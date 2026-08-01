--------------------------------------------------
-- Initialize Settings Menu (Uses LibAddonMenu2)
--------------------------------------------------
function BountyTimer.InitializeSettingsMenu()
	if BountyTimer.debug then d("Settings Menu") end

	--------------------------------------------------
	-- Initialize tables used to provide menu settings
	--------------------------------------------------
	local iconDropdownOptions ={}
	for key, value in ipairs(BountyTimer.iconList) do
		iconDropdownOptions[key] = value.description
	end

	local fontNamesDropdownOptions = {}
	for key, value in ipairs(BountyTimer.fontNames) do
		fontNamesDropdownOptions[key] = value.name
	end
	
	--------------------------------------------------
	-- Initialize LibAddonMenu2 table and variables
	--------------------------------------------------
	local LAM = LibAddonMenu2
	local saveData = BountyTimer.savedVariables
	local callDelay = BountyTimer.callDelay
	local panelName = "BountyTimerSettingsPanel"
	
	--------------------------------------------------
	-- Initialize settings panel info
	--------------------------------------------------
	local panelData = {
		type = "panel",
		name = "Bounty Timer",
		displayName = "|c00E600Bounty Timer|r",
		author = "|c787878ShadowMau|r",
		registerForRefresh = true
	}
	local panel = LAM:RegisterAddonPanel(panelName, panelData)
	
	--------------------------------------------------
	-- Table to specify the options used to provide menu settings
	--------------------------------------------------
	local optionsData = {
		[1] = {
			type = "checkbox",
			name = "Move bounty timer:",
			tooltip = "",
			getFunc = function() return BountyTimer.savedVariables.lockWindow end,
			setFunc = function(value) BountyTimer.savedVariables.lockWindow = value BountyTimer.OptionSet() end
		},
		[2] = {
			type = "checkbox",
			name = "Hide in-game bounty meter:",
			tooltip = "",
			getFunc = function() return BountyTimer.savedVariables.hideOriginal end,
			setFunc = function(value) BountyTimer.savedVariables.hideOriginal = value BountyTimer.OptionSet() end
		},
		[3] = {
			type = "dropdown",
			name = "Kill On Sight Icon:",
			tooltip = "",
			choices = iconDropdownOptions,
			getFunc = function() return BountyTimer.iconList[BountyTimer.savedVariables.icon].description end,
			setFunc = function(value) BountyTimer.SetIcon(value) end
		},
		[4] = {
			type = "slider",
			name = "Set font size:",
			min = 10,
			max = 50,
			readOnly = true,
			getFunc = function() return BountyTimer.savedVariables.fontSize end,
			setFunc = function(value) BountyTimer.savedVariables.fontSize = value BountyTimer.SetFont() end
		},
		[5] = {
			type = "dropdown",
			name = "Font Type: ",
			tooltip = "",
			choices = fontNamesDropdownOptions,
			getFunc = function() return BountyTimer.fontNames[BountyTimer.savedVariables.fontName].name end,
			setFunc = function(value) BountyTimer.SetFontName(value) BountyTimer.SetFont() end
		},
		[6] = {
			type = "checkbox",
			name = "Show Timer",
			tooltip = "Turn the bounty timer on so it can be moved, or to adjust the background color.",
			getFunc = function() return BountyTimer.showWindow end,
			setFunc = function(value) BountyTimer.SetShowing(value) end,
		},
		[7] = {
			type = "colorpicker",
			name = "Background Colorpicker:",
			tooltip = "",
			getFunc = function() local r, g, b, a = BountyTimer.GetBackground() return r, g, b, a end,
			setFunc = function(r, g, b, a) BountyTimer.SetBackground(r, g, b, a) end
		}
		
	}

	LAM:RegisterOptionControls(panelName, optionsData)
end