NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local UI = NQOL.Features.UI
if not UI then
    return
end

local LOOT_LOG_TOTAL_ICON_MARKUP = "|t20:20:EsoUI/Art/HUD/Gamepad/gp_lootHistory_icon_craftBag.dds|t"
local LOOT_LOG_PRICE_ICON_MARKUP = "|t20:20:EsoUI/Art/currency/currency_gold.dds|t"
local LOOT_LOG_STATUS_ICON = "EsoUI/Art/HUD/Gamepad/gp_lootHistory_icon_craftBag.dds"

local lootHistoryHookInstalled = false
local pendingLootLogItemId
local pendingLootLogItemLink
local hookedLootHistoryObjects = {}

local function GetLootLogSettings()
    return UI.GetLootLogSettings()
end

local function GetLootLogShowPrice()
    if type(UI.GetLootLogShowPrice) == "function" then
        return UI.GetLootLogShowPrice()
    end

    return "off"
end

local function ShouldCaptureLootLogItem()
    return GetLootLogSettings().showTotals == true or GetLootLogShowPrice() ~= "off"
end

local function GetLootLogTimerMs()
    local timerSeconds = math.floor((tonumber(GetLootLogSettings().timerSeconds) or 4) + 0.5)
    return timerSeconds * 1000
end

local function GetLootLogNowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        return GetFrameTimeMilliseconds()
    end

    return 0
end

local function ReanchorLootLogActiveEntries(stream)
    if not stream or type(stream.activeEntries) ~= "table" then
        return
    end

    local previousEntry
    for index, entryControl in ipairs(stream.activeEntries) do
        if entryControl then
            if type(entryControl.ClearAnchors) == "function" then
                entryControl:ClearAnchors()
            end

            if stream.anchor and type(stream.anchor.Set) == "function" then
                stream.anchor:Set(entryControl)
            end

            if index == 1 then
                entryControl:SetAnchor(BOTTOMRIGHT, stream.control, BOTTOMRIGHT, 0, 0)
                stream.bottomEntry = entryControl
            else
                entryControl:SetAnchor(BOTTOMRIGHT, previousEntry, TOPRIGHT, 0, stream.additionalEntrySpacingY)
            end

            previousEntry = entryControl
        end
    end

    stream.lastAnchoredEntry = previousEntry
end

local function ReleaseExpiredLootLogEntries(stream, nowMs)
    if not stream or type(stream.activeEntries) ~= "table" or type(stream.ReleaseControl) ~= "function" then
        return
    end

    local released = false
    for index = #stream.activeEntries, 1, -1 do
        local entryControl = stream.activeEntries[index]
        if entryControl and entryControl.nqolLootLogExpireAtMs and nowMs >= entryControl.nqolLootLogExpireAtMs then
            stream:ReleaseControl(entryControl)
            released = true
        end
    end

    if released then
        if tonumber(stream.currentlyFadingEntries) and tonumber(stream.currentNumDisplayedEntries) then
            stream.currentlyFadingEntries = math.min(stream.currentlyFadingEntries, stream.currentNumDisplayedEntries)
        end

        ReanchorLootLogActiveEntries(stream)
        if stream.currentNumDisplayedEntries == 0 then
            stream.doesContainsEntries = false
            stream.bottomEntry = nil
            stream.lastAnchoredEntry = nil
        elseif type(stream.DisplayBatches) == "function" then
            stream:DisplayBatches()
        end
    end
end

local function InstallLootLogStreamPerEntryTimer(stream)
    if not stream or stream.nqolLootLogPerEntryTimerInstalled then
        return
    end

    if type(stream.DisplayEntry) ~= "function" or type(stream.OnUpdateBuffer) ~= "function" then
        return
    end

    stream.nqolLootLogPerEntryTimerInstalled = true
    local originalDisplayEntry = stream.DisplayEntry
    local originalOnUpdateBuffer = stream.OnUpdateBuffer

    function stream:DisplayEntry(templateName, entry, entryNumber, hasCurrentEntries)
        local entryControl = originalDisplayEntry(self, templateName, entry, entryNumber, hasCurrentEntries)
        if entryControl then
            entryControl.nqolLootLogExpireAtMs = GetLootLogNowMs() + GetLootLogTimerMs()
        end
        return entryControl
    end

    function stream:OnUpdateBuffer(timeMs)
        originalOnUpdateBuffer(self, timeMs)
        ReleaseExpiredLootLogEntries(self, timeMs or GetLootLogNowMs())
    end
