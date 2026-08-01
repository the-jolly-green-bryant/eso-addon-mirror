-- =============================================================================
-- Guild Stacker v1.0.0
-- Consolidates non-full stacks in the Guild Bank.
-- No library dependencies. Gamepad/console ready.
-- =============================================================================

local GS = {
    name    = "GuildStacker",
    version = "1.0.6",
}

local DELAY           = 100
local MIN_FREE_SLOTS  = 5

-- Runtime state
local db
local defaults = { enabled = true, liteMode = false }
local currentBank
local checkingBank
local restackInProgress = false
local duplicates        = {}
local currentRun        = {}
local inBagCollection   = {}
local UI

-- Current-item state (the item group being restacked right now)
local cSlot, cSlotIdx, cInstanceId, cItemDuplicateList
local lastRestackResult = {}
local itemIndex, slotIndex
local qtyToMoveToGuildBank = 0
local waitingRetries = 1

local keybindDescriptor
local descriptorName = "Restack Guild Bank"

-- ═══════════════════════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════════════════════

local function IsAtGuildBank()
    if not SCENE_MANAGER or not SCENE_MANAGER:GetCurrentScene() then return false end
    local s = SCENE_MANAGER:GetCurrentScene():GetName()
    return s == "guildBank" or s == "gamepad_guild_bank"
end

local function GetRealStackSize(bag, slot)
    local stack, maxStack = GetSlotStackSize(bag, slot)
    local itemLink = GetItemLink(bag, slot, LINK_STYLE_BRACKETS)
    local itemType = GetItemType(bag, slot)
    local hp = select(23, ZO_LinkHandler_ParseLink(itemLink))
    if itemType == ITEMTYPE_SIEGE and hp ~= "0" then
        maxStack = 1
    end
    return stack, maxStack
end

local function MoveItem(srcBag, srcSlot, dstBag, dstSlot, qty)
    if IsProtectedFunction("RequestMoveItem") then
        CallSecureProtected("RequestMoveItem", srcBag, srcSlot, dstBag, dstSlot, qty)
    else
        RequestMoveItem(srcBag, srcSlot, dstBag, dstSlot, qty)
    end
end

-- Public flag for other addons
function GS.WorkInProgress()
    return restackInProgress
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SCANNING
-- ═══════════════════════════════════════════════════════════════════════════

local function ScanGuildBank()
    local lookUp   = {}
    local dupeTemp = {}
    duplicates = {}

    local bagData = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_GUILDBANK)
    for _, slot in pairs(bagData) do
        local stack, maxStack = GetRealStackSize(slot.bagId, slot.slotIndex)
        if stack ~= maxStack then
            local iid = slot.itemInstanceId
            if lookUp[iid] then
                if not dupeTemp[iid] then
                    dupeTemp[iid] = lookUp[iid]
                end
            else
                lookUp[iid] = {}
            end
            table.insert(lookUp[iid], {
                slotId         = slot.slotIndex,
                stack          = stack,
                texture        = slot.iconFile,
                name           = slot.name,
                itemInstanceId = iid,
            })
        end
    end

    for _, data in pairs(dupeTemp) do
        table.insert(duplicates, data)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- BACKPACK MERGING
-- ═══════════════════════════════════════════════════════════════════════════

