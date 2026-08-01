local GS = GetString
local ctrGear = {}
local gearSelector = {
	controls = ctrGear
}
CSPS.gearSelector = gearSelector
local gearCategories = {
	
}

local cspsD = CSPS.cspsD

local theGear = {}

local gearSlots = {
	EQUIP_SLOT_HEAD, EQUIP_SLOT_SHOULDERS,EQUIP_SLOT_CHEST, EQUIP_SLOT_HAND, EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET, 
	EQUIP_SLOT_NECK, EQUIP_SLOT_RING1, EQUIP_SLOT_RING2,
	EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND, EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF,
	EQUIP_SLOT_POISON, EQUIP_SLOT_BACKUP_POISON,
}

local gearSlotIcons = {
	[EQUIP_SLOT_CHEST] = "gearslot_chest",
	[EQUIP_SLOT_HAND] = "gearslot_hands",
	[EQUIP_SLOT_WAIST] = "gearslot_belt",
	[EQUIP_SLOT_LEGS] = "gearslot_legs",
	[EQUIP_SLOT_FEET] = "gearslot_feet",
	[EQUIP_SLOT_HEAD] = "gearslot_head",
	[EQUIP_SLOT_SHOULDERS] = "gearslot_shoulders",
	[EQUIP_SLOT_MAIN_HAND] = "gearslot_mainhand",
	[EQUIP_SLOT_OFF_HAND] = "gearslot_offhand",
	[EQUIP_SLOT_BACKUP_MAIN] = "gearslot_mainhand",
	[EQUIP_SLOT_BACKUP_OFF] = "gearslot_offhand",
	[EQUIP_SLOT_NECK] = "gearslot_neck",
	[EQUIP_SLOT_RING1] = "gearslot_ring",
	[EQUIP_SLOT_RING2] = "gearslot_ring",
	[EQUIP_SLOT_POISON] = "gearslot_poison",
	[EQUIP_SLOT_BACKUP_POISON] = "gearslot_poison",
}

local gearSlotsBody = {
	[EQUIP_SLOT_CHEST] = true,
	[EQUIP_SLOT_HAND] = true,
	[EQUIP_SLOT_WAIST] = true,
	[EQUIP_SLOT_LEGS] = true,
	[EQUIP_SLOT_FEET] = true,
	[EQUIP_SLOT_HEAD] = true,
	[EQUIP_SLOT_SHOULDERS] = true,
}
	
local gearSlotsHands = {
	[EQUIP_SLOT_MAIN_HAND] = true,
	[EQUIP_SLOT_OFF_HAND] = true,
	[EQUIP_SLOT_BACKUP_MAIN] = true,
	[EQUIP_SLOT_BACKUP_OFF] = true,
}

local gearSlotsBackbar = {
	[EQUIP_SLOT_BACKUP_MAIN] = true,
	[EQUIP_SLOT_BACKUP_OFF] = true,
}

local gearSlotsJewelry = {
	[EQUIP_SLOT_NECK] = true,
	[EQUIP_SLOT_RING1] = true,
	[EQUIP_SLOT_RING2] = true,
}

local gearSlotsPoison = {
	[EQUIP_SLOT_POISON] = true,
	[EQUIP_SLOT_BACKUP_POISON] = true,
}


local isTwoHanded = {
    [WEAPONTYPE_FIRE_STAFF] = true,
    [WEAPONTYPE_FROST_STAFF] = true,
    [WEAPONTYPE_HEALING_STAFF] = true,
    [WEAPONTYPE_LIGHTNING_STAFF] = true,
    [WEAPONTYPE_TWO_HANDED_AXE] = true,
    [WEAPONTYPE_TWO_HANDED_HAMMER] = true,
    [WEAPONTYPE_TWO_HANDED_SWORD] = true,
	[WEAPONTYPE_BOW] = true,
}


local equipSlotToEquipType = {
	[EQUIP_SLOT_BACKUP_MAIN] = {[EQUIP_TYPE_ONE_HAND] = true, [EQUIP_TYPE_TWO_HAND] = true},
	[EQUIP_SLOT_BACKUP_OFF] = {[EQUIP_TYPE_ONE_HAND] = true, [EQUIP_TYPE_OFF_HAND] = true},

	[EQUIP_SLOT_MAIN_HAND] = {[EQUIP_TYPE_ONE_HAND] = true, [EQUIP_TYPE_MAIN_HAND] = true, [EQUIP_TYPE_TWO_HAND] = true},
	[EQUIP_SLOT_OFF_HAND] = {[EQUIP_TYPE_ONE_HAND] = true, [EQUIP_TYPE_OFF_HAND] = true},

	[EQUIP_SLOT_POISON] = {[EQUIP_TYPE_POISON] = true},
	[EQUIP_SLOT_BACKUP_POISON] = {[EQUIP_TYPE_POISON] = true},

	[EQUIP_SLOT_CHEST] = {[EQUIP_TYPE_CHEST] = true},
	[EQUIP_SLOT_FEET] = {[EQUIP_TYPE_FEET] = true},
	[EQUIP_SLOT_HEAD] = {[EQUIP_TYPE_HEAD] = true},
	[EQUIP_SLOT_LEGS] = {[EQUIP_TYPE_LEGS] = true},
	[EQUIP_SLOT_SHOULDERS] = {[EQUIP_TYPE_SHOULDERS] = true},
	[EQUIP_SLOT_WAIST] = {[EQUIP_TYPE_WAIST] = true},
	[EQUIP_SLOT_HAND] = {[EQUIP_TYPE_HAND] = true},

	[EQUIP_SLOT_NECK] = {[EQUIP_TYPE_NECK] = true},
	[EQUIP_SLOT_RING1] = {[EQUIP_TYPE_RING] = true},
	[EQUIP_SLOT_RING2] = {[EQUIP_TYPE_RING] = true},
}

