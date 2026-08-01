-- ***** Pawprint's PVP Tools - Merchant and Banker *****



--------------------------------------------------
-- Initialize our namespace and variables
--------------------------------------------------
if not PVPTools then PVPTools = {} end
if not PVPTools.MB then PVPTools.MB = {} end
local PT = PVPTools
local MB = PVPTools.MB

local merchantTag = "|c62d27f[M&B] |r" 
--------------------------------------------------
-- Item ID Tables
--------------------------------------------------

MB.Currency = {
	["Gold"]			=	CURT_MONEY,
	["Telvar"]			=	CURT_TELVAR_STONES,
	["Alliance Points"] = 	CURT_ALLIANCE_POINTS,
}

MB.CurrencyIcons = {
	["Gold"]			=	"|t32:32:/esoui/art/icons/housing_gen_inc_coinstack004.dds|t",
	["Telvar"]			=	"|t32:32:/esoui/art/currency/telvar_mipmap.dds|t",
	["Alliance Points"] =	"|t32:32:/esoui/art/currency/alliancepoints_32.dds|t",

}


--[[
function PT.SearchBackpack(searchItemId)
	if PT.debug then PT.DebugEntry("PVPTools.SearchBag") end
	
	local bag = BAG_BACKPACK
	local slot = ZO_GetNextBagSlotIndex(bag)
	
	while slot do
		if GetItemId(bag, slot) == SearchItemId then break end
		slot = ZO_GetNextBagSlotIndex(bag)
	end
	
	return slot
end	
--]]




--------------------------------------------------
-- ToggleAutomaticBanking - toggle if the automatic banking module is enabled
--------------------------------------------------

function MB.ToggleAutomaticBanking()
	if PT.debug then PT.DebugEntry("PVPTools.MB.ToggleAutomaticBanking") end
	
	PT.ASV.settingsMBUseAutoBanking = not PT.ASV.settingsMBUseAutoBanking
	
	PT.CheckEventRegistrations()
end


--------------------------------------------------
-- ToggleAutomaticMerchant - toggle if the automatic merchant module is enabled
--------------------------------------------------
function MB.ToggleAutomaticMerchant()
	if PT.debug then PT.DebugEntry("PVPTools.MB.ToggleAutomaticMerchant") end
	
	PT.ASV.settingsMBUseAutoMerchant = not PT.ASV.settingsMBUseAutoMerchant
	
	PT.CheckEventRegistrations()
end


--------------------------------------------------
-- ToggleFragmentMerchant - toggle if the automatic imperial fragment merchant module is enabled
--------------------------------------------------
function MB.ToggleFragmentMerchant()
	if PT.debug then PT.DebugEntry("PVPTools.MB.ToggleFragmentMerchant") end
	
	PT.ASV.settingsMBUseFragmentMerchant = not PT.ASV.settingsMBUseFragmentMerchant
	
	PT.CheckEventRegistrations()
	
end


--------------------------------------------------
-- SetReserveBankSpace - set the number of bag spaces to reserve when using auto merchant
--------------------------------------------------
function MB.SetReserveBankSpace(value)
	if PT.debug then PT.DebugEntry("PVPTools.MB.SetReserveBankSpace") end
	
	value = tonumber(value)
	if type(value) ~= "number" then
		PVPTools.AMS.DisplayMessage("Error setting reserve bag space - Entry not a number", "mb")
	else
		local maxBagSlots = GetBagSize(BAG_BACKPACK)
		if value > maxBagSlots then 
			PVPTools.AMS.DispalyMessage("Error setting reserve bag space - Entry exceeds maximum bag space", "mb")
		elseif maxBagSlots < 1 then
			PVPTools.AMS.DisplayMessage("Error setting reserve bag space - Entry is less than 1", "mb")
		else
			PVPTools.ASV.settingsMBReserveBagSpace = value
		end
	end
end


--------------------------------------------------
-- SetMinimumAmount - set the minimum amount of the currency to keep in player inventory
--------------------------------------------------
function MB.SetMinimumAmount(currency, value)
	if PT.debug then PT.DebugEntry("PVPTools.MB.SetMinimumAmount") end
	
	value = tonumber(value)
	
	if value == nil then value = 0 end
	if value > PVPTools.ASV.settingsMBAutoBanking[currency][3] then 
		value = PVPTools.ASV.settingsMBAutoBanking[currency][3]
	end
	
	PVPTools.ASV.settingsMBAutoBanking[currency][2] = value
	CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", PT.LAMpanel)
