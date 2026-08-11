local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- DATABASE (DEFINE NEW SKILLS HERE FOR PROCS LIKE VESTMENT OF OLORIME)
-- PLEASE ALSO SEND ME A MSG (INGAME, DISCORD ETC. SO I CAN ALSO ADD THEM)
----------------------------------------------------------------------------------------------------
CC.SkillData = {

    -- TEMPLAR
    [22262]  = { name = "Extended Ritual", type = 0, offsetPlayer = 0, maxRange = 0, width = 24, height = 24, durationSec = 24, offsetOlorime = 0, },

    -- FIGHTERS GUILD
    [40169]  = { name = "Ring of Preservation", type = 0, offsetPlayer = 0, maxRange = 0, width = 10, height = 10, durationSec = 10, offsetOlorime = 0, },

    -- NECROMANCER
    [115252] = { name = "Boneyard",           type = 1, offsetPlayer = 0, maxRange = 28, width = 12, height = 12, durationSec = 10, offsetOlorime = 0, },
    [117805] = { name = "Unnerving Boneyard", type = 1, offsetPlayer = 0, maxRange = 28, width = 12, height = 12, durationSec = 10, offsetOlorime = 0, },
    [117850] = { name = "Avid Boneyard",      type = 1, offsetPlayer = 0, maxRange = 28, width = 12, height = 12, durationSec = 10, offsetOlorime = 0, },

    -- SUPPORT
    [61489]  = { name = "Revealing Flare", type = 1, offsetPlayer = 0, maxRange = 28, width = 20, height = 20, durationSec = 5, offsetOlorime = 0, },
    [61519]  = { name = "Lingering Flare", type = 1, offsetPlayer = 0, maxRange = 28, width = 20, height = 20, durationSec = 10, offsetOlorime = 0, },
    [61524]  = { name = "Blinding Flare",  type = 1, offsetPlayer = 0, maxRange = 28, width = 20, height = 20, durationSec = 10, offsetOlorime = 0, },

    -- SCRIBING
    [29059]  = { name = "Hearthfire",      type = 1, offsetPlayer = 0, maxRange = 22, width = 16, height = 16, durationSec = 15, offsetOlorime = 0, },
    [20779]  = { name = "Fire Keeper",     type = 1, offsetPlayer = 0, maxRange = 22, width = 16, height = 16, durationSec = 15, offsetOlorime = 0, },
    [32710]  = { name = "Hearth and Home", type = 1, offsetPlayer = 0, maxRange = 22, width = 16, height = 16, durationSec = 15, offsetOlorime = 0, },

    -- UNDAUNTED WEBS
    [39425]  = { name = "Trapping Webs", type = 1, offsetPlayer = 0, maxRange = 28, width = 8, height = 8, durationSec = 10, offsetOlorime = 0, },
    [41990]  = { name = "Shadow Silk",   type = 1, offsetPlayer = 0, maxRange = 28, width = 8, height = 8, durationSec = 10, offsetOlorime = 0, },
    [42012]  = { name = "Tangling Webs", type = 1, offsetPlayer = 0, maxRange = 28, width = 8, height = 8, durationSec = 10, offsetOlorime = 0, },

    -- TRAP BEAST
    [35750]  = { name = "Trap Beast",             type = 0, offsetPlayer = 1.5, maxRange = 0,  width = 5, height = 5, durationSec = 20, offsetOlorime = 2.5, },
    [40382]  = { name = "Barbed Trap",            type = 0, offsetPlayer = 1.5, maxRange = 0,  width = 5, height = 5, durationSec = 20, offsetOlorime = 2.5, },
    [40372]  = { name = "Lightweight Beast Trap", type = 1, offsetPlayer = 0,   maxRange = 28, width = 5, height = 5, durationSec = 20, offsetOlorime = 0,   },

    -- RESTORATION STAFF
    [28385]  = { name = "Grand Healing",       type = 1, offsetPlayer = 0, maxRange = 28, width = 16, height = 16, durationSec = 10, offsetOlorime = 0, },
    [40058]  = { name = "Illustrious Healing", type = 1, offsetPlayer = 0, maxRange = 28, width = 16, height = 16, durationSec = 15, offsetOlorime = 0, },
    [40060]  = { name = "Healing Springs",     type = 1, offsetPlayer = 0, maxRange = 28, width = 16, height = 16, durationSec = 10, offsetOlorime = 0, },

    -- MAGES GUILD
    [40465]  = { name = "Scalding Rune", type = 1, offsetPlayer = 0, maxRange = 28, width = 6, height = 6, durationSec = 20, offsetOlorime = 0, },

    -- WARDEN
    [86169]  = { name = "Winter's Revenge", type = 1, offsetPlayer = 0, maxRange = 28, width = 12, height = 12, durationSec = 12, offsetOlorime = 0, },
    [86165]  = { name = "Gripping Shards",  type = 0, offsetPlayer = 0, maxRange = 0,  width = 12, height = 12, durationSec = 12, offsetOlorime = 0, },
    [86179]  = { name = "Frozen Device",    type = 1, offsetPlayer = 0, maxRange = 22, width = 10, height = 10, durationSec = 15, offsetOlorime = 0, },

    -- UNDAUNTED ALTAR
    [39489]  = { name = "Blood Altar",       type = 0, offsetPlayer = 1.5, maxRange = 0, width = 56, height = 56, durationSec = 30, offsetOlorime = 1.5, },
    [41967]  = { name = "Sanguine Altar",    type = 0, offsetPlayer = 1.5, maxRange = 0, width = 56, height = 56, durationSec = 40, offsetOlorime = 1.5, },
    [41958]  = { name = "Overflowing Altar", type = 0, offsetPlayer = 1.5, maxRange = 0, width = 56, height = 56, durationSec = 30, offsetOlorime = 1.5, },

    -- SORCERER
    [23200]  = { name = "Liquid Lightning", type = 1, offsetPlayer = 0, maxRange = 28, width = 16, height = 16, durationSec = 10, offsetOlorime = 0, },
    [23205]  = { name = "Lightning Flood",  type = 1, offsetPlayer = 0, maxRange = 28, width = 16, height = 16, durationSec = 10, offsetOlorime = 0, },

    [38791]  = { name = "Stampede", type = 0, offsetPlayer = 5, maxRange = 0, width = 10, height = 10, durationSec = 15, offsetOlorime = 5, },

    -- OTHER ABILITYS
    -- [28798]  = { name = "Frost Impulse", type = 0, offsetPlayer = 0, maxRange = 0,  width = 12, height = 12, durationSec = 6, offsetOlorime = nil, },
    -- [39146]  = { name = "Frost Ring",    type = 1, offsetPlayer = 0, maxRange = 28, width = 12, height = 12, durationSec = 6, offsetOlorime = nil, },
    -- [39163]  = { name = "Frost Pulsar",  type = 0, offsetPlayer = 0, maxRange = 0,  width = 12, height = 12, durationSec = 6, offsetOlorime = nil, },

    -- DRAGONKNIGHT TALONS
    -- [20245]  = { name = "Dark Talons",    type = 0, offsetPlayer = 0, maxRange = 0, width = 12, height = 12, durationSec = 4, offsetOlorime = nil, },
    -- [20252]  = { name = "Burning Talons", type = 0, offsetPlayer = 0, maxRange = 0, width = 12, height = 12, durationSec = 4, offsetOlorime = nil, },
    -- [20251]  = { name = "Choking Talons", type = 0, offsetPlayer = 0, maxRange = 0, width = 12, height = 12, durationSec = 4, offsetOlorime = nil, },
}

