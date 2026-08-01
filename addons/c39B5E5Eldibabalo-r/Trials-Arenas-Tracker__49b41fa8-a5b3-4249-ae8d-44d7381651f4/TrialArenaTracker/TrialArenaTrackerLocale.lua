-- =============================================================================
-- Trial & Arena Tracker — Localization
-- Auto-detects the client language and provides localized content names
-- (via manual translation tables) and UI strings.
-- =============================================================================

TAT_Locale = {}

-- ---------------------------------------------------------------------------
-- Internal state
-- ---------------------------------------------------------------------------
local lang = "en"

-- ---------------------------------------------------------------------------
-- UI string tables  (EN is the default fallback)
-- ---------------------------------------------------------------------------
local strings = {}

strings["en"] = {
    TITLE           = "Trial & Arena Tracker",
    TAB_TRIALS      = "Trials",
    TAB_ARENAS      = "Arenas",
    KB_PREV_TAB     = "Prev Tab",
    KB_NEXT_TAB     = "Next Tab",
    KB_SCROLL_UP    = "Scroll Up",
    KB_SCROLL_DOWN  = "Scroll Down",
    MENU_ENTRY      = "Trial & Arena Tracker",
    -- Group headers (chapter / DLC names)
    GROUP_CRAGLORN                  = "Craglorn",
    GROUP_THIEVES_GUILD             = "Thieves Guild",
    GROUP_MORROWIND                 = "Morrowind",
    GROUP_CLOCKWORK_CITY            = "Clockwork City",
    GROUP_SUMMERSET                 = "Summerset",
    GROUP_ELSWEYR                   = "Elsweyr",
    GROUP_GREYMOOR                  = "Greymoor",
    GROUP_BLACKWOOD                 = "Blackwood",
    GROUP_HIGH_ISLE                 = "High Isle",
    GROUP_NECROM                    = "Necrom",
    GROUP_GOLD_ROAD                 = "Gold Road",
    GROUP_SEASONS_OF_THE_WORM_CULT  = "Seasons of the Worm Cult",
    GROUP_ORSINIUM                  = "Orsinium",
    GROUP_MURKMIRE                  = "Murkmire",
    GROUP_MARKARTH                  = "Markarth",
}

strings["de"] = {
    TITLE           = "Prüfungs- & Arena-Tracker",
    TAB_TRIALS      = "Prüfungen",
    TAB_ARENAS      = "Arenen",
    KB_PREV_TAB     = "Vorh. Tab",
    KB_NEXT_TAB     = "Nächst. Tab",
    KB_SCROLL_UP    = "Nach oben",
    KB_SCROLL_DOWN  = "Nach unten",
    MENU_ENTRY      = "Prüfungs- & Arena-Tracker",
    GROUP_CRAGLORN                  = "Kargstein",
    GROUP_THIEVES_GUILD             = "Diebesgilde",
    GROUP_MORROWIND                 = "Morrowind",
    GROUP_CLOCKWORK_CITY            = "Uhrwerkstadt",
    GROUP_SUMMERSET                 = "Sommersend",
    GROUP_ELSWEYR                   = "Elsweyr",
    GROUP_GREYMOOR                  = "Graumark",
    GROUP_BLACKWOOD                 = "Dunkelforst",
    GROUP_HIGH_ISLE                 = "Hochinsel",
    GROUP_NECROM                    = "Necrom",
    GROUP_GOLD_ROAD                 = "Goldstraße",
    GROUP_SEASONS_OF_THE_WORM_CULT  = "Jahreszeiten des Wurmkults",
    GROUP_ORSINIUM                  = "Orsinium",
    GROUP_MURKMIRE                  = "Trübmoor",
    GROUP_MARKARTH                  = "Markarth",
}

