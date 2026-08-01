--[[ NO FILTERING
○ 
○ 
○ 

	filters are now applied based on priority
	

	
- - - 2.8
○ reformatted the language files
○ fixed stolen icon showing on categories other than stolen when stolen category is active.

- - - 2.7.2
○ fixed error "IsJustaGamepadInventory.lua:282: unexpected symbol near 'char(27)'"

- - - 2.7.1
○ updated for API 101038.
○ removed the need for VAR_CURRENT_CATEGORY_FILTER
○ improved ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription based on current inventory category
○ changed ITEMFILTERTYPE_MAPS category icon

- - - 2.7
○ stolen icon will now be applied to categories with stolen items
○ stolen items can now be un/marked as junk
-- changed how custom filters are handled
○ removed SPECIALIZED_ITEMTYPE_TROPHY_TOY from Treasures category. Makes slot-able items un-assignabl
-- example: the jester "toys"

- - - 2.6.3
○ added Tel Var containers to Containers category
○ attempt to fix lag caused by store sell.
○ removed SPECIALIZED_ITEMTYPE_SIEGE_BATTLE_STANDARD since zos removed it

- - - 2.6.1
○ fixed error "IsJustaGamepadInventory.lua:146: function expected instead of nil"

- - - 2.6
○ added "destroy all junk" keybind to junk category
○ added custom category for recipe, rune box, upgrade, and collectible fragments.
○ fixed typo of table name.
○ fixed supply items not being listed in supplies after being unmarked as junk.
○ fixed error "IsJustaGamepadInventory.lua:1325: attempt to index a nil value"

- - - 2.5.2
○ compatibility update.
	removed requirement for the experimental library

- - -2.5.1
○ compatibility update.

- - -2.5
○ updated for API 101034.
○ implemented support for LibHaF

-- 2.4.8
○ update to API
○ fixed refresh of inventory on filter removed. 

-- 2.4.7
○ fixed custom category sorting 

-- 2.4.6
○ fixed malformed number error

-- 2.4.5
○ added French translation courtesy of fzr6n7


see what i can do about sorting
]]
if not jo_callLaterOnNextScene then
	jo_callLaterOnNextScene = function(id, func, ...)
		local params = {...}
		local sceneName = SCENE_MANAGER:GetCurrentSceneName()
		local updateName = "JO_CallLaterOnNextScene_" .. id
		EVENT_MANAGER:UnregisterForUpdate(updateName)
		
		local function OnUpdateHandler()
			if SCENE_MANAGER:GetCurrentSceneName() ~= sceneName then
				EVENT_MANAGER:UnregisterForUpdate(updateName)
				func(unpack(params))
			end
		end
		
		EVENT_MANAGER:RegisterForUpdate(updateName, 100, OnUpdateHandler)
	end
end

local addonData = {
	displayName = "|cFF00FFIsJusta|r |cffffffGamepad Inventory Update|r",
	name = "IsJustaGamepadInventory",
	prefix = "IJA_GPInventory",
	version = "2.8",
}
local defaults = {
}

local savedVarsVersion = 2.4
local ADDON_SHORT_NAME = addonData.prefix
local SI_IJA_GPINVENTORY_CATEGORY = 'SI_' .. ADDON_SHORT_NAME:upper() .. '_CATEGORY'

local INVENTORY_ITEM_LIST = "itemList"
local INVENTORY_CRAFT_BAG_LIST = "craftBagList"
local INVENTORY_CATEGORY_LIST = "categoryList"

local NUM_JUNK_ITEMS = 0
local VAR_CURRENT_CATEGORY_FILTER = ITEMFILTERTYPE_ALL
local CONFIRM_DELETE_ALL_DIALOGUE = ADDON_SHORT_NAME .. "_Confirm_Delete_All_Dialogue"
local JUNK_ITEMS_STACKS = {}

local STOLEN_ICON_TEXTURE = "EsoUI/Art/Inventory/inventory_stolenItem_icon.dds"

local function initStrings()
	-- Initialize dynamic localized strings. Doing this here allows for having to only do it once.
	local useCategory = IJA_GPINVENTORY_LOCALIZEDSTRINGS.useCategory
	IJA_GPINVENTORY_LOCALIZEDSTRINGS.useCategory = nil
	local useCategoryTooltip = IJA_GPINVENTORY_LOCALIZEDSTRINGS.useCategoryTooltip
	IJA_GPINVENTORY_LOCALIZEDSTRINGS.useCategoryTooltip = nil
	local localizedStrings = IJA_GPINVENTORY_LOCALIZEDSTRINGS
	local strings = {}

	for itemFilterType, info in pairs(localizedStrings) do
		strings['SI_IJA_GPINVENTORY_CATEGORY' .. itemFilterType]				= zo_strformat(useCategory, info.category)
		strings['SI_IJA_GPINVENTORY_CATEGORY' .. '_TOOLTIP' .. itemFilterType]	= zo_strformat(useCategoryTooltip, info.tooltip)
		-- used for categoryList item
		strings["SI_ITEMFILTERTYPE" .. itemFilterType] = info.category
	end

	for stringId, stringValue in pairs(strings) do
		ZO_CreateStringId(stringId, stringValue)
		SafeAddVersion(stringId, 1)
	end

	strings = nil
	localizedStrings = nil
	IJA_GPINVENTORY_LOCALIZEDSTRINGS = nil
end

--------------------------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------------------------
local IJA_GPInventory = ZO_InitializingCallbackObject:Subclass()

function IJA_GPInventory:Initialize(control)
	self.control = control
	zo_mixin(self, addonData)
	initStrings()
	
	local function OnLoaded(_, name)
		if name ~= self.name then return end
		self.control:UnregisterForEvent(EVENT_ADD_ON_LOADED)
		
		local AccountWideSavedVars = ZO_SavedVars:NewAccountWide(self.prefix .. "_SavedVars",savedVarsVersion, nil, defaults, GetWorldName())
		self.savedVars = AccountWideSavedVars
		
		self:PerformDeferredInitialize()
		self:SetupSettings()
		self:InitJunkSort()
		
		self:InitializeDialogue()
		self:InitializeKeybinds()
	end
	control:RegisterForEvent( EVENT_ADD_ON_LOADED, OnLoaded)
	
	local function onPlayerActivated()
		control:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)

		self:AddInventoryActions()
		self:InitializeInventoryFilters()
		--	d( self.displayName .. " version: " .. self.version)
	end
	control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, onPlayerActivated)
	
	if LibFilters3 then
		LibFilters3:InitializeLibFilters()
	end
end

