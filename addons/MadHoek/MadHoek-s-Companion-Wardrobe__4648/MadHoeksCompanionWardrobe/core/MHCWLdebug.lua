-- ============================================================================
-- Companion Wardrobe
-- Debug and Developer Utilities
--
-- Responsibilities:
-- - Provide debug chat output.
-- - Expose developer-only inspection helpers.
-- - Print saved loadout and runtime state for troubleshooting.
-- - Stay gated behind debug settings where appropriate.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

function MHCWL.IsDebugEnabled()
    return MHCWL.saved
        and MHCWL.saved.settings
        and MHCWL.saved.settings.debug == true
end

function MHCWL.Debug(text)
    if not MHCWL.IsDebugEnabled() then return end

    if not MHCWL.saved.settings.debugMessages then
        return
    end

    d("|c88CCFF[MHCWL]|r " .. tostring(text))
end

function MHCWL.DebugCommand(text)
    if not MHCWL.IsDebugEnabled() then return end

    d("|c88CCFF[MHCWL]|r " .. tostring(text))
end

function MHCWL.DebugHeader(title)
    MHCWL.DebugCommand(" ")
    MHCWL.DebugCommand("=== " .. tostring(title) .. " ===")
end

function MHCWL.DebugLine(label, value)
    MHCWL.DebugCommand(tostring(label) .. ": " .. tostring(value))
end

function MHCWL.DebugBool(label, value)
    MHCWL.DebugLine(label, value == true and "true" or "false")
end

function MHCWL.DebugLinkLine(label, link)
    if link and link ~= "" then
        MHCWL.DebugLine(label, link)
    else
        MHCWL.DebugLine(label, "-")
    end
end

function MHCWL.DebugContext()
    MHCWL.DebugHeader("Context")

    MHCWL.DebugBool("HasActiveCompanion", HasActiveCompanion())
    MHCWL.DebugBool("IsInteractingWithMyCompanion", IsInteractingWithMyCompanion())
    MHCWL.DebugBool("IsBankOpen", IsBankOpen())
    MHCWL.DebugBool("AreCompanionSkillsInitialized", AreCompanionSkillsInitialized and AreCompanionSkillsInitialized())
    MHCWL.DebugBool("IsPlayerInCombat", IsUnitInCombat("player"))
end

function MHCWL.DebugCompanion()
    MHCWL.DebugHeader("Companion")

    MHCWL.DebugBool("HasActiveCompanion", HasActiveCompanion())

    if not HasActiveCompanion() then
        return
    end

    local companionDefId = GetActiveCompanionDefId()
    local name = MHCWL.GetCompanionDisplayName(companionDefId)

    MHCWL.DebugLine("Name", name)
    MHCWL.DebugLine("Companion DefId", companionDefId)

    if GetCompanionCollectibleId then
        MHCWL.DebugLine("CollectibleId", GetCompanionCollectibleId(companionDefId))
    end

    if GetCompanionRace then
        local race = GetCompanionRace(companionDefId)
        MHCWL.DebugLine("Race", race)
        MHCWL.DebugLine("Race Name", GetString("SI_RACE", race) or "-")
    end

    if GetCompanionGender then
        local gender = GetCompanionGender(companionDefId)
        MHCWL.DebugLine("Gender", gender)
        MHCWL.DebugLine("Gender Name", GetString("SI_GENDER", gender) or "-")
    end

    if GetActiveCompanionLevelInfo then
        local level, currentXp, maxXp = GetActiveCompanionLevelInfo()

        MHCWL.DebugLine("Level", level)
        MHCWL.DebugLine("XP", tostring(currentXp) .. " / " .. tostring(maxXp))
    end

    if GetActiveCompanionRapport then
        MHCWL.DebugLine("Rapport", GetActiveCompanionRapport())
    end
end

