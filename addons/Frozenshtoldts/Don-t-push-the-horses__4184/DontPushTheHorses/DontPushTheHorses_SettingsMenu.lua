function DontPushTheHorses:CreateSettingsMenu()
	if not LibAddonMenu2 then
		d("[DPTH] Error: LibAddonMenu2 not found!")
		return
	end

	if not DontPushTheHorses.savedVars or not DontPushTheHorses.savedVars.chatFilters or not DontPushTheHorses.savedVars.notifyChannels then
		d("[DPTH] Error: Saved variables not initialized correctly!")
		return
	end

	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = "Don't Push The Horses",
		displayName = "|cFF0000Don't Push The Horses!|r",
		author = "Frozenshtoldts",
		version = "1.0.6",
		slashCommand = "/dpthmenu",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	LAM:RegisterAddonPanel("DontPushTheHorsesPanel", panelData)

	local optionsTable = {}

	table.insert(optionsTable, {
		type = "description",
		text = "This addon filters unwanted language content from incoming chat messages and displays customizable notifications.",
	})

	-- Checkbox: block own messages
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Block My Own Messages",
		tooltip = "Enable this to also filter your own messages.",
		getFunc = function() return DontPushTheHorses.savedVars.blockOwnMessages end,
		setFunc = function(value) DontPushTheHorses.savedVars.blockOwnMessages = value end,
		default = false,
	})

	-- Dropdown: Message Format
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Message Format",
		tooltip = "Choose the format of the notification message.",
		choices = { "name", "name+channel", "name+channel+text" },
		getFunc = function() return DontPushTheHorses.savedVars.messageFormat end,
		setFunc = function(value) DontPushTheHorses.savedVars.messageFormat = value end,
		default = "name+channel+text",
	})

	-- Submenus
	local blockControls = {
		type = "submenu",
		name = "Channels to Filter (Messages will be blocked)",
		controls = {},
	}
	local notifyControls = {
		type = "submenu",
		name = "Channels to Show Notifications",
		controls = {},
	}

	-- Hardcoded channel order
	local orderedChannelIDs = {
		CHAT_CHANNEL_SAY,
		CHAT_CHANNEL_YELL,
		CHAT_CHANNEL_PARTY,
		CHAT_CHANNEL_GUILD_1,
		CHAT_CHANNEL_GUILD_2,
		CHAT_CHANNEL_GUILD_3,
		CHAT_CHANNEL_GUILD_4,
		CHAT_CHANNEL_GUILD_5,
		CHAT_CHANNEL_ZONE,
		CHAT_CHANNEL_ZONE_LANGUAGE_1,
		CHAT_CHANNEL_ZONE_LANGUAGE_2,
		CHAT_CHANNEL_ZONE_LANGUAGE_3,
		CHAT_CHANNEL_ZONE_LANGUAGE_4,
		CHAT_CHANNEL_ZONE_LANGUAGE_5,
		CHAT_CHANNEL_ZONE_LANGUAGE_6,
		CHAT_CHANNEL_WHISPER,
		CHAT_CHANNEL_WHISPER_SENT,
		CHAT_CHANNEL_EMOTE,
	}

	for _, id in ipairs(orderedChannelIDs) do
		local label = DontPushTheHorses.CHANNELS[id]
		if label then
			table.insert(blockControls.controls, {
				type = "checkbox",
				name = label,
				getFunc = function() return DontPushTheHorses.savedVars.chatFilters[id] end,
				setFunc = function(value) DontPushTheHorses.savedVars.chatFilters[id] = value end,
				default = true,
			})
			table.insert(notifyControls.controls, {
				type = "checkbox",
				name = label,
				getFunc = function() return DontPushTheHorses.savedVars.notifyChannels[id] end,
				setFunc = function(value) DontPushTheHorses.savedVars.notifyChannels[id] = value end,
				default = true,
			})
		end
	end

	table.insert(optionsTable, blockControls)
	table.insert(optionsTable, notifyControls)

	LAM:RegisterOptionControls("DontPushTheHorsesPanel", optionsTable)
end
