-- pandoc Lua filter for devdocs.nvim (editor/devdocs.lua): HTML -> GFM without raw HTML.
-- GFM pipe tables only hold one line of inline text per cell, so pandoc writes any other
-- table (cppreference puts every declaration in a <pre> inside a cell) as raw <table> HTML.
-- Declaration tables become a cpp code block; other tables stay pipe tables when they fit,
-- else become a bullet list. The rest repeats the plugin's own clean-up filter.

-- Text of a block list, keeping line breaks (stringify would fold them into spaces).
local function text(blocks)
  local out = {}
  pandoc.walk_block(pandoc.Div(blocks), {
    CodeBlock = function(el)
      table.insert(out, el.text)
    end,
    Str = function(el)
      table.insert(out, el.text)
    end,
    Code = function(el)
      table.insert(out, el.text)
    end,
    Space = function()
      table.insert(out, ' ')
    end,
    SoftBreak = function()
      table.insert(out, ' ')
    end,
    LineBreak = function()
      table.insert(out, '\n')
    end,
  })
  -- a <pre> in a cell arrives as plain text with no-break spaces
  return (table.concat(out):gsub('\194\160', ' '):gsub('^%s+', ''):gsub('%s+$', ''))
end

local function rows(tbl)
  local all = {}
  for _, row in ipairs(tbl.head.rows) do
    table.insert(all, row)
  end
  for _, body in ipairs(tbl.bodies) do
    for _, row in ipairs(body.head) do
      table.insert(all, row)
    end
    for _, row in ipairs(body.body) do
      table.insert(all, row)
    end
  end
  for _, row in ipairs(tbl.foot.rows) do
    table.insert(all, row)
  end
  return all
end

-- A `t-dcl` row is a declaration: its first cell is the code, the other cells (overload
-- number, "(since C++11)") a trailing comment. Other rows ("Defined in header <map>")
-- become comment lines of their own.
local function declarations(tbl)
  local lines = {}
  for _, row in ipairs(rows(tbl)) do
    local code, notes = nil, {}
    for i, cell in ipairs(row.cells) do
      if i == 1 and row.attr.classes:includes 't-dcl' then
        code = text(cell.contents)
      else
        local note = text(cell.contents)
        if note ~= '' then
          table.insert(notes, note)
        end
      end
    end
    local note = table.concat(notes, ' '):gsub('%s+', ' ')
    if code then
      table.insert(lines, note ~= '' and code .. '  // ' .. note or code)
    elseif note ~= '' then
      table.insert(lines, '// ' .. note)
    end
  end
  return #lines > 0 and pandoc.CodeBlock(table.concat(lines, '\n'), { class = 'cpp' }) or {}
end

local trailing = { LineBreak = true, SoftBreak = true, Space = true }

-- Drops row/cell attributes (a style on a <tr> alone makes the GFM writer fall back to
-- HTML) and the trailing <br>s cppreference pads header cells with. The rows come out
-- of the table as copies, so each list is written back.
local function clean(tbl)
  local function clean_rows(list)
    for r, row in ipairs(list) do
      local cells = row.cells
      for c, cell in ipairs(cells) do
        local blocks = cell.contents
        for b, block in ipairs(blocks) do
          if block.t == 'Plain' or block.t == 'Para' then
            local inlines = block.content
            while #inlines > 0 and trailing[inlines[#inlines].t] do
              inlines:remove()
            end
            block.content = inlines
            blocks[b] = block
          end
        end
        cell.contents = blocks
        cell.attr = pandoc.Attr()
        cells[c] = cell
      end
      row.cells = cells
      row.attr = pandoc.Attr()
      list[r] = row
    end
    return list
  end
  local head, foot, bodies = tbl.head, tbl.foot, tbl.bodies
  head.rows = clean_rows(head.rows)
  foot.rows = clean_rows(foot.rows)
  for i, body in ipairs(bodies) do
    body.head = clean_rows(body.head)
    body.body = clean_rows(body.body)
    bodies[i] = body
  end
  tbl.head, tbl.foot, tbl.bodies = head, foot, bodies
  tbl.attr = pandoc.Attr()
  -- explicit widths alone make pandoc fall back to HTML
  for i, spec in ipairs(tbl.colspecs) do
    tbl.colspecs[i] = { spec[1], pandoc.ColWidthDefault }
  end
  return tbl
end

-- A pipe table needs every cell to be at most one Plain/Para with no line break, no spans.
local function fits_pipe(tbl)
  for _, row in ipairs(rows(tbl)) do
    for _, cell in ipairs(row.cells) do
      if cell.row_span > 1 or cell.col_span > 1 or #cell.contents > 1 then
        return false
      end
      local block = cell.contents[1]
      if block and block.t ~= 'Plain' and block.t ~= 'Para' then
        return false
      end
      local broken = false
      if block then
        block:walk {
          LineBreak = function()
            broken = true
          end,
        }
      end
      if broken then
        return false
      end
    end
  end
  return true
end

local function as_list(tbl)
  local items = {}
  for _, row in ipairs(rows(tbl)) do
    local inlines = pandoc.Inlines {}
    for _, cell in ipairs(row.cells) do
      local cell_text = pandoc.utils.blocks_to_inlines(cell.contents, { pandoc.Space() }):walk {
        LineBreak = pandoc.Space,
      }
      if #cell_text > 0 and pandoc.utils.stringify(cell_text):match '%S' then
        if #inlines == 0 then
          inlines = pandoc.Inlines { pandoc.Strong(cell_text) }
        else
          inlines:extend { pandoc.Space(), pandoc.Str '—', pandoc.Space() }
          inlines:extend(cell_text)
        end
      end
    end
    if #inlines > 0 then
      table.insert(items, { pandoc.Plain(inlines) })
    end
  end
  return #items > 0 and pandoc.BulletList(items) or {}
end

function Table(el)
  if el.classes:includes 't-dcl-begin' then
    return declarations(el)
  end
  el = clean(el)
  return fits_pipe(el) and el or as_list(el)
end

-- <figure> (cppreference's inheritance diagrams) has no GFM form: keep just the image
function Figure(el)
  return el.content
end

function Div(el)
  return el.content
end

function Span(el)
  return el.content
end

function Para(el)
  if #el.content == 0 then
    return {}
  end
end

function Header(el)
  if #el.content == 0 then
    return {}
  end
end

function Link(el)
  if #el.content == 1 and el.content[1].text == el.target then
    return pandoc.Str(el.target)
  end
  -- a class or rel on the <a> makes the GFM writer keep it as raw HTML
  el.attr = pandoc.Attr()
  return el
end

-- 2<sup>n</sup> -> 2^n, x<sub>i</sub> -> x_i
function Superscript(el)
  return { pandoc.Str '^', table.unpack(el.content) }
end

function Subscript(el)
  return { pandoc.Str '_', table.unpack(el.content) }
end

-- width/height/class on an <img> make the GFM writer keep it as raw HTML
function Image(el)
  el.attr = pandoc.Attr()
  return el
end