----------------------------------------------------------------------------------------------------
-- IDS OF CURRENT TRIALS - NEEDED FOR SLAYER ASSISTANT, ARKASIS ETC
----------------------------------------------------------------------------------------------------
CC.TrialZones = {
    [636]  = "Hel Ra Citadel",
    [638]  = "Aetherian Archive",
    [639]  = "Sanctum Ophidia",
    [725]  = "Maw of Lorkhaj",
    [975]  = "Halls of Fabrication",
    [1000] = "Asylum Sanctorium",
    [1051] = "Cloudrest",
    [1121] = "Sunspire",
    [1196] = "Kyne's Aegis",
    [1263] = "Rockgrove",
    [1344] = "Dreadsail Reef",
    [1427] = "Sanity's Edge",
    [1478] = "Lucent Citadel",
    [1548] = "Ossein Cage",
    [1559] = "Night Market",
    [1565] = "Opulent Ordeal",
}

----------------------------------------------------------------------------------------------------
-- ZONE MAP
----------------------------------------------------------------------------------------------------
CC.ZoneMap = {
    [0]  = 0,    -- Receiver Zone
    [1]  = 1,    -- Sender Zone
    [2]  = 636,  -- Hel Ra Citadel
    [3]  = 638,  -- Aetherian Archive
    [4]  = 639,  -- Sanctum Ophidia
    [5]  = 725,  -- Maw of Lorkhaj
    [6]  = 975,  -- Halls of Fabrication
    [7]  = 1000, -- Asylum Sanctorium
    [8]  = 1051, -- Cloudrest
    [9]  = 1121, -- Sunspire
    [10] = 1196, -- Kyne's Aegis
    [11] = 1263, -- Rockgrove
    [12] = 1344, -- Dreadsail Reef
    [13] = 1427, -- Sanity's Edge
    [14] = 1478, -- Lucent Citadel
    [15] = 1548, -- Ossein Cage
    [16] = 1559, -- Night Market
    [17] = 1565, -- Opulent Ordeal
}

