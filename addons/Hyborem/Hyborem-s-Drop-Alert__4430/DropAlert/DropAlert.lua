-- DropAlert.lua (z LibAsync i kolejką cen)
DropAlert = DropAlert or {}
DropAlert.name = "DropAlert"
DropAlert.version = "1.0.26"

local DA = DropAlert

local I_MORA = "|t160:160:DropAlert/art/mora.dds|t"
local I_GOLD = "|t160:160:DropAlert/art/gold.dds|t"
local I_WRIT = "|t120:120:DropAlert/art/zenithar.dds|t"
local I_QUAL = "|t120:120:DropAlert/art/pure.dds|t"
local I_HUNT = "|t120:120:DropAlert/art/hunt.dds|t"

local stackCountCache = {}
local STACK_CACHE_DURATION = 10

-- Zmieniono nazwę z GetTotalStackCount na DA.GetTotalStackCount
function DA.GetTotalStackCount(itemLink)
    local itemId = GetItemLinkItemId(itemLink)
    if not itemId then return nil end

    local now = GetFrameTimeSeconds()
    local cached = stackCountCache[itemId]
    if cached and (now - cached.time) < STACK_CACHE_DURATION then
        return cached.count
    end

    local total = 0
    if HasCraftBagAccess() then
        local slot = GetNextVirtualBagSlotId()
        while slot do
            if GetItemId(BAG_VIRTUAL, slot) == itemId then
                total = total + GetSlotStackSize(BAG_VIRTUAL, slot)
            end
            slot = GetNextVirtualBagSlotId(slot)
        end
    end

    local bagSize = GetBagSize(BAG_BACKPACK)
    for slot = 0, bagSize - 1 do
        if GetItemId(BAG_BACKPACK, slot) == itemId then
            total = total + GetSlotStackSize(BAG_BACKPACK, slot)
        end
    end

    local bankSize = GetBagSize(BAG_BANK)
    for slot = 0, bankSize - 1 do
        if GetItemId(BAG_BANK, slot) == itemId then
            total = total + GetSlotStackSize(BAG_BANK, slot)
        end
    end

    stackCountCache[itemId] = { time = now, count = total }
    return total
end

local function DoEmote()
    if not DA.vars.doEmote then return end
    if DA.vars.doEmoteStealthed == false and GetUnitStealthState("player") ~= STEALTH_STATE_NONE then return end
    if SLASH_COMMANDS["/cheer"] then
        SLASH_COMMANDS["/cheer"]()
    end
end

local function IsKnownByCraftStore(itemLink)
    if not CraftStoreFixedAndImprovedLongClassName then return nil end
    local CS = CraftStoreFixedAndImprovedLongClassName
    local itemId = GetItemLinkItemId(itemLink)
    if not itemId then return nil end
    local currentChar = CS.CurrentPlayer
    local itemType = GetItemLinkItemType(itemLink)
    
    if itemType == ITEMTYPE_RECIPE then
        if CS.Data and CS.Data.cook and CS.Data.cook.knowledge and CS.Data.cook.knowledge[currentChar] then
            return CS.Data.cook.knowledge[currentChar][itemId]
        end
    elseif itemType == ITEMTYPE_FURNISHING_DESIGN or itemType == 68 then
        if CS.Data and CS.Data.furnisher and CS.Data.furnisher.knowledge and CS.Data.furnisher.knowledge[currentChar] then
            return CS.Data.furnisher.knowledge[currentChar][itemId]
        end
    elseif itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
        if CS.Data and CS.Data.style and CS.Data.style.knowledge and CS.Data.style.knowledge[currentChar] then
            return CS.Data.style.knowledge[currentChar][itemId]
        end
    end
    return nil
end

local function IsKnowledgeKnown(itemLink)
    local known = IsKnownByCraftStore(itemLink)
    if known ~= nil then
        return known
    end
    local itemType = GetItemLinkItemType(itemLink)
    if itemType == ITEMTYPE_RECIPE then
        return IsItemLinkRecipeKnown(itemLink)
    else
        return IsItemLinkBookKnown(itemLink)
    end
end

