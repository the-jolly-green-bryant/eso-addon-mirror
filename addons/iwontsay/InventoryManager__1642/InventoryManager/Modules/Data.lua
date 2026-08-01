
if not InventoryManager then InventoryManager = {} end
local IM = InventoryManager

local function generateFiltertypes()
	local _new = { }
	for _, f in pairs(IM.filterorder) do
		local _innernew = { }
		for _, ff in pairs(f[2]) do
			_innernew[ff[1]] = ff[2]
		end
		_new[f[1]] = _innernew
	end
	return _new
end

if not IM.IM_Ruleset then IM.IM_Ruleset = ZO_Object:Subclass() end

local IM_Ruleset = IM.IM_Ruleset

function IM:getIQString(itemQuality)
	return GetItemQualityColor(itemQuality):Colorize(GetString("SI_ITEMQUALITY", itemQuality))
end
 
IM.ACTION_KEEP		=  0
IM.ACTION_JUNK		=  1
IM.ACTION_DESTROY 	=  2
IM.ACTION_SELL		=  3
IM.ACTION_LAUNDER		=  4
IM.ACTION_DECONSTRUCT	=  5
IM.ACTION_LOCK		=  6
IM.ACTION_UNLOCK		=  7
IM.ACTION_STASH		=  10
IM.ACTION_GB_STASH	=  11
IM.ACTION_RETRIEVE	=  20
IM.ACTION_GB_RETRIEVE	=  21

