return {
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {

        '<leader>f',
        function()
          require('conform').format({ async = true, lsp_format = 'never' }, function(err, did_edit)
            if did_edit then
              -- 触发 gitsigns 更新并预览变更
            end
          end)
        end,
        mode = '',
        desc = '[f]ormat buffer',
      },
    },

    opts = {
      log_level = vim.log.levels.INFO,
      notify_on_error = true,
      -- Conform will notify you when no formatters are available for the buffer
      notify_no_formatters = true,
      -- format_on_save = { -- I recommend these options. See :help conform.format for details.
      --   lsp_format = 'fallback',
      --   timeout_ms = 500,
      -- },
      formatters_by_ft = {
        lua = { 'stylua' },
        bash = { 'beautysh' },
        sh = { 'beautysh' },
        zsh = { 'beautysh' },
        c = { 'clang-format' },
        python = { 'ruff_format' },
        javascript = { 'prettierd' },
        typescript = { 'prettierd' },
        css = { 'prettierd' },
        scss = { 'prettierd' },
        markdown = { 'prettierd' },
        html = { 'prettierd' },
        json = { 'prettierd', 'prettier', stop_after_first = true },
        yaml = { 'prettierd', 'prettier', stop_after_first = true },

        -- if bit defube stop after first will run below
        -- Use the "*" filetype to run formatters on all filetypes.
        ['*'] = { 'codespell' },
        -- Use the "_" filetype to run formatters on filetypes that don't
        -- have other formatters configured.
        ['_'] = { 'trim_whitespace' },
      },
    },
  },
}
