
local LAM2 = LibAddonMenu2

local colorYellow 		= "|cFFFF00" 	-- yellow 
local colorRed 			= "|cFF0000" 	-- Red


--===================================--
--=====   Settings Menu   ===========--
--===================================--
function PvPRanks.CreateSettingsMenu()
	local panelData = {
		type = "panel",
		name = "PvPRanks",
		displayName = "|cFF0000 Circonians |c00FFFF PvPRanks",
		author = "Circonian",
		version = PvPRanks.RealVersion,
		slashCommand = "/pvpranks",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Circonians_PvPRanks_Options", panelData)
	
	local optionsData = {
		[1] = {
			type = "description",
			text = colorYellow.."If you wish to submit a bug report or feature request please do so on my PORTAL page. Go to the addons web page & clock on Portal, Bugs, or Feature (under the download button)."
		},
		[2] = {
			type = "colorpicker",
			name = "Show Extra Background",
			tooltip = "Changes the highlight color for your current rank.",
			default = true,
			getFunc = function() return unpack(self.sv["RANK_HIGHLIGHT_COLOR"]) end,
			setFunc = function(r,g,b,a) self.sv["RANK_HIGHLIGHT_COLOR"] = {r,g,b,a} end,
		},
	}
	LAM2:RegisterOptionControls("Circonians_PvPRanks_Options", optionsData)
end