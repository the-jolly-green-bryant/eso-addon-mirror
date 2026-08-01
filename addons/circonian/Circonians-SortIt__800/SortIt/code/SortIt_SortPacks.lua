
local LIBSI = LibStub:GetLibrary("LibSortIt-1.0")


----------------------------------------------------------
--  Data Gathering functions to populate callback data  --
----------------------------------------------------------
local function GetArmorInfo(_iBagId, _iSlotId)
	local iItemType = GetItemType(_iBagId, _iSlotId)
	local tArmorTable = {
		IsArmor = false, IsHeavyArmor = false, IsMediumArmor = false, IsLightArmor = false,
		IsJewelry = false,
	}
	if iItemType ~= ITEMTYPE_ARMOR  then return tArmorTable end
	local iSubType = GetItemArmorType(_iBagId, _iSlotId)
	
	local iSubType = GetItemArmorType(_iBagId, _iSlotId)
	tArmorTable.IsArmor = true
	if iSubType == ARMORTYPE_HEAVY then 
		tArmorTable.IsHeavyArmor = true
	elseif iSubType == ARMORTYPE_MEDIUM then
		tArmorTable.IsMediumArmor = true
	elseif iSubType == ARMORTYPE_LIGHT then
		tArmorTable.IsLightArmor = true
	elseif iSubType == ARMORTYPE_NONE then
		tArmorTable.IsJewelry = true
	end
	return tArmorTable
end
     
local function GetWeaponInfo(_iBagId, _iSlotId)
	local iItemType = GetItemType(_iBagId, _iSlotId)
	local tWeaponTable = {
		IsWeapon = false, Is1hWeapon = false, Is1hMace = false, Is1hAxe = false, Is1hSword = false,
		IsDagger = false, IsBow = false, Is2hWeapon = false, Is2hMace = false, Is2hAxe = false,
		Is2hSword = false, IsStave = false, IsFireStaff = false, IsFrostStaff = false,
		IsLightStaff = false, IsHealingStaff = false, IsShield = false,
	}
	if iItemType ~= ITEMTYPE_WEAPON   then return tWeaponTable end
	local iSubType = GetItemWeaponType(_iBagId, _iSlotId)
	tWeaponTable.IsWeapon = true
	
	if iSubType == WEAPONTYPE_HAMMER then
		tWeaponTable.Is1hWeapon = true
		tWeaponTable.Is1hMace = true
	elseif iSubType == WEAPONTYPE_AXE then
		tWeaponTable.Is1hWeapon = true
		tWeaponTable.Is1hAxe = true
	elseif iSubType == WEAPONTYPE_SWORD then
		tWeaponTable.Is1hWeapon = true
		tWeaponTable.Is1hSword = true
	elseif iSubType == WEAPONTYPE_DAGGER then
		tWeaponTable.Is1hWeapon = true
		tWeaponTable.IsDagger = true
	elseif iSubType == WEAPONTYPE_BOW then
		tWeaponTable.IsBow = true
	elseif iSubType == WEAPONTYPE_TWO_HANDED_HAMMER then
		tWeaponTable.Is2hWeapon = true
		tWeaponTable.Is2hMace = true
	elseif iSubType == WEAPONTYPE_TWO_HANDED_AXE then
		tWeaponTable.Is2hWeapon = true
		tWeaponTable.Is2hAxe = true
	elseif iSubType == WEAPONTYPE_TWO_HANDED_SWORD then
		tWeaponTable.Is2hWeapon = true
		tWeaponTable.Is2hSword = true
	elseif iSubType == WEAPONTYPE_FIRE_STAFF then
		tWeaponTable.IsStave = true
		tWeaponTable.IsFireStaff = true
	elseif iSubType == WEAPONTYPE_FROST_STAFF then
		tWeaponTable.IsStave = true
		tWeaponTable.IsFrostStaff = true
	elseif iSubType == WEAPONTYPE_LIGHTNING_STAFF then
		tWeaponTable.IsStave = true
		tWeaponTable.IsLightStaff = true
	elseif iSubType == WEAPONTYPE_HEALING_STAFF then
		tWeaponTable.IsStave = true
		tWeaponTable.IsHealingStaff = true
	elseif iSubType == WEAPONTYPE_SHIELD then
		tWeaponTable.IsShield = true
	end
	return tWeaponTable
end

