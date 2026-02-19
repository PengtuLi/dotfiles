-- [[ Setting options ]]
vim.opt.cmdheight = 0
vim.opt.showmode = false
vim.opt.mouse = 'a'
vim.opt.undofile = true
vim.g.editorconfig = true
vim.opt.signcolumn = 'yes'
vim.opt.laststatus = 3
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.o.confirm = true
vim.opt.termguicolors = true
-- vim.opt.conceallevel = 2
-- Save view (fold, scroll, cursor) on jump
vim.opt.jumpoptions = 'view'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.breakindent = true
vim.opt.shiftround = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- vim.opt.virtualedit = "block"
vim.opt.inccommand = 'split'
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.splitkeep = 'screen'
-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
-- vim.opt.fillchars = {
--   foldopen = "",
--   foldclose = "",
--   fold = " ",
--   foldsep = " ",
--   diff = "╱",
--   eob = " ",
-- }
-- vim.opt.foldtext = ""
vim.wo.foldlevel = 99
vim.opt.scrolloff = 4
vim.opt.smoothscroll = true
vim.opt.sidescrolloff = 8
-- 设置会话保存内容（增强 auto-session 体验）
vim.o.sessionoptions = 'buffers,curdir,folds,help,winsize,localoptions'
-- 拼写检查
vim.opt.spell = false
vim.opt.spelllang = 'en_us,cjk'
-- auto read file change outside nvim
vim.o.autoread = true

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
vim.keymap.set({ 'n' }, 'x', [["_x]]) -- v + x means clip
vim.keymap.set({ 'n', 'v' }, 'X', [["_X]])
vim.keymap.set({ 'n', 'v' }, 'c', [["_c]])
vim.keymap.set({ 'n', 'v' }, 'C', [["_C]])
