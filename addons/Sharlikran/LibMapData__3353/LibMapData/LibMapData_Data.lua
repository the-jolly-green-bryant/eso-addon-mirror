local lib = _G["LibMapData"]

LIBMAPDATA_TAMRIEL_PSEUDOMAPINDEX = 1
LIBMAPDATA_GLENUMBRA_PSEUDOMAPINDEX = 2
LIBMAPDATA_RIVENSPIRE_PSEUDOMAPINDEX = 3
LIBMAPDATA_STORMHAVEN_PSEUDOMAPINDEX = 4
LIBMAPDATA_ALIKR_DESERT_PSEUDOMAPINDEX = 5
LIBMAPDATA_BANGKORAI_PSEUDOMAPINDEX = 6
LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX = 7
LIBMAPDATA_MALABAL_TOR_PSEUDOMAPINDEX = 8
LIBMAPDATA_SHADOWFEN_PSEUDOMAPINDEX = 9
LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX = 10
LIBMAPDATA_STONEFALLS_PSEUDOMAPINDEX = 11
LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX = 12
LIBMAPDATA_EASTMARCH_PSEUDOMAPINDEX = 13
LIBMAPDATA_CYRODIIL_PSEUDOMAPINDEX = 14
LIBMAPDATA_AURIDON_PSEUDOMAPINDEX = 15
LIBMAPDATA_GREENSHADE_PSEUDOMAPINDEX = 16
LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX = 17
LIBMAPDATA_BAL_FOYEN_PSEUDOMAPINDEX = 18
LIBMAPDATA_STROS_MKAI_PSEUDOMAPINDEX = 19
LIBMAPDATA_BETNIKH_PSEUDOMAPINDEX = 20
LIBMAPDATA_KHENARTHIS_ROOST_PSEUDOMAPINDEX = 21
LIBMAPDATA_BLEAKROCK_ISLE_PSEUDOMAPINDEX = 22
LIBMAPDATA_COLDHARBOUR_PSEUDOMAPINDEX = 23
LIBMAPDATA_THE_AURBIS_PSEUDOMAPINDEX = 24
LIBMAPDATA_CRAGLORN_PSEUDOMAPINDEX = 25
LIBMAPDATA_IMPERIAL_CITY_PSEUDOMAPINDEX = 26
LIBMAPDATA_WROTHGAR_PSEUDOMAPINDEX = 27
LIBMAPDATA_HEWS_BANE_PSEUDOMAPINDEX = 28
LIBMAPDATA_GOLD_COAST_PSEUDOMAPINDEX = 29
LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX = 30
LIBMAPDATA_CLOCKWORK_CITY_PSEUDOMAPINDEX = 31
LIBMAPDATA_SUMMERSET_PSEUDOMAPINDEX = 32
LIBMAPDATA_ARTAEUM_PSEUDOMAPINDEX = 33
LIBMAPDATA_MURKMIRE_PSEUDOMAPINDEX = 34
LIBMAPDATA_NORTHERN_ELSWEYR_PSEUDOMAPINDEX = 35
LIBMAPDATA_SOUTHERN_ELSWEYR_PSEUDOMAPINDEX = 36
LIBMAPDATA_WESTERN_SKYRIM_PSEUDOMAPINDEX = 37
LIBMAPDATA_BLACKREACH_GREYMOOR_CAVERNS_PSEUDOMAPINDEX = 38
LIBMAPDATA_BLACKREACH_PSEUDOMAPINDEX = 39
LIBMAPDATA_BLACKREACH_ARKTHZAND_CAVERN_PSEUDOMAPINDEX = 40
LIBMAPDATA_THE_REACH_PSEUDOMAPINDEX = 41
LIBMAPDATA_BLACKWOOD_PSEUDOMAPINDEX = 42
-- mapsData is fargraveData rather then shamblesData for 43
LIBMAPDATA_FARGRAVE_PSEUDOMAPINDEX = 43
LIBMAPDATA_THE_DEADLANDS_PSEUDOMAPINDEX = 44
LIBMAPDATA_HIGH_ISLE_PSEUDOMAPINDEX = 45
LIBMAPDATA_FARGRAVE_CITY_PSEUDOMAPINDEX = 46
LIBMAPDATA_GALEN_PSEUDOMAPINDEX = 47
LIBMAPDATA_TELVANNI_PENINSULA_PSEUDOMAPINDEX = 48
LIBMAPDATA_APOCRYPHA_PSEUDOMAPINDEX = 49
LIBMAPDATA_WESTWEALD_PSEUDOMAPINDEX = 50
LIBMAPDATA_EYEVEA_PSEUDOMAPINDEX = 51
LIBMAPDATA_SOLSTICE_PSEUDOMAPINDEX = 52

LIBMAPDATA_PSEUDOMAPINDEX_LOOKUP = {
  [1] = "LIBMAPDATA_TAMRIEL_PSEUDOMAPINDEX",
  [2] = "LIBMAPDATA_GLENUMBRA_PSEUDOMAPINDEX",
  [3] = "LIBMAPDATA_RIVENSPIRE_PSEUDOMAPINDEX",
  [4] = "LIBMAPDATA_STORMHAVEN_PSEUDOMAPINDEX",
  [5] = "LIBMAPDATA_ALIKR_DESERT_PSEUDOMAPINDEX",
  [6] = "LIBMAPDATA_BANGKORAI_PSEUDOMAPINDEX",
  [7] = "LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX",
  [8] = "LIBMAPDATA_MALABAL_TOR_PSEUDOMAPINDEX",
  [9] = "LIBMAPDATA_SHADOWFEN_PSEUDOMAPINDEX",
  [10] = "LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX",
  [11] = "LIBMAPDATA_STONEFALLS_PSEUDOMAPINDEX",
  [12] = "LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX",
  [13] = "LIBMAPDATA_EASTMARCH_PSEUDOMAPINDEX",
  [14] = "LIBMAPDATA_CYRODIIL_PSEUDOMAPINDEX",
  [15] = "LIBMAPDATA_AURIDON_PSEUDOMAPINDEX",
  [16] = "LIBMAPDATA_GREENSHADE_PSEUDOMAPINDEX",
  [17] = "LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX",
  [18] = "LIBMAPDATA_BAL_FOYEN_PSEUDOMAPINDEX",
  [19] = "LIBMAPDATA_STROS_MKAI_PSEUDOMAPINDEX",
  [20] = "LIBMAPDATA_BETNIKH_PSEUDOMAPINDEX",
  [21] = "LIBMAPDATA_KHENARTHIS_ROOST_PSEUDOMAPINDEX",
  [22] = "LIBMAPDATA_BLEAKROCK_ISLE_PSEUDOMAPINDEX",
  [23] = "LIBMAPDATA_COLDHARBOUR_PSEUDOMAPINDEX",
  [24] = "LIBMAPDATA_THE_AURBIS_PSEUDOMAPINDEX",
  [25] = "LIBMAPDATA_CRAGLORN_PSEUDOMAPINDEX",
  [26] = "LIBMAPDATA_IMPERIAL_CITY_PSEUDOMAPINDEX",
  [27] = "LIBMAPDATA_WROTHGAR_PSEUDOMAPINDEX",
  [28] = "LIBMAPDATA_HEWS_BANE_PSEUDOMAPINDEX",
  [29] = "LIBMAPDATA_GOLD_COAST_PSEUDOMAPINDEX",
  [30] = "LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX",
  [31] = "LIBMAPDATA_CLOCKWORK_CITY_PSEUDOMAPINDEX",
  [32] = "LIBMAPDATA_SUMMERSET_PSEUDOMAPINDEX",
  [33] = "LIBMAPDATA_ARTAEUM_PSEUDOMAPINDEX",
  [34] = "LIBMAPDATA_MURKMIRE_PSEUDOMAPINDEX",
  [35] = "LIBMAPDATA_NORTHERN_ELSWEYR_PSEUDOMAPINDEX",
  [36] = "LIBMAPDATA_SOUTHERN_ELSWEYR_PSEUDOMAPINDEX",
  [37] = "LIBMAPDATA_WESTERN_SKYRIM_PSEUDOMAPINDEX",
  [38] = "LIBMAPDATA_BLACKREACH_GREYMOOR_CAVERNS_PSEUDOMAPINDEX",
  [39] = "LIBMAPDATA_BLACKREACH_PSEUDOMAPINDEX",
  [40] = "LIBMAPDATA_BLACKREACH_ARKTHZAND_CAVERN_PSEUDOMAPINDEX",
  [41] = "LIBMAPDATA_THE_REACH_PSEUDOMAPINDEX",
  [42] = "LIBMAPDATA_BLACKWOOD_PSEUDOMAPINDEX",
  [43] = "LIBMAPDATA_FARGRAVE_PSEUDOMAPINDEX",
  [44] = "LIBMAPDATA_THE_DEADLANDS_PSEUDOMAPINDEX",
  [45] = "LIBMAPDATA_HIGH_ISLE_PSEUDOMAPINDEX",
  [46] = "LIBMAPDATA_FARGRAVE_CITY_PSEUDOMAPINDEX",
  [47] = "LIBMAPDATA_GALEN_PSEUDOMAPINDEX",
  [48] = "LIBMAPDATA_TELVANNI_PENINSULA_PSEUDOMAPINDEX",
  [49] = "LIBMAPDATA_APOCRYPHA_PSEUDOMAPINDEX",
  [50] = "LIBMAPDATA_WESTWEALD_PSEUDOMAPINDEX",
  [51] = "LIBMAPDATA_EYEVEA_PSEUDOMAPINDEX",
  [52] = "LIBMAPDATA_SOLSTICE_PSEUDOMAPINDEX",
}

lib.tamrielData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
}

lib.glenumbraData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = {
    [1] = {
      ["Impresario"] = {
        x = 0.3420265614,
        y = 0.7411329746,
      },
      ["Chef_Donolon"] = {
        x = 0.2082464247,
        y = 0.7187666893,
      },
    },
  },
  [1] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GLENUMBRA_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/glenumbra_base_0",
  },
  [65] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GLENUMBRA_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/badmanscave_base_0",
  },
  [531] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GLENUMBRA_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/aldcroft_base_0",
  },
  [99] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GLENUMBRA_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/badmansstart_base_0",
  },
  [724] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GLENUMBRA_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/dresankeep_base_0",
  },
  [64] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GLENUMBRA_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/cathbedraud_base_0",
  },
  [807] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GLENUMBRA_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/glenumbraoutlawrefuge_base_0",
  },
  [541] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GLENUMBRA_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/crosswych_base_0",
  },
  [228] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GLENUMBRA_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/minesofkhuras_base_0",
  },
  [237] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GLENUMBRA_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/ilessantower_base_0",
  },
  [235] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GLENUMBRA_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/cryptwatchfort_base_0",
  },
  [2044] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GLENUMBRA_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/rpb_map_ext001_0",
  },
  [174] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GLENUMBRA_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/spindleclutch_base_0",
  },
  [63] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GLENUMBRA_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/daggerfall_base_0",
  },
}

lib.rivenspireData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [513] = {
    ["pseudoMapIndex"] = LIBMAPDATA_RIVENSPIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "rivenspire/northpoint_base_0",
  },
  [2120] = {
    ["pseudoMapIndex"] = LIBMAPDATA_RIVENSPIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "rivenspire/lostshipyard_map001_0",
  },
  [10] = {
    ["pseudoMapIndex"] = LIBMAPDATA_RIVENSPIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "rivenspire/rivenspire_base_0",
  },
  [204] = {
    ["pseudoMapIndex"] = LIBMAPDATA_RIVENSPIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "rivenspire/erokii_base_0",
  },
  [528] = {
    ["pseudoMapIndex"] = LIBMAPDATA_RIVENSPIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "rivenspire/hoarfrost_base_0",
  },
  [244] = {
    ["pseudoMapIndex"] = LIBMAPDATA_RIVENSPIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "rivenspire/hildunessecretrefuge_base_0",
  },
  [85] = {
    ["pseudoMapIndex"] = LIBMAPDATA_RIVENSPIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "rivenspire/shornhelm_base_0",
  },
  [151] = {
    ["pseudoMapIndex"] = LIBMAPDATA_RIVENSPIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "rivenspire/cryptofhearts_base_0",
  },
  [216] = {
    ["pseudoMapIndex"] = LIBMAPDATA_RIVENSPIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "rivenspire/flyleafcatacombs_base_0",
  },
  [42] = {
    ["pseudoMapIndex"] = LIBMAPDATA_RIVENSPIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "rivenspire/obsidianscar_base_0",
  },
  [200] = {
    ["pseudoMapIndex"] = LIBMAPDATA_RIVENSPIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "rivenspire/orcsfingerruins_base_0",
  },
  [220] = {
    ["pseudoMapIndex"] = LIBMAPDATA_RIVENSPIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "rivenspire/tribulationcrypt_base_0",
  },
  [477] = {
    ["pseudoMapIndex"] = LIBMAPDATA_RIVENSPIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "rivenspire/shroudedpass_base_0",
  },
  [225] = {
    ["pseudoMapIndex"] = LIBMAPDATA_RIVENSPIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "rivenspire/crestshademine_base_0",
  },
  [812] = {
    ["pseudoMapIndex"] = LIBMAPDATA_RIVENSPIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "rivenspire/rivenspireoutlaw_base_0",
  },
}

