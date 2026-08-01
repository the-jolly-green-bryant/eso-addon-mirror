

---[[
--Register LAM with LibStub
local MAJOR, MINOR = "LibNeed4Research", 5
local ln4r, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not ln4r then return end	--the same or newer version of this lib is already loaded into memory 
--]]

local ASV
local LIBNEED4RESEARCHVARVERSION = 2  -- DO NOT CHANGE

local varDefaults = {
	KnownTraitTable = {},
	KnownRecipeTable = {},
	PlayerNames = {},
}

local tIsTraitResearchable = {
	[ITEM_TRAIT_TYPE_ARMOR_DIVINES] 		= true,
	[ITEM_TRAIT_TYPE_ARMOR_EXPLORATION] 	= true,
	[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] 	= true,
	[ITEM_TRAIT_TYPE_ARMOR_INFUSED] 		= true,
	[ITEM_TRAIT_TYPE_ARMOR_INTRICATE] 		= false,
	[ITEM_TRAIT_TYPE_ARMOR_ORNATE] 			= false,
	[ITEM_TRAIT_TYPE_ARMOR_REINFORCED]		= true,
	[ITEM_TRAIT_TYPE_ARMOR_STURDY] 			= true,
	[ITEM_TRAIT_TYPE_ARMOR_TRAINING] 		= true,
	[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED]		= true,
	[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] 		= true,
	
	[ITEM_TRAIT_TYPE_WEAPON_CHARGED] 		= true,
	[ITEM_TRAIT_TYPE_WEAPON_DEFENDING] 		= true,
	[ITEM_TRAIT_TYPE_WEAPON_INFUSED] 		= true,
	[ITEM_TRAIT_TYPE_WEAPON_INTRICATE] 		= false,
	[ITEM_TRAIT_TYPE_WEAPON_ORNATE] 		= false,
	[ITEM_TRAIT_TYPE_WEAPON_POWERED] 		= true,
	[ITEM_TRAIT_TYPE_WEAPON_PRECISE] 		= true,
	[ITEM_TRAIT_TYPE_WEAPON_SHARPENED] 		= true,
	[ITEM_TRAIT_TYPE_WEAPON_TRAINING] 		= true,
	[ITEM_TRAIT_TYPE_WEAPON_WEIGHTED]	 	= true,
	[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] 		= true,
	
	[ITEM_TRAIT_TYPE_JEWELRY_ARCANE] 		= false,
	[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY]	 	= false,
	[ITEM_TRAIT_TYPE_JEWELRY_ORNATE] 		= false,
	[ITEM_TRAIT_TYPE_JEWELRY_ROBUST] 		= false,

	[ITEM_TRAIT_TYPE_NONE] 					= false,
}

