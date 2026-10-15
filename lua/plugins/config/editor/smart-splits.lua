-- Window navigation and resizing that is aware of the terminal multiplexer.
-- In Neovim alone this behaves like <C-w>hjkl; crossing into adjacent *kitty* panes
-- additionally needs kitty-side config (the navigation kitten / pass_keys) -- see
-- os-custom-config/linux/. Without that it degrades gracefully to plain window nav.
-- edgy.nvim pins the size of the windows it docks (Claude Code, neo-tree, the bottom
-- bar): a plain resize is undone on the next layout pass. Those go through edgy's own
-- Window:resize, which stores the new size. `dir` is where the border moves (h/j/k/l),
-- the same meaning smart-splits gives <A-hjkl>.
local STEP = 3
local SIDE = { h = 'left', j = 'down', k = 'up', l = 'right' }

local function edgy_win(win)
  local ok, editor = pcall(require, 'edgy.editor')
  return ok and editor.get_win(win) or nil
end

local function resize(dir)
  local cur = vim.api.nvim_get_current_win()
  local ew = edgy_win(cur)
  if ew then
    local pos = ew.view.edgebar.pos
    local dim = (pos == 'left' or pos == 'right') and 'width' or 'height'
    -- the border facing the editor moves: towards it grows the pane, away shrinks it
    local grow = ({ right = 'h', left = 'l', bottom = 'k', top = 'j' })[pos]
    local shrink = ({ right = 'l', left = 'h', bottom = 'j', top = 'k' })[pos]
    if dir == grow or dir == shrink then
      return ew:resize(dim, dir == grow and STEP or -STEP)
    end
  else
    -- a code window next to an edgy pane: the shared border moves towards the pane
    -- (shrinks it), or -- when there is nothing on that side, the screen edge -- away
    -- from the pane on the other side (grows it), as smart-splits would do.
    local function edgy_dim(w)
      local pos = w.view.edgebar.pos
      return (pos == 'left' or pos == 'right') and 'width' or 'height'
    end
    local nb = vim.fn.win_getid(vim.fn.winnr(dir))
    local nw = nb ~= cur and edgy_win(nb) or nil
    if nw then
      return nw:resize(edgy_dim(nw), -STEP)
    end
    if nb == cur then
      local opp = vim.fn.win_getid(vim.fn.winnr(({ h = 'l', l = 'h', j = 'k', k = 'j' })[dir]))
      local ow = opp ~= cur and edgy_win(opp) or nil
      if ow then
        return ow:resize(edgy_dim(ow), STEP)
      end
    end
  end
  require('smart-splits')['resize_' .. SIDE[dir]]()
end

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
    -- <A-hjkl> also in terminal mode, so the Claude Code pane (and any :terminal) resizes
    -- without <C-\><C-n> first. Costs those four chords inside terminal programs.
    {
      '<A-h>',
      function()
        resize 'h'
      end,
      mode = { 'n', 't' },
      desc = 'Resize split left',
    },
    {
      '<A-j>',
      function()
        resize 'j'
      end,
      mode = { 'n', 't' },
      desc = 'Resize split down',
    },
    {
      '<A-k>',
      function()
        resize 'k'
      end,
      mode = { 'n', 't' },
      desc = 'Resize split up',
    },
    {
      '<A-l>',
      function()
        resize 'l'
      end,
      mode = { 'n', 't' },
      desc = 'Resize split right',
    },
  },
}
