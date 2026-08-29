-- Syntax-aware textobjects and motions (`main` branch, matching nvim-treesitter).
--
-- Two consumers:
--   1. mini.ai reads the `textobjects.scm` queries this plugin ships (via the builtin
--      `vim.treesitter.query.get()`), which is what makes `vaf`/`vic` work — see ui/mini.lua.
--   2. The `]f`/`[f`/`]c`/`[c` motions below, bound directly against the move module.
--
-- Loaded eagerly: mini.ai resolves queries at textobject time, so the runtimepath entry
-- has to already be there. (Deliberately NOT setting `vim.g.no_plugin_maps` as the README
-- suggests — that disables every builtin ftplugin mapping globally, and these bindings
-- don't collide with the builtin `]m`/`[m` anyway.)
return {
  'nvim-treesitter/nvim-treesitter-textobjects',
  branch = 'main',
  lazy = false,
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('nvim-treesitter-textobjects').setup {
      select = { lookahead = true },
      move = { set_jumps = true },
    }

    local move = require 'nvim-treesitter-textobjects.move'
    local motions = {
      [']f'] = { move.goto_next_start, '@function.outer', 'Next function start' },
      ['[f'] = { move.goto_previous_start, '@function.outer', 'Previous function start' },
      [']F'] = { move.goto_next_end, '@function.outer', 'Next function end' },
      ['[F'] = { move.goto_previous_end, '@function.outer', 'Previous function end' },
      -- ]c/[c are gitsigns' buffer-local hunk motions (which would win anyway), and
      -- ]]/[[ are snacks.words reference navigation, so class motions use ]C/[C.
      [']C'] = { move.goto_next_start, '@class.outer', 'Next class start' },
      ['[C'] = { move.goto_previous_start, '@class.outer', 'Previous class start' },
      [']a'] = { move.goto_next_start, '@parameter.inner', 'Next parameter' },
      ['[a'] = { move.goto_previous_start, '@parameter.inner', 'Previous parameter' },
    }
    for lhs, spec in pairs(motions) do
      local fn, query, desc = spec[1], spec[2], spec[3]
      vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
        fn(query, 'textobjects')
      end, { desc = desc })
    end

    -- Swap the argument under the cursor with its neighbour.
    local swap = require 'nvim-treesitter-textobjects.swap'
    vim.keymap.set('n', '<leader>cA', function()
      swap.swap_next '@parameter.inner'
    end, { desc = 'Swap parameter with next' })
    vim.keymap.set('n', '<leader>cP', function()
      swap.swap_previous '@parameter.inner'
    end, { desc = 'Swap parameter with previous' })
  end,
}
