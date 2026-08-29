-- Yank ring: cycle backwards through previous yanks with <C-p>/<C-n> right after pasting.
-- Loaded on VeryLazy (not on `p`) because the ring is built from TextYankPost -- lazy-loading
-- on paste alone would drop every yank made before the first paste.
return {
  'gbprod/yanky.nvim',
  event = 'VeryLazy',
  keys = {
    { 'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, desc = 'Put after' },
    { 'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, desc = 'Put before' },
    { 'gp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x' }, desc = 'Put after (cursor after)' },
    { 'gP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x' }, desc = 'Put before (cursor after)' },
    { '<C-p>', '<Plug>(YankyPreviousEntry)', desc = 'Yank ring: previous entry' },
    { '<C-n>', '<Plug>(YankyNextEntry)', desc = 'Yank ring: next entry' },
    {
      '<leader>p',
      function()
        local history = require('yanky.history').all()
        if #history == 0 then
          return vim.notify('Yank ring is empty', vim.log.levels.INFO)
        end
        vim.ui.select(history, {
          prompt = 'Yank ring',
          format_item = function(item)
            return (item.regcontents:gsub('\n', '\\n'):sub(1, 120))
          end,
        }, function(choice)
          if choice then
            vim.fn.setreg('"', choice.regcontents, choice.regtype)
            vim.cmd 'normal! ""p'
          end
        end)
      end,
      desc = '[P]aste from yank ring',
    },
  },
  opts = {
    highlight = { on_put = true, on_yank = true, timer = 200 },
    ring = { storage = 'shada' },
  },
}