local function MergeInBackpack(duplicateList)
    local result = {}
    local idx, dataItems = next(duplicateList)
    local itemIdx = 0

    while idx do
        local i = 1
        local info = dataItems[i]
        local base = nil
        local lastSingle = false
        local lastMulti  = false
        result[idx] = {}

        while info do
            if not base then
                base = info
                base.actualStack, base.maxStack = GetRealStackSize(BAG_BACKPACK, info.slotId)
            else
                info.maxStack = base.maxStack

                if (base.actualStack + info.stack) <= base.maxStack then
                    local qty = info.stack
                    MoveItem(BAG_BACKPACK, info.slotId, BAG_BACKPACK, base.slotId, qty)
                    base.actualStack = base.actualStack + qty
                    base.stack = base.actualStack

                    if lastMulti or lastSingle then
                        result[idx][#result[idx]] = base
                    else
                        table.insert(result[idx], base)
                    end
                    lastSingle = true
                    lastMulti  = false
                else
                    local qty = base.maxStack - base.actualStack
                    MoveItem(BAG_BACKPACK, info.slotId, BAG_BACKPACK, base.slotId, qty)

                    if lastMulti or lastSingle then
                        result[idx][#result[idx]].stack = base.maxStack
                        result[idx][#result[idx]].actualStack = base.maxStack
                    else
                        base.stack = base.maxStack
                        base.actualStack = base.maxStack
                        table.insert(result[idx], base)
                    end

                    info.stack = info.stack - qty
                    info.actualStack = info.stack
                    table.insert(result[idx], info)

                    base = info
                    base.actualStack = info.stack
                    lastSingle = false
                    lastMulti  = true
                end
            end
            i = i + 1
            info = dataItems[i]
        end

        if base and #result[idx] == 0 then
            table.insert(result[idx], base)
        end

        itemIdx = itemIdx + 1
        idx, dataItems = next(duplicateList, itemIdx)
    end

    return result
end

local function MergeFromVirtual(duplicateList)
    local result = { [1] = {} }
    local dataItems = duplicateList[next(duplicateList)]
    if not dataItems or not dataItems[1] then return result end

    local _, maxStack = GetRealStackSize(BAG_VIRTUAL, dataItems[1].slotId)
    local remaining = qtyToMoveToGuildBank

    while remaining > 0 do
        local qty = math.min(remaining, maxStack)
        table.insert(result[1], {
            itemInstanceId = dataItems[1].itemInstanceId,
            slotId         = dataItems[1].slotId,
            bagId          = BAG_VIRTUAL,
            stack          = qty,
            texture        = dataItems[1].texture,
            name           = dataItems[1].name,
        })
        remaining = remaining - qty
    end

    return result
end

-- ═══════════════════════════════════════════════════════════════════════════
-- STOP / RESET
-- ═══════════════════════════════════════════════════════════════════════════

local function ResetCurrentItem()
    cInstanceId        = nil
    cSlotIdx           = nil
    cSlot              = nil
    inBagCollection    = {}
    currentReturnIndex = nil
    restackInProgress  = false
    waitingRetries     = 1
end

local function StopAndRescan()
    EVENT_MANAGER:UnregisterForEvent(GS.name, EVENT_GUILD_BANK_TRANSFER_ERROR)
    EVENT_MANAGER:UnregisterForEvent(GS.name, EVENT_GUILD_BANK_ITEM_ADDED)
    EVENT_MANAGER:UnregisterForEvent(GS.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)

    ResetCurrentItem()

    if UI then
        local desc = UI:GetNamedChild("Description")
        if desc then desc:SetText("Complete") end
        UI:SetHidden(true)
    end

    GS.ReadyCheck()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- DEPOSIT BACK → GUILD BANK
-- ═══════════════════════════════════════════════════════════════════════════

local function ReturnItemsToBank(_, errorCode)
    if not checkingBank then
        StopAndRescan()
        return
    end

    if errorCode == GUILD_BANK_NO_SPACE_LEFT then
        d("|cE53935[GS] Guild bank full — stopping.|r")
        StopAndRescan()
        return
    elseif errorCode == GUILD_BANK_ITEM_NOT_FOUND then
        if lastRestackResult[itemIndex] and next(lastRestackResult[itemIndex], slotIndex) then
            slotIndex = slotIndex + 1
            zo_callLater(ReturnItemsToBank, DELAY)
        elseif next(lastRestackResult, itemIndex) then
            itemIndex = itemIndex + 1
            slotIndex = 1
            zo_callLater(ReturnItemsToBank, DELAY)
        end
        return
    elseif errorCode == GUILD_BANK_TRANSFER_PENDING then
        waitingRetries = waitingRetries + 1
        if waitingRetries < 10 then
            if UI then
                UI:GetNamedChild("Description"):SetText("Bank busy, retrying...")
            end
            zo_callLater(ReturnItemsToBank, DELAY * 5)
        else
            StopAndRescan()
        end
        return
    end

    local entry = lastRestackResult[itemIndex] and lastRestackResult[itemIndex][slotIndex]
    if entry and SHARED_INVENTORY:GenerateSingleSlotData(entry.bagId, entry.slotId) then
        if UI and cSlot then
            UI:GetNamedChild("Description"):SetText("Returning " .. cSlot.name .. " to Guild Bank")
        end
        TransferToGuildBank(entry.bagId, entry.slotId)
    elseif not errorCode then
        GS.RestackNext()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- RECEIVE ITEMS IN BACKPACK
-- ═══════════════════════════════════════════════════════════════════════════

local function OnItemReceived(_, bagId, slotId, _, _, _, stackCountChange)
    if (bagId ~= BAG_BACKPACK and bagId ~= BAG_VIRTUAL) or not cItemDuplicateList then return end

    local id = GetItemInstanceId(bagId, slotId)
    if not id or not cSlot or id ~= cSlot.itemInstanceId then return end

    cSlot.bagId = bagId
    cSlot.slotId = slotId
    qtyToMoveToGuildBank = qtyToMoveToGuildBank + cSlot.stack

    table.insert(inBagCollection, cSlot)

    if next(cItemDuplicateList, cSlotIdx) then
        cSlotIdx, cSlot = next(cItemDuplicateList, cSlotIdx)

        local dupId = GetItemInstanceId(BAG_GUILDBANK, cSlot.slotId)
        if not dupId or dupId ~= cSlot.itemInstanceId then
            StopAndRescan()
            return
        end
        TransferFromGuildBank(cSlot.slotId)
    else
        EVENT_MANAGER:UnregisterForEvent(GS.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)

        if UI and cSlot then
            UI:GetNamedChild("Description"):SetText("Merging " .. cSlot.name .. " in inventory")
        end

        if bagId == BAG_VIRTUAL then
            lastRestackResult = MergeFromVirtual({inBagCollection})
        else
            lastRestackResult = MergeInBackpack({inBagCollection})
        end

        EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_GUILD_BANK_TRANSFER_ERROR, ReturnItemsToBank)
        EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_GUILD_BANK_ITEM_ADDED, OnGuildBankItemAdded)

        zo_callLater(function()
            itemIndex = 1
            slotIndex = 1
            local entry = lastRestackResult[itemIndex] and lastRestackResult[itemIndex][slotIndex]
            if entry and SHARED_INVENTORY:GenerateSingleSlotData(entry.bagId or BAG_BACKPACK, entry.slotId) then
                if UI and cSlot then
                    UI:GetNamedChild("Description"):SetText("Returning " .. cSlot.name .. " to Guild Bank")
                end
                TransferToGuildBank(entry.bagId or BAG_BACKPACK, entry.slotId)
            end
        end, DELAY)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- GUILD BANK ITEM ADDED (deposit confirmed)
-- ═══════════════════════════════════════════════════════════════════════════

function OnGuildBankItemAdded(_, gslot, localPlayer)
    if not localPlayer then return end

    local id = GetItemInstanceId(BAG_GUILDBANK, gslot)
    local expected = lastRestackResult[itemIndex]
        and lastRestackResult[itemIndex][slotIndex]
        and lastRestackResult[itemIndex][slotIndex].itemInstanceId

    if id ~= expected then
        if db.liteMode then
            GS.LiteRestack(gslot)
        end
        return
    end

    if next(lastRestackResult[itemIndex], slotIndex) then
        qtyToMoveToGuildBank = qtyToMoveToGuildBank - lastRestackResult[itemIndex][slotIndex].stack
        slotIndex = slotIndex + 1
        zo_callLater(ReturnItemsToBank, DELAY)
    elseif next(lastRestackResult, itemIndex) then
        itemIndex = itemIndex + 1
        slotIndex = 1
        qtyToMoveToGuildBank = 0
        zo_callLater(ReturnItemsToBank, DELAY)
    else
        qtyToMoveToGuildBank = 0
        GS.RestackNext()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- RESTACK CYCLE
-- ═══════════════════════════════════════════════════════════════════════════

function GS.RestackNext()
    if not checkingBank then return end
    if not CheckInventorySpaceAndWarn(MIN_FREE_SLOTS) then return end

    if not cInstanceId then
        checkingBank = false
        GS.ReadyCheck()
        checkingBank = true
    end

    cInstanceId, cItemDuplicateList = next(duplicates, cInstanceId)

    if cInstanceId then
        currentRun[cInstanceId] = true
    end

    qtyToMoveToGuildBank = 0

    if cItemDuplicateList then
        restackInProgress = true

        if UI then
            UI:SetHidden(false)
            local index = NonContiguousCount(currentRun)
            local total = NonContiguousCount(duplicates)
            local bar = UI:GetNamedChild("Bar")
            local pct = UI:GetNamedChild("Percent")
            if bar then
                ZO_StatusBar_SmoothTransition(bar, index, total, FORCE_VALUE)
            end
            if pct then
                pct:SetText(string.format("%3d%%", math.floor((index / total) * 100)))
            end
        end

        cSlotIdx = 1
        cSlot = cItemDuplicateList[cSlotIdx]

        if UI then
            UI:GetNamedChild("Icon"):SetTexture(cSlot.texture)
            UI:GetNamedChild("Description"):SetText("Pulling " .. cSlot.name .. " from Guild Bank")
        end

        inBagCollection = {}

        if not SHARED_INVENTORY:GenerateSingleSlotData(BAG_GUILDBANK, cSlot.slotId) then
            zo_callLater(GS.RestackNext, DELAY)
            return
        end

        EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnItemReceived)
        TransferFromGuildBank(cSlot.slotId)
    else
        StopAndRescan()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- READY CHECK (scan + show/hide keybind)
