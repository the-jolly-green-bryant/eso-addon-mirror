-----------------------------------------------------------
-- Migration
-- One-time automatic upgrade of stored combat history to the
-- v17 binary format (varint rows, section mask, per-instance
-- ability/name registries, pooled setups, binary sharedData).
--
-- Runs on its own shortly after login when legacy encounters
-- exist. Per-instance transaction: every encounter is decoded,
-- re-encoded and decoded again, and the result is deep-verified
-- against the original BEFORE anything is committed. If any
-- encounter of an instance fails verification the whole
-- instance is left untouched in its old format (which stays
-- readable forever) and marked so it is not retried every
-- session. Interruption-safe: committed instances are detected
-- as migrated on the next load and skipped.
--
-- Memory pacing: one encounter is the unit of work; a full
-- confirmed GC collection runs between units (see
-- core/gc.lua CollectFullAsync). Migration pauses while the
-- player is in combat.
-----------------------------------------------------------

if not SemisPlaygroundCheckAccess() then
    return
end

BattleScrolls = BattleScrolls or {}

---@class MigrationModule
local migration = {}
BattleScrolls.migration = migration

local EVENT_NAMESPACE = "BattleScrolls_Migration"

---Delay after login before migration starts (let the world settle)
local START_DELAY_MS = 60000

---Poll interval while waiting out combat
local COMBAT_POLL_MS = 5000

---Tolerance for the 12-bit quantized percents of shared entries
local PERCENT_TOLERANCE = 1 / 4095

-- =============================================================================
-- VERIFICATION
-- =============================================================================

---Havok hstructures report type "struct" but iterate like tables.
---@param v any
---@return boolean
local function isTableLike(v)
    local t = type(v)
    return t == "table" or t == "struct"
end

---Deep-compares decoded encounter data. Numbers may differ by tolerance
---(used for the quantized percents of shared entries; 0 for encounter data).
---@param a any
---@param b any
---@param path string
---@param tolerance number
---@return boolean equal
---@return string|nil firstMismatch
local function deepEq(a, b, path, tolerance)
    if type(a) ~= type(b) then
        -- Absent v17 sections decode to canonical empty defaults
        if a == nil and type(b) == "table" and next(b) == nil then
            return true
        end
        if b == nil and type(a) == "table" and next(a) == nil then
            return true
        end
        return false, path .. " type " .. type(a) .. " vs " .. type(b)
    end
    if type(a) == "number" then
        if math.abs(a - b) > tolerance then
            return false, string.format("%s: %s vs %s", path, tostring(a), tostring(b))
        end
        return true
    end
    if not isTableLike(a) then
        if a ~= b then
            return false, string.format("%s: %s vs %s", path, tostring(a), tostring(b))
        end
        return true
    end
    for k, v in pairs(a) do
        local ok, err = deepEq(v, b[k], path .. "." .. tostring(k), tolerance)
        if not ok then
            return false, err
        end
    end
    for k, bv in pairs(b) do
        -- Mirror of the nil-vs-empty allowance above: decoders materialize
        -- canonical empty containers for fields older data never had
        if a[k] == nil and not (isTableLike(bv) and next(bv) == nil) then
            return false, path .. "." .. tostring(k) .. " unexpected in re-decode"
        end
    end
    return true
end

---Fields verified for the encounter round trip (setup included: migration
---commits the pool, so pooled setups resolve during verification).
local COMPARED_FIELDS = {
    "damageByUnitId", "damageByUnitIdGroup", "damageTakenByUnitId",
    "healingStats", "procs", "effectsOnPlayer", "effectsOnBosses",
    "effectsOnGroup", "bossNames", "playerAliveTimeMs", "unitAliveTimeMs",
    "unitNames", "deaths", "weaving", "setup",
}

-- =============================================================================
-- MIGRATION
-- =============================================================================

---@param chunks string[]|nil
---@return number chars
local function chunkChars(chunks)
    local total = 0
    for _, chunk in ipairs(chunks or {}) do
        total = total + #chunk
    end
    return total
end

