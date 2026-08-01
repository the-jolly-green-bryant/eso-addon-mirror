-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: Action.lua
-- File Description: This file contains the actions which are executed by a task
-- Load Order Requirements: before Task
-- 
-----------------------------------------------------------------------------------

local RbI = RulebasedInventory
RbI.actions = RbI.actions or {}
local actions = RbI.actions

-- define actions for tasks
actions.Notify = function(taskName, itemLinkForSorting, slotFromData, bagFrom, bagTo)
	RbI.ActionQueue.Push(taskName, slotFromData.itemLink, -slotFromData.stackCountChange, function() end)
	return 0
end

actions.JunkItem = function(taskName, itemLinkForSorting, slotFromData, bagFrom, bagTo)
	RbI.ActionQueue.Push(taskName, itemLinkForSorting, -slotFromData.stackCountChange, function() SetItemIsJunk(slotFromData.bag, slotFromData.slot, true) end)
	return 0
end

actions.UnJunkItem = function(taskName, itemLinkForSorting, slotFromData, bagFrom, bagTo)
	RbI.ActionQueue.Push(taskName, itemLinkForSorting, -slotFromData.stackCountChange, function() SetItemIsJunk(slotFromData.bag, slotFromData.slot, false) end)
	return 0
end

actions.SellItem = function(taskName, itemLinkForSorting, slotFromData, bagFrom, bagTo)
	RbI.GetLookup(bagFrom, true).SetSlotData(itemLinkForSorting, slotFromData)
	RbI.ActionQueue.Push(taskName, itemLinkForSorting, -slotFromData.stackCountChange, function() SellInventoryItem(slotFromData.bag, slotFromData.slot, -slotFromData.stackCountChange) end)
	RbI.ClearLookup(bagFrom)
	return 0
end

actions.BuyItem = function(taskName, itemLinkForSorting, slotFromData, bagFrom, bagTo)
	local purchaseQuantity = -slotFromData.stackCountChange
	if(purchaseQuantity <= MAX_STORE_WINDOW_STACK_QUANTITY) then
		-- update target bag
		local startingQuantity, slotToDatas = RbI.GetLookup(bagTo, true).GetSlotToDatas(itemLinkForSorting, slotFromData)
		slotFromData.stackCountChange = startingQuantity - purchaseQuantity
		RbI.GetLookup(bagFrom, true).SetSlotData(itemLinkForSorting, slotFromData)
		slotFromData.stackCountChange = -purchaseQuantity -- merchant auto-replenishes their stock

		RbI.ActionQueue.Push(taskName, itemLinkForSorting, purchaseQuantity, function() BuyStoreItem(slotFromData.slot, purchaseQuantity) end)
		RbI.ClearLookup(bagFrom)
		RbI.ClearLookup(bagTo)
	else
		local errorMessage = 'Unconstrained Purchase! Attempt to purchase ' .. tostring(purchaseQuantity) .. ' ' .. itemLinkForSorting .. ', which is more than allowed (' .. tostring(MAX_STORE_WINDOW_STACK_QUANTITY) .. ').'
		RbI.PrintToClipBoard(errorMessage, 'Buy Task')
	end
	return 0
end

actions.FenceItem = function(taskName, itemLinkForSorting, slotFromData, bagFrom, bagTo)
	local stackCountChange = math.min((RbI.fenceTotal - RbI.fenceUsed), -slotFromData.stackCountChange)
	if(stackCountChange > 0) then
		RbI.fenceUsed = RbI.fenceUsed + stackCountChange
		RbI.GetLookup(bagFrom, true).SetSlotData(itemLinkForSorting, slotFromData)
		RbI.ActionQueue.Push(taskName, itemLinkForSorting, stackCountChange, function() SellInventoryItem(slotFromData.bag, slotFromData.slot, stackCountChange) end)
		RbI.ClearLookup(bagFrom)
	end
	return -(slotFromData.stackCountChange + stackCountChange)
end 

