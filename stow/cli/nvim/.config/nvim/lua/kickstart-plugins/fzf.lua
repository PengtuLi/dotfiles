return {
  'ibhagwan/fzf-lua',
  -- optional for icon support
  dependencies = { 'nvim-tree/nvim-web-devicons' },

  -- flash integration
  config = function()
    local fzf_lua = require 'fzf-lua'
    local actions = fzf_lua.actions

    fzf_lua.setup {
      keymap = {
        -- Below are the default binds, setting any value in these tables will override
        -- the defaults, to inherit from the defaults change [1] from `false` to `true`
        builtin = {
          -- neovim `:tmap` mappings for the fzf win
          -- true,        -- uncomment to inherit all the below in your custom config
          ['<F1>'] = 'toggle-help',
          ['<F2>'] = 'toggle-fullscreen',
          -- Only valid with the 'builtin' previewer
          ['<F3>'] = 'toggle-preview-wrap',
          ['<F4>'] = 'toggle-preview',
          -- Rotate preview clockwise/counter-clockwise
          ['<F5>'] = 'toggle-preview-cw',
          -- Preview toggle behavior default/extend
          ['<F6>'] = 'toggle-preview-behavior',
          -- `ts-ctx` binds require `nvim-treesitter-context`
          ['<F7>'] = 'toggle-preview-ts-ctx',
          ['<F8>'] = 'preview-ts-ctx-dec',
          ['<F9>'] = 'preview-ts-ctx-inc',
        },
        fzf = {
          -- fzf '--bind=' options
          -- true,        -- uncomment to inherit all the below in your custom config
          ['ctrl-d'] = 'half-page-down',
          ['ctrl-u'] = 'half-page-up',
          ['alt-a'] = 'toggle-all',
          ['alt-g'] = 'first',
          ['alt-G'] = 'last',
          -- Only valid with fzf previewers (bat/cat/git/etc)
          ['f3'] = 'toggle-preview-wrap',
          ['f4'] = 'toggle-preview',
          ['shift-down'] = 'preview-page-down',
          ['shift-up'] = 'preview-page-up',
        },
      },
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
      lsp = {
        symbols = {
          fzf_opts = {
            ['--delimiter'] = ' ',
            -- 隐藏第1个字段（即隐藏 line:col: 这一坨东西），显示第2个字段及之后的内容
            ['--with-nth'] = '3..',
          },
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
