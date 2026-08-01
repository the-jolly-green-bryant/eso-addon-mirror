

local panelKill = {
	type = "panel",
	name = "PvP Meter",
	displayName = "PvP Meter",
	author = "|cFFC300@amuridee|r, marig63, Baertram",
	version = "3.0",
	registerForDefaults = true,
			--version = ADDON_VERSION,
	slashCommand = "/PvpMeter",
	}

local optionsKill = {
	
	[1] = {
		type = "header",
		name = "General Settings",
	},
	
	[2] = {
		type = "checkbox",
		name = "Auto accept queue",
		tooltip = "Auto accept queue for Battleground and Cyrodiil",
		default = true,
		getFunc = function() return PvpMeter.savedVariables.autoqueue end,
		setFunc = function(val) PvpMeter.savedVariables.autoqueue = val 
		end,
	},
	
	[3] = {
		type = "checkbox",
		name = "Show Meter in Battleground and Cyrodiil",
		tooltip = "Show Meter in Battleground and Cyrodiil",
		default = true,
		getFunc = function() return PvpMeter.savedVariables.showBeautifulMeter end,
		setFunc = function(val) PvpMeter.savedVariables.showBeautifulMeter = val 
			if(val)then
				--HUDTelvarMeter_show()
			else
				--HUDTelvarMeter_hide()
			end
		end,
	},
	
	[4] = {
		type = "dropdown",
		name = "Meter Rotation", -- or string id or function returning a string
		choices = {"Bot-Right", "Bot-Left", "Top-Left","Top-Right"},
		choicesValues = {1, 2, 3, 4 }, 
		getFunc = function() return PvpMeter.savedVariables.rotation end,
		setFunc = function(var) PvpMeter.savedVariables.rotation = var 
			PvpMeter.rotateMeter(var)
		end,
	},

	[5] = {
		type = "checkbox",
		name = "AP of the current session",
		tooltip = "show just AP of the current session",
		default = true,
		getFunc = function() return PvpMeter.savedVariables.currAP end,
		setFunc = function(val) PvpMeter.savedVariables.currAP = val 
			PvpMeter.updateAP()
		end,
	},
	
	[6] = {
		type = "dropdown",
		name = "Cyrodiil meter bar", -- or string id or function returning a string
		choices = {"Percentage of keeps capture","Xp progress to next pvp level"},
		choicesValues = {0, 2}, 
		getFunc = function() return PvpMeter.savedVariables.nbrCyro end,
		setFunc = function(var) PvpMeter.savedVariables.nbrCyro = var  
								PvpMeter.updateMeter()
		end,
	},
	
	[7] = {
		type = "checkbox",
		name = "Show assist in Battleground",
		tooltip = "Show assist in Battleground",
		default = true,
		getFunc = function() return PvpMeter.savedVariables.BGAssist end,
		setFunc = function(val) PvpMeter.savedVariables.BGAssist = val 
			if(val and PvpMeter.inBG)then
				LabelAssist:SetHidden(false)
			else
				LabelAssist:SetHidden(true)
			end
		end,
	},	
	
	[8] = {
		type = "checkbox",
		name = "Kill alert border",
		tooltip = "little animation on border of the screen when you kill an ennemy",
		default = true,
		getFunc = function() return PvpMeter.savedVariables.alertBorder end,
		setFunc = function(val) PvpMeter.savedVariables.alertBorder = val end,
	},
	
	[9] = {
		type = "checkbox",
		name = "Kill sound",
		tooltip = "Play a little sound when you kill an enemy",
		default = true,
		getFunc = function() return PvpMeter.savedVariables.playSound end,
		setFunc = function(val) PvpMeter.savedVariables.playSound = val end,
	},
	
	[10] = {
		type = "dropdown",
		name = "Choice kill sound", -- or string id or function returning a string
		choices = {"Lockpicking", "Crowned"},
		choicesValues = {0, 1, }, 
		getFunc = function() return PvpMeter.savedVariables.nbrSound end,
		setFunc = function(var) PvpMeter.savedVariables.nbrSound = var  end,
	},
	
	[11] = {
	 	type = "button",
		name = "Test sound",
		tooltip = "",
		width = "full",
		func = function()
	      if(PvpMeter.savedVariables.nbrSound == 0)then
				PlaySound(SOUNDS.LOCKPICKING_SUCCESS_CELEBRATION)
			end
			if(PvpMeter.savedVariables.nbrSound == 1)then
				PlaySound(SOUNDS.EMPEROR_CORONATED_EBONHEART)
			end
		end,
	},
	
	[12] = {
		type = "checkbox",
		name = "Show button for Cyrodiil queue in the chat ",
		tooltip = "Button of home campaign in Cyrodiil",
		default = true,
		getFunc = function() return PvpMeter.savedVariables.quickButton end,
		setFunc = function(val) PvpMeter.savedVariables.quickButton = val 
			PvpMeter.updateButtonQuick() 
		
		end,
	},	
	
	[13] = {
		type = 'slider',
		name = "Change position of the button",
		tooltip = "Slide for change position of the button",
		min = 10,
		max = 200,
		step = 10,
		default = 200,
		getFunc = function() return PvpMeter.savedVariables.chat end,
		setFunc = function(val) PvpMeter.savedVariables.chat = val end,
		warning = "Reload UI required",
	},
	
	[14] = {
      type = "button",
      name = "Reload UI",
      func = function() ReloadUI() end
    },
}

function PvpMeter.initSettings()
	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel("IHateYou", panelKill)
	LAM:RegisterOptionControls("IHateYou", optionsKill)
end

