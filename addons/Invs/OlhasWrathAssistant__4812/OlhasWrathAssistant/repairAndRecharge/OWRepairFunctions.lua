local owa = OWAssistant
owa.Repair = owa.Repair or {}
local repair = owa.Repair

local EVENT_NAMESPACE = owa.addonName .. "RepairAndRecharge"
local SCAN_DELAY_MS = 250
local ACTION_COOLDOWN_MS = 1000
local RECHARGE_CHECK_INTERVAL_MS = 1500

local DEFAULT_SETTINGS = {
    autoRepair = false,
    repairThreshold = 10,
    useCrownRepairKitsFirst = false,
    repairInCombat = false,
    repairResourceTracking = true,
    repairResourceThreshold = 10,
    repairChatMessages = true,

    autoRecharge = false,
    rechargeThreshold = 10,
    useCrownSoulGemsFirst = false,
    rechargeInCombat = false,
    rechargeResourceTracking = true,
    rechargeResourceThreshold = 10,
    rechargeChatMessages = true,
}

local function ClampThreshold(value)
    return zo_clamp(
        zo_round(tonumber(value) or 10),
        0,
        20
    )
end

local function ClampResourceThreshold(value)
    return zo_clamp(
        zo_round(tonumber(value) or 10),
        1,
        50
    )
end

function repair.GetSettings()
    local savedVariables = owa.savedVariables

    if not savedVariables.repairAndRecharge then
        savedVariables.repairAndRecharge = {}
    end

    local settings = savedVariables.repairAndRecharge

    if settings.useCrownRepairKitsFirst == nil then
        settings.useCrownRepairKitsFirst =
            settings.repairKitMode == "crown_first"
            or settings.repairKitMode == "crown_only"
    end

    if settings.useCrownSoulGemsFirst == nil then
        settings.useCrownSoulGemsFirst =
            settings.soulGemMode == "crown_first"
            or settings.soulGemMode == "crown_only"
    end

    for key, defaultValue in pairs(DEFAULT_SETTINGS) do
        if settings[key] == nil then
            settings[key] = defaultValue
        end
    end

    settings.repairThreshold =
        ClampThreshold(settings.repairThreshold)
    settings.rechargeThreshold =
        ClampThreshold(settings.rechargeThreshold)
    settings.repairResourceThreshold =
        ClampResourceThreshold(
            settings.repairResourceThreshold
        )
    settings.rechargeResourceThreshold =
        ClampResourceThreshold(
            settings.rechargeResourceThreshold
        )

    settings.repairKitMode = nil
    settings.soulGemMode = nil

    return settings
end

function repair.Chat(key, ...)
    local settings = repair.GetSettings()

    if (key == "REPAIR_THRESHOLD_SET"
        or key == "ITEM_REPAIRED")
        and not settings.repairChatMessages
    then
        return
    end

    if (key == "RECHARGE_THRESHOLD_SET"
        or key == "ITEM_RECHARGED")
        and not settings.rechargeChatMessages
    then
        return
    end

    local message = owa.GetString("REPAIR_" .. key)
    if not message then
        return
    end

    local argumentCount = select("#", ...)
    if argumentCount > 0 then
        message = string.format(message, ...)
    end

    d("[OWRepair] " .. message)
end

local function GetStackCount(bagId, slotIndex)
    local _, stackCount = GetItemInfo(bagId, slotIndex)
    return stackCount or 0
end

local function GetEquippedItemLink(slotIndex)
    return GetItemLink(
        BAG_WORN,
        slotIndex,
        LINK_STYLE_BRACKETS
    )
end

local function CollectEquippedRepairTargets(threshold)
    local targets = {}
    local damagedItems = {}
    local bagSize = GetBagSize(BAG_WORN)

    for slotIndex = 0, bagSize - 1 do
        local itemLink = GetEquippedItemLink(slotIndex)

        if itemLink ~= ""
            and DoesItemHaveDurability(BAG_WORN, slotIndex)
        then
            local condition =
                GetItemCondition(BAG_WORN, slotIndex)

            if condition and condition < 100 then
                local target = {
                    slotIndex = slotIndex,
                    itemLink = itemLink,
                    condition = condition,
                }

                table.insert(damagedItems, target)

                if condition <= threshold then
                    table.insert(targets, target)
                end
            end
        end
    end

    table.sort(targets, function(left, right)
        return left.condition < right.condition
    end)

    return targets, damagedItems
