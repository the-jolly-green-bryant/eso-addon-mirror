local GS = GetString
local CS = CraftStoreFixedAndImprovedLongClassName

local myAccentColor = "9e0911"
local myTextColor = "1d6dad"

local cllD = CarosLootList.cllD
local cllPost = CarosLootList.cllPost

local cllSLDiag = false

-- jensTest42 = function(bagId, slotIndex) local myLink = GetItemLink(bagId, slotIndex) local _, _, _, _, _, itemSetId = GetItemLinkSetInfo(myLink, false) if itemSetId == 391 then return myLink else return false end end
-- CarosLootList.depositToBank(jensTest42, false, true, function() end,  function() end,  function() end)
-- CarosLootList.retrieveFromBank(jensTest42, false, true, function() end,  function() end,  function() end)

local function getItemPrice(itemLink)
	if not LibPrice then return false end
	local myPrice, priceSource = LibPrice.ItemLinkToPriceGold(itemLink)
	if priceSource == "npc" then return false end
	if not myPrice or myPrice == 0 then return false end
	return myPrice
end

function CarosLootList.retrieveFromVirtual()
	local cbLimitOther = CarosLootList.sV.cbLimitOther or 1000
	local cbLimitProvAlch = CarosLootList.sV.cbLimitProvAlch or 300
	local cbLimitGolden = CarosLootList.sV.cbLimitGolden or 1000
	local cbLimitAmount = CarosLootList.sV.cbLimitAmount or 50
	local cbGoldenStacks = CarosLootList.sV.cbGoldenStacks or 16
	local cbLimitIdentical = CarosLootList.sV.cbLimitIdentical or 0
	
	local stacksRetrieved = 0
	
	local itemIdStacks = {}
	local itemIdsMaxed = {}
	
	local function retrieveItem(sourceSlot, stackSize)
		local destSlot = FindFirstEmptySlotInBag(BAG_BACKPACK)
		if not destSlot then return false end
		if IsProtectedFunction("RequestMoveItem") then
			CallSecureProtected("RequestMoveItem", BAG_VIRTUAL, sourceSlot, BAG_BACKPACK, destSlot, stackSize)
		else
			RequestMoveItem(BAG_VIRTUAL, sourceSlot, BAG_BACKPACK, destSlot, stackSize)
		end
		return destSlot
	end
	
	local function  checkStack(virtualSlot, itemType, stackSize, maxStack)
		 if itemIdsMaxed[virtualSlot] then return false end
		 local myQuality = GetItemQuality(BAG_VIRTUAL, virtualSlot)
		 if myQuality == ITEM_QUALITY_LEGENDARY then
			return stackSize >= cbLimitGolden + cbGoldenStacks
		 end
		 		 
		-- other: ITEMTYPE_ARMOR_BOOSTER, ITEMTYPE_ARMOR_TRAIT, ITEMTYPE_BLACKSMITHING_BOOSTER, ITEMTYPE_BLACKSMITHING_MATERIAL, 
		--ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, ITEMTYPE_CLOTHIER_BOOSTER, ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_CLOTHIER_RAW_MATERIAL, 
		--ITEMTYPE_ENCHANTING_RUNE_ASPECT, ITEMTYPE_ENCHANTING_RUNE_ESSENCE, ITEMTYPE_ENCHANTING_RUNE_POTENCY, 
		--ITEMTYPE_FURNISHING_MATERIAL, ITEMTYPE_JEWELRYCRAFTING_BOOSTER, ITEMTYPE_JEWELRYCRAFTING_MATERIAL,
		--ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER, ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL, ITEMTYPE_JEWELRY_RAW_TRAIT, ITEMTYPE_JEWELRY_TRAIT,
		--ITEMTYPE_RAW_MATERIAL, ITEMTYPE_STYLE_MATERIAL, ITEMTYPE_WEAPON_BOOSTER, ITEMTYPE_WEAPON_TRAIT, ITEMTYPE_WOODWORKING_BOOSTER, 
		-- ITEMTYPE_WOODWORKING_MATERIAL, ITEMTYPE_WOODWORKING_RAW_MATERIAL, 		 		 

		local alchProv = {
			[ITEMTYPE_POISON] = true, 
			[ITEMTYPE_POISON_BASE] = true, 
			[ITEMTYPE_POTION] = true, 
			[ITEMTYPE_POTION_BASE] = true, 
			[ITEMTYPE_INGREDIENT] = true, 
			[ITEMTYPE_REAGENT] = true, 
			[ITEMTYPE_SPICE] = true, 
			[ITEMTYPE_FLAVORING] = true, 
		}
		if alchProv[itemType] then
			return stackSize >= cbLimitProvAlch
		end
		return stackSize >= cbLimitOther		
	end
	
	local virtualSlot = GetNextVirtualBagSlotId()
	
	local isRaw = {
		[ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = true,
		[ITEMTYPE_CLOTHIER_RAW_MATERIAL] = true,
		[ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] = true,
		[ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = true,
		[ITEMTYPE_JEWELRY_RAW_TRAIT] = true,
		[ITEMTYPE_RAW_MATERIAL] = true,
		[ITEMTYPE_WOODWORKING_RAW_MATERIAL] = true,
	}
	
	
	local lastPrice = 0
	local lastStack = 0
	local itemToRetrieve = false
	local maxStackToRetrieve = 0
	
	-- 1: Alphabetical, 2: Number of Stacks, 3: Price (up), 4: Price (down)
	local sortFunctions = {
		function(theItem, stackSize) 
			if not itemToRetrieve or GetItemName(BAG_VIRTUAL, theItem) < GetItemName(BAG_VIRTUAL, itemToRetrieve) then
				itemToRetrieve = theItem 
				return true 
			end 
		end,
		function(theItem, stackSize) 
			if stackSize > lastStack then 
				lastStack = stackSize 
				itemToRetrieve = theItem 
				return true 
			else 
				return false 
			end 
		end,
		function(theItem, stackSize) 
			local thePrice = getItemPrice(GetItemLink(BAG_VIRTUAL, theItem))
			if thePrice and (thePrice < lastPrice or lastPrice == 0) then 
				lastPrice = thePrice 
				itemToRetrieve = theItem
				return true 
			else
				return false
			end
		end,
		function(theItem, stackSize) 
			local thePrice = getItemPrice(GetItemLink(BAG_VIRTUAL, theItem))
			if thePrice and thePrice > lastPrice then 
				lastPrice = thePrice 
				itemToRetrieve = theItem
				return true 
			else
				return false
			end
		end,
		function(theItem, stackSize) 
			local thePrice = getItemPrice(GetItemLink(BAG_VIRTUAL, theItem))
			thePrice = thePrice and thePrice * stackSize
			if thePrice and (thePrice < lastPrice or lastPrice == 0) then 
				lastPrice = thePrice 
				itemToRetrieve = theItem
				return true 
			else
				return false
			end
		end,
		function(theItem, stackSize) 
			local thePrice = getItemPrice(GetItemLink(BAG_VIRTUAL, theItem))
			thePrice = thePrice and thePrice * stackSize
			if thePrice and thePrice > lastPrice then 
				lastPrice = thePrice 
				itemToRetrieve = theItem
				return true 
			else
				return false
			end
		end
	}
	local mySortFunction = sortFunctions[CarosLootList.sV.cbSort  or 1]
	
	local function retrieveNext()
		virtualSlot = GetNextVirtualBagSlotId()
		itemToRetrieve = false
		lastPrice = 0
		lastStack = 0
		while virtualSlot do
			if not CarosLootList.sV.cbExclude[virtualSlot] then
				local itemType = GetItemType(BAG_VIRTUAL, virtualSlot)
				if not (isRaw[itemType] and CarosLootList.sV.cbExclude.raw) and not (itemType == ITEMTYPE_LURE and CarosLootList.sV.cbExclude.bait)  then
					local stackSize, maxStack = GetSlotStackSize(BAG_VIRTUAL, virtualSlot)
						if checkStack(virtualSlot, itemType, stackSize, maxStack) then
							if mySortFunction(virtualSlot, stackSize) then 
								local myQuality = GetItemQuality(BAG_VIRTUAL, virtualSlot)
								if myQuality == ITEM_QUALITY_LEGENDARY then
									maxStackToRetrieve = cbGoldenStacks
								else
									maxStackToRetrieve = maxStack 
								end
							end
						end
				end	
			end
			virtualSlot = GetNextVirtualBagSlotId(virtualSlot)
		end
		if not itemToRetrieve then cllD("Nothing to retrieve..?") return false end
		local itemName = string.format("%sx %s", maxStackToRetrieve, GetItemLink(BAG_VIRTUAL, itemToRetrieve))
		local destSlot = retrieveItem(itemToRetrieve, maxStackToRetrieve)
		if not destSlot then cllPost(GS(CLL_InventorySpace)) return end
		cllPost(itemName)
		cllD("ItemId: "..itemToRetrieve..", DestSlot: "..destSlot)
		local myTries = 1
		local function checkSlot(myTries)
			myTries = myTries + 1
			zo_callLater(function()
				if GetItemId(BAG_BACKPACK, destSlot) ~= itemToRetrieve then
					if myTries < 20 then 
						checkSlot(myTries) 
					else
						cllPost(GS(CLL_BankFail))
					end
				else
					CarosLootList.sV.matTransferCount = CarosLootList.sV.matTransferCount + maxStackToRetrieve
					stacksRetrieved = stacksRetrieved + 1
					itemIdStacks[itemToRetrieve] = itemIdStacks[itemToRetrieve] or 0
					itemIdStacks[itemToRetrieve] = itemIdStacks[itemToRetrieve] + 1
					if cbLimitIdentical > 0 and itemIdStacks[itemToRetrieve] >= cbLimitIdentical then itemIdsMaxed[itemToRetrieve] = true end
					if stacksRetrieved < cbLimitAmount then retrieveNext() end
				end
			end, 50)
		end
		checkSlot(myTries)
	end
	cllPost(GS(CLL_Transferring))
	retrieveNext()
end

function CarosLootList.depositStackables(destBank, postTransferStatus)
	
	if GetInteractionType() ~= INTERACTION_BANK then cllPost(GS(CLL_NoBank)) return false end
	
	StackBag(BAG_BACKPACK)
	
	destBank = destBank or GetBankingBag()
	
	StackBag(destBank)
	
	local itemsToStack = {}
		
	for slotIndex=0, GetBagSize(BAG_BACKPACK) do
		local isBankLocked = FCOIS and FCOIS.IsPlayerBankDepositLocked(BAG_BACKPACK, slotIndex) or false
		local myLink = GetItemLink(BAG_BACKPACK, slotIndex)
		if not IsItemLinkStolen(myLink) and not isBankLocked and IsItemLinkStackable(myLink) then 
			for destSlot=0, GetBagSize(destBank) do
				if GetItemLink(destBank, destSlot) == myLink then
					local stackSource = GetSlotStackSize(BAG_BACKPACK, slotIndex)
					local stackDest, stackMax = GetSlotStackSize(destBank, destSlot)
					if stackDest < stackMax then
						if stackSource + stackDest > stackMax then stackSource = stackMax - stackDest end
						table.insert(itemsToStack, {slotIndex, destSlot, stackSource})
						break
					end
				end
			end
		end
	end
	
	cllD(itemsToStack)
	
	if #itemsToStack > 0 then if postTransferStatus then cllPost(GS(CLL_Transferring)) end else return false end
	
	
	local myCount = #itemsToStack
	
	local function depositItem(sourceSlot, destSlot, stackSize)
		if GetItemLink(BAG_BACKPACK, sourceSlot) ~= GetItemLink(destBank, destSlot) then return false end
		if IsProtectedFunction("RequestMoveItem") then
			CallSecureProtected("RequestMoveItem", BAG_BACKPACK, sourceSlot, destBank, destSlot, stackSize)
		else
			RequestMoveItem(BAG_BACKPACK, sourceSlot, destBank, destSlot, stackSize)
		end
		return true
	end
	
	local  function depositNext()
			if #itemsToStack == 0 then 
			EVENT_MANAGER:UnregisterForEvent("CarosLootList_DepositFail2", EVENT_BANK_DEPOSIT_NOT_ALLOWED) 
			depositNotAllowed = false
			if destBank == BAG_BANK then CarosLootList.depositStackables(BAG_SUBSCRIBER_BANK, postTransferStatus) end
			return 
		end
		local sourceSlot, destSlot, stackSize = unpack(itemsToStack[1])
		local myLink = GetItemLink(BAG_BACKPACK, sourceSlot)
		if myLink == GetItemLink(destBank, destSlot) then
			table.remove(itemsToStack, 1)
			if postTransferStatus then cllPost(string.format(GS(CLL_BankCounter), myCount - #itemsToStack, myCount, myLink), true) end
			if not depositItem(sourceSlot, destSlot, stackSize) then 
				if postTransferStatus then cllPost(GS(CLL_BankSpace)) end
				return 
			else
				local myTries = 1
				local oldStack = GetSlotStackSize(BAG_BACKPACK, sourceSlot)
				local function checkSlot(myTries)
					myTries = myTries + 1
					zo_callLater(function()
						if depositNotAllowed then
							depositNotAllowed = false
							CarosLootList.sV.transferCount = CarosLootList.sV.transferCount + 1
							depositNext()
						elseif GetSlotStackSize(BAG_BACKPACK, sourceSlot) > oldStack - stackSize then
							if myTries < 20 and GetInteractionType() == INTERACTION_BANK then 
								checkSlot(myTries) 
							else
								if postTransferStatus then cllPost(GS(CLL_BankFail)) end
							end
						else
							CarosLootList.sV.transferCount = CarosLootList.sV.transferCount + 1
							depositNext()
						end
					end, 50)
				end
				checkSlot(myTries)
				return
			end
		end
	end
	EVENT_MANAGER:RegisterForEvent("CarosLootList_DepositFail2", EVENT_BANK_DEPOSIT_NOT_ALLOWED, function() depositNotAllowed = true end)
	depositNext()
end


function CarosLootList.depositToBank(checkFunction, preCheckFunction, postTransferStatus, onItemTransfer, onItemFail, onTransferComplete, callAfterPrecheck)
	-- checkFunction/preCheckFunction = get source+slotIndex, return itemLink and stackSize to transferItem
	-- onItemTransfer: get bag+slot and boolean if already transferred successfully
	-- onItemFail: get bag+slot and boolean if destbag is full

	if GetInteractionType() ~= INTERACTION_BANK then cllPost(GS(CLL_NoBank)) return false end
	
	local destBank = GetBankingBag()
	local myPosition = 1
	local myCount = 0
		
	-- use a separate preCheckFunction if the itemCheck depends on items already being transferred
	preCheckFunction = preCheckFunction or checkFunction
	
	onItemTransfer = onItemTransfer or function() end
	onItemFail = onItemFail or function() end
	onTransferComplete = onTransferComplete or function() end
	
	for slotIndex=0, GetBagSize(BAG_BACKPACK) do
		local isBankLocked = FCOIS and FCOIS.IsPlayerBankDepositLocked(BAG_BACKPACK, slotIndex) or false
		if preCheckFunction(BAG_BACKPACK, slotIndex) and not IsItemStolen(BAG_BACKPACK, slotIndex) and not isBankLocked then myCount = myCount + 1 end
	end
	
	if callAfterPrecheck then callAfterPrecheck() end
	
	if myCount > 0 then if postTransferStatus then cllPost(GS(CLL_Transferring)) end else return false end
	
	local function getFreeSlot()
		local destBag = destBank
		local destSlot = FindFirstEmptySlotInBag(destBag)
		
		-- if depositing into regular bank then try the eso plus bank
		if not destSlot and destBag == BAG_BANK then
			destBag = BAG_SUBSCRIBER_BANK
			destSlot = FindFirstEmptySlotInBag(destBag)
		end
		
		if not destSlot then destBag = nil end
		return destBag, destSlot
	end
	
	local function depositItem(sourceSlot, stackSize)
		local destBag, destSlot = getFreeSlot()
		stackSize = stackSize or 1
		if not destBag or not destSlot then return false end
		if IsProtectedFunction("RequestMoveItem") then
			CallSecureProtected("RequestMoveItem", BAG_BACKPACK, sourceSlot, destBag, destSlot, stackSize)
		else
			RequestMoveItem(BAG_BACKPACK, sourceSlot, destBag, destSlot, stackSize)
		end
		return destBag, destSlot
	end
	local slotsToIgnore = {}
	local  function depositNext()
		for slotIndex=0, GetBagSize(BAG_BACKPACK) do
			local isBankLocked = FCOIS and FCOIS.IsPlayerBankDepositLocked(BAG_BACKPACK, slotIndex) or false
			local myLink, stackSize = checkFunction(BAG_BACKPACK, slotIndex)
			if not slotsToIgnore[slotIndex] and myLink and not isBankLocked and not IsItemLinkStolen(myLink) then
				if postTransferStatus then cllPost(string.format(GS(CLL_BankCounter), myPosition, myCount, myLink), true) end
				
				onItemTransfer(BAG_BACKPACK, slotIndex, false)
				myPosition = myPosition + 1
				
				local destBag, destSlot = depositItem(slotIndex, stackSize)
				
				if not destBag or not destSlot then 
					if postTransferStatus then cllPost(GS(CLL_BankSpace)) end
					onItemFail(BAG_BACKPACK, slotIndex, true)
					return 
				else
					local myTries = 1
					local function checkSlot(myTries)
						myTries = myTries + 1
						zo_callLater(function()
							if depositNotAllowed then
								slotsToIgnore[slotIndex] = true
								depositNotAllowed = false
								CarosLootList.sV.transferCount = CarosLootList.sV.transferCount + 1
								depositNext()
							elseif GetItemLink(destBag, destSlot, 1) ~= myLink then
								if myTries < 20 and GetInteractionType() == INTERACTION_BANK then 
									checkSlot(myTries) 
								else
									if postTransferStatus then cllPost(GS(CLL_BankFail)) end
									onItemFail(theSource, slotIndex, false)
								end
							else
								onItemTransfer(destBag, destSlot, myLink)
								CarosLootList.sV.transferCount = CarosLootList.sV.transferCount + 1
								depositNext()
							end
						end, 50)
					end
					checkSlot(myTries)
					return
				end
			end
		end
		-- the next code is only executed if nothing was found
		EVENT_MANAGER:UnregisterForEvent("CarosLootList_DepositFail", EVENT_BANK_DEPOSIT_NOT_ALLOWED) 
		depositNotAllowed = false
		onTransferComplete()
		return true
	end
	EVENT_MANAGER:RegisterForEvent("CarosLootList_DepositFail", EVENT_BANK_DEPOSIT_NOT_ALLOWED, function() depositNotAllowed = true end)
	depositNext()
end


function CarosLootList.retrieveFromBank(checkFunction, preCheckFunction, postTransferStatus, onItemTransfer, onItemFail, onTransferComplete, callAfterPrecheck)
	-- checkFunction/preCheckFunction = get source+slotIndex, return itemLink and stackSize to transferItem
	-- onItemTransfer: get bag+slot and boolean if already transferred successfully
	-- onItemFail: get bag+slot and boolean if destbag is full

	
	
	if GetInteractionType() ~= INTERACTION_BANK then cllPost(GS(CLL_NoBank)) return false end
	local theSource = GetBankingBag()
	local myPosition = 1
	local myCount = 0
	
	-- use a separate preCheckFunction if the itemCheck depends on items already being transferred
	preCheckFunction = preCheckFunction or checkFunction
	onItemTransfer = onItemTransfer or function() end
	onItemFail = onItemFail or function() end
	onTransferComplete = onTransferComplete or function() end
			
	for slotIndex=0, GetBagSize(theSource) do
		local isBankLocked = FCOIS and FCOIS.IsPlayerBankWithdrawLocked(BAG_BACKPACK, slotIndex) or false
		local myLink = preCheckFunction(theSource, slotIndex) 
		if myLink and not IsItemLinkStolen(myLink) and not isBankLocked then myCount = myCount + 1 end
	end
	
	if theSource == BAG_BANK then
		for slotIndex=0, GetBagSize(BAG_SUBSCRIBER_BANK) do
			local isBankLocked = FCOIS and FCOIS.IsPlayerBankWithdrawLocked(BAG_BACKPACK, slotIndex) or false
			local myLink = preCheckFunction(BAG_SUBSCRIBER_BANK, slotIndex) 
			if myLink and not IsItemLinkStolen(myLink) and not isBankLocked then myCount = myCount + 1 end
		end
	end
	
	if callAfterPrecheck then callAfterPrecheck() end
	
	if myCount > 0 then if postTransferStatus then cllPost(GS(CLL_Transferring)) end else return false end
	
	local function transferItem(sourceSlot, stackSize)
		local destSlot = FindFirstEmptySlotInBag(BAG_BACKPACK)
		stackSize = stackSize or 1
		if not destSlot then return false end
		if IsProtectedFunction("RequestMoveItem") then
			CallSecureProtected("RequestMoveItem", theSource, sourceSlot, BAG_BACKPACK, destSlot, stackSize)
		else
			RequestMoveItem(theSource, sourceSlot, BAG_BACKPACK, destSlot, stackSize)
		end
		return destSlot
	end
	
	local  function transferNext()
		for slotIndex=0, GetBagSize(theSource) do
			local myLink, stackSize = checkFunction(theSource, slotIndex)
			local isBankLocked = FCOIS and FCOIS.IsPlayerBankWithdrawLocked(theSource, slotIndex) or false
			if myLink and not isBankLocked and not IsItemLinkStolen(myLink) then
				if postTransferStatus then cllPost(string.format(GS(CLL_BankCounter), myPosition, myCount, myLink), true) end
				onItemTransfer(theSource, slotIndex, false)
				myPosition = myPosition + 1
				local destSlot = transferItem(slotIndex, stackSize)
				if not destSlot then 
					if postTransferStatus then cllPost(GS(CLL_InventorySpace)) end
					onItemFail(theSource, slotIndex, true)
					return
				end
				local myTries = 1
				local function checkSlot(myTries)
					myTries = myTries + 1
					zo_callLater(function()
						if GetItemLink(BAG_BACKPACK, destSlot, 1) ~= myLink then
							if myTries < 20 and GetInteractionType() == INTERACTION_BANK then 
								checkSlot(myTries) 
							else
								if postTransferStatus then cllPost(GS(CLL_BankFail)) end
								onItemFail(theSource, slotIndex, false)
							end
						else
							onItemTransfer(BAG_BACKPACK, destSlot, myLink)
							CarosLootList.sV.transferCount = CarosLootList.sV.transferCount + 1
							transferNext()
						end
					end, 50)
				end
				checkSlot(myTries)
				return
			end
		end
		-- the next code is only executed if nothing was found
		if theSource == BAG_BANK then 
			theSource = BAG_SUBSCRIBER_BANK 
			transferNext() 
		else
			
			onTransferComplete()
			return true
		end	
	end
	transferNext()
	
end

 
function CarosLootList.depositItems(depositDungeon, depositOther, destBank)
	
	local function shouldDepositItem(bagId, slotId)
		local myLink = GetItemLink(bagId, slotId, 1)
		local myType = GetItemType(bagId, slotId)
		local isBankLocked = FCOIS and FCOIS.IsPlayerBankDepositLocked(bagId, slotId) or false
		local isDungeonItem = GetItemBoPTimeRemainingSeconds(bagId, slotId) > 0
		if (myType == ITEMTYPE_WEAPON or myType == ITEMTYPE_ARMOR) and not IsItemJunk(bagId, slotId) and not IsItemLinkStolen(myLink) and 
		  not IsItemPlayerLocked(bagId, slotId) and not isBankLocked and not IsItemLinkCrafted(myLink) and GetItemLinkBindType(myLink) ~= BIND_TYPE_ON_PICKUP_BACKPACK and
		  ((IsItemLinkSetCollectionPiece(myLink) and depositDungeon and isDungeonItem) or 
		  (depositOther and not isDungeonItem)) then
			return myLink
		end
		return false
	end
	
	CarosLootList.depositToBank(shouldDepositItem, shouldDepositItem, true, false, false, false)

end

local function checkForCraftingPassive(reqRank)
	local abIds = {47276, 47288, 47282}
	for i, v in pairs(abIds) do
		local skillType, skillLineIndex, skillIndex = GetSpecificSkillAbilityKeysByAbilityId(v)
		local _, _, _, _, _, purchased, _, rank = GetSkillAbilityInfo(skillType, skillLineIndex, skillIndex)         
		if purchased and rank >= reqRank then return true end
	end
	return false
end

local craftingItemCheckFunctions = {
	[ITEMTYPE_RACIAL_STYLE_MOTIF] = function(itemLink, argTable)
		cllD(string.format("Checking motif: %s", itemLink), 2)
		if argTable and not argTable.motifs then cllD("Does not fit filter", 2) return false end
		local isKnown = IsItemLinkBookKnown(itemLink)
		local canLearn = true
		if not isKnown then 
			local myId = GetItemLinkItemId(itemLink)
			local requiredRanks = { -- the racial motifs that require a certain rank in one of the crafting passives
				[54868] = 1, -- Imperial
				[51638] = 8, -- Ancient Elves
				[51565] = 7, -- Barbaric
				[51345] = 6, -- Primal 
				[51688] = 9, -- Daedric
			}
			if requiredRanks[myId] then canLearn = checkForCraftingPassive(requiredRanks[myId]) end
		end
		return true, isKnown, CS.IsStyleNeeded(itemLink), canLearn
	end,
	
	[ITEMTYPE_CONTAINER] = function(itemLink, argTable)
		cllD(string.format("Checking container: %s", itemLink), 2)
		if argTable and not argTable.style then cllD("Does not fit filter", 2) return false end

		local _, specializedItemType = GetItemLinkItemType(itemLink)
		local collectibleId = GetItemLinkContainerCollectibleId(itemLink)
		if GetCollectibleCategoryType(collectibleId) ~= COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE then return false end
		if specializedItemType ~= SPECIALIZED_ITEMTYPE_CONTAINER or not collectibleId or collectibleId == 0 then cllD("Is not a collectible container", 2) return false end
		local isKnown = IsCollectibleUnlocked(collectibleId)
		return true, isKnown, "", true
	end,
	
	[ITEMTYPE_COLLECTIBLE] = function(itemLink, argTable)
		cllD(string.format("Checking collectible: %s", itemLink), 2)
		if argTable and not argTable.style then cllD("Does not fit filter", 2) return false end
		local _, specializedItemType = GetItemLinkItemType(itemLink)
		if specializedItemType ~= SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE then cllD("Is not a style page", 2) return false end
		local isKnown = IsCollectibleUnlocked(GetItemLinkContainerCollectibleId(itemLink))
		return true, isKnown, "", true
	end,
	
	[ITEMTYPE_RECIPE] = function(itemLink, argTable)
		cllD(string.format("Checking recipe: %s", itemLink), 2)
		local neededOnMain = ""
		if IsItemLinkFurnitureRecipe(itemLink) then
			if argTable and not argTable.furniture then cllD("Doesn't fit arguments", 2) return false end
			neededOnMain = CS.IsBlueprintNeeded(itemLink)
		else
			if argTable and not argTable.recipes then cllD("Doesn't fit arguments", 2) return false end
			neededOnMain = CS.IsRecipeNeeded(itemLink)
		end
		return true, IsItemLinkRecipeKnown(itemLink), "", true
	end	
}
		
local function learnItems(slotList, linksToLearn, priceSumText)
	cllD(slotList)
	local function learnNext()
		for indexLink, slotIndex in pairs(slotList) do
			local myLink = GetItemLink(BAG_BACKPACK, slotIndex, 1)
			local slotStack = GetSlotStackSize(BAG_BACKPACK, slotIndex)
			cllD(string.format("Trying to find: %s and comparing to %s", indexLink, myLink))
			if indexLink == myLink and linksToLearn[myLink] then
				cllPost(string.format(GS(CLL_AutoLearn), myLink))
				if IsProtectedFunction("UseItem") then
					CallSecureProtected("UseItem", BAG_BACKPACK, slotIndex)
				else
					UseItem(BAG_BACKPACK, slotIndex)
				end
				local myTries = 1
				local function checkLearned(myTries)
					myTries = myTries + 1
					zo_callLater(function()
						if GetItemLink(BAG_BACKPACK, slotIndex, 1) == myLink and GetSlotStackSize(BAG_BACKPACK, slotIndex) == slotStack then
							if myTries < 20 then 
								checkLearned(myTries) 
							else
								cllPost(string.format(GS(CLL_FailedToLearn), myLink))
							end
						else
							slotList[myLink] = nil
							linksToLearn[myLink] = nil
							CarosLootList.sV.autoLearnCount =CarosLootList.sV.autoLearnCount + 1
							learnNext()
						end
					end, 50)
				end
				checkLearned(myTries)
				return
			end	
		end
		cllPost(GS(CLL_NoItemsLeft))
		if priceSumText then cllPost(priceSumText) end
	end			
	learnNext()
end

function CarosLootList.learnAllInInv(useMaxPrice)
	local maxPrice = useMaxPrice and (CarosLootList.sV.recipePriceFilterChars[GetCurrentCharacterId()] or CarosLootList.sV.recipePriceFilter) or false
	local linksToLearn, slotList  = {}, {}
	for slotIndex = 0, GetBagSize(BAG_BACKPACK) do
		local checksPrice = not maxPrice
		local itemLink = GetItemLink(BAG_BACKPACK, slotIndex, 1)

		if not linksToLearn[itemLink] then
			local itemType = GetItemLinkItemType(itemLink)
			if craftingItemCheckFunctions[itemType] then
				local fitsFilter, isKnown, _, canLearn = craftingItemCheckFunctions[itemType](itemLink)
				if fitsFilter and canLearn and not isKnown then 
					if not checksPrice then 
						local myPrice = getItemPrice(itemLink)
						if myPrice and myPrice <= maxPrice then checksPrice = true end
					end
					if checksPrice then
						linksToLearn[itemLink] = true
						slotList[itemLink] = slotIndex
					end
					
				end
			end
		end
	end
	learnItems(slotList, linksToLearn)
end

function CarosLootList.retrieveAndLearnFromGuildBank()
	if not IsGuildBankOpen() then cllD("Guild bank closed") return end
	local guildId = GetSelectedGuildBankId()
    if not DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_BANK_DEPOSIT) then cllD("Guild does not have bank privilege") return end
    if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_BANK_DEPOSIT) or not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_BANK_WITHDRAW) then cllD("You don't have permissions to withdraw and deposit.") return end	

	local itemsTransfered = {}
	local inventorySlotsUsed = {}
	local priceSum = 0
	local maxPrice = CarosLootList.sV.recipePriceFilterGuildBank
	local putBackItem, putBackNumber = false, false
	local freeBackbackSlots = GetNumBagFreeSlots(BAG_BACKPACK)
	if not maxPrice or maxPrice == 0 then cllD("No max price") return end
	cllD("Max price: "..maxPrice)
	local function endGuildBankTransfer(wasError)
		local priceSumText = priceSum > 0 and string.format("%s |t24:24:esoui/art/loot/icon_goldcoin_pressed.dds|t %s (%s)", GS(SI_TRADING_HOUSE_POSTING_PRICE_TOTAL), ZO_FastFormatDecimalNumber(ZO_LocalizeDecimalNumber((math.floor(priceSum * 100 + 0.5) / 100))), GetGuildName(guildId))
		
		EVENT_MANAGER:UnregisterForEvent("CLL_GuildBankFailed", EVENT_GUILD_BANK_TRANSFER_ERROR)
		EVENT_MANAGER:UnregisterForEvent("CLL_GuildBankItemAdded", EVENT_GUILD_BANK_ITEM_ADDED)
		EVENT_MANAGER:UnregisterForEvent("CLL_GuildBankWithdraw", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		EVENT_MANAGER:UnregisterForEvent("CLL_GuildBankClose", EVENT_CLOSE_GUILD_BANK)
		
		
		if wasError then
			cllPost(GS(SI_PROMPT_TITLE_ERROR))
		else
			EndInteraction(INTERACTION_GUILDBANK)
			zo_callLater(function() learnItems(inventorySlotsUsed, itemsTransfered, priceSumText) end, 100)
		end
		
		if putBackItem then cllPost(string.format(GS(CLL_GuildbankCouldNotDeposit), putBackNumber, putBackItem)) end
		
		if priceSumText then cllPost(priceSumText) end
	end
	
	local function withdrawNext()
		local guildBankSlotId = GetNextGuildBankSlotId()
		if not IsGuildBankOpen() or GetSelectedGuildBankId() ~= guildId then endGuildBankTransfer(true) return end
		while guildBankSlotId do
			if freeBackbackSlots < 2 or GetNumBagFreeSlots(BAG_BACKPACK) < 2 then cllPost(GS(CLL_InventorySpace)) break end
			local itemLink = GetItemLink(BAG_GUILDBANK, guildBankSlotId, 1)
			if itemLink and itemLink ~= "" and not itemsTransfered[itemLink] then 
				local itemType = GetItemLinkItemType(itemLink)
				local fitsFilter, isKnown, canLearn = false, true, false
				if craftingItemCheckFunctions[itemType] then 
					fitsFilter, isKnown, _, canLearn = craftingItemCheckFunctions[itemType](itemLink)
				end
				if fitsFilter and not isKnown and canLearn then 
					cllD("Found item, checking price: "..itemLink)
					local itemPrice = getItemPrice(itemLink)
					if itemPrice and itemPrice <= maxPrice then
						cllPost(string.format(GS(CLL_Retrieve), (GetSlotStackSize(BAG_GUILDBANK, guildBankSlotId)), itemLink))
						itemsTransfered[itemLink] = true
						local instanceId = GetItemInstanceId(BAG_GUILDBANK, guildBankSlotId)
						priceSum = priceSum + itemPrice
						local slotUsedBeforeSplitting = false
						EVENT_MANAGER:RegisterForEvent("CLL_GuildBankWithdraw", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
							function(_, bagId, slotIndex, _, _, _, stackCountChange)
								cllD("Single slot update: bag "..bagId..", slot: "..slotIndex..", change: "..stackCountChange)
								if bagId ~= BAG_BACKPACK then return end
								if stackCountChange < 1 then return end
								-- we need to use the instanceId because for some items the link differs in guild bank (internal level)
								if GetItemInstanceId(bagId, slotIndex) ~= instanceId then cllD("Wrong item id: "..itemLink) return end
								
								if stackCountChange == 1 then 
									local inventoryItemLink = GetItemLink(bagId, slotIndex, 1)
									inventorySlotsUsed[inventoryItemLink] = slotIndex
									itemsTransfered[inventoryItemLink] = true
									EVENT_MANAGER:UnregisterForEvent("CLL_GuildBankWithdraw", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
									if slotUsedBeforeSplitting then
										cllD("Stack was split, trying to move the rest back")
										if GetItemLink(BAG_BACKPACK, slotUsedBeforeSplitting, 1) == inventoryItemLink then
											EVENT_MANAGER:RegisterForEvent("CLL_GuildBankItemAdded", EVENT_GUILD_BANK_ITEM_ADDED,
												function(_, addedGuildBankSlotId)
													if GetItemInstanceId(BAG_GUILDBANK, addedGuildBankSlotId) == instanceId then
														cllD("Successfully put the rest of the "..itemLink.." back into guild bank.")
														putBackItem = false
														putBackNumber = false
														-- this is the other position to do the next one...
														withdrawNext()
														EVENT_MANAGER:UnregisterForEvent("CLL_GuildBankItemAdded", EVENT_GUILD_BANK_ITEM_ADDED)
													else
														cllD("Item added to guild bank, but wrong instance id: "..GetItemLink(BAG_GUILDBANK, addedGuildBankSlotId, 1))
														
													end
												end)
											putBackNumber = GetSlotStackSize(BAG_BACKPACK, slotUsedBeforeSplitting)
											putBackItem = inventoryItemLink
											cllPost(string.format(GS(CLL_Deposit), putBackNumber, inventoryItemLink))	
											TransferToGuildBank(BAG_BACKPACK, slotUsedBeforeSplitting)
										else
											cllD("Error: split item seems to have moved inside inventory")
										end
									else
										cllD("Everything in order - this is the time to do the next one...")
										-- this is one position to do the next one...
										freeBackbackSlots = freeBackbackSlots - 1
										withdrawNext()
									end
								elseif slotIndex ~= slotUsedBeforeSplitting then
									cllD("Stack > 1. Trying to split stack.")
									local destSlot = FindFirstEmptySlotInBag(BAG_BACKPACK)
									if not destSlot then return end
									slotUsedBeforeSplitting = slotIndex									
									if IsProtectedFunction("RequestMoveItem") then
										CallSecureProtected("RequestMoveItem", BAG_BACKPACK, slotIndex, BAG_BACKPACK, destSlot, 1)
									else
										RequestMoveItem(BAG_BACKPACK, slotIndex, BAG_BACKPACK, destSlot, 1)
									end
								end
							end)
						
						TransferFromGuildBank(guildBankSlotId)
						return
					end
				end	
			end
			guildBankSlotId = GetNextGuildBankSlotId(guildBankSlotId)
		end
		cllD("No new guildbank slotIndex was found")
		endGuildBankTransfer()
	end 
	
	EVENT_MANAGER:RegisterForEvent("CLL_GuildBankClose", EVENT_CLOSE_GUILD_BANK, function()
		endGuildBankTransfer()
	end)
	EVENT_MANAGER:RegisterForEvent("CLL_GuildBankFailed", EVENT_GUILD_BANK_TRANSFER_ERROR, function()
		endGuildBankTransfer(true)
	end)
	withdrawNext()
end

local function bindFoundItems(itemsToBind)
	for itemLink, slotIndex in pairs(itemsToBind) do
		if slotIndex and GetItemLink(BAG_BACKPACK, slotIndex, 1) == itemLink then
			if CarosLootList.sV.listBoundItems then cllPost(string.format(GS(CLL_BindItem), itemLink)) end
			BindItem(BAG_BACKPACK, slotIndex)
		end
		itemsToBind[itemLink] = false
	end
end

function CarosLootList.retrieveShoppingMailsAndLearn(tryToLearn, bindItems, boughtItems, soldItems, doHirelings, doBG)
	if SCENE_MANAGER.currentScene:GetName() ~= "mailInbox" then cllD("Not in mail scene") return end
	
	local freeBackbackSlots = GetNumBagFreeSlots(BAG_BACKPACK)
	
	local mailsToRead = {}
	local mailsToDelete = {}
	local itemsToLearn = {}
	local itemsToTake = {}
	local slotList = {}
	local itemsToBind = {}
	local foundSetItems = {}
	local guildStoreName = GS(SI_WINDOW_TITLE_TRADING_HOUSE)
	
	-- /script blubb = "" bla = GetNextMailId() while bla do  local _, _, xyz = GetMailItemInfo(bla) blubb = blubb.."-"..xyz bla = GetNextMailId(bla) end  StartChatInput(blubb)
	-- /script SetCVar("language.2", "de")
	-- /script SetCVar("language.2", "en")
	-- /script SetCVar("language.2", "fr")

	local bgSubjects = {
		["de"] = {
			["So wie es kommt!"] = true,
			["Gerechter Lohn!"] = true,
			["Der Preis eines Champions!"] = true,
		},
		["en"] = {
			["One day at a time!"] = true,
			["Rewards for the Worthy!"] = true,
			["A Champion's Prize!"] = true,
		},
		["fr"] = {
			["À chaque jour suffit sa peine !"] = true,
			["La Récompense des dignes !"] = true,
			["Un prix de champion !"] = true,
		},
	}

	local undauntedSubject = {
		["de"] = "Erstklassige Erkundungsvorräte der Unerschrockenen", 
		["en"] = "Premium Undaunted Exploration Supplies",
		["fr"] = "Fournitures d'exploration des Indomptables Premium",
	}
	
	local guildStoreSubject = {
		["de"] = "Gegenstand gekauft",
		["en"] = "Item Purchased",
		["fr"] = "Objet acheté",
	}
	local guildStoreSoldSubject = {
		["de"] = "Gegenstand verkauft",
		["en"] = "Item Sold",
		["fr"] = "Objet vendu",
	}
	local hirelingNames = {
		["de"] = {
			["Schreinermaterial"] = true,
			["Versorgerzutaten"] = true,
			["Verzauberermaterial"] = true,
			["Schneidermaterial"] = true,
			["Schmiedematerial"] = true,
		},
		["en"] = {
			["Raw Enchanter Materials"] = true ,
			["Raw Clothier Materials"] = true ,
			["Raw Woodworker Materials"] = true ,
			["Raw Provisioner Materials"] = true ,
			["Raw Blacksmith Materials"] = true ,
		},
		["fr"] = {
			["Matériaux bruts de travail du bois"] = true,
			["Matériaux bruts d'enchantement"] = true,
			["Matériaux bruts de couture"] = true,
			["Matériaux bruts de forge"] = true,
			["Matériaux bruts de cuisine"] = true,
		},
	}
	
	local myLang = GetCVar("language.2")
	guildStoreSubject = guildStoreSubject[myLang]
	guildStoreSoldSubject = guildStoreSoldSubject[myLang]
	hirelingNames = hirelingNames[myLang] or {}
	undauntedSubject = undauntedSubject[myLang]
	bgSubjects = bgSubjects[myLang]
	if not guildStoreSubject then cllPost("This function is not supported for the current language. Please contact Irniben via esoui.com") return end
	
	if guildStoreName == "" then cllD("Guild store name is empty string") return end
	
	local moneyInMails = {}
	
	local function unregisterMailEvents()
		for i, v in pairs(moneyInMails) do
			cllPost(string.format("%s: %s |t24:24:esoui/art/loot/icon_goldcoin_pressed.dds|t", i, ZO_FastFormatDecimalNumber(ZO_LocalizeDecimalNumber(v))))
		end
		EVENT_MANAGER:UnregisterForEvent("CLL_MailboxClosed", EVENT_MAIL_CLOSE_MAILBOX)
		EVENT_MANAGER:UnregisterForEvent("CLL_MailDeleted", EVENT_MAIL_REMOVED)
		EVENT_MANAGER:UnregisterForEvent("CLL_MailReadable", EVENT_MAIL_READABLE)
		EVENT_MANAGER:UnregisterForEvent("CLL_MailAttachmentTaken", EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS)
		EVENT_MANAGER:UnregisterForEvent("CLL_MailInvSlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
	end
	
	EVENT_MANAGER:RegisterForEvent("CLL_MailboxClosed", EVENT_MAIL_CLOSE_MAILBOX, function()
		cllD("Mailbox closed...")
		unregisterMailEvents()
		if bindItems then
			bindFoundItems(itemsToBind)
		end
		if tryToLearn then
			learnItems(slotList, itemsToLearn)
		end
	end)
		
	local mailId = GetNextMailId()
	local numberToRead, numberToDelete = 0, 0
		
	while mailId do
		local sName, scName, subject, _, _, fSys, fCusServ, returned, numAttachments, attachedMoney = GetMailItemInfo(mailId)
		if fSys and not fCusServ and (sName == guildStoreName and (soldItems and subject == guildStoreSoldSubject or boughtItems and subject == guildStoreSubject) or hirelingNames[subject] and doHirelings or bgSubjects[subject] and doBG) then
			if numAttachments == 1 and boughtItems and sName == guildStoreName and subject == guildStoreSubject then
				numberToRead = numberToRead + 1
				mailsToRead[mailId] = true
			elseif attachedMoney > 0 and soldItems then
				numberToRead = numberToRead + 1
				mailsToRead[mailId] = true
			elseif numAttachments >= 1 and (hirelingNames[subject] and doHirelings or bgSubjects[subject] and doBG) then
				numberToRead = numberToRead + 1
				mailsToRead[mailId] = true
			elseif numAttachments == 0 and attachedMoney == 0 then
				numberToDelete = numberToDelete + 1
				mailsToDelete[mailId] = true
			end
		end
		mailId = GetNextMailId(mailId)
	end
	
	cllD(string.format("To read: %s, to delete: %s", numberToRead, numberToDelete))
	
	local function readMail(mailId)
		if not mailsToRead[mailId] then return false end
		local sName, _, _, _, _, _, _, _, numAttachments, attachedMoney = GetMailItemInfo(mailId)
		
		if freeBackbackSlots < numAttachments then
			mailsToRead[mailId] = false
			cllPost(GS(SI_INVENTORY_ERROR_INVENTORY_FULL))
			return true
		end
		if numAttachments == 0 then 
			cllD(string.format("Reading mail containing %s gold", attachedMoney))
			moneyInMails[sName] = (moneyInMails[sName] or 0) + attachedMoney
		else
			cllD("Reading mail containing:")
			for i=1, numAttachments do
				local itemLink = GetAttachedItemLink(mailId, i, 1)
				local _, stack = GetAttachedItemInfo(mailId, i)
				cllD(string.format("--- %s x %s", stack, itemLink))
				itemsToTake[itemLink] = itemsToTake[itemLink] or {}
				table.insert(itemsToTake[itemLink], stack)
			end
		end
		mailsToRead[mailId] = false
		mailsToDelete[mailId] = true
		freeBackbackSlots = freeBackbackSlots - numAttachments
		ZO_MailInboxShared_TakeAll(mailId)
	end
	
	local function deleteNext()
		for mailId, stillToDelete in pairs(mailsToDelete) do
			if stillToDelete then
				cllD("Deleting next mail")
				DeleteMail(mailId, true)
				mailsToDelete[mailId] = false
				return
			end
		end
		cllD("Nothing more to delete, returning to base scene to try and learn the motifs etc.")
		if tryToLearn or bindItems then
			SCENE_MANAGER:ShowBaseScene()
		else
			unregisterMailEvents()
		end
	end
	
	local function readNext()
		for mailId, stillToRead in pairs(mailsToRead) do
			if stillToRead then
				cllD("Request to read: "..mailId)
				RequestReadMail(mailId)
				return
			end
		end
		-- no mails left:
		cllD("No more mails to read - start deleting empty ones.")
		EVENT_MANAGER:RegisterForEvent("CLL_MailDeleted", EVENT_MAIL_REMOVED, deleteNext)
		deleteNext()
	end
	
	EVENT_MANAGER:RegisterForEvent("CLL_MailInvSlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 
		function(_, eBagId, eSlotIndex, eNew, _, eReason, eStackChange) 
			cllD("Slot update, checking if new...")
			if not eNew then return end
			local itemLink = GetItemLink(eBagId, eSlotIndex, 1)
			cllD("New item:"..itemLink)
			if eBagId == BAG_VIRTUAL then
				cllD("Craftbag...")
				itemLink = false
				for mailItem, stacksToTake in pairs(itemsToTake) do
					if GetItemLinkItemId(mailItem) == eSlotIndex then itemLink = mailItem break end
				end
				if not itemLink then cllD("Craftbag item not an attachment.") return end
			end
			local stackTaken = false
			local anyStackInList = false
			for i, v in pairs(itemsToTake[itemLink]) do
				anyStackInList = true
				if v == eStackChange then
					stackTaken = true
					itemsToTake[itemLink][i] = nil
					break
				end
			end
			if not anyStackInList then return end
			if not stackTaken then 
				cllD(string.format("Stacksize %s doesn't match attachement stack %s", eStackChange, itemsToTake[itemLink][1]))
				return 
			end
			cllD(string.format("%sx %s", eStackChange, itemLink))
			local itemType = GetItemLinkItemType(itemLink)
			cllD(string.format("ItemType: %s", itemType))
			if craftingItemCheckFunctions[itemType] then
				cllD("Checking if still needed...")
				local fitsFilter, isKnown, neededOnMain, canLearn = craftingItemCheckFunctions[itemType](itemLink)
				if fitsFilter and not isKnown and canLearn then
					cllD("Adding to learn list...")
					itemsToLearn[itemLink] = true
					slotList[itemLink] = eSlotIndex
				end
			elseif IsItemLinkSetCollectionPiece(itemLink) and not IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink)) then
				local hasSet, setName = GetItemLinkSetInfo(itemLink) 
				setName = ZO_CachedStrFormat("<<C:1>>", setName)
				local mySetPiece = GetItemLinkEquipType(itemLink)
				local myWeaponType = GetItemLinkWeaponType(itemLink)
				if myWeaponType ~= WEAPONTYPE_NONE then mySetPiece = myWeaponType + 42 end
				foundSetItems[setName] = foundSetItems[setName] or {}
				if not foundSetItems[setName][mySetPiece] then
					itemsToBind[itemLink] = eSlotIndex
					foundSetItems[setName][mySetPiece] = true
				end
			end
		end)
		
	EVENT_MANAGER:RegisterForEvent("CLL_MailAttachmentTaken", EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, readNext)
	EVENT_MANAGER:RegisterForEvent("CLL_MailAttachmentTaken", EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS, readNext)
	EVENT_MANAGER:RegisterForEvent("CLL_MailReadable", EVENT_MAIL_READABLE, function(_, mailId) cllD("Readable: "..mailId) if readMail(mailId) then readNext() end end) -- will return true for errors
	
	readNext()
end

function CarosLootList.transferCustom(argTable)

	local maxPrice = argTable.pul
	local minPrice = argTable.pll
	local maxCost = argTable.cul
	local minCost = argTable.cll
	if maxPrice == 0 then maxPrice = nil end
	if minPrice == 0 then minPrice = nil end
	if maxCost == 0 then maxCost = nil end
	if minCost == 0 then minCost = nil end
	maxPrice = argTable.filterForPriceLowerThan and maxPrice or nil
	local itemsDone = {}
	local itemsToLearn = {}
		
	local function checkItem(bagId, slotIndex)
		local myLink = GetItemLink(bagId, slotIndex, 1)
		--local _, stackSize = GetItemInfo(bagId, slotIndex)
		
		if argTable.oneCopyOnly and itemsDone[myLink] then return false end
		if argTable.filterForPriceHigherThan or argTable.filterForPriceLowerThan then
			local myPrice = getItemPrice(myLink)
			if not myPrice then return false end
			if argTable.filterForPriceHigherThan and (not minPrice or myPrice <= minPrice) then return false end
			if argTable.filterForPriceLowerThan and (not maxPrice or myPrice >= maxPrice) then return false end
		end
		local itemType, specializedItemType = GetItemLinkItemType(myLink)
		local neededOnMain = ""
		local stackSize = GetSlotStackSize(bagId, slotIndex)
		stackSize = argTable.oneCopyOnly and 1 or stackSize
		
		if craftingItemCheckFunctions[itemType] then 
			
			local fitsFilter, isKnown, neededOnMain, canLearn = craftingItemCheckFunctions[itemType](myLink, argTable)
			
			if not fitsFilter then return false end
			
			if neededOnMain ~= "" and filterForMain then return false end
			
			if isKnown and argTable.known  then return myLink, stackSize end
			
			if not isKnown and argTable.unknown and canLearn then 				
				if argTable.autoLearn then itemsToLearn[myLink] = true end
				return myLink, stackSize 
			end
			
		elseif itemType == ITEMTYPE_MASTER_WRIT then
			if not argTable.writs then return false end
			if not argTable.filterForCostHigherThan and not argTable.filterForCostLowerThan and argTable.known and argTable.unknown then return myLink, stackSize end
			if not WritWorthy then return false end
			local mat_list, know_list = WritWorthy.ToMatKnowList(myLink)
			if mat_list and #mat_list > 0 and CarosLootList.sV.writLimit then
				local canDo = true
				for i, v in pairs(know_list) do
					canDo = v.is_known and canDo or false
				end
				if canDo and not argTable.known then return false end
				if not canDo and not argTable.unknown then return false end
				
				local vouchers = WritWorthy.ToVoucherCount(myLink)
				local matPrice = 0
				for _, matData in pairs(mat_list) do
					if not matData.mm then 
						cllPost(string.format(GS(CLL_NoPriceDataFor, myLink)))
						return false 
					end
					matPrice = matPrice + matData.ct * matData.mm
				end
				if argTable.filterForCostHigherThan and (not minCost or matPrice/vouchers <= minCost) then return false end
				if argTable.filterForCostLowerThan and (not maxCost or matPrice/vouchers >= maxCost) then return false end	
				return myLink, stackSize 
			end				
		end			
		return false
	end
	
	
	
	if argTable.retr then
		CarosLootList.retrieveFromBank(
			checkItem, --checkFunction, 
			checkItem, -- preCheckFunction,
			true, -- postTransferStatus, 
			function(bagId, slotIndex, myLink) if myLink then itemsDone[myLink] = slotIndex end end, -- onItemTransfer, 
			false, -- onItemFail, 
			function() -- onTransferComplete, 
				if argTable.autoLearn then
					EndInteraction(INTERACTION_BANK)
					zo_callLater(function() learnItems(itemsDone, itemsToLearn) end, 100)
				end	
			end, 
			function() itemsDone = {} end --callAfterPrecheck)
		)
	else
		CarosLootList.depositToBank(
			checkItem, --checkFunction, 
			checkItem, -- preCheckFunction,
			true, -- postTransferStatus, 
			function(bagId, slotIndex, myLink) if myLink then itemsDone[myLink] = slotIndex end end, -- onItemTransfer, 
			false, -- onItemFail, 
			function() end, -- onTransferComplete, 
			function() itemsDone = {} end --callAfterPrecheck)
		)
	end