---@param encounter CompactEncounter
---@return boolean
local function encounterIsLegacy(encounter)
    return (encounter._v or 0) < BattleScrolls.binaryStorage.CURRENT_VERSION
        or encounter.sharedData ~= nil
end

---Conservative check backing the persistent savedVariables.migrationDoneV18
---flag: no encounter anywhere may be legacy, INCLUDING the live instance
---(which the migration run itself skips - it must stay reachable in a later
---session). Failed instances are excluded: they intentionally stay legacy
---forever. Covers new installations too - an empty history passes.
---@return boolean
local function everythingMigrated()
    for _, instance in ipairs(BattleScrolls.storage.savedVariables.history) do
        if not instance._migrationFailed then
            for _, encounter in ipairs(instance.encounters) do
                if encounterIsLegacy(encounter) then
                    return false
                end
            end
        end
    end
    return true
end

---@param instance InstanceWithIndex
---@return boolean
local function instanceNeedsMigration(instance)
    if instance._migrationFailed then
        return false
    end
    -- The live instance is owned by scribe (registry, appends); it migrates
    -- in a later session once left
    if instance == BattleScrolls.scribe.instance then
        return false
    end
    for _, encounter in ipairs(instance.encounters) do
        if encounterIsLegacy(encounter) then
            return true
        end
    end
    return false
end

---@generic T
---@param arr T[]
---@return T[]
local function copyArray(arr)
    local copy = {}
    for i, v in ipairs(arr) do
        copy[i] = v
    end
    return copy
end

---Blocks (async) while the player is in combat.
local function waitOutCombat()
    while BattleScrolls.state.inCombat do
        LibEffect.Sleep(COMBAT_POLL_MS):Await()
    end
end

---@class MigrationTotals
---@field migrated number Encounters successfully re-encoded
---@field poolGrowth number Estimated memory of setup-pool entries created while migrating

---Re-encodes one legacy encounter and verifies the result.
---@param encounter CompactEncounter
---@param instance InstanceWithIndex
---@param staged EncounterRegistry
---@return CompactEncounter|nil reencoded Nil when decode/verify failed
---@return string|nil failReason
---@return number|nil poolGrowthBytes Estimated memory of a pool entry newly created for this setup
local function migrateEncounter(encounter, instance, staged)
    local binaryStorage = BattleScrolls.binaryStorage

    ---@type Encounter|nil
    local decoded = BattleScrolls.storage.DecodeEncounterAsync(encounter, instance)
        :Recover(function() return nil end):Await()
    if not decoded then
        return nil, "decode failed"
    end

    -- Setup: normalize historical volatility, then pool the build
    local pooled = false
    local setupHash = nil
    local poolGrowthBytes = 0
    if decoded.setup then
        BattleScrolls.setupCapture.normalizeSetup(decoded.setup)
        local setupShare = BattleScrolls.setupShare
        setupHash = setupShare.computeHash(setupShare.convertToCompact(decoded.setup))
        local ownSetups = BattleScrolls.storage.savedVariables.ownSetups
        local existedBefore = ownSetups ~= nil and ownSetups[setupHash] ~= nil
        pooled = BattleScrolls.storage:InternOwnSetup(setupHash, decoded.setup)
        if pooled and not existedBefore then
            -- Charge new pool entries against the freed total
            poolGrowthBytes = BattleScrolls.storage:EstimateValueMemory(
                BattleScrolls.storage.savedVariables.ownSetups[setupHash])
        end
    end

    ---@type CompactEncounter|nil
    local reencoded = binaryStorage.encodeEncounterAsync(decoded, pooled, staged)
        :Recover(function() return nil end):Await()
    if not reencoded then
        return nil, "re-encode failed", poolGrowthBytes
    end
    -- A correct v17 re-encode never inflates the stream (denser format,
    -- canonical encoder). Growth means the legacy decode fabricated data
    -- from a misparsed stream - garbage that would pass the round-trip
    -- verification below faithfully
    local oldChars = chunkChars(encounter._data)
    local newChars = chunkChars(reencoded._data)
    if newChars > oldChars + 512 then
        return nil, string.format("re-encode grew %d -> %d chars", oldChars, newChars), poolGrowthBytes
    end
    if pooled then
        reencoded._setupHash = setupHash
    end
    -- Compact-only metadata the decode does not carry
    reencoded.gameVersion = encounter.gameVersion

    -- Shared entries: plain -> binary sibling
    reencoded.sharedData = nil
    local oldShared = decoded.sharedData
    if oldShared then
        local compactShared = {}
        for i, entry in ipairs(oldShared) do
            compactShared[i] = binaryStorage.encodeSharedEntry(entry)
        end
        reencoded._shared = compactShared
    end

    -- Verify the full round trip before this encounter may be committed
    ---@type Encounter|nil
    local redecoded = binaryStorage.decodeEncounterAsync(reencoded, staged)
        :Recover(function() return nil end):Await()
    if not redecoded then
        return nil, "verify decode failed", poolGrowthBytes
    end
    for _, field in ipairs(COMPARED_FIELDS) do
        local ok, err = deepEq(decoded[field], redecoded[field], field, 0)
        if not ok then
            return nil, err, poolGrowthBytes
        end
    end
    if oldShared then
        local ok, err = deepEq(oldShared, redecoded.sharedData, "sharedData", PERCENT_TOLERANCE)
        if not ok then
            return nil, err, poolGrowthBytes
        end
    end

    return reencoded, nil, poolGrowthBytes
