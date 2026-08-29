-- Generate a docstring for the function/class under the cursor (JSDoc, Google-style
-- Python, Doxygen for C/C++, ...). Uses LuaSnip, which blink.cmp already pulls in.
return {
  'danymat/neogen',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  cmd = 'Neogen',
  keys = {
    {
      '<leader>cd',
      function()
        require('neogen').generate()
      end,
      desc = '[C]ode [D]ocstring generate',
    },
  },
  opts = { snippet_engine = 'luasnip' },
}
