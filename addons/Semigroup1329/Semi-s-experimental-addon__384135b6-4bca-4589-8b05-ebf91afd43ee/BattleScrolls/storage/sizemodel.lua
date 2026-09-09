-- Memory model of stored data, in the units the console Add-On Memory gauge
-- charges. One shared model for the storage limit, the dialogs and the
-- settings tooltip.
--
-- The console keeps add-on Lua in a dlmalloc heap fed by separate 4 KiB
-- backing segments, each charged whole to the gauge (Xbox calibration of
-- 2026-09-09, docs/addon-memory-calib-results.md):
--   chunk   an allocation of r bytes occupies max(32, roundUp8(r + 8))
--   table   a 64-byte header (one chunk) plus, when it has entries, one
--           chunk of 40 bytes per hash node, nodes in powers of two.
--           SavedVariables files write every entry with an explicit key,
--           so loaded tables are hash-backed regardless of shape.
--   string  27 bytes plus the length (one chunk) plus 8 bytes for its slot
--           in the interning table, once per distinct value.
--   number, boolean: 0, stored inline in the slot.
--
-- Chunk bytes convert to gauge bytes through GAUGE_PER_CHUNK_BYTE: the
-- 72-byte foot of every 4096-byte segment, times the packing waste of a
-- mixed graph, measured at about 1% and taken as 1.5% to stay conservative.
-- Load-time garbage that stays interleaved in live segments is not modeled;
-- the eager collection before the SavedVariables load turns it into reuse.
BattleScrolls = BattleScrolls or {}

---@class SizeModel
---@field MIB number Bytes per MiB, the unit of the game's memory display
---@field SEGMENT number Bytes per backing segment, charged whole
---@field SEGMENT_FOOT number Bytes of each segment the heap keeps for itself
---@field PACKING_WASTE number Fraction of chunk bytes lost to segment tails in a mixed graph
---@field GAUGE_PER_CHUNK_BYTE number Gauge bytes per chunk byte
---@field VERSION number Bumped when the model changes, invalidating cached estimates
local sizeModel = {
    MIB = 1024 * 1024,
    SEGMENT = 4096,
    SEGMENT_FOOT = 72,
    PACKING_WASTE = 0.015,
    GAUGE_PER_CHUNK_BYTE = 0,
    VERSION = 3,
}
sizeModel.GAUGE_PER_CHUNK_BYTE = sizeModel.SEGMENT / (sizeModel.SEGMENT - sizeModel.SEGMENT_FOOT)
    * (1 + sizeModel.PACKING_WASTE)
BattleScrolls.sizeModel = sizeModel

local TABLE_HEADER = 64
local NODE_BYTES = 40
local STRING_HEADER = 27
local STRING_SLOT = 8
local CHUNK_OVERHEAD = 8
local MIN_CHUNK = 32

---Rounds up to the next power of two; 0 stays 0
---@param n number
---@return number
local function nextPow2(n)
    if n <= 0 then return 0 end
    local p = 1
    while p < n do p = p * 2 end
    return p
end

---Chunk bytes of one allocation of the given request size
---@param request number
---@return number bytes
function sizeModel.chunk(request)
    return math.max(MIN_CHUNK, math.ceil((request + CHUNK_OVERHEAD) / 8) * 8)
end

---Chunk bytes of a table's own header and nodes, without its contents
---@param entryCount number
---@return number bytes
function sizeModel.tableShell(entryCount)
    local bytes = sizeModel.chunk(TABLE_HEADER)
    if entryCount > 0 then
        bytes = bytes + sizeModel.chunk(NODE_BYTES * nextPow2(entryCount))
    end
    return bytes
end

---Chunk bytes of a stored value. Tables and strings reachable more than
---once count once per call; pass the same visited set to measure several
---roots as one graph.
---@param value any
---@param visited table<any, boolean>|nil
---@return number bytes
function sizeModel.measure(value, visited)
    local valueType = type(value)
    if valueType == "string" then
        visited = visited or {}
        if visited[value] then return 0 end
        visited[value] = true
        return sizeModel.chunk(STRING_HEADER + #value) + STRING_SLOT
    elseif valueType ~= "table" then
        return 0
    end
    visited = visited or {}
    if visited[value] then return 0 end
    visited[value] = true

    local entries, bytes = 0, 0
    for k, v in pairs(value) do
        entries = entries + 1
        bytes = bytes + sizeModel.measure(k, visited) + sizeModel.measure(v, visited)
    end
    return bytes + sizeModel.tableShell(entries)
end

---Gauge bytes of a stored value: chunk bytes times the segment factor
---@param value any
---@return number bytes
function sizeModel.gaugeBytes(value)
    return sizeModel.measure(value) * sizeModel.GAUGE_PER_CHUNK_BYTE
end
