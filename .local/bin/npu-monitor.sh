#!/bin/bash
# npu-monitor.sh - Enhanced NPU monitor with process/user/docker info
# Usage:
#   ./npu-monitor.sh                    # show once
#   watch -n 2 ./npu-monitor.sh         # auto-refresh every 2s

# ==================== System constants ====================
CLK_TCK=$(getconf CLK_TCK)
UPTIME_S=$(awk '{printf "%.0f", $1}' /proc/uptime)
NOW_EPOCH=$(date +%s)

# ==================== 1. Parse npu-smi ====================
RAW=$(npu-smi info 2>/dev/null) || { echo "Error: npu-smi not available" >&2; exit 1; }

declare -A NPU_NAME NPU_HEALTH NPU_POWER NPU_TEMP NPU_AICORE NPU_HBM NPU_BUSID
declare -A NPU_PIDS

NPU_ID=""
while IFS= read -r line; do
    if [[ "$line" =~ ^\|[[:space:]]+([0-9]+)[[:space:]]+([^ |]+)[[:space:]]+\|[[:space:]]+([^ |]+)[[:space:]]+\|[[:space:]]+([0-9.]+)[[:space:]]+([0-9]+)[[:space:]] ]]; then
        NPU_ID="${BASH_REMATCH[1]}"
        NPU_NAME[$NPU_ID]="${BASH_REMATCH[2]}"
        NPU_HEALTH[$NPU_ID]="${BASH_REMATCH[3]}"
        NPU_POWER[$NPU_ID]="${BASH_REMATCH[4]}"
        NPU_TEMP[$NPU_ID]="${BASH_REMATCH[5]}"
    fi
    if [[ "$line" =~ ^\|[[:space:]]+0[[:space:]]+\|[[:space:]]+([0-9a-fA-F:.]+)[[:space:]]+\|[[:space:]]+([0-9]+)[[:space:]]+[0-9]+[[:space:]]*/[[:space:]]*[0-9]+[[:space:]]+([0-9]+)[[:space:]]*/[[:space:]]*([0-9]+) ]]; then
        NPU_BUSID[$NPU_ID]="${BASH_REMATCH[1]}"
        NPU_AICORE[$NPU_ID]="${BASH_REMATCH[2]}"
        NPU_HBM[$NPU_ID]="${BASH_REMATCH[3]}/${BASH_REMATCH[4]}"
    fi
    if [[ "$line" =~ ^\|[[:space:]]+([0-9]+)[[:space:]]+0[[:space:]]+\|[[:space:]]+([0-9]+)[[:space:]]+\|[[:space:]]+([^|]+[^|[:space:]])[[:space:]]+\|[[:space:]]+([0-9]+) ]]; then
        n_id="${BASH_REMATCH[1]}"
        pid="${BASH_REMATCH[2]}"
        if [ -n "${NPU_PIDS[$n_id]}" ]; then
            NPU_PIDS[$n_id]="${NPU_PIDS[$n_id]},$pid"
        else
            NPU_PIDS[$n_id]="$pid"
        fi
    fi
done <<< "$RAW"

# ==================== 2. Docker info (single docker inspect call) ====================
declare -A DCK  # indexed by full_id_prefix12 -> "name|image|ports|uptime"

container_ids=$(docker ps -q 2>/dev/null)
if [ -n "$container_ids" ]; then
    docker inspect --format '{{.Id}}|{{.Name}}|{{.Config.Image}}|{{json .NetworkSettings.Ports}}|{{.State.StartedAt}}' $container_ids 2>/dev/null | while IFS='|' read -r full_id c_name c_img ports_json started; do
        # Strip leading / from container name
        c_name="${c_name#/}"
        # Short ID (first 12 hex chars of full ID)
        short="${full_id:0:12}"

        # Parse ports
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

        # Parse uptime
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
    done > /tmp/.npu_monitor_dck_$$

    while IFS='|' read -r idx c_name c_img port_str up_str; do
        DCK["$idx"]="${c_name}|${c_img}|${port_str}|${up_str}"
    done < /tmp/.npu_monitor_dck_$$
    rm -f /tmp/.npu_monitor_dck_$$
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

# Returns 5 pipe-separated fields: user|c_name|c_img|c_ports|c_up
get_pid_info() {
    local pid=$1
    local user="root" c_name="(host)" c_img="" c_ports="" c_up=""

    [ ! -d "/proc/$pid" ] && echo "GONE|(exited)|||" && return

    # User
    local uid=$(awk '/^Uid:/{print $2}' /proc/$pid/status 2>/dev/null)
    if [ -n "$uid" ] && [ "$uid" != "0" ] && [ "$uid" != "4294967295" ]; then
        local resolved=$(getent passwd "$uid" 2>/dev/null | cut -d: -f1)
        [ -n "$resolved" ] && user="$resolved"
    fi

    # Docker via cgroup
    local cgroup_line=$(head -1 /proc/$pid/cgroup 2>/dev/null)
    if [[ "$cgroup_line" =~ docker-([a-f0-9]+)\.scope ]]; then
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
    fi

    echo "${user}|${c_name}|${c_img}|${c_ports}|${c_up}"
}

# ==================== 4. Print ====================

# First, show raw npu-smi output
echo "$RAW"
echo ""

# Then append our enhanced process details
echo "  Enhanced Process Details  $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

printf "  %-3s %-9s %-8s %-6s %-16s %-7s %-5s %-25s %-10s %-12s\n" \
    "NPU" "PID" "User" "Age" "Process" "Mem(MB)" "HBM%" "Container" "Ports" "Up"
printf "  %-3s %-9s %-8s %-6s %-16s %-7s %-5s %-25s %-10s %-12s\n" \
    "---" "--------" "----" "----" "------" "-------" "-----" "---------" "-----" "--"

for id in $(echo "${!NPU_PIDS[@]}" | tr ' ' '\n' | sort -n); do
    IFS=',' read -ra pids <<< "${NPU_PIDS[$id]}"

    hbm="${NPU_HBM[$id]}"
    hbm_used=$(echo "$hbm" | cut -d'/' -f1)
    hbm_total=$(echo "$hbm" | cut -d'/' -f2)
    hbm_pct=0
    [ "$hbm_total" -gt 0 ] 2>/dev/null && hbm_pct=$((hbm_used * 100 / hbm_total))

    for pid in "${pids[@]}"; do
        info=$(get_pid_info "$pid")
        user=$(echo "$info" | cut -d'|' -f1)
        c_name=$(echo "$info" | cut -d'|' -f2)
        c_ports=$(echo "$info" | cut -d'|' -f4)
        c_up=$(echo "$info" | cut -d'|' -f5)

        pname=$(cat /proc/$pid/comm 2>/dev/null || echo "?")
        age=$(get_pid_age "$pid")

        pmem=$(echo "$RAW" | awk -v pid="$pid" '
            $0 ~ "\\| +" pid " +\\|" {
                n=split($0, a, "|")
                for(i=1;i<=n;i++) {
                    gsub(/^ +| +$/, "", a[i])
                    if(a[i] ~ /^[0-9]+$/) mem=a[i]
                }
            }
            END{print mem+0}
        ')

        # Truncate long container names
        c_disp="$c_name"
        [ ${#c_disp} -gt 24 ] && c_disp="${c_disp:0:22}.."

        printf "  %-3s %-9s %-8s %-6s %-16s %-7s %3d%%   %-25s %-10s %-12s\n" \
            "$id" "$pid" "$user" "$age" "$pname" "$pmem" "$hbm_pct" \
            "$c_disp" "${c_ports:0:10}" "${c_up}"
    done
done

echo ""
