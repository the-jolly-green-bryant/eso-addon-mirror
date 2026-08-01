local function OnLoad(eventCode, addOnName)
  if (addOnName == YADE.addonname) then
    EVENT_MANAGER:UnregisterForEvent(YADE.addonName, EVENT_ADD_ON_LOADED)
    YADE.init()
  end
end

EVENT_MANAGER:RegisterForEvent(YADE.addonname, EVENT_ADD_ON_LOADED, OnLoad)
