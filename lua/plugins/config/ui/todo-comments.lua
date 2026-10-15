-- TODO / FIXME / HACK / BUG / NOTE / PERF comments: highlighted, and navigable.
return {
  'folke/todo-comments.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = { signs = false },
  keys = {
    {
      '<leader>st',
      function()
        Snacks.picker.todo_comments()
      end,
      desc = '[S]earch [T]ODO/FIXME in the project',
    },
    { '<leader>xt', '<cmd>Trouble todo toggle<cr>', desc = 'TODO/FIXME list (trouble)' },
    {
      ']t',
      function()
        require('todo-comments').jump_next()
      end,
      desc = 'Next TODO comment',
    },
    {
      '[t',
      function()
        require('todo-comments').jump_prev()
      end,
      desc = 'Previous TODO comment',
    },
  },
}
