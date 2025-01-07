require('lazy').setup({
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).

  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  require 'kickstart-plugins.gitsigns',
  require 'kickstart-plugins.which-key',
  -- require 'kickstart-plugins.telescope',
  require 'kickstart-plugins.fzf',
  require 'kickstart-plugins.theme',
  require 'kickstart-plugins.lsp-config',
  require 'kickstart-plugins.conform',
  require 'kickstart-plugins.blink-cmp',
  require 'kickstart-plugins.luasnip',
  require 'kickstart-plugins.mini',
  require 'kickstart-plugins.treesitter',
  require 'kickstart-plugins.autopairs',
  require 'kickstart-plugins.indent_line',
  require 'kickstart-plugins.neo-tree',
  require 'kickstart-plugins.lint',
  require 'kickstart-plugins.lualine',
  require 'kickstart-plugins.flash',

  -- plugins import
  -- require 'kickstart-plugins.debug',
  -- require neogit
  require 'custom-plugins.auto-session',
  require 'custom-plugins.todo-comments',
  -- require 'custom-plugins.bufferline',
  require 'custom-plugins.vim-tmux-navigator',
  require 'custom-plugins.duck',
  -- require 'custom-plugins.animation',
  -- require 'custom-plugins.markview',
  -- require 'custom-plugins.peek',
  require 'custom-plugins.notify',
  require 'custom-plugins.hardtime',
  -- require 'custom-plugins.lazygit',
  require 'custom-plugins.harpoon',

  -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
  -- Or use telescope!
  -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
  -- you can continue same window with `<space>sr` which resumes last telescope search
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
