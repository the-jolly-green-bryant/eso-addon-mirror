local NAME = 'AltBossBar'
local SV_VER = 3

local SETTINGS

local ICONSIZE = ZO_COMPASS_FRAME_HEIGHT_KEYBOARD-8
local ABB_TEMPLATE_NAME = "ABB_BossBar_Emb"
local FN_ABB_GET_WIDTH = nil

local THEME_OFFSET = 0

local OVERSHIELD_COLOR_START = ZO_ColorDef:New("392952")
local OVERSHIELD_COLOR_END = ZO_ColorDef:New("968498")
local UNWAVERING_COLOR_START = ZO_ColorDef:New("7D7750")
local UNWAVERING_COLOR_END = ZO_ColorDef:New("DDDDCB")

local OVERSHIELD_GRADIENT = { OVERSHIELD_COLOR_START, OVERSHIELD_COLOR_END }
local UNWAVERING_GRADIENT = { UNWAVERING_COLOR_START, UNWAVERING_COLOR_END }

-- equal to ZO_POWER_BAR_GRADIENT_COLORS[COMBAT_MECHANIC_FLAGS_HEALTH]
local DEFAULT_HP_COLOR_START = { 0.447, 0.137, 0.137 }
local DEFAULT_HP_COLOR_END = { 0.855, 0.188, 0.188 }

local THEMES = {
    ["Plain"] = {
        template = "ABB_BossBar",
        calcWidth = function() return GuiRoot:GetWidth() * 0.35 end
    },
    ["Embellished"] = {
        template = "ABB_BossBar_Emb",
        calcWidth = function() return GuiRoot:GetWidth() * 0.35 - 20 end
    }
}

