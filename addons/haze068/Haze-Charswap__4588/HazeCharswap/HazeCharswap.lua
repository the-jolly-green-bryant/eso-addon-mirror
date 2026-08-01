-- Haze Charswap
-- Author: haze068
-- Version: 1.0.0

HazeCharswap = {}
local HCS = HazeCharswap

HCS.name        = "HazeCharswap"
HCS.displayName = "Haze Charswap"
HCS.version     = "1.3.0"

HCS.defaults = {
    profiles = {
        ["Default"] = { items = {} },
    },
    activeProfile    = "Default",

    autoOpenAtBank   = true,
    showChatMessages = true,
    includeStolen    = false,
    showIcons        = true,
    uiLeft           = 400,
    uiTop            = 200,
    uiHidden         = true,
}

HCS.atBank = false

-- UI stubs (overwritten when the UI module loads)
function HCS.UI_Refresh()  end
function HCS.UI_RefreshProfileDropdown()  end
function HCS.UI_UpdateBankButtons()  end


-- =============================================================================
-- Profile helpers
-- =============================================================================

local function GetActiveProfile()
    if not HCS.sv.profiles then HCS.sv.profiles = { ["Default"] = { items = {} } } end
    local key = HCS.sv.activeProfile or "Default"
    if not HCS.sv.profiles[key] then
        local fallback = next(HCS.sv.profiles)
        if fallback then
            HCS.sv.activeProfile = fallback
            key = fallback
        else
            HCS.sv.profiles["Default"] = { items = {} }
            HCS.sv.activeProfile = "Default"
            key = "Default"
        end
    end
    if not HCS.sv.profiles[key].items then
        HCS.sv.profiles[key].items = {}
    end
    return HCS.sv.profiles[key], key
end

local function GetActiveItems()
    return GetActiveProfile().items
end

function HCS.GetProfileNames()
    local names = {}
    for n in pairs(HCS.sv.profiles or {}) do
        table.insert(names, n)
    end
    table.sort(names, function(a, b) return a:lower() < b:lower() end)
    return names
end

function HCS.GetActiveProfileName()
    return select(2, GetActiveProfile())
end

function HCS.SwitchProfile(name)
    if not HCS.sv.profiles[name] then return end
    HCS.sv.activeProfile = name
    if HCS.sv.showChatMessages then
        CHAT_SYSTEM:AddMessage(zo_strformat(GetString(HAZECS_MSG_PROFILE_SWITCHED), name))
    end
    HCS.UI_RefreshProfileDropdown()
    HCS.UI_Refresh()
end

