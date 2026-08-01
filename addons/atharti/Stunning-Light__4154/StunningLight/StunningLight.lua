StunningLight = {}

local SL = StunningLight

local stunnedMode = false
local playerName = nil
local StunningLightAlert = nil
local alertActive = false

local defaultSavedVariables = {
    blurOnStun = true,
    enableSound = true,
    globalSound = "BATTLEGROUND_ROUND_RECAP_SCREEN_FINAL_WIN",
	hideGameUI = false,
	alertFontSize = 48,
	enableTextAlerts = true,
    
    trackFear = true,
    fearSoundEnabled = true,
    fearSound = "BATTLEGROUND_ROUND_RECAP_SCREEN_FINAL_WIN",
	fearBlurDuration = 1000,
    
    trackCharm = true,
    charmSoundEnabled = true,
    charmSound = "BATTLEGROUND_ROUND_RECAP_SCREEN_FINAL_WIN",
	charmBlurDuration = 1000,
}


local function HideAlert()
    if StunningLightAlert then
        StunningLightAlert:SetHidden(true)
        alertActive = false
        StunningLightAlert:SetHandler("OnUpdate", nil)
    end
end

local function ShowCustomAlert(msgText, color, duration, xOffset, yOffset)
    if not SL.SV.enableTextAlerts then return end
    HideAlert()
    
    if not StunningLightAlert then
        StunningLightAlert = WINDOW_MANAGER:CreateTopLevelWindow("StunningLightAlert")
        StunningLightAlert:SetDimensions(800, 150)
        
        local label = StunningLightAlert:CreateControl(nil, CT_LABEL)
        local fontString = string.format("$(BOLD_FONT)|$(KB_%d)|soft-shadow-thick", SL.SV.alertFontSize)
        label:SetFont(fontString)
        label:SetAnchor(CENTER, StunningLightAlert, CENTER, 0, 0)
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        StunningLightAlert.label = label
    end
    
    local screenWidth, screenHeight = GuiRoot:GetDimensions()
    local xPos = screenWidth / 2
    local yPos = screenHeight / 3
    
    StunningLightAlert:ClearAnchors()
    StunningLightAlert:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, xPos - 400, yPos - 75)
    
    StunningLightAlert.label:SetText("|c" .. (color or "FF0000") .. msgText .. "|r")
    StunningLightAlert:SetHidden(false)
    alertActive = true
    
    local startTime = GetFrameTimeSeconds()
    StunningLightAlert:SetHandler("OnUpdate", function()
        if not alertActive then return end
        if (GetFrameTimeSeconds() - startTime) * 1000 >= (duration or 1000) then
            HideAlert()
        end
    end)
end

function SL.ShowTempBlurWithMessage(msgText, soundName, color, duration)
    if SL.SV.hideGameUI then
        ToggleShowIngameGui()
    end
    
    if SL.SV.blurOnStun then
        SetFullscreenEffect(FULLSCREEN_EFFECT_UNIFORM_BLUR)
    end
    
    if soundName then
        PlaySound(SOUNDS[soundName])
    end
    
    ShowCustomAlert(msgText, color, duration, 0, 0)
    
    zo_callLater(function()
        if SL.SV.blurOnStun then
            SetFullscreenEffect(FULLSCREEN_EFFECT_NONE)
        end
        
        if SL.SV.hideGameUI then
            ToggleShowIngameGui()
        end
    end, duration)
end

function SL.NormalizeName(name)
    if not name then return nil end
    return name:gsub("%^[A-Za-z]+$", "")
end

function SL.SetStunState(stunned)
    if stunned then
        if not stunnedMode and IsUnitInCombat("player") then
            stunnedMode = true
            
            if SL.SV.hideGameUI then
                ToggleShowIngameGui()
            end
            
            if SL.SV.blurOnStun then
                SetFullscreenEffect(FULLSCREEN_EFFECT_UNIFORM_BLUR)
            end
            
            if SL.SV.enableSound then
                PlaySound(SOUNDS[SL.SV.globalSound])
            end
        end
    else
        if stunnedMode then
            if SL.SV.blurOnStun then
                SetFullscreenEffect(FULLSCREEN_EFFECT_NONE)
            end
            
            if SL.SV.hideGameUI then
                ToggleShowIngameGui()
            end
            
            stunnedMode = false
        end
    end
end

function SL.StunHandler(_, stunned)
    SL.SetStunState(stunned)
end

function SL.PlayerActivatedHandler()
    HideAlert()
    if stunnedMode then
        SetFullscreenEffect(FULLSCREEN_EFFECT_NONE)
        if SL.SV.hideGameUI then
            ToggleShowIngameGui()
        end
        stunnedMode = false
    end
end

function SL.OnInitPlayerActivated()
    playerName = GetUnitName("player")
    
    EVENT_MANAGER:UnregisterForEvent("StunningLight", EVENT_PLAYER_ACTIVATED)
    
    EVENT_MANAGER:RegisterForEvent("StunningLight", EVENT_PLAYER_ACTIVATED, SL.PlayerActivatedHandler)
end

local function CombatEventHandler(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if isError then return end
    
    local ACTION_RESULT_FEARED = 2320
    local ACTION_RESULT_CHARMED = 3510
    
    local normalizedTarget = SL.NormalizeName(targetName)
    
    if normalizedTarget == playerName then
        if result == ACTION_RESULT_FEARED and SL.SV.trackFear then
            local sound = nil
            if SL.SV.fearSoundEnabled then
                sound = SL.SV.fearSound
            elseif SL.SV.enableSound then
                sound = SL.SV.globalSound
            end
            SL.ShowTempBlurWithMessage("FEARED!", sound, "FF0000", SL.SV.fearBlurDuration)
            
        elseif result == ACTION_RESULT_CHARMED and SL.SV.trackCharm then
            local sound = nil
            if SL.SV.charmSoundEnabled then
                sound = SL.SV.charmSound
            elseif SL.SV.enableSound then
                sound = SL.SV.globalSound
            end
            SL.ShowTempBlurWithMessage("CHARMED!", sound, "FF0000", SL.SV.charmBlurDuration)
        end
    end
end

local function OnAddonLoaded(_, addonName)
    if addonName == "StunningLight" then
	
	    SL.SV = ZO_SavedVars:NewAccountWide("StunningLight_SV", 1, nil, defaultSavedVariables)
	
	    SL.RegisterLAMPanel()
		
		
        EVENT_MANAGER:UnregisterForEvent("StunningLight", EVENT_ADD_ON_LOADED)

        EVENT_MANAGER:RegisterForEvent("StunningLight", EVENT_PLAYER_STUNNED_STATE_CHANGED, SL.StunHandler)
        EVENT_MANAGER:RegisterForEvent("StunningLight", EVENT_PLAYER_ACTIVATED, SL.OnInitPlayerActivated)
        
        EVENT_MANAGER:RegisterForEvent("StunningLight", EVENT_COMBAT_EVENT, CombatEventHandler)
    end
end

EVENT_MANAGER:RegisterForEvent("StunningLight", EVENT_ADD_ON_LOADED, OnAddonLoaded)