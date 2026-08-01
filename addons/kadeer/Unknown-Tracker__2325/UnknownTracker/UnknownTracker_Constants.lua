UnknownTracker = {}
local UT = UnknownTracker or {}

UT.STYLEPAGE_ICON_PATH1 = "/esoui/art/icons/quest_summerset_completed_report.dds"
UT.STYLEPAGE_ICON_PATH2 = "/esoui/art/icons/quest_letter_002.dds"
UT.RUNEBOX_ICON_PATH1 = "/esoui/art/icons/container_sealed_polymorph_001.dds"

UT.ICON_STYLES_CHOICES =
{
	"|t16:16:/UnknownTracker/Textures/bolt.dds|t Bolt",
	"|t16:16:/UnknownTracker/Textures/circle.dds|t Circle",
	"|t16:16:/UnknownTracker/Textures/gear.dds|t Gear",
	"|t16:16:/UnknownTracker/Textures/heart.dds|t Heart",
	"|t16:16:/UnknownTracker/Textures/star.dds|t Star",
	"|t16:16:/UnknownTracker/Textures/tick.dds|t Tick",
    "|t16:16:/UnknownTracker/Textures/UT.dds|t UT",
}

UT.ICON_STYLE_VALUES =
{
	"/UnknownTracker/Textures/bolt.dds",
  	"/UnknownTracker/Textures/circle.dds",
  	"/UnknownTracker/Textures/gear.dds",
  	"/UnknownTracker/Textures/heart.dds",
  	"/UnknownTracker/Textures/star.dds",
  	"/UnknownTracker/Textures/tick.dds",
  	"/UnknownTracker/Textures/UT.dds",
}

UT.COLOUR_SCHEME_CHOICES = {
	"Vibrant",
	"Pastel",
	"Pyrokinesis",
}

UT.COLOUR_SCHEME_VALUES = {
	["Vibrant"] = { unknownColour = "00FF00FF", knownBySomeColour = "00FFFFFF", knownByAllColour = "808080FF" },
	["Pastel"] = { unknownColour = "B3CC57FF", knownBySomeColour = "B8E6FFFF", knownByAllColour = "898F95FF" },
	["Pyrokinesis"] = { unknownColour = "B03333FF", knownBySomeColour = "74BDEEFF", knownByAllColour = "2A2A2AFF" },
}

UT.defaultOpts =
{
	APIVersion=0,
	AddOnVersion=0,

	-- global options
	displayBust=false,
	displayCraftedGear=false,
	displayGear=false,
	displayMotifs=true,
  	displayRecipes=true,
  	displayFurnishings=true,
  	displayStylepages=true,
  	displayRuneboxes=true,
  	displayScribing=true,

  	inventoryIconPosition = 3, 				-- 1=left, 2=centre, 3=right
  	inventoryIconStyle = "/UnknownTracker/Textures/UT.dds",
  	colourScheme = "Vibrant",

  	-- characters submenu
  	trackedCharacters = {
		["EU Megaserver"] = {},
		["NA Megaserver"] = {},
		["PTS"] = {},
	},

	-- misc advanced
  	displayOnlyIfUnknown=false,
  	iconXOffset = 0,
  	iconYOffset = 0,
  	iconSize = 32,
  	iconDrawLevel = 5,
  	unknownColour = "00FF00FF",
  	knownBySomeColour = "00FFFFFF",
  	knownByAllColour = "808080FF",
  	displayTooltip=true,
  	shortenTooltipNames=false,
  	displayTooltipNameOnlyIfUnknown=false,
}

UT.defaultUTMasterList =
{
	["EU Megaserver"] = {
		recipes = {},
		furnishings = {},
		motifs = {},
		stylepages = {},
		runeboxes = {},
		affix = {},
		focus = {},
		signature = {},
	},
	["NA Megaserver"] = {
		recipes = {},
		furnishings = {},
		motifs = {},
		stylepages = {},
		runeboxes = {},
		affix = {},
		focus = {},
		signature = {},
	},
	["PTS"] = {
		recipes = {},
		furnishings = {},
		motifs = {},
		stylepages = {},
		runeboxes = {},
		affix = {},
		focus = {},
		signature = {},
	},
}

UT.defaultUTDataDump =
{
	motifData = {},
	recipeData = {},
	furnitureData = {},
	stylepageData = {},
	runeboxData = {},
	affixData = {},
	focusData = {},
	signatureData = {},
}

UT.CHAPTERS =
{
	[ITEM_STYLE_CHAPTER_AXES] = 1,
	[ITEM_STYLE_CHAPTER_BELTS] = 2,
	[ITEM_STYLE_CHAPTER_BOOTS] = 3,
	[ITEM_STYLE_CHAPTER_BOWS] = 4,
	[ITEM_STYLE_CHAPTER_CHESTS] = 5,
	[ITEM_STYLE_CHAPTER_DAGGERS] = 6,
	[ITEM_STYLE_CHAPTER_GLOVES] = 7,
	[ITEM_STYLE_CHAPTER_HELMETS] = 8,
	[ITEM_STYLE_CHAPTER_LEGS] = 9,
	[ITEM_STYLE_CHAPTER_MACES] = 10,
	[ITEM_STYLE_CHAPTER_SHIELDS] = 11,
	[ITEM_STYLE_CHAPTER_SHOULDERS] = 12,
	[ITEM_STYLE_CHAPTER_STAVES] = 13,
	[ITEM_STYLE_CHAPTER_SWORDS] = 14
}
