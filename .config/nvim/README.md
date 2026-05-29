# Neovim config

Small Neovim setup focused on code highlighting, editing, and reviewing Git changes.

## Install / link

This repo expects the config at:

```sh
~/.config/nvim
```

If needed, link it from the dotfiles repo:

```sh
mkdir -p ~/.config
ln -s ~/src/dotfiles/.config/nvim ~/.config/nvim
```

Recommended tools:

```sh
brew install neovim ripgrep fd
```

Open Neovim with:

```sh
nvim
```

On first launch, `lazy.nvim` installs the plugins automatically. You can manage plugins with:

```vim
:Lazy
```

## Basics

The leader key is `Space`.

Common mappings:

| Key | Action |
| --- | --- |
| `<Space>w` | Save |
| `<Space>q` | Quit |
| `<Space>e` | Open file explorer |
| `<Space>h` | Clear search highlight |
| `<Space>tw` | Trim trailing whitespace |
| `<C-h/j/k/l>` | Move between splits |

## Finding files and text

Powered by Telescope:

| Key | Action |
| --- | --- |
| `<Space>ff` | Find files |
| `<Space>fg` | Search text in repo |
| `<Space>fb` | Find open buffers |
| `<Space>fr` | Recent files |
| `<Space>fh` | Help tags |

## Git hunks while editing

Powered by Gitsigns:

| Key | Action |
| --- | --- |
| `]c` | Next Git hunk |
| `[c` | Previous Git hunk |
| `<Space>gp` | Preview hunk |
| `<Space>gs` | Stage hunk |
| `<Space>gx` | Reset hunk |
| `<Space>gu` | Undo staged hunk |
| `<Space>gb` | Blame current line |
| `<Space>gB` | Toggle inline blame |
| `<Space>gd` | Diff current file |

## Reviewing changes / AI edits

For a repo with uncommitted changes:

```sh
cd path/to/repo
nvim
```

Then press:

```text
<Space>gr
```

Or run:

```vim
:DiffviewOpen
```

This opens a read-only review tab. It is for reviewing, not inserting text.

Useful Diffview controls:

| Key / command | Action |
| --- | --- |
| `j` / `k` | Move around |
| `Enter` | Open selected file from the file panel |
| `]c` / `[c` | Next / previous change |
| `<C-w>h` / `<C-w>l` | Move between panels |
| `<Space>gq` | Close Diffview |
| `:DiffviewClose` | Close Diffview |
| `:qa!` | Force quit Neovim if stuck |

For untracked files, make them visible to Git diff without staging contents:

```sh
git add -N path/to/file
```

Then review with either:

```sh
git diff
```

or:

```vim
:DiffviewOpen
```

## Notes

- This config intentionally stays small.
- It does not include LSP/completion yet; add that later per language if needed.
- Treesitter provides code-aware highlighting and indentation.
- Diff settings use histogram + linematch for cleaner code review diffs.
