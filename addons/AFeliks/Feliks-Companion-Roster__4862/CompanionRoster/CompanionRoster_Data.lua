CompanionRoster = CompanionRoster or {}
local CompanionRoster = CompanionRoster -- local reference, faster than repeated _G lookups

CompanionRoster.name = "CompanionRoster"
CompanionRoster.savedVariablesVersion = 1
CompanionRoster.Data = {}

-- Keep this in sync with ## Version in CompanionRoster.txt on every bump -
-- there's no runtime API that reads the manifest's free-text Version
-- string back (GetAddOnManager():GetAddOnVersion() returns the separate
-- numeric ## AddOnVersion tag instead, meant for dependency checks, not
-- display), so this has to be maintained by hand.
CompanionRoster.version = "2.0.8"

local savedVars = nil

local function GetCharacterKey()
    return GetUnitName("player")
end

local function GetOrCreateCharacterEntry(characterKey)
    if savedVars.characters[characterKey] == nil then
        savedVars.characters[characterKey] = { companions = {}, introQuestsDone = {} }
    end
    if savedVars.characters[characterKey].introQuestsDone == nil then
        savedVars.characters[characterKey].introQuestsDone = {}
    end
    return savedVars.characters[characterKey]
end

-- companionId is a small integer (currently 1 through the low teens, with
-- gaps) valid to query directly for any companion regardless of summon
-- state. Set comfortably above the current range so new companions are
-- picked up automatically without a code change.
local MAX_COMPANION_DEF_ID = 30

-- Public read API. Kept narrow and free of any UI concerns so this file
-- could be lifted into a standalone embeddable library later without
-- reworking its interface.

