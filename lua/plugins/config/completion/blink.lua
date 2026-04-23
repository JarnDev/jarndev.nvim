return {
  'saghen/blink.cmp',
  version = '1.*',
  dependencies = {
    'saghen/blink.compat',
    'fang2hou/blink-copilot',
    {
      'L3MON4D3/LuaSnip',
      build = (function()
        if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
          return
        end
        return 'make install_jsregexp'
      end)(),
    },
  },
  opts = {
    keymap = { preset = 'default' },
    appearance = {
      nerd_font_variant = 'mono',
    },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      accept = { auto_brackets = { enabled = true } },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
      per_filetype = {
        sql = { 'dadbod', 'buffer' },
        mysql = { 'dadbod', 'buffer' },
      },
      providers = {
        copilot = {
          name = 'copilot',
          module = 'blink-copilot',
          score_offset = 100,
          async = true,
        },
        dadbod = {
          name = 'Dadbod',
          module = 'blink.compat.source',
          opts = { name = 'vim-dadbod-completion' },
        },
      },
    },
    snippets = { preset = 'luasnip' },
  },
  opts_extend = { 'sources.default' },
}