----------------------------------------------------------------------------------------------------
-- BLACKLIST FOR ABILITY USED EVENT AND THEREFORE LASTCAST
----------------------------------------------------------------------------------------------------
CC.Blacklist = {
    [23604] = { name = "Light Attack (Unarmed)" },
    [18429] = { name = "Heavy Attack (Unarmed)" },
    [16277] = { name = "Light Attack (Ice)" },
    [16261] = { name = "Heavy Attack (Ice)" },
    [16165] = { name = "Light Attack (Inferno)" },
    [15383] = { name = "Heavy Attack (Inferno)" },
    [18350] = { name = "Light Attack (Lightning)" },
    [18396] = { name = "Heavy Attack (Lightning)" },
    [16499] = { name = "Light Attack (Dual Wield)" },
    [16420] = { name = "Heavy Attack (Dual Wield)" },
    [15435] = { name = "Light Attack (One Handed)" },
    [15279] = { name = "Heavy Attack (One Handed)" },
    [16037] = { name = "Light Attack (Two Handed)" },
    [16041] = { name = "Heavy Attack (Two Handed)" },
    [16145] = { name = "Light Attack (Restoration)" },
    [16212] = { name = "Heavy Attack (Restoration)" },
    [16688] = { name = "Light Attack (Bow)" },
    [16691] = { name = "Heavy Attack (Bow)" },
}

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- WARNING: DO NOT TOUCH!!! !!1!ELEVEN!!!11!
-- SERIOUSLY.. DO NOT TOUCH!!
--
-- THIS ARE BROADCASTED LOOKUP TABLE IDS. IF YOU MESS WITH THESE.. EVERYTHING GETS FKED UP! 4 REAL.
-- IT'S EVEN POSSIBLE THAT THERE IS SERIOUS HARM.. TO DOLPHINS.. AND KITTENS.
-- PLEASE.. PLEASE, WITH SUGAR ON TOP! NEVER EVER CHANGE ANYTHING HERE.
-- PS: IF YOU DO.. I WILL KNOW. AND I WILL FIND YOU.
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- PS: DON'T CHANGE ANYTHING. IN CASE YOU FORGOT.
----------------------------------------------------------------------------------------------------
CC.LUT = {
    ----------------------------------------------------------------------------------------------------
    -- 0 .. 511 INTERNAL
    ----------------------------------------------------------------------------------------------------
    -- 0 .. 15 BROADCAST PING FOR SYNC
    SYNC = {
        PING_REPLY     = 0,
        PING_REQUEST   = 1,
    },

    ----------------------------------------------------------------------------------------------------
    -- 16 .. 31 POINTING AND DRAWING
    DRAW_SHAPE = {
        CIRCLE    = 16,
        RECTANGLE = 17,
        TRIANGLE  = 18,
        LINE_A    = 19,
        LINE_B    = 20,
        LINE_C    = 21,
    },

    -- 32 .. 47 MODULE: POINTER
    POINTER = {
        PLACE = 32,
    },

    -- 48 .. 63 MODULE: RAIDLEAD TOOLS
    RAIDLEAD_TOOLS = {
        BREAK_TIMER    = 48,
        PULL_TIMER     = 49,
        ULTIPULL_TIMER = 50,
        WIPE_PLEASE    = 51,
        EXIT_INSTANCE  = 52,
        PORT_IN_PLEASE = 53,
        PORT_TO_LEADER = 54,
        VOTE_START     = 55,
        VOTE_REPLY     = 56,
    },

    -- 64 .. 79 MODULE: SLAYER ASSISTANT
    SLAYER_ASSISTANT = {
        SLAYER_TRIGGER      = 64,
        ASSIGNMENT_REQUEST  = 65,
        ASSIGNMENT_TARGETED = 66,
    },

    -- 80 .. 95 MODULE: ARKASIS ASSISTANT
    ARKASIS_ASSISTANT = {
        ARKASIS_TRIGGER     = 80,
        ASSIGNMENT_REQUEST  = 81,
        ASSIGNMENT_TARGETED = 82,
    },

    ----------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------
    -- 512 .. 768  ABILITYS
    ----------------------------------------------------------------------------------------------------
    -- 512 .. 527 DRAGONKNIGHT
    DRAGONKNIGHT = {
        DRAGONKNIGHT_STANDARD = 512,
        STANDARD_OF_MIGHT     = 513,
    },
    -- 528 .. 543 SORCERER
    SORCERER = {
        STORM_ATRONACH         = 528,
        GREATER_STORM_ATRONACH = 529,
        CHARGED_ATRONACH       = 530,
    },
    -- 544 .. 559 NIGHTBLADE
    -- 560 .. 575 TEMPLAR
    -- 576 .. 591 WARDEN
    WARDEN = {
        HEALING_SEED      = 576,
        CORRUPTING_POLLEN = 577,
        BUDDING_SEEDS     = 578,
    },

    -- 592 .. 607 NECROMANCER
    NECROMANCER = {
        FROZEN_COLOSSUS    = 592,
        PESTILENT_COLOSSUS = 593,
        GLACIAL_COLOSSUS   = 594,
    },
    -- 608 .. 623 ARCANIST
    ARCANIST = {
        VITALIZING_GLYPHIC   = 608,
        GLYPHIC_OF_THE_TIDED = 609,
        RESONATING_GLYPHIC   = 610,
    },
    -- 624 .. 639
    -- 640 .. 655
    -- 656 .. 671
    -- 672 .. 687
    -- 688 .. 703
    -- 704 .. 719
    -- 720 .. 735
    -- 736 .. 751 ASSAULT
    -- 752 .. 767 SUPPORT
    SUPPORT = {
        BARRIER              = 752,
        REVIVING_BARRIER     = 753,
        REPLENISHING_BARRIER = 754,
    },

    ----------------------------------------------------------------------------------------------------
    -- 768 .. 895  SET PROCS
    ----------------------------------------------------------------------------------------------------
    -- 768 .. 831 SET BUFFS
    VESTMENT_OF_OLORIME = {
        EFFECT_GAINED = 768,
    },
    -- 832 .. 895 SET DEBUFFS
    ROAR_OF_ALKOSH = {
        EFFECT_GAINED = 832,
    },

    ----------------------------------------------------------------------------------------------------
    -- 896 .. 1023 MECHANICS
    ----------------------------------------------------------------------------------------------------
}