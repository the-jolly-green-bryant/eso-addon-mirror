Mephisto = Mephisto or {}
local MP = Mephisto

MP.banking = {}
local MPB = MP.banking
local MPG = MP.gui

function MPB.Init()
	MPB.name = MP.name .. "Banking"
	MPB.RegisterEvents()
end

function MPB.RegisterEvents()
	EVENT_MANAGER:RegisterForEvent(MPB.name, EVENT_OPEN_BANK, function(_, bankBag)
		if not MP.DISABLEDBAGS[bankBag] then
			MPG.RefreshPage()
		end
	end)
	EVENT_MANAGER:RegisterForEvent(MPB.name, EVENT_CLOSE_BANK, function(_)
		MPG.RefreshPage()
	end)
end

function MPB.WithdrawPage(zone, pageId)
	local bankBag = GetBankingBag()
	if MP.DISABLEDBAGS[bankBag] then return end
	
	local preGearTable = {}
	local amount = 0
	
	for entry in MP.PageIterator(zone, pageId) do
		local setup = Setup:FromStorage(zone.tag, pageId, entry.index)
		for _, gearSlot in ipairs(MP.GEARSLOTS) do
			local gear = setup:GetGearInSlot(gearSlot)
			if gearSlot ~= EQUIP_SLOT_POISON
				and gearSlot ~= EQUIP_SLOT_BACKUP_POISON
				and gearSlot ~= EQUIP_SLOT_COSTUME
				and gear then
				
				if not preGearTable[gear.id] then
					preGearTable[gear.id] = true
					amount = amount + 1
				end
			end
		end
	end
	
	if not IsBankOpen() then return end
	
	local gearTable = MPB.ScanBank(bankBag, preGearTable, amount)
	
	local pageName = MP.pages[zone.tag][pageId].name
	MP.Log(GetString(MP_MSG_WITHDRAW_PAGE), MP.LOGTYPES.NORMAL, "FFFFFF", pageName)
	
	MPB.MoveItems(gearTable, BAG_BACKPACK)
end

function MPB.WithdrawSetup(zone, pageId, index)
	local bankBag = GetBankingBag()
	if MP.DISABLEDBAGS[bankBag] then return end
	
	local setup = Setup:FromStorage(zone.tag, pageId, index)
	
	local preGearTable = {}
	local amount = 0
	for _, gearSlot in ipairs(MP.GEARSLOTS) do
		local gear = setup:GetGearInSlot(gearSlot)
		if gearSlot ~= EQUIP_SLOT_POISON
			and gearSlot ~= EQUIP_SLOT_BACKUP_POISON
			and gearSlot ~= EQUIP_SLOT_COSTUME
			and gear then
			
			if not preGearTable[gear.id] then
				preGearTable[gear.id] = true
				amount = amount + 1
			end
		end
	end
	
	if not IsBankOpen() then return end
	
	local gearTable = MPB.ScanBank(bankBag, preGearTable, amount)
	
	MP.Log(GetString(MP_MSG_WITHDRAW_SETUP), MP.LOGTYPES.NORMAL, "FFFFFF", setup:GetName())
	
	MPB.MoveItems(gearTable, BAG_BACKPACK)
end

function MPB.DepositSetup(zone, pageId, index)
	local bankBag = GetBankingBag()
	if MP.DISABLEDBAGS[bankBag] then return end
	
	local setup = Setup:FromStorage(zone.tag, pageId, index)
	local itemLocationTable = MP.GetItemLocation()
	
	local gearTable = {}
	for _, gearSlot in ipairs(MP.GEARSLOTS) do
		local gear = setup:GetGearInSlot(gearSlot)
		if gearSlot ~= EQUIP_SLOT_POISON
			and gearSlot ~= EQUIP_SLOT_BACKUP_POISON
			and gearSlot ~= EQUIP_SLOT_COSTUME
			and gear then
			
			if itemLocationTable[gear.id] then
				table.insert(gearTable, {
					id = gear.id,
					bag = itemLocationTable[gear.id].bag,
					slot = itemLocationTable[gear.id].slot,
				})
			end
		end
	end
	
	MP.Log(GetString(MP_MSG_DEPOSIT_SETUP), MP.LOGTYPES.NORMAL, "FFFFFF", setup:GetName())
	
	MPB.MoveItems(gearTable, bankBag)
end

