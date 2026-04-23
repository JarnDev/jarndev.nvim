return {
  'MagicDuck/grug-far.nvim',
  cmd = 'GrugFar',
  opts = {},
  keys = {
    { '<leader>S', '<cmd>GrugFar<cr>', desc = '[S]earch & replace (grug-far)' },
    {
      '<leader>sR',
      function()
        local ext = vim.bo.filetype ~= '' and ('.' .. vim.bo.filetype) or ''
        require('grug-far').open { prefills = { search = vim.fn.expand '<cword>', filesFilter = '*' .. ext } }
      end,
      desc = '[S]earch & [R]eplace word under cursor',
    },
  },
}
