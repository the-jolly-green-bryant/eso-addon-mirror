WerewolfTrackersAndQOL = WerewolfTrackersAndQOL or {}
local WTQ = WerewolfTrackersAndQOL


-- local api & variables 

local EVENT_MANAGER = EVENT_MANAGER
local GetFrameTimeSeconds = GetFrameTimeSeconds
local IsUnitDead = IsUnitDead
local GetUnitPower = GetUnitPower
local IsPlayerInWerewolfForm = IsPlayerInWerewolfForm
local IsUnitInCombat = IsUnitInCombat
local GetNumBuffs = GetNumBuffs
local GetUnitBuffInfo = GetUnitBuffInfo
local GetSlotBoundId = GetSlotBoundId
local IsReticleHidden = IsReticleHidden
local string_format = string.format
local string_find = string.find
local d = d
local debug_traceback = debug.traceback

local EVENT_ADD_ON_LOADED = EVENT_ADD_ON_LOADED
local EVENT_EFFECT_CHANGED = EVENT_EFFECT_CHANGED
local EVENT_POWER_UPDATE = EVENT_POWER_UPDATE
local EVENT_WEREWOLF_STATE_CHANGED = EVENT_WEREWOLF_STATE_CHANGED
local EVENT_PLAYER_DEAD = EVENT_PLAYER_DEAD
local EVENT_PLAYER_ALIVE = EVENT_PLAYER_ALIVE
local EVENT_RETICLE_HIDDEN_UPDATE = EVENT_RETICLE_HIDDEN_UPDATE
local EFFECT_RESULT_GAINED = EFFECT_RESULT_GAINED
local EFFECT_RESULT_UPDATED = EFFECT_RESULT_UPDATED
local EFFECT_RESULT_FADED = EFFECT_RESULT_FADED
local REGISTER_FILTER_UNIT_TAG = REGISTER_FILTER_UNIT_TAG
local REGISTER_FILTER_POWER_TYPE = REGISTER_FILTER_POWER_TYPE
local REGISTER_FILTER_ABILITY_ID = REGISTER_FILTER_ABILITY_ID
local POWERTYPE_WEREWOLF = POWERTYPE_WEREWOLF
local TOPLEFT = TOPLEFT

local ADDON_NAME = "WerewolfTrackersAndQOL"

-- need to make sure this covers all instances of ff being activated, maybe get a buddy to help
local FEEDING_FRENZY_ABILITY_IDS = {
    [133026] = true,
    [133027] = true,
    [133028] = true,
    [133029] = true,
    [135384] = true,
    -- pretty sure this is the one for the version you get from ferocious roar which is the most important
    [131353] = true,
}

local WEREWOLF_ULTIMATE_IDS = {
    [32455] = true,
    [39075] = true,
    [39076] = true,
}

WTQ.defaults = {
    isLocked = true,
    scaleFF = 0.95,
    scaleFury = 0.95,
    enableFF = true,
    -- maybe I should change these to FFx and FFy? 
    x = 500,
    y = 500,
    enableFury = true,
    furyX = 560,
    furyY = 500,
    preventAccidentalRevert = true,
    enableDebug = false,
}

local activeBuff = nil
local exitTimerStart = nil
local isHooked = false

local FFContainer, FFContainerMovablePreview, FFContainerTimerBg, FFContainerTimer, FFContainerIcon
local FuryContainer, FuryContainerMovablePreview, FuryContainerTimerBg, FuryContainerTimer, FuryContainerIcon


-- ui stuff

local function ToggleNativeFuryTracker(hide)
    if ZO_PlayerAttributeWerewolf then
        ZO_PlayerAttributeWerewolf:SetHidden(hide)
    end
end

local function ApplyVisibilityRules()
    if not WTQ.db.isLocked then
        local showPreview = WTQ.db.enableFF
        FFContainer:SetHidden(not showPreview)
        FFContainerMovablePreview:SetHidden(not showPreview)
        FFContainerTimerBg:SetHidden(not showPreview)
        FFContainerIcon:SetTexture("/esoui/art/icons/ability_werewolf_004.dds")
        FFContainerTimer:SetText("5")
        FFContainerTimer:SetColor(0.2, 1, 0.2, 1)
        return
    end

    FFContainerMovablePreview:SetHidden(true)
    local isVisible = WTQ.db.enableFF and (activeBuff ~= nil or exitTimerStart ~= nil) and not IsUnitDead("player") and not IsReticleHidden()
    
    FFContainer:SetHidden(not isVisible)
    FFContainerTimerBg:SetHidden(not isVisible)