--------------------------------------------------------------------------------------------------
-- Custom Categories
--------------------------------------------------------------------------------------------------
local customCategories = {
	ITEMFILTERTYPE_POTION,
	ITEMFILTERTYPE_FOOD_DRINK,
	ITEMFILTERTYPE_MAPS,
	ITEMFILTERTYPE_CONTAINER,
	ITEMFILTERTYPE_REPAIR,
	ITEMFILTERTYPE_RECIPE_STYLE_PAGE,
	ITEMFILTERTYPE_TREASURE,
	ITEMFILTERTYPE_FRAGMENT,
	ITEMFILTERTYPE_WRIT,
	ITEMFILTERTYPE_SIEGE,
--	ITEMFILTERTYPE_DAMAGED,
	ITEMFILTERTYPE_JUNK,
	ITEMFILTERTYPE_STOLEN,
--	ITEMFILTERTYPE_TRASH,
}

local isCustomCategory = {}
for k, filterType in ipairs(customCategories) do
	isCustomCategory[filterType] = true
end

local customCategoryIcons = {
	[ITEMFILTERTYPE_POTION]		= "/esoui/art/tradinghouse/gamepad/gp_tradinghouse_materials_potions_potionsolvent.dds",
	[ITEMFILTERTYPE_FOOD_DRINK] = "/esoui/art/tradinghouse/gamepad/gp_tradinghouse_materials_provisioning_food.dds",
--	[ITEMFILTERTYPE_MAPS]		= "EsoUI/Art/crafting/Gamepad/gp_crafting_menuicon_designs.dds",
--	[ITEMFILTERTYPE_MAPS]		= "/esoui/art/tradinghouse/gamepad/gp_tradinghouse_trophy_treasure_map.dds",
	[ITEMFILTERTYPE_MAPS]		= "/esoui/art/guildfinder/gamepad/gp_guildrecruitment_menuicon_response_message.dds",
	[ITEMFILTERTYPE_CONTAINER]	= "/esoui/art/icons/servicemappins/servicepin_bank.dds",
	[ITEMFILTERTYPE_REPAIR]		= "/esoui/art/treeicons/gamepad/gp_tools.dds",
	[ITEMFILTERTYPE_RECIPE_STYLE_PAGE] = "/esoui/art/crafting/gamepad/gp_crafting_menuicon_schematics.dds",
	[ITEMFILTERTYPE_TREASURE]	= "/esoui/art/tradinghouse/gamepad/gp_tradinghouse_other_trophy_types.dds",
	[ITEMFILTERTYPE_FRAGMENT]	= "/esoui/art/tradinghouse/gamepad/gp_tradinghouse_trophy_recipe_fragment.dds",
	[ITEMFILTERTYPE_WRIT]		= "/esoui/art/tradinghouse/gamepad/gp_tradinghouse_master_writ.dds",
	[ITEMFILTERTYPE_SIEGE]		= "/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_ava.dds",
	[ITEMFILTERTYPE_JUNK]		= "esoui/art/inventory/inventory_tabicon_junk_up.dds",
	[ITEMFILTERTYPE_STOLEN]		= "esoui/art/inventory/gamepad/gp_inventory_icon_stolenitem.dds",
--	[ITEMFILTERTYPE_TRASH]		= "esoui/art/inventory/gamepad/gp_inventory_icon_stolenitem.dds",
}

local Tel_Var_Containers = {
	[69415] = true,
	[69413] = true,
	[69414] = true,
	[69433] = true,
	[81993] = true,
}

--------------------------------------------------------------------------------------------------
-- Comparetors
--------------------------------------------------------------------------------------------------

local function isItemLinkCrownItem(itemLink)
	return IsItemLinkFromCrownCrate(itemLink) or IsItemLinkFromCrownStore(itemLink)
end


local isQuickSlotFiltersType = {
	[ITEMFILTERTYPE_MAPS]		= true,
	[ITEMFILTERTYPE_QUEST]		= true,
	[ITEMFILTERTYPE_SIEGE]		= true,
	[ITEMFILTERTYPE_REPAIR]		= true,
	[ITEMFILTERTYPE_POTION]		= true,
	[ITEMFILTERTYPE_CONTAINER]	= true,
	[ITEMFILTERTYPE_FOOD_DRINK] = true,
	[ITEMFILTERTYPE_QUICKSLOT]	= true,
	[ITEMFILTERTYPE_FRAGMENT]	= true,
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
	[SPECIALIZED_ITEMTYPE_AVA_REPAIR] = true,	-- SPECIALIZED_ITEMTYPE_AVA_REPAIR = 2100
	[SPECIALIZED_ITEMTYPE_SIEGE_BALLISTA] = true,	-- SPECIALIZED_ITEMTYPE_SIEGE_BALLISTA = 401
	[SPECIALIZED_ITEMTYPE_SIEGE_CATAPULT] = true,	-- SPECIALIZED_ITEMTYPE_SIEGE_CATAPULT = 404
	[SPECIALIZED_ITEMTYPE_SIEGE_GRAVEYARD] = true,	-- SPECIALIZED_ITEMTYPE_SIEGE_GRAVEYARD = 405
	[SPECIALIZED_ITEMTYPE_SIEGE_LANCER] = true,	-- SPECIALIZED_ITEMTYPE_SIEGE_LANCER = 409
	[SPECIALIZED_ITEMTYPE_SIEGE_MONSTER] = true,	-- SPECIALIZED_ITEMTYPE_SIEGE_MONSTER = 406
	[SPECIALIZED_ITEMTYPE_SIEGE_OIL] = true,	-- SPECIALIZED_ITEMTYPE_SIEGE_OIL = 407
	[SPECIALIZED_ITEMTYPE_SIEGE_RAM] = true,	-- SPECIALIZED_ITEMTYPE_SIEGE_RAM = 402
	[SPECIALIZED_ITEMTYPE_SIEGE_TREBUCHET] = true,	-- SPECIALIZED_ITEMTYPE_SIEGE_TREBUCHET = 400
	[SPECIALIZED_ITEMTYPE_SIEGE_UNIVERSAL] = true,	-- SPECIALIZED_ITEMTYPE_SIEGE_UNIVERSAL = 403
	[SPECIALIZED_ITEMTYPE_RECALL_STONE_KEEP] = true	-- SPECIALIZED_ITEMTYPE_RECALL_STONE_KEEP = 3100
}
local SPECIALIZED_ITEMTYPE_FOR_TREASURE = {
	[SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH] = true,	-- SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH = 80
	[SPECIALIZED_ITEMTYPE_COLLECTIBLE_MONSTER_TROPHY] = true,	-- SPECIALIZED_ITEMTYPE_COLLECTIBLE_MONSTER_TROPHY = 81
--	[SPECIALIZED_ITEMTYPE_TROPHY_TOY] = true,	-- SPECIALIZED_ITEMTYPE_TROPHY_TOY = 111
	[SPECIALIZED_ITEMTYPE_TREASURE] = true,	-- SPECIALIZED_ITEMTYPE_TREASURE = 2550
}
local SPECIALIZED_ITEMTYPE_FOR_WRIT = {
	[SPECIALIZED_ITEMTYPE_HOLIDAY_WRIT] = true,	-- SPECIALIZED_ITEMTYPE_HOLIDAY_WRIT = 2760
	[SPECIALIZED_ITEMTYPE_MASTER_WRIT] = true,	-- SPECIALIZED_ITEMTYPE_MASTER_WRIT = 2750
}
local SPECIALIZED_ITEMTYPE_FOR_FRAGEMTS = {
--	[SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT] = true,	-- SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT = 102
	[SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT] = true,	-- SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT = 104
	[SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT] = true,	-- SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT = 108
	[SPECIALIZED_ITEMTYPE_TROPHY_UPGRADE_FRAGMENT] = true,	-- SPECIALIZED_ITEMTYPE_TROPHY_UPGRADE_FRAGMENT = 110
	[SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT] = true,	-- SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT = 109
}

