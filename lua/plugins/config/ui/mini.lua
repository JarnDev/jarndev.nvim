return {
  'echasnovski/mini.nvim',
  config = function()
    require('mini.ai').setup { n_lines = 500 }
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
