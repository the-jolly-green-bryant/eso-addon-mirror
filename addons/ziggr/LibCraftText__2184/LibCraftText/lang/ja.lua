LibCraftText        = LibCraftText        or {}
LibCraftText.DAILY  = LibCraftText.DAILY  or {}
LibCraftText.MASTER = LibCraftText.MASTER or {}


-- Table Setup ---------------------------------------------------------------
--
-- Constants and index values we use in later tables

                        -- For less typing
local bs = CRAFTING_TYPE_BLACKSMITHING   or 1
local cl = CRAFTING_TYPE_CLOTHIER        or 2
local en = CRAFTING_TYPE_ENCHANTING      or 3
local al = CRAFTING_TYPE_ALCHEMY         or 4
local pr = CRAFTING_TYPE_PROVISIONING    or 5
local ww = CRAFTING_TYPE_WOODWORKING     or 6
local jw = CRAFTING_TYPE_JEWELRYCRAFTING or 7

                        -- Identify which list of crafting materials.
LibCraftText.MAT_SET_ID = {
    LIGHT           = "mat_lgt"
,   MEDIUM          = "mat_med"
,   HEAVY           = "mat_hvy"
,   WOOD            = "mat_wood"
,   JEWELRY         = "mat_jewl"
}
                        -- For less typing
local mat_lgt       = LibCraftText.MAT_SET_ID.LIGHT
local mat_med       = LibCraftText.MAT_SET_ID.MEDIUM
local mat_hvy       = LibCraftText.MAT_SET_ID.HEAVY
local mat_wood      = LibCraftText.MAT_SET_ID.WOOD
local mat_jewl      = LibCraftText.MAT_SET_ID.JEWELRY

                        -- Identify which list of traits.
LibCraftText.TRAIT_SET_ID = {
    WEAPON          = "trait_weap"
,   ARMOR           = "trait_armr"
,   JEWELRY         = "trait_jewl"
}
                        -- For less typing
local trait_weap    = LibCraftText.TRAIT_SET_ID.WEAPON
local trait_armr    = LibCraftText.TRAIT_SET_ID.ARMOR
local trait_jewl    = LibCraftText.TRAIT_SET_ID.JEWELRY


-- Craftable Equipment -------------------------------------------------------
--
-- Answer the question "what gear item does this crafting quest require?"
-- An axe? Light robe? Wooden shield?

