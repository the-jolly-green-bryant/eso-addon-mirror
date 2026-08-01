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
  ["H1_AXE"         ] = { name="ascia"                , master_name="Axe"                       , pattern_index= 1, master_writ1=53, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H1_MACE"        ] = { name="mazza"                , master_name="Mace"                      , pattern_index= 2, master_writ1=56, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H1_SWORD"       ] = { name="spada"                , master_name="Spada"                     , pattern_index= 3, master_writ1=59, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H2_BATTLE_AXE"  ] = { name="ascia da battaglia"   , master_name="Grande Ascia"              , pattern_index= 4, master_writ1=68, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H2_MAUL"        ] = { name="maglio"               , master_name="Maul"                      , pattern_index= 5, master_writ1=69, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H2_GREATSWORD"  ] = { name="spadone"              , master_name="Greatsword"                , pattern_index= 6, master_writ1=67, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["DAGGER"         ] = { name="pugnale"              , master_name="Dagger"                    , pattern_index= 7, master_writ1=62, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["CUIRASS"        ] = { name="corazza"              , master_name="Corazza"                   , pattern_index= 8, master_writ1=46, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["SABATONS"       ] = { name="schinieri"            , master_name="Sabatons"                  , pattern_index= 9, master_writ1=50, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["GAUNTLETS"      ] = { name="mittene"              , master_name="Gauntlets"                 , pattern_index=10, master_writ1=52, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["HELM"           ] = { name="elmo"                 , master_name="Elmo"                      , pattern_index=11, master_writ1=44, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["GREAVES"        ] = { name="gambali"              , master_name="Gambali"                   , pattern_index=12, master_writ1=49, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["PAULDRON"       ] = { name="spallaccio"           , master_name="Spallaccio"                , pattern_index=13, master_writ1=47, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["GIRDLE"         ] = { name="cinturone"            , master_name="Girdle"                    , pattern_index=14, master_writ1=48, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }

, ["ROBE"           ] = { name="veste"                , master_name="Veste"                     , pattern_index= 1, master_writ1=28, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["JERKIN"         ] = { name="giaco"                , master_name="Giaco"                     , pattern_index= 2, master_writ1=75, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["SHOES"          ] = { name="scarpe"               , master_name="Scarpe"                    , pattern_index= 3, master_writ1=32, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["GLOVES"         ] = { name="guanti"               , master_name="Guanti"                    , pattern_index= 4, master_writ1=34, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["HAT"            ] = { name="cappello"             , master_name="Cappello"                  , pattern_index= 5, master_writ1=26, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["BREECHES"       ] = { name="calzoni"              , master_name="Calzoni"                   , pattern_index= 6, master_writ1=31, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["EPAULETS"       ] = { name="coprispalle"          , master_name="Coprispalle"               , pattern_index= 7, master_writ1=29, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr , name_2="coprispalle"}
, ["SASH"           ] = { name="fascia"               , master_name="Fascia"                    , pattern_index= 8, master_writ1=30, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr , name_2="fascia"    }
, ["JACK"           ] = { name="corpetto"             , master_name="Corpetto"                  , pattern_index= 9, master_writ1=37, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["BOOTS"          ] = { name="stivali"              , master_name="Stivali"                   , pattern_index=10, master_writ1=41, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["BRACERS"        ] = { name="bracciali"            , master_name="Bracciali"                 , pattern_index=11, master_writ1=43, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr , name_2="bracciali" }
, ["HELMET"         ] = { name="elmetto"              , master_name="Elmetto"                   , pattern_index=12, master_writ1=35, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr , name_2="elmetto"   }
, ["GUARDS"         ] = { name="pantaloni"            , master_name="Pantaloni"                 , pattern_index=13, master_writ1=40, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["ARM_COPS"       ] = { name="spalline"             , master_name="Spalline"                  , pattern_index=14, master_writ1=38, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["BELT"           ] = { name="cintura"              , master_name="Cintura"                   , pattern_index=15, master_writ1=39, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }

, ["BOW"            ] = { name="arco"                 , master_name="Bow"                       , pattern_index= 1, master_writ1=70, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["INFERNO_STAFF"  ] = { name="bastone del fuoco"    , master_name="Bastone del Fuoco"         , pattern_index= 3, master_writ1=72, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["ICE_STAFF"      ] = { name="bastone del gelo"     , master_name="Frost Staff"               , pattern_index= 4, master_writ1=73, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["LIGHTNING_STAFF"] = { name="bastone del fulmine"  , master_name="Lightning Staff"           , pattern_index= 5, master_writ1=74, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["RESTO_STAFF"    ] = { name="bastone di cura"      , master_name="Healing Staff"             , pattern_index= 6, master_writ1=71, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["SHIELD"         ] = { name="scudo"                , master_name="Scudo"                     , pattern_index= 2, master_writ1=65, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_armr }

, ["NECKLACE"       ] = { name="collana"              , master_name="Necklace"                  , pattern_index= 2, master_writ1=18, crafting_type=jw, mat_set_id=mat_jewl, trait_set_id=trait_jewl , name_2="collana"   }
, ["RING"           ] = { name="anello"               , master_name="Ring"                      , pattern_index= 1, master_writ1=24, crafting_type=jw, mat_set_id=mat_jewl, trait_set_id=trait_jewl }
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
  ["AETHERIAL_TEA"                      ] = { name="Aetherial Tea"                         , food_item_id=033602, recipe_item_id=046049, recipe_list_index=  9, recipe_index= 31, name_2="Aetherial Tea"}
, ["ALIKR_BEETS_WITH_GOAT_CHEESE"       ] = { name="Alik'r Beets with Goat Cheese"         , food_item_id=028338, recipe_item_id=045899, recipe_list_index=  3, recipe_index= 13}
, ["BAKED_APPLES"                       ] = { name="Baked Apples"                          , food_item_id=033837, recipe_item_id=045889, recipe_list_index=  2, recipe_index=  1}
, ["BAKED_POTATO"                       ] = { name="Baked Potato"                          , food_item_id=028354, recipe_item_id=045912, recipe_list_index=  3, recipe_index=  2}
, ["BANANA_SURPRISE"                    ] = { name="Banana Surprise"                       , food_item_id=028281, recipe_item_id=045913, recipe_list_index=  2, recipe_index=  2}
, ["BARLEY_NECTAR"                      ] = { name="Barley Nectar"                         , food_item_id=033624, recipe_item_id=045984, recipe_list_index=  8, recipe_index= 14}
, ["BATTAGLIR_CHOWDER"                  ] = { name="Battaglir Chowder"                     , food_item_id=028394, recipe_item_id=045946, recipe_list_index=  3, recipe_index= 15}
, ["BITTERLEMON_TEA"                    ] = { name="Bitterlemon Tea"                       , food_item_id=028457, recipe_item_id=046000, recipe_list_index=  9, recipe_index= 13}
, ["BLUE_ROAD_MARATHON"                 ] = { name="Blue Road Marathon"                    , food_item_id=028513, recipe_item_id=046030, recipe_list_index= 10, recipe_index= 25}
, ["BOG_IRON_ALE"                       ] = { name="Bog-Iron Ale"                          , food_item_id=028405, recipe_item_id=045971, recipe_list_index=  8, recipe_index=  4}
, ["BRETON_PORK_SAUSAGE"                ] = { name="Breton Pork Sausage"                   , food_item_id=028342, recipe_item_id=045900, recipe_list_index=  1, recipe_index= 13}
, ["CARROT_SOUP"                        ] = { name="Carrot Soup"                           , food_item_id=028321, recipe_item_id=045887, recipe_list_index=  3, recipe_index=  1}
, ["CHICKEN_BREAST"                     ] = { name="Chicken Breast"                        , food_item_id=033819, recipe_item_id=045935, recipe_list_index=  1, recipe_index=  3}
, ["CHORROL_CORN_ON_THE_COB"            ] = { name="Chorrol Corn on the Cob"               , food_item_id=033514, recipe_item_id=045929, recipe_list_index=  3, recipe_index= 20}
, ["CINNAMON_GRAPE_JELLY"               ] = { name="Cinnamon Grape Jelly"                  , food_item_id=042790, recipe_item_id=045907, recipe_list_index=  2, recipe_index= 19}
, ["CLARIFIED_SYRAH_WINE"               ] = { name="Clarified Syrah Wine"                  , food_item_id=028409, recipe_item_id=045972, recipe_list_index=  8, recipe_index=  7, name_2="Clarified Syrah Wine"}
, ["COMELY_WENCH_WHISKEY"               ] = { name="Comely Wench Whiskey"                  , food_item_id=028402, recipe_item_id=046048, recipe_list_index=  8, recipe_index= 31}
, ["CYRODILIC_CORNBREAD"                ] = { name="Cyrodilic Cornbread"                   , food_item_id=033897, recipe_item_id=045958, recipe_list_index=  3, recipe_index= 25}
, ["CYRODILIC_PUMPKIN_FRITTERS"         ] = { name="Cyrodilic Pumpkin Fritters"            , food_item_id=033789, recipe_item_id=045931, recipe_list_index=  2, recipe_index= 20}
, ["ELENHIR_ROAST_ANTELOPE"             ] = { name="Elinhir Roast Antelope"                , food_item_id=033520, recipe_item_id=045930, recipe_list_index=  1, recipe_index= 20}
, ["ELTHERIC_HOOCH"                     ] = { name="Eltheric Hooch"                        , food_item_id=028417, recipe_item_id=045974, recipe_list_index=  8, recipe_index= 13, name_2="Eltheric Hooch"}
, ["FIRSTHOLD_FRUIT_AND_CHEESE_PLATE"   ] = { name="Firsthold Fruit and Cheese Plate"      , food_item_id=068236, recipe_item_id=068192, recipe_list_index=  2, recipe_index= 40}
, ["FISHY_STICK"                        ] = { name="Fishy Stick"                           , food_item_id=033526, recipe_item_id=045888, recipe_list_index=  1, recipe_index=  1}
, ["FOUR_EYE_GROG"                      ] = { name="Four-Eye Grog"                         , food_item_id=033612, recipe_item_id=045982, recipe_list_index=  8, recipe_index=  8}
, ["GARLIC_MASHED_POTATOES"             ] = { name="Garlic Mashed Potatoes"                , food_item_id=028346, recipe_item_id=045905, recipe_list_index=  3, recipe_index= 19}
, ["GARLIC_PUMPKIN_SEEDS"               ] = { name="Garlic Pumpkin Seeds"                  , food_item_id=033490, recipe_item_id=045925, recipe_list_index=  2, recipe_index= 14}
, ["GINGER_WHEAT_BEER"                  ] = { name="Ginger Wheat Beer"                     , food_item_id=033963, recipe_item_id=045993, recipe_list_index=  8, recipe_index= 18}
, ["GODS_BLIND_ME"                      ] = { name="Gods-Blind-Me"                         , food_item_id=028433, recipe_item_id=045978, recipe_list_index=  8, recipe_index= 25, name_2="Gods-Blind-Me"}
, ["GOLDEN_LAGER"                       ] = { name="Golden Lager"                          , food_item_id=033933, recipe_item_id=045988, recipe_list_index=  8, recipe_index=  3}
, ["GOSSAMER_MAZTE"                     ] = { name="Gossamer Mazte"                        , food_item_id=033957, recipe_item_id=045992, recipe_list_index=  8, recipe_index= 15}
, ["GRANDPAS_BEDTIME_TONIC"             ] = { name="Grandpa's Bedtime Tonic"               , food_item_id=028444, recipe_item_id=046050, recipe_list_index= 10, recipe_index= 31}
, ["GRAPE_PRESERVES"                    ] = { name="Grape Preserves"                       , food_item_id=033825, recipe_item_id=045936, recipe_list_index=  2, recipe_index=  3}
, ["HAGRAVENS_TONIC"                    ] = { name="Hagraven's Tonic"                      , food_item_id=068263, recipe_item_id=068219, recipe_list_index= 10, recipe_index= 42}
, ["HARE_IN_GARLIC_SAUCE"               ] = { name="Hare in Garlic Sauce"                  , food_item_id=033581, recipe_item_id=045953, recipe_list_index=  1, recipe_index= 21, name_2="Hare in Garlic Sauce"}
, ["HEARTY_GARLIC_CORN_CHOWDER"         ] = { name="Hearty Garlic Corn Chowder"            , food_item_id=068239, recipe_item_id=068195, recipe_list_index=  3, recipe_index= 40}
, ["HONEY_RYE"                          ] = { name="Honey Rye"                             , food_item_id=028421, recipe_item_id=045975, recipe_list_index=  8, recipe_index= 16}
, ["JERALL_VIEW_INN_CARROT_CAKE"        ] = { name="Jerall View Inn Carrot Cake"           , food_item_id=033575, recipe_item_id=045952, recipe_list_index=  3, recipe_index= 21}
, ["LEMON_FLOWER_MAZTE"                 ] = { name="Lemon Flower Mazte"                    , food_item_id=033945, recipe_item_id=045990, recipe_list_index=  8, recipe_index=  9}
, ["LILMOTH_GARLIC_HAGFISH"             ] = { name="Lilmoth Garlic Hagfish"                , food_item_id=068235, recipe_item_id=068191, recipe_list_index=  1, recipe_index= 42}
, ["LUSTY_ARGONIAN_MAID_MAZTE"          ] = { name="Lusty Argonian Maid Mazte"             , food_item_id=068276, recipe_item_id=068232, recipe_list_index= 14, recipe_index= 31, name_2="Lusty Argonian Maid Mazte"}
, ["MAMMOTH_SNOUT_PIE"                  ] = { name="Mammoth Snout Pie"                     , food_item_id=033903, recipe_item_id=045959, recipe_list_index=  1, recipe_index= 25}
, ["MAORMER_TEA"                        ] = { name="Maormer Tea"                           , food_item_id=028465, recipe_item_id=046002, recipe_list_index=  9, recipe_index= 19}
, ["MARKARTH_MEAD"                      ] = { name="Markarth Mead"                         , food_item_id=068257, recipe_item_id=068213, recipe_list_index=  8, recipe_index= 42}
, ["MAZTE"                              ] = { name="Mazte"                                 , food_item_id=033606, recipe_item_id=045981, recipe_list_index=  8, recipe_index=  5}
, ["MERMAID_WHISKEY"                    ] = { name="Mermaid Whiskey"                       , food_item_id=033630, recipe_item_id=045985, recipe_list_index=  8, recipe_index= 17}
, ["MILLET_STUFFED_PORK_LOIN"           ] = { name="Millet-Stuffed Pork Loin"              , food_item_id=043088, recipe_item_id=045965, recipe_list_index=  1, recipe_index= 31}
, ["MULLED_WINE"                        ] = { name="Mulled Wine"                           , food_item_id=033969, recipe_item_id=045994, recipe_list_index=  8, recipe_index= 21}
, ["MUTHSERAS_REMORSE"                  ] = { name="Muthsera's Remorse"                    , food_item_id=068260, recipe_item_id=068216, recipe_list_index=  9, recipe_index= 42}
, ["NEREID_WINE"                        ] = { name="Nereid Wine"                           , food_item_id=033975, recipe_item_id=045995, recipe_list_index=  8, recipe_index= 24}
, ["NIBENESE_GARLIC_CARROTS"            ] = { name="Nibenese Garlic Carrots"               , food_item_id=033478, recipe_item_id=045923, recipe_list_index=  3, recipe_index= 14}
, ["NUT_BROWN_ALE"                      ] = { name="Nut Brown Ale"                         , food_item_id=028401, recipe_item_id=045970, recipe_list_index=  8, recipe_index=  1}
, ["ORCREST_GARLIC_APPLE_JELLY"         ] = { name="Orcrest Garlic Apple Jelly"            , food_item_id=043094, recipe_item_id=045966, recipe_list_index=  2, recipe_index= 31}
, ["PELLITINE_TOMATO_RICE"              ] = { name="Pellitine Tomato Rice"                 , food_item_id=042814, recipe_item_id=045901, recipe_list_index=  2, recipe_index= 13}
, ["RED_RYE_BEER"                       ] = { name="Red Rye Beer"                          , food_item_id=033600, recipe_item_id=045980, recipe_list_index=  8, recipe_index=  2}
, ["REDORAN_PEPPERED_MELON"             ] = { name="Redoran Peppered Melon"                , food_item_id=033552, recipe_item_id=045948, recipe_list_index=  2, recipe_index= 15}
, ["ROAST_CORN"                         ] = { name="Roast Corn"                            , food_item_id=033813, recipe_item_id=045934, recipe_list_index=  3, recipe_index=  3}
, ["RYE_IN_YOUR_EYE"                    ] = { name="Rye-in-your-Eye"                       , food_item_id=028429, recipe_item_id=045977, recipe_list_index=  8, recipe_index= 22}
, ["SEAFLOWER_TEA"                      ] = { name="Seaflower Tea"                         , food_item_id=034005, recipe_item_id=046018, recipe_list_index=  9, recipe_index= 15}
, ["SENCHAL_CURRY_FISH_AND_RICE"        ] = { name="Senchal Curry Fish and Rice"           , food_item_id=028350, recipe_item_id=045906, recipe_list_index=  1, recipe_index= 19}
, ["SKYRIM_JAZBAY_CROSTATA"             ] = { name="Skyrim Jazbay Crostata"                , food_item_id=033909, recipe_item_id=045960, recipe_list_index=  2, recipe_index= 25}
, ["SORRY_HONEY_LAGER"                  ] = { name="Sorry, Honey Lager"                    , food_item_id=033642, recipe_item_id=045987, recipe_list_index=  8, recipe_index= 23}
, ["SOUR_MASH"                          ] = { name="Sour Mash"                             , food_item_id=028425, recipe_item_id=045976, recipe_list_index=  8, recipe_index= 19}
, ["SPICEBERRY_CHAI"                    ] = { name="Spiceberry Chai"                       , food_item_id=033684, recipe_item_id=046012, recipe_list_index=  9, recipe_index= 20}
, ["SPICED_MAZTE"                       ] = { name="Spiced Mazte"                          , food_item_id=033636, recipe_item_id=045986, recipe_list_index=  8, recipe_index= 20}
, ["STORMHOLD_BAKED_BANANAS"            ] = { name="Stormhold Baked Bananas"               , food_item_id=033587, recipe_item_id=045954, recipe_list_index=  2, recipe_index= 21}
, ["SURILIE_SYRAH_WINE"                 ] = { name="Surilie Syrah Wine"                    , food_item_id=033939, recipe_item_id=045989, recipe_list_index=  8, recipe_index=  6}
, ["TORVAL_MINT_TEA"                    ] = { name="Torval Mint Tea"                       , food_item_id=034017, recipe_item_id=046020, recipe_list_index=  9, recipe_index= 21}
, ["TREACLEBERRY_TEA"                   ] = { name="Treacleberry Tea"                      , food_item_id=033672, recipe_item_id=046010, recipe_list_index=  9, recipe_index= 14}
, ["TWO_ZEPHYR_TEA"                     ] = { name="Two-Zephyr Tea"                        , food_item_id=028473, recipe_item_id=046004, recipe_list_index=  9, recipe_index= 25}
, ["VENISON_PASTY"                      ] = { name="Venison Pasty"                         , food_item_id=028398, recipe_item_id=045947, recipe_list_index=  1, recipe_index= 15}
, ["WEST_WEALD_CORN_CHOWDER"            ] = { name="West Weald Corn Chowder"               , food_item_id=032160, recipe_item_id=045964, recipe_list_index=  3, recipe_index= 31}
, ["WHITERUN_CHEESE_BAKED_TROUT"        ] = { name="Whiterun Cheese-Baked Trout"           , food_item_id=033484, recipe_item_id=045924, recipe_list_index=  1, recipe_index= 14}

-- master
, ["CAPON_TOMATO_BEET_CASSEROLE"        ] = { name="Capon Tomato-Beet Casserole"           , food_item_id=068251, recipe_item_id=068207, recipe_list_index=  7, recipe_index= 28}
, ["JUGGED_RABBIT_IN_PRESERVES"         ] = { name="Jugged Rabbit in Preserves"            , food_item_id=068252, recipe_item_id=068208, recipe_list_index=  7, recipe_index= 29}
, ["LONGFIN_PASTY_WITH_MELON_SAUCE"     ] = { name="Longfin Pasty with Melon Sauce"        , food_item_id=068253, recipe_item_id=068209, recipe_list_index=  7, recipe_index= 30, name_2="Longfin Pasty with Melon Sauce"}
, ["LUSTY_ARGONIAN_MAID_MAZTE"          ] = { name="Lusty Argonian Maid Mazte"             , food_item_id=068276, recipe_item_id=068232, recipe_list_index= 14, recipe_index= 31, name_2="Lusty Argonian Maid Mazte"}
, ["ORCREST_AGONY_PALE_ALE"             ] = { name="Orcrest Agony Pale Ale"                , food_item_id=068275, recipe_item_id=068231, recipe_list_index= 14, recipe_index= 30, name_2="Orcrest Agony Pale Ale"}
, ["ORZORGAS_BLOOD_PRICE_PIE"           ] = { name="Orzorga's Blood Price Pie"             , food_item_id=071058, recipe_item_id=071062, recipe_list_index= 16, recipe_index=  3, name_2="Orzorga's Blood Price Pie"}
, ["ORZORGAS_RED_FROTHGAR"              ] = { name="Orzorga's Red Frothgar"                , food_item_id=071056, recipe_item_id=071060, recipe_list_index= 15, recipe_index= 14, name_2="Orzorga's Red Frothgar"}
, ["ORZORGAS_SMOKED_BEAR_HAUNCH"        ] = { name="Orzorga's Smoked Bear Haunch"          , food_item_id=071059, recipe_item_id=071063, recipe_list_index= 16, recipe_index=  4, name_2="Orzorga's Smoked Bear Haunch"}
, ["ORZORGAS_TRIPE_TRIFLE_POCKET"       ] = { name="Orzorga's Tripe Trifle Pocket"         , food_item_id=071057, recipe_item_id=071061, recipe_list_index= 16, recipe_index=  2, name_2="Orzorga's Tripe Trifle Pocket"}
, ["PSIJIC_AMBROSIA"                    ] = { name="Psijic Ambrosia"                       , food_item_id=064221, recipe_item_id=064223, recipe_list_index= 15, recipe_index=  1, name_2="Psijic Ambrosia"}
, ["SENCHE_TIGER_SINGLE_MALT"           ] = { name="Senche-Tiger Single Malt"              , food_item_id=068273, recipe_item_id=068229, recipe_list_index= 14, recipe_index= 28, name_2="Senche-Tiger Single Malt"}
, ["VELOTHI_VIEW_VINTAGE_MALBEC"        ] = { name="Velothi View Vintage Malbec"           , food_item_id=068274, recipe_item_id=068230, recipe_list_index= 14, recipe_index= 29, name_2="Velothi View Vintage Malbec"}
, ["WITHERED_TREE_INN_VENISON_POT_ROAST"] = { name="Withered Tree Inn Venison Pot Roast"   , food_item_id=068254, recipe_item_id=068210, recipe_list_index=  7, recipe_index= 31, name_2="Longfin Pasty with Melon Sauce"}
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
, ["EBONY"                   ] = { name="ebon"                           , crafting_type=bs, level_index= 5, material_index=23, master_writ2=164, mat_set_id=mat_hvy  , name_2="ebony"          }
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

, ["BLESSED_THISTLE"         ] = { name="blessed thistle"                , crafting_type=al, item_id= 30157 }
, ["BLUE_ENTOLOMA"           ] = { name="blue entoloma"                  , crafting_type=al, item_id= 30148 }
, ["BUGLOSS"                 ] = { name="bugloss"                        , crafting_type=al, item_id= 30160 }
, ["COLUMBINE"               ] = { name="columbine"                      , crafting_type=al, item_id= 30164 }
, ["CORN_FLOWER"             ] = { name="corn flower"                    , crafting_type=al, item_id= 30161 }
, ["DRAGONTHORN"             ] = { name="dragonthorn"                    , crafting_type=al, item_id= 30162 }
, ["EMETIC_RUSSULA"          ] = { name="emetic russula"                 , crafting_type=al, item_id= 30151 }
, ["IMP_STOOL"               ] = { name="imp stool"                      , crafting_type=al, item_id= 30156 }
, ["LADYS_SMOCK"             ] = { name="lady's smock"                   , crafting_type=al, item_id= 30158 }
, ["LUMINOUS_RUSSULA"        ] = { name="luminous russula"               , crafting_type=al, item_id= 30155 }
, ["MOUNTAIN_FLOWER"         ] = { name="mountain flower"                , crafting_type=al, item_id= 30163 }
, ["NAMIRAS_ROT"             ] = { name="namira's rot"                   , crafting_type=al, item_id= 30153 }
, ["NIRNROOT"                ] = { name="nirnroot"                       , crafting_type=al, item_id= 30165 }
, ["STINKHORN"               ] = { name="stinkhorn"                      , crafting_type=al, item_id= 30149 }
, ["VIOLET_COPRINUS"         ] = { name="violet coprinus"                , crafting_type=al, item_id= 30152 , name_2="violet coprinus"    }
, ["WATER_HYACINTH"          ] = { name="water hyacinth"                 , crafting_type=al, item_id= 30166 }
, ["WHITE_CAP"               ] = { name="white cap"                      , crafting_type=al, item_id= 30154 }
, ["WORMWOOD"                ] = { name="wormwood"                       , crafting_type=al, item_id= 30159 }
, ["BEETLE_SCUTTLE"          ] = { name="Beetle Scuttle"                 , crafting_type=al, item_id= 77583 }
, ["BUTTERFLY_WING"          ] = { name="Butterfly Wing"                 , crafting_type=al, item_id= 77585 }
, ["FLESHFLY_LARVA"          ] = { name="Fleshfly Larva"                 , crafting_type=al, item_id= 77587 }
, ["MUDCRAB_CHITIN"          ] = { name="Mudcrab Chitin"                 , crafting_type=al, item_id= 77591 }
, ["NIGHTSHADE"              ] = { name="Nightshade"                     , crafting_type=al, item_id= 77590 }
, ["SCRIB_JELLY"             ] = { name="Scrib Jelly"                    , crafting_type=al, item_id= 77589 }
, ["SPIDER_EGG"              ] = { name="Spider Egg"                     , crafting_type=al, item_id= 77584 }
, ["TORCHBUG_THORAX"         ] = { name="Torchbug Thorax"                , crafting_type=al, item_id= 77581 }
, ["CLAM_GALL"               ] = { name="Reagent"                        , crafting_type=al, item_id=139020 }
, ["POWDERED_MOTHER_OF_PEARL"] = { name="Reagent"                        , crafting_type=al, item_id=139019 }

, ["NATURAL_WATER"           ] = { name="natural water"                  , crafting_type=al, item_id=   883 , name_2="natural water"      , rank=1, potion_name="health"                  }
, ["CLEAR_WATER"             ] = { name="clear water"                    , crafting_type=al, item_id=  1187                               , rank=2, potion_name="health"                  }
, ["PRISTINE_WATER"          ] = { name="pristine water"                 , crafting_type=al, item_id=  4570 , name_2="pristine water"     , rank=3, potion_name="health"                  , potion_name2="health"                   }
, ["CLEANSED_WATER"          ] = { name="cleansed water"                 , crafting_type=al, item_id= 23265 , name_2="cleansed water"     , rank=4, potion_name="health"                  }
, ["FILTERED_WATER"          ] = { name="filtered water"                 , crafting_type=al, item_id= 23266 , name_2="filtered water"     , rank=5, potion_name="health"                  }
, ["PURIFIED_WATER"          ] = { name="purified water"                 , crafting_type=al, item_id= 23267 , name_2="purified water"     , rank=6, potion_name="health"                  }
, ["CLOUD_MIST"              ] = { name="cloud mist"                     , crafting_type=al, item_id= 23268                               , rank=7, potion_name="health"                  }
, ["STAR_DEW"                ] = { name="Star Dew"                       , crafting_type=al, item_id= 64500                               , rank=8, potion_name="health"                  }
, ["LORKHANS_TEARS"          ] = { name="Lorkhan's Tears"                , crafting_type=al, item_id= 64501                               , rank=9, potion_name="health"                  }

, ["GREASE"                  ] = { name="Grease"                         , crafting_type=al, item_id= 75357                               , rank=1, poison_name="Drain Health Poison"     }
, ["ICHOR"                   ] = { name="Ichor"                          , crafting_type=al, item_id= 75358                               , rank=2, poison_name="Drain Health Poison"     }
, ["SLIME"                   ] = { name="Slime"                          , crafting_type=al, item_id= 75359                               , rank=3, poison_name="Drain Health Poison"     }
, ["GALL"                    ] = { name="Gall"                           , crafting_type=al, item_id= 75360                               , rank=4, poison_name="Drain Health Poison"     }
, ["TEREBINTHINE"            ] = { name="Terebinthine"                   , crafting_type=al, item_id= 75361                               , rank=5, poison_name="Drain Health Poison"     }
, ["PITCH_BILE"              ] = { name="Pitch-Bile"                     , crafting_type=al, item_id= 75362                               , rank=6, poison_name="Drain Health Poison"     }
, ["TARBLACK"                ] = { name="Tarblack"                       , crafting_type=al, item_id= 75363                               , rank=7, poison_name="Drain Health Poison"     }
, ["NIGHT_OIL"               ] = { name="Night-Oil"                      , crafting_type=al, item_id= 75364                               , rank=8, poison_name="Drain Health Poison"     }
, ["ALKAHEST"                ] = { name="Alkahest"                       , crafting_type=al, item_id= 75365                               , rank=9, poison_name="Drain Health Poison"     }

, ["JORA"                    ] = { name="Jora"                           , crafting_type=en, item_id= 45855 , name_2="glifo of health"}
, ["PORADE"                  ] = { name="Porade"                         , crafting_type=en, item_id= 45856 }
, ["JERA"                    ] = { name="Jera"                           , crafting_type=en, item_id= 45857 , name_2="glifo of health"}
, ["JEJORA"                  ] = { name="Jejora"                         , crafting_type=en, item_id= 45806 }
, ["ODRA"                    ] = { name="Odra"                           , crafting_type=en, item_id= 45807 , name_2="glifo of health"}
, ["POJORA"                  ] = { name="Pojora"                         , crafting_type=en, item_id= 45808 }
, ["EDORA"                   ] = { name="Edora"                          , crafting_type=en, item_id= 45809 , name_2="glifo of health"}
, ["JAERA"                   ] = { name="Jaera"                          , crafting_type=en, item_id= 45810 }
, ["PORA"                    ] = { name="Pora"                           , crafting_type=en, item_id= 45811 , name_2="glifo of health"}
, ["DENARA"                  ] = { name="Denara"                         , crafting_type=en, item_id= 45812 }
, ["RERA"                    ] = { name="Rera"                           , crafting_type=en, item_id= 45813 , name_2="glifo of health"}
, ["DERADO"                  ] = { name="Derado"                         , crafting_type=en, item_id= 45814 , name_2="glifo of health", name_3="glifo of health"}
, ["REKURA"                  ] = { name="Rekura"                         , crafting_type=en, item_id= 45815 , name_2="glifo of health"}
, ["KURA"                    ] = { name="Kura"                           , crafting_type=en, item_id= 45816 , name_2="glifo of health"}
, ["REJERA"                  ] = { name="Rejera"                         , crafting_type=en, item_id= 64509 , name_2="glifo of health"}
, ["REPORA"                  ] = { name="Repora"                         , crafting_type=en, item_id= 68341 , name_2="glifo of health"}

, ["JODE"                    ] = { name="Jode"                           , crafting_type=en, item_id= 45817 }
, ["NOTADE"                  ] = { name="Notade"                         , crafting_type=en, item_id= 45818 }
, ["ODE"                     ] = { name="Ode"                            , crafting_type=en, item_id= 45819 }
, ["TADE"                    ] = { name="Tade"                           , crafting_type=en, item_id= 45820 }
, ["JAYDE"                   ] = { name="Jayde"                          , crafting_type=en, item_id= 45821 }
, ["EDODE"                   ] = { name="Edode"                          , crafting_type=en, item_id= 45822 }
, ["POJODE"                  ] = { name="Pojode"                         , crafting_type=en, item_id= 45823 }
, ["REKUDE"                  ] = { name="Rekude"                         , crafting_type=en, item_id= 45824 }
, ["HADE"                    ] = { name="Hade"                           , crafting_type=en, item_id= 45825 }
, ["IDODE"                   ] = { name="Idode"                          , crafting_type=en, item_id= 45826 }
, ["PODE"                    ] = { name="Pode"                           , crafting_type=en, item_id= 45827 }
, ["KEDEKO"                  ] = { name="Kedeko"                         , crafting_type=en, item_id= 45828 }
, ["REDE"                    ] = { name="Rede"                           , crafting_type=en, item_id= 45829 }
, ["KUDE"                    ] = { name="Kude"                           , crafting_type=en, item_id= 45830 }
, ["JEHADE"                  ] = { name="Jehade"                         , crafting_type=en, item_id= 64508 }
, ["ITADE"                   ] = { name="Itade"                          , crafting_type=en, item_id= 68340 }

, ["DEKEIPA"                 ] = { name="Dekeipa"                        , crafting_type=en, item_id= 45839 , add="frost"            , sub="frost resist"      }
, ["DENI"                    ] = { name="Deni"                           , crafting_type=en, item_id= 45833 , add="stamina"          , sub="absorb stamina"   , add_2="stamina"             }
, ["DENIMA"                  ] = { name="Denima"                         , crafting_type=en, item_id= 45836 , add="stamina recovery" , sub="reduce feat cost"  }
, ["DETERI"                  ] = { name="Deteri"                         , crafting_type=en, item_id= 45842 , add="hardening"        , sub="crushing"          }
, ["HAOKO"                   ] = { name="Haoko"                          , crafting_type=en, item_id= 45841 , add="foulness"         , sub="disease resist"    }
, ["HAKEIJO"                 ] = { name="Hakeijo"                        , crafting_type=en, item_id= 68342 , add="prismatic defense", sub="prismatic onslaught"}
, ["KADERI"                  ] = { name="Kaderi"                         , crafting_type=en, item_id= 45849 , add="bashing"          , sub="shielding"         }
, ["KUOKO"                   ] = { name="Kuoko"                          , crafting_type=en, item_id= 45837 , add="poison"           , sub="poison resist"     }
, ["MAKDERI"                 ] = { name="Makderi"                        , crafting_type=en, item_id= 45848 , add="increase magical harm", sub="decrease spell harm"}
, ["MAKKO"                   ] = { name="Makko"                          , crafting_type=en, item_id= 45832 , add="magicka"          , sub="absorb magicka"   , add_2="magicka"             }
, ["MAKKOMA"                 ] = { name="Makkoma"                        , crafting_type=en, item_id= 45835 , add="magicka recovery" , sub="reduce spell cost" }
, ["MEIP"                    ] = { name="Meip"                           , crafting_type=en, item_id= 45840 , add="shock"            , sub="shock resist"      }
, ["OKO"                     ] = { name="Oko"                            , crafting_type=en, item_id= 45831 , add="health"           , sub="absorb health"    , add_2="health"              }
, ["OKOMA"                   ] = { name="Okoma"                          , crafting_type=en, item_id= 45834 , add="health recovery"  , sub="decrease health"   }
, ["OKORI"                   ] = { name="Okori"                          , crafting_type=en, item_id= 45843 , add="weapon damage"    , sub="weakening"         }
, ["ORU"                     ] = { name="Oru"                            , crafting_type=en, item_id= 45846 , add="potion boost"     , sub="potion speed"      }
, ["RAKEIPA"                 ] = { name="Rakeipa"                        , crafting_type=en, item_id= 45838 , add="flame"            , sub="flame resist"      }
, ["TADERI"                  ] = { name="Taderi"                         , crafting_type=en, item_id= 45847 , add="increase physical harm", sub="decrease physical harm"}

, ["TA"                      ] = { name="Ta"                             , crafting_type=en, item_id= 45850 , name_2="Normale"  }
, ["JEJOTA"                  ] = { name="Jejota"                         , crafting_type=en, item_id= 45851 , name_2="Buono"    }
, ["DENATA"                  ] = { name="Denata"                         , crafting_type=en, item_id= 45852 , name_2="Superiore"}
, ["REKUTA"                  ] = { name="Rekuta"                         , crafting_type=en, item_id= 45853 , name_2="Epico"    }
, ["KUTA"                    ] = { name="Kuta"                           , crafting_type=en, item_id= 45854 , name_2="Leggendario"}

, ["QUARTZ"                  ] = { name="Quartz"                         ,                   item_id=  4456 }
, ["DIAMOND"                 ] = { name="Diamond"                        ,                   item_id= 23219 }
, ["SARDONYX"                ] = { name="Sardonyx"                       ,                   item_id= 30221 }
, ["ALMANDINE"               ] = { name="Almandine"                      ,                   item_id= 23221 }
, ["EMERALD"                 ] = { name="Emerald"                        ,                   item_id=  4442 }
, ["BLOODSTONE"              ] = { name="Bloodstone"                     ,                   item_id= 30219 }
, ["GARNET"                  ] = { name="Garnet"                         ,                   item_id= 23171 }
, ["SAPPHIRE"                ] = { name="Sapphire"                       ,                   item_id= 23173 }
, ["FORTIFIED_NIRNCRUX"      ] = { name="Fortified Nirncrux"             ,                   item_id= 56862 }
, ["CHYSOLITE"               ] = { name="Chysolite"                      ,                   item_id= 23203 }
, ["AMETHYST"                ] = { name="Amethyst"                       ,                   item_id= 23204 }
, ["RUBY"                    ] = { name="Ruby"                           ,                   item_id=  4486 }
, ["JADE"                    ] = { name="Jade"                           ,                   item_id=   810 }
, ["TURQUOISE"               ] = { name="Turquoise"                      ,                   item_id=   813 }
, ["CARNELIAN"               ] = { name="Carnelian"                      ,                   item_id= 23165 }
, ["FIRE_OPAL"               ] = { name="Fire Opal"                      ,                   item_id= 23149 }
, ["CITRINE"                 ] = { name="Citrine"                        ,                   item_id= 16291 }
, ["POTENT_NIRNCRUX"         ] = { name="Potent Nirncrux"                ,                   item_id= 56863 }
, ["COBALT"                  ] = { name="cobalt"                         ,                   item_id=135155 }
, ["ANTIMONY"                ] = { name="antimony"                       ,                   item_id=135156 }
, ["ZINC"                    ] = { name="zinc"                           ,                   item_id=135157 }
, ["DAWN_PRISM"              ] = { name="Dawn-Prism"                     ,                   item_id=139409 }
, ["DIBELLIUM"               ] = { name="Dibellium"                      ,                   item_id=139413 }
, ["GILDING_WAX"             ] = { name="Gilding Wax"                    ,                   item_id=139412 }
, ["AURBIC_AMBER"            ] = { name="Aurbic Amber"                   ,                   item_id=139411 }
, ["TITANIUM"                ] = { name="Titanium"                       ,                   item_id=139410 }
, ["SLAUGHTERSTONE"          ] = { name="Slaughterstone"                 ,                   item_id=139414 }

}


-- Equipment Traits ----------------------------------------------------------
--
-- For master writ quests that require Nirnhoned or whatever.
--
local ts=LibCraftText.TRAIT_SET_ID -- for less typing
local m =LibCraftText.MATERIAL
LibCraftText.TRAIT = {
    ["WEAPON_POWERED"      ] = { name="Potenziato"                  , trait_set_id=ts.WEAPON  , trait_index=1 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_POWERED          or  1 , material=m.CHYSOLITE          }
,   ["WEAPON_CHARGED"      ] = { name="Carico"                      , trait_set_id=ts.WEAPON  , trait_index=2 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_CHARGED          or  2 , material=m.AMETHYST           }
,   ["WEAPON_PRECISE"      ] = { name="Preciso"                     , trait_set_id=ts.WEAPON  , trait_index=3 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_PRECISE          or  3 , material=m.RUBY               }
,   ["WEAPON_INFUSED"      ] = { name="Infuso"                      , trait_set_id=ts.WEAPON  , trait_index=4 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_INFUSED          or  4 , material=m.JADE               }
,   ["WEAPON_DEFENDING"    ] = { name="Difensivo"                   , trait_set_id=ts.WEAPON  , trait_index=5 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_DEFENDING        or  5 , material=m.TURQUOISE          }
,   ["WEAPON_TRAINING"     ] = { name="da Allenamento"              , trait_set_id=ts.WEAPON  , trait_index=6 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_TRAINING         or  6 , material=m.CARNELIAN          }
,   ["WEAPON_SHARPENED"    ] = { name="Affilato"                    , trait_set_id=ts.WEAPON  , trait_index=7 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_SHARPENED        or  7 , material=m.FIRE_OPAL          }
,   ["WEAPON_DECISIVE"     ] = { name="Decisivo"                    , trait_set_id=ts.WEAPON  , trait_index=8 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_DECISIVE         or  8 , material=m.CITRINE            }
,   ["WEAPON_NIRNHONED"    ] = { name="Nirnhoned"                   , trait_set_id=ts.WEAPON  , trait_index=9 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_NIRNHONED        or 26 , material=m.POTENT_NIRNCRUX    }

,   ["ARMOR_STURDY"        ] = { name="Robusto"                     , trait_set_id=ts.ARMOR   , trait_index=1 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_STURDY            or 11 , material=m.QUARTZ             }
,   ["ARMOR_IMPENETRABLE"  ] = { name="Impenetrabile"               , trait_set_id=ts.ARMOR   , trait_index=2 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE      or 12 , material=m.DIAMOND            }
,   ["ARMOR_REINFORCED"    ] = { name="Rinforzato"                  , trait_set_id=ts.ARMOR   , trait_index=3 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_REINFORCED        or 13 , material=m.SARDONYX           }
,   ["ARMOR_WELL_FITTED"   ] = { name="Comodo"                      , trait_set_id=ts.ARMOR   , trait_index=4 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED       or 14 , material=m.ALMANDINE          }
,   ["ARMOR_TRAINING"      ] = { name="da Allenamento"              , trait_set_id=ts.ARMOR   , trait_index=5 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_TRAINING          or 15 , material=m.EMERALD            }
,   ["ARMOR_INFUSED"       ] = { name="Infuso"                      , trait_set_id=ts.ARMOR   , trait_index=6 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_INFUSED           or 16 , material=m.BLOODSTONE         }
,   ["ARMOR_INVIGORATING"  ] = { name="Prospero"                    , trait_set_id=ts.ARMOR   , trait_index=7 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_INVIGORATING      or 17 , material=m.GARNET             }
,   ["ARMOR_DIVINES"       ] = { name="Divino"                      , trait_set_id=ts.ARMOR   , trait_index=8 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_DIVINES           or 18 , material=m.SAPPHIRE           }
,   ["ARMOR_NIRNHONED"     ] = { name="Nirnhoned"                   , trait_set_id=ts.ARMOR   , trait_index=9 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_NIRNHONED         or 25 , material=m.FORTIFIED_NIRNCRUX }

,   ["JEWELRY_ARCANE"      ] = { name="Arcano"                      , trait_set_id=ts.JEWELRY , trait_index=1 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_ARCANE          or 22 , material=m.COBALT             }
,   ["JEWELRY_HEALTHY"     ] = { name="Salubre"                     , trait_set_id=ts.JEWELRY , trait_index=2 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_HEALTHY         or 21 , material=m.ANTIMONY           }
,   ["JEWELRY_ROBUST"      ] = { name="Robusto"                     , trait_set_id=ts.JEWELRY , trait_index=3 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_ROBUST          or 23 , material=m.ZINC               }
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
    ["RESTORE_HEALTH"         ] = { trait_index=01, name="Restore Health"           , master_potion="health"                            , master_poison="Drain Health Poison"               , daily_potion_name="health"                       , daily_poison_name="drain health"                 }
,   ["RAVAGE_HEALTH"          ] = { trait_index=02, name="Ravage Health"            , master_potion="Ravage Health"                     , master_poison="Damage Health Poison"              , daily_potion_name="ravage health"                , daily_poison_name="damage health"                , daily_poison_name2="damage health"                }
,   ["RESTORE_MAGICKA"        ] = { trait_index=03, name="Restore Magicka"          , master_potion="Magicka"                           , master_poison="Drain Magicka Poison"              , daily_potion_name="magicka"                      , daily_poison_name="drain magicka"                }
,   ["RAVAGE_MAGICKA"         ] = { trait_index=04, name="Ravage Magicka"           , master_potion="Ravage Magicka"                    , master_poison="Damage Magicka Poison"             , daily_potion_name="ravage magicka"               , daily_poison_name="damage magicka"               , daily_poison_name2="ravage magicka"                }
,   ["RESTORE_STAMINA"        ] = { trait_index=05, name="Restore Stamina"          , master_potion="stamina"                           , master_poison="Drain Stamina Poison"              , daily_potion_name="stamina"                      , daily_poison_name="drain stamina"                }
,   ["RAVAGE_STAMINA"         ] = { trait_index=06, name="Ravage Stamina"           , master_potion="Ravage Stamina"                    , master_poison="Damage Stamina Poison"             , daily_potion_name="ravage stamina"               , daily_poison_name="damage stamina"               , daily_poison_name2="damage stamina"                }
,   ["SPELL_RESISTANCE"       ] = { trait_index=07, name="Increase Spell Resist"    , master_potion="Spell Protection"                  , master_poison="Ward-Draining Poison"              }
,   ["BREACH"                 ] = { trait_index=08, name="Breach"                   , master_potion="Ravage Spell Protection"           , master_poison="Breaching Poison"                  }
,   ["INCREASE_ARMOR"         ] = { trait_index=09, name="Increase Armor"           , master_potion="Armor"                             , master_poison="Resolve-Draining Poison"           }
,   ["FRACTURE"               ] = { trait_index=10, name="Fracture"                 , master_potion="Ravage Armor"                      , master_poison="Fracturing Poison"                 }
,   ["INCREASE_SPELL_POWER"   ] = { trait_index=11, name="Increase Spell Power"     , master_potion="Spell Power"                       , master_poison="Sorcery-Draining Poison"           }
,   ["COWARDICE"              ] = { trait_index=12, name="Cowardice"                , master_potion="Cowardice"                         , master_poison="Cowardice Poison"                  }
,   ["INCREASE_WEAPON_POWER"  ] = { trait_index=13, name="Increase Weapon Power"    , master_potion="Weapon Power"                      , master_poison="Brutality-Draining Poison"         }
,   ["MAIM"                   ] = { trait_index=14, name="Maim"                     , master_potion="Maim"                              , master_poison="Maiming Poison"                    }
,   ["SPELL_CRITICAL"         ] = { trait_index=15, name="Spell Critical"           , master_potion="Spell Critical"                    , master_poison="Prophecy-Draining Poison"          }
,   ["UNCERTAINTY"            ] = { trait_index=16, name="Uncertainty"              , master_potion="Uncertainty"                       , master_poison="Uncertainty Poison"                }
,   ["WEAPON_CRITICAL"        ] = { trait_index=17, name="Weapon Critical"          , master_potion="Weapon Crit"                       , master_poison="Savagery-Draining Poison"          }
,   ["ENERVATION"             ] = { trait_index=18, name="Enervation"               , master_potion="Enervation"                        , master_poison="Enervating Poison"                 }
,   ["UNSTOPPABLE"            ] = { trait_index=19, name="Unstoppable"              , master_potion="Immovability"                      , master_poison="Escapist's Poison"                 }
,   ["ENTRAPMENT"             ] = { trait_index=20, name="Entrapment"               , master_potion="Entrapment"                        , master_poison="Entrapping Poison"                 }
,   ["DETECTION"              ] = { trait_index=21, name="Detection"                , master_potion="Detection"                         , master_poison="Stealth-Draining Poison"           }
,   ["INVISIBLE"              ] = { trait_index=22, name="Invisible"                , master_potion="Invisibility"                      , master_poison="Conspicuous Poison"                }
,   ["SPEED"                  ] = { trait_index=23, name="Speed"                    , master_potion="Speed"                             , master_poison="Speed-Draining Poison"             }
,   ["HINDRANCE"              ] = { trait_index=24, name="Hindrance"                , master_potion="Hindering"                         , master_poison="Hindering Poison"                  }
,   ["PROTECTION"             ] = { trait_index=25, name="Protection"               , master_potion="Protection"                        , master_poison="Protection-Reversing Poison"       }
,   ["VULNERABILITY"          ] = { trait_index=26, name="Vulnerability"            , master_potion="Vulnerability"                     , master_poison="Vulnerability Poison"              }
,   ["LINGERING_HEALTH"       ] = { trait_index=27, name="Lingering Health"         , master_potion="Lingering Health"                  , master_poison="Gradual Health Drain Poison"       }
,   ["GRADUAL_RAVAGE_HEALTH"  ] = { trait_index=28, name="Gradual Ravage Health"    , master_potion="Creeping Ravage Health"            , master_poison="Gradual Ravage Health Poison"      }
,   ["VITALITY"               ] = { trait_index=29, name="Vitality"                 , master_potion="Vitality"                          , master_poison="Vitality-Draining Poison"          }
,   ["DEFILE"                 ] = { trait_index=30, name="Defile"                   , master_potion="Defile"                            , master_poison="Defiling Poison"                   }
}


-- Craftable Sets ------------------------------------------------------------
--
-- set_id       writ4 field for master writs
--
LibCraftText.SET = {
    ["ADEPT_RIDER"              ] = { name="Adept Rider"                , set_id=385 }
,   ["ALESSIAS_BULWARK"         ] = { name="Alessia's Bulwark"          , set_id= 82 }
,   ["ARMOR_MASTER"             ] = { name="Armor Master"               , set_id=178 }
,   ["ARMOR_OF_THE_SEDUCER"     ] = { name="Armatura della Seduttrice"  , set_id= 43 }
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
    ["BRETON"             ] = { name="Breton"               , motif_id=  1 }
,   ["REDGUARD"           ] = { name="Redguard"             , motif_id=  2 }
,   ["ORC"                ] = { name="Orc"                  , motif_id=  3 }
,   ["DARK_ELF"           ] = { name="Dark Elf"             , motif_id=  4 }
,   ["NORD"               ] = { name="Nord"                 , motif_id=  5 }
,   ["ARGONIAN"           ] = { name="Argonian"             , motif_id=  6 }
,   ["HIGH_ELF"           ] = { name="High Elf"             , motif_id=  7 }
,   ["WOOD_ELF"           ] = { name="Wood Elf"             , motif_id=  8 }
,   ["KHAJIIT"            ] = { name="Khajiit"              , motif_id=  9 }
,   ["UNIQUE"             ] = { name="Unique"               , motif_id= 10 }
,   ["THIEVES_GUILD"      ] = { name="Thieves Guild"        , motif_id= 11 }
,   ["DARK_BROTHERHOOD"   ] = { name="Dark Brotherhood"     , motif_id= 12 }
,   ["MALACATH"           ] = { name="Malacath"             , motif_id= 13 }
,   ["DWEMER"             ] = { name="Dwemer"               , motif_id= 14 }
,   ["ANCIENT_ELF"        ] = { name="Ancient Elf"          , motif_id= 15 }
,   ["ORDER_OF_THE_HOUR"  ] = { name="Order of the Hour"    , motif_id= 16 }
,   ["BARBARIC"           ] = { name="Barbaric"             , motif_id= 17 }
,   ["BANDIT"             ] = { name="Bandit"               , motif_id= 18 }
,   ["PRIMAL"             ] = { name="Primal"               , motif_id= 19 }
,   ["DAEDRIC"            ] = { name="Daedric"              , motif_id= 20 }
,   ["TRINIMAC"           ] = { name="Trinimac"             , motif_id= 21 }
,   ["ANCIENT_ORC"        ] = { name="Ancient Orc"          , motif_id= 22 }
,   ["DAGGERFALL_COVENANT"] = { name="Daggerfall Covenant"  , motif_id= 23 }
,   ["EBONHEART_PACT"     ] = { name="Ebonheart Pact"       , motif_id= 24 }
,   ["ALDMERI_DOMINION"   ] = { name="Aldmeri Dominion"     , motif_id= 25 }
,   ["MERCENARY"          ] = { name="Mercenary"            , motif_id= 26 }
,   ["CELESTIAL"          ] = { name="Celestial"            , motif_id= 27 }
,   ["GLASS"              ] = { name="Glass"                , motif_id= 28 }
,   ["XIVKYN"             ] = { name="Xivkyn"               , motif_id= 29 }
,   ["SOUL_SHRIVEN"       ] = { name="Soul Shriven"         , motif_id= 30 }
,   ["DRAUGR"             ] = { name="Draugr"               , motif_id= 31 }
,   ["MAORMER"            ] = { name="Maormer"              , motif_id= 32 }
,   ["AKAVIRI"            ] = { name="Akaviri"              , motif_id= 33 }
,   ["IMPERIAL"           ] = { name="Imperial"             , motif_id= 34 }
,   ["YOKUDAN"            ] = { name="Yokudan"              , motif_id= 35 }
,   ["UNIVERSAL"          ] = { name="Universal"            , motif_id= 36 }
,   ["REACH_WINTER"       ] = { name="Reach Winter"         , motif_id= 37 }
,   ["TSAESCI"            ] = { name="Tsaesci"              , motif_id= 38 }
,   ["MINOTAUR"           ] = { name="Minotaur"             , motif_id= 39 }
,   ["EBONY"              ] = { name="Ebony"                , motif_id= 40 }
,   ["ABAHS_WATCH"        ] = { name="Abah's Watch"         , motif_id= 41 }
,   ["SKINCHANGER"        ] = { name="Skinchanger"          , motif_id= 42 }
,   ["MORAG_TONG"         ] = { name="Morag Tong"           , motif_id= 43 }
,   ["RA_GADA"            ] = { name="Ra Gada"              , motif_id= 44 }
,   ["DRO_MATHRA"         ] = { name="Dro-m'Athra"          , motif_id= 45 }
,   ["ASSASSINS_LEAGUE"   ] = { name="Assassins League"     , motif_id= 46 }
,   ["OUTLAW"             ] = { name="Outlaw"               , motif_id= 47 }
,   ["REDORAN"            ] = { name="Redoran"              , motif_id= 48 }
,   ["HLAALU"             ] = { name="Hlaalu"               , motif_id= 49 }
,   ["MILITANT_ORDINATOR" ] = { name="Militant Ordinator"   , motif_id= 50 }
,   ["TELVANNI"           ] = { name="Telvanni"             , motif_id= 51 }
,   ["BUOYANT_ARMIGER"    ] = { name="Buoyant Armiger"      , motif_id= 52 }
,   ["FROSTCASTER"        ] = { name="Frostcaster"          , motif_id= 53 }
,   ["ASHLANDER"          ] = { name="Ashlander"            , motif_id= 54 }
,   ["WORM_CULT"          ] = { name="Worm Cult"            , motif_id= 55 }
,   ["SILKEN_RING"        ] = { name="Silken Ring"          , motif_id= 56 }
,   ["MAZZATUN"           ] = { name="Mazzatun"             , motif_id= 57 }
,   ["GRIM_HARLEQUIN"     ] = { name="Grim Harlequin"       , motif_id= 58 }
,   ["HOLLOWJACK"         ] = { name="Hollowjack"           , motif_id= 59 }
,   ["REFABRICATED"       ] = { name="Refabricated"         , motif_id= 60 }
,   ["BLOODFORGE"         ] = { name="Bloodforge"           , motif_id= 61 }
,   ["DREADHORN"          ] = { name="Dreadhorn"            , motif_id= 62 }
,   ["APOSTLE"            ] = { name="Apostle"              , motif_id= 65 }
,   ["EBONSHADOW"         ] = { name="Ebonshadow"           , motif_id= 66 }
,   ["UNDAUNTED"          ] = { name="Undaunted"            , motif_id= 67 }
,   ["USE_ME"             ] = { name="USE ME"               , motif_id= 68 }
,   ["FANG_LAIR"          ] = { name="Fang Lair"            , motif_id= 69 }
,   ["SCALECALLER"        ] = { name="Scalecaller"          , motif_id= 70 }
,   ["PSIJIC_ORDER"       ] = { name="Psijic Order"         , motif_id= 71 }
,   ["SAPIARCH"           ] = { name="Sapiarch"             , motif_id= 72 }
,   ["WELKYNAR"           ] = { name="Welkynar"             , motif_id= 73 }
,   ["DREMORA"            ] = { name="Dremora"              , motif_id= 74 }
,   ["PYANDONEAN"         ] = { name="Pyandonean"           , motif_id= 75 }
,   ["DIVINE_PROSECUTION" ] = { name="Divine Prosecution"   , motif_id= 76 }
,   ["HUNTSMAN"           ] = { name="Huntsman"             , motif_id= 77 }
,   ["SILVER_DAWN"        ] = { name="Silver Dawn"          , motif_id= 78 }
,   ["DEAD_WATER"         ] = { name="Dead-Water"           , motif_id= 79 }
,   ["HONOR_GUARD"        ] = { name="Honor Guard"          , motif_id= 80 }
,   ["ELDER_ARGONIAN"     ] = { name="Elder Argonian"       , motif_id= 81 }
}


-- Miscellaneous conditions --------------------------------------------------

LibCraftText.DAILY.COND = {
    HINT_PR_BREWERS_COOKS_RECIPES = "TRACKER GOAL TEXT"           
,   DELIVER_GOODS_SUBSTRING       = "TRACKER GOAL TEXT"     
,   DELIVER_NEAREST_QUARTERMASTER = "TRACKER GOAL TEXT"           
,   DELIVER_ALLIANCE_DEPOT        = "Deliver Goods to Alliance Supply Depot"
,   DELIVER_CONSORTIUM_TRADEPOST  = "Deliver Goods to Consortium Tradepost"
,   DELIVER_REFUGEE_RELIEF        = "Deliver Goods to Refugee Relief Site"
,   DELIVER_FIGHTERS_GUILD        = "Deliver Goods to Fighters Guild Provisioner"
}

LibCraftText.MASTER.COND = {
    TRAVEL_AD       = "Travel to Elden Root to Meet your Contact"   -- "Travel to Elden Root to Meet Your Contact"
,   TRAVEL_DC       = "Travel to Wayrest to Meet your Contact"      -- "Travel to Wayrest to Meet Your Contact"
,   TRAVEL_EP       = "Travel to Mournhold to Meet your Contact"    -- "Travel to Mournhold to Meet Your Contact"

,   DELIVER_AL      = "Deliver the Concoction"                      -- "Deliver the Concoction"
,   DELIVER_EN      = "Deliver the Glyph"                           -- "Deliver the Glyph"
,   DELIVER_PR      = "Deliver the Feast"                           -- "Deliver the Feast"
,   DELIVER_WEAPON  = "Deliver the Weapon"                          -- "Deliver the Weapon"
,   DELIVER_ARMOR   = "Deliver the Armor"                           -- "Deliver the Armor"
,   DELIVER_JW      = "Deliver the Jewelry"                         -- "Deliver the Jewelry"
}


-- Random Unsorted Stuff -----------------------------------------------------

LibCraftText.MASTER_LABELS = {
    ["quality"] =  "Qualità"                         -- "Quality"
,   ["set"    ] =  "Set"                             -- "Set"
,   ["style"  ] =  "Stile"                           -- "Style"
,   ["trait"  ] =  "Tratti"                          -- "Trait"
}

LibCraftText.QUALITY = {
    ["NORMAL"   ] = { name="Normale"    , index=ITEM_QUALITY_NORMAL         or 1 }
,   ["FINE"     ] = { name="Buono"      , index=ITEM_QUALITY_FINE           or 2 }
,   ["SUPERIOR" ] = { name="Superiore"  , index=ITEM_QUALITY_SUPERIOR       or 3 }
,   ["EPIC"     ] = { name="Epico"      , index=ITEM_QUALITY_EPIC           or 4 }
,   ["LEGENDARY"] = { name="Leggendario", index=ITEM_QUALITY_LEGENDARY      or 5 }
}


-- Quest and Dialog Text -----------------------------------------------------

LibCraftText.DAILY.QUEST_NAME = {
    [bs] = "Blacksmith Writ"                    -- "Blacksmith Writ"
,   [cl] = "Clothier Writ"                      -- "Clothier Writ"
,   [en] = "Enchanter Writ"                     -- "Enchanter Writ"
,   [al] = "Alchemist Writ"                     -- "Alchemist Writ"
,   [pr] = "Provisioner Writ"                   -- "Provisioner Writ"
,   [ww] = "Woodworker Writ"                    -- "Woodworker Writ"
,   [jw] = "Jewelry Crafting Writ"              -- "Jewelry Crafting Writ"
}
                        -- SURPRISE! "A Masterful Weapon" is used by both
                        -- Blacksmithing and Woodworking.
                        --
                        -- Why a list? Because BS, CL, and WW can all use
                        -- different quest titles depending on what item they
                        -- requested (armor vs. weapon, light vs. medium armor)
                        --
LibCraftText.MASTER.QUEST_NAME = {
    [bs] = { "A Masterful Plate"                  -- "A Masterful Plate"
           , "A Masterful Weapon"               } -- "A Masterful Weapon"
,   [cl] = { "Masterful Tailoring"                -- "Masterful Tailoring"
           , "Masterful Leatherwear"            } -- "Masterful Leatherwear"
,   [en] = { "A Masterful Glyph"                } -- "A Masterful Glyph"
,   [al] = { "A Masterful Concoction"           } -- "A Masterful Concoction"
,   [pr] = { "A Masterful Feast"                } -- "A Masterful Feast"
,   [ww] = { "A Masterful Shield"                 -- "A Masterful Shield"
           , "A Masterful Weapon"               } -- "A Masterful Weapon"
,   [jw] = { "Masterful Jewelry"                } -- "Masterful Jewelry"
}

LibCraftText.DAILY.DIALOG = {
    ["OPTION_ACCEPT"      ] = "<Pull a Writ from the Board.>"           -- "<Pull a Writ from the Board.>"
,   ["OPTION_FINISH_SIGN" ] = "<Sign the Manifest.>"                    -- "<Sign the Manifest.>"
,   ["OPTION_FINISH_PLACE"] = "<Place the goods within the crate.>"     -- "<Place the goods within the crate.>"
,   ["GOAL_SIGN"          ] = "Sign Delivery Manifest"                  -- "Sign Delivery Manifest"
}

LibCraftText.MASTER.DIALOG = {
    ["OPTION_ACCEPT"      ] = { "<Accept the contract.>"                -- "<Accept the contract.>"
                              , "<Accept the contract.>"                -- "<Accept the contract>"  (FR French omits the period sometimes)
                              }
,   ["ROLIS_NAME"         ] = "Rolis Hlaalu"                            -- "Rolis Hlaalu"
,   ["TITLE_ROLIS"        ] = "-Rolis Hlaalu-"                          -- "-Rolis Hlaalu-"
,   ["OPTION_STORE"       ] = "Negozio (Mastercraft Mediator)"          -- "Store (Mastercraft Mediator)"
,   ["OPTION_FINISH_JOB"  ] = "<Finish the job.>"                       -- "<Finish the job.>"
,   ["RESPONSE_ENDING"    ] = "<He notes your work and tenders payment.>"-- "<He notes your work and tenders payment.>"
}

LibCraftText.DAILY.DIALOG.TITLE_OFFER = {
    "-Equipment Crafting Writs-"                  -- "-Equipment Crafting Writs-"
,   "-Consumables Crafting Writs-"                -- "-Consumables Crafting Writs-"
}

LibCraftText.MASTER.DIALOG.TITLE_OFFER = {
    [bs] = "-Sealed Blacksmithing Writ-"          -- "-Sealed Blacksmithing Writ-"
,   [cl] = "-Sealed Clothier Writ-"               -- "-Sealed Clothier Writ-"
,   [en] = "-Sealed Enchanting Writ-"             -- "-Sealed Enchanting Writ-"
,   [al] = "-Sealed Alchemy Writ-"                -- "-Sealed Alchemy Writ-"
,   [pr] = "-Sealed Provisioning Writ-"           -- "-Sealed Provisioning Writ-"
,   [ww] = "-Sealed Woodworking Writ-"            -- "-Sealed Woodworking Writ-"
,   [jw] = "-Sealed Jewelry Crafter Writ-"        -- "-Sealed Jewelry Crafter Writ-"
}

LibCraftText.DAILY.DIALOG.TITLE_TURN_IN = {
    [bs] = "-Blacksmith Delivery Crate-"          -- "-Blacksmith Delivery Crate-"
,   [cl] = "-Clothier Delivery Crate-"            -- "-Clothier Delivery Crate-"
,   [en] = "-Enchanter Delivery Crate-"           -- "-Enchanter Delivery Crate-"
,   [al] = "-Alchemist Delivery Crate-"           -- "-Alchemist Delivery Crate-"
,   [pr] = "-Provisioner Delivery Crate-"         -- "-Provisioner Delivery Crate-"
,   [ww] = "-Woodworker Delivery Crate-"          -- "-Woodworker Delivery Crate-"
,   [jw] = "-Jewelry Crafting Delivery Crate-"    -- "-Jewelry Crafting Delivery Crate-"
}

LibCraftText.DAILY.DIALOG.OPTION_EXAMINE = {
    [bs] = "<Examine the Blacksmith Writs.>"      -- "<Examine the Blacksmith Writs.>"
,   [cl] = "<Examine the Clothier Writs.>"        -- "<Examine the Clothier Writs.>"
,   [en] = "<Examine the Enchanter Writs.>"       -- "<Examine the Enchanter Writs.>"
,   [al] = "<Examine the Alchemist Writs.>"       -- "<Examine the Alchemist Writs.>"
,   [pr] = "<Examine the Provisioner Writs.>"     -- "<Examine the Provisioner Writs.>"
,   [ww] = "<Examine the Woodworker Writs.>"      -- "<Examine the Woodworker Writs.>"
,   [jw] = "<Examine the Jewelry Crafting Writs.>"-- "<Examine the Jewelry Crafting Writs.>"
}

LibCraftText.MASTER.DIALOG.OPTION_FINISH = {
    [bs] = "I've finished the Blacksmithing job." -- "I've finished the Blacksmithing job."
,   [cl] = "I've finished the Clothier job."      -- "I've finished the Clothier job."
,   [en] = "I've finished the Enchanting job."    -- "I've finished the Enchanting job."
,   [al] = "I've finished the Alchemy job."       -- "I've finished the Alchemy job."
,   [pr] = "I've finished the Provisioning job."  -- "I've finished the Provisioning job."
,   [ww] = "I've finished the Woodworking job."   -- "I've finished the Woodworking job."
,   [jw] = "I've finished the Jewelry job."       -- "I've finished the Jewelry job."
}
