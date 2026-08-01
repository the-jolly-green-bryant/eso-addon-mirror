-- *** SimpleSlashCommand ***
-- See detailed programming notes at the end of file

-- *** Pre-Initialize ***
SimpleSlashCommand = {}
SimpleSlashCommand.name = "SimpleSlashCommand"

-- *** Functions ***

local function Tester()
	
	d("Quick Test")
end

local function Tester2(extra)
	
	d("Quick Test 2 " .. tostring(extra))
end

-- *** Main ***

-- Check to see if this addon is the one loaded
function SimpleSlashCommand.OnAddOnLoaded(event, addonName)
	if addonName == SimpleSlashCommand.name then
		SLASH_COMMANDS["/st"] = Tester
		SLASH_COMMANDS["/st2"] = Tester2

		--[[ SLASH_COMMANDS NOTES:
		Do not use capital letters in slash commands. The command will fail silently.
		Leave off end ending () in the function call.
		In trying different combinations, I found this was the only one that worked.
		SimpleSlashCommand.Tester would not work in either the function call or declaration.
		In-game use /st will only output "Quick Test" even if you type in /st extra, however
		/st2 extra will output "Quick Test extra" to the chat window.  Using various
		advanced string parsing you can process multiple parameters.
		For more details: https://wiki.esoui.com/How_to_add_a_slash_command
		]]--
		
		-- No need to check any more
		EVENT_MANAGER:UnregisterForEvent(SimpleSlashCommand.name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(SimpleSlashCommand.name, EVENT_ADD_ON_LOADED, SimpleSlashCommand.OnAddOnLoaded)

--[[
 *** Programming Notes ***
 
Naming Conventions
	function SimpleSlashCommand.FunctionName()
	SimpleSlashCommand.storedVariable = 2	
	
GUI XML
	none

ZOS API
	EVENT_MANAGER:RegisterForEvent()
	EVENT_MANAGER:UnregisterForEvent()
	SLASH_COMMANDS[]
	
ZOS EVENTS	
	EVENT_ADD_ON_LOADED
	
ZOS CONSTANTS
	none

My Functions
	Tester
	Tester2

]]--