end

local function CollectEquippedRechargeTargets(threshold)
    local targets = {}
    local bagSize = GetBagSize(BAG_WORN)

    for slotIndex = 0, bagSize - 1 do
        local itemLink = GetEquippedItemLink(slotIndex)

        if itemLink ~= ""
            and IsItemChargeable(BAG_WORN, slotIndex)
        then
            local charges, maxCharges =
                GetChargeInfoForItem(BAG_WORN, slotIndex)

            if maxCharges and maxCharges > 0 then
                local percentage = zo_round(
                    (charges / maxCharges) * 100
                )

                if percentage <= threshold then
                    table.insert(targets, {
                        slotIndex = slotIndex,
                        itemLink = itemLink,
                        charges = charges,
                        maxCharges = maxCharges,
                        percentage = percentage,
                    })
                end
            end
        end
    end

    table.sort(targets, function(left, right)
        return left.percentage < right.percentage
    end)

    return targets
end

local function CollectRepairKits()
    local standard = {}
    local crown = {}
    local bagSize = GetBagSize(BAG_BACKPACK)

    for slotIndex = 0, bagSize - 1 do
        local isRepairKit =
            IsItemRepairKit(BAG_BACKPACK, slotIndex)
        local itemType =
            GetItemType(BAG_BACKPACK, slotIndex)
        local isCrownRepairKit =
            (ITEMTYPE_CROWN_REPAIR
                and itemType == ITEMTYPE_CROWN_REPAIR)
            or (isRepairKit
                and not IsItemNonCrownRepairKit(
                    BAG_BACKPACK,
                    slotIndex
                ))

        if isRepairKit or isCrownRepairKit then
            local resource = {
                slotIndex = slotIndex,
                remaining = GetStackCount(
                    BAG_BACKPACK,
                    slotIndex
                ),
                tier = GetRepairKitTier(
                    BAG_BACKPACK,
                    slotIndex
                ) or 0,
            }

            if isRepairKit
                and IsItemNonCrownRepairKit(
                BAG_BACKPACK,
                slotIndex
            ) then
                table.insert(standard, resource)
            else
                table.insert(crown, resource)
            end
        end
    end

    table.sort(standard, function(left, right)
        return left.tier > right.tier
    end)

    return standard, crown
end

local function CollectSoulGems()
    local standard = {}
    local crown = {}
    local bagSize = GetBagSize(BAG_BACKPACK)

    for slotIndex = 0, bagSize - 1 do
        if IsItemSoulGem(
            SOUL_GEM_TYPE_FILLED,
            BAG_BACKPACK,
            slotIndex
        ) then
            local tier = select(
                1,
                GetSoulGemItemInfo(
                    BAG_BACKPACK,
                    slotIndex
                )
            ) or 0

            local resource = {
                slotIndex = slotIndex,
                remaining = GetStackCount(
                    BAG_BACKPACK,
                    slotIndex
                ),
                tier = tier,
            }

            local isCrown = IsItemFromCrownStore
                and IsItemFromCrownStore(
                    BAG_BACKPACK,
                    slotIndex
                )

            if isCrown or tier == 0 then
                table.insert(crown, resource)
            else
                table.insert(standard, resource)
            end
        end
    end

    table.sort(standard, function(left, right)
        return left.tier < right.tier
    end)

    return standard, crown
end

local function GetAvailableResource(resources)
    for _, resource in ipairs(resources) do
        if resource.remaining > 0 then
            return resource
        end
    end

    return nil
end

local function GetRemainingResourceCount(resources)
    local count = 0

    for _, resource in ipairs(resources) do
        count = count + math.max(resource.remaining or 0, 0)
    end

    return count
end

local function NotifyRepairKitCount(
    settings,
    standardKits
)
    if not settings.repairResourceTracking then
        return
    end

    local remaining =
        GetRemainingResourceCount(standardKits)

    if remaining <= settings.repairResourceThreshold then
        repair.Chat("REPAIR_KITS_REMAINING", remaining)
    end
