local addonName = 'FishingVibration'
local cnt0 = 0
local function startVibration2()
  SetGamepadVibration(3000, 0.99, 0.50, 1.00, 1.00, "FishingVibration")
  EVENT_MANAGER:UnregisterForUpdate("startVibration2")
end
local function startVibration()
  SetGamepadVibration(180, 0.50, 0.90, 1.00, 1.00, "FishingVibration")
  EVENT_MANAGER:RegisterForUpdate("startVibration2", 250, startVibration2)
end
local function onSlotUpdate(event, bagId, slotIndex, isNew)
  local lure = GetFishingLure()
  local cnt = 0
  if lure then
    cnt = select(3, GetFishingLureInfo(lure))
  else
    cnt = 0
  end
  if( (not isNew and (GetItemType(bagId, slotIndex) == ITEMTYPE_LURE)) and (cnt0 - cnt == 1) )then
    startVibration()
  else
    SetGamepadVibration(0, 0, 0, 0, 0, "FishingVibration")
  end
  cnt0 = cnt
end
local function onLureCleared(event)
  -- d("FV:onLureCleared")
  local lure = GetFishingLure()
  if lure then
    cnt0 = select(3, GetFishingLureInfo(lure))
  end
end
local function onLureSet(event,lure)
  -- d("FV:onLureSet")
  if lure then
    cnt0 = select(3, GetFishingLureInfo(lure))
  end
end
local function onMissingLure(event)
  -- d("FV:onMissingLure")
  local lure = GetFishingLure()
  if lure then
    cnt0 = select(3, GetFishingLureInfo(lure))
  end
end
local function onCannotFish(event)
  -- d("FV:onCannotFish")
end

local function eventRegister()
  EVENT_MANAGER:RegisterForEvent(addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onSlotUpdate)
  
  EVENT_MANAGER:RegisterForEvent(addonName, EVENT_FISHING_LURE_CLEARED, onLureCleared)
  EVENT_MANAGER:RegisterForEvent(addonName, EVENT_FISHING_LURE_SET, onLureSet)
  -- EVENT_MANAGER:RegisterForEvent(addonName, EVENT_MISSING_LURE, onMissingLure)
  -- EVENT_MANAGER:RegisterForEvent(addonName, EVENT_CANNOT_FISH_WHILE_SWIMMING, onCannotFish)
end
local function onLoaded( event, addon )
  if ( addon ~= addonName ) then return end
    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
    eventRegister()
  local lure = GetFishingLure()
  if lure then
    cnt0 = select(3, GetFishingLureInfo(lure))
  end
end
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED,onLoaded)
--[[
local function cmd(value)
  if (value == "test") then
    SetGamepadVibration(2000, 1, 1, 1, 1, "")
  elseif (value == "stop") then
    SetGamepadVibration(0, 0, 0, 0, 0, "")
  else
    d("FishingVibration")
  end
end
SLASH_COMMANDS["/fv"] = cmd
--]]