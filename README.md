## Dotfiles

This repository contains my dotfiles, which are the config files and scripts I use to customize my development environment. These files help me maintain a consistent setup across different machines and save time when setting up new environments.

## Essential Tools

### Core Development Environment

- **Editor**: NeoVim (Lua configuration with lazy.nvim plugin manager)
- **Multiplexer**: Tmux with tmuxinator for session management
- **Shell**: Zsh with atuin (history), zoxide (navigation), fzf (search)
- **Prompt**: Starship cross-shell prompt
- **Terminal**: Ghostty (modern terminal emulator)

### File Management

- **File Manager**: Yazi (modern terminal file manager)
- **Git**: Lazygit for terminal git operations
- **Search**: fzf integrated throughout the system

### Platform-Specific

- **macOS**: Rectangle (window management), Karabiner (keyboard remapping)
- **Linux**: Sway (Wayland compositor), headless server support

### Git Hooks and Quality

- Uses Husky for pre-commit hooks
- Commitlint for conventional commit message formatting
- SOPS with Age encryption for secrets management

### Remote Integration

- Docker volume mounting via SSHFS
- Auto-sync capabilities for remote development

## Network Features

- mihomo/Clash proxy support with automatic updates
- rclone
- SMB/NAS file sharing setup
- easytier

## Ghostty

```shell
快捷键：

alt   + shift + ,       reload_config
alt   + shift + 0       equalize_splits
alt   + shift + enter   toggle_split_zoom
alt   + s               new_split:down
alt   + v               new_split:right
alt   + shift + h       resize_split:left,20
alt   + shift + j       resize_split:down,20
alt   + shift + k       resize_split:up,20
alt   + shift + l       resize_split:right,20
ctrl  + shift + c       copy_to_clipboard
ctrl  + shift + v       paste_from_clipboard
alt   + equal           increase_font_size:1
alt   + minus           decrease_font_size:1
alt   + 0               reset_font_size
alt   + 1               goto_tab:1
alt   + 2               goto_tab:2
alt   + 3               goto_tab:3
alt   + 4               goto_tab:4
alt   + 5               goto_tab:5
alt   + 6               goto_tab:6
alt   + 7               goto_tab:7
alt   + 8               goto_tab:8
alt   + enter           toggle_fullscreen
alt   + page_down       scroll_page_down
alt   + page_up         scroll_page_up
alt   + arrow_down      jump_to_prompt:1
alt   + arrow_up        jump_to_prompt:-1
alt   + h               goto_split:left
alt   + j               goto_split:down
alt   + k               goto_split:up
alt   + l               goto_split:right
alt   + n               new_window
alt   + t               new_tab
alt   + w               close_tab
alt   + shift + w       close_window

```

## Yazi

```text
# open file
o O e
# search
f s S z Z /
# help
f1
# copy path
c[]
# file
a r y x d p(P)
# file info
Tab
# select
v C-a Space
# task
w
# sort
,
# move
h j k l
H J K L
```

## Tmux

```shell
## Key Commands

# Start a new session
tmux new -s NewSession
# exit a session
tmux detach
# List sessions
tmux ls
# Go back into session
tmux attach -t NewSession
# Show all available options
tmux show-options -g
# Show all available shortcuts
tmux list-keys
# Show all available commands
tmux list-commands

# Start fresh
tmux kill-server && rm -rf /tmp/tmux-*

## Essential Shortcuts

- Prefix: `CTRL + b`
- reload cinfig: `Prefix + r`
- which key: `Predix + space`
- fzf integration: `Predix + F:w`

- Create new tmux window: `Prefix + c`
- Navigate to window: `Prefix + number`
- Cycle through window: `Prefix + n/p`
- Explore sessions: `Prefix + s`
- Explore all windows: `Prefix + w`
- Rename window: `Prefix + ,`
- Rename session: `Prefix + $`
- Detach: `Prefix + d`

- Save sessions: `Prefix + CTRL + s`
- Restore session: `Prefix + CTRL + r`
- Install plugins: `Prefix + I`
- list all shortcuts: `Prefix + ?`

- close panel: `Prefix + x`
- close all other panel: `Prefix + e`
- close window: `Prefix + &`
- places us in copy mode: `Prefix + [`
- split window: `Prefix + s or v`
- resize panel: `Prefix + hjkl`
- switch panel: `ctrl + hjkl\`
- switch panel: `ctrl + q + number`

## tmuxinator

```

## fzf

```shell
### fzf

- Paste the selected files and directories onto the command-line: `CTRL-T`
- Paste the selected command from history onto the command-line: `CTRL-R`
- auto complete: `command [dir]/[fzf pattern]** + TAB`

### fzf-tab

- Just press Tab as usual~
- Ctrl+Space: select multiple results, can be configured by fzf-bindings tag
- </>: switch between groups, can be configured by switch-group tag

```

## zoxide

```
z foo              # cd into highest ranked directory matching foo
z foo bar          # cd into highest ranked directory matching foo and bar
z foo /            # cd into a subdirectory starting with foo

z ~/foo            # z also works like a regular cd command
z foo/             # cd into relative path
z ..               # cd one level up
z -                # cd into previous directory

zi foo             # cd with interactive selection (using fzf)

z foo<SPACE><TAB>  # show interactive completions (zoxide v0.8.0+, bash 4.4+/fish/zsh only)
```
