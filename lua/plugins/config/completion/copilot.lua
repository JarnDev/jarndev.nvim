return {
  'github/copilot.vim',
  event = 'InsertEnter',
  init = function()
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true
  end,
  keys = {
    -- copilot_no_tab_map leaves the ghost text without an accept key; <Tab> belongs to blink.
    { '<M-l>', 'copilot#Accept("")', mode = 'i', expr = true, replace_keycodes = false, desc = 'Copilot accept' },
  },
}
