return {
  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VeryLazy',
    version = '1.*',
    dependencies = {
      -- lua cmp source
      'folke/lazydev.nvim',
      'L3MON4D3/LuaSnip',
    },
    opts = {
      keymap = {
        -- See :h blink-cmp-config-keymap for defining your own keymap
        preset = 'none',
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        -- ['<C-e>'] = { 'hide', 'fallback' },
        ['<C-y>'] = { 'select_and_accept', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
        ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },
        -- fzf like
        ['<C-k>'] = { 'select_prev', 'fallback_to_mappings' },
        ['<C-j>'] = { 'select_next', 'fallback_to_mappings' },
        ['<C-u>'] = { 'scroll_documentation_up', 'fallback_to_mappings' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback_to_mappings' },

        ['<Tab>'] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            else
              return cmp.select_and_accept()
            end
          end,
          'snippet_forward',
          'fallback',
        },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      completion = {
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = true, auto_show_delay_ms = 0, update_delay_ms = 50 },

        -- Display a preview of the selected item on the current line
        ghost_text = { enabled = false },

        menu = {
          min_width = 30,
          max_height = 20,
          border = nil, -- Defaults to `vim.o.winborder` on nvim 0.11+
          -- AVAILABLE COMPONENTS
          -- `kind_icon`: Shows the icon for the kind of the item
          -- `kind`: Shows the kind of the item as text (e.g. `Function`)
          -- `label`: Shows the label of the item as well as the `label_detail` (e.g. `into(as Into)` where `into` is the label and `(as Into)` is the label detail)
          -- If the `label_detail` is missing from your items, ensure you’ve setup LSP capabilities <../installation> and that your LSP supports the feature
          -- `label_description`: Shows the label description of the item (e.g. `date-fns/formatDistance`, the module that the item will be auto-imported from)
          -- If the `label_description` is missing from your items, ensure you’ve setup LSP capabilities <../installation> and that your LSP supports the feature
          -- `source_name`: Shows the name of the source that provided the item, from the `sources.providers.*.name` (e.g. `LSP`)
          -- `source_id`: Shows the id of the source that provided the item, from the `sources.providers[id]` (e.g. `lsp`)
          draw = {
            columns = { { 'kind_icon', gap = 1, 'kind' }, { 'label', gap = 1 }, { 'label_description', 'source_name', gap = 1 } },
          },
        },
      },

      -- add 'buffer' if you don't want text completions, by default it's only enabled when LSP returns no items
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        per_filetype = {
          -- sql = { 'dadbod' },
          lua = { inherit_defaults = true, 'lazydev' },
        },
        -- many community providers
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },

      snippets = { preset = 'luasnip' },

      -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
      -- which automatically downloads a prebuilt binary when enabled.
      -- fuzzy = { implementation = 'lua' },
      fuzzy = { implementation = 'prefer_rust_with_warning' },

      -- Shows a signature help window while you type arguments for a function
      signature = { enabled = true, window = { show_documentation = true } },

      cmdline = {
        keymap = { preset = 'inherit' },
        completion = { menu = { auto_show = true } },
      },
    },
    opts_extend = { 'sources.default' },
  },
}