function DA:Alert(link, count, price, mode)
    if not DA.vars or not link then return end

    local q = GetItemLinkDisplayQuality(link)
    local color = GetItemQualityColor(q)
    local icon = "|t80:80:"..tostring(GetItemLinkIcon(link)).."|t"
    local name = color:Colorize(zo_strformat("<<t:1>>", GetItemLinkName(link)))
    
    local countText = (count and count > 1) and string.format("|c00CED1%dx|r ", count) or ""
    local totalCount = DA.GetTotalStackCount(link)
    local totalText = (totalCount and totalCount > 0) and string.format(" (|c87CEEB%d|r)", totalCount) or ""
    
    local msg = ""
    if mode == "KNOWLEDGE" then
        local priceText = (price and price > 0 and price >= (DA.vars.alertMinPrice or 5000)) and string.format(" |cFFFF00%.0fg|r", price) or ""
        msg = string.format("%s %s|cE066FFI want that knowledge!!!|r %s%s%s%s", I_MORA, countText, icon, name, totalText, priceText)
    elseif mode == "WRIT" then
        local priceText = (price and price > 0 and price >= (DA.vars.alertMinPrice or 5000)) and string.format(" |cFFFF00%.0fg|r", price) or ""
        msg = string.format("%s %s|cFF8C00Your craft, recognized.|r %s%s%s%s", I_WRIT, countText, icon, name, totalText, priceText)
    elseif mode == "VALUE" then
        local priceText = (price and price > 0) and string.format("|cFFFF00%.0fg|r", price) or "|cFF8888no price|r"
        msg = string.format("%s %s|c7FD47FA fair trade... for ME!|r %s%s%s %s", I_GOLD, countText, icon, name, totalText, priceText)
    elseif mode == "QUALITY" then
        local priceText = (price and price > 0 and price >= (DA.vars.alertMinPrice or 5000)) and string.format(" |cFFFF00%.0fg|r", price) or ""
        msg = string.format("%s %s|c00FFFFA vessel for my purity!|r %s%s%s%s", I_QUAL, countText, icon, name, totalText, priceText)
    end

    if msg ~= "" then
        DoEmote()
        if DA.vars.doAudio then PlaySound(SOUNDS.BOOK_ACQUIRED) end
        local p = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
        p:SetText(msg)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(p)
    end
end

-- Debouncer dla alertów
local pendingAlerts = {}
local alertDebounceTimer = nil

local function ProcessPendingAlerts()
    for itemKey, data in pairs(pendingAlerts) do
        if data and data.link then
            DA:Alert(data.link, data.count, data.price, data.mode)
        end
    end
    pendingAlerts = {}
    alertDebounceTimer = nil
end

local function ScheduleAlert(link, count, price, mode)
    local itemKey = tostring(GetItemLinkItemId(link)) or link
    pendingAlerts[itemKey] = { link = link, count = count, price = price, mode = mode }
    
    if alertDebounceTimer then
        zo_callLater(function() end, alertDebounceTimer)
    end
    alertDebounceTimer = zo_callLater(ProcessPendingAlerts, 1000)
end

local pendingPriceChecks = {}

-- ============================================
-- KOLEJKA ZAPYTAŃ O CENY (LibAsync)
-- ============================================
local priceQueryQueue = {}
local isProcessingQueue = false

local function ProcessPriceQueue()
    if not isProcessingQueue then return end
    if #priceQueryQueue == 0 then
        isProcessingQueue = false
        return
    end
    local item = table.remove(priceQueryQueue, 1)
    if item and item.link and LibPriceCache and LibPriceCache.GetPrice then
        local success, price = pcall(LibPriceCache.GetPrice, item.link)
        if success and price and price >= (DA.vars.alertMinPrice or 5000) then
            ScheduleAlert(item.link, item.count, price, "VALUE")
        elseif success and not price then
            local itemKey = tostring(GetItemLinkItemId(item.link))
            pendingPriceChecks[itemKey] = { link = item.link, count = item.count, minPrice = DA.vars.alertMinPrice or 5000 }
        end
    end
    zo_callLater(ProcessPriceQueue, 100)
end

local function QueuePriceCheck(link, count)
    if not LibPriceCache or not LibPriceCache.GetPrice then return end
    table.insert(priceQueryQueue, { link = link, count = count })
    if not isProcessingQueue then
        isProcessingQueue = true
        ProcessPriceQueue()
    end
end

