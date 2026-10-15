-- Offline documentation from devdocs.io (cppreference for C/C++ by default), browsed
-- with the snacks picker. Group <leader>i. More docs: <leader>ii, e.g. python~3.12,
-- javascript, typescript, node.
return {
  'maskudo/devdocs.nvim',
  dependencies = { 'folke/snacks.nvim' },
  cmd = 'DevDocs',
  keys = {
    { '<leader>io', '<cmd>DevDocs get<cr>', desc = 'Docs: open (search an installed doc)' },
    { '<leader>ii', '<cmd>DevDocs install<cr>', desc = 'Docs: install a doc set' },
    {
      '<leader>iv',
      function()
        local devdocs = require 'devdocs'
        vim.ui.select(devdocs.GetInstalledDocs(), { prompt = 'Doc' }, function(doc)
          if doc then
            Snacks.picker.files { cwd = devdocs.GetDocDir(doc) }
          end
        end)
      end,
      desc = 'Docs: browse the files of a doc set',
    },
    { '<leader>id', '<cmd>DevDocs delete<cr>', desc = 'Docs: delete a doc set' },
  },
  opts = {
    -- downloaded once on first use (cppreference is the point; the rest on demand)
    ensure_installed = { 'cpp', 'c' },
  },
}
