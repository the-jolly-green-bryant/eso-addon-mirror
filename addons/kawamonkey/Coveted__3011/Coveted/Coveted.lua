local wayshrines = {
	177, -- Vulkhel Guard, Auridon
	214, -- Elden Root, Grahtwood
	143, -- Marbruk, Greenshade
	106, -- Baandari Trading Post, Malabal Tor
	162, -- Rawl'kha, Reaper's March

	62, -- Daggerfall, Glenumbra
	56, -- Wayrest, Stormhaven
	55, -- Shornhelm, Rivenspire
	43, -- Sentinel, Alik'r Desert
	33, -- Evermore, Bangkorai
	
	65, -- Davon's Watch, Stonefalls
	28, -- Mournhold, Deshaan
	48, -- Stormhold, Shadowfen
	87, -- Windhelm, Eastmarch
	109, -- Riften, The Rift
}

function IsCovetedItem(itemLink)
	if GetItemLinkItemType(itemLink) == ITEMTYPE_TREASURE and GetItemLinkQuality(itemLink) == ITEM_QUALITY_NORMAL then
		local numItemTags = GetItemLinkNumItemTags(itemLink)

		if numItemTags > 0 then
			for i = 1, numItemTags do
				local itemTag = GetItemLinkItemTagInfo(itemLink, i)

				for type = 1, 14 do
					if itemTag == GetString("SI_COVETEDTREASURETYPE", type) then
						return true
					end
				end
			end
		end
	end

	return false
end

local function OnLootUpdated()
	local stealthState = GetUnitStealthState("player")
	local numLootItems = GetNumLootItems()

	for i = 1, numLootItems do
		local lootId, _, _, _, _, _, _, stolen = GetLootItemInfo(i)
		local itemLink = GetLootItemLink(lootId)

		if IsCovetedItem(itemLink) and (not stolen or (stealthState ~= STEALTH_STATE_NONE and stealthState ~= STEALTH_STATE_DETECTED)) then
			LootItemById(lootId)
		end
	end
end

local function OnFenceOpened(_, _, enableLaunder)
	if enableLaunder then
		for slotIndex in ZO_IterateBagSlots(BAG_BACKPACK) do
			if IsItemStolen(BAG_BACKPACK, slotIndex) and IsCovetedItem(GetItemLink(BAG_BACKPACK, slotIndex)) then
				local totalLaunders, laundersUsed = GetFenceLaunderTransactionInfo()
				local laundersLeft = totalLaunders - laundersUsed
				local stackSize = GetSlotStackSize(BAG_BACKPACK, slotIndex)

				if laundersLeft == 0 then
					break
				elseif laundersLeft < stackSize then
					LaunderItem(BAG_BACKPACK, slotIndex, laundersLeft)
					break
				elseif laundersLeft == stackSize then
					LaunderItem(BAG_BACKPACK, slotIndex, stackSize)
					break
				else
					LaunderItem(BAG_BACKPACK, slotIndex, stackSize)
				end
			end
		end
	end
end

local function OnFastTravelInteraction()
	for i = 1, MAX_JOURNAL_QUESTS do
		local questName, _, _, _, _, completed, tracked = GetJournalQuestInfo(i)

		if tracked then
			if questName == GetString(SI_COVETOUS_COUNTESS) then
				if completed then
					FastTravelToNode(255)
				else
					local conditionText, current, max = GetJournalQuestConditionInfo(i)

					if current == max then
						for _, nodeIndex in ipairs(wayshrines) do
							if string.match(conditionText, GetString("SI_COVETEDWAYSHRINE", nodeIndex)) then
								FastTravelToNode(nodeIndex)
								return
							end
						end
					end
				end
			end
	
			return
		end
	end
end

ZO_PostHook(
	INTERACTION,
	"PopulateChatterOption",
	function (self, _, _, _, optionType)
		local name = select(2, GetGameCameraInteractableActionInfo())

		if name == GetString(SI_COUNTESS_VIATRIX_CELETA) then
			if optionType ~= CHATTER_GOODBYE then
				for i = 1, 2 do
					self:SelectChatterOptionByIndex(1)
				end
			end
		elseif name == GetString(SI_KARI) then
			if optionType == CHATTER_START_COMPLETE_QUEST or optionType == CHATTER_COMPLETE_QUEST then
				self:SelectChatterOptionByIndex(1)
			end
		elseif name == GetString(SI_TIP_BOARD) then
			local questName = GetOfferedQuestInfo()

			if string.sub(questName, 2, 17) == GetString(SI_ESTEEMED_THIEVES) then
				for i = 1, 5 do
					self:SelectChatterOptionByIndex(1)
				end
			else
				EndInteraction(INTERACTION_QUEST)
			end
		end
	end
)

EVENT_MANAGER:RegisterForEvent("Coveted", EVENT_LOOT_UPDATED, OnLootUpdated)
EVENT_MANAGER:RegisterForEvent("Coveted", EVENT_OPEN_FENCE, OnFenceOpened)
EVENT_MANAGER:RegisterForEvent("Coveted", EVENT_START_FAST_TRAVEL_INTERACTION, OnFastTravelInteraction)