-- 使用 lazy.nvim 的推荐配置
return {
  'j-hui/fidget.nvim',
  event = 'VeryLazy',
  version = '*',
  opts = {
    notification = {
      override_vim_notify = false, -- Automatically override vim.notify() with Fidget
      -- How to configure notification groups when instantiated
      -- configs = { default = require('fidget.notification').default_config },
      -- Conditionally redirect notifications to another backend
      -- redirect = function(msg, level, opts)
      --   if opts and opts.on_open then
      --     return require('fidget.integration.nvim-notify').delegate(msg, level, opts)
      --   end
      -- end,
    },
    progress = {
      display = {},
    },
  },

  -- 可选：配置键映射
  config = function(_, opts)
    local fidget = require 'fidget'
    fidget.setup(opts)
    -- default
    -- vim.notify = require 'notify'
  end,
}
