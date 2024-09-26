return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    local Terminal = require('toggleterm.terminal').Terminal
    local lazygit = Terminal:new {
      cmd = 'lazygit',
      dir = 'git_dir',
      direction = 'float',
      float_opts = {
        border = 'double',
      },
      -- function to run on opening the terminal
      on_open = function(term)
        vim.cmd 'startinsert!'
        vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
      end,
      -- function to run on closing the terminal
      on_close = function(term)
        vim.cmd 'startinsert!'
      end,
    }

    local lazydocker = Terminal:new {
      cmd = 'lazydocker',
      dir = 'git_dir',
      direction = 'float',
      float_opts = {
        border = 'double',
      },
      -- function to run on opening the terminal
      on_open = function(term)
        vim.cmd 'startinsert!'
        vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
      end,
      -- function to run on closing the terminal
      on_close = function(term)
        vim.cmd 'startinsert!'
      end,
    }

    local lazyterminal = Terminal:new {
      dir = 'git_dir',
      direction = 'float',
      float_opts = {
        border = 'double',
      },

      on_open = function(term)
        vim.cmd 'startinsert!'
        vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
      end,
      -- function to run on closing the terminal
      on_close = function(term)
        vim.cmd 'startinsert!'
      end,
    }

    function _lazygit_toggle()
      lazygit:toggle()
    end

    function _lazydocker_toggle()
      lazydocker:toggle()
    end

    function _lazyterminal_toggle()
      lazyterminal:toggle()
    end

    vim.api.nvim_set_keymap('n', '<leader>lg', '<cmd>lua _lazygit_toggle()<CR>', { noremap = true, silent = true, desc = 'Open Lazy Git' })
    vim.api.nvim_set_keymap('n', '<leader>ld', '<cmd>lua _lazydocker_toggle()<CR>', { noremap = true, silent = true, desc = 'Open Lazy Docker' })
    vim.api.nvim_set_keymap('n', '<leader>lt', '<cmd>lua _lazyterminal_toggle()<CR>', { noremap = true, silent = true, desc = 'Open Lazy Terminal' })
  end,
}
