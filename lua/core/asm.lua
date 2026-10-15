-- :Asm [O0|O1|O2|O3|Os] -- the assembly of the current C/C++ file (PTX for CUDA), in a
-- split. A local
-- Compiler Explorer: the compile happens here, nothing is sent to godbolt.org.
--
-- Uses the file's real command from compile_commands.json when there is one (so
-- includes/defines/standard match the build), else plain gcc/g++. Output is Intel
-- syntax, demangled (c++filt), without the .cfi/.loc noise.
local M = {}

local function from_compile_commands(file)
  local root = vim.fs.root(file, 'compile_commands.json')
  if not root then
    return nil
  end
  local ok, db = pcall(vim.json.decode, table.concat(vim.fn.readfile(root .. '/compile_commands.json'), '\n'))
  if not ok then
    return nil
  end
  for _, e in ipairs(db) do
    -- `file` may be absolute (CMake writes it so) or relative to `directory`
    local path = vim.fs.normalize(e.file:sub(1, 1) == '/' and e.file or vim.fs.joinpath(e.directory, e.file))
    if path == file then
      local args = e.arguments or vim.split(e.command, '%s+', { trimempty = true })
      local out, skip = {}, false
      for _, a in ipairs(args) do
        if skip then
          skip = false
        elseif a == '-o' then
          skip = true
        elseif a ~= '-c' then
          table.insert(out, a)
        end
      end
      return out, e.directory
    end
  end
end

-- CUDA: PTX (the GPU's virtual ISA) for the RTX 3080 (sm_86), through nvcc.
local function show_ptx(file, opt)
  if vim.fn.executable 'nvcc' == 0 then
    return vim.notify('Asm: nvcc não encontrado -- instale o CUDA Toolkit', vim.log.levels.WARN)
  end
  local r = vim.system({ 'nvcc', '-' .. (opt ~= '' and opt or 'O2'), '-arch=sm_86', '-ptx', '-o', '-', file }, { text = true }):wait()
  if r.code ~= 0 then
    return vim.notify('Asm: nvcc falhou\n' .. r.stderr, vim.log.levels.ERROR)
  end
  vim.cmd 'vnew'
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(r.stdout, '\n'))
  vim.bo.buftype, vim.bo.bufhidden, vim.bo.swapfile, vim.bo.filetype = 'nofile', 'wipe', false, 'asm'
  vim.api.nvim_buf_set_name(0, ('ptx://%s (sm_86)'):format(vim.fs.basename(file)))
end

function M.show(opt)
  local file = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
  if vim.bo.filetype == 'cuda' then
    return show_ptx(file, opt)
  end
  local cpp = vim.bo.filetype == 'cpp'
  local args, cwd = from_compile_commands(file)
  if not args then
    args, cwd = { cpp and 'g++' or 'gcc', cpp and '-std=c++20' or '-std=c17', file }, vim.fs.dirname(file)
  end
  -- later -O wins, so the requested level overrides the build's
  vim.list_extend(args, { '-' .. (opt ~= '' and opt or 'O2'), '-S', '-masm=intel', '-fno-asynchronous-unwind-tables', '-fno-dwarf2-cfi-asm', '-g0', '-o', '-' })
  local r = vim.system(args, { cwd = cwd, text = true }):wait()
  if r.code ~= 0 then
    return vim.notify('Asm: a compilação falhou\n' .. r.stderr, vim.log.levels.ERROR)
  end
  local demangled = vim.system({ 'c++filt' }, { stdin = r.stdout, text = true }):wait().stdout or r.stdout
  local lines = vim.tbl_filter(function(l)
    -- keep instructions and labels, drop assembler directives
    return not l:match '^%s+%.' and l ~= ''
  end, vim.split(demangled, '\n'))
  vim.cmd 'vnew'
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.buftype, vim.bo.bufhidden, vim.bo.swapfile, vim.bo.filetype = 'nofile', 'wipe', false, 'asm'
  vim.api.nvim_buf_set_name(0, ('asm://%s (-%s)'):format(vim.fs.basename(file), opt ~= '' and opt or 'O2'))
end

function M.setup()
  vim.api.nvim_create_user_command('Asm', function(o)
    M.show(o.args)
  end, {
    nargs = '?',
    complete = function()
      return { 'O0', 'O1', 'O2', 'O3', 'Os' }
    end,
    desc = 'Assembly of the current C/C++ file',
  })
end

return M
