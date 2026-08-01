RestockBankMaterials = RestockBankMaterials or {}

RestockBankMaterials.name = "RestockBankMaterials"

function RestockBankMaterials.OnAddOnLoaded(event, addonName)
    if addonName ~= RestockBankMaterials.name then return end
    
    EVENT_MANAGER:UnregisterForEvent(RestockBankMaterials.name, EVENT_ADD_ON_LOADED)

    RestockBankMaterials.savedVars = ZO_SavedVars:NewAccountWide(
        "RestockBankMaterials_SavedVariables", 1, nil, RestockBankMaterials.defaults, nil)
    RestockBankMaterials.InitSettings()
end

RestockBankMaterials.buttonGroup = {
    {
        name = RestockBankMaterials.strings.core.restockBankButton,
        keybind = nil,  -- set in RestockBankMaterials.InitSettings
        callback = function() RestockBankMaterials.RestockBank() end
    },
    alignment = KEYBIND_STRIP_ALIGN_LEFT
}

function RestockBankMaterials.OnBankOpened(event, bankBag)
    local saveData = RestockBankMaterials.savedVars
    if not saveData.enabled then return end

    if bankBag == BAG_BANK then
        KEYBIND_STRIP:AddKeybindButtonGroup(RestockBankMaterials.buttonGroup)
    end
end

function RestockBankMaterials.OnBankClosed(event, bankBag)
    -- always remove/unregister just to be on the safe side
    KEYBIND_STRIP:RemoveKeybindButtonGroup(RestockBankMaterials.buttonGroup)
    EVENT_MANAGER:UnregisterForEvent(RestockBankMaterials.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
end

local function FindSmallestBankSlot(itemId)
    -- is there a better way to do this than iterating through every slot?
    -- seems to perform fine tho
    local bank = BAG_BANK
    local smallestStackSize = math.huge
    local bankSlot = ZO_GetNextBagSlotIndex(bank)
    local resultSlot
    while bankSlot do
        if HasItemInSlot(bank, bankSlot) and GetItemId(bank, bankSlot) == itemId then
            local stackSize = GetSlotStackSize(bank, bankSlot)
            if stackSize < smallestStackSize then
                smallestStackSize = stackSize
                resultSlot = bankSlot
            end
        end
        bankSlot = ZO_GetNextBagSlotIndex(bank, bankSlot)
    end
    return resultSlot
end

function RestockBankMaterials.RestockBank()
    local saveData = RestockBankMaterials.savedVars
    if not saveData.enabled then return end
    
    -- todo: consider making this work in gamepad mode?
    if saveData.autoOpenMaterials and not IsInGamepadPreferredMode() then
        ZO_MenuBar_SelectDescriptor(ZO_PlayerBankMenuBar, SI_BANK_DEPOSIT)
        ZO_MenuBar_SelectDescriptor(ZO_PlayerInventoryTabs, ITEM_TYPE_DISPLAY_CATEGORY_CRAFTING)
    end

    local inventory = BAG_BACKPACK
    local bank = BAG_BANK

    -- collect item slots that have their item type in the bank
    local inventorySlotsToMove = {}
    local inventorySlot = ZO_GetNextBagSlotIndex(inventory)
    while inventorySlot do
        if HasItemInSlot(inventory, inventorySlot) then
            local itemLink = GetItemLink(inventory, inventorySlot)
            local _, bankCount = GetItemLinkStacks(itemLink)
            if IsItemLinkStackable(itemLink) and bankCount > 0
              and not IsItemLinkStolen(itemLink)
              and (saveData.allowNonMaterials or GetItemLinkFilterTypeInfo(itemLink) == ITEMFILTERTYPE_CRAFTING) then
                table.insert(inventorySlotsToMove, inventorySlot)
            end
        end
        inventorySlot = ZO_GetNextBagSlotIndex(inventory, inventorySlot)
    end

    -- at this point, inventorySlotsToMove has every inventory slot that should be moved

    local movedSlots = 0

    local function MoveNextSlot()
        local strings = RestockBankMaterials.strings.core

        -- if we have no items left to move, unregister event and finish
        if #inventorySlotsToMove == 0 then
            EVENT_MANAGER:UnregisterForEvent(RestockBankMaterials.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
            
            -- yes i know zo_strformat exists but i'm too lazy to change this now
            -- especially since noSlotsMoved has a different alert sound and category
            if movedSlots > 0 then
                local msg
                if movedSlots > 1 then
                    msg = string.format(strings.slotsMovedPlural, movedSlots)
                else
                    msg = strings.slotsMovedSingular
                end
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.DEFAULT_WINDOW_CLOSE, msg)
            else
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, strings.noSlotsMoved)
            end

            return
        end

        local inventorySlot = table.remove(inventorySlotsToMove)  -- returns the removed slot
        local itemId = GetItemId(inventory, inventorySlot)
        local bankSlot = FindSmallestBankSlot(itemId)
        
        local bankSlotCount, maxCount = GetSlotStackSize(bank, bankSlot)
        local inventorySlotCount = GetSlotStackSize(inventory, inventorySlot)
        local numItems = math.min(inventorySlotCount, maxCount - bankSlotCount)

        if numItems > 0 then
            -- simply hope this always works :^)
            CallSecureProtected("RequestMoveItem", inventory, inventorySlot, bank, bankSlot, numItems)

            if movedSlots == 0 then  -- only play sound with first item
                PlayItemSound(ITEM_SOUND_CATEGORY_RUNE)
            end
            movedSlots = movedSlots + 1

            if numItems < inventorySlotCount then
                -- is there a way to take just the name that doesn't act stupid?
                -- currently this will have colored text in the notification for >=green items
                -- but using GetItemLinkName often gives lowercase (e.g. "copper ounce" instead of "Copper Ounce")
                -- so i'm leaving it like this for now
                local itemName = GetItemLink(bank, bankSlot)
                local msg = string.format(strings.maxStackReached, itemName)
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, msg)
            end
        else
            -- make sure it's called again even if inventory doesn't update
            MoveNextSlot()
        end
    end

    -- registering the event like this ensures that the next slot will only be moved when the previous one is finished
    EVENT_MANAGER:RegisterForEvent(RestockBankMaterials.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, MoveNextSlot)
    EVENT_MANAGER:AddFilterForEvent(RestockBankMaterials.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BANK)

    MoveNextSlot()
end

EVENT_MANAGER:RegisterForEvent(RestockBankMaterials.name, EVENT_ADD_ON_LOADED, RestockBankMaterials.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(RestockBankMaterials.name, EVENT_OPEN_BANK, RestockBankMaterials.OnBankOpened)
EVENT_MANAGER:RegisterForEvent(RestockBankMaterials.name, EVENT_CLOSE_BANK, RestockBankMaterials.OnBankClosed)