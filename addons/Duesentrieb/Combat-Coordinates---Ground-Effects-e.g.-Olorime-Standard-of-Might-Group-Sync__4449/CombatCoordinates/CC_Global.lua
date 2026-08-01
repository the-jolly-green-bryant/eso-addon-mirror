---------------------------------------------------------------------------
-- GLOBAL NAMESPACE AND DEFAULTS
---------------------------------------------------------------------------
CombatCoordinates = {
    name = "CombatCoordinates",
    author = "@Duesentrieb",
    version = "20260314-0001",
    chat = "|cFF7F00[CC]|r",

    isLoaded = false,
    isConsole = false,

    PARENT = nil,
    segmentPool = {},
    trackedVisuals = {},
    cooldowns = {},
    protocol = nil,

    -- SUPPORTED SKILLS TABLE
    -- 32947 = STANDARD OF MIGHT
    supportedSkills = {
        [32947] = {
            duration = 15000,
            name = "Standard of Might"
        }
    },

    default = {
        enableAddon = true,
        debugMode = false,

        -- STANDARD OF MIGHT SETTINGS
        standardRadius = 800,
        standardOffset = 150,
        standardHeightOffset = 5,
        standardNumSides = 16,
        standardLineWidth = 0.25,
        standardColorSelf = {0, 1, 0, 1},
        standardColorGroup = {0, 0.5, 1, 1},
    },

    SV = {},
    SVVersion = 1,
    SVName = "CombatCoordinatesVariables",
}