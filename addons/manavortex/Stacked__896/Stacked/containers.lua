local addonName, _ = 'Stacked'
local addon = _G[addonName]
local L = addon.L

STACKED_CONTAINER_COMPLETED = 'Stacked_ContainerStackingCompleted'

-- GLOBALS: LINK_STYLE_DEFAULT, BAG_BANK, KEYBIND_STRIP, ZO_GuildBank
-- GLOBALS: GetSlotStackSize, ClearCursor, CallSecureProtected, GetBagInfo, GetItemLink, GetMaxBags, IsItemConsumable, ZO_LinkHandler_ParseLink, GetItemInstanceId
-- GLOBALS: string, pairs, tonumber

local function GetSlotText(bag, slot)
	local result = (bag == BAG_BACKPACK and L'backpack' )
		or (bag == BAG_BANK and L'bank')
		--or (bag == BAG_GUILDBANK and L'guildbank')
		or 'unknown'
	if slot and addon.db.showSlot then
		result = L('bag slot number', result, slot)
	end
	return result
end
addon.GetSlotText = GetSlotText

local moveLog = {}
local function MoveItem(fromBag, fromSlot, toBag, toSlot, count, destCount, silent)
	local success = false	
	
	
		local sourceCount = count or GetSlotStackSize(fromBag, fromSlot)
		local destCount   = destCount or GetSlotStackSize(toBag, toSlot)

		
		if CallSecureProtected('PickupInventoryItem', fromBag, fromSlot, sourceCount) then
			
				success = CallSecureProtected('PlaceInInventory', toBag, toSlot)
			
		end

		if addon.db.showMessages and not silent then
			local itemLink = GetItemLink(fromBag, fromSlot, LINK_STYLE_DEFAULT)
			local output
			if fromBag == toBag and not addon.db.showSlot then
				output = L(success and 'stacked item' or 'failed stacking item',
					itemLink, (sourceCount + destCount), GetSlotText(toBag, toSlot), sourceCount, destCount)
			else
				output = L(success and 'moved item' or 'failed moving item',
					itemLink, sourceCount, GetSlotText(fromBag, fromSlot), GetSlotText(toBag, toSlot))
			end
			addon.Print(output)
		end

		-- clear the cursor to avoid issues
		ClearCursor()

		if success then
			moveLog[toBag..'.'..toSlot] = (moveLog[toBag..'.'..toSlot] or 0) + 1
		end

	return success
end

function addon.GetExcluded(bag, slot, item, excludeSlots)
	
	local itemSaverSaved = false
	if addon.ExcludeItemSaver then itemSaverSaved = addon.ExcludeItemSaver(bag, slot) end
		
	return (addon.db.exclude[itemID]
		and not (type(excludeSlots) == 'table' 
		and addon.Find(excludeSlots, slot))) 
		or itemSaverSaved

end

function checkOwnership(bag, slot, remotebag, remoteslot)
	return IsItemStolen(bag, slot) == IsItemStolen(remotebag, remoteslot)
end


local positions = {}
function addon.StackContainer(bag, itemKey, silent, excludeSlots)
	local numBagSlots = GetBagSize and GetBagSize(bag) or select(2, GetBagInfo(bag))
	for slot = 0, numBagSlots do
		local itemLink = GetItemLink(bag, slot, LINK_STYLE_DEFAULT)
		local itemID, key
		if itemLink then
			_, _, _, itemID = ZO_LinkHandler_ParseLink(itemLink)
			itemID = itemID and tonumber(itemID)
			key = GetItemInstanceId(bag, slot)

		end

		-- don't touch if slot is empty or item or slot is excluded
		if itemID and not addon.GetExcluded(bag, slot, itemID, excludeSlots) then
			local count, stackSize = GetSlotStackSize(bag, slot)
			local total = count			
			if itemLink and count < stackSize then
				local data = positions[key]

				if itemKey and key ~= itemKey then
					-- do nothing
				
				elseif data and checkOwnership(bag, slot, data.bag, data.slot) then
					total = total + data.count
					local success = MoveItem(bag, slot, data.bag, data.slot, count, data.count, silent)
					if success then
						if total > stackSize then
							-- dest stack was full, remove, instead use updated source
							data.bag = bag
							data.slot = slot
							data.count = total - stackSize
						else
							-- items fit, update count
							data.count = total
						end
					end
				else
					-- first time encountering this item
					positions[key] = {
						bag = bag,
						slot = slot,
						count = count,
					}
				end
			end
		end
	end
