# Shared functions (POSIX compatible)

# Cheat.sh lookup
cheatsh() {
    if [ -z "$1" ]; then
        echo "Usage: cheatsh <topic>" && return 1
    fi
    curl -s "cht.sh/$1"
}

# Quick file backup
backup() {
    if [ -z "$1" ]; then
        echo "Usage: backup <file>" && return 1
    fi
    local file="$1"
    if [ -e "$file" ]; then
        cp -r "$file" "$file.bak_$(date +%Y%m%d_%H%M%S)"
        echo "Backed up $file to $file.bak_$(date +%Y%m%d_%H%M%S)"
    else
        echo "Error: $file does not exist"
        return 1
    fi
}

# Extract various archive formats
extract() {
    if [ -z "$1" ]; then
        echo "Usage: extract <archive>" && return 1
    fi
    if [ ! -f "$1" ]; then
        echo "Error: '$1' is not a valid file" && return 1
    fi
    # prefer ouch if available
    if command -v ouch >/dev/null 2>&1; then
        ouch d "$1"
        return
    fi
    # fallback to system tools
    case "$1" in
        *.tar.bz2)   tar xjf "$1"     ;;
        *.tar.gz)    tar xzf "$1"     ;;
        *.bz2)       bunzip2 "$1"     ;;
        *.gz)        gunzip "$1"      ;;
        *.tar)       tar xf "$1"      ;;
        *.tbz2)      tar xjf "$1"     ;;
        *.tgz)       tar xzf "$1"     ;;
        *.zip)       unzip "$1"       ;;
        *.Z)         uncompress "$1"  ;;
        *)           echo "'$1' cannot be extracted via extract()" && return 1 ;;
    esac
}

# Compress files into archive
compress() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: compress <output.tar.gz> <file1> [file2 ...]" && return 1
    fi
    # prefer ouch if available
    if command -v ouch >/dev/null 2>&1; then
        local output="$1"; shift
        ouch c "$@" "$output"
        return
    fi
    # fallback to system tools
    local output="$1"; shift
    case "$output" in
        *.tar.gz|*.tgz)    tar czf "$output" "$@" ;;
        *.tar.bz2|*.tbz2)  tar cjf "$output" "$@" ;;
        *.tar)              tar cf "$output" "$@"  ;;
        *.zip)              zip -r "$output" "$@"  ;;
        *.gz)               gzip -c "$@" > "$output" ;;
        *)                  echo "Unsupported format: $output" && return 1 ;;
    esac
}

# Port usage check
port() {
    if [ -z "$1" ]; then
        sudo lsof -i -P -n 2>/dev/null || lsof -i -P -n 2>/dev/null
        return
    fi
    sudo lsof -i :"$1" -P -n 2>/dev/null || lsof -i :"$1" -P -n 2>/dev/null
}

# Find and activate .venv in parent directories
uv-activate() {
    local dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/.venv/bin/activate" ]; then
            echo "Activating virtual environment: $dir/.venv"
            source "$dir/.venv/bin/activate"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    echo "No .venv found in any parent directory." >&2
    return 1
}

# Yazi with cd on exit
y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

# Show all aliases formatted
show_aliases() {
    alias | while read -r line; do
        alias_name="${line%%=*}"
        alias_command="${line#*=}"
        dash_length=$((20 - ${#alias_name}))
        dashes=$(printf '%*s' "$dash_length" | tr ' ' '-')
        printf "\033[31m%-s\033[0m \033[37m%s\033[0m \033[32m%s\033[0m\n" "$alias_name" "$dashes" "$alias_command"
    done
}

# Tmux auto-start
if command -v tmux >/dev/null 2>&1; then
    if [ -z "$TMUX" ] && [ -e ~/.tmux-auto-start ]; then
        tmux attach -t default || tmux new -s default
    fi
fi
