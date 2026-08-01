-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: dataType.lua
-- File Description: This file contains data which is needed for rule evaluation
-- Load Order Requirements: before Item 
-- 
-----------------------------------------------------------------------------------

local RbI = RulebasedInventory

local dataTypeStatic = {}
RbI.dataTypeStatic = dataTypeStatic
local itemCatalog = {}
RbI.itemCatalog = itemCatalog
local utils = RbI.utils
local dataTypeHandler = {}
RbI.dataTypeHandler = dataTypeHandler
RbI.data = {}

function dataTypeHandler.ContainsValue(dataTypeData, value)
	if(type(dataTypeData) == 'table') then
		for _, cur in pairs(dataTypeData) do
			if(cur == value) then return true end
		end
	elseif(dataTypeData == value) then return true end
	return false
end

-- adds key-value pair to the given data-table, if multiple values exists for one key
-- it will be stored into a table
function dataTypeHandler.addData(dataTable, key, value)
	if(type(value) == 'table') then
		for _, cur in pairs(value) do
			dataTypeHandler.addData(dataTable, key, cur)
		end
	else
		local currentValues = dataTable[key]
		if(currentValues) then
			if(type(currentValues) == 'table') then
				if(not utils.TableContainsValue(currentValues, value)) then
					table.insert(currentValues, value)
				end
			elseif(currentValues ~= value) then
				local newTable = {}
				table.insert(newTable, currentValues)
				table.insert(newTable, value)
				dataTable[key] = newTable
			end
		else
			dataTable[key] = value
		end
	end
end
function dataTypeHandler.removeData(dataTable, key, value) -- only for collected
	local currentValues = dataTable[key]
	if(currentValues) then
		if(type(currentValues) == 'table') then
			utils.TableRemoveElement(currentValues, value)
			if(utils.count(currentValues) == 0) then
				dataTable[key] = nil
			end
		elseif(currentValues == value) then
			dataTable[key] = nil
		else
			error("Data to remove not found "..tostring(key)..", "..tostring(key))
		end
	else
		dataTable[key] = nil
	end
end

function dataTypeHandler.isStaticDataTypeKey(dataTypeName, key)
	return dataTypeStatic[dataTypeName][key]~=nil
end