end

local function NotifySoulGemCount(
    settings,
    standardGems
)
    if not settings.rechargeResourceTracking then
        return
    end

    local remaining =
        GetRemainingResourceCount(standardGems)

    if remaining <= settings.rechargeResourceThreshold then
        repair.Chat("SOUL_GEMS_REMAINING", remaining)
    end
end

local function TryRepairWithStandardKit(target, resources)
    for _, resource in ipairs(resources) do
        if resource.remaining > 0 then
            local amount = GetAmountRepairKitWouldRepairItem(
                BAG_WORN,
                target.slotIndex,
                BAG_BACKPACK,
                resource.slotIndex
            ) or 0

            if amount > 0 then
                RepairItemWithRepairKit(
                    BAG_WORN,
                    target.slotIndex,
                    BAG_BACKPACK,
                    resource.slotIndex
                )

                resource.remaining = resource.remaining - 1

                local repairedPercentage = zo_clamp(
                    zo_round(math.min(
                        amount,
                        100 - target.condition
                    )),
                    0,
                    100
                )

                repair.Chat(
                    "ITEM_REPAIRED",
                    target.itemLink,
                    repairedPercentage
                )

                return true
            end
        end
    end

    return false
end

local function TryUseCrownRepairKit(
    crownKits,
    damagedItems
)
    local resource = GetAvailableResource(crownKits)

    if not resource or IsUnitInCombat("player") then
        return false
    end

    if CanUseItem
        and not CanUseItem(BAG_BACKPACK, resource.slotIndex)
    then
        return false
    end

    local success = true

    if IsProtectedFunction("UseItem") then
        success = CallSecureProtected(
            "UseItem",
            BAG_BACKPACK,
            resource.slotIndex
        )
    else
        UseItem(BAG_BACKPACK, resource.slotIndex)
    end

    if success == false then
        return false
    end

    resource.remaining = resource.remaining - 1

    for _, target in ipairs(damagedItems) do
        repair.Chat(
            "ITEM_REPAIRED",
            target.itemLink,
            100 - target.condition
        )
    end

    return true
end

local function RepairEquippedItems(settings)
    if not settings.autoRepair
        or (IsUnitInCombat("player")
            and not settings.repairInCombat)
    then
        return 0
    end

    local targets, damagedItems =
        CollectEquippedRepairTargets(
            settings.repairThreshold
        )

    if #targets == 0 then
        return 0
    end

    local standardKits, crownKits = CollectRepairKits()
    local actionCount = 0

    if settings.useCrownRepairKitsFirst
        and GetAvailableResource(crownKits)
    then
        if TryUseCrownRepairKit(
            crownKits,
            damagedItems
        ) then
            return 1
        end
    end

    for _, target in ipairs(targets) do
        if TryRepairWithStandardKit(
            target,
            standardKits
        ) then
            actionCount = actionCount + 1
        end
    end

    if actionCount > 0 then
        NotifyRepairKitCount(
            settings,
            standardKits
        )
    end

    return actionCount
end

local function TryRechargeWithSoulGem(target, resources)
    for _, resource in ipairs(resources) do
        if resource.remaining > 0 then
            local amount = GetAmountSoulGemWouldChargeItem(
                BAG_WORN,
                target.slotIndex,
                BAG_BACKPACK,
                resource.slotIndex
            ) or 0

            if amount > 0 then
                ChargeItemWithSoulGem(
                    BAG_WORN,
                    target.slotIndex,
                    BAG_BACKPACK,
                    resource.slotIndex
                )

                resource.remaining = resource.remaining - 1

                local chargeAdded = math.min(
                    amount,
                    target.maxCharges - target.charges
                )

                local chargedPercentage = zo_clamp(
                    zo_round(
                        (chargeAdded / target.maxCharges)
                        * 100
                    ),
                    0,
                    100
                )

                repair.Chat(
                    "ITEM_RECHARGED",
                    target.itemLink,
                    chargedPercentage
                )

                return true
            end
        end
    end

    return false
end

