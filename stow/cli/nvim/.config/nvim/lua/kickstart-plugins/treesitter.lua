return {
  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,
    config = function()
      local ts_group = vim.api.nvim_create_augroup('nvim_ts', { clear = true })
      local ensure_installed = {
        'bash',
        'c',
        'diff',
        'html',
        'javascript',
        'jsdoc',
        'json',
        'lua',
        'luadoc',
        'luap',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'regex',
        'toml',
        'vim',
        'vimdoc',
        'yaml',
      }
      require('nvim-treesitter').install(ensure_installed)

      -- Autocommands

      -- TS parser
      vim.api.nvim_create_autocmd('FileType', {
        pattern = ensure_installed,
        callback = function()
          vim.treesitter.start()
        end,
        group = ts_group,
      })

      -- TS fold cal
      vim.api.nvim_create_autocmd('FileType', {
        pattern = ensure_installed,
        callback = function()
          vim.wo.foldmethod = 'expr'
          vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        end,
        group = ts_group,
      })

      -- TS indent
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {},
        callback = function()
          vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
        end,
        group = ts_group,
      })

      -- Toggle mappings
      vim.keymap.set('n', '<leader>tth', function()
        if vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil then
          vim.treesitter.stop()
          vim.print 'Turned off treesitter highlighting...'
        else
          vim.treesitter.start()
          vim.print 'Turned on treesitter highlighting...'
        end
      end, { noremap = true, desc = 'Toggle treesitter [h]ighlighting' })

      vim.keymap.set('n', '<leader>tti', function()
        local current_indentexpr = vim.bo.indentexpr
        local current_buffer = vim.api.nvim_get_current_buf()
        if current_indentexpr ~= "v:lua.require('nvim-treesitter').indentexpr()" then
          vim.b[current_buffer].rahlir_previous_indentexpr = current_indentexpr
          vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
          vim.print 'Turned on treesitter indent...'
        else
          local previous_indentexpr = vim.b[current_buffer].rahlir_previous_indentexpr
          if previous_indentexpr == nil then
            previous_indentexpr = ''
          end
          vim.bo.indentexpr = previous_indentexpr
          vim.print 'Turned off treesitter indent...'
        end
      end, { noremap = true, desc = 'Toggle treesitter [i]ndent' })
    end,
  },
  { --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    'nvim-treesitter/nvim-treesitter-context',
    event = 'VeryLazy',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    opts = {
      enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
      multiwindow = false, -- Enable multiwindow support.
      max_lines = 10, -- How many lines the window should span. Values <= 0 mean no limit.
      min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
      line_numbers = true,
      multiline_threshold = 1, -- Maximum number of lines to show for a single context
      trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      mode = 'topline', -- Line used to calculate context. Choices: 'cursor', 'topline'
      -- Separator between context and content. Should be a single character string, like '-'.
      -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
      separator = nil,
      zindex = 20, -- The Z-index of the context window
      on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    },
    config = function()
      -- 设置高亮
      vim.api.nvim_set_hl(0, 'TreesitterContextBottom', {
        underline = true,
        sp = 'grey',
      })
      -- toggle
      vim.keymap.set('n', '<leader>ttc', '<cmd>TSContext toggle<cr>', { desc = 'toggle treesitter [c]ontext' })
      -- context jump
      vim.keymap.set('n', '[C', function()
        require('treesitter-context').go_to_context(vim.v.count1)
      end, { silent = true, desc = 'Jumping to previous treesitter [C]ontext' })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    event = 'VeryLazy',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    config = function()
      require('nvim-treesitter-textobjects').setup {
        textobjects = {
          select = {
            enable = true,
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,
            keymaps = {},
            -- You can choose the select mode (default is charwise 'v')
            selection_modes = {
              ['@parameter.outer'] = 'v', -- charwise
              ['@function.outer'] = 'V', -- linewise
              ['@class.outer'] = '<c-v>', -- blockwise
            },
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding or succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in
            include_surrounding_whitespace = false,
          },
          move = {
            set_jumps = true, -- jmpplist with C-i/o
          },
        },
      }

      -- Select keymappings
      vim.keymap.set({ 'x', 'o' }, 'af', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
      end, { desc = 'Function outer region' })
      vim.keymap.set({ 'x', 'o' }, 'if', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
      end, { desc = 'Function inner region' })

      vim.keymap.set({ 'x', 'o' }, 'ac', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@class.outer', 'textobjects')
      end, { desc = 'Class outer region' })
      vim.keymap.set({ 'x', 'o' }, 'ic', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@class.inner', 'textobjects')
      end, { desc = 'Class inner region' })

      vim.keymap.set({ 'x', 'o' }, 'aa', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@parameter.outer', 'textobjects')
      end, { desc = 'Parameter outer region' })
      vim.keymap.set({ 'x', 'o' }, 'ia', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@parameter.inner', 'textobjects')
      end, { desc = 'Parameter inner region' })

      vim.keymap.set({ 'x', 'o' }, 'ak', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@block.outer', 'textobjects')
      end, { desc = 'Block outer region' })
      vim.keymap.set({ 'x', 'o' }, 'ik', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@block.inner', 'textobjects')
      end, { desc = 'Block inner region' })

      vim.keymap.set({ 'x', 'o' }, 'ai', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@conditional.outer', 'textobjects')
      end, { desc = 'Conditional outer region' })
      vim.keymap.set({ 'x', 'o' }, 'ii', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@conditional.inner', 'textobjects')
      end, { desc = 'Conditional inner region' })

      vim.keymap.set({ 'x', 'o' }, 'al', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@loop.outer', 'textobjects')
      end, { desc = 'Loop outer region' })
      vim.keymap.set({ 'x', 'o' }, 'il', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@loop.inner', 'textobjects')
      end, { desc = 'Loop inner region' })

      vim.keymap.set({ 'x', 'o' }, 'a=', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@assignment.outer', 'textobjects')
      end, { desc = 'Assignment outer region' })
      vim.keymap.set({ 'x', 'o' }, 'i=', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@assignment.inner', 'textobjects')
      end, { desc = 'Assignment inner region' })

      -- Move keymappings
      vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
        require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
      end, { desc = 'Next function' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
        require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer', 'textobjects')
      end, { desc = 'End of next function' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
        require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')
      end, { desc = 'Previous function' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
        require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer', 'textobjects')
      end, { desc = 'End of previous function' })

      vim.keymap.set({ 'n', 'x', 'o' }, ']]', function()
        require('nvim-treesitter-textobjects.move').goto_next_start('@class.outer', 'textobjects')
      end, { desc = 'Next class' })
      vim.keymap.set({ 'n', 'x', 'o' }, '][', function()
        require('nvim-treesitter-textobjects.move').goto_next_end('@class.outer', 'textobjects')
      end, { desc = 'End of next class' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[[', function()
        require('nvim-treesitter-textobjects.move').goto_previous_start('@class.outer', 'textobjects')
      end, { desc = 'Previous class' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[]', function()
        require('nvim-treesitter-textobjects.move').goto_previous_end('@class.outer', 'textobjects')
      end, { desc = 'End of previous class' })

      vim.keymap.set({ 'n', 'x', 'o' }, ']k', function()
        require('nvim-treesitter-textobjects.move').goto_next_start('@block.outer', 'textobjects')
      end, { desc = 'Next block' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']K', function()
        require('nvim-treesitter-textobjects.move').goto_next_end('@block.outer', 'textobjects')
      end, { desc = 'End of next block' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[k', function()
        require('nvim-treesitter-textobjects.move').goto_previous_start('@block.outer', 'textobjects')
      end, { desc = 'Previous block' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[K', function()
        require('nvim-treesitter-textobjects.move').goto_previous_end('@block.outer', 'textobjects')
      end, { desc = 'End of previous block' })

      vim.keymap.set({ 'n', 'x', 'o' }, ']a', function()
        require('nvim-treesitter-textobjects.move').goto_next_start('@parameter.outer', 'textobjects')
      end, { desc = 'Next parameter' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']A', function()
        require('nvim-treesitter-textobjects.move').goto_next_end('@parameter.outer', 'textobjects')
      end, { desc = 'End of next parameter' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[a', function()
        require('nvim-treesitter-textobjects.move').goto_previous_start('@parameter.outer', 'textobjects')
      end, { desc = 'Previous parameter' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[A', function()
        require('nvim-treesitter-textobjects.move').goto_previous_end('@parameter.outer', 'textobjects')
      end, { desc = 'End of previous parameter' })
    end,
  },
}
