# Dotfiles

My personal development environment configuration.

## Quick Start

First install just and python.

```bash
git clone https://github.com/tutu/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
just
```

## Stack

按工具类别组织，平台相关预设见 [Justfile](#presets)。

### Shell & Terminal

| Category | Tool |
| --- | --- |
| **Shell** | Zsh + Bash |
| **Prompt** | Starship |
| **History** | Atuin |
| **Fuzzy finder** | fzf |
| **Navigation** | zoxide |
| **Terminal** | Ghostty, Windows Terminal |
| **Multiplexer** | Tmux + tmuxinator |

### Editors & IDE

| Category | Tool |
| --- | --- |
| **Editor** | Neovim (Lua + lazy.nvim) |
| **IDE** | Visual Studio Code |

### File & System Tools

| Category | Tool |
| --- | --- |
| **File manager** | yazi |
| **ls replacement** | eza |
| **cat replacement** | bat |
| **find replacement** | fd |
| **grep replacement** | ripgrep |
| **System info** | fastfetch, btop |
| **Process / disk / network** | procs, duf, dust, doggo, gping |
| **Benchmark** | hyperfine |
| **Archive** | ouch |

### Git & Quality

| Category | Tool |
| --- | --- |
| **Git** | git, git-delta, gitui, lazygit, gh, onefetch |
| **Hooks** | Husky, pre-commit, gitleaks |
| **Commits** | Commitlint (conventional commits) |
| **Secrets** | SOPS + Age |

### Network, Proxy & VPN

| Category | Tool |
| --- | --- |
| **Proxy** | Mihomo (Clash Meta) |
| **Mesh VPN** | EasyTier |
| **Remote sync** | rclone, rsync, fswatch |
| **SSH helpers** | ssh-select, ssh-forward, sshfs-mount, rsync-auto |

### Desktop Environment

| Category | Tool |
| --- | --- |
| **macOS WM** | Aerospace |
| **macOS keyboard** | Karabiner-Elements |
| **macOS tweaks** | Mos, Caffeine, Ice, Stats, Rectangle |
| **Linux WM** | Niri |
| **Linux launcher** | Fuzzel |
| **Linux status** | waybar, swaync |
| **Linux lock / idle** | Hyprlock, swayidle |
| **Linux Input** | fcitx5 |
| **Windows / WSL** | PowerToys, AutoHotkey, Windows Terminal |

## License

MIT
