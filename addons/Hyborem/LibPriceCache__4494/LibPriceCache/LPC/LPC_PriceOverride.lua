-- LibPriceCache.PriceOverride (cena stacka zaokrąglona, jednostkowa niezaokrąglona)
LibPriceCache = LibPriceCache or {}
LibPriceCache.PriceOverride = LibPriceCache.PriceOverride or {}
local PO = LibPriceCache.PriceOverride

PO.name = "LibPriceCache.PriceOverride"
PO.version = "43.0.0"
PO.Enabled = false
PO.DisplayMode = "Stack"  -- Stack / Unit / Both

local Colors = {Orange = "|cFCBA03", Dark_Orange = "|cFC8403", White = "|cFFFFFF"}
local CoinIcon = "|t16:16:EsoUI/Art/currency/currency_gold.dds|t"

local function Log(msg) d("|cFFA500[LPC_PO]|r " .. tostring(msg)) end

local function IsEnabled()
    local core = LibPriceCache.Core
    return core and core.db and core.db.PriceOverrideEnabled or false
end

local function GetLPCPriceForItem(link, stackCount)
    if not IsEnabled() then return nil, nil end
    local core = LibPriceCache.Core
    if not core or not core.db then return nil, nil end
    if not link or link == "" then return nil, nil end
    if IsItemLinkBound(link) then return nil, nil end
    local maxAge = core.db.MaxPriceAgeDays * 86400
    local avgPrice = LibPriceCache.Calc:GetAveragePrice(link, maxAge)
    if not avgPrice or avgPrice <= 0 then return nil, nil end
    -- cena jednostkowa (niezaokrąglona)
    local unitPrice = avgPrice
    -- cena stacka (zaokrąglona do pełnego złota)
    local stackPrice = math.floor(avgPrice * stackCount + 0.5)
    return stackPrice, unitPrice
end

-- ============================================
-- KEYBOARD INVENTORY PRICE OVERRIDE
-- ============================================
local function OverrideInventoryPrice(control, slot)
    if not IsEnabled() then return end
    local core = LibPriceCache.Core
    if not core or not core.db then return end
    local ItemData = control.dataEntry.data
    if not ItemData then return end
    local BagId = ItemData.bagId
    local SlotIndex = ItemData.slotIndex
    if not BagId or not SlotIndex then return end
    local ItemLink = GetItemLink(BagId, SlotIndex)
    if not ItemLink then return end
    if IsItemLinkBound(ItemLink) then return end
    local SellPriceControl = control:GetNamedChild("SellPriceText")
    if not SellPriceControl then return end
    local stackPrice, unitPrice = GetLPCPriceForItem(ItemLink, ItemData.stackCount)
    if not stackPrice then return end
    local priceStack = tostring(stackPrice)
    local priceUnit = string.format("%.2f", unitPrice)
    local text = ""
    if PO.DisplayMode == "Stack" then
        text = Colors.Orange .. priceStack .. "|r " .. CoinIcon
    elseif PO.DisplayMode == "Unit" then
        text = Colors.Dark_Orange .. priceUnit .. "|r " .. CoinIcon
    else
        text = Colors.Orange .. priceStack .. "|r " .. CoinIcon .. "\n" .. Colors.White .. "@|r" .. Colors.Dark_Orange .. priceUnit .. "|r " .. CoinIcon
    end
    SellPriceControl:SetText(text)
end

local function SetupKeyboardInventoryHooks()
    for _, inv in pairs(PLAYER_INVENTORY.inventories) do
        local lv = inv.listView
        if lv and lv.dataTypes and lv.dataTypes[1] then
            SecurePostHook(lv.dataTypes[1], 'setupCallback', OverrideInventoryPrice)
        end
    end
    local craftInv = {
        ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack,
        ZO_SmithingTopLevelRefinementPanelInventoryBackpack,
        ZO_SmithingTopLevelImprovementPanelInventoryBackpack,
        ZO_EnchantingTopLevelInventoryBackpack,
        ZO_UniversalDeconstructionTopLevel_KeyboardPanelInventoryBackpack,
    }
    for _, inv in ipairs(craftInv) do
        if inv and inv.dataTypes and inv.dataTypes[1] then
            SecurePostHook(inv.dataTypes[1], 'setupCallback', OverrideInventoryPrice)
        end
    end
    Log("Keyboard inventory hooks installed")
end

-- ============================================
-- GUILD STORE PRICE OVERRIDE
-- ============================================
local function OverrideGuildStorePrice(rowControl, data)
    if not IsEnabled() then return end
    if not data or not data.itemLink then return end
    local stackPrice, _ = GetLPCPriceForItem(data.itemLink, data.stackCount or 1)
    if not stackPrice then return end
    local ValueControl = rowControl:GetNamedChild("Value")
    if not ValueControl then return end
    local formatted = ZO_Currency_FormatKeyboard(CURT_MONEY, stackPrice, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
    ValueControl:SetText(formatted)
    ValueControl:SetColor(0.58, 1, 0.54)
end

local function SetupGuildStoreHooks()
    if not IsEnabled() then return end
    if not TRADING_HOUSE then return end
    local searchList = TRADING_HOUSE.searchResultsList
    if searchList and searchList.dataTypes and searchList.dataTypes[1] then
        SecurePostHook(searchList.dataTypes[1], 'setupCallback', OverrideGuildStorePrice)
        Log("Guild store hook installed")
    end
end

SLASH_COMMANDS["/lpcpo"] = function()
    local core = LibPriceCache.Core
    if core and core.db then
        core.db.PriceOverrideEnabled = not core.db.PriceOverrideEnabled
        core.db.dirty = true
        Log("Price override " .. (core.db.PriceOverrideEnabled and "ENABLED" or "DISABLED"))
        if core.db.PriceOverrideEnabled then
            SetupKeyboardInventoryHooks()
            SetupGuildStoreHooks()
            PLAYER_INVENTORY:UpdateList(INVENTORY_BACKPACK)
            PLAYER_INVENTORY:UpdateList(INVENTORY_CRAFT_BAG)
            PLAYER_INVENTORY:UpdateList(INVENTORY_BANK)
            PLAYER_INVENTORY:UpdateList(INVENTORY_HOUSE_BANK)
            PLAYER_INVENTORY:UpdateList(INVENTORY_GUILD_BANK)
        else
            Log("Type /reloadui to restore original prices")
        end
    end
end

local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent("LibPriceCache_PO_Init", EVENT_PLAYER_ACTIVATED)
    zo_callLater(function()
        if IsEnabled() then
            SetupKeyboardInventoryHooks()
            SetupGuildStoreHooks()
        end
        Log("PriceOverride v" .. PO.version .. " ready. Use /lpcpo to toggle. Current state: " .. (IsEnabled() and "ON" or "OFF"))
        if IsEnabled() and MasterMerchant and MasterMerchant.systemSavedVariables and MasterMerchant.systemSavedVariables.replaceInventoryValues then
            Log("|cFF8800WARNING: Master Merchant inventory override is also enabled. Disable one.|r")
        end
    end, 5000)
end

EVENT_MANAGER:RegisterForEvent("LibPriceCache_PO_Init", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

LibPriceCache.PriceOverride.SetupKeyboardInventoryHooks = SetupKeyboardInventoryHooks
LibPriceCache.PriceOverride.SetupGuildStoreHooks = SetupGuildStoreHooks