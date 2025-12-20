-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
    },
    lazy = false, -- neo-tree will lazily load itself
    cmd = 'Neotree',
    keys = {
      { '\\', ':Neotree toggle reveal float<CR>', desc = 'NeoTree reveal', silent = true },
      { '|', ':Neotree toggle float source=buffers<CR>', desc = 'NeoTree reveal buffers', silent = true },
    },
    config = function()
      vim.api.nvim_set_hl(0, 'NeoTreeIndent', { fg = '#F8F8F8' })

      require('neo-tree').setup {
        default_component_configs = {
          indent = {
            with_markers = true,
            indent_marker = '┃',
            last_indent_marker = '┗',
            indent_size = 2,
            highlight = 'NeoTreeIndent',
          },
        },
        window = {
          position = 'left',
          width = 0.25,
        },
        filesystem = {
          filtered_items = {
            visible = true,
            show_hidden_count = true,
            hide_dotfiles = true,
          },
        },
      }
    end,
  },
}
