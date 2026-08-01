TimeToKill = {
    name = "TimeToKill",
    author = "@Duesentrieb",
    version = "20260518-0001",
    chat = "|cFF7F00[TTK]|r",

    -- UI ELEMENTS
    PARENT = nil,
    BG = nil,
    ICON = nil,
    DURATION = nil,
    DPS_LABEL = nil,

    -- STATE VARIABLES
    isLoaded = false,
    isCombat = false,
    isPreview = false,
    isConsole = false,
    hasTriggered = false,

    -- TRACKING VARIABLES
    currentTargetTag = nil,
    lastTargetTag = nil,

    smoothedDPS = 0,
    smoothedTTK = -1,

    healthHistory = {},

    -- DEFAULT SETTINGS
    default = {
        isEnabledAddon = true,
        isOnlyCombat = true,
        updateIntervalMs = 250,
        averageTimeSec = 10,
        smoothingMultiplier = 0.15,

        -- CALCULATION
        thresholdSec = 60,
        factorInitial = 1.25,
        factorExecute = 1.25,

        -- DIMENSIONS & GLOBAL DESIGN
        iconSize = 70,
        borderThickness = 5,
        edgeThickness = 1,
        iconDesaturation = 50,
        isThickOutline = true,

        -- TIMER (CENTER)
        fontSizeTimer = 40,
        offsetYTimer = 12,
        isColoredTimer = true,
        textColorTimer = {1, 1, 1, 1},

        -- DPS (TOP LEFT)
        isHideDPSLabel = false,
        fontSizeDPS = 22,
        textColorDPS = {1, 1, 1, 1},

        -- BORDER COLORS
        colorHigh = {0, 1, 0, 1}, -- GREEN
        colorMid = {1, 1, 0, 1}, -- YELLOW
        colorLow = {1, 0, 0, 1}, -- RED

        -- UI
        offsetX = 0,
        offsetY = -200,
        isLocked = false,
    },

    SV = {},
    SVVersion = 1,
    SVName = "TimeToKillVariables",
}