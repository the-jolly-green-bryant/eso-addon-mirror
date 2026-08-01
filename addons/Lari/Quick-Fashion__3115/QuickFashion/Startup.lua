QF = {}

QF.name = "QuickFashion"
QF.author = "Lari"
QF.addonVersion = "2.3"

QF.SavedVars = {}

QF.Temp = {}

QF.Defaults = {
  accountWide = false,
  FashionPanelTop = nil,
  FashionPanelLeft = nil,
  FavsPanelTop = nil,
  FavsPanelLeft = nil,
  AOPanelTop = nil,
  AOPanelLeft = nil,
  CharacterProfilesLeft = nil,
  CharacterProfilesTop = nil,
  FavPanelWidth = 305,
  FavPanelHeight = 600,
  showQFPanelWithCollections = true,
  showFavsPanelWithCollections = true,
  showAOPanelWithCollections = true,
  Favourites = { 0 },
  migratedFavsToSortedTable = false,
  versionTwoUpdateSent = false,
  FavouritesByType = {
    [2] = {},
    [3] = {},
    [4] = {},
    [9] = {},
    [10] = {},
    [11] = {},
    [12] = {},
    [13] = {},
    [14] = {},
    [15] = {},
    [16] = {},
    [17] = {},
    [18] = {},
  },
  collectibleTab = "favs",
  initAllCollectibleIcons = false,
  OwnedCollectibles = {
    [2] = {},
    [3] = {},
    [4] = {},
    [9] = {},
    [10] = {},
    [11] = {},
    [12] = {},
    [13] = {},
    [14] = {},
    [15] = {},
    [16] = {},
    [17] = {},
    [18] = {},
  },
  numRecentCollectibles = 8,
  RecentCollectibles = {
    [2] = {},
    [3] = {},
    [4] = {},
    [9] = {},
    [10] = {},
    [11] = {},
    [12] = {},
    [13] = {},
    [14] = {},
    [15] = {},
    [16] = {},
    [17] = {},
    [18] = {},
  },
  FilterStates = {
    [0] = true,  -- ALL
    [2] = false,
    [3] = false,
    [4] = false,
    [9] = false,
    [10] = false,
    [11] = false,
    [12] = false,
    [13] = false,
    [14] = false,
    [15] = false,
    [16] = false,
    [17] = false,
    [18] = false,
  },
  categoryLoadOrder = {
    [1] = 10,
    [2] = 4,
    [3] = 13,
    [4] = 14,
    [5] = 15,
    [6] = 16,
    [7] = 17,
    [8] = 18,
    [9] = 9,
    [10] = 11,
    [11] = 12,
    [12] = 2,
    [13] = 3,
  },
  randomizeTable = "All Collectibles",
  RandomizeSetting = {
    ["2"] = true,
    ["3"] = true,
    ["4"] = true,
    ["9"] = true,
    ["10"] = true,
    ["11"] = true,
    ["12"] = false,
    ["13"] = true,
    ["14"] = true,
    ["15"] = true,
    ["16"] = true,
    ["17"] = true,
    ["18"] = true,
    ["Title"] = true,
    ["Outfit"] = false,
  },
  Profiles = {},
  ProfileHotkey = {},
  lastSlottedHatId = nil,
  AutoOutfitter = {
    tab = "ZONES",
    ZoneCategories = {},
    OverlandZones = {},
    Houses = {},
  },
  Armory = {
    Profiles = {},
  },
}

QF.Constants = {
  chatPrefix = "|c7B68EE[Quick|r |c9832FFFashion]|r ",
  COLLECTIBLE_ID_HIDE_HELMET = 5002,
}

QF.Armory = {}

