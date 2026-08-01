--[[ FILTERING
2.5
○ added French translation courtesy of fzr6n7
○ 
○ 
○ 
○ 



○ added inventory sorting and filtering based off of bank withdraw filtering


see what i can do about sorting


Test bank sorts

]]

local defaults = {
	displayName = "|cFF00FFIsJusta|r |cffffffGamepad Inventory Update|r",
	name = "IsJustaGamepadInventory",
	version = "2.5",
}

local savedVarsVersion = 2.4

local INVENTORY_CATEGORY_LIST = "categoryList"

local CURRENT_CATEGORY_FILTER = ITEMFILTERTYPE_ALL

local function initStrings()
	local strings = IJA_GPINVENTORY_LOCALIZEDSTRINGS

	-- indexed string ids
	local localizedstrings = {}
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY" .. ITEMFILTERTYPE_CONTAINER]				  = zo_strformat(strings.useCategory, strings.category.container)
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY_TOOLTIP" .. ITEMFILTERTYPE_CONTAINER]		  = zo_strformat(strings.useCategoryTooltip, strings.tooltips.container)
	 
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY" .. ITEMFILTERTYPE_FOOD_DRINK]				 = zo_strformat(strings.useCategory, strings.category.foofDrink)
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY_TOOLTIP" .. ITEMFILTERTYPE_FOOD_DRINK]		 = zo_strformat(strings.useCategoryTooltip, strings.tooltips.foofDrink)
	 
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY" .. ITEMFILTERTYPE_JUNK]					   = zo_strformat(strings.useCategory, strings.category.junk)
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY_TOOLTIP" .. ITEMFILTERTYPE_JUNK]			   = zo_strformat(strings.useCategoryTooltip, strings.tooltips.junk)
	 
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY" .. ITEMFILTERTYPE_POTION]					 = zo_strformat(strings.useCategory, strings.category.potion)
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY_TOOLTIP" .. ITEMFILTERTYPE_POTION]			 = zo_strformat(strings.useCategoryTooltip, strings.tooltips.potion)
	 
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY" .. ITEMFILTERTYPE_MAPS]					   = zo_strformat(strings.useCategory, strings.category.mapsSurvey)
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY_TOOLTIP" .. ITEMFILTERTYPE_MAPS]			   = zo_strformat(strings.useCategoryTooltip, strings.tooltips.mapsSurvey)
	 
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY" .. ITEMFILTERTYPE_RECIPE_STYLE_PAGE]		  = zo_strformat(strings.useCategory, strings.category.recipes)
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY_TOOLTIP" .. ITEMFILTERTYPE_RECIPE_STYLE_PAGE]  = zo_strformat(strings.useCategoryTooltip, strings.tooltips.recipes)
	 
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY" .. ITEMFILTERTYPE_REPAIR]					 = zo_strformat(strings.useCategory, strings.category.repairKits)
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY_TOOLTIP" .. ITEMFILTERTYPE_REPAIR]			 = zo_strformat(strings.useCategoryTooltip, strings.tooltips.repairKits)
	 
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY" .. ITEMFILTERTYPE_SIEGE]					  = zo_strformat(strings.useCategory, strings.category.siege)
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY_TOOLTIP" .. ITEMFILTERTYPE_SIEGE]			  = zo_strformat(strings.useCategoryTooltip, strings.tooltips.siege)
	 
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY" .. ITEMFILTERTYPE_STOLEN]					 = zo_strformat(strings.useCategory, strings.category.stolen)
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY_TOOLTIP" .. ITEMFILTERTYPE_STOLEN]			 = zo_strformat(strings.useCategoryTooltip, strings.tooltips.stolen)
	 
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY" .. ITEMFILTERTYPE_TREASURE]				   = zo_strformat(strings.useCategory, strings.category.treasures)
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY_TOOLTIP" .. ITEMFILTERTYPE_TREASURE]		   = zo_strformat(strings.useCategoryTooltip, strings.tooltips.treasures)
	 
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY" .. ITEMFILTERTYPE_WRIT]					   = zo_strformat(strings.useCategory, strings.category.writs)
	localizedstrings["SI_IJA_GPINVENTORY_CATEGORY_TOOLTIP" .. ITEMFILTERTYPE_WRIT]			   = zo_strformat(strings.useCategoryTooltip, strings.tooltips.writs)

	for stringId, stringValue in pairs(localizedstrings) do
		ZO_CreateStringId(stringId, stringValue)
		SafeAddVersion(stringId, 1)
	end
	 
	localizedstrings = nil
	IJA_GPINVENTORY_LOCALIZEDSTRINGS = nil
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
local IJA_GPInventory = ZO_CallbackObject:Subclass()

function IJA_GPInventory:New(...)
	local object = ZO_Object.New(self)
	object:Initialize(...)
	return object
end

function IJA_GPInventory:Initialize(control)
	self.control = control
	initStrings()	
	
	self.displayName	= defaults.displayName
	self.name 			= defaults.name
	self.version 		= defaults.version

	local function OnLoaded(_, name)
		if name ~= defaults.name then return end
		self.control:UnregisterForEvent(EVENT_ADD_ON_LOADED)
		
		local AccountWideSavedVars = ZO_SavedVars:NewAccountWide("IJA_GPInventory_SavedVars",savedVarsVersion, nil, defaults, GetWorldName())
		self.savedVars = AccountWideSavedVars
		
		self:SetupSettings()
		self:InitJunkSort()
	end
	control:RegisterForEvent( EVENT_ADD_ON_LOADED, OnLoaded)
	
	local function onPlayerActivated()
		control:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)

		self:AddInventoryActions()
		self:InitializeInventoryFilters()
		--	d( self.displayName .. " version: " .. self.version)
	end
	control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, onPlayerActivated)
end

---------------------------------------------------------------------------------------------------------------
-- Custom Categories
---------------------------------------------------------------------------------------------------------------
local isCutomCategory = {
	[ITEMFILTERTYPE_JUNK] = true,
	[ITEMFILTERTYPE_CONTAINER] = true,
	[ITEMFILTERTYPE_FOOD_DRINK] = true,
	[ITEMFILTERTYPE_MAPS] = true,
	[ITEMFILTERTYPE_POTION] = true,
	[ITEMFILTERTYPE_RECIPE_STYLE_PAGE] = true,
	[ITEMFILTERTYPE_REPAIR] = true,
	[ITEMFILTERTYPE_SIEGE] = true,
	[ITEMFILTERTYPE_STOLEN] = true,
	[ITEMFILTERTYPE_TREASURE] = true,
	[ITEMFILTERTYPE_WRIT] = true
}

---------------------------------------------------------------------------------------------------------------
-- Comparetors
---------------------------------------------------------------------------------------------------------------
local isQuickSlotFiltersType = {
	[ITEMFILTERTYPE_MAPS]		= true,
	[ITEMFILTERTYPE_SIEGE]		= true,
	[ITEMFILTERTYPE_REPAIR]		= true,
	[ITEMFILTERTYPE_POTION]		= true,
	[ITEMFILTERTYPE_CONTAINER]	= true,
	[ITEMFILTERTYPE_FOOD_DRINK] = true,
	[ITEMFILTERTYPE_QUICKSLOT]	= true,
}

local SPECIALIZED_ITEMTYPE_FOR_CONTAINER = {
	[SPECIALIZED_ITEMTYPE_CONTAINER_EVENT] = true,	-- SPECIALIZED_ITEMTYPE_CONTAINER_EVENT = 851
	[SPECIALIZED_ITEMTYPE_CONTAINER] = true,	-- SPECIALIZED_ITEMTYPE_CONTAINER = 850
}
local SPECIALIZED_ITEMTYPE_FOR_FOOD_DRINK = {
	[SPECIALIZED_ITEMTYPE_DRINK_ALCOHOLIC] = true,	-- SPECIALIZED_ITEMTYPE_DRINK_ALCOHOLIC = 20
	[SPECIALIZED_ITEMTYPE_DRINK_CORDIAL_TEA] = true,	-- SPECIALIZED_ITEMTYPE_DRINK_CORDIAL_TEA = 25
	[SPECIALIZED_ITEMTYPE_DRINK_DISTILLATE] = true,	-- SPECIALIZED_ITEMTYPE_DRINK_DISTILLATE = 26
	[SPECIALIZED_ITEMTYPE_DRINK_LIQUEUR] = true,	-- SPECIALIZED_ITEMTYPE_DRINK_LIQUEUR = 23
	[SPECIALIZED_ITEMTYPE_DRINK_TEA] = true,	-- SPECIALIZED_ITEMTYPE_DRINK_TEA = 21
	[SPECIALIZED_ITEMTYPE_DRINK_TINCTURE] = true,	-- SPECIALIZED_ITEMTYPE_DRINK_TINCTURE = 24
	[SPECIALIZED_ITEMTYPE_DRINK_TONIC] = true,	-- SPECIALIZED_ITEMTYPE_DRINK_TONIC = 22
	[SPECIALIZED_ITEMTYPE_DRINK_UNIQUE] = true,	-- SPECIALIZED_ITEMTYPE_DRINK_UNIQUE = 27
	[SPECIALIZED_ITEMTYPE_FOOD_ENTREMET] = true,	-- SPECIALIZED_ITEMTYPE_FOOD_ENTREMET = 6
	[SPECIALIZED_ITEMTYPE_FOOD_FRUIT] = true,	-- SPECIALIZED_ITEMTYPE_FOOD_FRUIT = 2
	[SPECIALIZED_ITEMTYPE_FOOD_GOURMET] = true,	-- SPECIALIZED_ITEMTYPE_FOOD_GOURMET = 7
	[SPECIALIZED_ITEMTYPE_FOOD_MEAT] = true,	-- SPECIALIZED_ITEMTYPE_FOOD_MEAT = 1
	[SPECIALIZED_ITEMTYPE_FOOD_RAGOUT] = true,	-- SPECIALIZED_ITEMTYPE_FOOD_RAGOUT = 5
	[SPECIALIZED_ITEMTYPE_FOOD_SAVOURY] = true,	-- SPECIALIZED_ITEMTYPE_FOOD_SAVOURY = 4
	[SPECIALIZED_ITEMTYPE_FOOD_UNIQUE] = true,	-- SPECIALIZED_ITEMTYPE_FOOD_UNIQUE = 8
	[SPECIALIZED_ITEMTYPE_FOOD_VEGETABLE] = true	-- SPECIALIZED_ITEMTYPE_FOOD_VEGETABLE = 3
}
local SPECIALIZED_ITEMTYPE_FOR_SURVEY_REPORT_TREASURE_MAP = {
	[SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP] = true,	-- SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP = 100
	[SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT] = true	-- SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT = 101
}
local SPECIALIZED_ITEMTYPE_FOR_POTION = {
	[SPECIALIZED_ITEMTYPE_POTION] = true	-- SPECIALIZED_ITEMTYPE_POTION = 450
}
local SPECIALIZED_ITEMTYPE_FOR_RECIPE_STYLE_MOTIF = {
	[SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE] = true,	-- SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE = 852
	[SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING] = true,	-- SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING = 175
	[SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING] = true,	-- SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING = 172
	[SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING] = true,	-- SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING = 173
	[SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING] = true,	-- SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING = 174
	[SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING] = true,	-- SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING = 178
	[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING] = true,	-- SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING = 176
	[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK] = true,	-- SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK = 171
	[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD] = true,	-- SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD = 170
	[SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING] = true,	-- SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING = 177
	[SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK] = true,	-- SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK = 60
	[SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER] = true,	-- SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER = 61
	[SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE] = true,	-- SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE = 82
}
local SPECIALIZED_ITEMTYPE_FOR_SLOTABLE_REPAIRKIT = {
	[SPECIALIZED_ITEMTYPE_CROWN_REPAIR] = true,	-- SPECIALIZED_ITEMTYPE_CROWN_REPAIR = 2500
	[SPECIALIZED_ITEMTYPE_GROUP_REPAIR] = true,	-- SPECIALIZED_ITEMTYPE_GROUP_REPAIR = 3150
}
local SPECIALIZED_ITEMTYPE_FOR_SIEGE = {
	[SPECIALIZED_ITEMTYPE_AVA_REPAIR] = true,		-- SPECIALIZED_ITEMTYPE_AVA_REPAIR = 2100
	[SPECIALIZED_ITEMTYPE_SIEGE_BALLISTA] = true,	-- SPECIALIZED_ITEMTYPE_SIEGE_BALLISTA = 401
	[SPECIALIZED_ITEMTYPE_SIEGE_CATAPULT] = true,	-- SPECIALIZED_ITEMTYPE_SIEGE_CATAPULT = 404
	[SPECIALIZED_ITEMTYPE_SIEGE_GRAVEYARD] = true,	-- SPECIALIZED_ITEMTYPE_SIEGE_GRAVEYARD = 405
	[SPECIALIZED_ITEMTYPE_SIEGE_LANCER] = true,		-- SPECIALIZED_ITEMTYPE_SIEGE_LANCER = 409
	[SPECIALIZED_ITEMTYPE_SIEGE_MONSTER] = true,	-- SPECIALIZED_ITEMTYPE_SIEGE_MONSTER = 406
	[SPECIALIZED_ITEMTYPE_SIEGE_OIL] = true,		-- SPECIALIZED_ITEMTYPE_SIEGE_OIL = 407
	[SPECIALIZED_ITEMTYPE_SIEGE_RAM] = true,		-- SPECIALIZED_ITEMTYPE_SIEGE_RAM = 402
	[SPECIALIZED_ITEMTYPE_SIEGE_TREBUCHET] = true,	-- SPECIALIZED_ITEMTYPE_SIEGE_TREBUCHET = 400
	[SPECIALIZED_ITEMTYPE_SIEGE_UNIVERSAL] = true,	-- SPECIALIZED_ITEMTYPE_SIEGE_UNIVERSAL = 403
	[SPECIALIZED_ITEMTYPE_RECALL_STONE_KEEP] = true,	-- SPECIALIZED_ITEMTYPE_RECALL_STONE_KEEP = 3100
	[SPECIALIZED_ITEMTYPE_SIEGE_BATTLE_STANDARD] = true, -- SPECIALIZED_ITEMTYPE_SIEGE_BATTLE_STANDARD = 408
}
local SPECIALIZED_ITEMTYPE_FOR_TREASURE = {
	[SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH] = true, -- SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH = 80
	[SPECIALIZED_ITEMTYPE_COLLECTIBLE_MONSTER_TROPHY] = true, -- SPECIALIZED_ITEMTYPE_COLLECTIBLE_MONSTER_TROPHY = 81
	[SPECIALIZED_ITEMTYPE_TROPHY_TOY] = true, -- SPECIALIZED_ITEMTYPE_TROPHY_TOY = 111
	[SPECIALIZED_ITEMTYPE_TREASURE] = true,	-- SPECIALIZED_ITEMTYPE_TREASURE = 2550
}
local SPECIALIZED_ITEMTYPE_FOR_WRIT = {
	[SPECIALIZED_ITEMTYPE_HOLIDAY_WRIT] = true,	-- SPECIALIZED_ITEMTYPE_HOLIDAY_WRIT = 2760
	[SPECIALIZED_ITEMTYPE_MASTER_WRIT] = true	-- SPECIALIZED_ITEMTYPE_MASTER_WRIT = 2750
}

