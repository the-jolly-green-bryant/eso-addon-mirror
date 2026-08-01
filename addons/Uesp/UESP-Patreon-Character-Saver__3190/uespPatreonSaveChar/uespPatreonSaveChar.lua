
uespPatreonSaveChar = {}
local uespPSC = uespPatreonSaveChar

uespPSC.name = "uespPatreonSaveChar"



function uespPSC:Initialize()
	uespPSC.savedVariables = ZO_SavedVars:NewCharacterIdSettings("uespPatreonSaveCharSavedVariables", 1, nil, {})	
	
	ZO_PreHook("Quit", uespPSC.OnPlayerLogout)
	ZO_PreHook("ReloadUI", uespPSC.OnPlayerLogout)
	ZO_PreHook("Logout", uespPSC.OnPlayerLogout)
   
end


function uespPSC.OnPlayerLogout()
	--d("uespPSC.OnPlayerLogout")
	
	uespPSC.SaveCharData()
end


function uespPSC:SaveCharData()
	local charData = {}
	
	charData = uespPSC:GetBaseCharData()
	
	charData.equipSlots = uespPSC:GetEquipSlotsData()
	charData.collectibles = uespPSC:GetCollectibleData()
	charData.heraldry = uespPSC:GetHeraldryData()
	
	uespPSC.savedVariables.charData = charData
end


function uespPSC:GetBaseCharData()
	local charData = {}
	
	charData.TimeStamp = GetTimeStamp()
	charData.TimeStamp64 = Id64ToString(charData.TimeStamp)
	charData.Date = GetDateStringFromTimestamp(charData.Timestamp)
	charData.APIVersion = GetAPIVersion()
	
	charData.CharId = GetCurrentCharacterId()
	charData.CharName = GetUnitName("player")
	charData.AccountName = GetDisplayName()
	charData.UniqueName = GetUniqueNameForCharacter(charData.CharName)
	charData.Title = GetUnitTitle("player")
	charData.Race = GetUnitRace("player")
	charData.Class = GetUnitClass("player")
	charData.Gender = GetUnitGender("player")
	charData.Level = GetUnitLevel("player")
	charData.EffectiveLevel = GetUnitEffectiveLevel("player")
	charData.Zone = GetUnitZone("player")
	
	return charData
end


function uespPSC:GetHeraldryData()
	local heraldryData = {}

	for i = 1, GetNumGuilds() do
		local bgCatIndex, bgStyleIndex, bgColorIndex1, bgColorIndex2, crestCatIndex, crestStyleIndex, crestColorIndex = GetGuildHeraldryAttribute(i)
		
		heraldryData[i] = {
			["bgCatIndex"] = bgCatIndex,
			["bgStyleIndex"] = bgStyleIndex,
			["bgColorIndex1"] = bgColorIndex1,
			["bgColorIndex2"] = bgColorIndex2,
			["crestCatIndex"] = crestCatIndex,
			["crestStyleIndex"] = crestStyleIndex,
			["crestColorIndex"] = crestColorIndex
		}
	end

	return heraldryData
end


function uespPSC:GetCollectibleData()
	local collectibleData = {}
	local categories = {	
			COLLECTIBLE_CATEGORY_TYPE_ABILITY_SKIN,
			COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING,
			COLLECTIBLE_CATEGORY_TYPE_COSTUME,
			COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY,
			COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS,
			COLLECTIBLE_CATEGORY_TYPE_HAIR,
			COLLECTIBLE_CATEGORY_TYPE_HAT,
			COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING,
			COLLECTIBLE_CATEGORY_TYPE_MEMENTO,
			COLLECTIBLE_CATEGORY_TYPE_MOUNT,
			COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE,
			COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY,
			COLLECTIBLE_CATEGORY_TYPE_POLYMORPH,
			COLLECTIBLE_CATEGORY_TYPE_SKIN,
			COLLECTIBLE_CATEGORY_TYPE_VANITY_PET }
			
	for i, category in ipairs(categories) do
		local collectibleId = GetActiveCollectibleByType(category)	
		
		if (collectibleId > 0) then
			local name = GetCollectibleName(collectibleId)
			local categoryName = GetString("SI_COLLECTIBLECATEGORYTYPE", category)
			
			if (categoryName == "") then
				categoryName = tostring(category)
			end
			
			local dye1, dye2, dye3 = GetCurrentCollectibleDyes(collectibleId)
			local dyeData1 = uespPSC:GetDyeData(dye1)
			local dyeData2 = uespPSC:GetDyeData(dye2)
			local dyeData3 = uespPSC:GetDyeData(dye3)
			
			collectibleData[categoryName] = {
				["name"] = name,
				["id"] = collectibleId,
				["dye1"] = dyeData1,
				["dye2"] = dyeData2,
				["dye3"] = dyeData3,
			}
		end
	end

	return collectibleData