IM_Ruleset.ITEM_TRAIT_TYPE_ANY				= -1
IM_Ruleset.ITEM_TRAIT_TYPE_ANYUNKOTHERS		= -2
IM_Ruleset.ITEM_TRAIT_TYPE_ANYUNKNOWN		= -3
IM_Ruleset.ITEM_TRAIT_TYPE_NOTRAIT			= -4

 
IM.filterorder = {
		{ "IM_FILTER_ANY" 			, {
			{ "IM_FILTERSPEC_ANY"			, { } },
		} },
		{ "IM_FILTER_WEAPON" 		, { 
			{ "IM_FILTERSPEC_ANY"			, { "itemType", ITEMTYPE_WEAPON } },
			{ "IM_FILTERSPEC_1H"			, { "weaponType", WEAPONTYPE_AXE, WEAPONTYPE_HAMMER, WEAPONTYPE_SWORD, WEAPONTYPE_DAGGER } },
			{ "IM_FILTERSPEC_2H"			, { "weaponType", WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_TWO_HANDED_SWORD } },
			{ "IM_FILTERSPEC_BOW"			, { "weaponType", WEAPONTYPE_BOW } },
			{ "IM_FILTERSPEC_STAFF_DEST"	, { "weaponType", WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF } },
			{ "IM_FILTERSPEC_STAFF_HEAL"	, { "weaponType", WEAPONTYPE_HEALING_STAFF } }
		} }, 
		{ "IM_FILTER_APPAREL"		, { 
			{ "IM_FILTERSPEC_ANY"			, { "itemType", ITEMTYPE_ARMOR } },
			{ "IM_FILTERSPEC_ANY_BODY"		, { "armorType", ARMORTYPE_HEAVY, ARMORTYPE_MEDIUM, ARMORTYPE_LIGHT } },
			{ "IM_FILTERSPEC_HEAVY" 		, { "armorType", ARMORTYPE_HEAVY } },
			{ "IM_FILTERSPEC_MEDIUM"		, { "armorType", ARMORTYPE_MEDIUM } },
			{ "IM_FILTERSPEC_LIGHT"			, { "armorType", ARMORTYPE_LIGHT } },
			{ "IM_FILTERSPEC_SHIELD"		, { "equipType", EQUIP_TYPE_OFF_HAND } },
			{ "IM_FILTERSPEC_JEWELRY"		, { "equipType", EQUIP_TYPE_RING, EQUIP_TYPE_NECK } },
			{ "IM_FILTERSPEC_VANITY"		, { "equipType", EQUIP_TYPE_COSTUME  } }
		} },
		{ "IM_FILTER_CONSUMABLE"	, { 
			{ "IM_FILTERSPEC_ANY"			, { "itemType", ITEMTYPE_CROWN_ITEM, ITEMTYPE_FOOD, ITEMTYPE_DRINK, ITEMTYPE_RECIPE, ITEMTYPE_POTION, ITEMTYPE_POISON, ITEMTYPE_RACIAL_STYLE_MOTIF, ITEMTYPE_MASTER_WRIT, ITEMTYPE_CONTAINER, ITEMTYPE_AVA_REPAIR, ITEMTYPE_TOOL, ITEMTYPE_CROWN_REPAIR, ITEMTYPE_FISH, ITEMTYPE_TROPHY, ITEMTYPE_DYE_STAMP } },
			{ "IM_FILTERSPEC_CROWN_ITEM"	, { "itemType", ITEMTYPE_CROWN_ITEM } },
			{ "IM_FILTERSPEC_FOOD"			, { "itemType", ITEMTYPE_FOOD } },
			{ "IM_FILTERSPEC_DRINK"			, { "itemType", ITEMTYPE_DRINK } },
			{ "IM_FILTERSPEC_RECIPE"		, { "itemType", ITEMTYPE_RECIPE } },
			{ "IM_FILTERSPEC_POTION"		, { "itemType", ITEMTYPE_POTION } },
			{ "IM_FILTERSPEC_POISON"		, { "itemType", ITEMTYPE_POISON } },
			{ "IM_FILTERSPEC_MOTIF"			, { "itemType", ITEMTYPE_RACIAL_STYLE_MOTIF } },
			{ "IM_FILTERSPEC_MASTER_WRIT"	, { "itemType", ITEMTYPE_MASTER_WRIT } },
			{ "IM_FILTERSPEC_CONTAINER"		, { "itemType", ITEMTYPE_CONTAINER } },
			{ "IM_FILTERSPEC_REPAIR"		, { "itemType", ITEMTYPE_AVA_REPAIR, ITEMTYPE_TOOL, ITEMTYPE_CROWN_REPAIR } },
			{ "IM_FILTERSPEC_FISH"			, { "itemType", ITEMTYPE_FISH } },
			{ "IM_FILTERSPEC_TROPHY"		, { "itemType", ITEMTYPE_TROPHY } },
			{ "IM_FILTERSPEC_DYE_STAMP"		, { "itemType", ITEMTYPE_DYE_STAMP } }
		} },
		{ "IM_FILTER_MATERIAL"		, { 
			{ "IM_FILTERSPEC_ANY"			, { "itemType", ITEMTYPE_BLACKSMITHING_MATERIAL, ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, ITEMTYPE_BLACKSMITHING_BOOSTER, ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_CLOTHIER_RAW_MATERIAL, ITEMTYPE_CLOTHIER_BOOSTER, ITEMTYPE_WOODWORKING_MATERIAL, ITEMTYPE_WOODWORKING_RAW_MATERIAL, ITEMTYPE_WOODWORKING_BOOSTER, ITEMTYPE_REAGENT, ITEMTYPE_POTION_BASE, ITEMTYPE_POISON_BASE, ITEMTYPE_ENCHANTING_RUNE_ASPECT, ITEMTYPE_ENCHANTING_RUNE_ESSENCE, ITEMTYPE_ENCHANTING_RUNE_POTENCY, ITEMTYPE_INGREDIENT, ITEMTYPE_JEWELRYCRAFTING_MATERIAL, ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL, ITEMTYPE_JEWELRYCRAFTING_BOOSTER, ITEMTYPE_STYLE_MATERIAL, ITEMTYPE_RAW_MATERIAL, ITEMTYPE_WEAPON_TRAIT, ITEMTYPE_ARMOR_TRAIT } },
			{ "IM_FILTERSPEC_BLACKSMITHING"	, { "itemType", ITEMTYPE_BLACKSMITHING_MATERIAL, ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, ITEMTYPE_BLACKSMITHING_BOOSTER } },
			{ "IM_FILTERSPEC_CLOTHIER"		, { "itemType", ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_CLOTHIER_RAW_MATERIAL, ITEMTYPE_CLOTHIER_BOOSTER } },
			{ "IM_FILTERSPEC_WOODWORKING"	, { "itemType", ITEMTYPE_WOODWORKING_MATERIAL, ITEMTYPE_WOODWORKING_RAW_MATERIAL, ITEMTYPE_WOODWORKING_BOOSTER } },
			{ "IM_FILTERSPEC_ALCHEMY"		, { "itemType", ITEMTYPE_REAGENT, ITEMTYPE_POTION_BASE, ITEMTYPE_POISON_BASE } },
			{ "IM_FILTERSPEC_ENCHANTING"	, { "itemType", ITEMTYPE_ENCHANTING_RUNE_ASPECT, ITEMTYPE_ENCHANTING_RUNE_ESSENCE, ITEMTYPE_ENCHANTING_RUNE_POTENCY } },
			{ "IM_FILTERSPEC_PROVISIONING"	, { "itemType", ITEMTYPE_INGREDIENT } },
			{ "IM_FILTERSPEC_JEWELCRAFTING"	, { "itemType", ITEMTYPE_JEWELRYCRAFTING_MATERIAL, ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL, ITEMTYPE_JEWELRYCRAFTING_BOOSTER } },
			{ "IM_FILTERSPEC_STYLE_MATERIAL", { "itemType", ITEMTYPE_STYLE_MATERIAL, ITEMTYPE_RAW_MATERIAL } },
			{ "IM_FILTERSPEC_ARMOR_TRAIT"	, { "itemType", ITEMTYPE_WEAPON_TRAIT } },
			{ "IM_FILTERSPEC_WEAPON_TRAIT"	, { "itemType", ITEMTYPE_ARMOR_TRAIT } },
		} },
		{ "IM_FILTER_FURNISHING"	, { 
			{ "IM_FILTERSPEC_ANY"			, { "itemType", ITEMTYPE_FURNISHING, ITEMTYPE_FURNISHING_MATERIAL } },
		} },
		{ "IM_FILTER_MISC"			, { 
			{ "IM_FILTERSPEC_ANY"			, { "itemType", ITEMTYPE_GLYPH_ARMOR, ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_WEAPON, ITEMTYPE_SOUL_GEM, ITEMTYPE_SIEGE, ITEMTYPE_LURE, ITEMTYPE_TOOL, ITEMTYPE_TRASH, ITEMTYPE_COLLECTIBLE, ITEMTYPE_TREASURE } },
			{ "IM_FILTERSPEC_GLYPH"			, { "itemType", ITEMTYPE_GLYPH_ARMOR, ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_WEAPON } },
			{ "IM_FILTERSPEC_SOUL_GEM"		, { "itemType", ITEMTYPE_SOUL_GEM } },
			{ "IM_FILTERSPEC_SIEGE"			, { "itemType", ITEMTYPE_SIEGE } },
			{ "IM_FILTERSPEC_BAIT"			, { "itemType", ITEMTYPE_LURE } },
			{ "IM_FILTERSPEC_TOOL"			, { "itemType", ITEMTYPE_TOOL } },
			{ "IM_FILTERSPEC_TRASH"			, { "itemType", ITEMTYPE_TRASH } },
			{ "IM_FILTERSPEC_TREASURE"		, { "itemType", ITEMTYPE_COLLECTIBLE, ITEMTYPE_TREASURE } },
		} },
}

