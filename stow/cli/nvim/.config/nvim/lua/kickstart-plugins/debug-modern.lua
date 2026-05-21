return {
  {
    'mfussenegger/nvim-dap',
    event = 'VeryLazy',
    dependencies = {
      -- ui
      'igorlfs/nvim-dap-view',
      -- install plugin
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
    },
    keys = {
      {
        '<F5>',
        function()
          require('dap').continue()
        end,
        desc = 'Debug: Continue',
      },
      {
        '<F10>',
        function()
          require('dap').step_over()
        end,
        desc = 'Debug: Step Over',
      },
      {
        '<F11>',
        function()
          require('dap').step_into()
        end,
        desc = 'Debug: Step Into',
      },
      {
        '<F12>',
        function()
          require('dap').step_out()
        end,
        desc = 'Debug: Step Out',
      },
      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = '[D]ebug: Toggle [B]reakpoint',
      },
      {
        '<leader>dc',
        function()
          require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = '[D]ebug: [C]onditional Breakpoint',
      },
      {
        '<F7>',
        function()
          require('dap-view').toggle()
        end,
        desc = 'Debug: Toggle DapView',
      },
    },
    config = function()
      local dap = require 'dap'
      dap.set_log_level 'error'

      require('dap-view').setup {
        winbar = {
          show = true,
          controls = {
            enabled = true,
          },
        },
        auto_toggle = true,
        virtual_text = {
          enabled = true,
        },
      }

      require('mason-nvim-dap').setup {
        automatic_installation = true,
        handlers = {},
      }

      -- hl
      vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
      vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
      vim.api.nvim_set_hl(0, 'debugPC', { bg = '#554480' })
      local breakpoint_icons = vim.g.have_nerd_font
          and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
        or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
      for type, icon in pairs(breakpoint_icons) do
        local tp = 'Dap' .. type
        local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
        vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
      end

      -- custom debugger such as delve
      -- require('dap-go').setup {
      --   delve = {
      --     detached = vim.fn.has 'win32' == 0,
      --   },
      -- }
    end,
  },
}
