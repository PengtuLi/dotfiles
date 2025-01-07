return {
  'rmagatti/auto-session',
  lazy = false,

  keys = {
    { '<leader>sa', '<cmd>AutoSession search<CR>', desc = 'search [a]uto-session' },
    -- { '<leader>aS', '<cmd>AutoSession save<CR>', desc = 'save session' },
    { '<leader>ta', '<cmd>AutoSession toggle<CR>', desc = 'toggle [a]utosave session' },
  },

  ---enables autocomplete for opts
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
    -- log_level = 'debug',
    show_auto_restore_notif = true,

    session_lens = {
      picker = 'fzf',
    },
  },
}
