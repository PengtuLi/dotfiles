return {

  -- nvim-lint complements the built-in language server client for languages where there are no language servers, or where standalone linters provide better results.
  { -- Linting
    'mfussenegger/nvim-lint',
    -- event = { 'BufReadPre', 'BufNewFile' },
    event = 'VeryLazy',
    config = function()
      local lint = require 'lint'

      -- -- 动态查找 mason 或系统安装的 linter
      -- local function find_mason_bin(executable)
      --   -- 先检查 PATH
      --   if vim.fn.executable(executable) == 1 then
      --     return executable
      --   end
      --
      --   -- 再检查 mason 默认安装路径
      --   local mason_bin = vim.fn.stdpath 'data' .. '/mason/bin/' .. executable
      --   if vim.fn.executable(mason_bin) == 1 then
      --     return mason_bin
      --   end
      --
      --   -- 最后检查 Homebrew 路径（macOS）
      --   if vim.fn.has 'mac' == 1 then
      --     local brew_path = '/opt/homebrew/bin/' .. executable
      --     if vim.fn.executable(brew_path) == 1 then
      --       return brew_path
      --     end
      --   end
      --
      --   return nil -- 未找到
      -- end
      --
      -- local typos_path = find_mason_bin('typos')
      -- if typos_path then
      --   lint.linters.typos.cmd = typos_path
      -- else
      --   vim.notify('typos not found, install via Mason or brew', vim.log.levels.WARN)
      -- end

      lint.linters_by_ft = {
        -- clojure = { "clj-kondo" },
        -- inko = { "inko" },
        -- janet = { "janet" },
        -- rst = { "vale" },
        -- ruby = { "ruby" },
        -- terraform = { "tflint" },
        yaml = {},
        ['yaml.ghaction'] = { 'actionlint' },
        json = {},
        text = {},
        markdown = {},
        latex = {},
        -- maybe trufflehog
      }

      -- -- 为所有已定义的文件类型添加 typos
      -- for filetype, linters in pairs(lint.linters_by_ft) do
      --   if not vim.tbl_contains(linters, 'typos') then
      --     table.insert(linters, 'typos')
      --   end
      -- end
      --
      -- -- 为常用但未定义的文件类型设置默认配置（包含 typos）
      -- local common_filetypes_with_typos = {
      --   'lua',
      --   'python',
      --   'javascript',
      --   'typescript',
      --   'rust',
      --   'go',
      --   'java',
      --   'cpp',
      --   'c',
      --   'sh',
      --   'bash',
      --   'zsh',
      --   'html',
      --   'css',
      --   'vim',
      --   'jsonc',
      --   'toml',
      --   'ini',
      --   'conf',
      --   'dockerfile',
      --   'make',
      --   'cmake',
      --   'sql',
      --   'graphql',
      --   'vue',
      --   'svelte',
      --   'tsx',
      --   'jsx',
      -- }
      --
      -- for _, filetype in ipairs(common_filetypes_with_typos) do
      --   if not lint.linters_by_ft[filetype] then
      --     lint.linters_by_ft[filetype] = { 'typos' }
      --   end
      -- end

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
