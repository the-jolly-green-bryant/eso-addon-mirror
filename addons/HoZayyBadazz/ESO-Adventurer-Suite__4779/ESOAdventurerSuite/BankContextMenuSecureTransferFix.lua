-- ESO Adventurer Suite
-- v0.29.664 - replace insecure native bank context-menu transfer callbacks.
-- Detect the native TryBankItem closures by callback source as well as label so
-- localization/string changes cannot leave PickupInventoryItem attached.

local EPC = ESOProgressionCoach
local Grid = rawget(_G, "EASInventoryGrid")
if not EPC or type(Grid) ~= "table" or type(Grid.ShowCompatibleItemMenu) ~= "function" then return end
if Grid._easSecureBankContextTransfer029664 then return end
Grid._easSecureBankContextTransfer029664 = true

local function textFor(idName, fallback)
    local id = rawget(_G, idName)
    if id ~= nil and type(GetString) == "function" then
        local ok, value = pcall(GetString, id)
        if ok and tostring(value or "") ~= "" then return tostring(value) end
    end
    return fallback
end

local function normalizeText(value)
    local text = tostring(value or "")
    text = text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    return string.lower(text)
end

local function isBankBag(bag)
    return bag == rawget(_G, "BAG_BANK") or bag == rawget(_G, "BAG_SUBSCRIBER_BANK")
end

local function findEmpty(bags)
    for _, bag in ipairs(bags) do
        if bag ~= nil and type(FindFirstEmptySlotInBag) == "function" then
            local ok, slot = pcall(FindFirstEmptySlotInBag, bag)
            if ok and slot ~= nil then return bag, slot end
        end
    end
end

local function secureTransfer(bag, slot)
    bag, slot = tonumber(bag), tonumber(slot)
    if bag == nil or slot == nil then return false end

    local targets
    if isBankBag(bag) then
        targets = { rawget(_G, "BAG_BACKPACK") }
    elseif bag == rawget(_G, "BAG_BACKPACK") then
        targets = { rawget(_G, "BAG_BANK"), rawget(_G, "BAG_SUBSCRIBER_BANK") }
    else
        return false
    end

    local destBag, destSlot = findEmpty(targets)
    if destBag == nil then return false end

    local count = 1
    if type(GetSlotStackSize) == "function" then
        local ok, value = pcall(GetSlotStackSize, bag, slot)
        if ok and tonumber(value) then count = tonumber(value) end
    end

    if type(IsProtectedFunction) == "function" then
        local ok, protected = pcall(IsProtectedFunction, "RequestMoveItem")
        if ok and protected == true and type(CallSecureProtected) == "function" then
            return pcall(CallSecureProtected, "RequestMoveItem", bag, slot, destBag, destSlot, count)
        end
    end
    if type(RequestMoveItem) == "function" then
        return pcall(RequestMoveItem, bag, slot, destBag, destSlot, count)
    end
    return false
end

local bankLabels = {}
local function addLabel(idName, fallback)
    bankLabels[normalizeText(textFor(idName, fallback))] = true
end
addLabel("SI_ITEM_ACTION_BANK_DEPOSIT", "Deposit")
addLabel("SI_ITEM_ACTION_BANK_WITHDRAW", "Withdraw")
addLabel("SI_ITEM_ACTION_BANK_DEPOSIT_ALL", "Deposit All")
addLabel("SI_ITEM_ACTION_BANK_WITHDRAW_ALL", "Withdraw All")

local function isNativeBankCallback(callback)
    if type(callback) ~= "function" or type(debug) ~= "table" or type(debug.getinfo) ~= "function" then return false end
    local ok, info = pcall(debug.getinfo, callback, "S")
    if not ok or type(info) ~= "table" then return false end

    local source = string.lower(tostring(info.source or info.short_src or ""))
    if not string.find(source, "inventoryslot.lua", 1, true) then return false end

    -- Current ESO API places bank_deposit/bank_withdraw closures around these
    -- lines. Keep a narrow compatibility window for line movement between minor
    -- API patches while avoiding unrelated inventory actions.
    local line = tonumber(info.linedefined) or 0
    if line >= 1690 and line <= 1760 then return true end

    return false
end

local base = Grid.ShowCompatibleItemMenu
function Grid:ShowCompatibleItemMenu(control, ...)
    local result = base(self, control, ...)
    local bag, slot = tonumber(control and control.bagId), tonumber(control and control.slotIndex)
    if bag == nil or slot == nil then return result end
    if not isBankBag(bag) and bag ~= rawget(_G, "BAG_BACKPACK") then return result end

    local menu = rawget(_G, "ZO_Menu")
    if menu and type(menu.items) == "table" then
        for _, entry in ipairs(menu.items) do
            local item = entry and entry.item
            if item then
                local label = item.nameLabel and type(item.nameLabel.GetText) == "function" and normalizeText(item.nameLabel:GetText()) or ""
                local callback = item.OnSelect
                local shouldReplace = bankLabels[label] == true or isNativeBankCallback(callback)

                if shouldReplace then
                    item.OnSelect = function()
                        secureTransfer(bag, slot)
                    end
                end
            end
        end
    end
    return result
end

EPC.bankContextMenuSecureTransferFix029664 = true
