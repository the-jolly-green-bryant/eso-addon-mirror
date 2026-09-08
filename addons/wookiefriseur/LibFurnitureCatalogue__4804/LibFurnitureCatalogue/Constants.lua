-- DB constants: item-source/version enums + source ranking, NPC/location/event name tables

FurC = FurC or {}

local LFC = LibFurnitureCatalogue

--- Collection of some variables for easier access. Not intended as an API. Some values are constants, while others are generated from string localisation and may change between play sessions or game patches.
local this = {}
LFC.Internal.Constants = this
FurC.Constants = this -- TODO: move alias to LFC.Internal

local getZoneStr = GetZoneNameById
local getCrateStr = GetCrownCrateName
local getSkillLineStr = GetSkillLineNameById
local sFormat = zo_strformat

local function getStr(id)
  return GetString(id)
end

--- One resolver per type: stable id -> localised text
this.Resolvers = {
  Zone = getZoneStr,
  Place = getStr,
  Npc = getStr,
  Event = getStr,
  Crate = getCrateStr,
  SkillLine = getSkillLineStr,
}

local idCounter = {}

---Generate consecutive ids for constants
---@param id_type string Type for which to generate an ID
---@return integer nextId Next ID for given type
local function getNextIdFor(id_type)
  idCounter[id_type] = (idCounter[id_type] or 0) + 1
  return idCounter[id_type]
end

---Fill "names" table and its reverse "byName" map from a table of stable ids
--- Resolves them with passed table specific callback function
---@param ids table<string, integer> key -> stable game or string id
---@param resolve fun(id: integer): string Resolver callback, use 1 resolver per table
---@param names table<string, string> key -> localised name, filled in place (mutating)
---@param byName table<string, integer> localised name -> id, filled in place (mutating)
local function deriveNames(ids, resolve, names, byName)
  for key, id in pairs(ids) do
    local name = resolve(id)
    names[key] = name
    if name and name ~= "" then
      byName[name] = id
    end
  end
end

-- Public event names, used in Api.lua as LFC.API.Events
-- here, because DB build fires them and loads before Api.lua
this.ApiEvents = {
  SCAN_STARTED = "LFC_SCAN_STARTED",
  SCAN_COMPLETE = "LFC_SCAN_COMPLETE",
  SCAN_FAILED = "LFC_SCAN_FAILED",
}

-- constants for filtering

-- item sources
this.ItemSources = {
  NONE = getNextIdFor("ITEM_SOURCES"), -- 1
  FAVE = getNextIdFor("ITEM_SOURCES"), -- 2
  CRAFTING = getNextIdFor("ITEM_SOURCES"), -- 3
  CRAFTING_KNOWN = getNextIdFor("ITEM_SOURCES"), -- 4
  CRAFTING_UNKNOWN = getNextIdFor("ITEM_SOURCES"), -- 5
  VENDOR = getNextIdFor("ITEM_SOURCES"), -- 6
  PVP = getNextIdFor("ITEM_SOURCES"), -- 7
  WRIT_VENDOR = getNextIdFor("ITEM_SOURCES"), -- 8
  CROWN = getNextIdFor("ITEM_SOURCES"), -- 9
  RUMOUR = getNextIdFor("ITEM_SOURCES"), -- 10
  LUXURY = getNextIdFor("ITEM_SOURCES"), -- 11
  OTHER = getNextIdFor("ITEM_SOURCES"), -- 12
  ROLIS = getNextIdFor("ITEM_SOURCES"), -- 13
  DROP = getNextIdFor("ITEM_SOURCES"), -- 14
  JUSTICE = getNextIdFor("ITEM_SOURCES"), -- 15
  FISHING = getNextIdFor("ITEM_SOURCES"), -- 16
  GUILDSTORE = getNextIdFor("ITEM_SOURCES"), -- 17
  FESTIVAL_DROP = getNextIdFor("ITEM_SOURCES"), -- 18
  BAZAAR = getNextIdFor("ITEM_SOURCES"), -- 19
  TOMES = getNextIdFor("ITEM_SOURCES"), -- 20
  TELVAR = getNextIdFor("ITEM_SOURCES"), -- 21
  COLL_MERCH = getNextIdFor("ITEM_SOURCES"), -- 22
  EDITOR = getNextIdFor("ITEM_SOURCES"), -- 23
  ANTIQUITY = getNextIdFor("ITEM_SOURCES"), -- 24
  DUNGEON = getNextIdFor("ITEM_SOURCES"), -- 25
  HARVEST = getNextIdFor("ITEM_SOURCES"), -- 26
  CHEST = getNextIdFor("ITEM_SOURCES"), -- 27
  QUEST = getNextIdFor("ITEM_SOURCES"), -- 28
  PICKPOCKET = getNextIdFor("ITEM_SOURCES"), -- 29
  CONTAINER = getNextIdFor("ITEM_SOURCES"), -- 30
}

---@alias FurCItemSource integer # FurC.Constants.ItemSources values

-- Ranking for multi-source
do
  local src = this.ItemSources
  this.SOURCE_PRIORITY = {
    [src.CRAFTING] = 10,
    -- purchased (in-game currencies)
    [src.VENDOR] = 20,
    [src.WRIT_VENDOR] = 21,
    [src.ROLIS] = 22,
    [src.TOMES] = 23,
    [src.PVP] = 30,
    [src.TELVAR] = 31,
    [src.COLL_MERCH] = 32,
    [src.BAZAAR] = 61,
    -- drop / harvest / steal
    -- fine-grained sources rank higher than their parent
    [src.DUNGEON] = 33,
    [src.HARVEST] = 34,
    [src.CHEST] = 35,
    [src.QUEST] = 36,
    [src.PICKPOCKET] = 37,
    [src.CONTAINER] = 38,
    [src.DROP] = 40,
    [src.JUSTICE] = 41,
    [src.FISHING] = 42,
    -- excavation / scrying
    [src.ANTIQUITY] = 45,
    -- time-limited / rotating stock
    [src.LUXURY] = 50,
    [src.FESTIVAL_DROP] = 51,
    -- real money
    [src.EDITOR] = 60,
    [src.CROWN] = 62,
    -- other
    [src.OTHER] = 70,
    [src.GUILDSTORE] = 98, -- do we even use this?
    [src.RUMOUR] = 99,
  }
