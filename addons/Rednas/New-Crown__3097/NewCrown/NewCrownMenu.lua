NewCrown = NewCrown or {}

--Icon Picker
function NewCrown.OnGetIconsDropdown()
	return NewCrown.SavedVars.CurrentIcon
end

function NewCrown.OnSetIconsDropdown(value)
	NewCrown.SavedVars.CurrentIcon = value
	NewCrown.UpdateCrown()
end

---Size Slider
function NewCrown.OnGetSizeSlider()
	return NewCrown.SavedVars.IconSize
end

function NewCrown.OnSetSizeSlider(value)
	NewCrown.SavedVars.IconSize = value
	NewCrown.UpdateCrown()
end

--Special Feature
function NewCrown.OnGetEnableSpecialFeatureCheckbox()
	return NewCrown.SavedVars.SpecialFeatureEnabled
end

function NewCrown.OnSetEnableSpecialFeatureCheckbox(value)
	NewCrown.SavedVars.SpecialFeatureEnabled = value
	NewCrown.RegisterUnregisterGroupEvents()
	NewCrown.CheckNewLeader()
	NewCrown.UpdateCrown()
end

--When to Activate
function NewCrown.OnGetWhenToActivateDropdown()
	return NewCrown.SavedVars.WhenToActivate
end

function NewCrown.OnSetWhenToActivateDropdown(value)
	NewCrown.SavedVars.WhenToActivate = value
	NewCrown.RegisterUnregisterPlayerCombatState()
	NewCrown.UpdateCrown()
end

--Active In Overland
function NewCrown.OnGetActiveInOverlandCheckbox()
	return NewCrown.SavedVars.ActiveInOverland
end

function NewCrown.OnSetActiveInOverlandCheckbox(value)
	NewCrown.SavedVars.ActiveInOverland = value
	NewCrown.UpdateCrown()
end

--Active In Cyrodiil
function NewCrown.OnGetActiveInAvACheckbox()
	return NewCrown.SavedVars.ActiveInAvA
end

function NewCrown.OnSetActiveInAvACheckbox(value)
	NewCrown.SavedVars.ActiveInAvA = value
	NewCrown.UpdateCrown()
end

--Active In Dungeon
function NewCrown.OnGetActiveInDungeonCheckbox()
	return NewCrown.SavedVars.ActiveInDungeon
end

function NewCrown.OnSetActiveInDungeonCheckbox(value)
	NewCrown.SavedVars.ActiveInDungeon = value
	NewCrown.UpdateCrown()
end

--Active In Trial
function NewCrown.OnGetActiveInTrialCheckbox()
	return NewCrown.SavedVars.ActiveInTrial
end

function NewCrown.OnSetActiveInTrialCheckbox(value)
	NewCrown.SavedVars.ActiveInTrial = value
	NewCrown.UpdateCrown()
end

--Set the menu
function NewCrown.SetupMenu()
	NewCrown.DebugMessage("Setting SettingsMenu...")

	local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
		name = "NewCrown",
		displayName = "New Crown! Make the crown visible",
		author = NewCrown.Author,
		version = NewCrown.Version,
		slashCommand = "/newcrown"
    }
    NewCrown.Panel = LAM:RegisterAddonPanel("NewCrownMenu", panelData)

    local optionsData = {
        {
			type = "description",
			text = "With this add-on you can add a bigger crown to the Trial/Group leader and it even lets you adjust the size, icon and some other settings. Initially made for the Guild: |c2eb82eGathering of Friends|r, you are welcome to say hi! \nSpecial thanks to: |cc9b449@MissCoko|r, for making nearly all of the icons",
			width = "full",	
		},
		{
			type = "divider",
		},
		{
			type = "iconpicker",
			name = "Pick a New Crown:",
			choices = NewCrown.Icons,
			getFunc = NewCrown.OnGetIconsDropdown,
			setFunc = NewCrown.OnSetIconsDropdown,
			width = "full",
			iconSize = 36,
			maxColumns = 6,
			visibleRows = 5.5,
			reference = "NCIconPicker",
		},
		{
			type = "slider",
			name = "What size should the crown be?",
			min = 10,
			max = 250,
			step = 1,
			getFunc = NewCrown.OnGetSizeSlider,
			setFunc = NewCrown.OnSetSizeSlider,
			width = "full",
			reference = "NCSizeSlider",
		},
		{
			type = "submenu",
			name = "When is it enabled?",
			controls = {
				{
					type = "dropdown",
					name = "When to activate?",
					getFunc = NewCrown.OnGetWhenToActivateDropdown,
					setFunc = NewCrown.OnSetWhenToActivateDropdown,
					choices = NewCrown.WhenToActivateChoices,
					width = "full",
				},
				{
					type = "checkbox",
					name = "Active in trials",
					getFunc = NewCrown.OnGetActiveInTrialCheckbox,
					setFunc = NewCrown.OnSetActiveInTrialCheckbox,
					width = "half",
				},
				{
					type = "checkbox",
					name = "Active in dungeons",
					getFunc = NewCrown.OnGetActiveInDungeonCheckbox,
					setFunc = NewCrown.OnSetActiveInDungeonCheckbox,
					width = "half",
				},
				{
					type = "checkbox",
					name = "Active in overland",
					getFunc = NewCrown.OnGetActiveInOverlandCheckbox,
					setFunc = NewCrown.OnSetActiveInOverlandCheckbox,
					width = "half",
				},
				{
					type = "checkbox",
					name = "Active in Cyrodiil & Imperial City",
					getFunc = NewCrown.OnGetActiveInAvACheckbox,
					setFunc = NewCrown.OnSetActiveInAvACheckbox,
					width = "half",
				},
			},
		},
        {
            type = "checkbox",
            name = "Enable special thank you feature",
            getFunc = NewCrown.OnGetEnableSpecialFeatureCheckbox,
            setFunc = NewCrown.OnSetEnableSpecialFeatureCheckbox,
			width = "full",
			tooltip = "This displays a unique icon above the leader, when it's someone who helped me with the add-on (mostly pre-release) and/or getting started with the game. This feature is my way of a thank you, thats why I didn't remove it. If you always want to see the icon you choose, you can always disable this in the settings, without any drawbacks!",
        },
    }
	
    LAM:RegisterOptionControls("NewCrownMenu", optionsData)
	
	NewCrown.DebugMessage("SettingsMenu set!")
end