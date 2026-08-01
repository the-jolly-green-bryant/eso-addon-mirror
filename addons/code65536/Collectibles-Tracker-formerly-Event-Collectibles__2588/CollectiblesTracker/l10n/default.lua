local Register = LibCodesCommonCode.RegisterString

Register("SI_COLLECTIBLESTRACKER_TITLE"            , "Collectibles Tracker")
Register("SI_EVENTCOLLECTIBLES_TITLE"              , "Event Collectibles")

Register("SI_COLLECTIBLESTRACKER_HEADER_NAME"      , "Name")
Register("SI_COLLECTIBLESTRACKER_HEADER_STATUS"    , "Collected")
Register("SI_COLLECTIBLESTRACKER_HEADER_CATEGORY"  , "Category")
Register("SI_COLLECTIBLESTRACKER_HEADER_SOURCE"    , "Source")

Register("SI_COLLECTIBLESTRACKER_SHOW_HIDDEN"      , "Show <<1>> hidden")
Register("SI_COLLECTIBLESTRACKER_HIDE0"            , GetString(SI_OUTFIT_SLOT_HIDE_ACTION))
Register("SI_COLLECTIBLESTRACKER_HIDE1"            , "Unhide")

Register("SI_COLLECTIBLESTRACKER_COLLECTED_COUNT"  , "%d / %d collected (%d%%)")

Register("SI_EVENTCOLLECTIBLES_CAKE"               , "Cake")

Register("SI_COLLECTIBLESTRACKER_SOURCE_ALL"       , GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ALL))
Register("SI_COLLECTIBLESTRACKER_SOURCE_UNDAUNTED" , "Undaunted Styles")

Register("SI_EVENTCOLLECTIBLES_SOURCE_MORPHS"      , "Event Morphs: <<1>>")


-- Extracted

local EXTRACTED = {
	["76200101-0-19"] = { default = "Stablemaster", de = "Stallmeister", es = "Jefe de establo", fr = "Maître des écuries", jp = "馬屋の親方", ru = "Хозяин конюшни", zh = "马厩主" },
	["125518133-0-956"] = { default = "Season <<1>>", de = "Saison <<1>>", es = "Temporada <<1>>", fr = "Saison <<1>>", jp = "シーズン <<1>>", ru = "Сезон <<1>>", zh = "季节 <<1>>" },

	["99281989-0-15"] = { default = "Murkmire Celebration", de = "„Murkmire“-Feierlichkeiten", es = "Aniversario de Lodazal Lóbrego", fr = "Festivités de Tourbevase", jp = "マークマイアの祝典", ru = "праздник «Мрачных Трясин»", zh = "幽暗沼泽庆典" },
	["99281989-0-23"] = { default = "Undaunted Celebration", de = "Unerschrockenen-Feierlichkeiten", es = "Fiestas Intrépidas", fr = "Anniversaire Indomptable", jp = "アンドーンテッドの祝典", ru = "праздник Неустрашимых", zh = "无畏者庆典" },
	["99281989-0-27"] = { default = "Year One Celebration", de = "Feierlichkeiten zum ersten Jahr", es = "Celebración del Primer Año", fr = "Premier anniversaire", jp = "一周年の祝典", ru = "празднование первого года", zh = "首年庆典" },
	["99281989-0-30"] = { default = "Daedric War Celebration", de = "Feierlichkeiten des daedrischen Krieges", es = "Celebración de la Guerra Daédrica", fr = "Célébration de la guerre daedrique", jp = "デイドラの軍事式典", ru = "праздник войны с даэдра", zh = "魔族战争庆典" },
	["99281989-0-31"] = { default = "Zeal of Zenithar", de = "Zenithars Eifer", es = "Fervor de Zenithar", fr = "Zèle de Zénithar", jp = "ゼニタールの信仰", ru = "Почитание Зенитара", zh = "泽尼萨尔的热忱" },
	["99281989-0-38"] = { default = "Season of the Dragon", de = "Saison des Drachen", es = "Temporada del Dragón", fr = "Saison du dragon", jp = "ドラゴンの季節", ru = "Сезон дракона", zh = "龙之季节" },
	["99281989-0-39"] = { default = "Dark Heart of Skyrim", de = "Schwarzes Herz von Skyrim", es = "Corazón Oscuro de Skyrim", fr = "Cœur noir de Skyrim", jp = "スカイリムの闇の中心", ru = "Темное сердце Скайрима", zh = "天际的黑暗之心" },
	["99281989-0-43"] = { default = "Secrets of the Telvanni", de = "Geheimnisse der Telvanni", es = "Secretos de los Telvanni", fr = "Secrets des Telvanni", jp = "テルヴァンニの秘密", ru = "Тайны Телванни", zh = "泰尔瓦尼的秘密" },
	["99281989-0-46"] = { default = "Gates of Oblivion", de = "Tore von Oblivion", es = "Puertas de Oblivion", fr = "Portes d'Oblivion", jp = "オブリビオンの門", ru = "Врата Обливиона", zh = "湮灭之门" },
	["99281989-0-47"] = { default = "Guilds and Glory", de = "Guilds and Glory", es = "Guilds and Glory", fr = "Guildes et Gloire", jp = "ギルドと栄光", ru = "Гильдии и слава", zh = "公会荣耀" },
	["99281989-0-51"] = { default = "Fallen Leaves of West Weald", de = "Gefallene Blätter der Westauen", es = "Hojas caídas del Bosque Occidental", fr = "Les feuilles mortes du Weald Occidental", jp = "ウェストウィールドの落ち葉", ru = "Опавшие листья Западного вельда", zh = "西威尔德的落叶" },
	["99281989-0-52"] = { default = "Legacy of the Bretons", de = "Vermächtnis der Bretonen", es = "Legado de los Bretones", fr = "L'Héritage des Brétons", jp = "ブレトンの伝統", ru = "Бретонское наследие", zh = "布莱顿人不朽神话" },
	["99281989-0-53"] = { default = "Pan-Tamriel Celebration", de = "Feierlichkeiten in ganz Tamriel", es = "Celebración pantamriélica", fr = "Festivités Pan-Tamriéliques", jp = "汎タムリエルの祝典", ru = "праздник Тамриэля", zh = "泛泰姆瑞尔庆典" },
}