QF.CollectibleTable = {
  [2] = {
    name = "mount",
    header = "Mounts",
    controlSuffix = "Mount",
    texture = "esoui/art/treeicons/gamepad/gp_store_indexicon_mounts.dds",
    bulletTexture = "esoui/art/icons/heraldrycrests_animals_horse_02.dds",
    collectibleSlot = {
      offsetX = "70",
      offsetY = "210",
    },
    filterIcon = {
      offsetX = "220",
      offsetY = "0",
    },
  },
  [3] = {
    name = "non-combat pet",
    header = "Non-Combat Pets",
    controlSuffix = "Pet",
    texture = "esoui/art/treeicons/gamepad/gp_store_indexicon_vanitypets.dds",
    bulletTexture = "/esoui/art/icons/heraldrycrests_animals_chicken.dds",
    collectibleSlot = {
      offsetX = "140",
      offsetY = "210",
    },
    filterIcon = {
      offsetX = "220",
      offsetY = "28",
    },
  },
  [4] = {
    name = "costume",
    header = "Costumes",
    controlSuffix = "Costume",
    texture = "esoui/art/treeicons/gamepad/gp_collectionicon_costumes.dds",
    bulletTexture = "esoui/art/treeicons/gamepad/gp_collectionicon_costumes.dds",
    collectibleSlot = {
      offsetX = "0",
      offsetY = "0",
    },
    filterIcon = {
      offsetX = "45",
      offsetY = "28",
    },
  },
  [9] = {
    name = "personality",
    header = "Personalities",
    controlSuffix = "Personality",
    texture = "esoui/art/treeicons/gamepad/gp_collectionicon_personalities.dds",
    -- bulletTexture = "/esoui/art/icons/heraldrycrests_daedra_sheogorath_01.dds",
    bulletTexture = "esoui/art/treeicons/gamepad/gp_collectionicon_personalities.dds",
    collectibleSlot = {
      offsetX = "210",
      offsetY = "210",
    },
    filterIcon = {
      offsetX = "185",
      offsetY = "0",
    },
  },
  [10] = {
    name = "hat",
    header = "Hats",
    controlSuffix = "Hat",
    texture = "esoui/art/treeicons/gamepad/gp_collectionicon_hats.dds",
    bulletTexture = "esoui/art/treeicons/gamepad/gp_collectionicon_hats.dds",
    collectibleSlot = {
      offsetX = "70",
      offsetY = "0",
    },
    filterIcon = {
      offsetX = "45",
      offsetY = "2",
    },
  },
  [11] = {
    name = "skin",
    header = "Skins",
    controlSuffix = "Skin",
    texture = "esoui/art/treeicons/gamepad/gp_collectionicon_skins.dds",
    bulletTexture = "/esoui/art/icons/skin_sanctifiedsilver.dds",
    collectibleSlot = {
      offsetX = "0",
      offsetY = "210",
    },
    filterIcon = {
      offsetX = "185",
      offsetY = "28",
    },
  },
  [12] = {
    name = "polymorph",
    header = "Polymorphs",
    controlSuffix = "Polymorph",
    texture = "esoui/art/treeicons/gamepad/gp_collectionicon_polymorphs.dds",
    bulletTexture = "/esoui/art/icons/heraldrycrests_daedra_clavicusvile_01.dds",
    collectibleSlot = {
      offsetX = "210",
      offsetY = "280",
    },
    filterIcon = {
      offsetX = "255",
      offsetY = "0",
    },
  },
  [13] = {
    name = "hair style",
    header = "Hair Styles",
    controlSuffix = "HairStyle",
    texture = "esoui/art/treeicons/gamepad/gp_collectionicon_hair.dds",
    bulletTexture = "esoui/art/treeicons/gamepad/gp_collectionicon_hair.dds",
    collectibleSlot = {
      offsetX = "140",
      offsetY = "0",
    },
    filterIcon = {
      offsetX = "80",
      offsetY = "0",
    },
  },
  [14] = {
    name = "facial hair",
    header = "Facial Hairs",
    controlSuffix = "FacialHair",
    texture = "esoui/art/treeicons/gamepad/gp_collectionicon_facialhair.dds",
    bulletTexture = "esoui/art/treeicons/gamepad/gp_collectionicon_facialhair.dds",
    collectibleSlot = {
      offsetX = "210",
      offsetY = "0",
    },
    filterIcon = {
      offsetX = "80",
      offsetY = "28",
    },
  },
  [15] = {
    name = "major adornment",
    header = "Major Adornments",
    controlSuffix = "MajorAdornment",
    -- texture = "esoui/art/icons/adornment_adornment_female_mixed_tiarahalfcirclet.dds",
    texture = "esoui/art/icons/adornment_female_mixed_tiarahalfcirclet.dds",
    bulletTexture = "esoui/art/icons/adornment_female_mixed_tiarahalfcirclet.dds",
    collectibleSlot = {
      offsetX = "210",
      offsetY = "70",
    },
    filterIcon = {
      offsetX = "115",
      offsetY = "0",
    },
  },
  [16] = {
    name = "minor adornment",
    header = "Minor Adornments",
    controlSuffix = "MinorAdornment",
    texture = "esoui/art/treeicons/gamepad/gp_collectionicon_facialaccessories.dds",
    bulletTexture = "esoui/art/treeicons/gamepad/gp_collectionicon_facialaccessories.dds",
    collectibleSlot = {
      offsetX = "210",
      offsetY = "140",
    },
    filterIcon = {
      offsetX = "115",
      offsetY = "28",
    },
  },
  [17] = {
    name = "head marking",
    header = "Head Markings",
    controlSuffix = "HeadMarking",
    texture = "esoui/art/treeicons/gamepad/gp_collectionicon_facialmarkings.dds",
    bulletTexture = "esoui/art/treeicons/gamepad/gp_collectionicon_facialmarkings.dds",
    collectibleSlot = {
      offsetX = "0",
      offsetY = "70",
    },
    filterIcon = {
      offsetX = "150",
      offsetY = "0",
    },
  },
  [18] = {
    name = "body marking",
    header = "Body Markings",
    controlSuffix = "BodyMarking",
    texture = "esoui/art/treeicons/gamepad/gp_collectionicon_bodymarkings.dds",
    bulletTexture = "esoui/art/treeicons/gamepad/gp_collectionicon_bodymarkings.dds",
    collectibleSlot = {
      offsetX = "0",
      offsetY = "140",
    },
    filterIcon = {
      offsetX = "150",
      offsetY = "28",
    },
  },
}

