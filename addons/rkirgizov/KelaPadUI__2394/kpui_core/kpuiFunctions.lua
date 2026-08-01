


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

local colors = kpuiConst.Colors	

--local functions
function getStyleHeaderLine(styleIndex)
	local style = zo_strformat("<<1>>", GetItemStyleName(styleIndex))
	local color = ZO_TOOLTIP_DEFAULT_COLOR
	
	-- if kpuiSV.colorizeStyle then
		if styleIndex >= ITEMSTYLE_RACIAL_BRETON and styleIndex <= ITEMSTYLE_RACIAL_KHAJIIT then
			color = GetItemQualityColor(ITEM_QUALITY_ARCANE)
		elseif styleIndex == ITEMSTYLE_RACIAL_IMPERIAL
			or styleIndex == ITEMSTYLE_AREA_DWEMER
			or styleIndex == ITEMSTYLE_AREA_XIVKYN
			or styleIndex == ITEMSTYLE_GLASS then
			color = GetItemQualityColor(ITEM_QUALITY_LEGENDARY)
		else
			color = GetItemQualityColor(ITEM_QUALITY_ARTIFACT)
		end 
	-- end

	return color, style
end
function getTraitHeaderLine(researchStatus, countBank, countPack, countWorn)
	
	local colors = kpuiConst.Colors
	
	local parts = {}
	local icon = "ESOUI/art/crafting/smithing_tabicon_research_down.dds"
	local color = ZO_TOOLTIP_DEFAULT_COLOR
	-- if kpuiSV.colorizeTrait then
		if researchStatus == TRAIT_RESEARCHABLE then
			icon = "ESOUI/art/crafting/smithing_tabicon_research_disabled.dds"
			if countBank + countPack + countWorn > 1 then
				color = colors.COLOR_ORANGE
			else
				color = colors.COLOR_RED
			end
		elseif researchStatus == TRAIT_RESEARCH_IN_PROGRESS then
			icon = "ESOUI/art/crafting/smithing_tabicon_research_over.dds"
			color = colors.COLOR_ORANGE
		end
	-- end
	--KelaPostMsg (researchStatus)
	-- if kpuiSV.showResearchInUpperRightCorner then
		--parts[#parts + 1] = "- "
		if researchStatus == 0 then
			parts[#parts + 1] = GetString(KELA_TRAIT_RESEARCHABLE)
		elseif researchStatus == 1 then
			parts[#parts + 1] = GetString(KELA_TRAIT_KNOWN)
		elseif researchStatus == 2 then
			parts[#parts + 1] = GetString(KELA_TRAIT_KNOWN_IN_PROGRESS)
		end
		-- parts[#parts + 1] = tostring(TraitStatusStrings[researchStatus])
	-- end
	-- if kpuiSV.duplicateItems and researchStatus == TRAIT_RESEARCHABLE then
	if researchStatus == TRAIT_RESEARCHABLE then
		if countBank > 0 or countPack > 0 or countWorn > 0 then
			parts[#parts + 1] = ", "
			if countBank > 0 then
				parts[#parts + 1] = "|u2:2::"
				parts[#parts + 1] = countBank
				parts[#parts + 1] = "|u"
				parts[#parts + 1] = "|t30:30:esoui/art/icons/servicemappins/servicepin_bank.dds:inheritColor|t"
				parts[#parts + 1] = "|u4:0::|u" -- padding
			end
			if countPack > 0 then
				parts[#parts + 1] = "|u2:0::"
				parts[#parts + 1] = countPack
				parts[#parts + 1] = "|u"
				parts[#parts + 1] = "|t30:30:EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_inventory.dds:inheritColor|t"
			end
			if countWorn > 0 then
				parts[#parts + 1] = "|u2:0::"
				parts[#parts + 1] = countWorn
				parts[#parts + 1] = "|u"
				parts[#parts + 1] = "|t30:30:EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_character.dds:inheritColor|t"
			end
			--parts[#parts + 1] = ")"
		end
	end
	if #parts > 0 then
		local text = table.concat(parts, "")
		return icon, color, text
	end
	return color
end

function setValueIfNil(tab, name, defaultValue)
	if tab[name] == nil then
		tab[name] = defaultValue
		return true
	end
	return false
end


function KelaPadUI:GetItemFlagStatus(bagId, slotIndex)
	local flags = kpuiConst.ItemFlags
	local itemLink = GetItemLink(bagId, slotIndex)
	local itemType = GetItemLinkItemType(itemLink)
	local traitType, _ = GetItemLinkTraitInfo(itemLink)
	local researchStatus = KelaPadUI:GetItemLinkResearchStatus(itemLink)
	local blnResearchable = false
	local returnStatus = flags.ITEM_FLAG_NONE
	local name = ""
	local treasureType = itemType == ITEMTYPE_TREASURE
	
	if treasureType then  
		local quality = GetItemLinkQuality(itemLink)
		if quality >= 2 then 
			return flags.ITEM_FLAG_TRAIT_ORNATE
		end
	else
		if researchStatus then
			if researchStatus == 0 then
				returnStatus = flags.ITEM_FLAG_TRAIT_RESEARCHABLE
				blnResearchable = true
			elseif researchStatus == 1 then
				returnStatus = flags.ITEM_FLAG_TRAIT_KNOWN
			elseif researchStatus == 2 then
				returnStatus = flags.ITEM_FLAG_TRAIT_RESEARCHING
			end
		else
			if traitType == ITEM_TRAIT_TYPE_WEAPON_INTRICATE or traitType == ITEM_TRAIT_TYPE_ARMOR_INTRICATE then
				return flags.ITEM_FLAG_TRAIT_INTRICATE, name
			elseif traitType == ITEM_TRAIT_TYPE_WEAPON_ORNATE or traitType == ITEM_TRAIT_TYPE_ARMOR_ORNATE then
				return flags.ITEM_FLAG_TRAIT_ORNATE, name
			end
			if traitType == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE or traitType == ITEM_TRAIT_TYPE_WEAPON_INTRICATE or traitType == ITEM_TRAIT_TYPE_ARMOR_INTRICATE then
				return flags.ITEM_FLAG_TRAIT_INTRICATE, name
			elseif traitType == ITEM_TRAIT_TYPE_JEWELRY_ORNATE or traitType == ITEM_TRAIT_TYPE_WEAPON_ORNATE or traitType == ITEM_TRAIT_TYPE_ARMOR_ORNATE then
				return flags.ITEM_FLAG_TRAIT_ORNATE, name
			end
		end   
	end
	return returnStatus, name, blnResearchable
end
function KelaPadUI:ItemToResearchLineIndex(itemLink)
 	local itemType = GetItemLinkItemType(itemLink)
	local armorType = GetItemLinkArmorType(itemLink)
	local weaponType = GetItemLinkWeaponType(itemLink)
	local equipType = GetItemLinkEquipType(itemLink)
	if itemType == ITEMTYPE_ARMOR then
		if armorType == ARMORTYPE_NONE then
			return kpuiConst.ArmorTypeAndEquipTypeToResearchLineIndex[ARMORTYPE_NONE][equipType]
		elseif armorType == ARMORTYPE_HEAVY then
			return kpuiConst.ArmorTypeAndEquipTypeToResearchLineIndex[ARMORTYPE_HEAVY][equipType]
		elseif armorType == ARMORTYPE_LIGHT then
			return kpuiConst.ArmorTypeAndEquipTypeToResearchLineIndex[ARMORTYPE_LIGHT][equipType]
		elseif armorType == ARMORTYPE_MEDIUM then
			return kpuiConst.ArmorTypeAndEquipTypeToResearchLineIndex[ARMORTYPE_MEDIUM][equipType]
		end
	elseif itemType == ITEMTYPE_WEAPON then
		return kpuiConst.WeaponTypeToResearchLineIndex[weaponType]
	end
	return 0
end
function KelaPadUI:ItemToTraitIndex(traitType)
  if traitType >= 1 and traitType <= 8 then
    return traitType
  elseif traitType == 26 then
    return 9
  elseif traitType >= 11 and traitType <= 18 then
    return traitType - 10
  elseif traitType == 25 then
    return 9
  elseif traitType == 22 then
    return 1
  elseif traitType == 21 then
    return 2
  elseif traitType == 23 then
    return 3
  elseif traitType == 30 then
    return 4
  elseif traitType == 33 then
    return 5
  elseif traitType == 32 then
    return 6
  elseif traitType == 28 then
    return 7
  elseif traitType == 29 then
    return 8
  elseif traitType == 31 then
    return 9
  end
  return nil
end

function KelaPadUI:IsResearchableTrait(itemType, traitType)
	return (itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR) 
	and (traitType == ITEM_TRAIT_TYPE_ARMOR_DIVINES
	or traitType == ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS
	or traitType == ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE
	or traitType == ITEM_TRAIT_TYPE_ARMOR_INFUSED
	or traitType == ITEM_TRAIT_TYPE_ARMOR_REINFORCED
	or traitType == ITEM_TRAIT_TYPE_ARMOR_STURDY
	or traitType == ITEM_TRAIT_TYPE_ARMOR_TRAINING
	or traitType == ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED
	or traitType == ITEM_TRAIT_TYPE_ARMOR_NIRNHONED
	or traitType == ITEM_TRAIT_TYPE_WEAPON_CHARGED
	or traitType == ITEM_TRAIT_TYPE_WEAPON_DEFENDING
	or traitType == ITEM_TRAIT_TYPE_WEAPON_INFUSED
	or traitType == ITEM_TRAIT_TYPE_WEAPON_POWERED
	or traitType == ITEM_TRAIT_TYPE_WEAPON_PRECISE
	or traitType == ITEM_TRAIT_TYPE_WEAPON_SHARPENED
	or traitType == ITEM_TRAIT_TYPE_WEAPON_TRAINING
	or traitType == ITEM_TRAIT_TYPE_WEAPON_DECISIVE
	or traitType == ITEM_TRAIT_TYPE_WEAPON_NIRNHONED
	or traitType == ITEM_TRAIT_TYPE_JEWELRY_ARCANE
	or traitType == ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY
	or traitType == ITEM_TRAIT_TYPE_JEWELRY_HARMONY
	or traitType == ITEM_TRAIT_TYPE_JEWELRY_HEALTHY
	or traitType == ITEM_TRAIT_TYPE_JEWELRY_INFUSED
	or traitType == ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE
	or traitType == ITEM_TRAIT_TYPE_JEWELRY_ROBUST
	or traitType == ITEM_TRAIT_TYPE_JEWELRY_SWIFT
	or traitType == ITEM_TRAIT_TYPE_JEWELRY_TRIUNE)
end

function getDateTime (remaining, remainingType) --remaining, remainingType
	local timeRemain = 0
	if remainingType == "seconds" then
		timeRemain = remaining
	elseif remainingType == "milliseconds" then
		timeRemain = remaining/ZO_ONE_SECOND_IN_MILLISECONDS
	end
	
	local completeTime = FormatTimeSeconds(GetSecondsSinceMidnight() + timeRemain, TIME_FORMAT_STYLE_CLOCK_TIME,  TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR, TIME_FORMAT_DIRECTION_NONE)
	local completeDate = GetTimeStamp() + timeRemain
	completeDate = GetDateStringFromTimestamp(completeDate)
	local month, day, year = string.match(completeDate,"(%d*)\/(%d*)\/(%d*)")
	completeDate = zo_strformat(KELA_FORMAT_DATE, day, month, year)	
	
	day = os.date("%d-%m-%Y", os.time() + timeRemain) --dayOffset*86400)
	
	return day, completeTime
end

function KelaPadUI:GetSameTraitCount(bagId, armorType, weaponType, equipType, trait)
	local count = 0
	for slotIndex = 0, GetBagSize(bagId) - 1 do
		local itemType = GetItemType(bagId, slotIndex)
		if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
			if armorType == GetItemArmorType(bagId, slotIndex) and weaponType == GetItemWeaponType(bagId, slotIndex) and GetItemTrait(bagId, slotIndex) == trait then
				local _,_,_,_,_, otherEquipType = GetItemInfo(bagId, slotIndex)
				if otherEquipType == equipType then
					count = count + 1
				end
			end
		end
	end
	return count
end

function GetAvailableTraitLine(countBank, countPack, countWorn)

	local parts = {}
	local color = ZO_TOOLTIP_DEFAULT_COLOR
		if countBank + countPack + countWorn > 1 then
			color = kpuiConst.Colors.COLOR_ORANGE
		else
			color = kpuiConst.Colors.COLOR_RED
		end
		if countBank > 0 or countPack > 0 or countWorn > 0 then
			parts[#parts + 1] = ""
			if countBank > 0 then
				parts[#parts + 1] = "|u2:2::"
				parts[#parts + 1] = countBank
				parts[#parts + 1] = "|u"
				parts[#parts + 1] = "|t24:24:esoui/art/icons/servicemappins/servicepin_bank.dds:inheritColor|t"
				parts[#parts + 1] = "|u4:0::|u" -- padding
			end
			if countPack > 0 then
				parts[#parts + 1] = "|u2:0::"
				parts[#parts + 1] = countPack
				parts[#parts + 1] = "|u"
				parts[#parts + 1] = "|t24:24:EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_inventory.dds:inheritColor|t"
			end
			if countWorn > 0 then
				parts[#parts + 1] = "|u2:0::"
				parts[#parts + 1] = countWorn
				parts[#parts + 1] = "|u"
				parts[#parts + 1] = "|t24:24:EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_character.dds:inheritColor|t"
			end
		end
	if #parts > 0 then
		local text = table.concat(parts, "")
		return color, text
	end
	return color
end

function getCraftingType (intCraftType, short, research)
	-- 1 CRAFTING_TYPE_BLACKSMITHING
	-- 2 CRAFTING_TYPE_CLOTHIER
	-- 6 CRAFTING_TYPE_WOODWORKING
	-- 7 CRAFTING_TYPE_JEWELRYCRAFTING

	local resultString = GetString(SI_SMITHING_RESEARCH_UNKNOWN)
	if intCraftType == 1 then
		if short then 
			resultString = GetString(KELA_CRAFTING_BLACKSMITHING)
		elseif research then 
			resultString = GetString(KELA_RESEARCH_BLACKSMITHING)
		else
			resultString = GetString(SI_ITEMFILTERTYPE13)
		end
	elseif intCraftType == 2 then
		if short then 
			resultString = GetString(KELA_CRAFTING_CLOTHIER)
		elseif research then 
			resultString = GetString(KELA_RESEARCH_CLOTHIER)
		else
			resultString = GetString(SI_ITEMFILTERTYPE14)
		end	
	elseif intCraftType == 6 then
		if short then 
			resultString = GetString(KELA_CRAFTING_WOODWORKING)
		elseif research then 
			resultString = GetString(KELA_RESEARCH_WOODWORKING)
		else
			resultString = GetString(SI_ITEMFILTERTYPE15)
		end
	elseif intCraftType == 7 then
		if short then 
			resultString = GetString(KELA_CRAFTING_JEWELRY)
		elseif research then 
			resultString = GetString(KELA_RESEARCH_JEWELRY)
		else
			resultString = GetString(SI_ITEMFILTERTYPE24)
		end
	end
	return resultString
end


function KelaPadUI:GetitemCraftType(itemLink)
	local itemType = GetItemLinkItemType(itemLink)
	local equipType = GetItemLinkEquipType(itemLink)
	if(itemType ~= ITEMTYPE_NONE and equipType ~= EQUIP_TYPE_INVALID) then
		if equipType == EQUIP_TYPE_RING or equipType == EQUIP_TYPE_NECK then -- ювелирные изделия
			return JEWELRYTYPE_RING_NECK
		end
		local armorType = GetItemLinkArmorType(itemLink)
		local weaponType = GetItemLinkWeaponType(itemLink)	
		if itemType == ITEMTYPE_ARMOR and weaponType == WEAPONTYPE_NONE then -- броня
			return armorType
		end
		if weaponType ~= WEAPONTYPE_NONE then
			return kpuiConst.ItemTypeToCraftType[weaponType] 
		end
	end
	return nil
end

function KelaPadUI:GetitemCraftTypeString(intType)
	if intType == WEAPONTYPE_BLACKSMITHING then
		return GetString(KELA_WEAPONTYPE_BLACKSMITHING)
	elseif intType == ARMORTYPE_HEAVY then
		return GetString(KELA_ARMORTYPE_HEAVY)
	elseif intType == WEAPONTYPE_BOW then
		return GetString(KELA_WEAPONTYPE_BOW)
	elseif intType == WEAPONTYPE_STAFF then
		return GetString(KELA_WEAPONTYPE_STAFF)
	elseif intType == WEAPONTYPE_SHIELD then
		return GetString(KELA_WEAPONTYPE_SHIELD)
	elseif intType == ARMORTYPE_LIGHT then
		return GetString(KELA_ARMORTYPE_LIGHT)
	elseif intType == ARMORTYPE_MEDIUM then
		return GetString(KELA_ARMORTYPE_MEDIUM)
	elseif intType == JEWELRYTYPE_RING_NECK then
		return GetString(KELA_JEWELRYTYPE_RING_NECK)
	end
	return GetString(SI_SMITHING_RESEARCH_UNKNOWN)
end

function KelaPadUI:GetBagInfo(itemLinkComparison, itemSize)
	for _,bagId in ipairs(kpuiConst.Bags["ALL_CRAFTING_INVENTORY_BAGS_AND_WORN"]) do
		for slotIndex = 0, GetBagSize(bagId) - 1 do
			itemLink = GetItemLink(bagId, slotIndex)
			if itemLink == itemLinkComparison then
				if itemSize == 24 then 
					local iconBag = kpuiConst.Bags["BAGS_ICONS_24"][bagId]
					local strBag = kpuiConst.Bags["BAGS_STRINGS"][bagId]
					local iconLocked = ""
					if IsItemPlayerLocked(bagId, slotIndex) then iconLocked = kpuiConst.Bags["BAGS_ICONS_24"]["LOCKED"] end
					return iconBag, strBag, iconLocked
				else
					local iconBag = kpuiConst.Bags["BAGS_ICONS"][bagId]
					local strBag = kpuiConst.Bags["BAGS_STRINGS"][bagId]
					local iconLocked = ""
					if IsItemPlayerLocked(bagId, slotIndex) then iconLocked = kpuiConst.Bags["BAGS_ICONS"]["LOCKED"] end
					return iconBag, strBag, iconLocked
				end
			end
		end
	end
	return "", "", ""
end

function KelaPadUI:GetSmithingType(bagId, slotIndex)
	itemType = GetItemType(bagId, slotIndex)
	if itemType == ITEMTYPE_ARMOR then
		return kpuiConst.TradeskillForArmorType[GetItemLinkArmorType(GetItemLink(bagId, slotIndex))]
	elseif itemType == ITEMTYPE_WEAPON then
		return kpuiConst.TradeskillForWeaponType[GetItemLinkWeaponType(GetItemLink(bagId, slotIndex))]
	end
	return nil
end

	

function kelaSetAvailableTraitsIcons(craftingType)

	countBank, countBackpack, countWorn = KelaPadUI:GetAvailableTraitCount(craftingType)
	researchColor, traitText = GetAvailableTraitLine(countBank, countBackpack, countWorn)			
	kelaAvailableTraitsIcons = researchColor:Colorize(string.lower(traitText))


end


function KelaPadUI:GetAvailableTraitCount(smithingType)
	local itemType, itemLink, itemName 
	local armorType, weaponType, equipType
	local smithingTypeArmor, smithingTypeWeapon
	local researchIcon, researchColor, traitText
	local countBank = 0
	local bagId = BAG_BANK
	for slotIndex = 0, GetBagSize(bagId) - 1 do
		itemType = GetItemType(bagId, slotIndex)
		if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
			itemLink = GetItemLink(bagId, slotIndex)
			itemName = GetItemName(bagId, slotIndex)
			equipType = GetItemLinkEquipType(itemLink)
			smithingTypeArmor = kpuiConst.TradeskillForArmorType[GetItemLinkArmorType(itemLink)]
			smithingTypeWeapon = kpuiConst.TradeskillForWeaponType[GetItemLinkWeaponType(itemLink)]		
			if (smithingTypeArmor == smithingType and itemType ~= ITEMTYPE_WEAPON and GetItemTrait(bagId, slotIndex)) or (smithingTypeWeapon == smithingType and itemType ~= ITEMTYPE_ARMOR and equipType ~= EQUIP_TYPE_RING and equipType ~= EQUIP_TYPE_NECK and GetItemTrait(bagId, slotIndex)) then
				local _,_,_,_,_, otherEquipType = GetItemInfo(bagId, slotIndex)
				if otherEquipType == equipType then
					local researchStatus = KelaPadUI:GetItemLinkResearchStatus(itemLink)
					if researchStatus == 0 then
						local traitType = GetItemLinkTraitInfo(itemLink)
						countBank = countBank + 1
					end
				end
			end
		end
	end
	local bagId = BAG_SUBSCRIBER_BANK
	for slotIndex = 0, GetBagSize(bagId) - 1 do
		itemType = GetItemType(bagId, slotIndex)
		if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
			itemLink = GetItemLink(bagId, slotIndex)
			itemName = GetItemName(bagId, slotIndex)
			equipType = GetItemLinkEquipType(itemLink)
			smithingTypeArmor = kpuiConst.TradeskillForArmorType[GetItemLinkArmorType(itemLink)]
			smithingTypeWeapon = kpuiConst.TradeskillForWeaponType[GetItemLinkWeaponType(itemLink)]		
			if (smithingTypeArmor == smithingType and itemType ~= ITEMTYPE_WEAPON and GetItemTrait(bagId, slotIndex)) or (smithingTypeWeapon == smithingType and itemType ~= ITEMTYPE_ARMOR and equipType ~= EQUIP_TYPE_RING and equipType ~= EQUIP_TYPE_NECK and GetItemTrait(bagId, slotIndex)) then
				local _,_,_,_,_, otherEquipType = GetItemInfo(bagId, slotIndex)
				if otherEquipType == equipType then
					local researchStatus = KelaPadUI:GetItemLinkResearchStatus(itemLink)
					if researchStatus == 0 then
						local traitType = GetItemLinkTraitInfo(itemLink)
						countBank = countBank + 1
					end
				end
			end
		end
	end
	local countBackpack = 0
	local bagId = BAG_BACKPACK
	for slotIndex = 0, GetBagSize(bagId) - 1 do
		itemType = GetItemType(bagId, slotIndex)
		if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
			itemLink = GetItemLink(bagId, slotIndex)
			itemName = GetItemName(bagId, slotIndex)
			equipType = GetItemLinkEquipType(itemLink)
			smithingTypeArmor = kpuiConst.TradeskillForArmorType[GetItemLinkArmorType(itemLink)]
			smithingTypeWeapon = kpuiConst.TradeskillForWeaponType[GetItemLinkWeaponType(itemLink)]		
			if (smithingTypeArmor == smithingType and itemType ~= ITEMTYPE_WEAPON and GetItemTrait(bagId, slotIndex)) or (smithingTypeWeapon == smithingType and itemType ~= ITEMTYPE_ARMOR and equipType ~= EQUIP_TYPE_RING and equipType ~= EQUIP_TYPE_NECK and GetItemTrait(bagId, slotIndex)) then
				local _,_,_,_,_, otherEquipType = GetItemInfo(bagId, slotIndex)
				if otherEquipType == equipType then
					local researchStatus = KelaPadUI:GetItemLinkResearchStatus(itemLink)
					if researchStatus == 0 then
						local traitType = GetItemLinkTraitInfo(itemLink)
						--KelaPostMsg(tostring(itemLink).." - "..GetString("SI_ITEMTRAITTYPE", traitType))
						countBackpack = countBackpack + 1
					end
				end
			end
		end
	end
	local countWorn = 0
	local bagId = BAG_WORN
	for slotIndex = 0, GetBagSize(bagId) - 1 do
		itemType = GetItemType(bagId, slotIndex)
		if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
			itemLink = GetItemLink(bagId, slotIndex)
			itemName = GetItemName(bagId, slotIndex)
			equipType = GetItemLinkEquipType(itemLink)
			smithingTypeArmor = kpuiConst.TradeskillForArmorType[GetItemLinkArmorType(itemLink)]
			smithingTypeWeapon = kpuiConst.TradeskillForWeaponType[GetItemLinkWeaponType(itemLink)]				
			if (smithingTypeArmor == smithingType and itemType ~= ITEMTYPE_WEAPON and GetItemTrait(bagId, slotIndex)) or (smithingTypeWeapon == smithingType and itemType ~= ITEMTYPE_ARMOR and equipType ~= EQUIP_TYPE_RING and equipType ~= EQUIP_TYPE_NECK and GetItemTrait(bagId, slotIndex)) then
				local _,_,_,_,_, otherEquipType = GetItemInfo(bagId, slotIndex)
				if otherEquipType == equipType then
					local researchStatus = KelaPadUI:GetItemLinkResearchStatus(itemLink)
					if researchStatus == 0 then
						local traitType = GetItemLinkTraitInfo(itemLink)
						--KelaPostMsg(tostring(itemLink).." - "..GetString("SI_ITEMTRAITTYPE", traitType))
						countWorn = countWorn + 1
					end
				end
			end
		end
	end
	local countAll = countBank + countBackpack + countWorn
	return countBank, countBackpack, countWorn, countAll
end

function KelaPadUI:GetAvailableResearchLines()

	local countBlacksmithing = 0
	local CraftingTypeID = CRAFTING_TYPE_BLACKSMITHING
	for researchLineIndex = 1, GetNumSmithingResearchLines(CraftingTypeID) do
		local _, _, numTraits = GetSmithingResearchLineInfo(CraftingTypeID, researchLineIndex)
		for t=1, numTraits do
			local dur, remaining = GetSmithingResearchLineTraitTimes(CraftingTypeID, researchLineIndex, t)
			if dur and remaining then
				countBlacksmithing = countBlacksmithing + 1
			end
		end		
	end
	countBlacksmithing = GetMaxSimultaneousSmithingResearch(CraftingTypeID) - countBlacksmithing

	local countClothier = 0
	local CraftingTypeID = CRAFTING_TYPE_CLOTHIER
	for researchLineIndex = 1, GetNumSmithingResearchLines(CraftingTypeID) do
		local _, _, numTraits = GetSmithingResearchLineInfo(CraftingTypeID, researchLineIndex)
		for t=1, numTraits do
			local dur, remaining = GetSmithingResearchLineTraitTimes(CraftingTypeID, researchLineIndex, t)
			if dur and remaining then
				countClothier = countClothier + 1
			end
		end		
	end
	countClothier = GetMaxSimultaneousSmithingResearch(CraftingTypeID) - countClothier
	
	local countWoodworking = 0
	local CraftingTypeID = CRAFTING_TYPE_WOODWORKING
	for researchLineIndex = 1, GetNumSmithingResearchLines(CraftingTypeID) do
		local _, _, numTraits = GetSmithingResearchLineInfo(CraftingTypeID, researchLineIndex)
		for t=1, numTraits do
			local dur, remaining = GetSmithingResearchLineTraitTimes(CraftingTypeID, researchLineIndex, t)
			if dur and remaining then
				countWoodworking = countWoodworking + 1
			end
		end		
	end
	countWoodworking = GetMaxSimultaneousSmithingResearch(CraftingTypeID) - countWoodworking
	
	local countJewelry = 0
	local CraftingTypeID = CRAFTING_TYPE_JEWELRYCRAFTING
	for researchLineIndex = 1, GetNumSmithingResearchLines(CraftingTypeID) do
		local _, _, numTraits = GetSmithingResearchLineInfo(CraftingTypeID, researchLineIndex)
		for t=1, numTraits do
			local dur, remaining = GetSmithingResearchLineTraitTimes(CraftingTypeID, researchLineIndex, t)
			if dur and remaining then
				countJewelry = countJewelry + 1
			end
		end		
	end
	countJewelry = GetMaxSimultaneousSmithingResearch(CraftingTypeID) - countJewelry

	return countBlacksmithing, countClothier, countWoodworking, countJewelry 
end
function KelaPadUI:GetCurrentResearchLines(CraftingTypeID)

	local count = 0
	for researchLineIndex = 1, GetNumSmithingResearchLines(CraftingTypeID) do
		local _, _, numTraits = GetSmithingResearchLineInfo(CraftingTypeID, researchLineIndex)
		for t=1, numTraits do
			local dur, remaining = GetSmithingResearchLineTraitTimes(CraftingTypeID, researchLineIndex, t)
			if dur and remaining then
				count = count + 1
			end
		end		
	end
	local maxResearchable = GetMaxSimultaneousSmithingResearch(CraftingTypeID)
	local CurrentResearchLines = tostring(count).."/"..tostring(maxResearchable)
	
	return CurrentResearchLines, count, maxResearchable
end


function KelaPadUI:GetItemsCounts()
	local countStolen = 0
	local countIntricate = 0
	local countOrnate = 0
	for slotIndex = 0, GetBagSize(BAG_BACKPACK) - 1 do
		local itemType = GetItemLinkItemType(GetItemLink(BAG_BACKPACK, slotIndex))
		if IsItemStolen(BAG_BACKPACK, slotIndex) then
			-- KelaPostMsg("IsItemStolen")
			countStolen = countStolen + 1
		end
		local traitType = GetItemTrait(BAG_BACKPACK, slotIndex)		
		if traitType == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE or traitType == ITEM_TRAIT_TYPE_WEAPON_INTRICATE or traitType == ITEM_TRAIT_TYPE_ARMOR_INTRICATE then
			countIntricate = countIntricate + 1
		elseif traitType == ITEM_TRAIT_TYPE_JEWELRY_ORNATE or traitType == ITEM_TRAIT_TYPE_WEAPON_ORNATE or traitType == ITEM_TRAIT_TYPE_ARMOR_ORNATE then
			countOrnate = countOrnate + 1
		end
	end
	return countStolen, countIntricate, countOrnate
end

--Integration with ArkadiusTradeTools
function GetATTPriceAndStatus(itemLink)
  if not ArkadiusTradeTools then
    return "", ""
  end
	--local L = ShissuFramework["func"]._L("ArkadiusTradeTools")
	local itemSales = ArkadiusTradeTools.Modules.Sales:GetItemSalesInformation(itemLink, GetTimeStamp() - 30 * 86400)
	local itemQuality = GetItemLinkQuality(itemLink)
	local itemType = GetItemLinkItemType(itemLink)
	for link, sales in pairs(itemSales) do
		averagePrice = 0
		quantity = 0

		if (link == itemLink) then
			local minPrice = math.huge
			local maxPrice = 0
			local price

			for _, sale in pairs(sales) do
				price = sale.price / sale.quantity

				if (price < minPrice) 
				then 
					minPrice = price 
				end
				if (price > maxPrice) 
				then 
					maxPrice = price 
				end
			end
		end

		for _, sale in pairs(sales) do
			averagePrice = averagePrice + sale.price
			quantity = quantity + sale.quantity
		end

		if (quantity > 0) then
			averagePrice = math.attRound(averagePrice / quantity, 2)
		else
			averagePrice = 0
		end

		--averagePrice = KelaLocalizedFormatNumber(averagePrice, 2)
		
	if (link == itemLink) then
		if (quantity > 0) then
			if (#sales ~= quantity) then
				statsString = zo_strformat("|cf58585<<1>>|r", string.format(GetString(KELA_MM_PRICE_XLISTINGSYITEMS), KelaLocalizedFormatNumber(#sales, 0), KelaLocalizedFormatNumber(quantity, 0)))
			else
				statsString = zo_strformat("|cf58585<<1>>|r", string.format(GetString(KELA_MM_PRICE_XLISTINGS), KelaLocalizedFormatNumber(#sales, 0)))
			end
			return averagePrice, statsString
		end
	end
end
return nil, nil 
end

-- функция для сортировки в pairs
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end
-- функция для подсчёта
function kelaGetCountTable(t)
    local count = 0
    for k in pairs(t) do count = count + 1 end
    return count
end

function KelaLocalizedFormatNumber(number, decimal)
	local mult = 10 ^ (decimal or 2)
	local subString = '%1' .. GetString(KELA_THOUSANDS_SEPARATOR)
	number = math.floor(number * mult + 0.5) / mult
	local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", subString)
	return minus .. int:reverse():gsub("^,", "") .. fraction
end

function KelaPostMsg(msg)
	CHAT_SYSTEM:AddMessage(msg)
end

function kelaGetAlliance(zoneId)
	if zoneId==ID_STONEFALLS or zoneId==ID_DESHAAN or zoneId==ID_EASTMARCH or zoneId==ID_THERIFT or zoneId==ID_SHADOWFEN then
		return ALLIANCE_EBONHEART_PACT
	elseif zoneId==ID_GLENUMBRA or zoneId==ID_STORMHAVEN or zoneId==ID_RIVENSPIRE or zoneId==ID_BANGKORAI or zoneId==ID_ALIKRDESERT then
		return ALLIANCE_DAGGERFALL_COVENANT
	elseif zoneId==ID_MALABALTOR or zoneId==ID_GREENSHADE or zoneId==ID_AURIDON or zoneId==ID_REAPERSMARCH or zoneId==ID_GRAHTWOOD then
		return ALLIANCE_ALDMERI_DOMINION
	else
		return ALLIANCE_NONE
	end
end

function  kelaGetZoneIcon(zoneId)
	if zoneId==ID_EYEVEA then
		return "esoui/art/icons/servicemappins/servicepin_magesguild.dds"
	elseif zoneId==ID_IMPERIALCITY then
		return "esoui/art/treeicons/tutorial_indexicon_ic_up.dds"
	elseif zoneId==ID_EARTHFORGE then
		return "esoui/art/icons/servicemappins/servicepin_fightersguild.dds"
	elseif zoneId==ID_WROTHGAR then
		return "esoui/art/treeicons/tutorial_idexicon_wrothgar_up.dds"
	elseif zoneId==ID_HEWSBANE then
		return "esoui/art/treeicons/tutorial_idexicon_thievesguild_up.dds"
	elseif zoneId==ID_GOLDCOAST then
		return "esoui/art/treeicons/tutorial_idexicon_darkbrotherhood_up.dds"
	elseif zoneId==ID_VVARDENFELL then
		return "esoui/art/treeicons/tutorial_idexicon_morrowind_up.dds"
	elseif zoneId==ID_CRAGLORN then
		return "esoui/art/mainmenu/menubar_ava_up.dds"
	elseif zoneId==ID_CLOCKWORK then
		return "esoui/art/treeicons/tutorial_idexicon_cwc_up.dds"
	elseif zoneId==ID_BRASSFORT then
		return "esoui/art/treeicons/tutorial_idexicon_cwc_up.dds"
	elseif zoneId==ID_SUMMERSET then
		return "esoui/art/treeicons/tutorial_idexicon_summerset_up.dds.dds"
	elseif zoneId==ID_ARTAEUM then
		return "esoui/art/treeicons/tutorial_idexicon_summerset_up.dds.dds"
	elseif zoneId==ID_MURKMIRE then
		return "esoui/art/treeicons/tutorial_idexicon_murkmire_up.dds"
	elseif zoneId==ID_ELSWEYR_NORTH then
		return "esoui/art/treeicons/tutorial_idexicon_elsweyr_up.dds"
	elseif zoneId==ID_LOCATION_NONE then
		return nil
	end
	return "esoui/art/treeicons/store_indexicon_dungdlc_up.dds"
end