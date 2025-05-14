# Dotfiles

This repository contains my dotfiles, which are the config files and scripts I use to customize my development environment. These files help me maintain a consistent setup across different machines and save time when setting up new environments.

## Essential Tools

- **Editor**: [NeoVim](https://neovim.io/). 
- **Multiplexer**: [Tmux](https://github.com/tmux/tmux/wiki)
- **Main Terminal**: [Ghostty](https://ghostty.org/)
- **Shell Prompt**: [Starship](https://starship.rs/)
- **Window Management**: [Rectangle](https://github.com/rxhanson/Rectangle) for resizing windows, paired with [Karabiner-Elements](https://karabiner-elements.pqrs.org/) for switching between applications.
- **File Manager**: [Superfile](https://superfile.netlify.app/)

## Custom Window Management

I'm not a fan of the default window management solutions that macOS provides, like repeatedly pressing Cmd+Tab to switch apps or using the mouse to click and drag. To streamline my workflow, I created a custom window management solution using [Karabiner-Elements](https://karabiner-elements.pqrs.org/) and [Rectangle](https://rectangleapp.com/). By using these tools together, I can efficiently manage my windows and switch apps with minimal mental overhead and maximum speed, using only my keyboard. Here's how it works:

### Tab Key as Hyperkey

The `Tab` key acts as a regular `Tab` when tapped, but when held, it provides additional functionalities.

### Access Exposé Layer

Holding `Tab + E` enables an exposé layer, where other keys become shortcuts to open specific apps.

**Examples:**

- `Tab + E + J`: Open browser
- `Tab + E + K`: Open terminal

## Setup

To set up these dotfiles on your system, run:

```bash
./install.sh
```

To delete all symlinks created by the installation script, run:

```bash
./scripts/symlinks.sh --delete
```

