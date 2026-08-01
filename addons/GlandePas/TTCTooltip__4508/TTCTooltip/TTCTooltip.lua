TTCTooltip       = {}
TTCTooltip.Panel = ZO_Object:Subclass()

local HEADER_HEIGHT = 60
local ROW_HEIGHT    = 20
local ROW_GAP       = 2
local BOTTOM_PAD    = 10

-- Compact 3-significant-digit formatter.
-- precise=true gives decimal places for values < 100 (used for averages).
local function ShortNum(n, precise)
    if n == nil then return "?" end
    local abs = math.abs(n)
    if     abs >= 100000000 then return string.format("%.0fM", n / 1000000)
    elseif abs >= 10000000  then return string.format("%.1fM", n / 1000000)
    elseif abs >= 1000000   then return string.format("%.2fM", n / 1000000)
    elseif abs >= 100000    then return string.format("%.0fk", n / 1000)
    elseif abs >= 10000     then return string.format("%.1fk", n / 1000)
    elseif abs >= 1000      then return string.format("%.2fk", n / 1000)
    elseif not precise or abs >= 100 then return string.format("%.0f",  n)
    elseif abs >= 10        then return string.format("%.1f",  n)
    else                         return string.format("%.2f",  n)
    end
end

----------------------------------------------------------------------------

function TTCTooltip.Panel:New(control, tooltip)
    local obj = ZO_Object.New(self)
    obj.control = control
    obj.tooltip = tooltip

    -- Parent
    obj.panel = control:GetNamedChild("TTCTooltipPanel")

    -- Static header
    obj.headerDate      = control:GetNamedChild("HeaderRowDate")

    -- Recommended row
    obj.recommRow = control:GetNamedChild("RecommRow")
    obj.recommLbl = control:GetNamedChild("RecommRowLabel")
    obj.recommAvg = control:GetNamedChild("RecommRowAvg")
    obj.recommRng = control:GetNamedChild("RecommRowRange")
    obj.recommCnt = control:GetNamedChild("RecommRowCount")

    -- Sales row
    obj.saleRow = control:GetNamedChild("SaleRow")
    obj.saleLbl = control:GetNamedChild("SaleRowLabel")
    obj.saleAvg = control:GetNamedChild("SaleRowAvg")
    obj.saleCnt = control:GetNamedChild("SaleRowCount")

    -- Listings row
    obj.listRow = control:GetNamedChild("ListRow")
    obj.listLbl = control:GetNamedChild("ListRowLabel")
    obj.listAvg = control:GetNamedChild("ListRowAvg")
    obj.listRng = control:GetNamedChild("ListRowRange")
    obj.listCnt = control:GetNamedChild("ListRowCount")

    -- Column header text (static, set once)
    control:GetNamedChild("HeaderRowSuggested"):SetText("TTC")
    control:GetNamedChild("ColHeaderRowAvgHeader"):SetText("Avg.")
    control:GetNamedChild("ColHeaderRowRangeHeader"):SetText("Min/Max")
    control:GetNamedChild("ColHeaderRowCountHeader"):SetText("Count")

    obj:HookTooltip()
    return obj
end

----------------------------------------------------------------------------

