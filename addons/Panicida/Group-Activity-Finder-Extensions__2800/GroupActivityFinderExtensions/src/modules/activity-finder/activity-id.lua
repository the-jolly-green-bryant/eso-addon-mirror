local GAFE = GroupActivityFinderExtensions

local ACTIVITY_ID = {
  -- ZOs
  NormalFungalGrottoI       = 2,
  VeteranFungalGrottoI      = 299,

  NormalFungalGrottoII      = 18,
  VeteranFungalGrottoII     = 312,

  NormalSpindleclutchI      = 3,
  VeteranSpindleclutchI     = 315,

  NormalSpindleclutchII     = 316,
  VeteranSpindleclutchII    = 19,

  NormalBanishedCellsI      = 4,
  VeteranBanishedCellsI     = 20,

  NormalBanishedCellsII     = 300,
  VeteranBanishedCellsII    = 301,

  NormalDarkshadeCavernsI   = 5,
  VeteranDarkshadeCavernsI  = 309,

  NormalDarkshadeCavernsII  = 308,
  VeteranDarkshadeCavernsII = 21,

  NormalEldenHollowI        = 7,
  VeteranEldenHollowI       = 23,

  NormalEldenHollowII       = 303,
  VeteranEldenHollowII      = 302,

  NormalWayrestSewersI      = 6,
  VeteranWayrestSewersI     = 306,

  NormalWayrestSewersII     = 22,
  VeteranWayrestSewersII    = 307,

  NormalArxCorinium         = 8,
  VeteranArxCorinium        = 305,

  NormalCityOfAshI          = 10,
  VeteranCityOfAshI         = 310,

  NormalCityOfAshII         = 322,
  VeteranCityOfAshII        = 267,

  NormalCryptOfHeartsI      = 9,
  VeteranCryptOfHeartsI     = 261,

  NormalCryptOfHeartsII     = 317,
  VeteranCryptOfHeartsII    = 318,

  NormalDirefrostKeep       = 11,
  VeteranDirefrostKeep      = 319,

  NormalTempestIsland       = 13,
  VeteranTempestIsland      = 311,

  NormalVolenfell           = 12,
  VeteranVolenfell          = 304,

  NormalBlackheartHaven     = 15,
  VeteranBlackheartHaven    = 321,

  NormalBlessedCrucible     = 14,
  VeteranBlessedCrucible    = 320,

  NormalSelenesWeb          = 16,
  VeteranSelenesWeb         = 313,

  NormalVaultsOfMadness     = 17,
  VeteranVaultsOfMadness    = 314,

  NormalBalSunnar           = 613,
  VeteranBalSunnar          = 614,

  NormalBedlamVeil          = 640,
  VeteranBedlamVeil         = 641,

  NormalBlackDrakeVilla     = 591,
  VeteranBlackDrakeVilla    = 592,

  NormalBlackGemFoundry     = 1039,
  VeteranBlackGemFoundry    = 1040,

  NormalBloodrootForge      = 324,
  VeteranBloodrootForge     = 325,

  NormalCastleThorn         = 509,
  VeteranCastleThorn        = 510,

  NormalCoralAerie          = 599,
  VeteranCoralAerie         = 600,

  NormalCradleOfShadows     = 295,
  VeteranCradleOfShadows    = 296,

  NormalDepthsOfMalatar     = 435,
  VeteranDepthsOfMalatar    = 436,

  NormalFalkreathHold       = 368,
  VeteranFalkreathHold      = 369,

  NormalFangLair            = 420,
  VeteranFangLair           = 421,

  NormalFrostvault          = 433,
  VeteranFrostvault         = 434,

  NormalIcereach            = 503,
  VeteranIcereach           = 504,

  NormalImperialCityPrison  = 289,
  VeteranImperialCityPrison = 268,

  NormalLairOfMaarselok     = 496,
  VeteranLairOfMaarselok    = 497,

  NormalMarchOfSacrifices   = 428,
  VeteranMarchOfSacrifices  = 429,

  NormalMoonHunterKeep      = 426,
  VeteranMoonHunterKeep     = 427,

  NormalNajCaldeesh         = 1037,
  VeteranNajCaldeesh        = 1038,

  NormalMoongraveFane       = 494,
  VeteranMoongraveFane      = 495,

  NormalOathswornPit        = 638,
  VeteranOathswornPit       = 639,

  NormalRedPetalBastion     = 595,
  VeteranRedPetalBastion    = 596,

  NormalRuinsOfMazzatun     = 293,
  VeteranRuinsOfMazzatun    = 294,

  NormalScalecallerPeak     = 418,
  VeteranScalecallerPeak    = 419,

  NormalScrivenersHall      = 615,
  VeteranScrivenersHall     = 616,

  NormalShipwrightsRegret   = 601,
  VeteranShipwrightsRegret  = 602,

  NormalStoneGarden         = 507,
  VeteranStoneGarden        = 508,

  NormalCauldron            = 593,
  VeteranCauldron           = 594,

  NormalDreadCellar         = 597,
  VeteranDreadCellar        = 598,

  NormalUnhallowedGrave     = 505,
  VeteranUnhallowedGrave    = 506,

  NormalWhiteGoldTower      = 288,
  VeteranWhiteGoldTower     = 287,

  NormalEarthenRootEnclave  = 608,
  VeteranEarthenRootEnclave = 609,

  NormalGravenDeep          = 610,
  VeteranGravenDeep         = 611,

  NormalExiledRedbout       = 855,
  VeteranExiledRedbout      = 856,

  NormalLepScluse           = 857,
  VeteranLepScluse          = 858,

  -- Custom ids. For safety start from 10000
  NormalAetherianArchive    = 10001,
  VeteranAetherianArchive   = 10002,

  NormalHelRaCitadel        = 10003,
  VeteranHelRaCitadel       = 10004,

  NormalSanctumOphidia      = 10005,
  VeteranSanctumOphidia     = 10006,

  NormalMawOfLorkhaj        = 10007,
  VeteranMawOfLorkhaj       = 10008,

  NormalHallsOfFabrication  = 10009,
  VeteranHallsOfFabrication = 10010,

  NormalAsylumSanctorium    = 10011,
  VeteranAsylumSanctorium   = 10012,

  NormalCloudrest           = 10013,
  VeteranCloudrest          = 10014,

  NormalSunspire            = 10015,
  VeteranSunspire           = 10016,

  NormalKynesAegis          = 10017,
  VeteranKynesAegis         = 10018,

  NormalRockgrove           = 10019,
  VeteranRockgrove          = 10020,

  NormalDreadsailReef       = 10021,
  VeteranDreadsailReef      = 10022
}

GAFE.ACTIVITY_ID = ACTIVITY_ID