IM.filtertypes = generateFiltertypes()

IM.qualityorder = {
	{ IM:getIQString(ITEM_QUALITY_TRASH), 		ITEM_QUALITY_TRASH },
	{ IM:getIQString(ITEM_QUALITY_NORMAL), 	ITEM_QUALITY_NORMAL },
	{ IM:getIQString(ITEM_QUALITY_MAGIC), 		ITEM_QUALITY_MAGIC },
	{ IM:getIQString(ITEM_QUALITY_ARCANE), 	ITEM_QUALITY_ARCANE },
	{ IM:getIQString(ITEM_QUALITY_ARTIFACT), 	ITEM_QUALITY_ARTIFACT },
	{ IM:getIQString(ITEM_QUALITY_LEGENDARY), 	ITEM_QUALITY_LEGENDARY }
}

IM.actionorder = {
	{ IM.ACTION_JUNK },
	{ IM.ACTION_DESTROY },
	{ IM.ACTION_STASH },
	{ IM.ACTION_RETRIEVE },
	{ IM.ACTION_GB_STASH },
	{ IM.ACTION_GB_RETRIEVE },
	{ IM.ACTION_SELL },
	{ IM.ACTION_LAUNDER },
	{ IM.ACTION_DECONSTRUCT },
}

IM.xreforder = {
	{ IM.ACTION_KEEP },
	{ IM.ACTION_JUNK },
	{ IM.ACTION_DESTROY },
	{ IM.ACTION_STASH },
	{ IM.ACTION_RETRIEVE },
	{ IM.ACTION_GB_STASH },
	{ IM.ACTION_GB_RETRIEVE },
	{ IM.ACTION_SELL },
	{ IM.ACTION_LAUNDER },
	{ IM.ACTION_DECONSTRUCT },
}
  