end


function uespPSC:GetEquipSlotsData()
	local wornSlots = GetBagSize(BAG_WORN)
	local equipSlots = {}
	local i

	for i = 0, wornSlots do
		if (HasItemInSlot(BAG_WORN, i)) then
			local itemLink = GetItemLink(BAG_WORN, i)
			local itemName = GetItemName(BAG_WORN, i)
			local weaponType = GetItemWeaponType(BAG_WORN, i)
			local style = GetItemLinkItemStyle(itemLink)
			local styleName = GetItemStyleName(style)

			local dye1, dye2, dye3 = GetCurrentItemDyes(BAG_WORN, i)
			local outfitIndex = GetEquippedOutfitIndex()
			local outfitSlot = uespPSC:ConvertEquipSlotToOutfitSlot(i, weaponType)
			local outfitName = ""
			local collectId = -1
			local itemMaterialIndex = -1
			
			if (outfitIndex ~= nil and outfitIndex > 0 and outfitSlot > 0) then
				collectId, itemMaterialIndex, dye1, dye2, dye3 = GetOutfitSlotInfo(0, outfitIndex, outfitSlot)
				outfitName = GetCollectibleName(collectId)
			end
			
			local dyeData1 = uespPSC:GetDyeData(dye1)
			local dyeData2 = uespPSC:GetDyeData(dye2)
			local dyeData3 = uespPSC:GetDyeData(dye3)
			
			equipSlots[i] = { 
				["name"] = itemName,
				["outfitName"] = outfitName,
				["collectId"] = collectId,
				["link"] = itemLink,
				["style"] = styleName,
				["dye1"] = dyeData1,
				["dye2"] = dyeData2,
				["dye3"] = dyeData3,
			}
		end
	end
	
	return equipSlots
end


function uespPSC:GetDyeData(dyeId)

	if (dyeId == 0) then
		return false
	end
	
	local dyeName, known, rarity, hueCategory, achievementId, r, g, b, sortKey = GetDyeInfoById(dyeId)
	local dyeData = {}
	
	dyeData.name = dyeName
	dyeData.r = r
	dyeData.g = g
	dyeData.b = b
	dyeData.id = dyeId
	
	return dyeData
end


