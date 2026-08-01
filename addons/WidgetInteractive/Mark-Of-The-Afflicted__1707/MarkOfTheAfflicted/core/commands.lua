-- Variables -------------------------------------------------------------------
MotA_Slash_Commands = {}

local colorYellow     = "|cFFFF00"
local colorSoftYellow = "|cCCCC00"
local colorRed        = "|cFF0000"
local colorBlue       = "|c1155bb"
local colorWidget     = "|c1fda9a"

-- Initialize slash commands ---------------------------------------------------
function MotA_Slash_Commands:Initialize(parent)
	SLASH_COMMANDS["/mota"] = function(command)
		local options = {}

		for o in command:gmatch("%S+") do
			table.insert(options, o)
		end

		if options[1] then
			local command  = string.lower(options[1])
			local option   = (options[2] and string.lower(options[2]) or nil)
			local argument = (options[3] and options[3] or nil)

			if command == "test" then
				-- local uid = GetCurrentCharacterId()
				-- d(parent.savedVariables.timers.list[uid])
				d(MotA_Fonts:GetTimerLabelFontString(MotA_Timers.parent))
			else
				MotA_Slash_Commands:DisplayGeneralHelp(parent)
			end
		else
			MotA_Slash_Commands:DisplayGeneralHelp(parent)
		end
	end
end

-- Display general help --------------------------------------------------------
function MotA_Slash_Commands:DisplayGeneralHelp(parent)
	d(colorWidget .. "[Mark of the Afflicted] " .. colorYellow .. GetString(MOTA_COMMANDS_VALID) .. ":")

	d(colorRed .. GetString(MOTA_COMMANDS_NONE))
end
