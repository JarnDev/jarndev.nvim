-- Per-project LSP/plugin settings via `.neoconf.json`. Must be set up BEFORE any
-- vim.lsp.config() call, which is why lspconfig.lua also lists it as a dependency and
-- calls require('neoconf').setup() as the first line of its config function.
return {
  'folke/neoconf.nvim',
  cmd = 'Neoconf',
  keys = {
    { '<leader>cN', '<cmd>Neoconf<cr>', desc = '[C]ode: [N]eoconf project settings' },
  },
  opts = {},
}
