------------------
-- Palantir Hud namespace
PalantirHUD = {}

--
local PH = PalantirHUD
PH.name  = "Palantir"
PH.version = "1.0"
PH.delayBuffer = {}

-- Saved variables options
PH.savedVarsName = 'PalantirSV'
PH.savedVarsVer  = 1

ZO_CreateStringId("SI_BINDING_NAME_PALANTIR_TOGGLE_ON_OFF", "Toggle Palantir visibility")

-- default settings
PH.defaults = {
	oocAlpha = 0.15,
	icAlpha  = 0.5,
}
PH.savedVars = nil

-- Bars container
PH.tlw = nil
PH.hidden = false
PH.tlwAnimation = nil
PH.powerBars = {
	player = {},
	controlledsiege = {},
}

-- RoundHud Initialization
function PH.OnAddOnLoaded(eventCode, addonName)
	-- Only initialize our own addon
	if PH.name ~= addonName then return end
	-- Once we know it's ours, lets unregister the event listener
	EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)

	-- Load saved variables
	PH.LoadSavedVars()

	-- TODO:
	PH.tlw = PH.Chain( WINDOW_MANAGER:CreateTopLevelWindow() )
		:SetClampedToScreen( true )
		:SetHidden( true )
		:SetAnchor(CENTER)
	.__END
	
	PH.tlwAnimation = ZO_AlphaAnimation:New( PH.tlw )
	PH.SetFadeLevels()

	PH.leftBar = PH.BarContainer:New(PH.tlw, 0)
	PH.rightBar = PH.BarContainer:New(PH.tlw, 1)

	-- order matters !!!
	PH.powerBars.player[POWERTYPE_HEALTH] = PH.RoundBar:New( PH.leftBar )
	PH.powerBars.player[POWERTYPE_HEALTH]:CreateShield()
	PH.powerBars.player[POWERTYPE_HEALTH]:CreateText()
	PH.powerBars.player[POWERTYPE_HEALTH]:SetColor(0.80, 0.10, 0.10)

	PH.powerBars.player[POWERTYPE_WEREWOLF] = PH.RoundBar:New( PH.leftBar )
	PH.powerBars.player[POWERTYPE_WEREWOLF]:SetColor(0.8, 0, 0.57)

	PH.powerBars.controlledsiege[POWERTYPE_HEALTH] = PH.RoundBar:New( PH.leftBar )
	PH.powerBars.controlledsiege[POWERTYPE_HEALTH]:SetColor(0.8, 0, 0.57)

	PH.powerBars.player[POWERTYPE_MAGICKA] = PH.RoundBar:New( PH.rightBar )
	PH.powerBars.player[POWERTYPE_MAGICKA]:CreateText()
	PH.powerBars.player[POWERTYPE_MAGICKA]:SetColor(0, 0.57, 1)
	
	PH.powerBars.player[POWERTYPE_STAMINA] = PH.RoundBar:New( PH.rightBar )
	PH.powerBars.player[POWERTYPE_STAMINA]:CreateText()
	PH.powerBars.player[POWERTYPE_STAMINA]:SetColor(0.57, 1, 0)

	-- Create settings menu for our addon
	PH.CreateSettings()

	-- register global event listeners
	PH.RegisterEvents()
end

function PH.LoadSavedVars()
	-- addon options
	PH.savedVars = ZO_SavedVars:NewAccountWide( PH.savedVarsName, PH.savedVarsVer, nil, PH.defaults )
end

function PH.SetFadeLevels()
	PH.tlwAnimation:SetMinMaxAlpha(PH.savedVars.oocAlpha, PH.savedVars.icAlpha)
	PH.OnPlayerCombatState(EVENT_PLAYER_COMBAT_STATE, IsUnitInCombat("player") )
end