lib.stormhavenData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [33] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STORMHAVEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "stormhaven/wayrest_base_0",
  },
  [194] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STORMHAVEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "stormhaven/norvulkruins_base_0",
  },
  [249] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STORMHAVEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "stormhaven/farangelsdelve_base_0",
  },
  [532] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STORMHAVEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "stormhaven/koeglinvillage_base_0",
  },
  [189] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STORMHAVEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "stormhaven/bonesnapruinssecret_base_0",
  },
  [238] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STORMHAVEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "stormhaven/portdunwatch_base_0",
  },
  [1432] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STORMHAVEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "stormhaven/ui_map_scalecaller001_base_0",
  },
  [297] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STORMHAVEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "stormhaven/windridgecave_base_0",
  },
  [34] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STORMHAVEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "stormhaven/alcairecastle_base_0",
  },
  [816] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STORMHAVEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "stormhaven/stormhavenoutlawrefuge_base_0",
  },
  [12] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STORMHAVEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "stormhaven/stormhaven_base_0",
  },
  [46] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STORMHAVEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "stormhaven/wayrestsewers_base_0",
  },
  [223] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STORMHAVEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "stormhaven/bearclawmine_base_0",
  },
}

lib.alikrDesertData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [224] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ALIKR_DESERT_PSEUDOMAPINDEX,
    ["mapTexture"] = "alikr/coldrockdiggings_base_0",
  },
  [226] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ALIKR_DESERT_PSEUDOMAPINDEX,
    ["mapTexture"] = "alikr/divadschagrinmine_base_0",
  },
  [3] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ALIKR_DESERT_PSEUDOMAPINDEX,
    ["mapTexture"] = "alikr/volenfell_base_0",
  },
  [773] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ALIKR_DESERT_PSEUDOMAPINDEX,
    ["mapTexture"] = "alikr/smugglerkingtunnel_base_0",
  },
  [774] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ALIKR_DESERT_PSEUDOMAPINDEX,
    ["mapTexture"] = "alikr/shorecave_base_0",
  },
  [231] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ALIKR_DESERT_PSEUDOMAPINDEX,
    ["mapTexture"] = "alikr/aldunz_base_0",
  },
  [233] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ALIKR_DESERT_PSEUDOMAPINDEX,
    ["mapTexture"] = "alikr/yldzuun_base_0",
  },
  [810] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ALIKR_DESERT_PSEUDOMAPINDEX,
    ["mapTexture"] = "alikr/alkiroutlawrefuge_base_0",
  },
  [76] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ALIKR_DESERT_PSEUDOMAPINDEX,
    ["mapTexture"] = "alikr/lostcity_base_0",
  },
  [336] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ALIKR_DESERT_PSEUDOMAPINDEX,
    ["mapTexture"] = "alikr/salasen_base_0",
  },
  [337] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ALIKR_DESERT_PSEUDOMAPINDEX,
    ["mapTexture"] = "alikr/imperviousvault_base_0",
  },
  [83] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ALIKR_DESERT_PSEUDOMAPINDEX,
    ["mapTexture"] = "alikr/sentinel_base_0",
  },
  [538] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ALIKR_DESERT_PSEUDOMAPINDEX,
    ["mapTexture"] = "alikr/kozanset_base_0",
  },
  [539] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ALIKR_DESERT_PSEUDOMAPINDEX,
    ["mapTexture"] = "alikr/bergama_base_0",
  },
  [230] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ALIKR_DESERT_PSEUDOMAPINDEX,
    ["mapTexture"] = "alikr/sandblownmine_base_0",
  },
  [246] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ALIKR_DESERT_PSEUDOMAPINDEX,
    ["mapTexture"] = "alikr/santaki_base_0",
  },
  [30] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ALIKR_DESERT_PSEUDOMAPINDEX,
    ["mapTexture"] = "alikr/alikr_base_0",
  },
}

lib.bangkoraiData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [418] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BANGKORAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "bangkorai/sunkenroad_base_0",
  },
  [420] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BANGKORAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "bangkorai/hallofheroes_base_0",
  },
  [1765] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BANGKORAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "bangkorai/unhallowedgravemap001_0",
  },
  [71] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BANGKORAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "bangkorai/razakswheel_base_0",
  },
  [360] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BANGKORAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "bangkorai/hallinsstand_base_0",
  },
  [591] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BANGKORAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "bangkorai/bisnensel_base_0",
  },
  [212] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BANGKORAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "bangkorai/cryptoftheexiles_base_0",
  },
  [245] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BANGKORAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "bangkorai/rubblebutte_base_0",
  },
  [229] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BANGKORAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "bangkorai/murciensclaim_base_0",
  },
  [232] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BANGKORAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "bangkorai/jaggerjaw_base_0",
  },
  [20] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BANGKORAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "bangkorai/bangkorai_base_0",
  },
  [347] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BANGKORAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "bangkorai/blackhearthavenarea1_base_0",
  },
  [1436] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BANGKORAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "bangkorai/ui_map_fanglairext_base_0",
  },
  [239] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BANGKORAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "bangkorai/trollstoothpick_base_0",
  },
  [84] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BANGKORAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "bangkorai/evermore_base_0",
  },
  [813] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BANGKORAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "bangkorai/bangkoraioutlawrefuge_base_0",
  },
}

lib.grahtwoodData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [512] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/haven_base_0",
  },
  [449] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/eldenrootmagesguilddown_base_0",
  },
  [450] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/eldenrootservices_base_0",
  },
  [451] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/eldenrootthroneroom_base_0",
  },
  [393] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/vindeathcave_base_0",
  },
  [395] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/mobarmine_base_0",
  },
  [396] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/burrootkwamamine_base_0",
  },
  [430] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/tombofanahbi_base_0",
  },
  [80] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/orrery_base_0",
  },
  [809] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/grahtwoodoutlawrefuge_base_0",
  },
  [1717] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/maarsoutsidemap001_base_0",
  },
  [406] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/reliquaryofstars_base_0",
  },
  [536] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/redfurtradingpost_base_0",
  },
  [9] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/grahtwood_base_0",
  },
  [405] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/caveofbrokensails_base_0",
  },
  [283] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/rootsunder_base_0",
  },
  [28] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/eldenhollow_base_0",
  },
  [445] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/eldenrootgroundfloor_base_0",
  },
  [446] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/eldenrootcrafting_base_0",
  },
  [571] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GRAHTWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "grahtwood/eldenrootfightersguildown_base_0",
  },
}

lib.malabalTorData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [271] = {
    ["pseudoMapIndex"] = LIBMAPDATA_MALABAL_TOR_PSEUDOMAPINDEX,
    ["mapTexture"] = "malabaltor/abamath_base_0",
  },
  [275] = {
    ["pseudoMapIndex"] = LIBMAPDATA_MALABAL_TOR_PSEUDOMAPINDEX,
    ["mapTexture"] = "malabaltor/velynharbor_base_0",
  },
  [820] = {
    ["pseudoMapIndex"] = LIBMAPDATA_MALABAL_TOR_PSEUDOMAPINDEX,
    ["mapTexture"] = "malabaltor/malabaltoroutlawrefuge_base_0",
  },
  [292] = {
    ["pseudoMapIndex"] = LIBMAPDATA_MALABAL_TOR_PSEUDOMAPINDEX,
    ["mapTexture"] = "malabaltor/tempestisland_base_0",
  },
  [199] = {
    ["pseudoMapIndex"] = LIBMAPDATA_MALABAL_TOR_PSEUDOMAPINDEX,
    ["mapTexture"] = "malabaltor/blackvineruins_base_0",
  },
  [990] = {
    ["pseudoMapIndex"] = LIBMAPDATA_MALABAL_TOR_PSEUDOMAPINDEX,
    ["mapTexture"] = "malabaltor/crimsoncove02_base_0",
  },
  [22] = {
    ["pseudoMapIndex"] = LIBMAPDATA_MALABAL_TOR_PSEUDOMAPINDEX,
    ["mapTexture"] = "malabaltor/malabaltor_base_0",
  },
  [282] = {
    ["pseudoMapIndex"] = LIBMAPDATA_MALABAL_TOR_PSEUDOMAPINDEX,
    ["mapTexture"] = "malabaltor/baandaritradingpost_base_0",
  },
  [534] = {
    ["pseudoMapIndex"] = LIBMAPDATA_MALABAL_TOR_PSEUDOMAPINDEX,
    ["mapTexture"] = "malabaltor/vulkwasten_base_0",
  },
  [221] = {
    ["pseudoMapIndex"] = LIBMAPDATA_MALABAL_TOR_PSEUDOMAPINDEX,
    ["mapTexture"] = "malabaltor/tomboftheapostates_base_0",
  },
  [222] = {
    ["pseudoMapIndex"] = LIBMAPDATA_MALABAL_TOR_PSEUDOMAPINDEX,
    ["mapTexture"] = "malabaltor/deadmansdrop_base_0",
  },
  [175] = {
    ["pseudoMapIndex"] = LIBMAPDATA_MALABAL_TOR_PSEUDOMAPINDEX,
    ["mapTexture"] = "malabaltor/crimsoncove_base_0",
  },
}

lib.shadowfenData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [544] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SHADOWFEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "shadowfen/altencorimont_base_0",
  },
  [135] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SHADOWFEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "shadowfen/skinstealerlair_base_0",
  },
  [137] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SHADOWFEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "shadowfen/templeofsul_base_0",
  },
  [138] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SHADOWFEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "shadowfen/whiteroseprison_base_0",
  },
  [139] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SHADOWFEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "shadowfen/loriasel_base_0",
  },
  [716] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SHADOWFEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "shadowfen/stormholdguildhall_map_0",
  },
  [1133] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SHADOWFEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "shadowfen/ui_cradleofshadowsint_001_base_0",
  },
  [144] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SHADOWFEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "shadowfen/sanguinesdemesne_base_0",
  },
  [561] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SHADOWFEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "shadowfen/mudtreemine_base_0",
  },
  [146] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SHADOWFEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "shadowfen/atanazruins_base_0",
  },
  [1127] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SHADOWFEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "shadowfen/ui_map_mazzatunext_base_0",
  },
  [217] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SHADOWFEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "shadowfen/stormhold_base_0",
  },
  [26] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SHADOWFEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "shadowfen/shadowfen_base_0",
  },
  [155] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SHADOWFEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "shadowfen/brokentuskcave_base_0",
  },
  [811] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SHADOWFEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "shadowfen/shadowfenoutlawrefuge_base_0",
  },
  [150] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SHADOWFEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "shadowfen/gandranen_base_0",
  },
  [141] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SHADOWFEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "shadowfen/arxcorinium_base_0",
  },
}

lib.deshaanData = {
  ["subZones"] = { },
  ["dungeons"] = { 118, 1152, 1153 },
  ["events"] = { },
  [118] = {
    ["mapTexture"] = "deshaan/darkshadecaverns_base_0",
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapScale"] = {
      zoom_factor = 0.0430215001,
      x = 0.7816408277,
      y = 0.5785392523,
    },
  },
  [1152] = {
    ["mapTexture"] = "deshaan/darkshadecaverns_base_0",
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapScale"] = {
      zoom_factor = 0.0430215001,
      x = 0.7816408277,
      y = 0.5785392523,
    },
  },
  -- not the main entrance, have not been here yet
  [1153] = {
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapTexture"] = "deshaan/darkshadecavernsheroic_base_0",
  },
  [2042] = {
    ["mapTexture"] = "deshaan/cauldronmapboss5_0",
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapScale"] = {
      zoom_factor = 0.0160155036,
      x = 0.0557703860,
      y = 0.5129439831,
    },
  },
  [128] = {
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapTexture"] = "deshaan/tribunaltemple_base_0",
  },
  [547] = {
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapTexture"] = "deshaan/obsidiangorge_base_0",
  },
  [714] = {
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapTexture"] = "deshaan/theshrineofstveloth_base_0",
  },
  [819] = {
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapTexture"] = "deshaan/mournholdoutlawsrefuge_base_0",
  },
  [13] = {
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapTexture"] = "deshaan/deshaan_base_0",
  },
  [191] = {
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapTexture"] = "deshaan/bthanual_base_0",
  },
  [115] = {
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapTexture"] = "deshaan/forgottencrypts_base_0",
  },
  [1968] = {
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapTexture"] = "deshaan/cauldronmapboss5_0",
  },
  [117] = {
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapTexture"] = "deshaan/eidolonshollow2_base_0",
  },
  [119] = {
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapTexture"] = "deshaan/kwamacolony_base_0",
  },
  [120] = {
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapTexture"] = "deshaan/triplecirclemine_base_0",
  },
  [537] = {
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapTexture"] = "deshaan/narsis_base_0",
  },
  [131] = {
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapTexture"] = "deshaan/taldeiccrypts_base_0",
  },
  [123] = {
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapTexture"] = "deshaan/desolatecave_base_0",
  },
  [205] = {
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapTexture"] = "deshaan/mournhold_base_0",
  },
  [126] = {
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapTexture"] = "deshaan/deepcragden_base_0",
  },
  [127] = {
    ["pseudoMapIndex"] = LIBMAPDATA_DESHAAN_PSEUDOMAPINDEX,
    ["mapTexture"] = "deshaan/mzithumz_base_0",
  },
}