actions.LaunderItem = function(taskName, itemLinkForSorting, slotFromData, bagFrom, bagTo)
	local stackCountChange = math.min((RbI.launderTotal - RbI.launderUsed), -slotFromData.stackCountChange)
	if(stackCountChange > 0) then
		RbI.launderUsed = RbI.launderUsed + stackCountChange
		RbI.GetLookup(bagFrom, true).SetSlotData(itemLinkForSorting, slotFromData)
		RbI.ActionQueue.Push(taskName, itemLinkForSorting, -slotFromData.stackCountChange, function() LaunderItem(slotFromData.bag, slotFromData.slot, -slotFromData.stackCountChange) end)
		RbI.ClearLookup(bagFrom)
	end
	return -(slotFromData.stackCountChange + stackCountChange)
end

local markItem = function(taskId, itemLinkForSorting, slotFromData, bagFrom, bagTo, value)
	local iconId = taskId:sub(taskId:find(":")+1)
	local iconNr = RbI.fcois.getNrById(iconId)
	local doUpdateInvNow = true
	RbI.ActionQueue.Push(taskId, itemLinkForSorting, -slotFromData.stackCountChange,
		function()
			FCOIS.MarkItem(slotFromData.bag, slotFromData.slot, iconNr, value, doUpdateInvNow)
			-- TODO: in batchmode doUpdateInvNow should be false. Instead at the end this should be called: FCOIS.FilterBasics(false)
		end
	)
	return 0
end
actions.FCOIS_MarkItem = function(taskId, itemLinkForSorting, slotFromData, bagFrom, bagTo)
	return markItem(taskId, itemLinkForSorting, slotFromData, bagFrom, bagTo, true)
end
actions.FCOIS_UnmarkItem = function(taskId, itemLinkForSorting, slotFromData, bagFrom, bagTo)
	return markItem(taskId, itemLinkForSorting, slotFromData, bagFrom, bagTo, false)
end

local moveItem = function(...)
	if IsProtectedFunction("RequestMoveItem") then
		CallSecureProtected("RequestMoveItem", ...)
	else
		RequestMoveItem(...)
	end
end
actions.MoveItem = function(taskName, itemLinkForSorting, slotFromData, bagFrom, bagTo)
	local remainingAmount, slotToDatas = RbI.GetLookup(bagTo, true).GetSlotToDatas(itemLinkForSorting, slotFromData)
	slotFromData.stackCountChange = slotFromData.stackCountChange + remainingAmount
	RbI.GetLookup(bagFrom, true).SetSlotData(itemLinkForSorting, slotFromData)
	for i, slotToData in ipairs(slotToDatas) do
		RbI.ActionQueue.Push(taskName, itemLinkForSorting, slotToData.stackCountChange, function() moveItem(slotFromData.bag, slotFromData.slot, slotToData.bag, slotToData.slot, slotToData.stackCountChange) end)
	end
	RbI.ClearLookup(bagTo)
	RbI.ClearLookup(bagFrom)
	return remainingAmount
end


actions.DestroyItem = function(taskName, itemLinkForSorting, slotFromData, bagFrom, bagTo)

	-- as ESO can only destroy whole stacks, the entire slot needs to be marked for destroy
	-- this means stack + stackCountChange has to be 0
	-- if the value is greater it means that this amount of leftover items need to be moved elsewhere
	-- therefore this rest becomes moveItem's stackCountChange
	-- this way this slot remains with -(slotFromData.stackCountChange) left, to be destroyed
	-- and the functionality of GetSlotTos does not need to explicitly look for an empty slot
	-- otherwise the perhaps small amount which would be moved to be destroyed would be stacked to another slot
	-- which then needed to be done as often as any stack holds the correct amount to destroy
	-- as only then, for safety reasons, with a new event risen, the slot is destroyed in whole
	-- this is possible due to destroy looking at any stack with the same itemLink instead of slot-based where the event occured

	-- remainingAmount is the amount which would remain after destroy could only and would destroy the stackCountChange it should
	-- if this is > 0 it must be moved away first
	local remainingAmount = slotFromData.stack + slotFromData.stackCountChange

	--d(slotFromData.stack .. "-" .. slotFromData.stackCountChange)
	if(remainingAmount > 0) then
		-- stack size is set according to stackCountChange when executed by MoveItem via lookup's SetSlotData
		slotFromData.stackCountChange = -remainingAmount
		-- Destroy only targets one bag, MoveItem does a stacksplit here
		-- if RbIMoveItem returns non-zero, no slot for stacksplit were found, cancle delete
		if(0 < actions.MoveItem('DestroyMove', itemLinkForSorting, slotFromData, slotFromData.bag, slotFromData.bag)) then
			-- ToDO: add feedback that bag is full and no slot for split
			-- prevent feedback from destroy (nothing was done yet) by returning a "leftover value"
			return remainingAmount
		end
		-- d("split done")
		-- prevent feedback from destroy (nothing was done yet) by returning a "leftover value"
		return remainingAmount
	end
		-- the stack has now exactly the amount it needs to have to destroy it in whole
		RbI.GetLookup(bagFrom, true).SetSlotData(itemLinkForSorting, slotFromData)
		RbI.ActionQueue.Push(taskName, itemLinkForSorting, -slotFromData.stackCountChange, function() DestroyItem(slotFromData.bag, slotFromData.slot) end)
		RbI.ClearLookup(bagFrom)
		-- d("destroy done")
	return 0
