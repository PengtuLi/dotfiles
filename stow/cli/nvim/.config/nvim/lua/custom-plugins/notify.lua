-- ~/.config/nvim/lua/config/plugins/notify.lua

return {
  'rcarriga/nvim-notify',
  opts = {
    render = 'wrapped-compact',
    top_down = false,
    max_width = function()
      local win_width = vim.fn.winwidth(0)
      return math.floor(win_width / 2)
    end,
  },
  config = function(_, opts)
    require('notify').setup(opts)

    -- 24-bit colour
    vim.opt.termguicolors = true

    vim.notify = require 'notify'
  end,
}
