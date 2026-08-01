
local Bank = {
    isClosed = true
}
local eventId, eventBag

local function findFirstEmptyBankSlot()
    local targetBagId = BAG_BANK
    local targetSlotIndex = FindFirstEmptySlotInBag(targetBagId)
    if targetSlotIndex == nil then
        targetBagId = BAG_SUBSCRIBER_BANK
        targetSlotIndex = FindFirstEmptySlotInBag(targetBagId)
    end
    return targetBagId, targetSlotIndex
end

local function getUniqueUpdateIdentifier(bagId, slotIndex)
    return table.concat({"LeoTrainerBank", tostring(bagId), tostring(slotIndex)})
end

local function disablePersonalAssistant()
    if not PersonalAssistant then return end

    -- Check if the Addon 'PABanking' is even enabled
    local PAB = PersonalAssistant.Banking
    if PAB then
        -- Unregister PABanking completely
        EVENT_MANAGER:UnregisterForEvent(PAB.AddonName, EVENT_OPEN_BANK, "OpenBank")
        EVENT_MANAGER:UnregisterForEvent(PAB.AddonName, EVENT_CLOSE_BANK, "CloseBank")
    end
end

local function runPersonalAssistant(eventId, bankBag)
    if not PersonalAssistant then return end

    -- Check if the Addon 'PABanking' is even enabled
    local PAB = PersonalAssistant.Banking
    if PAB then
        -- Check if the functionality is turned on within the addon
        local PABMenuFunctions = PersonalAssistant.MenuFunctions.PABanking
        if PABMenuFunctions.getCurrenciesEnabledSetting() or PABMenuFunctions.getCraftingItemsEnabledSetting()
                or PABMenuFunctions.getAdvancedItemsEnabledSetting() then
            PAB.OnBankOpen(eventId, bankBag)
        end
    end
end

local function depositItems(items, startIndex)
    local itemData = items[startIndex]

    local targetBagId, targetSlotIndex = findFirstEmptyBankSlot()
    if targetBagId == nil or targetSlotIndex == nil then
        LeoTrainer.log("Cannot deposit item. Bank full?")
        runPersonalAssistant(eventId, eventBag)
        return
    end
    if IsProtectedFunction("RequestMoveItem") then
        CallSecureProtected("RequestMoveItem", BAG_BACKPACK, itemData.slotIndex, targetBagId, targetSlotIndex, 1)
    else
        RequestMoveItem(BAG_BACKPACK, itemData.slotIndex, targetBagId, targetSlotIndex, 1)
    end
    local identifier = getUniqueUpdateIdentifier(BAG_BACKPACK, itemData.slotIndex)
    EVENT_MANAGER:RegisterForUpdate(identifier, 50, function()
        local itemId = GetItemId(targetBagId, targetSlotIndex)
        if itemId > 0 or Bank.isClosed then
            EVENT_MANAGER:UnregisterForUpdate(identifier)
            LeoTrainer.log("Deposited " .. itemData.itemLink)
            if not Bank.isClosed then
                local newIndex = startIndex + 1
                if newIndex <= #items then
                    depositItems(items, newIndex)
                    return
                end
            end
            LeoTrainer.debug("Done depositing")
            runPersonalAssistant(eventId, eventBag)
        end
    end)
end

function Bank.OnOpenBank(event, bankBag)
    eventId = event
    eventBag = bankBag

    if IsHouseBankBag(bankBag) then
        runPersonalAssistant(eventId, eventBag)
        return
    end

    Bank.isClosed = false

    if not LeoTrainer.settings.bank.autoDeposit then return end

    local items = LeoTrainer.craft.ScanBackpackForCrafted()
    if #items > 0 then
        depositItems(items, 1)
    end
end

function Bank.OnCloseBank()
    Bank.isClosed = true
end

function Bank.Initialize()
    EVENT_MANAGER:RegisterForEvent(LeoTrainer.name, EVENT_OPEN_BANK, Bank.OnOpenBank)
    EVENT_MANAGER:RegisterForEvent(LeoTrainer.name, EVENT_CLOSE_BANK, Bank.OnCloseBank)
    disablePersonalAssistant()
end

LeoTrainer.bank = Bank
