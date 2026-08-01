function EmoteShortcuts.CreateConfigMenuX()

    local panelData = {
        type = "panel",
        name = "EmoteShortcuts Config",
        displayName = "|c8080FFEmote Shortcuts|r",
        author = "Knut Hansen",
        version = tostring(EmoteShortcuts.version),
    }

    local optionsData = {
    -- GENERAL SECTION: 
        {
            type = "header",
            name = "Key Bindings",
        },
		{
			type = "editbox",
			name = "Emote 1",
			getFunc = function() return EmoteShortcuts.settings.emote[1] end,
			setFunc = function(value) EmoteShortcuts.settings.emote[1] = value end		
		},
		{
			type = "editbox",
			name = "Emote 2",
			getFunc = function() return EmoteShortcuts.settings.emote[2] end,
			setFunc = function(value) EmoteShortcuts.settings.emote[2] = value end		
		},
		{
			type = "editbox",
			name = "Emote 3",
			getFunc = function() return EmoteShortcuts.settings.emote[3] end,
			setFunc = function(value) EmoteShortcuts.settings.emote[3] = value end		
		},
		{
			type = "editbox",
			name = "Emote 4",
			getFunc = function() return EmoteShortcuts.settings.emote[4] end,
			setFunc = function(value) EmoteShortcuts.settings.emote[4] = value end		
		},
		{
			type = "editbox",
			name = "Emote 5",
			getFunc = function() return EmoteShortcuts.settings.emote[5] end,
			setFunc = function(value) EmoteShortcuts.settings.emote[5] = value end		
		},
		{
			type = "editbox",
			name = "Emote 6",
			getFunc = function() return EmoteShortcuts.settings.emote[6] end,
			setFunc = function(value) EmoteShortcuts.settings.emote[6] = value end		
		},
		{
			type = "editbox",
			name = "Emote 7",
			getFunc = function() return EmoteShortcuts.settings.emote[7] end,
			setFunc = function(value) EmoteShortcuts.settings.emote[7] = value end		
		},
		{
			type = "editbox",
			name = "Emote 8",
			getFunc = function() return EmoteShortcuts.settings.emote[8] end,
			setFunc = function(value) EmoteShortcuts.settings.emote[8] = value end		
		},
		{
			type = "editbox",
			name = "Emote 9",
			getFunc = function() return EmoteShortcuts.settings.emote[9] end,
			setFunc = function(value) EmoteShortcuts.settings.emote[9] = value end		
		},
		{
			type = "editbox",
			name = "Emote 10",
			getFunc = function() return EmoteShortcuts.settings.emote[10] end,
			setFunc = function(value) EmoteShortcuts.settings.emote[10] = value end		
		},		
    }

 -- local LAM2 = LibStub("LibAddonMenu-2.0")
    local LAM2 = LibAddonMenu2
    LAM2:RegisterAddonPanel(EmoteShortcuts.name.."Config", panelData)
    LAM2:RegisterOptionControls(EmoteShortcuts.name.."Config", optionsData)	

end