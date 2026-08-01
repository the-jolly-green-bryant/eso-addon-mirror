TargetTaunt = {
    NAME = "TargetTaunt",
    AUTHOR = "@Duesentrieb",
    VERSION = "20260604-0001",
    CHAT = "|cFF7F00[TT]|r",

    -- UI ELEMENTS
    RETICLE = nil,
    RETICLE_NAME = nil,
    RETICLE_TIME = nil,
    TRACKER = nil,
    TRACKER_BG = nil,
    TRACKER_ROWS = {},

    DRAW_TIER_CHOICES = {"High (2)", "Medium (1)", "Low (0)"},
    DRAW_TIER_VALUES = {DT_HIGH, DT_MEDIUM, DT_LOW},

    DRAW_LAYER_CHOICES = {"Overlay (3)", "Text (2)", "Controls (1)", "Background (0)"},
    DRAW_LAYER_VALUES = {DL_OVERLAY, DL_TEXT, DL_CONTROLS, DL_BACKGROUND},

    MENU_PANEL = nil,

    MARKER_PREVIEW = nil,
    ANIMATION_TIMELINE = nil,
    ANIMATION_SCALEUP = nil,
    ANIMATION_SCALEDOWN = nil,

    -- UI MODES
    UI_MODE_CHOICES = { "Crosshair & Tracker Table", "Only Crosshair", "Only Tracker Table", "Both Disabled" },
    UI_MODE_VALUES = { 3, 2, 1, 0 },
    UI_MODE_BOTH = 3,
    UI_MODE_RETICLE = 2,
    UI_MODE_TRACKER = 1,
    UI_MODE_OFF = 0,

    -- FLOATING MARKER TEXTURES; CREDITS TO SOLINUR FOR SOLINUR.DDS; THANKS!
    MARKER_TEXTURE_CHOICES = { "Triangle", "Chevron", "Solinur", },
    MARKER_TEXTURE_VALUES = { "TargetTaunt/textures/triangle.dds", "TargetTaunt/textures/chevron.dds", "TargetTaunt/textures/solinur.dds", },

    -- FONTS AND OFFSETS
    FONT_STYLE_CHOICES = {"Bold Font", "Medium Font", "Chat Font", "Gamepad Bold Font", "Gamepad Medium Font", "Gamepad Light Font", "Antique Font", "Handwritten Font", "Stone Tablet Font"},
    FONT_STYLE_VALUES = {"$(BOLD_FONT)", "$(MEDIUM_FONT)", "$(CHAT_FONT)", "$(GAMEPAD_BOLD_FONT)", "$(GAMEPAD_MEDIUM_FONT)", "$(GAMEPAD_LIGHT_FONT)", "$(ANTIQUE_FONT)", "$(HANDWRITTEN_FONT)", "$(STONE_TABLET_FONT)"},

    FONT_WEIGHT_CHOICES = {"Thick Outline", "Soft Shadow Thick", "Soft Shadow Thin", "None", },
    FONT_WEIGHT_VALUES = {"thick-outline", "soft-shadow-thick", "soft-shadow-thin", "none", },

    FONT_WEIGHT_OFFSETS = {
        ["thick-outline"] = 4,
        ["soft-shadow-thick"] = 0,
        ["soft-shadow-thin"] = 0,
        ["none"] = 0,
    },

    FONT_ENUM_CHOICES = { "Thick Outline", "Outline", "Soft Shadow Thick", "Soft Shadow Thin", "Shadow", "Normal" },
    FONT_ENUM_VALUES = { FONT_STYLE_OUTLINE_THICK, FONT_STYLE_OUTLINE, FONT_STYLE_SOFT_SHADOW_THICK, FONT_STYLE_SOFT_SHADOW_THIN, FONT_STYLE_SHADOW, FONT_STYLE_NORMAL },

    -- BACKGROUND STYLE CHOICES
    TRACKER_BACKGROUND_STYLE_CHOICES = { "Important Targets", "Current Target", "Disabled"},
    TRACKER_BACKGROUND_STYLE_VALUES = { 2, 1, 0 },

    -- CONFLICTING 3D MARKERS
    isInternalFloatingMarker = false,
    isExternalFloatingMarker = false,

    -- SOUND CHOICES
    SOUND_CHOICES = {
        "Money Changed",
        "Recipe Learned",
    },
    SOUND_VALUES = {
        SOUNDS.ITEM_MONEY_CHANGED,
        SOUNDS.RECIPE_LEARNED,
    },

    -- STATE VARIABLES
    isMenuPreview = false,
    isHiddenByScene = false,
    isReticleUnlocked = false,
    isTrackerUnlocked = false,
    isConsole = false,
    isWarningActive = false,
    isAnimationActive = false,
    isCombat = false,

    difficultyCache = {},
    healthCache = {},

    -- CENTRAL DATA STORAGE
    targetData = {},
    targetList = {},
    activeTargetCount = 0,
    currentReticleName = "",
    currentReticleEndTime = 0,
    reticleExpireTimeHighlight = 0,

    -- TAUNT STATES
    TAUNT_STATE_NONE    = 0,
    TAUNT_STATE_PLAYER  = 1,
    TAUNT_STATE_OTHER   = 2,
    TAUNT_STATE_IMMUNE  = 3,

    -- CONSTANTS
    TAUNT_ID            = 38254,
    TAUNT_IMMUNITY_ID   = 52788, -- DEBUG: BURNING 18084
    DURATION_TAUNT      = 15, -- SEC
    UPDATE_INTERVAL     = 200, -- MS

    BOSS_TAGS = { "boss1", "boss2", "boss3", "boss4", "boss5", "boss6" },

    -- DEFAULT SETTINGS
    default = {
        isEnabledAddon      = true,

        -- ROLE FILTERS & UI PREFERENCES
        modeTank            = 3,
        modeHeal            = 3,
        modeDPS             = 3,
        modeSolo            = 3,

        -- TARGET DIFFICULTY
        thresholdDifficulty = 2, -- 5=BOSS ONLY, 4=DEADLY, 3=HARD, 2=NORMAL, 1=EASY, 0=EVERYTHING
        thresholdMaxHealth = 5000000,

        -- TARGET MARKER
        isEnabledFloatingMarker = true,
        floatingMarkerSize = 32,
        floatingMarkerTexture = "TargetTaunt/textures/solinur.dds",
        isEnabledFloatingMarkerPulse = true,

        -- SOUNDS
        isEnabledSoundTauntImportant = true,
        isEnabledSoundTauntHarmless = false,
        soundTauntVolume = 5,
        soundTauntSelected = SOUNDS.ITEM_MONEY_CHANGED,

        -- DESIGN & SCALING
        reticleDrawTier = DT_HIGH,
        reticleDrawLayer = DL_OVERLAY,

        trackerDrawTier = DT_HIGH,
        trackerDrawLayer = DL_OVERLAY,

        isEnabledReticleName = true,
        isEnabledTimer = true,
        isEnabledScanning = true,
        isEnabledOtherTaunts = false,

        -- RETICLE POSITION
        reticleOffsetX = 0,
        reticleOffsetY = -100,

        -- TRACKER POSITION
        trackerOffsetX = 640,
        trackerOffsetY = 480,
        trackerWidth = 300,
        trackerHeight = 300,
        trackerEdgeX = 4,
        trackerEdgeY = 4,
        trackerDistanceY = 2,
        trackerMaxRows = 15,
        trackerEdgeThickness = 2,
        trackerGrowUpwards = false,

        -- TRACKER
        expireTimeHarmless = 3, -- SEC
        expireTimeImportant = 10, -- SEC
        expireTimeHighlight = 0.5, -- SEC

        -- RETICLE FONTS
        reticleFontStyle = "$(BOLD_FONT)",
        reticleFontSize = 24,
        reticleFontWeight = "thick-outline",
        reticleMaxLengthName = 24,

        trackerFontStyle = "$(BOLD_FONT)",
        trackerFontSize = 18,
        trackerFontWeight = "thick-outline",
        trackerMaxLengthName = 24,

        isEnabledBossBrackets = true,
        isEnabledIgnoreHarmless = false,
        isEnabledFlagHarmlessImportant = false,

        -- NAMEPLATE FONTS
        nameplateFontStyle = "$(BOLD_FONT)",
        nameplateFontSize = 20,
        nameplateFontEnum = FONT_STYLE_OUTLINE_THICK,

        -- VISUAL FEEDBACK / ANIMATION
        isEnabledReticleAnimation = true,
        reticleAnimationScale = 200, -- FACTOR
        reticleAnimationDuration = 500, -- MS

        isEnabledTrackerAnimation = true,
        trackerAnimationScale = 125, -- FACTOR
        trackerAnimationDuration = 500, -- MS

        -- WARNINGS
        isEnabledWarningTauntImmunity = true,
        isEnabledWarningTauntFaded = true,
        warningTauntDuration = 3000, -- MS

        -- TAUNT COLORS
        colorPlayer100 = {0, 1, 0, 1},
        colorPlayer50 = {1, 1, 0, 1},
        colorPlayer0 = {1, 0, 0, 1},
        colorOther = {0, 0.5, 1, 1},
        colorNone = {1, 0, 1, 1},
        --colorImmune = {0.5, 0, 0.5, 1},
        colorImmune = {0.5, 0.25, 0.75, 1},
        colorHarmless = {0.5, 0.5, 0.5, 1},

        -- TRACKER BACKGROUND
        trackerBackgroundStyle = 2,
        trackerBackgroundAlpha = 0.7,
    },

    isLoaded = false,

    SV = {},
    SVVersion = 1,
    SVName = "TargetTauntVariables",
}