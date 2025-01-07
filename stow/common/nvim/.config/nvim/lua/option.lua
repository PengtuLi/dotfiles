-- [[ Setting options ]]
-- See `:help vim.opt`
-- hide Cmd if not used
vim.opt.cmdheight = 0

-- vim.g.editorconfig = true

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- 使用 OSC 52 协议实现远程剪贴板（如 SSH）
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy '+',
    ['*'] = require('vim.ui.clipboard.osc52').copy '*',
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste '+',
    ['*'] = require('vim.ui.clipboard.osc52').paste '*',
  },
}

-- no harm to +* register from dxc
vim.keymap.set({ 'n', 'v' }, 'd', [["_d]])
vim.keymap.set({ 'n', 'v' }, 'D', [["_D]])
vim.keymap.set({ 'n', 'v' }, 'x', [["_x]])
vim.keymap.set({ 'n', 'v' }, 'X', [["_X]])
vim.keymap.set({ 'n', 'v' }, 'c', [["_c]])
vim.keymap.set({ 'n', 'v' }, 'C', [["_C]])

-- Enable break indent
-- 当一行文本因窗口宽度不足而自动换行显示时，后续的折行会保持与原行相同的缩进。
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
-- 显示不可见字符
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 5

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- 设置会话保存内容（增强 auto-session 体验）
vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

-- 拼写检查
vim.opt.spell = false
vim.opt.spelllang = 'en_us,cjk' -- 支持中英文（cjk 可选）
