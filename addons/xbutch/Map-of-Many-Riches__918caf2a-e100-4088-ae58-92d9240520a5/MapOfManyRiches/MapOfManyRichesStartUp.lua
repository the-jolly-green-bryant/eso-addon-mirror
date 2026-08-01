local MapOfManyRiches = ZO_InitializingObject:Subclass()

MOMR_BLANK_SAVED_VARS = 0

MOMR_MARK_OPTIONS_USING = "using"
MOMR_MARK_OPTIONS_INVENTORY = "inventory"
MOMR_MARK_OPTIONS_ALL = "all"

MOMR_PIN_KEY_MAP = "worldmap"
MOMR_PIN_KEY_COMPASS = "compass"

MOMR_PIN_TYPE_TREASURE = "treasure"
MOMR_PIN_TYPE_SURVEYS = "survey"

-- Use the existing stable string IDs to avoid missing string errors
MOMR_MAP_NOT_OPENED = GetString(SI_MOMR_BUGREPORT_PICKUP_NO_MAP)
MOMR_BOOK_NOT_OPENED = 0

MOMR_NO_PIN_TYPE = "nil"

MOMR_PIN_TYPE_DATA =
{
	[MOMR_PIN_TYPE_TREASURE] =
	{
		pinName = "MapOfManyRiches_TreasureMapPin",
		specializedItemType = SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP,
		compareString = zo_strlower(GetString(SI_SPECIALIZEDITEMTYPE100)),	--no more need to translate
		name = GetString(SI_SPECIALIZEDITEMTYPE100),						--no more need to translate
		interactionType = INTERACTION_NONE,
	},
	[MOMR_PIN_TYPE_SURVEYS] =
	{
		pinName = "MapOfManyRiches_SurveyReportPin",
		specializedItemType = SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT,
		compareString = zo_strlower(GetString(SI_SPECIALIZEDITEMTYPE101)),	--no more need to translate
		name = GetString(SI_SPECIALIZEDITEMTYPE101),						--no more need to translate
		interactionType = INTERACTION_HARVEST,
	},
}

MapOfManyRiches.addOnName = "MapOfManyRiches"
MapOfManyRiches.addOnDisplayName = "Map of Many Riches"
MapOfManyRiches.APIVersion = GetAPIVersion()
MapOfManyRiches.internal = { }

local function GetAddOnInfos()
	local addOnManager = GetAddOnManager()
	local name, author
	for i = 1, addOnManager:GetNumAddOns() do
		name, _, author = addOnManager:GetAddOnInfo(i)
		if name == MapOfManyRiches.addOnName then
			return author, addOnManager:GetAddOnVersion(i)
		end
	end
end
MapOfManyRiches.author, MapOfManyRiches.version = GetAddOnInfos()

-- The flag will only be changed after API.lua is loaded
MapOfManyRiches.isInitialized = false

-- GLOBAL
-- Merge with existing globals so debug helpers remain available
local previous = MOMR
if type(previous) == "table" then
	setmetatable(MapOfManyRiches, { __index = previous })
end
MOMR = MapOfManyRiches
