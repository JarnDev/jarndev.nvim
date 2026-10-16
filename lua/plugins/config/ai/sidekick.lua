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

-- `git diff` of the buffer's repo, capped: a long diff would eat the 8k context
local function git_diff(args)
  return function(ctx)
    local out = vim.fn.systemlist(vim.list_extend({ 'git', '-C', ctx.cwd, 'diff', '--no-color' }, args))
    if vim.v.shell_error ~= 0 or #out == 0 then
      return false
    end
    if #out > 150 then
      out = vim.list_slice(out, 1, 150)
      table.insert(out, '[diff truncated at 150 lines]')
    end
    return { '```diff', unpack(vim.list_extend(out, { '```' })) }
  end
end

-- sidekick takes {this}/{file}/... from the last window it saw focused, tracked by a
-- WinEnter autocmd that only exists once the plugin has loaded. Mark the window the key
-- was pressed in, or the first send can read neo-tree and drop every {this} prompt.
local function here()
  if vim.bo.filetype ~= 'sidekick_terminal' then
    vim.w.sidekick_visit = vim.uv.hrtime()
  end
end

local function send(msg)
  return function()
    here()
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
        here()
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
      -- extra ready prompts for <leader>ala, next to the built-in ones (explain, fix,
      -- tests, review...). The diff ones carry the diff, so Pi needs no confirmed bash.
      context = {
        git_diff = git_diff { 'HEAD' },
        git_staged = git_diff { '--cached' },
      },
      prompts = {
        changes = 'Review these uncommitted changes for bugs and leftovers:\n{git_diff}',
        commit = 'Write a conventional commit message (subject up to 72 chars, then a short body) for:\n{git_staged|git_diff}',
        simplify = 'Simplify {this} without changing its behavior',
        names = 'Suggest clearer names for the variables and functions in {this}',
        edge_cases = 'Which inputs or edge cases does {this} handle wrong? Be specific',
        errors = 'Add error handling to {this}, in the style of the rest of the file',
        types = 'Add type annotations to {this}',
        pt = 'Explique {this} em português, de forma curta',
      },
    },
  },
}
