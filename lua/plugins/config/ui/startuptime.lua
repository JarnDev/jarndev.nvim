return {
  'dstein64/vim-startuptime',
  cmd = 'StartupTime',
  keys = {
    { '<leader>us', '<cmd>StartupTime<cr>', desc = 'UI: [S]tartup time' },
  },
  init = function()
    vim.g.startuptime_tries = 10
  end,
}
