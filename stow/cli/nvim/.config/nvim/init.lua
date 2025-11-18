--     - :help lua-guide
--     - :Tutor

-- must load first before other plugin
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- [[ Basic Option ]]
require 'option'

-- [[ AutoCmd ]]
require 'autocmd'

-- [[ Basic Keymaps ]]
require 'hotkey'

-- [[ Install `lazy.nvim` plugin manager ]]
require 'lazy-bootstrap'

-- [[ Configure and install plugins ]]
require 'lazy-plugins'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
