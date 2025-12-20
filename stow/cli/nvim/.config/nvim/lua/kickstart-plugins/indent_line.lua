return {
  {
    'lukas-reineke/indent-blankline.nvim',
    -- event = { 'BufNewFile', 'BufRead' },
    event = 'VeryLazy',
    config = function()
      -- vim.opt.listchars:append "eol:↴"
      local highlight = {
        'RainbowRed',
        'RainbowOrange',
        'RainbowYellow',
        'RainbowGreen',
        'RainbowBlue',
        'RainbowIndigo',
        'RainbowViolet',
      }

      local hooks = require 'ibl.hooks'
      -- create the highlight groups in the highlight setup hook, so they are reset
      -- every time the colorscheme changes
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, 'RainbowRed', { fg = '#E06C75' })
        vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = '#D19A66' })
        vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = '#E5C07B' })
        vim.api.nvim_set_hl(0, 'RainbowGreen', { fg = '#98C379' })
        vim.api.nvim_set_hl(0, 'RainbowBlue', { fg = '#61AFEF' })
        vim.api.nvim_set_hl(0, 'RainbowIndigo', { fg = '#56B6C2' })
        vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#C678DD' })

        vim.api.nvim_set_hl(0, 'IBLScope', { fg = '#F8F8F8' })
      end)

      -- [ERROR] for complicated of depth of AST
      -- local function scope_color_index(tick, bufnr, scope, scope_index)
      --   local current_node = scope
      --   local depth = 0
      --   while current_node:parent() do
      --     current_node = current_node:parent()
      --     depth = depth + 1
      --   end
      --   local num_colors = #highlight
      --   local color_index = (depth % num_colors) + 0
      --   return color_index
      -- end
      --
      -- hooks.register(hooks.type.SCOPE_HIGHLIGHT, scope_color_index)

      local ibl = require 'ibl'
      ibl.setup {
        indent = {
          -- highlight = { 'Function', 'Label' },
          highlight = highlight,
          tab_char = '*',
          -- char = '▎',
          char = '▏',
          smart_indent_cap = true,
        },
        whitespace = { highlight = { 'Whitespace', 'NonText' } },
        scope = {
          show_start = true,
          show_end = true,
          priority = 1024,
          show_exact_scope = true,
          char = {
            '▌',
          },
        },
      }

      local hooks = require 'ibl.hooks'
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_tab_indent_level)
    end,
  },
}
