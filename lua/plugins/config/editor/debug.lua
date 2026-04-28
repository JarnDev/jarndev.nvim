return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',
    'jay-babu/mason-nvim-dap.nvim',
  },
  config = function()
    local dap = require('dap')
    local dapui = require('dapui')

    require('nvim-dap-virtual-text').setup()
    require('dapui').setup()
    require('mason-nvim-dap').setup({
      automatic_setup = true,
      handlers = {},
      ensure_installed = {
        'python',
        'delve',
        'js-debug-adapter',
      },
    })

    -- Keymaps
    vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Continue' })
    vim.keymap.set('n', '<leader>di', dap.step_into, { desc = 'Step Into' })
    vim.keymap.set('n', '<leader>do', dap.step_over, { desc = 'Step Over' })
    vim.keymap.set('n', '<leader>dO', dap.step_out, { desc = 'Step Out' })
    vim.keymap.set('n', '<leader>dr', dap.repl.toggle, { desc = 'Toggle REPL' })
    vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = 'Run Last' })
    vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = 'Toggle Debug UI' })
    vim.keymap.set('n', '<leader>dt', dap.terminate, { desc = 'Terminate' })

    -- Python configuration
    dap.adapters.python = {
      type = 'executable',
      command = 'python',
      args = { '-m', 'debugpy.adapter' },
    }

    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        pythonPath = function()
          return vim.fn.exepath('python3')
        end,
      },
    }

    -- JS/TS configuration (js-debug-adapter)
    local js_debug = os.getenv('HOME') .. '/.local/share/jarndev.nvim/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js'
    for _, adapter in ipairs({ 'node', 'pwa-node', 'pwa-chrome' }) do
      dap.adapters[adapter] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = 'node',
          args = { js_debug, '${port}' },
        },
      }
    end

    local js_configs = {
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        cwd = '${workspaceFolder}',
        sourceMaps = true,
      },
      {
        -- Run `npm run start:debug` in a terminal first, then use this.
        type = 'pwa-node',
        request = 'attach',
        name = 'Attach to NestJS (port 9229)',
        port = 9229,
        cwd = '${workspaceFolder}',
        sourceMaps = true,
        resolveSourceMapLocations = { '${workspaceFolder}/src/**', '!**/node_modules/**' },
        skipFiles = { '<node_internals>/**', 'node_modules/**' },
        restart = true, -- auto-reattach when watch mode restarts the process
      },
      {
        type = 'pwa-node',
        request = 'attach',
        name = 'Attach to process',
        processId = require('dap.utils').pick_process,
        cwd = '${workspaceFolder}',
        sourceMaps = true,
      },
    }

    for _, lang in ipairs({ 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' }) do
      dap.configurations[lang] = js_configs
    end

    -- Go configuration
    dap.adapters.delve = {
      type = 'server',
      port = '${port}',
      executable = {
        command = 'dlv',
        args = { 'dap', '-l', '127.0.0.1:${port}' },
      },
    }

    dap.configurations.go = {
      {
        type = 'delve',
        name = 'Debug',
        request = 'launch',
        program = '${file}',
      },
      {
        type = 'delve',
        name = 'Debug test',
        request = 'launch',
        mode = 'test',
        program = '${file}',
      },
    }
  end,
} 