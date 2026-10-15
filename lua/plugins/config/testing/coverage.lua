-- Covered / uncovered lines in the sign column, from the reports the test runners write:
--   jest:   --coverage                      -> coverage/lcov.info
--   pytest: --cov (pytest-cov)              -> .coverage (read via `coverage json`)
--   C/C++:  -O0 --coverage, run, lcov ...   -> report.info
local function load_or_toggle()
  local cov = require 'coverage'
  if vim.g.coverage_loaded then
    cov.toggle()
  else
    cov.load(true)
    vim.g.coverage_loaded = true
  end
end

return {
  'andythigpen/nvim-coverage',
  dependencies = { 'nvim-lua/plenary.nvim' },
  cmd = { 'Coverage', 'CoverageLoad', 'CoverageToggle', 'CoverageSummary', 'CoverageClear' },
  keys = {
    { '<leader>tc', load_or_toggle, desc = 'Coverage: show / toggle' },
    { '<leader>tC', '<cmd>CoverageSummary<cr>', desc = 'Coverage: summary' },
  },
  opts = { auto_reload = true },
}
