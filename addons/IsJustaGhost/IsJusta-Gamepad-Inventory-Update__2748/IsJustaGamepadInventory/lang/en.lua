------------------------------------------------
-- English localization for IsJustaGamepadInventory
------------------------------------------------
--	Create global custom ITEMFILTERTYPEs dynamically based on ITEMFILTERTYPE_ITERATION_END
-- ITEMFILTERTYPE_ITERATION_END = 26

ITEMFILTERTYPE_CONTAINER			= ITEMFILTERTYPE_ITERATION_END + 1
ITEMFILTERTYPE_FOOD_DRINK			= ITEMFILTERTYPE_CONTAINER + 1
ITEMFILTERTYPE_MAPS					= ITEMFILTERTYPE_FOOD_DRINK + 1
ITEMFILTERTYPE_POTION				= ITEMFILTERTYPE_MAPS + 1
ITEMFILTERTYPE_RECIPE_STYLE_PAGE	= ITEMFILTERTYPE_POTION + 1
ITEMFILTERTYPE_REPAIR				= ITEMFILTERTYPE_RECIPE_STYLE_PAGE + 1
ITEMFILTERTYPE_SIEGE				= ITEMFILTERTYPE_REPAIR + 1
ITEMFILTERTYPE_STOLEN				= ITEMFILTERTYPE_SIEGE + 1
ITEMFILTERTYPE_TREASURE				= ITEMFILTERTYPE_STOLEN + 1
ITEMFILTERTYPE_WRIT					= ITEMFILTERTYPE_TREASURE + 1
ITEMFILTERTYPE_FRAGMENT				= ITEMFILTERTYPE_WRIT + 1
--ITEMFILTERTYPE_TRASH				= ITEMFILTERTYPE_FRAGMENT + 1

-- ITEM_TYPE_DISPLAY_CATEGORY_MAX_VALUE = 40
ITEM_TYPE_DISPLAY_CATEGORY_CRAFTED = ITEM_TYPE_DISPLAY_CATEGORY_MAX_VALUE + 1

-- localized strings
local useCategory = "Use <<1>> Category"
local useCategoryTooltip = "Enabled: adds a dynamic category for <<1>>."
local plural = "<<1>>s"

local containerString	= GetString(SI_ITEMTYPEDISPLAYCATEGORY26)
local junkString		= GetString(SI_ITEMFILTERTYPE9)
local foofDrinkString	= zo_strformat(SI_UNIT_FRAME_BARVALUE, GetString(SI_ITEMTYPEDISPLAYCATEGORY19), GetString(SI_ITEMTYPEDISPLAYCATEGORY20))
local potionString		= GetString(SI_ITEMTYPEDISPLAYCATEGORY22)
local recipesString		= zo_strformat(SI_UNIT_FRAME_BARVALUE, GetString(SI_ITEMTYPEDISPLAYCATEGORY21), GetString(SI_ITEMTYPEDISPLAYCATEGORY24))
local repairKitsString	= GetString(SI_HOOK_POINT_STORE_REPAIR_KIT_HEADER):gsub(":$", "")
local siegeString		= GetString(SI_ITEMTYPEDISPLAYCATEGORY32)
local treasuresString	= zo_strformat(plural, GetString(SI_ITEMTYPE56))
local writsString		= GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES212)
local stolenString		= GetString(SI_GAMEPAD_ITEM_STOLEN_LABEL)
local fragmentsString	= GetString(SI_ANTIQUITY_FRAGMENTS)
local trashString		= GetString(SI_ITEMTYPEDISPLAYCATEGORY36)

local mapsSurveyString = zo_strformat(SI_UNIT_FRAME_BARVALUE,  
							zo_strformat(plural, GetString(SI_SPECIALIZEDITEMTYPE101)), zo_strformat(plural, GetString(SI_SPECIALIZEDITEMTYPE100))
						)


--local surveyString = zo_strformat(plural, GetString(SI_SPECIALIZEDITEMTYPE101):gsub(" .*$", ''))
--surveyString = zo_strformat(SI_UNIT_NAME, surveyString)

local tooltips = {}
tooltips.container	= 'select containers'
tooltips.foofDrink	= foofDrinkString:lower()
tooltips.junk		= 'items marked as junk'
tooltips.potion		= potionString:lower()
tooltips.mapsSurvey	= mapsSurveyString:lower()
tooltips.recipes	= recipesString:lower()
tooltips.repairKits	= 'slot-able repair kits'
tooltips.siege		= 'AVA items'
tooltips.stolen		= 'stolen items'
tooltips.treasures	= '\"Sell to merchant\" treasure items'
tooltips.writs		= 'writs'
tooltips.fragments	= fragmentsString:lower()

