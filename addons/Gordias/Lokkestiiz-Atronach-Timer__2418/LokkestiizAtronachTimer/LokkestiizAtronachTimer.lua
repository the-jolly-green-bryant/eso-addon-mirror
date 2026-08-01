-- LokkestiizAtronachTimer, by Gordias

LokkestiizAtronachTimer = {
	-- AddOn information
	name = "LokkestiizAtronachTimer",
	version = 1.01,
	variableVersion = 1.0,
	-- Listener variables
	lokkestiizFlyingFlag = false,
	labelColor = {197/255, 194/255, 158/255, 1},
	labelFont = "ZoFontWinH3",
	-- AddOn Variables
	debugFlag = true,
	sunspireZoneId = 1121,
	atronachTimer = 0,
	-- ID Definitions
	-- Lokkestiiz IDs
	icyPresenceId = 123103,
	-- Frost Attronach IDs
	frostAttroInitId = 114085,
	-- Default settings
	default = {
		offsetX = -100,
		offsetY = 200,
		labelColor = {197/255, 194/255, 158/255, 1},
		labelFont = "ZoFontWinH3",
	},
	-- LAM Panel Data
	panelData = {
    type = "panel",
    name = "Lokkestiiz Atronach Timer",
    displayName = "Lokkestiiz Atronach Timer",
    author = "Gordias",
    version = "1.01",
    registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
    registerForDefaults = true,	--boolean (optional) (will set all options controls back to default values)
	},
	-- LAM Options
	optionsTable = {
		[1] = {
	        type = "header",
	        name = "General Settings",
	        width = "full",	--or "half" (optional)
	    },
	    [2] = {
			type = "button",
			name = "Change UI Location",
			tooltip = "This button pops up the UI for you to move to a prefered location",
			func = function() LATWindow:SetHidden(false) end,
			width = "half",	--or "half" (optional)
		},
		[3] = {
			type = "button",
			name = "Set Default Location",
			tooltip = "This button moves the UI to the default location",
			func = function() 
				LokkestiizAtronachTimer.savedVariables.offsetX = LokkestiizAtronachTimer.default.offsetX
				LokkestiizAtronachTimer.savedVariables.offsetY = LokkestiizAtronachTimer.default.offsetY
				LATWindow:ClearAnchors()
				LATWindow:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, LokkestiizAtronachTimer.savedVariables.offsetX, LokkestiizAtronachTimer.savedVariables.offsetY) 
			end,
			width = "half",	--or "half" (optional)
		},
		[4] = {
	        type = "header",
	        name = "Label Settings",
	        width = "full",	--or "half" (optional)
	    },
		[5] = {
			type = "colorpicker",
			name = "Label Color",
			tooltip = "This option sets the label color",
			getFunc = function() return unpack(LokkestiizAtronachTimer.labelColor) end,	--(alpha is optional)
			setFunc = function(r,g,b,a) 
				LokkestiizAtronachTimer.labelColor = {r, g, b, a}
				LokkestiizAtronachTimer.savedVariables.labelColor = LokkestiizAtronachTimer.labelColor
				LATWindowLabel:SetColor(unpack(LokkestiizAtronachTimer.labelColor)) 
			end,	--(alpha is optional)
			width = "half",	--or "half" (optional)
			default = {r = 197/255, g = 194/255, b = 158/255, a = 1},
		},
		[6] = {
			type = "dropdown",
			name = "Label Font",
			tooltip = "This option sets the label font",
			choices = {"ZoFontWinH1",
				"ZoFontWinH2",
				"ZoFontWinH3",
				"ZoFontWinH4",
				"ZoFontWinH5"},
			getFunc = function() return LokkestiizAtronachTimer.labelFont end,
			setFunc = function(var) 
				LokkestiizAtronachTimer.labelFont = var 
				LokkestiizAtronachTimer.savedVariables.labelFont = LokkestiizAtronachTimer.labelFont
				LATWindowLabel:SetFont(LokkestiizAtronachTimer.labelFont)
				end,
			width = "half",	--or "half" (optional)
			default = "ZoFontWinH3",
		},
	},
}

-- Get reference to the LibAddonMenu-2.0 library table
local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")

-- This function is for debug purposes
function LokkestiizAtronachTimer.DebugText(text)
	if LokkestiizAtronachTimer.debugFlag then
		 d(text)
	end
end

