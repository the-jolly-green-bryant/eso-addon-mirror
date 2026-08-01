HeatShockTracker = {
    NAME = "HeatShockTracker",
    AUTHOR = "@Duesentrieb",
    VERSION = "20260715-0001",
    CHAT = "|cFF7F00[HST]|r",

    -- UI ELEMENTS
    PARENT = nil,
    BG = nil,
    ICON = nil,
    DURATION = nil,
    STACK_LABEL = nil,
    UPTIME_LABEL = nil,
    BOSS_LABEL = nil,
    TIME_UPDATE = 100,

    -- ANIMATION
    TIMELINE = nil,
    ANIMATION_SCALEUP = nil,
    ANIMATION_SCALEDOWN = nil,
    isAnimationActive = false,

    -- SKILL CONSTANTS
    DEBUFF_ID = 134340,
    SLOT_ID = 31816,
    MAX_STACKS = 3,
    DURATION_MS = 7000,

    -- STATE VARIABLES
    isLoaded = false,
    isCombat = false,
    isEquipped = false,
    isForceShow = false,
    isMenuPreview = false,
    isConsole = false,

    -- TRACKING VARIABLES
    timeFightStart = 0,
    timeFightUpdate = 0,

    -- TABLES
    ActiveDebuffs = {},
    TargetEndTimes = {},
    BossUnits = {},
    BOSS_TAGS = { "boss1", "boss2", "boss3", "boss4", "boss5", "boss6" },
    ColorCache = {1, 1, 1, 1},

    -- UNIT IDS
    lastTargetUnitId = nil,
    lastBossUnitId = nil,
    trackedBossLabel = "BOSS",

    -- CAST COUNTER
    currentStacks = 0,
    counterCasts = 0,
    timeCounterCasts = 0,

    -- TRACKING MODES
    TRACKING_MODES = {
        [1] = "Recent Target (Dynamic)",
        [2] = "Highest Stacks (Global)",
        [3] = "Boss Focus (Target Lock)",
        [4] = "Reticle Target (Strict)",
    },

    isTrackedBoss = false,

    -- STATISTICS
    StackTimes = { [1] = 0, [2] = 0, [3] = 0 },
    StackEndTimes = { [1] = 0, [2] = 0, [3] = 0 },
    Percentages = { [1] = 0, [2] = 0, [3] = 0 },

    -- DEFAULT SETTINGS
    Default = {
        enableAddon = true,
        isOnlyCombat = true,

        -- TRACKING
        trackingMode = 1,
        isOnlyTrackPlayer = true,

        -- DIMENSIONS / DESIGN
        iconSize = 70,
        borderThickness = 5,
        edgeThickness = 1,
        iconDesaturation = 50,
        isThickOutline = true,

        -- TIMER
        fontSizeTimer = 40,
        offsetYTimer = 12,
        isColoredTimer = true,
        TextColorTimer = {1, 1, 1, 1},

        -- ANIMATION
        isEnabledAnimation = true,
        animationDuration = 300,
        animationScale = 150,

        -- BOSS LABEL
        isHideBossLabel = false,
        fontSizeBoss = 22,
        offsetYBoss = 12,
        isColoredBossLabel = true,
        TextColorBoss = {1, 1, 1, 1},

        -- STACKS
        isHideStacks = false,
        fontSizeStacks = 22,
        TextColorStacks = {1, 1, 1, 1},

        -- UPTIME
        isHideUptime = false,
        fontSizeUptime = 22,
        TextColorUptime = {1, 1, 1, 1},

        -- BORDER COLORS
        ColorStack0 = {1, 0, 0, 1},
        ColorStack1 = {1, 0.5, 0, 1},
        ColorStack2 = {1, 1, 0, 1},
        ColorStack3 = {0, 1, 0, 1},

        -- UI
        offsetX = 0,
        offsetY = -200,
        isLocked = false,

        -- CHAT
        isEnabledChat = true,
        minFightTime = 60,
    },

    SV = {},
    SVVersion = 1,
    SVName = "HeatShockTrackerVariables",
}