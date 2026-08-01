-- Local instances of Global tables
local SK = SwissKnife
local SKCD = SK.CustomDialogs
local SKC = SK.Collectables
local SKH = SK.HelperFunctions


local function fillCommandsData()
	SK.commandsData = {
		[0] = {
			command = "skh",
			helpText = GetString(SI_SK_SLASH_COMMANDS_HELP),
			callback = function() SK.SlashCommands.showHelp() end
		},
		[1] = {
			command = "skupt",
			helpText = GetString(SI_SK_SLASH_COMMANDS_UPDATE_TRACKED),
			callback = function() SKCD.refreshTrackedSetItems() end
		},
		[2] = {
			command = "skupc",
			helpText = GetString(SI_SK_SLASH_COMMANDS_UPDATE_COLLECTABLES),
			callback = function() SKC.refreshCollectables() end
		},
		[4] = {
			command = "skmw",
			helpText = GetString(SI_SK_SLASH_COMMANDS_TOGGLE_MAIN_WINDOW),
			callback = function() SKMD:Toggle() end
		},
		[5] = {
			command = "sktb",
			helpText = SKH.getFormattedText(GetString(SI_SK_SLASH_COMMANDS_SUMMON),
				SK.COLOR.LIGHT_YELLOW:Colorize(SKH.getCompanionNameById(SK.COMPANIONS.BASTIAN))),
			callback = function() SKH.summonCompanion(SK.COMPANIONS.BASTIAN) end
		},
		[6] = {
			command = "sktm",
			helpText = SKH.getFormattedText(GetString(SI_SK_SLASH_COMMANDS_SUMMON),
				SK.COLOR.LIGHT_YELLOW:Colorize(SKH.getCompanionNameById(SK.COMPANIONS.MIRRI))),
			callback = function() SKH.summonCompanion(SK.COMPANIONS.MIRRI) end
		},
		[7] = {
			command = "skti",
			helpText = SKH.getFormattedText(GetString(SI_SK_SLASH_COMMANDS_SUMMON),
				SK.COLOR.LIGHT_YELLOW:Colorize(SKH.getCompanionNameById(SK.COMPANIONS.ISOBEL))),
			callback = function() SKH.summonCompanion(SK.COMPANIONS.ISOBEL) end
		},
		[8] = {
			command = "skte",
			helpText = SKH.getFormattedText(GetString(SI_SK_SLASH_COMMANDS_SUMMON),
				SK.COLOR.LIGHT_YELLOW:Colorize(SKH.getCompanionNameById(SK.COMPANIONS.EMBER))),
			callback = function() SKH.summonCompanion(SK.COMPANIONS.EMBER) end
		},
		[9] = {
			command = "skts",
			helpText = SKH.getFormattedText(GetString(SI_SK_SLASH_COMMANDS_SUMMON),
				SK.COLOR.LIGHT_YELLOW:Colorize(SKH.getCompanionNameById(SK.COMPANIONS.SHARP))),
			callback = function() SKH.summonCompanion(SK.COMPANIONS.SHARP) end
		},
		[10] = {
			command = "skta",
			helpText = SKH.getFormattedText(GetString(SI_SK_SLASH_COMMANDS_SUMMON),
				SK.COLOR.LIGHT_YELLOW:Colorize(SKH.getCompanionNameById(SK.COMPANIONS.AZANDAR))),
			callback = function() SKH.summonCompanion(SK.COMPANIONS.AZANDAR) end
		},
		[11] = {
			command = "sktt",
			helpText = SKH.getFormattedText(GetString(SI_SK_SLASH_COMMANDS_SUMMON),
				SK.COLOR.LIGHT_YELLOW:Colorize(SKH.getCompanionNameById(SK.COMPANIONS.TANLORIN))),
			callback = function() SKH.summonCompanion(SK.COMPANIONS.TANLORIN) end
		},
		[12] = {
			command = "sktz",
			helpText = SKH.getFormattedText(GetString(SI_SK_SLASH_COMMANDS_SUMMON),
				SK.COLOR.LIGHT_YELLOW:Colorize(SKH.getCompanionNameById(SK.COMPANIONS.ZERIT))),
			callback = function() SKH.summonCompanion(SK.COMPANIONS.ZERIT) end
		},
		[13] = {
			command = "skci",
			helpText = GetString(SI_SK_SLASH_COMMANDS_COMPANIONS_INTERACTION),
			callback = function() SKH.toggleCompanionsInteraction() end
		},
		[14] = {
			command = "sktdi",
			helpText = GetString(SI_SK_SLASH_COMMANDS_DANGER_INTERACTION),
			callback = function()
				SKH.toggleDangerInteraction()
				SK.savedVars.previousHideDangerInteraction = SK.savedVars.hideDangerInteraction
			end
		},
	}
	SK.commandsData[15] = {
		command = "skesnu",
		callback = function()
			SK.savedVars.setsData = {}
			for i = 1, 1000 do
				local setName = GetItemSetName(i)
				if setName and setName ~= '' then
					SK.savedVars.setsData[i] = setName
				end
			end
		end
	}
end

local function showHelp()
	for _, data in pairs(SK.commandsData) do
		if data.helpText then
			SKH.sendMessageToChat(
				SK.COLOR.ORANGE:Colorize("/"..data.command),
				SK.COLOR.WHITE:Colorize(" - "..data.helpText)
			)
		end
	end
end

local function InitSlashCommands()
	fillCommandsData()
	for _, data in pairs(SK.commandsData) do
		SLASH_COMMANDS["/"..data.command] = data.callback
	end
end

-- Export
SK.SlashCommands = {
	InitSlashCommands = InitSlashCommands,
	fillCommandsData = fillCommandsData,
	showHelp = showHelp
}