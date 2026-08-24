return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  opts = {
    -- Adapters live under `adapters.http` in current codecompanion. Anthropic is
    -- the cloud default; ollama runs fully local against the machine's Ollama.
    adapters = {
      http = {
        anthropic = function()
          return require('codecompanion.adapters').extend('anthropic', {
            schema = {
              model = {
                default = 'claude-sonnet-4-6',
              },
            },
          })
        end,
        ollama = function()
          return require('codecompanion.adapters').extend('ollama', {
            schema = {
              model = {
                default = 'qwen2.5-coder:14b',
              },
            },
          })
        end,
      },
    },
    strategies = {
      chat = { adapter = 'anthropic' },
      inline = { adapter = 'anthropic' },
    },
  },
  keys = {
    { '<leader>aa', '<cmd>CodeCompanionChat Toggle<cr>', mode = { 'n', 'v' }, desc = '[A]I Chat toggle' },
    { '<leader>ai', '<cmd>CodeCompanion<cr>', mode = { 'n', 'v' }, desc = '[A]I [I]nline assistant' },
    { '<leader>ac', '<cmd>CodeCompanionChat Add<cr>', mode = 'v', desc = '[A]I add selection to [C]hat' },
    { '<leader>ap', '<cmd>CodeCompanionActions<cr>', mode = { 'n', 'v' }, desc = '[A]I action [P]alette' },
    { '<leader>aL', '<cmd>CodeCompanionChat adapter=ollama<cr>', mode = { 'n', 'v' }, desc = '[A]I [L]ocal chat (Ollama)' },
  },
}