function MHCWL.DebugGearLink(link)
    if not link or link == "" then
        MHCWL.DebugLine("Link", "-")
        return
    end

    MHCWL.DebugLinkLine("Link", link)

    if GetItemLinkItemId then
        MHCWL.DebugLine("ItemId", GetItemLinkItemId(link))
    end

    if GetItemLinkName then
        MHCWL.DebugLine("Name", zo_strformat("<<1>>", GetItemLinkName(link)))
    end

    if GetItemLinkQuality then
        MHCWL.DebugLine("Quality", GetItemLinkQuality(link))
    end

    if GetItemLinkArmorType then
        local armorType = GetItemLinkArmorType(link)

        if armorType and armorType ~= ARMORTYPE_NONE then
            MHCWL.DebugLine("ArmorType", tostring(armorType) .. " / " .. tostring(GetString("SI_ARMORTYPE", armorType)))
        end
    end

    if GetItemLinkWeaponType then
        local weaponType = GetItemLinkWeaponType(link)

        if weaponType and weaponType ~= WEAPONTYPE_NONE then
            MHCWL.DebugLine("WeaponType", tostring(weaponType) .. " / " .. tostring(GetString("SI_WEAPONTYPE", weaponType)))

            if weaponType == WEAPONTYPE_HEALING_STAFF then
                MHCWL.DebugLine("Role Guess", "Healing")
            else
                MHCWL.DebugLine("Role Guess", "Damage")
            end
        end
    end

    if GetItemLinkTraitInfo then
        local traitType, traitDescription = GetItemLinkTraitInfo(link)

        MHCWL.DebugLine("TraitType", tostring(traitType) .. " / " .. tostring(GetString("SI_ITEMTRAITTYPE", traitType)))
        MHCWL.DebugLine("TraitDescription", traitDescription or "-")
    end

    if GetItemLinkWeaponPower then
        MHCWL.DebugLine("WeaponPower", GetItemLinkWeaponPower(link))
    end

    if GetItemLinkArmorRating then
        MHCWL.DebugLine("ArmorRating", GetItemLinkArmorRating(link))
    end

    if GetItemLinkRequiredLevel then
        MHCWL.DebugLine("RequiredLevel", GetItemLinkRequiredLevel(link))
    end

    if GetItemLinkRequiredChampionPoints then
        MHCWL.DebugLine("RequiredCP", GetItemLinkRequiredChampionPoints(link))
    end
end

function MHCWL.DebugGear()
    MHCWL.DebugHeader("Equipped Companion Gear")

    if not HasActiveCompanion() then
        MHCWL.DebugCommand("No active companion.")
        return
    end

    for _, equipSlot in ipairs(MHCWL.GEARSLOTS) do
        local link = GetItemLink(BAG_COMPANION_WORN, equipSlot, LINK_STYLE_DEFAULT)
        local uniqueId = Id64ToString(GetItemUniqueId(BAG_COMPANION_WORN, equipSlot))
        local itemId = GetItemId(BAG_COMPANION_WORN, equipSlot)

        MHCWL.DebugCommand(" ")
        MHCWL.DebugHeader(MHCWL.SlotName(equipSlot))

        MHCWL.DebugLine("EquipSlot", equipSlot)
        MHCWL.DebugLine("BagItemId", itemId)
        MHCWL.DebugLine("UniqueId", uniqueId)

        MHCWL.DebugGearLink(link)
    end
end

function MHCWL.DebugSkillAbility(abilityId)
    if not abilityId or abilityId <= 0 then
        MHCWL.DebugLine("AbilityId", "-")
        return
    end

    MHCWL.DebugLine("AbilityId", abilityId)
    MHCWL.DebugLine("Name", GetAbilityName(abilityId) or "-")

    if GetAbilityIcon then
        MHCWL.DebugLine("Icon", GetAbilityIcon(abilityId) or "-")
    end

    if GetAbilityTargetDescription then
        MHCWL.DebugLine("Target", GetAbilityTargetDescription(abilityId) or "-")
    end

    if GetAbilityCastInfo then
        local channeled, castTime, channelTime, angleDistance, mechanic, interruptible, blockable = GetAbilityCastInfo(abilityId)

        MHCWL.DebugLine("CastTime", castTime)
        MHCWL.DebugLine("ChannelTime", channelTime)
        MHCWL.DebugLine("Channeled", channeled)
        MHCWL.DebugLine("Interruptible", interruptible)
        MHCWL.DebugLine("Blockable", blockable)
        MHCWL.DebugLine("Mechanic", mechanic)
        MHCWL.DebugLine("Angle/Distance", angleDistance)
    end

    if GetAbilityDuration then
        MHCWL.DebugLine("Duration", GetAbilityDuration(abilityId))
    end

    if GetAbilityCooldown then
        MHCWL.DebugLine("Cooldown", GetAbilityCooldown(abilityId))
    end

    if IsCompanionAbilityUnlocked then
        MHCWL.DebugBool("Unlocked", IsCompanionAbilityUnlocked(abilityId))
    end

    local info = MHCWL.GetCompanionSkillLineInfo and MHCWL.GetCompanionSkillLineInfo(abilityId)

    if info then
        MHCWL.DebugLine("SkillLine", info.skillLine or "-")
        MHCWL.DebugLine("SkillLineAbility", info.ability or "-")
    end
