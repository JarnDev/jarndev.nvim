-- GitHub issues and pull-request review inside Neovim. Requires the `gh` CLI on PATH
-- and an authenticated `gh auth login`.
return {
  'pwntester/octo.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'folke/snacks.nvim' },
  cmd = 'Octo',
  keys = {
    { '<leader>gp', '<cmd>Octo pr list<cr>', desc = 'Octo: [P]ull request list' },
    { '<leader>gi', '<cmd>Octo issue list<cr>', desc = 'Octo: [I]ssue list' },
    { '<leader>gr', '<cmd>Octo review start<cr>', desc = 'Octo: start [R]eview' },
    { '<leader>gO', '<cmd>Octo actions<cr>', desc = 'Octo: action palette' },
  },
  opts = {
    picker = 'snacks', -- reuse the existing picker; avoids dragging telescope in
    enable_builtin = true,
  },
}
