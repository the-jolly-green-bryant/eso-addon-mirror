NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local Gear = {}

local CHARGE_THRESHOLD_MIN = 1
local CHARGE_THRESHOLD_MAX = 99
local CHARGE_THRESHOLD_DEFAULT = 10
local REPAIR_THRESHOLD_MIN = 1
local REPAIR_THRESHOLD_MAX = 99
local REPAIR_THRESHOLD_DEFAULT = 10
local RETRY_DELAY_MS = 3000
local VERIFY_DELAY_MS = 250
local REPAIR_VERIFY_DELAY_MS = 1000
local EVENT_NAMESPACE = "NQOL_Gear"
local REPAIR_KIT_TYPE_NORMAL = 1
local REPAIR_KIT_TYPE_CROWN = 2

local defaults = {
    gear = {
        autoCharge = false,
        chargeThreshold = CHARGE_THRESHOLD_DEFAULT,
        autoRepair = false,
        repairThreshold = REPAIR_THRESHOLD_DEFAULT,
        repairAllInMerchants = false,
        autoBound = false,
        logCharge = false,
        logRepair = false,
        logBind = false,
    },
}

local weaponSlots = {
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
}

local savedVariables
local eventsRegistered = false
local pendingCharge = false
local pendingRepair = false
local retryQueued = false
local HasUsableWornItem
local QueueRetry

local function GetBackpackItemLink(slotId)
    if GetItemLink then
        local itemLink = GetItemLink(BAG_BACKPACK, slotId, LINK_STYLE_BRACKETS)
        if itemLink and itemLink ~= "" then
            return itemLink
        end
    end

    return "gear"
end

local function GetWornItemLink(slotId)
    if GetItemLink then
        local itemLink = GetItemLink(BAG_WORN, slotId, LINK_STYLE_BRACKETS)
        if itemLink and itemLink ~= "" then
            return itemLink
        end
    end

    return "gear"
end

local function Log(message)
    NQOL.Chat.Message(message, NQOL.L("common.feature.gear"))
end

local function LogChargeIfSuccessful(slotId, itemLink, previousCharge)
    zo_callLater(function()
        if not GetChargeInfoForItem or not HasUsableWornItem(slotId) then
            return
        end

        local charge = GetChargeInfoForItem(BAG_WORN, slotId)
        if charge and previousCharge and charge > previousCharge then
            Log(NQOL.L("features.gear.charged", itemLink))
        end
    end, VERIFY_DELAY_MS)
end

local function VerifyRepairAttempt(slotId, itemLink, previousCondition)
    zo_callLater(function()
        if not GetItemCondition or not HasUsableWornItem(slotId) then
            return
        end

        local condition = GetItemCondition(BAG_WORN, slotId)
        if condition and previousCondition and condition > previousCondition then
            if Gear.GetLogRepair() then
                Log(NQOL.L("features.gear.repaired", itemLink))
            end
            return
        end

        pendingRepair = true
        QueueRetry()
    end, REPAIR_VERIFY_DELAY_MS)
end

local function LogBoundIfSuccessful(slotId, itemLink)
    zo_callLater(function()
        if IsItemBound and IsItemBound(BAG_BACKPACK, slotId) then
            Log(NQOL.L("features.gear.bound", itemLink))
        end
    end, VERIFY_DELAY_MS)
end

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "gear")
    local defaultSettings = defaults.gear

    NQOL.Settings.Default(settings, defaultSettings, "autoCharge")
    NQOL.Settings.Default(settings, defaultSettings, "chargeThreshold")
    NQOL.Settings.Default(settings, defaultSettings, "autoRepair")
    NQOL.Settings.Default(settings, defaultSettings, "repairThreshold")
    NQOL.Settings.Default(settings, defaultSettings, "repairAllInMerchants")
    NQOL.Settings.Default(settings, defaultSettings, "autoBound")
    NQOL.Settings.Default(settings, defaultSettings, "logCharge")
    NQOL.Settings.Default(settings, defaultSettings, "logRepair")
    NQOL.Settings.Default(settings, defaultSettings, "logBind")

    return settings
end