lib.stonefallsData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = {
    [7] = {
      ["Impresario"] = {
        x = 0.9201570153,
        y = 0.4024004340,
      },
      ["Chef_Donolon"] = {
        x = 0.7826786637,
        y = 0.2969335913,
      },
      ["Witchmother Olyve"] = {
        x = 0.4950504899,
        y = 0.7059394121,
      },
      ["Witchmother Taerma"] = {
        x = 0.4963544607,
        y = 0.7065058946,
      },
    },
  },
  [786] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STONEFALLS_PSEUDOMAPINDEX,
    ["mapTexture"] = "stonefalls/tormented_spire_base_0",
  },
  [7] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STONEFALLS_PSEUDOMAPINDEX,
    ["mapTexture"] = "stonefalls/stonefalls_base_0",
  },
  [72] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STONEFALLS_PSEUDOMAPINDEX,
    ["mapTexture"] = "stonefalls/crowswood_base_0",
  },
  [510] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STONEFALLS_PSEUDOMAPINDEX,
    ["mapTexture"] = "stonefalls/kragenmoor_base_0",
  },
  [24] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STONEFALLS_PSEUDOMAPINDEX,
    ["mapTexture"] = "stonefalls/davonswatch_base_0",
  },
  [109] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STONEFALLS_PSEUDOMAPINDEX,
    ["mapTexture"] = "guildmaps/fortvirakruin_base_0",
  },
  [77] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STONEFALLS_PSEUDOMAPINDEX,
    ["mapTexture"] = "stonefalls/fungalgrotto_base_0",
  },
  [814] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STONEFALLS_PSEUDOMAPINDEX,
    ["mapTexture"] = "stonefalls/stonefallsoutlawrefuge_base_0",
  },
  [511] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STONEFALLS_PSEUDOMAPINDEX,
    ["mapTexture"] = "stonefalls/ebonheart_base_0",
  },
}

lib.theRiftData = {
  ["subZones"] = { },
  ["events"] = { },
  ["dungeons"] = { },
  [198] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX,
    ["mapTexture"] = "therift/riften_base_0",
  },
  [214] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX,
    ["mapTexture"] = "therift/ebonmeretower_base_0",
  },
  [142] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX,
    ["mapTexture"] = "therift/thelionsden_base_0",
  },
  [655] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX,
    ["mapTexture"] = "therift/trolhettasummit_base_0",
  },
  [177] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX,
    ["mapTexture"] = "therift/northwindmine_base_0",
  },
  [815] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX,
    ["mapTexture"] = "therift/riftoutlaw_base_0",
  },
  [211] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX,
    ["mapTexture"] = "therift/shroudhearth_base_0",
  },
  [176] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX,
    ["mapTexture"] = "therift/trolhettacave_base_0",
  },
  [277] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX,
    ["mapTexture"] = "therift/shorsstonemine_base_0",
  },
  [254] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX,
    ["mapTexture"] = "therift/fortgreenwall_base_0",
  },
  [125] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX,
    ["mapTexture"] = "therift/therift_base_0",
  },
  [543] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX,
    ["mapTexture"] = "therift/nimalten_base_0",
  },
  [218] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX,
    ["mapTexture"] = "therift/pinepeakcaverns_base_0",
  },
  [2363] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX,
    ["mapTexture"] = "therift/u37_scrivenershall_sect1baseme_0",
  },
  [397] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX,
    ["mapTexture"] = "therift/blessedcrucible1_base_0",
  },
  [509] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX,
    ["mapTexture"] = "therift/taarengrav_base_0",
  },
  [542] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX,
    ["mapTexture"] = "therift/shorsstone_base_0",
  },
  [703] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_RIFT_PSEUDOMAPINDEX,
    ["mapTexture"] = "therift/brokenhelm_base_0",
  },
}

lib.eastmarchData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = {
    [61] = {
      ["Petronius Galenus"] = {
        x = 0.48735749721527,
        y = 0.37827250361443,
      },
      ["Breda"] = {
        x = 0.48691499233246,
        y = 0.38149499893188,
      },
      ["Selvari Abello"] = {
        x = 0.48738500475883,
        y = 0.38356500864029,
      },
      ["Raeififeh"] = {
        x = 0.48627999424934,
        y = 0.37936249375343,
      },
    },
  },
  [578] = {
    ["pseudoMapIndex"] = LIBMAPDATA_EASTMARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "eastmarch/fortamol_base_0",
  },
  [348] = {
    ["pseudoMapIndex"] = LIBMAPDATA_EASTMARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "eastmarch/direfrostkeep_base_0",
  },
  [164] = {
    ["pseudoMapIndex"] = LIBMAPDATA_EASTMARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "eastmarch/icehammersvault_base_0",
  },
  [165] = {
    ["pseudoMapIndex"] = LIBMAPDATA_EASTMARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "eastmarch/oldsordscave_base_0",
  },
  [167] = {
    ["pseudoMapIndex"] = LIBMAPDATA_EASTMARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "eastmarch/thebastardstomb_base_0",
  },
  [160] = {
    ["pseudoMapIndex"] = LIBMAPDATA_EASTMARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "eastmarch/windhelm_base_0",
  },
  [1607] = {
    ["pseudoMapIndex"] = LIBMAPDATA_EASTMARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "eastmarch/ui_map_frvfrstvlt01_base_0",
  },
  [61] = {
    ["pseudoMapIndex"] = LIBMAPDATA_EASTMARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "eastmarch/eastmarch_base_0",
  },
  [822] = {
    ["pseudoMapIndex"] = LIBMAPDATA_EASTMARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "eastmarch/eastmarchrefuge_base_0",
  },
  [156] = {
    ["pseudoMapIndex"] = LIBMAPDATA_EASTMARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "eastmarch/lostknifecave_base_0",
  },
  [140] = {
    ["pseudoMapIndex"] = LIBMAPDATA_EASTMARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "eastmarch/hallofthedead_base_0",
  },
  [159] = {
    ["pseudoMapIndex"] = LIBMAPDATA_EASTMARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "eastmarch/mzulft_base_0",
  },
}

lib.cyrodiilData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [576] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CYRODIIL_PSEUDOMAPINDEX,
    ["mapTexture"] = "cyrodiil/westelsweyrgate_base_0",
  },
  [577] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CYRODIIL_PSEUDOMAPINDEX,
    ["mapTexture"] = "cyrodiil/eastelsweyrgate_base_0",
  },
  [573] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CYRODIIL_PSEUDOMAPINDEX,
    ["mapTexture"] = "cyrodiil/northmorrowgate_base_0",
  },
  [16] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CYRODIIL_PSEUDOMAPINDEX,
    ["mapTexture"] = "cyrodiil/ava_whole_0",
  },
  [572] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CYRODIIL_PSEUDOMAPINDEX,
    ["mapTexture"] = "cyrodiil/northhighrockgate_base_0",
  },
  [574] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CYRODIIL_PSEUDOMAPINDEX,
    ["mapTexture"] = "cyrodiil/southmorrowgate_base_0",
  },
  [575] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CYRODIIL_PSEUDOMAPINDEX,
    ["mapTexture"] = "cyrodiil/southhighrockgate_base_0",
  },
}

lib.auridonData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = {
    [143] = {
      ["Impresario"] = {
        x = 0.6482877135,
        y = 0.8675177097,
      },
      ["Chef_Donolon"] = {
        x = 0.6562538146,
        y = 0.9370744824,
      },
    },
  },
  [545] = {
    ["pseudoMapIndex"] = LIBMAPDATA_AURIDON_PSEUDOMAPINDEX,
    ["mapTexture"] = "auridon/skywatch_base_0",
  },
  [178] = {
    ["pseudoMapIndex"] = LIBMAPDATA_AURIDON_PSEUDOMAPINDEX,
    ["mapTexture"] = "auridon/delsclaim_base_0",
  },
  [243] = {
    ["pseudoMapIndex"] = LIBMAPDATA_AURIDON_PSEUDOMAPINDEX,
    ["mapTexture"] = "auridon/vulkhelguard_base_0",
  },
  [180] = {
    ["pseudoMapIndex"] = LIBMAPDATA_AURIDON_PSEUDOMAPINDEX,
    ["mapTexture"] = "auridon/bewan_base_0",
  },
  [182] = {
    ["pseudoMapIndex"] = LIBMAPDATA_AURIDON_PSEUDOMAPINDEX,
    ["mapTexture"] = "auridon/mehrunesspite_base_0",
  },
  [279] = {
    ["pseudoMapIndex"] = LIBMAPDATA_AURIDON_PSEUDOMAPINDEX,
    ["mapTexture"] = "auridon/thebanishedcells_base_0",
  },
  [808] = {
    ["pseudoMapIndex"] = LIBMAPDATA_AURIDON_PSEUDOMAPINDEX,
    ["mapTexture"] = "auridon/auridonoutlawrefuge_base_0",
  },
  [268] = {
    ["pseudoMapIndex"] = LIBMAPDATA_AURIDON_PSEUDOMAPINDEX,
    ["mapTexture"] = "auridon/toothmaulgully_base_0",
  },
  [540] = {
    ["pseudoMapIndex"] = LIBMAPDATA_AURIDON_PSEUDOMAPINDEX,
    ["mapTexture"] = "auridon/firsthold_base_0",
  },
  [143] = {
    ["pseudoMapIndex"] = LIBMAPDATA_AURIDON_PSEUDOMAPINDEX,
    ["mapTexture"] = "auridon/auridon_base_0",
  },
}

lib.greenshadeData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [529] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GREENSHADE_PSEUDOMAPINDEX,
    ["mapTexture"] = "greenshade/woodhearth_base_0",
  },
  [387] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GREENSHADE_PSEUDOMAPINDEX,
    ["mapTexture"] = "greenshade/marbruk_base_0",
  },
  [300] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GREENSHADE_PSEUDOMAPINDEX,
    ["mapTexture"] = "greenshade/greenshade_base_0",
  },
  [374] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GREENSHADE_PSEUDOMAPINDEX,
    ["mapTexture"] = "greenshade/serpentsgrotto_base_0",
  },
  [391] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GREENSHADE_PSEUDOMAPINDEX,
    ["mapTexture"] = "greenshade/narilnagaia_base_0",
  },
  [326] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GREENSHADE_PSEUDOMAPINDEX,
    ["mapTexture"] = "greenshade/cityofashmain_base_0",
  },
  [278] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GREENSHADE_PSEUDOMAPINDEX,
    ["mapTexture"] = "greenshade/rulanyilsfall_base_0",
  },
  [817] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GREENSHADE_PSEUDOMAPINDEX,
    ["mapTexture"] = "greenshade/marbrukoutlawsrefuge_base_0",
  },
  [699] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GREENSHADE_PSEUDOMAPINDEX,
    ["mapTexture"] = "greenshade/vetcirtyash01_base_0",
  },
  [380] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GREENSHADE_PSEUDOMAPINDEX,
    ["mapTexture"] = "greenshade/barrowtrench_base_0",
  },
  [382] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GREENSHADE_PSEUDOMAPINDEX,
    ["mapTexture"] = "greenshade/gurzagsmine_base_0",
  },
  [1519] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GREENSHADE_PSEUDOMAPINDEX,
    ["mapTexture"] = "greenshade/marchodsacrifices_base_0",
  },
}