end

-- Stable English names for the source types (because the enum meaning might not be obvious)
-- Those are not and will not be locale strings
do
  local src = this.ItemSources
  this.SourceLabels = {
    [src.NONE] = "Unknown",
    [src.FAVE] = "Favourite",
    [src.CRAFTING] = "Crafting",
    [src.CRAFTING_KNOWN] = "Crafting",
    [src.CRAFTING_UNKNOWN] = "Crafting",
    [src.VENDOR] = "Achievement Vendor",
    [src.PVP] = "PvP Vendor",
    [src.WRIT_VENDOR] = "Master Writ Vendor",
    [src.CROWN] = "Crown Store",
    [src.RUMOUR] = "Datamined, unconfirmed",
    [src.LUXURY] = "Luxury Furnisher",
    [src.OTHER] = "Other",
    [src.ROLIS] = "Rolis Hlaalu",
    [src.DROP] = "Drop",
    [src.JUSTICE] = "Justice",
    [src.FISHING] = "Fishing",
    [src.GUILDSTORE] = "Guild Store",
    [src.FESTIVAL_DROP] = "Event",
    [src.BAZAAR] = "Gold Coast Bazaar",
    [src.TOMES] = "Tamriel Tomes",
    [src.TELVAR] = "Tel Var Merchant",
    [src.COLL_MERCH] = "Collectibles Merchant",
    [src.EDITOR] = "Housing Editor",
    [src.ANTIQUITY] = "Antiquity",
    [src.DUNGEON] = "Dungeon",
    [src.HARVEST] = "Harvesting",
    [src.CHEST] = "Treasure Chest",
    [src.QUEST] = "Quest Reward",
    [src.PICKPOCKET] = "Pickpocketing",
    [src.CONTAINER] = "Container",
  }

  -- Enum values that just exist for filtering, not as an item source
  -- TODO: mv those into FC only
  this.NotASource = {
    [src.FAVE] = true,
    [src.CRAFTING_KNOWN] = true,
    [src.CRAFTING_UNKNOWN] = true,
  }
end

-- TODO #REFACTOR Switch version numbering to the same as game update numbers

-- versioning
this.Versioning = {
  NONE = getNextIdFor("VERSIONING"), -- 1 off
  HOMESTEAD = getNextIdFor("VERSIONING"), -- 2 Homestead U13
  MORROWIND = getNextIdFor("VERSIONING"), -- 3 Morrowind U14
  REACH = getNextIdFor("VERSIONING"), -- 4 Horns of the Reach U15
  CLOCKWORK = getNextIdFor("VERSIONING"), -- 5 Clockwork City U16
  DRAGONS = getNextIdFor("VERSIONING"), -- 6 Dragon Bones U17
  ALTMER = getNextIdFor("VERSIONING"), -- 7 Summerset U18
  SLAVES = getNextIdFor("VERSIONING"), -- 8 Murkmire U19
  WEREWOLF = getNextIdFor("VERSIONING"), -- 9 Wolfhunter U20
  WOTL = getNextIdFor("VERSIONING"), -- 10 Wrathstone U21
  KITTY = getNextIdFor("VERSIONING"), -- 11 Elsweyr U22
  SCALES = getNextIdFor("VERSIONING"), -- 12 Scalebreaker U23
  DRAGON2 = getNextIdFor("VERSIONING"), -- 13 Dragonhold U24
  HARROW = getNextIdFor("VERSIONING"), -- 14 Harrowstorm U25
  SKYRIM = getNextIdFor("VERSIONING"), -- 15 Greymoor U26
  STONET = getNextIdFor("VERSIONING"), -- 16 Stonethorn U27
  MARKAT = getNextIdFor("VERSIONING"), -- 17 Markarth U28
  FLAMES = getNextIdFor("VERSIONING"), -- 18 Flames of Ambition U29
  BLACKW = getNextIdFor("VERSIONING"), -- 19 Blackwood U30
  WAKE = getNextIdFor("VERSIONING"), -- 20 Waking Flame U31
  DEADL = getNextIdFor("VERSIONING"), -- 21 Deadlands U32
  TIDES = getNextIdFor("VERSIONING"), -- 22 Ascending Tide U33
  BRETON = getNextIdFor("VERSIONING"), -- 23 High Isle U34
  DEPTHS = getNextIdFor("VERSIONING"), -- 24 Lost Depths U35
  DRUID = getNextIdFor("VERSIONING"), -- 25 Firesong U36
  SCRIBE = getNextIdFor("VERSIONING"), -- 26 Scribes of Fate U37
  NECROM = getNextIdFor("VERSIONING"), -- 27 Necrom U38
  BASED = getNextIdFor("VERSIONING"), -- 28 Base Game Patch U39
  ENDLESS = getNextIdFor("VERSIONING"), -- 29 Secrets of the Telvanni U40
  SCIONS = getNextIdFor("VERSIONING"), -- 30 Scions of Ithelia U41
  WEALD = getNextIdFor("VERSIONING"), -- 31 Gold Road U42
  BASE43 = getNextIdFor("VERSIONING"), -- 32 Home Tours U43
  BASE44 = getNextIdFor("VERSIONING"), -- 33 Golden Pursuits U44
  FALLBAN = getNextIdFor("VERSIONING"), -- 34 Fallen Banners (U45)
  WORMS = getNextIdFor("VERSIONING"), -- 35 Seasons of the Worm Cult (U46)
  SHADOWS = getNextIdFor("VERSIONING"), -- 36 Feast of Shadows (U47)
  WORMS2 = getNextIdFor("VERSIONING"), -- 37 Seasons of the Worm Cult Part 2 (U48)
  ZERO = getNextIdFor("VERSIONING"), -- 38 Season Zero (U49)
  THIEVES = getNextIdFor("VERSIONING"), -- 39 Season One (U50)
}

