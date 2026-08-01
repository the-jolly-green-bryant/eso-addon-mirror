-- =============================================================================
-- Dungeon Tracker — Localization
-- Auto-detects the client language and provides localized content names
-- (via manual translation tables) and UI strings.
-- =============================================================================

DTT_Locale = {}

-- ---------------------------------------------------------------------------
-- Internal state
-- ---------------------------------------------------------------------------
local lang = "en"

-- ---------------------------------------------------------------------------
-- UI string tables  (EN is the default fallback)
-- ---------------------------------------------------------------------------
local strings = {}

strings["en"] = {
    TITLE           = "Dungeon Tracker",
    TAB_BASE        = "Base Dungeons",
    TAB_DLC         = "DLC Dungeons",
    KB_PREV_TAB     = "Prev Tab",
    KB_NEXT_TAB     = "Next Tab",
    KB_SCROLL_UP    = "Scroll Up",
    KB_SCROLL_DOWN  = "Scroll Down",
    MENU_ENTRY      = "Dungeon Tracker",
    COL_Q           = "Q",
    -- DLC group headers
    GROUP_BASE_GAME             = "Base Game",
    GROUP_IMPERIAL_CITY         = "Imperial City",
    GROUP_SHADOWS_OF_THE_HIST   = "Shadows of the Hist",
    GROUP_HORNS_OF_THE_REACH    = "Horns of the Reach",
    GROUP_DRAGON_BONES          = "Dragon Bones",
    GROUP_WOLFHUNTER            = "Wolfhunter",
    GROUP_WRATHSTONE            = "Wrathstone",
    GROUP_SCALEBREAKER          = "Scalebreaker",
    GROUP_HARROWSTORM           = "Harrowstorm",
    GROUP_STONETHORN            = "Stonethorn",
    GROUP_FLAMES_OF_AMBITION    = "Flames of Ambition",
    GROUP_WAKING_FLAME          = "Waking Flame",
    GROUP_ASCENDING_TIDE        = "Ascending Tide",
    GROUP_LOST_DEPTHS           = "Lost Depths",
    GROUP_SCRIBES_OF_FATE       = "Scribes of Fate",
    GROUP_SCIONS_OF_ITHELIA     = "Scions of Ithelia",
    GROUP_FALLEN_BANNERS        = "Fallen Banners",
    GROUP_FEAST_OF_SHADOWS      = "Feast of Shadows",
}

strings["de"] = {
    TITLE           = "Verlies-Tracker",
    TAB_BASE        = "Basisverliese",
    TAB_DLC         = "DLC-Verliese",
    KB_PREV_TAB     = "Vorh. Tab",
    KB_NEXT_TAB     = "Nächst. Tab",
    KB_SCROLL_UP    = "Nach oben",
    KB_SCROLL_DOWN  = "Nach unten",
    MENU_ENTRY      = "Verlies-Tracker",
    COL_Q           = "Q",
    GROUP_BASE_GAME             = "Basisspiel",
    GROUP_IMPERIAL_CITY         = "Kaiserstadt",
    GROUP_SHADOWS_OF_THE_HIST   = "Schatten des Hist",
    GROUP_HORNS_OF_THE_REACH    = "Hörner der Reichweite",
    GROUP_DRAGON_BONES          = "Drachenknochen",
    GROUP_WOLFHUNTER            = "Wolfsjäger",
    GROUP_WRATHSTONE            = "Zornstein",
    GROUP_SCALEBREAKER          = "Schuppenbrecher",
    GROUP_HARROWSTORM           = "Unheilssturm",
    GROUP_STONETHORN            = "Steindorn",
    GROUP_FLAMES_OF_AMBITION    = "Flammen des Ehrgeizes",
    GROUP_WAKING_FLAME          = "Erwachende Flamme",
    GROUP_ASCENDING_TIDE        = "Steigende Flut",
    GROUP_LOST_DEPTHS           = "Verlorene Tiefen",
    GROUP_SCRIBES_OF_FATE       = "Schreiber des Schicksals",
    GROUP_SCIONS_OF_ITHELIA     = "Nachkommen Ithelias",
    GROUP_FALLEN_BANNERS        = "Gefallene Banner",
    GROUP_FEAST_OF_SHADOWS      = "Fest der Schatten",
}

