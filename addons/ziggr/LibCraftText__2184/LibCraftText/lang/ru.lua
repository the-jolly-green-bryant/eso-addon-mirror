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
  ["H1_AXE"         ] = { name="axe"                  , master_name="Axe"                       , pattern_index= 1, master_writ1=53, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H1_MACE"        ] = { name="mace"                 , master_name="Mace"                      , pattern_index= 2, master_writ1=56, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H1_SWORD"       ] = { name="sword"                , master_name="Sword"                     , pattern_index= 3, master_writ1=59, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H2_BATTLE_AXE"  ] = { name="battle axe"           , master_name="Battle Axe"                , pattern_index= 4, master_writ1=68, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H2_MAUL"        ] = { name="maul"                 , master_name="Maul"                      , pattern_index= 5, master_writ1=69, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H2_GREATSWORD"  ] = { name="greatsword"           , master_name="Greatsword"                , pattern_index= 6, master_writ1=67, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["DAGGER"         ] = { name="dagger"               , master_name="Dagger"                    , pattern_index= 7, master_writ1=62, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["CUIRASS"        ] = { name="cuirass"              , master_name="Cuirass"                   , pattern_index= 8, master_writ1=46, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["SABATONS"       ] = { name="sabatons"             , master_name="Sabatons"                  , pattern_index= 9, master_writ1=50, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["GAUNTLETS"      ] = { name="gauntlets"            , master_name="Gauntlets"                 , pattern_index=10, master_writ1=52, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["HELM"           ] = { name="helm"                 , master_name="Helm"                      , pattern_index=11, master_writ1=44, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["GREAVES"        ] = { name="greaves"              , master_name="Greaves"                   , pattern_index=12, master_writ1=49, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["PAULDRON"       ] = { name="pauldron"             , master_name="Pauldron"                  , pattern_index=13, master_writ1=47, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["GIRDLE"         ] = { name="girdle"               , master_name="Girdle"                    , pattern_index=14, master_writ1=48, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }

, ["ROBE"           ] = { name="robe"                 , master_name="Robe"                      , pattern_index= 1, master_writ1=28, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["JERKIN"         ] = { name="jerkin"               , master_name="Jerkin"                    , pattern_index= 2, master_writ1=75, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["SHOES"          ] = { name="shoes"                , master_name="Shoes"                     , pattern_index= 3, master_writ1=32, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["GLOVES"         ] = { name="gloves"               , master_name="Gloves"                    , pattern_index= 4, master_writ1=34, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["HAT"            ] = { name="hat"                  , master_name="Hat"                       , pattern_index= 5, master_writ1=26, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["BREECHES"       ] = { name="breeches"             , master_name="Breeches"                  , pattern_index= 6, master_writ1=31, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["EPAULETS"       ] = { name="epaulets"             , master_name="Epaulets"                  , pattern_index= 7, master_writ1=29, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr , name_2="epaulet"   }
, ["SASH"           ] = { name="sash"                 , master_name="Sash"                      , pattern_index= 8, master_writ1=30, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr , name_2="sash"      }
, ["JACK"           ] = { name="jack"                 , master_name="Jack"                      , pattern_index= 9, master_writ1=37, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["BOOTS"          ] = { name="boots"                , master_name="Boots"                     , pattern_index=10, master_writ1=41, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["BRACERS"        ] = { name="bracers"              , master_name="Bracers"                   , pattern_index=11, master_writ1=43, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr , name_2="bracers"   }
, ["HELMET"         ] = { name="helmet"               , master_name="Helmet"                    , pattern_index=12, master_writ1=35, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr , name_2="helmet"    }
, ["GUARDS"         ] = { name="guards"               , master_name="Guards"                    , pattern_index=13, master_writ1=40, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["ARM_COPS"       ] = { name="arm cops"             , master_name="Arm Cops"                  , pattern_index=14, master_writ1=38, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["BELT"           ] = { name="belt"                 , master_name="Belt"                      , pattern_index=15, master_writ1=39, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }

, ["BOW"            ] = { name="bow"                  , master_name="Bow"                       , pattern_index= 1, master_writ1=70, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["INFERNO_STAFF"  ] = { name="inferno staff"        , master_name="Inferno Staff"             , pattern_index= 3, master_writ1=72, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["ICE_STAFF"      ] = { name="ice staff"            , master_name="Ice Staff"                 , pattern_index= 4, master_writ1=73, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["LIGHTNING_STAFF"] = { name="lightning staff"      , master_name="Lightning Staff"           , pattern_index= 5, master_writ1=74, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["RESTO_STAFF"    ] = { name="restoration staff"    , master_name="Restoration Staff"         , pattern_index= 6, master_writ1=71, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["SHIELD"         ] = { name="shield"               , master_name="Shield"                    , pattern_index= 2, master_writ1=65, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_armr }

, ["NECKLACE"       ] = { name="necklace"             , master_name="Necklace"                  , pattern_index= 2, master_writ1=18, crafting_type=jw, mat_set_id=mat_jewl, trait_set_id=trait_jewl , name_2="necklace"  }
, ["RING"           ] = { name="ring"                 , master_name="Ring"                      , pattern_index= 1, master_writ1=24, crafting_type=jw, mat_set_id=mat_jewl, trait_set_id=trait_jewl }
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
  ["AETHERIAL_TEA"                      ] = { name="этерический чай"                       , food_item_id=033602, recipe_item_id=046049, recipe_list_index=  9, recipe_index= 31, name_2="этерический чай"}
, ["ALIKR_BEETS_WITH_GOAT_CHEESE"       ] = { name="алик'рская свекла с козьим сыром"      , food_item_id=028338, recipe_item_id=045899, recipe_list_index=  3, recipe_index= 13}
, ["BAKED_APPLES"                       ] = { name="печеные яблоки"                        , food_item_id=033837, recipe_item_id=045889, recipe_list_index=  2, recipe_index=  1}
, ["BAKED_POTATO"                       ] = { name="печеный картофель"                     , food_item_id=028354, recipe_item_id=045912, recipe_list_index=  3, recipe_index=  2}
, ["BANANA_SURPRISE"                    ] = { name="банановый сюрприз"                     , food_item_id=028281, recipe_item_id=045913, recipe_list_index=  2, recipe_index=  2}
, ["BARLEY_NECTAR"                      ] = { name="ячменный нектар"                       , food_item_id=033624, recipe_item_id=045984, recipe_list_index=  8, recipe_index= 14}
, ["BATTAGLIR_CHOWDER"                  ] = { name="чаудер из баттаглира"                  , food_item_id=028394, recipe_item_id=045946, recipe_list_index=  3, recipe_index= 15}
, ["BITTERLEMON_TEA"                    ] = { name="горький чай с лимоном"                 , food_item_id=028457, recipe_item_id=046000, recipe_list_index=  9, recipe_index= 13}
, ["BLUE_ROAD_MARATHON"                 ] = { name="«Марафон по Синей дороге»"             , food_item_id=028513, recipe_item_id=046030, recipe_list_index= 10, recipe_index= 25}
, ["BOG_IRON_ALE"                       ] = { name="болотнорудный эль"                     , food_item_id=028405, recipe_item_id=045971, recipe_list_index=  8, recipe_index=  4}
, ["BRETON_PORK_SAUSAGE"                ] = { name="бретонская свиная колбаса"             , food_item_id=028342, recipe_item_id=045900, recipe_list_index=  1, recipe_index= 13}
, ["CARROT_SOUP"                        ] = { name="морковный суп"                         , food_item_id=028321, recipe_item_id=045887, recipe_list_index=  3, recipe_index=  1}
, ["CHICKEN_BREAST"                     ] = { name="куриная грудка"                        , food_item_id=033819, recipe_item_id=045935, recipe_list_index=  1, recipe_index=  3}
, ["CHORROL_CORN_ON_THE_COB"            ] = { name="корролский початок кукурузы"           , food_item_id=033514, recipe_item_id=045929, recipe_list_index=  3, recipe_index= 20}
, ["CINNAMON_GRAPE_JELLY"               ] = { name="виноградное желе с корицей"            , food_item_id=042790, recipe_item_id=045907, recipe_list_index=  2, recipe_index= 19}
, ["CLARIFIED_SYRAH_WINE"               ] = { name="очищенное вино сорта шираз"            , food_item_id=028409, recipe_item_id=045972, recipe_list_index=  8, recipe_index=  7, name_2="очищенное вино сорта шираз"}
, ["COMELY_WENCH_WHISKEY"               ] = { name="виски «Смазливая девка»"               , food_item_id=028402, recipe_item_id=046048, recipe_list_index=  8, recipe_index= 31}
, ["CYRODILIC_CORNBREAD"                ] = { name="сиродильский кукурузный хлеб"          , food_item_id=033897, recipe_item_id=045958, recipe_list_index=  3, recipe_index= 25}
, ["CYRODILIC_PUMPKIN_FRITTERS"         ] = { name="тыква во фритюре по-сиродильски"       , food_item_id=033789, recipe_item_id=045931, recipe_list_index=  2, recipe_index= 20}
, ["ELENHIR_ROAST_ANTELOPE"             ] = { name="жареная оленина по-элинирски"          , food_item_id=033520, recipe_item_id=045930, recipe_list_index=  1, recipe_index= 20}
, ["ELTHERIC_HOOCH"                     ] = { name="самогон «Элтерический»"                , food_item_id=028417, recipe_item_id=045974, recipe_list_index=  8, recipe_index= 13, name_2="самогон «Элтерический»"}
, ["FIRSTHOLD_FRUIT_AND_CHEESE_PLATE"   ] = { name="сырная тарелка с фруктами по-фестхолдски", food_item_id=068236, recipe_item_id=068192, recipe_list_index=  2, recipe_index= 40}
, ["FISHY_STICK"                        ] = { name="рыбные палочки"                        , food_item_id=033526, recipe_item_id=045888, recipe_list_index=  1, recipe_index=  1}
, ["FOUR_EYE_GROG"                      ] = { name="грог «Четыре глаза»"                   , food_item_id=033612, recipe_item_id=045982, recipe_list_index=  8, recipe_index=  8}
, ["GARLIC_MASHED_POTATOES"             ] = { name="картофельное пюре с чесноком"          , food_item_id=028346, recipe_item_id=045905, recipe_list_index=  3, recipe_index= 19}
, ["GARLIC_PUMPKIN_SEEDS"               ] = { name="тыквенные семена с чесноком"           , food_item_id=033490, recipe_item_id=045925, recipe_list_index=  2, recipe_index= 14}
, ["GINGER_WHEAT_BEER"                  ] = { name="пшенично-имбирное пиво"                , food_item_id=033963, recipe_item_id=045993, recipe_list_index=  8, recipe_index= 18}
, ["GODS_BLIND_ME"                      ] = { name="«Боги, ослепите меня»"                 , food_item_id=028433, recipe_item_id=045978, recipe_list_index=  8, recipe_index= 25, name_2="«Боги, ослепите меня»"}
, ["GOLDEN_LAGER"                       ] = { name="золотой лагер"                         , food_item_id=033933, recipe_item_id=045988, recipe_list_index=  8, recipe_index=  3}
, ["GOSSAMER_MAZTE"                     ] = { name="мацт «Паутинка»"                       , food_item_id=033957, recipe_item_id=045992, recipe_list_index=  8, recipe_index= 15}
, ["GRANDPAS_BEDTIME_TONIC"             ] = { name="тоник «Дедушкин сонный час»"           , food_item_id=028444, recipe_item_id=046050, recipe_list_index= 10, recipe_index= 31}
, ["GRAPE_PRESERVES"                    ] = { name="виноградное варенье"                   , food_item_id=033825, recipe_item_id=045936, recipe_list_index=  2, recipe_index=  3}
, ["HAGRAVENS_TONIC"                    ] = { name="тоник ворожеи"                         , food_item_id=068263, recipe_item_id=068219, recipe_list_index= 10, recipe_index= 42}
, ["HARE_IN_GARLIC_SAUCE"               ] = { name="заяц в чесночном соусе"                , food_item_id=033581, recipe_item_id=045953, recipe_list_index=  1, recipe_index= 21, name_2="заяц в чесночном соусе"}
, ["HEARTY_GARLIC_CORN_CHOWDER"         ] = { name="наваристый зерновой чаудер с чесноком" , food_item_id=068239, recipe_item_id=068195, recipe_list_index=  3, recipe_index= 40}
, ["HONEY_RYE"                          ] = { name="медово-ржаной виски"                   , food_item_id=028421, recipe_item_id=045975, recipe_list_index=  8, recipe_index= 16}
, ["JERALL_VIEW_INN_CARROT_CAKE"        ] = { name="морковный торт таверны «Радушие Джерола»", food_item_id=033575, recipe_item_id=045952, recipe_list_index=  3, recipe_index= 21}
, ["LEMON_FLOWER_MAZTE"                 ] = { name="лимонный мацт"                         , food_item_id=033945, recipe_item_id=045990, recipe_list_index=  8, recipe_index=  9}
, ["LILMOTH_GARLIC_HAGFISH"             ] = { name="пиявкорот с чесноком по-лилмотски"     , food_item_id=068235, recipe_item_id=068191, recipe_list_index=  1, recipe_index= 42}
, ["LUSTY_ARGONIAN_MAID_MAZTE"          ] = { name="мацт «Похотливая аргонианская дева»"   , food_item_id=068276, recipe_item_id=068232, recipe_list_index= 14, recipe_index= 31, name_2="мацт «Похотливая аргонианская дев"}
, ["MAMMOTH_SNOUT_PIE"                  ] = { name="пирог с хоботом мамонта"               , food_item_id=033903, recipe_item_id=045959, recipe_list_index=  1, recipe_index= 25}
, ["MAORMER_TEA"                        ] = { name="маормерский чай"                       , food_item_id=028465, recipe_item_id=046002, recipe_list_index=  9, recipe_index= 19}
, ["MARKARTH_MEAD"                      ] = { name="маркартский мед"                       , food_item_id=068257, recipe_item_id=068213, recipe_list_index=  8, recipe_index= 42}
, ["MAZTE"                              ] = { name="мацт"                                  , food_item_id=033606, recipe_item_id=045981, recipe_list_index=  8, recipe_index=  5}
, ["MERMAID_WHISKEY"                    ] = { name="виски «Русалка»"                       , food_item_id=033630, recipe_item_id=045985, recipe_list_index=  8, recipe_index= 17}
, ["MILLET_STUFFED_PORK_LOIN"           ] = { name="свиная вырезка с начинкой из пшена"    , food_item_id=043088, recipe_item_id=045965, recipe_list_index=  1, recipe_index= 31}
, ["MULLED_WINE"                        ] = { name="пряное вино"                           , food_item_id=033969, recipe_item_id=045994, recipe_list_index=  8, recipe_index= 21}
, ["MUTHSERAS_REMORSE"                  ] = { name="«Раскаяние мутсэры»"                   , food_item_id=068260, recipe_item_id=068216, recipe_list_index=  9, recipe_index= 42}
, ["NEREID_WINE"                        ] = { name="вино нереиды"                          , food_item_id=033975, recipe_item_id=045995, recipe_list_index=  8, recipe_index= 24}
, ["NIBENESE_GARLIC_CARROTS"            ] = { name="нибенейская морковь с чесноком"        , food_item_id=033478, recipe_item_id=045923, recipe_list_index=  3, recipe_index= 14}
, ["NUT_BROWN_ALE"                      ] = { name="темный ореховый эль"                   , food_item_id=028401, recipe_item_id=045970, recipe_list_index=  8, recipe_index=  1}
, ["ORCREST_GARLIC_APPLE_JELLY"         ] = { name="чесночно-яблочное желе из Оркреста"    , food_item_id=043094, recipe_item_id=045966, recipe_list_index=  2, recipe_index= 31}
, ["PELLITINE_TOMATO_RICE"              ] = { name="пеллитинский рис с томатом"            , food_item_id=042814, recipe_item_id=045901, recipe_list_index=  2, recipe_index= 13}
, ["RED_RYE_BEER"                       ] = { name="красное ржаное пиво"                   , food_item_id=033600, recipe_item_id=045980, recipe_list_index=  8, recipe_index=  2}
, ["REDORAN_PEPPERED_MELON"             ] = { name="редоранская перченая дыня"             , food_item_id=033552, recipe_item_id=045948, recipe_list_index=  2, recipe_index= 15}
, ["ROAST_CORN"                         ] = { name="жареная кукуруза"                      , food_item_id=033813, recipe_item_id=045934, recipe_list_index=  3, recipe_index=  3}
, ["RYE_IN_YOUR_EYE"                    ] = { name="«Рожь-в-глазах»"                       , food_item_id=028429, recipe_item_id=045977, recipe_list_index=  8, recipe_index= 22}
, ["SEAFLOWER_TEA"                      ] = { name="чай «Морской цветок»"                  , food_item_id=034005, recipe_item_id=046018, recipe_list_index=  9, recipe_index= 15}
, ["SENCHAL_CURRY_FISH_AND_RICE"        ] = { name="сенчальское рыбное карри с рисом"      , food_item_id=028350, recipe_item_id=045906, recipe_list_index=  1, recipe_index= 19}
, ["SKYRIM_JAZBAY_CROSTATA"             ] = { name="песочная полоска с желе из винограда джазби", food_item_id=033909, recipe_item_id=045960, recipe_list_index=  2, recipe_index= 25}
, ["SORRY_HONEY_LAGER"                  ] = { name="лагер «Извини, дорогая»"               , food_item_id=033642, recipe_item_id=045987, recipe_list_index=  8, recipe_index= 23}
, ["SOUR_MASH"                          ] = { name="кислый затор"                          , food_item_id=028425, recipe_item_id=045976, recipe_list_index=  8, recipe_index= 19}
, ["SPICEBERRY_CHAI"                    ] = { name="пряный ягодный чай"                    , food_item_id=033684, recipe_item_id=046012, recipe_list_index=  9, recipe_index= 20}
, ["SPICED_MAZTE"                       ] = { name="пряный мацт"                           , food_item_id=033636, recipe_item_id=045986, recipe_list_index=  8, recipe_index= 20}
, ["STORMHOLD_BAKED_BANANAS"            ] = { name="печеные бананы по-стормхолдски"        , food_item_id=033587, recipe_item_id=045954, recipe_list_index=  2, recipe_index= 21}
, ["SURILIE_SYRAH_WINE"                 ] = { name="вино Сурили сорта шираз"               , food_item_id=033939, recipe_item_id=045989, recipe_list_index=  8, recipe_index=  6}
, ["TORVAL_MINT_TEA"                    ] = { name="торвальский мятный чай"                , food_item_id=034017, recipe_item_id=046020, recipe_list_index=  9, recipe_index= 21}
, ["TREACLEBERRY_TEA"                   ] = { name="ягодный чай с патокой"                 , food_item_id=033672, recipe_item_id=046010, recipe_list_index=  9, recipe_index= 14}
, ["TWO_ZEPHYR_TEA"                     ] = { name="чай «Два зефира»"                      , food_item_id=028473, recipe_item_id=046004, recipe_list_index=  9, recipe_index= 25}
, ["VENISON_PASTY"                      ] = { name="корзиночка с олениной"                 , food_item_id=028398, recipe_item_id=045947, recipe_list_index=  1, recipe_index= 15}
, ["WEST_WEALD_CORN_CHOWDER"            ] = { name="зерновой чаудер Западного Вельда"      , food_item_id=032160, recipe_item_id=045964, recipe_list_index=  3, recipe_index= 31}
, ["WHITERUN_CHEESE_BAKED_TROUT"        ] = { name="запеченная с сыром вайтранская форель" , food_item_id=033484, recipe_item_id=045924, recipe_list_index=  1, recipe_index= 14}

-- master
, ["CAPON_TOMATO_BEET_CASSEROLE"        ] = { name="томатно-свекольная запеканка с каплуном", food_item_id=068251, recipe_item_id=068207, recipe_list_index=  7, recipe_index= 28}
, ["JUGGED_RABBIT_IN_PRESERVES"         ] = { name="консервированный тушеный кролик"       , food_item_id=068252, recipe_item_id=068208, recipe_list_index=  7, recipe_index= 29}
, ["LONGFIN_PASTY_WITH_MELON_SAUCE"     ] = { name="хлебный конверт с окунем в дынном соусе", food_item_id=068253, recipe_item_id=068209, recipe_list_index=  7, recipe_index= 30, name_2="хлебный конверт с окунем в дынном"}
, ["LUSTY_ARGONIAN_MAID_MAZTE"          ] = { name="мацт «Похотливая аргонианская дева»"   , food_item_id=068276, recipe_item_id=068232, recipe_list_index= 14, recipe_index= 31, name_2="мацт «Похотливая аргонианская дев"}
, ["ORCREST_AGONY_PALE_ALE"             ] = { name="светлый эль «Агония Оркреста»"         , food_item_id=068275, recipe_item_id=068231, recipe_list_index= 14, recipe_index= 30, name_2="светлый эль «Агония Орк"}
, ["ORZORGAS_BLOOD_PRICE_PIE"           ] = { name="ценная корзиночка с кровью от Орзорги" , food_item_id=071058, recipe_item_id=071062, recipe_list_index= 16, recipe_index=  3, name_2="ценная корзиночка с кровью от Орзо"}
, ["ORZORGAS_RED_FROTHGAR"              ] = { name="красный пенный напиток от Орзорги"     , food_item_id=071056, recipe_item_id=071060, recipe_list_index= 15, recipe_index= 14, name_2="красный пенный напиток от Ор"}
, ["ORZORGAS_SMOKED_BEAR_HAUNCH"        ] = { name="копченый медвежий окорок от Орзорги"   , food_item_id=071059, recipe_item_id=071063, recipe_list_index= 16, recipe_index=  4, name_2="копченый медвежий окорок от Орзо"}
, ["ORZORGAS_TRIPE_TRIFLE_POCKET"       ] = { name="хлебный конверт с требухой от Орзорги" , food_item_id=071057, recipe_item_id=071061, recipe_list_index= 16, recipe_index=  2, name_2="хлебный конверт с требухой от Орзо"}
, ["PSIJIC_AMBROSIA"                    ] = { name="амброзия Псиджиков"                    , food_item_id=064221, recipe_item_id=064223, recipe_list_index= 15, recipe_index=  1, name_2="амброзия Псид"}
, ["SENCHE_TIGER_SINGLE_MALT"           ] = { name="односолодовый виски «Сенч-тигр»"       , food_item_id=068273, recipe_item_id=068229, recipe_list_index= 14, recipe_index= 28, name_2="односолодовый виски «Сенч"}
, ["VELOTHI_VIEW_VINTAGE_MALBEC"        ] = { name="выдержанный мальбек «Велотийский вид»" , food_item_id=068274, recipe_item_id=068230, recipe_list_index= 14, recipe_index= 29, name_2="выдержанный мальбек «Велотийский"}
, ["WITHERED_TREE_INN_VENISON_POT_ROAST"] = { name="тушеная оленина из «Высохшего дерева»" , food_item_id=068254, recipe_item_id=068210, recipe_list_index=  7, recipe_index= 31, name_2="хлебный конверт с окунем в дынном"}
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
  ["IRON"                    ] = { name="iron"                           , crafting_type=bs, level_index= 1, material_index= 1, master_writ2=  1, mat_set_id=mat_hvy  }
, ["STEEL"                   ] = { name="steel"                          , crafting_type=bs, level_index= 2, material_index= 8, master_writ2=  9, mat_set_id=mat_hvy  }
, ["ORICHALC"                ] = { name="orichalc"                       , crafting_type=bs, level_index= 3, material_index=13, master_writ2=156, mat_set_id=mat_hvy  }
, ["DWARVEN"                 ] = { name="dwarven"                        , crafting_type=bs, level_index= 4, material_index=18, master_writ2=160, mat_set_id=mat_hvy  , name_2="dwarven"        }
, ["EBONY"                   ] = { name="ebon"                           , crafting_type=bs, level_index= 5, material_index=23, master_writ2=164, mat_set_id=mat_hvy  , name_2="ebon"           }
, ["CALCINIUM"               ] = { name="calcinium"                      , crafting_type=bs, level_index= 6, material_index=26, master_writ2=168, mat_set_id=mat_hvy  }
, ["GALATITE"                ] = { name="galatite"                       , crafting_type=bs, level_index= 7, material_index=29, master_writ2=172, mat_set_id=mat_hvy  }
, ["QUICKSILVER"             ] = { name="quicksilver"                    , crafting_type=bs, level_index= 8, material_index=32, master_writ2=176, mat_set_id=mat_hvy  }
, ["VOIDSTEEL"               ] = { name="voidsteel"                      , crafting_type=bs, level_index= 9, material_index=34, master_writ2=180, mat_set_id=mat_hvy  }
, ["RUBEDITE"                ] = { name="Rubedite"                       , crafting_type=bs, level_index=10, material_index=40, master_writ2=188, mat_set_id=mat_hvy  }

, ["JUTE"                    ] = { name="homespun"                       , crafting_type=cl, level_index= 1, material_index= 1, master_writ2=  5, mat_set_id=mat_lgt  , name_2="homespun"        }
, ["LINEN"                   ] = { name="linen"                          , crafting_type=cl, level_index= 2, material_index= 8, master_writ2= 45, mat_set_id=mat_lgt  }
, ["COTTON"                  ] = { name="cotton"                         , crafting_type=cl, level_index= 3, material_index=13, master_writ2= 47, mat_set_id=mat_lgt  }
, ["SPIDERSILK"              ] = { name="spidersilk"                     , crafting_type=cl, level_index= 4, material_index=18, master_writ2= 49, mat_set_id=mat_lgt  }
, ["EBONTHREAD"              ] = { name="ebonthread"                     , crafting_type=cl, level_index= 5, material_index=23, master_writ2= 51, mat_set_id=mat_lgt  }
, ["KRESH"                   ] = { name="kresh"                          , crafting_type=cl, level_index= 6, material_index=26, master_writ2=125, mat_set_id=mat_lgt  }
, ["IRONTHREAD"              ] = { name="ironthread"                     , crafting_type=cl, level_index= 7, material_index=29, master_writ2=126, mat_set_id=mat_lgt  , name_2="ironthread"      }
, ["SILVERWEAVE"             ] = { name="silverweave"                    , crafting_type=cl, level_index= 8, material_index=32, master_writ2=127, mat_set_id=mat_lgt  }
, ["SHADOWSPUN"              ] = { name="shadowspun"                     , crafting_type=cl, level_index= 9, material_index=34, master_writ2=128, mat_set_id=mat_lgt  }
, ["ANCESTOR_SILK"           ] = { name="Ancestor Silk"                  , crafting_type=cl, level_index=10, material_index=40, master_writ2=194, mat_set_id=mat_lgt  , name_2="Ancestor Silk"   }

, ["RAWHIDE"                 ] = { name="rawhide"                        , crafting_type=cl, level_index= 1, material_index= 1, master_writ2=148, mat_set_id=mat_med  }
, ["HIDE"                    ] = { name="hide"                           , crafting_type=cl, level_index= 2, material_index= 8, master_writ2=154, mat_set_id=mat_med  }
, ["LEATHER"                 ] = { name="leather"                        , crafting_type=cl, level_index= 3, material_index=13, master_writ2=158, mat_set_id=mat_med  }
, ["FULL_LEATHER"            ] = { name="full-leather"                   , crafting_type=cl, level_index= 4, material_index=18, master_writ2=162, mat_set_id=mat_med  }
, ["FELL_HIDE"               ] = { name="fell"                           , crafting_type=cl, level_index= 5, material_index=23, master_writ2=166, mat_set_id=mat_med  }
, ["BRIGANDINE"              ] = { name="brigandine"                     , crafting_type=cl, level_index= 6, material_index=26, master_writ2=170, mat_set_id=mat_med  , name_2="brigandine"      }
, ["IRONHIDE"                ] = { name="ironhide"                       , crafting_type=cl, level_index= 7, material_index=29, master_writ2=174, mat_set_id=mat_med  }
, ["SUPERB"                  ] = { name="superb"                         , crafting_type=cl, level_index= 8, material_index=32, master_writ2=131, mat_set_id=mat_med  , name_2="superb"          }
, ["SHADOWHIDE"              ] = { name="shadowhide"                     , crafting_type=cl, level_index= 9, material_index=34, master_writ2=132, mat_set_id=mat_med  }
, ["RUBEDO_LEATHER"          ] = { name="Rubedo Leather"                 , crafting_type=cl, level_index=10, material_index=40, master_writ2=190, mat_set_id=mat_med  }

, ["MAPLE"                   ] = { name="maple"                          , crafting_type=ww, level_index= 1, material_index= 1, master_writ2=  2, mat_set_id=mat_wood }
, ["OAK"                     ] = { name="oak"                            , crafting_type=ww, level_index= 2, material_index= 8, master_writ2= 18, mat_set_id=mat_wood }
, ["BEECH"                   ] = { name="beech"                          , crafting_type=ww, level_index= 3, material_index=13, master_writ2= 20, mat_set_id=mat_wood }
, ["HICKORY"                 ] = { name="hickory"                        , crafting_type=ww, level_index= 4, material_index=18, master_writ2= 22, mat_set_id=mat_wood }
, ["YEW"                     ] = { name="yew"                            , crafting_type=ww, level_index= 5, material_index=23, master_writ2= 24, mat_set_id=mat_wood }
, ["BIRCH"                   ] = { name="birch"                          , crafting_type=ww, level_index= 6, material_index=26, master_writ2=133, mat_set_id=mat_wood }
, ["ASH"                     ] = { name="ash"                            , crafting_type=ww, level_index= 7, material_index=29, master_writ2=134, mat_set_id=mat_wood }
, ["MAHOGANY"                ] = { name="mahogany"                       , crafting_type=ww, level_index= 8, material_index=32, master_writ2=135, mat_set_id=mat_wood }
, ["NIGHTWOOD"               ] = { name="nightwood"                      , crafting_type=ww, level_index= 9, material_index=34, master_writ2=136, mat_set_id=mat_wood }
, ["RUBY_ASH"                ] = { name="Ruby Ash"                       , crafting_type=ww, level_index=10, material_index=40, master_writ2=192, mat_set_id=mat_wood }

, ["PEWTER"                  ] = { name="pewter"                         , crafting_type=jw, level_index= 1, material_index= 1, master_writ2=  6, mat_set_id=mat_jewl }
, ["COPPER"                  ] = { name="copper"                         , crafting_type=jw, level_index= 2, material_index=13, master_writ2= 56, mat_set_id=mat_jewl }
, ["SILVER"                  ] = { name="silver"                         , crafting_type=jw, level_index= 3, material_index=26, master_writ2=137, mat_set_id=mat_jewl }
, ["ELECTRUM"                ] = { name="electrum"                       , crafting_type=jw, level_index= 4, material_index=33, master_writ2=139, mat_set_id=mat_jewl , name_2="electrum"       }
, ["PLATINUM"                ] = { name="platinum"                       , crafting_type=jw, level_index= 5, material_index=40, master_writ2=255, mat_set_id=mat_jewl }

, ["BLESSED_THISTLE"         ] = { name="благословенный чертополох"      , crafting_type=al, item_id= 30157 }
, ["BLUE_ENTOLOMA"           ] = { name="голубая энтолома"               , crafting_type=al, item_id= 30148 }
, ["BUGLOSS"                 ] = { name="воловик"                        , crafting_type=al, item_id= 30160 }
, ["COLUMBINE"               ] = { name="водосбор"                       , crafting_type=al, item_id= 30164 }
, ["CORN_FLOWER"             ] = { name="василек"                        , crafting_type=al, item_id= 30161 }
, ["DRAGONTHORN"             ] = { name="драконий шип"                   , crafting_type=al, item_id= 30162 }
, ["EMETIC_RUSSULA"          ] = { name="жгучеедкая сыроежка"            , crafting_type=al, item_id= 30151 }
, ["IMP_STOOL"               ] = { name="бесовский гриб"                 , crafting_type=al, item_id= 30156 }
, ["LADYS_SMOCK"             ] = { name="луговой сердечник"              , crafting_type=al, item_id= 30158 }
, ["LUMINOUS_RUSSULA"        ] = { name="светящаяся сыроежка"            , crafting_type=al, item_id= 30155 }
, ["MOUNTAIN_FLOWER"         ] = { name="горноцвет"                      , crafting_type=al, item_id= 30163 }
, ["NAMIRAS_ROT"             ] = { name="гниль Намиры"                   , crafting_type=al, item_id= 30153 }
, ["NIRNROOT"                ] = { name="корень Нирна"                   , crafting_type=al, item_id= 30165 }
, ["STINKHORN"               ] = { name="цветохвостник веретеновидный"   , crafting_type=al, item_id= 30149 }
, ["VIOLET_COPRINUS"         ] = { name="лиловый копринус"               , crafting_type=al, item_id= 30152 , name_2="лиловый копринус"   }
, ["WATER_HYACINTH"          ] = { name="водный гиацинт"                 , crafting_type=al, item_id= 30166 }
, ["WHITE_CAP"               ] = { name="белянка"                        , crafting_type=al, item_id= 30154 }
, ["WORMWOOD"                ] = { name="полынь"                         , crafting_type=al, item_id= 30159 }
, ["BEETLE_SCUTTLE"          ] = { name="Жучиный скатл"                  , crafting_type=al, item_id= 77583 }
, ["BUTTERFLY_WING"          ] = { name="Крыло бабочки"                  , crafting_type=al, item_id= 77585 }
, ["FLESHFLY_LARVA"          ] = { name="Личинка мясной мухи"            , crafting_type=al, item_id= 77587 }
, ["MUDCRAB_CHITIN"          ] = { name="Хитин грязевого краба"          , crafting_type=al, item_id= 77591 }
, ["NIGHTSHADE"              ] = { name="Паслен"                         , crafting_type=al, item_id= 77590 }
, ["SCRIB_JELLY"             ] = { name="Скрибовое желе"                 , crafting_type=al, item_id= 77589 }
, ["SPIDER_EGG"              ] = { name="Паучье яйцо"                    , crafting_type=al, item_id= 77584 }
, ["TORCHBUG_THORAX"         ] = { name="Торакс светлячка"               , crafting_type=al, item_id= 77581 }
, ["CLAM_GALL"               ] = { name="желчь моллюска"                 , crafting_type=al, item_id=139020 }
, ["POWDERED_MOTHER_OF_PEARL"] = { name="измельченный перламутр"         , crafting_type=al, item_id=139019 }

, ["NATURAL_WATER"           ] = { name="природная вода"                 , crafting_type=al, item_id=   883 , name_2="природную воду"     , rank=1, potion_name="sip"                     }
, ["CLEAR_WATER"             ] = { name="чистая вода"                    , crafting_type=al, item_id=  1187                               , rank=2, potion_name="tincture"                }
, ["PRISTINE_WATER"          ] = { name="нетронутая вода"                , crafting_type=al, item_id=  4570 , name_2="нетронутую воду"    , rank=3, potion_name="dram"                    , potion_name2="dram"                     }
, ["CLEANSED_WATER"          ] = { name="очищенная вода"                 , crafting_type=al, item_id= 23265 , name_2="очищенную воду"     , rank=4, potion_name="potion"                  }
, ["FILTERED_WATER"          ] = { name="фильтрованная вода"             , crafting_type=al, item_id= 23266 , name_2="фильтрованную воду" , rank=5, potion_name="solution"                }
, ["PURIFIED_WATER"          ] = { name="дистиллированная вода"          , crafting_type=al, item_id= 23267 , name_2="дистиллированную воду", rank=6, potion_name="elixir"                  }
, ["CLOUD_MIST"              ] = { name="облачный пар"                   , crafting_type=al, item_id= 23268                               , rank=7, potion_name="panacea"                 }
, ["STAR_DEW"                ] = { name="звездная роса"                  , crafting_type=al, item_id= 64500                               , rank=8, potion_name="distillate"              }
, ["LORKHANS_TEARS"          ] = { name="Слезы Лорхана"                  , crafting_type=al, item_id= 64501                               , rank=9, potion_name="essence"                 }

, ["GREASE"                  ] = { name="Топленое сало"                  , crafting_type=al, item_id= 75357                               , rank=1, poison_name="i"                       }
, ["ICHOR"                   ] = { name="Сукровица"                      , crafting_type=al, item_id= 75358                               , rank=2, poison_name="ii"                      }
, ["SLIME"                   ] = { name="Слизь"                          , crafting_type=al, item_id= 75359                               , rank=3, poison_name="iii"                     }
, ["GALL"                    ] = { name="Желчь"                          , crafting_type=al, item_id= 75360                               , rank=4, poison_name="iv"                      }
, ["TEREBINTHINE"            ] = { name="Терпентинное масло"             , crafting_type=al, item_id= 75361                               , rank=5, poison_name="v"                       }
, ["PITCH_BILE"              ] = { name="Смоляная желчь"                 , crafting_type=al, item_id= 75362                               , rank=6, poison_name="vi"                      }
, ["TARBLACK"                ] = { name="Дегтярное масло"                , crafting_type=al, item_id= 75363                               , rank=7, poison_name="vii"                     }
, ["NIGHT_OIL"               ] = { name="Ночное масло"                   , crafting_type=al, item_id= 75364                               , rank=8, poison_name="viii"                    }
, ["ALKAHEST"                ] = { name="Алкагест"                       , crafting_type=al, item_id= 75365                               , rank=9, poison_name="ix"                      }

, ["JORA"                    ] = { name="Джора"                          , crafting_type=en, item_id= 45855 , name_2="trifling"      }
, ["PORADE"                  ] = { name="Пораде"                         , crafting_type=en, item_id= 45856 }
, ["JERA"                    ] = { name="Джера"                          , crafting_type=en, item_id= 45857 , name_2="petty"         }
, ["JEJORA"                  ] = { name="Джеджора"                       , crafting_type=en, item_id= 45806 }
, ["ODRA"                    ] = { name="Одра"                           , crafting_type=en, item_id= 45807 , name_2="minor"         }
, ["POJORA"                  ] = { name="Поджора"                        , crafting_type=en, item_id= 45808 }
, ["EDORA"                   ] = { name="Эдора"                          , crafting_type=en, item_id= 45809 , name_2="moderate"      }
, ["JAERA"                   ] = { name="Джейра"                         , crafting_type=en, item_id= 45810 }
, ["PORA"                    ] = { name="Пора"                           , crafting_type=en, item_id= 45811 , name_2="strong"        }
, ["DENARA"                  ] = { name="Денара"                         , crafting_type=en, item_id= 45812 }
, ["RERA"                    ] = { name="Рера"                           , crafting_type=en, item_id= 45813 , name_2="greater"       }
, ["DERADO"                  ] = { name="Дерадо"                         , crafting_type=en, item_id= 45814 , name_2="grand"        , name_3="grand"          }
, ["REKURA"                  ] = { name="Рекура"                         , crafting_type=en, item_id= 45815 , name_2="splendid"      }
, ["KURA"                    ] = { name="Кура"                           , crafting_type=en, item_id= 45816 , name_2="monumental"    }
, ["REJERA"                  ] = { name="Реджера"                        , crafting_type=en, item_id= 64509 , name_2="superb"        }
, ["REPORA"                  ] = { name="Репора"                         , crafting_type=en, item_id= 68341 , name_2="truly superb"  }

, ["JODE"                    ] = { name="Джоде"                          , crafting_type=en, item_id= 45817 }
, ["NOTADE"                  ] = { name="Нотаде"                         , crafting_type=en, item_id= 45818 }
, ["ODE"                     ] = { name="Оде"                            , crafting_type=en, item_id= 45819 }
, ["TADE"                    ] = { name="Таде"                           , crafting_type=en, item_id= 45820 }
, ["JAYDE"                   ] = { name="Джайде"                         , crafting_type=en, item_id= 45821 }
, ["EDODE"                   ] = { name="Эдоде"                          , crafting_type=en, item_id= 45822 }
, ["POJODE"                  ] = { name="Поджоде"                        , crafting_type=en, item_id= 45823 }
, ["REKUDE"                  ] = { name="Рекуде"                         , crafting_type=en, item_id= 45824 }
, ["HADE"                    ] = { name="Хаде"                           , crafting_type=en, item_id= 45825 }
, ["IDODE"                   ] = { name="Идоде"                          , crafting_type=en, item_id= 45826 }
, ["PODE"                    ] = { name="Поде"                           , crafting_type=en, item_id= 45827 }
, ["KEDEKO"                  ] = { name="Кедеко"                         , crafting_type=en, item_id= 45828 }
, ["REDE"                    ] = { name="Реде"                           , crafting_type=en, item_id= 45829 }
, ["KUDE"                    ] = { name="Куде"                           , crafting_type=en, item_id= 45830 }
, ["JEHADE"                  ] = { name="Джехаде"                        , crafting_type=en, item_id= 64508 }
, ["ITADE"                   ] = { name="Итаде"                          , crafting_type=en, item_id= 68340 }

, ["DEKEIPA"                 ] = { name="Декейпа"                        , crafting_type=en, item_id= 45839 , add="frost"            , sub="frost resist"      }
, ["DENI"                    ] = { name="Дени"                           , crafting_type=en, item_id= 45833 , add="stamina"          , sub="absorb stamina"   , add_2="stamina"             }
, ["DENIMA"                  ] = { name="Денима"                         , crafting_type=en, item_id= 45836 , add="stamina recovery" , sub="reduce feat cost"  }
, ["DETERI"                  ] = { name="Детери"                         , crafting_type=en, item_id= 45842 , add="hardening"        , sub="crushing"          }
, ["HAOKO"                   ] = { name="Хаоко"                          , crafting_type=en, item_id= 45841 , add="foulness"         , sub="disease resist"    }
, ["HAKEIJO"                 ] = { name="Хакейджо"                       , crafting_type=en, item_id= 68342 , add="prismatic defense", sub="prismatic onslaught"}
, ["KADERI"                  ] = { name="Кадери"                         , crafting_type=en, item_id= 45849 , add="bashing"          , sub="shielding"         }
, ["KUOKO"                   ] = { name="Куоко"                          , crafting_type=en, item_id= 45837 , add="poison"           , sub="poison resist"     }
, ["MAKDERI"                 ] = { name="Макдери"                        , crafting_type=en, item_id= 45848 , add="increase magical harm", sub="decrease spell harm"}
, ["MAKKO"                   ] = { name="Макко"                          , crafting_type=en, item_id= 45832 , add="magicka"          , sub="absorb magicka"   , add_2="magicka"             }
, ["MAKKOMA"                 ] = { name="Маккома"                        , crafting_type=en, item_id= 45835 , add="magicka recovery" , sub="reduce spell cost" }
, ["MEIP"                    ] = { name="Мейп"                           , crafting_type=en, item_id= 45840 , add="shock"            , sub="shock resist"      }
, ["OKO"                     ] = { name="Око"                            , crafting_type=en, item_id= 45831 , add="health"           , sub="absorb health"    , add_2="health"              }
, ["OKOMA"                   ] = { name="Окома"                          , crafting_type=en, item_id= 45834 , add="health recovery"  , sub="decrease health"   }
, ["OKORI"                   ] = { name="Окори"                          , crafting_type=en, item_id= 45843 , add="weapon damage"    , sub="weakening"         }
, ["ORU"                     ] = { name="Ору"                            , crafting_type=en, item_id= 45846 , add="potion boost"     , sub="potion speed"      }
, ["RAKEIPA"                 ] = { name="Ракейпа"                        , crafting_type=en, item_id= 45838 , add="flame"            , sub="flame resist"      }
, ["TADERI"                  ] = { name="Тадери"                         , crafting_type=en, item_id= 45847 , add="increase physical harm", sub="decrease physical harm"}

, ["TA"                      ] = { name="Та"                             , crafting_type=en, item_id= 45850 , name_2="Обычное"  }
, ["JEJOTA"                  ] = { name="Джеджота"                       , crafting_type=en, item_id= 45851 , name_2="Хорошее"  }
, ["DENATA"                  ] = { name="Дената"                         , crafting_type=en, item_id= 45852 , name_2="Превосходное"}
, ["REKUTA"                  ] = { name="Рекута"                         , crafting_type=en, item_id= 45853 , name_2="Эпическое"}
, ["KUTA"                    ] = { name="Кута"                           , crafting_type=en, item_id= 45854 , name_2="Легендарное"}

, ["QUARTZ"                  ] = { name="кварц"                          ,                   item_id=  4456 }
, ["DIAMOND"                 ] = { name="алмаз"                          ,                   item_id= 23219 }
, ["SARDONYX"                ] = { name="сардоникс"                      ,                   item_id= 30221 }
, ["ALMANDINE"               ] = { name="альмандин"                      ,                   item_id= 23221 }
, ["EMERALD"                 ] = { name="изумруд"                        ,                   item_id=  4442 }
, ["BLOODSTONE"              ] = { name="кровавик"                       ,                   item_id= 30219 }
, ["GARNET"                  ] = { name="гранат"                         ,                   item_id= 23171 }
, ["SAPPHIRE"                ] = { name="сапфир"                         ,                   item_id= 23173 }
, ["FORTIFIED_NIRNCRUX"      ] = { name="укрепленный нирнкрукс"          ,                   item_id= 56862 }
, ["CHYSOLITE"               ] = { name="хризолит"                       ,                   item_id= 23203 }
, ["AMETHYST"                ] = { name="аметист"                        ,                   item_id= 23204 }
, ["RUBY"                    ] = { name="рубин"                          ,                   item_id=  4486 }
, ["JADE"                    ] = { name="нефрит"                         ,                   item_id=   810 }
, ["TURQUOISE"               ] = { name="бирюза"                         ,                   item_id=   813 }
, ["CARNELIAN"               ] = { name="сердолик"                       ,                   item_id= 23165 }
, ["FIRE_OPAL"               ] = { name="огненный опал"                  ,                   item_id= 23149 }
, ["CITRINE"                 ] = { name="цитрин"                         ,                   item_id= 16291 }
, ["POTENT_NIRNCRUX"         ] = { name="мощный нирнкрукс"               ,                   item_id= 56863 }
, ["COBALT"                  ] = { name="кобальт"                        ,                   item_id=135155 }
, ["ANTIMONY"                ] = { name="сурьма"                         ,                   item_id=135156 }
, ["ZINC"                    ] = { name="цинк"                           ,                   item_id=135157 }
, ["DAWN_PRISM"              ] = { name="призма рассвета"                ,                   item_id=139409 }
, ["DIBELLIUM"               ] = { name="дибеллий"                       ,                   item_id=139413 }
, ["GILDING_WAX"             ] = { name="воск для золочения"             ,                   item_id=139412 }
, ["AURBIC_AMBER"            ] = { name="аурбический янтарь"             ,                   item_id=139411 }
, ["TITANIUM"                ] = { name="титан"                          ,                   item_id=139410 }
, ["SLAUGHTERSTONE"          ] = { name="убийственный камень"            ,                   item_id=139414 }

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
    ["RESTORE_HEALTH"         ] = { trait_index=01, name="Восстановление здоровья"  , master_potion="Essence of health"                 , master_poison="Drain Health Poison IX"            , daily_potion_name="health"                       , daily_poison_name="drain health"                 }
,   ["RAVAGE_HEALTH"          ] = { trait_index=02, name="Опустошение здоровья"     , master_potion="Essence of Ravage Health"          , master_poison="Damage Health Poison IX"           , daily_potion_name="ravage health"                , daily_poison_name="damage health"                , daily_poison_name2="damage health"                }
,   ["RESTORE_MAGICKA"        ] = { trait_index=03, name="Восстановление магии"     , master_potion="Essence of Magicka"                , master_poison="Drain Magicka Poison IX"           , daily_potion_name="magicka"                      , daily_poison_name="drain magicka"                }
,   ["RAVAGE_MAGICKA"         ] = { trait_index=04, name="Опустошение магии"        , master_potion="Essence of Ravage Magicka"         , master_poison="Damage Magicka Poison IX"          , daily_potion_name="ravage magicka"               , daily_poison_name="damage magicka"               , daily_poison_name2="ravage magicka"                }
,   ["RESTORE_STAMINA"        ] = { trait_index=05, name="Восстановление запаса сил", master_potion="Essence of stamina"                , master_poison="Drain Stamina Poison IX"           , daily_potion_name="stamina"                      , daily_poison_name="drain stamina"                }
,   ["RAVAGE_STAMINA"         ] = { trait_index=06, name="Опустошение запаса сил"   , master_potion="Essence of Ravage Stamina"         , master_poison="Damage Stamina Poison IX"          , daily_potion_name="ravage stamina"               , daily_poison_name="damage stamina"               , daily_poison_name2="damage stamina"                }
,   ["SPELL_RESISTANCE"       ] = { trait_index=07, name="Увеличение защиты от магии", master_potion="Essence of Spell Protection"       , master_poison="Яд ослабления защиты IX"           }
,   ["BREACH"                 ] = { trait_index=08, name="Разрыв"                   , master_potion="Essence of Ravage Spell Protection", master_poison="Breaching Poison IX"               }
,   ["INCREASE_ARMOR"         ] = { trait_index=09, name="Увеличение брони"         , master_potion="Essence of Armor"                  , master_poison="Resolve-Draining Poison IX"        }
,   ["FRACTURE"               ] = { trait_index=10, name="Перелом"                  , master_potion="Essence of Ravage Armor"           , master_poison="Fracturing Poison IX"              }
,   ["INCREASE_SPELL_POWER"   ] = { trait_index=11, name="Увеличение силы заклинаний", master_potion="Essence of Spell Power"            , master_poison="Sorcery-Draining Poison IX"        }
,   ["COWARDICE"              ] = { trait_index=12, name="Трусость"                 , master_potion="Essence of Cowardice"              , master_poison="Cowardice Poison IX"               }
,   ["INCREASE_WEAPON_POWER"  ] = { trait_index=13, name="Увеличение силы оружия"   , master_potion="Essence of Weapon Power"           , master_poison="Brutality-Draining Poison IX"      }
,   ["MAIM"                   ] = { trait_index=14, name="Травма"                   , master_potion="Essence of Maim"                   , master_poison="Maiming Poison IX"                 }
,   ["SPELL_CRITICAL"         ] = { trait_index=15, name="Критический урон заклинаниями", master_potion="Essence of Spell Critical"         , master_poison="Prophecy-Draining Poison IX"       }
,   ["UNCERTAINTY"            ] = { trait_index=16, name="Неуверенность"            , master_potion="Essence of Uncertainty"            , master_poison="Uncertainty Poison IX"             }
,   ["WEAPON_CRITICAL"        ] = { trait_index=17, name="Критический урон оружием" , master_potion="Essence of Weapon Crit"            , master_poison="Savagery-Draining Poison IX"       }
,   ["ENERVATION"             ] = { trait_index=18, name="Слабость"                 , master_potion="Essence of Enervation"             , master_poison="Enervating Poison IX"              }
,   ["UNSTOPPABLE"            ] = { trait_index=19, name="Неудержимость"            , master_potion="Essence of Immovability"           , master_poison="Escapist's Poison IX"              }
,   ["ENTRAPMENT"             ] = { trait_index=20, name="Защемление"               , master_potion="Essence of Entrapment"             , master_poison="Entrapping Poison IX"              }
,   ["DETECTION"              ] = { trait_index=21, name="Обнаружение"              , master_potion="Essence of Detection"              , master_poison="Stealth-Draining Poison IX"        }
,   ["INVISIBLE"              ] = { trait_index=22, name="Невидимость"              , master_potion="Essence of Invisibility"           , master_poison="Conspicuous Poison IX"             }
,   ["SPEED"                  ] = { trait_index=23, name="Скорость"                 , master_potion="Essence of Speed"                  , master_poison="Speed-Draining Poison IX"          }
,   ["HINDRANCE"              ] = { trait_index=24, name="Помеха"                   , master_potion="Essence of Hindering"              , master_poison="Hindering Poison IX"               }
,   ["PROTECTION"             ] = { trait_index=25, name="Защита"                   , master_potion="Essence of Protection"             , master_poison="Protection-Reversing Poison IX"    }
,   ["VULNERABILITY"          ] = { trait_index=26, name="Уязвимость"               , master_potion="Essence of Vulnerability"          , master_poison="Vulnerability Poison IX"           }
,   ["LINGERING_HEALTH"       ] = { trait_index=27, name="Длительное исцеление"     , master_potion="Essence of Lingering Health"       , master_poison="Gradual Health Drain Poison IX"    }
,   ["GRADUAL_RAVAGE_HEALTH"  ] = { trait_index=28, name="Постепенное опустош. здоровья", master_potion="Essence of Creeping Ravage Health" , master_poison="Gradual Ravage Health Poison IX"   }
,   ["VITALITY"               ] = { trait_index=29, name="Живучесть"                , master_potion="Essence of Vitality"               , master_poison="Vitality-Draining Poison IX"       }
,   ["DEFILE"                 ] = { trait_index=30, name="Осквернение"              , master_potion="Essence of Defile"                 , master_poison="Defiling Poison IX"                }
}


-- Craftable Sets ------------------------------------------------------------
--
-- set_id       writ4 field for master writs
--
LibCraftText.SET = {
    ["ADEPT_RIDER"              ] = { name="Adept Rider"                , set_id=385 }
,   ["ALESSIAS_BULWARK"         ] = { name="Alessia's Bulwark"          , set_id= 82 }
,   ["ARMOR_MASTER"             ] = { name="Armor Master"               , set_id=178 }
,   ["ARMOR_OF_THE_SEDUCER"     ] = { name="Armor of the Seducer"       , set_id= 43 }
,   ["ASHEN_GRIP"               ] = { name="Ashen Grip"                 , set_id= 54 }
,   ["ASSASSINS_GUILE"          ] = { name="Assassin's Guile"           , set_id=323 }
,   ["CLEVER_ALCHEMIST"         ] = { name="Clever Alchemist"           , set_id=225 }
,   ["DAEDRIC_TRICKERY"         ] = { name="Daedric Trickery"           , set_id=324 }
,   ["DEATHS_WIND"              ] = { name="Death's Wind"               , set_id= 37 }
,   ["ETERNAL_HUNT"             ] = { name="Eternal Hunt"               , set_id=226 }
,   ["EYES_OF_MARA"             ] = { name="Eyes of Mara"               , set_id= 87 }
,   ["FORTIFIED_BRASS"          ] = { name="Fortified Brass"            , set_id=352 }
,   ["GRAVE_STAKE_COLLECTOR"    ] = { name="Grave-Stake Collector"      , set_id=408 }
,   ["HIST_BARK"                ] = { name="Hist Bark"                  , set_id= 78 }
,   ["HUNDINGS_RAGE"            ] = { name="Hunding's Rage"             , set_id= 80 }
,   ["INNATE_AXIOM"             ] = { name="Innate Axiom"               , set_id=351 }
,   ["KAGRENACS_HOPE"           ] = { name="Kagrenac's Hope"            , set_id= 92 }
,   ["KVATCH_GLADIATOR"         ] = { name="Kvatch Gladiator"           , set_id=240 }
,   ["LAW_OF_JULIANOS"          ] = { name="Law of Julianos"            , set_id=207 }
,   ["MAGNUS_GIFT"              ] = { name="Magnus' Gift"               , set_id= 48 }
,   ["MECHANICAL_ACUITY"        ] = { name="Mechanical Acuity"          , set_id=353 }
,   ["MIGHT_OF_THE_LOST_LEGION" ] = { name="Might of the Lost Legion"   , set_id=410 }
,   ["MORKULDIN"                ] = { name="Morkuldin"                  , set_id=219 }
,   ["NAGA_SHAMAN"              ] = { name="Naga Shaman"                , set_id=409 }
,   ["NIGHT_MOTHERS_GAZE"       ] = { name="Night Mother's Gaze"        , set_id= 51 }
,   ["NIGHTS_SILENCE"           ] = { name="Night's Silence"            , set_id= 40 }
,   ["NOBLES_CONQUEST"          ] = { name="Noble's Conquest"           , set_id=176 }
,   ["NOCTURNALS_FAVOR"         ] = { name="Nocturnal's Favor"          , set_id=387 }
,   ["OBLIVIONS_FOE"            ] = { name="Oblivion's Foe"             , set_id= 73 }
,   ["ORGNUMS_SCALES"           ] = { name="Orgnum's Scales"            , set_id= 84 }
,   ["PELINALS_APTITUDE"        ] = { name="Pelinal's Aptitude"         , set_id=242 }
,   ["REDISTRIBUTOR"            ] = { name="Redistributor"              , set_id=177 }
,   ["SHACKLEBREAKER"           ] = { name="Shacklebreaker"             , set_id=325 }
,   ["SHALIDORS_CURSE"          ] = { name="Shalidor's Curse"           , set_id= 95 }
,   ["SLOADS_SEMBLANCE"         ] = { name="Sload's Semblance"          , set_id=386 }
,   ["SONG_OF_LAMAE"            ] = { name="Song of Lamae"              , set_id= 81 }
,   ["SPECTRES_EYE"             ] = { name="Spectre's Eye"              , set_id= 74 }
,   ["TAVAS_FAVOR"              ] = { name="Tava's Favor"               , set_id=224 }
,   ["TORUGS_PACT"              ] = { name="Torug's Pact"               , set_id= 75 }
,   ["TRIAL_BY_FIRE"            ] = { name="Trial by Fire"              , set_id=208 }
,   ["TWICE_BORN_STAR"          ] = { name="Twice-Born Star"            , set_id=161 }
,   ["TWILIGHTS_EMBRACE"        ] = { name="Twilight's Embrace"         , set_id= 38 }
,   ["VAMPIRES_KISS"            ] = { name="Vampire's Kiss"             , set_id= 44 }
,   ["VARENS_LEGACY"            ] = { name="Varen's Legacy"             , set_id=241 }
,   ["WAY_OF_THE_ARENA"         ] = { name="Way of the Arena"           , set_id=148 }
,   ["WHITESTRAKES_RETRIBUTION" ] = { name="Whitestrake's Retribution"  , set_id= 41 }
,   ["WILLOWS_PATH"             ] = { name="Willow's Path"              , set_id= 79 }
}

-- Craftable Motifs ----------------------------------------------------------
--
-- writ6 field for master writs
--
LibCraftText.MOTIF = {
    ["BRETON"             ] = { name="бретонский"           , motif_id=  1 }
,   ["REDGUARD"           ] = { name="редгардский"          , motif_id=  2 }
,   ["ORC"                ] = { name="орочий"               , motif_id=  3 }
,   ["DARK_ELF"           ] = { name="данмерский"           , motif_id=  4 }
,   ["NORD"               ] = { name="нордский"             , motif_id=  5 }
,   ["ARGONIAN"           ] = { name="аргонианский"         , motif_id=  6 }
,   ["HIGH_ELF"           ] = { name="альтмерский"          , motif_id=  7 }
,   ["WOOD_ELF"           ] = { name="босмерский"           , motif_id=  8 }
,   ["KHAJIIT"            ] = { name="каджитский"           , motif_id=  9 }
,   ["UNIQUE"             ] = { name="уникальный"           , motif_id= 10 }
,   ["THIEVES_GUILD"      ] = { name="Гильдия воров"        , motif_id= 11 }
,   ["DARK_BROTHERHOOD"   ] = { name="Темное Братство"      , motif_id= 12 }
,   ["MALACATH"           ] = { name="Малакат"              , motif_id= 13 }
,   ["DWEMER"             ] = { name="двемерский"           , motif_id= 14 }
,   ["ANCIENT_ELF"        ] = { name="древнеэльфийский"     , motif_id= 15 }
,   ["ORDER_OF_THE_HOUR"  ] = { name="Часовой орден"        , motif_id= 16 }
,   ["BARBARIC"           ] = { name="варварский"           , motif_id= 17 }
,   ["BANDIT"             ] = { name="бандитский"           , motif_id= 18 }
,   ["PRIMAL"             ] = { name="первобытный"          , motif_id= 19 }
,   ["DAEDRIC"            ] = { name="даэдрический"         , motif_id= 20 }
,   ["TRINIMAC"           ] = { name="Тринимак"             , motif_id= 21 }
,   ["ANCIENT_ORC"        ] = { name="древнеорочий"         , motif_id= 22 }
,   ["DAGGERFALL_COVENANT"] = { name="Даггерфольский Ковенант", motif_id= 23 }
,   ["EBONHEART_PACT"     ] = { name="Эбонхартский Пакт"    , motif_id= 24 }
,   ["ALDMERI_DOMINION"   ] = { name="Альдмерский Доминион" , motif_id= 25 }
,   ["MERCENARY"          ] = { name="наемнический"         , motif_id= 26 }
,   ["CELESTIAL"          ] = { name="Небожители"           , motif_id= 27 }
,   ["GLASS"              ] = { name="стеклянный"           , motif_id= 28 }
,   ["XIVKYN"             ] = { name="зивкинский"           , motif_id= 29 }
,   ["SOUL_SHRIVEN"       ] = { name="душелишенные"         , motif_id= 30 }
,   ["DRAUGR"             ] = { name="драугрский"           , motif_id= 31 }
,   ["MAORMER"            ] = { name="маормерский"          , motif_id= 32 }
,   ["AKAVIRI"            ] = { name="акавирский"           , motif_id= 33 }
,   ["IMPERIAL"           ] = { name="имперский"            , motif_id= 34 }
,   ["YOKUDAN"            ] = { name="йокуданский"          , motif_id= 35 }
,   ["UNIVERSAL"          ] = { name="универсальный"        , motif_id= 36 }
,   ["REACH_WINTER"       ] = { name="зимний предельцев"    , motif_id= 37 }
,   ["TSAESCI"            ] = { name="цаэски"               , motif_id= 38 }
,   ["MINOTAUR"           ] = { name="минотаврский"         , motif_id= 39 }
,   ["EBONY"              ] = { name="эбонитовый"           , motif_id= 40 }
,   ["ABAHS_WATCH"        ] = { name="стража Причала Абы"   , motif_id= 41 }
,   ["SKINCHANGER"        ] = { name="оборотни"             , motif_id= 42 }
,   ["MORAG_TONG"         ] = { name="Мораг Тонг"           , motif_id= 43 }
,   ["RA_GADA"            ] = { name="Ра Гада"              , motif_id= 44 }
,   ["DRO_MATHRA"         ] = { name="дро-м'Атра"           , motif_id= 45 }
,   ["ASSASSINS_LEAGUE"   ] = { name="Лига убийц"           , motif_id= 46 }
,   ["OUTLAW"             ] = { name="разбойничий"          , motif_id= 47 }
,   ["REDORAN"            ] = { name="редоранский"          , motif_id= 48 }
,   ["HLAALU"             ] = { name="Хлаалу"               , motif_id= 49 }
,   ["MILITANT_ORDINATOR" ] = { name="боевые ординаторы"    , motif_id= 50 }
,   ["TELVANNI"           ] = { name="Телванни"             , motif_id= 51 }
,   ["BUOYANT_ARMIGER"    ] = { name="Вечная стража"        , motif_id= 52 }
,   ["FROSTCASTER"        ] = { name="заклинатель мороза"   , motif_id= 53 }
,   ["ASHLANDER"          ] = { name="эшлендеры"            , motif_id= 54 }
,   ["WORM_CULT"          ] = { name="культ Червя"          , motif_id= 55 }
,   ["SILKEN_RING"        ] = { name="Шелковое Кольцо"      , motif_id= 56 }
,   ["MAZZATUN"           ] = { name="Маззатун"             , motif_id= 57 }
,   ["GRIM_HARLEQUIN"     ] = { name="мрачный арлекин"      , motif_id= 58 }
,   ["HOLLOWJACK"         ] = { name="Пустоголовый Джек"    , motif_id= 59 }
,   ["REFABRICATED"       ] = { name="переработанный"       , motif_id= 60 }
,   ["BLOODFORGE"         ] = { name="Кровавая кузница"     , motif_id= 61 }
,   ["DREADHORN"          ] = { name="Грозный Рог"          , motif_id= 62 }
,   ["APOSTLE"            ] = { name="апостолы"             , motif_id= 65 }
,   ["EBONSHADOW"         ] = { name="эбонитовая тень"      , motif_id= 66 }
,   ["UNDAUNTED"          ] = { name="Неустрашимые"         , motif_id= 67 }
,   ["USE_ME"             ] = { name="[EN]USE ME"           , motif_id= 68 }
,   ["FANG_LAIR"          ] = { name="Логово Клыка"         , motif_id= 69 }
,   ["SCALECALLER"        ] = { name="Призывательница Чешуи", motif_id= 70 }
,   ["PSIJIC_ORDER"       ] = { name="орден Псиджиков"      , motif_id= 71 }
,   ["SAPIARCH"           ] = { name="сапиархи"             , motif_id= 72 }
,   ["WELKYNAR"           ] = { name="велкинары"            , motif_id= 73 }
,   ["DREMORA"            ] = { name="дремора"              , motif_id= 74 }
,   ["PYANDONEAN"         ] = { name="пиандонейский"        , motif_id= 75 }
,   ["DIVINE_PROSECUTION" ] = { name="Божественное Обвинение", motif_id= 76 }
,   ["HUNTSMAN"           ] = { name="Охотник"              , motif_id= 77 }
,   ["SILVER_DAWN"        ] = { name="Серебряный Рассвет"   , motif_id= 78 }
,   ["DEAD_WATER"         ] = { name="мертвая-вода"         , motif_id= 79 }
,   ["HONOR_GUARD"        ] = { name="почетная стража"      , motif_id= 80 }
,   ["ELDER_ARGONIAN"     ] = { name="древние аргониане"    , motif_id= 81 }
}


-- Miscellaneous conditions --------------------------------------------------

LibCraftText.DAILY.COND = {
    HINT_PR_BREWERS_COOKS_RECIPES = "Пивовары и повара могут снабдить вас рецептами"
,   DELIVER_GOODS_SUBSTRING       = "Доставить товары"      
,   DELIVER_NEAREST_QUARTERMASTER = "Доставить товары ближайшему интенданту заказов"
,   DELIVER_ALLIANCE_DEPOT        = "Deliver Goods to Alliance Supply Depot"
,   DELIVER_CONSORTIUM_TRADEPOST  = "Deliver Goods to Consortium Tradepost"
,   DELIVER_REFUGEE_RELIEF        = "Deliver Goods to Refugee Relief Site"
,   DELIVER_FIGHTERS_GUILD        = "Deliver Goods to Fighters Guild Provisioner"
}

LibCraftText.MASTER.COND = {
    TRAVEL_AD       = "Отправиться в Элден-Рут, чтобы встретиться с работодателем"-- "Travel to Elden Root to Meet Your Contact"
,   TRAVEL_DC       = "Отправиться в Вэйрест, чтобы встретиться с работодателем"-- "Travel to Wayrest to Meet Your Contact"
,   TRAVEL_EP       = "Отправиться в Морнхолд, чтобы встретиться с работодателем"-- "Travel to Mournhold to Meet Your Contact"

,   DELIVER_AL      = "Доставить варево"                            -- "Deliver the Concoction"
,   DELIVER_EN      = "Доставить глиф"                              -- "Deliver the Glyph"
,   DELIVER_PR      = "Доставить еду"                               -- "Deliver the Feast"
,   DELIVER_WEAPON  = "Доставить оружие"                            -- "Deliver the Weapon"
,   DELIVER_ARMOR   = "Доставить доспехи"                           -- "Deliver the Armor"
,   DELIVER_JW      = "Доставить ювелирное изделие"                 -- "Deliver the Jewelry"
}


-- Random Unsorted Stuff -----------------------------------------------------

LibCraftText.MASTER_LABELS = {
    ["quality"] =  "Качество"                        -- "Quality"
,   ["set"    ] =  "Комплект"                        -- "Set"
,   ["style"  ] =  "Стиль"                           -- "Style"
,   ["trait"  ] =  "Особенность"                     -- "Trait"
}

LibCraftText.QUALITY = {
    ["NORMAL"   ] = { name="Обычное"    , index=ITEM_QUALITY_NORMAL         or 1 }
,   ["FINE"     ] = { name="Хорошее"    , index=ITEM_QUALITY_FINE           or 2 }
,   ["SUPERIOR" ] = { name="Превосходное", index=ITEM_QUALITY_SUPERIOR       or 3 }
,   ["EPIC"     ] = { name="Эпическое"  , index=ITEM_QUALITY_EPIC           or 4 }
,   ["LEGENDARY"] = { name="Легендарное", index=ITEM_QUALITY_LEGENDARY      or 5 }
}


-- Quest and Dialog Text -----------------------------------------------------

LibCraftText.DAILY.QUEST_NAME = {
    [bs] = "Заказ кузнецу"                      -- "Blacksmith Writ"
,   [cl] = "Заказ портному"                     -- "Clothier Writ"
,   [en] = "Заказ зачарователю"                 -- "Enchanter Writ"
,   [al] = "Заказ алхимику"                     -- "Alchemist Writ"
,   [pr] = "Заказ снабженцу"                    -- "Provisioner Writ"
,   [ww] = "Заказ столяру"                      -- "Woodworker Writ"
,   [jw] = "Заказ ювелиру"                      -- "Jewelry Crafting Writ"
}
                        -- SURPRISE! "A Masterful Weapon" is used by both
                        -- Blacksmithing and Woodworking.
                        --
                        -- Why a list? Because BS, CL, and WW can all use
                        -- different quest titles depending on what item they
                        -- requested (armor vs. weapon, light vs. medium armor)
                        --
LibCraftText.MASTER.QUEST_NAME = {
    [bs] = { "Искусные латы"                      -- "A Masterful Plate"
           , "Искусное оружие"                  } -- "A Masterful Weapon"
,   [cl] = { "Искусные тканевые доспехи"          -- "Masterful Tailoring"
           , "Искусные кожаные доспехи"         } -- "Masterful Leatherwear"
,   [en] = { "Искусный глиф"                    } -- "A Masterful Glyph"
,   [al] = { "Искусное варево"                  } -- "A Masterful Concoction"
,   [pr] = { "Искусный пир"                     } -- "A Masterful Feast"
,   [ww] = { "Искусный щит"                       -- "A Masterful Shield"
           , "Искусное оружие"                  } -- "A Masterful Weapon"
,   [jw] = { "Искусные ювелирные изделия"       } -- "Masterful Jewelry"
}

LibCraftText.DAILY.DIALOG = {
    ["OPTION_ACCEPT"      ] = "<Взять заказ с доски.>"                  -- "<Pull a Writ from the Board.>"
,   ["OPTION_FINISH_SIGN" ] = "<Подписать декларацию.>"                 -- "<Sign the Manifest.>"
,   ["OPTION_FINISH_PLACE"] = "<Положить предметы в ящик.>"             -- "<Place the goods within the crate.>"
,   ["GOAL_SIGN"          ] = "Подписать доставочный манифест"          -- "Sign Delivery Manifest"
}

LibCraftText.MASTER.DIALOG = {
    ["OPTION_ACCEPT"      ] = { "<Принять заказ.>"                      -- "<Accept the contract.>"
                              , "<Принять заказ.>"                      -- "<Accept the contract>"  (FR French omits the period sometimes)
                              }
,   ["ROLIS_NAME"         ] = "Ролис Хлаалу"                            -- "Rolis Hlaalu"
,   ["TITLE_ROLIS"        ] = "-Ролис Хлаалу-"                          -- "-Rolis Hlaalu-"
,   ["OPTION_STORE"       ] = "Магазин (ремесленный посредник)"         -- "Store (Mastercraft Mediator)"
,   ["OPTION_FINISH_JOB"  ] = "<Закончить работу.>"                     -- "<Finish the job.>"
,   ["RESPONSE_ENDING"    ] = "<Он отмечает вашу работу и выдает оплату.>"-- "<He notes your work and tenders payment.>"
}

LibCraftText.DAILY.DIALOG.TITLE_OFFER = {
    "-Ремесленные заказы на экипировку-"          -- "-Equipment Crafting Writs-"
,   "-Ремесленные заказы на расходные материалы-" -- "-Consumables Crafting Writs-"
}

LibCraftText.MASTER.DIALOG.TITLE_OFFER = {
    [bs] = "-Запечатанный заказ кузнецу-"         -- "-Sealed Blacksmithing Writ-"
,   [cl] = "-Запечатанный заказ портному-"        -- "-Sealed Clothier Writ-"
,   [en] = "-Запечатанный заказ зачарователю-"    -- "-Sealed Enchanting Writ-"
,   [al] = "-Запечатанный заказ алхимику-"        -- "-Sealed Alchemy Writ-"
,   [pr] = "-Запечатанный заказ снабженцу-"       -- "-Sealed Provisioning Writ-"
,   [ww] = "-Запечатанный заказ столяру-"         -- "-Sealed Woodworking Writ-"
,   [jw] = "-Запечатанный заказ ювелиру-"         -- "-Sealed Jewelry Crafter Writ-"
}

LibCraftText.DAILY.DIALOG.TITLE_TURN_IN = {
    [bs] = "-Доставочный ящик кузнеца-"           -- "-Blacksmith Delivery Crate-"
,   [cl] = "-Доставочный ящик портного-"          -- "-Clothier Delivery Crate-"
,   [en] = "-Доставочный ящик зачарователя-"      -- "-Enchanter Delivery Crate-"
,   [al] = "-Доставочный ящик алхимика-"          -- "-Alchemist Delivery Crate-"
,   [pr] = "-Доставочный ящик снабженца-"         -- "-Provisioner Delivery Crate-"
,   [ww] = "-Доставочный ящик столяра-"           -- "-Woodworker Delivery Crate-"
,   [jw] = "-Доставочный ящик ювелира-"           -- "-Jewelry Crafting Delivery Crate-"
}

LibCraftText.DAILY.DIALOG.OPTION_EXAMINE = {
    [bs] = "<Изучить заказы для кузнеца.>"        -- "<Examine the Blacksmith Writs.>"
,   [cl] = "<Изучить заказы для портного.>"       -- "<Examine the Clothier Writs.>"
,   [en] = "<Изучить заказы для зачарователя.>"   -- "<Examine the Enchanter Writs.>"
,   [al] = "<Изучить заказы для алхимика.>"       -- "<Examine the Alchemist Writs.>"
,   [pr] = "<Изучить заказы для снабженца.>"      -- "<Examine the Provisioner Writs.>"
,   [ww] = "<Изучить заказы для столяра.>"        -- "<Examine the Woodworker Writs.>"
,   [jw] = "<Изучить заказы для ювелира.>"        -- "<Examine the Jewelry Crafting Writs.>"
}

LibCraftText.MASTER.DIALOG.OPTION_FINISH = {
    [bs] = "Я закончил работу кузнеца."           -- "I've finished the Blacksmithing job."
,   [cl] = "Я закончил работу портного."          -- "I've finished the Clothier job."
,   [en] = "Я закончил работу зачарователя."      -- "I've finished the Enchanting job."
,   [al] = "Я закончил работу алхимика."          -- "I've finished the Alchemy job."
,   [pr] = "Я закончил работу снабженца."         -- "I've finished the Provisioning job."
,   [ww] = "Я закончил работу столяра."           -- "I've finished the Woodworking job."
,   [jw] = "I've finished the Jewelry job."       -- "I've finished the Jewelry job."
}
