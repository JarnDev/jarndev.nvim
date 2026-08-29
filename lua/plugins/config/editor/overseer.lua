-- Task runner: build/watch/lint tasks with a results UI, wired into the quickfix.
return {
  'stevearc/overseer.nvim',
  cmd = { 'OverseerRun', 'OverseerToggle', 'OverseerQuickAction', 'OverseerInfo' },
  keys = {
    { '<leader>oo', '<cmd>OverseerToggle<cr>', desc = 'Overseer: t[O]ggle task list' },
    { '<leader>or', '<cmd>OverseerRun<cr>', desc = 'Overseer: [R]un task' },
    { '<leader>oa', '<cmd>OverseerQuickAction<cr>', desc = 'Overseer: quick [A]ction' },
    { '<leader>oi', '<cmd>OverseerInfo<cr>', desc = 'Overseer: [I]nfo' },
  },
  opts = {
    task_list = { direction = 'bottom', min_height = 12 },
  },
}
