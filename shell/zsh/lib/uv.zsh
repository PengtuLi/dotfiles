uv-activate() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/.venv/bin/activate" ]]; then
            echo "Activating virtual environment: $dir/.venv"
            source "$dir/.venv/bin/activate"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    echo "No .venv found in any parent directory." >&2
    return 1
}