local function RechargeEquippedWeapons(settings)
    if not settings.autoRecharge
        or (IsUnitInCombat("player")
            and not settings.rechargeInCombat)
    then
        return 0
    end

    local targets = CollectEquippedRechargeTargets(
        settings.rechargeThreshold
    )

    if #targets == 0 then
        return 0
    end

    local standardGems, crownGems = CollectSoulGems()
    local actionCount = 0
    local usedStandardGem = false

    for _, target in ipairs(targets) do
        local charged = false

        if settings.useCrownSoulGemsFirst then
            charged = TryRechargeWithSoulGem(
                target,
                crownGems
            )
        end

        if not charged then
            charged = TryRechargeWithSoulGem(
                target,
                standardGems
            )

            if charged then
                usedStandardGem = true
            end
        end

        if charged then
            actionCount = actionCount + 1
        end
    end

    if usedStandardGem then
        NotifySoulGemCount(
            settings,
            standardGems
        )
    end

    return actionCount
end

function repair.ScanEquipped()
    if not owa.savedVariables.repairEnabled then
        return
    end

    if IsUnitDead("player") then
        return
    end

    local now = GetFrameTimeMilliseconds()

    if repair.nextActionTime
        and now < repair.nextActionTime
    then
        repair.ScheduleScan(
            repair.nextActionTime - now
        )
        return
    end

    local settings = repair.GetSettings()
    local actionCount = RepairEquippedItems(settings)
        + RechargeEquippedWeapons(settings)

    if actionCount > 0 then
        repair.nextActionTime = now + ACTION_COOLDOWN_MS
    end
end

function repair.ScheduleScan(delayMilliseconds)
    if repair.scanScheduled then
        return
    end

    local delay = delayMilliseconds or SCAN_DELAY_MS
    local now = GetFrameTimeMilliseconds()

    if repair.nextActionTime
        and now < repair.nextActionTime
    then
        delay = math.max(
            delay,
            repair.nextActionTime - now
        )
    end

    repair.scanScheduled = true

    zo_callLater(function()
        repair.scanScheduled = false
        repair.ScanEquipped()
    end, delay)
end

function repair.Initialize()
    repair.GetSettings()

    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE,
        EVENT_PLAYER_ACTIVATED,
        function()
            repair.ScheduleScan(1000)
        end
    )

    local inventoryEventName =
        EVENT_NAMESPACE .. "WornItems"

    EVENT_MANAGER:RegisterForEvent(
        inventoryEventName,
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        function()
            repair.ScheduleScan()
        end
    )

    EVENT_MANAGER:AddFilterForEvent(
        inventoryEventName,
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_BAG_ID,
        BAG_WORN
    )

    local weaponChargeEventName =
        EVENT_NAMESPACE .. "WeaponCharge"

    EVENT_MANAGER:RegisterForEvent(
        weaponChargeEventName,
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        function()
            repair.ScheduleScan()
        end
    )

    EVENT_MANAGER:AddFilterForEvent(
        weaponChargeEventName,
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_BAG_ID,
        BAG_WORN,
        REGISTER_FILTER_INVENTORY_UPDATE_REASON,
        INVENTORY_UPDATE_REASON_ITEM_CHARGE
    )

    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE .. "WeaponPair",
        EVENT_ACTIVE_WEAPON_PAIR_CHANGED,
        function()
            repair.ScheduleScan()
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE .. "Combat",
        EVENT_PLAYER_COMBAT_STATE,
        function()
            repair.ScheduleScan()
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE .. "PlayerAlive",
        EVENT_PLAYER_ALIVE,
        function()
            -- Durability can reach zero while the player is dead. The worn-item
            -- update is ignored at that moment, so repeat the scan after revival.
            repair.ScheduleScan(750)
        end
    )

    EVENT_MANAGER:RegisterForUpdate(
        EVENT_NAMESPACE .. "RechargeCheck",
        RECHARGE_CHECK_INTERVAL_MS,
        function()
            local settings = repair.GetSettings()

            if owa.savedVariables.repairEnabled
                and settings.autoRecharge
                and not IsUnitDead("player")
            then
                repair.ScheduleScan(0)
            end
        end
    )
end