-- Used to find the crafting type & research Index for items
local tEquipTypes = {
	[ITEMTYPE_ARMOR] = {
		--[ARMORTYPE_NONE] 	= {}, -- jewelry is excluded --
		[ARMORTYPE_LIGHT] 	= {
			["CRAFTINGSKILLTYPE"] 	= CRAFTING_TYPE_CLOTHIER,
			[EQUIP_TYPE_CHEST]		= 1,
			[EQUIP_TYPE_FEET]		= 2,
			[EQUIP_TYPE_HAND]		= 3,
			[EQUIP_TYPE_HEAD]		= 4,
			[EQUIP_TYPE_LEGS]		= 5,
			[EQUIP_TYPE_SHOULDERS]	= 6,
			[EQUIP_TYPE_WAIST]		= 7,
		},
		[ARMORTYPE_MEDIUM] 	= {
			["CRAFTINGSKILLTYPE"] 	= CRAFTING_TYPE_CLOTHIER,
			[EQUIP_TYPE_CHEST]		= 8,
			[EQUIP_TYPE_FEET]		= 9,
			[EQUIP_TYPE_HAND]		= 10,
			[EQUIP_TYPE_HEAD]		= 11,
			[EQUIP_TYPE_LEGS]		= 12,
			[EQUIP_TYPE_SHOULDERS]	= 13,
			[EQUIP_TYPE_WAIST]		= 14,
		},
		[ARMORTYPE_HEAVY] 	= {
			["CRAFTINGSKILLTYPE"] 	= CRAFTING_TYPE_BLACKSMITHING,
			[EQUIP_TYPE_CHEST]		= 8,
			[EQUIP_TYPE_FEET]		= 9,
			[EQUIP_TYPE_HAND]		= 10,
			[EQUIP_TYPE_HEAD]		= 11,
			[EQUIP_TYPE_LEGS]		= 12,
			[EQUIP_TYPE_SHOULDERS]	= 13,
			[EQUIP_TYPE_WAIST]		= 14,
		},
	},
	[ITEMTYPE_WEAPON] = {
		[WEAPONTYPE_SHIELD]				= {
			[EQUIP_TYPE_OFF_HAND] = 6, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_WOODWORKING},
		[WEAPONTYPE_AXE]				= {
			[EQUIP_TYPE_ONE_HAND] = 1, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_BLACKSMITHING},
		[WEAPONTYPE_DAGGER]				= {
			[EQUIP_TYPE_ONE_HAND] = 7, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_BLACKSMITHING},
		[WEAPONTYPE_HAMMER]				= {
			[EQUIP_TYPE_ONE_HAND] = 2, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_BLACKSMITHING},
		[WEAPONTYPE_SWORD]				= {
			[EQUIP_TYPE_ONE_HAND] = 3, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_BLACKSMITHING},
		[WEAPONTYPE_TWO_HANDED_AXE]		= {
			[EQUIP_TYPE_TWO_HAND] = 4, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_BLACKSMITHING},
		[WEAPONTYPE_TWO_HANDED_HAMMER]	= {
			[EQUIP_TYPE_TWO_HAND] = 5, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_BLACKSMITHING},
		[WEAPONTYPE_TWO_HANDED_SWORD]	= {
			[EQUIP_TYPE_TWO_HAND] = 6, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_BLACKSMITHING},
		[WEAPONTYPE_BOW]				= {
			[EQUIP_TYPE_TWO_HAND] = 1, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_WOODWORKING},
		[WEAPONTYPE_FIRE_STAFF]			= {
			[EQUIP_TYPE_TWO_HAND] = 2, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_WOODWORKING},
		[WEAPONTYPE_FROST_STAFF]		= {
			[EQUIP_TYPE_TWO_HAND] = 3, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_WOODWORKING},
		[WEAPONTYPE_LIGHTNING_STAFF] 	= {
			[EQUIP_TYPE_TWO_HAND] = 4, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_WOODWORKING},
		[WEAPONTYPE_HEALING_STAFF]		= {
			[EQUIP_TYPE_TWO_HAND] = 5, ["CRAFTINGSKILLTYPE"] = CRAFTING_TYPE_WOODWORKING},
	},
}


------------------------------------------------------------------------
-- Get Trait Index --
------------------------------------------------------------------------
local function GetTraitIndex(_BagIdOrLink, _iSlotId)
	local lLink = _BagIdOrLink
	if _iSlotId then
		lLink = GetItemLink(_BagIdOrLink,_iSlotId)
	end
	local iTraitType = GetItemLinkTraitInfo(lLink)
	if not tIsTraitResearchable[iTraitType] then return end
	
	if ((iTraitType == ITEM_TRAIT_TYPE_WEAPON_NIRNHONED) 
	or (iTraitType == ITEM_TRAIT_TYPE_ARMOR_NIRNHONED)) then
		return 9
	end
	return (iTraitType % 10)
end

local function GetResearchInfo(_BagIdOrLink, _iSlotId)
	local lLink = _BagIdOrLink
	if _iSlotId then
		lLink = GetItemLink(_BagIdOrLink, _iSlotId)
	end
	
	local iTraitType = GetItemLinkTraitInfo(lLink)    
	if not tIsTraitResearchable[iTraitType] then return end
	
	local iItemType = GetItemLinkItemType(lLink)     
	local iSubType = 0 -- 0 is the same return as WEAPONTYPE_NONE & ARMORTYPE_NONE 
	
	if iItemType == ITEMTYPE_ARMOR then
		iSubType = GetItemLinkArmorType(lLink)
	elseif iItemType == ITEMTYPE_WEAPON then
		iSubType = GetItemLinkWeaponType(lLink)
	else
		return
	end
	
	if not (tEquipTypes[iItemType] and tEquipTypes[iItemType][iSubType]) then return end
	
	local iEquipType 			= GetItemLinkEquipType(lLink)
	local iCraftingSkillType 	= tEquipTypes[iItemType][iSubType]["CRAFTINGSKILLTYPE"]
	local iResearchLineIndex 	= tEquipTypes[iItemType][iSubType][iEquipType]
	local iTraitIndex 			= GetTraitIndex(_BagIdOrLink, _iSlotId)
	
	return iCraftingSkillType, iResearchLineIndex, iTraitIndex
