ArchiveAdvisor = ArchiveAdvisor or {}
local ADDON = ArchiveAdvisor

ADDON.Build = {}

local EQUIPPED_SLOTS = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_NECK,
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2,
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
}

local HOTBARS = {
    HOTBAR_CATEGORY_PRIMARY,
    HOTBAR_CATEGORY_BACKUP,
}

local PRIMARY_WEAPON_SLOTS = {
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
}

local BACKUP_WEAPON_SLOTS = {
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
}

local function GetEquippedSets()
    local sets = {}

    for _, equipSlot in ipairs(EQUIPPED_SLOTS) do
        local itemLink = GetItemLink(BAG_WORN, equipSlot, LINK_STYLE_DEFAULT)
        if itemLink ~= "" then
            local hasSet, _, _, numNormalEquipped, _, setId, numPerfectedEquipped = GetItemLinkSetInfo(itemLink)
            if hasSet and setId and setId > 0 and not sets[setId] then
                sets[setId] = (numNormalEquipped or 0) + (numPerfectedEquipped or 0)
            end
        end
    end

    return sets
end

local function GetRelevantHotbars(hasOakensoul)
    if not hasOakensoul then
        return HOTBARS
    end

    local activeHotbar = GetActiveHotbarCategory()
    if activeHotbar == HOTBAR_CATEGORY_PRIMARY or activeHotbar == HOTBAR_CATEGORY_BACKUP then
        return { activeHotbar }
    end

    return { HOTBAR_CATEGORY_PRIMARY }
end

local function GetSlottedAbilities(hotbars)
    local abilities = {}

    for _, hotbarCategory in ipairs(hotbars) do
        for slotIndex = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX, ACTION_BAR_ULTIMATE_SLOT_INDEX do
            local abilityId = GetSlotBoundId(slotIndex, hotbarCategory)
            if abilityId and abilityId > 0 then
                abilities[abilityId] = true
            end
        end
    end

    return abilities
end


local function ResolveAbilitySkillFamily(abilityId)
    local hasProgression, progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
    if hasProgression and progressionIndex then
        local skillType, skillLineIndex, abilityIndex = GetSkillAbilityIndicesFromProgressionIndex(progressionIndex)
        if skillType and skillType > 0 then
            return skillType, skillLineIndex, abilityIndex
        end
    end

    local skillType, skillLineIndex, abilityIndex = GetSpecificSkillAbilityKeysByAbilityId(abilityId)
    if skillType and skillType > 0 then
        return skillType, skillLineIndex, abilityIndex
    end

    return nil, nil, nil
end


local function ResolveCanonicalAbilityId(abilityId)
    local hasProgression, progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
    if hasProgression and progressionIndex then
        local skillType, skillLineIndex, abilityIndex = GetSkillAbilityIndicesFromProgressionIndex(progressionIndex)
        if skillType and skillType > 0 and skillLineIndex and skillLineIndex > 0 and abilityIndex and abilityIndex > 0 then
            local canonicalId = GetSkillAbilityId(skillType, skillLineIndex, abilityIndex, false)
            if canonicalId and canonicalId > 0 then
                return canonicalId
            end
        end
    end

    return abilityId
end

local function GetAbilityCostSignals(abilities)
    local magickaCostSkills = 0
    local staminaCostSkills = 0

    for abilityId in pairs(abilities) do
        local queryId = ResolveCanonicalAbilityId(abilityId)
        local baseCost, mechanicFlags = GetAbilityBaseCostInfo(queryId, nil, "player")
        if baseCost and baseCost > 0 then
            if mechanicFlags == COMBAT_MECHANIC_FLAGS_MAGICKA then
                magickaCostSkills = magickaCostSkills + 1
            elseif mechanicFlags == COMBAT_MECHANIC_FLAGS_STAMINA then
                staminaCostSkills = staminaCostSkills + 1
            end
        end
    end

    return magickaCostSkills, staminaCostSkills
end

