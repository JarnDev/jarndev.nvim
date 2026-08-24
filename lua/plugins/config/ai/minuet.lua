-- Local AI code completion via Ollama (qwen2.5-coder) using minuet-ai.nvim.
-- Non-destructive to github/copilot.vim: minuet is exposed as a blink.cmp source
-- (see completion/blink.lua) and as an on-demand ghost-text engine via
-- `:Minuet virtualtext` + the <A-*> keymaps below.
-- Flip the inline ghost-text engine between GitHub Copilot (cloud) and the
-- local Ollama model. Default is Copilot, matching prior behaviour.
local function toggle_ai_engine()
  vim.g.ai_engine_local = not vim.g.ai_engine_local
  if vim.g.ai_engine_local then
    vim.cmd 'silent! Copilot disable'
    vim.cmd 'Minuet virtualtext enable'
    vim.notify('AI ghost-text: LOCAL (qwen2.5-coder)', vim.log.levels.INFO)
  else
    vim.cmd 'silent! Minuet virtualtext disable'
    vim.cmd 'silent! Copilot enable'
    vim.notify('AI ghost-text: GitHub Copilot', vim.log.levels.INFO)
  end
end

return {
  'milanglacier/minuet-ai.nvim',
  main = 'minuet',
  dependencies = { 'nvim-lua/plenary.nvim' },
  event = 'InsertEnter',
  keys = {
    { '<leader>at', toggle_ai_engine, desc = '[A]I [T]oggle local/copilot' },
  },
  opts = {
    -- Ask the local model for a single completion per request (keeps the 3080 snappy).
    n_completions = 1,
    -- How many chars of context to send around the cursor. 512/128 is a good
    -- FIM budget for a 7B model without blowing latency.
    context_window = 512,
    request_timeout = 4,
    provider = 'openai_fim_compatible',
    provider_options = {
      openai_fim_compatible = {
        -- Ollama needs no key; minuet just reads an env var that exists.
        api_key = 'TERM',
        name = 'Ollama',
        end_point = 'http://localhost:11434/v1/completions',
        model = 'qwen2.5-coder:7b',
        optional = {
          max_tokens = 256,
          top_p = 0.9,
        },
      },
    },
    -- Ghost-text UI is opt-in (auto_trigger_ft empty) so it never fights
    -- copilot.vim's automatic ghost text. Toggle per-buffer with
    -- `:Minuet virtualtext` (or the auto-trigger command), then use these keys.
    virtualtext = {
      auto_trigger_ft = {},
      keymap = {
        accept = '<A-y>',
        accept_line = '<A-Y>',
        prev = '<A-[>',
        next = '<A-]>',
        dismiss = '<A-e>',
      },
    },
  },
}
