return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      delay = 0,
      preset = 'classic',
      plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        spelling = {
          enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
          suggestions = 20, -- how many suggestions should be shown in the list?
        },
        presets = {
          operators = true, -- adds help for operators like d, y, ...
          motions = true, -- adds help for motions
          text_objects = true, -- help for text objects triggered after entering an operator
          windows = true, -- default bindings on <c-w>
          nav = true, -- misc bindings to work with windows
          z = true, -- bindings for folds, spelling and others prefixed with z
          g = true, -- bindings for prefixed with g
        },
      },
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },
      triggers = {
        { '<auto>', mode = 'nixsotc' },
      },

      -- Document existing key chains
      spec = {
        { '<leader>s', group = '[s]earch' },
        { 's', group = '[s]ourround' },
        { '<leader>a', group = '[a]uto-session' },
        { '<leader>t', group = '[t]oggle' },
        { '<leader>h', group = 'git [h]unk', mode = { 'n', 'v' } },
        { '<leader>k', group = 'duc[k]', mode = { 'n' } },
        { '<leader>b', group = '[b]uffer', mode = { 'n' } },

        -- other built-in useful
        { 'gd', desc = 'Go to Declaration of local variable under cursor', mode = { 'n' } },
        { 'gD', desc = 'Go to Declaration of global variable under cursor', mode = { 'n' } },
        { '.', desc = 'Repeat lash action', mode = { 'n' } },
      },
    },
  },
}