lib.reapersMarchData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [256] = {
    ["pseudoMapIndex"] = LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reapersmarch/reapersmarch_base_0",
  },
  [323] = {
    ["pseudoMapIndex"] = LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reapersmarch/thibautscairn_base_0",
  },
  [4] = {
    ["pseudoMapIndex"] = LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reapersmarch/rawlkhatemple_base_0",
  },
  [334] = {
    ["pseudoMapIndex"] = LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reapersmarch/selenesweb_base_0",
  },
  [343] = {
    ["pseudoMapIndex"] = LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reapersmarch/kunasdelve_base_0",
  },
  [213] = {
    ["pseudoMapIndex"] = LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reapersmarch/khajrawlith_base_0",
  },
  [1523] = {
    ["pseudoMapIndex"] = LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reapersmarch/mhkmoonhunterkeep_base_0",
  },
  [116] = {
    ["pseudoMapIndex"] = LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reapersmarch/fortsphinxmoth_base_0",
  },
  [533] = {
    ["pseudoMapIndex"] = LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reapersmarch/dune_base_0",
  },
  [310] = {
    ["pseudoMapIndex"] = LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reapersmarch/planeofjodehubhillbos_base_0",
  },
  [823] = {
    ["pseudoMapIndex"] = LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reapersmarch/reapersmarchoutlawrefuge_base_0",
  },
  [312] = {
    ["pseudoMapIndex"] = LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reapersmarch/rawlkha_base_0",
  },
  [758] = {
    ["pseudoMapIndex"] = LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reapersmarch/thefivefingerdance_0",
  },
  [535] = {
    ["pseudoMapIndex"] = LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reapersmarch/arenthia_base_0",
  },
  [763] = {
    ["pseudoMapIndex"] = LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reapersmarch/vilemansehouse01_base_0",
  },
  [764] = {
    ["pseudoMapIndex"] = LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reapersmarch/vilemansehouse02_base_0",
  },
  [317] = {
    ["pseudoMapIndex"] = LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reapersmarch/thevilemansefirstfloor_base_0",
  },
  [309] = {
    ["pseudoMapIndex"] = LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reapersmarch/planeofjodecave_base_0",
  },
  [997] = {
    ["mapTexture"] = "reapersmarch/maw_of_lorkaj_base_0",
    ["pseudoMapIndex"] = LIBMAPDATA_REAPERS_MARCH_PSEUDOMAPINDEX,
    ["mapScale"] = {
      x = 0.2280121892,
      y = 0.7320250272,
      zoom_factor = 0.0085498988,
    },
  },
}

lib.balFoyenData = {
  ["subZones"] = { 56, },
  ["dungeons"] = { 713, },
  ["events"] = { },
  [56] = {
    ["mapTexture"] = "stonefalls/dhalmora_base_0",
    ["pseudoMapIndex"] = LIBMAPDATA_BAL_FOYEN_PSEUDOMAPINDEX,
    ["mapScale"] = {
      zoom_factor = 0.2375039756,
      x = 0.4718720018,
      y = 0.4531199932,
    },
  },
  [713] = {
    ["mapTexture"] = "balfoyen/smugglertunnel_base_0",
    ["pseudoMapIndex"] = LIBMAPDATA_BAL_FOYEN_PSEUDOMAPINDEX,
    ["mapScale"] = {
      zoom_factor = 0.2375039756,
      x = 0.4718720018,
      y = 0.4531199932,
    },
  },
  [713] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BAL_FOYEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "balfoyen/smugglertunnel_base_0",
  },
  [75] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BAL_FOYEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "stonefalls/balfoyen_base_0",
  },
  [56] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BAL_FOYEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "stonefalls/dhalmora_base_0",
  },
}

lib.strosMKaiData = {
  ["subZones"] = { 530, },
  ["dungeons"] = { 247, 295, 296, },
  ["events"] = { },
  [530] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STROS_MKAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/porthunding_base_0",
    ["mapScale"] = {
      zoom_factor = 0.4183864891,
      x = 0.4483701884,
      y = 0.2100436538,
    },
  },
  [247] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STROS_MKAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/bthzark_base_0",
    ["mapScale"] = {
      zoom_factor = 0.1503042280,
      x = 0.1867931485,
      y = 0.4390945136,
    },
  },
  [295] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STROS_MKAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/goblinminesstart_base_0",
    ["mapScale"] = {
      zoom_factor = 0.1095895171,
      x = 0.6883449554,
      y = -0.0239869542,
    },
  },
  [296] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STROS_MKAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/goblinminesend_base_0",
    ["mapScale"] = {
      zoom_factor = 0.1712402105,
      x = 0.5171047449,
      y = 0.0753274559,
    },
  },
  [248] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STROS_MKAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/thegrave_base_0",
  },
  [201] = {
    ["pseudoMapIndex"] = LIBMAPDATA_STROS_MKAI_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/strosmkai_base_0",
  },
}

lib.betnikhData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [649] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BETNIKH_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/stonetoothfortress_base_0",
    ["mapScale"] = {
      zoom_factor = 0.3335171044,
      x = 0.3742568195,
      y = 0.3294342160,
    },
  },
  [227] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BETNIKH_PSEUDOMAPINDEX,
    ["mapTexture"] = "glenumbra/betnihk_base_0",
  },
}

lib.khenarthisRoostData = {
  ["subZones"] = { 567, },
  ["dungeons"] = { 605, 329, },
  ["events"] = { },
  [567] = {
    ["pseudoMapIndex"] = LIBMAPDATA_KHENARTHIS_ROOST_PSEUDOMAPINDEX,
    ["mapTexture"] = "auridon/mistral_base_0",
    ["mapScale"] = {
      zoom_factor = 0.2719750106,
      x = 0.3891499936,
      y = 0.3125,
    },
  },
  [605] = {
    ["pseudoMapIndex"] = LIBMAPDATA_KHENARTHIS_ROOST_PSEUDOMAPINDEX,
    ["mapTexture"] = "auridon/hazikslair_base_0",
    ["mapScale"] = {
      zoom_factor = 0.0918000340,
      x = 0.6913999915123,
      y = 0.38135001063347,
    },
  },
  [329] = {
    ["pseudoMapIndex"] = LIBMAPDATA_KHENARTHIS_ROOST_PSEUDOMAPINDEX,
    ["mapTexture"] = "auridon/templeofthemourningspring_base_0",
    ["mapScale"] = {
      zoom_factor = 0.1640500426,
      x = 0.7446249723,
      y = 0.4790000021,
    },
  },
  [258] = {
    ["pseudoMapIndex"] = LIBMAPDATA_KHENARTHIS_ROOST_PSEUDOMAPINDEX,
    ["mapTexture"] = "auridon/khenarthisroost_base_0",
  },
}

lib.bleakrockIsleData = {
  ["subZones"] = { 8, },
  ["dungeons"] = { 87, 88, 726, },
  ["events"] = { },
  [8] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BLEAKROCK_ISLE_PSEUDOMAPINDEX,
    ["mapTexture"] = "bleakrock/bleakrockvillage_base_0",
    ["mapScale"] = {
      zoom_factor = 0.3027249574,
      x = 0.2955639958,
      y = 0.4459442198,
    },
  },
  [87] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BLEAKROCK_ISLE_PSEUDOMAPINDEX,
    ["mapTexture"] = "stonefalls/orkeyshollow_base_0",
    ["mapScale"] = {
      zoom_factor = 0.2217997610,
      x = 0.3898183405,
      y = 0.0246092099,
    },
  },
  [88] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BLEAKROCK_ISLE_PSEUDOMAPINDEX,
    ["mapTexture"] = "stonefalls/hozzinsfolley_base_0",
    ["mapScale"] = {
      zoom_factor = 1.0000000027649,
      x = -0.00011784114758,
      y = -0.00011784114758,
    },
  },
  [726] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BLEAKROCK_ISLE_PSEUDOMAPINDEX,
    ["mapTexture"] = "bleakrock/skyshroudbarrow_base_0",
    ["mapScale"] = {
      zoom_factor = 0.0820236206,
      x = 0.7207013368,
      y = 0.3710604012,
    },
  },
  [74] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BLEAKROCK_ISLE_PSEUDOMAPINDEX,
    ["mapTexture"] = "stonefalls/bleakrock_base_0",
  },
}

lib.coldharbourData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [593] = {
    ["pseudoMapIndex"] = LIBMAPDATA_COLDHARBOUR_PSEUDOMAPINDEX,
    ["mapTexture"] = "coldharbor/caveoftrophies_base_0",
  },
  [322] = {
    ["pseudoMapIndex"] = LIBMAPDATA_COLDHARBOUR_PSEUDOMAPINDEX,
    ["mapTexture"] = "coldharbor/malsorrastomb_base_0",
  },
  [339] = {
    ["pseudoMapIndex"] = LIBMAPDATA_COLDHARBOUR_PSEUDOMAPINDEX,
    ["mapTexture"] = "coldharbor/villageofthelost_base_0",
  },
  [261] = {
    ["pseudoMapIndex"] = LIBMAPDATA_COLDHARBOUR_PSEUDOMAPINDEX,
    ["mapTexture"] = "coldharbor/depravedgrotto_base_0",
  },
  [263] = {
    ["pseudoMapIndex"] = LIBMAPDATA_COLDHARBOUR_PSEUDOMAPINDEX,
    ["mapTexture"] = "coldharbor/wailingmaw_base_0",
  },
  [354] = {
    ["pseudoMapIndex"] = LIBMAPDATA_COLDHARBOUR_PSEUDOMAPINDEX,
    ["mapTexture"] = "coldharbor/lightlessoubliette_base_0",
  },
  [585] = {
    ["pseudoMapIndex"] = LIBMAPDATA_COLDHARBOUR_PSEUDOMAPINDEX,
    ["mapTexture"] = "coldharbor/greatshackle1_base_0",
  },
  [422] = {
    ["pseudoMapIndex"] = LIBMAPDATA_COLDHARBOUR_PSEUDOMAPINDEX,
    ["mapTexture"] = "coldharbor/hollowcity_base_0",
  },
  [741] = {
    ["pseudoMapIndex"] = LIBMAPDATA_COLDHARBOUR_PSEUDOMAPINDEX,
    ["mapTexture"] = "coldharbor/thelibrarydusk_base_0",
  },
  [454] = {
    ["pseudoMapIndex"] = LIBMAPDATA_COLDHARBOUR_PSEUDOMAPINDEX,
    ["mapTexture"] = "coldharbor/vaultsofmadness1_base_0",
  },
  [350] = {
    ["pseudoMapIndex"] = LIBMAPDATA_COLDHARBOUR_PSEUDOMAPINDEX,
    ["mapTexture"] = "coldharbor/libraryofdusk_base_0",
  },
  [255] = {
    ["pseudoMapIndex"] = LIBMAPDATA_COLDHARBOUR_PSEUDOMAPINDEX,
    ["mapTexture"] = "coldharbor/coldharbour_base_0",
  },
}

lib.theAurbisData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
}

lib.craglornData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [1089] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CRAGLORN_PSEUDOMAPINDEX,
    ["mapTexture"] = "craglorn/rkhardahrk_0",
  },
  [818] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CRAGLORN_PSEUDOMAPINDEX,
    ["mapTexture"] = "craglorn/craglornoutlawrefuge_base_0",
  },
  [1076] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CRAGLORN_PSEUDOMAPINDEX,
    ["mapTexture"] = "craglorn/thaliasretreat_base_0",
  },
  [1077] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CRAGLORN_PSEUDOMAPINDEX,
    ["mapTexture"] = "craglorn/mtharnaz_base_0",
  },
  [615] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CRAGLORN_PSEUDOMAPINDEX,
    ["mapTexture"] = "craglorn/helracitadelentry_base_0",
  },
  [680] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CRAGLORN_PSEUDOMAPINDEX,
    ["mapTexture"] = "craglorn/craglorn_dragonstar_base_0",
  },
  [1321] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CRAGLORN_PSEUDOMAPINDEX,
    ["mapTexture"] = "craglorn/ui_map_falkreathsdemise_base_0",
  },
  [646] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CRAGLORN_PSEUDOMAPINDEX,
    ["mapTexture"] = "craglorn/aetherianarchivebottom_base_0",
  },
  [1131] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CRAGLORN_PSEUDOMAPINDEX,
    ["mapTexture"] = "craglorn/belkarth_base_0",
  },
  [1088] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CRAGLORN_PSEUDOMAPINDEX,
    ["mapTexture"] = "craglorn/shadaburialgrounds_base_0",
  },
  [1126] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CRAGLORN_PSEUDOMAPINDEX,
    ["mapTexture"] = "craglorn/craglorn_base_0",
  },
  [1087] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CRAGLORN_PSEUDOMAPINDEX,
    ["mapTexture"] = "craglorn/shadacitydistrict_base_0",
  },
}

lib.imperialCityData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [897] = {
    ["pseudoMapIndex"] = LIBMAPDATA_IMPERIAL_CITY_PSEUDOMAPINDEX,
    ["mapTexture"] = "cyrodiil/imperialsewers_aldmeri1_base_0",
  },
  [900] = {
    ["pseudoMapIndex"] = LIBMAPDATA_IMPERIAL_CITY_PSEUDOMAPINDEX,
    ["mapTexture"] = "cyrodiil/imperialsewer_daggerfall1_base_0",
  },
  [917] = {
    ["pseudoMapIndex"] = LIBMAPDATA_IMPERIAL_CITY_PSEUDOMAPINDEX,
    ["mapTexture"] = "cyrodiil/wgtpinnacle_base_0",
  },
  [660] = {
    ["pseudoMapIndex"] = LIBMAPDATA_IMPERIAL_CITY_PSEUDOMAPINDEX,
    ["mapTexture"] = "cyrodiil/imperialcity_base_0",
  },
  [912] = {
    ["pseudoMapIndex"] = LIBMAPDATA_IMPERIAL_CITY_PSEUDOMAPINDEX,
    ["mapTexture"] = "cyrodiil/wgtlibrarymain_base_0",
  },
  [890] = {
    ["pseudoMapIndex"] = LIBMAPDATA_IMPERIAL_CITY_PSEUDOMAPINDEX,
    ["mapTexture"] = "cyrodiil/imperialsewers_ebon1_base_0",
  },
  [907] = {
    ["pseudoMapIndex"] = LIBMAPDATA_IMPERIAL_CITY_PSEUDOMAPINDEX,
    ["mapTexture"] = "cyrodiil/wgtpalacesewers_base_0",
  },
  [908] = {
    ["pseudoMapIndex"] = LIBMAPDATA_IMPERIAL_CITY_PSEUDOMAPINDEX,
    ["mapTexture"] = "cyrodiil/wgtgreenemporerway_base_0",
  },
  [765] = {
    ["pseudoMapIndex"] = LIBMAPDATA_IMPERIAL_CITY_PSEUDOMAPINDEX,
    ["mapTexture"] = "cyrodiil/imperialprisondistrictdun_base_0",
  },
  [767] = {
    ["pseudoMapIndex"] = LIBMAPDATA_IMPERIAL_CITY_PSEUDOMAPINDEX,
    ["mapTexture"] = "cyrodiil/imperialprisondunint01_base_0",
  },
}

