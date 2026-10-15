-- REPL for Python (IPython when installed) and Node, in a split: send the line, the
-- selection, a paragraph or a `# %%` cell and see the result there. Group <leader>e
-- ("eval"). The REPL is a real terminal: you can also type into it.
return {
  'Vigemus/iron.nvim',
  ft = { 'python', 'javascript', 'typescript' },
  cmd = { 'IronRepl', 'IronRestart', 'IronFocus', 'IronHide' },
  config = function()
    local view = require 'iron.view'
    local common = require 'iron.fts.common'
    require('iron.core').setup {
      config = {
        scratch_repl = true,
        repl_definition = {
          python = {
            command = function()
              return vim.fn.executable 'ipython' == 1 and { 'ipython', '--no-autoindent' } or { 'python3' }
            end,
            format = common.bracketed_paste_python,
            block_dividers = { '# %%', '#%%' },
          },
          javascript = { command = { 'node' } },
          -- plain node: type annotations are not stripped in the REPL, keep TS snippets to JS
          typescript = { command = { 'node' } },
        },
        repl_open_cmd = view.split.vertical.botright(0.4),
      },
      keymaps = {
        toggle_repl = '<leader>er',
        restart_repl = '<leader>eR',
        send_line = '<leader>el',
        visual_send = '<leader>es',
        send_paragraph = '<leader>ep',
        send_code_block = '<leader>eb',
        send_code_block_and_move = '<leader>en',
        send_file = '<leader>ef',
        send_motion = '<leader>em',
        interrupt = '<leader>ei',
        clear = '<leader>ec',
        exit = '<leader>eq',
      },
      highlight = { italic = true },
    }
  end,
}
