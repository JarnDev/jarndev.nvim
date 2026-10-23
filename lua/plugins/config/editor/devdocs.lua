-- Offline documentation from devdocs.io (cppreference for C/C++ by default), browsed
-- with the snacks picker. Group <leader>i. More docs: <leader>ii, e.g. python~3.12,
-- javascript, typescript, node.

-- Replaces the plugin's HTML -> markdown step (one pandoc run per page). pandoc 3.11 reads
-- a bare <pre> as plain text with line breaks, so it gets a <code> to become a code block;
-- pandoc/devdocs.lua then turns the tables GFM can't hold into code blocks, pipe tables or
-- lists instead of raw HTML. Pages already extracted keep the old output until re-extracted:
-- :lua require('devdocs.docs').ExtractDocs('cpp')
local filter = vim.fn.stdpath 'config' .. '/pandoc/devdocs.lua'

local function convert(html, output, callback)
  -- cppreference tags C++ examples as "c" too
  local cpp = output:find('/docs/cpp/', 1, true) ~= nil
  html = html:gsub('<pre data%-language="([^"]*)">(.-)</pre>', function(lang, code)
    return ('<pre><code class="language-%s">%s</code></pre>'):format((cpp and lang == 'c') and 'cpp' or lang, code)
  end)
  vim.system({ 'pandoc', '-f', 'html', '-t', 'gfm', '--lua-filter=' .. filter, '-o', output }, { stdin = html }, function(res)
    if res.code ~= 0 then
      vim.schedule(function()
        vim.notify('DevDocs pandoc error (' .. output .. '): ' .. (res.stderr or 'unknown error'), vim.log.levels.WARN)
      end)
    end
    callback()
  end)
end

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
  config = function(_, opts)
    -- before setup: ensure_installed may start extracting right away
    require('devdocs.docs').ConvertHtmlToMarkdown = convert
    require('devdocs').setup(opts)
  end,
}
