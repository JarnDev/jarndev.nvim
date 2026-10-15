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
    -- How many chars of context to send around the cursor.
    context_window = 512,
    -- qwen2.5-coder:14b is the only installed model that supports FIM ("insert");
    -- the 7B was removed and qwen3-coder:30b answers "does not support insert".
    -- Measured 12/10/2026: 3.2s for a full 64-token completion warm; a cold load
    -- takes 33-65s, so the first request after a model swap times out and the next
    -- ones work. It also evicts the default qwen3:8b from VRAM (10 GB fit only one).
    request_timeout = 5,
    provider = 'openai_fim_compatible',
    provider_options = {
      openai_fim_compatible = {
        -- Ollama needs no key; minuet just reads an env var that exists.
        api_key = 'TERM',
        name = 'Ollama',
        -- OLLAMA_API_BASE (zshrc): localhost on the machine with the GPU; another machine
        -- points it at that one over the LAN / Tailscale subnet route.
        end_point = (vim.env.OLLAMA_API_BASE or 'http://localhost:11434') .. '/v1/completions',
        model = 'qwen2.5-coder:14b',
        optional = {
          -- 256 tokens (~20 tok/s here) would blow the timeout; 64 fits in ~3.2s.
          max_tokens = 64,
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
