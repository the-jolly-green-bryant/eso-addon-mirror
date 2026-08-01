
-- remap some skills to their main variant
HealerHelper.remapSkillId = {
    [130291] = 24165, -- bound armaments
    [23316] = 77182, -- dps familiar
    [123719] = 117637, -- Ricochet Skull
    [123718] = 117637, -- Ricochet Skull
    [85922] = 85840, -- Budding Seeds
}


HealerHelper.skillProperties = {
    --              [1]                           [2]         [3]         [4]           [5]         [6]             [7]         [8]        [9]
    --  SkillId     Name                       castSec    castHp%   CombatEvent     Ultimate
    --                                        0.0=spam     player   Triggered      Required
    --                                      -1.0=never      HP% <
    [77182] = {"Volatile Familiar",           20.0,       100,      true,             0,         false,               0,        100,     false, },
    [23316] = {"Summon Volatile Familiar",     0.0,       100,     false,             0,         false,               0,        100,     false, },

    [39073] = {"Unstable Wall of Storms",     10.0,       100,      true,             0,         false,               0,        100,     false, },
    [39067] = {"Unstable Wall of Frost",      10.0,       100,      true,             0,         false,               0,        100,     false, },




    [23213] = {"Boundless Storm",             30.0,       100,      true,             0,         false,               0,        100,     false, },
    [23231] = {"Hurricane",                   20.0,       100,      true,             0,         false,               0,        100,     false, },


    [24842] = {"Daedric Tomb",                15.0,       100,      true,             0,         false,               0,        100,     false, },
    [42028] = {"Mystic Orb",                  10.0,       100,      true,             0,         false,               0,        100,     false, },

    [46324] = {"Crystal Fragments",            0.0,       100,      false,            0,         false,               0,        100,     false, },
    [114716] = {"Crystal Fragments(proc)",      0.0,       100,      false,            0,        false,               0,        100,     false, },
    [24328] = {"Daedric Prey",                 6.1,       100,      true,             0,         false,               0,        100,     false, },
    [23678] = {"Critical Surge",              33.0,       100,      true,             0,         false,               0,        100,     false, },

    [40382] = {"Barbed Trap",                 20.0,       100,      true,             0,         false,               0,        100,     false, },

    [77369] = {"Matriarch Restore",           -1.0,        75,      false,            0,         false,               0,        100,     false, },
    [24639] = {"Summon Matriarch Restore",     0.0,       100,      false,            0,         false,               0,        100,     false, },

    [77140] = {"Twilight Tormentor Enrage",   20.0,       100,       true,            0,         false,               0,        100,     false, },
    [24636] = {"Summon Twilight Tormentor",    0.0,       100,      false,            0,         false,               0,        100,     false, },

    [23678] = {"Critical Surge",              33.0,       100,       true,            0,         false,               0,        100,     false, },
    [61505] = {"Echoing Vigor",               15.0,       100,       true,            0,         false,               0,        100,     false, },
    [40465] = {"Scalding Rune",               24.0,       100,       true,            0,         false,               0,        100,     false, },
    [40242] = {"Razor Caltrops",              10.0,       100,       true,            0,         false,               0,        100,     false, },

    [86027] = {"Fetcher Infection",           20.0,       100,       true,            0,         false,               0,        100,     false, },
    [86031] = {"Growing Swarm",               20.0,       100,       true,            0,         false,               0,        100,     false, },


    [86169] = {"Winter's Revenge",            12.0,       100,       true,            0,         false,               0,        100,     false, },
    [86156] = {"Arctic Blast",                20.0,       100,       true,            0,         false,               0,        100,     false, },

    [86003] = {"Screaming Cliff Racer",        0.0,       100,       true,            0,         false,               0,        100,     false, },
    [86015] = {"Deep Fissure",                 9.0,       100,       true,            0,         false,               0,        100,     false, },
    [86019] = {"Subterranean Assault",         6.0,       100,       true,            0,         false,               0,        100,     false, },



    [40452] = {"Structured Entropy",          24.0,       100,       true,            0,         false,               0,        100,     false, },
    [39095] = {"Elemental Drain",             60.0,       100,       true,            0,         false,               0,        100,     false, },
    [39089] = {"Elemental Susceptibility",    30.0,       100,       true,            0,         false,               0,        100,     false, },
    [117749] = {"Stalking Blastbones",          0.0,       100,       true,            0,         false,               0,        100,     false, },
    [117637] = {"Ricochet Skull",               0.0,       100,       true,            0,         false,               0,        100,     false, },

    [117805] = {"Unnerving Boneyard",          10.0,       100,       true,            0,         false,               0,        100,     false, },
    [117850] = {"Avid Boneyard",               10.0,       100,       true,            0,         false,               0,        100,     false, },
    [117883] = {"Resistant Flesh",             -1.0,        75,       true,            0,         false,               0,        100,     false, },

    [118726] = {"Skeletal Arcanist",           20.0,       100,       true,            0,         false,               0,        100,     false, },
    [118680] = {"Skeletal Archer",             20.0,       100,       true,            0,         false,               0,        100,     false, },
    [118912] = {"Spirit Guardian",             16.0,       100,       true,            0,         false,               0,        100,     false, },

    [118763] = {"Detonating Siphon",            20,        100,       true,            0,         false,               0,        100,     false, },

    [20252] = {"Burning Talons",               4.0,       100,       true,            0,         false,               0,        100,     false, },
    [20805] = {"Molten Whip",                  0.0,       100,       true,            0,         false,               0,        100,     false, },
    [32722] = {"Coagulating Blood",           -1.0,        65,       true,            0,         false,               0,        100,     false, },
    [32853] = {"Flames of Oblivion",            15,       100,       true,            0,         false,               0,        100,     false, },
    [20668] = {"Venomous Claw",                 24,       100,       true,            0,         false,               0,        100,     false, },
    [20930] = {"Engulfing Flames",              24,       100,       true,            0,         false,               0,        100,     false, },
    [32792] = {"Deep Breath",                    4,       100,       true,            0,         false,               0,        100,     false, },
    [32710] = {"Eruption",                      18,       100,       true,            0,         false,               0,        100,     false, },
    [31874] = {"Igneous Weapons",               72,       100,       true,            0,         false,               0,        100,     false, },

    [46331] = {"Crystal Weapon",                 6,       100,       true,            0,         false,               0,        100,     false, },

    [24163] = {"Bound Aegis",                   20,        90,       true,             0,         false,              0,        100,     false, },

    [36049] = {"Twisting Path",                 12,       100,       true,            0,         false,               0,        100,     false, },
    [25267] = {"Concealed Weapon",               0,       100,       true,            0,         false,               0,        100,     false, },
    [34851] = {"Impale",                         0,       100,       true,            0,         false,               0,        100,     false, },
    [34835] = {"Swallow Soul",                   0,       100,       true,            0,         false,               0,        100,     false, },
    [61919] = {"Merciless Resolve",             40,       100,       true,            0,         false,               0,        100,     false, },
    [61930] = {"Assassin's Will",                0,       100,       true,            0,         false,               0,        100,     false, },
    [35434] = {"Dark Shade",                    22,       100,       true,            0,         false,               0,        100,     false, },
    [36943] = {"Debilitate",                    20,       100,       true,            0,         false,               0,        100,     false, },
    [36967] = {"Reaper's Mark",                 20,       100,       true,            0,         false,               0,        100,     false, },
    [25493] = {"Lotus Fan",                     10,       100,       true,            0,         false,               0,        100,     false, },
    [36891] = {"Sap Essence",                    0,       100,       true,            0,         false,               0,        100,     false, },
    [46356] = {"Force Pulse",                    0,       100,       true,            0,         false,               0,        100,     false, },

    [85862] = {"Enchanted Growth",            -1.0,        75,       true,            0,         false,               0,        100,     false, },

    [63046] = {"Radiant Oppression",             0,       100,       true,            0,         false,               0,        100,     false, },
    [22256] = {"Breath of Life",                -1,        75,       true,            0,         false,               0,        100,     false, },
    [26869] = {"Blazing Spear",                 10,       100,       true,            0,         false,               0,        100,     false, },
    [22262] = {"Extended Ritual",               30,       100,       true,            0,         false,               0,        100,     false, },
    [21765] = {"Purifying Light",                6,       100,       true,            0,         false,               0,        100,     false, },
    [21763] = {"Power of the Light",             6,       100,       true,            0,         false,               0,        100,     false, },
    [22259] = {"Ritual of Retribution",         20,       100,       true,            0,         false,               0,        100,     false, },

    [21729] = {"Vampire's Bane",                32,       100,       true,            0,         false,               0,        100,     false, },
    [22095] = {"Solar Barrage",                 22,       100,       true,            0,         false,               0,        100,     false, },
    [26797] = {"Puncturing Sweep",               0,       100,       true,            0,         false,               0,        100,     false, },

    [86126] = {"Expansive Frost Cloak",         20,       100,       true,            0,         false,               0,        100,     false, },

    [85840] = {"Budding Seeds",                  6,       100,       true,            0,         false,               0,        100,     false, },
    [40094] = {"Combat Prayer",                 10,       100,       true,            0,         false,               0,        100,     false, },
    [40060] = {"Healing Springs",               10,       100,       true,            0,         false,               0,        100,     false, },
    [40058] = {"Illustrious Healing",           15,       100,       true,            0,         false,               0,        100,     false, },

    [85862] = {"Enchanted Growth",              20,       100,       true,            0,         false,               0,        100,     false, },
    [86054] = {"Blue Betty",                    25,       100,       true,            0,         false,               0,        100,     false, },

    [40079] = {"Radiating Regeneration",        10,       100,       true,            0,         false,               0,        100,     false, },

    [42176] = {"Bone Surge",                     6,       100,       true,            0,         false,               0,        100,     false, },
    [41958] = {"Overflowing Altar",             30,       100,       true,            0,         false,               0,        100,     false, },
    [42038] = {"Energy Orb",                    10,       100,       true,            0,         false,               0,        100,     false, },
    [34838] = {"Funnel Health",                 10,       100,       true,            0,         false,               0,        100,     false,  },
    [36028] = {"Refreshing Path",               12,       100,       true,            0,         false,               0,        100,     false,  },

    [26807] = {"Radiant Aura",                  60,       100,      false,            0,         false,               0,        100,     false,  },
    [22240] = {"Channeled Focus",               60,       100,       true,            0,         false,               0,        100,     false,  },
    [26858] = {"Luminous Shards",               10,       100,       true,            0,         false,               0,        100,     false,  },
    [118070] = {"Braided Tether",                12,       100,       true,            0,         false,               0,        100,     false,  },
    [118404] = {"Agony Totem",                   13,       100,       true,            0,         false,               0,        100,     false,  },

    [23200] = {"Liquid Lightning",               15,       100,       true,            0,         false,               0,        100,     false,  },
    [23674] = {"Power Surge",                    33,       100,       true,            0,         false,               0,        100,     false,  },

    [24589] = {"Dark Conversion",                -1,       100,       true,            0,         false,               0,        100,     false,  },
    [86130] = {"Ice Fortress",                   30,       100,       true,            0,         false,               0,        100,     false,  },
    [40169] = {"Ring of Preservation",           10,       100,       true,            0,         false,               0,        100,     false,  },
    [183267] = {"Rune of the Colorless Pool",    20,       100,       true,            0,         false,               0,        100,     false,  },
    [186229] = {"Zenas' Empowering Disc",        20,       100,       true,            0,         false,               0,        100,     false,  },
    [186234] = {"Reconstructive Domain",         20,       100,       true,            0,         false,               0,        100,     false,  },

    [29482]= {"Regenerative Ward",         10,       100,       true,            0,         false,               0,        100,     false,  },

    [31874] = {"Igneous Weapons",                72,       100,       true,            0,         false,               0,        100,     false,  },
--[18:05] ({"name":"Igneous Weapons", "id":31874})

    -- ULTIMATES
    [23495] = {"Summon Charged Atronach",     -1.0,       100,      false,          170,         false,               0,        100,     false, },
    [23492] = {"Greater Storm Atronach",      -1.0,       100,      false,          170,         false,               0,        100,     false, },
    [85130] = {"Thunderous Rage",             -1.0,       100,      false,          250,         false,               0,        100,     false, },
    [24806] = {"Power Overload",              -1.0,       100,      false,           21,         false,               0,        100,     false, },
    [40493] = {"Shooting Star",               -1.0,       100,      false,          200,         false,               0,        100,     false, },
    [40223] = {"Aggressive Horn",             -1.0,       100,      false,          250,         false,               0,        100,     false, },
    [40237] = {"Reviving Barrier",            -1.0,       100,      false,          250,         false,               0,        100,     false, },
   [122395] = {"Pestilent Colossus",          -1.0,       100,      false,          175,         false,               0,        100,     false, },
   [118379] = {"Animate Blastbones",          -1.0,       100,      false,          320,         false,               0,        100,     false, },
    [32947] = {"Standard of Might",           -1.0,       100,      false,          250,         false,               0,        100,     false, },
   [113105] = {"Incapacitating Strike",       -1.0,       100,      false,           70,         false,               0,        100,     false, },
    [36508] = {"Incapacitating Strike",       -1.0,       100,      false,           70,         false,               0,        100,     false, },
    [36514] = {"Soul Harvest",                -1.0,       100,      false,           70,         false,               0,        100,     false, },
    [85807] = {"Healing Thicket",             -1.0,       100,      false,           90,         false,               0,        100,     false, },
    [85126] = {"Fiery Rage",                  -1.0,       100,      false,          250,         false,               0,        100,     false, },

}
--/script d(GetAbilityCost(85807))
--/script d(GetAbilityCost(36514))

function HealerHelper.updateUltimateCosts()

 for k, v in pairs(HealerHelper.skillProperties ) do
    if v[5]>0 then -- check if skill has an ultimate cost
        local newUltimateValue = GetAbilityCost(k)
        if v[5]~=newUltimateValue and newUltimateValue>0 then
            --d("Update ultimate cost for "..v[1].." to "..newUltimateValue)
            v[5]=newUltimateValue
        end
    end
 end
end