function HCS.CreateProfile(name)
    name = (name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then
        CHAT_SYSTEM:AddMessage(GetString(HAZECS_MSG_PROFILE_INVALID))
        return false
    end
    if HCS.sv.profiles[name] then
        CHAT_SYSTEM:AddMessage(GetString(HAZECS_MSG_PROFILE_EXISTS))
        return false
    end
    HCS.sv.profiles[name] = { items = {} }
    HCS.sv.activeProfile = name
    CHAT_SYSTEM:AddMessage(zo_strformat(GetString(HAZECS_MSG_PROFILE_CREATED), name))
    HCS.UI_RefreshProfileDropdown()
    HCS.UI_Refresh()
    return true
end

function HCS.DeleteProfile(name)
    if not HCS.sv.profiles[name] then return end

    local count = 0
    for _ in pairs(HCS.sv.profiles) do count = count + 1 end
    if count <= 1 then
        CHAT_SYSTEM:AddMessage(GetString(HAZECS_MSG_PROFILE_LAST))
        return
    end

    HCS.sv.profiles[name] = nil
    if HCS.sv.activeProfile == name then
        HCS.sv.activeProfile = next(HCS.sv.profiles)
    end
    CHAT_SYSTEM:AddMessage(zo_strformat(GetString(HAZECS_MSG_PROFILE_DELETED), name))
    HCS.UI_RefreshProfileDropdown()
    HCS.UI_Refresh()
end

function HCS.RenameProfile(oldName, newName)
    newName = (newName or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if newName == "" then
        CHAT_SYSTEM:AddMessage(GetString(HAZECS_MSG_PROFILE_INVALID))
        return false
    end
    if newName == oldName then return true end
    if HCS.sv.profiles[newName] then
        CHAT_SYSTEM:AddMessage(GetString(HAZECS_MSG_PROFILE_EXISTS))
        return false
    end
    if not HCS.sv.profiles[oldName] then return false end

    HCS.sv.profiles[newName] = HCS.sv.profiles[oldName]
    HCS.sv.profiles[oldName] = nil
    if HCS.sv.activeProfile == oldName then
        HCS.sv.activeProfile = newName
    end
    CHAT_SYSTEM:AddMessage(zo_strformat(GetString(HAZECS_MSG_PROFILE_RENAMED), newName))
    HCS.UI_RefreshProfileDropdown()
    HCS.UI_Refresh()
    return true
end

function HCS.CycleProfile(direction)
    local names = HCS.GetProfileNames()
    if #names <= 1 then return end
    local active = HCS.GetActiveProfileName()
    local idx = 1
    for i, n in ipairs(names) do
        if n == active then idx = i; break end
    end
    idx = idx + (direction or 1)
    if idx < 1 then idx = #names end
    if idx > #names then idx = 1 end
    HCS.SwitchProfile(names[idx])
end


-- =============================================================================
-- Item helpers
-- =============================================================================

local function chatMsg(msg)
    if HCS.sv and HCS.sv.showChatMessages then
        CHAT_SYSTEM:AddMessage(msg)
    end
end

local function GetItemUniqueIdString(bagId, slotIndex)
    local uniqueId = GetItemUniqueId(bagId, slotIndex)
    if not uniqueId then return nil end
    return Id64ToString(uniqueId)
end

function HCS.IsItemMarked(bagId, slotIndex)
    local idStr = GetItemUniqueIdString(bagId, slotIndex)
    if not idStr then return false, nil end
    return GetActiveItems()[idStr] ~= nil, idStr
end

function HCS.MarkItem(bagId, slotIndex)
    local idStr = GetItemUniqueIdString(bagId, slotIndex)
    if not idStr then return end

    GetActiveItems()[idStr] = {
        itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT),
        name     = GetItemName(bagId, slotIndex),
        icon     = GetItemInfo(bagId, slotIndex),
        markedAt = GetTimeStamp(),
    }

    chatMsg(zo_strformat(GetString(HAZECS_MSG_ITEM_ADDED), GetActiveItems()[idStr].itemLink))
    HCS.UI_Refresh()
end

function HCS.UnmarkItem(bagId, slotIndex)
    local idStr = GetItemUniqueIdString(bagId, slotIndex)
    if not idStr then return end

    local items = GetActiveItems()
    local entry = items[idStr]
    if entry then
        chatMsg(zo_strformat(GetString(HAZECS_MSG_ITEM_REMOVED), entry.itemLink or entry.name or ""))
        items[idStr] = nil
        HCS.UI_Refresh()
    end
end

function HCS.UnmarkByUniqueId(idStr)
    local items = GetActiveItems()
    local entry = items[idStr]
    if entry then
        chatMsg(zo_strformat(GetString(HAZECS_MSG_ITEM_REMOVED), entry.itemLink or entry.name or ""))
        items[idStr] = nil
        HCS.UI_Refresh()
    end
end

function HCS.ClearList()
    GetActiveProfile().items = {}
    chatMsg(GetString(HAZECS_MSG_LIST_CLEARED))
    HCS.UI_Refresh()
end

local function FindMarkedSlotsInBag(bagId)
    local result = {}
    local items = GetActiveItems()
    local bagSize = GetBagSize(bagId)
    if not bagSize or bagSize <= 0 then return result end

    for slotIndex = 0, bagSize - 1 do
        if GetItemType(bagId, slotIndex) ~= ITEMTYPE_NONE then
            local idStr = GetItemUniqueIdString(bagId, slotIndex)
            if idStr and items[idStr] then
                table.insert(result, {
                    bagId      = bagId,
                    slotIndex  = slotIndex,
                    idStr      = idStr,
                    stackCount = GetSlotStackSize(bagId, slotIndex) or 1,
                    name       = GetItemName(bagId, slotIndex),
                    itemLink   = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT),
                    icon       = GetItemInfo(bagId, slotIndex),
                    stolen     = IsItemStolen(bagId, slotIndex),
                })
            end
        end
    end
    return result
end

function HCS.GetMarkedItemsByLocation()
    local invItems  = FindMarkedSlotsInBag(BAG_BACKPACK)
    local bankItems = {}

    for _, bag in ipairs({ BAG_BANK, BAG_SUBSCRIBER_BANK }) do
        local found = FindMarkedSlotsInBag(bag)
        for _, v in ipairs(found) do
            table.insert(bankItems, v)
        end
    end

    return invItems, bankItems
