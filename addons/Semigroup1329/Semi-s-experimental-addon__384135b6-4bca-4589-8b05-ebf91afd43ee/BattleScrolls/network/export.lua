-----------------------------------------------------------
-- Export
-- Builds self-contained binary export streams for online sharing.
--
-- Wire format v3 (bytes, before URL transport):
--   u8  wireVersion (3; v1 lacked the facts bytes, v2 the shared-entry flags)
--   u8  flags: bit0 = body is raw-DEFLATE compressed, bit1 = archive profile
--   body (compressed when bit0 is set):
--     varint createdAtS
--     string instanceName             (string = varint byte length + bytes)
--     varint abilityCount, varint abilityId ...
--     u8 factsByte x abilityCount     (per-ability classification from the
--       instance's recorded abilityInfo: damageType in bits 0-3 (0 = unknown
--       or ambiguous), dot class in bits 4-5: 0 unknown, 1 direct, 2 dot,
--       3 mixed. Scoped to this export's own combat recordings.)
--     varint nameCount, string name ...
--     varint encounterCount
--     per encounter:
--       u8 metaFlags: bit0 = boss fight
--       string displayName
--       varint timestampS
--       varint durationMs
--       varint bossUnitCount, varint unitId ...            (bossesUnits)
--       varint tagSeqCount, (varint unitId, string key) ...(bossTagSeqByUnitId)
--       varint seqNameCount, (string key, string name) ... (bossSeqNames)
--       varint dataLen, then dataLen bytes of v17 _data
--         (re-encoded against the export registry, WITHOUT the setup
--         section - the build ships as the compact struct below)
--       varint sharedCount
--       per entry: u8 entryFlags (bit0 = the uploader's own entry),
--         string displayName, varint role, varint payloadVersion,
--         varint timestampS, varint durationMs,
--         varint payloadLen, then payload bytes (binary shared entry;
--         timestamp/duration live OUTSIDE the payload in storage too)
--       u8 hasSetup; when 1, the compact setup struct:
--         u8 flags: bit0 vengeance, bit1 werewolfEntireFight,
--                   bit2 frontBarDisabled, bit3 backBarDisabled
--         varint raceId, varint classId
--         u8 barMask (bit0 front, bit1 back, bit2 werewolf); per present bar
--           6 slots: varint abilityId, u8 crafted; when crafted:
--           varint craftedAbilityId + 3x varint scriptId
--         varint championCount, per: varint skillId, varint disciplineId
--         varint mundusCount, per: varint abilityId
--         varint foodCount, per: varint abilityId, varint uptimeMs+1 (0=none)
--         varint classSkillLineCount, per: varint skillLineId
--         varint masteryCount, per: varint abilityId
--         varint equipCount, per slot: u8 slotIndex(1-14), varint itemId,
--           varint traitType+1 (0=unknown; from GetItemLinkTraitType, so
--           retrait truth survives - itemId alone would lie for retraits),
--           varint enchantId, varint quality (GetItemLinkDisplayQuality:
--           6 = mythic override, unlike the functional variant)
--         u8 poisonMask (bit0 front, bit1 back), per: varint itemId
--         when vengeance: 4x varint weaponType, varint loadoutSkillLineId,
--           3x varint vengeancePerkDefId
--
-- The compact equip slots replace the ~70-char itemLinks: name, set, weight
-- and equip slot resolve from the item database by itemId on the viewer side.
--
-- The view profile collapses damageByUnitIdGroup to per-source/per-target
-- aggregates under pseudo-ability id 0 before encoding: the UI consumes only
-- totals from that section (arithmancer groupTotalDamage/groupDamageByBoss),
-- and the ability-level rows are the bulk of a full-group encounter.
-----------------------------------------------------------

if not SemisPlaygroundCheckAccess() then
    return
end

BattleScrolls = BattleScrolls or {}

---@class BattleScrollsExport
local export = {}
BattleScrolls.export = export

export.WIRE_VERSION = 3
export.PROFILE_VIEW = 1
export.PROFILE_ARCHIVE = 2

local FLAG_DEFLATE = 1
local FLAG_ARCHIVE = 2

-- Only bother compressing bodies that could plausibly shave a URL chunk
local COMPRESS_MIN_BYTES = 4096

-- =============================================================================
-- BASE64 <-> BYTES (same alphabet as bitcodec)
-- =============================================================================

local B64_ENCODE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local B64_VALUE = {} ---@type table<number, number> byte code -> 0-63
for i = 1, 64 do
    B64_VALUE[string.byte(B64_ENCODE, i)] = i - 1
end

local B64_CHAR = {} ---@type table<number, string> 0-63 -> char
for i = 0, 63 do
    B64_CHAR[i] = B64_ENCODE:sub(i + 1, i + 1)
end

---Decodes concatenated base64 chunks (as produced by one BitEncoder) to bytes.
---@param chunks string[] Base64 chunks
---@return string bytes
function export.chunksToBytes(chunks)
    local s = table.concat(chunks):gsub("=", "")
    local n = #s
    local out = {}
    local oi = 0
    local i = 1
    while i + 3 <= n do
        local a = B64_VALUE[string.byte(s, i)]
        local b = B64_VALUE[string.byte(s, i + 1)]
        local c = B64_VALUE[string.byte(s, i + 2)]
        local d = B64_VALUE[string.byte(s, i + 3)]
        local v = ((a * 64 + b) * 64 + c) * 64 + d
        oi = oi + 1
        out[oi] = string.char(math.floor(v / 65536), math.floor(v / 256) % 256, v % 256)
        i = i + 4
    end
    local rem = n - i + 1
    if rem == 2 then
        local a = B64_VALUE[string.byte(s, i)]
        local b = B64_VALUE[string.byte(s, i + 1)]
        oi = oi + 1
        out[oi] = string.char(math.floor((a * 64 + b) / 16))
    elseif rem == 3 then
        local a = B64_VALUE[string.byte(s, i)]
        local b = B64_VALUE[string.byte(s, i + 1)]
        local c = B64_VALUE[string.byte(s, i + 2)]
        local v = (a * 64 + b) * 64 + c
        oi = oi + 1
        out[oi] = string.char(math.floor(v / 1024), math.floor(v / 4) % 256)
    end
    return table.concat(out)
end

---Encodes a byte string as standard padded base64 (BitDecoder requires
---complete 4-char groups, so the padding is not optional).
---@param bytes string
---@return string base64
function export.bytesToBase64(bytes)
    local n = #bytes
    local out = {}
    local oi = 0
    local i = 1
    while i + 2 <= n do
        local a, b, c = string.byte(bytes, i, i + 2)
        local v = (a * 256 + b) * 256 + c
        oi = oi + 1
        out[oi] = B64_CHAR[math.floor(v / 262144)]
            .. B64_CHAR[math.floor(v / 4096) % 64]
            .. B64_CHAR[math.floor(v / 64) % 64]
            .. B64_CHAR[v % 64]
        i = i + 3
    end
    local rem = n - i + 1
    if rem == 1 then
        local a = string.byte(bytes, i)
        oi = oi + 1
        out[oi] = B64_CHAR[math.floor(a / 4)] .. B64_CHAR[(a % 4) * 16] .. "=="
    elseif rem == 2 then
        local a, b = string.byte(bytes, i, i + 1)
        local v = a * 256 + b
        oi = oi + 1
        out[oi] = B64_CHAR[math.floor(v / 1024)]
            .. B64_CHAR[math.floor(v / 16) % 64]
            .. B64_CHAR[(v % 16) * 4] .. "="
    end
    return table.concat(out)
end

-- =============================================================================
-- BYTE WRITER (wire-level framing; encounter payloads come from bitcodec)
-- =============================================================================

---@class ExportByteWriter
---@field _parts string[]
---@field _count number
local ByteWriter = {}
ByteWriter.__index = ByteWriter

---@return ExportByteWriter
function ByteWriter.new()
    return setmetatable({ _parts = {}, _count = 0 }, ByteWriter)
end

---@param byte number 0-255
function ByteWriter:writeByte(byte)
    self._count = self._count + 1
    self._parts[self._count] = string.char(byte)
end

---LEB128, identical to BitEncoder:writeVarUInt
---@param value number
function ByteWriter:writeVarUInt(value)
    value = math.floor(value or 0)
    if value < 0 then
        value = 0
    end
    while value >= 128 do
        self:writeByte(128 + value % 128)
        value = math.floor(value / 128)
    end
    self:writeByte(value)
end

---@param bytes string
function ByteWriter:writeBytes(bytes)
    self._count = self._count + 1
    self._parts[self._count] = bytes
end

---Varint byte length + raw bytes (wire-level strings; NOT bitcodec's u8-prefixed form)
---@param str string|nil
function ByteWriter:writeString(str)
    str = str or ""
    self:writeVarUInt(#str)
    self:writeBytes(str)
end

---@return string
function ByteWriter:finish()
    return table.concat(self._parts)
end

-- =============================================================================
-- VIEW-PROFILE TRANSFORM
-- =============================================================================

---Collapses source -> target -> ability -> breakdown to a single aggregated
---breakdown per source/target pair, stored under pseudo-ability id 0. Sums are
---exact; min/max ticks are the extremes across abilities.
---@param damageGroup table<number, table<number, table<number, DamageBreakdown>>>
---@return table<number, table<number, table<number, DamageBreakdown>>>
local function collapseGroupDamage(damageGroup)
    local out = {}
    for sourceUnitId, byTarget in pairs(damageGroup) do
        local outByTarget = {}
        for targetUnitId, byAbility in pairs(byTarget) do
            local total, rawTotal, ticks, critTicks = 0, 0, 0, 0
            local minTick, maxTick = nil, 0
            for _, breakdown in pairs(byAbility) do
                total = total + (breakdown.total or 0)
                rawTotal = rawTotal + (breakdown.rawTotal or breakdown.total or 0)
                ticks = ticks + (breakdown.ticks or 0)
                critTicks = critTicks + (breakdown.critTicks or 0)
                local bMin = breakdown.minTick or 0
                if minTick == nil or bMin < minTick then
                    minTick = bMin
                end
                local bMax = breakdown.maxTick or 0
                if bMax > maxTick then
                    maxTick = bMax
                end
            end
            outByTarget[targetUnitId] = {
                [0] = BattleScrolls.structures.makeDamageBreakdown(
                    total, rawTotal, ticks, critTicks, minTick or 0, maxTick),
            }
        end
        out[sourceUnitId] = outByTarget
    end
    return out
end

-- =============================================================================
-- COMPACT SETUP (wire form of PlayerSetup; replaces the bit-packed blob)
-- =============================================================================

---@class ExportEquipSlot
---@field slotIndex number 1-14
---@field itemId number
---@field traitType number GetItemLinkTraitType result (retrait-aware); -1 unknown
---@field enchantId number
---@field quality number

---@class ExportSetup
---@field setup PlayerSetup The decoded setup (bars, champion, mundus, ...)
---@field equipSlots ExportEquipSlot[]
---@field frontPoisonItemId number 0 when none
---@field backPoisonItemId number 0 when none

---@param link string
---@return number itemId
local function linkItemId(link)
    return tonumber(link:match("|H%d:item:(%d+)")) or 0
end

---Precomputes per-slot facts the viewer cannot derive from the itemId alone.
---Runs in-game where the item link APIs are available.
---@param setup PlayerSetup
---@return ExportSetup
local function buildExportSetup(setup)
    local equipSlots = {}
    for i = 1, 14 do
        local link = setup.equipSlots and setup.equipSlots[i]
        if link and link ~= "" then
            equipSlots[#equipSlots + 1] = {
                slotIndex = i,
                itemId = linkItemId(link),
                traitType = GetItemLinkTraitType(link),
                enchantId = GetItemLinkFinalEnchantId(link),
                -- Display quality: functional quality caps at Legendary,
                -- only the display variant reports the Mythic override
                quality = GetItemLinkDisplayQuality(link),
            }
        end
    end
    return {
        setup = setup,
        equipSlots = equipSlots,
        frontPoisonItemId = setup.frontPoison and linkItemId(setup.frontPoison.itemLink) or 0,
        backPoisonItemId = setup.backPoison and linkItemId(setup.backPoison.itemLink) or 0,
    }
end

---@param body ExportByteWriter
---@param bar PlayerSetupAbility[]
local function writeExportBar(body, bar)
    for i = 1, 6 do
        local ability = bar[i] or {}
        body:writeVarUInt(ability.abilityId or 0)
        if ability.craftedAbilityId then
            body:writeByte(1)
            body:writeVarUInt(ability.craftedAbilityId)
            local scripts = ability.scriptIds or {}
            body:writeVarUInt(scripts[1] or 0)
            body:writeVarUInt(scripts[2] or 0)
            body:writeVarUInt(scripts[3] or 0)
        else
            body:writeByte(0)
        end
    end
end

---@param body ExportByteWriter
---@param exportSetup ExportSetup|nil
local function writeExportSetup(body, exportSetup)
    if not exportSetup then
        body:writeByte(0)
        return
    end
    body:writeByte(1)
    local setup = exportSetup.setup
    body:writeByte((setup.isVengeance and 1 or 0)
        + (setup.werewolfEntireFight and 2 or 0)
        + (setup.frontBarDisabled and 4 or 0)
        + (setup.backBarDisabled and 8 or 0))
    body:writeVarUInt(setup.raceId or 0)
    body:writeVarUInt(setup.classId or 0)

    local front = setup.abilities and setup.abilities.front
    local back = setup.abilities and setup.abilities.back
    local werewolf = setup.werewolfAbilities
    body:writeByte((front and 1 or 0) + (back and 2 or 0) + (werewolf and 4 or 0))
    if front then writeExportBar(body, front) end
    if back then writeExportBar(body, back) end
    if werewolf then writeExportBar(body, werewolf) end

    local champion = setup.champion or {}
    body:writeVarUInt(#champion)
    for _, skill in ipairs(champion) do
        body:writeVarUInt(skill.skillId)
        body:writeVarUInt(skill.disciplineId)
    end

    local mundus = setup.mundusAbilityIds or {}
    body:writeVarUInt(#mundus)
    for _, id in ipairs(mundus) do
        body:writeVarUInt(id)
    end

    local foods = setup.foods or {}
    body:writeVarUInt(#foods)
    for _, food in ipairs(foods) do
        body:writeVarUInt(food.abilityId)
        body:writeVarUInt((food.uptimeMs or -1) + 1)
    end

    local skillLines = setup.classSkillLineIds or {}
    body:writeVarUInt(#skillLines)
    for _, id in ipairs(skillLines) do
        body:writeVarUInt(id)
    end

    local mastery = setup.classMasteryAbilityIds or {}
    body:writeVarUInt(#mastery)
    for _, id in ipairs(mastery) do
        body:writeVarUInt(id)
    end

    body:writeVarUInt(#exportSetup.equipSlots)
    for _, slot in ipairs(exportSetup.equipSlots) do
        body:writeByte(slot.slotIndex)
        body:writeVarUInt(slot.itemId)
        body:writeVarUInt((slot.traitType or -1) + 1)
        body:writeVarUInt(slot.enchantId or 0)
        body:writeVarUInt(slot.quality or 0)
    end

    body:writeByte((exportSetup.frontPoisonItemId > 0 and 1 or 0)
        + (exportSetup.backPoisonItemId > 0 and 2 or 0))
    if exportSetup.frontPoisonItemId > 0 then
        body:writeVarUInt(exportSetup.frontPoisonItemId)
    end
    if exportSetup.backPoisonItemId > 0 then
        body:writeVarUInt(exportSetup.backPoisonItemId)
    end

    if setup.isVengeance then
        local weaponTypes = setup.weaponTypes or {}
        for i = 1, 4 do
            body:writeVarUInt(weaponTypes[i] or 0)
        end
        body:writeVarUInt(setup.loadoutSkillLineId or 0)
        local perks = setup.vengeancePerkDefIds or {}
        for i = 1, 3 do
            body:writeVarUInt(perks[i] or 0)
        end
    end
end

-- =============================================================================
-- STREAM BUILDER
-- =============================================================================

---@class ExportEncounterEntry
---@field displayName string
---@field timestampS number
---@field durationMs number
---@field isBoss boolean
---@field bossesUnits number[]
---@field bossTagSeqByUnitId table<number, string>
---@field bossSeqNames table<string, string>
---@field dataBytes string
---@field shared ExportSharedEntry[]
---@field exportSetup ExportSetup|nil

---@class ExportSharedEntry
---@field isSelf boolean True when this is the uploader's own entry
---@field displayName string
---@field role number
---@field payloadVersion number
---@field timestampS number
---@field durationMs number
---@field payloadBytes string

---@class ExportResult
---@field bytes string Final stream (header + body, body possibly compressed)
---@field profile number export.PROFILE_VIEW or export.PROFILE_ARCHIVE
---@field encounterCount number Encounters included
---@field skipped number Encounters that failed to decode (archive only)

---Extracts binary shared entries for one encounter. Reuses the stored binary
---payloads when present (v17); legacy plain sharedData is encoded fresh.
---@param encounter CompactEncounter
---@param decoded Encounter
---@return ExportSharedEntry[]
local function collectSharedEntries(encounter, decoded)
    local binaryStorage = BattleScrolls.binaryStorage
    -- The uploader's own broadcast entry is marked explicitly: the viewer
    -- must not have to guess which member the personal data belongs to
    local ownName = BattleScrolls.utils.GetUndecoratedDisplayName("player")
    local entries = {}
    local compactEntries = encounter._shared
    if not compactEntries and decoded.sharedData then
        compactEntries = {}
        for i, entry in ipairs(decoded.sharedData) do
            compactEntries[i] = binaryStorage.encodeSharedEntry(entry)
        end
    end
    for i, compact in ipairs(compactEntries or {}) do
        entries[i] = {
            displayName = compact.d or "",
            isSelf = compact.d == ownName,
            role = compact.r or 0,
            payloadVersion = compact.v or 17,
            timestampS = compact.t or 0,
            durationMs = compact.u or 0,
            payloadBytes = export.chunksToBytes(compact.c),
        }
    end
    return entries
end

---Wire facts byte for one ability: damage type + dot/direct class from the
---delivery flags and damage-type set the combat recorder stored per instance.
---An ability recorded with several damage types encodes 0 (unknown) - the
---component model says that should not happen, so ambiguity is not guessed at.
---@param info AbilityInfo|nil
---@return number
local function factsByte(info)
    if not info then
        return 0
    end
    local delivery = info.deliveryType or {}
    local class = 0
    if delivery.overTime and delivery.direct then
        class = 3
    elseif delivery.overTime then
        class = 2
    elseif delivery.direct then
        class = 1
    end
    local damageType = 0
    for dt in pairs(info.damageTypes or {}) do
        if damageType ~= 0 then
            damageType = 0
            break
        end
        damageType = dt
    end
    if damageType > 15 then
        damageType = 0
    end
    return damageType + class * 16
end

---Decodes and re-encodes the given stored encounters against a fresh export
---registry, then frames everything into one wire body.
---@param instance InstanceStorage
---@param encounters CompactEncounter[]
---@param profile number
---@return Effect Effect resolving to ExportResult
local function buildStreamAsync(instance, encounters, profile)
    return LibEffect.Async(function()
        local binaryStorage = BattleScrolls.binaryStorage
        local registry = binaryStorage.newRegistry()

        -- The instance's recorded abilityInfo (delivery flags + damage types
        -- seen in combat) classifies every export registry id - it has been
        -- part of every recording, so old encounters are covered too
        ---@type table<number, AbilityInfo>
        local abilityInfo
        if instance.abilityInfo then
            abilityInfo = instance.abilityInfo
        elseif instance._instanceData then
            abilityInfo = BattleScrolls.storage.DecodeInstanceFieldsAsync(instance):Await()[1]
        else
            abilityInfo = {}
        end
        ---@type ExportEncounterEntry[]
        local entries = {}
        local skipped = 0

        for _, encounter in ipairs(encounters) do
            ---@type Encounter|nil
            local decoded = BattleScrolls.storage.DecodeEncounterAsync(encounter, instance)
                :Recover(function() return nil end):Await()
            if decoded then
                if profile == export.PROFILE_VIEW
                    and next(decoded.damageByUnitIdGroup or {}) ~= nil then
                    decoded.damageByUnitIdGroup = collapseGroupDamage(decoded.damageByUnitIdGroup)
                end
                -- The build travels as the compact wire struct, not the
                -- bit-packed blob: strip it before encoding the encounter
                local exportSetup = decoded.setup and buildExportSetup(decoded.setup) or nil
                decoded.setup = nil
                local compact = binaryStorage.encodeEncounterAsync(decoded, false, registry):Await()
                entries[#entries + 1] = {
                    displayName = encounter.displayName or "",
                    timestampS = encounter.timestampS or 0,
                    durationMs = encounter.durationMs or 0,
                    isBoss = next(encounter.bossesUnits or {}) ~= nil,
                    bossesUnits = encounter.bossesUnits or {},
                    bossTagSeqByUnitId = encounter.bossTagSeqByUnitId or {},
                    bossSeqNames = encounter.bossSeqNames or {},
                    dataBytes = export.chunksToBytes(compact._data),
                    shared = collectSharedEntries(encounter, decoded),
                    exportSetup = exportSetup,
                }
            else
                skipped = skipped + 1
            end
            LibEffect.YieldWithGC():Await()
        end

        if #entries == 0 then
            error("export: no encounter could be decoded")
        end

        local body = ByteWriter.new()
        body:writeVarUInt(GetTimeStamp())
        -- The journal titles instances by zone; instanceName on the wire is
        -- the same string ("Earthen Root Enclave", "Sunspire", ...)
        body:writeString(instance.zone or "")
        body:writeVarUInt(#registry.abilityIds)
        for i = 1, #registry.abilityIds do
            body:writeVarUInt(registry.abilityIds[i])
        end
        -- Per-ability classification, scoped to this export: the recorder
        -- saw every registry id's combat events in this very instance, so
        -- coverage is exact - and a bad actor can only mislabel their own share
        for i = 1, #registry.abilityIds do
            body:writeByte(factsByte(abilityInfo[registry.abilityIds[i]]))
        end
        body:writeVarUInt(#registry.names)
        for i = 1, #registry.names do
            body:writeString(registry.names[i])
        end
        body:writeVarUInt(#entries)
        for _, entry in ipairs(entries) do
            body:writeByte(entry.isBoss and 1 or 0)
            body:writeString(entry.displayName)
            body:writeVarUInt(entry.timestampS)
            body:writeVarUInt(entry.durationMs)
            body:writeVarUInt(#entry.bossesUnits)
            for _, unitId in ipairs(entry.bossesUnits) do
                body:writeVarUInt(unitId)
            end
            local tagSeqCount = 0
            for _ in pairs(entry.bossTagSeqByUnitId) do
                tagSeqCount = tagSeqCount + 1
            end
            body:writeVarUInt(tagSeqCount)
            for unitId, key in pairs(entry.bossTagSeqByUnitId) do
                body:writeVarUInt(unitId)
                body:writeString(key)
            end
            local seqNameCount = 0
            for _ in pairs(entry.bossSeqNames) do
                seqNameCount = seqNameCount + 1
            end
            body:writeVarUInt(seqNameCount)
            for key, name in pairs(entry.bossSeqNames) do
                body:writeString(key)
                body:writeString(name)
            end
            body:writeVarUInt(#entry.dataBytes)
            body:writeBytes(entry.dataBytes)
            body:writeVarUInt(#entry.shared)
            for _, shared in ipairs(entry.shared) do
                body:writeByte(shared.isSelf and 1 or 0)
                body:writeString(shared.displayName)
                body:writeVarUInt(shared.role)
                body:writeVarUInt(shared.payloadVersion)
                body:writeVarUInt(shared.timestampS)
                body:writeVarUInt(shared.durationMs)
                body:writeVarUInt(#shared.payloadBytes)
                body:writeBytes(shared.payloadBytes)
            end
            writeExportSetup(body, entry.exportSetup)
        end

        local bodyBytes = body:finish()
        local flags = profile == export.PROFILE_ARCHIVE and FLAG_ARCHIVE or 0

        -- Optional compression: only when the module is present and it wins
        local deflate = BattleScrolls.deflate
        if deflate and #bodyBytes >= COMPRESS_MIN_BYTES then
            local compressed = deflate.compressAsync(bodyBytes):Await()
            if compressed and #compressed < #bodyBytes then
                bodyBytes = compressed
                flags = flags + FLAG_DEFLATE
            end
        end

        return {
            bytes = string.char(export.WIRE_VERSION, flags) .. bodyBytes,
            profile = profile,
            encounterCount = #entries,
            skipped = skipped,
        }
    end)
end

---Builds a single-encounter share (view profile: group damage collapsed to
---per-source/per-target totals).
---@param instance InstanceStorage
---@param encounter CompactEncounter
---@return Effect Effect resolving to ExportResult
function export.buildEncounterShareAsync(instance, encounter)
    return buildStreamAsync(instance, { encounter }, export.PROFILE_VIEW)
end

---Builds a whole-instance archive (full fidelity, every encounter).
---@param instance InstanceStorage
---@return Effect Effect resolving to ExportResult
function export.buildInstanceArchiveAsync(instance)
    return buildStreamAsync(instance, instance.encounters, export.PROFILE_ARCHIVE)
end
