-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: Lookup.lua
-- File Description: This file contains the lookup from which trarget slots for task actions are selected
-- Load Order Requirements: before Action
-- 
-----------------------------------------------------------------------------------

local RbI = RulebasedInventory
local lookup = {}

local function ReplaceItemLinkAttributeAtIndex(itemLink, index)
	local i = 0
	for x= 0, index do
	i = string.find(itemLink, ':', i+1)
	end
	return string.sub(itemLink, 0, i-1) .. string.gsub(string.sub(itemLink, i), '%d+','0', 1)
end

local function GetItemLinkForSorting(itemLink)
	if(itemLink~=nil and itemLink~='') then

		if(not CanItemLinkBeVirtual(itemLink)) then
			local replaceIndex = {15, 16, 19} -- replace allFlag, style, stolen information
			for _, index in pairs(replaceIndex) do
				itemLink = ReplaceItemLinkAttributeAtIndex(itemLink, index)
			end
		else
			for index = 2, 21 do -- replace all 
				itemLink = ReplaceItemLinkAttributeAtIndex(itemLink, index)
			end 
		end
	end
	return itemLink
end
RbI.GetItemLinkForSorting = GetItemLinkForSorting

local function NewLookup(bag)
	local self = {}
	self.free = {}
	self.occupied = {}
	self.isESOPlusSubscriber = IsESOPlusSubscriber()

	-- itemLink returns the occupied table with only the single itemLink-table inside
	-- itemLink needs to be masked as it possibly is a real itemLink
	-- return of GetSlotDatas must not be written to!
	local function GetSlotDatas(itemLink)
		local occupied
		if(itemLink ~= nil) then
			itemLink = GetItemLinkForSorting(itemLink)
			
			occupied = {[itemLink] = (self.occupied[itemLink] or {})}
		end
		return occupied or self.occupied
	end
	
	-- called by actions to mark changes to the slotFrom
	-- but also by GetSlotToDatas to change slots which items will go into
	-- and by the initializer of a lookup to build itself up
	local function SetSlotData(itemLinkForSorting, slotFromData, checkItemLink)
		local bagFrom = slotFromData.bag
		if(bagFrom == BAG_SUBSCRIBER_BANK) then
			bagFrom = BAG_BANK
		end
		if(itemLinkForSorting ~= nil and itemLinkForSorting ~= '') then
			if(slotFromData.stackCountChange ~= nil) then
				local status = false
				for i, slotData in ipairs(self.occupied[itemLinkForSorting]) do
					if(slotData.bag == slotFromData.bag and slotData.slot == slotFromData.slot) then
						self.occupied[itemLinkForSorting].count = self.occupied[itemLinkForSorting].count or {}
						self.occupied[itemLinkForSorting].count[bagFrom] = (self.occupied[itemLinkForSorting].count[bagFrom] or 0) + slotFromData.stackCountChange
						if(slotFromData.stack + slotFromData.stackCountChange > 0) then
							self.occupied[itemLinkForSorting][i].stack = math.max(self.occupied[itemLinkForSorting][i].stack + slotFromData.stackCountChange, 0)
							self.occupied[itemLinkForSorting][i].quickslotted = slotFromData.quickslotted
						else
							table.remove(self.occupied[itemLinkForSorting], i)
							if(self.isESOPlusSubscriber or slotFromData.bag ~= BAG_SUBSCRIBER_BANK) then
								table.insert(self.free, {bag = slotFromData.bag
														,slot = slotFromData.slot})
							end
						end
						status = true
						break
					end
				end
			else
				self.occupied[itemLinkForSorting] = self.occupied[itemLinkForSorting] or {}
				self.occupied[itemLinkForSorting].count = self.occupied[itemLinkForSorting].count or {}
				self.occupied[itemLinkForSorting].count[bagFrom] = (self.occupied[itemLinkForSorting].count[bagFrom] or 0) + slotFromData.stack
				local itemLink = slotFromData.itemLink
				if(checkItemLink == true) then
					itemLink = GetItemLink(slotFromData.bag, slotFromData.slot)
				end

				table.insert(self.occupied[itemLinkForSorting], {bag = slotFromData.bag
																,slot = slotFromData.slot
																,stack = slotFromData.stack
																,itemLink = itemLink
																,stackPrice = slotFromData.stackPrice
																,currency = slotFromData.currency
																,stackMax = slotFromData.stackMax
																,quickslotted = slotFromData.quickslotted})
			end
		elseif(self.isESOPlusSubscriber or slotFromData.bag ~= BAG_SUBSCRIBER_BANK) then
			-- insert free slot
			table.insert(self.free, slotFromData)
		end
	end

	-- get slotTos for an given amount of a single item, 
	-- sets the slots in this lookup as if the actions had already taken place
	local function GetSlotToDatas(itemLinkForSorting, slotFromData)	
		local slotToDatas = {}
		-- stackCountChange of slotFromData is count which is taken there and added here
		local amount = -slotFromData.stackCountChange

		-- if item can be stacked, search for stackable slots till amount is satisfied or no stackable slots are found
		if(slotFromData.stackMax > 1) then
			for i, slotToData in ipairs(self.occupied[itemLinkForSorting] or {}) do
				-- only use slot from BAG_SUBSCRIBER_BANK if user still is subscriber, as transferring TO such a slot is impossible
				-- check here is necessary because items could still reside in BAG_SUBSCRIBER_BANK, while subscription has run out
				if(slotToData.itemLink == slotFromData.itemLink 
					and slotToData.stack < slotToData.stackMax 
					and (self.isESOPlusSubscriber or slotToData.bag ~= BAG_SUBSCRIBER_BANK)
					and (slotToData.bag ~= slotFromData.bag or slotToData.slot ~= slotFromData.slot)) then
					-- slot fits and has space, fill slot further
					slotToData.stackCountChange = math.min(amount, (slotToData.stackMax - slotToData.stack))
					--slotToData.stack = math.max(slotToData.stack + slotToData.stackCountChange, 0) --stack changes in SetSlotData
					-- update slot in lookup
					SetSlotData(itemLinkForSorting, slotToData)
					table.insert(slotToDatas, slotToData)
					amount = amount - slotToData.stackCountChange
					if(amount <= 0) then
						break
					end
				end
			end
		end
		
		while(amount > 0) do
			-- still amount to move left, take empty slots into consideration
			local slotToData = table.remove(self.free)
			-- no need to check for subscription, 
			-- empty slots of BAG_SUBSCRIBER_BANK will only show if user inded is subscriber
			if(slotToData ~= nil) then
				slotToData.stack = amount
				slotToData.itemLink = slotFromData.itemLink
				slotToData.stackMax = slotFromData.stackMax
				slotToData.quickslotted = slotFromData.quickslotted
				-- insert to lookup (without stackCountChange to newly insert
				SetSlotData(itemLinkForSorting, slotToData, true)
				
				slotToData.stackCountChange = math.min(amount, slotToData.stackMax)
				table.insert(slotToDatas, slotToData)
				amount = math.max(0, (amount - slotToData.stackMax))
			else
				break
			end
		end
		
		-- set stackCountChange to processed item count (amount holds left overs)
		slotFromData.stackCountChange = slotFromData.stackCountChange + amount
		return amount, slotToDatas
	end
	
	
	local function InitializeFromBag()
		-- initial build up when on bag
		local bags = {}
		if(bag == 'EXTRACTION' or bag == 'DECONSTRUCTION' or bag == 'REFINEMENT') then
			bags[BAG_BACKPACK] = true
			bags[BAG_BANK] = true
			bags[BAG_SUBSCRIBER_BANK] = true
			if(bag == 'REFINEMENT') then
				bags[BAG_VIRTUAL] = true
			end
		else
			bags[bag] = true
			if(bag == BAG_BANK) then
				bags[BAG_SUBSCRIBER_BANK] = true
			end
		end
		
		for bag in pairs(bags) do
			if(bag=='VENDOR') then
				RbI.BagIteration(bag, function(slot)
					local _, _, stack, price, sellPrice, meetsRequirementsToBuy, meetsRequirementsToEquip, _, _, currencyType1, currencyQuantity1, currencyType2, currencyQuantity2, entryType, _, _ = GetStoreEntryInfo(slot)
					local itemLink, itemLinkForSorting, stackMax, currency

					if(price ~= 0) then
						currency = CURT_MONEY
					elseif(currencyQuantity1 ~= 0) then
						currency = currencyType1
						price = currencyQuantity1
					elseif(currencyQuantity2 ~= 0) then
						currency = currencyType2
						price = currencyQuantity2
					end

					if(stack > 0 and price ~= 0 and entryType == STORE_ENTRY_TYPE_ITEM) then
						itemLink = GetStoreItemLink(slot)
						itemLinkForSorting = GetItemLinkForSorting(itemLink)
						stackMax = math.max(GetStoreEntryMaxBuyable(slot), stack)
						stack = stackMax
					else
						stack = 0
						price = 0
					end

					SetSlotData(itemLinkForSorting, {bag = bag
						,slot = slot
						,stack = stack
						,stackPrice = stack * price
						,currency = currency
						,itemLink = itemLink
						,stackMax = stackMax
						,quickslotted = false})
	
				end)
			else
				RbI.BagIteration(bag, function(slot)
					local itemLink = GetItemLink(bag, slot)
					local itemLinkForSorting = GetItemLinkForSorting(itemLink)
					local stack, stackMax = GetSlotStackSize(bag, slot)
					local quickslotted = (FindActionSlotMatchingItem(bag, slot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL) ~= nil)
					SetSlotData(itemLinkForSorting, {bag = bag
						,slot = slot
						,stack = stack
						,itemLink = itemLink
						,stackMax = stackMax
						,quickslotted = quickslotted})

				end)
			end
		end
	end

	InitializeFromBag()

	return {SetSlotData = SetSlotData
		   ,GetSlotDatas = GetSlotDatas
		   ,GetSlotToDatas = GetSlotToDatas
		   }
end

-- calls the given function with the slot
function RbI.BagIteration(bag, fn)
	if(bag == BAG_VIRTUAL) then
		-- BAG_VIRTUAL
		local slot = GetNextVirtualBagSlotId()
		while slot ~= nil do
			if(fn(slot) == false) then
				break
			end
			slot = GetNextVirtualBagSlotId(slot)
		end
	elseif(bag == 'VENDOR') then
		for slot = 1, GetNumStoreItems() do
			if(fn(slot) == false) then
				break
			end
		end
	else
		for slot = 0, GetBagSize(bag) - 1 do
			if(fn(slot) == false) then
				break
			end
		end
	end
end

function RbI.ClearLookup(bag)
	if(bag == nil) then return end
	local bags = {}
	if(bag == BAG_SUBSCRIBER_BANK) then
		bags[BAG_BANK] = true
	else
		bags[bag] = true
	end

	for bag in pairs(bags) do
		if(lookup[bag] ~= nil) then
			lookup[bag].count = lookup[bag].count + -1
			if(lookup[bag].count == 0) then
				lookup[bag] = nil
				-- d("Cleared Bag for "..bag)
			else
				-- d("Bag not yet cleared for "..bag)
			end
		else
			-- d("already cleared Bag for "..bag)
		end
	end
end

function RbI.GetLookup(bag, create)
	if(bag == nil) then return end
	local bags = {}
	if(bag == BAG_SUBSCRIBER_BANK) then
		bag = BAG_BANK
		bags[bag] = true
	else
		bags[bag] = true
	end
	
	--d("Requested bag for "..bag)
	for bag in pairs(bags) do
		if(lookup[bag] == nil) then
			if(create) then
				lookup[bag] = {lookup = NewLookup(bag), count = 0}
				-- d("Created Bag for "..bag)
			else
				return
			end
		end
	end
	if(create) then
		lookup[bag].count = lookup[bag].count + 1
	end
	-- for requests only a single bag from the specific ZO_BAGs will be present
	return lookup[bag].lookup
end