end


-- =============================================================================
-- Bank transfer (sequential, async-safe)
-- =============================================================================

HCS.transfer = {
    active    = false,
    direction = nil,
    moved     = 0,
    failed    = 0,
}

local function FindFreeSlot(bagId)
    local size = GetBagSize(bagId)
    for slot = 0, size - 1 do
        if GetItemType(bagId, slot) == ITEMTYPE_NONE then
            return slot
        end
    end
    return -1
end

local function FindFreeBankSlot()
    local slot = FindFreeSlot(BAG_BANK)
    if slot >= 0 then return BAG_BANK, slot end

    if IsESOPlusSubscriber() and GetBagSize(BAG_SUBSCRIBER_BANK) > 0 then
        slot = FindFreeSlot(BAG_SUBSCRIBER_BANK)
        if slot >= 0 then return BAG_SUBSCRIBER_BANK, slot end
    end
    return nil, nil
end

local function CollectBagItemsForDeposit()
    local queue = {}
    for _, item in ipairs(FindMarkedSlotsInBag(BAG_BACKPACK)) do
        if not item.stolen then
            table.insert(queue, item)
        end
    end
    return queue
end

local function CollectBankItemsForWithdraw()
    local _, bankItems = HCS.GetMarkedItemsByLocation()
    return bankItems
end

local ProcessNextTransfer

local function FinishTransfer()
    if HCS.transfer.direction == "deposit" then
        if HCS.transfer.moved > 0 then
            chatMsg(zo_strformat(GetString(HAZECS_MSG_DEPOSITED), HCS.transfer.moved))
        end
        if HCS.transfer.failed > 0 then
            chatMsg(zo_strformat(GetString(HAZECS_MSG_BANK_FULL), HCS.transfer.failed))
        end
    else
        if HCS.transfer.moved > 0 then
            chatMsg(zo_strformat(GetString(HAZECS_MSG_WITHDRAWN), HCS.transfer.moved))
        end
        if HCS.transfer.failed > 0 then
            chatMsg(zo_strformat(GetString(HAZECS_MSG_INV_FULL), HCS.transfer.failed))
        end
    end

    HCS.transfer.active    = false
    HCS.transfer.direction = nil
    HCS.transfer.moved     = 0
    HCS.transfer.failed    = 0

    HCS.UI_Refresh()
    HCS.UI_UpdateBankButtons()
end

ProcessNextTransfer = function()
    if not HCS.transfer.active then return end
    if not HCS.atBank then
        FinishTransfer()
        return
    end

    local nextItem
    if HCS.transfer.direction == "deposit" then
        nextItem = CollectBagItemsForDeposit()[1]
    else
        nextItem = CollectBankItemsForWithdraw()[1]
    end

    if not nextItem then
        FinishTransfer()
        return
    end

    local destBag, destSlot
    if HCS.transfer.direction == "deposit" then
        destBag, destSlot = FindFreeBankSlot()
    else
        destBag = BAG_BACKPACK
        destSlot = FindFreeSlot(BAG_BACKPACK)
        if destSlot < 0 then destSlot = nil end
    end

    if not destBag or not destSlot then
        local queue
        if HCS.transfer.direction == "deposit" then
            queue = CollectBagItemsForDeposit()
        else
            queue = CollectBankItemsForWithdraw()
        end
        HCS.transfer.failed = HCS.transfer.failed + #queue
        FinishTransfer()
        return
    end

    local ok = CallSecureProtected("RequestMoveItem",
        nextItem.bagId, nextItem.slotIndex,
        destBag, destSlot,
        nextItem.stackCount)

    if ok then
        HCS.transfer.moved = HCS.transfer.moved + 1
    else
        HCS.transfer.failed = HCS.transfer.failed + 1
    end

    zo_callLater(function()
        if HCS.transfer.active then
            ProcessNextTransfer()
        end
    end, 120)
end

function HCS.DepositAll()
    if HCS.transfer.active then return end
    if not HCS.atBank then
        chatMsg(GetString(HAZECS_UI_NEEDS_BANK))
        return
    end
    if #CollectBagItemsForDeposit() == 0 then
        chatMsg(GetString(HAZECS_MSG_NOTHING_TO_MOVE))
        return
    end
    HCS.transfer.active    = true
    HCS.transfer.direction = "deposit"
    HCS.transfer.moved     = 0
    HCS.transfer.failed    = 0
    ProcessNextTransfer()
