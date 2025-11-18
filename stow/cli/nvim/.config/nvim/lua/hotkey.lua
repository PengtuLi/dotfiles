--  [[ keymap ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- 将 s 和 S 映射为原来的 r 和 R 功能
-- vim.keymap.set('n', 'r', 's', { expr = false, desc = 'substitute' })
-- vim.keymap.set('n', 'R', 'S', { expr = false, desc = 'substitute line' })
-- vim.keymap.set('n', 's', '<Nop>')
-- vim.keymap.set('n', 's', '<Nop>')
vim.keymap.set('n', 's', 's') -- in case of unactivated
-- vim.keymap.set('', '<Plug>CustomS', '') -- 占位用，不冲突
-- vim.keymap.set('n', 's', 'v:count || mode() == "n" ? "<Plug>CustomS" : "<Nop>"', { expr = true, silent = true })
-- vim.keymap.set('n', 'sa', ':echo "sa 被触发"<CR>')
-- vim.keymap.set('n', 'sA', ':echo "sA 被触发"<CR>')

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- 映射 <Leader> + Enter 为 :wq（保存并退出）
vim.keymap.set('n', '<Leader><CR>', '<Cmd>qa<CR>', { desc = 'Save and quit' })

vim.keymap.set('n', '<leader>bd', ':bd<CR>', { desc = '[d]elete current buffer' })

-- window resize
local function initiate_resize_mode()
  -- 设置超时时间 (毫秒)
  local timeout = 1000
  local resize_timer = vim.uv.new_timer() -- Neovim 0.10+ 使用 vim.uv，旧版用 vim.loop

  -- 定义清理函数：移除临时按键，关闭计时器
  local function clear_resize_maps()
    if resize_timer then
      resize_timer:stop()
      resize_timer:close()
      resize_timer = nil
    end
    -- 使用 pcall 防止按键已经被移除时报错
    pcall(vim.keymap.del, 'n', 'h')
    pcall(vim.keymap.del, 'n', 'j')
    pcall(vim.keymap.del, 'n', 'k')
    pcall(vim.keymap.del, 'n', 'l')
  end

  -- 重置计时器的辅助函数
  local function reset_timer()
    resize_timer:stop()
    resize_timer:start(timeout, 0, vim.schedule_wrap(clear_resize_maps))
  end

  local map_opts = { noremap = true, silent = true }

  vim.keymap.set('n', 'h', function()
    vim.cmd 'vertical resize -3'
    reset_timer()
  end, map_opts)

  vim.keymap.set('n', 'l', function()
    vim.cmd 'vertical resize +3'
    reset_timer()
  end, map_opts)

  vim.keymap.set('n', 'j', function()
    vim.cmd 'resize -3'
    reset_timer()
  end, map_opts)

  vim.keymap.set('n', 'k', function()
    vim.cmd 'resize +3'
    reset_timer()
  end, map_opts)

  -- 启动第一次计时
  reset_timer()
end

vim.keymap.set('n', '<Leader>h', function()
  initiate_resize_mode()
  vim.cmd 'vertical resize -3' -- 加上括号
end, { noremap = true, silent = true, desc = 'vertical resize -3' })
vim.keymap.set('n', '<Leader>l', function()
  initiate_resize_mode()
  vim.cmd 'vertical resize +3' -- 加上括号
end, { noremap = true, silent = true, desc = 'vertical resize +3' })
vim.keymap.set('n', '<Leader>j', function()
  initiate_resize_mode()
  vim.cmd 'resize +3' -- 加上括号
end, { noremap = true, silent = true, desc = 'horizontal resize +3' })
vim.keymap.set('n', '<Leader>k', function()
  initiate_resize_mode()
  vim.cmd 'resize -3' -- 加上括号
end, { noremap = true, silent = true, desc = 'horizontal resize -3' })

-- treesitter tree
vim.keymap.set('n', '<leader>i', function()
  vim.treesitter.inspect_tree()
  vim.api.nvim_input 'I'
end, { desc = '[i]nspect treesitter tree' })

vim.keymap.set("n", "<leader>I", vim.show_pos, { desc = "[I]nspect Pos" })
