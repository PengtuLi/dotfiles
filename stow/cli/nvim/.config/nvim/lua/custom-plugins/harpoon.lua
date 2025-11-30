return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  event = 'VeryLazy',
  opts = function()
    local harpoon = require 'harpoon'
    -- REQUIRED
    harpoon:setup()

    local harpoon_extensions = require 'harpoon.extensions'
    harpoon:extend(harpoon_extensions.builtins.highlight_current_file())
    harpoon:extend(harpoon_extensions.builtins.navigate_with_number())

    local function toggle_fzf_lua(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        -- item.value 通常是文件的完整路径
        table.insert(file_paths, item.value)
      end

      -- 调用 fzf-lua 的 files picker
      -- 我们传递一个自定义的 source，它是一个包含文件路径的列表
      require('fzf-lua').fzf_exec(file_paths, {
        -- 可选：自定义提示符
        prompt = 'Harpoon Files> ',
        header = 'Ctrl-v: vsplit | Ctrl-s: split | Enter: open',
        -- 可选：自定义回调函数来处理用户选择
        -- 默认行为是打开选中的文件
        actions = {
          -- 默认的 <CR> (回车) 动作就是打开文件
          -- 你可以添加其他快捷键，例如在分割窗口中打开等
          ['default'] = function(selected)
            if selected and selected[1] then
              -- 使用 :edit 命令打开选中的文件
              vim.cmd('edit ' .. selected[1])
            end
          end,
          -- 示例：在垂直分割窗口中打开 (Ctrl+v)
          ['ctrl-v'] = function(selected)
            if selected and selected[1] then
              vim.cmd('vsplit ' .. selected[1])
            end
          end,
          ['ctrl-s'] = function(selected)
            if selected and selected[1] then
              vim.cmd('split ' .. selected[1])
            end
          end,
          -- ['ctrl-x'] = function(selected)
          --   if selected and selected[1] then
          --     -- 从字符串中提取索引
          --     local selected_text = selected[1]
          --     local index = tonumber(string.match(selected_text, '%[(%d+)%]'))
          --     if index then
          --       harpoon:list():remove(index)
          --       print('Removed item ' .. index .. ' from harpoon')
          --     end
          --   end
          -- end,
        },
        -- 其他 fzf-lua 选项...
        -- 例如，你可以设置预览命令等
        -- previewer = "builtin", -- 或 "bat", "cat", "head", 等
      })
    end

    -- 将 <C-e> 键映射到新的 fzf-lua 函数
    vim.keymap.set('n', '<C-e>', function()
      toggle_fzf_lua(harpoon:list())
    end, { desc = 'Open harpoon window with fzf-lua' })

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '<S-Tab>', function()
      harpoon:list():prev()
    end, { desc = 'prev harpoon' })
    vim.keymap.set('n', '<Tab>', function()
      harpoon:list():next()
    end, { desc = 'next harpoon' })

    vim.keymap.set('n', '<leader>ba', function()
      harpoon:list():add()
    end, { desc = 'buffer [a]dd to harpoon' })

    vim.keymap.set('n', '<C-S-e>', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'harpoon menu' })

    -- vim.keymap.set('n', '<C-h>', function()
    --   harpoon:list():select(1)
    -- end)
    -- vim.keymap.set('n', '<C-t>', function()
    --   harpoon:list():select(2)
    -- end)
    -- vim.keymap.set('n', '<C-n>', function()
    --   harpoon:list():select(3)
    -- end)
    -- vim.keymap.set('n', '<C-s>', function()
    --   harpoon:list():select(4)
    -- end)
  end,
}
