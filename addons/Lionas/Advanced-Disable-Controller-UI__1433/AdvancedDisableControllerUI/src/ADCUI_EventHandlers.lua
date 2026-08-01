-- Advanced Disable Controller UI
-- Author: Lionas, Setsu

if not ADCUI.isDefined then return end

	
-- handling lockpicking
local function onStartLockPicking()
  ADCUI.vars.isLockpicking = true
end

local function onFinishLockPicking()
  ADCUI.vars.isLockpicking = false
end

-- onCraftStationInteract
local function onCraftStationInteract(eventCode, craftSkill)  
  -- Prevent ESO UI bug -- interaction freezing
  CALLBACK_MANAGER:FireCallbacks("CraftingAnimationsStopped") 
end

local function OnTransmuteStationInteract(eventCode, responseCode)
  -- fix freezing after transmute
  CALLBACK_MANAGER:FireCallbacks("CraftingAnimationsStopped")
end


EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME, EVENT_BEGIN_LOCKPICK, onStartLockPicking)
EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME, EVENT_LOCKPICK_FAILED, onFinishLockPicking)
EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME, EVENT_LOCKPICK_SUCCESS, onFinishLockPicking)
EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME, EVENT_CRAFT_COMPLETED, onCraftStationInteract)
EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME, EVENT_RETRAIT_RESPONSE, OnTransmuteStationInteract)