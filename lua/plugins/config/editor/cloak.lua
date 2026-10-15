-- Masks secret values in .env-style files (`KEY=****`) so they do not leak on a shared
-- screen, a recording or a demo. <leader>uk toggles; <leader>uK reveals the cursor line
-- until the cursor moves.
return {
  'laytan/cloak.nvim',
  event = { 'BufReadPre .env*', 'BufReadPre *.env', 'BufReadPre .envrc' },
  keys = {
    { '<leader>uk', '<cmd>CloakToggle<cr>', desc = 'UI: cloa[K] secrets on/off' },
    { '<leader>uK', '<cmd>CloakPreviewLine<cr>', desc = 'UI: reveal this secret line' },
  },
  opts = {
    cloak_character = '*',
    patterns = {
      { file_pattern = { '.env*', '*.env', '.envrc' }, cloak_pattern = '=.+' },
    },
  },
}
