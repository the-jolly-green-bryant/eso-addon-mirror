-- Beltalowda Mundus Stone Data
-- Central catalog of all 13 Mundus Stone (Boon) buffs and their ability IDs.
-- These are permanent active effects on each character. Detection is done by
-- scanning GetUnitBuffInfo() for matching ability IDs — no localization needed
-- since ESO provides localized names and icons via GetAbilityName/GetAbilityIcon.
--
-- The Twice-Born Star set (setId 257) allows a character to have two mundus
-- stones active simultaneously.

Beltalowda = Beltalowda or {}
Beltalowda.Data = Beltalowda.Data or {}
Beltalowda.Data.MundusData = {}

local MD = Beltalowda.Data.MundusData

-- ============================================================================
-- Mundus Stone Definitions
-- ============================================================================

--[[
    MUNDUS_STONES: Keyed by ability ID (the abilityId returned from GetUnitBuffInfo).
    Each entry contains:
      - name:        English fallback name (used only if GetAbilityName fails)
      - iconPath:    Fallback icon path (used only if GetAbilityIcon fails)
      - effect:      Human-readable description of the buff effect
      - type:        "offensive" or "defensive" (for potential future grouping)
]]--
MD.MUNDUS_STONES = {
    [13940] = {
        name = "The Warrior",
        iconPath = "/esoui/art/icons/ability_mundusstones_001.dds",
        effect = "Increases Weapon Damage",
        type = "offensive",
    },
    [13943] = {
        name = "The Mage",
        iconPath = "/esoui/art/icons/ability_mundusstones_002.dds",
        effect = "Increases Maximum Magicka",
        type = "offensive",
    },
    [13974] = {
        name = "The Serpent",
        iconPath = "/esoui/art/icons/ability_mundusstones_004.dds",
        effect = "Increases Stamina Recovery",
        type = "offensive",
    },
    [13975] = {
        name = "The Thief",
        iconPath = "/esoui/art/icons/ability_mundusstones_003.dds",
        effect = "Increases Weapon and Spell Critical",
        type = "offensive",
    },
    [13976] = {
        name = "The Lady",
        iconPath = "/esoui/art/icons/ability_mundusstones_005.dds",
        effect = "Increases Physical and Spell Resistance",
        type = "defensive",
    },
    [13977] = {
        name = "The Steed",
        iconPath = "/esoui/art/icons/ability_mundusstones_006.dds",
        effect = "Increases Health Recovery and Movement Speed",
        type = "defensive",
    },
    [13978] = {
        name = "The Lord",
        iconPath = "/esoui/art/icons/ability_mundusstones_007.dds",
        effect = "Increases Maximum Health",
        type = "defensive",
    },
    [13979] = {
        name = "The Apprentice",
        iconPath = "/esoui/art/icons/ability_mundusstones_008.dds",
        effect = "Increases Spell Damage",
        type = "offensive",
    },
    [13980] = {
        name = "The Ritual",
        iconPath = "/esoui/art/icons/ability_mundusstones_010.dds",
        effect = "Increases Healing Done",
        type = "defensive",
    },
    [13981] = {
        name = "The Lover",
        iconPath = "/esoui/art/icons/ability_mundusstones_011.dds",
        effect = "Increases Physical and Spell Penetration",
        type = "offensive",
    },
    [13982] = {
        name = "The Atronach",
        iconPath = "/esoui/art/icons/ability_mundusstones_009.dds",
        effect = "Increases Magicka Recovery",
        type = "offensive",
    },
    [13984] = {
        name = "The Shadow",
        iconPath = "/esoui/art/icons/ability_mundusstones_012.dds",
        effect = "Increases Critical Damage and Healing Done",
        type = "offensive",
    },
    [13985] = {
        name = "The Tower",
        iconPath = "/esoui/art/icons/ability_mundusstones_013.dds",
        effect = "Increases Maximum Stamina",
        type = "offensive",
    },
}

-- ============================================================================
-- Reverse Lookup: Set of all mundus ability IDs for fast detection
-- ============================================================================

MD.MUNDUS_ABILITY_IDS = {}
for abilityId, _ in pairs(MD.MUNDUS_STONES) do
    MD.MUNDUS_ABILITY_IDS[abilityId] = true
end

-- ============================================================================
-- Twice-Born Star set ID (allows two mundus stones)
-- ============================================================================

MD.TWICE_BORN_STAR_SET_ID = 257

-- ============================================================================
-- Public API
-- ============================================================================

--[[
    Check if an ability ID is a mundus stone buff.
    @param abilityId: Numeric ability ID
    @return: boolean
]]--
function MD.IsMundusAbility(abilityId)
    return MD.MUNDUS_ABILITY_IDS[abilityId] == true
end

--[[
    Get the mundus stone definition for a given ability ID.
    @param abilityId: Numeric ability ID
    @return: Definition table, or nil
]]--
function MD.GetMundusStone(abilityId)
    return MD.MUNDUS_STONES[abilityId]
end

--[[
    Get the display name for a mundus stone.
    Uses the game's localized ability name, falling back to the English name.
    @param abilityId: Numeric ability ID
    @return: Localized string (e.g., "Boon: The Warrior")
]]--
function MD.GetMundusName(abilityId)
    local gameName = GetAbilityName(abilityId)
    if gameName and gameName ~= "" then
        return zo_strformat("<<1>>", gameName)
    end
    local def = MD.MUNDUS_STONES[abilityId]
    return def and def.name or ("Mundus #" .. tostring(abilityId))
end

--[[
    Get the icon for a mundus stone.
    Uses the game's ability icon, falling back to the hardcoded path.
    @param abilityId: Numeric ability ID
    @return: Icon path string
]]--
function MD.GetMundusIcon(abilityId)
    local icon = GetAbilityIcon(abilityId)
    if icon and icon ~= "" then return icon end
    local def = MD.MUNDUS_STONES[abilityId]
    return def and def.iconPath or "/esoui/art/icons/ability_mundusstones_001.dds"
end
