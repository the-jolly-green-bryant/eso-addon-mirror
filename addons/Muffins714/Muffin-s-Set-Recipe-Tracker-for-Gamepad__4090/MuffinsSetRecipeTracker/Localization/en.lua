local strings = {
	-- Weapon Types
	MSRT_WEAPONTYPE1  = "Axe",
	MSRT_WEAPONTYPE2  = "Mace",
	MSRT_WEAPONTYPE3  = "Sword",
	MSRT_WEAPONTYPE4  = "Greatsword",
	MSRT_WEAPONTYPE5  = "Battle Axe",
	MSRT_WEAPONTYPE6  = "Maul",
	MSRT_WEAPONTYPE8  = "Bow",
	MSRT_WEAPONTYPE9  = "Healing Staff",
	MSRT_WEAPONTYPE11 = "Dagger",
	MSRT_WEAPONTYPE12 = "Inferno Staff",
	MSRT_WEAPONTYPE13 = "Ice Staff",
	MSRT_WEAPONTYPE14 = "Shield",
	MSRT_WEAPONTYPE15 = "Lightning Staff",


	-- MSRT Menu
	MSRT_Gen               = "General settings",
	MSRT_Set               = "Set settings",
	MSRT_Recipe            = "Recipe settings",
	MSRT_ItemSetBook       = "Item Set Book",
	MSRT_NICKNAMES         = "Character Nicknames",
	--Global settings
	MSRT_GLOBAL            = "Use the same settings for all characters?",
	MSRT_WARNING           = "Changing this will reload the UI.",

	-- Recipe settings
	MSRT_CHARMOTIF         = "Use selected character for motifs?",
	MSRT_CHARMOTIFTT       =
	"ON uses selected character. OFF uses current character.",
	MSRT_SELCHARMOTIF      = "Selected character for motifs",
	MSRT_SELCHARMOTIFTT    = "Pick which character's motifs to display when the checkbox is ON.",

	-- Nickname settings
	MSRT_USENICKNAMES      = "Use Character Nicknames?",
	MSRT_NICKNAMESTT       = "Set a nickname to show in the Known By list.",

	-- Set settings
	MSRT_HideSP            = "Hide individual Style Pages?",
	MSRT_HideSPtooltip     = "Only shows Completed(#/#) if style set is completed",
	MSRT_HideS             = "Hide individual sets?",
	MSRT_HideStooltip      = "Only shows Completed(#/#) if set is completed",

	MSRT_SetBook           = "Show set progress?",
	MSRT_SetBooktooltip    =
	"Show progress you have collected or are still missing.",

	MSRT_MythicBook        = "Show mythic fragments",
	MSRT_MythicBooktooltip = "Shows progress for antiquity fragments.",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
