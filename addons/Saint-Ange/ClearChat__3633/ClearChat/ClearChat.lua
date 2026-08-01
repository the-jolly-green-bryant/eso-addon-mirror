ClearChat = {}
local addon = { name = "ClearChat" }

--------------------------------------------------------------------------------

local function Initialize()
   ZO_CreateStringId("SI_BINDING_NAME_CLEAR_CHAT", "Clear chat")
   SLASH_COMMANDS['/clearchat'] = function()
      CHAT_SYSTEM.primaryContainer.currentBuffer:Clear()
   end
end

local function OnAddonLoaded(_, addonName)
   if addonName ~= addon.name then return end
   Initialize()
   EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)