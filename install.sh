#!/bin/sh
# Install this repository's dotfiles into the current user's home directory.
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
home_dir=${HOME:?HOME is not set}
backup_suffix=$(date +%Y%m%d%H%M%S)

backup_if_needed() {
    target=$1
    if [ -e "$target" ] || [ -L "$target" ]; then
        case "$target" in
            "$repo_dir"/*) return ;;
        esac
        backup="${target}.backup.${backup_suffix}"
        printf 'Backing up %s to %s\n' "$target" "$backup"
        mv "$target" "$backup"
    fi
}

link_file() {
    source=$1
    target=$2
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        printf 'Already linked %s -> %s\n' "$target" "$source"
        return
    fi
    backup_if_needed "$target"
    if [ ! -L "$target" ]; then
        ln -s "$source" "$target"
    fi
    printf 'Linked %s -> %s\n' "$target" "$source"
}

link_file "$repo_dir/.bash_aliases" "$home_dir/.bash_aliases"
link_file "$repo_dir/.vimrc" "$home_dir/.vimrc"

mkdir -p "$home_dir/.config"
link_file "$repo_dir/.config/nvim" "$home_dir/.config/nvim"

# macOS uses zsh by default. Bash does not load .bash_aliases automatically,
# so make the aliases available in both common interactive shell startup files.
for rc in "$home_dir/.zshrc" "$home_dir/.bashrc" "$home_dir/.bash_profile"; do
    touch "$rc"
    source_line='. "$HOME/.bash_aliases"'
    if ! grep -Fqx "$source_line" "$rc" 2>/dev/null; then
        printf '\n# Dotfiles\n%s\n' "$source_line" >> "$rc"
        printf 'Configured %s\n' "$rc"
    fi
done

printf '\nDone. Restart your terminal, or run: source ~/.zshrc\n'
