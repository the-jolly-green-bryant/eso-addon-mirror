  EPT = EPT or {}
local EPT = EPT

---------------------
-- LOCAL FUNCTIONS --
---------------------

local function GetSetName(itemLink)
    local _, setName, _, _, _, _ = GetItemLinkSetInfo(itemLink)
    --resize setName on multiple lines if necessary "\n"
    return zo_strformat( SI_ABILITY_NAME, setName )
end

local courageMajor = {
  [110020] = "perfectOlo",
  [66902] = "spc",
  [109994] = "normalOlo"
}

-----------
-- Arena --
-----------

local forceOverflow = { --562
    ["setName"] = GetSetName("|H0:item:169891:364:50:0:0:0:0:0:0:0:0:0:0:0:1:10:0:1:0:500:0|h|h"),
    ["abilityId"] = 147875,
    ["cooldown"] = 10000,
    ["origin"] = EPT_ORIGIN_ARENA,
}

local forceOverflowPerfect = { --568
    ["setName"] = GetSetName("|H0:item:170010:364:50:0:0:0:0:0:0:0:0:0:0:0:1:10:0:1:0:500:0|h|h"),
    ["abilityId"] = 147875,
    ["cooldown"] = 10000,
    ["origin"] = EPT_ORIGIN_ARENA,
}

local elementWrath = { --561
    ["setName"] = GetSetName("|H0:item:169889:364:50:0:0:0:0:0:0:0:0:0:0:0:1:10:0:1:0:500:0|h|h"),
    ["abilityId"] = 147843,
    ["cooldown"] = 10000,
    ["origin"] = EPT_ORIGIN_ARENA,
}

local elementWrathPerfect = { --567
    ["setName"] = GetSetName("|H0:item:170076:364:50:0:0:0:0:0:0:0:0:0:0:0:1:10:0:1:0:500:0|h|h"),
    ["abilityId"] = 147843,
    ["cooldown"] = 10000,
    ["origin"] = EPT_ORIGIN_ARENA,
}

local voidBash = { --558
    ["setName"] = GetSetName("|H0:item:169878:364:50:0:0:0:0:0:0:0:0:0:0:0:1:10:0:1:0:500:0|h|h"),
    ["abilityId"] = 147747,
    ["cooldown"] = 13000,
    ["origin"] = EPT_ORIGIN_ARENA,
}

local voidBashPerfect = { --564
    ["setName"] = GetSetName("|H0:item:170047:364:50:0:0:0:0:0:0:0:0:0:0:0:1:10:0:1:0:500:0|h|h"),
    ["abilityId"] = 147747,
    ["cooldown"] = 13000,
    ["origin"] = EPT_ORIGIN_ARENA,
}

local destructiveImpact = { --317
  ["setName"] = GetSetName("|H0:item:133807:364:50:0:0:0:0:0:0:0:0:0:0:0:1:4:0:1:0:495:0|h|h"),
  ["abilityId"] = 140334,
  ["origin"] = EPT_ORIGIN_ARENA,
}

local destructiveImpactPerfect = { --532
  ["setName"] = GetSetName("|H0:item:166062:364:50:0:0:0:0:0:0:0:0:0:0:0:1:5:0:1:0:499:0|h|h"),
  ["abilityId"] = 140334,
  ["origin"] = EPT_ORIGIN_ARENA,
}

local winterborn = { --217
  ["setName"] = GetSetName("|H0:item:68574:364:50:0:0:0:0:0:0:0:0:0:0:0:1:37:0:1:0:10000:0|h|h"),
  ["abilityId"] = 71647,
  ["cooldown"] = 6000,
  ["origin"] = EPT_ORIGIN_ARENA,
}
---------------
-- Undaunted --
---------------

local grothdarr = { --280
  ["setName"] = GetSetName("|H0:item:94853:364:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h"),
  ["abilityId"] = 84504,
  ["cooldown"] = 10000,
  ["origin"] = EPT_ORIGIN_UNDAUNTED,
}

local bogdan = { --167
  ["setName"] = GetSetName("|H0:item:59577:364:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h"),
  ["abilityId"] = 59590,
  ["cooldown"] = 10000,
  ["origin"] = EPT_ORIGIN_UNDAUNTED,
}

local sentinel = { --268
  ["setName"] = GetSetName("|H0:item:94757:364:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h"),
  ["abilityId"] = 81036,
  ["cooldown"] = 15000,
  ["origin"] = EPT_ORIGIN_UNDAUNTED,
}

local earthgore = { --341
  ["setName"] = GetSetName("|H0:item:127705:364:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h"),
  ["abilityId"] = 97855,
  ["cooldown"] = 20000,
  ["origin"] = EPT_ORIGIN_UNDAUNTED,
}

local tremorscale = { --276
  ["setName"] = GetSetName("|H0:item:94821:364:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h"),
  ["abilityId"] = 80865,
  ["cooldown"] = 10000,
  ["origin"] = EPT_ORIGIN_UNDAUNTED,
}
--local symphony = {
--  ["setName"] = GetSetName("|H0:item:147243:364:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h"),
--  ["setId"] = 436,
--  ["abilities"] = {
--    [1] = {
--      ["abilityId"] = 117111,
--      ["unitTag"] = xxx,
--      ["cd"] = InMilliSec(18),
--          },
--  },
--}
local infernalGuardian = { --272
  ["setName"] = GetSetName("|H0:item:94516:364:50:0:0:0:0:0:0:0:0:0:0:0:2048:67:0:0:0:10000:0|h|h"),
  ["abilityId"] = 83405,
  ["origin"] = EPT_ORIGIN_UNDAUNTED,
  ["cooldown"] = 6000,
}

local iceheart = { --274
  ["setName"] = GetSetName("|H0:item:94532:364:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h"),
  ["abilityId"] = 80562,
  ["origin"] = EPT_ORIGIN_UNDAUNTED,
  ["cooldown"] = 6000,
}

