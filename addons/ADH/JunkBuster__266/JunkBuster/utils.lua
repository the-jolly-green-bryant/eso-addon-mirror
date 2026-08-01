jb = jb or {}
jb.utils = {}
local utils = jb.utils

function utils.getItemData(bagId, slotId)
    local id = GetItemInstanceId(bagId, slotId)
    local name = GetItemName(bagId, slotId)
    local link = GetItemLink(bagId, slotId, LINK_STYLE_BRACKETS)
    local level = GetItemLevel(bagId, slotId)
	local reqLevel = GetItemRequiredLevel(bagId, slotId)
	local reqCP = GetItemRequiredChampionPoints(bagId, slotId)
    local itemType,specType = GetItemType(bagId, slotId)
    local trait = GetItemTrait(bagId, slotId)
    local icon,stack,price,meetsReqs,locked,equipType,itemStyle,quality,funcQuality = GetItemInfo(bagId, slotId)
    local craft,craftType = GetItemCraftingInfo(bagId, slotId)
	local weaponType = GetItemWeaponType(bagId, slotId)
	local armorType = GetItemArmorType(bagId, slotId)
	local isCrafted = IsItemLinkCrafted(link)
	local isStolen = IsItemLinkStolen(link)
	local hasSet = GetItemLinkSetInfo(link)
	local actorType = GetItemActorCategory(bagId, slotId)
	local isKnown = IsItemLinkRecipeKnown(link)
	
	-- Formats the link correctly for display in the chat window (Uppercase first letter in words and removes the ^ control characters at the end)
	link = string.gsub(link, name, zo_strformat("<<tx:1>>", name))
	
    return {id = id, name = name, link = link, level = level, quality = quality, 
			itemType = itemType, specType = specType, price = price, craft = craft, craftType = craftType, 
			trait = trait, icon = icon, stack = stack, meetsRequirements = meetsReqs, 
			locked = locked, equipType = equipType, itemStyle = itemStyle, 
			isCrafted = isCrafted, isStolen = isStolen, hasSet = hasSet, reqLevel = reqLevel, 
			reqCP = reqCP, weaponType = weaponType, armorType = armorType, actorType = actorType, isKnown = isKnown}
end

function utils.numToStr(value)
    if value == nil or value == "" or value < 0 then
        return ""
    else
        return tostring(value)
    end
end

function utils.strToNum(value)
    if value == nil or value == "" then return -1 end
    local num = tonumber(value)
    local num2 = tonumber(value .. "0")
    if num == nil or num2 == nil or num2 ~= num * 10 then return -1 end
    return num
end

function utils.findKey(table, value)
    for k,v in pairs(table) do
        if v == value then return k end
    end
    return -1
end

function jb.printItemInfo(link)
	local itemType,specType = GetItemLinkItemType(link)
	local weaponType = GetItemLinkWeaponType(link)
	local armorType = GetItemLinkArmorType(link)
	local equipType = GetItemLinkEquipType(link)
	local actorType = GetItemLinkActorCategory(link)
	local isKnown = IsItemLinkRecipeKnown(link)
	local reqLevel = GetItemLinkRequiredLevel(link)
	local reqCP = GetItemLinkRequiredChampionPoints(link)
	d(jb.chatTag .. link .. ": ItemT = " .. utils.typeNames[itemType] .. ", SpecT = " .. utils.specTypeNames.all[specType] .. 
		"; WeapT = " .. utils.weaponTypeNames[weaponType] .. "; ArmT = " .. utils.armorTypeNames[armorType] ..
		"; EquipT = " .. utils.equipTypeNames[equipType] .. "; ActT = " .. utils.actorTypeNames[actorType] .. 
		"; isKnown = " .. utils.boolStr[isKnown] .. "; Level/CP = " .. reqLevel .. "/" .. reqCP)
end

