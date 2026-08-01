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
  ["H1_AXE"         ] = { name="Hacha"                , master_name="Hacha"                     , pattern_index= 1, master_writ1=53, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H1_MACE"        ] = { name="Maza"                 , master_name="Maza"                      , pattern_index= 2, master_writ1=56, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H1_SWORD"       ] = { name="Espada"               , master_name="Espada"                    , pattern_index= 3, master_writ1=59, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H2_BATTLE_AXE"  ] = { name="hacha de batalla"     , master_name="Hacha de batalla"          , pattern_index= 4, master_writ1=68, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H2_MAUL"        ] = { name="Maza"                 , master_name="Maza"                      , pattern_index= 5, master_writ1=69, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["H2_GREATSWORD"  ] = { name="Mandoble"             , master_name="Mandoble"                  , pattern_index= 6, master_writ1=67, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["DAGGER"         ] = { name="Daga"                 , master_name="Daga"                      , pattern_index= 7, master_writ1=62, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_weap }
, ["CUIRASS"        ] = { name="Coraza"               , master_name="Coraza"                    , pattern_index= 8, master_writ1=46, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["SABATONS"       ] = { name="escarpes"             , master_name="Escarpes"                  , pattern_index= 9, master_writ1=50, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["GAUNTLETS"      ] = { name="guanteletes"          , master_name="Guanteletes"               , pattern_index=10, master_writ1=52, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["HELM"           ] = { name="yelmo"                , master_name="Casco"                     , pattern_index=11, master_writ1=44, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["GREAVES"        ] = { name="grebas"               , master_name="Grebas"                    , pattern_index=12, master_writ1=49, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["PAULDRON"       ] = { name="espaldarones"         , master_name="Espaldarones"              , pattern_index=13, master_writ1=47, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }
, ["GIRDLE"         ] = { name="Faja"                 , master_name="Faja"                      , pattern_index=14, master_writ1=48, crafting_type=bs, mat_set_id=mat_hvy , trait_set_id=trait_armr }

, ["ROBE"           ] = { name="Túnica"               , master_name="Túnica"                    , pattern_index= 1, master_writ1=28, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["JERKIN"         ] = { name="Jubón"                , master_name="Jubón"                     , pattern_index= 2, master_writ1=75, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["SHOES"          ] = { name="Zapatos"              , master_name="Zapatos"                   , pattern_index= 3, master_writ1=32, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["GLOVES"         ] = { name="guantes"              , master_name="Guantes"                   , pattern_index= 4, master_writ1=34, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["HAT"            ] = { name="Capucha"              , master_name="Capucha"                   , pattern_index= 5, master_writ1=26, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["BREECHES"       ] = { name="calzones"             , master_name="Calzones"                  , pattern_index= 6, master_writ1=31, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr }
, ["EPAULETS"       ] = { name="Cubrehombros"         , master_name="Cubrehombros"              , pattern_index= 7, master_writ1=29, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr , name_2="Cubrehombros"}
, ["SASH"           ] = { name="banda"                , master_name="Banda"                     , pattern_index= 8, master_writ1=30, crafting_type=cl, mat_set_id=mat_lgt , trait_set_id=trait_armr , name_2="banda"     }
, ["JACK"           ] = { name="pechera"              , master_name="Pechera"                   , pattern_index= 9, master_writ1=37, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["BOOTS"          ] = { name="botas"                , master_name="Botas"                     , pattern_index=10, master_writ1=41, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["BRACERS"        ] = { name="brazales"             , master_name="Brazales"                  , pattern_index=11, master_writ1=43, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr , name_2="brazaletes"}
, ["HELMET"         ] = { name="Casco"                , master_name="Casco"                     , pattern_index=12, master_writ1=35, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr , name_2="yelmo"     }
, ["GUARDS"         ] = { name="musleras"             , master_name="Musleras"                  , pattern_index=13, master_writ1=40, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["ARM_COPS"       ] = { name="Hombreras"            , master_name="Hombreras"                 , pattern_index=14, master_writ1=38, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }
, ["BELT"           ] = { name="Cinturón"             , master_name="Cinturón"                  , pattern_index=15, master_writ1=39, crafting_type=cl, mat_set_id=mat_med , trait_set_id=trait_armr }

, ["BOW"            ] = { name="Arco"                 , master_name="Arco"                      , pattern_index= 1, master_writ1=70, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["INFERNO_STAFF"  ] = { name="Vara infernal"        , master_name="Vara infernal"             , pattern_index= 3, master_writ1=72, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["ICE_STAFF"      ] = { name="vara glaciar"         , master_name="Vara glaciar"              , pattern_index= 4, master_writ1=73, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["LIGHTNING_STAFF"] = { name="vara eléctrica"       , master_name="Vara eléctrica"            , pattern_index= 5, master_writ1=74, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["RESTO_STAFF"    ] = { name="vara restauradora"    , master_name="Vara restauradora"         , pattern_index= 6, master_writ1=71, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_weap }
, ["SHIELD"         ] = { name="Escudo"               , master_name="Escudo"                    , pattern_index= 2, master_writ1=65, crafting_type=ww, mat_set_id=mat_wood, trait_set_id=trait_armr }

, ["NECKLACE"       ] = { name="collar"               , master_name="Collar"                    , pattern_index= 2, master_writ1=18, crafting_type=jw, mat_set_id=mat_jewl, trait_set_id=trait_jewl , name_2="colgantes" }
, ["RING"           ] = { name="anillo"               , master_name="Anillo"                    , pattern_index= 1, master_writ1=24, crafting_type=jw, mat_set_id=mat_jewl, trait_set_id=trait_jewl }
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
  ["AETHERIAL_TEA"                      ] = { name="té aeterio"                            , food_item_id=033602, recipe_item_id=046049, recipe_list_index=  9, recipe_index= 31, name_2="té aeterio"  }
, ["ALIKR_BEETS_WITH_GOAT_CHEESE"       ] = { name="remolachas de Alik'r con queso de cabra", food_item_id=028338, recipe_item_id=045899, recipe_list_index=  3, recipe_index= 13}
, ["BAKED_APPLES"                       ] = { name="manzanas asadas"                       , food_item_id=033837, recipe_item_id=045889, recipe_list_index=  2, recipe_index=  1}
, ["BAKED_POTATO"                       ] = { name="patata asada"                          , food_item_id=028354, recipe_item_id=045912, recipe_list_index=  3, recipe_index=  2}
, ["BANANA_SURPRISE"                    ] = { name="plátano sorpresa"                      , food_item_id=028281, recipe_item_id=045913, recipe_list_index=  2, recipe_index=  2}
, ["BARLEY_NECTAR"                      ] = { name="néctar de cebada"                      , food_item_id=033624, recipe_item_id=045984, recipe_list_index=  8, recipe_index= 14}
, ["BATTAGLIR_CHOWDER"                  ] = { name="Crema de marisco con battaglir"        , food_item_id=028394, recipe_item_id=045946, recipe_list_index=  3, recipe_index= 15}
, ["BITTERLEMON_TEA"                    ] = { name="Té de limón amargo"                    , food_item_id=028457, recipe_item_id=046000, recipe_list_index=  9, recipe_index= 13}
, ["BLUE_ROAD_MARATHON"                 ] = { name="maratón de Blue Road"                  , food_item_id=028513, recipe_item_id=046030, recipe_list_index= 10, recipe_index= 25}
, ["BOG_IRON_ALE"                       ] = { name="cerveza del Pantano de Hierro"         , food_item_id=028405, recipe_item_id=045971, recipe_list_index=  8, recipe_index=  4}
, ["BRETON_PORK_SAUSAGE"                ] = { name="Salchicha de cerdo bretona"            , food_item_id=028342, recipe_item_id=045900, recipe_list_index=  1, recipe_index= 13}
, ["CARROT_SOUP"                        ] = { name="Sopa de zanahoria"                     , food_item_id=028321, recipe_item_id=045887, recipe_list_index=  3, recipe_index=  1}
, ["CHICKEN_BREAST"                     ] = { name="pechuga de pollo"                      , food_item_id=033819, recipe_item_id=045935, recipe_list_index=  1, recipe_index=  3}
, ["CHORROL_CORN_ON_THE_COB"            ] = { name="mazorca de maíz de Chorrol"            , food_item_id=033514, recipe_item_id=045929, recipe_list_index=  3, recipe_index= 20}
, ["CINNAMON_GRAPE_JELLY"               ] = { name="Jalea de uva con canela"               , food_item_id=042790, recipe_item_id=045907, recipe_list_index=  2, recipe_index= 19}
, ["CLARIFIED_SYRAH_WINE"               ] = { name="vino aclarado de syrah"                , food_item_id=028409, recipe_item_id=045972, recipe_list_index=  8, recipe_index=  7, name_2="vino aclarado de syrah"}
, ["COMELY_WENCH_WHISKEY"               ] = { name="whisky de la doncella encantadora"     , food_item_id=028402, recipe_item_id=046048, recipe_list_index=  8, recipe_index= 31}
, ["CYRODILIC_CORNBREAD"                ] = { name="pan de maíz cyrodílico"                , food_item_id=033897, recipe_item_id=045958, recipe_list_index=  3, recipe_index= 25}
, ["CYRODILIC_PUMPKIN_FRITTERS"         ] = { name="buñuelos de calabaza de Cyrodill"      , food_item_id=033789, recipe_item_id=045931, recipe_list_index=  2, recipe_index= 20}
, ["ELENHIR_ROAST_ANTELOPE"             ] = { name="antílope asado de Elinhir"             , food_item_id=033520, recipe_item_id=045930, recipe_list_index=  1, recipe_index= 20}
, ["ELTHERIC_HOOCH"                     ] = { name="Licor eltérico"                        , food_item_id=028417, recipe_item_id=045974, recipe_list_index=  8, recipe_index= 13, name_2="Licor eltérico"}
, ["FIRSTHOLD_FRUIT_AND_CHEESE_PLATE"   ] = { name="plato de frutas y queso de Primada"    , food_item_id=068236, recipe_item_id=068192, recipe_list_index=  2, recipe_index= 40}
, ["FISHY_STICK"                        ] = { name="Palitos de pescado"                    , food_item_id=033526, recipe_item_id=045888, recipe_list_index=  1, recipe_index=  1}
, ["FOUR_EYE_GROG"                      ] = { name="grog cuatro-ojos"                      , food_item_id=033612, recipe_item_id=045982, recipe_list_index=  8, recipe_index=  8}
, ["GARLIC_MASHED_POTATOES"             ] = { name="Puré de patatas con ajo"               , food_item_id=028346, recipe_item_id=045905, recipe_list_index=  3, recipe_index= 19}
, ["GARLIC_PUMPKIN_SEEDS"               ] = { name="semillas de calabaza con ajo"          , food_item_id=033490, recipe_item_id=045925, recipe_list_index=  2, recipe_index= 14}
, ["GINGER_WHEAT_BEER"                  ] = { name="Cerveza de trigo y jengibre"           , food_item_id=033963, recipe_item_id=045993, recipe_list_index=  8, recipe_index= 18}
, ["GODS_BLIND_ME"                      ] = { name="Vino Cegado-Por-Dioses"                , food_item_id=028433, recipe_item_id=045978, recipe_list_index=  8, recipe_index= 25, name_2="Vino Cegado-Por-Dioses"}
, ["GOLDEN_LAGER"                       ] = { name="Cerveza rubia dorada"                  , food_item_id=033933, recipe_item_id=045988, recipe_list_index=  8, recipe_index=  3}
, ["GOSSAMER_MAZTE"                     ] = { name="Mazte sedoso"                          , food_item_id=033957, recipe_item_id=045992, recipe_list_index=  8, recipe_index= 15}
, ["GRANDPAS_BEDTIME_TONIC"             ] = { name="tónico de dormir del abuelo"           , food_item_id=028444, recipe_item_id=046050, recipe_list_index= 10, recipe_index= 31}
, ["GRAPE_PRESERVES"                    ] = { name="conserva de uvas"                      , food_item_id=033825, recipe_item_id=045936, recipe_list_index=  2, recipe_index=  3}
, ["HAGRAVENS_TONIC"                    ] = { name="tónico de bruja cuervo"                , food_item_id=068263, recipe_item_id=068219, recipe_list_index= 10, recipe_index= 42}
, ["HARE_IN_GARLIC_SAUCE"               ] = { name="Liebre en salsa de ajo"                , food_item_id=033581, recipe_item_id=045953, recipe_list_index=  1, recipe_index= 21, name_2="Liebre en salsa de ajo"}
, ["HEARTY_GARLIC_CORN_CHOWDER"         ] = { name="caldo espeso de maíz y ajo"            , food_item_id=068239, recipe_item_id=068195, recipe_list_index=  3, recipe_index= 40}
, ["HONEY_RYE"                          ] = { name="centeno meloso"                        , food_item_id=028421, recipe_item_id=045975, recipe_list_index=  8, recipe_index= 16}
, ["JERALL_VIEW_INN_CARROT_CAKE"        ] = { name="Pastel de zanahoria \"El Paisaje de Jerall\"", food_item_id=033575, recipe_item_id=045952, recipe_list_index=  3, recipe_index= 21}
, ["LEMON_FLOWER_MAZTE"                 ] = { name="Mazte de azahar"                       , food_item_id=033945, recipe_item_id=045990, recipe_list_index=  8, recipe_index=  9}
, ["LILMOTH_GARLIC_HAGFISH"             ] = { name="pez bruja al ajo de Lilmoth"           , food_item_id=068235, recipe_item_id=068191, recipe_list_index=  1, recipe_index= 42}
, ["LUSTY_ARGONIAN_MAID_MAZTE"          ] = { name="Mazte de la sensual doncella argoniana", food_item_id=068276, recipe_item_id=068232, recipe_list_index= 14, recipe_index= 31, name_2="Mazte de la sensual doncella argoniana"}
, ["MAMMOTH_SNOUT_PIE"                  ] = { name="pastel de trompa de mamut"             , food_item_id=033903, recipe_item_id=045959, recipe_list_index=  1, recipe_index= 25}
, ["MAORMER_TEA"                        ] = { name="Té maormer"                            , food_item_id=028465, recipe_item_id=046002, recipe_list_index=  9, recipe_index= 19}
, ["MARKARTH_MEAD"                      ] = { name="aguamiel de Markarth"                  , food_item_id=068257, recipe_item_id=068213, recipe_list_index=  8, recipe_index= 42}
, ["MAZTE"                              ] = { name="mazte"                                 , food_item_id=033606, recipe_item_id=045981, recipe_list_index=  8, recipe_index=  5}
, ["MERMAID_WHISKEY"                    ] = { name="whisky de sirena"                      , food_item_id=033630, recipe_item_id=045985, recipe_list_index=  8, recipe_index= 17}
, ["MILLET_STUFFED_PORK_LOIN"           ] = { name="lomo de cerdo relleno de mijo"         , food_item_id=043088, recipe_item_id=045965, recipe_list_index=  1, recipe_index= 31}
, ["MULLED_WINE"                        ] = { name="Vino caliente"                         , food_item_id=033969, recipe_item_id=045994, recipe_list_index=  8, recipe_index= 21}
, ["MUTHSERAS_REMORSE"                  ] = { name="remordimiento de muthsera"             , food_item_id=068260, recipe_item_id=068216, recipe_list_index=  9, recipe_index= 42}
, ["NEREID_WINE"                        ] = { name="Vino de nereida"                       , food_item_id=033975, recipe_item_id=045995, recipe_list_index=  8, recipe_index= 24}
, ["NIBENESE_GARLIC_CARROTS"            ] = { name="zanahorias al ajo a la nibenesa"       , food_item_id=033478, recipe_item_id=045923, recipe_list_index=  3, recipe_index= 14}
, ["NUT_BROWN_ALE"                      ] = { name="cerveza negra con avellanas"           , food_item_id=028401, recipe_item_id=045970, recipe_list_index=  8, recipe_index=  1}
, ["ORCREST_GARLIC_APPLE_JELLY"         ] = { name="jalea de manzana y ajo de Orcelia"     , food_item_id=043094, recipe_item_id=045966, recipe_list_index=  2, recipe_index= 31}
, ["PELLITINE_TOMATO_RICE"              ] = { name="Arroz con tomate Pellitine"            , food_item_id=042814, recipe_item_id=045901, recipe_list_index=  2, recipe_index= 13}
, ["RED_RYE_BEER"                       ] = { name="cerveza roja de centeno"               , food_item_id=033600, recipe_item_id=045980, recipe_list_index=  8, recipe_index=  2}
, ["REDORAN_PEPPERED_MELON"             ] = { name="Melón a la pimienta Redoran"           , food_item_id=033552, recipe_item_id=045948, recipe_list_index=  2, recipe_index= 15}
, ["ROAST_CORN"                         ] = { name="maíz tostado"                          , food_item_id=033813, recipe_item_id=045934, recipe_list_index=  3, recipe_index=  3}
, ["RYE_IN_YOUR_EYE"                    ] = { name="cente-no en la cara"                   , food_item_id=028429, recipe_item_id=045977, recipe_list_index=  8, recipe_index= 22}
, ["SEAFLOWER_TEA"                      ] = { name="Té de flor marina"                     , food_item_id=034005, recipe_item_id=046018, recipe_list_index=  9, recipe_index= 15}
, ["SENCHAL_CURRY_FISH_AND_RICE"        ] = { name="Curry de pescado y arroz de Senchal"   , food_item_id=028350, recipe_item_id=045906, recipe_list_index=  1, recipe_index= 19}
, ["SKYRIM_JAZBAY_CROSTATA"             ] = { name="crostata de jazbay de Skyrim"          , food_item_id=033909, recipe_item_id=045960, recipe_list_index=  2, recipe_index= 25}
, ["SORRY_HONEY_LAGER"                  ] = { name="cerveza \"Lo siento, cariño\""         , food_item_id=033642, recipe_item_id=045987, recipe_list_index=  8, recipe_index= 23}
, ["SOUR_MASH"                          ] = { name="Malta agria"                           , food_item_id=028425, recipe_item_id=045976, recipe_list_index=  8, recipe_index= 19}
, ["SPICEBERRY_CHAI"                    ] = { name="té chai de bayacida"                   , food_item_id=033684, recipe_item_id=046012, recipe_list_index=  9, recipe_index= 20}
, ["SPICED_MAZTE"                       ] = { name="mazte especiado"                       , food_item_id=033636, recipe_item_id=045986, recipe_list_index=  8, recipe_index= 20}
, ["STORMHOLD_BAKED_BANANAS"            ] = { name="plátanos asados de Fuertormenta"       , food_item_id=033587, recipe_item_id=045954, recipe_list_index=  2, recipe_index= 21}
, ["SURILIE_SYRAH_WINE"                 ] = { name="vino de syrah de los Surilie"          , food_item_id=033939, recipe_item_id=045989, recipe_list_index=  8, recipe_index=  6}
, ["TORVAL_MINT_TEA"                    ] = { name="Té de menta de Torval"                 , food_item_id=034017, recipe_item_id=046020, recipe_list_index=  9, recipe_index= 21}
, ["TREACLEBERRY_TEA"                   ] = { name="té de bayamelaza"                      , food_item_id=033672, recipe_item_id=046010, recipe_list_index=  9, recipe_index= 14}
, ["TWO_ZEPHYR_TEA"                     ] = { name="té de Dos-Céfiros"                     , food_item_id=028473, recipe_item_id=046004, recipe_list_index=  9, recipe_index= 25}
, ["VENISON_PASTY"                      ] = { name="Empanada de venado"                    , food_item_id=028398, recipe_item_id=045947, recipe_list_index=  1, recipe_index= 15}
, ["WEST_WEALD_CORN_CHOWDER"            ] = { name="caldo de maíz del Bosque Occidental"   , food_item_id=032160, recipe_item_id=045964, recipe_list_index=  3, recipe_index= 31}
, ["WHITERUN_CHEESE_BAKED_TROUT"        ] = { name="trucha gratinada de Carrera Blanca"    , food_item_id=033484, recipe_item_id=045924, recipe_list_index=  1, recipe_index= 14}

-- master
, ["CAPON_TOMATO_BEET_CASSEROLE"        ] = { name="Capon Tomato-Beet Casserole"           , food_item_id=068251, recipe_item_id=068207, recipe_list_index=  7, recipe_index= 28}
, ["JUGGED_RABBIT_IN_PRESERVES"         ] = { name="Jugged Rabbit in Preserves"            , food_item_id=068252, recipe_item_id=068208, recipe_list_index=  7, recipe_index= 29}
, ["LONGFIN_PASTY_WITH_MELON_SAUCE"     ] = { name="Longfin Pasty with Melon Sauce"        , food_item_id=068253, recipe_item_id=068209, recipe_list_index=  7, recipe_index= 30, name_2="Longfin Pasty with Melon Sauce"}
, ["LUSTY_ARGONIAN_MAID_MAZTE"          ] = { name="Mazte de la sensual doncella argoniana", food_item_id=068276, recipe_item_id=068232, recipe_list_index= 14, recipe_index= 31, name_2="Mazte de la sensual doncella argoniana"}
, ["ORCREST_AGONY_PALE_ALE"             ] = { name="cerveza pálida de la agonía de Orcelia", food_item_id=068275, recipe_item_id=068231, recipe_list_index= 14, recipe_index= 30, name_2="cerveza pálida de la agonía de Orcelia"}
, ["ORZORGAS_BLOOD_PRICE_PIE"           ] = { name="Tarta del precio de sangre de Orzorga" , food_item_id=071058, recipe_item_id=071062, recipe_list_index= 16, recipe_index=  3, name_2="Tarta del precio de sangre de Orzorga"}
, ["ORZORGAS_RED_FROTHGAR"              ] = { name="Caldo rojo de Orzorga"                 , food_item_id=071056, recipe_item_id=071060, recipe_list_index= 15, recipe_index= 14, name_2="Caldo rojo de Orzorga"}
, ["ORZORGAS_SMOKED_BEAR_HAUNCH"        ] = { name="Pierna de oso ahumada de Orzorga"      , food_item_id=071059, recipe_item_id=071063, recipe_list_index= 16, recipe_index=  4, name_2="Pierna de oso ahumada de Orzorga"}
, ["ORZORGAS_TRIPE_TRIFLE_POCKET"       ] = { name="callos con todo de Ozorga"             , food_item_id=071057, recipe_item_id=071061, recipe_list_index= 16, recipe_index=  2, name_2="callos con todo de Ozorga"}
, ["PSIJIC_AMBROSIA"                    ] = { name="ambrosía psijic"                       , food_item_id=064221, recipe_item_id=064223, recipe_list_index= 15, recipe_index=  1, name_2="ambrosía psijic"}
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
  ["IRON"                    ] = { name="hierro"                         , crafting_type=bs, level_index= 1, material_index= 1, master_writ2=  1, mat_set_id=mat_hvy  }
, ["STEEL"                   ] = { name="acero"                          , crafting_type=bs, level_index= 2, material_index= 8, master_writ2=  9, mat_set_id=mat_hvy  }
, ["ORICHALC"                ] = { name="oricalco"                       , crafting_type=bs, level_index= 3, material_index=13, master_writ2=156, mat_set_id=mat_hvy  }
, ["DWARVEN"                 ] = { name="acero enano"                    , crafting_type=bs, level_index= 4, material_index=18, master_writ2=160, mat_set_id=mat_hvy  , name_2="acero enano"    }
, ["EBONY"                   ] = { name="ébano"                          , crafting_type=bs, level_index= 5, material_index=23, master_writ2=164, mat_set_id=mat_hvy  , name_2="ébano"          }
, ["CALCINIUM"               ] = { name="calcinio"                       , crafting_type=bs, level_index= 6, material_index=26, master_writ2=168, mat_set_id=mat_hvy  }
, ["GALATITE"                ] = { name="galatita"                       , crafting_type=bs, level_index= 7, material_index=29, master_writ2=172, mat_set_id=mat_hvy  }
, ["QUICKSILVER"             ] = { name="azogue"                         , crafting_type=bs, level_index= 8, material_index=32, master_writ2=176, mat_set_id=mat_hvy  }
, ["VOIDSTEEL"               ] = { name="acero del vacío"                , crafting_type=bs, level_index= 9, material_index=34, master_writ2=180, mat_set_id=mat_hvy  }
, ["RUBEDITE"                ] = { name="rubedita"                       , crafting_type=bs, level_index=10, material_index=40, master_writ2=188, mat_set_id=mat_hvy  }

, ["JUTE"                    ] = { name="tejido artesanal"               , crafting_type=cl, level_index= 1, material_index= 1, master_writ2=  5, mat_set_id=mat_lgt  , name_2="tejido artesanal"}
, ["LINEN"                   ] = { name="lino"                           , crafting_type=cl, level_index= 2, material_index= 8, master_writ2= 45, mat_set_id=mat_lgt  }
, ["COTTON"                  ] = { name="algodón"                        , crafting_type=cl, level_index= 3, material_index=13, master_writ2= 47, mat_set_id=mat_lgt  }
, ["SPIDERSILK"              ] = { name="seda de araña"                  , crafting_type=cl, level_index= 4, material_index=18, master_writ2= 49, mat_set_id=mat_lgt  }
, ["EBONTHREAD"              ] = { name="hilo de ébano"                  , crafting_type=cl, level_index= 5, material_index=23, master_writ2= 51, mat_set_id=mat_lgt  }
, ["KRESH"                   ] = { name="kresh"                          , crafting_type=cl, level_index= 6, material_index=26, master_writ2=125, mat_set_id=mat_lgt  }
, ["IRONTHREAD"              ] = { name="hilo de hierro"                 , crafting_type=cl, level_index= 7, material_index=29, master_writ2=126, mat_set_id=mat_lgt  , name_2="hilo férreo"     }
, ["SILVERWEAVE"             ] = { name="hilo de plata"                  , crafting_type=cl, level_index= 8, material_index=32, master_writ2=127, mat_set_id=mat_lgt  }
, ["SHADOWSPUN"              ] = { name="tejido sombrío"                 , crafting_type=cl, level_index= 9, material_index=34, master_writ2=128, mat_set_id=mat_lgt  }
, ["ANCESTOR_SILK"           ] = { name="seda ancestral"                 , crafting_type=cl, level_index=10, material_index=40, master_writ2=194, mat_set_id=mat_lgt  , name_2="seda ancestral"  }

, ["RAWHIDE"                 ] = { name="piel cruda"                     , crafting_type=cl, level_index= 1, material_index= 1, master_writ2=148, mat_set_id=mat_med  }
, ["HIDE"                    ] = { name="piel"                           , crafting_type=cl, level_index= 2, material_index= 8, master_writ2=154, mat_set_id=mat_med  }
, ["LEATHER"                 ] = { name="cuero"                          , crafting_type=cl, level_index= 3, material_index=13, master_writ2=158, mat_set_id=mat_med  }
, ["FULL_LEATHER"            ] = { name="cuero tratado"                  , crafting_type=cl, level_index= 4, material_index=18, master_writ2=162, mat_set_id=mat_med  }
, ["FELL_HIDE"               ] = { name="piel impía"                     , crafting_type=cl, level_index= 5, material_index=23, master_writ2=166, mat_set_id=mat_med  }
, ["BRIGANDINE"              ] = { name="brigantina"                     , crafting_type=cl, level_index= 6, material_index=26, master_writ2=170, mat_set_id=mat_med  , name_2="brigantina"      }
, ["IRONHIDE"                ] = { name="piel férrea"                    , crafting_type=cl, level_index= 7, material_index=29, master_writ2=174, mat_set_id=mat_med  }
, ["SUPERB"                  ] = { name="soberbio"                       , crafting_type=cl, level_index= 8, material_index=32, master_writ2=131, mat_set_id=mat_med  , name_2="soberbia"        }
, ["SHADOWHIDE"              ] = { name="piel sombría"                   , crafting_type=cl, level_index= 9, material_index=34, master_writ2=132, mat_set_id=mat_med  }
, ["RUBEDO_LEATHER"          ] = { name="cuero rubedo"                   , crafting_type=cl, level_index=10, material_index=40, master_writ2=190, mat_set_id=mat_med  }

, ["MAPLE"                   ] = { name="arce"                           , crafting_type=ww, level_index= 1, material_index= 1, master_writ2=  2, mat_set_id=mat_wood }
, ["OAK"                     ] = { name="roble"                          , crafting_type=ww, level_index= 2, material_index= 8, master_writ2= 18, mat_set_id=mat_wood }
, ["BEECH"                   ] = { name="haya"                           , crafting_type=ww, level_index= 3, material_index=13, master_writ2= 20, mat_set_id=mat_wood }
, ["HICKORY"                 ] = { name="nogal"                          , crafting_type=ww, level_index= 4, material_index=18, master_writ2= 22, mat_set_id=mat_wood }
, ["YEW"                     ] = { name="tejo"                           , crafting_type=ww, level_index= 5, material_index=23, master_writ2= 24, mat_set_id=mat_wood }
, ["BIRCH"                   ] = { name="abedul"                         , crafting_type=ww, level_index= 6, material_index=26, master_writ2=133, mat_set_id=mat_wood }
, ["ASH"                     ] = { name="fresno"                         , crafting_type=ww, level_index= 7, material_index=29, master_writ2=134, mat_set_id=mat_wood }
, ["MAHOGANY"                ] = { name="caoba"                          , crafting_type=ww, level_index= 8, material_index=32, master_writ2=135, mat_set_id=mat_wood }
, ["NIGHTWOOD"               ] = { name="nocteca"                        , crafting_type=ww, level_index= 9, material_index=34, master_writ2=136, mat_set_id=mat_wood }
, ["RUBY_ASH"                ] = { name="fresno rubí"                    , crafting_type=ww, level_index=10, material_index=40, master_writ2=192, mat_set_id=mat_wood }

, ["PEWTER"                  ] = { name="peltre"                         , crafting_type=jw, level_index= 1, material_index= 1, master_writ2=  6, mat_set_id=mat_jewl }
, ["COPPER"                  ] = { name="cobre"                          , crafting_type=jw, level_index= 2, material_index=13, master_writ2= 56, mat_set_id=mat_jewl }
, ["SILVER"                  ] = { name="plata"                          , crafting_type=jw, level_index= 3, material_index=26, master_writ2=137, mat_set_id=mat_jewl }
, ["ELECTRUM"                ] = { name="electro"                        , crafting_type=jw, level_index= 4, material_index=33, master_writ2=139, mat_set_id=mat_jewl , name_2="electrum"       }
, ["PLATINUM"                ] = { name="platino"                        , crafting_type=jw, level_index= 5, material_index=40, master_writ2=255, mat_set_id=mat_jewl }

, ["BLESSED_THISTLE"         ] = { name="cardo bendito"                  , crafting_type=al, item_id= 30157 }
, ["BLUE_ENTOLOMA"           ] = { name="entoloma azul"                  , crafting_type=al, item_id= 30148 }
, ["BUGLOSS"                 ] = { name="lengua de buey"                 , crafting_type=al, item_id= 30160 }
, ["COLUMBINE"               ] = { name="aguilegia"                      , crafting_type=al, item_id= 30164 }
, ["CORN_FLOWER"             ] = { name="aciano"                         , crafting_type=al, item_id= 30161 }
, ["DRAGONTHORN"             ] = { name="espina de dragón"               , crafting_type=al, item_id= 30162 }
, ["EMETIC_RUSSULA"          ] = { name="rúsula emética"                 , crafting_type=al, item_id= 30151 }
, ["IMP_STOOL"               ] = { name="seta de diablillo"              , crafting_type=al, item_id= 30156 }
, ["LADYS_SMOCK"             ] = { name="cardamina"                      , crafting_type=al, item_id= 30158 }
, ["LUMINOUS_RUSSULA"        ] = { name="rúsula luminosa"                , crafting_type=al, item_id= 30155 }
, ["MOUNTAIN_FLOWER"         ] = { name="flor de montaña"                , crafting_type=al, item_id= 30163 }
, ["NAMIRAS_ROT"             ] = { name="seta de Namira"                 , crafting_type=al, item_id= 30153 }
, ["NIRNROOT"                ] = { name="raíz de nirn"                   , crafting_type=al, item_id= 30165 }
, ["STINKHORN"               ] = { name="falacea"                        , crafting_type=al, item_id= 30149 }
, ["VIOLET_COPRINUS"         ] = { name="coprinus violeta"               , crafting_type=al, item_id= 30152 , name_2="coprinus violeta"   }
, ["WATER_HYACINTH"          ] = { name="jacinto de agua"                , crafting_type=al, item_id= 30166 }
, ["WHITE_CAP"               ] = { name="hongo blanco"                   , crafting_type=al, item_id= 30154 }
, ["WORMWOOD"                ] = { name="artemisia"                      , crafting_type=al, item_id= 30159 }
, ["BEETLE_SCUTTLE"          ] = { name="baba de escarabajo"             , crafting_type=al, item_id= 77583 }
, ["BUTTERFLY_WING"          ] = { name="ala de mariposa"                , crafting_type=al, item_id= 77585 }
, ["FLESHFLY_LARVA"          ] = { name="larva de mosca de la carne"     , crafting_type=al, item_id= 77587 }
, ["MUDCRAB_CHITIN"          ] = { name="quitina de cangrejo del barro"  , crafting_type=al, item_id= 77591 }
, ["NIGHTSHADE"              ] = { name="belladona"                      , crafting_type=al, item_id= 77590 }
, ["SCRIB_JELLY"             ] = { name="jalea de scrib"                 , crafting_type=al, item_id= 77589 }
, ["SPIDER_EGG"              ] = { name="huevo de araña"                 , crafting_type=al, item_id= 77584 }
, ["TORCHBUG_THORAX"         ] = { name="tórax de luciérnaga"            , crafting_type=al, item_id= 77581 }
, ["CLAM_GALL"               ] = { name="hiel de almeja"                 , crafting_type=al, item_id=139020 }
, ["POWDERED_MOTHER_OF_PEARL"] = { name="polvo de nácar"                 , crafting_type=al, item_id=139019 }

, ["NATURAL_WATER"           ] = { name="agua natural"                   , crafting_type=al, item_id=   883 , name_2="agua natural"       , rank=1, potion_name="sorbo"                   }
, ["CLEAR_WATER"             ] = { name="agua limpia"                    , crafting_type=al, item_id=  1187                               , rank=2, potion_name="tintura"                 }
, ["PRISTINE_WATER"          ] = { name="agua prístina"                  , crafting_type=al, item_id=  4570 , name_2="agua prístina"      , rank=3, potion_name="trago"                   , potion_name2="trago"                    }
, ["CLEANSED_WATER"          ] = { name="agua depurada"                  , crafting_type=al, item_id= 23265 , name_2="agua depurada"      , rank=4, potion_name="poción"                  }
, ["FILTERED_WATER"          ] = { name="agua filtrada"                  , crafting_type=al, item_id= 23266 , name_2="agua filtrada"      , rank=5, potion_name="solución"                }
, ["PURIFIED_WATER"          ] = { name="agua purificada"                , crafting_type=al, item_id= 23267 , name_2="agua purificada"    , rank=6, potion_name="elixir"                  }
, ["CLOUD_MIST"              ] = { name="Bruma"                          , crafting_type=al, item_id= 23268                               , rank=7, potion_name="panacea"                 }
, ["STAR_DEW"                ] = { name="rocío estelar"                  , crafting_type=al, item_id= 64500                               , rank=8, potion_name="destilado"               }
, ["LORKHANS_TEARS"          ] = { name="Lágrimas de Lorkhan"            , crafting_type=al, item_id= 64501                               , rank=9, potion_name="esencia"                 }

, ["GREASE"                  ] = { name="Grasa"                          , crafting_type=al, item_id= 75357                               , rank=1, poison_name="i"                       }
, ["ICHOR"                   ] = { name="icor"                           , crafting_type=al, item_id= 75358                               , rank=2, poison_name="ii"                      }
, ["SLIME"                   ] = { name="limo"                           , crafting_type=al, item_id= 75359                               , rank=3, poison_name="iii"                     }
, ["GALL"                    ] = { name="bilis"                          , crafting_type=al, item_id= 75360                               , rank=4, poison_name="iv"                      }
, ["TEREBINTHINE"            ] = { name="trementina"                     , crafting_type=al, item_id= 75361                               , rank=5, poison_name="v"                       }
, ["PITCH_BILE"              ] = { name="bilis ácido"                    , crafting_type=al, item_id= 75362                               , rank=6, poison_name="vi"                      }
, ["TARBLACK"                ] = { name="betún negro"                    , crafting_type=al, item_id= 75363                               , rank=7, poison_name="vii"                     }
, ["NIGHT_OIL"               ] = { name="aceite noctívago"               , crafting_type=al, item_id= 75364                               , rank=8, poison_name="viii"                    }
, ["ALKAHEST"                ] = { name="alkahest"                       , crafting_type=al, item_id= 75365                               , rank=9, poison_name="ix"                      }

, ["JORA"                    ] = { name="Jora"                           , crafting_type=en, item_id= 45855 , name_2="mediocre"      }
, ["PORADE"                  ] = { name="Porade"                         , crafting_type=en, item_id= 45856 }
, ["JERA"                    ] = { name="Jera"                           , crafting_type=en, item_id= 45857 , name_2="insignificante"}
, ["JEJORA"                  ] = { name="Jejora"                         , crafting_type=en, item_id= 45806 }
, ["ODRA"                    ] = { name="Odra"                           , crafting_type=en, item_id= 45807 , name_2="menor"         }
, ["POJORA"                  ] = { name="Pojora"                         , crafting_type=en, item_id= 45808 }
, ["EDORA"                   ] = { name="Edora"                          , crafting_type=en, item_id= 45809 , name_2="moderado"      }
, ["JAERA"                   ] = { name="Jaera"                          , crafting_type=en, item_id= 45810 }
, ["PORA"                    ] = { name="Pora"                           , crafting_type=en, item_id= 45811 , name_2="fuerte"        }
, ["DENARA"                  ] = { name="Denara"                         , crafting_type=en, item_id= 45812 }
, ["RERA"                    ] = { name="Rera"                           , crafting_type=en, item_id= 45813 , name_2="superior"      }
, ["DERADO"                  ] = { name="Derado"                         , crafting_type=en, item_id= 45814 , name_2="grande"       , name_3="grand"          }
, ["REKURA"                  ] = { name="Rekura"                         , crafting_type=en, item_id= 45815 , name_2="espléndido"    }
, ["KURA"                    ] = { name="Kura"                           , crafting_type=en, item_id= 45816 , name_2="monumental"    }
, ["REJERA"                  ] = { name="Rejera"                         , crafting_type=en, item_id= 64509 , name_2="soberbio"      }
, ["REPORA"                  ] = { name="Repora"                         , crafting_type=en, item_id= 68341 , name_2="realmente soberbio"}

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

, ["DEKEIPA"                 ] = { name="Dekeipa"                        , crafting_type=en, item_id= 45839 , add="hielo"            , sub="resistencia al frío"}
, ["DENI"                    ] = { name="Deni"                           , crafting_type=en, item_id= 45833 , add="aguante"          , sub="absorción de aguante", add_2="aguante"             }
, ["DENIMA"                  ] = { name="Denima"                         , crafting_type=en, item_id= 45836 , add="regeneración de aguante", sub="virtuosidad"       }
, ["DETERI"                  ] = { name="Deteri"                         , crafting_type=en, item_id= 45842 , add="robustez"         , sub="aplastamiento"     }
, ["HAOKO"                   ] = { name="Haoko"                          , crafting_type=en, item_id= 45841 , add="podredumbre"      , sub="resistencia a la enfermedad"}
, ["HAKEIJO"                 ] = { name="Hakeijo"                        , crafting_type=en, item_id= 68342 , add="defensa prismática", sub="asalto prismático" }
, ["KADERI"                  ] = { name="Kaderi"                         , crafting_type=en, item_id= 45849 , add="percutante"       , sub="protección"        }
, ["KUOKO"                   ] = { name="Kuoko"                          , crafting_type=en, item_id= 45837 , add="veneno"           , sub="resistencia al veneno"}
, ["MAKDERI"                 ] = { name="Makderi"                        , crafting_type=en, item_id= 45848 , add="aumento de daño mágico", sub="resistencia al daño mágico"}
, ["MAKKO"                   ] = { name="Makko"                          , crafting_type=en, item_id= 45832 , add="magia"            , sub="absorción de magia", add_2="magicka"             }
, ["MAKKOMA"                 ] = { name="Makkoma"                        , crafting_type=en, item_id= 45835 , add="regeneración de magia", sub="brujería"          }
, ["MEIP"                    ] = { name="Meip"                           , crafting_type=en, item_id= 45840 , add="descarga"         , sub="resistencia a electricidad"}
, ["OKO"                     ] = { name="Oko"                            , crafting_type=en, item_id= 45831 , add="vida"             , sub="absorción de vida", add_2="vida"                }
, ["OKOMA"                   ] = { name="Okoma"                          , crafting_type=en, item_id= 45834 , add="regeneración de salud", sub="disminución de vida"}
, ["OKORI"                   ] = { name="Okori"                          , crafting_type=en, item_id= 45843 , add="daño físico"      , sub="debilidad"         }
, ["ORU"                     ] = { name="Oru"                            , crafting_type=en, item_id= 45846 , add="del alquimista"   , sub="aceleración de pociones"}
, ["RAKEIPA"                 ] = { name="Rakeipa"                        , crafting_type=en, item_id= 45838 , add="fuego"            , sub="resistencia al fuego"}
, ["TADERI"                  ] = { name="Taderi"                         , crafting_type=en, item_id= 45847 , add="aumento de daño físico", sub="resistencia al daño físico"}

, ["TA"                      ] = { name="Ta"                             , crafting_type=en, item_id= 45850 , name_2="Normal"   }
, ["JEJOTA"                  ] = { name="Jejota"                         , crafting_type=en, item_id= 45851 , name_2="Bueno"    }
, ["DENATA"                  ] = { name="Denata"                         , crafting_type=en, item_id= 45852 , name_2="Superior" }
, ["REKUTA"                  ] = { name="Rekuta"                         , crafting_type=en, item_id= 45853 , name_2="Épico"    }
, ["KUTA"                    ] = { name="Kuta"                           , crafting_type=en, item_id= 45854 , name_2="Legendario"}

, ["QUARTZ"                  ] = { name="Cuarzo"                         ,                   item_id=  4456 }
, ["DIAMOND"                 ] = { name="Diamante"                       ,                   item_id= 23219 }
, ["SARDONYX"                ] = { name="sardónice"                      ,                   item_id= 30221 }
, ["ALMANDINE"               ] = { name="Almandino"                      ,                   item_id= 23221 }
, ["EMERALD"                 ] = { name="Esmeralda"                      ,                   item_id=  4442 }
, ["BLOODSTONE"              ] = { name="Piedra de sangre"               ,                   item_id= 30219 }
, ["GARNET"                  ] = { name="Granate"                        ,                   item_id= 23171 }
, ["SAPPHIRE"                ] = { name="Zafiro"                         ,                   item_id= 23173 }
, ["FORTIFIED_NIRNCRUX"      ] = { name="Nirncrux fortificado"           ,                   item_id= 56862 }
, ["CHYSOLITE"               ] = { name="Crisolita"                      ,                   item_id= 23203 }
, ["AMETHYST"                ] = { name="Amatista"                       ,                   item_id= 23204 }
, ["RUBY"                    ] = { name="rubí"                           ,                   item_id=  4486 }
, ["JADE"                    ] = { name="Jade"                           ,                   item_id=   810 }
, ["TURQUOISE"               ] = { name="turquesa"                       ,                   item_id=   813 }
, ["CARNELIAN"               ] = { name="Cornalina"                      ,                   item_id= 23165 }
, ["FIRE_OPAL"               ] = { name="Ópalo de fuego"                 ,                   item_id= 23149 }
, ["CITRINE"                 ] = { name="Citrino"                        ,                   item_id= 16291 }
, ["POTENT_NIRNCRUX"         ] = { name="Nirncrux potente"               ,                   item_id= 56863 }
, ["COBALT"                  ] = { name="cobalto"                        ,                   item_id=135155 }
, ["ANTIMONY"                ] = { name="antimonio"                      ,                   item_id=135156 }
, ["ZINC"                    ] = { name="cinc"                           ,                   item_id=135157 }
, ["DAWN_PRISM"              ] = { name="prisma del alba"                ,                   item_id=139409 }
, ["DIBELLIUM"               ] = { name="dibelio"                        ,                   item_id=139413 }
, ["GILDING_WAX"             ] = { name="cera dorada"                    ,                   item_id=139412 }
, ["AURBIC_AMBER"            ] = { name="ámbar aúrbico"                  ,                   item_id=139411 }
, ["TITANIUM"                ] = { name="titanio"                        ,                   item_id=139410 }
, ["SLAUGHTERSTONE"          ] = { name="piedra masacre"                 ,                   item_id=139414 }

}


-- Equipment Traits ----------------------------------------------------------
--
-- For master writ quests that require Nirnhoned or whatever.
--
local ts=LibCraftText.TRAIT_SET_ID -- for less typing
local m =LibCraftText.MATERIAL
LibCraftText.TRAIT = {
    ["WEAPON_POWERED"      ] = { name="Potenciado"                  , trait_set_id=ts.WEAPON  , trait_index=1 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_POWERED          or  1 , material=m.CHYSOLITE          }
,   ["WEAPON_CHARGED"      ] = { name="Cargado"                     , trait_set_id=ts.WEAPON  , trait_index=2 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_CHARGED          or  2 , material=m.AMETHYST           }
,   ["WEAPON_PRECISE"      ] = { name="Preciso"                     , trait_set_id=ts.WEAPON  , trait_index=3 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_PRECISE          or  3 , material=m.RUBY               }
,   ["WEAPON_INFUSED"      ] = { name="Imbuido"                     , trait_set_id=ts.WEAPON  , trait_index=4 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_INFUSED          or  4 , material=m.JADE               }
,   ["WEAPON_DEFENDING"    ] = { name="Defensivo"                   , trait_set_id=ts.WEAPON  , trait_index=5 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_DEFENDING        or  5 , material=m.TURQUOISE          }
,   ["WEAPON_TRAINING"     ] = { name="Entrenamiento"               , trait_set_id=ts.WEAPON  , trait_index=6 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_TRAINING         or  6 , material=m.CARNELIAN          }
,   ["WEAPON_SHARPENED"    ] = { name="Afilado"                     , trait_set_id=ts.WEAPON  , trait_index=7 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_SHARPENED        or  7 , material=m.FIRE_OPAL          }
,   ["WEAPON_DECISIVE"     ] = { name="Decisivo"                    , trait_set_id=ts.WEAPON  , trait_index=8 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_DECISIVE         or  8 , material=m.CITRINE            }
,   ["WEAPON_NIRNHONED"    ] = { name="Temple de Nirn"              , trait_set_id=ts.WEAPON  , trait_index=9 , trait_type_id=ITEM_TRAIT_TYPE_WEAPON_NIRNHONED        or 26 , material=m.POTENT_NIRNCRUX    }

,   ["ARMOR_STURDY"        ] = { name="Resistente"                  , trait_set_id=ts.ARMOR   , trait_index=1 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_STURDY            or 11 , material=m.QUARTZ             }
,   ["ARMOR_IMPENETRABLE"  ] = { name="Impenetrable"                , trait_set_id=ts.ARMOR   , trait_index=2 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE      or 12 , material=m.DIAMOND            }
,   ["ARMOR_REINFORCED"    ] = { name="Reforzado"                   , trait_set_id=ts.ARMOR   , trait_index=3 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_REINFORCED        or 13 , material=m.SARDONYX           }
,   ["ARMOR_WELL_FITTED"   ] = { name="Ajustado"                    , trait_set_id=ts.ARMOR   , trait_index=4 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED       or 14 , material=m.ALMANDINE          }
,   ["ARMOR_TRAINING"      ] = { name="Adiestramiento"              , trait_set_id=ts.ARMOR   , trait_index=5 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_TRAINING          or 15 , material=m.EMERALD            }
,   ["ARMOR_INFUSED"       ] = { name="Imbuido"                     , trait_set_id=ts.ARMOR   , trait_index=6 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_INFUSED           or 16 , material=m.BLOODSTONE         }
,   ["ARMOR_INVIGORATING"  ] = { name="Vigorizante"                 , trait_set_id=ts.ARMOR   , trait_index=7 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_INVIGORATING      or 17 , material=m.GARNET             }
,   ["ARMOR_DIVINES"       ] = { name="Divino"                      , trait_set_id=ts.ARMOR   , trait_index=8 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_DIVINES           or 18 , material=m.SAPPHIRE           }
,   ["ARMOR_NIRNHONED"     ] = { name="Temple de Nirn"              , trait_set_id=ts.ARMOR   , trait_index=9 , trait_type_id=ITEM_TRAIT_TYPE_ARMOR_NIRNHONED         or 25 , material=m.FORTIFIED_NIRNCRUX }

,   ["JEWELRY_ARCANE"      ] = { name="Arcano"                      , trait_set_id=ts.JEWELRY , trait_index=1 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_ARCANE          or 22 , material=m.COBALT             }
,   ["JEWELRY_HEALTHY"     ] = { name="Saludable"                   , trait_set_id=ts.JEWELRY , trait_index=2 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_HEALTHY         or 21 , material=m.ANTIMONY           }
,   ["JEWELRY_ROBUST"      ] = { name="Robusto"                     , trait_set_id=ts.JEWELRY , trait_index=3 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_ROBUST          or 23 , material=m.ZINC               }
,   ["JEWELRY_TRIUNE"      ] = { name="Trinitario"                  , trait_set_id=ts.JEWELRY , trait_index=4 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_TRIUNE          or 30 , material=m.DAWN_PRISM         }
,   ["JEWELRY_INFUSED"     ] = { name="Imbuido"                     , trait_set_id=ts.JEWELRY , trait_index=5 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_INFUSED         or 33 , material=m.AURBIC_AMBER       }
,   ["JEWELRY_PROTECTIVE"  ] = { name="Protector"                   , trait_set_id=ts.JEWELRY , trait_index=6 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE      or 32 , material=m.TITANIUM           }
,   ["JEWELRY_SWIFT"       ] = { name="Ágil"                        , trait_set_id=ts.JEWELRY , trait_index=7 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_SWIFT           or 28 , material=m.GILDING_WAX        }
,   ["JEWELRY_HARMONY"     ] = { name="Armonioso"                   , trait_set_id=ts.JEWELRY , trait_index=8 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_HARMONY         or 29 , material=m.DIBELLIUM          }
,   ["JEWELRY_BLOODTHIRSTY"] = { name="Sanguinario"                 , trait_set_id=ts.JEWELRY , trait_index=9 , trait_type_id=ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY    or 31 , material=m.SLAUGHTERSTONE     }

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
    ["RESTORE_HEALTH"         ] = { trait_index=01, name="Restauración de salud"    , master_potion="esencia de salud"                  , master_poison="veneno de absorción de vida IX"    , daily_potion_name="salud"                        , daily_poison_name="absorción de vida"            }
,   ["RAVAGE_HEALTH"          ] = { trait_index=02, name="Reducción de salud"       , master_potion="esencia de reducción de salud"     , master_poison="Veneno de daño a la salud IX"      , daily_potion_name="reducción de salud"           , daily_poison_name="daño a la salud"              , daily_poison_name2="daño a la salud"              }
,   ["RESTORE_MAGICKA"        ] = { trait_index=03, name="Restauración de magia"    , master_potion="esencia de magia"                  , master_poison="Veneno de absorción de magia IX"   , daily_potion_name="magia"                        , daily_poison_name="absorción de magia"           }
,   ["RAVAGE_MAGICKA"         ] = { trait_index=04, name="Reducción de magia"       , master_potion="esencia de reducción de magia"     , master_poison="Veneno de daño a la magia IX"      , daily_potion_name="reducción de magia"           , daily_poison_name="daño a la magia"              , daily_poison_name2="reducción de magia"            }
,   ["RESTORE_STAMINA"        ] = { trait_index=05, name="Restauración de aguante"  , master_potion="esencia de aguante"                , master_poison="Veneno de absorción de aguante IX" , daily_potion_name="aguante"                      , daily_poison_name="absorción de aguante"         }
,   ["RAVAGE_STAMINA"         ] = { trait_index=06, name="Reducción de aguante"     , master_potion="esencia de reducción de aguante"   , master_poison="Veneno de daño al aguante IX"      , daily_potion_name="reducción de aguante"         , daily_poison_name="daño al aguante"              , daily_poison_name2="daño al aguante"               }
,   ["SPELL_RESISTANCE"       ] = { trait_index=07, name="Aumento de resistencia mágica", master_potion="esencia de's protección mágica"    , master_poison="Veneno de absorción del custodio IX"}
,   ["BREACH"                 ] = { trait_index=08, name="La Grieta"                , master_potion="Estrago de protección mágica esencia de", master_poison="Veneno perforador IX"              }
,   ["INCREASE_ARMOR"         ] = { trait_index=09, name="Aumento de armadura"      , master_potion="esencia de's armadura"             , master_poison="Veneno de absorción resolutorio IX"}
,   ["FRACTURE"               ] = { trait_index=10, name="Fracture"                 , master_potion="esencia de estrago de armadura"    , master_poison="Veneno fracturador IX"             }
,   ["INCREASE_SPELL_POWER"   ] = { trait_index=11, name="Aumento de poder mágico"  , master_potion="esencia de potencia de hechizo"    , master_poison="Veneno de absorción del hechicero IX"}
,   ["COWARDICE"              ] = { trait_index=12, name="Cobardía"                 , master_potion="esencia de cobardía"               , master_poison="Veneno de cobardía IX"             }
,   ["INCREASE_WEAPON_POWER"  ] = { trait_index=13, name="Aumento del poder físico" , master_potion="esencia de poder del arma"         , master_poison="Veneno de absorción de brutalidad IX"}
,   ["MAIM"                   ] = { trait_index=14, name="Mutilación"               , master_potion="esencia de mutilación"             , master_poison="Veneno de mutilación IX"           }
,   ["SPELL_CRITICAL"         ] = { trait_index=15, name="Crítico mágico"           , master_potion="esencia de crítico mágico"         , master_poison="Veneno de absorción profética IX"  }
,   ["UNCERTAINTY"            ] = { trait_index=16, name="Incertidumbre"            , master_potion="esencia de incertidumbre"          , master_poison="Veneno de incertidumbre IX"        }
,   ["WEAPON_CRITICAL"        ] = { trait_index=17, name="Crítico físico"           , master_potion="esencia de crítico físico"         , master_poison="Veneno de absorción de salvajismo IX"}
,   ["ENERVATION"             ] = { trait_index=18, name="Debilitación"             , master_potion="enervación esencia de"             , master_poison="Veneno enervante IX"               }
,   ["UNSTOPPABLE"            ] = { trait_index=19, name="Imparable"                , master_potion="esencia de inmovilidad"            , master_poison="Veneno del escapista IX"           }
,   ["ENTRAPMENT"             ] = { trait_index=20, name="Captura"                  , master_potion="esencia de captura"                , master_poison="Veneno enredador IX"               }
,   ["DETECTION"              ] = { trait_index=21, name="Detección"                , master_potion="esencia de detección"              , master_poison="Veneno de absorción de sigilo IX"  }
,   ["INVISIBLE"              ] = { trait_index=22, name="Invisible"                , master_potion="esencia de invisibilidad"          , master_poison="Revealing Poison IX"               }
,   ["SPEED"                  ] = { trait_index=23, name="Velocidad"                , master_potion="esencia de velocidad"              , master_poison="Veneno de absorción de velocidad IX"}
,   ["HINDRANCE"              ] = { trait_index=24, name="Torpeza"                  , master_potion="estorbo esencia de"                , master_poison="Slowing Poison IX"                 }
,   ["PROTECTION"             ] = { trait_index=25, name="Protection"               , master_potion="esencia de Protección"             , master_poison="Veneno anti-protección IX"         }
,   ["VULNERABILITY"          ] = { trait_index=26, name="Vulnerabilidad"           , master_potion="esencia de vulnerabilidad"         , master_poison="Veneno de vulnerabilidad IX"       }
,   ["LINGERING_HEALTH"       ] = { trait_index=27, name="Salud prolongada"         , master_potion="esencia de Salud prolongada"       , master_poison="Veneno de absorción progresiva de salud IX"}
,   ["GRADUAL_RAVAGE_HEALTH"  ] = { trait_index=28, name="Reducción de salud insidioso", master_potion="Estrago progresivo de salud esencia de", master_poison="Veneno de daño progresivo de salud IX"}
,   ["VITALITY"               ] = { trait_index=29, name="Vitalidad"                , master_potion="esencia de vitalidad"              , master_poison="veneno de absorción de vitalidad^z IX^z"}
,   ["DEFILE"                 ] = { trait_index=30, name="Profanación"              , master_potion="esencia de Profanación"            , master_poison="Veneno marchitador IX"             }
}


-- Craftable Sets ------------------------------------------------------------
--
-- set_id       writ4 field for master writs
--
LibCraftText.SET = {
    ["ADEPT_RIDER"              ] = { name="Jinete adepto"              , set_id=385 }
,   ["ALESSIAS_BULWARK"         ] = { name="Baluarte de Alessia"        , set_id= 82 }
,   ["ARMOR_MASTER"             ] = { name="Maestro armero"             , set_id=178 }
,   ["ARMOR_OF_THE_SEDUCER"     ] = { name="Armadura de la Seductora"   , set_id= 43 }
,   ["ASHEN_GRIP"               ] = { name="Control de cenizas"         , set_id= 54 }
,   ["ASSASSINS_GUILE"          ] = { name="Astucia de asesino"         , set_id=323 }
,   ["CLEVER_ALCHEMIST"         ] = { name="Alquimista astuto"          , set_id=225 }
,   ["DAEDRIC_TRICKERY"         ] = { name="Engaño daédrico"            , set_id=324 }
,   ["DEATHS_WIND"              ] = { name="Viento Efímero"             , set_id= 37 }
,   ["ETERNAL_HUNT"             ] = { name="Caza Eterna"                , set_id=226 }
,   ["EYES_OF_MARA"             ] = { name="Ojos de Mara"               , set_id= 87 }
,   ["FORTIFIED_BRASS"          ] = { name="Cobre reforzado"            , set_id=352 }
,   ["GRAVE_STAKE_COLLECTOR"    ] = { name="Grave-Stake Collector"      , set_id=408 }
,   ["HIST_BARK"                ] = { name="Corteza de Hist"            , set_id= 78 }
,   ["HUNDINGS_RAGE"            ] = { name="Rabia de Hunding"           , set_id= 80 }
,   ["INNATE_AXIOM"             ] = { name="Axioma innato"              , set_id=351 }
,   ["KAGRENACS_HOPE"           ] = { name="Esperanza de Kagrenac"      , set_id= 92 }
,   ["KVATCH_GLADIATOR"         ] = { name="Gladiador de Kvatch"        , set_id=240 }
,   ["LAW_OF_JULIANOS"          ] = { name="Ley de Julianos"            , set_id=207 }
,   ["MAGNUS_GIFT"              ] = { name="Regalo de Magnus"           , set_id= 48 }
,   ["MECHANICAL_ACUITY"        ] = { name="Agudeza mecánica"           , set_id=353 }
,   ["MIGHT_OF_THE_LOST_LEGION" ] = { name="Might of the Lost Legion"   , set_id=410 }
,   ["MORKULDIN"                ] = { name="Morkuldin"                  , set_id=219 }
,   ["NAGA_SHAMAN"              ] = { name="Naga Shaman"                , set_id=409 }
,   ["NIGHT_MOTHERS_GAZE"       ] = { name="Mirada de la Madre Noche"   , set_id= 51 }
,   ["NIGHTS_SILENCE"           ] = { name="Silencio Noctívago"         , set_id= 40 }
,   ["NOBLES_CONQUEST"          ] = { name="Conquista del Noble"        , set_id=176 }
,   ["NOCTURNALS_FAVOR"         ] = { name="Favor de Nocturnal"         , set_id=387 }
,   ["OBLIVIONS_FOE"            ] = { name="Enemigo de Oblivion"        , set_id= 73 }
,   ["ORGNUMS_SCALES"           ] = { name="Escamas de Orgnum"          , set_id= 84 }
,   ["PELINALS_APTITUDE"        ] = { name="Aptitud de Pelinal"         , set_id=242 }
,   ["REDISTRIBUTOR"            ] = { name="Redistribuidor"             , set_id=177 }
,   ["SHACKLEBREAKER"           ] = { name="Rompecadenas"               , set_id=325 }
,   ["SHALIDORS_CURSE"          ] = { name="Maldición de Shalidor"      , set_id= 95 }
,   ["SLOADS_SEMBLANCE"         ] = { name="Semblanza de Sload"         , set_id=386 }
,   ["SONG_OF_LAMAE"            ] = { name="Canción de Lamae"           , set_id= 81 }
,   ["SPECTRES_EYE"             ] = { name="Ojo del Espectro"           , set_id= 74 }
,   ["TAVAS_FAVOR"              ] = { name="Favor de Tava"              , set_id=224 }
,   ["TORUGS_PACT"              ] = { name="Pacto de Torug"             , set_id= 75 }
,   ["TRIAL_BY_FIRE"            ] = { name="Prueba de fuego"            , set_id=208 }
,   ["TWICE_BORN_STAR"          ] = { name="Estrella renacida"          , set_id=161 }
,   ["TWILIGHTS_EMBRACE"        ] = { name="Abrazo del Crepúsculo"      , set_id= 38 }
,   ["VAMPIRES_KISS"            ] = { name="Beso del Vampiro"           , set_id= 44 }
,   ["VARENS_LEGACY"            ] = { name="Legado de Varen"            , set_id=241 }
,   ["WAY_OF_THE_ARENA"         ] = { name="Senda de la Arena"          , set_id=148 }
,   ["WHITESTRAKES_RETRIBUTION" ] = { name="Castigo de Descarga Blanca" , set_id= 41 }
,   ["WILLOWS_PATH"             ] = { name="Sendero del Sauce"          , set_id= 79 }
}

-- Craftable Motifs ----------------------------------------------------------
--
-- writ6 field for master writs
--
LibCraftText.MOTIF = {
    ["BRETON"             ] = { name="Bretón"               , motif_id=  1 }
,   ["REDGUARD"           ] = { name="Guardia rojo"         , motif_id=  2 }
,   ["ORC"                ] = { name="Orco"                 , motif_id=  3 }
,   ["DARK_ELF"           ] = { name="Elfo oscuro"          , motif_id=  4 }
,   ["NORD"               ] = { name="Nórdico"              , motif_id=  5 }
,   ["ARGONIAN"           ] = { name="Argoniano"            , motif_id=  6 }
,   ["HIGH_ELF"           ] = { name="Alto elfo"            , motif_id=  7 }
,   ["WOOD_ELF"           ] = { name="Elfo del bosque"      , motif_id=  8 }
,   ["KHAJIIT"            ] = { name="Khajiit"              , motif_id=  9 }
,   ["UNIQUE"             ] = { name="Unique"               , motif_id= 10 }
,   ["THIEVES_GUILD"      ] = { name="Gremio de Ladrones"   , motif_id= 11 }
,   ["DARK_BROTHERHOOD"   ] = { name="Hermandad Oscura"     , motif_id= 12 }
,   ["MALACATH"           ] = { name="Malacath"             , motif_id= 13 }
,   ["DWEMER"             ] = { name="Dwemer"               , motif_id= 14 }
,   ["ANCIENT_ELF"        ] = { name="Elfo antiguo"         , motif_id= 15 }
,   ["ORDER_OF_THE_HOUR"  ] = { name="Orden de las Horas"   , motif_id= 16 }
,   ["BARBARIC"           ] = { name="Bárbaro"              , motif_id= 17 }
,   ["BANDIT"             ] = { name="Bandit"               , motif_id= 18 }
,   ["PRIMAL"             ] = { name="Primitivo"            , motif_id= 19 }
,   ["DAEDRIC"            ] = { name="Daédrico"             , motif_id= 20 }
,   ["TRINIMAC"           ] = { name="Trinimac"             , motif_id= 21 }
,   ["ANCIENT_ORC"        ] = { name="Orco antiguo"         , motif_id= 22 }
,   ["DAGGERFALL_COVENANT"] = { name="Convenio de Daggerfall", motif_id= 23 }
,   ["EBONHEART_PACT"     ] = { name="Pacto de Ebonheart"   , motif_id= 24 }
,   ["ALDMERI_DOMINION"   ] = { name="Dominio Aldmeri"      , motif_id= 25 }
,   ["MERCENARY"          ] = { name="Mercenario"           , motif_id= 26 }
,   ["CELESTIAL"          ] = { name="Celestial"            , motif_id= 27 }
,   ["GLASS"              ] = { name="Cristal"              , motif_id= 28 }
,   ["XIVKYN"             ] = { name="Xivkyn"               , motif_id= 29 }
,   ["SOUL_SHRIVEN"       ] = { name="Alma condenada"       , motif_id= 30 }
,   ["DRAUGR"             ] = { name="Draugr"               , motif_id= 31 }
,   ["MAORMER"            ] = { name="Maormer"              , motif_id= 32 }
,   ["AKAVIRI"            ] = { name="Akaviri"              , motif_id= 33 }
,   ["IMPERIAL"           ] = { name="Imperial"             , motif_id= 34 }
,   ["YOKUDAN"            ] = { name="Yokudan"              , motif_id= 35 }
,   ["UNIVERSAL"          ] = { name="Universal"            , motif_id= 36 }
,   ["REACH_WINTER"       ] = { name="Invierno de la Cuenca", motif_id= 37 }
,   ["TSAESCI"            ] = { name="Tsaesci"              , motif_id= 38 }
,   ["MINOTAUR"           ] = { name="Minotauro"            , motif_id= 39 }
,   ["EBONY"              ] = { name="Ébano"                , motif_id= 40 }
,   ["ABAHS_WATCH"        ] = { name="Guardia de Abah"      , motif_id= 41 }
,   ["SKINCHANGER"        ] = { name="Cambiapieles"         , motif_id= 42 }
,   ["MORAG_TONG"         ] = { name="Morag Tong"           , motif_id= 43 }
,   ["RA_GADA"            ] = { name="Ra Gada"              , motif_id= 44 }
,   ["DRO_MATHRA"         ] = { name="Dro-m'Athra"          , motif_id= 45 }
,   ["ASSASSINS_LEAGUE"   ] = { name="Liga de asesinos"     , motif_id= 46 }
,   ["OUTLAW"             ] = { name="Forajido"             , motif_id= 47 }
,   ["REDORAN"            ] = { name="Redoran"              , motif_id= 48 }
,   ["HLAALU"             ] = { name="Hlaalu"               , motif_id= 49 }
,   ["MILITANT_ORDINATOR" ] = { name="Ordenante militante"  , motif_id= 50 }
,   ["TELVANNI"           ] = { name="Telvanni"             , motif_id= 51 }
,   ["BUOYANT_ARMIGER"    ] = { name="Armígero Jovial"      , motif_id= 52 }
,   ["FROSTCASTER"        ] = { name="Magoscarcha"          , motif_id= 53 }
,   ["ASHLANDER"          ] = { name="Cenicio"              , motif_id= 54 }
,   ["WORM_CULT"          ] = { name="Culto del Gusano"     , motif_id= 55 }
,   ["SILKEN_RING"        ] = { name="Anillo de Seda"       , motif_id= 56 }
,   ["MAZZATUN"           ] = { name="Mazzatun"             , motif_id= 57 }
,   ["GRIM_HARLEQUIN"     ] = { name="Arlequín siniestro"   , motif_id= 58 }
,   ["HOLLOWJACK"         ] = { name="Hollowjack"           , motif_id= 59 }
,   ["REFABRICATED"       ] = { name="Refabricado"          , motif_id= 60 }
,   ["BLOODFORGE"         ] = { name="Forja de Sangre"      , motif_id= 61 }
,   ["DREADHORN"          ] = { name="Cuenorror"            , motif_id= 62 }
,   ["APOSTLE"            ] = { name="Apóstoles"            , motif_id= 65 }
,   ["EBONSHADOW"         ] = { name="Sombra de Ébano"      , motif_id= 66 }
,   ["UNDAUNTED"          ] = { name="Intrépidos"           , motif_id= 67 }
,   ["USE_ME"             ] = { name="USE ME"               , motif_id= 68 }
,   ["FANG_LAIR"          ] = { name="Guarida de los Colmillos", motif_id= 69 }
,   ["SCALECALLER"        ] = { name="Invocadora de Escamas", motif_id= 70 }
,   ["PSIJIC_ORDER"       ] = { name="Orden Psijic"         , motif_id= 71 }
,   ["SAPIARCH"           ] = { name="Sapiarca"             , motif_id= 72 }
,   ["WELKYNAR"           ] = { name="Welkynar"             , motif_id= 73 }
,   ["DREMORA"            ] = { name="Dremora"              , motif_id= 74 }
,   ["PYANDONEAN"         ] = { name="Pyandoneano"          , motif_id= 75 }
,   ["DIVINE_PROSECUTION" ] = { name="Divina Justicia"      , motif_id= 76 }
,   ["HUNTSMAN"           ] = { name="Huntsman"             , motif_id= 77 }
,   ["SILVER_DAWN"        ] = { name="Silver Dawn"          , motif_id= 78 }
,   ["DEAD_WATER"         ] = { name="Dead-Water"           , motif_id= 79 }
,   ["HONOR_GUARD"        ] = { name="Honor Guard"          , motif_id= 80 }
,   ["ELDER_ARGONIAN"     ] = { name="Elder Argonian"       , motif_id= 81 }
}


-- Miscellaneous conditions --------------------------------------------------

LibCraftText.DAILY.COND = {
    HINT_PR_BREWERS_COOKS_RECIPES = "Los cerveceros y los cocineros pueden proporcionar recetas"
,   DELIVER_GOODS_SUBSTRING       = "Entrega la mercancía"  
,   DELIVER_NEAREST_QUARTERMASTER = "Entrega la mercancía al intendente más cercano"
,   DELIVER_ALLIANCE_DEPOT        = "Deliver Goods to Alliance Supply Depot"
,   DELIVER_CONSORTIUM_TRADEPOST  = "Deliver Goods to Consortium Tradepost"
,   DELIVER_REFUGEE_RELIEF        = "Deliver Goods to Refugee Relief Site"
,   DELIVER_FIGHTERS_GUILD        = "Deliver Goods to Fighters Guild Provisioner"
}

LibCraftText.MASTER.COND = {
    TRAVEL_AD       = "Reúnete con tu contacto en Raíz de Elden"    -- "Travel to Elden Root to Meet Your Contact"
,   TRAVEL_DC       = "Reúnete con tu contacto en Quietud"          -- "Travel to Wayrest to Meet Your Contact"
,   TRAVEL_EP       = "Reúnete con tu contacto en El Duelo"         -- "Travel to Mournhold to Meet Your Contact"

,   DELIVER_AL      = "Entrega la mezcla"                           -- "Deliver the Concoction"
,   DELIVER_EN      = "Entrega el glifo"                            -- "Deliver the Glyph"
,   DELIVER_PR      = "Entrega el festín"                           -- "Deliver the Feast"
,   DELIVER_WEAPON  = "Entrega el arma"                             -- "Deliver the Weapon"
,   DELIVER_ARMOR   = "Entrega la armadura"                         -- "Deliver the Armor"
,   DELIVER_JW      = "Entrega la joya"                             -- "Deliver the Jewelry"
}


-- Random Unsorted Stuff -----------------------------------------------------

LibCraftText.MASTER_LABELS = {
    ["quality"] =  "Calidad"                         -- "Quality"
,   ["set"    ] =  "Set"                             -- "Set"
,   ["style"  ] =  "Estilo"                          -- "Style"
,   ["trait"  ] =  "Rasgo"                           -- "Trait"
}

LibCraftText.QUALITY = {
    ["NORMAL"   ] = { name="Normal"     , index=ITEM_QUALITY_NORMAL         or 1 }
,   ["FINE"     ] = { name="Bueno"      , index=ITEM_QUALITY_FINE           or 2 }
,   ["SUPERIOR" ] = { name="Superior"   , index=ITEM_QUALITY_SUPERIOR       or 3 }
,   ["EPIC"     ] = { name="Épico"      , index=ITEM_QUALITY_EPIC           or 4 }
,   ["LEGENDARY"] = { name="Legendario" , index=ITEM_QUALITY_LEGENDARY      or 5 }
}


-- Quest and Dialog Text -----------------------------------------------------

LibCraftText.DAILY.QUEST_NAME = {
    [bs] = "Encargo de herrería"                -- "Blacksmith Writ"
,   [cl] = "Encargo de sastrería"               -- "Clothier Writ"
,   [en] = "Encargo de encantamiento"           -- "Enchanter Writ"
,   [al] = "Encargo de alquimia"                -- "Alchemist Writ"
,   [pr] = "Encargo de provisiones"             -- "Provisioner Writ"
,   [ww] = "Encargo de carpintería"             -- "Woodworker Writ"
,   [jw] = "Encargo de artesanía de joyería"    -- "Jewelry Crafting Writ"
}
                        -- SURPRISE! "A Masterful Weapon" is used by both
                        -- Blacksmithing and Woodworking.
                        --
                        -- Why a list? Because BS, CL, and WW can all use
                        -- different quest titles depending on what item they
                        -- requested (armor vs. weapon, light vs. medium armor)
                        --
LibCraftText.MASTER.QUEST_NAME = {
    [bs] = { "Una protección magistral"           -- "A Masterful Plate"
           , "Un arma magistral"                } -- "A Masterful Weapon"
,   [cl] = { "Una prenda de tela magistral"       -- "Masterful Tailoring"
           , "Una prenda de cuero magistral"    } -- "Masterful Leatherwear"
,   [en] = { "Un glifo magistral"               } -- "A Masterful Glyph"
,   [al] = { "Una mezcla magistral"             } -- "A Masterful Concoction"
,   [pr] = { "Un festín magistral"              } -- "A Masterful Feast"
,   [ww] = { "Un escudo magistral"                -- "A Masterful Shield"
           , "Un arma magistral"                } -- "A Masterful Weapon"
,   [jw] = { "Joyería magistral"                } -- "Masterful Jewelry"
}

LibCraftText.DAILY.DIALOG = {
    ["OPTION_ACCEPT"      ] = "<Coger un encargo del tablón.>"          -- "<Pull a Writ from the Board.>"
,   ["OPTION_FINISH_SIGN" ] = "<Firmar el manifiesto.>"                 -- "<Sign the Manifest.>"
,   ["OPTION_FINISH_PLACE"] = "<Colocar los objetos dentro de la caja.>"-- "<Place the goods within the crate.>"
,   ["GOAL_SIGN"          ] = "Firma el manifiesto de entrega"          -- "Sign Delivery Manifest"
}

LibCraftText.MASTER.DIALOG = {
    ["OPTION_ACCEPT"      ] = { "<Aceptar el contrato.>"                -- "<Accept the contract.>"
                              , "<Aceptar el contrato.>"                -- "<Accept the contract>"  (FR French omits the period sometimes)
                              }
,   ["ROLIS_NAME"         ] = "Rolis Hlaalu"                            -- "Rolis Hlaalu"
,   ["TITLE_ROLIS"        ] = "-Rolis Hlaalu-"                          -- "-Rolis Hlaalu-"
,   ["OPTION_STORE"       ] = "Tienda (Intermediario de maestros artesanos)"-- "Store (Mastercraft Mediator)"
,   ["OPTION_FINISH_JOB"  ] = "<Terminar el trabajo>"                   -- "<Finish the job.>"
,   ["RESPONSE_ENDING"    ] = "<Observa tu trabajo y te entrega el pago.>"-- "<He notes your work and tenders payment.>"
}

LibCraftText.DAILY.DIALOG.TITLE_OFFER = {
    "-Encargos de equipamiento artesanal-"        -- "-Equipment Crafting Writs-"
,   "-Encargos de consumibles artesanales-"       -- "-Consumables Crafting Writs-"
}

LibCraftText.MASTER.DIALOG.TITLE_OFFER = {
    [bs] = "-Encargo de herrería sellado-"        -- "-Sealed Blacksmithing Writ-"
,   [cl] = "-Encargo de sastrería sellado-"       -- "-Sealed Clothier Writ-"
,   [en] = "-Encargo de encantamiento sellado-"   -- "-Sealed Enchanting Writ-"
,   [al] = "-Encargo de alquimia sellado-"        -- "-Sealed Alchemy Writ-"
,   [pr] = " -Encargo de cocina sellado-"         -- "-Sealed Provisioning Writ-"
,   [ww] = "-Encargo de carpintería sellado-"     -- "-Sealed Woodworking Writ-"
,   [jw] = "-Encargo de joyería sellado-"         -- "-Sealed Jewelry Crafter Writ-"
}

LibCraftText.DAILY.DIALOG.TITLE_TURN_IN = {
    [bs] = "-Caja de entregas de herrero-"        -- "-Blacksmith Delivery Crate-"
,   [cl] = "-Caja de entregas de sastre-"         -- "-Clothier Delivery Crate-"
,   [en] = "-Caja de entregas de encantador-"     -- "-Enchanter Delivery Crate-"
,   [al] = "-Caja de entregas de alquimista-"     -- "-Alchemist Delivery Crate-"
,   [pr] = "-Caja de entregas de cocina-"         -- "-Provisioner Delivery Crate-"
,   [ww] = "-Caja de entregas de carpintero-"     -- "-Woodworker Delivery Crate-"
,   [jw] = "-Caja de entrega de joyería-"         -- "-Jewelry Crafting Delivery Crate-"
}

LibCraftText.DAILY.DIALOG.OPTION_EXAMINE = {
    [bs] = "<Revisar los encargos de herrería.>"  -- "<Examine the Blacksmith Writs.>"
,   [cl] = "<Revisar los encargos de sastrería.>" -- "<Examine the Clothier Writs.>"
,   [en] = "<Revisar los encargos de encantamiento.>"-- "<Examine the Enchanter Writs.>"
,   [al] = "<Revisar los encargos de alquimia.>"  -- "<Examine the Alchemist Writs.>"
,   [pr] = "<Revisar los encargos de cocina.>"    -- "<Examine the Provisioner Writs.>"
,   [ww] = "<Revisar los encargos de carpintería.>"-- "<Examine the Woodworker Writs.>"
,   [jw] = "<Examine the Jewelry Crafting Writs.>"-- "<Examine the Jewelry Crafting Writs.>"
}

LibCraftText.MASTER.DIALOG.OPTION_FINISH = {
    [bs] = "He terminado el trabajo de herrería." -- "I've finished the Blacksmithing job."
,   [cl] = "He terminado el trabajo de sastrería."-- "I've finished the Clothier job."
,   [en] = "He terminado el trabajo de encantamiento."-- "I've finished the Enchanting job."
,   [al] = "He terminado el trabajo de alquimia." -- "I've finished the Alchemy job."
,   [pr] = "He terminado el encargo de cocina."   -- "I've finished the Provisioning job."
,   [ww] = "He terminado el trabajo de carpintería."-- "I've finished the Woodworking job."
,   [jw] = "He terminado el trabajo de joyería."  -- "I've finished the Jewelry job."
}
