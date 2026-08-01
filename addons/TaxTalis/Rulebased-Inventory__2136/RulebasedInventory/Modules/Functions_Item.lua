-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: Functions_Item.lua
-- File Description: This file contains item related functions, to get informations about the item
-- Load Order Requirements: before Rule, after RuleEnvironment, Utilities, any Extensions
-- 
-----------------------------------------------------------------------------------

-- Imports
local RbI = RulebasedInventory
local ruleEnv = RbI.ruleEnvironment
local self = RbI.executionEnv
local ctx = self.ctx
local ext = RbI.extensions
local utils = RbI.utils
local dataTypeHandler = RbI.dataTypeHandler

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Helper functions ---------------------------------------------------------
------------------------------------------------------------------------------

-- Fix for monstersets which return 67 but should return 26
function RbI.GetItemLinkItemStyleFix(itemLink)
	local style = GetItemLinkItemStyle(itemLink)
	if(style == 67) then
		style = 26
	end
	return style
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Functions -----------------------------------------------------------------
------------------------------------------------------------------------------

local function ReturnItemDataValueAll(ItemDataFunction, inputType)
	if(inputType == 1) then
		return {ItemDataFunction(ctx.itemLink)}
	else
		return {ItemDataFunction(ctx.bag, ctx.slot)}
	end
end

local function ReturnItemDataValue(ItemDataFunction, itemDataIndex, inputType)
	return ReturnItemDataValueAll(ItemDataFunction, inputType)[itemDataIndex]
end

local function getItemData(ItemDataFunction, itemDataIndex, inputType)
	itemDataIndex = itemDataIndex or 1
	if(inputType == 1) then
		return select(itemDataIndex, ItemDataFunction(ctx.itemLink))
	else
		return select(itemDataIndex, ItemDataFunction(ctx.bag, ctx.slot))
	end
end
local function CheckItemDataByTable(ItemDataFunction, itemDataIndex, name, inputType, ...)
	local itemData = getItemData(ItemDataFunction, itemDataIndex, inputType)
	return ruleEnv.Validate(name, false, name, itemData, ...)
end
local function CheckItemDataByMatrix(ItemDataFunction, name, inputType, ...)
	local itemData = {getItemData(ItemDataFunction, nil, inputType)}
	return ruleEnv.Validate(name, false, name, itemData, ...)
end

