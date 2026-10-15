-- clangd features the plain LSP client does not expose: AST of a range, type
-- hierarchy, symbol info, clangd's memory usage. Buffer keys on C/C++ only.
local function cmd(c)
  return '<cmd>' .. c .. '<cr>'
end

return {
  'p00f/clangd_extensions.nvim',
  ft = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
  opts = {},
  keys = {
    { '<leader>cH', cmd 'ClangdTypeHierarchy', ft = { 'c', 'cpp' }, desc = 'C++: type hierarchy' },
    { '<leader>cT', cmd 'ClangdAST', mode = { 'n', 'x' }, ft = { 'c', 'cpp' }, desc = 'C++: AST of line/selection' },
    { '<leader>cS', cmd 'ClangdSymbolInfo', ft = { 'c', 'cpp' }, desc = 'C++: symbol info' },
    { '<leader>cM', cmd 'ClangdMemoryUsage', ft = { 'c', 'cpp' }, desc = 'C++: clangd memory usage' },
    { '<leader>cs', cmd 'LspClangdSwitchSourceHeader', ft = { 'c', 'cpp' }, desc = 'C++: switch source/header' },
  },
}
