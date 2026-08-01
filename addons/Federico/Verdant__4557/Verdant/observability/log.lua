
Verdant = Verdant or {}
local Verdant = Verdant

Verdant.Log = {}
local M = Verdant.Log

local d        = d
local tostring = tostring
local concat   = table.concat

local ALIAS = {
  ["observability.diagnostics"] = "diag",
  ["core.engine"]               = "engine",
  ["core.metrics"]              = "metrics",
  ["core.probe"]                = "probe",
}

local function format_line(level, source, args, n)
  local prefix = "[" .. (ALIAS[source] or source) .. "]"
  if level ~= "info" then
    prefix = prefix .. " " .. level .. ":"
  end
  if n == 0 then return prefix end
  local body
  if n == 1 then body = tostring(args[1])
  elseif n == 2 then body = tostring(args[1]) .. " " .. tostring(args[2])
  else
    local parts = {}
    for i = 1, n do parts[i] = tostring(args[i]) end
    body = concat(parts, " ")
  end
  return prefix .. " " .. body
end

local function emit(level, source, ...)
  local debug_on = Verdant.Constants.DEBUG
  if not debug_on and level ~= "err" then return end
  local n = select("#", ...)
  local args = { ... }
  local line = format_line(level, source, args, n)
  if debug_on and Verdant.CopyBox then
    Verdant.CopyBox.append(line)
  elseif level == "err" then
    d(line)
  end
end


function M.info(source, ...) emit("info", source, ...) end
function M.warn(source, ...) emit("warn", source, ...) end
function M.err(source, ...)  emit("err",  source, ...) end

local Bound = {}
Bound.__index = Bound

function Bound:info(...) emit("info", self.source, ...) end
function Bound:warn(...) emit("warn", self.source, ...) end
function Bound:err(...)  emit("err",  self.source, ...) end

function M.for_module(source)
  return setmetatable({ source = source }, Bound)
end

local NOOP = function() end
M.write        = NOOP
M.flush        = function() return 0 end
M.clear        = NOOP
M.size         = function() return 0, 0 end
M.show_recent  = NOOP
M.recent_lines = function() return {} end

if not Verdant.Constants.DEBUG then return end

local RING_CAPACITY = 1024
local ring          = {}
local ring_head     = 0
local ring_count    = 0
local now_ms        = Verdant.zenimax.api.GetGameTimeMilliseconds

for i = 1, RING_CAPACITY do
  ring[i] = { t = 0, level = "", key = "", data = nil }
end

local function format_data(data)
  if data == nil then return "" end
  if type(data) ~= "table" then return tostring(data) end
  local parts = {}
  for k, v in pairs(data) do
    parts[#parts+1] = tostring(k) .. "=" .. tostring(v)
  end
  return table.concat(parts, " ")
end

function M.write(level, key, data)
  ring_head = (ring_head % RING_CAPACITY) + 1
  local rec = ring[ring_head]
  rec.t     = now_ms()
  rec.level = level
  rec.key   = key
  rec.data  = data
  ring_count = ring_count + 1
  if (level == "warn" or level == "error") and Verdant.CopyBox then
    local body = "[" .. level .. ":" .. key .. "]"
    if data ~= nil then
      body = body .. " " .. format_data(data)
    end
    Verdant.CopyBox.append(body)
  end
end

function M.flush()
  if not Verdant.SavedVars then return 0 end
  Verdant.SavedVars.debug = Verdant.SavedVars.debug or {}
  local out = {}
  if ring_count <= RING_CAPACITY then
    for i = 1, ring_count do
      local r = ring[i]
      out[#out+1] = { t = r.t, level = r.level, key = r.key, data = r.data }
    end
  else
    for i = 1, RING_CAPACITY do
      local idx = (ring_head + i - 1) % RING_CAPACITY + 1
      local r = ring[idx]
      out[#out+1] = { t = r.t, level = r.level, key = r.key, data = r.data }
    end
  end
  Verdant.SavedVars.debug.log = out
  return #out
end

function M.clear()
  ring_head  = 0
  ring_count = 0
end

function M.size()
  return math.min(ring_count, RING_CAPACITY), RING_CAPACITY
end

function M.recent_lines(n)
  n = n or 20
  local lines = {}
  local total = math.min(ring_count, RING_CAPACITY)
  local start_i = math.max(1, total - n + 1)
  for i = start_i, total do
    local idx
    if ring_count <= RING_CAPACITY then
      idx = i
    else
      idx = (ring_head + i - 1) % RING_CAPACITY + 1
    end
    local r = ring[idx]
    lines[#lines+1] = string.format("[%d %s:%s] %s",
      r.t, r.level, r.key, format_data(r.data))
  end
  return lines
end

function M.show_recent(n)
  local lines = M.recent_lines(n)
  if Verdant.CopyBox and Verdant.CopyBox.show then
    Verdant.CopyBox.show("Verdant /log show", table.concat(lines, "\n"))
  else
    for _, l in ipairs(lines) do d(l) end
  end
end
