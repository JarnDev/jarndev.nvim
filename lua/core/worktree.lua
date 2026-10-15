-- Git worktrees from inside nvim: several branches checked out side by side, e.g. one
-- per Claude Code session, without stashing or switching under each other.
--   <leader>gw  pick a worktree and switch to it (cd + reopen the same file if it exists)
--   <leader>gW  create one for a branch (new or existing) next to the repo, and switch
-- In the picker, <C-x> removes the selected worktree (asks first; git refuses if it has
-- uncommitted changes).
local M = {}

local function git(args, cwd)
  local r = vim.system(vim.list_extend({ 'git' }, args), { cwd = cwd, text = true }):wait()
  return r.code == 0, vim.trim(r.stdout or ''), vim.trim(r.stderr or '')
end

local function toplevel()
  local ok, out = git({ 'rev-parse', '--show-toplevel' }, vim.uv.cwd())
  return ok and out or nil
end

local function list()
  local ok, out = git({ 'worktree', 'list', '--porcelain' }, vim.uv.cwd())
  if not ok then
    return {}
  end
  local items, cur = {}, nil
  for line in (out .. '\n'):gmatch '([^\n]*)\n' do
    local path = line:match '^worktree (.+)'
    if path then
      cur = { path = path, branch = '(detached)' }
      table.insert(items, cur)
    elseif cur and line:match '^branch ' then
      cur.branch = line:match '^branch refs/heads/(.+)' or line:sub(8)
    elseif cur and line == 'bare' then
      cur.branch = '(bare)'
    end
  end
  return items
end

function M.switch(path)
  local root = toplevel()
  local rel = root and vim.fs.relpath(root, vim.api.nvim_buf_get_name(0))
  vim.cmd.cd(vim.fn.fnameescape(path))
  -- stop LSP clients rooted in the old tree; they restart on the next buffer
  for _, c in ipairs(vim.lsp.get_clients()) do
    c:stop()
  end
  local target = rel and vim.fs.joinpath(path, rel)
  if target and vim.uv.fs_stat(target) then
    vim.cmd.edit(vim.fn.fnameescape(target))
  else
    vim.cmd.edit(vim.fn.fnameescape(path))
  end
  vim.notify('worktree: ' .. path)
end

function M.pick()
  local cwd = vim.uv.cwd()
  local items = vim.tbl_map(function(w)
    local here = vim.fs.normalize(w.path) == vim.fs.normalize(toplevel() or cwd)
    return { text = ('%s  %s%s'):format(w.branch, w.path, here and '  ●' or ''), path = w.path, file = w.path }
  end, list())
  if #items == 0 then
    return vim.notify('worktree: não é um repositório git', vim.log.levels.WARN)
  end
  Snacks.picker.pick {
    title = 'Git worktrees  (<C-x> remove)',
    items = items,
    format = 'text',
    preview = 'none',
    layout = { preset = 'select' },
    confirm = function(picker, item)
      picker:close()
      if item then
        M.switch(item.path)
      end
    end,
    actions = {
      remove = function(picker, item)
        if not item then
          return
        end
        picker:close()
        vim.ui.select({ 'Não', 'Sim, remover' }, { prompt = 'Remover o worktree ' .. item.path .. '?' }, function(choice)
          if choice ~= 'Sim, remover' then
            return
          end
          local ok, _, err = git({ 'worktree', 'remove', item.path }, cwd)
          vim.notify(ok and ('worktree removido: ' .. item.path) or ('git recusou: ' .. err), ok and vim.log.levels.INFO or vim.log.levels.WARN)
        end)
      end,
    },
    win = { input = { keys = { ['<C-x>'] = { 'remove', mode = { 'i', 'n' } } } } },
  }
end

function M.create()
  local root = toplevel()
  if not root then
    return vim.notify('worktree: não é um repositório git', vim.log.levels.WARN)
  end
  vim.ui.input({ prompt = 'Branch do novo worktree: ' }, function(branch)
    if not branch or branch == '' then
      return
    end
    -- ../<repo>-<branch>, slashes in the branch name flattened
    local path = vim.fs.joinpath(vim.fs.dirname(root), vim.fs.basename(root) .. '-' .. branch:gsub('/', '-'))
    local exists = git({ 'rev-parse', '--verify', '--quiet', 'refs/heads/' .. branch }, root)
    local args = exists and { 'worktree', 'add', path, branch } or { 'worktree', 'add', '-b', branch, path }
    local ok, _, err = git(args, root)
    if not ok then
      return vim.notify('git worktree add falhou: ' .. err, vim.log.levels.ERROR)
    end
    M.switch(path)
  end)
end

return M
