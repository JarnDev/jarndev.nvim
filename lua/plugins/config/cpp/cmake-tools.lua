-- CMake projects from inside nvim: configure, build, run and debug targets, pick the
-- build type. Group <leader>b. Builds into ./build (not cmake-tools' default
-- out/<type>) so neotest-ctest and the "Check: build C/C++" overseer task use the same
-- tree, and compile_commands.json is symlinked to the root for clangd.
local function cmd(c)
  return '<cmd>' .. c .. '<cr>'
end

-- :CMakeDebug passes itself as the callback of the build-type picker and ignores the
-- result, so with no CMakeLists.txt at cwd (or an Esc in the picker) it re-runs forever,
-- one toast per round. Do both checks here and only debug once a debuggable type is set.
local function debug()
  local cmake = require 'cmake-tools'
  if not cmake.is_cmake_project() then
    vim.notify('CMake: no CMakeLists.txt in ' .. cmake.get_config().cwd, vim.log.levels.WARN)
    return
  end
  local function debuggable()
    local build_type = cmake.get_build_type()
    return build_type ~= nil and require('cmake-tools.variants').debuggable(build_type, cmake.get_config().cwd)
  end
  if debuggable() then
    return vim.cmd 'CMakeDebug'
  end
  cmake.select_build_type(function(result)
    if not result:is_ok() then
      return
    elseif debuggable() then
      vim.cmd 'CMakeDebug'
    else
      vim.notify('CMake: ' .. cmake.get_build_type() .. ' has no debug info -- pick Debug or RelWithDebInfo', vim.log.levels.WARN)
    end
  end)
end

return {
  'Civitasv/cmake-tools.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  ft = { 'c', 'cpp', 'cuda', 'cmake' },
  cmd = { 'CMakeGenerate', 'CMakeBuild', 'CMakeRun', 'CMakeDebug', 'CMakeSelectBuildType', 'CMakeSelectBuildTarget', 'CMakeClean' },
  keys = {
    { '<leader>bg', cmd 'CMakeGenerate', desc = 'CMake: generate (configure)' },
    { '<leader>bb', cmd 'CMakeBuild', desc = 'CMake: build' },
    { '<leader>br', cmd 'CMakeRun', desc = 'CMake: run target' },
    { '<leader>bd', debug, desc = 'CMake: debug target' },
    { '<leader>bt', cmd 'CMakeSelectBuildType', desc = 'CMake: build type (Debug/Release)' },
    { '<leader>bT', cmd 'CMakeSelectLaunchTarget', desc = 'CMake: launch target' },
    { '<leader>bc', cmd 'CMakeClean', desc = 'CMake: clean' },
    -- not cmake-tools: the local Compiler Explorer in core/asm.lua
    { '<leader>ba', cmd 'Asm', ft = { 'c', 'cpp', 'cuda' }, desc = 'Assembly of this file (-O2; PTX for CUDA)' },
  },
  opts = {
    cmake_build_directory = 'build',
    cmake_use_preset = false,
    cmake_executor = { name = 'quickfix', opts = { show = 'only_on_error' } },
    -- codelldb is registered by autodap (editor/autodap.lua)
    cmake_dap_configuration = { name = 'cpp', type = 'codelldb', request = 'launch', stopOnEntry = false },
  },
}