local function GetSkillFamilyCounts(abilities)
    local counts = {
        CLASS = 0,
        WEAPON = 0,
        GUILD = 0,
        WORLD = 0,
        AVA = 0,
    }

    for abilityId in pairs(abilities) do
        local skillType = ResolveAbilitySkillFamily(abilityId)
        if skillType == SKILL_TYPE_CLASS then
            counts.CLASS = counts.CLASS + 1
        elseif skillType == SKILL_TYPE_WEAPON then
            counts.WEAPON = counts.WEAPON + 1
        elseif skillType == SKILL_TYPE_GUILD then
            counts.GUILD = counts.GUILD + 1
        elseif skillType == SKILL_TYPE_WORLD then
            counts.WORLD = counts.WORLD + 1
        elseif skillType == SKILL_TYPE_AVA then
            counts.AVA = counts.AVA + 1
        end
    end

    return counts
end

local function ApplySkillCapabilities(flags, abilities)
    for abilityId in pairs(abilities) do
        local capabilityData = ADDON.Data.SKILL_CAPABILITIES[abilityId]
        if capabilityData then
            for capability, enabled in pairs(capabilityData) do
                if enabled then
                    flags[capability] = true
                end
            end
        end
    end
end

local werewolfLineProgressions = nil

local function GetWerewolfLineProgressions()
    if werewolfLineProgressions then
        return werewolfLineProgressions
    end

    werewolfLineProgressions = {}
    for lineName, seedAbilityId in pairs(ADDON.Data.WEREWOLF_LINE_SEEDS or {}) do
        local hasProgression, progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(seedAbilityId)
        if hasProgression and progressionIndex then
            werewolfLineProgressions[lineName] = progressionIndex
        end
    end

    return werewolfLineProgressions
end

local function GetWerewolfAbilityLineMap()
    local lineByAbilityId = {}

    -- Build this per snapshot because effective Werewolf IDs can change with
    -- the current hotbar override state (for example Pounce -> Carnage).
    for lineName, progressionIndex in pairs(GetWerewolfLineProgressions()) do
        for morphChoice = 0, 2 do
            for rank = 1, 4 do
                local abilityId = GetAbilityProgressionAbilityId(progressionIndex, morphChoice, rank)
                if abilityId and abilityId > 0 then
                    lineByAbilityId[abilityId] = lineName

                    local effectiveId = GetEffectiveAbilityIdForAbilityOnHotbar(abilityId, HOTBAR_CATEGORY_WEREWOLF)
                    if effectiveId and effectiveId > 0 then
                        lineByAbilityId[effectiveId] = lineName
                    end
                end
            end
        end
    end

    return lineByAbilityId
end

local function ApplyWerewolfLineCapabilities(flags, abilities)
    local lineByAbilityId = GetWerewolfAbilityLineMap()
    local lineProgressions = GetWerewolfLineProgressions()

    -- Werewolf Light/Heavy Attacks and its damaging kit are martial even when
    -- the character underneath is using a staff or another ranged weapon.
    flags.MARTIAL = true

    for abilityId in pairs(abilities) do
        local lineName = lineByAbilityId[abilityId]

        -- Normal morph IDs expose their progression directly. Effective IDs
        -- such as Carnage are normally resolved by the hotbar map above.
        if not lineName then
            local hasProgression, progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
            if hasProgression and progressionIndex then
                for candidateLine, candidateProgression in pairs(lineProgressions) do
                    if candidateProgression == progressionIndex then
                        lineName = candidateLine
                        break
                    end
                end
            end
        end

        local capabilityData = lineName and ADDON.Data.WEREWOLF_LINE_CAPABILITIES[lineName]
        if capabilityData then
            for capability, enabled in pairs(capabilityData) do
                if enabled then
                    flags[capability] = true
                end
            end
        end
    end
end

local function ApplyWeaponTypeSignals(flags, weaponType)
    -- Weapon type alone is not a build specialization signal. It is only used
    -- here for the structural ranged capability.
    if weaponType == WEAPONTYPE_LIGHTNING_STAFF
        or weaponType == WEAPONTYPE_FIRE_STAFF
        or weaponType == WEAPONTYPE_FROST_STAFF
        or weaponType == WEAPONTYPE_HEALING_STAFF
        or weaponType == WEAPONTYPE_BOW then
        flags.RANGED = true
    end
end

local function GetWeaponSlotsForHotbar(hotbarCategory)
    return hotbarCategory == HOTBAR_CATEGORY_BACKUP and BACKUP_WEAPON_SLOTS or PRIMARY_WEAPON_SLOTS
