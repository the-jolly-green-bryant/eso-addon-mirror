-- TTC Price v1.4 - Listing Inspector
-- Author: @NPViral
-- Evaluates your own guild-store listings against current TTC market data.

local TP = TTCPrice
if not TP then return end

local Inspector = {}
TP.ListingInspector = Inspector

local LISTING_LIFETIME_SECONDS = 30 * 24 * 60 * 60
local MIN_SALE_COUNT = 5

local ICON_SIZE = 18
local ICON_OFFSET_X = -90

local ICON_GOOD = ZO_CHECK_ICON or "EsoUI/Art/Miscellaneous/check_icon_32.dds"
local ICON_DRIFT = "EsoUI/Art/Miscellaneous/ESO_Icon_Warning.dds"
local ICON_WAITING = ZO_TIMER_ICON_32 or "EsoUI/Art/Miscellaneous/timer_32.dds"

local STATE_GOOD = "good"
local STATE_DRIFT = "drift"
local STATE_WAITING = "waiting"

local rowHookInstalled = false

local function GetTTCData(itemLink)
    if not TamrielTradeCentrePrice
        or type(TamrielTradeCentrePrice.GetPriceInfo) ~= "function" then
        return nil
    end
    return TamrielTradeCentrePrice:GetPriceInfo(itemLink)
end

local function GetSettings()
    if type(TP.GetListingInspectorSettings) == "function" then
        return TP.GetListingInspectorSettings()
    end
    return true, 5, 3
end

local function FormatAge(ageDays)
    if not ageDays then return "-" end
    if ageDays < 1 then
        return string.format("%.1f hours", ageDays * 24)
    end
    return string.format("%.1f days", ageDays)
end

local function RefreshVisibleRows()
    local list = TRADING_HOUSE and TRADING_HOUSE.postedItemsList
    if list and type(ZO_ScrollList_RefreshVisible) == "function" then
        ZO_ScrollList_RefreshVisible(list)
    end
end

function Inspector:Refresh()
    RefreshVisibleRows()
end

local function EnsureStatusControl(rowControl)
    if rowControl.TTCPriceListingStatus then
        return rowControl.TTCPriceListingStatus
    end

    local control = WINDOW_MANAGER:CreateControl(nil, rowControl, CT_TEXTURE)
    control:SetDimensions(ICON_SIZE, ICON_SIZE)
    control:SetAnchor(RIGHT, rowControl, RIGHT, ICON_OFFSET_X, 0)
    control:SetDrawLayer(DL_OVERLAY)
    control:SetMouseEnabled(true)
    control:SetHidden(true)

    control:SetHandler("OnMouseEnter", function(self)
        if not self.ttcPriceTooltipTitle or not self.ttcPriceTooltipReason then return end

        InitializeTooltip(InformationTooltip, self, TOP)
        InformationTooltip:AddLine(
            self.ttcPriceTooltipTitle,
            "ZoFontWinH4",
            ZO_HIGHLIGHT_TEXT:UnpackRGB()
        )
        InformationTooltip:AddLine(
            self.ttcPriceTooltipReason,
            "ZoFontGame",
            ZO_NORMAL_TEXT:UnpackRGB()
        )
    end)
    control:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)

    rowControl.TTCPriceListingStatus = control
    return control
end

local function ResetStatus(control)
    control.ttcPriceTooltipTitle = nil
    control.ttcPriceTooltipReason = nil
    control:SetHidden(true)
end

