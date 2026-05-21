#!/bin/bash
# gpu-monitor.sh - Enhanced NVIDIA GPU monitor with process/user/docker/cwd/cmd info
# Usage:
#   ./gpu-monitor.sh                    # show once
#   watch -n 2 ./gpu-monitor.sh         # auto-refresh every 2s

# ==================== System constants ====================
CLK_TCK=$(getconf CLK_TCK)
UPTIME_S=$(awk '{printf "%.0f", $1}' /proc/uptime)
NOW_EPOCH=$(date +%s)

# Current shell/container context
MY_PID=$$
MY_CGROUP=$(head -1 /proc/self/cgroup 2>/dev/null)
MY_CWD=$(readlink -f /proc/self/cwd 2>/dev/null)

# ==================== 1. Parse nvidia-smi ====================
RAW=$(nvidia-smi 2>/dev/null) || { echo "Error: nvidia-smi not available" >&2; exit 1; }

# Also get process info from nvidia-smi
RAW_PMON=$(nvidia-smi pmon -c 1 2>/dev/null)

# Get detailed GPU info in query format for easier parsing
GPU_QUERY=$(nvidia-smi --query-gpu=index,name,temperature.gpu,utilization.gpu,utilization.memory,memory.used,memory.total,power.draw,power.limit,persistence_mode,pci.bus_id --format=csv,noheader,nounits 2>/dev/null)

# Get compute process info
COMPUTE_PROCS=$(nvidia-smi --query-compute-apps=pid,used_gpu_memory,process_name --format=csv,noheader,nounits 2>/dev/null)

declare -A GPU_NAME GPU_TEMP GPU_UTIL GPU_MEM_UTIL GPU_MEM_USED GPU_MEM_TOTAL GPU_POWER GPU_PWR_LIMIT GPU_BUSID
declare -A GPU_PIDS

# Parse GPU query info
while IFS=',' read -r idx name temp util mem_util mem_used mem_total power pwr_limit persist busid; do
    idx=$(echo "$idx" | xargs)
    name=$(echo "$name" | xargs)
    temp=$(echo "$temp" | xargs)
    util=$(echo "$util" | xargs)
    mem_util=$(echo "$mem_util" | xargs)
    mem_used=$(echo "$mem_used" | xargs)
    mem_total=$(echo "$mem_total" | xargs)
    power=$(echo "$power" | xargs)
    pwr_limit=$(echo "$pwr_limit" | xargs)
    persist=$(echo "$persist" | xargs)
    busid=$(echo "$busid" | xargs)

    GPU_NAME[$idx]="$name"
    GPU_TEMP[$idx]="$temp"
    GPU_UTIL[$idx]="$util"
    GPU_MEM_UTIL[$idx]="$mem_util"
    GPU_MEM_USED[$idx]="$mem_used"
    GPU_MEM_TOTAL[$idx]="$mem_total"
    GPU_POWER[$idx]="$power"
    GPU_PWR_LIMIT[$idx]="$pwr_limit"
    GPU_BUSID[$idx]="$busid"
done <<< "$GPU_QUERY"

# Parse pmon for per-process GPU utilization and association
# nvidia-smi pmon format: gpu_idx pid type sm mem enc dec command
declare -A PID_GPU_ID PID_SM PID_MEM_PID CMD_NAME
declare -A PID_GPU_MEM
declare -A PID_GPU_NAME

