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
    'haydenmeade/neotest-jest',
  },
  config = function()
    require('neotest').setup({
      adapters = {
        require('neotest-python'),
        require('neotest-vim-test'),
        require('neotest-go'),
        require('neotest-jest')({
          jestCommand = 'npx jest',
          jestConfigFile = function(file)
            if string.find(file, '/packages/') then
              return string.match(file, '(.-/[^/]+/)src') .. 'jest.config.ts'
            end
            return vim.fn.getcwd() .. '/jest.config.ts'
          end,
          env = { CI = true },
          cwd = function()
            return vim.fn.getcwd()
          end,
        }),
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