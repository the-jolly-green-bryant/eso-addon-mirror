ToggleStatus = ToggleStatus or { }
local ts = ToggleStatus

local LAM = LibAddonMenu2

function ts.setupMenu()
	local lockUI = true

	local panelData = {
		type = "panel",
		name = "Toggle Status",
		displayName = "|c4719ffToggle|r |c7040ffStatus|r",
		author = "|cc2ff19Wheels|r",
		version = ""..ts.version,
		registerForRefresh = true,
	}

	LAM:RegisterAddonPanel(ts.name.."OPTIONS", panelData)

	local options = {
		{
			type = "header",
			name = "Display Options",
		},
		{
			type = "description",
			text = "The UI will be displayed when simmering is toggled on, and will persist until the player leaves combat.",
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = "Lock Frame",
			tooltip = "Unlock to reposition the frame",
			getFunc = function() return lockUI end,
			setFunc = function(value)
				ts.ui.setDisplay(value)
				lockUI = value
			end
		},
	}

	LAM:RegisterOptionControls(ts.name.."OPTIONS", options)
end

