MrPlow = {}

local LibSort, minor = LibStub:GetLibrary("LibSort-1.0")

local watchedSlots = {[INVENTORY_GUILD_BANK] = true, [INVENTORY_BACKPACK] = true, [INVENTORY_BANK] = true }

local IS_WEAPON = { [EQUIP_TYPE_MAIN_HAND] = true, [EQUIP_TYPE_OFF_HAND] = true, [EQUIP_TYPE_ONE_HAND] = true, [EQUIP_TYPE_TWO_HAND] = true}

local WEAPON_ORDER = {
	[WEAPONTYPE_AXE] =  1,
	[WEAPONTYPE_DAGGER] =  2,
	[WEAPONTYPE_HAMMER] = 3,
	[WEAPONTYPE_SWORD] = 4,

	[WEAPONTYPE_TWO_HANDED_AXE] = 5,
	[WEAPONTYPE_TWO_HANDED_HAMMER] = 6, 
	[WEAPONTYPE_TWO_HANDED_SWORD] = 7,
	
	[WEAPONTYPE_BOW] = 8,
	
	[WEAPONTYPE_FIRE_STAFF] = 9,
	[WEAPONTYPE_FROST_STAFF] =  10,
	[WEAPONTYPE_LIGHTNING_STAFF] = 11,
	[WEAPONTYPE_HEALING_STAFF] = 12,

	[WEAPONTYPE_NONE] = 13,
	[WEAPONTYPE_RUNE] = 14,
	[WEAPONTYPE_SHIELD] = 15	
}

local ARMOUR_ORDER = {
	[EQUIP_TYPE_HEAD] 	= 1,
	[EQUIP_TYPE_SHOULDERS] 	= 2,
	[EQUIP_TYPE_CHEST] 	= 3,
	[EQUIP_TYPE_HAND] 	= 4,
	[EQUIP_TYPE_WAIST] 	= 5, 
	[EQUIP_TYPE_LEGS] 	= 6,
	[EQUIP_TYPE_FEET] 	= 7,
	
	[EQUIP_TYPE_NECK] 	= 8,
	[EQUIP_TYPE_RING] 	= 9,

	[EQUIP_TYPE_MAIN_HAND] 	= 10,
	[EQUIP_TYPE_OFF_HAND] 	= 11,
	[EQUIP_TYPE_ONE_HAND] 	= 12,
	[EQUIP_TYPE_TWO_HAND] 	= 13,
	[EQUIP_TYPE_COSTUME] 	= 14,	
}

