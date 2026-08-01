local LAM 							= LibAddonMenu2

function GROUP_SYNERGIZER.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Group Synergizer",
		displayName = "Scorps Group Synergizer",
		author = "Scorp",
		version = GROUP_SYNERGIZER.version,
		website = "https://www.esoui.com/downloads/info2286-GroupSynergizer-EnhancedLFGFeaturesAutoAcceptQueBetterNotifications.html",
		slashCommand = "/gs",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	local cntrlOptionsPanel = LAM:RegisterAddonPanel("GROUP_SYNERGIZER_Settings", panelData)
	
	local optionsData = {
		{
			type = "texture",
			image = "GroupSynergizer\\textures\\GroupSynergizerLogo.dds",
			imageWidth = 510,	--max of 250 for half width, 510 for full
			imageHeight = 100,	--max of 100
			--tooltip = "Group Synergizer Logo",	--(optional)
			width = "full",	--or "half" (optional)
		},
		{
			type = "divider",
			height = 15,
			alpha = 1.0,
			width = "full"
		},
		{
			type = "checkbox",
			name = GetString(SI_GROUP_SYNERGIZER_ENABLE),
			tooltip = GetString(SI_GROUP_SYNERGIZER_ENABLE_TT),
			default = true,
			getFunc = function() return GROUP_SYNERGIZER.savedVariables.Enable end,
			setFunc = function(newValue) 
				GROUP_SYNERGIZER.savedVariables.Enable = newValue
				GROUP_SYNERGIZER.Enable = newValue
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_GROUP_SYNERGIZER_SOUND),
			tooltip = GetString(SI_GROUP_SYNERGIZER_SOUND_TT),
			default = true,
			getFunc = function() return GROUP_SYNERGIZER.savedVariables.SoundNotify end,
			setFunc = function(newValue) 
				GROUP_SYNERGIZER.savedVariables.SoundNotify = newValue
				GROUP_SYNERGIZER.SoundNotify = newValue 
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_GROUP_SYNERGIZER_SCREEN),
			tooltip = GetString(SI_GROUP_SYNERGIZER_SCREEN_TT),
			default = true,
			getFunc = function() return GROUP_SYNERGIZER.savedVariables.ScreenNotify end,
			setFunc = function(newValue) 
				GROUP_SYNERGIZER.savedVariables.ScreenNotify = newValue
				GROUP_SYNERGIZER.ScreenNotify = newValue 
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_GROUP_SYNERGIZER_ENHANCE),
			tooltip = GetString(SI_GROUP_SYNERGIZER_ENHANCE_TT),
			default = true,
			getFunc = function() return GROUP_SYNERGIZER.savedVariables.EnhanceGAF end,
			setFunc = function(newValue) 
				GROUP_SYNERGIZER.savedVariables.EnhanceGAF = newValue
				GROUP_SYNERGIZER.EnhanceGAF = newValue 
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_GROUP_SYNERGIZER_ACCEPT),
			tooltip = GetString(SI_GROUP_SYNERGIZER_ACCEPT_TT),
			default = false,
			getFunc = function() return GROUP_SYNERGIZER.savedVariables.AutoAccept end,
			setFunc = function(newValue) 
				GROUP_SYNERGIZER.savedVariables.AutoAccept = newValue
				GROUP_SYNERGIZER.AutoAccept = newValue 
			end,
		},		
		{
			type = "checkbox",
			name = GetString(SI_GROUP_SYNERGIZER_RELEASE),
			tooltip = GetString(SI_GROUP_SYNERGIZER_RELEASE_TT),
			default = false,
			getFunc = function() return GROUP_SYNERGIZER.savedVariables.AutoRelease end,
			setFunc = function(newValue) 
				GROUP_SYNERGIZER.savedVariables.AutoRelease = newValue
				GROUP_SYNERGIZER.AutoRelease = newValue 
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_GROUP_SYNERGIZER_SLASH),
			tooltip = GetString(SI_GROUP_SYNERGIZER_SLASH_TT),
			default = true,
			warning = SI_GROUP_SYNERGIZER_SLASH_WARN,
			getFunc = function() return GROUP_SYNERGIZER.savedVariables.SlashCommands end,
			setFunc = function(newValue) 
				GROUP_SYNERGIZER.savedVariables.SlashCommands = newValue
				GROUP_SYNERGIZER.SlashCommands = newValue 
			end,
		},		
		{
			type = "slider",
			name = GetString(SI_GROUP_SYNERGIZER_DELAY),
			tooltip = GetString(SI_GROUP_SYNERGIZER_DELAY_TT),
			min = 1,
			max = 5,
			step = 1,
			default = 2,
			getFunc = function() return GROUP_SYNERGIZER.savedVariables.NotifyDelay end,
			setFunc = function(newValue) 
				GROUP_SYNERGIZER.savedVariables.NotifyDelay = newValue
				GROUP_SYNERGIZER.NotifyDelay = newValue
			end,
		},
		{
			type = "divider",
			height = 15,
			alpha = 1.0,
			width = "full"			
		},
		{
			type = "button",
			name = GetString(SI_GROUP_SYNERGIZER_FEEDBACK),
			func = function() MAIN_MENU_KEYBOARD:ShowScene("mailSend") MAIL_SEND:SetReply("@scorpius2k1", GROUP_SYNERGIZER.name) end,
			tooltip = GetString(SI_GROUP_SYNERGIZER_FEEDBACK_TT),
		},			
	}
	
	LAM:RegisterOptionControls("GROUP_SYNERGIZER_Settings", optionsData)
end
