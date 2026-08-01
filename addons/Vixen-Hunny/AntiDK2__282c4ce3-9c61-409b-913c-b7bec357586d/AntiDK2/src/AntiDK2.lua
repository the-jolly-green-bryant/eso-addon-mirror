AntiDK2 = AntiDK2 or {}
local ADK = AntiDK2

ADK.name        = "AntiDK2"
ADK.version     = "1.2"
ADK.displayName = "Anti DK 2.0"

-- Ability IDs
ADK.IDS = {
    POWER_LASH_EFFECT   = 34117,   -- Flame Lash: effect gained when DK has 5 stacks
    POWER_LASH          = 20824,   -- Power Lash: actual hit ability
    MOLTEN_WHIP         = 122658,
    MOLTEN_ATTACK        = 20805,
    SHATTERING_ROCKS    = 32678,
    WING_BUFFET         = 21007,
    FOSSILIZE           = 32685,
    SHIFTING_STANDARD   = 32958,
    CORROSIVE_ARMOR     = 17879,
}

-- Trans-pride colour palette { r, g, b, a }
ADK.COLORS = {
    LIGHT_BLUE  = { 0.36, 0.74, 0.98, 1    },   -- #5BCEFA
    PINK        = { 0.96, 0.66, 0.72, 1    },   -- #F5A9B8
    WHITE       = { 1,    1,    1,    1    },
    NAVY_BG     = { 0.04, 0.06, 0.14, 0.90 },
    NAVY_EDGE   = { 0.22, 0.28, 0.42, 0.95 },
    CORROSIVE   = { 0.44, 0.90, 0.18, 1    },   -- poison-green
    DANGER      = { 1.00, 0.18, 0.18, 1    },   -- bright red
    WARN        = { 1.00, 0.65, 0.10, 1    },   -- orange
    GREY        = { 0.55, 0.55, 0.60, 1    },
}

-- Default saved variables
ADK.defaults = {
    mainPanelX          = 20,
    mainPanelY          = 400,
    corrosivePopupX     =   0,
    corrosivePopupY     = -120,
    avoidPopupX         =   0,
    avoidPopupY         =  -40,
    trackCorrosive          = true,
    trackWings              = true,
    trackMoltenWhip         = true,
    trackPowerLash          = true,
    trackShatteringRocks    = true,
    trackFossilize          = true,
    trackShiftingStandard   = true,
    corrosiveFadeDelay  = 2.5,
    avoidFadeDelay      = 2.0,
    wingsCombatTimeout  = 8,
    -- Scale (stored as float, slider shows x10)
    mainPanelScale      = 1.0,
    corrosiveScale      = 1.0,
    avoidScale          = 1.0,
    -- Font presets
    corrosiveFontPreset = "Large",
    avoidFontPreset     = "Large",
}

-- Sub-namespace tables (populated by later files)
ADK.Combat              = {}
ADK.Combat.Events       = {}
ADK.UI                  = {}
ADK.Config              = {}