-- This function saves the location of the GUI once it has been moved by the player
function LokkestiizAtronachTimer.SaveGUILocation()
	LokkestiizAtronachTimer.savedVariables.offsetX = LATWindow:GetRight() - GuiRoot:GetRight()
	LokkestiizAtronachTimer.savedVariables.offsetY = LATWindow:GetTop()
	LATWindow:ClearAnchors()
	LATWindow:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, LokkestiizAtronachTimer.savedVariables.offsetX, LokkestiizAtronachTimer.savedVariables.offsetY) 
	LATWindow:SetHidden(true)
end

-- This function updates the priority target based on the available information
function LokkestiizAtronachTimer.OnUpdateTimer()

	-- Initialize local variables
	local currentTime = GetGameTimeMilliseconds()
	local atronachSpawnTimeLeft = LokkestiizAtronachTimer.atronachTimer - currentTime
	local diffTime = (LokkestiizAtronachTimer.atronachTimer - currentTime) / 1000

	-- If the difference is less than zero, then the event will start soon
	if diffTime < 0 then diffTime = 0 end

	-- Convert time difference to string
	local stringDiffTime = string.format("%.0f", diffTime)

	-- Update UI Label
	LATWindowLabel:SetText("Next Spawn in " .. stringDiffTime .. "s")

end

-- Event handler function for the EVENT_COMBAT_EVENT of Frost Atronach Init
function LokkestiizAtronachTimer.OnAtronachInitEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, 
	targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

	-- Check if Frost Atronach Init Event started
	if result == ACTION_RESULT_EFFECT_GAINED and LokkestiizAtronachTimer.lokkestiizFlyingFlag == false then
		-- Set Atronach Timer
		LokkestiizAtronachTimer.atronachTimer = GetGameTimeMilliseconds() + 90000
	end

end

-- Event handler function for the EVENT_EFFECT_CHANGED of Icy Presence 
function LokkestiizAtronachTimer.OnLokkestiizIceEvent(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, 
	iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)

	-- Check if Lokkestiiz is on the ground or flying
	if changeType == EFFECT_RESULT_GAINED then
		-- Set Flying Flag to false
		LokkestiizAtronachTimer.lokkestiizFlyingFlag = false
		-- Set Atronach Timer
		LokkestiizAtronachTimer.atronachTimer = GetGameTimeMilliseconds() + 20000
		-- Show the UI
		LATWindow:SetHidden(false)
		-- Register Timer Update Event
		-- EVENT_MANAGER:RegisterForUpdate(LokkestiizAtronachTimer.name, 1000, LokkestiizAtronachTimer.OnUpdateTimer)
	elseif changeType == EFFECT_RESULT_FADED then
		-- Set Flying Flag to true
		LokkestiizAtronachTimer.lokkestiizFlyingFlag = true
		-- Hide the UI
		LATWindow:SetHidden(true)
		-- Clear UI Label
		LATWindowLabel:SetText("")
		-- Unregister Timer Update Event
		-- EVENT_MANAGER:UnregisterForUpdate(LokkestiizAtronachTimer.name)	
	end

end

-- Event handler function for the EVENT_PLAYER_ACTIVATED
function LokkestiizAtronachTimer.OnPlayerActivated(eventCode, initial)

	-- Check the current zone the player is in
	local currentZone = GetUnitZone("player")
	-- Sunspire (zoneId : 1121)
	local sunspireZone = GetZoneNameById(LokkestiizAtronachTimer.sunspireZoneId)
	-- Register combat state event if the zone is Sunspire
	if currentZone == sunspireZone then
		EVENT_MANAGER:RegisterForEvent(LokkestiizAtronachTimer.name, EVENT_PLAYER_COMBAT_STATE, LokkestiizAtronachTimer.OnCombatState)
	else
		EVENT_MANAGER:UnregisterForEvent(LokkestiizAtronachTimer.name, EVENT_PLAYER_COMBAT_STATE)
	end

end

