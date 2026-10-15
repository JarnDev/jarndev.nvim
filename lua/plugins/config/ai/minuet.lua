-- Local AI code completion via Ollama (qwen2.5-coder) using minuet-ai.nvim.
-- Non-destructive to github/copilot.vim: minuet is exposed as a blink.cmp source
-- (see completion/blink.lua) and as an on-demand ghost-text engine via
-- `:Minuet virtualtext` + the <A-*> keymaps below.
local MODEL = 'qwen2.5-coder:14b'
-- OLLAMA_API_BASE (zshrc): localhost on the machine with the GPU; another machine
-- points it at that one over the LAN / Tailscale subnet route.
local OLLAMA = vim.env.OLLAMA_API_BASE or 'http://localhost:11434'

-- Load the model into VRAM ahead of time. A cold load takes ~35-60s, far past minuet's
-- request_timeout, so the first completions of a session silently time out. An empty
-- prompt to /api/generate only loads the model. keep_alive 15m keeps it warm for a
-- working session without pinning it: it shares the 10 GB with the default qwen3:8b.
local function warm_model()
  local t0 = vim.uv.hrtime()
  vim.notify('AI local: carregando ' .. MODEL .. '...', vim.log.levels.INFO)
  vim.system({
    'curl', '-sf', '--max-time', '180', '-X', 'POST', OLLAMA .. '/api/generate',
    '-d', vim.json.encode { model = MODEL, keep_alive = '15m' },
  }, { text = true }, function(r)
    local s = (vim.uv.hrtime() - t0) / 1e9
    vim.schedule(function()
      if r.code == 0 then
        vim.notify(('AI local: %s pronto (%.1fs)'):format(MODEL, s), vim.log.levels.INFO)
      else
        vim.notify(('AI local: falhou ao carregar %s em %s (curl %d)'):format(MODEL, OLLAMA, r.code), vim.log.levels.WARN)
      end
    end)
  end)
end

-- Flip the inline ghost-text engine between GitHub Copilot (cloud) and the
-- local Ollama model. Default is Copilot, matching prior behaviour.
local function toggle_ai_engine()
  vim.g.ai_engine_local = not vim.g.ai_engine_local
  if vim.g.ai_engine_local then
    vim.cmd 'silent! Copilot disable'
    vim.cmd 'Minuet virtualtext enable'
    warm_model() -- switching to local is when the first completion is about to be asked
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
    { '<leader>aw', warm_model, desc = '[A]I [W]arm local model (load into VRAM)' },
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
        end_point = OLLAMA .. '/v1/completions',
        model = MODEL,
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
