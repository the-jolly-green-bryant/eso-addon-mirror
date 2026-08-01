local function OnAddOnLoaded(eventCode, addOnName)
  if(addOnName == ItemConditionAlert.Name) then
        EVENT_MANAGER:UnregisterForEvent(ItemConditionAlert.Name, eventCode)
        ItemConditionAlert:Init()
  end
end

EVENT_MANAGER:RegisterForEvent(ItemConditionAlert.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)