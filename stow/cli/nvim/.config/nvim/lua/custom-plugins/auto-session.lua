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
    -- show_auto_restore_notif = true,

    session_lens = {
      picker = 'fzf',
      mappings = {
        -- Mode can be a string or a table, e.g. {"i", "n"} for both insert and normal mode
        delete_session = { 'i', '<C-x>' }, -- mode and key for deleting a session from the picker
        alternate_session = { 'i', '<C-s>' }, -- mode and key for swapping to alternate session from the picker
        copy_session = { 'i', '<C-y>' }, -- mode and key for copying a session from the picker
      },
    },
  },
}
