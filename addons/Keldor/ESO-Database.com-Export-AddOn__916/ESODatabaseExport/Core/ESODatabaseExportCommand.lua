ESODBExportCommand = {}

function ESODBExportCommand.Handle(...)

	local option = select(1, ...)

	if type(option) == "nil" or option == "" or option == "help" then

		local msg = GetString(ESODB_COMMAND_HELP_TITLE) .. "\n"
		msg = msg .. "|c009900/esodb character|r - " .. GetString(ESODB_COMMAND_HELP_CHARACTER) .. "\n"
		msg = msg .. "|c009900/esodb dungeon|r - " .. GetString(ESODB_COMMAND_HELP_DUNGEON) .. "\n"
		msg = msg .. "|c009900/esodb trial|r - " .. GetString(ESODB_COMMAND_HELP_TRIAL) .. "\n"
		msg = msg .. "|c009900/esodb sets|r - " .. GetString(ESODB_COMMAND_HELP_SETS) .. "\n"
		msg = msg .. "|c009900/esodb motifs|r - " .. GetString(ESODB_COMMAND_HELP_MOTIFS) .. "\n"
		msg = msg .. "|c009900/esodb antiquities|r - " .. GetString(ESODB_COMMAND_HELP_ANTIQUITIES) .. "\n"
		msg = msg .. "|c009900/esodb stats|r - " .. GetString(ESODB_COMMAND_HELP_STATS) .. "\n"
		msg = msg .. "|c009900/esodb c|r - " .. GetString(ESODB_COMMAND_HELP_CHARACTER_SHORT) .. "\n"
		msg = msg .. "|c009900/esodb d|r - " .. GetString(ESODB_COMMAND_HELP_DUNGEON_SHORT) .. "\n"
		msg = msg .. "|c009900/esodb t|r - " .. GetString(ESODB_COMMAND_HELP_TRIAL_SHORT) .. "\n"
		msg = msg .. "|c009900/esodb s|r - " .. GetString(ESODB_COMMAND_HELP_SETS_SHORT) .. "\n"
		msg = msg .. "|c009900/esodb m|r - " .. GetString(ESODB_COMMAND_HELP_MOTIFS_SHORT) .. "\n"
		msg = msg .. "|c009900/esodb a|r - " .. GetString(ESODB_COMMAND_HELP_ANTIQUITIES_SHORT) .. "\n"
		msg = msg .. "|c009900/esodb export|r - " .. GetString(ESODB_COMMAND_HELP_EXPORT) .. "\n"
		msg = msg .. "|c009900/esodb toggle-startup-message|r - " .. GetString(ESODB_COMMAND_HELP_TOGGLE_STARTUP_MESSAGE) .. "\n"
		msg = msg .. "|c009900/esodb version|r - " .. GetString(ESODB_COMMAND_HELP_VERSION)

		ESODBExportUtils:PrintMessage(msg)
	elseif option == "export" then
		ESODatabaseExport.Export()
		ESODBExportUtils:PrintMessage(GetString(ESODB_COMMAND_EXPORT))
	elseif option == "version" then
		ESODBExportUtils:PrintMessage(GetString(ESODB_COMMAND_ADDON_VERSION) .. " |ceeeeee" .. ESODatabaseExport.AddonVersion .. "|r")
	elseif option == "character" or option == "c" then
		ESODBExportCommand.OpenQuicklinkUrl("character")
	elseif option == "dungeon" or option == "d" then
		ESODBExportCommand.OpenQuicklinkUrl("dungeon")
	elseif option == "trial" or option == "t" then
		ESODBExportCommand.OpenQuicklinkUrl("trial")
	elseif option == "sets" or option == "s" then
		ESODBExportCommand.OpenQuicklinkUrl("sets")
	elseif option == "motifs" or option == "m" then
		ESODBExportCommand.OpenQuicklinkUrl("motifs")
	elseif option == "antiquities" or option == "a" then
		ESODBExportCommand.OpenQuicklinkUrl("antiquities")
	elseif option == "stats" then
		ESODBExportCommand.OpenQuicklinkUrl("stats")
	elseif option == "toggle-startup-message" then
		ESODatabaseExport.ToggleInitialExportChatMessage()
	end
end

function ESODBExportCommand.OpenQuicklinkUrl(type)

	local lang = ESODatabaseExport.GlobalStore.Lang

	if lang == "ru" or lang == "es" then
		lang = "en"
	end

	local _, megaserver = ESODBExportUtils:GetCharacterInfo()
	local url = ESODBExportConst.OpenUrlWebsite .. lang .. "/quicklink/" .. type .. "/" .. string.lower(megaserver) .. "/" .. GetCurrentCharacterId() .. "/"

	RequestOpenUnsafeURL(url)
end
