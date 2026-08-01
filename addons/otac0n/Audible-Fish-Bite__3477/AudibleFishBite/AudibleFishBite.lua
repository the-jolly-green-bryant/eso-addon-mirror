EVENT_MANAGER:RegisterForEvent(AudibleFishBite.ADDON_NAME, EVENT_ADD_ON_LOADED, function (eventCode, name)
  if name ~= AudibleFishBite.ADDON_NAME then return end
  AudibleFishBite:Initialize()
  EVENT_MANAGER:UnregisterForEvent(AudibleFishBite.ADDON_NAME, EVENT_ADD_ON_LOADED)
end)

function AudibleFishBite:Initialize()
  AudibleFishBite:InitializeSettings()
  AudibleFishBite:InitializeStateMachine()
  AudibleFishBite.settingsMenu = AudibleFishBiteSettingsMenu:New()
end

local states = {
    none = 0,
    fishing = 1,
    bite = 2,
}
function AudibleFishBite:InitializeStateMachine()
  local state = states.none

  EVENT_MANAGER:RegisterForEvent(AudibleFishBite.ADDON_NAME .. "EVENT_INVENTORY_SINGLE_SLOT_UPDATE", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
    if state == states.fishing then
      state = states.bite
      PlaySound(AudibleFishBite.soundVars.SoundFile)
      EVENT_MANAGER:RegisterForUpdate(AudibleFishBite.ADDON_NAME .. "TIMEOUT", 3000, function()
        EVENT_MANAGER:UnregisterForUpdate(AudibleFishBite.ADDON_NAME .. "TIMEOUT")
        if state == states.bite then
          state = states.none
        end
      end)
    elseif state == states.bite then
      EVENT_MANAGER:UnregisterForUpdate(AudibleFishBite.ADDON_NAME .. "TIMEOUT")
      state = states.none
    end
  end)

  local mostRecentFishingNode
  local function OnShowOrHide()
    local action, interactableName, _, _, additionalInfo = GetGameCameraInteractableActionInfo()
    if action then
      if additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE then
        mostRecentFishingNode = interactableName
        state = states.none
      elseif interactableName == mostRecentFishingNode and state == states.none then
        state = states.fishing
      end
    else
        state = states.none
    end
  end

  ZO_PreHookHandler(RETICLE.interact, "OnEffectivelyShown", OnShowOrHide)
  ZO_PreHookHandler(RETICLE.interact, "OnHide", OnShowOrHide)
end
