-- Jump to a window by letter. Also used by neo-tree's `open_with_window_picker`
-- mappings, which are already in neo-tree's defaults but inert without this plugin.
return {
  's1n7ax/nvim-window-picker',
  name = 'window-picker',
  version = '2.*',
  event = 'VeryLazy',
  opts = {
    hint = 'floating-big-letter',
    filter_rules = {
      include_current_win = false,
      autoselect_one = true,
      bo = {
        filetype = { 'neo-tree', 'neo-tree-popup', 'notify', 'snacks_dashboard' },
        buftype = { 'terminal', 'quickfix' },
      },
    },
  },
  keys = {
    {
      '<leader>wp',
      function()
        local win = require('window-picker').pick_window()
        if win then
          vim.api.nvim_set_current_win(win)
        end
      end,
      desc = '[W]indow [P]ick',
    },
  },
}
