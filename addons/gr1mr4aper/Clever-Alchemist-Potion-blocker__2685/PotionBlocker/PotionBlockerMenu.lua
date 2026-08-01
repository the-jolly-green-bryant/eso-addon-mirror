PotionBlocker = PotionBlocker or { }
local pot = PotionBlocker

function pot.setupMenu()
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = "Clever Alchemist Potion Blocker",
		displayName = "|cFFD700 Clever Alchemist Potion Blocker|r",
		author = "Gr1mr4aper",
		version = ""..pot.version, 
		registerForRefresh = true  
	}

	LAM:RegisterAddonPanel(pot.name.."Options", panelData)
 
	local options = {
		{ 
			type = "header", 
			name = "Options"
		},
		{
			type = "checkbox",
			name = "Hide timer",
			tooltip = "Always hide the timer",
			requiresReload = true,
			getFunc = function() return pot.savedVariables.hideTimer end,
			setFunc = function(value)
				pot.savedVariables.hideTimer = value
			end
		},
		{
			type = "checkbox",
			name = "Only Display In Combat",
			tooltip = "Only displays timer when the player is in combat",
			warning = "for this to work hide timer has to be off",
			requiresReload = true,
			getFunc = function() return pot.savedVariables.passiveHide end,
			setFunc = function(value)
				pot.savedVariables.passiveHide = value
				pot.hideOutOfCombat()
			end
		},
		{
			type = "slider",
			name = "Text Size",
			tooltip = "Size of the displayed timer",
			min = 10,
			max = 32,
			getFunc = function() return pot.savedVariables.timerSize end,
			setFunc = function(value)
				if value then	
					pot.savedVariables.timerSize = value
					pot.defaults = value
					pot.setFontSize(value)
				end
			end
		},
		{
			type = "colorpicker",
			name = "Available Color",
			tooltip = "Color of timer when clever alchemist proc is available",
			requiresReload = true,
			getFunc = function() return unpack(pot.savedVariables.colourUp) end,
			setFunc = function(r,g,b,a) pot.savedVariables.colourUp = {r,g,b,a} end,
		},
		{
			type = "colorpicker",
			name = "Cooldown Color",
			tooltip = "Color of timer when clever alchemist proc is currently on cooldown",
			requiresReload = true,
			getFunc = function() return unpack(pot.savedVariables.colourDown) end,
			setFunc = function(r,g,b,a) pot.savedVariables.colourDown = {r,g,b,a} end,
		},
	}

	LAM:RegisterOptionControls(pot.name.."Options", options)
end
