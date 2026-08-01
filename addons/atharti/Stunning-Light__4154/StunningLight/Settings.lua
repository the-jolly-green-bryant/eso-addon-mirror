local SL = StunningLight

function SL.RegisterLAMPanel()
    local LAM = LibAddonMenu2

    local SV = SL.SV 

    local soundChoices = {
        "ARMORY_SAVE_SUCCESS",
        "BATTLEGROUND_ROUND_RECAP_SCREEN_FINAL_WIN",
		"BATTLEGROUND_ROUND_RECAP_SCREEN_WIN",	
        "ENDLESS_DUNGEON_BUFF_ACQUIRE_VERSE",
		"ENDLESS_DUNGEON_BUFF_ACQUIRE_AVATAR_VISION",
		"ENDLESS_DUNGEON_BUFF_ACQUIRE_VISION",
		"CHAMPION_RESPEC_TOGGLED",
    }

    -- =========================
    -- Panel
    -- =========================
    local panelData = {
        type = "panel",
        name = "StunningLight",
        displayName = "|cFFD700Stunning Light|r",
        author = "|cFFD700@Atharti|r",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    -- =========================
    -- Options
    -- =========================
    local optionsData = {
        {
            type = "header",
            name = "General Settings",
        },
        {
            type = "checkbox",
            name = "Blur Effect on Stun",
            tooltip = "Apply fullscreen blur when stunned",
            getFunc = function() return SV.blurOnStun end,
            setFunc = function(value) SV.blurOnStun = value end,
            default = true,
        },
		{
			type = "checkbox",
			name = "Hide Game UI while Stunned/Feared/Charmed",
			tooltip = "Hides the game interface (action bars, chat, etc.) when affected. Charmed and Feared text alerts will not be visible if its ON.",
			getFunc = function() return SV.hideGameUI end,
			setFunc = function(value) SV.hideGameUI = value end,
			default = false,
		},
        {
            type = "checkbox",
            name = "Enable Sound",
            tooltip = "Play a sound when any effect triggers",
            getFunc = function() return SV.enableSound end,
            setFunc = function(value) SV.enableSound = value end,
            default = true,
        },
		{
			type = "dropdown",
			name = "Global Sound",
			tooltip = "Select which sound to play for all effects",
			choices = soundChoices,
			getFunc = function() return SV.globalSound end,
			setFunc = function(value) 
				SV.globalSound = value
				PlaySound(SOUNDS[value])
			end,
			default = "BATTLEGROUND_ROUND_RECAP_SCREEN_FINAL_WIN",
			disabled = function() return not SV.enableSound end,
		},
	    {
            type = "checkbox",
            name = "Text Alerts For Charm & Fear",
            tooltip = "Show on-screen text messages when feared or charmed",
            getFunc = function() return SV.enableTextAlerts end,
            setFunc = function(value) SV.enableTextAlerts = value end,
            default = true,
        },
		{
            type = "dropdown",
            name = "Alert Font Size",
            tooltip = "Select the font size for alert messages",
            choices = {24, 28, 30, 32, 34, 36, 40, 48, 54},
            getFunc = function() return SV.alertFontSize end,
            setFunc = function(value) 
                SV.alertFontSize = value
            end,
            default = 48,
            requiresReload = true,
        },

        {
            type = "header",
            name = "Fear Settings",
        },
        {
            type = "checkbox",
            name = "Track Fear",
            tooltip = "Show blur and announcement when feared",
            getFunc = function() return SV.trackFear end,
            setFunc = function(value) SV.trackFear = value end,
            default = true,
        },
		{
			type = "slider",
			name = "Fear Blur Duration (ms)",
			tooltip = "How long the blur effect lasts when feared (300ms to 1000ms)",
			min = 300,
			max = 1000,
			step = 100,
			getFunc = function() return SV.fearBlurDuration end,
			setFunc = function(value) SV.fearBlurDuration = value end,
			default = 1000,
			disabled = function() return not SV.trackFear end,
		},
        {
            type = "checkbox",
            name = "Enable Fear Sound",
            tooltip = "Play a sound when feared (overrides Global Sound)",
            getFunc = function() return SV.fearSoundEnabled end,
            setFunc = function(value) SV.fearSoundEnabled = value end,
            default = true,
            disabled = function() return not SV.trackFear end,
        },
        {
            type = "dropdown",
            name = "Fear Sound",
            tooltip = "Select sound to play when feared",
            choices = soundChoices,
            getFunc = function() return SV.fearSound end,
            setFunc = function(value)
     			SV.fearSound = value
				PlaySound(SOUNDS[value])
			end,
            default = "BATTLEGROUND_ROUND_RECAP_SCREEN_FINAL_WIN",
            disabled = function() return not SV.trackFear or not SV.fearSoundEnabled end,
        },

        {
            type = "header",
            name = "Charm Settings",
        },
        {
            type = "checkbox",
            name = "Track Charm",
            tooltip = "Show blur and announcement when charmed",
            getFunc = function() return SV.trackCharm end,
            setFunc = function(value) SV.trackCharm = value end,
            default = true,
        },
		{
			type = "slider",
			name = "Charm Blur Duration (ms)",
			tooltip = "How long the blur effect lasts when charmed (300ms to 1000ms)",
			min = 300,
			max = 1000,
			step = 100,
			getFunc = function() return SV.charmBlurDuration end,
			setFunc = function(value) SV.charmBlurDuration = value end,
			default = 1000,
			disabled = function() return not SV.trackCharm end,
		},
        {
            type = "checkbox",
            name = "Enable Charm Sound",
            tooltip = "Play a sound when charmed (overrides Global Sound)",
            getFunc = function() return SV.charmSoundEnabled end,
            setFunc = function(value) SV.charmSoundEnabled = value end,
            default = true,
            disabled = function() return not SV.trackCharm end,
        },
        {
            type = "dropdown",
            name = "Charm Sound",
            tooltip = "Select sound to play when charmed",
            choices = soundChoices,
            getFunc = function() return SV.charmSound end,
            setFunc = function(value)
			    SV.charmSound = value
				PlaySound(SOUNDS[value])
			end,			
            default = "BATTLEGROUND_ROUND_RECAP_SCREEN_FINAL_WIN",
            disabled = function() return not SV.trackCharm or not SV.charmSoundEnabled end,
        },
    }

    LAM:RegisterAddonPanel("StunningLightPanel", panelData)
    LAM:RegisterOptionControls("StunningLightPanel", optionsData)
end