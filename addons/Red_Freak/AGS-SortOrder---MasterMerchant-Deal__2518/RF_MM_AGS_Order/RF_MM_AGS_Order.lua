local version = '0.0.1 beta'
local addonName = "red_Freak's MasterMerchant AwesomeGuildStore Order"
local AGS = AwesomeGuildStore
local MM = MasterMerchant

-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
RF_MM_AGS_Order = {
    addonName = addonName,
    loaded = false,
    MMloaded = false,
    AGSloaded = false,
    SORT_ORDER_ID = 100,
    SORT_ORDER_LABEL = "Deal",
    classes = {
        AGS = AGS,
        MM = MM,
        SortOrderBase = AGS.class.SortOrderBase,
        SortOrderDeal = AGS.class.SortOrderBase:Subclass()
    }
}

-- define the constructor of our class
function RF_MM_AGS_Order.classes.SortOrderDeal:New(...)
    return RF_MM_AGS_Order.classes.SortOrderBase.New(self, ...)
end

-- define the hook
function RF_MM_AGS_Order.classes.SortOrderDeal:Initialize()
    RF_MM_AGS_Order.classes.SortOrderBase.Initialize(self, RF_MM_AGS_Order.SORT_ORDER_ID, RF_MM_AGS_Order.SORT_ORDER_LABEL, function(a, b)
        local index = a.itemUniqueId
        local itemLink_a = GetTradingHouseSearchResultItemLink(index)
        index = b.itemUniqueId
        local itemLink_b = GetTradingHouseSearchResultItemLink(index)

        local x, margin_a, x = RF_MM_AGS_Order.classes.MM.GetDealInfo(itemLink_a, a.purchasePrice, a.stackCount)
        local x, margin_b, x = RF_MM_AGS_Order.classes.MM.GetDealInfo(itemLink_b, b.purchasePrice, b.stackCount)

        if (margin_a == margin_b) then
            return 0
        end
        return margin_a < margin_b and 1 or -1
    end)
end

function RF_MM_AGS_Order:registerHook()
    if (not (RF_MM_AGS_Order.loaded) and RF_MM_AGS_Order.MMloaded and RF_MM_AGS_Order.AGSloaded) then
        -- CHAT_SYSTEM:AddMessage('|cCCCCCCRF_MM_AGS_Order Debug:|r registerHook')
        RF_MM_AGS_Order.classes.AGS:RegisterSortOrder(RF_MM_AGS_Order.classes.SortOrderDeal:New())
        RF_MM_AGS_Order.loaded = true
    end
end

-- initialize after MM loaded
function RF_MM_AGS_Order:initMM()
    -- CHAT_SYSTEM:AddMessage('|cCCCCCCRF_MM_AGS_Order Debug:|r initMM')
    RF_MM_AGS_Order.MMloaded = true
    RF_MM_AGS_Order:registerHook()
end

-- initialize after AGS loaded
function RF_MM_AGS_Order:initAGS()
    -- CHAT_SYSTEM:AddMessage('|cCCCCCCRF_MM_AGS_Order Debug:|r initAGS')
    RF_MM_AGS_Order.classes.AGS:RegisterCallback(RF_MM_AGS_Order.classes.AGS.callback.AFTER_INITIAL_SETUP,
        function(...)
        end)
    RF_MM_AGS_Order.classes.AGS:RegisterCallback(RF_MM_AGS_Order.classes.AGS.callback.AFTER_FILTER_SETUP,
        function(...)
            CHAT_SYSTEM:AddMessage('|cCCCCCCRF_MM_AGS_Order Debug:|r initAGS-callback')
            RF_MM_AGS_Order.AGSloaded = true
            RF_MM_AGS_Order:registerHook()
        end)
end

local function OnAddOnLoaded(eventCode, addOnName)
    if addOnName:find('^ZO_') then return end
    if addOnName == "MasterMerchant" then
        RF_MM_AGS_Order:initMM()
    elseif addOnName == "AwesomeGuildStore" then
        RF_MM_AGS_Order:initAGS()
    elseif addOnName == RF_MM_AGS_Order.addonName then
        RF_MM_AGS_Order:registerHook()
    end
end

-- Register for the OnAddOnLoaded event
EVENT_MANAGER:RegisterForEvent(RF_MM_AGS_Order.addonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
