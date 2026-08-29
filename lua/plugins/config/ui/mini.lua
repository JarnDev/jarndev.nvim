return {
  'echasnovski/mini.nvim',
  config = function()
    -- Treesitter-backed textobjects. mini.ai resolves these through the builtin
    -- `vim.treesitter.query.get(lang, 'textobjects')`, so the queries come from
    -- nvim-treesitter-textobjects (see treesitter/textobjects.lua).
    -- Note `f` is the function DEFINITION here (mini.ai's default `f` -- a function
    -- call -- moves to `u`, matching the common convention).
    local ai = require 'mini.ai'
    ai.setup {
      n_lines = 500,
      custom_textobjects = {
        f = ai.gen_spec.treesitter { a = '@function.outer', i = '@function.inner' },
        c = ai.gen_spec.treesitter { a = '@class.outer', i = '@class.inner' },
        o = ai.gen_spec.treesitter {
          a = { '@conditional.outer', '@loop.outer' },
          i = { '@conditional.inner', '@loop.inner' },
        },
        a = ai.gen_spec.treesitter { a = '@parameter.outer', i = '@parameter.inner' },
        u = ai.gen_spec.function_call(), -- mini.ai's original `f`
      },
    }
    -- Prefix `gs` so plain `s` is free for flash.nvim (no timeoutlen wait)
    require('mini.surround').setup {
      mappings = {
        add = 'gsa',
        delete = 'gsd',
        find = 'gsf',
        find_left = 'gsF',
        highlight = 'gsh',
        replace = 'gsr',
        update_n_lines = 'gsn',
      },
    }

    -- mini.statusline disabled: lualine.nvim is used instead
    -- mini.tabline disabled: bufferline.nvim is used instead

    -- Inline highlights for #rrggbb / #rgb and for TODO-style words. Chosen over
    -- nvim-colorizer / highlight-colors because mini.nvim is already loaded.
    local hipatterns = require 'mini.hipatterns'
    hipatterns.setup {
      highlighters = {
        hex_color = hipatterns.gen_highlighter.hex_color(),
      },
    }

    require('mini.move').setup {
      mappings = {
        left = '<M-D-h>',
        right = '<M-D-l>',
        down = '<M-D-j>',
        up = '<M-D-k>',
        line_left = '<M-D-h>',
        line_right = '<M-D-l>',
        line_down = '<M-D-j>',
        line_up = '<M-D-k>',
      },
      options = {
        reindent_linewise = true,
      },
    }
  end,
}
