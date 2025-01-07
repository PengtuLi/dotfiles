return { -- TODO fix key
  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'latex', 'query', 'vim', 'vimdoc', 'python' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as
        -- Ruby) for indent rules. If you are experiencing weird indenting
        -- issues, add the language to the list of
        -- additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true },
    },
    config = function(_)
      -- Fold settings using Treesitter
      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo.foldlevel = 99
    end,
  },

  { --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    'nvim-treesitter/nvim-treesitter-context',
    after = 'nvim-treesitter/nvim-treesitter',
    opts = {
      enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
      multiwindow = false, -- Enable multiwindow support.
      max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
      min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
      line_numbers = true,
      multiline_threshold = 20, -- Maximum number of lines to show for a single context
      trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
      -- Separator between context and content. Should be a single character string, like '-'.
      -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
      separator = nil,
      zindex = 20, -- The Z-index of the context window
      on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    },

    -- 设置高亮
    vim.api.nvim_set_hl(0, 'TreesitterContextBottom', {
      underline = true,
      sp = 'orange',
    }),
    -- toggle
    vim.keymap.set('n', '<leader>tt', '<cmd>TSContext toggle<cr>', { desc = 'toggle [t]reesitter context' }),
    -- context jump
    vim.keymap.set('n', '[c', function()
      require('treesitter-context').go_to_context(vim.v.count1)
    end, { silent = true, desc = 'Jumping to previous treesitter [c]ontext' }),
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup {
        textobjects = {
          select = {
            enable = true,
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['af'] = { query = '@function.outer', desc = 'Select outer part of a function region' },
              ['if'] = { query = '@function.inner', desc = 'Select inner part of a function region' },
              ['ac'] = { query = '@class.outer', desc = 'Select outer part of a class region' },
              ['ic'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
              -- You can also use captures from other query groups like `locals.scm`
              ['as'] = { query = '@local.scope', query_group = 'locals', desc = 'Select language scope' },
            },
            -- You can choose the select mode (default is charwise 'v')
            -- Can also be a function which gets passed a table with the keys
            selection_modes = {
              ['@function.outer'] = 'V', -- linewise
              ['@class.outer'] = '<c-v>', -- blockwise
            },
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding or succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in
            include_surrounding_whitespace = false,
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              [']m'] = '@function.outer',
              [']['] = { query = '@class.outer', desc = 'Next Class start' },
              -- [']o'] = '@loop.*', -- 支持正则匹配多个类型
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']]'] = { query = '@class.outer', desc = 'Next Class end' },
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[['] = { query = '@class.outer', desc = 'Previous Class end' },
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[]'] = { query = '@class.outer', desc = 'Previous Class start' },
            },
          },
          -- lsp_interop = {
          --   enable = true,
          --   border = 'none',
          --   floating_preview_opts = {},
          --   peek_definition_code = {
          --     ['grf'] = '@function.outer',
          --     ['grF'] = '@class.outer',
          --   },
          -- },
        },
      }
    end,
  },
}
