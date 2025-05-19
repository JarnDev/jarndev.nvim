-- Editor bootstrap settings
-- Settings that affect the editor's behavior and must be loaded early

-- Enable true colors if available
if vim.fn.has('termguicolors') == 1 then
  vim.opt.termguicolors = true
end

return {} 