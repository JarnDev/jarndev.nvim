-- Pi (a minimal Claude-Code-style terminal agent) on the local Ollama model, docked on
-- the right like Claude Code. Group <leader>al. sidekick.nvim only hosts the CLI and
-- sends context to it; its Copilot "next edit suggestions" stay off.
--
-- Pi's own config lives in ~/.pi/agent: models.json (Ollama, 8k context to match
-- OLLAMA_CONTEXT_LENGTH), settings.json (qwen3:8b, thinking off, small compaction
-- reserve) and extensions/confirm.ts (asks before every bash command and before
-- writes outside the project -- Pi has no permission system of its own).
local function cli()
  return require 'sidekick.cli'
end

local function send(msg)
  return function()
    cli().send { name = 'pi', msg = msg }
  end
end

return {
  'folke/sidekick.nvim',
  cmd = 'Sidekick',
  keys = {
    {
      '<leader>alc',
      function()
        cli().toggle { name = 'pi', focus = true }
      end,
      mode = { 'n', 'x' },
      desc = 'Chat: Pi agent (local model)',
    },
    { '<leader>als', send '{selection}', mode = 'x', desc = 'Send the selection to Pi' },
    { '<leader>alf', send '{file}', desc = 'Send the current file to Pi' },
    { '<leader>ald', send '{diagnostics}', desc = 'Send this file’s diagnostics to Pi' },
    {
      '<leader>ala',
      function()
        cli().prompt { name = 'pi' }
      end,
      mode = { 'n', 'x' },
      desc = 'Ask Pi with a ready prompt (explain, fix, tests...)',
    },
  },
  opts = {
    nes = { enabled = false },
    cli = {
      win = {
        layout = 'right',
        split = { width = 0.3 },
        keys = {
          -- Pi uses <C-p> to cycle models
          prompt = false,
        },
      },
      tools = {
        -- -nc: no AGENTS.md / CLAUDE.md -- written for Claude Code, and they would
        -- fill the 8k context
        pi = { cmd = { 'pi', '-nc' } },
      },
    },
  },
}
