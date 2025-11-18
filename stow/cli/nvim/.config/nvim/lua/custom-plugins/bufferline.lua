return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('bufferline').setup {
        options = {
          mode = 'buffers', -- set to "tabs" to only show tabpages instead
          themable = true, -- allows highlight groups to be overridden i.e. sets highlights as default
          numbers = 'none',
          -- numbers = function(opts)
          --   return string.format('%s·%s', opts.raise(opts.ordinal), opts.lower(opts.id))
          -- end,

          path_components = 1, -- Show only the file name without the directory
          max_name_length = 15,
          tab_size = 15,
          show_buffer_close_icons = false,
          show_close_icon = false,
          persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
          always_show_bufferline = true,
          separator_style = 'slope',

          indicator = {
            icon = '▎', -- this should be omitted if indicator style is not 'icon'
            style = 'underline',
          },
          style_preset = {
            style_preset = 'minimal',
          },
        },
      }

      vim.keymap.set('n', '<leader>b1', '<Cmd>BufferLineGoToBuffer 1<CR>', { desc = 'goto 1st visible buffer' })
      vim.keymap.set('n', '<leader>b2', '<Cmd>BufferLineGoToBuffer 2<CR>', { desc = 'goto 2nd visible buffer' })
      vim.keymap.set('n', '<leader>b3', '<Cmd>BufferLineGoToBuffer 3<CR>', { desc = 'goto 3rd visible buffer' })
      vim.keymap.set('n', '<leader>b4', '<Cmd>BufferLineGoToBuffer 4<CR>', { desc = 'goto 4st visible buffer' })
      vim.keymap.set('n', '<leader>b5', '<Cmd>BufferLineGoToBuffer 5<CR>', { desc = 'goto 5st visible buffer' })
      vim.keymap.set('n', '<leader>b6', '<Cmd>BufferLineGoToBuffer 6<CR>', { desc = 'goto 6st visible buffer' })
      vim.keymap.set('n', '<leader>b7', '<Cmd>BufferLineGoToBuffer 7<CR>', { desc = 'goto 7st visible buffer' })
      vim.keymap.set('n', '<leader>b8', '<Cmd>BufferLineGoToBuffer 8<CR>', { desc = 'goto 8st visible buffer' })
      vim.keymap.set('n', '<leader>b9', '<Cmd>BufferLineGoToBuffer 9<CR>', { desc = 'goto 9st visible buffer' })
      vim.keymap.set('n', '<leader>b0', '<Cmd>BufferLineGoToBuffer -1<CR>', { desc = 'goto -1st visible buffer' })

      vim.keymap.set('n', '<leader>bb1', '<cmd>lua require("bufferline").go_to(1, true)<cr>', { desc = 'goto 1st absolute buffer' })
      vim.keymap.set('n', '<leader>bb2', '<cmd>lua require("bufferline").go_to(2, true)<cr>', { desc = 'goto 2nd absolute buffer' })
      vim.keymap.set('n', '<leader>bb3', '<cmd>lua require("bufferline").go_to(3, true)<cr>', { desc = 'goto 3rd absolute buffer' })
      vim.keymap.set('n', '<leader>bb4', '<cmd>lua require("bufferline").go_to(4, true)<cr>', { desc = 'goto 4st absolute buffer' })
      vim.keymap.set('n', '<leader>bb5', '<cmd>lua require("bufferline").go_to(5, true)<cr>', { desc = 'goto 5st absolute buffer' })
      vim.keymap.set('n', '<leader>bb6', '<cmd>lua require("bufferline").go_to(6, true)<cr>', { desc = 'goto 6st absolute buffer' })
      vim.keymap.set('n', '<leader>bb7', '<cmd>lua require("bufferline").go_to(7, true)<cr>', { desc = 'goto 7st absolute buffer' })
      vim.keymap.set('n', '<leader>bb8', '<cmd>lua require("bufferline").go_to(8, true)<cr>', { desc = 'goto 8st absolute buffer' })
      vim.keymap.set('n', '<leader>bb9', '<cmd>lua require("bufferline").go_to(9, true)<cr>', { desc = 'goto 9st absolute buffer' })
      vim.keymap.set('n', '<leader>bb0', '<cmd>lua require("bufferline").go_to(-1, true)<cr>', { desc = 'goto -1st absolute buffer' })

      vim.keymap.set('n', '<leader>bcr', '<cmd>BufferLineCloseRight<cr>', { desc = 'close all visible buffers to the right' })
      vim.keymap.set('n', '<leader>bcl', '<cmd>BufferLineCloseLeft<cr>', { desc = 'close all visible buffers to the left' })
      vim.keymap.set('n', '<leader>bco', '<cmd>BufferLineCloseOthers<cr>', { desc = 'close all visible buffers except self' })

      local close_all_buffers = function()
        for _, e in ipairs(require('bufferline').get_elements().elements) do
          vim.schedule(function()
            vim.cmd('bd ' .. e.id)
          end)
        end
      end
      vim.keymap.set('n', '<leader>bca', close_all_buffers, { desc = 'close all visible buffers' })

      vim.keymap.set('n', '<Tab>', '<Cmd>BufferLineCycleNext<CR>', { desc = 'next buffer' })
      vim.keymap.set('n', '<S-Tab>', '<Cmd>BufferLineCyclePrev<CR>', { desc = 'previous buffer' })
      vim.keymap.set('n', '<leader>c', ':bd<CR>', { desc = 'Close current buffer' })

      vim.keymap.set('n', '<leader>bp', function()
        local bufpath = vim.fn.expand '%:p'
        if bufpath == '' then
          vim.notify('buffer no file related.', vim.log.levels.WARN)
        else
          vim.notify('buffer file path: ' .. bufpath, vim.log.levels.INFO)
        end
      end, { desc = 'show path of buffer related file' })
    end,
  },
}
