local GR = GoldRush

local DEAL_LEVELS = {
    { min = 25,  color = "22C55E" }, -- Green
    { min = 1,   color = "3B82F6" }, -- Blue
    { min = 0,   color = "FFFFFF" }, -- White
    { min = -15, color = "F97316" }, -- Orange
    { min = -math.huge, color = "EF4444" }, -- Red
}

function GR.GetDealMarginFromAvg(avgPricePerUnit, purchasePricePerUnit)
    if not avgPricePerUnit or avgPricePerUnit <= 0 or not purchasePricePerUnit then
        return nil, "888888"
    end
    local margin = math.floor(((avgPricePerUnit - purchasePricePerUnit) / avgPricePerUnit) * 100)
    for _, tier in ipairs(DEAL_LEVELS) do
        if margin >= tier.min then
            return margin, tier.color
        end
    end
    return margin, "FFFFFF"
end

-- -------------------------------------------------------------------
-- Pre‑compute averages
-- -------------------------------------------------------------------
local commitHookAttached = false

local function PreCommitHook(list)
    if list ~= ZO_TradingHouseBrowseItemsRightPaneSearchResults then
        return false
    end

    local dataList = ZO_ScrollList_GetDataList(list)
    if not dataList then return false end

    for i, entry in ipairs(dataList) do
        local data = entry.data
        if data and data.slotIndex then
            local itemLink = GetTradingHouseSearchResultItemLink(data.slotIndex)
            if itemLink then
                local normLink = GR.NormalizeItemLink(itemLink)
                if normLink then
                    data.GR_avgPricePerUnit = GR.GetItemAveragePrice(normLink) or 0
                else
                    data.GR_avgPricePerUnit = 0
                end
            else
                data.GR_avgPricePerUnit = 0
            end
        end
    end

    return false
end

local function AttachCommitHook()
    if commitHookAttached then return end
    ZO_PreHook("ZO_ScrollList_Commit", PreCommitHook)
    commitHookAttached = true
end

local function UpdateDealControl(dealControl, data)
    local purchasePricePerUnit = data.purchasePrice / data.stackCount
    local avgPrice = data.GR_avgPricePerUnit 

    if not avgPrice or avgPrice <= 0 then
        dealControl:SetText("∞")
        dealControl:SetColor(0.5, 0.5, 0.5, 1)
        return
    end

    local margin, colorHex = GR.GetDealMarginFromAvg(avgPrice, purchasePricePerUnit)
    if margin == nil then
        dealControl:SetText("∞")
        dealControl:SetColor(0.5, 0.5, 0.5, 1)
    else
        dealControl:SetText(margin .. "%")
        local r, g, b = tonumber(colorHex:sub(1,2), 16)/255,
                        tonumber(colorHex:sub(3,4), 16)/255,
                        tonumber(colorHex:sub(5,6), 16)/255
        dealControl:SetColor(r, g, b, 1)
    end
end

-- Vanilla layout
local function SetVanillaSearchResults(rowControl, data)
    local dealControl = rowControl:GetNamedChild("GR_DealLevel")
    local nameControl = rowControl:GetNamedChild("Name")
    local timeRemainingControl = rowControl:GetNamedChild("TimeRemaining")
    local sellPricePerUnitControl = rowControl:GetNamedChild("SellPricePerUnit")
    local sellPriceControl = rowControl:GetNamedChild("SellPrice")

    if not dealControl and nameControl then
        local h = nameControl:GetHeight()
        dealControl = CreateControlFromVirtual(rowControl:GetName() .. "GR_DealLevel", rowControl, "ZO_KeyboardGuildRosterRowLabel")
        -- Kept at 55 to prevent triple-digit truncation
        dealControl:SetDimensions(55, h)
        dealControl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        dealControl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        dealControl:SetFont("ZoFontGameShadow")
    end

    if dealControl and nameControl then
        nameControl:SetWidth(185) 
        timeRemainingControl:SetWidth(50)
        if sellPricePerUnitControl then sellPricePerUnitControl:SetWidth(100) end
        if sellPriceControl then sellPriceControl:SetWidth(100) end

        timeRemainingControl:ClearAnchors()
        timeRemainingControl:SetAnchor(LEFT, nameControl, RIGHT, 20)

        dealControl:ClearAnchors()
        dealControl:SetAnchor(LEFT, timeRemainingControl, RIGHT, 10)

        if sellPricePerUnitControl then
            sellPricePerUnitControl:ClearAnchors()
            sellPricePerUnitControl:SetAnchor(LEFT, dealControl, RIGHT, 10)
        end

        UpdateDealControl(dealControl, data)
    end
end

-- AGS layout
local function SetSearchResultsAGS(rowControl, data)
    local dealControl = rowControl:GetNamedChild("GR_DealLevel")
    local timeRemainingControl = rowControl:GetNamedChild("TimeRemaining")

    if not dealControl and timeRemainingControl then
        local h = timeRemainingControl:GetHeight()
        dealControl = CreateControlFromVirtual(rowControl:GetName() .. "GR_DealLevel", rowControl, "ZO_KeyboardGuildRosterRowLabel")
        dealControl:SetDimensions(55, h)
        dealControl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        dealControl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        dealControl:SetFont("ZoFontGameShadow")
    end

    if dealControl and timeRemainingControl then
        dealControl:ClearAnchors()
        dealControl:SetAnchor(TOPLEFT, timeRemainingControl, TOPRIGHT, -10, 0)
        UpdateDealControl(dealControl, data)
    end
end

local function TradingHouseSearchResultsSetupRow(rowControl, data)
    if not rowControl.dataEntry then return false end
    if not AwesomeGuildStore then
        SetVanillaSearchResults(rowControl, data)
    else
        SetSearchResultsAGS(rowControl, data)
    end
    return false 
end

-- -------------------------------------------------------------------
-- Injection initialization
-- -------------------------------------------------------------------
local hooksAttached = false

local function AttachKioskHooks()
    if hooksAttached then return end

    AttachCommitHook()

    if not TRADING_HOUSE or not TRADING_HOUSE.searchResultsList then return end

    if AwesomeGuildStore then
        for _, dataType in pairs(TRADING_HOUSE.searchResultsList.dataTypes) do
            if dataType and dataType.setupCallback then
                ZO_PreHook(dataType, "setupCallback", TradingHouseSearchResultsSetupRow)
                hooksAttached = true
            end
        end
    else
        local dataType = TRADING_HOUSE.searchResultsList.dataTypes[1]
        if dataType then
            ZO_PreHook(dataType, "setupCallback", TradingHouseSearchResultsSetupRow)
            hooksAttached = true
        end
    end
end


local function OnTradingHouseResponse(eventCode, responseType, result)
    if eventCode == EVENT_TRADING_HOUSE_RESPONSE_RECEIVED
       and responseType == TRADING_HOUSE_RESULT_SEARCH_PENDING
       and result == TRADING_HOUSE_RESULT_SUCCESS
       and TRADING_HOUSE.searchResultsList then
        AttachKioskHooks()
        ZO_ScrollList_Commit(ZO_TradingHouseBrowseItemsRightPaneSearchResults)
        EVENT_MANAGER:UnregisterForEvent("GoldRush_KioskLoad", EVENT_TRADING_HOUSE_RESPONSE_RECEIVED)
    end
end

function GR.SetupKioskRowInjections()
    AttachKioskHooks()
    EVENT_MANAGER:RegisterForEvent("GoldRush_KioskLoad", EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, OnTradingHouseResponse)
end