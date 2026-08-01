RemovePotionSound = {}

RemovePotionSound.name = "RemovePotionSound"
RemovePotionSound.version = 1.4

function RemovePotionSound:Initialize()
  local handlers = ZO_AlertText_GetHandlers()

  local function ZO_Alert_Hook_Time(category, soundId, message)
    if message and message ~= "" and message == "Item not ready yet" then
      return true
    end
    return false
  end
  ZO_PreHook("ZO_Alert", ZO_Alert_Hook_Time)

  NOTIFICATIONS:RefreshNotificationList()

  EVENT_MANAGER:UnregisterForEvent(RemovePotionSound.name, EVENT_ADD_ON_LOADED)
end

function RemovePotionSound.OnAddOnLoaded(event, addonName)
  if addonName == RemovePotionSound.name then
    RemovePotionSound:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(RemovePotionSound.name, EVENT_ADD_ON_LOADED, RemovePotionSound.OnAddOnLoaded)
