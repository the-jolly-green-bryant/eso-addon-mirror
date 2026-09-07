-- Opt-in experiments for the console memory investigation.
-- No history mutation. `seed`, `compact` and `discard` write BattleScrollsMemoryProbe, a separate
-- SavedVariables global. Measurements are volatile and printed after sampling.
if not SemisPlaygroundCheckAccess() then return end

local diag = BattleScrolls.memDiag
local MIB = 1024 * 1024
local POLL = LibEffect.Sleep(100)
local SLICE = LibEffect.Sleep(1) -- timer suspension, not a busy Yield loop
local TABLE_COUNT = 8192
local SEED_VERSION = 1
local SEED_DEPTH = 20
local SEED_LENGTH = 240
local MIRROR_SUFFIX = ":BSML"

---@class MemLabSeedNode
---@field [string|number] string|number|boolean|MemLabSeedNode

---@class MemLabMirrorStats
---@field tables integer
---@field strings integer
---@field listBytes number Constructed graph model, including the string suffix
---@field hashBytes number Constructed graph model, including the string suffix

---@class MemLabMirrorFrame
---@field source table
---@field target MemLabSeedNode
---@field key string|number|nil
---@field count integer
---@field maxIndex number
---@field dense boolean

---@class MemLabSeed
---@field version integer
---@field shape string "flat", "nested", "tables" or "mirror"
---@field count integer
---@field root MemLabSeedNode
---@field mirror MemLabMirrorStats|nil

---@class MemLabSample
---@field gauge number|nil MiB
---@field heap number|nil MiB

---@class MemLabRow
---@field label string Experiment token (documented in the research guide)
---@field before MemLabSample
---@field work MemLabSample
---@field freed MemLabSample

---@class MemLabReport
---@field mode string
---@field rows MemLabRow[]
---@field statusId integer
---@field completed integer
---@field maxGauge number
---@field maxHeap number
---@field startedMs number
---@field elapsedSeconds integer
---@field diskMiB number|nil Saved file size, not runtime memory
---@field seedCount integer|nil
---@field matches integer|nil Nonempty ability results (summed over passes)
---@field error string|nil
---@field census MemLabCensus|nil Counts only; never retains the traversed graph
---@field mirror MemLabMirrorStats|nil Counts only; never retains the copied graph

---@class MemLabCensus
---@field listBytes number Dense 1..n tables modeled as arrays; other tables as hash
---@field hashBytes number All tables modeled as power-of-two hash storage
---@field historyListBytes number
---@field historyHashBytes number
---@field ownHashBytes number Incremental after history
---@field sharedHashBytes number Incremental after history and own setups
---@field cachedBytes number Sum of existing instance caches, without recalculation
---@field missingCaches integer
---@field instances integer
---@field arrayTables integer Dense tables in the whole saved graph
---@field arraySlots integer Their rounded capacities
---@field strings integer Unique strings, including keys, across all lengths
---@field stringBytes number String payload plus 27-byte headers
---@field live MemLabLiveStats|nil

---@class MemLabLiveStats
---@field lastActive integer 1 if the scribe still owns the last saved instance, otherwise 0
---@field abilities integer Entries in the scribe's decoded ability-info cache
---@field ids integer Ability IDs in the live registry
---@field names integer Names in the live registry
---@field listBytes number Incremental requested-byte model after all saved roots
---@field hashBytes number Incremental requested-byte model after all saved roots

---@class MemLab
---@field report MemLabReport|nil
---@field running boolean
---@field fileSample MemLabSample After this module's dependencies loaded; not loader peak
---@field loadedSample MemLabSample Before Battle Scrolls initialization
---@field loadedShape string
---@field loadedCount integer
---@field seedChanged boolean Refuse load comparisons after changing the seed this session
local lab = {
    running = false,
    fileSample = { gauge = diag.gaugeBytes() / MIB, heap = diag.luaHeapBytes() / MIB },
    loadedSample = {}, loadedShape = "empty", loadedCount = 0, seedChanged = false,
}
BattleScrolls.memLab = lab

---@return MemLabSeed|nil
local function seed()
    return _G["BattleScrollsMemoryProbe"]
end

-- Registered before main.lua: the event arrives after SavedVariables load,
-- but before our main handler initializes/migrates the addon. Never auto-run a
-- workload on login, and never claim these samples observe native load peaks.
EVENT_MANAGER:RegisterForEvent("BattleScrolls_MemLab", EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= BattleScrolls.addonName then return end
    lab.loadedSample.gauge = diag.gaugeBytes() / MIB
    lab.loadedSample.heap = diag.luaHeapBytes() / MIB
    local saved = seed()
    if type(saved) == "table" and type(saved.root) == "table"
        and type(saved.shape) == "string" and type(saved.count) == "number" then
        lab.loadedShape = saved.shape
        lab.loadedCount = saved.count
    end
    EVENT_MANAGER:UnregisterForEvent("BattleScrolls_MemLab", EVENT_ADD_ON_LOADED)
end)

