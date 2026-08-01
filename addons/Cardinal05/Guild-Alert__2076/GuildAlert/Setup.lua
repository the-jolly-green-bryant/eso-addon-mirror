local GA = GuildAlert
local EH = GA.EventHandlers
local UI = GA.UI
local Util = GA.Util
local Setup = GA.Setup
local LAM

------[[ Operations : Add-On ]]------


function Setup.Initialize()

	GA.Vars = ZO_SavedVars:NewAccountWide( GA.SAVED_VARS.FILE, GA.SAVED_VARS.VERSION, nil, GA.SAVED_VARS.DEFAULTS )

end


function Setup.InitializeSettingsMenu()

	LAM = LibAddonMenu2
	local options, panelData, panelName

	panelName = GA.ADDON.NAME

	panelData = {
		type = "panel",
		name = GA.ADDON.TITLE,
		displayName = GA.ADDON.TITLE .. " - Settings",
		author = GA.ADDON.AUTHOR,
		version = GA.ADDON.VERSION,
		registerForRefresh = true,
		registerForDefaults = true,
	}

	GA.LAMPanel = LAM:RegisterAddonPanel( panelName, panelData )

	options = { }

	table.insert( options, {
		type = "custom",
	} )

	table.insert( options, {
		type = "header",
		name = "Receiving Alerts",
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Enable Announcements",
		tooltip = "Toggle this ON to display Guild Alerts from your Guild Masters as Announcements in the center of your screen.",
		getFunc = function() return GA.Vars.EnableAnnouncements end,
		setFunc = function(value) GA.Vars.EnableAnnouncements = value end,
		default = GA.SAVED_VARS.DEFAULTS.EnableAnnouncements,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "checkbox",
		name = "Enable Chat Messages",
		tooltip = "Toggle this ON to display Guild Alerts from your Guild Masters as system messages in your chat window.",
		getFunc = function() return GA.Vars.EnableChatMessages end,
		setFunc = function(value) GA.Vars.EnableChatMessages = value end,
		default = GA.SAVED_VARS.DEFAULTS.EnableChatMessages,
		disabled = function() return false end,
	} )

	table.insert( options, {
		type = "custom",
	} )

	table.insert( options, {
		type = "header",
		name = "Broadcasting Alerts",
	} )

	table.insert( options, {
		type = "description",
		title = "How do I broadcast alerts to my Guild Members?",
		text = "\nTo broadcast an alert to any Guild Members |cff3333that are running this add-on and that are online|r, " ..
			"simply edit your guild's |caaaaffAbout Us|r field in the |c7777ffGuilds|r menu as follows:\n\n" ..
			"At the end of the |caaaaffAbout Us|r field, begin a new line with the text |caaffaaAlert:|r followed by your message. " ..
			"All of the text that follows |caaffaaAlert:|r will be broadcast to any online Guild Members that use this add-on.",
		width = "full",
	} )

	LAM:RegisterOptionControls( panelName, options )

end
