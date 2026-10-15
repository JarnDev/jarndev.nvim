-- Claude Code (the CLI agent, on the Claude subscription) in a Neovim terminal, wired to
-- the current buffer / selection / diffs. Group <leader>ac.
return {
  'coder/claudecode.nvim',
  opts = {
    -- right, 30%: the code keeps most of the screen. edgy.lua docks it in the same
    -- place (its bottom slot would otherwise grab every snacks terminal).
    terminal = { split_side = 'right', split_width_percentage = 0.30 },
  },
  keys = {
    { '<leader>acc', '<cmd>ClaudeCode<cr>', desc = 'Toggle the Claude Code terminal' },
    { '<leader>acf', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus the Claude Code terminal' },
    { '<leader>acs', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send the selection' },
    { '<leader>acb', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add the current file' },
    { '<leader>aca', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept the proposed diff' },
    { '<leader>acd', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny the proposed diff' },
    { '<leader>acm', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Select the model' },
  },
}
