-- autodap.nvim -- zero-config debugging over nvim-dap (own plugin, developed in ~/git).
-- `dev = true` resolves it from lazy's `dev.path` instead of cloning; with
-- `dev.fallback` set in plugins/init.lua the same spec still works from GitHub on a
-- machine that has no local checkout.
return {
  'JarnDev/autodap.nvim',
  dev = true,
  dependencies = { 'mfussenegger/nvim-dap' },
  -- Kept lazy on purpose: `defaults.lazy = false` would otherwise load this -- and
  -- drag nvim-dap in with it -- at startup, undoing debug.lua's keys-based laziness.
  cmd = { 'AutodapContinue', 'AutodapReset' },
  -- Load on any filetype autodap handles (detect.lua's ft_to_lang), so its config
  -- provider is registered before you press anything -- a plain `<leader>dc`
  -- (dap.continue) then lists autodap's targets too, not just `<F5>`.
  ft = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'python',
    'c',
    'cpp',
    'objc',
    'objcpp',
    'cuda',
  },
  keys = {
    {
      '<F5>',
      function()
        require('autodap').continue()
      end,
      desc = 'Debug: autodap continue',
    },
    {
      '<leader>dC',
      function()
        require('autodap').continue()
      end,
      desc = 'Continue (autodap)',
    },
  },
  config = function()
    require('autodap').setup()
  end,
}
