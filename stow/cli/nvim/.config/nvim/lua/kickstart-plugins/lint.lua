return {

  -- nvim-lint complements the built-in language server client for languages where there are no language servers, or where standalone linters provide better results.
  { -- Linting
    'mfussenegger/nvim-lint',
    -- event = { 'BufReadPre', 'BufNewFile' },
    event = 'VeryLazy',
    config = function()
      local lint = require 'lint'

      lint.linters_by_ft = {
        -- clojure = { "clj-kondo" },
        -- inko = { "inko" },
        -- janet = { "janet" },
        -- rst = { "vale" },
        -- ruby = { "ruby" },
        -- terraform = { "tflint" },
        yaml = {},
        json = {},
        text = {},
        markdown = {},
        latex = {},
        -- maybe trufflehog
      }

      -- for _, filetype in ipairs(common_filetypes_with_typos) do
      --   if not lint.linters_by_ft[filetype] then
      --     lint.linters_by_ft[filetype] = { 'typos' }
      --   end
      -- end

      -- 初始化为 true，表示默认开启自动 linting
      vim.g.auto_lint_enabled = true
      local function toggle_auto_lint()
        vim.g.auto_lint_enabled = not vim.g.auto_lint_enabled
        local status = vim.g.auto_lint_enabled and 'enabled' or 'disabled'
        vim.notify('auto linting: ' .. status, vim.log.levels.INFO)
      end
      vim.keymap.set('n', '<leader>tl', toggle_auto_lint, { desc = 'toggle auto [l]int' })

      vim.keymap.set('n', '<leader>L', function()
        lint.try_lint()
      end, { desc = '[L]int buffer' })

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.g.auto_lint_enabled and vim.opt_local.modifiable:get() then
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