local function GetLiveState(postedItem)
    local enabled, driftThreshold, waitingDays = GetSettings()
    if not enabled then return nil end

    local itemLink = postedItem and postedItem.itemLink
    local unitPrice = postedItem and tonumber(postedItem.purchasePricePerUnit)
    local timeRemaining = postedItem and tonumber(postedItem.timeRemaining)

    if not itemLink or itemLink == "" or not unitPrice or unitPrice <= 0 or not timeRemaining then
        return nil
    end

    local ttc = GetTTCData(itemLink)
    local saleAvg = type(ttc) == "table" and tonumber(ttc.SaleAvg) or nil
    local saleCount = type(ttc) == "table" and (tonumber(ttc.SaleEntryCount) or 0) or 0
    if not saleAvg or saleAvg <= 0 or saleCount < MIN_SALE_COUNT then
        return nil
    end

    driftThreshold = tonumber(driftThreshold) or 5
    waitingDays = tonumber(waitingDays) or 3

    local ageSeconds = math.max(0, math.min(LISTING_LIFETIME_SECONDS, LISTING_LIFETIME_SECONDS - timeRemaining))
    local ageDays = ageSeconds / (24 * 60 * 60)
    local drift = ((unitPrice / saleAvg) - 1) * 100

    -- TTC documents SuggestedPrice as the low end of its suggested range.
    -- The high end is SuggestedPrice * 1.25. The suggested range is only a
    -- sanity check: it can prevent a SaleAvg-only
    -- false warning, but it never creates a Price Drift state by itself.
    local suggestedLow = type(ttc) == "table" and tonumber(ttc.SuggestedPrice) or nil
    if suggestedLow and suggestedLow <= 0 then
        suggestedLow = nil
    end
    local suggestedHigh = suggestedLow and (suggestedLow * 1.25) or nil

    local saleAvgDrifted = drift >= driftThreshold
    local aboveSuggestedRange = not suggestedHigh or unitPrice > suggestedHigh
    local isPriceDrift = saleAvgDrifted and aboveSuggestedRange

    local state
    if isPriceDrift then
        state = STATE_DRIFT
    elseif ageDays >= waitingDays then
        state = STATE_WAITING
    else
        state = STATE_GOOD
    end

    return state, {
        ageDays = ageDays,
        drift = drift,
        saleAvgDrifted = saleAvgDrifted,
        unitPrice = unitPrice,
        suggestedLow = suggestedLow,
        suggestedHigh = suggestedHigh,
    }
end

local function BuildLiveTooltip(state, data)
    if state == STATE_DRIFT then
        return "Price Drift", string.format(
            "%.1f%% above TTC Sale Avg.",
            data.drift
        )
    end

    if state == STATE_WAITING then
        return "Still Waiting", string.format(
            "Price looks good after %s.",
            FormatAge(data.ageDays)
        )
    end

    if state == STATE_GOOD then
        if data.drift < -1 then
            return "Looks Good", "Price is below TTC Sale Avg."
        end
        if data.saleAvgDrifted and data.suggestedHigh then
            if data.suggestedLow and data.unitPrice < data.suggestedLow then
                return "Looks Good", "Price is below TTC range."
            end
            return "Looks Good", "Price is within TTC range."
        end
        return "Looks Good", "Price is close to TTC Sale Avg."
    end

    return nil, nil
end

local function ApplyState(control, state, tooltipTitle, tooltipReason)
    if state == STATE_DRIFT then
        control:SetTexture(ICON_DRIFT)
        control:SetColor(1.00, 0.64, 0.12, 1)
    elseif state == STATE_WAITING then
        control:SetTexture(ICON_WAITING)
        control:SetColor(0.58, 0.78, 1.00, 0.95)
    elseif state == STATE_GOOD then
        control:SetTexture(ICON_GOOD)
        control:SetColor(0.50, 0.90, 0.50, 0.95)
    else
        ResetStatus(control)
        return
    end

    control.ttcPriceTooltipTitle = tooltipTitle
    control.ttcPriceTooltipReason = tooltipReason
    control:SetHidden(false)
end

local function SetupListingStatus(rowControl, postedItem)
    local control = EnsureStatusControl(rowControl)
    ResetStatus(control)

    local enabled = GetSettings()
    if not enabled then return end

    local state, data = GetLiveState(postedItem)
    if not state then return end

    local title, reason = BuildLiveTooltip(state, data)
    ApplyState(control, state, title, reason)
end

function Inspector:TryInstallRowHook()
    if rowHookInstalled then return true end

    local list = TRADING_HOUSE and TRADING_HOUSE.postedItemsList
    local dataTypes = list and list.dataTypes
    local rowType = dataTypes and dataTypes[2]
    local originalSetupCallback = rowType and rowType.setupCallback
    if type(originalSetupCallback) ~= "function" then
        return false
    end

    rowType.setupCallback = function(rowControl, postedItem, ...)
        originalSetupCallback(rowControl, postedItem, ...)
        local ok = pcall(SetupListingStatus, rowControl, postedItem)
        if not ok and rowControl and rowControl.TTCPriceListingStatus then
            ResetStatus(rowControl.TTCPriceListingStatus)
        end
    end

    rowHookInstalled = true
    RefreshVisibleRows()
    return true
end

function Inspector:Initialize()
    self:TryInstallRowHook()
end
