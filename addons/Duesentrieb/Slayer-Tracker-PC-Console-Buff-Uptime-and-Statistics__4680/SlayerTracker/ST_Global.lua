SlayerTracker = {
    NAME = "SlayerTracker",
    AUTHOR = "@Duesentrieb",
    VERSION = "20260709-0001",
    CHAT = "|cFF7F00[ST]|r",

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
    MAJOR_SLAYER_ID = 93109,
    MAJOR_SLAYER_ICON = 93120,
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

    -- EXPECTED SECONDS
    expSec = 0,

    -- STATE VARIABLES
    isLoaded = false,
    isCombat = false,
    isPreview = false,
    isConsole = false,
    isWearingSlayerSet = false,
    isActiveSlayerBar = false,

    SLAYER_SETS = {
        [331] = true, -- WARMACHINE (SLAYER)
        [332] = true, -- MASTER ARCHITECT (SLAYER)
    },

    ITEM_SLOTS = {
        EQUIP_SLOT_HEAD, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_CHEST, EQUIP_SLOT_HAND,
        EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET, EQUIP_SLOT_NECK,
        EQUIP_SLOT_RING1, EQUIP_SLOT_RING2, EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND,
        EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF
    },

    WEAPONTYPE_TWO_HANDED = {
        [WEAPONTYPE_FIRE_STAFF]        = true,
        [WEAPONTYPE_LIGHTNING_STAFF]   = true,
        [WEAPONTYPE_FROST_STAFF]       = true,
        [WEAPONTYPE_HEALING_STAFF]     = true,
        [WEAPONTYPE_TWO_HANDED_SWORD]  = true,
        [WEAPONTYPE_TWO_HANDED_AXE]    = true,
        [WEAPONTYPE_TWO_HANDED_HAMMER] = true,
    },

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

        isAlternativeIcon = true,
        textureIcon = GetAbilityIcon(93120),

        -- COLORS
        ColorIdle = {0.5, 0.5, 0.5, 1},
        ColorStart = {0, 1, 0, 1},
        ColorEnd = {1, 0, 0, 1},
        colorThreshold = 15.0,

        -- TIMER SPECIFIC
        isStaticTimer = false,
        ColorStaticTimer = {1, 1, 1, 1},
        fontSizeTimer = 40,
        offsetYTimer = 12,
        thresholdDecimal = 10.0,

        -- UPTIME SPECIFIC
        isHideUptime = false,
        fontSizeUptime = 22,
        textColorUptime = {1, 1, 1, 1},

        -- EXPECTED SECONDS
        isHideExpSecSec = false,
        fontSizeExpSec = 22,
        textColorExpSec = {0, 1, 0, 1},

        -- ANIMATION
        animationScale = 200,
        animationDuration = 500,

        -- UI POSITION
        offsetX = 0,
        offsetY = -100,
        isLocked = false,

        -- CHAT SUMMARY
        isEnabledChat = true,
        minFightTime = 60,
    },

    SV = {},
    SVVersion = 1,
    SVName = "SlayerTrackerVariables",
}