function TTCTooltip.Panel:HookTooltip()
    local function Update(tt, itemLink)
        if not TamrielTradeCentre:IsItemLink(itemLink) then return end
        local itemInfo = TamrielTradeCentre_ItemInfo:New(itemLink)
        if itemInfo == nil then return end
        local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemInfo)
        if priceInfo == nil then return end
        self:UpdateLabels(priceInfo)
        tt:AddControl(self.control, 0, false)
        self.control:SetAnchor(CENTER)
        self.control:SetHidden(false)
    end

    -- Wraps one tooltip method; each call creates a fresh `base` local
    -- so closures are fully independent (no shared-upvalue).
    local t = self.tooltip
    local function Hook(name, getLinkFn)
        local base = t[name]
        t[name] = function(tt, ...)
            base(tt, ...)
            Update(tt, getLinkFn(...))
        end
    end

    Hook("SetLink",                function(link)         return link end)
    Hook("SetBagItem",             function(bag, index)   return GetItemLink(bag, index) end)
    Hook("SetWornItem",            function(slot)         return GetItemLink(BAG_WORN, slot) end)
    Hook("SetLootItem",            function(id)           return GetLootItemLink(id) end)
    Hook("SetStoreItem",           function(index)        return GetStoreItemLink(index) end)
    Hook("SetBuybackItem",         function(index)        return GetBuybackItemLink(index) end)
    Hook("SetTradeItem",           function(tt, index)    return GetTradeItemLink(tt, index) end)
    Hook("SetTradingHouseItem",    function(index)        return GetTradingHouseSearchResultItemLink(index) end)
    Hook("SetTradingHouseListing", function(index)        return GetTradingHouseListingItemLink(index) end)
    Hook("SetAttachedMailItem",    function(mailId, i)    return GetAttachedItemLink(mailId, i) end)
    Hook("SetQuestReward",         function(index)        return GetQuestRewardItemLink(index) end)
end

----------------------------------------------------------------------------

local function FormatCount(n, m)
    -- "N/M" when counts differ, "N" when equal
    if n ~= m then
        return TamrielTradeCentre:FormatNumber(n) .. "/" .. TamrielTradeCentre:FormatNumber(m)
    else
        return TamrielTradeCentre:FormatNumber(n)
    end
end

function TTCTooltip.Panel:UpdateLabels(priceInfo)
    -- Header
    self.headerDate:SetText(TamrielTradeCentrePrice:GetPriceTableUpdatedDateString())
    local height = HEADER_HEIGHT

    -- Recommended row
    local showRecomm = priceInfo.SuggestedPrice ~= nil
    self.recommRow:SetHidden(not showRecomm)
    if showRecomm then
        self.recommLbl:SetText("Suggest.")
        self.recommAvg:SetText("")
        self.recommRng:SetText(string.format("%s-%s",
            ShortNum(priceInfo.SuggestedPrice, true),
            ShortNum(priceInfo.SuggestedPrice * 1.25, true)))
        self.recommCnt:SetText("")
        self.recommRow:ClearAnchors()
        self.recommRow:SetAnchor(TOPLEFT,  self.panel, TOPLEFT,  0, height)
        height = height + ROW_HEIGHT + ROW_GAP
    end

    -- Sales row
    local showSales = priceInfo.SaleAvg ~= nil
    self.saleRow:SetHidden(not showSales)
    if showSales then
        self.saleLbl:SetText("Sales")
        self.saleAvg:SetText(ShortNum(priceInfo.SaleAvg, true))
        self.saleCnt:SetText(FormatCount(priceInfo.SaleEntryCount, priceInfo.SaleAmountCount))
        self.saleRow:ClearAnchors()
        self.saleRow:SetAnchor(TOPLEFT,  self.panel, TOPLEFT,  0, height)
        height = height + ROW_HEIGHT + ROW_GAP
    end

    -- Listings row (always shown)
    self.listRow:SetHidden(false)
    self.listLbl:SetText("Listings")
    self.listAvg:SetText(ShortNum(priceInfo.Avg, true))
    self.listRng:SetText(ShortNum(priceInfo.Min) .. "-" .. ShortNum(priceInfo.Max))
    self.listCnt:SetText(FormatCount(priceInfo.EntryCount, priceInfo.AmountCount))
    self.listRow:ClearAnchors()
    self.listRow:SetAnchor(TOPLEFT,  self.panel, TOPLEFT,  0, height)
    height = height + ROW_HEIGHT

    self.control:SetHeight(height + BOTTOM_PAD)
end

----------------------------------------------------------------------------

local function OnAddOnLoaded(_, addonName)
    if addonName ~= "TTCTooltip" then return end
    CreateControlFromVirtual("TTCTooltipItemTooltipPanel",  GuiRoot, "TTCTooltipItemTooltipTemplate")
    CreateControlFromVirtual("TTCTooltipPopupTooltipPanel", GuiRoot, "TTCTooltipPopupTooltipTemplate")
    EVENT_MANAGER:UnregisterForEvent("TTCTooltip", EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent("TTCTooltip", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
