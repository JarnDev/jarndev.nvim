return {
  'nvim-treesitter/nvim-treesitter-context',
  event = 'BufReadPost',
  keys = {
    { '<leader>ux', '<cmd>TSContext toggle<cr>', desc = 'UI: sticky conte[X]t header on/off' },
  },
  opts = {
    max_lines = 3,
  },
}