strings["fr"] = {
    TITLE           = "Suivi des épreuves et arènes",
    TAB_TRIALS      = "Épreuves",
    TAB_ARENAS      = "Arènes",
    KB_PREV_TAB     = "Onglet préc.",
    KB_NEXT_TAB     = "Onglet suiv.",
    KB_SCROLL_UP    = "Défiler haut",
    KB_SCROLL_DOWN  = "Défiler bas",
    MENU_ENTRY      = "Suivi des épreuves et arènes",
    GROUP_CRAGLORN                  = "Raidelorn",
    GROUP_THIEVES_GUILD             = "Guilde des voleurs",
    GROUP_MORROWIND                 = "Morrowind",
    GROUP_CLOCKWORK_CITY            = "Cité mécanique",
    GROUP_SUMMERSET                 = "Summerset",
    GROUP_ELSWEYR                   = "Elsweyr",
    GROUP_GREYMOOR                  = "Greymoor",
    GROUP_BLACKWOOD                 = "Bois noir",
    GROUP_HIGH_ISLE                 = "Haute-Île",
    GROUP_NECROM                    = "Nécrom",
    GROUP_GOLD_ROAD                 = "Route dorée",
    GROUP_SEASONS_OF_THE_WORM_CULT  = "Saisons du culte du Ver",
    GROUP_ORSINIUM                  = "Orsinium",
    GROUP_MURKMIRE                  = "Fangeombre",
    GROUP_MARKARTH                  = "Markarth",
}

strings["ja"] = {
    TITLE           = "試練＆アリーナトラッカー",
    TAB_TRIALS      = "試練",
    TAB_ARENAS      = "アリーナ",
    KB_PREV_TAB     = "前のタブ",
    KB_NEXT_TAB     = "次のタブ",
    KB_SCROLL_UP    = "上スクロール",
    KB_SCROLL_DOWN  = "下スクロール",
    MENU_ENTRY      = "試練＆アリーナトラッカー",
    GROUP_CRAGLORN                  = "クラグローン",
    GROUP_THIEVES_GUILD             = "盗賊ギルド",
    GROUP_MORROWIND                 = "モロウウィンド",
    GROUP_CLOCKWORK_CITY            = "クロックワークシティ",
    GROUP_SUMMERSET                 = "サマーセット",
    GROUP_ELSWEYR                   = "エルスウェア",
    GROUP_GREYMOOR                  = "グレイムーア",
    GROUP_BLACKWOOD                 = "ブラックウッド",
    GROUP_HIGH_ISLE                 = "ハイ・アイル",
    GROUP_NECROM                    = "ネクロム",
    GROUP_GOLD_ROAD                 = "ゴールドロード",
    GROUP_SEASONS_OF_THE_WORM_CULT  = "蟲の教団の季節",
    GROUP_ORSINIUM                  = "オルシニウム",
    GROUP_MURKMIRE                  = "マークマイア",
    GROUP_MARKARTH                  = "マルカルス",
}

strings["zh"] = {
    TITLE           = "试炼和竞技场追踪器",
    TAB_TRIALS      = "试炼",
    TAB_ARENAS      = "竞技场",
    KB_PREV_TAB     = "上一页",
    KB_NEXT_TAB     = "下一页",
    KB_SCROLL_UP    = "向上滚动",
    KB_SCROLL_DOWN  = "向下滚动",
    MENU_ENTRY      = "试炼和竞技场追踪器",
    GROUP_CRAGLORN                  = "克拉格伦",
    GROUP_THIEVES_GUILD             = "盗贼公会",
    GROUP_MORROWIND                 = "晨风",
    GROUP_CLOCKWORK_CITY            = "发条城",
    GROUP_SUMMERSET                 = "夏暮岛",
    GROUP_ELSWEYR                   = "艾斯维尔",
    GROUP_GREYMOOR                  = "灰沼",
    GROUP_BLACKWOOD                 = "黑木",
    GROUP_HIGH_ISLE                 = "高岛",
    GROUP_NECROM                    = "奈克罗姆",
    GROUP_GOLD_ROAD                 = "黄金之路",
    GROUP_SEASONS_OF_THE_WORM_CULT  = "蠕虫教团之季",
    GROUP_ORSINIUM                  = "奥辛纽姆",
    GROUP_MURKMIRE                  = "黑沼",
    GROUP_MARKARTH                  = "马卡斯",
}

-- ---------------------------------------------------------------------------
-- Mapping from English group name -> translation key
-- ---------------------------------------------------------------------------
local groupKeyMap = {
    ["Craglorn"]                    = "GROUP_CRAGLORN",
    ["Thieves Guild"]               = "GROUP_THIEVES_GUILD",
    ["Morrowind"]                   = "GROUP_MORROWIND",
    ["Clockwork City"]              = "GROUP_CLOCKWORK_CITY",
    ["Summerset"]                   = "GROUP_SUMMERSET",
    ["Elsweyr"]                     = "GROUP_ELSWEYR",
    ["Greymoor"]                    = "GROUP_GREYMOOR",
    ["Blackwood"]                   = "GROUP_BLACKWOOD",
    ["High Isle"]                   = "GROUP_HIGH_ISLE",
    ["Necrom"]                      = "GROUP_NECROM",
    ["Gold Road"]                   = "GROUP_GOLD_ROAD",
    ["Seasons of the Worm Cult"]    = "GROUP_SEASONS_OF_THE_WORM_CULT",
    ["Orsinium"]                    = "GROUP_ORSINIUM",
    ["Murkmire"]                    = "GROUP_MURKMIRE",
    ["Markarth"]                    = "GROUP_MARKARTH",
}

