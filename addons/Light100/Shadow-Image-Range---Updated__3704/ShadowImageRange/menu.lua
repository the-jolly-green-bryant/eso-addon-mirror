local SIR = ShadowImageRange
local LAM = LibAddonMenu2

function SIR.BuildMenu(SV, defaults)

	local panel = {
		type = 'panel',
		name = 'Shadow Image Range',
		displayName = 'Shadow Image Range',
		author = '|cFFFF00@andy.s|r',
		version = string.format('|c00FF00%s|r', SIR.GetVersion()),
		donation = 'https://www.esoui.com/downloads/info2311-HodorReflexes-DPSampUltimateShare.html#donate',
		registerForRefresh = true,
	}

	local options = {
		{
			type = "header",
			name = "|cFFFACDGeneral|r",
		},
		{
			type = "checkbox",
			name = "UI Locked",
			tooltip = 'Unlock UI to reposition controls.',
			getFunc = function() return SIR.IsLockedUI() end,
			setFunc = function(value)
				SIR.SetLockedUI(value or false)
			end
		},
		{
			type = "checkbox",
			name = "Show distance",
			tooltip = "Show distance to your shadow image in meters.",
			default = defaults.enableDistance,
			getFunc = function() return SV.enableDistance end,
			setFunc = function(value)
				SV.enableDistance = value or false
			end,
		},
		{
			type = "checkbox",
			name = "Show arrow",
			tooltip = "Show an arrow pointing to your shadow image.",
			default = defaults.enableArrow,
			getFunc = function() return SV.enableArrow end,
			setFunc = function(value)
				SV.enableArrow = value or false
			end,
		},
		{
			type = "checkbox",
			name = "Debug mode",
			tooltip = "Display internal events in the game chat.",
			default = false,
			getFunc = function() return SIR.IsDebugMode() end,
			setFunc = function(value)
				SIR.SetDebugMode(value or false)
			end,
		},
	}

	local name = SIR.GetName() .. 'Menu'
    LAM:RegisterAddonPanel(name, panel)
    LAM:RegisterOptionControls(name, options)

end