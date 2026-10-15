-- GitHub Projects (v2) board in a picker, through the `gh` CLI. <leader>gj.
--
--   Enter   open the issue/PR in octo (draft issues: their body in a scratch buffer)
--   <C-s>   change the item's Status (Todo / In Progress / In Review / Done...)
--   <C-o>   open in the browser
--
-- Items are sorted the way the board reads (In Progress, In Review, Todo, Done) and
-- show Step/Size when the project has them, so typing "P2" or "Todo" filters.
--
-- Auth: gh runs WITHOUT $GITHUB_TOKEN, falling back to the keyring login -- the shell's
-- token lacks the `project` scope that Projects need.
local M = {}

M.owners = { 'JarnDev', 'jarndev-ltda' }
local STATUS_ORDER = { ['In Progress'] = 1, ['In Review'] = 2, Todo = 3, Done = 4 }
local last ---@type {owner:string, number:integer, title:string}?

local function gh(args, cb)
  vim.system(vim.list_extend({ 'env', '-u', 'GITHUB_TOKEN', 'gh' }, args), { text = true }, function(r)
    vim.schedule(function()
      if r.code ~= 0 then
        return vim.notify('gh: ' .. vim.trim(r.stderr or ''), vim.log.levels.ERROR)
      end
      local ok, data = pcall(vim.json.decode, r.stdout)
      cb(ok and data or r.stdout)
    end)
  end)
end

local function open_item(item)
  local c = item.content or {}
  if c.type == 'DraftIssue' then
    vim.cmd 'new'
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split('# ' .. item.title .. '\n\n' .. (c.body or ''), '\n'))
    vim.bo.buftype, vim.bo.bufhidden, vim.bo.filetype = 'nofile', 'wipe', 'markdown'
    return
  end
  local kind = c.type == 'PullRequest' and 'pr' or 'issue'
  if pcall(require, 'octo') then
    vim.cmd(('Octo %s edit %d %s'):format(kind, c.number, c.repository))
  else
    vim.ui.open(c.url)
  end
end

local function set_status(project, item, done)
  gh({ 'project', 'field-list', tostring(project.number), '--owner', project.owner, '--format', 'json' }, function(fields)
    local status
    for _, f in ipairs(fields.fields or {}) do
      if f.name == 'Status' then
        status = f
      end
    end
    if not status then
      return vim.notify('Este projeto não tem campo Status', vim.log.levels.WARN)
    end
    vim.ui.select(status.options, {
      prompt = item.title,
      format_item = function(o)
        return o.name .. (o.name == item.status and '  ●' or '')
      end,
    }, function(opt)
      if not opt then
        return
      end
      gh({ 'project', 'view', tostring(project.number), '--owner', project.owner, '--format', 'json' }, function(p)
        gh({
          'project',
          'item-edit',
          '--id',
          item.id,
          '--project-id',
          p.id,
          '--field-id',
          status.id,
          '--single-select-option-id',
          opt.id,
        }, function()
          vim.notify(('%s → %s'):format(item.title, opt.name))
          if done then
            done()
          end
        end)
      end)
    end)
  end)
end

function M.items(project)
  last = project
  gh({ 'project', 'item-list', tostring(project.number), '--owner', project.owner, '--format', 'json', '--limit', '500' }, function(data)
    local items = {}
    for _, it in ipairs(data.items or {}) do
      local c = it.content or {}
      local tags = table.concat(
        vim.tbl_filter(function(x)
          return x ~= nil
        end, { it.step, it.size }),
        ' '
      )
      local ref = c.number and ('%s#%d'):format((c.repository or ''):gsub('^.-/', ''), c.number) or 'draft'
      table.insert(items, {
        text = ('[%s] %s  %s  %s'):format(it.status or '—', tags, it.title, ref),
        item = it,
        preview = { text = '# ' .. it.title .. '\n\n' .. ref .. '  ·  ' .. (it.status or '') .. '\n\n' .. (c.body or ''), ft = 'markdown' },
        order = STATUS_ORDER[it.status] or 5,
      })
    end
    table.sort(items, function(a, b)
      return a.order ~= b.order and a.order < b.order or a.text < b.text
    end)
    Snacks.picker.pick {
      title = ('%s  (<C-s> status · <C-o> browser)'):format(project.title),
      items = items,
      format = 'text',
      preview = 'preview',
      confirm = function(picker, it)
        picker:close()
        if it then
          open_item(it.item)
        end
      end,
      actions = {
        set_status = function(picker, it)
          if it then
            picker:close()
            set_status(project, it.item, function()
              M.items(project)
            end)
          end
        end,
        browser = function(_, it)
          if it and it.item.content.url then
            vim.ui.open(it.item.content.url)
          end
        end,
      },
      win = {
        input = {
          keys = {
            ['<C-s>'] = { 'set_status', mode = { 'i', 'n' } },
            ['<C-o>'] = { 'browser', mode = { 'i', 'n' } },
          },
        },
      },
    }
  end)
end

--- Pick a project (open ones of the configured owners), then its board.
function M.pick(opts)
  opts = opts or {}
  if last and not opts.choose then
    return M.items(last)
  end
  local projects, pending = {}, #M.owners
  for _, owner in ipairs(M.owners) do
    gh({ 'project', 'list', '--owner', owner, '--format', 'json' }, function(data)
      for _, p in ipairs(type(data) == 'table' and data.projects or {}) do
        if not p.closed then
          table.insert(projects, { owner = owner, number = p.number, title = p.title, count = p.items and p.items.totalCount or 0 })
        end
      end
      pending = pending - 1
      if pending == 0 then
        vim.ui.select(projects, {
          prompt = 'GitHub Project',
          format_item = function(p)
            return ('%s  (%d itens · %s)'):format(p.title, p.count, p.owner)
          end,
        }, function(p)
          if p then
            M.items(p)
          end
        end)
      end
    end)
  end
end

return M
