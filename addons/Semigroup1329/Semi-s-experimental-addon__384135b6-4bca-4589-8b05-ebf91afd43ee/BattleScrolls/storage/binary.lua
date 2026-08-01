if not SemisPlaygroundCheckAccess() then
    return
end

-- Binary Storage Encoding Module for BattleScrolls
-- Encounter and instance encoding/decoding using BitEncoder/BitDecoder from bitcodec.lua

BattleScrolls = BattleScrolls or {}

---Binary storage module for encoding/decoding combat data
---@class BinaryStorage
local binaryStorage = {}
BattleScrolls.binaryStorage = binaryStorage

local CURRENT_VERSION = 17

-- Import BitEncoder/BitDecoder from bitcodec module
local BitEncoder = BattleScrolls.bitcodec.BitEncoder
local BitDecoder = BattleScrolls.bitcodec.BitDecoder

-- =============================================================================
-- BIT ALLOCATION CONSTANTS
-- =============================================================================

---Bit width constants for binary encoding/decoding
---@class BitWidthConstants
---@field TOTAL number 30 bits - damage/healing totals (up to ~1 billion)
---@field TICK_VALUE number 24 bits - individual tick values (up to 16M)
---@field COUNT number 16 bits - tick/proc counts (up to 65535)
---@field ABILITY_ID number 20 bits - ability IDs (up to 1M, ESO uses ~200K)
---@field UNIT_ID number 24 bits - unit IDs (up to 16M)
---@field TIME_MS number 24 bits - duration/time in ms (up to ~4.6 hours)
---@field EFFECT_TYPE number 4 bits - effect type enum (up to 16 types)
---@field MAX_STACKS number 4 bits - max stacks (up to 15)
---@field APPLICATIONS number 12 bits - effect applications (up to 4095)
---@field INTERVAL_MS number 16 bits - proc interval in ms (up to 65535)
---@field MAP_COUNT number 16 bits - map/array count (up to 65535 entries)

---@type BitWidthConstants
local BITS = {
    -- Damage/healing totals (30 bits = up to ~1 billion)
    TOTAL = 30,

    -- Individual tick values (24 bits = up to 16M)
    TICK_VALUE = 24,

    -- Counts (16 bits = up to 65535)
    COUNT = 16,

    -- Ability ID (20 bits = up to 1M, ESO uses ~200K)
    ABILITY_ID = 20,

    -- Unit ID (24 bits = up to 16M)
    UNIT_ID = 24,

    -- Duration/time in ms (24 bits = up to ~4.6 hours)
    TIME_MS = 24,

    -- Effect type (4 bits = up to 16 types)
    EFFECT_TYPE = 4,

    -- Max stacks (4 bits = up to 15 stacks)
    MAX_STACKS = 4,

    -- Applications (12 bits = up to 4095)
    APPLICATIONS = 12,

    -- Proc interval (16 bits = up to 65535 ms)
    INTERVAL_MS = 16,

    -- Map/array count (16 bits = up to 65535 entries)
    MAP_COUNT = 16,

    -- Death attack count (3 bits = up to 6 attacks per recap)
    DEATH_ATTACK_COUNT = 3,

    -- Setup encoding (v9+)
    CHAMPION_SKILL_ID = 16,
    DISCIPLINE_ID = 8,
    CHAMPION_COUNT = 6,
    SCRIPT_ID = 16,
    CRAFTED_ABILITY_ID = 16,

    RACE_ID = 8,
    CLASS_ID = 8,
    SKILL_LINE_ID = 16,
    CLASS_MASTERY_ABILITY_COUNT = 3,
    MUNDUS_COUNT = 2,
    FOOD_COUNT = 2,
    WEAPON_TYPE = 5,
    VENGEANCE_PERK_DEF_ID = 20,
}

local EQUIP_SLOT_COUNT = 14

-- v17: encounters start with a 16-bit section-presence bitmask; empty sections
-- are omitted entirely and reconstructed as defaults on decode. Bit indices
-- must never be reordered - append only.
local SECTION = {
    DAMAGE = 1,
    DAMAGE_GROUP = 2,
    DAMAGE_TAKEN = 3,
    HEALING = 4,
    PROCS = 5,
    EFFECTS_PLAYER = 6,
    EFFECTS_BOSSES = 7,
    EFFECTS_GROUP = 8,
    BOSS_NAMES = 9,
    PLAYER_ALIVE_TIME = 10,
    UNIT_ALIVE_TIMES = 11,
    UNIT_NAMES = 12,
    DEATHS = 13,
    SETUP = 14,
    WEAVING = 15,
}

---@param mask number
---@param sectionBit number SECTION.* index
---@return boolean
local function hasSection(mask, sectionBit)
    return BitAnd(BitRShift(mask, sectionBit - 1), 1) == 1
end

-- Retained cap from the fixed 16-bit MAP_COUNT era: bounds decode loops even
-- on corrupt data.
local MAX_MAP_COUNT = 65535

---Reads a value that was fixed-width pre-v17 and varint from v17 on.
---@param decoder BitDecoder
---@param version number
---@param bits number Fixed width used before v17
---@return number
local function readVal(decoder, version, bits)
    if version >= 17 then
        return decoder:readVarUInt()
    end
    return decoder:readUInt(bits)
end

---Reads a map/array count (fixed MAP_COUNT pre-v17, varint v17+), clamped.
---@param decoder BitDecoder
---@param version number
---@return number
local function readMapCount(decoder, version)
    local count
    if version >= 17 then
        count = decoder:readVarUInt()
    else
        count = decoder:readUInt(BITS.MAP_COUNT)
    end
    if count > MAX_MAP_COUNT then
        count = MAX_MAP_COUNT
    end
    return count
end

---Writes a signed integer as a zigzag varint (byte-aligned, unlike a sign bit)
---@param encoder BitEncoder
---@param value number
local function writeZigZag(encoder, value)
    if value >= 0 then
        encoder:writeVarUInt(value * 2)
    else
        encoder:writeVarUInt(-value * 2 - 1)
    end
end

---@param decoder BitDecoder
---@return number
local function readZigZag(decoder)
    local n = decoder:readVarUInt()
    if n % 2 == 0 then
        return n / 2
    end
    return -(n + 1) / 2
end

-- =============================================================================
-- PER-INSTANCE REGISTRIES (v17+)
-- Ability ids and name strings repeat heavily across an instance's encounters,
-- so encounters store small varint indices into append-only per-instance
-- arrays persisted in _instanceData. Unit ids stay raw: they are
-- session-scoped and can collide across game restarts, so they must never be
-- interned across encounters.
-- =============================================================================

---@class RegistryArrays
---@field abilityIds number[] Append-only ability id list (1-based index -> id)
---@field names string[] Append-only string pool (1-based index -> name)

---@class EncounterRegistry : RegistryArrays
---@field abilityIndex table<number, number> Reverse lookup id -> index
---@field nameIndex table<string, number> Reverse lookup string -> index

---Creates an encode-capable registry from (possibly existing) arrays,
---building the reverse lookups. The arrays are kept by reference and appended
---to as new abilities/names are interned.
---@param abilityIds number[]|nil
---@param names string[]|nil
---@return EncounterRegistry
function binaryStorage.newRegistry(abilityIds, names)
    abilityIds = abilityIds or {}
    names = names or {}
    local abilityIndex = {}
    local nameIndex = {}
    for i, id in ipairs(abilityIds) do
        abilityIndex[id] = i
    end
    for i, name in ipairs(names) do
        nameIndex[name] = i
    end
    return {
        abilityIds = abilityIds,
        names = names,
        abilityIndex = abilityIndex,
        nameIndex = nameIndex,
    }
end

---Writes an ability reference as a 0-based varint registry index, interning
---new ids on first use.
---@param encoder BitEncoder
---@param registry EncounterRegistry
---@param abilityId number|nil
local function writeAbilityRef(encoder, registry, abilityId)
    abilityId = abilityId or 0
    local index = registry.abilityIndex[abilityId]
    if not index then
        index = #registry.abilityIds + 1
        registry.abilityIds[index] = abilityId
        registry.abilityIndex[abilityId] = index
    end
    encoder:writeVarUInt(index - 1)
end

---@param decoder BitDecoder
---@param registry RegistryArrays
---@return number abilityId
local function readAbilityRef(decoder, registry)
    local index = decoder:readVarUInt() + 1
    local abilityId = registry.abilityIds[index]
    if not abilityId then
        error("Corrupt ability registry reference: " .. tostring(index))
    end
    return abilityId
end

---Writes a name/string reference as a 0-based varint registry index.
---@param encoder BitEncoder
---@param registry EncounterRegistry
---@param name string|nil
local function writeNameRef(encoder, registry, name)
    name = name or ""
    local index = registry.nameIndex[name]
    if not index then
        index = #registry.names + 1
        registry.names[index] = name
        registry.nameIndex[name] = index
    end
    encoder:writeVarUInt(index - 1)
end

---@param decoder BitDecoder
---@param registry RegistryArrays
---@return string name
local function readNameRef(decoder, registry)
    local index = decoder:readVarUInt() + 1
    local name = registry.names[index]
    if not name then
        error("Corrupt name registry reference: " .. tostring(index))
    end
    return name
end

-- Number of encoded items (breakdowns, healing breakdowns, effect stats, etc.)
-- between yield checkpoints. Each item averages ~8-10 writeUInt calls, but the
-- slow path for non-byte-aligned writes (30-bit damage totals) roughly doubles
-- the cost
local ITEMS_PER_YIELD = 50

---@class EncodeProgress
---@field count number Items encoded since last yield

---Increments progress counter and yields if threshold reached.
---Must only be called from within a LibEffect.Async coroutine.
---GC is not requested here — the encoding loop is nearly allocation-free.
---The caller (scribe) handles GC before and after encoding.
---@param progress EncodeProgress
local function countAndMaybeYield(progress)
    progress.count = progress.count + 1
    if progress.count >= ITEMS_PER_YIELD then
        progress.count = 0
        LibEffect.Yield():Await()
    end
end

---Yields if any items have been counted since last yield (flushes remaining work)
---@param progress EncodeProgress
local function flushProgress(progress)
    if progress.count > 0 then
        progress.count = 0
        LibEffect.Yield():Await()
    end
end

---Writes a count value clamped to the max representable value for the bit width.
---Returns the clamped count for use as a loop bound.
---@param encoder BitEncoder
---@param count number
---@param bits number
---@return number clampedCount
local function writeCount(encoder, count, bits)
    local maxVal = BitLShift(1, bits) - 1
    if count > maxVal then count = maxVal end
    encoder:writeUInt(count, bits)
    return count
end

---Writes a map/array count as varint (v17+), clamped to MAX_MAP_COUNT.
---@param encoder BitEncoder
---@param count number
---@return number clampedCount
local function writeVarCount(encoder, count)
    if count > MAX_MAP_COUNT then
        count = MAX_MAP_COUNT
    end
    encoder:writeVarUInt(count)
    return count
end