end


--------------------------------------------------
-- SetMaximumAmount - Set the maximum amount of the currency to keep in player inventory
--------------------------------------------------
function MB.SetMaximumAmount(currency, value)
	if PT.debug then PT.DebugEntry("PVPTools.MB.SetMaximumAmount") end
	
	value = tonumber(value)
	
	if value == nil then value = 0 end
	if value < PVPTools.ASV.settingsMBAutoBanking[currency][2] then 
		value = PVPTools.ASV.settingsMBAutoBanking[currency][2]
	end
	
	PVPTools.ASV.settingsMBAutoBanking[currency][3] = value
	CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", PT.LAMpanel)
end
--------------------------------------------------
-- DoBanking - do the appropriate deposits or withdraws from the bank
--------------------------------------------------
function MB.DoBanking(bankBag)
	if PT.debug then PT.DebugEntry("PVPTools.MB.DoBanking") end
	
	-- PT.ASV.settingsMBAutoBanking format: 
	-- ["currencyType"] = {[1]active, [2]minAmount, [3]maxAmount}
	
	for key, currencyType in pairs(MB.Currency) do
		local active = PT.ASV.settingsMBAutoBanking[key][1]
		local minAmount = PT.ASV.settingsMBAutoBanking[key][2]
		local maxAmount = PT.ASV.settingsMBAutoBanking[key][3]
		local currencyIcon = MB.CurrencyIcons[key]
		local done = false
		
		if active then
			local inPocket = GetCurrencyAmount(currencyType, CURRENCY_LOCATION_CHARACTER)
			local inBank = GetCurrencyAmount(currencyType, CURRENCY_LOCATION_BANK)
			
			if maxAmount < minAmount then maxAmount = minAmount end
						
			if inPocket > maxAmount then
				local deposit = inPocket - maxAmount
				TransferCurrency(currencyType, deposit, CURRENCY_LOCATION_CHARACTER, CURRENCY_LOCATION_BANK)
				PT.AMS.DisplayMessage("Transferred "..ZO_CommaDelimitNumber(deposit).." "..currencyIcon.." to the bank.", "mb")
				done = true
			end
			
			if inPocket < minAmount then
				local withdraw = minAmount - inPocket
				if withdraw < inBank then
					TransferCurrency(currencyType, withdraw, CURRENCY_LOCATION_BANK, CURRENCY_LOCATION_CHARACTER)
					PT.AMS.DisplayMessage("Withdrew "..ZO_CommaDelimitNumber(withdraw).." "..currencyIcon.." from the bank.", "mb")
				else
					PT.AMS.DisplayMessage("Insufficient Funds to withdraw "..ZO_CommaDelimitNumber(withdraw).." "..currencyIcon.."from bank.  Please see a loan officer.", "mb")
				end
				done = true
			end
			
			if not done then 
				PT.AMS.DisplayMessage(currencyIcon .. " No banking action taken.", "mb")
			end
		end
	end
end