end


function CarosLootList.getSetsInBag(theBag)
	local allSets = {}
	local myBags = {theBag}
	if theBag == BAG_BANK then table.insert(myBags, BAG_SUBSCRIBER_BANK) end
	local setsSorted = {}
	for _, bagId in pairs(myBags) do
		for slotIndex=0, GetBagSize(bagId) do
			local myLink = GetItemLink(bagId, slotIndex, 1)
			local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(myLink) 
			if hasSet and setId then 
				local formattedSetName = ZO_CachedStrFormat("<<C:1>>", setName)
				if not allSets[formattedSetName] then
					allSets[formattedSetName] = tonumber(setId)
					table.insert(setsSorted, formattedSetName)
				end
			end
		end
	end
	table.sort(setsSorted)
	return allSets, setsSorted
end


function CarosLootList.transferSet(setTable, retrieve)
	local function checkSet(bagId, slotIndex)
		local myLink = GetItemLink(bagId, slotIndex, 1)
		local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(myLink) 
		if setId and setTable[tonumber(setId)] then return myLink else return false end
	end
	
	if retrieve then 
		CarosLootList.retrieveFromBank(checkSet, nil, true)
	else
		CarosLootList.depositToBank(checkSet, nil, true)
	end
end




local function cllSetupListDiag()

	local function cllSetupItemRow(rowControl, slotInfo)
		GetControl(rowControl, "Name"):SetText(zo_strformat(SI_TOOLTIP_ITEM_NAME, slotInfo.name))
		GetControl(rowControl, "Icon"):SetTexture(slotInfo.icon)
		GetControl(rowControl, "Selected"):SetHidden(not slotInfo.selectForTransfer)
		rowControl:SetMouseEnabled(true)
		
		rowControl:SetHandler("OnMouseUp", function() 
			--d(slotInfo) 
			slotInfo.selectForTransfer = not slotInfo.selectForTransfer
			ZO_ScrollList_RefreshVisible(cllSLDiag.list)
		end)
		
	end
	--cllSLDiag:SetBelowText(text)

	cllSLDiag = ZO_ListDialog:New("CarosLootList_ListDiagItemRow", 42, cllSetupItemRow) 
	cllSLDiag.list.selectionCallback = false 
	cllSLDiag.list.selectionTemplate = false
	cllSLDiag:SetFirstButtonEnabled(true)
	cllSLDiag:SetEmptyListText(GS(CLL_NoItems))
	local clDiagCtr = cllSLDiag:GetControl()
	GetControl(clDiagCtr, "Divider"):SetHidden(true)
	
	GetControl(clDiagCtr, "TopCustomControlContainer"):SetAnchor(TOPLEFT, GetControl(clDiagCtr, "Title"), BOTTOMLEFT)

	GetControl(clDiagCtr, "List"):SetHeight(420)

	clDiagCtr:SetResizeToFitPadding(0, 48)
	cllSLDiag.maxVisibleItems = 10
	
	CarosLootList.cllSLDiag = cllSLDiag
	ZO_ScrollList_EnableHighlight(cllSLDiag.list, "ZO_ThinListHighlight")
	
	local retrieve = false
	local callbackFunction = function() end
	
	ZO_Dialogs_RegisterCustomDialog("CLL_LIST_DIAG",
	{
		customControl = cllSLDiag:GetControl(),
		setup = function(dialog, data)
			retrieve = data.retrieve
			callbackFunction = data.callbackFunction
			if data.retrieve then 
				cllSLDiag.firstButton:SetText(GS(SI_ITEM_ACTION_BANK_WITHDRAW))
				--cllSLDiag:SetAboveText(GS(SI_ITEM_ACTION_BANK_WITHDRAW))
			else
				cllSLDiag.firstButton:SetText(GS(SI_ITEM_ACTION_BANK_DEPOSIT))
				--cllSLDiag:SetAboveText(GS(SI_ITEM_ACTION_BANK_DEPOSIT))
			end
			
			data.setupFunction(data)
			
		end,

		title =
			{
				text = "|c9e0911Caro's Loot List|r",
			},        
			
		buttons =
			{
				{
					control = cllSLDiag:GetButton(1),
					clickSound = SOUNDS.SMITHING_START_RESEARCH,
					callback = function() 
						local scrollData = ZO_ScrollList_GetDataList(cllSLDiag.list)
						callbackFunction(scrollData)
					end,
					text = SI_ITEM_ACTION_BANK_WITHDRAW, 
				},

				{
					control = cllSLDiag:GetButton(2),
					text = SI_DIALOG_CANCEL,
				}
			}
	})
		