local StupidBossNamesInsteadOfId = {
    -- TRIALS --
    -- Hel Ra Citadel
    ["Ra Kotu"] = { 35 }, ["Ра-Коту"] = { 35 }, ["ラ・コツ"] = { 35 }, ["拉·阔图"] = { 35 },
    ["The Warrior"] = { 35 }, ["Krieger"] = { 35 }, ["Le Guerrier"] = { 35 }, ["Воин"] = { 35 }, ["El Guerrero"] = { 35 }, ["戦士"] = { 35 }, ["战士星"] = { 35 },
    ["Yokeda Kai"] = { 30 }, ["Le Yokeda Kai"] = { 30 }, ["Йокеда Кай"] = { 30 }, ["ヨケダ・カイ"] = { 30 }, ["尤可达·凯"] = { 30 },

    -- Sanctum Ophidia
    ["Stonebreaker"] = { 75, 50, 25 }, ["Steinbrecher"] = { 75, 50, 25 }, ["Briseroc"] = { 75, 50, 25 }, ["Камнелом"] = { 75, 50, 25 }, ["Rompepiedras"] = { 75, 50, 25 }, ["ストーンブレイカー"] = { 75, 50, 25 }, ["碎石者"] = { 75, 50, 25 },

    -- Aetherian Archive
    ["Foundation Stone Atronach"] = { 75, 25 }, ["Grundsteinatronach"] = { 75, 25 }, ["Atronach de pierre des fondationsm"] = { 75, 25 }, ["Древний каменный атронах"] = { 75, 25 }, ["Atronach de piedra base"] = { 75, 25 }, ["礎石の精霊"] = { 75, 25 }, ["石头侍灵基座"] = { 75, 25 },
    ["The Mage"] = { 16 }, ["Magierin"] = { 16 }, ["La Mage"] = { 16 }, ["Маг"] = { 16 }, ["La Maga"] = { 16 }, ["魔術師"] = { 16 }, ["法师星"] = { 16 },

    -- Maw of Lorkhaj
    ["Zhaj'hassa the Forgotten"] = { 70, 30 }, ["Zhaj'hassa der Vergessene"] = { 70, 30 }, ["Zhaj'hassa l'Oublié"] = { 70, 30 }, ["Задж'хасса Забытый"] = { 70, 30 }, ["Zhaj'hassa el Olvidado"] = { 70, 30 }, ["忘れ去られたザジュハッサ"] = { 70, 30 }, ["遗忘者扎哈撒"] = { 70, 30 },

    -- Halls of Fabrication
    ["Hunter-Killer Negatrix"] = { 30 }, ["Abfänger Negatrix"] = { 30 }, ["Chasseur-tueur négatrix"] = { 30 }, ["Охотник-убийца Негатрикс"] = { 30 }, ["El cazador asesino Negatrix"] = { 30 }, ["ハンターキラー・ネガトリクス"] = { 30 }, ["猎杀者聂佳特里克斯"] = { 30 },
    ["Hunter-Killer Positrox"] = { 30 }, ["Abfänger Positrox"] = { 30 }, ["Chasseur-tueur positrox"] = { 30 }, ["Охотник-убийца Позитрокс"] = { 30 }, ["El cazador asesino Positrox"] = { 30 }, ["ハンターキラー・ポジトロクス"] = { 30 }, ["猎杀者博西特洛克斯"] = { 30 },
    ["Pinnacle Factotum"] = { 80, 60, 40, 20 }, ["Perfektioniertes Faktotum"] = { 80, 60, 40, 20 }, ["Factotum du pinacle"] = { 80, 60, 40, 20 }, ["Высший фактотум"] = { 80, 60, 40, 20 }, ["Factótum del pináculo"] = { 80, 60, 40, 20 }, ["ピナクル・ファクトタム"] = { 80, 60, 40, 20 }, ["巅峰机械人"] = { 80, 60, 40, 20 },
    ["Reactor"] = { 70, 40, 20 }, ["Reaktor"] = { 70, 40, 20 }, ["Réacteur"] = { 70, 40, 20 }, ["Реактор"] = { 70, 40, 20 }, ["リアクター"] = { 70, 40, 20 }, ["反应器人"] = { 70, 40, 20 },
    ["Reducer"] = { 70, 40, 20 }, ["Minderer"] = { 70, 40, 20 }, ["Réducteur"] = { 70, 40, 20 }, ["Редуктор"] = { 70, 40, 20 }, ["リデューサー"] = { 70, 40, 20 }, ["减速器人"] = { 70, 40, 20 },
    ["Reclaimer"] = { 70, 40, 20 }, ["Rückforderer"] = { 70, 40, 20 }, ["Récupérateur"] = { 70, 40, 20 }, ["Регенератор"] = { 70, 40, 20 }, ["Reinvindicador"] = { 70, 40, 20 }, ["リクライマー"] = { 70, 40, 20 }, ["采集器人"] = { 70, 40, 20 },
    ["Assembly General"] = { 85, 65, 45, 25 }, ["Montagegeneral"] = { 85, 65, 45, 25 }, ["Assembleur général"] = { 85, 65, 45, 25 }, ["Мастер сборки"] = { 85, 65, 45, 25 }, ["Ensamblador general"] = { 85, 65, 45, 25 }, ["アセンブリ・ジェネラル"] = { 85, 65, 45, 25 }, ["组装将军"] = { 85, 65, 45, 25 },

    -- Asylum Sanctorium
    ["Saint Olms the Just"] = { 90, 75, 50, 25 }, ["Heiliger Olms der Gerechte"] = { 90, 75, 50, 25 }, ["Saint Olms le Juste"] = { 90, 75, 50, 25 }, ["Святой Олмс Справедливый"] = { 90, 75, 50, 25 }, ["San Olms el Justo"] = { 90, 75, 50, 25 }, ["公正なる聖オルムス"] = { 90, 75, 50, 25 }, ["公正圣徒奥尔姆斯"] = { 90, 75, 50, 25 },

    -- Cloudrest
    ["Z'Maja"] = { 75, 50, 40, 25, 5 }, ["З'Маджа"] = { 75, 50, 40, 25, 5 }, ["ズマジャ"] = { 75, 50, 40, 25, 5 }, ["泽玛亚"] = { 75, 50, 40, 25, 5 },

    -- Sunspire
    ["Lokkestiiz"] = { 80, 50, 20 }, ["Локкестиз"] = { 80, 50, 20 }, ["ロクケスティーズ"] = { 80, 50, 20 }, ["洛克提兹"] = { 80, 50, 20 },
    ["Yolnahkriin"] = { 75, 50, 25 }, ["Йолнакрин"] = { 75, 50, 25 }, ["ヨルナークリン"] = { 75, 50, 25 }, ["尤尔纳克林"] = { 75, 50, 25 },
    ["Nahviintaas"] = { 80, 60, 40 }, ["Навинтас"] = { 80, 60, 40 }, ["ナーヴィンタース"] = { 80, 60, 40 }, ["纳温塔丝"] = { 80, 60, 40 },

    -- Kyne’s Aegis
    ["Yandir the Butcher"] = { 50 }, ["Yandir der Ausweider"] = { 50 }, ["Yandir le boucher"] = { 50 }, ["Яндир Мясник"] = { 50 }, ["Yandir el Matarife"] = { 50 }, ["肉削ぎヤンディル"] = { 50 }, ["屠夫扬迪尔"] = { 50 },
    ["Captain Vrol"] = { 50 }, ["Kapitän Vrol"] = { 50 }, ["Le capitaine Vrol"] = { 50 }, ["Капитан Врол"] = { 50 }, ["Capitán Vrol"] = { 50 }, ["ヴロル隊長"] = { 50 }, ["威若船长"] = { 50 },
    ["Lord Falgravn"] = { 90, 80, 70, 35 }, ["Fürst Falgravn"] = { 90, 80, 70, 35 }, ["Le seigneur Falgravn"] = { 90, 80, 70, 35 }, ["Лорд Фальгравн"] = { 90, 80, 70, 35 }, ["ファルグラヴン卿"] = { 90, 80, 70, 35 }, ["法尔格拉文领主"] = { 90, 80, 70, 35 },

    -- Rockgrove
    ["Oaxiltso"] = { 90, 75, 50, 20 }, ["Оазилцо"] = { 90, 75, 50, 20 }, ["オアジルツォ"] = { 90, 75, 50, 20 }, ["奥西索"] = { 90, 75, 50, 20 },
    ["Flame-Herald Bahsei"] = { 90, 85, 80, 75, 70, 65, 60, 50, 40, 25, 20, 10 }, ["Flammenheroldin Bahsei"] = { 90, 85, 80, 75, 70, 65, 60, 50, 40, 25, 20, 10 }, ["La Héraut des flammes Bahsei"] = { 90, 85, 80, 75, 70, 65, 60, 50, 40, 25, 20, 10 }, ["Басей Вестница Пламени"] = { 90, 85, 80, 75, 70, 65, 60, 50, 40, 25, 20, 10 }, ["Bahsei la Emisaria del Fuego"] = { 90, 85, 80, 75, 70, 65, 60, 50, 40, 25, 20, 10 }, ["炎の使者バーセイ"] = { 90, 85, 80, 75, 70, 65, 60, 50, 40, 25, 20, 10 }, ["烈焰先驱巴塞"] = { 90, 85, 80, 75, 70, 65, 60, 50, 40, 25, 20, 10 },
    ["Xalvakka"] = { 70, 40 }, ["Залвакка"] = { 70, 40 }, ["ザルヴァッカ"] = { 70, 40 }, ["夏尔瓦卡"] = { 70, 40 },

    -- 2022Q2 Dreadsail Reef
    ["Lylanar"] = { 80, 70 }, ["Лиланар"] = { 80, 70 }, ["リラナー"] = { 80, 70 }, ["莱拉纳尔"] = { 80, 70 },
    ["Turlassil"] = { 80, 70 }, ["Турлассил"] = { 80, 70 }, ["トゥルラシル"] = { 80, 70 }, ["图拉塞尔"] = { 80, 70 },
    ["Tideborn Taleria"] = { 85, 50, 35, 20 }, ["Gezeitengeborene Taleria"] = { 85, 50, 35, 20 }, ["Taleria Née-des-Marées"] = { 85, 50, 35, 20 }, ["Талерия Рожденная Приливом"] = { 85, 50, 35, 20 }, ["Taleria de la Marea"] = { 85, 50, 35, 20 }, ["タイドボーン・タレリア"] = { 85, 50, 35, 20 }, ["泰德伯恩·塔勒里亚"] = { 85, 50, 35, 20 },

    -- 2023Q2 Sanity's Edge
    ["Exarchanic Yaseyla"] = { 90, 70, 60, 50, 35, 30, 20, 10 }, ["Exarchanikerin Yaseyla"] = { 90, 70, 60, 50, 35, 30, 20, 10 }, ["L’exarchanique Yaseyla"] = { 90, 70, 60, 50, 35, 30, 20, 10 }, ["Экзарханик Ясейла"] = { 90, 70, 60, 50, 35, 30, 20, 10 }, ["Exarcana Yaseyla"] = { 90, 70, 60, 50, 35, 30, 20, 10 }, ["エグザーカニック・ヤセイラ"] = { 90, 70, 60, 50, 35, 30, 20, 10 }, ["主教亚赛拉"] = { 90, 70, 60, 50, 35, 30, 20, 10 },
    ["Ansuul the Tormentor"] = { 90, 80, 70, 60, 50, 40, 30, 20 }, ["Ansuul die Quälende"] = { 90, 80, 70, 60, 50, 40, 30, 20 }, ["Ansuul la Tormentrice"] = { 90, 80, 70, 60, 50, 40, 30, 20 }, ["Ансул Истязательница"] = { 90, 80, 70, 60, 50, 40, 30, 20 }, ["Ansuul la Atormentadora"] = { 90, 80, 70, 60, 50, 40, 30, 20 }, ["拷問者アンスール"] = { 90, 80, 70, 60, 50, 40, 30, 20 }, ["折磨者安苏尔"] = { 90, 80, 70, 60, 50, 40, 30, 20 },

    -- U42 Lucent Citadel
    ["Orphic Shattered Shard"] = { 90, 60, 40, 20 }, ["orphische Splitterscherbe"] = { 90, 60, 40, 20 }, ["fragment brisé orphique"] = { 90, 60, 40, 20 },  ["Таинственный осколочник"] = { 90, 60, 40, 20 }, ["fragmento destrozado órfico"] = { 90, 60, 40, 20 }, ["オーフィックの砕けた欠片"] = { 90, 60, 40, 20 }, ["神秘破裂碎片"] = { 90, 60, 40, 20 },

    -- Dragonstar Arena
    ["Champion Marcauld"] = { 70, 40 }, ["Le champion Marcauld"] = { 70, 40 }, ["Чемпион Марко"] = { 70, 40 }, ["El campeón Marcauld"] = { 70, 40 }, ["チャンピオン・マルカウルド"] = { 70, 40 }, ["勇士马卡尔德"] = { 70, 40 },
    ["Anal'a Tu'wha"] = { 40 }, ["Анал'а Ту'ва"] = { 40 }, ["アナラ・ツワ"] = { 40 }, ["阿那拉·图哈"] = { 40 },
    ["Vampire Lord Thisa"] = { 80 }, ["Vampirfürstin Thisa"] = { 80 }, ["La dame vampire Thisa"] = { 80 }, ["Вампир-лорд Тиза"] = { 80 }, ["La señora de los vampiros Tisa"] = { 80 }, ["吸血鬼の王シサ"] = { 80 }, ["吸血鬼领主斯萨"] = { 80 },
    ["Hiath the Battlemaster"] = { 75, 50, 25 }, ["Hiath der Kampfmeister"] = { 75, 50, 25 }, ["Hiath le Maître de guerre"] = { 75, 50, 25 }, ["Хиат Полководец"] = { 75, 50, 25 }, ["Hiath el Maestro de batalla"] = { 75, 50, 25 }, ["バトルマスター・ヒアス"] = { 75, 50, 25 }, ["战斗大师西亚斯"] = { 75, 50, 25 },

    -- Blackrose Prison
    ["Tames-the-Beast"] = { 80, 60, 40 }, ["Zähmt-die-Bestien"] = { 80, 60, 40 }, ["Dompte-la-Bête"] = { 80, 60, 40 }, ["Приручает-Чудовищ"] = { 80, 60, 40 }, ["Doma Las Bestias"] = { 80, 60, 40 }, ["獣を馴らす者"] = { 80, 60, 40 }, ["驯兽者"] = { 80, 60, 40 },
    ["Lady Minara"] = { 80, 60, 40, 20 }, ["Fürstin Minara"] = { 80, 60, 40, 20 }, ["La dame Minara"] = { 80, 60, 40, 20 }, ["Леди Минара"] = { 80, 60, 40, 20 }, ["レディ・ミナラ"] = { 80, 60, 40, 20 }, ["米纳拉夫人"] = { 80, 60, 40, 20 },

    -- Maelstrom Arena
    ["Matriarch Runa"] = { 75, 45 }, ["Matriarchin Runa"] = { 75, 45 }, ["Matriarche Runa"] = { 75, 45 }, ["Матриарх Руна"] = { 75, 45 }, ["Matriarca Runa"] = { 75, 45 }, ["ルナ女族長"] = { 75, 45 }, ["女酋长卢娜"] = { 75, 45 },
    ["Ash Titan"] = { 65, 35 }, ["Aschtitan"] = { 65, 35 }, ["Titan de cendres"] = { 65, 35 }, ["Пепельный титан"] = { 65, 35 }, ["Titán de ceniza"] = { 65, 35 }, ["アッシュタイタン"] = { 65, 35 }, ["灰烬泰坦"] = { 65, 35 },
    ["Voriak Solkyn"] = { 70 }, ["Ворьяк Солкин"] = { 70 }, ["ヴォリアク・ソルキン"] = { 70 }, ["沃瑞亚克·索尔金"] = { 70 },

    -- Vateshran Hollows
    ["Maebroogha the Void Lich"] = { 10 }, ["Maebroogha der Leerenlich"] = { 10 }, ["Maebroogha la Liche du Vide"] = { 10 }, ["Мейбруга Лич Пустоты"] = { 10 }, ["Maebroogha la liche del vacío"] = { 10 }, ["虚無のリッチ・メイブルーガ"] = { 10 }, ["虚无巫妖梅布鲁加"] = { 10 },
    ["Shade of the Grove"] = { 80, 50, 20 }, ["Schatten des Hains"] = { 80, 50, 20 }, ["Ombre du bosquet"] = { 80, 50, 20 }, ["Тень Рощи"] = { 80, 50, 20 }, ["Sombra de la arboleda"] = { 80, 50, 20 }, ["森の影"] = { 80, 50, 20 }, ["树林幽影"] = { 80, 50, 20 },
    ["Rahdgarak"] = { 95, 80, 65 }, ["Радгарак"] = { 95, 80, 65 }, ["ラードガラク"] = { 95, 80, 65 }, ["拉德加拉克"] = { 95, 80, 65 },
    ["Magma Queen"] = { 45 }, ["Magmakönigin"] = { 45 }, ["Reine du magma"] = { 45 }, ["Лавовая Королева"] = { 45 }, ["La reina de magma"] = { 45 }, ["マグマ・クィーン"] = { 45 }, ["岩浆女王"] = { 45 },
    ["The Pyrelord"] = { 70, 35 }, ["Der Schürfürst"] = { 70, 35 }, ["Le Seigneur des bûchers"] = { 70, 35 }, ["Пламенный Владыка"] = { 70, 35 }, ["Señor de la pira"] = { 70, 35 }, ["火の王"] = { 70, 35 }, ["柴堆领主"] = { 70, 35 },

    -- DUNGEONS --
    -- Tempest Island
    ["Stormfist"] = { 70, 40 }, ["Sturmfaust"] = { 70, 40 }, ["Poigne-tempête"] = { 70, 40 }, ["Штормовой Кулак"] = { 70, 40 }, ["Puño de Tormenta"] = { 70, 40 }, ["ストームフィスト"] = { 70, 40 }, ["暴风拳"] = { 70, 40 },

    -- City Of Ash 2
    ["Valkyn Skoria"] = { 60, 20 }, ["Валкин Скория"] = { 60, 20 }, ["El valkyn Skoria"] = { 60, 20 }, ["ヴァルキン・スコリア"] = { 60, 20 }, ["瓦尔金·斯科里亚"] = { 60, 20 },

    -- White Gold Tower
    ["Molag Kena"] = { 60, 30 }, ["Молаг Кена"] = { 60, 30 }, ["モラグ・キーナ"] = { 60, 30 }, ["莫拉格·科娜"] = { 60, 30 },

    -- Ruins of Mazzatun
    ["Tree-Minder Na-Kesh"] = { 70, 40 }, ["Baumhirtin Na-Kesh"] = { 70, 40 }, ["La Sylvegarde Na-Kesh"] = { 70, 40 }, ["Древохранительница На-Кеш"] = { 70, 40 }, ["La arborista Na-Kesh"] = { 70, 40 }, ["木の番人ナ・ケッシュ"] = { 70, 40 }, ["树之牧者纳-凯石"] = { 70, 40 },
    -- Cradle of Shadows
    ["Velidreth"] = { 65, 30 }, ["Велидрет"] = { 65, 30 }, ["ヴェリドレス"] = { 65, 30 }, ["薇利德雷斯"] = { 65, 30 },

    -- Bloodroot Forge
    ["Mathgamain"] = { 75, 50, 25 }, ["Матгамейн^M"] = { 75, 50, 25 }, ["マスガメイン"] = { 75, 50, 25 }, ["玛斯加梅因"] = { 75, 50, 25 },
    ["Caillaoife"] = { 75, 50, 30 }, ["Каиллаф^F"] = { 75, 50, 30 }, ["カイラオイフェ"] = { 75, 50, 30 }, ["凯拉奥菲"] = { 75, 50, 30 },
    ["Galchobhar"] = { 50 }, ["Галкобар"] = { 50 }, ["ガルチョブハル"] = { 50 }, ["盖尔卓巴尔"] = { 50 },
    ["Earthgore Amalgam"] = { 80, 50 }, ["Erdbluter-Amalgam"] = { 80, 50 }, ["Amalgame de sangreterre"] = { 80, 50 }, ["Атронах из крови земли"] = { 80, 50 }, ["La amalgama Tierra sangrienta"] = { 80, 50 }, ["アースゴア・アマルガム"] = { 80, 50 }, ["地血混合体"] = { 80, 50 },
    -- Falkreath Hold
    ["Domihaus the Bloody-Horned"] = { 80, 60, 40, 25 }, ["Domihaus der Blutgehörnte"] = { 80, 60, 40, 25 }, ["Domihaus Corne-Sanglante"] = { 80, 60, 40, 25 }, ["Домихаус Кровавые Рога"] = { 80, 60, 40, 25 }, ["Domihaus Cuerno Sangriento"] = { 80, 60, 40, 25 }, ["血塗られた角ドミーハウス"] = { 80, 60, 40, 25 }, ["“血角”铎米豪斯"] = { 80, 60, 40, 25 },

    -- Scalecaller Peak
    ["Doylemish Ironheart"] = { 80, 60, 40, 20 }, ["Doylemish Eisenherz"] = { 80, 60, 40, 20 }, ["Doylemish Cœur-de-Fer"] = { 80, 60, 40, 20 }, ["Дойлемиш Железное Сердце"] = { 80, 60, 40, 20 }, ["Doylemish Corazón de Hierro"] = { 80, 60, 40, 20 }, ["ドイルミッシュ・アイアンハート"] = { 80, 60, 40, 20 }, ["“铁心”多来米什"] = { 80, 60, 40, 20 },
    ["Zaan the Scalecaller"] = { 80, 60, 40, 20 }, ["Zaan die Schuppenruferin"] = { 80, 60, 40, 20 }, ["Zaan la Mandécailles"] = { 80, 60, 40, 20 }, ["Заан Воспевательница Дракона"] = { 80, 60, 40, 20 }, ["Zaan la Invocadora de Escamas"] = { 80, 60, 40, 20 }, ["ザーン・スケイルコーラー"] = { 80, 60, 40, 20 }, ["唤鳞者赞恩"] = { 80, 60, 40, 20 },
    -- Fang Lair
    ["Thurvokun"] = { 80, 60, 40, 20 }, ["Турвокун"] = { 80, 60, 40, 20 }, ["サーヴォクン"] = { 80, 60, 40, 20 }, ["图尔佛昆"] = { 80, 60, 40, 20 },

    -- March of Sacrifices
    ["Tarcyr"] = { 80, 50, 20 }, ["Тарсир"] = { 80, 50, 20 }, ["タルシル"] = { 80, 50, 20 }, ["塔赛尔"] = { 80, 50, 20 },
    ["Balorgh"] = { 80, 60, 40, 20 }, ["Балорг"] = { 80, 60, 40, 20 }, ["バローグ"] = { 80, 60, 40, 20 }, ["巴洛格"] = { 80, 60, 40, 20 },
    -- Moon Hunter Keep
    ["Vykosa the Ascendant"] = { 90, 70, 50, 30 }, ["Vykosa die Aufgestiegene"] = { 90, 70, 50, 30 }, ["Vykosa l'Ascendante"] = { 90, 70, 50, 30 }, ["Вайкоса Вознесшаяся"] = { 90, 70, 50, 30 }, ["Vykosa la Ascendida"] = { 90, 70, 50, 30 }, ["超越者ヴィコサ"] = { 90, 70, 50, 30 }, ["飞升的维科萨"] = { 90, 70, 50, 30 },

    -- 2019Q1 Depths of Malatar
    ["The Scavenging Maw"] = { 80, 50, 25 }, ["Der Raubschlund"] = { 80, 50, 25 }, ["La Gueule charognarde"] = { 80, 50, 25 }, ["Пожиратель Мертвечины"] = { 80, 50, 25 }, ["Las Fauces Carroñeras"] = { 80, 50, 25 }, ["スカベンジング・モー"] = { 80, 50, 25 }, ["拾荒饿鬼"] = { 80, 50, 25 },
    ["The Weeping Woman"] = { 75, 55, 35 }, ["Die Trauernde"] = { 75, 55, 35 }, ["La Pleureuse"] = { 75, 55, 35 }, ["Плачущая Дева"] = { 75, 55, 35 }, ["La Llorona"] = { 75, 55, 35 }, ["嘆きの淑女"] = { 75, 55, 35 }, ["悲泣之女"] = { 75, 55, 35 },
    ["Symphony of Blades"] = { 80, 50, 11 }, ["Die Sinfonie der Klingen"] = { 80, 50, 11 }, ["La Symphonie des Lames"] = { 80, 50, 11 }, ["Симфония Клинков"] = { 80, 50, 11 }, ["Sinfonía de espadas"] = { 80, 50, 11 }, ["シンフォニー・オブ・ブレイズ"] = { 80, 50, 11 }, ["利刃交响曲"] = { 80, 50, 11 },
    -- 2019Q1 Frostvault
    ["Icestalker"] = { 90, 75, 50, 30 }, ["Eispirscher"] = { 90, 75, 50, 30 }, ["Traqueglace"] = { 90, 75, 50, 30 }, ["Ледяной Охотник"] = { 90, 75, 50, 30 }, ["Acechador del Hielo"] = { 90, 75, 50, 30 }, ["アイスストーカー"] = { 90, 75, 50, 30 }, ["寒冰追猎者"] = { 90, 75, 50, 30 },
    ["Warlord Tzogvin"] = { 70, 33 }, ["Kriegsfürst Tzogvin"] = { 70, 33 }, ["Le seigneur de guerre Tzogvin"] = { 70, 33 }, ["Вождь Тзогвин"] = { 70, 33 }, ["El señor de la guerra Tzogvin"] = { 70, 33 }, ["ツォグヴィン戦士長"] = { 70, 33 }, ["督军佐格文"] = { 70, 33 },
    ["Vault Protector"] = { 90, 75, 50 }, ["Gewölbebeschützer"] = { 90, 75, 50 }, ["Protecteur des cryptes"] = { 90, 75, 50 }, ["Защитник хранилища"] = { 90, 75, 50 }, ["Defensor de la cripta"] = { 90, 75, 50 }, ["ヴォルトの守護者"] = { 90, 75, 50 }, ["宝库保卫者"] = { 90, 75, 50 },
    ["The Stonekeeper"] = { 70, 55, 30 }, ["Der Steinwahrer"] = { 70, 55, 30 }, ["Le Gardien des Pierres"] = { 70, 55, 30 }, ["Хранитель Камня"] = { 70, 55, 30 }, ["Guardián de la tablilla"] = { 70, 55, 30 }, ["石の番人"] = { 70, 55, 30 }, ["石之看守"] = { 70, 55, 30 },

    -- 2019Q3 Moongrave Fane
    ["Dro'zakar"] = { 90, 60, 30 }, ["Дро'закар"] = { 90, 60, 30 }, ["ドロザカール"] = { 90, 60, 30 }, ["多罗扎卡"] = { 90, 60, 30 },
    ["Kujo Kethba"] = { 90, 70, 50, 30 }, ["Куджо-Кетба"] = { 90, 70, 50, 30 }, ["クジョー・ケスバ"] = { 90, 70, 50, 30 }, ["库乔·科斯巴"] = { 90, 70, 50, 30 },
    ["Grundwulf"] = { 70, 50, 30, 20, 10 }, ["Грандвульф"] = { 70, 50, 30, 20, 10 }, ["グランドウルフ"] = { 70, 50, 30, 20, 10 }, ["格伦德伍尔夫"] = { 70, 50, 30, 20, 10 },
    -- 2019Q3 Lair of Maarselok
    ["Maarselok"] = { 90, 80, 70, 65, 55, 50, 25 }, ["Марселок"] = { 90, 80, 70, 65, 55, 50, 25 }, ["マーセロク"] = { 90, 80, 70, 65, 55, 50, 25 }, ["马塞洛克"] = { 90, 80, 70, 65, 55, 50, 25 },

    -- 2020Q1 Icereach
    ["Stormborn Revenant"] = { 55, 40 }, ["Sturmgeborener Wiedergänger"] = { 55, 40 }, ["Le revenant Enfant de la foudre"] = { 55, 40 }, ["Бурерожденный неупокоенный"] = { 55, 40 }, ["Hijo de la tormenta reanimado"] = { 55, 40 }, ["ストームボーン・レブナント"] = { 55, 40 }, ["冰铸亡魂"] = { 55, 40 },
    ["Mother Ciannait"] = { 90, 80, 70, 60, 50, 40, 30, 20 }, ["Mutter Ciannait"] = { 90, 80, 70, 60, 50, 40, 30, 20 }, ["Mère Ciannait"] = { 90, 80, 70, 60, 50, 40, 30, 20 }, ["Мать Кьяннайт"] = { 90, 80, 70, 60, 50, 40, 30, 20 }, ["Madre Ciannait"] = { 90, 80, 70, 60, 50, 40, 30, 20 }, ["マザー・シアネイト"] = { 90, 80, 70, 60, 50, 40, 30, 20 }, ["巫母西恩奈特"] = { 90, 80, 70, 60, 50, 40, 30, 20 },
    -- 2020Q1 Unhallowed Grave
    ["Hakgrym the Howler"] = { 70, 30 }, ["Hakgrym der Heuler"] = { 70, 30 }, ["Hakgrym le Hurleur"] = { 70, 20 }, ["Хакгрим Ревун"] = { 70, 30 }, ["Hakgrym el Aullador"] = { 70, 30 }, ["吠えるハクグリム"] = { 70, 30 }, ["嚎叫者哈克格里姆"] = { 70, 30 },
    ["Keeper of the Kiln"] = { 80, 70, 60, 50, 40 }, ["Bewahrerin der Feuerkammer"] = { 80, 70, 60, 50, 40 }, ["Le gardien du four"] = { 80, 70, 60, 50, 40 }, ["Хранительница Горна"] = { 80, 70, 60, 50, 40 }, ["Guardián del Horno"] = { 80, 70, 60, 50, 40 }, ["窯の番人"] = { 80, 70, 60, 50, 40 }, ["炉窑守护者"] = { 80, 70, 60, 50, 40 },
    ["Voria the Heart-Thief"] = { 75, 40 }, ["Voria die Herzdiebin"] = { 75, 40 }, ["Voria la Voleuse de cœurs"] = { 75, 40 }, ["Вория Похитительница Сердец"] = { 75, 40 }, ["Voria la Ladrona de Corazones"] = { 75, 40 }, ["心盗賊ヴォリア"] = { 75, 40 }, ["偷心者沃瑞亚"] = { 75, 40 },
    ["Eternal Aegis"] = { 90, 70, 50, 30 }, ["Ewige Ägis"] = { 90, 70, 50, 30 }, ["L’Égide éternelle"] = { 90, 70, 50, 30 }, ["Вечный страж"] = { 90, 70, 50, 30 }, ["Égida eterna"] = { 90, 70, 50, 30 }, ["エターナル・アイギス"] = { 90, 70, 50, 30 }, ["永恒盾灵"] = { 90, 70, 50, 30 },
    ["Ondagore the Mad"] = { 80, 60, 40, 20 }, ["Ondagore der Verrückte"] = { 80, 60, 40, 20 }, ["Ondagore le Fou"] = { 80, 60, 40, 20 }, ["Ондагор Безумный"] = { 80, 60, 40, 20 }, ["Ondagore el Demente"] = { 80, 60, 40, 20 }, ["狂乱のオンダゴア"] = { 80, 60, 40, 20 }, ["疯狂的昂达戈尔"] = { 80, 60, 40, 20 },
    ["Voria's Masterpiece"] = { 90, 40 }, ["Vorias Meisterstück"] = { 90, 40 }, ["Le chef-d'œuvre de Voria"] = { 90, 40 }, ["Шедевр Вории"] = { 90, 40 }, ["Obra maestra de Voria"] = { 90, 40 }, ["ヴォリアの傑作"] = { 90, 40 }, ["沃瑞亚的杰作"] = { 90, 40 },
    ["Kjalnar Tombskald"] = { 50 }, ["Kjalnar Grabskalde"] = { 50 }, ["Kjalnar Tombescalde"] = { 50 }, ["Кьялнар Скальд Гробниц"] = { 50 }, ["Kjalnar Escaldo Fúnebre"] = { 50 }, ["クジャルナル・トゥームスカルド"] = { 50 }, ["卡尔纳尔·墓歌"] = { 50 },

    -- 2020Q3 Castle Thorn
    ["Vaduroth"] = { 75, 50, 25 }, ["Вадорот"] = { 75, 50, 25 }, ["ヴァドゥロス"] = { 75, 50, 25 }, ["瓦杜罗斯"] = { 75, 50, 25 },
    ["Lady Thorn"] = { 60, 20 }, ["Fürstin Dorn"] = { 60, 20 }, ["Dame Ronce"] = { 60, 20 }, ["Леди Шипов"] = { 60, 20 }, ["Lady Espina"] = { 60, 20 }, ["レディ・ソーン"] = { 60, 20 }, ["荆棘夫人"] = { 60, 20 },
    -- 2020Q3 Stone Garden
    ["Arkasis the Mad Alchemist"] = { 60, 20, 10 }, ["Arkasis der irre Alchemist"] = { 60, 20, 10 }, ["Arkasis l'Alchimiste fou"] = { 60, 20, 10 }, ["Безумный алхимик Аркасис"] = { 60, 20, 10 }, ["Arkasis el Alquimista Loco"] = { 60, 20, 10 }, ["狂った錬金術師アルカシス"] = { 60, 20, 10 }, ["疯炼金术士阿卡西斯"] = { 60, 20, 10 },

    -- 2021Q1 Black Drake Villa
    ["Kinras Ironeye"] = { 75, 30 }, ["Kinras Eisenauge"] = { 75, 30 }, ["Kinras Œil-de-fer"] = { 75, 30 }, ["Кинрас Железный Глаз"] = { 75, 30 }, ["Kinras Ojo de Hierro"] = { 75, 30 }, ["キンラス・アイアンアイ"] = { 75, 30 }, ["金拉斯·铁眼"] = { 75, 30 },
    ["Captain Geminus"] = { 70, 30 }, ["Hauptmann Geminus"] = { 70, 30 }, ["La Capitaine Géminus"] = { 70, 30 }, ["Капитан Гемина"] = { 70, 30 }, ["La capitana Gémino"] = { 70, 30 }, ["ゲミナス隊長"] = { 70, 30 }, ["杰米诺斯队长"] = { 70, 30 },
    ["Pyroturge Encratis"] = { 60 }, ["Pyroturg Encratis"] = { 60 }, ["Le Pyroturge Encratis"] = { 60 }, [""] = { 60 }, ["Повелитель Пламени Энкратис"] = { 60 }, ["Piroturgo Engracio"] = { 60 }, ["火炎魔術師エンクラティス"] = { 60 }, ["派罗图格·恩克拉迪斯"] = { 60 },
    ["Sentinel Aksalaz"] = { 85, 60, 35 }, ["Wächter Aksalaz"] = { 85, 60, 35 }, ["La sentinelle Aksalaz"] = { 85, 60, 35 }, ["Страж Аксалаз"] = { 85, 60, 35 }, ["Centinela Aksalaz"] = { 85, 60, 35 }, ["衛士アクサラズ"] = { 85, 60, 35 }, ["哨兵阿克萨拉兹"] = { 85, 60, 35 },
    -- 2021Q1 The Cauldron
    ["Taskmaster Viccia"] = { 75, 50, 25 }, ["Zuchtmeisterin Viccia"] = { 75, 50, 25 }, ["La contremaître Viccia"] = { 75, 50, 25 }, ["Надсмотрщица Викция"] = { 75, 50, 25 }, ["La capataz Viccia"] = { 75, 50, 25 }, ["タスクマスター・ヴィッシア"] = { 75, 50, 25 }, ["使命之主维希娅"] = { 75, 50, 25 },
    ["Molten Guardian"] = { 25 }, ["Geschmolzener Wächter"] = { 25 }, ["Gardien en fusion"] = { 25 }, ["Раскаленный страж"] = { 25 }, ["Guardián fundido"] = { 25 }, ["溶けたガーディアン"] = { 25 }, ["熔火守护者"] = { 25 },
    ["Baron Zaudrus"] = { 60, 50, 25 }, ["Le baron Zaudrus"] = { 60, 50, 25 }, ["Барон Зодрус"] = { 60, 50, 25 }, ["Barón Zaudrus"] = { 60, 50, 25 }, ["ザウドラス男爵"] = { 60, 50, 25 }, ["佐德鲁斯男爵"] = { 60, 50, 25 },

    -- 2021Q3 Red Petal Bastion
    ["Eliam Merick "] = { 80, 50, 30 }, ["Eliam Merick"] = { 80, 50, 30 }, ["Эльям Мерик"] = { 80, 50, 30 }, ["エリアム・メリック"] = { 80, 50, 30 }, ["于连·梅里克"] = { 80, 50, 30 },
    -- 2021Q3 The Dread Cellar
    ["Magma Incarnate"] = { 60, 30 }, ["Magmaverkörperung"] = { 60, 30 }, ["Magma Incarné"] = { 60, 30 }, ["Живое Пламя"] = { 60, 30 }, ["Encarnado de magma"] = { 60, 30 }, ["マグマの転生者"] = { 60, 30 }, ["岩浆化身"] = { 60, 30 },

    -- 2022Q1 Shipwright's Regret
    ["Foreman Bradiggan"] = { 60, 30 }, ["Vorarbeiter Bradiggan"] = { 60, 30 }, ["Le contremaître Bradiggan"] = { 60, 30 }, ["Бригадир Брадигган"] = { 60, 30 }, ["El capataz Bradiggan"] = { 60, 30 }, ["ブラディガン作業長"] = { 60, 30 }, ["布拉迪干工头"] = { 60, 30 }, [""] = { 60, 30 },
    ["Nazaray"] = { 70, 30 }, ["Назарей"] = { 70, 30 }, ["ナザレイ"] = { 70, 30 }, ["娜扎莱"] = { 70, 30 },
    ["Captain Numirril"] = { 85, 40 }, ["Kapitän Numirril"] = { 85, 40 }, ["Le capitaine Numirril"] = { 85, 40 }, ["Капитан Нумиррил"] = { 85, 40 }, ["El capitán Numirril"] = { 85, 40 }, ["ヌミリル船長"] = { 85, 40 }, ["队长努米利尔"] = { 85, 40 }, [""] = { 85, 40 },
    -- 2022Q1 Coral Aerie
    ["Maligalig"] = { 65, 35 }, ["Малигалиг"] = { 65, 35 }, ["マリガリグ"] = { 65, 35 }, ["马里伽利格"] = { 65, 35 },
    ["Sarydil"] = { 70, 35 }, ["Саридил"] = { 70, 35 }, ["サリディル"] = { 70, 35 }, ["萨利迪尔"] = { 70, 35 },
    ["Varallion"] = { 90, 80, 50 }, ["Вараллион"] = { 90, 80, 50 }, ["ヴァラリオン"] = { 90, 80, 50 }, ["瓦拉利昂"] = { 90, 80, 50 },
    ["Shield Guardian"] = { 65, 25 }, ["Schildwächter"] = { 65, 25 }, ["Gardien du bouclier"] = { 65, 25 }, ["Страж со щитом"] = { 65, 25 }, ["Guardián del Escudo"] = { 65, 25 }, ["盾のガーディアン"] = { 65, 25 }, ["盾守护者"] = { 65, 25 },

    -- 2022Q3 Earthen Root Enclave
    ["Corruption of Stone"] = { 80, 60, 30 }, ["Verderbnis des Steins"] = { 80, 60, 30 }, ["La corruption de pierre"] = { 80, 60, 30 }, ["Скверна Камня"] = { 80, 60, 30 }, ["Corrupción de la piedra"] = { 80, 60, 30 }, ["腐敗の石"] = { 80, 60, 30 }, ["腐化之石"] = { 80, 60, 30 },
    ["Corruption of Root"] = { 66, 33 }, ["Die Verderbnis der Wurzel"] = { 66, 33 }, ["La corruption de racine"] = { 66, 33 }, ["Скверна Корня"] = { 66, 33 }, ["Corrupción de la raíz"] = { 66, 33 }, ["腐敗の根"] = { 66, 33 }, ["腐化之根"] = { 66, 33 },
    ["Archdruid Devyric"] = { 70, 20 }, ["Erzdruide Devyric"] = { 70, 20 }, ["L’archidruide Devyric"] = { 70, 20 }, ["Архидруид Девирик"] = { 70, 20 }, ["El archidruida Devyric"] = { 70, 20 }, ["アークドルイド・デヴィリック"] = { 70, 20 }, ["大德鲁伊德维里克"] = { 70, 20 },
    -- 2022Q3 Graven Deep
    ["Zelvraak the Unbreathing"] = { 75, 50, 25 }, ["Zelvraak der Atemlose"] = { 75, 50, 25 }, ["Zelvraak le Sans-Souffle"] = { 75, 50, 25 }, ["Зельврак Бездыханный"] = { 75, 50, 25 }, ["Zelvraak el Sin Aliento"] = { 75, 50, 25 }, ["息要らずのゼルヴラーク"] = { 75, 50, 25 }, ["无息泽尔拉克"] = { 75, 50, 25 },

    -- 2023Q1 Scrivener's Hall
    ["Riftmaster Naqri"] = { 80, 55, 35 }, ["Rissmeister Naqri"] = { 80, 55, 35 }, ["Le maître de la Faille Naqri"] = { 80, 55, 35 }, ["Мастер разломов Накри"] = { 80, 55, 35 }, ["El Señor de la Grieta Naqri"] = { 80, 55, 35 }, ["リフトマスター・ナクリ"] = { 80, 55, 35 }, ["裂隙御侍纳克里"] = { 80, 55, 35 },
    ["Ozezan the Inferno"] = { 50, 40, 20 }, ["Ozezan das Inferno"] = { 50, 40, 20 }, ["Ozezan l'Infernal"] = { 50, 40, 20 }, ["Озезан Бушующее Пламя"] = { 50, 40, 20 }, ["Ozezan la Infernal"] = { 50, 40, 20 }, ["業火のオゼザン"] = { 50, 40, 20 }, ["炼狱奥泽赞"] = { 50, 40, 20 },
    -- 2023Q1 Bal Sunnar
    ["Kovan Giryon"] = { 65, 45, 20 }, ["Кован Гирион"] = { 65, 45, 20 }, ["コヴァン・ジリョン"] = { 65, 45, 20 }, ["科万·吉里恩"] = { 65, 45, 20 },
    ["Roksa the Warped"] = { 70, 40 }, ["Roksa die Verkrümmte"] = { 70, 40 }, ["Roksa le Déformé"] = { 70, 40 }, ["Рокса Искалеченный"] = { 70, 40 }, ["Roksa el Deformado"] = { 70, 40 }, ["歪められたロクサ"] = { 70, 40 }, ["扭曲者洛科萨"] = { 70, 40 },
    ["Matriarch Lladi Telvanni"] = { 70, 35 }, ["Matriarchin Lladi Telvanni"] = { 70, 35 }, ["La matriarche Lladi Telvanni"] = { 70, 35 }, ["Матриарх Ллади Телванни"] = { 70, 35 }, ["La matriarca Lladi Telvanni"] = { 70, 35 }, ["ルラディ・テルヴァンニ女族長"] = { 70, 35 }, ["女族长雷拉蒂·泰尔瓦尼"] = { 70, 35 },

    -- Oathsworn Pit
    ["Anthelmir's Construct"] = { 70 }, ["Anthelmirs Konstrukt"] = { 70 }, ["Assemblage d'Anthelmir"] = {70}, ["Творение Антелмир"] = { 70 }, ["autómata de Anthelmir"] = { 70 }, ["アンセルミルのコンストラクト"] = { 70 }, ["安塞尔莫的构造体"] = { 70 },
    ["Aradros the Awakened"] = { 51 }, ["Aradros der Erwachte"] = { 51 }, ["Aradros l'Éveillé"] = { 51 }, ["Арадрос Пробужденный"] = { 51 }, ["Aradros el Despertado"] = { 51 }, ["覚醒者アラドロス"] = { 51 }, ["苏醒者亚拉德罗斯"] = { 51 },

    -- Bedlam Veil
    ["Shattered Champion"] = { 70, 50 }, ["zerschlagener Champion"] = { 70, 50 }, ["Champion brisé"] = { 70, 50 }, ["Расколотый воин"] = { 70, 50 }, ["Campeón Fragmentado"] = { 70, 50 }, ["砕けた勇者"] = { 70, 50 }, ["破碎勇士"] = { 70, 50 },
    ["Darkshard"] = { 80, 60, 40 }, ["Dunkelscherbe"] = { 80, 60, 40 }, ["Fragment noir"] = { 80, 60, 40 }, ["Осколок Тьмы"] = { 80, 60, 40 }, ["Fragmento Oscuro"] = { 80, 60, 40 }, ["ダークシャード"] = { 80, 60, 40 }, ["暗黑碎片"] = { 80, 60, 40 },
    ["The Blind"] = { 81, 61, 41, 21 }, ["Blinde"] = { 81, 61, 41, 21 }, ["Aveugle"] = { 81, 61, 41, 21 }, ["Слепая"] = { 81, 61, 41, 21 }, ["Invidente"] = { 81, 61, 41, 21 }, ["盲目者"] = { 81, 61, 41, 21 }, ["盲眼邪神"] = { 81, 61, 41, 21 },

    -- U45 Exiled Redoubt
    ["Executioner Jerensi"] = { 80, 50, 30 }, ["Henkerin Jerensi"] = { 80, 50, 30 }, ["bourreau Jerensi"] = { 80, 50, 30 }, ["Палач Джеренси"] = { 80, 50, 30 }, ["verdugo Jerensi"] = { 80, 50, 30 }, ["処刑人ジェレンシ"] = { 80, 50, 30 }, ["行刑者耶伦希"] = { 80, 50, 30 },
    ["Prime Sorcerer Vandorallen"] = { 90, 66, 45 }, ["oberster Zauberer Vandorallen"] = { 90, 66, 45 }, ["sorcier primat Vandorallen"] = { 90, 66, 45 }, ["Главный чародей Вандораллен"] = { 90, 66, 45 }, ["brujo supremo Vandorallen"] = { 90, 66, 45 }, ["筆頭妖術師ヴァンドラレン"] = { 90, 66, 45 }, ["首席术士范多拉伦"] = { 90, 66, 45 },
    ["Squall of Retribution"] = { 95, 88, 80, 70, 65, 55, 50, 45, 32, 22, 16, 5 }, ["Bö der Vergeltung"] = { 95, 88, 80, 70, 65, 55, 50, 45, 32, 22, 16, 5 }, ["Grain punitif"] = { 95, 88, 80, 70, 65, 55, 50, 45, 32, 22, 16, 5 }, ["Шквал Возмездия"] = { 95, 88, 80, 70, 65, 55, 50, 45, 32, 22, 16, 5 }, ["Borrasca de Retribución"] = { 95, 88, 80, 70, 65, 55, 50, 45, 32, 22, 16, 5 }, ["報復のスコール"] = { 95, 88, 80, 70, 65, 55, 50, 45, 32, 22, 16, 5 }, ["惩罚之飑"] = { 95, 88, 80, 70, 65, 55, 50, 45, 32, 22, 16, 5 }, 

    -- U45 Lep Seclusa
    ["Garvin the Tracker"] = { 80, 50, 40 }, ["Garvin der Fährtenleser"] = { 80, 50, 40 }, ["Garvin le pisteur"] = { 80, 50, 40 }, ["Следопыт Гарвин"] = { 80, 50, 40 }, ["Garvin el Rastreador"] = { 80, 50, 40 }, ["追跡者ガーヴィン"] = { 80, 50, 40 }, ["追踪者加文"] = { 80, 50, 40 },
    ["Noriwen"] = { 70, 50, 20 }, ["Noriwën"] = { 70, 50, 20 }, ["Норивен"] = { 70, 50, 20 }, ["ノリウェン"] = { 70, 50, 20 }, ["诺丽纹"] = { 70, 50, 20 },
    ["Orpheon the Tactician"] = { 80, 50, 30 }, ["Orpheon der Taktiker"] = { 80, 50, 30 }, ["Orphéon le tacticien"] = { 80, 50, 30 }, ["Тактик Орфеон"] = { 80, 50, 30 }, ["Orfeón el Estratega"] = { 80, 50, 30 }, ["戦術家オルフェオン"] = { 80, 50, 30 }, ["战术家奥腓翁"] = { 80, 50, 30 },
}

