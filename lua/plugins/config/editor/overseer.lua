-- Task runner: build/watch/lint tasks with a results UI, wired into the quickfix.
return {
  'stevearc/overseer.nvim',
  cmd = { 'OverseerRun', 'OverseerToggle', 'OverseerOpen', 'OverseerClose', 'OverseerTaskAction', 'OverseerShell' },
  keys = {
    { '<leader>oo', '<cmd>OverseerToggle<cr>', desc = 'Overseer: t[O]ggle task list' },
    { '<leader>or', '<cmd>OverseerRun<cr>', desc = 'Overseer: [R]un task' },
    -- overseer v2 dropped :OverseerQuickAction (-> :OverseerTaskAction) and turned
    -- :OverseerInfo into a checkhealth section.
    { '<leader>oa', '<cmd>OverseerTaskAction<cr>', desc = 'Overseer: task [A]ction' },
    { '<leader>oi', '<cmd>checkhealth overseer<cr>', desc = 'Overseer: [I]nfo (checkhealth)' },
  },
  opts = {
    task_list = { direction = 'bottom', min_height = 12 },
  },
}