function dataTypeHandler.GetKeysForValues(dataTypeData, values)
	if(type(values) ~= 'table') then
		values = {values}
	end
	local keys = {}
	for _, value in pairs(values) do
		for key, val in pairs(dataTypeData) do
			if(not utils.TableContainsValue(keys, key)) then
				if(type(val) == 'table') then
					for _, cur in pairs(val) do
						if (cur == value) then
							keys[#keys+1] = key
							break
						end
					end
				else
					if (val == value) then keys[#keys+1] = key end
				end
			end
		end
	end
	return keys
end


local function registerDataType(name, data)
	if(dataTypeStatic[name] ~= nil) then
		error('DataType: \''..name..'\' already exists!')
	end
	dataTypeStatic[name] = data
end

local addFnMetatable = {
	__add = function(self, fn)
		if(self.str) then
			self.str = fn(self.str)
		end
		return self
	end,
	__index = {
		gsub = function(self, from, to)
			if(self.str) then
				self.str = self.str:gsub(from, to)
			end
			return self
		end,
		prefix = function(self, toAdd)
			if(self.str) then
				self.str = toAdd..self.str
			end
			return self
		end,
		map = function(self, from, to)
			if(self.str == from) then
				self.str = to
			end
			return self
		end
	}
}
local function wrap(str)
	return setmetatable({ str=str }, addFnMetatable)
end
local function removePrefix(str, prefix, suffix)
	local result
	if(utils.startsWith(str, prefix)) then
		result = str:sub(prefix:len() + 1)
		if(suffix and utils.endsWith(str, suffix)) then
			result = result:sub(1, -suffix:len()-1)
		end
	end
	return wrap(result)
end
local function removeSuffix(str, suffix)
	local result
	if(utils.endsWith(str, suffix)) then
		result = str:sub(1, -suffix:len()-1)
	end
	return wrap(result)
end
local function gsub(from, to)
	return function(str)
		return str:gsub(from, to)
	end
end
local function prefix(toAdd)
	return function(str)
		return toAdd..str
	end
end

local constantReader = utils.ConstanteReaderNew()
RbI.constantReader = constantReader

-- bags where items can be junked
local junkBags = {
	[BAG_BACKPACK] = true,
	[BAG_BANK] = true,
	[BAG_SUBSCRIBER_BANK] = true,
	[BAG_HOUSE_BANK_ONE] = true,
	[BAG_HOUSE_BANK_TWO] = true,
	[BAG_HOUSE_BANK_THREE] = true,
	[BAG_HOUSE_BANK_FOUR] = true,
	[BAG_HOUSE_BANK_FIVE] = true,
	[BAG_HOUSE_BANK_SIX] = true,
	[BAG_HOUSE_BANK_SEVEN] = true,
	[BAG_HOUSE_BANK_EIGHT] = true,
	[BAG_HOUSE_BANK_NINE] = true,
	[BAG_HOUSE_BANK_TEN] = true,
}
local homebanks = {
	["1"]=BAG_HOUSE_BANK_ONE,
	["2"]=BAG_HOUSE_BANK_TWO,
	["3"]=BAG_HOUSE_BANK_THREE,
	["4"]=BAG_HOUSE_BANK_FOUR,
	["5"]=BAG_HOUSE_BANK_FIVE,
	["6"]=BAG_HOUSE_BANK_SIX,
	["7"]=BAG_HOUSE_BANK_SEVEN,
	["8"]=BAG_HOUSE_BANK_EIGHT,
	["9"]=BAG_HOUSE_BANK_NINE,
	["10"]=BAG_HOUSE_BANK_TEN,
}
RbI.data.isJunkBag = function(bagId)
	return junkBags[bagId] or false
end
RbI.data.getHomeBanks = function()
	return homebanks
end
RbI.data.getBankName = function(bagId)
	if(bagId == BAG_BANK) then return "Bank" end
	if(bagId == BAG_FURNITURE_VAULT) then return "FurnishingVault" end
	local homebankId = utils.GetKeyForValue(bagId, homebanks)
	if(not homebankId) then error("Can not found bankName for bagId: "..tostring(bagId)) end
	return "Homebank"..homebankId
end
RbI.data.isHomebank = function(bagId)
	return utils.GetKeyForValue(bagId, homebanks)
end


registerDataType('bag', {
	backpack = BAG_BACKPACK,
	bag_worn = BAG_WORN,
	bank = BAG_BANK,
	buyback = BAG_BUYBACK,
	craftbag = BAG_VIRTUAL,
	delete = BAG_DELETE,
	guildbank = BAG_GUILDBANK,
	housebank1 = BAG_HOUSE_BANK_ONE,
	housebank10 = BAG_HOUSE_BANK_TEN,
	housebank2 = BAG_HOUSE_BANK_TWO,
	housebank3 = BAG_HOUSE_BANK_THREE,
	housebank4 = BAG_HOUSE_BANK_FOUR,
	housebank5 = BAG_HOUSE_BANK_FIVE,
	housebank6 = BAG_HOUSE_BANK_SIX,
	housebank7 = BAG_HOUSE_BANK_SEVEN,
	housebank8 = BAG_HOUSE_BANK_EIGHT,
	housebank9 = BAG_HOUSE_BANK_NINE,
	subscriberbank = BAG_SUBSCRIBER_BANK,
	companion_worn = BAG_COMPANION_WORN,
})
registerDataType('bank', {
	bank = BAG_BANK,
	guildbank = BAG_GUILDBANK,
	housebank1 = BAG_HOUSE_BANK_ONE,
	housebank2 = BAG_HOUSE_BANK_TWO,
	housebank3 = BAG_HOUSE_BANK_THREE,
	housebank4 = BAG_HOUSE_BANK_FOUR,
	housebank5 = BAG_HOUSE_BANK_FIVE,
	housebank6 = BAG_HOUSE_BANK_SIX,
	housebank7 = BAG_HOUSE_BANK_SEVEN,
	housebank8 = BAG_HOUSE_BANK_EIGHT,
	housebank9 = BAG_HOUSE_BANK_NINE,
	housebank10 = BAG_HOUSE_BANK_TEN,
})
-- SoulGemType
registerDataType('soulGemType', {
	empty = SOUL_GEM_TYPE_EMPTY,
	filled = SOUL_GEM_TYPE_FILLED,
})
-- GearCraftingType
registerDataType('gearCraftingType', {
	alchemy = CRAFTING_TYPE_ALCHEMY,
	blacksmithing = CRAFTING_TYPE_BLACKSMITHING,
	clothier = CRAFTING_TYPE_CLOTHIER,
	enchanting = CRAFTING_TYPE_ENCHANTING,
	provisioning = CRAFTING_TYPE_PROVISIONING,
	woodworking = CRAFTING_TYPE_WOODWORKING,
	jewelry = CRAFTING_TYPE_JEWELRYCRAFTING,
	none = CRAFTING_TYPE_INVALID,
})
-- RecipeCraftingType
registerDataType('recipeCraftingType', {
	alchemy = RECIPE_CRAFTING_SYSTEM_ALCHEMY_FORMULAE,
	blacksmithing = RECIPE_CRAFTING_SYSTEM_BLACKSMITHING_DIAGRAMS,
	clothier = RECIPE_CRAFTING_SYSTEM_CLOTHIER_PATTERNS,
	enchanting = RECIPE_CRAFTING_SYSTEM_ENCHANTING_SCHEMATICS,
	jewelry = RECIPE_CRAFTING_SYSTEM_JEWELRYCRAFTING_SKETCHES,
	provisioning = RECIPE_CRAFTING_SYSTEM_PROVISIONING_DESIGNS,
	woodworking = RECIPE_CRAFTING_SYSTEM_WOODWORKING_BLUEPRINTS,
	none = RECIPE_CRAFTING_SYSTEM_INVALID,
})

registerDataType('armorType', (function()
	local result = {}
	constantReader.addCallback('ARMORTYPE_(.*)', function(key, value, origKey)
		if(not utils.endsWith(key, '_VALUE') and not utils.endsWith(key, 'ITERATION_END') and not utils.endsWith(key, 'ITERATION_BEGIN')) then
			key = key:lower()
			result[key] = value
		end
	end)
	return result
end)())

registerDataType('bindType', {
	characterbound = BIND_TYPE_ON_PICKUP_BACKPACK,
	onequip = BIND_TYPE_ON_EQUIP,
	onpickup = BIND_TYPE_ON_PICKUP,
	unbound = BIND_TYPE_NONE,
})
registerDataType('equipType', {
	chest = EQUIP_TYPE_CHEST,
	costume = EQUIP_TYPE_COSTUME,
	feet = EQUIP_TYPE_FEET,
	hand = EQUIP_TYPE_HAND,
	head = EQUIP_TYPE_HEAD,
	legs = EQUIP_TYPE_LEGS,
	mainhand = EQUIP_TYPE_MAIN_HAND,
	neck = EQUIP_TYPE_NECK,
	none = EQUIP_TYPE_INVALID,
	offhand = EQUIP_TYPE_OFF_HAND,
	onehand = EQUIP_TYPE_ONE_HAND,
	poison = EQUIP_TYPE_POISON,
	ring = EQUIP_TYPE_RING,
	shoulders = EQUIP_TYPE_SHOULDERS,
	twohand = EQUIP_TYPE_TWO_HAND,
	waist = EQUIP_TYPE_WAIST,
})
registerDataType('quality', {
	trash = ITEM_QUALITY_TRASH,
	normal = ITEM_QUALITY_NORMAL,
	fine = ITEM_QUALITY_MAGIC,
	superior = ITEM_QUALITY_ARCANE,
	epic = ITEM_QUALITY_ARTIFACT,
	legendary = ITEM_QUALITY_LEGENDARY,
})

registerDataType('style', (function()
	local result = {}
	constantReader.addCallback('ITEMSTYLE_(.*)', function(key, value, origKey)
		if(not utils.endsWith(key, '_VALUE')) then
			key = removePrefix(key, 'RACIAL_').str
					or removePrefix(key, 'AREA_').str
					or removePrefix(key, 'ORG_').str
					or removePrefix(key, 'ENEMY_').str
					or removePrefix(key, 'DEITY_').str
					or removePrefix(key, 'ALLIANCE_').str
					or removePrefix(key, 'HOLIDAY_').str
					or removePrefix(key, 'RAIDS_').str
					or key
			key = key.str or key
			key = key:gsub('_', ''):lower()
			result[key] = value
		end
	end)
	-- legacy addition
	result.styleless = ITEMSTYLE_NONE
	return result
end)())

registerDataType('chatterOption', (function()
	local result = {}
	constantReader.addCallback('CHATTER_(.*)', function(key, value, origKey)
		result[tostring(value)] = key
	end)
	return result
end)())

registerDataType('interactionType', (function()
	local result = {}
	constantReader.addCallback('INTERACTION_(.*)', function(key, value, origKey)
		result[tostring(value)] = key
	end)
	return result
end)())

if(FCOIS) then
	local ids = {}
	dataTypeStatic["fcoisMarkIds"] = ids
	registerDataType('fcoisMark', (function()
		local result = {}
		constantReader.addCallback('FCOIS_CON_ICON_(.*)',
			function(key, value, origKey)
				if(type(value) == "number" and value > 0) then
					result[key:lower()] = value
					ids[value] = key:lower()
				end
			end
		)
		return result
	end)())
end

registerDataType('sType', (function()
	local result = {}
	constantReader.addCallback('SPECIALIZED_ITEMTYPE_(.*)', function(key, value, origKey)
		if(not utils.endsWith(key, '_VALUE') and not utils.endsWith(key, 'ITERATION_END') and not utils.endsWith(key, 'ITERATION_BEGIN')) then
			key = (removePrefix(key, 'TROPHY_', '_REPORT') + gsub('TREASURE_MAP', 'treasuremap')).str
					or (removePrefix(key, 'COLLECTIBLE_') + gsub('_', '')).str
					or (removePrefix(key, 'RECIPE_', '_FURNISHING')
							+ gsub('PROVISIONING_STANDARD_', 'recipe&')
							+ gsub('.*_', '')
							+ gsub('&', '_')
						).str
					or (removePrefix(key, 'RACIAL_STYLE_') + gsub('_', '')).str
					or (removePrefix(key, 'SIEGE_')
						:map("MONSTER", "siege_monster")
						:map("UNIVERSAL", "siege_universal")
						:map("OIL", "siege_oil")
						).str
					or (removePrefix(key, 'ENCHANTING_RUNE_')).str
					or (removePrefix(key, 'RAW_MATERIAL')
						:prefix('material_raw_style')
						).str
					or (removePrefix(key, 'FURNISHING_MATERIAL_')
						:map('JEWELRYCRAFTING', 'jewelry')
						:prefix("material_furnishing_")
						).str
					or (removeSuffix(key, '_RAW_MATERIAL')
						:gsub('JEWELRYCRAFTING', 'jewelry')
						:prefix('material_raw_')).str
					or (removeSuffix(key, '_MATERIAL')
						:gsub('JEWELRYCRAFTING', 'jewelry')
						:prefix('material_refined_')).str
					or (removeSuffix(key, '_BOOSTER')
						:gsub("JEWELRYCRAFTING_RAW", "raw_jewelry")
						:gsub("JEWELRYCRAFTING", "refined_jewelry")
						:prefix('booster_')
						).str
					or (wrap(key):map("MASTER_WRIT", "masterwrit")
						:map("HOLIDAY_WRIT", "holidaywrit")
						:map("SOUL_GEM", "soulgem")
						:gsub("CRAFTING_STATION", "craftingstation")
						:map("CROWN_ITEM", "crownitem")
						:map("DYE_STAMP", "dyestamp")
						:map("CROWN_REPAIR", "crownrepair")
						:map("AVA_REPAIR", "avarepair")
						:map("ARMOR_TRAIT", "material_armortrait")
						:map("WEAPON_TRAIT", "material_weapontrait")
						:map("JEWELRY_TRAIT", "material_refined_jewelrytrait")
						:map("JEWELRY_RAW_TRAIT", "material_raw_jewelrytrait")
						:gsub("TARGET_DUMMY", "targetdummy")
						:gsub("ANIMAL_PART", "animalpart")
						:gsub("CORDIAL_TEA", "cordialtea")
						:gsub("STYLE_PAGE", "stylepage")
						).str
			key = key:lower()
			--key = key:gsub('_', ''):lower()
			if(result[key]~=nil and result[key]~=value) then
				error("Key-Value-Difference: "..key.."="..result[key].." vs. "..origKey.."="..value)
			end
			result[key] = value
		end
	end)
	-- legacy additions
	result.typeless = 0
	return result
end)())

registerDataType('sTypeOld', {

	-- siege
	ballista = SPECIALIZED_ITEMTYPE_SIEGE_BALLISTA,
	battle_standard = SPECIALIZED_ITEMTYPE_SIEGE_BATTLE_STANDARD,
	catapult = SPECIALIZED_ITEMTYPE_SIEGE_CATAPULT,
	siege_oil = SPECIALIZED_ITEMTYPE_SIEGE_OIL,
	graveyard = SPECIALIZED_ITEMTYPE_SIEGE_GRAVEYARD,
	ram = SPECIALIZED_ITEMTYPE_SIEGE_RAM,
	siege_monster = SPECIALIZED_ITEMTYPE_SIEGE_MONSTER,
	siege_universal = SPECIALIZED_ITEMTYPE_SIEGE_UNIVERSAL,
	trebuchet = SPECIALIZED_ITEMTYPE_SIEGE_TREBUCHET,

	-- drink, food, furnishing, ingredient
	drink_alcoholic = SPECIALIZED_ITEMTYPE_DRINK_ALCOHOLIC,
	drink_cordialtea = SPECIALIZED_ITEMTYPE_DRINK_CORDIAL_TEA,
	drink_distillate = SPECIALIZED_ITEMTYPE_DRINK_DISTILLATE,
	drink_liqueur = SPECIALIZED_ITEMTYPE_DRINK_LIQUEUR,
	drink_tea = SPECIALIZED_ITEMTYPE_DRINK_TEA,
	drink_tincture = SPECIALIZED_ITEMTYPE_DRINK_TINCTURE,
	drink_tonic = SPECIALIZED_ITEMTYPE_DRINK_TONIC,
	drink_unique = SPECIALIZED_ITEMTYPE_DRINK_UNIQUE,
	food_entremet = SPECIALIZED_ITEMTYPE_FOOD_ENTREMET,
	food_fruit = SPECIALIZED_ITEMTYPE_FOOD_FRUIT,
	food_gourmet = SPECIALIZED_ITEMTYPE_FOOD_GOURMET,
	food_meat = SPECIALIZED_ITEMTYPE_FOOD_MEAT,
	food_ragout = SPECIALIZED_ITEMTYPE_FOOD_RAGOUT,
	food_savoury = SPECIALIZED_ITEMTYPE_FOOD_SAVOURY,
	food_unique = SPECIALIZED_ITEMTYPE_FOOD_UNIQUE,
	food_vegetable = SPECIALIZED_ITEMTYPE_FOOD_VEGETABLE,
	furnishing_craftingstation = SPECIALIZED_ITEMTYPE_FURNISHING_CRAFTING_STATION,
	furnishing_light = SPECIALIZED_ITEMTYPE_FURNISHING_LIGHT,
	furnishing_ornamental = SPECIALIZED_ITEMTYPE_FURNISHING_ORNAMENTAL,
	furnishing_seating = SPECIALIZED_ITEMTYPE_FURNISHING_SEATING,
	furnishing_targetdummy = SPECIALIZED_ITEMTYPE_FURNISHING_TARGET_DUMMY,
	ingredient_alcohol = SPECIALIZED_ITEMTYPE_INGREDIENT_ALCOHOL,
	ingredient_fruit = SPECIALIZED_ITEMTYPE_INGREDIENT_FRUIT,
	ingredient_meat = SPECIALIZED_ITEMTYPE_INGREDIENT_MEAT,
	ingredient_rare = SPECIALIZED_ITEMTYPE_INGREDIENT_RARE,
	ingredient_tea = SPECIALIZED_ITEMTYPE_INGREDIENT_TEA,
	ingredient_tonic = SPECIALIZED_ITEMTYPE_INGREDIENT_TONIC,
	ingredient_vegetable = SPECIALIZED_ITEMTYPE_INGREDIENT_VEGETABLE,

	-- trophy
	key = SPECIALIZED_ITEMTYPE_TROPHY_KEY,
	monstertrophy = SPECIALIZED_ITEMTYPE_COLLECTIBLE_MONSTER_TROPHY,
	museum_piece = SPECIALIZED_ITEMTYPE_TROPHY_MUSEUM_PIECE,
	s_material_upgrader = SPECIALIZED_ITEMTYPE_TROPHY_MATERIAL_UPGRADER,
	toy = SPECIALIZED_ITEMTYPE_TROPHY_TOY,
	scroll = SPECIALIZED_ITEMTYPE_TROPHY_SCROLL,
	survey = SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT,
	treasuremap = SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP,
	-- trophy fragment
	key_fragment = SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT,
	recipe_fragment = SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT,
	runebox_fragment = SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT,
	collectible_fragment = SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT,
	upgrade_fragment = SPECIALIZED_ITEMTYPE_TROPHY_UPGRADE_FRAGMENT,

	material_furnishing_alchemy = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_ALCHEMY,
	material_furnishing_blacksmithing = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_BLACKSMITHING,
	material_furnishing_clothier = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_CLOTHIER,
	material_furnishing_enchanting = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_ENCHANTING,
	material_furnishing_jewelry = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_JEWELRYCRAFTING,
	material_furnishing_provisioning = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_PROVISIONING,
	material_furnishing_woodworking = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_WOODWORKING,

	schematic = SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING,
	sketch = SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING,
	formula = SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING,
	blueprint = SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING,
	design = SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING,
	diagram = SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING,
	pattern = SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING,

	-- motif
	motifbook = SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK,
	motifchapter = SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER,

	container_currency = SPECIALIZED_ITEMTYPE_CONTAINER_CURRENCY,
	rarefish = SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH,
	reagent_animalpart = SPECIALIZED_ITEMTYPE_REAGENT_ANIMAL_PART,
	reagent_fungus = SPECIALIZED_ITEMTYPE_REAGENT_FUNGUS,
	reagent_herb = SPECIALIZED_ITEMTYPE_REAGENT_HERB,
	recipe_drink = SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK,
	recipe_food = SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD,
	s_additiv = SPECIALIZED_ITEMTYPE_ADDITIVE,
	s_armor = SPECIALIZED_ITEMTYPE_ARMOR,
	s_aspect = SPECIALIZED_ITEMTYPE_ENCHANTING_RUNE_ASPECT,
	s_avarepair = SPECIALIZED_ITEMTYPE_AVA_REPAIR,
	s_booster_armor = SPECIALIZED_ITEMTYPE_ARMOR_BOOSTER,
	s_booster_blacksmithing = SPECIALIZED_ITEMTYPE_BLACKSMITHING_BOOSTER,
	s_booster_clothier = SPECIALIZED_ITEMTYPE_CLOTHIER_BOOSTER,
	s_booster_enchantment = SPECIALIZED_ITEMTYPE_ENCHANTMENT_BOOSTER,
	s_booster_raw_jewelry = SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER,
	s_booster_refined_jewelry = SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_BOOSTER,
	s_booster_weapon = SPECIALIZED_ITEMTYPE_WEAPON_BOOSTER,
	s_booster_woodworking = SPECIALIZED_ITEMTYPE_WOODWORKING_BOOSTER,
	s_container = SPECIALIZED_ITEMTYPE_CONTAINER,
	s_costume = SPECIALIZED_ITEMTYPE_COSTUME,
	s_crownitem = SPECIALIZED_ITEMTYPE_CROWN_ITEM,
	s_crownrepair = SPECIALIZED_ITEMTYPE_CROWN_REPAIR,
	s_disguise = SPECIALIZED_ITEMTYPE_DISGUISE,
	s_dyestamp = SPECIALIZED_ITEMTYPE_DYE_STAMP,
	s_essence = SPECIALIZED_ITEMTYPE_ENCHANTING_RUNE_ESSENCE,
	s_eventcontainer = SPECIALIZED_ITEMTYPE_CONTAINER_EVENT,
	s_fish = SPECIALIZED_ITEMTYPE_FISH,
	s_flavoring = SPECIALIZED_ITEMTYPE_FLAVORING,
	s_glyph_armor = SPECIALIZED_ITEMTYPE_GLYPH_ARMOR,
	s_glyph_jewelry = SPECIALIZED_ITEMTYPE_GLYPH_JEWELRY,
	s_glyph_weapon = SPECIALIZED_ITEMTYPE_GLYPH_WEAPON,
	s_ingridient_drink_additiv = SPECIALIZED_ITEMTYPE_INGREDIENT_DRINK_ADDITIVE,
	s_ingridient_food_additiv = SPECIALIZED_ITEMTYPE_INGREDIENT_FOOD_ADDITIVE,
	s_lockpick = SPECIALIZED_ITEMTYPE_LOCKPICK,
	s_lure = SPECIALIZED_ITEMTYPE_LURE,
	s_masterwrit = SPECIALIZED_ITEMTYPE_MASTER_WRIT,
	holidaywrit = SPECIALIZED_ITEMTYPE_HOLIDAY_WRIT,
	s_material_armortrait = SPECIALIZED_ITEMTYPE_ARMOR_TRAIT,
	s_material_raw_blacksmithing = SPECIALIZED_ITEMTYPE_BLACKSMITHING_RAW_MATERIAL,
	s_material_raw_clothier = SPECIALIZED_ITEMTYPE_CLOTHIER_RAW_MATERIAL,
	s_material_raw_jewelry = SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL,
	s_material_raw_jewelrytrait = SPECIALIZED_ITEMTYPE_JEWELRY_RAW_TRAIT,
	s_material_raw_style = SPECIALIZED_ITEMTYPE_RAW_MATERIAL,
	s_material_raw_woodworking = SPECIALIZED_ITEMTYPE_WOODWORKING_RAW_MATERIAL,
	s_material_refined_blacksmithing = SPECIALIZED_ITEMTYPE_BLACKSMITHING_MATERIAL,
	s_material_refined_clothier = SPECIALIZED_ITEMTYPE_CLOTHIER_MATERIAL,
	s_material_refined_jewelry = SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_MATERIAL,
	s_material_refined_jewelrytrait = SPECIALIZED_ITEMTYPE_JEWELRY_TRAIT,
	s_material_refined_style = SPECIALIZED_ITEMTYPE_STYLE_MATERIAL,
	s_material_refined_woodworking = SPECIALIZED_ITEMTYPE_WOODWORKING_MATERIAL,
	s_material_weapontrait = SPECIALIZED_ITEMTYPE_WEAPON_TRAIT,
	s_mount = SPECIALIZED_ITEMTYPE_MOUNT,
	s_plug = SPECIALIZED_ITEMTYPE_PLUG,
	s_poison = SPECIALIZED_ITEMTYPE_POISON,
	s_poison_base = SPECIALIZED_ITEMTYPE_POISON_BASE,
	s_potency = SPECIALIZED_ITEMTYPE_ENCHANTING_RUNE_POTENCY,
	s_potion = SPECIALIZED_ITEMTYPE_POTION,
	s_potion_base = SPECIALIZED_ITEMTYPE_POTION_BASE,
	s_soulgem = SPECIALIZED_ITEMTYPE_SOUL_GEM,
	s_spellcrafting_tablet = SPECIALIZED_ITEMTYPE_SPELLCRAFTING_TABLET,
	s_spice = SPECIALIZED_ITEMTYPE_SPICE,
	s_tabard = SPECIALIZED_ITEMTYPE_TABARD,
	s_tool = SPECIALIZED_ITEMTYPE_TOOL,
	s_trash = SPECIALIZED_ITEMTYPE_TRASH,
	s_treasure = SPECIALIZED_ITEMTYPE_TREASURE,
	s_typeless = SPECIALIZED_ITEMTYPE_NONE,
	s_weapon = SPECIALIZED_ITEMTYPE_WEAPON,
})

registerDataType('type', (function()
	local result = {}
	constantReader.addCallback('ITEMTYPE_(.*)', function(key, value, origKey)
		if(not utils.endsWith(key, '_VALUE') and not utils.endsWith(key, 'ITERATION_END') and not utils.endsWith(key, 'ITERATION_BEGIN')) then
			key = (removePrefix(key, 'ENCHANTING_RUNE_')).str
					or (removePrefix(key, 'RAW_MATERIAL')
						:prefix('material_raw_style')
						).str
					or (removeSuffix(key, '_RAW_MATERIAL')
						:gsub('JEWELRYCRAFTING', 'jewelry')
						:prefix('material_raw_')).str
					or (removePrefix(key, 'FURNISHING_MATERIAL')
						:prefix('material_furnishing')).str
					or (removeSuffix(key, '_MATERIAL')
						:gsub('JEWELRYCRAFTING', 'jewelry')
						:prefix('material_refined_')).str
					or (removeSuffix(key, '_BOOSTER')
						:gsub("JEWELRYCRAFTING_RAW", "raw_jewelry")
						:gsub("JEWELRYCRAFTING", "refined_jewelry")
						:prefix('booster_')).str
					or (wrap(key):map("MASTER_WRIT", "masterwrit")
						:map("SOUL_GEM", "soulgem")
						:map("CROWN_ITEM", "crownitem")
						:map("CROWN_REPAIR", "crownrepair")
						:map("DYE_STAMP", "dyestamp")
						:map("AVA_REPAIR", "avarepair")
						:gsub("RACIAL_STYLE_", "")
						:map("JEWELRY_RAW_TRAIT", "material_raw_jewelrytrait")
						:map("ARMOR_TRAIT", "material_armortrait")
						:map("WEAPON_TRAIT", "material_weapontrait")
						:map("JEWELRY_TRAIT", "material_refined_jewelrytrait")
						).str
			key = key:lower()
			--key = key:gsub('_', ''):lower()
			if(result[key]~=nil and result[key]~=value) then
				error("Key-Value-Difference: "..key.."="..result[key].." vs. "..origKey.."="..value)
			end
			result[key] = value
		end
	end)
	-- legacy additions
	result.typeless = ITEMTYPE_NONE
	return result
end)())

registerDataType('typeOld', {
	additive = ITEMTYPE_ADDITIVE,
	armor = ITEMTYPE_ARMOR,
	armor_booster = ITEMTYPE_ARMOR_BOOSTER,
	aspect = ITEMTYPE_ENCHANTING_RUNE_ASPECT,
	avarepair = ITEMTYPE_AVA_REPAIR,
	booster_blacksmithing = ITEMTYPE_BLACKSMITHING_BOOSTER,
	booster_clothier = ITEMTYPE_CLOTHIER_BOOSTER,
	booster_enchantment = ITEMTYPE_ENCHANTMENT_BOOSTER,
	booster_raw_jewelry = ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER,
	booster_refined_jewelry = ITEMTYPE_JEWELRYCRAFTING_BOOSTER,
	booster_weapon = ITEMTYPE_WEAPON_BOOSTER,
	booster_woodworking = ITEMTYPE_WOODWORKING_BOOSTER,
	collectible = ITEMTYPE_COLLECTIBLE,
	container = ITEMTYPE_CONTAINER,
	crownitem = ITEMTYPE_CROWN_ITEM,
	crownrepair = ITEMTYPE_CROWN_REPAIR,
	costume = ITEMTYPE_COSTUME,
	disguise = ITEMTYPE_DISGUISE,
	drink = ITEMTYPE_DRINK,
	dyestamp = ITEMTYPE_DYE_STAMP,
	essence = ITEMTYPE_ENCHANTING_RUNE_ESSENCE,
	fish = ITEMTYPE_FISH,
	flavoring = ITEMTYPE_FLAVORING,
	food = ITEMTYPE_FOOD,
	furnishing = ITEMTYPE_FURNISHING,
	glyph_armor = ITEMTYPE_GLYPH_ARMOR,
	glyph_jewelry = ITEMTYPE_GLYPH_JEWELRY,
	glyph_weapon = ITEMTYPE_GLYPH_WEAPON,
	ingredient = ITEMTYPE_INGREDIENT,
	itemtype_deprecated = ITEMTYPE_DEPRECATED,
	motif = ITEMTYPE_RACIAL_STYLE_MOTIF,
	lockpick = ITEMTYPE_LOCKPICK,
	lure = ITEMTYPE_LURE,
	masterwrit = ITEMTYPE_MASTER_WRIT,
	material_armortrait = ITEMTYPE_ARMOR_TRAIT,
	material_furnishing = ITEMTYPE_FURNISHING_MATERIAL,
	material_raw_blacksmithing = ITEMTYPE_BLACKSMITHING_RAW_MATERIAL,
	material_raw_clothier = ITEMTYPE_CLOTHIER_RAW_MATERIAL,
	material_raw_jewelry = ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL,
	material_raw_jewelrytrait = ITEMTYPE_JEWELRY_RAW_TRAIT,
	material_raw_style = ITEMTYPE_RAW_MATERIAL,
	material_raw_woodworking = ITEMTYPE_WOODWORKING_RAW_MATERIAL,
	material_refined_blacksmithing = ITEMTYPE_BLACKSMITHING_MATERIAL,
	material_refined_clothier = ITEMTYPE_CLOTHIER_MATERIAL,
	material_refined_jewelry = ITEMTYPE_JEWELRYCRAFTING_MATERIAL,
	material_refined_jewelrytrait = ITEMTYPE_JEWELRY_TRAIT,
	material_refined_style = ITEMTYPE_STYLE_MATERIAL,
	material_refined_woodworking = ITEMTYPE_WOODWORKING_MATERIAL,
	material_weapontrait = ITEMTYPE_WEAPON_TRAIT,
	container_currency = ITEMTYPE_CONTAINER_CURRENCY,
	mount = ITEMTYPE_MOUNT,
	plug = ITEMTYPE_PLUG,
	poison = ITEMTYPE_POISON,
	poison_base = ITEMTYPE_POISON_BASE,
	potency = ITEMTYPE_ENCHANTING_RUNE_POTENCY,
	potion = ITEMTYPE_POTION,
	potion_base = ITEMTYPE_POTION_BASE,
	reagent = ITEMTYPE_REAGENT,
	recipe = ITEMTYPE_RECIPE,
	siege = ITEMTYPE_SIEGE,
	soulgem = ITEMTYPE_SOUL_GEM,
	spellcraftingtablet = ITEMTYPE_SPELLCRAFTING_TABLET,
	spice = ITEMTYPE_SPICE,
	tabard = ITEMTYPE_TABARD,
	tool = ITEMTYPE_TOOL,
	trash = ITEMTYPE_TRASH,
	treasure = ITEMTYPE_TREASURE,
	trophy = ITEMTYPE_TROPHY,
	typeless = ITEMTYPE_NONE,
	weapon = ITEMTYPE_WEAPON,
})

-- TraitCategory
registerDataType('traitCategory', {
	armor = ITEM_TRAIT_TYPE_CATEGORY_ARMOR,
	jewelry = ITEM_TRAIT_TYPE_CATEGORY_JEWELRY,
	none = ITEM_TRAIT_TYPE_CATEGORY_NONE,
	weapon = ITEM_TRAIT_TYPE_CATEGORY_WEAPON,
})

local function switchName(key)
	if(key == 'armor_exploration' or key == 'weapon_weighted') then
		return nil
	end
	if(key == 'armor_prosperous') then -- rename
		return 'armor_invigorating'
	end
	if(key == 'armor_well_fitted') then -- rename
		return 'armor_wellfitted'
	end
	return key
end

registerDataType('trait', (function()
	local result = {}
	constantReader.addCallback('ITEM_TRAIT_TYPE_([^C].*)', function(key, value, origKey)
		if(not utils.endsWith(key, '_VALUE') and not utils.endsWith(key, 'ITERATION_END') and not utils.endsWith(key, 'ITERATION_BEGIN')) then
			key = key:lower()
			key = switchName(key)
			if(key == nil) then return end
			dataTypeHandler.addData(result, key, value)
			local traitName = key:match("_(.*)")
			if(traitName ~= nil) then -- e.g.: key='none'
				dataTypeHandler.addData(result, traitName, value)
			end
		end
	end)
	return result
end)())

registerDataType('filterType', (function()
	local result = {}
	constantReader.addCallback('ITEMFILTERTYPE_(.*)', function(key, value, origKey)
		if(not utils.startsWith(key, 'AF_') and not utils.endsWith(key, '_VALUE') and not utils.endsWith(key, 'ITERATION_END') and not utils.endsWith(key, 'ITERATION_BEGIN')) then
			key = key:lower()
			result[key] = value
		end
	end)
	return result
end)())

registerDataType('traitInfo', {
	intricate = ITEM_TRAIT_INFORMATION_INTRICATE,
	none = ITEM_TRAIT_INFORMATION_NONE,
	ornate = ITEM_TRAIT_INFORMATION_ORNATE,
	researchable = ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED,
	retraited = ITEM_TRAIT_INFORMATION_RETRAITED,
	reconstructed = ITEM_TRAIT_INFORMATION_RECONSTRUCTED,
})

registerDataType('mountTrainType', {
	capacity = RIDING_TRAIN_CARRYING_CAPACITY,
	speed = RIDING_TRAIN_SPEED,
	stamina = RIDING_TRAIN_STAMINA,
})

registerDataType('weaponType', {
	axe = WEAPONTYPE_AXE,
	battleaxe = WEAPONTYPE_TWO_HANDED_AXE,
	bow = WEAPONTYPE_BOW,
	dagger = WEAPONTYPE_DAGGER,
	firestaff = WEAPONTYPE_FIRE_STAFF,
	froststaff = WEAPONTYPE_FROST_STAFF,
	greatsword = WEAPONTYPE_TWO_HANDED_SWORD,
	healingstaff = WEAPONTYPE_HEALING_STAFF,
	lightningstaff = WEAPONTYPE_LIGHTNING_STAFF,
	mace = WEAPONTYPE_HAMMER,
	maul = WEAPONTYPE_TWO_HANDED_HAMMER,
	shield = WEAPONTYPE_SHIELD,
	sword = WEAPONTYPE_SWORD,
	none = WEAPONTYPE_NONE,
	prop = WEAPONTYPE_PROP,
	rune = WEAPONTYPE_RUNE,
})

registerDataType('assistantName', (function()
	local assistantNames = {}
	local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCategoryDataById(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT)
	for _, data in ipairs(collectibleData.orderedCollectibles) do
		local assistantName = data.name
		assistantName = zo_strformat("<<C:1>>", assistantName)
		assistantNames[assistantName:lower()] = assistantName
	end
	return assistantNames
end)())

registerDataType('zoneType', (function()
	local zoneTypes = {}
	for _, zoneType in ipairs({"pve", "overland", "solo", "house", "my_house", "delve", "group_delve", "dungeon", "public_dungeon", "trial", "outlaw_refuge", "pvp", "battlegrounds", "cyrodiil", "imperial_city", "imperial_sewers", "campaign", "justice_enabled", "telvar_enabled", "cp_disabled"}) do
		zoneTypes[zoneType] = zoneType
	end
	return zoneTypes
end)())

registerDataType('groupRole', (function()
	local result = {}
	constantReader.addCallback('LFG_ROLE_(.*)', function(key, value, origKey)
		if(not utils.endsWith(key, '_VALUE') and not utils.endsWith(key, 'ITERATION_END') and not utils.endsWith(key, 'ITERATION_BEGIN')) then
			key = key:lower()
			result[key] = value
		end
	end)
	return result
end)())

registerDataType('stealthState', (function()
	local result = {}
	constantReader.addCallback('STEALTH_STATE_(.*)', function(key, value, origKey)
		if(not utils.endsWith(key, '_VALUE') and not utils.endsWith(key, 'ITERATION_END') and not utils.endsWith(key, 'ITERATION_BEGIN')) then
			key = key:lower()
			result[key] = value
		end
	end)
	return result
end)())

registerDataType('currencyTypes', (function()
	local result = {
		vouchers = CURT_WRIT_VOUCHERS,
		ap = CURT_ALLIANCE_POINTS,
		telvar = CURT_TELVAR_STONES,
	}
	constantReader.addCallback('CURT_(.*)', function(key, value, origKey)
		if(not utils.endsWith(key, '_VALUE') and not utils.endsWith(key, 'ITERATION_END') and not utils.endsWith(key, 'ITERATION_BEGIN')) then
			key = GetCurrencyName(value):lower():gsub("%s+", "_")
			if(key ~= "") then
				result[key] = value
			end
		end
	end)
	return result
end)())


registerDataType('charName', (function()
	local charNames = {}
	for i = 1, GetNumCharacters() do
		local charName = GetCharacterInfo(i)
		charName = zo_strformat("<<C:1>>", charName)
		charNames[charName:lower()] = charName
	end
	return charNames
end)())

-- Created with the _classes/DataDumper on english client
registerDataType('cSkill', {
	outofsight = 68,
	friendsinlowplaces = 76,
	fadeaway = 84,
	cutpursesart = 90,
	shadowstrike = 80,
	mastergatherer = 78,
	treasurehunter = 79,
	steadfastenchantment = 75,
	rationer = 85,
	liquidefficiency = 86,
	anglersinstincts = 89,
	reeltechnique = 88,
	homemaker = 91,
	wanderer = 70,
	plentifulharvest = 81,
	warmount = 82,
	giftedrider = 92,
	meticulousdisassembly = 83,
	inspirationboost = 72,
	fortunesfavor = 71,
	infamous = 77,
	fleetphantom = 67,
	gildedfingers = 74,
	breakfall = 69,
	soulreservoir = 87,
	steedsblessing = 66,
	sustainingshadows = 65,
	professionalupkeep = 1,
	precision = 11,
	fightingfinesse = 12,
	blessed = 108,
	fromthebrink = 262,
	enliveningoverflow = 263,
	hopeinfusion = 261,
	salveofrenewal = 260,
	soothingtide = 24,
	rejuvenator = 9,
	foresight = 163,
	cleansingrevival = 29,
	focusedmending = 26,
	swiftrenewal = 28,
	piercing = 10,
	masteratarms = 264,
	weaponsexpert = 259,
	flawlessritual = 17,
	warmage = 21,
	battlemastery = 18,
	mighty = 22,
	deadlyaim = 25,
	bitingaura = 23,
	thaumaturge = 27,
	reavingblows = 30,
	wrathfulstrikes = 8,
	occultoverload = 32,
	backstabber = 31,
	tirelessdiscipline = 6,
	quickrecovery = 20,
	resilience = 13,
	preparation = 14,
	elementalaegis = 15,
	hardy = 16,
	enduringresolve = 136,
	reinforced = 160,
	riposte = 162,
	bulwark = 159,
	laststand = 161,
	cuttingdefense = 33,
	duelistsrebuff = 134,
	unassailable = 133,
	eldritchinsight = 99,
	endlessendurance = 5,
	untamedaggression = 4,
	arcanesupremacy = 3,
	sprinter = 38,
	hasty = 42,
	herosvigor = 113,
	shieldmaster = 63,
	bastion = 46,
	temperedsoul = 58,
	survivalinstincts = 57,
	spiritmastery = 56,
	arcanealacrity = 61,
	piercinggaze = 45,
	bloodyrenewal = 48,
	strategicreserve = 49,
	mystictenacity = 53,
	siphoningspells = 47,
	rousingspeed = 62,
	tirelessguardian = 39,
	savagedefense = 40,
	bashingbrutality = 50,
	nimbleprotector = 44,
	onguard = 60,
	fortification = 43,
	tumbling = 37,
	expertevasion = 51,
	defiance = 128,
	slippery = 52,
	unchained = 64,
	juggernaut = 59,
	peaceofmind = 54,
	hardened = 55,
	rejuvenation = 35,
	ironclad = 34,
	boundlessvitality = 2,
})

-- itemLinkId => craftingType
itemCatalog.furnishingCraftingType= (function()
	local result = {}
	for list = 1, GetNumRecipeLists() do
		local _,num = GetRecipeListInfo(list)
		for id = 1, num do
			local known, name,_,_,_,_,tradeSkill = GetRecipeInfo(list, id)
			local itemLink = GetRecipeResultItemLink(list, id)
			local itemLinkId = GetItemLinkItemId(itemLink)
			result[itemLinkId] = tradeSkill
		end
	end
	return result
end)()

-- masterwritIcon => craftingType
itemCatalog.masterwritIcon2CraftingType = {
	["/esoui/art/icons/master_writ_blacksmithing.dds"] = CRAFTING_TYPE_BLACKSMITHING,   -- 1
	["/esoui/art/icons/master_writ_clothier.dds"     ] = CRAFTING_TYPE_CLOTHIER,        -- 2
	["/esoui/art/icons/master_writ_woodworking.dds"  ] = CRAFTING_TYPE_WOODWORKING,     -- 6
	["/esoui/art/icons/master_writ_jewelry.dds"      ] = CRAFTING_TYPE_JEWELRYCRAFTING, -- 7
	["/esoui/art/icons/master_writ_alchemy.dds"      ] = CRAFTING_TYPE_ALCHEMY,         -- 4
	["/esoui/art/icons/master_writ_enchanting.dds"   ] = CRAFTING_TYPE_ENCHANTING,      -- 3
	["/esoui/art/icons/master_writ_provisioning.dds" ] = CRAFTING_TYPE_PROVISIONING,    -- 5
	["/esoui/art/icons/master_writ-newlife.dds"] 	   = nil,
}

-- excerpt from AGS\data\ItemRequirementLevelRanges.lua, credit and many thanks to sirinsidiator!
local lvl = 0
local cp = GetMaxLevel()

-- change from AGS: second value is now last craftable level as represented in tooltip values
local RequirementSkillLevel1  = {  lvl+1, lvl+14 }
local RequirementSkillLevel2  = { lvl+16, lvl+24 }
local RequirementSkillLevel3  = { lvl+26, lvl+34 }
local RequirementSkillLevel4  = { lvl+36, lvl+44 }
local RequirementSkillLevel5  = { lvl+46, lvl+50 }
local RequirementSkillLevel6  = {  cp+10,  cp+30 }
local RequirementSkillLevel7  = {  cp+40,  cp+60 }
local RequirementSkillLevel8  = {  cp+70,  cp+80 }
local RequirementSkillLevel9  = {  cp+90, cp+140 }
local RequirementSkillLevel10 = { cp+150, cp+160 }

local JewelryCraftingRequirementSkillLevel1 = {  lvl+1, lvl+24 }
local JewelryCraftingRequirementSkillLevel2 = { lvl+26, lvl+50 }
local JewelryCraftingRequirementSkillLevel3 = {  cp+10,  cp+70 }
local JewelryCraftingRequirementSkillLevel4 = {  cp+80, cp+140 }
local JewelryCraftingRequirementSkillLevel5 = { cp+150, cp+160 }

local SolventRequirementSkillLevel1A = {  lvl+3,  lvl+3 }
local SolventRequirementSkillLevel1B = { lvl+10, lvl+10 }
local SolventRequirementSkillLevel2  = { lvl+20, lvl+20 }
local SolventRequirementSkillLevel3  = { lvl+30, lvl+30 }
local SolventRequirementSkillLevel4  = { lvl+40, lvl+40 }
local SolventRequirementSkillLevel5  = {  cp+10,  cp+10 }
local SolventRequirementSkillLevel6  = {  cp+50,  cp+50 }
local SolventRequirementSkillLevel7  = { cp+100, cp+100 }
local SolventRequirementSkillLevel8  = { cp+150, cp+150 }

local GlyphRequirementSkillLevel1A  = {  lvl+1,  lvl+4 }
local GlyphRequirementSkillLevel1B  = {  lvl+5,  lvl+9 }
local GlyphRequirementSkillLevel2A  = { lvl+10, lvl+14 }
local GlyphRequirementSkillLevel2B  = { lvl+15, lvl+19 }
local GlyphRequirementSkillLevel3A  = { lvl+20, lvl+24 }
local GlyphRequirementSkillLevel3B  = { lvl+25, lvl+29 }
local GlyphRequirementSkillLevel4A  = { lvl+30, lvl+34 }
local GlyphRequirementSkillLevel4B  = { lvl+35, lvl+39 }
local GlyphRequirementSkillLevel5A  = { lvl+40,   cp+9 }
local GlyphRequirementSkillLevel5B  = {  cp+10,  cp+29 }
local GlyphRequirementSkillLevel6   = {  cp+30,  cp+49 }
local GlyphRequirementSkillLevel7   = {  cp+50,  cp+69 }
local GlyphRequirementSkillLevel8   = {  cp+70,  cp+99 }
local GlyphRequirementSkillLevel9   = { cp+100, cp+149 }
local GlyphRequirementSkillLevel10A = { cp+150, cp+159 }
local GlyphRequirementSkillLevel10B = { cp+160, cp+160 }

-- itemLinkId => RequirementSkillLevel
itemCatalog.MaterialRequirementLevel = {
    -- Blacksmithing:
    [808] = RequirementSkillLevel1, -- Iron Ore
    [5413] = RequirementSkillLevel1, -- Iron Ingot
    [5820] = RequirementSkillLevel2, -- High Iron Ore
    [4487] = RequirementSkillLevel2, -- Steel Ingot
    [23103] = RequirementSkillLevel3, -- Orichalcum Ore
    [23107] = RequirementSkillLevel3, -- Orichalcum Ingot
    [23104] = RequirementSkillLevel4, -- Dwarven Ore
    [6000] = RequirementSkillLevel4, -- Dwarven Ingot
    [23105] = RequirementSkillLevel5, -- Ebony Ore
    [6001] = RequirementSkillLevel5, -- Ebony Ingot
    [4482] = RequirementSkillLevel6, -- Calcinium Ore
    [46127] = RequirementSkillLevel6, -- Calcinium Ingot
    [23133] = RequirementSkillLevel7, -- Galatite Ore
    [46128] = RequirementSkillLevel7, -- Galatite Ingot
    [23134] = RequirementSkillLevel8, -- Quicksilver Ore
    [46129] = RequirementSkillLevel8, -- Quicksilver Ingot
    [23135] = RequirementSkillLevel9, -- Voidstone Ore
    [46130] = RequirementSkillLevel9, -- Voidstone Ingot
    [71198] = RequirementSkillLevel10, -- Rubedite Ore
    [64489] = RequirementSkillLevel10, -- Rubedite Ingot

    -- Clothing:
    [812] = RequirementSkillLevel1, -- Raw Jute
    [793] = RequirementSkillLevel1, -- Rawhide Scraps
    [811] = RequirementSkillLevel1, -- Jute
    [794] = RequirementSkillLevel1, -- Rawhide
    [4464] = RequirementSkillLevel2, -- Raw Flax
    [4448] = RequirementSkillLevel2, -- Hide Scraps
    [4463] = RequirementSkillLevel2, -- Flax
    [4447] = RequirementSkillLevel2, -- Hide
    [23129] = RequirementSkillLevel3, -- Raw Cotton
    [23095] = RequirementSkillLevel3, -- Leather Scraps
    [23125] = RequirementSkillLevel3, -- Cotton
    [23099] = RequirementSkillLevel3, -- Leather
    [23130] = RequirementSkillLevel4, -- Raw Spidersilk
    [6020] = RequirementSkillLevel4, -- Thick Leather Scraps
    [23126] = RequirementSkillLevel4, -- Spidersilk
    [23100] = RequirementSkillLevel4, -- Thick Leather
    [23131] = RequirementSkillLevel5, -- Raw Ebonthread
    [23097] = RequirementSkillLevel5, -- Fell Hide Scraps
    [23127] = RequirementSkillLevel5, -- Ebonthread
    [23101] = RequirementSkillLevel5, -- Fell Hide
    [33217] = RequirementSkillLevel6, -- Raw Kreshweed
    [23142] = RequirementSkillLevel6, -- Topgrain Hide Scraps
    [46131] = RequirementSkillLevel6, -- Kresh Fiber
    [46135] = RequirementSkillLevel6, -- Topgrain Hide
    [33218] = RequirementSkillLevel7, -- Raw Ironweed
    [23143] = RequirementSkillLevel7, -- Iron Hide Scraps
    [46132] = RequirementSkillLevel7, -- Ironthread
    [46136] = RequirementSkillLevel7, -- Iron Hide
    [33219] = RequirementSkillLevel8, -- Raw Silverweed
    [800] = RequirementSkillLevel8, -- Superb Hide Scraps
    [46133] = RequirementSkillLevel8, -- Silverweave
    [46137] = RequirementSkillLevel8, -- Superb Hide
    [33220] = RequirementSkillLevel9, -- Raw Void Bloom
    [4478] = RequirementSkillLevel9, -- Shadowhide Scraps
    [46134] = RequirementSkillLevel9, -- Void Cloth
    [46138] = RequirementSkillLevel9, -- Shadowhide
    [71200] = RequirementSkillLevel10, -- Raw Ancestor Silk
    [71239] = RequirementSkillLevel10, -- Rubedo Hide Scraps
    [64504] = RequirementSkillLevel10, -- Ancestor Silk
    [64506] = RequirementSkillLevel10, -- Rubedo Leather

    -- Woodworking:
    [802] = RequirementSkillLevel1, -- Rough Maple
    [803] = RequirementSkillLevel1, -- Sanded Maple
    [521] = RequirementSkillLevel2, -- Rough Oak
    [533] = RequirementSkillLevel2, -- Sanded Oak
    [23117] = RequirementSkillLevel3, -- Rough Beech
    [23121] = RequirementSkillLevel3, -- Sanded Beech
    [23118] = RequirementSkillLevel4, -- Rough Hickory
    [23122] = RequirementSkillLevel4, -- Sanded Hickory
    [23119] = RequirementSkillLevel5, -- Rough Yew
    [23123] = RequirementSkillLevel5, -- Sanded Yew
    [818] = RequirementSkillLevel6, -- Rough Birch
    [46139] = RequirementSkillLevel6, -- Sanded Birch
    [4439] = RequirementSkillLevel7, -- Rough Ash
    [46140] = RequirementSkillLevel7, -- Sanded Ash
    [23137] = RequirementSkillLevel8, -- Rough Mahogany
    [46141] = RequirementSkillLevel8, -- Sanded Mahogany
    [23138] = RequirementSkillLevel9, -- Rough Nightwood
    [46142] = RequirementSkillLevel9, -- Sanded Nightwood
    [71199] = RequirementSkillLevel10, -- Rough Ruby Ash
    [64502] = RequirementSkillLevel10, -- Sanded Ruby Ash

    -- Jewelry Crafting:
    [135137] = JewelryCraftingRequirementSkillLevel1, -- Pewter Dust
    [135138] = JewelryCraftingRequirementSkillLevel1, -- Pewter Ounce
    [135139] = JewelryCraftingRequirementSkillLevel2, -- Copper Dust
    [135140] = JewelryCraftingRequirementSkillLevel2, -- Copper Ounce
    [135141] = JewelryCraftingRequirementSkillLevel3, -- Silver Dust
    [135142] = JewelryCraftingRequirementSkillLevel3, -- Silver Ounce
    [135143] = JewelryCraftingRequirementSkillLevel4, -- Electrum Dust
    [135144] = JewelryCraftingRequirementSkillLevel4, -- Electrum Ounce
    [135145] = JewelryCraftingRequirementSkillLevel5, -- Platinum Dust
    [135146] = JewelryCraftingRequirementSkillLevel5, -- Platinum Ounce

    -- Solvents:
    [883] = SolventRequirementSkillLevel1A, -- Natural Water
    [75357] = SolventRequirementSkillLevel1A, -- Grease
    [1187] = SolventRequirementSkillLevel1B, -- Clear Water
    [75358] = SolventRequirementSkillLevel1B, -- Ichor
    [4570] = SolventRequirementSkillLevel2, -- Pristine Water
    [75359] = SolventRequirementSkillLevel2, -- Slime
    [23265] = SolventRequirementSkillLevel3, -- Cleansed Water
    [75360] = SolventRequirementSkillLevel3, -- Gall
    [23266] = SolventRequirementSkillLevel4, -- Filtered Water
    [75361] = SolventRequirementSkillLevel4, -- Terebinthine
    [23267] = SolventRequirementSkillLevel5, -- Purified Water
    [75362] = SolventRequirementSkillLevel5, -- Pitch-Bile
    [23268] = SolventRequirementSkillLevel6, -- Cloud Mist
    [75363] = SolventRequirementSkillLevel6, -- Tarblack
    [64500] = SolventRequirementSkillLevel7, -- Star Dew
    [75364] = SolventRequirementSkillLevel7, -- Night-Oil
    [64501] = SolventRequirementSkillLevel8, -- Lorkhan's Tears
    [75365] = SolventRequirementSkillLevel8, -- Alkahest

    -- Potency Runes:
    [45817] = GlyphRequirementSkillLevel1A, -- Jode
    [45855] = GlyphRequirementSkillLevel1A, -- Jora
    [45818] = GlyphRequirementSkillLevel1B, -- Notade
    [45856] = GlyphRequirementSkillLevel1B, -- Porade
    [45819] = GlyphRequirementSkillLevel2A, -- Ode
    [45857] = GlyphRequirementSkillLevel2A, -- Jera
    [45820] = GlyphRequirementSkillLevel2B, -- Tade
    [45806] = GlyphRequirementSkillLevel2B, -- Jejora
    [45807] = GlyphRequirementSkillLevel3A, -- Odra
    [45821] = GlyphRequirementSkillLevel3A, -- Jayde
    [45808] = GlyphRequirementSkillLevel3B, -- Pojora
    [45822] = GlyphRequirementSkillLevel3B, -- Edode
    [45809] = GlyphRequirementSkillLevel4A, -- Edora
    [45823] = GlyphRequirementSkillLevel4A, -- Pojode
    [45810] = GlyphRequirementSkillLevel4B, -- Jaera
    [45824] = GlyphRequirementSkillLevel4B, -- Rekude
    [45811] = GlyphRequirementSkillLevel5A, -- Pora
    [45825] = GlyphRequirementSkillLevel5A, -- Hade
    [45812] = GlyphRequirementSkillLevel5B, -- Denara
    [45826] = GlyphRequirementSkillLevel5B, -- Idode
    [45813] = GlyphRequirementSkillLevel6, -- Rera
    [45827] = GlyphRequirementSkillLevel6, -- Pode
    [45814] = GlyphRequirementSkillLevel7, -- Derado
    [45828] = GlyphRequirementSkillLevel7, -- Kedeko
    [45815] = GlyphRequirementSkillLevel8, -- Rekura
    [45829] = GlyphRequirementSkillLevel8, -- Rede
    [45816] = GlyphRequirementSkillLevel9, -- Kura
    [45830] = GlyphRequirementSkillLevel9, -- Kude
    [64508] = GlyphRequirementSkillLevel10A, -- Jehade
    [64509] = GlyphRequirementSkillLevel10A, -- Rejera
    [68340] = GlyphRequirementSkillLevel10B, -- Itdate
    [68341] = GlyphRequirementSkillLevel10B, -- Repora
}
-- end of AGS excerpt

constantReader.read()

local dataType = {}
RbI.dataType = dataType
-- merge static data into RbI.dataType
for enumName, enum in pairs(dataTypeStatic) do
	local targetEnum = dataType[enumName]
	if(not targetEnum) then
		targetEnum = {}
		dataType[enumName] = targetEnum
	end
	for key, value in pairs(enum) do
		if(type(key) == 'string') then
			targetEnum[string.lower(key)] = value
		else -- can also be a number in an array (like charNames)
			targetEnum[key] = value
		end
	end
end