strings["fr"] = {
    TITLE           = "Suivi des donjons",
    TAB_BASE        = "Donjons de base",
    TAB_DLC         = "Donjons DLC",
    KB_PREV_TAB     = "Onglet préc.",
    KB_NEXT_TAB     = "Onglet suiv.",
    KB_SCROLL_UP    = "Défiler haut",
    KB_SCROLL_DOWN  = "Défiler bas",
    MENU_ENTRY      = "Suivi des donjons",
    COL_Q           = "Q",
    GROUP_BASE_GAME             = "Jeu de base",
    GROUP_IMPERIAL_CITY         = "Cité impériale",
    GROUP_SHADOWS_OF_THE_HIST   = "Ombres du Hist",
    GROUP_HORNS_OF_THE_REACH    = "Cornes de la Portée",
    GROUP_DRAGON_BONES          = "Ossements de dragons",
    GROUP_WOLFHUNTER            = "Chasseur de loups",
    GROUP_WRATHSTONE            = "Pierre de courroux",
    GROUP_SCALEBREAKER          = "Brise-écailles",
    GROUP_HARROWSTORM           = "Tempête infernale",
    GROUP_STONETHORN            = "Épine de pierre",
    GROUP_FLAMES_OF_AMBITION    = "Flammes de l'ambition",
    GROUP_WAKING_FLAME          = "Flamme éveillée",
    GROUP_ASCENDING_TIDE        = "Marée montante",
    GROUP_LOST_DEPTHS           = "Profondeurs perdues",
    GROUP_SCRIBES_OF_FATE       = "Scribes du destin",
    GROUP_SCIONS_OF_ITHELIA     = "Rejetons d'Ithelia",
    GROUP_FALLEN_BANNERS        = "Bannières déchues",
    GROUP_FEAST_OF_SHADOWS      = "Festin des ombres",
}

strings["ja"] = {
    TITLE           = "ダンジョントラッカー",
    TAB_BASE        = "基本ダンジョン",
    TAB_DLC         = "DLCダンジョン",
    KB_PREV_TAB     = "前のタブ",
    KB_NEXT_TAB     = "次のタブ",
    KB_SCROLL_UP    = "上スクロール",
    KB_SCROLL_DOWN  = "下スクロール",
    MENU_ENTRY      = "ダンジョントラッカー",
    COL_Q           = "Q",
    GROUP_BASE_GAME             = "ベースゲーム",
    GROUP_IMPERIAL_CITY         = "帝都",
    GROUP_SHADOWS_OF_THE_HIST   = "ヒストの影",
    GROUP_HORNS_OF_THE_REACH    = "リーチの角笛",
    GROUP_DRAGON_BONES          = "ドラゴンボーン",
    GROUP_WOLFHUNTER            = "ウルフハンター",
    GROUP_WRATHSTONE            = "ラスストーン",
    GROUP_SCALEBREAKER          = "スケイルブレイカー",
    GROUP_HARROWSTORM           = "ハローストーム",
    GROUP_STONETHORN            = "ストーンソーン",
    GROUP_FLAMES_OF_AMBITION    = "野望の炎",
    GROUP_WAKING_FLAME          = "覚醒の炎",
    GROUP_ASCENDING_TIDE        = "潮流の台頭",
    GROUP_LOST_DEPTHS           = "失われし深淵",
    GROUP_SCRIBES_OF_FATE       = "運命の書記",
    GROUP_SCIONS_OF_ITHELIA     = "イセリアの末裔",
    GROUP_FALLEN_BANNERS        = "倒れし旗",
    GROUP_FEAST_OF_SHADOWS      = "影の饗宴",
}

