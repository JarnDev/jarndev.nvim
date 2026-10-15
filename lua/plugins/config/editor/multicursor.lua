-- Multiple cursors, for edits an LSP rename cannot express. While cursors exist, <Esc>
-- clears them and <Left>/<Right> hop between them.
return {
  'jake-stewart/multicursor.nvim',
  branch = '1.0',
  keys = {
    {
      '<C-Up>',
      function()
        require('multicursor-nvim').lineAddCursor(-1)
      end,
      mode = { 'n', 'x' },
      desc = 'Multicursor: add above',
    },
    {
      '<C-Down>',
      function()
        require('multicursor-nvim').lineAddCursor(1)
      end,
      mode = { 'n', 'x' },
      desc = 'Multicursor: add below',
    },
    {
      '<leader>n',
      function()
        require('multicursor-nvim').matchAddCursor(1)
      end,
      mode = { 'n', 'x' },
      desc = 'Multicursor: add next match',
    },
    {
      '<leader>N',
      function()
        require('multicursor-nvim').matchSkipCursor(1)
      end,
      mode = { 'n', 'x' },
      desc = 'Multicursor: skip this match',
    },
  },
  config = function()
    local mc = require 'multicursor-nvim'
    mc.setup()
    mc.addKeymapLayer(function(set)
      set({ 'n', 'x' }, '<Left>', mc.prevCursor)
      set({ 'n', 'x' }, '<Right>', mc.nextCursor)
      set({ 'n', 'x' }, '<leader>X', mc.deleteCursor) -- <leader>x stays trouble's
      set('n', '<Esc>', function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end)
    end)
  end,
}
