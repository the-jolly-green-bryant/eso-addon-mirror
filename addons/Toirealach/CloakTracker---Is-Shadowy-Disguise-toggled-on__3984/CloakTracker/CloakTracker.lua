-------------------------------------------------------------------------------
-- CloakTracker
-------------------------------------------------------------------------------
CloakTracker = CloakTracker or {}

CloakTracker.name = "CloakTracker"
CloakTracker.version = "1.0.8"
CloakTracker.displayName = "|cFFFFFFCloak Tracker|r"
CloakTracker.author = "|c00a313Teebow Ganx|r"
CloakTracker.website = "https://www.youtube.com/channel/UCqE9Vi36WzTJBBbo9-G40bg"
CloakTracker.donation = "https://www.youtube.com/channel/UCqE9Vi36WzTJBBbo9-G40bg"

CloakTracker.SavedVariablesName = "CloakTracker_SavedVariables"
CloakTracker.savedVarsVersion = 1

--Locals -------------------------------------------------------------

local L = CloakTracker.Localization


-- Saved Variables --------------------------------------------------------------

local savedVariables = nil

local whiteColorHex = "FFFFFF"	-- white
local redColorHex = "FF0000"	-- bright red
local yellowColorHex = "FFFF00" -- yellow
local function colorizeStr(str, color)
	return string.format("|c%s%s|r", color, str)
end

local defaults = {
	window = { anchorPoint = 6, xOff = 1140, yOff = -580 },
}

local debugWindow = false

function CloakTracker.WindowUpdate()

end

local MAIN_CONTROL = CloakTrackerWindow
local COOLDOWN_CONTROL = MAIN_CONTROL:GetNamedChild('Cooldown')
local ICON_CONTROL = MAIN_CONTROL:GetNamedChild('Icon')
local LEADINGEDGE_CONTROL = MAIN_CONTROL:GetNamedChild('LeadingEdge')
local GLOW_CONTROL = MAIN_CONTROL:GetNamedChild('Glow')
local LABEL_CONTROL = MAIN_CONTROL:GetNamedChild('Label')

function CloakTracker:RestoreWindowPosition()

	MAIN_CONTROL:ClearAnchors()
	MAIN_CONTROL:SetAnchor(savedVariables.window.anchorPoint,
  									GuiRoot, nil,
  									savedVariables.window.xOff,
  									savedVariables.window.yOff)
end

function CloakTracker.ShowWindow()
	CloakTracker:RestoreWindowPosition()
	CloakTrackerWindow:SetHidden(false)
end

function CloakTracker.HideWindow()
	CloakTrackerWindow:SetHidden(true)
end

function CloakTracker.Window_OnMouseDoubleClick()
	if debugWindow ~= true then return end
	-- Report the Windows' current position.
	local theStr = string.format("CloakTracker.Window_OnMouseDoubleClick: anchorPoint = %s, xOff = %d, yOff = %d", savedVariables.window.anchorPoint, savedVariables.window.xOff, savedVariables.window.yOff)
	d(theStr)
end

function CloakTracker.Window_OnMoveStop()

	if debugWindow == true then 
		zo_callLater(function() d("CloakTracker.Window_OnMoveStop()") end, 300)
	end

	-- Control:GetAnchor(number anchorIndex)
	-- Returns: boolean isValidAnchor, number anchorPoint, object relativeTo, number relativePoint, 
	--					number offsetX, number offsetY, number AnchorConstrains anchorConstrains
		
	local isValidAnchor, anchorPoint, relativeTo, relativePoint, xOff, yOff, anchorConstrains
						= CloakTrackerWindow:GetAnchor()
	
	savedVariables.window.anchorPoint = anchorPoint
	savedVariables.window.xOff = xOff
	savedVariables.window.yOff = yOff
end

local function SendLoadedString()
	local loadedStr = "%s %s Loaded"
	loadedStr = string.format(loadedStr, CloakTracker.displayName, CloakTracker.version)
	zo_callLater(function() d(loadedStr) end, 300)
end

local cloakAbilityID = 25380

-- ABILITY: name = Shadowy Disguise, id = 25380, icon = /esoui/art/icons/ability_nightblade_004_a.dds
-- EVENT_EFFECT_CHANGED : Shadowy Disguise (25380): EFFECT_RESULT_GAINED
-- EVENT_EFFECT_CHANGED : Shadowy Disguise (25380): EFFECT_RESULT_FADED

-- EVENT_EFFECT_CHANGED (eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
local function OnEffectChanged(eventCode, changeType, effectSlot, effectName,  unitTag, beginTime, endTime, stackCount,  _,  _,  effectType, _,  _,  unitName, unitId, abilityId, sourceType)

	if abilityId ~= cloakAbilityID then return end

	if changeType == EFFECT_RESULT_GAINED then 
		CloakTrackerWindow:SetHidden(false)
	elseif changeType == EFFECT_RESULT_FADED then
		CloakTrackerWindow:SetHidden(true)
	end

end

local function CloakIsActive()

	for i = 0, GetNumBuffs('player') do
		local buffName, 					--
			timeStarted, 				--
			timeEnding, 				--
			buffSlot, 					--
			stackCount, 				--
			iconFilename,				--
			buffType, 					--
			effectType, 				--
			abilityType, 				--
			statusEffectType, 	--
			abilityId, 					--
			canClickOff, 				--
			castByPlayer 				--
				= GetUnitBuffInfo('player', i)
		
		if abilityId == cloakAbilityID then return true end
	end
	return false
end 

local function OnLoad(eventCode, addOnName)

	if(addOnName ~= CloakTracker.name) then return end
	
	savedVariables = ZO_SavedVars:NewCharacterIdSettings(CloakTracker.SavedVariablesName, CloakTracker.savedVarsVersion, nil, defaults)

	EVENT_MANAGER:RegisterForEvent(CloakTracker.name, EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(CloakTracker.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

	CloakTracker:RestoreWindowPosition()

	-- Make cloak icon window visible if cloak is currently active. Necessary when player does a /reloadui
	if CloakIsActive() == true then CloakTrackerWindow:SetHidden(false) end

	SendLoadedString()

	-- Be a good citizen and unregister for load events now
	EVENT_MANAGER:UnregisterForEvent(CloakTracker.name, EVENT_ADD_ON_LOADED)
end

-- Init
EVENT_MANAGER:RegisterForEvent(CloakTracker.name, EVENT_ADD_ON_LOADED, OnLoad)