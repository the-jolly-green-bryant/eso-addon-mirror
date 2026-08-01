local VPP 					= VisiblePickpocketPing
local control 				= VisiblePickpocketingIndicator
local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")

function VisiblePickpocketPing.CreateMenu(settings, defaults)

	local panelData = {
		type = "panel",
		name = "VisiblePickpocketPing",
		displayName = name,
	 	author = "manavortex",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	LAM:RegisterAddonPanel("VisiblePickpocketPing_OptionsPanel", panelData)

	local optionsData = { -- optionsData 
		{	-- checkbox: lock control
			type 	= "checkbox",
			name 	= "lock control",
			getFunc = function() return settings.locked end,
			setFunc = VisiblePickpocketPing.SetLocked,
		},		
		{	-- color picker: lock control
			type 	= "iconpicker",
			name 	= "icon",
			choices = {
				"esoui/art/treeicons/gamepad/gp_tutorial_idexicon_thievesguild.dds",
				"esoui/art/treeicons/tutorial_idexicon_thievesguild_down.dds",
				"esoui/art/icons/justice_stolen_pouch_003.dds",
				"esoui/art/icons/justice_stolen_key_002.dds",
				"esoui/art/tutorial/gamepad/achievement_categoryicon_justice.dds",
				"esoui/art/mail/gamepad/gp_mailmenu_requestgold.dds",
				"esoui/art/icons/memento_goldenaura.dds",
				"esoui/art/tutorial/journal_tabicon_quest_up.dds",
			},
			getFunc = function() return settings.icon end,
			setFunc = VisiblePickpocketPing.SetIcon,
		},
		{	-- header: Icon color
			type 	= "header",
			name 	= "icon color",
		},
		{	-- color picker: lock control
			type 	= "colorpicker",
			name 	= "hidden",
			tooltip	= "icon color when it's okay to pickpocket",
			getFunc = function() return settings.r, settings.g, settings.b, settings.a end,
			setFunc = VisiblePickpocketPing.SetColor,
		},
		{	-- checkbox: lock control
			type 	= "checkbox",
			name 	= "deactivate warning color",
			getFunc = function() return settings.noWarning end,
			setFunc = VisiblePickpocketPing.DeactivateWarningColor,
		},
		{	-- color picker: lock control
			type 		= "colorpicker",
			name 		= "not hidden",
			tooltip		= "when you're not fully hidden, the icon will have this color",
			getFunc 	= function() return settings.rVisible, settings.gVisible, settings.bVisible, settings.aVisible end,
			setFunc 	= VisiblePickpocketPing.SetColorVisible,
			deactivated = settings.noWarning,
		},

	}

	LAM:RegisterOptionControls("VisiblePickpocketPing_OptionsPanel", optionsData)

end
