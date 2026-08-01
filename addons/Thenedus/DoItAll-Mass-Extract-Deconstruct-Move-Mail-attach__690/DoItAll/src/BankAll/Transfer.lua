DoItAll = DoItAll or {}

local function IsShowingBank()
  return BANK_FRAGMENT.state == SCENE_SHOWN
end
local function IsShowingInventory()
  return INVENTORY_FRAGMENT.state == SCENE_SHOWN
end

local errorMessage = nil
local function TransferItem(slot)
  local targetContainer = slot.bagId == BAG_BACKPACK and (BAG_BANK or BAG_SUBSCRIBER_BANK) or BAG_BACKPACK
  --Subscriber bank introduced with Morrowind patch
  --Is the user an ESO+ subscriber
  local isEsoPlusSubscriber = IsESOPlusSubscriber() or false
  if isEsoPlusSubscriber and targetContainer == BAG_BANK then
    --Check bag space. If it's full change to the subscriber bank, if given
    if not DoesBagHaveSpaceFor(BAG_BANK, slot.bagId, slot.slotIndex) then
      targetContainer = BAG_SUBSCRIBER_BANK
    end
  end
  if DoesBagHaveSpaceFor(targetContainer, slot.bagId, slot.slotIndex) then
    CallSecureProtected("PickupInventoryItem", slot.bagId, slot.slotIndex)
    CallSecureProtected("PlaceInTransfer")
  else
    errorMessage = targetContainer == BAG_BACKPACK and SI_INVENTORY_ERROR_INVENTORY_FULL or SI_INVENTORY_ERROR_BANK_FULL
  end
  return true
end

local function ReportError()
  ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, errorMessage)
end

local function TransferBatch(slotsAll)
  local slotsBatch = DoItAll.Slots:New(DoItAll.ItemFilter:New(false, "BANK_DEPOSIT"))
  if not slotsBatch:Take(slotsAll, DoItAll.Settings.GetBatchSize()) then return end
  
  if slotsBatch:ForEach(TransferItem) then
    zo_callLater(function() TransferBatch(slotsAll) end, DoItAll.Settings.GetBatchDelay())
  end
end

local function TransferAll(container)
  errorMessage = nil
  
  local slotsAll = DoItAll.Slots:New(DoItAll.ItemFilter:New(false))
  slotsAll:Fill(container)
  TransferBatch(slotsAll)
  
  if errorMessage then ReportError() end
end

local function WithdrawAll()
  TransferAll(ZO_PlayerBankBackpack)
end

local function DepositAll()
  TransferAll(ZO_PlayerInventoryBackpack)
end

function DoItAll.BankAll()
  if IsShowingBank() then
    WithdrawAll()
  elseif IsShowingInventory() then
    -- there should always be one or the other shown, but check both conditions to be on the safe side
    DepositAll()
  end
end
