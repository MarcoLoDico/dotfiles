# Keep `vim` as standard Vim; use the Neovim config through `vi` or `nvim`.
unalias vim 2>/dev/null || true
if command -v nvim >/dev/null 2>&1; then
    alias vi='nvim'
fi

venv() {
    if [ "$1" = "-d" ]; then
        if [ -n "$VIRTUAL_ENV" ]; then
            deactivate
        else
            echo "No virtual environment is currently active."
        fi
    else
        # Look for common venv directory names
        local venv_dir=""
        for dir in venv env my_env .venv; do
            if [ -d "$dir" ] && [ -f "$dir/bin/activate" ]; then
                venv_dir="$dir"
                break
            fi
        done
        
        if [ -n "$venv_dir" ]; then
            source "$venv_dir/bin/activate"
        else
            echo "No virtual environment found. Looking for: venv, env, my_env, .venv"
        fi
    fi
}
