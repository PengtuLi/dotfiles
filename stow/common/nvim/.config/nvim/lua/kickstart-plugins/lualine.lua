return {
  'nvim-lualine/lualine.nvim',
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

    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = 'dracula',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        always_show_tabline = true,
        globalstatus = false,
        refresh = {
          statusline = 100,
          tabline = 100,
          winbar = 100,
        },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = {
          {
            'filename',
            file_status = true, -- Displays file status (readonly status, modified status)
            newfile_status = true, -- Display new file status (new file means no write after created)
            path = 1,
            -- 0: Just the filename
            -- 1: Relative path
            -- 2: Absolute path
            -- 3: Absolute path, with tilde as the home directory
            -- 4: Filename and parent dir, with tilde as the home directory

            shorting_target = 40, -- Shortens path to leave 40 spaces in the window
            -- for other components. (terrible name, any suggestions?)
            symbols = {
              modified = '[-]', -- Text to show when the file is modified.
              readonly = '[x]', -- Text to show when the file is non-modifiable or readonly.
              unnamed = '[?]', -- Text to show for unnamed buffers.
              newfile = '[+]', -- Text to show for newly created file before first write
            },
          },
          ts_breadcrumb,
        },
        lualine_x = {
          'searchcount',
          'selectioncount',
          'encoding',
          'fileformat',
          'filetype',
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
              return ' '
            end
          end,
        },
        lualine_z = { 'progress', '%l:%LLOC' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename', ts_breadcrumb },
        lualine_x = {},
        lualine_y = {},
        lualine_z = { 'progress', '%l:%LLOC' },
      },
      tabline = {},
      extensions = {},
      winbar = {
        lualine_a = { 'buffers' },
      },
      inactive_winbar = {
        -- lualine_a = { 'buffers' },
      },
    }
  end,
}