while IFS= read -r line; do
    [[ "$line" =~ ^# ]] && continue
    [[ -z "$line" ]] && continue
    read -r g_idx pid ptype sm mem enc dec cmd rest <<< "$line"
    [[ "$g_idx" == "gpu" ]] && continue
    [[ -z "$g_idx" || -z "$pid" || "$pid" == "-" ]] && continue

    # Associate PID to GPU
    if [ -n "${GPU_PIDS[$g_idx]}" ]; then
        if [[ ",${GPU_PIDS[$g_idx]}," != *",$pid,"* ]]; then
            GPU_PIDS[$g_idx]="${GPU_PIDS[$g_idx]},$pid"
        fi
    else
        GPU_PIDS[$g_idx]="$pid"
    fi

    PID_GPU_ID[$pid]="$g_idx"
    PID_SM[$pid]="$sm"
    CMD_NAME[$pid]="$cmd"
done <<< "$RAW_PMON"

# Also parse compute apps for memory info
while IFS=',' read -r pid mem_used pname; do
    pid=$(echo "$pid" | xargs)
    mem_used=$(echo "$mem_used" | xargs)
    pname=$(echo "$pname" | xargs)
    if [ -n "$pid" ] && [ "$pid" != "[Not Supported]" ]; then
        PID_GPU_MEM[$pid]="$mem_used"
        PID_GPU_NAME[$pid]="$pname"
    fi
done <<< "$COMPUTE_PROCS"

# ==================== 2. Docker info (single docker inspect call) ====================
declare -A DCK  # indexed by full_id_prefix12 -> "name|image|ports|uptime"

container_ids=$(docker ps -q 2>/dev/null)
if [ -n "$container_ids" ]; then
    docker inspect --format '{{.Id}}|{{.Name}}|{{.Config.Image}}|{{json .NetworkSettings.Ports}}|{{.State.StartedAt}}' $container_ids 2>/dev/null | while IFS='|' read -r full_id c_name c_img ports_json started; do
        c_name="${c_name#/}"
        short="${full_id:0:12}"

        port_str=""
        if [ -n "$ports_json" ] && [ "$ports_json" != "{}" ]; then
            port_str=$(echo "$ports_json" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    result = []
    for proto, bindings in d.items():
        if bindings:
            port = proto.split('/')[0]
            hp = bindings[0].get('HostPort','')
            if hp: result.append(hp + '->' + port)
    print(','.join(result))
except: pass
" 2>/dev/null)
        fi

        up_str=""
        if [ -n "$started" ]; then
            start_epoch=$(date -d "${started:0:19}" +%s 2>/dev/null)
            if [ -n "$start_epoch" ]; then
                diff=$((NOW_EPOCH - start_epoch))
                d=$((diff/86400)); h=$(( (diff%86400)/3600 )); m=$(( (diff%3600)/60 ))
                if [ "$d" -gt 0 ]; then up_str="${d}d${h}h"
                elif [ "$h" -gt 0 ]; then up_str="${h}h${m}m"
                else up_str="${m}m"; fi
            fi
        fi

        echo "${short}|${c_name}|${c_img}|${port_str}|${up_str}"
    done > /tmp/.gpu_monitor_dck_$$

    while IFS='|' read -r idx c_name c_img port_str up_str; do
        DCK["$idx"]="${c_name}|${c_img}|${port_str}|${up_str}"
    done < /tmp/.gpu_monitor_dck_$$
    rm -f /tmp/.gpu_monitor_dck_$$
fi

# ==================== 3. Helpers ====================

get_pid_age() {
    local pid=$1
    local starttime=$(awk '{print $22}' /proc/$pid/stat 2>/dev/null)
    [ -z "$starttime" ] && echo "?" && return
    local age_s=$(( UPTIME_S - starttime / CLK_TCK ))
    local d=$((age_s / 86400)) h=$(( (age_s % 86400) / 3600 )) m=$(( (age_s % 3600) / 60 ))
    if [ "$d" -gt 0 ]; then echo "${d}d${h}h"
    elif [ "$h" -gt 0 ]; then echo "${h}h${m}m"
    else echo "${m}m"; fi
}

# Returns 6 pipe-separated fields: user|c_name|c_img|c_ports|c_up|c_match
get_pid_info() {
    local pid=$1
    local user="root" c_name="(host)" c_img="" c_ports="" c_up="" c_match=""

    [ ! -d "/proc/$pid" ] && echo "GONE|(exited)||||" && return

    local uid=$(awk '/^Uid:/{print $2}' /proc/$pid/status 2>/dev/null)
    if [ -n "$uid" ] && [ "$uid" != "0" ] && [ "$uid" != "4294967295" ]; then
        local resolved=$(getent passwd "$uid" 2>/dev/null | cut -d: -f1)
        [ -n "$resolved" ] && user="$resolved"
    fi

    local cgroup_line=$(head -1 /proc/$pid/cgroup 2>/dev/null)
    if [[ "$cgroup_line" =~ docker-([a-f0-9]+)\.scope ]] || [[ "$cgroup_line" =~ docker/([a-f0-9]+) ]]; then
        local d_id="${BASH_REMATCH[1]:0:12}"
        if [ -n "${DCK[$d_id]}" ]; then
            local val="${DCK[$d_id]}"
            c_name="${val%%|*}"
            local rest="${val#*|}"
            c_img="${rest%%|*}"
            rest="${rest#*|}"
            c_ports="${rest%%|*}"
            c_up="${rest#*|}"
        fi

        # Mark if same container as current shell
        if [ -n "$MY_CGROUP" ] && [[ "$MY_CGROUP" == *"$d_id"* ]]; then
            c_match="*"
        fi
    fi

    echo "${user}|${c_name}|${c_img}|${c_ports}|${c_up}|${c_match}"
}

get_pid_cmdline() {
    local pid=$1
    local cmdline=""
    if [ -r "/proc/$pid/cmdline" ]; then
        cmdline=$(tr '\0' ' ' < /proc/$pid/cmdline 2>/dev/null)
    fi
    [ -z "$cmdline" ] && cmdline=$(cat /proc/$pid/comm 2>/dev/null)
    echo "$cmdline"
}

get_pid_cwd() {
    local pid=$1
    local cwd=$(readlink -f /proc/$pid/cwd 2>/dev/null)
    echo "${cwd:-?}"
}

# ==================== 4. Print ====================

# First, show raw nvidia-smi output
echo "$RAW"
echo ""

# Then append our enhanced process details
echo "  Enhanced Process Details  $(date '+%Y-%m-%d %H:%M:%S')"
echo "  (* = same container as this shell; MY_CWD=$MY_CWD)"
echo ""

printf "  %-3s %-9s %-8s %-6s %-16s %-10s %-6s %-25s %-10s %-12s\n" \
    "GPU" "PID" "User" "Age" "Process" "GPU Mem" "SM%" "Container" "Ports" "Up"
printf "  %-3s %-9s %-8s %-6s %-16s %-10s %-6s %-25s %-10s %-12s\n" \
    "---" "--------" "----" "----" "------" "--------" "----" "---------" "-----" "--"

for id in $(echo "${!GPU_PIDS[@]}" | tr ' ' '\n' | sort -n); do
    IFS=',' read -ra pids <<< "${GPU_PIDS[$id]}"

    for pid in "${pids[@]}"; do
        info=$(get_pid_info "$pid")
        user=$(echo "$info" | cut -d'|' -f1)
        c_name=$(echo "$info" | cut -d'|' -f2)
        c_ports=$(echo "$info" | cut -d'|' -f4)
        c_up=$(echo "$info" | cut -d'|' -f5)
        c_match=$(echo "$info" | cut -d'|' -f6)

        pname=$(cat /proc/$pid/comm 2>/dev/null || echo "?")
        age=$(get_pid_age "$pid")

        pmem="${PID_GPU_MEM[$pid]}"
        [ -z "$pmem" ] && pmem="-"

        sm="${PID_SM[$pid]}"
        [[ -z "$sm" || "$sm" == "-" ]] && sm="-"

        c_disp="$c_name"
        [ ${#c_disp} -gt 24 ] && c_disp="${c_disp:0:22}.."
        [ -n "$c_match" ] && c_disp="${c_match}${c_disp}"

        printf "  %-3s %-9s %-8s %-6s %-16s %-10s %-6s %-25s %-10s %-12s\n" \
            "$id" "$pid" "$user" "$age" "$pname" "$pmem" "$sm" \
            "$c_disp" "${c_ports:0:10}" "${c_up}"

        # Detailed info lines
        cmdline=$(get_pid_cmdline "$pid")
        cwd=$(get_pid_cwd "$pid")
        [ -n "$cmdline" ] && printf "      CMD: %s\n" "$cmdline"
        [ -n "$cwd" ] && printf "      CWD: %s\n" "$cwd"
    done
done

# If no processes found, show GPU summary instead
if [ ${#GPU_PIDS[@]} -eq 0 ]; then
    for id in $(echo "${!GPU_NAME[@]}" | tr ' ' '\n' | sort -n); do
        mem_used="${GPU_MEM_USED[$id]}"
        mem_total="${GPU_MEM_TOTAL[$id]}"
        temp="${GPU_TEMP[$id]}"
        power="${GPU_POWER[$id]}"

        printf "  %-3s %-9s %-8s %-6s %-16s %-10s %-6s %-25s %-10s %-12s\n" \
            "$id" "-" "-" "-" "(idle)" "${mem_used}/${mem_total}" "-" \
            "${GPU_NAME[$id]:0:24}" "${temp}°C" "${power}W"
    done
fi

echo ""
