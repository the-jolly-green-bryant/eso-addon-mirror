BerserkTracker = {
    NAME = "BerserkTracker",
    AUTHOR = "@Duesentrieb",
    VERSION = "20260829",
    ADDONVERSION = 0001,
    CHAT = "|cFF7F00[BT]|r",

    -- UI ELEMENTS
    PARENT = nil,
    BG = nil,
    ICON = nil,
    DURATION = nil,
    UPTIME_LABEL = nil,
    TIME_UPDATE = 100,

    -- ANIMATION
    TIMELINE = nil,
    ANIMATION_SCALEUP = 0,
    ANIMATION_SCALEDOWN = 0,
    isAnimationActive = false,
    lastAnimationTime = 0,

    -- TRACKING
    MAJOR_BERSERK_ID = 61745,
    isActive = false,
    endTime = 0,
    referenceDuration = 0,
    groupRole = 0,
    hadBuffBefore = false,

    -- UPTIME TRACKING
    timeFightStart = 0,
    timeFightUpdate = 0,
    timeActive = 0,
    uptimePercentage = 0,

    -- STATE VARIABLES
    isLoaded = false,
    isCombat = false,
    isPreview = false,
    isConsole = false,

    -- DEFAULT SETTINGS
    Default = {
        enableAddon = true,

        -- VISIBILITY & ROLE FILTERS
        visibilityMode = 2,
        isEnabledTank = true,
        isEnabledHeal = true,
        isEnabledDPS = true,
        isEnabledSolo = true,

        -- DESIGN & SCALING
        isShowBackground = true,
        iconSize = 70,
        borderThickness = 5,
        edgeThickness = 1,
        iconDesaturation = 50,
        isThickOutline = true,

        textureIcon = GetAbilityIcon(61745),

        -- COLORS
        ColorIdle = { 0.5, 0.5, 0.5, 1 },
        ColorStart = { 0, 1, 0, 1 },
        ColorEnd = { 1, 0, 0, 1 },
        colorThreshold = 15.0,

        -- TIMER SPECIFIC
        isStaticTimer = false,
        ColorStaticTimer = { 1, 1, 1, 1 },
        fontSizeTimer = 40,
        offsetYTimer = 12,
        thresholdDecimal = 5.0,

        -- UPTIME SPECIFIC
        isHideUptime = false,
        fontSizeUptime = 22,
        textColorUptime = { 1, 1, 1, 1 },

        -- ANIMATION
        animationScale = 200,
        animationDuration = 500,

        -- UI POSITION
        offsetX = 0,
        offsetY = -100,
        isLocked = false,

        -- CHAT SUMMARY
        isEnabledChat = false,
        minFightTime = 60,
    },

    SV = {},
    SVVersion = 1,
    SVName = "BerserkTrackerVariables",
}