local LAM 							= LibAddonMenu2

function COMBATPET_COOLDOWN.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Combat Pet Cooldown",
		displayName = "Scorps Combat Pet Cooldown",
		author = "Scorp",
		version = COMBATPET_COOLDOWN.version,
		website = "https://www.esoui.com/downloads/info3039-CombatPetCooldown.html",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	local cntrlOptionsPanel = LAM:RegisterAddonPanel("COMBATPET_COOLDOWN_Settings", panelData)
	
	local optionsData = {
		{
			type = "texture",
			image = "CombatPetCooldown\\textures\\CombatPetCooldownLogo.dds",
			imageWidth = 510,	--max of 250 for half width, 510 for full
			imageHeight = 100,	--max of 100
			--tooltip = "",	--(optional)
			width = "full",	--or "half" (optional)
		},
		{
			type = "checkbox",
			name = "Enable",
			tooltip = "Enable/Disable Combat Pet Cooldown",
			default = true,
			getFunc = function() return COMBATPET_COOLDOWN.savedVariables.enable end,
			setFunc = function(newValue) 
				COMBATPET_COOLDOWN.savedVariables.enable = newValue
				COMBATPET_COOLDOWN.enable = newValue
				COMBATPET_COOLDOWN.time = 0
			end,
		},
		{
			type = "slider",
			name = "Cooldown Time (Auto-Dismiss Combat Pets)",
			tooltip = "Maximum Amount Of Time (In Seconds) Before Combat Pets Are Dismissed If:\n• Not Moving\n• Not In Combat\n• Not In Delve/Dungeon/Trial",
			min = 30,
			max = 300,
			step = 5,
			default = 90,
			getFunc = function() return COMBATPET_COOLDOWN.savedVariables.cooldown end,
			setFunc = function(newValue) 
				COMBATPET_COOLDOWN.savedVariables.cooldown = newValue
				COMBATPET_COOLDOWN.cooldown = newValue
				COMBATPET_COOLDOWN.time = 0
			end,
		},
		{
			type = "description",
			title = "|cb7ff00Thank You!",
			text = "By using this addon, you are helping Tamriel be an even better place to adventure in.",
			width = "full",
		},		
	}
	
	LAM:RegisterOptionControls("COMBATPET_COOLDOWN_Settings", optionsData)
end