local GS = GetString
local secSpace = CSPS.secSpace

local weaponResearchLines = {
	[WEAPONTYPE_AXE] = {CRAFTING_TYPE_BLACKSMITHING, 1},
	[WEAPONTYPE_HAMMER] = {CRAFTING_TYPE_BLACKSMITHING, 2},
	[WEAPONTYPE_SWORD] = {CRAFTING_TYPE_BLACKSMITHING, 3},
	[WEAPONTYPE_TWO_HANDED_AXE] = {CRAFTING_TYPE_BLACKSMITHING, 4},
	[WEAPONTYPE_TWO_HANDED_HAMMER] = {CRAFTING_TYPE_BLACKSMITHING, 5},
	[WEAPONTYPE_TWO_HANDED_SWORD] = {CRAFTING_TYPE_BLACKSMITHING, 6},
	[WEAPONTYPE_DAGGER] = {CRAFTING_TYPE_BLACKSMITHING, 7},
	
	[WEAPONTYPE_BOW] = {CRAFTING_TYPE_WOODWORKING, 1},
	[WEAPONTYPE_FIRE_STAFF] = {CRAFTING_TYPE_WOODWORKING, 2},
	[WEAPONTYPE_FROST_STAFF] = {CRAFTING_TYPE_WOODWORKING, 3},
	[WEAPONTYPE_LIGHTNING_STAFF] = {CRAFTING_TYPE_WOODWORKING, 4},
	[WEAPONTYPE_HEALING_STAFF] = {CRAFTING_TYPE_WOODWORKING, 5},
	[WEAPONTYPE_SHIELD] = {CRAFTING_TYPE_WOODWORKING, 6},
}

local armorResearchLines = {
	[ARMORTYPE_LIGHT] = {
		[EQUIP_SLOT_CHEST] = {CRAFTING_TYPE_CLOTHIER, 1},
		[EQUIP_SLOT_FEET] = {CRAFTING_TYPE_CLOTHIER, 2},
		[EQUIP_SLOT_HAND] = {CRAFTING_TYPE_CLOTHIER, 3},
		[EQUIP_SLOT_HEAD] = {CRAFTING_TYPE_CLOTHIER, 4},
		[EQUIP_SLOT_LEGS] = {CRAFTING_TYPE_CLOTHIER, 5},
		[EQUIP_SLOT_SHOULDERS] = {CRAFTING_TYPE_CLOTHIER, 6},
		[EQUIP_SLOT_WAIST] = {CRAFTING_TYPE_CLOTHIER, 7},
	},
	[ARMORTYPE_MEDIUM] = {
		[EQUIP_SLOT_CHEST] = {CRAFTING_TYPE_CLOTHIER, 8},
		[EQUIP_SLOT_FEET] = {CRAFTING_TYPE_CLOTHIER, 9},
		[EQUIP_SLOT_HAND] = {CRAFTING_TYPE_CLOTHIER, 10},
		[EQUIP_SLOT_HEAD] = {CRAFTING_TYPE_CLOTHIER, 11},
		[EQUIP_SLOT_LEGS] = {CRAFTING_TYPE_CLOTHIER, 12},
		[EQUIP_SLOT_SHOULDERS] = {CRAFTING_TYPE_CLOTHIER, 13},
		[EQUIP_SLOT_WAIST] = {CRAFTING_TYPE_CLOTHIER, 14},
	},
	[ARMORTYPE_HEAVY] = {
		[EQUIP_SLOT_CHEST] = {CRAFTING_TYPE_BLACKSMITHING, 8},
		[EQUIP_SLOT_FEET] = {CRAFTING_TYPE_BLACKSMITHING, 9},
		[EQUIP_SLOT_HAND] = {CRAFTING_TYPE_BLACKSMITHING, 10},
		[EQUIP_SLOT_HEAD] = {CRAFTING_TYPE_BLACKSMITHING, 11},
		[EQUIP_SLOT_LEGS] = {CRAFTING_TYPE_BLACKSMITHING, 12},
		[EQUIP_SLOT_SHOULDERS] = {CRAFTING_TYPE_BLACKSMITHING, 13},
		[EQUIP_SLOT_WAIST] = {CRAFTING_TYPE_BLACKSMITHING, 14},
	},
}

