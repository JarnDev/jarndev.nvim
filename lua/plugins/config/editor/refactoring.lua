-- Extract function / extract variable / inline variable -- the refactorings LSP rename
-- alone cannot do. Treesitter-based, so it works wherever a parser is installed.
return {
  'ThePrimeagen/refactoring.nvim',
  -- async.nvim is a hard runtime dependency (refactoring.lua:45 requires 'async').
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter', 'lewis6991/async.nvim' },
  keys = {
    {
      '<leader>cr',
      function()
        require('refactoring').select_refactor()
      end,
      mode = { 'n', 'x' },
      desc = '[C]ode [R]efactor (select)',
    },
    {
      '<leader>cR',
      function()
        require('refactoring').debug.print_var()
      end,
      mode = { 'n', 'x' },
      desc = '[C]ode debug print va[R]',
    },
  },
  opts = {},
}