-- value -> name, taken before the aliases below start sharing values
this.VersionNames = {}
for name, value in pairs(this.Versioning) do
  this.VersionNames[value] = name
end

this.Versioning.LATEST = this.Versioning.THIEVES

---@deprecated Version smushing related compatibility workaround. Currently required by FC 7.0.0
--- Delete at next main version update.
this.Versioning.ZERO2 = this.Versioning.THIEVES

-- Game zones, translated by the game
--  Careful: the ids may change with expansions, use FurCDev.FindZone to fix any broken ones
this.ZoneIds = {
  ALIKR = 104, -- Alik'r Desert
  APOCRYPHA = 1413, -- Apocrypha
  ARTAEUM = 1027, -- Artaeum
  AURIDON = 381, -- Auridon
  BALFOYEN = 281, -- Bal Foyen
  BANG = 92, -- Bangkorai
  BETNIKH = 535, -- Betnikh
  BLACKREACH_GMC = 1161, --  Blackreach: Greymoor Caverns
  BLACKWOOD = 1261, -- Blackwood
  BLEAK = 280, -- Bleakrock Isle
  COLDH = 347, -- Coldharbor
  CRAGLORN = 888, -- Craglorn
  CWC = 980, -- Clockwork City
  CYRO = 181, -- Cyrodiil
  DEADLANDS = 1286, -- Deadlands
  DESHAAN = 57, -- Deshaan
  DUNG_DOM = 1081, -- Depths of Malatar
  DUNG_FL = 1009, -- Fang Lair
  DUNG_FV = 1080, -- Frostvault
  DUNG_IA = 1436, -- Infinite Archive
  DUNG_MHK = 1052, -- Moon Hunter Keep
  DUNG_MOS = 1055, -- March of the Sacrifices
  DUNG_NYMIC = 1420, -- Bastion Nymic
  DUNG_SCP = 1010, -- Scalecaller Peak
  DUNG_SCRIV = 1390, -- Scrivener's Hall
  EASTMARCH = 101, -- Eastmarch
  FARGRAVE = 1282, -- Fargrave
  GALEN = 1383, -- Galen
  GLENUMBRA = 3, -- Glenumbra
  GOLDCOAST = 823, -- Gold Coast
  GRAHTWOOD = 383, -- Grahtwood
  GREENSHADE = 108, -- Greenshade
  HEWSBANE = 816, -- Hew's Bane
  HIGHISLE = 1318, -- High Isle
  IMPCITY = 584, -- Imperial City
  KHENARTHI = 537, -- Khenarthi's Roost
  MALABAL = 58, -- Malabal Tor
  MURKMIRE = 726, -- Murkmire
  NELSWEYR = 1086, -- Northern Elsweyr
  NMARKET = 1559, -- Night Market
  PDUNG_VVARDENFELL_FW = 919, -- Forgotten Wastes
  REACH = 1207, -- The Reach
  REAPER = 382, -- Reaper's March
  RIFT = 103, -- Rift
  RIVENSPIRE = 20, -- Rivenspire
  SCHOLAR = 1463, -- The Scholarium
  SELSWEYR = 1133, -- Southern Elsweyr
  SHADOWFEN = 117, -- Shadowfen
  SOLSTICE = 1502, -- Solstice
  STONEFALLS = 41, -- Stonefalls
  STORMHAVEN = 19, -- Stormhaven
  STROSMKAI = 534, -- Stros M'Kai
  SUMMERSET = 1011, -- Summerset
  TELVANNI = 1414, -- Telvanni Peninsula
  VVARDENFELL = 849, -- Vvardenfell
  WEALD = 1443, -- West Weald

  WROTHGAR = 684, -- Wrothgar
  WSKYRIM = 1160, -- Western Skyrim
}

-- Places the game has no zone ids for
this.PlaceIds = {
  ANY = SI_FURC_LOC_ANY,
  ANY_CAPITAL = SI_FURC_LOC_ANY_CAPITAL,
  ANY_CITY = SI_FURC_LOC_ANY_CITY,
  GUILD_FIGHTERS = SI_FURC_GUILD_FIGHTERS, -- location in AchievementVendors
  GUILD_MAGES = SI_FURC_GUILD_MAGES, -- location in AchievementVendors
  -- TODO
  LILANDRIL = SI_FURC_LOC_LILANDRIL,
  MURKMIRE_LIL = SI_FURC_LOC_MURKMIRE_LIL,
  PLACE_ORSINIUM = SI_FURC_LOC_PLACE_ORSINIUM,
  REACH_MARKARTH_MM = SI_FURC_LOC_REACH_MARKARTH_MM,
  SELSWEYR_DHA = SI_FURC_LOC_SELSWEYR_DHA,
  SELSWEYR_SENCHAL_MARKET = SI_FURC_LOC_SELSWEYR_SENCHAL_MARKET,
  SHADOWFEN_CORIMONT = SI_FURC_LOC_SHADOWFEN_CORIMONT,
  STONEFALLS_EBONHEART = SI_FURC_LOC_STONEFALLS_EBONHEART,
  SUMMERSET_ALINOR = SI_FURC_LOC_SUMMERSET_ALINOR,
  SUMMERSET_ALINOR_RIVERSIDE = SI_FURC_LOC_SUMMERSET_ALINOR_RIVERSIDE,
  UNDAUNTED = SI_FURC_LOC_UNDAUNTED,
  STORMHAVEN_WAY_MERCH = SI_FURC_LOC_STORMHAVEN_WAY_MERCH,
  TELVANNI_NECROM_FRF = SI_FURC_TELVANNI_NECROM_FRF,
  VVARDENFELL_SURAN = SI_FURC_LOC_VVARDENFELL_SURAN,
  VVARDENFELL_ALDRUHN = SI_FURC_LOC_VVARDENFELL_ALDRUHN, -- Vvardenfell
  VVARDENFELL_VIVEC = SI_FURC_LOC_VVARDENFELL_VIVEC,
  VVARDENFELL_VIVEC_GQ = SI_FURC_LOC_VVARDENFELL_VIVEC_GQ,
  VVARDENFELL_VIVEC_SDI = SI_FURC_LOC_VVARDENFELL_VIVEC_SDI,
  WSKYRIM_SOLI_DH = SI_FURC_LOC_WSKYRIM_SOLI_DH,
}