end

--[[
ZO_CraftingUtils_IsTraitAppliedToWeapons(traitType)
ZO_CraftingUtils_IsTraitAppliedToArmor(traitType)
--]]

local function IsTraitNeeded(_sPlayerName, _iCraftingSkillType, _iResearchLineIndex, _iTraitIndex)
	--[[ checks to make sure were not getting called to early by an addon, before the libraries saved vars have loaded. Even though this is local, this is called from a function they can access.
	--]]
	if not (ASV and ASV.KnownTraitTable and ASV.KnownTraitTable[_sPlayerName]) then return true end
	if not ASV.KnownTraitTable[_sPlayerName][_iCraftingSkillType] then return true end
	if not ASV.KnownTraitTable[_sPlayerName][_iCraftingSkillType][_iResearchLineIndex] then return true end
	
	if ASV.KnownTraitTable[_sPlayerName][_iCraftingSkillType][_iResearchLineIndex][_iTraitIndex] then
		return false
	end
	return true
end

function ln4r:DoesPlayerNeedTrait(_sPlayerName, _iBagIdOrLink, _iSlotId)
	local iCraftingSkillType, iResearchLineIndex, iTraitIndex = GetResearchInfo(_iBagIdOrLink, _iSlotId)
	
	-- Its either not a researchable ItemType or doesn't have a researchable trait
	if not (iCraftingSkillType and iResearchLineIndex and iTraitIndex) then return false end
	
	if IsTraitNeeded(_sPlayerName, iCraftingSkillType, iResearchLineIndex, iTraitIndex) then
		return true, iCraftingSkillType, iResearchLineIndex, iTraitIndex
	end
	return false
end

function ln4r:DoAnyPlayersNeedTrait(_iBagIdOrLink, _iSlotId)
	local iCraftingSkillType, iResearchLineIndex, iTraitIndex = GetResearchInfo(_iBagIdOrLink, _iSlotId)
	
	-- Its either not a researchable ItemType or doesn't have a researchable trait
	if not (iCraftingSkillType and iResearchLineIndex and iTraitIndex) then return end
	
	--[[ check to make sure were not getting called to early by an addon, before the libraries saved vars have loaded. Default to true, player needs, so nothing bad happens to the item.
	--]]
	if not (ASV and ASV.PlayerNames) then return end
	
	local sCurrentPlayerName = GetUnitName("player")
	
	local tPlayersThatNeed = {
		CraftingSkillType	= iCraftingSkillType,
		ResearchLineIndex 	= iResearchLineIndex,
		TraitIndex 			= iTraitIndex,
		PlayerCount 		= 0,
		PlayerNames			= {},
		PlayerNeeds			= false,
		OtherNeeds			= false,
	}
	
	for sPlayerName,v in pairs(ASV.PlayerNames) do
		if IsTraitNeeded(sPlayerName, iCraftingSkillType, iResearchLineIndex, iTraitIndex) then
			tPlayersThatNeed.PlayerCount = tPlayersThatNeed.PlayerCount + 1
			
			if sPlayerName == sCurrentPlayerName then
				tPlayersThatNeed.PlayerNeeds = true
			else
				tPlayersThatNeed.OtherNeeds = true
			end
			tPlayersThatNeed.PlayerNames[sPlayerName] = true
		end
	end
	if tPlayersThatNeed.PlayerCount > 0 then
		return tPlayersThatNeed
	end
