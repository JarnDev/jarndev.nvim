-- Markdown (also HTML, AsciiDoc, SVG) in the browser, updated as you type and
-- scrolled with the buffer. Pure Lua server on 127.0.0.1:5500: no Node, no build
-- step. Replaces markdown-preview.nvim, unmaintained since 2024.
return {
  'brianhuster/live-preview.nvim',
  cmd = 'LivePreview',
  keys = {
    {
      '<leader>mp',
      function()
        local lp = require 'livepreview'
        if lp.is_running() then
          lp.close() -- the plugin itself says "Server closed"
        else
          vim.cmd 'LivePreview start'
        end
      end,
      desc = '[M]arkdown [P]review in the browser (toggle)',
    },
  },
  config = function()
    require('livepreview.config').set { picker = 'snacks.picker', sync_scroll = true }
  end,
}