local function CheckItemDataByValue(returnType, ItemDataFunction, itemDataIndex, inputType, ...)
	local input = {...}
	if(#input == 0) then
		return ReturnItemDataValue(ItemDataFunction, itemDataIndex, inputType)
	end

	local itemData = getItemData(ItemDataFunction, itemDataIndex, inputType)
	if(returnType == ruleEnv.GET_STRING) then
		itemData = string.lower(zo_strformat('<<1>>', itemData))
	end

	local match, message = utils.textCheckMany(input, {itemData}, returnType == ruleEnv.GET_STRING)
	if match == nil then
		ruleEnv.error(message)
		return false
	end
	return match
end

local function GetItemLinkSetInfoSetName(itemLink)
	local _, name = GetItemLinkSetInfo(itemLink)
	return zo_strformat("<<1>>", name)
end

-- function name, ingame data retrieval function, index of return value to look at, rbi compare function, 1=itemlink / 2=bag+slot
-- rbi compare functions:
-- 'value' check for names (any match). Also uses LibTextFilter, when installed.
-- 'table' at least one filter argument (any match) which has to be included in the 'data'-domain, otherwise throws ruleEnv.errorInvalidArgument
-- 'return' direct return for numbers and booleans without any arguments
-- 'matrix' like 'table' but checks all values instead of a specific index
local itemFunctions = {}
itemFunctions.armorType		= {GetItemLinkArmorType, 						1, 'table', 	1}
itemFunctions.bag			= {function() return ctx.bag end, 		        1, 'table', 	1}
itemFunctions.bindType 		= {GetItemLinkBindType, 						1, 'table', 	1}
itemFunctions.bound 		= {IsItemLinkBound, 							1, 'return', 	1, ruleEnv.GET_BOOL }
itemFunctions.craftingRankRequired = {GetItemLinkRequiredCraftingSkillRank,	1, 'value', 	1}
itemFunctions.crownStore 	= {IsItemFromCrownStore, 						1, 'return', 	2, ruleEnv.GET_BOOL } -- integrated in itemLink allFlags
itemFunctions.crownCrate 	= {IsItemFromCrownCrate, 						1, 'return', 	2, ruleEnv.GET_BOOL } -- integrated in itemLink allFlags
itemFunctions.crownGems 	= {GetNumCrownGemsFromItemManualGemification, 	1, 'return', 	2} -- needed? -- NOT interleave save
itemFunctions.equipType 	= {GetItemLinkEquipType, 						1, 'table', 	1}
itemFunctions.id 			= {GetItemLinkItemId, 							1, 'value', 	1}
itemFunctions.instanceId 	= {GetItemInstanceId, 							1, 'value', 	2} -- not needed -- NOT interleave save
itemFunctions.quality 		= {GetItemLinkQuality, 							1, 'table', 	1}
itemFunctions.traitInfo 	= {GetItemTraitInformationFromItemLink,			1, 'table', 	1} -- not needed, guess not that important -- NOT interleave save
itemFunctions.trait 		= {GetItemLinkTraitType, 						1, 'table', 	1}
itemFunctions.traitCategory = {GetItemLinkTraitCategory, 				    1, 'table', 	1}
itemFunctions.style 		= {RbI.GetItemLinkItemStyleFix, 				1, 'table', 	1}
itemFunctions.type 			= {GetItemLinkItemType, 						1, 'table', 	1}
itemFunctions.sType 		= {GetItemLinkItemType, 						2, 'table', 	1} -- 'SpecializedItemType'
itemFunctions.weaponType 	= {GetItemLinkWeaponType, 						1, 'table', 	1}
itemFunctions.glyphMinLevel = {GetItemLinkGlyphMinLevels, 					1, 'value', 	1}
itemFunctions.glyphMinCP 	= {GetItemLinkGlyphMinLevels, 					2, 'value', 	1}
itemFunctions.name 			= {GetItemLinkName, 							1, 'value', 	1, ruleEnv.GET_STRING }
itemFunctions.set 			= {GetItemLinkSetInfo, 							1, 'return', 	1, ruleEnv.GET_BOOL }
itemFunctions.setBonusCount	= {GetItemLinkSetInfo, 							3, 'return', 	1}
itemFunctions.setId 		= {GetItemLinkSetInfo, 							6, 'value', 	1}
itemFunctions.setName 		= {GetItemLinkSetInfoSetName,					1, 'value', 	1, ruleEnv.GET_STRING }
itemFunctions.value 		= {GetItemLinkValue, 							1, 'return', 	1}
itemFunctions.junked 		= {IsItemJunk, 									1, 'return', 	2} -- not needed, junked  executes stackwise, stacking on junk is o.k. -- NOT interleave save
itemFunctions.crafted 		= {IsItemLinkCrafted, 							1, 'return', 	1, ruleEnv.GET_BOOL }
itemFunctions.creator 		= {GetItemCreatorName, 							1, 'value', 	2, ruleEnv.GET_STRING } -- not needed, guess not that important -- NOT interleave save
itemFunctions.recipeKnown 	= {IsItemLinkRecipeKnown, 						1, 'return', 	1, ruleEnv.GET_BOOL }
itemFunctions.motifKnown 	= {IsItemLinkBookKnown, 						1, 'return', 	1, ruleEnv.GET_BOOL }
itemFunctions.stackable 	= {IsItemLinkStackable, 						1, 'return', 	1, ruleEnv.GET_BOOL }
itemFunctions.stolen 		= {IsItemLinkStolen, 							1, 'return', 	1, ruleEnv.GET_BOOL }
itemFunctions.unique 		= {IsItemLinkUnique, 							1, 'return', 	1, ruleEnv.GET_BOOL }
itemFunctions.setcollection	= {IsItemLinkSetCollectionPiece, 				1, 'return', 	1, ruleEnv.GET_BOOL }
itemFunctions.reconstructed	= {IsItemLinkReconstructed, 					1, 'return', 	1,	 ruleEnv.GET_BOOL }
itemFunctions.sellinformation = {GetItemSellInformation,					1, 'return', 	2} -- NOT interleave save
itemFunctions.gearCraftingType   = {GetItemLinkCraftingSkillType,		   	1, 'table', 	1}
itemFunctions.recipeCraftingType = {GetItemLinkRecipeCraftingSkillType,   	1, 'table', 	1}
itemFunctions.filterType    = {GetItemLinkFilterTypeInfo,   				1, 'matrix', 	1}
itemFunctions.inArmory    	= {IsItemInArmory,   							1, 'return', 	2, ruleEnv.GET_BOOL }
itemFunctions.tradeableTemporarily	= {IsItemBoPAndTradeable,   			1, 'return', 	2, ruleEnv.GET_BOOL }

for name, itemFunctionDef in pairs(itemFunctions) do

	local ItemDataFunction, itemDataIndex, dataRetrievalType, inputType, returnType  = unpack(itemFunctionDef)

	local tag
	if(inputType == 2) then
		tag = ruleEnv.NEED_BAGSLOT
	else
		tag = ruleEnv.NEED_LINKONLY
	end

	if(dataRetrievalType == 'table') then
		ruleEnv.Register(name, function(...) return CheckItemDataByTable(ItemDataFunction, itemDataIndex, name, inputType, ...) end, ruleEnv.MATCH_FILTER, tag)
		ruleEnv.Register(name..'GetValue', function() return ReturnItemDataValue(ItemDataFunction, itemDataIndex, inputType) end, tag, returnType)
	elseif(dataRetrievalType == 'value') then
		ruleEnv.Register(name, function(...) return CheckItemDataByValue(returnType, ItemDataFunction, itemDataIndex, inputType, ...) end, ruleEnv.MATCH_FILTER, tag)
	elseif(dataRetrievalType == 'matrix') then
		ruleEnv.Register(name, function(...) return CheckItemDataByMatrix(ItemDataFunction, name, inputType, ...) end, ruleEnv.MATCH_MATRIX, tag)
		ruleEnv.Register(name..'GetValue', function() return ReturnItemDataValueAll(ItemDataFunction, inputType) end, tag)
	else
		ruleEnv.Register(name, function() return ReturnItemDataValue(ItemDataFunction, itemDataIndex, inputType) end, tag, returnType)
	end
end

ruleEnv.Register("getRefined", function()
	local result = GetItemLinkRefinedMaterialItemLink(ctx.itemLink)
	if(result == "") then return ruleEnv.INVALID_ITEMLINK_RETURN_VALUE end
	return result
end, ruleEnv.GET_LINK, ruleEnv.NEED_LINKONLY)

-- proposed by user Random
ruleEnv.Register("quickslotted", function()
	local bag = ctx.bag
	local slot = ctx.slot
	local itemLink = ctx.itemLink

	if(itemLink ~= nil) then
		local lookup = RbI.GetLookup(bag)
		if(lookup ~= nil) then
			-- GetSlotDatas' returned table must not be written to!
			-- clear! from linked table an value is returned and saved, no link remains
			local itemData = {next(lookup.GetSlotDatas(itemLink))}
			itemData = itemData[2] or {} -- get table of items in bag fitting the itemLink
			itemData = itemData[1] or {} -- get the first item in table
			return itemData.quickslotted
		end
	else
		d("lookup2")
		d(tostring(FindActionSlotMatchingItem(bag, slot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL) ~= nil))
	end
	return FindActionSlotMatchingItem(bag, slot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL) ~= nil
end, ruleEnv.GET_BOOL, ruleEnv.NEED_BAGSLOT)

ruleEnv.Register("price", function(default, withValueFallback)
	local libPrice = LibPrice
	if(libPrice == nil) then
		if(withValueFallback == true) then
			return GetItemLinkValue(ctx.itemLink)
		else
			ruleEnv.errorAddonRequired('LibPrice')
		end
	end
	local goldPrice
	if (libPrice.ItemLinkToCrossSourcePrices ~= nil) then
		-- LibPrice 7.48+
		local goldData = libPrice.ItemLinkToCrossSourcePrices(ctx.itemLink)['gold']
		goldPrice = goldData and ((goldData.sold and goldData.sold.value) or (goldData.list and goldData.list.value))
	elseif (libPrice.ItemLinkToBidAskSpread ~= nil) then
		-- LibPrice 7.47 and earlier
		local goldData = libPrice.ItemLinkToBidAskSpread(ctx.itemLink)['gold']
		goldPrice = goldData and ((goldData.sale and goldData.sale.value) or (goldData.ask and goldData.ask.value))
	end
	return goldPrice or default or RbI.NaN
end, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("countStack", function()
	local buyInfo = ctx.buyInfo
	if buyInfo then
		return buyInfo.stackCount
	end
	local stack, stackMax = GetSlotStackSize(ctx.bag, ctx.slot)
	return stack
end, ruleEnv.NEED_BAGSLOT)

ruleEnv.Register("countStackMax", function()
	local buyInfo = ctx.buyInfo
	if buyInfo then
		return buyInfo.stackCountMax
	end
	local buyInfo = ctx.buyInfo
	local stack, stackMax = GetSlotStackSize(ctx.bag, ctx.slot)
	return stackMax
end, ruleEnv.NEED_BAGSLOT)

local function CallWithValidCurrency(typeName, ItemDataFunction, ...)
	local buyInfo = ctx.buyInfo
	if(buyInfo and ruleEnv.Validate(typeName, true, "currencyTypes", buyInfo.currency, ...)) then
		return ItemDataFunction()
	end
	return RbI.NaN
end

ruleEnv.Register("buyStackPrice", function(...)
	return CallWithValidCurrency("buyStackPrice", function()
		return ctx.buyInfo.stackPrice
	end, ...)
end, ruleEnv.MATCH_FILTER, ruleEnv.NEED_BAGSLOT)

ruleEnv.Register("buyItemPrice", function(...)
	return CallWithValidCurrency("buyItemPrice", function()
		return ctx.buyInfo.stackPrice / ctx.buyInfo.stackCount
	end, ...)
end, ruleEnv.MATCH_FILTER, ruleEnv.NEED_BAGSLOT)

-- Returns:
-- 0: Not a collectible
-- 1: Collectible and not collected
-- 2: Collectible and collected
-- thx@LootLog
local function GetItemLinkCollectionStatus(itemLink)
	if (IsItemLinkSetCollectionPiece(itemLink)) then
		if (IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink))) then
			return 2
		else
			return 1
		end
	else
		local id = GetItemLinkContainerCollectibleId(itemLink)
		if (id > 0) then
			if (IsCollectibleOwnedByDefId(id)) then
				return 2
			elseif (GetCollectibleCategoryType(id) == COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT and not CanCombinationFragmentBeUnlocked(id)) then
				return 2
			else
				return 1
			end
		end
		return 0
	end