end

function CarosLootList.OnTransferDialogHide(control)
	
end

local customTransferSettings = {}
local filterButtons = {}
CarosLootList.filterButtons = filterButtons

function CarosLootList.setCustomTransferSetting(setting, value)
	local enabledWhenOneIsTrue = {
		[{"recipes", "furniture", "motifs", "style"}] = {"autoLearn"},
		[{"recipes", "furniture", "motifs"}] = {"filterForMain"},
		[{"writs"}] = {"filterForCostLowerThan", "filterForCostHigherThan"},
	}
	local disableWhenNotOneIsTrue = {
		[{"unknown"}] = {"autoLearn"},
		
	}
	
	if setting then customTransferSettings[setting] = value end
	
	for conditionArray, targetArray in pairs(enabledWhenOneIsTrue) do
		local active = false
		for _, condition in pairs(conditionArray) do
			if customTransferSettings[condition] then active = true end
		end
		for _, target in pairs(targetArray) do
			filterButtons[target]:SetHidden(not active)
			if not active then customTransferSettings[target] = false end
		end
	end
	for conditionArray, targetArray in pairs(disableWhenNotOneIsTrue) do
		local active = false
		for _, condition in pairs(conditionArray) do
			if customTransferSettings[condition] then active = true end
		end
		if not active then		
			for _, target in pairs(targetArray) do
				filterButtons[target]:SetHidden(true)
				customTransferSettings[target] = false
			end
		end
	end
