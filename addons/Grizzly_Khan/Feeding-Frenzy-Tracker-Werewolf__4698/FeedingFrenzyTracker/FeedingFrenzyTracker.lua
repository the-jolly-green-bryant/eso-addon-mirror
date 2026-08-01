FeedingFrenzyTracker = FeedingFrenzyTracker or {}
local FFT = FeedingFrenzyTracker

local EVENT_MANAGER = EVENT_MANAGER
local GetFrameTimeSeconds = GetFrameTimeSeconds
local IsUnitDead = IsUnitDead
local string_format = string.format
local string_lower = string.lower
local string_find = string.find
local REGISTER_FILTER_UNIT_TAG = REGISTER_FILTER_UNIT_TAG
local EFFECT_RESULT_GAINED = EFFECT_RESULT_GAINED
local EFFECT_RESULT_UPDATED = EFFECT_RESULT_UPDATED
local EFFECT_RESULT_FADED = EFFECT_RESULT_FADED
local TOPLEFT = TOPLEFT
local GuiRoot = GuiRoot

FFT.defaults = {
    isLocked = false,
    x = 500,
    y = 500,
    scale = 1.0,
}

local activeBuff = nil
local exitTimerStart = nil
local ApplyVisibilityRules

local function SetUpdateLoop(active)
    if active then
        EVENT_MANAGER:RegisterForUpdate("FFTrackerUpdate", 100, FFT.OnUpdate)
    else
        EVENT_MANAGER:UnregisterForUpdate("FFTrackerUpdate")
    end
end

ApplyVisibilityRules = function()
    if not FFT.db then return end
    
    FFTrackerContainer:SetScale(FFT.db.scale)

    if not FFT.db.isLocked then
        FFTrackerContainer:SetHidden(false)
        FFTrackerContainerMovablePreview:SetHidden(false)
        FFTrackerContainerTimerBg:SetHidden(false)
        FFTrackerContainerTimer:SetText("5.0")
        FFTrackerContainerTimer:SetColor(0.2, 1, 0.2, 1) 
        FFTrackerContainerIcon:SetTexture("/esoui/art/icons/ability_werewolf_004.dds")
        return
    end

    FFTrackerContainerMovablePreview:SetHidden(true)
    local isVisible = (activeBuff ~= nil or exitTimerStart ~= nil) and not IsUnitDead("player")
    
    FFTrackerContainer:SetHidden(not isVisible)
    FFTrackerContainerTimerBg:SetHidden(not isVisible)
end

FFT.OnUpdate = function()
    local currentTime = GetFrameTimeSeconds()

    if activeBuff then
        local remaining = activeBuff.endTime - currentTime
        if remaining > 0 then
            FFTrackerContainerTimer:SetText(string_format("%.1f", remaining))
            FFTrackerContainerTimer:SetColor(remaining <= 5.0 and 1 or 0.2, remaining <= 5.0 and 0.9 or 1, 0.2, 1)
        else
            activeBuff = nil
            exitTimerStart = currentTime
            FFTrackerContainerTimer:SetText("0.0")
            FFTrackerContainerTimer:SetColor(1, 0.1, 0.1, 1)
        end
    elseif exitTimerStart then
        if currentTime - exitTimerStart >= 2.0 then
            exitTimerStart = nil
            SetUpdateLoop(false)
            ApplyVisibilityRules()
        end
    end
end

FeedingFrenzyTracker.OnMoveStop = function()
    FFT.db.x = FFTrackerContainer:GetLeft()
    FFT.db.y = FFTrackerContainer:GetTop()
end

local function OnEffectChanged(_, changeType, _, effectName, _, _, endTime, _, iconName, ...)
    if string_find(string_lower(effectName), "feeding frenzy") then
        if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
            activeBuff = { endTime = endTime }
            exitTimerStart = nil 
            FFTrackerContainerIcon:SetTexture(iconName)
            SetUpdateLoop(true)
        elseif changeType == EFFECT_RESULT_FADED then
            if activeBuff then activeBuff.endTime = GetFrameTimeSeconds() end
        end
        ApplyVisibilityRules()
    end
end

local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local optionsData = {
        {
            type = "checkbox",
            name = "Lock UI Element",
            getFunc = function() return FFT.db.isLocked end,
            setFunc = function(value) 
                FFT.db.isLocked = value 
                FFTrackerContainer:SetMovable(not value)
                FFTrackerContainer:SetMouseEnabled(not value)
                ApplyVisibilityRules()
            end,
        },
        {
            type = "slider",
            name = "Icon Scale",
            min = 0.5, max = 2.0, step = 0.05,
            decimals = 2,
            getFunc = function() return FFT.db.scale end,
            setFunc = function(value) 
                FFT.db.scale = value 
                FFTrackerContainer:SetScale(value)
            end,
        },
    }
    
    LAM:RegisterAddonPanel("FeedingFrenzyTrackerSettingsMenu", {type = "panel", name = "Feeding Frenzy Tracker", author = "Grizzly_Khan", version = "1.0.0"})
    LAM:RegisterOptionControls("FeedingFrenzyTrackerSettingsMenu", optionsData)
end

EVENT_MANAGER:RegisterForEvent("FeedingFrenzyTracker", EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= "FeedingFrenzyTracker" then return end
    
    FFT.db = ZO_SavedVars:NewCharacterIdSettings("FeedingFrenzyTrackerSV", 1, nil, FFT.defaults)
    
    CreateSettingsMenu()
    FFTrackerContainer:ClearAnchors()
    FFTrackerContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, FFT.db.x, FFT.db.y)
    
    ApplyVisibilityRules()
    
    EVENT_MANAGER:RegisterForEvent("FeedingFrenzyTrackerBuff", EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent("FeedingFrenzyTrackerBuff", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
end)