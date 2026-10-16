return {
  'folke/trouble.nvim',
  cmd = 'Trouble',
  opts = {
    -- the default preview ('main') covers the code window exactly, so it reads as a
    -- scroll, not a preview; a bordered popup on the right is visibly separate
    preview = {
      type = 'float',
      relative = 'editor',
      border = 'rounded',
      title = 'Preview',
      title_pos = 'center',
      position = { 0, -2 },
      size = { width = 0.45, height = 0.45 },
      zindex = 200,
    },
  },
  keys = {
    { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Workspace Diagnostics' },
    { '<leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Document Diagnostics' },
    { '<leader>xq', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix List' },
    { '<leader>xl', '<cmd>Trouble loclist toggle<cr>', desc = 'Location List' },
    { '<leader>xs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols' },
    {
      ']x',
      function()
        require('trouble').next { skip_groups = true, jump = true }
      end,
      desc = 'Next Trouble item',
    },
    {
      '[x',
      function()
        require('trouble').prev { skip_groups = true, jump = true }
      end,
      desc = 'Previous Trouble item',
    },
  },
}
