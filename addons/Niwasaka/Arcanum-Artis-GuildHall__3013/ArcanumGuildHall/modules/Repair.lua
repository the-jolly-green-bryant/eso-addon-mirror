local ArcanumGuildHall = _G["ArcanumGuildHall"]

local res = ArcanumGuildHallMediaRes
local currencyIcon = GetCurrencyLootKeyboardIcon(CURT_MONEY)

local p = function(msg)
    if ArcanumGuildHall.db.showChatIcon == false then
        CHAT_ROUTER:AddSystemMessage(res.Ccolor2 .. tostring(msg) .. "|r")
    else
        CHAT_ROUTER:AddSystemMessage(res.IconAA .. " " .. res.Ccolor2 .. tostring(msg) .. "|r")
    end
end

local c = function(msg, c1, c2)
    return "" .. (c1 or res.Ccolor8) .. tostring(msg) .. (c2 or res.Ccolor2)
end

local repairKits = {}
local soulGems = {}

function ArcanumGuildHall.FindRepairKits()
    repairKits = {}
    local bagId = BAG_BACKPACK

    for slotId = 0, GetBagSize(bagId) - 1 do
        if IsItemRepairKit(bagId, slotId) then
            local tier = GetRepairKitTier(bagId, slotId)
            if not repairKits[tier] then
                repairKits[tier] = {}
            end
            repairKits[tier][slotId] = GetSlotStackSize(bagId, slotId)
        end
    end

    return repairKits
end

local function GetItemLevelTier(bagId, slotId)
    return math.floor(GetItemRequiredLevel(bagId, slotId) / 10) + 1
end

local function GetRepairKitSlot(repairKitTier)
    if repairKits[repairKitTier] then
        for slotId, count in pairs(repairKits[repairKitTier]) do
            return slotId, count, repairKitTier
        end
    elseif ArcanumGuildHall.db.useAnyKit then
        while repairKitTier < 6 do
            repairKitTier = repairKitTier + 1
            if repairKits[repairKitTier] then
                for slotId, count in pairs(repairKits[repairKitTier]) do
                    return slotId, count, repairKitTier
                end
            end
        end
    end
end

function ArcanumGuildHall.RepairItemWithKit(bagId, slotId)
    local repairKitTier = GetItemLevelTier(bagId, slotId)
    local repaired = false
    local itemCondition = GetItemCondition(bagId, slotId)
    local oldCondition = itemCondition
    local safetyCounter = 0

    while itemCondition and itemCondition < 100 do
        safetyCounter = safetyCounter + 1
        if safetyCounter > 20 then
            break
        end

        local repairKitSlot = GetRepairKitSlot(repairKitTier)
        if repairKitSlot then
            local repairKitAmount = GetAmountRepairKitWouldRepairItem(bagId, slotId, BAG_BACKPACK, repairKitSlot)
            if not repairKitAmount or repairKitAmount <= 0 then
                break
            end

            RepairItemWithRepairKit(bagId, slotId, BAG_BACKPACK, repairKitSlot)
            itemCondition = itemCondition + repairKitAmount
            repairKits = ArcanumGuildHall.FindRepairKits()
            repaired = true
        else
            break
        end
    end

    if repaired and ArcanumGuildHall.db.verboseKits then
        local link = GetItemLink(bagId, slotId)

        if itemCondition and itemCondition >= 100 then
            itemCondition = 100
        end

        p(zo_strformat(
                ArcanumGuildHall.GetDefaultLocaleString("CHAT_REPAIRED"),
                link:gsub("%^%a+", ""),
                c(oldCondition .. "%"),
                c((itemCondition or oldCondition) .. "%")
        ))
    end
end

function ArcanumGuildHall.RepairItemsWithKits(threshold)
    threshold = tonumber(threshold) or ArcanumGuildHall.db.repairThreshold
    repairKits = ArcanumGuildHall.FindRepairKits()

    local bagId = BAG_WORN
    for slotId = 0, GetBagSize(bagId) - 1 do
        if DoesItemHaveDurability(bagId, slotId) then
            local itemName = GetItemName(bagId, slotId)
            local itemCondition = GetItemCondition(bagId, slotId)
            if itemName ~= "" and itemCondition and itemCondition <= threshold then
                ArcanumGuildHall.RepairItemWithKit(bagId, slotId)
            end
        end
    end
end

function ArcanumGuildHall.FindSoulGems()
    soulGems = {}
    local bagId = BAG_BACKPACK

    for slotId = 0, GetBagSize(bagId) - 1 do
        if IsItemSoulGem(SOUL_GEM_TYPE_FILLED, bagId, slotId) then
            local tier = GetSoulGemItemInfo(bagId, slotId)
            if not soulGems[tier] then
                soulGems[tier] = {}
            end
            soulGems[tier][slotId] = GetSlotStackSize(bagId, slotId)
        end
    end

    return soulGems
end

