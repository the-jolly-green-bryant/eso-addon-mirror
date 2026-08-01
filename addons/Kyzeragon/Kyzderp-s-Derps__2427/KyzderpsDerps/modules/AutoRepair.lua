KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.AutoRepair = KyzderpsDerps.AutoRepair or {}
local AutoRepair = KyzderpsDerps.AutoRepair

---------------------------------------------------------------------
-- Find repair kit
---------------------------------------------------------------------
local function FindRepairKitFor(equipBagId, equipSlotId)
    local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
    for _, item in pairs(bagCache) do
        -- Don't use bound (crown/group) repair kits
        if (IsItemRepairKit(item.bagId, item.slotIndex) and not IsItemBound(item.bagId, item.slotIndex)) then
            -- Use a repair kit that... probably isn't a petty repair kit
            local repairAmount = GetAmountRepairKitWouldRepairItem(equipBagId, equipSlotId, item.bagId, item.slotIndex)
            if (repairAmount >= 5) then
                return item.bagId, item.slotIndex, repairAmount
            end
        end
    end
end

---------------------------------------------------------------------
---------------------------------------------------------------------
local function AttemptRepair(bagId, slotId)
    if (GetItemCondition(bagId, slotId) > 1) then
        KyzderpsDerps:dbg("|cFF0000skipping repair because item is already repaired")
        return
    end

    -- Can't repair while dead or reincarnating, so delay and keep checking it
    if (IsUnitDeadOrReincarnating("player")) then
        KyzderpsDerps:dbg("delaying repair because dead or reincarnating")
        zo_callLater(function()
                AttemptRepair(bagId, slotId)
            end, 1000)
        return
    end

    local repairBagId, repairSlotId, repairAmount = FindRepairKitFor(bagId, slotId)
    if (not repairBagId) then
        KyzderpsDerps:msg(string.format("No repair kit to repair %s with!", GetItemLink(bagId, slotId)))
        return
    end

    RepairItemWithRepairKit(bagId, slotId, repairBagId, repairSlotId)
    KyzderpsDerps:msg(string.format("Repairing %s with %s for %d%% durability.", GetItemLink(bagId, slotId), GetItemLink(repairBagId, repairSlotId), repairAmount))
end

---------------------------------------------------------------------
-- EVENT_INVENTORY_SINGLE_SLOT_UPDATE (number eventCode, Bag bagId, number slotId, boolean isNewItem, ItemUISoundCategory itemSoundCategory, number inventoryUpdateReason, number stackCountChange)
---------------------------------------------------------------------
local function OnDurabilityUpdate(_, bagId, slotId, _, _, _, _)
    if (GetItemCondition(bagId, slotId) > 1) then
        return
    end

    -- Delay it by a second because sometimes it seems to try to repair immediately
    -- upon death, and it passes the dead/reincarnating check. I got kicked to login
    -- in a dungeon twice and this might be related...
    zo_callLater(function()
            AttemptRepair(bagId, slotId)
        end, 1000)
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function AutoRepair.Initialize()
    KyzderpsDerps:dbg("    Initializing AutoRepair module...")

    if (KyzderpsDerps.savedOptions.misc.repair) then
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "DurabilityUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnDurabilityUpdate)
        EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "DurabilityUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DURABILITY_CHANGE)
    else
        EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "DurabilityUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    end
end
