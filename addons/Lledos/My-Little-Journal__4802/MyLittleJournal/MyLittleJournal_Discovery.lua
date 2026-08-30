-- My Little Journal — auto-discovery from game data.
--
-- Instance detection is zone-id based, the same approach used by
-- CrutchAlerts and Wizard's Wardrobe: GetZoneId(GetUnitZoneIndex("player"))
-- gives a stable numeric id for every dungeon/trial/arena, so no name
-- matching is needed once a zone id is mapped to a journal page.
--
-- Two sources keep the shipped catalog current without addon updates:
--   1. LibSets (optional): ships a patch-maintained table of every dungeon
--      and trial zone id in the game, so new DLC content (e.g. Black Gem
--      Foundry) appears automatically.
--   2. Activity Finder locations: name-based fallback when LibSets isn't
--      installed.
--
-- Bosses are intentionally NOT auto-learned from encounters: boss health
-- bars don't map cleanly onto journal entries (a single fight can expose
-- three boss units), so wrong entries kept appearing. Bosses come from the
-- shipped catalog or are added manually by the user.
--
-- Discovered entries are stored in the same saved-vars structures as the
-- user's custom entries (flagged auto = true) with deterministic ids, so
-- notes survive re-discovery and right-click delete works unchanged.

MyLittleJournal = MyLittleJournal or {}
local TJ = MyLittleJournal

TJ.Discovery = {}
local Discovery = TJ.Discovery

local MODULE = "MyLittleJournal_Discovery"

local SV

-- Runtime map of zoneId -> journal instance id, rebuilt each login.
local zoneToInstance = {}

-- Arenas aren't in LibSets' dungeon table; there are only five, with ids
-- verified against CrutchAlerts and Wizard's Wardrobe.
local ARENA_ZONE_IDS = {
    635,  -- Dragonstar Arena
    677,  -- Maelstrom Arena
    1082, -- Blackrose Prison
    1227, -- Vateshran Hollows
    1436, -- Infinite Archive
}

-- =========================
-- Name helpers
-- =========================
local function displayName(raw)
    return zo_strtrim(zo_strformat("<<1>>", raw or ""))
end

-- Loose key for matching: lowercase, no parentheticals ("(solo)"), no
-- "Veteran " prefix, alphanumerics only.
local function normName(name)
    local s = zo_strlower(displayName(name))
    s = s:gsub("%b()", "")
    s = s:gsub("^veteran%s+", "")
    s = s:gsub("[^%w]+", "")
    return s
end

-- ZOS ships internal developer test zones inside its own zone data
-- ("Trial Template", "Normal Trials", ...). None of them are real content,
-- so they must never become journal pages.
local function isJunkName(name)
    local s = normName(name)
    if s == "" then return true end
    if s:find("template", 1, true) or s:find("test", 1, true) then return true end
    return s == "trial" or s == "trials" or s == "normaltrial" or s == "normaltrials"
        or s == "dungeon" or s == "dungeons" or s == "normaldungeon" or s == "normaldungeons"
        or s == "arena" or s == "arenas"
end

local function findInstanceByName(name)
    local target = normName(name)
    if target == "" then return nil end
    for _, inst in ipairs(TJ.Data.INSTANCES) do
        if normName(inst.name) == target then return inst.id end
    end
    if SV and SV.customInstances then
        for _, inst in ipairs(SV.customInstances) do
            if normName(inst.name) == target then return inst.id end
        end
    end
    return nil
end

local function addInstance(name, category, zoneId)
    if not SV.customInstances then SV.customInstances = {} end
    local inst = { id = "auto_" .. normName(name), name = name, category = category, auto = true, zoneId = zoneId }
    table.insert(SV.customInstances, inst)
    return inst.id
end

local function zoneDisplayName(zoneId)
    if not zoneId or zoneId <= 0 then return "" end
    return displayName(GetZoneNameById(zoneId))
end

-- =========================
-- Source 1: LibSets dungeon/trial zone ids (+ hardcoded arenas)
-- =========================
-- Maps one zone id to a journal instance, creating the instance if the
-- catalog doesn't have it yet. Returns 1 if a new instance was added.
local function mapZone(zoneId, category)
    local name = zoneDisplayName(zoneId)
    if name == "" or isJunkName(name) then return 0 end
    local instanceId = findInstanceByName(name)
    if instanceId then
        zoneToInstance[zoneId] = instanceId
        return 0
    end
    zoneToInstance[zoneId] = addInstance(name, category, zoneId)
    return 1