end
--[[
function ln4r:GetRecipeIndices(_iBagIdOrLink, _iSlotId)
	local lLink = _iBagIdOrLink
	if _iSlotId then
		lLink = GetItemLink(_iBagIdOrLink, _iSlotId)
	end 
	
	local iItemType = GetItemLinkItemType(lLink)    
	if iItemType ~= ITEMTYPE_RECIPE then return end

	local lRecipeResultItemLink = GetItemLinkRecipeResultItemLink(lLink)
	local iNumRecipeLists = GetNumRecipeLists() 
		
	for iRecipeListIndex = 1, iNumRecipeLists do
		local _, iNumRecipes = GetRecipeListInfo(iRecipeListIndex)
		for iRecipeIndex = 1, iNumRecipes do         
			local lRecipeResultTableLink = GetRecipeResultItemLink(iRecipeListIndex, iRecipeIndex) 
			if lRecipeResultItemLink == lRecipeResultTableLink then
				return iRecipeListIndex, iRecipeIndex, lRecipeResultItemLink
			end
		end
	end
end
--]]
function ln4r:DoesPlayerNeedRecipe(_sPlayerName, _iBagIdOrLink, _iSlotId)
	--[[ check to make sure were not getting called to early by an addon, before the libraries saved vars have loaded. --]]
	if not (ASV and ASV.KnownRecipeTable and ASV.KnownRecipeTable[_sPlayerName]) then return end
	
	local lLink = _iBagIdOrLink
	if _iSlotId then
		lLink = GetItemLink(_iBagIdOrLink, _iSlotId)
	end 
	
	local iItemType = GetItemLinkItemType(lLink)
	if iItemType ~= ITEMTYPE_RECIPE then return false end
	
	local lRecipeResultItemLink = GetItemLinkRecipeResultItemLink(lLink)
	local sItemId = select(4,ZO_LinkHandler_ParseLink(lRecipeResultItemLink))
	local iItemId = tonumber(sItemId)
	
	if type(iItemId) == "number" and ASV.KnownRecipeTable[_sPlayerName][iItemId] then
		return false
	end
	return true
end

function ln4r:DoAnyPlayersNeedRecipe(_iBagIdOrLink, _iSlotId)
	local lLink = _iBagIdOrLink
	if _iSlotId then
		lLink = GetItemLink(_iBagIdOrLink, _iSlotId)
	end 
	
	local iItemType = GetItemLinkItemType(lLink)    
	if iItemType ~= ITEMTYPE_RECIPE then return end
	-- check to make sure were not getting called to early by an addon, before the libraries saved
	-- vars have loaded.
	if not (ASV and ASV.PlayerNames) then return end
	
	local sCurrentPlayerName = GetUnitName("player")  
	
	local tPlayersThatNeed = {
		CraftingSkillType	= CRAFTING_TYPE_PROVISIONING,
		PlayerCount 		= 0,
		PlayerNames			= {},
		PlayerNeeds			= false,
		OtherNeeds			= false,
	}
	for sPlayerName,v in pairs(ASV.PlayerNames) do
		local bPlayerNeedsRecipe = ln4r:DoesPlayerNeedRecipe(sPlayerName, _iBagIdOrLink, _iSlotId)
		if bPlayerNeedsRecipe then
			tPlayersThatNeed.PlayerCount = tPlayersThatNeed.PlayerCount + 1
			
			if sPlayerName == sCurrentPlayerName then
				tPlayersThatNeed.PlayerNeeds = true
			else
				tPlayersThatNeed.OtherNeeds = true
			end
			tPlayersThatNeed.PlayerNames[sPlayerName] = true
		end
	end
	if tPlayersThatNeed.PlayerCount > 0 then
		return tPlayersThatNeed
	end
end


local function AddKnownTrait(_EventCode,  _iCraftingSkillType,  _iResearchLineIndex,  _iTraitIndex)
	if _iCraftingSkillType == CRAFTING_TYPE_INVALID then return end
	local sPlayerName = GetUnitName("player")
	
	if not ASV.KnownTraitTable[sPlayerName][_iCraftingSkillType][_iResearchLineIndex] then
		ASV.KnownTraitTable[sPlayerName][_iCraftingSkillType][_iResearchLineIndex] = {}
	end
	
    local iTraitType  = GetSmithingResearchLineTraitInfo(_iCraftingSkillType, _iResearchLineIndex, _iTraitIndex)
	
	if iTraitType ~= ITEM_TRAIT_TYPE_NONE then
		ASV.KnownTraitTable[sPlayerName][_iCraftingSkillType][_iResearchLineIndex][_iTraitIndex] = true
	end
end

