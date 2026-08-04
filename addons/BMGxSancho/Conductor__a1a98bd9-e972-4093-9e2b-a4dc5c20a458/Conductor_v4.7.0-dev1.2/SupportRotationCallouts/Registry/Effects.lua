local R = Conductor.Registry

local effects = {
    -- Buffs
    { "MAJOR_FORCE", "Major Force", "BUFF", {"AGGRESSIVE_HORN","WAR_HORN","SAXHLEEL_CHAMPION","LIGHTS_CHAMPION"}, "Critical damage support" },
    { "MINOR_FORCE", "Minor Force", "BUFF", {"BARBED_TRAP","LIGHTWEIGHT_BEAST_TRAP","CHANNELED_ACCELERATION","ACCELERATE","RACE_AGAINST_TIME","MEDUSA"}, "Critical damage support" },
    { "MAJOR_SLAYER", "Major Slayer", "BUFF", {"ROARING_OPPORTUNIST","PERFECTED_ROARING_OPPORTUNIST","MASTER_ARCHITECT","WAR_MACHINE"}, "Trial and dungeon damage support" },
    { "MINOR_SLAYER", "Minor Slayer", "BUFF", {"TRIAL_SET_BONUS"}, "Passive trial and dungeon damage" },
    { "MAJOR_COURAGE", "Major Courage", "BUFF", {"SPELL_POWER_CURE","OLORIME"}, "Weapon and spell damage support" },
    { "MAJOR_MENDING", "Major Mending", "BUFF", {"OBSIDIAN_SHIELD","ACCELERATED_GROWTH","ESSENCE_DRAIN"}, "Healing done support" },
    { "MINOR_COURAGE", "Minor Courage", "BUFF", {"CLAW_OF_YOLNAHKRIIN","ARCANISTS_DOMAIN","ZENAS_EMPOWERING_DISC","RECONSTRUCTIVE_DOMAIN","PACK_LEADER"}, "Weapon and spell damage support" },
    { "MAJOR_RESOLVE", "Major Resolve", "BUFF", {"EXPANSIVE_FROST_CLOAK","FROST_CLOAK","ICE_FORTRESS","RESOLVING_VIGOR","RUNE_FOCUS","BOUNDLESS_STORM","HURRICANE","LIGHTNING_FORM","UNSTOPPABLE","IMMOVABLE"}, "Armor increase" },
    { "MINOR_RESOLVE", "Minor Resolve", "BUFF", {"COMBAT_PRAYER","BLESSING_OF_PROTECTION","BLESSING_OF_RESTORATION","MIRAGE"}, "Armor increase" },
    { "MAJOR_BERSERK", "Major Berserk", "BUFF", {"SEA_SERPENTS_COIL","STORM_ATRONACH_SYNERGY","HIRCINES_RAGE","ROUSING_ROAR"}, "Damage done support" },
    { "MINOR_BERSERK", "Minor Berserk", "BUFF", {"COMBAT_PRAYER","CAMOUFLAGED_HUNTER","KINRAS_WRATH"}, "Damage done support" },
    { "MINOR_BRUTALITY", "Minor Brutality", "BUFF", {"PASSIVE_MOUNTAIN_BLESSING"}, "Group weapon damage support" },
    { "MINOR_SORCERY", "Minor Sorcery", "BUFF", {"PASSIVE_ILLUMINATE"}, "Group spell damage support" },
    { "MINOR_PROPHECY", "Minor Prophecy", "BUFF", {"PASSIVE_EXPLOITATION"}, "Group spell critical support" },
    { "MINOR_SAVAGERY", "Minor Savagery", "BUFF", {"PASSIVE_HEMORRHAGE"}, "Group weapon critical support" },
    { "MAJOR_BRUTALITY", "Major Brutality", "BUFF", {"IGNEOUS_WEAPONS","MOLTEN_WEAPONS","MOLTEN_ARMAMENTS","DEGENERATION","ENTROPY","STRUCTURED_ENTROPY","MOMENTUM","RALLY","FORWARD_MOMENTUM","HIDDEN_BLADE","FLYING_BLADE","SHROUDED_DAGGERS","BLUE_BETTY","BULL_NETCH"}, "Weapon damage support" },
    { "MAJOR_SORCERY", "Major Sorcery", "BUFF", {"IGNEOUS_WEAPONS","MOLTEN_WEAPONS","MOLTEN_ARMAMENTS","DEGENERATION","ENTROPY","STRUCTURED_ENTROPY","MOMENTUM","RALLY","FORWARD_MOMENTUM","BLUE_BETTY","BULL_NETCH"}, "Spell damage support" },
    { "MAJOR_PROPHECY", "Major Prophecy", "BUFF", {"INNER_LIGHT","MAGELIGHT","RADIANT_MAGELIGHT","CAMOUFLAGED_HUNTER","EXPERT_HUNTER","EVIL_HUNTER","LOTUS_BLOSSOM"}, "Spell critical support" },
    { "MAJOR_SAVAGERY", "Major Savagery", "BUFF", {"INNER_LIGHT","MAGELIGHT","RADIANT_MAGELIGHT","CAMOUFLAGED_HUNTER","EXPERT_HUNTER","EVIL_HUNTER","LOTUS_BLOSSOM"}, "Weapon critical support" },
    { "MAJOR_EXPEDITION", "Major Expedition", "BUFF", {"RACE_AGAINST_TIME","ACCELERATE","CHANNELED_ACCELERATION","RAPID_MANEUVER","CHARGING_MANEUVER","RETREATING_MANEUVER","BOUNDLESS_STORM","DOUBLE_TAKE","REFRESHING_PATH","TWISTING_PATH"}, "Movement support" },
    { "MINOR_EXPEDITION", "Minor Expedition", "BUFF", {"HURRICANE","CHARGING_MANEUVER"}, "Movement support" },
    { "MAJOR_PROTECTION", "Major Protection", "BUFF", {"BARRIER","REVIVING_BARRIER","REPLENISHING_BARRIER","REVEALING_FLARE","BLINDING_FLARE","LINGERING_FLARE","SLEET_STORM","NORTHERN_STORM","PERMAFROST","RITE_OF_PASSAGE","REMEMBRANCE","PRACTICED_INCANTATION","BOLSTERING_DARKNESS","VEIL_OF_BLADES","CONSUMING_DARKNESS","DEADEN_PAIN","ROUSING_ROAR"}, "Defensive support" },
    { "MINOR_PROTECTION", "Minor Protection", "BUFF", {"RUNE_GUARD_OF_FREEDOM","RUNIC_DEFENSE","AGONY_TOTEM","REMOTE_TOTEM","DARK_CLOAK","ICE_FORTRESS","CIRCLE_OF_PROTECTION","TURN_EVIL","RING_OF_PRESERVATION","TEMPORAL_GUARD"}, "Defensive support" },
    { "MAJOR_HEROISM", "Major Heroism", "BUFF", {"DRAKES_RUSH","SHIMMERING_SHIELD","ROUSING_ROAR"}, "Ultimate generation" },
    { "MINOR_HEROISM", "Minor Heroism", "BUFF", {"HEROIC_SLASH"}, "Ultimate generation" },
    { "MINOR_INTELLECT", "Minor Intellect", "BUFF", {"ARCANISTS_DOMAIN","ZENAS_EMPOWERING_DISC","RECONSTRUCTIVE_DOMAIN","ENCHANTED_GROWTH","RESTORING_AURA","RADIANT_AURA","EMPOWERED_WARD"}, "Magicka recovery support" },
    { "MINOR_ENDURANCE", "Minor Endurance", "BUFF", {"ARCANISTS_DOMAIN","ZENAS_EMPOWERING_DISC","RECONSTRUCTIVE_DOMAIN","ENCHANTED_GROWTH","RESTORING_AURA","RADIANT_AURA","CIRCLE_OF_PROTECTION","TURN_EVIL","RING_OF_PRESERVATION"}, "Stamina recovery support" },
    { "MINOR_FORTITUDE", "Minor Fortitude", "BUFF", {"ARCANISTS_DOMAIN","ZENAS_EMPOWERING_DISC","RECONSTRUCTIVE_DOMAIN","RESTORING_AURA","RADIANT_AURA"}, "Health recovery support" },
    { "MINOR_VITALITY", "Minor Vitality", "BUFF", {"OZEZAN_THE_INFERNO","MYSTIC_GUARD"}, "Healing received support" },
    { "MAJOR_VITALITY", "Major Vitality", "BUFF", {"SOUL_SIPHON","RESTRAINING_PRISON","BONE_SURGE"}, "Healing received support" },
    { "POWERFUL_ASSAULT", "Powerful Assault", "BUFF", {"POWERFUL_ASSAULT_SET"}, "Group weapon and spell damage" },

    -- Debuffs and status effects
    { "MAJOR_VULNERABILITY", "Major Vulnerability", "DEBUFF", {"GLACIAL_COLOSSUS","FROZEN_COLOSSUS","PESTILENT_COLOSSUS","TURNING_TIDE","ARCHDRUID_DEVYRIC"}, "Increases damage taken" },
    { "MINOR_VULNERABILITY", "Minor Vulnerability", "DEBUFF", {"FETCHER_INFECTION","GROWING_SWARM","RUNE_OF_THE_COLORLESS_POOL","LOTUS_FAN","TELEPORT_STRIKE","CONCUSSION"}, "Increases damage taken" },
    { "MAJOR_BRITTLE", "Major Brittle", "DEBUFF", {"HYPOTHERMIA","NUNATAK"}, "Increases critical damage taken" },
    { "MINOR_BRITTLE", "Minor Brittle", "DEBUFF", {"CHILLED_FROST_SUPPORT"}, "Critical damage taken support" },
    { "MAJOR_BREACH", "Major Breach", "DEBUFF", {"PIERCE_ARMOR","PUNCTURE","RANSACK","ELEMENTAL_SUSCEPTIBILITY","WEAKNESS_TO_ELEMENTS","ELEMENTAL_DRAIN","RAZOR_CALTROPS","NOXIOUS_BREATH","REAPERS_MARK","MARK_TARGET","PIERCING_MARK","DEEP_FISSURE","SUBTERRANEAN_ASSAULT","UNNERVING_BONEYARD","DEAFENING_ROAR"}, "Resistance reduction" },
    { "MINOR_BREACH", "Minor Breach", "DEBUFF", {"PIERCE_ARMOR","POWER_OF_THE_LIGHT","DEEP_FISSURE","SUBTERRANEAN_ASSAULT"}, "Resistance reduction" },
    { "CRUSHER", "Crusher", "DEBUFF", {"CRUSHER_ENCHANTMENT"}, "Resistance reduction" },
    { "MAJOR_MAIM", "Major Maim", "DEBUFF", {"NOVA","SOLAR_PRISON","SOLAR_DISTURBANCE","FROZEN_DEVICE"}, "Enemy damage reduction" },
    { "MINOR_MAIM", "Minor Maim", "DEBUFF", {"CHOKING_TALONS","LOW_SLASH","HEROIC_SLASH","DEEP_SLASH","GRAVE_GRASP","EMPOWERING_GRASP","GHOSTLY_EMBRACE"}, "Enemy damage reduction" },
    { "MAJOR_COWARDICE", "Major Cowardice", "DEBUFF", {}, "Enemy weapon and spell damage reduction" },
    { "MINOR_COWARDICE", "Minor Cowardice", "DEBUFF", {"POWER_EXTRACTION","VYKOSA"}, "Enemy weapon and spell damage reduction" },
    { "MAJOR_DEFILE", "Major Defile", "DEBUFF", {"DARK_FLARE","CORRUPTING_POLLEN","REVERBERATING_BASH","SHIFTING_STANDARD"}, "Healing reduction" },
    { "MINOR_DEFILE", "Minor Defile", "DEBUFF", {}, "Healing reduction" },
    { "MINOR_MAGICKASTEAL", "Minor Magickasteal", "DEBUFF", {"ELEMENTAL_DRAIN","RADIANT_AURA","SIPHON_SPIRIT"}, "Magicka sustain support" },
    { "MINOR_LIFESTEAL", "Minor Lifesteal", "DEBUFF", {"BLOOD_ALTAR","OVERFLOWING_ALTAR","SANGUINE_ALTAR","FORCE_SIPHON","SIPHON_SPIRIT","QUICK_SIPHON"}, "Healing sustain support" },
    { "OFF_BALANCE", "Off Balance", "DEBUFF", {"DIZZYING_SWING","LIGHTNING_WALL_CONCUSSION","FEROCIOUS_ROAR_WEREWOLF"}, "Off Balance interactions" },
    { "CHILLED", "Chilled", "DEBUFF", {"FROST_DAMAGE","ELEMENTAL_SUSCEPTIBILITY","GRIPPING_SHARDS","ARCTIC_BLAST","IMPALING_SHARDS"}, "Frost status effect" },
    { "CONCUSSION", "Concussion", "DEBUFF", {"SHOCK_DAMAGE","ELEMENTAL_SUSCEPTIBILITY"}, "Shock status effect" },
    { "BURNING", "Burning", "DEBUFF", {"FLAME_DAMAGE","ELEMENTAL_SUSCEPTIBILITY"}, "Flame status effect" },
    { "POISONED", "Poisoned", "DEBUFF", {"POISON_DAMAGE"}, "Poison status effect" },
    { "DISEASED", "Diseased", "DEBUFF", {"DISEASE_DAMAGE"}, "Disease status effect" },
    { "ZEN_DAMAGE_TAKEN", "Touch of Z'en", "DEBUFF", {"ZENS_REDRESS"}, "Increases target damage taken based on the provider's active damage-over-time effects" },
    { "ALKOSH_RESISTANCE_REDUCTION", "Roar of Alkosh", "DEBUFF", {"ROAR_OF_ALKOSH"}, "Reduces enemy resistances after the provider activates a synergy" },
    { "MORAG_TONG_AMPLIFICATION", "Morag Tong", "DEBUFF", {"THE_MORAG_TONG"}, "Increases Poison and Disease damage taken" },
    { "ELEMENTAL_CATALYST_AMPLIFICATION", "Elemental Catalyst", "DEBUFF", {"ELEMENTAL_CATALYST"}, "Increases critical damage taken through elemental weakness stacks" },
    { "MARTIAL_KNOWLEDGE_AMPLIFICATION", "Martial Knowledge", "DEBUFF", {"WAY_OF_MARTIAL_KNOWLEDGE"}, "Increases damage taken while the provider meets the stamina condition" },
    { "HEMORRHAGING", "Hemorrhaging", "DEBUFF", {"BLEED_DAMAGE"}, "Bleed status effect" },
    { "SUNDERED", "Sundered", "DEBUFF", {"PHYSICAL_DAMAGE"}, "Physical status effect" },
    { "OVERCHARGED", "Overcharged", "DEBUFF", {"MAGIC_DAMAGE"}, "Magic status effect" },

    -- Other responsibilities
    { "ULTIMATE_RESTORE", "Ultimate Restore", "OTHER", {"PILLAGERS_PROFIT","ARKASIS_GENIUS","REPLENISHING_BARRIER","NECROTIC_POTENCY","BITTER_HARVEST","EXHILARATING_DRAIN","CRITICAL_MOTIVATION","MISSIONARY_OF_LIGHT","HOLD_THE_LINE"}, "Ultimate recovery" },
    { "DEBUFF_EXTENSION", "Debuff Extension", "OTHER", {"NAZARAY"}, "Extends eligible enemy debuffs" },
    { "BUFF_EXTENSION", "Buff Extension", "OTHER", {"JORVULDS_GUIDANCE"}, "Extends eligible buffs" },
    { "RESOURCE_RESTORE", "Resource Restore", "OTHER", {"SYMPHONY_OF_BLADES","ENERGY_ORB","MYSTIC_ORB","NECROTIC_ORB","NATURES_BOUNTY","CONSERVATION_OF_ENERGY","ABSORB_STAMINA_ENCHANTMENT","ABSORB_MAGICKA_ENCHANTMENT"}, "Group sustain" },
    { "GROUP_SHIELDING", "Group Shielding", "OTHER", {"BARRIER","REVIVING_BARRIER","REPLENISHING_BARRIER","OBSIDIAN_SHIELD","IGNEOUS_SHIELD","FRAGMENTED_SHIELD","IMPERIOUS_RUNEWARD","CHAKRAM_SHIELDS","TIDAL_CHAKRAM","MAGMA_SHELL","BONE_SURGE"}, "Group damage shields" },
    { "CLEANSE", "Cleanse", "OTHER", {"PURGE","EFFICIENT_PURGE","CLEANSE_SKILL","CLEANSING_RITUAL","EXTENDED_RITUAL","RITUAL_OF_RETRIBUTION"}, "Negative effect removal" },
    { "PULL_STACK", "Pull and Stack", "OTHER", {"SILVER_LEASH","FIERY_GRIP","UNRELENTING_GRIP","BECKONING_ARMOR","FROZEN_DEVICE"}, "Enemy positioning" },
    { "CROWD_CONTROL", "Crowd Control", "OTHER", {"DARK_TALONS","BURNING_TALONS","CHOKING_TALONS","MASS_HYSTERIA","ENCAGE","STREAK","TIME_STOP","BORROWED_TIME","TIME_FREEZE"}, "Enemy control" },
    { "SYNERGY_PROVIDER", "Synergy Provider", "OTHER", {"SOLAR_PRISON","BONE_SURGE","ENERGY_ORB","MYSTIC_ORB","NECROTIC_ORB","BUDDING_SEEDS","HEALING_SEED","LIGHTNING_SPLASH"}, "Group synergy support" },
    { "DAMAGE_AMPLIFICATION", "Damage Amplification", "OTHER", {"SPAULDER_OF_RUIN","ENCRATIS_BEHEMOTH","ILLUMINARY_OF_BRAVERY"}, "Non-standard group damage support" },
    { "RESISTANCE_REDUCTION", "Resistance Reduction", "OTHER", {"CRIMSON_OATH","TREMORSCALE","CRUSHER_ENCHANTMENT"}, "Additional resistance reduction" },
    { "DEFENSIVE_RAID_BUFF", "Defensive Raid Buff", "OTHER", {"PEARLESCENT_WARD"}, "Raid defensive support" },

    -- Coordinated ultimate families
    { "ULT_WARHORN", "Warhorn", "OTHER", {"AGGRESSIVE_HORN","WAR_HORN","STURDY_HORN"}, "Warhorn rotation" },
    { "ULT_BARRIER", "Barrier", "OTHER", {"BARRIER","REVIVING_BARRIER","REPLENISHING_BARRIER"}, "Barrier rotation" },
    { "ULT_COLOSSUS", "Colossus", "OTHER", {"GLACIAL_COLOSSUS","FROZEN_COLOSSUS","PESTILENT_COLOSSUS"}, "Colossus rotation" },
    { "ULT_DAMAGE", "Damage Ultimate", "OTHER", {"ELEMENTAL_RAGE","EYE_OF_THE_STORM","ELEMENTAL_STORM","METEOR","ICE_COMET","SHOOTING_STAR","STANDARD_OF_MIGHT","RAPID_FIRE","TOXIC_BARRAGE","BALLISTA","DAWNBREAKER","SOUL_STRIKE"}, "Damage ultimate assignment" },
}

