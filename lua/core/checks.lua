-- Project-wide checks as overseer tasks (<leader>or): typecheck / lint / build for
-- TypeScript-JavaScript, Python and C/C++. They run once, on demand, in the background,
-- and their errors land in the quickfix and open in trouble -- the cheap alternative to
-- making the LSP analyse a whole repo (keep: ~10k files) all the time.
--
-- Each tool's output is read with an errorformat; relative paths resolve against the
-- task cwd (the project root found from the current buffer).
local M = {}

local mason_bin = vim.fn.stdpath 'data' .. '/mason/bin/'

-- First executable that exists: project-local, then Mason, then PATH.
local function pick(candidates)
  for _, c in ipairs(candidates) do
    if c and vim.fn.executable(c) == 1 then
      return c
    end
  end
end

local function root(markers)
  local buf = vim.api.nvim_buf_get_name(0)
  return vim.fs.root(buf ~= '' and buf or vim.uv.cwd(), markers)
end

local EFM = {
  -- src/a.ts(3,7): error TS2322: Type 'string' is not assignable ...
  tsc = '%f(%l\\,%c): %trror TS%n: %m,%f(%l\\,%c): %tarning TS%n: %m',
  -- eslint "stylish": a file path line, then "  3:7  error  message  rule"
  eslint = '%-P%f,%\\s%#%l:%c%\\s%\\+%trror%\\s%\\+%m,%\\s%#%l:%c%\\s%\\+%tarning%\\s%\\+%m,%-Q,%-G%.%#',
  -- ruff --output-format=concise: path:line:col: CODE message
  ruff = '%f:%l:%c: %m',
  -- pyright: "  /abs/file.py:3:5 - error: message"
  pyright = '%\\s%#%f:%l:%c - %trror: %m,%\\s%#%f:%l:%c - %tarning: %m',
  -- gcc / clang
  gcc = '%f:%l:%c: %trror: %m,%f:%l:%c: fatal %trror: %m,%f:%l:%c: %tarning: %m,%-G%.%#',
}

-- default + parse with `efm` + quickfix + trouble when there is something to show
local function components(efm)
  return {
    'default',
    { 'on_output_parse', errorformat = efm },
    { 'on_result_diagnostics_quickfix', set_empty_results = true },
    'trouble_qflist',
  }
end

local TS_ROOT = { 'tsconfig.json', 'jsconfig.json' }
local ESLINT_ROOT =
  { 'eslint.config.js', 'eslint.config.mjs', 'eslint.config.cjs', 'eslint.config.ts', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.json', '.eslintrc' }
local PY_ROOT = { 'pyproject.toml', 'pyrightconfig.json', 'setup.py', 'setup.cfg', 'requirements.txt' }
local C_ROOT = { 'CMakeLists.txt', 'Makefile' }

M.templates = {
  {
    name = 'Check: typecheck TS/JS (tsc --noEmit)',
    condition = {
      callback = function()
        return root(TS_ROOT) ~= nil
      end,
    },
    builder = function()
      local dir = root(TS_ROOT)
      -- the project's own TypeScript; else the one bundled with Mason's ts server
      local tsc =
        pick { dir .. '/node_modules/.bin/tsc', vim.fn.stdpath 'data' .. '/mason/packages/typescript-language-server/node_modules/typescript/bin/tsc', 'tsc' }
      local config = vim.uv.fs_stat(dir .. '/tsconfig.json') and 'tsconfig.json' or 'jsconfig.json'
      return { cmd = { tsc, '--noEmit', '--pretty', 'false', '-p', config }, cwd = dir, components = components(EFM.tsc) }
    end,
  },
  {
    name = 'Check: lint JS/TS (eslint)',
    condition = {
      callback = function()
        return root(ESLINT_ROOT) ~= nil
      end,
    },
    builder = function()
      local dir = root(ESLINT_ROOT)
      local eslint = pick { dir .. '/node_modules/.bin/eslint', mason_bin .. 'eslint_d' }
      return { cmd = { eslint, '.', '--format', 'stylish' }, cwd = dir, components = components(EFM.eslint) }
    end,
  },
  {
    name = 'Check: typecheck Python (pyright)',
    condition = {
      callback = function()
        return root(PY_ROOT) ~= nil
      end,
    },
    builder = function()
      local dir = root(PY_ROOT)
      return { cmd = { pick { mason_bin .. 'pyright', 'pyright' } }, cwd = dir, components = components(EFM.pyright) }
    end,
  },
  {
    name = 'Check: lint Python (ruff)',
    condition = {
      callback = function()
        return root(PY_ROOT) ~= nil
      end,
    },
    builder = function()
      local dir = root(PY_ROOT)
      local ruff = pick { mason_bin .. 'ruff', 'ruff' }
      return { cmd = { ruff, 'check', '--output-format=concise', '.' }, cwd = dir, components = components(EFM.ruff) }
    end,
  },
  {
    name = 'Check: build C/C++ (cmake / make)',
    condition = {
      callback = function()
        return root(C_ROOT) ~= nil
      end,
    },
    builder = function()
      local dir = root(C_ROOT)
      local cmd
      if vim.uv.fs_stat(dir .. '/CMakeLists.txt') then
        -- configure once into build/ (also writes compile_commands.json for clangd)
        cmd = vim.uv.fs_stat(dir .. '/build/CMakeCache.txt') and 'cmake --build build'
          or 'cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build'
      else
        cmd = 'make -k' -- -k: keep going, so one run reports every broken file
      end
      return { cmd = cmd, cwd = dir, components = components(EFM.gcc) }
    end,
  },
}

function M.register()
  local overseer = require 'overseer'
  for _, t in ipairs(M.templates) do
    overseer.register_template(t)
  end
end

return M
