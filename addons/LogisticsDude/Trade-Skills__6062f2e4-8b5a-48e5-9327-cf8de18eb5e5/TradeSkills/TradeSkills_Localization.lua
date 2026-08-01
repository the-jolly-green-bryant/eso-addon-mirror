-- TradeSkills Localization
-- Covers all officially supported ESO languages: en, de, fr, ja, ru, es
-- Usage: TradeSkills.L["key"] returns the localized string for the current client language

TradeSkills = TradeSkills or {}
TradeSkills.L = {}

local lang = GetCVar("language.2") or "en"

-- =======================
-- MINING: Ore & Jewelry Dust Names
-- =======================
local MINING = {
    en = {
        "iron ore", "high iron ore", "orichalcum ore", "dwarven ore", "ebony ore",
        "calcinium ore", "galatite ore", "quicksilver ore", "voidstone ore", "rubedite ore",
        "pewter dust", "copper dust", "silver dust", "electrum dust", "platinum dust",
    },
    de = {
        "eisenerz", "stahleienerz", "orichalcumerz", "dwemerit", "ebenholzerz",
        "calciniumserz", "galatiterz", "quecksilbererz", "leersteinerz", "rubediterz",
        "zinnstaub", "kupferstaub", "silberstaub", "elektrumstaub", "platinstaub",
    },
    fr = {
        "minerai de fer", "minerai de fer noble", "minerai d'orichalque", "minerai dwemer", "minerai d'ébonite",
        "minerai de calcinium", "minerai de galatite", "minerai de vif-argent", "minerai de pierre du vide", "minerai de rubédite",
        "poussière d'étain", "poussière de cuivre", "poussière d'argent", "poussière d'électrum", "poussière de platine",
    },
    ja = {
        "鉄鉱石", "高鉄鉱石", "オリハルコン鉱石", "ドワーフ鉱石", "黒檀鉱石",
        "カルシニウム鉱石", "ガラタイト鉱石", "水銀鉱石", "虚無石鉱石", "ルベダイト鉱石",
        "ピューターの粉", "銅の粉", "銀の粉", "エレクトラムの粉", "プラチナの粉",
    },
    ru = {
        "железная руда", "руда высокого железа", "орихалковая руда", "двемерская руда", "эбонитовая руда",
        "кальциниевая руда", "галатитовая руда", "ртутная руда", "руда пустотного камня", "рубедитовая руда",
        "оловянная пыль", "медная пыль", "серебряная пыль", "электрумовая пыль", "платиновая пыль",
    },
    es = {
        "mineral de hierro", "mineral de hierro alto", "mineral de oricalco", "mineral enano", "mineral de ébano",
        "mineral de calcinio", "mineral de galatita", "mineral de mercurio", "mineral de piedravacía", "mineral de rubedita",
        "polvo de peltre", "polvo de cobre", "polvo de plata", "polvo de electro", "polvo de platino",
    },
}

