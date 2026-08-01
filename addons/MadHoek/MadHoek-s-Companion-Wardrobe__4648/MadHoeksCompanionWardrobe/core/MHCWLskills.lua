-- ============================================================================
-- Companion Wardrobe
-- Companion Skill Helpers
--
-- Responsibilities:
-- - Read currently slotted companion skills.
-- - Load saved skills back into companion slots.
-- - Provide skill slot constants and display names.
-- - Support save/load, warnings, verification, and inspect views.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

MHCWL.COMPANION_SKILL_SLOTS = { 3, 4, 5, 6, 7, 8 }

function MHCWL.ScanSkills()
    MHCWL.Debug("AreCompanionSkillsInitialized: " .. tostring(AreCompanionSkillsInitialized()))

    if not AreCompanionSkillsInitialized() then return end

    MHCWL.Debug("Scanning HOTBAR_CATEGORY_COMPANION...")

    for _, slotIndex in ipairs(MHCWL.COMPANION_SKILL_SLOTS) do
        local boundId = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_COMPANION)
        local slotType = GetSlotType(slotIndex, HOTBAR_CATEGORY_COMPANION)
        local abilityName = boundId and GetAbilityName(boundId) or ""

        MHCWL.Debug(string.format(
            "slot %s | boundId=%s | type=%s | name=%s",
            tostring(slotIndex),
            tostring(boundId),
            tostring(slotType),
            abilityName ~= "" and abilityName or "-"
        ))
    end
end

function MHCWL.LoadSkillsAll()
    if not HasActiveCompanion() then MHCWL.Debug("No active companion.") return end
    if not IsInteractingWithMyCompanion() then MHCWL.Debug("Open companion menu first.") return end
    if IsUnitInCombat("player") then MHCWL.Debug("Cannot load skills in combat.") return end
    if not AreCompanionSkillsInitialized() then MHCWL.Debug("Companion skills not initialized.") return end

    local setup = MHCWL.GetActiveSetup()
    if not setup then return end

    local hotbarData = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(HOTBAR_CATEGORY_COMPANION)
    if not hotbarData then MHCWL.Debug("No companion hotbar data.") return end

    MHCWL.Debug("Loading all companion skills...")

    for _, slotIndex in ipairs(MHCWL.COMPANION_SKILL_SLOTS) do
        local abilityId = setup.skills[slotIndex]

        if abilityId and abilityId > 0 then
            MHCWL.Debug("Slot " .. tostring(slotIndex) .. ": " .. tostring(abilityId) .. " / " .. GetAbilityName(abilityId))
            hotbarData:AssignSkillToSlotByAbilityId(slotIndex, abilityId)
        else
            MHCWL.Debug("Slot " .. tostring(slotIndex) .. ": empty/skipped")
        end
    end

    zo_callLater(function()
        MHCWL.Debug("Post-skill-load scan:")
        MHCWL.ScanSkills()
    end, MHCWL.GetDelay(MHCWL.TIMINGS.skillLoadFinish))
end