---@param sample MemLabSample
local function readSample(sample)
    sample.gauge = diag.gaugeBytes() / MIB
    sample.heap = diag.luaHeapBytes() / MIB
end

---@param report MemLabReport
---@param allowCombat? boolean
local function check(report, allowCombat)
    local gauge, heap = diag.gaugeBytes() / MIB, diag.luaHeapBytes() / MIB
    report.maxGauge = math.max(report.maxGauge, gauge)
    report.maxHeap = math.max(report.maxHeap, heap)
    local capacity = GetTotalUserAddOnMemoryPoolCapacityMB()
    local limit = capacity > 0 and math.min(75, capacity * 0.75) or 75
    if gauge >= limit then
        report.statusId = BATTLESCROLLS_MEMDIAG_TEST_LIMIT
        error(report.statusId)
    elseif not allowCombat and IsUnitInCombat("player") then
        report.statusId = BATTLESCROLLS_MEMDIAG_TEST_COMBAT
        error(report.statusId)
    elseif GetGameTimeMilliseconds() - report.startedMs > 180000 then
        report.statusId = BATTLESCROLLS_MEMLAB_TIMEOUT
        error(report.statusId)
    end
end

---@param report MemLabReport
---@param milliseconds integer
---@param allowCombat? boolean
local function wait(report, milliseconds, allowCombat)
    local deadline = GetGameTimeMilliseconds() + milliseconds
    repeat
        check(report, allowCombat)
        POLL:Await()
    until GetGameTimeMilliseconds() >= deadline
    check(report, allowCombat)
end

---@param report MemLabReport
local function collect(report)
    for _ = 1, 2 do
        check(report)
        local completed = BattleScrolls.gc:CollectFullAsync():Await()
        check(report)
        if not completed then
            report.statusId = BATTLESCROLLS_MEMDIAG_TEST_GC_TIMEOUT
            error(report.statusId)
        end
    end
end

---@param report MemLabReport
---@param sample MemLabSample
local function settle(report, sample)
    wait(report, 1000)
    collect(report)
    readSample(sample)
    check(report)
end

---@param value number|nil
---@return string
local function number(value)
    return value and string.format("%.2f", value) or "--"
end

