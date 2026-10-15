-- Shows the keys being pressed in a corner -- for recordings, demos, teaching.
return {
  'nvzone/showkeys',
  cmd = 'ShowkeysToggle',
  keys = {
    { '<leader>uv', '<cmd>ShowkeysToggle<cr>', desc = 'UI: show keys pressed (recording)' },
  },
  opts = { position = 'top-right', maxkeys = 5 },
}
