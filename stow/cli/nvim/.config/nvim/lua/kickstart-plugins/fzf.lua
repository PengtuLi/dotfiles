return {
  'ibhagwan/fzf-lua',
  event = 'VeryLazy',
  -- optional for icon support
  dependencies = { 'nvim-tree/nvim-web-devicons' },

  -- flash integration
  config = function()
    local fzf_lua = require 'fzf-lua'
    local actions = fzf_lua.actions

    fzf_lua.setup {
      winopts = {
        height = 0.9, -- window height
        width = 0.9, -- window width
        row = 0.50, -- window row position (0=top, 1=bottom)
        col = 0.50, -- window col position (0=left, 1=right)
        -- Backdrop opacity, 0 is fully opaque, 100 is fully transparent (i.e. disabled)
        backdrop = 100,
        preview = {},
      },
      keymap = {
        -- Below are the default binds, setting any value in these tables will override
        -- the defaults, to inherit from the defaults change [1] from `false` to `true`
        builtin = {
          false,
          ['<F1>'] = 'toggle-help',
          ['<F2>'] = 'toggle-fullscreen',
          ['<F4>'] = 'toggle-preview',
          ['<C-A-b>'] = 'preview-page-up',
          ['<C-A-f>'] = 'preview-page-down',
          ['<C-A-u>'] = 'preview-half-page-up',
          ['<C-A-d>'] = 'preview-half-page-down',
        },
        fzf = {
          false,
          -- fzf '--bind=' options
        },
        actions = {
          files = {
            false, -- uncomment to inherit all the below in your custom config
            -- Pickers inheriting these actions:
            --   files, git_files, git_status, grep, lsp, oldfiles, quickfix, loclist,
            --   tags, btags, args, buffers, tabs, lines, blines
            -- `file_edit_or_qf` opens a single selection or sends multiple selection to quickfix
            -- replace `enter` with `file_edit` to open all files/bufs whether single or multiple
            -- replace `enter` with `file_switch_or_edit` to attempt a switch in current tab first
            ['enter'] = FzfLua.actions.file_edit_or_qf,
            ['ctrl-s'] = FzfLua.actions.file_split,
            ['ctrl-v'] = FzfLua.actions.file_vsplit,
            ['ctrl-t'] = FzfLua.actions.file_tabedit,
            ['alt-q'] = FzfLua.actions.file_sel_to_qf,
            ['alt-Q'] = FzfLua.actions.file_sel_to_ll,
            ['alt-i'] = FzfLua.actions.toggle_ignore,
            ['alt-h'] = FzfLua.actions.toggle_hidden,
            -- ['alt-f'] = FzfLua.actions.toggle_follow,
          },
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
          fzf_opts = {},
        },
        document_symbols = {
          -- 只显示 symbol 部分，隐藏 [bufnr] filename:lnum:col 部分
          -- 这样缩进对齐问题就解决了
          fzf_opts = {
            ['--delimiter'] = '\t\t',
            ['--with-nth'] = '2..',
          },
        },
        workspace_symbols = {
          -- 默认显示 cwd 相对路径
          cwd = vim.fn.getcwd(),
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
