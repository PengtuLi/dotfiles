-- Snippet Engine
return {
  'L3MON4D3/LuaSnip',
  version = '2.*',
  build = 'make install_jsregexp',
  event = 'VeryLazy',
  dependencies = {
    -- `friendly-snippets` contains a variety of premade snippets.
    --    See the README about individual language/framework/plugin snippets:
    --    https://github.com/rafamadriz/friendly-snippets
    {
      'rafamadriz/friendly-snippets', -- 提供大量现成的 VS Code 风格 snippets
    },
  },
  config = function()
    require('luasnip.loaders.from_vscode').lazy_load() -- 加载 friendly-snippets
    -- friendly-snippets - enable standardized comments snippets
    require('luasnip').filetype_extend('typescript', { 'tsdoc' })
    require('luasnip').filetype_extend('javascript', { 'jsdoc' })
    require('luasnip').filetype_extend('lua', { 'luadoc' })
    require('luasnip').filetype_extend('python', { 'debug', 'comprehension', 'pydoc', 'unittest' })
    require('luasnip').filetype_extend('rust', { 'rustdoc' })
    require('luasnip').filetype_extend('cs', { 'csharpdoc' })
    require('luasnip').filetype_extend('java', { 'javadoc' })
    require('luasnip').filetype_extend('c', { 'cdoc' })
    require('luasnip').filetype_extend('cpp', { 'cppdoc' })
    require('luasnip').filetype_extend('sh', { 'shelldoc' })

    -- custom snippets
    require('luasnip.loaders.from_vscode').lazy_load {
      paths = { vim.fn.stdpath 'config' .. '/snippets' },
    }
    -- require('luasnip').filetype_extend('markdown', { 'mdx' })

    local ls = require 'luasnip'
    --   vim.keymap.set({ 'i', 's' }, '<C-E>', function()
    --     if ls.choice_active() then
    --       ls.change_choice(1)
    --     end
    --   end, { silent = true })
  end,
}