local ladyThorn = { --535
  ["setName"] = GetSetName("|H0:item:167128:364:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h"),
  ["abilityId"] = 141905,--proc
  --["abilityId"] = 141971, --synergyActivate
  --["abilityId"] = 141927, --Maim
  --["cooldown"] = 20000,
  --["type"] = "special",
}

local sellistrix = { --271
  ["setName"] = GetSetName("|H0:item:94781:364:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h"),
  ["abilityId"] = 80545,
  ["cooldown"] = 6000,
  ["origin"] = EPT_ORIGIN_UNDAUNTED,
  --80544 (result1)
  --80549 (result 2000)
}

local encratisBehemoth = { --577
  ["setName"] = GetSetName("|H0:item:171602:364:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h"),
  ["abilityId"] = 151033,
  ["origin"] = EPT_ORIGIN_UNDAUNTED,
  ["cooldown"] = 15000,
}

local zaan = { -- 350
  ["setName"] = GetSetName("|H0:item:129563:364:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h"),
  ["abilityId"] = 110997,--102136, --102142
  ["origin"] = EPT_ORIGIN_UNDAUNTED,
  ["cooldown"] = 20000,
}

local vykosa = { --398
  ["setName"] = GetSetName("|H0:item:141674:364:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h"),
  ["abilityId"] = 111354, --102142
  ["origin"] = EPT_ORIGIN_UNDAUNTED,
  ["cooldown"] = 15000,
}

local magmaIncarnate = { --609
  ["setName"] = GetSetName("|H0:item:178627:364:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h"),
  ["abilityId"] = 159329, --159329
  ["origin"] = EPT_ORIGIN_UNDAUNTED,
  ["cooldown"] = 15000,
}

local priorThierric = { --608
  ["setName"] = GetSetName("|H0:item:178571:364:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h"),
  ["abilityId"] = 159500,
  ["origin"] = EPT_ORIGIN_UNDAUNTED,
  ["cooldown"] = 15000,
}

local nazaray = { --633
  ["setName"] = GetSetName("|H0:item:183795:364:50:0:0:0:11:0:0:0:0:0:0:0:2049:67:0:1:0:10000:0|h|h"),
  ["origin"] = EPT_ORIGIN_UNDAUNTED,
  ["cooldown"] = 30000,
  ["abilityId"] = 167065,--167930
}

local kargaeda = { --632
  ["setName"] = GetSetName("|H0:item:183739:364:50:0:0:0:11:0:0:0:0:0:0:0:2049:67:0:1:0:10000:0|h|h"),
  ["origin"] = EPT_ORIGIN_UNDAUNTED,
  ["cooldown"] = 20000,
  ["abilityId"] = 167052,
}

-----------
-- Raids --
-----------

local olo = { --391
  ["setName"] = GetSetName("|H0:item:137362:364:50:0:0:0:0:0:0:0:0:0:0:0:1:73:0:1:0:10000:0|h|h"),
  ["abilityId"] = 107141,
  ["cooldown"] = 10000,
  ["origin"] = EPT_ORIGIN_TRIAL,
}

local oloPerf = { --395
  ["setName"] = GetSetName("|H0:item:138558:364:50:0:0:0:0:0:0:0:0:0:0:0:1:73:0:1:0:10000:0|h|h"),
  ["abilityId"] = 107141,
  ["cooldown"] = 10000,
  ["origin"] = EPT_ORIGIN_TRIAL,
}

local yolnah = { --446
  ["setName"] = GetSetName("|H0:item:149651:364:50:0:0:0:0:0:0:0:0:0:0:0:1:86:0:1:0:10000:0|h|h"),
  ["abilityId"] = 121878,
  ["cooldown"] = 8000,
  ["origin"] = EPT_ORIGIN_TRIAL,
}

local yolnahPerf = { --451
  ["setName"] = GetSetName("|H0:item:150852:364:50:0:0:0:0:0:0:0:0:0:0:0:1:86:0:1:0:10000:0|h|h"),
  ["abilityId"] = 121878,
  ["cooldown"] = 8000,
  ["origin"] = EPT_ORIGIN_TRIAL,
}

local wind = { --492
  ["setName"] = GetSetName("|H0:item:162413:364:50:0:0:0:0:0:0:0:0:0:0:0:1:102:0:1:0:10000:0|h|h"),
  ["abilityId"] = 136098,
  ["cooldown"] = 10000,
  ["origin"] = EPT_ORIGIN_TRIAL,
}

local windPerf = { --493
  ["setName"] = GetSetName("|H0:item:162956:364:50:0:0:0:0:0:0:0:0:0:0:0:1:102:0:1:0:10000:0|h|h"),
  ["abilityId"] = 136098,
  ["cooldown"] = 10000,
  ["origin"] = EPT_ORIGIN_TRIAL,
}

local opportunist = { --496
  ["setName"] = GetSetName("|H1:item:161965:364:50:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"),
  ["abilityId"] = 135923,
  ["debuff"] = 135924,
  ["cooldown"] = 22000,
  ["type"] = "special",
  ["origin"] = EPT_ORIGIN_TRIAL,
}

local opportunistPerf = { --497
  ["setName"] = GetSetName("|H1:item:162508:364:50:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"),
  ["abilityId"] = 135923, --137986
  ["debuff"] = 135924, --137985,
  ["cooldown"] = 22000,
  ["type"] = "special",
  ["origin"] = EPT_ORIGIN_TRIAL,
}

local moondancer = { --230
  ["setName"] = GetSetName("|H0:item:73006:363:50:0:0:0:0:0:0:0:0:0:0:0:1:45:0:1:0:10000:0|h|h"),
  ["setId"] = 230,
  ["abilityId"] = {75801, 75804},
  ["cooldown"] = {0,0},
  ["type"] = "special",
  ["origin"] = EPT_ORIGIN_TRIAL,
}

local vrolNorm= { --494
  ["setName"] = GetSetName("|H0:item:162264:363:50:0:0:0:0:0:0:0:0:0:0:0:1:45:0:1:0:10000:0|h|h"),
  ["abilityId"] = 135926,
  ["cooldown"] = 21000,
  ["origin"] = EPT_ORIGIN_TRIAL,
}

