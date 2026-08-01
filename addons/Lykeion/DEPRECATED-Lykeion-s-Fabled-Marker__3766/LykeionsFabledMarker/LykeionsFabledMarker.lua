LFM = {}

LFM.name = "LykeionsFabledMarker"
author = "|c215895Lykeion|r"
local SV_NAME = 'FABLED_MARKER_VARS'
local SV_VER = 1

local availableMarkers = {
TARGET_MARKER_TYPE_ONE, -- 1 Blue Square -- backup marker
TARGET_MARKER_TYPE_TWO, -- 2 Star
TARGET_MARKER_TYPE_THREE, -- 3 Green Circle -- Totem
TARGET_MARKER_TYPE_FOUR, -- 4 Red Tri -- Flame
TARGET_MARKER_TYPE_FIVE, -- 5 Moon -- Sun Eater
TARGET_MARKER_TYPE_SIX, -- 6 Daedra -- Infuser
TARGET_MARKER_TYPE_SEVEN, -- 7 Cross Blade -- Spellthief
TARGET_MARKER_TYPE_EIGHT -- 8 Skull
}

local fabeldMale = {
    [GetString(LFM_FABLED_SPELLTHIEF_MALE)] = "ST",
    [GetString(LFM_FABLED_TOTEM_MASTER_MALE)] = "TM",
    [GetString(LFM_FABLED_SUN_EATER_MALE)] = "SE",
    [GetString(LFM_FABLED_INFUSER_MALE)] = "IN",
    [GetString(LFM_FABLED_FLAMESHAPER_MALE)] = "FS"
}
local fabeldFemale = {
    [GetString(LFM_FABLED_SPELLTHIEF_FEMALE)] = "ST",
    [GetString(LFM_FABLED_TOTEM_MASTER_FEMALE)] = "TM",
    [GetString(LFM_FABLED_SUN_EATER_FEMALE)] = "SE",
    [GetString(LFM_FABLED_INFUSER_FEMALE)] = "IN",
    [GetString(LFM_FABLED_FLAMESHAPER_FEMALE)] = "FS"
}

-- Each wave has a maximum of 2 fabled foes so only one variable is needed to keep track of the used marker
local usedMark = ""

local playerLang = ""

local eaZoneId = 1436

function LFM:Initialize()
    -- LFM:AddonMenu()
end

local function GetMarker(fabledType)
    if (fabledType == "ST") then
        return TARGET_MARKER_TYPE_SEVEN
    elseif (fabledType == "TM") then
        return TARGET_MARKER_TYPE_THREE
    elseif (fabledType == "SE") then
        return TARGET_MARKER_TYPE_FIVE
    elseif (fabledType == "IN") then
        return TARGET_MARKER_TYPE_SIX
    elseif (fabledType == "FS") then
        return TARGET_MARKER_TYPE_FOUR
    end
    return nil
end

local function GetAvailableMarker(fabledType)
    if (usedMark == fabledType) then
        return TARGET_MARKER_TYPE_ONE
    end

    usedMark = fabledType
    return GetMarker(fabledType)
end

-- this can't always be correctly called since the existence of Tho'at blob
local function OnCombatStateChanged(_, inCombat)
    if (not inCombat) then
        usedMark = ""
    end
end

local function GetTargetFabledType()
    local fabledNameList = {}
	local fabledName = GetUnitName("reticleover")

	-- fabled names in these languages are gender-neutral
    if (playerLang == "zh" or playerLang == "ze" or playerLang == "en" or playerLang == "jp") then
        fabledNameList = fabeldMale
    else
        local gender = GetUnitGender("reticleover")
        -- CHAT_SYSTEM:AddMessage(GetUnitGender("reticleover") .. " : " .. GetUnitName("reticleover"))

        if (gender == GENDER_MALE) then
            fabledNameList = fabeldMale
        elseif (gender == GENDER_FEMALE) then
            fabledNameList = fabeldFemale
        end
    end

    return fabledNameList[fabledName]

    -- if (fabledNameList[fabledName] ~= nil) then
    --     local fabledType = fabledNameList[fabledName]
    --     -- AssignTargetMarkerToReticleTarget(GetAvailableMarker(fabledType))
    --     return fabledType
    -- end
    -- return nil
end


local function OnReticleChanged()
    if (not IsUnitAttackable("reticleover")
	-- or GetUnitTargetMarkerType("reticleover") ~= TARGET_MARKER_TYPE_NONE 
	or GetUnitDifficulty("reticleover") ~= MONSTER_DIFFICULTY_HARD) then
        return
    end

    local targetFabledType = GetTargetFabledType()

    -- if it should be marked and haven't been properly marked
    if (targetFabledType ~= nil and GetUnitTargetMarkerType("reticleover") ~= GetMarker(targetFabledType) and GetUnitTargetMarkerType("reticleover") ~= TARGET_MARKER_TYPE_ONE) then
        AssignTargetMarkerToReticleTarget(GetAvailableMarker(targetFabledType))
    end

end

local function OnPlayerActivated()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    playerLang = GetCVar("Language.2")

    if (GetZoneId(GetUnitZoneIndex("player")) == eaZoneId) then
        usedMark = ""

        EVENT_MANAGER:RegisterForEvent(LFM.name .. "Combat", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
        EVENT_MANAGER:RegisterForEvent(LFM.name .. "Target", EVENT_RETICLE_TARGET_CHANGED, OnReticleChanged)
    else
        EVENT_MANAGER:UnregisterForEvent(LFM.name .. "Combat", EVENT_PLAYER_COMBAT_STATE)
        EVENT_MANAGER:UnregisterForEvent(LFM.name .. "Target", EVENT_RETICLE_TARGET_CHANGED)
    end
end

function LFM.OnAddOnLoaded(event, addonName)
    if addonName == LFM.name then
        LFM:Initialize()
    end
end
EVENT_MANAGER:RegisterForEvent(LFM.name, EVENT_ADD_ON_LOADED, LFM.OnAddOnLoaded)

EVENT_MANAGER:RegisterForEvent(LFM.name .. "Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
