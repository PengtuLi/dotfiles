return {
  'stevearc/aerial.nvim',
  event = 'VeryLazy',
  opts = {},
  -- Optional dependencies
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require('aerial').setup {
      -- optionally use on_attach to set keymaps when aerial has attached to a buffer
      on_attach = function(bufnr)
        -- Jump forwards/backwards with '{' and '}'
        vim.keymap.set('n', '<leader>p', '<cmd>AerialPrev<CR>', { buffer = bufnr, desc = 'AerialPrev' })
        vim.keymap.set('n', '<leader>n', '<cmd>AerialNext<CR>', { buffer = bufnr, desc = 'AerialNext' })
      end,
      attach_mode = 'global',
      layout = {
        default_direction = 'right',
        -- Determines where the aerial window will be opened
        --   edge   - open aerial at the far right/left of the editor
        --   window - open aerial to the right/left of the current window
        -- placement = 'window',
      },
    }
    -- You probably also want to set a keymap to toggle aerial
    vim.keymap.set('n', '|', '<cmd>AerialToggle!<CR>')
    vim.keymap.set('n', '<leader>sO', require('aerial').fzf_lua_picker, { desc = 'LSP Document Symbols (aerial)' })
  end,
}