local function getWidth()
    if FN_ABB_GET_WIDTH ~= nil then return zo_clamp(FN_ABB_GET_WIDTH(), 400, 800) end
    return zo_clamp(GuiRoot:GetWidth() * .35, 400, 800)
end

local PercentLineManager = ZO_ControlPool:Subclass()
function PercentLineManager:New(parent, ...)
    local obj = ZO_ControlPool.New(self, "ABB_HP_Line_"..SETTINGS.PERCENTAGE_LINE_STYLE.."_Template", parent, "ABB_HP_Line")
    --obj:Initialize( ... )
    return obj
end

local ABB_BossBar = ZO_Object:Subclass()
function ABB_BossBar:New(...)
    local bar = ZO_Object.New(self)
    bar:Initialize(...)
    return bar
end

function ABB_BossBar:Initialize(bossTag, topLevelCtrl, previousBar)
    self.unitTag = bossTag
    self.parent = topLevelCtrl
    self.control = CreateControlFromVirtual("ABB_Frame"..bossTag, topLevelCtrl, ABB_TEMPLATE_NAME)
    self.control:SetHidden(true)
    local healthControl = GetControl(self.control, "Health")
    self.nameText = GetControl(healthControl, "Name")
    self.healthText = GetControl(healthControl, "Text")
    self.healthBar = GetControl(healthControl, "Bar")
    self.healthLeftBgBar = GetControl(healthControl, "LeftBgBar")
    self.previousBar = previousBar
    self.nextBar = nil
    self.percentLinePool = PercentLineManager:New(self.healthBar)
    self.bossPercentages = nil
    self.hasShield = false
    self.hasImmunity = false
    self.bracketLeft = self.control:GetNamedChild("BracketLeft")
    self.bracketRight = self.control:GetNamedChild("BracketRight")
    self.scaleX = 1.0
    self.shouldWarn = false
    self.warner = GetControl(self.control, "Warner")
    self.warnerAnimation = ZO_AlphaAnimation:New(self.warner)


    local function PowerUpdateHandlerFunction(unitTag, powerPoolIndex, powerType, powerPool, powerPoolMax)
        self:OnPowerUpdate(unitTag, powerPool, powerPoolMax, false)
    end
    local powerUpdateEventHandler = ZO_MostRecentPowerUpdateHandler:New("BossBar"..bossTag, PowerUpdateHandlerFunction)
    powerUpdateEventHandler:AddFilterForEvent(REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
    
    if bossTag == "reticleover" then
        powerUpdateEventHandler:AddFilterForEvent(REGISTER_FILTER_UNIT_TAG, bossTag)
    else
        powerUpdateEventHandler:AddFilterForEvent(REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")
    end

    self:RegisterUnit(bossTag)
    self.control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function() self:UpdateWidth() end)
    self.control:RegisterForEvent(EVENT_SCREEN_RESIZED, function() self:UpdateWidth() end)
    
    self:ResetColors()
    self:ApplyStyle()
    self:ApplyAnchors()
end

function ABB_BossBar:RegisterUnit(unitTag)
    self:UnregisterUnit()
    self.unitTag = unitTag
    self.control:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, function(eventCode, unitTag, ...) self:OnUavUpdate(...) end)
    self.control:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, self.unitTag)
    self.control:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, function(eventCode, unitTag, ...) self:OnUavUpdate(...) end)
    self.control:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG, self.unitTag)
    self.control:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, function(eventCode, unitTag, ...) self:OnUavRemoval(...) end)
    self.control:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, self.unitTag)