-- ═══════════════════════════════════════════════════════════════════════════

function GS.ReadyCheck()
    if db.liteMode then return end
    if not checkingBank then return end

    ScanGuildBank()

    if DoesGuildHavePrivilege(currentBank, GUILD_PRIVILEGE_BANK_DEPOSIT)
        and DoesPlayerHaveGuildPermission(currentBank, GUILD_PERMISSION_BANK_DEPOSIT)
        and DoesPlayerHaveGuildPermission(currentBank, GUILD_PERMISSION_BANK_WITHDRAW) then

        if not KEYBIND_STRIP:HasKeybindButtonGroup(keybindDescriptor) then
            KEYBIND_STRIP:AddKeybindButtonGroup(keybindDescriptor)
        else
            KEYBIND_STRIP:UpdateKeybindButtonGroup(keybindDescriptor)
        end

        currentRun = {}
    else
        if KEYBIND_STRIP:HasKeybindButtonGroup(keybindDescriptor) then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindDescriptor)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- LITE MODE
-- ═══════════════════════════════════════════════════════════════════════════

function GS.LiteRestack(gslot)
    if not gslot or gslot == 0 then return end
    if not CheckInventorySpaceAndWarn(MIN_FREE_SLOTS) then return end
    if not DoesGuildHavePrivilege(currentBank, GUILD_PRIVILEGE_BANK_DEPOSIT) then return end
    if not DoesPlayerHaveGuildPermission(currentBank, GUILD_PERMISSION_BANK_DEPOSIT)
        or not DoesPlayerHaveGuildPermission(currentBank, GUILD_PERMISSION_BANK_WITHDRAW) then return end

    local targetId = GetItemInstanceId(BAG_GUILDBANK, gslot)
    if not targetId then return end

    local lookUp   = {}
    local dupeTemp = {}
    duplicates = {}

    local bagData = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_GUILDBANK)
    for _, slot in pairs(bagData) do
        if slot.itemInstanceId == targetId then
            local stack, maxStack = GetRealStackSize(slot.bagId, slot.slotIndex)
            if stack ~= maxStack then
                local iid = slot.itemInstanceId
                if lookUp[iid] then
                    if not dupeTemp[iid] then dupeTemp[iid] = lookUp[iid] end
                else
                    lookUp[iid] = {}
                end
                table.insert(lookUp[iid], {
                    slotId = slot.slotIndex, stack = stack,
                    texture = slot.iconFile, name = slot.name,
                    itemInstanceId = iid,
                })
            end
        end
    end

    for _, data in pairs(dupeTemp) do
        table.insert(duplicates, data)
    end

    if #duplicates > 0 then
        GS.ReadyCheck()
        GS.RestackNext()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- CRAFT BAG PROXY (BAG_VIRTUAL → backpack → guild bank)