end

local function mergeKnownZones()
    local added = 0

    if LibSets and LibSets.GetAllDungeonZoneIdData then
        local ok, zoneData = pcall(LibSets.GetAllDungeonZoneIdData)
        if ok and type(zoneData) == "table" then
            for zoneId, data in pairs(zoneData) do
                added = added + mapZone(zoneId, data.isTrial and "trial" or "dungeon")
            end
        end
    end

    for _, zoneId in ipairs(ARENA_ZONE_IDS) do
        added = added + mapZone(zoneId, "arena")
    end

    if added > 0 then
        d(string.format("|c88CCFF[Journal]|r Added %d new instance(s) from game data.", added))
        if TJ.UI and TJ.UI.NotifyDataChanged then TJ.UI.NotifyDataChanged() end
    end
end

-- =========================
-- Source 2: Activity Finder locations (fallback when LibSets is missing)
-- =========================
local ACTIVITY_CATEGORIES = {}
if LFG_ACTIVITY_DUNGEON then ACTIVITY_CATEGORIES[LFG_ACTIVITY_DUNGEON] = "dungeon" end
if LFG_ACTIVITY_MASTER_DUNGEON then ACTIVITY_CATEGORIES[LFG_ACTIVITY_MASTER_DUNGEON] = "dungeon" end
if LFG_ACTIVITY_TRIAL then ACTIVITY_CATEGORIES[LFG_ACTIVITY_TRIAL] = "trial" end

local function mergeActivityFinderLocations()
    if not (ZO_ACTIVITY_FINDER_ROOT_MANAGER and ZO_ACTIVITY_FINDER_ROOT_MANAGER.GetLocationsData) then
        return
    end

    local added = 0
    for activityType, category in pairs(ACTIVITY_CATEGORIES) do
        local ok, locations = pcall(
            ZO_ACTIVITY_FINDER_ROOT_MANAGER.GetLocationsData,
            ZO_ACTIVITY_FINDER_ROOT_MANAGER,
            activityType
        )
        if ok and type(locations) == "table" then
            for _, location in ipairs(locations) do
                local okName, rawName = pcall(function() return location:GetRawName() end)
                if okName and rawName then
                    local name = displayName(rawName):gsub("^[Vv]eteran%s+", "")
                    -- Skip "Random Dungeon" placeholders and test zones.
                    local isRandom = zo_strlower(name):find("random", 1, true) ~= nil
                    if name ~= "" and not isRandom and not isJunkName(name) and not findInstanceByName(name) then
                        addInstance(name, category)
                        added = added + 1
                    end
                end
            end
        end
    end

    if added > 0 then
        d(string.format("|c88CCFF[Journal]|r Added %d new instance(s) from the Activity Finder.", added))
        if TJ.UI and TJ.UI.NotifyDataChanged then TJ.UI.NotifyDataChanged() end
    end
end

-- =========================
-- Current location
-- =========================
local function currentZoneId()
    local zoneIndex = GetUnitZoneIndex("player")
    return zoneIndex and GetZoneId(zoneIndex) or nil
end

