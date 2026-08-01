-- *** SimpleKeybind ***
-- See detailed programming notes at the end of file

-- *** Pre-Initialize ***
SimpleKeybind = {}
SimpleKeybind.name = "SimpleKeybind"

--*** Functions ***

-- Output debug information to test if the assignments were made
local function Tester()
	d("Simple Keybind Status Report")
	d("Binding 1: " .. GetString(SI_BINDING_NAME_SK1))
	d("Binding 2: " .. GetString(SI_BINDING_NAME_SK2))
	d("Binding 3: " .. GetString(SI_BINDING_NAME_SK3))
	d("Keybinding Layer: " .. GetString(SI_KEYBINDINGS_LAYER_GENERAL))
end

-- A function called from the bindings.xml keybind
function example1()
	d("Button 1 was pushed")
end

-- A second function called from the bindings.xml keybind
-- This one demonstrates the use of parameters
function example2(action)
	if action == "2" then d("Button 2 was pushed")
	elseif action == "three" then d("Button 3 was pushed")
	else d("Error")
	end
end

-- *** Main ***

-- Assigning the keybinds and the debugging slash command
function SimpleKeybind.Initialize()
	-- LUA is a scripted language, not a compiled language.  Thins is run
	-- in the order they appear.
	-- These calls must be *after* the function have been defined above
	ZO_CreateStringId("SI_BINDING_NAME_SK1", "|cEECA2AKeybind1|r")
	ZO_CreateStringId("SI_BINDING_NAME_SK2", "|cEECA2AKeybind2|r")
	ZO_CreateStringId("SI_BINDING_NAME_SK3", "|cEECA2AKeybind3|r")
	SLASH_COMMANDS["/st"] = Tester
end

-- Check to see if this addon is the one loaded
function SimpleKeybind.OnAddOnLoaded(event, addonName)
	if addonName == SimpleKeybind.name then
		SimpleKeybind.Initialize()
		-- No need to check any more
		EVENT_MANAGER:UnregisterForEvent(SimpleKeybind.name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(SimpleKeybind.name, EVENT_ADD_ON_LOADED, SimpleKeybind.OnAddOnLoaded)

--[[
 *** Programming Notes ***
 
Naming Conventions
	function SimpleKeybind.FunctionName()
	SimpleKeybind.storedVariable = 2	
	
GUI & XML
	none

API & ESO Functions
	EVENT_MANAGER:RegisterForEvent(addon name, event, triggered function)
	EVENT_MANAGER:UnregisterForEvent(addon name, event)
	d(string)
	SLASH_COMMANDS[""]
	ZO_CreateStringId(binding, string)
	
EVENTS	
	EVENT_ADD_ON_LOADED
	
CONSTANTS
	SI_KEYBINDINGS_LAYER_GENERAL
	
My Functions
	SimpleKeybind.OnAddOnLoaded(event, addonName)
	SimpleKeybind.Initialize()
	example1()
	example2(string)
	Tester()
	
]]--