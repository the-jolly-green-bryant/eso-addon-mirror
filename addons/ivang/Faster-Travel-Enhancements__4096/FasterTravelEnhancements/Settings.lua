local Settings = {}
FasterTravelEnhancements.Settings = Settings

function Settings.Initialize(addon, savedVars)
	local panelData = {
		type = "panel",
		name = addon.name,
		displayName = addon.displayName,
		author = addon.author,
		version = addon.version,
		--website = addon.website,
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local optionsTable = {
		{
			type = "description",
			title = "Explanation",
			text = [[
			This addon adds some fixes and improvements for the original FasterTravel and can't work independently.
			Bellow a list of fixes / improvements:
			- Added option to disable (hide) keybindings on open map
			- Last choosed map tab saved and restore on the game restarts
			- Fixed right click on the favorites and recent wayshrines (show it on the map) in the FT wayshrine map tab (originaly it's broken)
			]],
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = "Hide FT keybindings on the map",
			default = false,
			tooltip =
			"When enabled - Faster Travel hot keys is not works on the map and dont displayed (some users has issues with them)",
			requiresReload = false,
			getFunc = function() return savedVars.hideMapKeybind end,
			setFunc = function(newValue) savedVars.hideMapKeybind = newValue end,
		},
	}

	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel(addon.name .. "Settings", panelData)
	LAM:RegisterOptionControls(addon.name .. "Settings", optionsTable)
end
