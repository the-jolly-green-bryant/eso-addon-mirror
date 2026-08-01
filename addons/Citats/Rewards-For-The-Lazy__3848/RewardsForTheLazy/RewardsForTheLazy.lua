RewardsForTheLazy = {}
RewardsForTheLazy.name = "RewardsForTheLazy"

function RewardsForTheLazy.OnAddOnLoaded(event, addonName)
	if addonName == RewardsForTheLazy.name then
		RewardsForTheLazy.Initialize()
	end
end

function RewardsForTheLazy.Initialize()
	RewardsForTheLazy.ClearingMail = false
	EVENT_MANAGER:UnregisterForEvent(RewardsForTheLazy.name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(RewardsForTheLazy.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, RewardsForTheLazy.OnInventoryChanged)
	RewardsForTheLazy.DeleteQueue = {}
	RewardsForTheLazy.UnboxQueue = {}
	RewardsForTheLazy.TimeLastCleared = 0
	SLASH_COMMANDS["/clearmail"] = RewardsForTheLazy.ClearMail
end

function RewardsForTheLazy.ClearMail()
	if RewardsForTheLazy.ClearingMail then
		d("Already clearing mail...")
		return
	end
	
	local waited = GetFrameTimeMilliseconds() - RewardsForTheLazy.TimeLastCleared
	
	if waited < 15000 then
		d("Cleared too recently, please wait " .. 15 - math.floor(waited / 1000) .. " more seconds...")
		return
	end
	
	RewardsForTheLazy.TimeLastCleared = GetFrameTimeMilliseconds()
	
	local usedSlots, maxSlots = PLAYER_INVENTORY:GetNumSlots(INVENTORY_BACKPACK)
	local freeSlots = maxSlots - usedSlots

	if freeSlots < 5 then
		d("You must have at least 5 free inventory slots.")
		return
	end

	RewardsForTheLazy.ClearingMail = true
	RewardsForTheLazy.RftwCount = 0
	RewardsForTheLazy.CurrentProgress = 0
	RewardsForTheLazy.MaxProgress = 0
	RewardsForTheLazy.CurrentPercent = 0
	
	d("Started clearing mail. Please wait...")
	
	SCENE_MANAGER:Show("mailInbox")
	
	zo_callLater(function() RewardsForTheLazy.ClearMail2() end, 2000)
end

function RewardsForTheLazy.ClearMail2()
	local rootNode = MAIL_INBOX.navigationTree.rootNode
	local listNodes = rootNode:GetChildren()
	
	if listNodes == nil then
		RewardsForTheLazy.ClearingMail = false
		d("Mail did not successfully initialize. Please try again.")
		return
	end
	
	RewardsForTheLazy.MailNodes = {}
    for listNodeKey, listNodeValue in ipairs(listNodes) do
		if listNodeKey == 2 then
			local mailNodes = listNodeValue:GetChildren()
			
			if mailNodes and #mailNodes ~= 0 then
				local itemCount = #mailNodes
				for mailNodeKey, mailNodeValue in ipairs(mailNodes) do
					RewardsForTheLazy.MailNodes[itemCount + 1 - mailNodeKey] = mailNodeValue
					RewardsForTheLazy.MaxProgress  = RewardsForTheLazy.MaxProgress + 1
				end
			end
		end
    end
	
	RewardsForTheLazy.MaxProgress = RewardsForTheLazy.MaxProgress
	
	d("Clearing mail: 0%")
	RewardsForTheLazy.DoMailClearAll()
end

function RewardsForTheLazy.DoMailClearAll()
	--if RewardsForTheLazy.RftwCount > 3 then
	--	zo_callLater(function() RewardsForTheLazy.FinishClearingMail() end, 1000)
	--	return
	--end
	
	local found = false
	
	if RewardsForTheLazy.MailNodes and #RewardsForTheLazy.MailNodes ~= 0 then
		for mailNodeKey, mailNodeValue in pairs(RewardsForTheLazy.MailNodes) do
			RewardsForTheLazy.CurrentProgress = RewardsForTheLazy.CurrentProgress + 1
			local percent = math.floor((RewardsForTheLazy.CurrentProgress * 10) / RewardsForTheLazy.MaxProgress) * 10
			if percent > RewardsForTheLazy.CurrentPercent then
				RewardsForTheLazy.CurrentPercent = percent
				d("Clearing mail: " .. percent .. "%")
			end
			table.remove(RewardsForTheLazy.MailNodes, mailNodeKey)
			if mailNodeValue.data.mailId ~= nil and mailNodeValue.data.isFromPlayer == false and mailNodeValue.data.subject == "Rewards for the Worthy!" then
				--d("found rftw ".. mailNodeValue.data.mailId)
				RequestReadMail(mailNodeValue.data.mailId)
				found = true
				RewardsForTheLazy.RftwCount = RewardsForTheLazy.RftwCount + 1
				--TakeMailAttachedMoney(mailNodeValue.data.mailId)
				--TakeMailAttachedItems(mailNodeValue.data.mailId)
				--DeleteMail(mailNodeValue.data.mailId, true)
				TakeMailAttachments(mailNodeValue.data.mailId, true)
				break
			end
		end
	end
	
	if found == false then
		zo_callLater(function() RewardsForTheLazy.FinishClearingMail() end, 2000)
	else
		zo_callLater(function() RewardsForTheLazy.DoInventoryClear() end, 150)
	end
end

function RewardsForTheLazy.FinishClearingMail()
	RewardsForTheLazy.ClearingMail = false
	d("Finished clearing mail.")
end

function RewardsForTheLazy.DoInventoryClear()
	if #RewardsForTheLazy.DeleteQueue > 0 then
		local deleted = table.remove(RewardsForTheLazy.DeleteQueue, 1)
		DestroyItem(deleted.bagId, deleted.slotIndex)
		zo_callLater(function() RewardsForTheLazy.DoInventoryClear() end, 1)
	elseif #RewardsForTheLazy.UnboxQueue > 0 then
		local test = RewardsForTheLazy.UnboxQueue[1]
		if GetInteractionType() == 0 and not IsLooting() and CanInteractWithItem(test.bagId, test.slotIndex) then
			local deleted = table.remove(RewardsForTheLazy.UnboxQueue, 1)
			CallSecureProtected("UseItem", deleted.bagId, deleted.slotIndex)
		end
		zo_callLater(function() RewardsForTheLazy.DoInventoryClear() end, 1000)
	else
		zo_callLater(function() RewardsForTheLazy.DoMailClearAll() end, 1)
	end
end

function RewardsForTheLazy.OnInventoryChanged(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
	if RewardsForTheLazy.ClearingMail == false then
		return
	end
   
	local link = GetItemLink(bagId, slotIndex)
	local id = GetItemLinkItemId(link)
	
	--d("id: " .. id .. "; link: " .. link)
	
	if id == 0 then --nothing
	
	elseif id == 141731 then --stone
		--d("ID for stone is: " .. id) 
	elseif id == 194353 then --rftw
		RewardsForTheLazy.AddToDeleteQueue(bagId, slotIndex)
		--RewardsForTheLazy.AddToUnboxQueue(bagId, slotIndex)
		--d("Added " .. link .. " to unbox queue.")
	elseif id == 204404 then --rftw2
		RewardsForTheLazy.AddToDeleteQueue(bagId, slotIndex)
		--RewardsForTheLazy.AddToUnboxQueue(bagId, slotIndex)
		--d("Added " .. link .. " to unbox queue.")
	elseif id == 210866 then --rftw_2024-11-08
		RewardsForTheLazy.AddToDeleteQueue(bagId, slotIndex)
		--RewardsForTheLazy.AddToUnboxQueue(bagId, slotIndex)
		--d("Added " .. link .. " to unbox queue.")
	elseif id == 214239 then --rftw_2025-03-13
		RewardsForTheLazy.AddToDeleteQueue(bagId, slotIndex)
		--RewardsForTheLazy.AddToUnboxQueue(bagId, slotIndex)
		--d("Added " .. link .. " to unbox queue.")
	elseif id == 219651 then --rftw_2025-08-31
		RewardsForTheLazy.AddToDeleteQueue(bagId, slotIndex)
		--RewardsForTheLazy.AddToUnboxQueue(bagId, slotIndex)
		--d("Added " .. link .. " to unbox queue.")
	elseif id == 192612 then --pelinal's
		RewardsForTheLazy.AddToDeleteQueue(bagId, slotIndex)
		--d("Added " .. link .. " to delete queue.")
	elseif id == 204459 then --jubilee
		RewardsForTheLazy.AddToDeleteQueue(bagId, slotIndex)
		--d("Added " .. link .. " to delete queue.")
	elseif id == 134618 then --geode
		--RewardsForTheLazy.AddToUnboxQueue(bagId, slotIndex)
		--d("Added " .. link .. " to unbox queue.")
	else
		--RewardsForTheLazy.AddToDeleteQueue(bagId, slotIndex)
		--d("Delete queued it.")
	end
end

function RewardsForTheLazy.AddToUnboxQueue(myBagId, mySlotIndex)
	table.insert(RewardsForTheLazy.UnboxQueue, {bagId = myBagId, slotIndex = mySlotIndex})
end

function RewardsForTheLazy.AddToDeleteQueue(myBagId, mySlotIndex)
	table.insert(RewardsForTheLazy.DeleteQueue, {bagId = myBagId, slotIndex = mySlotIndex})
end

EVENT_MANAGER:RegisterForEvent(RewardsForTheLazy.name, EVENT_ADD_ON_LOADED, RewardsForTheLazy.OnAddOnLoaded)