---Counts entries in a hash table, writes the count as varint, returns it.
---@param encoder BitEncoder
---@param tbl table
---@return number clampedCount
local function writeTableVarCount(encoder, tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return writeVarCount(encoder, count)
end

---Counts entries in a hash table, writes the clamped count, returns the clamped count.
---@param encoder BitEncoder
---@param tbl table
---@param bits number
---@return number clampedCount
local function writeTableCount(encoder, tbl, bits)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return writeCount(encoder, count, bits)
end


-- =============================================================================
-- LOW-LEVEL WRITE HELPERS
-- =============================================================================

---Writes a DamageBreakdown to encoder
---@param encoder BitEncoder
---@param breakdown DamageBreakdown
local function writeDamageBreakdown(encoder, breakdown)
    local total = breakdown.total or 0
    local rawTotal = breakdown.rawTotal or total
    local minTick = breakdown.minTick or 0
    local maxTick = breakdown.maxTick or 0
    -- rawTotal == total on every non-killing blow; the "differs" flag rides in
    -- bit 0 of the total varint to keep the stream byte-aligned
    if rawTotal == total then
        encoder:writeVarUInt(total * 2)
    else
        encoder:writeVarUInt(total * 2 + 1)
        encoder:writeVarUInt(rawTotal - total)
    end
    encoder:writeVarUInt(breakdown.ticks or 0)
    encoder:writeVarUInt(breakdown.critTicks or 0)
    encoder:writeVarUInt(minTick)
    encoder:writeVarUInt(maxTick - minTick)
end

---Reads a DamageBreakdown from decoder
---@param decoder BitDecoder
---@param version number
---@return DamageBreakdown
local function readDamageBreakdown(decoder, version)
    if version >= 17 then
        local packed = decoder:readVarUInt()
        local total = math.floor(packed / 2)
        local rawTotal = total
        if packed % 2 == 1 then
            rawTotal = total + decoder:readVarUInt()
        end
        local ticks = decoder:readVarUInt()
        local critTicks = decoder:readVarUInt()
        local minTick = decoder:readVarUInt()
        local maxTick = minTick + decoder:readVarUInt()
        return BattleScrolls.structures.makeDamageBreakdown(
            total, rawTotal, ticks, critTicks, minTick, maxTick)
    end
    return BattleScrolls.structures.makeDamageBreakdown(
        decoder:readUInt(BITS.TOTAL),
        decoder:readUInt(BITS.TOTAL),
        decoder:readUInt(BITS.COUNT),
        decoder:readUInt(BITS.COUNT),
        decoder:readUInt(BITS.TICK_VALUE),
        decoder:readUInt(BITS.TICK_VALUE)
    )
end

---Writes a HealingTotals to encoder
---@param encoder BitEncoder
---@param totals HealingTotals|nil
local function writeHealingTotals(encoder, totals)
    -- raw = real + overheal, so it is derived on read instead of stored
    encoder:writeVarUInt(totals and totals.real or 0)
    encoder:writeVarUInt(totals and totals.overheal or 0)
end

---Reads a HealingTotals from decoder
---@param decoder BitDecoder
---@param version number
---@return HealingTotals
local function readHealingTotals(decoder, version)
    if version >= 17 then
        local real = decoder:readVarUInt()
        local overheal = decoder:readVarUInt()
        return BattleScrolls.structures.makeHealingTotals(real + overheal, real, overheal)
    end
    return BattleScrolls.structures.makeHealingTotals(
        decoder:readUInt(BITS.TOTAL),
        decoder:readUInt(BITS.TOTAL),
        decoder:readUInt(BITS.TOTAL)
    )
end

---Writes a HealingBreakdown to encoder
---@param encoder BitEncoder
---@param breakdown HealingBreakdown
local function writeHealingBreakdown(encoder, breakdown)
    local minTick = breakdown.minTick or 0
    local maxTick = breakdown.maxTick or 0
    -- raw = real + overheal, derived on read
    encoder:writeVarUInt(breakdown.real or 0)
    encoder:writeVarUInt(breakdown.overheal or 0)
    encoder:writeVarUInt(breakdown.ticks or 0)
    encoder:writeVarUInt(breakdown.critTicks or 0)
    encoder:writeVarUInt(minTick)
    encoder:writeVarUInt(maxTick - minTick)
end

---Reads a HealingBreakdown from decoder
---@param decoder BitDecoder
---@param version number
---@return HealingBreakdown
local function readHealingBreakdown(decoder, version)
    if version >= 17 then
        local real = decoder:readVarUInt()
        local overheal = decoder:readVarUInt()
        local ticks = decoder:readVarUInt()
        local critTicks = decoder:readVarUInt()
        local minTick = decoder:readVarUInt()
        local maxTick = minTick + decoder:readVarUInt()
        return BattleScrolls.structures.makeHealingBreakdown(
            real + overheal, real, overheal, ticks, critTicks, minTick, maxTick)
    end
    return BattleScrolls.structures.makeHealingBreakdown(
        decoder:readUInt(BITS.TOTAL),
        decoder:readUInt(BITS.TOTAL),
        decoder:readUInt(BITS.TOTAL),
        decoder:readUInt(BITS.COUNT),
        decoder:readUInt(BITS.COUNT),
        decoder:readUInt(BITS.TICK_VALUE),
        decoder:readUInt(BITS.TICK_VALUE)
    )
end

---Writes an EffectStats to encoder
---@param encoder BitEncoder
---@param stats EffectStats
local function writeEffectStats(encoder, stats, registry, abilityId)
    local totalActive = stats.totalActiveTimeMs or 0
    local timeAtMax = stats.timeAtMaxStacksMs or 0
    local applications = stats.applications or 0
    local playerActive = stats.playerActiveTimeMs or 0
    local playerTimeAtMax = stats.playerTimeAtMaxStacksMs or 0
    local playerApplications = stats.playerApplications or 0
    local peak = stats.peakConcurrentInstances or 1
    local maxStacks = stats.maxStacks or 0
    if maxStacks > 15 then
        maxStacks = 15
    end

    writeAbilityRef(encoder, registry, abilityId or stats.abilityId)

    -- Equality flags: the common cases (non-stacking effects, self-applied
    -- effects, no concurrent instances) duplicate fields exactly. Packed with
    -- the effect type into one byte to keep the stream byte-aligned.
    local timeAtMaxSame = timeAtMax == totalActive
    local playerSame = playerActive == totalActive
        and playerTimeAtMax == timeAtMax
        and playerApplications == applications
    local peakOne = peak == 1
    encoder:writeUInt(
        (stats.effectType or 0) % 16 * 16
        + (timeAtMaxSame and 8 or 0)
        + (playerSame and 4 or 0)
        + (peakOne and 2 or 0), 8)

    encoder:writeVarUInt(totalActive)
    encoder:writeVarUInt(applications * 16 + maxStacks)
    if not timeAtMaxSame then
        encoder:writeVarUInt(timeAtMax)
    end
    if not playerSame then
        encoder:writeVarUInt(playerActive)
        encoder:writeVarUInt(playerTimeAtMax)
        encoder:writeVarUInt(playerApplications)
    end
    if not peakOne then
        encoder:writeVarUInt(peak)
    end
end

---Reads an EffectStats from decoder
---@param decoder BitDecoder
---@param version number
---@return EffectStats
local function readEffectStats(decoder, version, registry)
    if version >= 17 then
        local abilityId = readAbilityRef(decoder, registry)
        local packed = decoder:readUInt(8)
        local effectType = math.floor(packed / 16)
        local timeAtMaxSame = packed % 16 >= 8
        local playerSame = packed % 8 >= 4
        local peakOne = packed % 4 >= 2

        local totalActive = decoder:readVarUInt()
        local appsPacked = decoder:readVarUInt()
        local applications = math.floor(appsPacked / 16)
        local maxStacks = appsPacked % 16

        local timeAtMax = totalActive
        if not timeAtMaxSame then
            timeAtMax = decoder:readVarUInt()
        end

        local playerActive, playerTimeAtMax, playerApplications
        if playerSame then
            playerActive, playerTimeAtMax, playerApplications = totalActive, timeAtMax, applications
        else
            playerActive = decoder:readVarUInt()
            playerTimeAtMax = decoder:readVarUInt()
            playerApplications = decoder:readVarUInt()
        end

        local peak = 1
        if not peakOne then
            peak = decoder:readVarUInt()
        end

        return BattleScrolls.structures.makeEffectStats(
            abilityId, effectType, totalActive, timeAtMax, applications, maxStacks,
            playerActive, playerTimeAtMax, playerApplications, peak)
    end
    return BattleScrolls.structures.makeEffectStats(
        decoder:readUInt(BITS.ABILITY_ID),
        decoder:readUInt(BITS.EFFECT_TYPE),
        decoder:readUInt(BITS.TIME_MS),
        decoder:readUInt(BITS.TIME_MS),
        decoder:readUInt(BITS.APPLICATIONS),
        decoder:readUInt(BITS.MAX_STACKS),
        decoder:readUInt(BITS.TIME_MS),
        decoder:readUInt(BITS.TIME_MS),
        decoder:readUInt(BITS.APPLICATIONS),
        decoder:readUInt(BITS.MAX_STACKS)
    )
end

-- =============================================================================
-- DAMAGE MAP ENCODING (nested: sourceId -> targetId -> abilityId -> breakdown)
-- =============================================================================

---Writes a damage map to encoder
---@param encoder BitEncoder
---@param damageMap table<number, table<number, DamageDone|DamageByAbility>>|nil Nested: sourceId -> targetId -> damage
---@param progress EncodeProgress
local function writeDamageMap(encoder, damageMap, registry, progress)
    local sourceCount = writeTableVarCount(encoder, damageMap or {})

    local sourcesWritten = 0
    for sourceId, byTarget in pairs(damageMap or {}) do
        if sourcesWritten >= sourceCount then break end
        sourcesWritten = sourcesWritten + 1
        encoder:writeVarUInt(sourceId)

        local targetCount = writeTableVarCount(encoder, byTarget)

        local targetsWritten = 0
        for targetId, damageDone in pairs(byTarget) do
            if targetsWritten >= targetCount then break end
            targetsWritten = targetsWritten + 1
            encoder:writeVarUInt(targetId)

            local byAbility = damageDone.byAbilityId or damageDone
            local abilityCount = writeTableVarCount(encoder, byAbility)

            local abilitiesWritten = 0
            for abilityId, breakdown in pairs(byAbility) do
                if abilitiesWritten >= abilityCount then break end
                abilitiesWritten = abilitiesWritten + 1
                writeAbilityRef(encoder, registry, abilityId)
                writeDamageBreakdown(encoder, breakdown)
                countAndMaybeYield(progress)
            end
        end
    end
end

---Reads a damage map from decoder
---@param decoder BitDecoder
---@param version number
---@return table<number, table<number, DamageByAbility>> Nested: sourceId -> targetId -> (abilityId -> DamageBreakdown)
local function readDamageMap(decoder, version, registry)
    local result = {}
    local sourceCount = readMapCount(decoder, version)

    for _ = 1, sourceCount do
        local sourceId = readVal(decoder, version, BITS.UNIT_ID)
        result[sourceId] = {}

        local targetCount = readMapCount(decoder, version)
        for _ = 1, targetCount do
            local targetId = readVal(decoder, version, BITS.UNIT_ID)
            result[sourceId][targetId] = {}

            local abilityCount = readMapCount(decoder, version)
            for _ = 1, abilityCount do
                local abilityId
                if version >= 17 then
                    abilityId = readAbilityRef(decoder, registry)
                else
                    abilityId = decoder:readUInt(BITS.ABILITY_ID)
                end
                result[sourceId][targetId][abilityId] = readDamageBreakdown(decoder, version)
            end
        end
    end

    return result
end

-- =============================================================================
-- HEALING STATS ENCODING
-- =============================================================================

---Writes HealingDoneDiffSource to encoder
---@param encoder BitEncoder
---@param healing HealingDoneDiffSource
---@param progress EncodeProgress
local function writeHealingDoneDiffSource(encoder, healing, registry, progress)
    writeHealingTotals(encoder, healing.total)
    -- v6+: byHotVsDirect computed on-demand from byAbilityId + abilityInfo

    local sourceCount = writeTableVarCount(encoder, healing.bySourceUnitIdByAbilityId or {})

    local sourcesWritten = 0
    for sourceId, byAbility in pairs(healing.bySourceUnitIdByAbilityId or {}) do
        if sourcesWritten >= sourceCount then break end
        sourcesWritten = sourcesWritten + 1
        encoder:writeVarUInt(sourceId)

        local abilityCount = writeTableVarCount(encoder, byAbility)

        local abilitiesWritten = 0
        for abilityId, breakdown in pairs(byAbility) do
            if abilitiesWritten >= abilityCount then break end
            abilitiesWritten = abilitiesWritten + 1
            writeAbilityRef(encoder, registry, abilityId)
            writeHealingBreakdown(encoder, breakdown)
            countAndMaybeYield(progress)
        end
    end
end

---Reads HealingDoneDiffSource from decoder
---@param decoder BitDecoder
---@param version number
---@return HealingDoneDiffSource
local function readHealingDoneDiffSource(decoder, version, registry)
    local result = {
        total = readHealingTotals(decoder, version),
        bySourceUnitIdByAbilityId = {},
    }

    local sourceCount = readMapCount(decoder, version)
    for _ = 1, sourceCount do
        local sourceId = readVal(decoder, version, BITS.UNIT_ID)
        result.bySourceUnitIdByAbilityId[sourceId] = {}

        local abilityCount = readMapCount(decoder, version)
        for _ = 1, abilityCount do
            local abilityId
            if version >= 17 then
                abilityId = readAbilityRef(decoder, registry)
            else
                abilityId = decoder:readUInt(BITS.ABILITY_ID)
            end
            result.bySourceUnitIdByAbilityId[sourceId][abilityId] = readHealingBreakdown(decoder, version)
        end
    end

    return result
end

---Writes HealingDone to encoder
---@param encoder BitEncoder
---@param healing HealingDone
---@param progress EncodeProgress
local function writeHealingDone(encoder, healing, registry, progress)
    writeHealingTotals(encoder, healing.total)
    -- v6+: byHotVsDirect computed on-demand from byAbilityId + abilityInfo

    local abilityCount = writeTableVarCount(encoder, healing.byAbilityId or {})

    local abilitiesWritten = 0
    for abilityId, breakdown in pairs(healing.byAbilityId or {}) do
        if abilitiesWritten >= abilityCount then break end
        abilitiesWritten = abilitiesWritten + 1
        writeAbilityRef(encoder, registry, abilityId)
        writeHealingBreakdown(encoder, breakdown)
        countAndMaybeYield(progress)
    end
end

---Reads HealingDone from decoder
---@param decoder BitDecoder
---@param version number
---@return HealingDone
local function readHealingDone(decoder, version, registry)
    local result = {
        total = readHealingTotals(decoder, version),
        byAbilityId = {},
    }

    local abilityCount = readMapCount(decoder, version)
    for _ = 1, abilityCount do
        local abilityId
        if version >= 17 then
            abilityId = readAbilityRef(decoder, registry)
        else
            abilityId = decoder:readUInt(BITS.ABILITY_ID)
        end
        result.byAbilityId[abilityId] = readHealingBreakdown(decoder, version)
    end

    return result
end

---Writes HealingStats to encoder
---@param encoder BitEncoder
---@param healingStats HealingStats
---@param progress EncodeProgress
local function writeHealingStats(encoder, healingStats, registry, progress)
    writeHealingDoneDiffSource(encoder, healingStats.selfHealing, registry, progress)

    -- healingOutToGroup
    local outCount = writeTableVarCount(encoder, healingStats.healingOutToGroup or {})

    local outWritten = 0
    for targetId, healing in pairs(healingStats.healingOutToGroup or {}) do
        if outWritten >= outCount then break end
        outWritten = outWritten + 1
        encoder:writeVarUInt(targetId)
        writeHealingDoneDiffSource(encoder, healing, registry, progress)
    end

    -- healingInFromGroup
    local inCount = writeTableVarCount(encoder, healingStats.healingInFromGroup or {})

    local inWritten = 0
    for sourceId, healing in pairs(healingStats.healingInFromGroup or {}) do
        if inWritten >= inCount then break end
        inWritten = inWritten + 1
        encoder:writeVarUInt(sourceId)
        writeHealingDone(encoder, healing, registry, progress)
    end
end

---Reads HealingStats from decoder
---@param decoder BitDecoder
---@param version number
---@return HealingStats
local function readHealingStats(decoder, version, registry)
    local result = {
        selfHealing = readHealingDoneDiffSource(decoder, version, registry),
        healingOutToGroup = {},
        healingInFromGroup = {},
    }

    local outCount = readMapCount(decoder, version)
    for _ = 1, outCount do
        local targetId = readVal(decoder, version, BITS.UNIT_ID)
        result.healingOutToGroup[targetId] = readHealingDoneDiffSource(decoder, version, registry)
    end

    local inCount = readMapCount(decoder, version)
    for _ = 1, inCount do
        local sourceId = readVal(decoder, version, BITS.UNIT_ID)
        result.healingInFromGroup[sourceId] = readHealingDone(decoder, version, registry)
    end

    return result
end

---Builds the empty HealingStats shape produced when nothing was recorded,
---matching what decoding a zero-count healing section used to return.
---@return HealingStats
local function makeEmptyHealingStats()
    return {
        selfHealing = {
            total = BattleScrolls.structures.makeHealingTotals(0, 0, 0),
            bySourceUnitIdByAbilityId = {},
        },
        healingOutToGroup = {},
        healingInFromGroup = {},
    }
end

-- =============================================================================
-- PROCS ENCODING
-- =============================================================================

---Writes procs to encoder
---@param encoder BitEncoder
---@param procs ProcData[]
local function writeProcs(encoder, procs, registry)
    procs = procs or {}
    local procCount = writeVarCount(encoder, #procs)

    for i = 1, procCount do
        local proc = procs[i]
        writeAbilityRef(encoder, registry, proc.abilityId)
        encoder:writeVarUInt(proc.totalProcs or 0)
        encoder:writeVarUInt(proc.meanIntervalMs or 0)
        encoder:writeVarUInt(proc.medianIntervalMs or 0)

        local enemies = proc.procsByEnemy or {}
        local enemyCount = writeVarCount(encoder, #enemies)
        for j = 1, enemyCount do
            encoder:writeVarUInt(enemies[j].unitId)
            encoder:writeVarUInt(enemies[j].procCount or 0)
        end
    end
end

---Reads procs from decoder
---@param decoder BitDecoder
---@return ProcData[]
local function readProcs(decoder, version, registry)
    local result = {}
    local procCount = readMapCount(decoder, version)

    for _ = 1, procCount do
        local abilityId
        if version >= 17 then
            abilityId = readAbilityRef(decoder, registry)
        else
            abilityId = decoder:readUInt(BITS.ABILITY_ID)
        end
        local proc = {
            abilityId = abilityId,
            totalProcs = readVal(decoder, version, BITS.COUNT),
            meanIntervalMs = readVal(decoder, version, BITS.INTERVAL_MS),
            medianIntervalMs = readVal(decoder, version, BITS.INTERVAL_MS),
            procsByEnemy = {},
        }

        local enemyCount = readMapCount(decoder, version)
        for _ = 1, enemyCount do
            proc.procsByEnemy[#proc.procsByEnemy + 1] = {
                unitId = readVal(decoder, version, BITS.UNIT_ID),
                procCount = readVal(decoder, version, BITS.COUNT),
            }
        end

        result[#result + 1] = proc
    end

    return result
end

-- =============================================================================
-- WEAVING ENCODING
-- =============================================================================

---Writes a signed time value (sign bit + absolute value)
---@param encoder BitEncoder
---@param value number
local function writeSignedTime(encoder, value)
    writeZigZag(encoder, value)
end

---Reads a signed time value (zigzag varint v17+, sign bit + fixed pre-v17)
---@param decoder BitDecoder
---@param version number
---@return number
local function readSignedTime(decoder, version)
    if version >= 17 then
        return readZigZag(decoder)
    end
    local negative = decoder:readBit()
    local magnitude = decoder:readUInt(BITS.TIME_MS)
    return negative and -magnitude or magnitude
end

---Writes weaving data to encoder
---@param encoder BitEncoder
---@param weaving WeavingData|nil
local function writeWeaving(encoder, weaving, registry)
    -- v17: presence is carried by the section mask, no internal flag
    encoder:writeVarUInt(weaving.lightAttackHits or 0)
    encoder:writeVarUInt(weaving.heavyAttackHits or 0)
    encoder:writeVarUInt(weaving.skillActivations or 0)
    encoder:writeVarUInt(weaving.totalWeavingErrors or 0)
    encoder:writeVarUInt(weaving.doubleLaErrors or 0)

    local byAbility = weaving.byAbility or {}
    local abilityCount = writeVarCount(encoder, #byAbility)
    for i = 1, abilityCount do
        local entry = byAbility[i]
        writeAbilityRef(encoder, registry, entry.abilityId)
        encoder:writeVarUInt(entry.activations or 0)
        writeSignedTime(encoder, entry.afterSum or 0)
        encoder:writeVarUInt(entry.afterCount or 0)
        writeSignedTime(encoder, entry.beforeSum or 0)
        encoder:writeVarUInt(entry.beforeCount or 0)
        encoder:writeVarUInt(entry.weavingErrors or 0)
    end
end

---Reads weaving data from decoder
---@param decoder BitDecoder
---@param version number
---@return WeavingData|nil
local function readWeaving(decoder, version, registry)
    if version < 17 and not decoder:readBit() then
        return nil
    end

    ---@type WeavingData
    local weaving = {
        lightAttackHits = readVal(decoder, version, BITS.COUNT),
        heavyAttackHits = readVal(decoder, version, BITS.COUNT),
        skillActivations = readVal(decoder, version, BITS.COUNT),
        totalWeavingErrors = readVal(decoder, version, BITS.COUNT),
        doubleLaErrors = readVal(decoder, version, BITS.COUNT),
        byAbility = {},
    }

    local abilityCount = readMapCount(decoder, version)
    for _ = 1, abilityCount do
        local abilityId
        if version >= 17 then
            abilityId = readAbilityRef(decoder, registry)
        else
            abilityId = decoder:readUInt(BITS.ABILITY_ID)
        end
        weaving.byAbility[#weaving.byAbility + 1] = {
            abilityId = abilityId,
            activations = readVal(decoder, version, BITS.COUNT),
            afterSum = readSignedTime(decoder, version),
            afterCount = readVal(decoder, version, BITS.COUNT),
            beforeSum = readSignedTime(decoder, version),
            beforeCount = readVal(decoder, version, BITS.COUNT),
            weavingErrors = readVal(decoder, version, BITS.COUNT),
        }
    end

    return weaving
end

-- =============================================================================
-- EFFECTS ENCODING
-- =============================================================================

---Writes effectsOnPlayer to encoder
---@param encoder BitEncoder
---@param effectsOnPlayer table<number, EffectStats>|nil
---@param progress EncodeProgress
local function writeEffectsOnPlayer(encoder, effectsOnPlayer, registry, progress)
    local count = writeTableVarCount(encoder, effectsOnPlayer or {})

    local written = 0
    for abilityId, stats in pairs(effectsOnPlayer or {}) do
        if written >= count then break end
        written = written + 1
        -- v17: the map key is carried inside the stats row (pre-v17 stored it twice)
        writeEffectStats(encoder, stats, registry, abilityId)
        countAndMaybeYield(progress)
    end
end

---Reads effectsOnPlayer from decoder
---@param decoder BitDecoder
---@return table<number, EffectStats>|nil
local function readEffectsOnPlayer(decoder, version, registry)
    local count = readMapCount(decoder, version)
    if count == 0 then return nil end

    local result = {}
    for _ = 1, count do
        local abilityId
        if version < 17 then
            abilityId = decoder:readUInt(BITS.ABILITY_ID)
        end
        local stats = readEffectStats(decoder, version, registry)
        abilityId = abilityId or stats.abilityId
        result[abilityId] = stats
        result[abilityId].abilityId = abilityId  -- Ensure abilityId is set
    end
    return result
end

---Writes effectsOnBosses to encoder
---@param encoder BitEncoder
---@param effectsOnBosses table<string, table<number, EffectStats>>|nil
---@param progress EncodeProgress
local function writeEffectsOnBosses(encoder, effectsOnBosses, registry, progress)
    local unitCount = writeTableVarCount(encoder, effectsOnBosses or {})

    local unitsWritten = 0
    for unitTag, byAbility in pairs(effectsOnBosses or {}) do
        if unitsWritten >= unitCount then break end
        unitsWritten = unitsWritten + 1
        writeNameRef(encoder, registry, unitTag)

        local abilityCount = writeTableVarCount(encoder, byAbility)

        local abilitiesWritten = 0
        for abilityId, stats in pairs(byAbility) do
            if abilitiesWritten >= abilityCount then break end
            abilitiesWritten = abilitiesWritten + 1
            writeEffectStats(encoder, stats, registry, abilityId)
            countAndMaybeYield(progress)
        end
    end
end

---Reads effectsOnBosses from decoder
---@param decoder BitDecoder
---@return table<string, table<number, EffectStats>>|nil
local function readEffectsOnBosses(decoder, version, registry)
    local unitCount = readMapCount(decoder, version)
    if unitCount == 0 then return nil end

    local result = {}
    for _ = 1, unitCount do
        local unitTag
        if version >= 17 then
            unitTag = readNameRef(decoder, registry)
        else
            unitTag = decoder:readString()
        end
        result[unitTag] = {}

        local abilityCount = readMapCount(decoder, version)
        for _ = 1, abilityCount do
            local abilityId
            if version < 17 then
                abilityId = decoder:readUInt(BITS.ABILITY_ID)
            end
            local stats = readEffectStats(decoder, version, registry)
            abilityId = abilityId or stats.abilityId
            result[unitTag][abilityId] = stats
            result[unitTag][abilityId].abilityId = abilityId
        end
    end
    return result
end

---Writes effectsOnGroup to encoder
---@param encoder BitEncoder
---@param effectsOnGroup table<string, table<number, EffectStats>>|nil
---@param progress EncodeProgress
local function writeEffectsOnGroup(encoder, effectsOnGroup, registry, progress)
    local memberCount = writeTableVarCount(encoder, effectsOnGroup or {})

    local membersWritten = 0
    for displayName, byAbility in pairs(effectsOnGroup or {}) do
        if membersWritten >= memberCount then break end
        membersWritten = membersWritten + 1
        writeNameRef(encoder, registry, displayName)

        local abilityCount = writeTableVarCount(encoder, byAbility)

        local abilitiesWritten = 0
        for abilityId, stats in pairs(byAbility) do
            if abilitiesWritten >= abilityCount then break end
            abilitiesWritten = abilitiesWritten + 1
            writeEffectStats(encoder, stats, registry, abilityId)
            countAndMaybeYield(progress)
        end
    end
end

---Reads effectsOnGroup from decoder
---@param decoder BitDecoder
---@return table<string, table<number, EffectStats>>|nil
local function readEffectsOnGroup(decoder, version, registry)
    local memberCount = readMapCount(decoder, version)
    if memberCount == 0 then return nil end

    local result = {}
    for _ = 1, memberCount do
        local displayName
        if version >= 17 then
            displayName = readNameRef(decoder, registry)
        else
            displayName = decoder:readString()
        end
        result[displayName] = {}

        local abilityCount = readMapCount(decoder, version)
        for _ = 1, abilityCount do
            local abilityId
            if version < 17 then
                abilityId = decoder:readUInt(BITS.ABILITY_ID)
            end
            local stats = readEffectStats(decoder, version, registry)
            abilityId = abilityId or stats.abilityId
            result[displayName][abilityId] = stats
            result[displayName][abilityId].abilityId = abilityId
        end
    end
    return result
end

-- =============================================================================
-- BOSS NAMES & ALIVE TIMES
-- =============================================================================

---Writes bossNames to encoder
---@param encoder BitEncoder
---@param bossNames table<string, string>|nil
local function writeBossNames(encoder, bossNames, registry)
    local count = writeTableVarCount(encoder, bossNames or {})

    local written = 0
    for unitTag, name in pairs(bossNames or {}) do
        if written >= count then break end
        written = written + 1
        writeNameRef(encoder, registry, unitTag)
        writeNameRef(encoder, registry, name)
    end
end

---Reads bossNames from decoder
---@param decoder BitDecoder
---@return table<string, string>|nil
local function readBossNames(decoder, version, registry)
    local count = readMapCount(decoder, version)
    if count == 0 then return nil end

    local result = {}
    for _ = 1, count do
        local unitTag, name
        if version >= 17 then
            unitTag = readNameRef(decoder, registry)
            name = readNameRef(decoder, registry)
        else
            unitTag = decoder:readString()
            name = decoder:readString()
        end
        result[unitTag] = name
    end
    return result
end

---Writes unitAliveTimeMs to encoder
---@param encoder BitEncoder
---@param unitAliveTimeMs table<string, number>|nil
local function writeUnitAliveTimes(encoder, unitAliveTimeMs, registry)
    local count = writeTableVarCount(encoder, unitAliveTimeMs or {})

    local written = 0
    for unitKey, timeMs in pairs(unitAliveTimeMs or {}) do
        if written >= count then break end
        written = written + 1
        writeNameRef(encoder, registry, unitKey)
        encoder:writeVarUInt(timeMs)
    end
end

---Reads unitAliveTimeMs from decoder
---@param decoder BitDecoder
---@return table<string, number>|nil
local function readUnitAliveTimes(decoder, version, registry)
    local count = readMapCount(decoder, version)
    if count == 0 then return nil end

    local result = {}
    for _ = 1, count do
        local unitKey
        if version >= 17 then
            unitKey = readNameRef(decoder, registry)
        else
            unitKey = decoder:readString()
        end
        local timeMs = readVal(decoder, version, BITS.TIME_MS)
        result[unitKey] = timeMs
    end
    return result
end

---Writes unitNames to encoder
---@param encoder BitEncoder
---@param unitNames table<number, string>|nil
---@param progress EncodeProgress
local function writeUnitNames(encoder, unitNames, registry, progress)
    unitNames = unitNames or {}
    local count = writeTableVarCount(encoder, unitNames)

    local written = 0
    for unitId, name in pairs(unitNames) do
        if written >= count then break end
        written = written + 1
        encoder:writeVarUInt(unitId)
        writeNameRef(encoder, registry, name)
        countAndMaybeYield(progress)
    end
end

---Reads unitNames from decoder
---@param decoder BitDecoder
---@return table<number, string>
local function readUnitNames(decoder, version, registry)
    local result = {}
    local count = readMapCount(decoder, version)

    for _ = 1, count do
        local unitId = readVal(decoder, version, BITS.UNIT_ID)
        local name
        if version >= 17 then
            name = readNameRef(decoder, registry)
        else
            name = decoder:readString()
        end
        result[unitId] = name
    end

    return result
end

-- =============================================================================
-- DEATH RECAP ENCODING (v8+)
-- =============================================================================

---Writes a single death recap to encoder
---@param encoder BitEncoder
---@param recap SharedDeathRecap
local function writeDeathRecap(encoder, recap, registry)
    local attacks = recap.attacks or {}
    if registry then
        -- Encounter path: attack count packed into the time varint, refs interned
        local attackCount = #attacks
        if attackCount > 7 then
            attackCount = 7
        end
        encoder:writeVarUInt((recap.timeOffsetMs or 0) * 8 + attackCount)
        for i = 1, attackCount do
            writeAbilityRef(encoder, registry, attacks[i].abilityId)
            encoder:writeVarUInt(attacks[i].damage)
        end
        return
    end
    -- Registry-less path (shared entries): raw ability ids
    encoder:writeVarUInt(recap.timeOffsetMs or 0)
    local attackCount = writeCount(encoder, #attacks, BITS.DEATH_ATTACK_COUNT)
    for i = 1, attackCount do
        encoder:writeUInt(attacks[i].abilityId, BITS.ABILITY_ID)
        encoder:writeVarUInt(attacks[i].damage)
    end
end

---Reads a single death recap from decoder
---@param decoder BitDecoder
---@return SharedDeathRecap
local function readDeathRecap(decoder, version, registry)
    if registry and version >= 17 then
        local packed = decoder:readVarUInt()
        local timeOffsetMs = math.floor(packed / 8)
        local attackCount = packed % 8
        local attacks = {}
        for _ = 1, attackCount do
            attacks[#attacks + 1] = {
                abilityId = readAbilityRef(decoder, registry),
                damage = decoder:readVarUInt(),
            }
        end
        return { timeOffsetMs = timeOffsetMs, attacks = attacks }
    end
    local timeOffsetMs = readVal(decoder, version, BITS.TIME_MS)
    local attackCount = decoder:readUInt(BITS.DEATH_ATTACK_COUNT)
    local attacks = {}
    for _ = 1, attackCount do
        attacks[#attacks + 1] = {
            abilityId = decoder:readUInt(BITS.ABILITY_ID),
            damage = readVal(decoder, version, BITS.TICK_VALUE),
        }
    end
    return { timeOffsetMs = timeOffsetMs, attacks = attacks }
end

---Writes EncounterDeaths to encoder (1-bit flag prefix)
---@param encoder BitEncoder
---@param deaths EncounterDeaths|nil
local function writeDeaths(encoder, deaths, registry)
    -- v17: presence is carried by the section mask, no internal flag
    encoder:writeVarUInt(deaths.deathCount)
    local recaps = deaths.recaps or {}
    local recapCount = writeVarCount(encoder, #recaps)
    for i = 1, recapCount do
        writeDeathRecap(encoder, recaps[i], registry)
    end
end

---Reads EncounterDeaths from decoder (1-bit flag prefix)
---@param decoder BitDecoder
---@return EncounterDeaths|nil
local function readDeaths(decoder, version, registry)
    if version < 17 and not decoder:readBit() then
        return nil
    end
    local deathCount = readMapCount(decoder, version)
    local recapCount = readMapCount(decoder, version)
    local recaps = {}
    for _ = 1, recapCount do
        recaps[#recaps + 1] = readDeathRecap(decoder, version, registry)
    end
    return { deathCount = deathCount, recaps = recaps }
end

-- =============================================================================
-- SETUP ENCODING (v9+)
-- =============================================================================

---Writes an ability bar (array of PlayerSetupAbility) to the encoder.
---@param encoder BitEncoder
---@param bar PlayerSetupAbility[]
local function writeAbilityBar(encoder, bar)
    for i = 1, 6 do
        local ability = bar[i] or {}
        encoder:writeUInt(ability.abilityId or 0, BITS.ABILITY_ID)
        local isCrafted = ability.craftedAbilityId ~= nil
        encoder:writeBit(isCrafted)
        if isCrafted then
            encoder:writeUInt(ability.craftedAbilityId, BITS.CRAFTED_ABILITY_ID)
            local scripts = ability.scriptIds or {}
            encoder:writeUInt(scripts[1] or 0, BITS.SCRIPT_ID)
            encoder:writeUInt(scripts[2] or 0, BITS.SCRIPT_ID)
            encoder:writeUInt(scripts[3] or 0, BITS.SCRIPT_ID)
        end
    end
end

---Reads an ability bar (6 slots) from the decoder.
---@param decoder BitDecoder
---@return PlayerSetupAbility[]
local function readAbilityBar(decoder)
    local bar = {}
    for _ = 1, 6 do
        local abilityId = decoder:readUInt(BITS.ABILITY_ID)
        local isCrafted = decoder:readBit()
        ---@type PlayerSetupAbility
        local ability
        if isCrafted then
            local craftedAbilityId = decoder:readUInt(BITS.CRAFTED_ABILITY_ID)
            local s1 = decoder:readUInt(BITS.SCRIPT_ID)
            local s2 = decoder:readUInt(BITS.SCRIPT_ID)
            local s3 = decoder:readUInt(BITS.SCRIPT_ID)
            ability = {
                abilityId = abilityId,
                craftedAbilityId = craftedAbilityId,
                scriptIds = { s1, s2, s3 },
            }
        else
            ability = { abilityId = abilityId }
        end
        bar[#bar + 1] = ability
    end
    return bar
end

---@param encoder BitEncoder
---@param champion PlayerSetupChampionSkill[]|nil
local function writeChampionPayload(encoder, champion)
    champion = champion or {}
    local championCount = writeCount(encoder, #champion, BITS.CHAMPION_COUNT)
    for i = 1, championCount do
        encoder:writeUInt(champion[i].skillId, BITS.CHAMPION_SKILL_ID)
        encoder:writeUInt(champion[i].disciplineId, BITS.DISCIPLINE_ID)
    end
end

---@param decoder BitDecoder
---@return PlayerSetupChampionSkill[]
local function readChampionPayload(decoder)
    local champion = {}
    local championCount = decoder:readUInt(BITS.CHAMPION_COUNT)
    for _ = 1, championCount do
        champion[#champion + 1] = {
            skillId = decoder:readUInt(BITS.CHAMPION_SKILL_ID),
            disciplineId = decoder:readUInt(BITS.DISCIPLINE_ID),
        }
    end
    return champion
end

---@param encoder BitEncoder
---@param equipSlots (string|false)[]|nil
local function writeEquipSlotsPayload(encoder, equipSlots)
    equipSlots = equipSlots or {}
    for i = 1, EQUIP_SLOT_COUNT do
        local link = equipSlots[i]
        if link and link ~= "" then
            encoder:writeBit(true)
            encoder:writeString(link)
        else
            encoder:writeBit(false)
        end
    end
end

---@param decoder BitDecoder
---@return (string|false)[]
local function readEquipSlotsPayload(decoder)
    local equipSlots = {}
    for i = 1, EQUIP_SLOT_COUNT do
        if decoder:readBit() then
            equipSlots[i] = decoder:readString()
        else
            equipSlots[i] = false
        end
    end
    return equipSlots
end

---@return (string|false)[]
local function makeEmptyEquipSlots()
    local equipSlots = {}
    for i = 1, EQUIP_SLOT_COUNT do
        equipSlots[i] = false
    end
    return equipSlots
end

---@param encoder BitEncoder
---@param setup PlayerSetup
local function writePoisonPayload(encoder, setup)
    if setup.frontPoison then
        encoder:writeBit(true)
        encoder:writeString(setup.frontPoison.itemLink)
    else
        encoder:writeBit(false)
    end
    if setup.backPoison then
        encoder:writeBit(true)
        encoder:writeString(setup.backPoison.itemLink)
    else
        encoder:writeBit(false)
    end
end

---@param decoder BitDecoder
---@param version number
---@return PlayerSetupPoison|nil frontPoison
---@return PlayerSetupPoison|nil backPoison
local function readPoisonPayload(decoder, version)
    local frontPoison = nil
    local backPoison = nil
    if version >= 11 then
        if decoder:readBit() then
            frontPoison = { itemLink = decoder:readString() }
        end
        if decoder:readBit() then
            backPoison = { itemLink = decoder:readString() }
        end
    else
        -- v10 and earlier stored poison ability IDs; consume and discard them.
        if decoder:readBit() then decoder:readUInt(BITS.ABILITY_ID) end
        if decoder:readBit() then decoder:readUInt(BITS.ABILITY_ID) end
    end
    return frontPoison, backPoison
end

---@param encoder BitEncoder
---@param setup PlayerSetup
local function writeClassPayload(encoder, setup)
    local classSkillLineIds = setup.classSkillLineIds or {}
    for i = 1, 3 do
        encoder:writeUInt(classSkillLineIds[i] or 0, BITS.SKILL_LINE_ID)
    end

    if setup.classMasteryAbilityIds then
        encoder:writeBit(true)
        local classMasteryAbilityIds = setup.classMasteryAbilityIds
        local classMasteryAbilityCount = writeCount(encoder, #classMasteryAbilityIds, BITS.CLASS_MASTERY_ABILITY_COUNT)
        for i = 1, classMasteryAbilityCount do
            encoder:writeUInt(classMasteryAbilityIds[i], BITS.ABILITY_ID)
        end
    else
        encoder:writeBit(false)
    end
end

---@param decoder BitDecoder
---@param result PlayerSetup
---@param version number
local function readClassPayload(decoder, result, version)
    local classSkillLineIds = {}
    for i = 1, 3 do
        classSkillLineIds[i] = decoder:readUInt(BITS.SKILL_LINE_ID)
    end
    result.classSkillLineIds = classSkillLineIds

    if version >= 16 and decoder:readBit() then
        local classMasteryAbilityCount = decoder:readUInt(BITS.CLASS_MASTERY_ABILITY_COUNT)
        local classMasteryAbilityIds = {}
        for _ = 1, classMasteryAbilityCount do
            classMasteryAbilityIds[#classMasteryAbilityIds + 1] = decoder:readUInt(BITS.ABILITY_ID)
        end
        result.classMasteryAbilityIds = classMasteryAbilityIds
    end
end

---@param encoder BitEncoder
---@param setup PlayerSetup
local function writeMundusAndFoodPayload(encoder, setup)
    local mundus = setup.mundusAbilityIds or {}
    local mundusCount = writeCount(encoder, #mundus, BITS.MUNDUS_COUNT)
    for i = 1, mundusCount do
        encoder:writeUInt(mundus[i], BITS.ABILITY_ID)
    end

    local foods = setup.foods or {}
    local foodCount = writeCount(encoder, #foods, BITS.FOOD_COUNT)
    for i = 1, foodCount do
        encoder:writeUInt(foods[i].abilityId, BITS.ABILITY_ID)
        if foods[i].uptimeMs then
            encoder:writeBit(true)
            encoder:writeUInt(foods[i].uptimeMs, BITS.TIME_MS)
        else
            encoder:writeBit(false)
        end
    end
end

---@param decoder BitDecoder
---@param result PlayerSetup
local function readMundusAndFoodPayload(decoder, result)
    local mundusCount = decoder:readUInt(BITS.MUNDUS_COUNT)
    if mundusCount > 0 then
        local mundus = {}
        for _ = 1, mundusCount do
            mundus[#mundus + 1] = decoder:readUInt(BITS.ABILITY_ID)
        end
        result.mundusAbilityIds = mundus
    end

    local foodCount = decoder:readUInt(BITS.FOOD_COUNT)
    if foodCount > 0 then
        local foods = {}
        for _ = 1, foodCount do
            local abilityId = decoder:readUInt(BITS.ABILITY_ID)
            local hasUptime = decoder:readBit()
            ---@type PlayerSetupFood
            local food = { abilityId = abilityId }
            if hasUptime then
                food.uptimeMs = decoder:readUInt(BITS.TIME_MS)
            end
            foods[#foods + 1] = food
        end
        result.foods = foods
    end
end

---@param encoder BitEncoder
---@param setup PlayerSetup
local function writeWerewolfPayload(encoder, setup)
    if setup.werewolfAbilities then
        encoder:writeBit(true)
        encoder:writeBit(setup.werewolfEntireFight or false)
        writeAbilityBar(encoder, setup.werewolfAbilities)
    else
        encoder:writeBit(false)
    end
end

---@param decoder BitDecoder
---@param result PlayerSetup
---@param version number
local function readWerewolfPayload(decoder, result, version)
    if version >= 10 and decoder:readBit() then
        result.werewolfEntireFight = decoder:readBit()
        result.werewolfAbilities = readAbilityBar(decoder)
    end
end

---@param encoder BitEncoder
---@param setup PlayerSetup
local function writeSetupHeader(encoder, setup)
    writeAbilityBar(encoder, setup.abilities.front)
    writeAbilityBar(encoder, setup.abilities.back)
    encoder:writeBit(setup.frontBarDisabled or false)
    encoder:writeBit(setup.backBarDisabled or false)
    encoder:writeUInt(setup.raceId or 0, BITS.RACE_ID)
    encoder:writeUInt(setup.classId or 0, BITS.CLASS_ID)
end

---@param encoder BitEncoder
---@param setup PlayerSetup
local function writeNormalSetupPayload(encoder, setup)
    writeChampionPayload(encoder, setup.champion)
    writeEquipSlotsPayload(encoder, setup.equipSlots)
    writePoisonPayload(encoder, setup)
    writeClassPayload(encoder, setup)
    writeMundusAndFoodPayload(encoder, setup)
    writeWerewolfPayload(encoder, setup)
end

---@param encoder BitEncoder
---@param setup PlayerSetup
local function writeVengeanceSetupPayload(encoder, setup)
    local weaponTypes = setup.weaponTypes or {}
    for i = 1, 4 do
        encoder:writeUInt(weaponTypes[i] or 0, BITS.WEAPON_TYPE)
    end

    encoder:writeUInt(setup.loadoutSkillLineId or 0, BITS.SKILL_LINE_ID)

    local perks = setup.vengeancePerkDefIds or {}
    for i = 1, 3 do
        encoder:writeUInt(perks[i] or 0, BITS.VENGEANCE_PERK_DEF_ID)
    end
end

---@param encoder BitEncoder
---@param setup PlayerSetup
local function writeSetup(encoder, setup)
    writeSetupHeader(encoder, setup)

    local isVengeance = setup.isVengeance == true
    encoder:writeBit(isVengeance)
    if isVengeance then
        writeVengeanceSetupPayload(encoder, setup)
    else
        writeNormalSetupPayload(encoder, setup)
    end
end

---@param decoder BitDecoder
---@param version number
---@param front PlayerSetupAbility[]
---@param back PlayerSetupAbility[]
---@return PlayerSetup
local function readLegacyNormalSetup(decoder, version, front, back)
    local champion = readChampionPayload(decoder)
    local equipSlots = readEquipSlotsPayload(decoder)
    local frontBarDisabled = decoder:readBit()
    local backBarDisabled = decoder:readBit()
    local frontPoison, backPoison = readPoisonPayload(decoder, version)

    ---@type PlayerSetup
    local result = {
        abilities = { front = front, back = back },
        champion = champion,
        equipSlots = equipSlots,
        frontBarDisabled = frontBarDisabled,
        backBarDisabled = backBarDisabled,
        frontPoison = frontPoison,
        backPoison = backPoison,
        raceId = decoder:readUInt(BITS.RACE_ID),
        classId = decoder:readUInt(BITS.CLASS_ID),
    }

    readClassPayload(decoder, result, version)
    readMundusAndFoodPayload(decoder, result)
    readWerewolfPayload(decoder, result, version)

    return result
end

---@param decoder BitDecoder
---@param version number
---@param front PlayerSetupAbility[]
---@param back PlayerSetupAbility[]
---@param frontBarDisabled boolean
---@param backBarDisabled boolean
---@param raceId number
---@param classId number
---@return PlayerSetup
local function readNormalSetupPayload(decoder, version, front, back, frontBarDisabled, backBarDisabled, raceId, classId)
    ---@type PlayerSetup
    local result = {
        abilities = { front = front, back = back },
        champion = readChampionPayload(decoder),
        equipSlots = readEquipSlotsPayload(decoder),
        frontBarDisabled = frontBarDisabled,
        backBarDisabled = backBarDisabled,
        raceId = raceId,
        classId = classId,
    }

    local frontPoison, backPoison = readPoisonPayload(decoder, version)
    result.frontPoison = frontPoison
    result.backPoison = backPoison

    readClassPayload(decoder, result, version)
    readMundusAndFoodPayload(decoder, result)
    readWerewolfPayload(decoder, result, version)

    return result
end

---@param decoder BitDecoder
---@param front PlayerSetupAbility[]
---@param back PlayerSetupAbility[]
---@param frontBarDisabled boolean
---@param backBarDisabled boolean
---@param raceId number
---@param classId number
---@return PlayerSetup
local function readVengeanceSetupPayload(decoder, front, back, frontBarDisabled, backBarDisabled, raceId, classId)
    local weaponTypes = {}
    for i = 1, 4 do
        weaponTypes[i] = decoder:readUInt(BITS.WEAPON_TYPE)
    end

    local loadoutSkillLineId = decoder:readUInt(BITS.SKILL_LINE_ID)

    local vengeancePerkDefIds = {}
    for i = 1, 3 do
        vengeancePerkDefIds[i] = decoder:readUInt(BITS.VENGEANCE_PERK_DEF_ID)
    end

    ---@type PlayerSetup
    local result = {
        abilities = { front = front, back = back },
        champion = {},
        equipSlots = makeEmptyEquipSlots(),
        frontBarDisabled = frontBarDisabled,
        backBarDisabled = backBarDisabled,
        raceId = raceId,
        classId = classId,
        classSkillLineIds = {},
        isVengeance = true,
        weaponTypes = weaponTypes,
        vengeancePerkDefIds = vengeancePerkDefIds,
    }

    if loadoutSkillLineId > 0 then
        result.loadoutSkillLineId = loadoutSkillLineId
    end

    return result
end

---Reads a PlayerSetup from decoder
---@param decoder BitDecoder
---@param version number Binary format version
---@return PlayerSetup
local function readSetup(decoder, version)
    local front = readAbilityBar(decoder)
    local back = readAbilityBar(decoder)

    if version < 16 then
        return readLegacyNormalSetup(decoder, version, front, back)
    end

    local frontBarDisabled = decoder:readBit()
    local backBarDisabled = decoder:readBit()
    local raceId = decoder:readUInt(BITS.RACE_ID)
    local classId = decoder:readUInt(BITS.CLASS_ID)
    if decoder:readBit() then
        return readVengeanceSetupPayload(decoder, front, back, frontBarDisabled, backBarDisabled, raceId, classId)
    end

    return readNormalSetupPayload(decoder, version, front, back, frontBarDisabled, backBarDisabled, raceId, classId)
end

---Returns a copy of a setup reduced to build identity: per-fight food
---uptimes stripped (they live in the per-encounter overlay of the setup
---section). Pool entries must be byte-identical for identical builds.
---@param setup PlayerSetup
---@return PlayerSetup
function binaryStorage.buildPoolableSetup(setup)
    local copy = {}
    for k, v in pairs(setup) do
        copy[k] = v
    end
    if setup.foods then
        local foods = {}
        for i, food in ipairs(setup.foods) do
            foods[i] = { abilityId = food.abilityId }
        end
        copy.foods = foods
    end
    return copy
end

---Encodes a PlayerSetup on its own, for the own-setup pool. Synchronous:
---a setup is ~1KB.
---@param setup PlayerSetup
---@return string[] chunks
---@return number version Schema version the chunks were written with
function binaryStorage.encodeSetupStandalone(setup)
    local encoder = BitEncoder.new()
    writeSetup(encoder, setup)
    return encoder:finish(), CURRENT_VERSION
end

---Decodes a PlayerSetup stored by encodeSetupStandalone.
---@param chunks string[]
---@param version number
---@return PlayerSetup
function binaryStorage.decodeSetupStandalone(chunks, version)
    return readSetup(BitDecoder.new(chunks), version)
end

-- =============================================================================
-- SHARED DATA ENCODING (v17+)
-- Each group member's SharedDataEntry is encoded independently so entries can
-- arrive and be upserted after the encounter itself was encoded and persisted.
-- Match keys (displayName, timestampS, durationMs), the setup hash (scanned by
-- pool pruning without decoding), and role stay plain on the entry.
-- =============================================================================

---@class CompactSharedEntry
---@field v number Entry schema version (CURRENT_VERSION at encode time)
---@field d string Sender display name
---@field t number Sender fight start (Unix epoch seconds)
---@field u number Sender fight duration in ms
---@field h number|nil 16-bit setup hash
---@field r number|nil LFG_ROLE_* constant captured at match time
---@field c string[] Base64 chunks of the binary SharedEncounterData payload

local PERCENT_BITS = 12
local PERCENT_MAX = 4095

---Writes a 0-1 fraction as 12-bit fixed point (~0.02% resolution)
---@param encoder BitEncoder
---@param value number|nil
local function writePercent(encoder, value)
    value = value or 0
    if value < 0 then
        value = 0
    elseif value > 1 then
        value = 1
    end
    encoder:writeUInt(math.floor(value * PERCENT_MAX + 0.5), PERCENT_BITS)
end

---@param decoder BitDecoder
---@return number fraction 0-1
local function readPercent(decoder)
    return decoder:readUInt(PERCENT_BITS) / PERCENT_MAX
end

---Writes a boss tag as a 3-bit BOSS_TAGS index, escaping unknown tags (index 7)
---to a full string
---@param encoder BitEncoder
---@param bossTag string|nil
local function writeBossTag(encoder, bossTag)
    local bossTags = BattleScrolls.constants.BOSS_TAGS
    for i = 1, 6 do
        if bossTags[i] == bossTag then
            encoder:writeUInt(i, 3)
            return
        end
    end
    encoder:writeUInt(7, 3)
    encoder:writeString(bossTag or "")
end

---@param decoder BitDecoder
---@return string bossTag
local function readBossTag(decoder)
    local index = decoder:readUInt(3)
    if index >= 1 and index <= 6 then
        return BattleScrolls.constants.BOSS_TAGS[index]
    end
    if index == 7 then
        return decoder:readString()
    end
    return ""
end

---Writes the binary payload of a SharedEncounterData (everything except the
---plain-kept fields timestampS/durationMs/setupHash).
---@param encoder BitEncoder
---@param data SharedEncounterData
local function writeSharedPayload(encoder, data)
    encoder:writeVarUInt(data.totalDamage)
    writePercent(encoder, data.critPercent)
    writePercent(encoder, data.dotPercent)
    writePercent(encoder, data.aoePercent)
    encoder:writeVarUInt(data.maxHit)
    encoder:writeVarUInt(data.totalDamageTaken)

    local damageByType = data.damageByType or {}
    local typeCount = writeVarCount(encoder, #damageByType)
    for i = 1, typeCount do
        encoder:writeUInt(damageByType[i].type or 0, 6)
        encoder:writeVarUInt(damageByType[i].damage)
    end

    local bossDamage = data.bossDamage or {}
    local bossCount = writeVarCount(encoder, #bossDamage)
    for i = 1, bossCount do
        local entry = bossDamage[i]
        writeBossTag(encoder, entry.bossTag)
        encoder:writeVarUInt(entry.tagSeq)
        encoder:writeVarUInt(entry.damage)
        writePercent(encoder, entry.critPercent)
        writePercent(encoder, entry.dotPercent)
        writePercent(encoder, entry.aoePercent)
        writePercent(encoder, entry.magicalPercent)
    end

    local bossDamageTaken = data.bossDamageTaken or {}
    local takenCount = writeVarCount(encoder, #bossDamageTaken)
    for i = 1, takenCount do
        local entry = bossDamageTaken[i]
        writeBossTag(encoder, entry.bossTag)
        encoder:writeVarUInt(entry.tagSeq)
        encoder:writeVarUInt(entry.damage)
    end

    if data.healing then
        encoder:writeBit(true)
        encoder:writeVarUInt(data.healing.rawOut)
        encoder:writeVarUInt(data.healing.effectiveOut)
        encoder:writeVarUInt(data.healing.rawSelf)
        encoder:writeVarUInt(data.healing.effectiveSelf)
    else
        encoder:writeBit(false)
    end

    if data.aliveTimeMs then
        encoder:writeBit(true)
        encoder:writeVarUInt(data.aliveTimeMs)
    else
        encoder:writeBit(false)
    end

    local topTaken = data.topDamageTakenAbilities or {}
    local topCount = writeVarCount(encoder, #topTaken)
    for i = 1, topCount do
        encoder:writeUInt(topTaken[i].abilityId or 0, BITS.ABILITY_ID)
        writePercent(encoder, topTaken[i].damagePercent)
    end

    local deaths = data.deaths
    if deaths and deaths.first then
        encoder:writeBit(true)
        encoder:writeUInt(deaths.deathCount or 1, 4)
        writeDeathRecap(encoder, deaths.first)
        if deaths.last then
            encoder:writeBit(true)
            writeDeathRecap(encoder, deaths.last)
        else
            encoder:writeBit(false)
        end
    else
        encoder:writeBit(false)
    end
end

---Reads the binary payload of a SharedEncounterData.
---@param decoder BitDecoder
---@param version number
---@return SharedEncounterData data (without timestampS/durationMs/setupHash)
local function readSharedPayload(decoder, version)
    ---@type SharedEncounterData
    local data = {}
    data.totalDamage = decoder:readVarUInt()
    data.critPercent = readPercent(decoder)
    data.dotPercent = readPercent(decoder)
    data.aoePercent = readPercent(decoder)
    data.maxHit = decoder:readVarUInt()
    data.totalDamageTaken = decoder:readVarUInt()

    data.damageByType = {}
    local typeCount = readMapCount(decoder, version)
    for i = 1, typeCount do
        data.damageByType[i] = {
            type = decoder:readUInt(6),
            damage = decoder:readVarUInt(),
        }
    end

    data.bossDamage = {}
    local bossCount = readMapCount(decoder, version)
    for i = 1, bossCount do
        data.bossDamage[i] = {
            bossTag = readBossTag(decoder),
            tagSeq = decoder:readVarUInt(),
            damage = decoder:readVarUInt(),
            critPercent = readPercent(decoder),
            dotPercent = readPercent(decoder),
            aoePercent = readPercent(decoder),
            magicalPercent = readPercent(decoder),
        }
    end

    data.bossDamageTaken = {}
    local takenCount = readMapCount(decoder, version)
    for i = 1, takenCount do
        data.bossDamageTaken[i] = {
            bossTag = readBossTag(decoder),
            tagSeq = decoder:readVarUInt(),
            damage = decoder:readVarUInt(),
        }
    end

    if decoder:readBit() then
        data.healing = {
            rawOut = decoder:readVarUInt(),
            effectiveOut = decoder:readVarUInt(),
            rawSelf = decoder:readVarUInt(),
            effectiveSelf = decoder:readVarUInt(),
        }
    end

    if decoder:readBit() then
        data.aliveTimeMs = decoder:readVarUInt()
    end

    data.topDamageTakenAbilities = {}
    local topCount = readMapCount(decoder, version)
    for i = 1, topCount do
        data.topDamageTakenAbilities[i] = {
            abilityId = decoder:readUInt(BITS.ABILITY_ID),
            damagePercent = readPercent(decoder),
        }
    end

    if decoder:readBit() then
        local deathCount = decoder:readUInt(4)
        local first = readDeathRecap(decoder, version)
        local last
        if decoder:readBit() then
            last = readDeathRecap(decoder, version)
        end
        data.deaths = { deathCount = deathCount, first = first, last = last }
    end

    return data
end

---Encodes one SharedDataEntry into its compact stored form. Synchronous:
---a single entry is a few hundred bytes.
---@param entry SharedDataEntry
---@return CompactSharedEntry
function binaryStorage.encodeSharedEntry(entry)
    local encoder = BitEncoder.new()
    writeSharedPayload(encoder, entry.data)
    return {
        v = CURRENT_VERSION,
        d = entry.displayName,
        t = entry.data.timestampS,
        u = entry.data.durationMs,
        h = entry.data.setupHash,
        r = entry.role,
        c = encoder:finish(),
    }
end

---Decodes a compact stored shared entry back into a SharedDataEntry.
---@param compactEntry CompactSharedEntry
---@return SharedDataEntry
function binaryStorage.decodeSharedEntry(compactEntry)
    local decoder = BitDecoder.new(compactEntry.c)
    local data = readSharedPayload(decoder, compactEntry.v)
    data.timestampS = compactEntry.t
    data.durationMs = compactEntry.u
    data.setupHash = compactEntry.h
    return {
        displayName = compactEntry.d,
        data = data,
        role = compactEntry.r,
    }
end

-- =============================================================================
-- MAIN ENCODE/DECODE FUNCTIONS
-- =============================================================================

---Returns true when healingStats carries no recorded data.
---@param healingStats HealingStats|nil
---@return boolean
local function healingIsEmpty(healingStats)
    if not healingStats then
        return true
    end
    local selfHealing = healingStats.selfHealing
    if selfHealing then
        if selfHealing.total and (selfHealing.total.raw or 0) > 0 then
            return false
        end
        if next(selfHealing.bySourceUnitIdByAbilityId or {}) then
            return false
        end
    end
    if next(healingStats.healingOutToGroup or {}) then
        return false
    end
    if next(healingStats.healingInFromGroup or {}) then
        return false
    end
    return true
end

---Encodes an encounter to binary format asynchronously.
---Returns an Effect that resolves to the binary-encoded encounter.
---@param encounter Encounter The encounter to encode (includes unitNames for v7+)
---@param setupPooled boolean|nil When true the setup build lives in the own-setup pool (caller sets _setupHash on the result); the section stores only the per-fight food uptime overlay
---@param registry EncounterRegistry The instance's ability/name registry; interns new entries during encoding
---@return Effect Effect that resolves to binaryEncounter
function binaryStorage.encodeEncounterAsync(encounter, setupPooled, registry)
    return LibEffect.Async(function()
        local encoder = BitEncoder.new()
        local progress = { count = 0 }

        -- v17: section-presence bitmask; empty sections are omitted entirely
        local present = {
            [SECTION.DAMAGE] = next(encounter.damageByUnitId or {}) ~= nil,
            [SECTION.DAMAGE_GROUP] = next(encounter.damageByUnitIdGroup or {}) ~= nil,
            [SECTION.DAMAGE_TAKEN] = next(encounter.damageTakenByUnitId or {}) ~= nil,
            [SECTION.HEALING] = not healingIsEmpty(encounter.healingStats),
            [SECTION.PROCS] = #(encounter.procs or {}) > 0,
            [SECTION.EFFECTS_PLAYER] = next(encounter.effectsOnPlayer or {}) ~= nil,
            [SECTION.EFFECTS_BOSSES] = next(encounter.effectsOnBosses or {}) ~= nil,
            [SECTION.EFFECTS_GROUP] = next(encounter.effectsOnGroup or {}) ~= nil,
            [SECTION.BOSS_NAMES] = next(encounter.bossNames or {}) ~= nil,
            [SECTION.PLAYER_ALIVE_TIME] = encounter.playerAliveTimeMs ~= nil,
            [SECTION.UNIT_ALIVE_TIMES] = next(encounter.unitAliveTimeMs or {}) ~= nil,
            [SECTION.UNIT_NAMES] = next(encounter.unitNames or {}) ~= nil,
            [SECTION.DEATHS] = encounter.deaths ~= nil,
            [SECTION.SETUP] = encounter.setup ~= nil,
            [SECTION.WEAVING] = encounter.weaving ~= nil,
        }
        local mask = 0
        for bit, isPresent in pairs(present) do
            if isPresent then
                mask = mask + BitLShift(1, bit - 1)
            end
        end
        encoder:writeUInt(mask, 16)

        -- Heavy sections: damage maps and healing (yield based on data volume).
        -- Every section is byte-aligned so varint/string ops stay on the
        -- bitcodec fast path (setup is the only internally bit-packed section).
        if present[SECTION.DAMAGE] then
            writeDamageMap(encoder, encounter.damageByUnitId, registry, progress)
            encoder:alignToByte()
        end
        if present[SECTION.DAMAGE_GROUP] then
            writeDamageMap(encoder, encounter.damageByUnitIdGroup, registry, progress)
            encoder:alignToByte()
        end
        if present[SECTION.DAMAGE_TAKEN] then
            writeDamageMap(encoder, encounter.damageTakenByUnitId, registry, progress)
            encoder:alignToByte()
        end
        if present[SECTION.HEALING] then
            writeHealingStats(encoder, encounter.healingStats, registry, progress)
            encoder:alignToByte()
        end
        flushProgress(progress)

        -- Light section: procs (always small, no per-item yields)
        if present[SECTION.PROCS] then
            writeProcs(encoder, encounter.procs, registry)
            encoder:alignToByte()
        end

        -- Effects (yield based on data volume, consistent with damage/healing)
        if present[SECTION.EFFECTS_PLAYER] then
            writeEffectsOnPlayer(encoder, encounter.effectsOnPlayer, registry, progress)
            encoder:alignToByte()
        end
        if present[SECTION.EFFECTS_BOSSES] then
            writeEffectsOnBosses(encoder, encounter.effectsOnBosses, registry, progress)
            encoder:alignToByte()
        end
        if present[SECTION.EFFECTS_GROUP] then
            writeEffectsOnGroup(encoder, encounter.effectsOnGroup, registry, progress)
            encoder:alignToByte()
        end
        flushProgress(progress)

        -- Metadata (must match decode order in decodeEncounterAsync)
        if present[SECTION.BOSS_NAMES] then
            writeBossNames(encoder, encounter.bossNames, registry)
            encoder:alignToByte()
        end
        if present[SECTION.PLAYER_ALIVE_TIME] then
            encoder:writeVarUInt(encounter.playerAliveTimeMs)
        end
        if present[SECTION.UNIT_ALIVE_TIMES] then
            writeUnitAliveTimes(encoder, encounter.unitAliveTimeMs, registry)
            encoder:alignToByte()
        end
        if present[SECTION.UNIT_NAMES] then
            writeUnitNames(encoder, encounter.unitNames, registry, progress)
            encoder:alignToByte()
        end
        if present[SECTION.DEATHS] then
            writeDeaths(encoder, encounter.deaths, registry)
            encoder:alignToByte()
        end
        if present[SECTION.SETUP] then
            if setupPooled then
                -- Reference form: the build is in the own-setup pool
                -- (_setupHash); only the per-fight food uptime overlay stays
                -- on the encounter. 0-varint = no uptime for that food.
                encoder:writeUInt(0, 8)
                local foods = encounter.setup.foods or {}
                local foodCount = writeCount(encoder, #foods, BITS.FOOD_COUNT)
                for i = 1, foodCount do
                    encoder:writeVarUInt((foods[i].uptimeMs or -1) + 1)
                end
            else
                encoder:writeUInt(1, 8)
                writeSetup(encoder, encounter.setup)
            end
            encoder:alignToByte()
        end
        if present[SECTION.WEAVING] then
            writeWeaving(encoder, encounter.weaving, registry)
            encoder:alignToByte()
        end
        flushProgress(progress)

        local chunks = encoder:finish()

        return {
            _v = CURRENT_VERSION,
            _data = chunks,
            displayName = encounter.displayName,
            location = encounter.location,
            timestampS = encounter.timestampS,
            durationMs = encounter.durationMs,
            bossesUnits = encounter.bossesUnits,
            isPlayerFight = encounter.isPlayerFight,
            isDummyFight = encounter.isDummyFight,
            sharedData = encounter.sharedData,
            bossSeqNames = encounter.bossSeqNames,
            bossTagSeqByUnitId = encounter.bossTagSeqByUnitId,
            gameVersion = encounter.gameVersion,
        }
    end)
end

---Decodes a binary-encoded encounter asynchronously.
---Returns an Effect that resolves to the decoded encounter.
---Yields between major decode steps to spread work across frames.
---@param binaryEncounter CompactEncounter The binary-encoded encounter
---@param registry RegistryArrays|nil The owning instance's ability/name registry arrays (required for v17+ encounters)
---@return Effect Effect that resolves to Encounter
function binaryStorage.decodeEncounterAsync(binaryEncounter, registry)
    return LibEffect.Async(function()
        local _v = binaryEncounter._v
        if _v < 7 or _v > CURRENT_VERSION then
            error("Invalid binary encounter version: " .. tostring(_v) .. " (expected 7-" .. tostring(CURRENT_VERSION) .. ")")
        end
        if _v >= 17 and not registry then
            error("v17+ encounter decode requires the instance registry")
        end

        local decoder = BitDecoder.new(binaryEncounter._data)

        ---@type Encounter
        local result = {
            displayName = binaryEncounter.displayName,
            location = binaryEncounter.location,
            timestampS = binaryEncounter.timestampS,
            durationMs = binaryEncounter.durationMs,
            bossesUnits = binaryEncounter.bossesUnits,
            isPlayerFight = binaryEncounter.isPlayerFight,
            isDummyFight = binaryEncounter.isDummyFight,
            sharedData = binaryEncounter.sharedData,
            bossSeqNames = binaryEncounter.bossSeqNames,
            bossTagSeqByUnitId = binaryEncounter.bossTagSeqByUnitId,
        }

        -- v17+: shared entries are stored binary in _shared; decode them into
        -- the plain SharedDataEntry[] shape all consumers expect
        if binaryEncounter._shared then
            local sharedData = {}
            for i, compactEntry in ipairs(binaryEncounter._shared) do
                sharedData[i] = binaryStorage.decodeSharedEntry(compactEntry)
            end
            result.sharedData = sharedData
        end

        -- v17+: section-presence bitmask; pre-v17 streams contain every section
        local mask = 0xFFFF
        if _v >= 17 then
            mask = decoder:readUInt(16)
        end

        ---Byte-aligns after a section read (v17 writers pad section ends)
        local function alignSection()
            if _v >= 17 then
                decoder:alignToByte()
            end
        end

        if hasSection(mask, SECTION.DAMAGE) then
            result.damageByUnitId = readDamageMap(decoder, _v, registry)
            alignSection()
            LibEffect.YieldWithGC():Await()
        else
            result.damageByUnitId = {}
        end

        if hasSection(mask, SECTION.DAMAGE_GROUP) then
            result.damageByUnitIdGroup = readDamageMap(decoder, _v, registry)
            alignSection()
            LibEffect.YieldWithGC():Await()
        else
            result.damageByUnitIdGroup = {}
        end

        if hasSection(mask, SECTION.DAMAGE_TAKEN) then
            result.damageTakenByUnitId = readDamageMap(decoder, _v, registry)
            alignSection()
            LibEffect.YieldWithGC():Await()
        else
            result.damageTakenByUnitId = {}
        end

        if hasSection(mask, SECTION.HEALING) then
            result.healingStats = readHealingStats(decoder, _v, registry)
            alignSection()
            LibEffect.YieldWithGC():Await()
        else
            result.healingStats = makeEmptyHealingStats()
        end

        if hasSection(mask, SECTION.PROCS) then
            result.procs = readProcs(decoder, _v, registry)
            alignSection()
            LibEffect.YieldWithGC():Await()
        else
            result.procs = {}
        end

        if hasSection(mask, SECTION.EFFECTS_PLAYER) then
            result.effectsOnPlayer = readEffectsOnPlayer(decoder, _v, registry)
            alignSection()
        end
        if hasSection(mask, SECTION.EFFECTS_BOSSES) then
            result.effectsOnBosses = readEffectsOnBosses(decoder, _v, registry)
            alignSection()
        end
        if hasSection(mask, SECTION.EFFECTS_GROUP) then
            result.effectsOnGroup = readEffectsOnGroup(decoder, _v, registry)
            alignSection()
        end
        if hasSection(mask, SECTION.BOSS_NAMES) then
            result.bossNames = readBossNames(decoder, _v, registry)
            alignSection()
        end

        -- playerAliveTimeMs (optional; own flag bit pre-v17, mask bit v17+)
        if _v >= 17 then
            if hasSection(mask, SECTION.PLAYER_ALIVE_TIME) then
                result.playerAliveTimeMs = decoder:readVarUInt()
            end
        elseif decoder:readBit() then
            result.playerAliveTimeMs = decoder:readUInt(BITS.TIME_MS)
        end

        if hasSection(mask, SECTION.UNIT_ALIVE_TIMES) then
            result.unitAliveTimeMs = readUnitAliveTimes(decoder, _v, registry)
            alignSection()
        end
        LibEffect.YieldWithGC():Await()

        if hasSection(mask, SECTION.UNIT_NAMES) then
            result.unitNames = readUnitNames(decoder, _v, registry)
            alignSection()
        else
            result.unitNames = {}
        end

        -- v8+: death recap data
        if _v >= 8 and hasSection(mask, SECTION.DEATHS) then
            result.deaths = readDeaths(decoder, _v, registry)
            alignSection()
        end

        -- v9+: player setup. v17+ sections start with an inline/reference
        -- byte: references resolve the build from the own-setup pool and
        -- re-apply the per-fight food uptime overlay stored here.
        if _v >= 9 and hasSection(mask, SECTION.SETUP) then
            if _v >= 17 then
                if decoder:readUInt(8) == 1 then
                    result.setup = readSetup(decoder, _v)
                else
                    local setup = binaryEncounter._setupHash
                        and BattleScrolls.storage:GetOwnSetup(binaryEncounter._setupHash) or nil
                    local foodCount = decoder:readUInt(BITS.FOOD_COUNT)
                    for i = 1, foodCount do
                        local packed = decoder:readVarUInt()
                        if packed > 0 and setup and setup.foods and setup.foods[i] then
                            setup.foods[i].uptimeMs = packed - 1
                        end
                    end
                    result.setup = setup
                end
            else
                result.setup = readSetup(decoder, _v)
            end
            alignSection()
        elseif binaryEncounter._setupHash then
            result.setup = BattleScrolls.storage:GetOwnSetup(binaryEncounter._setupHash)
        end

        -- v12+: weaving data
        if _v >= 12 and hasSection(mask, SECTION.WEAVING) then
            result.weaving = readWeaving(decoder, _v, registry)
            alignSection()
        end

        return result
    end)
end

-- =============================================================================
-- INSTANCE-LEVEL ENCODING: abilityInfo and unitNames
-- =============================================================================

-- Additional bit allocations for instance-level encoding
local BITS_DAMAGE_TYPE = 4  -- DamageType enum (16 values max)

---Reads abilityInfo from decoder
---@param decoder BitDecoder
---@param version number
---@return table<number, AbilityInfoStorage>
local function readAbilityInfo(decoder, version)
    local result = {}
    local count = decoder:readUInt(BITS.MAP_COUNT)

    for _ = 1, count do
        local abilityId = decoder:readUInt(BITS.ABILITY_ID)

        local overTime = decoder:readBit()
        local direct = decoder:readBit()
        local shield = version >= 13 and decoder:readBit() or false
        local regen = version >= 14 and decoder:readBit() or false
        local healAbsorption = version >= 15 and decoder:readBit() or false

        local typeCount = decoder:readUInt(4)
        local damageTypes = {}
        for _ = 1, typeCount do
            local damageType = decoder:readUInt(BITS_DAMAGE_TYPE)
            damageTypes[damageType] = true
        end

        local deliveryType = {
            overTime = overTime or nil,
            direct = direct or nil,
            shield = shield or nil,
            regen = regen or nil,
            healAbsorption = healAbsorption or nil,
        }
        result[abilityId] = {
            deliveryType = deliveryType,
            damageTypes = damageTypes,
        }
    end

    return result
end

---Encoded instance fields result
---@class EncodedInstanceFields
---@field _instanceData string[] Base64 encoded data chunks
---@field _instanceDataVersion number Binary schema used for instance data

---Encodes instance-level abilityInfo to binary format asynchronously.
---Returns an Effect that resolves to the encoded fields.
---@param abilityInfo table<number, AbilityInfo> The ability info to encode
---@param registry EncounterRegistry|nil The instance's ability/name registry to persist alongside (v17+)
---@return Effect Effect that resolves to EncodedInstanceFields
function binaryStorage.encodeInstanceFieldsAsync(abilityInfo, registry)
    return LibEffect.Async(function()
        local encoder = BitEncoder.new()
        local progress = { count = 0 }

        abilityInfo = abilityInfo or {}
        local count = writeTableCount(encoder, abilityInfo, BITS.MAP_COUNT)

        local written = 0
        for abilityId, info in pairs(abilityInfo) do
            if written >= count then break end
            written = written + 1
            encoder:writeUInt(abilityId, BITS.ABILITY_ID)

            local deliveryType = info.deliveryType or {}
            encoder:writeBit(deliveryType.overTime)
            encoder:writeBit(deliveryType.direct)
            encoder:writeBit(deliveryType.shield)
            encoder:writeBit(deliveryType.regen)
            encoder:writeBit(deliveryType.healAbsorption)

            local typeCount = writeTableCount(encoder, info.damageTypes or {}, 4)

            local typesWritten = 0
            for damageType in pairs(info.damageTypes or {}) do
                if typesWritten >= typeCount then break end
                typesWritten = typesWritten + 1
                encoder:writeUInt(damageType, BITS_DAMAGE_TYPE)
            end

            countAndMaybeYield(progress)
        end
        flushProgress(progress)

        -- v17: persist the encounter registries (append-only ordered arrays)
        encoder:alignToByte()
        local abilityIds = registry and registry.abilityIds or {}
        encoder:writeVarUInt(#abilityIds)
        for i = 1, #abilityIds do
            encoder:writeVarUInt(abilityIds[i])
        end
        local names = registry and registry.names or {}
        encoder:writeVarUInt(#names)
        for i = 1, #names do
            encoder:writeString(names[i])
        end

        local chunks = encoder:finish()

        return {
            _instanceData = chunks,
            _instanceDataVersion = CURRENT_VERSION,
        }
    end)
end

---Decodes instance-level abilityInfo asynchronously.
---Returns an Effect that resolves to { abilityInfo, {} }.
---Note: unitNames are stored at encounter level (not instance level).
---@param instance InstanceStorage The instance with encoded _instanceData
---@return Effect Effect that resolves to DecodedInstanceFields
function binaryStorage.decodeInstanceFieldsAsync(instance)
    return LibEffect.Async(function()
        if not instance._instanceData then
            error("Instance missing _instanceData - corrupted or incompatible format")
        end

        local decoder = BitDecoder.new(instance._instanceData)
        LibEffect.YieldWithGC():Await()

        local version = instance._instanceDataVersion or 12
        local abilityInfo = readAbilityInfo(decoder, version)
        LibEffect.YieldWithGC():Await()

        -- v17: encounter registries follow the ability info
        local abilityIds = {}
        local names = {}
        if version >= 17 then
            decoder:alignToByte()
            local abilityCount = decoder:readVarUInt()
            for i = 1, abilityCount do
                abilityIds[i] = decoder:readVarUInt()
            end
            local nameCount = decoder:readVarUInt()
            for i = 1, nameCount do
                names[i] = decoder:readString()
            end
        end

        return { abilityInfo, {}, abilityIds, names }
    end)
end