QF.CustomizedActionsTable ={
  [0] = {
    name = "recall",
    header = "Recalling",
    controlSuffix = "Recall",
    texture = "esoui/art/zonestories/completiontypeicon_wayshrine.dds",
    bulletTexture = "esoui/art/zonestories/completiontypeicon_wayshrine.dds",
    collectibleSlot = {
      offsetX = "0",
      offsetY = "280",
    },
  },
  [1] = {
    name = "plant",
    header = "Plant Collecting",
    controlSuffix = "Plant",
    texture = "esoui/art/tradinghouse/gamepad/gp_tradinghouse_materials_potions_reagents.dds",
    bulletTexture = "esoui/art/tradinghouse/gamepad/gp_tradinghouse_materials_potions_reagents.dds",
    collectibleSlot = {
      offsetX = "0",
      offsetY = "0",
    },
  },
  [2] = {
    name = "wood",
    header = "Wood Cutting",
    controlSuffix = "Wood",
    texture = "esoui/art/tradinghouse/gamepad/gp_tradinghouse_materials_woodworking_rawmats.dds",
    bulletTexture = "esoui/art/tradinghouse/gamepad/gp_tradinghouse_materials_woodworking_rawmats.dds",
    collectibleSlot = {
      offsetX = "0",
      offsetY = "210",
    },
  },
  [3] = {
    name = "mining",
    header = "Mining",
    controlSuffix = "Mining",
    texture = "esoui/art/tradinghouse/gamepad/gp_tradinghouse_materials_blacksmithing_rawmats.dds",
    bulletTexture = "esoui/art/tradinghouse/gamepad/gp_tradinghouse_materials_blacksmithing_rawmats.dds",
    collectibleSlot = {
      offsetX = "0",
      offsetY = "140",
    },
  },
  [5] = {
    name = "rune",
    header = "Rune Collecting",
    controlSuffix = "Rune",
    texture = "esoui/art/tradinghouse/gamepad/gp_tradinghouse_materials_enchanting_essence.dds",
    bulletTexture = "esoui/art/tradinghouse/gamepad/gp_tradinghouse_materials_enchanting_essence.dds",
    collectibleSlot = {
      offsetX = "0",
      offsetY = "70",
    },
  },
}

