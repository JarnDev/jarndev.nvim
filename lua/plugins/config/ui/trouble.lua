return {
  'folke/trouble.nvim',
  cmd = 'Trouble',
  opts = {},
  keys = {
    { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Workspace Diagnostics' },
    { '<leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Document Diagnostics' },
    { '<leader>xq', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix List' },
    { '<leader>xl', '<cmd>Trouble loclist toggle<cr>', desc = 'Location List' },
    { '<leader>xs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols' },
    { ']x', function() require('trouble').next({ skip_groups = true, jump = true }) end, desc = 'Next Trouble item' },
    { '[x', function() require('trouble').prev({ skip_groups = true, jump = true }) end, desc = 'Previous Trouble item' },
  },
}