for _, entry in ipairs(effects) do
    R:Register("EFFECTS", entry[1], {
        name = entry[2], effectType = entry[3], providers = entry[4],
        whyItMatters = entry[5], tracked = true, displayOrder = "ALPHABETICAL",
    })
end

-- Dashboard presentation is deliberately separate from effect semantics.
-- TIMER rows represent one active duration on a target or raid window.
-- COUNT rows represent how many group members currently have the effect.
local timerEffects = {
    MAJOR_FORCE=true, MAJOR_SLAYER=true, MAJOR_COURAGE=true, MAJOR_MENDING=true, MAJOR_BERSERK=true,
    MAJOR_HEROISM=true, MAJOR_PROTECTION=true, MINOR_FORCE=true,
    POWERFUL_ASSAULT=true,
    MAJOR_VULNERABILITY=true, MINOR_VULNERABILITY=true, MAJOR_BRITTLE=true,
    MINOR_BRITTLE=true, MAJOR_BREACH=true, MINOR_BREACH=true, CRUSHER=true,
    MAJOR_MAIM=true, MINOR_MAIM=true, MAJOR_COWARDICE=true,
    MINOR_COWARDICE=true, MAJOR_DEFILE=true, MINOR_DEFILE=true,
    MINOR_MAGICKASTEAL=true, MINOR_LIFESTEAL=true, OFF_BALANCE=true,
    CHILLED=true, CONCUSSION=true, BURNING=true, POISONED=true,
    DISEASED=true, HEMORRHAGING=true, SUNDERED=true, OVERCHARGED=true,
    ALKOSH_RESISTANCE_REDUCTION=true,
}
local defaultTracked = {
    MAJOR_FORCE=true, MAJOR_SLAYER=true, MAJOR_COURAGE=true, MAJOR_MENDING=true, MINOR_COURAGE=true,
    POWERFUL_ASSAULT=true, MAJOR_RESOLVE=true, MINOR_RESOLVE=true,
    MINOR_BERSERK=true, MAJOR_VULNERABILITY=true, MAJOR_BRITTLE=true,
    MINOR_BRITTLE=true, CRUSHER=true, MAJOR_BREACH=true, MINOR_BREACH=true,
    MINOR_VULNERABILITY=true, MINOR_COWARDICE=true, OFF_BALANCE=true,
    ALKOSH_RESISTANCE_REDUCTION=true,
}
for _, effect in ipairs(R:GetAll("EFFECTS") or {}) do
    effect.dashboardMode = timerEffects[effect.key] and "TIMER" or "COUNT"
    effect.defaultTracked = defaultTracked[effect.key] == true
    effect.showMissingPlayers = effect.key == "MAJOR_SLAYER" or effect.key == "POWERFUL_ASSAULT"
    effect.missingPlayerWindow = effect.showMissingPlayers and 5 or 0
end

R:RegisterAlias("EFFECTS", "HEROISM", "MAJOR_HEROISM")
