# Dotfiles

This repository contains my dotfiles, which are the config files and scripts I use to customize my development environment. These files help me maintain a consistent setup across different machines and save time when setting up new environments.

## Essential Tools

- **Editor**: [NeoVim](https://neovim.io/). 
- **Multiplexer**: [Tmux](https://github.com/tmux/tmux/wiki)
- **Main Terminal**: [Ghostty](https://ghostty.org/)
- **Shell Prompt**: [Starship](https://starship.rs/)
- **Window Management**: [Rectangle](https://github.com/rxhanson/Rectangle) for resizing windows, paired with [Karabiner-Elements](https://karabiner-elements.pqrs.org/) for switching between applications.
- **File Manager**: [Superfile](https://superfile.netlify.app/)
- **hotkey-macos** [Karabiner-Elements](https://karabiner-elements.pqrs.org/) as my hotkey set tool in macos

## Setup

To set up these dotfiles on your system, run:

```bash
./install.sh
```

To delete all symlinks created by the installation script, run:

```bash
./scripts/symlinks.sh --delete
```

