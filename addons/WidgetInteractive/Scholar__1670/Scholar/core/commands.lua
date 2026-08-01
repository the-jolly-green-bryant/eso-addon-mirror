-- Variables -------------------------------------------------------------------
Scholar_Slash_Commands = {}

local colorYellow     = "|cFFFF00"
local colorSoftYellow = "|cCCCC00"
local colorRed        = "|cFF0000"
local colorBlue       = "|c1155bb"
local colorWidget     = "|c1fda9a"

-- Initialize slash commands ---------------------------------------------------
function Scholar_Slash_Commands:Initialize(parent)
	SLASH_COMMANDS["/scholar"] = function(command)
		local options = {}

		for o in command:gmatch("%S+") do
			table.insert(options, o)
		end

		if options[1] then
			local command  = string.lower(options[1])
			local option   = (options[2] and string.lower(options[2]) or nil)
			local argument = (options[3] and options[3] or nil)

			if command == "timers" then
				if parent.savedVariables.enable.timers or parent.savedVariables.enable.stableTimer then
					Scholar_Timers_Toggle()
				end
			elseif command == "set" then
				if option == "timersound" and argument then
					parent.savedVariables.timers.notificationSound = argument
					ReloadUI("ingame")
				else
					Scholar_Slash_Commands:DisplaySetHelp(parent)
				end
			else
				Scholar_Slash_Commands:DisplayGeneralHelp(parent)
			end
		else
			Scholar_Slash_Commands:DisplayGeneralHelp(parent)
		end
	end
end

-- Display general help --------------------------------------------------------
function Scholar_Slash_Commands:DisplayGeneralHelp(parent)
	d(colorWidget .. "[Scholar] " .. colorYellow .. GetString(SCHOLAR_COMMANDS_VALID) .. ":")

	if parent.savedVariables.enable.timers or parent.savedVariables.enable.stableTimer then
		d(colorBlue .. "    /scholar timers" .. colorSoftYellow .. " - " .. GetString(SCHOLAR_COMMANDS_TIMERS))
		d(colorBlue .. "    /scholar set <setting> <option>" .. colorSoftYellow .. " - " .. GetString(SCHOLAR_COMMANDS_SET))
	else
		d(colorRed .. GetString(SCHOLAR_COMMANDS_NONE))
	end
end

-- Display set help ------------------------------------------------------------
function Scholar_Slash_Commands:DisplaySetHelp(parent)
	d(colorWidget .. "[Scholar] " .. colorYellow .. GetString(SCHOLAR_COMMANDS_VALID) .. ":")

	if parent.savedVariables.enable.timers or parent.savedVariables.enable.stableTimer then
		d(colorBlue .. "    /scholar set timersound <option>" .. colorSoftYellow .. " - " .. GetString(SCHOLAR_COMMANDS_SET_TIMERSOUND))
	else
		d(colorRed .. GetString(SCHOLAR_COMMANDS_NONE))
	end
end
