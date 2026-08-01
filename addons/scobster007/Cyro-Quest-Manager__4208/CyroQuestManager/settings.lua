CyroQuestManager = CyroQuestManager or {}
local CQM = CyroQuestManager

function CQM.initMenu()
	local LAM2 = LibAddonMenu2
	local panelData = {
		type = "panel",
		name = "Cyro Quest Manager",
		author = "Scobster007",
		version = "1",
		registerForRefresh = true,
		registerForDefaults = true
	}
	LAM2:RegisterAddonPanel("CyroQuestManager", panelData)

	local optionsData = {
		{
			type = "editbox",
			name = "Group 1 Leader",
			getFunc = function() return CQM.svChar.Leader1 end,
			setFunc = function(value) CQM.svChar.Leader1=CQM.checkUsername(value) end,
			default = CQM.svCharDef.Leader1,
			width = "full",
			requiresReload = false,
		},
		{
			type = "editbox",
			name = "Auto Invite 1",
			getFunc = function() return CQM.svChar.AutoInv1 end,
			setFunc = function(value) CQM.svChar.AutoInv1=value end,
			default = CQM.svCharDef.AutoInv1,
			width = "full",
			requiresReload = false,
		},
		{
			type = "editbox",
			name = "Group 2 Leader",
			getFunc = function() return CQM.svChar.Leader2 end,
			setFunc = function(value) CQM.svChar.Leader2=CQM.checkUsername(value) end,
			default = CQM.svCharDef.Leader2,
			width = "full",
			requiresReload = false,
		},
		{
			type = "editbox",
			name = "Auto Invite 2",
			getFunc = function() return CQM.svChar.AutoInv2 end,
			setFunc = function(value) CQM.svChar.AutoInv2=value end,
			default = CQM.svCharDef.AutoInv2,
			width = "full",
			requiresReload = false,
		},
		{
			type = "checkbox",
			name = "Auto Share Quests On Member Join",
			getFunc = function() return CQM.svChar.AutoShare end,
			setFunc = function(value) CQM.svChar.AutoShare=value end,
			default = CQM.svCharDef.AutoShare,
			width = "full",
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = "Show Cyrodiil Quest Menu",
			getFunc = function() return CQM.svChar.bShowQuestMenu end,
			setFunc = function(value) CQM.svChar.bShowQuestMenu = value end,
			default = CQM.svCharDef.bShowQuestMenu,
			width = "full",
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = "Auto Drop 'Kill 150 Players' Quest",
			getFunc = function() return CQM.svChar.bAutoDrop150 end,
			setFunc = function(value) CQM.svChar.bAutoDrop150 = value end,
			default = CQM.svCharDef.bAutoDrop150,
			width = "full",
			requiresReload = false,
		},
		{
			type = "checkbox",
			name = "Auto Drop 'Capture all 3 Towns' Quest",
			getFunc = function() return CQM.svChar.bAutoDropTowns end,
			setFunc = function(value) CQM.svChar.bAutoDropTowns = value end,
			default = CQM.svCharDef.bAutoDropTowns,
			width = "full",
			requiresReload = false,
		},
		{
			type = "checkbox",
			name = "Auto Drop 'Kill Enemy (Class)' Quests",
			getFunc = function() return CQM.svChar.bAutoDropClasses end,
			setFunc = function(value) CQM.svChar.bAutoDropClasses = value end,
			default = CQM.svCharDef.bAutoDropClasses,
			width = "full",
			requiresReload = false,
		},
	}
	LAM2:RegisterOptionControls("CyroQuestManager", optionsData)
end