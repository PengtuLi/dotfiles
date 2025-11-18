-- LSP Plugins
return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
      { 'mason-org/mason-lspconfig.nvim' },
      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim' },
      -- Allows extra capabilities provided by blink.cmp
      { 'saghen/blink.cmp' },
    },
    config = function()
      vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#1e1e1e' })
      vim.api.nvim_set_hl(0, 'LspInlayHint', { bg = 'NONE', fg = '#5c5c5c' })

      --  This function gets run when an LSP attaches to a particular buffer.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- hover show document
          map('<C-s>', vim.lsp.buf.hover, '[s]how LSP hover info')

          -- Rename the variable under your cursor.
          map('grn', vim.lsp.buf.rename, '[r]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('gra', require('fzf-lua').lsp_code_actions, 'goto Code [a]ction', { 'n', 'x' })

          -- Find references for the word under your cursor.
          map('grr', require('fzf-lua').lsp_references, 'goto [r]eferences')

          -- Jump to the implementation of the word under your cursor.
          map('gri', require('fzf-lua').lsp_implementations, 'goto [i]mplementation')

          -- Jump to the definition of the word under your cursor.
          map('grd', require('fzf-lua').lsp_definitions, 'goto [d]efinition')

          -- Jump to the declaration of the word under your cursor.
          map('grD', require('fzf-lua').lsp_declarations, 'goto [D]eclaration')

          -- Jump to the type of the word under your cursor.
          map('grt', require('fzf-lua').lsp_typedefs, 'goto [t]ype definition')

          -- Jump to the Incoming Calls under your cursor.
          map('grc', require('fzf-lua').lsp_incoming_calls, 'goto incoming [c]alls')

          -- Jump to the Outgoing Calls under your cursor.
          map('grC', require('fzf-lua').lsp_outgoing_calls, 'goto outgoing [C]alls')

          -- Fuzzy find all the symbols in your current document.
          map('<leader>ss', function()
            require('fzf-lua').lsp_document_symbols {
              regex_filter = function(entry)
                if not entry.text then return true end
                -- 计算开头的空格数量（每级缩进2个空格）
                local _, end_pos = entry.text:find('^%s*')
                local spaces = end_pos or 0
                -- 提取符号类型，如 [Function], [Variable], [Class]
                local kind = entry.text:match('%[(%w+)%]')
                -- 显示顶层所有符号，一级嵌套中排除 Variable
                if spaces == 0 then
                  return true
                elseif spaces == 2 or spaces == 4 then
                  return kind ~= 'Variable'
                end
                return false
              end,
            }
          end, 'search document [s]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          map('<leader>so', require('fzf-lua').lsp_live_workspace_symbols, 'search workspace symb[o]ls')

          vim.keymap.set('n', '<leader>sS', function()
            require('fzf-lua').lsp_document_symbols {
              -- 正则过滤：匹配行首非缩进字符的行
              regex_filter = '^[^ │└├]',
              -- 修改提示符，方便区分
              prompt = 'TopLevel> ',
            }
          end, { desc = 'LSP Document Symbols (Top Level)' })

          -- Diagnostic keymaps
          vim.keymap.set('n', '<leader>d', vim.diagnostic.setloclist, { desc = 'Open [d]iagnostic Quickfix list' })

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- Auto enable inlay hints if supported
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, 'toggle inlay [h]ints')
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = true, severity_sort = true },
        update_in_insert = false,
        underline = { severity = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR } },
        virtual_lines = false,
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = true,
          spacing = 2,
          virt_text_pos = 'eol_right_align',
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      -- NOTE: The following line is now commented as blink.cmp extends capabilities by default from its internal code:
      -- https://github.com/Saghen/blink.cmp/blob/102db2f5996a46818661845cf283484870b60450/plugin/blink-cmp.lua
      -- local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Enable the following language servers
      local servers = {
        bashls = {}, -- shell
        clangd = {}, -- c, c++
        ruff = {}, -- python
        pyright = {},
        eslint = {}, -- js, ts
        lua_ls = {
          -- cmd = { ... },
          -- filetypes = { ... },
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
        harper_ls = {
          filetypes = { 'markdown', 'mdx' }, -- 仅在 markdown 文件中启用
          settings = {
            ['harper-ls'] = {
              linters = {
                SentenceCapitalization = false,
                SpellCheck = false,
                OrthographicConsistency = false,
                SplitWords = false,
              },
              markdown = {
                IgnoreLinkTitle = false,
              },
              diagnosticSeverity = 'hint',
              dialect = 'American',
              maxFileLength = 120000,
              excludePatterns = {},
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --    :Mason
      -- You can press `g?` for help in this menu.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        -----------Formatter
        'prettierd', -- many
        'prettier', -- many
        'clang-format', -- c cpp
        'ruff', -- python
        'codespell', -- spell check
        'beautysh', -- bash sh zsh
        'stylua', -- lua
        'typos-lsp', -- spell check

        -----------Linter
        -- 'cfn-lint', -- yaml, json
        -- 'vale', -- text, markdown
        'actionlint', -- ghaction-yaml

        -----------DAP
        -- 'debugpy', -- py
      })
      require('mason-tool-installer').setup {
        ensure_installed = ensure_installed,
        run_on_start = true,
        start_delay = 3000,
      }

      -- Configure global capabilities for file rename operations
      vim.lsp.config('*', {
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
      })

      -- Either merge all additional server configs from the `servers.mason` and `servers.others` tables
      -- to the default language server configs as provided by nvim-lspconfig or
      -- define a custom server config that's unavailable on nvim-lspconfig.
      for server, config in pairs(servers) do
        if not vim.tbl_isempty(config) then
          vim.lsp.config(server, config)
        end
      end

      -- After configuring our language servers, we now enable them
      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_enable = true,
      }
    end,
  },
}
