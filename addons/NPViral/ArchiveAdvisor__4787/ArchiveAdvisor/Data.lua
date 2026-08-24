ArchiveAdvisor = ArchiveAdvisor or {}
local ADDON = ArchiveAdvisor

ADDON.Data = {}

-- Exact live IDs confirmed from the U50 client.
ADDON.Data.SKILL_CAPABILITIES = {
    [23678] = { LIGHTNING = true, MAGICAL = true },
    [29489] = { SHIELD = true, MAGICAL = true },
    [39073] = { LIGHTNING = true, AOE = true, DOT = true, MAGICAL = true },
    [39089] = { STATUS = true, RANGED = true, MAGICAL = true },
    [23316] = { PET_SKILL = true, LIGHTNING = true, AOE = true, MAGICAL = true },
    [77182] = { PET_SKILL = true, LIGHTNING = true, AOE = true, MAGICAL = true },

    -- U50 Werewolf IDs confirmed from the active transformed hotbar.
    -- These remain exact fast paths; Build.lua also resolves the Werewolf
    -- progression lines at runtime so alternate morph/effective IDs inherit
    -- the same build capabilities without maintaining a copied ID catalogue.
    [58855] = { AOE = true, DOT = true, MARTIAL = true, STATUS = true }, -- Rending Claws
    [58742] = { MARTIAL = true, STATUS = true }, -- Rip and Tear
    [137164] = { DOT = true, MARTIAL = true }, -- Feral Carnage
}

-- Seed IDs are only used to resolve the three damaging Werewolf progression
-- lines through the ESO skill API. This makes the snapshot morph/effective-ID
-- aware while keeping the production data small and auditable.
ADDON.Data.WEREWOLF_LINE_SEEDS = {
    POUNCE = 39104,        -- Feral Pounce, observed pre-transform
    GNASH = 58405,         -- Gnash, observed
    RENDING_CLAWS = 58855, -- Rending Claws, observed
}

ADDON.Data.WEREWOLF_LINE_CAPABILITIES = {
    POUNCE = { DOT = true, MARTIAL = true, STATUS = true },
    GNASH = { MARTIAL = true, STATUS = true },
    RENDING_CLAWS = { AOE = true, MARTIAL = true, STATUS = true },
}

ADDON.Data.SERGEANTS_MAIL_SET_ID = 29
ADDON.Data.OAKENSOUL_SET_ID = 658

ADDON.Data.AVATAR_SETS = {
    FEROCIOUS = { 199990, 200421, 202743 },
    CRYSTALLINE = { 199997, 200494, 202510 },
    SCORCHING = { 200004, 200679, 202804 },
    NECROTIC = { 220557, 220563, 220568 },
}

ADDON.Data.AVATAR_SET_BY_ABILITY = {}
for setName, abilityIds in pairs(ADDON.Data.AVATAR_SETS) do
    for _, abilityId in ipairs(abilityIds) do
        ADDON.Data.AVATAR_SET_BY_ABILITY[abilityId] = setName
    end
end

-- Small player preference bias for LAM Recommendation Style. ZOS already
-- classifies every offered card as Offense, Defense, or Utility; Core.lua uses
-- that live bucket directly, so this table never needs manual category upkeep.
ADDON.Data.STYLE_BONUS = 10