-- Localised names, keyed as before. Zones and places share the namespace
this.Locations = {}
this.ZoneByName = {}
this.PlaceByName = {}
deriveNames(this.ZoneIds, getZoneStr, this.Locations, this.ZoneByName)
deriveNames(this.PlaceIds, getStr, this.Locations, this.PlaceByName)

-- NPC ids, for better readability and more control of the string sources
-- Names keep the game's grammar markup; the formatter resolves it
this.NpcIds = {
  -- Writ Furnishers
  ROLIS = SI_FURC_TRADERS_ROLIS, -- Rolis Hlaalu, Mastercraft Mediator
  FAUSTINA = SI_FURC_TRADERS_FAUSTINA, -- Faustina Curio, Achievement Mediator

  -- Other Furnishers
  ALCHEMISTS = SI_FURC_TRADERS_ALCHEMISTS, -- any alchemist
  BLACKSMITHS = SI_FURC_TRADERS_BLACKSMITHS, -- any blacksmith
  CARPENTERS = SI_FURC_TRADERS_CARPENTERS, -- any capenter
  CLOTHIERS = SI_FURC_TRADERS_CLOTHIERS, -- any clothier
  COOKS = SI_FURC_TRADERS_COOKS, -- any cook
  ENCHANTERS = SI_FURC_TRADERS_ENCHANTERS, -- any enchanter

  -- Special Merchants
  AF = SI_FURC_TRADERS_AF, -- Achievement Vendor: Lozotusk, ...
  BGF = SI_FURC_TRADERS_BGF, -- Battlegrounds Furnishers
  CAF = SI_FURC_TRADERS_CAF, -- Global Achievement Vendor: Nolenowen, ...
  EVENT = SI_FURC_TRADERS_EVENT, -- Event Merchant, any capital city: The Impressario
  HGF = SI_FURC_TRADERS_HGF, -- Home Goods Furnisher: Maladiq, Rohzika, ...
  HOLIDAY = SI_FURC_TRADERS_HOLIDAY, -- Heralda, Tildannire, ...
  LUXF = SI_FURC_TRADERS_LUXF, -- Luxury Furnisher: Zanil
  NM = SI_FURC_TRADERS_NM, -- Night Market Vendors: Nymisasha, Fennel, Najirra
  COLL_MERCH = SI_FURC_TRADERS_COLL_MERCH, -- Tel Var Collectibles Merchant: Enruvie, Skoref Bearblood, Bernamund Bertault

  -- Guild Traders
  FIGHTERS_STEWARD = SI_FURC_GUILD_FIGHTERS_STEWARD, -- stewards in Fighters Guild locations
  MAGES_MYSTIC = SI_FURC_GUILD_MAGES_MYSTIC, --  mystics in Mages Guild locations
  PSIJIC_NALIRSEWEN = SI_FURC_GUILD_PSIJIC_NALIRSEWEN, -- Psijic Trader on Artaeum
  THIEVES_MERCH = SI_FURC_GUILD_THIEVES_MERCH, -- Outlaw Merchant in any refuge
  UNDAUNTED_QM = SI_FURC_GUILD_UNDAUNTED_QM, -- Undaunted Achievement trader

  -- enemies (loot)
  ENEMY_AUTOMATON = SI_FURC_NPC_AUTOMATON,
}

-- Social classes (pickpocketing), rendered singular
-- NOTE: Extra lookup table for better testing, and because we don't own those strings (nil str would drop the whole row)
local SOCIAL_CLASS_STRINGS = {
  CLASS_ALCHEMIST = "SI_MONSTERSOCIALCLASS2",
  CLASS_ARTISAN = "SI_MONSTERSOCIALCLASS3",
  CLASS_ASSASSIN = "SI_MONSTERSOCIALCLASS4",
  CLASS_BARD = "SI_MONSTERSOCIALCLASS5",
  CLASS_BEGGAR = "SI_MONSTERSOCIALCLASS6",
  CLASS_CHEF = "SI_MONSTERSOCIALCLASS7",
  CLASS_CIVIL_SERVANT = "SI_MONSTERSOCIALCLASS8",
  CLASS_CLOTHIER = "SI_MONSTERSOCIALCLASS9",
  CLASS_COMMONER = "SI_MONSTERSOCIALCLASS10",
  CLASS_CRAFTER = "SI_MONSTERSOCIALCLASS11",
  CLASS_CULTIST = "SI_MONSTERSOCIALCLASS12",
  CLASS_DAEDRA = "SI_MONSTERSOCIALCLASS47",
  CLASS_DRUNKARD = "SI_MONSTERSOCIALCLASS13",
  CLASS_FARMER = "SI_MONSTERSOCIALCLASS14",
  CLASS_FIGHTER = "SI_MONSTERSOCIALCLASS15",
  CLASS_FISHER = "SI_MONSTERSOCIALCLASS16",
  CLASS_GATHERER = "SI_MONSTERSOCIALCLASS17",
  CLASS_GHOST = "SI_MONSTERSOCIALCLASS18",
  CLASS_GUARD = "SI_MONSTERSOCIALCLASS19",
  CLASS_HEALER = "SI_MONSTERSOCIALCLASS20",
  CLASS_HUNTER = "SI_MONSTERSOCIALCLASS21",
  CLASS_LABORER = "SI_MONSTERSOCIALCLASS22",
  CLASS_MAGE = "SI_MONSTERSOCIALCLASS23",
  CLASS_MERCHANT = "SI_MONSTERSOCIALCLASS24",
  CLASS_NOBLE = "SI_MONSTERSOCIALCLASS25",
  CLASS_NUDE = "SI_MONSTERSOCIALCLASS26",
  CLASS_ORDINATOR = "SI_MONSTERSOCIALCLASS27",
  CLASS_OUTLAW = "SI_MONSTERSOCIALCLASS28",
  CLASS_PILGRIM = "SI_MONSTERSOCIALCLASS29",
  CLASS_PRIEST = "SI_MONSTERSOCIALCLASS30",
  CLASS_PRISONER = "SI_MONSTERSOCIALCLASS31",
  CLASS_PROVISIONER = "SI_MONSTERSOCIALCLASS32",
  CLASS_SAILOR = "SI_MONSTERSOCIALCLASS33",
  CLASS_SCHOLAR = "SI_MONSTERSOCIALCLASS34",
  CLASS_SERVANT = "SI_MONSTERSOCIALCLASS35",
  CLASS_SKELETON = "SI_MONSTERSOCIALCLASS36",
  CLASS_SLAVE = "SI_MONSTERSOCIALCLASS37",
  CLASS_SMITH = "SI_MONSTERSOCIALCLASS38",
  CLASS_SOLDIER = "SI_MONSTERSOCIALCLASS39",
  CLASS_STUDENT = "SI_MONSTERSOCIALCLASS40",
  CLASS_THIEF = "SI_MONSTERSOCIALCLASS41",
  CLASS_VAMPIRE = "SI_MONSTERSOCIALCLASS42",
  CLASS_WARRIOR = "SI_MONSTERSOCIALCLASS43",
  CLASS_WATCHMEN = "SI_MONSTERSOCIALCLASS44",
  CLASS_WEREWOLF = "SI_MONSTERSOCIALCLASS45",
  CLASS_WOODWORKER = "SI_MONSTERSOCIALCLASS46",
}

