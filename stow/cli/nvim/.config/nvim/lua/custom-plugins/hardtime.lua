return {
  'm4xshen/hardtime.nvim',
  event="VeryLazy",
  dependencies = { 'MunifTanjim/nui.nvim' },
  opts = {
    disable_mouse = false,
    disabled_keys = {
      ['<Up>'] = false,
      ['<Down>'] = false,
      ['<Left>'] = false,
      ['<Right>'] = false,
    },
    restricted_keys = {
      ['+'] = false,
    },
  },
}