local function isContainerItem(itemData)
	return SPECIALIZED_ITEMTYPE_FOR_CONTAINER[itemData.specializedItemType] or false
end
local function isFoodItem(itemData)
	return SPECIALIZED_ITEMTYPE_FOR_FOOD_DRINK[itemData.specializedItemType] or false
end
local function isMapItem(itemData)
	return SPECIALIZED_ITEMTYPE_FOR_SURVEY_REPORT_TREASURE_MAP[itemData.specializedItemType] or false
end
local function isPotionItem(itemData)
	return SPECIALIZED_ITEMTYPE_FOR_POTION[itemData.specializedItemType] or false
end
local function isRecipeItem(itemData)
	return SPECIALIZED_ITEMTYPE_FOR_RECIPE_STYLE_MOTIF[itemData.specializedItemType] or itemData.itemType == ITEMTYPE_RACIAL_STYLE_MOTIF or false
end
local function isRepairItem(itemData)
	return SPECIALIZED_ITEMTYPE_FOR_SLOTABLE_REPAIRKIT[itemData.specializedItemType] or false
end
local function isSiegeItem(itemData)
	return SPECIALIZED_ITEMTYPE_FOR_SIEGE[itemData.specializedItemType] or false
end
local function isTreasureItem(itemData)
	return SPECIALIZED_ITEMTYPE_FOR_TREASURE[itemData.specializedItemType] or false
end
local function isWritItem(itemData)
	return SPECIALIZED_ITEMTYPE_FOR_WRIT[itemData.specializedItemType] or false
end
local function isJunkItem(itemData)
	return itemData.isJunk and IJA_GPINVENTORY.savedVars.enabledCategories[ITEMFILTERTYPE_JUNK] or false
end
local function isStolenItem(itemData)
	return itemData.stolen and IJA_GPINVENTORY.savedVars.enabledCategories[ITEMFILTERTYPE_STOLEN] or false
end

local filterTypeComparators = {
	[ITEMFILTERTYPE_CONTAINER]			= function(itemData) return isContainerItem(itemData) end,
	[ITEMFILTERTYPE_FOOD_DRINK]			= function(itemData) return isFoodItem(itemData) end,
	[ITEMFILTERTYPE_MAPS]				= function(itemData) return isMapItem(itemData) end,
	[ITEMFILTERTYPE_POTION]				= function(itemData) return isPotionItem(itemData) end,
	[ITEMFILTERTYPE_RECIPE_STYLE_PAGE]	= function(itemData) return isRecipeItem(itemData) end,
	[ITEMFILTERTYPE_REPAIR]				= function(itemData) return isRepairItem(itemData) end,
	[ITEMFILTERTYPE_SIEGE]				= function(itemData) return isSiegeItem(itemData) end,
	[ITEMFILTERTYPE_TREASURE]			= function(itemData) return isTreasureItem(itemData) end,
	[ITEMFILTERTYPE_WRIT]				= function(itemData) return isWritItem(itemData) end,
	
	[ITEMFILTERTYPE_STOLEN]				= function(itemData) return isStolenItem(itemData) end,
	[ITEMFILTERTYPE_JUNK]				= function(itemData) return isJunkItem(itemData) end,
}

local function comparatorDoFiltersMatch(filter, filterType)
	return filter == filterType
end

---------------------------------------------------------------------------------------------------------------
-- Helper functions
---------------------------------------------------------------------------------------------------------------
local function parseFilterData(itemData, comparator, filterType)
	for i, filter in ipairs(itemData.filterData) do
		if comparator(filter, filterType) then
			return true
		end
	end
	return false
end

local function getFilteredItemListData(comparator)
	local list = {}
	
	for k, slotData in pairs(GAMEPAD_INVENTORY.itemList.dataList) do
		if comparator(slotData) then
			table.insert(list, slotData)
		end
	end
	return list
end

---------------------------------------------------------------------------------------------------------------
-- Category Description functions
---------------------------------------------------------------------------------------------------------------
local function GetCategoryTypeFromWeaponType(bagId, slotIndex)
	local weaponType = GetItemWeaponType(bagId, slotIndex)
	if weaponType == WEAPONTYPE_AXE or weaponType == WEAPONTYPE_HAMMER or weaponType == WEAPONTYPE_SWORD or weaponType == WEAPONTYPE_DAGGER then
		return GAMEPAD_WEAPON_CATEGORY_ONE_HANDED_MELEE
	elseif weaponType == WEAPONTYPE_TWO_HANDED_SWORD or weaponType == WEAPONTYPE_TWO_HANDED_AXE or weaponType == WEAPONTYPE_TWO_HANDED_HAMMER then
		return GAMEPAD_WEAPON_CATEGORY_TWO_HANDED_MELEE
	elseif weaponType == WEAPONTYPE_FIRE_STAFF or weaponType == WEAPONTYPE_FROST_STAFF or weaponType == WEAPONTYPE_LIGHTNING_STAFF then
		return GAMEPAD_WEAPON_CATEGORY_DESTRUCTION_STAFF
	elseif weaponType == WEAPONTYPE_HEALING_STAFF then
		return GAMEPAD_WEAPON_CATEGORY_RESTORATION_STAFF
	elseif weaponType == WEAPONTYPE_BOW then
		return GAMEPAD_WEAPON_CATEGORY_TWO_HANDED_BOW
	elseif weaponType ~= WEAPONTYPE_NONE then
		return GAMEPAD_WEAPON_CATEGORY_UNCATEGORIZED
	end
end

local function IsTwoHandedWeaponCategory(categoryType)
	return categoryType == GAMEPAD_WEAPON_CATEGORY_TWO_HANDED_MELEE or
		categoryType == GAMEPAD_WEAPON_CATEGORY_DESTRUCTION_STAFF or
		categoryType == GAMEPAD_WEAPON_CATEGORY_RESTORATION_STAFF or
		categoryType == GAMEPAD_WEAPON_CATEGORY_TWO_HANDED_BOW
end

