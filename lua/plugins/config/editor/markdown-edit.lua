-- Editing helpers for markdown (markdown.nvim): lists that continue themselves,
-- inline styles as an operator, links, heading motions, task toggle and TOC.
-- Rendering stays with render-markdown; links between notes with obsidian.nvim.
--
-- Its default keys clash here, so they are moved: `gs` is mini.surround's prefix
-- (-> gS), `gl` is glance (-> gL), `]c` is gitsigns and `]]`/`[[` snacks.words
-- (-> ]h/[h), and `ds`/`cs` would eat flash's `s` in operator-pending mode (off).
local LIST_ITEM = { '^%s*[-*+]%s', '^%s*%d+[.)]%s' }

local function list_item(line)
  for _, p in ipairs(LIST_ITEM) do
    if line:match(p) then
      return true
    end
  end
end

-- a marker with nothing after it ("- ", "1. ", "- [ ] ")
local function empty_item(line)
  return line:match '^%s*[-*+]%s+%[.%]%s*$' or line:match '^%s*[-*+]%s*$' or line:match '^%s*%d+[.)]%s*$'
end

return {
  'tadmccorkle/markdown.nvim',
  ft = 'markdown',
  opts = {
    mappings = {
      inline_surround_toggle = 'gS',
      inline_surround_toggle_line = 'gSS',
      inline_surround_delete = false,
      inline_surround_change = false,
      link_add = 'gL',
      link_follow = 'gx',
      go_curr_heading = false,
      go_parent_heading = ']p',
      go_next_heading = ']h',
      go_prev_heading = '[h',
    },
    on_attach = function(buf)
      local function map(mode, lhs, rhs, desc, opts)
        vim.keymap.set(mode, lhs, rhs, vim.tbl_extend('force', { buffer = buf, desc = desc }, opts or {}))
      end
      -- o / O on a list item open a new item (same marker, numbering, `[ ]`)
      map('n', 'o', function()
        return list_item(vim.api.nvim_get_current_line()) and '<Cmd>MDListItemBelow<CR>' or 'o'
      end, 'New list item below (or plain o)', { expr = true })
      map('n', 'O', function()
        return list_item(vim.api.nvim_get_current_line()) and '<Cmd>MDListItemAbove<CR>' or 'O'
      end, 'New list item above (or plain O)', { expr = true })
      -- <CR> at the end of a list item continues the list; on an empty item it ends it
      map('i', '<CR>', function()
        local line = vim.api.nvim_get_current_line()
        if list_item(line .. ' ') and vim.fn.col '.' > #line then
          if empty_item(line) then
            vim.schedule(function()
              vim.api.nvim_set_current_line ''
            end)
            return ''
          end
          return vim.keycode '<Cmd>MDListItemBelow<CR>'
        end
        -- autopairs_cr() returns keys already encoded, hence replace_keycodes = false
        local ok, autopairs = pcall(require, 'nvim-autopairs')
        return ok and autopairs.autopairs_cr() or vim.keycode '<CR>'
      end, 'Continue the list', { expr = true, replace_keycodes = false })
      map({ 'n', 'x' }, '<leader>mx', ':MDTaskToggle<CR>', 'Markdown: toggle task [X]', { silent = true })
      map({ 'n', 'x' }, '<leader>mn', ':MDResetListNumbering<CR>', 'Markdown: re[N]umber ordered lists', { silent = true })
      map('n', '<leader>mt', '<Cmd>MDToc<CR>', 'Markdown: [T]able of contents (loclist)')
      map('n', '<leader>mT', '<Cmd>MDInsertToc<CR>', 'Markdown: insert a [T]able of contents')
    end,
  },
}
