-- One set of ghost-text keys for both engines: copilot.vim (default) and minuet's
-- local model (<leader>alt, ai/minuet.lua). Each key acts on whichever suggestion is
-- on screen; with none shown, next/prev ask the active engine for one.
local function minuet()
  local ok, vt = pcall(require, 'minuet.virtualtext')
  return ok and vt.action or nil
end

local function copilot_visible()
  return vim.fn.exists '*copilot#GetDisplayedSuggestion' == 1 and vim.fn['copilot#GetDisplayedSuggestion']().text ~= ''
end

local function minuet_visible()
  local m = minuet()
  if not m then
    return false
  end
  local ok, visible = pcall(m.is_visible)
  return ok and visible
end

-- These are expr maps, so they run under textlock: copilot returns the keys to type,
-- while minuet edits the buffer itself and has to run right after the map returns.
local function run_minuet(name)
  vim.schedule(function()
    local m = minuet()
    if m then
      m[name]()
    end
  end)
  return ''
end

local function accept(copilot_fn, minuet_fn)
  return function()
    if copilot_visible() then
      return vim.fn[copilot_fn] ''
    elseif minuet_visible() then
      return run_minuet(minuet_fn)
    end
    return ''
  end
end

local function cycle(copilot_fn, minuet_fn)
  return function()
    if not copilot_visible() and (minuet_visible() or vim.g.ai_engine_local) then
      return run_minuet(minuet_fn)
    end
    return vim.fn[copilot_fn]()
  end
end

-- <C-]> still goes through afterwards, as in copilot.vim's own map (it expands abbreviations).
local function dismiss()
  if copilot_visible() then
    return vim.fn['copilot#Dismiss']() .. vim.keycode '<C-]>'
  elseif minuet_visible() then
    run_minuet 'dismiss'
  end
  return vim.keycode '<C-]>'
end

local function imap(lhs, rhs, desc)
  return { lhs, rhs, mode = 'i', expr = true, replace_keycodes = false, desc = desc }
end

return {
  'github/copilot.vim',
  event = 'InsertEnter',
  init = function()
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true
  end,
  keys = {
    -- <Tab> belongs to blink, so copilot_no_tab_map is set and accept lives on <A-y>.
    imap('<A-y>', accept('copilot#Accept', 'accept'), 'AI: accept suggestion'),
    imap('<A-Y>', accept('copilot#AcceptLine', 'accept_line'), 'AI: accept one line'),
    imap('<A-]>', cycle('copilot#Next', 'next'), 'AI: next suggestion'),
    imap('<A-[>', cycle('copilot#Previous', 'prev'), 'AI: previous suggestion'),
    imap('<C-]>', dismiss, 'AI: dismiss suggestion'),
  },
}