local ITEM_TYPE_TO_CATEGORY_MAP = {
	[ITEMTYPE_REAGENT] = GAMEPAD_ITEM_CATEGORY_ALCHEMY,
	[ITEMTYPE_POTION_BASE] = GAMEPAD_ITEM_CATEGORY_ALCHEMY,
	[ITEMTYPE_POISON_BASE] = GAMEPAD_ITEM_CATEGORY_ALCHEMY,
	[ITEMTYPE_LURE] = GAMEPAD_ITEM_CATEGORY_BAIT,
	[ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = GAMEPAD_ITEM_CATEGORY_BLACKSMITH,
	[ITEMTYPE_BLACKSMITHING_MATERIAL] = GAMEPAD_ITEM_CATEGORY_BLACKSMITH,
	[ITEMTYPE_BLACKSMITHING_BOOSTER] = GAMEPAD_ITEM_CATEGORY_BLACKSMITH,
	[ITEMTYPE_CLOTHIER_RAW_MATERIAL] = GAMEPAD_ITEM_CATEGORY_CLOTHIER,
	[ITEMTYPE_CLOTHIER_MATERIAL] = GAMEPAD_ITEM_CATEGORY_CLOTHIER,
	[ITEMTYPE_CLOTHIER_BOOSTER] = GAMEPAD_ITEM_CATEGORY_CLOTHIER,
	[ITEMTYPE_FOOD] = GAMEPAD_ITEM_CATEGORY_CONSUMABLE,
	[ITEMTYPE_DRINK] = GAMEPAD_ITEM_CATEGORY_CONSUMABLE,
	[ITEMTYPE_RECIPE] = GAMEPAD_ITEM_CATEGORY_CONSUMABLE,
	[ITEMTYPE_COSTUME] = GAMEPAD_ITEM_CATEGORY_COSTUME,
	[ITEMTYPE_ENCHANTING_RUNE_POTENCY] = GAMEPAD_ITEM_CATEGORY_ENCHANTING,
	[ITEMTYPE_ENCHANTING_RUNE_ASPECT] = GAMEPAD_ITEM_CATEGORY_ENCHANTING,
	[ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = GAMEPAD_ITEM_CATEGORY_ENCHANTING,
	[ITEMTYPE_GLYPH_WEAPON] = GAMEPAD_ITEM_CATEGORY_GLYPHS,
	[ITEMTYPE_GLYPH_ARMOR] = GAMEPAD_ITEM_CATEGORY_GLYPHS,
	[ITEMTYPE_GLYPH_JEWELRY] = GAMEPAD_ITEM_CATEGORY_GLYPHS,
	[ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = GAMEPAD_ITEM_CATEGORY_JEWELRYCRAFTING,
	[ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = GAMEPAD_ITEM_CATEGORY_JEWELRYCRAFTING,
	[ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] = GAMEPAD_ITEM_CATEGORY_JEWELRYCRAFTING,
	[ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = GAMEPAD_ITEM_CATEGORY_JEWELRYCRAFTING,
	[ITEMTYPE_POTION] = GAMEPAD_ITEM_CATEGORY_POTION,
	[ITEMTYPE_INGREDIENT] = GAMEPAD_ITEM_CATEGORY_PROVISIONING,
	[ITEMTYPE_ADDITIVE] = GAMEPAD_ITEM_CATEGORY_PROVISIONING,
	[ITEMTYPE_SPICE] = GAMEPAD_ITEM_CATEGORY_PROVISIONING,
	[ITEMTYPE_FLAVORING] = GAMEPAD_ITEM_CATEGORY_PROVISIONING,
	[ITEMTYPE_SIEGE] = GAMEPAD_ITEM_CATEGORY_SIEGE,
	[ITEMTYPE_AVA_REPAIR] = GAMEPAD_ITEM_CATEGORY_SIEGE,
	[ITEMTYPE_RACIAL_STYLE_MOTIF] = GAMEPAD_ITEM_CATEGORY_STYLE_MATERIAL,
	[ITEMTYPE_STYLE_MATERIAL] = GAMEPAD_ITEM_CATEGORY_STYLE_MATERIAL,
	[ITEMTYPE_SOUL_GEM] = GAMEPAD_ITEM_CATEGORY_SOUL_GEM,
	[ITEMTYPE_LOCKPICK] = GAMEPAD_ITEM_CATEGORY_TOOL,
	[ITEMTYPE_TOOL] = GAMEPAD_ITEM_CATEGORY_TOOL,
	[ITEMTYPE_ARMOR_TRAIT] = GAMEPAD_ITEM_CATEGORY_TRAIT_ITEM,
	[ITEMTYPE_WEAPON_TRAIT] = GAMEPAD_ITEM_CATEGORY_TRAIT_ITEM,
	[ITEMTYPE_JEWELRY_RAW_TRAIT] = GAMEPAD_ITEM_CATEGORY_TRAIT_ITEM,
	[ITEMTYPE_JEWELRY_TRAIT] = GAMEPAD_ITEM_CATEGORY_TRAIT_ITEM,
	[ITEMTYPE_TROPHY] = GAMEPAD_ITEM_CATEGORY_TROPHY,
	[ITEMTYPE_WOODWORKING_RAW_MATERIAL] = GAMEPAD_ITEM_CATEGORY_WOODWORKING,
	[ITEMTYPE_WOODWORKING_MATERIAL] = GAMEPAD_ITEM_CATEGORY_WOODWORKING,
	[ITEMTYPE_WOODWORKING_BOOSTER] = GAMEPAD_ITEM_CATEGORY_WOODWORKING,
}
local function GetCategoryFromItemType(itemType)
	-- This is not an exhaustive map: when we don't have a category we'll just use the raw itemtype instead.
	return ITEM_TYPE_TO_CATEGORY_MAP[itemType]
end

local WEAPON_TYPE_TO_CATEGORY_MAP = {
	[WEAPONTYPE_AXE] = GAMEPAD_ITEM_CATEGORY_AXE,
	[WEAPONTYPE_TWO_HANDED_AXE] = GAMEPAD_ITEM_CATEGORY_AXE,
	[WEAPONTYPE_BOW] = GAMEPAD_ITEM_CATEGORY_BOW,
	[WEAPONTYPE_DAGGER] = GAMEPAD_ITEM_CATEGORY_DAGGER,
	[WEAPONTYPE_HAMMER] = GAMEPAD_ITEM_CATEGORY_HAMMER,
	[WEAPONTYPE_TWO_HANDED_HAMMER] = GAMEPAD_ITEM_CATEGORY_HAMMER,
	[WEAPONTYPE_SHIELD] = GAMEPAD_ITEM_CATEGORY_SHIELD,
	[WEAPONTYPE_HEALING_STAFF] = GAMEPAD_ITEM_CATEGORY_STAFF,
	[WEAPONTYPE_FIRE_STAFF] = GAMEPAD_ITEM_CATEGORY_STAFF,
	[WEAPONTYPE_FROST_STAFF] = GAMEPAD_ITEM_CATEGORY_STAFF,
	[WEAPONTYPE_LIGHTNING_STAFF] = GAMEPAD_ITEM_CATEGORY_STAFF,
	[WEAPONTYPE_SWORD] = GAMEPAD_ITEM_CATEGORY_SWORD,
	[WEAPONTYPE_TWO_HANDED_SWORD] = GAMEPAD_ITEM_CATEGORY_SWORD,
}
local function GetCategoryFromWeapon(itemData)
	local weaponType
	if itemData.bagId and itemData.slotIndex then
		weaponType = GetItemWeaponType(itemData.bagId, itemData.slotIndex)
	else
		weaponType = GetItemLinkWeaponType(itemData.itemLink)
	end
	local category = WEAPON_TYPE_TO_CATEGORY_MAP[weaponType]
	internalassert(category)
	return category
end

local ARMOR_EQUIP_TYPE_TO_CATEGORY_MAP = {
	[EQUIP_TYPE_CHEST] = GAMEPAD_ITEM_CATEGORY_CHEST,
	[EQUIP_TYPE_FEET] = GAMEPAD_ITEM_CATEGORY_FEET,
	[EQUIP_TYPE_HAND] = GAMEPAD_ITEM_CATEGORY_HANDS,
	[EQUIP_TYPE_HEAD] = GAMEPAD_ITEM_CATEGORY_HEAD,
	[EQUIP_TYPE_LEGS] = GAMEPAD_ITEM_CATEGORY_LEGS,
	[EQUIP_TYPE_NECK] = GAMEPAD_ITEM_CATEGORY_AMULET,
	[EQUIP_TYPE_RING] = GAMEPAD_ITEM_CATEGORY_RING,
	[EQUIP_TYPE_SHOULDERS] = GAMEPAD_ITEM_CATEGORY_SHOULDERS,
	[EQUIP_TYPE_WAIST] = GAMEPAD_ITEM_CATEGORY_WAIST,
}
local function GetCategoryFromArmor(itemData)
	local category = ARMOR_EQUIP_TYPE_TO_CATEGORY_MAP[itemData.equipType]
	internalassert(category)
	return category
end

local SPECIALIZED_ITEMTYPE_TO_CATEGORY_MAP = {
	[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD] = ITEM_TYPE_DISPLAY_CATEGORY_RECIPE, -- "Food Recipe"
	[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK] = ITEM_TYPE_DISPLAY_CATEGORY_RECIPE, -- "Drink Recipe"
	[SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING] = ITEM_TYPE_DISPLAY_CATEGORY_FURNISHING, -- "Furnishing Diagram"
	[SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING] = ITEM_TYPE_DISPLAY_CATEGORY_FURNISHING, -- "Furnishing Pattern"
	[SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING] = ITEM_TYPE_DISPLAY_CATEGORY_FURNISHING, -- "Furnishing Praxis"
	[SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING] = ITEM_TYPE_DISPLAY_CATEGORY_FURNISHING, -- "Furnishing Formula"
	[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING] = ITEM_TYPE_DISPLAY_CATEGORY_FURNISHING, -- "Furnishing Design"
	[SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING] = ITEM_TYPE_DISPLAY_CATEGORY_FURNISHING, -- "Furnishing Sketch"
	[SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING] = ITEM_TYPE_DISPLAY_CATEGORY_FURNISHING, -- "Furnishing Blueprint"
	
	[SPECIALIZED_ITEMTYPE_FOOD_ENTREMET] = ITEM_TYPE_DISPLAY_CATEGORY_FOOD, -- "Food"
	[SPECIALIZED_ITEMTYPE_FOOD_FRUIT] = ITEM_TYPE_DISPLAY_CATEGORY_FOOD, -- "Food"
	[SPECIALIZED_ITEMTYPE_FOOD_GOURMET] = ITEM_TYPE_DISPLAY_CATEGORY_FOOD, -- "Food"
	[SPECIALIZED_ITEMTYPE_FOOD_MEAT] = ITEM_TYPE_DISPLAY_CATEGORY_FOOD, -- "Food"
	[SPECIALIZED_ITEMTYPE_FOOD_RAGOUT] = ITEM_TYPE_DISPLAY_CATEGORY_FOOD, -- "Food"
	[SPECIALIZED_ITEMTYPE_FOOD_SAVOURY] = ITEM_TYPE_DISPLAY_CATEGORY_FOOD, -- "Food"
	[SPECIALIZED_ITEMTYPE_FOOD_UNIQUE] = ITEM_TYPE_DISPLAY_CATEGORY_FOOD, -- "Food"
	[SPECIALIZED_ITEMTYPE_FOOD_VEGETABLE] = ITEM_TYPE_DISPLAY_CATEGORY_FOOD, -- "Food"
	[SPECIALIZED_ITEMTYPE_DRINK_ALCOHOLIC] = ITEM_TYPE_DISPLAY_CATEGORY_DRINK, -- "Drinks"
	[SPECIALIZED_ITEMTYPE_DRINK_CORDIAL_TEA] = ITEM_TYPE_DISPLAY_CATEGORY_DRINK, -- "Drinks"
	[SPECIALIZED_ITEMTYPE_DRINK_DISTILLATE] = ITEM_TYPE_DISPLAY_CATEGORY_DRINK, -- "Drinks"
	[SPECIALIZED_ITEMTYPE_DRINK_LIQUEUR] = ITEM_TYPE_DISPLAY_CATEGORY_DRINK, -- "Drinks"
	[SPECIALIZED_ITEMTYPE_DRINK_TEA] = ITEM_TYPE_DISPLAY_CATEGORY_DRINK, -- "Drinks"
	[SPECIALIZED_ITEMTYPE_DRINK_CORDIAL_TEA] = ITEM_TYPE_DISPLAY_CATEGORY_DRINK, -- "Drinks"
	[SPECIALIZED_ITEMTYPE_DRINK_TINCTURE] = ITEM_TYPE_DISPLAY_CATEGORY_DRINK, -- "Drinks"
	[SPECIALIZED_ITEMTYPE_DRINK_TONIC] = ITEM_TYPE_DISPLAY_CATEGORY_DRINK, -- "Drinks"
	[SPECIALIZED_ITEMTYPE_DRINK_UNIQUE] = ITEM_TYPE_DISPLAY_CATEGORY_DRINK, -- "Drinks"
	
	[SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE] = ITEM_TYPE_DISPLAY_CATEGORY_STYLE_MOTIF,	-- "Style Motifs"
	[SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK] = ITEM_TYPE_DISPLAY_CATEGORY_STYLE_MOTIF,	-- "Style Motifs"
	[SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER] = ITEM_TYPE_DISPLAY_CATEGORY_STYLE_MOTIF,	-- "Style Motifs"
	[SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE] = ITEM_TYPE_DISPLAY_CATEGORY_STYLE_MOTIF,	-- "Style Motifs"
	
	
}

local function GetCategoryForCustomFilterTypes(itemData)
	local category = SPECIALIZED_ITEMTYPE_TO_CATEGORY_MAP[itemData.specializedItemType]
	internalassert(category)
	return category
end

local CATEGORY_BY_SORT_TYPE = {
    [ITEM_LIST_SORT_TYPE_CATEGORY]		= function(itemData) 
		if itemData.isJunk and CURRENT_CATEGORY_FILTER ~= ITEMFILTERTYPE_JUNK then
		--	itemData.sellInformationSortOrder = 1
			return zo_strformat(SI_INVENTORY_HEADER, GetString(SI_ITEMFILTERTYPE9))
		end
		
		if isCutomCategory[CURRENT_CATEGORY_FILTER] then
			local category = GetCategoryForCustomFilterTypes(itemData)
			
			if CURRENT_CATEGORY_FILTER == ITEMFILTERTYPE_POTION then
				if itemData.name:match('Crown') then
					category = ITEM_TYPE_DISPLAY_CATEGORY_CROWN_ITEM -- 28
				elseif GetItemCreatorName(itemData.bagId, itemData.slotIndex) ~= '' then	-- crafted
					category = ITEM_TYPE_DISPLAY_CATEGORY_CRAFTED
				end
			end
			
			if CURRENT_CATEGORY_FILTER == ITEMFILTERTYPE_FOOD_DRINK then
				if itemData.name:match('Crown') then
					category = ITEM_TYPE_DISPLAY_CATEGORY_CROWN_ITEM -- 28
				end
			end
			
			if category then
				return GetString("SI_ITEMTYPEDISPLAYCATEGORY", category)
			end
			return zo_strformat(SI_INVENTORY_HEADER, GetString("SI_SPECIALIZEDITEMTYPE", itemData.specializedItemType))
		end
		
		local category = nil
		
		if itemData.itemType == ITEMTYPE_WEAPON then
			category = GetCategoryFromWeapon(itemData)
		elseif itemData.itemType == ITEMTYPE_ARMOR then
			category = GetCategoryFromArmor(itemData)
		else
			category = GetCategoryFromItemType(itemData.itemType)
		end
		
		if category then
			return GetString("SI_GAMEPADITEMCATEGORY", category)
		end
		
		return zo_strformat(SI_INVENTORY_HEADER, GetString("SI_ITEMTYPE", itemData.itemType))
	end,
    [ITEM_LIST_SORT_TYPE_ITEM_NAME]		= function(itemData)
		local initial = itemData.name:sub(1, 1)
		initial = initial:match('^%d') == nil and initial or '#'
		return initial
	end,
    [ITEM_LIST_SORT_TYPE_ITEM_QUALITY]	= function(itemData)
		return GetString('SI_ITEMDISPLAYQUALITY', itemData.displayQuality)
	end,
    [ITEM_LIST_SORT_TYPE_STACK_COUNT]	= function(itemData)
		local count = 0
	
		if itemData.stackCount > 0 then
			if itemData.stackCount <= 10 then
				count = '0 - 10'
			elseif itemData.stackCount <= 100 then
				count = '11 - 100'
			elseif itemData.stackCount <= 200 then
				count = '100 - 200'
			else
				count = '> 200'
			end
		end
		
		return count
	end,
    [ITEM_LIST_SORT_TYPE_VALUE]			= function(itemData) return end,
}

function ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription(itemData)
	local getCategory = CATEGORY_BY_SORT_TYPE[GAMEPAD_INVENTORY.currentSortType] or CATEGORY_BY_SORT_TYPE[ITEM_LIST_SORT_TYPE_CATEGORY]
	return getCategory(itemData)
end


local getGamepadCategory = CATEGORY_BY_SORT_TYPE[ITEM_LIST_SORT_TYPE_CATEGORY]



--[[
---------------------------------------------------------------------------------------------------------------
-- Main Filters
---------------------------------------------------------------------------------------------------------------
function IJA_GPInventory:InitializeInventoryFilters()
	--	Supplies Category filters
	local function IJA_GPInventory_DoesNewItemMatchFilterType(itemData)
		for i, filter in ipairs(itemData.filterData) do
			if isCutomCategory[filter] then
				return true
			end
		end
		
		local ignore = itemData.stolen and IJA_GPINVENTORY.savedVars.enabledCategories[ITEMFILTERTYPE_STOLEN] or 
			itemData.isJunk and IJA_GPINVENTORY.savedVars.enabledCategories[ITEMFILTERTYPE_JUNK]
		return ignore
	end

	local old_ZO_InventoryUtils_DoesNewItemMatchSupplies = ZO_InventoryUtils_DoesNewItemMatchSupplies
	function ZO_InventoryUtils_DoesNewItemMatchSupplies(itemData)
		return old_ZO_InventoryUtils_DoesNewItemMatchSupplies(itemData)
			and not IJA_GPInventory_DoesNewItemMatchFilterType(itemData)
	end

	--	categoryList and itemList filters
	local original_GetItemDataFilterComparator = GAMEPAD_INVENTORY.GetItemDataFilterComparator
	function GAMEPAD_INVENTORY:GetItemDataFilterComparator(filteredEquipSlot, nonEquipableFilterType)
		return function(itemData)
			-- comparator == ZOS original or libFilters3_v3
			local comparator = original_GetItemDataFilterComparator(GAMEPAD_INVENTORY, filteredEquipSlot, nonEquipableFilterType)
			
			if comparator(itemData) then
				if itemData.IJA_CustomFilterFunction then
					if filteredEquipSlot or nonEquipableFilterType then
						return itemData:IJA_CustomFilterFunction(filteredEquipSlot, nonEquipableFilterType)
					end
				end
				return true
			end
			
			return false
		end
	end

	local function customFilterFunction(itemData, filteredEquipSlot, nonEquipableFilterType)
		local currentFilter = currentCategoryFilter
		
		if itemData.IJA_FilterType and itemData.IJA_FilterType ~= nonEquipableFilterType then return false end
		
		if filteredEquipSlot then
			return true
		end
		
        if nonEquipableFilterType then
			if isCutomCategory[filterType] then
				if filterType == 9 then d(GetItemLink(itemData.bagId, itemData.slotIndex)) end
				return parseFilterData(itemData, comparatorDoFiltersMatch, filterType)
			end
        end

		return true
	end
	
	-- get filterType based on comparators to be used for filtering
	local function slotDataToFilterType(itemData)
		local filterType = ITEMFILTERTYPE_ALL

		for filter, comparator in pairs(filterTypeComparators) do
			if comparator(itemData) and IJA_GPINVENTORY.savedVars.enabledCategories[filter] then
				filterType = filter
			end
		end
		
		return filterType
	end

	-- add custom filterType to slotData.filterData
	local function addFilterToSlotData(slotData, filterType)
		table.insert(slotData.filterData, filterType)
		slotData.IJA_FilterType = filterType
	end
	
	local function updateSlotData(slotData)
		if slotData == nil then return end
		slotData.IJA_FilterType = nil
		
		local filterType = slotDataToFilterType(slotData)
		
		slotData.IJA_CustomFilterFunction = function(self, filteredEquipSlot, nonEquipableFilterType) return customFilterFunction(self, filteredEquipSlot, nonEquipableFilterType) end
		if filterType == ITEMFILTERTYPE_ALL then return end
		
		if not parseFilterData(slotData, comparatorDoFiltersMatch, filterType) then addFilterToSlotData(slotData, filterType) end
		
		if isStolenItem(slotData) then
			addFilterToSlotData(slotData, ITEMFILTERTYPE_STOLEN)
		elseif isJunkItem(slotData) then
			addFilterToSlotData(slotData, ITEMFILTERTYPE_JUNK)
		end
	end
	
	local function onSingleSlotUpdate(bagId, slotIndex) 
		local bagCache = SHARED_INVENTORY:GetBagCache(bagId)
		if bagCache == nil then return end
		updateSlotData(bagCache[slotIndex]) 
	end
	
	local function onBagCacheUpdate(bagId)
		local bagCache = SHARED_INVENTORY:GetBagCache(bagId)
		if bagCache == nil then return end
		for slotIndex, slotData in pairs(bagCache) do
			updateSlotData(slotData)
		end
	end

	-- this may be done after the list is updated. need to verify
	SHARED_INVENTORY:RegisterCallback("SingleSlotInventoryUpdate", onSingleSlotUpdate)
	SHARED_INVENTORY:RegisterCallback("FullInventoryUpdate", onBagCacheUpdate)
	SHARED_INVENTORY.refresh:RefreshAll("inventory")
end
]]

-- must be above SlotData_Extended
---------------------------------------------------------------------------------------------------------------
local INVENTORY_SEARCH_FILTERS = {}
local function isTableEmpty(tble)
	local isEmpty = true
	if ZO_IsTableEmpty(tble) then return true end
	for k, v in pairs(tble) do
		if not ZO_IsTableEmpty(v) then
			isEmpty = false
		end
	end
	
	return isEmpty
end

local function IsInFilteredCategories(filterCategories, itemData)
	-- No category selected, don't filter out anything.
	if ZO_IsTableEmpty(filterCategories) then
		return true
	end
	for _, filterData in ipairs(itemData.filterData) do
		if filterCategories[filterData] then
			return true
		end
	end
	return false
end

local function insertQualityFilters(itemData)
	if not INVENTORY_SEARCH_FILTERS.displayQuality then INVENTORY_SEARCH_FILTERS.displayQuality = {} end
	
	local displayQuality = GetString('SI_ITEMDISPLAYQUALITY', itemData.displayQuality)
	if not INVENTORY_SEARCH_FILTERS.displayQuality[displayQuality] then
		local color = GetItemQualityColor(itemData.displayQuality)
	--	INVENTORY_SEARCH_FILTERS.displayQuality[displayQuality] = color:Colorize(displayQuality)
	
		INVENTORY_SEARCH_FILTERS.displayQuality[displayQuality] = displayQuality
	end
end

local function insertSpecializedItemTypeFilter(itemData)
	local specializedItemType = GetString('SI_SPECIALIZEDITEMTYPE', itemData.specializedItemType)
	if specializedItemType == '' then return end
	
	if not INVENTORY_SEARCH_FILTERS.specializedItemType then INVENTORY_SEARCH_FILTERS.specializedItemType = {} end
	if not INVENTORY_SEARCH_FILTERS.specializedItemType[specializedItemType] then
		INVENTORY_SEARCH_FILTERS.specializedItemType[specializedItemType] = specializedItemType
	end
end

local function insertGamepadCategoryFilter(itemData)
	if not INVENTORY_SEARCH_FILTERS.bestItemCategoryName then INVENTORY_SEARCH_FILTERS.bestItemCategoryName = {} end
	if not INVENTORY_SEARCH_FILTERS.bestItemCategoryName[itemData.bestItemCategoryName] then
		INVENTORY_SEARCH_FILTERS.bestItemCategoryName[itemData.bestItemCategoryName] = itemData.bestItemCategoryName
	end
	insertSpecializedItemTypeFilter(itemData)
end

local function inserEquipmentFilters(itemData)
	if not itemData.setName then return end
	if not INVENTORY_SEARCH_FILTERS.setName then INVENTORY_SEARCH_FILTERS.setName = {} end
	if not INVENTORY_SEARCH_FILTERS.setName[itemData.setName] then
		INVENTORY_SEARCH_FILTERS.setName[itemData.setName] = itemData.setName
	end
end

local function insertWeaponFilters(itemData)
	local weaponType = GetString('SI_WEAPONTYPE', itemData.weaponType)
	if not INVENTORY_SEARCH_FILTERS.weaponType then INVENTORY_SEARCH_FILTERS.weaponType = {} end
	if not INVENTORY_SEARCH_FILTERS.weaponType[weaponType] and weaponType ~= WEAPONTYPE_NONE then
		INVENTORY_SEARCH_FILTERS.weaponType[weaponType] = weaponType
	end
	inserEquipmentFilters(itemData)
end

local function insertArmorFilters(itemData)
	local armorType = GetString('SI_ARMORTYPE', itemData.armorType)
	if not INVENTORY_SEARCH_FILTERS.armorType then INVENTORY_SEARCH_FILTERS.armorType = {} end
	if not INVENTORY_SEARCH_FILTERS.armorType[armorType] and armorType ~= ARMORTYPE_NONE then
		INVENTORY_SEARCH_FILTERS.armorType[armorType] = armorType
	end
	inserEquipmentFilters(itemData)
end

local function insertFilter(itemData)
	if itemData.itemType == ITEMTYPE_WEAPON and itemData.actorCategory ~= GAMEPLAY_ACTOR_CATEGORY_COMPANION then
		insertWeaponFilters(itemData)
	elseif itemData.itemType == ITEMTYPE_ARMOR and itemData.actorCategory ~= GAMEPLAY_ACTOR_CATEGORY_COMPANION then
		insertArmorFilters(itemData)
	else
		insertGamepadCategoryFilter(itemData)
	end
	
	insertQualityFilters(itemData)
end

local function getAvailableFilters()
	local filters = {}
	
	for name, category in pairs(INVENTORY_SEARCH_FILTERS) do
		if NonContiguousCount(category) > 1 or name == 'setName' then
			local data = {
				name = name,
				category = category,
			}
			table.insert(filters, data)
		end
	end
	
	return filters
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
local SlotData_Extended = {}

-- get filterType based on comparators to be used for filtering
local function slotDataToFilterType(itemData)
	local filterType = ITEMFILTERTYPE_ALL

	for filter, comparator in pairs(filterTypeComparators) do
		if comparator(itemData) and IJA_GPINVENTORY.savedVars.enabledCategories[filter] then
			filterType = filter
		end
	end
	
	return filterType
end

function SlotData_Extended:Update_Extended(slotData, bagId, slotIndex)
	self.IJA_FilterType = nil
	self.bagId = bagId
	self.slotIndex = slotIndex
	
	zo_mixin(slotData, self)
	
	slotData:IJA_SetAditionalFilters()
	
	local filterType = slotDataToFilterType(slotData)
		
	if filterType == ITEMFILTERTYPE_ALL then return end
	
	if not slotData:IJA_ParseFilterData(comparatorDoFiltersMatch, filterType) then slotData:IJA_AddFilterToSlotData(filterType) end
	
	if isStolenItem(slotData) then
		slotData:IJA_AddFilterToSlotData(ITEMFILTERTYPE_STOLEN)
	elseif isJunkItem(slotData) then
		slotData:IJA_AddFilterToSlotData(ITEMFILTERTYPE_JUNK)
	end
end

function SlotData_Extended:IJA_ParseFilterData(comparator, filterType)
	for i, filter in ipairs(self.filterData) do
		if comparator(filter, filterType) then
			insertFilter(self)
			return true
		end
	end
	return false
end

function SlotData_Extended:IJA_CustomFilterFunction(filteredEquipSlot, nonEquipableFilterType)
	if self.IJA_FilterType and self.IJA_FilterType ~= nonEquipableFilterType then return false end
	
	if nonEquipableFilterType then
		-- only non-equipment items are used in custom categories
		if isCutomCategory[nonEquipableFilterType] then
			if filterType == 9 then d(GetItemLink(self.bagId, self.slotIndex)) end
			return self:IJA_ParseFilterData(comparatorDoFiltersMatch, nonEquipableFilterType)
		end
	end
	
	insertFilter(self)
	return true
end

-- add custom filterType to slotData.filterData
function SlotData_Extended:IJA_AddFilterToSlotData(filterType)
	table.insert(self.filterData, filterType)
	self.IJA_FilterType = filterType
end

function SlotData_Extended:IJA_SetAditionalFilters()
	self.weaponType = GetItemWeaponType(self.bagId, self.slotIndex) or 0
	self.armorType = GetItemArmorType(self.bagId, self.slotIndex) or 0
	
	if self.weaponType > 0 then
		table.insert(self.filterData, GetString('SI_WEAPONTYPE', self.weaponType))
	end
	if self.armorType > 0 then
		table.insert(self.filterData, GetString('SI_ARMORTYPE', self.armorType))
	end
	
	self.itemLink = GetItemLink(self.bagId, self.slotIndex)
	
	local hasSet, setName, numBonuses, numNormalEquipped, maxEquipped, setId, numPerfectedEquipped = GetItemLinkSetInfo(self.itemLink)
	if setName then 
		self.setName = setName
		self.setId = setId or 0
		table.insert(self.filterData, self.setName)
	end
	self.bestItemCategoryName = getGamepadCategory(self)
	table.insert(self.filterData, self.bestItemCategoryName)
	
	table.insert(self.filterData, GetString('SI_ITEMDISPLAYQUALITY', self.displayQuality))
	table.insert(self.filterData, GetString('SI_SPECIALIZEDITEMTYPE', self.specializedItemType))
end


local INVENTORY_SORT_PRIMARY_KEY =
{
    [ITEM_LIST_SORT_TYPE_CATEGORY] = "bestItemCategoryName",
    [ITEM_LIST_SORT_TYPE_ITEM_NAME] = "name",
    [ITEM_LIST_SORT_TYPE_ITEM_QUALITY] = "displayQuality",
    [ITEM_LIST_SORT_TYPE_STACK_COUNT] = "stackCount",
    [ITEM_LIST_SORT_TYPE_VALUE] = "sellPrice",
}

local SORT_OPTIONS =
{
    bestItemCategoryName = { tiebreaker = "name" },
    displayQuality = { tiebreaker = "name", isNumeric = true, tieBreakerSortOrder = ZO_SORT_ORDER_UP },
    stackCount = { tiebreaker = "name", isNumeric = true, tieBreakerSortOrder = ZO_SORT_ORDER_UP },
    sellPrice = { tiebreaker = "name", isNumeric = true, tieBreakerSortOrder = ZO_SORT_ORDER_UP },
    name = { tiebreaker = "requiredLevel" },
    requiredLevel = { tiebreaker = "requiredChampionPoints", isNumeric = true },
    requiredChampionPoints = { tiebreaker = "iconFile", isNumeric = true },
    iconFile = { tiebreaker = "uniqueId" },
    uniqueId = { isId64 = true },
}

---------------------------------------------------------------------------------------------------------------
-- Main Filters
---------------------------------------------------------------------------------------------------------------
function IJA_GPInventory:InitializeInventoryFilters()
	--	Supplies Category filters
	local function IJA_GPInventory_DoesNewItemMatchFilterType(itemData)
		for i, filter in ipairs(itemData.filterData) do
			if isCutomCategory[filter] then
				return true
			end
		end
		
		local ignore = itemData.stolen and IJA_GPINVENTORY.savedVars.enabledCategories[ITEMFILTERTYPE_STOLEN] or 
			itemData.isJunk and IJA_GPINVENTORY.savedVars.enabledCategories[ITEMFILTERTYPE_JUNK]
		return ignore
	end

	local original_ZO_InventoryUtils_DoesNewItemMatchSupplies = ZO_InventoryUtils_DoesNewItemMatchSupplies
	function ZO_InventoryUtils_DoesNewItemMatchSupplies(itemData)
		return original_ZO_InventoryUtils_DoesNewItemMatchSupplies(itemData)
			and not IJA_GPInventory_DoesNewItemMatchFilterType(itemData)
	end

	--	categoryList and itemList filters
	local original_GetItemDataFilterComparator = GAMEPAD_INVENTORY.GetItemDataFilterComparator
	function GAMEPAD_INVENTORY:GetItemDataFilterComparator(filteredEquipSlot, nonEquipableFilterType)
		return function(itemData)
			-- comparator == ZOS original or libFilters3_v3
			local comparator = original_GetItemDataFilterComparator(GAMEPAD_INVENTORY, filteredEquipSlot, nonEquipableFilterType)
			
			local passesCategoryFilter = IsInFilteredCategories(self.filterCategories, itemData)
			
			if comparator(itemData) and passesCategoryFilter then
				if itemData.IJA_CustomFilterFunction then
					if filteredEquipSlot or nonEquipableFilterType then
						return itemData:IJA_CustomFilterFunction(filteredEquipSlot, nonEquipableFilterType)
					end
				end
				insertFilter(itemData)
				return true
			end
			
			return false
		end
	end

	local function onSingleSlotUpdate(bagId, slotIndex) 
		local bagCache = SHARED_INVENTORY:GetBagCache(bagId)
		if bagCache then
			local slotData = bagCache[slotIndex]
			if slotData == nil then return end
		--	updateSlotData(bagCache[slotIndex])
			SlotData_Extended:Update_Extended(slotData, bagId, slotIndex)
		end
	end
	
	local function onBagCacheUpdate(bagId)
		local bagCache = SHARED_INVENTORY:GetBagCache(bagId)
		if bagCache == nil then return end
		for slotIndex, slotData in pairs(bagCache) do
		--	updateSlotData(slotData)
			SlotData_Extended:Update_Extended(slotData, bagId, slotIndex)
		end
	end

	-- this may be done after the list is updated. need to verify
	SHARED_INVENTORY:RegisterCallback("SingleSlotInventoryUpdate", onSingleSlotUpdate)
	SHARED_INVENTORY:RegisterCallback("FullInventoryUpdate", onBagCacheUpdate)
	SHARED_INVENTORY.refresh:RefreshAll("inventory")
end

---------------------------------------------------------------------------------------------------------------
-- Inventory filtering and sorting
---------------------------------------------------------------------------------------------------------------
function GAMEPAD_INVENTORY:InitializeFiltersDialog()
	local function setupList(filters, categoryName)
		local list = {
			header = GetString(SI_GAMEPAD_BANK_FILTER_HEADER) .. ' | ' .. categoryName:sub(1,1):upper() .. categoryName:sub(2):lower(),
			template = "ZO_GamepadMultiSelectionDropdownItem",
			templateData =
			{
				setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
					local dialog = data.dialog
					local dialogData = dialog and dialog.data
					local inventory = dialogData.inventory
					local dropdown = control.dropdown
					table.insert(dialog.dropdowns, dropdown)
					dropdown:SetNormalColor(ZO_GAMEPAD_COMPONENT_COLORS.UNSELECTED_INACTIVE:UnpackRGB())
					dropdown:SetHighlightedColor(ZO_GAMEPAD_COMPONENT_COLORS.SELECTED_ACTIVE:UnpackRGB())
					dropdown:SetSelectedItemTextColor(selected)
					dropdown:SetSortsItems(false)
					dropdown:SetNoSelectionText(GetString(SI_GAMEPAD_BANK_FILTER_DEFAULT_TEXT))
					dropdown:SetMultiSelectionTextFormatter(GetString(SI_GAMEPAD_BANK_FILTER_DROPDOWN_TEXT))
					local dropdownData = ZO_MultiSelection_ComboBox_Data_Gamepad:New()
					dropdownData:Clear()
					
					table.sort(filters)
					for filter, filterName in pairs(filters) do
						local newEntry = ZO_ComboBox_Base:CreateItemEntry(ZO_CachedStrFormat(SI_GAMEPAD_BANK_FILTER_ENTRY_FORMATTER, filterName))
						newEntry.filter = filter
						newEntry.categoryName = data.name
						
						newEntry.callback = function(control, name, item, isSelected)
							if isSelected then
								inventory.filterCategories[item.filter] = true
							else
								inventory.filterCategories[item.filter] = nil
							end
						end
						
						dropdownData:AddItem(newEntry)
						if inventory.filterCategories[filter] then
							dropdownData:ToggleItemSelected(newEntry)
						end
					end
					dropdown:LoadData(dropdownData)
					
				end,
				callback = function(dialog)
					local targetData = dialog.entryList:GetTargetData()
					local targetControl = dialog.entryList:GetTargetControl()
					targetControl.dropdown:Activate()
				end,
			}
		}

		return list
	end

	local function OnReleaseDialog(dialog)
		if dialog.dropdowns then
			for _, dropdown in ipairs(dialog.dropdowns) do
				dropdown:Deactivate()
			end
		end
		dialog.dropdowns = nil
	end
	
	-- ESO_Dialogs['GAMEPAD_INVENTORY_SEARCH_FILTERS']
	ZO_Dialogs_RegisterCustomDialog("GAMEPAD_INVENTORY_SEARCH_FILTERS",
	{
		gamepadInfo =
		{
			dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
		},
		
		parametricList = {},
		setup =  function(dialog, data)
			ZO_GenericGamepadDialog_RefreshText(dialog, GetString(SI_GAMEPAD_GUILD_BROWSER_FILTERS_DIALOG_HEADER))
			dialog.dropdowns = {}
			dialog.selectedSortType = dialog.selectedSortType or ITEM_LIST_SORT_TYPE_ITERATION_BEGIN
			local DONT_LIMIT_NUM_ENTRIES = nil
			dialog:setupFunc(DONT_LIMIT_NUM_ENTRIES, data)
			
			
			local parametricList = dialog.info.parametricList
			ZO_ClearNumericallyIndexedTable(parametricList)
			
			
			local sortList = {
				header = GetString(SI_GAMEPAD_BANK_SORT_TYPE_HEADER),
				template = "ZO_GamepadDropdownItem",
				templateData =
				{
					setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
						local dialogData = data and data.dialog and data.dialog.data
						local inventory = dialogData.inventory
						local dropdown = control.dropdown
						table.insert(data.dialog.dropdowns, dropdown)
						dropdown:SetNormalColor(ZO_GAMEPAD_COMPONENT_COLORS.UNSELECTED_INACTIVE:UnpackRGB())
						dropdown:SetHighlightedColor(ZO_GAMEPAD_COMPONENT_COLORS.SELECTED_ACTIVE:UnpackRGB())
						dropdown:SetSelectedItemTextColor(selected)
						dropdown:SetSortsItems(false)
						dropdown:ClearItems()
						local function OnSelectedCallback(dropdown, entryText, entry)
							inventory.currentSortType = entry.sortType
						end
						for i = ITEM_LIST_SORT_TYPE_ITERATION_BEGIN, ITEM_LIST_SORT_TYPE_ITERATION_END do
							local entryText = ZO_CachedStrFormat(SI_GAMEPAD_BANK_FILTER_ENTRY_FORMATTER, GetString("SI_ITEMLISTSORTTYPE", i))
							local newEntry = control.dropdown:CreateItemEntry(entryText, OnSelectedCallback)
							newEntry.sortType = i
							control.dropdown:AddItem(newEntry)
						end
						dropdown:UpdateItems()
						control.dropdown:SelectItemByIndex(inventory.currentSortType)
					end,
					callback = function(dialog)
						local targetData = dialog.entryList:GetTargetData()
						local targetControl = dialog.entryList:GetTargetControl()
						targetControl.dropdown:Activate()
					end,
				},
			}			
			table.insert(parametricList, sortList)

			local sortOrder = {
				header = GetString(SI_GAMEPAD_BANK_SORT_ORDER_HEADER),
				template = "ZO_GamepadDropdownItem",
				templateData =
				{
					setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
						local dialog = data.dialog
						local dialogData = dialog and dialog.data
						local inventory = dialogData.inventory
						local dropdown = control.dropdown
						table.insert(dialog.dropdowns, dropdown)
						dropdown:SetNormalColor(ZO_GAMEPAD_COMPONENT_COLORS.UNSELECTED_INACTIVE:UnpackRGB())
						dropdown:SetHighlightedColor(ZO_GAMEPAD_COMPONENT_COLORS.SELECTED_ACTIVE:UnpackRGB())
						dropdown:SetSelectedItemTextColor(selected)
						dropdown:SetSortsItems(false)
						dropdown:ClearItems()
						local function OnSelectedCallback(dropdown, entryText, entry)
							inventory.currentSortOrder = entry.sortOrder
							inventory.currentSortOrderIndex = entry.index
						end
						local sortUpEntry = control.dropdown:CreateItemEntry(GetString(SI_GAMEPAD_BANK_SORT_ORDER_UP_TEXT), OnSelectedCallback)
						sortUpEntry.sortOrder = ZO_SORT_ORDER_UP
						sortUpEntry.index = 1
						control.dropdown:AddItem(sortUpEntry)
						local sortDownEntry = control.dropdown:CreateItemEntry(GetString(SI_GAMEPAD_BANK_SORT_ORDER_DOWN_TEXT), OnSelectedCallback)
						sortDownEntry.sortOrder = ZO_SORT_ORDER_DOWN
						sortDownEntry.index = 2
						control.dropdown:AddItem(sortDownEntry)
						dropdown:UpdateItems()
						control.dropdown:SelectItemByIndex(inventory.currentSortOrderIndex)
					end,
					callback = function(dialog)
						local targetData = dialog.entryList:GetTargetData()
						local targetControl = dialog.entryList:GetTargetControl()
						targetControl.dropdown:Activate()
					end,
				},
			}
			table.insert(parametricList, sortOrder)
			
			local availableFilters = getAvailableFilters()
			if NonContiguousCount(availableFilters) > 1 then
			end
			for k, filter in pairs(availableFilters) do
				table.insert(parametricList, setupList(filter.category, filter.name))
			end
			
			dialog:setupFunc(DONT_LIMIT_NUM_ENTRIES, data)
		end,
		blockDialogReleaseOnPress = true,
		buttons =
		{
			{
				keybind = "DIALOG_PRIMARY",
				text = SI_GAMEPAD_SELECT_OPTION,
				callback = function(dialog)
					local targetData = dialog.entryList:GetTargetData()
					if targetData and targetData.callback then
						targetData.callback(dialog)
					end
				end,
			},
			{
				keybind = "DIALOG_NEGATIVE",
				text = SI_DIALOG_CANCEL,
				callback =  function(dialog)
					local dialogData = dialog.data
					ZO_Dialogs_ReleaseDialogOnButtonPress("GAMEPAD_INVENTORY_SEARCH_FILTERS")
					
					if dialogData.inventory.currentListType == "craftBagList" then
						GAMEPAD_INVENTORY.craftBagList.filterCategories = dialogData.inventory.filterCategories
					end
					
					dialogData.inventory.onClose = true
					dialogData.inventory:OnUpdate()
				end,
			},
			{
				keybind = "DIALOG_RESET",
				text = SI_GUILD_BROWSER_RESET_FILTERS_KEYBIND,
				enabled = function(dialog)
					local dialogData = dialog.data
					return not dialogData.inventory:AreFiltersSetToDefault()
				end,
				callback = function(dialog)
					local dialogData = dialog and dialog.data
					dialogData.inventory:ResetFilters()
					dialog.info.setup(dialog)
				end,
			},
		},
		onHidingCallback = OnReleaseDialog,
		noChoiceCallback = OnReleaseDialog,
	})

	CALLBACK_MANAGER:RegisterCallback("OnGamepadDialogHidden", function()
		if GAMEPAD_INVENTORY.onClose then
			GAMEPAD_INVENTORY.onClose = false
			local list = GAMEPAD_INVENTORY:GetCurrentList()
			local selectedIndex = list:GetSelectedIndex()
			list:SetSelectedIndex(selectedIndex == 1 and 2 or selectedIndex - 1)
			zo_callLater(function()
				list:SetSelectedIndex(selectedIndex)
			end,100)
		end
	end)
end

function GAMEPAD_INVENTORY:ResetFilters()
	self.filterCategories = {}
	self.currentSortType = ITEM_LIST_SORT_TYPE_CATEGORY
	self.currentSortOrder = ZO_SORT_ORDER_UP
	self.currentSortOrderIndex = 1
	
	INVENTORY_SEARCH_FILTERS = {}
	self.craftBagList.filterCategories = {}
	self:OnUpdate()
end

function GAMEPAD_INVENTORY:AreFiltersSetToDefault()
	return ZO_IsTableEmpty(self.filterCategories) and
		self.currentSortType == ITEM_LIST_SORT_TYPE_CATEGORY and
		self.currentSortOrder == ZO_SORT_ORDER_UP and
		self.currentSortOrderIndex == 1
end

---------------------------------------------------------------------------------------------------------------
-- Header functions
---------------------------------------------------------------------------------------------------------------
local hasSellValue = {
	[ITEMFILTERTYPE_JUNK] = true,
	[ITEMFILTERTYPE_STOLEN] = true,
	[ITEMFILTERTYPE_TREASURE] = true,
}

local function UpdateGold(control)
	ZO_CurrencyControl_SetSimpleCurrency(control, CURT_MONEY, GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER), ZO_GAMEPAD_CURRENCY_OPTIONS_LONG_FORMAT)
	return true
end

local function UpdateCapacityString()
	return zo_strformat(SI_GAMEPAD_INVENTORY_CAPACITY_FORMAT, GetNumBagUsedSlots(BAG_BACKPACK), GetBagSize(BAG_BACKPACK))
end

local function UpdateSellValueString(control)
	local comparetor = GAMEPAD_INVENTORY:GetItemDataFilterComparator(nil, currentCategoryFilter)
	
	local bagCache = SHARED_INVENTORY:GenerateFullSlotData(comparetor, BAG_BACKPACK)
	
	local total = 0
	for slotId, itemData in pairs(bagCache) do
		total = total + itemData.stackSellPrice
	end
	return zo_strformat(SI_TOOLTIP_ITEM_VALUE_FORMAT, total, GetString(SI_GAMEPAD_INVENTORY_AVAILABLE_FUNDS))
end

local function dynamicMapHeaders_SetTextAndCount(index, header, count)
	GAMEPAD_INVENTORY.IJA_mapsHeaderData['data' .. index .. 'HeaderText'] = zo_strformat(SI_INVENTORY_HEADER, header)
	GAMEPAD_INVENTORY.IJA_mapsHeaderData['data' .. index .. 'Text'] = zo_strformat(SI_TOOLTIP_ITEM_VALUE_FORMAT, count, "")
end
local function dynamicMapHeaders_Clear()
	dynamicMapHeaders_SetTextAndCount(3)
	dynamicMapHeaders_SetTextAndCount(4)
end
local function dynamicMapHeaders_Set(surveyCache, mapCache)
	local function getSurveyCount(surveyCache)
		local count = 0
		for k, itemData in pairs(surveyCache) do
			count = count + itemData.stackCount
		end
		return count
	end
	
	local plural = GetString(SI_IJA_GPINVENTORY_PLURAL)
	
	local index = 3
	if #surveyCache > 0 then
		local surveyString = zo_strformat(SI_IJA_GPINVENTORY_PLURAL, GetString(SI_SPECIALIZEDITEMTYPE101))
		dynamicMapHeaders_SetTextAndCount(index, surveyString, getSurveyCount(surveyCache))
		index = index + 1
	end
	if #mapCache > 0 then
		local mapString = zo_strformat(SI_IJA_GPINVENTORY_PLURAL, GetString(SI_SPECIALIZEDITEMTYPE100))
		dynamicMapHeaders_SetTextAndCount(index, mapString, #mapCache)
	end
end
local function dynamicMapHeaders_Update()
	local getComparator = function(specialized_itemtype)
		return function(itemData)
			if itemData.specializedItemType == specialized_itemtype then
				return not isJunkItem(itemData) and not isStolenItem(itemData)
			end
		end
	end
	
	local isMap			= getComparator(SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP)
	local isSurvey		= getComparator(SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT)

	local mapCache		= getFilteredItemListData(isMap)
	local surveyCache	= getFilteredItemListData(isSurvey)

	dynamicMapHeaders_Clear()
	dynamicMapHeaders_Set(surveyCache, mapCache)
end
 
ZO_PostHook(GAMEPAD_INVENTORY, "InitializeHeader", function(self)
	local function UpdateTitleText()
		return GetString("SI_ITEMFILTERTYPE", currentCategoryFilter)
	end

	self.IJA_customHeaderData = {
		titleText = UpdateTitleText,
		data1HeaderText = GetString(SI_GAMEPAD_INVENTORY_AVAILABLE_FUNDS),
		data1Text = UpdateGold,

		data2HeaderText = GetString(SI_GAMEPAD_INVENTORY_CAPACITY),
		data2Text = UpdateCapacityString,
	}
	
	self.IJA_customHeaderWithValueData = {
		titleText = UpdateTitleText,
		data1HeaderText = GetString(SI_GAMEPAD_INVENTORY_AVAILABLE_FUNDS),
		data1Text = UpdateGold,

		data2HeaderText = GetString(SI_GAMEPAD_INVENTORY_CAPACITY),
		data2Text = UpdateCapacityString,
		
		data3HeaderText = GetString(SI_INVENTORY_SORT_TYPE_PRICE),
		data3Text = UpdateSellValueString,
	}

	self.IJA_mapsHeaderData = {
		titleText = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_MAPS),
		data1HeaderText = GetString(SI_GAMEPAD_INVENTORY_AVAILABLE_FUNDS),
		data1Text = UpdateGold,

		data2HeaderText = GetString(SI_GAMEPAD_INVENTORY_CAPACITY),
		data2Text = UpdateCapacityString,
	}
--	return false
end)

ZO_PreHook(GAMEPAD_INVENTORY, "RefreshHeader", function(self, blockCallback)
    if self:GetCurrentList() == self.itemList then
		local filterType = currentCategoryFilter
		
		if isCutomCategory[filterType] and self:GetCurrentList():IsActive() then
			local headerData
			
			if filterType == ITEMFILTERTYPE_MAPS then
				dynamicMapHeaders_Update()
				headerData = self.IJA_mapsHeaderData
				
			elseif hasSellValue[filterType] then
				headerData = self.IJA_customHeaderWithValueData
				
			else
				headerData = self.IJA_customHeaderData
			end
			
			ZO_GamepadGenericHeader_Refresh(self.header, headerData, blockCallback)
			return true
		end
	end
	
	-- if not custom category then run default RefreshHeader
	return false
end)

---------------------------------------------------------------------------------------------------------------
-- Category list
---------------------------------------------------------------------------------------------------------------
function GAMEPAD_INVENTORY:RefreshCategoryList(selectDefaultEntry)
	if GAMEPAD_INVENTORY.currentListType ~= INVENTORY_CATEGORY_LIST then return end
	self:ResetFilters()
	self.categoryList:Clear()
	
	do -- Currencies
		local name = GetString(SI_INVENTORY_CURRENCIES)
		local iconFile = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_currencies.dds"
		local data = ZO_GamepadEntryData:New(name, iconFile, nil, nil, false)
		data.isCurrencyEntry = true
		data:SetIconTintOnSelection(true)
		self.categoryList:AddEntry("ZO_GamepadItemEntryTemplate", data)
	end

	do -- Supplies
		local isListEmpty = self:IsItemListEmpty()
		if not isListEmpty then
			local name = GetString(SI_INVENTORY_SUPPLIES)
			local iconFile = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_all.dds"
			local hasAnyNewItems = SHARED_INVENTORY:AreAnyItemsNew(ZO_InventoryUtils_DoesNewItemMatchSupplies, nil, BAG_BACKPACK)
			local data = ZO_GamepadEntryData:New(name, iconFile, nil, nil, hasAnyNewItems)
			data:SetIconTintOnSelection(true)
			self.categoryList:AddEntry("ZO_GamepadItemEntryTemplate", data)
		end
	end

	-- Materials
	self:AddFilteredBackpackCategoryIfPopulated(ITEMFILTERTYPE_CRAFTING, "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_materials.dds")
	-- Consumables
	self:AddFilteredBackpackCategoryIfPopulated(ITEMFILTERTYPE_QUICKSLOT, "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_quickslot.dds")
	-- Furnishing
	self:AddFilteredBackpackCategoryIfPopulated(ITEMFILTERTYPE_FURNISHING, "EsoUI/Art/Crafting/Gamepad/gp_crafting_menuIcon_furnishings.dds")
	-- Companion Items
	self:AddFilteredBackpackCategoryIfPopulated(ITEMFILTERTYPE_COMPANION, "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_companionItems.dds")
	
	do -- Quest Items
		local questCache = SHARED_INVENTORY:GenerateFullQuestCache()
		local textSearchFilterdQuestCache = {}
		for _, questItems in pairs(questCache) do
			for _, questItem in pairs(questItems) do
				if self:GetQuestItemDataFilterComparator(questItem.questItemId) then
					table.insert(textSearchFilterdQuestCache, questCache)
				end
			end
		end

		if next(textSearchFilterdQuestCache) then
			local name = GetString(SI_GAMEPAD_INVENTORY_QUEST_ITEMS)
			local iconFile = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_quest.dds"
			local data = ZO_GamepadEntryData:New(name, iconFile)
			data.filterType = ITEMFILTERTYPE_QUEST
			data:SetIconTintOnSelection(true)
			self.categoryList:AddEntry("ZO_GamepadItemEntryTemplate", data)
		end
	end

	do -- Custom Categories
		local customHeader = nil

		local function addFilteredBackpackCategoryIfEnabled(filterType, iconFile)
			if IJA_GPINVENTORY.savedVars.enabledCategories[filterType] then
				local isListEmpty = self:IsItemListEmpty(nil, filterType)
				if not isListEmpty then
					local name = GetString("SI_ITEMFILTERTYPE", filterType)
					local hasAnyNewItems = SHARED_INVENTORY:AreAnyItemsNew(ZO_InventoryUtils_DoesNewItemMatchFilterType, filterType, BAG_BACKPACK)
					local data = ZO_GamepadEntryData:New(name, iconFile, nil, nil, hasAnyNewItems)
					data.filterType = filterType
					data:SetIconTintOnSelection(true)
					
					if customHeader == nil then
						customHeader = GetString(SI_IJA_GPINVENTORY_CATEGORIES_HEADER)
						self.categoryList:AddEntry("ZO_GamepadItemEntryTemplateWithHeader", data)
						data:SetHeader(customHeader)
					else
						self.categoryList:AddEntry("ZO_GamepadItemEntryTemplate", data)
					end
				end
			end
		end
			
		addFilteredBackpackCategoryIfEnabled(ITEMFILTERTYPE_POTION, "/esoui/art/tradinghouse/gamepad/gp_tradinghouse_materials_potions_potionsolvent.dds")
		addFilteredBackpackCategoryIfEnabled(ITEMFILTERTYPE_FOOD_DRINK, "/esoui/art/tradinghouse/gamepad/gp_tradinghouse_materials_provisioning_food.dds")
		addFilteredBackpackCategoryIfEnabled(ITEMFILTERTYPE_MAPS, "EsoUI/Art/crafting/Gamepad/gp_crafting_menuicon_designs.dds")
		addFilteredBackpackCategoryIfEnabled(ITEMFILTERTYPE_CONTAINER, "/esoui/art/icons/servicemappins/servicepin_bank.dds")
		addFilteredBackpackCategoryIfEnabled(ITEMFILTERTYPE_REPAIR, "/esoui/art/treeicons/gamepad/gp_tools.dds")
		addFilteredBackpackCategoryIfEnabled(ITEMFILTERTYPE_RECIPE_STYLE_PAGE, "/esoui/art/crafting/gamepad/gp_crafting_menuicon_schematics.dds")
		addFilteredBackpackCategoryIfEnabled(ITEMFILTERTYPE_TREASURE, "/esoui/art/tradinghouse/gamepad/gp_tradinghouse_other_trophy_types.dds")
		addFilteredBackpackCategoryIfEnabled(ITEMFILTERTYPE_WRIT, "/esoui/art/tradinghouse/gamepad/gp_tradinghouse_master_writ.dds")
		addFilteredBackpackCategoryIfEnabled(ITEMFILTERTYPE_SIEGE, "/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_ava.dds")
		addFilteredBackpackCategoryIfEnabled(ITEMFILTERTYPE_JUNK, "esoui/art/inventory/inventory_tabicon_junk_up.dds")
		addFilteredBackpackCategoryIfEnabled(ITEMFILTERTYPE_STOLEN, "esoui/art/inventory/gamepad/gp_inventory_icon_stolenitem.dds")
	end
	
	local twoHandIconFile
	local headersUsed = {}
	for i, equipSlot in ZO_Character_EnumerateOrderedEquipSlots() do -- equipable items
		local locked = IsLockedWeaponSlot(equipSlot)
		local isListEmpty = self:IsItemListEmpty(equipSlot, nil)
		if not locked and not isListEmpty then
			local name = zo_strformat(SI_CHARACTER_EQUIP_SLOT_FORMAT, GetString("SI_EQUIPSLOT", equipSlot))
			local iconFile, slotHasItem = GetEquippedItemInfo(equipSlot)
			if not slotHasItem then
				iconFile = nil
			end

			--special case where a two handed weapon icon shows up in offhand slot at lower opacity
			local weaponCategoryType = GetCategoryTypeFromWeaponType(BAG_WORN, equipSlot)
			if iconFile
				and (equipSlot == EQUIP_SLOT_MAIN_HAND or equipSlot == EQUIP_SLOT_BACKUP_MAIN)
				and IsTwoHandedWeaponCategory(weaponCategoryType) then
				twoHandIconFile = iconFile
			end

			local offhandTransparency
			if twoHandIconFile and (equipSlot == EQUIP_SLOT_OFF_HAND or equipSlot == EQUIP_SLOT_BACKUP_OFF) then
				iconFile = twoHandIconFile
				twoHandIconFile = nil
				offhandTransparency = 0.5
			end

			local function DoesNewItemMatchEquipSlot(itemData)
				return ZO_Character_DoesEquipSlotUseEquipType(equipSlot, itemData.equipType)
			end

			local hasAnyNewItems = SHARED_INVENTORY:AreAnyItemsNew(DoesNewItemMatchEquipSlot, nil, BAG_BACKPACK)
			
			local data = ZO_GamepadEntryData:New(name, iconFile, nil, nil, hasAnyNewItems)
			data:SetMaxIconAlpha(offhandTransparency)
			data.equipSlot = equipSlot
			data.filterType = (GetItemFilterTypeInfo(BAG_WORN, equipSlot)) -- first filter only

			if (equipSlot == EQUIP_SLOT_POISON or equipSlot == EQUIP_SLOT_BACKUP_POISON) then
				data.stackCount = select(2, GetItemInfo(BAG_WORN, equipSlot))
			end

			--Headers for Equipment Visual Categories (Weapons, Apparel, Accessories): display header for the first equip slot of a category to be visible 
			local visualCategory = ZO_Character_GetEquipSlotVisualCategory(equipSlot)
			if headersUsed[visualCategory] == nil then
				self.categoryList:AddEntry("ZO_GamepadItemEntryTemplateWithHeader", data)
				data:SetHeader(GetString("SI_EQUIPSLOTVISUALCATEGORY", visualCategory))

				headersUsed[visualCategory] = true
			--No Header Needed
			else
				self.categoryList:AddEntry("ZO_GamepadItemEntryTemplate", data)
			end
		end
	end

	self.categoryList:Commit()
end

SecurePostHook(GAMEPAD_INVENTORY, "OnDeferredInitialize", function(self)
    --Match the functionality to the target data
    local function OnTargetCategoryChanged(list, targetData, oldTargetData)
        if targetData then
            self.selectedEquipSlot = targetData.equipSlot
            self:SetSelectedItemUniqueId(self:GenerateItemSlotData(targetData))
			
			local filterType = targetData.filterType
			self.selectedItemFilterType = isQuickSlotFiltersType[filterType] and ITEMFILTERTYPE_QUICKSLOT or filterType
			currentCategoryFilter = targetData.filterType
			
        else
			currentCategoryFilter = ITEMFILTERTYPE_ALL
            self:SetSelectedItemUniqueId(nil)
        end
		self:ResetFilters()
        self.currentlySelectedData = targetData
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.categoryListKeybindStripDescriptor)
    end
	
	self.categoryList:SetOnTargetDataChangedCallback(OnTargetCategoryChanged)
	
	self.filterCategories = {}
	self:InitializeFiltersDialog()
	
	function GAMEPAD_INVENTORY:GetCurrentSortParams()
		return INVENTORY_SORT_PRIMARY_KEY[GAMEPAD_INVENTORY.currentSortType], SORT_OPTIONS, GAMEPAD_INVENTORY.currentSortOrder
	end
	
	function ZO_GamepadInventory_DefaultItemSortComparator(left, right)
		return ZO_TableOrderingFunction(left, right, GAMEPAD_INVENTORY:GetCurrentSortParams())
	end
	
	SecurePostHook(GAMEPAD_INVENTORY, 'RefreshCraftBagList', function(self)
		INVENTORY_SEARCH_FILTERS = {}
		for k,v in pairs(self.craftBagList.list.dataList) do
			insertFilter(v)
		end
	end)
end)

---------------------------------------------------------------------------------------------------------------
-- Sort Functions For Merch/Bank
---------------------------------------------------------------------------------------------------------------
local DEFAULT_SORT_KEYS ={
	bestGamepadItemCategoryName = { tiebreaker = "name" },
	name = { tiebreaker = "requiredLevel" },
	requiredLevel = { tiebreaker = "requiredChampionPoints", isNumeric = true },
	requiredChampionPoints = { tiebreaker = "iconFile", isNumeric = true },
	iconFile = { tiebreaker = "uniqueId" },
	uniqueId = { isId64 = true },
	customSortOrder = { tiebreaker = "bestGamepadItemCategoryName", isNumeric = true },
	isJunk = { tiebreaker = "bestGamepadItemCategoryName" },
	equipType = { tiebreaker = "bestGamepadItemCategoryName" , isNumeric = true },
	specializedItemType = { tiebreaker = "bestGamepadItemCategoryName" },
	
--	setId = { tiebreaker = "armorType" },
--	weaponType = { tiebreaker = "armorType" },
--	armorType = { tiebreaker = "name" },
}

local function sortJunkToTOP(data1, data2)
	if data1.isJunk or data2.isJunk then
		return ZO_TableOrderingFunction(data1, data2, "isJunk", DEFAULT_SORT_KEYS, ZO_SORT_ORDER_DOWN)
	end
	return ZO_TableOrderingFunction(data1, data2, "bestGamepadItemCategoryName", DEFAULT_SORT_KEYS, ZO_SORT_ORDER_UP)
end
local function sortJunkToBottom(data1, data2)
	if data1.isJunk or data2.isJunk then
		return ZO_TableOrderingFunction(data1, data2, "isJunk", DEFAULT_SORT_KEYS, savedVars.deposit)
	end
	return ZO_TableOrderingFunction(data1, data2, "bestGamepadItemCategoryName", DEFAULT_SORT_KEYS, ZO_SORT_ORDER_UP)
end

local SELL_SORT_KEYS ={
	bestGamepadItemCategoryName = { tiebreaker = "name" },
	name = { tiebreaker = "requiredLevel" },
	requiredLevel = { tiebreaker = "requiredChampionPoints", isNumeric = true },
	requiredChampionPoints = { tiebreaker = "iconFile", isNumeric = true },
	iconFile = { tiebreaker = "uniqueId" },
	uniqueId = { isId64 = true },
	customSortOrder = { tiebreaker = "bestGamepadItemCategoryName", isNumeric = true },
	isJunk = { tiebreaker = "customSortOrder", tieBreakerSortOrder = ZO_SORT_ORDER_UP },
	
--	setId = { tiebreaker = "armorType" },
--	weaponType = { tiebreaker = "armorType" },
--	armorType = { tiebreaker = "name" },
}
local function SellSortFunc(data1, data2)
	if data1.isJunk or data2.isJunk then
		return ZO_TableOrderingFunction(data1, data2, "isJunk", SELL_SORT_KEYS, ZO_SORT_ORDER_DOWN)
	end
	return ZO_TableOrderingFunction(data1, data2, "customSortOrder", SELL_SORT_KEYS, ZO_SORT_ORDER_UP)
end

---------------------------------------------------------------------------------------------------------------
-- Sort Functions For Merch/Bank
---------------------------------------------------------------------------------------------------------------
function IJA_GPInventory:InitJunkSort()
	savedVars = self.savedVars
	-------------------------------------
	-- Gamepad Merchant Inventory List
	-------------------------------------
	local gamePadSellModeList = STORE_WINDOW_GAMEPAD.components[ZO_MODE_STORE_SELL].list
	ZO_PostHook(gamePadSellModeList, "UpdateList", function(self)
		self:Clear()
		local items = self.updateFunc(self.searchContext)
		table.sort(items, SellSortFunc)
		self:AddItems(items)
	end)

	-------------------------------------
	-- Initialize Gamepad Guild Bank Deposit Sort
	-------------------------------------
	local guildBankSCene = SCENE_MANAGER:GetScene("gamepad_guild_bank")
	guildBankSCene:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWING then
			guildBankSCene:UnregisterCallback("StateChange")
			GAMEPAD_GUILD_BANK.depositList:SetSortFunction(sortJunkToBottom)
		elseif newState == SCENE_SHOWN then
		end
	end)
	
	-------------------------------------
	-- Initialize Gamepad Bank Inventory Sort
	-------------------------------------
	local ENTRY_ORDER_CURRENCY = 1
	local ENTRY_ORDER_OTHER = 2
	local gamepadBankSCene = SCENE_MANAGER:GetScene("gamepad_banking")
	
	local function stateChange(oldState, newState)
		if newState == SCENE_SHOWING then
			gamepadBankSCene:UnregisterCallback("StateChange", stateChange)
				
			GAMEPAD_BANKING.withdrawList:SetSortFunction(function(left, right)
				local leftOrder = ENTRY_ORDER_OTHER
				if left.isCurrenciesMenuEntry or left.currencyType then
					leftOrder = ENTRY_ORDER_CURRENCY
				end
				
				local rightOrder = ENTRY_ORDER_OTHER
				if right.isCurrenciesMenuEntry or right.currencyType then
					rightOrder = ENTRY_ORDER_CURRENCY
				end
				
				if leftOrder < rightOrder then
					return true
				elseif leftOrder > rightOrder then
					return false
				elseif leftOrder == ENTRY_ORDER_OTHER then

					if left.isJunk or right.isJunk then
						return ZO_TableOrderingFunction(left, right, "isJunk", DEFAULT_SORT_KEYS, savedVars.withdraw)
					end
					return ZO_TableOrderingFunction(left, right, GAMEPAD_BANKING:GetCurrentSortParams())
				else
					return false
				end
			end)
			GAMEPAD_BANKING.depositList:SetSortFunction(sortJunkToBottom)
		end
	end
	gamepadBankSCene:RegisterCallback("StateChange", stateChange)
end

---------------------------------------------------------------------------------------------------------------
-- Add Mark/Unmark as Junk to Inventory Item Action list
---------------------------------------------------------------------------------------------------------------
function IJA_GPInventory:AddInventoryActions()
	local menu = LibCustomMenu

	local SUPPORTED_STORE_MODES = {
		["ZO_MODE_STORE_SELL_STOLEN"] = true,
		["ZO_MODE_STORE_LAUNDER"] = true,
		["ZO_MODE_STORE_SELL"] = true,
	 }

	local SUPPORTED_SCENES = {
        ["gamepad_inventory_root"] = true,
        ["gamepad_banking"] = true,
	}
	
	local function canSceneHandleJunk()
		local currentSceneName = SCENE_MANAGER:GetCurrentSceneName()
		return SUPPORTED_SCENES[currentSceneName] or SCENE_MANAGER:IsSceneOnStack("gamepad_inventory_root")
	end

	local function markAsJunkHelper(bagId, slotIndex, markJunk)
		local isLastItem = false
		
		if SCENE_MANAGER:IsShowing("gamepad_inventory_root") or SCENE_MANAGER:IsSceneOnStack("gamepad_inventory_root")then
			local currentList = GAMEPAD_INVENTORY and GAMEPAD_INVENTORY:GetCurrentList()
			isLastItem = currentList and (currentList:GetNumEntries() == 1) or false
		end
		
		SetItemIsJunk(bagId, slotIndex, markJunk)
		PlaySound(markJunk and SOUNDS.INVENTORY_ITEM_JUNKED or SOUNDS.INVENTORY_ITEM_UNJUNKED)
		
		if isLastItem then
			GAMEPAD_INVENTORY:SwitchActiveList(INVENTORY_CATEGORY_LIST)
		end

		CALLBACK_MANAGER:FireCallbacks("InventorySlotUpdate", {bagId, slotIndex})
	end

	local function addItem(inventorySlot, slotActions)
		local valid = ZO_Inventory_GetBagAndIndex(inventorySlot)
		if not valid or inventorySlot.stolen then return end
		
		if canSceneHandleJunk() then
			local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)
			
			if CanItemBeMarkedAsJunk(bag, index) and not QUICKSLOT_WINDOW:AreQuickSlotsShowing() and IsInGamepadPreferredMode() then
				local isJunk = IsItemJunk(bag, index)
				local enableSlotAction = isJunk or (not IsItemPlayerLocked(bag, index))
				
				if enableSlotAction then
					local slotActionString = isJunk and SI_ITEM_ACTION_UNMARK_AS_JUNK or SI_ITEM_ACTION_MARK_AS_JUNK
					slotActions:AddCustomSlotAction(slotActionString, function() markAsJunkHelper(bag, index, not isJunk) end, "")
				end
			end
		end
	end
	menu:RegisterKeyStripEnter(addItem, menu.CATEGORY_PRIMARY)
	
	menu:RegisterKeyStripEnter(function(inventorySlot, slotActions)
		if GAMEPAD_INVENTORY.currentListType ~= INVENTORY_CATEGORY_LIST then
			slotActions:AddCustomSlotAction(SI_GAMEPAD_GUILD_BROWSER_FILTERS_DIALOG_HEADER, function() zo_callLater(function() ZO_Dialogs_ShowGamepadDialog("GAMEPAD_INVENTORY_SEARCH_FILTERS", { inventory = GAMEPAD_INVENTORY }) end, 400) end, "")
		end
	end, menu.CATEGORY_LATE)
end

---------------------------------------------------------------------------------------------------------------
-- Settings menu
---------------------------------------------------------------------------------------------------------------
local function delayedInventoryRefresh()
    EVENT_MANAGER:UnregisterForUpdate("IJA_GPInventory")
	local function OnUpdateHandler(...)
		-- update list when returned to hud
		if SCENE_MANAGER:GetCurrentSceneName() ~= 'gameMenuInGame' then
			EVENT_MANAGER:UnregisterForUpdate("IJA_GPInventory")
			
			SHARED_INVENTORY.refresh:RefreshAll("inventory")
		end
	end
	
	EVENT_MANAGER:RegisterForUpdate("IJA_GPInventory", 100, OnUpdateHandler)
end

function IJA_GPInventory:SetupSettings()
	local LAM2 = LibAddonMenu2
	if not LAM2 then
		return
	end

	local panelData = {
		type = "panel",
		name = self.displayName,
		displayName = self.displayName,
		author = "IsJustaGhost",
		version = self.version,
		registerForRefresh = true,
		registerForDefaults = true
	}
	LAM2:RegisterAddonPanel(self.name, panelData)

	if not self.savedVars.enabledCategories then self.savedVars.enabledCategories = {} end
	if not self.savedVars.filteredCategories then self.savedVars.filteredCategories = {} end
	
	local controlList = {}
	for filterType,v in pairs(isCutomCategory) do
		local control = {
			type = "checkbox",
			name = '   ' .. GetString("SI_IJA_GPINVENTORY_CATEGORY", filterType),
			tooltip = GetString("SI_IJA_GPINVENTORY_CATEGORY_TOOLTIP", filterType),
			getFunc = function() return self.savedVars.enabledCategories[filterType] end,
			setFunc = function(value) 
				self.savedVars.enabledCategories[filterType] = value
				delayedInventoryRefresh()
			end,
			width = "full"
		}
		controlList[#controlList + 1] = control
	end
	
	local optionsTable = {
		{
            type = "header",
            name = GetString(SI_IJA_GPINVENTORY_BANK_OPTIONS),
            width = "full",
        },
		{
			type = "checkbox",
			name = GetString(SI_IJA_GPINVENTORY_SORTBANK_WITHDRAW),
			tooltip = GetString(SI_IJA_GPINVENTORY_SORTBANK_WITHDRAW_TOOLTIP),
			getFunc = function() return self.savedVars.withdraw end,
			setFunc = function(value) self.savedVars.withdraw = value end,
            width = "half"
		},
		{
			type = "checkbox",
			name = GetString(SI_IJA_GPINVENTORY_SORTBANK_DEPOSIT),
			tooltip = GetString(SI_IJA_GPINVENTORY_SORTBANK_DEPOSIT_TOOLTIP),
			getFunc = function() return self.savedVars.deposit end,
			setFunc = function(value) self.savedVars.deposit = value end,
            width = "half",
		},
		{
			type = "submenu",
			name = GetString(SI_IJA_GPINVENTORY_CATEGORIE_OPTIONS),
			reference = "CustomCategories",
			controls = controlList,
		}
	}
	LAM2:RegisterOptionControls(self.name, optionsTable)
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
function IJA_GPInventory_Initialize( ... )
    IJA_GPINVENTORY = IJA_GPInventory:New( ... )
end
