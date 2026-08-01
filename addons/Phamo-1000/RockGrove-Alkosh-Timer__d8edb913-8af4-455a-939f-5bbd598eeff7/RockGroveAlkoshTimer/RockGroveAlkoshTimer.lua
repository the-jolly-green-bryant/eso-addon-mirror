RockGroveAlkoshTimer = {}
local RGAT = RockGroveAlkoshTimer

local LAM  -- initialize after addon loaded

----------------------------------------------------------------
-- Saved Variables Defaults
----------------------------------------------------------------
local defaults = {
    posX = 0,
    posY = 0,
    scale = 1.0,
}

RGAT.SV = nil

----------------------------------------------------------------
-- Rockgrove Bosses
----------------------------------------------------------------
RGAT.BOSSES = {
    [157177] = "Oaxiltso",
    [157178] = "Flame-Herald Bahsei",
    [157179] = "Xalvakka",
}

-- TEMP placeholder until debug logs show correct ID
local ALKOSH_DEBUFF_ID = 76667

----------------------------------------------------------------
-- Initialization
----------------------------------------------------------------
RGAT.inBossFight = false
RGAT.currentTimerEnd = 0
RGAT.debugMode = true
RGAT.UILoaded = false

----------------------------------------------------------------
-- Update UI safely
----------------------------------------------------------------
local function RGAT_UpdateUIPosition()
    if not RGAT.UILoaded then return end
    RGAT_Window:ClearAnchors()
    RGAT_Window:SetAnchor(CENTER, GuiRoot, CENTER, RGAT.SV.posX, RGAT.SV.posY)
end

local function RGAT_UpdateUIScale()
    if not RGAT.UILoaded then return end
    RGAT_Window:SetScale(RGAT.SV.scale)
end

----------------------------------------------------------------
-- Load UI controls safely
----------------------------------------------------------------
local function RGAT_TryLoadUI()
    if RGAT.UILoaded then return end

    if RGAT_Window ~= nil and RGAT_Label ~= nil then
        RGAT.UILoaded = true

        RGAT_Window:SetHidden(false)
        RGAT_Label:SetText("|cFF0000Alkosh: 0|r")

        -- Apply saved position + scale safely
        RGAT_UpdateUIPosition()
        RGAT_UpdateUIScale()
    end
end

----------------------------------------------------------------
-- Rockgrove boss detection helper
----------------------------------------------------------------
local function RGAT_IsRockgroveBoss(unitTag)
    local name = GetUnitName(unitTag)
    for _, bossName in pairs(RGAT.BOSSES) do
        if name == bossName then return true end
    end
    return false
end

----------------------------------------------------------------
-- Combat State
----------------------------------------------------------------
function RGAT.OnCombatState(event, inCombat)
    RGAT_TryLoadUI()

    if inCombat then
        for i = 1, 6 do
            if RGAT_IsRockgroveBoss("boss" .. i) then
                RGAT.inBossFight = true
                return
            end
        end
    end

    RGAT.inBossFight = false
    RGAT.currentTimerEnd = 0
    if RGAT.UILoaded then
        RGAT_Label:SetText("|cFF0000Alkosh: 0|r")
    end
end

----------------------------------------------------------------
-- Debug Print for Boss Debuff
----------------------------------------------------------------
--[[local function RGAT_DebugEffect(effectName, abilityId, unitTag)
    if not RGAT.debugMode or not RGAT.inBossFight then return end

    local bossName = GetUnitName(unitTag)
    if effectName and string.find(string.lower(effectName), "alkosh") then
        d(string.format("[RGAT Debug] %s applied to %s (%s) (ID: %d)", effectName, unitTag, bossName, abilityId))
    end
end]]

----------------------------------------------------------------
-- Effect Changed
----------------------------------------------------------------
function RGAT.OnEffectChanged(event, changeType, effectSlot, effectName, unitTag,
                              beginTime, endTime, stackCount, iconName, buffType,
                              effectType, abilityType, statusEffectType, unitName,
                              unitId, abilityId)

    -- Only track Rockgrove bosses
    if unitTag ~= "boss1" and unitTag ~= "boss2" and unitTag ~= "boss3" then return end

    --RGAT_DebugEffect(effectName, abilityId, unitTag)

    if not RGAT.inBossFight then return end
    if not RGAT.UILoaded then return end

    -- Only track the debuff with correct ability ID
    if abilityId == ALKOSH_DEBUFF_ID and changeType == EFFECT_RESULT_GAINED then
        RGAT.currentTimerEnd = endTime
    end
