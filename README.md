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
- **fzf** [fzf](https://github.com/junegunn/fzf) as fuzzy finder

## Setup

To set up these dotfiles on your system, run:

```bash
./install.sh
```

To delete all symlinks created by the installation script, run:

```bash
./scripts/symlinks.sh --delete
```

## Ghostty

```shell
快捷键：
# 移动
super+up arrow: 向上滚动至上一行命令
super+down arrow: 向下滚动至下一行命令
super+page_up: 向上翻页。
super+page_down: 向下翻页。
super+home: 滚动到顶部
super+end: 滚动到底部
option+left mouse：在命令中移动指针

# 窗口管理
super+t: 新建标签页
super+n: 新建窗口
super+w: 关闭当前（标签页或分割窗口）
super+Shift+W：关闭窗口

super+enter: 切换全屏模式

super+d: 在右侧新建分割窗口
super+shift+d: 在下方新建分割窗口
super+alt+方向键：切换窗口
super+ctrl+方向键: 调整分割窗口大小
super+ctrl+equal: 使分割窗口大小相等

super+number:切换到对应的tab

# 大小调整
super+equal: 增加字体大小
super+minus: 减小字体大小
super+zero: 重置字体大小


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

## Useful Snippets

Add this to you `.zshrc` to always work in a Tmux session:

```shell
# Always work in a tmux session if Tmux is installed
if which tmux 2>&1 >/dev/null; then
  if [ $TERM != "screen-256color" ] && [  $TERM != "screen" ]; then
    tmux attach -t default || tmux new -s default; exit
  fi
fi
```

## fzf
