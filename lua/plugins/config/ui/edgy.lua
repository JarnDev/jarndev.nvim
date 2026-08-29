-- Docks the sidebar/bottom windows into fixed slots so trouble, overseer, dap-ui and
-- neo-tree stop fighting each other for space.
--
-- Deliberately conservative: `animate = false` (snacks.scroll already animates), and
-- neo-tree is pinned left so auto-session's `Neotree close` / `Neotree filesystem show`
-- hooks keep working across a save/restore cycle.
return {
  'folke/edgy.nvim',
  event = 'VeryLazy',
  keys = {
    { '<leader>ue', '<cmd>EdgyToggle<cr>', desc = 'UI: toggle [E]dgy sidebars' },
  },
  opts = {
    animate = { enabled = false },
    wo = { winbar = false },
    bottom = {
      { ft = 'qf', title = 'QuickFix' },
      { ft = 'trouble', size = { height = 0.35 } },
      { ft = 'OverseerList', title = 'Tasks', size = { height = 0.3 } },
      {
        ft = 'help',
        size = { height = 0.4 },
        filter = function(buf)
          return vim.bo[buf].buftype == 'help'
        end,
      },
      { ft = 'snacks_terminal', size = { height = 0.35 } },
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
    },
    -- Never dock the dashboard or the AI chat panes.
    options = { left = { size = 34 }, bottom = { size = 12 }, right = { size = 50 } },
  },
}