end

local function ApplyFuryVisibilityRules()
    local isWW = IsPlayerInWerewolfForm()

    if not WTQ.db.isLocked then
        local showPreview = WTQ.db.enableFury
        FuryContainer:SetHidden(not showPreview)
        FuryContainerMovablePreview:SetHidden(not showPreview)
        FuryContainerTimerBg:SetHidden(not showPreview)
        FuryContainerIcon:SetTexture("/esoui/art/icons/ability_werewolf_001.dds")
        FuryContainerTimer:SetText("Max")
        FuryContainerTimer:SetColor(1, 0.1, 0.1, 1)

        ToggleNativeFuryTracker(WTQ.db.enableFury)
        return
    end

    FuryContainerMovablePreview:SetHidden(true)
    
    local powerValue = GetUnitPower("player", POWERTYPE_WEREWOLF)
    local isVisible = WTQ.db.enableFury and isWW and (powerValue > 0) and not IsUnitDead("player") and not IsReticleHidden()
    
    FuryContainer:SetHidden(not isVisible)
    FuryContainerTimerBg:SetHidden(not isVisible)
    
    if WTQ.db.enableFury and isWW and not IsReticleHidden() then
        ToggleNativeFuryTracker(true)
    else
        ToggleNativeFuryTracker(false)
    end
end


-- timers

local function OnUpdate()
    local currentTime = GetFrameTimeSeconds()

    if activeBuff then
        local remaining = activeBuff.endTime - currentTime
        if remaining > 0 then
            FFContainerTimer:SetText(string_format("%d", math.ceil(remaining)))
            if remaining <= 5.0 then
                FFContainerTimer:SetColor(1, 0.9, 0.2, 1)
            else
                FFContainerTimer:SetColor(0.2, 1, 0.2, 1)
            end
        else
            activeBuff = nil
            exitTimerStart = currentTime
            FFContainerTimer:SetText("0")
            FFContainerTimer:SetColor(1, 0.1, 0.1, 1)
        end
    elseif exitTimerStart then
        if currentTime - exitTimerStart >= 2.0 then
            exitTimerStart = nil
            EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "Update")
            ApplyVisibilityRules()
        end
    end
end
WTQ.OnUpdate = OnUpdate

local function SetUpdateLoop(active)
    if active then
        EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "Update", 100, OnUpdate)
    else
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "Update")
    end
end

local function OnMoveStop(control, xKey, yKey)
    WTQ.db[xKey] = control:GetLeft()
    WTQ.db[yKey] = control:GetTop()
end
WTQ.OnMoveStop = OnMoveStop

-- uses 16
local function OnEffectChanged(_, changeType, _, effectName, _, _, endTime, _, iconName, _, _, _, _, _, _, abilityId)
    if not FEEDING_FRENZY_ABILITY_IDS[abilityId] then return end

    if WTQ.db.enableDebug then
        d("[WTQ Debug] Buff Event: Name=" .. tostring(effectName) .. " | ID=" .. tostring(abilityId) .. " | ChangeType=" .. tostring(changeType))
    end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        activeBuff = { endTime = endTime }
        exitTimerStart = nil
        if iconName and iconName ~= "" then
            FFContainerIcon:SetTexture(iconName)
        end
        SetUpdateLoop(true)
    elseif changeType == EFFECT_RESULT_FADED then
        if activeBuff then 
            activeBuff.endTime = GetFrameTimeSeconds() 
        end
    end
    ApplyVisibilityRules()
end

local function CheckInitialBuffs()
    local numBuffs = GetNumBuffs("player")
    for i = 1, numBuffs do
        local buffName, _, endTime, _, _, iconPath, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if FEEDING_FRENZY_ABILITY_IDS[abilityId] or (buffName and string_find(buffName, "Feeding Frenzy")) then
            activeBuff = { endTime = endTime }
            exitTimerStart = nil
            if iconPath then
                FFContainerIcon:SetTexture(iconPath)
            end
            SetUpdateLoop(true)
            ApplyVisibilityRules()
            break
        end
    end
end