local function isFragmentItem(itemData)
	return SPECIALIZED_ITEMTYPE_FOR_FRAGEMTS[itemData.specializedItemType] or false
end
local function isContainerItem(itemData)
	local itemId = GetItemId(itemData.bagId, itemData.slotIndex)
	return SPECIALIZED_ITEMTYPE_FOR_CONTAINER[itemData.specializedItemType] or Tel_Var_Containers[itemId] or false
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
local function isItemJunk(itemData)
	return itemData.isJunk and IJA_GPINVENTORY.savedVars.enabledCategories[ITEMFILTERTYPE_JUNK] or false
end
local function isItemStolen(itemData)
	return itemData.stolen and IJA_GPINVENTORY.savedVars.enabledCategories[ITEMFILTERTYPE_STOLEN] or false
end

local function isItemJunkOrStolen(itemData)
	return isItemJunk(itemData) or isItemStolen(itemData)
end

local filterTypeComparators = {
	[ITEMFILTERTYPE_JUNK]				= function(itemData) return isItemJunk(itemData) end,
	[ITEMFILTERTYPE_STOLEN]				= function(itemData) return isItemStolen(itemData) end,
	
	[ITEMFILTERTYPE_CONTAINER]			= function(itemData) return isContainerItem(itemData) end,
	[ITEMFILTERTYPE_FOOD_DRINK]			= function(itemData) return isFoodItem(itemData) end,
	[ITEMFILTERTYPE_MAPS]				= function(itemData) return isMapItem(itemData) end,
	[ITEMFILTERTYPE_POTION]				= function(itemData) return isPotionItem(itemData) end,
	[ITEMFILTERTYPE_RECIPE_STYLE_PAGE]	= function(itemData) return isRecipeItem(itemData) end,
	[ITEMFILTERTYPE_REPAIR]				= function(itemData) return isRepairItem(itemData) end,
	[ITEMFILTERTYPE_SIEGE]				= function(itemData) return isSiegeItem(itemData) end,
	[ITEMFILTERTYPE_TREASURE]			= function(itemData) return isTreasureItem(itemData) end,
	[ITEMFILTERTYPE_WRIT]				= function(itemData) return isWritItem(itemData) end,
	[ITEMFILTERTYPE_FRAGMENT]			= function(itemData) return isFragmentItem(itemData) end,
}

local function comparatorDoFiltersMatch(filter, filterType)
	return filter == filterType
end

--[[
local function itemCannotBeSold(itemData) ---------------
	return itemData.sellInformation == ITEM_SELL_INFORMATION_CANNOT_SELL
end

local function isCrownItem(itemData) ---------------
	return itemData.isCrownItem
end

local function isTelVarContainer(itemData) ---------------
	return Tel_Var_Containers[itemData.itemId]
end
]]

--------------------------------------------------------------------------------------------------
-- Helper functions
--------------------------------------------------------------------------------------------------

local function getFilteredItemListData(comparator)
	local list = {}
	
	for k, slotData in pairs(GAMEPAD_INVENTORY.itemList.dataList) do
		if comparator(slotData) then
			table.insert(list, slotData)
		end
	end
	return list
end

local function refreshInventory()
	NUM_JUNK_ITEMS = 0
	JUNK_ITEMS_STACKS = {}
	GAMEPAD_INVENTORY:MarkDirty()
	SHARED_INVENTORY.refresh:RefreshAll("inventory")
	SHARED_INVENTORY.refresh:UpdateRefreshGroups()
--	/script GAMEPAD_INVENTORY:MarkDirty(); SHARED_INVENTORY.refresh:RefreshAll("inventory")
end

local function updateJunkCount(bagId, slotIndex, stackCount)
	local bagItems = JUNK_ITEMS_STACKS[bagId] or {}
	
	if slotIndex then
		bagItems[slotIndex] = stackCount
	else
		bagItems = nil
	end
	
	JUNK_ITEMS_STACKS[bagId] = bagItems
end

local function getNumJunkItems()
	local numItems = 0
	
	for bagId, bagItems in pairs(JUNK_ITEMS_STACKS) do
		for slotIndex, stackCount in pairs(bagItems) do
			numItems = numItems + stackCount
		end
	end
	
	return numItems
end

local function areAnyItemsStolen(optFilterFunction, currentFilter, ...)
	if currentFilter == ITEMFILTERTYPE_STOLEN or not IJA_GPINVENTORY.savedVars.enabledCategories[ITEMFILTERTYPE_STOLEN] then
		for i = 1, select("#", ...) do
			local bagId = select(i, ...)
			local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(bagId)

			for _, itemData in pairs(bagCache) do
				if itemData.stolen and (not optFilterFunction or optFilterFunction(itemData, currentFilter)) then
					return true
				end
			end
		end
	end

	return false
end

--------------------------------------------------------------------------------------------------
-- Category Description functions
--------------------------------------------------------------------------------------------------

local function getCategoryTypeFromWeaponType(bagId, slotIndex)
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

local function isTwoHandedWeaponCategory(categoryType)
	return categoryType == GAMEPAD_WEAPON_CATEGORY_TWO_HANDED_MELEE or
		categoryType == GAMEPAD_WEAPON_CATEGORY_DESTRUCTION_STAFF or
		categoryType == GAMEPAD_WEAPON_CATEGORY_RESTORATION_STAFF or
		categoryType == GAMEPAD_WEAPON_CATEGORY_TWO_HANDED_BOW
end

