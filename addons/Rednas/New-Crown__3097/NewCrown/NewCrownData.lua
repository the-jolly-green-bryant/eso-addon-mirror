NewCrown = NewCrown or {}

NewCrown.Name = "NewCrown"
NewCrown.Version = "1.0.2"
NewCrown.Author = "Rednas"
NewCrown.VariableVersion = 1
NewCrown.DebugEnabled = false

NewCrown.LeaderIcon = ""	--Storing path to the icon if there is a special leader :)
NewCrown.IconPath = ""		--Storing the path to the current icon to be displayed
NewCrown.GroupSize = 0
NewCrown.InCombat = false
NewCrown.Location = "Overland"
NewCrown.CombatStateRegisterd = false
NewCrown.GroupEventsRegisterd = false

NewCrown.Panel = nil
NewCrown.WhenToActivateChoices = {"Always",	"Combat Only",	"Peace time only",	"Never"}

NewCrown.Icons = {
	"/esoui/art/compass/groupleader.dds",
	"/NewCrown/Textures/new_crown.dds",
	
	"/NewCrown/Textures/crown_border_blue.dds",
	"/NewCrown/Textures/crown_border_blue_bright.dds",
	"/NewCrown/Textures/crown_border_green.dds",
	"/NewCrown/Textures/crown_border_pink.dds",
	"/NewCrown/Textures/crown_border_red.dds",
	"/NewCrown/Textures/crown_border_white.dds",
	"/NewCrown/Textures/crown_border_yellow.dds",
	"/NewCrown/Textures/crown_border_yellow_dark.dds",
	
	"/NewCrown/Textures/crown_full_blue.dds",
	"/NewCrown/Textures/crown_full_blue_bright.dds",
	"/NewCrown/Textures/crown_full_green.dds",
	"/NewCrown/Textures/crown_full_pink.dds",
	"/NewCrown/Textures/crown_full_red.dds",
	"/NewCrown/Textures/crown_full_white.dds",
	"/NewCrown/Textures/crown_full_yellow.dds",
	"/NewCrown/Textures/crown_full_yellow_dark.dds",
		
	"/NewCrown/Textures/diamant_blue.dds",
	"/NewCrown/Textures/diamant_blue_bright.dds",
	"/NewCrown/Textures/diamant_green.dds",
	"/NewCrown/Textures/diamant_pink.dds",
	"/NewCrown/Textures/diamant_red.dds",
	"/NewCrown/Textures/diamant_white.dds",
	"/NewCrown/Textures/diamant_yellow.dds",
	"/NewCrown/Textures/diamant_yellow_dark.dds",
	
	"/NewCrown/Textures/gof_full_border_blue.dds",
	"/NewCrown/Textures/gof_full_border_blue_bright.dds",
	"/NewCrown/Textures/gof_full_border_green.dds",
	"/NewCrown/Textures/gof_full_border_pink.dds",
	"/NewCrown/Textures/gof_full_border_red.dds",
	"/NewCrown/Textures/gof_full_border_white.dds",
	"/NewCrown/Textures/gof_full_border_yellow.dds",
	"/NewCrown/Textures/gof_full_border_yellow_dark.dds",
	
	"/NewCrown/Textures/pin_blue.dds",
	"/NewCrown/Textures/pin_blue_bright.dds",
	"/NewCrown/Textures/pin_green.dds",
	"/NewCrown/Textures/pin_pink.dds",
	"/NewCrown/Textures/pin_red.dds",
	"/NewCrown/Textures/pin_white.dds",
	"/NewCrown/Textures/pin_yellow.dds",
	"/NewCrown/Textures/pin_yellow_dark.dds",
	
	"/NewCrown/Textures/skull_blue.dds",
	"/NewCrown/Textures/skull_blue_bright.dds",
	"/NewCrown/Textures/skull_green.dds",
	"/NewCrown/Textures/skull_pink.dds",
	"/NewCrown/Textures/skull_red.dds",
	"/NewCrown/Textures/skull_white.dds",
	"/NewCrown/Textures/skull_yellow.dds",
	"/NewCrown/Textures/skull_yellow_dark.dds",
	
	"/NewCrown/Textures/skull_crown_blue.dds",
	"/NewCrown/Textures/skull_crown_blue_bright.dds",
	"/NewCrown/Textures/skull_crown_green.dds",
	"/NewCrown/Textures/skull_crown_pink.dds",
	"/NewCrown/Textures/skull_crown_red.dds",
	"/NewCrown/Textures/skull_crown_white.dds",
	"/NewCrown/Textures/skull_crown_yellow.dds",
	"/NewCrown/Textures/skull_crown_yellow_dark.dds",
	
	"/NewCrown/Textures/finger_blue.dds",
	"/NewCrown/Textures/finger_blue_bright.dds",
	"/NewCrown/Textures/finger_green.dds",
	"/NewCrown/Textures/finger_pink.dds",
	"/NewCrown/Textures/finger_red.dds",
	"/NewCrown/Textures/finger_white.dds",
	"/NewCrown/Textures/finger_yellow.dds",
	"/NewCrown/Textures/finger_yellow_dark.dds",
}

NewCrown.DefaultSavedVars = {
	CurrentIcon = NewCrown.Icons[1],
	IconSize = 64,
	SpecialFeatureEnabled = true,
	WhenToActivate = NewCrown.WhenToActivateChoices[1],
	ActiveInOverland = true,
	ActiveInAvA = true,
	ActiveInDungeon = true,
	ActiveInTrial = true,
}

NewCrown.SavedVars = {}