end

local function GetPoisonSlotForHotbar(hotbarCategory)
    return hotbarCategory == HOTBAR_CATEGORY_BACKUP and EQUIP_SLOT_BACKUP_POISON or EQUIP_SLOT_POISON
end

local function IsHotbarPoisoned(hotbarCategory)
    return HasItemInSlot(BAG_WORN, GetPoisonSlotForHotbar(hotbarCategory))
end

local function GetWeaponSignals(flags, hotbars)
    local weaponTypes = {}
    local hasWeaponEnchant = false

    for _, hotbarCategory in ipairs(hotbars) do
        local poisoned = IsHotbarPoisoned(hotbarCategory)
        if poisoned then
            flags.POISON = true
        end

        for _, equipSlot in ipairs(GetWeaponSlotsForHotbar(hotbarCategory)) do
            local itemLink = GetItemLink(BAG_WORN, equipSlot, LINK_STYLE_DEFAULT)
            if itemLink ~= "" then
                local weaponType = GetItemLinkWeaponType(itemLink)
                if weaponType and weaponType ~= WEAPONTYPE_NONE then
                    weaponTypes[weaponType] = true
                    ApplyWeaponTypeSignals(flags, weaponType)
                end

                -- A poison suppresses the weapon enchant on that bar.
                if not poisoned then
                    local hasEnchant = GetItemLinkEnchantInfo(itemLink)
                    if hasEnchant then
                        hasWeaponEnchant = true

                        local finalEnchantId = GetItemLinkFinalEnchantId(itemLink)
                        if finalEnchantId and finalEnchantId > 0 then
                            local enchantCategory = GetEnchantSearchCategoryType(finalEnchantId)
                            if enchantCategory == ENCHANTMENT_SEARCH_CATEGORY_REDUCE_POWER then
                                flags.WEAKENING_ENCHANT = true
                            end
                        end
                    end
                end
            end
        end
    end

    if hasWeaponEnchant then
        flags.WEAPON_ENCHANT = true
    end

    return weaponTypes
end

local function HasActivePet()
    for petIndex = 1, 7 do
        if DoesUnitExist(string.format("playerpet%d", petIndex)) then
            return true
        end
    end

    return false
end

local function GetRunState()
    local runState = {
        arc = 0,
        attemptsRemaining = 0,
        verseStacks = {},
        visionStacks = {},
    }

    if not ENDLESS_DUNGEON_MANAGER then
        return runState
    end

    local _, _, arc = ENDLESS_DUNGEON_MANAGER:GetProgression()
    runState.arc = arc or 0
    runState.attemptsRemaining = ENDLESS_DUNGEON_MANAGER:GetAttemptsRemaining() or 0

    local verses = ENDLESS_DUNGEON_MANAGER:GetAbilityStackCountTable(ENDLESS_DUNGEON_BUFF_TYPE_VERSE)
    local visions = ENDLESS_DUNGEON_MANAGER:GetAbilityStackCountTable(ENDLESS_DUNGEON_BUFF_TYPE_VISION)

    if verses then
        for abilityId, stackCount in pairs(verses) do
            runState.verseStacks[abilityId] = stackCount
        end
    end

    if visions then
        for abilityId, stackCount in pairs(visions) do
            runState.visionStacks[abilityId] = stackCount
        end
    end

    return runState
end