-- =======================
-- HERBALISM: Reagent Names
-- =======================
local HERBALISM_REAGENTS = {
    en = {
        "beetle scuttle", "blessed thistle", "blue entoloma", "bugloss", "butterfly wing",
        "chaurus egg", "clam gall", "columbine", "corn flower",
        "crimson nirnroot", "dragon rheum", "dragon's bile", "dragon's blood",
        "dragonthorn", "emetic russula", "fleshfly larva", "imp stool", "lady's smock",
        "lorkhan's tears", "luminous russula",
        "mountain flower", "namira's rot", "nightshade", "nirnroot",
        "powdered mother of pearl", "scrib jelly", "stinkhorn", "torchbug thorax",
        "vile coagulant", "violet coprinus", "water hyacinth", "white cap", "wormwood",
    },
    de = {
        "käferpanzer", "gesegnete distel", "blauer entolom", "wolfsauge", "schmetterlingsflügel",
        "chaurusei", "muschelgalle", "akelei", "kornblume",
        "karmesin-nirnwurz", "drachenrhabarber", "drachengalle", "drachenblut",
        "drachendorn", "brech-täubling", "schmeißfliegenlarve", "koboldhocker", "wiesenschaumkraut",
        "lorkhans tränen", "leucht-täubling",
        "bergblume", "namiras fäulnis", "nachtschatten", "nirnwurz",
        "perlmuttpulver", "skribgelee", "stinkmorchel", "fackelbugbrustpanzer",
        "widerliches gerinnsel", "violetter tintling", "wasserhyazinthe", "weißkappe", "wermut",
    },
    fr = {
        "élytres de scarabée", "chardon béni", "entolome bleu", "buglosse", "aile de papillon",
        "œuf de chaurus", "bile de palourde", "ancolie", "bleuet",
        "nirnrave carmin", "rhubarbe-dragon", "bile de dragon", "sang de dragon",
        "épine-de-dragon", "russule émétique", "larve de mouche à viande", "tabouret du lutin", "cardamine des prés",
        "larmes de lorkhan", "russule lumineuse",
        "fleur de montagne", "pourriture de namira", "morelle noire", "nirnrave",
        "nacre en poudre", "gelée de scrib", "satyre puant", "thorax de luciole",
        "vil coagulant", "coprin violet", "jacinthe d'eau", "chapeau blanc", "absinthe",
    },
    ja = {
        "甲虫の甲殻", "祝福アザミ", "ブルーエントローマ", "バグロス", "蝶の翅",
        "シャウルスの卵", "貝の胆汁", "オダマキ", "ヤグルマギク",
        "クリムゾンニルンルート", "ドラゴンルバーブ", "ドラゴンの胆汁", "ドラゴンの血",
        "ドラゴンソーン", "ドクベニタケ", "ニクバエの幼虫", "インプスツール", "レディスモック",
        "ロルカーンの涙", "ヒカリベニタケ",
        "マウンテンフラワー", "ナミラの腐敗", "ナイトシェード", "ニルンルート",
        "真珠母の粉末", "スクリブゼリー", "スッポンタケ", "トーチバグの胸部",
        "忌まわしい凝血剤", "ムラサキヒトヨタケ", "ウォーターヒヤシンス", "ホワイトキャップ", "ニガヨモギ",
    },
    ru = {
        "жучиный панцирь", "благословенный чертополох", "голубая энтолома", "воловик", "крыло бабочки",
        "яйцо хоруса", "моллюсковая желчь", "водосбор", "василёк",
        "багряный корень нирна", "драконий ревень", "драконья желчь", "драконья кровь",
        "драконий шип", "рвотная сыроежка", "личинка мясной мухи", "бесовский табурет", "сердечник луговой",
        "слёзы лорхана", "светящаяся сыроежка",
        "горный цветок", "гниль намиры", "паслён", "корень нирна",
        "перламутровый порошок", "скрибовое желе", "весёлка", "торакс факельного жука",
        "мерзкий коагулянт", "фиолетовый копринус", "водяной гиацинт", "белянка", "полынь",
    },
    es = {
        "caparazón de escarabajo", "cardo bendito", "entoloma azul", "buglosa", "ala de mariposa",
        "huevo de chaurus", "hiel de almeja", "aguileña", "aciano",
        "raíz de nirn carmesí", "ruibarbo de dragón", "bilis de dragón", "sangre de dragón",
        "espina de dragón", "rúsula emética", "larva de moscarda", "taburete de duende", "cardamina",
        "lágrimas de lorkhan", "rúsula luminosa",
        "flor de montaña", "podredumbre de namira", "belladona", "raíz de nirn",
        "madreperla en polvo", "jalea de escrib", "falo hediondo", "tórax de luciérnaga",
        "vil coagulante", "coprino violeta", "jacinto de agua", "seta blanca", "ajenjo",
    },
}

-- =======================
-- HERBALISM: Raw Fiber Names (Clothier plants)
-- =======================
local HERBALISM_FIBERS = {
    en = {
        "raw jute", "raw flax", "raw cotton", "raw spidersilk", "raw ebonthread",
        "raw kreshweed", "raw silverweed", "raw void bloom", "raw ancestor silk",
    },
    de = {
        "rohjute", "rohflachs", "rohbaumwolle", "rohspinnenseide", "rohebenholzfaden",
        "rohkreshkraut", "rohsilberkraut", "rohleerblüte", "rohahnenseide",
    },
    fr = {
        "jute brut", "lin brut", "coton brut", "soie d'araignée brute", "fil d'ébène brut",
        "kreshweed brut", "argentine brute", "fleur du vide brute", "soie ancestrale brute",
    },
    ja = {
        "ジュートの原料", "亜麻の原料", "綿の原料", "蜘蛛の糸の原料", "黒檀糸の原料",
        "クレッシュの原料", "銀草の原料", "虚無の花の原料", "先祖シルクの原料",
    },
    ru = {
        "джутовое волокно", "льняное волокно", "хлопковое волокно", "сырой паучий шёлк", "сырая эбонитовая нить",
        "сырой крешьян", "сырое серебрянолистое волокно", "сырой пустоцвет", "шёлк предков",
    },
    es = {
        "yute en bruto", "lino en bruto", "algodón en bruto", "seda de araña en bruto", "hilo de ébano en bruto",
        "hierba kresh en bruto", "argentaria en bruto", "flor del vacío en bruto", "seda ancestral en bruto",
    },
}

