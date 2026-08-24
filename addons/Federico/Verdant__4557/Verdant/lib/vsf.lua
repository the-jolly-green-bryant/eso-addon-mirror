Verdant = Verdant or {}
Verdant.lib = Verdant.lib or {}

local M = {}
Verdant.lib.vsf = M

M.VERSION   = 1
M.CHUNK_MAX = 1800
M.CHK_WIDTH = 4

local ALPHABET = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz._"
M.ALPHABET = ALPHABET

local string_sub    = string.sub
local string_byte   = string.byte
local table_concat  = table.concat
local math_floor    = math.floor

local CHAR_OF = {}
local VAL_OF  = {}
for i = 1, 64 do
  local ch = string_sub(ALPHABET, i, i)
  CHAR_OF[i - 1] = ch
  VAL_OF[string_byte(ch)] = i - 1
end

local CHK_MOD = 64 ^ M.CHK_WIDTH

function M.encode_uint(v, w)
  if type(v) ~= "number" or v ~= v then v = 0 end
  v = math_floor(v + 0.5)
  if v < 0 then v = 0 end
  local max = 64 ^ w - 1
  if v > max then v = max end
  local out = {}
  for i = w, 1, -1 do
    out[i] = CHAR_OF[v % 64]
    v = math_floor(v / 64)
  end
  return table_concat(out)
end

function M.decode_uint(s, pos, w)
  local v = 0
  for i = pos, pos + w - 1 do
    local d = VAL_OF[string_byte(s, i)]
    if d == nil then return nil end
    v = v * 64 + d
  end
  return v
end

local function checksum(blob)
  local sum = 0
  for i = 1, #blob do
    sum = (sum * 67 + string_byte(blob, i)) % CHK_MOD
  end
  return M.encode_uint(sum, M.CHK_WIDTH)
end

M.checksum = checksum

local function record_len(desc)
  local rlen = 0
  for i = 1, #desc do
    rlen = rlen + desc[i].width
  end
  return rlen
end

function M.pack(records, desc)
  local n = #records
  local rlen = record_len(desc)
  local parts = {}
  local prev = {}
  local warnings = 0
  for r = 1, n do
    local rec = records[r]
    for f = 1, #desc do
      local d = desc[f]
      local v = rec[d.name] or 0
      if d.scale then v = v * d.scale end
      if d.delta then
        local raw = v
        v = v - (prev[f] or 0)
        prev[f] = raw
        if v < 0 then
          v = 0
          warnings = warnings + 1
        end
      end
      parts[#parts + 1] = M.encode_uint(v, d.width)
    end
  end
  local blob = table_concat(parts)
  local data = {}
  for i = 1, #blob, M.CHUNK_MAX do
    data[#data + 1] = string_sub(blob, i, i + M.CHUNK_MAX - 1)
  end
  return {
    n    = n,
    rlen = rlen,
    chk  = checksum(blob),
    data = data,
  }, warnings
end

function M.unpack(stream, desc)
  if type(stream) ~= "table" or type(stream.n) ~= "number"
     or type(stream.rlen) ~= "number" or type(stream.data) ~= "table" then
    return nil, "malformed stream container"
  end
  local rlen = record_len(desc)
  if stream.rlen ~= rlen then
    return nil, "descriptor rlen mismatch: stream=" .. stream.rlen .. " desc=" .. rlen
  end
  local blob = table_concat(stream.data)
  if #blob ~= stream.n * rlen then
    return nil, "length mismatch: expected " .. (stream.n * rlen) .. " got " .. #blob
  end
  if checksum(blob) ~= stream.chk then
    return nil, "checksum mismatch"
  end
  local records = {}
  local pos = 1
  local prev = {}
  for r = 1, stream.n do
    local rec = {}
    for f = 1, #desc do
      local d = desc[f]
      local v = M.decode_uint(blob, pos, d.width)
      if v == nil then
        return nil, "invalid character in record " .. r
      end
      pos = pos + d.width
      if d.delta then
        v = v + (prev[f] or 0)
        prev[f] = v
      end
      if d.scale then v = v / d.scale end
      rec[d.name] = v
    end
    records[r] = rec
  end
  return records
end