local function UpdateFuryVisuals(powerValue, powerMax)
    if powerMax > 0 then
        FuryContainerTimer:SetText(tostring(powerValue))
        if powerValue >= powerMax then
            FuryContainerTimer:SetColor(1, 0.1, 0.1, 1)
        else
            FuryContainerTimer:SetColor(0.2, 1, 0.2, 1)
        end
    else
        FuryContainerTimer:SetText("0")
        FuryContainerTimer:SetColor(0.2, 1, 0.2, 1)
    end
    ApplyFuryVisibilityRules()
end

local function OnPowerUpdate(_, _, _, powerType, powerValue, powerMax)
    --d("power update fired")
    if powerType == POWERTYPE_WEREWOLF then
        UpdateFuryVisuals(powerValue, powerMax)
    end
end

local function OnPlayerStateChanged()
    ApplyVisibilityRules()
    ApplyFuryVisibilityRules()
end

local function OnReticleHiddenUpdate()
    ApplyVisibilityRules()
    ApplyFuryVisibilityRules()
end


-- blocking reverting in combat
-- gamepad stuff right? need to test further

local function InterceptActionSlotUse()
    if not WTQ.db.preventAccidentalRevert then 
        return false 
    end

    if not (IsPlayerInWerewolfForm() and IsUnitInCombat("player")) then
        return false
    end

    local boundAbilityId = GetSlotBoundId(8)
    if not WEREWOLF_ULTIMATE_IDS[boundAbilityId] then
        return false
    end

    local trace = debug_traceback()
    if string_find(trace, "ACTION_BUTTON_8") or string_find(trace, "GAMEPAD_ACTION_BUTTON_8") then
        if WTQ.db.enableDebug then
            d("[WTQ Debug] Blocked accidental werewolf revert in combat!")
        end
        return true
    end

    return false
end

local function HookSystemCalls()
    if not isHooked then
        ZO_PreHook("ZO_ActionBar_CanUseActionSlots", InterceptActionSlotUse)
        
        if ZO_PlayerAttributeWerewolf then
            ZO_PreHook(ZO_PlayerAttributeWerewolf, "SetHidden", function(_, hidden)
                if not hidden and WTQ.db and WTQ.db.enableFury and IsPlayerInWerewolfForm() and not IsReticleHidden() then
                    return true
                end
            end)
        end
        
        isHooked = true
    end
end


-- registrations

local function UpdateEventRegistrations()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "Buff", EVENT_EFFECT_CHANGED)
    
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "Fury", EVENT_POWER_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "WWState", EVENT_WEREWOLF_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "Dead", EVENT_PLAYER_DEAD)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "Alive", EVENT_PLAYER_ALIVE)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "Reticle", EVENT_RETICLE_HIDDEN_UPDATE)

    if WTQ.db.enableFF or WTQ.db.enableDebug then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Buff", EVENT_EFFECT_CHANGED, OnEffectChanged)
        EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "Buff", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
        
        if WTQ.db.enableFF then
            CheckInitialBuffs()
        end
    else
        activeBuff = nil
        exitTimerStart = nil
        SetUpdateLoop(false)
    end

    if WTQ.db.enableFury then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Fury", EVENT_POWER_UPDATE, OnPowerUpdate)
        EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "Fury", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
        EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "Fury", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_WEREWOLF)
        
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "WWState", EVENT_WEREWOLF_STATE_CHANGED, ApplyFuryVisibilityRules)
        
        local current, max = GetUnitPower("player", POWERTYPE_WEREWOLF)
        UpdateFuryVisuals(current, max)
    else
        ToggleNativeFuryTracker(false)
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Dead", EVENT_PLAYER_DEAD, OnPlayerStateChanged)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Alive", EVENT_PLAYER_ALIVE, OnPlayerStateChanged)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Reticle", EVENT_RETICLE_HIDDEN_UPDATE, OnReticleHiddenUpdate)

    ApplyVisibilityRules()
    ApplyFuryVisibilityRules()
end


-- settings menu

