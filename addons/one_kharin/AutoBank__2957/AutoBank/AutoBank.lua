AutoBank = {}
AutoBank.name = "AutoBank"


function AutoBank.OnAddOnLoaded(event, addonName)
  if addonName == AutoBank.name then
    AutoBank:Initialize()
  end
end

local function MoveItem(toBagId, fromBagId, fromSlotIndex, stackCount)
    if DoesBagHaveSpaceFor(toBagId, fromBagId, fromSlotIndex) then
        ClearCursor()
        local result = CallSecureProtected("PickupInventoryItem", fromBagId, fromSlotIndex, stackCount)
        if(result == true) then
            result = CallSecureProtected("PlaceInTransfer")
        end
        ClearCursor()
        return result
    end
    return false
end

local function hasItemIn(bagId, targetItemId)
    for slotId = 0, GetBagSize(bagId) do
            local itemId = GetItemId(bagId, slotId)
        if itemId == targetItemId then 
          return true;
        end  
    end
    return false;
end

local function OnOpenBank(eventCode, bankBag)
   if bankBag == BAG_BANK then
        for slotId in pairs(SHARED_INVENTORY.bagCache[BAG_BACKPACK]) do
            local itemId = GetItemId(BAG_BACKPACK, slotId)
            local hasItemInBank = hasItemIn(BAG_BANK, itemId)
            if(hasItemInBank == true) then 
              local link = GetItemLink(BAG_BACKPACK, slotId)
                  local count = GetItemTotalCount(BAG_BACKPACK, slotId)
                  local result = MoveItem(BAG_BANK, BAG_BACKPACK, slotId, count)
                  if(result == true) then
                  	d("["..link .. "] x ".. count .." sended to the bank")
                  else
                   	d("no space in the bank for ["..link .. "] x ".. count)
                  end 

            end
        end
   end
end

function AutoBank:Initialize()
  EVENT_MANAGER:RegisterForEvent(AutoBank.name, EVENT_OPEN_BANK, OnOpenBank)
end
 
EVENT_MANAGER:RegisterForEvent(AutoBank.name, EVENT_ADD_ON_LOADED, AutoBank.OnAddOnLoaded)