this.NpcClassIds = {}
for key, stringId in pairs(SOCIAL_CLASS_STRINGS) do
  this.NpcClassIds[key] = _G[stringId]
end

-- Groups of enemies, rendered plural
this.NpcGroupIds = {
  ENEMY_RND = SI_FURC_SRC_RNDMOB,
}

this.NPC = {}
this.NpcByName = {}
deriveNames(this.NpcIds, getStr, this.NPC, this.NpcByName)
deriveNames(SOCIAL_CLASS_STRINGS, function(stringId)
  local id = _G[stringId]
  return id and sFormat("<<1>>", GetString(id)) or ""
end, this.NPC, this.NpcByName)
deriveNames(this.NpcGroupIds, function(id)
  return sFormat("<<m:1>>", GetString(id))
end, this.NPC, this.NpcByName)

this.CrownCrateIds = {
  -- Source: https://en.uesp.net/wiki/Online:Crown_Crates

  -- ids not confirmed ingame yet

  KINDRED = 64, -- 2025-12, Hidden Kindred

  -- confirmed ids
  ANU_PAD = 67, -- 2026-06, Anu vs. Padomay
  DB = 60, -- 2024-12, Dark Brotherhood
  MIRROR = 61, -- 2025-03, Mirrormoor
  WAVE = 66, -- 2026-06, Warrior Wave
  AKA_ALDU = 63, -- 2025-09, Akatosh vs. Alduin
  CARNAVAL = 62, -- 2025-06, Carnaval
  ORSINIUM = 65, -- 2026-03, Moons Over Orsinium
  DIAMOND = 59, -- 2024-07, Diamond Anniversary
  LAMP = 58, -- 2024-04 Order of the Lamp
  ALLMAKER = 57, -- 2023-12 All-Maker
  ARMIGER = 55, -- 2023-09 Buoyant Armiger
  FEATHER = 54, -- 2023-06, Unfeathered
  RAGE = 53, -- 2023-04 Ragebound
  STONELORE = 52, -- 2022-12 Stonelore
  WRAITH = 51, -- 2022-09 Wraithtide
  DARK = 50, -- 2022-06 Dark Chivalry
  SUNKEN = 49, -- 2022-04 Sunken Trove
  CELESTIAL = 48, -- 2021-12 Celestial
  HARLEQUIN = 47, -- 2021-09 Grim Harlequin
  IRON_ATRO = 46, -- 2021-06 Iron Atronach
  AYLEID = 45, -- 2021-03 Ayleid
  POTENTATE = 44, -- 2020-12, Akaviri Potentate
  SOVNGARDE = 41, -- 2020-09 Sovngarde
  NIGHTFALL = 39, -- 2020-06 Nightfall
  GLOOMSPORE = 37, -- 2020-04 Gloomspore
  FROST_ATRO = 30, -- 2020-01 Frost Atronach
  NEWMOON = 27, -- 2019-09 New Moon
  BAANDARI = 21, -- 2019-07, Baandari Pedlar
  DRAGONSCALE = 24, -- 2019-04 Dragonscale
  XANMEER = 12, -- 2018-12, Xanmeer
  HOLLOWJACK = 10, -- 2018-09, Hollowjack
  PSIJIC = 9, -- 2018-06, Psijic Vault
  SCALECALLER = 8, -- 2018-03, Scalecaller
  FIRE_ATRO = 6, -- 2017-11, Flame Atronach
  REAPER = 5, -- 2017-09, Reaper's Harvest
  DWEMER = 4, -- 2017-07, Dwarven
  WILD_HUNT = 2, -- 2017-04, Wild Hunt
  --STORM_ATRO = 1, -- 2016-12, Storm Atronach, no exclusive furnishings
}

this.CrownCrates = {}
this.CrownCrateByName = {}
deriveNames(this.CrownCrateIds, getCrateStr, this.CrownCrates, this.CrownCrateByName)

