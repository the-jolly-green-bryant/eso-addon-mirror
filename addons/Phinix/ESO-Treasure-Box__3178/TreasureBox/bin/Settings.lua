local TBoxAddon = _G['TBoxAddon']
local L = TBoxAddon:GetLanguage()
local pTC = TBoxAddon.TColor
local Defaults = TBoxAddon.DB.DefaultVars()

------------------------------------------------------------------------------------------------------------------------------------
-- Set up the options panel in Addon Settings
------------------------------------------------------------------------------------------------------------------------------------
function TBoxAddon.DB.CreateSettingsWindow(addonName, version)
	local panelData = {
		type					= "panel",
		name					= "ESO Treasure Box",
		displayName				= pTC("FEE854", "ESO ")..pTC("FF9900", "Treasure Box"),
		author					= pTC("66ccff", "Phinix"),
		version					= version,
		registerForRefresh		= true,
		registerForDefaults		= true,
	}

	local optionsData = {
------------------------------------------------------------------------------------------------------------------------------------
-- General Settings
------------------------------------------------------------------------------------------------------------------------------------
	{
		type			= "header",
		name			= ZO_HIGHLIGHT_TEXT:Colorize(L.TBoxAddon_GOPTS),
	},
	{
		type			= "checkbox",
		name			= L.TBoxAddon_USTIME,
		tooltip			= L.TBoxAddon_USTIMET,
		getFunc			= function() return TBoxAddon.ASV.aOpts.USTime end,
		setFunc			= function(value) TBoxAddon.ASV.aOpts.USTime = value end,
		width			= "full",
		default			= Defaults.USTime,
	},
	{
		type			= "checkbox",
		name			= L.TBoxAddon_CHARALPHA,
		tooltip			= L.TBoxAddon_CHARALPHAT,
		getFunc			= function() return TBoxAddon.ASV.aOpts.charSortAlpha end,
		setFunc			= function(value)
							TBoxAddon.ASV.aOpts.charSortAlpha = value
							TBoxAddon.XMLNavigation(107)
						end,
		width			= "full",
		default			= Defaults.charSortAlpha,
	},
	}

	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel("TBoxAddon_Panel", panelData)
	LAM:RegisterOptionControls("TBoxAddon_Panel", optionsData)
end
