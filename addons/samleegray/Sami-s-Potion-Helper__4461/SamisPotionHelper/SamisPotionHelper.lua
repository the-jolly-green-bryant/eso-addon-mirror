local SPH = SamisPotionHelperAddon
local SAMID = SamisAddonsDebugHelpers
local SPHUtils = SPH.utils

local function iterateThroughEntireBag()
  SAMID:Print("Iterating through entire bag to find potions...")
  local bagId = BAG_BACKPACK
  local slotIndex = ZO_GetNextBagSlotIndex(bagId, 0)
  local totalTrashSellPrice = 0

  while slotIndex do
    if SPHUtils.shouldFlagAsJunk(bagId, slotIndex) then
      local itemLink = GetItemLink(bagId, slotIndex, 1)
      local itemTotalSellPrice = SPHUtils.getItemTotalSellPrice(bagId, slotIndex)
      totalTrashSellPrice = totalTrashSellPrice + itemTotalSellPrice
      SAMID:Print("Marking item as junk: " .. itemLink .. " (Total Sell Price: " .. itemTotalSellPrice .. ")")
      SPHUtils.markItemAsTrash(bagId, slotIndex, itemLink)
    end

    slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)
  end

  SAMID:Print("Finished iterating through bag. Total Trash Sell Price: " .. totalTrashSellPrice)
  return totalTrashSellPrice
end

local function onInventoryStateChange(oldState, newState)
  if newState == SCENE_SHOWING then
    iterateThroughEntireBag()
  end
end

local function onOpenStore(eventCode)
  SAMID:Print("Store opened...")
  if SPH.savedVariables and SPH.savedVariables.autoSellTrash then
    SAMID:Print("Auto-sell enabled, selling junk items...")
    local totalTrashSellPrice = iterateThroughEntireBag()
    SAMID:Print("Total Trash Sell Price: " .. totalTrashSellPrice)
    SellAllJunk()
    SAMID:Print("Finished selling junk items. You earned " .. totalTrashSellPrice .. " gold from selling junk.")
  end
end

function SPH.RegisterEvents()
  local shouldAutoSellTrash = SPH.savedVariables and SPH.savedVariables.autoSellTrash
  if shouldAutoSellTrash then
    EVENT_MANAGER:RegisterForEvent(SPH.name .. "OpenStoreEvent", EVENT_OPEN_STORE, onOpenStore)
  else
    EVENT_MANAGER:UnregisterForEvent(SPH.name .. "OpenStoreEvent", EVENT_OPEN_STORE)
  end
end

local function initialize()
  SPH.savedVariables = ZO_SavedVars:NewAccountWide("SamisPotionHelperSavedVariables", 1, nil, SPH.savedVariableDefaults)

  SAMID:Print("Initializing Samis Potion Helper...")

  SPH.InitializeSettings()
  SPHUtils.syncSavedVarsToUtils()
  SPH.RegisterEvents()
end

local function onAddOnLoaded(_, addonName)
  if addonName ~= SPH.name then
    return
  end

  initialize()

  EVENT_MANAGER:UnregisterForEvent(SPH.name, EVENT_ADD_ON_LOADED)
  SCENE_MANAGER:GetScene("inventory"):RegisterCallback("StateChange", onInventoryStateChange)
end

EVENT_MANAGER:RegisterForEvent(SPH.name, EVENT_ADD_ON_LOADED, onAddOnLoaded)
