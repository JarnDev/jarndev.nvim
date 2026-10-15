-- Obsidian vault (~/git/vault, the Forgejo repo jarndev/vault) edited from nvim, no
-- Obsidian app needed: [[links]] with completion, backlinks, search, quick switch.
-- Group <leader>v.
--
-- It must not rewrite existing notes: no frontmatter is added on save, notes keep
-- their human titles as file names (the vault's convention: "EDA VISUALS.md"), the UI
-- layer stays off (render-markdown already renders), and new notes go to 00-Inbox.
local VAULT = vim.fn.expand '~/git/vault'

local function cmd(c)
  return '<cmd>Obsidian ' .. c .. '<cr>'
end

return {
  'obsidian-nvim/obsidian.nvim',
  version = '*',
  -- only for notes inside the vault, and the commands
  event = { 'BufReadPre ' .. VAULT .. '/*.md', 'BufNewFile ' .. VAULT .. '/*.md' },
  cmd = 'Obsidian',
  keys = {
    { '<leader>vo', cmd 'quick_switch', desc = 'Vault: [O]pen a note' },
    { '<leader>vs', cmd 'search', desc = 'Vault: [S]earch text' },
    { '<leader>vn', cmd 'new', desc = 'Vault: [N]ew note (00-Inbox)' },
    { '<leader>vb', cmd 'backlinks', desc = 'Vault: [B]acklinks of this note' },
    { '<leader>vl', cmd 'links', desc = 'Vault: [L]inks in this note' },
    { '<leader>vt', cmd 'tags', desc = 'Vault: [T]ags' },
    { '<leader>vr', cmd 'rename', desc = 'Vault: [R]ename note (updates links)' },
    { '<leader>vk', cmd 'link_new', mode = 'x', desc = 'Vault: lin[K] selection to a new note' },
    -- tasks are plain markdown checkboxes inside the notes; <CR> on one also toggles it
    { '<leader>vc', cmd 'toggle_checkbox', desc = 'Vault: toggle [C]heckbox' },
    {
      '<leader>vT',
      function()
        Snacks.picker.grep {
          title = 'Vault: open tasks',
          cwd = VAULT,
          search = '^\\s*[-*] \\[ \\]',
          regex = true,
          live = false,
          glob = { '*.md' },
        }
      end,
      desc = 'Vault: open [T]asks (every note)',
    },
  },
  opts = {
    legacy_commands = false,
    workspaces = { { name = 'vault', path = VAULT } },
    notes_subdir = '00-Inbox',
    new_notes_location = 'notes_subdir',
    -- file name = the title as typed (vault convention), a timestamp if no title
    note_id_func = function(title)
      return (title and title ~= '') and title or os.date '%Y-%m-%d %H%M'
    end,
    frontmatter = { enabled = false },
    templates = { enabled = false },
    picker = { name = 'snacks.picker' },
    completion = { min_chars = 2 },
    ui = { enable = false },
    footer = { enabled = false },
  },
}
