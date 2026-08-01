OffBalanceTracker = {
    name = "OffBalanceTracker",
    author = "@Duesentrieb",
    version = "20260526-0001",
    chat = "|cFF7F00[OBT]|r",

    -- UI ELEMENTS
    PARENT = nil,
    BG = nil,
    ICON = nil,
    DURATION = nil,
    BOSS_LABEL = nil,
    TIME_UPDATE = 100,

    TIMELINE = nil,
    ANIMATION_SCALEUP = 0,
    ANIMATION_SCALEDOWN = 0,
    isAnimationActive = false,

    -- SKILL CONSTANTS & ICONS
    debuffName = "",
    cleanDebuffName = "",
    immuneName = "",
    cleanImmuneName = "",
    ICON_OB = "/esoui/art/icons/ability_debuff_offbalance.dds",
    ICON_IMMUNE = "/esoui/art/icons/achievement_030.dds",

    -- STATE VARIABLES
    isLoaded = false,
    isCombat = false,
    isForceShow = false,
    isConsole = false,
    groupRole = 0,
    isTrackingBoss = false,
    hasCombatBoss = false,

    -- TRACKING VARIABLES
    bossTimers = {},
    knownBosses = {},
    memory = { state = 0, endTime = 0, isBoss = false },
    BOSS_TAGS = { "boss1", "boss2", "boss3", "boss4", "boss5", "boss6" },

    -- DEFAULT SETTINGS
    default = {
        enableAddon = true,
        isOnlyCombat = true,
        isBossFocus = false,
        isOnlyBosses = false,

        -- ROLES
        isEnabledTank = true,
        isEnabledHeal = true,
        isEnabledDPS = true,
        isEnabledSolo = true,

        -- DIMENSIONS & GLOBAL DESIGN
        isShowBackground = true,
        iconSize = 70,
        borderThickness = 5,
        edgeThickness = 1,
        isThickOutline = true,

        -- TIMER
        fontSizeTimer = 40,
        offsetYTimer = 0,
        isColoredTimer = true,
        textColorTimer = {1, 1, 1, 1},
        decimalThreshold = 7.5,

        -- BOSS LABEL
        isHideBossLabel = false,
        fontSizeBoss = 22,
        offsetYBoss = 12,
        isColoredBossLabel = true,
        textColorBoss = {1, 1, 1, 1},

        -- BORDER COLORS
        colorIdle = {0.5, 0.5, 0.5, 1},
        colorActive = {0, 1, 0, 1},
        colorImmune = {1, 0, 0, 1},

        -- UI
        offsetX = 0,
        offsetY = -100,
        isLocked = false,
    },

    SV = {},
    SVVersion = 1,
    SVName = "OffBalanceTrackerVariables",
}