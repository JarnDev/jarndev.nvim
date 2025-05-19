return {
  'echasnovski/mini.nvim',
  config = function()
    require('mini.ai').setup { n_lines = 500 }
    require('mini.surround').setup()
    
    local statusline = require 'mini.statusline'
    statusline.setup { use_icons = vim.g.have_nerd_font }
    statusline.section_location = function()
      return '%2l:%-2v'
    end

    require('mini.tabline').setup()
    vim.keymap.set('n', '<leader><Tab>h', ':bprevious<CR>', { desc = 'Go to previous buffer' })
    vim.keymap.set('n', '<leader><Tab>l', ':bnext<CR>', { desc = 'Go to next buffer' })
    vim.keymap.set('n', '<leader><Tab>d', ':bdelete<CR>', { desc = 'Delete current buffer' })
    vim.keymap.set('n', '<leader><Tab>D', ':bdelete!<CR>', { desc = 'Delete current buffer forcefully' })

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