uespPSC.OUTFIT_SLOT_MAP = {
	[EQUIP_SLOT_BACKUP_MAIN] = { 
			[-1] = OUTFIT_SLOT_WEAPON_MAIN_HAND_BACKUP,
			[WEAPONTYPE_AXE] = OUTFIT_SLOT_WEAPON_MAIN_HAND_BACKUP,
			[WEAPONTYPE_DAGGER] = OUTFIT_SLOT_WEAPON_MAIN_HAND_BACKUP,
			[WEAPONTYPE_HAMMER] = OUTFIT_SLOT_WEAPON_MAIN_HAND_BACKUP,
			[WEAPONTYPE_SWORD] = OUTFIT_SLOT_WEAPON_MAIN_HAND_BACKUP,
			[WEAPONTYPE_TWO_HANDED_HAMMER] = OUTFIT_SLOT_WEAPON_TWO_HANDED_BACKUP,
			[WEAPONTYPE_TWO_HANDED_SWORD] = OUTFIT_SLOT_WEAPON_TWO_HANDED_BACKUP,
			[WEAPONTYPE_TWO_HANDED_AXE] = OUTFIT_SLOT_WEAPON_TWO_HANDED_BACKUP,
			[WEAPONTYPE_LIGHTNING_STAFF] = OUTFIT_SLOT_WEAPON_STAFF_BACKUP,
			[WEAPONTYPE_FROST_STAFF] = OUTFIT_SLOT_WEAPON_STAFF_BACKUP,
			[WEAPONTYPE_FIRE_STAFF] = OUTFIT_SLOT_WEAPON_STAFF_BACKUP,
			[WEAPONTYPE_HEALING_STAFF] = OUTFIT_SLOT_WEAPON_STAFF_BACKUP,
			[WEAPONTYPE_BOW] = OUTFIT_SLOT_WEAPON_BOW_BACKUP,
			[WEAPONTYPE_SHIELD] = OUTFIT_SLOT_SHIELD_BACKUP,
		},
	[EQUIP_SLOT_BACKUP_OFF] = { 
			[-1] = OUTFIT_SLOT_WEAPON_OFF_HAND_BACKUP,
			[WEAPONTYPE_AXE] = OUTFIT_SLOT_WEAPON_OFF_HAND_BACKUP,
			[WEAPONTYPE_DAGGER] = OUTFIT_SLOT_WEAPON_OFF_HAND_BACKUP,
			[WEAPONTYPE_HAMMER] = OUTFIT_SLOT_WEAPON_OFF_HAND_BACKUP,
			[WEAPONTYPE_SWORD] = OUTFIT_SLOT_WEAPON_OFF_HAND_BACKUP,
			[WEAPONTYPE_TWO_HANDED_HAMMER] = OUTFIT_SLOT_WEAPON_TWO_HANDED_BACKUP,
			[WEAPONTYPE_TWO_HANDED_SWORD] = OUTFIT_SLOT_WEAPON_TWO_HANDED_BACKUP,
			[WEAPONTYPE_TWO_HANDED_AXE] = OUTFIT_SLOT_WEAPON_TWO_HANDED_BACKUP,
			[WEAPONTYPE_LIGHTNING_STAFF] = OUTFIT_SLOT_WEAPON_STAFF_BACKUP,
			[WEAPONTYPE_FROST_STAFF] = OUTFIT_SLOT_WEAPON_STAFF_BACKUP,
			[WEAPONTYPE_FIRE_STAFF] = OUTFIT_SLOT_WEAPON_STAFF_BACKUP,
			[WEAPONTYPE_HEALING_STAFF] = OUTFIT_SLOT_WEAPON_STAFF_BACKUP,
			[WEAPONTYPE_BOW] = OUTFIT_SLOT_WEAPON_BOW_BACKUP,
			[WEAPONTYPE_SHIELD] = OUTFIT_SLOT_SHIELD_BACKUP,
		},
	[EQUIP_SLOT_CHEST] = OUTFIT_SLOT_CHEST,
	[EQUIP_SLOT_COSTUME] = OUTFIT_SLOT_COSTUME,
	[EQUIP_SLOT_FEET] = OUTFIT_SLOT_FEET,
	[EQUIP_SLOT_HAND] = OUTFIT_SLOT_HANDS,
	[EQUIP_SLOT_HEAD] = OUTFIT_SLOT_HEAD,
	[EQUIP_SLOT_LEGS] = OUTFIT_SLOT_LEGS,
	[EQUIP_SLOT_MAIN_HAND] = { 
			[-1] = OUTFIT_SLOT_WEAPON_MAIN_HAND,
			[WEAPONTYPE_AXE] = OUTFIT_SLOT_WEAPON_MAIN_HAND,
			[WEAPONTYPE_DAGGER] = OUTFIT_SLOT_WEAPON_MAIN_HAND,
			[WEAPONTYPE_HAMMER] = OUTFIT_SLOT_WEAPON_MAIN_HAND,
			[WEAPONTYPE_SWORD] = OUTFIT_SLOT_WEAPON_MAIN_HAND,
			[WEAPONTYPE_TWO_HANDED_HAMMER] = OUTFIT_SLOT_WEAPON_TWO_HANDED,
			[WEAPONTYPE_TWO_HANDED_SWORD] = OUTFIT_SLOT_WEAPON_TWO_HANDED,
			[WEAPONTYPE_TWO_HANDED_AXE] = OUTFIT_SLOT_WEAPON_TWO_HANDED,
			[WEAPONTYPE_LIGHTNING_STAFF] = OUTFIT_SLOT_WEAPON_STAFF,
			[WEAPONTYPE_FROST_STAFF] = OUTFIT_SLOT_WEAPON_STAFF,
			[WEAPONTYPE_FIRE_STAFF] = OUTFIT_SLOT_WEAPON_STAFF,
			[WEAPONTYPE_HEALING_STAFF] = OUTFIT_SLOT_WEAPON_STAFF,
			[WEAPONTYPE_BOW] = OUTFIT_SLOT_WEAPON_BOW,
			[WEAPONTYPE_SHIELD] = OUTFIT_SLOT_SHIELD,
		},
	[EQUIP_SLOT_OFF_HAND] = { 
			[-1] = OUTFIT_SLOT_WEAPON_OFF_HAND,
			[WEAPONTYPE_AXE] = OUTFIT_SLOT_WEAPON_OFF_HAND,
			[WEAPONTYPE_DAGGER] = OUTFIT_SLOT_WEAPON_OFF_HAND,
			[WEAPONTYPE_HAMMER] = OUTFIT_SLOT_WEAPON_OFF_HAND,
			[WEAPONTYPE_SWORD] = OUTFIT_SLOT_WEAPON_OFF_HAND,
			[WEAPONTYPE_TWO_HANDED_HAMMER] = OUTFIT_SLOT_WEAPON_TWO_HANDED,
			[WEAPONTYPE_TWO_HANDED_SWORD] = OUTFIT_SLOT_WEAPON_TWO_HANDED,
			[WEAPONTYPE_TWO_HANDED_AXE] = OUTFIT_SLOT_WEAPON_TWO_HANDED,
			[WEAPONTYPE_LIGHTNING_STAFF] = OUTFIT_SLOT_WEAPON_STAFF,
			[WEAPONTYPE_FROST_STAFF] = OUTFIT_SLOT_WEAPON_STAFF,
			[WEAPONTYPE_FIRE_STAFF] = OUTFIT_SLOT_WEAPON_STAFF,
			[WEAPONTYPE_HEALING_STAFF] = OUTFIT_SLOT_WEAPON_STAFF,
			[WEAPONTYPE_BOW] = OUTFIT_SLOT_WEAPON_BOW,
			[WEAPONTYPE_SHIELD] = OUTFIT_SLOT_SHIELD,
		},
	[EQUIP_SLOT_SHOULDERS] = OUTFIT_SLOT_SHOULDERS,
	[EQUIP_SLOT_WAIST] = OUTFIT_SLOT_WAIST,
}


function uespPSC:ConvertEquipSlotToOutfitSlot(equipSlot, weaponType)
	local outfitSlot = uespPSC.OUTFIT_SLOT_MAP[equipSlot]
	
	if (outfitSlot == nil) then
		return -1
	end
	
	if (type(outfitSlot) == "table") then
		outfitSlot = outfitSlot[weaponType]
		
		if (outfitSlot == nil) then
			outfitSlot = outfitSlot[-1]
		end
		
		if (outfitSlot == nil) then
			return -1
		end
	end
	
	return outfitSlot
end
 

function uespPSC.OnAddOnLoaded(event, addonName)

	if (addonName == uespPSC.name) then
		uespPSC:Initialize()
	end
	
end
 

EVENT_MANAGER:RegisterForEvent(uespPSC.name, EVENT_ADD_ON_LOADED, uespPSC.OnAddOnLoaded)