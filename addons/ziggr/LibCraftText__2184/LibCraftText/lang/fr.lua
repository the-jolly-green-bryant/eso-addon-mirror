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
  ["H1_AXE"         ] = { name="hache"                , master_name="hache"                     , pattern_index= 1, master_writ1=53, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H1_MACE"        ] = { name="masse"                , master_name="masse"                     , pattern_index= 2, master_writ1=56, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H1_SWORD"       ] = { name="épée"                 , master_name="épée"                      , pattern_index= 3, master_writ1=59, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H2_BATTLE_AXE"  ] = { name="hache de bataille"    , master_name="Hache de bataille"         , pattern_index= 4, master_writ1=68, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H2_MAUL"        ] = { name="masse d'arme"         , master_name="masse d'arme"              , pattern_index= 5, master_writ1=69, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H2_GREATSWORD"  ] = { name="épée longue"          , master_name="épée longue"               , pattern_index= 6, master_writ1=67, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["DAGGER"         ] = { name="dague"                , master_name="dague"                     , pattern_index= 7, master_writ1=62, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["CUIRASS"        ] = { name="cuirasse"             , master_name="cuirasse"                  , pattern_index= 8, master_writ1=46, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["SABATONS"       ] = { name="solerets"             , master_name="Soleret"                   , pattern_index= 9, master_writ1=50, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["GAUNTLETS"      ] = { name="gantelets"            , master_name="Gantelets"                 , pattern_index=10, master_writ1=52, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["HELM"           ] = { name="heaume"               , master_name="casque"                    , pattern_index=11, master_writ1=44, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["GREAVES"        ] = { name="grèves"               , master_name="Grèves"                    , pattern_index=12, master_writ1=49, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["PAULDRON"       ] = { name="spallière"            , master_name="Spallière"                 , pattern_index=13, master_writ1=47, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["GIRDLE"         ] = { name="gaine"                , master_name="gaine"                     , pattern_index=14, master_writ1=48, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }

, ["ROBE"           ] = { name="robe"                 , master_name="robe"                      , pattern_index= 1, master_writ1=28, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["JERKIN"         ] = { name="pourpoint"            , master_name="Pourpoint"                 , pattern_index= 2, master_writ1=75, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["SHOES"          ] = { name="chaussures"           , master_name="Chaussures"                , pattern_index= 3, master_writ1=32, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["GLOVES"         ] = { name="gants"                , master_name="Gants"                     , pattern_index= 4, master_writ1=34, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["HAT"            ] = { name="chapeau"              , master_name="chapeau"                   , pattern_index= 5, master_writ1=26, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["BREECHES"       ] = { name="braies"               , master_name="Braies"                    , pattern_index= 6, master_writ1=31, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["EPAULETS"       ] = { name="épaulettes"           , master_name="Épaulettes"                , pattern_index= 7, master_writ1=29, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr , name_2="épaulettes"}
, ["SASH"           ] = { name="baudrier"             , master_name="Baudrier"                  , pattern_index= 8, master_writ1=30, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr , name_2="baudier"   }
, ["JACK"           ] = { name="gilet"                , master_name="gilet"                     , pattern_index= 9, master_writ1=37, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["BOOTS"          ] = { name="bottes"               , master_name="Bottes"                    , pattern_index=10, master_writ1=41, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["BRACERS"        ] = { name="brassards"            , master_name="Brassards"                 , pattern_index=11, master_writ1=43, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr , name_2="brassards" }
, ["HELMET"         ] = { name="casque"               , master_name="casque"                    , pattern_index=12, master_writ1=35, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr , name_2="casque"    }
, ["GUARDS"         ] = { name="gardes"               , master_name="Gardes"                    , pattern_index=13, master_writ1=40, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["ARM_COPS"       ] = { name="coques d'épaules"     , master_name="Coques d'épaules"          , pattern_index=14, master_writ1=38, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["BELT"           ] = { name="ceinture"             , master_name="ceinture"                  , pattern_index=15, master_writ1=39, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }

, ["BOW"            ] = { name="arc"                  , master_name="arc"                       , pattern_index= 1, master_writ1=70, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["INFERNO_STAFF"  ] = { name="bâton infernal"       , master_name="bâton infernal"            , pattern_index= 3, master_writ1=72, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["ICE_STAFF"      ] = { name="bâton de glace"       , master_name="Bâton de glace"            , pattern_index= 4, master_writ1=73, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["LIGHTNING_STAFF"] = { name="bâton de foudre"      , master_name="Bâton de foudre"           , pattern_index= 5, master_writ1=74, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["RESTO_STAFF"    ] = { name="bâton de rétablissement", master_name="Bâton de rétablissement"   , pattern_index= 6, master_writ1=71, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["SHIELD"         ] = { name="bouclier"             , master_name="bouclier"                  , pattern_index= 2, master_writ1=65, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_armr }

, ["NECKLACE"       ] = { name="collier"              , master_name="Collier"                   , pattern_index= 2, master_writ1=18, crafting_type=jw, mat_set_id=mat_jewl, trait_set_id=trait_jewl , name_2="collier"   }
, ["RING"           ] = { name="anneau"               , master_name="Anneau"                    , pattern_index= 1, master_writ1=24, crafting_type=jw, mat_set_id=mat_jewl, trait_set_id=trait_jewl }
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
  ["AETHERIAL_TEA"                      ] = { name="thé éthérien"                          , food_item_id=033602, recipe_item_id=046049, recipe_list_index=  9, recipe_index= 31, name_2="thé éthérien"}
, ["ALIKR_BEETS_WITH_GOAT_CHEESE"       ] = { name="betteraves d'Alik'r au chèvre"         , food_item_id=028338, recipe_item_id=045899, recipe_list_index=  3, recipe_index= 13}
, ["BAKED_APPLES"                       ] = { name="pommes cuites"                         , food_item_id=033837, recipe_item_id=045889, recipe_list_index=  2, recipe_index=  1}
, ["BAKED_POTATO"                       ] = { name="pomme de terre au four"                , food_item_id=028354, recipe_item_id=045912, recipe_list_index=  3, recipe_index=  2}
, ["BANANA_SURPRISE"                    ] = { name="banane surprise"                       , food_item_id=028281, recipe_item_id=045913, recipe_list_index=  2, recipe_index=  2}
, ["BARLEY_NECTAR"                      ] = { name="nectar d'orge"                         , food_item_id=033624, recipe_item_id=045984, recipe_list_index=  8, recipe_index= 14}
, ["BATTAGLIR_CHOWDER"                  ] = { name="bisque de battaglir"                   , food_item_id=028394, recipe_item_id=045946, recipe_list_index=  3, recipe_index= 15}
, ["BITTERLEMON_TEA"                    ] = { name="infusion de citron amer"               , food_item_id=028457, recipe_item_id=046000, recipe_list_index=  9, recipe_index= 13}
, ["BLUE_ROAD_MARATHON"                 ] = { name="marathon de Sente-azur"                , food_item_id=028513, recipe_item_id=046030, recipe_list_index= 10, recipe_index= 25}
, ["BOG_IRON_ALE"                       ] = { name="bière de Tourbefer"                    , food_item_id=028405, recipe_item_id=045971, recipe_list_index=  8, recipe_index=  4}
, ["BRETON_PORK_SAUSAGE"                ] = { name="saucisse de porc brétonne"             , food_item_id=028342, recipe_item_id=045900, recipe_list_index=  1, recipe_index= 13}
, ["CARROT_SOUP"                        ] = { name="soupe de carottes"                     , food_item_id=028321, recipe_item_id=045887, recipe_list_index=  3, recipe_index=  1}
, ["CHICKEN_BREAST"                     ] = { name="blanc de poulet"                       , food_item_id=033819, recipe_item_id=045935, recipe_list_index=  1, recipe_index=  3}
, ["CHORROL_CORN_ON_THE_COB"            ] = { name="maïs grillé de Chorrol"                , food_item_id=033514, recipe_item_id=045929, recipe_list_index=  3, recipe_index= 20}
, ["CINNAMON_GRAPE_JELLY"               ] = { name="gelée de raisins à la cannelle"        , food_item_id=042790, recipe_item_id=045907, recipe_list_index=  2, recipe_index= 19}
, ["CLARIFIED_SYRAH_WINE"               ] = { name="clairet de Syrah"                      , food_item_id=028409, recipe_item_id=045972, recipe_list_index=  8, recipe_index=  7, name_2="clairet de Syrah"}
, ["COMELY_WENCH_WHISKEY"               ] = { name="whiskey de l'accorte hôtesse"          , food_item_id=028402, recipe_item_id=046048, recipe_list_index=  8, recipe_index= 31}
, ["CYRODILIC_CORNBREAD"                ] = { name="pain de maïs cyrodiiléen"              , food_item_id=033897, recipe_item_id=045958, recipe_list_index=  3, recipe_index= 25}
, ["CYRODILIC_PUMPKIN_FRITTERS"         ] = { name="beignets de citrouille cyrodiiléens"   , food_item_id=033789, recipe_item_id=045931, recipe_list_index=  2, recipe_index= 20}
, ["ELENHIR_ROAST_ANTELOPE"             ] = { name="antilope rôtie d'Élinhir"              , food_item_id=033520, recipe_item_id=045930, recipe_list_index=  1, recipe_index= 20}
, ["ELTHERIC_HOOCH"                     ] = { name="tord-boyau Elthérique"                 , food_item_id=028417, recipe_item_id=045974, recipe_list_index=  8, recipe_index= 13, name_2="tord-boyau Elthérique"}
, ["FIRSTHOLD_FRUIT_AND_CHEESE_PLATE"   ] = { name="plateau de fruits et de fromage de Prime-Tenure", food_item_id=068236, recipe_item_id=068192, recipe_list_index=  2, recipe_index= 40}
, ["FISHY_STICK"                        ] = { name="bâtonnet de poisson"                   , food_item_id=033526, recipe_item_id=045888, recipe_list_index=  1, recipe_index=  1}
, ["FOUR_EYE_GROG"                      ] = { name="grog quilouche"                        , food_item_id=033612, recipe_item_id=045982, recipe_list_index=  8, recipe_index=  8}
, ["GARLIC_MASHED_POTATOES"             ] = { name="purée à l'ail"                         , food_item_id=028346, recipe_item_id=045905, recipe_list_index=  3, recipe_index= 19}
, ["GARLIC_PUMPKIN_SEEDS"               ] = { name="graines de citrouille à l'ail"         , food_item_id=033490, recipe_item_id=045925, recipe_list_index=  2, recipe_index= 14}
, ["GINGER_WHEAT_BEER"                  ] = { name="bière de froment au gingembre"         , food_item_id=033963, recipe_item_id=045993, recipe_list_index=  8, recipe_index= 18}
, ["GODS_BLIND_ME"                      ] = { name="Les-Dieux-M'aveuglent"                 , food_item_id=028433, recipe_item_id=045978, recipe_list_index=  8, recipe_index= 25, name_2="Les-Dieux-M'aveuglent"}
, ["GOLDEN_LAGER"                       ] = { name="cervoise dorée"                        , food_item_id=033933, recipe_item_id=045988, recipe_list_index=  8, recipe_index=  3}
, ["GOSSAMER_MAZTE"                     ] = { name="mazté soyeux"                          , food_item_id=033957, recipe_item_id=045992, recipe_list_index=  8, recipe_index= 15}
, ["GRANDPAS_BEDTIME_TONIC"             ] = { name="tonique du papi au lit"                , food_item_id=028444, recipe_item_id=046050, recipe_list_index= 10, recipe_index= 31}
, ["GRAPE_PRESERVES"                    ] = { name="confiture de raisin"                   , food_item_id=033825, recipe_item_id=045936, recipe_list_index=  2, recipe_index=  3}
, ["HAGRAVENS_TONIC"                    ] = { name="tonique de harfreuse"                  , food_item_id=068263, recipe_item_id=068219, recipe_list_index= 10, recipe_index= 42}
, ["HARE_IN_GARLIC_SAUCE"               ] = { name="lièvre à l'ail"                        , food_item_id=033581, recipe_item_id=045953, recipe_list_index=  1, recipe_index= 21, name_2="lièvre à l'ail"}
, ["HEARTY_GARLIC_CORN_CHOWDER"         ] = { name="soupe de maïs épaisse à l'ail"         , food_item_id=068239, recipe_item_id=068195, recipe_list_index=  3, recipe_index= 40}
, ["HONEY_RYE"                          ] = { name="scotch au miel"                        , food_item_id=028421, recipe_item_id=045975, recipe_list_index=  8, recipe_index= 16}
, ["JERALL_VIEW_INN_CARROT_CAKE"        ] = { name="gâteau de carotte de l'auberge de la vue de Jerall", food_item_id=033575, recipe_item_id=045952, recipe_list_index=  3, recipe_index= 21}
, ["LEMON_FLOWER_MAZTE"                 ] = { name="mazté à la fleur de citronnier"        , food_item_id=033945, recipe_item_id=045990, recipe_list_index=  8, recipe_index=  9}
, ["LILMOTH_GARLIC_HAGFISH"             ] = { name="anguille des harfreuses à l'ail de Lilmoth", food_item_id=068235, recipe_item_id=068191, recipe_list_index=  1, recipe_index= 42}
, ["LUSTY_ARGONIAN_MAID_MAZTE"          ] = { name="mazté de la femme de chambre argonienne", food_item_id=068276, recipe_item_id=068232, recipe_list_index= 14, recipe_index= 31, name_2="mazté de la femme de chambre argonienne"}
, ["MAMMOTH_SNOUT_PIE"                  ] = { name="tourte au groin de mammouth"           , food_item_id=033903, recipe_item_id=045959, recipe_list_index=  1, recipe_index= 25}
, ["MAORMER_TEA"                        ] = { name="thé maormer"                           , food_item_id=028465, recipe_item_id=046002, recipe_list_index=  9, recipe_index= 19}
, ["MARKARTH_MEAD"                      ] = { name="hydromel de Markarth"                  , food_item_id=068257, recipe_item_id=068213, recipe_list_index=  8, recipe_index= 42}
, ["MAZTE"                              ] = { name="mazté"                                 , food_item_id=033606, recipe_item_id=045981, recipe_list_index=  8, recipe_index=  5}
, ["MERMAID_WHISKEY"                    ] = { name="whisky des sirènes"                    , food_item_id=033630, recipe_item_id=045985, recipe_list_index=  8, recipe_index= 17}
, ["MILLET_STUFFED_PORK_LOIN"           ] = { name="filet-mignon de porc farci au millet"  , food_item_id=043088, recipe_item_id=045965, recipe_list_index=  1, recipe_index= 31}
, ["MULLED_WINE"                        ] = { name="vin chaud"                             , food_item_id=033969, recipe_item_id=045994, recipe_list_index=  8, recipe_index= 21}
, ["MUTHSERAS_REMORSE"                  ] = { name="remords de Muthséra"                   , food_item_id=068260, recipe_item_id=068216, recipe_list_index=  9, recipe_index= 42}
, ["NEREID_WINE"                        ] = { name="vin de la néréïde"                     , food_item_id=033975, recipe_item_id=045995, recipe_list_index=  8, recipe_index= 24}
, ["NIBENESE_GARLIC_CARROTS"            ] = { name="carottes à l'ail nibenaises"           , food_item_id=033478, recipe_item_id=045923, recipe_list_index=  3, recipe_index= 14}
, ["NUT_BROWN_ALE"                      ] = { name="bière brune à la noisette"             , food_item_id=028401, recipe_item_id=045970, recipe_list_index=  8, recipe_index=  1}
, ["ORCREST_GARLIC_APPLE_JELLY"         ] = { name="gelée de pommes à l'ail d'Orcrête"     , food_item_id=043094, recipe_item_id=045966, recipe_list_index=  2, recipe_index= 31}
, ["PELLITINE_TOMATO_RICE"              ] = { name="riz à la tomate de Pellitine"          , food_item_id=042814, recipe_item_id=045901, recipe_list_index=  2, recipe_index= 13}
, ["RED_RYE_BEER"                       ] = { name="bière de seigle rousse"                , food_item_id=033600, recipe_item_id=045980, recipe_list_index=  8, recipe_index=  2}
, ["REDORAN_PEPPERED_MELON"             ] = { name="melon poivré de Rédoran"               , food_item_id=033552, recipe_item_id=045948, recipe_list_index=  2, recipe_index= 15}
, ["ROAST_CORN"                         ] = { name="maïs rôti"                             , food_item_id=033813, recipe_item_id=045934, recipe_list_index=  3, recipe_index=  3}
, ["RYE_IN_YOUR_EYE"                    ] = { name="scotch-dans-ta-face"                   , food_item_id=028429, recipe_item_id=045977, recipe_list_index=  8, recipe_index= 22}
, ["SEAFLOWER_TEA"                      ] = { name="thé à l'anémone"                       , food_item_id=034005, recipe_item_id=046018, recipe_list_index=  9, recipe_index= 15}
, ["SENCHAL_CURRY_FISH_AND_RICE"        ] = { name="curry de poisson de Senchal"           , food_item_id=028350, recipe_item_id=045906, recipe_list_index=  1, recipe_index= 19}
, ["SKYRIM_JAZBAY_CROSTATA"             ] = { name="croustillant au jazbay de Bordeciel"   , food_item_id=033909, recipe_item_id=045960, recipe_list_index=  2, recipe_index= 25}
, ["SORRY_HONEY_LAGER"                  ] = { name="cervoise « Désolé, chérie »"           , food_item_id=033642, recipe_item_id=045987, recipe_list_index=  8, recipe_index= 23}
, ["SOUR_MASH"                          ] = { name="moût aigre"                            , food_item_id=028425, recipe_item_id=045976, recipe_list_index=  8, recipe_index= 19}
, ["SPICEBERRY_CHAI"                    ] = { name="thé d'épiceline"                       , food_item_id=033684, recipe_item_id=046012, recipe_list_index=  9, recipe_index= 20}
, ["SPICED_MAZTE"                       ] = { name="mazté épicé"                           , food_item_id=033636, recipe_item_id=045986, recipe_list_index=  8, recipe_index= 20}
, ["STORMHOLD_BAKED_BANANAS"            ] = { name="bananes cuites de Fort-tempête"        , food_item_id=033587, recipe_item_id=045954, recipe_list_index=  2, recipe_index= 21}
, ["SURILIE_SYRAH_WINE"                 ] = { name="vin de syrah de Surilie"               , food_item_id=033939, recipe_item_id=045989, recipe_list_index=  8, recipe_index=  6}
, ["TORVAL_MINT_TEA"                    ] = { name="thé à la menthe de Torval"             , food_item_id=034017, recipe_item_id=046020, recipe_list_index=  9, recipe_index= 21}
, ["TREACLEBERRY_TEA"                   ] = { name="thé de mélassine"                      , food_item_id=033672, recipe_item_id=046010, recipe_list_index=  9, recipe_index= 14}
, ["TWO_ZEPHYR_TEA"                     ] = { name="thé des deux zéphyrs"                  , food_item_id=028473, recipe_item_id=046004, recipe_list_index=  9, recipe_index= 25}
, ["VENISON_PASTY"                      ] = { name="friand de gibier"                      , food_item_id=028398, recipe_item_id=045947, recipe_list_index=  1, recipe_index= 15}
, ["WEST_WEALD_CORN_CHOWDER"            ] = { name="bisque au maïs occidental froide"      , food_item_id=032160, recipe_item_id=045964, recipe_list_index=  3, recipe_index= 31}
, ["WHITERUN_CHEESE_BAKED_TROUT"        ] = { name="truite gratinée de Blancherive"        , food_item_id=033484, recipe_item_id=045924, recipe_list_index=  1, recipe_index= 14}

-- master
, ["CAPON_TOMATO_BEET_CASSEROLE"        ] = { name="ragoût de capon aux tomates et aux betteraves", food_item_id=068251, recipe_item_id=068207, recipe_list_index=  7, recipe_index= 28}
, ["JUGGED_RABBIT_IN_PRESERVES"         ] = { name="conserve de lapin confit"              , food_item_id=068252, recipe_item_id=068208, recipe_list_index=  7, recipe_index= 29}
, ["LONGFIN_PASTY_WITH_MELON_SAUCE"     ] = { name="friand de nagelongue à la sauce au melon", food_item_id=068253, recipe_item_id=068209, recipe_list_index=  7, recipe_index= 30, name_2="friand de nagelongue à la sauce au melon"}
, ["LUSTY_ARGONIAN_MAID_MAZTE"          ] = { name="mazté de la femme de chambre argonienne", food_item_id=068276, recipe_item_id=068232, recipe_list_index= 14, recipe_index= 31, name_2="mazté de la femme de chambre argonienne"}
, ["ORCREST_AGONY_PALE_ALE"             ] = { name="bière blonde d'agonie d'Orcrête"       , food_item_id=068275, recipe_item_id=068231, recipe_list_index= 14, recipe_index= 30, name_2="bière blonde d'agonie d'Orcrête"}
, ["ORZORGAS_BLOOD_PRICE_PIE"           ] = { name="tarte « Prix du sang » d'Orzorga"      , food_item_id=071058, recipe_item_id=071062, recipe_list_index= 16, recipe_index=  3, name_2="tarte « Prix du sang » d'Orzorga"}
, ["ORZORGAS_RED_FROTHGAR"              ] = { name="bouillon rouge d'Orzorga"              , food_item_id=071056, recipe_item_id=071060, recipe_list_index= 15, recipe_index= 14, name_2="bouillon rouge d'Orzorga"}
, ["ORZORGAS_SMOKED_BEAR_HAUNCH"        ] = { name="cuissot d'ours fumé d'Orzorga"         , food_item_id=071059, recipe_item_id=071063, recipe_list_index= 16, recipe_index=  4, name_2="cuissot d'ours fumé d'Orzorga"}
, ["ORZORGAS_TRIPE_TRIFLE_POCKET"       ] = { name="charlotte aux tripes d'Orzorga"        , food_item_id=071057, recipe_item_id=071061, recipe_list_index= 16, recipe_index=  2, name_2="charlotte aux tripes d'Orzorga"}
, ["PSIJIC_AMBROSIA"                    ] = { name="ambroisie psijique"                    , food_item_id=064221, recipe_item_id=064223, recipe_list_index= 15, recipe_index=  1, name_2="ambroisie psijique"}
, ["SENCHE_TIGER_SINGLE_MALT"           ] = { name="single malt du tigre-senche"           , food_item_id=068273, recipe_item_id=068229, recipe_list_index= 14, recipe_index= 28, name_2="single malt du tigre-senche"}
, ["VELOTHI_VIEW_VINTAGE_MALBEC"        ] = { name="vieux cru vélothi de Malbec"           , food_item_id=068274, recipe_item_id=068230, recipe_list_index= 14, recipe_index= 29, name_2="vieux cru vélothi de Malbec"}
, ["WITHERED_TREE_INN_VENISON_POT_ROAST"] = { name="rôti de gibier de l'auberge de l'Arbre flétri", food_item_id=068254, recipe_item_id=068210, recipe_list_index=  7, recipe_index= 31, name_2="friand de nagelongue à la sauce au melon"}
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
  ["IRON"                    ] = { name="fer"                            , crafting_type=bs, level_index= 1, material_index= 1, master_writ2=  1, mat_set_id=mat_hvy  }
, ["STEEL"                   ] = { name="acier"                          , crafting_type=bs, level_index= 2, material_index= 8, master_writ2=  9, mat_set_id=mat_hvy  }
, ["ORICHALC"                ] = { name="orichalque"                     , crafting_type=bs, level_index= 3, material_index=13, master_writ2=156, mat_set_id=mat_hvy  }
, ["DWARVEN"                 ] = { name="dwemère"                        , crafting_type=bs, level_index= 4, material_index=18, master_writ2=160, mat_set_id=mat_hvy  , name_2="dwemer"         }
, ["EBONY"                   ] = { name="ébonite"                        , crafting_type=bs, level_index= 5, material_index=23, master_writ2=164, mat_set_id=mat_hvy  , name_2="ébonite"        }
, ["CALCINIUM"               ] = { name="calcinium"                      , crafting_type=bs, level_index= 6, material_index=26, master_writ2=168, mat_set_id=mat_hvy  }
, ["GALATITE"                ] = { name="galatite"                       , crafting_type=bs, level_index= 7, material_index=29, master_writ2=172, mat_set_id=mat_hvy  }
, ["QUICKSILVER"             ] = { name="mercure"                        , crafting_type=bs, level_index= 8, material_index=32, master_writ2=176, mat_set_id=mat_hvy  }
, ["VOIDSTEEL"               ] = { name="acier du néant"                 , crafting_type=bs, level_index= 9, material_index=34, master_writ2=180, mat_set_id=mat_hvy  }
, ["RUBEDITE"                ] = { name="cuprite"                        , crafting_type=bs, level_index=10, material_index=40, master_writ2=188, mat_set_id=mat_hvy  }

, ["JUTE"                    ] = { name="artisanales"                    , crafting_type=cl, level_index= 1, material_index= 1, master_writ2=  5, mat_set_id=mat_lgt  , name_2="artisanal"       }
, ["LINEN"                   ] = { name="lin"                            , crafting_type=cl, level_index= 2, material_index= 8, master_writ2= 45, mat_set_id=mat_lgt  }
, ["COTTON"                  ] = { name="coton"                          , crafting_type=cl, level_index= 3, material_index=13, master_writ2= 47, mat_set_id=mat_lgt  }
, ["SPIDERSILK"              ] = { name="soie d'araignée"                , crafting_type=cl, level_index= 4, material_index=18, master_writ2= 49, mat_set_id=mat_lgt  }
, ["EBONTHREAD"              ] = { name="fil d'ébonite"                  , crafting_type=cl, level_index= 5, material_index=23, master_writ2= 51, mat_set_id=mat_lgt  }
, ["KRESH"                   ] = { name="kresh"                          , crafting_type=cl, level_index= 6, material_index=26, master_writ2=125, mat_set_id=mat_lgt  }
, ["IRONTHREAD"              ] = { name="fil de fer"                     , crafting_type=cl, level_index= 7, material_index=29, master_writ2=126, mat_set_id=mat_lgt  , name_2="fil de fer"      }
, ["SILVERWEAVE"             ] = { name="fil d'argent"                   , crafting_type=cl, level_index= 8, material_index=32, master_writ2=127, mat_set_id=mat_lgt  }
, ["SHADOWSPUN"              ] = { name="tissombre"                      , crafting_type=cl, level_index= 9, material_index=34, master_writ2=128, mat_set_id=mat_lgt  }
, ["ANCESTOR_SILK"           ] = { name="soie ancestrales"               , crafting_type=cl, level_index=10, material_index=40, master_writ2=194, mat_set_id=mat_lgt  , name_2="soie ancestral"  }

, ["RAWHIDE"                 ] = { name="cuir brut"                      , crafting_type=cl, level_index= 1, material_index= 1, master_writ2=148, mat_set_id=mat_med  }
, ["HIDE"                    ] = { name="peau"                           , crafting_type=cl, level_index= 2, material_index= 8, master_writ2=154, mat_set_id=mat_med  }
, ["LEATHER"                 ] = { name="cuir"                           , crafting_type=cl, level_index= 3, material_index=13, master_writ2=158, mat_set_id=mat_med  }
, ["FULL_LEATHER"            ] = { name="cuir complet"                   , crafting_type=cl, level_index= 4, material_index=18, master_writ2=162, mat_set_id=mat_med  }
, ["FELL_HIDE"               ] = { name="déchu"                          , crafting_type=cl, level_index= 5, material_index=23, master_writ2=166, mat_set_id=mat_med  }
, ["BRIGANDINE"              ] = { name="cuir clouté"                    , crafting_type=cl, level_index= 6, material_index=26, master_writ2=170, mat_set_id=mat_med  , name_2="brigandine"      }
, ["IRONHIDE"                ] = { name="peau de fer"                    , crafting_type=cl, level_index= 7, material_index=29, master_writ2=174, mat_set_id=mat_med  }
, ["SUPERB"                  ] = { name="superbe"                        , crafting_type=cl, level_index= 8, material_index=32, master_writ2=131, mat_set_id=mat_med  , name_2="superbe"         }
, ["SHADOWHIDE"              ] = { name="peau d'ombre"                   , crafting_type=cl, level_index= 9, material_index=34, master_writ2=132, mat_set_id=mat_med  }
, ["RUBEDO_LEATHER"          ] = { name="cuir pourpre"                   , crafting_type=cl, level_index=10, material_index=40, master_writ2=190, mat_set_id=mat_med  }

, ["MAPLE"                   ] = { name="érable"                         , crafting_type=ww, level_index= 1, material_index= 1, master_writ2=  2, mat_set_id=mat_wood }
, ["OAK"                     ] = { name="chêne"                          , crafting_type=ww, level_index= 2, material_index= 8, master_writ2= 18, mat_set_id=mat_wood }
, ["BEECH"                   ] = { name="hêtre"                          , crafting_type=ww, level_index= 3, material_index=13, master_writ2= 20, mat_set_id=mat_wood }
, ["HICKORY"                 ] = { name="noyer"                          , crafting_type=ww, level_index= 4, material_index=18, master_writ2= 22, mat_set_id=mat_wood }
, ["YEW"                     ] = { name="if"                             , crafting_type=ww, level_index= 5, material_index=23, master_writ2= 24, mat_set_id=mat_wood }
, ["BIRCH"                   ] = { name="bouleau"                        , crafting_type=ww, level_index= 6, material_index=26, master_writ2=133, mat_set_id=mat_wood }
, ["ASH"                     ] = { name="frêne"                          , crafting_type=ww, level_index= 7, material_index=29, master_writ2=134, mat_set_id=mat_wood }
, ["MAHOGANY"                ] = { name="acajou"                         , crafting_type=ww, level_index= 8, material_index=32, master_writ2=135, mat_set_id=mat_wood }
, ["NIGHTWOOD"               ] = { name="bois de nuit"                   , crafting_type=ww, level_index= 9, material_index=34, master_writ2=136, mat_set_id=mat_wood }
, ["RUBY_ASH"                ] = { name="frêne roux"                     , crafting_type=ww, level_index=10, material_index=40, master_writ2=192, mat_set_id=mat_wood }

, ["PEWTER"                  ] = { name="étain"                          , crafting_type=jw, level_index= 1, material_index= 1, master_writ2=  6, mat_set_id=mat_jewl }
, ["COPPER"                  ] = { name="cuivre"                         , crafting_type=jw, level_index= 2, material_index=13, master_writ2= 56, mat_set_id=mat_jewl }
, ["SILVER"                  ] = { name="argent"                         , crafting_type=jw, level_index= 3, material_index=26, master_writ2=137, mat_set_id=mat_jewl }
, ["ELECTRUM"                ] = { name="électrum"                       , crafting_type=jw, level_index= 4, material_index=33, master_writ2=139, mat_set_id=mat_jewl , name_2="électrum"       }
, ["PLATINUM"                ] = { name="platine"                        , crafting_type=jw, level_index= 5, material_index=40, master_writ2=255, mat_set_id=mat_jewl }

, ["BLESSED_THISTLE"         ] = { name="chardon béni"                   , crafting_type=al, item_id= 30157 }
, ["BLUE_ENTOLOMA"           ] = { name="entoloma bleue"                 , crafting_type=al, item_id= 30148 }
, ["BUGLOSS"                 ] = { name="noctuelle"                      , crafting_type=al, item_id= 30160 }
, ["COLUMBINE"               ] = { name="ancolie"                        , crafting_type=al, item_id= 30164 }
, ["CORN_FLOWER"             ] = { name="bleuet"                         , crafting_type=al, item_id= 30161 }
, ["DRAGONTHORN"             ] = { name="épine-de-dragon"                , crafting_type=al, item_id= 30162 }
, ["EMETIC_RUSSULA"          ] = { name="russule émétique"               , crafting_type=al, item_id= 30151 }
, ["IMP_STOOL"               ] = { name="pied-de-lutin"                  , crafting_type=al, item_id= 30156 }
, ["LADYS_SMOCK"             ] = { name="cardamine des prés"             , crafting_type=al, item_id= 30158 }
, ["LUMINOUS_RUSSULA"        ] = { name="russule phosphorescente"        , crafting_type=al, item_id= 30155 }
, ["MOUNTAIN_FLOWER"         ] = { name="lys des cimes"                  , crafting_type=al, item_id= 30163 }
, ["NAMIRAS_ROT"             ] = { name="truffe de Namira"               , crafting_type=al, item_id= 30153 }
, ["NIRNROOT"                ] = { name="nirnrave"                       , crafting_type=al, item_id= 30165 }
, ["STINKHORN"               ] = { name="mutinus elegans"                , crafting_type=al, item_id= 30149 }
, ["VIOLET_COPRINUS"         ] = { name="coprin violet"                  , crafting_type=al, item_id= 30152 , name_2="coprin violet"      }
, ["WATER_HYACINTH"          ] = { name="jacinthe d'eau"                 , crafting_type=al, item_id= 30166 }
, ["WHITE_CAP"               ] = { name="Chapeau blanc"                  , crafting_type=al, item_id= 30154 }
, ["WORMWOOD"                ] = { name="absinthe"                       , crafting_type=al, item_id= 30159 }
, ["BEETLE_SCUTTLE"          ] = { name="cloaque de scarabée"            , crafting_type=al, item_id= 77583 }
, ["BUTTERFLY_WING"          ] = { name="aile de papillon"               , crafting_type=al, item_id= 77585 }
, ["FLESHFLY_LARVA"          ] = { name="larve de mouche à viande"       , crafting_type=al, item_id= 77587 }
, ["MUDCRAB_CHITIN"          ] = { name="chitine de vasard"              , crafting_type=al, item_id= 77591 }
, ["NIGHTSHADE"              ] = { name="Belladone"                      , crafting_type=al, item_id= 77590 }
, ["SCRIB_JELLY"             ] = { name="gelée de scrib"                 , crafting_type=al, item_id= 77589 }
, ["SPIDER_EGG"              ] = { name="œuf d'araignée"                 , crafting_type=al, item_id= 77584 }
, ["TORCHBUG_THORAX"         ] = { name="thorax de flammouche"           , crafting_type=al, item_id= 77581 }
, ["CLAM_GALL"               ] = { name="impureté de palourde"           , crafting_type=al, item_id=139020 }
, ["POWDERED_MOTHER_OF_PEARL"] = { name="poudre de nacre"                , crafting_type=al, item_id=139019 }

, ["NATURAL_WATER"           ] = { name="eau naturelle"                  , crafting_type=al, item_id=   883 , name_2="eau naturelle"      , rank=1, potion_name="gorgée"                  }
, ["CLEAR_WATER"             ] = { name="eau claire"                     , crafting_type=al, item_id=  1187                               , rank=2, potion_name="teinture"                }
, ["PRISTINE_WATER"          ] = { name="eau limpide"                    , crafting_type=al, item_id=  4570 , name_2="eau limpide"        , rank=3, potion_name="goutte"                  , potion_name2="goutte"                   }
, ["CLEANSED_WATER"          ] = { name="eau assainie"                   , crafting_type=al, item_id= 23265 , name_2="eau assainie"       , rank=4, potion_name="potion"                  }
, ["FILTERED_WATER"          ] = { name="eau filtrée"                    , crafting_type=al, item_id= 23266 , name_2="eau filtrée"        , rank=5, potion_name="solution"                }
, ["PURIFIED_WATER"          ] = { name="eau purifiée"                   , crafting_type=al, item_id= 23267 , name_2="eau purifiée"       , rank=6, potion_name="élixir"                  }
, ["CLOUD_MIST"              ] = { name="brume"                          , crafting_type=al, item_id= 23268                               , rank=7, potion_name="panacée"                 }
, ["STAR_DEW"                ] = { name="rosée stellaire"                , crafting_type=al, item_id= 64500                               , rank=8, potion_name="distillat"               }
, ["LORKHANS_TEARS"          ] = { name="larmes de Lorkhan"              , crafting_type=al, item_id= 64501                               , rank=9, potion_name="essence"                 }

, ["GREASE"                  ] = { name="graisse"                        , crafting_type=al, item_id= 75357                               , rank=1, poison_name="i"                       }
, ["ICHOR"                   ] = { name="sanie"                          , crafting_type=al, item_id= 75358                               , rank=2, poison_name="ii"                      }
, ["SLIME"                   ] = { name="fluide visqueux"                , crafting_type=al, item_id= 75359                               , rank=3, poison_name="iii"                     }
, ["GALL"                    ] = { name="bile"                           , crafting_type=al, item_id= 75360                               , rank=4, poison_name="iv"                      }
, ["TEREBINTHINE"            ] = { name="térébenthine"                   , crafting_type=al, item_id= 75361                               , rank=5, poison_name="v"                       }
, ["PITCH_BILE"              ] = { name="bile-poix"                      , crafting_type=al, item_id= 75362                               , rank=6, poison_name="vi"                      }
, ["TARBLACK"                ] = { name="goudron"                        , crafting_type=al, item_id= 75363                               , rank=7, poison_name="vii"                     }
, ["NIGHT_OIL"               ] = { name="nocthuile"                      , crafting_type=al, item_id= 75364                               , rank=8, poison_name="viii"                    }
, ["ALKAHEST"                ] = { name="alcaleste"                      , crafting_type=al, item_id= 75365                               , rank=9, poison_name="ix"                      }

, ["JORA"                    ] = { name="Jora"                           , crafting_type=en, item_id= 45855 , name_2="insignifiant"  }
, ["PORADE"                  ] = { name="Porade"                         , crafting_type=en, item_id= 45856 }
, ["JERA"                    ] = { name="Jéra"                           , crafting_type=en, item_id= 45857 , name_2="petit"         }
, ["JEJORA"                  ] = { name="Jéjora"                         , crafting_type=en, item_id= 45806 }
, ["ODRA"                    ] = { name="Odra"                           , crafting_type=en, item_id= 45807 , name_2="mineur"        }
, ["POJORA"                  ] = { name="Pojora"                         , crafting_type=en, item_id= 45808 }
, ["EDORA"                   ] = { name="Edora"                          , crafting_type=en, item_id= 45809 , name_2="modéré"        }
, ["JAERA"                   ] = { name="Jaera"                          , crafting_type=en, item_id= 45810 }
, ["PORA"                    ] = { name="Pora"                           , crafting_type=en, item_id= 45811 , name_2="fort"          }
, ["DENARA"                  ] = { name="Dénara"                         , crafting_type=en, item_id= 45812 }
, ["RERA"                    ] = { name="Réra"                           , crafting_type=en, item_id= 45813 , name_2="majeur"        }
, ["DERADO"                  ] = { name="Dérado"                         , crafting_type=en, item_id= 45814 , name_2="grandiose"    , name_3="grandiose"      }
, ["REKURA"                  ] = { name="Rekura"                         , crafting_type=en, item_id= 45815 , name_2="splendide"     }
, ["KURA"                    ] = { name="Kura"                           , crafting_type=en, item_id= 45816 , name_2="monumental"    }
, ["REJERA"                  ] = { name="Rejera"                         , crafting_type=en, item_id= 64509 , name_2="superbe"       }
, ["REPORA"                  ] = { name="Repora"                         , crafting_type=en, item_id= 68341 , name_2="vraiment superbe"}

, ["JODE"                    ] = { name="Jode"                           , crafting_type=en, item_id= 45817 }
, ["NOTADE"                  ] = { name="Notade"                         , crafting_type=en, item_id= 45818 }
, ["ODE"                     ] = { name="Ode"                            , crafting_type=en, item_id= 45819 }
, ["TADE"                    ] = { name="Tade"                           , crafting_type=en, item_id= 45820 }
, ["JAYDE"                   ] = { name="Jayde"                          , crafting_type=en, item_id= 45821 }
, ["EDODE"                   ] = { name="Edode"                          , crafting_type=en, item_id= 45822 }
, ["POJODE"                  ] = { name="Pojode"                         , crafting_type=en, item_id= 45823 }
, ["REKUDE"                  ] = { name="Rekudé"                         , crafting_type=en, item_id= 45824 }
, ["HADE"                    ] = { name="Hade"                           , crafting_type=en, item_id= 45825 }
, ["IDODE"                   ] = { name="Idode"                          , crafting_type=en, item_id= 45826 }
, ["PODE"                    ] = { name="Pode"                           , crafting_type=en, item_id= 45827 }
, ["KEDEKO"                  ] = { name="Kédéko"                         , crafting_type=en, item_id= 45828 }
, ["REDE"                    ] = { name="Rede"                           , crafting_type=en, item_id= 45829 }
, ["KUDE"                    ] = { name="Kudé"                           , crafting_type=en, item_id= 45830 }
, ["JEHADE"                  ] = { name="Jehade"                         , crafting_type=en, item_id= 64508 }
, ["ITADE"                   ] = { name="Itade"                          , crafting_type=en, item_id= 68340 }

, ["DEKEIPA"                 ] = { name="Dekeïpa"                        , crafting_type=en, item_id= 45839 , add="givré"            , sub="de résistance au givre"}
, ["DENI"                    ] = { name="Deni"                           , crafting_type=en, item_id= 45833 , add="vigoureux"        , sub="d'absorption de vigueur", add_2="Vigueur"             }
, ["DENIMA"                  ] = { name="Denima"                         , crafting_type=en, item_id= 45836 , add="revigorant"       , sub="du virtuose"       }
, ["DETERI"                  ] = { name="Deteri"                         , crafting_type=en, item_id= 45842 , add="robuste"          , sub="contondant"        }
, ["HAOKO"                   ] = { name="Haoko"                          , crafting_type=en, item_id= 45841 , add="odieux"           , sub="de résistance à la maladie"}
, ["HAKEIJO"                 ] = { name="Hakeijo"                        , crafting_type=en, item_id= 68342 , add="de défense prismatique", sub="d'assaut prismatique"}
, ["KADERI"                  ] = { name="Kadéri"                         , crafting_type=en, item_id= 45849 , add="percutant"        , sub="blindé"            }
, ["KUOKO"                   ] = { name="Kuoko"                          , crafting_type=en, item_id= 45837 , add="empoisonné"       , sub="de résistance au poison"}
, ["MAKDERI"                 ] = { name="Makdéri"                        , crafting_type=en, item_id= 45848 , add="de puissance magique", sub="de résistance magique"}
, ["MAKKO"                   ] = { name="Makko"                          , crafting_type=en, item_id= 45832 , add="magique"          , sub="d'absorption de magie", add_2="magie"               }
, ["MAKKOMA"                 ] = { name="Makkoma"                        , crafting_type=en, item_id= 45835 , add="régénérant"       , sub="du mage"           }
, ["MEIP"                    ] = { name="Méip"                           , crafting_type=en, item_id= 45840 , add="étourdissant"     , sub="isolé"             }
, ["OKO"                     ] = { name="Oko"                            , crafting_type=en, item_id= 45831 , add="vital"            , sub="sangsue"          , add_2="Santé"               }
, ["OKOMA"                   ] = { name="Okoma"                          , crafting_type=en, item_id= 45834 , add="revivifiant"      , sub="de santé déclinante"}
, ["OKORI"                   ] = { name="Okori"                          , crafting_type=en, item_id= 45843 , add="de dégâts d'arme" , sub="affaiblissant"     }
, ["ORU"                     ] = { name="Oru"                            , crafting_type=en, item_id= 45846 , add="de l'alchimiste"  , sub="d'accélération des potions"}
, ["RAKEIPA"                 ] = { name="Rakeïpa"                        , crafting_type=en, item_id= 45838 , add="ardent"           , sub="ignifugé"          }
, ["TADERI"                  ] = { name="Taderi"                         , crafting_type=en, item_id= 45847 , add="de puissance physique", sub="de résistance physique"}

, ["TA"                      ] = { name="Ta"                             , crafting_type=en, item_id= 45850 , name_2="Normal"   }
, ["JEJOTA"                  ] = { name="Jéjota"                         , crafting_type=en, item_id= 45851 , name_2="Raffiné"  }
, ["DENATA"                  ] = { name="Denata"                         , crafting_type=en, item_id= 45852 , name_2="Supérieur"}
, ["REKUTA"                  ] = { name="Rekuta"                         , crafting_type=en, item_id= 45853 , name_2="Épique"   }
, ["KUTA"                    ] = { name="Kuta"                           , crafting_type=en, item_id= 45854 , name_2="Légendaire"}

, ["QUARTZ"                  ] = { name="quartz"                         ,                   item_id=  4456 }
, ["DIAMOND"                 ] = { name="diamant"                        ,                   item_id= 23219 }
, ["SARDONYX"                ] = { name="sardonyx"                       ,                   item_id= 30221 }
, ["ALMANDINE"               ] = { name="almandine"                      ,                   item_id= 23221 }
, ["EMERALD"                 ] = { name="émeraude"                       ,                   item_id=  4442 }
, ["BLOODSTONE"              ] = { name="pierre de sang"                 ,                   item_id= 30219 }
, ["GARNET"                  ] = { name="grenat"                         ,                   item_id= 23171 }
, ["SAPPHIRE"                ] = { name="saphir"                         ,                   item_id= 23173 }
, ["FORTIFIED_NIRNCRUX"      ] = { name="nirncrux fortifié"              ,                   item_id= 56862 }
, ["CHYSOLITE"               ] = { name="chrysolite"                     ,                   item_id= 23203 }
, ["AMETHYST"                ] = { name="améthyste"                      ,                   item_id= 23204 }
, ["RUBY"                    ] = { name="rubis"                          ,                   item_id=  4486 }
, ["JADE"                    ] = { name="jade"                           ,                   item_id=   810 }
, ["TURQUOISE"               ] = { name="turquoise"                      ,                   item_id=   813 }
, ["CARNELIAN"               ] = { name="cornaline"                      ,                   item_id= 23165 }
, ["FIRE_OPAL"               ] = { name="opale de feu"                   ,                   item_id= 23149 }
, ["CITRINE"                 ] = { name="citrine"                        ,                   item_id= 16291 }
, ["POTENT_NIRNCRUX"         ] = { name="nirncrux puissant"              ,                   item_id= 56863 }
, ["COBALT"                  ] = { name="cobalt"                         ,                   item_id=135155 }
, ["ANTIMONY"                ] = { name="antimoine"                      ,                   item_id=135156 }
, ["ZINC"                    ] = { name="zinc"                           ,                   item_id=135157 }
, ["DAWN_PRISM"              ] = { name="prisme d'aube"                  ,                   item_id=139409 }
, ["DIBELLIUM"               ] = { name="dibellium"                      ,                   item_id=139413 }
, ["GILDING_WAX"             ] = { name="cire dorée"                     ,                   item_id=139412 }
, ["AURBIC_AMBER"            ] = { name="ambre aurbique"                 ,                   item_id=139411 }
, ["TITANIUM"                ] = { name="titane"                         ,                   item_id=139410 }
, ["SLAUGHTERSTONE"          ] = { name="pierre de massacre"             ,                   item_id=139414 }

}


-- Equipment Traits ----------------------------------------------------------
--
-- For master writ quests that require Nirnhoned or whatever.
--
local ts=LibCraftText.TRAIT_SET_ID -- for less typing
local m =LibCraftText.MATERIAL
LibCraftText.TRAIT = {
    ["WEAPON_POWERED"      ] = { name="Énergisé"                    , trait_set_id=ts.WEAPON  , trait_index=1 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_POWERED          or  1 , material=m.CHYSOLITE          }
,   ["WEAPON_CHARGED"      ] = { name="Chargé"                      , trait_set_id=ts.WEAPON  , trait_index=2 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_CHARGED          or  2 , material=m.AMETHYST           }
,   ["WEAPON_PRECISE"      ] = { name="Précis"                      , trait_set_id=ts.WEAPON  , trait_index=3 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_PRECISE          or  3 , material=m.RUBY               }
,   ["WEAPON_INFUSED"      ] = { name="Infusé"                      , trait_set_id=ts.WEAPON  , trait_index=4 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_INFUSED          or  4 , material=m.JADE               }
,   ["WEAPON_DEFENDING"    ] = { name="Défenseur"                   , trait_set_id=ts.WEAPON  , trait_index=5 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_DEFENDING        or  5 , material=m.TURQUOISE          }
,   ["WEAPON_TRAINING"     ] = { name="Entraînement"                , trait_set_id=ts.WEAPON  , trait_index=6 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_TRAINING         or  6 , material=m.CARNELIAN          }
,   ["WEAPON_SHARPENED"    ] = { name="Acéré"                       , trait_set_id=ts.WEAPON  , trait_index=7 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_SHARPENED        or  7 , material=m.FIRE_OPAL          }
,   ["WEAPON_DECISIVE"     ] = { name="Décisif"                     , trait_set_id=ts.WEAPON  , trait_index=8 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_DECISIVE         or  8 , material=m.CITRINE            }
,   ["WEAPON_NIRNHONED"    ] = { name="Trempe de Nirn"              , trait_set_id=ts.WEAPON  , trait_index=9 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_NIRNHONED        or 26 , material=m.POTENT_NIRNCRUX    }

,   ["ARMOR_STURDY"        ] = { name="Solide"                      , trait_set_id=ts.ARMOR   , trait_index=1 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_STURDY            or 11 , material=m.QUARTZ             }
,   ["ARMOR_IMPENETRABLE"  ] = { name="Impénétrable"                , trait_set_id=ts.ARMOR   , trait_index=2 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE      or 12 , material=m.DIAMOND            }
,   ["ARMOR_REINFORCED"    ] = { name="Renforcé"                    , trait_set_id=ts.ARMOR   , trait_index=3 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_REINFORCED        or 13 , material=m.SARDONYX           }
,   ["ARMOR_WELL_FITTED"   ] = { name="Ajusté"                      , trait_set_id=ts.ARMOR   , trait_index=4 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED       or 14 , material=m.ALMANDINE          }
,   ["ARMOR_TRAINING"      ] = { name="Entraînement"                , trait_set_id=ts.ARMOR   , trait_index=5 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_TRAINING          or 15 , material=m.EMERALD            }
,   ["ARMOR_INFUSED"       ] = { name="Infusé"                      , trait_set_id=ts.ARMOR   , trait_index=6 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_INFUSED           or 16 , material=m.BLOODSTONE         }
,   ["ARMOR_INVIGORATING"  ] = { name="Revigorant"                  , trait_set_id=ts.ARMOR   , trait_index=7 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_INVIGORATING      or 17 , material=m.GARNET             }
,   ["ARMOR_DIVINES"       ] = { name="Divins"                      , trait_set_id=ts.ARMOR   , trait_index=8 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_DIVINES           or 18 , material=m.SAPPHIRE           }
,   ["ARMOR_NIRNHONED"     ] = { name="Trempe de Nirn"              , trait_set_id=ts.ARMOR   , trait_index=9 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_NIRNHONED         or 25 , material=m.FORTIFIED_NIRNCRUX }

,   ["JEWELRY_ARCANE"      ] = { name="Arcane"                      , trait_set_id=ts.JEWELRY , trait_index=1 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_ARCANE          or 22 , material=m.COBALT             }
,   ["JEWELRY_HEALTHY"     ] = { name="Sain"                        , trait_set_id=ts.JEWELRY , trait_index=2 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_HEALTHY         or 21 , material=m.ANTIMONY           }
,   ["JEWELRY_ROBUST"      ] = { name="Robuste"                     , trait_set_id=ts.JEWELRY , trait_index=3 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_ROBUST          or 23 , material=m.ZINC               }
,   ["JEWELRY_TRIUNE"      ] = { name="Triun"                       , trait_set_id=ts.JEWELRY , trait_index=4 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_TRIUNE          or 30 , material=m.DAWN_PRISM         }
,   ["JEWELRY_INFUSED"     ] = { name="Infusé"                      , trait_set_id=ts.JEWELRY , trait_index=5 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_INFUSED         or 33 , material=m.AURBIC_AMBER       }
,   ["JEWELRY_PROTECTIVE"  ] = { name="Protecteur"                  , trait_set_id=ts.JEWELRY , trait_index=6 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE      or 32 , material=m.TITANIUM           }
,   ["JEWELRY_SWIFT"       ] = { name="Vif"                         , trait_set_id=ts.JEWELRY , trait_index=7 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_SWIFT           or 28 , material=m.GILDING_WAX        }
,   ["JEWELRY_HARMONY"     ] = { name="Harmonieux"                  , trait_set_id=ts.JEWELRY , trait_index=8 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_HARMONY         or 29 , material=m.DIBELLIUM          }
,   ["JEWELRY_BLOODTHIRSTY"] = { name="Assoiffé de sang"            , trait_set_id=ts.JEWELRY , trait_index=9 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY    or 31 , material=m.SLAUGHTERSTONE     }

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
    ["RESTORE_HEALTH"         ] = { trait_index=01, name="Rend de la Santé"         , master_potion="essence de Santé"                  , master_poison="Poison de drain de Santé IX"       , daily_potion_name="santé"                        , daily_poison_name="drain de santé"               }
,   ["RAVAGE_HEALTH"          ] = { trait_index=02, name="Réduit la Santé"          , master_potion="essence de ravage de Santé"        , master_poison="Poison de ravage de Santé IX"      , daily_potion_name="ravage de santé"              , daily_poison_name="ravage de santé"              , daily_poison_name2="Dégâts de Santé"              }
,   ["RESTORE_MAGICKA"        ] = { trait_index=03, name="Rend de la Magie"         , master_potion="essence de Magie"                  , master_poison="Poison de drain de Magie IX"       , daily_potion_name="magie"                        , daily_poison_name="drain de magie"               }
,   ["RAVAGE_MAGICKA"         ] = { trait_index=04, name="Réduit la Magie"          , master_potion="essence de ravage de Magie"        , master_poison="Poison de ravage de Magie IX"      , daily_potion_name="ravage de magie"              , daily_poison_name="ravage de magie"              , daily_poison_name2="Dégâts de Magie"               }
,   ["RESTORE_STAMINA"        ] = { trait_index=05, name="Rend de la Vigueur"       , master_potion="essence de Vigueur"                , master_poison="Poison de drain de Vigueur IX"     , daily_potion_name="vigueur"                      , daily_poison_name="drain de vigueur"             }
,   ["RAVAGE_STAMINA"         ] = { trait_index=06, name="Ravage de Vigueur"        , master_potion="essence de ravage de Vigueur"      , master_poison="Poison de ravage de Vigueur IX"    , daily_potion_name="ravage de vigueur"            , daily_poison_name="ravage de vigueur"            , daily_poison_name2="Dégâts de Vigueur"             }
,   ["SPELL_RESISTANCE"       ] = { trait_index=07, name="Augmente la résistance aux sorts", master_potion="essence de protection contre les sorts", master_poison="Poison de drain de Protection IX"  }
,   ["BREACH"                 ] = { trait_index=08, name="Brèche"                   , master_potion="essence de ravage de protection contre les sorts", master_poison="Poison de brèche IX"               }
,   ["INCREASE_ARMOR"         ] = { trait_index=09, name="Augmente l'armure"        , master_potion="essence d’armure"                  , master_poison="Poison de drain de Résolution IX"  }
,   ["FRACTURE"               ] = { trait_index=10, name="Fracture"                 , master_potion="essence de ravage d'armure"        , master_poison="Poison de fracture IX"             }
,   ["INCREASE_SPELL_POWER"   ] = { trait_index=11, name="Augmente la puissance des sorts", master_potion="essence de puissance de sort"      , master_poison="Poison de drain de Sorcellerie IX" }
,   ["COWARDICE"              ] = { trait_index=12, name="Couardise"                , master_potion="essence de couardise"              , master_poison="Poison de lâcheté IX"              }
,   ["INCREASE_WEAPON_POWER"  ] = { trait_index=13, name="Augmente la puissance de l'arme", master_potion="essence de puissance d'arme"       , master_poison="Poison de drain de Brutalité IX"   }
,   ["MAIM"                   ] = { trait_index=14, name="Mutilation"               , master_potion="essence de mutilation"             , master_poison="Poison de Mutilation IX"           }
,   ["SPELL_CRITICAL"         ] = { trait_index=15, name="Critique de sorts"        , master_potion="essence de critique des sorts"     , master_poison="Poison de drain de Prophécie IX"   }
,   ["UNCERTAINTY"            ] = { trait_index=16, name="Incertitude"              , master_potion="essence d’incertitude"             , master_poison="Poison d'Incertitude IX"           }
,   ["WEAPON_CRITICAL"        ] = { trait_index=17, name="Critique d'armes"         , master_potion="essence de critique d'arme"        , master_poison="Poison de drain de Sauvagerie IX"  }
,   ["ENERVATION"             ] = { trait_index=18, name="Affaiblissement"          , master_potion="essence d’affaiblissement"         , master_poison="Poison d'Affaiblissement IX"       }
,   ["UNSTOPPABLE"            ] = { trait_index=19, name="Implacable"               , master_potion="essence d’Immuabilité"             , master_poison="Poison du monte-en-l'air IX"       }
,   ["ENTRAPMENT"             ] = { trait_index=20, name="Capture"                  , master_potion="essence de capture"                , master_poison="Poison d'Entrave IX"               }
,   ["DETECTION"              ] = { trait_index=21, name="de détection"             , master_potion="essence de détection"              , master_poison="Poison de drain de Furtivité IX"   }
,   ["INVISIBLE"              ] = { trait_index=22, name="invisible"                , master_potion="essence d’Invisibilité"            , master_poison="Poison révélateur IX"              }
,   ["SPEED"                  ] = { trait_index=23, name="Vitesse"                  , master_potion="essence de vitesse"                , master_poison="Poison de drain de vitesse IX"     }
,   ["HINDRANCE"              ] = { trait_index=24, name="Entrave"                  , master_potion="essence d’entravant"               , master_poison="Poison ralentissant IX"            }
,   ["PROTECTION"             ] = { trait_index=25, name="Protection"               , master_potion="essence de Protection"             , master_poison="Poison inverseur de protection IX" }
,   ["VULNERABILITY"          ] = { trait_index=26, name="Vulnérabilité"            , master_potion="essence de vulnérabilité"          , master_poison="Poison de vulnérabilité IX"        }
,   ["LINGERING_HEALTH"       ] = { trait_index=27, name="Santé persistante"        , master_potion="essence de Santé pérenne"          , master_poison="Poison de drain graduel de Santé IX"}
,   ["GRADUAL_RAVAGE_HEALTH"  ] = { trait_index=28, name="Ravage de Santé graduel"  , master_potion="essence de Ravage de Santé rampante", master_poison="Poison de ravage graduel de Santé IX"}
,   ["VITALITY"               ] = { trait_index=29, name="Vitalité"                 , master_potion="essence de vitalité"               , master_poison="Poison de drain de Vitalité IX"    }
,   ["DEFILE"                 ] = { trait_index=30, name="Profanation"              , master_potion="essence d’Avilissement"            , master_poison="Poison profanateur IX"             }
}


-- Craftable Sets ------------------------------------------------------------
--
-- set_id       writ4 field for master writs
--
LibCraftText.SET = {
    ["ADEPT_RIDER"              ] = { name="l’Adepte cavalier"          , set_id=385 }
,   ["ALESSIAS_BULWARK"         ] = { name="le Rempart d'Alessia"       , set_id= 82 }
,   ["ARMOR_MASTER"             ] = { name="Maître armurier"            , set_id=178 }
,   ["ARMOR_OF_THE_SEDUCER"     ] = { name="l’Armure de la séductrice"  , set_id= 43 }
,   ["ASHEN_GRIP"               ] = { name="la Poigne de cendres"       , set_id= 54 }
,   ["ASSASSINS_GUILE"          ] = { name="la Duplicité de l'assassin" , set_id=323 }
,   ["CLEVER_ALCHEMIST"         ] = { name="Alchimiste astucieux"       , set_id=225 }
,   ["DAEDRIC_TRICKERY"         ] = { name="la Tromperie daedrique"     , set_id=324 }
,   ["DEATHS_WIND"              ] = { name="le Vent mortel"             , set_id= 37 }
,   ["ETERNAL_HUNT"             ] = { name="Chasse éternelle"           , set_id=226 }
,   ["EYES_OF_MARA"             ] = { name="les Yeux de Mara"           , set_id= 87 }
,   ["FORTIFIED_BRASS"          ] = { name="Airain fortifié"            , set_id=352 }
,   ["GRAVE_STAKE_COLLECTOR"    ] = { name="Collectionneur de marqueurs funéraires", set_id=408 }
,   ["HIST_BARK"                ] = { name="l’Écorce d'Hist"            , set_id= 78 }
,   ["HUNDINGS_RAGE"            ] = { name="la Rage de Hunding"         , set_id= 80 }
,   ["INNATE_AXIOM"             ] = { name="Axiome inné"                , set_id=351 }
,   ["KAGRENACS_HOPE"           ] = { name="l’Espoir de Kagrenac"       , set_id= 92 }
,   ["KVATCH_GLADIATOR"         ] = { name="le gladiateur de Kvatch"    , set_id=240 }
,   ["LAW_OF_JULIANOS"          ] = { name="Loi de Julianos"            , set_id=207 }
,   ["MAGNUS_GIFT"              ] = { name="le Présent de Magnus"       , set_id= 48 }
,   ["MECHANICAL_ACUITY"        ] = { name="Acuité mécanique"           , set_id=353 }
,   ["MIGHT_OF_THE_LOST_LEGION" ] = { name="la Puissance de la Légion perdue", set_id=410 }
,   ["MORKULDIN"                ] = { name="Morkuldin"                  , set_id=219 }
,   ["NAGA_SHAMAN"              ] = { name="le Chaman Naga"             , set_id=409 }
,   ["NIGHT_MOTHERS_GAZE"       ] = { name="le Regard de la Mère de la nuit", set_id= 51 }
,   ["NIGHTS_SILENCE"           ] = { name="le Silence de la nuit"      , set_id= 40 }
,   ["NOBLES_CONQUEST"          ] = { name="le Butin du noble"          , set_id=176 }
,   ["NOCTURNALS_FAVOR"         ] = { name="Faveur de Nocturne"         , set_id=387 }
,   ["OBLIVIONS_FOE"            ] = { name="l’Adversaire d'Oblivion"    , set_id= 73 }
,   ["ORGNUMS_SCALES"           ] = { name="les Écailles d'Orgnum"      , set_id= 84 }
,   ["PELINALS_APTITUDE"        ] = { name="l’Aptitude de Pélinal"      , set_id=242 }
,   ["REDISTRIBUTOR"            ] = { name="Redistributeur"             , set_id=177 }
,   ["SHACKLEBREAKER"           ] = { name="le Brise-entraves"          , set_id=325 }
,   ["SHALIDORS_CURSE"          ] = { name="la Malédiction de Shalidor" , set_id= 95 }
,   ["SLOADS_SEMBLANCE"         ] = { name="l’Aspect du Sload"          , set_id=386 }
,   ["SONG_OF_LAMAE"            ] = { name="le Chant de Lamae"          , set_id= 81 }
,   ["SPECTRES_EYE"             ] = { name="l’Œil du spectre"           , set_id= 74 }
,   ["TAVAS_FAVOR"              ] = { name="Faveur de Tava"             , set_id=224 }
,   ["TORUGS_PACT"              ] = { name="le Pacte de Torug"          , set_id= 75 }
,   ["TRIAL_BY_FIRE"            ] = { name="Épreuve du feu"             , set_id=208 }
,   ["TWICE_BORN_STAR"          ] = { name="Étoile gémellaire"          , set_id=161 }
,   ["TWILIGHTS_EMBRACE"        ] = { name="l’Étreinte du crépuscule"   , set_id= 38 }
,   ["VAMPIRES_KISS"            ] = { name="le Baiser du vampire"       , set_id= 44 }
,   ["VARENS_LEGACY"            ] = { name="l’Héritage de Varen"        , set_id=241 }
,   ["WAY_OF_THE_ARENA"         ] = { name="la Voie de l'arène"         , set_id=148 }
,   ["WHITESTRAKES_RETRIBUTION" ] = { name="la Rétribution de Blancserpent", set_id= 41 }
,   ["WILLOWS_PATH"             ] = { name="le Sentier des saules"      , set_id= 79 }
}

-- Craftable Motifs ----------------------------------------------------------
--
-- writ6 field for master writs
--
LibCraftText.MOTIF = {
    ["BRETON"             ] = { name="Bréton"               , motif_id=  1 }
,   ["REDGUARD"           ] = { name="Rougegarde"           , motif_id=  2 }
,   ["ORC"                ] = { name="Orque"                , motif_id=  3 }
,   ["DARK_ELF"           ] = { name="Elfe noir"            , motif_id=  4 }
,   ["NORD"               ] = { name="Nordique"             , motif_id=  5 }
,   ["ARGONIAN"           ] = { name="Argonien"             , motif_id=  6 }
,   ["HIGH_ELF"           ] = { name="Haut-elfe"            , motif_id=  7 }
,   ["WOOD_ELF"           ] = { name="Elfe des bois"        , motif_id=  8 }
,   ["KHAJIIT"            ] = { name="Khajiit"              , motif_id=  9 }
,   ["UNIQUE"             ] = { name="Unique"               , motif_id= 10 }
,   ["THIEVES_GUILD"      ] = { name="Guilde des voleurs"   , motif_id= 11 }
,   ["DARK_BROTHERHOOD"   ] = { name="Confrérie noire"      , motif_id= 12 }
,   ["MALACATH"           ] = { name="Malacath"             , motif_id= 13 }
,   ["DWEMER"             ] = { name="Dwemer"               , motif_id= 14 }
,   ["ANCIENT_ELF"        ] = { name="Elfe antique"         , motif_id= 15 }
,   ["ORDER_OF_THE_HOUR"  ] = { name="Ordre des Heures"     , motif_id= 16 }
,   ["BARBARIC"           ] = { name="Barbare"              , motif_id= 17 }
,   ["BANDIT"             ] = { name="Bandit"               , motif_id= 18 }
,   ["PRIMAL"             ] = { name="Primitif"             , motif_id= 19 }
,   ["DAEDRIC"            ] = { name="Daedrique"            , motif_id= 20 }
,   ["TRINIMAC"           ] = { name="Trinimac"             , motif_id= 21 }
,   ["ANCIENT_ORC"        ] = { name="Orque ancien"         , motif_id= 22 }
,   ["DAGGERFALL_COVENANT"] = { name="Alliance de Daguefilante", motif_id= 23 }
,   ["EBONHEART_PACT"     ] = { name="Pacte de Cœurébène"   , motif_id= 24 }
,   ["ALDMERI_DOMINION"   ] = { name="Domaine aldmeri"      , motif_id= 25 }
,   ["MERCENARY"          ] = { name="Mercenaire"           , motif_id= 26 }
,   ["CELESTIAL"          ] = { name="Céleste"              , motif_id= 27 }
,   ["GLASS"              ] = { name="Verre"                , motif_id= 28 }
,   ["XIVKYN"             ] = { name="Xivkyn"               , motif_id= 29 }
,   ["SOUL_SHRIVEN"       ] = { name="Absous"               , motif_id= 30 }
,   ["DRAUGR"             ] = { name="Draugr"               , motif_id= 31 }
,   ["MAORMER"            ] = { name="Maormer"              , motif_id= 32 }
,   ["AKAVIRI"            ] = { name="Akavirois"            , motif_id= 33 }
,   ["IMPERIAL"           ] = { name="Impérial"             , motif_id= 34 }
,   ["YOKUDAN"            ] = { name="Yokudan"              , motif_id= 35 }
,   ["UNIVERSAL"          ] = { name="Universel"            , motif_id= 36 }
,   ["REACH_WINTER"       ] = { name="Hiver de la Crevasse" , motif_id= 37 }
,   ["TSAESCI"            ] = { name="Tsaesci"              , motif_id= 38 }
,   ["MINOTAUR"           ] = { name="Minotaure"            , motif_id= 39 }
,   ["EBONY"              ] = { name="Ébonite"              , motif_id= 40 }
,   ["ABAHS_WATCH"        ] = { name="Garde d'Abah"         , motif_id= 41 }
,   ["SKINCHANGER"        ] = { name="Changepeau"           , motif_id= 42 }
,   ["MORAG_TONG"         ] = { name="Morag Tong"           , motif_id= 43 }
,   ["RA_GADA"            ] = { name="Ra Gada"              , motif_id= 44 }
,   ["DRO_MATHRA"         ] = { name="Dro-m'Athra"          , motif_id= 45 }
,   ["ASSASSINS_LEAGUE"   ] = { name="Ligue des assassins"  , motif_id= 46 }
,   ["OUTLAW"             ] = { name="Hors-la-loi"          , motif_id= 47 }
,   ["REDORAN"            ] = { name="Redoran"              , motif_id= 48 }
,   ["HLAALU"             ] = { name="Hlaalu"               , motif_id= 49 }
,   ["MILITANT_ORDINATOR" ] = { name="Ordonnateur militant" , motif_id= 50 }
,   ["TELVANNI"           ] = { name="Telvanni"             , motif_id= 51 }
,   ["BUOYANT_ARMIGER"    ] = { name="Exalté"               , motif_id= 52 }
,   ["FROSTCASTER"        ] = { name="Lancegivre"           , motif_id= 53 }
,   ["ASHLANDER"          ] = { name="Cendrais"             , motif_id= 54 }
,   ["WORM_CULT"          ] = { name="Culte du Ver"         , motif_id= 55 }
,   ["SILKEN_RING"        ] = { name="Anneau de soie"       , motif_id= 56 }
,   ["MAZZATUN"           ] = { name="Mazzatun"             , motif_id= 57 }
,   ["GRIM_HARLEQUIN"     ] = { name="Sinistre Arlequin"    , motif_id= 58 }
,   ["HOLLOWJACK"         ] = { name="Hallowjack"           , motif_id= 59 }
,   ["REFABRICATED"       ] = { name="Refabriqué"           , motif_id= 60 }
,   ["BLOODFORGE"         ] = { name="Forgesang"            , motif_id= 61 }
,   ["DREADHORN"          ] = { name="Corneffroi"           , motif_id= 62 }
,   ["APOSTLE"            ] = { name="Apôtre"               , motif_id= 65 }
,   ["EBONSHADOW"         ] = { name="Ombrébène"            , motif_id= 66 }
,   ["UNDAUNTED"          ] = { name="Indomptables"         , motif_id= 67 }
,   ["USE_ME"             ] = { name="USE ME"               , motif_id= 68 }
,   ["FANG_LAIR"          ] = { name="Repaire du croc"      , motif_id= 69 }
,   ["SCALECALLER"        ] = { name="Mandécailles"         , motif_id= 70 }
,   ["PSIJIC_ORDER"       ] = { name="Ordre psijique"       , motif_id= 71 }
,   ["SAPIARCH"           ] = { name="Sapiarque"            , motif_id= 72 }
,   ["WELKYNAR"           ] = { name="Welkynar"             , motif_id= 73 }
,   ["DREMORA"            ] = { name="Drémora"              , motif_id= 74 }
,   ["PYANDONEAN"         ] = { name="Pyandonéen"           , motif_id= 75 }
,   ["DIVINE_PROSECUTION" ] = { name="Poursuite divine"     , motif_id= 76 }
,   ["HUNTSMAN"           ] = { name="Chasseur"             , motif_id= 77 }
,   ["SILVER_DAWN"        ] = { name="Aube d'argent"        , motif_id= 78 }
,   ["DEAD_WATER"         ] = { name="Aiguemortes"          , motif_id= 79 }
,   ["HONOR_GUARD"        ] = { name="garde prétorienne"    , motif_id= 80 }
,   ["ELDER_ARGONIAN"     ] = { name="Aînés argoniens"      , motif_id= 81 }
}


-- Miscellaneous conditions --------------------------------------------------

LibCraftText.DAILY.COND = {
    HINT_PR_BREWERS_COOKS_RECIPES = "Les brasseurs et cuisiniers peuvent fournir des recettes"
,   DELIVER_GOODS_SUBSTRING       = "Livrez les marchandises"
,   DELIVER_NEAREST_QUARTERMASTER = "Livrez les marchandises au quartier-maître le plus proche"
,   DELIVER_ALLIANCE_DEPOT        = "Deliver Goods to Alliance Supply Depot"
,   DELIVER_CONSORTIUM_TRADEPOST  = "Deliver Goods to Consortium Tradepost"
,   DELIVER_REFUGEE_RELIEF        = "Deliver Goods to Refugee Relief Site"
,   DELIVER_FIGHTERS_GUILD        = "Deliver Goods to Fighters Guild Provisioner"
}

LibCraftText.MASTER.COND = {
    TRAVEL_AD       = "Allez rencontrer votre contact à Faneracine" -- "Travel to Elden Root to Meet Your Contact"
,   TRAVEL_DC       = "Allez rencontrer votre contact à Haltevoie"  -- "Travel to Wayrest to Meet Your Contact"
,   TRAVEL_EP       = "Allez rencontrer votre contact à Longsanglot"-- "Travel to Mournhold to Meet Your Contact"

,   DELIVER_AL      = "Livrer la concoction"                        -- "Deliver the Concoction"
,   DELIVER_EN      = "Livrer le glyphe."                           -- "Deliver the Glyph"
,   DELIVER_PR      = "Livrer le festin."                           -- "Deliver the Feast"
,   DELIVER_WEAPON  = "Livrer l'arme."                              -- "Deliver the Weapon"
,   DELIVER_ARMOR   = "Livrez l'armure"                             -- "Deliver the Armor"
,   DELIVER_JW      = "Livrez le bijou"                             -- "Deliver the Jewelry"
}


-- Random Unsorted Stuff -----------------------------------------------------

LibCraftText.MASTER_LABELS = {
    ["quality"] =  "Qualité"                         -- "Quality"
,   ["set"    ] =  "Ensemble"                        -- "Set"
,   ["style"  ] =  "Style"                           -- "Style"
,   ["trait"  ] =  "Trait"                           -- "Trait"
}

LibCraftText.QUALITY = {
    ["NORMAL"   ] = { name="Normal"     , index=ITEM_QUALITY_NORMAL         or 1 }
,   ["FINE"     ] = { name="Raffiné"    , index=ITEM_QUALITY_FINE           or 2 }
,   ["SUPERIOR" ] = { name="Supérieur"  , index=ITEM_QUALITY_SUPERIOR       or 3 }
,   ["EPIC"     ] = { name="Épique"     , index=ITEM_QUALITY_EPIC           or 4 }
,   ["LEGENDARY"] = { name="Légendaire" , index=ITEM_QUALITY_LEGENDARY      or 5 }
}


-- Quest and Dialog Text -----------------------------------------------------

LibCraftText.DAILY.QUEST_NAME = {
    [bs] = "Commande de forge"                  -- "Blacksmith Writ"
,   [cl] = "Commande de tailleur"               -- "Clothier Writ"
,   [en] = "Commandes d'enchantement"           -- "Enchanter Writ"
,   [al] = "Commande d'alchimie"                -- "Alchemist Writ"
,   [pr] = "Commande de cuisine"                -- "Provisioner Writ"
,   [ww] = "Commande de travail du bois"        -- "Woodworker Writ"
,   [jw] = "Commande de joaillerie"             -- "Jewelry Crafting Writ"
}
                        -- SURPRISE! "A Masterful Weapon" is used by both
                        -- Blacksmithing and Woodworking.
                        --
                        -- Why a list? Because BS, CL, and WW can all use
                        -- different quest titles depending on what item they
                        -- requested (armor vs. weapon, light vs. medium armor)
                        --
LibCraftText.MASTER.QUEST_NAME = {
    [bs] = { "Une protection magistrale"          -- "A Masterful Plate"
           , "Une arme magistrale"              } -- "A Masterful Weapon"
,   [cl] = { "Une tenue magistrale"               -- "Masterful Tailoring"
           , "Un vêtement de cuir magistral"    } -- "Masterful Leatherwear"
,   [en] = { "Un glyphe magistral"              } -- "A Masterful Glyph"
,   [al] = { "Une concoction magistrale"        } -- "A Masterful Concoction"
,   [pr] = { "Un festin magistral"              } -- "A Masterful Feast"
,   [ww] = { "Un bouclier magistral"              -- "A Masterful Shield"
           , "Une arme magistrale"              } -- "A Masterful Weapon"
,   [jw] = { "Joaillerie magistrale"            } -- "Masterful Jewelry"
}

LibCraftText.DAILY.DIALOG = {
    ["OPTION_ACCEPT"      ] = "<Prendre une commande sur le panneau.>"  -- "<Pull a Writ from the Board.>"
,   ["OPTION_FINISH_SIGN" ] = "<Signer le manifeste.>"                  -- "<Sign the Manifest.>"
,   ["OPTION_FINISH_PLACE"] = "<Placer les produits dans la caisse.>"   -- "<Place the goods within the crate.>"
,   ["GOAL_SIGN"          ] = "Signez le manifeste de livraison"        -- "Sign Delivery Manifest"
}

LibCraftText.MASTER.DIALOG = {
    ["OPTION_ACCEPT"      ] = { "<Accepter le contrat>"                 -- "<Accept the contract.>"
                              , "<Accepter le contrat.>"                -- "<Accept the contract>"  (FR French omits the period sometimes)
                              }
,   ["ROLIS_NAME"         ] = "Rolis Hlaalu"                            -- "Rolis Hlaalu"
,   ["TITLE_ROLIS"        ] = "-Rolis Hlaalu-"                          -- "-Rolis Hlaalu-"
,   ["OPTION_STORE"       ] = "Magasin (intermédiaire pour maîtres artisans)"-- "Store (Mastercraft Mediator)"
,   ["OPTION_FINISH_JOB"  ] = "<Finir le travail.>"                     -- "<Finish the job.>"
,   ["RESPONSE_ENDING"    ] = "<Il note votre travail et se charge du paiement.>"-- "<He notes your work and tenders payment.>"
}

LibCraftText.DAILY.DIALOG.TITLE_OFFER = {
    "-Commandes d'équipement artisanal-"          -- "-Equipment Crafting Writs-"
,   "-Commandes de consommables artisanaux-"      -- "-Consumables Crafting Writs-"
}

LibCraftText.MASTER.DIALOG.TITLE_OFFER = {
    [bs] = "-Commande de forge scellée-"          -- "-Sealed Blacksmithing Writ-"
,   [cl] = "-Commande scellée de couture-"        -- "-Sealed Clothier Writ-"
,   [en] = "-Commande d'enchantement scellée-"    -- "-Sealed Enchanting Writ-"
,   [al] = "-Commande scellée d'alchimie-"        -- "-Sealed Alchemy Writ-"
,   [pr] = "-Commande scellée de cuisine-"        -- "-Sealed Provisioning Writ-"
,   [ww] = "-Commande de travail du bois scellée-"-- "-Sealed Woodworking Writ-"
,   [jw] = "-Commande scellée de joaillier-"      -- "-Sealed Jewelry Crafter Writ-"
}

LibCraftText.DAILY.DIALOG.TITLE_TURN_IN = {
    [bs] = "-La caisse de livraison du forgeron-" -- "-Blacksmith Delivery Crate-"
,   [cl] = "-La caisse de livraison du tailleur-" -- "-Clothier Delivery Crate-"
,   [en] = "-La caisse de livraison de l'enchanteur-"-- "-Enchanter Delivery Crate-"
,   [al] = "-La caisse de livraison de l'alchimiste-"-- "-Alchemist Delivery Crate-"
,   [pr] = "-La caisse de livraison du cuisinier-"-- "-Provisioner Delivery Crate-"
,   [ww] = "-La caisse de livraison du travailleur du bois-"-- "-Woodworker Delivery Crate-"
,   [jw] = "-Caisse de livraison de joaillerie-"  -- "-Jewelry Crafting Delivery Crate-"
}

LibCraftText.DAILY.DIALOG.OPTION_EXAMINE = {
    [bs] = "<Parcourir les commandes de forge.>"  -- "<Examine the Blacksmith Writs.>"
,   [cl] = "<Parcourir les commandes de couture.>"-- "<Examine the Clothier Writs.>"
,   [en] = "<Parcourir les commandes d'enchantement.>"-- "<Examine the Enchanter Writs.>"
,   [al] = "<Parcourir les commandes d'alchimie.>"-- "<Examine the Alchemist Writs.>"
,   [pr] = "<Parcourir les commandes de cuisine.>"-- "<Examine the Provisioner Writs.>"
,   [ww] = "<Parcourir les commandes de travail du bois.>"-- "<Examine the Woodworker Writs.>"
,   [jw] = "<Examiner les commandes de joaillerie.>"-- "<Examine the Jewelry Crafting Writs.>"
}

LibCraftText.MASTER.DIALOG.OPTION_FINISH = {
    [bs] = "J'ai accompli la tâche de forge."     -- "I've finished the Blacksmithing job."
,   [cl] = "J'ai accompli la tâche de couture."   -- "I've finished the Clothier job."
,   [en] = "J'ai accompli la tâche d'enchantement."-- "I've finished the Enchanting job."
,   [al] = "J'ai accompli la tâche d'alchimie."   -- "I've finished the Alchemy job."
,   [pr] = "J'ai rempli la commande de cuisine."  -- "I've finished the Provisioning job."
,   [ww] = "J'ai accompli la tâche du bois."      -- "I've finished the Woodworking job."
,   [jw] = "J'ai accompli la tâche de joaillerie."-- "I've finished the Jewelry job."
}
