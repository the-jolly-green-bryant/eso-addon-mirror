tim99sFTSIO = tim99sFTSIO or {}
local ftsio = tim99sFTSIO 

function ftsio.initMenu()
	local LAM2 = LibAddonMenu2
	local panelData = {
		type        = "panel",
		name        = "|c9b30fftim99s FTSIO|r",
		author      = "|c9b30fftim99|r",
		version	    = "666",
		website		= "https://www.esoui.com/downloads/info3373-tim99sColoredLists.html",
		registerForRefresh = true,	--will refresh all options controls when a setting is changed and when the panel is shown
		registerForDefaults = true	--will set all options controls back to default values
	}
	LAM2:RegisterAddonPanel("tim99sFTSIO", panelData)
--===============================================================================================--
	local optionsData = {
		{	type		= "description",
			title		= "|c9b30ffFTSIO - Fuck This Shit I'm Out|r",
			text		= "|c999999I have come here to chew bubblegum and kick ass... and I'm all out of bubblegum|r",
			width		= "half",
		}, ----------------------------------------------------------------------------
		{	type		= "texture",
			image		= "/esoui/art/icons/assistant_banker_01.dds",
			--text      = "text",
			imageWidth	= 96,
			imageHeight	= 96,
			width		= "half",
		}, 
		--========================================================================--
		{	type    = "divider",
			alpha   = 0.4,
		}, -------------------------------------------
		{	type    = "checkbox",
			name    = "auto accept pvp queues",
			getFunc = function() return ftsio.svChar.autoAcceptPvpQ end,
			setFunc = function(value) ftsio.svChar.autoAcceptPvpQ=value end,
			default = ftsio.svCharDef.autoAcceptPvpQ,
			width   = "full",
			requiresReload = true,
		}, -------------------------------------------
		{	type    = "checkbox",
			name    = "chat message when accepted",
			getFunc = function() return ftsio.svChar.autoAcceptChat end,
			setFunc = function(value) ftsio.svChar.autoAcceptChat=value end,
			default = ftsio.svCharDef.autoAcceptChat,
			width   = "full",
			requiresReload = false,
		}, -------------------------------------------
		{	type    = "checkbox",
			name    = "use no-cp for imperial city",
			getFunc = function() return ftsio.svChar.useICnoCP end,
			setFunc = function(value) ftsio.svChar.useICnoCP=value end,
			default = ftsio.svCharDef.useICnoCP,
			width   = "full",
			requiresReload = false,
		}, -------------------------------------------
		--{	type    = "checkbox",
		--	name    = "auto accept dungeon queues",
		--	getFunc = function() return ftsio.svChar.autoAcceptIniQ end,
		--	setFunc = function(value) ftsio.svChar.autoAcceptIniQ=value end,
		--	default = ftsio.svCharDef.autoAcceptIniQ,
		--	width   = "full",
		--	requiresReload = true,
		--}, -------------------------------------------
	}
	LAM2:RegisterOptionControls("tim99sFTSIO", optionsData)
end
