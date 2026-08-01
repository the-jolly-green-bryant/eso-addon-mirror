-- *** SimpleBox ***
-- See detailed programming notes at the end of file

-- *** Pre-Initialize ***


-- Initialize the storage container, and the name of the addon
SimpleBox = {}
SimpleBox.name = "SimpleBox"

-- Define default minimum settings for the saved variables
SimpleBox.defaults = {
		left = 500,
		top = 500,
		hide = true,
		test = "This is a line of text to see if the saved variables function is called",
		test2 = "more testing"
	}


-- *** Functions ***


-- Set the FightingIndicator position and state
function SimpleBox.SetIndicatorPosition()
	local left = SimpleBox.savedVariables.left
	local top = SimpleBox.savedVariables.top
	
	-- FightingIndicator is the name of our box defined in SimpleBox.xml
	-- FightingIndicatorOutput is defined in SimpleBox.xml
	FightingIndicator:ClearAnchors()
	FightingIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
	FightingIndicatorOutput:SetText("|c00ff00Safe!|r")
	FightingIndicator:SetHidden(SimpleBox.savedVariables.hide)
end


-- When the user finished moving the indicator - triggered from SimpleBox.xml
function SimpleBox.OnIndicatorMoveStop()
	SimpleBox.savedVariables.left = FightingIndicator:GetLeft()
	SimpleBox.savedVariables.top = FightingIndicator:GetTop()
end


-- Display as needed for combat state changes
function SimpleBox.PlayerCombatState(event, inCombat)
	-- FightingIndicator is defined in SimpleBox.xml
	-- FightingIndicatorOutput is defined in SimpleBox.xml
	if (inCombat) then
		FightingIndicatorOutput:SetText("|cFF0000Fighting!|r")
		FightingIndicator:SetHidden(false)
	else
		FightingIndicatorOutput:SetText("|c00ff00Safe!|r")
		if SimpleBox.savedVariables.hide == true then
			FightingIndicator:SetHidden(true)
		end
	end

end


-- When the user toggles always display box on or off
function SimpleBox.Toggle()
	SimpleBox.savedVariables.hide = not SimpleBox.savedVariables.hide
	FightingIndicator:SetHidden(SimpleBox.savedVariables.hide)
end


-- *** Main ***


-- Initialize all aspects of the addon
function SimpleBox.Initialize()
	-- Register for whenever combat state changes
	EVENT_MANAGER:RegisterForEvent(SimpleBox.name, EVENT_PLAYER_COMBAT_STATE, SimpleBox.PlayerCombatState)
	
	-- Load saved variables
	SimpleBox.savedVariables = ZO_SavedVars:New("SimpleBoxSavedVariables", 1, nil, SimpleBox.defaults)
	-- For per-character saved settings use:
	-- ZO_SavedVars:NewCharacterId(savedVariableName, variableVersion, namespace, defaults, profile)
	
	-- Define the slash command
	SLASH_COMMANDS["/sbtoggle"] = SimpleBox.Toggle
	
	-- Set up the display box
	SimpleBox.SetIndicatorPosition()
end


-- Check to see if this addon is the one loaded
function SimpleBox.OnAddOnLoaded(event, addonName)
	if addonName == SimpleBox.name then
		SimpleBox.Initialize()
		EVENT_MANAGER:UnregisterForEvent(SimpleBox.name, EVENT_ADD_ON_LOADED)
	end
end


EVENT_MANAGER:RegisterForEvent(SimpleBox.name, EVENT_ADD_ON_LOADED, SimpleBox.OnAddOnLoaded)


--[[


 *** Programming Notes ***
 
Naming Conventions
	function SimpleBox.FunctionName()
	SimpleBox.storedVariable = 2	
	
GUI & XML & CONTROLS
	:setHidden
	:ClearAnchors
	:SetAnchor
	:GetLeft
	:GetTop
	:SetText

API & ESO Functions
	ZO_SavedVars:NewAccountWide
	EVENT_MANAGER:RegisterForEvent
	EVENT_MANAGER:UnregisterForEvent
	SLASH_COMMANDS
	
EVENTS	
	EVENT_ADD_ON_LOADED
	EVENT_PLAYER_COMBAT_STATE
	
ZOS CONSTANTS
	none
	
My Functions
	SimpleBox.OnAddOnLoaded
	SimpleBox.Initialize
	SimpleBox.PlayerCombatState
	SimpleBox.SetIndicatorPosition
	SimpleBox.OnIndicatorMoveStop
	SimpleBox.Toggle
]]--