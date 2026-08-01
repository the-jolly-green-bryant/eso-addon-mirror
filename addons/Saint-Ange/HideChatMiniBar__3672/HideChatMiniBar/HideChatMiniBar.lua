HideChatMiniBar = {}
local addon = { name = "HideChatMiniBar", author = "Saint-Ange", version = "1.1.1"  }

--------------------------------------------------------------------------------

local function Initialize()
   ZO_ChatWindowNotifications:SetHidden(true)
   ZO_ChatWindowNumNotifications:SetHidden(true)
   ZO_ChatWindowMinBar:SetAlpha(0)
end

local function OnAddonLoaded(_, addonName)
   if addonName ~= addon.name then return end
   Initialize()
   EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)