local GS = GetString
local allMyChars = CarosPreCrafter.allMyChars
local thisCharId = CarosPreCrafter.thisCharId

local CS = CraftStoreFixedAndImprovedLongClassName
local LLC = false
local woodworkingRemap = {1,3,4,5,6,2}
local internalLLCQueue = {[CRAFTING_TYPE_BLACKSMITHING] = {}, [CRAFTING_TYPE_CLOTHIER] = {}, [CRAFTING_TYPE_WOODWORKING] = {}, [CRAFTING_TYPE_JEWELRYCRAFTING] = {}, }
local itemsInLLCQueueByReference = {}
local strIL = "|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"

local wm = WINDOW_MANAGER
local cpcD = CarosPreCrafter.cpcD

local nirnTraits = { [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = true, [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = true}

-- the following numbers are the internal traitindices used by functions like GetSmithingResearchLineTraitInfo
-- inside the crafting window jewelry traits are ordered by traitids
-- later if a traitId is used in crafting we add 1 because that's how it's handled inside the game (global vars begin at 0, crafting at 1 ==> everything moves up)

local jewelryTraitIds = { -- and once again one has to wonder: why...
	[1] = 22,
	[2] = 21,
	[3] = 23,
	[4] = 30,
	[5] = 33,
	[6] = 32,
	[7] = 28,
	[8] = 29,
	[9] = 31,
}

local jewelryTraitIndices = {
	[22] = 1,
	[21] = 2,
	[23] = 3,
	[30] = 4,
	[33] = 5,
	[32] = 6,
	[28] = 7,
	[29] = 8,
	[31] = 9,
}
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
	[ARMORTYPE_NONE] = {
		[EQUIP_TYPE_NECK] = {CRAFTING_TYPE_JEWELRYCRAFTING, 1},
		[EQUIP_TYPE_RING] = {CRAFTING_TYPE_JEWELRYCRAFTING, 2},
	},
	[ARMORTYPE_LIGHT] = {
		[EQUIP_TYPE_CHEST] = {CRAFTING_TYPE_CLOTHIER, 1},
		[EQUIP_TYPE_FEET] = {CRAFTING_TYPE_CLOTHIER, 2},
		[EQUIP_TYPE_HAND] = {CRAFTING_TYPE_CLOTHIER, 3},
		[EQUIP_TYPE_HEAD] = {CRAFTING_TYPE_CLOTHIER, 4},
		[EQUIP_TYPE_LEGS] = {CRAFTING_TYPE_CLOTHIER, 5},
		[EQUIP_TYPE_SHOULDERS] = {CRAFTING_TYPE_CLOTHIER, 6},
		[EQUIP_TYPE_WAIST] = {CRAFTING_TYPE_CLOTHIER, 7},
	},
	[ARMORTYPE_MEDIUM] = {
		[EQUIP_TYPE_CHEST] = {CRAFTING_TYPE_CLOTHIER, 8},
		[EQUIP_TYPE_FEET] = {CRAFTING_TYPE_CLOTHIER, 9},
		[EQUIP_TYPE_HAND] = {CRAFTING_TYPE_CLOTHIER, 10},
		[EQUIP_TYPE_HEAD] = {CRAFTING_TYPE_CLOTHIER, 11},
		[EQUIP_TYPE_LEGS] = {CRAFTING_TYPE_CLOTHIER, 12},
		[EQUIP_TYPE_SHOULDERS] = {CRAFTING_TYPE_CLOTHIER, 13},
		[EQUIP_TYPE_WAIST] = {CRAFTING_TYPE_CLOTHIER, 14},
	},
	[ARMORTYPE_HEAVY] = {
		[EQUIP_TYPE_CHEST] = {CRAFTING_TYPE_BLACKSMITHING, 8},
		[EQUIP_TYPE_FEET] = {CRAFTING_TYPE_BLACKSMITHING, 9},
		[EQUIP_TYPE_HAND] = {CRAFTING_TYPE_BLACKSMITHING, 10},
		[EQUIP_TYPE_HEAD] = {CRAFTING_TYPE_BLACKSMITHING, 11},
		[EQUIP_TYPE_LEGS] = {CRAFTING_TYPE_BLACKSMITHING, 12},
		[EQUIP_TYPE_SHOULDERS] = {CRAFTING_TYPE_BLACKSMITHING, 13},
		[EQUIP_TYPE_WAIST] = {CRAFTING_TYPE_BLACKSMITHING, 14},
	},
}

local function isLineWeapon(craft, lineIndex) 
	if craft == CRAFTING_TYPE_WOODWORKING and lineIndex < 6 then return true end
	if craft == CRAFTING_TYPE_BLACKSMITHING and lineIndex < 8 then return true end
	return false
end

local function getMatNumbers()

	local getTotalCount = CarosPreCrafter.getTotalCount
			
	local nirnArmorLeft = getTotalCount(string.format(strIL, 56862))
	local nirnWeaponLeft = getTotalCount(string.format(strIL, 56863))
	
	local jewelryTraitMatNumbers = {}
	local jewelryTraitMatLinks = {}
	
	for i=1, GetNumSmithingTraitItems() do
		local traitType = GetSmithingTraitItemInfo(i)
		if jewelryTraitIndices[traitType] then
			local matLink = GetSmithingTraitItemLink(i)
			jewelryTraitMatNumbers[traitType] = getTotalCount(matLink)
			jewelryTraitMatLinks[traitType] = matLink
		end
	end
	return nirnArmorLeft, nirnWeaponLeft, jewelryTraitMatNumbers, jewelryTraitMatLinks
	
end

local function getResearchLineFromItemLink(myLink)
	local weaponType = GetItemLinkWeaponType(myLink)
	local armorType = GetItemLinkArmorType(myLink) -- light, medium, heavy (0 = none)
	local equipType = GetItemLinkEquipType(myLink)
	local theTrait = GetItemLinkTraitType(myLink)
	
	local myCraftAndLine, myTraitIndex = false, false
	
	if weaponType > 0 then
		if weaponType ~= WEAPONTYPE_SHIELD then myTraitIndex = theTrait end
		myCraftAndLine = weaponResearchLines[weaponType]
	else
		myCraftAndLine = armorResearchLines[armorType] and  armorResearchLines[armorType][equipType]
	end
	-- subtract different traitindices for armor/jewelry (LLC always adds 1)
	if myCraftAndLine[1] == CRAFTING_TYPE_JEWELRYCRAFTING then
		myTraitIndex = jewelryTraitIndices[theTrait]
	else
		myTraitIndex = myTraitIndex or theTrait - ITEM_TRAIT_TYPE_ARMOR_STURDY + 1 
	end
	if nirnTraits[theTrait] then myTraitIndex = 9 end
	if not myCraftAndLine then return false end
	return myCraftAndLine[1], myCraftAndLine[2], myTraitIndex
end
CarosPreCrafter.getResearchLineFromItemLink = getResearchLineFromItemLink

local function findResearchItemInBag(bagId, craft, lineIndex, traitIndex)
	for slotId=0, GetBagSize(bagId) do
		local myLink = GetItemLink(bagId, slotId, 1)
		if IsItemLinkCrafted(myLink) and GetItemLinkQuality(myLink) == ITEM_QUALITY_NORMAL and GetItemLinkRequiredLevel(myLink) == 1 then
			local itemCraft, itemLineIndex, itemTraitIndex = getResearchLineFromItemLink(myLink)
			if itemCraft == craft and itemLineIndex == lineIndex and itemTraitIndex == traitIndex then
				cpcD("Found in bag "..bagId.." in slot "..slotId..": "..craft..lineIndex..traitIndex)
				return slotId, bagId
			end
		end
	end
	if bagId == BAG_BANK then
		return findResearchItemInBag(BAG_SUBSCRIBER_BANK, craft, lineIndex, traitIndex)
	else
		cpcD("Not found in "..bagId..": "..craft..lineIndex..traitIndex)
		return false
	end
end

local function buildBagItemList(bagId)
	local bagItemList = {}
	for slotId=0, GetBagSize(bagId) do
		local myLink = GetItemLink(bagId, slotId, 1)
		if IsItemLinkCrafted(myLink) and GetItemLinkQuality(myLink) == ITEM_QUALITY_NORMAL and GetItemLinkRequiredLevel(myLink) == 1 and not IsItemPlayerLocked(bagId, slotId) then
			local itemCraft, itemLineIndex, itemTraitIndex = getResearchLineFromItemLink(myLink)
			if itemCraft then table.insert(bagItemList, {slot=slotId, craft=itemCraft, lineIndex = itemLineIndex, traitIndex = itemTraitIndex, link=myLink}) end
		end
	end
	return bagItemList
end

function CarosPreCrafter.rebuildCraftItemList()
	local bagpackList = buildBagItemList(BAG_BACKPACK)
	local bankList = buildBagItemList(BAG_BANK)
	local plusBankList = buildBagItemList(BAG_SUBSCRIBER_BANK)
	local thisCharId = CarosPreCrafter.thisCharId
	
	local charItems = CarosPreCrafter.sV.researchChars[thisCharId]
	local doJewelry = charItems.doJewelry and not charItems.finishedJewelry
		local doNirn = charItems.doNirn and not charItems.finishedNirn
	charItems = charItems and (charItems.active or doJewelry or doNirn) and charItems.items or false
	if not CarosPreCrafter.isOnMainCrafter and not charItems then return end
	local charsToIterate = {}
	for i, v in pairs(CarosPreCrafter.sV.researchChars) do
		if (v.active or v.doJewelry and not v.finishedJewelry or v.doNirn and not v.finishedNirn) and v.items then
			charsToIterate[i] = v.items
		end
	end
	
	local shouldBeInInventory = {}
	local shouldBeInBank = {}
	local shouldNotBeThere = {}
	
	for charId, charItems in pairs(charsToIterate) do 
		for itemKey, itemData in pairs(charItems) do
			local theItem = {itemKey = itemKey, craft=itemData.craft, lineIndex=itemData.lineIndex, traitIndex=itemData.traitIndex, charId = charId}
			if itemData.location == thisCharId then
				table.insert(shouldBeInInventory, theItem)
			elseif itemData.location == 42 then
				table.insert(shouldBeInBank, theItem)
			elseif itemData.location == 0 then
				table.insert(shouldNotBeThere, theItem)
			end
		end	
	end
		
	local function compareTwoItems(item1, item2)
		return item1.craft == item2.craft and item1.lineIndex == item2.lineIndex and item1.traitIndex == item2.traitIndex 
	end
	local function compareTwoList(list1, list2, myFunc)
		local index1=1
		while index1 <= #list1 do 
			local index2 = 1
			local removedEntry = false
			while index2 <= #list2 do
				if compareTwoItems(list1[index1], list2[index2]) then 
					cpcD("Found something...")
					if myFunc then myFunc(list1[index1], list2[index2]) end
					table.remove(list1, index1)
					table.remove(list2, index2)
					removedEntry = true
					break
				else
					index2 = index2 + 1
				end
			end
			if not removedEntry then index1 = index1 + 1 end
		end
	end
	
	cpcD("Checking Bagpack")
	compareTwoList(bagpackList, shouldBeInInventory, function(entry1, entry2) cpcD("Removed "..entry2.itemKey.." from Backpack") end)
	cpcD("Checking Bank")
	compareTwoList(bankList, shouldBeInBank, function(entry1, entry2) cpcD("Removed "..entry2.itemKey.." from Bank") end)
	cpcD("Checking +Bank")
	compareTwoList(plusBankList, shouldBeInBank, function(entry1, entry2) cpcD("Removed "..entry2.itemKey.." from +Bank") end)
	
	cpcD("Cross-checking others...")
	if CarosPreCrafter.isOnMainCrafter then
		compareTwoList(shouldBeInBank, bagpackList, function(entry1,entry2) charsToIterate[entry1.charId][entry1.itemKey].location = thisCharId cpcD("Moved: "..entry1.itemKey.." to "..thisCharId) end)
		compareTwoList(shouldBeInInventory, bankList, function(entry1,entry2) charsToIterate[entry1.charId][entry1.itemKey].location = 42 cpcD("Moved: "..entry1.itemKey.." to bank") end)
		compareTwoList(shouldBeInInventory, plusBankList, function(entry1,entry2) charsToIterate[entry1.charId][entry1.itemKey].location = 42 cpcD("Moved: "..entry1.itemKey.." to bank") end)
		compareTwoList(shouldNotBeThere, bagpackList, function(entry1,entry2) charsToIterate[entry1.charId][entry1.itemKey].location = thisCharId cpcD("Updated entry: "..entry1.itemKey.." for "..entry1.charId) end)
		compareTwoList(shouldNotBeThere, bankList, function(entry1,entry2) charsToIterate[entry1.charId][entry1.itemKey].location = 42 cpcD("Updated entry: "..entry1.itemKey.." for "..entry1.charId) end)
		compareTwoList(shouldNotBeThere, plusBankList, function(entry1,entry2) charsToIterate[entry1.charId][entry1.itemKey].location = 42 cpcD("Updated entry: "..entry1.itemKey.." for "..entry1.charId) end)
	else
		compareTwoList(shouldBeInInventory, bankList, function(entry1,entry2) charsToIterate[entry1.charId][entry1.itemKey].location = 42  cpcD("Moved: "..entry1.itemKey.." to bank") end)
		compareTwoList(shouldBeInInventory, plusBankList, function(entry1,entry2) charsToIterate[entry1.charId][entry1.itemKey].location = 42  cpcD("Moved: "..entry1.itemKey.." to bank") end)
		compareTwoList(shouldBeInBank, bagpackList, function(entry1,entry2) charsToIterate[entry1.charId][entry1.itemKey].location = thisCharId  cpcD("Moved: "..entry1.itemKey.." to "..thisCharId) end)
		compareTwoList(shouldNotBeThere, bagpackList, function(entry1,entry2) charsToIterate[entry1.charId][entry1.itemKey].location = thisCharId cpcD("Updated entry: "..entry1.itemKey.." for "..thisCharId) end)
		compareTwoList(shouldNotBeThere, bankList, function(entry1,entry2) charsToIterate[entry1.charId][entry1.itemKey].location = 42 cpcD("Updated entry: "..entry1.itemKey.." for "..thisCharId) end)
		compareTwoList(shouldNotBeThere, plusBankList, function(entry1,entry2) charsToIterate[entry1.charId][entry1.itemKey].location = 42 cpcD("Updated entry: "..entry1.itemKey.." for "..thisCharId) end)
	end
	cpcD("Should be in inventory:")
	for i, itemData in pairs(shouldBeInInventory) do
		local lineName = GetSmithingResearchLineInfo(itemData.craft, itemData.lineIndex)
		local traitname = GS("SI_ITEMTRAITTYPE", GetSmithingResearchLineTraitInfo(itemData.craft, itemData.lineIndex, itemData.traitIndex))
		if CarosPreCrafter.isOnMainCrafter then 
			cpcD("Setting location to zero: "..lineName.." - "..traitname)
			CarosPreCrafter.sV.researchChars[itemData.charId].items[itemData.itemKey].location = 0
		else
			cpcD("Deleting: "..lineName.." - "..traitname)
			charItems[itemData.itemKey] = nil
		end
	end
	cpcD("Should be in bank:")
	for i, itemData in pairs(shouldBeInBank) do
		local lineName = GetSmithingResearchLineInfo(itemData.craft, itemData.lineIndex)
		local traitname = GS("SI_ITEMTRAITTYPE", GetSmithingResearchLineTraitInfo(itemData.craft, itemData.lineIndex, itemData.traitIndex))
		if CarosPreCrafter.isOnMainCrafter then 
			cpcD("Setting location to zero: "..lineName.." - "..traitname.." - Char: "..itemData.charId)
			CarosPreCrafter.sV.researchChars[itemData.charId].items[itemData.itemKey].location = 0
		else
			cpcD("Deleting: "..lineName.." - "..traitname)
			charItems[itemData.itemKey] = nil
		end
	end
	return {bagpackList = bagpackList, bankList = bankList, plusBankList = plusBankList, shouldBeInInventory = shouldBeInInventory, shouldBeInBank = shouldBeInBank, shouldNotBeThere = shouldNotBeThere}
end

function CarosPreCrafter.deconUnnededItems(itemLists, craft)
	if not itemLists then itemLists = CarosPreCrafter.rebuildCraftItemList() end
	craft = craft or GetCraftingInteractionType()
	craft = craft ~= 0 and craft
	d(#itemLists.bagpackList)
	d(#itemLists.bankList + #itemLists.plusBankList)
	local bagLists = {
		[BAG_BACKPACK] = itemLists.bagpackList, 
		[BAG_BANK] = itemLists.bankList, 
		[BAG_SUBSCRIBER_BANK] = itemLists.plusBankList
	}
	if craft then PrepareDeconstructMessage() end
	for bagId, bagList in pairs(bagLists) do
		for i, itemData in pairs(bagList) do
			local slotIndex = itemData.slot
			local myLink = GetItemLink(bagId, slotIndex, 1)
			if myLink == itemData.link and (not craft or craft == itemData.craft) then 
				if not IsItemPlayerLocked(bagId, slotIndex) and (not FCOIS or not FCOIS.IsDeconstructionLocked(bagId, slotIndex)) then
					d(myLink) 
					if craft then AddItemToDeconstructMessage(bagId, slotIndex, 1) end
				end
			end
		end
	end
	if craft and not SendDeconstructMessage() then d("Failed to deconstruct items.") end
end

local function checkSVItems()
	if CarosPreCrafter.isOnMainCrafter then return end
	local svItems = CarosPreCrafter.sV.researchChars[CarosPreCrafter.thisCharId] and CarosPreCrafter.sV.researchChars[CarosPreCrafter.thisCharId].items
	if not svItems then return end
	for itemKey, itemData in pairs(svItems) do
		local _, _, traitIsKnown = GetSmithingResearchLineTraitInfo(itemData.craft, itemData.lineIndex, itemData.traitIndex)
		local time1, time2 = GetSmithingResearchLineTraitTimes(itemData.craft, itemData.lineIndex, itemData.traitIndex)
		if traitIsKnown or time1 or time2 then
			cpcD("Already known or in research! - Deleting entry: "..itemKey)
			svItems[itemKey] = nil
		end
	end
end
CarosPreCrafter.checkSVItems = checkSVItems

local function checkResearchItems(craft)
	cpcD("Checking...")
	local inResearch = {}
	CarosPreCrafter.inResearch = inResearch
	local openSpots = GetMaxSimultaneousSmithingResearch(craft)
	for researchLineIndex=1,  GetNumSmithingResearchLines(craft) do
		local _, _, numTraits = GetSmithingResearchLineInfo(craft, researchLineIndex)
		for traitIndex=1, numTraits do
			local time1, time2 = GetSmithingResearchLineTraitTimes(craft, researchLineIndex, traitIndex)
			if time1 or time2 then 
				inResearch[researchLineIndex] = true
				openSpots = openSpots - 1
				break
			end
		end
		if openSpots == 0 then cpcD("Stopping: no open spots") return {}, {}, 0 end
	end
	local charData =  CarosPreCrafter.sV.researchChars[CarosPreCrafter.thisCharId]
	if not charData or not (charData.active or charData.doNirn and not charData.finishedNirn or charData.doJewelry and not charData.finishedJewelry) then cpcD("Not active for this char.") return {}, {}, 0  end
	local svItems = charData and charData.items
	cpcD(svItems, 3)
	if not svItems then cpcD("No items in SV for "..CarosPreCrafter.thisCharId) return {}, {}, 0  end
	local sortedResearchItems = {}
	checkSVItems()
	for itemKey, itemData in pairs(svItems) do
		if itemData.craft == craft and not inResearch[itemData.lineIndex] and (itemData.location == 42 or itemData.location == CarosPreCrafter.thisCharId) then 
			cpcD("Looking for: "..itemKey, 2)
			local insertedInList = false
			for comparePosition, compareKey in ipairs(sortedResearchItems) do
				local compareItem = svItems[compareKey]
				local _, _, _, timeRemain = GetSmithingResearchLineInfo(craft, itemData.lineIndex)
				local _, _, _, timeRemain2 = GetSmithingResearchLineInfo(craft, compareItem.lineIndex)	
				if timeRemain == timeRemain2 then
					if itemData.lineIndex == compareItem.lineIndex then
						if itemData.traitIndex <= compareItem.traitIndex then
							table.insert(sortedResearchItems, comparePosition, itemKey)
							insertedInList = true
							break	
						end
					elseif itemData.lineIndex < compareItem.lineIndex then
						table.insert(sortedResearchItems, comparePosition, itemKey)
						insertedInList = true
						break
					end
				elseif timeRemain < timeRemain2 then
					table.insert(sortedResearchItems, comparePosition, itemKey)
					insertedInList = true
					break
				end
			end
			if not insertedInList then table.insert(sortedResearchItems, itemKey)  end
		end
	end
	
	if #sortedResearchItems == 0 then cpcD("Nothing to do here") end
	
	CarosPreCrafter.sortedResearchItems = sortedResearchItems
	cpcD("Stored itemList to CarosPreCrafter.sortedResearchItems")
	return sortedResearchItems, svItems, openSpots
end
CarosPreCrafter.checkResearchItems = checkResearchItems

local function startResearching(craft)
	if not craft then cpcD("Not crafting") return end
	if not CarosPreCrafter.craftsToPreCraftResearch[craft] then return end
	cpcD("Starting the research:"..craft)
	local sortedResearchItems, svItems, openSpots = checkResearchItems(craft)
	local lastQueuedTrait = false
	
	local function endResearch()
		EVENT_MANAGER:UnregisterForEvent("CPC_ResearchStarted", EVENT_SMITHING_TRAIT_RESEARCH_STARTED)
		SMITHING_SCENE:RemoveFragment(CarosPreCrafter.fragment)
	end
	
	local function queueNextResearchTrait()
		if GetCraftingInteractionType() ~= craft then 
			cpcD("Not at the same crafting station any more")
			EVENT_MANAGER:UnregisterForEvent("CPC_ResearchStarted", EVENT_SMITHING_TRAIT_RESEARCH_STARTED) 
		end
		if openSpots <= 0 or #sortedResearchItems == 0 then 
			endResearch()
			cpcD("No open spots or no items left")
			return
		end
		local itemKey = sortedResearchItems[1]
		local itemData = svItems[itemKey]
		if not itemData then 
			table.remove(sortedResearchItems, 1) 
			if #sortedResearchItems > 0 then queueNextResearchTrait() end
			return	
		end
		local bagId = false
		if itemData.location == CarosPreCrafter.thisCharId then bagId = BAG_BACKPACK elseif itemData.location == 42 then bagId = BAG_BANK end
		if bagId then
			local slotId, theBagId = findResearchItemInBag(bagId, craft, itemData.lineIndex, itemData.traitIndex)
			if not slotId then 
				bagId = bagId == BAG_BACKPACK and BAG_BANK or BAG_BACKPACK 
				slotId, theBagId = findResearchItemInBag(bagId, craft, itemData.lineIndex, itemData.traitIndex)
			end
			if slotId then
				cpcD(string.format("Found %s in slot %s", itemKey, slotId))
				lastQueuedTrait = {itemData.lineIndex, itemData.traitIndex}
				EVENT_MANAGER:RegisterForEvent("CPCresearchDontShowAlert", EVENT_CRAFT_STARTED, 
					function() 
						CRAFTING_RESULTS.craftingProcessProducesItems = false 
						EVENT_MANAGER:UnregisterForEvent("CPCresearchDontShowAlert", EVENT_CRAFT_STARTED)  
					end)
				ResearchSmithingTrait(theBagId, slotId)
				openSpots = openSpots - 1
			else
				-- if item not found: remove from list and set to 0
				cpcD(string.format("Not found: %s", itemKey))
				table.remove(sortedResearchItems, 1)
				itemData.location = 0
				if #sortedResearchItems > 0 then 
					queueNextResearchTrait()
					return
				end
			end
		end
	end
	
	EVENT_MANAGER:UnregisterForEvent("CPC_ResearchStarted", EVENT_SMITHING_TRAIT_RESEARCH_STARTED)
	EVENT_MANAGER:RegisterForEvent("CPC_ResearchStarted", EVENT_SMITHING_TRAIT_RESEARCH_STARTED, 
		function(_, startedCraft, startedLine, startedTrait) 
			if not lastQueuedTrait then return end
			cpcD(string.format("Started craft: %s, line: %s, trait: %s", startedCraft, startedLine, startedTrait))
			cpcD(string.format("Queued craft: %s, line: %s, trait: %s", craft, lastQueuedTrait[1], lastQueuedTrait[2] ))
			if startedCraft ~= craft or startedLine ~= lastQueuedTrait[1] or startedTrait ~= lastQueuedTrait[2] then return end
			svItems[sortedResearchItems[1]] = nil
			table.remove(sortedResearchItems, 1)
			if #sortedResearchItems == 0 then 
				endResearch()
			else
				zo_callLater(queueNextResearchTrait, 500)
			end
		end)
	
	queueNextResearchTrait()
	
end
CarosPreCrafter.startResearching = startResearching


-- itemsInLLCQueueByReference[myReference] = {char=charId, craft=itemData.craft, line=itemData.lineIndex, traitIndex=itemData.traitIndex, key=itemKey}

function CarosPreCrafter.showTTResearchCrafting(control, craft)
	local charItemList = {}
	local nirnArmorLeft, nirnWeaponLeft, jewelryTraitMatNumbers, jewelryTraitMatLinks = getMatNumbers()
	local ableToCraft = false
	for myReference, itemData in pairs(itemsInLLCQueueByReference) do
		if itemData.craft == craft then
			charItemList[itemData.char] = charItemList[itemData.char] or {}
			local lineName, lineIcon = GetSmithingResearchLineInfo(itemData.craft, itemData.line)
			local traitname = GS("SI_ITEMTRAITTYPE", GetSmithingResearchLineTraitInfo(itemData.craft, itemData.line, itemData.traitIndex))
			local ttLine = string.format(" |t28:28:%s|t %s, %s", lineIcon, lineName, traitname)
			if itemData.nirn or itemData.craft == CRAFTING_TYPE_JEWELRYCRAFTING then
				local numberToCheck = itemData.nirn and (itemData.weapon and nirnWeaponLeft or nirnArmorLeft) or jewelryTraitMatNumbers[jewelryTraitIds[itemData.traitIndex]]
				if not numberToCheck then cpcD("No number to check for "..ttLine) end
				if not numberToCheck or itemData.nirn and numberToCheck <= CarosPreCrafter.sV.keepNirnMats or not itemData.nirn and numberToCheck <= CarosPreCrafter.sV.keepJewelryTraitMats then
					ttLine = ZO_ERROR_COLOR:Colorize(ttLine)	
				else					
					ableToCraft = true
				end
			else
				ableToCraft = true
			end
			table.insert(charItemList[itemData.char], ttLine)
		end
	end	
	InitializeTooltip(InformationTooltip, control, LEFT)
	InformationTooltip:AddLine(GS(CPC_Research_CraftItems), "ZoFontWinH2")
	if not ableToCraft then 
		CarosPreCrafter.window.btn1.flash:SetColor(0.8,0,0.1)
	else
		CarosPreCrafter.window.btn1.flash:SetColor(0,0.8,0)
	end
	
	local charsToShow = {}
	local charsSorted = {}
	for charId, charItems in pairs(charItemList) do
		if #charItems > 0 then
			table.sort(charItems)
			local charName = allMyChars[charId]
			table.insert(charsSorted, charName)
			charsToShow[charName] = charItems
		end
	end
	table.sort(charsSorted)
	for _, charName in pairs(charsSorted) do
		ZO_Tooltip_AddDivider(InformationTooltip)
		InformationTooltip:AddLine(charName, "ZoFontGame")
		InformationTooltip:AddLine(table.concat(charsToShow[charName], "\n"), "ZoFontGame")
	end
end

function CarosPreCrafter.startResearchCrafting(craft)
	local nirnArmorLeft, nirnWeaponLeft, jewelryTraitMatNumbers, jewelryTraitMatLinks = getMatNumbers()

	for reference, itemData in pairs(internalLLCQueue[craft]) do
		local addItem = true
		if itemData.nirn then
			cpcD("Item is nirn...")
			if itemData.weapon then
				nirnWeaponLeft = nirnWeaponLeft - 1
				if nirnWeaponLeft < CarosPreCrafter.sV.keepNirnMats then
					addItem = false
					cpcD("Not enough mats for nirn weapon")
				end
			else
				nirnArmorLeft = nirnArmorLeft - 1
				if nirnArmorLeft < CarosPreCrafter.sV.keepNirnMats then 
					addItem = false 
					cpcD("Not enough mats for nirn armor")
				end
			end
		elseif craft == CRAFTING_TYPE_JEWELRYCRAFTING then 
			jewelryTraitMatNumbers[itemData.traitId - 1] = jewelryTraitMatNumbers[itemData.traitId - 1] or 0
			jewelryTraitMatNumbers[itemData.traitId - 1] = jewelryTraitMatNumbers[itemData.traitId - 1] - 1
			if jewelryTraitMatNumbers[itemData.traitId - 1] < CarosPreCrafter.sV.keepJewelryTraitMats then
				addItem = false
				cpcD("Not enough "..jewelryTraitMatLinks[itemData.traitId - 1])
			end
		end
		
		if addItem then
			LLC:CraftSmithingItemByLevel(itemData.pattern, false , 1, LLC_FREE_STYLE_CHOICE, itemData.traitId, false, craft, nil, ITEM_QUALITY_NORMAL, true, reference)
			internalLLCQueue[craft][reference] = nil
		end
	end
end

local function checkInternalLLCQueues(craft)
	-- Will check if there are items in queue for crafting (for one or every craft)
	if not craft then
		for craftIndex, _ in pairs(internalLLCQueue) do
			checkInternalLLCQueues(craftIndex)
		end
		return
	end
	local craftQueue = internalLLCQueue[craft]
	for reference, itemData in pairs(craftQueue) do
		return true
	end
	return false
end
CarosPreCrafter.checkInternalLLCQueues = checkInternalLLCQueues

local function cpcSetupLLC()
	local styleTable = {true, true, true, true, true, true, true, true, true} -- just 1-9 for the standard racial styles
	LLC = LibLazyCrafting:AddRequestingAddon(CarosPreCrafter.name, true, 
		function(result, station, craftedItem) 
			local itemData = craftedItem and craftedItem.reference and itemsInLLCQueueByReference[craftedItem.reference]
			if result == "success" and itemData then
				cpcD(craftedItem)
				local charData = CarosPreCrafter.sV.researchChars[itemData.char]
				local theItem = charData.items[itemData.key]
				theItem.location = thisCharId
				cpcD(string.format("Crafted %s for %s", craftedItem.reference, charData.name))
				itemsInLLCQueueByReference[craftedItem.reference] = nil
				local moreToCraft = false
				for i, v in pairs(itemsInLLCQueueByReference) do
					if v.craft == station then
						moreToCraft = true
						break
					end
				end
				if moreToCraft then 
					if CarosPreCrafter.window and WINDOW_MANAGER:GetMouseOverControl() == CarosPreCrafter.window.btn1 then
						CarosPreCrafter.showTTResearchCrafting(CarosPreCrafter.window.btn1, itemData.craft)
					end
				else
					SMITHING_SCENE:RemoveFragment(CarosPreCrafter.fragment) 
				end
			end
		end, 
		nil, styleTable) 
end

function CarosPreCrafter.checkResearchItemsOnMainCrafter()
	CarosPreCrafter.researchDeposit = {}
	for charId, charSv in pairs(CarosPreCrafter.sV.researchChars) do
		if charSv.active or charSv.doNirn and not charSv.finishedNirn or charSv.doJewelry and not charSv.finishedJewelry then
			for itemKey, itemData in pairs(charSv.items) do
				if itemData.location == CarosPreCrafter.thisCharId then
					table.insert(CarosPreCrafter.researchDeposit, {itemData.craft, itemData.lineIndex, itemData.traitIndex, charId, itemKey}) 
				end
			end
		end
	end
end

function CarosPreCrafter.checkRetrieveResearchItems()
	CarosPreCrafter.researchRetrieve = {}
	local myItems = CarosPreCrafter.sV.researchChars[CarosPreCrafter.thisCharId] and CarosPreCrafter.sV.researchChars[CarosPreCrafter.thisCharId].items or {}
	for itemKey, itemData in pairs(myItems) do
		if itemData.location == 42 then
			table.insert(CarosPreCrafter.researchRetrieve, {itemData.craft, itemData.lineIndex, itemData.traitIndex, itemKey})
		end
	end
end

function CarosPreCrafter.buildInternalLLCQueue(craft)
	if craft then 
		internalLLCQueue[craft] = {} 
	else 
		for i, _ in pairs(internalLLCQueue) do 
			internalLLCQueue[i] = {} 
		end 
	end
	for charId, charData in pairs(CarosPreCrafter.sV.researchChars) do
		if charData.active or charData.doNirn and not charData.finishedNirn or charData.doJewelry and not charData.finishedJewelry then
			for itemKey, itemData in pairs(charData.items) do
				local isNirn = false
				local doItem = not craft or itemData.craft == craft
				if itemData.craft == CRAFTING_TYPE_JEWELRYCRAFTING then
					doItem = doItem and charData.doJewelry and not charData.finishedJewelry
				else
					doItem = doItem and (charData.active or itemData.traitIndex == 9 and charData.doNirn)
					if itemData.traitIndex == 9 then isNirn = true end
				end
				if itemData.location == 0 and doItem then
					local myReference = string.format("%s:%s", charData.name, itemKey)
					local myTraitId = 0
									
					local myPattern = itemData.lineIndex
					local isWeapon = isLineWeapon(itemData.craft, itemData.lineIndex)
					if isWeapon then
						if isNirn then 
							myTraitId = ITEM_TRAIT_TYPE_WEAPON_NIRNHONED  + 1
						else
							myTraitId = itemData.traitIndex + ITEM_TRAIT_TYPE_WEAPON_POWERED
						end
					elseif itemData.craft == CRAFTING_TYPE_JEWELRYCRAFTING then
						myTraitId = jewelryTraitIds[itemData.traitIndex] + 1
						local changeLine = {[1]= 2, [2] = 1}
						myPattern = changeLine[myPattern]
					else
						if isNirn then
							myTraitId = ITEM_TRAIT_TYPE_ARMOR_NIRNHONED + 1
						else
							myTraitId = itemData.traitIndex + ITEM_TRAIT_TYPE_ARMOR_STURDY
						end
					end
					-- since at clothier we have two patterns for chest parts we need that subtracted...
					if itemData.craft == CRAFTING_TYPE_CLOTHIER and myPattern > 1 then myPattern = myPattern + 1 end
					-- again: why? for woodworking shield is the second pattern and everything afterwards is moved up
					if itemData.craft == CRAFTING_TYPE_WOODWORKING then myPattern = woodworkingRemap[myPattern] end
					internalLLCQueue[itemData.craft][myReference] = {pattern=myPattern, traitId = myTraitId, nirn=isNirn or nil, weapon = isNirn and isWeapon or nil}
					cpcD("Added an item to the queue..."..myReference)
					itemsInLLCQueueByReference[myReference] = {char=charId, craft=itemData.craft, line=itemData.lineIndex, traitIndex=itemData.traitIndex, key=itemKey, nirn=isNirn or nil, weapon = isNirn and isWeapon or nil}
				end
			end
		end
	end
end

local function findInLLCQueue(craft, llcReference)
	if LLC and LLC.personalQueue and LLC.personalQueue[craft] then
		for llcIndex, llcActualEntry in pairs (LLC.personalQueue[craft]) do
			if llcActualEntry.reference == llcReference then
				cpcD("Removed from lib-queue: "..llcReference)
				return llcIndex, LLC.personalQueue[craft]
			end
		end
	end
end

local function removeFromInternalLLC(itemKey)
	for llcReference, llcEntry in pairs(itemsInLLCQueueByReference) do
		if llcEntry.key == itemKey then 
			cpcD("Removing from internal LLC-Queue...")
			itemsInLLCQueueByReference[llcReference] = nil
			internalLLCQueue[llcEntry.craft][llcReference] = nil
			local llcIndex, pQueue = findInLLCQueue(llcEntry.craft, llcReference)
			if llcIndex then table.remove(pQueue, llcIndex) end
			break
		end
	end
end

function CarosPreCrafter.setupResearchCrafting()
	local charTable = {}
	local anythingActive = false
	checkSVItems()
	CarosPreCrafter.rebuildCraftItemList()
	
	if CarosPreCrafter.isOnMainCrafter then
		if not LLC then cpcSetupLLC() end
		for charId, charSv in pairs(CarosPreCrafter.sV.researchChars) do
			if charSv.active and charSv.isALittleKnowItAll then charSv.active = false end
			local doJewelry = charSv.doJewelry and not charSv.finishedJewelry
			local doNirn = charSv.doNirn and not charSv.finishedNirn
			if charSv.active or doJewelry or doNirn then 
				charSv.items = charSv.items or {}
				charTable[charId] = { 
					name = charSv.name, 
					-- attention: this is the only part of the table pointing to sv
					items = charSv.items,
					doJewelry = doJewelry,
					doNirn = doNirn, 
					isALittleKnowItAll = charSv.isALittleKnowItAll or false,
				}
				anythingActive = true 
			end
			if charSv.items then
				for itemKey, itemData in pairs(charSv.items) do
					-- remove all items that weren't crafted yet and everything from the bank that we don't actually want
					if itemData.location == 0 or itemData.location == 42 and 
						((itemData.craft ~= CRAFTING_TYPE_JEWELRYCRAFTING and 
						(not charSv.active or itemData.traitIndex == 9 and not doNirn)) or
						(itemData.craft == CRAFTING_TYPE_JEWELRYCRAFTING and 
						not doJewelry)) then -- or not CarosPreCrafter.sV.researchJewelryTraits[itemData.traitIndex] disabled that. if already crafted use it...
						charSv.items[itemKey] = nil
						removeFromInternalLLC(itemKey)
					end
				end -- end of itemdata loop
			end 
		end -- end of char loop
	end
	
	if not anythingActive then cpcD("Not activated for any char") return end
	
	--[[
		This loop will iterate through the crafts for each char activated in settings:
		CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_WOODWORKING
			(not CRAFTING_TYPE_JEWELRYCRAFTING for now)
		Table will look like this:
			charTable[charId]
				.name
				.items[item]
					.craft
					.lineIndex
					.traitIndex
					.location (charID/0 for not found/42 for bank)
				.crafts[craft]
					.priorityOpen (sorted by how many traits can be learned)
						{numOpen, lineIndex}
					.priorityQueued (second list for lines currently in research)
						{numOpen, lineIndex}
					.lines[lineIndex]
									
							
	]]--
	
	-- run the loop for all chars cpc is active for (charTable is local and was setup before)
	for charId, charData in pairs(charTable) do
		local csCharData = CS.Data.crafting and CS.Data.crafting.researched and CS.Data.crafting.researched[charData.name]
		-- only run if the char doesn't know all traits and if CS can provide the data
		if (not charData.isALittleKnowItAll or charData.doNirn or charData.doJewelry) and csCharData and type(csCharData) == "table" then 
			cpcD("Checking: "..charData.name)
			charData.crafts = {}
			local youKnowNothingJonSnow = false -- will be set true once an unlearned trait comes along
			local nirnLeftToLearn = false
			-- run the CS-data for all crafts
			for craft, csCraftData in pairs(csCharData) do
				-- exclude jewelry if not active
				if craft ~= CRAFTING_TYPE_JEWELRYCRAFTING or charData.doJewelry then
					local jewelryLeftToLearn = false
					charData.crafts[craft] = {}
					local craftData = charData.crafts[craft]
					craftData.priorityOpen = {}
					craftData.priorityQueued = {}
					craftData.nirnWeapons = {}
					craftData.nirnArmor = {}
					craftData.lines = {}
					-- still keep the items in queue that were already added there
					local listEntriesToFill = CarosPreCrafter.sV.researchItemsToPrecraft
					
					-- everytime an item is discarded from the list the addon rechecks which lines have items in them
					-- manually runs through the existing chardata and checking lines...
					-- running it the first time will also decrease the number of items to craft for every item already in the list.
					local linesWithItemsInSV = {}
					local function reCheckLinesWithItemsInSV(decreaseList)
						linesWithItemsInSV = {}
							for itemKey, itemData in pairs(charData.items) do
								if itemData.craft == craft then 
									if decreaseList then listEntriesToFill = listEntriesToFill - 1 end
									linesWithItemsInSV[itemData.lineIndex] = true
								end
							end
					end
					-- run it once (decreasing the number of items to craft)
					reCheckLinesWithItemsInSV(true)
					
					-- if there are more items in the list than the user wants the addon to craft (after changing the settings), delete every item that has not yet been crafted
					-- deleting all of them so the addon can check again which will be the fastest trait to research (deleting a single item would be random)
					if listEntriesToFill <= 0 then
						youKnowNothingJonSnow = youKnowNothingJonSnow or craft ~= CRAFTING_TYPE_JEWELRYCRAFTING
						for itemKey, itemData in pairs(charData.items) do
							if itemData.craft == craft and itemData.location == 0 then 
								cpcD("Removing from existing list: "..itemKey)
								charData.items[itemKey] = nil
								listEntriesToFill = listEntriesToFill + 1
								removeFromInternalLLC(itemKey)
							end
						end
						cpcD("ListEntriesToFill: "..listEntriesToFill)
						listEntriesToFill = math.min(CarosPreCrafter.sV.researchItemsToPrecraft, listEntriesToFill)
						reCheckLinesWithItemsInSV(false)
					end
					
					-- run the loop through the research lines in CS data
					for lineIndex, csLineData in pairs(csCraftData) do
						-- set lineData to an empty table filling it with all traits not yet researched
						craftData.lines[lineIndex] = {}
						local lineData = craftData.lines[lineIndex]
						local isLineInResearch = false
						
						-- run the loop through all the traits
						for traitIndex, csTraitData in pairs(csLineData) do
							if craft == CRAFTING_TYPE_JEWELRYCRAFTING and not csTraitData then
								jewelryLeftToLearn = true
							end	
							if craft ~= CRAFTING_TYPE_JEWELRYCRAFTING or CarosPreCrafter.sV.researchJewelryTraits[traitIndex] then
								if type(csTraitData) == "number" and csTraitData > GetTimeStamp() then isLineInResearch = true end
								if not csTraitData and (traitIndex < 9 or craft == CRAFTING_TYPE_JEWELRYCRAFTING) then 
									table.insert(lineData, traitIndex) 
								elseif not csTraitData and traitIndex == 9 then
									nirnLeftToLearn = true
									if isLineWeapon(craft, lineIndex) then
										table.insert(craftData.nirnWeapons, lineIndex)
									else
										table.insert(craftData.nirnArmor, lineIndex)
									end
								else
									local myKey = string.format("%s-%s-%s", craft, lineIndex, traitIndex)
									if charData.items and charData.items[myKey] then
										cpcD("Removing item from char data that has manually been analyzed...")
										charData.items[myKey] = nil
										listEntriesToFill = listEntriesToFill + 1
										removeFromInternalLLC(myKey)
										reCheckLinesWithItemsInSV(false)
									end
								end
							end
						end
						
						-- insert traits found into the correct lists but only if there are any traits to be added in the current line
						if #lineData > 0 then
							local tableToInsert = craftData.priorityOpen 
							-- use a second list for lines that are busy only to fill empty slots in the end
							if isLineInResearch or linesWithItemsInSV[lineIndex] then tableToInsert = craftData.priorityQueued end
							-- run through all the lines already in the chosen list
							for insertIndex, tableEntry in pairs(tableToInsert) do
								if tableEntry.numOpen <= #lineData then 
									-- break the loop once the new line would be faster to analyse and insert it at that point
									table.insert(tableToInsert, insertIndex, {numOpen = #lineData, lineIndex = lineIndex})
									break
								end
							end
							-- if all existing lines are faster to analyse than the new one, insert it at the end
							if #tableToInsert == 0 then table.insert(tableToInsert, {numOpen = #lineData, lineIndex = lineIndex}) end
						end
					end
					
					-- if there are less lines not in research than items to be crafted fill with items from the queued list
					for missingEntry=1, CarosPreCrafter.sV.researchItemsToPrecraft - #craftData.priorityOpen do
						if not craftData.priorityQueued[missingEntry] then break end
						table.insert(craftData.priorityOpen, craftData.priorityQueued[missingEntry])
					end
					
					if charData.doNirn then -- fill empty spots with nirn (only if all other lines are busy)
						for missingEntry=1, CarosPreCrafter.sV.researchItemsToPrecraft - #craftData.priorityOpen do
							if not craftData.nirnArmor[missingEntry] then break end
							table.insert(craftData.priorityOpen, {nirn = true, lineIndex = craftData.nirnArmor[missingEntry]})
						end
						
						for missingEntry=1, CarosPreCrafter.sV.researchItemsToPrecraft - #craftData.priorityOpen do
							if not craftData.nirnWeapons[missingEntry] then break end
							table.insert(craftData.priorityOpen, {nirn = true, lineIndex = craftData.nirnWeapons[missingEntry]})
						end
					end
					
					-- if there should be more then there are lines to craft for do two items in one line
					local doDuplicates = CarosPreCrafter.sV.researchItemsToPrecraft - #craftData.priorityOpen
					
					-- list should be capped not to have more items then desired
					while #craftData.priorityOpen > CarosPreCrafter.sV.researchItemsToPrecraft do
						youKnowNothingJonSnow = youKnowNothingJonSnow or craft ~= CRAFTING_TYPE_JEWELRYCRAFTING
						table.remove(craftData.priorityOpen, #craftData.priorityOpen)
					end
					
					local function addItemToChar(lineIndex, traitIndex) 
						local alreadyInLine = false
						local myKey = string.format("%s-%s-%s", craft, lineIndex, traitIndex)
						if charData.items[myKey] then alreadyInLine = true end
						if not alreadyInLine and listEntriesToFill > 0 then
							-- the .items table is the only part of charData that points directly to the sv!
							charData.items[myKey] = {craft = craft, lineIndex = lineIndex, traitIndex = traitIndex, location = 0}
							listEntriesToFill = listEntriesToFill - 1
						end
					end
						
					for _, openItem in pairs(craftData.priorityOpen) do
						youKnowNothingJonSnow = youKnowNothingJonSnow or craft ~= CRAFTING_TYPE_JEWELRYCRAFTING
												
						if openItem.nirn then 
							addItemToChar(openItem.lineIndex, 9)
						else
							for _, traitIndex in pairs(craftData.lines[openItem.lineIndex]) do
								addItemToChar(openItem.lineIndex, traitIndex)
								if doDuplicates > 0 then doDuplicates = doDuplicates - 1 else break end
							end
						end
						
					end-- checking priorityLists
					if craft == CRAFTING_TYPE_JEWELRYCRAFTING and not jewelryLeftToLearn then
						CarosPreCrafter.sV.researchChars[charId].finishedJewelry = true
					end
				end -- if not jewelry or jewelry active
				
			end -- end of the craftForLoop
			if not nirnLeftToLearn then
				CarosPreCrafter.sV.researchChars[charId].finishedNirn = true
			end
			if not youKnowNothingJonSnow then 
				charData.isALittleKnowItAll = true
				CarosPreCrafter.sV.researchChars[charId].isALittleKnowItAll = true
			end
		end -- if char...
	end --end of charLoop
	CarosPreCrafter.rebuildCraftItemList()
	return charTable
end


function CarosPreCrafter.showResearchBtnTT(self)
	local craft = GetCraftingInteractionType()
	local myItems, svItems, openSpots = CarosPreCrafter.checkResearchItems(craft)
	local myText = {}
	local i = 1
	while i <= openSpots and i <= #myItems do
		local itemData = svItems[myItems[i]]
		local lineName, lineIcon, _, timeRemain = GetSmithingResearchLineInfo(itemData.craft, itemData.lineIndex)
		local traitName = GS("SI_ITEMTRAITTYPE", GetSmithingResearchLineTraitInfo(itemData.craft, itemData.lineIndex, itemData.traitIndex))
		local timeText = ""
		if timeRemain >= ZO_ONE_DAY_IN_SECONDS then
            timeText = zo_strformat("<<X:1>>", ZO_FormatTime(timeRemain, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS))
        else
            timeText = zo_strformat("<<X:1>>", ZO_FormatTimeLargestTwo(timeRemain, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL))
        end
		
		table.insert(myText, string.format("|t28:28:%s|t %s, %s (%s)", lineIcon, lineName, traitName, timeText))
		i = i + 1
	end
	
	ZO_Tooltips_ShowTextTooltip(self, RIGHT,  string.format(GS(CPC_Research_ResearchAvailable), #myText, table.concat(myText, "\n")))
						
end	

function CarosPreCrafter.logSvItems(craft)
	for charId, charData in pairs(CarosPreCrafter.sV.researchChars) do
		if (charData.active or charData.doJewelry or charData.doNirn) and charData.items then
			d(allMyChars[charId])
			for itemKey, itemData in pairs(charData.items) do
				local location = itemData.location == 0 and "-" or itemData.location == 42 and "Bank" or allMyChars[itemData.location]
				local lineName, lineIcon, _, timeRemain = GetSmithingResearchLineInfo(itemData.craft, itemData.lineIndex)
				local traitName = GS("SI_ITEMTRAITTYPE", GetSmithingResearchLineTraitInfo(itemData.craft, itemData.lineIndex, itemData.traitIndex))
				if not craft or craft == itemData.craft then d(string.format("... |t28:28:%s|t %s, %s (%s): %s", lineIcon, lineName, traitName, itemKey, location)) end
			end
		end
	end
end

function CarosPreCrafter.logLLC(craft)
	if not craft then
		for i, v in pairs(CarosPreCrafter.craftsToPreCraftResearch) do
			CarosPreCrafter.logLLC(i)
		end
		return
	end
	d("Craft "..craft..":")
	for i, v in pairs(internalLLCQueue[craft]) do
		d(string.format("... %s - %s, %s%s", i, v.pattern, v.traitId, v.nirn and "(Nirn)" or ""))
	end
end