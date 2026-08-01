local GS = GetString
local cpcD = CarosPreCrafter.cpcD
local getResearchLineFromItemLink = CarosPreCrafter.getResearchLineFromItemLink
local thisCharId = CarosPreCrafter.thisCharId

function CarosPreCrafter.ShowBankBtn2TT(control)
	InitializeTooltip(InformationTooltip, control, LEFT)
	InformationTooltip:AddLine(GS(CPC_Bank_Deposit), "ZoFontWinH2")
	if CarosPreCrafter.isOnMainCrafter then CarosPreCrafter.checkResearchItemsOnMainCrafter() end
	if CarosPreCrafter.hasCraftedWritItemsToDeposit then 
		ZO_Tooltip_AddDivider(InformationTooltip)
		InformationTooltip:AddLine(GS(CPC_Bank_PrecraftedWritInfo), "ZoFontGame")
	end
	if CarosPreCrafter.researchDeposit and #CarosPreCrafter.researchDeposit > 0 then 
		ZO_Tooltip_AddDivider(InformationTooltip)
		InformationTooltip:AddLine(string.format(GS(CPC_Bank_PreCraftedResearch), #CarosPreCrafter.researchDeposit), "ZoFontGame")
	end
end

function CarosPreCrafter.ShowBankBtn1TT(control)
	local svChars = CarosPreCrafter.sV.researchChars
	local charItemCounter = {}
	local thisCharItems = false
	for charId, charData in pairs(svChars) do
		if (charData.active or charData.doJewelry or charData.doNirn) and charData.items then
			local singleCharItemNumber = 0
			for itemKey, itemData in pairs(charData.items) do
				if itemData.location == 42 then singleCharItemNumber = singleCharItemNumber + 1 end
			end
			if singleCharItemNumber > 0 then
				if charId == CarosPreCrafter.thisCharId then
					thisCharItems = string.format("|c9e0911%s:|r %s", charData.name, singleCharItemNumber)
				else
					table.insert(charItemCounter, string.format("|c9e0911%s:|r %s", charData.name, singleCharItemNumber))
				end
			end
		end
	end
	if not thisCharItems then thisCharItems = GS(CPC_Bank_NotForCurrent) end
	InitializeTooltip(InformationTooltip, control, LEFT)
	InformationTooltip:AddLine(GS(CPC_Bank_Retrieve), "ZoFontWinH2")
	ZO_Tooltip_AddDivider(InformationTooltip)
	InformationTooltip:AddLine(thisCharItems, "ZoFontGame")
	ZO_Tooltip_AddDivider(InformationTooltip)
	InformationTooltip:AddLine(table.concat(charItemCounter, "\n"), "ZoFontGame")
end



function CarosPreCrafter.depositWritItems(depositingResearch)
	if depositingResearch then
		d(GS(CPC_Bank_DepositingResearch))
	else
		d(GS(CPC_Bank_DepositingWrit))
	end
	local itemLinkList = {}
	local potionOptions, poisonOptions, alchemyAlternatives, writPotion, writPotion1, writPoison, writFood, writFoodLev1AD, writFoodLev1DC, writFoodLev1EP = CarosPreCrafter.getAlchProvTables()
	local strIL, craftedLink, craftedLink1, alchemyStringMaxLevel, alchemyStringLevel1, otherLink, otherLink1 = CarosPreCrafter.getItemLinkStrings()
	
	if not depositingResearch then
		local function iterateWritAlternatives(levelBasedAlchemyString, theTable)
			for i, v in pairs(theTable) do
				for j, w in pairs(alchemyAlternatives[i]) do
					itemLinkList[string.format(levelBasedAlchemyString, i, w)] = true
				end
			end
		end
		
		if CarosPreCrafter.sV.desiredPois > 0 then iterateWritAlternatives(alchemyStringMaxLevel, writPoison) end	
		if CarosPreCrafter.sV.desiredPot > 0 then iterateWritAlternatives(alchemyStringMaxLevel, writPotion) end	
		if CarosPreCrafter.sV.desiredPot1 > 0 then	iterateWritAlternatives(alchemyStringLevel1, writPotion1) end
			
		if CarosPreCrafter.sV.desiredProv > 0 then		
			for i, v in pairs(writFood) do
				itemLinkList[string.format( craftedLink, i)] = true
			end
		end	
		if CarosPreCrafter.sV.desiredProv1ad > 0 then		
			for i, v in pairs(writFoodLev1AD) do
				itemLinkList[string.format( craftedLink1, i, v[2])] = true
			end
		end	
		if CarosPreCrafter.sV.desiredProv1dc > 0 then 		
			for i, v in pairs(writFoodLev1DC) do
				itemLinkList[string.format( craftedLink1, i, v[2])] = true
			end
		end	
		if CarosPreCrafter.sV.desiredProv1ep > 0 then
			for i, v in pairs(writFoodLev1EP) do
				itemLinkList[string.format( craftedLink1, i, v[2])] = true
			end
		end
		CarosPreCrafter.itemLinkList = itemLinkList
	end	
	local myPosition = 1
	local myCount = 0
	
	local function getFreeSlot()
		local bankId = BAG_BANK
		local slotId = FindFirstEmptySlotInBag(bankId)
		if not slotId then
			bankId = BAG_SUBSCRIBER_BANK
			slotId = FindFirstEmptySlotInBag(bankId)
		end
		if not slotId then bankId = nil end
		return bankId, slotId
	end
	
	local function depositItem(sourceSlot)
		local destBag, destSlot = getFreeSlot()
		if not destBag or not destSlot then return false end
		local stackCount = GetSlotStackSize(BAG_BACKPACK, sourceSlot)
		if IsProtectedFunction("RequestMoveItem") then
			CallSecureProtected("RequestMoveItem", BAG_BACKPACK, sourceSlot, destBag, destSlot, stackCount)
		else
			RequestMoveItem(BAG_BACKPACK, sourceSlot, destBag, destSlot, stackCount)
		end
		return true
	end
	
	if not depositingResearch then
		for slotId=0, GetBagSize(BAG_BACKPACK) do
			local myLink = GetItemLink(BAG_BACKPACK, slotId, 1)
			if myLink and itemLinkList[myLink] then
				myCount = myCount + 1
			end
		end	
	else
		myCount = #CarosPreCrafter.researchDeposit
	end
	
	local  function depositNext()
		for slotId=0, GetBagSize(BAG_BACKPACK) do
			local myLink = GetItemLink(BAG_BACKPACK, slotId, 1)
			local doDeposit = false
			if myLink and itemLinkList[myLink] then
				doDeposit = true
			elseif myLink and depositingResearch then
				if IsItemLinkCrafted(myLink) and GetItemLinkQuality(myLink) == ITEM_QUALITY_NORMAL and GetItemLinkRequiredLevel(myLink) == 1 and not IsItemPlayerLocked(BAG_BACKPACK, slotId) then
					local craft, lineIndex, traitIndex = getResearchLineFromItemLink(myLink)
					for itemIndex, itemData in pairs(CarosPreCrafter.researchDeposit) do
						if itemData[1] == craft and itemData[2] == lineIndex and itemData[3] == traitIndex then
							doDeposit = itemIndex
							break
						end
					end
				end
			end
			if doDeposit then	
				d(string.format(GS(CPC_Bank_Position), myPosition, myCount, myLink))
				myPosition = myPosition + 1
				if not depositItem(slotId) then 
					d(GS(CPC_Bank_Full))
					return 
				else
					local myTries = 1
					local function checkSlot(myTries)
						myTries = myTries + 1
						zo_callLater(function()
							if GetItemId(BAG_BACKPACK, slotId) ~= 0 then
								if myTries < 20 and GetInteractionType() == INTERACTION_BANK then 
									checkSlot(myTries) 
								else
									d(GS(CPC_Bank_Fail))
								end
							else
								if type(doDeposit) == "number" then 
									local theDepositedItem = CarosPreCrafter.researchDeposit[doDeposit]
									local charId, itemKey = theDepositedItem[4], theDepositedItem[5]
									cpcD("Depositing Item "..itemKey)
									local charData = charId and CarosPreCrafter.sV.researchChars[charId]
									if charData and charData.items and charData.items[itemKey] then
										charData.items[itemKey].location = 42
									end
									table.remove(CarosPreCrafter.researchDeposit, doDeposit)
									cpcD(string.format("Removed %s from the depositList", doDeposit))
								end
								depositNext()
							end
						end, 50)
					end
					checkSlot(myTries)
					return
				end
			end	
		end
		
		-- If the iterator got through the whole bag without finding anything:
		if depositingResearch then 
			CarosPreCrafter.hasCraftedWritItemsToDeposit = false 
			CarosPreCrafter.onBankInteraction()
		elseif CarosPreCrafter.mayPrecraftResearchItems then 
			-- deposit research items
			CarosPreCrafter.depositWritItems(true) 
		else 
			-- retrieve research items
			cpcD(CarosPreCrafter.researchDeposit)  
			CarosPreCrafter.checkRetrieveResearchItems()
			CarosPreCrafter.retrieveResearchItems() 
		end
	end
	depositNext()
end

function CarosPreCrafter.retrieveResearchItems()
	if CarosPreCrafter.isOnMainCrafter then return end
	d(GS(CPC_Bank_RetrievingResearch))

	local function retrieveItem(sourceBag, sourceSlot)
		local destSlot =  FindFirstEmptySlotInBag(BAG_BACKPACK)
		if not destSlot then return false end
		if IsProtectedFunction("RequestMoveItem") then
			CallSecureProtected("RequestMoveItem", sourceBag, sourceSlot, BAG_BACKPACK, destSlot, 1)
		else
			RequestMoveItem(sourceBag, sourceSlot, BAG_BACKPACK, destSlot, 1)
		end
		return true
	end
	
	local myPosition = 1
	local myCount = #CarosPreCrafter.researchRetrieve
	local bagId = BAG_BANK
	
	cpcD(#CarosPreCrafter.researchRetrieve)
	cpcD(CarosPreCrafter.researchRetrieve)
	
	local  function retrieveNext()
		for slotId=0, GetBagSize(bagId) do
			local myLink = GetItemLink(bagId, slotId, 1)
			local doRetrieve = false
			if IsItemLinkCrafted(myLink) and GetItemLinkQuality(myLink) == ITEM_QUALITY_NORMAL and GetItemLinkRequiredLevel(myLink) == 1 then
				local craft, lineIndex, traitIndex = getResearchLineFromItemLink(myLink)
				for itemIndex, itemData in pairs(CarosPreCrafter.researchRetrieve) do
					if itemData[1] == craft and itemData[2] == lineIndex and itemData[3] == traitIndex then
						doRetrieve = itemIndex
						cpcD(doRetrieve)
						break
					end
				end
			end
			if doRetrieve then	
				d(string.format(GS(CPC_Bank_Position), myPosition, myCount, myLink))
				myPosition = myPosition + 1
				if not retrieveItem(bagId, slotId) then 
					d(GS(CPC_Bank_InventoryFull))
					return 
				else
					local myTries = 1
					local function checkSlot(myTries)
						myTries = myTries + 1
						zo_callLater(function()
							if GetItemId(bagId, slotId) ~= 0 then
								if myTries < 20 and GetInteractionType() == INTERACTION_BANK then 
									checkSlot(myTries) 
								else
									d(GS(CPC_Bank_Fail))
								end
							else
								local theRetrievedItem = CarosPreCrafter.researchRetrieve[doRetrieve]
								local charData = CarosPreCrafter.thisCharId and CarosPreCrafter.sV.researchChars[CarosPreCrafter.thisCharId]
								if charData and charData.items and charData.items[theRetrievedItem[4]] then
									charData.items[theRetrievedItem[4]].location = thisCharId
								end
								table.remove(CarosPreCrafter.researchRetrieve, doRetrieve) 
								retrieveNext()
							end
						end, 50)
					end
					checkSlot(myTries)
					return
				end
			end	
		end
		if bagId == BAG_BANK then 
			cpcD("End of Bank1")
			bagId = BAG_SUBSCRIBER_BANK 
			retrieveNext() 
		else
			cpcD("End of Bank 2")
			CarosPreCrafter.onBankInteraction()
		end
	end
	retrieveNext()
end

function CarosPreCrafter.onBankInteraction()
	if not CarosPreCrafter.sV.showBtnBank then return end
	if CarosPreCrafter.isOnMainCrafter then CarosPreCrafter.checkResearchItemsOnMainCrafter() end
	local showWin = false
	CarosPreCrafter.checkRetrieveResearchItems()
	if #CarosPreCrafter.researchRetrieve > 0 then
		showWin = true
		 CarosPreCrafter.window2.btn1:SetHidden(false)
	else
		 CarosPreCrafter.window2.btn1:SetHidden(true)
	end
	if #CarosPreCrafter.researchDeposit > 0 or CarosPreCrafter.hasCraftedWritItemsToDeposit then
		showWin = true
		 CarosPreCrafter.window2.btn2:SetHidden(false)
	else
		 CarosPreCrafter.window2.btn2:SetHidden(true)
	end
	if showWin then SCENE_MANAGER:GetScene("bank"):AddFragment(CarosPreCrafter.fragment2) else SCENE_MANAGER:GetScene("bank"):RemoveFragment(CarosPreCrafter.fragment2) end
end