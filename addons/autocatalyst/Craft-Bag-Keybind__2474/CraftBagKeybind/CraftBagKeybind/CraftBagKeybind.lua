CraftBagKeybind = {}

local ADDON_NAME = 'CraftBagKeybind'

-- EVENT_ADD_ON_LOADED
local function OnAddOnLoaded(event, addonName)
  if (addonName ~= ADDON_NAME) then
      return
  end
  
  ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_AUTOADD_TO_CRAFT_BAG", "Toggle Auto-Add to Craft Bag")
  EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

-- Binding
function CraftBagKeybind:Switch()
    local newState = 1 - GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_ADD_TO_CRAFT_BAG)
    SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_ADD_TO_CRAFT_BAG, newState)
    -- set up for chat relay
    CraftBagKeybind:SendToChat()
end

-- Chat notifications
function CraftBagKeybind:SendToChat()
  if GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_ADD_TO_CRAFT_BAG) == '1' then 
    d('Auto-Add to Craft Bag Enabled')
  else 
    d('Auto-Add to Craft Bag Disabled')
  end
end

-- Load Event Manager
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
--end