-- Book containers
-- Source: manual lookup + https://en.uesp.net (minedItemSummary, ITEMTYPE_CONTAINER)
this.BookContainers = {
  -- Mages Guild reprints
  REPRINT_ALIKR = 120381, -- Guild Reprint: Alik'r Desert Lore
  REPRINT_AURIDON = 120401, -- Guild Reprint: Auridon Lore
  REPRINT_BANGKORAI = 120380, -- Guild Reprint: Bangkorai Lore
  REPRINT_BIOGRAPHIES = 120385, -- Guild Reprint: Biographies
  REPRINT_COLDHARBOUR = 120405, -- Guild Reprint: Coldharbour Lore
  REPRINT_DAEDRIC_PRINCES = 120384, -- Guild Reprint: Daedric Princes
  REPRINT_DESHAAN = 120399, -- Guild Reprint: Deshaan Lore
  REPRINT_DIVINES = 120386, -- Guild Reprint: Divines and Deities
  REPRINT_DUNGEON_LORE = 120387, -- Guild Reprint: Dungeon Lore
  REPRINT_DWEMER = 120388, -- Guild Reprint: Dwemer
  REPRINT_EASTMARCH = 120398, -- Guild Reprint: Eastmarch Lore
  REPRINT_EYEVEA = 120383, -- Guild Reprint: The Trial of Eyevea
  REPRINT_GLENUMBRA = 120377, -- Guild Reprint: Glenumbra Lore
  REPRINT_GRAHTWOOD = 120402, -- Guild Reprint: Grahtwood Lore
  REPRINT_GREENSHADE = 120403, -- Guild Reprint: Greenshade Lore
  REPRINT_LEGENDS_OF_NIRN = 120389, -- Guild Reprint: Legends of Nirn
  REPRINT_LITERATURE = 120390, -- Guild Reprint: Literature
  REPRINT_MAGIC_MAGICKA = 120391, -- Guild Reprint: Magic and Magicka
  REPRINT_MALABAL_TOR = 120397, -- Guild Reprint: Malabal Tor Lore
  REPRINT_MYTHS_MUNDUS = 120392, -- Guild Reprint: Myths of the Mundus
  REPRINT_OBLIVION_LORE = 120393, -- Guild Reprint: Oblivion Lore
  REPRINT_POETRY_SONG = 120394, -- Guild Reprint: Poetry and Song
  REPRINT_REAPERS_MARCH = 120404, -- Guild Reprint: Reaper's March Lore
  REPRINT_RIFT = 120400, -- Guild Reprint: The Rift Lore
  REPRINT_RIVENSPIRE = 120379, -- Guild Reprint: Rivenspire Lore
  REPRINT_SHADOWFEN = 120382, -- Guild Reprint: Shadowfen Lore
  REPRINT_STONEFALLS = 120396, -- Guild Reprint: Stonefalls Lore
  REPRINT_STORMHAVEN = 120378, -- Guild Reprint: Stormhaven Lore
  REPRINT_TAMRIEL_HISTORY = 120395, -- Guild Reprint: Tamriel History

  -- lore collections, sold by achievement furnishers
  TEMPLE_DOCTRINE = 126792, -- Temple Doctrine: The 36 Lessons (Vvardenfell)
  TRUTH_IN_SEQUENCE = 134547, -- The Truth in Sequence (Clockwork City)
  NOTHING_EYES = 145596, -- Look Upon Their Nothing Eyes (Murkmire)
}

this.ItemPacks = {
  -- Source: PTS + UESP dump

  ALCHEMIST = 197984, -- Furnishing Pack: Mad Alchemist
  AMBITIONS = 197988, -- Furnishing Pack: Daedric Ambitions
  AQUATIC = 197990, -- Furnishing Pack: Aquatic Splendor
  ASTULA = 197994, -- Furnishing Pack: Shad Astula Scholars
  AYLEID = 197959, -- Furniture Pack: Ayleid
  AZURA = 197956, -- Furnishing Pack: Azura
  COLDHARBOUR = 197964, -- Furnishing Pack: Coldharbour Arcanaeum
  COMBAT = 214259, -- Furnishing Pack: Combat Training
  COVEN = 197960, -- Furnishing Pack: Witches' Coven
  CRAGBED = 197941, -- Craglorn Multicultural Bedroom Pack
  CRAGKITCHEN = 197940, -- Craglorn Multicultural Kitchen Pack
  CRAGKNICKS = 197943, -- Craglorn Multicultural Knick-Knacks Pack
  CRAGPARLOUR = 197942, -- Craglorn Multicultural Parlor Pack
  CURIO = 203179, -- Furnishing Pack: Apocryphal Curiosities
  DARIEN = 225202, -- Furnishing Pack: Darien's Delights
  DEEPMIRE = 197976, -- Furnishing Pack: Deepmire Expedition
  DIBELLA = 197966, -- Furnishing Pack: Dibella's Garden
  DRUIDIC = 198668, -- Furnishing Pack: Druidic Gatherings
  DWARVEN = 212354, -- Furnishing Pack: Dwarven Training Dummies
  FARGRAVE = 197989, -- Furnishing Pack: Fargrave Bazaar
  FORGE = 197977, -- Furnishing Pack: Forge-Lord's Great Works
  HAUNTED = 211094, -- Furnishing Pack: Haunted Housewares
  HEART = 197982, -- Furnishing Pack: Heart's Day Retreat
  HOLLOWJACK = 197973, -- Furnishing Pack: Sinister Hollowjack Items
  HUBTREASURE = 197965, -- Furnishing Pack: Hubalajad's Final Treasure
  JESTER = 204435, -- Furnishing Pack: Jester's Festival Stagecraft
  KHAJIIT = 197981, -- Furnishing Pack: Khajiiti Life
  LOOM = 214260, -- Furnishing Pack: Heart of the Loom
  MALACATH = 197963, -- Furnishing Pack: Malacath's Chosen
  MAORMER = 197993, -- Furnishing Pack: Maormer Boarding Party
  MEPHALA = 197968, -- Furnishing Pack: Trappings of Mephala Worship
  MERMAID = 197987, -- Furnishing Pack: Steam Bath Serenity
  MOLAG = 197961, -- Furnishing Pack: Molag Bal
  MOONBISHOP = 197979, -- Furnishing Pack: Moon-Bishop's Sanctuary
  MOONPATH = 219746, -- Furnishing Pack: Moonlit Pathways
  NECROM = 198324, -- Furnishing Pack: Necrom Garden
  NEREID = 217656, -- Furnishing Pack: Water Dancer Nereid
  NEWLIFE2018 = 197974, -- Furnishing Pack: New Life Festival
  NOBLEBATH = 197972, -- Summerset Noble's Bathing Pack
  NOBLEKIT = 197970, -- Summerset Noble's Kitchen Pack
  NOBLEPARLOUR = 197971, -- Summerset Noble's Parlor Pack
  OASIS = 197980, -- Furnishing Pack: Moons-Blessed Oasis
  PIPES = 197957, -- Furnishing Pack: Dwarven Pipes
  SANGUINE = 219745, -- Furnishing Pack: Sanguine's Festival
  SOTHA = 197962, -- Furnishing Pack: The Clockwork God's Domain
  SWAMP = 197975, -- Furnishing Pack: Shadow and Stone
  THEATER = 217655, -- Furnishing Pack: Community Theater
  TOYMAKER = 224366, -- Furnishing Pack: Toymaker's Trove
  TREES = 197954, -- Trees of Tamriel Garden Pack
  TYRANTS = 197967, -- Furnishing Pack: Tyrants of the Merethic Era
  VAMPIRE = 197983, -- Furnishing Pack: Vampiric Libations
  VIVEC = 197958, -- Furnishing Pack: Lord Vivec
  WINDOWS = 197986, -- Furnishing Pack: Windows of the Divines
  WINTER = 223659, -- Furnishing Pack: Winter's Feast
  WRITHING = 223665, -- Furnishing Pack: Writhing Fortress
  ZENI = 197985, -- Furnishing Pack: Chapel of Zenithar
}