lib.wrothgarData = {
  ["subZones"] = { },
  ["events"] = { },
  ["dungeons"] = { },
  [960] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WROTHGAR_PSEUDOMAPINDEX,
    ["mapTexture"] = "wrothgar/exilesbarrow_map_base_0",
  },
  [968] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WROTHGAR_PSEUDOMAPINDEX,
    ["mapTexture"] = "wrothgar/watchershold_base_0",
  },
  [937] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WROTHGAR_PSEUDOMAPINDEX,
    ["mapTexture"] = "wrothgar/rkindaleftoutside_base_0",
  },
  [938] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WROTHGAR_PSEUDOMAPINDEX,
    ["mapTexture"] = "wrothgar/rkindaleftint01_base_0",
  },
  [975] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WROTHGAR_PSEUDOMAPINDEX,
    ["mapTexture"] = "wrothgar/oldorsiniummap01_base_0",
  },
  [977] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WROTHGAR_PSEUDOMAPINDEX,
    ["mapTexture"] = "wrothgar/arenaslobbyexterior_base_0",
  },
  [945] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WROTHGAR_PSEUDOMAPINDEX,
    ["mapTexture"] = "wrothgar/zthenganaz_base_0",
  },
  [1736] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WROTHGAR_PSEUDOMAPINDEX,
    ["mapTexture"] = "wrothgar/icereachpart1_0",
  },
  [895] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WROTHGAR_PSEUDOMAPINDEX,
    ["mapTexture"] = "wrothgar/orsinium_base_0",
  },
  [943] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WROTHGAR_PSEUDOMAPINDEX,
    ["mapTexture"] = "wrothgar/honorsrestleft_base_0",
  },
  [889] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WROTHGAR_PSEUDOMAPINDEX,
    ["mapTexture"] = "wrothgar/bonerock_caverns_base_0",
  },
  [954] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WROTHGAR_PSEUDOMAPINDEX,
    ["mapTexture"] = "wrothgar/morkul_base_0",
  },
  [667] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WROTHGAR_PSEUDOMAPINDEX,
    ["mapTexture"] = "wrothgar/wrothgar_base_0",
  },
  [956] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WROTHGAR_PSEUDOMAPINDEX,
    ["mapTexture"] = "wrothgar/coldperchcavern_base_0",
  },
  [941] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WROTHGAR_PSEUDOMAPINDEX,
    ["mapTexture"] = "wrothgar/kennelrun_base_0",
  },
  [2494] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WROTHGAR_PSEUDOMAPINDEX,
    ["mapTexture"] = "wrothgar/u41_bv_sc1_map_0",
  },
  [927] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WROTHGAR_PSEUDOMAPINDEX,
    ["mapTexture"] = "wrothgar/wrothgaroutlawrefuge_base_0",
  },

}

lib.hewsBaneData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [993] = {
    ["pseudoMapIndex"] = LIBMAPDATA_HEWS_BANE_PSEUDOMAPINDEX,
    ["mapTexture"] = "thievesguild/abahslanding_base_0",
  },
  [994] = {
    ["pseudoMapIndex"] = LIBMAPDATA_HEWS_BANE_PSEUDOMAPINDEX,
    ["mapTexture"] = "thievesguild/hewsbane_base_0",
  },
  [1030] = {
    ["pseudoMapIndex"] = LIBMAPDATA_HEWS_BANE_PSEUDOMAPINDEX,
    ["mapTexture"] = "thievesguild/sharktoothgrotto2_base_0",
  },
  [1013] = {
    ["pseudoMapIndex"] = LIBMAPDATA_HEWS_BANE_PSEUDOMAPINDEX,
    ["mapTexture"] = "thievesguild/safehouse_base_0",
  },
  [997] = {
    ["pseudoMapIndex"] = LIBMAPDATA_HEWS_BANE_PSEUDOMAPINDEX,
    ["mapTexture"] = "reapersmarch/maw_of_lorkaj_base_0",
  },
}

lib.goldCoastData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [1009] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GOLD_COAST_PSEUDOMAPINDEX,
    ["mapTexture"] = "darkbrotherhood/goldcoastrefuge_base_0",
  },
  [1074] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GOLD_COAST_PSEUDOMAPINDEX,
    ["mapTexture"] = "darkbrotherhood/anvilcity_base_0",
  },
  [1063] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GOLD_COAST_PSEUDOMAPINDEX,
    ["mapTexture"] = "darkbrotherhood/dbsanctuary_base_0",
  },
  [1064] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GOLD_COAST_PSEUDOMAPINDEX,
    ["mapTexture"] = "darkbrotherhood/kvatchcity_base_0",
  },
  [1873] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GOLD_COAST_PSEUDOMAPINDEX,
    ["mapTexture"] = "darkbrotherhood/bdvillamap1ext1_0",
  },
  [1005] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GOLD_COAST_PSEUDOMAPINDEX,
    ["mapTexture"] = "darkbrotherhood/garlasagea_base_0",
  },
  [1596] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GOLD_COAST_PSEUDOMAPINDEX,
    ["mapTexture"] = "darkbrotherhood/ui_map_domdepthsofmal_base_0",
  },
  [1006] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GOLD_COAST_PSEUDOMAPINDEX,
    ["mapTexture"] = "darkbrotherhood/goldcoast_base_0",
  },
  [1007] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GOLD_COAST_PSEUDOMAPINDEX,
    ["mapTexture"] = "darkbrotherhood/hrotacave_base_0",
  },
}

lib.vvardenfellData = {
  ["subZones"] = { },
  ["dungeons"] = { 1162, 1310, },
  ["events"] = {
    [1060] = {
      ["Impresario"] = {
        x = 0.4671077430,
        y = 0.8333740830,
      },
    },
  },
  [1162] = {
    ["pseudoMapIndex"] = LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX,
    ["mapTexture"] = "vvardenfell/nchuleft_base_0",
    ["mapScale"] = {
      x = 0.6046329141,
      y = 0.3318561316,
      zoom_factor = 0.0031403303,
    },
  },
  [1310] = {
    ["pseudoMapIndex"] = LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX,
    ["mapTexture"] = "vvardenfell/nchuleftingth1_base_0",
    ["mapScale"] = {
      x = 0.6638011932,
      y = 0.6520555615,
      zoom_factor = 0.0039404035,
    },
  },
  [1220] = {
    ["pseudoMapIndex"] = LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX,
    ["mapTexture"] = "vvardenfell/vivecthroneroom01_base_0",
  },
  [1221] = {
    ["pseudoMapIndex"] = LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX,
    ["mapTexture"] = "vvardenfell/vivecthroneroom02_base_0",
  },
  [1222] = {
    ["pseudoMapIndex"] = LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX,
    ["mapTexture"] = "vvardenfell/vivechow01a_base_0",
  },
  [1287] = {
    ["pseudoMapIndex"] = LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX,
    ["mapTexture"] = "vvardenfell/viviccity_base_0",
  },
  [1288] = {
    ["pseudoMapIndex"] = LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX,
    ["mapTexture"] = "vvardenfell/sadrithmora_base_0",
  },
  [1225] = {
    ["pseudoMapIndex"] = LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX,
    ["mapTexture"] = "vvardenfell/vivechoj01a_base_0",
  },
  [1290] = {
    ["pseudoMapIndex"] = LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX,
    ["mapTexture"] = "vvardenfell/balmora_base_0",
  },
  [1231] = {
    ["pseudoMapIndex"] = LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX,
    ["mapTexture"] = "vvardenfell/vivecstolms02a_base_0",
  },
  [1232] = {
    ["pseudoMapIndex"] = LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX,
    ["mapTexture"] = "vvardenfell/vivecstolms02b_base_0",
  },
  [1233] = {
    ["pseudoMapIndex"] = LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX,
    ["mapTexture"] = "vvardenfell/vivecstolms03_base_0",
  },
  [1235] = {
    ["pseudoMapIndex"] = LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX,
    ["mapTexture"] = "vvardenfell/vivecstdelyn02a_base_0",
  },
  [1237] = {
    ["pseudoMapIndex"] = LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX,
    ["mapTexture"] = "vvardenfell/vivecsdelyn03a_base_0",
  },
  [1238] = {
    ["pseudoMapIndex"] = LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX,
    ["mapTexture"] = "vvardenfell/vivecsdelyn03b_base_0",
  },
  [1286] = {
    ["pseudoMapIndex"] = LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX,
    ["mapTexture"] = "vvardenfell/ui_map_hofabriccaves_base_0",
  },
  [1276] = {
    ["pseudoMapIndex"] = LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX,
    ["mapTexture"] = "vvardenfell/forgottenwastesext_base_0",
  },
  [1245] = {
    ["pseudoMapIndex"] = LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX,
    ["mapTexture"] = "vvardenfell/vvardenfelloutlawrefuge_base_0",
  },
  [1060] = {
    ["pseudoMapIndex"] = LIBMAPDATA_VVARDENFELL_PSEUDOMAPINDEX,
    ["mapTexture"] = "vvardenfell/vvardenfell_base_0",
  },
}

lib.clockworkCityData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [1313] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CLOCKWORK_CITY_PSEUDOMAPINDEX,
    ["mapTexture"] = "clockwork/clockwork_base_0",
  },
  [1354] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CLOCKWORK_CITY_PSEUDOMAPINDEX,
    ["mapTexture"] = "clockwork/clockworkoutlawsrefuge_base_0",
  },
  [1362] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CLOCKWORK_CITY_PSEUDOMAPINDEX,
    ["mapTexture"] = "clockwork/ccunderground02_base_0",
  },
  [1348] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CLOCKWORK_CITY_PSEUDOMAPINDEX,
    ["mapTexture"] = "clockwork/brassfortress_base_0",
  },
  [1391] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CLOCKWORK_CITY_PSEUDOMAPINDEX,
    ["mapTexture"] = "clockwork/ui_map_asylumsanctorum001_base_0",
  },
  [1385] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CLOCKWORK_CITY_PSEUDOMAPINDEX,
    ["mapTexture"] = "clockwork/basilica_01_base_0",
  },
  [1386] = {
    ["pseudoMapIndex"] = LIBMAPDATA_CLOCKWORK_CITY_PSEUDOMAPINDEX,
    ["mapTexture"] = "clockwork/basilica_02_base_0",
  },
}

lib.summersetData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = {
    [1349] = {
      ["Impresario"] = {
        x = 0.2842602431,
        y = 0.5381632447,
      },
    },
  },
  [1476] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SUMMERSET_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/dreamingcave02_base_0",
  },
  [1349] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SUMMERSET_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/summerset_base_0",
  },
  [1455] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SUMMERSET_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/lillandrill_base_0",
  },
  [1488] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SUMMERSET_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/dreamingcave03_base_0",
  },
  [1492] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SUMMERSET_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/collegeofpsijicsruins_base_0",
  },
  [1493] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SUMMERSET_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/collegeofpsijicsruins_btm_base_0",
  },
  [1430] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SUMMERSET_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/alinor_base_0",
  },
  [1431] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SUMMERSET_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/shimmerene_base_0",
  },
  [1438] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SUMMERSET_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/sunhold_base_0",
  },
  [1366] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SUMMERSET_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/kingshavenext_base_0",
  },
  [2110] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SUMMERSET_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/coralaerie_beach_001_0",
  },
  [1372] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SUMMERSET_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/etonnir_01_base_0",
  },
  [1470] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SUMMERSET_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/dreamingcave01_base_0",
  },
  [1502] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SUMMERSET_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/ui_map_cloudresttrial_base_0",
  },
}

