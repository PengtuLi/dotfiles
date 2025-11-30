return {

  -- nvim-lint complements the built-in language server client for languages where there are no language servers, or where standalone linters provide better results.
  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      -- FIX: 动态设置 typos 的命令路径（仅在 macOS 上使用 Homebrew 路径）
      if vim.fn.has 'mac' == 1 then
        local typos_cmd = 'typos' -- 默认 fallback
        -- 优先检查 Apple Silicon 的 Homebrew 路径
        local brew_path = '/opt/homebrew/bin/typos'
        if vim.fn.executable(brew_path) == 1 then
          typos_cmd = brew_path
        end
        -- 注册 linter
        lint.linters.typos.cmd = typos_cmd
      end

      lint.linters_by_ft = {
        -- clojure = { "clj-kondo" },
        -- inko = { "inko" },
        -- janet = { "janet" },
        -- rst = { "vale" },
        -- ruby = { "ruby" },
        -- terraform = { "tflint" },
        yaml = { 'cfn_lint' },
        ['yaml.ghaction'] = { 'actionlint' },
        json = { 'cfn_lint' },
        text = { 'vale' },
        markdown = { 'vale' },
        latex = { 'vale' },
        -- maybe trufflehog
      }

      -- 为所有已定义的文件类型添加 typos
      for filetype, linters in pairs(lint.linters_by_ft) do
        if not vim.tbl_contains(linters, 'typos') then
          table.insert(linters, 'typos')
        end
      end

      -- 为常用但未定义的文件类型设置默认配置（包含 typos）
      local common_filetypes_with_typos = {
        'lua',
        'python',
        'javascript',
        'typescript',
        'rust',
        'go',
        'java',
        'cpp',
        'c',
        'sh',
        'bash',
        'zsh',
        'html',
        'css',
        'vim',
        'jsonc',
        'toml',
        'ini',
        'conf',
        'dockerfile',
        'make',
        'cmake',
        'sql',
        'graphql',
        'vue',
        'svelte',
        'tsx',
        'jsx',
      }

      for _, filetype in ipairs(common_filetypes_with_typos) do
        if not lint.linters_by_ft[filetype] then
          lint.linters_by_ft[filetype] = { 'typos' }
        end
      end

      -- vim.notify(vim.inspect(lint.linters_by_ft), vim.log.levels.INFO)

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