end

actions.DeconstructItem = function(taskName, itemLinkForSorting, slotFromData, bagFrom, bagTo)
	local remainingAmount
	--d(slotFromData.itemLink .. " " .. slotFromData.bag .. " " .. slotFromData.slot  .. " " .. -slotFromData.stackCountChange)
	-- d(slotFromData)
	-- SCENE_MANAGER:ShowBaseScene() -- for testing deconstruction cancelling
	if(taskName == 'Refine') then
		local hundrets
		local cnt = -slotFromData.stackCountChange
		-- d(cnt)
		if(RbI.account.settings.maxDeconstruct >= 10) then
			-- Done 10 at a time, so 10*10 = 100, which meets the threshold for allowing hundredths.
			remainingAmount = cnt%100
			hundrets = math.floor((cnt-remainingAmount)/100)
		else
			remainingAmount = cnt
			hundrets = 0
		end
		-- d(remainingAmount)
		-- d(hundrets)
		cnt, remainingAmount = remainingAmount, remainingAmount%10
		-- d(cnt)
		-- d(remainingAmount)
		local tenths = math.floor((cnt-remainingAmount)/10)
		--d('Refine: '..hundrets..' '..tenths)
		-- d(tenths)
		for i=1, hundrets do
			RbI.ActionQueue.Push(taskName, itemLinkForSorting, 100, function() AddItemToDeconstructMessage(slotFromData.bag, slotFromData.slot, 100) end)
			-- d("hundrets")
		end
		for i=1, tenths do
			RbI.ActionQueue.Push(taskName, itemLinkForSorting, 10, function() AddItemToDeconstructMessage(slotFromData.bag, slotFromData.slot, 10) end)
			-- d("tenths")
		end
	else
		-- d("single")
		RbI.ActionQueue.Push(taskName, itemLinkForSorting, -slotFromData.stackCountChange, function() AddItemToDeconstructMessage(slotFromData.bag, slotFromData.slot, 1) end)
		remainingAmount = 0
	end
	
	slotFromData.stackCountChange = slotFromData.stackCountChange + remainingAmount
	RbI.GetLookup(bagFrom, true).SetSlotData(itemLinkForSorting, slotFromData)
	RbI.ClearLookup(bagFrom)

	-- d("rem: " .. remainingAmount)
	return remainingAmount
end

local function canUseGenerally()
	if IsInteractionUsingInteractCamera() then return false end
	local sceneName = SCENE_MANAGER:GetCurrentScene().name
	if sceneName=='interact' or sceneName == 'mailInbox' then return false end
	if GetGameCameraInteractableActionInfo() then return false end -- If the player is about to interact, don't block the interaction.
	if IsUnitSwimming("player") then return false end -- only for fillet a fish!?
	if IsUnitInCombat("player") then return false end -- only for fillet a fish!?
	if not LOOT_WINDOW_FRAGMENT:IsHidden() then return false end -- IsLooting()==true takes too long after loot-failure
	-- IsPlayerMoving() would be only a precondition for fillet a fish, currently we don't increment 'tryTimes' for using a fish
	return true