local function IsBlocked()
    if IsUnitInCombat and IsUnitInCombat("player") then
        return true
    end

    if IsUnitDeadOrReincarnating and IsUnitDeadOrReincarnating("player") then
        return true
    end

    return IsUnitDead and IsUnitDead("player")
end

QueueRetry = function()
    if retryQueued then
        return
    end

    retryQueued = true
    zo_callLater(function()
        retryQueued = false
        Gear.TryPending()
    end, RETRY_DELAY_MS)
end

local function FindFilledSoulGem()
    if not IsItemSoulGem or not GetBagSize then
        return nil
    end

    local crownSoulGemSlot

    for slotId = 0, GetBagSize(BAG_BACKPACK) do
        if IsItemSoulGem(SOUL_GEM_TYPE_FILLED, BAG_BACKPACK, slotId) then
            if not IsItemFromCrownStore or not IsItemFromCrownStore(BAG_BACKPACK, slotId) then
                return slotId
            end

            if not crownSoulGemSlot then
                crownSoulGemSlot = slotId
            end
        end
    end

    return crownSoulGemSlot
end

local function FindRepairKit()
    if not IsItemRepairKit or not IsItemNonCrownRepairKit or not IsItemNonGroupRepairKit or not GetBagSize then
        return nil
    end

    local crownRepairKitSlot

    for slotId = 0, GetBagSize(BAG_BACKPACK) do
        if IsItemRepairKit(BAG_BACKPACK, slotId)
            and IsItemNonGroupRepairKit(BAG_BACKPACK, slotId)
        then
            if IsItemNonCrownRepairKit(BAG_BACKPACK, slotId) then
                return slotId, REPAIR_KIT_TYPE_NORMAL
            end

            if not crownRepairKitSlot then
                crownRepairKitSlot = slotId
            end
        end
    end

    if crownRepairKitSlot then
        return crownRepairKitSlot, REPAIR_KIT_TYPE_CROWN
    end

    return nil
end

local function IsGearItem(bagId, slotId)
    if not GetItemType then
        return false
    end

    local itemType = GetItemType(bagId, slotId)
    return itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON
end

local function IsBindableItem(bagId, slotId)
    if IsItemBound and IsItemBound(bagId, slotId) then
        return false
    end

    if GetItemBindType then
        local bindType = GetItemBindType(bagId, slotId)
        return bindType ~= BIND_TYPE_NONE and bindType ~= BIND_TYPE_UNSET
    end

    return true
end

local function IsUncollectedSetCollectionPiece(bagId, slotId)
    if not GetItemLink
        or not IsItemLinkSetCollectionPiece
        or not GetItemLinkItemId
        or not IsItemSetCollectionPieceUnlocked
    then
        return false
    end

    local itemLink = GetItemLink(bagId, slotId, LINK_STYLE_DEFAULT)
    if not itemLink or itemLink == "" or not IsItemLinkSetCollectionPiece(itemLink) then
        return false
    end

    local itemId = GetItemLinkItemId(itemLink)
    return itemId and itemId > 0 and not IsItemSetCollectionPieceUnlocked(itemId)
end

HasUsableWornItem = function(slotId)
    return HasItemInSlot and HasItemInSlot(BAG_WORN, slotId)
end

local function TryBindSlot(slotId)
    if not Gear.GetAutoBound()
        or not BindItem
        or not IsGearItem(BAG_BACKPACK, slotId)
        or not IsBindableItem(BAG_BACKPACK, slotId)
        or not IsUncollectedSetCollectionPiece(BAG_BACKPACK, slotId)
    then
        return false
    end

    local itemLink = GetBackpackItemLink(slotId)
    local succeeded = pcall(BindItem, BAG_BACKPACK, slotId)
    if succeeded and Gear.GetLogBind() then
        LogBoundIfSuccessful(slotId, itemLink)
    end

    return succeeded
end

