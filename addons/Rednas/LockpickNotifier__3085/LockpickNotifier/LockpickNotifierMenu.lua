LPN = LPN or {}

function LPN.OnGetActiveInGroupDungeonCheckbox()
	return LPN.savedVars.activeInGroupDungeons
end

function LPN.OnSetActiveInGroupDungeonCheckbox(value)
	LPN.savedVars.activeInGroupDungeons = value
end

function LPN.OnGetActiveInTrialCheckbox()
	return LPN.savedVars.activeInTrials
end

function LPN.OnSetActiveInTrialCheckbox(value)
	LPN.savedVars.activeInTrials = value
end

function LPN.OnGetTextEditbox()
	return LPN.savedVars.messageText
end

function LPN.OnSetTextEditbox(value)
	LPN.savedVars.messageText = value
end

function LPN.OnGetTextDifficultyEditbox(difficulty)
	return LPN.savedVars.chestDifficultyName[difficulty]
end

function LPN.OnSetTextDifficultyEditbox(value, difficulty)
	LPN.savedVars.chestDifficultyName[difficulty] = value
end


--Set the menu
function LPN.SetupMenu()

	local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
		name = "Lockpick Notifier",
		displayName = "Lockpick Notifier!",
		author = LPN.author,
		version = LPN.version,
		slashCommand = "/lpn"
    }
    LAM:RegisterAddonPanel("LockpickNotifierMenu", panelData)

    local optionsData = {
		{
			type = "checkbox",
			name = "Active in group dungeons:",
			getFunc = LPN.OnGetActiveInGroupDungeonCheckbox,
			setFunc = LPN.OnSetActiveInGroupDungeonCheckbox,
			width = "half",
		},
		{
			type = "checkbox",
			name = "Active in trials:",
			getFunc = LPN.OnGetActiveInTrialCheckbox,
			setFunc = LPN.OnSetActiveInTrialCheckbox,
			width = "half",
		},
		{
			type = "submenu",
			name = "Edit the text (advanced)",
			controls = {
				{
					type = "editbox",
					name = "Set the text:",
					getFunc = LPN.OnGetTextEditbox,
					setFunc = LPN.OnSetTextEditbox,
					width = "full",
					isExtraWide = true,
				},
				{
					type = "description",
					text = "Use %s for the chest difficulty",
					width = "full",	
				},
				{
					type = "editbox",
					name = "Text for Simple:",
					getFunc = function() return LPN.OnGetTextDifficultyEditbox(1) end,
					setFunc = function(value) LPN.OnSetTextDifficultyEditbox(value, 1) end,
					width = "half",
					isExtraWide = true,
				},
				{
					type = "editbox",
					name = "Text for Intermediate:",
					getFunc = function() return LPN.OnGetTextDifficultyEditbox(2) end,
					setFunc = function(value) LPN.OnSetTextDifficultyEditbox(value, 2) end,
					width = "half",
					isExtraWide = true,
				},
				{
					type = "editbox",
					name = "Text for Advanced:",
					getFunc = function() return LPN.OnGetTextDifficultyEditbox(3) end,
					setFunc = function(value) LPN.OnSetTextDifficultyEditbox(value, 3) end,
					width = "half",
					isExtraWide = true,
				},
				{
					type = "editbox",
					name = "Text for Master:",
					getFunc = function() return LPN.OnGetTextDifficultyEditbox(4) end,
					setFunc = function(value) LPN.OnSetTextDifficultyEditbox(value, 4) end,
					width = "half",
					isExtraWide = true,
				},
				
			}
		}
    }
	
    LAM:RegisterOptionControls("LockpickNotifierMenu", optionsData)
end