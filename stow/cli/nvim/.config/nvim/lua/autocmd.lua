vim.api.nvim_create_autocmd('FocusGained', {
  callback = function()
    vim.cmd 'checktime' -- 检查时，autoread 会控制是否自动加载
  end,
})

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
