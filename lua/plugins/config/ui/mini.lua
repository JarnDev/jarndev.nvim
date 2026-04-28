return {
  'echasnovski/mini.nvim',
  config = function()
    require('mini.ai').setup { n_lines = 500 }
    require('mini.surround').setup()
    
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