return {
  'CopilotC-Nvim/CopilotChat.nvim',
  branch = 'canary',
  dependencies = {
    { 'zbirenbaum/copilot.lua' },
    { 'nvim-lua/plenary.nvim' },
  },
  opts = {
    debug = false,
    show_help = 'yes',
    prompts = {
      Explain = 'Explain how the selected code works.',
      Review = 'Review the selected code and provide suggestions for improvement.',
      Tests = 'Generate unit tests for the selected code.',
      Fix = 'Fix the selected code and explain the fix.',
      Optimize = 'Optimize the selected code and explain the optimization.',
    },
  },
  cmd = {
    'CopilotChat',
    'CopilotChatExplain',
    'CopilotChatReview',
    'CopilotChatTests',
    'CopilotChatFix',
    'CopilotChatOptimize',
  },
} 