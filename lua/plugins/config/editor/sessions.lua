return {
  'rmagatti/auto-session',
  lazy = false,
  opts = {
    suppressed_dirs = { '~/', '~/Downloads', '/', '/tmp' },
    bypass_save_filetypes = { 'alpha', 'dashboard' },
    pre_save_cmds = { 'Neotree close' },
    post_restore_cmds = { 'Neotree filesystem show' },
  },
  keys = {
    { '<leader>qs', '<cmd>SessionSearch<cr>', desc = 'Session Search' },
    { '<leader>qd', '<cmd>SessionDelete<cr>', desc = 'Session Delete' },
  },
}
