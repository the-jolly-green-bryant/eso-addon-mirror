NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local TransmuteWatch = {}

local FEATURE_NAME = NQOL.L("features.transmute_watch.enabled_label")
NQOL.Lexicon.RegisterRefreshCallback(function() FEATURE_NAME = NQOL.L("features.transmute_watch.enabled_label") end)

local defaults = {
    utility = {
        transmuteWatch = false,
    },
}

local GEODE_AMOUNTS = {
    [134583] = 1,
    [134588] = 5,
    [134590] = 10,
    [134591] = 50,
    [134595] = 50,
    [140222] = 1000,
    [171531] = 3,
    [178570] = 5,
    [211304] = 25,
    [211305] = 100,

    -- Random reward ranges use their maximum possible roll.
    [134618] = 25,
    [134622] = 3,
    [134623] = 10,
}

local savedVariables
local initialized = false
local useItemHookInstalled = false

local INDEX_ACTION_NAME = 1
local INDEX_ACTION_CALLBACK = 2

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "utility")
    NQOL.Settings.Boolean(settings, defaults.utility, "transmuteWatch")

    return settings
end

local function IsEnabled()
    return GetSettings().transmuteWatch == true
end

local function IsApiAvailable()
    return type(GetCurrencyAmount) == "function"
        and type(GetMaxPossibleCurrency) == "function"
        and type(GetItemType) == "function"
        and CURT_CHAOTIC_CREATIA ~= nil
        and CURRENCY_LOCATION_ACCOUNT ~= nil
end

local function GetInventoryItemId(bagId, slotIndex)
    if type(GetItemId) == "function" then
        return GetItemId(bagId, slotIndex)
    end

    if type(GetItemLink) == "function" and type(GetItemLinkItemId) == "function" then
        local itemLink = GetItemLink(bagId, slotIndex)
        if itemLink and itemLink ~= "" then
            return GetItemLinkItemId(itemLink)
        end
    end

    return nil
end

local function GetTransmuteCap()
    if not IsApiAvailable() then
        return nil
    end

    return GetMaxPossibleCurrency(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)
end

local function GetCurrentTransmutes()
    if not IsApiAvailable() then
        return nil
    end

    return GetCurrencyAmount(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)
end

local function GetTransmutePackageAmount(bagId, slotIndex)
    if bagId ~= BAG_BACKPACK or not IsApiAvailable() then
        return nil
    end

    local itemType = GetItemType(bagId, slotIndex)
    if itemType ~= ITEMTYPE_CONTAINER
        and itemType ~= ITEMTYPE_CONTAINER_CURRENCY
        and itemType ~= ITEMTYPE_CONTAINER_STACKABLE
    then
        return nil
    end

    local itemId = GetInventoryItemId(bagId, slotIndex)
    return GEODE_AMOUNTS[itemId]
end

local FormatNumber = NQOL.Util.FormatNumber

local function ShowCenterScreenAlert(message)
    if CENTER_SCREEN_ANNOUNCE and CENTER_SCREEN_ANNOUNCE.CreateMessageParams then
        local sound = SOUNDS and SOUNDS.NEGATIVE_CLICK or nil
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, sound)
        messageParams:SetText(message)

        if messageParams.SetCSAType and CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT then
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
        end

        if messageParams.SetLifespanMS then
            messageParams:SetLifespanMS(3500)
        end

        if CENTER_SCREEN_ANNOUNCE.AddMessageWithParams then
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        elseif CENTER_SCREEN_ANNOUNCE.DisplayMessage then
            CENTER_SCREEN_ANNOUNCE:DisplayMessage(messageParams)
        end
    end

    if ZO_Alert then
        local category = UI_ALERT_CATEGORY_ALERT or UI_ALERT_CATEGORY_ERROR
        local sound = SOUNDS and SOUNDS.NEGATIVE_CLICK or nil
        ZO_Alert(category, sound, message)
    end
end

local function LogBlocked(amount, current, cap)
    local message = NQOL.L("features.transmute_watch.blocked", FormatNumber(current), FormatNumber(amount), FormatNumber(cap))

    ShowCenterScreenAlert(message)
    NQOL.Chat.Message(message, FEATURE_NAME)
end

local function ShouldBlockUseItem(bagId, slotIndex, announce)
    if not IsEnabled() then
        return false
    end

    local packageAmount = GetTransmutePackageAmount(bagId, slotIndex)
    if not packageAmount or packageAmount <= 0 then
        return false
    end

    local currentTransmutes = GetCurrentTransmutes()
    local transmuteCap = GetTransmuteCap()
    if not currentTransmutes or not transmuteCap or transmuteCap <= 0 then
        return false
    end

    if currentTransmutes + packageAmount <= transmuteCap then
        return false
    end

    if announce then
        LogBlocked(packageAmount, currentTransmutes, transmuteCap)
    end

    return true
end

local function InstallUseItemHook()
    if useItemHookInstalled
        or not SecurePostHook
        or type(ZO_InventorySlot_DiscoverSlotActionsFromActionList) ~= "function" then
        return
    end

    useItemHookInstalled = true

    SecurePostHook(_G, "ZO_InventorySlot_DiscoverSlotActionsFromActionList", function(inventorySlot, slotActions)
        if not inventorySlot or not slotActions or not slotActions.m_slotActions or not ZO_Inventory_GetBagAndIndex then
            return
        end

        local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
        if not ShouldBlockUseItem(bagId, slotIndex, false) then
            return
        end

        local primaryAction = slotActions.m_slotActions[1]
        if not primaryAction or primaryAction[INDEX_ACTION_NAME] ~= GetString(SI_ITEM_ACTION_USE) then
            return
        end

        primaryAction[INDEX_ACTION_CALLBACK] = function()
            ShouldBlockUseItem(bagId, slotIndex, true)
        end
    end)
end

function TransmuteWatch.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function TransmuteWatch.Initialize()
    if initialized then
        return
    end

    initialized = true
    InstallUseItemHook()
end

function TransmuteWatch.GetEnabled()
    return IsEnabled()
end

function TransmuteWatch.GetEnabledDefault()
    return defaults.utility.transmuteWatch
end

function TransmuteWatch.SetEnabled(value)
    GetSettings().transmuteWatch = value == true
end

function TransmuteWatch.GetEnabledLabel()
    return NQOL.L("features.transmute_watch.enabled_label")
end

function TransmuteWatch.GetEnabledTooltip()
    return NQOL.L("features.transmute_watch.enabled_tooltip")
end

NQOL.Features.TransmuteWatch = TransmuteWatch