--[[
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
local function GetCategoryFromItemType(itemType) ----------------
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
local function GetCategoryFromWeapon(itemData) ------------
	local weaponType
	if itemData.bagId and itemData.slotIndex then
		weaponType = GetItemWeaponType(itemData.bagId, itemData.slotIndex)
	else
		weaponType = GetItemLinkWeaponType(itemData.itemLink)
	end

	return WEAPON_TYPE_TO_CATEGORY_MAP[weaponType]
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
local function GetCategoryFromArmor(itemData) -------------
	return ARMOR_EQUIP_TYPE_TO_CATEGORY_MAP[itemData.equipType]
end
]]

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

local function getCategoryForCustomFilterTypes(specializedItemType)
	return SPECIALIZED_ITEMTYPE_TO_CATEGORY_MAP[specializedItemType] or ITEM_TYPE_DISPLAY_CATEGORY_ALL
end

local function getBestItemCategory(itemData)
	if GAMEPAD_INVENTORY.scene:IsShowing() then
		local specializedItemType = itemData.specializedItemType
		local category = ITEM_TYPE_DISPLAY_CATEGORY_ALL

		local targetCategoryData = GAMEPAD_INVENTORY.categoryList:GetTargetData()
		local filterType = targetCategoryData.filterType or ITEMFILTERTYPE_ALL
		
		if isCustomCategory[filterType] then
			category = getCategoryForCustomFilterTypes(specializedItemType)
			
			if filterType == ITEMFILTERTYPE_POTION then
				if isItemLinkCrownItem(itemData.itemLink) then
					category = ITEM_TYPE_DISPLAY_CATEGORY_CROWN_ITEM -- 28
				elseif GetItemCreatorName(itemData.bagId, itemData.slotIndex) ~= '' then	-- crafted
					category = ITEM_TYPE_DISPLAY_CATEGORY_CRAFTED
				else
			--		category = ITEM_TYPE_DISPLAY_CATEGORY_POTION
				end
			end
			
			if filterType == ITEMFILTERTYPE_FOOD_DRINK then
				if isItemLinkCrownItem(itemData.itemLink) then
					category = ITEM_TYPE_DISPLAY_CATEGORY_CROWN_ITEM -- 28
				elseif GetItemCreatorName(itemData.bagId, itemData.slotIndex) ~= '' then	-- crafted
					category = ITEM_TYPE_DISPLAY_CATEGORY_CRAFTED
				end
				
				--ITEM_TYPE_DISPLAY_CATEGORY_FOOD ITEM_TYPE_DISPLAY_CATEGORY_DRINK
			end
			
			if filterType == ITEMFILTERTYPE_DAMAGED then
		--		category = ITEM_TYPE_DISPLAY_CATEGORY_CROWN_ITEM -- 28
			end
			
			if filterType == ITEMFILTERTYPE_DAMAGED then
		--		category = ITEM_TYPE_DISPLAY_CATEGORY_CROWN_ITEM -- 28
			end
		--[[
			if filterType == ITEMFILTERTYPE_TRASH then
				category = ITEM_TYPE_DISPLAY_CATEGORY_TRASH -- 36
			end
		]]
			
			if itemData.isJunk and filterType ~= ITEMFILTERTYPE_JUNK then
				category = ITEM_TYPE_DISPLAY_CATEGORY_JUNK
			end
			return category, specializedItemType
		end
	end
end

local orig_Gamepad_GetBestItemCategoryDescription = ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription
function ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription(itemData)
	local category, specializedItemType = getBestItemCategory(itemData)
	
	if specializedItemType then
		if category ~= ITEM_TYPE_DISPLAY_CATEGORY_ALL then
			return GetString("SI_ITEMTYPEDISPLAYCATEGORY", category)
		end
		
		return zo_strformat(SI_INVENTORY_HEADER, GetString("SI_SPECIALIZEDITEMTYPE", specializedItemType))
	end
	
	return orig_Gamepad_GetBestItemCategoryDescription(itemData)
end

--------------------------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------------------------
-- SlotData_Extended is added as a subclass to each inventory item
-- used to add additional data to inventory items to use for filtering.
-- Update_Extended 
-- IJA_CustomFilterFunction
-- IJA_AddFilterToSlotData

IJA_GPInventory_Test = {}

local function parseFilterData(filterData, comparator, filterType)
	comparator = comparator or function(filter, filterType)
		return filter == filterType
	end
		
	for i, filter in ipairs(filterData) do
		if comparator(filter, filterType) then
			return true
		end
	end
	return false
end

-- get filterType based on comparators to be used for filtering
local function slotDataToFilterType(itemData)
	for filter, comparator in pairs(filterTypeComparators) do
		if comparator(itemData) and IJA_GPINVENTORY.savedVars.enabledCategories[filter] then
			return filter
		end
	end
end

local SlotData_Extended = ZO_Object:Subclass()

function SlotData_Extended:GetFilterObject(slotData, bagId, slotIndex)
	local filterObject = setmetatable({}, self)
	filterObject:Update(slotData, bagId, slotIndex)
	return filterObject
end

function SlotData_Extended:Update(slotData, bagId, slotIndex)
	self.filterData = slotData.filterData
	self.itemLink = GetItemLink(bagId, slotIndex)
	
	self.filterType = nil
	slotData.itemLink = GetItemLink(bagId, slotIndex)
	
	self.info = {GetItemInfo(bagId, slotIndex)}
	local filterType = slotDataToFilterType(slotData)
	
	if filterType then
		if isItemJunk(slotData) then
			filterType = ITEMFILTERTYPE_JUNK
		elseif isItemStolen(slotData) then
			filterType = ITEMFILTERTYPE_STOLEN
		end
		
		local stackCount = filterType == ITEMFILTERTYPE_JUNK and slotData.stackCount or nil
		updateJunkCount(bagId, slotIndex, stackCount)
		
		if not parseFilterData(self.filterData, comparatorDoFiltersMatch, filterType) then
			self:AddFilterToSlotData(filterType)
		end
	end
end

function SlotData_Extended:CustomFilterFunction(filteredEquipSlot, nonEquipableFilterType)
	if self.filterType and self.filterType ~= nonEquipableFilterType then return false end
	
	if nonEquipableFilterType then
		-- only non-equipment items are used in custom categories
		if isCustomCategory[nonEquipableFilterType] then
			return parseFilterData(self.filterData, comparatorDoFiltersMatch, nonEquipableFilterType)
		else
			
		end
	end
	
	return true
end

-- add custom filterType to slotData.filterData
function SlotData_Extended:AddFilterToSlotData(filterType)
	table.insert(self.filterData, filterType)
	self.filterType = filterType
end