end

function ABB_BossBar:UnregisterUnit()
    self.control:UnregisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED)
    self.control:UnregisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED)
    self.control:UnregisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED)
end

function ABB_BossBar:GetBossPercentagesByName(name)
    -- GetCVar("Language.2") returns locale like "en", "de"
    -- local rawName = GetRawUnitName(unitTag)
    if StupidBossNamesInsteadOfId[name] ~= nil then
        self.bossPercentages = StupidBossNamesInsteadOfId[name]
        self.shouldWarn = true
        return
    end
    self.shouldWarn = false
    if SETTINGS.SHOW_DEFAULTS then
        self.bossPercentages = { 75, 50, 25 } -- default Percentages
    else 
        self.bossPercentages = nil
    end
end

function ABB_BossBar:CreateLine(percent)
    local line = self.percentLinePool:AcquireObject()
    local x = (self.healthBar:GetWidth() / 100) * percent
    if SETTINGS.THEME_NAME == "Embellished" then
        x = x - 8.5
    else
        x = x - 9 -- mod for better simmetry cause of healthLeftBgBar
    end
    line:SetAnchor(TOPLEFT, self.healthBar, TOPLEFT, x, 0)
    line:SetAnchor(BOTTOMRIGHT, self.healthBar, TOPLEFT,  x, -0 + self.healthBar:GetHeight())
