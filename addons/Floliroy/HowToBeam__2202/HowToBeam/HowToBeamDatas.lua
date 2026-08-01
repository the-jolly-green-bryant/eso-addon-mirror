HowToBeam = HowToBeam or {}
local HowToBeam = HowToBeam

HowToBeam.SkillNames = {
    STRING_PULSE_UNMORPHED = zo_strformat(SI_ABILITY_NAME, GetAbilityName(46340)),
    STRING_CRUSHING_SHOCK = zo_strformat(SI_ABILITY_NAME, GetAbilityName(46348)),
    STRING_FORCE_PULSE = zo_strformat(SI_ABILITY_NAME, GetAbilityName(46356)),
    STRING_ELEMENTAL_WEAPON = zo_strformat(SI_ABILITY_NAME, GetAbilityName(103571)),
    STRING_SWEEP_UNMORPHED = zo_strformat(SI_ABILITY_NAME, GetAbilityName(26114)),
    STRING_PUNCTURING_SWEEP = zo_strformat(SI_ABILITY_NAME, GetAbilityName(26797)),
    STRING_FLARE_UNMORPHED = zo_strformat(SI_ABILITY_NAME, GetAbilityName(22057)),
    STRING_DARK_FLARE = zo_strformat(SI_ABILITY_NAME, GetAbilityName(22110)),
    STRING_SUN_FIRE = zo_strformat(SI_ABILITY_NAME, GetAbilityName(21726)),
    STRING_VAMPIRE_BANE = zo_strformat(SI_ABILITY_NAME, GetAbilityName(21729)),
    STRING_REFLECTIVE_LIGHT = zo_strformat(SI_ABILITY_NAME, GetAbilityName(21732)),
    STRING_SOLAR_BARRAGE = zo_strformat(SI_ABILITY_NAME, GetAbilityName(22095)),
    STRING_ENTROPY = zo_strformat(SI_ABILITY_NAME, GetAbilityName(28567)),
    STRING_DEGENERATION = zo_strformat(SI_ABILITY_NAME, GetAbilityName(40457)),
    STRING_STRUCTURED_ENTROPY = zo_strformat(SI_ABILITY_NAME, GetAbilityName(40452)),
    STRING_SOUL_TRAP = zo_strformat(SI_ABILITY_NAME, GetAbilityName(26768)),
    STRING_SOUL_SPLIT_TRAP = zo_strformat(SI_ABILITY_NAME, GetAbilityName(40328)),
    STRING_CONSUMING_TRAP = zo_strformat(SI_ABILITY_NAME, GetAbilityName(40317)),
    STRING_FLAME_REACH = zo_strformat(SI_ABILITY_NAME, GetAbilityName(38944)),
    STRING_FLAME_TOUCH = zo_strformat(SI_ABILITY_NAME, GetAbilityName(29073)),
    STRING_SHOCK_REACH = zo_strformat(SI_ABILITY_NAME, GetAbilityName(38978)),
    STRING_SHOCK_TOUCH = zo_strformat(SI_ABILITY_NAME, GetAbilityName(29089)),
    STRING_SCALDING_RUNE = zo_strformat(SI_ABILITY_NAME, GetAbilityName(40465)),
    STRING_BACKLASH = zo_strformat(SI_ABILITY_NAME, GetAbilityName(21761)),
    STRING_PURIFYING_LIGHT = zo_strformat(SI_ABILITY_NAME, GetAbilityName(21765)),
    STRING_RITUAL_RETRIBUTION = zo_strformat(SI_ABILITY_NAME, GetAbilityName(22259)),
    STRING_NECROTIC_ORB = zo_strformat(SI_ABILITY_NAME, GetAbilityName(39298)),
    STRING_MYSTIC_ORB = zo_strformat(SI_ABILITY_NAME, GetAbilityName(42028)),
}