local ITEM_TYPE_ORDER = {
	[ITEMTYPE_WEAPON] = 			1,
	[ITEMTYPE_ARMOR] = 			2,
	[ITEMTYPE_FOOD] = 			3,
	[ITEMTYPE_DRINK] = 			4, 
	[ITEMTYPE_RECIPE] =  			5,	
	[ITEMTYPE_POTION] =  			6,
	[ITEMTYPE_POISON] =   			7,
	[ITEMTYPE_CONTAINER] = 			8,
	[ITEMTYPE_AVA_REPAIR] =   		9,	
	[ITEMTYPE_ARMOR_BOOSTER] =		10,
	[ITEMTYPE_WEAPON_BOOSTER] = 		11,
	[ITEMTYPE_BLACKSMITHING_BOOSTER] = 	12,
	[ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = 13, 
	[ITEMTYPE_BLACKSMITHING_MATERIAL] = 	14, 
	[ITEMTYPE_CLOTHIER_BOOSTER] = 		15,
	[ITEMTYPE_CLOTHIER_RAW_MATERIAL] =	16, 
	[ITEMTYPE_CLOTHIER_MATERIAL] = 		17, 
	[ITEMTYPE_WOODWORKING_BOOSTER] =	18,
	[ITEMTYPE_WOODWORKING_RAW_MATERIAL] = 	19, 
	[ITEMTYPE_WOODWORKING_MATERIAL] = 	20, 
	[ITEMTYPE_POTION_BASE] = 		21,
	[ITEMTYPE_POISON_BASE] = 		22,
	[ITEMTYPE_REAGENT] = 			23, 
	[ITEMTYPE_ENCHANTMENT_BOOSTER] =	24,
	[ITEMTYPE_INGREDIENT] =   		25,	
	[ITEMTYPE_FLAVORING] =			26,
	[ITEMTYPE_SPICE] =			27,
	[ITEMTYPE_ADDITIVE] =			28,
	[ITEMTYPE_RAW_MATERIAL] =		29,
	[ITEMTYPE_SPELLCRAFTING_TABLET] = 	30,
	[ITEMTYPE_STYLE_MATERIAL] =   		31,
	[ITEMTYPE_GLYPH_WEAPON] =   		32,
	[ITEMTYPE_GLYPH_ARMOR] =   		33,
	[ITEMTYPE_GLYPH_JEWELRY] =   		34,
	[ITEMTYPE_RACIAL_STYLE_MOTIF] =		35,
	[ITEMTYPE_SOUL_GEM] =   		36,
	[ITEMTYPE_SIEGE] =   			37,
	[ITEMTYPE_MOUNT] =			38,
	[ITEMTYPE_LURE] = 			39,
	[ITEMTYPE_TRASH] = 	  		40,
	[ITEMTYPE_COSTUME] =			41,
	[ITEMTYPE_DISGUISE] =			42,
	[ITEMTYPE_TABARD] =			43,
	[ITEMTYPE_COLLECTIBLE] = 		44,
	[ITEMTYPE_TROPHY] =   			45,
	[ITEMTYPE_LOCKPICK] =			46,
	[ITEMTYPE_TOOL] =			47,
	[ITEMTYPE_ARMOR_TRAIT] =   		48,
	[ITEMTYPE_WEAPON_TRAIT] =   		49,
	[ITEMTYPE_PLUG] =			50,
	[ITEMTYPE_NONE] =			51,
	[ITEMTYPE_DEPRECATED] =			52,
}

local ENCHANTING_RUNE_ORDER = {
	[ENCHANTING_RUNE_POTENCY]	= 1,
	[ENCHANTING_RUNE_ESSENCE]	= 2,
	[ENCHANTING_RUNE_ASPECT] 	= 3,
	[ENCHANTING_RUNE_NONE]		= 4,
}

function MrPlow:Loaded(...)
   local eventCode, addonName = ...
   if addonName ~= "MrPlow" then return end

   LibSort:Register("Item Sort", "Item Type", "The type of item", "itemType", function(...) return MrPlow:ItemType(...) end)
   LibSort:Register("Item Sort", "Weapon Type", "The type of weapon", "weaponType", function(...) return MrPlow:WeaponType(...) end)
   LibSort:Register("Item Sort", "Armour Equip Type", "The type of armour", "armorEquipType", function(...) return MrPlow:ArmourEquipType(...) end)
   LibSort:Register("Item Sort", "Armour Type", "The weight of armour", "armorType", function(...) return MrPlow:ArmorType(...) end)
   LibSort:Register("Item Sort", "Crafting Type", "The crafting type of an item", "craftingType", function(...) return MrPlow:CraftingType(...) end)

   LibSort:Register("Item Sort", "Subjective Level", "The calculated subjective level", "subjectiveLevel", function(bag, index) return GetItemLevel(bag, index) end)

   LibSort:RegisterDefaultOrder("Item Sort", {"Item Type", "Weapon Type", "Armour Equip Type", "Armour Type", "Crafting Type"}, {"Subjective Level"}) 
end

function MrPlow:SubjectiveLevel(bag, index)
	return GetItemLevel(bag, index) 
end

function MrPlow:ItemType(bag, index)
      	return ITEM_TYPE_ORDER[GetItemType(bag, index)] or 100
end

function MrPlow:WeaponType(bag, index)
        return WEAPON_ORDER[GetItemLinkWeaponType(GetItemLink(bag, index))]
end

function MrPlow:ArmorType(bag, index)
	return GetItemLinkArmorType(GetItemLink(bag, index))
end

function MrPlow:ArmourEquipType(bag, index)
	return ARMOUR_ORDER[GetItemLinkEquipType(GetItemLink(bag, index))] 
end

function MrPlow:CraftingType(bag, index)
	local _, _, extra1 = GetItemCraftingInfo(bag, index)
	return ENCHANTING_RUNE_ORDER[extra1 or 4]
end

EVENT_MANAGER:RegisterForEvent("MrPlowLoaded", EVENT_ADD_ON_LOADED, function(...) MrPlow:Loaded(...) end)
