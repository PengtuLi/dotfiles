# Dotfiles

My personal development environment configuration.

## Quick Start

```bash
git clone https://github.com/tutu/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
just ***
```

## Stack

### Core

| Category | Tool |
| --- | --- |
| **Shell** | Zsh (atuin, zoxide, fzf, fzf-tab, autosuggestions, syntax-highlighting) |
| **Prompt** | Starship |
| **Editor** | NeoVim (Lua + lazy.nvim) |
| **Multiplexer** | Tmux + tmuxinator (tmux-resurrect, tmux-continuum, which-key) |

### Window Managers

| Platform | Tools |
| --- | --- |
| **macOS** | Yabai + Skhd (tiling), Aerospace (tiling), Rectangle (floating) |
| **Linux (Wayland)** | Sway + Waybar + Swaync, Niri, Hyprlock |
| **Linux (Input)** | Fcitx5, Fuzzel (launcher) |
| **Windows** | PowerToys, AutoHotKey |

### Quality & Security

| Category | Tool |
| --- | --- |
| **Git Hooks** | Husky |
| **Commits** | Commitlint (conventional commits) |
| **Secrets** | SOPS + Age |

## License

MIT