QF.EquipSlots = {
  EQUIP_SLOT_MAIN_HAND,
  EQUIP_SLOT_OFF_HAND,
  EQUIP_SLOT_BACKUP_MAIN,
  EQUIP_SLOT_BACKUP_OFF,
  EQUIP_SLOT_HEAD,
  EQUIP_SLOT_CHEST,
  EQUIP_SLOT_LEGS,
  EQUIP_SLOT_SHOULDERS,
  EQUIP_SLOT_FEET,
  EQUIP_SLOT_HAND,
  EQUIP_SLOT_WAIST,
  EQUIP_SLOT_COSTUME,
}

QF.ZoneCategories = {
  [1] = "Default Profile",
  [2] = "Dungeons/Trials",
  [3] = "Cyrodiil",
  [4] = "Battlegrounds",
  [5] = "Imperial City",
  [6] = "Outlaws Refuge",
  [7] = "Swimming",
  [8] = "Clothing station",
  [9] = "Blacksmithing",
  [10] = "Woodworking",
  [11] = "Jewelry crafting",
  [12] = "Alchemy",
  [13] = "Enchanting",
  [14] = "Provisioning",
  -- [xx] = "Trespassing",
}

-- ALL major zoneIds
QF.OverlandZones = {
  [1] = {zoneId = 3}, -- Glenumbra
  [2] = {zoneId = 19}, -- Stormhaven
  [3] = {zoneId = 20}, -- Rivenspire
  [4] = {zoneId = 41}, -- Stonefalls
  [5] = {zoneId = 57}, -- Deshaan
  [6] = {zoneId = 58}, -- Malabal Tor
  [7] = {zoneId = 92}, -- Bangkorai
  [8] = {zoneId = 101}, -- Eastmarch
  [9] = {zoneId = 103}, -- The Rift
  [10] = {zoneId = 104}, -- Alik'r Desert
  [11] = {zoneId = 108}, -- Greenshade
  [12] = {zoneId = 117}, -- Shadowfen
  [13] = {zoneId = 280}, -- Bleakrock Isle
  [14] = {zoneId = 281}, -- Bal Foyen
  [15] = {zoneId = 347}, -- Coldharbour
  [16] = {zoneId = 381}, -- Auridon
  [17] = {zoneId = 382}, -- Reaper's March
  [18] = {zoneId = 383}, -- Grahtwood
  [19] = {zoneId = 534}, -- Stros M'Kai
  [20] = {zoneId = 535}, -- Betnikh
  [21] = {zoneId = 537}, -- Khenarthi's Roost
  [22] = {zoneId = 684}, -- Wrothgar
  [23] = {zoneId = 726}, -- Murkmire
  [24] = {zoneId = 816}, -- Hew's Bane
  [25] = {zoneId = 823}, -- Gold Coast
  [26] = {zoneId = 849}, -- Vvardenfell
  [27] = {zoneId = 888}, -- Craglorn
  [28] = {zoneId = 980}, -- Clockwork City
  [29] = {zoneId = 1011}, -- Summerset
  [30] = {zoneId = 1027}, -- Artaeum
  [31] = {zoneId = 1086}, -- Northern Elsweyr
  [32] = {zoneId = 1133}, -- Southern Elsweyr
  [33] = {zoneId = 1160}, -- Western Skyrim
  [34] = {zoneId = 1161}, -- Blackreach: Greymoor Caverns
  [35] = {zoneId = 1207}, -- The Reach
  [36] = {zoneId = 1208}, -- Blackreach: Arkthzand Cavern
  [37] = {zoneId = 1261}, -- Blackwood
  [38] = {zoneId = 1282}, -- Fargrave
  [39] = {zoneId = 1286}, -- The Deadlands
  [40] = {zoneId = 1318}, -- High Isle
  [41] = {zoneId = 1383}, -- Galen
  [42] = {zoneId = 1414}, -- Telvanni Peninsula
  [43] = {zoneId = 1413}, -- Apocrypha
  -- [XX] = {zoneId = 1436}, -- Infinite Archive, counts as dungeon/trial
  [44] = {zoneId = 1443}, -- West Weald
}

