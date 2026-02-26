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

-- cursor for theme
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    vim.api.nvim_set_hl(0, 'Cursor', { bg = '#2F81F7' })
    vim.api.nvim_set_hl(0, 'lCursor', { bg = '#2F81F7' })
    vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#2d3a4d' })
    -- window separator
    vim.api.nvim_set_hl(0, 'WinSeparator', { fg = '#6b7394', bold = true })
  end,
})