strings["zh"] = {
    TITLE           = "地下城追踪器",
    TAB_BASE        = "基础地下城",
    TAB_DLC         = "DLC地下城",
    KB_PREV_TAB     = "上一页",
    KB_NEXT_TAB     = "下一页",
    KB_SCROLL_UP    = "向上滚动",
    KB_SCROLL_DOWN  = "向下滚动",
    MENU_ENTRY      = "地下城追踪器",
    COL_Q           = "Q",
    GROUP_BASE_GAME             = "基础游戏",
    GROUP_IMPERIAL_CITY         = "帝都",
    GROUP_SHADOWS_OF_THE_HIST   = "幽暗沼泽",
    GROUP_HORNS_OF_THE_REACH    = "猎角行动",
    GROUP_DRAGON_BONES          = "龙骨",
    GROUP_WOLFHUNTER            = "猎狼人",
    GROUP_WRATHSTONE            = "怒石",
    GROUP_SCALEBREAKER          = "碎鳞者",
    GROUP_HARROWSTORM           = "恐怖风暴",
    GROUP_STONETHORN            = "石棘",
    GROUP_FLAMES_OF_AMBITION    = "野心之焰",
    GROUP_WAKING_FLAME          = "觉醒之焰",
    GROUP_ASCENDING_TIDE        = "潮起",
    GROUP_LOST_DEPTHS           = "失落深渊",
    GROUP_SCRIBES_OF_FATE       = "命运抄写员",
    GROUP_SCIONS_OF_ITHELIA     = "伊瑟利亚后裔",
    GROUP_FALLEN_BANNERS        = "倒下的旗帜",
    GROUP_FEAST_OF_SHADOWS      = "暗影之宴",
}

-- ---------------------------------------------------------------------------
-- Mapping from English group name -> translation key
-- ---------------------------------------------------------------------------
local groupKeyMap = {
    ["Base Game"]              = "GROUP_BASE_GAME",
    ["Imperial City"]          = "GROUP_IMPERIAL_CITY",
    ["Shadows of the Hist"]    = "GROUP_SHADOWS_OF_THE_HIST",
    ["Horns of the Reach"]     = "GROUP_HORNS_OF_THE_REACH",
    ["Dragon Bones"]           = "GROUP_DRAGON_BONES",
    ["Wolfhunter"]             = "GROUP_WOLFHUNTER",
    ["Wrathstone"]             = "GROUP_WRATHSTONE",
    ["Scalebreaker"]           = "GROUP_SCALEBREAKER",
    ["Harrowstorm"]            = "GROUP_HARROWSTORM",
    ["Stonethorn"]             = "GROUP_STONETHORN",
    ["Flames of Ambition"]     = "GROUP_FLAMES_OF_AMBITION",
    ["Waking Flame"]           = "GROUP_WAKING_FLAME",
    ["Ascending Tide"]         = "GROUP_ASCENDING_TIDE",
    ["Lost Depths"]            = "GROUP_LOST_DEPTHS",
    ["Scribes of Fate"]        = "GROUP_SCRIBES_OF_FATE",
    ["Scions of Ithelia"]      = "GROUP_SCIONS_OF_ITHELIA",
    ["Fallen Banners"]         = "GROUP_FALLEN_BANNERS",
    ["Feast of Shadows"]       = "GROUP_FEAST_OF_SHADOWS",
}

-- ---------------------------------------------------------------------------
-- Content name translation tables  (English name -> localized name)
-- Sourced from official ESO community databases (eso-hub.com/de, dragonika.fr)
-- ---------------------------------------------------------------------------
local contentNames = {}

