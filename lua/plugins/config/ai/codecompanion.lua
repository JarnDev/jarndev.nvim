-- Inline edits (and a markdown chat buffer) against Ollama (core/ollama.lua: same server as minuet,
-- OLLAMA_API_BASE or this machine). Group <leader>al; the Claude-style chat is Pi
-- (sidekick.lua). No cloud adapter: the Anthropic
-- one needs a paid API key the Claude subscription does not cover -- Claude Code
-- (<leader>ac) is the cloud agent.
return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  cmd = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionActions', 'CodeCompanionCmd' },
  opts = {
    adapters = {
      http = {
        ollama = function()
          return require('codecompanion.adapters').extend('ollama', {
            env = { url = require('core.ollama').base },
            schema = {
              model = {
                -- a chat-capable model already in VRAM if any (no swap), else the one
                -- picked with <leader>alm
                default = function()
                  return require('core.ollama').chat_model_now()
                end,
              },
            },
          })
        end,
      },
    },
    -- don't auto-attach CLAUDE.md / AGENTS.md: they are instructions for Claude Code
    -- agents, and on an 8B model they only eat the context window
    rules = { opts = { chat = { enabled = false } } },
    interactions = {
      chat = { adapter = 'ollama' },
      inline = { adapter = 'ollama' },
      cmd = { adapter = 'ollama' },
    },
  },
  keys = {
    { '<leader>alC', '<cmd>CodeCompanionChat Toggle<cr>', mode = { 'n', 'v' }, desc = 'Chat buffer (codecompanion, markdown)' },
    { '<leader>ali', '<cmd>CodeCompanion<cr>', mode = { 'n', 'v' }, desc = 'Inline edit with the local model' },
    { '<leader>alp', '<cmd>CodeCompanionActions<cr>', mode = { 'n', 'v' }, desc = 'Action palette' },
  },
}