-- ═══════════════════════════════════════════════════════════════════════════

local function PreHookTransfer()
    local original = TransferToGuildBank
    local function Proxy(sourceBag, sourceSlot)
        if IsGuildBankOpen() and sourceBag == BAG_VIRTUAL then
            if GetNumBagFreeSlots(BAG_BACKPACK) >= 1 and GetNumBagFreeSlots(BAG_GUILDBANK) >= 1 then
                local proxySlot = FindFirstEmptySlotInBag(BAG_BACKPACK)
                local stack, maxStack = GetRealStackSize(sourceBag, sourceSlot)
                local qty = math.min(stack, maxStack, qtyToMoveToGuildBank > 0 and qtyToMoveToGuildBank or stack)
                MoveItem(sourceBag, sourceSlot, BAG_BACKPACK, proxySlot, qty)
                original(BAG_BACKPACK, proxySlot)
                return true
            end
        end
    end
    ZO_PreHook("TransferToGuildBank", Proxy)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- KEYBIND
-- ═══════════════════════════════════════════════════════════════════════════

local function UpdateKeybindName()
    if GS.WorkInProgress() then
        descriptorName = "Stop"
    elseif #duplicates >= 1 and IsAtGuildBank() then
        descriptorName = "Restack Guild Bank"
    else
        descriptorName = "Scan Guild Bank"
    end
    return IsAtGuildBank()
end