end

function ABB_BossBar:Refresh(force)
    if force then
        self:ApplyStyle()
        self:ResetColors()
        self:ApplyAnchors()
    else
        self:UpdateWidth()
    end
    local bossName = GetUnitName(self.unitTag)
    local health, maxHealth = GetUnitPower(self.unitTag, POWERTYPE_HEALTH)
    self:GetBossPercentagesByName(bossName)
    self.percentLinePool:ReleaseAllObjects()
    if self.bossPercentages ~= nil then
        for i = 1, #self.bossPercentages do
            self:CreateLine(self.bossPercentages[i])
        end
    end
    self.nameText:SetText(bossName)
    self:OnPowerUpdate(self.unitTag, health, maxHealth, force)
end

function ABB_BossBar:FormatPercent(health, maxHealth)
    local percent = 0
    local percentText
    if maxHealth ~= 0 then
        percent = (health / maxHealth) * 100
    end
    if percent < 10 then
        percentText = ZO_CommaDelimitDecimalNumber(zo_roundToNearest(percent, .1))
        percentText = ZO_FastFormatDecimalNumber(percentText)
    else
        percentText = zo_round(percent)
    end
    if self.bossPercentages ~= nil and SETTINGS.NOTIFY_ALERT then
        for i = 1, #self.bossPercentages do
            if (percent >= self.bossPercentages[i] and percent <= self.bossPercentages[i] + SETTINGS.NOTIFY_BEFORE_PERCENT) then
                if SETTINGS.NOTIFY_ALERT_TYPE == "Flash" then
                    self:FlashWarning()
                else
                    return zo_iconFormat("esoui/art/interaction/questnewavailable.dds", ICONSIZE-8, ICONSIZE-8)..percentText..'%'
                end
            end
        end
    end
    return percentText..'%'