IM.actionfunctions = {
  [IM.ACTION_KEEP]		    =  function(data) end,  -- Do nothing
  [IM.ACTION_JUNK]		    =  function(data) SetItemIsJunk(data.bagId, data.slotId, true) end,
  [IM.ACTION_DESTROY] 	  =  function(data) DestroyItem(data.bagId, data.slotId) end,
  [IM.ACTION_SELL]		    =  function(data) SellInventoryItem(data.bagId, data.slotId, data.count) end,
  [IM.ACTION_LAUNDER]		  =  function(data) LaunderItem(data.bagId, data.slotId, data.count) end,
  [IM.ACTION_GB_STASH]	  =  function(data) TransferToGuildBank(data.bagId, data.slotId) end,
  [IM.ACTION_GB_RETRIEVE]	=  function(data) TransferFromGuildBank(data.slotId) end,
  [IM.ACTION_DECONSTRUCT]	=  function(data) end,  -- Added in Extractor.lua
  [IM.ACTION_STASH]		    =  function(data) end,  -- Bank moves are handled differently
  [IM.ACTION_RETRIEVE]	  =  function(data) end,
  [IM.ACTION_LOCK]		    =  nil,                 -- RFU
  [IM.ACTION_UNLOCK]		  =  nil,
}

IM.traitsorder = {
	["IM_FILTER_ANY"] = {
		0, -- Redefined to "don't care about traits"
		IM_Ruleset.ITEM_TRAIT_TYPE_NOTRAIT,
		IM_Ruleset.ITEM_TRAIT_TYPE_ANY,
		IM_Ruleset.ITEM_TRAIT_TYPE_ANYUNKOTHERS, 
		IM_Ruleset.ITEM_TRAIT_TYPE_ANYUNKNOWN,
		ITEM_TRAIT_TYPE_WEAPON_INTRICATE,
		ITEM_TRAIT_TYPE_WEAPON_ORNATE,
	},
	["IM_FILTER_WEAPON"] = {
		0, -- Redefined to "don't care about traits"
		IM_Ruleset.ITEM_TRAIT_TYPE_NOTRAIT,
		IM_Ruleset.ITEM_TRAIT_TYPE_ANY, 
		IM_Ruleset.ITEM_TRAIT_TYPE_ANYUNKOTHERS, 
		IM_Ruleset.ITEM_TRAIT_TYPE_ANYUNKNOWN,
		ITEM_TRAIT_TYPE_WEAPON_CHARGED,
		ITEM_TRAIT_TYPE_WEAPON_DECISIVE,
		ITEM_TRAIT_TYPE_WEAPON_DEFENDING,
		ITEM_TRAIT_TYPE_WEAPON_INFUSED,
		ITEM_TRAIT_TYPE_WEAPON_POWERED,
		ITEM_TRAIT_TYPE_WEAPON_PRECISE,
		ITEM_TRAIT_TYPE_WEAPON_SHARPENED,
		ITEM_TRAIT_TYPE_WEAPON_TRAINING,
		ITEM_TRAIT_TYPE_WEAPON_NIRNHONED,
		ITEM_TRAIT_TYPE_WEAPON_INTRICATE,
		ITEM_TRAIT_TYPE_WEAPON_ORNATE,
 	},
	["IM_FILTER_APPAREL"] = { 
		0, -- Redefined to "don't care about traits"
		IM_Ruleset.ITEM_TRAIT_TYPE_NOTRAIT,
		IM_Ruleset.ITEM_TRAIT_TYPE_ANY, 
		IM_Ruleset.ITEM_TRAIT_TYPE_ANYUNKOTHERS, 
		IM_Ruleset.ITEM_TRAIT_TYPE_ANYUNKNOWN,
		ITEM_TRAIT_TYPE_ARMOR_DIVINES,
		ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE,
		ITEM_TRAIT_TYPE_ARMOR_INFUSED,
		ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS,
		ITEM_TRAIT_TYPE_ARMOR_REINFORCED,
		ITEM_TRAIT_TYPE_ARMOR_STURDY,
		ITEM_TRAIT_TYPE_ARMOR_TRAINING,
		ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED,
		ITEM_TRAIT_TYPE_WEAPON_NIRNHONED,
		ITEM_TRAIT_TYPE_WEAPON_INTRICATE,
		ITEM_TRAIT_TYPE_WEAPON_ORNATE,
	},
	["IM_FILTERSPEC_JEWELRY"] = { 
		0, -- Redefined to "don't care about traits"
		IM_Ruleset.ITEM_TRAIT_TYPE_NOTRAIT,
		IM_Ruleset.ITEM_TRAIT_TYPE_ANY, 
		IM_Ruleset.ITEM_TRAIT_TYPE_ANYUNKOTHERS, 
		IM_Ruleset.ITEM_TRAIT_TYPE_ANYUNKNOWN,
		ITEM_TRAIT_TYPE_JEWELRY_ARCANE,
		ITEM_TRAIT_TYPE_JEWELRY_HEALTHY,
		ITEM_TRAIT_TYPE_JEWELRY_ROBUST,
		ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY,
		ITEM_TRAIT_TYPE_JEWELRY_HARMONY,
		ITEM_TRAIT_TYPE_JEWELRY_INFUSED,
		ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE,
		ITEM_TRAIT_TYPE_JEWELRY_SWIFT,
		ITEM_TRAIT_TYPE_JEWELRY_TRIUNE,
		ITEM_TRAIT_TYPE_WEAPON_INTRICATE,
		ITEM_TRAIT_TYPE_WEAPON_ORNATE,
 	},
	["IM_FILTERSPEC_RECIPE"] = {
		0, -- Redefined to "don't care about traits"
		IM_Ruleset.ITEM_TRAIT_TYPE_ANYUNKOTHERS, 
		IM_Ruleset.ITEM_TRAIT_TYPE_ANYUNKNOWN,
	},
	["IM_FILTERSPEC_MOTIF"] = {
		0, -- Redefined to "don't care about traits"
		IM_Ruleset.ITEM_TRAIT_TYPE_ANYUNKOTHERS, 
		IM_Ruleset.ITEM_TRAIT_TYPE_ANYUNKNOWN,
	},
}