--------------------------------------------------------------------------------------------------
-- Main Filters
--------------------------------------------------------------------------------------------------
function IJA_GPInventory:InitializeInventoryFilters()
	-- Supplies Category filters
	-- custom category filters are not added to items unless the filter is enabled.
	local function doesNewItemMatchFilterType(itemData)
		for i, filter in ipairs(itemData.filterData) do
			if isCustomCategory[filter] then
				return true
			end
		end
		
		local ignore = isItemJunkOrStolen(itemData)
		return ignore
	end

	local original_DoesNewItemMatchSupplies = ZO_InventoryUtils_DoesNewItemMatchSupplies
	function ZO_InventoryUtils_DoesNewItemMatchSupplies(itemData)
		return original_DoesNewItemMatchSupplies(itemData)
			and not doesNewItemMatchFilterType(itemData)
	end

	--	categoryList and itemList filters
	local original_GetItemDataFilterComparator = GAMEPAD_INVENTORY.GetItemDataFilterComparator
	function GAMEPAD_INVENTORY:GetItemDataFilterComparator(filteredEquipSlot, nonEquipableFilterType)
		return function(itemData)
			-- comparator == ZOS original or libFilters3_v3
			local comparator = original_GetItemDataFilterComparator(GAMEPAD_INVENTORY, filteredEquipSlot, nonEquipableFilterType)
			
			if comparator(itemData) then
				local filterObject = itemData.IJA_GPINVENTORY
				if filteredEquipSlot == nil and filterObject then
					return filterObject:CustomFilterFunction(filteredEquipSlot, nonEquipableFilterType)
				end
				
				return true
			end
			
			return false
		end
	end

	local function updateSlotData(slotData, bagId, slotIndex)
		slotData.IJA_GPINVENTORY = SlotData_Extended:GetFilterObject(slotData, bagId, slotIndex)
	end

	local function onSingleSlotUpdate(bagId, slotIndex, previousSlotData)
		local bagCache = SHARED_INVENTORY:GetBagCache(bagId)
		
		if bagCache then
			if previousSlotData then
				-- need to update junk count if an item's junk status has changed
				updateJunkCount(bagId, previousSlotData.slotIndex)
			end

			local slotData = bagCache[slotIndex]
			if slotData == nil then return end			
			updateSlotData(slotData, bagId, slotIndex)
		end
	end
	
	local function onBagCacheUpdate(bagId)
		local bagCache = SHARED_INVENTORY:GetBagCache(bagId)
	--	IJA_GPInventory_Test = {}
		updateJunkCount(bagId)
		
		if bagCache == nil then return end
		for slotIndex, slotData in pairs(bagCache) do
			updateSlotData(slotData, bagId, slotIndex)
		--	table.insert(IJA_GPInventory_Test, slotData)
		end
	end
	-- this may be done after the list is updated. need to verify
	SHARED_INVENTORY:RegisterCallback("SingleSlotInventoryUpdate", onSingleSlotUpdate)
	SHARED_INVENTORY:RegisterCallback("FullInventoryUpdate", onBagCacheUpdate)
	refreshInventory()
end

--------------------------------------------------------------------------------------------------
-- Category build functions
--------------------------------------------------------------------------------------------------
-- Using custom build functions to allow adding the stolen icon to all categories with a stolen item.
local twoHandIconFile
local headersUsed = {}

local function addCategory(name, iconFile, categoryFilter, equipSlot, filterType, bag, header, offhandTransparency)
	local hasAnyNewItems = SHARED_INVENTORY:AreAnyItemsNew(categoryFilter, filterType, BAG_BACKPACK)
	
	local data = ZO_GamepadEntryData:New(name, iconFile, nil, nil, hasAnyNewItems)
	data.filterType = filterType
	data.equipSlot = equipSlot
	data:SetIconTintOnSelection(true)
	data:SetMaxIconAlpha(offhandTransparency)
	
	if filterType ~= ITEMFILTERTYPE_STOLEN and areAnyItemsStolen(categoryFilter, filterType, BAG_BACKPACK, BAG_WORN) then
		data:AddIcon(STOLEN_ICON_TEXTURE)
	end
	
	if (equipSlot == EQUIP_SLOT_POISON or equipSlot == EQUIP_SLOT_BACKUP_POISON) then
		data.stackCount = select(2, GetItemInfo(BAG_WORN, equipSlot))
	end
	
	if header and headersUsed[header] == nil then
		GAMEPAD_INVENTORY.categoryList:AddEntry("ZO_GamepadItemEntryTemplateWithHeader", data)
		data:SetHeader(header)

		headersUsed[header] = true
	else --No Header Needed
		GAMEPAD_INVENTORY.categoryList:AddEntry("ZO_GamepadItemEntryTemplate", data)
	end
end

local function addSuppliesCategoryIfPopulated(iconFile)
	local isListEmpty = GAMEPAD_INVENTORY:IsItemListEmpty()
	if not isListEmpty then
		local name = GetString(SI_INVENTORY_SUPPLIES)
		addCategory(name, iconFile, ZO_InventoryUtils_DoesNewItemMatchSupplies, nil, nil, BAG_BACKPACK)
	end
end

local function addFilteredBackpackCategoryIfPopulated(filterType, iconFile)
	local isListEmpty = GAMEPAD_INVENTORY:IsItemListEmpty(nil, filterType)
	if not isListEmpty then
		local name = GetString("SI_ITEMFILTERTYPE", filterType)
		addCategory(name, iconFile, ZO_InventoryUtils_DoesNewItemMatchFilterType, nil, filterType, BAG_BACKPACK, header)
	end
end

local function addFilteredEquipCategoryIfPopulated(equipSlot)
	local locked = IsLockedWeaponSlot(equipSlot)
	local isListEmpty = GAMEPAD_INVENTORY:IsItemListEmpty(equipSlot, nil)
	
	if not locked and not isListEmpty then
		local filterType = (GetItemFilterTypeInfo(BAG_WORN, equipSlot)) -- first filter only
	
		local name = zo_strformat(SI_CHARACTER_EQUIP_SLOT_FORMAT, GetString("SI_EQUIPSLOT", equipSlot))
		local iconFile, slotHasItem = GetEquippedItemInfo(equipSlot)
		if not slotHasItem then
			iconFile = nil
		end
		
		--special case where a two handed weapon icon shows up in offhand slot at lower opacity
		local weaponCategoryType = getCategoryTypeFromWeaponType(bag, equipSlot)
		if iconFile
			and (equipSlot == EQUIP_SLOT_MAIN_HAND or equipSlot == EQUIP_SLOT_BACKUP_MAIN)
			and isTwoHandedWeaponCategory(weaponCategoryType) then
			twoHandIconFile = iconFile
		end

		local offhandTransparency
		if twoHandIconFile ~= nil and (equipSlot == EQUIP_SLOT_OFF_HAND or equipSlot == EQUIP_SLOT_BACKUP_OFF) then
			iconFile = twoHandIconFile
			twoHandIconFile = nil
			offhandTransparency = 0.5
		end
		
		local filterType = (GetItemFilterTypeInfo(BAG_WORN, equipSlot)) -- first filter only
		local function doesNewItemMatchEquipSlot(itemData)
			return ZO_Character_DoesEquipSlotUseEquipType(equipSlot, itemData.equipType)
		end
		
		--Headers for Equipment Visual Categories (Weapons, Apparel, Accessories): display header for the first equip slot of a category to be visible 
		local visualCategory = ZO_Character_GetEquipSlotVisualCategory(equipSlot)
		local header = GetString("SI_EQUIPSLOTVISUALCATEGORY", visualCategory)
		addCategory(name, iconFile, doesNewItemMatchEquipSlot, equipSlot, filterType, BAG_WORN, header, offhandTransparency)
	end
