return {
  'ibhagwan/fzf-lua',
  -- optional for icon support
  dependencies = { 'nvim-tree/nvim-web-devicons' },

  -- flash integration
  config = function()
    local fzf_lua = require 'fzf-lua'
    local actions = fzf_lua.actions

    fzf_lua.setup {
      buffers = {
        prompt = 'Buffers❯ ',
        sort_lastused = true, -- sort buffers() by last used
        show_unloaded = true, -- show unloaded buffers
        cwd_only = false, -- buffers for the cwd only
        actions = {
          -- actions inherit from 'actions.files' and merge
          -- by supplying a table of functions we're telling
          -- fzf-lua to not close the fzf window, this way we
          -- can resume the buffers picker on the same window
          -- eliminating an otherwise unaesthetic win "flash"
          ['ctrl-x'] = { fn = actions.buf_del, reload = true },
        },
      },
    }

    vim.keymap.set('n', '<leader>sh', fzf_lua.help_tags, { desc = 'search [h]elp' })
    vim.keymap.set('n', '<leader>sc', fzf_lua.awesome_colorschemes, { desc = 'search [c]olorschemes' })
    vim.keymap.set('n', '<leader>sk', fzf_lua.keymaps, { desc = 'search [k]eymaps' })
    vim.keymap.set('n', '<leader>sf', fzf_lua.files, { desc = 'search [f]iles' })
    vim.keymap.set('n', '<leader>s?', fzf_lua.builtin, { desc = 'search [?]help fzf-lua' })
    vim.keymap.set('n', '<leader>sd', fzf_lua.diagnostics_document, { desc = 'search [d]iagnostics' })
    vim.keymap.set('n', '<leader>sD', fzf_lua.diagnostics_workspace, { desc = 'search [D]iagnostics (Workspace)' })
    vim.keymap.set('n', '<leader>sr', fzf_lua.resume, { desc = 'search [r]esume' }) -- live grep continue last search
    vim.keymap.set('n', '<leader>s.', fzf_lua.oldfiles, { desc = 'search Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', fzf_lua.buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>sg', fzf_lua.live_grep_native, { desc = 'search by [g]rep' })
    vim.keymap.set('n', '<leader>sw', fzf_lua.grep_cword, { desc = 'search current [w]ord' })
    vim.keymap.set('n', '<leader>/', fzf_lua.blines, { desc = '[/] Fuzzily search in current buffer' })
    vim.keymap.set('n', '<leader>s/', fzf_lua.lines, { desc = 'search [/] in Open Files' })

    -- 搜索你的 Neovim 配置文件
    vim.keymap.set('n', '<leader>sn', function()
      fzf_lua.files { cwd = vim.fn.stdpath 'config' }
    end, { desc = 'search [n]eovim files' })
  end,
}
