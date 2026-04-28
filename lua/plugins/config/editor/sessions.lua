return {
  'rmagatti/auto-session',
  lazy = false,
  opts = {
    suppressed_dirs = { '~/', '~/Downloads', '/', '/tmp' },
    bypass_save_filetypes = { 'alpha', 'dashboard' },
    pre_save_cmds = { 'Neotree close' },
    post_restore_cmds = { 'Neotree filesystem show' },
    session_lens = {
      picker_opts = { preset = 'select', preview = false },
    },
  },
  keys = {
    { '<leader>qs', '<cmd>AutoSession search<cr>', desc = 'Session Search' },
    { '<leader>qd', '<cmd>AutoSession delete<cr>', desc = 'Session Delete' },
  },
}