local function InitKeybind()
    local bind = IsInGamepadPreferredMode() and "UI_SHORTCUT_RIGHT_STICK" or "RUN_GUILD_STACKER"
    keybindDescriptor = {
        alignment = IsInGamepadPreferredMode() and KEYBIND_STRIP_ALIGN_CENTER or KEYBIND_STRIP_ALIGN_LEFT,
        {
            name     = function() return descriptorName end,
            keybind  = bind,
            callback = GuildStacker_Run,
            visible  = UpdateKeybindName,
        },
    }
end

-- Global binding callback
function GuildStacker_Run()
    if not db.enabled then return end
    if GS.WorkInProgress() then
        StopAndRescan()
        return
    end
    if #duplicates >= 1 and IsAtGuildBank() then
        GS.ReadyCheck()
        GS.RestackNext()
    elseif IsAtGuildBank() then
        GS.ReadyCheck()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- GUILD BANK EVENTS
-- ═══════════════════════════════════════════════════════════════════════════

local function OnBankReady()
    zo_callLater(function()
        if not checkingBank then
            if IsInGamepadPreferredMode() then
                UI = GS_WindowGP
            else
                UI = GS_Window
            end
            checkingBank = true
            GS.ReadyCheck()
        end
    end, 1700)
end

local function OnBankSelected(_, guildBankId)
    checkingBank = false
    currentBank = guildBankId
    ResetCurrentItem()
end

local function OnBankOpened()
    if not db.enabled then return end
    EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_GUILD_BANK_ITEMS_READY, OnBankReady)
    EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_GUILD_BANK_SELECTED, OnBankSelected)
    if db.liteMode then
        EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_GUILD_BANK_ITEM_ADDED, OnGuildBankItemAdded)
    end
end

local function OnBankClosed()
    if keybindDescriptor and KEYBIND_STRIP:HasKeybindButtonGroup(keybindDescriptor) then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindDescriptor)
    end
    if UI then UI:SetHidden(true) end
    ResetCurrentItem()

    EVENT_MANAGER:UnregisterForEvent(GS.name, EVENT_GUILD_BANK_ITEMS_READY)
    EVENT_MANAGER:UnregisterForEvent(GS.name, EVENT_GUILD_BANK_SELECTED)
    EVENT_MANAGER:UnregisterForEvent(GS.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(GS.name, EVENT_GUILD_BANK_TRANSFER_ERROR)
    EVENT_MANAGER:UnregisterForEvent(GS.name, EVENT_GUILD_BANK_ITEM_ADDED)
    checkingBank = false
end

-- ═══════════════════════════════════════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════════════════════════════════════

local function OnAddonLoaded(_, addonName)
    if addonName ~= GS.name then return end
    EVENT_MANAGER:UnregisterForEvent(GS.name, EVENT_ADD_ON_LOADED)

    db = ZO_SavedVars:NewAccountWide("GuildStackerSV", 1, nil, defaults)

    ZO_CreateStringId("SI_BINDING_NAME_RUN_GUILD_STACKER", "Run Guild Stacker")

    InitKeybind()
    PreHookTransfer()

    -- Mute item sounds while restacking
    ZO_PreHook("PlayItemSound", function(_, itemSoundAction)
        if GS.WorkInProgress() then
            if keybindDescriptor and KEYBIND_STRIP:HasKeybindButtonGroup(keybindDescriptor) then
                KEYBIND_STRIP:UpdateKeybindButtonGroup(keybindDescriptor)
            end
            PlaySound(SOUNDS.SPINNER_UP)
            return itemSoundAction == ITEM_SOUND_ACTION_SLOT
        end
    end)

    EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_OPEN_GUILD_BANK, OnBankOpened)
    EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_CLOSE_GUILD_BANK, OnBankClosed)

    SLASH_COMMANDS["/gs"] = function(args)
        local cmd = (args or ""):lower()
        if cmd == "on" then
            db.enabled = true
            d("|c4CAF50[GS] Enabled.|r")
        elseif cmd == "off" then
            db.enabled = false
            d("|cE53935[GS] Disabled.|r")
        elseif cmd == "lite" then
            db.liteMode = not db.liteMode
            d("|cE8C05C[GS] Lite mode: " .. (db.liteMode and "ON" or "OFF") .. "|r")
        else
            d("|cE8C05C[GS] Guild Stacker v" .. GS.version .. "|r")
            d("  |c00FFFF/gs on|r - enable")
            d("  |c00FFFF/gs off|r - disable")
            d("  |c00FFFF/gs lite|r - toggle lite mode (auto-restack on deposit)")
        end
    end
end

EVENT_MANAGER:RegisterForEvent(GS.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