function MPB.DepositPage(zone, pageId)
	local bankBag = GetBankingBag()
	if MP.DISABLEDBAGS[bankBag] then return end
	
	local itemLocationTable = MP.GetItemLocation()
	
	local preGearTable = {}
	for entry in MP.PageIterator(zone, pageId) do
		local setup = Setup:FromStorage(zone.tag, pageId, entry.index)
		for _, gearSlot in ipairs(MP.GEARSLOTS) do
			local gear = setup:GetGearInSlot(gearSlot)
			if gearSlot ~= EQUIP_SLOT_POISON
				and gearSlot ~= EQUIP_SLOT_BACKUP_POISON
				and gearSlot ~= EQUIP_SLOT_COSTUME
				and gear then
				
				if itemLocationTable[gear.id] then
					preGearTable[gear.id] = {
						bag = itemLocationTable[gear.id].bag,
						slot = itemLocationTable[gear.id].slot,
					}
				end
			end
		end
	end
	
	local gearTable = {}
	for id, item in pairs(preGearTable) do
		table.insert(gearTable, {
			id = id,
			bag = item.bag,
			slot = item.slot,
		})
	end
	
	local pageName = MP.pages[zone.tag][pageId].name
	MP.Log(GetString(MP_MSG_DEPOSIT_PAGE), MP.LOGTYPES.NORMAL, "FFFFFF", pageName)
	
	MPB.MoveItems(gearTable, bankBag)
end

function MPB.ScanBank(bankBag, itemIdTable, amount)
	local itemTable = {}
	local i = 0
	
	for slot in ZO_IterateBagSlots(bankBag) do
		local lookupId = Id64ToString(GetItemUniqueId(bankBag, slot))
		if lookupId and itemIdTable[lookupId] then
			table.insert(itemTable, {
				id = lookupId,
				bag = bankBag,
				slot = slot,
			})
			i = i + 1
			if i >= amount then
				-- found all items
				return itemTable
			end
		end
	end
	
	if bankBag == BAG_BANK and IsESOPlusSubscriber() then -- straight up torture
		for slot in ZO_IterateBagSlots(BAG_SUBSCRIBER_BANK) do
			local lookupId = Id64ToString(GetItemUniqueId(BAG_SUBSCRIBER_BANK, slot))
			if lookupId and itemIdTable[lookupId] then
				table.insert(itemTable, {
					id = lookupId,
					bag = BAG_SUBSCRIBER_BANK,
					slot = slot,
				})
				i = i + 1
				if i >= amount then
					-- found all items
					return itemTable
				end
			end
		end
	end
	
	-- check if items are already in inventory
	local inventoryList = MP.GetItemLocation()
	for itemId, _ in pairs(inventoryList) do
		if itemId and itemIdTable[itemId] then
			i = i + 1
			if i >= amount then
				-- found all items
				return itemTable
			end
		end
	end
	
	MP.Log(GetString(MP_MSG_WITHDRAW_ENOENT), MP.LOGTYPES.INFO)
	return itemTable
end

function MPB.MoveItems(itemTable, destBag, supressOutput)
	if (destBag == BAG_BANK or destBag == BAG_SUBSCRIBER_BANK) and not IsBankOpen() then return end
	
	if #itemTable == 0 then
		if not supressOutput then
			MP.Log(GetString(MP_MSG_TRANSFER_FINISHED))
		end
		return
	end
	local item = itemTable[1]
	
	local sourceId = item.id
	local sourceBag = item.bag
	local sourceSlot = item.slot
	
	-- check space
	if not DoesBagHaveSpaceFor(destBag, sourceBag, sourceSlot) then
		if destBag == BAG_BACKPACK then
			MP.Log(GetString(MP_MSG_WITHDRAW_FULL), MP.LOGTYPES.ERROR)
		else
			if destBag == BAG_BANK and IsESOPlusSubscriber() then
				MPB.MoveItems(itemTable, BAG_SUBSCRIBER_BANK, supressOutput)
			else
				MP.Log(GetString(MP_MSG_DEPOSIT_FULL), MP.LOGTYPES.ERROR)
			end
		end
		return false
	end
	
	-- get first slot
	local destSlot = FindFirstEmptySlotInBag(destBag)
	if not destSlot then
		return false
	end
	
	-- move item
	CallSecureProtected("RequestMoveItem", sourceBag, sourceSlot, destBag, destSlot, 1)
	
	-- check arrival
	local identifier = string.format("MPB_%s", sourceId)
	local i = 1
	EVENT_MANAGER:RegisterForUpdate(identifier, 100, function()
		if (destBag == BAG_BANK or destBag == BAG_SUBSCRIBER_BANK) and not IsBankOpen() then
			EVENT_MANAGER:UnregisterForUpdate(identifier)
			return
		end
		
		local itemId = GetItemId(destBag, destSlot)
		if itemId > 0 then
			EVENT_MANAGER:UnregisterForUpdate(identifier)
			table.remove(itemTable, 1)
			zo_callLater(function()
				MPB.MoveItems(itemTable, destBag, supressOutput)
			end, 100)
			return
		end
		
		i = i + 1
		if i > 30 then -- 3000ms
			EVENT_MANAGER:UnregisterForUpdate(identifier)
			MP.Log(GetString(MP_MSG_TRANSFER_TIMEOUT), MP.LOGTYPES.ERROR)
			return
		end
	end)
end