end

function addon.ExcludeItemSaver(bag, slot)
	local ret = false
	if ItemSaver_IsItemSaved then 
		ret = ItemSaver_IsItemSaved(1, slot)
	end
	--Return value if item is saved with ItemSaver
	if FCOIsMarked then
		--Return value if item is marked with FCOItemSaver
		ret = ret or FCOIsMarked(GetItemInstanceId(1, slot), -1)
	end
	return ret
end

local function CheckRestack(event)
	if (event == 'EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS' and not addon.GetSetting('mail'))
		or (event == 'EVENT_TRADE_SUCCEEDED' and not addon.GetSetting('trade'))
		or (event == 'EVENT_OPEN_BANK' and not addon.GetSetting('bank')) then
		return
	end

	local firstBag, lastBag, direction = 1, GetMaxBags(), 1
	local moveTarget = addon.GetSetting('moveTarget')
	if moveTarget == L'bank' then
		-- to put items into bank, we need different traversal
		firstBag = lastBag
		lastBag = 1
		direction = -1
	end

	ZO_ClearTable(positions)
	for bag = firstBag, lastBag, direction do
		-- check if this bag may be stacked but still allow manual stacking (/stack or keybind)
		if addon.GetSetting('stackContainer'..bag) or not event then
			addon.StackContainer(bag)
		end

		if (bag == BAG_BACKPACK and moveTarget ~= L'backpack')
			or (bag == BAG_BANK and moveTarget ~= L'bank') then
			for key, position in pairs(positions) do
				if position.bag == bag then
					ZO_ClearTable(positions[key])
					positions[key] = nil
				end
			end
		end
	end

	--addon.Print(L'stacking completed')
end

-- Events
-----------------------------------------------------------
local em = GetEventManager()
em:RegisterForEvent(addonName, EVENT_TRADE_SUCCEEDED, function() CheckRestack('EVENT_TRADE_SUCCEEDED') end)
em:RegisterForEvent(addonName, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, function() CheckRestack('EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS') end)
em:RegisterForEvent(addonName, EVENT_OPEN_BANK, function() CheckRestack('EVENT_OPEN_BANK') end)
em:RegisterForEvent(addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(eventID, bagID, slotID, isNew, sound, updateReason)
	local slot = bagID..'.'..slotID
	if moveLog[slot] then
		if moveLog[slot] <= 1 then
			moveLog[slot] = nil
		else
			moveLog[slot] = moveLog[slot] -1
		end
	end

	local bagDone = true
	for moveSlot, num in pairs(moveLog) do
		local bag = math.floor(tonumber(moveSlot))
		if bag == bagID then
			bagDone = false
			break
		end
	end
	if bagDone then
		CALLBACK_MANAGER:FireCallbacks(STACKED_CONTAINER_COMPLETED)
	end
end)

-- Keybindings
-----------------------------------------------------------
addon.slashCommandHelp = (addon.slashCommandHelp or '') .. '\n' .. L'/stack'
SLASH_COMMANDS['/stack'] = CheckRestack

local keybind = {
	name = L'Stack',
	keybind = 'STACKED_STACK',
	callback = CheckRestack,
	alignment = KEYBIND_STRIP_ALIGN_LEFT,
}
local function ShowKeybinds() KEYBIND_STRIP:AddKeybindButton(keybind) end
local function HideKeybinds() KEYBIND_STRIP:RemoveKeybindButton(keybind) end

ZO_PreHookHandler(ZO_PlayerInventory, 'OnShow', ShowKeybinds)
ZO_PreHookHandler(ZO_PlayerInventory, 'OnHide', HideKeybinds)
ZO_PreHookHandler(ZO_PlayerBank, 'OnShow', ShowKeybinds)
ZO_PreHookHandler(ZO_PlayerBank, 'OnHide', HideKeybinds)