local GetLocalizedData = LibCodesCommonCode.GetLocalizedData
local Localize = function( key )
	return GetLocalizedData(EXTRACTED[key])
end

Register("SI_COLLECTIBLESTRACKER_SOURCE_STABLES"   , Localize("76200101-0-19"))
Register("SI_COLLECTIBLESTRACKER_SOURCE_SEASON"    , Localize("125518133-0-956"))

Register("SI_EVENTCOLLECTIBLES_SOURCE_MURKMIRE"    , Localize("99281989-0-15"))
Register("SI_EVENTCOLLECTIBLES_SOURCE_UNDAUNTED"   , Localize("99281989-0-23"))
Register("SI_EVENTCOLLECTIBLES_SOURCE_YEAR_ONE"    , Localize("99281989-0-27"))
Register("SI_EVENTCOLLECTIBLES_SOURCE_DAEDRIC_WAR" , Localize("99281989-0-30"))
Register("SI_EVENTCOLLECTIBLES_SOURCE_ZENITHAR"    , Localize("99281989-0-31"))
Register("SI_EVENTCOLLECTIBLES_SOURCE_DRAGON"      , Localize("99281989-0-38"))
Register("SI_EVENTCOLLECTIBLES_SOURCE_DARK_SKYRIM" , Localize("99281989-0-39"))
Register("SI_EVENTCOLLECTIBLES_SOURCE_TELVANNI"    , Localize("99281989-0-43"))
Register("SI_EVENTCOLLECTIBLES_SOURCE_OBLIVION"    , Localize("99281989-0-46"))
Register("SI_EVENTCOLLECTIBLES_SOURCE_GUILDS"      , Localize("99281989-0-47"))
Register("SI_EVENTCOLLECTIBLES_SOURCE_WEST_WEALD"  , Localize("99281989-0-51"))
Register("SI_EVENTCOLLECTIBLES_SOURCE_BRETON"      , Localize("99281989-0-52"))
Register("SI_EVENTCOLLECTIBLES_SOURCE_PANTAM"      , Localize("99281989-0-53"))
