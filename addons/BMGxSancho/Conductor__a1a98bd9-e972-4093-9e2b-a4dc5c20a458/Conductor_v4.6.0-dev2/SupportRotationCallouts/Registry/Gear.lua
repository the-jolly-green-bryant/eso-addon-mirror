local R = Conductor.Registry

-- Update 50 curated role catalog used by Raid Setup -> Team Review.
-- These entries intentionally separate role visibility from provider logic.
-- Unknown IDs remain explicitly unverified rather than being guessed.
local VERIFIED_PATCH = 50
local VERIFIED_DATE = "2026-07"
local META_SOURCE = "User-provided Update 50 ESO Logs / Community Meta research"

local ARENA_CANONICAL = {
    MASTERS_SWORD_AND_SHIELD="Puncturing Remedy", PERFECTED_MASTERS_SWORD_AND_SHIELD="Perfected Puncturing Remedy",
    DRAGONSTAR_SWORD_AND_SHIELD="Puncturing Remedy", PERFECTED_DRAGONSTAR_SWORD_AND_SHIELD="Perfected Puncturing Remedy",
    MASTERS_RESTORATION_STAFF="Grand Rejuvenation", PERFECTED_MASTERS_RESTORATION_STAFF="Perfected Grand Rejuvenation",
    DRAGONSTAR_RESTORATION_STAFF="Grand Rejuvenation", PERFECTED_DRAGONSTAR_RESTORATION_STAFF="Perfected Grand Rejuvenation",
    MAELSTROM_RESTORATION_STAFF="Precise Regeneration", PERFECTED_MAELSTROM_RESTORATION_STAFF="Perfected Precise Regeneration",
    MAELSTROM_INFERNO_STAFF="Crushing Wall", PERFECTED_MAELSTROM_INFERNO_STAFF="Perfected Crushing Wall",
    MAELSTROM_LIGHTNING_STAFF="Crushing Wall", PERFECTED_MAELSTROM_LIGHTNING_STAFF="Perfected Crushing Wall",
    MAELSTROM_GREATSWORD="Merciless Charge", PERFECTED_MAELSTROM_GREATSWORD="Perfected Merciless Charge",
    MAELSTROM_BOW="Thunderous Volley", PERFECTED_MAELSTROM_BOW="Perfected Thunderous Volley",
    BLACKROSE_DUAL_WIELD="Spectral Cloak", PERFECTED_BLACKROSE_DUAL_WIELD="Perfected Spectral Cloak",
    BLACKROSE_RESTORATION_STAFF="Mender's Ward", PERFECTED_BLACKROSE_RESTORATION_STAFF="Perfected Mender's Ward",
    ASYLUM_INFERNO_STAFF="Concentrated Force", PERFECTED_ASYLUM_INFERNO_STAFF="Perfected Concentrated Force",
    ASYLUM_GREATSWORD="Disciplined Slash", PERFECTED_ASYLUM_GREATSWORD="Perfected Disciplined Slash",
    ASYLUM_RESTORATION_STAFF="Timeless Blessing", PERFECTED_ASYLUM_RESTORATION_STAFF="Perfected Timeless Blessing",
    VATESHRAN_ICE_STAFF="Wrath of Elements", PERFECTED_VATESHRAN_ICE_STAFF="Perfected Wrath of Elements",
    VATESHRAN_GREATSWORD="Frenzied Momentum", PERFECTED_VATESHRAN_GREATSWORD="Perfected Frenzied Momentum",
    VATESHRAN_BOW="Point-Blank Snipe", PERFECTED_VATESHRAN_BOW="Perfected Point-Blank Snipe",
    VOID_BASH="Void Bash", PERFECTED_VOID_BASH="Perfected Void Bash",
}

