



HealerHelper.combatEventsToSkills = {
 -- combat              name                                        cast skill that started                  result which triggers this
 -- EventID
    [39073] =           {"Unstable Wall of Storms",                 39073,                                   {ACTION_RESULT_EFFECT_GAINED, }        },
    [39067] =           {"Unstable Wall of Frost",                  39067,                                   {ACTION_RESULT_EFFECT_GAINED, }        },

    [24328] =           {"Daedric Prey",                            24328,                                   {ACTION_RESULT_EFFECT_GAINED, }        },
    [88933] =           {"Volatile Familiar",                       77182,                                   {ACTION_RESULT_EFFECT_GAINED, }        },
    [23678] =           {"Critical Surge",                          23678,                                   {ACTION_RESULT_EFFECT_GAINED, }        },
    [23213] =           {"Boundless Storm",                         23213,                                   {ACTION_RESULT_EFFECT_GAINED, }        },
    [23231] =           {"Hurricane",                               23231,                                   {ACTION_RESULT_EFFECT_GAINED, }        },

    [24842] =           {"Daedric Tomb",                            24842,                                   {ACTION_RESULT_EFFECT_GAINED_DURATION,ACTION_RESULT_EFFECT_GAINED, }        },
    [42028] =           {"Mystic Orb",                              42028,                                   {ACTION_RESULT_EFFECT_GAINED, }        },
    [61506] =           {"Echoing Vigor",                           61505,                                   {ACTION_RESULT_EFFECT_GAINED, }        },

    [40382] =           {"Barbed Trap",                             40382,                                   {ACTION_RESULT_EFFECT_GAINED, }        },

    [40465] =           {"Scalding Rune",                           40465,                                   {ACTION_RESULT_EFFECT_GAINED_DURATION,ACTION_RESULT_EFFECT_GAINED, }        },
    [40242] =           {"Razor Caltrops",                          40242,                                   {ACTION_RESULT_EFFECT_GAINED, }     },



    [86027] =           {"Fetcher Infection",                       86027,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [86031] =           {"Growing Swarm",                           86031,                                   {ACTION_RESULT_EFFECT_GAINED, }     },


    [86169] =           {"Winter's Revenge",                        86169,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [90834] =           {"Arctic Blast",                            86156,                                   {ACTION_RESULT_EFFECT_GAINED, }     },


    [86003] =           {"Screaming Cliff Racer",                   86003,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [86015] =           {"Deep Fissure",                            86015,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [86019] =           {"Subterranean Assault",                    86019,                                   {ACTION_RESULT_EFFECT_GAINED, }     },


    [126371] =          {"Structured Entropy",                      40452,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [62787] =           {"Elemental Drain",                         39095,                                   {ACTION_RESULT_EFFECT_GAINED, }     },-- major breach specific to eledrain
    [62775] =           {"Elemental Susceptibility",                39089,                                   {ACTION_RESULT_EFFECT_GAINED, }     },-- major breach specific to ele sus
    [117749] =          {"Stalking Blastbones",                    117749,                                   {ACTION_RESULT_EFFECT_GAINED, }     },

    [117637] =          {"Ricochet Skull",                         117637,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [123719] =          {"Ricochet Skull",                         117637,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [123718] =          {"Ricochet Skull",                         117637,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [117805] =          {"Unnerving Boneyard",                     117805,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [117850] =          {"Avid Boneyard",                          117850,                                   {ACTION_RESULT_EFFECT_GAINED, }     },


    [118726] =          {"Skeletal Arcanist",                      118726,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [118680] =          {"Skeletal Archer",                        118680,                                   {ACTION_RESULT_EFFECT_GAINED, }     },

    [118912] =          {"Spirit Guardian",                        118912,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [117883] =          {"Resistant Flesh",                        117883,                                   {ACTION_RESULT_CRITICAL_HEAL,ACTION_RESULT_HEAL }     },


    [20252] =           {"Burning Talons",                          20252,                                   {ACTION_RESULT_DAMAGE,ACTION_RESULT_CRITICAL_DAMAGE, }     }, -- required damage to detect
    [20805] =           {"Molten Whip",                             20805,                                   {ACTION_RESULT_DAMAGE,ACTION_RESULT_CRITICAL_DAMAGE, }     },
    [32722] =           {"Coagulating Blood",                       32722,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [32853] =           {"Flames of Oblivion",                      32853,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [20668] =           {"Venomous Claw",                           20668,                                   {ACTION_RESULT_DAMAGE,ACTION_RESULT_CRITICAL_DAMAGE, }     },
    [20930] =           {"Engulfing Flames",                        20930,                                   {ACTION_RESULT_DAMAGE,ACTION_RESULT_CRITICAL_DAMAGE, }     },
    [32792] =           {"Deep Breath",                             32792,                                   {ACTION_RESULT_DAMAGE,ACTION_RESULT_CRITICAL_DAMAGE, }     },
    [32710] =           {"Eruption",                                32710,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [76518] =           {"Igneous Weapons",                         31874,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
   [143806] =           {"Crystal Weapon",                          46331,                                   {ACTION_RESULT_EFFECT_GAINED, }     },

    [77354] =           {"Twilight Tormentor Enrage",               77140,                                   {ACTION_RESULT_EFFECT_GAINED, }     },

    [36049] =           {"Twisting Path",                           36049,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [25267] =           {"Concealed Weapon",                        25267,                                   {ACTION_RESULT_DAMAGE,ACTION_RESULT_CRITICAL_DAMAGE, }     },
    [34851] =           {"Impale",                                  34851,                                   {ACTION_RESULT_DAMAGE,ACTION_RESULT_CRITICAL_DAMAGE, }     },
    [34835] =           {"Swallow Soul",                            34835,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [61919] =           {"Merciless Resolve",                       61919,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [61930] =           {"Assassin's Will",                         61930,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [35434] =           {"Dark Shade",                              35434,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [36943] =           {"Debilitate",                              36943,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [36967] =           {"Reaper's Mark",                           36967,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [35336] =           {"Lotus Fan",                               25493,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [45655] =           {"Sap Essence",                             36891,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [46356] =           {"Force Pulse",                             46356,                                   {ACTION_RESULT_EFFECT_GAINED, }     },


    [63046] =           {"Radiant Oppression",                      63046,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [22256] =           {"Breath of Life",                          22256,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [26869] =           {"Blazing Spear",                           26869,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [22262] =           {"Extended Ritual",                         22262,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [21765] =           {"Purifying Light",                         21765,                                   {ACTION_RESULT_EFFECT_GAINED, }     },

    [21763] =           {"Power of the Light",                      21763,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [22259] =           {"Ritual of Retribution",                   22259,                                   {ACTION_RESULT_EFFECT_GAINED, }     },

    [21729] =           {"Vampire's Bane",                          21729,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [22095] =           {"Solar Barrage",                           22095,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [26797] =           {"Puncturing Sweep",                        26797,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [85862] =           {"Enchanted Growth",                        85862,                                   {ACTION_RESULT_HEAL,ACTION_RESULT_CRITICAL_HEAL, }     },

   [118763] =           {"Detonating Siphon",                      118763,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [88758] =           {"Expansive Frost Cloak",                   86126,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [88761] =           {"Ice Fortress",                            86130,                                   {ACTION_RESULT_EFFECT_GAINED, }     },



   [85840] =            {"Budding Seeds",                           85840,                                   {ACTION_RESULT_EFFECT_GAINED, }     },

   [40094] =            {"Combat Prayer",                           40094,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
   [40060] =            {"Healing Springs",                         40060,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
   [40058] =            {"Illustrious Healing",                     40058,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
   [85862] =            {"Enchanted Growth",                        85862,                                   {ACTION_RESULT_HEAL,ACTION_RESULT_CRITICAL_HEAL,  }     },

   [86054] =            {"Blue Betty",                              86054,                                   {ACTION_RESULT_EFFECT_GAINED,  }     },

   [40079] =            {"Radiating Regeneration",                  40079,                                   {ACTION_RESULT_EFFECT_GAINED,  }     },

   [42176] =            {"Bone Surge",                              42176,                                   {ACTION_RESULT_EFFECT_GAINED,  }     },
   [41958] =            {"Overflowing Altar",                       41958,                                   {ACTION_RESULT_EFFECT_GAINED,  }     },
   [42038] =            {"Energy Orb",                              42038,                                   {ACTION_RESULT_EFFECT_GAINED  }     },
   [34838] =            {"Funnel Health",                           34838,                                   {ACTION_RESULT_EFFECT_GAINED  }     },
   [36028] =            {"Refreshing Path",                         36028,                                   {ACTION_RESULT_EFFECT_GAINED  }     },

   [33524] =            {"Channeled Focus",                         22240,                                   {ACTION_RESULT_EFFECT_GAINED  }     },
   [26858] =            {"Luminous Shards",                         26858,                                   {ACTION_RESULT_EFFECT_GAINED  }     },
  [118070] =            {"Braided Tether",                         118070,                                   {ACTION_RESULT_EFFECT_GAINED  }     },

  [118405] =            {"Agony Totem",                            118404,                                   {ACTION_RESULT_EFFECT_GAINED  }     },

  [156567] =            {"Liquid Lightning",                        23200,                                   {ACTION_RESULT_EFFECT_GAINED  }     },
  [23674] =             {"Power Surge",                             23674,                                   {ACTION_RESULT_EFFECT_GAINED  }     },
  [24589] =             {"Dark Conversion",                         24589,                                   {ACTION_RESULT_BEGIN  }     },
  [40170] =             {"Ring of Preservation",                    40169,                                   {ACTION_RESULT_EFFECT_GAINED  }     },
  [183267] =            {"Rune of the Colorless Pool",             183267,                                   {ACTION_RESULT_EFFECT_GAINED  }     },
  [186229] =            {"Zenas' Empowering Disc",                 186229,                                   {ACTION_RESULT_EFFECT_GAINED  }     },
  [186234] =            {"Reconstructive Domain",                  186234,                                   {ACTION_RESULT_EFFECT_GAINED  }     },
  [31874] =             {"Igneous Weapons",                         31874,                                   {ACTION_RESULT_EFFECT_GAINED  }     },
  [29482] =             {"Regenerative Ward",                       29482,                                   {ACTION_RESULT_EFFECT_GAINED  }     },



}



HealerHelper.combatEventsToAdjustSkillCastTimes = {
    -- combat   name                           cast skill
    -- EventID  skill                          needs to be adjusted
    [62636] = { "Combat Prayer",               40094 }, -- resto staff

    [88758] = { "Expansive Frost Cloak",       86126 }, -- warden
    [89107] = { "Blue Betty",                  86054 }, -- warden
    [86300] = { "Enchanted Growth",            85862 }, -- warden

    [177304] = { "Radiant Aura",               26807 }, -- templar

    [77418] =  { "Regenerative Ward",          29482 }, -- sorc
}
