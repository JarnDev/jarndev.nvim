-- REPL for Python (IPython when installed) and Node in a split on the right. Group
-- <leader>e ("eval"); the REPL is a real terminal, you can also type into it.
--
-- <leader>ep / <leader>ej start Python / Node from anywhere (a markdown note, the
-- dashboard, a Lua file...). A buffer that has no REPL of its own gets attached to the
-- one just opened, so the send keys (line, selection, motion, cell) work from it too.
-- In a .py / .js / .ts file the send keys go to that language's REPL, started on the
-- first send.
local function core()
  return require 'iron.core'
end

-- languages with a REPL of their own; everything else attaches to one
local OWN = { python = true, javascript = true, typescript = true }

local function has_repl()
  return OWN[vim.bo.filetype] or (vim.b.repl ~= nil and require('iron.lowlevel').repl_exists(vim.b.repl))
end

-- run a send/control action only where it has a REPL to talk to
local function guard(fn)
  return function()
    if not has_repl() then
      return vim.notify('Sem REPL aqui: <leader>ep (Python) ou <leader>ej (Node)', vim.log.levels.WARN)
    end
    fn()
  end
end

--- Open (or jump to) the `lang` REPL from any buffer and start typing in it.
local function open(lang)
  return function()
    local buf = vim.api.nvim_get_current_buf()
    if not OWN[vim.bo[buf].filetype] and vim.bo[buf].buftype == '' then
      core().attach(lang, buf) -- creates the REPL when needed
    end
    core().focus_on(lang)
    vim.cmd 'startinsert'
  end
end

-- <leader>er: show/hide this buffer's REPL; ask which one when it has none yet
local function toggle()
  if OWN[vim.bo.filetype] then
    return vim.cmd 'IronRepl'
  end
  local meta = vim.b.repl
  if meta and require('iron.lowlevel').repl_exists(meta) then
    local win = vim.fn.bufwinid(meta.bufnr)
    if win ~= -1 then
      return vim.api.nvim_win_hide(win)
    end
    return core().repl_for(meta.ft)
  end
  vim.ui.select({ 'python', 'node' }, { prompt = 'REPL' }, function(choice)
    if choice then
      open(choice == 'node' and 'javascript' or 'python')()
    end
  end)
end

return {
  'Vigemus/iron.nvim',
  cmd = { 'IronRepl', 'IronRestart', 'IronFocus', 'IronHide', 'IronAttach' },
  keys = {
    { '<leader>ep', open 'python', desc = 'REPL: [P]ython (from anywhere)' },
    { '<leader>ej', open 'javascript', desc = 'REPL: Node ([J]S, from anywhere)' },
    { '<leader>er', toggle, desc = 'REPL: show / hide this buffer’s REPL' },
    {
      '<leader>eR',
      guard(function()
        vim.cmd 'IronRestart'
      end),
      desc = 'REPL: [R]estart',
    },
    { '<leader>el', guard(function()
      core().send_line()
    end), desc = 'REPL: send [L]ine' },
    { '<leader>es', guard(function()
      core().visual_send()
    end), mode = 'x', desc = 'REPL: [S]end selection' },
    {
      '<leader>em',
      guard(function()
        core().run_motion 'send_motion'
      end),
      desc = 'REPL: send [M]otion (e.g. ap, ip, 3j)',
    },
    { '<leader>eu', guard(function()
      core().send_until_cursor()
    end), desc = 'REPL: send file [U]ntil the cursor' },
    { '<leader>ef', guard(function()
      core().send_file()
    end), desc = 'REPL: send [F]ile' },
    {
      '<leader>eb',
      guard(function()
        core().send_code_block(false)
      end),
      desc = 'REPL: send cell / [B]lock (# %%)',
    },
    {
      '<leader>en',
      guard(function()
        core().send_code_block(true)
      end),
      desc = 'REPL: send cell, go to the [N]ext',
    },
    {
      '<leader>ei',
      guard(function()
        core().send(nil, string.char(3))
      end),
      desc = 'REPL: [I]nterrupt (Ctrl-C)',
    },
    {
      '<leader>ec',
      guard(function()
        core().send(nil, string.char(12))
      end),
      desc = 'REPL: [C]lear the screen',
    },
    { '<leader>eq', guard(function()
      core().close_repl()
    end), desc = 'REPL: [Q]uit' },
  },
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
      -- the keys above are lazy.nvim keys, so they exist (and show in which-key)
      -- before iron loads
      keymaps = {},
      highlight = { italic = true },
    }
  end,
}
