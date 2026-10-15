-- Peek definitions / references / implementations in a floating list + editable preview,
-- without leaving the current buffer. Complements the snacks picker (gd/gr jump away)
-- and trouble (a docked list). Prefix `gl` = "glance".
local function glance(what)
  return function()
    vim.cmd('Glance ' .. what)
  end
end

return {
  'dnlhc/glance.nvim',
  cmd = 'Glance',
  keys = {
    { 'gld', glance 'definitions', desc = 'Glance definitions' },
    { 'glr', glance 'references', desc = 'Glance references' },
    { 'gli', glance 'implementations', desc = 'Glance implementations' },
    { 'glt', glance 'type_definitions', desc = 'Glance type definitions' },
  },
  opts = {
    border = { enable = true },
  },
}