local function TryChargeSlot(slotId)
    if not Gear.GetAutoCharge()
        or not HasUsableWornItem(slotId)
        or not GetChargeInfoForItem
        or not ChargeItemWithSoulGem
    then
        return false
    end

    local charge, maxCharge = GetChargeInfoForItem(BAG_WORN, slotId)
    if not charge or not maxCharge or maxCharge <= 0 then
        return false
    end

    if (charge / maxCharge) * 100 > Gear.GetChargeThreshold() then
        return false
    end

    local soulGemSlot = FindFilledSoulGem()
    if not soulGemSlot then
        return false
    end

    if IsBlocked() then
        pendingCharge = true
        QueueRetry()
        return false
    end

    local itemLink = GetWornItemLink(slotId)
    local succeeded = pcall(ChargeItemWithSoulGem, BAG_WORN, slotId, BAG_BACKPACK, soulGemSlot)
    if not succeeded then
        pendingCharge = true
        QueueRetry()
    elseif Gear.GetLogCharge() then
        LogChargeIfSuccessful(slotId, itemLink, charge)
    end

    return succeeded
end

local function TryRepairSlot(slotId)
    if not Gear.GetAutoRepair()
        or not HasUsableWornItem(slotId)
        or not DoesItemHaveDurability
        or not GetItemCondition
    then
        return false
    end

    if not DoesItemHaveDurability(BAG_WORN, slotId) then
        return false
    end

    local condition = GetItemCondition(BAG_WORN, slotId)
    if not condition or condition > Gear.GetRepairThreshold() then
        return false
    end

    local repairKitSlot, repairKitType = FindRepairKit()
    if not repairKitSlot then
        return false
    end

    if IsBlocked() then
        pendingRepair = true
        QueueRetry()
        return false
    end

    local itemLink = GetWornItemLink(slotId)
    local attempted = false
    if repairKitType == REPAIR_KIT_TYPE_CROWN then
        if CallSecureProtected then
            local callSucceeded, useSucceeded = pcall(CallSecureProtected, "UseItem", BAG_BACKPACK, repairKitSlot)
            attempted = callSucceeded and useSucceeded == true
        end
    elseif RepairItemWithRepairKit then
        attempted = pcall(RepairItemWithRepairKit, BAG_WORN, slotId, BAG_BACKPACK, repairKitSlot)
    end

    if not attempted then
        pendingRepair = true
        QueueRetry()
    else
        VerifyRepairAttempt(slotId, itemLink, condition)
    end

    return attempted, repairKitType
end

local function TryChargeAll()
    for _, slotId in ipairs(weaponSlots) do
        TryChargeSlot(slotId)
    end
end

local function TryRepairAll()
    if not GetBagSize then
        return
    end

    for slotId = 0, GetBagSize(BAG_WORN) do
        local succeeded, repairKitType = TryRepairSlot(slotId)
        if succeeded and repairKitType == REPAIR_KIT_TYPE_CROWN then
            return
        end
    end
end

local function OnChargeChanged(_, bagId, slotId)
    if bagId == BAG_WORN then
        TryChargeSlot(slotId)
    end
end

local function OnDurabilityChanged(_, bagId, slotId)
    if bagId == BAG_WORN then
        TryRepairSlot(slotId)
    end
end

local function OnBackpackItemAdded(_, bagId, slotId)
    if bagId == BAG_BACKPACK then
        TryBindSlot(slotId)
    end
end

local function OnCombatState(_, inCombat)
    if not inCombat then
        Gear.TryPending()
    end
end

local function OnPlayerAlive()
    Gear.TryPending()
end

local function OnRepairFailure()
    if Gear.GetAutoRepair() then
        pendingRepair = true
        QueueRetry()
    end
end

local function OnOpenStore()
    if not Gear.GetRepairAllInMerchants()
        or not CanStoreRepair
        or not GetRepairAllCost
        or not RepairAll
        or not CanStoreRepair()
    then
        return
    end

    local repairCost = GetRepairAllCost()
    if not repairCost or repairCost <= 0 then
        return
    end

    if GetCurrencyAmount
        and repairCost > GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    then
        return
    end

    pcall(RepairAll)
end