lib.artaeumData = {
  ["subZones"] = { },
  ["dungeons"] = { 1475, 1476, 1488, 1489, 1490, 1493, 1503, },
  ["events"] = { },
  [1475] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ARTAEUM_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/traitorsvault04_base_0",
    ["mapScale"] = {
      zoom_factor = 0.0073818266,
      x = 0.3961500227,
      y = 0.4466728270,
    },
  },
  [1476] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ARTAEUM_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/dreamingcave02_base_0",
    ["mapScale"] = {
      zoom_factor = 0.0348578095,
      x = 0.6414873004,
      y = 0.2571611404,
    },
  },
  [1488] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ARTAEUM_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/dreamingcave03_base_0",
    ["mapScale"] = {
      zoom_factor = 0.0216386914,
      x = 0.6568168401,
      y = 0.2631108462,
    },
  },
  [1493] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ARTAEUM_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/collegeofpsijicsruins_btm_base_0",
    ["mapScale"] = {
      zoom_factor = 0.0160962939,
      x = 0.5573176145,
      y = 0.4827489554,
    },
  },
  [1503] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ARTAEUM_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/collegeofpsijicsruins_base_0",
    ["mapScale"] = {
      zoom_factor = 0.0160962939,
      x = 0.5573176145,
      y = 0.4827489554,
    },
  },
  [1429] = {
    ["pseudoMapIndex"] = LIBMAPDATA_ARTAEUM_PSEUDOMAPINDEX,
    ["mapTexture"] = "summerset/artaeum_base_0",
  },
}
lib.artaeumData[1489] = lib.artaeumData[1488] -- dreamingcave03_base_0
lib.artaeumData[1490] = lib.artaeumData[1488] -- dreamingcave03_base_0

lib.murkmireData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [1556] = {
    ["pseudoMapIndex"] = LIBMAPDATA_MURKMIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "murkmire/ui_map_blackroseprison01_base_0",
  },
  [1560] = {
    ["pseudoMapIndex"] = LIBMAPDATA_MURKMIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "murkmire/lilmothcity_base_0",
  },
  [1561] = {
    ["pseudoMapIndex"] = LIBMAPDATA_MURKMIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "murkmire/brightthroatvillage_base_0",
  },
  [1562] = {
    ["pseudoMapIndex"] = LIBMAPDATA_MURKMIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "murkmire/deadwatervillage_base_0",
  },
  [1563] = {
    ["pseudoMapIndex"] = LIBMAPDATA_MURKMIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "murkmire/rootwhisper_base_0",
  },
  [1484] = {
    ["pseudoMapIndex"] = LIBMAPDATA_MURKMIRE_PSEUDOMAPINDEX,
    ["mapTexture"] = "murkmire/murkmire_base_0",
  },
}

lib.northernElsweyrData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = {
    [1555] = {
      ["Impresario"] = {
        x = 0.7474783062,
        y = 0.3210040330,
      },
      ["Captain Samara"] = {
        x = 0.1376450359,
        y = 0.7660769820,
      },
      ["Apprentice Taz"] = {
        x = 0.1333959847,
        y = 0.7631761431,
      },
    },
  },
  [1618] = {
    ["pseudoMapIndex"] = LIBMAPDATA_NORTHERN_ELSWEYR_PSEUDOMAPINDEX,
    ["mapTexture"] = "elsweyr/uimapstarhavenadeptor_base_0",
  },
  [1555] = {
    ["pseudoMapIndex"] = LIBMAPDATA_NORTHERN_ELSWEYR_PSEUDOMAPINDEX,
    ["mapTexture"] = "elsweyr/elsweyr_base_0",
  },
  [1639] = {
    ["pseudoMapIndex"] = LIBMAPDATA_NORTHERN_ELSWEYR_PSEUDOMAPINDEX,
    ["mapTexture"] = "elsweyr/rimmennecropolis_base_0",
  },
  [1576] = {
    ["pseudoMapIndex"] = LIBMAPDATA_NORTHERN_ELSWEYR_PSEUDOMAPINDEX,
    ["mapTexture"] = "elsweyr/rimmen_base_0",
  },
  [1650] = {
    ["pseudoMapIndex"] = LIBMAPDATA_NORTHERN_ELSWEYR_PSEUDOMAPINDEX,
    ["mapTexture"] = "elsweyr/sunspirehall001_base_0",
  },
  [1626] = {
    ["pseudoMapIndex"] = LIBMAPDATA_NORTHERN_ELSWEYR_PSEUDOMAPINDEX,
    ["mapTexture"] = "elsweyr/thetangle_base_0",
  },
  [1616] = {
    ["pseudoMapIndex"] = LIBMAPDATA_NORTHERN_ELSWEYR_PSEUDOMAPINDEX,
    ["mapTexture"] = "elsweyr/predatorrise_base_0",
  },
  [1591] = {
    ["pseudoMapIndex"] = LIBMAPDATA_NORTHERN_ELSWEYR_PSEUDOMAPINDEX,
    ["mapTexture"] = "elsweyr/riverholdcity_base_0",
  },
  [1699] = {
    ["pseudoMapIndex"] = LIBMAPDATA_NORTHERN_ELSWEYR_PSEUDOMAPINDEX,
    ["mapTexture"] = "southernelsweyr/moongravesection1_base_0",
  },
  [1663] = {
    ["pseudoMapIndex"] = LIBMAPDATA_NORTHERN_ELSWEYR_PSEUDOMAPINDEX,
    ["mapTexture"] = "elsweyr/stitches_base_0",
  },
}

lib.southernElsweyrData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [1682] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SOUTHERN_ELSWEYR_PSEUDOMAPINDEX,
    ["mapTexture"] = "southernelsweyr/els_dg_sanctuary_base_0",
  },
  [1683] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SOUTHERN_ELSWEYR_PSEUDOMAPINDEX,
    ["mapTexture"] = "southernelsweyr/els_dg_sanctuary02_base_0",
  },
  [1684] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SOUTHERN_ELSWEYR_PSEUDOMAPINDEX,
    ["mapTexture"] = "southernelsweyr/els_dragonguard_island01_base_0",
  },
  [1690] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SOUTHERN_ELSWEYR_PSEUDOMAPINDEX,
    ["mapTexture"] = "southernelsweyr/senchalpalace01_base_0",
  },
  [1675] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SOUTHERN_ELSWEYR_PSEUDOMAPINDEX,
    ["mapTexture"] = "southernelsweyr/senchal_base_0",
  },
  [1654] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SOUTHERN_ELSWEYR_PSEUDOMAPINDEX,
    ["mapTexture"] = "southernelsweyr/southernelsweyr_base_0",
  },
}

lib.westernSkyrimData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = {
    [1719] = {
      ["Impresario"] = {
        x = 0.5106408596,
        y = 0.4133806228,
      },
    },
  },
  [1719] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WESTERN_SKYRIM_PSEUDOMAPINDEX,
    ["mapTexture"] = "skyrim/westernskryim_base_0",
  },
  [1805] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WESTERN_SKYRIM_PSEUDOMAPINDEX,
    ["mapTexture"] = "skyrim/kynesaegismap001_0",
  },
  [1790] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WESTERN_SKYRIM_PSEUDOMAPINDEX,
    ["mapTexture"] = "skyrim/skrtut_deepwoodbarrow_base_0",
  },
  [1773] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WESTERN_SKYRIM_PSEUDOMAPINDEX,
    ["mapTexture"] = "skyrim/solitudecity_base_0",
  },
  [1822] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WESTERN_SKYRIM_PSEUDOMAPINDEX,
    ["mapTexture"] = "skyrim/castlethornmap_001_0",
  },
  [1791] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WESTERN_SKYRIM_PSEUDOMAPINDEX,
    ["mapTexture"] = "skyrim/skrtut_deepwoodvale_base_0",
  },
}

lib.blackreachGreymoorCavernsData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [1785] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BLACKREACH_GREYMOOR_CAVERNS_PSEUDOMAPINDEX,
    ["mapTexture"] = "skyrim/stonegarden01_base_0",
  },
  [1747] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BLACKREACH_GREYMOOR_CAVERNS_PSEUDOMAPINDEX,
    ["mapTexture"] = "skyrim/blackreach_base_0",
  },
  [1798] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BLACKREACH_GREYMOOR_CAVERNS_PSEUDOMAPINDEX,
    ["mapTexture"] = "skyrim/darkmoongrottorefuge_base_0",
  },
}

lib.blackreachData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
}

lib.blackreachArkthzandCavernData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [1850] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BLACKREACH_ARKTHZAND_CAVERN_PSEUDOMAPINDEX,
    ["mapTexture"] = "reach/u28_blackreach_base_0",
  },
  [1907] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BLACKREACH_ARKTHZAND_CAVERN_PSEUDOMAPINDEX,
    ["mapTexture"] = "reach/u28_orrerychamber_base_0",
  },
}

lib.theReachData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [1842] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_REACH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reach/vateshransrites01_0",
  },
  [1858] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_REACH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reach/markarthcity_base_0",
  },
  [2462] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_REACH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reach/u41_osp_map_starterarea_0",
  },
  [1814] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_REACH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reach/reach_base_0",
  },
  [1888] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_REACH_PSEUDOMAPINDEX,
    ["mapTexture"] = "reach/markunderstonekeep_base_0",
  },
}

lib.blackwoodData = {
  ["subZones"] = { 1940, 1972, 2051, 2052 },
  ["dungeons"] = { 1939, 2031, 2032 },
  ["events"] = {
    [1887] = {
      ["Impresario"] = {
        x = 0.2744835615,
        y = 0.5430571436,
      },
    },
  },
  [1940] = {
    ["mapTexture"] = "blackwood/u30_leyawiincity_base_0",
    ["pseudoMapIndex"] = LIBMAPDATA_BLACKWOOD_PSEUDOMAPINDEX,
    ["mapScale"] = {
      zoom_factor = 0.0998815596,
      x = 0.1879221797,
      y = 0.5008402467,
    },
  },
  [1939] = {
    ["mapTexture"] = "blackwood/arpenial_base_0",
    ["pseudoMapIndex"] = LIBMAPDATA_BLACKWOOD_PSEUDOMAPINDEX,
    ["mapScale"] = {
      zoom_factor = 0.0123090744,
      x = 0.3725301027,
      y = 0.2471901476,
    },
  },
  [2031] = {
    ["mapTexture"] = "blackwood/arpeniah2_base_0",
    ["pseudoMapIndex"] = LIBMAPDATA_BLACKWOOD_PSEUDOMAPINDEX,
    ["mapScale"] = {
      zoom_factor = 0.0123090744,
      x = 0.3725301027,
      y = 0.2471901476,
    },
  },
  [2032] = {
    ["mapTexture"] = "blackwood/arpenial3_base_0",
    ["pseudoMapIndex"] = LIBMAPDATA_BLACKWOOD_PSEUDOMAPINDEX,
    ["mapScale"] = {
      zoom_factor = 0.0123090744,
      x = 0.3725301027,
      y = 0.2471901476,
    },
  },
  [2018] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BLACKWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "blackwood/u30_gideoncity_base_0",
  },
  [2004] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BLACKWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "blackwood/u30_rg_map_outside_001_0",
  },
  [2023] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BLACKWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "blackwood/tdc_map_outside_001_0",
  },
  [2057] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BLACKWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "blackwood/vaultdelve_ext01_base_0",
  },
  [1979] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BLACKWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "blackwood/vaultdelve_int01_base_0",
  },
  [2000] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BLACKWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "blackwood/u30_oblivion_portal_base_0",
  },
  [1887] = {
    ["pseudoMapIndex"] = LIBMAPDATA_BLACKWOOD_PSEUDOMAPINDEX,
    ["mapTexture"] = "blackwood/blackwood_base_0",
  },
}
lib.blackwoodData[1972] = lib.blackwoodData[1940] -- u30_leyawiincity_base_0
lib.blackwoodData[2051] = lib.blackwoodData[1940] -- u30_leyawiincity_base_0
lib.blackwoodData[2052] = lib.blackwoodData[1940] -- u30_leyawiincity_base_0

lib.fargraveData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [2773] = {
    ["pseudoMapIndex"] = LIBMAPDATA_FARGRAVE_PSEUDOMAPINDEX,
    ["mapTexture"] = "dungeons/u49_avz_skitter_001_0",
  },
  [2771] = {
    ["pseudoMapIndex"] = LIBMAPDATA_FARGRAVE_PSEUDOMAPINDEX,
    ["mapTexture"] = "dungeons/u49_avz_hub_001_0",
  },
  [2772] = {
    ["pseudoMapIndex"] = LIBMAPDATA_FARGRAVE_PSEUDOMAPINDEX,
    ["mapTexture"] = "dungeons/u49_avz_parch_001_0",
  },
  [2774] = {
    ["pseudoMapIndex"] = LIBMAPDATA_FARGRAVE_PSEUDOMAPINDEX,
    ["mapTexture"] = "dungeons/u49_avz_sorrow_001_0",
  },
}

lib.theDeadlandsData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [2021] = {
    ["pseudoMapIndex"] = LIBMAPDATA_THE_DEADLANDS_PSEUDOMAPINDEX,
    ["mapTexture"] = "deadlands/u32deadlandszone_base_0",
  },
}

