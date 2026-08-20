-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.Data = EPC.Data or {}
local D = EPC.Data

D.classNames = {
    [1] = "Dragonknight",
    [2] = "Sorcerer",
    [3] = "Nightblade",
    [4] = "Warden",
    [5] = "Necromancer",
    [6] = "Templar",
    [117] = "Arcanist",
}

D.raceNames = {
    [1] = "Breton", [2] = "Redguard", [3] = "Orc", [4] = "Dark Elf",
    [5] = "Nord", [6] = "Argonian", [7] = "High Elf", [8] = "Wood Elf",
    [9] = "Khajiit", [10] = "Imperial",
}

D.roleProfiles = {
    MAGICKA = {
        label = "Magicka DPS",
        preferredWeaponTypes = { [WEAPONTYPE_FIRE_STAFF or 12] = true, [WEAPONTYPE_LIGHTNING_STAFF or 15] = true },
        preferredArmor = ARMORTYPE_LIGHT,
        resource = POWERTYPE_MAGICKA,
    },
    STAMINA = {
        label = "Stamina DPS",
        preferredWeaponTypes = {
            [WEAPONTYPE_BOW or 8] = true,
            [WEAPONTYPE_TWO_HANDED_AXE or 4] = true,
            [WEAPONTYPE_TWO_HANDED_SWORD or 5] = true,
            [WEAPONTYPE_TWO_HANDED_HAMMER or 6] = true,
        },
        preferredArmor = ARMORTYPE_MEDIUM,
        resource = POWERTYPE_STAMINA,
    },
}

D.weaponNames = {
    [WEAPONTYPE_FIRE_STAFF or 12] = "Flame Staff",
    [WEAPONTYPE_FROST_STAFF or 13] = "Frost Staff",
    [WEAPONTYPE_HEALING_STAFF or 14] = "Restoration Staff",
    [WEAPONTYPE_LIGHTNING_STAFF or 15] = "Lightning Staff",
    [WEAPONTYPE_BOW or 8] = "Bow",
    [WEAPONTYPE_TWO_HANDED_AXE or 4] = "Two-Handed Axe",
    [WEAPONTYPE_TWO_HANDED_SWORD or 5] = "Two-Handed Sword",
    [WEAPONTYPE_TWO_HANDED_HAMMER or 6] = "Two-Handed Maul",
}

D.sorcererTips = {
    {
        minLevel = 1,
        maxLevel = 14,
        priority = 96,
        category = "SKILLS",
        title = "Keep a Sorcerer ability on your current skill bar",
        reason = "Before level 15, you have one weapon bar. Skills on the selected bar gain progress when XP is awarded.",
    },
    {
        minLevel = 15,
        priority = 96,
        category = "SKILLS",
        title = "Keep a Sorcerer ability on both weapon bars",
        reason = "Weapon Set 2 unlocks at level 15. Only skills on the selected bar gain XP, so keep a Sorcerer ability on both bars while leveling.",
    },
    {
        minLevel = 5,
        priority = 92,
        category = "SKILLS",
        title = "Level Destruction Staff alongside your class skills",
        reason = "A Magicka Sorcerer gets strong value from staff passives and a reliable ranged weapon toolkit.",
    },
    {
        minLevel = 10,
        priority = 86,
        category = "SKILLS",
        title = "Unlock and level Light Armor passives",
        reason = "Light Armor supports Magicka sustain and offensive spell-oriented progression.",
    },
    {
        minLevel = 15,
        priority = 89,
        category = "BUILD",
        title = "Give the front and back weapon bars clear jobs",
        reason = "Use the front bar for frequent direct damage and the back bar for buffs, damage-over-time, healing, or utility instead of duplicating every ability.",
    },
    {
        minLevel = 20,
        priority = 78,
        category = "SKILLS",
        title = "Morph the skills you actually use",
        reason = "Useful skill morphs are normally a larger leveling gain than spreading points across abilities that never reach your bars.",
    },
    {
        minLevel = 30,
        priority = 72,
        category = "SKILLS",
        title = "Round out class and weapon passives",
        reason = "By mid-leveling, passive multipliers and sustain bonuses compound across your entire rotation.",
    },
}

D.sorcererEndgameTips = {
    {
        priority = 94,
        category = "BUILD",
        title = "Tune your bars for the content you are running",
        reason = "At endgame, the best setup depends on solo play, four-player content, trials, PvP, and whether you are providing damage, healing, or tank utility.",
    },
    {
        priority = 91,
        category = "SKILLS",
        title = "Audit passives, morphs, and Champion Point slottables",
        reason = "Endgame gains often come from finishing the passives you actually benefit from and matching Champion Point slottables to your role and content.",
    },
    {
        priority = 88,
        category = "GEAR",
        title = "Build complete five-piece and weapon-set synergies",
        reason = "Endgame gear should be evaluated as a complete setup: set bonuses, weapon bars, traits, enchantments, armor weights, and content-specific utility all matter together.",
    },
}
