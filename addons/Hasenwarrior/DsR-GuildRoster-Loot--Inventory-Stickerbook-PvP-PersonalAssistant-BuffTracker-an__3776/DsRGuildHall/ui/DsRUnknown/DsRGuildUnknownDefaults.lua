-- Create namespace
DsRGuildUnknownDefaults = {}
local DsRGuildUnknownDefaults = DsRGuildUnknownDefaults  or {}

DsRGuildUnknownDefaults.name = "DsRGuildUnknownDefaults"

DsRGuildUnknown_LEARNING     = GetString(DsRGuildUnknown_MenuLearning)
DsRGuildUnknown_NOT_LEARNING = GetString(DsRGuildUnknown_MenuLearningNot)
DsRGuildUnknown_ALL_LEARNING = GetString(DsRGuildUnknown_MenuLearningAll)
DsRGuildUnknown_LEFT 		 = GetString(DsRGuildUnknown_MenuLeft)
DsRGuildUnknown_CORNER 		 = GetString(DsRGuildUnknown_MenuCorner)
DsRGuildUnknown_RIGHT 		 = GetString(DsRGuildUnknown_MenuRight)

DsRGuildUnknownDefaults.STYLEPAGE_ICON_PATH1 = "/esoui/art/icons/quest_summerset_completed_report.dds"
DsRGuildUnknownDefaults.STYLEPAGE_ICON_PATH2 = "/esoui/art/icons/quest_letter_002.dds"
DsRGuildUnknownDefaults.RUNEBOX_ICON_PATH1   = "/esoui/art/icons/container_sealed_polymorph_001.dds"

DsRGuildUnknownDefaults.ICON_STYLES_CHOICES =
{
	"|t24:24:/esoui/art/buttons/accept_up.dds|t " .. GetString(DsRGuildUnknown_SelectIcon1),
	"|t24:24:/esoui/art/buttons/edit_up.dds|t " .. GetString(DsRGuildUnknown_SelectIcon2),
	"|t24:24:/esoui/art/guild/tabicon_roster_up.dds|t " .. GetString(DsRGuildUnknown_SelectIcon3),
	"|t24:24:/esoui/art/miscellaneous/new_icon.dds|t " .. GetString(DsRGuildUnknown_SelectIcon4),
	"|t24:24:/esoui/art/login/login_icon_info.dds|t " .. GetString(DsRGuildUnknown_SelectIcon5),
	"|t24:24:/esoui/art/tradinghouse/gamepad/gp_tradinghouse_racial_style_motif_book.dds|t " .. GetString(DsRGuildUnknown_SelectIcon6),
}

DsRGuildUnknownDefaults.ICON_STYLE_VALUES =
{
	"/esoui/art/buttons/accept_up.dds",
	"/esoui/art/buttons/edit_up.dds",
	"/esoui/art/guild/tabicon_roster_up.dds",
	"/esoui/art/miscellaneous/new_icon.dds",
	"/esoui/art/login/login_icon_info.dds",
	"/esoui/art/tradinghouse/gamepad/gp_tradinghouse_racial_style_motif_book.dds",
}

DsRGuildUnknownDefaults.CHAPTERS = {
	[ITEM_STYLE_CHAPTER_AXES] 	 	= 1,
	[ITEM_STYLE_CHAPTER_BELTS] 	 	= 2,
	[ITEM_STYLE_CHAPTER_BOOTS] 	 	= 3,
	[ITEM_STYLE_CHAPTER_BOWS] 	 	= 4,
	[ITEM_STYLE_CHAPTER_CHESTS]  	= 5,
	[ITEM_STYLE_CHAPTER_DAGGERS] 	= 6,
	[ITEM_STYLE_CHAPTER_GLOVES]  	= 7,
	[ITEM_STYLE_CHAPTER_HELMETS] 	= 8,
	[ITEM_STYLE_CHAPTER_LEGS] 	 	= 9,
	[ITEM_STYLE_CHAPTER_MACES] 	 	= 10,
	[ITEM_STYLE_CHAPTER_SHIELDS] 	= 11,
	[ITEM_STYLE_CHAPTER_SHOULDERS]  = 12,
	[ITEM_STYLE_CHAPTER_STAVES] 	= 13,
	[ITEM_STYLE_CHAPTER_SWORDS] 	= 14
}

DsRGuildUnknownDefaults.defaultDsRGuildUnknownConstantsML = {
	["EU Megaserver"] = {
		recipes 	= {},
		furnishings = {},
		motifs 		= {},
		stylepages 	= {},
		runeboxes 	= {},
		affix 		= {},
		focus 		= {},
		signature 	= {},
	},
	["NA Megaserver"] = {
		recipes 	= {},
		furnishings = {},
		motifs 		= {},
		stylepages 	= {},
		runeboxes 	= {},
		affix 		= {},
		focus 		= {},
		signature 	= {},
	},
	["PTS"] = {
		recipes 	= {},
		furnishings = {},
		motifs 		= {},
		stylepages 	= {},
		runeboxes 	= {},
		affix 		= {},
		focus 		= {},
		signature 	= {},
	},
}

DsRGuildUnknownDefaults.defaultDsRGuildUnknownConstantsDD = {
	motifData 		= {},
	recipeData 		= {},
	furnitureData 	= {},
	stylepageData 	= {},
	runeboxData 	= {},
	affixData 		= {},
	focusData 		= {},
	signatureData 	= {},
}

DsRGuildUnknownDefaults.CharTrack = {
	["trackedCharacters"] = {
		["EU Megaserver"] = {},
		["NA Megaserver"] = {},
		["PTS"]			  = {},
	},
}

DsRGuildUnknownDefaults.defaultOpts = {
	APIVersion	 		= 0,
	AddOnVersion 		= 0,
	TrackerOnOff 		= true,
	TrackerTooltipOnOff = true,
	TrackerIconOnOff	= true,
	TrackerChatOnOff	= true,
	
	displayMotifs		= true,
	displayRecipes		= true,
	displayFurnishings	= true,
	displayStylepages	= true,
	displayRuneboxes	= true,
	displayScribing		= true,
	
	inventoryIconPosition 	= 2, -- 1=left, 2=corner, 3=right
	inventoryIconStyle 		= "/esoui/art/miscellaneous/new_icon.dds",
	MultiIconUseOnOff		= false,
	displayOnlyIfUnknownINV	= false,
	displayOnlyIfUnknownCHAT= false,
	iconXOffset 			= -14,
	iconYOffset 			= 8,
	iconSize 				= 24,
	iconDrawLevel 			= 5,
	unknownColour 			= "ff0000ff",
	knownBySomeColour		= "00dbffff",
	knownByAllColour 		= "00ff00ff",
	displayTooltip			= true,
	displayChat  			= true,
	displayInventory		= true,
}

function DsRGuildUnknownDefaults:Defaults()
	
end