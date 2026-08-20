-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.Maintenance = EPC.Maintenance or {}
local M = EPC.Maintenance

local function bagSize(bagId)
    if type(GetBagSize) ~= "function" or bagId == nil then return 0 end
    local ok, size = pcall(GetBagSize, bagId)
    return ok and (tonumber(size) or 0) or 0
end

local function itemName(bagId, slotIndex)
    if type(GetItemLink) ~= "function" then return "item" end
    local ok, link = pcall(GetItemLink, bagId, slotIndex)
    if ok and link and link ~= "" then return link end
    return "item"
end

function M:Initialize()
    self.running = false
    self.lastRunMs = 0
end

function M:FindSoulGem(targetSlot)
    if BAG_BACKPACK == nil or SOUL_GEM_TYPE_FILLED == nil or type(IsItemSoulGem) ~= "function" then return nil end
    local bestSlot, bestAmount = nil, -1
    for slot = 0, bagSize(BAG_BACKPACK) - 1 do
        local okGem, isGem = pcall(IsItemSoulGem, SOUL_GEM_TYPE_FILLED, BAG_BACKPACK, slot)
        if okGem and isGem == true then
            local amount = 0
            if type(GetAmountSoulGemWouldChargeItem) == "function" then
                local okAmount, value = pcall(GetAmountSoulGemWouldChargeItem, BAG_WORN, targetSlot, BAG_BACKPACK, slot)
                if okAmount then amount = tonumber(value) or 0 end
            end
            if amount > bestAmount then
                bestAmount = amount
                bestSlot = slot
            end
        end
    end
    return bestSlot, bestAmount
end

function M:FindRepairKit(targetSlot)
    if BAG_BACKPACK == nil or type(IsItemRepairKit) ~= "function" then return nil end
    local neverUseCrown = EPC.saved.maintenanceNeverUseCrown ~= false
    local bestSlot, bestAmount = nil, -1
    for slot = 0, bagSize(BAG_BACKPACK) - 1 do
        local okKit, isKit = pcall(IsItemRepairKit, BAG_BACKPACK, slot)
        if okKit and isKit == true then
            local allowed = true
            if neverUseCrown and type(IsItemNonCrownRepairKit) == "function" then
                local okNonCrown, nonCrown = pcall(IsItemNonCrownRepairKit, BAG_BACKPACK, slot)
                allowed = okNonCrown and nonCrown == true
            end
            local amount = 0
            if allowed and type(GetAmountRepairKitWouldRepairItem) == "function" then
                local okAmount, value = pcall(GetAmountRepairKitWouldRepairItem, BAG_WORN, targetSlot, BAG_BACKPACK, slot)
                if okAmount then amount = tonumber(value) or 0 end
            end
            if allowed and amount > bestAmount then
                bestSlot, bestAmount = slot, amount
            end
        end
    end
    return bestSlot, bestAmount
end

function M:RechargeEquipped()
    if EPC.saved.autoRecharge == false or BAG_WORN == nil or type(IsItemChargeable) ~= "function"
        or type(GetChargeInfoForItem) ~= "function" or type(ChargeItemWithSoulGem) ~= "function" then
        return 0, 0
    end

    local threshold = tonumber(EPC.saved.autoRechargeThreshold) or 90
    local charged, skippedNoGem = 0, 0

    -- BAG_WORN slot indices are equip slots. Scanning the bag instead of a hard-coded
    -- weapon list also catches future weapon-slot changes without an addon update.
    for slot = 0, bagSize(BAG_WORN) - 1 do
        local okChargeable, chargeable = pcall(IsItemChargeable, BAG_WORN, slot)
        if okChargeable and chargeable == true then
            local okInfo, charge, maxCharge = pcall(GetChargeInfoForItem, BAG_WORN, slot)
            charge, maxCharge = tonumber(charge) or 0, tonumber(maxCharge) or 0
            local percent = maxCharge > 0 and ((charge / maxCharge) * 100) or 100
            if okInfo and maxCharge > 0 and percent < threshold then
                local gemSlot, amount = self:FindSoulGem(slot)
                if gemSlot ~= nil and (tonumber(amount) or 0) > 0 then
                    local ok = pcall(ChargeItemWithSoulGem, BAG_WORN, slot, BAG_BACKPACK, gemSlot)
                    if ok then charged = charged + 1 end
                else
                    skippedNoGem = skippedNoGem + 1
                end
            end
        end
    end
    return charged, skippedNoGem