-- ── German (de) ─────────────────────────────────────────────────────────────
contentNames["de"] = {
    -- Base Game Dungeons
    ["Fungal Grotto I"]        = "Pilzgrotte I",
    ["Fungal Grotto II"]       = "Pilzgrotte II",
    ["Spindleclutch I"]        = "Spindeltiefen I",
    ["Spindleclutch II"]       = "Spindeltiefen II",
    ["The Banished Cells I"]   = "Verbannungszellen I",
    ["The Banished Cells II"]  = "Verbannungszellen II",
    ["Elden Hollow I"]         = "Eldengrund I",
    ["Elden Hollow II"]        = "Eldengrund II",
    ["Wayrest Sewers I"]       = "Kanalisation von Wegesruh I",
    ["Wayrest Sewers II"]      = "Kanalisation von Wegesruh II",
    ["Arx Corinium"]           = "Arx Corinium",
    ["City of Ash I"]          = "Stadt der Asche I",
    ["City of Ash II"]         = "Stadt der Asche II",
    ["Crypt of Hearts I"]      = "Krypta der Herzen I",
    ["Crypt of Hearts II"]     = "Krypta der Herzen II",
    ["Direfrost Keep"]         = "Burg Grauenfrost",
    ["Tempest Island"]         = "Orkaninsel",
    ["Volenfell"]              = "Volenfell",
    ["Darkshade Caverns I"]    = "Dunkelschattenkavernen I",
    ["Darkshade Caverns II"]   = "Dunkelschattenkavernen II",
    ["Blackheart Haven"]       = "Schwarzherz-Unterschlupf",
    ["Blessed Crucible"]       = "Gesegnete Feuerprobe",
    ["Selene's Web"]           = "Selenes Netz",
    ["Vaults of Madness"]      = "Kammern des Wahnsinns",
    -- DLC Dungeons
    ["Imperial City Prison"]   = "Gefängnis der Kaiserstadt",
    ["White-Gold Tower"]       = "Weißgoldturm",
    ["Ruins of Mazzatun"]      = "Ruinen von Mazzatun",
    ["Cradle of Shadows"]      = "Wiege der Schatten",
    ["Falkreath Hold"]         = "Falkenring",
    ["Bloodroot Forge"]        = "Blutquellschmiede",
    ["Fang Lair"]              = "Krallenhort",
    ["Scalecaller Peak"]       = "Gipfel der Schuppenruferin",
    ["Moon Hunter Keep"]       = "Mondjägerfeste",
    ["March of Sacrifices"]    = "Marsch der Aufopferung",
    ["Frostvault"]             = "Frostgewölbe",
    ["Depths of Malatar"]      = "Tiefen von Malatar",
    ["Lair of Maarselok"]      = "Hort von Maarselok",
    ["Moongrave Fane"]         = "Mondgrab-Tempelstadt",
    ["Icereach"]               = "Eiskap",
    ["Unhallowed Grave"]       = "Unheiliges Grab",
    ["Stone Garden"]           = "Steingarten",
    ["Castle Thorn"]           = "Kastell Dorn",
    ["Black Drake Villa"]      = "Schwarzdrachenvilla",
    ["The Cauldron"]           = "Der Kessel",
    ["Red Petal Bastion"]      = "Rotblütenbastion",
    ["The Dread Cellar"]       = "Der Schreckenskeller",
    ["Coral Aerie"]            = "Korallenhorst",
    ["Shipwright's Regret"]    = "Gram des Schiffbauers",
    ["Earthen Root Enclave"]   = "Erdwurz-Enklave",
    ["Graven Deep"]            = "Kentertiefen",
    ["Bal Sunnar"]             = "Bal Sunnar",
    ["Scrivener's Hall"]       = "Halle der Schriftmeister",
    ["Oathsworn Pit"]          = "Grube der Eidgeschworenen",
    ["Bedlam Veil"]            = "Schleier des Aufruhrs",
    ["Exiled Redoubt"]         = "Schanze der Abgeschiedenen",
    ["Lep Seclusa"]            = "Lep Seclusa",
    ["Naj-Caldeesh"]           = "Naj-Caldeesh",
    ["Black Gem Foundry"]      = "Schwatzstein-Gießerei",
}

