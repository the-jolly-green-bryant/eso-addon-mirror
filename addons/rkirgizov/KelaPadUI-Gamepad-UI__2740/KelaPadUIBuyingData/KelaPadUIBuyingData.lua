local KelaPadUIBuyingData = {
	name = "KelaPadUIBuyingData",	
}

KELA_BUYING_DATA_RETENTION_PERIOD = 30
KELA_ITEMDATA_WITH_COUNTCHANGE = {}

-- запоминаем цену покупки
function KelaAddToBuyingUniqueTable(uniqueId, itemName, buyPrice, buyPricePerUnit, listingIndex, displayQuality)
	local kelaPlayerAccountName = GetUnitDisplayName('player')
	local guildName = ""
	itemUID = Id64ToString(uniqueId)
	buyingTimeStamp = GetTimeStamp()
	currentGuildId = GetSelectedTradingHouseGuildId()
	if currentGuildId then 
		_, guildName = GetCurrentTradingHouseGuildDetails()
	end

	KelaSetValueIfNil(kpuiSVBuyingData["buyingTable"], itemUID, {})
	kpuiSVBuyingData["buyingTable"][itemUID] = {
		["buyingTimeStamp"] = buyingTimeStamp,
		["guildName"] = guildName,
		["itemName"] = itemName, 	-- tempo
		["displayQuality"] = displayQuality, 	
		["buyPrice"] = buyPrice,
		["buyPricePerUnit"] = buyPricePerUnit,
		}
end	

-- очищаем старые записи
local function CheckingForRetentionPeriod()
	local checkingTimeStamp = GetTimeStamp() - (KELA_BUYING_DATA_RETENTION_PERIOD * ZO_ONE_DAY_IN_SECONDS)
	
	if next(kpuiSVBuyingData["buyingTable"]) ~= nil then
		for itemUID, data in pairs(kpuiSVBuyingData["buyingTable"]) do
			if data["buyingTimeStamp"] < checkingTimeStamp then 
				kpuiSVBuyingData["buyingTable"][itemUID] = nil
			end
		end	
	end
end

local function _onInventoryChanged(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
	local link = GetItemLink(bagId, slotIndex)
	-- обнуляем временное хранилище
	local function ClearData ()
		KELA_ITEMDATA_WITH_COUNTCHANGE = {}	
	end
	if not isNewItem and stackCountChange > 0 then
		local uniqueId = GetItemUniqueId(bagId, slotIndex)
		local itemUID = Id64ToString(uniqueId)
		local itemName = GetItemName(bagId, slotIndex)
		if next(kpuiSVBuyingData["buyingTable"]) ~= nil then
			for uid, data in pairs(kpuiSVBuyingData["buyingTable"]) do
				if data["itemName"] == itemName then 
					KELA_ITEMDATA_WITH_COUNTCHANGE = {
						["itemUID"] = itemUID,
						["link"] = link,
						["itemName"] = itemName,
						}
				end
			end	
		end		
	elseif not isNewItem and stackCountChange < 0 then
		if next(KELA_ITEMDATA_WITH_COUNTCHANGE) ~= nil and KELA_ITEMDATA_WITH_COUNTCHANGE["link"] == link then
			if next(kpuiSVBuyingData["buyingTable"]) ~= nil then
				for uid, data in pairs(kpuiSVBuyingData["buyingTable"]) do
					-- CHAT_SYSTEM:AddMessage(tostring(KELA_ITEMDATA_WITH_COUNTCHANGE["itemName"])..tostring(data["itemName"]))
					if data["itemName"] == KELA_ITEMDATA_WITH_COUNTCHANGE["itemName"] then 
						local newItemUID = KELA_ITEMDATA_WITH_COUNTCHANGE["itemUID"]
						KelaSetValueIfNil(kpuiSVBuyingData["buyingTable"], newItemUID, {})
						kpuiSVBuyingData["buyingTable"][newItemUID] = data
					end
				end	
			end			
		end
		ClearData ()
	else
		ClearData ()
	end
end

local function onAddOnLoaded(eventCode, addonName)
    if (addonName ~= KelaPadUIBuyingData.name) then
        return
    end

	if TamrielTradeCentre ~= nil and ArkadiusTradeTools ~= nil then

		kpuiSVBuyingData = ZO_SavedVars:NewAccountWide('kpuiSavedVariablesBuyingData', 0.10, nil, {})

		-- kpuiSVBuyingData["buyingTable"] = nil
		KelaSetValueIfNil(kpuiSVBuyingData, "buyingTable", {})
		CheckingForRetentionPeriod()
		 
		EVENT_MANAGER:RegisterForEvent("KelaPadUIBuyingData.name".."InventorySlotUpdated", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, _onInventoryChanged)
		EVENT_MANAGER:AddFilterForEvent("KelaPadUIBuyingData.name".."InventorySlotUpdated", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
	end
	
    EVENT_MANAGER:UnregisterForEvent(KelaPadUIBuyingData.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(KelaPadUIBuyingData.name, EVENT_ADD_ON_LOADED, onAddOnLoaded)