end

---Migrates one instance transactionally. Commits only when every encounter
---verified; otherwise the instance is left untouched.
---@param instance InstanceWithIndex
---@param totals MigrationTotals
---@return boolean committed
local function migrateInstance(instance, totals)
    local binaryStorage = BattleScrolls.binaryStorage

    -- Stage a registry seeded from the instance's existing one (mixed
    -- instances may already hold v17 encounters whose indices must survive)
    local existing = BattleScrolls.storage:GetInstanceRegistryAsync(instance):Await()
    local staged = binaryStorage.newRegistry(copyArray(existing.abilityIds), copyArray(existing.names))

    ---@type table<number, AbilityInfo>
    local abilityInfo
    if instance.abilityInfo then
        abilityInfo = instance.abilityInfo
    elseif instance._instanceData then
        abilityInfo = binaryStorage.decodeInstanceFieldsAsync(instance):Await()[1]
    else
        abilityInfo = {}
    end

    local newEncounters = {}
    local migratedHere = 0

    for i, encounter in ipairs(instance.encounters) do
        if not encounterIsLegacy(encounter) then
            newEncounters[i] = encounter
        else
            waitOutCombat()

            local reencoded, failReason, poolGrowthBytes = migrateEncounter(encounter, instance, staged)
            -- Interned pool entries persist even when the instance later
            -- fails verification, so charge them unconditionally
            totals.poolGrowth = totals.poolGrowth + (poolGrowthBytes or 0)
            if not reencoded then
                BattleScrolls.log.Warn(string.format(
                    "Migration: instance %d encounter %d failed verification (%s), leaving instance in old format",
                    instance.index or -1, i, failReason or "?"))
                return false
            end
            newEncounters[i] = reencoded
            migratedHere = migratedHere + 1

            -- One encounter is the unit of work: do not start the next burst
            -- until this one's garbage is confirmed reclaimed
            BattleScrolls.gc:CollectFullAsync():Await()
        end
    end

    -- Commit: swap encounters and persist the staged registries atomically
    instance.encounters = newEncounters
    local encodedFields = binaryStorage.encodeInstanceFieldsAsync(abilityInfo, staged):Await()
    instance._instanceData = encodedFields._instanceData
    instance._instanceDataVersion = encodedFields._instanceDataVersion
    instance._estimatedSize = nil
    BattleScrolls.storage:CacheInstanceRegistry(instance, staged)

    totals.migrated = totals.migrated + migratedHere
    return true
end

