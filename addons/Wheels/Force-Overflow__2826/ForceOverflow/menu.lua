ForceOverflow = ForceOverflow or { }
local fo = ForceOverflow

local LAM = LibAddonMenu2

function fo.setupMenu()
	local lockUI = true

	local panelData = {
		type = "panel",
		name = "Force Overflow",
		displayName = "|c00bbffF|rorce Overflow",
		author = "|cc2ff19Wheels|r",
		version = ""..fo.version,
		registerForRefresh = true,
	}

	LAM:RegisterAddonPanel(fo.name.."Options", panelData)

	local options = {
		{
			type = "header",
			name = "Display Options",
		},
		{
			type = "checkbox",
			name = "Lock Frame",
			tooltip = "Unlock to reposition the frame",
			getFunc = function() return lockUI end,
			setFunc = function(value)
				fo.ui.setDisplay(value)
				lockUI = value
			end
		},
	}

	LAM:RegisterOptionControls(fo.name.."Options", options)
end