function DA.OnLoot(_, _, link, count, _, _, selfLooted)
    if not selfLooted or not link or not DA.vars then return end
    if DA.isCurrentlyHunted then 
        DA.isCurrentlyHunted = false 
        return 
    end

    local t, q = GetItemLinkItemType(link), GetItemLinkDisplayQuality(link)
    
    if (DA.vars.alertMotifs and t == ITEMTYPE_RACIAL_STYLE_MOTIF) or 
       (DA.vars.alertRecipes and t == ITEMTYPE_RECIPE) or 
       (DA.vars.alertPlans and t == ITEMTYPE_FURNISHING_DESIGN) then
        if not IsKnowledgeKnown(link) then
            ScheduleAlert(link, count, nil, "KNOWLEDGE")
            return
        end
    end

    if DA.vars.alertWrits and t == ITEMTYPE_MASTER_WRIT then 
        ScheduleAlert(link, count, nil, "WRIT") 
        return 
    end

    if DA.vars.enableAlerts then
        QueuePriceCheck(link, count)
    end

    if DA.vars.enableQualityAlerts and q >= (DA.vars.minQuality or 4) then 
        ScheduleAlert(link, count, nil, "QUALITY") 
        return 
    end
end

local function OnLPCPriceUpdated(itemKey, price, itemLink)
    local pending = pendingPriceChecks[itemKey]
    if pending and price and price >= pending.minPrice then
        ScheduleAlert(pending.link, pending.count, price, "VALUE")
        pendingPriceChecks[itemKey] = nil
    end
end

function DA.HircineAlert(link, count)
    if not link then return end
    local color = GetItemLinkDisplayQuality(link)
    local hex = GetItemQualityColor(color):ToHex()
    local name = string.format("|c%s%s|r", hex, zo_strformat("<<t:1>>", GetItemLinkName(link)))
    local icon = "|t80:80:"..tostring(GetItemLinkIcon(link)).."|t"
    local countText = (count and count > 1) and string.format("|c00CED1%dx|r ", count) or ""
    local totalCount = DA.GetTotalStackCount(link)
    local totalText = (totalCount and totalCount > 0) and string.format(" (|c87CEEB%d|r)", totalCount) or ""
    
    local price = nil
    if LibPriceCache and LibPriceCache.GetPrice then
        local success, p = pcall(LibPriceCache.GetPrice, link)
        if success then price = p end
    end
    local priceText = (price and price > 0 and price >= (DA.vars.alertMinPrice or 5000)) and string.format(" |cFFFF00%.0fg|r", price) or ""
    
    local msg = string.format("%s %s|c00FFFFGreat Hunt Trophy!|r %s%s%s%s", I_HUNT, countText, icon, name, totalText, priceText)
    
    DoEmote()
    if DA.vars.doAudio then PlaySound(SOUNDS.BOOK_ACQUIRED) end
    local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
    params:SetText(msg)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= DA.name then return end
    EVENT_MANAGER:UnregisterForEvent("DropAlert_Load", EVENT_ADD_ON_LOADED)
    
    local defaults = {
        minQuality = 4,
        enableQualityAlerts = true,
        alertRecipes = true, alertPlans = true,
        alertMotifs = true, enableAlerts = false, alertMinPrice = 5000,
        alertWrits = true, customItems = {},
        doEmote = true, doAudio = true, doEmoteStealthed = false,
    }
    local serverKey = GetDisplayName() .. "_" .. GetWorldName()
    DA.vars = LibSavedVars:NewAccountWide("DropAlert_Vars", defaults, nil, serverKey)
    
    if DA.CreateMenu then DA:CreateMenu() end
    if DA.InitHircine then DA.InitHircine() end
    
    EVENT_MANAGER:RegisterForEvent(DA.name, EVENT_LOOT_RECEIVED, DA.OnLoot)
    -- Rejestracja callbacka DOPIERO po inicie SavedVars
    CALLBACK_MANAGER:RegisterCallback("LPC_PRICE_UPDATED", OnLPCPriceUpdated)
    
    if not CraftStoreFixedAndImprovedLongClassName then
        d("[DropAlert] |cFF8800CraftStore not found. Knowledge alerts may not work correctly.|r")
    end
    if not LibPriceCache then
        d("[DropAlert] |cFF8800LibPriceCache not found. Price alerts will not work.|r")
    end
end

EVENT_MANAGER:RegisterForEvent("DropAlert_Load", EVENT_ADD_ON_LOADED, OnAddOnLoaded)