local function getResearchLineInfoFromGear(gearSlot, armorType, weaponType)
	if armorType and armorType ~= 0 then
		return unpack(armorResearchLines[armorType][gearSlot])
	elseif weaponType and weaponType ~= 0 then
		return unpack(weaponResearchLines[weaponType])
	elseif gearSlot == EQUIP_SLOT_NECK then
		return CRAFTING_TYPE_JEWELRYCRAFTING, 1
	elseif gearSlot == EQUIP_SLOT_RING1 or gearSlot == EQUIP_SLOT_RING2 then
		return CRAFTING_TYPE_JEWELRYCRAFTING, 2
	end
end

function CSPS.getPatternInfo(gearSlot, armorType, weaponType)
	local station, line = getResearchLineInfoFromGear(gearSlot, armorType, weaponType)
	if station == CRAFTING_TYPE_JEWELRYCRAFTING then return station, line == 1 and 2 or 1 end
	if station == CRAFTING_TYPE_CLOTHIER then return station, line == 1 and line or line + 1 end -- two body pieces
	if station == CRAFTING_TYPE_BLACKSMITHING then return station, line end
	if station == CRAFTING_TYPE_WOODWORKING then return station, line == 1 and 1 or line == 7 and 2 or line + 1 end
end

function CSPS.canCraftTrait(gearSlot, armorType, weaponType, itemTrait)
	local craft, researchLineIndex = getResearchLineInfoFromGear(gearSlot, armorType, weaponType)
	local _, _, numTraits = GetSmithingResearchLineInfo(craft, researchLineIndex)
	for i=1, numTraits do
		local traitType, _, known = GetSmithingResearchLineTraitInfo(craft, researchLineIndex, i)
		if traitType == itemTrait then return known end
	end
	return false
end

function CSPS.canCraftSetItem(setId, gearSlot, armorType, weaponType)
	local craft, researchLineIndex = getResearchLineInfoFromGear(gearSlot, armorType, weaponType)
	local traitsNeeded = LibSets and LibSets.GetTraitsNeeded(setId)
	if not traitsNeeded then return false end
	local _, _, numTraits = GetSmithingResearchLineInfo(craft, researchLineIndex)
	local traitsKnown = 0
	for i=1, numTraits do
		local traitType, _, known = GetSmithingResearchLineTraitInfo(craft, researchLineIndex, i)
		if known then traitsKnown = traitsKnown + 1 end
	end
	return traitsKnown >= traitsNeeded
end

function CSPS.getUpgradeCost(itemLink, minQuality, itemQuality)
	local craft = GetItemLinkCraftingSkillType(itemLink)
	local costTable = {}
	local costFormatted = {}
	--GetItemLinkCraftingSkillType
	for quality = minQuality, itemQuality - 1 do
   		local matsLink = GetSmithingImprovementItemLink(craft, quality)
        local _, matsIcon, matsAvailable = GetSmithingImprovementItemInfo(craft, quality)
        local matsRequired = GetSmithingGuaranteedImprovementItemAmount(craft, quality)
		table.insert(costTable, {link = matsLink, icon = matsIcon, required = matsRequired, available = matsAvailable})
		matsRequired = (matsRequired > matsAvailable and ZO_ERROR_COLOR or ZO_SUCCEEDED_TEXT):Colorize(matsRequired.."x")
		--local myCost = string.format("%s%s|t22:22:%s|t", matsRequired, secSpace, matsIcon)
		local myCost = zo_strformat("<<1>><<2>><<C:3>>", matsRequired, secSpace, GetItemLinkName(matsLink))
		table.insert(costFormatted, myCost)
	end
	return #costFormatted > 0 and table.concat(costFormatted, ", ") or nil, costTable
end

function CSPS.isUpgradeSkillLeveled(craft)
	local craft = type(craft) == "number" and craft or GetItemLinkCraftingSkillType(craft)
	return GetSmithingGuaranteedImprovementItemAmount(craft, ITEM_FUNCTIONAL_QUALITY_LEGENDARY) > 8
end