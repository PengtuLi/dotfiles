return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = function()
    -- breadcrumb
    local function ts_breadcrumb()
      return vim.fn['nvim_treesitter#statusline'] {
        indicator_size = 160,
        separator = ' ',
        allow_duplicates = true,
      } or ''
    end

    -- green filename highlight
    local green_hl_filename = {
      'filename',
      file_status = true, -- Displays file status (readonly status, modified status)
      newfile_status = true, -- Display new file status (new file means no write after created)
      path = 0,
      -- 0: Just the filename
      -- 1: Relative path
      -- 2: Absolute path
      -- 3: Absolute path, with tilde as the home directory
      -- 4: Filename and parent dir, with tilde as the home directory

      symbols = {
        modified = '[+]', -- Text to show when the file is modified.
        readonly = '[]', -- Text to show when the file is non-modifiable or readonly.
        unnamed = '[-]', -- Text to show for unnamed buffers.
        newfile = '[?]', -- Text to show for newly created file before first write
      },
      color = {
        fg = 'White',
        bg = 'Green',
        gui = 'bold', -- 字体样式 (加粗)
      },
    }

    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = 'tokyonight',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = { 'neo-tree' },
          winbar = { 'neo-tree' },
        },
        ignore_focus = {},
        always_divide_middle = true,
        always_show_tabline = true,
        globalstatus = true,
        -- refresh = {
        --   statusline = 100,
        --   tabline = 100,
        --   winbar = 100,
        -- },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = {
          {
            'filename',
            path = 1, -- 使用相对路径
            file_status = false, -- 这里不显示状态符号
            fmt = function(str)
              -- 正则表达式：提取最后一个 "/" 之前的所有内容
              local dir = str:match '(.*/)'
              return dir or '' -- 如果没有目录（在根目录），则返回空
            end,
            padding = { left = 1, right = 0 },
            color = { fg = 'White', gui = 'bold,italic' }, -- 路径颜色 (Dracula 紫色或灰色)
            shorting_target = 40, -- Shortens path to leave 40 spaces in the window
          },
          green_hl_filename,
        },
        lualine_x = {
          'searchcount',
          'selectioncount',
          -- 'encoding',
          -- 'fileformat',
          -- 'filetype',
        },
        lualine_y = {
          'lsp_status',
          function()
            local lint = require 'lint'
            local filetype = vim.bo.filetype

            if lint.linters_by_ft[filetype] then
              local linters = lint.get_running(vim.api.nvim_get_current_buf())
              if #linters == 0 then
                return ' ' .. table.concat(lint.linters_by_ft[filetype], ',')
              end
              return ' ' .. table.concat(linters, ',')
            else
              -- return ' '
              return ''
            end
          end,
        },
        lualine_z = { 'progress', '%l:%LLOC' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { green_hl_filename },
        lualine_x = {},
        lualine_y = {},
        lualine_z = { 'progress', '%l:%LLOC' },
      },
      tabline = {},
      extensions = {},
      winbar = {
        -- lualine_a = { 'buffers' },
      },
      inactive_winbar = {
        -- lualine_a = { 'buffers' },
      },
    }
  end,
}
