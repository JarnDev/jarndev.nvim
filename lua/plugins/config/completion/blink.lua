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
    keymap = {
      preset = 'default',
      ['<Tab>'] = { 'snippet_forward', 'accept', 'fallback' },
      ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
      ['<CR>'] = { 'fallback' },
    },
    appearance = {
      nerd_font_variant = 'mono',
    },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      accept = { auto_brackets = { enabled = true } },
    },
    sources = {
      -- minuet (Ollama) is only queried when the local engine is toggled on (<leader>at),
      -- otherwise every keystroke would hit localhost:11434.
      default = function()
        local sources = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' }
        if vim.g.ai_engine_local then
          table.insert(sources, 'minuet')
        end
        return sources
      end,
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
        minuet = {
          name = 'minuet',
          module = 'minuet.blink',
          score_offset = 50,
          async = true,
          timeout_ms = 3000,
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
}