end

local useItem = function(...)
	if IsProtectedFunction("UseItem") then
		return CallSecureProtected("UseItem", ...)
	else
		return UseItem(...)
	end
end

local currentLootBag
local currentLootSlot
local semaphoreGainedAt
local function gainLootSemaphore(bag, slot)
	local timeElapsedSinceLastGain = GetGameTimeMilliseconds() - (semaphoreGainedAt or 0)
	if(currentLootBag == nil or timeElapsedSinceLastGain > 3000) then
		currentLootBag = bag
		currentLootSlot = slot
	end
	local result = currentLootBag == bag and currentLootSlot == slot
	if(result) then
		semaphoreGainedAt = GetGameTimeMilliseconds()
	end
	return result
end
local function clearLootSemaphore()
	currentLootBag = nil
	currentLootSlot = nil
	RbI.loot = nil
end
actions.UseItem = function(taskName, itemLinkForSorting, slotFromData, bagFrom, bagTo)
	local bag = slotFromData.bag
	local slot = slotFromData.slot
	if(not IsItemUsable(bag, slot)) then return 0 end

	-- ensures that the item we want to use, is still there
	local name = GetItemName(bag, slot)
	local _, stackItemToUse = GetItemInfo(bag, slot)
	local instanceId = GetItemInstanceId(bag, slot)
	local type, _ = GetItemType(bag, slot)
	local withLoot = (type == ITEMTYPE_CONTAINER) or (type == ITEMTYPE_CONTAINER_CURRENCY)
	local function alreadyUsed()
		if(instanceId ~= GetItemInstanceId(bag, slot)) then return true end
		local _, stackCount = GetItemInfo(bag, slot)
		return stackCount < stackItemToUse
	end

	local couldHaveUsed -- will be used when interacting with bank, retrieve and store the usable, so we would skip the action instead of emitting a failure
	local tryTimes = 0
	local useIt
	local wait = function(msecs) RbI.ActionQueue.Push(taskName, itemLinkForSorting, 1, useIt, msecs) return nil end
	useIt = function()
		if(withLoot) then
			if(not gainLootSemaphore(bag, slot)) then return wait(200) end -- another looting is in progress
			local loot = RbI.loot or {}
			if(alreadyUsed() or loot.error) then
				local optMsg
				if(loot.content) then
					optMsg = " (Loot: "..tostring(loot.content)..")"
				end

				if(loot.error) then -- something that prevents a full loot
					local msg = loot.error
					zo_callLater(function() RbI.out.msg(msg) end, 1)
				end

				clearLootSemaphore()
				return couldHaveUsed, optMsg
			end
		else
			if(alreadyUsed()) then return couldHaveUsed end
		end
		if(tryTimes > 4) then
			if(withLoot) then clearLootSemaphore() end
			return tostring(tryTimes)
		end

		local remain, duration = GetItemCooldownInfo(bag, slot)
		if(canUseGenerally()) then
			if(remain == 0) then
				if(withLoot) then
					RbI.lootTime = GetGameTimeMilliseconds()
				end
				-- d("UseCheck: "..itemLinkForSorting..remain.." "..duration.." :: "..GetGameTimeMilliseconds().." "..tostring(IsItemUsable(bag, slot)).." "..tostring(IsItemConsumable(bag, slot)).." "..stackItemToUse)
				useItem(bag, slot)
				couldHaveUsed = true
				remain, duration = GetItemCooldownInfo(bag, slot)
				if(remain > 0 and duration > 0) then
					-- d("Successfully used: "..itemLinkForSorting.." "..RbI.lootTime)
					remain = 0 -- fast recheck
					-- could be unsuccessful (like inventory full or interrupt animation with moving)
					tryTimes = tryTimes + 1
				else -- unsucessful try (like try while moving, recipe already known)
					if(type == ITEMTYPE_FISH) then
						-- ok (like try while moving)
					else -- recipe already known
						tryTimes = tryTimes + 1
					end
				end
			end
		else -- can not use, we wait ~1sec
			remain = 800
		end
		return wait(remain + 200)
	end
	wait() -- no wait, immediate push
	return 0
end