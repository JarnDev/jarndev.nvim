return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-neotest/neotest-python',
    'nvim-neotest/neotest-vim-test',
    'nvim-neotest/neotest-go',
    'nvim-neotest/nvim-nio',
  },
  config = function()
    require('neotest').setup({
      adapters = {
        require('neotest-python'),
        require('neotest-vim-test'),
        require('neotest-go'),
      },
      status = { virtual_text = true },
      output = { open_on_run = true },
      quickfix = {
        open = function()
          vim.cmd('Trouble quickfix')
        end,
      },
    })

    -- Keymaps
    vim.keymap.set('n', '<leader>tt', function()
      require('neotest').run.run()
    end, { desc = 'Run nearest test' })

    vim.keymap.set('n', '<leader>tf', function()
      require('neotest').run.run(vim.fn.expand('%'))
    end, { desc = 'Run all tests in file' })

    vim.keymap.set('n', '<leader>td', function()
      require('neotest').run.run({ strategy = 'dap' })
    end, { desc = 'Debug nearest test' })

    vim.keymap.set('n', '<leader>ts', function()
      require('neotest').summary.toggle()
    end, { desc = 'Toggle test summary' })

    vim.keymap.set('n', '<leader>to', function()
      require('neotest').output.open({ enter = true })
    end, { desc = 'Show test output' })
  end,
}