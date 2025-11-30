return {
  {
    'christoomey/vim-tmux-navigator',
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
      'TmuxNavigatorProcessList',
    },
    keys = {
      { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>', desc = 'Move to the left window' },
      { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>', desc = 'Move to the right window' },
      { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>', desc = 'Move to the lower window' },
      { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>', desc = 'Move to the upper window' },
      { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>', desc = 'Move to the previous window' },
    },
  },
}
