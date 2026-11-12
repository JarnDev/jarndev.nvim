-- hover.nvim provider: the cppreference page (explanation + example) for the C/C++
-- symbol under the cursor, read from the offline devdocs pages (editor/devdocs.lua).
-- clangd only shows the comments in the headers, which for the standard library is
-- mostly the signature.
--
-- The pages are indexed by their title ("# std::vector<T,Allocator>::push_back"), built
-- once per session. The scope comes from clangd's hover ("// In namespace std",
-- "// In vector<int>"); without it, every page whose last name part matches is offered.

local root = vim.fn.stdpath 'data' .. '/devdocs/docs/'

--- @type table<string, { last: table<string, {name: string, file: string}[]> }>
local indexes = {}

-- the pages are usable only once devdocs marked the set extracted: during the
-- extraction the folder already exists, half full, and would be indexed as it is
local function ready(slug)
  local ok, state = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath 'data' .. '/devdocs/state.json'), ''))
  end)
  return ok and type(state[slug]) == 'table' and state[slug].extracted == true
end

local requested = {}

-- first use on a new machine: start the download instead of only warning about it.
-- Loading devdocs runs its setup, whose ensure_installed (cpp, c) downloads and
-- extracts in the background; once devdocs is already loaded, that has run, so the
-- set is installed directly.
local function install(slug)
  if requested[slug] then
    return vim.notify(('cppreference: "%s" docs still downloading, try again when devdocs reports it done'):format(slug))
  end
  requested[slug] = true
  vim.notify(('cppreference: downloading the "%s" docs (~100 MB, converted with pandoc); try again when devdocs reports it done'):format(slug))
  local loaded = package.loaded['devdocs'] ~= nil
  require('lazy').load { plugins = { 'devdocs.nvim' } }
  if loaded then
    require('devdocs.docs').InstallDocs(slug)
  end
end

-- "std::basic_string<CharT,Traits,Allocator>::size" -> "std::basic_string::size"
local function strip_templates(s)
  local prev
  repeat
    prev = s
    s = s:gsub('%b<>', '')
  until s == prev
  return s
end

local function build(slug)
  local last = {}
  local dir = root .. slug
  for path, kind in vim.fs.dir(dir, { depth = 10 }) do
    if kind == 'file' and path:sub(-3) == '.md' then
      local file = dir .. '/' .. path
      local f = io.open(file)
      local title = f and f:read '*l'
      if f then
        f:close()
      end
      if title and title:sub(1, 2) == '# ' then
        title = title:sub(3):gsub('\\(.)', '%1')
        -- one page can document several names: "std::printf, std::fprintf, ..."
        for name in strip_templates(title):gmatch '[^,]+' do
          name = vim.trim(name):gsub('%s*%(.*$', '')
          local tail = name:match '([%w_~]+)$'
          if tail then
            last[tail] = last[tail] or {}
            table.insert(last[tail], { name = name, file = file })
          end
        end
      end
    end
  end
  return { last = last }
end

local function index(slug)
  indexes[slug] = indexes[slug] or build(slug)
  return indexes[slug]
end

-- scope clangd reports for the symbol: "std", "vector", "basic_string"... or nil
local function clangd_scope(bufnr, pos, cb)
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = 'clangd' })[1]
  if not client then
    return cb(nil)
  end
  local params = {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    position = { line = pos[1] - 1, character = vim.lsp.util.character_offset(bufnr, pos[1] - 1, pos[2], client.offset_encoding) },
  }
  client:request('textDocument/hover', params, function(_, res)
    local text = res and res.contents and (res.contents.value or res.contents) or ''
    local scope = type(text) == 'string' and text:match '// In namespace ([%w_:]+)' or nil
    if not scope and type(text) == 'string' then
      local cls = text:match '// In ([^\n]+)'
      scope = cls and strip_templates(cls):match '([%w_]+)%s*$'
    end
    cb(scope)
  end, bufnr)
end

-- best matches for `word` given the scope: exact scope first, then any page with that name
local function candidates(slug, word, scope)
  local all = index(slug).last[word] or {}
  if scope then
    local want = scope:match '([%w_]+)$'
    local hits = vim.tbl_filter(function(c)
      local parent = c.name:match '([%w_]+)::[%w_~]+$'
      return parent == want or c.name == scope .. '::' .. word
    end, all)
    if #hits > 0 then
      all = hits
    end
  end
  -- one entry per page: a page lists several names (size, length), and cppreference
  -- aliases are saved as copies (io/c/printf, io/c/fprintf...) that differ only in the
  -- source URL line
  local seen, out = {}, {}
  for _, c in ipairs(all) do
    local body = table.concat(
      vim.tbl_filter(function(l)
        return not l:match '^https://en%.cppreference%.com/'
      end, vim.fn.readfile(c.file)),
      '\n'
    )
    if not seen[body] then
      seen[body] = true
      table.insert(out, c)
    end
  end
  return out
end

-- page text with markdown links reduced to their label: the targets are relative
-- devdocs paths, of no use in a popup
local function page_lines(file)
  local text = table.concat(vim.fn.readfile(file), '\n')
  text = text:gsub('%[([^%[%]]-)%]%b()', '%1')
  return vim.split(text, '\n')
end

--- @type Hover.Provider
local provider = {
  name = 'cppreference',
  priority = 100,
  enabled = function(bufnr)
    return vim.bo[bufnr].filetype == 'c' or vim.bo[bufnr].filetype == 'cpp'
  end,
  execute = function(params, done)
    local slug = vim.bo[params.bufnr].filetype == 'c' and 'c' or 'cpp'
    if not ready(slug) then
      install(slug)
      return done(false)
    end
    local word = vim.fn.expand '<cword>'
    clangd_scope(params.bufnr, params.pos, function(scope)
      vim.schedule(function()
        local list = candidates(slug, word, scope)
        local function show(c)
          if not c then
            return done(false)
          end
          done { lines = page_lines(c.file), filetype = 'markdown' }
        end
        if #list == 0 then
          vim.notify(('cppreference: no page for "%s"'):format(word), vim.log.levels.INFO)
          return done(false)
        elseif #list == 1 then
          return show(list[1])
        end
        vim.ui.select(list, {
          prompt = 'cppreference',
          format_item = function(c)
            return c.name .. '  (' .. c.file:sub(#root + #slug + 2, -4) .. ')'
          end,
        }, show)
      end)
    end)
  end,
}

return provider
