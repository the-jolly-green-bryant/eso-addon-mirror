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
  ["H1_AXE"         ] = { name="axt"                  , master_name="axt"                       , pattern_index= 1, master_writ1=53, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H1_MACE"        ] = { name="keule"                , master_name="keule"                     , pattern_index= 2, master_writ1=56, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H1_SWORD"       ] = { name="schwert"              , master_name="schwert"                   , pattern_index= 3, master_writ1=59, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H2_BATTLE_AXE"  ] = { name="streitaxt"            , master_name="streitaxt"                 , pattern_index= 4, master_writ1=68, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H2_MAUL"        ] = { name="streitkolben"         , master_name="streitkolben"              , pattern_index= 5, master_writ1=69, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H2_GREATSWORD"  ] = { name="bidenhänder"          , master_name="bidenhänder"               , pattern_index= 6, master_writ1=67, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["DAGGER"         ] = { name="dolch"                , master_name="dolch"                     , pattern_index= 7, master_writ1=62, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["CUIRASS"        ] = { name="kürass"               , master_name="kürass"                    , pattern_index= 8, master_writ1=46, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["SABATONS"       ] = { name="panzerschuhe"         , master_name="panzerschuhe"              , pattern_index= 9, master_writ1=50, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["GAUNTLETS"      ] = { name="hentzen"              , master_name="hentzen"                   , pattern_index=10, master_writ1=52, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["HELM"           ] = { name="haube"                , master_name="haube"                     , pattern_index=11, master_writ1=44, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["GREAVES"        ] = { name="beinschienen"         , master_name="beinschienen"              , pattern_index=12, master_writ1=49, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["PAULDRON"       ] = { name="schulterschutz"       , master_name="schulterschutz"            , pattern_index=13, master_writ1=47, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["GIRDLE"         ] = { name="gürtel"               , master_name="gürtel"                    , pattern_index=14, master_writ1=48, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }

, ["ROBE"           ] = { name="robe"                 , master_name="robe"                      , pattern_index= 1, master_writ1=28, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["JERKIN"         ] = { name="jacke"                , master_name="jacke"                     , pattern_index= 2, master_writ1=75, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["SHOES"          ] = { name="schuhe"               , master_name="schuhe"                    , pattern_index= 3, master_writ1=32, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["GLOVES"         ] = { name="handschuhe"           , master_name="handschuhe"                , pattern_index= 4, master_writ1=34, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["HAT"            ] = { name="hut"                  , master_name="hut"                       , pattern_index= 5, master_writ1=26, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["BREECHES"       ] = { name="beinkleider"          , master_name="beinkleider"               , pattern_index= 6, master_writ1=31, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["EPAULETS"       ] = { name="schulterpolster"      , master_name="schulterpolster"           , pattern_index= 7, master_writ1=29, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr , name_2="schulterpolster"}
, ["SASH"           ] = { name="schärpe"              , master_name="schärpe"                   , pattern_index= 8, master_writ1=30, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr , name_2="schärpe"   }
, ["JACK"           ] = { name="wams"                 , master_name="wams"                      , pattern_index= 9, master_writ1=37, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["BOOTS"          ] = { name="stiefel"              , master_name="stiefel"                   , pattern_index=10, master_writ1=41, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["BRACERS"        ] = { name="armschienen"          , master_name="armschienen"               , pattern_index=11, master_writ1=43, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr , name_2="armschienen"}
, ["HELMET"         ] = { name="helm"                 , master_name="helm"                      , pattern_index=12, master_writ1=35, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr , name_2="helm"      }
, ["GUARDS"         ] = { name="schoner"              , master_name="schoner"                   , pattern_index=13, master_writ1=40, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["ARM_COPS"       ] = { name="schulterkappen"       , master_name="schulterkappen"            , pattern_index=14, master_writ1=38, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["BELT"           ] = { name="riemen"               , master_name="riemen"                    , pattern_index=15, master_writ1=39, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }

, ["BOW"            ] = { name="bogen"                , master_name="bogen"                     , pattern_index= 1, master_writ1=70, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["INFERNO_STAFF"  ] = { name="flammenstab"          , master_name="flammenstab"               , pattern_index= 3, master_writ1=72, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["ICE_STAFF"      ] = { name="froststab"            , master_name="froststab"                 , pattern_index= 4, master_writ1=73, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["LIGHTNING_STAFF"] = { name="blitzstab"            , master_name="blitzstab"                 , pattern_index= 5, master_writ1=74, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["RESTO_STAFF"    ] = { name="heilungsstab"         , master_name="heilungsstab"              , pattern_index= 6, master_writ1=71, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["SHIELD"         ] = { name="schild"               , master_name="schild"                    , pattern_index= 2, master_writ1=65, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_armr }

, ["NECKLACE"       ] = { name="halskette"            , master_name="kette"                     , pattern_index= 2, master_writ1=18, crafting_type=jw, mat_set_id=mat_jewl, trait_set_id=trait_jewl , name_2="halskette" }
, ["RING"           ] = { name="ring"                 , master_name="ring"                      , pattern_index= 1, master_writ1=24, crafting_type=jw, mat_set_id=mat_jewl, trait_set_id=trait_jewl }
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
  ["AETHERIAL_TEA"                      ] = { name="Ätherischer Tee"                       , food_item_id=033602, recipe_item_id=046049, recipe_list_index=  9, recipe_index= 31, name_2="Ätherischen Tee"}
, ["ALIKR_BEETS_WITH_GOAT_CHEESE"       ] = { name="Alik'r-Gemüse mit Ziegenkäse"          , food_item_id=028338, recipe_item_id=045899, recipe_list_index=  3, recipe_index= 13}
, ["BAKED_APPLES"                       ] = { name="Bratäpfel"                             , food_item_id=033837, recipe_item_id=045889, recipe_list_index=  2, recipe_index=  1}
, ["BAKED_POTATO"                       ] = { name="Ofenkartoffel"                         , food_item_id=028354, recipe_item_id=045912, recipe_list_index=  3, recipe_index=  2}
, ["BANANA_SURPRISE"                    ] = { name="Bananenüberraschung"                   , food_item_id=028281, recipe_item_id=045913, recipe_list_index=  2, recipe_index=  2}
, ["BARLEY_NECTAR"                      ] = { name="Gerstennektar"                         , food_item_id=033624, recipe_item_id=045984, recipe_list_index=  8, recipe_index= 14}
, ["BATTAGLIR_CHOWDER"                  ] = { name="Battaglirsuppe"                        , food_item_id=028394, recipe_item_id=045946, recipe_list_index=  3, recipe_index= 15}
, ["BITTERLEMON_TEA"                    ] = { name="Bitterzitrustee"                       , food_item_id=028457, recipe_item_id=046000, recipe_list_index=  9, recipe_index= 13}
, ["BLUE_ROAD_MARATHON"                 ] = { name="Blauweg-Marathon"                      , food_item_id=028513, recipe_item_id=046030, recipe_list_index= 10, recipe_index= 25}
, ["BOG_IRON_ALE"                       ] = { name="Sumpfeisen-Ale"                        , food_item_id=028405, recipe_item_id=045971, recipe_list_index=  8, recipe_index=  4}
, ["BRETON_PORK_SAUSAGE"                ] = { name="bretonische Fleischwurst"              , food_item_id=028342, recipe_item_id=045900, recipe_list_index=  1, recipe_index= 13}
, ["CARROT_SOUP"                        ] = { name="Karottensuppe"                         , food_item_id=028321, recipe_item_id=045887, recipe_list_index=  3, recipe_index=  1}
, ["CHICKEN_BREAST"                     ] = { name="Hühnerbrust"                           , food_item_id=033819, recipe_item_id=045935, recipe_list_index=  1, recipe_index=  3}
, ["CHORROL_CORN_ON_THE_COB"            ] = { name="Chorrol-Maiskolben am Stück"           , food_item_id=033514, recipe_item_id=045929, recipe_list_index=  3, recipe_index= 20}
, ["CINNAMON_GRAPE_JELLY"               ] = { name="Zimttraubengelee"                      , food_item_id=042790, recipe_item_id=045907, recipe_list_index=  2, recipe_index= 19}
, ["CLARIFIED_SYRAH_WINE"               ] = { name="klarer Syrahwein"                      , food_item_id=028409, recipe_item_id=045972, recipe_list_index=  8, recipe_index=  7, name_2="klaren Syrahwein"}
, ["COMELY_WENCH_WHISKEY"               ] = { name="Hübschmaidwhiskey"                     , food_item_id=028402, recipe_item_id=046048, recipe_list_index=  8, recipe_index= 31}
, ["CYRODILIC_CORNBREAD"                ] = { name="cyrodiilisches Maisbrot"               , food_item_id=033897, recipe_item_id=045958, recipe_list_index=  3, recipe_index= 25}
, ["CYRODILIC_PUMPKIN_FRITTERS"         ] = { name="cyrodiilisches Kürbisfrittiertes"      , food_item_id=033789, recipe_item_id=045931, recipe_list_index=  2, recipe_index= 20}
, ["ELENHIR_ROAST_ANTELOPE"             ] = { name="Elinhir-Grillantilope"                 , food_item_id=033520, recipe_item_id=045930, recipe_list_index=  1, recipe_index= 20}
, ["ELTHERIC_HOOCH"                     ] = { name="eltherischer Fusel"                    , food_item_id=028417, recipe_item_id=045974, recipe_list_index=  8, recipe_index= 13, name_2="eltherischen Fusel"}
, ["FIRSTHOLD_FRUIT_AND_CHEESE_PLATE"   ] = { name="Ersthalt-Käseplatte mit Früchten"      , food_item_id=068236, recipe_item_id=068192, recipe_list_index=  2, recipe_index= 40}
, ["FISHY_STICK"                        ] = { name="Fischstäbchen"                         , food_item_id=033526, recipe_item_id=045888, recipe_list_index=  1, recipe_index=  1}
, ["FOUR_EYE_GROG"                      ] = { name="Vieraugengrog"                         , food_item_id=033612, recipe_item_id=045982, recipe_list_index=  8, recipe_index=  8}
, ["GARLIC_MASHED_POTATOES"             ] = { name="Kartoffelpüree mit Knoblauch"          , food_item_id=028346, recipe_item_id=045905, recipe_list_index=  3, recipe_index= 19}
, ["GARLIC_PUMPKIN_SEEDS"               ] = { name="Kürbissamen mit Knoblauch"             , food_item_id=033490, recipe_item_id=045925, recipe_list_index=  2, recipe_index= 14}
, ["GINGER_WHEAT_BEER"                  ] = { name="Ingwerbier"                            , food_item_id=033963, recipe_item_id=045993, recipe_list_index=  8, recipe_index= 18}
, ["GODS_BLIND_ME"                      ] = { name="Heiliger Strohsack"                    , food_item_id=028433, recipe_item_id=045978, recipe_list_index=  8, recipe_index= 25, name_2="Heiligen Strohsack"}
, ["GOLDEN_LAGER"                       ] = { name="Goldlager"                             , food_item_id=033933, recipe_item_id=045988, recipe_list_index=  8, recipe_index=  3}
, ["GOSSAMER_MAZTE"                     ] = { name="Gespinstmazte"                         , food_item_id=033957, recipe_item_id=045992, recipe_list_index=  8, recipe_index= 15}
, ["GRANDPAS_BEDTIME_TONIC"             ] = { name="Großvaters Nachttonikum"               , food_item_id=028444, recipe_item_id=046050, recipe_list_index= 10, recipe_index= 31}
, ["GRAPE_PRESERVES"                    ] = { name="Traubeneingemachtes"                   , food_item_id=033825, recipe_item_id=045936, recipe_list_index=  2, recipe_index=  3}
, ["HAGRAVENS_TONIC"                    ] = { name="Rabenvetteltonikum"                    , food_item_id=068263, recipe_item_id=068219, recipe_list_index= 10, recipe_index= 42}
, ["HARE_IN_GARLIC_SAUCE"               ] = { name="Hase in Knoblauchsoße"                 , food_item_id=033581, recipe_item_id=045953, recipe_list_index=  1, recipe_index= 21, name_2="Hasen in Knoblauchsoße"}
, ["HEARTY_GARLIC_CORN_CHOWDER"         ] = { name="herzhafte Maissuppe mit Knoblauch"     , food_item_id=068239, recipe_item_id=068195, recipe_list_index=  3, recipe_index= 40}
, ["HONEY_RYE"                          ] = { name="Honigwhiskey"                          , food_item_id=028421, recipe_item_id=045975, recipe_list_index=  8, recipe_index= 16}
, ["JERALL_VIEW_INN_CARROT_CAKE"        ] = { name="Jerallblick-Karottenkuchen"            , food_item_id=033575, recipe_item_id=045952, recipe_list_index=  3, recipe_index= 21}
, ["LEMON_FLOWER_MAZTE"                 ] = { name="Zitrusblütenmazte"                     , food_item_id=033945, recipe_item_id=045990, recipe_list_index=  8, recipe_index=  9}
, ["LILMOTH_GARLIC_HAGFISH"             ] = { name="Lilmoth-Vettelfisch mit Knoblauch"     , food_item_id=068235, recipe_item_id=068191, recipe_list_index=  1, recipe_index= 42}
, ["LUSTY_ARGONIAN_MAID_MAZTE"          ] = { name="Mazte der munteren argonischen Maid"   , food_item_id=068276, recipe_item_id=068232, recipe_list_index= 14, recipe_index= 31, name_2="Mazte der munteren argonischen Maid"}
, ["MAMMOTH_SNOUT_PIE"                  ] = { name="Mammutrüsselpastete"                   , food_item_id=033903, recipe_item_id=045959, recipe_list_index=  1, recipe_index= 25}
, ["MAORMER_TEA"                        ] = { name="Maormertee"                            , food_item_id=028465, recipe_item_id=046002, recipe_list_index=  9, recipe_index= 19}
, ["MARKARTH_MEAD"                      ] = { name="Markarth-Met"                          , food_item_id=068257, recipe_item_id=068213, recipe_list_index=  8, recipe_index= 42}
, ["MAZTE"                              ] = { name="Mazte"                                 , food_item_id=033606, recipe_item_id=045981, recipe_list_index=  8, recipe_index=  5}
, ["MERMAID_WHISKEY"                    ] = { name="Wassernixenwhiskey"                    , food_item_id=033630, recipe_item_id=045985, recipe_list_index=  8, recipe_index= 17}
, ["MILLET_STUFFED_PORK_LOIN"           ] = { name="gefüllte Schweinelende mit Hirse"      , food_item_id=043088, recipe_item_id=045965, recipe_list_index=  1, recipe_index= 31}
, ["MULLED_WINE"                        ] = { name="Glühwein"                              , food_item_id=033969, recipe_item_id=045994, recipe_list_index=  8, recipe_index= 21}
, ["MUTHSERAS_REMORSE"                  ] = { name="Muthseras Reue"                        , food_item_id=068260, recipe_item_id=068216, recipe_list_index=  9, recipe_index= 42}
, ["NEREID_WINE"                        ] = { name="Nereïdenwein"                          , food_item_id=033975, recipe_item_id=045995, recipe_list_index=  8, recipe_index= 24}
, ["NIBENESE_GARLIC_CARROTS"            ] = { name="nibenesische Knoblauchkarotten"        , food_item_id=033478, recipe_item_id=045923, recipe_list_index=  3, recipe_index= 14}
, ["NUT_BROWN_ALE"                      ] = { name="Nussbraunale"                          , food_item_id=028401, recipe_item_id=045970, recipe_list_index=  8, recipe_index=  1}
, ["ORCREST_GARLIC_APPLE_JELLY"         ] = { name="Orkruh-Apfelgelee mit Knoblauch"       , food_item_id=043094, recipe_item_id=045966, recipe_list_index=  2, recipe_index= 31}
, ["PELLITINE_TOMATO_RICE"              ] = { name="Pellitine-Tomatenreis"                 , food_item_id=042814, recipe_item_id=045901, recipe_list_index=  2, recipe_index= 13}
, ["RED_RYE_BEER"                       ] = { name="Rotweizenbier"                         , food_item_id=033600, recipe_item_id=045980, recipe_list_index=  8, recipe_index=  2}
, ["REDORAN_PEPPERED_MELON"             ] = { name="Redoran-Pfeffermelone"                 , food_item_id=033552, recipe_item_id=045948, recipe_list_index=  2, recipe_index= 15}
, ["ROAST_CORN"                         ] = { name="Grillmais"                             , food_item_id=033813, recipe_item_id=045934, recipe_list_index=  3, recipe_index=  3}
, ["RYE_IN_YOUR_EYE"                    ] = { name="Durchschlagwhiskey"                    , food_item_id=028429, recipe_item_id=045977, recipe_list_index=  8, recipe_index= 22}
, ["SEAFLOWER_TEA"                      ] = { name="Seeblumentee"                          , food_item_id=034005, recipe_item_id=046018, recipe_list_index=  9, recipe_index= 15}
, ["SENCHAL_CURRY_FISH_AND_RICE"        ] = { name="Senchal-Curryfisch mit Reis"           , food_item_id=028350, recipe_item_id=045906, recipe_list_index=  1, recipe_index= 19}
, ["SKYRIM_JAZBAY_CROSTATA"             ] = { name="Himmelsrand-Jazbuchtcrostata"          , food_item_id=033909, recipe_item_id=045960, recipe_list_index=  2, recipe_index= 25}
, ["SORRY_HONEY_LAGER"                  ] = { name="Tutmirleidlager"                       , food_item_id=033642, recipe_item_id=045987, recipe_list_index=  8, recipe_index= 23}
, ["SOUR_MASH"                          ] = { name="Sauermaische"                          , food_item_id=028425, recipe_item_id=045976, recipe_list_index=  8, recipe_index= 19}
, ["SPICEBERRY_CHAI"                    ] = { name="Würzbeerenchai"                        , food_item_id=033684, recipe_item_id=046012, recipe_list_index=  9, recipe_index= 20}
, ["SPICED_MAZTE"                       ] = { name="Würzmazte"                             , food_item_id=033636, recipe_item_id=045986, recipe_list_index=  8, recipe_index= 20}
, ["STORMHOLD_BAKED_BANANAS"            ] = { name="Sturmfeste-Backbananen"                , food_item_id=033587, recipe_item_id=045954, recipe_list_index=  2, recipe_index= 21}
, ["SURILIE_SYRAH_WINE"                 ] = { name="Surilie-Syrahwein"                     , food_item_id=033939, recipe_item_id=045989, recipe_list_index=  8, recipe_index=  6}
, ["TORVAL_MINT_TEA"                    ] = { name="Torval-Minztee"                        , food_item_id=034017, recipe_item_id=046020, recipe_list_index=  9, recipe_index= 21}
, ["TREACLEBERRY_TEA"                   ] = { name="Sirupbeerentee"                        , food_item_id=033672, recipe_item_id=046010, recipe_list_index=  9, recipe_index= 14}
, ["TWO_ZEPHYR_TEA"                     ] = { name="Doppelsturmtee"                        , food_item_id=028473, recipe_item_id=046004, recipe_list_index=  9, recipe_index= 25}
, ["VENISON_PASTY"                      ] = { name="Wildfleischpastete"                    , food_item_id=028398, recipe_item_id=045947, recipe_list_index=  1, recipe_index= 15}
, ["WEST_WEALD_CORN_CHOWDER"            ] = { name="Westauen-Maissuppe"                    , food_item_id=032160, recipe_item_id=045964, recipe_list_index=  3, recipe_index= 31}
, ["WHITERUN_CHEESE_BAKED_TROUT"        ] = { name="Weißlauf-Käseforelle"                  , food_item_id=033484, recipe_item_id=045924, recipe_list_index=  1, recipe_index= 14}

-- master
, ["CAPON_TOMATO_BEET_CASSEROLE"        ] = { name="Kapaunauflauf mit Tomaten und Gemüse"  , food_item_id=068251, recipe_item_id=068207, recipe_list_index=  7, recipe_index= 28}
, ["JUGGED_RABBIT_IN_PRESERVES"         ] = { name="Hasenpfeffer mit Eingemachtem"         , food_item_id=068252, recipe_item_id=068208, recipe_list_index=  7, recipe_index= 29}
, ["LONGFIN_PASTY_WITH_MELON_SAUCE"     ] = { name="Langflossenpastete mit Melonensoße"    , food_item_id=068253, recipe_item_id=068209, recipe_list_index=  7, recipe_index= 30, name_2="Langflossenpastete mit Melonensoße"}
, ["LUSTY_ARGONIAN_MAID_MAZTE"          ] = { name="Mazte der munteren argonischen Maid"   , food_item_id=068276, recipe_item_id=068232, recipe_list_index= 14, recipe_index= 31, name_2="Mazte der munteren argonischen Maid"}
, ["ORCREST_AGONY_PALE_ALE"             ] = { name="Orkruh-Schmerzbleichale"               , food_item_id=068275, recipe_item_id=068231, recipe_list_index= 14, recipe_index= 30, name_2="Orkruh-Schmerzbleichale"}
, ["ORZORGAS_BLOOD_PRICE_PIE"           ] = { name="Orzorgas Blutzoll-Pastete"             , food_item_id=071058, recipe_item_id=071062, recipe_list_index= 16, recipe_index=  3, name_2="Orzorgas Blutzoll-Pastete"}
, ["ORZORGAS_RED_FROTHGAR"              ] = { name="Orzorgas rotes Frothgar"               , food_item_id=071056, recipe_item_id=071060, recipe_list_index= 15, recipe_index= 14, name_2="Orzorgas rotes Frothgar"}
, ["ORZORGAS_SMOKED_BEAR_HAUNCH"        ] = { name="Orzorgas geräucherte Bärenlende"       , food_item_id=071059, recipe_item_id=071063, recipe_list_index= 16, recipe_index=  4, name_2="Orzorgas geräucherte Bärenlende"}
, ["ORZORGAS_TRIPE_TRIFLE_POCKET"       ] = { name="Orzorgas kleines Schundtäschchen"      , food_item_id=071057, recipe_item_id=071061, recipe_list_index= 16, recipe_index=  2, name_2="Orzorgas kleines Schundtäschchen"}
, ["PSIJIC_AMBROSIA"                    ] = { name="Psijik-Ambrosia"                       , food_item_id=064221, recipe_item_id=064223, recipe_list_index= 15, recipe_index=  1, name_2="Psijik-Ambrosia"}
, ["SENCHE_TIGER_SINGLE_MALT"           ] = { name="Senchetiger-Whiskey"                   , food_item_id=068273, recipe_item_id=068229, recipe_list_index= 14, recipe_index= 28, name_2="Senchetiger-Whiskey"}
, ["VELOTHI_VIEW_VINTAGE_MALBEC"        ] = { name="Velothi-Fernmalbec"                    , food_item_id=068274, recipe_item_id=068230, recipe_list_index= 14, recipe_index= 29, name_2="Velothi-Fernmalbec"}
, ["WITHERED_TREE_INN_VENISON_POT_ROAST"] = { name="Wildtopfbraten aus dem Verdorrten Baum", food_item_id=068254, recipe_item_id=068210, recipe_list_index=  7, recipe_index= 31, name_2="Langflossenpastete mit Melonensoße"}
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
  ["IRON"                    ] = { name="Eisen"                          , crafting_type=bs, level_index= 1, material_index= 1, master_writ2=  1, mat_set_id=mat_hvy  }
, ["STEEL"                   ] = { name="Stahl"                          , crafting_type=bs, level_index= 2, material_index= 8, master_writ2=  9, mat_set_id=mat_hvy  }
, ["ORICHALC"                ] = { name="Oreichalkos"                    , crafting_type=bs, level_index= 3, material_index=13, master_writ2=156, mat_set_id=mat_hvy  }
, ["DWARVEN"                 ] = { name="Dwemer"                         , crafting_type=bs, level_index= 4, material_index=18, master_writ2=160, mat_set_id=mat_hvy  , name_2="Dwemer"         }
, ["EBONY"                   ] = { name="Ebenerz"                        , crafting_type=bs, level_index= 5, material_index=23, master_writ2=164, mat_set_id=mat_hvy  , name_2="Ebenerz"        }
, ["CALCINIUM"               ] = { name="Kalzinium"                      , crafting_type=bs, level_index= 6, material_index=26, master_writ2=168, mat_set_id=mat_hvy  }
, ["GALATITE"                ] = { name="Galatit"                        , crafting_type=bs, level_index= 7, material_index=29, master_writ2=172, mat_set_id=mat_hvy  }
, ["QUICKSILVER"             ] = { name="Flinksilber"                    , crafting_type=bs, level_index= 8, material_index=32, master_writ2=176, mat_set_id=mat_hvy  }
, ["VOIDSTEEL"               ] = { name="Leerenstahl"                    , crafting_type=bs, level_index= 9, material_index=34, master_writ2=180, mat_set_id=mat_hvy  }
, ["RUBEDITE"                ] = { name="Rubedit"                        , crafting_type=bs, level_index=10, material_index=40, master_writ2=188, mat_set_id=mat_hvy  }

, ["JUTE"                    ] = { name="Jute"                           , crafting_type=cl, level_index= 1, material_index= 1, master_writ2=  5, mat_set_id=mat_lgt  , name_2="Jute"            }
, ["LINEN"                   ] = { name="Flachs"                         , crafting_type=cl, level_index= 2, material_index= 8, master_writ2= 45, mat_set_id=mat_lgt  }
, ["COTTON"                  ] = { name="Baumwoll"                       , crafting_type=cl, level_index= 3, material_index=13, master_writ2= 47, mat_set_id=mat_lgt  }
, ["SPIDERSILK"              ] = { name="Spinnenseiden"                  , crafting_type=cl, level_index= 4, material_index=18, master_writ2= 49, mat_set_id=mat_lgt  }
, ["EBONTHREAD"              ] = { name="Ebengarn"                       , crafting_type=cl, level_index= 5, material_index=23, master_writ2= 51, mat_set_id=mat_lgt  }
, ["KRESH"                   ] = { name="Kresh"                          , crafting_type=cl, level_index= 6, material_index=26, master_writ2=125, mat_set_id=mat_lgt  }
, ["IRONTHREAD"              ] = { name="Eisenstoff"                     , crafting_type=cl, level_index= 7, material_index=29, master_writ2=126, mat_set_id=mat_lgt  , name_2="Eisenstoff"      }
, ["SILVERWEAVE"             ] = { name="Silberstoff"                    , crafting_type=cl, level_index= 8, material_index=32, master_writ2=127, mat_set_id=mat_lgt  }
, ["SHADOWSPUN"              ] = { name="Leerenstoff"                    , crafting_type=cl, level_index= 9, material_index=34, master_writ2=128, mat_set_id=mat_lgt  }
, ["ANCESTOR_SILK"           ] = { name="Ahnenseiden"                    , crafting_type=cl, level_index=10, material_index=40, master_writ2=194, mat_set_id=mat_lgt  , name_2="Ahnenseiden"     }

, ["RAWHIDE"                 ] = { name="Rohleder"                       , crafting_type=cl, level_index= 1, material_index= 1, master_writ2=148, mat_set_id=mat_med  }
, ["HIDE"                    ] = { name="Halbleder"                      , crafting_type=cl, level_index= 2, material_index= 8, master_writ2=154, mat_set_id=mat_med  }
, ["LEATHER"                 ] = { name="Leder"                          , crafting_type=cl, level_index= 3, material_index=13, master_writ2=158, mat_set_id=mat_med  }
, ["FULL_LEATHER"            ] = { name="Hartleder"                      , crafting_type=cl, level_index= 4, material_index=18, master_writ2=162, mat_set_id=mat_med  }
, ["FELL_HIDE"               ] = { name="Wildleder"                      , crafting_type=cl, level_index= 5, material_index=23, master_writ2=166, mat_set_id=mat_med  }
, ["BRIGANDINE"              ] = { name="Rauleder"                       , crafting_type=cl, level_index= 6, material_index=26, master_writ2=170, mat_set_id=mat_med  , name_2="Rauleder"        }
, ["IRONHIDE"                ] = { name="Eisenleder"                     , crafting_type=cl, level_index= 7, material_index=29, master_writ2=174, mat_set_id=mat_med  }
, ["SUPERB"                  ] = { name="prächtiges "                    , crafting_type=cl, level_index= 8, material_index=32, master_writ2=131, mat_set_id=mat_med  , name_2="Prachtleder"     }
, ["SHADOWHIDE"              ] = { name="Schattenleder"                  , crafting_type=cl, level_index= 9, material_index=34, master_writ2=132, mat_set_id=mat_med  }
, ["RUBEDO_LEATHER"          ] = { name="Rubedoleder"                    , crafting_type=cl, level_index=10, material_index=40, master_writ2=190, mat_set_id=mat_med  }

, ["MAPLE"                   ] = { name="Ahorn"                          , crafting_type=ww, level_index= 1, material_index= 1, master_writ2=  2, mat_set_id=mat_wood }
, ["OAK"                     ] = { name="Eichen"                         , crafting_type=ww, level_index= 2, material_index= 8, master_writ2= 18, mat_set_id=mat_wood }
, ["BEECH"                   ] = { name="Buchen"                         , crafting_type=ww, level_index= 3, material_index=13, master_writ2= 20, mat_set_id=mat_wood }
, ["HICKORY"                 ] = { name="Hickory"                        , crafting_type=ww, level_index= 4, material_index=18, master_writ2= 22, mat_set_id=mat_wood }
, ["YEW"                     ] = { name="Eiben"                          , crafting_type=ww, level_index= 5, material_index=23, master_writ2= 24, mat_set_id=mat_wood }
, ["BIRCH"                   ] = { name="Birken"                         , crafting_type=ww, level_index= 6, material_index=26, master_writ2=133, mat_set_id=mat_wood }
, ["ASH"                     ] = { name="Eschen"                         , crafting_type=ww, level_index= 7, material_index=29, master_writ2=134, mat_set_id=mat_wood }
, ["MAHOGANY"                ] = { name="Mahagoni"                       , crafting_type=ww, level_index= 8, material_index=32, master_writ2=135, mat_set_id=mat_wood }
, ["NIGHTWOOD"               ] = { name="Nachtholz"                      , crafting_type=ww, level_index= 9, material_index=34, master_writ2=136, mat_set_id=mat_wood }
, ["RUBY_ASH"                ] = { name="Rubineschen"                    , crafting_type=ww, level_index=10, material_index=40, master_writ2=192, mat_set_id=mat_wood }

, ["PEWTER"                  ] = { name="Zinn"                           , crafting_type=jw, level_index= 1, material_index= 1, master_writ2=  6, mat_set_id=mat_jewl }
, ["COPPER"                  ] = { name="Kupfer"                         , crafting_type=jw, level_index= 2, material_index=13, master_writ2= 56, mat_set_id=mat_jewl }
, ["SILVER"                  ] = { name="Silber"                         , crafting_type=jw, level_index= 3, material_index=26, master_writ2=137, mat_set_id=mat_jewl }
, ["ELECTRUM"                ] = { name="Elektrum"                       , crafting_type=jw, level_index= 4, material_index=33, master_writ2=139, mat_set_id=mat_jewl , name_2="Elektrum"       }
, ["PLATINUM"                ] = { name="Platin"                         , crafting_type=jw, level_index= 5, material_index=40, master_writ2=255, mat_set_id=mat_jewl }

, ["BLESSED_THISTLE"         ] = { name="Benediktenkraut"                , crafting_type=al, item_id= 30157 }
, ["BLUE_ENTOLOMA"           ] = { name="blauer Glöckling"               , crafting_type=al, item_id= 30148 }
, ["BUGLOSS"                 ] = { name="Wolfsauge"                      , crafting_type=al, item_id= 30160 }
, ["COLUMBINE"               ] = { name="Akelei"                         , crafting_type=al, item_id= 30164 }
, ["CORN_FLOWER"             ] = { name="Kornblume"                      , crafting_type=al, item_id= 30161 }
, ["DRAGONTHORN"             ] = { name="Drachendorn"                    , crafting_type=al, item_id= 30162 }
, ["EMETIC_RUSSULA"          ] = { name="Brechtäubling"                  , crafting_type=al, item_id= 30151 }
, ["IMP_STOOL"               ] = { name="Koboldschemel"                  , crafting_type=al, item_id= 30156 }
, ["LADYS_SMOCK"             ] = { name="Wiesenschaumkraut"              , crafting_type=al, item_id= 30158 }
, ["LUMINOUS_RUSSULA"        ] = { name="Leuchttäubling"                 , crafting_type=al, item_id= 30155 }
, ["MOUNTAIN_FLOWER"         ] = { name="Bergblume"                      , crafting_type=al, item_id= 30163 }
, ["NAMIRAS_ROT"             ] = { name="Namiras Fäulnis"                , crafting_type=al, item_id= 30153 }
, ["NIRNROOT"                ] = { name="Nirnwurz"                       , crafting_type=al, item_id= 30165 }
, ["STINKHORN"               ] = { name="Stinkmorchel"                   , crafting_type=al, item_id= 30149 }
, ["VIOLET_COPRINUS"         ] = { name="violetter Tintling"             , crafting_type=al, item_id= 30152 , name_2="violetten Tintling" }
, ["WATER_HYACINTH"          ] = { name="Wasserhyazinthe"                , crafting_type=al, item_id= 30166 }
, ["WHITE_CAP"               ] = { name="Weißkappe"                      , crafting_type=al, item_id= 30154 }
, ["WORMWOOD"                ] = { name="Wermut"                         , crafting_type=al, item_id= 30159 }
, ["BEETLE_SCUTTLE"          ] = { name="Käferbeine"                     , crafting_type=al, item_id= 77583 }
, ["BUTTERFLY_WING"          ] = { name="Schmetterlingsflügel"           , crafting_type=al, item_id= 77585 }
, ["FLESHFLY_LARVA"          ] = { name="Fleischfliegenlarve"            , crafting_type=al, item_id= 77587 }
, ["MUDCRAB_CHITIN"          ] = { name="Schlammkrabbenchitin"           , crafting_type=al, item_id= 77591 }
, ["NIGHTSHADE"              ] = { name="Nachtschatten"                  , crafting_type=al, item_id= 77590 }
, ["SCRIB_JELLY"             ] = { name="Skribgelee"                     , crafting_type=al, item_id= 77589 }
, ["SPIDER_EGG"              ] = { name="Spinnenei"                      , crafting_type=al, item_id= 77584 }
, ["TORCHBUG_THORAX"         ] = { name="Fackelkäferpanzer"              , crafting_type=al, item_id= 77581 }
, ["CLAM_GALL"               ] = { name="Muschelgalle"                   , crafting_type=al, item_id=139020 }
, ["POWDERED_MOTHER_OF_PEARL"] = { name="pulverisiertes Perlmutt"        , crafting_type=al, item_id=139019 }

, ["NATURAL_WATER"           ] = { name="natürliches Wasser"             , crafting_type=al, item_id=   883 , name_2="natürliches Wasser" , rank=1, potion_name="schlückchen"             }
, ["CLEAR_WATER"             ] = { name="klares Wasser"                  , crafting_type=al, item_id=  1187                               , rank=2, potion_name="tinktur"                 }
, ["PRISTINE_WATER"          ] = { name="unberührtes Wasser"             , crafting_type=al, item_id=  4570 , name_2="unberührtes Wasser" , rank=3, potion_name="schluck"                 , potion_name2="Schlücke"                 }
, ["CLEANSED_WATER"          ] = { name="gesäubertes Wasser"             , crafting_type=al, item_id= 23265 , name_2="gesäubertes Wasser" , rank=4, potion_name="trank"                   }
, ["FILTERED_WATER"          ] = { name="gefiltertes Wasser"             , crafting_type=al, item_id= 23266 , name_2="gefiltertes Wasser" , rank=5, potion_name="lösung"                  }
, ["PURIFIED_WATER"          ] = { name="gereinigtes Wasser"             , crafting_type=al, item_id= 23267 , name_2="gereinigtes Wasser" , rank=6, potion_name="elixier"                 }
, ["CLOUD_MIST"              ] = { name="Wolkennebel"                    , crafting_type=al, item_id= 23268                               , rank=7, potion_name="panazee"                 }
, ["STAR_DEW"                ] = { name="Sternentau"                     , crafting_type=al, item_id= 64500                               , rank=8, potion_name="destillat"               }
, ["LORKHANS_TEARS"          ] = { name="Lorkhans Tränen"                , crafting_type=al, item_id= 64501                               , rank=9, potion_name="essenz"                  }

, ["GREASE"                  ] = { name="Fett"                           , crafting_type=al, item_id= 75357                               , rank=1, poison_name="i"                       }
, ["ICHOR"                   ] = { name="Eiter"                          , crafting_type=al, item_id= 75358                               , rank=2, poison_name="ii"                      }
, ["SLIME"                   ] = { name="Schleim"                        , crafting_type=al, item_id= 75359                               , rank=3, poison_name="iii"                     }
, ["GALL"                    ] = { name="Galle"                          , crafting_type=al, item_id= 75360                               , rank=4, poison_name="iv"                      }
, ["TEREBINTHINE"            ] = { name="Terebinthe"                     , crafting_type=al, item_id= 75361                               , rank=5, poison_name="v"                       }
, ["PITCH_BILE"              ] = { name="Schwarzgalle"                   , crafting_type=al, item_id= 75362                               , rank=6, poison_name="vi"                      }
, ["TARBLACK"                ] = { name="Teerschwarz"                    , crafting_type=al, item_id= 75363                               , rank=7, poison_name="vii"                     }
, ["NIGHT_OIL"               ] = { name="Nachtöl"                        , crafting_type=al, item_id= 75364                               , rank=8, poison_name="viii"                    }
, ["ALKAHEST"                ] = { name="Alkahest"                       , crafting_type=al, item_id= 75365                               , rank=9, poison_name="ix"                      }

, ["JORA"                    ] = { name="Jora"                           , crafting_type=en, item_id= 45855 , name_2="unbedeutende"  }
, ["PORADE"                  ] = { name="Porade"                         , crafting_type=en, item_id= 45856 }
, ["JERA"                    ] = { name="Jera"                           , crafting_type=en, item_id= 45857 , name_2="winzige"       }
, ["JEJORA"                  ] = { name="Jejora"                         , crafting_type=en, item_id= 45806 }
, ["ODRA"                    ] = { name="Odra"                           , crafting_type=en, item_id= 45807 , name_2="niedere"       }
, ["POJORA"                  ] = { name="Pojora"                         , crafting_type=en, item_id= 45808 }
, ["EDORA"                   ] = { name="Edora"                          , crafting_type=en, item_id= 45809 , name_2="moderate"      }
, ["JAERA"                   ] = { name="Jaera"                          , crafting_type=en, item_id= 45810 }
, ["PORA"                    ] = { name="Pora"                           , crafting_type=en, item_id= 45811 , name_2="starke"        }
, ["DENARA"                  ] = { name="Denara"                         , crafting_type=en, item_id= 45812 }
, ["RERA"                    ] = { name="Rera"                           , crafting_type=en, item_id= 45813 , name_2="hervorragende" }
, ["DERADO"                  ] = { name="Derado"                         , crafting_type=en, item_id= 45814 , name_2="gewaltige"    , name_3="gewaltige"      }
, ["REKURA"                  ] = { name="Rekura"                         , crafting_type=en, item_id= 45815 , name_2="vortreffliche" }
, ["KURA"                    ] = { name="Kura"                           , crafting_type=en, item_id= 45816 , name_2="monumentale"   }
, ["REJERA"                  ] = { name="Rejera"                         , crafting_type=en, item_id= 64509 , name_2="prächtige"     }
, ["REPORA"                  ] = { name="Repora"                         , crafting_type=en, item_id= 68341 , name_2="wahrlich prächtige"}

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

, ["DEKEIPA"                 ] = { name="Dakeipa"                        , crafting_type=en, item_id= 45839 , add="frosts"           , sub="frostresistenz"    }
, ["DENI"                    ] = { name="Deni"                           , crafting_type=en, item_id= 45833 , add="ausdauer"         , sub="ausdauerabsorption", add_2="ausdauer"            }
, ["DENIMA"                  ] = { name="Denima"                         , crafting_type=en, item_id= 45836 , add="ausdauerregeneration", sub="fähigkeitenkostenminderung"}
, ["DETERI"                  ] = { name="Deteri"                         , crafting_type=en, item_id= 45842 , add="abhärtung"        , sub="zerschmetterns"    }
, ["HAOKO"                   ] = { name="Haoko"                          , crafting_type=en, item_id= 45841 , add="fäulnis"          , sub="seuchenresistenz"  }
, ["HAKEIJO"                 ] = { name="Hakeijo"                        , crafting_type=en, item_id= 68342 , add="prismatischen verteidigung", sub="prismatischen ansturms"}
, ["KADERI"                  ] = { name="Kaderi"                         , crafting_type=en, item_id= 45849 , add="einschlagens"     , sub="abschirmens"       }
, ["KUOKO"                   ] = { name="Kuoko"                          , crafting_type=en, item_id= 45837 , add="gifts"            , sub="giftresistenz"     }
, ["MAKDERI"                 ] = { name="Makderi"                        , crafting_type=en, item_id= 45848 , add="erhöhten magischen schadens", sub="verringerten magischen schadens"}
, ["MAKKO"                   ] = { name="Makko"                          , crafting_type=en, item_id= 45832 , add="magicka"          , sub="magickaabsorption", add_2="magicka"             }
, ["MAKKOMA"                 ] = { name="Makkoma"                        , crafting_type=en, item_id= 45835 , add="magickaregeneration", sub="zauberkostenminderung"}
, ["MEIP"                    ] = { name="Meip"                           , crafting_type=en, item_id= 45840 , add="schocks"          , sub="schockresistenz"   }
, ["OKO"                     ] = { name="Oko"                            , crafting_type=en, item_id= 45831 , add="lebens"           , sub="lebensabsorption" , add_2="lebens"              }
, ["OKOMA"                   ] = { name="Okoma"                          , crafting_type=en, item_id= 45834 , add="lebensregeneration", sub="lebensminderung"   }
, ["OKORI"                   ] = { name="Okori"                          , crafting_type=en, item_id= 45843 , add="waffenkraft"      , sub="schwächung"        }
, ["ORU"                     ] = { name="Oru"                            , crafting_type=en, item_id= 45846 , add="trankverbesserung", sub="tranktempos"       }
, ["RAKEIPA"                 ] = { name="Rakeipa"                        , crafting_type=en, item_id= 45838 , add="flamme"           , sub="flammenresistenz"  }
, ["TADERI"                  ] = { name="Taderi"                         , crafting_type=en, item_id= 45847 , add="erhöhten physischen schadens", sub="verringerten physischen schadens"}

, ["TA"                      ] = { name="Ta"                             , crafting_type=en, item_id= 45850 , name_2="Normal"   }
, ["JEJOTA"                  ] = { name="Jejota"                         , crafting_type=en, item_id= 45851 , name_2="Erlesen"  }
, ["DENATA"                  ] = { name="Denata"                         , crafting_type=en, item_id= 45852 , name_2="Überlegen"}
, ["REKUTA"                  ] = { name="Rekuta"                         , crafting_type=en, item_id= 45853 , name_2="Episch"   }
, ["KUTA"                    ] = { name="Kuta"                           , crafting_type=en, item_id= 45854 , name_2="Legendär" }

, ["QUARTZ"                  ] = { name="Quarz"                          ,                   item_id=  4456 }
, ["DIAMOND"                 ] = { name="Diamant"                        ,                   item_id= 23219 }
, ["SARDONYX"                ] = { name="Sardonyx"                       ,                   item_id= 30221 }
, ["ALMANDINE"               ] = { name="Almandin"                       ,                   item_id= 23221 }
, ["EMERALD"                 ] = { name="Smaragd"                        ,                   item_id=  4442 }
, ["BLOODSTONE"              ] = { name="Blutstein"                      ,                   item_id= 30219 }
, ["GARNET"                  ] = { name="Granat"                         ,                   item_id= 23171 }
, ["SAPPHIRE"                ] = { name="Saphir"                         ,                   item_id= 23173 }
, ["FORTIFIED_NIRNCRUX"      ] = { name="festes Nirnkrux"                ,                   item_id= 56862 }
, ["CHYSOLITE"               ] = { name="Chrysolith"                     ,                   item_id= 23203 }
, ["AMETHYST"                ] = { name="Amethyst"                       ,                   item_id= 23204 }
, ["RUBY"                    ] = { name="Rubin"                          ,                   item_id=  4486 }
, ["JADE"                    ] = { name="Jade"                           ,                   item_id=   810 }
, ["TURQUOISE"               ] = { name="Türkis"                         ,                   item_id=   813 }
, ["CARNELIAN"               ] = { name="Karneol"                        ,                   item_id= 23165 }
, ["FIRE_OPAL"               ] = { name="Feueropal"                      ,                   item_id= 23149 }
, ["CITRINE"                 ] = { name="Zitrin"                         ,                   item_id= 16291 }
, ["POTENT_NIRNCRUX"         ] = { name="starres Nirnkrux"               ,                   item_id= 56863 }
, ["COBALT"                  ] = { name="Kobalt"                         ,                   item_id=135155 }
, ["ANTIMONY"                ] = { name="Antimon"                        ,                   item_id=135156 }
, ["ZINC"                    ] = { name="Zink"                           ,                   item_id=135157 }
, ["DAWN_PRISM"              ] = { name="Dämmerprisma"                   ,                   item_id=139409 }
, ["DIBELLIUM"               ] = { name="Dibellium"                      ,                   item_id=139413 }
, ["GILDING_WAX"             ] = { name="Goldwachs"                      ,                   item_id=139412 }
, ["AURBIC_AMBER"            ] = { name="aurbischer Bernstein"           ,                   item_id=139411 }
, ["TITANIUM"                ] = { name="Titanium"                       ,                   item_id=139410 }
, ["SLAUGHTERSTONE"          ] = { name="Schlachterstein"                ,                   item_id=139414 }

}


-- Equipment Traits ----------------------------------------------------------
--
-- For master writ quests that require Nirnhoned or whatever.
--
local ts=LibCraftText.TRAIT_SET_ID -- for less typing
local m =LibCraftText.MATERIAL
LibCraftText.TRAIT = {
    ["WEAPON_POWERED"      ] = { name="Gestärkt"                    , trait_set_id=ts.WEAPON  , trait_index=1 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_POWERED          or  1 , material=m.CHYSOLITE          }
,   ["WEAPON_CHARGED"      ] = { name="Geladen"                     , trait_set_id=ts.WEAPON  , trait_index=2 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_CHARGED          or  2 , material=m.AMETHYST           }
,   ["WEAPON_PRECISE"      ] = { name="Präzise"                     , trait_set_id=ts.WEAPON  , trait_index=3 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_PRECISE          or  3 , material=m.RUBY               }
,   ["WEAPON_INFUSED"      ] = { name="Erfüllt"                     , trait_set_id=ts.WEAPON  , trait_index=4 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_INFUSED          or  4 , material=m.JADE               }
,   ["WEAPON_DEFENDING"    ] = { name="Verteidigend"                , trait_set_id=ts.WEAPON  , trait_index=5 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_DEFENDING        or  5 , material=m.TURQUOISE          }
,   ["WEAPON_TRAINING"     ] = { name="Lehrend"                     , trait_set_id=ts.WEAPON  , trait_index=6 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_TRAINING         or  6 , material=m.CARNELIAN          }
,   ["WEAPON_SHARPENED"    ] = { name="Geschärft"                   , trait_set_id=ts.WEAPON  , trait_index=7 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_SHARPENED        or  7 , material=m.FIRE_OPAL          }
,   ["WEAPON_DECISIVE"     ] = { name="Entschlossen"                , trait_set_id=ts.WEAPON  , trait_index=8 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_DECISIVE         or  8 , material=m.CITRINE            }
,   ["WEAPON_NIRNHONED"    ] = { name="Nirngeschliffen"             , trait_set_id=ts.WEAPON  , trait_index=9 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_NIRNHONED        or 26 , material=m.POTENT_NIRNCRUX    }

,   ["ARMOR_STURDY"        ] = { name="Robust"                      , trait_set_id=ts.ARMOR   , trait_index=1 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_STURDY            or 11 , material=m.QUARTZ             }
,   ["ARMOR_IMPENETRABLE"  ] = { name="Undurchdringlich"            , trait_set_id=ts.ARMOR   , trait_index=2 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE      or 12 , material=m.DIAMOND            }
,   ["ARMOR_REINFORCED"    ] = { name="Verstärkt"                   , trait_set_id=ts.ARMOR   , trait_index=3 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_REINFORCED        or 13 , material=m.SARDONYX           }
,   ["ARMOR_WELL_FITTED"   ] = { name="Passgenau"                   , trait_set_id=ts.ARMOR   , trait_index=4 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED       or 14 , material=m.ALMANDINE          }
,   ["ARMOR_TRAINING"      ] = { name="Lehrend"                     , trait_set_id=ts.ARMOR   , trait_index=5 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_TRAINING          or 15 , material=m.EMERALD            }
,   ["ARMOR_INFUSED"       ] = { name="Erfüllt"                     , trait_set_id=ts.ARMOR   , trait_index=6 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_INFUSED           or 16 , material=m.BLOODSTONE         }
,   ["ARMOR_INVIGORATING"  ] = { name="Belebend"                    , trait_set_id=ts.ARMOR   , trait_index=7 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_INVIGORATING      or 17 , material=m.GARNET             }
,   ["ARMOR_DIVINES"       ] = { name="Göttlich"                    , trait_set_id=ts.ARMOR   , trait_index=8 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_DIVINES           or 18 , material=m.SAPPHIRE           }
,   ["ARMOR_NIRNHONED"     ] = { name="Nirngeschliffen"             , trait_set_id=ts.ARMOR   , trait_index=9 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_NIRNHONED         or 25 , material=m.FORTIFIED_NIRNCRUX }

,   ["JEWELRY_ARCANE"      ] = { name="Arkan"                       , trait_set_id=ts.JEWELRY , trait_index=1 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_ARCANE          or 22 , material=m.COBALT             }
,   ["JEWELRY_HEALTHY"     ] = { name="Kräftigend"                  , trait_set_id=ts.JEWELRY , trait_index=2 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_HEALTHY         or 21 , material=m.ANTIMONY           }
,   ["JEWELRY_ROBUST"      ] = { name="Robust"                      , trait_set_id=ts.JEWELRY , trait_index=3 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_ROBUST          or 23 , material=m.ZINC               }
,   ["JEWELRY_TRIUNE"      ] = { name="Dreifaltig"                  , trait_set_id=ts.JEWELRY , trait_index=4 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_TRIUNE          or 30 , material=m.DAWN_PRISM         }
,   ["JEWELRY_INFUSED"     ] = { name="Erfüllt"                     , trait_set_id=ts.JEWELRY , trait_index=5 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_INFUSED         or 33 , material=m.AURBIC_AMBER       }
,   ["JEWELRY_PROTECTIVE"  ] = { name="Schützend"                   , trait_set_id=ts.JEWELRY , trait_index=6 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE      or 32 , material=m.TITANIUM           }
,   ["JEWELRY_SWIFT"       ] = { name="Flink"                       , trait_set_id=ts.JEWELRY , trait_index=7 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_SWIFT           or 28 , material=m.GILDING_WAX        }
,   ["JEWELRY_HARMONY"     ] = { name="Harmonisch"                  , trait_set_id=ts.JEWELRY , trait_index=8 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_HARMONY         or 29 , material=m.DIBELLIUM          }
,   ["JEWELRY_BLOODTHIRSTY"] = { name="Blutdürstig"                 , trait_set_id=ts.JEWELRY , trait_index=9 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY    or 31 , material=m.SLAUGHTERSTONE     }

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
    ["RESTORE_HEALTH"         ] = { trait_index=01, name="Leben wiederherstellen"   , master_potion="Essenz des Lebens"                 , master_poison="Gift des Lebensentzugs IX"         , daily_potion_name="lebens"                       , daily_poison_name="lebensentzugs"                }
,   ["RAVAGE_HEALTH"          ] = { trait_index=02, name="Lebensverwüstung"         , master_potion="Essenz der Lebensverwüstung"       , master_poison="Gift der Lebensschändung IX"       , daily_potion_name="lebensverwüstung"             , daily_poison_name="lebensschändung"              , daily_poison_name2="lebensschändung"              }
,   ["RESTORE_MAGICKA"        ] = { trait_index=03, name="Magicka wiederherstellen" , master_potion="Essenz der Magicka"                , master_poison="Gift des Magickaentzugs IX"        , daily_potion_name="magicka"                      , daily_poison_name="magickaentzugs"               }
,   ["RAVAGE_MAGICKA"         ] = { trait_index=04, name="Magickaverwüstung"        , master_potion="Essenz der Magickaverwüstung"      , master_poison="Gift der Magickaschändung IX"      , daily_potion_name="magickaverwüstung"            , daily_poison_name="magickaschändung"             , daily_poison_name2="magickaverwüstung"             }
,   ["RESTORE_STAMINA"        ] = { trait_index=05, name="Ausdauer wiederherstellen", master_potion="Essenz der Ausdauer"               , master_poison="Gift des Ausdauerentzugs IX"       , daily_potion_name="ausdauer"                     , daily_poison_name="ausdauerentzugs"              }
,   ["RAVAGE_STAMINA"         ] = { trait_index=06, name="Ausdauerverwüstung"       , master_potion="Essenz der Ausdauerverwüstung"     , master_poison="Gift der Ausdauerschändung IX"     , daily_potion_name="ausdauerverwüstung"           , daily_poison_name="ausdauerschändung"            , daily_poison_name2="ausdauerschändung"             }
,   ["SPELL_RESISTANCE"       ] = { trait_index=07, name="Erhöht Magieresistenz"    , master_potion="Essenz des Zauberschutzes"         , master_poison="Gift des Schutzentzugs IX"         }
,   ["BREACH"                 ] = { trait_index=08, name="Bruch"                    , master_potion="Essenz der Zauberschutzverwüstung" , master_poison="Gift des Durchdringens IX"         }
,   ["INCREASE_ARMOR"         ] = { trait_index=09, name="Erhöht Rüstung"           , master_potion="Essenz der Rüstung"                , master_poison="Gift des Entschlossenheitsentzugs IX"}
,   ["FRACTURE"               ] = { trait_index=10, name="Fraktur"                  , master_potion="Essenz der Rüstungsverwüstung"     , master_poison="Gift des Zertrümmerns IX"          }
,   ["INCREASE_SPELL_POWER"   ] = { trait_index=11, name="Erhöht Magiekraft"        , master_potion="Essenz der Magiekraft"             , master_poison="Gift des Zaubereientzugs IX"       }
,   ["COWARDICE"              ] = { trait_index=12, name="Feigheit"                 , master_potion="Essenz der Feigheit"               , master_poison="Gift der Feigheit IX"              }
,   ["INCREASE_WEAPON_POWER"  ] = { trait_index=13, name="Erhöht Waffenkraft"       , master_potion="Essenz der Waffenkraft"            , master_poison="Gift des Brutalitätsentzugs IX"    }
,   ["MAIM"                   ] = { trait_index=14, name="Verkrüppeln"              , master_potion="Essenz des Verkrüppelns"           , master_poison="Gift der Verstümmelung IX"         }
,   ["SPELL_CRITICAL"         ] = { trait_index=15, name="Kritische Magietreffer"   , master_potion="Essenz der kritischen Magietreffer", master_poison="Gift des Prophetieentzugs IX"      }
,   ["UNCERTAINTY"            ] = { trait_index=16, name="Ungewissheit"             , master_potion="Essenz der Ungewissheit"           , master_poison="Gift der Ungewissheit IX"          }
,   ["WEAPON_CRITICAL"        ] = { trait_index=17, name="Kritische Waffentreffer"  , master_potion="Essenz der kritischen Waffentreffer", master_poison="Gift des Wildheitentzugs IX"       }
,   ["ENERVATION"             ] = { trait_index=18, name="Schwäche"                 , master_potion="Essenz der Schwäche"               , master_poison="Gift der Enervierung IX"           }
,   ["UNSTOPPABLE"            ] = { trait_index=19, name="Sicherer Stand"           , master_potion="Essenz der Unbeweglichkeit"        , master_poison="Gift des Fliehenden IX"            }
,   ["ENTRAPMENT"             ] = { trait_index=20, name="Einfangen"                , master_potion="Essenz des Einfangens"             , master_poison="Gift des Festsetzens IX"           }
,   ["DETECTION"              ] = { trait_index=21, name="Detektion"                , master_potion="Essenz der Detektion"              , master_poison="Gift des Schleichentzugs IX"       }
,   ["INVISIBLE"              ] = { trait_index=22, name="Unsichtbarkeit"           , master_potion="Essenz der Unsichtbarkeit"         , master_poison="Gift des Auffallens IX"            }
,   ["SPEED"                  ] = { trait_index=23, name="Tempo"                    , master_potion="Essenz des Tempos"                 , master_poison="Gift des Tempoentzugs IX"          }
,   ["HINDRANCE"              ] = { trait_index=24, name="Einschränken"             , master_potion="Essenz des Einschränkens"          , master_poison="Gift der Hinderung IX"             }
,   ["PROTECTION"             ] = { trait_index=25, name="Schutz"                   , master_potion="Essenz des Schutzes"               , master_poison="Gift der Schutzumkehrung IX"       }
,   ["VULNERABILITY"          ] = { trait_index=26, name="Verwundbarkeit"           , master_potion="Essenz der Verwundbarkeit"         , master_poison="Gift der Verwundbarkeit IX"        }
,   ["LINGERING_HEALTH"       ] = { trait_index=27, name="Beständige Heilung"       , master_potion="Essenz des beständigen Lebens"     , master_poison="langsam wirkendes Gift des Lebensentzugs IX"}
,   ["GRADUAL_RAVAGE_HEALTH"  ] = { trait_index=28, name="Langsame Lebensverwüstung", master_potion="Essenz der schleichenden Lebensverwüstung", master_poison="langsam wirkendes Gift der Lebensverwüstung IX"}
,   ["VITALITY"               ] = { trait_index=29, name="Vitalität"                , master_potion="Essenz der Vitalität"              , master_poison="Gift des Vitalitätsentzugs IX"     }
,   ["DEFILE"                 ] = { trait_index=30, name="Schänden"                 , master_potion="Essenz der Schändung"              , master_poison="Gift der Schändung IX"             }
}


-- Craftable Sets ------------------------------------------------------------
--
-- set_id       writ4 field for master writs
--
LibCraftText.SET = {
    ["ADEPT_RIDER"              ] = { name="versierter Reiter"          , set_id=385 }
,   ["ALESSIAS_BULWARK"         ] = { name="Alessias Bollwerk"          , set_id= 82 }
,   ["ARMOR_MASTER"             ] = { name="Rüstungsmeister"            , set_id=178 }
,   ["ARMOR_OF_THE_SEDUCER"     ] = { name="Rüstung der Verführung"     , set_id= 43 }
,   ["ASHEN_GRIP"               ] = { name="Aschengriff"                , set_id= 54 }
,   ["ASSASSINS_GUILE"          ] = { name="Assassinenlist"             , set_id=323 }
,   ["CLEVER_ALCHEMIST"         ] = { name="schlauer Alchemist"         , set_id=225 }
,   ["DAEDRIC_TRICKERY"         ] = { name="daedrische Gaunerei"        , set_id=324 }
,   ["DEATHS_WIND"              ] = { name="Todeswind"                  , set_id= 37 }
,   ["ETERNAL_HUNT"             ] = { name="ewige Jagd"                 , set_id=226 }
,   ["EYES_OF_MARA"             ] = { name="Augen von Mara"             , set_id= 87 }
,   ["FORTIFIED_BRASS"          ] = { name="Messingpanzer"              , set_id=352 }
,   ["GRAVE_STAKE_COLLECTOR"    ] = { name="Grabpflocksammler"          , set_id=408 }
,   ["HIST_BARK"                ] = { name="Histrinde"                  , set_id= 78 }
,   ["HUNDINGS_RAGE"            ] = { name="Hundings Zorn"              , set_id= 80 }
,   ["INNATE_AXIOM"             ] = { name="Kernaxiom"                  , set_id=351 }
,   ["KAGRENACS_HOPE"           ] = { name="Kagrenacs Hoffnung"         , set_id= 92 }
,   ["KVATCH_GLADIATOR"         ] = { name="Gladiator von Kvatch"       , set_id=240 }
,   ["LAW_OF_JULIANOS"          ] = { name="Gesetz von Julianos"        , set_id=207 }
,   ["MAGNUS_GIFT"              ] = { name="Magnus' Gabe"               , set_id= 48 }
,   ["MECHANICAL_ACUITY"        ] = { name="Mechanikblick"              , set_id=353 }
,   ["MIGHT_OF_THE_LOST_LEGION" ] = { name="Macht der Verlorenen Legion", set_id=410 }
,   ["MORKULDIN"                ] = { name="Morkuldin"                  , set_id=219 }
,   ["NAGA_SHAMAN"              ] = { name="Nagaschamane"               , set_id=409 }
,   ["NIGHT_MOTHERS_GAZE"       ] = { name="Blick der Mutter der Nacht" , set_id= 51 }
,   ["NIGHTS_SILENCE"           ] = { name="Stille der Nacht"           , set_id= 40 }
,   ["NOBLES_CONQUEST"          ] = { name="Adelssieg"                  , set_id=176 }
,   ["NOCTURNALS_FAVOR"         ] = { name="Nocturnals Gunst"           , set_id=387 }
,   ["OBLIVIONS_FOE"            ] = { name="Erinnerung"                 , set_id= 73 }
,   ["ORGNUMS_SCALES"           ] = { name="Orgnums Schuppen"           , set_id= 84 }
,   ["PELINALS_APTITUDE"        ] = { name="Pelinals Talent"            , set_id=242 }
,   ["REDISTRIBUTOR"            ] = { name="Umverteilung"               , set_id=177 }
,   ["SHACKLEBREAKER"           ] = { name="Kettensprenger"             , set_id=325 }
,   ["SHALIDORS_CURSE"          ] = { name="Shalidors Fluch"            , set_id= 95 }
,   ["SLOADS_SEMBLANCE"         ] = { name="Kreckenantlitz"             , set_id=386 }
,   ["SONG_OF_LAMAE"            ] = { name="Lied der Lamien"            , set_id= 81 }
,   ["SPECTRES_EYE"             ] = { name="Schemenauge"                , set_id= 74 }
,   ["TAVAS_FAVOR"              ] = { name="Tavas Gunst"                , set_id=224 }
,   ["TORUGS_PACT"              ] = { name="Torugs Pakt"                , set_id= 75 }
,   ["TRIAL_BY_FIRE"            ] = { name="Feuertaufe"                 , set_id=208 }
,   ["TWICE_BORN_STAR"          ] = { name="Doppelstern"                , set_id=161 }
,   ["TWILIGHTS_EMBRACE"        ] = { name="Zwielichtkuss"              , set_id= 38 }
,   ["VAMPIRES_KISS"            ] = { name="Kuss des Vampirs"           , set_id= 44 }
,   ["VARENS_LEGACY"            ] = { name="Varens Erbe"                , set_id=241 }
,   ["WAY_OF_THE_ARENA"         ] = { name="Weg der Arena"              , set_id=148 }
,   ["WHITESTRAKES_RETRIBUTION" ] = { name="Weißplankes Vergeltung"     , set_id= 41 }
,   ["WILLOWS_PATH"             ] = { name="Weidenpfad"                 , set_id= 79 }
}

-- Craftable Motifs ----------------------------------------------------------
--
-- writ6 field for master writs
--
LibCraftText.MOTIF = {
    ["BRETON"             ] = { name="Bretonen"             , motif_id=  1 }
,   ["REDGUARD"           ] = { name="Rothwardonen"         , motif_id=  2 }
,   ["ORC"                ] = { name="Orks"                 , motif_id=  3 }
,   ["DARK_ELF"           ] = { name="Dunkelelfen"          , motif_id=  4 }
,   ["NORD"               ] = { name="Nord"                 , motif_id=  5 }
,   ["ARGONIAN"           ] = { name="Argonier"             , motif_id=  6 }
,   ["HIGH_ELF"           ] = { name="Hochelfen"            , motif_id=  7 }
,   ["WOOD_ELF"           ] = { name="Waldelfen"            , motif_id=  8 }
,   ["KHAJIIT"            ] = { name="Khajiit"              , motif_id=  9 }
,   ["UNIQUE"             ] = { name="Einzigartig"          , motif_id= 10 }
,   ["THIEVES_GUILD"      ] = { name="Diebesgilde"          , motif_id= 11 }
,   ["DARK_BROTHERHOOD"   ] = { name="Dunkle Bruderschaft"  , motif_id= 12 }
,   ["MALACATH"           ] = { name="Malacath"             , motif_id= 13 }
,   ["DWEMER"             ] = { name="Dwemer"               , motif_id= 14 }
,   ["ANCIENT_ELF"        ] = { name="alte Elfen"           , motif_id= 15 }
,   ["ORDER_OF_THE_HOUR"  ] = { name="Orden der Stunde"     , motif_id= 16 }
,   ["BARBARIC"           ] = { name="Barbaren"             , motif_id= 17 }
,   ["BANDIT"             ] = { name="Bandit"               , motif_id= 18 }
,   ["PRIMAL"             ] = { name="Wilde"                , motif_id= 19 }
,   ["DAEDRIC"            ] = { name="Daedra"               , motif_id= 20 }
,   ["TRINIMAC"           ] = { name="Trinimac"             , motif_id= 21 }
,   ["ANCIENT_ORC"        ] = { name="Orkahnen"             , motif_id= 22 }
,   ["DAGGERFALL_COVENANT"] = { name="Dolchsturz-Bündnis"   , motif_id= 23 }
,   ["EBONHEART_PACT"     ] = { name="Ebenherz-Pakt"        , motif_id= 24 }
,   ["ALDMERI_DOMINION"   ] = { name="Aldmeri-Dominion"     , motif_id= 25 }
,   ["MERCENARY"          ] = { name="Söldner"              , motif_id= 26 }
,   ["CELESTIAL"          ] = { name="Himmlische"           , motif_id= 27 }
,   ["GLASS"              ] = { name="Glasit"               , motif_id= 28 }
,   ["XIVKYN"             ] = { name="Xivkyn"               , motif_id= 29 }
,   ["SOUL_SHRIVEN"       ] = { name="Seelenberaubte"       , motif_id= 30 }
,   ["DRAUGR"             ] = { name="Draugr"               , motif_id= 31 }
,   ["MAORMER"            ] = { name="Maormer"              , motif_id= 32 }
,   ["AKAVIRI"            ] = { name="Akaviri"              , motif_id= 33 }
,   ["IMPERIAL"           ] = { name="Kaiserliche"          , motif_id= 34 }
,   ["YOKUDAN"            ] = { name="Yokudaner"            , motif_id= 35 }
,   ["UNIVERSAL"          ] = { name="universell"           , motif_id= 36 }
,   ["REACH_WINTER"       ] = { name="Reikwinter"           , motif_id= 37 }
,   ["TSAESCI"            ] = { name="Tsaesci"              , motif_id= 38 }
,   ["MINOTAUR"           ] = { name="Minotauren"           , motif_id= 39 }
,   ["EBONY"              ] = { name="Ebenerz"              , motif_id= 40 }
,   ["ABAHS_WATCH"        ] = { name="Abahs Wacht"          , motif_id= 41 }
,   ["SKINCHANGER"        ] = { name="Gestaltwandler"       , motif_id= 42 }
,   ["MORAG_TONG"         ] = { name="Morag Tong"           , motif_id= 43 }
,   ["RA_GADA"            ] = { name="Ro'Wada"              , motif_id= 44 }
,   ["DRO_MATHRA"         ] = { name="dro-m'Athra"          , motif_id= 45 }
,   ["ASSASSINS_LEAGUE"   ] = { name="Assassinenbund"       , motif_id= 46 }
,   ["OUTLAW"             ] = { name="Gesetzlose"           , motif_id= 47 }
,   ["REDORAN"            ] = { name="Redoran"              , motif_id= 48 }
,   ["HLAALU"             ] = { name="Hlaalu"               , motif_id= 49 }
,   ["MILITANT_ORDINATOR" ] = { name="kriegerische Ordinatoren", motif_id= 50 }
,   ["TELVANNI"           ] = { name="Telvanni"             , motif_id= 51 }
,   ["BUOYANT_ARMIGER"    ] = { name="Kriegswappenträger"   , motif_id= 52 }
,   ["FROSTCASTER"        ] = { name="Frostwirker"          , motif_id= 53 }
,   ["ASHLANDER"          ] = { name="Aschländer"           , motif_id= 54 }
,   ["WORM_CULT"          ] = { name="Wurmkult"             , motif_id= 55 }
,   ["SILKEN_RING"        ] = { name="Seidenring"           , motif_id= 56 }
,   ["MAZZATUN"           ] = { name="Mazzatun"             , motif_id= 57 }
,   ["GRIM_HARLEQUIN"     ] = { name="grimmiger Harlekin"   , motif_id= 58 }
,   ["HOLLOWJACK"         ] = { name="Kürbisfratze"         , motif_id= 59 }
,   ["REFABRICATED"       ] = { name="Rekonstruktion"       , motif_id= 60 }
,   ["BLOODFORGE"         ] = { name="Blutquellschmiede"    , motif_id= 61 }
,   ["DREADHORN"          ] = { name="Grauenshorn"          , motif_id= 62 }
,   ["APOSTLE"            ] = { name="Apostel"              , motif_id= 65 }
,   ["EBONSHADOW"         ] = { name="Ebenschatten"         , motif_id= 66 }
,   ["UNDAUNTED"          ] = { name="Unerschrockene"       , motif_id= 67 }
,   ["USE_ME"             ] = { name="USE ME"               , motif_id= 68 }
,   ["FANG_LAIR"          ] = { name="Krallenhort"          , motif_id= 69 }
,   ["SCALECALLER"        ] = { name="Schuppenruferin"      , motif_id= 70 }
,   ["PSIJIC_ORDER"       ] = { name="Psijik-Orden"         , motif_id= 71 }
,   ["SAPIARCH"           ] = { name="Sapiarchen"           , motif_id= 72 }
,   ["WELKYNAR"           ] = { name="Welkynare"            , motif_id= 73 }
,   ["DREMORA"            ] = { name="Dremora"              , motif_id= 74 }
,   ["PYANDONEAN"         ] = { name="Pyandonesier"         , motif_id= 75 }
,   ["DIVINE_PROSECUTION" ] = { name="Göttliche Strafbehörde", motif_id= 76 }
,   ["HUNTSMAN"           ] = { name="Jäger"                , motif_id= 77 }
,   ["SILVER_DAWN"        ] = { name="Silbermorgen"         , motif_id= 78 }
,   ["DEAD_WATER"         ] = { name="Totwasser"            , motif_id= 79 }
,   ["HONOR_GUARD"        ] = { name="Ehrengarde"           , motif_id= 80 }
,   ["ELDER_ARGONIAN"     ] = { name="alte Argonier"        , motif_id= 81 }
}


-- Miscellaneous conditions --------------------------------------------------

LibCraftText.DAILY.COND = {
    HINT_PR_BREWERS_COOKS_RECIPES = "Brauer und Köche verkaufen Rezepte"
,   DELIVER_GOODS_SUBSTRING       = "Beliefert "            
,   DELIVER_NEAREST_QUARTERMASTER = "Beliefert den nächsten Quartiermeister für Handwerksschriebe"
,   DELIVER_ALLIANCE_DEPOT        = "Deliver Goods to Alliance Supply Depot"
,   DELIVER_CONSORTIUM_TRADEPOST  = "Deliver Goods to Consortium Tradepost"
,   DELIVER_REFUGEE_RELIEF        = "Deliver Goods to Refugee Relief Site"
,   DELIVER_FIGHTERS_GUILD        = "Deliver Goods to Fighters Guild Provisioner"
}

LibCraftText.MASTER.COND = {
    TRAVEL_AD       = "Reist nach Eldenwurz, um Euren Kontakt zu treffen"-- "Travel to Elden Root to Meet Your Contact"
,   TRAVEL_DC       = "Reist nach Wegesruh, um Euren Kontakt zu treffen"-- "Travel to Wayrest to Meet Your Contact"
,   TRAVEL_EP       = "Reist nach Gramfeste, um Euren Kontakt zu treffen"-- "Travel to Mournhold to Meet Your Contact"

,   DELIVER_AL      = "Liefert das Gebräu"                          -- "Deliver the Concoction"
,   DELIVER_EN      = "Liefert die Glyphe"                          -- "Deliver the Glyph"
,   DELIVER_PR      = "Liefert das Mahl"                            -- "Deliver the Feast"
,   DELIVER_WEAPON  = "Liefert die Waffe"                           -- "Deliver the Weapon"
,   DELIVER_ARMOR   = "Liefert die Rüstung"                         -- "Deliver the Armor"
,   DELIVER_JW      = "Liefert den Schmuck aus"                     -- "Deliver the Jewelry"
}


-- Random Unsorted Stuff -----------------------------------------------------

LibCraftText.MASTER_LABELS = {
    ["quality"] =  "Qualität"                        -- "Quality"
,   ["set"    ] =  "Set"                             -- "Set"
,   ["style"  ] =  "Stil"                            -- "Style"
,   ["trait"  ] =  "Eigenschaft"                     -- "Trait"
}

LibCraftText.QUALITY = {
    ["NORMAL"   ] = { name="Normal"     , index=ITEM_QUALITY_NORMAL         or 1 }
,   ["FINE"     ] = { name="Erlesen"    , index=ITEM_QUALITY_FINE           or 2 }
,   ["SUPERIOR" ] = { name="Überlegen"  , index=ITEM_QUALITY_SUPERIOR       or 3 }
,   ["EPIC"     ] = { name="Episch"     , index=ITEM_QUALITY_EPIC           or 4 }
,   ["LEGENDARY"] = { name="Legendär"   , index=ITEM_QUALITY_LEGENDARY      or 5 }
}


-- Quest and Dialog Text -----------------------------------------------------

LibCraftText.DAILY.QUEST_NAME = {
    [bs] = "Schmiedeschrieb"                    -- "Blacksmith Writ"
,   [cl] = "Schneiderschrieb"                   -- "Clothier Writ"
,   [en] = "Verzaubererschrieb"                 -- "Enchanter Writ"
,   [al] = "Alchemistenschrieb"                 -- "Alchemist Writ"
,   [pr] = "Versorgerschrieb"                   -- "Provisioner Writ"
,   [ww] = "Schreinerschrieb"                   -- "Woodworker Writ"
,   [jw] = "Schmuckhandwerksschrieb"            -- "Jewelry Crafting Writ"
}
                        -- SURPRISE! "A Masterful Weapon" is used by both
                        -- Blacksmithing and Woodworking.
                        --
                        -- Why a list? Because BS, CL, and WW can all use
                        -- different quest titles depending on what item they
                        -- requested (armor vs. weapon, light vs. medium armor)
                        --
LibCraftText.MASTER.QUEST_NAME = {
    [bs] = { "Eine meisterhafte Rüstung"          -- "A Masterful Plate"
           , "Eine meisterhafte Waffe"          } -- "A Masterful Weapon"
,   [cl] = { "Ein meisterhaftes Gewand"           -- "Masterful Tailoring"
           , "Meisterhafte Lederwaren"          } -- "Masterful Leatherwear"
,   [en] = { "Eine meisterhafte Glyphe"         } -- "A Masterful Glyph"
,   [al] = { "Ein meisterhaftes Gebräu"         } -- "A Masterful Concoction"
,   [pr] = { "Ein meisterhaftes Mahl"           } -- "A Masterful Feast"
,   [ww] = { "Ein meisterhafter Schild"           -- "A Masterful Shield"
           , "Eine meisterhafte Waffe"          } -- "A Masterful Weapon"
,   [jw] = { "Ein meisterhaftes Schmuckstück"   } -- "Masterful Jewelry"
}

LibCraftText.DAILY.DIALOG = {
    ["OPTION_ACCEPT"      ] = "<Einen Schrieb vom Brett nehmen.>"       -- "<Pull a Writ from the Board.>"
,   ["OPTION_FINISH_SIGN" ] = "<Das Manifest unterschreiben.>"          -- "<Sign the Manifest.>"
,   ["OPTION_FINISH_PLACE"] = "<Die Waren in die Kiste legen.>"         -- "<Place the goods within the crate.>"
,   ["GOAL_SIGN"          ] = "Unterschreibt das Liefermanifest"        -- "Sign Delivery Manifest"
}

LibCraftText.MASTER.DIALOG = {
    ["OPTION_ACCEPT"      ] = { "<Nehmt den Auftrag an.>"               -- "<Accept the contract.>"
                              , "<Den Auftrag annehmen.>"               -- "<Accept the contract>"  (FR French omits the period sometimes)
                              }
,   ["ROLIS_NAME"         ] = "Rolis Hlaalu"                            -- "Rolis Hlaalu"
,   ["TITLE_ROLIS"        ] = "-Rolis Hlaalu-"                          -- "-Rolis Hlaalu-"
,   ["OPTION_STORE"       ] = "Was habt Ihr anzubieten, Meisterhandwerksvermittler?"-- "Store (Mastercraft Mediator)"
,   ["OPTION_FINISH_JOB"  ] = "<Auftrag abschließen.>"                  -- "<Finish the job.>"
,   ["RESPONSE_ENDING"    ] = "<Er vermerkt Eure Arbeit und kümmert sich um die Bezahlung.>"-- "<He notes your work and tenders payment.>"
}

LibCraftText.DAILY.DIALOG.TITLE_OFFER = {
    "-Handwerksschriebe: Ausrüstung-"             -- "-Equipment Crafting Writs-"
,   "-Handwerksschriebe-"                         -- "-Consumables Crafting Writs-"
}

LibCraftText.MASTER.DIALOG.TITLE_OFFER = {
    [bs] = "-Versiegelter Waffenschmiedeschrieb-" -- "-Sealed Blacksmithing Writ-"
,   [cl] = "-Versiegelter Schneiderschrieb-"      -- "-Sealed Clothier Writ-"
,   [en] = "-Versiegelter Verzauberungsschrieb-"  -- "-Sealed Enchanting Writ-"
,   [al] = "-Versiegelter Alchemieschrieb-"       -- "-Sealed Alchemy Writ-"
,   [pr] = "-Versiegelter Versorgerschrieb-"      -- "-Sealed Provisioning Writ-"
,   [ww] = "-Versiegelter Schreinerschrieb-"      -- "-Sealed Woodworking Writ-"
,   [jw] = "-Versiegelter Schmuckhandwerksschrieb-"-- "-Sealed Jewelry Crafter Writ-"
}

LibCraftText.DAILY.DIALOG.TITLE_TURN_IN = {
    [bs] = "-Schmiedelieferung-"                  -- "-Blacksmith Delivery Crate-"
,   [cl] = "-Schneiderlieferung-"                 -- "-Clothier Delivery Crate-"
,   [en] = "-Verzaubererlieferung-"               -- "-Enchanter Delivery Crate-"
,   [al] = "-Alchemistenlieferung-"               -- "-Alchemist Delivery Crate-"
,   [pr] = "-Versorgerlieferung-"                 -- "-Provisioner Delivery Crate-"
,   [ww] = "-Schreinerlieferung-"                 -- "-Woodworker Delivery Crate-"
,   [jw] = "-Schmucklieferung-"                   -- "-Jewelry Crafting Delivery Crate-"
}

LibCraftText.DAILY.DIALOG.OPTION_EXAMINE = {
    [bs] = "<Die Schmiedeschriebe betrachten.>"   -- "<Examine the Blacksmith Writs.>"
,   [cl] = "<Die Schneiderschriebe betrachten.>"  -- "<Examine the Clothier Writs.>"
,   [en] = "<Die Verzaubererschriebe betrachten.>"-- "<Examine the Enchanter Writs.>"
,   [al] = "<Die Alchemistenschriebe betrachten.>"-- "<Examine the Alchemist Writs.>"
,   [pr] = "<Die Versorgerschriebe betrachten.>"  -- "<Examine the Provisioner Writs.>"
,   [ww] = "<Die Schreinerschriebe betrachten.>"  -- "<Examine the Woodworker Writs.>"
,   [jw] = "<Die Schmuckhandwerksschriebe betrachten.>"-- "<Examine the Jewelry Crafting Writs.>"
}

LibCraftText.MASTER.DIALOG.OPTION_FINISH = {
    [bs] = "Ich habe den Schmiedeauftrag erledigt."-- "I've finished the Blacksmithing job."
,   [cl] = "Ich habe den Schneiderauftrag erledigt."-- "I've finished the Clothier job."
,   [en] = "Ich habe den Verzaubererauftrag erledigt."-- "I've finished the Enchanting job."
,   [al] = "Ich habe den Alchemieauftrag erledigt."-- "I've finished the Alchemy job."
,   [pr] = "Ich habe den Versorgerauftrag erledigt."-- "I've finished the Provisioning job."
,   [ww] = "Ich habe den Schreinerauftrag erledigt."-- "I've finished the Woodworking job."
,   [jw] = "Ich habe den Schmuckauftrag erledigt."-- "I've finished the Jewelry job."
}
