-- autodap.nvim -- zero-config debugging over nvim-dap (own plugin). Installed from
-- GitHub like any other plugin, pinned by lazy-lock. To try local, unpushed changes
-- from ~/git/autodap.nvim, add `dev = true` here for the session (lazy's `dev.path`
-- in plugins/init.lua points at ~/git).
return {
  'JarnDev/autodap.nvim',
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