-- =======================
-- SKINNING: Hide/Scrap Names (partial match keywords)
-- =======================
local SKINNING = {
    en = {
        "rawhide", "hide scraps", "leather scraps", "thick leather", "fell hide",
        "topgrain hide", "iron hide", "superb hide", "shadowhide", "rubedo hide",
    },
    de = {
        "rohleder", "lederfetzen", "lederschnipsel", "dickleder", "fellhaut",
        "feinnarbenleder", "eisenhaut", "edles leder", "schattenleder", "rubedoleder",
    },
    fr = {
        "cuir brut", "chutes de cuir", "morceaux de cuir", "cuir épais", "cuir de fell",
        "cuir pleine fleur", "cuir de fer", "cuir superbe", "cuir d'ombre", "cuir rubédo",
    },
    ja = {
        "生皮", "皮の端切れ", "なめし革の端切れ", "厚革", "フェルハイド",
        "トップグレインハイド", "アイアンハイド", "極上ハイド", "シャドウハイド", "ルベドハイド",
    },
    ru = {
        "сыромятная кожа", "обрезки кожи", "кожаные обрезки", "толстая кожа", "шкура фелла",
        "мягкая кожа", "железная шкура", "превосходная кожа", "теневая кожа", "кожа рубедо",
    },
    es = {
        "cuero crudo", "restos de cuero", "trozos de cuero", "cuero grueso", "cuero de fell",
        "cuero curtido", "cuero de hierro", "cuero excelso", "cuero de sombra", "cuero de rubedo",
    },
}

-- =======================
-- FISHING: Water Type Keywords (found in fishing hole names)
-- =======================
local WATER_TYPES = {
    en = { ["foul"] = "foul", ["oily"] = "foul", ["river"] = "river", ["lake"] = "lake", ["saltwater"] = "saltwater", ["ocean"] = "saltwater", ["mystic"] = "saltwater" },
    de = { ["faulig"] = "foul", ["ölig"] = "foul", ["fluss"] = "river", ["see"] = "lake", ["salzwasser"] = "saltwater", ["ozean"] = "saltwater", ["mystisch"] = "saltwater" },
    fr = { ["fétide"] = "foul", ["huileu"] = "foul", ["rivière"] = "river", ["lac"] = "lake", ["eau salée"] = "saltwater", ["océan"] = "saltwater", ["mystique"] = "saltwater" },
    ja = { ["汚水"] = "foul", ["油"] = "foul", ["川"] = "river", ["湖"] = "lake", ["海水"] = "saltwater", ["海"] = "saltwater", ["神秘"] = "saltwater" },
    ru = { ["гнил"] = "foul", ["масл"] = "foul", ["реч"] = "river", ["озер"] = "lake", ["солен"] = "saltwater", ["океан"] = "saltwater", ["мисти"] = "saltwater" },
    es = { ["fétid"] = "foul", ["aceit"] = "foul", ["río"] = "river", ["lago"] = "lake", ["salad"] = "saltwater", ["océano"] = "saltwater", ["místic"] = "saltwater" },
}

-- =======================
-- FISHING: Bait Names
-- =======================
local BAIT_NAMES = {
    en = { foul = {"Fish Roe", "Crawlers"},       river = {"Shad", "Insect Parts"},   lake = {"Minnow", "Guts"},       saltwater = {"Chub", "Worms"} },
    de = { foul = {"Fischrogen", "Krabbler"},      river = {"Maifisch", "Insektenteile"}, lake = {"Elritze", "Innereien"}, saltwater = {"Döbel", "Würmer"} },
    fr = { foul = {"Œufs de poisson", "Rampants"}, river = {"Alose", "Morceaux d'insecte"}, lake = {"Vairon", "Entrailles"}, saltwater = {"Chevesne", "Vers"} },
    ja = { foul = {"魚卵", "這う虫"},               river = {"シャッド", "昆虫の部位"},   lake = {"ミノー", "臓物"},       saltwater = {"チャブ", "ミミズ"} },
    ru = { foul = {"Рыбья икра", "Ползуны"},       river = {"Шэд", "Части насекомых"}, lake = {"Гольян", "Потроха"},     saltwater = {"Голавль", "Черви"} },
    es = { foul = {"Huevas de pescado", "Lombrices"}, river = {"Sábalo", "Partes de insecto"}, lake = {"Piscardo", "Tripas"}, saltwater = {"Cacho", "Gusanos"} },
}