end

function ABB_BossBar:OnPowerUpdate(sourceUnit, health, maxHealth, force)
    if sourceUnit ~= self.unitTag then
        return
    end
    ZO_StatusBar_SmoothTransition(self.healthBar, health, maxHealth, force)
    self.healthLeftBgBar:SetValue((health > 0 and 1 or 0))

    if health > 0 and not IsUnitDead(self.unitTag) then
        self.healthText:SetText(ZO_AbbreviateAndLocalizeNumber(health, NUMBER_ABBREVIATION_PRECISION_TENTHS, false) .. " " .. self:FormatPercent(health, maxHealth))
    else
        self.healthText:SetText(zo_iconFormat("esoui/art/icons/mapkey/mapkey_groupboss.dds", ICONSIZE, ICONSIZE))
    end
end

function ABB_BossBar:OnUavUpdate(unitAttributeVisual, _, _, _, value1)
    if (unitAttributeVisual == ATTRIBUTE_VISUAL_UNWAVERING_POWER) then
        if value1 ~= nil and value1 > 0 then
            if not self.hasImmunity then
                self.hasImmunity = true
                ZO_StatusBar_SetGradientColor(self.healthBar, UNWAVERING_GRADIENT)
                self.healthLeftBgBar:SetColor(UNWAVERING_COLOR_START:UnpackRGBA())
            end
        else
            self:OnUavRemoval(unitAttributeVisual)
        end
        return
    end
    if (unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING and not self.hasImmunity) then
        if value1 ~= nil and value1 > 0 then
            if not self.hasShield then
                self.hasShield = true
                ZO_StatusBar_SetGradientColor(self.healthBar, OVERSHIELD_GRADIENT)
                self.healthLeftBgBar:SetColor(OVERSHIELD_COLOR_START:UnpackRGBA())
            end
        else
            self:OnUavRemoval(unitAttributeVisual)
        end
    end
