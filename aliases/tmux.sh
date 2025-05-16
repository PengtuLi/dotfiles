if [[ -n "$TMUX" ]]; then
  echo -e '\e[5 q'
fi

# auto start tmux
if which tmux 2>&1 >/dev/null; then
  if [ $TERM != "screen-256color" ] && [  $TERM != "screen" ] && [ -e ~/.tmux-auto-start ]; then
    tmux attach -t default || tmux new -s default
  fi
fi

alias t-en="touch ~/.tmux-auto-start"
alias t-dis="rm -f ~/.tmux-auto-start"
