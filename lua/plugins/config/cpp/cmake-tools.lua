-- CMake projects from inside nvim: configure, build, run and debug targets, pick the
-- build type. Group <leader>b. Builds into ./build (not cmake-tools' default
-- out/<type>) so neotest-ctest and the "Check: build C/C++" overseer task use the same
-- tree, and compile_commands.json is symlinked to the root for clangd.
local function cmd(c)
  return '<cmd>' .. c .. '<cr>'
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
    { '<leader>bd', cmd 'CMakeDebug', desc = 'CMake: debug target' },
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
