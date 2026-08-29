-- Window navigation and resizing that is aware of the terminal multiplexer.
-- In Neovim alone this behaves like <C-w>hjkl; crossing into adjacent *kitty* panes
-- additionally needs kitty-side config (the navigation kitten / pass_keys) -- see
-- os-custom-config/linux/. Without that it degrades gracefully to plain window nav.
return {
  'mrjones2014/smart-splits.nvim',
  -- Copies neighboring_window.py / relative_resize.py / split_window.py into
  -- ~/.config/kitty/ -- the kittens the kitty.conf mappings call. See CLAUDE.md
  -- "Required Setup" for the kitty.conf side.
  build = './kitty/install-kittens.bash',
  -- Must NOT be lazy-loaded: the plugin sets kitty's `IS_NVIM` user-var on startup, and
  -- kitty's conditional mappings key off it to decide whether to forward <C-hjkl>.
  lazy = false,
  opts = {
    ignored_filetypes = { 'neo-tree', 'snacks_dashboard' },
    at_edge = 'stop',
  },
  keys = {
    {
      '<C-h>',
      function()
        require('smart-splits').move_cursor_left()
      end,
      desc = 'Move focus left',
    },
    {
      '<C-j>',
      function()
        require('smart-splits').move_cursor_down()
      end,
      desc = 'Move focus down',
    },
    {
      '<C-k>',
      function()
        require('smart-splits').move_cursor_up()
      end,
      desc = 'Move focus up',
    },
    {
      '<C-l>',
      function()
        require('smart-splits').move_cursor_right()
      end,
      desc = 'Move focus right',
    },
    {
      '<A-h>',
      function()
        require('smart-splits').resize_left()
      end,
      desc = 'Resize split left',
    },
    {
      '<A-j>',
      function()
        require('smart-splits').resize_down()
      end,
      desc = 'Resize split down',
    },
    {
      '<A-k>',
      function()
        require('smart-splits').resize_up()
      end,
      desc = 'Resize split up',
    },
    {
      '<A-l>',
      function()
        require('smart-splits').resize_right()
      end,
      desc = 'Resize split right',
    },
  },
}
