-----------------------------------------------------------
-- Memory Diagnostics
-- Console-readable instrumentation for the Add-On Memory gauge
-- investigation: the gauge attributes ~2.5x what the settings screen's
-- history estimate claims, and this module exists to split that gap into
-- measurable parts (see the settings screen's Memory Diagnostics section).
--
-- Three distinct meters, none interchangeable:
--   - the console Add-On Memory gauge: engine-side, allocator-level, counts
--     code + UI + libs + loaded SavedVariables + allocator rounding
--   - collectgarbage("count"): live Lua heap for the WHOLE VM (all addons)
--   - storage's EstimateHistorySize: layout model of history instances only,
--     times an empirical 1.5 fudge
--
-- Provides:
--   - a raw walk of the ENTIRE BattleScrollsSavedVariables global (every
--     world/account root - catches stale subtrees the history estimate
--     never visits), with both a Lua-layout byte model and an approximation
--     of the serialized on-disk file size (what the game parses at load)
--   - calibration allocators: hold exactly N model-MB of strings or tables
--     so the gauge's bytes-per-model-byte factor can be read off the
--     console display, replacing the guessed 1.5 fudge with a measurement
-----------------------------------------------------------

if not SemisPlaygroundCheckAccess() then
    return
end

BattleScrolls = BattleScrolls or {}

---@class MemDiagSection
---@field path string Slash-joined key path, e.g. "Default/@User/$AccountWide/history"
---@field rawBytes number Lua-layout model bytes (no correction factor)
---@field serializedBytes number Approximate share of the on-disk SV file

---@class MemDiagReport
---@field totalRawBytes number Raw model bytes for the whole SV global
---@field totalSerializedBytes number Approximate on-disk SV file size
---@field historyEstimateBytes number storage:EstimateHistorySize() (the shown, fudged number)
---@field sections MemDiagSection[] Depth-3 breakdown, largest first

---@class MemDiagProbeRow
---@field length number String length probed
---@field gaugePerString number Console gauge bytes charged per string (0 on PC)
---@field heapPerString number collectgarbage bytes per string
---@field modelPerString number What our layout model charges per string

---@class MemDiag
---@field lastReport MemDiagReport|nil Result of the latest measure run
---@field probeRows MemDiagProbeRow[]|nil Result of the latest size-class probe
---@field busyText string|nil Localized status while an async op runs; nil when idle
---@field _held (string|number[])[]|nil Calibration allocations currently pinned
---@field _heldModelBytes number Model cost of the pinned allocations
---@field _stringSerial number Ever-increasing suffix counter: Havok interns ALL strings (5.1 lineage), so restarting the counter per press would regenerate identical strings and later presses would allocate nothing
---@field _fiber Fiber<any>|nil Running diagnostic op (measure/allocate/release)
local memDiag = {
    lastReport = nil,
    probeRows = nil,
    busyText = nil,
    _held = nil,
    _heldModelBytes = 0,
    _stringSerial = 0,
    _fiber = nil,
}
BattleScrolls.memDiag = memDiag

-- Yield cadence for the walk and the allocators (nodes / items per slice).
-- Console kills any script step exceeding 1000ms, and allocation slices can
-- absorb large incremental-GC pauses on top of their own cost, so slices
-- must stay tiny: 500 strings per slice tripped the watchdog on console.
local NODES_PER_YIELD = 1000
local STRINGS_PER_YIELD = 50
local TABLES_PER_YIELD = 250

---@return number bytes Live Lua heap in bytes (whole VM, all addons)
function memDiag.luaHeapBytes()
    return collectgarbage("count") * 1024
end

---@return number bytes Model cost of the currently pinned calibration data
function memDiag.heldModelBytes()
    return memDiag._heldModelBytes
end

---@return boolean
function memDiag.isBusy()
    return memDiag._fiber ~= nil
end

---@param n number
---@return number Next power of two >= n
local function nextPow2(n)
    if n <= 0 then return 0 end
    local p = 1
    while p < n do p = p * 2 end
    return p
end

---@class MemDiagWalkState
---@field visited table<any, boolean> Shared across the whole walk: interned strings and shared tables count once, matching the heap
---@field nodes number Nodes visited since the last yield

---Measures one value: Lua-layout bytes (same constants as storage.lua's
---estimateValueSize, no correction factor) plus an approximation of its
---serialized text size in the SavedVariables file. Runs inside the measure
---fiber and yields every NODES_PER_YIELD nodes.
---@param value any
---@param depth number Indentation depth in the serialized file
---@param state MemDiagWalkState
---@return number rawBytes
---@return number serializedBytes
local function measureValue(value, depth, state)
    state.nodes = state.nodes + 1
    if state.nodes >= NODES_PER_YIELD then
        state.nodes = 0
        LibEffect.Yield():Await()
    end

    local valueType = type(value)
    if valueType == "boolean" then
        return 0, value and 4 or 5
    elseif valueType == "number" then
        return 0, #tostring(value)
    elseif valueType == "string" then
        local len = #value
        local serialized = len + 2
        if len <= 40 then
            if state.visited[value] then
                return 0, serialized
            end
            state.visited[value] = true
        end
        return 32 + len + 1, serialized
    elseif valueType == "table" then
        if state.visited[value] then
            return 0, 0
        end
        state.visited[value] = true

        local rawBytes = 72
        -- Opening/closing brace lines with indentation
        local serializedBytes = (depth * 4 + 2) * 2

        local arrayLen = #value
        local totalKeys = 0
        local isPureArray = arrayLen > 0
        local stringKeyBytes = 0

        for k, v in pairs(value) do
            totalKeys = totalKeys + 1

            if isPureArray then
                local kType = type(k)
                if kType ~= "number" or k < 1 or k > arrayLen or k % 1 ~= 0 then
                    isPureArray = false
                end
            end

            local keySerialized
            if type(k) == "string" then
                local kLen = #k
                if kLen > 40 or not state.visited[k] then
                    if kLen <= 40 then state.visited[k] = true end
                    stringKeyBytes = stringKeyBytes + 32 + kLen + 1
                end
                keySerialized = kLen + 4
            else
                keySerialized = #tostring(k) + 2
            end

            local childRaw, childSerialized = measureValue(v, depth + 1, state)
            rawBytes = rawBytes + childRaw
            -- indent + ["key"] + " = " + value + ",\n"
            serializedBytes = serializedBytes
                + (depth + 1) * 4 + keySerialized + 3 + childSerialized + 2
        end

        if isPureArray and totalKeys == arrayLen then
            rawBytes = rawBytes + nextPow2(arrayLen) * 16
        else
            rawBytes = rawBytes + nextPow2(totalKeys) * 40 + stringKeyBytes
        end
        return rawBytes, serializedBytes
    end
    return 0, 0
end

---Walks the raw SavedVariables global three key levels deep (world ->
---account -> namespace) and measures every subtree found at that grain, so
---stale roots from other servers or old layouts show up by name.
---@return Effect Effect resolving to MemDiagReport
local function measureEffect()
    return LibEffect.Async(function()
        ---@type MemDiagWalkState
        local state = { visited = {}, nodes = 0 }
        ---@type MemDiagSection[]
        local sections = {}
        local totalRaw, totalSerialized = 0, 0

        ---@param value any
        ---@param path string
        ---@param depth number Key depth from the global (0-based)
        local function walk(value, path, depth)
            if type(value) ~= "table" or depth >= 3 then
                local rawBytes, serializedBytes = measureValue(value, depth, state)
                if rawBytes > 0 or serializedBytes > 0 then
                    sections[#sections + 1] = {
                        path = path,
                        rawBytes = rawBytes,
                        serializedBytes = serializedBytes,
                    }
                    totalRaw = totalRaw + rawBytes
                    totalSerialized = totalSerialized + serializedBytes
                end
                return
            end
            -- Container tables above the section grain: count their own
            -- shells so totals stay honest, without a section row
            totalRaw = totalRaw + 72
            state.visited[value] = true
            for k, v in pairs(value) do
                walk(v, path .. "/" .. tostring(k), depth + 1)
            end
        end

        local sv = _G["BattleScrollsSavedVariables"]
        if sv then
            walk(sv, "", 0)
        end

        table.sort(sections, function(a, b) return a.rawBytes > b.rawBytes end)

        local historyEstimateBytes = BattleScrolls.storage:EstimateHistorySize()
        ---@type MemDiagReport
        return {
            totalRawBytes = totalRaw,
            totalSerializedBytes = totalSerialized,
            historyEstimateBytes = historyEstimateBytes,
            sections = sections,
        }
    end)
end

---Runs one diagnostic op at a time; busyText/lastReport drive the settings
---rows and onDone re-renders them.
---@param busyText string Localized status shown while running
---@param effect Effect
---@param onDone fun()
local function runOp(busyText, effect, onDone)
    if memDiag._fiber then
        return
    end
    memDiag.busyText = busyText
    memDiag._fiber = effect:Ensure(function()
        memDiag._fiber = nil
        memDiag.busyText = nil
        onDone()
    end):Run()
end

---Measures the whole SavedVariables global; report lands in lastReport.
---@param onDone fun() Called (also on failure) when the run settles
function memDiag.measure(onDone)
    runOp(GetString(BATTLESCROLLS_MEMDIAG_BUSY), LibEffect.Async(function()
        memDiag.lastReport = measureEffect():Await()
    end), onDone)
end

-- Calibration allocation size per press. 5 model-MB moves the console gauge
-- far enough above its noise (~1 MB between samples) to read the factor.
local CALIBRATION_BYTES = 5 * 1000 * 1000

-- Unique long strings: > 40 chars so nothing interns, ~1 KB each so the
-- per-string overhead share matches stored _data chunks. Model cost per
-- string: TString(32) + len + null + a TValue array slot(16).
local CALIBRATION_STRING_LEN = 1000

---Allocates and pins CALIBRATION_BYTES of unique long strings.
---@param onDone fun()
function memDiag.allocateStrings(onDone)
    runOp(GetString(BATTLESCROLLS_MEMDIAG_BUSY), LibEffect.Async(function()
        local held = memDiag._held or {}
        memDiag._held = held
        local perString = 32 + CALIBRATION_STRING_LEN + 1 + 16
        local count = math.floor(CALIBRATION_BYTES / perString)
        local base = string.rep("m", CALIBRATION_STRING_LEN - 12)
        for i = 1, count do
            -- The 12-digit suffix keeps every string unique — across presses
            -- too, via the persistent serial (see _stringSerial above)
            memDiag._stringSerial = memDiag._stringSerial + 1
            held[#held + 1] = base .. string.format("%012d", memDiag._stringSerial)
            if i % STRINGS_PER_YIELD == 0 then
                LibEffect.Yield():Await()
            end
        end
        memDiag._heldModelBytes = memDiag._heldModelBytes + count * perString
    end), onDone)
end

-- Size-class probe ---------------------------------------------------------
-- Havok Script allocates through hkFreeListMemorySystem, whose allocators
-- (read out of the client binary) both work in 16-byte steps: requests up to
-- 640 bytes come from binned free lists ((size+15)/16 selects the bin),
-- larger ones from hkLargeBlockAllocator's coalescing list. So our 240-char
-- chunk strings should cost ~288 bytes and the model should be within a few
-- percent. These lengths bracket the 641-byte boundary and the 1996-char
-- chunk size we reduced from, to confirm that on the real console allocator
-- rather than trusting the disassembly.
local PROBE_LENGTHS = { 120, 200, 240, 260, 300, 380, 500, 590, 620, 1996 }

-- Allocate a roughly constant volume at every length: the console gauge reads
-- in 0.01 MB steps, so each step needs enough bulk to be read off it
local PROBE_TARGET_BYTES = 2 * 1024 * 1024

-- The pool APIs report megabytes; pools are sized in binary MB
local MB_BYTES = 1024 * 1024

---@return number bytes Console add-on memory gauge, 0 where unavailable (PC)
function memDiag.gaugeBytes()
    if GetTotalUserAddOnMemoryPoolUsageMB then
        return GetTotalUserAddOnMemoryPoolUsageMB() * MB_BYTES
    end
    return 0
end

---Builds one unique string of exactly `length` characters
---@param length number
---@return string
local function uniqueString(length)
    memDiag._stringSerial = memDiag._stringSerial + 1
    return string.rep("m", length - 12) .. string.format("%012d", memDiag._stringSerial)
end

---Measures marginal per-string cost at one length: allocate a pinned batch,
---settle GC, sample, then drop it and settle again so the next length starts
---from the same footing.
---@param length number
---@return Effect Effect resolving to MemDiagProbeRow
local function probeLengthEffect(length)
    return LibEffect.Async(function()
        BattleScrolls.gc:CollectFullAsync():Await()
        local gaugeBefore, heapBefore = memDiag.gaugeBytes(), memDiag.luaHeapBytes()

        local modelPerString = 32 + length + 1 + 16
        local count = math.max(200, math.floor(PROBE_TARGET_BYTES / modelPerString))
        local batch = {}
        for i = 1, count do
            batch[i] = uniqueString(length)
            if i % STRINGS_PER_YIELD == 0 then
                LibEffect.Yield():Await()
            end
        end

        BattleScrolls.gc:CollectFullAsync():Await()
        local gaugeAfter, heapAfter = memDiag.gaugeBytes(), memDiag.luaHeapBytes()
        -- batch stays reachable until here on purpose
        local batchSize = #batch
        batch = nil
        BattleScrolls.gc:CollectFullAsync():Await()

        ---@type MemDiagProbeRow
        return {
            length = length,
            gaugePerString = (gaugeAfter - gaugeBefore) / batchSize,
            heapPerString = (heapAfter - heapBefore) / batchSize,
            modelPerString = modelPerString,
        }
    end)
end

---Runs the size-class probe across PROBE_LENGTHS; result lands in probeRows.
---@param onDone fun()
function memDiag.probeStringSizes(onDone)
    runOp(GetString(BATTLESCROLLS_MEMDIAG_BUSY), LibEffect.Async(function()
        ---@type MemDiagProbeRow[]
        local rows = {}
        for _, length in ipairs(PROBE_LENGTHS) do
            rows[#rows + 1] = probeLengthEffect(length):Await()
            memDiag.probeRows = rows -- publish incrementally: a forced reload mid-run still leaves usable data
        end
    end), onDone)
end

---Allocates and pins CALIBRATION_BYTES of small number-array tables, the
---other allocation shape stored data is made of. Model cost per table:
---header(72) + 8 array slots(128) + the holder's own slot(16).
---@param onDone fun()
function memDiag.allocateTables(onDone)
    runOp(GetString(BATTLESCROLLS_MEMDIAG_BUSY), LibEffect.Async(function()
        local held = memDiag._held or {}
        memDiag._held = held
        local perTable = 72 + 8 * 16 + 16
        local count = math.floor(CALIBRATION_BYTES / perTable)
        for i = 1, count do
            held[#held + 1] = { i, i + 1, i + 2, i + 3, i + 4, i + 5, i + 6, i + 7 }
            if i % TABLES_PER_YIELD == 0 then
                LibEffect.Yield():Await()
            end
        end
        memDiag._heldModelBytes = memDiag._heldModelBytes + count * perTable
    end), onDone)
end

---Drops all pinned calibration data and steps GC until the reclamation is
---confirmed, so the gauge reading afterwards is meaningful.
---@param onDone fun()
function memDiag.release(onDone)
    runOp(GetString(BATTLESCROLLS_MEMDIAG_BUSY), LibEffect.Async(function()
        memDiag._held = nil
        memDiag._heldModelBytes = 0
        BattleScrolls.gc:CollectFullAsync():Await()
    end), onDone)
end

---Runs a confirmed full GC cycle (no allocations touched).
---@param onDone fun()
function memDiag.runFullGC(onDone)
    runOp(GetString(BATTLESCROLLS_MEMDIAG_BUSY), BattleScrolls.gc:CollectFullAsync(), onDone)
end