local function GetCraftingInfo(_lLink)
	local tCraftingInfo = {
		CraftingType = CRAFTING_TYPE_INVALID, IsCraftingMat = false, IsBlackSmithingMat = false, IsClothierMat = false, IsEnchantingMat = false,  IsAlchemyMat = false, IsProvisioningMat = false, IsWoodworkingMat = false,
	}
	tCraftingInfo.CraftingType = GetItemLinkCraftingSkillType(_lLink)
	
	if tCraftingInfo.CraftingType == CRAFTING_TYPE_BLACKSMITHING then
		tCraftingInfo.IsCraftingMat = true
		tCraftingInfo.IsBlackSmithingMat = true
	elseif tCraftingInfo.CraftingType == CRAFTING_TYPE_CLOTHIER then
		tCraftingInfo.IsCraftingMat = true
		tCraftingInfo.IsClothierMat = true
	elseif tCraftingInfo.CraftingType == CRAFTING_TYPE_ENCHANTING then
		tCraftingInfo.IsCraftingMat = true
		tCraftingInfo.IsEnchantingMat = true
	elseif tCraftingInfo.CraftingType == CRAFTING_TYPE_ALCHEMY then
		tCraftingInfo.IsCraftingMat = true
		tCraftingInfo.IsAlchemyMat = true
	elseif tCraftingInfo.CraftingType == CRAFTING_TYPE_PROVISIONING then
		tCraftingInfo.IsCraftingMat = true
		tCraftingInfo.IsProvisioningMat = true
	elseif tCraftingInfo.CraftingType == CRAFTING_TYPE_WOODWORKING then
		tCraftingInfo.IsCraftingMat = true
		tCraftingInfo.IsWoodworkingMat = true
	end
	return tCraftingInfo
end

----------------------------------------------
--  SetData:  LibSortIt Callback Func  --
----------------------------------------------
function SortIt.SetData(_iBagId,_iSlotId)
	local lLink = GetItemLink(_iBagId,_iSlotId)
	local sName = GetItemName(_iBagId,_iSlotId)
	local iItemType = GetItemLinkItemType(lLink)
	local iEquipType = GetItemLinkEquipType(lLink)
	local iQuality = GetItemLinkQuality(lLink)
	local tArmorTable = GetArmorInfo(_iBagId, _iSlotId)
	local tWeaponTable = GetWeaponInfo(_iBagId, _iSlotId)
	local tCraftingInfo = GetCraftingInfo(lLink)
	
	local tSortPackKeys = {
		SortIt_Name 			= sName,
		SortIt_ItemType 		= iItemType,
		SortIt_EquipType 		= iEquipType,
		SortIt_Quality 			= iQuality,
		SortIt_Armor 			= tArmorTable.IsArmor,
		SortIt_HeavyArmor 		= tArmorTable.IsHeavyArmor,
		SortIt_MediumArmor 		= tArmorTable.IsMediumArmor,
		SortIt_LightArmor 		= tArmorTable.IsLightArmor,
		SortIt_Jewelry 			= tArmorTable.IsJewelry,
		SortIt_Weapons			= tWeaponTable.IsWeapon,
		SortIt_Shields 			= tWeaponTable.IsShield,
		SortIt_1hWeapon			= tWeaponTable.Is1hWeapon,
		SortIt_1hMace			= tWeaponTable.Is1hMace,
		SortIt_1hAxe			= tWeaponTable.Is1hAxe,
		SortIt_1hSword			= tWeaponTable.Is1hSword,
		SortIt_Dagger			= tWeaponTable.IsDagger,
		SortIt_Bow				= tWeaponTable.IsBow,
		SortIt_2hWeapon			= tWeaponTable.Is2hWeapon,
		SortIt_2hMace			= tWeaponTable.Is2hMace,
		SortIt_2hAxe			= tWeaponTable.Is2hAxe,
		SortIt_2hSword			= tWeaponTable.Is2hSword,
		SortIt_Staves			= tWeaponTable.IsStave,
		SortIt_FireStaff		= tWeaponTable.IsFireStaff,
		SortIt_FrostStaff		= tWeaponTable.IsFrostStaff,
		SortIt_LightningStaff	= tWeaponTable.IsLightStaff,
		SortIt_HealingStaff		= tWeaponTable.IsHealingStaff,
		SortIt_CraftingType		= tCraftingInfo.CraftingType,
		SortIt_CraftingMat		= tCraftingInfo.IsCraftingMat,
		SortIt_BlackSmithingMat	= tCraftingInfo.IsBlackSmithingMat,
		SortIt_ClothierMat		= tCraftingInfo.IsClothierMat,
		SortIt_EnchantingMat	= tCraftingInfo.IsEnchantingMat,
		SortIt_AlchemMat		= tCraftingInfo.IsAlchemyMat,
		SortIt_ProvisioningMat	= tCraftingInfo.IsProvisioningMat,
		SortIt_WoodworkingMat	= tCraftingInfo.IsWoodworkingMat,
	}
	return tSortPackKeys
end

local function GetCraftingInfo()
	local tCraftingInfo = {
		
	}
end