-- EQUIP_SLOT_COSTUME		[EQUIP_TYPE_COSTUME

local poisonItemLink = "|H0:item:%s:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:%s|h|h"

local itemIdsGlyphsArmor = {
	26580, 26582, 26588, 68343, -- health, magicka, stamina, prismatic defense
}

local itemIdsGlyphsWeapon = {
	26848, 5365, 26844, 26587, 26841, 45869, -- flame, frost, shock, poison, foul, decreasehealth
	43573,45868,45867,  -- absorb health / magicka / stamina
	54484,26845, 5366, 26591, 68344, -- weapon damage, crushing, hardening, weakening, prismatic onslaught 
}

local itemIdsGlyphsJewelry = {
	26581, 26583, 26589,  -- health/magicka/stamina recovery 
	45884, 45883,  -- increase magical/physical harm
	45870, 45871,  -- reduce spell/stam cost
	45872, 45873,   -- bashing damage, shielding
	26849, 5364, 43570, 26586, 26847,  -- flame/frost/shock/poison/disease resistance
	45875, 45874,  -- potion speed / poweer
	166047,	166046, -- prismatic recovery, reduce prismatic skill cost
	45886, 45885,  -- decrease spell/physical harm
}

local enchantIds = false
local enchantNames = false
local enchantGlyphs = false
	

local myCPLevel = math.min(GetUnitChampionPoints("player") or 0, 160)
myCPLevel = math.floor(myCPLevel/10)*10
local myLevel = GetUnitLevel("player")	
	
local function tableContains(myTable, myEntry)
	for i, v in pairs(myTable) do
		if v == myEntry then return true end
	end
	return false
end

function CSPS.getGearSlotsHands()
	return gearSlotsHands
end

function CSPS.getSortedGearSlots()
	return gearSlots
end

local function buildGlyphTables()
	enchantIds = {}
	enchantNames = {}
	enchantGlyphs = {}
	for j, w in pairs({itemIdsGlyphsArmor, itemIdsGlyphsJewelry, itemIdsGlyphsWeapon}) do
		for i, v in pairs(w) do
			local itemLink = string.format("|H0:item:%s:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", v) 
			local _, enchantNameFull = GetItemLinkEnchantInfo(itemLink)
			local enchantId = GetItemLinkDefaultEnchantId(itemLink)
			local enchantName = v ~= 68343 and v ~= 166047 and
				(string.match(enchantNameFull, "(.+)%s*Enchantment") or string.match(enchantNameFull, ":%s*(.+)") or 
				string.match(enchantNameFull, "Enchantement%s*(.+)"))
			local enchantSearchCategory = GetEnchantSearchCategoryType(enchantId)
			if enchantId == 179 then enchantSearchCategory = ENCHANTMENT_SEARCH_CATEGORY_PRISMATIC_REGEN end
			enchantName = enchantName or GS("SI_ENCHANTMENTSEARCHCATEGORYTYPE", enchantSearchCategory) or ""
			-- d(itemLink.." - "..enchantName)
			enchantIds[v] = enchantId
			enchantGlyphs[enchantId] = v
			enchantNames[enchantId] = enchantName
		end
	end
end

local function buildItemLink(itemId, itemQuality, enchantGlyph, crafted, traitType)
	if not itemId then return "" end
	itemQuality = itemQuality or ITEM_QUALITY_LEGENDARY
	local subLevel = 359 + itemQuality
	if crafted then subLevel = 365 + itemQuality end
	local linkTable = {
		"|H0:item",
		itemId,
		subLevel,
		50,
		enchantGlyph or 0,
		enchantGlyph and subLevel or 0,
		enchantGlyph and 50 or 0,
		traitType or 0,
		"0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h",
	}
	return table.concat(linkTable, ":")
end

CSPS.buildItemLink = buildItemLink

local function checkItemLevel(itemLink, noText)
	local warnLevel = false
	local ignoreLevel = false
	
	if GetItemLinkItemId(itemLink) == 44904 then 
		if noText then return false end
		ignoreLevel = true
	end
	
	local auxCPLevel = myCPLevel
	
	if GetItemLinkItemType(itemLink) == ITEMTYPE_POISON then
		if GetItemLinkDisplayQuality(itemLink) == ITEM_QUALITY_LEGENDARY then 
			if noText then return false end
			ignoreLevel = true
		end
		if auxCPLevel > 150 then auxCPLevel = 150 end
	end
	
	local reqCP = GetItemLinkRequiredChampionPoints(itemLink)
	local reqLevel = GetItemLinkRequiredLevel(itemLink)
	
	local maxLevelDiff = CSPS.savedVariables.settings.maxLevelDiff or 10
	
	if not ignoreLevel then
		if math.abs(reqCP - auxCPLevel) >= maxLevelDiff or auxCPLevel == 0 and math.abs(reqLevel - myLevel) >= maxLevelDiff then 
			warnLevel = true 
		end
	end
	
	if noText then return warnLevel end
	
	local levelText = reqCP and reqCP > 0 and string.format("|t28:28:esoui/art/champion/champion_icon_32.dds|t %s", reqCP) or reqLevel
	levelText = string.format("%s: %s", GS(SI_ITEM_FORMAT_STR_LEVEL), levelText)
	return warnLevel, levelText
end

CSPS.checkItemLevel = checkItemLevel

local function getSetItemInfo(setId, gearSlot, itemType,  traitType, itemQuality)

	itemQuality = itemQuality or ITEM_QUALITY_LEGENDARY

	local numPieces = GetNumItemSetCollectionPieces(setId)
	
	if numPieces > 0 then
		local setType = GetItemSetType(setId)
		for i=1, numPieces do
			if numPieces == 1  and setType ~= ITEM_SET_TYPE_WEAPON then itemQuality = ITEM_QUALITY_LEGENDARY end -- mythic items 
			-- no green items that aren't open world sets
			if setType == ITEM_SET_TYPE_DUNGEON and itemQuality < ITEM_QUALITY_ARCANE then itemQuality = ITEM_QUALITY_ARCANE end
			-- no blue perfected items
			if GetItemSetUnperfectedSetId(setId) ~= 0 and itemQuality == ITEM_QUALITY_ARCANE then itemQuality = ITEM_QUALITY_ARTIFACT end
			local pieceId, setSlot = GetItemSetCollectionPieceInfo(setId, i)
			local itemLink = GetItemSetCollectionPieceItemLink(pieceId, 0, traitType, itemQuality)
			local equipType = GetItemLinkEquipType(itemLink)
			if (gearSlotsHands[gearSlot] and GetItemLinkWeaponType(itemLink) == itemType) or
				 ((not gearSlotsHands[gearSlot]) and equipSlotToEquipType[gearSlot] and equipSlotToEquipType[gearSlot][equipType] and (gearSlotsJewelry[gearSlot] or itemType == GetItemLinkArmorType(itemLink))) then 
				local icon = GetItemLinkInfo(itemLink)
				return icon, itemLink, pieceId, setSlot
			end
		end
	elseif setId == 0 then
		local itemId = CSPS.getGenericItemId(gearSlotsHands[gearSlot] and itemType, gearSlotsBody[gearSlot] and itemType, gearSlot)
		local itemLink = buildItemLink(itemId, itemQuality, false, true, traitType)
		local icon = GetItemLinkInfo(itemLink)
		return icon, itemLink, nil, nil
	else
		local allSetItemIds = LibSets and LibSets.GetSetItemIds(setId)
		if not allSetItemIds then return "---", "---" end
		for theItemId, v in pairs(allSetItemIds) do
			local itemLink = buildItemLink(theItemId, itemQuality, false, true, traitType)
			local equipType = GetItemLinkEquipType(itemLink)
			if (gearSlotsHands[gearSlot] and GetItemLinkWeaponType(itemLink) == itemType) or
				 ((not gearSlotsHands[gearSlot]) and equipSlotToEquipType[gearSlot] and equipSlotToEquipType[gearSlot][equipType] and (gearSlotsJewelry[gearSlot] or itemType == GetItemLinkArmorType(itemLink))) then 
					local icon = GetItemLinkInfo(itemLink)
					return icon, itemLink, nil, nil
			end
		end
		return icon, "---", nil, nil
	end
	
end
CSPS.getSetItemInfo = getSetItemInfo

local function setupBoxLabelPair(control, description, isTextField)
	control.label:SetText(description)
	control.box.data = control.box.data or {}
	control.box.data.tooltipText = description
	control.box:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	control.box:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	if not isTextField then 
		control.box.comboBox = control.box.comboBox or ZO_ComboBox_ObjectFromContainer(control.box) 
		control.box.comboBox:SetSortsItems(false)
	end

end

local function doesSetFitGearSlot(gearSlot, setId)
	if not gearSlot then return true end
	if not setId then return false end
	local fittingEquipTypes = equipSlotToEquipType[gearSlot]
	local setType = GetItemSetType(setId)
	if setType == ITEM_SET_TYPE_CRAFTED then return true end
	if setType == ITEM_SET_TYPE_MONSTER then return gearSlot == EQUIP_SLOT_SHOULDERS or gearSlot == EQUIP_SLOT_HEAD end
	if setType == ITEM_SET_TYPE_WEAPON then return gearSlotsHands[gearSlot] == true end
    
	if GetNumItemSetCollectionPieces(setId) == 1 then
		--mythic or single weapon
		return fittingEquipTypes[GetItemLinkEquipType(GetItemSetCollectionPieceItemLink(GetItemSetCollectionPieceInfo(setId, 1)))]
	end
	
	if GetNumItemSetCollectionPieces(setId) < 22 then
		for i=1, GetNumItemSetCollectionPieces(setId) do
			if fittingEquipTypes[GetItemLinkEquipType(GetItemSetCollectionPieceItemLink(GetItemSetCollectionPieceInfo(setId, i)))] then return true end
		end
		return false
	end
		
	return true
end

local function fillComboBox(control, choiceList, filterFunc, nameFunc, callback, selectText)
	local comboBox = control.comboBox
	comboBox:ClearItems()
	if not choiceList then return end
	for i, v in pairs(choiceList) do
		if not filterFunc or filterFunc(i,v) then
			comboBox:AddItem(comboBox:CreateItemEntry(nameFunc(i, v), function() callback(i, v) PlaySound(SOUNDS.POSITIVE_CLICK) end), ZO_COMBOBOX_SUPPRESS_UPDATE)
		end
	end
	comboBox:UpdateItems()
	comboBox:SetSelectedItem(selectText)
end


local function fillTraitCombo(gearSlot, selectTrait, isShield)
	
	local armorTraits = {ITEM_TRAIT_TYPE_ARMOR_DIVINES, ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE, ITEM_TRAIT_TYPE_ARMOR_INFUSED, ITEM_TRAIT_TYPE_ARMOR_NIRNHONED, ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS, ITEM_TRAIT_TYPE_ARMOR_REINFORCED, ITEM_TRAIT_TYPE_ARMOR_STURDY, ITEM_TRAIT_TYPE_ARMOR_TRAINING, ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED}
	local jewelryTraits = {ITEM_TRAIT_TYPE_JEWELRY_ARCANE, ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY, ITEM_TRAIT_TYPE_JEWELRY_HARMONY, ITEM_TRAIT_TYPE_JEWELRY_HEALTHY, ITEM_TRAIT_TYPE_JEWELRY_INFUSED,  ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE, ITEM_TRAIT_TYPE_JEWELRY_ROBUST, ITEM_TRAIT_TYPE_JEWELRY_SWIFT, ITEM_TRAIT_TYPE_JEWELRY_TRIUNE}
	local weaponTraits = {ITEM_TRAIT_TYPE_WEAPON_CHARGED, ITEM_TRAIT_TYPE_WEAPON_DECISIVE, ITEM_TRAIT_TYPE_WEAPON_DEFENDING, ITEM_TRAIT_TYPE_WEAPON_INFUSED, ITEM_TRAIT_TYPE_WEAPON_NIRNHONED, ITEM_TRAIT_TYPE_WEAPON_POWERED, ITEM_TRAIT_TYPE_WEAPON_PRECISE, ITEM_TRAIT_TYPE_WEAPON_SHARPENED, ITEM_TRAIT_TYPE_WEAPON_TRAINING}
	local myTraits = gearSlotsHands[gearSlot] and not isShield and weaponTraits or gearSlotsJewelry[gearSlot] and jewelryTraits or armorTraits
	
	selectTrait = selectTrait or gearSelector.trait
	if selectTrait and not tableContains(myTraits, selectTrait) then selectTrait = false end
	
	selectTrait = selectTrait or isShield and ITEM_TRAIT_TYPE_ARMOR_DIVINES or gearSlotsHands[gearSlot] and ITEM_TRAIT_TYPE_WEAPON_PRECISE or 
	gearSlotsJewelry[gearSlot] and ITEM_TRAIT_TYPE_JEWELRY_ARCANE or ITEM_TRAIT_TYPE_ARMOR_DIVINES
	
	gearSelector.trait = selectTrait
	selectTrait = GS("SI_ITEMTRAITTYPE", selectTrait)
	
	fillComboBox(ctrGear.trait.box, myTraits, false,  function(i,v) return(GS("SI_ITEMTRAITTYPE", v)) end, function(i,v) gearSelector.trait = v end, selectTrait)
end

local function getWeaponTypeName(weaponType)
	if isTwoHanded[weaponType] then
		return string.format("%s (%s)", GS("SI_WEAPONTYPE", weaponType), GS(SI_WEAPONCONFIGTYPE3))
	else
		return GS("SI_WEAPONTYPE", weaponType)
	end
end

local function fillEnchantCombo(gearSlot, selectEnchant)
	if not enchantIds then buildGlyphTables() end	
	
	local myGlyphs = gearSlotsHands[gearSlot] and gearSelector.type ~= WEAPONTYPE_SHIELD and itemIdsGlyphsWeapon
		or gearSlotsJewelry[gearSlot] and itemIdsGlyphsJewelry or itemIdsGlyphsArmor

	selectEnchant = selectEnchant or gearSelector.enchant 

	if selectEnchant and not tableContains(myGlyphs, enchantGlyphs[selectEnchant]) then selectEnchant = false end
	
	selectEnchant = selectEnchant or enchantIds[myGlyphs[1]]
	
	gearSelector.enchant = selectEnchant
	selectEnchant = enchantNames[selectEnchant]

	fillComboBox(ctrGear.enchantment.box, myGlyphs, false, function(i,v) return zo_strformat("<<C:1>>", enchantNames[enchantIds[v]]) end, 
		function(i,v) 
			gearSelector.enchant = enchantIds[v]
		end, 
		selectEnchant)
end

local function fillTypeCombo(gearSlot, selectText, setArmorTypes)

	local armorTypes = setArmorTypes and #setArmorTypes > 0 and setArmorTypes or {ARMORTYPE_LIGHT, ARMORTYPE_MEDIUM, ARMORTYPE_HEAVY}
	local weaponTypes = {WEAPONTYPE_AXE, WEAPONTYPE_SWORD, WEAPONTYPE_HAMMER, WEAPONTYPE_DAGGER, WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_SWORD, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_BOW, WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF, WEAPONTYPE_HEALING_STAFF, WEAPONTYPE_SHIELD}
			
	if gearSlotsHands[gearSlot] and GetItemSetType(gearSelector.setId) == ITEM_SET_TYPE_WEAPON then
		weaponTypes = {}
		for i=1, GetNumItemSetCollectionPieces(gearSelector.setId) do
			local collectionPieceWeaponType = GetItemLinkWeaponType(GetItemSetCollectionPieceItemLink(GetItemSetCollectionPieceInfo(gearSelector.setId,i)))
			if collectionPieceWeaponType > 0 then table.insert(weaponTypes, collectionPieceWeaponType) end
		end
	end
	selectText = selectText or gearSelector.type
	
	if selectText and gearSlotsHands[gearSlot] and not tableContains(weaponTypes, selectText) then selectText = false end
	if selectText and gearSlotsBody[gearSlot] and not tableContains(armorTypes, selectText) then selectText = false end
	
	selectText = selectText or gearSlotsHands[gearSlot] and weaponTypes[1] or gearSlotsBody[gearSlot] and armorTypes[1] or 0
	
	gearSelector.type = selectText
	selectText = gearSlotsHands[gearSlot] and getWeaponTypeName(selectText) or GS("SI_ARMORTYPE", selectText)

	if gearSlotsHands[gearSlot] then
		fillComboBox(ctrGear.type.box, weaponTypes, false, function(i,v) return(getWeaponTypeName(v)) end, 
			function(i,v) 
				if v == WEAPONTYPE_SHIELD and gearSelector.type ~= WEAPONTYPE_SHIELD then
					 gearSelector.type = v 
					 gearSelector.trait = nil
					 fillTraitCombo(gearSlot, false, true)
					 gearSelector.enchant = nil
					 fillEnchantCombo(gearSlot, false)
				elseif  v ~= WEAPONTYPE_SHIELD and gearSelector.type == WEAPONTYPE_SHIELD then
					gearSelector.type = v 
					 gearSelector.trait = nil
					fillTraitCombo(gearSlot, false, false)
					gearSelector.enchant = nil
					fillEnchantCombo(gearSlot, false)
				else
					gearSelector.type = v 
				end				
			end, selectText)
	elseif gearSlotsJewelry[gearSlot] then
		fillComboBox(ctrGear.type.box, false, false, function(i,v) end, 
			function(i,v) end, "")
	else
		fillComboBox(ctrGear.type.box, armorTypes, false, function(i,v) return(GS("SI_ARMORTYPE", v)) end, 
			function(i,v) 
				gearSelector.type = v 
			end, selectText)
	end
end

local function fillQualityCombo(mythic, selectText, setType)
	selectText = selectText or gearSelector.quality or ITEM_QUALITY_LEGENDARY 
	
	local qualityList = {ITEM_QUALITY_NORMAL, ITEM_QUALITY_MAGIC, ITEM_QUALITY_ARCANE, ITEM_QUALITY_ARTIFACT, ITEM_QUALITY_LEGENDARY}
	if mythic then 
		qualityList = {ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE} 
	elseif setType ~= ITEM_SET_TYPE_CRAFTED then
		table.remove(qualityList, 1)
		if setType ~= ITEM_SET_TYPE_WORLD then
			table.remove(qualityList, 1)
		end
	end
	
	if selectText and not tableContains(qualityList, selectText) then selectText = qualityList[#qualityList] end

	gearSelector.quality = selectText
	selectText = GetItemQualityColor(selectText):Colorize(GS("SI_ITEMDISPLAYQUALITY", selectText))
	
	fillComboBox(ctrGear.quality.box, qualityList, false, function(i,v) return(GetItemQualityColor(v):Colorize(GS("SI_ITEMDISPLAYQUALITY", v))) end, function(i,v) gearSelector.quality = v end, selectText)
end

local function setSetId(setId)
	gearSelector.setId = setId
	local gearSlot = gearSelector.gearSlot
	if not setId then
		ctrGear.type:SetHidden(true)
		ctrGear.quality:SetHidden(true)
		ctrGear.trait:SetHidden(true)
		ctrGear.enchantment:SetHidden(true)
	else
		local setArmorTypes = false
		if gearSlotsBody[gearSlot] and GetItemSetType(setId) ~= ITEM_SET_TYPE_CRAFTED then
			local armorTypesChecked = {}
			setArmorTypes = {}
			for i=1, GetNumItemSetCollectionPieces(setId) do
				local armorType = GetItemLinkArmorType(GetItemSetCollectionPieceItemLink(GetItemSetCollectionPieceInfo(setId, i)))
				if armorType ~= 0 and not armorTypesChecked[armorType] then
					table.insert(setArmorTypes, armorType)
					armorTypesChecked[armorType] = true
				end
			end
		end
		local setType = GetItemSetType(setId)
		local mySetItem = theGear[gearSlot] or {}
		fillTraitCombo(gearSlot, mySetItem.trait or false)
		fillQualityCombo(GetNumItemSetCollectionPieces(setId) == 1  and setType ~= ITEM_SET_TYPE_WEAPON, mySetItem.quality or false, setType)
		fillTypeCombo(gearSlot, mySetItem.type or false, setArmorTypes)
		fillEnchantCombo(gearSlot, mySetItem.enchant or false)
	
		ctrGear.quality:SetHidden(GetNumItemSetCollectionPieces(setId) == 1 and setType ~= ITEM_SET_TYPE_WEAPON)
		ctrGear.type:SetHidden(gearSlotsJewelry[gearSlot])
		ctrGear.trait:SetHidden(false)
		ctrGear.enchantment:SetHidden(false)
	end
end

local function formatSetName(setId)
	if GetItemSetType(setId) == ITEM_SET_TYPE_WEAPON then
		return zo_strformat("<<C:1>> (<<C:2>>)", GetItemSetName(setId), GetItemSetCollectionCategoryName(GetItemSetCollectionCategoryId(setId)))
	end
	return zo_strformat("<<C:1>>", GetItemSetName(setId))
end

local function getSetAutoCompleteOptions(gearSlot)
	if gearSlotsPoison[gearSlot] then return false, false end
	local allSets = {}
	local allSetsT = {}
	for i, v in pairs(CSPS.GetSetList()) do
		if not gearSlot or doesSetFitGearSlot(gearSlot, v) then
			local mySetName = formatSetName(v)
			allSetsT[v]= mySetName
			allSets[mySetName] = v
		end
	end
	return allSets, allSetsT
end

local function getActiveSets()
	local setCounts = {}
	for gearSlot, gearTable in pairs(theGear) do
		if gearTable and gearTable.setId and gearTable.setId ~= 0 then
			setCounts[gearTable.setId] = setCounts[gearTable.setId] or {0, 0, 0}
			if gearSlotsHands[gearSlot] then
				local addNum = isTwoHanded[gearTable.type] and 2 or 1
				if gearSlotsBackbar[gearSlot] then 
					setCounts[gearTable.setId][3] = setCounts[gearTable.setId][3] + addNum
				else
					setCounts[gearTable.setId][2] = setCounts[gearTable.setId][2] + addNum
				end
			else
				setCounts[gearTable.setId][1] = setCounts[gearTable.setId][1] + 1
			end
		end
	end
	return setCounts
end

local function showSetContextMenu(gearSlot)
	gearSlot = gearSlot or gearSelector.gearSlot
	if gearSlotsPoison[gearSlot] then return false, false end
	local setCounts = getActiveSets()

	local function iterateBag(bagId, tableToFill)
		for slotIndex=0, GetBagSize(bagId) do
			local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(GetItemLink(bagId, slotIndex))
			if hasSet then tableToFill[setId] = true end
		end
	end
	
	local setsInInventory = {}
	iterateBag(BAG_BACKPACK, setsInInventory)
	iterateBag(BAG_WORN, setsInInventory)
	
	local setsInBank = {}
	iterateBag(BAG_BANK, setsInBank)
	iterateBag(BAG_SUBSCRIBER_BANK, setsInBank)
	
	local function createSubMenu(setIdList)
		local idByName = {}
		local sortedNames = {}
		for setId in pairs(setIdList) do
			if doesSetFitGearSlot(gearSlot, setId) then
				local formattedSetName = formatSetName(setId)
				table.insert(sortedNames, formattedSetName)
				idByName[formattedSetName] = setId
			end
		end
		table.sort(sortedNames)
		local mySubMenu = {}
		for _, formattedSetName in pairs(sortedNames) do
			local setId = idByName[formattedSetName]			
			table.insert(mySubMenu, {label = formattedSetName, 
				callback = function() 
					CSPSWindowGearWindowSetsEdit:SetText(formattedSetName) 
					setSetId(setId)
				end})
		end
		return mySubMenu
	end
	
	ClearMenu()	
	
	AddCustomSubMenuItem(GS(SI_CHARACTER_EQUIP_TITLE), createSubMenu(setCounts)) 
	AddCustomSubMenuItem(GS(SI_GAMEPAD_INVENTORY_CATEGORY_HEADER), createSubMenu(setsInInventory)) 	
	AddCustomSubMenuItem(GS(SI_GUILDHISTORYCATEGORY2), createSubMenu(setsInBank)) 	
	
	ShowMenu()
			
end

local function setSelectorPoison(firstId, secondId)
	if not firstId then
		gearSelector.firstId = false
		return
	end
	secondId = secondId or 0
	gearSelector.firstId = firstId
	gearSelector.secondId = secondId or 0
	local itemLink = string.format(poisonItemLink, firstId, secondId)
	gearSelector.itemLink = itemLink
end


CSPSGearSelectorPoisonList = ZO_SortFilterList:Subclass()

local CSPSGearSelectorPoisonList = CSPSGearSelectorPoisonList

function CSPSGearSelectorPoisonList:New( control )
	local list = ZO_SortFilterList.New(self, control)
	list.frame = control
	list:Setup()
	return list
end

function CSPSGearSelectorPoisonList:SetupItemRow( control, data )
	control.data = data
	GetControl(control, "Name").normalColor = ZO_DEFAULT_TEXT
	GetControl(control, "Name"):SetText(data.name)
	
	GetControl(control, "Selected"):SetHidden(data.firstId ~= gearSelector.firstId or data.secondId ~= gearSelector.secondId)
	ZO_SortFilterList.SetupRow(self, control, data)
end

function CSPSGearSelectorPoisonList:Setup( )
	ZO_ScrollList_AddDataType(self.list, 1, "CSPSPOISONLISTENTRY", 28, function(control, data) self:SetupItemRow(control, data) end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self:SetAlternateRowBackgrounds(true)
	self.masterList = {}
	
	local sortKeys = {}
	self.currentSortKey = ""
	self.currentSortOrder = ZO_SORT_ORDER_UP
	self.sortFunction = function( listEntry1, listEntry2 )	return true end

	self:RefreshData()
end

local poisonSelection = {}

function CSPSGearSelectorPoisonList:BuildMasterList()
	self.masterList = {}
	local useEffectNames = not ctrGear.poisonBox2:IsHidden()
	for i, v in pairs(poisonSelection) do
		local name = CSPS.getAlternatePoisonName(v[2] or 0)
		name = useEffectNames and name or string.format(poisonItemLink, v[1] or 0, v[2] or 0)
		table.insert(self.masterList, {name = name, firstId = v[1], secondId = v[2] or 0})
	end
end

function CSPSGearSelectorPoisonList:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)
	for _, data in ipairs(self.masterList) do
		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
	end
end


function CSPS.poisonListMouseEnter(control)
	CSPS.ctrPoisonList:Row_OnMouseEnter(control)
	CSPS.showPoisonTooltip(control, nil, control.data.firstId, control.data.secondId or 0)
end

function CSPS.poisonListMouseExit(control)
	CSPS.ctrPoisonList:Row_OnMouseExit(control)
	ZO_Tooltips_HideTextTooltip()
end

function CSPS.poisonListMouseUp(control, button, upInside)
	setSelectorPoison(control.data.firstId, control.data.secondId)
	CSPS.ctrPoisonList:RefreshVisible()
end

local function fillPoisonList(myList, getFromInventory)
	
	poisonSelection = myList or {}
	if getFromInventory then
		poisonSelection = {}
		local poisonsFound = {}
		local myBags = {BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK}
		for _, bagId in pairs(myBags) do
			for slotIndex = 0, GetBagSize(bagId) do
				if GetItemType(bagId, slotIndex) == ITEMTYPE_POISON then
					local itemLink = GetItemLink(bagId, slotIndex)
					local firstId = GetItemLinkItemId(itemLink)
					local secondId = tonumber(string.match(itemLink, ":(%d+)|")) or 0
					poisonsFound[firstId] = poisonsFound[firstId] or {}
					if not poisonsFound[firstId][secondId] then
						poisonsFound[firstId][secondId] = true
						table.insert(poisonSelection, {firstId, secondId})
					end
				end
			end
		end
	end
	CSPS.ctrPoisonList:RefreshData()
end

local function fillFirstPoisonDropdown()
	ctrGear.poisonBox2:SetHidden(true)
	local invBank = string.format("%s/%s ...", GS(SI_MAIN_MENU_INVENTORY), GS(SI_CURRENCYLOCATION1))

	local typicalPoisons = {
		{76827, 138240},	-- health poison ix
		{79690, 0},	-- crown lethal poison
	}
	
	local myChoices = {
		[invBank] = function() ctrGear.poisonBox2:SetHidden(true) fillPoisonList({}, true) end,
		[GS(CSPS_Txt_StandardProfile)] = function() ctrGear.poisonBox2:SetHidden(true) fillPoisonList(typicalPoisons, false) end,
		[GS(SI_ITEMTYPEDISPLAYCATEGORY28)] = function() ctrGear.poisonBox2:SetHidden(true) fillPoisonList(CSPS.getPoisonIds(false, true), false) end, -- crown poisons
		[GS(SI_ITEM_FORMAT_STR_CRAFTED)] = function() 
				fillComboBox(ctrGear.poisonBox2.box, 
				CSPS.getPoisonIds(), false, 
				function(i,v) return string.format(poisonItemLink, v, 0) end, 
				function(i,v) fillPoisonList(CSPS.getPoisonIds(v)) end, 
				"...")
				ctrGear.poisonBox2:SetHidden(false)
		end,
	}
	
	fillComboBox(ctrGear.poisonBox1.box, 
		myChoices, false, 
		function(i,v) return i end, 
		function(i,v) v() end, 
		selectText)
	
end

function CSPS.InitGearWindow(control)
	local setText = control:GetNamedChild("SetsEdit")
	ctrGear.sets = {box = setText, label = GetControl(control, "SetsLabel")}
	ctrGear.type = GetControl(control, "Type")
	ctrGear.quality = GetControl(control, "Quality")
	ctrGear.trait = GetControl(control, "Trait")
	ctrGear.enchantment = GetControl(control, "Enchantment")
	ctrGear.window = control
	ctrGear.btnOK = GetControl(control, "Ok")
	ctrGear.gearStuff = GetControl(control, "SetItemFields")
	ctrGear.poisonStuff = GetControl(control, "PoisonFields")
	ctrGear.poisonBox1 = GetControl(control, "GeneralPoisons")
	ctrGear.poisonBox2 = GetControl(control, "PoisonsSpecific")
	ctrGear.poisonList = GetControl(control, "PoisonFieldsList")
	CSPS.ctrPoisonList = CSPSGearSelectorPoisonList:New(ctrGear.poisonStuff)
	
	setupBoxLabelPair(ctrGear.type, GS(SI_SMITHING_HEADER_ITEM))
	setupBoxLabelPair(ctrGear.quality, GS(SI_ITEMLISTSORTTYPE3))
	setupBoxLabelPair(ctrGear.trait, GS(SI_SMITHING_HEADER_TRAIT))
	setupBoxLabelPair(ctrGear.enchantment, GS(SI_ITEM_FORMAT_STR_ENCHANT_HEADER))
	setupBoxLabelPair(ctrGear.poisonBox1, "")
	setupBoxLabelPair(ctrGear.poisonBox2, "")
	
	setupBoxLabelPair(ctrGear.sets, GS(SI_ITEM_SETS_BOOK_TITLE), true) -- true not to try to setup a combobox
	
	local itemSetNameAutoComplete = ZO_AutoComplete:New(setText, NO_INCLUDE_FLAGS, NO_EXCLUDE_FLAGS, DEFAULT_ONLINE_ONLY, MAX_RESULTS, AUTO_COMPLETION_AUTOMATIC_MODE, AUTO_COMPLETION_USE_ARROWS)
	
	local setOptions = {}

	itemSetNameAutoComplete.GetAutoCompletionResults = function(autoCompleControl, text)
		setOptions = getSetAutoCompleteOptions(gearSelector.gearSlot)
		local results = {}
		if #text < 4 then 
			for i, v in pairs(setOptions) do
				if string.lower(string.sub(i, 1, #text)) == string.lower(text) then table.insert(results, i) end
				
			end
		else
			for i, v in pairs(setOptions) do
				if string.find(string.lower(i), string.lower(text), 1, true) then table.insert(results, i) end
			end
		end
		table.sort(results)
		if #results > 20 then 
			for i=21, #results do
				table.remove(results, 21)
			end
		end
		return unpack(results)
	end

	setText:SetHandler("OnTextChanged", 
		function() 
				local setId = setOptions[setText:GetText()] 
				setSetId(setId and setId or false)
			end, "getSetNameResult")
	setText:SetHandler("OnMouseUp",
		function(_, mouseButton, upInside)
			if upInside and mouseButton == 2 then showSetContextMenu(gearSelector.gearSlot) end
		end)
		
	control:GetNamedChild("BtnListSelect"):SetHandler("OnClicked",
		function()
			showSetContextMenu(gearSelector.gearSlot)
		end)
end

local function hideGearWindow(anchorControl)
	local control = WINDOW_MANAGER:GetMouseOverControl()
	for i = 1, 15 do
		if control == CSPS.gearWindow or control == ZO_Menu then return end
		local controlName = control:GetName()
		if string.sub(controlName, 1, 10) == "ZO_SubMenu" or string.sub(controlName, 1, 16) == "ZO_CustomSubMenu" then return end
		if anchorControl and control == anchorControl then return end
		if control == control:GetParent() then break end
		control = control:GetParent()
		if control == nil then break end
	end
	CSPS.gearWindow:SetHidden(true)
	EVENT_MANAGER:UnregisterForEvent(CSPS.name.."GearWinHider", EVENT_GLOBAL_MOUSE_DOWN)
end


function CSPS.showGearWin(control, gearSlot)
	if not CSPS.gearWindow then CSPS.gearWindow = WINDOW_MANAGER:CreateControlFromVirtual("CSPSWindowGearWindow", CSPSWindow, "CSPSGearWindow") end
	
	CSPS.gearWindow:ClearAnchors()
	if control then 
		CSPS.gearWindow:SetAnchor(RIGHT, control, LEFT, -10, 0)
	end
	gearSelector.gearSlot = gearSlot
	local mySetItem = theGear[gearSlot] or {}
	local _, setOptionsT = getSetAutoCompleteOptions(gearSlot)
	
	if gearSlotsPoison[gearSlot] then 
		ctrGear.gearStuff:SetHidden(true)
		ctrGear.poisonStuff:SetHidden(false)
		local myPoison = theGear[gearSlot] or {}
		setSelectorPoison(myPoison.firstId, myPoison.secondId or 0, true)
		fillFirstPoisonDropdown()
		fillPoisonList({}, false)
		ctrGear.poisonBox2:SetHidden(true)
	else
		ctrGear.gearStuff:SetHidden(false)
		ctrGear.poisonStuff:SetHidden(true)
		ctrGear.sets.box:SetText(mySetItem.setId and setOptionsT[mySetItem.setId] or "")	
		setSetId(mySetItem.setId)
	end
	
	ctrGear.btnOK:SetHandler("OnClicked", function()
		if gearSlotsPoison[gearSelector.gearSlot] then
			if gearSelector.firstId then
				local myTable = {firstId = gearSelector.firstId, secondId = gearSelector.secondId or 0, link = gearSelector.itemLink}
				theGear[gearSelector.gearSlot] = myTable
				CSPS.gearWindow:SetHidden(true)
				EVENT_MANAGER:UnregisterForEvent(CSPS.name.."GearWinHider", EVENT_GLOBAL_MOUSE_DOWN)
				CSPS.getTreeControl():RefreshVisible()
			end
		else
			if gearSelector.setId then
				local myTable = {}
				myTable.setId = gearSelector.setId
				myTable.quality = gearSelector.quality
				myTable.trait = gearSelector.trait
				myTable.enchant = gearSelector.enchant
				if not gearSlotsJewelry[gearSelector.gearSlot] then myTable.type = gearSelector.type end
				local _, itemLink = getSetItemInfo(myTable.setId, gearSelector.gearSlot, myTable.type,  myTable.trait, myTable.quality)
				local itemId = GetItemLinkItemId(itemLink)
				local crafted = GetItemSetType(setId) == ITEM_SET_TYPE_CRAFTED
				if itemLink and itemId then
					myTable.link = buildItemLink(itemId, myTable.quality, myTable.enchant and enchantGlyphs[myTable.enchant], crafted, myTable.trait)
				elseif myTable.setId == 0 then
					itemId = CSPS.getGenericItemId(gearSlotsHands[gearSelector.gearSlot] and myTable.type, gearSlotsBody[gearSelector.gearSlot] and myTable.type, gearSlot)
					myTable.link = buildItemLink(itemId, myTable.quality, myTable.enchant and enchantGlyphs[myTable.enchant], crafted, myTable.trait)
				end
				theGear[gearSelector.gearSlot] = myTable
				CSPS.gearWindow:SetHidden(true)
				EVENT_MANAGER:UnregisterForEvent(CSPS.name.."GearWinHider", EVENT_GLOBAL_MOUSE_DOWN)
				CSPS.refreshSetCount()
				CSPS.getTreeControl():RefreshVisible()
			end
		end
	end)
	EVENT_MANAGER:RegisterForEvent(CSPS.name.."GearWinHider", EVENT_GLOBAL_MOUSE_DOWN, function() hideGearWindow(control) end)
	CSPS.gearWindow:SetHidden(false)
end


function CSPS.testGearWin()
	if not CSPS.gearWindow then CSPS.gearWindow = WINDOW_MANAGER:CreateControlFromVirtual("CSPSWindowGearWindow", CSPSWindow, "CSPSGearWindow") end
	CSPS.showGearWin()
	CSPS.gearWindow:SetAnchor(TOP, CSPSWindow, BOTTOM)
end




function CSPS.buildGearString()
	local myGearString = {}
	local myGearStringUnique = {}
	for _, gearSlot in pairs(gearSlots) do
		local slotTable = theGear[gearSlot]
		if gearSlotsPoison[gearSlot] then
			table.insert(myGearString, slotTable and 
				string.format("%s:%s",
					slotTable.firstId or 0,
					slotTable.secondId or 0)
			or 0)
		elseif type(slotTable) == "table" and slotTable.mara then
			table.insert(myGearString, "mara:44904")
		else
			table.insert(myGearString, slotTable and
				-- setId, type, trait, quality, enchantId
				string.format("%d:%d:%d:%d:%d", 
					slotTable.setId or 0,
					slotTable.type or 0,
					slotTable.trait or 0,
					slotTable.quality or 0,
					slotTable.enchant or 0) or 0)
			
			table.insert(myGearStringUnique, slotTable and slotTable.itemUniqueID or 0)
			
		end
	end
	myGearStringUnique = table.concat(myGearStringUnique, ";") or nil
	myGearString = table.concat(myGearString, ";")
	
	return myGearString, myGearStringUnique
end

local function checkPoisonForTable(itemLink, myTable)
	if not myTable then return false, false end
	local firstId = GetItemLinkItemId(itemLink)
	local secondId = tonumber(string.match(itemLink, ":(%d+)|")) or 0
	return myTable.firstId == firstId, myTable.secondId == secondId
end

local function checkItemForSlot(itemLink, mySlot)
	local myTable = mySlot and theGear[mySlot]
	if not myTable then return false, false, false, false, false end
	if myTable.mara then return GetItemLinkItemId(itemLink) == 44904, true, true, true, true end
	
	local _, _, _, _, _, setId = GetItemLinkSetInfo(itemLink)
	local setIdFits = setId == myTable.setId
	
	local qualityFits = GetItemLinkDisplayQuality(itemLink) == myTable.quality 
	local enchantFits = GetItemLinkFinalEnchantId(itemLink) == myTable.enchant 
	
	local typeFits = gearSlotsBody[mySlot] and GetItemLinkArmorType(itemLink) == myTable.type or 
		gearSlotsHands[mySlot] and GetItemLinkWeaponType(itemLink) == myTable.type or gearSlotsJewelry[mySlot] or false
	
	local traitFits = myTable.trait == GetItemLinkTraitInfo(itemLink)
	
	return setIdFits, enchantFits, qualityFits, typeFits, traitFits
end

CSPS.checkItemForSlot = checkItemForSlot

local function findSetItem(mySlot, findNew)
	if not mySlot then return false, false, false, false, false end
	local bagIds = {BAG_BACKPACK, BAG_BANK,  BAG_SUBSCRIBER_BANK }
	local fitsExactly, couldFit = {}, {}
	local uniqueIdToFind = theGear[mySlot].itemUniqueID or false
	local foundNotUnique = false	
	theGear[mySlot].fitsExactly = theGear[mySlot].fitsExactly or {}
	if findNew then theGear[mySlot].fitsExactly = {} end
	local lastFits = theGear[mySlot].fitsExactly
	
	for _, bagId in pairs(bagIds) do
		fitsExactly[bagId] = {}
		couldFit[bagId] = {}
	end
	cspsD("Looking for item for slot "..mySlot)
	for _, bagId in pairs(bagIds) do
		cspsD("Looking for item in bag "..bagId)
		local isBackpack = bagId == BAG_BACKPACK 
		
		local lastFitBag = lastFits and lastFits[isBackpack]
		
		if lastFitBag and lastFitBag.itemLink == GetItemLink(lastFitBag.bagId, lastFitBag.slotIndex, 1) then
			if not uniqueIdToFind or not foundNotUnique or isBackpack then
				fitsExactly[lastFitBag.bagId] = {lastFitBag}
				cspsD("Found exact item in list of items found in previous search.")
				return fitsExactly, couldFit
			end
		else

			lastFits[isBackpack] = false
		end

		
		for slotIndex = 0, GetBagSize(bagId) do
			local itemLink = GetItemLink(bagId, slotIndex, 1)
			if uniqueIdToFind then
				local itemUniqueID = Id64ToString(GetItemUniqueId(bagId, slotIndex))
				if itemUniqueID == uniqueIdToFind then
					fitsExactly[bagId] = {{slotIndex = slotIndex, itemLink = itemLink}}
					lastFits[isBackpack] = {slotIndex = slotIndex, itemLink = itemLink, bagId = bagId}
					for _, otherBag in pairs(bagIds) do
						if otherBag ~= bagId then fitsExactly[otherBag] = {} end
					end
					cspsD("Found exact item with unique id.")
					return fitsExactly, couldFit, true -- third parameter to indicated we found the unique item
				end
			end
			local equipType = GetItemLinkEquipType(itemLink)
			if equipType and equipType ~= 0 and equipSlotToEquipType[mySlot][equipType] then
				if equipType == EQUIP_TYPE_POISON then
					local fit1, fit2 = checkPoisonForTable(itemLink, theGear[mySlot])
					if fit1 and not checkItemLevel(itemLink, true) then
						if fit2 then
							table.insert(fitsExactly[bagId], {slotIndex = slotIndex, itemLink = itemLink})
							lastFits[isBackpack] = {slotIndex = slotIndex, itemLink = itemLink, bagId = bagId}
							cspsD("Found exact potion, stop search and return lists.")
							return fitsExactly, couldFit
						else
						
							--- TODO    TODO    TODO ---
							---  differences!!
							---------------------------
							
							table.insert(couldFit[bagId], {slotIndex = slotIndex, itemLink = itemLink, differences = ""})
						end
					end
				else
					local setIdFits, enchantFits, qualityFits, typeFits, traitFits = checkItemForSlot(itemLink, mySlot)
					if setIdFits and typeFits and not checkItemLevel(itemLink, true) then
						if enchantFits and qualityFits and traitFits then
							table.insert(fitsExactly[bagId], {slotIndex = slotIndex, itemLink = itemLink})
							lastFits[isBackpack] = {slotIndex = slotIndex, itemLink = itemLink, bagId = bagId}
							if not uniqueIdToFind then 
								cspsD("Found exact item, stop search and return lists.")
								return fitsExactly, couldFit 
							elseif not isBackpack then
								foundNotUnique = true 
							end
							
						else
							local itemDifferences = {}
							if not qualityFits then 
								table.insert(itemDifferences, GS("SI_ITEMDISPLAYQUALITY", GetItemLinkDisplayQuality(itemLink)))
							end
							if not traitFits then
								table.insert(itemDifferences, GS("SI_ITEMTRAITTYPE", GetItemLinkTraitInfo(itemLink)))
							end
							if not enchantFits then 
								local _, enchantHeader = GetItemLinkEnchantInfo(itemLink)
								table.insert(itemDifferences, enchantHeader)
							end
							itemDifferences = table.concat(itemDifferences, "/")
							table.insert(couldFit[bagId], {slotIndex = slotIndex, itemLink = itemLink, differences = itemDifferences})
						end
					end
				end
			end
		end
	end
	cspsD("Search complete. Return lists.")
	return fitsExactly, couldFit
end

CSPS.findSetItem = findSetItem

local function showPoisonTooltip(control, gearSlot, firstId, secondId)
	if not firstId then return end
	local itemLink = string.format(poisonItemLink, firstId, secondId or 0)
	InitializeTooltip(InformationTooltip, control, LEFT)
	local icon = GetItemLinkIcon(itemLink)
	local r,g,b = GetItemQualityColor(GetItemLinkDisplayQuality(itemLink)):UnpackRGB()
	
	local fit1, fit2 = checkPoisonForTable(GetItemLink(BAG_WORN, gearSlot), {firstId = firstId, secondId = secondId})
	if gearSlot and (not fit1 or not fit2) then r,g,b = ZO_ERROR_COLOR:UnpackRGB() end
	
	InformationTooltip:AddLine(zo_strformat("|t28:28:<<1>>|t <<C:2>>", icon , GetItemLinkName(itemLink)), "ZoFontWinH2", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	ZO_Tooltip_AddDivider(InformationTooltip)
	
	r, g, b = ZO_NORMAL_TEXT:UnpackRGB()
	local _, _, onUseText = GetItemLinkOnUseAbilityInfo(itemLink)				
	if onUseText and onUseText ~= "" then 
		InformationTooltip:AddLine(onUseText, "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true) 
	end
	for i=1, 10 do
		local hasAb, abText = GetItemLinkTraitOnUseAbilityInfo(itemLink, i)
		if not hasAb then break end
		if abText and abText ~= "" then 
			InformationTooltip:AddLine(abText, "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true) 
		else 
			break
		end
	end
	
	
	if gearSlot and (not fit1 or not fit2) then
		local fitsExactly, couldFit = findSetItem(gearSlot)
		if #fitsExactly[BAG_BACKPACK] > 0 then
			ZO_Tooltip_AddDivider(InformationTooltip)
			r, g, b = ZO_NORMAL_TEXT:UnpackRGB()
			InformationTooltip:AddLine(string.format("|t26:26:esoui/art/tooltips/icon_bag.dds|t %s\n|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t: %s", fitsExactly[BAG_BACKPACK][1].itemLink, GS(SI_ITEM_ACTION_EQUIP)), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			control.equipItem = {BAG_BACKPACK, fitsExactly[BAG_BACKPACK][1].slotIndex, gearSlot}
		elseif #fitsExactly[BAG_BANK] > 0 or #fitsExactly[BAG_SUBSCRIBER_BANK] > 0 then
			ZO_Tooltip_AddDivider(InformationTooltip)
			r, g, b = ZO_NORMAL_TEXT:UnpackRGB()
			local fittingItem = fitsExactly[BAG_BANK][1] or fitsExactly[BAG_SUBSCRIBER_BANK][1]
			local bagId = #fitsExactly[BAG_BANK] > 0 and BAG_BANK or BAG_SUBSCRIBER_BANK
			control.retrieveItem = {bagId, fittingItem.slotIndex}
			InformationTooltip:AddLine(string.format("|t26:26:esoui/art/tooltips/icon_bank.dds|t %s\n|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t: %s", fittingItem.itemLink, GS(SI_BANK_WITHDRAW)), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		end
	end
end

CSPS.showPoisonTooltip = showPoisonTooltip	

local function showSetItemTooltip(control, setId, gearSlot, itemType,  traitType, itemQuality, enchantId)

	if not theGear[gearSlot] then return false end
	local parentControl = control:GetParent()
	if WINDOW_MANAGER:GetMouseOverControl():GetParent() ~= parentControl then return false end
	
	InitializeTooltip(InformationTooltip, control, LEFT)
	
	local icon, itemLink, pieceId, setSlot = getSetItemInfo(setId, gearSlot, itemType,  traitType, itemQuality)
	local itemId = GetItemLinkItemId(itemLink)
	if setId == 0 then 
		itemId = CSPS.getGenericItemId(gearSlotsHands[gearSlot] and itemType, gearSlotsBody[gearSlot] and itemType, gearSlot) 
	end
	
	local crafted = GetItemSetType(setId) == ITEM_SET_TYPE_CRAFTED
	itemLink = buildItemLink(itemId, itemQuality, enchantId and enchantGlyphs[enchantId], crafted, traitType)
	if setId == 0 then icon = GetItemLinkIcon(itemLink) end
	
	local qualityColor = itemQuality and GetItemQualityColor(itemQuality) or ZO_NORMAL_TEXT
	local r,g,b = qualityColor:UnpackRGB()
	
	local wornItem = GetItemLink(BAG_WORN, gearSlot)
	local setIdFits, enchantFits, qualityFits, typeFits, traitFits = checkItemForSlot(wornItem, gearSlot)
	local warnLevel, levelText = checkItemLevel(wornItem)
	
	local trueFalseColors = {[true] = ZO_SUCCEEDED_TEXT, [false] = ZO_ERROR_COLOR}
	if not setIdFits then r,g,b = ZO_ERROR_COLOR:UnpackRGB() end
	
	InformationTooltip:AddLine(zo_strformat("|t28:28:<<1>>|t <<C:2>>", icon ,  GetItemLinkName(itemLink)), "ZoFontWinH2", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	
	local qualityText = GS("SI_ITEMDISPLAYQUALITY", itemQuality or 1)
	qualityText = trueFalseColors[qualityFits]:Colorize(qualityText)
	if warnLevel then
		qualityText = string.format("%s, %s", qualityText, trueFalseColors[false]:Colorize(levelText))
	end
	if gearSlotsBody[gearSlot] then 
		qualityText = string.format("%s, %s", trueFalseColors[typeFits]:Colorize(GS("SI_ARMORTYPE", itemType)), qualityText)
	end
	r,g,b = ZO_NORMAL_TEXT:UnpackRGB()
	InformationTooltip:AddLine(qualityText, "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	
	ZO_Tooltip_AddDivider(InformationTooltip)
		
	if traitType then
		local _, traitDescription = GetItemLinkTraitInfo(itemLink) 
		r,g,b =  trueFalseColors[traitFits]:UnpackRGB()
		local traitName = zo_strformat("<<Z:1>>", GS("SI_ITEMTRAITTYPE", traitType))
		if traitType > 0 then traitName = string.format("%s\n%s", traitName, traitDescription) end
		InformationTooltip:AddLine(traitName, "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	end
	
	r,g,b =  trueFalseColors[enchantFits]:UnpackRGB()
	local _, enchantHeader, enchantDescription = GetItemLinkEnchantInfo(itemLink)
	local enchantText = string.format("%s\n%s", string.upper(enchantHeader), enchantDescription)
	if enchantHeader == "" then	enchantText = string.upper(GS(SI_ENCHANTMENTSEARCHCATEGORYTYPE0)) end
	InformationTooltip:AddLine(enchantText, "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true) 

	local hasSet, _, numBonuses, _, _, linkSetId = GetItemLinkSetInfo(itemLink)
	
	if hasSet then
		local setCount = theGear[gearSlot].setCount
		local numActive = setCount and math.max(setCount[1] + setCount[2], setCount[1] + setCount[3]) or 42
		
		local activeBoni, inactiveBoni = {}, {}
		for i=1, numBonuses do
			local numRequired, bonusDescription = GetItemLinkSetBonusInfo(itemLink, false, i)
			if numActive >= numRequired then 
				table.insert(activeBoni, (string.gsub(bonusDescription, "\n\r\n", " ")))
			else
				table.insert(inactiveBoni, (string.gsub(bonusDescription, "\n\r\n", " ")))
			end
		end
		if #activeBoni > 0 then
			r, g, b = ZO_SELECTED_TEXT:UnpackRGB()
			InformationTooltip:AddLine(table.concat(activeBoni, "\n"), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		end
		if #inactiveBoni > 0 then
			r, g, b = ZO_DISABLED_TEXT:UnpackRGB()
			InformationTooltip:AddLine(table.concat(inactiveBoni, "\n"), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		end
	end
	
	if not (setIdFits and enchantFits and qualityFits and typeFits and traitFits) then 
		local fitsExactly, couldFit, foundUnique = findSetItem(gearSlot)
		if #fitsExactly[BAG_BACKPACK] > 0 then
			ZO_Tooltip_AddDivider(InformationTooltip)
			r, g, b = ZO_NORMAL_TEXT:UnpackRGB()
			local iconUnique = foundUnique and " |t26:26:esoui/art/tooltips/icon_lock.dds|t" or ""
			InformationTooltip:AddLine(string.format("|t26:26:esoui/art/tooltips/icon_bag.dds|t%s %s\n|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t %s", iconUnique, fitsExactly[BAG_BACKPACK][1].itemLink, GS(SI_ITEM_ACTION_EQUIP)), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			parentControl.equipItem = {BAG_BACKPACK, fitsExactly[BAG_BACKPACK][1].slotIndex, gearSlot}
		elseif #fitsExactly[BAG_BANK] > 0 or #fitsExactly[BAG_SUBSCRIBER_BANK] > 0 then
			ZO_Tooltip_AddDivider(InformationTooltip)
			r, g, b = ZO_NORMAL_TEXT:UnpackRGB()
			local fittingItem = fitsExactly[BAG_BANK][1] or fitsExactly[BAG_SUBSCRIBER_BANK][1]
			local myItemText = string.format("|t26:26:esoui/art/tooltips/icon_bank.dds|t %s", fittingItem.itemLink)
			
			if GetInteractionType() == INTERACTION_BANK then
				myItemText = string.format("%s\n|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t %s", myItemText, GS(SI_ITEM_ACTION_BANK_WITHDRAW))
				local bagId = fitsExactly[BAG_BANK][1] and BAG_BANK or BAG_SUBSCRIBER_BANK
				parentControl.retrieveItem = {bagId, fittingItem.slotIndex}				
			end
			
			InformationTooltip:AddLine(myItemText, "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			
		elseif #couldFit[BAG_BACKPACK] > 0 or #couldFit[BAG_BANK] > 0 or #couldFit[BAG_SUBSCRIBER_BANK] > 0 then
			ZO_Tooltip_AddDivider(InformationTooltip)
			r, g, b = ZO_ORANGE:UnpackRGB()
			
			for i, v in pairs(couldFit[BAG_BACKPACK]) do
				local myItemText = string.format("|t26:26:esoui/art/tooltips/icon_bag.dds:inheritcolor|t %s (%s)", 
					v.itemLink, ZO_ERROR_COLOR:Colorize(v.differences))
				InformationTooltip:AddLine(myItemText, "ZoFontGameSmall", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			end
			
			for i, v in pairs(couldFit[BAG_BANK]) do
				local myItemText = string.format("|t26:26:esoui/art/tooltips/icon_bank.dds:inheritcolor|t %s (%s)", 
					v.itemLink, ZO_ERROR_COLOR:Colorize(v.differences))
				InformationTooltip:AddLine(myItemText, "ZoFontGameSmall", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			end
			
			for i, v in pairs(couldFit[BAG_SUBSCRIBER_BANK]) do
				local myItemText = string.format("|t26:26:esoui/art/tooltips/icon_bank.dds:inheritcolor|t %s (%s)", 
					v.itemLink, ZO_ERROR_COLOR:Colorize(v.differences))
				InformationTooltip:AddLine(myItemText, "ZoFontGameSmall", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			end
		else
			r,g,b = ZO_NORMAL_TEXT:UnpackRGB()
			local myItemText = false
			if GetItemSetType(setId) == ITEM_SET_TYPE_CRAFTED then
				myItemText = GS(SI_ITEM_FORMAT_STR_CRAFTED)
				local traitsNeeded = LibSets.GetTraitsNeeded(setId)
				if traitsNeeded then 
					local canCraft = CSPS.canCraftSetItem(setId, gearSlot, gearSlotsBody[gearSlot] and itemType, gearSlotsHands[gearSlot] and itemType)
					if canCraft ~= nil then traitsNeeded = trueFalseColors[canCraft]:Colorize(traitsNeeded) end
					myItemText = string.format("%s (%s)", myItemText, traitsNeeded) 
				end
				local mySetZoneIds = LibSets.GetZoneIds(setId)
				if mySetZoneIds then
					local zoneIdsChecked = {}
					local setZoneNames = {}
					for i, v in pairs(mySetZoneIds) do
						if not zoneIdsChecked[v] then
							zoneIdsChecked[v] = true
							table.insert(setZoneNames, zo_strformat("<<C:1>>", GetZoneNameById(v)))
						end
					end
					if #setZoneNames > 0 then
						myItemText = string.format("%s:\n%s", myItemText, table.concat(setZoneNames, ", "))
					end
				end
				local traitKnown = CSPS.canCraftTrait(gearSlot, gearSlotsBody[gearSlot] and itemType, gearSlotsHands[gearSlot] and itemType, traitType)
				if traitKnown ~= nil then 
					myItemText = string.format("%s\n%s: %s", myItemText, 
						GS(SI_MASTER_WRIT_DESCRIPTION_TRAIT), trueFalseColors[traitKnown]:Colorize(GS("SI_ITEMTRAITTYPE", traitType)))
				end
			else
				local categoryId = GetItemSetCollectionCategoryId(setId)
				if categoryId and categoryId ~= 0 then
					myItemText = zo_strformat("<<C:1>>: <<C:2>>", 
						GetItemSetCollectionCategoryName(GetItemSetCollectionCategoryParentId(categoryId)),
						GetItemSetCollectionCategoryName(categoryId))
				end	
				if setSlot and IsItemSetCollectionSlotUnlocked(setId, setSlot) then
					local reconCurrencies = {} -- all of this is not needed right now, but it seems like they might add more currencies some day...
					for i=1, GetNumItemReconstructionCurrencyOptions() do
						local currencyType = GetItemReconstructionCurrencyOptionType(i)
						local cost = GetItemReconstructionCurrencyOptionCost(setId, currencyType)
						local currencyIcon = ZO_Currency_GetPlatformCurrencyIcon(currencyType)
						if currencyType ~= 0 then table.insert(reconCurrencies, 
							string.format("%s |t22:22:%s|t", cost, currencyIcon))
						end
					end
					if #reconCurrencies > 0 then
						myItemText = myItemText and myItemText.."\n" or ""
						myItemText = string.format("%s%s: %s", myItemText, GS(SI_RETRAIT_STATION_PERFORM_RECONSTRUCT), table.concat(reconCurrencies, ", "))
						local traitKnown = CSPS.canCraftTrait(gearSlot, gearSlotsBody[gearSlot] and itemType, gearSlotsHands[gearSlot] and itemType, traitType)
						if traitKnown ~= nil then 
							myItemText = string.format("%s\n%s: %s", myItemText, 
								GS(SI_MASTER_WRIT_DESCRIPTION_TRAIT), trueFalseColors[traitKnown]:Colorize(GS("SI_ITEMTRAITTYPE", traitType)))
						end
					end
				end
			end
			if myItemText then 
				ZO_Tooltip_AddDivider(InformationTooltip)
				InformationTooltip:AddLine(myItemText, "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true) 
			end
		end
	end
	InformationTooltip:AddLine(GS(CSPS_QS_TT_Edit))
end

function CSPS.extractGearString(myGearString, myGearStringUnique)
	local myGear = {}
	if not myGearString or myGearString == "" then
		for i, gearSlot in pairs(gearSlots) do
			myGear[gearSlot] = false	
		end
		return myGear
	end
	local singleUniqueStrings = myGearStringUnique and {SplitString(";", myGearStringUnique)} or {}
	local singleGearStrings = {SplitString(";", myGearString)}
	for i, gearSlot in pairs(gearSlots) do
		if singleGearStrings[i] == "0" then
			myGear[gearSlot] = false		
		else
			local singleSlotTable = {SplitString(":", singleGearStrings[i])}
			local itemUniqueID = singleUniqueStrings[i] ~= "0" and singleUniqueStrings[i]
			if gearSlotsPoison[gearSlot] then
				myGear[gearSlot] = {
					firstId = tonumber(singleSlotTable[1]) or 0,
					secondId = tonumber(singleSlotTable[2]) or 0,
				}
			elseif singleSlotTable[1] == "mara" then
				myGear[gearSlot] = {
					setId = 44904,
					mara = true,
					link = buildItemLink(44904),
					itemUniqueID = itemUniqueID,
				}
			else
				myGear[gearSlot] = {
					setId = tonumber(singleSlotTable[1]),
					type = tonumber(singleSlotTable[2]),
					trait = tonumber(singleSlotTable[3]),
					quality = tonumber(singleSlotTable[4]),
					enchant = tonumber(singleSlotTable[5]),
					itemUniqueID = itemUniqueID,
				}
				local gearItem = myGear[gearSlot]
				local _, itemLink = getSetItemInfo(gearItem.setId, gearSlot, gearItem.type,  gearItem.trait, gearItem.quality)
				gearItem.link = itemLink
				
				if gearSlotsJewelry[gearSlot] then myGear[gearSlot].type = nil end
			end
		end
	end
	return myGear
end

local function setMara(gearSlot, itemLink, itemUniqueID)
	theGear[gearSlot] = {mara = true, setId = 44904, link = itemLink, itemUniqueID = itemUniqueID}
end

local function setPoisonFromIdAndLink(gearSlot, itemLink, itemId)
	theGear[gearSlot] = {
		firstId = itemId,
		secondId = tonumber(string.match(itemLink, ":(%d+)|")) or 0
	}
end

local function setArmorOrWeaponFromLink(gearSlot, itemLink, itemUniqueID)
	theGear[gearSlot] = {}
	local slotTable = theGear[gearSlot]
	local hasSetInfo, _, _, _, neededNumber, itemSetId = GetItemLinkSetInfo(itemLink, false)
	slotTable.setId = hasSetInfo and itemSetId or 0
	slotTable.quality = GetItemLinkDisplayQuality(itemLink)
	if slotTable.quality == ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE then slotTable.mystic = true end
	local enchantId = GetItemLinkFinalEnchantId(itemLink)
	slotTable.enchant = enchantId
	slotTable.trait = GetItemLinkTraitInfo(itemLink)
	slotTable.link = itemLink
	slotTable.itemUniqueID = itemUniqueID
	if gearSlotsBody[gearSlot] then
		slotTable.type = GetItemLinkArmorType(itemLink)
	elseif gearSlotsHands[gearSlot] then
		local weaponType = GetItemLinkWeaponType(itemLink)
		slotTable.type = weaponType
	end
end

local function removeDuplicateUniqueId(itemUniqueID)
	for gearSlot, gearData in pairs(theGear) do
		if gearData and gearData.itemUniqueID == itemUniqueID then theGear[gearSlot] = false end
	end
end

local function receiveDrag(gearSlot)
	local acceptedCursorContentTypes = {[MOUSE_CONTENT_INVENTORY_ITEM] = true, [MOUSE_CONTENT_EQUIPPED_ITEM] = true}
	if not acceptedCursorContentTypes[GetCursorContentType()] then return false end

	local bagId = GetCursorBagId()
	local slotIndex = GetCursorSlotIndex()
	ClearCursor()
		
	local itemLink = GetItemLink(bagId, slotIndex)
	local itemType = GetItemType(bagId, slotIndex)
	local itemUniqueID = Id64ToString(GetItemUniqueId(bagId, slotIndex))
	itemUniqueID = itemUniqueID ~= "0" and itemUniqueID or false
	local itemId = GetItemId(bagId, slotIndex)
	
	if gearSlotsPoison[gearSlot] then
		if itemType ~= ITEMTYPE_POISON then return false end
		setPoisonFromIdAndLink(gearSlot, itemLink, itemId)
		CSPS:getTreeControl():RefreshVisible()
		
		return true
	end
	
	local equipType = GetItemLinkEquipType(itemLink)
	
	if gearSlotsHands[gearSlot] then
		if itemType ~= ITEMTYPE_WEAPON then return false end
		if not equipSlotToEquipType[gearSlot][equipType] then return false end
		local weaponType = GetItemLinkWeaponType(itemLink)
		local slotToClearReverse = {
			[EQUIP_SLOT_BACKUP_OFF]  = EQUIP_SLOT_BACKUP_MAIN,
			[EQUIP_SLOT_OFF_HAND] = EQUIP_SLOT_MAIN_HAND,
		}
		if isTwoHanded[weaponType] then
			local slotToClear = {
				[EQUIP_SLOT_BACKUP_MAIN]  = EQUIP_SLOT_BACKUP_OFF,
				[EQUIP_SLOT_MAIN_HAND] = EQUIP_SLOT_OFF_HAND,
			}
			if slotToClear[gearSlot] then theGear[slotToClear[gearSlot]] = false end
		elseif slotToClearReverse[gearSlot] then
			local weaponTypeMain = theGear[slotToClearReverse[gearSlot]]
			weaponTypeMain = weaponTypeMain and weaponTypeMain.type
			weaponTypeMain = weaponTypeMain and isTwoHanded[weaponTypeMain]
			if weaponTypeMain then theGear[slotToClearReverse[gearSlot]] = false end
		end
		if itemUniqueID then removeDuplicateUniqueId(itemUniqueID) end
		setArmorOrWeaponFromLink(gearSlot, itemLink, itemUniqueID)
		CSPS.refreshSetCount()
		CSPS:getTreeControl():RefreshVisible()
		return true
	end
	
	if itemType ~= ITEMTYPE_ARMOR then return false end
	if not equipSlotToEquipType[gearSlot][equipType] then return false end
	
	if itemId == 44904 then 
		if itemUniqueID then removeDuplicateUniqueId(itemUniqueID) end
		setMara(gearSlot, itemLink, itemUniqueID) 
	else	
		if itemUniqueID then removeDuplicateUniqueId(itemUniqueID) end
		setArmorOrWeaponFromLink(gearSlot, itemLink, itemUniqueID)
	end
	CSPS.refreshSetCount()
	CSPS:getTreeControl():RefreshVisible()
	return true
		
end

local function NodeSetupGear(node, control, data, open, userRequested, enabled)
	--Entries in data: Text, Value, entrColor
	local mySlot = data.gearSlot
	local myTable = theGear[mySlot]
	local itemFitIndicators = {
			{texture = "esoui/art/inventory/inventory_icon_equipped.dds", color = ZO_SUCCEEDED_TEXT}, -- result = 1, item is equipped
			{texture = "esoui/art/inventory/newitem_icon.dds", color = ZO_ORANGE},  -- result = 2, item needs inspection
			{texture = "esoui/art/inventory/inventory_sell_forbidden_icon.dds", color = ZO_ERROR_COLOR}, -- result = 3, item is not available
			{texture = "esoui/art/tooltips/icon_bag.dds", color = GetItemQualityColor(ITEM_QUALITY_ARCANE)},  -- result = 4, item is in inventory
			{texture = "esoui/art/tooltips/icon_bank.dds", color = GetItemQualityColor(ITEM_QUALITY_ARTIFACT)}, -- result = 5, item is in bank
	}
	
	control.receiveDragFunction = function() receiveDrag(mySlot) end
	
	if myTable then
		local myItemFitIndicator = itemFitIndicators[3]		
		local showIconUnique = false
		
		if gearSlotsPoison[mySlot] then
			local itemLink = string.format(poisonItemLink, myTable.firstId or 0, myTable.secondId or 0)
			control.ctrSetName:SetText(itemLink)
			control.ctrIcon:SetTexture(GetItemLinkIcon(itemLink))
			control.ctrTrait:SetHidden(true)
			control.ctrEnchantment:SetHidden(true)
			
			local fit1, fit2 = checkPoisonForTable(GetItemLink(BAG_WORN, mySlot), myTable)
			if fit1 then
				myItemFitIndicator = itemFitIndicators[fit2 and 1 or 2]
			else
				local fitsExactly, couldFit, fitsUnique = findSetItem(mySlot)
				if #fitsExactly[BAG_BACKPACK] > 0 then
					myItemFitIndicator = itemFitIndicators[4]
				elseif #fitsExactly[BAG_BANK] > 0 or #fitsExactly[BAG_SUBSCRIBER_BANK] > 0 then
					myItemFitIndicator = itemFitIndicators[5]
				else
					myItemFitIndicator = itemFitIndicators[3]
				end
			end
			
			control.tooltipFunction = function(self)
				if not theGear[mySlot] then ZO_Tooltips_ShowTextTooltip(self, TOP, GS(CSPS_QS_TT_Edit)) return end
				showPoisonTooltip(control.ctrEnchantment, mySlot, myTable.firstId, myTable.secondId)
				InformationTooltip:AddLine(GS(CSPS_QS_TT_Edit))
			end
			
			control.tooltipExitFunction = function()
				control.retrieveItem = nil
				control.equipItem = nil
				ZO_Tooltips_HideTextTooltip()
			end
			control:SetHandler("OnMouseUp", function(_, mouseButton, upInside)
				if not upInside then return end
				if mouseButton == 1 then
					if control.equipItem then 
						EquipItem(unpack(control.equipItem))
						zo_callLater(function() showPoisonTooltip(control.ctrEnchantment, mySlot, myTable.firstId, myTable.secondId) end, 420)
						InformationTooltip:AddLine(GS(CSPS_QS_TT_Edit))
					elseif control.retrieveItem then
						if GetInteractionType() == INTERACTION_BANK then
							if IsProtectedFunction("RequestMoveItem") then
								CallSecureProtected("RequestMoveItem", control.retrieveItem[1], control.retrieveItem[2], BAG_BACKPACK, FindFirstEmptySlotInBag(BAG_BACKPACK), 1)
							else
								RequestMoveItem(control.retrieveItem[1], control.retrieveItem[2], BAG_BACKPACK, FindFirstEmptySlotInBag(BAG_BACKPACK), 1)
							end
						end
						zo_callLater(function() showPoisonTooltip(control.ctrEnchantment, mySlot, myTable.firstId, myTable.secondId) end, 420)
					end
				elseif mouseButton == 2 and control.editFunc then
					control.editFunc()
				end
			end)
		else
			control.ctrTrait:SetHidden(false)
			control.ctrEnchantment:SetHidden(false)			
			--control.ctrSetName:SetText(zo_strformat("<<C:1>>", GetItemSetName(myTable.setId)))
			if myTable.setCountF and not CSPS.savedVariables.settings.hideNumSetItems then
				control.ctrSetName:SetText(string.format("%s (%s)", myTable.link, myTable.setCountF))
			else
				control.ctrSetName:SetText(myTable.link)
			end
			local itemIcon = getSetItemInfo(myTable.setId, mySlot, myTable.type)
			if myTable.mara or myTable.setId == 0 then
				itemIcon = GetItemLinkIcon(myTable.link)
			end
			control.ctrIcon:SetTexture(itemIcon)
			control.ctrTrait:SetText(GS("SI_ITEMTRAITTYPE", myTable.trait))
			control.ctrEnchantment:SetText(enchantNames[myTable.enchant])
			--control.ctrBtnEdit:SetText("-") 
			local ttdc1, ttdc2, ttdc3, ttdc4 = false, false, false, false
			control.tooltipFunction = function()
				ttdc1, ttdc2, ttdc3, ttdc4 = InformationTooltip:GetDimensionConstraints()
				if not theGear[mySlot] then return end
				InformationTooltip:SetDimensionConstraints(ttdc1, ttdc2, 420, ttdc4)
			-- showSetItemTooltip(control,                setId,      gearSlot, itemType,  traitType,          quality, enchantId)
				showSetItemTooltip(control.ctrEnchantment, myTable.setId, mySlot, myTable.type, myTable.trait, myTable.quality, myTable.enchant)
			end
			
			control.tooltipExitFunction = function()
				if ttdc1 then
					InformationTooltip:SetDimensionConstraints(ttdc1, ttdc2, ttdc3, ttdc4)
				end
				control.retrieveItem = nil
				control.equipItem = nil
				ZO_Tooltips_HideTextTooltip()
			end
			
			control:SetHandler("OnMouseUp", function(_, mouseButton, upInside)
				if not upInside then return end
				if mouseButton == 1 then
					if control.equipItem then
						EquipItem(unpack(control.equipItem))
						zo_callLater(function() showSetItemTooltip(control.ctrEnchantment, myTable.setId, mySlot, myTable.type, myTable.trait, myTable.quality, myTable.enchant) end, 420)
					elseif control.retrieveItem then
						if GetInteractionType() == INTERACTION_BANK then
							if IsProtectedFunction("RequestMoveItem") then
								CallSecureProtected("RequestMoveItem", control.retrieveItem[1], control.retrieveItem[2], BAG_BACKPACK, FindFirstEmptySlotInBag(BAG_BACKPACK), 1)
							else
								RequestMoveItem(control.retrieveItem[1], control.retrieveItem[2], BAG_BACKPACK, FindFirstEmptySlotInBag(BAG_BACKPACK), 1)
							end
						end
						zo_callLater(function() showSetItemTooltip(control.ctrEnchantment, myTable.setId, mySlot, myTable.type, myTable.trait, myTable.quality, myTable.enchant) end, 420)
					end
				elseif mouseButton == 2 and control.editFunc then
					control.editFunc()	
				end
			end)
			
			local setIdFits, enchantFits, qualityFits, typeFits, traitFits = checkItemForSlot(GetItemLink(BAG_WORN, mySlot), mySlot)
	 		

			if setIdFits then
				if enchantFits then control.ctrEnchantment:SetColor(ZO_SUCCEEDED_TEXT:UnpackRGB()) else control.ctrEnchantment:SetColor(ZO_ERROR_COLOR:UnpackRGB()) end 
				if traitFits then control.ctrTrait:SetColor(ZO_SUCCEEDED_TEXT:UnpackRGB()) else control.ctrTrait:SetColor(ZO_ERROR_COLOR:UnpackRGB()) end 
				myItemFitIndicator = itemFitIndicators[enchantFits and traitFits and qualityFits and typeFits and 1 or 2]
			else
				control.ctrEnchantment:SetColor(ZO_NORMAL_TEXT:UnpackRGB())
				control.ctrTrait:SetColor(ZO_NORMAL_TEXT:UnpackRGB())
				
				local fitsExactly, couldFit, foundUnique = findSetItem(mySlot)
				showIconUnique = foundUnique or false
				if #fitsExactly[BAG_BACKPACK] > 0 then
					myItemFitIndicator = itemFitIndicators[4]
				elseif #fitsExactly[BAG_BANK] > 0 or #fitsExactly[BAG_SUBSCRIBER_BANK] > 0 then
					myItemFitIndicator = itemFitIndicators[5]
				elseif #couldFit[BAG_BACKPACK] > 0 or #couldFit[BAG_BANK] > 0 or #couldFit[BAG_SUBSCRIBER_BANK] > 0 then
					myItemFitIndicator = itemFitIndicators[2]
				end
			end
			

		end
		
		control.ctrIndicator:SetTexture(myItemFitIndicator.texture)
		control.ctrIndicator:SetColor(myItemFitIndicator.color:UnpackRGB())
		control.ctrIndicator2:SetHidden(not showIconUnique)
		
		control.ctrIndicator:SetHidden(false)
	else
		--control:SetHidden(true)
		--control:SetHeight(0)
		control.tooltipFunction = function(self) if control.editFunc then ZO_Tooltips_ShowTextTooltip(self, TOP, GS(CSPS_QS_TT_Edit)) end end
		control.tooltipExitFunction = function() ZO_Tooltips_HideTextTooltip() end
		control:SetHandler("OnMouseUp", 
			function(_, mouseButton, upInside)
				if not upInside then return end
				if mouseButton == 2 and control.editFunc then control.editFunc() end 
			end)
		control.ctrSetName:SetText("-")
		control.ctrIcon:SetTexture(string.format("esoui/art/characterwindow/%s.dds", gearSlotIcons[mySlot]))
		control.ctrTrait:SetHidden(true)
		control.ctrEnchantment:SetHidden(true)		
		control.ctrIndicator:SetHidden(true)
		control.ctrIndicator2:SetHidden(true)
	end			

	if mySlot == EQUIP_SLOT_BACKUP_OFF and theGear[EQUIP_SLOT_BACKUP_MAIN] and theGear[EQUIP_SLOT_BACKUP_MAIN].type and isTwoHanded[theGear[EQUIP_SLOT_BACKUP_MAIN].type] or
		mySlot == EQUIP_SLOT_OFF_HAND and theGear[EQUIP_SLOT_MAIN_HAND] and theGear[EQUIP_SLOT_MAIN_HAND].type and isTwoHanded[theGear[EQUIP_SLOT_MAIN_HAND].type] then
		control.editFunc = false
		control.ctrBtnEdit:SetHidden(true)
		control.ctrIcon:SetMouseEnabled(false)
		control.ctrSetName:SetMouseEnabled(false)
	else
		control.editFunc = 
			function()
				if CSPS.gearWindow and not CSPS.gearWindow:IsHidden() and gearSelector.gearSlot == mySlot then 
					EVENT_MANAGER:UnregisterForEvent(CSPS.name.."GearWinHider", EVENT_GLOBAL_MOUSE_DOWN)
					CSPS.gearWindow:SetHidden(true)
					return
				end
				CSPS.showGearWin(control.ctrBtnEdit, mySlot)
			end
		control.ctrBtnEdit:SetHandler("OnClicked", control.editFunc)
		control.ctrBtnEdit:SetHidden(false)
		control.ctrIcon:SetMouseEnabled(true)
		control.ctrSetName:SetMouseEnabled(true)		
	end
end

local function doesWornItemFitSlot(gearSlot)
	if gearSlot == EQUIP_SLOT_POISON or gearSlot == EQUIP_SLOT_BACKUP_POISON then
		local fit1, fit2 = checkPoisonForTable(GetItemLink(BAG_WORN, gearSlot), theGear[gearSlot])
		return fit1 and fit2
	else
		local setIdFits, enchantFits, qualityFits, typeFits, traitFits = checkItemForSlot(GetItemLink(BAG_WORN, gearSlot), gearSlot)
		return setIdFits and enchantFits and qualityFits and typeFits and traitFits
	end
end

CSPS.doesWornItemFitSlot = doesWornItemFitSlot

local function equipAllFittingGear()
	local alreadyEquipped = {}
	for gearSlot, gearTable in pairs(theGear) do
		if gearTable then
			
			if not doesWornItemFitSlot(gearSlot) then
				cspsD("Slot to change: "..gearSlot)
				local fitsExactly, couldFit = findSetItem(gearSlot, true)
				cspsD("Fits exactly:")
				cspsD(fitsExactly)
				cspsD("Could fit:")
				cspsD(couldFit)
				if #fitsExactly[BAG_BACKPACK] > 0 then
					cspsD(fitsExactly[BAG_BACKPACK])
					for _, fittingItem in pairs(fitsExactly[BAG_BACKPACK]) do
						-- since we`re equipping all items at once if there is one item fitting two slots (possible for rings or weapons) we have to check
						-- we have to iterate over the fitting items because they might still be there but already queed to equip
						if not alreadyEquipped[fittingItem.slotIndex] then
							EquipItem(BAG_BACKPACK, fittingItem.slotIndex, gearSlot)
							alreadyEquipped[fittingItem.slotIndex] = true
							break
						end
					end
				end
			end
		end
	end
end

CSPS.equipAllFittingGear = equipAllFittingGear

local function retrieveAllFittingGear()

	if GetInteractionType() ~= INTERACTION_BANK then return false end
	
	local itemsToRetrieve = {}
	for gearSlot, gearTable in pairs(theGear) do
		if gearTable then
			if not doesWornItemFitSlot(gearSlot) then
				local fitsExactly, couldFit = findSetItem(gearSlot)
				if #fitsExactly[BAG_BACKPACK] == 0 then 
					if #fitsExactly[BAG_BANK] > 0 then
						table.insert(itemsToRetrieve, 
							{bagId = BAG_BANK, 
							slotIndex = fitsExactly[BAG_BANK][1].slotIndex, 
							itemLink = fitsExactly[BAG_BANK][1].itemLink})
					elseif #fitsExactly[BAG_SUBSCRIBER_BANK] > 0 then
						table.insert(itemsToRetrieve, 
							{bagId = BAG_SUBSCRIBER_BANK, 
							slotIndex = fitsExactly[BAG_SUBSCRIBER_BANK][1].slotIndex, 
							itemLink = fitsExactly[BAG_SUBSCRIBER_BANK][1].itemLink})
					end
				end	
			end
		end
	end
		
	local function transferItem(sourceBag, sourceSlot)
		local destSlot = FindFirstEmptySlotInBag(BAG_BACKPACK)
		if not destSlot then return false end
		if IsProtectedFunction("RequestMoveItem") then
			CallSecureProtected("RequestMoveItem", sourceBag, sourceSlot, BAG_BACKPACK, destSlot, 1)
		else
			RequestMoveItem(sourceBag, sourceSlot, BAG_BACKPACK, destSlot, 1)
		end
		return destSlot
	end
	
	local function transferNext()			
		local nextItem = itemsToRetrieve[1]
		local destSlot = transferItem(nextItem.bagId, nextItem.slotIndex)
		if not destSlot then d(GS(SI_ACTIONRESULT3430)) return end
		local myTries = 1
		local function checkSlot(myTries)
			myTries = myTries + 1
			zo_callLater(function()
				if GetItemLink(BAG_BACKPACK, destSlot, 1) ~= nextItem.itemLink then
					if myTries < 20 and GetInteractionType() == INTERACTION_BANK then 
						checkSlot(myTries) 
					else
						d(GS(SI_TRANSACTION_FAILED_TITLE))
					end
				else
					table.remove(itemsToRetrieve, 1)
					if #itemsToRetrieve > 0 then transferNext() end
				end
			end, 50)
		end
		checkSlot(myTries)
	end
	if #itemsToRetrieve > 0 then transferNext() end
end

function CSPS.setupGearSection(control, node, data)
	local canRetrieve = false
	local canEquip = false
	if node:IsOpen() and not data.fillContent then
		for gearSlot, gearTable in pairs(theGear) do
			if gearTable then
				if not doesWornItemFitSlot(gearSlot) then
					local fitsExactly, couldFit = findSetItem(gearSlot)
					if #fitsExactly[BAG_BACKPACK] > 0 then
						canEquip = true
					elseif #fitsExactly[BAG_BANK] > 0 or #fitsExactly[BAG_SUBSCRIBER_BANK] > 0 then
						canRetrieve = true
					end
				end
			end
		end
		canRetrieve = canRetrieve and GetInteractionType() == INTERACTION_BANK
	end
	local btnApply = GetControl(control, "BtnApply")
	local btnRetrieve = GetControl(control, "BtnRetrieve")
	
	btnApply:SetHidden(not canEquip)
	btnApply:SetWidth(canEquip and 21 or 0)
	btnApply:SetHandler("OnClicked", equipAllFittingGear)
	btnApply:SetHandler("OnMouseEnter", function() ZO_Tooltips_ShowTextTooltip(btnApply, RIGHT, GS(SI_ITEM_ACTION_EQUIP)) end)
	btnRetrieve:SetHidden(not canRetrieve)
	btnRetrieve:SetWidth(canRetrieve and 21 or 0)
	btnRetrieve:SetHandler("OnClicked", retrieveAllFittingGear)
	btnRetrieve:SetHandler("OnMouseEnter", function() ZO_Tooltips_ShowTextTooltip(btnRetrieve, RIGHT, GS(SI_BANK_WITHDRAW)) end)
end


function CSPS.setupGearTree()
	CSPS.getCurrentGear()
	local myTree = CSPS.getTreeControl()
	if not enchantIds then buildGlyphTables() end
	myTree:AddTemplate("CSPSLEGEAR", NodeSetupGear, nil, nil, 24, 0)
	local fillContent = {}
		for i, v in pairs(gearSlots) do
		table.insert(fillContent, {"CSPSLEGEAR", {gearSlot = v}})
	end
	local overNode = myTree:AddNode("CSPSLH", {name = GS(SI_GAMEPAD_DYEING_EQUIPMENT_HEADER), variant=7, fillContent=fillContent}) -- variant 3 = skill section = always active color

	if myLevel < 50 then
		EVENT_MANAGER:RegisterForEvent(CSPS.name.."LevelUp", EVENT_LEVEL_UPDATE,
			function(_, unitTag, level) 
				if unitTag ~= "player" then return end
				myLevel = level
			end)
	end
	if myCPLevel < 160 then
		EVENT_MANAGER:RegisterForEvent(CSPS.name.."CPLevelUp", EVENT_CHAMPION_POINT_UPDATE,
			function(_, unitTag, _, currentChampionPoints) 
				if unitTag ~= "player" then return end
				myCPLevel = math.min(currentChampionPoints, 160)
				myCPLevel = math.floor(myCPLevel/10)*10
			end)
	end
	
end

function CSPS.getCurrentGear()	
	--local ringOfMara = false
	for _, gearSlot in ipairs(gearSlots) do
		theGear[gearSlot] = false
		local itemLink = GetItemLink(BAG_WORN, gearSlot, LINK_STYLE_DEFAULT)
		local itemUniqueID = Id64ToString(GetItemUniqueId(BAG_WORN, gearSlot))
		itemUniqueID = itemUniqueID ~= "0" and itemUniqueID or false
		local itemId = GetItemLinkItemId(itemLink)
		
		if itemId == 44904 then -- the actual functions are way up above because of the receive-drag-function that uses them too
			setMara(gearSlot, itemLink, itemUniqueID)
		elseif not gearSlotsPoison[gearSlot] and itemLink ~= "" then
			setArmorOrWeaponFromLink(gearSlot, itemLink, itemUniqueID)
		elseif itemLink ~= "" then
			setPoisonFromIdAndLink(gearSlot, itemLink, itemId)
		end
	end

		--[[
			local itemId, enchantSubType = itemLink:match("|H[^:]+:item:([^:]+):[^:]+:[^:]+:[^:]+:([^:]+):")
			local itemQuality = GetItemLinkQuality(itemLink)
			if not ignoreEmpty[gearSlot] and enchantSubType and tonumber(enchantSubType) > 0 then
				local enchantQuality = GetItemLinkQuality(string.format("|H1:item:%i:%i:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h", itemId, enchantSubType))
				if enchantQuality < itemQuality then table.insert(enchantWarning, gearSlot) end
			end

		]]--
	
	CSPS.refreshSetCount()
	return theGear
end

function CSPS.refreshSetCount()
	local setCounts = getActiveSets()
	local setCountFormatted = {}
	for setId, setCountNumbers in pairs(setCounts) do
		if setCountNumbers[2] > 0 or setCountNumbers[3] > 0 then
			setCountFormatted[setId] = string.format("%s/%sx", setCountNumbers[1] + setCountNumbers[2], setCountNumbers[1] + setCountNumbers[3])
		else	
			setCountFormatted[setId] = setCountNumbers[1].."x"
		end
	end
	for gearSlot, gearTable in pairs(theGear) do
		if gearTable and gearTable.setId and gearTable.setId ~= 0 then
			gearTable.setCountF = setCountFormatted[gearTable.setId]
			gearTable.setCount = setCounts[gearTable.setId]
		elseif gearTable then
			gearTable.setCountF = nil
			gearTable.setCount = nil
		end
	end
	return setCountFormatted
end

function CSPS.getTheGear()
	return theGear or {}
end

function CSPS.setTheGear(newGear)
	if not newGear or type(newGear) ~= "table" then return false end
	theGear = newGear
	for gearSlot, v in pairs(theGear) do
		if v and not v.link then
			if gearSlotsPoison[gearSlot] then
				if v.firstId then v.link = string.format(poisonItemLink, v.firstId, v.secondId or 0) else theGear[gearSlot] = nil end
			else
				local _, itemLink = getSetItemInfo(v.setId, gearSlot, v.type,  v.trait, v.quality)
				local itemId = GetItemLinkItemId(itemLink)
				if v.setId == 0 then itemId = CSPS.getGenericItemId(gearSlotsHands[gearSlot] and v.type, gearSlotsBody[gearSlot] and v.type, gearSlot) end
				local crafted = GetItemSetType(v.setId) == ITEM_SET_TYPE_CRAFTED
				itemLink = buildItemLink(itemId, v.quality, v.enchant and enchantGlyphs[v.enchant], crafted, v.trait)
				v.link = itemLink
			end
		end
	end
	CSPS.refreshSetCount()
	CSPS.getTreeControl():RefreshVisible()
end