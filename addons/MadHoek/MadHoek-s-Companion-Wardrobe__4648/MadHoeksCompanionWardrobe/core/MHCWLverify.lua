-- ============================================================================
-- Companion Wardrobe
-- Loadout Verification
--
-- Responsibilities:
-- - Compare saved gear/skills against the currently active companion state.
-- - Detect mismatches after loading a setup.
-- - Provide safe gear comparison that survives ESO unique-id instability.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

-- Check whether a saved gear entry is already equipped in the expected companion slot.
function MHCWL.IsSavedGearEquipped(saved, equipSlot)
    if not saved then return false end
    -- Companion gear uniqueIds may differ across sessions/contexts.
    -- Fallback to itemId comparison prevents false missing-gear warnings.
    -- First: exact unique-id match
    if saved.id and saved.id ~= "0" then
        local equippedId = Id64ToString(GetItemUniqueId(BAG_COMPANION_WORN, equipSlot))

        if equippedId == saved.id then
            return true
        end
    end

    -- Second: link itemId fallback
    if saved.link and saved.link ~= "" then
        local equippedLink = GetItemLink(BAG_COMPANION_WORN, equipSlot, LINK_STYLE_DEFAULT)

        if equippedLink ~= "" then
            return GetItemLinkItemId(equippedLink) == GetItemLinkItemId(saved.link)
        end
    end

    return false
end

-- Debug verification pass used after loading to report gear or skill mismatches.
function MHCWL.VerifySetup()
    if not HasActiveCompanion() then
        MHCWL.Debug("No active companion.")
        return
    end

    local setup = MHCWL.GetActiveSetup()
    if not setup then return end

    MHCWL.Debug("Verifying companion setup...")

    local gearOk = true
    local skillsOk = true

    -- GEAR
    for _, equipSlot in ipairs(MHCWL.GEARSLOTS) do
        local saved = setup.gear[equipSlot]

        local equippedLink = GetItemLink(
            BAG_COMPANION_WORN,
            equipSlot,
            LINK_STYLE_DEFAULT
        )

        local savedLink = saved and saved.link or ""

        local equippedItemId =
            equippedLink ~= "" and GetItemLinkItemId(equippedLink) or 0

        local savedItemId =
            savedLink ~= "" and GetItemLinkItemId(savedLink) or 0

        if equippedItemId ~= savedItemId then
            gearOk = false

            MHCWL.Debug(string.format(
                "GEAR MISMATCH [%s] saved=%s current=%s",
                MHCWL.SlotName(equipSlot),
                savedLink ~= "" and savedLink or "-",
                equippedLink ~= "" and equippedLink or "-"
            ))
        end
    end

    -- SKILLS
    for _, slotIndex in ipairs(MHCWL.COMPANION_SKILL_SLOTS) do
        local savedAbilityId = setup.skills[slotIndex] or 0
        local currentAbilityId = GetSlotBoundId(
            slotIndex,
            HOTBAR_CATEGORY_COMPANION
        ) or 0

        if savedAbilityId ~= currentAbilityId then
            skillsOk = false

            MHCWL.Debug(string.format(
                "SKILL MISMATCH [slot %s] saved=%s current=%s",
                tostring(slotIndex),
                tostring(savedAbilityId),
                tostring(currentAbilityId)
            ))
        end
    end

    if gearOk then
        MHCWL.Debug("Gear verification: OK")
    end

    if skillsOk then
        MHCWL.Debug("Skill verification: OK")
    end

    if gearOk and skillsOk then
        MHCWL.Debug("FULL VERIFY: SUCCESS")
    else
        MHCWL.Debug("FULL VERIFY: FAILED")
    end
end