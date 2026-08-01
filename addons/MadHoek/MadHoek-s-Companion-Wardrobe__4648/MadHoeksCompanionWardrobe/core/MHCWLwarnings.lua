-- ============================================================================
-- Companion Wardrobe
-- Warning Detection and Warning Tooltips
--
-- Responsibilities:
-- - Detect missing gear, locked skill slots, invalid skills, and locked skill lines.
-- - Build warning data once so UI layers can decide how to display it.
-- - Provide shared tooltip text for main window and inspect window warnings.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

-- Create the normalized warning structure expected by all warning UI consumers.
function MHCWL.CreateEmptyWarnings()
    return {
        missingGear = {},

        lockedSkillSlots = {},
        lockedSkillLines = {},
        invalidSkills = {},

        lockedSkillLinesBySlot = {},
        invalidSkillsBySlot = {},
    }
end

-- Debug helper used to force locked-skill warning paths during testing.
function MHCWL.ShouldForceLockedSkills()
    return MHCWL.saved
        and MHCWL.saved.settings
        and MHCWL.saved.settings.debug
        and MHCWL.saved.settings.debugForceLockedSkills
end

-- Resolve an abilityId back to its companion skill line and ability name for tooltips.
function MHCWL.GetCompanionSkillLineInfo(abilityId)
    local skillTypes = {1, 2, 3, 5, 7}

    for _, skillType in ipairs(skillTypes) do
        local numLines = GetNumCompanionSkillLines(skillType) or 0

        for lineIndex = 1, numLines do
            local skillLineId = GetCompanionSkillLineId(skillType, lineIndex)
            local numAbilities = GetNumAbilitiesInCompanionSkillLine(skillLineId) or 0

            for abilityIndex = 1, numAbilities do
                local currentAbilityId = GetCompanionAbilityId(skillLineId, abilityIndex)

                if currentAbilityId == abilityId then
                    return {
                        skillLine = MHCWL.CleanEsoName(GetCompanionSkillLineNameById(skillLineId)),
                        ability = MHCWL.CleanEsoName(GetAbilityName(abilityId)),
                    }
                end
            end
        end
    end

    return nil
end

function MHCWL.HasWarnings(warnings)
    if not warnings then return false end

    return #warnings.missingGear > 0
        or #warnings.lockedSkillSlots > 0
        or #warnings.lockedSkillLines > 0
        or #warnings.invalidSkills > 0
end

-- Build warning data for one loadout without deciding how the UI should show it.
function MHCWL.GetSetupWarnings(setup)
    local warnings = MHCWL.CreateEmptyWarnings()

    if not setup then return warnings end

    for _, equipSlot in ipairs(MHCWL.GEARSLOTS) do
        local saved = setup.gear and setup.gear[equipSlot]

        if saved
        and (
            (saved.id and saved.id ~= "0")
            or (saved.link and saved.link ~= "")
        ) then
            local backpackSlot = MHCWL.FindSavedItemInBackpack(saved)
            local isEquipped = MHCWL.IsSavedGearEquipped(saved, equipSlot)

            if not backpackSlot and not isEquipped then
                table.insert(warnings.missingGear, equipSlot)
            end
        end
    end

    local companionLevel = 0

    if GetActiveCompanionLevelInfo then
        companionLevel = select(1, GetActiveCompanionLevelInfo()) or 0
    end

    for _, slotIndex in ipairs(MHCWL.COMPANION_SKILL_SLOTS) do
        local abilityId = setup.skills and setup.skills[slotIndex] or 0
        local unlockLevel = MHCWL.SKILL_SLOT_UNLOCK_LEVELS[slotIndex] or 1

        local hasSavedSkill = abilityId and abilityId > 0

        if hasSavedSkill and companionLevel < unlockLevel then
            table.insert(warnings.lockedSkillSlots, slotIndex)
        elseif hasSavedSkill and GetAbilityName(abilityId) == "" then
            table.insert(warnings.invalidSkills, abilityId)
            warnings.invalidSkillsBySlot[slotIndex] = abilityId
        elseif hasSavedSkill and (MHCWL.ShouldForceLockedSkills() or not IsCompanionAbilityUnlocked(abilityId)) then
            table.insert(warnings.lockedSkillLines, abilityId)
            warnings.lockedSkillLinesBySlot[slotIndex] = abilityId
        end
    end

    return warnings
end

-- Convert warning data into a shared tooltip string, respecting tooltip mode.
function MHCWL.GetWarningTooltip(warnings)
    if not MHCWL.HasWarnings(warnings) then
        return ""
    end

    local lines = {}

    local function AddSectionHeader(text)
        if #lines > 0 then
            table.insert(lines, "")
        end

        table.insert(lines, text)
    end

    if MHCWL.AreTutorialTooltipsEnabled() then
        table.insert(
            lines,
            "|cFFFF66" .. GetString(MHCWL_WARNING_TOOLTIP_TITLE) .. "|r"
        )
    end

    if #warnings.missingGear > 0 then
        AddSectionHeader(GetString(MHCWL_WARNING_MISSING_GEAR))

        for _, equipSlot in ipairs(warnings.missingGear) do
            table.insert(lines, "- " .. MHCWL.SlotName(equipSlot))
        end
    end

    if #warnings.lockedSkillSlots > 0 then
        AddSectionHeader(GetString(MHCWL_WARNING_LOCKED_SKILL_SLOTS))

        for _, slotIndex in ipairs(warnings.lockedSkillSlots) do
            table.insert(lines, "- " .. MHCWL.GetDisplaySkillSlotName(slotIndex))
        end
    end

    if #warnings.invalidSkills > 0 then
        AddSectionHeader(GetString(MHCWL_WARNING_INVALID_SKILLS))

        for _, abilityId in ipairs(warnings.invalidSkills) do
            table.insert(lines, "- " .. tostring(abilityId))
        end
    end

    if #warnings.lockedSkillLines > 0 then
        AddSectionHeader(GetString(MHCWL_WARNING_LOCKED_SKILL_LINES))

        local grouped = {}

        for _, abilityId in ipairs(warnings.lockedSkillLines) do
            local info = MHCWL.GetCompanionSkillLineInfo(abilityId)

            if info then
                grouped[info.skillLine] = grouped[info.skillLine] or {}

                table.insert(grouped[info.skillLine], info.ability)
            end
        end

        for skillLine, abilities in pairs(grouped) do
            table.insert(lines, "- " .. skillLine .. ":")

            for _, ability in ipairs(abilities) do
                table.insert(lines, "    " .. ability)
            end
        end
    end

    return table.concat(lines, "\n")
end