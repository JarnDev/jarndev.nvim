-- Docks the sidebar/bottom windows into fixed slots so trouble, overseer, dap-ui and
-- neo-tree stop fighting each other for space.
--
-- Deliberately conservative: `animate = false` (snacks.scroll already animates), and
-- neo-tree is pinned left so auto-session's `Neotree close` / `Neotree filesystem show`
-- hooks keep working across a save/restore cycle.

-- claudecode.nvim opens Claude Code in a snacks terminal too; it gets its own slot on
-- the right (30%) instead of the bottom one every other terminal shares.
local function is_claude(buf)
  return vim.api.nvim_buf_get_name(buf):lower():find('claude', 1, true) ~= nil
end

-- edgy turns a floating window that matches a slot into a split. lazygit, lazydocker
-- and k9s are snacks terminals in a float, so the terminal slots skip floats (so does
-- trouble's, for its preview).
local function is_float(win)
  return vim.api.nvim_win_get_config(win).relative ~= ''
end

return {
  'folke/edgy.nvim',
  event = 'VeryLazy',
  keys = {
    -- edgy has no user commands; toggle() is its Lua API.
    {
      '<leader>ue',
      function()
        require('edgy').toggle()
      end,
      desc = 'UI: toggle [E]dgy sidebars',
    },
  },
  opts = {
    animate = { enabled = false },
    wo = { winbar = false },
    bottom = {
      { ft = 'qf', title = 'QuickFix' },
      {
        ft = 'trouble',
        size = { height = 0.35 },
        -- trouble's preview is a float over the code that starts with a trouble buffer;
        -- docked, it became a split that cut the code window in two
        filter = function(_, win)
          return not is_float(win)
        end,
      },
      { ft = 'OverseerList', title = 'Tasks', size = { height = 0.3 } },
      {
        ft = 'help',
        size = { height = 0.4 },
        filter = function(buf)
          return vim.bo[buf].buftype == 'help'
        end,
      },
      {
        ft = 'snacks_terminal',
        size = { height = 0.35 },
        filter = function(buf, win)
          return not is_claude(buf) and not is_float(win)
        end,
      },
      { ft = 'dap-repl', size = { height = 0.35 } },
    },
    left = {
      {
        ft = 'neo-tree',
        size = { width = 34 },
        filter = function(buf)
          return vim.b[buf].neo_tree_source == 'filesystem'
        end,
      },
    },
    right = {
      { ft = 'grug-far', title = 'Search / Replace', size = { width = 0.4 } },
      {
        ft = 'snacks_terminal',
        title = 'Claude Code',
        size = { width = 0.3 },
        filter = function(buf, win)
          return is_claude(buf) and not is_float(win)
        end,
      },
      -- sidekick.nvim (Pi, the local agent) opens on the right too
      {
        ft = 'sidekick_terminal',
        title = 'Pi (local)',
        size = { width = 0.3 },
        filter = function(_, win)
          return not is_float(win)
        end,
      },
    },
    -- Never dock the dashboard or the AI chat panes.
    options = { left = { size = 34 }, bottom = { size = 12 }, right = { size = 50 } },
  },
}
