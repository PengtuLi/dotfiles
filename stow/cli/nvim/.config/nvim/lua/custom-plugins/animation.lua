return {
  {
    'sphamba/smear-cursor.nvim',
    event = 'VeryLazy',
    opts = { -- Default  Range
      stiffness = 0.8, -- 0.6      [0, 1]
      trailing_stiffness = 0.6, -- 0.45     [0, 1]
      stiffness_insert_mode = 0.7, -- 0.5      [0, 1]
      trailing_stiffness_insert_mode = 0.7, -- 0.5      [0, 1]
      damping = 0.95, -- 0.85     [0, 1]
      damping_insert_mode = 0.95, -- 0.9      [0, 1]
      distance_stop_animating = 0.5, -- 0.1      > 0
    },
  },
  -- {
  --   'karb94/neoscroll.nvim',
  --   opts = {
  --     duration_multiplier = 1,
  --     easing = 'quadratic',
  --   },
  -- },
  -- {
  --   'LuxVim/nvim-luxmotion',
  --   config = function()
  --     require('luxmotion').setup {
  --       cursor = {
  --         duration = 50,
  --         easing = 'ease-out',
  --         enabled = true,
  --       },
  --       scroll = {
  --         duration = 100,
  --         easing = 'ease-in-out',
  --         enabled = true,
  --       },
  --       performance = { enabled = true },
  --       keymaps = {
  --         cursor = true,
  --         scroll = true,
  --       },
  --     }
  --   end,
  -- },
}