end

local function ApplyLootLogBufferSettingsToStream(stream)
    if not stream then
        return
    end

    local settings = GetLootLogSettings()
    stream.maxDisplayedEntries = tonumber(settings.bufferSize) or 5

    if type(stream.SetContainerShowTime) == "function" then
        stream:SetContainerShowTime(3600000)
    end

    InstallLootLogStreamPerEntryTimer(stream)
end

local function ApplyLootLogBufferSettingsToHistory(history)
    if not history then
        return
    end

    ApplyLootLogBufferSettingsToStream(history.lootStream)
    ApplyLootLogBufferSettingsToStream(history.lootStreamPersistent)
end

local function GetLootLogTotalBagIds()
    local bagIds = {}
    local seen = {}
    local candidateBagNames = {
        "BAG_BACKPACK",
        "BAG_BANK",
        "BAG_SUBSCRIBER_BANK",
        "BAG_VIRTUAL",
        "BAG_HOUSE_BANK_ONE",
        "BAG_HOUSE_BANK_TWO",
        "BAG_HOUSE_BANK_THREE",
        "BAG_HOUSE_BANK_FOUR",
        "BAG_HOUSE_BANK_FIVE",
        "BAG_HOUSE_BANK_SIX",
        "BAG_HOUSE_BANK_SEVEN",
        "BAG_HOUSE_BANK_EIGHT",
        "BAG_HOUSE_BANK_NINE",
        "BAG_HOUSE_BANK_TEN",
    }

    for _, bagName in ipairs(candidateBagNames) do
        local bagId = _G[bagName]
        if bagId ~= nil and not seen[bagId] then
            seen[bagId] = true
            bagIds[#bagIds + 1] = bagId
        end
    end

    return bagIds
end

local function GetLootLogItemIdFromLink(itemLink)
    if type(itemLink) == "string" and itemLink ~= "" and type(GetItemLinkItemId) == "function" then
        local ok, itemId = pcall(GetItemLinkItemId, itemLink)
        if ok and itemId and itemId > 0 then
            return itemId
        end
    end

    return nil
end

local function GetLootLogSlotStackCount(bagId, slotIndex)
    if type(GetSlotStackSize) == "function" then
        local ok, stackCount = pcall(GetSlotStackSize, bagId, slotIndex)
        if ok and tonumber(stackCount) then
            return tonumber(stackCount)
        end
    end

    if type(GetItemInfo) == "function" then
        local ok, _, stackCount = pcall(GetItemInfo, bagId, slotIndex)
        if ok and tonumber(stackCount) then
            return tonumber(stackCount)
        end
    end

    return 1
end

local function GetLootLogSlotDataLink(bagId, slotKey, slotData)
    local itemLink = slotData and (slotData.itemLink or slotData.link or (slotData.itemData and slotData.itemData.itemLink))
    if (not itemLink or itemLink == "") and type(GetItemLink) == "function" and slotKey ~= nil then
        local slotIndex = tonumber(slotData and (slotData.slotIndex or slotData.slotId or slotData.slot) or slotKey) or slotKey
        local ok, link = pcall(GetItemLink, bagId, slotIndex, LINK_STYLE_DEFAULT)
        if ok then
            itemLink = link
        end
    end

    return itemLink
end

local function GetLootLogSlotDataCount(bagId, slotKey, slotData)
    local stackCount = tonumber(slotData and (slotData.stackCount or slotData.quantity or slotData.stack))
    if stackCount and stackCount > 0 then
        return stackCount
    end

    local slotIndex = tonumber(slotData and (slotData.slotIndex or slotData.slotId or slotData.slot) or slotKey)
    if slotIndex then
        return GetLootLogSlotStackCount(bagId, slotIndex)
    end

    return 1
end

local function GetLootLogSlotItemId(bagId, slotIndex)
    if type(GetItemLink) == "function" then
        local ok, itemLink = pcall(GetItemLink, bagId, slotIndex, LINK_STYLE_DEFAULT)
        if ok then
            local itemId = GetLootLogItemIdFromLink(itemLink)
            if itemId then
                return itemId
            end
        end
    end

    if type(GetItemId) == "function" then
        local ok, itemId = pcall(GetItemId, bagId, slotIndex)
        if ok and itemId and itemId > 0 then
            return itemId
        end
    end

    return nil
end

local function CountLootLogSharedInventoryBag(itemId, bagId)
    if not SHARED_INVENTORY then
        return nil
    end

    local total = 0
    local scanned = false
    local methods = { "GenerateFullSlotData", "GetBagCache", "GetOrCreateBagCache" }

    for _, methodName in ipairs(methods) do
        if type(SHARED_INVENTORY[methodName]) == "function" then
            local ok, bagData
            if methodName == "GenerateFullSlotData" then
                ok, bagData = pcall(function()
                    return SHARED_INVENTORY:GenerateFullSlotData(nil, bagId)
                end)
            else
                ok, bagData = pcall(function()
                    return SHARED_INVENTORY[methodName](SHARED_INVENTORY, bagId)
                end)
            end

            if ok and type(bagData) == "table" then
                for slotKey, slotData in pairs(bagData) do
                    local itemLink = GetLootLogSlotDataLink(bagId, slotKey, slotData)
                    if GetLootLogItemIdFromLink(itemLink) == itemId then
                        total = total + GetLootLogSlotDataCount(bagId, slotKey, slotData)
                    end
                    scanned = true
                end
            end

            if scanned then
                return total
            end
        end
    end

    return nil
end

local function CountLootLogBag(itemId, bagId)
    if bagId == nil or type(GetBagSize) ~= "function" then
        return 0
    end

    if bagId == _G.BAG_VIRTUAL then
        local sharedTotal = CountLootLogSharedInventoryBag(itemId, bagId)
        if sharedTotal then
            return sharedTotal
        end
    end

    local sizeOk, bagSize = pcall(GetBagSize, bagId)
    if not sizeOk or not bagSize or bagSize <= 0 then
        return 0
    end

    local total = 0
    for slotIndex = 0, bagSize - 1 do
        if GetLootLogSlotItemId(bagId, slotIndex) == itemId then
            total = total + GetLootLogSlotStackCount(bagId, slotIndex)
        end
    end

    return total
end

local function CountLootLogItemTotal(itemId)
    if not itemId or itemId <= 0 or type(GetBagSize) ~= "function" then
        return nil
    end

    local total = 0
    local bagIds = GetLootLogTotalBagIds()

    for _, bagId in ipairs(bagIds) do
        total = total + CountLootLogBag(itemId, bagId)
    end

    if total > 0 then
        return total
    end

    return nil
end

local function FormatLootLogNumber(value)
    value = tonumber(value)
    if not value or value <= 0 then
        return nil
    end

    value = math.floor(value + 0.5)
    if type(ZO_LocalizeDecimalNumber) == "function" then
        return ZO_LocalizeDecimalNumber(value)
    end

    if type(ZO_CommaDelimitDecimalNumber) == "function" then
        return ZO_CommaDelimitDecimalNumber(value)
    end

    if type(ZO_CommaDelimitNumber) == "function" then
        return ZO_CommaDelimitNumber(value)
    end

    if type(FormatIntegerWithDigitGrouping) == "function" then
        return FormatIntegerWithDigitGrouping(value)
    end

    return tostring(value)
end

local function GetLootLogPriceValue(itemData, priceMode)
    if priceMode == "average" then
        return tonumber(itemData.avgPrice)
    end

    if priceMode == "min" then
        return tonumber(itemData.commonMin) or tonumber(itemData.legacyMin)
    end

    if priceMode == "max" then
        return tonumber(itemData.commonMax) or tonumber(itemData.legacyMax)
    end

    return nil
end

local function GetLootLogPriceText(itemLink)
    local priceMode = GetLootLogShowPrice()
    if priceMode == "off" then
        return nil
    end

    if type(itemLink) ~= "string" or itemLink == "" then
        return nil
    end

    local priceApi = _G.TSCPriceDataAPI
    if type(priceApi) ~= "table" or type(priceApi.GetItemData) ~= "function" then
        return nil
    end

    local ok, itemData = pcall(function()
        return priceApi:GetItemData(itemLink)
    end)
    if not ok or itemData == nil or itemData == priceApi.LOADING or type(itemData) ~= "table" then
        return nil
    end

    local priceText = FormatLootLogNumber(GetLootLogPriceValue(itemData, priceMode))
    if not priceText then
        return nil
    end

    return string.format("%s %s", LOOT_LOG_PRICE_ICON_MARKUP, priceText)
end

local function AddLootLogCustomData(lootData)
    if not lootData or lootData.entryType ~= LOOT_ENTRY_TYPE_ITEM or not ShouldCaptureLootLogItem() then
        return
    end

    local itemLink = pendingLootLogItemLink or lootData.itemLink
    local itemId = pendingLootLogItemId or GetLootLogItemIdFromLink(itemLink)
    if not itemId and (type(itemLink) ~= "string" or itemLink == "") then
        return
    end

    local originalText = lootData.text
    lootData.nqolLootLogItemId = itemId
    lootData.nqolLootLogItemLink = itemLink
    lootData.nqolLootLogCustomStatus = true
    lootData.statusIcon = LOOT_LOG_STATUS_ICON
    lootData.statusIconColor = nil
    lootData.text = function(data)
        if type(originalText) == "function" then
            return originalText(data)
        end

        return originalText
    end
end

local function EnsureLootLogStatusLabel(control)
    if not control or not control.statusIcon or control.nqolLootLogStatusLabel then
        return control and control.nqolLootLogStatusLabel
    end

    if not WINDOW_MANAGER or type(WINDOW_MANAGER.CreateControl) ~= "function" then
        return nil
    end

    local label = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    label:SetAnchor(RIGHT, control, RIGHT, -4, 0)
    label:SetDimensions(70, 24)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetFont("ZoFontGamepad22")
    label:SetColor(ZO_WHITE:UnpackRGBA())
    label:SetHidden(true)

    control.nqolLootLogStatusLabel = label
    return label
end

local function BuildLootLogStatusText(data)
    if not data or not data.nqolLootLogCustomStatus then
        return ""
    end

    local segments = {}
    if GetLootLogSettings().showTotals == true then
        local total = CountLootLogItemTotal(data.nqolLootLogItemId)
        local totalText = FormatLootLogNumber(total)
        if totalText then
            segments[#segments + 1] = string.format("%s %s", LOOT_LOG_TOTAL_ICON_MARKUP, totalText)
        end
    end

    local priceText = GetLootLogPriceText(data.nqolLootLogItemLink)
    if priceText then
        segments[#segments + 1] = priceText
    end

    return table.concat(segments, "  ")
end

local function GetLootLogStatusTextWidth(label, text)
    local width = label:GetTextWidth() + 8
    local textureCount = 0

    for _ in string.gmatch(text, "|t.-|t") do
        textureCount = textureCount + 1
    end

    return math.max(70, width + textureCount * 24)
end

local function ApplyLootLogStatusText(control, data)
    local label = EnsureLootLogStatusLabel(control)
    if not label then
        return
    end

    local text = BuildLootLogStatusText(data)
    if data and data.nqolLootLogCustomStatus and control.statusIcon then
        control.statusIcon:SetHidden(text ~= "")
    end

    label:SetText(text)
    label:SetHidden(text == "")

    if text ~= "" then
        label:SetWidth(GetLootLogStatusTextWidth(label, text))
        control:SetWidth(315 + label:GetWidth())
    else
        label:SetWidth(70)
        control:SetWidth(315)
    end
end

local function WrapLootHistoryTemplate(templateName, templateData)
    if templateName ~= "ZO_LootHistory_GamepadEntry" or type(templateData) ~= "table" then
        return
    end

    local originalSetup = templateData.setup
    if type(originalSetup) == "function" and not templateData.nqolLootLogSetupWrapped then
        templateData.nqolLootLogSetupWrapped = true
        templateData.setup = function(control, data)
            originalSetup(control, data)
            ApplyLootLogStatusText(control, data)
        end
    end

    local originalEqualitySetup = templateData.equalitySetup
    if type(originalEqualitySetup) == "function" and not templateData.nqolLootLogEqualitySetupWrapped then
        templateData.nqolLootLogEqualitySetupWrapped = true
        templateData.equalitySetup = function(fadingControlBuffer, currentEntry, newEntry)
            originalEqualitySetup(fadingControlBuffer, currentEntry, newEntry)
            local data = currentEntry and currentEntry.lines and currentEntry.lines[1]
            if data then
                ApplyLootLogStatusText(data.control, data)
            end
        end
    end
end

local function WrapLootHistoryTemplates(history)
    if not history then
        return
    end

    if history.lootStream and type(history.lootStream.templates) == "table" then
        for templateName, templateData in pairs(history.lootStream.templates) do
            WrapLootHistoryTemplate(templateName, templateData)
        end
    end

    if history.lootStreamPersistent and type(history.lootStreamPersistent.templates) == "table" then
        for templateName, templateData in pairs(history.lootStreamPersistent.templates) do
            WrapLootHistoryTemplate(templateName, templateData)
        end
    end
end

local function InstallLootHistoryTemplateHook()
    if UI.lootHistoryTemplateHookInstalled
        or not ZO_FadingStationaryControlBuffer
        or type(ZO_FadingStationaryControlBuffer.AddTemplate) ~= "function"
    then
        return
    end

    UI.lootHistoryTemplateHookInstalled = true
    local originalAddTemplate = ZO_FadingStationaryControlBuffer.AddTemplate

    function ZO_FadingStationaryControlBuffer:AddTemplate(templateName, templateData)
        WrapLootHistoryTemplate(templateName, templateData)
        return originalAddTemplate(self, templateName, templateData)
    end
end

local function HookLootHistoryObject(history)
    if not history or hookedLootHistoryObjects[history] then
        return
    end

    if history ~= ZO_LootHistory_Shared
        and rawget(history, "CreateLootEntry") == nil
        and rawget(history, "OnNewItemReceived") == nil
    then
        return
    end

    if type(history.CreateLootEntry) ~= "function" or type(history.OnNewItemReceived) ~= "function" then
        return
    end

    hookedLootHistoryObjects[history] = true
    local originalCreateLootEntry = history.CreateLootEntry
    local originalOnNewItemReceived = history.OnNewItemReceived

    function history:CreateLootEntry(lootData)
        AddLootLogCustomData(lootData)
        return originalCreateLootEntry(self, lootData)
    end

    function history:OnNewItemReceived(itemLinkOrName, stackCount, itemSound, lootType, ...)
        if ShouldCaptureLootLogItem() and type(itemLinkOrName) == "string" then
            pendingLootLogItemLink = itemLinkOrName
            pendingLootLogItemId = GetLootLogItemIdFromLink(itemLinkOrName)
        end

        local result = originalOnNewItemReceived(self, itemLinkOrName, stackCount, itemSound, lootType, ...)
        pendingLootLogItemId = nil
        pendingLootLogItemLink = nil
        return result
    end
end

local function HookActiveLootHistoryObject()
    if SYSTEMS and type(SYSTEMS.GetObject) == "function" and ZO_LOOT_HISTORY_NAME then
        local ok, history = pcall(function()
            return SYSTEMS:GetObject(ZO_LOOT_HISTORY_NAME)
        end)
        if ok then
            HookLootHistoryObject(history)
            WrapLootHistoryTemplates(history)
            ApplyLootLogBufferSettingsToHistory(history)
        end
    end

    HookLootHistoryObject(LOOT_HISTORY_GAMEPAD)
    WrapLootHistoryTemplates(LOOT_HISTORY_GAMEPAD)
    ApplyLootLogBufferSettingsToHistory(LOOT_HISTORY_GAMEPAD)
    HookLootHistoryObject(LOOT_HISTORY_KEYBOARD)
end

local function InstallLootHistoryHook()
    if lootHistoryHookInstalled then
        HookActiveLootHistoryObject()
        return
    end

    if not ZO_LootHistory_Shared then
        return
    end

    lootHistoryHookInstalled = true
    HookLootHistoryObject(ZO_LootHistory_Shared)
    HookActiveLootHistoryObject()
end

function UI.InitializeLootLog()
    InstallLootHistoryTemplateHook()
    InstallLootHistoryHook()
end

function UI.ApplyLootLogBufferSettings()
    HookActiveLootHistoryObject()
end