end

local function addFilteredBackpackCategoryIfEnabled(equipSlot, filterType, iconFile, header, headersUsed)
	if IJA_GPINVENTORY.savedVars.enabledCategories[filterType] then
		local isListEmpty = GAMEPAD_INVENTORY:IsItemListEmpty(nil, filterType)
		if not isListEmpty then
			local name = GetString("SI_ITEMFILTERTYPE", filterType)
			addCategory(name, iconFile, ZO_InventoryUtils_DoesNewItemMatchFilterType, nil, filterType, BAG_BACKPACK, header)
		end
	end
end

--------------------------------------------------------------------------------------------------
-- Header functions
--------------------------------------------------------------------------------------------------
local hasSellValue = {
	[ITEMFILTERTYPE_JUNK] = true,
	[ITEMFILTERTYPE_STOLEN] = true,
	[ITEMFILTERTYPE_TREASURE] = true,
}

local function updateTitleText()
	local targetCategoryData = GAMEPAD_INVENTORY.categoryList:GetTargetData()
	local filterType = targetCategoryData.filterType
	return GetString("SI_ITEMFILTERTYPE", filterType)
--	return GetString("SI_ITEMFILTERTYPE", VAR_CURRENT_CATEGORY_FILTER)
end

local function updateGold(control)
	ZO_CurrencyControl_SetSimpleCurrency(control, CURT_MONEY, GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER), ZO_GAMEPAD_CURRENCY_OPTIONS_LONG_FORMAT)
	return true
end

local function updateCapacityString()
	return zo_strformat(SI_GAMEPAD_INVENTORY_CAPACITY_FORMAT, GetNumBagUsedSlots(BAG_BACKPACK), GetBagSize(BAG_BACKPACK))
end

local function updateSellValueString(control)
	local targetCategoryData = GAMEPAD_INVENTORY.categoryList:GetTargetData()
	local filterType = targetCategoryData.filterType
	local comparetor = GAMEPAD_INVENTORY:GetItemDataFilterComparator(nil, filterType)
--	local comparetor = GAMEPAD_INVENTORY:GetItemDataFilterComparator(nil, VAR_CURRENT_CATEGORY_FILTER)
	
	local bagCache = SHARED_INVENTORY:GenerateFullSlotData(comparetor, BAG_BACKPACK)
	
	local total = 0
	for slotId, itemData in pairs(bagCache) do
		total = total + itemData.stackSellPrice
	end
	return zo_strformat(SI_TOOLTIP_ITEM_VALUE_FORMAT, total, GetString(SI_GAMEPAD_INVENTORY_AVAILABLE_FUNDS))
end

function IJA_GPInventory:DynamicMapHeaders_SetTextAndCount(index, header, count)
	self.customHeaders.mapsHeaderData['data' .. index .. 'HeaderText'] = zo_strformat(SI_INVENTORY_HEADER, header)
	self.customHeaders.mapsHeaderData['data' .. index .. 'Text'] = zo_strformat(SI_TOOLTIP_ITEM_VALUE_FORMAT, count, "")
end
function IJA_GPInventory:DynamicMapHeaders_Clear()
	self:DynamicMapHeaders_SetTextAndCount(3)
	self:DynamicMapHeaders_SetTextAndCount(4)
end
function IJA_GPInventory:DynamicMapHeaders_Set(surveyCache, mapCache)
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
		self:DynamicMapHeaders_SetTextAndCount(index, surveyString, getSurveyCount(surveyCache))
		index = index + 1
	end
	if #mapCache > 0 then
		local mapString = zo_strformat(SI_IJA_GPINVENTORY_PLURAL, GetString(SI_SPECIALIZEDITEMTYPE100))
		self:DynamicMapHeaders_SetTextAndCount(index, mapString, #mapCache)
	end
end
function IJA_GPInventory:DynamicMapHeaders_Update()
	local getComparator = function(specialized_itemtype)
		return function(itemData)
			if itemData.specializedItemType == specialized_itemtype then
				return not isItemJunk(itemData) and not isItemStolen(itemData)
			end
		end
	end
	
	local isMap			= getComparator(SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP)
	local isSurvey		= getComparator(SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT)

	local mapCache		= getFilteredItemListData(isMap)
	local surveyCache	= getFilteredItemListData(isSurvey)

	self:DynamicMapHeaders_Clear()
	self:DynamicMapHeaders_Set(surveyCache, mapCache)
end
function IJA_GPInventory:InitializeCustomHeaders()
	self.customHeaders = {}
	self.customHeaders.default = {
		titleText = updateTitleText,
		data1HeaderText = GetString(SI_GAMEPAD_INVENTORY_AVAILABLE_FUNDS),
		data1Text = updateGold,

		data2HeaderText = GetString(SI_GAMEPAD_INVENTORY_CAPACITY),
		data2Text = updateCapacityString,
	}
	self.customHeaders.withValueData = {
		titleText = updateTitleText,
		data1HeaderText = GetString(SI_GAMEPAD_INVENTORY_AVAILABLE_FUNDS),
		data1Text = updateGold,

		data2HeaderText = GetString(SI_GAMEPAD_INVENTORY_CAPACITY),
		data2Text = updateCapacityString,
		
		data3HeaderText = GetString(SI_INVENTORY_SORT_TYPE_PRICE),
		data3Text = updateSellValueString,
	}
	self.customHeaders.mapsHeaderData = {
		titleText = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_MAPS),
		data1HeaderText = GetString(SI_GAMEPAD_INVENTORY_AVAILABLE_FUNDS),
		data1Text = updateGold,

		data2HeaderText = GetString(SI_GAMEPAD_INVENTORY_CAPACITY),
		data2Text = updateCapacityString,
	}
	
