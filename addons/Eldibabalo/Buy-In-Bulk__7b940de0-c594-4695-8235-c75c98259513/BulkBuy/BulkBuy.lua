-- =============================================================================
-- Bulk Buy v4.0.0
-- R3 toggles bulk mode, L1/R1 adjust target quantity.
-- When bulk mode is ON, X button bypasses the spinner and calls BuyStoreItem
-- directly in batches using the highlighted item's entry index.
-- Console/gamepad ready.
-- =============================================================================

local BB = {
    name    = "BulkBuy",
    version = "4.0.0",
}

local QTY_STEP  = 100
local MAX_QTY   = 9999
local BUY_DELAY = 100
local BATCH_MAX = 200

-- Runtime state
local storeOpen  = false
local bulkMode   = false
local targetQty  = QTY_STEP

-- Bulk-purchase chain state
local bulkBuying   = false
local bulkRemaining = 0
local bulkEntryIdx  = nil
local bulkFailures  = 0

-- Keybind bookkeeping
local injectedDescriptors = {}
local injected = false
local shoulderKeybindDescriptor
local wrappedXButtons = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════════════════════

local function ClampTarget()
    if targetQty < QTY_STEP then targetQty = QTY_STEP end
    if targetQty > MAX_QTY  then targetQty = MAX_QTY  end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ENTRY-INDEX RESOLUTION (from gamepad store UI)
-- ═══════════════════════════════════════════════════════════════════════════

local function GetSelectedEntryFromUI()
    if not STORE_WINDOW_GAMEPAD or not STORE_WINDOW_GAMEPAD.components then
        return nil
    end
    for _, comp in pairs(STORE_WINDOW_GAMEPAD.components) do
        if comp and comp.list then
            local ok, data = pcall(function() return comp.list:GetTargetData() end)
            if ok and data then
                local ds = data.dataSource or data
                for _, f in ipairs({"entryIndex","slotIndex","index","filterStoreIndex"}) do
                    local v = ds[f]
                    if v and type(v) == "number" and v > 0 then return v end
                end
                for _, f in ipairs({"entryIndex","slotIndex","index","filterStoreIndex"}) do
                    local v = data[f]
                    if v and type(v) == "number" and v > 0 then return v end
                end
            end
        end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════════════════
-- BULK PURCHASE ENGINE
-- ═══════════════════════════════════════════════════════════════════════════

local function BuyNextBatch()
    if not bulkBuying or bulkRemaining <= 0 or not storeOpen then
        bulkBuying = false
        return
    end

    if bulkFailures >= 3 then
        bulkBuying = false
        return
    end

    if GetNumBagFreeSlots(BAG_BACKPACK) < 1 then
        bulkBuying = false
        return
    end

    local qty = math.min(bulkRemaining, BATCH_MAX)
    local ok = pcall(BuyStoreItem, bulkEntryIdx, qty)

    if ok then
        bulkRemaining = bulkRemaining - qty
        bulkFailures  = 0
    else
        bulkFailures = bulkFailures + 1
    end

    if bulkRemaining > 0 and bulkFailures < 3 then
        zo_callLater(BuyNextBatch, BUY_DELAY)
    else
        bulkBuying = false
    end
end

local function StartBulkBuy()
    local idx = GetSelectedEntryFromUI()
    if not idx then return end

    bulkEntryIdx  = idx
    bulkRemaining = targetQty
    bulkFailures  = 0
    bulkBuying    = true
    BuyNextBatch()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- KEYBIND STRIP HELPERS
-- ═══════════════════════════════════════════════════════════════════════════

local function RefreshStoreStrip()
    for _, desc in ipairs(injectedDescriptors) do
        pcall(function()
            if KEYBIND_STRIP:HasKeybindButtonGroup(desc) then
                KEYBIND_STRIP:UpdateKeybindButtonGroup(desc)
            end
        end)
    end
    pcall(function()
        if shoulderKeybindDescriptor
           and KEYBIND_STRIP:HasKeybindButtonGroup(shoulderKeybindDescriptor) then
            KEYBIND_STRIP:UpdateKeybindButtonGroup(shoulderKeybindDescriptor)
        end
    end)
end

local function AddShoulderKeybinds()
    pcall(function()
        if shoulderKeybindDescriptor
           and not KEYBIND_STRIP:HasKeybindButtonGroup(shoulderKeybindDescriptor) then
            KEYBIND_STRIP:AddKeybindButtonGroup(shoulderKeybindDescriptor)
        end
    end)
end