-- =======================
-- FISHING: Angler achievement keyword & fish boon
-- =======================
local ANGLER_KEYWORDS = {
    en = { angler = "angler", fish_boon = "fish boon", strangler = "strangler" },
    de = { angler = "angler", fish_boon = "fischsegen", strangler = "würger" },
    fr = { angler = "pêcheur", fish_boon = "aubaine .* poisson", strangler = "étrangleur" },
    ja = { angler = "釣り師", fish_boon = "魚の恩恵", strangler = "ストラングラー" },
    ru = { angler = "рыболов", fish_boon = "рыбное благо", strangler = "душитель" },
    es = { angler = "pescador", fish_boon = "don de pesca", strangler = "estrangulador" },
}

-- =======================
-- HERBALISM: Columbine (for Scent of the Wild passive)
-- =======================
local COLUMBINE = {
    en = "columbine",
    de = "akelei",
    fr = "ancolie",
    ja = "オダマキ",
    ru = "водосбор",
    es = "aguileña",
}

-- =======================
-- SKINNING: Loot Filter Keywords (items to exclude from Anatomy Specialist)
-- =======================
local LOOT_FILTER = {
    en = {
        "potion", "poison", "scraps", "scrap", "glyph", "gold",
        "sword", "axe", "mace", "maul", "dagger", "greatsword", "battle axe",
        "staff", "bow", "shield", "helm", "jack", "robe", "guard", "boots",
        "gauntlet", "sabatons", "greaves", "pauldron", "cuirass", "girdle",
        "sash", "epaulet", "breeches", "shoes", "gloves", "hat", "arm cops",
        "bracers", "ring", "necklace", "amulet",
    },
    de = {
        "trank", "gift", "fetzen", "glyphe", "gold",
        "schwert", "axt", "keule", "streitkolben", "dolch", "großschwert", "streitaxt",
        "stab", "bogen", "schild", "helm", "wams", "robe", "schutz", "stiefel",
        "handschuhe", "beinschienen", "schulterstücke", "harnisch", "gürtel",
        "schärpe", "hose", "schuhe", "hut", "armschienen",
        "ring", "halskette", "amulett",
    },
    fr = {
        "potion", "poison", "chutes", "chute", "glyphe", "or",
        "épée", "hache", "masse", "maillet", "dague", "espadon", "hache de guerre",
        "bâton", "arc", "bouclier", "heaume", "pourpoint", "robe", "garde", "bottes",
        "gantelets", "grèves", "spallières", "cuirasse", "ceinture",
        "écharpe", "braies", "chaussures", "chapeau", "brassards",
        "anneau", "collier", "amulette",
    },
    ja = {
        "ポーション", "毒", "端切れ", "グリフ", "ゴールド",
        "剣", "斧", "メイス", "モール", "短剣", "大剣", "戦斧",
        "杖", "弓", "盾", "兜", "ジャック", "ローブ", "ガード", "ブーツ",
        "篭手", "脛当て", "肩当て", "胸当て", "帯",
        "飾り帯", "脚衣", "靴", "帽子", "腕甲",
        "指輪", "首飾り", "アミュレット",
    },
    ru = {
        "зелье", "яд", "обрезки", "обрезк", "глиф", "золот",
        "меч", "топор", "булава", "молот", "кинжал", "двуручный меч", "секира",
        "посох", "лук", "щит", "шлем", "куртка", "мантия", "наручи", "сапоги",
        "перчатки", "поножи", "наплечники", "кираса", "пояс",
        "кушак", "штаны", "башмаки", "шляпа", "наручники",
        "кольцо", "ожерелье", "амулет",
    },
    es = {
        "poción", "veneno", "restos", "resto", "glifo", "oro",
        "espada", "hacha", "maza", "mazo", "daga", "mandoble", "hacha de batalla",
        "bastón", "arco", "escudo", "yelmo", "jubón", "túnica", "guarda", "botas",
        "guanteletes", "grebas", "hombreras", "coraza", "fajín",
        "faja", "calzas", "zapatos", "sombrero", "brazales",
        "anillo", "collar", "amuleto",
    },
}