end

function M:RepairEquipped()
    if EPC.saved.autoRepair == false or BAG_WORN == nil or type(DoesItemHaveDurability) ~= "function"
        or type(GetItemCondition) ~= "function" or type(RepairItemWithRepairKit) ~= "function" then
        return 0, 0
    end

    local threshold = tonumber(EPC.saved.autoRepairThreshold) or 90
    local repaired, skippedNoKit = 0, 0

    -- Durability tells us what is actually repairable, including equipped shields.
    for slot = 0, bagSize(BAG_WORN) - 1 do
        local okDurability, hasDurability = pcall(DoesItemHaveDurability, BAG_WORN, slot)
        if okDurability and hasDurability == true then
            local okCondition, condition = pcall(GetItemCondition, BAG_WORN, slot)
            condition = tonumber(condition) or 100
            if okCondition and condition < threshold then
                local kitSlot, amount = self:FindRepairKit(slot)
                if kitSlot ~= nil and (tonumber(amount) or 0) > 0 then
                    local ok = pcall(RepairItemWithRepairKit, BAG_WORN, slot, BAG_BACKPACK, kitSlot)
                    if ok then repaired = repaired + 1 end
                else
                    skippedNoKit = skippedNoKit + 1
                end
            end
        end
    end
    return repaired, skippedNoKit
end

function M:Run(reason, force)
    if not EPC.saved or EPC.saved.autoMaintenance == false then return end
    if self.running then return end
    if type(IsUnitDead) == "function" then
        local okDead, dead = pcall(IsUnitDead, "player")
        if okDead and dead == true then return end
    end

    local now = type(GetFrameTimeMilliseconds) == "function" and GetFrameTimeMilliseconds() or 0
    if not force and now > 0 and self.lastRunMs > 0 and (now - self.lastRunMs) < 350 then return end
    self.lastRunMs = now
    self.running = true

    local charged, noGem = self:RechargeEquipped()
    local repaired, noKit = self:RepairEquipped()
    self.running = false

    if EPC.saved.maintenanceMessages ~= false then
        if charged > 0 or repaired > 0 then
            EPC:Print(string.format("Auto maintenance (%s): recharged %d weapon%s, repaired %d armor piece%s.",
                tostring(reason or "check"), charged, charged == 1 and "" or "s", repaired, repaired == 1 and "" or "s"))
        elseif force and (noGem > 0 or noKit > 0) then
            local parts = {}
            if noGem > 0 then parts[#parts + 1] = "no filled soul gem for low-charge weapon" end
            if noKit > 0 then parts[#parts + 1] = "no usable repair kit for damaged armor" end
            EPC:Print("Maintenance could not finish: " .. table.concat(parts, "; ") .. ".")
        elseif force then
            EPC:Print("Maintenance check complete. Equipped weapons and armor are above your thresholds.")
        end
    end
end

function M:OnCombatState(inCombat)
    if not EPC.saved or EPC.saved.autoMaintenance == false then return end
    if inCombat and EPC.saved.autoMaintenanceOnCombatStart == false then return end
    if (not inCombat) and EPC.saved.autoMaintenanceOnCombatEnd == false then return end

    local reason = inCombat and "combat start" or "combat end"
    local delay = inCombat and 75 or 250
    if type(zo_callLater) == "function" then
        zo_callLater(function() self:Run(reason, false) end, delay)
    else
        self:Run(reason, false)
    end
end