function PH.CreateSettings()
	if LibStub == nil then return end
	local LAM2 = LibStub("LibAddonMenu-2.0")
	if LAM2 == nil then return end
	
	local panelData = {
		type = 'panel',
		name = PH.name,
		displayName = "Palantir HUD Settings",
		author = "SpellBuilder",
		version = PH.version,
		-- slashCommand = "/palantirset",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local optionsData = {
		[1] = {
			type = "slider",
			name = "Default bars opacity, %",
			tooltip = "Out-of-combat opacity of bars. Usually this value is small and bars are barely visible.",
			min = 5,
			max = 95,
			step = 1,
			getFunc = function() return PH.savedVars.oocAlpha * 100 end,
			setFunc = function(value) PH.savedVars.oocAlpha = 0.01 * value PH.SetFadeLevels() end,
			width = "full",
			default = PH.defaults.oocAlpha * 100,
			--disabled = function() return false end,
		},
		[2] = {
			type = "slider",
			name = "In-combat bars opacity, %",
			tooltip = "In-combat opacity of bars. Usually this value is high and bars are normally visible during combat.",
			min = 5,
			max = 95,
			step = 1,
			getFunc = function() return PH.savedVars.icAlpha * 100 end,
			setFunc = function(value) PH.savedVars.icAlpha = 0.01 * value PH.SetFadeLevels() end,
			width = "full",
			default = PH.defaults.icAlpha * 100,
			--disabled = function() return false end,
		},
	}

	LAM2:RegisterAddonPanel('RoundHudAddonOptions', panelData)
	LAM2:RegisterOptionControls('RoundHudAddonOptions', optionsData)
end

function PH.RegisterEvents()
	EVENT_MANAGER:RegisterForEvent(PH.name, EVENT_ACTION_LAYER_POPPED, PH.ToggleVisibility)
	EVENT_MANAGER:RegisterForEvent(PH.name, EVENT_ACTION_LAYER_PUSHED, PH.ToggleVisibility)
	EVENT_MANAGER:RegisterForEvent(PH.name, EVENT_PLAYER_ACTIVATED,	PH.OnPlayerActivated )
	EVENT_MANAGER:RegisterForEvent(PH.name, EVENT_POWER_UPDATE,		PH.OnPowerUpdate )
	EVENT_MANAGER:RegisterForEvent(PH.name, EVENT_COMBAT_EVENT,			PH.OnCombatEvent )
	EVENT_MANAGER:RegisterForEvent(PH.name, EVENT_PLAYER_COMBAT_STATE,	PH.OnPlayerCombatState )
	EVENT_MANAGER:RegisterForEvent(PH.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED,   PH.OnVisualizationAdded )
	EVENT_MANAGER:RegisterForEvent(PH.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, PH.OnVisualizationRemoved )
	EVENT_MANAGER:RegisterForEvent(PH.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, PH.OnVisualizationUpdated )
	EVENT_MANAGER:RegisterForEvent(PH.name, EVENT_WEREWOLF_STATE_CHANGED,	PH.OnWerewolf )
	EVENT_MANAGER:RegisterForEvent(PH.name, EVENT_BEGIN_SIEGE_CONTROL,		PH.OnSiege )
	EVENT_MANAGER:RegisterForEvent(PH.name, EVENT_END_SIEGE_CONTROL,		PH.OnSiege )
	EVENT_MANAGER:RegisterForEvent(PH.name, EVENT_LEAVE_RAM_ESCORT,			PH.OnSiege )
end

function PH.ToggleVisibility(eventCode, layerIndex, activeLayerIndex)
	if not PH.hidden then 
		PH.tlw:SetHidden(activeLayerIndex > 2)
	else
		PH.tlw:SetHidden(PH.hidden)
	end
end

function PH.ToggleOnOff(eventCode, layerIndex, activeLayerIndex)
	PH.hidden = not PH.hidden
	PH.tlw:SetHidden(PH.hidden)
end

--[[ 
 * Runs on the EVENT_PLAYER_ACTIVATED listener.
 * This handler fires every time the player is loaded. Used to set initial values.
 ]]--
function PH.OnPlayerActivated(eventCode)

	PH.powerBars.player[POWERTYPE_HEALTH].values = { GetUnitPower("player", POWERTYPE_HEALTH) }
	PH.powerBars.player[POWERTYPE_HEALTH]:UpdateShield( GetUnitAttributeVisualizerEffectInfo("player", ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH) )

	for unitTag,fields in pairs(PH.powerBars) do
		for powerType,_ in pairs(fields) do
			if unitTag ~= "player" or powerType ~= POWERTYPE_HEALTH then
				PH.OnPowerUpdate(EVENT_POWER_UPDATE, unitTag, nil, powerType, GetUnitPower(unitTag, powerType))
			end
		end
	end

	PH.OnPlayerCombatState(EVENT_PLAYER_COMBAT_STATE, IsUnitInCombat("player") )
	PH.OnWerewolf(nil, IsWerewolf() )
	PH.OnSiege()
	PH.rightBar:Update() -- this bar has to be updated manually, as power and stamina are always visible
end

--[[ 
 * Runs on the EVENT_POWER_UPDATE listener.
 * This handler fires every time unit attribute changes.
 ]]--
function PH.OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	if PH.powerBars[unitTag] and PH.powerBars[unitTag][powerType] then
		PH.powerBars[unitTag][powerType]:SetValue(powerValue, powerMax, powerEffectiveMax)
	end
end

--[[ 
 * Runs on the EVENT_PLAYER_COMBAT_STATE listener.
 * This handler fires every time player enters or leaves combat
 ]]--
function PH.OnPlayerCombatState(eventCode, inCombat)
	if inCombat then
		PH.tlwAnimation:Stop(ZO_ALPHA_ANIMATION_OPTION_PREVENT_CALLBACK)
		PH.tlw:SetAlpha( PH.savedVars.icAlpha )
	else
		PH.tlwAnimation:FadeOut(500, 1000, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_ALPHA, nil, ZO_ALPHA_ANIMATION_OPTION_FORCE_SHOWN)
	end
end

--[[ 
 * Runs on the EVENT_COMBAT_EVENT listener.
 ]]--
function PH.OnCombatEvent( eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log )
	if isError and sourceType == COMBAT_UNIT_TYPE_PLAYER and targetType == COMBAT_UNIT_TYPE_PLAYER and PH.powerBars["player"][powerType] ~= nil then
		PH.powerBars.player[powerType]:OnError()
	end
end

--[[ 
 * Runs on the EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED listener.
 ]]--
function PH.OnVisualizationAdded(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
	if PH.powerBars[unitTag] and PH.powerBars[unitTag][powerType] then
		if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
			PH.powerBars[unitTag][powerType]:UpdateShield(value)
		elseif unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER then
			PH.UpdateRegen(unitTag, statType, attributeType, powerType )
		end
	end
end

--[[ 
 * Runs on the EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED listener.
 ]]--
function PH.OnVisualizationRemoved(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
	if PH.powerBars[unitTag] and PH.powerBars[unitTag][powerType] then
		if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
			PH.powerBars[unitTag][powerType]:UpdateShield(0)
		elseif unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER then
			PH.UpdateRegen(unitTag, statType, attributeType, powerType )
		end
	end
end

--[[ 
 * Runs on the EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED listener.
 ]]--
function PH.OnVisualizationUpdated(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
	if PH.powerBars[unitTag] and PH.powerBars[unitTag][powerType] and unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
		PH.powerBars[unitTag][powerType]:UpdateShield(newValue)
	end
end

--[[
 * Helper for regen/degen visuals
 ]]--
function PH.UpdateRegen(unitTag, statType, attributeType, powerType )
	local value = (GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, statType, attributeType, powerType) or 0)
				+ (GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, statType, attributeType, powerType) or 0)
	PH.powerBars[unitTag][powerType]:SetRegen(value)
end

--[[ 
 * Runs on the EVENT_WEREWOLF_STATE_CHANGED listener.
 ]]--
function PH.OnWerewolf(eventCode, werewolf)
	PH.powerBars.player[POWERTYPE_WEREWOLF]:SetValue(GetUnitPower("player", POWERTYPE_WEREWOLF))
	PH.powerBars.player[POWERTYPE_WEREWOLF]:SetHidden( not werewolf )
end

--[[ 
 * Runs on the EVENT_BEGIN_SIEGE_CONTROL, EVENT_END_SIEGE_CONTROL, EVENT_LEAVE_RAM_ESCORT listeners.
 ]]--
function PH.OnSiege(eventCode)
	local isSiege	= ( IsPlayerControllingSiegeWeapon() or IsPlayerEscortingRam() )
	PH.powerBars.controlledsiege[POWERTYPE_HEALTH]:SetValue(GetUnitPower("controlledsiege", POWERTYPE_HEALTH))
	PH.powerBars.controlledsiege[POWERTYPE_HEALTH]:SetHidden( not isSiege )
end

-- Utility functions

function PH.DelayBuffer( key, buffer, currentTime )
	if key == nil then return end
	if PH.delayBuffer[key] == nil then
		PH.delayBuffer[key] = {}
	end
	local delayBuffer = PH.delayBuffer[key]
	delayBuffer.buffer = buffer or 3
	delayBuffer.now    = currentTime or GetFrameTimeMilliseconds()
	if delayBuffer.last == nil then
		delayBuffer.last = delayBuffer.now
		return true -- for first call of DelayBuffer we should return true
	end
	local eval = ( delayBuffer.now - delayBuffer.last ) >= delayBuffer.buffer
	if eval then
		delayBuffer.last = delayBuffer.now
	end
	return eval
end

 --[[ 
 * A handy chaining function for quickly setting up UI elements
 * Allows us to reference methods to set properties without calling the specific object
 ]]-- 
function PH.Chain( object )

	-- Setup the metatable
	local T = {}
	setmetatable( T , { __index = function( self , func )

		-- Know when to stop chaining
		if func == "__END" then	return object end

		-- Otherwise, add the method to the parent object
		return function( self , ... )
			assert( object[func] , func .. " missing in object" )
			object[func]( object , ... )
			return self
		end
	end })

	-- Return the metatable
	return T
end

-- Hook initialization
EVENT_MANAGER:RegisterForEvent(PH.name, EVENT_ADD_ON_LOADED, PH.OnAddOnLoaded)
