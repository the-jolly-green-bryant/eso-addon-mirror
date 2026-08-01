MU.Data = {}

D = MU.Data

D.positioningTable = {
    [1] = {
        [0] = {
            x = 0,
            y = 10
        }
    },
    [2] = {
        [0] = {
            x = -20,
            y = 10
        },
        [1] = {
            x = 20,
            y = 10
        }
    },
    [3] = {
        [0] = {
            x = -40,
            y = 10
        },
        [1] = {
            x = 0,
            y = 10
        },
        [2] = {
            x = 40,
            y = 10
        }
    },
    [4] = {
        [0] = {
            x = -40,
            y = 10
        },
        [1] = {
            x = 0,
            y = 10
        },
        [2] = {
            x = 40,
            y = 10
        },
        [3] = {
            x = 0,
            y = -20
        }
    },
    [5] = {
        [0] = {
            x = -40,
            y = 10
        },
        [1] = {
            x = 0,
            y = 10
        },
        [2] = {
            x = 40,
            y = 10
        },
        [3] = {
            x = -20,
            y = -20
        },
        [4] = {
            x = 20,
            y = -20
        }
    }
}

function D.BuildAbilities()
    -- This table stores pretty much all the informations the Addon needs
    return {
        [1] = { abilityID = 38541,  name = "Taunt",                 shortcode = "0",      enabled = MU.SV.taunt,                  color = "",     debuffType = 0, ignoreDebuff = false  },
        [2] = { abilityID = 31104,  name = "Engulfing",             shortcode = "EN",       enabled = MU.SV.engulfing,              color = "",     debuffType = 1, ignoreDebuff = false  },
        [3] = { abilityID = 75753,  name = "Alkosh",                shortcode = "AL",       enabled = MU.SV.alkosh,                 color = "",     debuffType = 1, ignoreDebuff = false  },
        [4] = { abilityID = 17906,  name = "Crusher",               shortcode = "CR",       enabled = MU.SV.crusher,                color = "",     debuffType = 1, ignoreDebuff = false  },
        [5] = { abilityID = 62484,  name = "MajorFracture",         shortcode = "MF",       enabled = MU.SV.majorfracture,          color = "",     debuffType = 2, ignoreDebuff = false  },
        [6] = { abilityID = 62484,  name = "MajorFracture",         shortcode = "MF",       enabled = MU.SV.majorfracture,          color = "",     debuffType = 2, ignoreDebuff = true  },
        [7] = { abilityID = 64144,  name = "MinorFracture",         shortcode = "mF",       enabled = MU.SV.minorfracture,          color = "",     debuffType = 3, ignoreDebuff = false  },
        [8] = { abilityID = 52788,  name = "Immune",                shortcode = "0.0",      enabled = MU.SV.immune,                 color = "",     debuffType = 0, ignoreDebuff = true  },
        [9] = { abilityID = 68359,  name = "MinorVulnerability",    shortcode = "mV",       enabled = MU.SV.minorvulnerability,     color = "",     debuffType = 3, ignoreDebuff = false  },
        [10] = { abilityID = 81519,  name = "MinorVulnerability",    shortcode = "mV",       enabled = MU.SV.minorvulnerability,     color = "",     debuffType = 3, ignoreDebuff = true  }, --probably aether set debuff
        [11] = { abilityID = 62787,  name = "MajorBreach",           shortcode = "MB",       enabled = MU.SV.majorbreach,            color = "",     debuffType = 2, ignoreDebuff = false  },
        [12] = { abilityID = 62485,  name = "MajorBreach",           shortcode = "MB",       enabled = MU.SV.majorbreach,            color = "",     debuffType = 2, ignoreDebuff = true  }, --melee taunt
        [13] = { abilityID = 108951,  name = "MajorBreach",           shortcode = "MB",       enabled = MU.SV.majorbreach,            color = "",     debuffType = 2, ignoreDebuff = true  }, --deep fissure
        [14] = { abilityID = 68588,  name = "MinorBreach",           shortcode = "mB",       enabled = MU.SV.minorbreach,            color = "",     debuffType = 3, ignoreDebuff = false  },
        [15] = { abilityID = 39100,  name = "MinorMagickaSteal",     shortcode = "mM",       enabled = MU.SV.minormagickasteal,      color = "",     debuffType = 3, ignoreDebuff = false  },
        [16] = { abilityID = 26220,  name = "MinorMagickaSteal",     shortcode = "mM",       enabled = MU.SV.minormagickasteal,      color = "",     debuffType = 3, ignoreDebuff = true  },
        [17] = { abilityID = 17945,  name = "Weakening",     shortcode = "WK",       enabled = MU.SV.weakening,      color = "",     debuffType = 1, ignoreDebuff = false  }
    }
    --[[
        Debuff Types:
        0 - Will be ignored
        1 - Debuffs that do not have different variants (like Alkosh or Engulfing)
        2 - Major Debuffs
        3 - Minor Debuffs
    ]]--
end