-- Event handler function for the EVENT_PLAYER_COMBAT_STATE
function LokkestiizAtronachTimer.OnCombatState(eventCode, inCombat)

	-- Check if the fight is with Lokkestiiz
	local boss1Name = GetUnitName("boss1")

	-- Debug
	-- LokkestiizAtronachTimer.DebugText(zo_strformat("CmbStt: <<1>>, <<2>>, <<3>>", boss1Name, tostring(inCombat), tostring(LokkestiizAtronachTimer.olmsActive)))

	-- There is a bug here sometimes, if the player is far away from the group when the fight starts, the boss name is returned as empty string
	if inCombat == true and boss1Name == "Lokkestiiz" then
		-- Register Timer Update Event
		EVENT_MANAGER:RegisterForUpdate(LokkestiizAtronachTimer.name, 1000, LokkestiizAtronachTimer.OnUpdateTimer)
		-- Register Frost Atronach Init event to track atronach spawn
		EVENT_MANAGER:RegisterForEvent(LokkestiizAtronachTimer.name .. "FrostAtroInit", EVENT_COMBAT_EVENT, LokkestiizAtronachTimer.OnAtronachInitEvent)
		EVENT_MANAGER:AddFilterForEvent(LokkestiizAtronachTimer.name .. "FrostAtroInit", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, LokkestiizAtronachTimer.frostAttroInitId)
		-- Register Icy Presence event to track boss flight state	
		EVENT_MANAGER:RegisterForEvent(LokkestiizAtronachTimer.name .. "IcyPresence", EVENT_EFFECT_CHANGED, LokkestiizAtronachTimer.OnLokkestiizIceEvent)
		EVENT_MANAGER:AddFilterForEvent(LokkestiizAtronachTimer.name .. "IcyPresence", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, LokkestiizAtronachTimer.icyPresenceId)
	elseif inCombat == false then
		-- Unregister the events if the fight is "really" over
		zo_callLater(
			function() 
				if (not IsUnitInCombat("player")) then 
					-- Hide and Reset the GUI
					LATWindow:SetHidden(true)
					LATWindowLabel:SetText("Next spawn in 0s")
					-- Unregister Events
					EVENT_MANAGER:UnregisterForUpdate(LokkestiizAtronachTimer.name)
					EVENT_MANAGER:UnregisterForEvent(LokkestiizAtronachTimer.name .. "FrostAtroInit", EVENT_EFFECT_CHANGED)
					EVENT_MANAGER:UnregisterForEvent(LokkestiizAtronachTimer.name .. "IcyPresence", EVENT_EFFECT_CHANGED)
				end 
			end, 
			2500);
	end

end

-- Initialization function
function LokkestiizAtronachTimer:Initialize()

	-- Load saved variables
	LokkestiizAtronachTimer.savedVariables = ZO_SavedVars:NewAccountWide("LokkestiizAtronachTimerVars", LokkestiizAtronachTimer.variableVersion, nil, LokkestiizAtronachTimer.default)

	-- Assign saved variables
	LokkestiizAtronachTimer.labelColor = LokkestiizAtronachTimer.savedVariables.labelColor
	LokkestiizAtronachTimer.labelFont = LokkestiizAtronachTimer.savedVariables.labelFont

	-- Re-anchor the GUI to GuiRoot
	LATWindow:ClearAnchors()
	LATWindow:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, LokkestiizAtronachTimer.savedVariables.offsetX, LokkestiizAtronachTimer.savedVariables.offsetY)

	-- Apply GUI Settings
	LATWindowLabel:SetColor(unpack(LokkestiizAtronachTimer.labelColor))
	LATWindowLabel:SetFont(LokkestiizAtronachTimer.labelFont)

	-- Hide the GUI
	LATWindow:SetHidden(true)

	-- Initialize Settings
	LAM:RegisterAddonPanel("LokkestiizAtronachTimerOptions", LokkestiizAtronachTimer.panelData)
	LAM:RegisterOptionControls("LokkestiizAtronachTimerOptions", LokkestiizAtronachTimer.optionsTable)

	-- Register the event to check the zone the player is in
	EVENT_MANAGER:RegisterForEvent(LokkestiizAtronachTimer.name, EVENT_PLAYER_ACTIVATED, LokkestiizAtronachTimer.OnPlayerActivated)

	-- Unregister the initialization event
	EVENT_MANAGER:UnregisterForEvent(LokkestiizAtronachTimer.name, EVENT_ADD_ON_LOADED)

end

-- Event handler function for the "addon loaded" event
function LokkestiizAtronachTimer.OnAddOnLoaded(event, addonName)
	if addonName == LokkestiizAtronachTimer.name then
		LokkestiizAtronachTimer:Initialize()
	end
end
 
-- Register the initialization event
EVENT_MANAGER:RegisterForEvent(LokkestiizAtronachTimer.name, EVENT_ADD_ON_LOADED, LokkestiizAtronachTimer.OnAddOnLoaded)