end

function ABB_BossBar:OnUavRemoval(unitAttributeVisual)
    if (unitAttributeVisual == ATTRIBUTE_VISUAL_UNWAVERING_POWER) then
        if self.hasImmunity then
            self.hasImmunity = false
            self:ResetColors()
        end
        return
    end
    if (unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING and not self.hasImmunity) then
        if self.hasShield then
            self.hasShield = false
            self:ResetColors()
        end
    end
end

function ABB_BossBar:ResetColors()
    local gradient = {ZO_ColorDef:New(unpack(SETTINGS.HP_COLOR_START) ), ZO_ColorDef:New(unpack(SETTINGS.HP_COLOR_END))}
    ZO_StatusBar_SetGradientColor(self.healthBar, gradient)
    self.healthLeftBgBar:SetColor(gradient[1]:UnpackRGBA())
end

function ABB_BossBar:ApplyAnchors()
    self.control:ClearAnchors()
    if self.previousBar ~= nil then
        self.previousBar.nextBar = self
        self.control:SetAnchor(TOP, self.previousBar.control, BOTTOM)
    else
        -- Only apply to the first bar
        self.control:SetAnchor(TOPLEFT, self.parent, TOPLEFT, 0, 0)
        -- self.warner:SetWidth(getWidth() * self.scaleX)
        if SETTINGS.THEME_NAME == "Embellished" then
            self.bracketLeft:SetHidden(false)
            self.bracketRight:SetHidden(false)
        end
    end
end

function ABB_BossBar:ApplyStyle()
    ApplyTemplateToControl(self.control, ZO_GetPlatformTemplate(ABB_TEMPLATE_NAME))
    self:UpdateWidth()
end

function ABB_BossBar:UpdateWidth()
    self.control:SetWidth(getWidth() * self.scaleX)
end

function ABB_BossBar:Show()
    self.control:SetHidden(false)
    self.control:SetAlpha(1)
end

function ABB_BossBar:Hide()
    self.control:SetHidden(true)
    self.hasShield = false
    self.hasImmunity = false
    self:ResetColors()
    if self.nextBar ~= nil then
        self.nextBar:Hide()
    end
end

function ABB_BossBar:FlashWarning()
    local RESOURCE_WARNER_FLASH_TIME = 300
    local RESOURCE_WARNER_NUM_FLASHES = 3
    if not self.shouldWarn then return end
    if not self.warnerAnimation:IsPlaying() then
        self.warnerAnimation:PingPong(0, 1, RESOURCE_WARNER_FLASH_TIME, RESOURCE_WARNER_NUM_FLASHES)
    else
        --Reset the animation by making it do RESOURCE_WARNER_NUM_FLASHES after this point
        local remainingLoops = self.warnerAnimation:GetPlaybackLoopsRemaining()
        local newLoops = RESOURCE_WARNER_NUM_FLASHES
        --If we're on the backswing of the ping pong we need to do one addition loop to make sure it ends in the alpha down state, otherwise it stops at full alpha
        if remainingLoops % 2 == 0 then
            newLoops = newLoops + 1
        end
        self.warnerAnimation:SetPlaybackLoopCount(newLoops)
    end
end

local function AttachTargetTo(control)
    local targetFrame = UNIT_FRAMES:GetFrame("reticleover")
    local targetControl = targetFrame.frame
    targetControl:ClearAnchors()
    targetControl:SetAnchor(TOP, control, BOTTOM, 0, 5)
end

local bossBars = {}

local function InitBars(topLevelCtrl)
    local prevBossBar

    for i = 1, MAX_BOSSES do
        local bossTag = "boss"..i
        bossBars[i] = ABB_BossBar:New(bossTag, topLevelCtrl, prevBossBar)
        prevBossBar = bossBars[i]
    end
    
    if SETTINGS.INCLUDE_DUMMY then
        bossBars[MAX_BOSSES + 1] = ABB_BossBar:New("reticleover", topLevelCtrl)
    end
end

local function ScaleBossBars()
    local highestHealthValue = 1
    local bossOrder = {}
    
    if SETTINGS.SCALE_HP_PROPORTION then
        for i = 1, MAX_BOSSES do
            local bossTag = "boss"..i
            local _, maxHealth = GetUnitPower(bossTag, POWERTYPE_HEALTH)
            table.insert(bossOrder, { tag = bossTag, maxhp = maxHealth})
            if maxHealth > highestHealthValue then
                highestHealthValue = maxHealth
            end
        end

        table.sort(bossOrder, function(a,b) return a.maxhp > b.maxhp end)
        for i, val in ipairs(bossOrder) do
            bossBars[i]:RegisterUnit(val.tag)
            bossBars[i].scaleX = zo_clamp(val.maxhp / highestHealthValue, 0.4, 1.0)
        end
    else
        for i = 1, MAX_BOSSES do
            bossBars[i].scaleX = 1.0
        end
    end
end

