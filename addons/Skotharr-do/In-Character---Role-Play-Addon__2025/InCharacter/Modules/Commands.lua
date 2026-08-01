--[[
Title:   Command Handling
Version: 1.1.3
Author:  @Skotharr-do [PC/EU]
--]]

local HELP = 'help'
local ENABLE_RETICLE_WINDOW = 'enable'
local DISABLE_RETICLE_WINDOW = 'disable'
local ANCHOR_RETICLE_WINDOW_TOP = 'top'
local ANCHOR_RETICLE_WINDOW_BOTTOM = 'bottom'
local SHOW_RETICLE_WINDOW_ALWAYS = 'always'
local SHOW_RETICLE_WINDOW_NORMAL = 'normal'
local SHOW_RETICLE_TIMESTAMP = 'show_timestamp'
local HIDE_RETICLE_TIMESTAMP = 'hide_timestamp'
local RETICLE_WINDOW_STATUS = 'popup'
local PRINT_CHARACTER_DESCRIPTION = 'print'
local OPEN_MENU = 'menu'
local OPEN_EDIT_WINDOW = 'edit'
local LIST_CHARACTERS = 'list'

local Commands = {}

Commands[HELP] = function()
		-- zo_strformat() cannot handle more than 6 entries. Use default LUA string.format()
		CHAT_SYSTEM:AddMessage(string.format(GetString(SI_INCHARACTER_COMMAND_HELP),
			IC.Addon.SLASH_COMMAND..' '..HELP,
			IC.Addon.SLASH_COMMAND..' '..OPEN_MENU,
			IC.Addon.SLASH_COMMAND..' '..OPEN_EDIT_WINDOW,
			IC.Addon.SLASH_COMMAND..' '..ENABLE_RETICLE_WINDOW..'/'..DISABLE_RETICLE_WINDOW,
			IC.Addon.SLASH_COMMAND..' '..SHOW_RETICLE_WINDOW_NORMAL..'/'..SHOW_RETICLE_WINDOW_ALWAYS,
			IC.Addon.SLASH_COMMAND..' '..SHOW_RETICLE_TIMESTAMP..'/'..HIDE_RETICLE_TIMESTAMP,
			IC.Addon.SLASH_COMMAND..' '..ANCHOR_RETICLE_WINDOW_TOP..'/'..ANCHOR_RETICLE_WINDOW_BOTTOM,
			IC.Addon.SLASH_COMMAND..' '..RETICLE_WINDOW_STATUS,
			IC.Addon.SLASH_COMMAND..' '..LIST_CHARACTERS,
			IC.Addon.SLASH_COMMAND,
			IC.Addon.SLASH_COMMAND..' '..PRINT_CHARACTER_DESCRIPTION))
	end

Commands[ENABLE_RETICLE_WINDOW] = function()
		IC.ReticleWindow.SetEnabled(true)
		CHAT_SYSTEM:AddMessage(GetString(SI_INCHARACTER_COMMAND_RETICLE_WINDOW_ENABLED))
	end

Commands[DISABLE_RETICLE_WINDOW] = function()
		IC.ReticleWindow.SetEnabled(false)
		CHAT_SYSTEM:AddMessage(GetString(SI_INCHARACTER_COMMAND_RETICLE_WINDOW_DISABLED))
	end

Commands[ANCHOR_RETICLE_WINDOW_TOP] = function()
		IC.ReticleWindow.SetAnchor(TOP)
		CHAT_SYSTEM:AddMessage(GetString(SI_INCHARACTER_COMMAND_RETICLE_WINDOW_ANCHOR_TOP))
	end

Commands[ANCHOR_RETICLE_WINDOW_BOTTOM] = function()
		IC.ReticleWindow.SetAnchor(BOTTOM)
		CHAT_SYSTEM:AddMessage(GetString(SI_INCHARACTER_COMMAND_RETICLE_WINDOW_ANCHOR_BOTTOM))
	end

Commands[SHOW_RETICLE_WINDOW_ALWAYS] = function()
		IC.ReticleWindow.SetAlwaysVisible(true)
		CHAT_SYSTEM:AddMessage(GetString(SI_INCHARACTER_COMMAND_RETICLE_WINDOW_VISIBLE_ALWAYS))
	end