end

----------------------------------------------------------------
-- Color Logic
----------------------------------------------------------------
local function RGAT_GetColoredTime(remaining)
    if remaining <= 0 then
        return "|cFF0000Alkosh: 0|r"
    elseif remaining <= 1 then
        return string.format("|cFF0000Alkosh: %.1f|r", remaining)
    elseif remaining <= 5 then
        return string.format("|cFFFF00Alkosh: %.1f|r", remaining)
    else
        return string.format("|c00FF00Alkosh: %.1f|r", remaining)
    end
end

----------------------------------------------------------------
-- Update Loop
----------------------------------------------------------------
function RGAT.OnUpdate(_, timeMs)
    if not RGAT.UILoaded then return end

    if RGAT.currentTimerEnd == 0 then
        RGAT_Label:SetText("|cFF0000Alkosh: 0|r")
        return
    end

    local remaining = RGAT.currentTimerEnd - GetFrameTimeSeconds()

    if remaining <= 0 then
        RGAT.currentTimerEnd = 0
        RGAT_Label:SetText("|cFF0000Alkosh: 0|r")
        return
    end

    RGAT_Label:SetText(RGAT_GetColoredTime(remaining))
end

----------------------------------------------------------------
-- Settings Menu (LAM)
----------------------------------------------------------------
local function RGAT_CreateSettingsMenu()
    local panelData = {
        type = "panel",
        name = "RockGrove Alkosh Timer",
        displayName = "RockGrove Alkosh Timer",
        author = "Phamo 1000",
        version = "1.0.3",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel("RGAT_Settings", panelData)

    local options = {
        {
            type = "slider",
            name = "UI X Position",
            min = -1200,
            max = 1200,
            step = 10,
            getFunc = function() return RGAT.SV.posX end,
            setFunc = function(value)
                RGAT.SV.posX = value
                RGAT_UpdateUIPosition()
            end,
        },
        {
            type = "slider",
            name = "UI Y Position",
            min = -800,
            max = 800,
            step = 10,
            getFunc = function() return RGAT.SV.posY end,
            setFunc = function(value)
                RGAT.SV.posY = value
                RGAT_UpdateUIPosition()
            end,
        },
        {
            type = "slider",
            name = "UI Scale",
            min = 1.0,
            max = 15.0,
            step = 0.5,
            getFunc = function() return RGAT.SV.scale end,
            setFunc = function(value)
                RGAT.SV.scale = value
                RGAT_UpdateUIScale()
            end,
        },
    }

    LAM:RegisterOptionControls("RGAT_Settings", options)
end

----------------------------------------------------------------
-- On Addon Loaded
----------------------------------------------------------------
function RGAT.OnAddOnLoaded(event, addonName)
    if addonName ~= "RockGroveAlkoshTimer" then return end

    -- Load saved variables
    RGAT.SV = ZO_SavedVars:NewAccountWide("RGAT_Saved", 1, nil, defaults)

    -- Use global LibAddonMenu2 (avoids LibStub issues on console)
    LAM = LibAddonMenu2

    -- Try to load UI
    RGAT_TryLoadUI()

    -- Register game events
    EVENT_MANAGER:RegisterForEvent("RGAT_Combat", EVENT_PLAYER_COMBAT_STATE, RGAT.OnCombatState)
    EVENT_MANAGER:RegisterForEvent("RGAT_Effect", EVENT_EFFECT_CHANGED, RGAT.OnEffectChanged)
    EVENT_MANAGER:RegisterForUpdate("RGAT_Update", 50, RGAT.OnUpdate)

    -- Build settings menu
    RGAT_CreateSettingsMenu()

    d("RockGroveAlkoshTimer Loaded (Settings Enabled)")
end

EVENT_MANAGER:RegisterForEvent("RGAT_Load", EVENT_ADD_ON_LOADED, RGAT.OnAddOnLoaded)
