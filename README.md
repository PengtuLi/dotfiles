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

### Quality & Security

| Category | Tool |
| --- | --- |
| **Git Hooks** | Husky |
| **Commits** | Commitlint (conventional commits) |
| **Secrets** | SOPS + Age |

## License

MIT
