DoItAll = DoItAll or {}

local errorMessage = nil
local function TransferItem(slot)
	local targetContainer = slot.bagId == BAG_BACKPACK and GetBankingBag() or BAG_BACKPACK
	if DoesBagHaveSpaceFor(targetContainer, slot.bagId, slot.slotIndex) then
		CallSecureProtected("PickupInventoryItem", slot.bagId, slot.slotIndex)
		CallSecureProtected("PlaceInTransfer")
	else
		errorMessage = targetContainer == BAG_BACKPACK and SI_INVENTORY_ERROR_INVENTORY_FULL or SI_BANK_HOME_STORAGE_FULL
	end
	return true
end

local function ReportError()
	ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, errorMessage, GetCollectibleNickname(GetCollectibleForHouseBankBag(GetBankingBag())))
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

function DoItAll.HouseBankAll()
	if HOUSE_BANK_FRAGMENT.state == SCENE_SHOWN then
		TransferAll(ZO_HouseBankBackpack)
	elseif INVENTORY_FRAGMENT.state == SCENE_SHOWN then  -- there should always be one or the other shown, but check both conditions to be on the safe side
		TransferAll(ZO_PlayerInventoryBackpack)
	end
end