-- Journal id of the instance the player is currently standing in, or nil
-- when out in the world (or the zone isn't in the journal yet). Used by the
-- UI to auto-open the right page.
function Discovery.GetCurrentInstanceId()
    if not SV then return nil end

    local zoneId = currentZoneId()
    if zoneId and zoneToInstance[zoneId] then
        return zoneToInstance[zoneId]
    end

    -- Name-based fallback for zones the map doesn't cover.
    if type(IsUnitInDungeon) == "function" and not IsUnitInDungeon("player") then return nil end
    local zoneName = zoneDisplayName(zoneId)
    if zoneName == "" then return nil end
    return findInstanceByName(zoneName)
end

-- One-time cleanup: earlier versions auto-learned bosses from encounter
-- health bars, which recorded wrong entries (multi-boss fights show up as
-- separate units). Remove those, but keep any the user wrote a note for.
local function purgeAutoLearnedBosses()
    if not SV.customBosses then return end
    local removed = 0
    for instanceId, bosses in pairs(SV.customBosses) do
        for i = #bosses, 1, -1 do
            local boss = bosses[i]
            local note = SV.notes and SV.notes[instanceId] and SV.notes[instanceId][boss.key]
            if boss.auto and (note == nil or note == "") then
                table.remove(bosses, i)
                removed = removed + 1
            end
        end
        if #bosses == 0 then SV.customBosses[instanceId] = nil end
    end
    if removed > 0 then
        d(string.format("|c88CCFF[Journal]|r Removed %d auto-recorded boss entr%s (auto-learning is disabled; entries with notes were kept).",
            removed, removed == 1 and "y" or "ies"))
    end
end

-- Cleanup: remove auto-discovered pages made from ZOS test zones before the
-- junk filter existed. Anything the user actually wrote notes on is kept.
local function purgeJunkInstances()
    if not SV.customInstances then return end
    local removed = 0
    for i = #SV.customInstances, 1, -1 do
        local inst = SV.customInstances[i]
        if inst.auto and isJunkName(inst.name) then
            local hasNote = false
            local notes = SV.notes and SV.notes[inst.id]
            if notes then
                for _, text in pairs(notes) do
                    if text and zo_strtrim(text) ~= "" then
                        hasNote = true
                        break
                    end
                end
            end
            if not hasNote then
                if SV.notes then SV.notes[inst.id] = nil end
                if SV.customBosses then SV.customBosses[inst.id] = nil end
                if SV.bossOrder then SV.bossOrder[inst.id] = nil end
                table.remove(SV.customInstances, i)
                removed = removed + 1
            end
        end
    end
    if removed > 0 then
        d(string.format("|c88CCFF[Journal]|r Removed %d test-zone entr%s that leaked in from game data (e.g. \"Trial Template\").",
            removed, removed == 1 and "y" or "ies"))
    end
end

-- Cleanup: an auto-discovered instance can duplicate a shipped catalog
-- entry when the catalog later gains that instance (e.g. Black Gem Foundry
-- was auto-added before it shipped in the catalog). Fold the duplicate into
-- the catalog entry, carrying over any notes and custom bosses.
local function dedupeAutoInstances()
    if not SV.customInstances then return end

    local catalogByNorm = {}
    for _, inst in ipairs(TJ.Data.INSTANCES) do
        catalogByNorm[normName(inst.name)] = inst.id
    end

    local removed = 0
    for i = #SV.customInstances, 1, -1 do
        local inst = SV.customInstances[i]
        local catalogId = inst.auto and catalogByNorm[normName(inst.name)]
        if catalogId then
            -- Move notes across without overwriting anything already
            -- written on the catalog entry.
            local oldNotes = SV.notes and SV.notes[inst.id]
            if oldNotes then
                SV.notes[catalogId] = SV.notes[catalogId] or {}
                for key, text in pairs(oldNotes) do
                    if SV.notes[catalogId][key] == nil then
                        SV.notes[catalogId][key] = text
                    end
                end
                SV.notes[inst.id] = nil
            end

            local oldBosses = SV.customBosses and SV.customBosses[inst.id]
            if oldBosses then
                SV.customBosses[catalogId] = SV.customBosses[catalogId] or {}
                for _, boss in ipairs(oldBosses) do
                    table.insert(SV.customBosses[catalogId], boss)
                end
                SV.customBosses[inst.id] = nil
            end

            table.remove(SV.customInstances, i)
            removed = removed + 1
        end
    end

    if removed > 0 then
        d(string.format("|c88CCFF[Journal]|r Merged %d duplicate instance entr%s into the built-in catalog.",
            removed, removed == 1 and "y" or "ies"))
    end
end

-- =========================
-- Init
-- =========================
function Discovery.Init(savedVars)
    SV = savedVars

    purgeAutoLearnedBosses()
    purgeJunkInstances()
    dedupeAutoInstances()

    -- Restore zone map entries for instances discovered in past sessions.
    if SV.customInstances then
        for _, inst in ipairs(SV.customInstances) do
            if inst.zoneId then zoneToInstance[inst.zoneId] = inst.id end
        end
    end

    -- Zone/activity data isn't reliable until the world is up, and all
    -- sources are idempotent, so re-running on every load screen is fine.
    EVENT_MANAGER:RegisterForEvent(MODULE, EVENT_PLAYER_ACTIVATED, function()
        mergeKnownZones()
        if not (LibSets and LibSets.GetAllDungeonZoneIdData) then
            mergeActivityFinderLocations()
        end
    end)
end