-- name             string that appears in daily crafting writs and tooltip
--                  text when crafting this item at a crafting station.
--
-- master_name      string that appears in a sealed master writ's tooltip,
--                  or an accepted master writ quest's conditions.
--                  SURPRISE! `master_name` does not always match `name`
--                  value in all languages. FR French heavy head piece
--                  is "heaume" most of the time, but "casque" in master writs.
--                  There are several examples of this mismatch, scattered
--                  throughout different languages. Or the particularly evil
--                  JP Japanese ring, which uses "リング" (phonetic "ringu")
--                  at the crafting station, but kanji "指輪" (yubi-wa, aka
--                  finger-ring) within daily crafting request condition text.
--
-- pattern_index    crafting index passed as an argument to ZOS API functions
--                  like GetSmithingPatternInfo() and others.
--
-- master_writ1     value for `writ1` field in sealed master writ item links.
--
-- crafting_type    Blacksmithing, Clothier, Woodworking, or Jewelry Crafting?
--
-- mat_set_id       Which set of crafting materials to use for this item?
--
-- trait_set_id     Which set of traits apply to this item?
--
-- name_2           FR French has a typo for Sash: "baudier" when it should
--                  be "baudrier". An extra name column helps match these
--                  and other surprises.
--
LibCraftText.ITEM = {
  ["H1_AXE"         ] = { name="斧"                    , master_name="斧"                         , pattern_index= 1, master_writ1=53, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H1_MACE"        ] = { name="メイス"                  , master_name="メイス"                       , pattern_index= 2, master_writ1=56, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H1_SWORD"       ] = { name="剣"                    , master_name="剣"                         , pattern_index= 3, master_writ1=59, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H2_BATTLE_AXE"  ] = { name="両手斧"                  , master_name="両手斧"                       , pattern_index= 4, master_writ1=68, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H2_MAUL"        ] = { name="大槌"                   , master_name="大槌"                        , pattern_index= 5, master_writ1=69, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H2_GREATSWORD"  ] = { name="大剣"                   , master_name="大剣"                        , pattern_index= 6, master_writ1=67, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["DAGGER"         ] = { name="短剣"                   , master_name="短剣"                        , pattern_index= 7, master_writ1=62, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["CUIRASS"        ] = { name="胸当て"                  , master_name="胸当て"                       , pattern_index= 8, master_writ1=46, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["SABATONS"       ] = { name="サバトン"                 , master_name="サバトン"                      , pattern_index= 9, master_writ1=50, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["GAUNTLETS"      ] = { name="篭手"                   , master_name="篭手"                        , pattern_index=10, master_writ1=52, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["HELM"           ] = { name="兜"                    , master_name="兜"                         , pattern_index=11, master_writ1=44, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["GREAVES"        ] = { name="グリーヴ"                 , master_name="グリーヴ"                      , pattern_index=12, master_writ1=49, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["PAULDRON"       ] = { name="ポールドロン"               , master_name="ポールドロン"                    , pattern_index=13, master_writ1=47, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["GIRDLE"         ] = { name="ガードル"                 , master_name="ガードル"                      , pattern_index=14, master_writ1=48, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }

, ["ROBE"           ] = { name="ローブ"                  , master_name="ローブ"                       , pattern_index= 1, master_writ1=28, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["JERKIN"         ] = { name="ジャーキン"                , master_name="ジャーキン"                     , pattern_index= 2, master_writ1=75, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["SHOES"          ] = { name="靴"                    , master_name="靴"                         , pattern_index= 3, master_writ1=32, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["GLOVES"         ] = { name="手袋"                   , master_name="手袋"                        , pattern_index= 4, master_writ1=34, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["HAT"            ] = { name="帽子"                   , master_name="帽子"                        , pattern_index= 5, master_writ1=26, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["BREECHES"       ] = { name="パンツ"                  , master_name="パンツ"                       , pattern_index= 6, master_writ1=31, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["EPAULETS"       ] = { name="肩当て"                  , master_name="肩当て"                       , pattern_index= 7, master_writ1=29, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr , name_2="肩当て"       }
, ["SASH"           ] = { name="サッシュ"                 , master_name="サッシュ"                      , pattern_index= 8, master_writ1=30, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr , name_2="サッシュ"      }
, ["JACK"           ] = { name="胴当て"                  , master_name="胴当て"                       , pattern_index= 9, master_writ1=37, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["BOOTS"          ] = { name="ブーツ"                  , master_name="ブーツ"                       , pattern_index=10, master_writ1=41, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["BRACERS"        ] = { name="腕当て"                  , master_name="腕当て"                       , pattern_index=11, master_writ1=43, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr , name_2="腕当て"       }
, ["HELMET"         ] = { name="兜"                    , master_name="兜"                         , pattern_index=12, master_writ1=35, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr , name_2="兜"         }
, ["GUARDS"         ] = { name="すね当て"                 , master_name="すね当て"                      , pattern_index=13, master_writ1=40, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["ARM_COPS"       ] = { name="アームカップ"               , master_name="アームカップ"                    , pattern_index=14, master_writ1=38, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["BELT"           ] = { name="ベルト"                  , master_name="ベルト"                       , pattern_index=15, master_writ1=39, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }

, ["BOW"            ] = { name="弓"                    , master_name="弓"                         , pattern_index= 1, master_writ1=70, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["INFERNO_STAFF"  ] = { name="業火の杖"                 , master_name="業火の杖"                      , pattern_index= 3, master_writ1=72, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["ICE_STAFF"      ] = { name="氷の杖"                  , master_name="氷の杖"                       , pattern_index= 4, master_writ1=73, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["LIGHTNING_STAFF"] = { name="稲妻の杖"                 , master_name="稲妻の杖"                      , pattern_index= 5, master_writ1=74, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["RESTO_STAFF"    ] = { name="回復の杖"                 , master_name="回復の杖"                      , pattern_index= 6, master_writ1=71, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["SHIELD"         ] = { name="盾"                    , master_name="盾"                         , pattern_index= 2, master_writ1=65, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_armr }

, ["NECKLACE"       ] = { name="ネックレス"                , master_name="ネックレス"                     , pattern_index= 2, master_writ1=18, crafting_type=jw, mat_set_id=mat_jewl, trait_set_id=trait_jewl , name_2="ネックレス"     }
, ["RING"           ] = { name="リング"                  , master_name="指輪"                        , pattern_index= 1, master_writ1=24, crafting_type=jw, mat_set_id=mat_jewl, trait_set_id=trait_jewl }
}


-- Craftable Food and Drink --------------------------------------------------
--
-- name                 string that appears in "Craft Banana Surprise"
--
-- food_item_id         item_id for crafted food/drink
--
-- recipe_item_id       item_id for recipe to learn how to make this food/drink
--
-- recipe_list_index    API value for GetRecipeResultItemInfo() and others
--
-- recipe_index         API value for GetRecipeResultItemInfo() and others
--
LibCraftText.RECIPE = {
-- daily
  ["AETHERIAL_TEA"                      ] = { name="エセリアルティー"                              , food_item_id=033602, recipe_item_id=046049, recipe_list_index=  9, recipe_index= 31, name_2="エセリアルティー"    }
, ["ALIKR_BEETS_WITH_GOAT_CHEESE"       ] = { name="アリクルのビートの山羊乳チーズ添え"                     , food_item_id=028338, recipe_item_id=045899, recipe_list_index=  3, recipe_index= 13}
, ["BAKED_APPLES"                       ] = { name="焼きリンゴ"                                 , food_item_id=033837, recipe_item_id=045889, recipe_list_index=  2, recipe_index=  1}
, ["BAKED_POTATO"                       ] = { name="ベイクドポテト"                               , food_item_id=028354, recipe_item_id=045912, recipe_list_index=  3, recipe_index=  2}
, ["BANANA_SURPRISE"                    ] = { name="びっくりバナナ"                               , food_item_id=028281, recipe_item_id=045913, recipe_list_index=  2, recipe_index=  2}
, ["BARLEY_NECTAR"                      ] = { name="大麦のビール"                                , food_item_id=033624, recipe_item_id=045984, recipe_list_index=  8, recipe_index= 14}
, ["BATTAGLIR_CHOWDER"                  ] = { name="バタグリアのチャウダー"                           , food_item_id=028394, recipe_item_id=045946, recipe_list_index=  3, recipe_index= 15}
, ["BITTERLEMON_TEA"                    ] = { name="ビターレモンティー"                             , food_item_id=028457, recipe_item_id=046000, recipe_list_index=  9, recipe_index= 13}
, ["BLUE_ROAD_MARATHON"                 ] = { name="ブルーロード・マラソン"                           , food_item_id=028513, recipe_item_id=046030, recipe_list_index= 10, recipe_index= 25}
, ["BOG_IRON_ALE"                       ] = { name="泥鉄鉱のエール"                               , food_item_id=028405, recipe_item_id=045971, recipe_list_index=  8, recipe_index=  4}
, ["BRETON_PORK_SAUSAGE"                ] = { name="ブレトンのポークソーセージ"                         , food_item_id=028342, recipe_item_id=045900, recipe_list_index=  1, recipe_index= 13}
, ["CARROT_SOUP"                        ] = { name="ニンジンスープ"                               , food_item_id=028321, recipe_item_id=045887, recipe_list_index=  3, recipe_index=  1}
, ["CHICKEN_BREAST"                     ] = { name="鶏の胸肉"                                  , food_item_id=033819, recipe_item_id=045935, recipe_list_index=  1, recipe_index=  3}
, ["CHORROL_CORN_ON_THE_COB"            ] = { name="コロールの軸付きトウモロコシ"                        , food_item_id=033514, recipe_item_id=045929, recipe_list_index=  3, recipe_index= 20}
, ["CINNAMON_GRAPE_JELLY"               ] = { name="グレープシナモンゼリー"                           , food_item_id=042790, recipe_item_id=045907, recipe_list_index=  2, recipe_index= 19}
, ["CLARIFIED_SYRAH_WINE"               ] = { name="シラーワインの蒸留酒"                            , food_item_id=028409, recipe_item_id=045972, recipe_list_index=  8, recipe_index=  7, name_2="シラーワインの蒸留酒"  }
, ["COMELY_WENCH_WHISKEY"               ] = { name="カムリーウェンチ・ウイスキー"                        , food_item_id=028402, recipe_item_id=046048, recipe_list_index=  8, recipe_index= 31}
, ["CYRODILIC_CORNBREAD"                ] = { name="シロディールのコーンブレッド"                        , food_item_id=033897, recipe_item_id=045958, recipe_list_index=  3, recipe_index= 25}
, ["CYRODILIC_PUMPKIN_FRITTERS"         ] = { name="シロディールのカボチャのフリッター"                     , food_item_id=033789, recipe_item_id=045931, recipe_list_index=  2, recipe_index= 20}
, ["ELENHIR_ROAST_ANTELOPE"             ] = { name="エリンヒルの羚羊の肉のロースト"                       , food_item_id=033520, recipe_item_id=045930, recipe_list_index=  1, recipe_index= 20}
, ["ELTHERIC_HOOCH"                     ] = { name="エルセリックの安酒"                             , food_item_id=028417, recipe_item_id=045974, recipe_list_index=  8, recipe_index= 13, name_2="エルセリックの安酒"   }
, ["FIRSTHOLD_FRUIT_AND_CHEESE_PLATE"   ] = { name="ファーストホールドの果実とチーズのプレート"                 , food_item_id=068236, recipe_item_id=068192, recipe_list_index=  2, recipe_index= 40}
, ["FISHY_STICK"                        ] = { name="魚のフライ"                                 , food_item_id=033526, recipe_item_id=045888, recipe_list_index=  1, recipe_index=  1}
, ["FOUR_EYE_GROG"                      ] = { name="4つ目のグロッグ"                              , food_item_id=033612, recipe_item_id=045982, recipe_list_index=  8, recipe_index=  8}
, ["GARLIC_MASHED_POTATOES"             ] = { name="ガーリックマッシュポテト"                          , food_item_id=028346, recipe_item_id=045905, recipe_list_index=  3, recipe_index= 19}
, ["GARLIC_PUMPKIN_SEEDS"               ] = { name="カボチャの種のニンニク炒め"                         , food_item_id=033490, recipe_item_id=045925, recipe_list_index=  2, recipe_index= 14}
, ["GINGER_WHEAT_BEER"                  ] = { name="ジンジャービール"                              , food_item_id=033963, recipe_item_id=045993, recipe_list_index=  8, recipe_index= 18}
, ["GODS_BLIND_ME"                      ] = { name="ゴッズ・ブラインド・ミー"                          , food_item_id=028433, recipe_item_id=045978, recipe_list_index=  8, recipe_index= 25, name_2="ゴッズ・ブラインド・ミー"}
, ["GOLDEN_LAGER"                       ] = { name="ゴールデンラガー"                              , food_item_id=033933, recipe_item_id=045988, recipe_list_index=  8, recipe_index=  3}
, ["GOSSAMER_MAZTE"                     ] = { name="手の込んだマッツェ"                             , food_item_id=033957, recipe_item_id=045992, recipe_list_index=  8, recipe_index= 15}
, ["GRANDPAS_BEDTIME_TONIC"             ] = { name="グランパのベッドタイム・トニック"                      , food_item_id=028444, recipe_item_id=046050, recipe_list_index= 10, recipe_index= 31}
, ["GRAPE_PRESERVES"                    ] = { name="ブドウのジャム"                               , food_item_id=033825, recipe_item_id=045936, recipe_list_index=  2, recipe_index=  3}
, ["HAGRAVENS_TONIC"                    ] = { name="ハグレイヴンのトニック"                           , food_item_id=068263, recipe_item_id=068219, recipe_list_index= 10, recipe_index= 42}
, ["HARE_IN_GARLIC_SAUCE"               ] = { name="野兎のガーリックソース添え"                         , food_item_id=033581, recipe_item_id=045953, recipe_list_index=  1, recipe_index= 21, name_2="野兎のガーリックソース添え"}
, ["HEARTY_GARLIC_CORN_CHOWDER"         ] = { name="ヘルシーなガーリックとコーンのチャウダー"                  , food_item_id=068239, recipe_item_id=068195, recipe_list_index=  3, recipe_index= 40}
, ["HONEY_RYE"                          ] = { name="ハニーライ・ウイスキー"                           , food_item_id=028421, recipe_item_id=045975, recipe_list_index=  8, recipe_index= 16}
, ["JERALL_VIEW_INN_CARROT_CAKE"        ] = { name="宿屋〈ジェラールビュー〉のニンジンケーキ"                  , food_item_id=033575, recipe_item_id=045952, recipe_list_index=  3, recipe_index= 21}
, ["LEMON_FLOWER_MAZTE"                 ] = { name="レモンフラワーのマッツェ"                          , food_item_id=033945, recipe_item_id=045990, recipe_list_index=  8, recipe_index=  9}
, ["LILMOTH_GARLIC_HAGFISH"             ] = { name="リルモスのニンニクのヌタウナギ焼き"                     , food_item_id=068235, recipe_item_id=068191, recipe_list_index=  1, recipe_index= 42}
, ["LUSTY_ARGONIAN_MAID_MAZTE"          ] = { name="好色なアルゴニアンの侍女のマッツェ"                     , food_item_id=068276, recipe_item_id=068232, recipe_list_index= 14, recipe_index= 31, name_2="好色なアルゴニアンの侍女のマッツェ"}
, ["MAMMOTH_SNOUT_PIE"                  ] = { name="マンモスの鼻のパイ"                             , food_item_id=033903, recipe_item_id=045959, recipe_list_index=  1, recipe_index= 25}
, ["MAORMER_TEA"                        ] = { name="マオマーティー"                               , food_item_id=028465, recipe_item_id=046002, recipe_list_index=  9, recipe_index= 19}
, ["MARKARTH_MEAD"                      ] = { name="マルカルスのハチミツ酒"                           , food_item_id=068257, recipe_item_id=068213, recipe_list_index=  8, recipe_index= 42}
, ["MAZTE"                              ] = { name="マッツェ"                                  , food_item_id=033606, recipe_item_id=045981, recipe_list_index=  8, recipe_index=  5}
, ["MERMAID_WHISKEY"                    ] = { name="マーメイド・ウイスキー"                           , food_item_id=033630, recipe_item_id=045985, recipe_list_index=  8, recipe_index= 17}
, ["MILLET_STUFFED_PORK_LOIN"           ] = { name="雑穀の豚腰肉包み焼き"                            , food_item_id=043088, recipe_item_id=045965, recipe_list_index=  1, recipe_index= 31}
, ["MULLED_WINE"                        ] = { name="ホットワイン"                                , food_item_id=033969, recipe_item_id=045994, recipe_list_index=  8, recipe_index= 21}
, ["MUTHSERAS_REMORSE"                  ] = { name="ムスセラの良心の呵責"                            , food_item_id=068260, recipe_item_id=068216, recipe_list_index=  9, recipe_index= 42}
, ["NEREID_WINE"                        ] = { name="ネレイドワイン"                               , food_item_id=033975, recipe_item_id=045995, recipe_list_index=  8, recipe_index= 24}
, ["NIBENESE_GARLIC_CARROTS"            ] = { name="ニベン人のニンジンのニンニク炒め"                      , food_item_id=033478, recipe_item_id=045923, recipe_list_index=  3, recipe_index= 14}
, ["NUT_BROWN_ALE"                      ] = { name="ナット・ブラウンエール"                           , food_item_id=028401, recipe_item_id=045970, recipe_list_index=  8, recipe_index=  1}
, ["ORCREST_GARLIC_APPLE_JELLY"         ] = { name="オークレストのニンニクとリンゴのゼリー"                   , food_item_id=043094, recipe_item_id=045966, recipe_list_index=  2, recipe_index= 31}
, ["PELLITINE_TOMATO_RICE"              ] = { name="ペレタインのトマトライス"                          , food_item_id=042814, recipe_item_id=045901, recipe_list_index=  2, recipe_index= 13}
, ["RED_RYE_BEER"                       ] = { name="赤いライ麦ビール"                              , food_item_id=033600, recipe_item_id=045980, recipe_list_index=  8, recipe_index=  2}
, ["REDORAN_PEPPERED_MELON"             ] = { name="レドランのペッパードメロン"                         , food_item_id=033552, recipe_item_id=045948, recipe_list_index=  2, recipe_index= 15}
, ["ROAST_CORN"                         ] = { name="焼きトウモロコシ"                              , food_item_id=033813, recipe_item_id=045934, recipe_list_index=  3, recipe_index=  3}
, ["RYE_IN_YOUR_EYE"                    ] = { name="瞳に映るライ・ウイスキー"                          , food_item_id=028429, recipe_item_id=045977, recipe_list_index=  8, recipe_index= 22}
, ["SEAFLOWER_TEA"                      ] = { name="海花茶"                                   , food_item_id=034005, recipe_item_id=046018, recipe_list_index=  9, recipe_index= 15}
, ["SENCHAL_CURRY_FISH_AND_RICE"        ] = { name="センシャルのシーフードカレー"                        , food_item_id=028350, recipe_item_id=045906, recipe_list_index=  1, recipe_index= 19}
, ["SKYRIM_JAZBAY_CROSTATA"             ] = { name="スカイリムのジャズベイ・クロスタータ"                    , food_item_id=033909, recipe_item_id=045960, recipe_list_index=  2, recipe_index= 25}
, ["SORRY_HONEY_LAGER"                  ] = { name="ソーリー、ハニーラガー"                           , food_item_id=033642, recipe_item_id=045987, recipe_list_index=  8, recipe_index= 23}
, ["SOUR_MASH"                          ] = { name="すっぱい麦芽汁"                               , food_item_id=028425, recipe_item_id=045976, recipe_list_index=  8, recipe_index= 19}
, ["SPICEBERRY_CHAI"                    ] = { name="スパイスベリーのチャイ"                           , food_item_id=033684, recipe_item_id=046012, recipe_list_index=  9, recipe_index= 20}
, ["SPICED_MAZTE"                       ] = { name="香辛料入りマッツェ"                             , food_item_id=033636, recipe_item_id=045986, recipe_list_index=  8, recipe_index= 20}
, ["STORMHOLD_BAKED_BANANAS"            ] = { name="ストームホールドの焼きバナナ"                        , food_item_id=033587, recipe_item_id=045954, recipe_list_index=  2, recipe_index= 21}
, ["SURILIE_SYRAH_WINE"                 ] = { name="スリリーのシラーワイン"                           , food_item_id=033939, recipe_item_id=045989, recipe_list_index=  8, recipe_index=  6}
, ["TORVAL_MINT_TEA"                    ] = { name="トルヴァルミントティー"                           , food_item_id=034017, recipe_item_id=046020, recipe_list_index=  9, recipe_index= 21}
, ["TREACLEBERRY_TEA"                   ] = { name="トリークルベリーティー"                           , food_item_id=033672, recipe_item_id=046010, recipe_list_index=  9, recipe_index= 14}
, ["TWO_ZEPHYR_TEA"                     ] = { name="トゥーゼファーティー"                            , food_item_id=028473, recipe_item_id=046004, recipe_list_index=  9, recipe_index= 25}
, ["VENISON_PASTY"                      ] = { name="鹿肉のパスティ"                               , food_item_id=028398, recipe_item_id=045947, recipe_list_index=  1, recipe_index= 15}
, ["WEST_WEALD_CORN_CHOWDER"            ] = { name="ウェストウィールドのコーンチャウダー"                    , food_item_id=032160, recipe_item_id=045964, recipe_list_index=  3, recipe_index= 31}
, ["WHITERUN_CHEESE_BAKED_TROUT"        ] = { name="ホワイトランのマスのチーズ焼き"                       , food_item_id=033484, recipe_item_id=045924, recipe_list_index=  1, recipe_index= 14}

-- master
, ["CAPON_TOMATO_BEET_CASSEROLE"        ] = { name="肥育鶏とトマトビーツのキャセロール"                     , food_item_id=068251, recipe_item_id=068207, recipe_list_index=  7, recipe_index= 28}
, ["JUGGED_RABBIT_IN_PRESERVES"         ] = { name="ジャムで煮込んだ兎肉"                            , food_item_id=068252, recipe_item_id=068208, recipe_list_index=  7, recipe_index= 29}
, ["LONGFIN_PASTY_WITH_MELON_SAUCE"     ] = { name="ロングフィンのパイのメロンソース添え"                    , food_item_id=068253, recipe_item_id=068209, recipe_list_index=  7, recipe_index= 30, name_2="ロングフィンのパイのメロンソース添え"}
, ["LUSTY_ARGONIAN_MAID_MAZTE"          ] = { name="好色なアルゴニアンの侍女のマッツェ"                     , food_item_id=068276, recipe_item_id=068232, recipe_list_index= 14, recipe_index= 31, name_2="好色なアルゴニアンの侍女のマッツェ"}
, ["ORCREST_AGONY_PALE_ALE"             ] = { name="オークレストの苦悶のペールエール"                      , food_item_id=068275, recipe_item_id=068231, recipe_list_index= 14, recipe_index= 30, name_2="オークレストの苦悶のペールエール"}
, ["ORZORGAS_BLOOD_PRICE_PIE"           ] = { name="オーゾーガのブラッド・プライス・パイ"                    , food_item_id=071058, recipe_item_id=071062, recipe_list_index= 16, recipe_index=  3, name_2="オーゾーガのブラッド・プライス・パイ"}
, ["ORZORGAS_RED_FROTHGAR"              ] = { name="オーゾーガのレッド・フロスガー"                       , food_item_id=071056, recipe_item_id=071060, recipe_list_index= 15, recipe_index= 14, name_2="オーゾーガのレッド・フロスガー"}
, ["ORZORGAS_SMOKED_BEAR_HAUNCH"        ] = { name="オーゾーガの熊の腰肉の燻製"                         , food_item_id=071059, recipe_item_id=071063, recipe_list_index= 16, recipe_index=  4, name_2="オーゾーガの熊の腰肉の燻製"}
, ["ORZORGAS_TRIPE_TRIFLE_POCKET"       ] = { name="オーゾーガの牛の内臓ミンチ入りのパン"                    , food_item_id=071057, recipe_item_id=071061, recipe_list_index= 16, recipe_index=  2, name_2="オーゾーガの牛の内臓ミンチ入りのパン"}
, ["PSIJIC_AMBROSIA"                    ] = { name="サイジックのアンブロージア"                         , food_item_id=064221, recipe_item_id=064223, recipe_list_index= 15, recipe_index=  1, name_2="サイジックのアンブロージア"}
, ["SENCHE_TIGER_SINGLE_MALT"           ] = { name="センチタイガーのシングルモルト"                       , food_item_id=068273, recipe_item_id=068229, recipe_list_index= 14, recipe_index= 28, name_2="センチタイガーのシングルモルト"}
, ["VELOTHI_VIEW_VINTAGE_MALBEC"        ] = { name="ヴェロシビューのビンテージマルベックワイン"                 , food_item_id=068274, recipe_item_id=068230, recipe_list_index= 14, recipe_index= 29, name_2="ヴェロシビューのビンテージマルベックワイン"}
, ["WITHERED_TREE_INN_VENISON_POT_ROAST"] = { name="ウィサードツリーの鹿肉のポットロースト"                   , food_item_id=068254, recipe_item_id=068210, recipe_list_index=  7, recipe_index= 31, name_2="ロングフィンのパイのメロンソース添え"}
}


-- Materials -----------------------------------------------------------------
--
-- Answer the question "what material does this crafting quest require?"
-- Rubetite? Jute? Maple?
--
-- name             string that appears in material requested in daily
--                  crafting quests and master writ conditions.
--
-- crafting_type    CRAFTING_TYPE_BLACKSMITHING, _CLOTHIER, others.
--
-- Equipment materials ----
--
--                  "Craft a Normal Rubedite Sword"
--                  "Craft a Pewter Ring"
--
-- level_index      ordinal 1..10 (or 1..5) to sort materials by level.
--
-- material_index   crafting index passed as an argument to ZOS API functions
--                  like GetSmithingPatternResultLink() and others
--
-- master_writ2     value for `writ2` field in sealed master writ item links.
--
-- mat_set_id       What set of crafting materials is this material in?
--
-- name_2,          A second or third name to search for when parsing
-- name_3           materials from writ text.
--
-- Alchemy and Enchanting Materials ----
--
--                  "Acquire Mudcrab Chitin"
--                  "Craft Strong Glyph of Health With Ta
--
-- item_id          ZOS itemId for use in itemLinks and other APIness.
--
-- rank             Alchemy "Solvent Proficiency" rank to use this solvent.
-- potion_name      "sip" portion of "sip of health"
-- poison_name      "ix" portion of "drain health poison ix"
--
LibCraftText.MATERIAL = {
  ["IRON"                    ] = { name="鉄"                              , crafting_type=bs, level_index= 1, material_index= 1, master_writ2=  1, mat_set_id=mat_hvy  }
, ["STEEL"                   ] = { name="鋼鉄"                             , crafting_type=bs, level_index= 2, material_index= 8, master_writ2=  9, mat_set_id=mat_hvy  }
, ["ORICHALC"                ] = { name="オリハルコン"                         , crafting_type=bs, level_index= 3, material_index=13, master_writ2=156, mat_set_id=mat_hvy  }
, ["DWARVEN"                 ] = { name="ドワーフ"                           , crafting_type=bs, level_index= 4, material_index=18, master_writ2=160, mat_set_id=mat_hvy  , name_2="ドワーフ"           }
, ["EBONY"                   ] = { name="黒檀"                             , crafting_type=bs, level_index= 5, material_index=23, master_writ2=164, mat_set_id=mat_hvy  , name_2="黒檀"             }
, ["CALCINIUM"               ] = { name="カルシニウム"                         , crafting_type=bs, level_index= 6, material_index=26, master_writ2=168, mat_set_id=mat_hvy  }
, ["GALATITE"                ] = { name="ガラタイト"                          , crafting_type=bs, level_index= 7, material_index=29, master_writ2=172, mat_set_id=mat_hvy  }
, ["QUICKSILVER"             ] = { name="水銀"                             , crafting_type=bs, level_index= 8, material_index=32, master_writ2=176, mat_set_id=mat_hvy  }
, ["VOIDSTEEL"               ] = { name="虚無の鉄"                           , crafting_type=bs, level_index= 9, material_index=34, master_writ2=180, mat_set_id=mat_hvy  }
, ["RUBEDITE"                ] = { name="ルベダイト"                          , crafting_type=bs, level_index=10, material_index=40, master_writ2=188, mat_set_id=mat_hvy  }

, ["JUTE"                    ] = { name="手織り布"                           , crafting_type=cl, level_index= 1, material_index= 1, master_writ2=  5, mat_set_id=mat_lgt  , name_2="手織り布"            }
, ["LINEN"                   ] = { name="リネン"                            , crafting_type=cl, level_index= 2, material_index= 8, master_writ2= 45, mat_set_id=mat_lgt  }
, ["COTTON"                  ] = { name="コットン"                           , crafting_type=cl, level_index= 3, material_index=13, master_writ2= 47, mat_set_id=mat_lgt  }
, ["SPIDERSILK"              ] = { name="スパイダーシルク"                       , crafting_type=cl, level_index= 4, material_index=18, master_writ2= 49, mat_set_id=mat_lgt  }
, ["EBONTHREAD"              ] = { name="エボンスレッド"                        , crafting_type=cl, level_index= 5, material_index=23, master_writ2= 51, mat_set_id=mat_lgt  }
, ["KRESH"                   ] = { name="クレッシュ"                          , crafting_type=cl, level_index= 6, material_index=26, master_writ2=125, mat_set_id=mat_lgt  }
, ["IRONTHREAD"              ] = { name="アイアンスレッド"                       , crafting_type=cl, level_index= 7, material_index=29, master_writ2=126, mat_set_id=mat_lgt  , name_2="アイアンスレッド"        }
, ["SILVERWEAVE"             ] = { name="シルバーウィーブ"                       , crafting_type=cl, level_index= 8, material_index=32, master_writ2=127, mat_set_id=mat_lgt  }
, ["SHADOWSPUN"              ] = { name="影の布"                            , crafting_type=cl, level_index= 9, material_index=34, master_writ2=128, mat_set_id=mat_lgt  }
, ["ANCESTOR_SILK"           ] = { name="先人のシルク"                         , crafting_type=cl, level_index=10, material_index=40, master_writ2=194, mat_set_id=mat_lgt  , name_2="先人のシルク"          }

, ["RAWHIDE"                 ] = { name="生皮"                             , crafting_type=cl, level_index= 1, material_index= 1, master_writ2=148, mat_set_id=mat_med  }
, ["HIDE"                    ] = { name="皮"                              , crafting_type=cl, level_index= 2, material_index= 8, master_writ2=154, mat_set_id=mat_med  }
, ["LEATHER"                 ] = { name="革"                              , crafting_type=cl, level_index= 3, material_index=13, master_writ2=158, mat_set_id=mat_med  }
, ["FULL_LEATHER"            ] = { name="フルレザー"                          , crafting_type=cl, level_index= 4, material_index=18, master_writ2=162, mat_set_id=mat_med  }
, ["FELL_HIDE"               ] = { name="フェルハイド"                         , crafting_type=cl, level_index= 5, material_index=23, master_writ2=166, mat_set_id=mat_med  }
, ["BRIGANDINE"              ] = { name="ブリガンダイン"                        , crafting_type=cl, level_index= 6, material_index=26, master_writ2=170, mat_set_id=mat_med  , name_2="ブリガンダイン"         }
, ["IRONHIDE"                ] = { name="アイアンハイド"                        , crafting_type=cl, level_index= 7, material_index=29, master_writ2=174, mat_set_id=mat_med  }
, ["SUPERB"                  ] = { name="最上"                             , crafting_type=cl, level_index= 8, material_index=32, master_writ2=131, mat_set_id=mat_med  , name_2="最上"              }
, ["SHADOWHIDE"              ] = { name="シャドウハイド"                        , crafting_type=cl, level_index= 9, material_index=34, master_writ2=132, mat_set_id=mat_med  }
, ["RUBEDO_LEATHER"          ] = { name="ルベドレザー"                         , crafting_type=cl, level_index=10, material_index=40, master_writ2=190, mat_set_id=mat_med  }

, ["MAPLE"                   ] = { name="カエデ"                            , crafting_type=ww, level_index= 1, material_index= 1, master_writ2=  2, mat_set_id=mat_wood }
, ["OAK"                     ] = { name="カシ"                             , crafting_type=ww, level_index= 2, material_index= 8, master_writ2= 18, mat_set_id=mat_wood }
, ["BEECH"                   ] = { name="ブナノキ"                           , crafting_type=ww, level_index= 3, material_index=13, master_writ2= 20, mat_set_id=mat_wood }
, ["HICKORY"                 ] = { name="ヒッコリー"                          , crafting_type=ww, level_index= 4, material_index=18, master_writ2= 22, mat_set_id=mat_wood }
, ["YEW"                     ] = { name="イチイ"                            , crafting_type=ww, level_index= 5, material_index=23, master_writ2= 24, mat_set_id=mat_wood }
, ["BIRCH"                   ] = { name="カバノキ"                           , crafting_type=ww, level_index= 6, material_index=26, master_writ2=133, mat_set_id=mat_wood }
, ["ASH"                     ] = { name="アッシュ"                           , crafting_type=ww, level_index= 7, material_index=29, master_writ2=134, mat_set_id=mat_wood }
, ["MAHOGANY"                ] = { name="マホガニー"                          , crafting_type=ww, level_index= 8, material_index=32, master_writ2=135, mat_set_id=mat_wood }
, ["NIGHTWOOD"               ] = { name="ナイトウッド"                         , crafting_type=ww, level_index= 9, material_index=34, master_writ2=136, mat_set_id=mat_wood }
, ["RUBY_ASH"                ] = { name="ルビーアッシュ"                        , crafting_type=ww, level_index=10, material_index=40, master_writ2=192, mat_set_id=mat_wood }

, ["PEWTER"                  ] = { name="ピューター"                          , crafting_type=jw, level_index= 1, material_index= 1, master_writ2=  6, mat_set_id=mat_jewl }
, ["COPPER"                  ] = { name="銅"                              , crafting_type=jw, level_index= 2, material_index=13, master_writ2= 56, mat_set_id=mat_jewl }
, ["SILVER"                  ] = { name="銀"                              , crafting_type=jw, level_index= 3, material_index=26, master_writ2=137, mat_set_id=mat_jewl }
, ["ELECTRUM"                ] = { name="琥珀金"                            , crafting_type=jw, level_index= 4, material_index=33, master_writ2=139, mat_set_id=mat_jewl , name_2="琥珀金"            }
, ["PLATINUM"                ] = { name="プラチナ"                           , crafting_type=jw, level_index= 5, material_index=40, master_writ2=255, mat_set_id=mat_jewl }

, ["BLESSED_THISTLE"         ] = { name="聖なるシッスル"                        , crafting_type=al, item_id= 30157 }
, ["BLUE_ENTOLOMA"           ] = { name="アオイッポンシメジ"                      , crafting_type=al, item_id= 30148 }
, ["BUGLOSS"                 ] = { name="ムラサキ草"                          , crafting_type=al, item_id= 30160 }
, ["COLUMBINE"               ] = { name="オダマキ"                           , crafting_type=al, item_id= 30164 }
, ["CORN_FLOWER"             ] = { name="コーンフラワー"                        , crafting_type=al, item_id= 30161 }
, ["DRAGONTHORN"             ] = { name="ドラゴンソーン"                        , crafting_type=al, item_id= 30162 }
, ["EMETIC_RUSSULA"          ] = { name="ドクベニタケ"                         , crafting_type=al, item_id= 30151 }
, ["IMP_STOOL"               ] = { name="木椅子キノコ"                         , crafting_type=al, item_id= 30156 }
, ["LADYS_SMOCK"             ] = { name="タネツケバナ"                         , crafting_type=al, item_id= 30158 }
, ["LUMINOUS_RUSSULA"        ] = { name="光ベニタケ"                          , crafting_type=al, item_id= 30155 }
, ["MOUNTAIN_FLOWER"         ] = { name="山の花"                            , crafting_type=al, item_id= 30163 }
, ["NAMIRAS_ROT"             ] = { name="ナミラキノコ"                         , crafting_type=al, item_id= 30153 }
, ["NIRNROOT"                ] = { name="ニルンルート"                         , crafting_type=al, item_id= 30165 }
, ["STINKHORN"               ] = { name="スッポンタケ"                         , crafting_type=al, item_id= 30149 }
, ["VIOLET_COPRINUS"         ] = { name="ムラサキヒトヨタケ"                      , crafting_type=al, item_id= 30152 , name_2="ムラサキヒトヨタケ"          }
, ["WATER_HYACINTH"          ] = { name="ホテイアオイ"                         , crafting_type=al, item_id= 30166 }
, ["WHITE_CAP"               ] = { name="白かさキノコ"                         , crafting_type=al, item_id= 30154 }
, ["WORMWOOD"                ] = { name="ニガヨモギ"                          , crafting_type=al, item_id= 30159 }
, ["BEETLE_SCUTTLE"          ] = { name="ビートルスカトル"                       , crafting_type=al, item_id= 77583 }
, ["BUTTERFLY_WING"          ] = { name="蝶の羽"                            , crafting_type=al, item_id= 77585 }
, ["FLESHFLY_LARVA"          ] = { name="ニクバエの幼虫"                        , crafting_type=al, item_id= 77587 }
, ["MUDCRAB_CHITIN"          ] = { name="マッドクラブキチン"                      , crafting_type=al, item_id= 77591 }
, ["NIGHTSHADE"              ] = { name="ベラドンナ"                          , crafting_type=al, item_id= 77590 }
, ["SCRIB_JELLY"             ] = { name="スクリブのゼリー"                       , crafting_type=al, item_id= 77589 }
, ["SPIDER_EGG"              ] = { name="蜘蛛の卵"                           , crafting_type=al, item_id= 77584 }
, ["TORCHBUG_THORAX"         ] = { name="ホタルの腹部"                         , crafting_type=al, item_id= 77581 }
, ["CLAM_GALL"               ] = { name="クラム・ゴル"                         , crafting_type=al, item_id=139020 }
, ["POWDERED_MOTHER_OF_PEARL"] = { name="真珠貝のパウダー"                       , crafting_type=al, item_id=139019 }

, ["NATURAL_WATER"           ] = { name="自然水"                            , crafting_type=al, item_id=   883 , name_2="自然水"                , rank=1, potion_name="雫"                       }
, ["CLEAR_WATER"             ] = { name="清水"                             , crafting_type=al, item_id=  1187                               , rank=2, potion_name="生薬"                      }
, ["PRISTINE_WATER"          ] = { name="清浄水"                            , crafting_type=al, item_id=  4570 , name_2="清浄水"                , rank=3, potion_name="飲み薬"                     , potion_name2="飲み薬"                      }
, ["CLEANSED_WATER"          ] = { name="浄化水"                            , crafting_type=al, item_id= 23265 , name_2="浄化水"                , rank=4, potion_name="薬"                       }
, ["FILTERED_WATER"          ] = { name="ろ過水"                            , crafting_type=al, item_id= 23266 , name_2="ろ過水"                , rank=5, potion_name="液体薬"                     }
, ["PURIFIED_WATER"          ] = { name="神聖水"                            , crafting_type=al, item_id= 23267 , name_2="神聖水"                , rank=6, potion_name="霊薬"                      }
, ["CLOUD_MIST"              ] = { name="霧の雲"                            , crafting_type=al, item_id= 23268                               , rank=7, potion_name="万能薬"                     }
, ["STAR_DEW"                ] = { name="星のしずく"                          , crafting_type=al, item_id= 64500                               , rank=8, potion_name="蒸留"                      }
, ["LORKHANS_TEARS"          ] = { name="ロルカーンの涙"                        , crafting_type=al, item_id= 64501                               , rank=9, potion_name="エキス"                     }

, ["GREASE"                  ] = { name="獣油"                             , crafting_type=al, item_id= 75357                               , rank=1, poison_name="1"                       }
, ["ICHOR"                   ] = { name="イコル"                            , crafting_type=al, item_id= 75358                               , rank=2, poison_name="2"                       }
, ["SLIME"                   ] = { name="粘液"                             , crafting_type=al, item_id= 75359                               , rank=3, poison_name="3"                       }
, ["GALL"                    ] = { name="胆嚢"                             , crafting_type=al, item_id= 75360                               , rank=4, poison_name="4"                       }
, ["TEREBINTHINE"            ] = { name="テレピン"                           , crafting_type=al, item_id= 75361                               , rank=5, poison_name="5"                       }
, ["PITCH_BILE"              ] = { name="黒の胆汁"                           , crafting_type=al, item_id= 75362                               , rank=6, poison_name="6"                       }
, ["TARBLACK"                ] = { name="ターブラック"                         , crafting_type=al, item_id= 75363                               , rank=7, poison_name="7"                       }
, ["NIGHT_OIL"               ] = { name="夜の油"                            , crafting_type=al, item_id= 75364                               , rank=8, poison_name="8"                       }
, ["ALKAHEST"                ] = { name="アルカヘスト"                         , crafting_type=al, item_id= 75365                               , rank=9, poison_name="9"                       }

, ["JORA"                    ] = { name="ジョラ"                            , crafting_type=en, item_id= 45855 , name_2="初歩"            }
, ["PORADE"                  ] = { name="ポラデ"                            , crafting_type=en, item_id= 45856 }
, ["JERA"                    ] = { name="ジェラ"                            , crafting_type=en, item_id= 45857 , name_2="不出来"           }
, ["JEJORA"                  ] = { name="ジェジョラ"                          , crafting_type=en, item_id= 45806 }
, ["ODRA"                    ] = { name="オドラ"                            , crafting_type=en, item_id= 45807 , name_2="一般的"           }
, ["POJORA"                  ] = { name="ポジョラ"                           , crafting_type=en, item_id= 45808 }
, ["EDORA"                   ] = { name="エドラ"                            , crafting_type=en, item_id= 45809 , name_2="中堅"            }
, ["JAERA"                   ] = { name="ジャエラ"                           , crafting_type=en, item_id= 45810 }
, ["PORA"                    ] = { name="ポラ"                             , crafting_type=en, item_id= 45811 , name_2="強力"            }
, ["DENARA"                  ] = { name="デナラ"                            , crafting_type=en, item_id= 45812 }
, ["RERA"                    ] = { name="レラ"                             , crafting_type=en, item_id= 45813 , name_2="希少"            }
, ["DERADO"                  ] = { name="デラド"                            , crafting_type=en, item_id= 45814 , name_2="至高"           , name_3="至高"             }
, ["REKURA"                  ] = { name="レクラ"                            , crafting_type=en, item_id= 45815 , name_2="究極"            }
, ["KURA"                    ] = { name="クラ"                             , crafting_type=en, item_id= 45816 , name_2="伝説"            }
, ["REJERA"                  ] = { name="レジェラ"                           , crafting_type=en, item_id= 64509 , name_2="最上"            }
, ["REPORA"                  ] = { name="レポラ"                            , crafting_type=en, item_id= 68341 , name_2="真に最上"          }

, ["JODE"                    ] = { name="ジョーデ"                           , crafting_type=en, item_id= 45817 }
, ["NOTADE"                  ] = { name="ノタデ"                            , crafting_type=en, item_id= 45818 }
, ["ODE"                     ] = { name="オデ"                             , crafting_type=en, item_id= 45819 }
, ["TADE"                    ] = { name="タデ"                             , crafting_type=en, item_id= 45820 }
, ["JAYDE"                   ] = { name="ジェイデ"                           , crafting_type=en, item_id= 45821 }
, ["EDODE"                   ] = { name="エドデ"                            , crafting_type=en, item_id= 45822 }
, ["POJODE"                  ] = { name="ポジョデ"                           , crafting_type=en, item_id= 45823 }
, ["REKUDE"                  ] = { name="レクデ"                            , crafting_type=en, item_id= 45824 }
, ["HADE"                    ] = { name="ハデ"                             , crafting_type=en, item_id= 45825 }
, ["IDODE"                   ] = { name="イドデ"                            , crafting_type=en, item_id= 45826 }
, ["PODE"                    ] = { name="ポデ"                             , crafting_type=en, item_id= 45827 }
, ["KEDEKO"                  ] = { name="ケデコ"                            , crafting_type=en, item_id= 45828 }
, ["REDE"                    ] = { name="レデ"                             , crafting_type=en, item_id= 45829 }
, ["KUDE"                    ] = { name="クデ"                             , crafting_type=en, item_id= 45830 }
, ["JEHADE"                  ] = { name="ジェハデ"                           , crafting_type=en, item_id= 64508 }
, ["ITADE"                   ] = { name="イタデ"                            , crafting_type=en, item_id= 68340 }

, ["DEKEIPA"                 ] = { name="デケイパ"                           , crafting_type=en, item_id= 45839 , add="氷結"               , sub="氷結耐性"              }
, ["DENI"                    ] = { name="デニ"                             , crafting_type=en, item_id= 45833 , add="スタミナ"             , sub="スタミナ吸収"           , add_2="スタミナ"                }
, ["DENIMA"                  ] = { name="デニマ"                            , crafting_type=en, item_id= 45836 , add="スタミナ再生"           , sub="技能消費減少"            }
, ["DETERI"                  ] = { name="デテリ"                            , crafting_type=en, item_id= 45842 , add="硬化"               , sub="粉砕"                }
, ["HAOKO"                   ] = { name="ハオコ"                            , crafting_type=en, item_id= 45841 , add="不浄"               , sub="病気耐性"              }
, ["HAKEIJO"                 ] = { name="ハケイジョ"                          , crafting_type=en, item_id= 68342 , add="分光防御"             , sub="分光猛襲"              }
, ["KADERI"                  ] = { name="カデリ"                            , crafting_type=en, item_id= 45849 , add="強撃"               , sub="盾"                 }
, ["KUOKO"                   ] = { name="クオコ"                            , crafting_type=en, item_id= 45837 , add="毒"                , sub="毒耐性"               }
, ["MAKDERI"                 ] = { name="マクデリ"                           , crafting_type=en, item_id= 45848 , add="魔法攻撃強化"           , sub="呪文耐性"              }
, ["MAKKO"                   ] = { name="マッコ"                            , crafting_type=en, item_id= 45832 , add="マジカ"              , sub="マジカ吸収"            , add_2="マジカ"                 }
, ["MAKKOMA"                 ] = { name="マッコマ"                           , crafting_type=en, item_id= 45835 , add="マジカ再生"            , sub="呪文消費減少"            }
, ["MEIP"                    ] = { name="メイプ"                            , crafting_type=en, item_id= 45840 , add="雷撃"               , sub="雷撃耐性"              }
, ["OKO"                     ] = { name="オコ"                             , crafting_type=en, item_id= 45831 , add="体力"               , sub="体力吸収"             , add_2="体力"                  }
, ["OKOMA"                   ] = { name="オコマ"                            , crafting_type=en, item_id= 45834 , add="体力再生"             , sub="体力減少"              }
, ["OKORI"                   ] = { name="オコリ"                            , crafting_type=en, item_id= 45843 , add="武器強化"             , sub="衰弱"                }
, ["ORU"                     ] = { name="オル"                             , crafting_type=en, item_id= 45846 , add="薬品強化"             , sub="薬品速度上昇"            }
, ["RAKEIPA"                 ] = { name="ラケイパ"                           , crafting_type=en, item_id= 45838 , add="炎"                , sub="炎耐性"               }
, ["TADERI"                  ] = { name="タデリ"                            , crafting_type=en, item_id= 45847 , add="物理攻撃強化"           , sub="物理耐性"              }

, ["TA"                      ] = { name="ター"                             , crafting_type=en, item_id= 45850 , name_2="Normal"   }
, ["JEJOTA"                  ] = { name="ジェジョタ"                          , crafting_type=en, item_id= 45851 , name_2="Fine"     }
, ["DENATA"                  ] = { name="デナタ"                            , crafting_type=en, item_id= 45852 , name_2="Superior" }
, ["REKUTA"                  ] = { name="レクタ"                            , crafting_type=en, item_id= 45853 , name_2="Epic"     }
, ["KUTA"                    ] = { name="クター"                            , crafting_type=en, item_id= 45854 , name_2="Legendary"}

, ["QUARTZ"                  ] = { name="クウォーツ"                          ,                   item_id=  4456 }
, ["DIAMOND"                 ] = { name="ダイヤモンド"                         ,                   item_id= 23219 }
, ["SARDONYX"                ] = { name="サードニックス"                        ,                   item_id= 30221 }
, ["ALMANDINE"               ] = { name="アルマンダイン"                        ,                   item_id= 23221 }
, ["EMERALD"                 ] = { name="エメラルド"                          ,                   item_id=  4442 }
, ["BLOODSTONE"              ] = { name="ブラッドストーン"                       ,                   item_id= 30219 }
, ["GARNET"                  ] = { name="ガーネット"                          ,                   item_id= 23171 }
, ["SAPPHIRE"                ] = { name="サファイア"                          ,                   item_id= 23173 }
, ["FORTIFIED_NIRNCRUX"      ] = { name="強化ニルンクラッツ"                      ,                   item_id= 56862 }
, ["CHYSOLITE"               ] = { name="ペリドット"                          ,                   item_id= 23203 }
, ["AMETHYST"                ] = { name="アメジスト"                          ,                   item_id= 23204 }
, ["RUBY"                    ] = { name="ルビー"                            ,                   item_id=  4486 }
, ["JADE"                    ] = { name="ヒスイ"                            ,                   item_id=   810 }
, ["TURQUOISE"               ] = { name="ターコイズ"                          ,                   item_id=   813 }
, ["CARNELIAN"               ] = { name="カーネリアン"                         ,                   item_id= 23165 }
, ["FIRE_OPAL"               ] = { name="炎のオパール"                         ,                   item_id= 23149 }
, ["CITRINE"                 ] = { name="シトリン"                           ,                   item_id= 16291 }
, ["POTENT_NIRNCRUX"         ] = { name="ニルンクラッツ(強力)"                    ,                   item_id= 56863 }
, ["COBALT"                  ] = { name="コバルト"                           ,                   item_id=135155 }
, ["ANTIMONY"                ] = { name="アンチモン"                          ,                   item_id=135156 }
, ["ZINC"                    ] = { name="亜鉛"                             ,                   item_id=135157 }
, ["DAWN_PRISM"              ] = { name="ドーンプリズム"                        ,                   item_id=139409 }
, ["DIBELLIUM"               ] = { name="ディベリウム"                         ,                   item_id=139413 }
, ["GILDING_WAX"             ] = { name="金箔ワックス"                         ,                   item_id=139412 }
, ["AURBIC_AMBER"            ] = { name="アウルビクアンバー"                      ,                   item_id=139411 }
, ["TITANIUM"                ] = { name="チタニウム"                          ,                   item_id=139410 }
, ["SLAUGHTERSTONE"          ] = { name="スローターストーン"                      ,                   item_id=139414 }

}


-- Equipment Traits ----------------------------------------------------------
--
-- For master writ quests that require Nirnhoned or whatever.
--
local ts=LibCraftText.TRAIT_SET_ID -- for less typing
local m =LibCraftText.MATERIAL
LibCraftText.TRAIT = {
    ["WEAPON_POWERED"      ] = { name="Powered"                     , trait_set_id=ts.WEAPON  , trait_index=1 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_POWERED          or  1 , material=m.CHYSOLITE          }
,   ["WEAPON_CHARGED"      ] = { name="Charged"                     , trait_set_id=ts.WEAPON  , trait_index=2 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_CHARGED          or  2 , material=m.AMETHYST           }
,   ["WEAPON_PRECISE"      ] = { name="Precise"                     , trait_set_id=ts.WEAPON  , trait_index=3 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_PRECISE          or  3 , material=m.RUBY               }
,   ["WEAPON_INFUSED"      ] = { name="Infused"                     , trait_set_id=ts.WEAPON  , trait_index=4 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_INFUSED          or  4 , material=m.JADE               }
,   ["WEAPON_DEFENDING"    ] = { name="Defending"                   , trait_set_id=ts.WEAPON  , trait_index=5 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_DEFENDING        or  5 , material=m.TURQUOISE          }
,   ["WEAPON_TRAINING"     ] = { name="Training"                    , trait_set_id=ts.WEAPON  , trait_index=6 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_TRAINING         or  6 , material=m.CARNELIAN          }
,   ["WEAPON_SHARPENED"    ] = { name="Sharpened"                   , trait_set_id=ts.WEAPON  , trait_index=7 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_SHARPENED        or  7 , material=m.FIRE_OPAL          }
,   ["WEAPON_DECISIVE"     ] = { name="Decisive"                    , trait_set_id=ts.WEAPON  , trait_index=8 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_DECISIVE         or  8 , material=m.CITRINE            }
,   ["WEAPON_NIRNHONED"    ] = { name="Nirnhoned"                   , trait_set_id=ts.WEAPON  , trait_index=9 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_NIRNHONED        or 26 , material=m.POTENT_NIRNCRUX    }

,   ["ARMOR_STURDY"        ] = { name="Sturdy"                      , trait_set_id=ts.ARMOR   , trait_index=1 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_STURDY            or 11 , material=m.QUARTZ             }
,   ["ARMOR_IMPENETRABLE"  ] = { name="Impenetrable"                , trait_set_id=ts.ARMOR   , trait_index=2 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE      or 12 , material=m.DIAMOND            }
,   ["ARMOR_REINFORCED"    ] = { name="Reinforced"                  , trait_set_id=ts.ARMOR   , trait_index=3 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_REINFORCED        or 13 , material=m.SARDONYX           }
,   ["ARMOR_WELL_FITTED"   ] = { name="Well-fitted"                 , trait_set_id=ts.ARMOR   , trait_index=4 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED       or 14 , material=m.ALMANDINE          }
,   ["ARMOR_TRAINING"      ] = { name="Training"                    , trait_set_id=ts.ARMOR   , trait_index=5 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_TRAINING          or 15 , material=m.EMERALD            }
,   ["ARMOR_INFUSED"       ] = { name="Infused"                     , trait_set_id=ts.ARMOR   , trait_index=6 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_INFUSED           or 16 , material=m.BLOODSTONE         }
,   ["ARMOR_INVIGORATING"  ] = { name="Invigorating"                , trait_set_id=ts.ARMOR   , trait_index=7 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_INVIGORATING      or 17 , material=m.GARNET             }
,   ["ARMOR_DIVINES"       ] = { name="Divines"                     , trait_set_id=ts.ARMOR   , trait_index=8 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_DIVINES           or 18 , material=m.SAPPHIRE           }
,   ["ARMOR_NIRNHONED"     ] = { name="Nirnhoned"                   , trait_set_id=ts.ARMOR   , trait_index=9 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_NIRNHONED         or 25 , material=m.FORTIFIED_NIRNCRUX }

,   ["JEWELRY_ARCANE"      ] = { name="Arcane"                      , trait_set_id=ts.JEWELRY , trait_index=1 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_ARCANE          or 22 , material=m.COBALT             }
,   ["JEWELRY_HEALTHY"     ] = { name="Healthy"                     , trait_set_id=ts.JEWELRY , trait_index=2 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_HEALTHY         or 21 , material=m.ANTIMONY           }
,   ["JEWELRY_ROBUST"      ] = { name="Robust"                      , trait_set_id=ts.JEWELRY , trait_index=3 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_ROBUST          or 23 , material=m.ZINC               }
,   ["JEWELRY_TRIUNE"      ] = { name="Triune"                      , trait_set_id=ts.JEWELRY , trait_index=4 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_TRIUNE          or 30 , material=m.DAWN_PRISM         }
,   ["JEWELRY_INFUSED"     ] = { name="Infused"                     , trait_set_id=ts.JEWELRY , trait_index=5 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_INFUSED         or 33 , material=m.AURBIC_AMBER       }
,   ["JEWELRY_PROTECTIVE"  ] = { name="Protective"                  , trait_set_id=ts.JEWELRY , trait_index=6 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE      or 32 , material=m.TITANIUM           }
,   ["JEWELRY_SWIFT"       ] = { name="Swift"                       , trait_set_id=ts.JEWELRY , trait_index=7 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_SWIFT           or 28 , material=m.GILDING_WAX        }
,   ["JEWELRY_HARMONY"     ] = { name="Harmony"                     , trait_set_id=ts.JEWELRY , trait_index=8 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_HARMONY         or 29 , material=m.DIBELLIUM          }
,   ["JEWELRY_BLOODTHIRSTY"] = { name="Bloodthirsty"                , trait_set_id=ts.JEWELRY , trait_index=9 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY    or 31 , material=m.SLAUGHTERSTONE     }

}
m  = nil
ts = nil


-- Alchemy Traits ------------------------------------------------------------
--
-- Answering "which trait?" for "Craft a potion/poison with the following traits".
--
-- trait_index      integer 1 through 30. Appears in one of the 4 bytes of
--                  itemLink for potions/poisons with this trait.
--
-- name             user-visible name of this trait. Often appears as part of
--                  potion name. Sometimes appears as part of poison name.
--
-- master_potion    name of a rank 9 potion with this trait. Appears as part
--                  of master writ requests.
--
-- master_poison    name of a rank 9 poison with this trait. Appears as part
--                  of master writ requests.
--
LibCraftText.ALCHEMY_TRAIT = {
    ["RESTORE_HEALTH"         ] = { trait_index=01, name="体力回復"                     , master_potion="体力 のエキス"                           , master_poison="体力吸収の毒 9"                          , daily_potion_name="体力"                           , daily_poison_name="体力吸収"                         }
,   ["RAVAGE_HEALTH"          ] = { trait_index=02, name="体力減少"                     , master_potion="体力減少 のエキス"                         , master_poison="体力減少の毒 9"                          , daily_potion_name="体力減少"                         , daily_poison_name="体力減少"                         , daily_poison_name2="体力減少"                         }
,   ["RESTORE_MAGICKA"        ] = { trait_index=03, name="マジカ回復"                    , master_potion="マジカ のエキス"                          , master_poison="マジカ吸収の毒 9"                         , daily_potion_name="マジカ"                          , daily_poison_name="マジカ吸収"                        }
,   ["RAVAGE_MAGICKA"         ] = { trait_index=04, name="マジカ減少"                    , master_potion="マジカ減少 のエキス"                        , master_poison="マジカ減少の毒 9"                         , daily_potion_name="マジカ減少"                        , daily_poison_name="マジカ減少"                        , daily_poison_name2="マジカ減少"                         }
,   ["RESTORE_STAMINA"        ] = { trait_index=05, name="スタミナ回復"                   , master_potion="スタミナ のエキス"                         , master_poison="スタミナ吸収の毒 9"                        , daily_potion_name="スタミナ"                         , daily_poison_name="スタミナ吸収"                       }
,   ["RAVAGE_STAMINA"         ] = { trait_index=06, name="スタミナ減少"                   , master_potion="スタミナ減少 のエキス"                       , master_poison="スタミナ減少の毒 9"                        , daily_potion_name="スタミナ減少"                       , daily_poison_name="スタミナ減少"                       , daily_poison_name2="スタミナ減少"                        }
,   ["SPELL_RESISTANCE"       ] = { trait_index=07, name="呪文耐性増大"                   , master_potion="呪文防御 のエキス"                         , master_poison="結界吸収の毒 9"                          }
,   ["BREACH"                 ] = { trait_index=08, name="侵害"                       , master_potion="呪文防御減少 のエキス"                       , master_poison="侵害の毒 9"                            }
,   ["INCREASE_ARMOR"         ] = { trait_index=09, name="防御力増大"                    , master_potion="防具 のエキス"                           , master_poison="強固吸収の毒 9"                          }
,   ["FRACTURE"               ] = { trait_index=10, name="破砕"                       , master_potion="鎧破損度 のエキス"                         , master_poison="破砕の毒 9"                            }
,   ["INCREASE_SPELL_POWER"   ] = { trait_index=11, name="呪文攻撃力上昇"                  , master_potion="呪文攻撃力 のエキス"                        , master_poison="魔術吸収の毒 9"                          }
,   ["COWARDICE"              ] = { trait_index=12, name="臆病"                       , master_potion="臆病 のエキス"                           , master_poison="臆病の毒 9"                            }
,   ["INCREASE_WEAPON_POWER"  ] = { trait_index=13, name="武器攻撃力上昇"                  , master_potion="武器攻撃力 のエキス"                        , master_poison="残忍吸収の毒 9"                          }
,   ["MAIM"                   ] = { trait_index=14, name="不自由"                      , master_potion="不自由 のエキス"                          , master_poison="不自由の毒 9"                           }
,   ["SPELL_CRITICAL"         ] = { trait_index=15, name="呪文クリティカル"                 , master_potion="呪文クリティカル のエキス"                     , master_poison="予言吸収の毒 9"                          }
,   ["UNCERTAINTY"            ] = { trait_index=16, name="不信"                       , master_potion="不信 のエキス"                           , master_poison="不信の毒 9"                            }
,   ["WEAPON_CRITICAL"        ] = { trait_index=17, name="武器クリティカル"                 , master_potion="武器クリティカル のエキス"                     , master_poison="獰猛吸収の毒 9"                          }
,   ["ENERVATION"             ] = { trait_index=18, name="弱体化"                      , master_potion="弱体化 のエキス"                          , master_poison="弱体化の毒 9"                           }
,   ["UNSTOPPABLE"            ] = { trait_index=19, name="猪突猛進"                     , master_potion="不動性 のエキス"                          , master_poison="逃避者の毒 9"                           }
,   ["ENTRAPMENT"             ] = { trait_index=20, name="罠"                        , master_potion="罠 のエキス"                            , master_poison="罠の毒 9"                             }
,   ["DETECTION"              ] = { trait_index=21, name="探知"                       , master_potion="探知 のエキス"                           , master_poison="ステルス吸収の毒 9"                        }
,   ["INVISIBLE"              ] = { trait_index=22, name="透明化"                      , master_potion="透明化 のエキス"                          , master_poison="露見の毒 9"                            }
,   ["SPEED"                  ] = { trait_index=23, name="加速"                       , master_potion="加速 のエキス"                           , master_poison="速度吸収の毒 9"                          }
,   ["HINDRANCE"              ] = { trait_index=24, name="妨害"                       , master_potion="妨害 のエキス"                           , master_poison="妨害の毒 9"                            }
,   ["PROTECTION"             ] = { trait_index=25, name="防護"                       , master_potion="防御 のエキス"                           , master_poison="防御逆転の毒 9"                          }
,   ["VULNERABILITY"          ] = { trait_index=26, name="脆弱"                       , master_potion="脆弱 のエキス"                           , master_poison="脆弱の毒 9"                            }
,   ["LINGERING_HEALTH"       ] = { trait_index=27, name="体力継続"                     , master_potion="体力継続 のエキス"                         , master_poison="体力吸収継続の毒 9"                        }
,   ["GRADUAL_RAVAGE_HEALTH"  ] = { trait_index=28, name="体力漸減"                     , master_potion="体力減少継続 のエキス"                       , master_poison="体力減少継続の毒 9"                        }
,   ["VITALITY"               ] = { trait_index=29, name="生命力"                      , master_potion="生命力 のエキス"                          , master_poison="生命力吸収の毒 9"                         }
,   ["DEFILE"                 ] = { trait_index=30, name="汚染"                       , master_potion="汚染 のエキス"                           , master_poison="汚染の毒 9"                            }
}


-- Craftable Sets ------------------------------------------------------------
--
-- set_id       writ4 field for master writs
--
LibCraftText.SET = {
    ["ADEPT_RIDER"              ] = { name="熟練騎手"                       , set_id=385 }
,   ["ALESSIAS_BULWARK"         ] = { name="アレッシア守護"                    , set_id= 82 }
,   ["ARMOR_MASTER"             ] = { name="鎧匠"                         , set_id=178 }
,   ["ARMOR_OF_THE_SEDUCER"     ] = { name="誘惑者の武具"                     , set_id= 43 }
,   ["ASHEN_GRIP"               ] = { name="青白い柄"                       , set_id= 54 }
,   ["ASSASSINS_GUILE"          ] = { name="アサシンの幻惑"                    , set_id=323 }
,   ["CLEVER_ALCHEMIST"         ] = { name="賢明な錬金術師"                    , set_id=225 }
,   ["DAEDRIC_TRICKERY"         ] = { name="デイドラの策略"                    , set_id=324 }
,   ["DEATHS_WIND"              ] = { name="死を招く風"                      , set_id= 37 }
,   ["ETERNAL_HUNT"             ] = { name="エターナルハント"                   , set_id=226 }
,   ["EYES_OF_MARA"             ] = { name="マーラの目"                      , set_id= 87 }
,   ["FORTIFIED_BRASS"          ] = { name="強化真鍮"                       , set_id=352 }
,   ["GRAVE_STAKE_COLLECTOR"    ] = { name="墓標コレクター"                    , set_id=408 }
,   ["HIST_BARK"                ] = { name="ヒスト樹皮"                      , set_id= 78 }
,   ["HUNDINGS_RAGE"            ] = { name="怒れるフンディング"                  , set_id= 80 }
,   ["INNATE_AXIOM"             ] = { name="内在公理"                       , set_id=351 }
,   ["KAGRENACS_HOPE"           ] = { name="カグレナクの希望"                   , set_id= 92 }
,   ["KVATCH_GLADIATOR"         ] = { name="クヴァッチ剣闘士"                   , set_id=240 }
,   ["LAW_OF_JULIANOS"          ] = { name="ジュリアノスの掟"                   , set_id=207 }
,   ["MAGNUS_GIFT"              ] = { name="マグナスの贈物"                    , set_id= 48 }
,   ["MECHANICAL_ACUITY"        ] = { name="機械的精度"                      , set_id=353 }
,   ["MIGHT_OF_THE_LOST_LEGION" ] = { name="失われた軍団の力"                   , set_id=410 }
,   ["MORKULDIN"                ] = { name="モークルディン"                    , set_id=219 }
,   ["NAGA_SHAMAN"              ] = { name="ナガ呪術師"                      , set_id=409 }
,   ["NIGHT_MOTHERS_GAZE"       ] = { name="夜母の注視"                      , set_id= 51 }
,   ["NIGHTS_SILENCE"           ] = { name="寂夜"                         , set_id= 40 }
,   ["NOBLES_CONQUEST"          ] = { name="大親征"                        , set_id=176 }
,   ["NOCTURNALS_FAVOR"         ] = { name="ノクターナルの寵愛"                  , set_id=387 }
,   ["OBLIVIONS_FOE"            ] = { name="反オブリビオン"                    , set_id= 73 }
,   ["ORGNUMS_SCALES"           ] = { name="オルグヌム鱗"                     , set_id= 84 }
,   ["PELINALS_APTITUDE"        ] = { name="ペリナルの適性"                    , set_id=242 }
,   ["REDISTRIBUTOR"            ] = { name="再分配"                        , set_id=177 }
,   ["SHACKLEBREAKER"           ] = { name="シャックルブレイカー"                 , set_id=325 }
,   ["SHALIDORS_CURSE"          ] = { name="呪えしシャリドール"                  , set_id= 95 }
,   ["SLOADS_SEMBLANCE"         ] = { name="スロードの装い"                    , set_id=386 }
,   ["SONG_OF_LAMAE"            ] = { name="ラマエ歌"                       , set_id= 81 }
,   ["SPECTRES_EYE"             ] = { name="霊なる瞳"                       , set_id= 74 }
,   ["TAVAS_FAVOR"              ] = { name="ターヴァの寵"                     , set_id=224 }
,   ["TORUGS_PACT"              ] = { name="トラグパクト"                     , set_id= 75 }
,   ["TRIAL_BY_FIRE"            ] = { name="炎の試練"                       , set_id=208 }
,   ["TWICE_BORN_STAR"          ] = { name="双子星"                        , set_id=161 }
,   ["TWILIGHTS_EMBRACE"        ] = { name="黄昏の抱擁"                      , set_id= 38 }
,   ["VAMPIRES_KISS"            ] = { name="吸血鬼の口づけ"                    , set_id= 44 }
,   ["VARENS_LEGACY"            ] = { name="ヴァレンレガシー"                   , set_id=241 }
,   ["WAY_OF_THE_ARENA"         ] = { name="アリーナの流儀"                    , set_id=148 }
,   ["WHITESTRAKES_RETRIBUTION" ] = { name="ホワイトストレークの報復"               , set_id= 41 }
,   ["WILLOWS_PATH"             ] = { name="ウィロー路"                      , set_id= 79 }
}

-- Craftable Motifs ----------------------------------------------------------
--
-- writ6 field for master writs
--
LibCraftText.MOTIF = {
    ["BRETON"             ] = { name="ブレトン"                 , motif_id=  1 }
,   ["REDGUARD"           ] = { name="レッドガード"               , motif_id=  2 }
,   ["ORC"                ] = { name="オーク"                  , motif_id=  3 }
,   ["DARK_ELF"           ] = { name="ダークエルフ"               , motif_id=  4 }
,   ["NORD"               ] = { name="ノルド"                  , motif_id=  5 }
,   ["ARGONIAN"           ] = { name="アルゴニアン"               , motif_id=  6 }
,   ["HIGH_ELF"           ] = { name="ハイエルフ"                , motif_id=  7 }
,   ["WOOD_ELF"           ] = { name="ウッドエルフ"               , motif_id=  8 }
,   ["KHAJIIT"            ] = { name="カジート"                 , motif_id=  9 }
,   ["UNIQUE"             ] = { name="ユニーク"                 , motif_id= 10 }
,   ["THIEVES_GUILD"      ] = { name="盗賊ギルド"                , motif_id= 11 }
,   ["DARK_BROTHERHOOD"   ] = { name="闇の一党"                 , motif_id= 12 }
,   ["MALACATH"           ] = { name="マラキャス"                , motif_id= 13 }
,   ["DWEMER"             ] = { name="ドゥエマー"                , motif_id= 14 }
,   ["ANCIENT_ELF"        ] = { name="古代エルフ"                , motif_id= 15 }
,   ["ORDER_OF_THE_HOUR"  ] = { name="時の騎士団"                , motif_id= 16 }
,   ["BARBARIC"           ] = { name="蛮族"                   , motif_id= 17 }
,   ["BANDIT"             ] = { name="Bandit"               , motif_id= 18 }
,   ["PRIMAL"             ] = { name="野性"                   , motif_id= 19 }
,   ["DAEDRIC"            ] = { name="デイドラ"                 , motif_id= 20 }
,   ["TRINIMAC"           ] = { name="トリニマク"                , motif_id= 21 }
,   ["ANCIENT_ORC"        ] = { name="古代オーク"                , motif_id= 22 }
,   ["DAGGERFALL_COVENANT"] = { name="ダガーフォール・カバナント"        , motif_id= 23 }
,   ["EBONHEART_PACT"     ] = { name="エボンハート・パクト"           , motif_id= 24 }
,   ["ALDMERI_DOMINION"   ] = { name="アルドメリ・ドミニオン"          , motif_id= 25 }
,   ["MERCENARY"          ] = { name="傭兵"                   , motif_id= 26 }
,   ["CELESTIAL"          ] = { name="セレスティアル"              , motif_id= 27 }
,   ["GLASS"              ] = { name="碧水晶"                  , motif_id= 28 }
,   ["XIVKYN"             ] = { name="シヴキン"                 , motif_id= 29 }
,   ["SOUL_SHRIVEN"       ] = { name="魂なき者"                 , motif_id= 30 }
,   ["DRAUGR"             ] = { name="ドラウグル"                , motif_id= 31 }
,   ["MAORMER"            ] = { name="マオマー"                 , motif_id= 32 }
,   ["AKAVIRI"            ] = { name="アカヴィリ"                , motif_id= 33 }
,   ["IMPERIAL"           ] = { name="帝国"                   , motif_id= 34 }
,   ["YOKUDAN"            ] = { name="ヨクダ"                  , motif_id= 35 }
,   ["UNIVERSAL"          ] = { name="ユニバーサル"               , motif_id= 36 }
,   ["REACH_WINTER"       ] = { name="リーチ・ウィンター"            , motif_id= 37 }
,   ["TSAESCI"            ] = { name="ツァエシ"                 , motif_id= 38 }
,   ["MINOTAUR"           ] = { name="ミノタウロス"               , motif_id= 39 }
,   ["EBONY"              ] = { name="黒檀"                   , motif_id= 40 }
,   ["ABAHS_WATCH"        ] = { name="アバーズ・ウォッチ"            , motif_id= 41 }
,   ["SKINCHANGER"        ] = { name="スキンチェンジャー"            , motif_id= 42 }
,   ["MORAG_TONG"         ] = { name="モラグ・トング"              , motif_id= 43 }
,   ["RA_GADA"            ] = { name="ラ・ガーダ"                , motif_id= 44 }
,   ["DRO_MATHRA"         ] = { name="ドロ・マスラ"               , motif_id= 45 }
,   ["ASSASSINS_LEAGUE"   ] = { name="アサシン同盟"               , motif_id= 46 }
,   ["OUTLAW"             ] = { name="無法者"                  , motif_id= 47 }
,   ["REDORAN"            ] = { name="レドラン"                 , motif_id= 48 }
,   ["HLAALU"             ] = { name="フラール"                 , motif_id= 49 }
,   ["MILITANT_ORDINATOR" ] = { name="ミリタント・オーディネーター"       , motif_id= 50 }
,   ["TELVANNI"           ] = { name="テルヴァンニ"               , motif_id= 51 }
,   ["BUOYANT_ARMIGER"    ] = { name="ボイアント・アーミガー"          , motif_id= 52 }
,   ["FROSTCASTER"        ] = { name="フロストキャスター"            , motif_id= 53 }
,   ["ASHLANDER"          ] = { name="アッシュランダー"             , motif_id= 54 }
,   ["WORM_CULT"          ] = { name="虫の教団"                 , motif_id= 55 }
,   ["SILKEN_RING"        ] = { name="シルケンリング"              , motif_id= 56 }
,   ["MAZZATUN"           ] = { name="マザッタン"                , motif_id= 57 }
,   ["GRIM_HARLEQUIN"     ] = { name="グリム・ハーレクイン"           , motif_id= 58 }
,   ["HOLLOWJACK"         ] = { name="ホロウジャック"              , motif_id= 59 }
,   ["REFABRICATED"       ] = { name="リファブリケイト"             , motif_id= 60 }
,   ["BLOODFORGE"         ] = { name="ブラッドフォージ"             , motif_id= 61 }
,   ["DREADHORN"          ] = { name="ドレッドホーン"              , motif_id= 62 }
,   ["APOSTLE"            ] = { name="使徒"                   , motif_id= 65 }
,   ["EBONSHADOW"         ] = { name="エボンシャドウ"              , motif_id= 66 }
,   ["UNDAUNTED"          ] = { name="アンドーンテッド"             , motif_id= 67 }
,   ["USE_ME"             ] = { name="USE ME"               , motif_id= 68 }
,   ["FANG_LAIR"          ] = { name="牙の巣"                  , motif_id= 69 }
,   ["SCALECALLER"        ] = { name="スケイルコーラー"             , motif_id= 70 }
,   ["PSIJIC_ORDER"       ] = { name="サイジック"                , motif_id= 71 }
,   ["SAPIARCH"           ] = { name="サピアルチ"                , motif_id= 72 }
,   ["WELKYNAR"           ] = { name="ウェルキナー"               , motif_id= 73 }
,   ["DREMORA"            ] = { name="ドレモラ"                 , motif_id= 74 }
,   ["PYANDONEAN"         ] = { name="ピャンドニア"               , motif_id= 75 }
,   ["DIVINE_PROSECUTION" ] = { name="神聖執行局"                , motif_id= 76 }
,   ["HUNTSMAN"           ] = { name="ハンツマン"                , motif_id= 77 }
,   ["SILVER_DAWN"        ] = { name="銀なる暁"                 , motif_id= 78 }
,   ["DEAD_WATER"         ] = { name="デッドウォーター"             , motif_id= 79 }
,   ["HONOR_GUARD"        ] = { name="儀仗兵"                  , motif_id= 80 }
,   ["ELDER_ARGONIAN"     ] = { name="古代アルゴニアン"             , motif_id= 81 }
}


-- Miscellaneous conditions --------------------------------------------------

LibCraftText.DAILY.COND = {
    HINT_PR_BREWERS_COOKS_RECIPES = "醸造家と料理人はレシピを提供できる"           
,   DELIVER_GOODS_SUBSTRING       = "に届ける"                  
,   DELIVER_NEAREST_QUARTERMASTER = "品物を、一番近い依頼を出す補給係に届ける"        
,   DELIVER_ALLIANCE_DEPOT        = "Deliver Goods to Alliance Supply Depot"
,   DELIVER_CONSORTIUM_TRADEPOST  = "Deliver Goods to Consortium Tradepost"
,   DELIVER_REFUGEE_RELIEF        = "Deliver Goods to Refugee Relief Site"
,   DELIVER_FIGHTERS_GUILD        = "Deliver Goods to Fighters Guild Provisioner"
}

LibCraftText.MASTER.COND = {
    TRAVEL_AD       = "エルデンルートへ行って代理人と会う"                           -- "Travel to Elden Root to Meet Your Contact"
,   TRAVEL_DC       = "ウェイレストへ行って代理人と会う"                            -- "Travel to Wayrest to Meet Your Contact"
,   TRAVEL_EP       = "モーンホールドへ行って代理人と会う"                           -- "Travel to Mournhold to Meet Your Contact"

,   DELIVER_AL      = "調合薬を届ける"                                     -- "Deliver the Concoction"
,   DELIVER_EN      = "グリフを届ける"                                     -- "Deliver the Glyph"
,   DELIVER_PR      = "料理を届ける"                                      -- "Deliver the Feast"
,   DELIVER_WEAPON  = "武器を届ける"                                      -- "Deliver the Weapon"
,   DELIVER_ARMOR   = "防具を届ける"                                      -- "Deliver the Armor"
,   DELIVER_JW      = "宝飾を届ける"                                      -- "Deliver the Jewelry"
}


-- Random Unsorted Stuff -----------------------------------------------------

LibCraftText.MASTER_LABELS = {
    ["quality"] =  "Quality"                         -- "Quality"
,   ["set"    ] =  "Set"                             -- "Set"
,   ["style"  ] =  "Style"                           -- "Style"
,   ["trait"  ] =  "Trait"                           -- "Trait"
}

LibCraftText.QUALITY = {
    ["NORMAL"   ] = { name="Normal"     , index=ITEM_QUALITY_NORMAL         or 1 }
,   ["FINE"     ] = { name="Fine"       , index=ITEM_QUALITY_FINE           or 2 }
,   ["SUPERIOR" ] = { name="Superior"   , index=ITEM_QUALITY_SUPERIOR       or 3 }
,   ["EPIC"     ] = { name="Epic"       , index=ITEM_QUALITY_EPIC           or 4 }
,   ["LEGENDARY"] = { name="Legendary"  , index=ITEM_QUALITY_LEGENDARY      or 5 }
}


-- Quest and Dialog Text -----------------------------------------------------

LibCraftText.DAILY.QUEST_NAME = {
    [bs] = "鍛冶師の依頼"                             -- "Blacksmith Writ"
,   [cl] = "仕立師の依頼"                             -- "Clothier Writ"
,   [en] = "付呪師の依頼"                             -- "Enchanter Writ"
,   [al] = "錬金術師の依頼"                            -- "Alchemist Writ"
,   [pr] = "調理師の依頼"                             -- "Provisioner Writ"
,   [ww] = "木工師の依頼"                             -- "Woodworker Writ"
,   [jw] = "宝飾師のクラフト依頼"                         -- "Jewelry Crafting Writ"
}
                        -- SURPRISE! "A Masterful Weapon" is used by both
                        -- Blacksmithing and Woodworking.
                        --
                        -- Why a list? Because BS, CL, and WW can all use
                        -- different quest titles depending on what item they
                        -- requested (armor vs. weapon, light vs. medium armor)
                        --
LibCraftText.MASTER.QUEST_NAME = {
    [bs] = { "優れた防具"                              -- "A Masterful Plate"
           , "優れた武器"                            } -- "A Masterful Weapon"
,   [cl] = { "優れた服"                               -- "Masterful Tailoring"
           , "優れた革装備"                           } -- "Masterful Leatherwear"
,   [en] = { "優れたグリフ"                           } -- "A Masterful Glyph"
,   [al] = { "優れた調合薬"                           } -- "A Masterful Concoction"
,   [pr] = { "優れた料理"                            } -- "A Masterful Feast"
,   [ww] = { "優れた盾"                               -- "A Masterful Shield"
           , "優れた武器"                            } -- "A Masterful Weapon"
,   [jw] = { "優れた宝飾"                            } -- "Masterful Jewelry"
}

LibCraftText.DAILY.DIALOG = {
    ["OPTION_ACCEPT"      ] = "<依頼を掲示板からはがす>"                           -- "<Pull a Writ from the Board.>"
,   ["OPTION_FINISH_SIGN" ] = "<伝票に署名する>"                               -- "<Sign the Manifest.>"
,   ["OPTION_FINISH_PLACE"] = "<品物を木箱の中に置く>"                            -- "<Place the goods within the crate.>"
,   ["GOAL_SIGN"          ] = "配達伝票に署名する"                               -- "Sign Delivery Manifest"
}

LibCraftText.MASTER.DIALOG = {
    ["OPTION_ACCEPT"      ] = { "<契約を受諾する>"                             -- "<Accept the contract.>"
                              , "<契約を受諾する>"                             -- "<Accept the contract>"  (FR French omits the period sometimes)
                              }
,   ["ROLIS_NAME"         ] = "ロリス・フラール"                                -- "Rolis Hlaalu"
,   ["TITLE_ROLIS"        ] = "-ロリス・フラール-"                              -- "-Rolis Hlaalu-"
,   ["OPTION_STORE"       ] = "Store (名工の調停人)"                          -- "Store (Mastercraft Mediator)"
,   ["OPTION_FINISH_JOB"  ] = "<仕事を終える>"                                -- "<Finish the job.>"
,   ["RESPONSE_ENDING"    ] = "<彼は仕事を記録し、支払いを提供する>"                     -- "<He notes your work and tenders payment.>"
}

LibCraftText.DAILY.DIALOG.TITLE_OFFER = {
    "-装備品のクラフトの依頼-"                               -- "-Equipment Crafting Writs-"
,   "-消費アイテムのクラフトの依頼-"                            -- "-Consumables Crafting Writs-"
}

LibCraftText.MASTER.DIALOG.TITLE_OFFER = {
    [bs] = "-密封された鍛冶依頼-"                          -- "-Sealed Blacksmithing Writ-"
,   [cl] = "-密封された仕立依頼-"                          -- "-Sealed Clothier Writ-"
,   [en] = "-密封された付呪依頼-"                          -- "-Sealed Enchanting Writ-"
,   [al] = "-密封された錬金術依頼-"                         -- "-Sealed Alchemy Writ-"
,   [pr] = "-密封された調理依頼-"                          -- "-Sealed Provisioning Writ-"
,   [ww] = "-密封された木工依頼-"                          -- "-Sealed Woodworking Writ-"
,   [jw] = "-密封された宝飾師依頼-"                         -- "-Sealed Jewelry Crafter Writ-"
}

LibCraftText.DAILY.DIALOG.TITLE_TURN_IN = {
    [bs] = "-鍛冶屋の配達箱-"                            -- "-Blacksmith Delivery Crate-"
,   [cl] = "-仕立師の配達箱-"                            -- "-Clothier Delivery Crate-"
,   [en] = "-付呪師の配達箱-"                            -- "-Enchanter Delivery Crate-"
,   [al] = "-錬金術師の配達箱-"                           -- "-Alchemist Delivery Crate-"
,   [pr] = "-調理師の配達箱-"                            -- "-Provisioner Delivery Crate-"
,   [ww] = "-木工師の配達箱-"                            -- "-Woodworker Delivery Crate-"
,   [jw] = "-宝飾師の配達箱-"                            -- "-Jewelry Crafting Delivery Crate-"
}

LibCraftText.DAILY.DIALOG.OPTION_EXAMINE = {
    [bs] = "<鍛冶屋の依頼を調べる>"                         -- "<Examine the Blacksmith Writs.>"
,   [cl] = "<仕立屋の依頼を調べる>"                         -- "<Examine the Clothier Writs.>"
,   [en] = "<付呪師の依頼を調べる>"                         -- "<Examine the Enchanter Writs.>"
,   [al] = "<錬金術師の依頼を見る>"                         -- "<Examine the Alchemist Writs.>"
,   [pr] = "<調理師の依頼を見る>"                          -- "<Examine the Provisioner Writs.>"
,   [ww] = "<木工師の依頼を調べる>"                         -- "<Examine the Woodworker Writs.>"
,   [jw] = "<宝飾師のクラフト依頼を調べる>"                     -- "<Examine the Jewelry Crafting Writs.>"
}

LibCraftText.MASTER.DIALOG.OPTION_FINISH = {
    [bs] = "鍛冶の仕事を終えた"                            -- "I've finished the Blacksmithing job."
,   [cl] = "仕立の仕事を終えた"                            -- "I've finished the Clothier job."
,   [en] = "付呪の仕事を終えた"                            -- "I've finished the Enchanting job."
,   [al] = "錬金術の仕事を終えた"                           -- "I've finished the Alchemy job."
,   [pr] = "調理の仕事を終えた"                            -- "I've finished the Provisioning job."
,   [ww] = "木工の仕事を終えた"                            -- "I've finished the Woodworking job."
,   [jw] = "宝飾の仕事を終えた"                            -- "I've finished the Jewelry job."
}