end

function HCS.WithdrawAll()
    if HCS.transfer.active then return end
    if not HCS.atBank then
        chatMsg(GetString(HAZECS_UI_NEEDS_BANK))
        return
    end
    if #CollectBankItemsForWithdraw() == 0 then
        chatMsg(GetString(HAZECS_MSG_NOTHING_TO_MOVE))
        return
    end
    HCS.transfer.active    = true
    HCS.transfer.direction = "withdraw"
    HCS.transfer.moved     = 0
    HCS.transfer.failed    = 0
    ProcessNextTransfer()
end


-- =============================================================================
-- Right-click context menu
-- =============================================================================

local function GetSlotBagAndIndex(inventorySlot)
    if not inventorySlot then return nil, nil end

    local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
    if bagId and slotIndex then return bagId, slotIndex end

    if inventorySlot.bagId and inventorySlot.slotIndex then
        return inventorySlot.bagId, inventorySlot.slotIndex
    end

    if inventorySlot.dataEntry and inventorySlot.dataEntry.data then
        local data = inventorySlot.dataEntry.data
        if data.bagId and data.slotIndex then
            return data.bagId, data.slotIndex
        end
    end

    if inventorySlot.slotControl then
        return GetSlotBagAndIndex(inventorySlot.slotControl)
    end

    return nil, nil
end

local function AddCharswapMenuEntry(bagId, slotIndex)
    if bagId ~= BAG_BACKPACK
       and bagId ~= BAG_BANK
       and bagId ~= BAG_SUBSCRIBER_BANK then
        return
    end

    if GetItemType(bagId, slotIndex) == ITEMTYPE_NONE then return end

    if IsItemStolen(bagId, slotIndex) and not HCS.sv.includeStolen then
        return
    end

    local isMarked = HCS.IsItemMarked(bagId, slotIndex)

    if isMarked then
        AddMenuItem(GetString(HAZECS_MENU_UNMARK), function()
            HCS.UnmarkItem(bagId, slotIndex)
        end)
    else
        AddMenuItem(GetString(HAZECS_MENU_MARK), function()
            HCS.MarkItem(bagId, slotIndex)
        end)
    end
end

local function HookInventoryContextMenu()
    local postHook = SecurePostHook or ZO_PostHook
    if not postHook then return end

    postHook("ZO_InventorySlot_DiscoverSlotActionsFromActionList",
        function(inventorySlot, slotActions)
            local bagId, slotIndex = GetSlotBagAndIndex(inventorySlot)
            if bagId and slotIndex then
                AddCharswapMenuEntry(bagId, slotIndex)
            end
        end)
end


-- =============================================================================
-- Events
-- =============================================================================

local function OnBankOpened()
    HCS.atBank = true
    if HCS.sv.autoOpenAtBank then
        HCS.UI_Show()
    end
    HCS.UI_Refresh()
    HCS.UI_UpdateBankButtons()
end

local function OnBankClosed()
    HCS.atBank = false
    HCS.UI_UpdateBankButtons()
end

local function OnInventorySingleSlotUpdate(_, bagId)
    if bagId == BAG_BACKPACK or bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK then
        HCS.UI_Refresh()
    end
end


-- =============================================================================
-- Init
-- =============================================================================

local function OnAddonLoaded(event, addonName)
    if addonName ~= HCS.name then return end
    EVENT_MANAGER:UnregisterForEvent(HCS.name, EVENT_ADD_ON_LOADED)

    HCS.sv = ZO_SavedVars:NewAccountWide("HazeCharswapSavedVars", 1, nil, HCS.defaults)

    if not HCS.sv.profiles or not next(HCS.sv.profiles) then
        HCS.sv.profiles = { ["Default"] = { items = {} } }
        HCS.sv.activeProfile = "Default"
    end

    HookInventoryContextMenu()

    if HCS.UI_Initialize then HCS.UI_Initialize() end
    if HCS.Settings_Initialize then HCS.Settings_Initialize() end

    EVENT_MANAGER:RegisterForEvent(HCS.name, EVENT_OPEN_BANK,  OnBankOpened)
    EVENT_MANAGER:RegisterForEvent(HCS.name, EVENT_CLOSE_BANK, OnBankClosed)
    EVENT_MANAGER:RegisterForEvent(HCS.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySingleSlotUpdate)
end

EVENT_MANAGER:RegisterForEvent(HCS.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