--- Crown Store bundles without itemlink, mv to ItemPacks when you get an ID
this.ItemBundles = {
  DWEMER = SI_FURC_ITEMPACK_DWEMER,
  EBONY = SI_FURC_ITEMPACK_EBONY,
  FIRSTBLADE = SI_FURC_ITEMPACK_FIRSTBLADE,
  JYGGALAG = SI_FURC_ITEMPACK_JYGGALAG,
  RAZOR = SI_FURC_ITEMPACK_RAZOR,
  STABLE = SI_FURC_ITEMPACK_STABLE,
}

this.SkillLineIds = {
  -- manual lookup for now:
  -- /script for i=1, 1000 do if (string.find(LocaleAwareToLower(GetSkillLineNameById(i)), "psijic")) then d(string.format("%d: %s", i, GetSkillLineNameById(i))) end end

  LEGERDEMAIN = 111,
  PSIJIC = 130,
}

this.SkillLines = {}
this.SkillLineByName = {}
deriveNames(this.SkillLineIds, getSkillLineStr, this.SkillLines, this.SkillLineByName)

this.EventIds = {
  ANNIVERSARY = SI_FURC_EVENT_ANNIVERSARY, -- Anniversary Jubilee
  BLACKWOOD = SI_FURC_EVENT_BLACKWOOD, -- Bounties of Blackwood
  CRIME = SI_FURC_EVENT_CRIME, -- Crime Wave
  ELSWEYR = SI_FURC_EVENT_ELSWEYR, -- Season of the Dragon
  HOLLOWJACK = SI_FURC_EVENT_HOLLOWJACK, -- Sinister Hollowjack
  IC = SI_FURC_EVENT_IC, -- Imperial City Celebration Event
  JESTER = SI_FURC_EVENT_JESTER, -- Jester's Festival
  MAYHEM = SI_FURC_EVENT_MAYHEM, -- Whitestrake's Mayhem
  NEWLIFE = SI_FURC_EVENT_NEWLIFE, -- New Life Festival
  UNDAUNTED = SI_FURC_EVENT_UNDAUNTED, -- Undaunted Celebration
  WITCHES = SI_FURC_EVENT_WITCHES, -- Witches Festival
  ZENITHAR = SI_FURC_EVENT_ZENITHAR, -- Zeal of Zenithar
  HEARTS = SI_FURC_EVENT_HEARTS, -- Hearts Week
  NIGHTMARKET = SI_FURC_EVENT_NIGHTMARKET, -- Night Market
  WRITHING = SI_FURC_EVENT_WRITHING, -- Writhing Wall
  ORSINIUM = SI_FURC_EVENT_ORSINIUM, -- Orsinium Celebration
}

this.Events = {}
this.EventByName = {}
deriveNames(this.EventIds, getStr, this.Events, this.EventByName)

this.Containers = {
  BOONBOX = "|H0:item:121526:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", -- during Whitestrake's Mayhem
  ELSWEYRCOFFER = "|H0:item:175580:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", -- during Season of the Dragon
  JESTERBOX = "|H0:item:194414:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", -- during Jester's Festival
  JUBILEEBOX = "|H0:item:134797:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", -- during Anniversary Jubilee
  LEGIONZEROBOX = "|H0:item:167210:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", -- during Imperial City Celebration
  NEWLIFEBOX = "|H0:item:96390:367:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", -- during New Life Festival
  PLUNDERSKULL = "|H0:item:84521:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", -- during Witches' Festival
  UNDAUNTEDBOX = "|H0:item:171267:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", -- during Undaunted Celebration
  ZENITHARPARCEL = "|H0:item:187701:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", -- during Zenithar's Zeal
  POUCH = "|H0:item:214263:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", -- during Crime Wave
  SUMMERSET_FOLIO = "|H1:item:171572:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
  SKYRIM_FOLIO = "|H1:item:171808:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
  DRAGONHOLD_FOLIO = "|H1:item:171778:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
  TOMEHOLD_FOLIO = "|H1:item:214255:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
  ELSWEYR_FOLIO = "|H1:item:171574:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
  NECROM_FOLIO = "|H1:item:211090:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
  WEALD2_FOLIO = "|H1:item:223978:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
  WEALD_FOLIO = "|H1:item:219721:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
  MORROWIND_FOLIO = "|H1:item:171569:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
  MARKARTH_FOLIO = "|H1:item:184192:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
  HIGHISLE_FOLIO = "|H1:item:198597:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
  GALEN_FOLIO = "|H0:item:204499:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
  BLACKWOOD_FOLIO = "|H1:item:190121:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
  DEADLANDS_FOLIO = "|H1:item:194429:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
  EBONHEART_FOLIO = "|H1:item:171573:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
  CRAFTER_FOLIO = "|H1:item:171568:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
  DARKELF_FOLIO = "|H1:item:171571:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
  SOLSTICE_FOLIO = "|H1:item:226916:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
}