-- ── French (fr) ─────────────────────────────────────────────────────────────
contentNames["fr"] = {
    -- Base Game Dungeons
    ["Fungal Grotto I"]        = "Champignonnière I",
    ["Fungal Grotto II"]       = "Champignonnière II",
    ["Spindleclutch I"]        = "Tressefuseau I",
    ["Spindleclutch II"]       = "Tressefuseau II",
    ["The Banished Cells I"]   = "Cachot interdit I",
    ["The Banished Cells II"]  = "Cachot interdit II",
    ["Elden Hollow I"]         = "Creuset des aînés I",
    ["Elden Hollow II"]        = "Creuset des aînés II",
    ["Wayrest Sewers I"]       = "Égouts d'Haltevoie I",
    ["Wayrest Sewers II"]      = "Égouts d'Haltevoie II",
    ["Arx Corinium"]           = "Arx Corinium",
    ["City of Ash I"]          = "Cité des cendres I",
    ["City of Ash II"]         = "Cité des cendres II",
    ["Crypt of Hearts I"]      = "Crypte des cœurs I",
    ["Crypt of Hearts II"]     = "Crypte des cœurs II",
    ["Direfrost Keep"]         = "Donjon d'Affregivre",
    ["Tempest Island"]         = "Île des Tempêtes",
    ["Volenfell"]              = "Volenfell",
    ["Darkshade Caverns I"]    = "Cavernes d'Ombré-noire I",
    ["Darkshade Caverns II"]   = "Cavernes d'Ombré-noire II",
    ["Blackheart Haven"]       = "Havre de Cœurnoir",
    ["Blessed Crucible"]       = "Creuset béni",
    ["Selene's Web"]           = "Toile de Sélène",
    ["Vaults of Madness"]      = "Chambres de la folie",
    -- DLC Dungeons
    ["Imperial City Prison"]   = "Prison de la cité impériale",
    ["White-Gold Tower"]       = "Tour d'or blanc",
    ["Ruins of Mazzatun"]      = "Ruines de Mazzatun",
    ["Cradle of Shadows"]      = "Berceau des ombres",
    ["Falkreath Hold"]         = "Forteresse d'Épervine",
    ["Bloodroot Forge"]        = "Forge de Sangracine",
    ["Fang Lair"]              = "Repaire du croc",
    ["Scalecaller Peak"]       = "Pic de la Mandécailles",
    ["Moon Hunter Keep"]       = "Fort du Chasseur lunaire",
    ["March of Sacrifices"]    = "Procession des Sacrifiés",
    ["Frostvault"]             = "Arquegivre",
    ["Depths of Malatar"]      = "Profondeurs de Malatar",
    ["Lair of Maarselok"]      = "Repaire de Maarselok",
    ["Moongrave Fane"]         = "Reliquaire des Lunes funèbres",
    ["Icereach"]               = "Crève-Nève",
    ["Unhallowed Grave"]       = "Le Sépulcre profane",
    ["Stone Garden"]           = "Jardin de pierre",
    ["Castle Thorn"]           = "Bastion-les-Ronce",
    ["Black Drake Villa"]      = "Villa du Dragon noir",
    ["The Cauldron"]           = "Chaudron",
    ["Red Petal Bastion"]      = "Bastion du Pétale rouge",
    ["The Dread Cellar"]       = "Cave d'effroi",
    ["Coral Aerie"]            = "Aire de corail",
    ["Shipwright's Regret"]    = "Regret du charpentier",
    ["Earthen Root Enclave"]   = "Enclave des Racines de la terre",
    ["Graven Deep"]            = "Profondeurs mortuaires",
    ["Bal Sunnar"]             = "Bal Sunnar",
    ["Scrivener's Hall"]       = "Salles du Scribe",
    ["Oathsworn Pit"]          = "Fosse aux fidèles",
    ["Bedlam Veil"]            = "Voile des fous",
    ["Exiled Redoubt"]         = "Redoute de l'Exil",
    ["Lep Seclusa"]            = "Lep Selusa",
    ["Naj-Caldeesh"]           = "Naj-Caldeesh",
    ["Black Gem Foundry"]      = "Fonderie de Gemme noire",
}

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

function DTT_Locale.Init()
    lang = GetCVar and GetCVar("language.2") or "en"
    if not strings[lang] then lang = "en" end
end

function DTT_Locale.RebuildNameMap()
    -- no-op: names are now hardcoded translation tables
end

function DTT_Locale.L(key)
    local tbl = strings[lang] or strings["en"]
    return tbl[key] or (strings["en"] and strings["en"][key]) or key
end

function DTT_Locale.GetLocalizedName(entry)
    if lang == "en" then return entry.name end

    local tbl = contentNames[lang]
    if tbl and tbl[entry.name] then
        return tbl[entry.name]
    end

    -- Fallback: English name
    return entry.name
end

function DTT_Locale.GetLocalizedGroup(englishGroupName)
    local key = groupKeyMap[englishGroupName]
    if key then
        return DTT_Locale.L(key)
    end
    return englishGroupName
end