---Center-screen announcement (discovered-location style). Console chat boxes
---clip long messages; CSAs are the base game's channel for event one-liners.
---@param secondaryText string
---@param sound string
local function announce(secondaryText, sound)
    ---@diagnostic disable-next-line: undefined-field -- CreateMessageParams missing from the CSA stub
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, sound)
    messageParams:SetText(GetString(BATTLESCROLLS_UI_NAME), secondaryText)
    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
    ---@diagnostic disable-next-line: undefined-field -- AddMessageWithParams missing from the CSA stub
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

---Sums the estimated memory of the whole history exactly the way the
---settings tooltip does (per-instance walks, cached in _estimatedSize),
---yielding between instances. Commits invalidate migrated instances'
---caches, so the after-pass re-walks precisely those.
---@return number bytes
local function historyMemoryAsync()
    local totalBytes = 0
    for _, instance in ipairs(BattleScrolls.storage.savedVariables.history) do
        totalBytes = totalBytes + BattleScrolls.storage:EstimateInstanceSize(instance)
        LibEffect.YieldWithGC():Await()
    end
    return totalBytes
end

local function runMigrationAsync()
    LibEffect.Async(function()
        -- DEFER_NOTIFICATION: audible but soft (MESSAGE_BROADCAST is silent,
        -- quest/objective sounds demand too much attention)
        announce(GetString(BATTLESCROLLS_MIGRATION_START), SOUNDS.DEFER_NOTIFICATION)

        ---@type MigrationTotals
        local totals = { migrated = 0, poolGrowth = 0 }
        local history = BattleScrolls.storage.savedVariables.history
        local historyBefore = historyMemoryAsync()

        for _, instance in ipairs(history) do
            if instanceNeedsMigration(instance) then
                waitOutCombat()
                if not migrateInstance(instance, totals) then
                    -- Not user-facing: nothing actionable, the old format
                    -- stays readable. Details are in the Warn log.
                    instance._migrationFailed = true
                end
            end
        end

        -- Freed = the actual change of the settings "History" figure, minus
        -- what the setup pool (stored beside history) gained. Decimal MB,
        -- matching the settings tooltip's currency. Observed on the real
        -- Xbox run: the Add-On Memory gauge showed this drop only after the
        -- next UI reload - freeing long-lived data may not register
        -- in-session (core/gc.lua header).
        local freedMb = math.max(0,
            historyBefore - historyMemoryAsync() - totals.poolGrowth) / 1000000
        announce(zo_strformat(GetString(BATTLESCROLLS_MIGRATION_DONE),
            totals.migrated, string.format("%.1f", freedMb)), SOUNDS.QUEST_COMPLETED)
        if totals.migrated > 0 then
            -- The one durable takeaway goes to chat (short enough to fit);
            -- default-yellow prefix + white body, matching core/log.lua
            d(string.format("[%s]|cffffff %s",
                GetString(BATTLESCROLLS_UI_NAME), GetString(BATTLESCROLLS_MIGRATION_TIP)))
        end

        if everythingMigrated() then
            BattleScrolls.storage.savedVariables.migrationDoneV18 = true
        end

        BattleScrolls.gc:RequestGC(2)
    end):Run()
end

---Schedules the migration when legacy encounters exist. Once the persistent
---migrationDoneV18 flag is set this is a no-op forever. Until then, the
---first activation decides for the whole session (the scan is a couple of
---field reads per stored encounter, no decoding); remaining legacy
---instances (interrupted session, live instance, failed ones excluded) are
---picked up on later loads. The flag is versioned so a format bump only
---has to introduce a fresh flag name to re-arm the whole pipeline (the v17
---run's flag was migrationDone; its stale key is cleared below).
function migration:Initialize()
    BattleScrolls.storage.savedVariables.migrationDone = nil
    if BattleScrolls.storage.savedVariables.migrationDoneV18 then
        return
    end
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED)
        if everythingMigrated() then
            BattleScrolls.storage.savedVariables.migrationDoneV18 = true
            return
        end
        for _, instance in ipairs(BattleScrolls.storage.savedVariables.history) do
            if instanceNeedsMigration(instance) then
                zo_callLater(runMigrationAsync, START_DELAY_MS)
                return
            end
        end
        -- Legacy data exists but only where this session cannot touch it
        -- (the live instance); the next session picks it up
    end)
end