-- custom strings
local destroyAllJunkWarning = GetString(SI_DESTROY_ALL_JUNK) .. '\n\n' .. ZO_ERROR_COLOR:Colorize('This action will destroy <<1>> %s.')

local strings = {
	SI_IJA_GPINVENTORY_CATEGORIES_HEADER			= "Sorted Categories",
	SI_IJA_GPINVENTORY_CATEGORIE_OPTIONS			= "Category options",
	SI_IJA_GPINVENTORY_BANK_OPTIONS					= "Bank junk sort Options",

	SI_IJA_GPINVENTORY_SORTBANK_WITHDRAW			= "Bank Withdraw",
	SI_IJA_GPINVENTORY_SORTBANK_WITHDRAW_TOOLTIP	= "Enabled: Sorts junk in bank withdraw list to bottom.",

	SI_IJA_GPINVENTORY_SORTBANK_DEPOSIT				= "Bank Deposit",
	SI_IJA_GPINVENTORY_SORTBANK_DEPOSIT_TOOLTIP		= "Enabled: sorts junk in bank and guild bank deposit lists to bottom.",
	
	SI_IJA_GPINVENTORY_PLURAL = plural,
	
	SI_IJA_GPINVENTORY_DESTROY_ALL_WARNING1			= string.format(destroyAllJunkWarning, 'item'),
	SI_IJA_GPINVENTORY_DESTROY_ALL_WARNING2			= string.format(destroyAllJunkWarning, 'items'),
	
	SI_IJA_GPINVENTORY_SORTJUNK1					= GetString(SI_ITEMTYPE0),
	SI_IJA_GPINVENTORY_SORTJUNK2					= "To Top",
	SI_IJA_GPINVENTORY_SORTJUNK3					= "To Bottom",
}

local localizedStrings = {
	[ITEMFILTERTYPE_CONTAINER] = {
		category = containerString,
		tooltip = tooltips.container
	},
	[ITEMFILTERTYPE_FOOD_DRINK] = {
		category = foofDrinkString,
		tooltip = tooltips.foofDrink
	},
	[ITEMFILTERTYPE_JUNK] = {
		category = junkString,
		tooltip = tooltips.junk
	},
	[ITEMFILTERTYPE_MAPS] = {
		category = mapsSurveyString,
		tooltip = tooltips.mapsSurvey
	},
	[ITEMFILTERTYPE_POTION] = {
		category = potionString,
		tooltip = tooltips.potion
	},
	[ITEMFILTERTYPE_RECIPE_STYLE_PAGE] = {
		category = recipesString,
		tooltip = tooltips.recipes
	},
	[ITEMFILTERTYPE_REPAIR] = {
		category = repairKitsString,
		tooltip = tooltips.repairKits
	},
	[ITEMFILTERTYPE_SIEGE] = {
		category = siegeString,
		tooltip = tooltips.siege
	},
	[ITEMFILTERTYPE_STOLEN] = {
		category = stolenString,
		tooltip = tooltips.stolen
	},
	[ITEMFILTERTYPE_TREASURE] = {
		category = treasuresString,
		tooltip = tooltips.treasures
	},
	[ITEMFILTERTYPE_WRIT] = {
		category = writsString,
		tooltip = tooltips.writs
	},
	[ITEMFILTERTYPE_FRAGMENT] = {
		category = fragmentsString,
		tooltip = tooltips.fragments
	},
	--[[
	[ITEMFILTERTYPE_TRASH] = {
		category = trashString,
		tooltip = trashString:lower()
	},
	]]
}
IJA_GPINVENTORY_LOCALIZEDSTRINGS = localizedStrings
IJA_GPINVENTORY_LOCALIZEDSTRINGS.useCategory = useCategory
IJA_GPINVENTORY_LOCALIZEDSTRINGS.useCategoryTooltip = useCategoryTooltip

strings["SI_ITEMTYPEDISPLAYCATEGORY" .. ITEM_TYPE_DISPLAY_CATEGORY_CRAFTED] = GetString(SI_ITEM_FORMAT_STR_CRAFTED) -- "Crafted"
strings["SI_ITEMTYPEDISPLAYCATEGORY" .. ITEM_TYPE_DISPLAY_CATEGORY_CRAFTED] = GetString(SI_ITEM_FORMAT_STR_CRAFTED) -- "Crafted"

--[[
ITEM_LIST_SORT_TYPE_JUNK = ITEM_LIST_SORT_TYPE_ITERATION_END + 1
ITEM_LIST_SORT_TYPE_ITERATION_END = ITEM_LIST_SORT_TYPE_JUNK
strings['SI_ITEMLISTSORTTYPE' .. ITEM_LIST_SORT_TYPE_JUNK] = GetString(SI_ITEMFILTERTYPE9)
]]
for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
