-- ============================================================================
-- Companion Wardrobe
-- Inspect Window - Text View
--
-- Responsibilities:
-- - Build text representations of saved gear and skills.
-- - Manage armor, weapon, and skill text tabs.
-- - Provide item/ability tooltip data for text inspect rows.
-- - Keep text view output readable and localization-aware.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

MHCWL.inspectViewMode = "visual"

function MHCWL.ToggleInspectViewMode()
    if MHCWL.inspectViewMode == "visual" then
        MHCWL.inspectViewMode = "text"
    else
        MHCWL.inspectViewMode = "visual"
    end

    if MHCWL.inspectIndex then
        MHCWL.RefreshInspectWindow(MHCWL.inspectIndex)
    end
end

MHCWL.inspectTextMode = "armor"

function MHCWL.RefreshInspectTextTabs()
    local window = MHCWL.inspectWindow
    if not window then return end

    if window.textArmorButton and window.textArmorButton.RefreshIcon then
        window.textArmorButton.RefreshIcon()
    end

    if window.textWeaponsButton and window.textWeaponsButton.RefreshIcon then
        window.textWeaponsButton.RefreshIcon()
    end

    if window.textSkillsButton and window.textSkillsButton.RefreshIcon then
        window.textSkillsButton.RefreshIcon()
    end
end

function MHCWL.GetSavedGearText(equipSlot, gear)
    local slotText = MHCWL.SlotName(equipSlot)

    if not gear or not gear.link or gear.link == "" then
        return slotText .. ": |c" .. MHCWL.TEXT_COLORS.warning .. GetString(MHCWL_INSPECT_TEXT_EMPTY) .. "|r"
    end

    local link = gear.link

    local armorType = GetItemLinkArmorType(link)
    local traitType, traitDescription = GetItemLinkTraitInfo(link)

    local typeText = GetString(MHCWL_INSPECT_TEXT_GEAR)

    if armorType == ARMORTYPE_LIGHT then
        typeText = GetString(MHCWL_INSPECT_TEXT_LIGHT)
    elseif armorType == ARMORTYPE_MEDIUM then
        typeText = GetString(MHCWL_INSPECT_TEXT_MEDIUM)
    elseif armorType == ARMORTYPE_HEAVY then
        typeText = GetString(MHCWL_INSPECT_TEXT_HEAVY)
    elseif equipSlot == EQUIP_SLOT_NECK then
        typeText = GetString(MHCWL_INSPECT_TEXT_NECKLACE)
    elseif equipSlot == EQUIP_SLOT_RING1
    or equipSlot == EQUIP_SLOT_RING2 then
        typeText = GetString(MHCWL_INSPECT_TEXT_RING)
    elseif equipSlot == EQUIP_SLOT_MAIN_HAND
    or equipSlot == EQUIP_SLOT_OFF_HAND then
        local weaponType = GetItemLinkWeaponType(link)
        local weaponName = MHCWL.CleanEsoName(GetString("SI_WEAPONTYPE", weaponType)) or GetString(MHCWL_INSPECT_TEXT_WEAPON)
        local weaponPower = GetItemLinkWeaponPower(link)

        if weaponPower and weaponPower > 0 then
            typeText = zo_strformat(GetString(MHCWL_INSPECT_TEXT_WEAPON_DAMAGE), weaponName, weaponPower)
        else
            typeText = weaponName
        end
    end

    local traitName = GetString(MHCWL_INSPECT_TEXT_NO_TRAIT)
    traitDescription = traitDescription or ""

    if traitType and traitType ~= ITEM_TRAIT_TYPE_NONE then
        traitName = MHCWL.CleanEsoName(GetString("SI_ITEMTRAITTYPE", traitType)) or GetString(MHCWL_INSPECT_TEXT_TRAIT)
    end

    local infoText = typeText .. " - " .. traitName

    if traitDescription ~= "" then
        infoText = infoText .. "\n  " .. traitDescription
    end

    local quality = GetItemLinkQuality(link)
    local qualityColor = quality and GetItemQualityColor(quality)

    if qualityColor and qualityColor.Colorize then
        infoText = qualityColor:Colorize(infoText)
    end

    return string.format(
        "%s: %s",
        slotText,
        infoText
    )
end

function MHCWL.GetSavedSkillText(slotIndex, abilityId)
    local slotName = MHCWL.GetDisplaySkillSlotName(slotIndex)

    if not abilityId or abilityId <= 0 then
        return slotName .. ": |c" .. MHCWL.TEXT_COLORS.warning .. GetString(MHCWL_INSPECT_TEXT_EMPTY) .. "|r"
    end

    local name = MHCWL.CleanEsoName(GetAbilityName(abilityId)) or GetString(MHCWL_INSPECT_TEXT_UNKNOWN)

    local target = GetAbilityTargetDescription(abilityId) or "-"

    local _, castTime = GetAbilityCastInfo(abilityId)
    local duration = GetAbilityDuration and GetAbilityDuration(abilityId)
    local cooldown = GetAbilityCooldown and GetAbilityCooldown(abilityId)

    local function FormatMs(value)
        value = tonumber(value) or 0

        if value <= 0 then
            return "-"
        end

        return string.format("%.1fs", value / 1000)
    end

    local baseValues = zo_strformat(
        GetString(MHCWL_INSPECT_TEXT_SKILL_BASE_VALUES),
        FormatMs(castTime),
        target,
        FormatMs(duration),
        FormatMs(cooldown)
    )

    local infoText = string.format(
        "%s\n  %s",
        name,
        baseValues
    )

    infoText = "|c" .. MHCWL.TEXT_COLORS.skill .. infoText .. "|r"

    return string.format(
        "%s: %s",
        slotName,
        infoText
    )