end

function IJA_GPInventory:PerformDeferredInitialize()
	local addon = self
	self:InitializeCustomHeaders()
	
	ZO_PreHook(GAMEPAD_INVENTORY, "RefreshHeader", function(self, blockCallback)
		if self:GetCurrentList() == self.itemList then
			local targetCategoryData = self.categoryList:GetTargetData()
			local filterType = targetCategoryData.filterType
		--	local filterType = VAR_CURRENT_CATEGORY_FILTER
			
			if isCustomCategory[filterType] and self:GetCurrentList():IsActive() then
				local headerData
				
				if filterType == ITEMFILTERTYPE_MAPS then
					addon:DynamicMapHeaders_Update()
					headerData = addon.customHeaders.mapsHeaderData
					
				elseif hasSellValue[filterType] then
					headerData = addon.customHeaders.withValueData
					
				else
					headerData = addon.customHeaders.default
				end
				
				ZO_GamepadGenericHeader_Refresh(self.header, headerData, blockCallback)
				return true
			end
		end
		
		-- if not custom category then run default RefreshHeader
		return false
	end)

	SecurePostHook(GAMEPAD_INVENTORY, "OnDeferredInitialize", function(self)
		-- this is to set the filterType to the current category. The Main reason this is here is to allow slot-able items
		-- in custom categories to be assignable
		--Match the functionality to the target data
		local function onTargetCategoryChanged(list, targetData, oldTargetData)
			if targetData then
				zo_callLater(function()
					local filterType = targetData.filterType
					self.selectedItemFilterType = isQuickSlotFiltersType[filterType] and ITEMFILTERTYPE_QUICKSLOT or filterType
					VAR_CURRENT_CATEGORY_FILTER = targetData.filterType
				end, 10)
				
			else
				VAR_CURRENT_CATEGORY_FILTER = ITEMFILTERTYPE_ALL
			end
			
			KEYBIND_STRIP:UpdateKeybindButtonGroup(self.categoryListKeybindStripDescriptor)
		end
		self.categoryList:SetOnTargetDataChangedCallback(onTargetCategoryChanged)
		
		table.insert(self.itemFilterKeybindStripDescriptor, addon.destroyAllKeybindButton)
	end)

	--------------------------------------------------------------------------------------------------
	-- Category list
	--------------------------------------------------------------------------------------------------
	
	function GAMEPAD_INVENTORY:RefreshCategoryList(selectDefaultEntry)
		self.categoryList:Clear()
		
		do -- Currencies
			local name = GetString(SI_INVENTORY_CURRENCIES)
			local iconFile = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_currencies.dds"
			local data = ZO_GamepadEntryData:New(name, iconFile, nil, nil, false)
			data.isCurrencyEntry = true
			data:SetIconTintOnSelection(true)
			self.categoryList:AddEntry("ZO_GamepadItemEntryTemplate", data)
		end

		-- Supplies
		addSuppliesCategoryIfPopulated("EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_all.dds")
		-- Materials
		addFilteredBackpackCategoryIfPopulated(ITEMFILTERTYPE_CRAFTING, "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_materials.dds")
		-- Consumables
		addFilteredBackpackCategoryIfPopulated(ITEMFILTERTYPE_QUICKSLOT, "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_quickslot.dds")
		-- Furnishing
		addFilteredBackpackCategoryIfPopulated(ITEMFILTERTYPE_FURNISHING, "EsoUI/Art/Crafting/Gamepad/gp_crafting_menuIcon_furnishings.dds")
		-- Companion Items
		addFilteredBackpackCategoryIfPopulated(ITEMFILTERTYPE_COMPANION, "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_companionItems.dds")
		
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
			local header = GetString(SI_IJA_GPINVENTORY_CATEGORIES_HEADER)
			for k, filterType in ipairs(customCategories) do
				addFilteredBackpackCategoryIfEnabled(nil, filterType, customCategoryIcons[filterType], header, headersUsed)
			end
		end
		
		for i, equipSlot in ZO_Character_EnumerateOrderedEquipSlots() do -- equipable items
			addFilteredEquipCategoryIfPopulated(equipSlot)
		end

		self.categoryList:Commit()
		headersUsed = {}
	end
end

--------------------------------------------------------------------------------------------------
-- Sort Functions For Merch/Bank
--------------------------------------------------------------------------------------------------
local DEFAULT_SORT_KEYS = {
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
}

local VAR_ENTRY_ORDER_CURRENCY = 1
local VAR_ENTRY_ORDER_OTHER = 2

local function sortJunkToTOP(left, right)
	local leftOrder = VAR_ENTRY_ORDER_OTHER
	if left.isCurrenciesMenuEntry or left.currencyType then
		leftOrder = VAR_ENTRY_ORDER_CURRENCY
	end
	
	local rightOrder = VAR_ENTRY_ORDER_OTHER
	if right.isCurrenciesMenuEntry or right.currencyType then
		rightOrder = VAR_ENTRY_ORDER_CURRENCY
	end
	
	if leftOrder < rightOrder then
		return true
	elseif leftOrder > rightOrder then
		return false
	elseif leftOrder == VAR_ENTRY_ORDER_OTHER then

		if left.isJunk or right.isJunk then
			return ZO_TableOrderingFunction(left, right, "isJunk", DEFAULT_SORT_KEYS, savedVars.withdraw)
		end
		return ZO_TableOrderingFunction(left, right, GAMEPAD_BANKING:GetCurrentSortParams())
	else
		return false
	end
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
	isJunk = { tiebreaker = "customSortOrder", tieBreakerSortOrder = ZO_SORT_ORDER_UP }
}
local function sellSortFunc(data1, data2)
	if data1.isJunk or data2.isJunk then
		return ZO_TableOrderingFunction(data1, data2, "isJunk", SELL_SORT_KEYS, ZO_SORT_ORDER_DOWN)
	end
	return ZO_TableOrderingFunction(data1, data2, "customSortOrder", SELL_SORT_KEYS, ZO_SORT_ORDER_UP)
end

--------------------------------------------------------------------------------------------------
-- Merch/Bank junk sort
--------------------------------------------------------------------------------------------------
function IJA_GPInventory:InitJunkSort()
	savedVars = self.savedVars
	-------------------------------------
	-- Gamepad Merchant Inventory List
	-------------------------------------
	local storeComponents = STORE_WINDOW_GAMEPAD.components
	storeComponents[ZO_MODE_STORE_SELL].list.sortFunc = sellSortFunc

	--self.components[component:GetStoreMode()] = component
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
	local gamepadBankSCene = SCENE_MANAGER:GetScene("gamepad_banking")
	
	local function setBankSortFuncitons()
		local gamepadBanking = GAMEPAD_BANKING
		gamepadBanking.withdrawList:SetSortFunction(sortJunkToTOP)
		gamepadBanking.depositList:SetSortFunction(sortJunkToBottom)

	end

	local function stateChange(oldState, newState)
		if newState == SCENE_SHOWING then
			gamepadBankSCene:UnregisterCallback("StateChange", stateChange)
			setBankSortFuncitons()
		end
	end
	gamepadBankSCene:RegisterCallback("StateChange", stateChange)
