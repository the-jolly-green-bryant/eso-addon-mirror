QR = QR or {}
local QR = QR

-- This addon is based on Kyoma's Repair and Recharge, removing the options and complexity and having a straight-forward repair-all functionality.

QR.name     = "QcellRepair"
QR.version  = "1.0"
QR.author   = "@Qcell"
QR.active   = false

QR.settings = {
  merchantRepair = true,
  repairKitSaver = false,
  repairKitThreshold = 99,
}

function QR.CommandLine(param)
  local help = "[QR] Usage: /qr {all}, or /qrepair"
  if param == nil or param == "" then
    --d(help)
    QR.RepairItemsWithKits()
  elseif param == "all" then
    d("[QR] Using /qr is the same as /qr all")
    QR.RepairItemsWithKits()
  else
    d(help)
  end
end

local repairKits = {}
function QR.FindRepairKits()
  repairKits = {}
  local bagId = BAG_BACKPACK
  for slotId = 0, GetBagSize(bagId) do
    if IsItemRepairKit(bagId, slotId) then 
      local tier = GetRepairKitTier(bagId, slotId)
      if not repairKits[tier] then repairKits[tier] = {} end
      repairKits[tier][slotId] = (GetSlotStackSize(bagId, slotId))
    end
  end
  return repairKits
end

function QR.GetRepairKitSlot(repairKitTier)
  if repairKits[repairKitTier] then
    for slotId, count in pairs(repairKits[repairKitTier]) do
      return slotId, count, repairKitTier
    end
  elseif Addon.Settings.anyKit then
    --Scan higher tiers first?
    while repairKitTier < 6 do
      repairKitTier = repairKitTier + 1
      if repairKits[repairKitTier] then
        for slotId, count in pairs(repairKits[repairKitTier]) do
          return slotId, count, repairKitTier
        end
      end
    end
  end
end 

function QR.RepairItemWithKit(bagId, slotId)
  local repairKitTier = 6 -- highest tier GetItemLevelTier(bagId, slotId)
  local repaired = false
  local repairKitSlot, repairKitCount, repairKitTier = QR.GetRepairKitSlot(repairKitTier)
  if repairKitSlot then
    RepairItemWithRepairKit(bagId, slotId, BAG_BACKPACK, repairKitSlot)
  end
  -- update next repairKits
  repairKits = QR.FindRepairKits()
end

function QR.RepairItemsWithKits()
  local threshold = 99
  if QR.savedVariables.repairKitThreshold ~= nil and QR.savedVariables.repairKitSaver then
    threshold = QR.savedVariables.repairKitThreshold
  end

  repairKits = QR.FindRepairKits()
  bagId = BAG_WORN -- 0
  local bagSize = GetBagSize(bagId)
  if bagSize == nil or bagSize <= 0 then
    return
  end
  for slotId = 0, bagSize do
    if DoesItemHaveDurability(bagId, slotId) then
      local itemName, itemCondition = GetItemName(bagId, slotId), GetItemCondition(bagId, slotId)
      if itemName ~= nil and itemName ~= "" and itemCondition ~= nil and itemCondition <= threshold then
        QR.RepairItemWithKit(bagId, slotId)
      end
    end
  end
end

function QR.OnOpenStore()
  if QR.savedVariables.merchantRepair then
    local repairCost = GetRepairAllCost()
    if repairCost <= 0 then
    elseif repairCost < GetCurrentMoney() then
      -- not checking <= intentionally, don't want to deal with 0 gold shenanigans.
      RepairAll()
    else
      d("[QR] Cannot afford repair cost of: "..tostring(repairCost).."g")
    end
  end
end

function QR.PlayerActivated()
  QR.active = true
  EVENT_MANAGER:UnregisterForEvent(QR.name .. "OpenStore", EVENT_OPEN_STORE)
  EVENT_MANAGER:RegisterForEvent(QR.name .. "OpenStore", EVENT_OPEN_STORE, QR.OnOpenStore)
end

function QR.OnAddonLoaded(event, addonName)
  if addonName ~= QR.name then
    return
  end
  
  QR.savedVariables = ZO_SavedVars:NewAccountWide("QcellRepairSavedVariables", 1, nil, QR.settings)
  -- Bindings.
  ZO_CreateStringId("SI_BINDING_NAME_QCELL_REPAIR_ALL", "Repair All worn gear")
  

  QR.Menu.AddonMenu()
  SLASH_COMMANDS["/qr"] = QR.CommandLine
  SLASH_COMMANDS["/qrepair"] = QR.CommandLine

  EVENT_MANAGER:UnregisterForEvent(QR.name, EVENT_ADD_ON_LOADED)
  EVENT_MANAGER:RegisterForEvent(QR.name .. "PlayerActive", EVENT_PLAYER_ACTIVATED,
    QR.PlayerActivated)
end


EVENT_MANAGER:RegisterForEvent(QR.name, EVENT_ADD_ON_LOADED, QR.OnAddonLoaded)