-- All real companions, discovered live rather than hardcoded, in display
-- (alphabetical) order. Each entry: { id = companionId, collectibleId =
-- <the companion's own collectible id>, name = <display name> }.
function CompanionRoster.Data.GetAllCompanions()
    local companions = {}
    for companionId = 1, MAX_COMPANION_DEF_ID do
        local collectibleId = GetCompanionCollectibleId(companionId)
        if collectibleId ~= nil and collectibleId > 0 then
            table.insert(companions, {
                id = companionId,
                collectibleId = collectibleId,
                name = zo_strformat("<<1>>", GetCompanionName(companionId)),
            })
        end
    end
    table.sort(companions, function(a, b) return a.name < b.name end)
    return companions
end

local function RecordActiveCompanion()
    if not HasActiveCompanion() then
        return
    end

    local companionId = GetActiveCompanionDefId()
    if companionId == nil or companionId == 0 then
        return
    end

    local rapportLevel = GetActiveCompanionRapportLevel()
    local level = GetActiveCompanionLevelInfo()
    local passivePerkId = GetCompanionPassivePerkAbilityId(companionId)

    local entry = {
        name = zo_strformat("<<1>>", GetCompanionName(companionId)),
        level = level,
        rapportValue = GetActiveCompanionRapport(),
        rapportMax = GetMaximumRapport(),
        rapportLevel = rapportLevel,
        rapportLevelText = GetActiveCompanionRapportLevelDescription(rapportLevel),
        passivePerkName = zo_strformat("<<1>>", GetAbilityName(passivePerkId)),
        passivePerkDescription = GetAbilityDescription(passivePerkId),
        lastUpdated = GetTimeStamp(),
    }

    local character = GetOrCreateCharacterEntry(GetCharacterKey())
    character.companions[companionId] = entry
end

-- Live-queryable for any companion without needing it summoned, but only
-- reflects the character currently logged in. Empty quest name means not
-- completed by this character.
local function IsIntroQuestCompleteForActiveCharacter(companionId)
    local introQuestId = GetCompanionIntroQuestId(companionId)
    if introQuestId == nil or introQuestId == 0 then
        return false
    end
    local questName = GetCompletedQuestInfo(introQuestId)
    return questName ~= nil and questName ~= ""
end

-- Records, for the currently active character, whether each companion's
-- recruitment quest is done - not tied to any particular companion being
-- summoned, unlike rapport/level/perk, so this runs once per login/reload
-- for every known companion rather than being event-driven per companion.
local function RecordIntroQuestCompletion()
    local character = GetOrCreateCharacterEntry(GetCharacterKey())
    for _, companion in ipairs(CompanionRoster.Data.GetAllCompanions()) do
        character.introQuestsDone[companion.id] = IsIntroQuestCompleteForActiveCharacter(companion.id)
    end
end

local function OnPlayerActivated()
    RecordActiveCompanion()
    RecordIntroQuestCompletion()
end

local function OnCompanionActivated()
    RecordActiveCompanion()
end

local function OnCompanionRapportUpdate()
    RecordActiveCompanion()
end

local function OnCompanionExperienceGain()
    RecordActiveCompanion()
end

function CompanionRoster.Data.GetCharacterNames()
    local names = {}
    for characterKey in pairs(savedVars.characters) do
        table.insert(names, characterKey)
    end
    table.sort(names)
    return names
end

function CompanionRoster.Data.GetCurrentCharacterName()
    return GetCharacterKey()
end

-- Window position is a UI preference, not game data, so it's account-wide
-- (not per-character) - independent of savedVars.characters.
function CompanionRoster.Data.SaveWindowPosition(point, relativePoint, offsetX, offsetY)
    savedVars.windowPosition = { point = point, relativePoint = relativePoint, offsetX = offsetX, offsetY = offsetY }
end

function CompanionRoster.Data.GetWindowPosition()
    return savedVars.windowPosition
end

function CompanionRoster.Data.GetCompanionsForCharacter(characterKey)
    local character = savedVars.characters[characterKey]
    if character == nil then
        return {}
    end
    return character.companions
end

-- A companion's passive perk doesn't vary by character, unlike rapport and
-- level - so if the currently selected character hasn't recorded it yet,
-- fall back to any character that has.
function CompanionRoster.Data.GetPassivePerkInfo(companionId)
    for _, character in pairs(savedVars.characters) do
        local info = character.companions[companionId]
        if info and info.passivePerkName then
            return info.passivePerkName, info.passivePerkDescription
        end
    end
    return nil, nil
end

-- Companion -> Keepsake collectible id. The Keepsake (Collections >
-- Upgrade > Companion Keepsakes) makes that companion's passive perk
-- always active, even when not summoned, once its meta-achievement is
-- done. No API derives this id from a companionId, so it's hardcoded -
-- found via chat-linking each one in-game (|H1:collectible:<id>|h|h).
local KEEPSAKE_COLLECTIBLE_IDS = {
    ["Azandar"] = 11453,
    ["Bastian Hallix"] = 9457,
    ["Ember"] = 10436,
    ["Isobel Veloise"] = 10437,
    ["Mirri Elendis"] = 9458,
    ["Sharp-as-Night"] = 11452,
    ["Tanlorin"] = 12227,
    ["Zerith-var"] = 12228,
}

-- Account-wide, so this doesn't depend on which character is selected.
function CompanionRoster.Data.IsKeepsakeUnlocked(companionName)
    local collectibleId = KEEPSAKE_COLLECTIBLE_IDS[companionName]
    if collectibleId == nil then
        return false
    end
    return IsCollectibleUnlocked(collectibleId)
end

-- Whether the account has this companion's own collectible at all
-- (account-wide - the same "Collected" flag the Collections screen shows).
-- Note this is NOT the same as being able to summon them on any particular
-- character - see CanSummonCompanion below for that.
function CompanionRoster.Data.IsCompanionOwned(companionId)
    local collectibleId = GetCompanionCollectibleId(companionId)
    if collectibleId == nil or collectibleId == 0 then
        return false
    end
    return IsCollectibleUnlocked(collectibleId)
end

-- Owned account-wide AND this character has completed the recruitment
-- quest - the Collections screen can show a companion as "Collected"
-- while still blocking summon on a character who hasn't personally met
-- them, so ownership alone isn't enough. Returns true/false if known, or
-- nil if this character's quest completion was never recorded.
function CompanionRoster.Data.CanSummonCompanion(characterKey, companionId)
    if not CompanionRoster.Data.IsCompanionOwned(companionId) then
        return false
    end

    local character = savedVars.characters[characterKey]
    if character == nil or character.introQuestsDone == nil then
        return nil
    end
    return character.introQuestsDone[companionId]
end

local function OnAddOnLoaded(eventCode, addOnName)
    if addOnName ~= CompanionRoster.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent("CompanionRoster_Data", EVENT_ADD_ON_LOADED)

    -- GetWorldName() as the namespace splits saved data by server (EU/NA/PTS)
    -- rather than mixing it - matters because data here is keyed by
    -- character name, not character id, and the same @account can play on
    -- more than one server where two different characters could share a name.
    local defaults = { characters = {} }
    savedVars = ZO_SavedVars:NewAccountWide("CompanionRoster_SavedVariables", CompanionRoster.savedVariablesVersion, GetWorldName(), defaults)

    EVENT_MANAGER:RegisterForEvent("CompanionRoster_Data", EVENT_COMPANION_ACTIVATED, OnCompanionActivated)
    EVENT_MANAGER:RegisterForEvent("CompanionRoster_Data", EVENT_COMPANION_RAPPORT_UPDATE, OnCompanionRapportUpdate)
    EVENT_MANAGER:RegisterForEvent("CompanionRoster_Data", EVENT_COMPANION_EXPERIENCE_GAIN, OnCompanionExperienceGain)
    EVENT_MANAGER:RegisterForEvent("CompanionRoster_Data", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent("CompanionRoster_Data", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