end

function MHCWL.DebugSkills()
    MHCWL.DebugHeader("Equipped Companion Skills")

    if not HasActiveCompanion() then
        MHCWL.DebugCommand("No active companion.")
        return
    end

    if AreCompanionSkillsInitialized and not AreCompanionSkillsInitialized() then
        MHCWL.DebugCommand("Companion skills are not initialized.")
        return
    end

    for _, slotIndex in ipairs(MHCWL.COMPANION_SKILL_SLOTS) do
        local boundId = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_COMPANION) or 0
        local slotType = GetSlotType(slotIndex, HOTBAR_CATEGORY_COMPANION)

        MHCWL.DebugCommand(" ")
        MHCWL.DebugHeader(MHCWL.GetDisplaySkillSlotName(slotIndex))

        MHCWL.DebugLine("HotbarSlot", slotIndex)
        MHCWL.DebugLine("SlotType", slotType)

        MHCWL.DebugSkillAbility(boundId)
    end
end

function MHCWL.DebugSaved()
    MHCWL.DebugHeader("Saved Active Loadout")

    local setup, companionData, activeIndex = MHCWL.GetActiveSetup()

    if not setup then
        MHCWL.DebugCommand("No active saved setup.")
        return
    end

    MHCWL.DebugLine("Companion", companionData and companionData.name or "-")
    MHCWL.DebugLine("ActiveIndex", activeIndex)
    MHCWL.DebugLine("Name", setup.name)
    MHCWL.DebugBool("Locked", setup.locked)
    MHCWL.DebugBool("Favorite", setup.isFavorite)
    MHCWL.DebugLine("NameColorSlot", setup.nameColorSlot or "-")
    MHCWL.DebugBool("UseColorWhenFavorite", setup.useColorWhenFavorite)

    MHCWL.DebugHeader("Saved Gear")

    for _, equipSlot in ipairs(MHCWL.GEARSLOTS) do
        local gear = setup.gear and setup.gear[equipSlot]

        MHCWL.DebugCommand(" ")
        MHCWL.DebugLine("Slot", MHCWL.SlotName(equipSlot))

        if gear then
            MHCWL.DebugLine("SavedUniqueId", gear.id or "-")
            MHCWL.DebugLinkLine("SavedLink", gear.link)
        else
            MHCWL.DebugLine("Saved", "-")
        end
    end

    MHCWL.DebugHeader("Saved Skills")

    for _, slotIndex in ipairs(MHCWL.COMPANION_SKILL_SLOTS) do
        local abilityId = setup.skills and setup.skills[slotIndex] or 0

        MHCWL.DebugCommand(" ")
        MHCWL.DebugLine("Slot", MHCWL.GetDisplaySkillSlotName(slotIndex))
        MHCWL.DebugSkillAbility(abilityId)
    end
end

function MHCWL.DebugCompanionSkillLines()
    MHCWL.DebugHeader("Companion Skill Lines")

    if not AreCompanionSkillsInitialized or not AreCompanionSkillsInitialized() then
        MHCWL.DebugCommand("Companion skills are not initialized.")
        return
    end

    for skillType = 1, 20 do
        local numLines = GetNumCompanionSkillLines(skillType) or 0

        if numLines > 0 then
            MHCWL.DebugCommand(" ")
            MHCWL.DebugLine("SkillType", skillType)
            MHCWL.DebugLine("Lines", numLines)

            for lineIndex = 1, numLines do
                local skillLineId = GetCompanionSkillLineId(skillType, lineIndex)
                local name = GetCompanionSkillLineNameById(skillLineId)

                MHCWL.DebugCommand("- " .. tostring(skillLineId) .. " / " .. tostring(name))

                local numAbilities = GetNumAbilitiesInCompanionSkillLine(skillLineId) or 0

                for abilityIndex = 1, numAbilities do
                    local abilityId = GetCompanionAbilityId(skillLineId, abilityIndex)

                    MHCWL.DebugCommand("    "
                        .. tostring(abilityIndex)
                        .. ": "
                        .. tostring(abilityId)
                        .. " / "
                        .. tostring(GetAbilityName(abilityId))
                    )
                end
            end
        end
    end
end

function MHCWL.DebugAll()
    MHCWL.DebugContext()
    MHCWL.DebugCompanion()
    MHCWL.DebugGear()
    MHCWL.DebugSkills()
    MHCWL.DebugSaved()
end