end

function CarosLootList.setCustomBankingNumber(setting, value)
	customTransferSettings[setting] = value
end

function CarosLootList.initFilterButton(control, setting)
	local labelTexts = {
		["recipes"] = string.format("|t32:32:esoui/art/icons/quest_scroll_001.dds|t %s", GS(SI_ITEMTYPEDISPLAYCATEGORY21)),
		["furniture"] = string.format("|t32:32:esoui/art/icons/crafting_planfurniture_blacksmithing3.dds|t %s", GS(SI_RECIPECRAFTINGSYSTEM6)),
		["motifs"] = string.format("|t32:32:esoui/art/icons/quest_letter_002.dds|t %s", GS(SI_ITEMTYPEDISPLAYCATEGORY24)),
		["style"] = string.format("|t32:32:esoui/art/icons/quest_summerset_completed_report.dds|t %s", GS(SI_COLLECTIBLECATEGORYTYPE24)),
		["writs"] = string.format("|t32:32:esoui/art/icons/master_writ_woodworking.dds|t %s", GS(SI_ITEMTYPEDISPLAYCATEGORY25)),
		["known"] = GS(CLL_CustBank_Known),
		["unknown"] = GS(CLL_CustBank_Unknown),
		["filterForMain"] = GS(CLL_CustBank_FilterForMain),
		["autoLearn"] = GS(CLL_CustBank_AutoLearn),
		["filterForPriceLowerThan"] = GS(CLL_CustBank_FilterForPriceLower),
		["filterForPriceHigherThan"] = GS(CLL_CustBank_FilterForPriceHigher),
		["filterForCostLowerThan"] = GS(CLL_CustBank_FilterForCostLower),
		["filterForCostHigherThan"] = GS(CLL_CustBank_FilterForCostHigher),
		["oneCopyOnly"] = GS(CLL_CustBank_OneCopyOnly),
	}
	
	local tooltips = {
		["filterForMain"] = GS(CLL_CustBank_FilterForMainTT),
		["filterForCostLowerThan"] = GS(CLL_CustBank_FilterForCostTT),
		["filterForCostHigherThan"] = GS(CLL_CustBank_FilterForCostTT),
	}
	
	ZO_CheckButton_SetLabelText(control, labelTexts[setting])
	if tooltips[setting] then ZO_CheckButton_SetTooltipText(control, tooltips[setting]) end
	control.mySetting = setting
	filterButtons[setting] = control
	ZO_CheckButton_SetToggleFunction(control, function(_, value) CarosLootList.setCustomTransferSetting(setting, value) end)