local entries = {
    -- Tank five-piece sets
    {"PEARLESCENT_WARD","Pearlescent Ward",{"DEFENSIVE_RAID_BUFF"},5,"TRIAL_SET",{"TANK"}},
    {"PERFECTED_PEARLESCENT_WARD","Perfected Pearlescent Ward",{"DEFENSIVE_RAID_BUFF"},5,"TRIAL_SET",{"TANK"}},
    {"TURNING_TIDE","Turning Tide",{"MAJOR_VULNERABILITY"},5,"DUNGEON_SET",{"TANK"}},
    {"CRIMSON_OATH","Crimson Oath's Rive",{"RESISTANCE_REDUCTION"},5,"DUNGEON_SET",{"TANK"}},
    {"LUCENT_ECHO","Lucent Echo",{},5,"TRIAL_SET",{"TANK"}},
    {"PERFECTED_LUCENT_ECHO","Perfected Lucent Echo",{},5,"TRIAL_SET",{"TANK"}},
    {"SAXHLEEL_CHAMPION","Saxhleel Champion",{"MAJOR_FORCE"},5,"TRIAL_SET",{"TANK"}},
    {"PERFECTED_SAXHLEEL_CHAMPION","Perfected Saxhleel Champion",{"MAJOR_FORCE"},5,"TRIAL_SET",{"TANK"}},
    {"WAR_MACHINE","War Machine",{"MAJOR_SLAYER"},5,"TRIAL_SET",{"TANK"}},
    {"PERFECTED_WAR_MACHINE","Perfected War Machine",{"MAJOR_SLAYER"},5,"TRIAL_SET",{"TANK"}},
    {"POWERFUL_ASSAULT_SET","Powerful Assault",{"POWERFUL_ASSAULT"},5,"PVP_SET",{"TANK","HEALER","SUPPORT"}},
    {"DRAKES_RUSH","Drake's Rush",{"MAJOR_HEROISM"},5,"DUNGEON_SET",{"TANK"}},
    {"CLAW_OF_YOLNAHKRIIN","Claw of Yolnahkriin",{"MINOR_COURAGE"},5,"TRIAL_SET",{"TANK"}},
    {"PERFECTED_CLAW_OF_YOLNAHKRIIN","Perfected Claw of Yolnahkriin",{"MINOR_COURAGE"},5,"TRIAL_SET",{"TANK"}},
    {"CRIMSON_TWILIGHT","Crimson Twilight",{},5,"DUNGEON_SET",{"TANK"}},

    -- Healer five-piece sets
    {"PILLAGERS_PROFIT","Pillager's Profit",{"ULTIMATE_RESTORE"},5,"TRIAL_SET",{"HEALER"}},
    {"PERFECTED_PILLAGERS_PROFIT","Perfected Pillager's Profit",{"ULTIMATE_RESTORE"},5,"TRIAL_SET",{"HEALER"}},
    {"ROARING_OPPORTUNIST","Roaring Opportunist",{"MAJOR_SLAYER"},5,"TRIAL_SET",{"HEALER","SUPPORT"}},
    {"PERFECTED_ROARING_OPPORTUNIST","Perfected Roaring Opportunist",{"MAJOR_SLAYER"},5,"TRIAL_SET",{"HEALER","SUPPORT"}},
    {"MASTER_ARCHITECT","Master Architect",{"MAJOR_SLAYER"},5,"TRIAL_SET",{"HEALER"}},
    {"PERFECTED_MASTER_ARCHITECT","Perfected Master Architect",{"MAJOR_SLAYER"},5,"TRIAL_SET",{"HEALER"}},
    {"JORVULDS_GUIDANCE","Jorvuld's Guidance",{"BUFF_EXTENSION"},5,"DUNGEON_SET",{"HEALER"}},
    {"SPELL_POWER_CURE","Spell Power Cure",{"MAJOR_COURAGE"},5,"DUNGEON_SET",{"HEALER"}},
    {"OLORIME","Vestment of Olorime",{"MAJOR_COURAGE"},5,"TRIAL_SET",{"HEALER"}},
    {"PERFECTED_OLORIME","Perfected Vestment of Olorime",{"MAJOR_COURAGE"},5,"TRIAL_SET",{"HEALER"}},
    {"XORYNS_MASTERPIECE","Xoryn's Masterpiece",{},5,"TRIAL_SET",{"HEALER"}},
    {"PERFECTED_XORYNS_MASTERPIECE","Perfected Xoryn's Masterpiece",{},5,"TRIAL_SET",{"HEALER"}},
    {"SERPENTS_DISDAIN","Serpent's Disdain",{},5,"OVERLAND_SET",{"HEALER"}},
    {"HOLLOWFANG_THIRST","Hollowfang Thirst",{"RESOURCE_RESTORE"},5,"DUNGEON_SET",{"HEALER"}},
    {"ZENS_REDRESS","Z'en's Redress",{"ZEN_DAMAGE_TAKEN"},5,"DUNGEON_SET",{"DD","SUPPORT"}},
    {"ROAR_OF_ALKOSH","Roar of Alkosh",{"ALKOSH_RESISTANCE_REDUCTION"},5,"TRIAL_SET",{"TANK","DD","SUPPORT"}},
    {"THE_MORAG_TONG","The Morag Tong",{"MORAG_TONG_AMPLIFICATION"},5,"PVP_SET",{"DD","SUPPORT"}},
    {"ELEMENTAL_CATALYST","Elemental Catalyst",{"ELEMENTAL_CATALYST_AMPLIFICATION"},5,"DUNGEON_SET",{"DD","SUPPORT"}},
    {"WAY_OF_MARTIAL_KNOWLEDGE","Way of Martial Knowledge",{"MARTIAL_KNOWLEDGE_AMPLIFICATION"},5,"OVERLAND_SET",{"DD","SUPPORT"}},

    -- Damage dealer five-piece sets
    {"SLIVERS_OF_THE_NULL_ARCA","Slivers of the Null Arca",{},5,"DAMAGE_SET",{"DD"}},
    {"PERFECTED_SLIVERS_OF_THE_NULL_ARCA","Perfected Slivers of the Null Arca",{},5,"DAMAGE_SET",{"DD"}},
    {"DEADLY_STRIKE","Deadly Strike",{},5,"DAMAGE_SET",{"DD"}},
    {"CORPSEBURSTER","Corpseburster",{},5,"CLASS_SET",{"DD"},"NECROMANCER"},
    {"MECHANICAL_ACUITY","Mechanical Acuity",{},5,"DAMAGE_SET",{"DD"}},
    {"AZUREBLIGHT_REAPER","Azureblight Reaper",{},5,"DAMAGE_SET",{"DD"}},
    {"AEGIS_CALLER","Aegis Caller",{},5,"DAMAGE_SET",{"DD"}},
    {"SUL_XANS_TORMENT","Sul-Xan's Torment",{},5,"DAMAGE_SET",{"DD"}},
    {"PERFECTED_SUL_XANS_TORMENT","Perfected Sul-Xan's Torment",{},5,"DAMAGE_SET",{"DD"}},
    {"TIDE_BORN_WILDSTALKER","Tide-Born Wildstalker",{},5,"DAMAGE_SET",{"DD"}},
    {"ANSUULS_TORMENT","Ansuul's Torment",{},5,"DAMAGE_SET",{"DD"}},
    {"PERFECTED_ANSUULS_TORMENT","Perfected Ansuul's Torment",{},5,"DAMAGE_SET",{"DD"}},
    {"CORAL_RIPTIDE","Coral Riptide",{},5,"DAMAGE_SET",{"DD"}},
    {"PERFECTED_CORAL_RIPTIDE","Perfected Coral Riptide",{},5,"DAMAGE_SET",{"DD"}},
    {"SPATTERING_DISJUNCTION","Spattering Disjunction",{},5,"CLASS_SET",{"DD"},"ARCANIST"},

    -- Additional curated DD entries retained from the prior build
    {"TIDEBORN","Tideborn",{},5,"DAMAGE_SET",{"DD"}},
    {"KAZPIAN","Kazpian",{},5,"DAMAGE_SET",{"DD"}},
    {"KINRAS_WRATH","Kinras's Wrath",{"MINOR_BERSERK"},5,"DAMAGE_SET",{"DD"}},
    {"MEDUSA","Medusa",{"MINOR_FORCE"},5,"DAMAGE_SET",{"DD"}},

    -- Tank mythics
    {"SPAULDER_OF_RUIN","Spaulder of Ruin",{"AURA_OF_PRIDE","WEAPON_SPELL_DAMAGE"},1,"MYTHIC",{"TANK","HEALER","SUPPORT"}},
    {"DEATH_DEALERS_FETE","Death Dealer's Fete",{},1,"MYTHIC",{"TANK","HEALER","DD"}},
    {"TORC_OF_TONAL_CONSTANCY","Torc of Tonal Constancy",{},1,"MYTHIC",{"TANK","HEALER"}},
    {"MARKYN_RING_OF_MAJESTY","Markyn Ring of Majesty",{},1,"MYTHIC",{"TANK","HEALER","DD"}},
    {"SAINT_AND_SEDUCER","Saint and Seducer",{},1,"MYTHIC",{"TANK"}},
    {"RING_OF_THE_WILD_HUNT","Ring of the Wild Hunt",{},1,"MYTHIC",{"TANK","HEALER","DD"}},
    {"SNOW_TREADERS","Snow Treaders",{},1,"MYTHIC",{"TANK","HEALER"}},
    {"MORAS_WHISPERS","Mora's Whispers",{},1,"MYTHIC",{"TANK","HEALER","DD"}},
    {"ESOTERIC_ENVIRONMENT_GREAVES","Esoteric Environment Greaves",{},1,"MYTHIC",{"TANK"}},
    {"CRYPTCANON_VESTMENTS","Cryptcanon Vestments",{"ULTIMATE_RESTORE"},1,"MYTHIC",{"TANK","HEALER","DD"}},

    -- Healer / DD mythics
    {"PEARLS_OF_EHLNOFEY","Pearls of Ehlnofey",{"ULTIMATE_RESTORE"},1,"MYTHIC",{"HEALER"}},
    {"SEA_SERPENTS_COIL","Sea-Serpent's Coil",{"MAJOR_BERSERK"},1,"MYTHIC",{"HEALER","DD"}},
    {"VELOTHI_UR_MAGES_AMULET","Velothi Ur-Mage's Amulet",{},1,"MYTHIC",{"DD"}},
    {"HARPOONERS_WADING_KILT","Harpooner's Wading Kilt",{},1,"MYTHIC",{"DD"}},
    {"RING_OF_THE_PALE_ORDER","Ring of the Pale Order",{},1,"MYTHIC",{"DD"}},
    {"THRASSIAN_STRANGLERS","Thrassian Stranglers",{},1,"MYTHIC",{"DD"}},
    {"HUNTSMANS_WARMASK","Huntsman's Warmask",{},1,"MYTHIC",{"DD"}},
    {"SHATTERED_PATH_SIGNET","Shattered Path Signet",{},1,"MYTHIC",{"DD"}},

    -- Tank arena weapons (regular and perfected variants)
    {"VOID_BASH","Void Bash",{},2,"ARENA_WEAPON",{"TANK"}},
    {"PERFECTED_VOID_BASH","Perfected Void Bash",{},2,"ARENA_WEAPON",{"TANK"}},
    {"MASTERS_SWORD_AND_SHIELD","The Master's Sword and Shield",{},2,"ARENA_WEAPON",{"TANK"}},
    {"PERFECTED_MASTERS_SWORD_AND_SHIELD","Perfected Master's Sword and Shield",{},2,"ARENA_WEAPON",{"TANK"}},
    {"MAELSTROM_ICE_STAFF","Maelstrom Ice Staff",{},2,"ARENA_WEAPON",{"TANK"}},
    {"PERFECTED_MAELSTROM_ICE_STAFF","Perfected Maelstrom Ice Staff",{},2,"ARENA_WEAPON",{"TANK"}},
    {"VATESHRAN_ICE_STAFF","Vateshran Ice Staff",{},2,"ARENA_WEAPON",{"TANK"}},
    {"PERFECTED_VATESHRAN_ICE_STAFF","Perfected Vateshran Ice Staff",{},2,"ARENA_WEAPON",{"TANK"}},
    {"DRAGONSTAR_SWORD_AND_SHIELD","The Master's Sword and Shield",{},2,"ARENA_WEAPON",{"TANK"}},
    {"PERFECTED_DRAGONSTAR_SWORD_AND_SHIELD","Perfected Master's Sword and Shield",{},2,"ARENA_WEAPON",{"TANK"}},
    {"ASYLUM_SWORD_AND_SHIELD","Asylum Sword & Shield",{},2,"ARENA_WEAPON",{"TANK"}},
    {"PERFECTED_ASYLUM_SWORD_AND_SHIELD","Perfected Asylum Sword & Shield",{},2,"ARENA_WEAPON",{"TANK"}},

    -- Healer arena weapons
    {"MASTERS_RESTORATION_STAFF","The Master's Restoration Staff",{},2,"ARENA_WEAPON",{"HEALER"}},
    {"PERFECTED_MASTERS_RESTORATION_STAFF","Perfected Master's Restoration Staff",{},2,"ARENA_WEAPON",{"HEALER"}},
    {"MAELSTROM_RESTORATION_STAFF","The Maelstrom's Restoration Staff",{},2,"ARENA_WEAPON",{"HEALER"}},
    {"PERFECTED_MAELSTROM_RESTORATION_STAFF","Perfected Maelstrom Restoration Staff",{},2,"ARENA_WEAPON",{"HEALER"}},
    {"BLACKROSE_RESTORATION_STAFF","The Blackrose Restoration Staff",{},2,"ARENA_WEAPON",{"HEALER"}},
    {"PERFECTED_BLACKROSE_RESTORATION_STAFF","Perfected The Blackrose Restoration Staff",{},2,"ARENA_WEAPON",{"HEALER"}},
    {"DRAGONSTAR_RESTORATION_STAFF","The Master's Restoration Staff",{},2,"ARENA_WEAPON",{"HEALER"}},
    {"PERFECTED_DRAGONSTAR_RESTORATION_STAFF","Perfected Master's Restoration Staff",{},2,"ARENA_WEAPON",{"HEALER"}},
    {"ASYLUM_RESTORATION_STAFF","The Asylum's Restoration Staff",{},2,"ARENA_WEAPON",{"HEALER"}},
    {"PERFECTED_ASYLUM_RESTORATION_STAFF","Perfected Asylum Restoration Staff",{},2,"ARENA_WEAPON",{"HEALER"}},

    -- Damage dealer arena weapons
    {"MAELSTROM_INFERNO_STAFF","The Maelstrom's Inferno Staff",{},2,"ARENA_WEAPON",{"DD"}},
    {"PERFECTED_MAELSTROM_INFERNO_STAFF","Perfected Maelstrom Inferno Staff",{},2,"ARENA_WEAPON",{"DD"}},
    {"MAELSTROM_GREATSWORD","The Maelstrom's Greatsword",{},2,"ARENA_WEAPON",{"DD"}},
    {"PERFECTED_MAELSTROM_GREATSWORD","Perfected Maelstrom Greatsword",{},2,"ARENA_WEAPON",{"DD"}},
    {"MAELSTROM_BOW","The Maelstrom's Bow",{},2,"ARENA_WEAPON",{"DD"}},
    {"PERFECTED_MAELSTROM_BOW","Perfected Maelstrom Bow",{},2,"ARENA_WEAPON",{"DD"}},
    {"BLACKROSE_DUAL_WIELD","The Blackrose Prison Dual Wield",{},2,"ARENA_WEAPON",{"DD"}},
    {"PERFECTED_BLACKROSE_DUAL_WIELD","Perfected Blackrose Prison Dual Wield",{},2,"ARENA_WEAPON",{"DD"}},
    {"ASYLUM_INFERNO_STAFF","Asylum Inferno Staff",{},2,"ARENA_WEAPON",{"DD"}},
    {"PERFECTED_ASYLUM_INFERNO_STAFF","Perfected Asylum Inferno Staff",{},2,"ARENA_WEAPON",{"DD"}},
    {"ASYLUM_GREATSWORD","Asylum Greatsword",{},2,"ARENA_WEAPON",{"DD"}},
    {"PERFECTED_ASYLUM_GREATSWORD","Perfected Asylum Greatsword",{},2,"ARENA_WEAPON",{"DD"}},
    {"DRAGONSTAR_BOW","The Master's Bow",{},2,"ARENA_WEAPON",{"DD"}},
    {"PERFECTED_DRAGONSTAR_BOW","Perfected Master's Bow",{},2,"ARENA_WEAPON",{"DD"}},
    {"VATESHRAN_GREATSWORD","The Vateshran's Greatsword",{},2,"ARENA_WEAPON",{"DD"}},
    {"PERFECTED_VATESHRAN_GREATSWORD","Perfected Vateshran Greatsword",{},2,"ARENA_WEAPON",{"DD"}},
    {"VATESHRAN_BOW","The Vateshran's Bow",{},2,"ARENA_WEAPON",{"DD"}},
    {"PERFECTED_VATESHRAN_BOW","Perfected Vateshran Bow",{},2,"ARENA_WEAPON",{"DD"}},
    {"MAELSTROM_LIGHTNING_STAFF","The Maelstrom's Lightning Staff",{},2,"ARENA_WEAPON",{"DD"}},
    {"PERFECTED_MAELSTROM_LIGHTNING_STAFF","Perfected Maelstrom Lightning Staff",{},2,"ARENA_WEAPON",{"DD"}},

    -- Passive registry entry retained for capability recognition only.
    {"TRIAL_SET_BONUS","Trial Set Bonus",{"MINOR_SLAYER"},3,"PASSIVE_BONUS",{}},
}