end
ruleEnv.Register("collectible", function()
	local itemLink = ctx.itemLink
	return GetItemLinkCollectionStatus(itemLink) > 0
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)
ruleEnv.Register("collected", function()
	local itemLink = ctx.itemLink
	return GetItemLinkCollectionStatus(itemLink) == 2
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

-- thx@LootLog
ruleEnv.Register("tradeable", function()
	local itemLink = ctx.itemLink
	if (IsItemLinkBound(itemLink) or IsItemLinkReconstructed(itemLink)) then
		return false
	else
		local bindType = GetItemLinkBindType(itemLink)
		if (bindType == BIND_TYPE_ON_PICKUP_BACKPACK) then
			return false
		elseif (bindType == BIND_TYPE_ON_PICKUP) then
			local itemType = GetItemLinkItemType(itemLink)
			return itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR
		else
			return true
		end
	end
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

local tradeableGroup = ruleEnv.Register("tradeableTemporarilyWithGroupMember", function(bag, slot)
	local bag = ctx.bag or bag
	local slot = ctx.slot or slot
	if(IsItemBoPAndTradeable(bag, slot)) then
		for i = 1, GetGroupSize() do
			if(IsDisplayNameInItemBoPAccountTable(bag, slot, UndecorateDisplayName(GetUnitDisplayName(GetGroupUnitTagByIndex(i))))) then 
				return true 
			end
		end
	end
	return false
end, ruleEnv.GET_BOOL, ruleEnv.NEED_BAGSLOT)
ruleEnv.Register("tradeableGroup", tradeableGroup, ruleEnv.GET_BOOL, ruleEnv.NEED_BAGSLOT)
ruleEnv.Register("tradeableTemp", function() return self.tradeableTemporarily() end, ruleEnv.GET_BOOL, ruleEnv.NEED_BAGSLOT)

local function checkFCOIS()
	local fcois = FCOIS
	if(fcois == nil) then
		if(RbI.account.settings.fcois) then -- no fcois, but we need it
			ruleEnv.errorAddonRequired('FCOIS')
		end
	else
		if(RbI.FcoisControllerUICheck() == false) then -- fcois, but controller is bad
			ruleEnv.error('FCOIS does not work properly with ControllerUI, as found')
		end
	end
	return fcois
end

-- possibly interesting for lookup
ruleEnv.Register("locked", function(bag, slot)
	local bag = ctx.bag or bag
	local slot = ctx.slot or slot
	local result = IsItemPlayerLocked(bag, slot)
	local fcois = checkFCOIS()
	if(fcois ~= nil and result == false) then
		local FCOISettings = fcois.BuildAndGetSettingsFromExternal()
		if (FCOISettings ~= nil) then
			result = fcois.IsMarked(bag, slot, FCOIS_CON_ICON_LOCK)
		end
	end
	return result
end, ruleEnv.GET_BOOL, ruleEnv.NEED_BAGSLOT)

ruleEnv.Register("usable", function()
	local usable, onlyFromActionSlot = IsItemUsable(ctx.bag, ctx.slot)
	return usable and not onlyFromActionSlot or self.filterType("consumable")
end, ruleEnv.GET_BOOL, ruleEnv.NEED_BAGSLOT)

ruleEnv.Register("canRefine", function()
	local bag = ctx.bag
	local slot = ctx.slot
	local station = ctx.station
	local result = false
	if(station == -1) then -- deconstruction assistant
		return false
	elseif(station == nil) then -- test-button
		result = CanItemBeRefined(bag, slot, CRAFTING_TYPE_BLACKSMITHING)
				or CanItemBeRefined(bag, slot, CRAFTING_TYPE_CLOTHIER)
				or CanItemBeRefined(bag, slot, CRAFTING_TYPE_JEWELRYCRAFTING)
				or CanItemBeRefined(bag, slot, CRAFTING_TYPE_WOODWORKING)
	else
		result = CanItemBeRefined(bag, slot, station)
	end
	return result
end, ruleEnv.GET_BOOL, ruleEnv.NEED_BAGSLOT)

ruleEnv.Register("canDeconstruct", function()
	local bag = ctx.bag
	local slot = ctx.slot
	local station = ctx.station
	local result = false
	if(station == nil or station == -1) then -- nil for test-button, -1 for deconstruction assistant
		result = CanItemBeDeconstructed(bag, slot, CRAFTING_TYPE_BLACKSMITHING)
				or CanItemBeDeconstructed(bag, slot, CRAFTING_TYPE_CLOTHIER)
				or CanItemBeDeconstructed(bag, slot, CRAFTING_TYPE_JEWELRYCRAFTING)
				or CanItemBeDeconstructed(bag, slot, CRAFTING_TYPE_WOODWORKING)
	else
		result = CanItemBeDeconstructed(bag, slot, station)
	end
	return result
end, ruleEnv.GET_BOOL, ruleEnv.NEED_BAGSLOT)

ruleEnv.Register("canExtract", function()
	local bag = ctx.bag
	local slot = ctx.slot
	return CanItemBeDeconstructed(bag, slot, CRAFTING_TYPE_ENCHANTING)
end, ruleEnv.GET_BOOL, ruleEnv.NEED_BAGSLOT)

local function isItemLink(itemLink)
	return itemLink ~= nil and itemLink ~= ""
end

local validComparators = {['>']=true, ['>=']=true, ['==']=true, ['<=']=true, ['<']=true, ['~=']=true}
local function CountBag(bag, comparator, value)
	local itemLink = ctx.itemLink
	if(not isItemLink(itemLink)) then return false end

	-- if comparator is left blank the mere count of items is returned instead of an evaluation being done
	if(comparator == '' or comparator == nil) then
		if(bag == BAG_VIRTUAL) then
			bag = 3
		end
		return ({GetItemLinkStacks(itemLink)})[bag] or 0
	end

	if(not validComparators[tostring(comparator)]) then
		ruleEnv.errorInvalidArgument(1, comparator, validComparators, "Comparator")
	end

	-- comparator was recognized, begin evaluation
	local itemData = ctx.amountHelper.count[bag]

	ctx.amountHelper[bag] = ctx.amountHelper[bag] or {}
	ctx.amountHelper[bag][value-1] = true
	ctx.amountHelper[bag][value]   = true
	ctx.amountHelper[bag][value+1] = true

	-- enter value for calculation of amount only if we are not in calculations already
	if(itemData == nil) then
		local lookup = RbI.GetLookup(bag)
		if(lookup ~= nil) then
			-- GetSlotDatas' returned table must not be written to!
			-- clear! from linked table an value is returned and saved, no link remains
			itemData = {next(lookup.GetSlotDatas(itemLink))}
			itemData = itemData[2] or {}
			itemData = itemData.count or {}
			itemData = itemData[bag]
			--RbI.ClearLookup(bag) -- not needed because lookup is not "create = true"
		end
	end

	if(bag == BAG_VIRTUAL) then
		bag = 3
	end

	-- fallback to zos function if no other data was found (function returns nil for items not in the bag)
	itemData = itemData or ({GetItemLinkStacks(itemLink)})[bag] or 0
	return (comparator == '>'  and itemData >  value)
		or (comparator == '>=' and itemData >= value)
		or (comparator == '==' and itemData == value)
		or (comparator == '<=' and itemData <= value)
		or (comparator == '<'  and itemData <  value)
		or (comparator == '~=' and itemData ~= value)
end

ruleEnv.Register("countBackpack", function(comparator, value)
	return CountBag(BAG_BACKPACK, comparator, value)
end, ruleEnv.NEED_NOITEM)
ruleEnv.Register("countBank", function(comparator, value)
	return CountBag(ctx.station or BAG_BANK, comparator, value)
end, ruleEnv.NEED_NOITEM)
ruleEnv.Register("countCraftbag", function(comparator, value)
	return CountBag(BAG_VIRTUAL, comparator, value)
end, ruleEnv.NEED_NOITEM)

ruleEnv.Register("setItemCollected", function()
	local itemLink = ctx.itemLink
    if (not IsItemLinkSetCollectionPiece(itemLink)) then
		return false
	end
    local setId = select(6, GetItemLinkSetInfo(itemLink, false))
    local collectionSlot = GetItemLinkItemSetCollectionSlot(itemLink)
    return IsItemSetCollectionSlotUnlocked(setId, collectionSlot)
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

local setTypes = {}
ruleEnv.Register("setType", function(...)
	local input = ruleEnv.GetArguments('setType', true, nil, ...)
	if(LibSets == nil) then ruleEnv.errorAddonRequired('LibSets') end
	if(LibSets.checkIfSetsAreLoadedProperly() == false) then
		--LibSets is currentls scanning and/or not ready!
		ruleEnv.error('Required Library LibSets was not found ready')
	end

	if(not setTypes.rbiInitialized) then
		for setType in pairs(LibSets.GetAllSetTypes()) do
			setTypes[string.lower(LibSets.GetSetTypeName(setType))] = setType
		end
		setTypes['none'] = 0
		setTypes.rbiInitialized = true
	end

	local itemLink = ctx.itemLink
	local isSet, _, setId = LibSets.IsSetByItemLink(itemLink)
	if(isSet) then
		for i = 1, #input do
			local inputI = string.lower(input[i])
			if (setTypes[inputI] == nil) then
				ruleEnv.errorInvalidArgument(i, inputI, setTypes)
			elseif(setTypes[inputI] == LibSets.GetSetType(setId)) then
				return true
			end
		end
	end
	return false
end, ruleEnv.MATCH_FILTER, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("vouchers", function()
	local itemLink = ctx.itemLink
	local itemType, itemSubType = GetItemLinkItemType(itemLink)
	local vouchers = 0
	if(itemType == ITEMTYPE_MASTER_WRIT or itemSubType == SPECIALIZED_ITEMTYPE_MASTER_WRIT) then
		vouchers = tonumber(string.match(GenerateMasterWritRewardText(itemLink), "[%d]+"))
	end
	return vouchers
end, ruleEnv.NEED_LINKONLY)

local needForDailyWritCount = ruleEnv.Register("needForDailyWritCount", function()
	for questIdx=1, MAX_JOURNAL_QUESTS do -- not GetNumJournalQuests()!!! the quests aren't saved sequentially
		if (GetJournalQuestType(questIdx) == QUEST_TYPE_CRAFTING and GetJournalQuestRepeatType(questIdx)==QUEST_REPEAT_DAILY) then
			for stepIdx=1, GetJournalQuestNumSteps(questIdx) do
				for condIdx=1, GetJournalQuestNumConditions(questIdx, stepIdx) do
					local _, current, max, _, _, _, _, conditionType = GetJournalQuestConditionInfo(questIdx, stepIdx, condIdx)
					if(conditionType == 44) then -- dailywrit
						if(DoesItemLinkFulfillJournalQuestCondition(ctx.itemLink, questIdx, stepIdx, condIdx)) then
							local cur, max = GetJournalQuestConditionValues(questIdx, stepIdx, condIdx)
							return max
						end
					end
				end
			end
		end
	end
	return 0
end, ruleEnv.GET_INT, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("needForDailyWrit", function()
	return needForDailyWritCount() > 0
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

local needForWritCount = ruleEnv.Register("needForWritCount", function()
	if(LibCraftText == nil) then ruleEnv.errorAddonRequired('LibCraftText') end
	for questIdx=1, MAX_JOURNAL_QUESTS do -- not GetNumJournalQuests()!!! the quests aren't saved sequentially
		if (GetJournalQuestType(questIdx) == QUEST_TYPE_CRAFTING) then -- and GetJournalQuestRepeatType(questIdx)==QUEST_REPEAT_DAILY
			for stepIdx=1, GetJournalQuestNumSteps(questIdx) do
				for condIdx=1, GetJournalQuestNumConditions(questIdx, stepIdx) do
					local conditionText, current, max, isFailCondition, isComplete, isCreditShared, isVisible, conditionType = GetJournalQuestConditionInfo(questIdx, stepIdx, condIdx)
					if(conditionType == 44) then -- dailywrit
						if(DoesItemLinkFulfillJournalQuestCondition(ctx.itemLink, questIdx, stepIdx, condIdx)) then
							local cur, max = GetJournalQuestConditionValues(questIdx, stepIdx, condIdx)
							return max
						end
					elseif(conditionType == 48) then -- masterwrit
						if(ext.DoesItemLinkFulfillJournalQuestConditionMasterWrit(ctx.itemLink, questIdx, stepIdx, condIdx)) then
							local cur, max = GetJournalQuestConditionValues(questIdx, stepIdx, condIdx)
							return max
						end
					end
				end
			end
		end
	end
	return 0
end, ruleEnv.GET_INT, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("needForWrit", function()
	return needForWritCount() > 0
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

local soulGemTypeGet = ruleEnv.Register("soulGemTypeGetValue", function()
	local bag = ctx.bag
	local slot = ctx.slot
	local itemLink = ctx.itemLink
	local itemType, itemSubType = GetItemLinkItemType(itemLink)
	if(itemType == ITEMTYPE_SOUL_GEM or itemSubType == SPECIALIZED_ITEMTYPE_SOUL_GEM) then
		local soulGemType
		if(GetItemLinkQuality(itemLink) == ITEM_QUALITY_ARCANE) then
			soulGemType = SOUL_GEM_TYPE_FILLED -- crown soulgems are always full but SoulGemType is "empty"
		else
			soulGemType = select(2, GetSoulGemItemInfo(bag, slot))
		end
		return soulGemType
	end
end, ruleEnv.NEED_BAGSLOT)

ruleEnv.Register("soulGemType", function(...)
	local soulGemType = soulGemTypeGet()
	if(soulGemType == nil) then return false end
	local args = ruleEnv.GetArguments('soulGemType', true, 'soulGemType', ...)
	return utils.TableContainsValue(args, soulGemType)
end, ruleEnv.MATCH_FILTER, ruleEnv.NEED_BAGSLOT)

ruleEnv.Register("autoCategory", function(...)
	if(AutoCategory == nil) then ruleEnv.errorAddonRequired('AutoCategory') end
	local _, category = AutoCategory:MatchCategoryRules(ctx.bag, ctx.slot)
	category = string.lower(category)
	return ruleEnv.Validate('autoCategory', true, nil, category, ...)
end, ruleEnv.MATCH_FILTER, ruleEnv.NEED_BAGSLOT)

ruleEnv.Register("tag", function(...)
	local input = ruleEnv.GetArguments('tag', true, nil, ...)
	local itemLink = ctx.itemLink
	local tags = {}
	for i = 0, GetItemLinkNumItemTags(itemLink) do
		local tag = GetItemLinkItemTagInfo(itemLink, i)
		if(tag ~= nil and tag ~= '') then
			table.insert(tags, zo_strformat("<<1>>", string.lower(tag)))
		end
	end
	local match, message = utils.textCheckMany(input, tags, false)
	if match == nil then
		ruleEnv.error(message)
		return false
	end
	return match
end, ruleEnv.MATCH_FILTER, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("fcoisPermission", function(taskName)
	local fcois = checkFCOIS()
	if(fcois == nil) then return true end

	local result = true
	local bag = ctx.bag
	local slot = ctx.slot
	local taskName = taskName or ctx.taskName
	if(taskName == 'Junk') then
		result = not fcois.IsJunkLocked(bag, slot)
	elseif(taskName == 'Launder') then
		result = not fcois.IsLaunderLocked(bag, slot)
	elseif(taskName == 'Fence') then
		result = not fcois.IsFenceSellLocked(bag, slot)
	elseif(taskName == 'Sell') then
		result = not fcois.IsVendorSellLocked(bag, slot)
	elseif(taskName == 'Destroy') then
		result = not fcois.IsDestroyLocked(bag, slot)
	elseif(taskName == 'Deconstruct') then
		result = not fcois.IsDeconstructionLocked(bag, slot)
	elseif(taskName == 'Extract') then
		result = not fcois.IsEnchantingExtractionLocked(bag, slot)
	elseif(taskName == 'Refine') then
		result = not fcois.IsRefinementLocked(bag, slot)
	end
	return result
end, ruleEnv.NEED_BAGSLOT)

ruleEnv.Register("fcoisMarker", function(...)
	local fcois = checkFCOIS()
	if(fcois == nil) then return false end

	local noInput = select('#', ...) == 0
	local input = ruleEnv.GetArgumentsMap("FcoisMarker", false, "fcoisMark", ...)
	local bag = ctx.bag
	local slot = ctx.slot
	local isMarked, marker = fcois.IsMarked(bag, slot, -1)
	if(isMarked and marker ~= nil) then
		for i, mark in ipairs(marker) do
			if(mark == true) then
				if(noInput) then return true end
				if(input[i]) then
					return true
				end
			end
		end
	end
	return false
end, ruleEnv.NEED_BAGSLOT)

-- @require RequireMultiCharactersApi
ruleEnv.Register("needTraitInOrder", function(...)
	local charNames = ruleEnv.GetCharactersNames(true, ...)
	return ext.RequireMultiCharactersApi().InOrderResearch(true, charNames)
end, ruleEnv.MATCH_FILTER, ruleEnv.NEED_LINKONLY)
-- @require RequireMultiCharactersApi
ruleEnv.Register("needTrait", function(...)
	local charNames = ruleEnv.GetCharactersNames(false, ...)
	return ext.RequireMultiCharactersApi().InOrderResearch(false, charNames)
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

-- @require RequireMultiCharactersApi
ruleEnv.Register("needLearnInOrder", function(...)
	local charNames = ruleEnv.GetCharactersNames(true, ...)
	-- if(self.isCollectible()) then return not self.isCollected() end
	return ext.RequireMultiCharactersApi().InOrderLearn(true, charNames)
end, ruleEnv.MATCH_FILTER, ruleEnv.NEED_LINKONLY)
-- @require RequireMultiCharactersApi
ruleEnv.Register("needLearn", function(...)
	local charNames = ruleEnv.GetCharactersNames(false, ...)
	-- if(self.isCollectible()) then return not self.isCollected() end
	return ext.RequireMultiCharactersApi().InOrderLearn(false, charNames)
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("costPerVoucher", function()
	if(WritWorthy == nil) then ruleEnv.errorAddonRequired('WritWorthy') end
	local itemLink = ctx.itemLink
	local vouchers = self.vouchers(itemLink)
	local cost
	if(vouchers > 0) then
		local matCost = WritWorthy.ToMatCost(itemLink)
		if(matCost ~= nil) then
			local buyCost = 0
			if(ctx.buyInfo and ctx.buyInfo.currency == CURT_MONEY) then
				buyCost = ctx.buyInfo.stackPrice
			end
			cost = (matCost + buyCost) / vouchers
		end
	end
	return cost or RbI.NaN
end, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("canCraftMasterwrit", function()
	if(WritWorthy == nil) then ruleEnv.errorAddonRequired('WritWorthy') end
	if(not self.type('masterwrit')) then return false end
	local mat_list, know_list, parser = WritWorthy.ToMatKnowList(ctx.itemLink)
	if(know_list) then
		for _, know in ipairs(know_list) do
			if(not know.is_known) then return false end
		end
	end
	if(mat_list) then
		for i, mat_row in ipairs(mat_list) do
			local need_ct = mat_row.ct or 1
			local have_ct = mat_row:HaveCt() or 0
			if have_ct < need_ct then
				return false
			end
		end
	else
		return false
	end
	return true
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("level", function()
	local itemLink = ctx.itemLink
	-- for material take max gear cp/lvl which can be crafted
	local level = RbI.itemCatalog.MaterialRequirementLevel[GetItemLinkItemId(itemLink)]
	if(level ~= nil) then
		level = level[2]
		if(level > GetMaxLevel()) then
			level = GetMaxLevel()
		end
	else
		-- if level returned is nil (itemLink was no material)
		level = GetItemLinkRequiredLevel(itemLink)
	end
	return level
end, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("cp", function()
	local itemLink = ctx.itemLink
	-- for material take max gear cp/lvl which can be crafted
	local cp = RbI.itemCatalog.MaterialRequirementLevel[GetItemLinkItemId(itemLink)]
	if(cp ~= nil) then
		cp = cp[2]
		if(cp > GetMaxLevel()) then
			-- recalculate returned cp from scaled version
			cp = cp - GetMaxLevel()
		else
			cp = 0
		end
	else
		-- if cp returned is nil (itemLink was no material)
		cp = GetItemLinkRequiredChampionPoints(itemLink)
	end
	return cp
end, ruleEnv.NEED_LINKONLY)

local function GetAllArmoryBuildNames()
	local result = {}
	for i = 1, GetNumUnlockedArmoryBuilds() do
		result[#result+1] = GetArmoryBuildName(i)
	end
	return result
end
ruleEnv.Register("armoryBuild", function(...)
	local BuildList = {GetItemArmoryBuildList(ctx.bag, ctx.slot)}
	return ruleEnv.Validate('ArmoryBuildName', true, GetAllArmoryBuildNames(), BuildList, ...)
end, ruleEnv.MATCH_MATRIX, ruleEnv.NEED_BAGSLOT)

ruleEnv.Register("reconstructionCost", function()
	return tonumber(GetItemReconstructionCurrencyOptionCost(self.setId(), CURT_CHAOTIC_CREATIA)) or RbI.NaN
end, ruleEnv.GET_INT, ruleEnv.NEED_LINKONLY)

-- get list of all alphagear build names
local function GetAllAlphaGearBuildNames()
	local result = {}
	for i = 1, 16 do
		if(AG.setdata[i] and AG.setdata[i].Set and AG.setdata[i].Set.text and AG.setdata[i].Set.text[1] ~= 0) then
			result[#result+1] = AG.setdata[i].Set.text[1]
		end
	end
	return result
end

-- get list of alphagear build names or numbers item
-- @returnNumber: set true if number is to be returned instead of name
local function GetAlphaGearBuildList(bag, slot, returnNumbers)
	local result = {}
	local id = AG.GetIdTypeAndLink(bag, slot)
	if id then
		for build = 1, 16 do
			if (AG.setdata[build] and AG.setdata[build].Set and AG.setdata[build].Set.gear > 0) then
				local set = AG.setdata[build].Set.gear
				for slot = 1, 14 do
					if (AG.setdata[set].Gear[slot].id == id) then
						if(returnNumbers) then
							result[#result+1] = build
						else
							result[#result+1] = AG.setdata[build].Set.text[1]
						end
						break -- item was found in this build, skip to next build
					end
				end
			end
		end
	end
	return result
end

ruleEnv.Register("alphaGearBuild", function(...)
	if(AG == nil) then ruleEnv.errorAddonRequired('AlphaGear') end
	local BuildList = GetAlphaGearBuildList(ctx.bag, ctx.slot)
	return ruleEnv.Validate('AlphaGearBuildName', true, GetAllAlphaGearBuildNames(), BuildList, ...)
end, ruleEnv.MATCH_MATRIX, ruleEnv.NEED_BAGSLOT)

ruleEnv.Register("alphaGearBuildNumber", function(...)
	if(AG == nil) then ruleEnv.errorAddonRequired('AlphaGear') end
	local BuildList = GetAlphaGearBuildList(ctx.bag, ctx.slot, true)
	return ruleEnv.ValidateNumbers('AlphaGearBuildNumber', true, BuildList, ...) -- validInputs {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
end, ruleEnv.MATCH_MATRIX, ruleEnv.NEED_BAGSLOT)

----------------------------------------
-- simplification functions ------------
----------------------------------------

ruleEnv.Register("material_alchemy", function()
	return self.type('reagent'
							 ,'potion_base'
							 ,'poison_base')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("item_enchanting", function()
	return self.type('glyph_armor'
							 ,'glyph_weapon'
							 ,'glyph_jewelry')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("glyph", function(...)
	return self.type('glyph_armor'
							,'glyph_weapon'
							,'glyph_jewelry')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("item_jewelry", function()
	return self.equiptype('ring'
								   ,'neck')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("armor_clothier", function()
	return self.armortype('light'
								  ,'medium')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("item_clothier", function()
	return self.armor_clothier()
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("weapon_woodworking", function()
	return self.weapontype('bow'
								   ,'firestaff'
								   ,'froststaff'
								   ,'healingstaff'
								   ,'lightningstaff'
								   ,'shield')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("item_woodworking", function()
	return self.weapon_woodworking()
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("armor_blacksmithing", function()
	return self.armortype('heavy')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("weapon_blacksmithing", function()
	return self.weapontype('axe'
								   ,'dagger'
								   ,'mace'
								   ,'sword'
								   ,'battleaxe'
								   ,'maul'
								   ,'greatsword')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("item_blacksmithing", function()
	return self.weapon_blacksmithing()
		or self.armor_blacksmithing()
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("material_jewelrytrait", function()
	return self.type('material_raw_jewelrytrait'
							 ,'material_refined_jewelrytrait')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("material_jewelry", function()
	return self.type('material_raw_jewelry'
							 ,'material_refined_jewelry'
							 ,'booster_refined_jewelry')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("material_woodworking", function()
	return self.type('material_raw_woodworking'
							 ,'material_refined_woodworking'
							 ,'booster_woodworking')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("material_clothier", function()
	return self.type('material_raw_clothier'
							 ,'material_refined_clothier'
							 ,'booster_clothier')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("material_blacksmithing", function()
	return self.type('material_raw_blacksmithing'
							 ,'material_refined_blacksmithing'
							 ,'booster_blacksmithing')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("material_style", function()
	return self.type('material_refined_style'
							 ,'material_raw_style')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("material_enchantment", function()
	return self.type('aspect'
							 ,'essence'
							 ,'potency')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("material_refined_trait", function()
	return self.type('material_armortrait'
							 ,'material_weapontrait'
							 ,'material_refined_jewelrytrait')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("material_raw_trait", function()
	return self.type('material_raw_jewelrytrait')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("material_trait", function()
	return self.material_refined_trait()
		or self.material_raw_trait()
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("material_refined_booster", function()
	return self.type('booster_blacksmithing'
							 ,'booster_clothier'
							 ,'booster_woodworking'
							 ,'booster_refined_jewelry')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("material_raw_booster", function()
	return self.type('booster_raw_jewelry')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("material_booster", function()
	return self.material_refined_booster()
		or self.material_raw_booster()
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("material_refined", function()
	return self.type('material_refined_blacksmithing'
							 ,'material_refined_clothier'
							 ,'material_refined_woodworking'
							 ,'material_refined_jewelry'
							 ,'material_refined_style'
							 ,'material_furnishing'
							 ,'ingredient')
		or self.material_refined_trait()
		or self.material_refined_booster()
		or self.material_alchemy()
		or self.material_enchantment()
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("material_raw", function()
	return self.type('material_raw_blacksmithing'
							 ,'material_raw_clothier'
							 ,'material_raw_woodworking'
							 ,'material_raw_jewelry'
							 ,'material_raw_jewelrytrait'
							 ,'material_raw_style'
							 ,'booster_raw_jewelry')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("material", function()
	return self.material_raw()
		or self.material_refined()
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("traited", function()
	return not self.trait('none')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("gear", function()
	return not self.equiptype('none', 'poison', 'costume')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("companion", function()
	return self.filtertype('companion')
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("fragment", function()
	return self.stype("key_fragment", "recipe_fragment", "runebox_fragment", "collectible_fragment", "upgrade_fragment")
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)