local function RefreshAllBosses(forceReset)
    local abbContainer = GetControl("ABB_Container")
    local lastBossBar

    ScaleBossBars()
    for i = 1, MAX_BOSSES do

        if DoesUnitExist(bossBars[i].unitTag) then
            bossBars[i]:Refresh(forceReset)
            bossBars[i]:Show()
        else
            bossBars[i]:Hide()
            do break end
        end
        lastBossBar = bossBars[i]
    end
    
    if lastBossBar ~= nil then
        COMPASS_FRAME_FRAGMENT:SetHiddenForReason("ABBar", SETTINGS.REPLACE_COMPASS)
        AttachTargetTo(lastBossBar.control)
    else
        COMPASS_FRAME_FRAGMENT:SetHiddenForReason("ABBar")
        AttachTargetTo(ZO_CompassFrame)
    end
end

local function RefreshExtraBar()
    local i = MAX_BOSSES + 1
    local isDummy = GetUnitType(bossBars[i].unitTag) == 12
    if isDummy and DoesUnitExist(bossBars[i].unitTag) then
        bossBars[i]:Refresh(forceReset)
        bossBars[i]:Show()
    else
        bossBars[i]:Hide()
    end
end

local function OnPlayerZoneChange(topLevelCtrl)
    if (GetCurrentZoneHouseId() > 0) and SETTINGS.INCLUDE_DUMMY then
        topLevelCtrl:RegisterForEvent(EVENT_RETICLE_TARGET_CHANGED, function() RefreshExtraBar() end)
    else
        topLevelCtrl:UnregisterForEvent(EVENT_RETICLE_TARGET_CHANGED)
    end
    RefreshAllBosses()
end

ABB_FakeGloss = ZO_Object:Subclass()
function ABB_FakeGloss:New()
    return ZO_Object.New(self)
end
function ABB_FakeGloss:SetMinMax() end
function ABB_FakeGloss:SetValue() end

local function SetVisualSettings()
    local offset = SETTINGS.REPLACE_COMPASS and 0 or ZO_CompassFrame:GetHeight()
    local container = GetControl("ABB_Container")
    container:SetAnchor(TOPLEFT, ZO_CompassFrame, TOPLEFT, 0, offset)
    ABB_TEMPLATE_NAME = THEMES[SETTINGS.THEME_NAME or "Plain"].template
    FN_ABB_GET_WIDTH = THEMES[SETTINGS.THEME_NAME or "Plain"].calcWidth
end

-------------------------------------
--Settings Menu--
-------------------------------------
local function InitializeAddonMenu()
    local LAM2 = LibAddonMenu2

    LAM2:RegisterAddonPanel("ABB_Settings", {
        type = "panel",
        name = "Alternative Boss Bars",
        displayName = "Alternative Boss Bars",
        author = "|c943810BulDeZir|r",
        version = string.format('|c00FF00%s|r', 3.1),
        registerForRefresh = true,
        registerForDefaults = true,
    })

    LAM2:RegisterOptionControls("ABB_Settings", {
        {
            type = "checkbox",
            name = "Replace compass",
            tooltip = "If turned off, HP bars will show under the compass instead of replacing it.",
            getFunc = function() return SETTINGS.REPLACE_COMPASS end,
            setFunc = function(newValue)
                SETTINGS.REPLACE_COMPASS = newValue
                SetVisualSettings()
                RefreshAllBosses(true)
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Proportional Bars",
            tooltip = "Bosses with less max HP have shorter bars, and bars are sorted from most to least HP.",
            getFunc = function() return SETTINGS.SCALE_HP_PROPORTION end,
            setFunc = function(newValue)
                SETTINGS.SCALE_HP_PROPORTION = newValue
                RefreshAllBosses(true)
            end,
            default = false,
        },
        {
            type = "checkbox",
            name = "Include Combat Dummies",
            requiresReload = true,
            tooltip = "Show boss bar when fighting a dummy.",
            getFunc = function() return SETTINGS.INCLUDE_DUMMY end,
            setFunc = function(newValue)
                SETTINGS.INCLUDE_DUMMY = newValue
            end,
            default = false,
        },
        {
            type = "divider",
            height = 5,
            alpha = 1,
            width = "full"
        },
        {
            type = "dropdown",
            name = "Percentage Line Style",
            requiresReload = true,
            choices = {"Hard", "Soft"},
            getFunc = function() return SETTINGS.PERCENTAGE_LINE_STYLE end,
            setFunc = function(newValue)
                SETTINGS.PERCENTAGE_LINE_STYLE = newValue
                RefreshAllBosses()
            end,
            default = "Hard"
        },
        {
            type = "checkbox",
            name = "Show Default Percent Lines (75%, 50%, 25%)",
            getFunc = function() return SETTINGS.SHOW_DEFAULTS end,
            setFunc = function(newValue)
                SETTINGS.SHOW_DEFAULTS = newValue
                RefreshAllBosses()
            end,
            default = false,
        },
        {
            type = "checkbox",
            name = "Alert Notification",
            tooltip = "Whether the HP bar displays an alert for percent-based mechanics.",
            getFunc = function() return SETTINGS.NOTIFY_ALERT end,
            setFunc = function(newValue)
                SETTINGS.NOTIFY_ALERT = newValue
                RefreshAllBosses()
            end,
            default = false,
            width = "half"
        },
        {
            type = "slider",
            name = "Threshold (%)",
            tooltip = "Number of percent (%), BEFORE showing alert.",
            min = 0,
            max = 5,
            step = 1,
            getFunc = function() return SETTINGS.NOTIFY_BEFORE_PERCENT end,
            setFunc = function(newValue)
                SETTINGS.NOTIFY_BEFORE_PERCENT = zo_round(newValue)
                RefreshAllBosses()
            end,
            disabled = function() return not SETTINGS.NOTIFY_ALERT end,
            default = 2,
            width = "half"
        },
        {
            type = "dropdown",
            name = "Alert Type",
            tooltip = "'Icon' displays an icon near the HP total. 'Flash' makes the bar flash red.",
            choices = {"Icon", "Flash"},
            getFunc = function() return SETTINGS.NOTIFY_ALERT_TYPE end,
            setFunc = function(newValue)
                SETTINGS.NOTIFY_ALERT_TYPE = newValue
            end,
            disabled = function() return not SETTINGS.NOTIFY_ALERT end,
            default = "Flash"
        },
        {
            type = "divider",
            height = 5,
            alpha = 1,
            width = "full"
        },
        {
            type = "colorpicker",
            name = "HP Color Gradient Start",
            getFunc = function() return unpack(SETTINGS.HP_COLOR_START) end,    --(alpha is optional)
            setFunc = function(r,g,b,a)
                SETTINGS.HP_COLOR_START = { r,g,b }
                RefreshAllBosses(true)
            end,
            width = "half",
            default = ZO_POWER_BAR_GRADIENT_COLORS[COMBAT_MECHANIC_FLAGS_HEALTH][1],
        },
        {
            type = "colorpicker",
            name = "HP Color Gradient End",
            getFunc = function() return unpack(SETTINGS.HP_COLOR_END) end,    --(alpha is optional)
            setFunc = function(r,g,b,a)
                SETTINGS.HP_COLOR_END = { r,g,b }
                RefreshAllBosses(true)
            end,
            width = "half",
            default = ZO_POWER_BAR_GRADIENT_COLORS[COMBAT_MECHANIC_FLAGS_HEALTH][2],
        },
        {
            type = "dropdown",
            name = "Theme",
            requiresReload = true,
            choices = {"Plain", "Embellished"},
            getFunc = function() return SETTINGS.THEME_NAME end,
            setFunc = function(newValue)
                SETTINGS.THEME_NAME = newValue
                RefreshAllBosses()
            end,
            default = "Plain"
        },
    })
end

function ABB_Initialize(topLevelCtrl)

    local function OnAddOnLoaded(_, addonName)
        if addonName == NAME then

            SETTINGS = ZO_SavedVars:NewAccountWide("AltBossBarSavedVariables", SV_VER, nil, {
                REPLACE_COMPASS = true,
                SHOW_DEFAULTS = false,
                INCLUDE_DUMMY = false,
                PERCENTAGE_LINE_STYLE = "Hard",
                NOTIFY_ALERT = false,
                NOTIFY_BEFORE_PERCENT = 2,
                NOTIFY_ALERT_TYPE = "Flash",
                SCALE_HP_PROPORTION = false,
                HP_COLOR_START = DEFAULT_HP_COLOR_START,
                HP_COLOR_END = DEFAULT_HP_COLOR_END,
                THEME_NAME = "Plain"
            })

            InitializeAddonMenu()

            COMPASS_FRAME:SetBossBarHiddenForReason('modded', true)
            local fragment = ZO_SimpleSceneFragment:New(topLevelCtrl)
            HUD_SCENE:AddFragment(fragment)
            HUD_UI_SCENE:AddFragment(fragment)
            SetVisualSettings()

            InitBars(topLevelCtrl)
            topLevelCtrl:RegisterForEvent(EVENT_BOSSES_CHANGED, function(_, forceReset) RefreshAllBosses(forceReset) end)
            topLevelCtrl:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function() OnPlayerZoneChange(topLevelCtrl) end)
            topLevelCtrl:RegisterForEvent(EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function() RefreshAllBosses(true) end)
        end
    end

    EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end