function utils.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[utils.deepcopy(orig_key)] = utils.deepcopy(orig_value)
        end
        setmetatable(copy, utils.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function utils.mergeTab(target, source)
	if type(target) == 'table' and type(source) == 'table' then
		for k,v in pairs(source) do 
			target[k] = v 
		end
	end
end

function utils.esc(x)
	return (x:gsub('%%', '%%%%')
			 :gsub('^%^', '%%^')
			 :gsub('%$$', '%%$')
			 :gsub('%(', '%%(')
			 :gsub('%)', '%%)')
			 :gsub('%.', '%%.')
			 :gsub('%[', '%%[')
			 :gsub('%]', '%%]')
			 :gsub('%*', '%%*')
			 :gsub('%+', '%%+')
			 :gsub('%-', '%%-')
			 :gsub('%?', '%%?'))
end

JB_FILTER_HAS_SET = 1
JB_FILTER_HAS_NO_SET = 2
JB_FILTER_IS_STOLEN = 1
JB_FILTER_IS_NOT_STOLEN = 2
JB_FILTER_COULD_BE_CRAFTED = 1
JB_FILTER_IS_CRAFTED = 2
JB_FILTER_REC_IS_KNOWN = 1
JB_FILTER_REC_IS_NOT_KNOWN = 2

JB_RTYPE_SAVE = 1
JB_RTYPE_DESTROY = 2
JB_RTYPE_JUNK = 3

utils.boolStr = {
	[false] = "No",
	[true]  = "Yes",
}

utils.armorTypeNames = {
	[-1] = "",
	[ARMORTYPE_HEAVY]  = "Heavy Armor",
	[ARMORTYPE_LIGHT]  = "Light Armor",
	[ARMORTYPE_MEDIUM] = "Medium Armor",
	[ARMORTYPE_NONE]   = "Clothing",
}

utils.weaponTypeNames = {
	[-1] = "",
	[WEAPONTYPE_AXE]               = "Axe",
	[WEAPONTYPE_BOW]               = "Bow",
	[WEAPONTYPE_DAGGER]            = "Dagger",
	[WEAPONTYPE_FIRE_STAFF]        = "Inferno Staff",
	[WEAPONTYPE_FROST_STAFF]       = "Ice Staff",
	[WEAPONTYPE_HAMMER]            = "Mace",
	[WEAPONTYPE_HEALING_STAFF]     = "Restoration Staff",
	[WEAPONTYPE_LIGHTNING_STAFF]   = "Lightning Staff",
	[WEAPONTYPE_NONE]              = "None",--HIDDEN
	[WEAPONTYPE_RUNE]              = "Rune",--HIDDEN
	[WEAPONTYPE_SHIELD]            = "Shield",
	[WEAPONTYPE_SWORD]             = "Sword",
	[WEAPONTYPE_TWO_HANDED_AXE]    = "Battle Axe",
	[WEAPONTYPE_TWO_HANDED_HAMMER] = "Maul",
	[WEAPONTYPE_TWO_HANDED_SWORD]  = "Greatsword",
}

utils.equipTypeNames = {
	[-1] = "",
	[EQUIP_TYPE_HEAD]      = "Head",
	[EQUIP_TYPE_SHOULDERS] = "Shoulder",
	[EQUIP_TYPE_CHEST]     = "Chest",
	[EQUIP_TYPE_HAND]      = "Hand",
	[EQUIP_TYPE_WAIST]     = "Waist",
	[EQUIP_TYPE_LEGS]      = "Legs",
	[EQUIP_TYPE_FEET]      = "Feet",
	[EQUIP_TYPE_NECK]      = "Neck",
	[EQUIP_TYPE_RING]      = "Ring",
	[EQUIP_TYPE_ONE_HAND]  = "One Handed",
	[EQUIP_TYPE_TWO_HAND]  = "Two Handed",
	[EQUIP_TYPE_MAIN_HAND] = "Main Hand",--HIDDEN
	[EQUIP_TYPE_OFF_HAND]  = "Off Hand",
	[EQUIP_TYPE_COSTUME]   = "Costume",--HIDDEN
	[EQUIP_TYPE_INVALID]   = "Invalid",--HIDDEN
	[EQUIP_TYPE_POISON]    = "Poison (Slot)",--HIDDEN
}

utils.setBonusFilter = {
	[-1] = "",
	[JB_FILTER_HAS_SET]    = "has set bonus",
	[JB_FILTER_HAS_NO_SET] = "has no set bonus"
}

utils.stolenFilter = {
	[-1] = "",
	[JB_FILTER_IS_STOLEN]     = "is stolen",
	[JB_FILTER_IS_NOT_STOLEN] = "is not stolen"
}

utils.craftFilter = {
	[-1] = "",
	[JB_FILTER_COULD_BE_CRAFTED] = "could be crafted",
	[JB_FILTER_IS_CRAFTED]       = "is crafted"
}

utils.craftNames = {
    [-1] = "",
    [CRAFTING_TYPE_ALCHEMY]         = "Alchemy",
    [CRAFTING_TYPE_BLACKSMITHING]   = "Blacksmithing",
    [CRAFTING_TYPE_CLOTHIER]        = "Clothier",
    [CRAFTING_TYPE_ENCHANTING]      = "Enchanting",
    [CRAFTING_TYPE_INVALID]         = "Invalid",
	[CRAFTING_TYPE_JEWELRYCRAFTING] = "Jewelry",
    [CRAFTING_TYPE_PROVISIONING]    = "Provisioning",
    [CRAFTING_TYPE_WOODWORKING]     = "Woodworking"
}

utils.typeNames = {
    [-1] = "",
    [ITEMTYPE_ADDITIVE]                     = "Additive",--HIDDEN
    [ITEMTYPE_ARMOR]                        = "Armor",
    [ITEMTYPE_ARMOR_BOOSTER]                = "Armor Booster",--HIDDEN
    [ITEMTYPE_ARMOR_TRAIT]                  = "Armor Trait",
    [ITEMTYPE_AVA_REPAIR]                   = "AvA Repair",
    [ITEMTYPE_BLACKSMITHING_BOOSTER]        = "Blacksmithing Temper",
    [ITEMTYPE_BLACKSMITHING_MATERIAL]       = "Blacksmithing Material",
    [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL]   = "Blacksmithing Raw Material",
    [ITEMTYPE_CLOTHIER_BOOSTER]             = "Clothier Tannin",
    [ITEMTYPE_CLOTHIER_MATERIAL]            = "Clothier Material",
    [ITEMTYPE_CLOTHIER_RAW_MATERIAL]        = "Clothier Raw Material",
    [ITEMTYPE_COLLECTIBLE]                  = "Collectible",
    [ITEMTYPE_CONTAINER]                    = "Container",
	[ITEMTYPE_CONTAINER_CURRENCY]           = "Currency Container",
    [ITEMTYPE_COSTUME]                      = "Costume",--HIDDEN
    [ITEMTYPE_CROWN_ITEM]                   = "Crown Item",
    [ITEMTYPE_CROWN_REPAIR]                 = "Crown Repair",
    [ITEMTYPE_DEPRECATED]                   = "Deprecated",--HIDDEN
	[ITEMTYPE_DEPRECATED_2]                 = "Deprecated_2",--HIDDEN
    [ITEMTYPE_DISGUISE]                     = "Disguise",
    [ITEMTYPE_DRINK]                        = "Drink",
	[ITEMTYPE_DYE_STAMP]                    = "Dye Stamp",
    [ITEMTYPE_ENCHANTING_RUNE_ASPECT]       = "Aspect Runestone",
    [ITEMTYPE_ENCHANTING_RUNE_ESSENCE]      = "Essence Runestone",
    [ITEMTYPE_ENCHANTING_RUNE_POTENCY]      = "Potency Runestone",
    [ITEMTYPE_ENCHANTMENT_BOOSTER]          = "Enchantment Booster",--HIDDEN
	[ITEMTYPE_FISH]                         = "Fish",
    [ITEMTYPE_FLAVORING]                    = "Flavoring",--HIDDEN
    [ITEMTYPE_FOOD]                         = "Food",
	[ITEMTYPE_FURNISHING]                   = "Furnishing",
	[ITEMTYPE_FURNISHING_MATERIAL]          = "Furnishing Material",
    [ITEMTYPE_GLYPH_ARMOR]                  = "Armor Glyph",
    [ITEMTYPE_GLYPH_JEWELRY]                = "Jewelry Glyph",
    [ITEMTYPE_GLYPH_WEAPON]                 = "Weapon Glyph",
	[ITEMTYPE_GROUP_REPAIR]                 = "Group Repair",
    [ITEMTYPE_INGREDIENT]                   = "Provisioning Ingredient",
	[ITEMTYPE_JEWELRYCRAFTING_BOOSTER]      = "Jewelry Plating",
	[ITEMTYPE_JEWELRYCRAFTING_MATERIAL]     = "Jewelry Material",
	[ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER]  = "Jewelry Raw Plating",--HIDDEN
	[ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = "Jewelry Raw Material",
	[ITEMTYPE_JEWELRY_RAW_TRAIT]            = "Jewelry Raw Trait",
	[ITEMTYPE_JEWELRY_TRAIT]                = "Jewelry Trait",
    [ITEMTYPE_LOCKPICK]                     = "Lockpick",--HIDDEN
    [ITEMTYPE_LURE]                         = "Lure",
	[ITEMTYPE_MASTER_WRIT]                  = "Master Writ",
	[ITEMTYPE_MOUNT]                        = "Mount",--HIDDEN
    [ITEMTYPE_NONE]                         = "None",--HIDDEN
    [ITEMTYPE_PLUG]                         = "Plug",--HIDDEN
    [ITEMTYPE_POISON]                       = "Poison",
    [ITEMTYPE_POISON_BASE]                  = "Poison Solvent",
    [ITEMTYPE_POTION]                       = "Potion",
    [ITEMTYPE_POTION_BASE]                  = "Potion Solvent",
	[ITEMTYPE_RACIAL_STYLE_MOTIF]           = "Style Motif",
    [ITEMTYPE_RAW_MATERIAL]                 = "Raw Material",
    [ITEMTYPE_REAGENT]                      = "Alchemy Reagent",
	[ITEMTYPE_RECALL_STONE]                 = "Recall Stone",
    [ITEMTYPE_RECIPE]                       = "Recipe",
    [ITEMTYPE_SIEGE]                        = "Siege",
    [ITEMTYPE_SOUL_GEM]                     = "Soul Gem",
    [ITEMTYPE_SPICE]                        = "Spice",--HIDDEN
    [ITEMTYPE_STYLE_MATERIAL]               = "Style Material",
    [ITEMTYPE_TABARD]                       = "Tabard",
    [ITEMTYPE_TOOL]                         = "Tool",
    [ITEMTYPE_TRASH]                        = "Trash",
    [ITEMTYPE_TREASURE]                     = "Treasure",
    [ITEMTYPE_TROPHY]                       = "Trophy",
    [ITEMTYPE_WEAPON]                       = "Weapon",
    [ITEMTYPE_WEAPON_BOOSTER]               = "Weapon Booster",--HIDDEN
    [ITEMTYPE_WEAPON_TRAIT]                 = "Weapon Trait",
    [ITEMTYPE_WOODWORKING_BOOSTER]          = "Woodworking Resin",
    [ITEMTYPE_WOODWORKING_MATERIAL]         = "Woodworking Material",
    [ITEMTYPE_WOODWORKING_RAW_MATERIAL]     = "Woodworking Raw Material"
}

utils.traitNames = {
    [-1] = "",
    [ITEM_TRAIT_TYPE_ARMOR_DIVINES]        = "Armor Divines",
    [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE]   = "Armor Impenetrable",
    [ITEM_TRAIT_TYPE_ARMOR_INFUSED]        = "Armor Infused",
    [ITEM_TRAIT_TYPE_ARMOR_INTRICATE]      = "Armor Intricate",
	[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED]      = "Armor Nirnhoned",
    [ITEM_TRAIT_TYPE_ARMOR_ORNATE]         = "Armor Ornate",
    [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS]     = "Armor Invigorating",
    [ITEM_TRAIT_TYPE_ARMOR_REINFORCED]     = "Armor Reinforced",
    [ITEM_TRAIT_TYPE_ARMOR_STURDY]         = "Armor Sturdy",
    [ITEM_TRAIT_TYPE_ARMOR_TRAINING]       = "Armor Training",
    [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED]    = "Armor Well-fitted",
    [ITEM_TRAIT_TYPE_JEWELRY_ARCANE]       = "Jewelry Arcane",
    [ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = "Jewelry Bloodthirsty",
    [ITEM_TRAIT_TYPE_JEWELRY_HARMONY]      = "Jewelry Harmony",
    [ITEM_TRAIT_TYPE_JEWELRY_HEALTHY]      = "Jewelry Healthy",
    [ITEM_TRAIT_TYPE_JEWELRY_INFUSED]      = "Jewelry Infused",
    [ITEM_TRAIT_TYPE_JEWELRY_INTRICATE]    = "Jewelry Intricate",
    [ITEM_TRAIT_TYPE_JEWELRY_ORNATE]       = "Jewelry Ornate",
    [ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE]   = "Jewelry Protective",
    [ITEM_TRAIT_TYPE_JEWELRY_ROBUST]       = "Jewelry Robust",
    [ITEM_TRAIT_TYPE_JEWELRY_SWIFT]        = "Jewelry Swift",
    [ITEM_TRAIT_TYPE_JEWELRY_TRIUNE]       = "Jewelry Triune",
    [ITEM_TRAIT_TYPE_NONE]                 = "No Traits",
    [ITEM_TRAIT_TYPE_WEAPON_CHARGED]       = "Weapon Charged",
    [ITEM_TRAIT_TYPE_WEAPON_DECISIVE]      = "Weapon Decisive",
    [ITEM_TRAIT_TYPE_WEAPON_DEFENDING]     = "Weapon Defending",
    [ITEM_TRAIT_TYPE_WEAPON_INFUSED]       = "Weapon Infused",
    [ITEM_TRAIT_TYPE_WEAPON_INTRICATE]     = "Weapon Intricate",
	[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED]     = "Weapon Nirnhoned",
    [ITEM_TRAIT_TYPE_WEAPON_ORNATE]        = "Weapon Ornate",
    [ITEM_TRAIT_TYPE_WEAPON_POWERED]       = "Weapon Powered",
    [ITEM_TRAIT_TYPE_WEAPON_PRECISE]       = "Weapon Precise",
    [ITEM_TRAIT_TYPE_WEAPON_SHARPENED]     = "Weapon Sharpened",
    [ITEM_TRAIT_TYPE_WEAPON_TRAINING]      = "Weapon Training",
    [ITEM_TRAIT_TYPE_ARMOR_AGGRESSIVE]     = "Comp Armor Aggressive",
    [ITEM_TRAIT_TYPE_ARMOR_AUGMENTED]      = "Comp Armor Augmented",
    [ITEM_TRAIT_TYPE_ARMOR_BOLSTERED]      = "Comp Armor Bolstered",
    [ITEM_TRAIT_TYPE_ARMOR_FOCUSED]        = "Comp Armor Focused",
    [ITEM_TRAIT_TYPE_ARMOR_PROLIFIC]       = "Comp Armor Prolific",
    [ITEM_TRAIT_TYPE_ARMOR_QUICKENED]      = "Comp Armor Quickened",
    [ITEM_TRAIT_TYPE_ARMOR_SHATTERING]     = "Comp Armor Shattering",
    [ITEM_TRAIT_TYPE_ARMOR_SOOTHING]       = "Comp Armor Soothing",
    [ITEM_TRAIT_TYPE_ARMOR_VIGOROUS]       = "Comp Armor Vigorous",
    [ITEM_TRAIT_TYPE_JEWELRY_AGGRESSIVE]   = "Comp Jewelry Aggressive",
    [ITEM_TRAIT_TYPE_JEWELRY_AUGMENTED]    = "Comp Jewelry Augmented",
    [ITEM_TRAIT_TYPE_JEWELRY_BOLSTERED]    = "Comp Jewelry Bolstered",
    [ITEM_TRAIT_TYPE_JEWELRY_FOCUSED]      = "Comp Jewelry Focused",
    [ITEM_TRAIT_TYPE_JEWELRY_PROLIFIC]     = "Comp Jewelry Prolific",
    [ITEM_TRAIT_TYPE_JEWELRY_QUICKENED]    = "Comp Jewelry Quickened",
    [ITEM_TRAIT_TYPE_JEWELRY_SHATTERING]   = "Comp Jewelry Shattering",
    [ITEM_TRAIT_TYPE_JEWELRY_SOOTHING]     = "Comp Jewelry Soothing",
    [ITEM_TRAIT_TYPE_JEWELRY_VIGOROUS]     = "Comp Jewelry Vigorous",
    [ITEM_TRAIT_TYPE_WEAPON_AGGRESSIVE]    = "Comp Weapon Aggressive",
    [ITEM_TRAIT_TYPE_WEAPON_AUGMENTED]     = "Comp Weapon Augmented",
    [ITEM_TRAIT_TYPE_WEAPON_BOLSTERED]     = "Comp Weapon Bolstered",
    [ITEM_TRAIT_TYPE_WEAPON_FOCUSED]       = "Comp Weapon Focused",
    [ITEM_TRAIT_TYPE_WEAPON_PROLIFIC]      = "Comp Weapon Prolific",
    [ITEM_TRAIT_TYPE_WEAPON_QUICKENED]     = "Comp Weapon Quickened",
    [ITEM_TRAIT_TYPE_WEAPON_SHATTERING]    = "Comp Weapon Shattering",
    [ITEM_TRAIT_TYPE_WEAPON_SOOTHING]      = "Comp Weapon Soothing",
    [ITEM_TRAIT_TYPE_WEAPON_VIGOROUS]      = "Comp Weapon Vigorous",
}

utils.qualityNames = {
    [-1] = "",
    [ITEM_FUNCTIONAL_QUALITY_TRASH]     = "Trash",
    [ITEM_FUNCTIONAL_QUALITY_NORMAL]    = "Normal",
    [ITEM_FUNCTIONAL_QUALITY_MAGIC]     = "Fine",
    [ITEM_FUNCTIONAL_QUALITY_ARCANE]    = "Superior",
    [ITEM_FUNCTIONAL_QUALITY_ARTIFACT]  = "Epic",
    [ITEM_FUNCTIONAL_QUALITY_LEGENDARY] = "Legendary"
}

utils.qualityColors = {
    [ITEM_FUNCTIONAL_QUALITY_TRASH]     = "|c777777",
    [ITEM_FUNCTIONAL_QUALITY_NORMAL]    = "|cffffff",
    [ITEM_FUNCTIONAL_QUALITY_MAGIC]     = "|c2dc50e",
    [ITEM_FUNCTIONAL_QUALITY_ARCANE]    = "|c3689ef",
    [ITEM_FUNCTIONAL_QUALITY_ARTIFACT]  = "|c912be1",
    [ITEM_FUNCTIONAL_QUALITY_LEGENDARY] = "|cd5b526"
}

utils.actorTypeNames = {
	[-1] = "",
	[GAMEPLAY_ACTOR_CATEGORY_COMPANION] = "Companion",
	[GAMEPLAY_ACTOR_CATEGORY_PLAYER]    = "Player"
}

utils.recKnownFilter = {
	[-1] = "",
	[JB_FILTER_REC_IS_KNOWN]     = "is known",
	[JB_FILTER_REC_IS_NOT_KNOWN] = "is not known"
}

utils.specTypeNames = {}
utils.specTypeNames.setChoices = {""}
utils.specTypeNames.all = {}

utils.specTypeNames.single = {
	[SPECIALIZED_ITEMTYPE_ADDITIVE]                     = "<None>",
	[SPECIALIZED_ITEMTYPE_ARMOR]                        = "<None>",
	[SPECIALIZED_ITEMTYPE_ARMOR_BOOSTER]                = "<None>",
	[SPECIALIZED_ITEMTYPE_ARMOR_TRAIT]                  = "<None>",
	[SPECIALIZED_ITEMTYPE_AVA_REPAIR]                   = "<None>",
	[SPECIALIZED_ITEMTYPE_BLACKSMITHING_BOOSTER]        = "<None>",
	[SPECIALIZED_ITEMTYPE_BLACKSMITHING_MATERIAL]       = "<None>",
	[SPECIALIZED_ITEMTYPE_BLACKSMITHING_RAW_MATERIAL]   = "<None>",
	[SPECIALIZED_ITEMTYPE_CLOTHIER_BOOSTER]             = "<None>",
	[SPECIALIZED_ITEMTYPE_CLOTHIER_MATERIAL]            = "<None>",
	[SPECIALIZED_ITEMTYPE_CLOTHIER_RAW_MATERIAL]        = "<None>",
	[SPECIALIZED_ITEMTYPE_CONTAINER_CURRENCY]           = "<None>",
	[SPECIALIZED_ITEMTYPE_COSTUME]                      = "<None>",
	[SPECIALIZED_ITEMTYPE_CROWN_ITEM]                   = "<None>",
	[SPECIALIZED_ITEMTYPE_CROWN_REPAIR]                 = "<None>",
	[SPECIALIZED_ITEMTYPE_DISGUISE]                     = "<None>",
	[SPECIALIZED_ITEMTYPE_DYE_STAMP]                    = "<None>",
	[SPECIALIZED_ITEMTYPE_ENCHANTING_RUNE_ASPECT]       = "<None>",
	[SPECIALIZED_ITEMTYPE_ENCHANTING_RUNE_ESSENCE]      = "<None>",
	[SPECIALIZED_ITEMTYPE_ENCHANTING_RUNE_POTENCY]      = "<None>",
	[SPECIALIZED_ITEMTYPE_ENCHANTMENT_BOOSTER]          = "<None>",
	[SPECIALIZED_ITEMTYPE_FISH]                         = "<None>",
	[SPECIALIZED_ITEMTYPE_FLAVORING]                    = "<None>",
	[SPECIALIZED_ITEMTYPE_GLYPH_ARMOR]                  = "<None>",
	[SPECIALIZED_ITEMTYPE_GLYPH_JEWELRY]                = "<None>",
	[SPECIALIZED_ITEMTYPE_GLYPH_WEAPON]                 = "<None>",
	[SPECIALIZED_ITEMTYPE_GROUP_REPAIR]                 = "<None>",
	[SPECIALIZED_ITEMTYPE_HOLIDAY_WRIT]                 = "<None>",
	[SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_BOOSTER]      = "<None>",
	[SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_MATERIAL]     = "<None>",
	[SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER]  = "<None>",
	[SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = "<None>",
	[SPECIALIZED_ITEMTYPE_JEWELRY_RAW_TRAIT]            = "<None>",
	[SPECIALIZED_ITEMTYPE_JEWELRY_TRAIT]                = "<None>",
	[SPECIALIZED_ITEMTYPE_LOCKPICK]                     = "<None>",
	[SPECIALIZED_ITEMTYPE_LURE]                         = "<None>",
	[SPECIALIZED_ITEMTYPE_MASTER_WRIT]                  = "<None>",
	[SPECIALIZED_ITEMTYPE_MOUNT]                        = "<None>",
	[SPECIALIZED_ITEMTYPE_NONE]                         = "<None>",
	[SPECIALIZED_ITEMTYPE_PLUG]                         = "<None>",
	[SPECIALIZED_ITEMTYPE_POISON]                       = "<None>",
	[SPECIALIZED_ITEMTYPE_POISON_BASE]                  = "<None>",
	[SPECIALIZED_ITEMTYPE_POTION]                       = "<None>",
	[SPECIALIZED_ITEMTYPE_POTION_BASE]                  = "<None>",
	[SPECIALIZED_ITEMTYPE_RAW_MATERIAL]                 = "<None>",
	[SPECIALIZED_ITEMTYPE_RECALL_STONE_KEEP]            = "<None>",
	[SPECIALIZED_ITEMTYPE_SOUL_GEM]                     = "<None>",
	[SPECIALIZED_ITEMTYPE_SPICE]                        = "<None>",
	[SPECIALIZED_ITEMTYPE_STYLE_MATERIAL]               = "<None>",
	[SPECIALIZED_ITEMTYPE_TABARD]                       = "<None>",
	[SPECIALIZED_ITEMTYPE_TOOL]                         = "<None>",
	[SPECIALIZED_ITEMTYPE_TRASH]                        = "<None>",
	[SPECIALIZED_ITEMTYPE_TREASURE]                     = "<None>",
	[SPECIALIZED_ITEMTYPE_WEAPON]                       = "<None>",
	[SPECIALIZED_ITEMTYPE_WEAPON_BOOSTER]               = "<None>",
	[SPECIALIZED_ITEMTYPE_WEAPON_TRAIT]                 = "<None>",
	[SPECIALIZED_ITEMTYPE_WOODWORKING_BOOSTER]          = "<None>",
	[SPECIALIZED_ITEMTYPE_WOODWORKING_MATERIAL]         = "<None>",
	[SPECIALIZED_ITEMTYPE_WOODWORKING_RAW_MATERIAL]     = "<None>"
}

utils.specTypeNames.collectible = {
	[-1] = "",
	[SPECIALIZED_ITEMTYPE_COLLECTIBLE_MONSTER_TROPHY] = "Monster Trophy",
	[SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH]      = "Rare Fish",
	[SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE]     = "Style Page"
}

utils.specTypeNames.container = {
	[-1] = "",
	[SPECIALIZED_ITEMTYPE_CONTAINER]            = "General",
	[SPECIALIZED_ITEMTYPE_CONTAINER_EVENT]      = "Event",
	[SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE] = "Motif Page"
}

utils.specTypeNames.drink = {
	[-1] = "",
	[SPECIALIZED_ITEMTYPE_DRINK_ALCOHOLIC]   = "Alcoholic",
	[SPECIALIZED_ITEMTYPE_DRINK_CORDIAL_TEA] = "Cordial Tea",
	[SPECIALIZED_ITEMTYPE_DRINK_DISTILLATE]  = "Distillate",
	[SPECIALIZED_ITEMTYPE_DRINK_LIQUEUR]     = "Liqueur",
	[SPECIALIZED_ITEMTYPE_DRINK_TEA]         = "Tea",
	[SPECIALIZED_ITEMTYPE_DRINK_TINCTURE]    = "Tincture",
	[SPECIALIZED_ITEMTYPE_DRINK_TONIC]       = "Tonic",
	[SPECIALIZED_ITEMTYPE_DRINK_UNIQUE]      = "Unique"
}

utils.specTypeNames.food = {
	[-1] = "",
	[SPECIALIZED_ITEMTYPE_FOOD_ENTREMET]  = "Entremet",
	[SPECIALIZED_ITEMTYPE_FOOD_FRUIT]     = "Fruit",
	[SPECIALIZED_ITEMTYPE_FOOD_GOURMET]   = "Gourmet",
	[SPECIALIZED_ITEMTYPE_FOOD_MEAT]      = "Meat",
	[SPECIALIZED_ITEMTYPE_FOOD_RAGOUT]    = "Ragout",
	[SPECIALIZED_ITEMTYPE_FOOD_SAVOURY]   = "Savoury",
	[SPECIALIZED_ITEMTYPE_FOOD_UNIQUE]    = "Unique",
	[SPECIALIZED_ITEMTYPE_FOOD_VEGETABLE] = "Vegetable"
}

utils.specTypeNames.furnishing = {
	[-1] = "",
	[SPECIALIZED_ITEMTYPE_FURNISHING_ATTUNABLE_STATION] = "Attunable Station",
	[SPECIALIZED_ITEMTYPE_FURNISHING_CRAFTING_STATION]  = "Crafting Station",
	[SPECIALIZED_ITEMTYPE_FURNISHING_LIGHT]             = "Light",
	[SPECIALIZED_ITEMTYPE_FURNISHING_ORNAMENTAL]        = "Ornamental",
	[SPECIALIZED_ITEMTYPE_FURNISHING_SEATING]           = "Seating",
	[SPECIALIZED_ITEMTYPE_FURNISHING_TARGET_DUMMY]      = "Target Dummy"
}

utils.specTypeNames.furnishingMat = {
	[-1] = "",
	[SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_ALCHEMY]          = "Alchemy",
	[SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_BLACKSMITHING]   = "Blacksmithing",
	[SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_CLOTHIER]        = "Clothier",
	[SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_ENCHANTING]      = "Enchanting",
	[SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_JEWELRYCRAFTING] = "Jewelrycrafting",
	[SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_PROVISIONING]    = "Provisioning",
	[SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_WOODWORKING]     = "Woodworking"
}

utils.specTypeNames.ingredient = {
	[-1] = "",
	[SPECIALIZED_ITEMTYPE_INGREDIENT_ALCOHOL]        = "Alcohol",
	[SPECIALIZED_ITEMTYPE_INGREDIENT_DRINK_ADDITIVE] = "Drink Additive",
	[SPECIALIZED_ITEMTYPE_INGREDIENT_FOOD_ADDITIVE]  = "Food Additive",
	[SPECIALIZED_ITEMTYPE_INGREDIENT_FRUIT]          = "Fruit",
	[SPECIALIZED_ITEMTYPE_INGREDIENT_MEAT]           = "Meat",
	[SPECIALIZED_ITEMTYPE_INGREDIENT_RARE]           = "Rare",
	[SPECIALIZED_ITEMTYPE_INGREDIENT_TEA]            = "Tea",
	[SPECIALIZED_ITEMTYPE_INGREDIENT_TONIC]          = "Tonic",
	[SPECIALIZED_ITEMTYPE_INGREDIENT_VEGETABLE]      = "Vegetable"
}

utils.specTypeNames.motif = {
	[-1] = "",
	[SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK]    = "Book",
	[SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER] = "Chapter"
}

utils.specTypeNames.reagent = {
	[-1] = "",
	[SPECIALIZED_ITEMTYPE_REAGENT_ANIMAL_PART] = "Animal Part",
	[SPECIALIZED_ITEMTYPE_REAGENT_FUNGUS]      = "Fungus",
	[SPECIALIZED_ITEMTYPE_REAGENT_HERB]        = "Herb"
}

utils.specTypeNames.recipe = {
	[-1] = "",
	[SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING]        = "Alchemy Formula",
	[SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING]  = "Blacksmithing Diagram",
	[SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING]       = "Clothier Pattern",
	[SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING]   = "Enchanting Schematic",
	[SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING] = "Jewelrycrafting Sketch",
	[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING]    = "Provisioning Design",
	[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK]       = "Drink",
	[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD]        = "Food",
	[SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING]  = "Woodworking Blueprint"
}

utils.specTypeNames.siege = {
	[-1] = "",
	[SPECIALIZED_ITEMTYPE_SIEGE_BALLISTA]  = "Ballista",
	[SPECIALIZED_ITEMTYPE_SIEGE_CATAPULT]  = "Catapult",
	[SPECIALIZED_ITEMTYPE_SIEGE_GRAVEYARD] = "Forward Camp",
	[SPECIALIZED_ITEMTYPE_SIEGE_LANCER]    = "Lancer",
	[SPECIALIZED_ITEMTYPE_SIEGE_MONSTER]   = "Monster",
	[SPECIALIZED_ITEMTYPE_SIEGE_OIL]       = "Oil",
	[SPECIALIZED_ITEMTYPE_SIEGE_RAM]       = "Ram",
	[SPECIALIZED_ITEMTYPE_SIEGE_TREBUCHET] = "Trebuchet",
	[SPECIALIZED_ITEMTYPE_SIEGE_UNIVERSAL] = "Universal"
}

utils.specTypeNames.trophy = {
	[-1] = "",
	[SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT]    = "Collectible Fragment",
	[SPECIALIZED_ITEMTYPE_TROPHY_DUNGEON_BUFF_INGREDIENT] = "Dungeon Buff Ingredient",
	[SPECIALIZED_ITEMTYPE_TROPHY_KEY]                     = "Key",
	[SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT]            = "Key Fragment",
	[SPECIALIZED_ITEMTYPE_TROPHY_MATERIAL_UPGRADER]       = "Mat Upgrader",
	[SPECIALIZED_ITEMTYPE_TROPHY_MUSEUM_PIECE]            = "Museum Piece",
	[SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT]         = "Recipe Fragment",
	[SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT]        = "Runebox Fragment",
	[SPECIALIZED_ITEMTYPE_TROPHY_SCROLL]                  = "Scroll",
	[SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT]           = "Survey Report",
	[SPECIALIZED_ITEMTYPE_TROPHY_TOY]                     = "Toy",
	[SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP]            = "Treasure Map",
	[SPECIALIZED_ITEMTYPE_TROPHY_TRIBUTE_CLUE]            = "Tribute Clue",
	[SPECIALIZED_ITEMTYPE_TROPHY_UPGRADE_FRAGMENT]        = "Upgrade Fragment"
}

utils.specTypeNames.abilityScript = {
	[-1] = ""
}

utils.specTypeNames.byItemType = {
	[ITEMTYPE_COLLECTIBLE]         = utils.specTypeNames.collectible,
	[ITEMTYPE_CONTAINER]           = utils.specTypeNames.container,
	[ITEMTYPE_DRINK]               = utils.specTypeNames.drink,
	[ITEMTYPE_FOOD]                = utils.specTypeNames.food,
	[ITEMTYPE_FURNISHING]          = utils.specTypeNames.furnishing,
	[ITEMTYPE_FURNISHING_MATERIAL] = utils.specTypeNames.furnishingMat,
	[ITEMTYPE_INGREDIENT]          = utils.specTypeNames.ingredient,
	[ITEMTYPE_RACIAL_STYLE_MOTIF]  = utils.specTypeNames.motif,
	[ITEMTYPE_REAGENT]             = utils.specTypeNames.reagent,
	[ITEMTYPE_RECIPE]              = utils.specTypeNames.recipe,
	[ITEMTYPE_SIEGE]               = utils.specTypeNames.siege,
	[ITEMTYPE_TROPHY]              = utils.specTypeNames.trophy
}

function utils.addNewApiConstants() -- Constants added by PTS api, move to regular array init later
--  Gold Road, 101042:
	if ITEMTYPE_CRAFTED_ABILITY ~= nil and ITEMTYPE_CRAFTED_ABILITY_SCRIPT ~= nil and ITEMTYPE_SCRIBING_INK ~= nil then
		utils.typeNames[ITEMTYPE_CRAFTED_ABILITY]        = "Grimoire"
		utils.typeNames[ITEMTYPE_CRAFTED_ABILITY_SCRIPT] = "Script"
		utils.typeNames[ITEMTYPE_SCRIBING_INK]           = "Luminous Ink"
	end
	if SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY ~= nil and SPECIALIZED_ITEMTYPE_SCRIBING_INK ~= nil then
		utils.specTypeNames.single[SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY] = "<None>"
		utils.specTypeNames.single[SPECIALIZED_ITEMTYPE_SCRIBING_INK]    = "<None>"
	end
	if SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_PRIMARY ~= nil and SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_SECONDARY ~= nil and SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_TERTIARY ~= nil then
		utils.specTypeNames.abilityScript[SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_PRIMARY]   = "Focus Script"
		utils.specTypeNames.abilityScript[SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_SECONDARY] = "Signature Script"
		utils.specTypeNames.abilityScript[SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_TERTIARY]  = "Affix Script"
		utils.specTypeNames.byItemType[ITEMTYPE_CRAFTED_ABILITY_SCRIPT] = utils.specTypeNames.abilityScript
	end
end

function utils.specTypeNames.initAllArray()
	utils.mergeTab(utils.specTypeNames.all, utils.specTypeNames.single)
	utils.mergeTab(utils.specTypeNames.all, utils.specTypeNames.collectible)
	utils.mergeTab(utils.specTypeNames.all, utils.specTypeNames.container)
	utils.mergeTab(utils.specTypeNames.all, utils.specTypeNames.drink)
	utils.mergeTab(utils.specTypeNames.all, utils.specTypeNames.food)
	utils.mergeTab(utils.specTypeNames.all, utils.specTypeNames.furnishing)
	utils.mergeTab(utils.specTypeNames.all, utils.specTypeNames.furnishingMat)
	utils.mergeTab(utils.specTypeNames.all, utils.specTypeNames.ingredient)
	utils.mergeTab(utils.specTypeNames.all, utils.specTypeNames.motif)
	utils.mergeTab(utils.specTypeNames.all, utils.specTypeNames.reagent)
	utils.mergeTab(utils.specTypeNames.all, utils.specTypeNames.recipe)
	utils.mergeTab(utils.specTypeNames.all, utils.specTypeNames.siege)
	utils.mergeTab(utils.specTypeNames.all, utils.specTypeNames.trophy)
	utils.mergeTab(utils.specTypeNames.all, utils.specTypeNames.abilityScript)
end
	