local function GetSoulGemSlot(soulGemTier)
    if soulGems[soulGemTier] then
        for slotId, count in pairs(soulGems[soulGemTier]) do
            return slotId, count, soulGemTier
        end
    elseif ArcanumGuildHall.db.useAnyGem then
        while soulGemTier < 6 do
            soulGemTier = soulGemTier + 1
            if soulGems[soulGemTier] then
                for slotId, count in pairs(soulGems[soulGemTier]) do
                    return slotId, count, soulGemTier
                end
            end
        end
    end
end

function ArcanumGuildHall.RechargeItemWithGem(bagId, slotId)
    local recharged = false
    local soulGemTier = 1
    local itemCharge, itemMaxCharge = GetChargeInfoForItem(bagId, slotId)
    local oldCharge = itemCharge
    local safetyCounter = 0

    if not itemMaxCharge or itemMaxCharge <= 0 then
        return
    end

    while itemCharge and itemCharge < itemMaxCharge do
        safetyCounter = safetyCounter + 1
        if safetyCounter > 20 then
            break
        end

        local soulGemSlot = GetSoulGemSlot(soulGemTier)
        if soulGemSlot then
            local chargeAmount = GetAmountSoulGemWouldChargeItem(bagId, slotId, BAG_BACKPACK, soulGemSlot)
            if not chargeAmount or chargeAmount <= 0 then
                break
            end

            ChargeItemWithSoulGem(bagId, slotId, BAG_BACKPACK, soulGemSlot)
            itemCharge = itemCharge + chargeAmount
            soulGems = ArcanumGuildHall.FindSoulGems()
            recharged = true
        else
            break
        end
    end

    if recharged and ArcanumGuildHall.db.verboseGems then
        local link = GetItemLink(bagId, slotId)

        if itemCharge and itemCharge > itemMaxCharge then
            itemCharge = itemMaxCharge
        end

        p(zo_strformat(
                ArcanumGuildHall.GetDefaultLocaleString("CHAT_RECHARGED"),
                link:gsub("%^%a+", ""),
                c(math.floor(oldCharge / itemMaxCharge * 100) .. "%"),
                c(math.floor((itemCharge or oldCharge) / itemMaxCharge * 100) .. "%")
        ))
    end
end

function ArcanumGuildHall.RechargeItemsWithGems(threshold)
    threshold = tonumber(threshold) or ArcanumGuildHall.db.rechargeThreshold
    soulGems = ArcanumGuildHall.FindSoulGems()

    for slotId = 0, GetBagSize(BAG_WORN) - 1 do
        if IsItemChargeable(BAG_WORN, slotId) then
            local itemName = GetItemName(BAG_WORN, slotId)
            local itemCharge, itemMaxCharge = GetChargeInfoForItem(BAG_WORN, slotId)
            if itemName ~= "" and itemCharge and itemMaxCharge and itemMaxCharge > 0 and math.floor(itemCharge / itemMaxCharge * 100) <= threshold then
                ArcanumGuildHall.RechargeItemWithGem(BAG_WORN, slotId)
            end
        end
    end
end

function ArcanumGuildHall.RepairRecharge(threshold)
    ArcanumGuildHall.RepairItemsWithKits(threshold)
    ArcanumGuildHall.RechargeItemsWithGems(threshold)
end

function ArcanumGuildHall.HasItemsToRepair(threshold)
    threshold = tonumber(threshold) or ArcanumGuildHall.db.repairThreshold
    for slotId = 0, GetBagSize(BAG_WORN) - 1 do
        if DoesItemHaveDurability(BAG_WORN, slotId) then
            local itemName = GetItemName(BAG_WORN, slotId)
            local itemCondition = GetItemCondition(BAG_WORN, slotId)
            if itemName ~= "" and itemCondition and itemCondition <= threshold then
                return true
            end
        end
    end
    return false
end

function ArcanumGuildHall.HasItemsToRecharge(threshold)
    threshold = tonumber(threshold) or ArcanumGuildHall.db.rechargeThreshold
    for slotId = 0, GetBagSize(BAG_WORN) - 1 do
        if IsItemChargeable(BAG_WORN, slotId) then
            local itemName = GetItemName(BAG_WORN, slotId)
            local itemCharge, itemMaxCharge = GetChargeInfoForItem(BAG_WORN, slotId)
            if itemName ~= "" and itemCharge and itemMaxCharge and itemMaxCharge > 0 and math.floor(itemCharge / itemMaxCharge * 100) <= threshold then
                return true
            end
        end
    end
    return false
end

local function AllowRecharge()
    if IsUnitDead("player") then
        return false
    end

    local usage = ArcanumGuildHall.db.rechargeMode
    return usage == 0 or (usage == 1 and IsRaidInProgress() and not HasRaidEnded())
end

