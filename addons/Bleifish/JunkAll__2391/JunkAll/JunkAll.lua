--[[--------------------------------------------------------
	JunkAll
------------------------------------------------------------
	* AddOn to send new items into the junk-bag.
	*
	* Author: @Bleifish
	*
]]----------------------------------------------------------

JunkAll = {}
JunkAll.name = "JunkAll"
JunkAll.version = "1.1.1"

--number eventCode, Bag bagId, number slotId, boolean isNewItem, ItemUISoundCategory itemSoundCategory, number inventoryUpdateReason, number stackCountChange
function JunkAll.OnSingleSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
	if isNewItem and inventoryUpdateReason == 0 and stackCountChange > 0 then	    
		local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality = GetItemInfo(bagId, slotId)
		if stack == stackCountChange or stack == 1 then
			SetItemIsJunk( bagId, slotId, true )
		end
	end
end

function OnAddOnLoaded(eventCode, addOnName)
	if(addOnName == JunkAll.name) then
		EVENT_MANAGER:RegisterForEvent(JunkAll.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, JunkAll.OnSingleSlotUpdate)
	end
end

EVENT_MANAGER:RegisterForEvent(JunkAll.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