local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local optionsData = {
        {
            type = "checkbox",
            name = "Enable Feeding Frenzy Tracker",
            getFunc = function() return WTQ.db.enableFF end,
            setFunc = function(value) 
                WTQ.db.enableFF = value 
                UpdateEventRegistrations()
            end,
        },
        {
            type = "checkbox",
            name = "Enable Fury Tracker",
            getFunc = function() return WTQ.db.enableFury end,
            setFunc = function(value) 
                WTQ.db.enableFury = value 
                UpdateEventRegistrations()
            end,
        },
        {
            type = "checkbox",
            name = "Prevent Accidental Revert in Combat",
            getFunc = function() return WTQ.db.preventAccidentalRevert end,
            setFunc = function(value) 
                WTQ.db.preventAccidentalRevert = value
            end,
        },
        {
            type = "checkbox",
            name = "Lock UI Elements",
            getFunc = function() return WTQ.db.isLocked end,
            setFunc = function(value) 
                WTQ.db.isLocked = value 
                FFContainer:SetMovable(not value)
                FFContainer:SetMouseEnabled(not value)
                FuryContainer:SetMovable(not value)
                FuryContainer:SetMouseEnabled(not value)
                ApplyVisibilityRules()
                ApplyFuryVisibilityRules()
            end,
        },
        {
            type = "checkbox",
            name = "Enable Chat Debug Mode",
            getFunc = function() return WTQ.db.enableDebug end,
            setFunc = function(value) 
                WTQ.db.enableDebug = value 
                UpdateEventRegistrations()
            end,
        },
        {
            type = "slider",
            name = "Feeding Frenzy Icon Scale",
            min = 0.5, max = 2.0, step = 0.05,
            decimals = 2,
            getFunc = function() return WTQ.db.scaleFF or 0.95 end,
            setFunc = function(value) 
                WTQ.db.scaleFF = value 
                FFContainer:SetScale(value)
            end,
        },
        {
            type = "slider",
            name = "Fury Icon Scale",
            min = 0.5, max = 2.0, step = 0.05,
            decimals = 2,
            getFunc = function() return WTQ.db.scaleFury or 0.95 end,
            setFunc = function(value) 
                WTQ.db.scaleFury = value 
                FuryContainer:SetScale(value)
            end,
        },
    }
    
	-- UPDATE THIS IN FUTURE VERSIONS
    LAM:RegisterAddonPanel(ADDON_NAME .. "SettingsMenu", {type = "panel", name = "Werewolf Trackers and QOL", author = "Grizzly_Khan", version = "1.1.1"})
    LAM:RegisterOptionControls(ADDON_NAME .. "SettingsMenu", optionsData)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    
    WTQ.db = ZO_SavedVars:NewCharacterIdSettings("WerewolfTrackersAndQOLSV", 1, nil, WTQ.defaults)
    
    FFContainer = WerewolfTrackersAndQOL_FFContainer
    FFContainerMovablePreview = WerewolfTrackersAndQOL_FFContainerMovablePreview
    FFContainerTimerBg = WerewolfTrackersAndQOL_FFContainerTimerBg
    FFContainerTimer = WerewolfTrackersAndQOL_FFContainerTimer
    FFContainerIcon = WerewolfTrackersAndQOL_FFContainerIcon
    
    FuryContainer = WerewolfTrackersAndQOL_FuryContainer
    FuryContainerMovablePreview = WerewolfTrackersAndQOL_FuryContainerMovablePreview
    FuryContainerTimerBg = WerewolfTrackersAndQOL_FuryContainerTimerBg
    FuryContainerTimer = WerewolfTrackersAndQOL_FuryContainerTimer
    FuryContainerIcon = WerewolfTrackersAndQOL_FuryContainerIcon
    
    local isMovable = not WTQ.db.isLocked
    FFContainer:SetScale(WTQ.db.scaleFF or 0.95)
    FFContainer:SetMovable(isMovable)
    FFContainer:SetMouseEnabled(isMovable)
    FFContainer:ClearAnchors()
    FFContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, WTQ.db.x, WTQ.db.y)
    FFContainerIcon:SetTexture("/esoui/art/icons/ability_werewolf_004.dds")

    FuryContainer:SetScale(WTQ.db.scaleFury or 0.95)
    FuryContainer:SetMovable(isMovable)
    FuryContainer:SetMouseEnabled(isMovable)
    FuryContainer:ClearAnchors()
    FuryContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, WTQ.db.furyX, WTQ.db.furyY)
    FuryContainerIcon:SetTexture("/esoui/art/icons/ability_werewolf_001.dds")

    CreateSettingsMenu()
    HookSystemCalls()
    UpdateEventRegistrations()
end)