return {
  {
    -- For `plugins/markview.lua` users.
    'OXY2DEV/markview.nvim',
    lazy = false,

    -- For `nvim-treesitter` users.
    priority = 49,

    -- For blink.cmp's completion
    dependencies = {
      'saghen/blink.cmp',
    },

    opts = {
      preview = {
        enable = true,
        enable_hybrid_mode = true,
        icon_provider = 'devicons', -- "mini" or "devicons"
        raw_previews = {
          markdown = { 'headings' }, -- ← 这是关键配置
          -- 你也可以加上其他元素，如 "tables", "images" 等（如果支持）
        },

        modes = { 'i', 'n', 'no', 'c' },
        hybrid_modes = { 'i' },
        linewise_hybrid_mode = true,
      },
      markdown = {
        enable = true,
        -- 启用 hybrid 模式（必须）
      },
    },
  },
}