local function RegisterEvents()
    if eventsRegistered then
        return
    end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Charge", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnChargeChanged)
    EVENT_MANAGER:AddFilterForEvent(
        EVENT_NAMESPACE .. "_Charge",
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_INVENTORY_UPDATE_REASON,
        INVENTORY_UPDATE_REASON_ITEM_CHARGE,
        REGISTER_FILTER_BAG_ID,
        BAG_WORN
    )

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Repair", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnDurabilityChanged)
    EVENT_MANAGER:AddFilterForEvent(
        EVENT_NAMESPACE .. "_Repair",
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_INVENTORY_UPDATE_REASON,
        INVENTORY_UPDATE_REASON_DURABILITY_CHANGE,
        REGISTER_FILTER_BAG_ID,
        BAG_WORN
    )

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Combat", EVENT_PLAYER_COMBAT_STATE, OnCombatState)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Alive", EVENT_PLAYER_ALIVE, OnPlayerAlive)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Reincarnated", EVENT_PLAYER_REINCARNATED, OnPlayerAlive)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_RepairFailure", EVENT_ITEM_REPAIR_FAILURE, OnRepairFailure)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_MerchantRepair", EVENT_OPEN_STORE, OnOpenStore)

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_AutoBound", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnBackpackItemAdded)
    EVENT_MANAGER:AddFilterForEvent(
        EVENT_NAMESPACE .. "_AutoBound",
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_IS_NEW_ITEM,
        true,
        REGISTER_FILTER_BAG_ID,
        BAG_BACKPACK
    )

    eventsRegistered = true
end

local function UnregisterEvents()
    if not eventsRegistered then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_Charge", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_Repair", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_Combat", EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_Alive", EVENT_PLAYER_ALIVE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_Reincarnated", EVENT_PLAYER_REINCARNATED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_RepairFailure", EVENT_ITEM_REPAIR_FAILURE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_MerchantRepair", EVENT_OPEN_STORE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_AutoBound", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    eventsRegistered = false
end

local function RefreshEvents()
    if Gear.GetAutoCharge() or Gear.GetAutoRepair() or Gear.GetRepairAllInMerchants() or Gear.GetAutoBound() then
        RegisterEvents()
    else
        UnregisterEvents()
    end
end

function Gear.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function Gear.Initialize()
    RefreshEvents()
    TryChargeAll()
    TryRepairAll()
end

function Gear.TryPending()
    if IsBlocked() then
        QueueRetry()
        return
    end

    if pendingCharge then
        pendingCharge = false
        TryChargeAll()
    end

    if pendingRepair then
        pendingRepair = false
        TryRepairAll()
    end
end

function Gear.GetAutoCharge()
    if not savedVariables then
        return defaults.gear.autoCharge
    end

    return GetSettings().autoCharge
end

function Gear.SetAutoCharge(value)
    GetSettings().autoCharge = value == true
    RefreshEvents()

    if GetSettings().autoCharge then
        TryChargeAll()
    end
end

function Gear.GetChargeThreshold()
    if not savedVariables then
        return defaults.gear.chargeThreshold
    end

    local value = math.floor((tonumber(GetSettings().chargeThreshold) or CHARGE_THRESHOLD_DEFAULT) + 0.5)
    value = math.max(CHARGE_THRESHOLD_MIN, math.min(CHARGE_THRESHOLD_MAX, value))
    GetSettings().chargeThreshold = value
    return value
end

function Gear.SetChargeThreshold(value)
    value = math.floor((tonumber(value) or CHARGE_THRESHOLD_DEFAULT) + 0.5)
    GetSettings().chargeThreshold = math.max(CHARGE_THRESHOLD_MIN, math.min(CHARGE_THRESHOLD_MAX, value))

    if Gear.GetAutoCharge() then
        TryChargeAll()
    end
end

function Gear.GetChargeThresholdMin()
    return CHARGE_THRESHOLD_MIN
end

function Gear.GetChargeThresholdMax()
    return CHARGE_THRESHOLD_MAX
end

function Gear.GetChargeThresholdDefault()
    return CHARGE_THRESHOLD_DEFAULT
end

function Gear.GetAutoRepair()
    if not savedVariables then
        return defaults.gear.autoRepair
    end

    return GetSettings().autoRepair
end

function Gear.SetAutoRepair(value)
    GetSettings().autoRepair = value == true
    RefreshEvents()

    if GetSettings().autoRepair then
        TryRepairAll()
    end
end

function Gear.GetRepairThreshold()
    if not savedVariables then
        return defaults.gear.repairThreshold
    end

    local value = math.floor((tonumber(GetSettings().repairThreshold) or REPAIR_THRESHOLD_DEFAULT) + 0.5)
    value = math.max(REPAIR_THRESHOLD_MIN, math.min(REPAIR_THRESHOLD_MAX, value))
    GetSettings().repairThreshold = value
    return value
