return {
  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local todo_comments = require 'todo-comments'
      local fzf_lua = require 'fzf-lua'
      todo_comments.setup {
        keywords = {
          FIX = {
            icon = ' ', -- icon used for the sign, and in search results
            color = 'error', -- can be a hex color, or a named color (see below)
            alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' }, -- a set of other keywords that all map to this FIX keywords
          },
          TODO = { icon = ' ', color = 'info', alt = { 'TODOS' } },
          HACK = { icon = ' ', color = 'warning' },
          WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
          PERF = { icon = ' ', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
          NOTE = { icon = ' ', color = 'hint', alt = { 'INFO' } },
          TEST = { icon = '⏲ ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
        },
        signs = true,
        vim.keymap.set('n', '<leader>D', '<CMD>TodoQuickFix<CR>', { desc = 'Open to[D]o-comment Quickfix list' }),
        vim.keymap.set('n', '<leader>st', '<CMD>TodoFzfLua<CR>', { desc = 'search [t]odos' }),
      }
    end,
  },
}
