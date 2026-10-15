-- Breadcrumbs in the winbar: `src › services › user.ts › UserService › create()`, every
-- segment pickable (directories list their siblings, symbols their neighbours). Answers
-- "where am I" in a big tree. edgy turns the winbar off in its docked panes.
return {
  'Bekaboo/dropbar.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  keys = {
    {
      '<leader>;',
      function()
        require('dropbar.api').pick()
      end,
      desc = 'Breadcrumbs: pick a segment',
    },
    {
      '[;',
      function()
        require('dropbar.api').goto_context_start()
      end,
      desc = 'Go to start of current context',
    },
    {
      '];',
      function()
        require('dropbar.api').select_next_context()
      end,
      desc = 'Select next context',
    },
  },
  opts = {},
}
