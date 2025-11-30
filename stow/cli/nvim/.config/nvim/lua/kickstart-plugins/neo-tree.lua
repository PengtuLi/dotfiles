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
      { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
      { '|', ':Neotree toggle source=buffers<CR>', desc = 'NeoTree reveal buffers', silent = true },
    },
    config = function()
      require('neo-tree').setup {
        window = {
          position = 'left',
          width = '25%',
        },
        filesystem = {
          filtered_items = {
            visible = true,
            show_hidden_count = true,
            hide_dotfiles = true,
          },
          window = {
            mappings = {
              ['\\'] = 'close_window',
            },
          },
        },
      }
    end,
  },
}