end

function MHCWL.BuildInspectText(index)
    if MHCWL.inspectTextMode == "weapons" then
        return MHCWL.BuildInspectWeaponText(index)
    elseif MHCWL.inspectTextMode == "skills" then
        return MHCWL.BuildInspectSkillText(index)
    end

    return MHCWL.BuildInspectArmorText(index)
end

function MHCWL.BuildInspectArmorText(index)
    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then return "" end

    local setup = companionData.setups[index]
    if not setup then return "" end

    local armorSlots = {
        EQUIP_SLOT_HEAD,
        EQUIP_SLOT_SHOULDERS,
        EQUIP_SLOT_CHEST,
        EQUIP_SLOT_HAND,
        EQUIP_SLOT_WAIST,
        EQUIP_SLOT_LEGS,
        EQUIP_SLOT_FEET,
    }

    local lines = {}

    table.insert(lines, GetString(MHCWL_INSPECT_TEXT_ARMOR_HEADER))
    table.insert(lines, "")

    MHCWL.inspectGearTextTooltips = {}

    for _, equipSlot in ipairs(armorSlots) do
        local gear = setup.gear and setup.gear[equipSlot]

        MHCWL.inspectGearTextTooltips[#MHCWL.inspectGearTextTooltips + 1] = {
            link = gear and gear.link,
        }
        table.insert(lines, MHCWL.GetSavedGearText(equipSlot, gear))
        table.insert(lines, " ")
    end

    return table.concat(lines, "\n")
end

function MHCWL.BuildInspectWeaponText(index)
    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then return "" end

    local setup = companionData.setups[index]
    if not setup then return "" end

    local lines = {}

    table.insert(lines, GetString(MHCWL_INSPECT_TEXT_JEWELRY_HEADER))
    table.insert(lines, "")

    local jewelrySlots = {
        EQUIP_SLOT_NECK,
        EQUIP_SLOT_RING1,
        EQUIP_SLOT_RING2,
    }

    MHCWL.inspectGearTextTooltips = {}

    for _, equipSlot in ipairs(jewelrySlots) do
        local gear = setup.gear and setup.gear[equipSlot]

        MHCWL.inspectGearTextTooltips[#MHCWL.inspectGearTextTooltips + 1] = {
            link = gear and gear.link,
        }

        table.insert(lines, MHCWL.GetSavedGearText(equipSlot, gear))
        table.insert(lines, " ")
    end

    table.insert(lines, "")
    table.insert(lines, GetString(MHCWL_INSPECT_TEXT_WEAPONS_HEADER))
    table.insert(lines, "")
    local mainGear = setup.gear and setup.gear[EQUIP_SLOT_MAIN_HAND]
    local mainLink = mainGear and mainGear.link
    local mainWeaponType = mainLink and GetItemLinkWeaponType(mainLink)
    local mainWeaponName = mainWeaponType and GetString("SI_WEAPONTYPE", mainWeaponType) or GetString(MHCWL_INSPECT_TEXT_TWO_HANDED_WEAPON)

    MHCWL.inspectGearTextTooltips[#MHCWL.inspectGearTextTooltips + 1] = {
        link = mainLink,
    }

    table.insert(lines, MHCWL.GetSavedGearText(EQUIP_SLOT_MAIN_HAND, mainGear))
    table.insert(lines, " ")

    if MHCWL.IsTwoHandedWeaponLink(mainLink) then
        local blockedText =
            MHCWL.SlotName(EQUIP_SLOT_OFF_HAND)
            .. ": "
            .. "|c"
            .. MHCWL.TEXT_COLORS.warning
            .. GetString(MHCWL_INSPECT_TEXT_BLOCKED)
            .. tostring(mainWeaponName)
            .. "|r"

        MHCWL.inspectGearTextTooltips[#MHCWL.inspectGearTextTooltips + 1] = {
            link = mainLink,
        }

        table.insert(lines, blockedText)
    else
        local offGear = setup.gear and setup.gear[EQUIP_SLOT_OFF_HAND]

        MHCWL.inspectGearTextTooltips[#MHCWL.inspectGearTextTooltips + 1] = {
            link = offGear and offGear.link,
        }

        table.insert(lines, MHCWL.GetSavedGearText(EQUIP_SLOT_OFF_HAND, offGear))
    end
    return table.concat(lines, "\n")
end

function MHCWL.BuildInspectSkillText(index)
    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then
        return ""
    end

    local setup = companionData.setups[index]
    if not setup then
        return ""
    end

    local lines = {}

    table.insert(lines, GetString(MHCWL_INSPECT_TEXT_SKILLS_HEADER))
    table.insert(lines, "")

    MHCWL.inspectSkillTextTooltips = {}

    for _, slotIndex in ipairs(MHCWL.COMPANION_SKILL_SLOTS) do
        local abilityId = setup.skills and setup.skills[slotIndex] or 0

        MHCWL.inspectSkillTextTooltips[slotIndex] = {
            abilityId = abilityId,
        }

        table.insert(lines, MHCWL.GetSavedSkillText(slotIndex, abilityId))
        table.insert(lines, " ")
    end

    return table.concat(lines, "\n")
end