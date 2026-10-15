return {
  'tpope/vim-dadbod',
  dependencies = {
    'kristijanhusak/vim-dadbod-ui',
    'kristijanhusak/vim-dadbod-completion',
  },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
    'DBUIRenameBuffer',
    'DBUILastQueryInfo',
  },
  -- group <leader>D; connections are saved by the UI (or come from $DB_UI_* / g:dbs)
  keys = {
    { '<leader>Dd', '<cmd>DBUIToggle<cr>', desc = 'DB: [D]rawer open / close' },
    { '<leader>Da', '<cmd>DBUIAddConnection<cr>', desc = 'DB: [A]dd a connection' },
    { '<leader>Df', '<cmd>DBUIFindBuffer<cr>', desc = 'DB: [F]ind this query buffer in the drawer' },
    { '<leader>Dl', '<cmd>DBUILastQueryInfo<cr>', desc = 'DB: [L]ast query info' },
  },
  init = function()
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_winwidth = 30
    vim.g.db_ui_winposition = 'right'
    vim.g.db_ui_use_nvim_notify = 1
  end,
}
