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

    function toggle_fzf_lua()
      local harpoon = require 'harpoon'
      local fzf = require 'fzf-lua'
      local list = harpoon:list()
      local items = {}
      for i = 1, list:length() do
        local item = list:get(i)
        if item and item.value and item.value ~= '' then
          table.insert(items, string.format('%d: %s', i, item.value)) -- skip empty lines if deletion didn't functional properly
        end
      end
      fzf.fzf_exec(items, {
        prompt = 'Harpoon Files> ',
        fzf_opts = {
          ['--preview'] = "bat --style=numbers --color=always $(echo {} | sed 's/^\\([0-9]\\+\\): //')",
        },
        actions = {
          ['default'] = function(selected)
            local idx = tonumber(selected[1]:match '^(%d+):')
            if idx then
              list:select(idx)
            end
          end,
          ['ctrl-x'] = function(selected)
            local idx = tonumber(selected[1]:match '^(%d+):')
            if idx then
              local item = list:get(idx)
              list:remove(item)
            end
          end,
          ['ctrl-s'] = function(selected)
            local idx = tonumber(selected[1]:match '^(%d+):')
            if idx then
              local item = list:get(idx)
              if item and item.value then
                vim.cmd('split ' .. vim.fn.fnameescape(item.value))
              end
            end
          end,
          ['ctrl-v'] = function(selected)
            local idx = tonumber(selected[1]:match '^(%d+):')
            if idx then
              local item = list:get(idx)
              if item and item.value then
                vim.cmd('vsplit ' .. vim.fn.fnameescape(item.value))
              end
            end
          end,
        },
      })
    end

    -- 将 <C-e> 键映射到新的 fzf-lua 函数
    vim.keymap.set('n', '<C-e>', function()
      toggle_fzf_lua()
    end, { desc = 'Open harpoon window with fzf-lua' })

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '<BS>', function()
      harpoon:list():prev()
    end, { desc = 'prev harpoon' })
    vim.keymap.set('n', '<CR>', function()
      harpoon:list():next()
    end, { desc = 'next harpoon' })

    vim.keymap.set('n', '<leader>ba', function()
      harpoon:list():add()
    end, { desc = 'buffer [a]dd to harpoon' })

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