local function RemoveShoulderKeybinds()
    pcall(function()
        if shoulderKeybindDescriptor
           and KEYBIND_STRIP:HasKeybindButtonGroup(shoulderKeybindDescriptor) then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(shoulderKeybindDescriptor)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- QUANTITY ADJUSTMENT  (L1 / R1)
-- ═══════════════════════════════════════════════════════════════════════════

local function AdjustQty(delta)
    if not bulkMode then return end
    targetQty = targetQty + delta
    ClampTarget()
    RefreshStoreStrip()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TOGGLE  (R3)  +  WATCHDOG for L1/R1
-- ═══════════════════════════════════════════════════════════════════════════

local SHOULDER_WD = BB.name .. "_ShoulderWD"

local function StartShoulderWatchdog()
    EVENT_MANAGER:RegisterForUpdate(SHOULDER_WD, 300, function()
        if not storeOpen or not bulkMode then return end
        AddShoulderKeybinds()
    end)
end

local function StopShoulderWatchdog()
    EVENT_MANAGER:UnregisterForUpdate(SHOULDER_WD)
end

function BulkBuy_Toggle()
    if not storeOpen then return end
    bulkMode = not bulkMode
    if bulkMode then
        targetQty = QTY_STEP
        AddShoulderKeybinds()
        StartShoulderWatchdog()
    else
        StopShoulderWatchdog()
        RemoveShoulderKeybinds()
        bulkBuying = false
    end
    RefreshStoreStrip()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- INJECT R3 + WRAP X BUTTON IN STORE KEYBIND DESCRIPTORS
-- ═══════════════════════════════════════════════════════════════════════════

local r3Keybind = {
    name = function()
        if bulkMode then return "Exit (" .. targetQty .. "x)" end
        return "Bulk Buy"
    end,
    keybind  = "UI_SHORTCUT_RIGHT_STICK",
    callback = BulkBuy_Toggle,
    visible  = function() return storeOpen end,
}

local function InjectIntoStoreKeybinds()
    if injected then return end
    pcall(function()
        if not IsInGamepadPreferredMode() then return end
        if not STORE_WINDOW_GAMEPAD or not STORE_WINDOW_GAMEPAD.components then return end

        for _, c in pairs(STORE_WINDOW_GAMEPAD.components) do
            if c and c.keybindStripDescriptor then
                -- Inject R3
                table.insert(c.keybindStripDescriptor, r3Keybind)
                table.insert(injectedDescriptors, c.keybindStripDescriptor)

                -- Wrap X button (UI_SHORTCUT_PRIMARY)
                for _, kb in ipairs(c.keybindStripDescriptor) do
                    if kb.keybind == "UI_SHORTCUT_PRIMARY" and not kb._bbWrapped then
                        local originalCB = kb.callback
                        kb.callback = function(...)
                            if bulkMode and storeOpen and not bulkBuying then
                                StartBulkBuy()
                                return
                            end
                            if originalCB then
                                return originalCB(...)
                            end
                        end
                        kb._bbWrapped = true
                        table.insert(wrappedXButtons, kb)
                    end
                end
            end
        end

        injected = true
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- L1 / R1 KEYBIND GROUP
-- ═══════════════════════════════════════════════════════════════════════════

local function InitShoulderKeybinds()
    local gp = IsInGamepadPreferredMode()
    shoulderKeybindDescriptor = {
        alignment = gp and KEYBIND_STRIP_ALIGN_CENTER or KEYBIND_STRIP_ALIGN_LEFT,
        {
            name     = "- " .. QTY_STEP,
            keybind  = gp and "UI_SHORTCUT_LEFT_SHOULDER"  or "BULK_BUY_TOGGLE",
            callback = function() AdjustQty(-QTY_STEP) end,
            visible  = function() return bulkMode end,
        },
        {
            name     = "+ " .. QTY_STEP,
            keybind  = gp and "UI_SHORTCUT_RIGHT_SHOULDER" or "BULK_BUY_TOGGLE",
            callback = function() AdjustQty(QTY_STEP) end,
            visible  = function() return bulkMode end,
        },
    }
end

-- ═══════════════════════════════════════════════════════════════════════════
-- STORE EVENTS
-- ═══════════════════════════════════════════════════════════════════════════

local function OnStoreOpened()
    storeOpen  = true
    bulkMode   = false
    bulkBuying = false
    targetQty  = QTY_STEP
    InjectIntoStoreKeybinds()
end

local function OnStoreClosed()
    StopShoulderWatchdog()
    RemoveShoulderKeybinds()
    storeOpen  = false
    bulkMode   = false
    bulkBuying = false
end

-- ═══════════════════════════════════════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════════════════════════════════════

local function OnAddonLoaded(_, addonName)
    if addonName ~= BB.name then return end
    EVENT_MANAGER:UnregisterForEvent(BB.name, EVENT_ADD_ON_LOADED)

    ZO_SavedVars:NewAccountWide("BulkBuySV", 1, nil, {})
    ZO_CreateStringId("SI_BINDING_NAME_BULK_BUY_TOGGLE", "Bulk Buy")

    InitShoulderKeybinds()

    EVENT_MANAGER:RegisterForEvent(BB.name, EVENT_OPEN_STORE, OnStoreOpened)
    EVENT_MANAGER:RegisterForEvent(BB.name, EVENT_CLOSE_STORE, OnStoreClosed)

    SLASH_COMMANDS["/bb"] = function()
        d("|cE8C05C[BB] v" .. BB.version ..
          " | R3: toggle bulk | L1/R1: qty | X: buy|r")
    end

    SLASH_COMMANDS["/bbdebug"] = function()
        d("|cE8C05C[BB] store=" .. tostring(storeOpen)
          .. " bulk=" .. tostring(bulkMode)
          .. " qty=" .. tostring(targetQty)
          .. " buying=" .. tostring(bulkBuying)
          .. " rem=" .. tostring(bulkRemaining) .. "|r")
        local idx = GetSelectedEntryFromUI()
        d("|cE8C05C[BB] UIidx=" .. tostring(idx) .. "|r")
        if idx then
            local ok, icon, name, stack, price = pcall(GetStoreEntryInfo, idx)
            d("|cE8C05C[BB] " .. tostring(name)
              .. " stk=" .. tostring(stack)
              .. " price=" .. tostring(price) .. "|r")
        end
        d("|cE8C05C[BB] wrappedX=" .. tostring(#wrappedXButtons) .. "|r")
    end
end

EVENT_MANAGER:RegisterForEvent(BB.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