lib.highIsleData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [2114] = {
    ["pseudoMapIndex"] = LIBMAPDATA_HIGH_ISLE_PSEUDOMAPINDEX,
    ["mapTexture"] = "systres/u34_systreszone_base_0",
  },
  [2163] = {
    ["pseudoMapIndex"] = LIBMAPDATA_HIGH_ISLE_PSEUDOMAPINDEX,
    ["mapTexture"] = "systres/u34_gonfalonbaycity_base_0",
  },
  [2229] = {
    ["pseudoMapIndex"] = LIBMAPDATA_HIGH_ISLE_PSEUDOMAPINDEX,
    ["mapTexture"] = "systres/gravendeep_island_map_0",
  },
  [2213] = {
    ["pseudoMapIndex"] = LIBMAPDATA_HIGH_ISLE_PSEUDOMAPINDEX,
    ["mapTexture"] = "systres/u34_stoneloregrove_base_0",
  },
  [2206] = {
    ["pseudoMapIndex"] = LIBMAPDATA_HIGH_ISLE_PSEUDOMAPINDEX,
    ["mapTexture"] = "systres/ere_outsidemap01_0",
  },
  [2214] = {
    ["pseudoMapIndex"] = LIBMAPDATA_HIGH_ISLE_PSEUDOMAPINDEX,
    ["mapTexture"] = "systres/u34_amenosstation_city_base_0",
  },
}

lib.fargraveCityData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [2082] = {
    ["pseudoMapIndex"] = LIBMAPDATA_FARGRAVE_CITY_PSEUDOMAPINDEX,
    ["mapTexture"] = "deadlands/u32_theshambles_base_0",
  },
  [2035] = {
    ["pseudoMapIndex"] = LIBMAPDATA_FARGRAVE_CITY_PSEUDOMAPINDEX,
    ["mapTexture"] = "deadlands/u32_fargrave_base_0",
  },
}

lib.galenData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [2227] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GALEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "galen/u36_vastyrcity_base_0",
  },
  [2212] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GALEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "galen/u36_galenisland_base_0",
  },
  [2279] = {
    ["pseudoMapIndex"] = LIBMAPDATA_GALEN_PSEUDOMAPINDEX,
    ["mapTexture"] = "galen/u36_vastyrcitycastle_base_0",
  },
}

lib.telvanniPeninsulaData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [2274] = {
    ["pseudoMapIndex"] = LIBMAPDATA_TELVANNI_PENINSULA_PSEUDOMAPINDEX,
    ["mapTexture"] = "telvanni/u38_telvannipeninsula_base_0",
  },
  [2333] = {
    ["pseudoMapIndex"] = LIBMAPDATA_TELVANNI_PENINSULA_PSEUDOMAPINDEX,
    ["mapTexture"] = "telvanni/sanitysedgesection0_map_0",
  },
  [2384] = {
    ["pseudoMapIndex"] = LIBMAPDATA_TELVANNI_PENINSULA_PSEUDOMAPINDEX,
    ["mapTexture"] = "apocrypha/u38_ciphersmidden_city_base_0",
  },
  [2343] = {
    ["pseudoMapIndex"] = LIBMAPDATA_TELVANNI_PENINSULA_PSEUDOMAPINDEX,
    ["mapTexture"] = "telvanni/u38_necrom_base_0",
  },
}

lib.apocryphaData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [2275] = {
    ["pseudoMapIndex"] = LIBMAPDATA_APOCRYPHA_PSEUDOMAPINDEX,
    ["mapTexture"] = "apocrypha/u38_apocrypha_base_0",
  },
  [2407] = {
    ["pseudoMapIndex"] = LIBMAPDATA_APOCRYPHA_PSEUDOMAPINDEX,
    ["mapTexture"] = "apocrypha/u40_tomehold_starterarea_0",
  },
}

lib.westWealdData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [2514] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WESTWEALD_PSEUDOMAPINDEX,
    ["mapTexture"] = "westweald/u42_skingrad_base_0",
  },
  [2453] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WESTWEALD_PSEUDOMAPINDEX,
    ["mapTexture"] = "westweald/u42_base_haldain_0",
  },
  [2456] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WESTWEALD_PSEUDOMAPINDEX,
    ["mapTexture"] = "westweald/u42_leftwheal_ext2_base_0",
  },
  [2501] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WESTWEALD_PSEUDOMAPINDEX,
    ["mapTexture"] = "westweald/u42_skingrad_or_base_0",
  },
  [2442] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WESTWEALD_PSEUDOMAPINDEX,
    ["mapTexture"] = "westweald/ui_maps_u42_varenswall_ext_0",
  },
  [2427] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WESTWEALD_PSEUDOMAPINDEX,
    ["mapTexture"] = "westweald/westwealdoverland_base_0",
  },
  [2604] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WESTWEALD_PSEUDOMAPINDEX,
    ["mapTexture"] = "westweald/u42_vashabar_base_0",
  },
  [2592] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WESTWEALD_PSEUDOMAPINDEX,
    ["mapTexture"] = "westweald/u42_ontus_city_base_0",
  },
  [2552] = {
    ["pseudoMapIndex"] = LIBMAPDATA_WESTWEALD_PSEUDOMAPINDEX,
    ["mapTexture"] = "deadlands/u42tri_lucentcitmap001_0",
  },
}

lib.eyeveaData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [108] = {
    ["pseudoMapIndex"] = LIBMAPDATA_EYEVEA_PSEUDOMAPINDEX,
    ["mapTexture"] = "guildmaps/eyevea_base_0",
  },
  [2515] = {
    ["pseudoMapIndex"] = LIBMAPDATA_EYEVEA_PSEUDOMAPINDEX,
    ["mapTexture"] = "westweald/u42_base_sc_library_0",
  },
}

lib.solsticeData = {
  ["subZones"] = { },
  ["dungeons"] = { },
  ["events"] = { },
  [2721] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SOLSTICE_PSEUDOMAPINDEX,
    ["mapTexture"] = "solstice/u46_base_shoresstand_0",
  },
  [2603] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SOLSTICE_PSEUDOMAPINDEX,
    ["mapTexture"] = "solstice/u48_overland_base_0",
  },
  [2654] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SOLSTICE_PSEUDOMAPINDEX,
    ["mapTexture"] = "solstice/u46_sunport_base_0",
  },
  [2686] = {
    ["pseudoMapIndex"] = LIBMAPDATA_SOLSTICE_PSEUDOMAPINDEX,
    ["mapTexture"] = "dungeons/osscage_entranceroomsmap001_0",
  },
}

lib.mapIdToMapIndex = {
  [27] = 1,
[1] = 2,
[10] = 3,
[12] = 4,
[30] = 5,
[20] = 6,
[9] = 7,
[22] = 8,
[26] = 9,
[13] = 10,
[7] = 11,
[125] = 12,
[61] = 13,
[16] = 14,
[143] = 15,
[300] = 16,
[256] = 17,
[75] = 18,
[201] = 19,
[227] = 20,
[258] = 21,
[74] = 22,
[255] = 23,
[439] = 24,
[1126] = 25,
[660] = 26,
[667] = 27,
[994] = 28,
[1006] = 29,
[1060] = 30,
[1313] = 31,
[1349] = 32,
[1429] = 33,
[1484] = 34,
[1555] = 35,
[1654] = 36,
[1719] = 37,
[1747] = 38,
[1782] = 39,
[1850] = 40,
[1814] = 41,
[1887] = 42,
[2119] = 43,
[2021] = 44,
[2114] = 45,
[2035] = 46,
[2212] = 47,
[2274] = 48,
[2275] = 49,
[2427] = 50,
[108] = 51,
[2603] = 52,
}

