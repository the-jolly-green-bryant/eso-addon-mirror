local settings = nil

local function OnInventorySlotUpdate(eventCode, bagID, slotID)
	local convert = nil

	if settings:ShouldConvertOnEquip() then
		convert = BAG_WORN
	else
		convert = BAG_BACKPACK
	end

	if bagID == convert then
		if CanConvertItemStyleToImperial(bagID, slotID) then
			local itemStyle = select(7, GetItemInfo(bagID, slotID))
			local itemStyleString = GetString("SI_ITEMSTYLE", itemStyle)
			if settings:ShouldConvertStyle(itemStyleString) then
				if settings:ShouldDisplayResults() then
					d(zo_strformat("<<t:1>> converted from the <<2>> style!", GetItemLink(bagID, slotID,
						LINK_STYLE_BRACKETS), itemStyleString))
				end
				ConvertItemStyleToImperial(bagID, slotID)
			end
		end
	end
end

local function ImperializationLoaded(eventCode, addonName)
	if addonName ~= "Imperialization" then return end
	EVENT_MANAGER:UnregisterForEvent("ImperializationLoaded", EVENT_ADD_ON_LOADED)

	settings = ImperializationSettings:New()

	EVENT_MANAGER:RegisterForEvent("ImperializationOnInvSlotUpdated",
		EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySlotUpdate)

	d("Imperialization loaded.")
end

EVENT_MANAGER:RegisterForEvent("ImperializationLoaded", EVENT_ADD_ON_LOADED, ImperializationLoaded)
