local LAM = LibAddonMenu2
local ee = ESOEmoji
local settings = ee.GetVars()
local saveData = {}
local panelName = "ESOEmojiSettings" -- TODO the name will be used to create a global variable, pick something unique or you may overwrite an existing variable!
local panel

local panelData = {
    type = "panel",
    name = ee.name .. " |t28:28:ESOEmoji/icons/misc/1F60D.dds|t",
	displayName = "ESO Emoji |t28:28:ESOEmoji/icons/misc/1F60D.dds|t",
    author = "|c800020@BosmeriPride|r and |c0DC1CF@M0R_Gaming|r",
	version = ee.version,
}

local optionsData = {
	{
		type = "header",	-- General Options Header
		name = "General",
	},
    {
        type = "checkbox",	-- showChatBar
        name = "Chat Bar",
		tooltip = "The chat bar is a bar above your chat textbox that contains extra controls.",
        getFunc = function() return settings.showChatBar end,
        setFunc = function(value) if value then ee:ShowChatBar() else ee:HideChatBar() end end
    },
	{
        type = "dropdown",	-- previewString only enabled if chat bar is enabled
        name = "Chat Bar displays",
		disabled = true,
		choices = {"Preview"},
		tooltip = "Change what the Chat Bar shows above the chat textbox. \n - Preview Text: allows you to see what your message will look like with emojis without editing your messages in real time.\n - Favourites: allows you to choose your favourite emoji to be available for quick access above the chat.",
        getFunc = function()
			if settings.previewString then
				return "Preview"
			else
				return "Favourites"
			end
		end,
        setFunc = function(value)
		if value == "Preview" then
				settings.previewString = true
			else
				settings.previewString = false
			end
		end
    },
	{
        type = "checkbox",	-- realtimeEdit
        name = "Show emoji in textbox while typing",
		tooltip = "Automatically edits text message to show which emoji are being used.",
		warning = "This feature EDITS your messages in real time before you send a message in chat. If you feel uncomfortable about this feature due to privacy or security concerns, you should leave it disabled.",
        getFunc = function() return settings.realtimeEdit end,
        setFunc = function(value) settings.realtimeEdit = value end
    },
	{
		type = "header",	-- Emoji Settings Header
		name = "Emoji Settings",
	},
	--[[ -- Preview isn't quite working as intended
	{
		type = "texture",	-- Emoji Preview
		image = "ESOEmoji/icons/openmoji-72x72-colour-dds/1F604.dds",
		imageWidth = 50,
		imageHeight = 50,
	},
	--]]
	{
        type = "dropdown",	-- Path of style (drop down?)
        name = "Appearance",
		choices = {"OpenMoji", "Twemoji"},
		choicesValues = {"ESOEmoji/icons/openmoji-72x72-colour-dds/", "ESOEmoji/icons/twemoji-72x72-colour-dds/"},
        getFunc = function() return settings.emojiSettings.Path end,
        setFunc = function(value) 
			settings.emojiSettings.Path = value
			--optionsData[6].image = value + "1F604.dds"
		end
    },
	{
        type = "slider",	-- Size option
        name = "Size",
		min = 10,
		max = 50,
		step = 1,
		tooltip = "Size of displayed emoji.\nThis setting is not retroactive.\nDefault = 28.",
        getFunc = function() return settings.emojiSettings.Size end,
        setFunc = function(value) settings.emojiSettings.Size = value end
    },
	{
        type = "checkbox",	-- SCEnabled AND StandardEnabled
        name = "Translate emoji shortcodes",
		tooltip = "Enables shortcodes. Example: :smile: will be changed to a smile emoji.",
		warning = "Requires UI Reload.",
        getFunc = function() return settings.emojiSettings.SCEnabled end,
        setFunc = function(value) settings.emojiSettings.SCEnabled = value end
    },
	{
        type = "checkbox",	-- CustomEnabled  should only be functional if shortcodes are enabled
        name = "Translate non-Unicode custom shortcodes",
		disabled = true,
		tooltip = "Custom emoji are coming soon!",
        getFunc = function() return settings.emojiSettings.CustomEnabled end,
        setFunc = function(value) settings.emojiSettings.CustomEnabled = value end
    },
    --[[
	{
		type = "header",	-- Emoji Settings Header
		name = "Favourites",
	},
	{
		type = "description",
		title = "Work in Progress Feature",
		text = "This feature is still being worked on, and will not be usable yet."
	},
	{
		type = "texture",	-- Emoji Preview
		image = "ESOEmoji/icons/openmoji-72x72-colour-dds/1F604.dds",
		imageWidth = 50,
		imageHeight = 50,
		width = "half",
	},
	{
		type = "editbox",
		name = "Favourites Search Box",
		tooltip = "Enter the emote you would like to favourite here:",
		getFunc = function() return "" end,
		setFunc = function(value) d(value) end,
		isMultiline = false,
		reference = "EEFavSearch",
		width = "half",
	},
	]]
}

function ee.OpenSettings()
	LAM:OpenToPanel(panel)
end

function ee.InitSettingsMenu()
	settings = ee.GetVars()
	panel = LAM:RegisterAddonPanel(panelName, panelData)
	LAM:RegisterOptionControls(panelName, optionsData)
end