for _, entry in ipairs(entries) do
    R:Register("GEAR", entry[1], {
        name = entry[2], displayName = entry[2], provides = entry[3], piecesRequired = entry[4],
        setCategory = entry[5], roles = entry[6] or {}, classKey = entry[7],
        canonicalSetName = ARENA_CANONICAL[entry[1]],
        combatForm = entry[8],
        setIds = {}, needsIdValidation = true,
        verifiedPatch = VERIFIED_PATCH, lastVerifiedPatch = VERIFIED_PATCH,
        verifiedDate = VERIFIED_DATE, source = META_SOURCE,
        metaStatus = "CURRENT_U50",
    })
end

R:RegisterAlias("GEAR", "POWERFUL_ASSAULT", "POWERFUL_ASSAULT_SET")
R:RegisterAlias("GEAR", "ZEN", "ZENS_REDRESS")
R:RegisterAlias("GEAR", "ZENS", "ZENS_REDRESS")
R:RegisterAlias("GEAR", "ALKOSH", "ROAR_OF_ALKOSH")
R:RegisterAlias("GEAR", "MORAG_TONG", "THE_MORAG_TONG")
R:RegisterAlias("GEAR", "MASTERS_RESTO", "MASTERS_RESTORATION_STAFF")
R:RegisterAlias("GEAR", "GRAND_REJUVENATION", "MASTERS_RESTORATION_STAFF")
R:RegisterAlias("GEAR", "SPAULDER", "SPAULDER_OF_RUIN")
R:RegisterAlias("GEAR", "SPAULDERS", "SPAULDER_OF_RUIN")
R:RegisterAlias("GEAR", "AURA_OF_PRIDE", "SPAULDER_OF_RUIN")