QF.HouseData = {
  [1] = {collectibleId = 1060},	-- Mara's Kiss Public House
  [2] = {collectibleId = 1061},	-- The Rosy Lion
  [3] = {collectibleId = 1062},	-- The Ebony Flask Inn Room
  [4] = {collectibleId = 1063},	-- Barbed Hook Private Room
  [5] = {collectibleId = 1064},	-- Sisters of the Sands Apartment
  [6] = {collectibleId = 1065},	-- Flaming Nix Deluxe garret
  [7] = {collectibleId = 1066},	-- Black Vine Villa
  [8] = {collectibleId = 1067},	-- Cliffshade
  [9] = {collectibleId = 1068},	-- Mathiisen Manor
  [10] = {collectibleId = 1069},	-- Humblemud
  [11] = {collectibleId = 1070},	-- The Ample Domicile
  [12] = {collectibleId = 1071},	-- Stay-Moist Mansion
  [13] = {collectibleId = 1072},	-- Snugpod
  [14] = {collectibleId = 1073},	-- Bouldertree Refuge
  [15] = {collectibleId = 1074},	-- The Gorinir Estate
  [16] = {collectibleId = 1075},	-- Captain Margaux's Place
  [17] = {collectibleId = 1076},	-- Ravenhurst
  [18] = {collectibleId = 1077},	-- Gardner House
  [19] = {collectibleId = 1078},	-- Kragenhome
  [20] = {collectibleId = 1079},	-- Velothi Reverie
  [21] = {collectibleId = 1080},	-- Quondam Indorilia
  [22] = {collectibleId = 1081},	-- Moonmirth House
  [23] = {collectibleId = 1082},	-- Sleek Creek House
  [24] = {collectibleId = 1083},	-- Dawnshadow
  [25] = {collectibleId = 1084},	-- Cyrodilic Jungle House
  [26] = {collectibleId = 1085},	-- Domus Phrasticus
  [27] = {collectibleId = 1086},	-- Strident Springs Demesne
  [28] = {collectibleId = 1087},	-- Autumn's-Gate
  [29] = {collectibleId = 1088},	-- Grymharth's Woe
  [30] = {collectibleId = 1089},	-- Old Mistveil Manor
  [31] = {collectibleId = 1090},	-- Hammerdeath Bungalow
  [32] = {collectibleId = 1091},	-- Mournoth Keep
  [33] = {collectibleId = 1092},	-- Forsaken Stronghold
  [34] = {collectibleId = 1093},	-- Twin Arches
  [35] = {collectibleId = 1094},	-- House of the Silent Magnifico
  [36] = {collectibleId = 1095},	-- Hunding's Palatial Hall
  [37] = {collectibleId = 1096},	-- Serenity Falls Estate
  [38] = {collectibleId = 1097},	-- Daggerfall Overlook
  [39] = {collectibleId = 1098},	-- Ebonheart Chateau
  [40] = {collectibleId = 1099},	-- Grand Topal Hideaway
  [41] = {collectibleId = 1100},	-- Earthtear Cavern
  [42] = {collectibleId = 1242},	-- Saint Delyn Penthouse
  [43] = {collectibleId = 1243},	-- Amaya Lake Lodge
  [44] = {collectibleId = 1244},	-- Ald Velothi Harbor House
  [45] = {collectibleId = 1245},	-- Tel Galen
  [46] = {collectibleId = 1309},	-- Linchal Grand Manor
  [47] = {collectibleId = 1312},	-- Coldharbour Surreal Estate
  [48] = {collectibleId = 1311},	-- Hakkvilkd's High Hall
  [49] = {collectibleId = 1310},	-- Exorcised Coven Cottage
  -- [50] = {collectibleId = nil},	-- Unused
  -- [51] = {collectibleId = nil},	-- Unused
  -- [52] = {collectibleId = nil},	-- Unused
  -- [53] = {collectibleId = nil},	-- Unused
  [54] = {collectibleId = 1445},	-- Pariah's Pinnacle
  [55] = {collectibleId = 1446},	-- The Observatory Prior
  [56] = {collectibleId = 4794},	-- The Erstwhile Sancturary
  [57] = {collectibleId = 4795},	-- Princely Dawnlight Palace
  [58] = {collectibleId = 5167},	-- Golden Gryphon Garret
  [59] = {collectibleId = 5168},	-- Alinor Crest Townhouse
  [60] = {collectibleId = 5169},	-- Colossal Aldmeri Grotto
  [61] = {collectibleId = 5461},	-- Hunter's Glade
  [62] = {collectibleId = 5462},	-- Grand Psijic Villa
  [63] = {collectibleId = 5756},	-- Enchanted Show Globe Home
  [64] = {collectibleId = 5757},	-- Lakemire Xanmeer Manor
  [65] = {collectibleId = 6139},	-- Frostvault Chasm
  [66] = {collectibleId = 6140},	-- Elinhir Private Arena
  -- [67] = {collectibleId = nil},	-- Unused
  [68] = {collectibleId = 6380},	-- Sugar Bowl Suite
  [69] = {collectibleId = 6399},	-- Jode's Embrace
  [70] = {collectibleId = 6400},	-- Hall of the Lunar Champion
  [71] = {collectibleId = 6751},	-- Moon-Sugar Meadow
  [72] = {collectibleId = 6752},	-- Wraithhome
  [73] = {collectibleId = 7218},	-- Lucky Cat Landing
  [74] = {collectibleId = 7226},	-- Potentate's Retreat
  [75] = {collectibleId = 7600},	-- Forgemaster Falls
  [76] = {collectibleId = 7601},	-- Thieves' Oasis
  [77] = {collectibleId = 8009},	-- Snowmelt Suite
  [78] = {collectibleId = 8010},	-- Proudspire Manor
  [79] = {collectibleId = 8011},	-- Bastion Sanguinaris
  [80] = {collectibleId = 8323},	-- Stillwaters Retreat
  [81] = {collectibleId = 8353},	-- Antiquarian's Apline Gallery
  [82] = {collectibleId = 8652},	-- Shalidor's Shrouded Realm
  [83] = {collectibleId = 8697},	-- Stone Eagle Aerie
  -- [84] = {collectibleId = nil},	-- Unused
  [85] = {collectibleId = 9013},	-- Kushalit Sanctuary
  [86] = {collectibleId = 9014},	-- Varlaisvea Ayleid Ruins
  [87] = {collectibleId = 9392},	-- Pilgrim's Rest
  [88] = {collectibleId = 9407},	-- Water's Edge
  [89] = {collectibleId = 9412},	-- Pantherfang Chapel
  [90] = {collectibleId = 9649},  -- Doomchar Plateau
  [91] = {collectibleId = 9735},  -- Sweetwater Cascades
  [92] = {collectibleId = 10051}, -- Ossa Accentium
  [93] = {collectibleId = 10052}, -- Agony's Ascent
  [94] = {collectibleId = 10223}, -- Seaveil Spire
  [95] = {collectibleId = 10441}, -- Ancient Anchor Berth
  [96] = {collectibleId = 10511}, -- Highhallow Hold
  -- [97] = {collectibleId = nil}, -- Unused
  [98] = {collectibleId = 11172}, -- Fogbreak Lighthouse
  [99] = {collectibleId = 11216}, -- The Fair Winds
  [100] = {collectibleId = 11220}, -- Journey's End Lodgings
  [101] = {collectibleId = 11223}, -- Emissary's Enclave
  [102] = {collectibleId = 11260}, -- Shadow Queen's Labyrinth
  -- [103] = {collectibleId = nil}, -- Unused
  [104] = {collectibleId = 11525}, -- Kelesan'ruhn
  [105] = {collectibleId = 11655}, -- Gladesong Arboretum
  [106] = {collectibleId = 11687}, -- Tower of Unetterable Truths
  [107] = {collectibleId = 12270}, -- Willowpond Haven
  [108] = {collectibleId = 12456}, -- Zhan Khaj Crest
  [109] = {collectibleId = 12471}, -- Rosewine Retreat
  [110] = {collectibleId = 12472}, -- Merryvine Estate
  [111] = {collectibleId = 12655}, -- Seabloom Villa
  [112] = {collectibleId = 12656}, -- Haven of the Five companions
  [113] = {collectibleId = 12731}, -- Kthendral Deep Mines
}