function SortIt.CreateSortKeys()
	local tSortKeys = {
		[1] = {key = "SortIt_ItemType", 		displayName = "Item Type", 			isNumeric = true},
		[2] = {key = "SortIt_EquipType", 		displayName = "Equip Type", 		isNumeric = true},
		[3] = {key = "SortIt_Quality", 			displayName = "Quality", 			isNumeric = true},
		[4] = {key = "SortIt_Name", 			displayName = "Name", 				isNumeric = false},
		[5] = {key = "SortIt_Armor", 			displayName = "Armor", 				isNumeric = false},
		[6] = {key = "SortIt_HeavyArmor", 		displayName = "Heavy Armor", 		isNumeric = false},
		[7] = {key = "SortIt_MediumArmor", 		displayName = "Medium Armor", 		isNumeric = false},
		[8] = {key = "SortIt_LightArmor", 		displayName = "Light Armor", 		isNumeric = false},
		[9] = {key = "SortIt_Jewelry", 			displayName = "Jewelry", 			isNumeric = false},
		[10] = {key = "SortIt_Shields", 		displayName = "Shields", 			isNumeric = false},
		[11] = {key = "SortIt_Weapons", 		displayName = "Weapons", 			isNumeric = false},
		[12] = {key = "SortIt_1hWeapon", 		displayName = "1H Weapon", 			isNumeric = false},
		[13] = {key = "SortIt_1hMace", 			displayName = "1H Maces", 			isNumeric = false},
		[14] = {key = "SortIt_1hAxe", 			displayName = "1H Axes", 			isNumeric = false},
		[15] = {key = "SortIt_1hSword", 		displayName = "1H Swords", 			isNumeric = false},
		[16] = {key = "SortIt_Dagger", 			displayName = "Daggers", 			isNumeric = false},
		[17] = {key = "SortIt_Bow", 			displayName = "Bows", 				isNumeric = false},
		[18] = {key = "SortIt_2hWeapon", 		displayName = "2H Weapon", 			isNumeric = false},
		[19] = {key = "SortIt_2hMace", 			displayName = "2H Maces", 			isNumeric = false},
		[20] = {key = "SortIt_2hAxe", 			displayName = "2H Axes", 			isNumeric = false},
		[21] = {key = "SortIt_2hSword", 		displayName = "2H Swords", 			isNumeric = false},
		[22] = {key = "SortIt_Staves", 			displayName = "Staves", 			isNumeric = false},
		[23] = {key = "SortIt_FireStaff", 		displayName = "Fire Staves", 		isNumeric = false},
		[24] = {key = "SortIt_FrostStaff", 		displayName = "Frost Staves", 		isNumeric = false},
		[25] = {key = "SortIt_LightningStaff", 	displayName = "Lightning Staves", 	isNumeric = false},
		[26] = {key = "SortIt_HealingStaff", 	displayName = "Healing Staves", 	isNumeric = false},
		[27] = {key = "SortIt_CraftingType", 	displayName = "Crafting Mat Type", 	isNumeric = true},
		[28] = {key = "SortIt_CraftingMat", 	displayName = "Crafting Material", 	isNumeric = false},
		[29] = {key = "SortIt_BlackSmithingMat",displayName = "Blacksmithing Material", isNumeric = false},
		[30] = {key = "SortIt_ClothierMat", 	displayName = "Clothier Material", 		isNumeric = false},
		[31] = {key = "SortIt_EnchantingMat", 	displayName = "Enchanting Material", 	isNumeric = false},
		[32] = {key = "SortIt_AlchemMat", 		displayName = "Alchemy Material", 		isNumeric = false},
		[33] = {key = "SortIt_ProvisioningMat", displayName = "Provisioning Material", 	isNumeric = false},
		[34] = {key = "SortIt_WoodworkingMat", displayName = "Woodworking Material", 	isNumeric = false},
	}
	LIBSI:CreateSortKeys(SortIt.name, SortIt.SetData, tSortKeys)
end
function SortIt.CreateSortPacks()
	local tSortPacks = {
	--[[
		[1] = {
			displayName = "Item Equip Quality",
			sortKeys = {
			[1] = {key = "SortIt_ItemType", 	Asc = false},
			[3] = {key = "SortIt_Quality", 		Asc = true},
			[2] = {key = "SortIt_EquipType", 	Asc = true},
			[4] = {key = "SortIt_Name", 		Asc = true},
			},
		},
		[2] = {
			displayName = "Quality Desc",
			sortKeys = {
			[1] = {key = "SortIt_Quality", 		Asc = false},
			[2] = {key = "SortIt_ItemType", 	Asc = true},
			[3] = {key = "SortIt_EquipType", 	Asc = true},
			[4] = {key = "SortIt_Name", 		Asc = false},
			},
		},
		[3] = {
			displayName = "H 1m med 1A li bow 2M na",
			sortKeys = {
			[1] = {key = "SortIt_HeavyArmor", 	Asc = false},
			[2] = {key = "SortIt_1hMace", 		Asc = false},
			[3] = {key = "SortIt_MediumArmor", 	Asc = false},
			[4] = {key = "SortIt_1hAxe", 		Asc = false},
			[5] = {key = "SortIt_LightArmor", 	Asc = false},
			[6] = {key = "SortIt_Bow", 			Asc = false},
			[7] = {key = "SortIt_2hMace", 		Asc = false},
			[8] = {key = "SortIt_Name", 		Asc = false},
			},
		},
		--]]
	}
	-- Grab all the sortPacks stored in Saved variables & load them into the pack
	-- to call CreateSortPacks once, to create them all.
	for k,v in ipairs(SortIt.SavedVariables.sortPacks) do
		table.insert(tSortPacks, v)
	end
	LIBSI:CreateSortPacks(SortIt.name, tSortPacks)
end
