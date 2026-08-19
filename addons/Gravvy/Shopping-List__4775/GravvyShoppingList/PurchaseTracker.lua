ShoppingListPurchaseTracker = {}

local Tracker = ShoppingListPurchaseTracker

function Tracker:New(owner)
    return setmetatable({ owner = owner, pending = nil, useAGS = false }, { __index = self })
end

function Tracker:Initialize(useAGS)
    self.useAGS = useAGS

    EVENT_MANAGER:RegisterForEvent(
        "GravvyShoppingList_PendingPurchase",
        EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE,
        function(_, index) self:Capture(index) end
    )
    EVENT_MANAGER:RegisterForEvent(
        "GravvyShoppingList_PurchaseResponse",
        EVENT_TRADING_HOUSE_RESPONSE_RECEIVED,
        function(_, responseType, result) self:OnResponse(responseType, result) end
    )
    EVENT_MANAGER:RegisterForEvent(
        "GravvyShoppingList_PurchaseError",
        EVENT_TRADING_HOUSE_ERROR,
        function() self.pending = nil end
    )
    EVENT_MANAGER:RegisterForEvent(
        "GravvyShoppingList_PurchaseTimeout",
        EVENT_TRADING_HOUSE_OPERATION_TIME_OUT,
        function(_, responseType)
            if responseType == TRADING_HOUSE_RESULT_PURCHASE_PENDING then
                self.pending = nil
            end
        end
    )
end

function Tracker:Capture(index)
    if self.useAGS or not index then
        return
    end

    local _, itemName, _, stackCount, sellerName, _, purchasePrice, currencyType, _, unitPrice =
        GetTradingHouseSearchResultItemInfo(index)
    local itemLink = GetTradingHouseSearchResultItemLink(index, LINK_STYLE_DEFAULT)
    if not itemLink or itemLink == "" then
        self.pending = nil
        return
    end

    local guildName
    if GetCurrentTradingHouseGuildDetails then
        local _, currentGuildName = GetCurrentTradingHouseGuildDetails()
        guildName = currentGuildName
    end

    self.pending = {
        itemLink = itemLink,
        itemName = itemName,
        stackCount = stackCount,
        purchase = {
            quantity = stackCount,
            totalPrice = purchasePrice,
            unitPrice = unitPrice,
            sellerName = sellerName,
            guildName = guildName,
            currencyType = currencyType,
            timestamp = GetTimeStamp(),
        },
    }
end

function Tracker:OnResponse(responseType, result)
    if self.useAGS or responseType ~= TRADING_HOUSE_RESULT_PURCHASE_PENDING then
        return
    end

    local pending = self.pending
    self.pending = nil
    if pending and result == TRADING_HOUSE_RESULT_SUCCESS then
        self.owner:RecordPurchase(
            pending.itemLink,
            pending.itemName,
            pending.stackCount,
            pending.purchase
        )
    end
end
