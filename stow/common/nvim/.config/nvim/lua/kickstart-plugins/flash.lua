return {
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    ---@type Flash.Config
    opts = {
      modes = {
        search = {
          enabled = true, -- 启用增强搜索
        },
      },
    },
    keys = {
      {
        'q',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash',
      },
      {
        -- 从当前节点语法树往上
        'Q',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash Treesitter',
      },
      {
        -- 支持二次动作 + 自动恢复位置
        -- you'll be back in the original window / position
        'r',
        mode = { 'o' },
        function()
          require('flash').remote()
        end,
        desc = 'Remote Flash',
      },
      {
        -- 遍历所有语法树节点
        'R',
        mode = { 'n', 'o', 'x' },
        function()
          require('flash').treesitter_search()
        end,
        desc = 'Treesitter Search',
      },
      -- '<C-r>',
      --   {
      --   mode = { 'c' },
      --   function()
      --     require('flash').toggle()
      --   end,
      --   desc = 'Toggle Flash Search',
      -- },

      -- NOTE: with repeated action of fFtT

      -- Treesitter incremental selection
      vim.keymap.set({ 'n', 'x', 'o' }, '<C-q>', function()
        require('flash').treesitter {
          actions = {
            ['<C-q>'] = 'next',
            ['<BS>'] = 'prev',
          },
        }
      end, { desc = 'Treesitter incremental selection' }),
    },
  },
}