end
								
function CarosLootList.showCustomDiag(retrieve, shiftDown, ctrlDown)
	CarosLootList.setCustomTransferSetting()
	ZO_Dialogs_RegisterCustomDialog("CLL_TRANSFER_DIAG",
	{
		customControl = CarosLootList_TransferDiag,
		setup = function(dialog, data)
						
		end,

		title =
			{
				text = "|c9e0911Caro's Loot List|r",
			},        
			
		buttons =
			{
				{
					control = CarosLootList_TransferDiagButton1,
					clickSound = SOUNDS.SMITHING_START_RESEARCH,
					callback = function() 
						local myArgs = {retrieve and "retr" or "depo"}
						local conditions = {
							filterForCostHigherThan = "cll", 
							filterForCostLowerThan = "cul", 
							filterForPriceHigherThan = "pll", 
							filterForPriceLowerThan = "pul",
						}
						for i, v in pairs(conditions) do
							if customTransferSettings[i] and not customTransferSettings[v] then customTransferSettings[i] = nil end
						end
						for i, v in pairs(customTransferSettings) do
							if v and (i == "cul" or i == "cll" or i == "pul" or i == "pll") then
								table.insert(myArgs, string.format("%s:%s", i, v))
							elseif v then
								table.insert(myArgs, i)
							end
						end
						local myId = table.concat(myArgs, "///")
						cllD(myId)
						CarosLootList.runFunctionAndSaveAsLast(myId, "bank", myArgs, shiftDown, ctrlDown)
					end,
					text = retrieve and SI_ITEM_ACTION_BANK_WITHDRAW or SI_ITEM_ACTION_BANK_DEPOSIT, 
				},

				{
					control = CarosLootList_TransferDiagButton2,
					text = SI_DIALOG_CANCEL,
				}
			}
	})

	ZO_Dialogs_ShowDialog("CLL_TRANSFER_DIAG", {})
	