IM.presetProfiles = {
	[1] = 
	{
		["rules"] = 
		{
			[1] = 
			{
				["minQuality"] = 0,
				["filterType"] = "IM_FILTER_ANY",
				["filterSubType"] = "IM_FILTERSPEC_ANY",
				["action"] = 10,
				["traitType"] = -2,
				["maxQuality"] = 5,
			},
			[2] = 
			{
				["minQuality"] = 0,
				["filterType"] = "IM_FILTER_ANY",
				["filterSubType"] = "IM_FILTERSPEC_ANY",
				["action"] = 10,
				["traitType"] = 9,
				["maxQuality"] = 5,
			},
			[3] = 
			{
				["minQuality"] = 0,
				["filterType"] = "IM_FILTER_ANY",
				["filterSubType"] = "IM_FILTERSPEC_ANY",
				["action"] = 1,
				["traitType"] = 10,
				["maxQuality"] = 5,
			},
			[4] = 
			{
				["minQuality"] = 0,
				["filterType"] = "IM_FILTER_ANY",
				["filterSubType"] = "IM_FILTERSPEC_ANY",
				["action"] = 20,
				["traitType"] = -3,
				["maxQuality"] = 5,
			},
			[5] = 
			{
				["minQuality"] = 0,
				["action"] = 1,
				["maxQuality"] = 5,
				["filterSubType"] = "IM_FILTERSPEC_TRASH",
				["filterType"] = "IM_FILTER_MISC",
			},
		},
		["name"] = "Research Assistant",
	},
	[2] = 
	{
		["rules"] = 
		{
			[1] = 
			{
				["minQuality"] = 0,
				["filterType"] = "IM_FILTER_ANY",
				["filterSubType"] = "IM_FILTERSPEC_ANY",
				["action"] = 20,
				["traitType"] = -3,
				["maxQuality"] = 5,
			},
			[2] = 
			{
				["minQuality"] = 0,
				["filterType"] = "IM_FILTER_ANY",
				["filterSubType"] = "IM_FILTERSPEC_ANY",
				["action"] = 10,
				["traitType"] = -2,
				["maxQuality"] = 5,
			},
			[3] = 
			{
				["minQuality"] = 0,
				["filterType"] = "IM_FILTER_ANY",
				["filterSubType"] = "IM_FILTERSPEC_ANY",
				["action"] = 20,
				["traitType"] = 9,
				["maxQuality"] = 5,
			},
			[4] = 
			{
				["minQuality"] = 0,
				["filterType"] = "IM_FILTER_ANY",
				["filterSubType"] = "IM_FILTERSPEC_ANY",
				["action"] = 1,
				["traitType"] = 10,
				["maxQuality"] = 5,
			},
			[5] = 
			{
				["minQuality"] = 0,
				["action"] = 1,
				["maxQuality"] = 5,
				["filterSubType"] = "IM_FILTERSPEC_TRASH",
				["filterType"] = "IM_FILTER_MISC",
			},
		},
		["name"] = "Researcher",
	},
}