---@param report MemLabReport
local function printReport(report)
    local census = report.census
    if census then
        d(GetString(BATTLESCROLLS_MEMLAB_CENSUS_HEADER))
        if census.live then
            d(string.format(GetString(BATTLESCROLLS_MEMLAB_LIVE_COUNTS),
                census.live.lastActive, census.live.abilities, census.live.ids, census.live.names))
            d(string.format(GetString(BATTLESCROLLS_MEMLAB_CENSUS_TOTAL),
                census.listBytes / MIB, census.hashBytes / MIB))
            d(string.format(GetString(BATTLESCROLLS_MEMLAB_LIVE_BYTES),
                census.live.listBytes / MIB, census.live.hashBytes / MIB))
        else
            d(string.format(GetString(BATTLESCROLLS_MEMLAB_CENSUS_CACHE),
                census.instances, census.cachedBytes / MIB, census.missingCaches))
            d(string.format(GetString(BATTLESCROLLS_MEMLAB_CENSUS_HISTORY),
                census.historyListBytes / MIB, census.historyHashBytes / MIB))
            d(string.format(GetString(BATTLESCROLLS_MEMLAB_CENSUS_SETUPS),
                census.ownHashBytes / MIB, census.sharedHashBytes / MIB))
            d(string.format(GetString(BATTLESCROLLS_MEMLAB_CENSUS_TOTAL),
                census.listBytes / MIB, census.hashBytes / MIB))
            d(string.format(GetString(BATTLESCROLLS_MEMLAB_CENSUS_ARRAYS),
                census.arrayTables, census.arraySlots))
            d(string.format(GetString(BATTLESCROLLS_MEMLAB_CENSUS_STRINGS),
                census.strings, census.stringBytes / MIB))
        end
    else
        d(string.format(GetString(BATTLESCROLLS_MEMLAB_HEADER), report.mode))
    end
    if report.seedCount then
        d(string.format(GetString(BATTLESCROLLS_MEMLAB_SEED_INFO), lab.loadedShape,
            report.seedCount, number(report.diskMiB)))
    elseif report.matches then
        d(string.format(GetString(BATTLESCROLLS_MEMLAB_MATCHES), report.matches))
    end
    if report.mirror then
        d(string.format(GetString(BATTLESCROLLS_MEMLAB_MIRROR_INFO),
            report.mirror.tables, report.mirror.strings,
            report.mirror.listBytes / MIB, report.mirror.hashBytes / MIB))
    end
    for _, row in ipairs(report.rows) do
        d(string.format(GetString(BATTLESCROLLS_MEMLAB_ROW), row.label,
            number(row.before.gauge), number(row.work.gauge), number(row.freed.gauge),
            number(row.before.heap), number(row.work.heap), number(row.freed.heap)))
    end
    d(string.format(GetString(BATTLESCROLLS_MEMLAB_FOOTER), GetString(report.statusId),
        report.completed, #report.rows, number(report.maxGauge), number(report.maxHeap), report.elapsedSeconds))
end

---@param mode string
---@param labels string[]
---@param body fun(report: MemLabReport)
local function run(mode, labels, body)
    if diag.isBusy() then d(GetString(BATTLESCROLLS_MEMDIAG_BUSY)) return end
    if diag._held then d(GetString(BATTLESCROLLS_MEMDIAG_TEST_HELD)) return end
    ---@type MemLabReport
    local report = {
        mode = mode, rows = {}, statusId = BATTLESCROLLS_MEMDIAG_TEST_RUNNING,
        completed = 0, maxGauge = 0, maxHeap = 0,
        startedMs = GetGameTimeMilliseconds(), elapsedSeconds = 0,
    }
    for _, label in ipairs(labels) do
        report.rows[#report.rows + 1] = { label = label, before = {}, work = {}, freed = {} }
    end
    lab.report, lab.running = report, true
    d(GetString(mode == "watch" and BATTLESCROLLS_MEMLAB_WATCH_STARTED or BATTLESCROLLS_MEMDIAG_TEST_STARTED))
    -- Share memdiag's lock so settings and either slash command cannot run a
    -- second allocator/collector or steal the temporary holder mid-experiment.
    diag._fiber = LibEffect.Async(function()
        check(report, mode == "watch")
        body(report)
        report.statusId = BATTLESCROLLS_MEMDIAG_TEST_DONE
    end):Recover(function(err)
        if LibEffect.IsCancelledError(err) then
            report.statusId = BATTLESCROLLS_MEMDIAG_TEST_CANCELLED
        elseif report.statusId == BATTLESCROLLS_MEMDIAG_TEST_RUNNING then
            report.statusId = BATTLESCROLLS_MEMDIAG_TEST_ERROR
        end
        report.error = tostring(err)
        return nil
    end):Ensure(function()
        diag._held, diag._heldModelBytes, diag._fiber = nil, 0, nil
        lab.running = false
        if report.statusId == BATTLESCROLLS_MEMDIAG_TEST_RUNNING then
            report.statusId = BATTLESCROLLS_MEMDIAG_TEST_CANCELLED
        end
        report.elapsedSeconds = math.floor((GetGameTimeMilliseconds() - report.startedMs) / 1000)
        -- Watch is observational during combat, including on exit.
        if mode ~= "watch" then BattleScrolls.gc:RequestGC(2) end
        printReport(report)
        if mode:match("^seed ") and report.statusId == BATTLESCROLLS_MEMDIAG_TEST_DONE then
            d(GetString(BATTLESCROLLS_MEMLAB_SAVE_RESTART))
        end
    end):Run()
end

-- Literal forms deliberately differ. Their semantic contents are identical;
-- compiler constructor hints and growth history may give different layouts.
---@param kind string
---@param i integer
---@return number[]
local function makeTable(kind, i)
    if kind == "I" then
        return { [1] = i, [2] = i+1, [3] = i+2, [4] = i+3,
            [5] = i+4, [6] = i+5, [7] = i+6, [8] = i+7 }
    elseif kind == "D" then
        local result = {}
        for j = 1, 8 do result[j] = i+j-1 end
        return result
    end
    return { i, i+1, i+2, i+3, i+4, i+5, i+6, i+7 }
end

-- No suspended coroutine retains a local alias of the large holder.
---@param kind string
---@param first integer
---@param last integer
---@param suffix string
local function allocateBatch(kind, first, last, suffix)
    if kind == "C" then return end -- same scheduling/GC, no payload
    local held = diag._held or {}
    diag._held = held
    for i = first, last do
        if kind == "S" or kind == "L" then
            diag._stringSerial = diag._stringSerial + 1
            held[i] = string.format("%012d", diag._stringSerial) .. suffix
        else
            held[i] = makeTable(kind, i)
        end
    end
end

---@param report MemLabReport
---@param kind string
local function allocate(report, kind)
    local count = kind == "L" and 1024 or TABLE_COUNT
    local suffix = (kind == "S" or kind == "L") and string.rep("m", (kind == "S" and 240 or 1996) - 12) or ""
    for first = 1, count, 64 do
        check(report)
        allocateBatch(kind, first, math.min(first + 63, count), suffix)
        check(report)
        SLICE:Await()
    end
end

---@param mode string
---@param labels string[]
local function allocationTest(mode, labels)
    run(mode, labels, function(report)
        for _, row in ipairs(report.rows) do
            settle(report, row.before)
            allocate(report, row.label)
            settle(report, row.work)
            diag._held = nil
            settle(report, row.freed)
            report.completed = report.completed + 1
        end
    end)
end

---@return number|nil
local function diskUsage()
    local manager = GetAddOnManager()
    if not manager or not manager.GetUserAddOnSavedVariablesDiskUsageMB then return nil end
    for i = 1, manager:GetNumAddOns() do
        if manager:GetAddOnInfo(i) == BattleScrolls.addonName then
            return manager:GetUserAddOnSavedVariablesDiskUsageMB(i)
        end
    end
    return nil
end

---@return MemLabSeedNode|nil
local function seedPayload()
    local saved = seed()
    if saved == nil then return nil end
    assert(type(saved) == "table" and type(saved.root) == "table")
    if saved.shape == "mirror" then
        -- Validate metadata only here: walking a mirror would warm the allocator
        -- before load's baseline. Discard measures the actual loaded graph's H.
        local stats = saved.mirror
        assert(saved.version == SEED_VERSION and type(stats) == "table")
        for _, key in ipairs({ "tables", "strings", "listBytes", "hashBytes" }) do
            local value = stats[key]
            assert(type(value) == "number" and value >= 0 and value < math.huge and value % 1 == 0)
        end
        assert(stats.tables >= 1 and saved.count == stats.tables)
        return saved.root
    end
    assert(saved.version == SEED_VERSION
        and (saved.shape == "flat" or saved.shape == "nested" or saved.shape == "tables"))
    assert(saved.count == 4096 or saved.count == 8192 or saved.count == 16384
        or (saved.shape == "tables" and saved.count == 32768))
    local root = saved.root
    for _ = 1, saved.shape == "nested" and SEED_DEPTH or 0 do
        assert(type(root[1]) == "table" and #root == 1)
        root = root[1]
        ---@cast root MemLabSeedNode
    end
    assert(#root == saved.count)
    for i = 1, saved.count do
        local value = root[i]
        if saved.shape == "tables" then
            assert(type(value) == "table" and #value == 8)
            for j = 1, 8 do assert(value[j] == i+j-1) end
            for key in pairs(value) do
                assert(type(key) == "number" and key % 1 == 0 and key >= 1 and key <= 8)
            end
        else
            assert(type(value) == "string" and #value == SEED_LENGTH)
        end
    end
    if saved.shape == "tables" then
        for key in pairs(root) do
            assert(type(key) == "number" and key % 1 == 0 and key >= 1 and key <= saved.count)
        end
    end
    return root
end

---@param first integer
---@param last integer
---@param suffix string
---@param shape string|nil
local function seedBatch(first, last, suffix, shape)
    local held = diag._held or {}
    diag._held = held
    for i = first, last do
        -- Same exact strings in every seed shape and runtime reconstruction.
        -- Prefix uniqueness avoids HKS's first-31-byte hash collision trap.
        held[i] = shape == "tables" and makeTable("A", i) or string.format("BSML%08d", i) .. suffix
    end
end

---@param report MemLabReport
---@param count integer
---@param shape? string
local function buildSeed(report, count, shape)
    local suffix = shape == "tables" and "" or string.rep("m", SEED_LENGTH - 12)
    for first = 1, count, 64 do
        check(report)
        seedBatch(first, math.min(first + 63, count), suffix, shape)
        check(report)
        SLICE:Await()
    end
end

---@param shape string
---@param count integer
local function publishSeed(shape, count)
    ---@type MemLabSeedNode
    local root = diag._held
    for _ = 1, shape == "nested" and SEED_DEPTH or 0 do root = { root } end
    ---@type MemLabSeed
    local saved = { version = SEED_VERSION, shape = shape, count = count, root = root }
    _G["BattleScrollsMemoryProbe"] = saved
    lab.seedChanged = true
end

---@param shape string
---@param count integer
local function prepareSeed(shape, count)
    if shape == "clear" then
        if diag.isBusy() then d(GetString(BATTLESCROLLS_MEMDIAG_BUSY)) return end
        _G["BattleScrollsMemoryProbe"] = nil
        lab.seedChanged = true
        d(GetString(BATTLESCROLLS_MEMLAB_SEED_CLEARED))
        d(GetString(BATTLESCROLLS_MEMLAB_SAVE_RESTART))
        return
    end
    run("seed " .. shape, { "SV" }, function(report)
        local row = report.rows[1]
        settle(report, row.before)
        buildSeed(report, count, shape)
        settle(report, row.work)
        -- Commit only a complete, successfully measured seed. Cancellation,
        -- limit, combat or error before here preserves the previous saved seed.
        publishSeed(shape, count)
        diag._held = nil
        readSample(row.freed) -- still retained by SavedVariables, intentionally
        report.completed = 1
    end)
end

-- Copy saved values without invoking storage, decoders, ability APIs, or
-- metatables. All source strings must lack the suffix, so every transformed
-- string differs from every source string. Appending preserves the first
-- 31 bytes of long strings used by the traced HKS hash, unlike unique prefixes.
---@param report MemLabReport
---@return Effect<MemLabMirrorStats>
local function buildMirror(report)
    local source = _G["BattleScrollsSavedVariables"]
    assert(type(source) == "table")
    ---@type MemLabMirrorStats
    local stats = { tables = 0, strings = 0, listBytes = 0, hashBytes = 0 }
    ---@type table<table, MemLabSeedNode>
    local tables = {}
    ---@type table<table, boolean>
    local active = {}
    ---@type table<string, string>
    local strings = {}
    ---@type MemLabMirrorFrame[]
    local stack = {}
    ---@param value string
    ---@return string
    local function copyString(value)
        assert(value:sub(-#MIRROR_SUFFIX) ~= MIRROR_SUFFIX)
        local existing = strings[value]
        if existing then return existing end
        local copy = value .. MIRROR_SUFFIX
        strings[value] = copy
        stats.strings = stats.strings + 1
        stats.listBytes = stats.listBytes + 27 + #copy
        stats.hashBytes = stats.hashBytes + 27 + #copy
        return copy
    end
    ---@param value any
    ---@return string|number|boolean|MemLabSeedNode
    local function clone(value)
        local kind = type(value)
        if kind == "string" then return copyString(value) end
        if kind == "number" or kind == "boolean" then return value end
        assert(kind == "table" and not active[value]) -- saved data must be acyclic
        if tables[value] then return tables[value] end
        ---@type MemLabSeedNode
        local copy = {}
        tables[value], active[value] = copy, true
        stats.tables = stats.tables + 1
        stack[#stack + 1] = { source = value, target = copy, count = 0, maxIndex = 0, dense = true }
        return copy
    end
    -- Frame/target aliases exist only in this non-yielding helper. Cleanup can
    -- empty the owning indexes even if a cancelled coroutine remains queued.
    local function copyBatch()
        for _ = 1, 128 do
            local frame = stack[#stack]
            if not frame then return end
            local key, child = next(frame.source, frame.key)
            if key == nil then
                local dense = frame.dense and frame.count > 0 and frame.maxIndex == frame.count
                local capacity = frame.count > 0 and 1 or 0
                while capacity < frame.count do capacity = capacity * 2 end
                stats.listBytes = stats.listBytes + 64 + (dense and 16 or 40) * capacity
                stats.hashBytes = stats.hashBytes + 64 + 40 * capacity
                active[frame.source] = nil
                stack[#stack] = nil
            else
                assert(type(key) == "number" or type(key) == "string")
                frame.key, frame.count = key, frame.count + 1
                if type(key) == "number" and key >= 1 and key % 1 == 0 then
                    frame.maxIndex = math.max(frame.maxIndex, key)
                else
                    frame.dense = false
                end
                frame.target[type(key) == "string" and copyString(key) or key] = clone(child)
            end
        end
    end
    return LibEffect.Async(function()
        diag._held = clone(source)
        while #stack > 0 do
            check(report)
            copyBatch()
            check(report)
            if #stack > 0 then SLICE:Await() end
        end
        return stats
    end):Ensure(function()
        tables, active, strings, stack = {}, {}, {}, {}
    end)
end

local function prepareMirrorSeed()
    if seed() ~= nil or lab.seedChanged then
        d(GetString(BATTLESCROLLS_MEMLAB_MIRROR_CLEAR))
        return
    end
    run("seed mirror", { "copy" }, function(report)
        local row = report.rows[1]
        settle(report, row.before)
        report.mirror = buildMirror(report):Await()
        settle(report, row.work)
        _G["BattleScrollsMemoryProbe"] = {
            version = SEED_VERSION, shape = "mirror", count = report.mirror.tables,
            root = diag._held, mirror = report.mirror,
        }
        lab.seedChanged = true
        diag._held = nil
        readSample(row.freed) -- the complete synthetic copy remains saved
        report.completed = 1
    end)
end

-- No graph traversal or copy: release the separate seed, then repeat with no
-- seed as a control. No local or suspended coroutine may retain its root.
local function discardSeedTest()
    if lab.seedChanged then d(GetString(BATTLESCROLLS_MEMLAB_SAVE_RESTART)) return end
    if seed() == nil then d(GetString(BATTLESCROLLS_MEMLAB_DISCARD_REQUIRED)) return end
    run("discard", { "SV>0", "0>0" }, function(report)
        for _, row in ipairs(report.rows) do
            settle(report, row.before)
            _G["BattleScrollsMemoryProbe"] = nil
            lab.seedChanged = true
            readSample(row.work)
            settle(report, row.freed)
            report.completed = report.completed + 1
        end
    end)
end

-- The first row replaces the loaded graph; the second repeats the replacement
-- as an in-session control. Work holds both graphs. Freed retains only the new
-- compact graph, with exactly the same validated values in the same SV global.
-- Only numeric count escapes validation: no coroutine may pin the old graph.
local function compactSeedTest()
    if lab.seedChanged then d(GetString(BATTLESCROLLS_MEMLAB_SAVE_RESTART)) return end
    if type(seed()) ~= "table" or seed().shape ~= "tables" then
        d(GetString(BATTLESCROLLS_MEMLAB_TABLE_SEED_REQUIRED))
        return
    end
    run("compact", { "SV>A", "A>A" }, function(report)
        seedPayload()
        local count = lab.loadedCount
        for _, row in ipairs(report.rows) do
            settle(report, row.before)
            buildSeed(report, count, "tables")
            settle(report, row.work)
            publishSeed("tables", count)
            diag._held = nil
            settle(report, row.freed)
            report.completed = report.completed + 1
        end
    end)
end

-- Pure observation of saved data: do not call the production estimator, which
-- writes caches, or decode encounters/look up abilities. Models are requested
-- Lua bytes, not gauge predictions or measurements of actual table capacity.
---@param report MemLabReport
---@param includeLive? boolean
---@return MemLabCensus
local function censusSavedData(report, includeLive)
    local account = BattleScrolls.storage.savedVariables
    local saved = _G["BattleScrollsSavedVariables"]
    assert(type(account) == "table" and type(account.history) == "table" and type(saved) == "table")
    ---@type MemLabCensus
    local result = {
        listBytes = 0, hashBytes = 0, historyListBytes = 0, historyHashBytes = 0,
        ownHashBytes = 0, sharedHashBytes = 0, cachedBytes = 0, missingCaches = 0,
        instances = 0, arrayTables = 0, arraySlots = 0, strings = 0, stringBytes = 0,
    }
    ---@type table<any, boolean>
    local seen = {}
    local visits = 0
    local function tick()
        visits = visits + 1
        if visits % 128 == 0 then
            check(report)
            SLICE:Await()
            check(report)
        end
    end
    ---@param value any
    local function visit(value)
        tick()
        local kind = type(value)
        if kind ~= "table" and kind ~= "string" then return end
        if seen[value] then return end
        seen[value] = true
        if kind == "string" then
            local bytes = 27 + #value
            result.strings, result.stringBytes = result.strings + 1, result.stringBytes + bytes
            result.listBytes, result.hashBytes = result.listBytes + bytes, result.hashBytes + bytes
            return
        end
        local count, maxIndex, dense = 0, 0, true
        for key, child in pairs(value) do
            count = count + 1
            if type(key) == "number" and key >= 1 and key % 1 == 0 then
                maxIndex = math.max(maxIndex, key)
            else
                dense = false
            end
            visit(key)
            visit(child)
        end
        dense = dense and count > 0 and maxIndex == count
        local capacity = count > 0 and 1 or 0
        while capacity < count do capacity = capacity * 2 end
        result.hashBytes = result.hashBytes + 64 + 40 * capacity
        result.listBytes = result.listBytes + 64 + (dense and 16 or 40) * capacity
        if dense then
            result.arrayTables = result.arrayTables + 1
            result.arraySlots = result.arraySlots + capacity
        end
    end
    for _, instance in ipairs(account.history) do
        result.instances = result.instances + 1
        if type(instance._estimatedSize) == "number" then
            result.cachedBytes = result.cachedBytes + instance._estimatedSize
        else
            result.missingCaches = result.missingCaches + 1
        end
        tick()
    end
    -- Shared strings/tables count once. The category order defines incremental
    -- contributions; setup figures are not independent eviction estimates.
    visit(account.history)
    result.historyListBytes, result.historyHashBytes = result.listBytes, result.hashBytes
    visit(account.ownSetups)
    result.ownHashBytes = result.hashBytes - result.historyHashBytes
    visit(account.sharedSetups)
    result.sharedHashBytes = result.hashBytes - result.historyHashBytes - result.ownHashBytes
    visit(saved) -- remaining accounts/worlds/settings, excluding the separate test global
    if includeLive then
        local scribe = BattleScrolls.scribe
        local registry = scribe.registry
        local listBytes, hashBytes = result.listBytes, result.hashBytes
        local arrayTables, arraySlots = result.arrayTables, result.arraySlots
        local stringCount, stringBytes = result.strings, result.stringBytes
        local abilities = 0
        for _ in pairs(scribe.decodedAbilityInfo) do
            abilities = abilities + 1
            tick()
        end
        visit(scribe.instance)
        visit(scribe.decodedAbilityInfo)
        visit(registry) -- includes both arrays and their reverse lookup maps
        result.live = {
            lastActive = scribe.instance == account.history[#account.history] and 1 or 0,
            abilities = abilities, ids = registry and #registry.abilityIds or 0,
            names = registry and #registry.names or 0,
            listBytes = result.listBytes - listBytes, hashBytes = result.hashBytes - hashBytes,
        }
        result.listBytes, result.hashBytes = listBytes, hashBytes
        result.arrayTables, result.arraySlots = arrayTables, arraySlots
        result.strings, result.stringBytes = stringCount, stringBytes
    end
    check(report)
    return result -- visited index dies when this helper returns
end

---@param includeLive? boolean
local function censusTest(includeLive)
    run("census", { "scan" }, function(report)
        local row = report.rows[1]
        settle(report, row.before)
        report.census = censusSavedData(report, includeLive)
        readSample(row.work)
        settle(report, row.freed)
        report.completed = 1
    end)
end

local function loadTest()
    if lab.seedChanged then d(GetString(BATTLESCROLLS_MEMLAB_SAVE_RESTART)) return end
    run("load", { "file", "init", "idle" }, function(report)
        seedPayload() -- validate the loaded shape; never reconstruct it here
        report.seedCount = lab.loadedCount
        if seed() then report.mirror = seed().mirror end
        report.rows[1].before = lab.fileSample
        report.rows[2].before = lab.loadedSample
        report.completed = 2
        local row = report.rows[3]
        readSample(row.before)
        wait(report, 10000)
        readSample(row.work)
        collect(report)
        readSample(row.freed)
        check(report)
        report.completed = 3
        -- The native file query can allocate too. Run it after all memory
        -- samples, so it cannot perturb the startup comparison being reported.
        report.diskMiB = diskUsage()
    end)
end

---@param count integer
local function runtimeSeedTest(count)
    -- An already loaded identical seed would intern all the same strings,
    -- making reconstruction look artificially cheap. Require an empty seed.
    if seed() ~= nil then d(GetString(BATTLESCROLLS_MEMLAB_REMOVE_SEED)) return end
    if lab.seedChanged then d(GetString(BATTLESCROLLS_MEMLAB_SAVE_RESTART)) return end
    run("runtime", { "SV", "SV" }, function(report)
        for _, row in ipairs(report.rows) do
            settle(report, row.before)
            buildSeed(report, count)
            settle(report, row.work)
            diag._held = nil
            settle(report, row.freed)
            report.completed = report.completed + 1
        end
    end)
end

---@param seconds integer
local function watch(seconds)
    run("watch", { "watch" }, function(report)
        local row = report.rows[1]
        readSample(row.before)
        wait(report, seconds * 1000, true)
        readSample(row.work)
        -- Do not change collection behavior during combat. Missing final
        -- sample means no post-watch collection was attempted.
        if not IsUnitInCombat("player") then
            collect(report)
            readSample(row.freed)
        end
        report.completed = 1
    end)
end

---@param kind string
---@param first integer
---@param last integer
---@return integer matches
local function abilityBatch(kind, first, last)
    if kind == "ctrl" then return 0 end -- identical timers and GC, no API lookup
    local matches = 0
    for id = first, last do
        local value
        if kind == "name" then value = GetAbilityName(id, "")
        elseif kind == "icon" then value = GetAbilityIcon(id)
        else value = GetAbilityDescription(id, nil, "") end
        if value and value ~= "" then matches = matches + 1 end
    end
    return matches -- returned strings never escape the non-yielding helper
end

---@param kind string
---@param first integer
---@param count integer
local function abilityTest(kind, first, count)
    run(kind .. " " .. first .. "+" .. count, { "API1", "API2", "API3" }, function(report)
        report.matches = 0
        for _, row in ipairs(report.rows) do
            settle(report, row.before)
            for id = first, first + count - 1, 4 do
                check(report)
                report.matches = report.matches + abilityBatch(kind, id, math.min(id + 3, first + count - 1))
                check(report)
                SLICE:Await()
            end
            readSample(row.work)
            settle(report, row.freed)
            report.completed = report.completed + 1
        end
    end)
end

---@param text string|nil
---@param default integer
---@param shape? string
---@return integer|nil
local function seedCount(text, default, shape)
    local value = text and tonumber(text) or default
    if value == 4096 or value == 8192 or value == 16384
        or (shape == "tables" and value == 32768) then return value end
end

SLASH_COMMANDS["/bsmemlab"] = function(args)
    local words = {}
    for word in args:lower():gmatch("%S+") do words[#words + 1] = word end
    local command = words[1]
    if command == "cancel" and #words == 1 then
        if lab.running and diag._fiber then diag._fiber:Cancel()
        else d(GetString(BATTLESCROLLS_MEMDIAG_TEST_NOT_RUNNING)) end
    elseif command == "report" and #words == 1 then
        if diag.isBusy() then d(GetString(BATTLESCROLLS_MEMDIAG_BUSY))
        elseif lab.report then
            printReport(lab.report)
            if lab.seedChanged and lab.report.mode ~= "census" then
                d(GetString(BATTLESCROLLS_MEMLAB_SAVE_RESTART))
            end
        else d(GetString(BATTLESCROLLS_MEMDIAG_TEST_NO_REPORT)) end
    elseif command == "layouts" and #words == 1 then
        allocationTest(command, { "A", "I", "D", "A", "I", "D" })
    elseif command == "shapes" and #words == 1 then
        allocationTest(command, { "A", "S", "L", "A", "S", "L" })
    elseif command == "control" and #words == 1 then
        allocationTest(command, { "C", "C", "C", "C", "C", "C" })
    elseif command == "load" and #words == 1 then loadTest()
    elseif command == "compact" and #words == 1 then compactSeedTest()
    elseif command == "discard" and #words == 1 then discardSeedTest()
    elseif command == "census" and #words == 1 then censusTest()
    elseif command == "census" and words[2] == "live" and #words == 2 then censusTest(true)
    elseif command == "seed" and words[2] == "mirror" and #words == 2 then prepareMirrorSeed()
    elseif command == "seed" and #words >= 2 and #words <= 3
        and (words[2] == "flat" or words[2] == "nested" or words[2] == "tables" or words[2] == "clear")
        and seedCount(words[3], 8192, words[2]) then
        prepareSeed(words[2], seedCount(words[3], 8192, words[2]))
    elseif command == "runtime" and #words <= 2 and seedCount(words[2], 8192) then
        runtimeSeedTest(seedCount(words[2], 8192))
    elseif command == "watch" and #words <= 2 then
        local seconds = tonumber(words[2] or "60")
        if seconds and seconds % 1 == 0 and seconds >= 10 and seconds <= 120 then watch(seconds)
        else d(GetString(BATTLESCROLLS_MEMLAB_USAGE_WATCH)) end
    elseif command == "ability" and #words == 4
        and (words[2] == "name" or words[2] == "icon" or words[2] == "desc" or words[2] == "ctrl") then
        local first, count = tonumber(words[3]), tonumber(words[4])
        if first and count and first % 1 == 0 and count % 1 == 0
            and first >= 1 and first <= 1000000 and count >= 1 and count <= 256 then
            abilityTest(words[2], first, count)
        else d(GetString(BATTLESCROLLS_MEMLAB_USAGE_ABILITY)) end
    else
        d(GetString(BATTLESCROLLS_MEMLAB_USAGE))
        d(GetString(BATTLESCROLLS_MEMLAB_USAGE_SEED))
        d(GetString(BATTLESCROLLS_MEMLAB_USAGE_TABLES))
        d(GetString(BATTLESCROLLS_MEMLAB_USAGE_MIRROR))
        d(GetString(BATTLESCROLLS_MEMLAB_USAGE_ABILITY))
        d(GetString(BATTLESCROLLS_MEMLAB_USAGE_WATCH))
    end
end