end

function CarosLootList.showSetListDiag(bagId, retrieve)
	if not cllSLDiag then cllSetupListDiag() end
	ZO_Dialogs_ShowDialog("CLL_LIST_DIAG", {
		bagId = bagId, 
		retrieve = retrieve,
		setupFunction = function(data)
			local allSets, setsSorted = CarosLootList.getSetsInBag(data.bagId)
			for i, v in pairs(setsSorted) do
				
				local setId = allSets[v]
				local setType = GetItemSetType(setId)
				
				local icon = "esoui/art/crafting/smithing_tabicon_armorset_up.dds" -- ITEM_SET_TYPE_CRAFTED
				if setType ~= ITEM_SET_TYPE_CRAFTED then
					if setType == ITEM_SET_TYPE_MONSTER or setType == ITEM_SET_TYPE_WEAPON or GetNumItemSetCollectionPieces(setId) == 1 then
						icon = GetItemLinkInfo(GetItemSetCollectionPieceItemLink(GetItemSetCollectionPieceInfo(setId, 1)))
					else
						icon = GetItemLinkInfo(GetItemSetCollectionPieceItemLink(GetItemSetCollectionPieceInfo(setId, 3)))
					end
				end
				cllSLDiag:AddListItem({name = v, setId = setId, icon = icon})
			end
			cllSLDiag:CommitList()
		end,
		callbackFunction = function(scrollData)
			local selectedSets = {}
			for i, v in pairs(scrollData) do
				if v.data.selectForTransfer then selectedSets[v.data.setId] = true end
			end
			CarosLootList.transferSet(selectedSets, retrieve)
		end,
		})	
end


-- CarosLootList.retrieveFromBank(checkFunction, preCheckFunction, postTransferStatus, onItemTransfer, onItemFail, onTransferComplete, callAfterPrecheck)
-- function CarosLootList.depositToBank(checkFunction, preCheckFunction, postTransferStatus, onItemTransfer, onItemFail, onTransferComplete, callAfterPrecheck)