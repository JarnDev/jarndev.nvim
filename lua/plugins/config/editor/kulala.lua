-- mistweaverco/kulala.nvim went private (the repo 404s). mrcjkb's fork kept its
-- history; `commit` pins the exact revision the config ran before, so the code is
-- unchanged. Drop the pin and repoint if a maintained continuation emerges.
return {
  'mrcjkb/kulala.nvim',
  commit = '232a9939919fe9bc88d573bce92de50f2f160c60',
  -- The `fmt` submodule points at mistweaverco/kulala-fmt, private too; it is
  -- the standalone formatter CLI, not runtime code, and would abort the clone.
  submodules = false,
  ft = { 'http', 'rest' },
  opts = {},
  keys = {
    {
      '<leader>rr',
      function()
        require('kulala').run()
      end,
      ft = 'http',
      desc = '[R]un HTTP request',
    },
    {
      '<leader>rR',
      function()
        require('kulala').run_all()
      end,
      ft = 'http',
      desc = '[R]un all HTTP requests',
    },
    {
      '<leader>re',
      function()
        require('kulala').set_selected_env()
      end,
      ft = 'http',
      desc = 'HTTP s[E]t environment',
    },
    {
      '<leader>ri',
      function()
        require('kulala').inspect()
      end,
      ft = 'http',
      desc = 'HTTP [I]nspect request',
    },
  },
}