-- TODO: allow customisable colours, getting from options
local colours = {
  AP = "5EA4FF",
  Gold = "E5DA40",
  House = "40D0C0",
  Location = "CF6D00",
  Quest = "E5DA40",
  TelVar = "82BCFF",
  Vendor = "72DB00",
  Voucher = "25C31E",
}
this.Colours = colours

-- Old Constants as a fallback for other AddOns that use them
-- ToDo: required functionality will be moved to an API in the future

-- fallback item sources

-- @warning deprecated
FURC_NONE = this.ItemSources.NONE -- 1

-- @warning deprecated
FURC_FAVE = this.ItemSources.FAVE -- 2

-- @warning deprecated
FURC_CRAFTING = this.ItemSources.CRAFTING -- 3

-- @warning deprecated
FURC_CRAFTING_KNOWN = this.ItemSources.CRAFTING_KNOWN -- 4

-- @warning deprecated
FURC_CRAFTING_UNKNOWN = this.ItemSources.CRAFTING_UNKNOWN -- 5

-- @warning deprecated
FURC_VENDOR = this.ItemSources.VENDOR -- 6

-- @warning deprecated
FURC_PVP = this.ItemSources.PVP -- 7

-- @warning deprecated
FURC_WRIT_VENDOR = this.ItemSources.WRIT_VENDOR -- 8

-- @warning deprecated
FURC_CROWN = this.ItemSources.CROWN -- 9

-- @warning deprecated
FURC_RUMOUR = this.ItemSources.RUMOUR -- 10

-- @warning deprecated
FURC_LUXURY = this.ItemSources.LUXURY -- 11

-- @warning deprecated
FURC_OTHER = this.ItemSources.OTHER -- 12

-- @warning deprecated
FURC_ROLIS = this.ItemSources.ROLIS -- 13

-- @warning deprecated
FURC_DROP = this.ItemSources.DROP -- 14

-- @warning deprecated
FURC_JUSTICE = this.ItemSources.JUSTICE -- 15

-- @warning deprecated
FURC_FISHING = this.ItemSources.FISHING -- 16

-- @warning deprecated
FURC_GUILDSTORE = this.ItemSources.GUILDSTORE -- 17

-- @warning deprecated
FURC_FESTIVAL_DROP = this.ItemSources.FESTIVAL_DROP -- 18

-- fallback versions

-- @warning deprecated
FURC_HOMESTEAD = this.Versioning.HOMESTEAD -- 2 Homestead

-- @warning deprecated
FURC_MORROWIND = this.Versioning.MORROWIND -- 3 Morrowind

-- @warning deprecated
FURC_REACH = this.Versioning.REACH -- 4 Horns of the Reach

-- @warning deprecated
FURC_CLOCKWORK = this.Versioning.CLOCKWORK -- 5 Clockwork City

-- @warning deprecated
FURC_DRAGONS = this.Versioning.DRAGONS -- 6 Dragon Bones

-- @warning deprecated
FURC_ALTMER = this.Versioning.ALTMER -- 7 Summerset

-- @warning deprecated
FURC_SLAVES = this.Versioning.SLAVES -- 8 Murkmire

-- @warning deprecated
FURC_WEREWOLF = this.Versioning.WEREWOLF -- 9 Wolfhunter

-- @warning deprecated
FURC_WOTL = this.Versioning.WOTL -- 10 Wrathstone

-- @warning deprecated
FURC_KITTY = this.Versioning.KITTY -- 11 Elsweyr

-- @warning deprecated
FURC_SCALES = this.Versioning.SCALES -- 12 Scalebreaker

-- @warning deprecated
FURC_DRAGON2 = this.Versioning.DRAGON2 -- 13 Dragonhold

-- @warning deprecated
FURC_HARROW = this.Versioning.HARROW -- 14 Harrowstorm

-- @warning deprecated
FURC_SKYRIM = this.Versioning.SKYRIM -- 15 Greymoor

-- @warning deprecated
FURC_STONET = this.Versioning.STONET -- 16 Stonethorn

-- @warning deprecated
FURC_MARKAT = this.Versioning.MARKAT -- 17 Markarth

-- @warning deprecated
FURC_FLAMES = this.Versioning.FLAMES -- 18 Flames of Ambition

-- @warning deprecated
FURC_BLACKW = this.Versioning.BLACKW -- 19 Blackwood

-- @warning deprecated
FURC_DEADL = this.Versioning.DEADL -- 20 Deadlands

-- @warning deprecated
FURC_TIDES = this.Versioning.TIDES -- 21 Ascending Tide

-- @warning deprecated
FURC_BRETON = this.Versioning.BRETON -- 22 High Isle

-- @warning deprecated
FURC_DEPTHS = this.Versioning.DEPTHS -- 23 Lost Depths

-- @warning deprecated
FURC_DRUID = this.Versioning.DRUID -- 24 Firesong

-- @warning deprecated
FURC_SCRIBE = this.Versioning.SCRIBE -- 25 Scribes of Fate

-- @warning deprecated
FURC_NECROM = this.Versioning.NECROM -- 26 Necrom

-- @warning deprecated
FURC_BASED = this.Versioning.BASED -- 27 Base Game Patch

-- @warning deprecated
FURC_ENDLESS = this.Versioning.ENDLESS -- 28 Secrets of the Telvanni

-- @warning deprecated
FURC_SCIONS = this.Versioning.SCIONS -- 29 Scions of Ithelia

-- @warning deprecated
FURC_WEALD = this.Versioning.WEALD -- 30 Gold Road

-- @warning deprecated
FURC_BASE43 = this.Versioning.BASE43 -- 31 Update 43 Base Game Patch

-- @warning deprecated
FURC_BASE44 = this.Versioning.BASE44 -- 32 Update 44 Base Game Patch

-- @warning deprecated
FURC_LATEST = this.Versioning.LATEST