local vrolPerf = { --495
  ["setName"] = GetSetName("|H0:item:162807:363:50:0:0:0:0:0:0:0:0:0:0:0:1:45:0:1:0:10000:0|h|h"),
  ["abilityId"] = 135926,
  ["cooldown"] = 21000,
  ["origin"] = EPT_ORIGIN_TRIAL,
}

local bahseiMania = { --587
  ["setName"] = GetSetName("|H0:item:173630:364:50:0:0:0:0:0:0:0:0:0:0:0:1:122:0:1:0:10000:0|h|h"),
  ["abilityId"] = 154691,
  ["origin"] = EPT_ORIGIN_TRIAL,
  ["type"] = "special"
}

local bahseiManiaPerf = { --591
  ["setName"] = GetSetName("|H0:item:174441:364:50:0:0:0:0:0:0:0:0:0:0:0:1:122:0:1:0:10000:0|h|h"),
  ["abilityId"] = 154691,
  ["origin"] = EPT_ORIGIN_TRIAL,
  ["type"] = "special"
}

local stoneTalkerOath = { --588
  ["setName"] = GetSetName("|H0:item:174039:364:50:0:0:0:0:0:0:0:0:0:0:0:1:122:0:1:0:10000:0|h|h"),
  ["abilityId"] = 154783,
  ["cooldown"] = 10000,
  ["origin"] = EPT_ORIGIN_TRIAL,
}

local stoneTalkerOathPerfect = { --592
  ["setName"] = GetSetName("|H0:item:174258:364:50:0:0:0:0:0:0:0:0:0:0:0:1:122:0:1:0:10000:0|h|h"),
  ["abilityId"] = 154783,
  ["cooldown"] = 10000,
  ["origin"] = EPT_ORIGIN_TRIAL,
}

local sulXanTorment = { --586
  ["setName"] = GetSetName("|H0:item:173766:364:50:0:0:0:0:0:0:0:0:0:0:0:1:122:0:1:0:10000:0|h|h"),
  ["abilityId"] = 154737,--157058,
  ["origin"] = EPT_ORIGIN_TRIAL,
}

local sulXanTormentPerfect = { --590
  ["setName"] = GetSetName("|H0:item:174624:364:50:0:0:0:0:0:0:0:0:0:0:0:1:122:0:1:0:10000:0|h|h"),
  ["abilityId"] = 154737,--157058,
  ["origin"] = EPT_ORIGIN_TRIAL,
}

local lunarBastion = { --231
  ["setName"] = GetSetName("|H0:item:73077:364:50:0:0:0:0:0:0:0:0:0:0:0:1:45:0:1:0:10000:0|h|h"),
  ["abilityId"] = 75814,--157058,
  ["origin"] = EPT_ORIGIN_TRIAL,
  ["cooldown"] = 20000,
}

local siroria = { --390
  ["setName"] = GetSetName("|H0:item:137170:364:50:0:0:0:0:0:0:0:0:0:0:0:1:73:0:1:0:10000:0|h|h"),
  ["abilityId"] = 110118,
  ["origin"] = EPT_ORIGIN_TRIAL,
  ["type"] = "stackself",
  ["maxstack"] = 8,
}

local siroriaPerf = { --394
  ["setName"] = GetSetName("|H0:item:138367:364:50:0:0:0:0:0:0:0:0:0:0:0:1:73:0:1:0:10000:0|h|h"),
  ["abilityId"] = 110118,
  ["origin"] = EPT_ORIGIN_TRIAL,
  ["type"] = "stackself",
  ["maxstack"] = 8,
}

local berserkingWarrior = { --137
  ["setName"] = GetSetName("|H0:item:113409:364:50:0:0:0:0:0:0:0:0:0:0:0:1:27:0:1:0:10000:0|h|h"),
  ["abilityId"] = 50978,
  ["origin"] = EPT_ORIGIN_TRIAL,
  ["type"] = "stackself",
  ["maxstack"] = 10,
}


------------
-- Dungeon --
-------------