-- =======================
-- STAT NAMES (for food/drink stat detection)
-- =======================
local STAT_NAMES = {
    en = { health = "health", magicka = "magicka", stamina = "stamina" },
    de = { health = "leben", magicka = "magicka", stamina = "ausdauer" },
    fr = { health = "vie", magicka = "magicka", stamina = "endurance" },
    ja = { health = "体力", magicka = "マジカ", stamina = "スタミナ" },
    ru = { health = "здоровь", magicka = "магии", stamina = "запас сил" },
    es = { health = "salud", magicka = "magicka", stamina = "aguante" },
}

-- =======================
-- FLORA ID: Potion/Poison category labels
-- =======================
local FLORA_LABELS = {
    en = { potions = "Potions", poisons = "Poisons", flora_id = "Flora ID" },
    de = { potions = "Tränke", poisons = "Gifte", flora_id = "Flora ID" },
    fr = { potions = "Potions", poisons = "Poisons", flora_id = "Flora ID" },
    ja = { potions = "ポーション", poisons = "毒", flora_id = "フローラID" },
    ru = { potions = "Зелья", poisons = "Яды", flora_id = "Флора" },
    es = { potions = "Pociones", poisons = "Venenos", flora_id = "Flora ID" },
}

-- =======================
-- BUILD LOOKUP TABLES FOR CURRENT LANGUAGE
-- =======================

-- Helper: build a set from an array (lowercase keys -> true)
local function BuildSet(arr)
    local set = {}
    if arr then
        for _, v in ipairs(arr) do
            set[string.lower(v)] = true
        end
    end
    return set
end

-- Helper: fall back to English if language not found
local function GetLang(tbl)
    return tbl[lang] or tbl["en"]
end

-- Mining whitelist (exact match set)
TradeSkills.L.MiningWhitelist = BuildSet(GetLang(MINING))

-- Herbalism reagent whitelist (exact match set)
TradeSkills.L.HerbalismReagents = BuildSet(GetLang(HERBALISM_REAGENTS))

-- Herbalism fiber whitelist (exact match set)
TradeSkills.L.HerbalismFibers = BuildSet(GetLang(HERBALISM_FIBERS))

-- Combined herbalism whitelist (reagents + fibers)
TradeSkills.L.HerbalismWhitelist = {}
for k, v in pairs(TradeSkills.L.HerbalismReagents) do TradeSkills.L.HerbalismWhitelist[k] = v end
for k, v in pairs(TradeSkills.L.HerbalismFibers) do TradeSkills.L.HerbalismWhitelist[k] = v end

-- Skinning keywords (partial match list)
TradeSkills.L.SkinningKeywords = GetLang(SKINNING)

-- Fishing water type map
TradeSkills.L.WaterTypes = GetLang(WATER_TYPES)

-- Fishing bait priority
TradeSkills.L.BaitPriority = GetLang(BAIT_NAMES)

-- Angler keywords
TradeSkills.L.AnglerKeywords = GetLang(ANGLER_KEYWORDS)

-- Columbine name
TradeSkills.L.Columbine = string.lower(COLUMBINE[lang] or COLUMBINE["en"])

-- Loot filter keywords (partial match array)
TradeSkills.L.LootFilter = {}
local filterLang = GetLang(LOOT_FILTER)
for _, val in ipairs(filterLang) do
    table.insert(TradeSkills.L.LootFilter, string.lower(val))
end

-- Stat names for food/drink detection
TradeSkills.L.Stats = GetLang(STAT_NAMES)

-- Flora ID labels
TradeSkills.L.FloraLabels = GetLang(FLORA_LABELS)

-- Flora ID reagent-to-potion data keys need to match localized names
-- Build a mapping from localized reagent name -> English reagent name
-- so FLORA_POTION_DATA (keyed in English) can be looked up by localized name
TradeSkills.L.ReagentToEnglish = {}
if lang ~= "en" then
    local enList = HERBALISM_REAGENTS["en"]
    local localList = GetLang(HERBALISM_REAGENTS)
    for i, localName in ipairs(localList) do
        if enList[i] then
            TradeSkills.L.ReagentToEnglish[string.lower(localName)] = string.lower(enList[i])
        end
    end
end