function ArcanumGuildHall.OnInventorySingleSlotUpdate(_, bagId, slotId, isNewItem, _, updateReason)
    if updateReason == INVENTORY_UPDATE_REASON_ITEM_CHARGE or updateReason == INVENTORY_UPDATE_REASON_DEFAULT then
        if AllowRecharge() and IsItemChargeable(bagId, slotId) then
            local itemName = GetItemName(bagId, slotId)
            local itemCharge, itemMaxCharge = GetChargeInfoForItem(bagId, slotId)
            if itemName ~= "" and itemCharge and itemMaxCharge and itemMaxCharge > 0 and math.floor(itemCharge / itemMaxCharge * 100) <= ArcanumGuildHall.db.rechargeThreshold then
                soulGems = ArcanumGuildHall.FindSoulGems()
                ArcanumGuildHall.RechargeItemWithGem(bagId, slotId)
            end
        end
    end
end

function ArcanumGuildHall.OnPlayerAlive()
    if AllowRecharge() then
        ArcanumGuildHall.RechargeItemsWithGems()
    end
end

function ArcanumGuildHall.RepairItemInShop(bagId, slotId)
    local cost = GetItemRepairCost(bagId, slotId)
    local oldCondition = GetItemCondition(bagId, slotId)

    if not cost or cost <= 0 or not oldCondition or oldCondition >= 100 then
        return 0
    end

    local link = GetItemLink(bagId, slotId, LINK_STYLE_BRACKETS)

    if cost > GetCurrentMoney() then
        if ArcanumGuildHall.db.verboseStore then
            p(zo_strformat(
                    ArcanumGuildHall.GetDefaultLocaleString("CHAT_SHOP_REPAIRED_DECLINED"),
                    link:gsub("%^%a+", ""),
                    c(cost) .. "|t15:15:" .. currencyIcon .. "|t"
            ))
        end
        return 0
    end

    RepairItem(bagId, slotId)

    -- RepairItem() ist asynchron, der Zustandscheck danach würde immer fehlschlagen.
    -- Die Voraussetzungen sind oben bereits geprüft, daher direkt Text ausgeben.
    if ArcanumGuildHall.db.verboseStore then
        p(zo_strformat(
                ArcanumGuildHall.GetDefaultLocaleString("CHAT_SHOP_REPAIRED"),
                link:gsub("%^%a+", ""),
                c(cost) .. "|t15:15:" .. currencyIcon .. "|t"
        ))
    end

    return cost
end

function ArcanumGuildHall.RepairItemsInShop()
    local totalCost = 0
    local bagId = BAG_WORN

    for slotId = 0, GetBagSize(bagId) - 1 do
        if DoesItemHaveDurability(bagId, slotId) then
            local itemName = GetItemName(bagId, slotId)
            if itemName ~= "" then
                totalCost = totalCost + ArcanumGuildHall.RepairItemInShop(bagId, slotId)
            end
        end
    end

    if ArcanumGuildHall.db.verboseStore and totalCost > 0 then
        p(zo_strformat(
                ArcanumGuildHall.GetDefaultLocaleString("CHAT_REPAIR_COST"),
                c(totalCost) .. "|t15:15:" .. currencyIcon .. "|t"
        ))
    end
end

function ArcanumGuildHall.OnOpenStore()
    if ArcanumGuildHall.db.storeRepairMode == 0 then
        local repairCost = GetRepairAllCost()

        if not repairCost or repairCost <= 0 then
            return
        end

        if repairCost > GetCurrentMoney() then
            if ArcanumGuildHall.db.verboseStore then
                p(zo_strformat(
                        ArcanumGuildHall.GetDefaultLocaleString("CHAT_SHOP_REPAIRED_DECLINED2"),
                        c(repairCost) .. "|t15:15:" .. currencyIcon .. "|t"
                ))
            end
            return
        end

        RepairAll()

        if ArcanumGuildHall.db.verboseStore then
            p(zo_strformat(
                    ArcanumGuildHall.GetDefaultLocaleString("CHAT_SHOP_REPAIRED_COST"),
                    c(repairCost) .. "|t15:15:" .. currencyIcon .. "|t"
            ))
        end

        return
    end

    if ArcanumGuildHall.db.storeRepairMode == 1 then
        ArcanumGuildHall.RepairItemsInShop()
    end
end

ZO_CreateStringId("SI_BINDING_NAME_AA_SETTINGS", ArcanumGuildHall.GetDefaultLocaleString("BINDING_OPEN_SETTINGS"))
ZO_CreateStringId("SI_BINDING_NAME_AA_REPAIR_RECHARGE", ArcanumGuildHall.GetDefaultLocaleString("BINDING_REPAIR_RECHARGE"))
ZO_CreateStringId("SI_BINDING_NAME_AA_REPAIR", ArcanumGuildHall.GetDefaultLocaleString("BINDING_REPAIR_WITH_KITS"))
ZO_CreateStringId("SI_BINDING_NAME_AA_RECHARGE", ArcanumGuildHall.GetDefaultLocaleString("BINDING_RECHARGE_WITH_GEMS"))