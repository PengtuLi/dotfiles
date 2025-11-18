# Dotfiles

My personal development environment configuration.

## Quick Start

```bash
git clone https://github.com/tutu/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

## Stack

### Core

| Category | Tool |
| --- | --- |
| **Shell** | Zsh (atuin, zoxide, fzf, fzf-tab, autosuggestions, syntax-highlighting) |
| **Prompt** | Starship |
| **Editor** | NeoVim (Lua + lazy.nvim) |
| **Multiplexer** | Tmux + tmuxinator (tmux-resurrect, tmux-continuum, which-key) |

### CLI Tools

| Category | Tool | Description |
| --- | --- | --- |
| **File** | yazi | Terminal file manager |
| **File** | fd | Fast file search |
| **File** | ripgrep | Content search |
| **File** | 7-Zip | Archive extraction |
| **Git** | lazygit | Interactive Git TUI |
| **Git** | git-delta | Enhanced diff viewer |
| **Git** | tig | Text-mode Git interface |
| **Viewers** | bat | Cat with syntax highlighting |
| **Viewers** | jq | JSON processor |
| **System** | btop | System monitor |
| **System** | fastfetch | System info |
| **System** | pstree | Process tree |
| **Utils** | fzf | Fuzzy finder |
| **Utils** | zoxide | Smart directory jump |
| **Utils** | atuin | Shell history sync |
| **Utils** | thefuck | Command correction |
| **Utils** | tldr | Simplified man pages |
| **Dev** | gdb | Debugger |
| **Dev** | pudb | Python debugger |
| **Dev** | uv | Python package manager |
| **Dev** | harper | Language server |
| **Dev** | vale-lint | Linting tool |
| **Misc** | tokei | Code counter |
| **Misc** | hyperfine | Benchmarking |
| **Misc** | code2prompt | AI tool |

### Terminal

| Platform | Tools |
| --- | --- |
| **Cross-platform** | Ghostty |
| **macOS** | Ghostty |
| **Linux** | Ghostty |
| **Windows** | Windows Terminal with wsl |

### Window Managers

| Platform | Tools |
| --- | --- |
| **macOS** | Yabai + Skhd (tiling), Aerospace (tiling), Rectangle (floating) |
| **Linux (Wayland)** | Sway + Waybar + Swaync, Niri, Hyprlock |
| **Linux (Input)** | Fcitx5, Fuzzel (launcher) |
| **Windows** | PowerToys, AutoHotKey |

### Desktop Apps

| Category | Tool |
| --- | --- |
| **Editor** | VSCode (settings, snippets, keybindings) |
| **macOS** | Karabiner (keyboard), Stats (monitor) |

### Quality & Security

| Category | Tool |
| --- | --- |
| **Git Hooks** | Husky |
| **Commits** | Commitlint (conventional commits) |
| **Secrets** | SOPS + Age |

## Keybindings

### Ghostty

```text
Alt+Shift+,    reload config
Alt+S/V        split down/right
Alt+H/J/K/L    navigate splits
Ctrl+Shift+C/V copy/paste
Alt+1-9        goto tab
Alt+N/T        new window/tab
Alt+Enter      fullscreen
```

### Tmux (Prefix: Ctrl+b)

```text
Prefix+Space   which-key
Prefix+R       reload config
Prefix+S/V     split horizontal/vertical
Ctrl+H/J/K/L   navigate panes
Prefix+H/L     resize panes
Prefix+C-S/R   save/restore session
```

## License

MIT
