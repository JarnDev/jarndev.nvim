return {
  'mistweaverco/kulala.nvim',
  ft = { 'http', 'rest' },
  opts = {},
  keys = {
    { '<leader>rr', function() require('kulala').run() end, ft = 'http', desc = '[R]un HTTP request' },
    { '<leader>rR', function() require('kulala').run_all() end, ft = 'http', desc = '[R]un all HTTP requests' },
    { '<leader>re', function() require('kulala').set_selected_env() end, ft = 'http', desc = 'HTTP s[E]t environment' },
    { '<leader>ri', function() require('kulala').inspect() end, ft = 'http', desc = 'HTTP [I]nspect request' },
  },
}