end

function Gear.SetRepairThreshold(value)
    value = math.floor((tonumber(value) or REPAIR_THRESHOLD_DEFAULT) + 0.5)
    GetSettings().repairThreshold = math.max(REPAIR_THRESHOLD_MIN, math.min(REPAIR_THRESHOLD_MAX, value))

    if Gear.GetAutoRepair() then
        TryRepairAll()
    end
end

function Gear.GetRepairThresholdMin()
    return REPAIR_THRESHOLD_MIN
end

function Gear.GetRepairThresholdMax()
    return REPAIR_THRESHOLD_MAX
end

function Gear.GetRepairThresholdDefault()
    return REPAIR_THRESHOLD_DEFAULT
end

function Gear.GetRepairAllInMerchants()
    if not savedVariables then
        return defaults.gear.repairAllInMerchants
    end

    return GetSettings().repairAllInMerchants
end

function Gear.SetRepairAllInMerchants(value)
    GetSettings().repairAllInMerchants = value == true
    RefreshEvents()
end

function Gear.GetAutoBound()
    if not savedVariables then
        return defaults.gear.autoBound
    end

    return GetSettings().autoBound
end

function Gear.SetAutoBound(value)
    GetSettings().autoBound = value == true
    RefreshEvents()
end

function Gear.GetLogCharge()
    if not savedVariables then
        return defaults.gear.logCharge
    end

    return GetSettings().logCharge
end

function Gear.SetLogCharge(value)
    GetSettings().logCharge = value == true
end

function Gear.GetLogRepair()
    if not savedVariables then
        return defaults.gear.logRepair
    end

    return GetSettings().logRepair
end

function Gear.SetLogRepair(value)
    GetSettings().logRepair = value == true
end

function Gear.GetLogBind()
    if not savedVariables then
        return defaults.gear.logBind
    end

    return GetSettings().logBind
end

function Gear.SetLogBind(value)
    GetSettings().logBind = value == true
end

function Gear.GetAutoChargeLabel()
    return NQOL.L("features.gear.auto_charge_label")
end

function Gear.GetAutoChargeTooltip()
    return NQOL.L("features.gear.auto_charge_tooltip")
end

function Gear.GetChargeThresholdLabel()
    return NQOL.L("features.gear.charge_threshold_label")
end

function Gear.GetChargeThresholdTooltip()
    return NQOL.L("features.gear.charge_threshold_tooltip")
end

function Gear.GetLogChargeLabel()
    return NQOL.L("features.gear.log_charge_label")
end

function Gear.GetLogChargeTooltip()
    return NQOL.L("features.gear.log_charge_tooltip")
end

function Gear.GetAutoRepairLabel()
    return NQOL.L("features.gear.auto_repair_label")
end

function Gear.GetAutoRepairTooltip()
    return NQOL.L("features.gear.auto_repair_tooltip")
end

function Gear.GetRepairThresholdLabel()
    return NQOL.L("features.gear.repair_threshold_label")
end

function Gear.GetRepairThresholdTooltip()
    return NQOL.L("features.gear.repair_threshold_tooltip")
end

function Gear.GetRepairAllInMerchantsLabel()
    return NQOL.L("features.gear.repair_all_in_merchants_label")
end

function Gear.GetRepairAllInMerchantsTooltip()
    return NQOL.L("features.gear.repair_all_in_merchants_tooltip")
end

function Gear.GetLogRepairLabel()
    return NQOL.L("features.gear.log_repair_label")
end

function Gear.GetLogRepairTooltip()
    return NQOL.L("features.gear.log_repair_tooltip")
end

function Gear.GetAutoBoundLabel()
    return NQOL.L("features.gear.auto_bound_label")
end

function Gear.GetAutoBoundTooltip()
    return NQOL.L("features.gear.auto_bound_tooltip")
end

function Gear.GetLogBindLabel()
    return NQOL.L("features.gear.log_bind_label")
end

function Gear.GetLogBindTooltip()
    return NQOL.L("features.gear.log_bind_tooltip")
end

NQOL.Features.Gear = Gear