HowToBeam.Datas = {
    [HowToBeam.SkillNames.STRING_PULSE_UNMORPHED] = {
        icon = "|t50:50:esoui/art/icons/ability_destructionstaff_001.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --Fire hit
                fireBonus = true, singleTarget = true, directDmg = true, magicDmg = true},
            [2] = { --Two other hits
                fireBonus = false, singleTarget = true, directDmg = true, magicDmg = true},
            [3] = { --Burning
                fireBonus = true, singleTarget = true, directDmg = false, magicDmg = true},
            [4] = { --Concussion
                fireBonus = false, singleTarget = true, directDmg = false, magicDmg = true}
        },
        factor = {
            [1] = { --Fire hit
                magicka = 0.030952,
                spellDamage = 0.326035,
                additional = -2.48241,
                multiplier = 1,
            },
            [2] = { --Two other hits
                magicka = 0.030952,
                spellDamage = 0.326035,
                additional = -2.48241,
                multiplier = 2,
            },
            [3] = { --Burning
                magicka = 0.0167947210695167,
                spellDamage = 0.167947210695167,
                additional = 0,
                multiplier = 0.2 * 1.8,
            },
            [4] = { --Concussion
                magicka = 0.008743955967,
                spellDamage = 0.08743955967,
                additional = 0,
                multiplier = 0.2,
            }
        }
    },
    [HowToBeam.SkillNames.STRING_CRUSHING_SHOCK] = {
        icon = "|t50:50:esoui/art/icons/ability_destructionstaff_001a.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --Fire hit
                fireBonus = true, singleTarget = true, directDmg = true, magicDmg = true},
            [2] = { --Two other hits
                fireBonus = false, singleTarget = true, directDmg = true, magicDmg = true},
            [3] = { --Burning
                fireBonus = true, singleTarget = true, directDmg = false, magicDmg = true},
            [4] = { --Concussion
                fireBonus = false, singleTarget = true, directDmg = false, magicDmg = true}
        },
        factor = {
            [1] = { --Fire hit
                magicka = 0.0311231,
                spellDamage = 0.325181,
                additional = -2.70571,
                multiplier = 1,
            },
            [2] = { --Two other hits
                magicka = 0.0311231,
                spellDamage = 0.325181,
                additional = -2.70571,
                multiplier = 2,
            },
            [3] = { --Burning
                magicka = 0.0167947210695167,
                spellDamage = 0.167947210695167,
                additional = 0,
                multiplier = 0.2 * 1.8,
            },
            [4] = { --Concussion
                magicka = 0.008743955967,
                spellDamage = 0.08743955967,
                additional = 0,
                multiplier = 0.2,
            }
        }
    },
    [HowToBeam.SkillNames.STRING_FORCE_PULSE] = {
        icon = "|t50:50:esoui/art/icons/ability_destructionstaff_001b.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --Fire hit
                fireBonus = true, singleTarget = true, directDmg = true, magicDmg = true},
            [2] = { --Two other hits
                fireBonus = false, singleTarget = true, directDmg = true, magicDmg = true},
            [3] = { --Burning
                fireBonus = true, singleTarget = true, directDmg = false, magicDmg = true},
            [4] = { --Concussion
                fireBonus = false, singleTarget = true, directDmg = false, magicDmg = true}
        },
        factor = {
            [1] = { --Fire hit
                magicka = 0.0311231,
                spellDamage = 0.325181,
                additional = -2.70571,
                multiplier = 1,
            },
            [2] = { --Two other hits
                magicka = 0.0311231,
                spellDamage = 0.325181,
                additional = -2.70571,
                multiplier = 2,
            },
            [3] = { --Burning
                magicka = 0.0167947210695167,
                spellDamage = 0.167947210695167,
                additional = 0,
                multiplier = 0.2 * 1.8,
            },
            [4] = { --Concussion
                magicka = 0.008743955967,
                spellDamage = 0.08743955967,
                additional = 0,
                multiplier = 0.2,
            }
        }
    },
    [HowToBeam.SkillNames.STRING_ELEMENTAL_WEAPON] = {
        icon = "|t50:50:esoui/art/icons/ability_psijic_003_a.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --Initial Hit
                fireBonus = false, singleTarget = true, directDmg = true, magicDmg = true},
            [2] = { --Orb proc
                fireBonus = false, singleTarget = true, directDmg = true, magicDmg = true},
            [3] = { --Burning
                fireBonus = true, singleTarget = true, directDmg = false, magicDmg = true},
            [4] = { --Concussion
                fireBonus = false, singleTarget = true, directDmg = false, magicDmg = true}
        },
        factor = {
            [1] = { --Initial Hit
                magicka = 0.0961859,
                spellDamage = 1.00786,
                additional = -2.25832,
                multiplier = 1,
            },
            [2] = { --Orb proc
                magicka = 0.0499045,
                spellDamage = 0.525227,
                additional = -0.0810038,
                multiplier = 0.2,
            },
            [3] = { --Burning
                magicka = 0.0167947210695167,
                spellDamage = 0.167947210695167,
                additional = 0,
                multiplier = 1/3 * 1.8,
            },
            [4] = { --Concussion
                magicka = 0.008743955967,
                spellDamage = 0.08743955967,
                additional = 0,
                multiplier = 1/3,
            }
        }
    },
    [HowToBeam.SkillNames.STRING_SWEEP_UNMORPHED] = {
        icon = "|t50:50:esoui/art/icons/ability_templar_recovery.dds|t",
        castTime = 1.4, --find by doing some weaving and checking timers
        bonus = {
            [1] = { --Single target hit
                fireBonus = false, singleTarget = false, directDmg = true, magicDmg = true},
            [2] = { --Burning Light
                fireBonus = false, singleTarget = true, directDmg = true, magicDmg = true},
        },
        factor = {
            [1] = { --Single target hit
                magicka = 0.0376766,
                spellDamage = 0.3948,
                additional = -2.99351,
                multiplier = 4,
            },
            [2] = { --Burning Light
                magicka = 0.0599264,
                spellDamage = 0.630855,
                additional = -1.93596,
                multiplier = 1,
            },
        }
    },
    [HowToBeam.SkillNames.STRING_PUNCTURING_SWEEP] = {
        icon = "|t50:50:esoui/art/icons/ability_templar_reckless_attacks.dds|t",
        castTime = 1.4, --find by doing some weaving and checking timers
        bonus = {
            [1] = { --Single target hit
                fireBonus = false, singleTarget = false, directDmg = true, magicDmg = true},
            [2] = { --Burning Light
                fireBonus = false, singleTarget = true, directDmg = true, magicDmg = true},
        },
        factor = {
            [1] = { --Single target hit
                magicka = 0.0387447,
                spellDamage = 0.408309,
                additional = -1.10807,
                multiplier = 4,
            },
            [2] = { --Burning Light
                magicka = 0.0599264,
                spellDamage = 0.630855,
                additional = -1.93596,
                multiplier = 1,
            },
        }
    },
    [HowToBeam.SkillNames.STRING_FLARE_UNMORPHED] = {
        icon = "|t50:50:esoui/art/icons/ability_templar_solar_flare.dds|t",
        castTime = 1.4, --find by doing some weaving and checking timers
        bonus = {
            [1] = { --Initial hit
                fireBonus = false, singleTarget = true, directDmg = true, magicDmg = true},
            [2] = { --Empower LA
                empower = true  },
        },
        factor = {
            [1] = { --Initial hit
                magicka = 0.10693,
                spellDamage = 1.12254,
                additional = -1.70751,
                multiplier = 1,
            },
            [2] = { --Empower LA
                magicka = 0.0450994,
                spellDamage = 0.47178,
                additional = -1.08238,
                multiplier = 0.4,
            },
        }
    },
    [HowToBeam.SkillNames.STRING_DARK_FLARE] = {
        icon = "|t50:50:esoui/art/icons/ability_templar_dark_flare.dds|t",
        castTime = 1.4, --find by doing some weaving and checking timers
        bonus = {
            [1] = { --Initial hit
                fireBonus = false, singleTarget = true, directDmg = true, magicDmg = true},
            [2] = { --Empower LA
                empower = true  },
        },
        factor = {
            [1] = { --Initial hit
                magicka = 0.110526,
                spellDamage = 1.15976,
                additional = -3.07334,
                multiplier = 1,
            },
            [2] = { --Empower LA
                magicka = 0.0450994,
                spellDamage = 0.47178,
                additional = -1.08238,
                multiplier = 0.4,
            },
        }
    },
    [HowToBeam.SkillNames.STRING_SUN_FIRE] = {
        icon = "|t50:50:esoui/art/icons/ability_templar_sun_fire.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --First hit
                fireBonus = true, singleTarget = true, directDmg = true, magicDmg = true},
            [2] = { --DoT dmg
                fireBonus = true, singleTarget = true, directDmg = false, magicDmg = true},
            [3] = { --Burning
                fireBonus = true, singleTarget = true, directDmg = false, magicDmg = true},
        },
        factor = {
            [1] = { --First hit
                magicka = 0.0515967,
                spellDamage = 0.542336,
                additional = -0.486753,
                multiplier = 1,
            },
            [2] = { --DoT dmg
                magicka = 0.102629,
                spellDamage = 1.08944,
                additional = -11.2877,
                multiplier = 12/10,
            },
            [3] = { --Burning
                magicka = 0.0167947210695167,
                spellDamage = 0.167947210695167,
                additional = 0,
                multiplier = (6 * 0.06 + 0.2) * 1.4,
            },
        }
    },
    [HowToBeam.SkillNames.STRING_VAMPIRE_BANE] = {
        icon = "|t50:50:esoui/art/icons/ability_templar_vampire_bane.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --First hit
                fireBonus = true, singleTarget = true, directDmg = true, magicDmg = true},
            [2] = { --DoT dmg
                fireBonus = true, singleTarget = true, directDmg = false, magicDmg = true},
            [3] = { --Burning
                fireBonus = true, singleTarget = true, directDmg = false, magicDmg = true},
        },
        factor = {
            [1] = { --First hit
                magicka = 0.0516357,
                spellDamage = 0.542491,
                additional = -1.13233,
                multiplier = 1,
            },
            [2] = { --DoT dmg
                magicka = 0.149124,
                spellDamage = 1.57047,
                additional = -13.0852,
                multiplier = 16/14,
            },
            [3] = { --Burning
                magicka = 0.0167947210695167,
                spellDamage = 0.167947210695167,
                additional = 0,
                multiplier = (8 * 0.06 + 0.2) * 1.4,
            },
        }
    },
    [HowToBeam.SkillNames.STRING_REFLECTIVE_LIGHT] = {
        icon = "|t50:50:esoui/art/icons/ability_templar_reflective_light.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --First hit
                fireBonus = true, singleTarget = false, directDmg = true, magicDmg = true},
            [2] = { --DoT dmg
                fireBonus = true, singleTarget = true, directDmg = false, magicDmg = true},
            [3] = { --Burning
                fireBonus = true, singleTarget = true, directDmg = false, magicDmg = true},
        },
        factor = {
            [1] = { --First hit
                magicka = 0.0533034,
                spellDamage = 0.560425,
                additional = -1.06864,
                multiplier = 1,
            },
            [2] = { --DoT dmg
                magicka = 0.102927,
                spellDamage = 1.08692,
                additional = -6.71283,
                multiplier = 12/10,
            },
            [3] = { --Burning
                magicka = 0.0167947210695167,
                spellDamage = 0.167947210695167,
                additional = 0,
                multiplier = (6 * 0.06 + 0.2) * 1.4,
            },
        }
    },
    [HowToBeam.SkillNames.STRING_SOLAR_BARRAGE] = {
        icon = "|t50:50:esoui/art/icons/ability_templar_solar_power.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --Dot dmg
                fireBonus = false, singleTarget = false, directDmg = false, magicDmg = true},
            [2] = { --Empower LA
                empower = true  },
        },
        factor = {
            [1] = { --Dot dmg
                magicka = 0.0257059,
                spellDamage = 0.268463,
                additional = -1.98564,
                multiplier = 5,
            },
            [2] = { --Empower LA
                magicka = 0.0450994,
                spellDamage = 0.47178,
                additional = -1.08238,
                multiplier = 0.35 * 9,
            },
        }
    },
    [HowToBeam.SkillNames.STRING_ENTROPY] = {
        icon = "|t50:50:esoui/art/icons/ability_mageguild_004.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --Dot dmg
                fireBonus = false, singleTarget = true, directDmg = false, magicDmg = true},
            [2] = { --Empower LA
                empower = true  },
        },
        factor = {
            [1] = { --Dot dmg
                magicka = 0.153339,
                spellDamage = 1.62863,
                additional = 11.5496,
                multiplier = 1,
            },
            [2] = { --Empower LA
                magicka = 0.0450994,
                spellDamage = 0.47178,
                additional = -1.08238,
                multiplier = 0.4,
            },
        }
    },
    [HowToBeam.SkillNames.STRING_DEGENERATION] = {
        icon = "|t50:50:esoui/art/icons/ability_mageguild_004_a.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --Dot dmg
                fireBonus = false, singleTarget = true, directDmg = false, magicDmg = true},
            [2] = { --Empower LA
                empower = true  },
        },
        factor = {
            [1] = { --Dot dmg
                magicka = 0.155315,
                spellDamage = 1.62775,
                additional = -12.2864,
                multiplier = 1,
            },
            [2] = { --Empower LA
                magicka = 0.0450994,
                spellDamage = 0.47178,
                additional = -1.08238,
                multiplier = 0.4,
            },
        }
    },
    [HowToBeam.SkillNames.STRING_STRUCTURED_ENTROPY] = {
        icon = "|t50:50:esoui/art/icons/ability_mageguild_004_b.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --Dot dmg
                fireBonus = false, singleTarget = true, directDmg = false, magicDmg = true},
            [2] = { --Empower LA
                empower = true  },
        },
        factor = {
            [1] = { --Dot dmg
                magicka = 0.155315,
                spellDamage = 1.62775,
                additional = -12.2864,
                multiplier = 1,
            },
            [2] = { --Empower LA
                magicka = 0.0450994,
                spellDamage = 0.47178,
                additional = -1.08238,
                multiplier = 0.4,
            },
        }
    },
    [HowToBeam.SkillNames.STRING_SOUL_TRAP] = {
        icon = "|t50:50:esoui/art/icons/ability_otherclass_001.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --Dot dmg
                fireBonus = false, singleTarget = true, directDmg = false, magicDmg = true},
        },
        factor = {
            [1] = { --Dot dmg
                magicka = 0.153339,
                spellDamage = 1.62863,
                additional = 11.5496,
                multiplier = 1,
            },
        }
    },
    [HowToBeam.SkillNames.STRING_SOUL_SPLIT_TRAP] = {
        icon = "|t50:50:esoui/art/icons/ability_otherclass_001_a.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --Dot dmg
                fireBonus = false, singleTarget = true, directDmg = false, magicDmg = true},
        },
        factor = {
            [1] = { --Dot dmg
                magicka = 0.10248,
                spellDamage = 1.08832,
                additional = -1.90599,
                multiplier = 1,
            },
        }
    },
    [HowToBeam.SkillNames.STRING_CONSUMING_TRAP] = {
        icon = "|t50:50:esoui/art/icons/ability_otherclass_001_b.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --Dot dmg
                fireBonus = false, singleTarget = true, directDmg = false, magicDmg = true},
        },
        factor = {
            [1] = { --Dot dmg
                magicka = 0.155315,
                spellDamage = 1.62775,
                additional = -12.2864,
                multiplier = 1,
            },
        }
    },
    [HowToBeam.SkillNames.STRING_FLAME_REACH] = {
        icon = "|t50:50:esoui/art/icons/ability_destructionstaff_007_b.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --First hit
                fireBonus = true, singleTarget = true, directDmg = true, magicDmg = true},
            [2] = { --DoT dmg
                fireBonus = true, singleTarget = true, directDmg = false, magicDmg = true},
            [3] = { --Burning
                fireBonus = true, singleTarget = true, directDmg = false, magicDmg = true},
        },
        factor = {
            [1] = { --First hit
                magicka = 0.051699,
                spellDamage = 0.542319,
                additional = -1.63234,
                multiplier = 1,
            },
            [2] = { --DoT dmg
                magicka = 0.102927,
                spellDamage = 1.08692,
                additional = -6.71283,
                multiplier = 1,
            },
            [3] = { --Burning
                magicka = 0.0167947210695167,
                spellDamage = 0.167947210695167,
                additional = 0,
                multiplier = (5 * 0.06 + 0.2) * 1.4,
            },
        }
    },
    [HowToBeam.SkillNames.STRING_FLAME_TOUCH] = {
        icon = "|t50:50:esoui/art/icons/ability_destructionstaff_007.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --First hit
                fireBonus = true, singleTarget = true, directDmg = true, magicDmg = true},
            [2] = { --DoT dmg
                fireBonus = true, singleTarget = true, directDmg = false, magicDmg = true},
            [3] = { --Burning
                fireBonus = true, singleTarget = true, directDmg = false, magicDmg = true},
        },
        factor = {
            [1] = { --First hit
                magicka = 0.0515967,
                spellDamage = 0.542336,
                additional = -0.486753,
                multiplier = 1,
            },
            [2] = { --DoT dmg
                magicka = 0.102629,
                spellDamage = 1.08944,
                additional = -11.2877,
                multiplier = 1,
            },
            [3] = { --Burning
                magicka = 0.0167947210695167,
                spellDamage = 0.167947210695167,
                additional = 0,
                multiplier = (5 * 0.06 + 0.2) * 1.4,
            },
        }
    },
    [HowToBeam.SkillNames.STRING_SHOCK_REACH] = {
        icon = "|t50:50:esoui/art/icons/ability_destructionstaff_006_b.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --First hit
                fireBonus = false, singleTarget = true, directDmg = true, magicDmg = true},
            [2] = { --DoT dmg
                fireBonus = false, singleTarget = true, directDmg = false, magicDmg = true},
            [3] = { --Concussion
                fireBonus = false, singleTarget = true, directDmg = false, magicDmg = true},
        },
        factor = {
            [1] = { --First hit
                magicka = 0.051699,
                spellDamage = 0.542319,
                additional = -1.63234,
                multiplier = 1,
            },
            [2] = { --DoT dmg
                magicka = 0.102927,
                spellDamage = 1.08692,
                additional = -6.71283,
                multiplier = 1,
            },
            [3] = { --Concussion
                magicka = 0.008743955967,
                spellDamage = 0.08743955967,
                additional = 0,
                multiplier = 5 * 0.06 + 0.2,
            }
        }
    },
    [HowToBeam.SkillNames.STRING_SHOCK_TOUCH] = {
        icon = "|t50:50:esoui/art/icons/ability_destructionstaff_006.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --First hit
                fireBonus = false, singleTarget = true, directDmg = true, magicDmg = true},
            [2] = { --DoT dmg
                fireBonus = false, singleTarget = true, directDmg = false, magicDmg = true},
            [3] = { --Concussion
                fireBonus = false, singleTarget = true, directDmg = false, magicDmg = true},
        },
        factor = {
            [1] = { --First hit
                magicka = 0.0515967,
                spellDamage = 0.542336,
                additional = -0.486753,
                multiplier = 1,
            },
            [2] = { --DoT dmg
                magicka = 0.102629,
                spellDamage = 1.08944,
                additional = -11.2877,
                multiplier = 1,
            },
            [3] = { --Concussion
                magicka = 0.008743955967,
                spellDamage = 0.08743955967,
                additional = 0,
                multiplier = 5 * 0.06 + 0.2
            }
        }
    },
    [HowToBeam.SkillNames.STRING_SCALDING_RUNE] = {
        icon = "|t50:50:esoui/art/icons/ability_mageguild_001_b.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --First hit
                fireBonus = true, singleTarget = false, directDmg = true, magicDmg = true},
            [2] = { --DoT dmg
                fireBonus = true, singleTarget = true, directDmg = false, magicDmg = true},
            [3] = { --Burning
                fireBonus = true, singleTarget = true, directDmg = false, magicDmg = true},
        },
        factor = {
            [1] = { --First hit
                magicka = 0.103271,
                spellDamage = 1.08498,
                additional = -1.26467,
                multiplier = 1,
            },
            [2] = { --DoT dmg
                magicka = 0.0857575,
                spellDamage = 0.89239,
                additional = -7.5992,
                multiplier = 1,
            },
            [3] = { --Burning
                magicka = 0.0167947210695167,
                spellDamage = 0.167947210695167,
                additional = 0,
                multiplier = (7 * 0.02 + 0.1) * 1.4,
            }
        }
    },
    [HowToBeam.SkillNames.STRING_BACKLASH] = {
        icon = "|t50:50:esoui/art/icons/ability_templar_backlash.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --First hit
                fireBonus = false, singleTarget = true, directDmg = true, magicDmg = true},
            [2] = { --Proc dmg
                fireBonus = false, magicDmg = false},
        },
        factor = {
            [1] = { --First hit
                magicka = 0.0515967,
                spellDamage = 0.542336,
                additional = -0.486753,
                multiplier = 1,
            },
            [2] = { --Proc dmg
                magicka = 0.600001,
                spellDamage = -0.0002062,
                additional = 0.241221,
                multiplier = 1,
            }
        }
    },
    [HowToBeam.SkillNames.STRING_PURIFYING_LIGHT] = {
        icon = "|t50:50:esoui/art/icons/ability_templar_purifying_light.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --First hit
                fireBonus = false, singleTarget = true, directDmg = true, magicDmg = true},
            [2] = { --Proc dmg
                fireBonus = false, magicDmg = false},
        },
        factor = {
            [1] = { --First hit
                magicka = 0.0516357,
                spellDamage = 0.542491,
                additional = -1.13233,
                multiplier = 1,
            },
            [2] = { --Proc dmg
                magicka = 0.600001,
                spellDamage = -0.0002062,
                additional = 0.241221,
                multiplier = 1,
            }
        }
    },
    [HowToBeam.SkillNames.STRING_RITUAL_RETRIBUTION] = {
        icon = "|t50:50:esoui/art/icons/ability_templar_purifying_ritual.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --Dot dmg
                fireBonus = false, singleTarget = false, directDmg = false, magicDmg = true},
        },
        factor = {
            [1] = { --Dot dmg
                magicka = 0.0343092,
                spellDamage = 0.360258,
                additional = -2.11577,
                multiplier = 6,
            }
        }
    },
    [HowToBeam.SkillNames.STRING_NECROTIC_ORB] = {
        icon = "|t50:50:esoui/art/icons/ability_undaunted_004.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --Dot dmg
                fireBonus = false, singleTarget = false, directDmg = false, magicDmg = true},
        },
        factor = {
            [1] = { --Dot dmg
                magicka = 0.0163241,
                spellDamage = 0.174365,
                additional = -0.0448192,
                multiplier = 10,
            }
        }
    },
    [HowToBeam.SkillNames.STRING_MYSTIC_ORB] = {
        icon = "|t50:50:esoui/art/icons/ability_undaunted_004_a.dds|t",
        castTime = 1,
        bonus = {
            [1] = { --Dot dmg
                fireBonus = false, singleTarget = false, directDmg = false, magicDmg = true},
        },
        factor = {
            [1] = { --Dot dmg
                magicka = 0.0205939,
                spellDamage = 0.214642,
                additional = -1.72533,
                multiplier = 10,
            }
        }
    },
}