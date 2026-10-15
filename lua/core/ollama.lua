-- Local Ollama models for minuet (FIM autocomplete) and codecompanion (local chat).
--
-- Which model is loaded matters: the 3080 has 10 GB, so one model at a time, and a cold
-- load takes ~35-60s (minuet gives up after 5s). So prefer whatever is already in VRAM,
-- and only load when needed.
--
-- Not every model can autocomplete: minuet asks for fill-in-the-middle, which Ollama
-- reports as the `insert` capability (only qwen2.5-coder here). Everything with
-- `completion` can chat; `embedding`-only models can do neither.
--
-- The choice lasts for the nvim session. OLLAMA_API_BASE (zshrc) points other machines
-- (the Mac) at the GPU box; unset means this machine.
local M = {}

M.base = vim.env.OLLAMA_API_BASE or 'http://localhost:11434'
M.fim_model = 'qwen2.5-coder:14b' -- autocomplete (needs `insert`)
M.chat_model = 'qwen2.5-coder:14b' -- codecompanion local chat
M.keep_alive = '15m' -- warm for a working session, without pinning the GPU
-- VRAM of the Ollama host (RTX 3080). The API does not report it, and from the Mac
-- nvidia-smi is not even there; used only to flag models that will spill into RAM.
M.vram_bytes = 10 * 1024 ^ 3

local caps_cache = {} ---@type table<string, string[]>

---@return table?, string?
local function request(method, path, body, timeout)
  local cmd = { 'curl', '-sf', '--max-time', tostring(timeout or 5), '-X', method, M.base .. path }
  if body then
    vim.list_extend(cmd, { '-d', vim.json.encode(body) })
  end
  local r = vim.system(cmd, { text = true }):wait()
  if r.code ~= 0 then
    return nil, ('curl %d em %s%s'):format(r.code, M.base, path)
  end
  local ok, decoded = pcall(vim.json.decode, r.stdout ~= '' and r.stdout or '{}')
  return ok and decoded or nil, not ok and 'resposta inválida' or nil
end

local function notify(msg, level)
  vim.schedule(function()
    vim.notify('AI local: ' .. msg, level or vim.log.levels.INFO)
  end)
end

--- Models installed on the server: { name, size } (size in bytes, on disk).
function M.tags()
  local d, err = request('GET', '/api/tags')
  if not d then
    return nil, err
  end
  return vim.tbl_map(function(m)
    return { name = m.name, size = m.size }
  end, d.models or {})
end

--- Names of the models currently in VRAM.
function M.loaded()
  local d = request('GET', '/api/ps', nil, 3)
  return vim.tbl_map(function(m)
    return m.name
  end, d and d.models or {})
end

function M.caps(name)
  if not caps_cache[name] then
    local d = request('POST', '/api/show', { model = name })
    caps_cache[name] = d and d.capabilities or {}
  end
  return caps_cache[name]
end

function M.can_fim(name)
  return vim.tbl_contains(M.caps(name), 'insert')
end

function M.can_chat(name)
  return vim.tbl_contains(M.caps(name), 'completion')
end

-- minuet reads its provider options on every request, so this takes effect at once.
local function set_minuet_model(name)
  M.fim_model = name
  local ok, minuet = pcall(require, 'minuet')
  if ok and minuet.config then
    minuet.config.provider_options.openai_fim_compatible.model = name
  end
end

--- Load a model in the background (an empty prompt only loads it).
function M.load(name, on_ready)
  local t0 = vim.uv.hrtime()
  notify('carregando ' .. name .. '...')
  vim.system({
    'curl',
    '-sf',
    '--max-time',
    '180',
    '-X',
    'POST',
    M.base .. '/api/generate',
    '-d',
    vim.json.encode { model = name, keep_alive = M.keep_alive },
  }, { text = true }, function(r)
    if r.code ~= 0 then
      return notify(('falhou ao carregar %s em %s (curl %d)'):format(name, M.base, r.code), vim.log.levels.WARN)
    end
    notify(('%s pronto (%.1fs)'):format(name, (vim.uv.hrtime() - t0) / 1e9))
    if on_ready then
      vim.schedule(on_ready)
    end
  end)
end

--- Drop every loaded model from VRAM now (keep_alive 0).
function M.unload()
  local loaded = M.loaded()
  if #loaded == 0 then
    return notify 'nenhum modelo carregado'
  end
  for _, name in ipairs(loaded) do
    vim.system({
      'curl',
      '-sf',
      '--max-time',
      '30',
      '-X',
      'POST',
      M.base .. '/api/generate',
      '-d',
      vim.json.encode { model = name, keep_alive = 0 },
    }, { text = true }, function(r)
      notify(
        r.code == 0 and (name .. ' descarregado da VRAM') or ('falhou ao descarregar ' .. name),
        r.code == 0 and vim.log.levels.INFO or vim.log.levels.WARN
      )
    end)
  end
end

--- Autocomplete: use a loaded FIM-capable model if there is one, otherwise load ours.
function M.ensure_fim()
  for _, name in ipairs(M.loaded()) do
    if M.can_fim(name) then
      set_minuet_model(name)
      return notify(name .. ' já carregado: autocomplete pronto')
    end
  end
  local busy = M.loaded()
  if #busy > 0 then
    notify(('%s não faz autocomplete; carregando %s (vai tirar %s da VRAM)'):format(busy[1], M.fim_model, table.concat(busy, ', ')), vim.log.levels.WARN)
  end
  set_minuet_model(M.fim_model)
  M.load(M.fim_model)
end

--- Local chat: a loaded chat-capable model if any (no swap), else the chosen one.
function M.chat_model_now()
  for _, name in ipairs(M.loaded()) do
    if M.can_chat(name) then
      return name
    end
  end
  return M.chat_model
end

--- Pick any installed model: becomes the chat model, and the autocomplete one when it
--- can do FIM; then it is loaded.
function M.pick()
  local models, err = M.tags()
  if not models then
    return notify('Ollama inacessível (' .. err .. ')', vim.log.levels.WARN)
  end
  local loaded = M.loaded()
  table.sort(models, function(a, b)
    return a.name < b.name
  end)
  vim.ui.select(models, {
    prompt = 'Modelo local (' .. M.base .. ')',
    format_item = function(m)
      local role = M.can_fim(m.name) and 'autocomplete + chat' or M.can_chat(m.name) and 'só chat' or 'não serve (embedding)'
      local flags = {}
      if vim.tbl_contains(loaded, m.name) then
        table.insert(flags, '● carregado')
      end
      if m.size > M.vram_bytes * 0.95 then
        table.insert(flags, 'não cabe na VRAM (lento)')
      end
      return ('%-28s %5.1f GB  %-22s %s'):format(m.name, m.size / 1024 ^ 3, role, table.concat(flags, ' · '))
    end,
  }, function(m)
    if not m then
      return
    end
    if not M.can_chat(m.name) then
      return notify(m.name .. ' não gera texto (embedding)', vim.log.levels.WARN)
    end
    M.chat_model = m.name
    if M.can_fim(m.name) then
      set_minuet_model(m.name)
      notify(m.name .. ' → chat e autocomplete')
    else
      notify(('%s → chat; autocomplete segue em %s (este não faz fill-in-the-middle)'):format(m.name, M.fim_model))
    end
    if not vim.tbl_contains(loaded, m.name) then
      M.load(m.name)
    end
  end)
end

return M