lib.mapIndexData = {
  [1] = {
    ["mapTexture"] = "tamriel/tamriel_0",
    ["mapIndex"] = 1,
    ["mapId"] = 27,
    ["zoneIndex"] = "nil",
    ["zoneName"] = "Tamriel",
    ["zoneId"] = "nil",
    ["mapsData"] = lib.tamrielData,
  },
  [2] = {
    ["mapTexture"] = "glenumbra/glenumbra_base_0",
    ["mapIndex"] = 2,
    ["mapId"] = 1,
    ["zoneIndex"] = 2,
    ["zoneName"] = "Glenumbra",
    ["zoneId"] = 3,
    ["mapsData"] = lib.glenumbraData,
  },
  [3] = {
    ["mapTexture"] = "rivenspire/rivenspire_base_0",
    ["mapIndex"] = 3,
    ["mapId"] = 10,
    ["zoneIndex"] = 5,
    ["zoneName"] = "Rivenspire",
    ["zoneId"] = 20,
    ["mapsData"] = lib.rivenspireData,
  },
  [4] = {
    ["mapTexture"] = "stormhaven/stormhaven_base_0",
    ["mapIndex"] = 4,
    ["mapId"] = 12,
    ["zoneIndex"] = 4,
    ["zoneName"] = "Stormhaven",
    ["zoneId"] = 19,
    ["mapsData"] = lib.stormhavenData,
  },
  [5] = {
    ["mapTexture"] = "alikr/alikr_base_0",
    ["mapIndex"] = 5,
    ["mapId"] = 30,
    ["zoneIndex"] = 17,
    ["zoneName"] = "Alik'r Desert",
    ["zoneId"] = 104,
    ["mapsData"] = lib.alikrDesertData,
  },
  [6] = {
    ["mapTexture"] = "bangkorai/bangkorai_base_0",
    ["mapIndex"] = 6,
    ["mapId"] = 20,
    ["zoneIndex"] = 14,
    ["zoneName"] = "Bangkorai",
    ["zoneId"] = 92,
    ["mapsData"] = lib.bangkoraiData,
  },
  [7] = {
    ["mapTexture"] = "grahtwood/grahtwood_base_0",
    ["mapIndex"] = 7,
    ["mapId"] = 9,
    ["zoneIndex"] = 180,
    ["zoneName"] = "Grahtwood",
    ["zoneId"] = 383,
    ["mapsData"] = lib.grahtwoodData,
  },
  [8] = {
    ["mapTexture"] = "malabaltor/malabaltor_base_0",
    ["mapIndex"] = 8,
    ["mapId"] = 22,
    ["zoneIndex"] = 11,
    ["zoneName"] = "Malabal Tor",
    ["zoneId"] = 58,
    ["mapsData"] = lib.malabalTorData,
  },
  [9] = {
    ["mapTexture"] = "shadowfen/shadowfen_base_0",
    ["mapIndex"] = 9,
    ["mapId"] = 26,
    ["zoneIndex"] = 19,
    ["zoneName"] = "Shadowfen",
    ["zoneId"] = 117,
    ["mapsData"] = lib.shadowfenData,
  },
  [10] = {
    ["mapTexture"] = "deshaan/deshaan_base_0",
    ["mapIndex"] = 10,
    ["mapId"] = 13,
    ["zoneIndex"] = 10,
    ["zoneName"] = "Deshaan",
    ["zoneId"] = 57,
    ["mapsData"] = lib.deshaanData,
  },
  [11] = {
    ["mapTexture"] = "stonefalls/stonefalls_base_0",
    ["mapIndex"] = 11,
    ["mapId"] = 7,
    ["zoneIndex"] = 9,
    ["zoneName"] = "Stonefalls",
    ["zoneId"] = 41,
    ["mapsData"] = lib.stonefallsData,
  },
  [12] = {
    ["mapTexture"] = "therift/therift_base_0",
    ["mapIndex"] = 12,
    ["mapId"] = 125,
    ["zoneIndex"] = 16,
    ["zoneName"] = "The Rift",
    ["zoneId"] = 103,
    ["mapsData"] = lib.theRiftData,
  },
  [13] = {
    ["mapTexture"] = "eastmarch/eastmarch_base_0",
    ["mapIndex"] = 13,
    ["mapId"] = 61,
    ["zoneIndex"] = 15,
    ["zoneName"] = "Eastmarch",
    ["zoneId"] = 101,
    ["mapsData"] = lib.eastmarchData,
  },
  [14] = {
    ["mapTexture"] = "cyrodiil/ava_whole_0",
    ["mapIndex"] = 14,
    ["mapId"] = 16,
    ["zoneIndex"] = 38,
    ["zoneName"] = "Cyrodiil",
    ["zoneId"] = 181,
    ["mapsData"] = lib.cyrodiilData,
  },
  [15] = {
    ["mapTexture"] = "auridon/auridon_base_0",
    ["mapIndex"] = 15,
    ["mapId"] = 143,
    ["zoneIndex"] = 178,
    ["zoneName"] = "Auridon",
    ["zoneId"] = 381,
    ["mapsData"] = lib.auridonData,
  },
  [16] = {
    ["mapTexture"] = "greenshade/greenshade_base_0",
    ["mapIndex"] = 16,
    ["mapId"] = 300,
    ["zoneIndex"] = 18,
    ["zoneName"] = "Greenshade",
    ["zoneId"] = 108,
    ["mapsData"] = lib.greenshadeData,
  },
  [17] = {
    ["mapTexture"] = "reapersmarch/reapersmarch_base_0",
    ["mapIndex"] = 17,
    ["mapId"] = 256,
    ["zoneIndex"] = 179,
    ["zoneName"] = "Reaper's March",
    ["zoneId"] = 382,
    ["mapsData"] = lib.reapersMarchData,
  },
  [18] = {
    ["mapTexture"] = "stonefalls/balfoyen_base_0",
    ["mapIndex"] = 18,
    ["mapId"] = 75,
    ["zoneIndex"] = 110,
    ["zoneName"] = "Bal Foyen",
    ["zoneId"] = 281,
    ["mapsData"] = lib.balFoyenData,
  },
  [19] = {
    ["mapTexture"] = "glenumbra/strosmkai_base_0",
    ["mapIndex"] = 19,
    ["mapId"] = 201,
    ["zoneIndex"] = 305,
    ["zoneName"] = "Stros M'Kai",
    ["zoneId"] = 534,
    ["mapsData"] = lib.strosMKaiData,
  },
  [20] = {
    ["mapTexture"] = "glenumbra/betnihk_base_0",
    ["mapIndex"] = 20,
    ["mapId"] = 227,
    ["zoneIndex"] = 306,
    ["zoneName"] = "Betnikh",
    ["zoneId"] = 535,
    ["mapsData"] = lib.betnikhData,
  },
  [21] = {
    ["mapTexture"] = "auridon/khenarthisroost_base_0",
    ["mapIndex"] = 21,
    ["mapId"] = 258,
    ["zoneIndex"] = 307,
    ["zoneName"] = "Khenarthi's Roost",
    ["zoneId"] = 537,
    ["mapsData"] = lib.khenarthisRoostData,
  },
  [22] = {
    ["mapTexture"] = "stonefalls/bleakrock_base_0",
    ["mapIndex"] = 22,
    ["mapId"] = 74,
    ["zoneIndex"] = 109,
    ["zoneName"] = "Bleakrock Isle",
    ["zoneId"] = 280,
    ["mapsData"] = lib.bleakrockIsleData,
  },
  [23] = {
    ["mapTexture"] = "coldharbor/coldharbour_base_0",
    ["mapIndex"] = 23,
    ["mapId"] = 255,
    ["zoneIndex"] = 154,
    ["zoneName"] = "Coldharbour",
    ["zoneId"] = 347,
    ["mapsData"] = lib.coldharbourData,
  },
  [24] = {
    ["mapTexture"] = "tamriel/mundus_base_0",
    ["mapIndex"] = 24,
    ["mapId"] = 439,
    ["zoneIndex"] = "nil",
    ["zoneName"] = "The Aurbis",
    ["zoneId"] = "nil",
    ["mapsData"] = lib.theAurbisData,
  },
  [25] = {
    ["mapTexture"] = "craglorn/craglorn_base_0",
    ["mapIndex"] = 25,
    ["mapId"] = 1126,
    ["zoneIndex"] = 501,
    ["zoneName"] = "Craglorn",
    ["zoneId"] = 888,
    ["mapsData"] = lib.craglornData,
  },
  [26] = {
    ["mapTexture"] = "cyrodiil/imperialcity_base_0",
    ["mapIndex"] = 26,
    ["mapId"] = 660,
    ["zoneIndex"] = 347,
    ["zoneName"] = "Imperial City",
    ["zoneId"] = 584,
    ["mapsData"] = lib.imperialCityData,
  },
  [27] = {
    ["mapTexture"] = "wrothgar/wrothgar_base_0",
    ["mapIndex"] = 27,
    ["mapId"] = 667,
    ["zoneIndex"] = 380,
    ["zoneName"] = "Wrothgar",
    ["zoneId"] = 684,
    ["mapsData"] = lib.wrothgarData,
  },
  [28] = {
    ["mapTexture"] = "thievesguild/hewsbane_base_0",
    ["mapIndex"] = 28,
    ["mapId"] = 994,
    ["zoneIndex"] = 443,
    ["zoneName"] = "Hew's Bane",
    ["zoneId"] = 816,
    ["mapsData"] = lib.hewsBaneData,
  },
  [29] = {
    ["mapTexture"] = "darkbrotherhood/goldcoast_base_0",
    ["mapIndex"] = 29,
    ["mapId"] = 1006,
    ["zoneIndex"] = 449,
    ["zoneName"] = "Gold Coast",
    ["zoneId"] = 823,
    ["mapsData"] = lib.goldCoastData,
  },
  [30] = {
    ["mapTexture"] = "vvardenfell/vvardenfell_base_0",
    ["mapIndex"] = 30,
    ["mapId"] = 1060,
    ["zoneIndex"] = 468,
    ["zoneName"] = "Vvardenfell",
    ["zoneId"] = 849,
    ["mapsData"] = lib.vvardenfellData,
  },
  [31] = {
    ["mapTexture"] = "clockwork/clockwork_base_0",
    ["mapIndex"] = 31,
    ["mapId"] = 1313,
    ["zoneIndex"] = 590,
    ["zoneName"] = "Clockwork City",
    ["zoneId"] = 980,
    ["mapsData"] = lib.clockworkCityData,
  },
  [32] = {
    ["mapTexture"] = "summerset/summerset_base_0",
    ["mapIndex"] = 32,
    ["mapId"] = 1349,
    ["zoneIndex"] = 617,
    ["zoneName"] = "Summerset",
    ["zoneId"] = 1011,
    ["mapsData"] = lib.summersetData,
  },
  [33] = {
    ["mapTexture"] = "summerset/artaeum_base_0",
    ["mapIndex"] = 33,
    ["mapId"] = 1429,
    ["zoneIndex"] = 633,
    ["zoneName"] = "Artaeum",
    ["zoneId"] = 1027,
    ["mapsData"] = lib.artaeumData,
  },
  [34] = {
    ["mapTexture"] = "murkmire/murkmire_base_0",
    ["mapIndex"] = 34,
    ["mapId"] = 1484,
    ["zoneIndex"] = 408,
    ["zoneName"] = "Murkmire",
    ["zoneId"] = 726,
    ["mapsData"] = lib.murkmireData,
  },
  [35] = {
    ["mapTexture"] = "elsweyr/elsweyr_base_0",
    ["mapIndex"] = 35,
    ["mapId"] = 1555,
    ["zoneIndex"] = 682,
    ["zoneName"] = "Northern Elsweyr",
    ["zoneId"] = 1086,
    ["mapsData"] = lib.northernElsweyrData,
  },
  [36] = {
    ["mapTexture"] = "southernelsweyr/southernelsweyr_base_0",
    ["mapIndex"] = 36,
    ["mapId"] = 1654,
    ["zoneIndex"] = 721,
    ["zoneName"] = "Southern Elsweyr",
    ["zoneId"] = 1133,
    ["mapsData"] = lib.southernElsweyrData,
  },
        [37] = {
    ["mapTexture"] = "skyrim/westernskryim_base_0",
            ["mapIndex"] = 37,
    ["mapId"] = 1719,
    ["zoneIndex"] = 744,
    ["zoneName"] = "Western Skyrim",
    ["zoneId"] = 1160,
    ["mapsData"] = lib.westernSkyrimData,
  },
        [38] = {
    ["mapTexture"] = "skyrim/blackreach_base_0",
            ["mapIndex"] = 38,
    ["mapId"] = 1747,
    ["zoneIndex"] = 745,
    ["zoneName"] = "Blackreach: Greymoor Caverns",
    ["zoneId"] = 1161,
    ["mapsData"] = lib.blackreachGreymoorCavernsData,
  },
  -- nil dungeon nil main zone
        [39] = {
    ["mapTexture"] = "skyrim/blackreachworld_base_0",
            ["mapIndex"] = 39,
    ["mapId"] = 1782,
    ["zoneIndex"] = "nil",
    ["zoneName"] = "Blackreach",
    ["zoneId"] = "nil",
    ["mapsData"] = lib.blackreachData,
  },
        [40] = {
    ["mapTexture"] = "reach/u28_blackreach_base_0",
    ["mapIndex"] = 40,
    ["mapId"] = 1850,
    ["zoneIndex"] = 785,
    ["zoneName"] = "Blackreach: Arkthzand Cavern",
    ["zoneId"] = 1208,
    ["mapsData"] = lib.blackreachArkthzandCavernData,
  },
        [41] = {
    ["mapTexture"] = "reach/reach_base_0",
    ["mapIndex"] = 41,
    ["mapId"] = 1814,
    ["zoneIndex"] = 784,
    ["zoneName"] = "The Reach",
    ["zoneId"] = 1207,
    ["mapsData"] = lib.theReachData,
  },
        [42] = {
    ["mapTexture"] = "blackwood/blackwood_base_0",
    ["mapIndex"] = 42,
    ["mapId"] = 1887,
    ["zoneIndex"] = 835,
    ["zoneName"] = "Blackwood",
    ["zoneId"] = 1261,
    ["mapsData"] = lib.blackwoodData,
  },
        [43] = {
    --[[Map name is Fargrave, zoneName is The Shambles
    This is when you are looking down at Fargrave City and The Shambles
    before you zoom in. This main map is not considered a subzone,
    The map has a mapIndex, if you zoom into the map for The Shambles it does not
    and the specific Shambles map, is considered a subzone

    Because of the unique situtaion the mapsData is fargraveData rather then shamblesData.
    If there is a need for shamblesData at a later date then it will refer to the unique
    Shambles map itself.

    The zoneName is The Shambles rather then Fargrave because that's what the game will
    return for the zoneName using the zoneIndex as well as using GetZoneNameById if we used
    the zoneId]]--
    ["mapTexture"] = "deadlands/u32_fargravezone_base_0",
    ["mapIndex"] = 43,
    ["mapId"] = 2119,
    ["zoneIndex"] = 855,
    ["zoneName"] = "The Shambles",
    ["zoneId"] = 1283,
    ["mapsData"] = lib.fargraveData,
  },
        [44] = {
    -- The Deadlands Zone, nothing to do with Fargrave
    ["mapTexture"] = "deadlands/u32deadlandszone_base_0",
    ["mapIndex"] = 44,
    ["mapId"] = 2021,
    ["zoneIndex"] = 858,
    ["zoneName"] = "The Deadlands",
    ["zoneId"] = 1286,
    ["mapsData"] = lib.theDeadlandsData,
  },
        [45] = {
    ["mapTexture"] = "systres/u34_systreszone_base_0",
    ["mapIndex"] = 45,
    ["mapId"] = 2114,
    ["zoneIndex"] = 884,
    ["zoneName"] = "High Isle",
    ["zoneId"] = 1318,
    ["mapsData"] = lib.highIsleData,
  },
        [46] = {
    -- Map name is Fargrave City District
    -- zoneName is Fargrave
    -- This is when you are looking at the Fargrave City District itself
    ["mapTexture"] = "deadlands/u32_fargrave_base_0",
    ["mapIndex"] = 46,
    ["mapId"] = 2035,
    ["zoneIndex"] = 854,
    ["zoneName"] = "Fargrave",
    ["zoneId"] = 1282,
    ["mapsData"] = lib.fargraveCityData,
  },
        [47] = {
    ["mapTexture"] = "galen/u36_galenisland_base_0",
    ["mapIndex"] = 47,
    ["mapId"] = 2212,
    ["zoneIndex"] = 931, -- was 930
    ["zoneName"] = "Galen",
    ["zoneId"] = 1383,
    ["mapsData"] = lib.galenData,
  },
        [48] = {
    ["mapTexture"] = "telvanni/u38_telvannipeninsula_base_0",
    ["mapIndex"] = 48,
    ["mapId"] = 2274,
    ["zoneIndex"] = 960, -- was 959
    ["zoneName"] = "Telvanni Peninsula",
    ["zoneId"] = 1414,
    ["mapsData"] = lib.telvanniPeninsulaData,
  },
        [49] = {
    ["mapTexture"] = "apocrypha/u38_apocrypha_base_0",
    ["mapIndex"] = 49,
    ["mapId"] = 2275,
    ["zoneIndex"] = 959, -- was 958
    ["zoneName"] = "Apocrypha",
    ["zoneId"] = 1413,
    ["mapsData"] = lib.apocryphaData,
  },
        [50] = {
    ["mapTexture"] = "westweald/westwealdoverland_base_0",
    ["mapIndex"] = 50,
    ["mapId"] = 2427,
    ["zoneIndex"] = 983, -- was 982
    ["zoneName"] = "West Weald",
    ["zoneId"] = 1443,
    ["mapsData"] = lib.westWealdData,
  },
        [51] = {
    ["mapTexture"] = "guildmaps/eyevea_base_0",
    ["mapIndex"] = 51,
    ["mapId"] = 108,
    ["zoneIndex"] = 99,
    ["zoneName"] = "Eyevea",
    ["zoneId"] = 267,
    ["mapsData"] = lib.eyeveaData,
  },
        [52] = {
    ["mapTexture"] = "solstice/u48_overland_base_0",
    ["mapIndex"] = 52,
    ["mapId"] = 2603,
    ["zoneIndex"] = 1034, -- was 1033
    ["zoneName"] = "Solstice",
    ["zoneId"] = 1502,
    ["mapsData"] = lib.solsticeData,
  },
}