local banisTorment = { --473
  ["setName"] = GetSetName("|H0:item:157266:364:50:0:0:0:0:0:0:0:0:0:0:0:1:97:0:1:0:10000:0|h|h"),
  ["abilityId"] = 133292, --Major Maim
  ["cooldown"] = 15000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

local caluurion = { --343
  ["setName"] = GetSetName("|H0:item:128593:364:50:0:0:0:0:0:0:0:0:0:0:0:1:69:0:1:0:10000:0|h|h"),
  ["abilityId"] = 102032,
  ["cooldown"] = 10000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

local hitis = { --471
  ["setName"] = GetSetName("|H0:item:156888:364:50:0:0:0:0:0:0:0:0:0:0:0:1:97:0:1:0:10000:0|h|h"),
  ["abilityId"] = 133210,
  ["cooldown"] = 12000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

local hollowfang = { --452
  ["setName"] = GetSetName("|H0:item:152577:364:50:0:0:0:0:0:0:0:0:0:0:0:1:93:0:1:0:10000:0|h|h"),
  ["abilityId"] = 126924,
  ["cooldown"] = 9000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

local burningSpellweave = { --160
  ["setName"] = GetSetName("|H0:item:104521:364:50:0:0:0:0:0:0:0:0:0:0:0:1:20:0:1:0:10000:0|h|h"),
  ["abilityId"] = 61459,
  ["cooldown"] = 12000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}


local zen = { --455
  ["setName"] = GetSetName("|H1:item:153094:363:50:0:0:0:0:0:0:0:0:0:0:0:1:89:0:1:0:0:0|h|h"),
  ["abilityId"] = 126597,
  ["cooldown"] = 22000,
  ["type"] = "special",
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

local spellPowerCure = { --185
  ["setName"] = GetSetName("|H0:item:111909:364:50:0:0:0:0:0:0:0:0:0:0:0:1:29:0:1:0:10000:0|h|h"),
  ["abilityId"] = 66902,
  ["cooldown"] = 5000,
  ["type"] = "value",
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

local icyConjuror = { --431
  ["setName"] = GetSetName("|H0:item:146480:364:50:0:0:0:0:0:0:0:0:0:0:0:1:82:0:1:0:10000:0|h|h"),
  ["abilityId"] = 117666,
  ["cooldown"] = 10000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

local drakesRush = { --571
  ["setName"] = GetSetName("|H0:item:170607:364:50:0:0:0:0:0:0:0:0:0:0:0:1:116:0:1:0:10000:0|h|h"),
  ["abilityId"] = 150974,
  ["cooldown"] = 18000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

local crimsonTwilight = { --515
  ["setName"] = GetSetName("|H0:item:164710:364:50:0:0:0:0:0:0:0:0:0:0:0:1:106:0:1:0:10000:0|h|h"),
  ["abilityId"] = 141638,
  ["cooldown"] = 8000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

local plagueSlinger = { --347
  ["setName"] = GetSetName("|H0:item:129338:364:50:0:0:0:0:0:0:0:0:0:0:0:1:70:0:1:0:10000:0|h|h"),
  ["abilityId"] = 102106,
  ["cooldown"] = 8000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

local scathingMage = { --190
  ["setName"] = GetSetName("|H0:item:111325:364:50:0:0:0:0:0:0:0:0:0:0:0:1:70:0:1:0:10000:0|h|h"),
  ["abilityId"] = 67288,
  ["cooldown"] = 5000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

local scorionsFeast = { --603
  ["setName"] = GetSetName("|H0:item:177596:364:50:0:0:0:0:0:0:0:0:0:0:0:1:123:0:1:0:10000:0|h|h"),
  ["abilityId"] = 159237, --imbued aura; 159236 overflow aura
  ["cooldown"] = 20000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

local rushOfAgony = { --604
  ["setName"] = GetSetName("|H0:item:177768:364:50:0:0:0:0:0:0:0:0:0:0:0:1:123:0:1:0:10000:0|h|h"),
  ["abilityId"] = 159279, --276 277 275
  ["cooldown"] = 8000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

local crimsonOathRive = { --602
  ["setName"] = GetSetName("|H0:item:177430:364:50:0:0:0:0:0:0:0:0:0:0:0:1:123:0:1:0:10000:0|h|h"),
  ["abilityId"] = 159291, --152288 debuff
  ["cooldown"] = 12000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

local thunderCaller = { --606
  ["setName"] = GetSetName("|H0:item:178099:364:50:0:0:0:0:0:0:0:0:0:0:0:1:124:0:1:0:9850:0|h|h"),
  ["abilityId"] = 159249, --152288 debuff
  ["cooldown"] = 12000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

local tzogvinWarband = { -- 430
  ["setName"] = GetSetName("|H0:item:146297:364:50:0:0:0:0:0:0:0:0:0:0:0:1:82:0:1:0:10000:0|h|h"),
  ["abilityId"] = 116742,
  ["origin"] = EPT_ORIGIN_DUNGEON,
  ["type"] = "stackself",
  ["maxstack"] = 10,
}

local kinrasWrath = { -- 570
  ["setName"] = GetSetName("|H0:item:170442:364:50:0:0:0:0:0:0:0:0:0:0:0:1:116:0:1:0:10000:0|h|h"),
  ["abilityId"] = 150750,
  ["origin"] = EPT_ORIGIN_DUNGEON,
  ["type"] = "stackself",
  ["maxstack"] = 5,
}

local turningTide = { --622
  ["setName"] = GetSetName("|H0:item:181739:364:50:68343:370:50:11:0:0:0:0:0:0:0:1:128:0:1:0:10000:0|h|h"),
  ["abilityId"] = 167350,
  ["cooldown"] = 15000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

local glacialGuardian = { --621
  ["setName"] = GetSetName("|H0:item:181306:364:50:0:0:0:0:0:0:0:0:0:0:0:1:129:0:1:0:10000:0|h|h"),
  ["abilityId"] = 167114,
  ["cooldown"] = 12000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

local gryphonsReprisal = { --620
  ["setName"] = GetSetName("|H0:item:181141:364:50:0:0:0:0:0:0:0:0:0:0:0:1:129:0:1:0:10000:0|h|h"),
  ["abilityId"] = 167043,
  ["cooldown"] = 20000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

local spriggansVigor = { --624
  ["setName"] = GetSetName("|H0:item:182080:364:50:0:0:0:0:0:0:0:0:0:0:0:1:128:0:1:0:10000:0|h|h"),
  ["abilityId"] = 167058,
  ["origin"] = EPT_ORIGIN_DUNGEON,
  ["type"] = "stackself",
  ["maxstack"] = 10,
}

local maligaligsMaelstrom = { --619
  ["setName"] = GetSetName("|H0:item:180969:364:50:0:0:0:0:0:0:0:0:0:0:0:1:129:0:1:0:10000:0|h|h"),
  ["abilityId"] = 167040,--168019,
  ["cooldown"] = 10000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

--------------
-- Overland --
--------------

local briarheart = { --212
  ["setName"] = GetSetName("|H0:item:68494:364:50:0:0:0:0:0:0:0:0:0:0:0:1:37:0:1:0:10000:0|h|h"),
  ["abilityId"] = 71107,
  ["cooldown"] = 15000,
  ["origin"] = EPT_ORIGIN_OVERLAND,
}

local winter = { --487
  ["setName"] = GetSetName("|H0:item:160666:364:50:0:0:0:0:0:0:0:0:0:0:0:1:100:0:1:0:10000:0|h|h"),
  ["abilityId"] = 135659,
  ["cooldown"] = 10000,
  ["origin"] = EPT_ORIGIN_OVERLAND,
}

local venomousSmite = { --488
  ["setName"] = GetSetName("|H0:item:160859:364:50:0:0:0:0:0:0:0:0:0:0:0:1:101:0:1:0:10000:0|h|h"),
  ["abilityId"] = 135690,
  ["cooldown"] = 15000,
  ["origin"] = EPT_ORIGIN_OVERLAND,
}

local redMountain = { --49
  ["setName"] = GetSetName("|H0:item:84934:364:50:0:0:0:0:0:0:0:0:0:0:0:1:54:0:1:0:10000:0|h|h"),
  ["abilityId"] = 97806,
  ["cooldown"] = 8000,
  ["origin"] = EPT_ORIGIN_OVERLAND,
}

local madTinkerer = { --354
  ["setName"] = GetSetName("|H0:item:132887:364:50:0:0:0:0:0:0:0:0:0:0:0:1:65:0:1:0:10000:0|h|h"),
  ["abilityId"] = 92982,
  ["cooldown"] = 8000,
  ["origin"] = EPT_ORIGIN_OVERLAND,
}

local martialKnowledge = { --147
  ["setName"] = GetSetName("|H1:item:95453:363:50:0:0:0:0:0:0:0:0:0:0:0:1:35:0:1:0:0:0|h|h"),
  ["abilityId"] = 127070,
  ["cooldown"] = 8000,
  ["type"] = "special",
  ["origin"] = EPT_ORIGIN_OVERLAND,
}

--------------
-- Crafting --
--------------

local mechAcuity = { --353
  ["setName"] = GetSetName("|H0:item:131086:25:4:0:0:0:0:0:0:0:0:0:0:0:1:4:1:1:0:10000:0|h|h"),
  ["abilityId"] = 99204, --164087,
  ["cooldown"] = 29000,
  ["type"] = "stackself",
  ["origin"] = EPT_ORIGIN_CRAFTING,
  ["maxstack"] = 5,
}

local cleverAlchemist = { --225
  ["setName"] = GetSetName("|H0:item:72141:30:1:0:0:0:0:0:0:0:0:0:0:0:1:1:1:1:0:10000:0|h|h"),
  ["abilityId"] = 75746,
  ["origin"] = EPT_ORIGIN_CRAFTING,
}

local spectresEye = { --74
  ["setName"] = GetSetName("|H0:item:50085:369:50:0:0:0:0:0:0:0:0:0:0:0:1:20:1:1:0:10000:0|h|h"),
  ["abilityId"] = 69685,
  ["origin"] = EPT_ORIGIN_CRAFTING,
}

-----------------
-- Cyrodiil/IC --
-----------------

local powerfulAssault = { --180
  ["setName"] = GetSetName("|H0:item:117125:364:50:0:0:0:0:0:0:0:0:0:0:0:1:23:0:1:0:10000:0|h|h"),
  ["abilityId"] = 61771,
  ["origin"] = EPT_ORIGIN_PVP,
}

local meritoriousService = { --181
  ["setName"] = GetSetName("|H0:item:116744:364:50:0:0:0:0:0:0:0:0:0:0:0:1:23:0:1:0:10000:0|h|h"),
  ["abilityId"] = 65706,
  ["origin"] = EPT_ORIGIN_PVP,
}

local darkConvergence = { --616
  ["setName"] = GetSetName("|H0:item:180445:362:50:0:0:0:11:0:0:0:0:0:0:0:2049:23:0:1:0:10000:0|h|h"),
  ["abilityId"] = 159388, --160317
  ["origin"] = EPT_ORIGIN_PVP,
  ["cooldown"] = 25000,
}

local hrothgarsChill = { --618
  ["setName"] = GetSetName("|H0:item:180783:364:50:0:0:0:11:0:0:0:0:0:0:0:2049:23:0:1:0:10000:0|h|h"),
  ["abilityId"] = 159713, --159713, 159740, 159793-somebody gets hit by explosions
  ["origin"] = EPT_ORIGIN_PVP,
  ["cooldown"] = 7000,
}

local nunatak = { --634
  ["setName"] = GetSetName("|H0:item:183903:364:50:0:0:0:11:0:0:0:0:0:0:0:2049:67:0:1:0:10000:0|h|h"),
  ["abilityId"] = 167682,
  ["origin"] = EPT_ORIGIN_PVP,
  ["cooldown"] = 15000,
}
-----------------
-- Mythic	   --
-----------------
-- Thrassian Stranglers
local ThrassianStranglers = { --501
  ["setName"] = GetSetName("|H0:item:164291:364:50:0:0:0:0:0:0:0:0:0:0:0:1:23:0:1:0:10000:0|h|h"),
  ["abilityId"] = 136123,
  ["origin"] = EPT_ORIGIN_MYTHIC,
  ["type"] = "stackself",
  ["maxstack"] = 50,
}
-- Harpooner's Wading Kilt
local HarpoonerWadingKilt = { -- 594
  ["setName"] = GetSetName("|H0:item:175524:364:50:0:0:0:0:0:0:0:0:0:0:0:1:23:0:1:0:10000:0|h|h"),
  ["abilityId"] = 155150,
  ["origin"] = EPT_ORIGIN_MYTHIC,
  ["type"] = "stackself",
  ["maxstack"] = 10,
}
-- Death Dealer's Fete
local DeathDealerFete = { -- 596
  ["setName"] = GetSetName("|H0:item:175527:364:50:0:0:0:0:0:0:0:0:0:0:0:1:23:0:1:0:10000:0|h|h"),
  ["abilityId"] = 155176,
  ["origin"] = EPT_ORIGIN_MYTHIC,
  ["type"] = "stackself",
  ["maxstack"] = 30,
}

local spaulderOfRuin = { -- 627
  ["setName"] = GetSetName("|H0:item:181695:364:50:0:0:0:11:0:0:0:0:0:0:0:2049:10:0:1:0:10000:0|h|h"),
  ["abilityId"] = 163401,
  ["origin"] = EPT_ORIGIN_MYTHIC,
  ["type"] = "special",
}

local bloodlordsEmbrace = { --521
  ["setName"] = GetSetName("|H0:item:165899:364:50:0:0:0:0:0:0:0:0:0:0:0:1:10:0:1:0:10000:0|h|h"),
  ["abilityId"] = 139903,
  ["origin"] = EPT_ORIGIN_MYTHIC,
  ["type"] = "special",
}


-- High Isle
local perfectPillar = { --650
  ["setName"] = GetSetName("|H0:item:187077:364:50:0:0:0:0:0:0:0:0:0:0:0:1:130:0:1:0:10000:0|h|h"),
  ["abilityId"] = 172056,--172056,
  ["cooldown"] = 45000,
  ["origin"] = EPT_ORIGIN_TRIAL,
}
local Pillar = { --649
  ["setName"] = GetSetName("|H0:item:186838:364:50:0:0:0:11:0:0:0:0:0:0:0:2049:130:0:1:0:10000:0|h|h"), --link of perfected version
  ["abilityId"] = 172056,--172056,
  ["cooldown"] = 45000,
  ["origin"] = EPT_ORIGIN_TRIAL,
}

local perfWhorl = { --653
  ["setName"] = GetSetName("|H0:item:187260:364:50:0:0:0:0:0:0:0:0:0:0:0:1:130:0:1:0:10000:0|h|h"),
  ["abilityId"] = 172671,
  ["cooldown"] = 18000,
  ["origin"] = EPT_ORIGIN_TRIAL,
}

local whorl = { --646
  ["setName"] = GetSetName("|H0:item:186428:364:50:0:0:0:11:0:0:0:0:0:0:0:2049:130:0:1:0:10000:0|h|h"),
  ["abilityId"] = 172671,
  ["cooldown"] = 18000,
  ["origin"] = EPT_ORIGIN_TRIAL,
}

local seaSerpent = { --657
  ["setName"] = GetSetName("|H0:item:187657:364:50:0:0:0:32:0:0:0:0:0:0:0:2049:0:0:1:0:0:0|h|h"),
  ["abilityId"] = 172865,
  ["cooldown"] = 10000,
  ["origin"] = EPT_ORIGIN_TRIAL,
}

---

local deeprootZeal = { --660 -- can not be tracked?
  ["setName"] = GetSetName("|H1:item:188380:364:50:0:0:0:0:0:0:0:0:0:0:0:1:135:0:1:0:9900:0|h|h"),
  ["abilityId"] = 178566, -- 176658, 176659, 176660 (none of the them actually works :/)
  ["cooldown"] = 2000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}

local stonesAccord = { --661
  ["setName"] = GetSetName("|H1:item:188551:364:50:0:0:0:0:0:0:0:0:0:0:0:1:135:0:1:0:10000:0|h|h"),
  ["abilityId"] = 174981,
  ["cooldown"] = 5000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
  ["icon"] = GetAbilityIcon(61744) -- minor berserk
}

local rageOfTheUrsauk = { --662
  ["setName"] = GetSetName("|H1:item:188718:364:50:0:0:0:0:0:0:0:0:0:0:0:1:135:0:1:0:10000:0|h|h"),
  ["abilityId"] = 176572, -- 176571 Empower, 176570 Proc, 177678(12100ms)
  ["cooldown"] = 8000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
  ["icon"] = GetAbilityIcon(61737) -- empower
}

local pangritDenmother = { --663
  ["setName"] = GetSetName("|H1:item:188883:364:50:0:0:0:0:0:0:0:0:0:0:0:1:136:0:1:0:10000:0|h|h"),
  ["abilityId"] = 176883,
  ["cooldown"] = 5000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
  ["icon"] = GetAbilityIcon(147417) -- minor courage
}

local graveInevitability = { --664
  ["setName"] = GetSetName("|H1:item:189051:364:50:0:0:0:0:0:0:0:0:0:0:0:1:136:0:1:0:10000:0|h|h"),
  ["abilityId"] = 176850, -- 176851 Remorseless Stack
  ["cooldown"] = 500,
  ["origin"] = EPT_ORIGIN_DUNGEON,
  ["icon"] = GetAbilityIcon(176851) -- remorseless
}

local phylacterysGrasp = { --665
  ["setName"] = GetSetName("|H1:item:189221:364:50:0:0:0:0:0:0:0:0:0:0:0:1:136:0:1:0:10000:0|h|h"),
  ["abilityId"] = 174996,
  ["cooldown"] = 10000,
  ["origin"] = EPT_ORIGIN_DUNGEON
}

local archdruidDevyric = { --666
  ["setName"] = GetSetName("|H1:item:189355:364:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h"),
  ["origin"] = EPT_ORIGIN_UNDAUNTED,
  ["cooldown"] = 15000,
  ["abilityId"] = 176813,
}

local euphoticGatekeeper = { --667
  ["setName"] = GetSetName("|H1:item:189408:364:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h"),
  ["origin"] = EPT_ORIGIN_UNDAUNTED,
  ["cooldown"] = 20000,
  ["abilityId"] = 176911, --177607
}

local alkosh = { --232
["setName"] = GetSetName("|H0:item:77690:370:50:0:0:0:0:0:0:0:0:0:0:0:0:45:0:0:0:0:0|h|h"),
["abilityId"] = 75753,
["cooldown"] = 0,
["origin"] = EPT_ORIGIN_TRIAL,
}


local pillarNirn = { --336
  ["setName"] = GetSetName("|H0:item:127541:364:50:0:0:0:11:0:0:0:0:0:0:0:2049:62:0:1:0:10000:0|h|h"),
  ["abilityId"] = 97714,--154184, --151152, --154179,
  ["cooldown"] = 10000,
  ["origin"] = EPT_ORIGIN_DUNGEON,
}


local maarselok = { --459
  ["setName"] = GetSetName("|H0:item:152312:363:50:0:0:0:11:0:0:0:0:0:0:0:2049:67:0:1:0:10000:0|h|h"), --lila
  ["abilityId"] = 126941,--154184, --151152, --154179,
  ["cooldown"] = 10000,
  ["origin"] = EPT_ORIGIN_UNDAUNTED,

}

----- new sets 

local aegisCaller = { --475
  ["setName"] = GetSetName("|H0:item:157747:364:50:0:0:0:11:0:0:0:0:0:0:0:2049:98:0:1:0:10000:0|h|h"),
  ["abilityId"] = 133493, 
  ["cooldown"] = 12000, 
  ["origin"] = EPT_ORIGIN_DUNGEON,
}


local flameBlossom = { --338 %blue robe
  ["setName"] = GetSetName("|H0:item:127950:362:50:0:0:0:11:0:0:0:0:0:0:0:2049:61:0:1:0:10000:0|h|h"),
  ["abilityId"] = 99144, 
  ["cooldown"] = 10000, 
  ["origin"] = EPT_ORIGIN_DUNGEON,
}


-- update 42 and addon version 2.12

local rallyingCry = { --629
["setName"] = GetSetName("|H0:item:183406:370:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
["abilityId"] = 166731, -- 166721, 166729, 166730, 166733, 168238
["origin"] = EPT_ORIGIN_PVP,
}

local duelistSilks = { -- 46
["setName"] = GetSetName("|H0:item:109850:362:50:0:0:0:11:0:0:0:0:0:0:0:2049:1:0:1:0:10000:0|h|h"),
["abilityId"] = 34373,
["origin"] = EPT_ORIGIN_DUNGEON,
["cooldown"] = 12000,
}

local sergeantMail = { -- 29
["setName"] = GetSetName("|H0:item:108749:362:50:0:0:0:11:0:0:0:0:0:0:0:2049:4:0:1:0:10000:0|h|h"),
["abilityId"] = 176055,
["origin"] = EPT_ORIGIN_DUNGEON,
["type"] = "stackself",
["maxstack"] = 4,
}

local ayleidRefuge = { -- 759
["setName"] = GetSetName("|H0:item:205258:364:50:0:0:0:0:0:0:0:0:0:0:0:1:147:0:1:0:10000:0|h|h"),
["abilityId"] = 219620,
["origin"] = EPT_ORIGIN_TRIAL,
["cooldown"] = 3000,
}

local highlandSentinel = { -- 764
["setName"] = GetSetName("|H0:item:205879:364:50:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:10000:0|h|h"),
["abilityId"] = 219681,
["origin"] = EPT_ORIGIN_CRAFTING,
["type"] = "stackself",
["maxstack"] = 10,
}

local tharrikerStriker = { -- 763
["setName"] = GetSetName("|H0:item:205514:364:50:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:10000:0|h|h"),
["abilityId"] = 219674,
["origin"] = EPT_ORIGIN_CRAFTING,
["cooldown"] = 4000, 
}

local tarnishedNightmare = { -- 736
["setName"] = GetSetName("|H0:item:202725:364:50:68343:370:50:18:0:0:0:0:0:0:0:2049:146:0:1:0:8950:0|h|h"),
["abilityId"] = 214520,
["origin"] = EPT_ORIGIN_DUNGEON,
["cooldown"] = 8000, 
["type"] = "timer", 
}

local hexosWard = { -- 614
["setName"] = GetSetName("|H0:item:180115:359:50:0:0:0:11:0:0:0:0:0:0:0:2049:114:0:1:0:10000:0|h|h"),
["abilityId"] = 163033,
["origin"] = EPT_ORIGIN_OVERLAND,
["cooldown"] = 7000, 
}

local arkasisGenius = { -- 518
["setName"] = GetSetName("|H0:item:165254:362:50:0:0:0:11:0:0:0:0:0:0:0:2049:107:0:1:0:10000:0|h|h"),
["abilityId"] = 142660,
["origin"] = EPT_ORIGIN_DUNGEON,
["cooldown"] = 30000, 
}


-- update 45 - Fallen Banners 
local vandorallensResonance = { -- 794
["setName"] = GetSetName("|H1:item:212659:364:50:0:0:0:0:0:0:0:0:0:0:0:1:153:0:1:0:10000:0|h|h"),
["abilityId"] = 235835,
["origin"] = EPT_ORIGIN_DUNGEON,
["cooldown"] = 6000,
}

local jerensisBladestorm = { -- 795
["setName"] = GetSetName("|H1:item:212826:364:50:0:0:0:0:0:0:0:0:0:0:0:1:153:0:1:0:10000:0|h|h"),
["abilityId"] = 235746,
["origin"] = EPT_ORIGIN_DUNGEON,
["cooldown"] = 15000,
}

local lucillasWindshield = { -- 796
["setName"] = GetSetName("|H1:item:212991:364:50:0:0:0:0:0:0:0:0:0:0:0:1:153:0:1:0:10000:0|h|h"),
["abilityId"] = 235885,
["origin"] = EPT_ORIGIN_DUNGEON,
["cooldown"] = 10000,
}

local fledglingsNest = { -- 799
["setName"] = GetSetName("|H1:item:213383:364:50:0:0:0:0:0:0:0:0:0:0:0:1:154:0:1:0:10000:0|h|h"),
["abilityId"] = 236355,
["origin"] = EPT_ORIGIN_DUNGEON,
["cooldown"] = 10000,
}

local noxiousBolder = { -- 800
["setName"] = GetSetName("|H1:item:213550:364:50:0:0:0:0:0:0:0:0:0:0:0:1:154:0:1:0:10000:0|h|h"),
["abilityId"] = 236745,
["origin"] = EPT_ORIGIN_DUNGEON,
["cooldown"] = 20000,
}

local orpheonTheTactician = { -- 801
["setName"] = GetSetName("|H1:item:213680:364:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h"),
["abilityId"] = 236654,
["origin"] = EPT_ORIGIN_DUNGEON,
["cooldown"] = 8000,
}

-- update 47 - Feast of Shadows
local stonehulkDomination = { -- 827
["setName"] = GetSetName("|H0:item:218884:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:159:0:0:0:10000:0|h|h"),
["abilityId"] = 248789,
["origin"] = EPT_ORIGIN_DUNGEON,
["cooldown"] = 15000,
["icon"] = GetItemLinkIcon("|H0:item:218884:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:159:0:0:0:10000:0|h|h"),
}

local huntsmansWarmask = { -- 845
["setName"] = GetSetName("|H1:item:223189:364:50:26582:370:50:0:0:0:0:0:0:0:0:1:0:0:1:0:7473:0|h|h"),
["abilityId"] = 252048,
["origin"] = EPT_ORIGIN_DUNGEON,
["cooldown"] = 60000,
}

local sentry = { --89
  ["setName"] = GetSetName("|H0:item:93904:364:50:0:0:0:11:0:0:0:0:0:0:0:2049:67:0:1:0:10000:0|h|h"),
  ["abilityId"] = 117391, -- Sentry
  ["origin"] = EPT_ORIGIN_PVP,
  ["cooldown"] = 30000,
}

local gorethief = { --855
  ["setName"] = GetSetName("|H0:item:93904:364:50:0:0:0:11:0:0:0:0:0:0:0:2049:67:0:1:0:10000:0|h|h"),
  ["abilityId"] = 260047, -- Sentry
  ["origin"] = EPT_ORIGIN_PVP,
  ["type"] = "stackself", 
  ["cooldown"] = 30000,
  ["maxstack"] = 10,
}
---------------------
-- RETURN FUNCTION --
---------------------

function EPT.GetSetList()
  return {
    [475] = aegisCaller, 
    [338] = flameBlossom,

    [459] = maarselok, 
    [232] = alkosh,--232
    [336] = pillarNirn,

    [660] = deeprootZeal, --660
    [661] = stonesAccord, --661
    [662] = rageOfTheUrsauk,
    [663] = pangritDenmother, --663
    [664] = graveInevitability, --664
    [665] = phylacterysGrasp, --665
    [666] = archdruidDevyric,
    [667] = euphoticGatekeeper,
    --Arena
    [562] = forceOverflow,
    [568] = forceOverflowPerfect,
    [561] = elementWrath,
    [567] = elementWrathPerfect,
    [558] = voidBash,
    [564] = voidBashPerfect,
    [317] = destructiveImpact,
    [532] = destructiveImpactPerfect,
    [217] = winterborn,

    --Undaunted
    [280] = grothdarr,
    [268] = sentinel,
    [167] = bogdan,
    [341] = earthgore,
    [274] = iceheart,
    [535] = ladyThorn,
    [271] = sellistrix,
    [276] = tremorscale,
    [577] = encratisBehemoth,
    [350] = zaan,
    [398] = vykosa,
    [609] = magmaIncarnate,
    [608] = priorThierric,
    [272] = infernalGuardian,
    [633] = nazaray,
    [632] = kargaeda,
    --Raids
    [391] = olo,
    [395] = oloPerf,
    [492] = wind,
    [493] = windPerf,
    [446] = yolnah,
    [451] = yolnahPerf,
    --[230] = moondancer,
    [496] = opportunist,
    [497] = opportunistPerf,
	  [494] = vrolNorm,
	  [495] = vrolPerf,
    [587] = bahseiMania,
    [591] = bahseiManiaPerf,
    [588] = stoneTalkerOath,
    [592] = stoneTalkerOathPerfect,
    [586] = sulXanTorment,
    [590] = sulXanTormentPerfect,
    [231] = lunarBastion,
    [390] = siroria,
    [394] = siroriaPerf,
    [137] = berserkingWarrior,

    ----Dungeon
    [343] = caluurion,
    [471] = hitis,
    [452] = hollowfang,
    [160] = burningSpellweave,
    [455] = zen,
    [431] = icyConjuror,
    [571] = drakesRush,
    [515] = crimsonTwilight,
    [347] = plagueSlinger,
    --[185] = spellPowerCure,
    [190] = scathingMage,
    [473] = banisTorment,
    [603] = scorionsFeast,
    [604] = rushOfAgony,
    [602] = crimsonOathRive,
    [606] = thunderCaller,
    [430] = tzogvinWarband,
    [570] = kinrasWrath,
    [622] = turningTide,
    [621] = glacialGuardian,
    [620] = gryphonsReprisal,
    [624] = spriggansVigor,
    [619] = maligaligsMaelstrom,

    ----Overland
    [49]  = redMountain,
    [212] = briarheart,
    [354] = madTinkerer,
    [487] = winter,
    [488] = venomousSmite,
    [147] = martialKnowledge,

    ----Crafting
    [353] = mechAcuity,
    [225] = cleverAlchemist,
    [74] = spectresEye,

    ----Cyrodiil/IC
    [180] = powerfulAssault,
    [181] = meritoriousService,
    [616] = darkConvergence,
    [618] = hrothgarsChill,
    [634] = nunatak,

    -- Mythic
    [501] = ThrassianStranglers,
    [594] = HarpoonerWadingKilt,
    [596] = DeathDealerFete,
    [627] = spaulderOfRuin,
    [521] = bloodlordsEmbrace,

    --highIsle
    [650] = perfectPillar,
    [649] = Pillar,
    [653] = perfWhorl,
    [646] = whorl,
    [657] = seaSerpent,

      -- gold road (addon 2.12)
    [629] = rallyingCry,
    [29] = sergeantMail ,
    [46] = duelistSilks ,
    [759] = ayleidRefuge, 
    [764] = highlandSentinel,
    [763] = tharrikerStriker,
    [736] = tarnishedNightmare,
    [614] = hexosWard,
    [518] = arkasisGenius,

    -- Fallen Banners 
    [794] = vandorallensResonance, 
    [795] = jerensisBladestorm, 
    [796] = lucillasWindshield, 
    [799] = fledglingsNest,
    [800] = noxiousBolder, 
    [801] = orpheonTheTactician, 
    -- Feast of Shadows
    [827] = stonehulkDomination,
    [845] = huntsmansWarmask,
    [89] = sentry,
    [855] = gorethief, 
    }

end