-- Recommendation weights for the 111 Verse/Vision ability IDs confirmed in the U50 client.
-- Ability IDs are the authoritative keys. The short why text is player-facing.
ADDON.Data.EVALUATOR = {
    [191802] = { base = 90, flagPenalties = { HA_SPECIALIST = 90, WEAPON_ENCHANT = 30 }, why = "Transformation" }, -- Werewolf Behemoth
    [191849] = { base = 60, flagPenalties = { RANGED = 20 }, why = "Flame Damage" }, -- Flame Aura
    [191936] = { base = 62, arcBonus = { startArc = 3, perArc = 3, max = 18 }, why = "Shield" }, -- Sequential Shield
    [192667] = { base = 70, flagBonuses = { WEREWOLF_ACTIVE = 15 }, flagPenalties = { HA_SPECIALIST = 60 }, why = "Light Attack" }, -- Swift Gale
    [192848] = { base = 76, why = "AoE Debuff" }, -- Pustulent Globs
    [192992] = { base = 45, requiresFamily = "WEAPON", familyBonus = { family = "WEAPON", perSlot = 8, max = 32 }, why = "Damage" }, -- Archival Weaponry
    [193146] = { base = 34, flagBonuses = { SHIELD = 42 }, arcBonus = { startArc = 3, perArc = 2, max = 12 }, why = "Defense" }, -- Tempered Ward
    [193551] = { base = 42, why = "Frost AoE" }, -- Cold Blast
    [193597] = { base = 55, flagBonuses = { HA_SPECIALIST = 30 }, why = "Armor Shred" }, -- Beatdown
    [193692] = { base = 42, flagBonuses = { DOT = 15 }, arcBonus = { startArc = 3, perArc = 2, max = 10 }, why = "DoT Healing" }, -- Transfusion
    [193711] = { base = 42, why = "Major Buff" }, -- Siphoning Vigor
    [193749] = { base = 50, why = "Healing Done" }, -- Enhanced Remedy
    [193758] = { base = 30, flagBonuses = { MAGICKA_FOCUS = 20 }, why = "Full Restore" }, -- Magicka Renewal
    [193977] = { base = 42, flagBonuses = { AOE = 35 }, why = "Area Damage" }, -- Augmented Areas
    [193984] = { base = 62, flagBonuses = { WEREWOLF_ACTIVE = 15 }, why = "Bleed DoT" }, -- Exsanguinate
    [194030] = { base = 84, arcBonus = { startArc = 3, perArc = 4, max = 24 }, why = "Mitigation" }, -- Regenerating Bastion
    [194058] = { base = 48, arcBonus = { startArc = 3, perArc = 2, max = 10 }, why = "Healing" }, -- Restorative Elixirs
    [194062] = { base = 24, flagBonuses = { STAMINA_FOCUS = 20 }, why = "Full Restore" }, -- Stamina Renewal
    [194138] = { base = 96, arcBonus = { startArc = 2, perArc = 2, max = 8 }, attemptsBonus = { [1] = 30, [2] = 15 }, why = "Second Chance" }, -- Rebirth
    [194153] = { base = 42, flagBonuses = { HA_SPECIALIST = 30 }, arcBonus = { startArc = 3, perArc = 3, max = 18 }, why = "Defense" }, -- Reactive Curse
    [194166] = { base = 68, arcBonus = { startArc = 3, perArc = 4, max = 24 }, why = "AoE Mitigation" }, -- Archival Evasion
    [194179] = { base = 72, arcBonus = { startArc = 3, perArc = 4, max = 24 }, why = "Direct Mitigation" }, -- Head-On Defense
    [194181] = { base = 22, flagBonuses = { MAGICKA_FOCUS = 15 }, why = "Max Magicka" }, -- Magical Expiration
    [194183] = { base = 18, flagBonuses = { STAMINA_FOCUS = 15 }, why = "Max Stamina" }, -- Energetic Expiration
    [194192] = { base = 28, why = "Crowd Control" }, -- Glamorous Scholar
    [195038] = { base = 88, arcBonus = { startArc = 3, perArc = 3, max = 18 }, why = "Damage Reduction" }, -- Shackled Resolve
    [195928] = { base = 40, arcBonus = { startArc = 3, perArc = 2, max = 10 }, why = "Max Health" }, -- Vital Expiration
    [196018] = { base = 72, why = "Transformation" }, -- Iron Atronach
    [197522] = { base = 24, why = "Healing Done" }, -- Curative Vigor
    [197652] = { base = 58, arcBonus = { startArc = 3, perArc = 4, max = 24 }, why = "Max Health" }, -- Hearty Vitality
    [197684] = { base = 22, why = "Health Recovery" }, -- Refined Restoration
    [197694] = { base = 54, arcBonus = { startArc = 3, perArc = 3, max = 18 }, why = "DoT Mitigation" }, -- Armored Shell
    [199960] = { base = 58, arcBonus = { startArc = 3, perArc = 3, max = 18 }, why = "AoE Mitigation" }, -- Sweeping Guard
    [199990] = { base = 45, arcBonus = { startArc = 3, perArc = 2, max = 12 }, why = "Physical Defense" }, -- Ferocious Fortification
    [199997] = { base = 52, arcBonus = { startArc = 3, perArc = 2, max = 12 }, why = "Frost Defense" }, -- Crystalline Fortification
    [200004] = { base = 50, arcBonus = { startArc = 3, perArc = 2, max = 12 }, why = "Fire Defense" }, -- Scorching Fortification
    [200015] = { base = 12, requiresFamily = "WORLD", familyBonus = { family = "WORLD", perSlot = 10, max = 30 }, flagBonuses = { WEREWOLF_ACTIVE = 60 }, why = "Skill Damage" }, -- Archival Worldliness
    [200016] = { base = 18, requiresFamily = "GUILD", familyBonus = { family = "GUILD", perSlot = 10, max = 30 }, why = "Skill Damage" }, -- Guild Superiority
    [200017] = { base = 40, requiresFamily = "CLASS", familyBonus = { family = "CLASS", perSlot = 8, max = 32 }, why = "Skill Damage" }, -- Class Embodiment
    [200018] = { base = 15, requiresFamily = "AVA", familyBonus = { family = "AVA", perSlot = 10, max = 30 }, why = "Skill Damage" }, -- Archival Assault
    [200020] = { base = 45, flagBonuses = { AOE = 28 }, why = "Extra AoE" }, -- Magical Multitudes
    [200022] = { base = 20, why = "Crit Healing" }, -- Bolstered Mending
    [200045] = { base = 74, why = "Magic Damage" }, -- Orbiting Echoes
    [200051] = { base = 18, why = "Crit Healing" }, -- Energized Salve
    [200075] = { base = 32, flagBonuses = { WEREWOLF_ACTIVE = 60 }, flagPenalties = { HA_SPECIALIST = 22 }, why = "Light Attack" }, -- Frenzied Zeal
    [200093] = { base = 68, why = "Disease AoE" }, -- Guardian of Pestilence
    [200127] = { base = 42, arcBonus = { startArc = 3, perArc = 2, max = 12 }, why = "Block Sustain" }, -- Effortless Aegis
    [200135] = { base = 42, arcBonus = { startArc = 3, perArc = 2, max = 12 }, why = "Break Free" }, -- Unrestrained Endurance
    [200142] = { base = 44, arcBonus = { startArc = 3, perArc = 2, max = 12 }, why = "Dodge Sustain" }, -- Effortless Acrobatics
    [200150] = { base = 55, arcBonus = { startArc = 3, perArc = 3, max = 18 }, why = "Magic Defense" }, -- Mystical Ward
    [200164] = { base = 42, flagBonuses = { SHIELD = 38 }, arcBonus = { startArc = 3, perArc = 2, max = 12 }, why = "HoT + Shield" }, -- Restorative Protection
    [200175] = { base = 54, arcBonus = { startArc = 3, perArc = 3, max = 18 }, why = "Break Free" }, -- Redirecting Bonds
    [200180] = { base = 30, flagBonuses = { AOE = 12 }, why = "Area Damage" }, -- Powerful Domain
    [200202] = { base = 32, arcBonus = { startArc = 3, perArc = 2, max = 12 }, why = "Free Dodge" }, -- Defensive Maneuver
    [200204] = { base = 30, arcBonus = { startArc = 3, perArc = 2, max = 10 }, why = "Free Block" }, -- Fortified Dexterity
    [200236] = { base = 30, why = "CC Immunity" }, -- Restorative Enabling
    [200291] = { base = 36, flagBonuses = { MAGICAL = 30 }, why = "Crit Chance" }, -- Lethal Sorcery
    [200306] = { base = 65, flagBonuses = { HA_SPECIALIST = 20, WEREWOLF_ACTIVE = 20 }, why = "Sustain" }, -- Bountiful Resources
    [200311] = { base = 34, why = "Bash Damage" }, -- Mighty Bash
    [200359] = { base = 36, flagBonuses = { MARTIAL = 30 }, why = "Crit Chance" }, -- Brawling Advantage
    [200370] = { base = 35, flagBonuses = { MAGICAL = 28 }, why = "Crit Damage" }, -- Thaumic Boom
    [200399] = { base = 35, flagBonuses = { MARTIAL = 28 }, why = "Crit Damage" }, -- Brawling Blitz
    [200412] = { base = 76, flagBonuses = { WEREWOLF_ACTIVE = 20 }, why = "Ultimate + Mangle" }, -- Tomefoolery
    [200421] = { base = 28, flagBonuses = { MARTIAL = 25, WEREWOLF_ACTIVE = 28 }, why = "Avatar Damage" }, -- Ferocious Strikes
    [200494] = { base = 30, flagBonuses = { FROST = 35 }, why = "Avatar Damage" }, -- Crystalline Strikes
    [200521] = { base = 58, arcBonus = { startArc = 3, perArc = 3, max = 18 }, why = "Group Shields" }, -- Unwitting Fortress
    [200679] = { base = 30, flagBonuses = { FIRE = 35 }, why = "Avatar Damage" }, -- Scorching Strikes
    [200686] = { base = 52, why = "Penetration" }, -- Piercing Perfection
    [200714] = { base = 30, why = "Direct Damage" }, -- Painful Proficient
    [200728] = { base = 28, flagBonuses = { DOT = 10, MAGICAL = 8 }, flagPenalties = { WEREWOLF_ACTIVE = 10 }, why = "Magic DoT" }, -- Thumping Thaumaturgy
    [200742] = { base = 20, flagBonuses = { DOT = 10, MARTIAL = 18 }, why = "Longer DoTs" }, -- Persistent Pain
    [200790] = { base = 28, flagBonuses = { DOT = 22 }, why = "Longer DoTs" }, -- Lasting Harm
    [200798] = { base = 48, why = "Boss Damage" }, -- Targeted Ire
    [200904] = { base = 78, flagBonuses = { STATUS = 42 }, stackGoal = 5, belowGoalBonus = 10, afterGoalPenalty = 25, why = "Status Damage" }, -- Focused Efforts
    [200941] = { base = 5, why = "Gold" }, -- Gilded Sleight
    [201012] = { base = 30, requiresFlag = "PET_SKILL", flagBonuses = { PET_SKILL = 45, PET_ACTIVE = 15 }, stackGoal = 5, belowGoalBonus = 6, why = "Damage" }, -- Well-Trained Command
    [201098] = { base = 0, why = "XP" }, -- Lessons Learned
    [201341] = { base = 0, why = "Gold" }, -- Full Coffers
    [201400] = { base = 34, flagBonuses = { MAGICKA_FOCUS = 15 }, why = "Recovery" }, -- Archival Intelligence
    [201407] = { base = 30, flagBonuses = { STAMINA_FOCUS = 15 }, why = "Recovery" }, -- Archival Endurance
    [201414] = { base = 50, flagBonuses = { STAMINA_FOCUS = 15 }, arcBonus = { startArc = 3, perArc = 2, max = 12 }, stackGoal = 2, belowGoalBonus = 12, afterGoalPenalty = 24, why = "Max Stamina" }, -- Stamina Reserves
    [201428] = { base = 44, flagBonuses = { MAGICKA_FOCUS = 18 }, arcBonus = { startArc = 3, perArc = 2, max = 12 }, why = "Max Magicka" }, -- Magicka Reserves
    [201435] = { base = 28, flagBonuses = { WEREWOLF_ACTIVE = 18 }, why = "Ultimate Cost" }, -- Boundless Potential
    [201443] = { base = 28, why = "Buff Duration" }, -- Extended Favor
    [201472] = { base = 60, arcBonus = { startArc = 3, perArc = 3, max = 18 }, why = "Decoy + Defense" }, -- Eye Catching
    [201474] = { base = 66, arcBonus = { startArc = 3, perArc = 3, max = 18 }, why = "CC Immunity" }, -- Resolute Mind
    [201491] = { base = 28, requiresFlag = "WEAPON_ENCHANT", flagBonuses = { WEAPON_ENCHANT = 32, WEAKENING_ENCHANT = 30 }, arcBonus = { startArc = 3, perArc = 3, max = 18 }, stackGoal = 5, belowGoalBonus = 8, afterGoalPenalty = 20, why = "Weapon Enchant" }, -- Attuned Enchantments
    [201504] = { base = 45, requiresFlag = "POISON", why = "Poison Power" }, -- Vicious Poisons
    [202134] = { base = 34, why = "Transformation" }, -- Ice Avatar
    [202510] = { base = 42, arcBonus = { startArc = 3, perArc = 2, max = 12 }, why = "Crowd Control" }, -- Crystalline Support
    [202743] = { base = 50, flagBonuses = { HA_SPECIALIST = 46 }, stackGoal = 1, why = "Heavy Attack" }, -- Ferocious Support
    [202804] = { base = 58, why = "Lava Damage" }, -- Scorching Support
    [211730] = { base = 105, attemptsBonus = { [1] = 45, [2] = 25 }, stackGoal = 1, afterGoalPenalty = 200, why = "Extra Thread" }, -- Supplemental Thread
    [220160] = { base = 34, arcBonus = { startArc = 4, perArc = 2, max = 12 }, why = "Block + Bash" }, -- Reflected Ruin
    [220184] = { base = 66, why = "Shock Damage" }, -- Tempest
    [220189] = { base = 72, flagPenalties = { HA_SPECIALIST = 20 }, why = "Transformation" }, -- Undead Avatar
    [220193] = { base = 55, arcBonus = { startArc = 3, perArc = 2, max = 10 }, why = "CC + Sustain" }, -- Grasping Limbs
    [220194] = { base = 34, why = "Movement Speed" }, -- Temporal Speed
    [220195] = { base = 82, arcBonus = { startArc = 3, perArc = 2, max = 10 }, why = "Enemy Debuff" }, -- Extravagant Elixirs
    [220557] = { base = 48, arcBonus = { startArc = 3, perArc = 2, max = 12 }, why = "Magic Defense" }, -- Necrotic Fortification
    [220563] = { base = 28, why = "Magic Damage" }, -- Necrotic Strikes
    [220568] = { base = 42, why = "Resource Restore" }, -- Necrotic Support
    [220730] = { base = 64, arcBonus = { startArc = 3, perArc = 2, max = 12 }, why = "Shield + CC" }, -- Phalanx
    [220765] = { base = 45, flagBonuses = { LIGHTNING = 15 }, why = "Shock Damage" }, -- Storm Projection
    [220770] = { base = 38, arcBonus = { startArc = 3, perArc = 2, max = 12 }, why = "Retaliation" }, -- Prickly Retort
    [220775] = { base = 52, arcBonus = { startArc = 3, perArc = 2, max = 12 }, why = "Defense" }, -- Apocryphal Emissary
    [220780] = { base = 20, why = "Potion Cooldown" }, -- Quickened Tinctures
    [221194] = { base = 80, why = "Persistent Damage" }, -- Fire Orb
    [222405] = { base = 58, arcBonus = { startArc = 3, perArc = 4, max = 24 }, why = "Low-Health Defense" }, -- Adaptive Defender
    [222413] = { base = 42, flagPenalties = { WEREWOLF_ACTIVE = 20 }, why = "Ultimate Damage" }, -- Adaptive Conqueror
    [222418] = { base = 38, why = "Resource Recovery" }, -- Adaptive Athlete
}
