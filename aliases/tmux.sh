if [[ -n "$TMUX" ]]; then
  echo -e '\e[5 q'
fi

if which tmux 2>&1 >/dev/null; then
  if ls /tmp/tmux-* >/dev/null 2>&1;then
    if [ $TERM != "screen-256color" ] && [  $TERM != "screen" ]; then
      tmux attach -t default || tmux new -s default
    fi
  fi
fi
