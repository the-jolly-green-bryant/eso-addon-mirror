

local UHS_Events = { name = "UnDeadHarvest" }

function UHS_Events.OnAddOnLoaded(_, addonName)
	if addonName == UHS_Events.name then UnDeadHarvest:Initialize() end
end

function UHS_Events.IDLog(itemId, itemLink)
	d(string.format("\n\n|c00cc99New Name =|r %s\n|c00cc99New ID =|r %s", tostring(itemLink), tostring(itemId)))
end

function UHS_Events.LootReceived(_, receivedBy, itemLink, quantity, _, _, _, _, _, itemId, _)
	local characterName = GetUnitName("player")
	if type(receivedBy) == "string" and type(characterName) == "string" and receivedBy:sub(1, #characterName) == characterName then
		--d("Loot received by: " .. tostring(receivedBy) .. " | ItemLink: " .. tostring(itemLink) .. " | Quantity: " .. tostring(quantity) .. " | ItemID: " .. tostring(itemId))
		--d("Character: " .. tostring(characterName))
		UnDeadHarvest.UpdateGain(itemId, quantity)
		if UHS_Data.Saved.IDLog then UHS_Events.IDLog(itemId, itemLink) end
		if GetItemLinkItemType(itemLink) == 54 and quantity > 0 then UnDeadHarvest.GetFish(quantity) end
		UnDeadHarvest.RefreshLabels()
	end
end

function UHS_Events.OnMoneyUpdate(_, newMoney, oldMoney, _)
	local goldChange = (newMoney or 0) - (oldMoney or 0)
	if goldChange > 0 then
		UHS_Data.Saved.Items.Gold[ITEM_GAIN] = (UHS_Data.Saved.Items.Gold[ITEM_GAIN] or 0) + goldChange
		UnDeadHarvest.RefreshLabels()
	end
end

function UHS_Events.OnAPUpdate(_, _, _, difference, _)
	if difference and difference > 0 then
		UHS_Data.Saved.Items.AP[ITEM_GAIN] = (UHS_Data.Saved.Items.AP[ITEM_GAIN] or 0) + difference
		UnDeadHarvest.RefreshLabels()
	end
end

function UHS_Events.OnTVUpdate(_, newTelvarStones, oldTelvarStones, _)
	local tvChange = (newTelvarStones or 0) - (oldTelvarStones or 0)
	local totalTV = GetCurrencyAmount(CURT_TELVAR_STONES, CURRENCY_LOCATION_CHARACTER)
	if tvChange ~= totalTV and tvChange > 0 then
		UHS_Data.Saved.Items.TelVar[ITEM_GAIN] = (UHS_Data.Saved.Items.TelVar[ITEM_GAIN] or 0) + tvChange
		UnDeadHarvest.RefreshLabels()
	end
end

EVENT_MANAGER:RegisterForEvent(UHS_Events.name, EVENT_ADD_ON_LOADED, UHS_Events.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(UHS_Events.name, EVENT_LOOT_RECEIVED, UHS_Events.LootReceived)
EVENT_MANAGER:RegisterForEvent(UHS_Events.name, EVENT_MONEY_UPDATE, UHS_Events.OnMoneyUpdate)
EVENT_MANAGER:RegisterForEvent(UHS_Events.name, EVENT_ALLIANCE_POINT_UPDATE, UHS_Events.OnAPUpdate)
EVENT_MANAGER:RegisterForEvent(UHS_Events.name, EVENT_TELVAR_STONE_UPDATE, UHS_Events.OnTVUpdate)
