return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',
    'jay-babu/mason-nvim-dap.nvim',
  },
  keys = {
    { '<leader>db', desc = 'Toggle Breakpoint' },
    { '<leader>dc', desc = 'Continue' },
    { '<leader>du', desc = 'Toggle Debug UI' },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('nvim-dap-virtual-text').setup()
    require('dapui').setup()
    require('mason-nvim-dap').setup {
      automatic_setup = true,
      handlers = {},
      ensure_installed = {
        'python',
        'codelldb',
        'js-debug-adapter',
      },
    }

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
          return vim.fn.exepath 'python3'
        end,
      },
    }

    -- JS/TS configuration (js-debug-adapter)
    local js_debug = vim.fn.stdpath 'data' .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js'
    for _, adapter in ipairs { 'node', 'pwa-node', 'pwa-chrome' } do
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

    for _, lang in ipairs { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' } do
      dap.configurations[lang] = js_configs
    end

    -- C / C++ configuration (codelldb; bundles its own lldb, so no system gdb needed)
    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        command = vim.fn.exepath 'codelldb',
        args = { '--port', '${port}' },
      },
    }

    -- Compile the current file with debug symbols next to it and hand the binary to dap.
    -- Returning dap.ABORT cancels the session cleanly when the build fails.
    local function build_current_file()
      local src = vim.fn.expand '%:p'
      local out = vim.fn.expand '%:p:r'
      local cc = vim.bo.filetype == 'cpp' and 'g++' or 'gcc'
      local result = vim.system({ cc, '-g', '-O0', src, '-o', out }, { text = true }):wait()
      if result.code ~= 0 then
        vim.notify(result.stderr or 'build failed', vim.log.levels.ERROR, { title = cc .. ' failed' })
        return dap.ABORT
      end
      return out
    end

    local c_configs = {
      {
        name = 'Build & debug current file',
        type = 'codelldb',
        request = 'launch',
        program = build_current_file,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
      {
        name = 'Launch executable (prompt)',
        type = 'codelldb',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
    }

    dap.configurations.c = c_configs
    dap.configurations.cpp = c_configs
  end,
}