function ADDON.Build:Snapshot()
    local flags = {
        HA_SPECIALIST = false,
        PET_SKILL = false,
        PET_ACTIVE = false,
        STATUS = false,
        SHIELD = false,
        LIGHTNING = false,
        AOE = false,
        RANGED = false,
        WEAPON_ENCHANT = false,
        WEAKENING_ENCHANT = false,
        DOT = false,
        MAGICAL = false,
        MARTIAL = false,
        MAGICKA_FOCUS = false,
        STAMINA_FOCUS = false,
        POISON = false,
        FIRE = false,
        FROST = false,
        WEREWOLF_ACTIVE = false,
    }

    local activeHotbar = GetActiveHotbarCategory()
    flags.WEREWOLF_ACTIVE = activeHotbar == HOTBAR_CATEGORY_WEREWOLF

    local sets = GetEquippedSets()
    local hasOakensoul = sets[ADDON.Data.OAKENSOUL_SET_ID] ~= nil
    local hotbars = GetRelevantHotbars(hasOakensoul)
    local skillHotbars = flags.WEREWOLF_ACTIVE and { HOTBAR_CATEGORY_WEREWOLF } or hotbars
    local abilities = GetSlottedAbilities(skillHotbars)
    local skillFamilyCounts = GetSkillFamilyCounts(abilities)

    ApplySkillCapabilities(flags, abilities)
    if flags.WEREWOLF_ACTIVE then
        ApplyWerewolfLineCapabilities(flags, abilities)
    end
    local magickaCostSkills, staminaCostSkills = GetAbilityCostSignals(abilities)

    -- Attribute allocation is the primary resource signal. Skill costs are only
    -- a fallback when the allocation is tied.
    local magickaAttributePoints = GetAttributeSpentPoints(ATTRIBUTE_MAGICKA) or 0
    local staminaAttributePoints = GetAttributeSpentPoints(ATTRIBUTE_STAMINA) or 0

    if magickaAttributePoints > staminaAttributePoints then
        flags.MAGICKA_FOCUS = true
    elseif staminaAttributePoints > magickaAttributePoints then
        flags.STAMINA_FOCUS = true
    elseif magickaCostSkills >= staminaCostSkills + 2 then
        flags.MAGICKA_FOCUS = true
    elseif staminaCostSkills >= magickaCostSkills + 2 then
        flags.STAMINA_FOCUS = true
    end

    if HasActivePet() then
        flags.PET_ACTIVE = true
        flags.PET_SKILL = true
    end

    local weaponTypes = GetWeaponSignals(flags, hotbars)

    -- The equipped weapon remains relevant for enchants/poisons while
    -- transformed, but its human combat geometry does not describe Werewolf.
    if flags.WEREWOLF_ACTIVE then
        flags.RANGED = false
    end

    -- Weapon damage family only counts when a Weapon skill is actually slotted.
    if (skillFamilyCounts.WEAPON or 0) > 0 then
        if weaponTypes[WEAPONTYPE_LIGHTNING_STAFF]
            or weaponTypes[WEAPONTYPE_FIRE_STAFF]
            or weaponTypes[WEAPONTYPE_FROST_STAFF]
            or weaponTypes[WEAPONTYPE_HEALING_STAFF] then
            flags.MAGICAL = true
        end

        if weaponTypes[WEAPONTYPE_BOW]
            or weaponTypes[WEAPONTYPE_AXE]
            or weaponTypes[WEAPONTYPE_HAMMER]
            or weaponTypes[WEAPONTYPE_SWORD]
            or weaponTypes[WEAPONTYPE_DAGGER]
            or weaponTypes[WEAPONTYPE_TWO_HANDED_AXE]
            or weaponTypes[WEAPONTYPE_TWO_HANDED_HAMMER]
            or weaponTypes[WEAPONTYPE_TWO_HANDED_SWORD] then
            flags.MARTIAL = true
        end
    end

    -- Strong Heavy-Attack specialization signals only. Human HA specialization
    -- does not carry into the Werewolf combat bar.
    if not flags.WEREWOLF_ACTIVE then
        local sergeantsMail = sets[ADDON.Data.SERGEANTS_MAIL_SET_ID]
        if (sergeantsMail and sergeantsMail >= 5)
            or (hasOakensoul and weaponTypes[WEAPONTYPE_LIGHTNING_STAFF]) then
            flags.HA_SPECIALIST = true
        end

        -- For a Heavy-Attack specialist, the staff element is a relevant signal.
        if flags.HA_SPECIALIST then
            if weaponTypes[WEAPONTYPE_LIGHTNING_STAFF] then
                flags.LIGHTNING = true
            elseif weaponTypes[WEAPONTYPE_FIRE_STAFF] then
                flags.FIRE = true
            elseif weaponTypes[WEAPONTYPE_FROST_STAFF] then
                flags.FROST = true
            end
        end
    end

    return {
        skillFamilyCounts = skillFamilyCounts,
        flags = flags,
        run = GetRunState(),
    }
end
