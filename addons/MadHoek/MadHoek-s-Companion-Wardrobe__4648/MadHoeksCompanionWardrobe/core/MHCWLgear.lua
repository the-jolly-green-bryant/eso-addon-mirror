-- ============================================================================
-- Companion Wardrobe
-- Companion Gear Helpers
--
-- Responsibilities:
-- - Read currently equipped companion gear.
-- - Match saved gear against inventory, bank, and equipment.
-- - Provide slot names and gear comparison helpers.
-- - Support save/load, warnings, verification, and bank automation.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

MHCWL.GEARSLOTS = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_NECK,
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2,
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
}

function MHCWL.ScanGear()
    MHCWL.Debug("Scanning BAG_COMPANION_WORN...")

    for _, slot in ipairs(MHCWL.GEARSLOTS) do
        local link = GetItemLink(BAG_COMPANION_WORN, slot, LINK_STYLE_DEFAULT)
        local uniqueId = Id64ToString(GetItemUniqueId(BAG_COMPANION_WORN, slot))
        local itemId = GetItemId(BAG_COMPANION_WORN, slot)

        MHCWL.Debug(string.format(
            "%s | itemId=%s | uid=%s | link=%s",
            MHCWL.SlotName(slot),
            tostring(itemId),
            tostring(uniqueId),
            link ~= "" and link or "-"
        ))
    end
end

function MHCWL.IsTwoHandedWeaponLink(link)
    if not link or link == "" then
        return false
    end

    local weaponType = GetItemLinkWeaponType(link)

    return weaponType == WEAPONTYPE_TWO_HANDED_SWORD
        or weaponType == WEAPONTYPE_TWO_HANDED_AXE
        or weaponType == WEAPONTYPE_TWO_HANDED_HAMMER
        or weaponType == WEAPONTYPE_BOW
        or weaponType == WEAPONTYPE_FIRE_STAFF
        or weaponType == WEAPONTYPE_FROST_STAFF
        or weaponType == WEAPONTYPE_LIGHTNING_STAFF
        or weaponType == WEAPONTYPE_HEALING_STAFF
end

function MHCWL.FindSavedItemInBag(saved, bagId)
    if not saved or not bagId then return nil end

    if saved.id and saved.id ~= "0" then
        for slot = 0, GetBagSize(bagId) do
            local uid = Id64ToString(GetItemUniqueId(bagId, slot))

            if uid == saved.id then
                return slot, "uniqueId"
            end
        end
    end

    if saved.link and saved.link ~= "" then
        local wantedItemId = GetItemLinkItemId(saved.link)

        if wantedItemId and wantedItemId ~= 0 then
            for slot = 0, GetBagSize(bagId) do
                local link = GetItemLink(bagId, slot, LINK_STYLE_DEFAULT)

                if link ~= ""
                and GetItemLinkItemId(link) == wantedItemId then
                    return slot, "linkItemId"
                end
            end
        end
    end

    return nil, nil
end

function MHCWL.FindSavedItemInBackpack(saved)
    return MHCWL.FindSavedItemInBag(saved, BAG_BACKPACK)
end

function MHCWL.LoadGearSlotQueue(queue, index)
    index = index or 1

    if index > #queue then
        MHCWL.Debug("Gear queue finished.")

        zo_callLater(function()
            MHCWL.Debug("Post-gear-load scan:")
            MHCWL.ScanGear()

            if MHCWL.gearLoadCallback then
                local callback = MHCWL.gearLoadCallback
                MHCWL.gearLoadCallback = nil
                callback()
            end
        end, MHCWL.GetDelay(MHCWL.TIMINGS.gearLoadFinish))

        return
    end

    local entry = queue[index]
    local equipSlot = entry.equipSlot
    local saved = entry.saved

    local backpackSlot, matchType = MHCWL.FindSavedItemInBackpack(saved)

    if backpackSlot then
        MHCWL.Debug(
            "Equipping "
            .. MHCWL.SlotName(equipSlot)
            .. " via "
            .. tostring(matchType)
            .. ": "
            .. tostring(saved.link)
        )

        CallSecureProtected(
            "RequestMoveItem",
            BAG_BACKPACK,
            backpackSlot,
            BAG_COMPANION_WORN,
            equipSlot,
            1
        )
    else
        if MHCWL.IsSavedGearEquipped(saved, equipSlot) then
            MHCWL.Debug("Already equipped: " .. MHCWL.SlotName(equipSlot))
        else
            MHCWL.Debug(
                "Missing: "
                .. MHCWL.SlotName(equipSlot)
                .. " / "
                .. tostring(saved.link)
            )
        end
    end

    zo_callLater(function()
        MHCWL.LoadGearSlotQueue(queue, index + 1)
    end, MHCWL.GetDelay(MHCWL.TIMINGS.gearLoadStep))
end

function MHCWL.LoadGearAll(callback)
    if not HasActiveCompanion() then MHCWL.Debug("No active companion.") return end
    if not IsInteractingWithMyCompanion() then MHCWL.Debug("Open companion menu first.") return end
    if IsUnitInCombat("player") then MHCWL.Debug("Cannot load gear in combat.") return end

    local setup = MHCWL.GetActiveSetup()
    if not setup then return end

    local queue = {}

    MHCWL.gearLoadCallback = callback

    for _, equipSlot in ipairs(MHCWL.GEARSLOTS) do
        local saved = setup.gear[equipSlot]

        if saved
        and (
            (saved.id and saved.id ~= "0")
            or (saved.link and saved.link ~= "")
        ) then
            table.insert(queue, {
                equipSlot = equipSlot,
                saved = saved,
            })
        end
    end

    MHCWL.Debug("Loading companion gear queue: " .. tostring(#queue) .. " item(s)")

    MHCWL.LoadGearSlotQueue(queue, 1)
end