Commands[SHOW_RETICLE_WINDOW_NORMAL] = function()
		IC.ReticleWindow.SetAlwaysVisible(false)
		CHAT_SYSTEM:AddMessage(GetString(SI_INCHARACTER_COMMAND_RETICLE_WINDOW_VISIBLE_NORMAL))
	end

Commands[SHOW_RETICLE_TIMESTAMP] = function()
	IC.ReticleWindow.SetTimestampVisible(true)
	CHAT_SYSTEM:AddMessage(GetString(SI_INCHARACTER_COMMAND_RETICLE_TIMESTAMP_VISIBLE))
end

Commands[HIDE_RETICLE_TIMESTAMP] = function()
	IC.ReticleWindow.SetTimestampVisible(false)
	CHAT_SYSTEM:AddMessage(GetString(SI_INCHARACTER_COMMAND_RETICLE_TIMESTAMP_HIDDEN))
end

Commands[PRINT_CHARACTER_DESCRIPTION] = function(parameter)
		if parameter == nil then
			IC.CharacterWide.WriteCurrentDescriptionToChatInput()
			return
		end

		local description = nil
		local number = tonumber(parameter)
		if number ~= nil then
			description = IC.CharacterWide.FindDescriptionByKeyNumber(number)
		else
			description = IC.CharacterWide.GetDescriptions()[parameter]
		end
		IC.CharacterWide.WriteToChatInput(description)
	end

Commands[OPEN_MENU] = function()
		IC.AddonMenu.Open()
	end

Commands[OPEN_EDIT_WINDOW] = function()
		IC.EditWindow.OpenAndFocus()
	end

Commands[LIST_CHARACTERS] = function(parameter)
		if parameter == nil then
			CHAT_SYSTEM:AddMessage(zo_strformat(GetString(SI_INCHARACTER_COMMAND_LIST_PARAMETER_EMPTY), IC.Addon.SLASH_COMMAND..' '..LIST_CHARACTERS))
			return
		end

		local accountName
		if not IsDecoratedDisplayName(parameter) then
			accountName = IC.AccountWide.FindAccountName(parameter)
		else
			accountName = parameter
		end
		-- list up all characters of player, parameter being account name
		if accountName ~= nil and IsDecoratedDisplayName(accountName) then
			local characterNames = IC.AccountWide.ReadCharacterNames(accountName)
			if characterNames:len() == 0 then
				characterNames = GetString(SI_INCHARACTER_COMMAND_LIST_NONE)
			end
			CHAT_SYSTEM:AddMessage(zo_strformat(GetString(SI_INCHARACTER_COMMAND_LIST_KNOWN_CHARACTERS), accountName, characterNames))
		else
			CHAT_SYSTEM:AddMessage(zo_strformat(GetString(SI_INCHARACTER_COMMAND_LIST_UNKNOWN_ACCOUNT), parameter))
		end
	end

Commands[RETICLE_WINDOW_STATUS] = function()
		local enabledString
		local alwaysVisibleString
		if IC.ReticleWindow.IsEnabled() then
			enabledString = GetString(SI_INCHARACTER_GENERAL_YES)
		else
			enabledString = GetString(SI_INCHARACTER_GENERAL_NO)
		end
		if IC.ReticleWindow.IsAlwaysVisible() then
			alwaysVisibleString = GetString(SI_INCHARACTER_GENERAL_YES)
		else
			alwaysVisibleString = GetString(SI_INCHARACTER_GENERAL_NO)
		end
		CHAT_SYSTEM:AddMessage(zo_strformat(GetString(SI_INCHARACTER_COMMAND_RETICLE_WINDOW_STATUS), enabledString, alwaysVisibleString))
	end

function IC.ExecuteCommand(message, command, parameter)
	if command == nil or command:len() == 0 then
		Commands[HELP]()
		return
	end

	local commandLower = command:lower()
	if Commands[commandLower] ~= nil then
		Commands[commandLower](parameter)
	else
		local character = IC.AccountWide.ReadCharacter(nil, message)
		if character ~= nil then
			CHAT_SYSTEM:AddMessage(zo_strformat(GetString(SI_INCHARACTER_COMMAND_PRINT_CHARACTER_DESCRIPTION), character.name, character.description, os.date(GetString(SI_INCHARACTER_GENERAL_DATE_FORMAT), character.time)))
		else
			CHAT_SYSTEM:AddMessage(zo_strformat(GetString(SI_INCHARACTER_COMMAND_UNKNOWN), message))
		end
	end
end