local function AddKnownRecipe(_EventCode, _iRecipeListIndex, _iRecipeIndex)
	local sPlayerName = GetUnitName("player")
    local lRecipeResultItemLink = GetRecipeResultItemLink(_iRecipeListIndex, _iRecipeIndex)
	local sItemId = select(4,ZO_LinkHandler_ParseLink(lRecipeResultItemLink))
	local iItemId = tonumber(sItemId)
	
	if type(iItemId) == "number" then 
		ASV.KnownRecipeTable[sPlayerName][iItemId] = true
	end
end

local function UpdateUnKnownRecipes()
	for iRecipeListIndex = 1, GetNumRecipeLists()  do
		local sRecipeListName, iNumRecipes = GetRecipeListInfo(iRecipeListIndex)
		for iRecipeIndex = 1, iNumRecipes do
			local bIsKnown, sRecipeName = GetRecipeInfo(iRecipeListIndex, iRecipeIndex)
			if bIsKnown then 
				AddKnownRecipe(nil, iRecipeListIndex, iRecipeIndex) 
			end
		end
	end
end

local function UpdateCraftingSkillTraits(_iCraftingSkillType)
	for iResearchLineIndex = 1, GetNumSmithingResearchLines(_iCraftingSkillType) do
		local _,_, iNumTraits = GetSmithingResearchLineInfo(_iCraftingSkillType, iResearchLineIndex)
		for iTraitIndex = 1, iNumTraits do
			local iTraitType, _, bIsKnown = GetSmithingResearchLineTraitInfo(_iCraftingSkillType, iResearchLineIndex, iTraitIndex)
			-- if its not known, check to see if we are researching it --
			if bIsKnown or GetSmithingResearchLineTraitTimes(_iCraftingSkillType, iResearchLineIndex, iTraitIndex) ~= nil then
				AddKnownTrait(nil,  _iCraftingSkillType,  iResearchLineIndex,  iTraitIndex) 
			end
		end
	end
end
local function UpdateUnKnownTraits()
	UpdateCraftingSkillTraits(CRAFTING_TYPE_BLACKSMITHING)
	UpdateCraftingSkillTraits(CRAFTING_TYPE_CLOTHIER)
	UpdateCraftingSkillTraits(CRAFTING_TYPE_WOODWORKING)
end

---------------------------------------------------------------------------------
---- Update Tables ----
--	Called during initialization() --
---------------------------------------------------------------------------------
local function UpdateTables()
	local sPlayerName = GetUnitName("player")
	
	if not ASV.KnownTraitTable[sPlayerName] then
		ASV.KnownTraitTable[sPlayerName] = {
			[CRAFTING_TYPE_BLACKSMITHING] 	= {},
			[CRAFTING_TYPE_CLOTHIER] 		= {},
			[CRAFTING_TYPE_WOODWORKING] 	= {},
		}
	end
	if not ASV.KnownRecipeTable[sPlayerName] then
		ASV.KnownRecipeTable[sPlayerName] = {}
	end
	if not ASV.PlayerNames[sPlayerName] then
		ASV.PlayerNames[sPlayerName] = true
	end
	
	UpdateUnKnownTraits()
	UpdateUnKnownRecipes()
end

local function OnAddOnLoaded(_event, _sAddonName)
	if _sAddonName == "ZO_Ingame" then
		ln4r:Initialize()
	end
end
function ln4r:Initialize()
	ln4r.AccountSavedVariables = ZO_SavedVars:NewAccountWide("ZO_Ingame_SavedVariables", LIBNEED4RESEARCHVARVERSION, "LibNeed4ResearchVars", varDefaults)

	ASV = ln4r.AccountSavedVariables
	--Need4Research = ln4r.AccountSavedVariables
	UpdateTables()
	
	-- register for events
	EVENT_MANAGER:RegisterForEvent("LibNeed4Research", EVENT_SMITHING_TRAIT_RESEARCH_STARTED, AddKnownTrait)
	EVENT_MANAGER:RegisterForEvent("LibNeed4Research", EVENT_RECIPE_LEARNED, AddKnownRecipe)

	-- Unregister events
	EVENT_MANAGER:UnregisterForEvent("LibNeed4Research", EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent("LibNeed4Research", EVENT_ADD_ON_LOADED, OnAddOnLoaded)