end

--------------------------------------------------------------------------------------------------
-- Add Mark/Unmark as Junk to Inventory Item Action list
--------------------------------------------------------------------------------------------------
function IJA_GPInventory:AddInventoryActions()
	local LCM = LibCustomMenu
	if not LCM then return end

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
			GAMEPAD_INVENTORY:SwitchActiveList(INVENTORY_CATEGORY_LIST, true)
	--		GAMEPAD_INVENTORY:SwitchActiveList(INVENTORY_CATEGORY_LIST
		end
		
		local inventorySlot = SHARED_INVENTORY:GenerateSingleSlotData(bagId, slotIndex)
		CALLBACK_MANAGER:FireCallbacks("InventorySlotUpdate", inventorySlot)
	end

	local function addItem(inventorySlot, slotActions)
		local valid = ZO_Inventory_GetBagAndIndex(inventorySlot)
	--	if not valid or inventorySlot.stolen then return end
		if not valid then return end
		
		local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)
		if canSceneHandleJunk() then
			
	--		if CanItemBeMarkedAsJunk(bag, index) and not QUICKSLOT_WINDOW:AreQuickSlotsShowing() and IsInGamepadPreferredMode() then
			if CanItemBeMarkedAsJunk(bag, index) and IsInGamepadPreferredMode() then
				local isJunk = IsItemJunk(bag, index)
				local enableSlotAction = isJunk or (not IsItemPlayerLocked(bag, index))
				
				if enableSlotAction then
					local slotActionString = isJunk and SI_ITEM_ACTION_UNMARK_AS_JUNK or SI_ITEM_ACTION_MARK_AS_JUNK
					slotActions:AddCustomSlotAction(slotActionString, function() markAsJunkHelper(bag, index, not isJunk) end, "")
				end
			end
		end
	end

	LCM:RegisterKeyStripEnter(addItem, LCM.CATEGORY_PRIMARY)
end

--------------------------------------------------------------------------------------------------
-- Settings menu
--------------------------------------------------------------------------------------------------
local function delayedInventoryRefresh(purge)
	local function OnUpdateHandler()
		if purge then
			for k, bagId in pairs({BAG_BACKPACK, BAG_WORN, BAG_VIRTUAL, BAG_BANK, BAG_SUBSCRIBER_BANK}) do
				if SHARED_INVENTORY.bagCache[bagId] ~= nil then
					SHARED_INVENTORY.bagCache[bagId] = {}
				end
			end
		end
		
		refreshInventory()
	end
	jo_callLaterOnNextScene(ADDON_SHORT_NAME, OnUpdateHandler)
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
	LAM2:RegisterAddonPanel(ADDON_SHORT_NAME .. '_LAM', panelData)

	if not self.savedVars.enabledCategories then self.savedVars.enabledCategories = {} end
	if not self.savedVars.filteredCategories then self.savedVars.filteredCategories = {} end
	
	local controlList = {}
	for k, filterType in ipairs(customCategories) do
		local reference = ADDON_SHORT_NAME .. '_CustomCategories_SubMenu_' .. GetString(SI_IJA_GPINVENTORY_CATEGORY, filterType)
		local control = {
			type = "checkbox",
			name = '   ' .. GetString(SI_IJA_GPINVENTORY_CATEGORY, filterType),
			tooltip = GetString(SI_IJA_GPINVENTORY_CATEGORY .. "_TOOLTIP", filterType),
			getFunc = function() return self.savedVars.enabledCategories[filterType] end,
			setFunc = function(value) 
				self.savedVars.enabledCategories[filterType] = value
				delayedInventoryRefresh(not value)
			end,
			width = "full",
			reference = reference
		}
		controlList[k] = control
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
			reference = ADDON_SHORT_NAME .. "_CustomCategories_SubMenu",
			controls = controlList,
		},
	}
	LAM2:RegisterOptionControls(ADDON_SHORT_NAME.. '_LAM', optionsTable)
end

function IJA_GPInventory:InitializeKeybinds()
	self.destroyAllKeybindButton = {
		alignment = KEYBIND_STRIP_ALIGN_LEFT,
		name = GetString(SI_DESTROY_ALL_JUNK_KEYBIND_TEXT),
		keybind = "UI_SHORTCUT_QUINARY",
		order = 2500,
		disabledDuringSceneHiding = true,
		visible = function()
			local targetCategoryData = GAMEPAD_INVENTORY.categoryList:GetTargetData()
			local filterType = targetCategoryData.filterType
			return filterType == ITEMFILTERTYPE_JUNK
		--	return VAR_CURRENT_CATEGORY_FILTER == ITEMFILTERTYPE_JUNK
		end,
		callback = function()
			ZO_Dialogs_ShowPlatformDialog(CONFIRM_DELETE_ALL_DIALOGUE)
		end
	}
end

function IJA_GPInventory:InitializeDialogue()
	local confirmAllJunkDialogue =  {
		gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC, allowShowOnNextScene = true },
		title =
		{
			text = SI_PROMPT_TITLE_DESTROY_ITEMS,
		},
		mainText = 
		{
			text = function(dialog)
				local numJunkItems = getNumJunkItems()
				local warningString = numJunkItems > 1 and SI_IJA_GPINVENTORY_DESTROY_ALL_WARNING2 or SI_IJA_GPINVENTORY_DESTROY_ALL_WARNING1
				return zo_strformat(warningString, (numJunkItems or 'error'))
			end,
		},
		buttons =
		{
			[1] =
			{
				text = SI_DESTROY_ALL_JUNK_CONFIRM,
				callback = function() 
					DestroyAllJunk()
				--	refreshInventory()
				end,
				clickSound = SOUNDS.INVENTORY_DESTROY_JUNK,
			},
			[2] =
			{
				text = SI_DIALOG_DECLINE,
			},
		}
	}
	ZO_Dialogs_RegisterCustomDialog(CONFIRM_DELETE_ALL_DIALOGUE, confirmAllJunkDialogue)
end

--------------------------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------------------------
function IJA_GPInventory_Initialize( ... )
	IJA_GPINVENTORY = IJA_GPInventory:New( ... )
end