-- ---------------------------------------------------------------------------
-- Content name translation tables  (English name -> localized name)
-- Sourced from official ESO community databases (eso-hub.com/de, dragonika.fr,
-- hilfe.elderscrollsonline.com, teso-legion.de, eso-database.com)
-- ---------------------------------------------------------------------------
local contentNames = {}

-- ── German (de) ─────────────────────────────────────────────────────────────
contentNames["de"] = {
    -- Trials
    ["Aetherian Archive"]    = "Ätherisches Archiv",
    ["Hel Ra Citadel"]       = "Zitadelle von Hel Ra",
    ["Sanctum Ophidia"]      = "Sanctum Ophidia",
    ["Maw of Lorkhaj"]       = "Schlund von Lorkhaj",
    ["Halls of Fabrication"] = "Hallen der Fertigung",
    ["Asylum Sanctorium"]    = "Anstalt Sanctorium",
    ["Cloudrest"]            = "Wolkenruh",
    ["Sunspire"]             = "Sonnspitz",
    ["Kyne's Aegis"]         = "Kynes Ägis",
    ["Rockgrove"]            = "Felshain",
    ["Dreadsail Reef"]       = "Grauenssegelriff",
    ["Sanity's Edge"]        = "Rand des Wahnsinns",
    ["Lucent Citadel"]       = "Luminit-Zitadelle",
    ["Ossein Cage"]          = "Gebeinkäfig",
    -- Arenas
    ["Dragonstar Arena"]     = "Drachenstern-Arena",
    ["Maelstrom Arena"]      = "Mahlstrom-Arena",
    ["Blackrose Prison"]     = "Schwarzrosengefängnis",
    ["Vateshran Hollows"]    = "Grund des Vateshran",
}

-- ── French (fr) ─────────────────────────────────────────────────────────────
contentNames["fr"] = {
    -- Trials
    ["Aetherian Archive"]    = "Archive æthérienne",
    ["Hel Ra Citadel"]       = "Citadelle d'Hel Ra",
    ["Sanctum Ophidia"]      = "Sanctum ophidia",
    ["Maw of Lorkhaj"]       = "Gueule de Lorkhaj",
    ["Halls of Fabrication"] = "Salles de la Fabrication",
    ["Asylum Sanctorium"]    = "Asile sanctuaire",
    ["Cloudrest"]            = "Pas-des-Nuées",
    ["Sunspire"]             = "Sollance",
    ["Kyne's Aegis"]         = "Égide de Kyne",
    ["Rockgrove"]            = "Rochebosque",
    ["Dreadsail Reef"]       = "Récif des Voiles funestes",
    ["Sanity's Edge"]        = "Bord de la Folie",
    ["Lucent Citadel"]       = "Citadelle lumineuse",
    ["Ossein Cage"]          = "Cage osseuse",
    -- Arenas
    ["Dragonstar Arena"]     = "Étoile du dragon",
    ["Maelstrom Arena"]      = "Maëlstrom",
    ["Blackrose Prison"]     = "Prison de la Rose noire",
    ["Vateshran Hollows"]    = "Ombres de Vateshran",
}

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

function TAT_Locale.Init()
    lang = GetCVar and GetCVar("language.2") or "en"
    if not strings[lang] then lang = "en" end
end

function TAT_Locale.RebuildNameMap()
    -- no-op: names are now hardcoded translation tables
end

function TAT_Locale.L(key)
    local tbl = strings[lang] or strings["en"]
    return tbl[key] or (strings["en"] and strings["en"][key]) or key
end

function TAT_Locale.GetLocalizedName(entry)
    if lang == "en" then return entry.name end

    local tbl = contentNames[lang]
    if tbl and tbl[entry.name] then
        return tbl[entry.name]
    end

    -- Fallback: English name
    return entry.name
end

function TAT_Locale.GetLocalizedGroup(englishGroupName)
    local key = groupKeyMap[englishGroupName]
    if key then
        return TAT_Locale.L(key)
    end
    return englishGroupName
end