--------------------------------------------------
-- DoShopping - do the appropriate shopping
--------------------------------------------------
function MB.DoShopping(itemIndex)
	if PT.debug then PT.DebugEntry("PVPTools.MB.DoShopping") end
	
	if itemIndex == nil then 
		itemIndex = 1
		StackBag(BAG_BACKPACK)
	end

	if itemIndex <= GetNumStoreItems() then
		if GetNumBagFreeSlots(BAG_BACKPACK) > PVPTools.ASV.settingsMBReserveBagSpace then
			
			local itemName = ""
			local cleanItemName = ""
			local currencyType = 0
			local currencyQuantity = 0
			local targetQuantity = 0
			local useGold = false
			local slot = 0
			local inBag = 0
			local shoppingQuantity = 0
			local properCurrency = false
			
			itemName, currencyType, currencyQuantity = MB.GetStoreItemInfo(itemIndex)
								
			-- To match the saved variables key, we have to strip the alliance name from the itemName
			cleanItemName = MB.CleanStoreItemName(itemName)
			
			-- PVPTools.ASV.settingsMBAutoMerchant format: 
			-- [itemName] = {[1]quantity, [2]useGold, [3]stackSize}
			
			targetQuantity  = PVPTools.ASV.settingsMBAutoMerchant[cleanItemName][1]
			useGold = PVPTools.ASV.settingsMBAutoMerchant[cleanItemName][2]
			
			if PT.debug then PT.DebugEntry("Item Name: "..itemName) PT.DebugEntry("Clean Item Name: "..cleanItemName) end
			
			if ((useGold == true) and (currencyType == CURT_MONEY)) then
				properCurrency = true
			end
			
			if ((useGold == false) and (currencyType == CURT_ALLIANCE_POINTS)) then
				properCurrency = true
			end
			
			if ((targetQuantity > 0) and properCurrency) then
				slot = PT.FindSlotInBackpackByItemName(itemName)
				if slot then 
					inBag = GetItemTotalCount(BAG_BACKPACK, slot)
				else
					inBag = 0
				end
				shoppingQuantity = targetQuantity - inBag
				if PT.debug then PT.DebugEntry("Item Name Being Checked in Inventory: "..itemName) PT.DebugEntry("Number we have in our bag: "..inBag) PT.DebugEntry("Number to Purchase: "..shoppingQuantity) end

				if (shoppingQuantity > 0)then
				
					MB.MakePurchase(itemIndex, itemName, shoppingQuantity, currencyQuantity, currencyType)
			
				end
			end
			itemIndex = itemIndex + 1
			zo_callLater(function() MB.DoShopping(itemIndex) end, 80)
		else
			PVPTools.AMS.DisplayMessage("Insufficient Bag Space", "mb")
		end
	else
		PVPTools.AMS.DisplayMessage("Shopping Complete", "mb")
	end
	
	
end


--------------------------------------------------
-- GetItemInfo - Get necessary item information from the passed item id from the store inventory list
--------------------------------------------------
function MB.GetStoreItemInfo(itemIndex)
	if PT.debug then PT.DebugEntry("PVPTools.MB.GetItemInfo") end
	
	local textureName, itemName, stack, price, sellPrice, meetsRequirementsToBuy, meetsRequirementsToUse, quality, questNameColor, currencyType1, currencyQuantity1, currencyType2, currencyQuantity2, entryType, buyStoreFailure, buyErrorStringId = GetStoreEntryInfo(itemIndex)

	-- The cyrodiil vendor will have a currencyType1 and a currencyQuantity1 if you can buy it with aliance points.  If it is for gold only, then those fields are "0" and the unit price is actually stored in the price field.  These adjustments compensate for this inconsistency.
	if (currencyType1 ~= CURT_ALLIANCE_POINTS) then
		currencyType1 = CURT_MONEY
		currencyQuantity1 = price
	end
		
	return itemName, currencyType1, currencyQuantity1
end


--------------------------------------------------
-- CleanStoreItemName - To match the saved variables key, we have to strip the alliance name from the itemName
--------------------------------------------------
function MB.CleanStoreItemName(itemName)
	if PT.debug then PT.DebugEntry("PVPTools.MB.CleanStoreItemName") end
	
	local alliance = PVPTools.MyAlliance()
	local cutString = ""
	
	if alliance == ALLIANCE_ALDMERI_DOMINION then cutString = "Dominion "
	elseif alliance == ALLIANCE_DAGGERFALL_COVENANT then cutString = "Covenant "
	elseif alliance == ALLIANCE_EBONHEART_PACT then cutString = "Pact "
	end
	
	itemName = string.gsub(itemName, cutString, "")
	
	if PT.debug then PT.DebugEntry("Modified Item Name: "..itemName) end
	
	return itemName
	
end

