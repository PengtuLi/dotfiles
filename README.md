## Dotfiles

This repository contains my dotfiles, which are the config files and scripts I use to customize my development environment. These files help me maintain a consistent setup across different machines and save time when setting up new environments.

## Essential Tools

- **Editor**: [NeoVim](https://neovim.io/).
- **Multiplexer**: [Tmux](https://github.com/tmux/tmux/wiki)
- **Main Terminal**: [Ghostty](https://ghostty.org/)
- **Shell Prompt**: [Starship](https://starship.rs/)
- **Window Management**: [Rectangle](https://github.com/rxhanson/Rectangle/) for resizing windows, paired with [Karabiner-Elements](https://karabiner-elements.pqrs.org/) for switching between applications.
<!-- - **File Manager**: [Superfile](https://superfile.netlify.app/) -->
- **hotkey-macos** [Karabiner-Elements](https://karabiner-elements.pqrs.org/) as my hotkey set tool in macos
- **fzf** [fzf](https://github.com/junegunn/fzf/) as fuzzy finder

## Ghostty

```shell
快捷键：

alt   + shift + ,       reload_config
alt   + shift + 0       equalize_splits
alt   + shift + enter   toggle_split_zoom
alt   + shift + d       new_split:right
alt   + shift + h       resize_split:left,20
alt   + shift + j       resize_split:down,20
alt   + shift + k       resize_split:up,20
alt   + shift + l       resize_split:right,20
alt   + shift + w       close_tab:this
ctrl  + shift + c       copy_to_clipboard
ctrl  + shift + v       paste_from_clipboard
alt   + digit_1         goto_tab:1
alt   + digit_2         goto_tab:2
alt   + digit_3         goto_tab:3
alt   + digit_4         goto_tab:4
alt   + digit_5         goto_tab:5
alt   + digit_6         goto_tab:6
alt   + digit_7         goto_tab:7
alt   + digit_8         goto_tab:8
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
alt   + 9               last_tab
alt   + enter           toggle_fullscreen
alt   + page_down       scroll_page_down
alt   + page_up         scroll_page_up
alt   + arrow_down      jump_to_prompt:1
alt   + arrow_up        jump_to_prompt:-1
alt   + c               clear_screen
alt   + d               new_split:down
alt   + h               goto_split:left
alt   + j               goto_split:down
alt   + k               goto_split:up
alt   + l               goto_split:right
alt   + n               new_window
alt   + t               new_tab
alt   + w               close_window
alt   + f4              close_window
copy                    copy_to_clipboard
paste                   paste_from_clipboard

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
- split window: `Prefix + -or|`
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
- cd into the selected directory: `ALT-C`
- auto complete: `command [dir]/[fzf pattern]** + TAB` (linux error)

### fzf-tab

- Just press Tab as usual~
- Ctrl+Space: select multiple results, can be configured by fzf-bindings tag
- F1/F2: switch between groups, can be configured by switch-group tag
- /: trigger continuous completion (useful when completing a deep path), can be configured by continuous-trigger tag

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