--------------------------------------------------
-- DoPurchase - make the purchase and print a receipt
--------------------------------------------------
function MB.MakePurchase(itemIndex, itemName, quantity, unitPrice, currencyType)

	local purchaseCost = 0
	local sufficientFunds = false
	local inPocket = 0
	
	purchaseCost = quantity * unitPrice
	
	if currencyType == CURT_MONEY then
		inPocket = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
	else
		inPocket = GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_CHARACTER)
	end
	
	if purchaseCost < inPocket then
		BuyStoreItem(itemIndex, quantity)
		StackBag(BAG_BACKPACK)
		local message = merchantTag.."Purchased "..quantity.." of "..itemName.." for "..purchaseCost.." "
		if currencyType == CURT_MONEY then
			message = message.. MB.CurrencyIcons["Gold"]
		else
			message = message.. MB.CurrencyIcons["Alliance Points"]
		end
		PVPTools.AMS.DisplayChatMessage(message)
	else
		local message = merchantTag.."Insufficient Funds.  Please see loan officer for more "
		if currencyType == CURT_MONEY then
			message = message..MB.CurrencyIcons["Gold"]
		else
			message = message..MB.CurrencyIcons["Alliance Points"]
		end
		PVPTools.AMS.DisplayChatMessage(message)
	end
end


--------------------------------------------------
-- DoICShopping- make the purchase at the imperial fragment merchant and open the resource bag
--------------------------------------------------
function MB.DoICShopping()
	if PT.debug then PT.DebugEntry("PVPTools.Merchant.DoICShopping") end
	
	if GetNumBagFreeSlots(BAG_BACKPACK) < 2 then
		PT.AMS.DispalyMessage("Insufficient Bag Space", "mb")
		return
	end
		
	for itemIndex = 1, GetNumStoreItems() do
		local itemName, currencyType, currencyQuantity = MB.GetStoreItemInfo(itemIndex)
		
		if string.find(itemName, "Imperial") then
			BuyStoreItem(itemIndex, 1)
			PVPTools.AMS.DisplayChatMessage("Purchased "..itemName)
			
			-- Because things were firing off so quickly it needed some time for everything to properly register
			zo_callLater(function() MB.CloseStore() end, 200)
			zo_callLater(function() MB.OpenResourceBag(itemName) end, 300)
		end
	end
	
end


--------------------------------------------------
-- CloseStore - close up the store scene so we can process the bag we purchased
--------------------------------------------------
function MB.CloseStore()
	if PT.debug then PT.DebugEntry("PVPTools.Merchant.CloseStore") end
	
	ZO_Dialogs_ReleaseDialog("REPAIR_ALL")
	ZO_Dialogs_ReleaseDialog("BUY_MULTIPLE")
	ZO_Dialogs_ReleaseDialog("SELL_ALL_JUNK")
	SCENE_MANAGER:Hide("store")
end


--------------------------------------------------
-- OpenResourceBag - process the bag we purchased
--------------------------------------------------
function MB.OpenResourceBag(itemName)
	if PT.debug then PT.DebugEntry("PVPTools.Merchant.OpenResourceBag") end
	
	local slot = PT.FindSlotInBackpackByItemName(itemName)
	
	if slot then 
		EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_LOOT_RECEIVED, MB.DisplayLootMessage)
		if IsProtectedFunction("UseItem") then
			CallSecureProtected("UseItem", BAG_BACKPACK, slot) -- https://wiki.esoui.com/API#Protected_Functions
		else
			UseItem(bag, slot)
		end
		zo_callLater(function() LootAll() end, 150)
		PVPTools.AMS.DisplayChatMessage("Opened "..itemName)
		zo_callLater(function()EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_LOOT_RECEIVED) PVPTools.AMS.DisplayChatMessage("You have "..ZO_CommaDelimitNumber(GetCurrencyAmount(CURT_IMPERIAL_FRAGMENTS, CURRENCY_LOCATION_ACCOUNT)).."|t80%:80%:/esoui/art/currency/currency_imperial_trophy_key_mipmap.dds|t remaining.") end, 700)
	end
end


--------------------------------------------------
-- DisplayLootMessage - show the results of LootAll()
--------------------------------------------------
function MB.DisplayLootMessage(eventCode, receivedBy, itemName, quantity, soundCategory, lootType, self, isPickpocketLoot, questItemIcon, itemId, isStolen)
	if PT.debug then PT.DebugEntry("PVPTools.Merchant.DisplayLootMessage") end
	
	PVPTools.AMS.DisplayChatMessage("Received "..quantity.." of "..itemName)
	
end