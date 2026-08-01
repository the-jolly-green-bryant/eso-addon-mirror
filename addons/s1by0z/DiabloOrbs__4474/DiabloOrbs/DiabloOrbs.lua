local NAME = "DiabloOrbs"
local SV_VER = 1
DiabloOrbs = DiabloOrbs or {}
local ThemeManager = DiabloOrbs.ThemeManager
local SETTINGS
local allBars = {}
local updateUltimate
local styleManager
local ApplyThemeTexturesToControls
local ApplyD4SpellSlotBorders
local GetModeSpecificUltimateSettings
local GetAutoDetectedD4BarMode
local IsActionBarUltimateWidgetEnabled
local D4HealthSmokeAnchorY = nil
local VISUAL_SETTINGS_REV = 0
local DEFAULT_SETTINGS = {
    THEME = "legacy",
    LEGACY_INTERFACE_SCALE = 100,
    SHOW_FOOD_TIMER = true,
    LANGUAGE_MODE = "auto",
    SHOW_ULTIMATE_BAR = true,
    SHOW_ULTIMATE_TEXT = true,
    ULTIMATE_TEXT_MODE = "value",
    ULTIMATE_TEXT_FONT_SIZE = 16,
    ULTIMATE_TEXT_ALPHA = 100,
    ULTIMATE_TEXT_COLOR_R = 0.94,
    ULTIMATE_TEXT_COLOR_G = 0.84,
    ULTIMATE_TEXT_COLOR_B = 0.60,
    LOW_RESOURCE_WARNING_PERCENT = 20,
    SMOKE_ALPHA = 1.0,
    SMOKEBG_BRIGHTNESS = 0,
    SHADE_ALPHA = 0.0,
    BORDER_ALPHA = 1.0,
    SPLIT_ALPHA = 1.0,
    GLOW_MAX_ALPHA = 0.9,
    D4_GLOW_MAX_ALPHA = 0.8,
    SHIELD_ALPHA = 1.0,
    BORDER_PULSE_ENABLED = true,
    BORDER_PULSE_R = 1.0,
    BORDER_PULSE_G = 0.0,
    BORDER_PULSE_B = 0.0,
    D4_BORDER_PULSE_ENABLED = true,
    D4_BORDER_PULSE_R = 1.0,
    D4_BORDER_PULSE_G = 0.0,
    D4_BORDER_PULSE_B = 0.0,
    ULTIMATE_READY_COLOR_R = 1.0,
    ULTIMATE_READY_COLOR_G = 0.86,
    ULTIMATE_READY_COLOR_B = 0.25,
    ULTIMATE_PULSE_SPEED = 1.6,
    ULTIMATE_PULSE_MIN_ALPHA = 0.50,
    ULTIMATE_PULSE_MAX_ALPHA = 0.95,
    GLOW_INTERNAL_ONLY = true,
    D4_GLOW_INTERNAL_ONLY = true,
    LEGACY_ORB_LAYER_GLOBAL_SCALE = 100,
    LEGACY_BORDER_SIZE = 173,
    LEGACY_SHADE_SIZE = 160,
    LEGACY_SPLIT_SIZE = 165,
    LEGACY_GLOW_SIZE = 160,
    LEGACY_ORB_OFFSET_Y = -9,
    LEGACY_ORB_OFFSET_X = 14,
    LEGACY_SOLO_ORB_OFFSET_Y = -10,
    LEGACY_SOLO_ORB_OFFSET_X = 14,
    LEGACY_DUAL_ORB_OFFSET_Y = -3,
    LEGACY_DUAL_ORB_OFFSET_X = 24,
    ORB_COLOR_BOOST = 100,
    ORB_BRIGHTNESS = 100,
    ORB_TINT_LAYER_ENABLED = false,
    ORB_TINT_LAYER_ALPHA = 68,
    ORB_TINT_LAYER_COLOR_R = 0.10,
    ORB_TINT_LAYER_COLOR_G = 0.10,
    ORB_TINT_LAYER_COLOR_B = 0.10,
    D4_ORB_COLOR_BOOST = 115,
    D4_ORB_BRIGHTNESS = 100,
    D4_ORB_TINT_LAYER_ENABLED = false,
    D4_ORB_TINT_LAYER_ALPHA = 35,
    D4_ORB_TINT_LAYER_COLOR_R = 0.10,
    D4_ORB_TINT_LAYER_COLOR_G = 0.10,
    D4_ORB_TINT_LAYER_COLOR_B = 0.10,
    HEALTH_COLOR_R = 1.0,
    HEALTH_COLOR_G = 0.0,
    HEALTH_COLOR_B = 0.0,
    MAGICKA_COLOR_R = 0.0,
    MAGICKA_COLOR_G = 0.4,
    MAGICKA_COLOR_B = 1.0,
    STAMINA_COLOR_R = 0.0,
    STAMINA_COLOR_G = 1.0,
    STAMINA_COLOR_B = 0.0,
    SHIELD_COLOR_R = 0.0,
    SHIELD_COLOR_G = 1.0,
    SHIELD_COLOR_B = 1.0,
    D4_HEALTH_COLOR_R = 1.0,
    D4_HEALTH_COLOR_G = 0.0,
    D4_HEALTH_COLOR_B = 0.0,
    D4_MAGICKA_COLOR_R = 0.0,
    D4_MAGICKA_COLOR_G = 0.4,
    D4_MAGICKA_COLOR_B = 1.0,
    D4_STAMINA_COLOR_R = 0.0,
    D4_STAMINA_COLOR_G = 1.0,
    D4_STAMINA_COLOR_B = 0.0,
    D4_SHIELD_COLOR_R = 0.0,
    D4_SHIELD_COLOR_G = 1.0,
    D4_SHIELD_COLOR_B = 1.0,
    D4_SHIELD_ALPHA = 1.0,
    D4_SHIELD_LAYER_LEVEL = 10,
    SHIELD_RING_SCALE = 100,
    D4_SHIELD_RING_SCALE = 125,
    SHIELD_VISUAL_RESPONSE = 130,
    D4_ORB_SIZE = 188,
    D4_ORB_INSET_X = 311,
    D4_SOLO_ORB_INSET_X = 279,
    D4_DUAL_ORB_INSET_X = 278,
    D4_ORB_GLOBAL_GAP_X = -17,
    D4_BACKGROUND_ORB_GAP_X = 107,
    D4_ADDITIVE_ORB_GAP_X = 0,
    D4_ADDITIVE_ORB_OFFSET_X = 0,
    D4_ORB_HEALTH_GAP_X = -4,
    D4_ORB_COMBINED_GAP_X = 0,
    D4_ORB_OFFSET_Y = 2,
    D4_SOLO_ORB_OFFSET_Y = 2,
    D4_DUAL_ORB_OFFSET_Y = 2,
    D4_FILL_LAYER_HEALTH_OFFSET_X = 0,
    D4_FILL_LAYER_GLOBAL_X = 10,
    D4_FILL_LAYER_HEALTH_OFFSET_Y = 0,
    D4_FILL_LAYER_COMBO_OFFSET_Y = 0,
    D4_UNIFIED_ORB_ALPHA = 100,
    LOW_RESOURCE_GLOW_ALERT_ENABLED = true,
    LOW_RESOURCE_GLOW_ALERT_ALPHA = 100,
    LOW_RESOURCE_GLOW_ALERT_SIZE = 100,
    LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_R = 1.0,
    LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_G = 0.2,
    LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_B = 0.1,
    LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_R = 0.2,
    LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_G = 0.4,
    LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_B = 1.0,
    LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_R = 0.0,
    LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_G = 0.9,
    LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_B = 0.1,
    LOW_RESOURCE_FRACTIONATE_COMBINED = true,
    D4_SHOW_OFFBAR = true,
    D4_BAR_TEXTURE_SCALE = 120,
    D4_SOLO_BAR_WIDTH_SCALE = 92,
    D4_SOLO_BAR_HEIGHT_SCALE = 124,
    D4_DUAL_BAR_WIDTH_SCALE = 92,
    D4_DUAL_BAR_HEIGHT_SCALE = 120,
    D4_BAR_SCALE = 100,
    D4_BAR_OFFSET_Y = 1,
    D4_SOLO_BAR_OFFSET_Y = 10,
    D4_DUAL_BAR_OFFSET_Y = 46,
    -- Legacy ultimate bar
    ULTIMATE_BAR_WIDTH_SCALE = 100,
    ULTIMATE_BAR_HEIGHT = 8,
    ULTIMATE_BAR_OFFSET_Y = 0,
    ULTIMATE_BAR_SOLO_WIDTH_SCALE = 100,
    ULTIMATE_BAR_SOLO_HEIGHT = 8,
    ULTIMATE_BAR_SOLO_OFFSET_Y = -2,
    ULTIMATE_BAR_DUAL_WIDTH_SCALE = 103,
    ULTIMATE_BAR_DUAL_HEIGHT = 10,
    ULTIMATE_BAR_DUAL_OFFSET_Y = 0,
    SHOW_ULTIMATE_BAR_BACKGROUND = false,
    ULTIMATE_BAR_FILL_ALPHA = 90,
    ULTIMATE_BAR_BG_ALPHA = 100,
    ULTIMATE_BAR_BG_COLOR_R = 1,
    ULTIMATE_BAR_BG_COLOR_G = 1,
    ULTIMATE_BAR_BG_COLOR_B = 1,
    ULTIMATE_BAR_BG_SOLO_WIDTH_SCALE = 100,
    ULTIMATE_BAR_BG_SOLO_HEIGHT = 16,
    ULTIMATE_BAR_BG_SOLO_OFFSET_Y = 0,
    ULTIMATE_BAR_BG_DUAL_WIDTH_SCALE = 100,
    ULTIMATE_BAR_BG_DUAL_HEIGHT = 16,
    ULTIMATE_BAR_BG_DUAL_OFFSET_Y = 0,
    -- D4 ultimate bar (valeurs calibrées)
    D4_SHOW_ULTIMATE_BAR = true,
    D4_ULTIMATE_BAR_WIDTH_SCALE = 100,
    D4_ULTIMATE_BAR_HEIGHT = 8,
    D4_ULTIMATE_BAR_OFFSET_Y = 0,
    D4_ULTIMATE_BAR_SOLO_WIDTH_SCALE = 80,
    D4_ULTIMATE_BAR_SOLO_HEIGHT = 11,
    D4_ULTIMATE_BAR_SOLO_OFFSET_Y = 54,
    D4_ULTIMATE_BAR_DUAL_WIDTH_SCALE = 82,
    D4_ULTIMATE_BAR_DUAL_HEIGHT = 11,
    D4_ULTIMATE_BAR_DUAL_OFFSET_Y = -30,
    D4_SHOW_ULTIMATE_BAR_BACKGROUND = true,
    D4_ULTIMATE_BAR_FILL_ALPHA = 45,
    D4_ULTIMATE_BAR_BG_ALPHA = 100,
    D4_ULTIMATE_BAR_BG_COLOR_R = 1,
    D4_ULTIMATE_BAR_BG_COLOR_G = 1,
    D4_ULTIMATE_BAR_BG_COLOR_B = 1,
    D4_ULTIMATE_BAR_BG_SOLO_WIDTH_SCALE = 83,
    D4_ULTIMATE_BAR_BG_SOLO_HEIGHT = 26,
    D4_ULTIMATE_BAR_BG_SOLO_OFFSET_Y = 51,
    D4_ULTIMATE_BAR_BG_DUAL_WIDTH_SCALE = 86,
    D4_ULTIMATE_BAR_BG_DUAL_HEIGHT = 23,
    D4_ULTIMATE_BAR_BG_DUAL_OFFSET_Y = -30,
    D4_BACKPLATE_INSET_X = 223,
    D4_BACKPLATE_OFFSET_X = 85,
    D4_BACKPLATE_OFFSET_Y = 0,
    D4_BACKPLATE_WIDTH_SCALE = 60,
    D4_BACKPLATE_HEIGHT_SCALE = 60,
    D4_ORB_BACKPLATE_PRESET = 16,
    D4_GLOBAL_TINT_R = 1.0,
    D4_GLOBAL_TINT_G = 1.0,
    D4_GLOBAL_TINT_B = 1.0,
    D4_GLOBAL_TINT_INTENSITY = 0,
    D4_SHOW_LIVE_PREVIEW = false,
    ENABLE_ACTION_BAR_MODULE = true,
    SHOW_ACTION_BAR_BACKGROUNDS = true,
    SHOW_ACTION_BAR_SLOTS = true,
    SHOW_ACTION_BAR_ULTIMATE_WIDGET = true,
    SHOW_ACTION_BAR_HOTKEYS = true,
    ACTION_BAR_HOTKEY_POSITION = "inside",
    ACTION_BAR_HOTKEY_SCALE = 100,
    ACTION_BAR_HOTKEY_ALPHA = 100,
    ACTION_BAR_HOTKEY_OFFSET_X = -15,
    ACTION_BAR_HOTKEY_OFFSET_Y = -13,
    ACTION_BAR_HOTKEY_ONLY_IN_COMBAT = false,
    SHOW_ACTION_BAR_WEAPON_SWAP = false,
    SHOW_ACTION_BAR_COMPANION_ULTIMATE = true,
    SHOW_D4_SLOT_BORDERS = true,
    D4_SLOT_BORDER_ADVANCED = false,
    D4_SLOT_HIGHLIGHT_ALPHA = 100,
    D4_SLOT_HIGHLIGHT_SOLO_ALPHA = 100,
    D4_SLOT_HIGHLIGHT_DUAL_ALPHA = 100,
    INACTIVE_BACK_BAR_ALPHA = 55,
    INACTIVE_BACK_BAR_DESATURATION = 35,
    INACTIVE_BACK_BAR_ALPHA_DUAL = 60,
    INACTIVE_BACK_BAR_DESATURATION_DUAL = 43,
    D4_BAR_BRIGHTNESS = 120,
    D4_BAR_QUICKSLOT_OFFSET_X = 0,
    D4_BAR_QUICKSLOT_OFFSET_Y = 0,
    D4_BAR_ULTIMATE_OFFSET_X = -15,
    D4_BAR_ULTIMATE_OFFSET_Y = 0,
    D4_BAR_SLOTS_OFFSET_Y = -38,
    D4_BAR_SLOTS_OFFSET_Y_DUAL = -64,
    ACTION_BAR_CENTER_SLOTS_GAP_X = 2,
    LEGACY_ACTION_BAR_CENTER_SLOTS_GAP_X = 6,
    LEGACY_ULTIMATE_OFFSET_X = 0,
    LEGACY_QUICKSLOT_OFFSET_X = 0,
    LEGACY_SOLO_ACTION_BAR_CENTER_SLOTS_GAP_X = 6,
    LEGACY_SOLO_ULTIMATE_OFFSET_X = 0,
    LEGACY_SOLO_QUICKSLOT_OFFSET_X = 0,
    LEGACY_DUAL_ACTION_BAR_CENTER_SLOTS_GAP_X = 6,
    LEGACY_DUAL_ULTIMATE_OFFSET_X = 0,
    LEGACY_DUAL_QUICKSLOT_OFFSET_X = 1,
    D4_ALL_SLOT_BORDER_ALPHA = 100,
    D4_SLOT_BORDER_DARKNESS = 0,
    D4_SLOT_BORDER_CONTRAST = 100,
    D4_SLOT_SMOKE_INTENSITY = 0,
    D4_COMPANION_SLOT_BORDER_DARKNESS = 0,
    D4_IDLE_HIGHLIGHT_ALPHA = 50,
    D4_MIN_SHADE_ALPHA = 0,
    D4_FILL_LAYER_ALPHA = 90,
    D4_FILL_LAYER_VISIBLE = true,
    D4_USE_TYPED_FILL_TEXTURES = false,
    D4_FILL_TINT_STRENGTH = 100,
    D4_FILL_LAYER_SIZE = 86,
    D4_FILL_LAYER_OFFSET_X = 0,
    D4_FILL_LAYER_OFFSET_Y = -15,
    D4_BACKGROUND_LAYER_ALPHA = 100,
    D4_BACKGROUND_LAYER_VISIBLE = true,
    D4_BACKGROUND_LAYER_BRIGHTNESS = 60,
    D4_BACKGROUND_LAYER_SIZE = 100,
    D4_BACKGROUND_LAYER_WIDTH = 106,
    D4_BACKGROUND_LAYER_HEIGHT = 106,
    D4_BACKGROUND_LAYER_OFFSET_X = 1,
    D4_BACKGROUND_LAYER_OFFSET_Y = 9,
    D4_BACKGROUND_LAYER_GLOBAL_X = 46,
    D4_BACKGROUND_NEGATIVE = true,
    D4_BACKGROUND_EDGE_LIGHT_BOOST = 70,
    D4_BACKGROUND_ADDITIVE_STAMINA = true,
    D4_GLOW_LAYER_ALPHA = 100,
    D4_GLOW_LAYER_VISIBLE = true,
    D4_GLOW_LAYER_SIZE = 87,
    D4_GLOW_LAYER_OFFSET_X = 0,
    D4_GLOW_LAYER_OFFSET_Y = 2,
    D4_SHADE_LAYER_ALPHA = 100,
    D4_SHADE_LAYER_VISIBLE = true,
    D4_SHADE_LAYER_SIZE = 102,
    D4_SHADE_LAYER_OFFSET_X = 0,
    D4_SHADE_LAYER_OFFSET_Y = 0,
    D4_SHADE_LAYER_GAP_X = 0,
    D4_BORDER_LAYER_ALPHA = 100,
    D4_BORDER_LAYER_VISIBLE = true,
    D4_BORDER_LAYER_SIZE = 103,
    D4_BORDER_LAYER_OFFSET_X = -9,
    D4_BORDER_LAYER_OFFSET_Y = -9,
    D4_BORDER_LAYER_GAP_X = 0,
    -- Séparateur central (scellé) mana/endurance
    D4_SEAM_VISIBLE = true,
    D4_SEAM_ALPHA = 45,
    D4_SEAM_COLOR_R = 0.1294117719,
    D4_SEAM_COLOR_G = 0.0901960805,
    D4_SEAM_COLOR_B = 0.0,
    D4_SEAM_SIZE = 100,
    D4_SEAM_WIDTH = 137,
    D4_SEAM_HEIGHT = 92,
    D4_SEAM_BRIGHTNESS = 0,
    D4_SEAM_ADDITIVE = false,
    D4_SEAM_OFFSET_X = 0,
    D4_SEAM_OFFSET_Y = -1,
    -- Glow orbe
    D4_GLOW_BRIGHTNESS = 500,
    D4_GLOW_INTENSITY = 500,
    D4_GLOW_CONTRAST = 395,
    D4_GLOW_TINT = 0,
    -- Overlay contour (itsmars)
    D4_OVERLAY_BRIGHTNESS = 75,
    D4_OVERLAY_CONTRAST = 70,
    D4_OVERLAY_LAYER_ALPHA = 58,
    D4_OVERLAY_LAYER_VISIBLE = true,
    D4_OVERLAY_LAYER_SIZE = 92,
    D4_OVERLAY_LAYER_OFFSET_X = -2,
    D4_OVERLAY_LAYER_OFFSET_Y = -2,
    D4_OVERLAY_LAYER_GAP_X = 0,
    NUMBER_FONT_FAMILY = "dum1",
    -- Legacy labels
    LABEL_SCALE = 0.95,
    LABEL_FORMAT = "full",
    LABEL_POSITION_MODE = "inside",
    LABEL_INSIDE_SWAP_MANA_STAMINA = false,
    LABEL_INNER_STYLE = "light",
    LABEL_TEXT_ALPHA = 100,
    LABEL_INNER_SHADE_ALPHA = 73,
    LABEL_INNER_BACKDROP_ALPHA = 35,
    LABEL_INNER_SHADE_COLOR_R = 0.0,
    LABEL_INNER_SHADE_COLOR_G = 0.0,
    LABEL_INNER_SHADE_COLOR_B = 0.0,
    LABEL_OUTER_PADDING_X = 12,
    LABEL_OUTER_PADDING_Y = -28,
    LABEL_INSIDE_HEALTH_OFFSET_X = 0,
    LABEL_CENTER_GAP_X = 42,
    LABEL_OFFSET_Y = 0,
    -- D4 labels (valeurs calibrées)
    D4_LABEL_SCALE = 1.1,
    D4_LABEL_FORMAT = "full",
    D4_LABEL_POSITION_MODE = "inside",
    D4_LABEL_INSIDE_SWAP_MANA_STAMINA = true,
    D4_LABEL_INNER_STYLE = "light",
    D4_LABEL_TEXT_ALPHA = 100,
    D4_LABEL_INNER_SHADE_ALPHA = 35,
    D4_LABEL_INNER_BACKDROP_ALPHA = 35,
    D4_LABEL_INNER_SHADE_COLOR_R = 0.0,
    D4_LABEL_INNER_SHADE_COLOR_G = 0.0,
    D4_LABEL_INNER_SHADE_COLOR_B = 0.0,
    D4_LABEL_OUTER_PADDING_X = 0,
    D4_LABEL_OUTER_PADDING_Y = -28,
    D4_LABEL_INSIDE_HEALTH_OFFSET_X = 1,
    D4_LABEL_CENTER_GAP_X = -40,
    D4_LABEL_OFFSET_Y = 0,
    SHOW_SHIELD_LABEL = true,
    SHIELD_LABEL_OFFSET_X = 0,
    SHIELD_LABEL_OFFSET_Y = -39,
    D4_SHOW_SHIELD_LABEL = true,
    D4_SHIELD_LABEL_OFFSET_X = 0,
    D4_SHIELD_LABEL_OFFSET_Y = -32,
    GLOW_CENTER_GAP_X = 65,
    GLOW_OFFSET_Y = 0,
    D4_GLOW_CENTER_GAP_X = 65,
    D4_GLOW_OFFSET_Y = 0,
    VALUE_TOOLTIP_BORDER_ALPHA = 100,
    -- Backbar D4 (barre inactive affichée derrière la barre active en mode dual)
    D4_BACKBAR_OFFSET_X = 0,
    D4_BACKBAR_OFFSET_Y = -34,
    D4_BACKBAR_ALPHA = 55,
    D4_BACKBAR_DESATURATION = 79,
    D4_BACKBAR_SCALE = 80,
    D4_BACKBAR_SLOT_SIZE = 61,
    D4_BACKBAR_SLOT_GAP = 5,
    D4_BACKBAR_ULT_GAP = 10,
    D4_BACKBAR_ULT_OFFSET_X = -5,
    D4_BACKBAR_ULT_OFFSET_Y = 0,
    -- Backbar Legacy (barre inactive affichée derrière la barre active en mode dual)
    LEGACY_SHOW_BACKBAR = true,
    -- Fond barre solo Legacy (ActionBarXp*)
    LEGACY_BG_SOLO_MIDDLE_WIDTH = 400,
    LEGACY_BG_SOLO_MIDDLE_HEIGHT = 256,
    LEGACY_BG_SOLO_MIDDLE_OFFSET_X = 0,
    LEGACY_BG_SOLO_MIDDLE_OFFSET_Y = -127,
    LEGACY_BG_SOLO_LEFT_OFFSET_X = 80,
    LEGACY_BG_SOLO_RIGHT_OFFSET_X = -83,
    -- Fond barre dual Legacy (DiabloOrbsDualBarXp*)
    LEGACY_BG_DUAL_MIDDLE_WIDTH = 400,
    LEGACY_BG_DUAL_MIDDLE_HEIGHT = 256,
    LEGACY_BG_DUAL_MIDDLE_OFFSET_X = 0,
    LEGACY_BG_DUAL_MIDDLE_OFFSET_Y = -127,
    LEGACY_BG_DUAL_LEFT_OFFSET_X = 69,
    LEGACY_BG_DUAL_RIGHT_OFFSET_X = -68,
    LEGACY_BACKBAR_OFFSET_X = 0,
    LEGACY_BACKBAR_OFFSET_Y = -59,
    LEGACY_BACKBAR_ALPHA = 40,
    LEGACY_BACKBAR_DESATURATION = 83,
    LEGACY_BACKBAR_SCALE = 79,
    LEGACY_BACKBAR_SLOT_SIZE = 61,
    LEGACY_BACKBAR_SLOT_GAP = 12,
    LEGACY_BACKBAR_ULT_GAP = 11,
    LEGACY_BACKBAR_ULT_OFFSET_X = 0,
    LEGACY_BACKBAR_ULT_OFFSET_Y = 0,
    -- Décorations Legacy (Angel / Demon)
    LEGACY_DECO_VISIBLE = false,
    LEGACY_DECO_SIZE = 200,
    LEGACY_DECO_WIDTH = 100,
    LEGACY_DECO_HEIGHT = 100,
    LEGACY_DECO_GAP_X = 90,
    LEGACY_DECO_OFFSET_Y = 0,
    LEGACY_DECO_FOREGROUND = false,
    LEGACY_DECO_MIRROR = false,
}

local powerSettings = {
    [POWERTYPE_HEALTH] = {0, 1, 0, 'esoui/art/icons/alchemy/crafting_alchemy_trait_restorehealth.dds'},
    [POWERTYPE_MAGICKA] = {0, 0.5, 0, 'esoui/art/icons/alchemy/crafting_alchemy_trait_restoremagicka.dds'},
    [POWERTYPE_STAMINA] = {0.5, 0, 75, 'esoui/art/icons/alchemy/crafting_alchemy_trait_restorestamina.dds'},
    [POWERTYPE_MOUNT_STAMINA] = {0.5, 0, 75, nil},
    [POWERTYPE_WEREWOLF] = {0.0, 0.5, 0, nil},
    [ATTRIBUTE_VISUAL_POWER_SHIELDING] = {1, 0, 0, nil},
}

-- Couleurs du SmokeBg : dark = couleur actuelle (XML), bright = couleur pleine
local smokeBgColors = {
    [POWERTYPE_HEALTH]             = { dark={0.302, 0, 0},      bright={1, 0, 0} },
    [POWERTYPE_MAGICKA]            = { dark={0, 0, 0.2},        bright={0, 0.4, 1} },
    [POWERTYPE_STAMINA]            = { dark={0, 0.302, 0},      bright={0, 1, 0} },
    [POWERTYPE_MOUNT_STAMINA]      = { dark={0, 0.302, 0},      bright={0, 1, 0} },
    [POWERTYPE_WEREWOLF]           = { dark={0, 0, 0.2},        bright={0, 0.4, 1} },
    [ATTRIBUTE_VISUAL_POWER_SHIELDING] = { dark={0, 0.302, 0.302}, bright={0, 1, 1} },
}

local function Clamp01(value)
    return zo_min(1, zo_max(0, value))
end

-- Clés indépendantes par thème : lire/écrire la variante D4_ ou Legacy selon le thème actif
local THEME_INDEPENDENT_KEYS = {
    -- Ultimate bar
    "SHOW_ULTIMATE_BAR", "SHOW_ULTIMATE_BAR_BACKGROUND",
    "ULTIMATE_BAR_FILL_ALPHA", "ULTIMATE_BAR_BG_ALPHA",
    "ULTIMATE_BAR_BG_COLOR_R", "ULTIMATE_BAR_BG_COLOR_G", "ULTIMATE_BAR_BG_COLOR_B",
    "ULTIMATE_BAR_WIDTH_SCALE", "ULTIMATE_BAR_HEIGHT", "ULTIMATE_BAR_OFFSET_Y",
    "ULTIMATE_BAR_SOLO_WIDTH_SCALE", "ULTIMATE_BAR_SOLO_HEIGHT", "ULTIMATE_BAR_SOLO_OFFSET_Y",
    "ULTIMATE_BAR_DUAL_WIDTH_SCALE", "ULTIMATE_BAR_DUAL_HEIGHT", "ULTIMATE_BAR_DUAL_OFFSET_Y",
    "ULTIMATE_BAR_BG_SOLO_WIDTH_SCALE", "ULTIMATE_BAR_BG_SOLO_HEIGHT", "ULTIMATE_BAR_BG_SOLO_OFFSET_Y",
    "ULTIMATE_BAR_BG_DUAL_WIDTH_SCALE", "ULTIMATE_BAR_BG_DUAL_HEIGHT", "ULTIMATE_BAR_BG_DUAL_OFFSET_Y",
    -- Labels
    "LABEL_SCALE", "LABEL_FORMAT", "LABEL_POSITION_MODE",
    "LABEL_INSIDE_SWAP_MANA_STAMINA", "LABEL_INNER_STYLE",
    "LABEL_TEXT_ALPHA", "LABEL_INNER_SHADE_ALPHA", "LABEL_INNER_BACKDROP_ALPHA",
    "LABEL_INNER_SHADE_COLOR_R", "LABEL_INNER_SHADE_COLOR_G", "LABEL_INNER_SHADE_COLOR_B",
    "LABEL_OUTER_PADDING_X", "LABEL_OUTER_PADDING_Y",
    "LABEL_INSIDE_HEALTH_OFFSET_X", "LABEL_CENTER_GAP_X", "LABEL_OFFSET_Y",
    -- Border pulse
    "BORDER_PULSE_ENABLED", "BORDER_PULSE_R", "BORDER_PULSE_G", "BORDER_PULSE_B",
}
local THEME_INDEPENDENT_KEYS_SET = {}
for _, k in ipairs(THEME_INDEPENDENT_KEYS) do
    THEME_INDEPENDENT_KEYS_SET[k] = true
end

local function GetThemeSetting(key)
    local isD4 = (ThemeManager:GetCurrentTheme() == "d4")
    if isD4 then
        local d4key = "D4_" .. key
        local v = SETTINGS[d4key]
        if v == nil then v = DEFAULT_SETTINGS[d4key] end
        return v
    else
        local v = SETTINGS[key]
        if v == nil then v = DEFAULT_SETTINGS[key] end
        return v
    end
end

local function SetThemeSetting(key, value)
    local isD4 = (ThemeManager:GetCurrentTheme() == "d4")
    if isD4 then
        SETTINGS["D4_" .. key] = value
    else
        SETTINGS[key] = value
    end
end

local function GetD4OrbSize()
    if ThemeManager:GetCurrentTheme() == "d4" then
        return zo_max(110, zo_min(240, SETTINGS.D4_ORB_SIZE or DEFAULT_SETTINGS.D4_ORB_SIZE))
    end
    return 150
end

local function GetD4BarBrightnessMultiplier()
    local brightness = SETTINGS.D4_BAR_BRIGHTNESS or DEFAULT_SETTINGS.D4_BAR_BRIGHTNESS
    return zo_max(40, zo_min(140, brightness)) / 100
end

local function GetD4TintedColor(rOrBrightness, gIn, bIn)
    local intensity = (SETTINGS.D4_GLOBAL_TINT_INTENSITY or DEFAULT_SETTINGS.D4_GLOBAL_TINT_INTENSITY) / 100
    local rBase = rOrBrightness
    local gBase = gIn or rOrBrightness
    local bBase = bIn or rOrBrightness
    if intensity <= 0 then
        return rBase, gBase, bBase, 1
    end
    local tR = SETTINGS.D4_GLOBAL_TINT_R or DEFAULT_SETTINGS.D4_GLOBAL_TINT_R
    local tG = SETTINGS.D4_GLOBAL_TINT_G or DEFAULT_SETTINGS.D4_GLOBAL_TINT_G
    local tB = SETTINGS.D4_GLOBAL_TINT_B or DEFAULT_SETTINGS.D4_GLOBAL_TINT_B
    local inv = 1 - intensity
    local r = rBase * (inv + tR * intensity)
    local g = gBase * (inv + tG * intensity)
    local b = bBase * (inv + tB * intensity)
    return r, g, b, 1
end

local function GetD4BarAxisScale(isDouble, axis)
    local settingKey

    if isDouble then
        settingKey = (axis == "width") and "D4_DUAL_BAR_WIDTH_SCALE" or "D4_DUAL_BAR_HEIGHT_SCALE"
    else
        settingKey = (axis == "width") and "D4_SOLO_BAR_WIDTH_SCALE" or "D4_SOLO_BAR_HEIGHT_SCALE"
    end

    local scaleValue = SETTINGS[settingKey] or DEFAULT_SETTINGS[settingKey]
    return zo_max(50, zo_min(180, scaleValue)) / 100
end

local function GetD4BarDimensions(isDouble)
    local baseWidth = 424
    local baseHeight = isDouble and 129 or 75
    local scale = zo_max(60, zo_min(160, SETTINGS.D4_BAR_TEXTURE_SCALE or DEFAULT_SETTINGS.D4_BAR_TEXTURE_SCALE)) / 100
    local widthScale = GetD4BarAxisScale(isDouble, "width")
    local heightScale = GetD4BarAxisScale(isDouble, "height")
    return zo_floor((baseWidth * scale * widthScale) + 0.5), zo_floor((baseHeight * scale * heightScale) + 0.5)
end

local function GetD4BarTexturePath(isDouble)
    if isDouble then
        return "DiabloOrbs/Themes/D4/Textures/D4DualBar.dds"
    end
    return "DiabloOrbs/Themes/D4/Textures/D4SoloBar.dds"
end

local function GetLegacyInterfaceScale()
    local value = SETTINGS and SETTINGS.LEGACY_INTERFACE_SCALE
    if value == nil then
        value = DEFAULT_SETTINGS.LEGACY_INTERFACE_SCALE
    end
    return zo_max(70, zo_min(180, value)) / 100
end

local function GetD4ActionBarSlotScale(style, isDouble)
    local desiredScale = zo_max(50, zo_min(300, SETTINGS.D4_BAR_SCALE or DEFAULT_SETTINGS.D4_BAR_SCALE)) / 100
    return zo_max(0.5, desiredScale)
end

local GetModeSpecificUltimateSettings
local IsActionBarUltimateWidgetEnabled
local GetAutoDetectedD4BarMode

local function GetModeSpecificUltimateBackgroundSettings(isDouble)
    local widthScale = isDouble and GetThemeSetting("ULTIMATE_BAR_BG_DUAL_WIDTH_SCALE") or GetThemeSetting("ULTIMATE_BAR_BG_SOLO_WIDTH_SCALE")
    local height = isDouble and GetThemeSetting("ULTIMATE_BAR_BG_DUAL_HEIGHT") or GetThemeSetting("ULTIMATE_BAR_BG_SOLO_HEIGHT")
    local offsetY = isDouble and GetThemeSetting("ULTIMATE_BAR_BG_DUAL_OFFSET_Y") or GetThemeSetting("ULTIMATE_BAR_BG_SOLO_OFFSET_Y")
    local _, fallbackHeight, fallbackOffset = GetModeSpecificUltimateSettings(isDouble)

    if widthScale == nil then
        widthScale = 100
    end
    if height == nil then
        height = fallbackHeight
    end
    if offsetY == nil then
        offsetY = fallbackOffset
    end

    return widthScale, height, offsetY
end

local function GetUltimateBarFillAlpha()
    local alphaPercent = GetThemeSetting("ULTIMATE_BAR_FILL_ALPHA")
    if alphaPercent == nil then
        alphaPercent = DEFAULT_SETTINGS.ULTIMATE_BAR_FILL_ALPHA
    end
    return zo_max(0, zo_min(100, alphaPercent)) / 100
end

local function GetOrCreateUltimateBarBackground(topLevelCtrl)
    local name = topLevelCtrl:GetName() .. "LineBackground"
    local existing = _G[name]
    if existing ~= nil then
        return existing
    end

    local background = WINDOW_MANAGER:CreateControl(name, topLevelCtrl, CT_TEXTURE)
    background:SetDrawLayer(0)
    background:SetDrawLevel(0)
    background:SetMouseEnabled(false)
    if ThemeManager:GetCurrentTheme() == "d4" then
        background:SetTexture("DiabloOrbs/Themes/D4/Textures/fond_jauge.dds")
    else
        background:SetTexture("DiabloOrbs/Textures/UltimateGaugeBackground.dds")
    end
    background:SetTextureCoords(0, 1, 0, 1)
    return background
end

local function NormalizeNumberFontFamily(value)
    local key = string.lower(tostring(value or ""))
    if key == "eso" or key == "dum1" or key == "spirits" or key == "gotic" then
        return key
    end
    return DEFAULT_SETTINGS.NUMBER_FONT_FAMILY
end

local function FontFileExists(path)
    if path == nil or path == "" then
        return false
    end
    if DoesFileExist == nil then
        -- Some runtime contexts do not expose DoesFileExist; allow path usage.
        return true
    end
    local ok, exists = pcall(DoesFileExist, path)
    return ok and exists == true
end

local ENABLE_DEBUG_LOG = false

local function DebugPrint(message)
    if not ENABLE_DEBUG_LOG then
        return
    end
    if type(d) == "function" then
        d("[DiabloOrbs] " .. tostring(message))
    end
end

local CUSTOM_NUMBER_FONTS = {
    { key = "eso", label = "ESO Medium", file = "$(MEDIUM_FONT)" },
    {
        key = "dum1",
        label = "Dum1 (par défaut)",
        ttfFiles = {
            "EsoUI/AddOns/DiabloOrbs/Fonts/dum1.ttf",
            "AddOns/DiabloOrbs/Fonts/dum1.ttf",
            "DiabloOrbs/Fonts/dum1.ttf",
        },
        slug = "EsoUI/Common/Fonts/ProseAntiquePSMT.slug",
    },
    {
        key = "spirits",
        label = "Spirit's Sword (custom)",
        ttfFiles = {
            "EsoUI/AddOns/DiabloOrbs/Fonts/spirits_sword.ttf",
            "AddOns/DiabloOrbs/Fonts/spirits_sword.ttf",
            "DiabloOrbs/Fonts/spirits_sword.ttf",
        },
        slug = "EsoUI/Common/Fonts/TrajanPro-Regular.slug",
    },
    {
        key = "gotic",
        label = "Gotic Ween (custom)",
        ttfFiles = {
            "EsoUI/AddOns/DiabloOrbs/Fonts/gotic_ween.ttf",
            "AddOns/DiabloOrbs/Fonts/gotic_ween.ttf",
            "DiabloOrbs/Fonts/gotic_ween.ttf",
            "EsoUI/AddOns/DiabloOrbs/Fonts/gotic ween.ttf",
            "AddOns/DiabloOrbs/Fonts/gotic ween.ttf",
            "DiabloOrbs/Fonts/gotic ween.ttf",
        },
        slug = "EsoUI/Common/Fonts/Univers57.slug",
    },
}

local function AddCustomNumberFont(key, label, file)
    table.insert(CUSTOM_NUMBER_FONTS, { key = key, label = label, file = file })
end

local function GetNumberFontFile()
    local fontKey = NormalizeNumberFontFamily(SETTINGS.NUMBER_FONT_FAMILY or DEFAULT_SETTINGS.NUMBER_FONT_FAMILY)
    if SETTINGS.NUMBER_FONT_FAMILY ~= fontKey then
        SETTINGS.NUMBER_FONT_FAMILY = fontKey
    end

    DebugPrint(string.format("GetNumberFontFile: selected key=%s", tostring(fontKey)))

    if fontKey == "eso" then
        return "$(MEDIUM_FONT)"
    elseif fontKey == "dum1" then
        return "EsoUI/Common/Fonts/ProseAntiquePSMT.slug"
    elseif fontKey == "spirits" then
        return "EsoUI/Common/Fonts/TrajanPro-Regular.slug"
    elseif fontKey == "gotic" then
        return "EsoUI/Common/Fonts/Univers57.slug"
    end

    return "$(MEDIUM_FONT)"
end

local function GetUltimateTextFontSize()
    local size = SETTINGS.ULTIMATE_TEXT_FONT_SIZE
    if size == nil then
        size = DEFAULT_SETTINGS.ULTIMATE_TEXT_FONT_SIZE
    end
    return zo_max(10, zo_min(36, zo_round(size)))
end

local function GetUltimateTextAlpha()
    local alphaPercent = SETTINGS.ULTIMATE_TEXT_ALPHA
    if alphaPercent == nil then
        alphaPercent = DEFAULT_SETTINGS.ULTIMATE_TEXT_ALPHA
    end
    return zo_max(0, zo_min(100, alphaPercent)) / 100
end

local function ApplyUltimateTextVisual(label)
    if label == nil then
        return
    end

    local fontFile = GetNumberFontFile() or "$(BOLD_FONT)"
    label:SetFont(string.format("%s|%d|soft-shadow-thin", fontFile, GetUltimateTextFontSize()))
    label:SetColor(
        Clamp01(SETTINGS.ULTIMATE_TEXT_COLOR_R or DEFAULT_SETTINGS.ULTIMATE_TEXT_COLOR_R),
        Clamp01(SETTINGS.ULTIMATE_TEXT_COLOR_G or DEFAULT_SETTINGS.ULTIMATE_TEXT_COLOR_G),
        Clamp01(SETTINGS.ULTIMATE_TEXT_COLOR_B or DEFAULT_SETTINGS.ULTIMATE_TEXT_COLOR_B),
        1
    )
    label:SetAlpha(GetUltimateTextAlpha())
end

local function GetOrCreateUltimateTextLabel(topLevelCtrl)
    local legacyLineValue = GetControl(topLevelCtrl, "LineValue")
    if legacyLineValue ~= nil then
        legacyLineValue:SetHidden(true)
    end

    local name = topLevelCtrl:GetName() .. "UltimateTextLabel"
    local label = _G[name]
    if label == nil then
        label = WINDOW_MANAGER:CreateControl(name, topLevelCtrl, CT_LABEL)
        label:SetDrawLayer(1)
        label:SetDrawLevel(30)
        label:SetMouseEnabled(false)
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    end

    ApplyUltimateTextVisual(label)
    return label
end

local function ApplyUltimateBarLayout(topLevelCtrl, isDouble)
    local line = GetControl(topLevelCtrl, "Line")
    local bgMiddle = GetControl(topLevelCtrl, "ActionBarBgMiddle")
    local lineValue = GetOrCreateUltimateTextLabel(topLevelCtrl)
    local lineBg = GetOrCreateUltimateBarBackground(topLevelCtrl)

    if line == nil or bgMiddle == nil then
        return
    end

    local bgMiddleWidth = bgMiddle:GetWidth()
    if bgMiddleWidth == nil or bgMiddleWidth <= 0 then
        bgMiddleWidth = isDouble and 410 or 424
    end

    local baseInset = isDouble and 14 or 0
    local baseOffsetY = isDouble and -114 or -68
    local widthScaleSetting, heightSetting, offsetSetting = GetModeSpecificUltimateSettings(isDouble)
    local widthScale = zo_max(50, zo_min(180, widthScaleSetting)) / 100
    local height = zo_max(2, zo_min(24, heightSetting))
    local offsetY = baseOffsetY + offsetSetting
    local width = zo_max(40, zo_floor(((bgMiddleWidth - baseInset) * widthScale) + 0.5))

    local bgWidthScaleSetting, bgHeightSetting, bgOffsetSetting = GetModeSpecificUltimateBackgroundSettings(isDouble)
    local bgWidthScale = zo_max(50, zo_min(180, bgWidthScaleSetting)) / 100
    local bgHeight = zo_max(4, zo_min(64, bgHeightSetting))
    local bgOffsetY = baseOffsetY + bgOffsetSetting
    local bgWidth = zo_max(40, zo_floor(((bgMiddleWidth - baseInset) * bgWidthScale) + 0.5))
    local isD4Theme = (ThemeManager:GetCurrentTheme() == "d4")
    local showLineBg = isD4Theme
        and IsActionBarUltimateWidgetEnabled()
        and GetThemeSetting("SHOW_ULTIMATE_BAR")
        and (GetThemeSetting("SHOW_ULTIMATE_BAR_BACKGROUND") ~= false)

    line:ClearAnchors()
    line:SetAnchor(BOTTOM, bgMiddle, BOTTOM, 0, offsetY)
    line:SetDimensions(width, height)

    if lineBg ~= nil then
        lineBg:ClearAnchors()
        -- Keep background attached to the ultimate bar so it always stays visible behind it.
        lineBg:SetAnchor(CENTER, line, CENTER, 0, bgOffsetY - offsetY)
        lineBg:SetDimensions(bgWidth, bgHeight)
        if isD4Theme then
            lineBg:SetTexture("DiabloOrbs/Themes/D4/Textures/fond_jauge.dds")
        else
            lineBg:SetTexture("DiabloOrbs/Textures/UltimateGaugeBackground.dds")
        end
        local bgAlpha = zo_max(0, zo_min(100, GetThemeSetting("ULTIMATE_BAR_BG_ALPHA"))) / 100
        lineBg:SetAlpha(bgAlpha)
        local ultBgR = GetThemeSetting("ULTIMATE_BAR_BG_COLOR_R")
        local ultBgG = GetThemeSetting("ULTIMATE_BAR_BG_COLOR_G")
        local ultBgB = GetThemeSetting("ULTIMATE_BAR_BG_COLOR_B")
        if isD4Theme then
            lineBg:SetColor(GetD4TintedColor(ultBgR, ultBgG, ultBgB))
        else
            lineBg:SetColor(ultBgR, ultBgG, ultBgB, 1)
        end
        lineBg:SetHidden(not showLineBg)
    end

    if lineValue ~= nil then
        lineValue:ClearAnchors()
        lineValue:SetAnchor(CENTER, line, CENTER, 0, 0)
    end
end

local function ApplyActionBarSlotScale(scale)
    local quickSlotButton = ZO_ActionBar_GetButton(1, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    if quickSlotButton and quickSlotButton.slot then
        quickSlotButton.slot:SetScale(scale)
    end

    for i = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + ACTION_BAR_SLOTS_PER_PAGE - 1 do
        local actionButton = ZO_ActionBar_GetButton(i)
        if actionButton and actionButton.slot then
            actionButton.slot:SetScale(scale)
        end
    end

    local ultimateButton = ZO_ActionBar_GetButton(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1)
    if ultimateButton and ultimateButton.slot then
        ultimateButton.slot:SetScale(scale)
    end
end

local function IsD4ShowOffbar()
    if SETTINGS == nil then
        return DEFAULT_SETTINGS.D4_SHOW_OFFBAR ~= false
    end
    local value = SETTINGS.D4_SHOW_OFFBAR
    if value == nil then
        value = DEFAULT_SETTINGS.D4_SHOW_OFFBAR
    end
    return value ~= false
end

local function IsActionBarCurrentlyDual()
    return IsD4ShowOffbar()
end

GetModeSpecificUltimateSettings = function(isDouble)
    local widthKey = isDouble and "ULTIMATE_BAR_DUAL_WIDTH_SCALE" or "ULTIMATE_BAR_SOLO_WIDTH_SCALE"
    local heightKey = isDouble and "ULTIMATE_BAR_DUAL_HEIGHT" or "ULTIMATE_BAR_SOLO_HEIGHT"
    local offsetKey = isDouble and "ULTIMATE_BAR_DUAL_OFFSET_Y" or "ULTIMATE_BAR_SOLO_OFFSET_Y"

    local widthScale = GetThemeSetting(widthKey)
    if widthScale == nil then
        widthScale = GetThemeSetting("ULTIMATE_BAR_WIDTH_SCALE")
    end

    local height = GetThemeSetting(heightKey)
    if height == nil then
        height = GetThemeSetting("ULTIMATE_BAR_HEIGHT")
    end

    local offsetY = GetThemeSetting(offsetKey)
    if offsetY == nil then
        offsetY = GetThemeSetting("ULTIMATE_BAR_OFFSET_Y")
    end

    return widthScale, height, offsetY
end

local function GetD4OrbBackplatePreset()
    return zo_max(0, zo_min(20, SETTINGS.D4_ORB_BACKPLATE_PRESET or DEFAULT_SETTINGS.D4_ORB_BACKPLATE_PRESET))
end

local function GetD4LayerAlpha(settingName)
    local value = SETTINGS[settingName]
    if value == nil then
        value = DEFAULT_SETTINGS[settingName]
    end
    return zo_max(0, zo_min(100, value or 100)) / 100
end

local function GetD4UnifiedOrbAlpha()
    local value = SETTINGS.D4_UNIFIED_ORB_ALPHA
    if value == nil then
        value = DEFAULT_SETTINGS.D4_UNIFIED_ORB_ALPHA
    end
    return zo_max(0, zo_min(100, value or 100)) / 100
end

local function IsD4LayerVisible(settingName)
    local value = SETTINGS[settingName]
    if value == nil then
        value = DEFAULT_SETTINGS[settingName]
    end
    return value ~= false
end

local function GetD4LayerScale(settingName)
    local value = SETTINGS[settingName]
    if value == nil then
        value = DEFAULT_SETTINGS[settingName]
    end
    return zo_max(50, zo_min(150, value or 100)) / 100
end

local function GetD4LayerOffset(settingName)
    local value = SETTINGS[settingName]
    if value == nil then
        value = DEFAULT_SETTINGS[settingName]
    end
    return value or 0
end

local function GetLegacyOrbLayerScale()
    local value = SETTINGS.LEGACY_ORB_LAYER_GLOBAL_SCALE
    if value == nil then
        value = DEFAULT_SETTINGS.LEGACY_ORB_LAYER_GLOBAL_SCALE
    end
    return zo_max(70, zo_min(180, value or 100)) / 100
end

local function GetCurrentOrbColorBoost()
    if ThemeManager:GetCurrentTheme() == "d4" then
        return SETTINGS.D4_ORB_COLOR_BOOST or DEFAULT_SETTINGS.D4_ORB_COLOR_BOOST
    end
    return SETTINGS.ORB_COLOR_BOOST or DEFAULT_SETTINGS.ORB_COLOR_BOOST
end

local function GetCurrentOrbBrightness()
    if ThemeManager:GetCurrentTheme() == "d4" then
        return SETTINGS.D4_ORB_BRIGHTNESS or DEFAULT_SETTINGS.D4_ORB_BRIGHTNESS
    end
    return SETTINGS.ORB_BRIGHTNESS or DEFAULT_SETTINGS.ORB_BRIGHTNESS
end

local function GetCurrentOrbTintLayerSettings()
    if ThemeManager:GetCurrentTheme() == "d4" then
        return SETTINGS.D4_ORB_TINT_LAYER_ENABLED == true,
               zo_max(0, zo_min(100, SETTINGS.D4_ORB_TINT_LAYER_ALPHA or DEFAULT_SETTINGS.D4_ORB_TINT_LAYER_ALPHA)) / 100,
               Clamp01(SETTINGS.D4_ORB_TINT_LAYER_COLOR_R or DEFAULT_SETTINGS.D4_ORB_TINT_LAYER_COLOR_R),
               Clamp01(SETTINGS.D4_ORB_TINT_LAYER_COLOR_G or DEFAULT_SETTINGS.D4_ORB_TINT_LAYER_COLOR_G),
               Clamp01(SETTINGS.D4_ORB_TINT_LAYER_COLOR_B or DEFAULT_SETTINGS.D4_ORB_TINT_LAYER_COLOR_B)
    end

    return SETTINGS.ORB_TINT_LAYER_ENABLED == true,
           zo_max(0, zo_min(100, SETTINGS.ORB_TINT_LAYER_ALPHA or DEFAULT_SETTINGS.ORB_TINT_LAYER_ALPHA)) / 100,
           Clamp01(SETTINGS.ORB_TINT_LAYER_COLOR_R or DEFAULT_SETTINGS.ORB_TINT_LAYER_COLOR_R),
           Clamp01(SETTINGS.ORB_TINT_LAYER_COLOR_G or DEFAULT_SETTINGS.ORB_TINT_LAYER_COLOR_G),
           Clamp01(SETTINGS.ORB_TINT_LAYER_COLOR_B or DEFAULT_SETTINGS.ORB_TINT_LAYER_COLOR_B)
end

local function IsShieldLabelEnabled()
    if ThemeManager:GetCurrentTheme() == "d4" then
        local value = SETTINGS.D4_SHOW_SHIELD_LABEL
        if value == nil then
            value = SETTINGS.SHOW_SHIELD_LABEL
        end
        if value == nil then
            value = DEFAULT_SETTINGS.D4_SHOW_SHIELD_LABEL
        end
        return value ~= false
    end

    local value = SETTINGS.SHOW_SHIELD_LABEL
    if value == nil then
        value = DEFAULT_SETTINGS.SHOW_SHIELD_LABEL
    end
    return value ~= false
end

local function GetShieldLabelOffsets()
    if ThemeManager:GetCurrentTheme() == "d4" then
        local x = SETTINGS.D4_SHIELD_LABEL_OFFSET_X
        local y = SETTINGS.D4_SHIELD_LABEL_OFFSET_Y
        if x == nil then
            x = SETTINGS.SHIELD_LABEL_OFFSET_X
        end
        if y == nil then
            y = SETTINGS.SHIELD_LABEL_OFFSET_Y
        end
        if x == nil then
            x = DEFAULT_SETTINGS.D4_SHIELD_LABEL_OFFSET_X
        end
        if y == nil then
            y = DEFAULT_SETTINGS.D4_SHIELD_LABEL_OFFSET_Y
        end
        return x, y
    end

    local x = SETTINGS.SHIELD_LABEL_OFFSET_X
    local y = SETTINGS.SHIELD_LABEL_OFFSET_Y
    if x == nil then
        x = DEFAULT_SETTINGS.SHIELD_LABEL_OFFSET_X
    end
    if y == nil then
        y = DEFAULT_SETTINGS.SHIELD_LABEL_OFFSET_Y
    end
    return x, y
end

local function GetShieldOpacity()
    if ThemeManager:GetCurrentTheme() == "d4" then
        local value = SETTINGS.D4_SHIELD_ALPHA
        if value == nil then
            value = SETTINGS.SHIELD_ALPHA
        end
        if value == nil then
            value = DEFAULT_SETTINGS.D4_SHIELD_ALPHA
        end
        return zo_max(0, zo_min(1, value))
    end

    local value = SETTINGS.SHIELD_ALPHA
    if value == nil then
        value = DEFAULT_SETTINGS.SHIELD_ALPHA
    end
    return zo_max(0, zo_min(1, value))
end

local function GetD4ShieldLayerLevel()
    local level = SETTINGS.D4_SHIELD_LAYER_LEVEL
    if level == nil then
        level = DEFAULT_SETTINGS.D4_SHIELD_LAYER_LEVEL
    end
    return zo_max(0, zo_min(20, zo_floor(level + 0.5)))
end

local function GetOrbColor(powerType)
    local isD4Theme = (ThemeManager:GetCurrentTheme() == "d4")
    if powerType == POWERTYPE_HEALTH then
        if isD4Theme then
            return SETTINGS.D4_HEALTH_COLOR_R or DEFAULT_SETTINGS.D4_HEALTH_COLOR_R,
                   SETTINGS.D4_HEALTH_COLOR_G or DEFAULT_SETTINGS.D4_HEALTH_COLOR_G,
                   SETTINGS.D4_HEALTH_COLOR_B or DEFAULT_SETTINGS.D4_HEALTH_COLOR_B
        end
        return SETTINGS.HEALTH_COLOR_R, SETTINGS.HEALTH_COLOR_G, SETTINGS.HEALTH_COLOR_B
    elseif powerType == POWERTYPE_MAGICKA or powerType == POWERTYPE_WEREWOLF then
        if isD4Theme then
            return SETTINGS.D4_MAGICKA_COLOR_R or DEFAULT_SETTINGS.D4_MAGICKA_COLOR_R,
                   SETTINGS.D4_MAGICKA_COLOR_G or DEFAULT_SETTINGS.D4_MAGICKA_COLOR_G,
                   SETTINGS.D4_MAGICKA_COLOR_B or DEFAULT_SETTINGS.D4_MAGICKA_COLOR_B
        end
        return SETTINGS.MAGICKA_COLOR_R, SETTINGS.MAGICKA_COLOR_G, SETTINGS.MAGICKA_COLOR_B
    elseif powerType == POWERTYPE_STAMINA or powerType == POWERTYPE_MOUNT_STAMINA then
        if isD4Theme then
            return SETTINGS.D4_STAMINA_COLOR_R or DEFAULT_SETTINGS.D4_STAMINA_COLOR_R,
                   SETTINGS.D4_STAMINA_COLOR_G or DEFAULT_SETTINGS.D4_STAMINA_COLOR_G,
                   SETTINGS.D4_STAMINA_COLOR_B or DEFAULT_SETTINGS.D4_STAMINA_COLOR_B
        end
        return SETTINGS.STAMINA_COLOR_R, SETTINGS.STAMINA_COLOR_G, SETTINGS.STAMINA_COLOR_B
    elseif powerType == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        if isD4Theme then
            return SETTINGS.D4_SHIELD_COLOR_R or DEFAULT_SETTINGS.D4_SHIELD_COLOR_R,
                   SETTINGS.D4_SHIELD_COLOR_G or DEFAULT_SETTINGS.D4_SHIELD_COLOR_G,
                   SETTINGS.D4_SHIELD_COLOR_B or DEFAULT_SETTINGS.D4_SHIELD_COLOR_B
        end
        return SETTINGS.SHIELD_COLOR_R, SETTINGS.SHIELD_COLOR_G, SETTINGS.SHIELD_COLOR_B
    end
    return 1, 1, 1
end

GetAutoDetectedD4BarMode = function(ctrl)
    return IsD4ShowOffbar() and "dual" or "solo"
end

local function RefreshAllBars()
    D4HealthSmokeAnchorY = nil
    VISUAL_SETTINGS_REV = VISUAL_SETTINGS_REV + 1
    for _, bar in ipairs(allBars) do
        bar:ApplySmokeAlpha()
        bar:ApplyAttributeLabel()
    end
end

local function GetBarByPowerType(powerType)
    for _, bar in ipairs(allBars) do
        if bar.powerType == powerType then
            return bar
        end
    end
    return nil
end

local function GetD4HealthSmokeFill()
    local healthBar = GetBarByPowerType(POWERTYPE_HEALTH)
    if healthBar == nil or healthBar.max == nil or healthBar.max == 0 then
        return nil
    end

    local orbSize = GetD4OrbSize()
    local percent = 0
    if healthBar.value >= healthBar.max then
        percent = 100
    else
        percent = zo_roundToNearest((healthBar.value / healthBar.max) * 100, 0.1)
    end

    percent = zo_max(0, percent - 3)
    local height = (orbSize / 100) * percent
    local anchorY = orbSize - height
    local coordTop = 1 - (percent / 100)

    return {
        percent = percent,
        height = height,
        anchorY = anchorY,
        coordTop = coordTop,
    }
end

local function GetBarVisualPercent(bar)
    if bar == nil then
        return 0
    end

    local percent = 0
    if bar.value >= bar.max then
        percent = 100
    elseif bar.max ~= nil and bar.max ~= 0 then
        percent = zo_roundToNearest((bar.value / bar.max) * 100, 0.1)
    end

    return zo_max(0, percent - 3)
end

local function GetRightOrbGlowVisual()
    local magickaBar = GetBarByPowerType(POWERTYPE_MAGICKA)
    local staminaBar = GetBarByPowerType(POWERTYPE_STAMINA)
    local threshold = SETTINGS.LOW_RESOURCE_WARNING_PERCENT or DEFAULT_SETTINGS.LOW_RESOURCE_WARNING_PERCENT
    local magickaLow = magickaBar ~= nil and GetBarVisualPercent(magickaBar) < threshold
    local staminaLow = staminaBar ~= nil and GetBarVisualPercent(staminaBar) < threshold

    if magickaLow and not staminaLow then
        local r, g, b = GetOrbColor(POWERTYPE_MAGICKA)
        return true, r, g, b
    end

    if staminaLow and not magickaLow then
        local r, g, b = GetOrbColor(POWERTYPE_STAMINA)
        return true, r, g, b
    end

    local mr, mg, mb = GetOrbColor(POWERTYPE_MAGICKA)
    local sr, sg, sb = GetOrbColor(POWERTYPE_STAMINA)
    return (magickaLow or staminaLow), (mr + sr) / 2, (mg + sg) / 2, (mb + sb) / 2
end

local function ApplyValueLabelAnchor(container, control, powerType, insideMode, labelGapX, labelOffsetY)
    if container == nil or control == nil then
        return
    end

    container:ClearAnchors()

    if insideMode then
        local swapInside = (GetThemeSetting("LABEL_INSIDE_SWAP_MANA_STAMINA") == true)
        local insideHealthOffsetX = GetThemeSetting("LABEL_INSIDE_HEALTH_OFFSET_X")
        if powerType == POWERTYPE_MAGICKA then
            container:SetAnchor(CENTER, control, CENTER, swapInside and labelGapX or (-labelGapX), labelOffsetY)
        elseif powerType == POWERTYPE_STAMINA then
            container:SetAnchor(CENTER, control, CENTER, swapInside and (-labelGapX) or labelGapX, labelOffsetY)
        else
            container:SetAnchor(CENTER, control, CENTER, insideHealthOffsetX, labelOffsetY)
        end
    else
        local outerPadX = GetThemeSetting("LABEL_OUTER_PADDING_X")
        local outerPadY = GetThemeSetting("LABEL_OUTER_PADDING_Y")
        if powerType == POWERTYPE_STAMINA then
            container:SetAnchor(TOPRIGHT, control, TOPRIGHT, outerPadX, outerPadY + labelOffsetY)
        else
            container:SetAnchor(TOPLEFT, control, TOPLEFT, -outerPadX, outerPadY + labelOffsetY)
        end
    end
end

local function ApplyValueLabelFont(label, scale, baseFontFile, baseFontHeight, baseFontStyle)
    if label == nil then
        return nil
    end

    local selectedNumberFont = GetNumberFontFile()
    local fontFile = selectedNumberFont or baseFontFile or "$(MEDIUM_FONT)"
    if DoesFileExist ~= nil and not FontFileExists(fontFile) then
        DebugPrint("ApplyValueLabelFont: selected font file not found, fallback to MEDIUM_FONT: " .. tostring(fontFile))
        fontFile = "$(MEDIUM_FONT)"
    end
    local fontHeight = tonumber(baseFontHeight) or 18
    local scaledHeight = zo_max(10, zo_floor((fontHeight * scale) + 0.5))
    local fontDescriptor = string.format("%s|%d", tostring(fontFile), scaledHeight)

    if baseFontStyle ~= nil and baseFontStyle ~= "" then
        fontDescriptor = fontDescriptor .. "|" .. tostring(baseFontStyle)
    end

    label:SetScale(1)
    label:SetFont(fontDescriptor)

    DebugPrint(string.format("ApplyValueLabelFont: fontFile='%s' scaledHeight=%d fontDescriptor='%s'", tostring(fontFile), scaledHeight, tostring(fontDescriptor)))

    return scaledHeight
end

local function ApplyValueLabelContainerSize(label, container, insideMode)
    if label == nil or container == nil then
        return
    end

    local textWidth, textHeight = label:GetTextDimensions()
    local padX = insideMode and 18 or 28
    local padY = insideMode and 10 or 14
    local minWidth = insideMode and 54 or 62
    local minHeight = insideMode and 28 or 30

    container:SetDimensions(
        zo_max(minWidth, textWidth + padX),
        zo_max(minHeight, textHeight + padY)
    )
end

local function ReadControlState(control)
    if control == nil then
        return "missing"
    end

    local hidden = "?"
    if control.IsHidden ~= nil then
        hidden = tostring(control:IsHidden())
    end

    local alpha = "?"
    if control.GetAlpha ~= nil then
        alpha = string.format("%.2f", control:GetAlpha())
    end

    local width, height = 0, 0
    if control.GetDimensions ~= nil then
        width, height = control:GetDimensions()
    end

    local texture = "n/a"
    if control.GetTextureFileName ~= nil then
        texture = control:GetTextureFileName() or ""
    end

    return string.format("hidden=%s alpha=%s size=%dx%d tex=%s", hidden, alpha, width or 0, height or 0, texture)
end

function DiabloOrbs.DebugD4BarState()
    local ctrl = DiabloOrbs._debugTopLevelCtrl
    if ctrl == nil then
        DebugPrint("Debug unavailable: top level control not initialized yet.")
        return
    end

    local theme = ThemeManager:GetCurrentTheme()
    local isDouble = IsD4ShowOffbar()
    local texturePath = GetD4BarTexturePath(isDouble)
    local bgMiddle = GetControl(ctrl, "ActionBarBgMiddle")
    local d4BarDecoration = GetControl(ctrl, "D4BarDecoration")
    local d4BarFallbackOverlay = GetControl(ctrl, "D4BarFallbackOverlay")
    local d4ExternalBar = _G[ctrl:GetName() .. "D4ExternalBar"]

    DebugPrint(string.format("theme=%s barre secondaire=%s isDouble=%s texture=%s", tostring(theme), tostring(isDouble), tostring(isDouble), tostring(texturePath)))
    DebugPrint("ActionBarBgMiddle -> " .. ReadControlState(bgMiddle))
    DebugPrint("D4BarDecoration -> " .. ReadControlState(d4BarDecoration))
    DebugPrint("D4BarFallbackOverlay -> " .. ReadControlState(d4BarFallbackOverlay))
    DebugPrint("D4ExternalBar -> " .. ReadControlState(d4ExternalBar))
end


local THEME_REDIRECT_TEXTURES = {
    "blank.dds",
    "ActionBarLeft.dds",
    "ActionBarMiddle.dds",
    "ActionBarRight.dds",
    "TooltipBorder.dds",
    "DiabloOrbsDualBarLeft.dds",
    "DiabloOrbsDualBarMiddle.dds",
    "DiabloOrbsDualBarRight.dds",
    "DiabloOrbsDualBarXpMiddle.dds",
    "DiabloOrbsDualBarXpLeft.dds",
    "DiabloOrbsDualBarXpRight.dds",
    "ActionBarXpMiddle.dds",
    "ActionBarXpLeft.dds",
    "ActionBarXpRight.dds",

    "Glow.dds",
    "glow_alert.dds",
    "Smoke.dds",
    "0/Shade.dds",
    "Border.dds",
    "Shield.dds",
    "Shield2.dds",
    "Shield3.dds",
    "Split.dds",
    "MountStamina.dds",
}

local function ApplyThemeTextureRedirects()
    for _, relativeTexture in ipairs(THEME_REDIRECT_TEXTURES) do
        local fromPath = "DiabloOrbs/Textures/" .. relativeTexture
        local toPath = ThemeManager:GetTexturePath(relativeTexture)
        RedirectTexture(fromPath, toPath)
    end
end

local function RefreshTheme(topLevelCtrl)
    ApplyThemeTextureRedirects()

    if styleManager ~= nil then
        styleManager:Apply()
    end
    ApplyThemeTexturesToControls(topLevelCtrl)

    -- Keep orb layer sizing authoritative after action-bar/layout refreshes.
    -- Without this pass, some controls can temporarily keep base dimensions
    -- until an orb-specific setting triggers RefreshAllBars().
    RefreshAllBars()


end

local function IsActionBarModuleEnabled()
    return SETTINGS == nil or SETTINGS.ENABLE_ACTION_BAR_MODULE ~= false
end

local function AreActionBarBackgroundsEnabled()
    return SETTINGS == nil or SETTINGS.SHOW_ACTION_BAR_BACKGROUNDS ~= false
end

local function AreActionBarSlotsEnabled()
    return IsActionBarModuleEnabled() and (SETTINGS == nil or SETTINGS.SHOW_ACTION_BAR_SLOTS ~= false)
end

IsActionBarUltimateWidgetEnabled = function()
    return SETTINGS == nil or SETTINGS.SHOW_ACTION_BAR_ULTIMATE_WIDGET ~= false
end

local function NormalizeActionBarHotkeyPosition(value)
    if type(value) ~= "string" then
        return DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_POSITION
    end

    local normalized = string.lower(zo_strtrim(value))
    if normalized == "top" or normalized == "haut" then
        return "top"
    end
    if normalized == "bottom" or normalized == "bas" then
        return "bottom"
    end
    if normalized == "inside"
        or normalized == "interior"
        or normalized == "inside_orb"
        or normalized == "center"
        or normalized == "centre"
        or normalized == "a l'interieur"
        or normalized == "a linterieur" then
        return "inside"
    end

    return DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_POSITION
end

local function NormalizeThemeKey(theme)
    if type(theme) ~= "string" then
        return ThemeManager.DEFAULT_THEME
    end

    local key = string.lower(theme)
    if key == "d4" then
        return "d4"
    end

    return "legacy"
end

-------------------------------------------------------------------------------------------------
-- BACKBAR : barre inactive affichée derrière la barre active en mode dual (D4)
-- Approche hybride optimisée :
-- - Icônes custom (event-driven, pas de timer)
-- - Timers cooldown natifs ESO (ActionBarTimerX) ancrés sur nos icônes custom
--   → zéro coût Lua, ESO gère les animations en C++ natif
-- - Dirty-check sur le layout : skip si aucun paramètre n'a changé
-- - Cache des refs de slots : pas de lookup _G dans les boucles
-- Prérequis : "Rangée arrière" activée dans Réglages > Combat ESO
-------------------------------------------------------------------------------------------------

local backbarContainer = nil
-- Tableau pré-alloué des refs de slots : [i] = { slotIndex, icon, glow, isUltimate }
local backbarSlotRefs = {}
-- Cache des derniers paramètres de layout pour le dirty-check
local backbarLayoutCache = {}

local BACKBAR_SLOT_COUNT = 6  -- 5 skills + 1 ultime

local function GetInactiveHotbarCategory()
    local active = GetActiveHotbarCategory and GetActiveHotbarCategory() or HOTBAR_CATEGORY_PRIMARY
    if active == HOTBAR_CATEGORY_PRIMARY then
        return HOTBAR_CATEGORY_BACKUP
    else
        return HOTBAR_CATEGORY_PRIMARY
    end
end

local function CreateBackbarContainer(topLevelCtrl)
    if backbarContainer ~= nil then return backbarContainer end

    local container = WINDOW_MANAGER:CreateControl(
        "DiabloOrbsBackBar", topLevelCtrl, CT_CONTROL)
    container:SetDrawLayer(DL_CONTROLS)
    container:SetDrawLevel(2)
    container:SetAnchor(BOTTOM, topLevelCtrl, BOTTOM, 0, 0)
    container:SetDimensions(400, 64)
    container:SetHidden(true)

    -- Précalcul des indices de slots (une seule fois)
    local slotIndices = {}
    for i = 1, ACTION_BAR_SLOTS_PER_PAGE - 1 do
        slotIndices[i] = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + i
    end
    slotIndices[BACKBAR_SLOT_COUNT] = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1

    for i = 1, BACKBAR_SLOT_COUNT do
        local slotIndex = slotIndices[i]
        local isUltimate = (slotIndex == ACTION_BAR_ULTIMATE_SLOT_INDEX + 1)

        local btn = WINDOW_MANAGER:CreateControl(
            "DiabloOrbsBackBarSlot" .. i, container, CT_CONTROL)
        btn:SetDimensions(42, 42)

        local icon = WINDOW_MANAGER:CreateControl(
            "DiabloOrbsBackBarSlot" .. i .. "Icon", btn, CT_TEXTURE)
        icon:SetDrawLayer(DL_CONTROLS)
        icon:SetDrawLevel(2)
        icon:SetAnchor(TOPLEFT, btn, TOPLEFT, 0, 0)
        icon:SetAnchor(BOTTOMRIGHT, btn, BOTTOMRIGHT, 0, 0)

        -- Stockage dans le tableau pré-alloué : pas de lookup _G en runtime
        backbarSlotRefs[i] = { btn = btn, icon = icon,
                                slotIndex = slotIndex, isUltimate = isUltimate }
    end

    backbarContainer = container
    return container
end


-- Met à jour les icônes — appelé sur events uniquement (pas de timer)
local function RefreshBackbarIcons()
    if backbarContainer == nil or backbarContainer:IsHidden() then return end
    if SETTINGS == nil then return end
    local inactiveCat = GetInactiveHotbarCategory()
    for i = 1, BACKBAR_SLOT_COUNT do
        local ref = backbarSlotRefs[i]
        if ref then
            local iconPath = GetSlotTexture(ref.slotIndex, inactiveCat)
            ref.icon:SetTexture((iconPath and iconPath ~= "") and iconPath or "EsoUI/Art/icons/icon_missing.dds")
        end
    end
end


-- Dirty-check : ne recalcule le layout que si les paramètres ont changé
local function ApplyBackbarLayout(topLevelCtrl)
    if SETTINGS == nil then return end
    local isD4 = (ThemeManager:GetCurrentTheme() == "d4")
    local showOffbar = IsD4ShowOffbar()
    local moduleEnabled = IsActionBarModuleEnabled()

    if not isD4 or not showOffbar or not moduleEnabled then
        if backbarContainer then backbarContainer:SetHidden(true) end
        return
    end

    local container = CreateBackbarContainer(topLevelCtrl)

    local offsetX  = SETTINGS.D4_BACKBAR_OFFSET_X       or DEFAULT_SETTINGS.D4_BACKBAR_OFFSET_X
    local offsetY  = SETTINGS.D4_BACKBAR_OFFSET_Y       or DEFAULT_SETTINGS.D4_BACKBAR_OFFSET_Y
    local alpha    = (SETTINGS.D4_BACKBAR_ALPHA          or DEFAULT_SETTINGS.D4_BACKBAR_ALPHA) / 100
    local desat    = (SETTINGS.D4_BACKBAR_DESATURATION   or DEFAULT_SETTINGS.D4_BACKBAR_DESATURATION) / 100
    local scale    = (SETTINGS.D4_BACKBAR_SCALE          or DEFAULT_SETTINGS.D4_BACKBAR_SCALE) / 100
    local slotSize = zo_round(SETTINGS.D4_BACKBAR_SLOT_SIZE  or DEFAULT_SETTINGS.D4_BACKBAR_SLOT_SIZE)
    local slotGap  = zo_round(SETTINGS.D4_BACKBAR_SLOT_GAP   or DEFAULT_SETTINGS.D4_BACKBAR_SLOT_GAP)
    local ultGap   = zo_round(SETTINGS.D4_BACKBAR_ULT_GAP    or DEFAULT_SETTINGS.D4_BACKBAR_ULT_GAP)
    local ultOffX  = zo_round(SETTINGS.D4_BACKBAR_ULT_OFFSET_X or DEFAULT_SETTINGS.D4_BACKBAR_ULT_OFFSET_X)
    local ultOffY  = zo_round(SETTINGS.D4_BACKBAR_ULT_OFFSET_Y or DEFAULT_SETTINGS.D4_BACKBAR_ULT_OFFSET_Y)

    -- Dirty-check : skip si rien n'a changé
    local c = backbarLayoutCache
    local layoutChanged = not (c.offsetX == offsetX and c.offsetY == offsetY and c.scale == scale
        and c.slotSize == slotSize and c.slotGap == slotGap
        and c.ultGap == ultGap and c.ultOffX == ultOffX and c.ultOffY == ultOffY
        and not container:IsHidden())

    if layoutChanged then
        c.offsetX = offsetX ; c.offsetY = offsetY ; c.scale = scale
        c.slotSize = slotSize ; c.slotGap = slotGap
        c.ultGap = ultGap ; c.ultOffX = ultOffX ; c.ultOffY = ultOffY

        container:ClearAnchors()
        container:SetAnchor(BOTTOM, topLevelCtrl, BOTTOM, offsetX, offsetY)
        container:SetScale(scale)

        local numSkills        = BACKBAR_SLOT_COUNT - 1
        local totalSkillsWidth = numSkills * slotSize + (numSkills - 1) * slotGap
        local halfSkills       = totalSkillsWidth / 2

        for i = 1, BACKBAR_SLOT_COUNT do
            local ref = backbarSlotRefs[i]
            if ref then
                ref.btn:SetDimensions(slotSize, slotSize)
                ref.btn:ClearAnchors()
                if ref.isUltimate then
                    ref.btn:SetAnchor(TOPLEFT, container, CENTER,
                        halfSkills + ultGap + ultOffX, -slotSize / 2 + ultOffY)
                else
                    ref.btn:SetAnchor(TOPLEFT, container, CENTER,
                        -halfSkills + (i - 1) * (slotSize + slotGap), -slotSize / 2)
                end
            end
        end
    end

    -- Alpha et désaturation : appliqués si changé
    if layoutChanged or c.alpha ~= alpha or c.desat ~= desat then
        c.alpha = alpha ; c.desat = desat
        for i = 1, BACKBAR_SLOT_COUNT do
            local ref = backbarSlotRefs[i]
            if ref then
                ref.icon:SetAlpha(alpha)
                ref.icon:SetDesaturation(desat)
            end
        end
    end

    container:SetHidden(false)
    RefreshBackbarIcons()
end

-------------------------------------------------------------------------------------------------
-- BACKBAR LEGACY : barre inactive affichée derrière la barre active en mode dual (Legacy)
-------------------------------------------------------------------------------------------------

local legacyBackbarContainer = nil
local legacyBackbarSlotRefs = {}
local legacyBackbarLayoutCache = {}

local function IsLegacyShowBackbar()
    if SETTINGS == nil then return DEFAULT_SETTINGS.LEGACY_SHOW_BACKBAR ~= false end
    local value = SETTINGS.LEGACY_SHOW_BACKBAR
    if value == nil then value = DEFAULT_SETTINGS.LEGACY_SHOW_BACKBAR end
    return value ~= false
end

-- Retourne le préfixe solo/dual Legacy selon l'état de la backbar
local function GetLegacyModePrefix()
    return IsLegacyShowBackbar() and "LEGACY_DUAL_" or "LEGACY_SOLO_"
end

local function CreateLegacyBackbarContainer(topLevelCtrl)
    if legacyBackbarContainer ~= nil then return legacyBackbarContainer end

    local container = WINDOW_MANAGER:CreateControl(
        "DiabloOrbsLegacyBackBar", topLevelCtrl, CT_CONTROL)
    container:SetDrawLayer(DL_CONTROLS)
    container:SetDrawLevel(2)
    container:SetAnchor(BOTTOM, topLevelCtrl, BOTTOM, 0, 0)
    container:SetDimensions(400, 64)
    container:SetHidden(true)

    local slotIndices = {}
    for i = 1, ACTION_BAR_SLOTS_PER_PAGE - 1 do
        slotIndices[i] = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + i
    end
    slotIndices[BACKBAR_SLOT_COUNT] = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1

    for i = 1, BACKBAR_SLOT_COUNT do
        local slotIndex = slotIndices[i]
        local isUltimate = (slotIndex == ACTION_BAR_ULTIMATE_SLOT_INDEX + 1)

        local btn = WINDOW_MANAGER:CreateControl(
            "DiabloOrbsLegacyBackBarSlot" .. i, container, CT_CONTROL)
        btn:SetDimensions(42, 42)

        local icon = WINDOW_MANAGER:CreateControl(
            "DiabloOrbsLegacyBackBarSlot" .. i .. "Icon", btn, CT_TEXTURE)
        icon:SetDrawLayer(DL_CONTROLS)
        icon:SetDrawLevel(2)
        icon:SetAnchor(TOPLEFT, btn, TOPLEFT, 0, 0)
        icon:SetAnchor(BOTTOMRIGHT, btn, BOTTOMRIGHT, 0, 0)

        legacyBackbarSlotRefs[i] = { btn = btn, icon = icon,
                                     slotIndex = slotIndex, isUltimate = isUltimate }
    end

    legacyBackbarContainer = container
    return container
end

local function RefreshLegacyBackbarIcons()
    if legacyBackbarContainer == nil or legacyBackbarContainer:IsHidden() then return end
    if SETTINGS == nil then return end
    local inactiveCat = GetInactiveHotbarCategory()
    for i = 1, BACKBAR_SLOT_COUNT do
        local ref = legacyBackbarSlotRefs[i]
        if ref then
            local iconPath = GetSlotTexture(ref.slotIndex, inactiveCat)
            ref.icon:SetTexture((iconPath and iconPath ~= "") and iconPath or "EsoUI/Art/icons/icon_missing.dds")
        end
    end
end

local function ApplyLegacyBackbarLayout(topLevelCtrl)
    if SETTINGS == nil then return end
    local isLegacy = (ThemeManager:GetCurrentTheme() == "legacy")
    local showBackbar = IsLegacyShowBackbar()
    local moduleEnabled = IsActionBarModuleEnabled()

    if not isLegacy or not showBackbar or not moduleEnabled then
        if legacyBackbarContainer then legacyBackbarContainer:SetHidden(true) end
        return
    end

    local container = CreateLegacyBackbarContainer(topLevelCtrl)

    local offsetX  = SETTINGS.LEGACY_BACKBAR_OFFSET_X       or DEFAULT_SETTINGS.LEGACY_BACKBAR_OFFSET_X
    local offsetY  = SETTINGS.LEGACY_BACKBAR_OFFSET_Y       or DEFAULT_SETTINGS.LEGACY_BACKBAR_OFFSET_Y
    local alpha    = (SETTINGS.LEGACY_BACKBAR_ALPHA          or DEFAULT_SETTINGS.LEGACY_BACKBAR_ALPHA) / 100
    local desat    = (SETTINGS.LEGACY_BACKBAR_DESATURATION   or DEFAULT_SETTINGS.LEGACY_BACKBAR_DESATURATION) / 100
    local scale    = (SETTINGS.LEGACY_BACKBAR_SCALE          or DEFAULT_SETTINGS.LEGACY_BACKBAR_SCALE) / 100
    local slotSize = zo_round(SETTINGS.LEGACY_BACKBAR_SLOT_SIZE  or DEFAULT_SETTINGS.LEGACY_BACKBAR_SLOT_SIZE)
    local slotGap  = zo_round(SETTINGS.LEGACY_BACKBAR_SLOT_GAP   or DEFAULT_SETTINGS.LEGACY_BACKBAR_SLOT_GAP)
    local ultGap   = zo_round(SETTINGS.LEGACY_BACKBAR_ULT_GAP    or DEFAULT_SETTINGS.LEGACY_BACKBAR_ULT_GAP)
    local ultOffX  = zo_round(SETTINGS.LEGACY_BACKBAR_ULT_OFFSET_X or DEFAULT_SETTINGS.LEGACY_BACKBAR_ULT_OFFSET_X)
    local ultOffY  = zo_round(SETTINGS.LEGACY_BACKBAR_ULT_OFFSET_Y or DEFAULT_SETTINGS.LEGACY_BACKBAR_ULT_OFFSET_Y)

    local c = legacyBackbarLayoutCache
    local layoutChanged = not (c.offsetX == offsetX and c.offsetY == offsetY and c.scale == scale
        and c.slotSize == slotSize and c.slotGap == slotGap
        and c.ultGap == ultGap and c.ultOffX == ultOffX and c.ultOffY == ultOffY
        and not container:IsHidden())

    if layoutChanged then
        c.offsetX = offsetX ; c.offsetY = offsetY ; c.scale = scale
        c.slotSize = slotSize ; c.slotGap = slotGap
        c.ultGap = ultGap ; c.ultOffX = ultOffX ; c.ultOffY = ultOffY

        container:ClearAnchors()
        container:SetAnchor(BOTTOM, topLevelCtrl, BOTTOM, offsetX, offsetY)
        container:SetScale(scale)

        local numSkills        = BACKBAR_SLOT_COUNT - 1
        local totalSkillsWidth = numSkills * slotSize + (numSkills - 1) * slotGap
        local halfSkills       = totalSkillsWidth / 2

        for i = 1, BACKBAR_SLOT_COUNT do
            local ref = legacyBackbarSlotRefs[i]
            if ref then
                ref.btn:SetDimensions(slotSize, slotSize)
                ref.btn:ClearAnchors()
                if ref.isUltimate then
                    ref.btn:SetAnchor(TOPLEFT, container, CENTER,
                        halfSkills + ultGap + ultOffX, -slotSize / 2 + ultOffY)
                else
                    ref.btn:SetAnchor(TOPLEFT, container, CENTER,
                        -halfSkills + (i - 1) * (slotSize + slotGap), -slotSize / 2)
                end
            end
        end
    end

    c.alpha = alpha ; c.desat = desat
    for i = 1, BACKBAR_SLOT_COUNT do
        local ref = legacyBackbarSlotRefs[i]
        if ref then
            ref.icon:SetAlpha(alpha)
            ref.icon:SetDesaturation(desat)
        end
    end

    container:SetHidden(false)
    RefreshLegacyBackbarIcons()
end

-- Applique directement les textures du th�me actif sur tous les contr�les nomm�s.
-- Contourne la limitation de RedirectTexture() qui ne met pas � jour les contr�les d�j� charg�s.
ApplyThemeTexturesToControls = function(ctrl)
    local bgMiddle = GetControl(ctrl, "ActionBarBgMiddle")
    local bgLeft = GetControl(ctrl, "ActionBarBgLeft")
    local bgRight = GetControl(ctrl, "ActionBarBgRight")
    local actionBarContainer = GetControl(ctrl, "ActionBarContainer")
    local line = GetControl(ctrl, "Line")
    local lineBg = _G[ctrl:GetName() .. "LineBackground"]
    local lineValue = GetOrCreateUltimateTextLabel(ctrl)
    local d4BarDecoration = GetControl(ctrl, "D4BarDecoration")
    local d4BarFallbackOverlay = GetControl(ctrl, "D4BarFallbackOverlay")
    local externalName = ctrl:GetName() .. "D4ExternalBar"
    local externalBar = _G[externalName]

    if not IsActionBarModuleEnabled() then
        if actionBarContainer then actionBarContainer:SetHidden(true) end
    end

    if ctrl ~= nil and ctrl.SetScale ~= nil then
        if ThemeManager:GetCurrentTheme() == "legacy" then
            ctrl:SetScale(GetLegacyInterfaceScale())
        else
            ctrl:SetScale(1)
        end
    end

    if ThemeManager:GetCurrentTheme() == "legacy" then
        local mp = GetLegacyModePrefix()
        local legacyOrbOffsetY = SETTINGS[mp.."ORB_OFFSET_Y"] or DEFAULT_SETTINGS[mp.."ORB_OFFSET_Y"]
        local legacyOrbOffsetX = SETTINGS[mp.."ORB_OFFSET_X"] or DEFAULT_SETTINGS[mp.."ORB_OFFSET_X"]
        local bgLeft  = GetControl(ctrl, "ActionBarBgLeft")
        local bgRight = GetControl(ctrl, "ActionBarBgRight")
        local healthOrb    = GetControl(ctrl, "Health")
        local doubleBarOrb = GetControl(ctrl, "DoubleBar")
        if healthOrb and bgLeft then
            healthOrb:ClearAnchors()
            healthOrb:SetAnchor(BOTTOMLEFT, bgLeft, BOTTOMLEFT, legacyOrbOffsetX, -16 - legacyOrbOffsetY)
        end
        if doubleBarOrb and bgRight then
            doubleBarOrb:ClearAnchors()
            doubleBarOrb:SetAnchor(BOTTOMRIGHT, bgRight, BOTTOMRIGHT, -legacyOrbOffsetX, -17 - legacyOrbOffsetY)
        end
        if externalBar then
            externalBar:SetHidden(true)
        end
        if actionBarContainer and IsActionBarModuleEnabled() then actionBarContainer:SetHidden(false) end
        -- Fond de barre Legacy : solo ou dual
        if bgMiddle then
            local bgLeftL  = GetControl(ctrl, "ActionBarBgLeft")
            local bgRightL = GetControl(ctrl, "ActionBarBgRight")
            local isDual = IsLegacyShowBackbar()
            local prefix = isDual and "LEGACY_BG_DUAL_" or "LEGACY_BG_SOLO_"
            local mW   = SETTINGS[prefix.."MIDDLE_WIDTH"]    or DEFAULT_SETTINGS[prefix.."MIDDLE_WIDTH"]
            local mH   = SETTINGS[prefix.."MIDDLE_HEIGHT"]   or DEFAULT_SETTINGS[prefix.."MIDDLE_HEIGHT"]
            local mOX  = SETTINGS[prefix.."MIDDLE_OFFSET_X"] or DEFAULT_SETTINGS[prefix.."MIDDLE_OFFSET_X"]
            local mOY  = SETTINGS[prefix.."MIDDLE_OFFSET_Y"] or DEFAULT_SETTINGS[prefix.."MIDDLE_OFFSET_Y"]
            local lOX  = SETTINGS[prefix.."LEFT_OFFSET_X"]   or DEFAULT_SETTINGS[prefix.."LEFT_OFFSET_X"]
            local rOX  = SETTINGS[prefix.."RIGHT_OFFSET_X"]  or DEFAULT_SETTINGS[prefix.."RIGHT_OFFSET_X"]
            if isDual then
                bgMiddle:SetTexture(ThemeManager:GetTexturePath("DiabloOrbsDualBarXpMiddle.dds"))
                if bgLeftL  then bgLeftL:SetTexture(ThemeManager:GetTexturePath("DiabloOrbsDualBarXpLeft.dds"))  end
                if bgRightL then bgRightL:SetTexture(ThemeManager:GetTexturePath("DiabloOrbsDualBarXpRight.dds")) end
            else
                bgMiddle:SetTexture(ThemeManager:GetTexturePath("ActionBarXpMiddle.dds"))
                if bgLeftL  then bgLeftL:SetTexture(ThemeManager:GetTexturePath("ActionBarXpLeft.dds"))  end
                if bgRightL then bgRightL:SetTexture(ThemeManager:GetTexturePath("ActionBarXpRight.dds")) end
            end
            bgMiddle:SetDimensions(mW, mH)
            bgMiddle:ClearAnchors()
            bgMiddle:SetAnchor(CENTER, ctrl, CENTER, mOX, mOY)
            if bgLeftL then
                bgLeftL:ClearAnchors()
                bgLeftL:SetAnchor(BOTTOMRIGHT, bgMiddle, BOTTOMLEFT, lOX, 0)
            end
            if bgRightL then
                bgRightL:ClearAnchors()
                bgRightL:SetAnchor(BOTTOMLEFT, bgMiddle, BOTTOMRIGHT, rOX, 0)
            end
        end
        ApplyUltimateBarLayout(ctrl, IsLegacyShowBackbar())
        if line then line:SetHidden(not GetThemeSetting("SHOW_ULTIMATE_BAR")) end
        if lineBg then
            lineBg:SetHidden(true)
        end
        if lineValue then lineValue:SetHidden((not GetThemeSetting("SHOW_ULTIMATE_BAR")) or (not SETTINGS.SHOW_ULTIMATE_TEXT)) end

        -- Décorations Legacy : Angel (droite) et Demon (gauche)
        do
            local angel = GetControl(ctrl, "LegacyDecoAngel")
            local demon  = GetControl(ctrl, "LegacyDecoDemon")
            local visible    = SETTINGS.LEGACY_DECO_VISIBLE ~= false
            local size       = SETTINGS.LEGACY_DECO_SIZE    or DEFAULT_SETTINGS.LEGACY_DECO_SIZE
            local widthPct   = (SETTINGS.LEGACY_DECO_WIDTH  or DEFAULT_SETTINGS.LEGACY_DECO_WIDTH)  / 100
            local heightPct  = (SETTINGS.LEGACY_DECO_HEIGHT or DEFAULT_SETTINGS.LEGACY_DECO_HEIGHT) / 100
            local gapX       = SETTINGS.LEGACY_DECO_GAP_X   or DEFAULT_SETTINGS.LEGACY_DECO_GAP_X
            local offsetY    = SETTINGS.LEGACY_DECO_OFFSET_Y or DEFAULT_SETTINGS.LEGACY_DECO_OFFSET_Y
            local foreground = SETTINGS.LEGACY_DECO_FOREGROUND == true
            local mirror     = SETTINGS.LEGACY_DECO_MIRROR == true
            local drawLevel  = foreground and 501 or 0
            local w = zo_floor(size * widthPct + 0.5)
            local h = zo_floor(size * heightPct + 0.5)
            -- Mirror : Angel va à gauche, Demon à droite
            local leftCtrl  = mirror and angel or demon
            local rightCtrl = mirror and demon or angel
            if leftCtrl then
                leftCtrl:SetHidden(not visible)
                if visible then
                    leftCtrl:SetDrawLevel(drawLevel)
                    leftCtrl:SetDimensions(w, h)
                    leftCtrl:ClearAnchors()
                    leftCtrl:SetAnchor(BOTTOM, ctrl, BOTTOM, -gapX, offsetY)
                end
            end
            if rightCtrl then
                rightCtrl:SetHidden(not visible)
                if visible then
                    rightCtrl:SetDrawLevel(drawLevel)
                    rightCtrl:SetDimensions(w, h)
                    rightCtrl:ClearAnchors()
                    rightCtrl:SetAnchor(BOTTOM, ctrl, BOTTOM, gapX, offsetY)
                end
            end
        end

        return
    end

    local isD4 = (ThemeManager:GetCurrentTheme() == "d4")
    local orbBorderTexture = isD4 and "D4OrbBorder.dds" or "Border.dds"
    local orbGlowTexture = "Glow.dds"
    local orbGlowAlertTexture = "glow_alert.dds"
    local orbBgTexture = isD4 and "D4OrbFill.dds" or "Smoke.dds"
    local orbFillTexture = "Smoke.dds"
    local orbShadeTexture = isD4 and "D4OrbShadow.dds" or "0/Shade.dds"

    local function setTex(parent, childName, texName)
        local child = GetControl(parent, childName)
        if child then
            child:SetTexture(ThemeManager:GetTexturePath(texName))
        end
    end

    local function applyLegacyLikeLabelAnchors(healthCtrl, magickaCtrl, staminaCtrl)
        local rawLabelPosition = string.lower(zo_strtrim(tostring(GetThemeSetting("LABEL_POSITION_MODE") or "outside")))
        local insideMode = (rawLabelPosition == "inside" or rawLabelPosition == "interior" or rawLabelPosition == "inside_orb")
        local labelGapX = GetThemeSetting("LABEL_CENTER_GAP_X")
        local labelOffsetY = GetThemeSetting("LABEL_OFFSET_Y")
        if healthCtrl then
            local healthLabel = GetControl(healthCtrl, "Label")
            if healthLabel and healthLabel:GetParent() then
                local c = healthLabel:GetParent()
                ApplyValueLabelAnchor(c, healthCtrl, POWERTYPE_HEALTH, insideMode, labelGapX, labelOffsetY)
            end
        end
        if magickaCtrl then
            local magickaLabel = GetControl(magickaCtrl, "Label")
            if magickaLabel and magickaLabel:GetParent() then
                local c = magickaLabel:GetParent()
                ApplyValueLabelAnchor(c, magickaCtrl, POWERTYPE_MAGICKA, insideMode, labelGapX, labelOffsetY)
            end
        end
        if staminaCtrl then
            local staminaLabel = GetControl(staminaCtrl, "Label")
            if staminaLabel and staminaLabel:GetParent() then
                local c = staminaLabel:GetParent()
                ApplyValueLabelAnchor(c, staminaCtrl, POWERTYPE_STAMINA, insideMode, labelGapX, labelOffsetY)
            end
        end
    end

    local function getOrCreateD4BarDecoration()
        local deco = GetControl(ctrl, "D4BarDecoration")
        if deco == nil then
            local name = ctrl:GetName() .. "D4BarDecoration"
            deco = WINDOW_MANAGER:CreateControl(name, ctrl, CT_TEXTURE)
        end
        deco:SetDrawLayer(1)
        deco:SetDrawLevel(2)
        deco:SetMouseEnabled(false)
        return deco
    end

    local function getOrCreateD4OrbBackplate(childSuffix)
        local name = ctrl:GetName() .. childSuffix
        local backplate = GetControl(ctrl, childSuffix)
        if backplate == nil then
            backplate = WINDOW_MANAGER:CreateControl(name, ctrl, CT_TEXTURE)
            backplate:SetDrawLayer(1)
            backplate:SetDrawLevel(1)
        end
        return backplate
    end

    local function getOrCreateD4BarFallbackOverlay()
        local overlay = GetControl(ctrl, "D4BarFallbackOverlay")
        if overlay == nil then
            local name = ctrl:GetName() .. "D4BarFallbackOverlay"
            overlay = WINDOW_MANAGER:CreateControl(name, ctrl, CT_TEXTURE)
        end
        overlay:SetDrawLayer(1)
        overlay:SetDrawLevel(0)
        overlay:SetMouseEnabled(false)
        return overlay
    end

    local function getOrCreateD4ExternalBar()
        local name = ctrl:GetName() .. "D4ExternalBar"
        local external = _G[name]
        if external == nil then
            external = WINDOW_MANAGER:CreateControl(name, GuiRoot, CT_TEXTURE)
        end
        external:SetDrawLayer(1)
        external:SetDrawLevel(0)
        external:SetMouseEnabled(false)
        return external
    end

    -- Masquer les décorations Legacy (Angel/Demon) en mode D4
    do
        local a = GetControl(ctrl, "LegacyDecoAngel")
        local d = GetControl(ctrl, "LegacyDecoDemon")
        if a then a:SetHidden(true) end
        if d then d:SetHidden(true) end
    end

    -- Déclaration des contrôles d'orbes (toujours nécessaires pour le bloc barre D4)
    local health  = GetControl(ctrl, "Health")
    local shield  = GetControl(ctrl, "Shield")
    local magicka = GetControl(ctrl, "Magicka")
    local stamina = GetControl(ctrl, "Stamina")
    local werewolf = GetControl(ctrl, "WerewolfTimer")
    local mountSta = GetControl(ctrl, "MountStamina")

    -- Textures orbes (uniquement au boot/changement de thème, pas sur ACTION_SLOTS_FULL_UPDATE)
    if health then
            setTex(health, "Glow",       orbGlowTexture)
            setTex(health, "SmokeBg",    orbBgTexture)
            setTex(health, "Smoke",      orbFillTexture)
            setTex(health, "BorderShade",orbShadeTexture)
            setTex(health, "Border",     orbBorderTexture)
            if isD4 then setTex(health, "BorderOverlay", "D4OrbBorderOverlay.dds") end
            if isD4 then setTex(health, "AdditiveOverlay", "D4OrbBack2.dds") end
        end
        if shield then
            setTex(shield, "Smoke", "Shield3.dds")
        end
        if magicka then
            setTex(magicka, "Glow",       orbGlowTexture)
            setTex(magicka, "SmokeBg",    orbBgTexture)
            setTex(magicka, "Smoke",      orbFillTexture)
            setTex(magicka, "BorderShade",orbShadeTexture)
            setTex(magicka, "Border",     orbBorderTexture)
            setTex(magicka, "Split",      "Split.dds")
            if isD4 then setTex(magicka, "BorderOverlay", "D4OrbBorderOverlay.dds") end
            if isD4 then setTex(magicka, "AdditiveOverlay", "D4OrbBack2.dds") end
        end
        if stamina then
            setTex(stamina, "Glow",   orbGlowTexture)
            setTex(stamina, "SmokeBg",orbBgTexture)
            setTex(stamina, "Smoke",  orbFillTexture)
            if isD4 then setTex(stamina, "AdditiveOverlay", "D4OrbBack2.dds") end
        end
        if werewolf then setTex(werewolf, "Smoke", "MountStamina.dds") end
        if mountSta then setTex(mountSta, "Smoke", "MountStamina.dds") end

    -- Fond de la barre d'action (apres ApplyTemplateToControl)
    local bgMiddle = GetControl(ctrl, "ActionBarBgMiddle")
    local isDouble = false
    if bgMiddle then
        isDouble = isD4 and IsD4ShowOffbar() or (not isD4 and IsLegacyShowBackbar())
        local bgLeft  = GetControl(ctrl, "ActionBarBgLeft")
        local bgRight = GetControl(ctrl, "ActionBarBgRight")
        local d4BarDecoration = getOrCreateD4BarDecoration()
        local d4BarFallbackOverlay = getOrCreateD4BarFallbackOverlay()
        local d4ExternalBar = getOrCreateD4ExternalBar()
        local d4OrbBackplateLeft = getOrCreateD4OrbBackplate("D4OrbBackplateLeft")
        local d4OrbBackplateRight = getOrCreateD4OrbBackplate("D4OrbBackplateRight")

        if bgLeft then bgLeft:SetHidden(false) end
        if bgRight then bgRight:SetHidden(false) end
        if d4BarDecoration then d4BarDecoration:SetHidden(true) end
        if d4BarFallbackOverlay then d4BarFallbackOverlay:SetHidden(true) end
        if d4ExternalBar then d4ExternalBar:SetHidden(true) end
        if d4OrbBackplateLeft then d4OrbBackplateLeft:SetHidden(true) end
        if d4OrbBackplateRight then d4OrbBackplateRight:SetHidden(true) end

        if isDouble then
            bgMiddle:SetTexture(ThemeManager:GetTexturePath("DiabloOrbsDualBarXpMiddle.dds"))
            if bgLeft  then bgLeft:SetTexture(ThemeManager:GetTexturePath("DiabloOrbsDualBarXpLeft.dds"))  end
            if bgRight then bgRight:SetTexture(ThemeManager:GetTexturePath("DiabloOrbsDualBarXpRight.dds")) end
        else
            bgMiddle:SetTexture(ThemeManager:GetTexturePath("ActionBarXpMiddle.dds"))
            if bgLeft  then bgLeft:SetTexture(ThemeManager:GetTexturePath("ActionBarXpLeft.dds"))  end
            if bgRight then bgRight:SetTexture(ThemeManager:GetTexturePath("ActionBarXpRight.dds")) end
        end

        if isD4 then
            local doubleBar = GetControl(ctrl, "DoubleBar")
            local actionBarContainer = GetControl(ctrl, "ActionBarContainer")
            -- Lecture des valeurs solo/dual selon le mode actif
            local d4InsetX, d4OffsetY, d4BarOffsetY
            if isDouble then
                d4InsetX    = SETTINGS.D4_DUAL_ORB_INSET_X  or DEFAULT_SETTINGS.D4_DUAL_ORB_INSET_X
                d4OffsetY   = SETTINGS.D4_DUAL_ORB_OFFSET_Y or DEFAULT_SETTINGS.D4_DUAL_ORB_OFFSET_Y
                d4BarOffsetY = SETTINGS.D4_DUAL_BAR_OFFSET_Y or DEFAULT_SETTINGS.D4_DUAL_BAR_OFFSET_Y
            else
                d4InsetX    = SETTINGS.D4_SOLO_ORB_INSET_X  or DEFAULT_SETTINGS.D4_SOLO_ORB_INSET_X
                d4OffsetY   = SETTINGS.D4_SOLO_ORB_OFFSET_Y or DEFAULT_SETTINGS.D4_SOLO_ORB_OFFSET_Y
                d4BarOffsetY = SETTINGS.D4_SOLO_BAR_OFFSET_Y or DEFAULT_SETTINGS.D4_SOLO_BAR_OFFSET_Y
            end
            local d4FinalInsetX = d4InsetX
            local d4BarWidth, d4BarHeight = GetD4BarDimensions(isDouble)
            local d4BarTexturePath = GetD4BarTexturePath(isDouble)
            local d4BarBrightness = GetD4BarBrightnessMultiplier()
            local d4OrbBackplatePreset = GetD4OrbBackplatePreset()
            local d4OrbBackplateTexturePreset = zo_max(0, zo_min(10, d4OrbBackplatePreset))
            local d4OrbBackplateBrightness = 1
            if d4OrbBackplatePreset > 10 then
                d4OrbBackplateBrightness = 1 + ((d4OrbBackplatePreset - 10) / 10) * 0.35
            end
            local orbSize = GetD4OrbSize()
            local halfOrbSize = zo_floor((orbSize / 2) + 0.5)
            local borderSize = orbSize
            local orbBackplateWidth = zo_floor((orbSize * 230 / 150) + 0.5)
            local orbBackplateHeight = zo_floor((orbSize * 108 / 150) + 0.5)
            -- Phase 2 anchor model: backplates follow orb global placement/size.
            local backplateAnchorX = d4InsetX
            local backplateAnchorY = d4OffsetY - 2
            local backplateWidthScale = 0.60
            local backplateHeightScale = 0.60
            local scaledBackplateWidth = orbBackplateWidth * backplateWidthScale
            local scaledBackplateHeight = orbBackplateHeight * backplateHeightScale

            bgMiddle:ClearAnchors()
            bgMiddle:SetAnchor(BOTTOM, ctrl, BOTTOM, 0, d4BarOffsetY)
            bgMiddle:SetTexture(d4BarTexturePath)
            bgMiddle:SetDimensions(d4BarWidth, d4BarHeight)
            bgMiddle:SetTextureCoords(0, 1, 0, 1)
            bgMiddle:SetColor(GetD4TintedColor(d4BarBrightness))
            bgMiddle:SetHidden(false)
            bgMiddle:SetAlpha(1)

            if d4BarDecoration then
                d4BarDecoration:ClearAnchors()
                d4BarDecoration:SetAnchor(BOTTOM, ctrl, BOTTOM, 0, d4BarOffsetY)
                d4BarDecoration:SetTexture(d4BarTexturePath)
                d4BarDecoration:SetDimensions(d4BarWidth, d4BarHeight)
                d4BarDecoration:SetTextureCoords(0, 1, 0, 1)
                d4BarDecoration:SetColor(GetD4TintedColor(d4BarBrightness))
                d4BarDecoration:SetAlpha(1)
                d4BarDecoration:SetHidden(false)
            end

            if d4BarFallbackOverlay then
                d4BarFallbackOverlay:ClearAnchors()
                d4BarFallbackOverlay:SetAnchor(BOTTOM, ctrl, BOTTOM, 0, d4BarOffsetY)
                d4BarFallbackOverlay:SetTexture(d4BarTexturePath)
                d4BarFallbackOverlay:SetDimensions(d4BarWidth, d4BarHeight)
                d4BarFallbackOverlay:SetTextureCoords(0, 1, 0, 1)
                d4BarFallbackOverlay:SetColor(GetD4TintedColor(d4BarBrightness))
                d4BarFallbackOverlay:SetAlpha(1)
                d4BarFallbackOverlay:SetHidden(false)
            end

            if d4ExternalBar then
                d4ExternalBar:ClearAnchors()
                d4ExternalBar:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 0, d4BarOffsetY)
                d4ExternalBar:SetTexture(d4BarTexturePath)
                d4ExternalBar:SetDimensions(d4BarWidth, d4BarHeight)
                d4ExternalBar:SetTextureCoords(0, 1, 0, 1)
                d4ExternalBar:SetColor(GetD4TintedColor(d4BarBrightness))
                d4ExternalBar:SetAlpha(1)
                d4ExternalBar:SetHidden(false)
            end

            if actionBarContainer then
                actionBarContainer:ClearAnchors()
                if isDouble then
                    local barHost = d4BarDecoration or bgMiddle
                    actionBarContainer:SetAnchor(BOTTOMLEFT, barHost, BOTTOMLEFT, 12, 10)
                    actionBarContainer:SetAnchor(BOTTOMRIGHT, barHost, BOTTOMRIGHT, -12, 10)
                else
                    local barHost = d4BarDecoration or bgMiddle
                    actionBarContainer:SetAnchor(BOTTOMLEFT, barHost, BOTTOMLEFT, 10, 7)
                    actionBarContainer:SetAnchor(BOTTOMRIGHT, barHost, BOTTOMRIGHT, -10, 7)
                end
            end
            if bgLeft then
                bgLeft:SetTexture(ThemeManager:GetTexturePath("blank.dds"))
                bgLeft:SetHidden(true)
            end
            if bgRight then
                bgRight:SetTexture(ThemeManager:GetTexturePath("blank.dds"))
                bgRight:SetHidden(true)
            end

            -- D4-specific orb positioning: keep the unified orb system independent
            -- from the action bar artwork and its host controls.

            -- Bloc gauche (health)
            if health then
                health:SetDimensions(orbSize, orbSize)
                health:ClearAnchors()
                health:SetAnchor(BOTTOM, ctrl, BOTTOM, -d4FinalInsetX, d4OffsetY)

                local healthBorder = GetControl(health, "Border")
                if healthBorder then healthBorder:SetDimensions(borderSize, borderSize) end
                local healthBorderOverlay = GetControl(health, "BorderOverlay")
                if healthBorderOverlay then healthBorderOverlay:SetDimensions(borderSize, borderSize) end
                local healthShade = GetControl(health, "BorderShade")
                if healthShade then healthShade:SetDimensions(orbSize, orbSize) end
                local healthGlow = GetControl(health, "Glow")
                if healthGlow then healthGlow:SetDimensions(orbSize, orbSize) end
                local healthSmoke = GetControl(health, "Smoke")
                if healthSmoke then healthSmoke:SetWidth(orbSize) end
                local healthSmokeBg = GetControl(health, "SmokeBg")
                if healthSmokeBg then healthSmokeBg:SetWidth(orbSize) end
            end

            -- Bloc droit (doubleBar = mana+endu soudées)
            if doubleBar then
                doubleBar:SetDimensions(orbSize, orbSize)
                doubleBar:ClearAnchors()
                doubleBar:SetAnchor(BOTTOM, ctrl, BOTTOM, d4FinalInsetX, d4OffsetY)

                -- Magicka and stamina orbs are always centered in doubleBar
                if magicka then
                    magicka:SetDimensions(orbSize, orbSize)
                    magicka:ClearAnchors()
                    magicka:SetAnchor(CENTER, doubleBar, CENTER, 0, 0)
                    local magickaBorder = GetControl(magicka, "Border")
                    if magickaBorder then magickaBorder:SetDimensions(borderSize, borderSize) end
                    local magickaBorderOverlay = GetControl(magicka, "BorderOverlay")
                    if magickaBorderOverlay then magickaBorderOverlay:SetDimensions(borderSize, borderSize) end
                    local magickaShade = GetControl(magicka, "BorderShade")
                    if magickaShade then magickaShade:SetDimensions(orbSize, orbSize) end
                    local magickaSplit = GetControl(magicka, "Split")
                    if magickaSplit then magickaSplit:SetDimensions(borderSize, borderSize) end
                    local magickaGlow = GetControl(magicka, "Glow")
                    if magickaGlow then magickaGlow:SetDimensions(orbSize, orbSize) end
                    -- Les couches Smoke/SmokeBg sont gérées dans leur propre logique (décalage par D4_FILL_LAYER_OFFSET_X)
                    local magickaSmoke = GetControl(magicka, "Smoke")
                    if magickaSmoke then magickaSmoke:SetDimensions(halfOrbSize, orbSize) end
                    local magickaSmokeBg = GetControl(magicka, "SmokeBg")
                    if magickaSmokeBg then magickaSmokeBg:SetDimensions(halfOrbSize, orbSize) end
                end

                if stamina then
                    stamina:SetDimensions(orbSize, orbSize)
                    stamina:ClearAnchors()
                    stamina:SetAnchor(CENTER, doubleBar, CENTER, 0, 0)
                    local staminaBorder = GetControl(stamina, "Border")
                    if staminaBorder then staminaBorder:SetDimensions(borderSize, borderSize) end
                    local staminaBorderOverlay = GetControl(stamina, "BorderOverlay")
                    if staminaBorderOverlay then staminaBorderOverlay:SetDimensions(borderSize, borderSize) end
                    local staminaShade = GetControl(stamina, "BorderShade")
                    if staminaShade then staminaShade:SetDimensions(orbSize, orbSize) end
                    local staminaSplit = GetControl(stamina, "Split")
                    if staminaSplit then staminaSplit:SetDimensions(borderSize, borderSize) end
                    local staminaGlow = GetControl(stamina, "Glow")
                    if staminaGlow then staminaGlow:SetDimensions(orbSize, orbSize) end
                    -- Les couches Smoke/SmokeBg sont gérées dans leur propre logique (décalage par D4_FILL_LAYER_OFFSET_X)
                    local staminaSmoke = GetControl(stamina, "Smoke")
                    if staminaSmoke then staminaSmoke:SetDimensions(halfOrbSize, orbSize) end
                    local staminaSmokeBg = GetControl(stamina, "SmokeBg")
                    if staminaSmokeBg then staminaSmokeBg:SetDimensions(halfOrbSize, orbSize) end
                end
            end

            if d4OrbBackplateLeft and health then
                d4OrbBackplateLeft:ClearAnchors()
                d4OrbBackplateLeft:SetAnchor(BOTTOM, ctrl, BOTTOM, -backplateAnchorX, backplateAnchorY)
                d4OrbBackplateLeft:SetTexture(ThemeManager:GetTexturePath(string.format("D4OrbBackplate_%02d.dds", d4OrbBackplateTexturePreset)))
                d4OrbBackplateLeft:SetTextureCoords(13 / 256, 243 / 256, 10 / 128, 118 / 128)
                d4OrbBackplateLeft:SetDimensions(scaledBackplateWidth, scaledBackplateHeight)
                d4OrbBackplateLeft:SetHidden(false)
                d4OrbBackplateLeft:SetAlpha(GetD4UnifiedOrbAlpha())
                d4OrbBackplateLeft:SetColor(GetD4TintedColor(d4OrbBackplateBrightness))
            end

            if d4OrbBackplateRight and doubleBar then
                d4OrbBackplateRight:ClearAnchors()
                d4OrbBackplateRight:SetAnchor(BOTTOM, ctrl, BOTTOM, backplateAnchorX, backplateAnchorY)
                d4OrbBackplateRight:SetTexture(ThemeManager:GetTexturePath(string.format("D4OrbBackplate_%02d.dds", d4OrbBackplateTexturePreset)))
                d4OrbBackplateRight:SetTextureCoords(243 / 256, 13 / 256, 10 / 128, 118 / 128)
                d4OrbBackplateRight:SetDimensions(scaledBackplateWidth, scaledBackplateHeight)
                d4OrbBackplateRight:SetHidden(false)
                d4OrbBackplateRight:SetAlpha(GetD4UnifiedOrbAlpha())
                d4OrbBackplateRight:SetColor(GetD4TintedColor(d4OrbBackplateBrightness))
            end

            if shield and health then
                shield:SetDimensions(orbSize, orbSize)
                shield:ClearAnchors()
                shield:SetAnchor(CENTER, health, CENTER, 0, 0)
            end

            -- Keep D4 resource labels at legacy corner positions.
            applyLegacyLikeLabelAnchors(health, magicka, stamina)
        else
            if d4ExternalBar then
                d4ExternalBar:SetHidden(true)
            end
        end
    end

    ApplyUltimateBarLayout(ctrl, isDouble)

    if not AreActionBarBackgroundsEnabled() then
        if bgMiddle then bgMiddle:SetHidden(true) end
        if bgLeft then bgLeft:SetHidden(true) end
        if bgRight then bgRight:SetHidden(true) end
        if d4BarDecoration then d4BarDecoration:SetHidden(true) end
        if d4BarFallbackOverlay then d4BarFallbackOverlay:SetHidden(true) end
        if externalBar then externalBar:SetHidden(true) end
    end

    local showUltimateWidget = IsActionBarUltimateWidgetEnabled() and GetThemeSetting("SHOW_ULTIMATE_BAR")
    if line then line:SetHidden(not showUltimateWidget) end
    if lineBg then
        local showUltimateBg = showUltimateWidget
            and (ThemeManager:GetCurrentTheme() == "d4")
            and (GetThemeSetting("SHOW_ULTIMATE_BAR_BACKGROUND") ~= false)
        lineBg:SetHidden(not showUltimateBg)
    end
    if lineValue then lineValue:SetHidden((not showUltimateWidget) or (not SETTINGS.SHOW_ULTIMATE_TEXT)) end

    -- Backbar (barre inactive en arrière-plan, mode dual)
    ApplyBackbarLayout(ctrl)
    ApplyLegacyBackbarLayout(ctrl)
end

local GAMEPAD_CONSTANTS =
{
    abilitySlotWidth = 64,
    abilitySlotOffsetX = 10,
    dualBarOffsetX = 44,
}
local KEYBOARD_CONSTANTS =
{
    abilitySlotWidth = 50,
    abilitySlotOffsetX = 2,
    dualBarOffsetX = 12,
}

local LOCALIZATION = {
    en = {
        DESC = "DiabloOrbs settings.",
        SECTION_LANGUAGE = "Language",
        LANG_MODE_NAME = "Addon language",
        LANG_MODE_TIP = "Auto uses your game client language. Manual forces the selected language.",
        LANG_MODE_AUTO = "Auto (game language)",
        LANG_MODE_HINT = "If some labels do not refresh immediately, close and reopen the settings panel.",
        RELOAD_UI_NAME = "Reload UI now",
        RELOAD_UI_TIP = "Recommended after changing addon language to ensure every label updates immediately.",

        SECTION_ULTIMATE = "Ultimate Bar",
        SHOW_ULTIMATE_BAR_NAME = "Show ultimate bar",
        SHOW_ULTIMATE_BAR_TIP = "Show or hide the center ultimate bar.",
        SHOW_ULTIMATE_TEXT_NAME = "Show current/cost text on bar",
        SHOW_ULTIMATE_TEXT_TIP = "Display ultimate progress text directly on the center bar.",
        ULTIMATE_TEXT_MODE_NAME = "Ultimate text format",
        ULTIMATE_TEXT_MODE_TIP = "Choose the format shown on the ultimate bar.",
        ULTIMATE_TEXT_MODE_VALUE = "Value (current/cost)",
        ULTIMATE_TEXT_MODE_PERCENT = "Percent",
        ULTIMATE_READY_COLOR_NAME = "Color when ultimate is ready",
        ULTIMATE_READY_COLOR_TIP = "Color applied to the center bar when ultimate is ready.",
        ULTIMATE_PULSE_SPEED_NAME = "Ultimate pulse speed",
        ULTIMATE_PULSE_SPEED_TIP = "Pulse speed when ultimate is ready.",
        ULTIMATE_PULSE_MIN_NAME = "Pulse min alpha (%)",
        ULTIMATE_PULSE_MIN_TIP = "Minimum pulse alpha for ultimate bar.",
        ULTIMATE_PULSE_MAX_NAME = "Pulse max alpha (%)",
        ULTIMATE_PULSE_MAX_TIP = "Maximum pulse alpha for ultimate bar.",

        SECTION_ALERT = "Resource Alerts",
        LOW_RESOURCE_NAME = "Low resource threshold (%)",
        LOW_RESOURCE_TIP = "Trigger glow effect when a resource drops below this threshold.",
        GLOW_MAX_NAME = "Alert glow max intensity (%)",
        GLOW_MAX_TIP = "Maximum halo intensity around orbs during low-resource alert.",
        GLOW_INTERNAL_NAME = "Strict internal glow (no overflow)",
        GLOW_INTERNAL_TIP = "Enable glow inside orb bounds only. Disable for a more dramatic overflow.",
        BORDER_PULSE_ENABLE_NAME = "Enable border color pulse",
        BORDER_PULSE_ENABLE_TIP = "When resource is low, the ornamental border pulses with selected alert color.",
        BORDER_PULSE_COLOR_NAME = "Alert pulse color",
        BORDER_PULSE_COLOR_TIP = "Border color when resource is low.",

        SECTION_ORB_STYLE = "Orbs - Style",
        SMOKE_ALPHA_NAME = "Smoke transparency (%)",
        SMOKE_ALPHA_TIP = "Adjust smoke effect opacity on resource orbs.",
        SMOKEBG_BRIGHTNESS_NAME = "Orb background brightness (%)",
        SMOKEBG_BRIGHTNESS_TIP = "0% = dark background. 100% = brighter background.",
        ORB_COLOR_BOOST_NAME = "Global color intensity (%)",
        ORB_COLOR_BOOST_TIP = "Global orb color boost. 100% = normal, above = more vivid.",
        SHADE_ALPHA_NAME = "Dark inner shade intensity (%)",
        SHADE_ALPHA_TIP = "0% = no dark shade. 100% = full dark shade.",
        BORDER_ALPHA_NAME = "Circular border opacity (%)",
        BORDER_ALPHA_TIP = "Adjust ornamental orb border opacity.",
        SPLIT_ALPHA_NAME = "Dual-bar separator opacity (%)",
        SPLIT_ALPHA_TIP = "Adjust separator line opacity between Magicka and Stamina.",
        SHIELD_ALPHA_NAME = "Shield opacity (%)",
        SHIELD_ALPHA_TIP = "Adjust shield visual opacity.",
        SHIELD_RING_SCALE_NAME = "Shield ring size (%)",
        SHIELD_RING_SCALE_TIP = "Adjust visual thickness/size of shield ring in health orb.",
        SHIELD_VISUAL_RESPONSE_NAME = "Shield visual response (%)",
        SHIELD_VISUAL_RESPONSE_TIP = "Higher = reacts faster visually. 100% = linear.",

        SECTION_ORB_COLORS = "Orbs - Colors",
        HEALTH_COLOR_NAME = "Health orb color",
        MAGICKA_COLOR_NAME = "Magicka orb color",
        STAMINA_COLOR_NAME = "Stamina orb color",
        SHIELD_COLOR_NAME = "Shield orb color",

        SECTION_TEXT = "Value Labels",
        LABEL_SCALE_NAME = "Value label size (%)",
        LABEL_SCALE_TIP = "Adjust size of value/percentage labels on orbs.",
        LABEL_FORMAT_NAME = "Resource value display",
        LABEL_FORMAT_TIP = "Choose how numeric values are displayed on orbs.",
        LABEL_FORMAT_HIDDEN = "Hidden",
        LABEL_FORMAT_VALUE = "Value (e.g. 23k)",
        LABEL_FORMAT_PERCENT = "Percent (e.g. 75%)",

        ULT_TT_READY_OVER = "Ultimate: <<1>> / <<2>> (Ready, +<<3>>)",
        ULT_TT_READY = "Ultimate: <<1>> / <<2>> (Ready)",
        ULT_TT_NORMAL = "Ultimate: <<1>> / <<2>>",
        P001 = "0 = pure white glow. 100 = glow tinted to orb color.",
        P002 = "0 = normal mode (alpha). 100 = additive mode (more punch and brightness on dark backgrounds).",
        P003 = "0 = no tint (original color), 100 = full tint.",
        P004 = "100 = normal, up to 500 for very bright.",
        P005 = "100 = normal. Raise for more brightness, lower to darken.",
        P006 = "Enables DiabloOrbs slot/hotkey/weapon handling. If off, DiabloOrbs keeps visuals (skins/backgrounds/ultimate gauge) but leaves slot handling to another addon.",
        P007 = "Enables additive mode on stamina for the combined D4 orb (otherwise only magicka is used).",
        P008 = "Enables or disables the central DiabloOrbs ultimate widget entirely, independent of other bar parts.",
        P009 = "Enables or disables D4-theme slot borders added by DiabloOrbs.",
        P010 = "Enables contained glow inside D4 orbs. Off = more dramatic glow that spills a bit.",
        P011 = "Enables alert glow when a resource drops below the threshold.",
        P012 = "Enables brighter divider rendering (useful on dark backgrounds).",
        P013 = "Enable tinted background layer",
        P014 = "Enable additive light",
        P015 = "Enable low-threshold alert glow",
        P016 = "Shows the shield numeric value in D4 theme.",
        P017 = "Shows the shield numeric value in Legacy theme.",
        P018 = "Shows weapon swap on the standard bar and the arrow on the dual version when available.",
        P019 = "Shows decorative background behind the ultimate gauge.",
        P020 = "Shows inactive bar ability icons in the background in Dual mode with dual Legacy background. (Legacy theme only)",
        P021 = "Shows separate solo/dual settings to fine-tune outline intensity. Main opacity remains the recommended control.",
        P022 = "Shows inactive bar slots in the background in dual mode. Only D4 mode is affected.",
        P023 = "Shows text/hotkey labels on action bar slots when keyboard UI is used.",
        P024 = "Shows or hides the shadow layer on D4 orbs.",
        P025 = "Shows or hides the colored fill layer inside D4 orbs.",
        P026 = "Shows or hides the bright glow layer on D4 orbs.",
        P027 = "Shows or hides the Smoke fill layer on D4 orbs.",
        P028 = "Shows or hides the outline overlay on D4 orbs.",
        P029 = "Shows or hides the main outline on D4 orbs.",
        P030 = "Shows or hides bar base, trims, and visual supports for the DiabloOrbs action bar.",
        P031 = "Shows or hides the companion ultimate slot without touching the rest of the bar.",
        P032 = "Shows or hides ability slots managed by DiabloOrbs. Handy to keep only the background or the opposite.",
        P033 = "Shows a simple line between magicka and stamina.",
        P034 = "Shows a second bar in the background with dual texture. Turn off to show only one bar. (D4 theme only)",
        P035 = "Show ultimate gauge background",
        P036 = "Show weapon swap indicator",
        P037 = "Show shadow",
        P038 = "Show companion ultimate",
        P039 = "Show central DiabloOrbs ultimate gauge",
        P040 = "Show overlay",
        P041 = "Show outline",
        P042 = "Show colored fill",
        P043 = "Show DiabloOrbs bar base/support",
        P044 = "Show glow",
        P045 = "Show smoke",
        P046 = "Show divider line",
        P047 = "Show D4 slot borders",
        P048 = "Show slot hotkeys",
        P049 = "Show DiabloOrbs ability slots",
        P050 = "Show advanced solo/dual outline settings",
        P051 = "Show shield value (D4)",
        P052 = "Show shield value (Legacy)",
        P053 = "Adds a Smoke veil tinted by orb colors to blend buttons into the theme.",
        P054 = "Adds a color layer behind the main orbs fill.",
        P055 = "Adjusts fill alignment inside the orbs.",
        P056 = "Adjusts spacing of the 5 center slots in Legacy dual.",
        P057 = "Adjusts spacing of the 5 center slots in Legacy solo.",
        P058 = "Adjusts spacing of the 5 center slots in D4 theme.",
        P059 = "Adjusts horizontal spacing of health/combined orbs around center on layer 1.",
        P060 = "Adjusts mirrored spacing of additive layer orbs (magicka/stamina).",
        P061 = "Adjusts desaturation on the inactive secondary bar in two-bar mode.",
        P062 = "Adjusts vertical thickness of the ultimate gauge in dual mode.",
        P063 = "Adjusts vertical thickness of the ultimate gauge in solo mode.",
        P064 = "Adjusts visual thickness of the shield ring in the health orb (D4 theme).",
        P065 = "Adjusts visual thickness of the shield ring in the health orb (Legacy theme).",
        P066 = "Adjusts shield visual opacity for D4 theme.",
        P067 = "Adjusts D4 shield draw order. Higher = drawn further on top.",
        P068 = "Adjusts height of the colored fill layer on D4 orbs.",
        P069 = "Adjusts height of D4 bar base when secondary bar is enabled.",
        P070 = "Adjusts height of D4 bar base when secondary bar is disabled.",
        P071 = "Adjusts height of ultimate gauge background in dual mode.",
        P072 = "Adjusts height of ultimate gauge background in solo mode.",
        P073 = "Adjusts width of the colored fill layer on D4 orbs.",
        P074 = "Adjusts width of the ultimate gauge in dual mode.",
        P075 = "Adjusts width of the ultimate gauge in solo mode.",
        P076 = "Adjusts D4 bar background width when secondary bar is active.",
        P077 = "Adjusts D4 bar background width when secondary bar is disabled.",
        P078 = "Adjusts gauge background width in dual mode.",
        P079 = "Adjusts gauge background width in solo mode.",
        P080 = "Adjusts D4OrbFill.dds brightness, used here as the neutral orb base.",
        P081 = "Adjusts D4 bar brightness with the 2 base textures only. 100 = source, below darkens, above brightens.",
        P082 = "Adjusts divider line brightness.",
        P083 = "Adjusts overall orb fill brightness. 100% = normal.",
        P084 = "Adjusts D4 orb shadow layer size.",
        P085 = "Adjusts D4 orb glow layer size.",
        P086 = "Adjusts D4 orb Smoke fill layer size.",
        P087 = "Adjusts D4 orb border overlay size.",
        P088 = "Adjusts D4 orb main border size.",
        P089 = "Adjusts ability hotkey text size.",
        P090 = "Adjusts overall D4 orb size and all their layers, extended range.",
        P091 = "Adjusts actual D4 bar background size. 100 = source size, higher enlarges, lower shrinks.",
        P092 = "Adjusts ability hotkey text opacity.",
        P093 = "Adjusts keys and icons inside the D4 bar. Content now follows bar size automatically; this fine-tunes the result.",
        P094 = "Alerts",
        P095 = "Appearance",
        P096 = "Applies a color tint to D4 orb frames, backplates, border overlay, action bar background and ultimate gauge background.",
        P097 = "Apply to stamina",
        P098 = "Companion slot border darkening (%)",
        P099 = "Darkens all D4 ability button borders.",
        P100 = "Darkens only the companion slot border without changing other D4 borders.",
        P101 = "Dims the ultimate gauge without affecting the text shown on top of it.",
        P102 = "Backbar (inactive D4 bar)",
        P103 = "Action bar - Common",
        P104 = "Action bar - D4",
        P105 = "Base",
        P106 = "Borders and outlines",
        P107 = "Shield",
        P108 = "D4 shield: horizontal offset (px)",
        P109 = "D4 shield: vertical offset (px)",
        P110 = "Legacy shield: horizontal offset (px)",
        P111 = "Legacy shield: vertical offset (px)",
        P112 = "Ornamental frame: size (px)",
        P113 = "These settings move or resize all orbs and bases.",
        P114 = "Sets the color of the background layer added to the orbs.",
        P115 = "Sets the color of the text on the ultimate gauge.",
        P116 = "Sets the color of the line between magicka and stamina.",
        P117 = "Sets the font for orb values and ultimate text. Custom fonts use files in DiabloOrbs/Fonts (otherwise falls back to ESO font).",
        P118 = "Sets shortcut text position for skills: above, below, or inside slots.",
        P119 = "Sets the texture theme (Legacy or D4). A reloadui runs automatically to apply the change.",
        P120 = "Choose a lighter or darker DDS variant for bases under the orbs.",
        P121 = "Shade color applied behind the text at the center of the orbs.",
        P122 = "Common",
        P123 = "Let DiabloOrbs control the action bar",
        P124 = "D4 button outline contrast (%)",
        P125 = "Controls overall transparency of the orbs and their bases.",
        P126 = "Layer 1: Colored background",
        P127 = "Layer 1: spacing between orbs (px)",
        P128 = "Layer 1: height (%)",
        P129 = "Layer 1: width (%)",
        P130 = "Layer 1: brightness (%)",
        P131 = "Layer 1: offset X (px)",
        P132 = "Layer 1: offset Y (px)",
        P133 = "Layer 1: global offset X (px)",
        P134 = "Layer 1: opacity (%)",
        P135 = "Layer 2: Colored smoke",
        P136 = "Layer 2: D4 shield color",
        P137 = "Layer 2: D4 stamina color",
        P138 = "Layer 2: D4 magicka color",
        P139 = "Layer 2: D4 health color",
        P140 = "Layer 2: center spacing (px)",
        P141 = "Layer 2: offset Y (px)",
        P142 = "Layer 2: global offset X (px)",
        P143 = "Layer 2: opacity (%)",
        P144 = "Layer 2: size (%)",
        P145 = "Layer 3: Additive light",
        P146 = "Layer 3: spacing between orbs (px)",
        P147 = "Layer 3: intensity (%)",
        P148 = "Layer 3: offset X (px)",
        P149 = "Layer 4: Glow",
        P150 = "Layer 4: brightness (%)",
        P151 = "Layer 4: offset X (px)",
        P152 = "Layer 4: offset Y (px)",
        P153 = "Layer 4: opacity (%)",
        P154 = "Layer 4: size (%)",
        P155 = "Layer 4: orb tint color (%)",
        P156 = "Layer 5: Shadow",
        P157 = "Layer 5: spacing between orbs (px)",
        P158 = "Layer 5: offset X (px)",
        P159 = "Layer 5: offset Y (px)",
        P160 = "Layer 5: opacity (%)",
        P161 = "Layer 5: size (%)",
        P162 = "Layer 6: Main outline",
        P163 = "Layer 6: spacing between orbs (px)",
        P164 = "Layer 6: offset X (px)",
        P165 = "Layer 6: offset Y (px)",
        P166 = "Layer 6: opacity (%)",
        P167 = "Layer 6: size (%)",
        P168 = "Layer 7: Divider line",
        P169 = "Layer 7: color",
        P170 = "Layer 7: height (% of orb)",
        P171 = "Layer 7: width (px)",
        P172 = "Layer 7: brightness (%)",
        P173 = "Layer 7: additive mode",
        P174 = "Layer 7: offset X (px)",
        P175 = "Layer 7: offset Y (px)",
        P176 = "Layer 7: opacity (%)",
        P177 = "Layer 7: size (% of orb)",
        P178 = "Layer 8: Outline overlay",
        P179 = "Layer 8: contrast (%)",
        P180 = "Layer 8: spacing between orbs (px)",
        P181 = "Layer 8: brightness (%)",
        P182 = "Layer 8: offset X (px)",
        P183 = "Layer 8: offset Y (px)",
        P184 = "Layer 8: opacity (%)",
        P185 = "Layer 8: size (%)",
        P186 = "Shield color (Legacy)",
        P187 = "Stamina color (Legacy)",
        P188 = "Magicka color (Legacy)",
        P189 = "Health color (Legacy)",
        P190 = "Color applied to D4 elements (frame, bases, overlay, bar, gauge).",
        P191 = "Tint layer color",
        P192 = "Legacy stamina orb fill color.",
        P193 = "Legacy magicka orb fill color.",
        P194 = "Legacy health orb fill color.",
        P195 = "D4 tint color",
        P196 = "Legacy shield color.",
        P197 = "Gauge background color",
        P198 = "Low-resource alert glow color for the stamina orb.",
        P199 = "Low-resource alert glow color for the magicka orb.",
        P200 = "Low-resource alert glow color for the health orb.",
        P201 = "Smoke fill color for the D4 stamina orb.",
        P202 = "Smoke fill color for the D4 magicka orb.",
        P203 = "Smoke fill color for the D4 health orb.",
        P204 = "Smoke fill color for the D4 shield.",
        P205 = "Stamina alert glow color (RGB)",
        P206 = "Magicka alert glow color (RGB)",
        P207 = "Health alert glow color (RGB)",
        P208 = "Inner text shadow color",
        P209 = "Ultimate text color",
        P210 = "Colors",
        P211 = "D4: horizontal spacing of the 5 slots (px)",
        P212 = "Fill offset — Health orb (px)",
        P213 = "Fill offset — Combined orb (px)",
        P214 = "Vertical offset (px)",
        P215 = "Shifts shortcut text on slots horizontally.",
        P216 = "Shifts the ultimate horizontally relative to slot 5.",
        P217 = "Shifts the ultimate horizontally.",
        P218 = "Shifts the ultimate vertically relative to other slots.",
        P219 = "Shifts the ultimate vertically.",
        P220 = "Shifts the Legacy backbar left or right.",
        P221 = "Shifts the Legacy backbar up (negative) or down.",
        P222 = "Shifts the backbar left or right relative to the active bar.",
        P223 = "Shifts the backbar up (negative) or down relative to the active bar. Default -28 to show about 20% of slots.",
        P224 = "Shifts entire layer 1 left/right without changing orb spacing.",
        P225 = "Shifts the Smoke layer up or down.",
        P226 = "Shifts the shadow layer left or right.",
        P227 = "Shifts the shadow layer up or down.",
        P228 = "Shifts the colored background layer up or down.",
        P229 = "Shifts the glow layer left or right.",
        P230 = "Shifts the glow layer up or down.",
        P231 = "Shifts the fill (smoke) inside orbs: health left and combined right by the same amount.",
        P232 = "Shifts the outline overlay left or right.",
        P233 = "Shifts the outline overlay up or down.",
        P234 = "Shifts the main outline left or right.",
        P235 = "Shifts the main outline up or down.",
        P236 = "Shifts the shortcut slot in Legacy dual.",
        P237 = "Shifts the shortcut slot in Legacy solo.",
        P238 = "Shifts the ultimate slot in Legacy dual.",
        P239 = "Shifts the ultimate slot in Legacy solo.",
        P240 = "Shifts the separator line left or right.",
        P241 = "Shifts the separator line up or down.",
        P242 = "Shifts only the fill (smoke) inside the combined magicka/stamina orb on the X axis.",
        P243 = "Shifts only the fill (smoke) inside the health orb on the X axis.",
        P244 = "Shifts shortcut text on slots vertically.",
        P245 = "Moves the left orb (health) value horizontally around the center.",
        P246 = "Moves shield text independently in D4.",
        P247 = "Moves shield text independently in Legacy.",
        P248 = "Moves the quickslot item left or right on the D4 bar. Useful to realign after size changes.",
        P249 = "Moves the quickslot item up or down independently of the bar background.",
        P250 = "Moves the ultimate slot left or right on the D4 bar (negative = left). Useful to realign after size changes.",
        P251 = "Moves the ultimate slot up or down independently of the bar background.",
        P252 = "Moves all 3 background layer instances (health + magicka + stamina) in the same direction.",
        P253 = "Moves all 3 fill layer instances (health + magicka + stamina) in the same direction.",
        P254 = "Moves the 5 central slots in dual mode.",
        P255 = "Moves the 5 central slots in solo mode.",
        P256 = "Moves the orbs up or down in dual mode.",
        P257 = "Moves the orbs up or down in solo mode.",
        P258 = "Moves both D4 glows vertically at once, keeping perfect left/right mirror.",
        P259 = "Moves both glows vertically at once, keeping perfect left/right mirror.",
        P260 = "Desaturation (%)",
        P261 = "Inactive bar desaturation, 2 bars (%)",
        P262 = "Desaturates backbar icons so they look different from the active bar.",
        P263 = "Desaturates icons so they look different from the active bar.",
        P264 = "Orb distance from screen center in solo mode.",
        P265 = "Orb distance from center in dual mode (secondary bar enabled).",
        P266 = "D4 glow spacing from center (px)",
        P267 = "Glow spacing from center (px)",
        P268 = "Spacing between each backbar ability slot.",
        P269 = "Spacing between each slot.",
        P270 = "Horizontal spacing of the 5 slots (px)",
        P271 = "Shortcut inset from edge (px)",
        P272 = "Symmetric fill spacing (px)",
        P273 = "Ultimate spacing (px)",
        P274 = "Ultimate inset from edge (px)",
        P275 = "Spreads shadow layer: health left, magicka/stamina right.",
        P276 = "Spreads overlay layer: health left, magicka/stamina right.",
        P277 = "Spreads outline layer: health left, magicka/stamina right.",
        P278 = "Spreads orbs relative to the bar in dual mode.",
        P279 = "Spreads orbs relative to the bar in solo mode.",
        P280 = "Spreads or pulls magicka/stamina values from the center of the split orb.",
        P281 = "Offset from center — Dual (px)",
        P282 = "Offset from center — Solo (px)",
        P283 = "Horizontal spacing (px)",
        P284 = "Scale (%)",
        P285 = "D4 bar content scale (%)",
        P286 = "Brightened = light text with dark shadow. Darkened = dark text with light shadow.",
        P287 = "Moves D4 magicka and stamina glows farther from or closer to the center.",
        P288 = "Moves magicka and stamina glows farther from or closer to the center. Increase for more spacing.",
        P289 = "In Legacy mode, each half (magicka/stamina) has its own alert state.",
        P290 = "Extra space between slot 5 and the ultimate.",
        P291 = "Slot spacing (px)",
        P292 = "Outer: horizontal padding (px)",
        P293 = "Outer: vertical padding (px)",
        P294 = "Outer = classic position. Inner = text centered in orbs.",
        P295 = "Background",
        P296 = "D4 bar background",
        P297 = "Dual background (DiabloOrbsDualBarXp)",
        P298 = "Solo background (ActionBarXp)",
        P299 = "Forces a minimum inner shadow to check layer nesting.",
        P300 = "Split combined orb alert",
        P301 = "General",
        P302 = "Glow: size (px)",
        P303 = "Strict inner D4 glow (no overflow)",
        P304 = "Action bar button styling in D4 theme: borders, smoke, companion.",
        P305 = "Separator line height as percent of orb size.",
        P306 = "D4 background height with secondary bar (%)",
        P307 = "D4 background height without secondary bar (%)",
        P308 = "Dual gauge background height (px)",
        P309 = "Solo gauge background height (px)",
        P310 = "Dual ultimate gauge height (px)",
        P311 = "Solo ultimate gauge height (px)",
        P312 = "Info and values",
        P313 = "Additional D4 dual orb rim intensity (%)",
        P314 = "Additional D4 solo orb rim intensity (%)",
        P315 = "Additive overlay D4OrbBack2 intensity.",
        P316 = "Tint intensity (%)",
        P317 = "Permanent reflection intensity outside resource alert.",
        P318 = "Max D4 resource alert glow intensity (%)",
        P319 = "Maximum halo brightness around D4 orbs during resource alert.",
        P320 = "D4 button smoke intensity (%)",
        P321 = "Interior: mirror magicka/stamina gap (px)",
        P322 = "Interior: left orb horizontal offset (px)",
        P323 = "Inverts horizontal placement of magicka and stamina values in interior display mode. Independent per theme (D4 / Legacy).",
        P324 = "Invert magicka/stamina (interior)",
        P325 = "Gauge",
        P326 = "Ultimate gauge",
        P327 = "Font is shared; orb text and ultimate gauge text size are set separately.",
        P328 = "Label - D4",
        P329 = "Label - Legacy",
        P330 = "Interface language",
        P331 = "Separator line width in pixels.",
        P332 = "D4 background width with secondary bar (%)",
        P333 = "D4 background width without secondary bar (%)",
        P334 = "Dual gauge background width (%)",
        P335 = "Solo gauge background width (%)",
        P336 = "Dual ultimate gauge width (%)",
        P337 = "Solo ultimate gauge width (%)",
        P338 = "Background follows active theme (D4: fond_jauge.dds, Legacy: UltimateGaugeBackground.dds). Sliders below control size/offset/opacity.",
        P339 = "Ultimate text is independent of gauge pulse and stays readable at all times.",
        P340 = "Legacy - Background and backbar",
        P341 = "D4 bar brightness (%)",
        P342 = "Pedestal brightness (preset)",
        P343 = "Background brightness (%)",
        P344 = "Global brightness (%)",
        P345 = "Global background brightness (%)",
        P346 = "Two-bar mode: these settings apply to the secondary bar shown when a dual system is detected.",
        P347 = "Raise or lower shield text independently in D4.",
        P348 = "Raise or lower shield text independently in Legacy.",
        P349 = "Raise or lower the bar in dual mode (secondary bar enabled).",
        P350 = "Raise or lower the bar in solo mode (secondary bar disabled).",
        P351 = "Raise or lower ultimate gauge in dual mode.",
        P352 = "Raise or lower ultimate gauge in solo mode.",
        P353 = "Raise or lower gauge background in dual mode.",
        P354 = "Raise or lower gauge background in solo mode.",
        P355 = "Raise or lower orb value text.",
        P356 = "Raise or lower orbs and pedestals in dual mode (secondary bar enabled).",
        P357 = "Raise or lower orbs and pedestals in solo mode (secondary bar disabled).",
        P358 = "D4 shield layer level",
        P359 = "D4 button rim darkness (%)",
        P360 = "Hotkey offset X (px)",
        P361 = "Ultimate offset X (px)",
        P362 = "Hotkey offset Y (px)",
        P363 = "Ultimate offset Y (px)",
        P364 = "Horizontal offset (px)",
        P365 = "D4 hotkey slot offset (px)",
        P366 = "D4 ultimate slot offset (px)",
        P367 = "Vertical offset (px)",
        P368 = "Vertical offset 5 slots - dual bar (px)",
        P369 = "Vertical offset 5 slots - solo bar (px)",
        P370 = "Vertical bar offset - Dual (px)",
        P371 = "Vertical bar offset - Solo (px)",
        P372 = "Dual gauge background vertical offset (px)",
        P373 = "Solo gauge background vertical offset (px)",
        P374 = "D4 glow vertical offset (px)",
        P375 = "Mirror glow vertical offset (px)",
        P376 = "Dual ultimate gauge vertical offset (px)",
        P377 = "Solo ultimate gauge vertical offset (px)",
        P378 = "D4 hotkey slot vertical offset (px)",
        P379 = "D4 ultimate slot vertical offset (px)",
        P380 = "Vertical offset value text (px)",
        P381 = "Inner shadow: size (px)",
        P382 = "Minimal D4 shadow (%)",
        P383 = "Opacity (%)",
        P384 = "Inactive bar opacity two bars (%)",
        P385 = "Value tooltip border opacity (%)",
        P386 = "D4 button rim opacity (%)",
        P387 = "Tint layer opacity (%)",
        P388 = "Hotkey opacity (%)",
        P389 = "D4 shield opacity (%)",
        P390 = "Legacy shield opacity (%)",
        P391 = "Low resource alert glow opacity.",
        P392 = "Interior contrast background opacity (%)",
        P393 = "Gauge background opacity (%)",
        P394 = "Global orbs and pedestals opacity (%)",
        P395 = "Alert glow opacity (%)",
        P396 = "Interior text shadow opacity (%)",
        P397 = "Gauge fill opacity (%)",
        P398 = "Ultimate text opacity (%)",
        P399 = "Value text opacity (%)",
        P400 = "Shared DiabloOrbs action bar options. Settings marked solo/dual allow different behavior by detected mode.",
        P401 = "D4 orbs",
        P402 = "Legacy orbs",
        P403 = "Layout: shared font family, then separate settings for orb values and ultimate gauge text.",
        P404 = "Number font (shared across all themes)",
        P405 = "Hotkey position",
        P406 = "Value position",
        P407 = "Position and size",
        P408 = "Position and size — global settings",
        P409 = "Orb position — Dual",
        P410 = "Orb position — Solo",
        P411 = "Vertical orb position — Dual (px)",
        P412 = "Vertical orb position — Solo (px)",
        P413 = "Hotkeys",
        P414 = "Hotkeys visible only in combat",
        P415 = "Uniformly scales all Legacy orb layers together.",
        P416 = "D4 idle reflection (%)",
        P417 = "Advanced: dual intensity multiplied by main opacity.",
        P418 = "Advanced: solo intensity multiplied by main opacity.",
        P419 = "Main opacity for D4 button outlines (hotkey, 5 slots, ultimate, companion).",
        P420 = "General DiabloOrbs settings.",
        P421 = "Per-theme settings (D4 or Legacy), with separate solo/dual values.",
        P422 = "Sets lateral offset of outside values from orb edges.",
        P423 = "Sets inactive secondary bar opacity when a 2-bar layout is detected.",
        P424 = "Sets decorative border opacity around value text.",
        P425 = "Sets D4 orb shadow layer opacity.",
        P426 = "Sets extra color layer opacity behind orbs.",
        P427 = "Sets D4 colored background layer opacity.",
        P428 = "Sets D4 orb glow layer opacity.",
        P429 = "Sets D4 orb Smoke fill layer opacity.",
        P430 = "Sets D4 orb outline overlay opacity.",
        P431 = "Sets real text shadow opacity behind values inside the orb.",
        P432 = "Sets main D4 orb outline opacity.",
        P433 = "Sets contrast backdrop opacity behind values inside the orb.",
        P434 = "Sets ultimate gauge text opacity without affecting bar pulse.",
        P435 = "Sets value text opacity regardless of placement.",
        P436 = "Sets magicka/stamina divider line opacity.",
        P437 = "Sets overall brightness of D4 colored Smoke.dds background.",
        P438 = "Sets vertical position of outside values.",
        P439 = "Sets font size of text on the ultimate gauge.",
        P440 = "Sets gauge background transparency without changing text.",
        P441 = "Resets all D4 settings to default calibrated values. Does not affect Legacy.",
        P442 = "Resets all Legacy settings to defaults. Does not affect D4.",
        P443 = "Fill — fine offset",
        P444 = "Boosts outline contrast (100 = normal, >100 = stronger).",
        P445 = "Boosts or softens Smoke.dds background color for all D4 resources.",
        P446 = "Reset D4 (default positions)",
        P447 = "Reset Legacy (default positions)",
        P448 = "Center separator: size (px)",
        P449 = "When on, skill hotkeys show only in combat.",
        P450 = "Slots — Dual",
        P451 = "Slots — Solo",
        P452 = "Inner text style",
        P453 = "Blends D4OrbBack2 additively to brighten the orb without recoloring the base.",
        P454 = "Size of each backbar icon in pixels.",
        P455 = "Size of each icon in pixels.",
        P456 = "Legacy orb inner shadow layer size (Shade.dds). 150 = default.",
        P457 = "Orb size (px)",
        P458 = "Hotkey size (%)",
        P459 = "Backbar slot size. 80 = smaller than active bar for more depth.",
        P460 = "Legacy circular frame size. 166 = default XML. Lower to avoid overlap when orbs are large.",
        P461 = "D4 shield circle size (%)",
        P462 = "Legacy shield circle size (%)",
        P463 = "Low-resource alert glow size vs normal glow. 100 = same.",
        P464 = "Legacy orb glow size. 150 = default.",
        P465 = "Separator size between magicka and stamina (Split.dds). 166 = default.",
        P466 = "D4 bar background size (%)",
        P467 = "Overall Legacy backbar size.",
        P468 = "Overall orb size (%)",
        P469 = "Overall separator size as percent of orb size.",
        P470 = "Alert glow size (%)",
        P471 = "Ultimate text font size",
        P472 = "Slot size (px)",
        P473 = "Backbar slot size (px)",
        P474 = "Tint applied to gauge background.",
        P475 = "Global D4 tint",
        P476 = "Text",
        P477 = "Text and values",
        P478 = "Visual theme",
        P479 = "Moves both additive-layer orbs left/right together.",
        P480 = "Backbar transparency. 0 = invisible, 100 = opaque.",
        P481 = "Legacy backbar icon transparency.",
        P482 = "Shared typography",
        P483 = "Positive = magicka/stamina move apart from center (smoke layer), negative = closer together.",
        P484 = "Orb values",
        P485 = "Visual — D4",
        P486 = "Visual — Legacy",
        P487 = "[Theme D4] Enable secondary bar (Dual mode)",
        P488 = "[Theme Legacy] Enable secondary bar (Dual mode)",
        P489 = "|cFFAA00[!] For best results (solo and dual), enable in|r |cFFFFFFSettings > Combat|r |cFFAA00:|r |cFFFFFF\"Ability Bar Back Row\"|r |cFFAA00and|r |cFFFFFF\"Ability Bar Timers\"|r|cFFAA00. (All themes)|r",
        P490 = "Profiles",
        P491 = "Manage your settings profiles. A profile saves all your visual settings. You can share a profile across multiple characters on the same account.",
        P492 = "Active profile",
        P493 = "Select the profile to load. Click 'Load selected profile' to apply.",
        P494 = "Load selected profile",
        P495 = "Applies the selected profile settings to this character.",
        P496 = "Save (overwrite active profile)",
        P497 = "Overwrites the active profile with your current settings.",
        P498 = "Save as... (new name)",
        P499 = "Creates a new profile with the entered name and your current settings.",
        P500 = "Create this new profile",
        P501 = "Creates or overwrites a profile with the name entered above.",
        P502 = "Delete selected profile",
        P503 = "Deletes the selected profile ('D4 default' and 'Legacy default' are protected).",
        P504 = "Decorations (Angel / Demon)",
        P505 = "Show decorations (Angel / Demon)",
        P506 = "Foreground (in front of orbs)",
        P507 = "Swap sides (Angel/Demon)",
        P508 = "Ornamental frame: size (px)",
        P509 = "Inner shadow: size (px)",
        P510 = "Center separator: size (px)",
        P511 = "Glow: size (px)",
        P512 = "Base size (px)",
        P513 = "Width (%)",
        P514 = "Height (%)",
        P515 = "Gap from center (px)",
        P516 = "Vertical offset (px)",
        P517 = "Legacy circular frame size. Default XML value is 166. Lower to avoid overlap when orbs are large. [ID: B93]",
        P518 = "Legacy inner shadow layer size (Shade.dds). Default value is 150. [ID: B94]",
        P519 = "Separator between Magicka and Stamina size (Split.dds). Default value is 166. [ID: B95]",
        P520 = "Legacy orb glow size. Default value is 150. [ID: B96]",
        P521 = "Show or hide the Angel and Demon decorative images on each side of the orbs (Legacy only). [ID: LD10]",
        P522 = "Reference size for Angel and Demon images. Width and height are percentages of this value. [ID: LD11]",
        P523 = "Horizontal distance between the center of the screen and each image. 0 = center. [ID: LD12]",
        P524 = "Moves decorations up (negative) or down (positive). [ID: LD13]",
        P525 = "Displays decorations in front of all elements. Disabled = background. [ID: LD14]",
        P526 = "Swaps positions: Angel on the left, Demon on the right. [ID: LD15]",
        P527 = "Width as % of the base size. [ID: LD16]",
        P528 = "Height as % of the base size. [ID: LD17]",
        P529 = "This profile is protected and cannot be overwritten.",
        P530 = "This profile is protected and cannot be deleted.",
        P531 = "Please enter a profile name.",
        P532 = "This profile name is protected and cannot be used.",
    },
    fr = {
        DESC = "Parametres de DiabloOrbs.",
        SECTION_LANGUAGE = "Langue",
        LANG_MODE_NAME = "Langue de l'addon",
        LANG_MODE_TIP = "Auto utilise la langue du client. Manuel force la langue choisie.",
        LANG_MODE_AUTO = "Auto (langue du jeu)",
        LANG_MODE_HINT = "Si certains textes ne se rafraichissent pas immediatement, ferme puis reouvre le panneau.",

        SECTION_ULTIMATE = "Jauge d'ultime",
        SHOW_ULTIMATE_BAR_NAME = "Afficher la jauge d'ultime",
        SHOW_ULTIMATE_BAR_TIP = "Affiche ou masque la jauge d'ultime au centre de la barre d'action.",
        SHOW_ULTIMATE_TEXT_NAME = "Afficher le texte actuel/cout sur la jauge",
        SHOW_ULTIMATE_TEXT_TIP = "Affiche le texte de progression d'ultime directement sur la jauge centrale.",
        ULTIMATE_TEXT_MODE_NAME = "Format du texte d'ultime",
        ULTIMATE_TEXT_MODE_TIP = "Choisit le format affiche sur la jauge ultime.",
        ULTIMATE_TEXT_MODE_VALUE = "Valeur (actuel/cout)",
        ULTIMATE_TEXT_MODE_PERCENT = "Pourcentage",
        ULTIMATE_READY_COLOR_NAME = "Couleur quand ultime est prete",
        ULTIMATE_READY_COLOR_TIP = "Couleur appliquee a la jauge centrale quand l'ultime est prete.",
        ULTIMATE_PULSE_SPEED_NAME = "Vitesse pulse ultime",
        ULTIMATE_PULSE_SPEED_TIP = "Vitesse du clignotement quand l'ultime est prete.",
        ULTIMATE_PULSE_MIN_NAME = "Pulse alpha min (%)",
        ULTIMATE_PULSE_MIN_TIP = "Opacite minimale du pulse de la jauge ultime.",
        ULTIMATE_PULSE_MAX_NAME = "Pulse alpha max (%)",
        ULTIMATE_PULSE_MAX_TIP = "Opacite maximale du pulse de la jauge ultime.",

        SECTION_ALERT = "Alertes ressources",
        LOW_RESOURCE_NAME = "Seuil alerte ressources (%)",
        LOW_RESOURCE_TIP = "Declenche l'effet glow quand une ressource passe sous ce pourcentage.",
        GLOW_MAX_NAME = "Intensite max du glow d'alerte (%)",
        GLOW_MAX_TIP = "Intensite maximale de l'aureole lumineuse autour des orbes lors d'une alerte ressource.",
        GLOW_INTERNAL_NAME = "Glow interne strict (sans debordement)",
        GLOW_INTERNAL_TIP = "Active un glow contenu a l'interieur des orbes. Desactive = glow plus dramatique qui depasse un peu.",
        BORDER_PULSE_ENABLE_NAME = "Activer le pulse de couleur sur le cadre",
        BORDER_PULSE_ENABLE_TIP = "Quand la ressource est faible, le cadre ornemental pulse dans la couleur d'alerte choisie.",
        BORDER_PULSE_COLOR_NAME = "Couleur du pulse d'alerte",
        BORDER_PULSE_COLOR_TIP = "Couleur du cadre quand la ressource est faible.",

        SECTION_ORB_STYLE = "Orbes - Style",
        SMOKE_ALPHA_NAME = "Transparence du smoke (%)",
        SMOKE_ALPHA_TIP = "Ajuste l'opacite des effets de fumee sur les orbes de ressources.",
        SMOKEBG_BRIGHTNESS_NAME = "Luminosite du fond des orbes (%)",
        SMOKEBG_BRIGHTNESS_TIP = "0% = fond sombre. 100% = fond plus lumineux.",
        ORB_COLOR_BOOST_NAME = "Intensite globale des couleurs (%)",
        ORB_COLOR_BOOST_TIP = "Boost global des couleurs des orbes. 100% = normal, au-dessus = plus vif.",
        SHADE_ALPHA_NAME = "Intensite du contour sombre (%)",
        SHADE_ALPHA_TIP = "0% = contour sombre invisible. 100% = contour sombre complet.",
        BORDER_ALPHA_NAME = "Opacite du cadre circulaire (%)",
        BORDER_ALPHA_TIP = "Ajuste l'opacite du cadre ornemental des orbes.",
        SPLIT_ALPHA_NAME = "Opacite du separateur double barre (%)",
        SPLIT_ALPHA_TIP = "Ajuste l'opacite de la ligne de separation entre Magie et Endurance.",
        SHIELD_ALPHA_NAME = "Opacite du bouclier (%)",
        SHIELD_ALPHA_TIP = "Ajuste l'opacite de l'effet visuel du bouclier magique.",
        SHIELD_RING_SCALE_NAME = "Taille du cercle bouclier (%)",
        SHIELD_RING_SCALE_TIP = "Ajuste l'epaisseur visuelle du cercle de bouclier dans l'orbe de vie.",
        SHIELD_VISUAL_RESPONSE_NAME = "Reactivite visuelle du bouclier (%)",
        SHIELD_VISUAL_RESPONSE_TIP = "Rend le bouclier visuellement plus rapide (haut) ou plus progressif (bas). 100% = lineaire.",

        SECTION_ORB_COLORS = "Orbes - Couleurs",
        HEALTH_COLOR_NAME = "Couleur Orbe Sante",
        MAGICKA_COLOR_NAME = "Couleur Orbe Magie",
        STAMINA_COLOR_NAME = "Couleur Orbe Endurance",
        SHIELD_COLOR_NAME = "Couleur Orbe Bouclier",

        SECTION_TEXT = "Texte des valeurs",
        LABEL_SCALE_NAME = "Taille des valeurs (%)",
        LABEL_SCALE_TIP = "Regle la taille du texte des valeurs/pourcentages affiches sur les orbes.",
        LABEL_FORMAT_NAME = "Affichage des valeurs de ressources",
        LABEL_FORMAT_TIP = "Choisit comment afficher les valeurs numeriques sur les orbes.",
        LABEL_FORMAT_HIDDEN = "Masque",
        LABEL_FORMAT_VALUE = "Valeur (ex: 23k)",
        LABEL_FORMAT_PERCENT = "Pourcentage (ex: 75%)",

        ULT_TT_READY_OVER = "Ultime: <<1>> / <<2>> (Pret, +<<3>>)",
        ULT_TT_READY = "Ultime: <<1>> / <<2>> (Pret)",
        ULT_TT_NORMAL = "Ultime: <<1>> / <<2>>",
        P001 = "0 = glow blanc pur. 100 = glow teinte couleur de l'orbe.",
        P002 = "0 = mode normal (alpha). 100 = mode additif (plus de punch et luminosite sur fond sombre).",
        P003 = "0 = pas de teinte (couleur originale), 100 = teinte pleine.",
        P004 = "100 = normal, jusqu'a 500 pour tres lumineux.",
        P005 = "100 = normal. Monter pour plus de luminosite, baisser pour assombrir.",
        P006 = "Active la gestion des slots/hotkeys/armes par DiabloOrbs. Si desactive, DiabloOrbs conserve les elements visuels (skins/fonds/jauge ultime) mais laisse la gestion des slots a un autre addon.",
        P007 = "Active le mode additif sur l'endurance de l'orbe combine D4 (sinon seule la magie est utilisee).",
        P008 = "Active ou coupe completement le widget d'ultime central de DiabloOrbs, independamment des autres parties de la barre.",
        P009 = "Active ou coupe les bordures de slots ajoutees par DiabloOrbs en theme D4.",
        P010 = "Active un glow contenu a l'interieur des orbes D4. Desactive = glow plus dramatique qui depasse un peu.",
        P011 = "Active un glow d'alerte lorsqu'une ressource tombe sous le seuil.",
        P012 = "Active un rendu plus lumineux de la separation (utile sur fonds sombres).",
        P013 = "Activer couche de fond teintee",
        P014 = "Activer la lumiere additive",
        P015 = "Activer le glow d'alerte pour seuil bas",
        P016 = "Affiche la valeur numerique du bouclier en theme D4.",
        P017 = "Affiche la valeur numerique du bouclier en theme Legacy.",
        P018 = "Affiche le controle de changement d'arme sur la barre standard et la fleche sur la version dual quand disponible.",
        P019 = "Affiche le fond decoratif derriere la jauge d'ultime.",
        P020 = "Affiche les icones de la barre inactive en arriere-plan en mode Dual, avec le fond dual Legacy. (Theme Legacy uniquement)",
        P021 = "Affiche les reglages separes solo/dual pour affiner l'intensite des contours. L'opacite principale reste le reglage recommande.",
        P022 = "Affiche les slots de la barre inactive en arriere-plan en mode dual. Seul le mode D4 est concerne.",
        P023 = "Affiche les textes/raccourcis clavier sur les slots de la barre d'action quand l'interface clavier est utilisee.",
        P024 = "Affiche ou masque la couche d'ombre des orbes D4.",
        P025 = "Affiche ou masque la couche de fond colore a l'interieur des orbes D4.",
        P026 = "Affiche ou masque la couche de glow lumineux des orbes D4.",
        P027 = "Affiche ou masque la couche de remplissage Smoke des orbes D4.",
        P028 = "Affiche ou masque la surcouche contour des orbes D4.",
        P029 = "Affiche ou masque le contour principal des orbes D4.",
        P030 = "Affiche ou masque le fond de barre, les habillages et les supports visuels de la barre d'action DiabloOrbs.",
        P031 = "Affiche ou masque le slot d'ultime du compagnon sans toucher au reste de la barre.",
        P032 = "Affiche ou masque les slots de competences geres par DiabloOrbs. Pratique pour ne garder que le fond, ou inversement.",
        P033 = "Affiche un trait simple entre mana et endurance.",
        P034 = "Affiche une deuxieme barre en arriere-plan avec la texture dual. Desactiver pour n'afficher qu'une seule barre. (Theme D4 uniquement)",
        P035 = "Afficher fond de jauge ultime",
        P036 = "Afficher l'indicateur de changement d'arme",
        P037 = "Afficher l'ombre",
        P038 = "Afficher l'ultime du compagnon",
        P039 = "Afficher la jauge ultime centrale DiabloOrbs",
        P040 = "Afficher la surcouche",
        P041 = "Afficher le contour",
        P042 = "Afficher le fond colore",
        P043 = "Afficher le fond/support de barre DiabloOrbs",
        P044 = "Afficher le glow",
        P045 = "Afficher le smoke",
        P046 = "Afficher le trait",
        P047 = "Afficher les bordures de slots D4",
        P048 = "Afficher les raccourcis des slots",
        P049 = "Afficher les slots de competences DiabloOrbs",
        P050 = "Afficher reglages avances solo/dual des contours",
        P051 = "Afficher valeur bouclier (D4)",
        P052 = "Afficher valeur bouclier (Legacy)",
        P053 = "Ajoute un voile Smoke teinte par les couleurs d'orbes pour fondre les boutons dans le theme.",
        P054 = "Ajoute une couche de couleur derriere le remplissage des orbes principaux.",
        P055 = "Ajuste l'alignement du remplissage a l'interieur des orbes.",
        P056 = "Ajuste l'ecart des 5 slots centraux en Legacy dual.",
        P057 = "Ajuste l'ecart des 5 slots centraux en Legacy solo.",
        P058 = "Ajuste l'ecart des 5 slots centraux en theme D4.",
        P059 = "Ajuste l'ecartement horizontal des orbes vie/combinee autour du centre en couche 1.",
        P060 = "Ajuste l'ecartement miroir des orbes de la couche additive (magie/endurance).",
        P061 = "Ajuste l'effet de desaturation sur la barre secondaire inactive en mode 2 barres.",
        P062 = "Ajuste l'epaisseur verticale de la jauge ultime en mode dual.",
        P063 = "Ajuste l'epaisseur verticale de la jauge ultime en mode solo.",
        P064 = "Ajuste l'epaisseur visuelle du cercle de bouclier dans l'orbe de vie (theme D4).",
        P065 = "Ajuste l'epaisseur visuelle du cercle de bouclier dans l'orbe de vie (theme Legacy).",
        P066 = "Ajuste l'opacite du visuel de bouclier pour le theme D4.",
        P067 = "Ajuste l'ordre de rendu du bouclier D4. Plus eleve = dessine plus au-dessus.",
        P068 = "Ajuste la hauteur de la couche de fond colore des orbes D4.",
        P069 = "Ajuste la hauteur du fond de barre D4 quand la barre secondaire est activee.",
        P070 = "Ajuste la hauteur du fond de barre D4 quand la barre secondaire est desactivee.",
        P071 = "Ajuste la hauteur du fond de jauge en mode dual.",
        P072 = "Ajuste la hauteur du fond de jauge en mode solo.",
        P073 = "Ajuste la largeur de la couche de fond colore des orbes D4.",
        P074 = "Ajuste la largeur de la jauge ultime en mode dual.",
        P075 = "Ajuste la largeur de la jauge ultime en mode solo.",
        P076 = "Ajuste la largeur du fond de barre D4 quand la barre secondaire est activee.",
        P077 = "Ajuste la largeur du fond de barre D4 quand la barre secondaire est desactivee.",
        P078 = "Ajuste la largeur du fond de jauge en mode dual.",
        P079 = "Ajuste la largeur du fond de jauge en mode solo.",
        P080 = "Ajuste la luminosite de D4OrbFill.dds, utilise ici comme base neutre de l'orbe.",
        P081 = "Ajuste la luminosite de la barre D4 avec les 2 textures de base uniquement. 100 = rendu source, en dessous assombrit, au-dessus eclaircit.",
        P082 = "Ajuste la luminosite du trait de separation.",
        P083 = "Ajuste la luminosite globale du remplissage des orbes. 100% = normal.",
        P084 = "Ajuste la taille de la couche d'ombre des orbes D4.",
        P085 = "Ajuste la taille de la couche de glow des orbes D4.",
        P086 = "Ajuste la taille de la couche de remplissage Smoke des orbes D4.",
        P087 = "Ajuste la taille de la surcouche contour des orbes D4.",
        P088 = "Ajuste la taille du contour principal des orbes D4.",
        P089 = "Ajuste la taille du texte des raccourcis des competences.",
        P090 = "Ajuste la taille globale des orbes D4 et de leurs couches, avec une plage etendue.",
        P091 = "Ajuste la taille reelle du fond de barre D4. 100 = taille source, plus haut agrandit la barre complete, plus bas la reduit.",
        P092 = "Ajuste la transparence du texte des raccourcis des competences.",
        P093 = "Ajuste les touches et icones a l'interieur de la barre D4. Le contenu suit maintenant automatiquement la taille du fond, puis ce reglage affine le resultat.",
        P094 = "Alertes",
        P095 = "Apparence",
        P096 = "Applique une teinte coloree sur le cadre des orbes, les socles, la surcouche contour, le fond de la barre d'action et le fond de la jauge ultime en theme D4.",
        P097 = "Appliquer sur l'endurance",
        P098 = "Assombrissement contour slot compagnon (%)",
        P099 = "Assombrit tous les contours de boutons de competences D4.",
        P100 = "Assombrit uniquement le contour du slot compagnon, sans modifier les autres contours D4.",
        P101 = "Attenue la jauge d'ultime sans impacter le texte affiche dessus.",
        P102 = "Backbar (barre inactive D4)",
        P103 = "Barre d'action — Commun",
        P104 = "Barre d'action — D4",
        P105 = "Base",
        P106 = "Bordures et contours",
        P107 = "Bouclier",
        P108 = "Bouclier D4 : offset horizontal (px)",
        P109 = "Bouclier D4 : offset vertical (px)",
        P110 = "Bouclier Legacy : offset horizontal (px)",
        P111 = "Bouclier Legacy : offset vertical (px)",
        P112 = "Cadre ornemental : taille (px)",
        P113 = "Ces reglages deplacent ou redimensionnent l'ensemble des orbes et socles.",
        P114 = "Choisit la couleur de la couche de fond ajoutee aux orbes.",
        P115 = "Choisit la couleur du texte affiche sur la jauge ultime.",
        P116 = "Choisit la couleur du trait entre mana et endurance.",
        P117 = "Choisit la police utilisee pour les valeurs des orbes et le texte d'ultime. Les polices custom utilisent les fichiers dans DiabloOrbs/Fonts (sinon retour auto a la police ESO).",
        P118 = "Choisit la position des textes de raccourcis des competences: au-dessus, en dessous, ou a l'interieur des cases.",
        P119 = "Choisit le theme des textures (Legacy ou D4). Un reloadui sera lance automatiquement pour appliquer le changement.",
        P120 = "Choisit une variante DDS plus ou moins eclaircie pour les socles sous les orbes.",
        P121 = "Choix de la couleur d'ombrage appliquee derriere le texte au centre des orbes.",
        P122 = "Commun",
        P123 = "Confier la barre d'action a DiabloOrbs",
        P124 = "Contraste contours boutons D4 (%)",
        P125 = "Controle la transparence globale des orbes et de leurs socles.",
        P126 = "Couche 1 : Fond colore",
        P127 = "Couche 1 : ecart entre les orbes (px)",
        P128 = "Couche 1 : hauteur (%)",
        P129 = "Couche 1 : largeur (%)",
        P130 = "Couche 1 : luminosite (%)",
        P131 = "Couche 1 : offset X (px)",
        P132 = "Couche 1 : offset Y (px)",
        P133 = "Couche 1 : offset global X (px)",
        P134 = "Couche 1 : opacite (%)",
        P135 = "Couche 2 : Smoke colore",
        P136 = "Couche 2 : couleur Bouclier D4",
        P137 = "Couche 2 : couleur Endurance D4",
        P138 = "Couche 2 : couleur Magie D4",
        P139 = "Couche 2 : couleur Sante D4",
        P140 = "Couche 2 : ecart centre (px)",
        P141 = "Couche 2 : offset Y (px)",
        P142 = "Couche 2 : offset global X (px)",
        P143 = "Couche 2 : opacite (%)",
        P144 = "Couche 2 : taille (%)",
        P145 = "Couche 3 : Lumiere additive",
        P146 = "Couche 3 : ecart entre les orbes (px)",
        P147 = "Couche 3 : intensite (%)",
        P148 = "Couche 3 : offset X (px)",
        P149 = "Couche 4 : Glow",
        P150 = "Couche 4 : luminosite (%)",
        P151 = "Couche 4 : offset X (px)",
        P152 = "Couche 4 : offset Y (px)",
        P153 = "Couche 4 : opacite (%)",
        P154 = "Couche 4 : taille (%)",
        P155 = "Couche 4 : teinte couleur de l'orbe (%)",
        P156 = "Couche 5 : Ombre",
        P157 = "Couche 5 : ecart entre les orbes (px)",
        P158 = "Couche 5 : offset X (px)",
        P159 = "Couche 5 : offset Y (px)",
        P160 = "Couche 5 : opacite (%)",
        P161 = "Couche 5 : taille (%)",
        P162 = "Couche 6 : Contour principal",
        P163 = "Couche 6 : ecart entre les orbes (px)",
        P164 = "Couche 6 : offset X (px)",
        P165 = "Couche 6 : offset Y (px)",
        P166 = "Couche 6 : opacite (%)",
        P167 = "Couche 6 : taille (%)",
        P168 = "Couche 7 : Trait de separation",
        P169 = "Couche 7 : couleur",
        P170 = "Couche 7 : hauteur (% de l'orbe)",
        P171 = "Couche 7 : largeur (px)",
        P172 = "Couche 7 : luminosite (%)",
        P173 = "Couche 7 : mode additif",
        P174 = "Couche 7 : offset X (px)",
        P175 = "Couche 7 : offset Y (px)",
        P176 = "Couche 7 : opacite (%)",
        P177 = "Couche 7 : taille (% de l'orbe)",
        P178 = "Couche 8 : Surcouche contour",
        P179 = "Couche 8 : contraste (%)",
        P180 = "Couche 8 : ecart entre les orbes (px)",
        P181 = "Couche 8 : luminosite (%)",
        P182 = "Couche 8 : offset X (px)",
        P183 = "Couche 8 : offset Y (px)",
        P184 = "Couche 8 : opacite (%)",
        P185 = "Couche 8 : taille (%)",
        P186 = "Couleur Bouclier (Legacy)",
        P187 = "Couleur Endurance (Legacy)",
        P188 = "Couleur Magie (Legacy)",
        P189 = "Couleur Sante (Legacy)",
        P190 = "Couleur appliquee sur les elements D4 (cadre, socles, surcouche, barre, jauge).",
        P191 = "Couleur couche teintee",
        P192 = "Couleur de remplissage de l'orbe d'endurance en theme Legacy.",
        P193 = "Couleur de remplissage de l'orbe de magie en theme Legacy.",
        P194 = "Couleur de remplissage de l'orbe de sante en theme Legacy.",
        P195 = "Couleur de teinte D4",
        P196 = "Couleur du bouclier en theme Legacy.",
        P197 = "Couleur du fond de jauge",
        P198 = "Couleur du glow d'alerte basse ressource pour l'orbe d'endurance.",
        P199 = "Couleur du glow d'alerte basse ressource pour l'orbe de magie.",
        P200 = "Couleur du glow d'alerte basse ressource pour l'orbe de sante.",
        P201 = "Couleur du remplissage Smoke pour l'orbe d'endurance D4.",
        P202 = "Couleur du remplissage Smoke pour l'orbe de magie D4.",
        P203 = "Couleur du remplissage Smoke pour l'orbe de sante D4.",
        P204 = "Couleur du remplissage Smoke pour le bouclier D4.",
        P205 = "Couleur glow d'alerte Endurance (RGB)",
        P206 = "Couleur glow d'alerte Magie (RGB)",
        P207 = "Couleur glow d'alerte Sante (RGB)",
        P208 = "Couleur ombrage texte interieur",
        P209 = "Couleur texte ultime",
        P210 = "Couleurs",
        P211 = "D4 : ecart horizontal des 5 slots (px)",
        P212 = "Decalage remplissage — Orbe Sante (px)",
        P213 = "Decalage remplissage — Orbe combine (px)",
        P214 = "Decalage vertical (px)",
        P215 = "Decale horizontalement le texte des raccourcis sur les slots.",
        P216 = "Decale l'ultime horizontalement par rapport au slot 5.",
        P217 = "Decale l'ultime horizontalement.",
        P218 = "Decale l'ultime verticalement par rapport aux autres slots.",
        P219 = "Decale l'ultime verticalement.",
        P220 = "Decale la backbar Legacy vers la gauche ou la droite.",
        P221 = "Decale la backbar Legacy vers le haut (negatif) ou le bas.",
        P222 = "Decale la backbar vers la gauche ou la droite par rapport a la barre active.",
        P223 = "Decale la backbar vers le haut (negatif) ou le bas par rapport a la barre active. Par defaut -28 pour voir environ 20% des slots.",
        P224 = "Decale la couche 1 entiere a gauche/droite, sans toucher l'ecart des orbes.",
        P225 = "Decale la couche Smoke vers le haut ou le bas.",
        P226 = "Decale la couche d'ombre a gauche ou a droite.",
        P227 = "Decale la couche d'ombre vers le haut ou le bas.",
        P228 = "Decale la couche de fond colore vers le haut ou le bas.",
        P229 = "Decale la couche de glow a gauche ou a droite.",
        P230 = "Decale la couche de glow vers le haut ou le bas.",
        P231 = "Decale la couche de remplissage (smoke) a l'interieur des orbes : sante vers la gauche et combinee vers la droite du meme montant.",
        P232 = "Decale la surcouche contour a gauche ou a droite.",
        P233 = "Decale la surcouche contour vers le haut ou le bas.",
        P234 = "Decale le contour principal a gauche ou a droite.",
        P235 = "Decale le contour principal vers le haut ou le bas.",
        P236 = "Decale le slot raccourci en Legacy dual.",
        P237 = "Decale le slot raccourci en Legacy solo.",
        P238 = "Decale le slot ultime en Legacy dual.",
        P239 = "Decale le slot ultime en Legacy solo.",
        P240 = "Decale le trait de separation a gauche ou a droite.",
        P241 = "Decale le trait de separation vers le haut ou le bas.",
        P242 = "Decale uniquement la couche de remplissage (smoke) a l'interieur de l'orbe combinee mana/endurance sur l'axe X.",
        P243 = "Decale uniquement la couche de remplissage (smoke) a l'interieur de l'orbe de vie sur l'axe X.",
        P244 = "Decale verticalement le texte des raccourcis sur les slots.",
        P245 = "Deplace horizontalement la valeur de l'orbe gauche (sante) autour du centre.",
        P246 = "Deplace independamment le texte du bouclier en D4.",
        P247 = "Deplace independamment le texte du bouclier en Legacy.",
        P248 = "Deplace l'objet de raccourci (quickslot) a gauche ou droite dans la barre D4. Utile pour recaler l'alignement apres changement de taille.",
        P249 = "Deplace l'objet de raccourci (quickslot) vers le haut ou bas independamment du fond de barre.",
        P250 = "Deplace le slot ultime a gauche ou droite dans la barre D4 (negatif = vers la gauche). Utile pour recaler l'alignement apres changement de taille.",
        P251 = "Deplace le slot ultime vers le haut ou bas independamment du fond de barre.",
        P252 = "Deplace les 3 instances de la couche de fond (sante + mana + endu) dans la meme direction.",
        P253 = "Deplace les 3 instances de la couche de remplissage (sante + mana + endu) dans la meme direction.",
        P254 = "Deplace les 5 slots centraux en mode dual.",
        P255 = "Deplace les 5 slots centraux en mode solo.",
        P256 = "Deplace les orbes vers le haut ou le bas en mode dual.",
        P257 = "Deplace les orbes vers le haut ou le bas en mode solo.",
        P258 = "Deplace verticalement les deux glows D4 en meme temps, en conservant le miroir parfait gauche/droite.",
        P259 = "Deplace verticalement les deux glows en meme temps, en conservant le miroir parfait gauche/droite.",
        P260 = "Desaturation (%)",
        P261 = "Desaturation barre inactive 2 barres (%)",
        P262 = "Desature les icones de la backbar pour les distinguer visuellement de la barre active.",
        P263 = "Desature les icones pour les distinguer de la barre active.",
        P264 = "Distance des orbes depuis le centre de l'ecran en mode solo.",
        P265 = "Distance des orbes depuis le centre en mode dual (barre secondaire activee).",
        P266 = "Ecart des glows D4 depuis le centre (px)",
        P267 = "Ecart des glows depuis le centre (px)",
        P268 = "Ecart entre chaque slot de competence de la backbar.",
        P269 = "Ecart entre chaque slot.",
        P270 = "Ecart horizontal des 5 slots (px)",
        P271 = "Ecart raccourci depuis le bord (px)",
        P272 = "Ecart symetrique du remplissage (px)",
        P273 = "Ecart ultime (px)",
        P274 = "Ecart ultime depuis le bord (px)",
        P275 = "Ecarte la couche d'ombre : sante vers la gauche, mana/endu vers la droite.",
        P276 = "Ecarte la couche d'overlay : sante vers la gauche, mana/endu vers la droite.",
        P277 = "Ecarte la couche de contour : sante vers la gauche, mana/endu vers la droite.",
        P278 = "Ecarte les orbes par rapport a la barre en mode dual.",
        P279 = "Ecarte les orbes par rapport a la barre en mode solo.",
        P280 = "Ecarte ou rapproche les valeurs mana/endurance du centre de l'orbe scinde.",
        P281 = "Ecartement depuis le centre — Dual (px)",
        P282 = "Ecartement depuis le centre — Solo (px)",
        P283 = "Ecartement horizontal (px)",
        P284 = "Echelle (%)",
        P285 = "Echelle contenu barre D4 (%)",
        P286 = "Eclairci = texte clair avec ombrage sombre. Assombri = texte fonce avec ombrage clair.",
        P287 = "Eloigne ou rapproche les glows D4 de magicka et stamina par rapport au centre.",
        P288 = "Eloigne ou rapproche les glows de magicka et stamina par rapport au centre. Augmentez pour plus d'ecart.",
        P289 = "En mode legacy, chaque moitie (mana/endurance) gere son propre etat d'alerte.",
        P290 = "Espace supplementaire entre le slot 5 et l'ultime.",
        P291 = "Espacement slots (px)",
        P292 = "Exterieur : padding horizontal (px)",
        P293 = "Exterieur : padding vertical (px)",
        P294 = "Exterieur = position classique. Interieur = texte place au centre des orbes.",
        P295 = "Fond",
        P296 = "Fond de barre D4",
        P297 = "Fond dual (DiabloOrbsDualBarXp)",
        P298 = "Fond solo (ActionBarXp)",
        P299 = "Force une ombre interne minimale pour verifier l'imbrication des couches.",
        P300 = "Fractionner alerte orbe combine",
        P301 = "General",
        P302 = "Glow : taille (px)",
        P303 = "Glow interne strict D4 (sans debordement)",
        P304 = "Habillage des boutons de la barre d'action en theme D4 : bordures, smoke, compagnon.",
        P305 = "Hauteur du trait de separation en pourcentage de la taille de l'orbe.",
        P306 = "Hauteur fond D4 avec barre secondaire (%)",
        P307 = "Hauteur fond D4 sans barre secondaire (%)",
        P308 = "Hauteur fond jauge dual (px)",
        P309 = "Hauteur fond jauge solo (px)",
        P310 = "Hauteur jauge ultime dual (px)",
        P311 = "Hauteur jauge ultime solo (px)",
        P312 = "Infos et valeurs",
        P313 = "Intensite additionnelle contours D4 dual (%)",
        P314 = "Intensite additionnelle contours D4 solo (%)",
        P315 = "Intensite de l'overlay additif D4OrbBack2.",
        P316 = "Intensite de la teinte (%)",
        P317 = "Intensite du reflet permanent hors alerte ressource.",
        P318 = "Intensite max du glow d'alerte D4 (%)",
        P319 = "Intensite maximale de l'aureole lumineuse autour des orbes D4 lors d'une alerte ressource.",
        P320 = "Intensite smoke boutons D4 (%)",
        P321 = "Interieur : ecart miroir mana/endu (px)",
        P322 = "Interieur : orbe gauche offset horizontal (px)",
        P323 = "Inverse l'emplacement horizontal des valeurs mana et endurance quand l'affichage est en mode interieur. Independant par theme (D4 / Legacy).",
        P324 = "Inverser mana/endurance (interieur)",
        P325 = "Jauge",
        P326 = "Jauge ultime",
        P327 = "La police est commune; la taille des textes orbes et jauge ultime est reglee separement.",
        P328 = "Label — D4",
        P329 = "Label — Legacy",
        P330 = "Langue de l'interface",
        P331 = "Largeur du trait de separation en pixels.",
        P332 = "Largeur fond D4 avec barre secondaire (%)",
        P333 = "Largeur fond D4 sans barre secondaire (%)",
        P334 = "Largeur fond jauge dual (%)",
        P335 = "Largeur fond jauge solo (%)",
        P336 = "Largeur jauge ultime dual (%)",
        P337 = "Largeur jauge ultime solo (%)",
        P338 = "Le fond suit le theme actif (D4: fond_jauge.dds, Legacy: UltimateGaugeBackground.dds). Les sliders ci-dessous pilotent taille/offset/opacite.",
        P339 = "Le texte ultime est independant du pulse de la jauge et reste lisible en permanence.",
        P340 = "Legacy — Fond et backbar",
        P341 = "Luminosite barre D4 (%)",
        P342 = "Luminosite des socles (preset)",
        P343 = "Luminosite du fond (%)",
        P344 = "Luminosite globale (%)",
        P345 = "Luminosite globale du fond (%)",
        P346 = "Mode 2 barres: ces reglages s'appliquent a la barre secondaire affichee en permanence quand un systeme dual est detecte.",
        P347 = "Monte ou descend independamment le texte du bouclier en D4.",
        P348 = "Monte ou descend independamment le texte du bouclier en Legacy.",
        P349 = "Monte ou descend la barre en mode dual (barre secondaire activee).",
        P350 = "Monte ou descend la barre en mode solo (barre secondaire desactivee).",
        P351 = "Monte ou descend la jauge ultime en mode dual.",
        P352 = "Monte ou descend la jauge ultime en mode solo.",
        P353 = "Monte ou descend le fond de jauge en mode dual.",
        P354 = "Monte ou descend le fond de jauge en mode solo.",
        P355 = "Monte ou descend le texte des valeurs des orbes.",
        P356 = "Monte/descend les orbes et socles en mode dual (barre secondaire activee).",
        P357 = "Monte/descend les orbes et socles en mode solo (barre secondaire desactivee).",
        P358 = "Niveau de couche bouclier D4",
        P359 = "Noirceur contours boutons D4 (%)",
        P360 = "Offset X raccourcis (px)",
        P361 = "Offset X ultime (px)",
        P362 = "Offset Y raccourcis (px)",
        P363 = "Offset Y ultime (px)",
        P364 = "Offset horizontal (px)",
        P365 = "Offset slot raccourci D4 (px)",
        P366 = "Offset slot ultime D4 (px)",
        P367 = "Offset vertical (px)",
        P368 = "Offset vertical 5 slots - dual bar (px)",
        P369 = "Offset vertical 5 slots - solo bar (px)",
        P370 = "Offset vertical barre - Dual (px)",
        P371 = "Offset vertical barre - Solo (px)",
        P372 = "Offset vertical fond jauge dual (px)",
        P373 = "Offset vertical fond jauge solo (px)",
        P374 = "Offset vertical glow D4 (px)",
        P375 = "Offset vertical glow miroir (px)",
        P376 = "Offset vertical jauge ultime dual (px)",
        P377 = "Offset vertical jauge ultime solo (px)",
        P378 = "Offset vertical slot raccourci D4 (px)",
        P379 = "Offset vertical slot ultime D4 (px)",
        P380 = "Offset vertical texte valeurs (px)",
        P381 = "Ombre interne : taille (px)",
        P382 = "Ombre minimale D4 (%)",
        P383 = "Opacite (%)",
        P384 = "Opacite barre inactive 2 barres (%)",
        P385 = "Opacite bordure tooltip valeurs (%)",
        P386 = "Opacite contours boutons D4 (%)",
        P387 = "Opacite couche teintee (%)",
        P388 = "Opacite des raccourcis (%)",
        P389 = "Opacite du bouclier D4 (%)",
        P390 = "Opacite du bouclier Legacy (%)",
        P391 = "Opacite du glow d'alerte basse ressource.",
        P392 = "Opacite fond contraste interieur (%)",
        P393 = "Opacite fond de jauge (%)",
        P394 = "Opacite globale orbes + socles (%)",
        P395 = "Opacite glow d'alerte (%)",
        P396 = "Opacite ombrage texte interieur (%)",
        P397 = "Opacite remplissage jauge (%)",
        P398 = "Opacite texte ultime (%)",
        P399 = "Opacite texte valeurs (%)",
        P400 = "Options communes de la barre d'action DiabloOrbs. Les reglages marques solo/dual permettent un comportement distinct selon le mode detecte.",
        P401 = "Orbes D4",
        P402 = "Orbes Legacy",
        P403 = "Organisation: famille de police commune, puis reglages separes pour valeurs des orbes et texte de jauge ultime.",
        P404 = "Police des nombres (commun tous themes)",
        P405 = "Position des raccourcis",
        P406 = "Position des valeurs",
        P407 = "Position et taille",
        P408 = "Position et taille — reglages globaux",
        P409 = "Position orbes — Dual",
        P410 = "Position orbes — Solo",
        P411 = "Position verticale des orbes — Dual (px)",
        P412 = "Position verticale des orbes — Solo (px)",
        P413 = "Raccourcis",
        P414 = "Raccourcis visibles seulement en combat",
        P415 = "Redimensionne homothetiquement tous les calques des orbes Legacy ensemble.",
        P416 = "Reflet au repos D4 (%)",
        P417 = "Reglage avance: intensite dual multipliee avec l'opacite principale.",
        P418 = "Reglage avance: intensite solo multipliee avec l'opacite principale.",
        P419 = "Reglage principal de l'opacite des contours de boutons D4 (raccourci, 5 slots, ultime et compagnon).",
        P420 = "Reglages generaux de DiabloOrbs.",
        P421 = "Reglages independants par theme (D4 ou Legacy), avec valeurs distinctes solo/dual.",
        P422 = "Regle l'ecart lateral des valeurs exterieures par rapport aux bords des orbes.",
        P423 = "Regle l'opacite de la barre secondaire inactive quand une configuration 2 barres est detectee.",
        P424 = "Regle l'opacite de la bordure decorative autour du texte des valeurs.",
        P425 = "Regle l'opacite de la couche d'ombre des orbes D4.",
        P426 = "Regle l'opacite de la couche de couleur supplementaire derriere les orbes.",
        P427 = "Regle l'opacite de la couche de fond colore des orbes D4.",
        P428 = "Regle l'opacite de la couche de glow des orbes D4.",
        P429 = "Regle l'opacite de la couche de remplissage Smoke des orbes D4.",
        P430 = "Regle l'opacite de la surcouche contour des orbes D4.",
        P431 = "Regle l'opacite de la vraie ombre de texte appliquee derriere les valeurs placees dans l'orbe.",
        P432 = "Regle l'opacite du contour principal des orbes D4.",
        P433 = "Regle l'opacite du fond de contraste derriere les valeurs placees dans l'orbe.",
        P434 = "Regle l'opacite du texte de la jauge ultime sans affecter le pulse de la barre.",
        P435 = "Regle l'opacite du texte des valeurs, quel que soit son placement.",
        P436 = "Regle l'opacite du trait de separation mana/endurance.",
        P437 = "Regle la luminosite generale du fond colore Smoke.dds des orbes D4.",
        P438 = "Regle la position haut/bas des valeurs exterieures.",
        P439 = "Regle la taille de la police du texte affiche sur la jauge ultime.",
        P440 = "Regle la transparence du fond de jauge sans toucher au texte.",
        P441 = "Remet tous les reglages D4 a leurs valeurs calibrees par defaut. N'affecte pas les reglages Legacy.",
        P442 = "Remet tous les reglages Legacy a leurs valeurs par defaut. N'affecte pas les reglages D4.",
        P443 = "Remplissage — decalage fin",
        P444 = "Renforce le contraste du contour (100 = normal, >100 = plus marque).",
        P445 = "Renforce ou adoucit la couleur du fond Smoke.dds pour toutes les ressources D4.",
        P446 = "Reset D4 (positions par defaut)",
        P447 = "Reset Legacy (positions par defaut)",
        P448 = "Separateur central : taille (px)",
        P449 = "Si active, les raccourcis de competences s'affichent uniquement en combat.",
        P450 = "Slots — Dual",
        P451 = "Slots — Solo",
        P452 = "Style texte interieur",
        P453 = "Superpose D4OrbBack2 en mode additif pour eclaircir l'orbe sans recolorer le fond.",
        P454 = "Taille de chaque icone de la backbar en pixels.",
        P455 = "Taille de chaque icone en pixels.",
        P456 = "Taille de la couche d'ombre interne (Shade.dds) des orbes Legacy. 150 = valeur par defaut.",
        P457 = "Taille des orbes (px)",
        P458 = "Taille des raccourcis (%)",
        P459 = "Taille des slots de la backbar. 80 = plus petits que la barre active pour accentuer la profondeur.",
        P460 = "Taille du cadre circulaire des orbes Legacy. 166 = valeur XML par defaut. Reduire pour eviter le depassement quand les orbes sont agrandis.",
        P461 = "Taille du cercle bouclier D4 (%)",
        P462 = "Taille du cercle bouclier Legacy (%)",
        P463 = "Taille du glow d'alerte basse ressource par rapport a la taille normale du glow. 100 = identique.",
        P464 = "Taille du glow des orbes Legacy. 150 = valeur par defaut.",
        P465 = "Taille du separateur entre Magie et Endurance (Split.dds). 166 = valeur par defaut.",
        P466 = "Taille fond barre D4 (%)",
        P467 = "Taille globale de la backbar Legacy.",
        P468 = "Taille globale des orbes (%)",
        P469 = "Taille globale du separateur en pourcentage de la taille de l'orbe.",
        P470 = "Taille glow d'alerte (%)",
        P471 = "Taille police texte ultime",
        P472 = "Taille slots (px)",
        P473 = "Taille slots backbar (px)",
        P474 = "Teinte appliquee au fond de jauge.",
        P475 = "Teinte globale D4",
        P476 = "Texte",
        P477 = "Texte et valeurs",
        P478 = "Theme visuel",
        P479 = "Translate les deux orbes de la couche additive ensemble a gauche/droite.",
        P480 = "Transparence de la backbar. 0 = invisible, 100 = opaque.",
        P481 = "Transparence des icones de la backbar Legacy.",
        P482 = "Typographie commune",
        P483 = "Valeur positive = mana/endu s'ecartent du centre (smoke layer), valeur negative = elles se rapprochent.",
        P484 = "Valeurs des orbes",
        P485 = "Visuel — D4",
        P486 = "Visuel — Legacy",
        P487 = "[Theme D4] Activer la barre secondaire (mode Dual)",
        P488 = "[Theme Legacy] Activer la barre secondaire (mode Dual)",
        P489 = "|cFFAA00[!] Pour un rendu optimal (solo et dual), activez dans|r |cFFFFFFReglages > Combat|r |cFFAA00:|r |cFFFFFF\"Rangee arriere de la barre de competences\"|r |cFFAA00et|r |cFFFFFF\"Minuteries de barre de competences\"|r|cFFAA00. (Tous themes)|r",
        P490 = "Profils",
        P491 = "Gerez vos profils de reglages. Un profil sauvegarde l'ensemble de vos parametres visuels. Vous pouvez partager un profil entre plusieurs personnages du meme compte.",
        P492 = "Profil actif",
        P493 = "Selectionner le profil a charger. Cliquez sur 'Charger le profil' pour appliquer.",
        P494 = "Charger le profil selectionne",
        P495 = "Applique les reglages du profil selectionne sur ce personnage.",
        P496 = "Sauvegarder (ecraser le profil actif)",
        P497 = "Ecrase le profil actif avec vos reglages actuels.",
        P498 = "Sauvegarder sous... (nouveau nom)",
        P499 = "Cree un nouveau profil avec le nom saisi, et vos reglages actuels.",
        P500 = "Creer ce nouveau profil",
        P501 = "Cree ou ecrase un profil avec le nom saisi ci-dessus.",
        P502 = "Supprimer le profil selectionne",
        P503 = "Supprime le profil selectionne ('D4 default' et 'Legacy default' sont proteges).",
        P504 = "Decorations (Angel / Demon)",
        P505 = "Afficher les decorations (Angel / Demon)",
        P506 = "Premier plan (devant les orbes)",
        P507 = "Inverser les cotes (Angel/Demon)",
        P508 = "Cadre ornemental : taille (px)",
        P509 = "Ombre interne : taille (px)",
        P510 = "Separateur central : taille (px)",
        P511 = "Glow : taille (px)",
        P512 = "Taille de base (px)",
        P513 = "Largeur (%)",
        P514 = "Hauteur (%)",
        P515 = "Ecartement depuis le centre (px)",
        P516 = "Decalage vertical (px)",
        P517 = "Taille du cadre circulaire des orbes Legacy. 166 = valeur XML par defaut. Reduire pour eviter le depassement quand les orbes sont agrandis. [ID: B93]",
        P518 = "Taille de la couche d'ombre interne (Shade.dds) des orbes Legacy. 150 = valeur par defaut. [ID: B94]",
        P519 = "Taille du separateur entre Magie et Endurance (Split.dds). 166 = valeur par defaut. [ID: B95]",
        P520 = "Taille du glow des orbes Legacy. 150 = valeur par defaut. [ID: B96]",
        P521 = "Affiche ou masque les images decoratives Angel et Demon de chaque cote des orbes (Legacy uniquement). [ID: LD10]",
        P522 = "Taille de reference des images Angel et Demon. La largeur et hauteur sont des pourcentages de cette valeur. [ID: LD11]",
        P523 = "Distance horizontale entre le centre de l'ecran et chaque image. 0 = centre. [ID: LD12]",
        P524 = "Deplace les decorations vers le haut (negatif) ou le bas (positif). [ID: LD13]",
        P525 = "Affiche les decorations devant tous les elements. Desactive = arriere-plan. [ID: LD14]",
        P526 = "Echange les positions : Angel a gauche, Demon a droite. [ID: LD15]",
        P527 = "Largeur en % de la taille de base. [ID: LD16]",
        P528 = "Hauteur en % de la taille de base. [ID: LD17]",
        P529 = "Ce profil est protege et ne peut pas etre ecrase.",
        P530 = "Ce profil est protege et ne peut pas etre supprime.",
        P531 = "Veuillez entrer un nom de profil.",
        P532 = "Ce nom de profil est protege et ne peut pas etre utilise.",
    },
    de = {
        DESC = "DiabloOrbs-Einstellungen.",
        SECTION_LANGUAGE = "Sprache",
        LANG_MODE_NAME = "Addon-Sprache",
        LANG_MODE_TIP = "Auto nutzt die Spielsprache. Manuell erzwingt die gewahlte Sprache.",
        LANG_MODE_AUTO = "Auto (Spielsprache)",
        LANG_MODE_HINT = "Falls einige Texte nicht sofort aktualisiert werden, schliesse und offne das Einstellungsfenster erneut.",
        SECTION_ULTIMATE = "Ultimative Leiste",
        SHOW_ULTIMATE_BAR_NAME = "Ultimative Leiste anzeigen",
        SHOW_ULTIMATE_BAR_TIP = "Zeigt oder versteckt die zentrale Ultimative-Leiste.",
        SHOW_ULTIMATE_TEXT_NAME = "Aktuell/Kosten auf Leiste anzeigen",
        SHOW_ULTIMATE_TEXT_TIP = "Zeigt den Ultimative-Fortschritt direkt auf der Leiste.",
        ULTIMATE_TEXT_MODE_NAME = "Ultimative Textformat",
        ULTIMATE_TEXT_MODE_TIP = "Wahlt das auf der Ultimative-Leiste angezeigte Format.",
        ULTIMATE_TEXT_MODE_VALUE = "Wert (aktuell/kosten)",
        ULTIMATE_TEXT_MODE_PERCENT = "Prozent",
        ULTIMATE_READY_COLOR_NAME = "Farbe bei bereiter Ultimative",
        ULTIMATE_READY_COLOR_TIP = "Farbe der zentralen Leiste, wenn Ultimative bereit ist.",
        ULTIMATE_PULSE_SPEED_NAME = "Pulse-Geschwindigkeit",
        ULTIMATE_PULSE_SPEED_TIP = "Blinkgeschwindigkeit bei bereiter Ultimative.",
        ULTIMATE_PULSE_MIN_NAME = "Pulse Min-Alpha (%)",
        ULTIMATE_PULSE_MIN_TIP = "Minimale Pulse-Transparenz der Ultimative-Leiste.",
        ULTIMATE_PULSE_MAX_NAME = "Pulse Max-Alpha (%)",
        ULTIMATE_PULSE_MAX_TIP = "Maximale Pulse-Transparenz der Ultimative-Leiste.",
        SECTION_ALERT = "Ressourcen-Warnungen",
        LOW_RESOURCE_NAME = "Niedrige-Ressourcen-Schwelle (%)",
        LOW_RESOURCE_TIP = "Aktiviert den Glow-Effekt, wenn eine Ressource unter diesen Wert fallt.",
        GLOW_MAX_NAME = "Max. Warn-Glow-Intensitat (%)",
        GLOW_MAX_TIP = "Maximale Halo-Intensitat um Orbs bei Warnung.",
        GLOW_INTERNAL_NAME = "Strikter interner Glow",
        GLOW_INTERNAL_TIP = "Glow nur innerhalb der Orb-Grenzen. Deaktivieren fur dramatischeren Glow.",
        BORDER_PULSE_ENABLE_NAME = "Rahmen-Farbpulse aktivieren",
        BORDER_PULSE_ENABLE_TIP = "Bei niedriger Ressource pulsiert der Ornamentrahmen in der gewahlten Farbe.",
        BORDER_PULSE_COLOR_NAME = "Warn-Pulse-Farbe",
        BORDER_PULSE_COLOR_TIP = "Rahmenfarbe bei niedriger Ressource.",
        SECTION_ORB_STYLE = "Orbs - Stil",
        SMOKE_ALPHA_NAME = "Smoke-Transparenz (%)",
        SMOKE_ALPHA_TIP = "Passt die Smoke-Effekt-Deckkraft der Ressourcen-Orbs an.",
        SMOKEBG_BRIGHTNESS_NAME = "Orb-Hintergrund-Helligkeit (%)",
        SMOKEBG_BRIGHTNESS_TIP = "0% = dunkel, 100% = heller.",
        ORB_COLOR_BOOST_NAME = "Globale Farbintensitat (%)",
        ORB_COLOR_BOOST_TIP = "Globaler Farb-Boost fur Orbs.",
        SHADE_ALPHA_NAME = "Intensitat der dunklen Innenschattierung (%)",
        SHADE_ALPHA_TIP = "0% = keine Schattierung, 100% = volle Schattierung.",
        BORDER_ALPHA_NAME = "Kreisrahmen-Deckkraft (%)",
        BORDER_ALPHA_TIP = "Deckkraft des Ornamentrahmens.",
        SPLIT_ALPHA_NAME = "Trennlinien-Deckkraft (%)",
        SPLIT_ALPHA_TIP = "Deckkraft der Trennlinie zwischen Magicka und Ausdauer.",
        SHIELD_ALPHA_NAME = "Schild-Deckkraft (%)",
        SHIELD_ALPHA_TIP = "Deckkraft des Schild-Effekts.",
        SHIELD_RING_SCALE_NAME = "Schildring-Grosse (%)",
        SHIELD_RING_SCALE_TIP = "Visuelle Dicke/Grosse des Schildrings im Lebens-Orb.",
        SHIELD_VISUAL_RESPONSE_NAME = "Schild visuelle Reaktion (%)",
        SHIELD_VISUAL_RESPONSE_TIP = "Hoch = schnellere visuelle Reaktion. 100% = linear.",
        SECTION_ORB_COLORS = "Orbs - Farben",
        HEALTH_COLOR_NAME = "Lebens-Orb-Farbe",
        MAGICKA_COLOR_NAME = "Magicka-Orb-Farbe",
        STAMINA_COLOR_NAME = "Ausdauer-Orb-Farbe",
        SHIELD_COLOR_NAME = "Schild-Orb-Farbe",
        SECTION_TEXT = "Wert-Beschriftungen",
        LABEL_SCALE_NAME = "Werttext-Grosse (%)",
        LABEL_SCALE_TIP = "Passt die Grosse von Wert-/Prozent-Labels auf den Orbs an.",
        LABEL_FORMAT_NAME = "Ressourcenwert-Anzeige",
        LABEL_FORMAT_TIP = "Wahlt die Anzeige der Zahlenwerte auf den Orbs.",
        LABEL_FORMAT_HIDDEN = "Versteckt",
        LABEL_FORMAT_VALUE = "Wert (z.B. 23k)",
        LABEL_FORMAT_PERCENT = "Prozent (z.B. 75%)",
        ULT_TT_READY_OVER = "Ultimativ: <<1>> / <<2>> (Bereit, +<<3>>)",
        ULT_TT_READY = "Ultimativ: <<1>> / <<2>> (Bereit)",
        ULT_TT_NORMAL = "Ultimativ: <<1>> / <<2>>",
        P001 = "0 = reines weisses glow. 100 = glow in orbfarbe getoent.",
        P002 = "0 = normalmodus (alpha). 100 = additiver modus (mehr punch und helligkeit auf dunklem hintergrund).",
        P003 = "0 = keine toenung (originalfarbe), 100 = volle toenung.",
        P004 = "100 = normal, bis 500 fuer sehr hell.",
        P005 = "100 = normal. Hoeher fuer mehr helligkeit, niedriger zum abdunkeln.",
        P006 = "Aktiviert DiabloOrbs slot/hotkey/waffen-handling. Aus = DiabloOrbs behaelt optik (skins/hintergruende/ultimate-leiste), slot-handling bleibt anderem addon.",
        P007 = "Additiven modus fuer stamina am kombinierten D4-orbe (sonst nur magicka).",
        P008 = "Schaltet das zentrale DiabloOrbs ultimate-widget komplett, unabhaengig vom rest der leiste.",
        P009 = "Schaltet von DiabloOrbs hinzugefuegte slot-raender im D4-theme ein oder aus.",
        P010 = "Glow innerhalb der D4-orbe. Aus = dramatischerer glow der etwas uebersteht.",
        P011 = "Warn-glow wenn eine ressource unter die schwelle faellt.",
        P012 = "Helleres rendering der trennlinie (nuetzlich auf dunklem hintergrund).",
        P013 = "Getonte hintergrundebene aktivieren",
        P014 = "Additives licht aktivieren",
        P015 = "Warn-glow bei niedriger schwelle aktivieren",
        P016 = "Zeigt den schild-zahlenwert im D4-theme.",
        P017 = "Zeigt den schild-zahlenwert im Legacy-theme.",
        P018 = "Zeigt waffenwechsel auf der standardleiste und den pfeil im dual-layout wenn verfuegbar.",
        P019 = "Dekorativen hintergrund hinter der ultimate-leiste anzeigen.",
        P020 = "Zeigt inaktive leisten-faehigkeits-ikonen im hintergrund im dual-modus mit dual-legacy-hintergrund. (nur Legacy-theme)",
        P021 = "Separate solo/dual-einstellungen zur feinanpassung der kontur-intensitaet. hauptopazitaet bleibt empfohlene regelung.",
        P022 = "Zeigt slots der inaktiven leiste im hintergrund im dual-modus. nur D4-layout betroffen.",
        P023 = "Zeigt texte/hotkeys auf aktionsleisten-slots bei tastatur-ui.",
        P024 = "Schattenebene auf D4-orben ein- oder ausblenden.",
        P025 = "Gefaerbte fuell-ebene innerhalb der D4-orbe ein- oder ausblenden.",
        P026 = "Helle glow-ebene auf D4-orben ein- oder ausblenden.",
        P027 = "Smoke-fuell-ebene auf D4-orben ein- oder ausblenden.",
        P028 = "Kontur-overlay auf D4-orben ein- oder ausblenden.",
        P029 = "Hauptkontur auf D4-orben ein- oder ausblenden.",
        P030 = "Leisten-untergrund, zierleisten und visuelle halter der DiabloOrbs-aktionsleiste ein- oder ausblenden.",
        P031 = "Begleiter-ultimate-slot ohne den rest der leiste ein- oder ausblenden.",
        P032 = "Von DiabloOrbs verwaltete faehigkeits-slots ein- oder ausblenden. praktisch um nur den hintergrund zu behalten oder umgekehrt.",
        P033 = "Zeigt eine einfache linie zwischen magicka und stamina.",
        P034 = "Zweite leiste im hintergrund mit dual-textur. aus fuer nur eine leiste. (nur D4-theme)",
        P035 = "Hintergrund der ultimate-leiste anzeigen",
        P036 = "Waffenwechsel-anzeige anzeigen",
        P037 = "Schatten anzeigen",
        P038 = "Begleiter-ultimate anzeigen",
        P039 = "Zentrale DiabloOrbs ultimate-leiste anzeigen",
        P040 = "Overlay anzeigen",
        P041 = "Kontur anzeigen",
        P042 = "Gefaerbte fuellung anzeigen",
        P043 = "DiabloOrbs leisten-untergrund/support anzeigen",
        P044 = "Glow anzeigen",
        P045 = "Smoke anzeigen",
        P046 = "Trennlinie anzeigen",
        P047 = "D4-slot-raender anzeigen",
        P048 = "Slot-hotkeys anzeigen",
        P049 = "DiabloOrbs faehigkeits-slots anzeigen",
        P050 = "Erweiterte solo/dual-kontur-einstellungen anzeigen",
        P051 = "Schild-wert anzeigen (D4)",
        P052 = "Schild-wert anzeigen (Legacy)",
        P053 = "Smoke-schleier in orbfarben zum einbinden der buttons ins theme.",
        P054 = "Farbebene hinter der fuellung der haupt-orbe.",
        P055 = "Richtet die fuellung innerhalb der orbe aus.",
        P056 = "Abstand der 5 mittleren slots im Legacy-dual.",
        P057 = "Abstand der 5 mittleren slots im Legacy-solo.",
        P058 = "Abstand der 5 mittleren slots im D4-theme.",
        P059 = "Horizontaler abstand der lebens/kombi-orbe um die mitte auf ebene 1.",
        P060 = "Spiegel-abstand der additiv-ebenen-orbe (magicka/stamina).",
        P061 = "Entsaettigung auf der inaktiven sekundaerleiste im zwei-leisten-modus.",
        P062 = "Vertikale dicke der ultimate-leiste im dual-modus.",
        P063 = "Vertikale dicke der ultimate-leiste im solo-modus.",
        P064 = "Visuelle dicke des schildrings in der lebens-orbe (D4-theme).",
        P065 = "Visuelle dicke des schildrings in der lebens-orbe (Legacy-theme).",
        P066 = "Opazitaet der schild-darstellung im D4-theme.",
        P067 = "Zeichenreihenfolge des D4-schilds. hoeher = weiter oben gezeichnet.",
        P068 = "Hoehe der gefaerbten fuell-ebene der D4-orbe.",
        P069 = "Hoehe des D4-leisten-untergrunds wenn sekundaerleiste aktiv ist.",
        P070 = "Hoehe des D4-leisten-untergrunds wenn sekundaerleiste aus ist.",
        P071 = "Hoehe des ultimate-leisten-hintergrunds im dual-modus.",
        P072 = "Hoehe des ultimate-leisten-hintergrunds im solo-modus.",
        P073 = "Breite der gefaerbten fuell-ebene der D4-orbe.",
        P074 = "Breite der ultimate-leiste im dual-modus.",
        P075 = "Breite der ultimate-leiste im solo-modus.",
        P076 = "Passt die Breite des D4-Balkenhintergrunds an, wenn die Sekundaerleiste aktiv ist.",
        P077 = "Passt die Breite des D4-Balkenhintergrunds an, wenn die Sekundaerleiste deaktiviert ist.",
        P078 = "Passt die Breite des Anzeigenhintergrunds im Dual-Modus an.",
        P079 = "Passt die Breite des Anzeigenhintergrunds im Solo-Modus an.",
        P080 = "Passt die Helligkeit von D4OrbFill.dds an, hier als neutrale Orb-Basis verwendet.",
        P081 = "Passt die Helligkeit der D4-Leiste mit den 2 Basistexturen an. 100 = Quelle, darunter dunkler, darueber heller.",
        P082 = "Passt die Helligkeit der Trennlinie an.",
        P083 = "Passt die Gesamthelligkeit der Orb-Fuellung an. 100% = normal.",
        P084 = "Passt die Groesse der Schattenebene der D4-Orbs an.",
        P085 = "Passt die Groesse der Glow-Ebene der D4-Orbs an.",
        P086 = "Passt die Groesse der Smoke-Fuellungsebene der D4-Orbs an.",
        P087 = "Passt die Groesse des Kontur-Overlays der D4-Orbs an.",
        P088 = "Passt die Groesse der Hauptkontur der D4-Orbs an.",
        P089 = "Passt die Groesse des Tastenkuerzel-Textes an.",
        P090 = "Passt die Gesamtgroesse der D4-Orbs und aller Ebenen an, erweiterter Bereich.",
        P091 = "Passt die tatsaechliche Groesse des D4-Balkenhintergrunds an. 100 = Quellgroesse, hoeher vergroessert, niedriger verkleinert.",
        P092 = "Passt die Transparenz des Tastenkuerzel-Textes an.",
        P093 = "Passt Tasten und Symbole in der D4-Leiste an. Inhalt folgt jetzt automatisch der Leistengroesse; dies verfeinert das Ergebnis.",
        P094 = "Warnungen",
        P095 = "Aussehen",
        P096 = "Wendet eine Farbtonung auf D4-Orbrahmen, Sockel, Kontur-Overlay, Aktionsleistenhintergrund und Ultimative-Anzeigenhintergrund an.",
        P097 = "Auf Ausdauer anwenden",
        P098 = "Abdunkelung Kontur Begleiter-Slot (%)",
        P099 = "Verdunkelt alle D4-Fertigkeitenknopf-Konturen.",
        P100 = "Verdunkelt nur die Kontur des Begleiter-Slots, ohne andere D4-Konturen zu aendern.",
        P101 = "Daempft die Ultimate-Leiste ohne den darueber angezeigten Text zu beeinflussen.",
        P102 = "Zweite Leiste (inaktive D4-Leiste)",
        P103 = "Aktionsleiste - Gemeinsam",
        P104 = "Aktionsleiste - D4",
        P105 = "Basis",
        P106 = "Rahmen und Konturen",
        P107 = "Schild",
        P108 = "D4-Schild: horizontaler Offset (px)",
        P109 = "D4-Schild: vertikaler Offset (px)",
        P110 = "Legacy-Schild: horizontaler Offset (px)",
        P111 = "Legacy-Schild: vertikaler Offset (px)",
        P112 = "Zier-Rahmen: Groesse (px)",
        P113 = "Diese Einstellungen verschieben oder skalieren alle Orbs und Sockel.",
        P114 = "Legt die Farbe der Hintergrundebene fest, die den Orbs hinzugefuegt wird.",
        P115 = "Legt die Farbe des Textes auf der Ultimate-Leiste fest.",
        P116 = "Legt die Farbe der Linie zwischen Magicka und Stamina fest.",
        P117 = "Legt die Schrift fuer Orb-Werte und Ultimate-Text fest. Custom-Fonts nutzen Dateien in DiabloOrbs/Fonts (sonst ESO-Schrift).",
        P118 = "Position der Tastenbezeichnungen: ueber, unter oder in den Slots.",
        P119 = "Textur-Theme (Legacy oder D4). ReloadUI startet automatisch zur Anwendung.",
        P120 = "Waehle eine hellere oder dunklere DDS-Variante fuer Sockel unter den Orbs.",
        P121 = "Schattierungsfarbe hinter dem Text in der Orb-Mitte.",
        P122 = "Gemeinsam",
        P123 = "Aktionsleiste DiabloOrbs ueberlassen",
        P124 = "D4-Button-Kontur-Kontrast (%)",
        P125 = "Steuert die Gesamttransparenz der Orbs und ihrer Sockel.",
        P126 = "Ebene 1: Farbiger Hintergrund",
        P127 = "Ebene 1: Abstand zwischen Orbs (px)",
        P128 = "Ebene 1: Hoehe (%)",
        P129 = "Ebene 1: Breite (%)",
        P130 = "Ebene 1: Helligkeit (%)",
        P131 = "Ebene 1: Offset X (px)",
        P132 = "Ebene 1: Offset Y (px)",
        P133 = "Ebene 1: globaler Offset X (px)",
        P134 = "Ebene 1: Deckkraft (%)",
        P135 = "Ebene 2: Farbiger smoke",
        P136 = "Ebene 2: D4-Schildfarbe",
        P137 = "Ebene 2: D4-Stamina-Farbe",
        P138 = "Ebene 2: D4-Magicka-Farbe",
        P139 = "Ebene 2: D4-Gesundheits-Farbe",
        P140 = "Ebene 2: Zentrum-Abstand (px)",
        P141 = "Ebene 2: Offset Y (px)",
        P142 = "Ebene 2: globaler Offset X (px)",
        P143 = "Ebene 2: Deckkraft (%)",
        P144 = "Ebene 2: Groesse (%)",
        P145 = "Ebene 3: additives Licht",
        P146 = "Ebene 3: Abstand zwischen Orbs (px)",
        P147 = "Ebene 3: Intensitaet (%)",
        P148 = "Ebene 3: Offset X (px)",
        P149 = "Ebene 4: Glow",
        P150 = "Ebene 4: Helligkeit (%)",
        P151 = "Ebene 4: Offset X (px)",
        P152 = "Ebene 4: Offset Y (px)",
        P153 = "Ebene 4: Deckkraft (%)",
        P154 = "Ebene 4: Groesse (%)",
        P155 = "Ebene 4: Orb-Faerbung (%)",
        P156 = "Ebene 5: Schatten",
        P157 = "Ebene 5: Abstand zwischen Orbs (px)",
        P158 = "Ebene 5: Offset X (px)",
        P159 = "Ebene 5: Offset Y (px)",
        P160 = "Ebene 5: Deckkraft (%)",
        P161 = "Ebene 5: Groesse (%)",
        P162 = "Ebene 6: Haupt-Kontur",
        P163 = "Ebene 6: Abstand zwischen Orbs (px)",
        P164 = "Ebene 6: Offset X (px)",
        P165 = "Ebene 6: Offset Y (px)",
        P166 = "Ebene 6: Deckkraft (%)",
        P167 = "Ebene 6: Groesse (%)",
        P168 = "Ebene 7: Trennlinie",
        P169 = "Ebene 7: Farbe",
        P170 = "Ebene 7: Hoehe (% des Orbs)",
        P171 = "Ebene 7: Breite (px)",
        P172 = "Ebene 7: Helligkeit (%)",
        P173 = "Ebene 7: additiver Modus",
        P174 = "Ebene 7: Offset X (px)",
        P175 = "Ebene 7: Offset Y (px)",
        P176 = "Ebene 7: Deckkraft (%)",
        P177 = "Ebene 7: Groesse (% des Orbs)",
        P178 = "Ebene 8: Kontur-Ueberlagerung",
        P179 = "Ebene 8: Kontrast (%)",
        P180 = "Ebene 8: Abstand zwischen Orbs (px)",
        P181 = "Ebene 8: Helligkeit (%)",
        P182 = "Ebene 8: Offset X (px)",
        P183 = "Ebene 8: Offset Y (px)",
        P184 = "Ebene 8: Deckkraft (%)",
        P185 = "Ebene 8: Groesse (%)",
        P186 = "Schildfarbe (Legacy)",
        P187 = "Stamina-Farbe (Legacy)",
        P188 = "Magicka-Farbe (Legacy)",
        P189 = "Gesundheits-Farbe (Legacy)",
        P190 = "Farbe fuer D4-Elemente (Rahmen, Sockel, Ueberlagerung, Leiste, Anzeige).",
        P191 = "Farbe der Faerbungs-Ebene",
        P192 = "Fuellfarbe des Stamina-Orbs im Legacy-Theme.",
        P193 = "Fuellfarbe des Magicka-Orbs im Legacy-Theme.",
        P194 = "Fuellfarbe des Gesundheits-Orbs im Legacy-Theme.",
        P195 = "D4-Faerbungsfarbe",
        P196 = "Schildfarbe im Legacy-Theme.",
        P197 = "Hintergrundfarbe der Anzeige",
        P198 = "Glow-Farbe bei niedrigem Stamina-Orb.",
        P199 = "Glow-Farbe bei niedrigem Magicka-Orb.",
        P200 = "Glow-Farbe bei niedrigem Gesundheits-Orb.",
        P201 = "Smoke-Fuellfarbe fuer den D4-Stamina-Orb.",
        P202 = "Smoke-Fuellfarbe fuer den D4-Magicka-Orb.",
        P203 = "Smoke-Fuellfarbe fuer den D4-Gesundheits-Orb.",
        P204 = "Smoke-Fuellfarbe fuer den D4-Schild.",
        P205 = "Stamina-Alarm-Glow-Farbe (RGB)",
        P206 = "Magicka-Alarm-Glow-Farbe (RGB)",
        P207 = "Gesundheits-Alarm-Glow-Farbe (RGB)",
        P208 = "Farbe des inneren Textschatten",
        P209 = "Ultimate-Textfarbe",
        P210 = "Farben",
        P211 = "D4: horizontaler Abstand der 5 Slots (px)",
        P212 = "Fuellversatz — Gesundheits-Orb (px)",
        P213 = "Fuellversatz — kombinierter Orb (px)",
        P214 = "Vertikaler Versatz (px)",
        P215 = "Verschiebt Shortcut-Text auf Slots horizontal.",
        P216 = "Verschiebt das Ultimate horizontal relativ zu Slot 5.",
        P217 = "Verschiebt das Ultimate horizontal.",
        P218 = "Verschiebt das Ultimate vertikal relativ zu anderen Slots.",
        P219 = "Verschiebt das Ultimate vertikal.",
        P220 = "Verschiebt die Legacy-Backbar nach links oder rechts.",
        P221 = "Verschiebt die Legacy-Backbar nach oben (negativ) oder unten.",
        P222 = "Verschiebt die Backbar links oder rechts relativ zur aktiven Leiste.",
        P223 = "Verschiebt die Backbar nach oben (negativ) oder unten relativ zur aktiven Leiste. Standard -28 fuer ca. 20% sichtbare Slots.",
        P224 = "Verschiebt ganze Ebene 1 links/rechts ohne Orb-Abstand zu aendern.",
        P225 = "Verschiebt die Smoke-Ebene nach oben oder unten.",
        P226 = "Verschiebt die Schattenebene nach links oder rechts.",
        P227 = "Verschiebt die Schattenebene nach oben oder unten.",
        P228 = "Verschiebt die farbige Hintergrundebene nach oben oder unten.",
        P229 = "Verschiebt die Glow-Ebene nach links oder rechts.",
        P230 = "Verschiebt die Glow-Ebene nach oben oder unten.",
        P231 = "Verschiebt Fuellung (smoke) in Orbs: Gesundheit links, kombiniert rechts um denselben Betrag.",
        P232 = "Verschiebt die Kontur-Overlay nach links oder rechts.",
        P233 = "Verschiebt die Kontur-Overlay nach oben oder unten.",
        P234 = "Verschiebt die Hauptkontur nach links oder rechts.",
        P235 = "Verschiebt die Hauptkontur nach oben oder unten.",
        P236 = "Verschiebt den Shortcut-Slot im Legacy-Dual-Modus.",
        P237 = "Verschiebt den Shortcut-Slot im Legacy-Solo-Modus.",
        P238 = "Verschiebt den Ultimate-Slot im Legacy-Dual-Modus.",
        P239 = "Verschiebt den Ultimate-Slot im Legacy-Solo-Modus.",
        P240 = "Verschiebt die Trennlinie nach links oder rechts.",
        P241 = "Verschiebt die Trennlinie nach oben oder unten.",
        P242 = "Verschiebt nur die Fuellung (smoke) im kombinierten Magicka/Stamina-Orb auf der X-Achse.",
        P243 = "Verschiebt nur die Fuellung (smoke) im Gesundheits-Orb auf der X-Achse.",
        P244 = "Verschiebt Shortcut-Text auf Slots vertikal.",
        P245 = "Verschiebt den Wert des linken Orbs (Gesundheit) horizontal um die Mitte.",
        P246 = "Verschiebt Schildtext unabhaengig in D4.",
        P247 = "Verschiebt Schildtext unabhaengig in Legacy.",
        P248 = "Verschiebt Quickslot-Objekt links/rechts auf der D4-Leiste. Hilft nach Groessenwechsel auszurichten.",
        P249 = "Verschiebt Quickslot-Objekt nach oben/unten unabhaengig vom Leisten-Hintergrund.",
        P250 = "Verschiebt Ultimate-Slot links/rechts auf der D4-Leiste (negativ = links). Hilft nach Groessenwechsel.",
        P251 = "Verschiebt Ultimate-Slot nach oben/unten unabhaengig vom Leisten-Hintergrund.",
        P252 = "Verschiebt alle 3 Hintergrund-Ebenen (Gesundheit + Magicka + Stamina) gleichrichtig.",
        P253 = "Verschiebt alle 3 Fuell-Ebenen (Gesundheit + Magicka + Stamina) gleichrichtig.",
        P254 = "Verschiebt die 5 zentralen Slots im Dual-Modus.",
        P255 = "Verschiebt die 5 zentralen Slots im Solo-Modus.",
        P256 = "Verschiebt die Orbs im Dual-Modus nach oben oder unten.",
        P257 = "Verschiebt die Orbs im Solo-Modus nach oben oder unten.",
        P258 = "Verschiebt beide D4-Glows gleichzeitig vertikal, mit perfektem Links/Rechts-Spiegel.",
        P259 = "Verschiebt beide Glows gleichzeitig vertikal, mit perfektem Links/Rechts-Spiegel.",
        P260 = "Entsaettigung (%)",
        P261 = "Entsaettigung inaktive Leiste, 2 Leisten (%)",
        P262 = "Entsaettigt Backbar-Icons zur visuellen Abgrenzung von der aktiven Leiste.",
        P263 = "Entsaettigt Icons zur Abgrenzung von der aktiven Leiste.",
        P264 = "Orb-Abstand vom Bildschirmzentrum im Solo-Modus.",
        P265 = "Orb-Abstand vom Zentrum im Dual-Modus (Sekundaerleiste aktiv).",
        P266 = "D4-Glow-Abstand vom Zentrum (px)",
        P267 = "Glow-Abstand vom Zentrum (px)",
        P268 = "Abstand zwischen jedem Backbar-Faehigkeits-Slot.",
        P269 = "Abstand zwischen jedem Slot.",
        P270 = "Horizontaler Abstand der 5 Slots (px)",
        P271 = "Shortcut-Abstand vom Rand (px)",
        P272 = "Symmetrischer Fuellabstand (px)",
        P273 = "Ultimate-Abstand (px)",
        P274 = "Ultimate-Abstand vom Rand (px)",
        P275 = "Spreizt Schattenebene: Gesundheit links, Magicka/Stamina rechts.",
        P276 = "Spreizt Overlay-Ebene: Gesundheit links, Magicka/Stamina rechts.",
        P277 = "Spreizt Kontur-Ebene: Gesundheit links, Magicka/Stamina rechts.",
        P278 = "Spreizt Orbs relativ zur Leiste im Dual-Modus.",
        P279 = "Spreizt Orbs relativ zur Leiste im Solo-Modus.",
        P280 = "Spreizt oder zieht Magicka/Stamina-Werte vom Zentrum des geteilten Orbs.",
        P281 = "Versatz vom Zentrum — Dual (px)",
        P282 = "Versatz vom Zentrum — Solo (px)",
        P283 = "Horizontaler Abstand (px)",
        P284 = "Skalierung (%)",
        P285 = "D4-Leisten-Inhaltsskalierung (%)",
        P286 = "Aufgehellt = heller Text mit dunklem Schatten. Abgedunkelt = dunkler Text mit hellem Schatten.",
        P287 = "Verschiebt D4-Magicka- und Stamina-Glows weiter vom Zentrum oder naeher.",
        P288 = "Verschiebt Magicka- und Stamina-Glows weiter vom Zentrum oder naeher. Erhoehen fuer mehr Abstand.",
        P289 = "Im Legacy-Modus hat jede Haelfte (Magicka/Stamina) eigenen Alarmzustand.",
        P290 = "Zusatzabstand zwischen Slot 5 und Ultimate.",
        P291 = "Slot-Abstand (px)",
        P292 = "Aussen: horizontaler Innenabstand (px)",
        P293 = "Aussen: vertikaler Innenabstand (px)",
        P294 = "Aussen = klassische Position. Innen = Text zentriert in Orbs.",
        P295 = "Hintergrund",
        P296 = "D4-Leisten-Hintergrund",
        P297 = "Dual-Hintergrund (DiabloOrbsDualBarXp)",
        P298 = "Solo-Hintergrund (ActionBarXp)",
        P299 = "Erzwingt minimalen Innenschatten zur Pruefung der Ebenenverschachtelung.",
        P300 = "Geteilter kombinierter Orb-Alarm",
        P301 = "Allgemein",
        P302 = "Glow: Groesse (px)",
        P303 = "Strenges inneres D4-Glow (ohne Ueberlauf)",
        P304 = "Aktionsleisten-Buttons im D4-Thema: Rahmen, smoke, Begleiter.",
        P305 = "Hoehe der Trennlinie in Prozent der Orbgroesse.",
        P306 = "D4 Hintergrundhoehe mit Sekundaerleiste (%)",
        P307 = "D4 Hintergrundhoehe ohne Sekundaerleiste (%)",
        P308 = "Hintergrundhoehe Dual-Jauge (px)",
        P309 = "Hintergrundhoehe Solo-Jauge (px)",
        P310 = "Hoehe Ultimate-Jauge Dual (px)",
        P311 = "Hoehe Ultimate-Jauge Solo (px)",
        P312 = "Infos und Werte",
        P313 = "Zusaetzliche D4 Dual-Orb-Konturintensitaet (%)",
        P314 = "Zusaetzliche D4 Solo-Orb-Konturintensitaet (%)",
        P315 = "Intensitaet des additiven Overlays D4OrbBack2.",
        P316 = "Faerbungsintensitaet (%)",
        P317 = "Intensitaet der permanenten Reflexion ausserhalb Ressourcenalarm.",
        P318 = "Max. D4 Ressourcenalarm-Glow-Intensitaet (%)",
        P319 = "Maximale Aureolenhelligkeit um D4-Orbs bei Ressourcenalarm.",
        P320 = "D4 Button-Smoke-Intensitaet (%)",
        P321 = "Innen: Abstand Spiegel Magicka/Ausdauer (px)",
        P322 = "Innen: linker Orb horizontaler Offset (px)",
        P323 = "Invertiert horizontale Platzierung von Magicka- und Ausdauerwerten im Innenmodus. Pro Thema unabhaengig (D4 / Legacy).",
        P324 = "Magicka/Ausdauer invertieren (innen)",
        P325 = "Jauge",
        P326 = "Ultimate-Jauge",
        P327 = "Schrift gemeinsam; Groesse Orb-Text und Ultimate-Jauge-Text getrennt.",
        P328 = "Label - D4",
        P329 = "Label - Legacy",
        P330 = "Interface-Sprache",
        P331 = "Breite der Trennlinie in Pixeln.",
        P332 = "D4 Hintergrundbreite mit Sekundaerleiste (%)",
        P333 = "D4 Hintergrundbreite ohne Sekundaerleiste (%)",
        P334 = "Hintergrundbreite Dual-Jauge (%)",
        P335 = "Hintergrundbreite Solo-Jauge (%)",
        P336 = "Breite Ultimate-Jauge Dual (%)",
        P337 = "Breite Ultimate-Jauge Solo (%)",
        P338 = "Hintergrund folgt aktivem Thema (D4: fond_jauge.dds, Legacy: UltimateGaugeBackground.dds). Regler unten steuern Groesse/Offset/Deckkraft.",
        P339 = "Ultimate-Text unabhaengig vom Jauge-Puls und dauerhaft lesbar.",
        P340 = "Legacy - Hintergrund und Rueckleiste",
        P341 = "D4 Leistenhelligkeit (%)",
        P342 = "Sockelhelligkeit (Preset)",
        P343 = "Hintergrundhelligkeit (%)",
        P344 = "Globale Helligkeit (%)",
        P345 = "Globale Hintergrundhelligkeit (%)",
        P346 = "Zwei-Leisten-Modus: gilt fuer die Sekundaerleiste bei erkanntem Dual-System.",
        P347 = "Schildtext in D4 unabhaengig hoch/runter.",
        P348 = "Schildtext in Legacy unabhaengig hoch/runter.",
        P349 = "Leiste im Dual-Modus (Sekundaerleiste an) hoch/runter.",
        P350 = "Leiste im Solo-Modus (Sekundaerleiste aus) hoch/runter.",
        P351 = "Ultimate-Jauge im Dual-Modus hoch/runter.",
        P352 = "Ultimate-Jauge im Solo-Modus hoch/runter.",
        P353 = "Jauge-Hintergrund im Dual-Modus hoch/runter.",
        P354 = "Jauge-Hintergrund im Solo-Modus hoch/runter.",
        P355 = "Orb-Wertetext hoch/runter.",
        P356 = "Orbs und Sockel im Dual-Modus (Sekundaerleiste an) hoch/runter.",
        P357 = "Orbs und Sockel im Solo-Modus (Sekundaerleiste aus) hoch/runter.",
        P358 = "D4 Schild-Ebenenstufe",
        P359 = "D4 Button-Kontur-Dunkelheit (%)",
        P360 = "Tastenkuerzel-Offset X (px)",
        P361 = "Ultimate-Offset X (px)",
        P362 = "Tastenkuerzel-Offset Y (px)",
        P363 = "Ultimate-Offset Y (px)",
        P364 = "Horizontaler Offset (px)",
        P365 = "D4 Tastenkuerzel-Slot-Offset (px)",
        P366 = "D4 Ultimate-Slot-Offset (px)",
        P367 = "Vertikaler Offset (px)",
        P368 = "Vertikaler Offset 5 Slots - Dual-Leiste (px)",
        P369 = "Vertikaler Offset 5 Slots - Solo-Leiste (px)",
        P370 = "Vertikaler Leisten-Offset - Dual (px)",
        P371 = "Vertikaler Leisten-Offset - Solo (px)",
        P372 = "Vertikaler Offset Jauge-Hintergrund Dual (px)",
        P373 = "Vertikaler Offset Jauge-Hintergrund Solo (px)",
        P374 = "Vertikaler D4-Glow-Offset (px)",
        P375 = "Vertikaler Spiegel-Glow-Offset (px)",
        P376 = "Vertikaler Offset Ultimate-Jauge Dual (px)",
        P377 = "Vertikaler Offset Ultimate-Jauge Solo (px)",
        P378 = "Vertikaler D4 Tastenkuerzel-Slot-Offset (px)",
        P379 = "Vertikaler D4 Ultimate-Slot-Offset (px)",
        P380 = "Vertikaler Offset Wertetext (px)",
        P381 = "Innenschatten: Groesse (px)",
        P382 = "Minimaler D4-Schatten (%)",
        P383 = "Deckkraft (%)",
        P384 = "Deckkraft inaktive Leiste Zwei-Leisten (%)",
        P385 = "Deckkraft Werte-Tooltip-Rand (%)",
        P386 = "Deckkraft D4 Button-Kontur (%)",
        P387 = "Deckkraft Faerbungsschicht (%)",
        P388 = "Deckkraft Tastenkuerzel (%)",
        P389 = "D4 Schild-Deckkraft (%)",
        P390 = "Legacy Schild-Deckkraft (%)",
        P391 = "Deckkraft des Glow bei niedriger Ressource.",
        P392 = "Deckkraft Innen-Kontrast-Hintergrund (%)",
        P393 = "Deckkraft Jauge-Hintergrund (%)",
        P394 = "Globale Deckkraft Orbs und Sockel (%)",
        P395 = "Deckkraft Alarm-Glow (%)",
        P396 = "Deckkraft Innen-Textschatten (%)",
        P397 = "Deckkraft Jauge-Fuellung (%)",
        P398 = "Deckkraft Ultimate-Text (%)",
        P399 = "Deckkraft Wertetext (%)",
        P400 = "Gemeinsame DiabloOrbs-Aktionsleisten-Optionen. Solo/Dual-Einstellungen je nach erkanntem Modus.",
        P401 = "D4 Orbs",
        P402 = "Legacy Orbs",
        P403 = "Struktur: gemeinsame Schriftfamilie, dann getrennte Einstellungen fuer Orb-Werte und Ultimate-Leistentext.",
        P404 = "Zahlenschrift (gemeinsam fuer alle Themes)",
        P405 = "Tastenkuerzel-Position",
        P406 = "Wert-Position",
        P407 = "Position und Groesse",
        P408 = "Position und Groesse — globale Einstellungen",
        P409 = "Orb-Position — Dual",
        P410 = "Orb-Position — Solo",
        P411 = "Vertikale Orb-Position — Dual (px)",
        P412 = "Vertikale Orb-Position — Solo (px)",
        P413 = "Tastenkuerzel",
        P414 = "Tastenkuerzel nur im Kampf sichtbar",
        P415 = "Skaliert alle Legacy-Orb-Ebenen proportional gemeinsam.",
        P416 = "D4 Ruhe-Spiegelung (%)",
        P417 = "Erweitert: Dual-Intensitaet multipliziert mit Hauptdeckkraft.",
        P418 = "Erweitert: Solo-Intensitaet multipliziert mit Hauptdeckkraft.",
        P419 = "Hauptdeckkraft fuer D4-Button-Konturen (Tastenkuerzel, 5 Slots, Ultimate, Begleiter).",
        P420 = "Allgemeine DiabloOrbs-Einstellungen.",
        P421 = "Theme-eigene Einstellungen (D4 oder Legacy), mit getrennten Solo-/Dual-Werten.",
        P422 = "Setzt seitlichen Abstand der aeusseren Werte zu den Orbrandern.",
        P423 = "Setzt Deckkraft der inaktiven Zweitleiste bei erkanntem 2-Leisten-Layout.",
        P424 = "Setzt Deckkraft des dekorativen Rahmens um Werttext.",
        P425 = "Setzt Deckkraft der D4-Orb-Schattenebene.",
        P426 = "Setzt Deckkraft der zusaetzlichen Farbebene hinter Orbs.",
        P427 = "Setzt Deckkraft der farbigen D4-Orb-Hintergrundebene.",
        P428 = "Setzt Deckkraft der D4-Orb-Glow-Ebene.",
        P429 = "Setzt Deckkraft der D4-Orb-Smoke-Fuellung.",
        P430 = "Setzt Deckkraft der D4-Orb-Kontur-Ueberlagerung.",
        P431 = "Setzt echte Textschatten-Deckkraft hinter Werten im Orb.",
        P432 = "Setzt Deckkraft der Haupt-D4-Orb-Kontur.",
        P433 = "Setzt Kontrast-Hintergrund-Deckkraft hinter Werten im Orb.",
        P434 = "Setzt Ultimate-Leistentext-Deckkraft ohne Puls der Leiste zu aendern.",
        P435 = "Setzt Werttext-Deckkraft unabhaengig von der Platzierung.",
        P436 = "Setzt Deckkraft der Magicka/Stamina-Trennlinie.",
        P437 = "Setzt Gesamthelligkeit des farbigen D4 Smoke.dds-Hintergrunds.",
        P438 = "Setzt vertikale Position aeusserer Werte.",
        P439 = "Setzt Schriftgroesse des Texts auf der Ultimate-Leiste.",
        P440 = "Setzt Leisten-Hintergrund-Transparenz ohne Text zu aendern.",
        P441 = "Setzt alle D4-Einstellungen auf kalibrierte Standardwerte. Legacy bleibt unberuehrt.",
        P442 = "Setzt alle Legacy-Einstellungen auf Standard. D4 bleibt unberuehrt.",
        P443 = "Fuellung — Feinversatz",
        P444 = "Verstaerkt Konturkontrast (100 = normal, >100 = staerker).",
        P445 = "Verstaerkt oder mildert Smoke.dds-Hintergrundfarbe fuer alle D4-Ressourcen.",
        P446 = "D4 zuruecksetzen (Standardpositionen)",
        P447 = "Legacy zuruecksetzen (Standardpositionen)",
        P448 = "Mitteltrenner: Groesse (px)",
        P449 = "Wenn aktiv, werden Faehigkeits-Tastenkuerzel nur im Kampf angezeigt.",
        P450 = "Slots — Dual",
        P451 = "Slots — Solo",
        P452 = "Innerer Textstil",
        P453 = "Ueberlagert D4OrbBack2 additiv, um den Orb aufzuhellen ohne den Grundton zu faerben.",
        P454 = "Groesse jedes Backbar-Symbols in Pixeln.",
        P455 = "Groesse jedes Symbols in Pixeln.",
        P456 = "Groesse der inneren Schattenebene Legacy-Orbs (Shade.dds). 150 = Standard.",
        P457 = "Orb-Groesse (px)",
        P458 = "Tastenkuerzel-Groesse (%)",
        P459 = "Backbar-Slot-Groesse. 80 = kleiner als aktive Leiste fuer mehr Tiefe.",
        P460 = "Legacy-Rundrahmen-Groesse. 166 = XML-Standard. Reduzieren bei grossen Orbs gegen Ueberlappung.",
        P461 = "D4 Schildkreis-Groesse (%)",
        P462 = "Legacy Schildkreis-Groesse (%)",
        P463 = "Groesse des Niedrig-Ressourcen-Alert-Glow vs normaler Glow. 100 = gleich.",
        P464 = "Legacy-Orb-Glow-Groesse. 150 = Standard.",
        P465 = "Trenner-Groesse zwischen Magicka und Stamina (Split.dds). 166 = Standard.",
        P466 = "D4 Leisten-Hintergrund-Groesse (%)",
        P467 = "Gesamtgroesse der Legacy-Backbar.",
        P468 = "Gesamt-Orb-Groesse (%)",
        P469 = "Gesamt-Trenner-Groesse als Prozent der Orb-Groesse.",
        P470 = "Alert-Glow-Groesse (%)",
        P471 = "Ultimate-Text-Schriftgroesse",
        P472 = "Slot-Groesse (px)",
        P473 = "Backbar-Slot-Groesse (px)",
        P474 = "Toenung auf Leisten-Hintergrund.",
        P475 = "Globale D4-Toenung",
        P476 = "Text",
        P477 = "Text und Werte",
        P478 = "Visuelles Theme",
        P479 = "Verschiebt beide Orbs der additiven Ebene gemeinsam links/rechts.",
        P480 = "Backbar-Transparenz. 0 = unsichtbar, 100 = deckend.",
        P481 = "Transparenz der Legacy-Backbar-Symbole.",
        P482 = "Gemeinsame Typografie",
        P483 = "Positiv = Magicka/Stamina weichen vom Zentrum ab (Smoke-Ebene), negativ = naeher zusammen.",
        P484 = "Orb-Werte",
        P485 = "Visuell — D4",
        P486 = "Visuell — Legacy",
        P487 = "[Theme D4] Zweitleiste aktivieren (Dual-Modus)",
        P488 = "[Theme Legacy] Zweitleiste aktivieren (Dual-Modus)",
        P489 = "|cFFAA00[!] Fuer optimale Darstellung (Solo und Dual) aktiviere unter|r |cFFFFFFEinstellungen > Kampf|r |cFFAA00:|r |cFFFFFF\"Hintere Reihe der Faehigkeitenleiste\"|r |cFFAA00und|r |cFFFFFF\"Faehigkeitenleisten-Timer\"|r|cFFAA00. (Alle Themen)|r",
        P490 = "Profile",
        P491 = "Verwalte deine Einstellungsprofile. Ein Profil speichert alle visuellen Einstellungen. Du kannst ein Profil auf mehrere Charaktere desselben Kontos anwenden.",
        P492 = "Aktives Profil",
        P493 = "Profil zum Laden auswaehlen. Klicke auf 'Ausgewaehltes Profil laden' um es anzuwenden.",
        P494 = "Ausgewaehltes Profil laden",
        P495 = "Wendet die Einstellungen des ausgewaehlten Profils auf diesen Charakter an.",
        P496 = "Speichern (aktives Profil ueberschreiben)",
        P497 = "Ueberschreibt das aktive Profil mit deinen aktuellen Einstellungen.",
        P498 = "Speichern unter... (neuer Name)",
        P499 = "Erstellt ein neues Profil mit dem eingegebenen Namen und deinen aktuellen Einstellungen.",
        P500 = "Dieses neue Profil erstellen",
        P501 = "Erstellt oder ueberschreibt ein Profil mit dem oben eingegebenen Namen.",
        P502 = "Ausgewaehltes Profil loeschen",
        P503 = "Loescht das ausgewaehlte Profil ('D4 default' und 'Legacy default' sind geschuetzt).",
        P504 = "Dekorationen (Angel / Demon)",
        P505 = "Dekorationen anzeigen (Angel / Demon)",
        P506 = "Vordergrund (vor den Orbs)",
        P507 = "Seiten tauschen (Angel/Demon)",
        P508 = "Ziervrahmen: Groesse (px)",
        P509 = "Innerer Schatten: Groesse (px)",
        P510 = "Mitteltrenner: Groesse (px)",
        P511 = "Glow: Groesse (px)",
        P512 = "Basisgroesse (px)",
        P513 = "Breite (%)",
        P514 = "Hoehe (%)",
        P515 = "Abstand vom Zentrum (px)",
        P516 = "Vertikaler Versatz (px)",
        P517 = "Groesse des Legacy-Ziervrahmens. Standard-XML-Wert ist 166. Verkleinern um Ueberlappung bei grossen Orbs zu vermeiden. [ID: B93]",
        P518 = "Groesse der Legacy-Innenschattenschicht (Shade.dds). Standardwert ist 150. [ID: B94]",
        P519 = "Groesse des Trenners zwischen Magie und Ausdauer (Split.dds). Standardwert ist 166. [ID: B95]",
        P520 = "Groesse des Legacy-Orb-Glows. Standardwert ist 150. [ID: B96]",
        P521 = "Zeigt oder versteckt die dekorativen Angel- und Demon-Bilder auf jeder Seite der Orbs (nur Legacy). [ID: LD10]",
        P522 = "Referenzgroesse fuer Angel- und Demon-Bilder. Breite und Hoehe sind Prozentwerte dieser Groesse. [ID: LD11]",
        P523 = "Horizontaler Abstand zwischen Bildschirmmitte und jedem Bild. 0 = Mitte. [ID: LD12]",
        P524 = "Verschiebt Dekorationen nach oben (negativ) oder unten (positiv). [ID: LD13]",
        P525 = "Zeigt Dekorationen vor allen Elementen an. Deaktiviert = Hintergrund. [ID: LD14]",
        P526 = "Tauscht Positionen: Angel links, Demon rechts. [ID: LD15]",
        P527 = "Breite in % der Basisgroesse. [ID: LD16]",
        P528 = "Hoehe in % der Basisgroesse. [ID: LD17]",
        P529 = "Dieses Profil ist geschuetzt und kann nicht ueberschrieben werden.",
        P530 = "Dieses Profil ist geschuetzt und kann nicht geloescht werden.",
        P531 = "Bitte einen Profilnamen eingeben.",
        P532 = "Dieser Profilname ist geschuetzt und kann nicht verwendet werden.",
    },
    es = {
        DESC = "Ajustes de DiabloOrbs.",
        SECTION_LANGUAGE = "Idioma",
        LANG_MODE_NAME = "Idioma del addon",
        LANG_MODE_TIP = "Auto usa el idioma del juego. Manual fuerza el idioma elegido.",
        LANG_MODE_AUTO = "Auto (idioma del juego)",
        LANG_MODE_HINT = "Si algunas etiquetas no se actualizan al instante, cierra y vuelve a abrir el panel.",
        SECTION_ULTIMATE = "Barra de definitiva",
        SHOW_ULTIMATE_BAR_NAME = "Mostrar barra de definitiva",
        SHOW_ULTIMATE_BAR_TIP = "Muestra u oculta la barra de definitiva central.",
        SHOW_ULTIMATE_TEXT_NAME = "Mostrar texto actual/coste",
        SHOW_ULTIMATE_TEXT_TIP = "Muestra el progreso de definitiva directamente en la barra central.",
        ULTIMATE_TEXT_MODE_NAME = "Formato del texto de definitiva",
        ULTIMATE_TEXT_MODE_TIP = "Elige el formato mostrado en la barra de definitiva.",
        ULTIMATE_TEXT_MODE_VALUE = "Valor (actual/coste)",
        ULTIMATE_TEXT_MODE_PERCENT = "Porcentaje",
        ULTIMATE_READY_COLOR_NAME = "Color cuando la definitiva esta lista",
        ULTIMATE_READY_COLOR_TIP = "Color aplicado a la barra central cuando la definitiva esta lista.",
        ULTIMATE_PULSE_SPEED_NAME = "Velocidad del pulso",
        ULTIMATE_PULSE_SPEED_TIP = "Velocidad del pulso cuando la definitiva esta lista.",
        ULTIMATE_PULSE_MIN_NAME = "Pulso alfa min (%)",
        ULTIMATE_PULSE_MIN_TIP = "Opacidad minima del pulso de la barra de definitiva.",
        ULTIMATE_PULSE_MAX_NAME = "Pulso alfa max (%)",
        ULTIMATE_PULSE_MAX_TIP = "Opacidad maxima del pulso de la barra de definitiva.",
        SECTION_ALERT = "Alertas de recursos",
        LOW_RESOURCE_NAME = "Umbral de recurso bajo (%)",
        LOW_RESOURCE_TIP = "Activa el brillo cuando un recurso baja de este porcentaje.",
        GLOW_MAX_NAME = "Intensidad maxima del brillo (%)",
        GLOW_MAX_TIP = "Intensidad maxima del halo durante la alerta de recurso bajo.",
        GLOW_INTERNAL_NAME = "Brillo interno estricto",
        GLOW_INTERNAL_TIP = "Brillo solo dentro de los orbes. Desactivar para un efecto mas dramatico.",
        BORDER_PULSE_ENABLE_NAME = "Activar pulso de color en borde",
        BORDER_PULSE_ENABLE_TIP = "Cuando el recurso es bajo, el borde ornamental pulsa con el color elegido.",
        BORDER_PULSE_COLOR_NAME = "Color del pulso de alerta",
        BORDER_PULSE_COLOR_TIP = "Color del borde cuando el recurso es bajo.",
        SECTION_ORB_STYLE = "Orbes - Estilo",
        SMOKE_ALPHA_NAME = "Transparencia del humo (%)",
        SMOKE_ALPHA_TIP = "Ajusta la opacidad del efecto de humo en los orbes.",
        SMOKEBG_BRIGHTNESS_NAME = "Brillo de fondo de orbes (%)",
        SMOKEBG_BRIGHTNESS_TIP = "0% = fondo oscuro, 100% = fondo mas brillante.",
        ORB_COLOR_BOOST_NAME = "Intensidad global de color (%)",
        ORB_COLOR_BOOST_TIP = "Aumento global de color de orbes.",
        SHADE_ALPHA_NAME = "Intensidad de sombreado interno (%)",
        SHADE_ALPHA_TIP = "0% = sin sombreado, 100% = sombreado completo.",
        BORDER_ALPHA_NAME = "Opacidad del borde circular (%)",
        BORDER_ALPHA_TIP = "Ajusta la opacidad del borde ornamental de los orbes.",
        SPLIT_ALPHA_NAME = "Opacidad del separador (%)",
        SPLIT_ALPHA_TIP = "Ajusta la opacidad de la linea entre Magia y Aguante.",
        SHIELD_ALPHA_NAME = "Opacidad del escudo (%)",
        SHIELD_ALPHA_TIP = "Ajusta la opacidad visual del escudo.",
        SHIELD_RING_SCALE_NAME = "Tamano del anillo de escudo (%)",
        SHIELD_RING_SCALE_TIP = "Ajusta el grosor/tamano visual del anillo de escudo en el orbe de vida.",
        SHIELD_VISUAL_RESPONSE_NAME = "Respuesta visual del escudo (%)",
        SHIELD_VISUAL_RESPONSE_TIP = "Mas alto = reaccion visual mas rapida. 100% = lineal.",
        SECTION_ORB_COLORS = "Orbes - Colores",
        HEALTH_COLOR_NAME = "Color orbe de Vida",
        MAGICKA_COLOR_NAME = "Color orbe de Magia",
        STAMINA_COLOR_NAME = "Color orbe de Aguante",
        SHIELD_COLOR_NAME = "Color orbe de Escudo",
        SECTION_TEXT = "Etiquetas de valores",
        LABEL_SCALE_NAME = "Tamano de texto (%)",
        LABEL_SCALE_TIP = "Ajusta el tamano de etiquetas de valor/porcentaje.",
        LABEL_FORMAT_NAME = "Visualizacion de valores",
        LABEL_FORMAT_TIP = "Elige como mostrar los valores numericos en los orbes.",
        LABEL_FORMAT_HIDDEN = "Oculto",
        LABEL_FORMAT_VALUE = "Valor (ej. 23k)",
        LABEL_FORMAT_PERCENT = "Porcentaje (ej. 75%)",
        ULT_TT_READY_OVER = "Definitiva: <<1>> / <<2>> (Lista, +<<3>>)",
        ULT_TT_READY = "Definitiva: <<1>> / <<2>> (Lista)",
        ULT_TT_NORMAL = "Definitiva: <<1>> / <<2>>",
        P001 = "0 = glow blanco puro. 100 = glow tintado al color del orbe.",
        P002 = "0 = modo normal (alpha). 100 = modo aditivo (mas impacto y brillo sobre fondos oscuros).",
        P003 = "0 = sin tinte (color original), 100 = tinte completo.",
        P004 = "100 = normal, hasta 500 para muy brillante.",
        P005 = "100 = normal. Sube para mas brillo, baja para oscurecer.",
        P006 = "Activa la gestion de slots/hotkeys/armas de DiabloOrbs. Desactivado: DiabloOrbs conserva lo visual (skins/fondos/jauge ultimate) y deja los slots a otro addon.",
        P007 = "Activa modo aditivo en stamina del orbe combinado D4 (si no, solo magicka).",
        P008 = "Activa o desactiva por completo el widget central de ultimate de DiabloOrbs, independiente del resto de la barra.",
        P009 = "Activa o desactiva los bordes de slots en tema D4 anadidos por DiabloOrbs.",
        P010 = "Glow contenido dentro de los orbes D4. Desactivado = glow mas dramatico que se sale un poco.",
        P011 = "Activa glow de alerta cuando un recurso cae por debajo del umbral.",
        P012 = "Render mas luminoso del separador (util en fondos oscuros).",
        P013 = "Activar capa de fondo tintada",
        P014 = "Activar luz aditiva",
        P015 = "Activar glow de alerta por umbral bajo",
        P016 = "Muestra el valor numerico del escudo en tema D4.",
        P017 = "Muestra el valor numerico del escudo en tema Legacy.",
        P018 = "Muestra el cambio de arma en la barra estandar y la flecha en la version dual cuando exista.",
        P019 = "Muestra el fondo decorativo detras de la jauge ultimate.",
        P020 = "Muestra los iconos de habilidades de la barra inactiva al fondo en modo Dual con fondo dual Legacy. (solo tema Legacy)",
        P021 = "Muestra ajustes separados solo/dual para afinar la intensidad del contorno. La opacidad principal sigue siendo el control recomendado.",
        P022 = "Muestra los slots de la barra inactiva al fondo en modo dual. Solo afecta al modo D4.",
        P023 = "Muestra texto/atajos en los slots de la barra de accion con interfaz de teclado.",
        P024 = "Muestra u oculta la capa de sombra en los orbes D4.",
        P025 = "Muestra u oculta la capa de relleno de color dentro de los orbes D4.",
        P026 = "Muestra u oculta la capa de glow luminoso en los orbes D4.",
        P027 = "Muestra u oculta la capa de relleno Smoke en los orbes D4.",
        P028 = "Muestra u oculta la superposicion de contorno en los orbes D4.",
        P029 = "Muestra u oculta el contorno principal en los orbes D4.",
        P030 = "Muestra u oculta la base de barra, adornos y soportes visuales de la barra de accion DiabloOrbs.",
        P031 = "Muestra u oculta el slot de ultimate del companero sin tocar el resto de la barra.",
        P032 = "Muestra u oculta los slots de habilidades gestionados por DiabloOrbs. Util para dejar solo el fondo o al reves.",
        P033 = "Muestra una linea simple entre magicka y stamina.",
        P034 = "Muestra una segunda barra al fondo con textura dual. Desactiva para una sola barra. (solo tema D4)",
        P035 = "Mostrar fondo de la jauge ultimate",
        P036 = "Mostrar indicador de cambio de arma",
        P037 = "Mostrar sombra",
        P038 = "Mostrar ultimate del companero",
        P039 = "Mostrar jauge ultimate central DiabloOrbs",
        P040 = "Mostrar superposicion",
        P041 = "Mostrar contorno",
        P042 = "Mostrar relleno de color",
        P043 = "Mostrar base/soporte de barra DiabloOrbs",
        P044 = "Mostrar glow",
        P045 = "Mostrar smoke",
        P046 = "Mostrar linea divisoria",
        P047 = "Mostrar bordes de slots D4",
        P048 = "Mostrar atajos de slots",
        P049 = "Mostrar slots de habilidades DiabloOrbs",
        P050 = "Mostrar ajustes avanzados de contorno solo/dual",
        P051 = "Mostrar valor del escudo (D4)",
        P052 = "Mostrar valor del escudo (Legacy)",
        P053 = "Anade un velo Smoke tintado con los colores del orbe para fundir los botones en el tema.",
        P054 = "Anade una capa de color detras del relleno de los orbes principales.",
        P055 = "Ajusta la alineacion del relleno dentro de los orbes.",
        P056 = "Ajusta la separacion de los 5 slots centrales en Legacy dual.",
        P057 = "Ajusta la separacion de los 5 slots centrales en Legacy solo.",
        P058 = "Ajusta la separacion de los 5 slots centrales en tema D4.",
        P059 = "Ajusta la separacion horizontal de los orbes de vida/combinados alrededor del centro en capa 1.",
        P060 = "Ajusta la separacion espejo de los orbes de capa aditiva (magicka/stamina).",
        P061 = "Ajusta la desaturacion en la barra secundaria inactiva en modo dos barras.",
        P062 = "Ajusta el grosor vertical de la jauge ultimate en modo dual.",
        P063 = "Ajusta el grosor vertical de la jauge ultimate en modo solo.",
        P064 = "Ajusta el grosor visual del anillo de escudo en el orbe de vida (tema D4).",
        P065 = "Ajusta el grosor visual del anillo de escudo en el orbe de vida (tema Legacy).",
        P066 = "Ajusta la opacidad visual del escudo en tema D4.",
        P067 = "Ajusta el orden de dibujo del escudo D4. Mas alto = mas arriba.",
        P068 = "Ajusta la altura de la capa de relleno de color en los orbes D4.",
        P069 = "Ajusta la altura de la base de barra D4 cuando la barra secundaria esta activa.",
        P070 = "Ajusta la altura de la base de barra D4 cuando la barra secundaria esta desactivada.",
        P071 = "Ajusta la altura del fondo de la jauge ultimate en modo dual.",
        P072 = "Ajusta la altura del fondo de la jauge ultimate en modo solo.",
        P073 = "Ajusta el ancho de la capa de relleno de color en los orbes D4.",
        P074 = "Ajusta el ancho de la jauge ultimate en modo dual.",
        P075 = "Ajusta el ancho de la jauge ultimate en modo solo.",
        P076 = "Ajusta el ancho del fondo de barra D4 cuando la barra secundaria esta activa.",
        P077 = "Ajusta el ancho del fondo de barra D4 cuando la barra secundaria esta desactivada.",
        P078 = "Ajusta el ancho del fondo de jauge en modo dual.",
        P079 = "Ajusta el ancho del fondo de jauge en modo solo.",
        P080 = "Ajusta la luminosidad de D4OrbFill.dds, usado como base neutra del orbe.",
        P081 = "Ajusta la luminosidad de la barra D4 solo con las 2 texturas base. 100 = fuente, menos oscurece, mas aclara.",
        P082 = "Ajusta la luminosidad de la linea divisoria.",
        P083 = "Ajusta la luminosidad global del relleno de los orbes. 100% = normal.",
        P084 = "Ajusta el tamano de la capa de sombra de los orbes D4.",
        P085 = "Ajusta el tamano de la capa de brillo de los orbes D4.",
        P086 = "Ajusta el tamano de la capa de relleno Smoke de los orbes D4.",
        P087 = "Ajusta el tamano de la superposicion de contorno de los orbes D4.",
        P088 = "Ajusta el tamano del contorno principal de los orbes D4.",
        P089 = "Ajusta el tamano del texto de atajos de competencias.",
        P090 = "Ajusta el tamano global de los orbes D4 y sus capas, rango ampliado.",
        P091 = "Ajusta el tamano real del fondo de barra D4. 100 = tamano fuente, mas grande agranda, mas bajo reduce.",
        P092 = "Ajusta la transparencia del texto de atajos de competencias.",
        P093 = "Ajusta teclas e iconos dentro de la barra D4. El contenido sigue automaticamente el tamano; esto afina el resultado.",
        P094 = "Alertas",
        P095 = "Apariencia",
        P096 = "Aplica un tono de color al marco de orbes D4, socles, superposicion de contorno, fondo de barra y fondo de jauge de definitiva.",
        P097 = "Aplicar a resistencia",
        P098 = "Oscurecimiento contorno slot companero (%)",
        P099 = "Oscurece todos los contornos de botones de competencias D4.",
        P100 = "Oscurece solo el contorno del slot companero sin modificar los demas contornos D4.",
        P101 = "Atenua la barra de ultimate sin afectar el texto mostrado encima.",
        P102 = "Barra secundaria (barra D4 inactiva)",
        P103 = "Barra de accion - Comun",
        P104 = "Barra de accion - D4",
        P105 = "Base",
        P106 = "Bordes y contornos",
        P107 = "Escudo",
        P108 = "Escudo D4: desplazamiento horizontal (px)",
        P109 = "Escudo D4: desplazamiento vertical (px)",
        P110 = "Escudo Legacy: desplazamiento horizontal (px)",
        P111 = "Escudo Legacy: desplazamiento vertical (px)",
        P112 = "Marco ornamental: tamano (px)",
        P113 = "Estos ajustes mueven o redimensionan todos los orbes y bases.",
        P114 = "Elige el color de la capa de fondo anadida a los orbes.",
        P115 = "Elige el color del texto en la barra de ultimate.",
        P116 = "Elige el color de la linea entre magicka y stamina.",
        P117 = "Elige la fuente para valores de orbes y texto de ultimate. Las fuentes personal usan archivos en DiabloOrbs/Fonts (si no, fuente ESO).",
        P118 = "Posicion del texto de atajos de habilidades: arriba, abajo o dentro de los slots.",
        P119 = "Tema de texturas (Legacy o D4). Se recarga la UI automaticamente al aplicar.",
        P120 = "Elige una variante DDS mas clara u oscura para las bases bajo los orbes.",
        P121 = "Color de sombreado detras del texto en el centro de los orbes.",
        P122 = "Comun",
        P123 = "Ceder la barra de accion a DiabloOrbs",
        P124 = "Contraste de contorno botones D4 (%)",
        P125 = "Controla la transparencia global de los orbes y sus bases.",
        P126 = "Capa 1: Fondo de color",
        P127 = "Capa 1: espacio entre orbes (px)",
        P128 = "Capa 1: altura (%)",
        P129 = "Capa 1: anchura (%)",
        P130 = "Capa 1: brillo (%)",
        P131 = "Capa 1: desplazamiento X (px)",
        P132 = "Capa 1: desplazamiento Y (px)",
        P133 = "Capa 1: desplazamiento global X (px)",
        P134 = "Capa 1: opacidad (%)",
        P135 = "Capa 2: smoke de color",
        P136 = "Capa 2: color escudo D4",
        P137 = "Capa 2: color stamina D4",
        P138 = "Capa 2: color magicka D4",
        P139 = "Capa 2: color salud D4",
        P140 = "Capa 2: espacio al centro (px)",
        P141 = "Capa 2: desplazamiento Y (px)",
        P142 = "Capa 2: desplazamiento global X (px)",
        P143 = "Capa 2: opacidad (%)",
        P144 = "Capa 2: tamano (%)",
        P145 = "Capa 3: luz aditiva",
        P146 = "Capa 3: espacio entre orbes (px)",
        P147 = "Capa 3: intensidad (%)",
        P148 = "Capa 3: desplazamiento X (px)",
        P149 = "Capa 4: glow",
        P150 = "Capa 4: brillo (%)",
        P151 = "Capa 4: desplazamiento X (px)",
        P152 = "Capa 4: desplazamiento Y (px)",
        P153 = "Capa 4: opacidad (%)",
        P154 = "Capa 4: tamano (%)",
        P155 = "Capa 4: tinte de color del orbe (%)",
        P156 = "Capa 5: sombra",
        P157 = "Capa 5: espacio entre orbes (px)",
        P158 = "Capa 5: desplazamiento X (px)",
        P159 = "Capa 5: desplazamiento Y (px)",
        P160 = "Capa 5: opacidad (%)",
        P161 = "Capa 5: tamano (%)",
        P162 = "Capa 6: contorno principal",
        P163 = "Capa 6: espacio entre orbes (px)",
        P164 = "Capa 6: desplazamiento X (px)",
        P165 = "Capa 6: desplazamiento Y (px)",
        P166 = "Capa 6: opacidad (%)",
        P167 = "Capa 6: tamano (%)",
        P168 = "Capa 7: linea divisoria",
        P169 = "Capa 7: color",
        P170 = "Capa 7: altura (% del orbe)",
        P171 = "Capa 7: anchura (px)",
        P172 = "Capa 7: brillo (%)",
        P173 = "Capa 7: modo aditivo",
        P174 = "Capa 7: desplazamiento X (px)",
        P175 = "Capa 7: desplazamiento Y (px)",
        P176 = "Capa 7: opacidad (%)",
        P177 = "Capa 7: tamano (% del orbe)",
        P178 = "Capa 8: superposicion de contorno",
        P179 = "Capa 8: contraste (%)",
        P180 = "Capa 8: espacio entre orbes (px)",
        P181 = "Capa 8: brillo (%)",
        P182 = "Capa 8: desplazamiento X (px)",
        P183 = "Capa 8: desplazamiento Y (px)",
        P184 = "Capa 8: opacidad (%)",
        P185 = "Capa 8: tamano (%)",
        P186 = "Color escudo (Legacy)",
        P187 = "Color stamina (Legacy)",
        P188 = "Color magicka (Legacy)",
        P189 = "Color salud (Legacy)",
        P190 = "Color aplicado a elementos D4 (marco, bases, capa, barra, gauge).",
        P191 = "Color de capa de tinte",
        P192 = "Color de relleno del orbe de stamina tema Legacy.",
        P193 = "Color de relleno del orbe de magicka tema Legacy.",
        P194 = "Color de relleno del orbe de salud tema Legacy.",
        P195 = "Color de tinte D4",
        P196 = "Color del escudo tema Legacy.",
        P197 = "Color de fondo de la gauge",
        P198 = "Color glow de alerta de recurso bajo del orbe stamina.",
        P199 = "Color glow de alerta de recurso bajo del orbe magicka.",
        P200 = "Color glow de alerta de recurso bajo del orbe salud.",
        P201 = "Color de relleno Smoke del orbe de stamina D4.",
        P202 = "Color de relleno Smoke del orbe de magicka D4.",
        P203 = "Color de relleno Smoke del orbe de salud D4.",
        P204 = "Color de relleno Smoke del escudo D4.",
        P205 = "Color glow alerta stamina (RGB)",
        P206 = "Color glow alerta magicka (RGB)",
        P207 = "Color glow alerta salud (RGB)",
        P208 = "Color sombra texto interior",
        P209 = "Color texto ultimate",
        P210 = "Colores",
        P211 = "D4: espacio horizontal de los 5 slots (px)",
        P212 = "Desplazamiento relleno — orbe salud (px)",
        P213 = "Desplazamiento relleno — orbe combinado (px)",
        P214 = "Desplazamiento vertical (px)",
        P215 = "Desplaza horizontalmente el texto de atajos en los slots.",
        P216 = "Desplaza el ultimate horizontalmente respecto al slot 5.",
        P217 = "Desplaza el ultimate horizontalmente.",
        P218 = "Desplaza el ultimate verticalmente respecto a los demas slots.",
        P219 = "Desplaza el ultimate verticalmente.",
        P220 = "Desplaza la backbar Legacy a izquierda o derecha.",
        P221 = "Desplaza la backbar Legacy arriba (negativo) o abajo.",
        P222 = "Desplaza la backbar izquierda o derecha respecto a la barra activa.",
        P223 = "Desplaza la backbar arriba (negativo) o abajo respecto a la barra activa. Por defecto -28 para ver ~20% de los slots.",
        P224 = "Desplaza toda la capa 1 izq./der. sin cambiar el espacio entre orbes.",
        P225 = "Desplaza la capa Smoke arriba o abajo.",
        P226 = "Desplaza la capa sombra a izquierda o derecha.",
        P227 = "Desplaza la capa sombra arriba o abajo.",
        P228 = "Desplaza la capa de fondo de color arriba o abajo.",
        P229 = "Desplaza la capa glow a izquierda o derecha.",
        P230 = "Desplaza la capa glow arriba o abajo.",
        P231 = "Desplaza el relleno (smoke) dentro de los orbes: salud a la izq., combinado a la der. la misma cantidad.",
        P232 = "Desplaza la superposicion contorno a izquierda o derecha.",
        P233 = "Desplaza la superposicion contorno arriba o abajo.",
        P234 = "Desplaza el contorno principal a izquierda o derecha.",
        P235 = "Desplaza el contorno principal arriba o abajo.",
        P236 = "Desplaza el slot de atajo en Legacy dual.",
        P237 = "Desplaza el slot de atajo en Legacy solo.",
        P238 = "Desplaza el slot ultimate en Legacy dual.",
        P239 = "Desplaza el slot ultimate en Legacy solo.",
        P240 = "Desplaza la linea separadora a izquierda o derecha.",
        P241 = "Desplaza la linea separadora arriba o abajo.",
        P242 = "Desplaza solo el relleno (smoke) dentro del orbe magicka/stamina combinado en el eje X.",
        P243 = "Desplaza solo el relleno (smoke) dentro del orbe de salud en el eje X.",
        P244 = "Desplaza verticalmente el texto de atajos en los slots.",
        P245 = "Mueve horizontalmente el valor del orbe izquierdo (salud) alrededor del centro.",
        P246 = "Mueve el texto del escudo de forma independiente en D4.",
        P247 = "Mueve el texto del escudo de forma independiente en Legacy.",
        P248 = "Mueve el objeto quickslot izq./der. en la barra D4. Util para realinear tras cambiar tamano.",
        P249 = "Mueve el objeto quickslot arriba/abajo independiente del fondo de barra.",
        P250 = "Mueve el slot ultimate izq./der. en la barra D4 (negativo = izq.). Util para realinear.",
        P251 = "Mueve el slot ultimate arriba/abajo independiente del fondo de barra.",
        P252 = "Mueve las 3 capas de fondo (salud + magicka + stamina) en la misma direccion.",
        P253 = "Mueve las 3 capas de relleno (salud + magicka + stamina) en la misma direccion.",
        P254 = "Mueve los 5 slots centrales en modo dual.",
        P255 = "Mueve los 5 slots centrales en modo solo.",
        P256 = "Mueve los orbes arriba o abajo en modo dual.",
        P257 = "Mueve los orbes arriba o abajo en modo solo.",
        P258 = "Mueve ambos glows D4 a la vez en vertical, manteniendo espejo izq./der. perfecto.",
        P259 = "Mueve ambos glows a la vez en vertical, manteniendo espejo izq./der. perfecto.",
        P260 = "Desaturacion (%)",
        P261 = "Desaturacion barra inactiva, 2 barras (%)",
        P262 = "Desatura iconos de backbar para distinguirlos de la barra activa.",
        P263 = "Desatura iconos para distinguirlos de la barra activa.",
        P264 = "Distancia de los orbes al centro de pantalla en modo solo.",
        P265 = "Distancia de los orbes al centro en modo dual (barra secundaria activa).",
        P266 = "Separacion glows D4 desde el centro (px)",
        P267 = "Separacion glows desde el centro (px)",
        P268 = "Espacio entre cada slot de habilidad de la backbar.",
        P269 = "Espacio entre cada slot.",
        P270 = "Espacio horizontal de los 5 slots (px)",
        P271 = "Separacion atajo desde el borde (px)",
        P272 = "Espaciado simetrico del relleno (px)",
        P273 = "Separacion ultimate (px)",
        P274 = "Separacion ultimate desde el borde (px)",
        P275 = "Separa capa sombra: salud izq., magicka/stamina der.",
        P276 = "Separa capa overlay: salud izq., magicka/stamina der.",
        P277 = "Separa capa contorno: salud izq., magicka/stamina der.",
        P278 = "Separa orbes respecto a la barra en modo dual.",
        P279 = "Separa orbes respecto a la barra en modo solo.",
        P280 = "Separa o acerca valores magicka/stamina del centro del orbe partido.",
        P281 = "Separacion desde el centro — Dual (px)",
        P282 = "Separacion desde el centro — Solo (px)",
        P283 = "Espaciado horizontal (px)",
        P284 = "Escala (%)",
        P285 = "Escala contenido barra D4 (%)",
        P286 = "Aclarado = texto claro con sombra oscura. Oscurecido = texto oscuro con sombra clara.",
        P287 = "Aleja o acerca los glows D4 de magicka y stamina respecto al centro.",
        P288 = "Aleja o acerca glows magicka y stamina al centro. Aumenta para mas separacion.",
        P289 = "En Legacy, cada mitad (magicka/stamina) tiene su propio estado de alerta.",
        P290 = "Espacio extra entre slot 5 y ultimate.",
        P291 = "Espaciado slots (px)",
        P292 = "Exterior: relleno horizontal (px)",
        P293 = "Exterior: relleno vertical (px)",
        P294 = "Exterior = posicion clasica. Interior = texto centrado en orbes.",
        P295 = "Fondo",
        P296 = "Fondo barra D4",
        P297 = "Fondo dual (DiabloOrbsDualBarXp)",
        P298 = "Fondo solo (ActionBarXp)",
        P299 = "Fuerza sombra interior minima para comprobar anidacion de capas.",
        P300 = "Alerta orbe combinado partido",
        P301 = "General",
        P302 = "Glow: tamano (px)",
        P303 = "Glow interno D4 estricto (sin desbordamiento)",
        P304 = "Estilo de botones de barra de accion tema D4: bordes, smoke, companero.",
        P305 = "Altura de la linea separadora en porcentaje del tamano del orbe.",
        P306 = "Altura fondo D4 con barra secundaria (%)",
        P307 = "Altura fondo D4 sin barra secundaria (%)",
        P308 = "Altura fondo jauge dual (px)",
        P309 = "Altura fondo jauge solo (px)",
        P310 = "Altura jauge ultimate dual (px)",
        P311 = "Altura jauge ultimate solo (px)",
        P312 = "Informacion y valores",
        P313 = "Intensidad adicional contornos D4 dual (%)",
        P314 = "Intensidad adicional contornos D4 solo (%)",
        P315 = "Intensidad del overlay aditivo D4OrbBack2.",
        P316 = "Intensidad del tinte (%)",
        P317 = "Intensidad del reflejo permanente fuera de alerta de recurso.",
        P318 = "Intensidad maxima glow alerta D4 (%)",
        P319 = "Brillo maximo del halo alrededor de orbes D4 en alerta de recurso.",
        P320 = "Intensidad smoke botones D4 (%)",
        P321 = "Interior: hueco espejo magicka/stamina (px)",
        P322 = "Interior: orbe izquierdo offset horizontal (px)",
        P323 = "Invierte la posicion horizontal de magicka y stamina en modo interior. Independiente por tema (D4 / Legacy).",
        P324 = "Invertir magicka/stamina (interior)",
        P325 = "Jauge",
        P326 = "Jauge ultimate",
        P327 = "Fuente comun; tamano de texto orbes y jauge ultimate por separado.",
        P328 = "Etiqueta - D4",
        P329 = "Etiqueta - Legacy",
        P330 = "Idioma de la interfaz",
        P331 = "Ancho de la linea separadora en pixeles.",
        P332 = "Ancho fondo D4 con barra secundaria (%)",
        P333 = "Ancho fondo D4 sin barra secundaria (%)",
        P334 = "Ancho fondo jauge dual (%)",
        P335 = "Ancho fondo jauge solo (%)",
        P336 = "Ancho jauge ultimate dual (%)",
        P337 = "Ancho jauge ultimate solo (%)",
        P338 = "El fondo sigue el tema activo (D4: fond_jauge.dds, Legacy: UltimateGaugeBackground.dds). Los deslizadores controlan tamano/offset/opacidad.",
        P339 = "El texto ultimate es independiente del pulso de la jauge y siempre legible.",
        P340 = "Legacy - Fondo y barra trasera",
        P341 = "Luminosidad barra D4 (%)",
        P342 = "Luminosidad de los socles (preset)",
        P343 = "Luminosidad del fondo (%)",
        P344 = "Luminosidad global (%)",
        P345 = "Luminosidad global del fondo (%)",
        P346 = "Modo 2 barras: se aplica a la barra secundaria cuando se detecta sistema dual.",
        P347 = "Sube o baja el texto del escudo en D4 de forma independiente.",
        P348 = "Sube o baja el texto del escudo en Legacy de forma independiente.",
        P349 = "Sube o baja la barra en modo dual (barra secundaria activada).",
        P350 = "Sube o baja la barra en modo solo (barra secundaria desactivada).",
        P351 = "Sube o baja la jauge ultimate en modo dual.",
        P352 = "Sube o baja la jauge ultimate en modo solo.",
        P353 = "Sube o baja el fondo de jauge en modo dual.",
        P354 = "Sube o baja el fondo de jauge en modo solo.",
        P355 = "Sube o baja el texto de valores de los orbes.",
        P356 = "Sube o baja orbes y socles en modo dual (barra secundaria activada).",
        P357 = "Sube o baja orbes y socles en modo solo (barra secundaria desactivada).",
        P358 = "Nivel de capa escudo D4",
        P359 = "Oscuridad contornos botones D4 (%)",
        P360 = "Offset X atajos (px)",
        P361 = "Offset X ultimate (px)",
        P362 = "Offset Y atajos (px)",
        P363 = "Offset Y ultimate (px)",
        P364 = "Offset horizontal (px)",
        P365 = "Offset slot atajo D4 (px)",
        P366 = "Offset slot ultimate D4 (px)",
        P367 = "Offset vertical (px)",
        P368 = "Offset vertical 5 slots - barra dual (px)",
        P369 = "Offset vertical 5 slots - barra solo (px)",
        P370 = "Offset vertical barra - Dual (px)",
        P371 = "Offset vertical barra - Solo (px)",
        P372 = "Offset vertical fondo jauge dual (px)",
        P373 = "Offset vertical fondo jauge solo (px)",
        P374 = "Offset vertical glow D4 (px)",
        P375 = "Offset vertical glow espejo (px)",
        P376 = "Offset vertical jauge ultimate dual (px)",
        P377 = "Offset vertical jauge ultimate solo (px)",
        P378 = "Offset vertical slot atajo D4 (px)",
        P379 = "Offset vertical slot ultimate D4 (px)",
        P380 = "Offset vertical texto valores (px)",
        P381 = "Sombra interna: tamano (px)",
        P382 = "Sombra minima D4 (%)",
        P383 = "Opacidad (%)",
        P384 = "Opacidad barra inactiva 2 barras (%)",
        P385 = "Opacidad borde tooltip valores (%)",
        P386 = "Opacidad contornos botones D4 (%)",
        P387 = "Opacidad capa tinte (%)",
        P388 = "Opacidad atajos (%)",
        P389 = "Opacidad escudo D4 (%)",
        P390 = "Opacidad escudo Legacy (%)",
        P391 = "Opacidad del glow de alerta de recurso bajo.",
        P392 = "Opacidad fondo contraste interior (%)",
        P393 = "Opacidad fondo de jauge (%)",
        P394 = "Opacidad global orbes y socles (%)",
        P395 = "Opacidad glow de alerta (%)",
        P396 = "Opacidad sombra texto interior (%)",
        P397 = "Opacidad relleno jauge (%)",
        P398 = "Opacidad texto ultimate (%)",
        P399 = "Opacidad texto valores (%)",
        P400 = "Opciones comunes de barra de accion DiabloOrbs. Los ajustes solo/dual permiten comportamiento distinto segun el modo detectado.",
        P401 = "Orbes D4",
        P402 = "Orbes Legacy",
        P403 = "Organizacion: familia de fuente comun, luego ajustes separados para valores de orbes y texto de barra de ultimate.",
        P404 = "Fuente de numeros (comun a todos los temas)",
        P405 = "Posicion de atajos",
        P406 = "Posicion de valores",
        P407 = "Posicion y tamano",
        P408 = "Posicion y tamano — ajustes globales",
        P409 = "Posicion de orbes — Dual",
        P410 = "Posicion de orbes — Solo",
        P411 = "Posicion vertical de orbes — Dual (px)",
        P412 = "Posicion vertical de orbes — Solo (px)",
        P413 = "Atajos",
        P414 = "Atajos visibles solo en combate",
        P415 = "Escala de forma uniforme todas las capas de orbes Legacy juntas.",
        P416 = "Reflejo en reposo D4 (%)",
        P417 = "Avanzado: intensidad dual multiplicada por la opacidad principal.",
        P418 = "Avanzado: intensidad solo multiplicada por la opacidad principal.",
        P419 = "Opacidad principal de contornos de botones D4 (atajo, 5 slots, ultimate, companero).",
        P420 = "Ajustes generales de DiabloOrbs.",
        P421 = "Ajustes por tema (D4 o Legacy), con valores distintos para solo/dual.",
        P422 = "Ajusta la separacion lateral de los valores exteriores respecto a los bordes del orbe.",
        P423 = "Ajusta la opacidad de la barra secundaria inactiva cuando se detecta configuracion de 2 barras.",
        P424 = "Ajusta la opacidad del borde decorativo alrededor del texto de valores.",
        P425 = "Ajusta la opacidad de la capa de sombra de los orbes D4.",
        P426 = "Ajusta la opacidad de la capa de color extra detras de los orbes.",
        P427 = "Ajusta la opacidad de la capa de fondo coloreado de los orbes D4.",
        P428 = "Ajusta la opacidad de la capa de glow de los orbes D4.",
        P429 = "Ajusta la opacidad de la capa de relleno Smoke de los orbes D4.",
        P430 = "Ajusta la opacidad de la superposicion de contorno de los orbes D4.",
        P431 = "Ajusta la opacidad de la sombra real del texto detras de valores dentro del orbe.",
        P432 = "Ajusta la opacidad del contorno principal de los orbes D4.",
        P433 = "Ajusta la opacidad del fondo de contraste detras de valores dentro del orbe.",
        P434 = "Ajusta la opacidad del texto de la barra de ultimate sin afectar el pulso de la barra.",
        P435 = "Ajusta la opacidad del texto de valores con cualquier colocacion.",
        P436 = "Ajusta la opacidad de la linea separadora magicka/stamina.",
        P437 = "Ajusta el brillo general del fondo coloreado Smoke.dds de los orbes D4.",
        P438 = "Ajusta la posicion vertical de los valores exteriores.",
        P439 = "Ajusta el tamano de fuente del texto en la barra de ultimate.",
        P440 = "Ajusta la transparencia del fondo de la barra sin tocar el texto.",
        P441 = "Restablece todos los ajustes D4 a valores calibrados por defecto. No afecta a Legacy.",
        P442 = "Restablece todos los ajustes Legacy a valores por defecto. No afecta a D4.",
        P443 = "Relleno — desplazamiento fino",
        P444 = "Refuerza el contraste del contorno (100 = normal, >100 = mas marcado).",
        P445 = "Refuerza o suaviza el color de fondo Smoke.dds para todos los recursos D4.",
        P446 = "Restablecer D4 (posiciones por defecto)",
        P447 = "Restablecer Legacy (posiciones por defecto)",
        P448 = "Separador central: tamano (px)",
        P449 = "Si esta activo, los atajos de habilidades solo se muestran en combate.",
        P450 = "Slots — Dual",
        P451 = "Slots — Solo",
        P452 = "Estilo de texto interior",
        P453 = "Superpone D4OrbBack2 en modo aditivo para aclarar el orbe sin recolorear el fondo.",
        P454 = "Tamano de cada icono de la backbar en pixeles.",
        P455 = "Tamano de cada icono en pixeles.",
        P456 = "Tamano de la capa de sombra interna de orbes Legacy (Shade.dds). 150 = valor por defecto.",
        P457 = "Tamano de orbes (px)",
        P458 = "Tamano de atajos (%)",
        P459 = "Tamano de slots de la backbar. 80 = mas pequenos que la barra activa para dar profundidad.",
        P460 = "Tamano del marco circular de orbes Legacy. 166 = XML por defecto. Reducir para evitar solapamiento con orbes grandes.",
        P461 = "Tamano del circulo escudo D4 (%)",
        P462 = "Tamano del circulo escudo Legacy (%)",
        P463 = "Tamano del glow de alerta de recurso bajo respecto al glow normal. 100 = igual.",
        P464 = "Tamano del glow de orbes Legacy. 150 = valor por defecto.",
        P465 = "Tamano del separador entre magicka y stamina (Split.dds). 166 = valor por defecto.",
        P466 = "Tamano del fondo de barra D4 (%)",
        P467 = "Tamano global de la backbar Legacy.",
        P468 = "Tamano global de orbes (%)",
        P469 = "Tamano global del separador como porcentaje del tamano del orbe.",
        P470 = "Tamano del glow de alerta (%)",
        P471 = "Tamano de fuente del texto de ultimate",
        P472 = "Tamano de slots (px)",
        P473 = "Tamano de slots de backbar (px)",
        P474 = "Tinte aplicada al fondo de la barra.",
        P475 = "Tinte global D4",
        P476 = "Texto",
        P477 = "Texto y valores",
        P478 = "Tema visual",
        P479 = "Desplaza juntos los dos orbes de la capa aditiva a izquierda/derecha.",
        P480 = "Transparencia de la backbar. 0 = invisible, 100 = opaca.",
        P481 = "Transparencia de los iconos de la backbar Legacy.",
        P482 = "Tipografia comun",
        P483 = "Valor positivo = magicka/stamina se separan del centro (capa smoke), negativo = se acercan.",
        P484 = "Valores de orbes",
        P485 = "Visual — D4",
        P486 = "Visual — Legacy",
        P487 = "[Tema D4] Activar barra secundaria (modo Dual)",
        P488 = "[Tema Legacy] Activar barra secundaria (modo Dual)",
        P489 = "|cFFAA00[!] Para un resultado optimo (solo y dual), activa en|r |cFFFFFFAjustes > Combate|r |cFFAA00:|r |cFFFFFF\"Fila trasera de la barra de habilidades\"|r |cFFAA00y|r |cFFFFFF\"Temporizadores de barra de habilidades\"|r|cFFAA00. (Todos los temas)|r",
        P490 = "Perfiles",
        P491 = "Gestiona tus perfiles de configuracion. Un perfil guarda todos los ajustes visuales. Puedes compartir un perfil entre varios personajes de la misma cuenta.",
        P492 = "Perfil activo",
        P493 = "Selecciona el perfil a cargar. Haz clic en 'Cargar perfil seleccionado' para aplicar.",
        P494 = "Cargar perfil seleccionado",
        P495 = "Aplica los ajustes del perfil seleccionado a este personaje.",
        P496 = "Guardar (sobrescribir perfil activo)",
        P497 = "Sobrescribe el perfil activo con tu configuracion actual.",
        P498 = "Guardar como... (nuevo nombre)",
        P499 = "Crea un nuevo perfil con el nombre introducido y tu configuracion actual.",
        P500 = "Crear este nuevo perfil",
        P501 = "Crea o sobreescribe un perfil con el nombre introducido arriba.",
        P502 = "Eliminar perfil seleccionado",
        P503 = "Elimina el perfil seleccionado ('D4 default' y 'Legacy default' estan protegidos).",
        P504 = "Decoraciones (Angel / Demon)",
        P505 = "Mostrar decoraciones (Angel / Demon)",
        P506 = "Primer plano (delante de los orbes)",
        P507 = "Intercambiar lados (Angel/Demon)",
        P508 = "Marco ornamental: tamano (px)",
        P509 = "Sombra interior: tamano (px)",
        P510 = "Separador central: tamano (px)",
        P511 = "Glow: tamano (px)",
        P512 = "Tamano base (px)",
        P513 = "Ancho (%)",
        P514 = "Alto (%)",
        P515 = "Separacion desde el centro (px)",
        P516 = "Desplazamiento vertical (px)",
        P517 = "Tamano del marco circular Legacy. El valor XML por defecto es 166. Reducir para evitar superposicion cuando los orbes son grandes. [ID: B93]",
        P518 = "Tamano de la capa de sombra interior Legacy (Shade.dds). Valor por defecto: 150. [ID: B94]",
        P519 = "Tamano del separador entre Magia y Resistencia (Split.dds). Valor por defecto: 166. [ID: B95]",
        P520 = "Tamano del glow de los orbes Legacy. Valor por defecto: 150. [ID: B96]",
        P521 = "Muestra u oculta las imagenes decorativas Angel y Demon a cada lado de los orbes (solo Legacy). [ID: LD10]",
        P522 = "Tamano de referencia para las imagenes Angel y Demon. El ancho y alto son porcentajes de este valor. [ID: LD11]",
        P523 = "Distancia horizontal entre el centro de la pantalla y cada imagen. 0 = centro. [ID: LD12]",
        P524 = "Mueve las decoraciones hacia arriba (negativo) o hacia abajo (positivo). [ID: LD13]",
        P525 = "Muestra las decoraciones delante de todos los elementos. Desactivado = fondo. [ID: LD14]",
        P526 = "Intercambia posiciones: Angel a la izquierda, Demon a la derecha. [ID: LD15]",
        P527 = "Ancho en % del tamano base. [ID: LD16]",
        P528 = "Alto en % del tamano base. [ID: LD17]",
        P529 = "Este perfil esta protegido y no puede ser sobrescrito.",
        P530 = "Este perfil esta protegido y no puede ser eliminado.",
        P531 = "Por favor, introduce un nombre de perfil.",
        P532 = "Este nombre de perfil esta protegido y no puede ser utilizado.",
    },
    it = {
        DESC = "Impostazioni di DiabloOrbs.",
        SECTION_LANGUAGE = "Lingua",
        LANG_MODE_NAME = "Lingua dell'addon",
        LANG_MODE_TIP = "Auto usa la lingua del client di gioco. Manuale forza la lingua selezionata.",
        LANG_MODE_AUTO = "Auto (lingua del gioco)",
        LANG_MODE_HINT = "Se alcune etichette non si aggiornano subito, chiudi e riapri il pannello impostazioni.",
        RELOAD_UI_NAME = "Ricarica UI ora",
        RELOAD_UI_TIP = "Consigliato dopo il cambio lingua per aggiornare subito tutte le etichette.",
        SECTION_ULTIMATE = "Barra Ultimate",
        SHOW_ULTIMATE_BAR_NAME = "Mostra barra ultimate",
        SHOW_ULTIMATE_BAR_TIP = "Mostra o nasconde la barra ultimate centrale.",
        SHOW_ULTIMATE_TEXT_NAME = "Mostra testo attuale/costo",
        SHOW_ULTIMATE_TEXT_TIP = "Mostra il progresso ultimate direttamente sulla barra centrale.",
        ULTIMATE_TEXT_MODE_NAME = "Formato testo ultimate",
        ULTIMATE_TEXT_MODE_TIP = "Scegli il formato mostrato sulla barra ultimate.",
        ULTIMATE_TEXT_MODE_VALUE = "Valore (attuale/costo)",
        ULTIMATE_TEXT_MODE_PERCENT = "Percentuale",
        ULTIMATE_READY_COLOR_NAME = "Colore quando ultimate e pronta",
        ULTIMATE_READY_COLOR_TIP = "Colore applicato alla barra centrale quando l'ultimate e pronta.",
        ULTIMATE_PULSE_SPEED_NAME = "Velocita pulsazione",
        ULTIMATE_PULSE_SPEED_TIP = "Velocita del pulse quando l'ultimate e pronta.",
        ULTIMATE_PULSE_MIN_NAME = "Pulse alpha min (%)",
        ULTIMATE_PULSE_MIN_TIP = "Opacita minima del pulse della barra ultimate.",
        ULTIMATE_PULSE_MAX_NAME = "Pulse alpha max (%)",
        ULTIMATE_PULSE_MAX_TIP = "Opacita massima del pulse della barra ultimate.",
        SECTION_ALERT = "Avvisi risorse",
        LOW_RESOURCE_NAME = "Soglia risorsa bassa (%)",
        LOW_RESOURCE_TIP = "Attiva il glow quando una risorsa scende sotto questa soglia.",
        GLOW_MAX_NAME = "Intensita massima glow (%)",
        GLOW_MAX_TIP = "Intensita massima dell'alone durante l'avviso risorsa bassa.",
        GLOW_INTERNAL_NAME = "Glow interno rigoroso",
        GLOW_INTERNAL_TIP = "Glow solo entro i bordi dell'orba. Disattiva per un effetto piu marcato.",
        BORDER_PULSE_ENABLE_NAME = "Attiva pulse colore bordo",
        BORDER_PULSE_ENABLE_TIP = "Quando la risorsa e bassa, il bordo ornamentale pulsa col colore scelto.",
        BORDER_PULSE_COLOR_NAME = "Colore pulse avviso",
        BORDER_PULSE_COLOR_TIP = "Colore del bordo con risorsa bassa.",
        SECTION_ORB_STYLE = "Orbe - Stile",
        SMOKE_ALPHA_NAME = "Trasparenza smoke (%)",
        SMOKE_ALPHA_TIP = "Regola l'opacita dell'effetto smoke sulle orbe.",
        SMOKEBG_BRIGHTNESS_NAME = "Luminosita sfondo orbe (%)",
        SMOKEBG_BRIGHTNESS_TIP = "0% = sfondo scuro. 100% = sfondo piu luminoso.",
        ORB_COLOR_BOOST_NAME = "Intensita colore globale (%)",
        ORB_COLOR_BOOST_TIP = "Boost globale colore orbe.",
        SHADE_ALPHA_NAME = "Intensita ombra interna (%)",
        SHADE_ALPHA_TIP = "0% = senza ombra, 100% = ombra completa.",
        BORDER_ALPHA_NAME = "Opacita bordo circolare (%)",
        BORDER_ALPHA_TIP = "Regola l'opacita del bordo ornamentale.",
        SPLIT_ALPHA_NAME = "Opacita separatore (%)",
        SPLIT_ALPHA_TIP = "Regola l'opacita della linea tra Magicka e Stamina.",
        SHIELD_ALPHA_NAME = "Opacita scudo (%)",
        SHIELD_ALPHA_TIP = "Regola l'opacita visiva dello scudo.",
        SHIELD_RING_SCALE_NAME = "Dimensione anello scudo (%)",
        SHIELD_RING_SCALE_TIP = "Regola spessore/dimensione visiva dell'anello scudo nell'orba salute.",
        SHIELD_VISUAL_RESPONSE_NAME = "Risposta visiva scudo (%)",
        SHIELD_VISUAL_RESPONSE_TIP = "Piu alto = reazione visiva piu rapida. 100% = lineare.",
        SECTION_ORB_COLORS = "Orbe - Colori",
        HEALTH_COLOR_NAME = "Colore orba Salute",
        MAGICKA_COLOR_NAME = "Colore orba Magicka",
        STAMINA_COLOR_NAME = "Colore orba Stamina",
        SHIELD_COLOR_NAME = "Colore orba Scudo",
        SECTION_TEXT = "Etichette valori",
        LABEL_SCALE_NAME = "Dimensione etichetta (%)",
        LABEL_SCALE_TIP = "Regola la dimensione delle etichette valore/percentuale sulle orbe.",
        LABEL_FORMAT_NAME = "Visualizzazione valori risorse",
        LABEL_FORMAT_TIP = "Scegli come mostrare i valori numerici sulle orbe.",
        LABEL_FORMAT_HIDDEN = "Nascosto",
        LABEL_FORMAT_VALUE = "Valore (es. 23k)",
        LABEL_FORMAT_PERCENT = "Percentuale (es. 75%)",
        ULT_TT_READY_OVER = "Ultimate: <<1>> / <<2>> (Pronta, +<<3>>)",
        ULT_TT_READY = "Ultimate: <<1>> / <<2>> (Pronta)",
        ULT_TT_NORMAL = "Ultimate: <<1>> / <<2>>",
        P001 = "0 = glow bianco puro. 100 = glow tinta al colore dell'orbe.",
        P002 = "0 = modalita normale (alpha). 100 = modalita additiva (piu impatto e luminosita su sfondi scuri).",
        P003 = "0 = nessuna tinta (colore originale), 100 = tinta piena.",
        P004 = "100 = normale, fino a 500 per molto luminoso.",
        P005 = "100 = normale. Alza per piu luminosita, abbassa per scurire.",
        P006 = "Abilita gestione slot/hotkey/armi DiabloOrbs. Disattivato: DiabloOrbs mantiene i visual (skin/sfondi/jauge ultimate) e lascia gli slot a un altro addon.",
        P007 = "Abilita modalita additiva su stamina dell'orbe combinato D4 (altrimenti solo magicka).",
        P008 = "Attiva o disattiva completamente il widget centrale ultimate di DiabloOrbs, indipendentemente dal resto della barra.",
        P009 = "Attiva o disattiva i bordi slot tema D4 aggiunti da DiabloOrbs.",
        P010 = "Glow contenuto dentro gli orbi D4. Disattivato = glow piu drammatico che esce un po'.",
        P011 = "Abilita glow di allerta quando una risorsa scende sotto la soglia.",
        P012 = "Rendering piu luminoso del separatore (utile su sfondi scuri).",
        P013 = "Attiva strato di fondo tintato",
        P014 = "Attiva luce additiva",
        P015 = "Abilita glow di allerta per soglia bassa",
        P016 = "Mostra il valore numerico dello scudo nel tema D4.",
        P017 = "Mostra il valore numerico dello scudo nel tema Legacy.",
        P018 = "Mostra il cambio arma sulla barra standard e la freccia sulla versione dual quando disponibile.",
        P019 = "Mostra lo sfondo decorativo dietro la jauge ultimate.",
        P020 = "Mostra le icone abilita della barra inattiva sullo sfondo in modalita Dual con sfondo dual Legacy. (solo tema Legacy)",
        P021 = "Mostra impostazioni separate solo/dual per rifinire l'intensita del contorno. L'opacita principale resta il controllo consigliato.",
        P022 = "Mostra gli slot della barra inattiva sullo sfondo in modalita dual. Vale solo per la modalita D4.",
        P023 = "Mostra testo/hotkey sugli slot della barra azioni con UI tastiera.",
        P024 = "Mostra o nasconde lo strato ombra sugli orbi D4.",
        P025 = "Mostra o nasconde lo strato di riempimento colorato dentro gli orbi D4.",
        P026 = "Mostra o nasconde lo strato glow luminoso sugli orbi D4.",
        P027 = "Mostra o nasconde lo strato di riempimento Smoke sugli orbi D4.",
        P028 = "Mostra o nasconde la sovrapposizione contorno sugli orbi D4.",
        P029 = "Mostra o nasconde il contorno principale sugli orbi D4.",
        P030 = "Mostra o nasconde base barra, rifiniture e supporti visivi della barra azioni DiabloOrbs.",
        P031 = "Mostra o nasconde lo slot ultimate del compagno senza modificare il resto della barra.",
        P032 = "Mostra o nasconde gli slot abilita gestiti da DiabloOrbs. Comodo per tenere solo lo sfondo o il contrario.",
        P033 = "Mostra una linea semplice tra magicka e stamina.",
        P034 = "Mostra una seconda barra sullo sfondo con texture dual. Disattiva per una sola barra. (solo tema D4)",
        P035 = "Mostra sfondo jauge ultimate",
        P036 = "Mostra indicatore cambio arma",
        P037 = "Mostra ombra",
        P038 = "Mostra ultimate del compagno",
        P039 = "Mostra jauge ultimate centrale DiabloOrbs",
        P040 = "Mostra sovrapposizione",
        P041 = "Mostra contorno",
        P042 = "Mostra riempimento colorato",
        P043 = "Mostra base/supporto barra DiabloOrbs",
        P044 = "Mostra glow",
        P045 = "Mostra smoke",
        P046 = "Mostra linea di separazione",
        P047 = "Mostra bordi slot D4",
        P048 = "Mostra hotkey degli slot",
        P049 = "Mostra slot abilita DiabloOrbs",
        P050 = "Mostra impostazioni avanzate contorno solo/dual",
        P051 = "Mostra valore scudo (D4)",
        P052 = "Mostra valore scudo (Legacy)",
        P053 = "Aggiunge un velo Smoke tintato dai colori degli orbi per fondere i pulsanti nel tema.",
        P054 = "Aggiunge uno strato di colore dietro il riempimento degli orbi principali.",
        P055 = "Regola l'allineamento del riempimento dentro gli orbi.",
        P056 = "Regola la spaziatura dei 5 slot centrali in Legacy dual.",
        P057 = "Regola la spaziatura dei 5 slot centrali in Legacy solo.",
        P058 = "Regola la spaziatura dei 5 slot centrali nel tema D4.",
        P059 = "Regola la spaziatura orizzontale degli orbi vita/combinati attorno al centro sullo strato 1.",
        P060 = "Regola la spaziatura speculare degli orbi dello strato additivo (magicka/stamina).",
        P061 = "Regola la desaturazione sulla barra secondaria inattiva in modalita due barre.",
        P062 = "Regola lo spessore verticale della jauge ultimate in modalita dual.",
        P063 = "Regola lo spessore verticale della jauge ultimate in modalita solo.",
        P064 = "Regola lo spessore visivo dell'anello scudo nell'orbe vita (tema D4).",
        P065 = "Regola lo spessore visivo dell'anello scudo nell'orbe vita (tema Legacy).",
        P066 = "Regola l'opacita visiva dello scudo nel tema D4.",
        P067 = "Regola l'ordine di disegno dello scudo D4. Piu alto = piu in superficie.",
        P068 = "Regola l'altezza dello strato di riempimento colorato sugli orbi D4.",
        P069 = "Regola l'altezza della base barra D4 con barra secondaria attiva.",
        P070 = "Regola l'altezza della base barra D4 con barra secondaria disattivata.",
        P071 = "Regola l'altezza dello sfondo jauge ultimate in modalita dual.",
        P072 = "Regola l'altezza dello sfondo jauge ultimate in modalita solo.",
        P073 = "Regola la larghezza dello strato di riempimento colorato sugli orbi D4.",
        P074 = "Regola la larghezza della jauge ultimate in modalita dual.",
        P075 = "Regola la larghezza della jauge ultimate in modalita solo.",
        P076 = "Regola la larghezza dello sfondo barra D4 quando la barra secondaria e attiva.",
        P077 = "Regola la larghezza dello sfondo barra D4 quando la barra secondaria e disattivata.",
        P078 = "Regola la larghezza dello sfondo indicatore in modalita dual.",
        P079 = "Regola la larghezza dello sfondo indicatore in modalita solo.",
        P080 = "Regola la luminosita di D4OrbFill.dds, usato come base neutra della sfera.",
        P081 = "Regola la luminosita della barra D4 con le 2 texture base. 100 = sorgente, sotto scurisce, sopra schiarisce.",
        P082 = "Regola la luminosita della linea di separazione.",
        P083 = "Regola la luminosita complessiva del riempimento sfere. 100% = normale.",
        P084 = "Regola la dimensione dello strato ombra delle sfere D4.",
        P085 = "Regola la dimensione dello strato bagliore delle sfere D4.",
        P086 = "Regola la dimensione dello strato di riempimento Smoke delle sfere D4.",
        P087 = "Regola la dimensione della sovrapposizione contorno delle sfere D4.",
        P088 = "Regola la dimensione del contorno principale delle sfere D4.",
        P089 = "Regola la dimensione del testo delle scorciatoie abilita.",
        P090 = "Regola la dimensione complessiva delle sfere D4 e dei loro strati, range esteso.",
        P091 = "Regola la dimensione reale dello sfondo barra D4. 100 = dimensione sorgente, piu alto ingrandisce, piu basso riduce.",
        P092 = "Regola la trasparenza del testo delle scorciatoie abilita.",
        P093 = "Regola tasti e icone nella barra D4. Il contenuto segue automaticamente la dimensione; questa opzione affina il risultato.",
        P094 = "Avvisi",
        P095 = "Aspetto",
        P096 = "Applica una tinta colorata alle cornici sfere D4, basamenti, sovrapposizione contorno, sfondo barra e sfondo indicatore ultimate.",
        P097 = "Applica a resistenza",
        P098 = "Scurimento contorno slot compagno (%)",
        P099 = "Scurisce tutti i contorni dei pulsanti abilita D4.",
        P100 = "Scurisce solo il contorno dello slot compagno senza modificare gli altri contorni D4.",
        P101 = "Attenua la barra ultimate senza influire sul testo mostrato sopra.",
        P102 = "Barra secondaria (barra D4 inattiva)",
        P103 = "Barra azioni - Comune",
        P104 = "Barra azioni - D4",
        P105 = "Base",
        P106 = "Bordi e contorni",
        P107 = "Scudo",
        P108 = "Scudo D4: offset orizzontale (px)",
        P109 = "Scudo D4: offset verticale (px)",
        P110 = "Scudo Legacy: offset orizzontale (px)",
        P111 = "Scudo Legacy: offset verticale (px)",
        P112 = "Cornice ornamentale: dimensione (px)",
        P113 = "Queste impostazioni spostano o ridimensionano tutti gli orbs e i basamenti.",
        P114 = "Imposta il colore dello strato di sfondo aggiunto agli orbs.",
        P115 = "Imposta il colore del testo sulla barra ultimate.",
        P116 = "Imposta il colore della linea tra magicka e stamina.",
        P117 = "Imposta il carattere per valori degli orbs e testo ultimate. I font custom usano file in DiabloOrbs/Fonts (altrimenti font ESO).",
        P118 = "Posizione testi scorciatoie abilita: sopra, sotto o dentro gli slot.",
        P119 = "Tema texture (Legacy o D4). ReloadUI automatico per applicare.",
        P120 = "Scegli una variante DDS piu chiara o scura per i basamenti sotto gli orbs.",
        P121 = "Colore ombreggiatura dietro il testo al centro degli orbs.",
        P122 = "Comune",
        P123 = "Affidare la barra azioni a DiabloOrbs",
        P124 = "Contrasto contorno pulsanti D4 (%)",
        P125 = "Controlla la trasparenza complessiva degli orbs e dei basamenti.",
        P126 = "Livello 1: Sfondo colorato",
        P127 = "Livello 1: distanza tra orbs (px)",
        P128 = "Livello 1: altezza (%)",
        P129 = "Livello 1: larghezza (%)",
        P130 = "Livello 1: luminosita (%)",
        P131 = "Livello 1: offset X (px)",
        P132 = "Livello 1: offset Y (px)",
        P133 = "Livello 1: offset globale X (px)",
        P134 = "Livello 1: opacita (%)",
        P135 = "Livello 2: smoke colorato",
        P136 = "Livello 2: colore scudo D4",
        P137 = "Livello 2: colore stamina D4",
        P138 = "Livello 2: colore magicka D4",
        P139 = "Livello 2: colore salute D4",
        P140 = "Livello 2: distanza dal centro (px)",
        P141 = "Livello 2: offset Y (px)",
        P142 = "Livello 2: offset globale X (px)",
        P143 = "Livello 2: opacita (%)",
        P144 = "Livello 2: dimensione (%)",
        P145 = "Livello 3: luce additiva",
        P146 = "Livello 3: distanza tra orbs (px)",
        P147 = "Livello 3: intensita (%)",
        P148 = "Livello 3: offset X (px)",
        P149 = "Livello 4: glow",
        P150 = "Livello 4: luminosita (%)",
        P151 = "Livello 4: offset X (px)",
        P152 = "Livello 4: offset Y (px)",
        P153 = "Livello 4: opacita (%)",
        P154 = "Livello 4: dimensione (%)",
        P155 = "Livello 4: tinta colore orb (%)",
        P156 = "Livello 5: ombra",
        P157 = "Livello 5: distanza tra orbs (px)",
        P158 = "Livello 5: offset X (px)",
        P159 = "Livello 5: offset Y (px)",
        P160 = "Livello 5: opacita (%)",
        P161 = "Livello 5: dimensione (%)",
        P162 = "Livello 6: contorno principale",
        P163 = "Livello 6: distanza tra orbs (px)",
        P164 = "Livello 6: offset X (px)",
        P165 = "Livello 6: offset Y (px)",
        P166 = "Livello 6: opacita (%)",
        P167 = "Livello 6: dimensione (%)",
        P168 = "Livello 7: linea di separazione",
        P169 = "Livello 7: colore",
        P170 = "Livello 7: altezza (% rispetto all orb)",
        P171 = "Livello 7: larghezza (px)",
        P172 = "Livello 7: luminosita (%)",
        P173 = "Livello 7: modalita additiva",
        P174 = "Livello 7: offset X (px)",
        P175 = "Livello 7: offset Y (px)",
        P176 = "Livello 7: opacita (%)",
        P177 = "Livello 7: dimensione (% rispetto all orb)",
        P178 = "Livello 8: sovrapposizione contorno",
        P179 = "Livello 8: contrasto (%)",
        P180 = "Livello 8: distanza tra orbs (px)",
        P181 = "Livello 8: luminosita (%)",
        P182 = "Livello 8: offset X (px)",
        P183 = "Livello 8: offset Y (px)",
        P184 = "Livello 8: opacita (%)",
        P185 = "Livello 8: dimensione (%)",
        P186 = "Colore scudo (Legacy)",
        P187 = "Colore stamina (Legacy)",
        P188 = "Colore magicka (Legacy)",
        P189 = "Colore salute (Legacy)",
        P190 = "Colore per elementi D4 (cornice, basamenti, overlay, barra, gauge).",
        P191 = "Colore livello tinta",
        P192 = "Colore riempimento orb stamina tema Legacy.",
        P193 = "Colore riempimento orb magicka tema Legacy.",
        P194 = "Colore riempimento orb salute tema Legacy.",
        P195 = "Colore tinta D4",
        P196 = "Colore scudo tema Legacy.",
        P197 = "Colore sfondo gauge",
        P198 = "Colore glow alerta risorse basse orb stamina.",
        P199 = "Colore glow alerta risorse basse orb magicka.",
        P200 = "Colore glow alerta risorse basse orb salute.",
        P201 = "Colore riempimento Smoke per l'orbe stamina D4.",
        P202 = "Colore riempimento Smoke per l'orbe magicka D4.",
        P203 = "Colore riempimento Smoke per l'orbe salute D4.",
        P204 = "Colore riempimento Smoke per lo scudo D4.",
        P205 = "Colore glow allerta stamina (RGB)",
        P206 = "Colore glow allerta magicka (RGB)",
        P207 = "Colore glow allerta salute (RGB)",
        P208 = "Colore ombra testo interno",
        P209 = "Colore testo ultimate",
        P210 = "Colori",
        P211 = "D4: spaziatura orizzontale dei 5 slot (px)",
        P212 = "Offset riempimento — orbe salute (px)",
        P213 = "Offset riempimento — orbe combinato (px)",
        P214 = "Offset verticale (px)",
        P215 = "Sposta orizzontalmente il testo scorciatoie sugli slot.",
        P216 = "Sposta l'ultimate orizzontalmente rispetto allo slot 5.",
        P217 = "Sposta l'ultimate orizzontalmente.",
        P218 = "Sposta l'ultimate verticalmente rispetto agli altri slot.",
        P219 = "Sposta l'ultimate verticalmente.",
        P220 = "Sposta la backbar Legacy a sinistra o destra.",
        P221 = "Sposta la backbar Legacy in alto (negativo) o in basso.",
        P222 = "Sposta la backbar a sinistra o destra rispetto alla barra attiva.",
        P223 = "Sposta la backbar in alto (negativo) o in basso rispetto alla barra attiva. Default -28 per mostrare circa il 20% degli slot.",
        P224 = "Sposta l'intero livello 1 sx/dx senza cambiare la distanza tra gli orbs.",
        P225 = "Sposta il livello Smoke su o giu.",
        P226 = "Sposta il livello ombra a sinistra o destra.",
        P227 = "Sposta il livello ombra su o giu.",
        P228 = "Sposta il livello sfondo colorato su o giu.",
        P229 = "Sposta il livello glow a sinistra o destra.",
        P230 = "Sposta il livello glow su o giu.",
        P231 = "Sposta il riempimento (smoke) negli orbs: salute a sx, combinato a dx dello stesso valore.",
        P232 = "Sposta la sovrapposizione contorno a sinistra o destra.",
        P233 = "Sposta la sovrapposizione contorno su o giu.",
        P234 = "Sposta il contorno principale a sinistra o destra.",
        P235 = "Sposta il contorno principale su o giu.",
        P236 = "Sposta lo slot scorciatoia in Legacy dual.",
        P237 = "Sposta lo slot scorciatoia in Legacy solo.",
        P238 = "Sposta lo slot ultimate in Legacy dual.",
        P239 = "Sposta lo slot ultimate in Legacy solo.",
        P240 = "Sposta la linea separatrice a sinistra o destra.",
        P241 = "Sposta la linea separatrice su o giu.",
        P242 = "Sposta solo il riempimento (smoke) nell'orbe magicka/stamina combinato sull'asse X.",
        P243 = "Sposta solo il riempimento (smoke) nell'orbe salute sull'asse X.",
        P244 = "Sposta verticalmente il testo scorciatoie sugli slot.",
        P245 = "Sposta orizzontalmente il valore dell'orbe sinistro (salute) intorno al centro.",
        P246 = "Sposta il testo scudo in modo indipendente in D4.",
        P247 = "Sposta il testo scudo in modo indipendente in Legacy.",
        P248 = "Sposta l'oggetto quickslot sx/dx sulla barra D4. Utile per riallineare dopo cambio dimensione.",
        P249 = "Sposta l'oggetto quickslot su/giu indipendentemente dallo sfondo barra.",
        P250 = "Sposta lo slot ultimate sx/dx sulla barra D4 (negativo = sx). Utile per riallineare.",
        P251 = "Sposta lo slot ultimate su/giu indipendentemente dallo sfondo barra.",
        P252 = "Sposta le 3 istanze sfondo (salute + magicka + stamina) nella stessa direzione.",
        P253 = "Sposta le 3 istanze riempimento (salute + magicka + stamina) nella stessa direzione.",
        P254 = "Sposta i 5 slot centrali in modalita dual.",
        P255 = "Sposta i 5 slot centrali in modalita solo.",
        P256 = "Sposta gli orbs su o giu in modalita dual.",
        P257 = "Sposta gli orbs su o giu in modalita solo.",
        P258 = "Sposta entrambi i glow D4 in verticale insieme, mantenendo specchio sx/dx perfetto.",
        P259 = "Sposta entrambi i glow in verticale insieme, mantenendo specchio sx/dx perfetto.",
        P260 = "Desaturazione (%)",
        P261 = "Desaturazione barra inattiva, 2 barre (%)",
        P262 = "Desatura le icone backbar per distinguerle dalla barra attiva.",
        P263 = "Desatura le icone per distinguerle dalla barra attiva.",
        P264 = "Distanza degli orbs dal centro schermo in modalita solo.",
        P265 = "Distanza degli orbs dal centro in modalita dual (barra secondaria attiva).",
        P266 = "Distanza glow D4 dal centro (px)",
        P267 = "Distanza glow dal centro (px)",
        P268 = "Spazio tra ogni slot abilita della backbar.",
        P269 = "Spazio tra ogni slot.",
        P270 = "Spaziatura orizzontale dei 5 slot (px)",
        P271 = "Distanza scorciatoia dal bordo (px)",
        P272 = "Spaziatura simmetrica riempimento (px)",
        P273 = "Spaziatura ultimate (px)",
        P274 = "Distanza ultimate dal bordo (px)",
        P275 = "Allarga livello ombra: salute sx, magicka/stamina dx.",
        P276 = "Allarga livello overlay: salute sx, magicka/stamina dx.",
        P277 = "Allarga livello contorno: salute sx, magicka/stamina dx.",
        P278 = "Allarga gli orbs rispetto alla barra in modalita dual.",
        P279 = "Allarga gli orbs rispetto alla barra in modalita solo.",
        P280 = "Allarga o avvicina valori magicka/stamina dal centro dell'orbe diviso.",
        P281 = "Offset dal centro — Dual (px)",
        P282 = "Offset dal centro — Solo (px)",
        P283 = "Spaziatura orizzontale (px)",
        P284 = "Scala (%)",
        P285 = "Scala contenuto barra D4 (%)",
        P286 = "Schiarito = testo chiaro con ombra scura. Scurito = testo scuro con ombra chiara.",
        P287 = "Allontana o avvicina i glow D4 magicka e stamina dal centro.",
        P288 = "Allontana o avvicina glow magicka e stamina dal centro. Aumenta per piu spazio.",
        P289 = "In Legacy, ogni meta (magicka/stamina) ha il proprio stato allerta.",
        P290 = "Spazio extra tra slot 5 e ultimate.",
        P291 = "Spaziatura slot (px)",
        P292 = "Esterno: padding orizzontale (px)",
        P293 = "Esterno: padding verticale (px)",
        P294 = "Esterno = posizione classica. Interno = testo centrato negli orbs.",
        P295 = "Sfondo",
        P296 = "Sfondo barra D4",
        P297 = "Sfondo dual (DiabloOrbsDualBarXp)",
        P298 = "Sfondo solo (ActionBarXp)",
        P299 = "Forza ombra interna minima per verificare annidamento livelli.",
        P300 = "Allerta orbe combinato diviso",
        P301 = "Generale",
        P302 = "Glow: dimensione (px)",
        P303 = "Glow interno D4 rigido (senza trabocco)",
        P304 = "Stile pulsanti barra azione tema D4: bordi, smoke, compagno.",
        P305 = "Altezza linea separatore in percentuale della dimensione orbe.",
        P306 = "Altezza sfondo D4 con barra secondaria (%)",
        P307 = "Altezza sfondo D4 senza barra secondaria (%)",
        P308 = "Altezza sfondo jauge dual (px)",
        P309 = "Altezza sfondo jauge solo (px)",
        P310 = "Altezza jauge ultimate dual (px)",
        P311 = "Altezza jauge ultimate solo (px)",
        P312 = "Info e valori",
        P313 = "Intensita aggiuntiva contorni D4 dual (%)",
        P314 = "Intensita aggiuntiva contorni D4 solo (%)",
        P315 = "Intensita overlay additivo D4OrbBack2.",
        P316 = "Intensita tinta (%)",
        P317 = "Intensita riflesso permanente fuori allerta risorsa.",
        P318 = "Intensita massima glow allerta D4 (%)",
        P319 = "Luminosita massima alone intorno agli orbs D4 in allerta risorsa.",
        P320 = "Intensita smoke pulsanti D4 (%)",
        P321 = "Interno: gap specchio magicka/stamina (px)",
        P322 = "Interno: orbe sinistro offset orizzontale (px)",
        P323 = "Inverte posizione orizzontale valori magicka e stamina in modalita interna. Indipendente per tema (D4 / Legacy).",
        P324 = "Inverti magicka/stamina (interno)",
        P325 = "Jauge",
        P326 = "Jauge ultimate",
        P327 = "Font condiviso; dimensione testo orbs e jauge ultimate separata.",
        P328 = "Etichetta - D4",
        P329 = "Etichetta - Legacy",
        P330 = "Lingua interfaccia",
        P331 = "Larghezza linea separatore in pixel.",
        P332 = "Larghezza sfondo D4 con barra secondaria (%)",
        P333 = "Larghezza sfondo D4 senza barra secondaria (%)",
        P334 = "Larghezza sfondo jauge dual (%)",
        P335 = "Larghezza sfondo jauge solo (%)",
        P336 = "Larghezza jauge ultimate dual (%)",
        P337 = "Larghezza jauge ultimate solo (%)",
        P338 = "Lo sfondo segue il tema attivo (D4: fond_jauge.dds, Legacy: UltimateGaugeBackground.dds). I cursori controllano dimensione/offset/opacita.",
        P339 = "Il testo ultimate e' indipendente dal pulse della jauge e' sempre leggibile.",
        P340 = "Legacy - Sfondo e barra posteriore",
        P341 = "Luminosita barra D4 (%)",
        P342 = "Luminosita socles (preset)",
        P343 = "Luminosita sfondo (%)",
        P344 = "Luminosita globale (%)",
        P345 = "Luminosita globale sfondo (%)",
        P346 = "Modalita 2 barre: si applica alla barra secondaria con sistema dual rilevato.",
        P347 = "Alza o abbassa il testo scudo in D4 in modo indipendente.",
        P348 = "Alza o abbassa il testo scudo in Legacy in modo indipendente.",
        P349 = "Alza o abbassa la barra in modalita dual (barra secondaria attiva).",
        P350 = "Alza o abbassa la barra in modalita solo (barra secondaria disattiva).",
        P351 = "Alza o abbassa la jauge ultimate in modalita dual.",
        P352 = "Alza o abbassa la jauge ultimate in modalita solo.",
        P353 = "Alza o abbassa lo sfondo jauge in modalita dual.",
        P354 = "Alza o abbassa lo sfondo jauge in modalita solo.",
        P355 = "Alza o abbassa il testo valori orbs.",
        P356 = "Alza o abbassa orbs e socles in modalita dual (barra secondaria attiva).",
        P357 = "Alza o abbassa orbs e socles in modalita solo (barra secondaria disattiva).",
        P358 = "Livello strato scudo D4",
        P359 = "Oscurita contorni pulsanti D4 (%)",
        P360 = "Offset X scorciatoie (px)",
        P361 = "Offset X ultimate (px)",
        P362 = "Offset Y scorciatoie (px)",
        P363 = "Offset Y ultimate (px)",
        P364 = "Offset orizzontale (px)",
        P365 = "Offset slot scorciatoia D4 (px)",
        P366 = "Offset slot ultimate D4 (px)",
        P367 = "Offset verticale (px)",
        P368 = "Offset verticale 5 slots - barra dual (px)",
        P369 = "Offset verticale 5 slots - barra solo (px)",
        P370 = "Offset verticale barra - Dual (px)",
        P371 = "Offset verticale barra - Solo (px)",
        P372 = "Offset verticale sfondo jauge dual (px)",
        P373 = "Offset verticale sfondo jauge solo (px)",
        P374 = "Offset verticale glow D4 (px)",
        P375 = "Offset verticale glow specchio (px)",
        P376 = "Offset verticale jauge ultimate dual (px)",
        P377 = "Offset verticale jauge ultimate solo (px)",
        P378 = "Offset verticale slot scorciatoia D4 (px)",
        P379 = "Offset verticale slot ultimate D4 (px)",
        P380 = "Offset verticale testo valori (px)",
        P381 = "Ombra interna: dimensione (px)",
        P382 = "Ombra minima D4 (%)",
        P383 = "Opacita (%)",
        P384 = "Opacita barra inattiva 2 barre (%)",
        P385 = "Opacita bordo tooltip valori (%)",
        P386 = "Opacita contorni pulsanti D4 (%)",
        P387 = "Opacita strato tinta (%)",
        P388 = "Opacita scorciatoie (%)",
        P389 = "Opacita scudo D4 (%)",
        P390 = "Opacita scudo Legacy (%)",
        P391 = "Opacita glow allerta risorsa bassa.",
        P392 = "Opacita sfondo contrasto interno (%)",
        P393 = "Opacita sfondo jauge (%)",
        P394 = "Opacita globale orbs e socles (%)",
        P395 = "Opacita glow allerta (%)",
        P396 = "Opacita ombra testo interno (%)",
        P397 = "Opacita riempimento jauge (%)",
        P398 = "Opacita testo ultimate (%)",
        P399 = "Opacita testo valori (%)",
        P400 = "Opzioni comuni barra azione DiabloOrbs. Le impostazioni solo/dual cambiano in base alla modalita rilevata.",
        P401 = "Orbe D4",
        P402 = "Orbe Legacy",
        P403 = "Disposizione: famiglia di caratteri condivisa, poi impostazioni separate per valori degli orbe e testo barra ultimate.",
        P404 = "Carattere numeri (comune a tutti i temi)",
        P405 = "Posizione tasti rapidi",
        P406 = "Posizione valori",
        P407 = "Posizione e dimensione",
        P408 = "Posizione e dimensione — impostazioni globali",
        P409 = "Posizione orbe — Dual",
        P410 = "Posizione orbe — Solo",
        P411 = "Posizione verticale orbe — Dual (px)",
        P412 = "Posizione verticale orbe — Solo (px)",
        P413 = "Tasti rapidi",
        P414 = "Tasti rapidi visibili solo in combattimento",
        P415 = "Ridimensiona in modo uniforme tutti i livelli degli orbe Legacy insieme.",
        P416 = "Riflesso a riposo D4 (%)",
        P417 = "Avanzato: intensita dual moltiplicata per l'opacita principale.",
        P418 = "Avanzato: intensita solo moltiplicata per l'opacita principale.",
        P419 = "Opacita principale contorni pulsanti D4 (tasto rapido, 5 slot, ultimate, compagno).",
        P420 = "Impostazioni generali di DiabloOrbs.",
        P421 = "Impostazioni per tema (D4 o Legacy), con valori separati solo/dual.",
        P422 = "Imposta lo scostamento laterale dei valori esterni rispetto ai bordi dell'orbe.",
        P423 = "Imposta l'opacita della barra secondaria inattiva con layout a 2 barre.",
        P424 = "Imposta l'opacita del bordo decorativo intorno al testo dei valori.",
        P425 = "Imposta l'opacita del livello ombra degli orbe D4.",
        P426 = "Imposta opacita del livello colore extra dietro gli orbe.",
        P427 = "Imposta l'opacita dello sfondo colorato degli orbe D4.",
        P428 = "Imposta l'opacita del livello glow degli orbe D4.",
        P429 = "Imposta l'opacita del riempimento Smoke degli orbe D4.",
        P430 = "Imposta l'opacita della sovrapposizione contorno degli orbe D4.",
        P431 = "Imposta l'opacita dell'ombra del testo reale dietro i valori nell'orbe.",
        P432 = "Imposta l'opacita del contorno principale degli orbe D4.",
        P433 = "Imposta l'opacita dello sfondo contrasto dietro i valori nell'orbe.",
        P434 = "Imposta l'opacita del testo barra ultimate senza alterare il pulse della barra.",
        P435 = "Imposta l'opacita del testo valori indipendentemente dal posizionamento.",
        P436 = "Imposta l'opacita della linea separatrice magicka/stamina.",
        P437 = "Imposta la luminosita complessiva dello sfondo Smoke.dds colorato D4.",
        P438 = "Imposta la posizione verticale dei valori esterni.",
        P439 = "Imposta la dimensione carattere del testo sulla barra ultimate.",
        P440 = "Imposta la trasparenza dello sfondo barra senza modificare il testo.",
        P441 = "Ripristina tutte le impostazioni D4 ai valori calibrati predefiniti. Non modifica Legacy.",
        P442 = "Ripristina tutte le impostazioni Legacy ai predefiniti. Non modifica D4.",
        P443 = "Riempimento — offset fine",
        P444 = "Rafforza il contrasto del contorno (100 = normale, >100 = piu marcato).",
        P445 = "Rafforza o attenua il colore di sfondo Smoke.dds per tutte le risorse D4.",
        P446 = "Ripristina D4 (posizioni predefinite)",
        P447 = "Ripristina Legacy (posizioni predefinite)",
        P448 = "Separatore centrale: dimensione (px)",
        P449 = "Se attivo, i tasti rapidi delle abilita compaiono solo in combattimento.",
        P450 = "Slot — Dual",
        P451 = "Slot — Solo",
        P452 = "Stile testo interno",
        P453 = "Sovrappone D4OrbBack2 in additivo per schiarire l'orbe senza ricolorare lo sfondo.",
        P454 = "Dimensione di ogni icona backbar in pixel.",
        P455 = "Dimensione di ogni icona in pixel.",
        P456 = "Dimensione livello ombra interna orbe Legacy (Shade.dds). 150 = predefinito.",
        P457 = "Dimensione orbe (px)",
        P458 = "Dimensione tasti rapidi (%)",
        P459 = "Dimensione slot backbar. 80 = piu piccoli della barra attiva per piu profondita.",
        P460 = "Dimensione cornice circolare orbe Legacy. 166 = XML predefinito. Ridurre per evitare sovrapposizioni con orbe ingranditi.",
        P461 = "Dimensione cerchio scudo D4 (%)",
        P462 = "Dimensione cerchio scudo Legacy (%)",
        P463 = "Dimensione glow allerta risorse basse rispetto al glow normale. 100 = uguale.",
        P464 = "Dimensione glow orbe Legacy. 150 = predefinito.",
        P465 = "Dimensione separatore tra magicka e stamina (Split.dds). 166 = predefinito.",
        P466 = "Dimensione sfondo barra D4 (%)",
        P467 = "Dimensione globale backbar Legacy.",
        P468 = "Dimensione globale orbe (%)",
        P469 = "Dimensione globale separatore in percentuale della dimensione orbe.",
        P470 = "Dimensione glow allerta (%)",
        P471 = "Dimensione carattere testo ultimate",
        P472 = "Dimensione slot (px)",
        P473 = "Dimensione slot backbar (px)",
        P474 = "Tinta applicata allo sfondo barra.",
        P475 = "Tinta globale D4",
        P476 = "Testo",
        P477 = "Testo e valori",
        P478 = "Tema visivo",
        P479 = "Sposta insieme a sinistra/destra entrambi gli orbe del livello additivo.",
        P480 = "Trasparenza backbar. 0 = invisibile, 100 = opaca.",
        P481 = "Trasparenza icone backbar Legacy.",
        P482 = "Tipografia condivisa",
        P483 = "Valore positivo = magicka/stamina si allontanano dal centro (livello smoke), negativo = si avvicinano.",
        P484 = "Valori orbe",
        P485 = "Visivo — D4",
        P486 = "Visivo — Legacy",
        P487 = "[Tema D4] Attiva barra secondaria (modalita Dual)",
        P488 = "[Tema Legacy] Attiva barra secondaria (modalita Dual)",
        P489 = "|cFFAA00[!] Per un risultato ottimale (solo e dual), attiva in|r |cFFFFFFImpostazioni > Combattimento|r |cFFAA00:|r |cFFFFFF\"Fila posteriore della barra delle abilita\"|r |cFFAA00e|r |cFFFFFF\"Timer della barra delle abilita\"|r|cFFAA00. (Tutti i temi)|r",
        P490 = "Profili",
        P491 = "Gestisci i tuoi profili di impostazioni. Un profilo salva tutte le impostazioni visive. Puoi condividere un profilo tra piu personaggi dello stesso account.",
        P492 = "Profilo attivo",
        P493 = "Seleziona il profilo da caricare. Clicca su 'Carica profilo selezionato' per applicare.",
        P494 = "Carica profilo selezionato",
        P495 = "Applica le impostazioni del profilo selezionato a questo personaggio.",
        P496 = "Salva (sovrascrive il profilo attivo)",
        P497 = "Sovrascrive il profilo attivo con le impostazioni correnti.",
        P498 = "Salva come... (nuovo nome)",
        P499 = "Crea un nuovo profilo con il nome inserito e le impostazioni correnti.",
        P500 = "Crea questo nuovo profilo",
        P501 = "Crea o sovrascrive un profilo con il nome inserito sopra.",
        P502 = "Elimina profilo selezionato",
        P503 = "Elimina il profilo selezionato ('D4 default' e 'Legacy default' sono protetti).",
        P504 = "Decorazioni (Angel / Demon)",
        P505 = "Mostra decorazioni (Angel / Demon)",
        P506 = "Primo piano (davanti agli orbs)",
        P507 = "Inverti lati (Angel/Demon)",
        P508 = "Cornice ornamentale: dimensione (px)",
        P509 = "Ombra interna: dimensione (px)",
        P510 = "Separatore centrale: dimensione (px)",
        P511 = "Glow: dimensione (px)",
        P512 = "Dimensione base (px)",
        P513 = "Larghezza (%)",
        P514 = "Altezza (%)",
        P515 = "Distanza dal centro (px)",
        P516 = "Offset verticale (px)",
        P517 = "Dimensione della cornice circolare Legacy. Il valore XML predefinito e' 166. Ridurre per evitare sovrapposizioni quando gli orbs sono grandi. [ID: B93]",
        P518 = "Dimensione dello strato ombra interna Legacy (Shade.dds). Valore predefinito: 150. [ID: B94]",
        P519 = "Dimensione del separatore tra Magia e Stamina (Split.dds). Valore predefinito: 166. [ID: B95]",
        P520 = "Dimensione del glow degli orbs Legacy. Valore predefinito: 150. [ID: B96]",
        P521 = "Mostra o nasconde le immagini decorative Angel e Demon su ciascun lato degli orbs (solo Legacy). [ID: LD10]",
        P522 = "Dimensione di riferimento per le immagini Angel e Demon. Larghezza e altezza sono percentuali di questo valore. [ID: LD11]",
        P523 = "Distanza orizzontale tra il centro dello schermo e ciascuna immagine. 0 = centro. [ID: LD12]",
        P524 = "Sposta le decorazioni verso l'alto (negativo) o verso il basso (positivo). [ID: LD13]",
        P525 = "Mostra le decorazioni davanti a tutti gli elementi. Disattivato = sfondo. [ID: LD14]",
        P526 = "Scambia le posizioni: Angel a sinistra, Demon a destra. [ID: LD15]",
        P527 = "Larghezza in % della dimensione base. [ID: LD16]",
        P528 = "Altezza in % della dimensione base. [ID: LD17]",
        P529 = "Questo profilo e' protetto e non puo' essere sovrascritto.",
        P530 = "Questo profilo e' protetto e non puo' essere eliminato.",
        P531 = "Per favore, inserisci un nome per il profilo.",
        P532 = "Questo nome profilo e' protetto e non puo' essere utilizzato.",
    },
    ru = {
        DESC = "Настройки DiabloFrames.",
        SECTION_LANGUAGE = "Язык",
        LANG_MODE_NAME = "Язык аддона",
        LANG_MODE_TIP = "Авто использует язык клиента игры. Ручной режим принудительно выбирает язык.",
        LANG_MODE_AUTO = "Авто (язык игры)",
        LANG_MODE_HINT = "Если некоторые подписи не обновились сразу, закройте и снова откройте панель настроек.",
        RELOAD_UI_NAME = "Перезагрузить интерфейс",
        RELOAD_UI_TIP = "Рекомендуется после смены языка аддона для мгновенного обновления всех подписей.",
        SECTION_ULTIMATE = "Шкала ульты",
        SHOW_ULTIMATE_BAR_NAME = "Показывать шкалу ульты",
        SHOW_ULTIMATE_BAR_TIP = "Показывает или скрывает центральную шкалу ульты.",
        SHOW_ULTIMATE_TEXT_NAME = "Показывать текст текущее/стоимость",
        SHOW_ULTIMATE_TEXT_TIP = "Показывает прогресс ульты прямо на центральной шкале.",
        ULTIMATE_TEXT_MODE_NAME = "Формат текста ульты",
        ULTIMATE_TEXT_MODE_TIP = "Выберите формат текста на шкале ульты.",
        ULTIMATE_TEXT_MODE_VALUE = "Значение (текущее/стоимость)",
        ULTIMATE_TEXT_MODE_PERCENT = "Процент",
        ULTIMATE_READY_COLOR_NAME = "Цвет, когда ульта готова",
        ULTIMATE_READY_COLOR_TIP = "Цвет центральной шкалы, когда ульта готова.",
        ULTIMATE_PULSE_SPEED_NAME = "Скорость пульса",
        ULTIMATE_PULSE_SPEED_TIP = "Скорость пульсации, когда ульта готова.",
        ULTIMATE_PULSE_MIN_NAME = "Мин. альфа пульса (%)",
        ULTIMATE_PULSE_MIN_TIP = "Минимальная прозрачность пульса шкалы ульты.",
        ULTIMATE_PULSE_MAX_NAME = "Макс. альфа пульса (%)",
        ULTIMATE_PULSE_MAX_TIP = "Максимальная прозрачность пульса шкалы ульты.",
        SECTION_ALERT = "Оповещения ресурсов",
        LOW_RESOURCE_NAME = "Порог низкого ресурса (%)",
        LOW_RESOURCE_TIP = "Включает glow-эффект, когда ресурс падает ниже порога.",
        GLOW_MAX_NAME = "Макс. интенсивность glow (%)",
        GLOW_MAX_TIP = "Максимальная интенсивность ореола при низком ресурсе.",
        GLOW_INTERNAL_NAME = "Строго внутренний glow",
        GLOW_INTERNAL_TIP = "Glow только внутри границ орба. Выключите для более драматичного эффекта.",
        BORDER_PULSE_ENABLE_NAME = "Включить цветовой пульс рамки",
        BORDER_PULSE_ENABLE_TIP = "При низком ресурсе декоративная рамка пульсирует выбранным цветом.",
        BORDER_PULSE_COLOR_NAME = "Цвет пульса оповещения",
        BORDER_PULSE_COLOR_TIP = "Цвет рамки при низком ресурсе.",
        SECTION_ORB_STYLE = "Орбы - Стиль",
        SMOKE_ALPHA_NAME = "Прозрачность smoke (%)",
        SMOKE_ALPHA_TIP = "Настройка прозрачности smoke-эффекта на орбах ресурсов.",
        SMOKEBG_BRIGHTNESS_NAME = "Яркость фона орбов (%)",
        SMOKEBG_BRIGHTNESS_TIP = "0% = темный фон. 100% = более яркий фон.",
        ORB_COLOR_BOOST_NAME = "Глобальная интенсивность цвета (%)",
        ORB_COLOR_BOOST_TIP = "Глобальное усиление цвета орбов.",
        SHADE_ALPHA_NAME = "Интенсивность темной внутренней тени (%)",
        SHADE_ALPHA_TIP = "0% = без тени. 100% = полная тень.",
        BORDER_ALPHA_NAME = "Прозрачность круглой рамки (%)",
        BORDER_ALPHA_TIP = "Настройка прозрачности декоративной рамки.",
        SPLIT_ALPHA_NAME = "Прозрачность разделителя (%)",
        SPLIT_ALPHA_TIP = "Прозрачность линии между Магией и Выносливостью.",
        SHIELD_ALPHA_NAME = "Прозрачность щита (%)",
        SHIELD_ALPHA_TIP = "Настройка прозрачности визуального эффекта щита.",
        SHIELD_RING_SCALE_NAME = "Размер кольца щита (%)",
        SHIELD_RING_SCALE_TIP = "Визуальная толщина/размер кольца щита в орбе здоровья.",
        SHIELD_VISUAL_RESPONSE_NAME = "Визуальная реакция щита (%)",
        SHIELD_VISUAL_RESPONSE_TIP = "Выше = более быстрая визуальная реакция. 100% = линейно.",
        SECTION_ORB_COLORS = "Орбы - Цвета",
        HEALTH_COLOR_NAME = "Цвет орба Здоровья",
        MAGICKA_COLOR_NAME = "Цвет орба Магии",
        STAMINA_COLOR_NAME = "Цвет орба Выносливости",
        SHIELD_COLOR_NAME = "Цвет орба Щита",
        SECTION_TEXT = "Подписи значений",
        LABEL_SCALE_NAME = "Размер текста значений (%)",
        LABEL_SCALE_TIP = "Настройка размера подписей значений/процентов на орбах.",
        LABEL_FORMAT_NAME = "Отображение значений ресурсов",
        LABEL_FORMAT_TIP = "Выберите формат числовых значений на орбах.",
        LABEL_FORMAT_HIDDEN = "Скрыто",
        LABEL_FORMAT_VALUE = "Значение (напр. 23k)",
        LABEL_FORMAT_PERCENT = "Процент (напр. 75%)",
        ULT_TT_READY_OVER = "Ульта: <<1>> / <<2>> (Готово, +<<3>>)",
        ULT_TT_READY = "Ульта: <<1>> / <<2>> (Готово)",
        ULT_TT_NORMAL = "Ульта: <<1>> / <<2>>",
        P001 = "0 = чисто белый glow. 100 = glow в цвет орба.",
        P002 = "0 = обычный режим (альфа). 100 = аддитивный режим (сильнее контраст и яркость на тёмном фоне).",
        P003 = "0 = без оттенка (исходный цвет), 100 = полный оттенок.",
        P004 = "100 = норма, до 500 — очень ярко.",
        P005 = "100 = норма. Поднимите для большей яркости, опустите для затемнения.",
        P006 = "Включает управление слотами, горячими клавишами и оружием через DiabloOrbs. Если выключено, DiabloOrbs оставляет визуальные элементы (скины, фоны, шкалу ульты), а управление слотами отдаёт другому аддону.",
        P007 = "Включает аддитивный режим для выносливости на объединённом орбе D4 (иначе аддитив только у магии).",
        P008 = "Показывает или скрывает центральный виджет ульты DiabloOrbs независимо от остальной панели.",
        P009 = "Показывает или скрывает рамки слотов в стиле D4, добавленные DiabloOrbs.",
        P010 = "Включает glow внутри орбов D4. Выключено = более драматичный glow, слегка выходящий за границы.",
        P011 = "Включает предупреждающий glow, когда ресурс падает ниже порога.",
        P012 = "Делает разделитель ярче (удобно на тёмных фонах).",
        P013 = "Включить тонированный фоновый слой",
        P014 = "Включить аддитивное освещение",
        P015 = "Включить предупреждающий glow при низком пороге",
        P016 = "Показывает числовое значение щита в теме D4.",
        P017 = "Показывает числовое значение щита в теме Legacy.",
        P018 = "Показывает элемент смены оружия на стандартной панели и стрелку в dual-версии, если доступно.",
        P019 = "Показывает декоративный фон за шкалой ульты.",
        P020 = "Показывает иконки неактивной панели на заднем плане в режиме Dual с фоном dual Legacy. (Только тема Legacy)",
        P021 = "Показывает отдельные настройки solo/dual для тонкой настройки интенсивности контуров. Основная непрозрачность остаётся рекомендуемым параметром.",
        P022 = "Показывает слоты неактивной панели на заднем плане в dual-режиме. Касается только режима D4.",
        P023 = "Показывает подписи и горячие клавиши на слотах панели действий при клавиатурном интерфейсе.",
        P024 = "Показывает или скрывает слой тени орбов D4.",
        P025 = "Показывает или скрывает цветной фоновый слой внутри орбов D4.",
        P026 = "Показывает или скрывает светящийся слой glow орбов D4.",
        P027 = "Показывает или скрывает слой заполнения Smoke орбов D4.",
        P028 = "Показывает или скрывает контурную накладку орбов D4.",
        P029 = "Показывает или скрывает основной контур орбов D4.",
        P030 = "Показывает или скрывает фон панели, обрамление и опоры панели действий DiabloOrbs.",
        P031 = "Показывает или скрывает слот ульты компаньона, не трогая остальную панель.",
        P032 = "Показывает или скрывает слоты навыков, которыми управляет DiabloOrbs. Удобно оставить только фон или наоборот.",
        P033 = "Показывает простую линию между магией и выносливостью.",
        P034 = "Показывает вторую панель на заднем плане с dual-текстурой. Выключите, чтобы была только одна панель. (Только тема D4)",
        P035 = "Показать фон шкалы ульты",
        P036 = "Показать индикатор смены оружия",
        P037 = "Показать тень",
        P038 = "Показать ульту компаньона",
        P039 = "Показать центральную шкалу ульты DiabloOrbs",
        P040 = "Показать накладку",
        P041 = "Показать контур",
        P042 = "Показать цветной фон",
        P043 = "Показать фон/опору панели DiabloOrbs",
        P044 = "Показать glow",
        P045 = "Показать smoke",
        P046 = "Показать разделитель",
        P047 = "Показать рамки слотов D4",
        P048 = "Показать привязки слотов",
        P049 = "Показать слоты навыков DiabloOrbs",
        P050 = "Показать расширенные настройки контуров solo/dual",
        P051 = "Показать значение щита (D4)",
        P052 = "Показать значение щита (Legacy)",
        P053 = "Добавляет дымку Smoke, окрашенную цветами орбов, чтобы кнопки сливались с темой.",
        P054 = "Добавляет цветной слой за заполнением основных орбов.",
        P055 = "Настраивает выравнивание заполнения внутри орбов.",
        P056 = "Настраивает расстояние между пятью центральными слотами в Legacy dual.",
        P057 = "Настраивает расстояние между пятью центральными слотами в Legacy solo.",
        P058 = "Настраивает расстояние между пятью центральными слотами в теме D4.",
        P059 = "Настраивает горизонтальный зазор орбов здоровья/комбинированного вокруг центра на слое 1.",
        P060 = "Настраивает зеркальный зазор орбов аддитивного слоя (магия/выносливость).",
        P061 = "Настраивает эффект обесцвечивания неактивной второй панели в режиме двух панелей.",
        P062 = "Настраивает вертикальную толщину шкалы ульты в dual-режиме.",
        P063 = "Настраивает вертикальную толщину шкалы ульты в solo-режиме.",
        P064 = "Настраивает визуальную толщину кольца щита в орбе здоровья (тема D4).",
        P065 = "Настраивает визуальную толщину кольца щита в орбе здоровья (тема Legacy).",
        P066 = "Настраивает непрозрачность отображения щита для темы D4.",
        P067 = "Настраивает порядок отрисовки щита D4. Выше — рисуется поверх остального.",
        P068 = "Настраивает высоту цветного фонового слоя орбов D4.",
        P069 = "Настраивает высоту фона панели D4, когда вторая панель включена.",
        P070 = "Настраивает высоту фона панели D4, когда вторая панель выключена.",
        P071 = "Настраивает высоту фона шкалы ульты в dual-режиме.",
        P072 = "Настраивает высоту фона шкалы ульты в solo-режиме.",
        P073 = "Настраивает ширину цветного фонового слоя орбов D4.",
        P074 = "Настраивает ширину шкалы ульты в dual-режиме.",
        P075 = "Настраивает ширину шкалы ульты в solo-режиме.",
        P076 = "Настраивает ширину фона панели D4, когда вторая панель включена.",
        P077 = "Настраивает ширину фона панели D4, когда вторая панель выключена.",
        P078 = "Настраивает ширину фона шкалы ульты в dual-режиме.",
        P079 = "Настраивает ширину фона шкалы ульты в solo-режиме.",
        P080 = "Настраивает яркость D4OrbFill.dds, используемой здесь как нейтральная основа орба.",
        P081 = "Настраивает яркость панели D4 только с двумя базовыми текстурами. 100 = как в источнике, ниже — темнее, выше — светлее.",
        P082 = "Настраивает яркость линии-разделителя.",
        P083 = "Настраивает общую яркость заполнения орбов. 100% = норма.",
        P084 = "Настраивает размер слоя тени орбов D4.",
        P085 = "Настраивает размер слоя glow орбов D4.",
        P086 = "Настраивает размер слоя заполнения Smoke орбов D4.",
        P087 = "Настраивает размер контурной накладки орбов D4.",
        P088 = "Настраивает размер основного контура орбов D4.",
        P089 = "Настраивает размер текста привязок навыков.",
        P090 = "Настраивает общий размер орбов D4 и их слоёв с расширенным диапазоном.",
        P091 = "Настраивает фактический размер фона панели D4. 100 = размер источника, выше — увеличивает всю панель, ниже — уменьшает.",
        P092 = "Настраивает прозрачность текста привязок навыков.",
        P093 = "Настраивает клавиши и иконки внутри панели D4. Содержимое теперь автоматически следует размеру фона; этот параметр подстраивает результат.",
        P094 = "Оповещения",
        P095 = "Внешний вид",
        P096 = "Накладывает цветной оттенок на рамки орбов, подставки, контурную накладку, фон панели действий и фон шкалы ульты в теме D4.",
        P097 = "Применить к запасу сил",
        P098 = "Затемнение контура слота компаньона (%)",
        P099 = "Затемняет все контуры кнопок навыков D4.",
        P100 = "Затемняет только контур слота компаньона, не меняя остальные контуры D4.",
        P101 = "Приглушает шкалу ультимейта, не затрагивая текст поверх неё.",
        P102 = "Задняя панель (неактивная панель D4)",
        P103 = "Панель действий — общие",
        P104 = "Панель действий — D4",
        P105 = "Основа",
        P106 = "Рамки и контуры",
        P107 = "Щит",
        P108 = "Щит D4: смещение по горизонтали (px)",
        P109 = "Щит D4: смещение по вертикали (px)",
        P110 = "Щит Legacy: смещение по горизонтали (px)",
        P111 = "Щит Legacy: смещение по вертикали (px)",
        P112 = "Орнаментальная рамка: размер (px)",
        P113 = "Эти настройки перемещают или меняют размер всех орбов и подставок.",
        P114 = "Цвет фонового слоя, добавляемого к орбам.",
        P115 = "Цвет текста на шкале ультимейта.",
        P116 = "Цвет линии между магикой и выносливостью.",
        P117 = "Шрифт для чисел на орбах и текста ультимейта. Свои шрифты — из DiabloOrbs/Fonts (иначе шрифт ESO).",
        P118 = "Положение текста горячих клавиш навыков: сверху, снизу или внутри слотов.",
        P119 = "Тема текстур (Legacy или D4). Для применения выполняется ReloadUI.",
        P120 = "Вариант DDS посветлее или потемнее для подставок под орбами.",
        P121 = "Цвет затенения за текстом в центре орбов.",
        P122 = "Общие",
        P123 = "Передать панель действий аддону DiabloOrbs",
        P124 = "Контраст контуров кнопок D4 (%)",
        P125 = "Общая прозрачность орбов и их подставок.",
        P126 = "Слой 1: цветной фон",
        P127 = "Слой 1: расстояние между орбами (px)",
        P128 = "Слой 1: высота (%)",
        P129 = "Слой 1: ширина (%)",
        P130 = "Слой 1: яркость (%)",
        P131 = "Слой 1: смещение X (px)",
        P132 = "Слой 1: смещение Y (px)",
        P133 = "Слой 1: глобальное смещение X (px)",
        P134 = "Слой 1: непрозрачность (%)",
        P135 = "Слой 2: цветной smoke",
        P136 = "Слой 2: цвет щита D4",
        P137 = "Слой 2: цвет выносливости D4",
        P138 = "Слой 2: цвет магики D4",
        P139 = "Слой 2: цвет здоровья D4",
        P140 = "Слой 2: отступ от центра (px)",
        P141 = "Слой 2: смещение Y (px)",
        P142 = "Слой 2: глобальное смещение X (px)",
        P143 = "Слой 2: непрозрачность (%)",
        P144 = "Слой 2: размер (%)",
        P145 = "Слой 3: аддитивный свет",
        P146 = "Слой 3: расстояние между орбами (px)",
        P147 = "Слой 3: интенсивность (%)",
        P148 = "Слой 3: смещение X (px)",
        P149 = "Слой 4: glow",
        P150 = "Слой 4: яркость (%)",
        P151 = "Слой 4: смещение X (px)",
        P152 = "Слой 4: смещение Y (px)",
        P153 = "Слой 4: непрозрачность (%)",
        P154 = "Слой 4: размер (%)",
        P155 = "Слой 4: оттенок цвета орба (%)",
        P156 = "Слой 5: тень",
        P157 = "Слой 5: расстояние между орбами (px)",
        P158 = "Слой 5: смещение X (px)",
        P159 = "Слой 5: смещение Y (px)",
        P160 = "Слой 5: непрозрачность (%)",
        P161 = "Слой 5: размер (%)",
        P162 = "Слой 6: основной контур",
        P163 = "Слой 6: расстояние между орбами (px)",
        P164 = "Слой 6: смещение X (px)",
        P165 = "Слой 6: смещение Y (px)",
        P166 = "Слой 6: непрозрачность (%)",
        P167 = "Слой 6: размер (%)",
        P168 = "Слой 7: разделительная линия",
        P169 = "Слой 7: цвет",
        P170 = "Слой 7: высота (% от орба)",
        P171 = "Слой 7: ширина (px)",
        P172 = "Слой 7: яркость (%)",
        P173 = "Слой 7: аддитивный режим",
        P174 = "Слой 7: смещение X (px)",
        P175 = "Слой 7: смещение Y (px)",
        P176 = "Слой 7: непрозрачность (%)",
        P177 = "Слой 7: размер (% от орба)",
        P178 = "Слой 8: наложение контура",
        P179 = "Слой 8: контраст (%)",
        P180 = "Слой 8: расстояние между орбами (px)",
        P181 = "Слой 8: яркость (%)",
        P182 = "Слой 8: смещение X (px)",
        P183 = "Слой 8: смещение Y (px)",
        P184 = "Слой 8: непрозрачность (%)",
        P185 = "Слой 8: размер (%)",
        P186 = "Цвет щита (Legacy)",
        P187 = "Цвет выносливости (Legacy)",
        P188 = "Цвет магики (Legacy)",
        P189 = "Цвет здоровья (Legacy)",
        P190 = "Цвет элементов D4 (рамка, подставки, наложение, панель, шкала).",
        P191 = "Цвет слоя оттенка",
        P192 = "Цвет заливки орба выносливости (тема Legacy).",
        P193 = "Цвет заливки орба магики (тема Legacy).",
        P194 = "Цвет заливки орба здоровья (тема Legacy).",
        P195 = "Цвет оттенка D4",
        P196 = "Цвет щита (тема Legacy).",
        P197 = "Цвет фона шкалы",
        P198 = "Цвет glow предупреждения о низкой выносливости на орбе.",
        P199 = "Цвет glow предупреждения о низкой магии на орбе.",
        P200 = "Цвет glow предупреждения о низком здоровье на орбе.",
        P201 = "Цвет заливки Smoke для орба выносливости D4.",
        P202 = "Цвет заливки Smoke для орба магии D4.",
        P203 = "Цвет заливки Smoke для орба здоровья D4.",
        P204 = "Цвет заливки Smoke для щита D4.",
        P205 = "Цвет свечения предупреждения выносливости (RGB)",
        P206 = "Цвет свечения предупреждения магии (RGB)",
        P207 = "Цвет свечения предупреждения здоровья (RGB)",
        P208 = "Цвет тени внутреннего текста",
        P209 = "Цвет текста ультимейта",
        P210 = "Цвета",
        P211 = "D4: горизонтальный интервал 5 слотов (px)",
        P212 = "Смещение заливки — орб здоровья (px)",
        P213 = "Смещение заливки — комбинированный орб (px)",
        P214 = "Вертикальное смещение (px)",
        P215 = "Сдвигает текст горячих клавиш на слотах по горизонтали.",
        P216 = "Сдвигает ультимейт по горизонтали относительно слота 5.",
        P217 = "Сдвигает ультимейт по горизонтали.",
        P218 = "Сдвигает ультимейт по вертикали относительно других слотов.",
        P219 = "Сдвигает ультимейт по вертикали.",
        P220 = "Сдвигает заднюю панель Legacy влево или вправо.",
        P221 = "Сдвигает заднюю панель Legacy вверх (отриц.) или вниз.",
        P222 = "Сдвигает заднюю панель влево или вправо относительно активной полосы.",
        P223 = "Сдвигает заднюю панель вверх (отриц.) или вниз относительно активной. По умолчанию -28, чтобы было видно ~20% слотов.",
        P224 = "Сдвигает весь слой 1 влево/вправо без изменения расстояния между орбами.",
        P225 = "Сдвигает слой Smoke вверх или вниз.",
        P226 = "Сдвигает слой тени влево или вправо.",
        P227 = "Сдвигает слой тени вверх или вниз.",
        P228 = "Сдвигает цветной фоновый слой вверх или вниз.",
        P229 = "Сдвигает слой свечения влево или вправо.",
        P230 = "Сдвигает слой свечения вверх или вниз.",
        P231 = "Сдвигает заливку (smoke) внутри орбов: здоровье влево, комбинированный вправо на ту же величину.",
        P232 = "Сдвигает оверлей контура влево или вправо.",
        P233 = "Сдвигает оверлей контура вверх или вниз.",
        P234 = "Сдвигает основной контур влево или вправо.",
        P235 = "Сдвигает основной контур вверх или вниз.",
        P236 = "Сдвигает слот горячей клавиши в Legacy dual.",
        P237 = "Сдвигает слот горячей клавиши в Legacy solo.",
        P238 = "Сдвигает слот ультимейта в Legacy dual.",
        P239 = "Сдвигает слот ультимейта в Legacy solo.",
        P240 = "Сдвигает разделительную линию влево или вправо.",
        P241 = "Сдвигает разделительную линию вверх или вниз.",
        P242 = "Сдвигает только заливку (smoke) внутри комбинированного орба магии/выносливости по оси X.",
        P243 = "Сдвигает только заливку (smoke) внутри орба здоровья по оси X.",
        P244 = "Сдвигает текст горячих клавиш на слотах по вертикали.",
        P245 = "Смещает значение левого орба (здоровье) по горизонтали вокруг центра.",
        P246 = "Независимо сдвигает текст щита в D4.",
        P247 = "Независимо сдвигает текст щита в Legacy.",
        P248 = "Сдвигает предмет quickslot влево/вправо на полосе D4. Удобно для выравнивания после смены размера.",
        P249 = "Сдвигает предмет quickslot вверх/вниз независимо от фона полосы.",
        P250 = "Сдвигает слот ультимейта влево/вправо на полосе D4 (отриц. = влево). Удобно для выравнивания.",
        P251 = "Сдвигает слот ультимейта вверх/вниз независимо от фона полосы.",
        P252 = "Сдвигает все 3 экземпляра фонового слоя (здоровье + magicka + stamina) в одном направлении.",
        P253 = "Сдвигает все 3 экземпляра слоя заливки (здоровье + magicka + stamina) в одном направлении.",
        P254 = "Сдвигает 5 центральных слотов в режиме dual.",
        P255 = "Сдвигает 5 центральных слотов в режиме solo.",
        P256 = "Сдвигает орбы вверх или вниз в режиме dual.",
        P257 = "Сдвигает орбы вверх или вниз в режиме solo.",
        P258 = "Сдвигает оба свечения D4 по вертикали сразу, сохраняя зеркало слева/справа.",
        P259 = "Сдвигает оба свечения по вертикали сразу, сохраняя зеркало слева/справа.",
        P260 = "Обесцвечивание (%)",
        P261 = "Обесцвечивание неактивной полосы, 2 полосы (%)",
        P262 = "Обесцвечивает иконки задней панели, чтобы отличать от активной полосы.",
        P263 = "Обесцвечивает иконки, чтобы отличать от активной полосы.",
        P264 = "Расстояние орбов от центра экрана в режиме solo.",
        P265 = "Расстояние орбов от центра в режиме dual (вторая полоса включена).",
        P266 = "Интервал свечений D4 от центра (px)",
        P267 = "Интервал свечений от центра (px)",
        P268 = "Интервал между слотами способностей задней панели.",
        P269 = "Интервал между каждым слотом.",
        P270 = "Горизонтальный интервал 5 слотов (px)",
        P271 = "Отступ горячей клавиши от края (px)",
        P272 = "Симметричный интервал заливки (px)",
        P273 = "Интервал ультимейта (px)",
        P274 = "Отступ ультимейта от края (px)",
        P275 = "Разводит слой тени: здоровье влево, magicka/stamina вправо.",
        P276 = "Разводит оверлей: здоровье влево, magicka/stamina вправо.",
        P277 = "Разводит слой контура: здоровье влево, magicka/stamina вправо.",
        P278 = "Разводит орбы относительно полосы в режиме dual.",
        P279 = "Разводит орбы относительно полосы в режиме solo.",
        P280 = "Разводит или подтягивает значения magicka/stamina от центра разделенного орба.",
        P281 = "Смещение от центра — Dual (px)",
        P282 = "Смещение от центра — Solo (px)",
        P283 = "Горизонтальный интервал (px)",
        P284 = "Масштаб (%)",
        P285 = "Масштаб содержимого полосы D4 (%)",
        P286 = "Светлее — светлый текст с темной тенью. Темнее — темный текст со светлой тенью.",
        P287 = "Отодвигает или приближает свечения magicka и stamina D4 к центру.",
        P288 = "Отодвигает или приближает свечения magicka и stamina к центру. Больше значение — больше интервал.",
        P289 = "В Legacy у каждой половины (magicka/stamina) свое состояние предупреждения.",
        P290 = "Дополнительный зазор между слотом 5 и ультимейтом.",
        P291 = "Интервал слотов (px)",
        P292 = "Снаружи: горизонтальные отступы (px)",
        P293 = "Снаружи: вертикальные отступы (px)",
        P294 = "Снаружи — классическое положение. Внутри — текст по центру орбов.",
        P295 = "Фон",
        P296 = "Фон полосы D4",
        P297 = "Фон dual (DiabloOrbsDualBarXp)",
        P298 = "Фон solo (ActionBarXp)",
        P299 = "Включает минимальную внутреннюю тень для проверки вложенности слоев.",
        P300 = "Предупреждение раздельного комбинированного орба.",
        P301 = "Общие",
        P302 = "Свечение: размер (px)",
        P303 = "Строгое внутреннее свечение D4 (без выхода за границы)",
        P304 = "Оформление кнопок панели действий в теме D4: рамки, smoke, спутник.",
        P305 = "Высота разделительной линии в процентах от размера сферы.",
        P306 = "Высота фона D4 со вторичной полосой (%)",
        P307 = "Высота фона D4 без вторичной полосы (%)",
        P308 = "Высота фона шкалы dual (px)",
        P309 = "Высота фона шкалы solo (px)",
        P310 = "Высота шкалы ultimate dual (px)",
        P311 = "Высота шкалы ultimate solo (px)",
        P312 = "Информация и значения",
        P313 = "Дополнительная интенсивность контуров D4 dual (%)",
        P314 = "Дополнительная интенсивность контуров D4 solo (%)",
        P315 = "Интенсивность аддитивного оверлея D4OrbBack2.",
        P316 = "Интенсивность оттенка (%)",
        P317 = "Интенсивность постоянного блика вне предупреждения о ресурсе.",
        P318 = "Макс. интенсивность свечения предупреждения D4 (%)",
        P319 = "Максимальная яркость ореола вокруг сфер D4 при предупреждении о ресурсе.",
        P320 = "Интенсивность smoke кнопок D4 (%)",
        P321 = "Внутри: зазор зеркала magicka/stamina (px)",
        P322 = "Внутри: горизонтальное смещение левой сферы (px)",
        P323 = "Меняет местами горизонтальное расположение magicka и stamina во внутреннем режиме. Отдельно для темы (D4 / Legacy).",
        P324 = "Поменять magicka/stamina местами (внутри)",
        P325 = "Шкала",
        P326 = "Шкала ultimate",
        P327 = "Шрифт общий; размер текста сфер и шкалы ultimate настраивается отдельно.",
        P328 = "Подпись - D4",
        P329 = "Подпись - Legacy",
        P330 = "Язык интерфейса",
        P331 = "Ширина разделительной линии в пикселях.",
        P332 = "Ширина фона D4 со вторичной полосой (%)",
        P333 = "Ширина фона D4 без вторичной полосы (%)",
        P334 = "Ширина фона шкалы dual (%)",
        P335 = "Ширина фона шкалы solo (%)",
        P336 = "Ширина шкалы ultimate dual (%)",
        P337 = "Ширина шкалы ultimate solo (%)",
        P338 = "Фон соответствует активной теме (D4: fond_jauge.dds, Legacy: UltimateGaugeBackground.dds). Ползунки ниже задают размер/смещение/непрозрачность.",
        P339 = "Текст ultimate не зависит от пульса шкалы и всегда читаем.",
        P340 = "Legacy - фон и задняя панель",
        P341 = "Яркость полосы D4 (%)",
        P342 = "Яркость подставок (пресет)",
        P343 = "Яркость фона (%)",
        P344 = "Общая яркость (%)",
        P345 = "Общая яркость фона (%)",
        P346 = "Режим двух полос: настройки для вторичной полосы при обнаружении dual.",
        P347 = "Поднять или опустить текст щита в D4 независимо.",
        P348 = "Поднять или опустить текст щита в Legacy независимо.",
        P349 = "Поднять или опустить полосу в режиме dual (вторичная полоса вкл.).",
        P350 = "Поднять или опустить полосу в режиме solo (вторичная полоса выкл.).",
        P351 = "Поднять или опустить шкалу ultimate в режиме dual.",
        P352 = "Поднять или опустить шкалу ultimate в режиме solo.",
        P353 = "Поднять или опустить фон шкалы в режиме dual.",
        P354 = "Поднять или опустить фон шкалы в режиме solo.",
        P355 = "Поднять или опустить текст значений сфер.",
        P356 = "Поднять или опустить сферы и подставки в режиме dual (вторичная полоса вкл.).",
        P357 = "Поднять или опустить сферы и подставки в режиме solo (вторичная полоса выкл.).",
        P358 = "Уровень слоя щита D4",
        P359 = "Темнота контуров кнопок D4 (%)",
        P360 = "Смещение X горячих клавиш (px)",
        P361 = "Смещение X ultimate (px)",
        P362 = "Смещение Y горячих клавиш (px)",
        P363 = "Смещение Y ultimate (px)",
        P364 = "Горизонтальное смещение (px)",
        P365 = "Смещение слота горячей клавиши D4 (px)",
        P366 = "Смещение слота ultimate D4 (px)",
        P367 = "Вертикальное смещение (px)",
        P368 = "Вертикальное смещение 5 слотов - dual (px)",
        P369 = "Вертикальное смещение 5 слотов - solo (px)",
        P370 = "Вертикальное смещение полосы - Dual (px)",
        P371 = "Вертикальное смещение полосы - Solo (px)",
        P372 = "Вертикальное смещение фона шкалы dual (px)",
        P373 = "Вертикальное смещение фона шкалы solo (px)",
        P374 = "Вертикальное смещение свечения D4 (px)",
        P375 = "Вертикальное смещение зеркального свечения (px)",
        P376 = "Вертикальное смещение шкалы ultimate dual (px)",
        P377 = "Вертикальное смещение шкалы ultimate solo (px)",
        P378 = "Вертикальное смещение слота горячей клавиши D4 (px)",
        P379 = "Вертикальное смещение слота ultimate D4 (px)",
        P380 = "Вертикальное смещение текста значений (px)",
        P381 = "Внутренняя тень: размер (px)",
        P382 = "Минимальная тень D4 (%)",
        P383 = "Непрозрачность (%)",
        P384 = "Непрозрачность неактивной полосы при двух полосах (%)",
        P385 = "Непрозрачность рамки подсказки значений (%)",
        P386 = "Непрозрачность контуров кнопок D4 (%)",
        P387 = "Непрозрачность слоя оттенка (%)",
        P388 = "Непрозрачность горячих клавиш (%)",
        P389 = "Непрозрачность щита D4 (%)",
        P390 = "Непрозрачность щита Legacy (%)",
        P391 = "Непрозрачность свечения при низком ресурсе.",
        P392 = "Непрозрачность контрастного фона внутри (%)",
        P393 = "Непрозрачность фона шкалы (%)",
        P394 = "Общая непрозрачность сфер и подставок (%)",
        P395 = "Непрозрачность свечения предупреждения (%)",
        P396 = "Непрозрачность тени текста внутри (%)",
        P397 = "Непрозрачность заливки шкалы (%)",
        P398 = "Непрозрачность текста ultimate (%)",
        P399 = "Непрозрачность текста значений (%)",
        P400 = "Общие настройки панели действий DiabloOrbs. Параметры solo/dual задают поведение в зависимости от режима.",
        P401 = "Сферы D4",
        P402 = "Сферы Legacy",
        P403 = "Структура: общий шрифт, затем отдельные настройки для чисел на сферах и текста шкалы ultimate.",
        P404 = "Шрифт чисел (общий для всех тем)",
        P405 = "Положение горячих клавиш",
        P406 = "Положение значений",
        P407 = "Положение и размер",
        P408 = "Положение и размер — общие настройки",
        P409 = "Положение сфер — Dual",
        P410 = "Положение сфер — Solo",
        P411 = "Вертикальное положение сфер — Dual (px)",
        P412 = "Вертикальное положение сфер — Solo (px)",
        P413 = "Горячие клавиши",
        P414 = "Горячие клавиши только в бою",
        P415 = "Равномерно масштабирует все слои сфер Legacy вместе.",
        P416 = "Отражение D4 в покое (%)",
        P417 = "Дополнительно: интенсивность Dual умножается на основную непрозрачность.",
        P418 = "Дополнительно: интенсивность Solo умножается на основную непрозрачность.",
        P419 = "Основная непрозрачность контуров кнопок D4 (горячая клавиша, 5 слотов, ultimate, спутник).",
        P420 = "Общие настройки DiabloOrbs.",
        P421 = "Настройки по теме (D4 или Legacy) с отдельными значениями для solo/dual.",
        P422 = "Задает боковой отступ внешних значений от краев сферы.",
        P423 = "Непрозрачность неактивной второй полосы при схеме из двух полос.",
        P424 = "Непрозрачность декоративной рамки вокруг текста значений.",
        P425 = "Непрозрачность слоя тени сфер D4.",
        P426 = "Непрозрачность дополнительного цветного слоя за сферами.",
        P427 = "Непрозрачность цветного фонового слоя сфер D4.",
        P428 = "Непрозрачность слоя glow сфер D4.",
        P429 = "Непрозрачность слоя заливки Smoke сфер D4.",
        P430 = "Непрозрачность наложения контура сфер D4.",
        P431 = "Непрозрачность настоящей тени текста за значениями внутри сферы.",
        P432 = "Непрозрачность основного контура сфер D4.",
        P433 = "Непрозрачность контрастного фона за значениями внутри сферы.",
        P434 = "Непрозрачность текста шкалы ultimate без изменения пульса полосы.",
        P435 = "Непрозрачность текста значений независимо от расположения.",
        P436 = "Непрозрачность разделительной линии magicka/stamina.",
        P437 = "Общая яркость цветного фона Smoke.dds для сфер D4.",
        P438 = "Вертикальное положение внешних значений.",
        P439 = "Размер шрифта текста на шкале ultimate.",
        P440 = "Прозрачность фона шкалы без изменения текста.",
        P441 = "Сбрасывает все настройки D4 к калиброванным значениям по умолчанию. Legacy не затрагивается.",
        P442 = "Сбрасывает все настройки Legacy к умолчаниям. D4 не затрагивается.",
        P443 = "Заливка — тонкое смещение",
        P444 = "Усиливает контраст контура (100 = норма, >100 = сильнее).",
        P445 = "Усиливает или смягчает цвет фона Smoke.dds для всех ресурсов D4.",
        P446 = "Сброс D4 (позиции по умолчанию)",
        P447 = "Сброс Legacy (позиции по умолчанию)",
        P448 = "Центральный разделитель: размер (px)",
        P449 = "Если включено, горячие клавиши умений видны только в бою.",
        P450 = "Слоты — Dual",
        P451 = "Слоты — Solo",
        P452 = "Стиль внутреннего текста",
        P453 = "Накладывает D4OrbBack2 аддитивно, чтобы осветлить сферу без перекраски основания.",
        P454 = "Размер каждой иконки backbar в пикселях.",
        P455 = "Размер каждой иконки в пикселях.",
        P456 = "Размер внутреннего слоя тени сфер Legacy (Shade.dds). 150 — по умолчанию.",
        P457 = "Размер сфер (px)",
        P458 = "Размер горячих клавиш (%)",
        P459 = "Размер слотов backbar. 80 — меньше активной полосы для глубины.",
        P460 = "Размер круглой рамки Legacy. 166 — XML по умолчанию. Уменьшите при крупных сферах, чтобы не наезжали.",
        P461 = "Размер круга щита D4 (%)",
        P462 = "Размер круга щита Legacy (%)",
        P463 = "Размер glow предупреждения о низком ресурсе относительно обычного glow. 100 — как обычно.",
        P464 = "Размер glow сфер Legacy. 150 — по умолчанию.",
        P465 = "Размер разделителя между magicka и stamina (Split.dds). 166 — по умолчанию.",
        P466 = "Размер фона полосы D4 (%)",
        P467 = "Общий размер backbar Legacy.",
        P468 = "Общий размер сфер (%)",
        P469 = "Общий размер разделителя в процентах от размера сферы.",
        P470 = "Размер glow предупреждения (%)",
        P471 = "Размер шрифта текста ultimate",
        P472 = "Размер слотов (px)",
        P473 = "Размер слотов backbar (px)",
        P474 = "Оттенок фона шкалы.",
        P475 = "Глобальный оттенок D4",
        P476 = "Текст",
        P477 = "Текст и значения",
        P478 = "Визуальная тема",
        P479 = "Сдвигает обе сферы аддитивного слоя влево/вправо вместе.",
        P480 = "Прозрачность backbar. 0 — невидимо, 100 — непрозрачно.",
        P481 = "Прозрачность иконок backbar Legacy.",
        P482 = "Общая типографика",
        P483 = "Положительное — magicka/stamina расходятся от центра (слой smoke), отрицательное — сходятся.",
        P484 = "Значения на сферах",
        P485 = "Визуал — D4",
        P486 = "Визуал — Legacy",
        P487 = "[Тема D4] Включить вторую полосу (режим Dual)",
        P488 = "[Тема Legacy] Включить вторую полосу (режим Dual)",
        P489 = "|cFFAA00[!] Для лучшего вида (solo и dual) включите в|r |cFFFFFFНастройки > Бой|r |cFFAA00:|r |cFFFFFF\"Задний ряд панели умений\"|r |cFFAA00и|r |cFFFFFF\"Таймеры панели умений\"|r|cFFAA00. (Все темы)|r",
        P490 = "Профили",
        P491 = "Управляйте профилями настроек. Профиль сохраняет все визуальные параметры. Профиль можно использовать на нескольких персонажах одного аккаунта.",
        P492 = "Активный профиль",
        P493 = "Выберите профиль для загрузки. Нажмите 'Загрузить выбранный профиль' для применения.",
        P494 = "Загрузить выбранный профиль",
        P495 = "Применяет настройки выбранного профиля к этому персонажу.",
        P496 = "Сохранить (перезаписать активный профиль)",
        P497 = "Перезаписывает активный профиль текущими настройками.",
        P498 = "Сохранить как... (новое имя)",
        P499 = "Создаёт новый профиль с введённым именем и текущими настройками.",
        P500 = "Создать этот новый профиль",
        P501 = "Создаёт или перезаписывает профиль с именем, введённым выше.",
        P502 = "Удалить выбранный профиль",
        P503 = "Удаляет выбранный профиль ('D4 default' и 'Legacy default' защищены).",
        P504 = "Украшения (Angel / Demon)",
        P505 = "Показать украшения (Angel / Demon)",
        P506 = "Передний план (перед сферами)",
        P507 = "Поменять стороны (Angel/Demon)",
        P508 = "Декоративная рамка: размер (px)",
        P509 = "Внутренняя тень: размер (px)",
        P510 = "Центральный разделитель: размер (px)",
        P511 = "Glow: размер (px)",
        P512 = "Базовый размер (px)",
        P513 = "Ширина (%)",
        P514 = "Высота (%)",
        P515 = "Отступ от центра (px)",
        P516 = "Вертикальное смещение (px)",
        P517 = "Размер декоративной рамки Legacy. Стандартное значение XML — 166. Уменьшите, чтобы избежать перекрытия при больших сферах. [ID: B93]",
        P518 = "Размер слоя внутренней тени Legacy (Shade.dds). Значение по умолчанию: 150. [ID: B94]",
        P519 = "Размер разделителя между Магией и Выносливостью (Split.dds). Значение по умолчанию: 166. [ID: B95]",
        P520 = "Размер свечения сфер Legacy. Значение по умолчанию: 150. [ID: B96]",
        P521 = "Показывает или скрывает декоративные изображения Angel и Demon по бокам сфер (только Legacy). [ID: LD10]",
        P522 = "Базовый размер изображений Angel и Demon. Ширина и высота задаются в процентах от этого значения. [ID: LD11]",
        P523 = "Горизонтальное расстояние между центром экрана и каждым изображением. 0 = центр. [ID: LD12]",
        P524 = "Перемещает украшения вверх (отрицательное) или вниз (положительное). [ID: LD13]",
        P525 = "Отображает украшения перед всеми элементами. Выключено = фон. [ID: LD14]",
        P526 = "Меняет позиции: Angel слева, Demon справа. [ID: LD15]",
        P527 = "Ширина в % от базового размера. [ID: LD16]",
        P528 = "Высота в % от базового размера. [ID: LD17]",
        P529 = "Этот профиль защищён и не может быть перезаписан.",
        P530 = "Этот профиль защищён и не может быть удалён.",
        P531 = "Пожалуйста, введите имя профиля.",
        P532 = "Это имя профиля защищено и не может быть использовано.",
    },
}

local SUPPORTED_LANGUAGE_CODES = { auto = true, en = true, fr = true, de = true, es = true, it = true, ru = true }

local function GetGameLanguageCode()
    if GetCVar == nil then
        return "en"
    end

    local cvarLang = GetCVar("language.2")
    if cvarLang == nil or cvarLang == "" then
        cvarLang = GetCVar("Language.2")
    end

    local lang = string.lower(tostring(cvarLang or "en"))
    if lang == "en" or lang == "fr" or lang == "de" or lang == "es" or lang == "it" or lang == "ru" then
        return lang
    end
    return "en"
end

local function ResolveLocaleCode()
    local mode = (SETTINGS and SETTINGS.LANGUAGE_MODE) or "auto"
    if mode == nil then
        mode = "auto"
    end

    mode = string.lower(tostring(mode))
    if mode == "auto" then
        return GetGameLanguageCode()
    end

    if SUPPORTED_LANGUAGE_CODES[mode] then
        return mode
    end
    return "en"
end

local function L(key)
    local lang = ResolveLocaleCode()
    if LOCALIZATION[lang] ~= nil and LOCALIZATION[lang][key] ~= nil then
        return LOCALIZATION[lang][key]
    end
    return (LOCALIZATION.en and LOCALIZATION.en[key]) or key
end

local function NormalizeLabelFormat(value)
    if value == "hidden" or value == "value" or value == "percent" or value == "full" then
        return value
    end

    local raw = string.lower(tostring(value or ""))

    local hiddenAliases = {
        ["masque"] = true,
        ["hidden"] = true,
        ["versteckt"] = true,
        ["oculto"] = true,
        ["nascosto"] = true,
        ["скрыто"] = true,
    }

    local valueAliases = {
        ["valeur (ex: 23k)"] = true,
        ["value (e.g. 23k)"] = true,
        ["wert (z.b. 23k)"] = true,
        ["valor (ej. 23k)"] = true,
        ["valore (es. 23k)"] = true,
        ["значение (напр. 23k)"] = true,
    }

    local fullAliases = {
        ["valeur complete (ex: 23456)"] = true,
        ["full value (e.g. 23456)"] = true,
        ["voller wert (z.b. 23456)"] = true,
        ["valor completo (ej. 23456)"] = true,
        ["valore completo (es. 23456)"] = true,
        ["полное значение (напр. 23456)"] = true,
    }

    local percentAliases = {
        ["pourcentage (ex: 75%)"] = true,
        ["percent (e.g. 75%)"] = true,
        ["prozent (z.b. 75%)"] = true,
        ["porcentaje (ej. 75%)"] = true,
        ["percentuale (es. 75%)"] = true,
        ["процент (напр. 75%)"] = true,
    }

    if hiddenAliases[raw] then
        return "hidden"
    end
    if valueAliases[raw] then
        return "value"
    end
    if fullAliases[raw] then
        return "full"
    end
    if percentAliases[raw] then
        return "percent"
    end

    return DEFAULT_SETTINGS.LABEL_FORMAT
end

local function FormatFullOrbValue(value)
    local rounded = zo_round(value or 0)
    if type(ZO_CommaDelimitNumber) == "function" then
        return ZO_CommaDelimitNumber(rounded)
    end
    return tostring(rounded)
end

local function NormalizeLabelPositionMode(value)
    local raw = string.lower(zo_strtrim(tostring(value or "")))
    if raw == "inside" or raw == "interior" or raw == "inside_orb" then
        return "inside"
    end
    return "outside"
end

local function NormalizeLabelInnerStyle(value)
    local raw = string.lower(zo_strtrim(tostring(value or "")))
    if raw == "light" or raw == "clair" or raw == "bright" then
        return "light"
    end
    if raw == "dark" or raw == "sombre" or raw == "dim" then
        return "dark"
    end
    return "none"
end

local LOCALIZED_LITERAL_KEYS = {
    ["Parametres de DiabloOrbs."] = "DESC",
    ["Jauge d'ultime"] = "SECTION_ULTIMATE",
    ["Afficher la jauge d'ultime"] = "SHOW_ULTIMATE_BAR_NAME",
    ["Affiche ou masque la jauge d'ultime au centre de la barre d'action."] = "SHOW_ULTIMATE_BAR_TIP",
    ["Afficher le texte actuel/cout sur la jauge"] = "SHOW_ULTIMATE_TEXT_NAME",
    ["Affiche le texte de progression d'ultime directement sur la jauge centrale."] = "SHOW_ULTIMATE_TEXT_TIP",
    ["Format du texte d'ultime"] = "ULTIMATE_TEXT_MODE_NAME",
    ["Choisit le format affiche sur la jauge ultime."] = "ULTIMATE_TEXT_MODE_TIP",
    ["Valeur (actuel/cout)"] = "ULTIMATE_TEXT_MODE_VALUE",
    ["Pourcentage"] = "ULTIMATE_TEXT_MODE_PERCENT",
    ["Couleur quand ultime est prete"] = "ULTIMATE_READY_COLOR_NAME",
    ["Couleur appliquee a la jauge centrale quand l'ultime est prete."] = "ULTIMATE_READY_COLOR_TIP",
    ["Vitesse pulse ultime"] = "ULTIMATE_PULSE_SPEED_NAME",
    ["Vitesse du clignotement quand l'ultime est prete."] = "ULTIMATE_PULSE_SPEED_TIP",
    ["Pulse alpha min (%)"] = "ULTIMATE_PULSE_MIN_NAME",
    ["Opacite minimale du pulse de la jauge ultime."] = "ULTIMATE_PULSE_MIN_TIP",
    ["Pulse alpha max (%)"] = "ULTIMATE_PULSE_MAX_NAME",
    ["Opacite maximale du pulse de la jauge ultime."] = "ULTIMATE_PULSE_MAX_TIP",
    ["Alertes ressources"] = "SECTION_ALERT",
    ["Seuil alerte ressources (%)"] = "LOW_RESOURCE_NAME",
    ["Declenche l'effet glow quand une ressource passe sous ce pourcentage."] = "LOW_RESOURCE_TIP",
    ["Intensite max du glow d'alerte (%)"] = "GLOW_MAX_NAME",
    ["Intensite maximale de l'aureole lumineuse autour des orbes lors d'une alerte ressource."] = "GLOW_MAX_TIP",
    ["Glow interne strict (sans debordement)"] = "GLOW_INTERNAL_NAME",
    ["Active un glow contenu a l'interieur des orbes. Desactive = glow plus dramatique qui depasse un peu."] = "GLOW_INTERNAL_TIP",
    ["Activer le pulse de couleur sur le cadre"] = "BORDER_PULSE_ENABLE_NAME",
    ["Quand la ressource est faible, le cadre ornemental pulse dans la couleur d'alerte choisie."] = "BORDER_PULSE_ENABLE_TIP",
    ["Couleur du pulse d'alerte"] = "BORDER_PULSE_COLOR_NAME",
    ["Couleur du cadre quand la ressource est faible. Defaut : rouge."] = "BORDER_PULSE_COLOR_TIP",
    ["Orbes - Style"] = "SECTION_ORB_STYLE",
    ["Transparence du smoke (%)"] = "SMOKE_ALPHA_NAME",
    ["Ajuste l'opacite des effets de fumee sur les orbes de ressources."] = "SMOKE_ALPHA_TIP",
    ["Luminosite du fond des orbes (%)"] = "SMOKEBG_BRIGHTNESS_NAME",
    ["0% = fond sombre. 100% = fond plus lumineux."] = "SMOKEBG_BRIGHTNESS_TIP",
    ["Intensite globale des couleurs (%)"] = "ORB_COLOR_BOOST_NAME",
    ["Boost global des couleurs des orbes. 100% = normal, au-dessus = plus vif."] = "ORB_COLOR_BOOST_TIP",
    ["Intensite du contour sombre (%)"] = "SHADE_ALPHA_NAME",
    ["0% = contour sombre invisible. 100% = contour sombre complet."] = "SHADE_ALPHA_TIP",
    ["Opacite du cadre circulaire (%)"] = "BORDER_ALPHA_NAME",
    ["Ajuste l'opacite du cadre ornemental des orbes."] = "BORDER_ALPHA_TIP",
    ["Opacite du separateur double barre (%)"] = "SPLIT_ALPHA_NAME",
    ["Ajuste l'opacite de la ligne de separation entre Magie et Endurance."] = "SPLIT_ALPHA_TIP",
    ["Opacite du bouclier (%)"] = "SHIELD_ALPHA_NAME",
    ["Ajuste l'opacite de l'effet visuel du bouclier magique."] = "SHIELD_ALPHA_TIP",
    ["Taille du cercle bouclier (%)"] = "SHIELD_RING_SCALE_NAME",
    ["Ajuste l'epaisseur visuelle du cercle de bouclier dans l'orbe de vie."] = "SHIELD_RING_SCALE_TIP",
    ["Reactivite visuelle du bouclier (%)"] = "SHIELD_VISUAL_RESPONSE_NAME",
    ["Rend le bouclier visuellement plus rapide (haut) ou plus progressif (bas). 100% = lineaire."] = "SHIELD_VISUAL_RESPONSE_TIP",
    ["Orbes - Couleurs"] = "SECTION_ORB_COLORS",
    ["Couleur Orbe Sante"] = "HEALTH_COLOR_NAME",
    ["Couleur Orbe Magie"] = "MAGICKA_COLOR_NAME",
    ["Couleur Orbe Endurance"] = "STAMINA_COLOR_NAME",
    ["Couleur Orbe Bouclier"] = "SHIELD_COLOR_NAME",
    ["Texte des valeurs"] = "SECTION_TEXT",
    ["Taille des valeurs (%)"] = "LABEL_SCALE_NAME",
    ["Regle la taille du texte des valeurs/pourcentages affiches sur les orbes."] = "LABEL_SCALE_TIP",
    ["Affichage des valeurs de ressources"] = "LABEL_FORMAT_NAME",
    ["Choisit comment afficher les valeurs numeriques sur les orbes."] = "LABEL_FORMAT_TIP",
    ["Masque"] = "LABEL_FORMAT_HIDDEN",
    ["Valeur (ex: 23k)"] = "LABEL_FORMAT_VALUE",
    ["Pourcentage (ex: 75%)"] = "LABEL_FORMAT_PERCENT",
    -- Panel strings (auto-generated)
    ["0 = glow blanc pur. 100 = glow teinte couleur de l'orbe."] = "P001",
    ["0 = mode normal (alpha). 100 = mode additif (plus de punch et luminosite sur fond sombre)."] = "P002",
    ["0 = pas de teinte (couleur originale), 100 = teinte pleine."] = "P003",
    ["100 = normal, jusqu'a 500 pour tres lumineux."] = "P004",
    ["100 = normal. Monter pour plus de luminosite, baisser pour assombrir."] = "P005",
    ["Active la gestion des slots/hotkeys/armes par DiabloOrbs. Si desactive, DiabloOrbs conserve les elements visuels (skins/fonds/jauge ultime) mais laisse la gestion des slots a un autre addon."] = "P006",
    ["Active le mode additif sur l'endurance de l'orbe combine D4 (sinon seule la magie est utilisee)."] = "P007",
    ["Active ou coupe completement le widget d'ultime central de DiabloOrbs, independamment des autres parties de la barre."] = "P008",
    ["Active ou coupe les bordures de slots ajoutees par DiabloOrbs en theme D4."] = "P009",
    ["Active un glow contenu a l'interieur des orbes D4. Desactive = glow plus dramatique qui depasse un peu."] = "P010",
    ["Active un glow d'alerte lorsqu'une ressource tombe sous le seuil."] = "P011",
    ["Active un rendu plus lumineux de la separation (utile sur fonds sombres)."] = "P012",
    ["Activer couche de fond teintee"] = "P013",
    ["Activer la lumiere additive"] = "P014",
    ["Activer le glow d'alerte pour seuil bas"] = "P015",
    ["Affiche la valeur numerique du bouclier en theme D4."] = "P016",
    ["Affiche la valeur numerique du bouclier en theme Legacy."] = "P017",
    ["Affiche le controle de changement d'arme sur la barre standard et la fleche sur la version dual quand disponible."] = "P018",
    ["Affiche le fond decoratif derriere la jauge d'ultime."] = "P019",
    ["Affiche les icones de la barre inactive en arriere-plan en mode Dual, avec le fond dual Legacy. (Theme Legacy uniquement)"] = "P020",
    ["Affiche les reglages separes solo/dual pour affiner l'intensite des contours. L'opacite principale reste le reglage recommande."] = "P021",
    ["Affiche les slots de la barre inactive en arriere-plan en mode dual. Seul le mode D4 est concerne."] = "P022",
    ["Affiche les textes/raccourcis clavier sur les slots de la barre d'action quand l'interface clavier est utilisee."] = "P023",
    ["Affiche ou masque la couche d'ombre des orbes D4."] = "P024",
    ["Affiche ou masque la couche de fond colore a l'interieur des orbes D4."] = "P025",
    ["Affiche ou masque la couche de glow lumineux des orbes D4."] = "P026",
    ["Affiche ou masque la couche de remplissage Smoke des orbes D4."] = "P027",
    ["Affiche ou masque la surcouche contour des orbes D4."] = "P028",
    ["Affiche ou masque le contour principal des orbes D4."] = "P029",
    ["Affiche ou masque le fond de barre, les habillages et les supports visuels de la barre d'action DiabloOrbs."] = "P030",
    ["Affiche ou masque le slot d'ultime du compagnon sans toucher au reste de la barre."] = "P031",
    ["Affiche ou masque les slots de competences geres par DiabloOrbs. Pratique pour ne garder que le fond, ou inversement."] = "P032",
    ["Affiche un trait simple entre mana et endurance."] = "P033",
    ["Affiche une deuxieme barre en arriere-plan avec la texture dual. Desactiver pour n'afficher qu'une seule barre. (Theme D4 uniquement)"] = "P034",
    ["Afficher fond de jauge ultime"] = "P035",
    ["Afficher l'indicateur de changement d'arme"] = "P036",
    ["Afficher l'ombre"] = "P037",
    ["Afficher l'ultime du compagnon"] = "P038",
    ["Afficher la jauge ultime centrale DiabloOrbs"] = "P039",
    ["Afficher la surcouche"] = "P040",
    ["Afficher le contour"] = "P041",
    ["Afficher le fond colore"] = "P042",
    ["Afficher le fond/support de barre DiabloOrbs"] = "P043",
    ["Afficher le glow"] = "P044",
    ["Afficher le smoke"] = "P045",
    ["Afficher le trait"] = "P046",
    ["Afficher les bordures de slots D4"] = "P047",
    ["Afficher les raccourcis des slots"] = "P048",
    ["Afficher les slots de competences DiabloOrbs"] = "P049",
    ["Afficher reglages avances solo/dual des contours"] = "P050",
    ["Afficher valeur bouclier (D4)"] = "P051",
    ["Afficher valeur bouclier (Legacy)"] = "P052",
    ["Ajoute un voile Smoke teinte par les couleurs d'orbes pour fondre les boutons dans le theme."] = "P053",
    ["Ajoute une couche de couleur derriere le remplissage des orbes principaux."] = "P054",
    ["Ajuste l'alignement du remplissage a l'interieur des orbes."] = "P055",
    ["Ajuste l'ecart des 5 slots centraux en Legacy dual."] = "P056",
    ["Ajuste l'ecart des 5 slots centraux en Legacy solo."] = "P057",
    ["Ajuste l'ecart des 5 slots centraux en theme D4."] = "P058",
    ["Ajuste l'ecartement horizontal des orbes vie/combinee autour du centre en couche 1."] = "P059",
    ["Ajuste l'ecartement miroir des orbes de la couche additive (magie/endurance)."] = "P060",
    ["Ajuste l'effet de desaturation sur la barre secondaire inactive en mode 2 barres."] = "P061",
    ["Ajuste l'epaisseur verticale de la jauge ultime en mode dual."] = "P062",
    ["Ajuste l'epaisseur verticale de la jauge ultime en mode solo."] = "P063",
    ["Ajuste l'epaisseur visuelle du cercle de bouclier dans l'orbe de vie (theme D4)."] = "P064",
    ["Ajuste l'epaisseur visuelle du cercle de bouclier dans l'orbe de vie (theme Legacy)."] = "P065",
    ["Ajuste l'opacite du visuel de bouclier pour le theme D4."] = "P066",
    ["Ajuste l'ordre de rendu du bouclier D4. Plus eleve = dessine plus au-dessus."] = "P067",
    ["Ajuste la hauteur de la couche de fond colore des orbes D4."] = "P068",
    ["Ajuste la hauteur du fond de barre D4 quand la barre secondaire est activee."] = "P069",
    ["Ajuste la hauteur du fond de barre D4 quand la barre secondaire est desactivee."] = "P070",
    ["Ajuste la hauteur du fond de jauge en mode dual."] = "P071",
    ["Ajuste la hauteur du fond de jauge en mode solo."] = "P072",
    ["Ajuste la largeur de la couche de fond colore des orbes D4."] = "P073",
    ["Ajuste la largeur de la jauge ultime en mode dual."] = "P074",
    ["Ajuste la largeur de la jauge ultime en mode solo."] = "P075",
    ["Ajuste la largeur du fond de barre D4 quand la barre secondaire est activee."] = "P076",
    ["Ajuste la largeur du fond de barre D4 quand la barre secondaire est desactivee."] = "P077",
    ["Ajuste la largeur du fond de jauge en mode dual."] = "P078",
    ["Ajuste la largeur du fond de jauge en mode solo."] = "P079",
    ["Ajuste la luminosite de D4OrbFill.dds, utilise ici comme base neutre de l'orbe."] = "P080",
    ["Ajuste la luminosite de la barre D4 avec les 2 textures de base uniquement. 100 = rendu source, en dessous assombrit, au-dessus eclaircit."] = "P081",
    ["Ajuste la luminosite du trait de separation."] = "P082",
    ["Ajuste la luminosite globale du remplissage des orbes. 100% = normal."] = "P083",
    ["Ajuste la taille de la couche d'ombre des orbes D4."] = "P084",
    ["Ajuste la taille de la couche de glow des orbes D4."] = "P085",
    ["Ajuste la taille de la couche de remplissage Smoke des orbes D4."] = "P086",
    ["Ajuste la taille de la surcouche contour des orbes D4."] = "P087",
    ["Ajuste la taille du contour principal des orbes D4."] = "P088",
    ["Ajuste la taille du texte des raccourcis des competences."] = "P089",
    ["Ajuste la taille globale des orbes D4 et de leurs couches, avec une plage etendue."] = "P090",
    ["Ajuste la taille reelle du fond de barre D4. 100 = taille source, plus haut agrandit la barre complete, plus bas la reduit."] = "P091",
    ["Ajuste la transparence du texte des raccourcis des competences."] = "P092",
    ["Ajuste les touches et icones a l'interieur de la barre D4. Le contenu suit maintenant automatiquement la taille du fond, puis ce reglage affine le resultat."] = "P093",
    ["Alertes"] = "P094",
    ["Apparence"] = "P095",
    ["Applique une teinte coloree sur le cadre des orbes, les socles, la surcouche contour, le fond de la barre d'action et le fond de la jauge ultime en theme D4."] = "P096",
    ["Appliquer sur l'endurance"] = "P097",
    ["Assombrissement contour slot compagnon (%)"] = "P098",
    ["Assombrit tous les contours de boutons de competences D4."] = "P099",
    ["Assombrit uniquement le contour du slot compagnon, sans modifier les autres contours D4."] = "P100",
    ["Attenue la jauge d'ultime sans impacter le texte affiche dessus."] = "P101",
    ["Backbar (barre inactive D4)"] = "P102",
    ["Barre d'action — Commun"] = "P103",
    ["Barre d'action — D4"] = "P104",
    ["Base"] = "P105",
    ["Bordures et contours"] = "P106",
    ["Bouclier"] = "P107",
    ["Bouclier D4 : offset horizontal (px)"] = "P108",
    ["Bouclier D4 : offset vertical (px)"] = "P109",
    ["Bouclier Legacy : offset horizontal (px)"] = "P110",
    ["Bouclier Legacy : offset vertical (px)"] = "P111",
    ["Cadre ornemental : taille (px)"] = "P112",
    ["Ces reglages deplacent ou redimensionnent l'ensemble des orbes et socles."] = "P113",
    ["Choisit la couleur de la couche de fond ajoutee aux orbes."] = "P114",
    ["Choisit la couleur du texte affiche sur la jauge ultime."] = "P115",
    ["Choisit la couleur du trait entre mana et endurance."] = "P116",
    ["Choisit la police utilisee pour les valeurs des orbes et le texte d'ultime. Les polices custom utilisent les fichiers dans DiabloOrbs/Fonts (sinon retour auto a la police ESO)."] = "P117",
    ["Choisit la position des textes de raccourcis des competences: au-dessus, en dessous, ou a l'interieur des cases."] = "P118",
    ["Choisit le theme des textures (Legacy ou D4). Un reloadui sera lance automatiquement pour appliquer le changement."] = "P119",
    ["Choisit une variante DDS plus ou moins eclaircie pour les socles sous les orbes."] = "P120",
    ["Choix de la couleur d'ombrage appliquee derriere le texte au centre des orbes."] = "P121",
    ["Commun"] = "P122",
    ["Confier la barre d'action a DiabloOrbs"] = "P123",
    ["Contraste contours boutons D4 (%)"] = "P124",
    ["Controle la transparence globale des orbes et de leurs socles."] = "P125",
    ["Couche 1 : Fond colore"] = "P126",
    ["Couche 1 : ecart entre les orbes (px)"] = "P127",
    ["Couche 1 : hauteur (%)"] = "P128",
    ["Couche 1 : largeur (%)"] = "P129",
    ["Couche 1 : luminosite (%)"] = "P130",
    ["Couche 1 : offset X (px)"] = "P131",
    ["Couche 1 : offset Y (px)"] = "P132",
    ["Couche 1 : offset global X (px)"] = "P133",
    ["Couche 1 : opacite (%)"] = "P134",
    ["Couche 2 : Smoke colore"] = "P135",
    ["Couche 2 : couleur Bouclier D4"] = "P136",
    ["Couche 2 : couleur Endurance D4"] = "P137",
    ["Couche 2 : couleur Magie D4"] = "P138",
    ["Couche 2 : couleur Sante D4"] = "P139",
    ["Couche 2 : ecart centre (px)"] = "P140",
    ["Couche 2 : offset Y (px)"] = "P141",
    ["Couche 2 : offset global X (px)"] = "P142",
    ["Couche 2 : opacite (%)"] = "P143",
    ["Couche 2 : taille (%)"] = "P144",
    ["Couche 3 : Lumiere additive"] = "P145",
    ["Couche 3 : ecart entre les orbes (px)"] = "P146",
    ["Couche 3 : intensite (%)"] = "P147",
    ["Couche 3 : offset X (px)"] = "P148",
    ["Couche 4 : Glow"] = "P149",
    ["Couche 4 : luminosite (%)"] = "P150",
    ["Couche 4 : offset X (px)"] = "P151",
    ["Couche 4 : offset Y (px)"] = "P152",
    ["Couche 4 : opacite (%)"] = "P153",
    ["Couche 4 : taille (%)"] = "P154",
    ["Couche 4 : teinte couleur de l'orbe (%)"] = "P155",
    ["Couche 5 : Ombre"] = "P156",
    ["Couche 5 : ecart entre les orbes (px)"] = "P157",
    ["Couche 5 : offset X (px)"] = "P158",
    ["Couche 5 : offset Y (px)"] = "P159",
    ["Couche 5 : opacite (%)"] = "P160",
    ["Couche 5 : taille (%)"] = "P161",
    ["Couche 6 : Contour principal"] = "P162",
    ["Couche 6 : ecart entre les orbes (px)"] = "P163",
    ["Couche 6 : offset X (px)"] = "P164",
    ["Couche 6 : offset Y (px)"] = "P165",
    ["Couche 6 : opacite (%)"] = "P166",
    ["Couche 6 : taille (%)"] = "P167",
    ["Couche 7 : Trait de separation"] = "P168",
    ["Couche 7 : couleur"] = "P169",
    ["Couche 7 : hauteur (% de l'orbe)"] = "P170",
    ["Couche 7 : largeur (px)"] = "P171",
    ["Couche 7 : luminosite (%)"] = "P172",
    ["Couche 7 : mode additif"] = "P173",
    ["Couche 7 : offset X (px)"] = "P174",
    ["Couche 7 : offset Y (px)"] = "P175",
    ["Couche 7 : opacite (%)"] = "P176",
    ["Couche 7 : taille (% de l'orbe)"] = "P177",
    ["Couche 8 : Surcouche contour"] = "P178",
    ["Couche 8 : contraste (%)"] = "P179",
    ["Couche 8 : ecart entre les orbes (px)"] = "P180",
    ["Couche 8 : luminosite (%)"] = "P181",
    ["Couche 8 : offset X (px)"] = "P182",
    ["Couche 8 : offset Y (px)"] = "P183",
    ["Couche 8 : opacite (%)"] = "P184",
    ["Couche 8 : taille (%)"] = "P185",
    ["Couleur Bouclier (Legacy)"] = "P186",
    ["Couleur Endurance (Legacy)"] = "P187",
    ["Couleur Magie (Legacy)"] = "P188",
    ["Couleur Sante (Legacy)"] = "P189",
    ["Couleur appliquee sur les elements D4 (cadre, socles, surcouche, barre, jauge)."] = "P190",
    ["Couleur couche teintee"] = "P191",
    ["Couleur de remplissage de l'orbe d'endurance en theme Legacy."] = "P192",
    ["Couleur de remplissage de l'orbe de magie en theme Legacy."] = "P193",
    ["Couleur de remplissage de l'orbe de sante en theme Legacy."] = "P194",
    ["Couleur de teinte D4"] = "P195",
    ["Couleur du bouclier en theme Legacy."] = "P196",
    ["Couleur du fond de jauge"] = "P197",
    ["Couleur du glow d'alerte basse ressource pour l'orbe d'endurance."] = "P198",
    ["Couleur du glow d'alerte basse ressource pour l'orbe de magie."] = "P199",
    ["Couleur du glow d'alerte basse ressource pour l'orbe de sante."] = "P200",
    ["Couleur du remplissage Smoke pour l'orbe d'endurance D4."] = "P201",
    ["Couleur du remplissage Smoke pour l'orbe de magie D4."] = "P202",
    ["Couleur du remplissage Smoke pour l'orbe de sante D4."] = "P203",
    ["Couleur du remplissage Smoke pour le bouclier D4."] = "P204",
    ["Couleur glow d'alerte Endurance (RGB)"] = "P205",
    ["Couleur glow d'alerte Magie (RGB)"] = "P206",
    ["Couleur glow d'alerte Sante (RGB)"] = "P207",
    ["Couleur ombrage texte interieur"] = "P208",
    ["Couleur texte ultime"] = "P209",
    ["Couleurs"] = "P210",
    ["D4 : ecart horizontal des 5 slots (px)"] = "P211",
    ["Decalage remplissage — Orbe Sante (px)"] = "P212",
    ["Decalage remplissage — Orbe combine (px)"] = "P213",
    ["Decalage vertical (px)"] = "P214",
    ["Decale horizontalement le texte des raccourcis sur les slots."] = "P215",
    ["Decale l'ultime horizontalement par rapport au slot 5."] = "P216",
    ["Decale l'ultime horizontalement."] = "P217",
    ["Decale l'ultime verticalement par rapport aux autres slots."] = "P218",
    ["Decale l'ultime verticalement."] = "P219",
    ["Decale la backbar Legacy vers la gauche ou la droite."] = "P220",
    ["Decale la backbar Legacy vers le haut (negatif) ou le bas."] = "P221",
    ["Decale la backbar vers la gauche ou la droite par rapport a la barre active."] = "P222",
    ["Decale la backbar vers le haut (negatif) ou le bas par rapport a la barre active. Par defaut -28 pour voir environ 20% des slots."] = "P223",
    ["Decale la couche 1 entiere a gauche/droite, sans toucher l'ecart des orbes."] = "P224",
    ["Decale la couche Smoke vers le haut ou le bas."] = "P225",
    ["Decale la couche d'ombre a gauche ou a droite."] = "P226",
    ["Decale la couche d'ombre vers le haut ou le bas."] = "P227",
    ["Decale la couche de fond colore vers le haut ou le bas."] = "P228",
    ["Decale la couche de glow a gauche ou a droite."] = "P229",
    ["Decale la couche de glow vers le haut ou le bas."] = "P230",
    ["Decale la couche de remplissage (smoke) a l'interieur des orbes : sante vers la gauche et combinee vers la droite du meme montant."] = "P231",
    ["Decale la surcouche contour a gauche ou a droite."] = "P232",
    ["Decale la surcouche contour vers le haut ou le bas."] = "P233",
    ["Decale le contour principal a gauche ou a droite."] = "P234",
    ["Decale le contour principal vers le haut ou le bas."] = "P235",
    ["Decale le slot raccourci en Legacy dual."] = "P236",
    ["Decale le slot raccourci en Legacy solo."] = "P237",
    ["Decale le slot ultime en Legacy dual."] = "P238",
    ["Decale le slot ultime en Legacy solo."] = "P239",
    ["Decale le trait de separation a gauche ou a droite."] = "P240",
    ["Decale le trait de separation vers le haut ou le bas."] = "P241",
    ["Decale uniquement la couche de remplissage (smoke) a l'interieur de l'orbe combinee mana/endurance sur l'axe X."] = "P242",
    ["Decale uniquement la couche de remplissage (smoke) a l'interieur de l'orbe de vie sur l'axe X."] = "P243",
    ["Decale verticalement le texte des raccourcis sur les slots."] = "P244",
    ["Deplace horizontalement la valeur de l'orbe gauche (sante) autour du centre."] = "P245",
    ["Deplace independamment le texte du bouclier en D4."] = "P246",
    ["Deplace independamment le texte du bouclier en Legacy."] = "P247",
    ["Deplace l'objet de raccourci (quickslot) a gauche ou droite dans la barre D4. Utile pour recaler l'alignement apres changement de taille."] = "P248",
    ["Deplace l'objet de raccourci (quickslot) vers le haut ou bas independamment du fond de barre."] = "P249",
    ["Deplace le slot ultime a gauche ou droite dans la barre D4 (negatif = vers la gauche). Utile pour recaler l'alignement apres changement de taille."] = "P250",
    ["Deplace le slot ultime vers le haut ou bas independamment du fond de barre."] = "P251",
    ["Deplace les 3 instances de la couche de fond (sante + mana + endu) dans la meme direction."] = "P252",
    ["Deplace les 3 instances de la couche de remplissage (sante + mana + endu) dans la meme direction."] = "P253",
    ["Deplace les 5 slots centraux en mode dual."] = "P254",
    ["Deplace les 5 slots centraux en mode solo."] = "P255",
    ["Deplace les orbes vers le haut ou le bas en mode dual."] = "P256",
    ["Deplace les orbes vers le haut ou le bas en mode solo."] = "P257",
    ["Deplace verticalement les deux glows D4 en meme temps, en conservant le miroir parfait gauche/droite."] = "P258",
    ["Deplace verticalement les deux glows en meme temps, en conservant le miroir parfait gauche/droite."] = "P259",
    ["Desaturation (%)"] = "P260",
    ["Desaturation barre inactive 2 barres (%)"] = "P261",
    ["Desature les icones de la backbar pour les distinguer visuellement de la barre active."] = "P262",
    ["Desature les icones pour les distinguer de la barre active."] = "P263",
    ["Distance des orbes depuis le centre de l'ecran en mode solo."] = "P264",
    ["Distance des orbes depuis le centre en mode dual (barre secondaire activee)."] = "P265",
    ["Ecart des glows D4 depuis le centre (px)"] = "P266",
    ["Ecart des glows depuis le centre (px)"] = "P267",
    ["Ecart entre chaque slot de competence de la backbar."] = "P268",
    ["Ecart entre chaque slot."] = "P269",
    ["Ecart horizontal des 5 slots (px)"] = "P270",
    ["Ecart raccourci depuis le bord (px)"] = "P271",
    ["Ecart symetrique du remplissage (px)"] = "P272",
    ["Ecart ultime (px)"] = "P273",
    ["Ecart ultime depuis le bord (px)"] = "P274",
    ["Ecarte la couche d'ombre : sante vers la gauche, mana/endu vers la droite."] = "P275",
    ["Ecarte la couche d'overlay : sante vers la gauche, mana/endu vers la droite."] = "P276",
    ["Ecarte la couche de contour : sante vers la gauche, mana/endu vers la droite."] = "P277",
    ["Ecarte les orbes par rapport a la barre en mode dual."] = "P278",
    ["Ecarte les orbes par rapport a la barre en mode solo."] = "P279",
    ["Ecarte ou rapproche les valeurs mana/endurance du centre de l'orbe scinde."] = "P280",
    ["Ecartement depuis le centre — Dual (px)"] = "P281",
    ["Ecartement depuis le centre — Solo (px)"] = "P282",
    ["Ecartement horizontal (px)"] = "P283",
    ["Echelle (%)"] = "P284",
    ["Echelle contenu barre D4 (%)"] = "P285",
    ["Eclairci = texte clair avec ombrage sombre. Assombri = texte fonce avec ombrage clair."] = "P286",
    ["Eloigne ou rapproche les glows D4 de magicka et stamina par rapport au centre."] = "P287",
    ["Eloigne ou rapproche les glows de magicka et stamina par rapport au centre. Augmentez pour plus d'ecart."] = "P288",
    ["En mode legacy, chaque moitie (mana/endurance) gere son propre etat d'alerte."] = "P289",
    ["Espace supplementaire entre le slot 5 et l'ultime."] = "P290",
    ["Espacement slots (px)"] = "P291",
    ["Exterieur : padding horizontal (px)"] = "P292",
    ["Exterieur : padding vertical (px)"] = "P293",
    ["Exterieur = position classique. Interieur = texte place au centre des orbes."] = "P294",
    ["Fond"] = "P295",
    ["Fond de barre D4"] = "P296",
    ["Fond dual (DiabloOrbsDualBarXp)"] = "P297",
    ["Fond solo (ActionBarXp)"] = "P298",
    ["Force une ombre interne minimale pour verifier l'imbrication des couches."] = "P299",
    ["Fractionner alerte orbe combine"] = "P300",
    ["General"] = "P301",
    ["Glow : taille (px)"] = "P302",
    ["Glow interne strict D4 (sans debordement)"] = "P303",
    ["Habillage des boutons de la barre d'action en theme D4 : bordures, smoke, compagnon."] = "P304",
    ["Hauteur du trait de separation en pourcentage de la taille de l'orbe."] = "P305",
    ["Hauteur fond D4 avec barre secondaire (%)"] = "P306",
    ["Hauteur fond D4 sans barre secondaire (%)"] = "P307",
    ["Hauteur fond jauge dual (px)"] = "P308",
    ["Hauteur fond jauge solo (px)"] = "P309",
    ["Hauteur jauge ultime dual (px)"] = "P310",
    ["Hauteur jauge ultime solo (px)"] = "P311",
    ["Infos et valeurs"] = "P312",
    ["Intensite additionnelle contours D4 dual (%)"] = "P313",
    ["Intensite additionnelle contours D4 solo (%)"] = "P314",
    ["Intensite de l'overlay additif D4OrbBack2."] = "P315",
    ["Intensite de la teinte (%)"] = "P316",
    ["Intensite du reflet permanent hors alerte ressource."] = "P317",
    ["Intensite max du glow d'alerte D4 (%)"] = "P318",
    ["Intensite maximale de l'aureole lumineuse autour des orbes D4 lors d'une alerte ressource."] = "P319",
    ["Intensite smoke boutons D4 (%)"] = "P320",
    ["Interieur : ecart miroir mana/endu (px)"] = "P321",
    ["Interieur : orbe gauche offset horizontal (px)"] = "P322",
    ["Inverse l'emplacement horizontal des valeurs mana et endurance quand l'affichage est en mode interieur. Independant par theme (D4 / Legacy)."] = "P323",
    ["Inverser mana/endurance (interieur)"] = "P324",
    ["Jauge"] = "P325",
    ["Jauge ultime"] = "P326",
    ["La police est commune; la taille des textes orbes et jauge ultime est reglee separement."] = "P327",
    ["Label — D4"] = "P328",
    ["Label — Legacy"] = "P329",
    ["Langue de l'interface"] = "P330",
    ["Largeur du trait de separation en pixels."] = "P331",
    ["Largeur fond D4 avec barre secondaire (%)"] = "P332",
    ["Largeur fond D4 sans barre secondaire (%)"] = "P333",
    ["Largeur fond jauge dual (%)"] = "P334",
    ["Largeur fond jauge solo (%)"] = "P335",
    ["Largeur jauge ultime dual (%)"] = "P336",
    ["Largeur jauge ultime solo (%)"] = "P337",
    ["Le fond suit le theme actif (D4: fond_jauge.dds, Legacy: UltimateGaugeBackground.dds). Les sliders ci-dessous pilotent taille/offset/opacite."] = "P338",
    ["Le texte ultime est independant du pulse de la jauge et reste lisible en permanence."] = "P339",
    ["Legacy — Fond et backbar"] = "P340",
    ["Luminosite barre D4 (%)"] = "P341",
    ["Luminosite des socles (preset)"] = "P342",
    ["Luminosite du fond (%)"] = "P343",
    ["Luminosite globale (%)"] = "P344",
    ["Luminosite globale du fond (%)"] = "P345",
    ["Mode 2 barres: ces reglages s'appliquent a la barre secondaire affichee en permanence quand un systeme dual est detecte."] = "P346",
    ["Monte ou descend independamment le texte du bouclier en D4."] = "P347",
    ["Monte ou descend independamment le texte du bouclier en Legacy."] = "P348",
    ["Monte ou descend la barre en mode dual (barre secondaire activee)."] = "P349",
    ["Monte ou descend la barre en mode solo (barre secondaire desactivee)."] = "P350",
    ["Monte ou descend la jauge ultime en mode dual."] = "P351",
    ["Monte ou descend la jauge ultime en mode solo."] = "P352",
    ["Monte ou descend le fond de jauge en mode dual."] = "P353",
    ["Monte ou descend le fond de jauge en mode solo."] = "P354",
    ["Monte ou descend le texte des valeurs des orbes."] = "P355",
    ["Monte/descend les orbes et socles en mode dual (barre secondaire activee)."] = "P356",
    ["Monte/descend les orbes et socles en mode solo (barre secondaire desactivee)."] = "P357",
    ["Niveau de couche bouclier D4"] = "P358",
    ["Noirceur contours boutons D4 (%)"] = "P359",
    ["Offset X raccourcis (px)"] = "P360",
    ["Offset X ultime (px)"] = "P361",
    ["Offset Y raccourcis (px)"] = "P362",
    ["Offset Y ultime (px)"] = "P363",
    ["Offset horizontal (px)"] = "P364",
    ["Offset slot raccourci D4 (px)"] = "P365",
    ["Offset slot ultime D4 (px)"] = "P366",
    ["Offset vertical (px)"] = "P367",
    ["Offset vertical 5 slots - dual bar (px)"] = "P368",
    ["Offset vertical 5 slots - solo bar (px)"] = "P369",
    ["Offset vertical barre - Dual (px)"] = "P370",
    ["Offset vertical barre - Solo (px)"] = "P371",
    ["Offset vertical fond jauge dual (px)"] = "P372",
    ["Offset vertical fond jauge solo (px)"] = "P373",
    ["Offset vertical glow D4 (px)"] = "P374",
    ["Offset vertical glow miroir (px)"] = "P375",
    ["Offset vertical jauge ultime dual (px)"] = "P376",
    ["Offset vertical jauge ultime solo (px)"] = "P377",
    ["Offset vertical slot raccourci D4 (px)"] = "P378",
    ["Offset vertical slot ultime D4 (px)"] = "P379",
    ["Offset vertical texte valeurs (px)"] = "P380",
    ["Ombre interne : taille (px)"] = "P381",
    ["Ombre minimale D4 (%)"] = "P382",
    ["Opacite (%)"] = "P383",
    ["Opacite barre inactive 2 barres (%)"] = "P384",
    ["Opacite bordure tooltip valeurs (%)"] = "P385",
    ["Opacite contours boutons D4 (%)"] = "P386",
    ["Opacite couche teintee (%)"] = "P387",
    ["Opacite des raccourcis (%)"] = "P388",
    ["Opacite du bouclier D4 (%)"] = "P389",
    ["Opacite du bouclier Legacy (%)"] = "P390",
    ["Opacite du glow d'alerte basse ressource."] = "P391",
    ["Opacite fond contraste interieur (%)"] = "P392",
    ["Opacite fond de jauge (%)"] = "P393",
    ["Opacite globale orbes + socles (%)"] = "P394",
    ["Opacite glow d'alerte (%)"] = "P395",
    ["Opacite ombrage texte interieur (%)"] = "P396",
    ["Opacite remplissage jauge (%)"] = "P397",
    ["Opacite texte ultime (%)"] = "P398",
    ["Opacite texte valeurs (%)"] = "P399",
    ["Options communes de la barre d'action DiabloOrbs. Les reglages marques solo/dual permettent un comportement distinct selon le mode detecte."] = "P400",
    ["Orbes D4"] = "P401",
    ["Orbes Legacy"] = "P402",
    ["Organisation: famille de police commune, puis reglages separes pour valeurs des orbes et texte de jauge ultime."] = "P403",
    ["Police des nombres (commun tous themes)"] = "P404",
    ["Position des raccourcis"] = "P405",
    ["Position des valeurs"] = "P406",
    ["Position et taille"] = "P407",
    ["Position et taille — reglages globaux"] = "P408",
    ["Position orbes — Dual"] = "P409",
    ["Position orbes — Solo"] = "P410",
    ["Position verticale des orbes — Dual (px)"] = "P411",
    ["Position verticale des orbes — Solo (px)"] = "P412",
    ["Raccourcis"] = "P413",
    ["Raccourcis visibles seulement en combat"] = "P414",
    ["Redimensionne homothetiquement tous les calques des orbes Legacy ensemble."] = "P415",
    ["Reflet au repos D4 (%)"] = "P416",
    ["Reglage avance: intensite dual multipliee avec l'opacite principale."] = "P417",
    ["Reglage avance: intensite solo multipliee avec l'opacite principale."] = "P418",
    ["Reglage principal de l'opacite des contours de boutons D4 (raccourci, 5 slots, ultime et compagnon)."] = "P419",
    ["Reglages generaux de DiabloOrbs."] = "P420",
    ["Reglages independants par theme (D4 ou Legacy), avec valeurs distinctes solo/dual."] = "P421",
    ["Regle l'ecart lateral des valeurs exterieures par rapport aux bords des orbes."] = "P422",
    ["Regle l'opacite de la barre secondaire inactive quand une configuration 2 barres est detectee."] = "P423",
    ["Regle l'opacite de la bordure decorative autour du texte des valeurs."] = "P424",
    ["Regle l'opacite de la couche d'ombre des orbes D4."] = "P425",
    ["Regle l'opacite de la couche de couleur supplementaire derriere les orbes."] = "P426",
    ["Regle l'opacite de la couche de fond colore des orbes D4."] = "P427",
    ["Regle l'opacite de la couche de glow des orbes D4."] = "P428",
    ["Regle l'opacite de la couche de remplissage Smoke des orbes D4."] = "P429",
    ["Regle l'opacite de la surcouche contour des orbes D4."] = "P430",
    ["Regle l'opacite de la vraie ombre de texte appliquee derriere les valeurs placees dans l'orbe."] = "P431",
    ["Regle l'opacite du contour principal des orbes D4."] = "P432",
    ["Regle l'opacite du fond de contraste derriere les valeurs placees dans l'orbe."] = "P433",
    ["Regle l'opacite du texte de la jauge ultime sans affecter le pulse de la barre."] = "P434",
    ["Regle l'opacite du texte des valeurs, quel que soit son placement."] = "P435",
    ["Regle l'opacite du trait de separation mana/endurance."] = "P436",
    ["Regle la luminosite generale du fond colore Smoke.dds des orbes D4."] = "P437",
    ["Regle la position haut/bas des valeurs exterieures."] = "P438",
    ["Regle la taille de la police du texte affiche sur la jauge ultime."] = "P439",
    ["Regle la transparence du fond de jauge sans toucher au texte."] = "P440",
    ["Remet tous les reglages D4 a leurs valeurs calibrees par defaut. N'affecte pas les reglages Legacy."] = "P441",
    ["Remet tous les reglages Legacy a leurs valeurs par defaut. N'affecte pas les reglages D4."] = "P442",
    ["Remplissage — decalage fin"] = "P443",
    ["Renforce le contraste du contour (100 = normal, >100 = plus marque)."] = "P444",
    ["Renforce ou adoucit la couleur du fond Smoke.dds pour toutes les ressources D4."] = "P445",
    ["Reset D4 (positions par defaut)"] = "P446",
    ["Reset Legacy (positions par defaut)"] = "P447",
    ["Separateur central : taille (px)"] = "P448",
    ["Si active, les raccourcis de competences s'affichent uniquement en combat."] = "P449",
    ["Slots — Dual"] = "P450",
    ["Slots — Solo"] = "P451",
    ["Style texte interieur"] = "P452",
    ["Superpose D4OrbBack2 en mode additif pour eclaircir l'orbe sans recolorer le fond."] = "P453",
    ["Taille de chaque icone de la backbar en pixels."] = "P454",
    ["Taille de chaque icone en pixels."] = "P455",
    ["Taille de la couche d'ombre interne (Shade.dds) des orbes Legacy. 150 = valeur par defaut."] = "P456",
    ["Taille des orbes (px)"] = "P457",
    ["Taille des raccourcis (%)"] = "P458",
    ["Taille des slots de la backbar. 80 = plus petits que la barre active pour accentuer la profondeur."] = "P459",
    ["Taille du cadre circulaire des orbes Legacy. 166 = valeur XML par defaut. Reduire pour eviter le depassement quand les orbes sont agrandis."] = "P460",
    ["Taille du cercle bouclier D4 (%)"] = "P461",
    ["Taille du cercle bouclier Legacy (%)"] = "P462",
    ["Taille du glow d'alerte basse ressource par rapport a la taille normale du glow. 100 = identique."] = "P463",
    ["Taille du glow des orbes Legacy. 150 = valeur par defaut."] = "P464",
    ["Taille du separateur entre Magie et Endurance (Split.dds). 166 = valeur par defaut."] = "P465",
    ["Taille fond barre D4 (%)"] = "P466",
    ["Taille globale de la backbar Legacy."] = "P467",
    ["Taille globale des orbes (%)"] = "P468",
    ["Taille globale du separateur en pourcentage de la taille de l'orbe."] = "P469",
    ["Taille glow d'alerte (%)"] = "P470",
    ["Taille police texte ultime"] = "P471",
    ["Taille slots (px)"] = "P472",
    ["Taille slots backbar (px)"] = "P473",
    ["Teinte appliquee au fond de jauge."] = "P474",
    ["Teinte globale D4"] = "P475",
    ["Texte"] = "P476",
    ["Texte et valeurs"] = "P477",
    ["Theme visuel"] = "P478",
    ["Translate les deux orbes de la couche additive ensemble a gauche/droite."] = "P479",
    ["Transparence de la backbar. 0 = invisible, 100 = opaque."] = "P480",
    ["Transparence des icones de la backbar Legacy."] = "P481",
    ["Typographie commune"] = "P482",
    ["Valeur positive = mana/endu s'ecartent du centre (smoke layer), valeur negative = elles se rapprochent."] = "P483",
    ["Valeurs des orbes"] = "P484",
    ["Visuel — D4"] = "P485",
    ["Visuel — Legacy"] = "P486",
    ["[Theme D4] Activer la barre secondaire (mode Dual)"] = "P487",
    ["[Theme Legacy] Activer la barre secondaire (mode Dual)"] = "P488",
    ["|cFFAA00[!] Pour un rendu optimal (solo et dual), activez dans|r |cFFFFFFReglages > Combat|r |cFFAA00:|r |cFFFFFF\"Rangee arriere de la barre de competences\"|r |cFFAA00et|r |cFFFFFF\"Minuteries de barre de competences\"|r|cFFAA00. (Tous themes)|r"] = "P489",
    ["Profils"] = "P490",
    ["Gerez vos profils de reglages. Un profil sauvegarde l'ensemble de vos parametres visuels. Vous pouvez partager un profil entre plusieurs personnages du meme compte."] = "P491",
    ["Profil actif"] = "P492",
    ["Selectionner le profil a charger. Cliquez sur 'Charger le profil' pour appliquer."] = "P493",
    ["Charger le profil selectionne"] = "P494",
    ["Applique les reglages du profil selectionne sur ce personnage."] = "P495",
    ["Sauvegarder (ecraser le profil actif)"] = "P496",
    ["Ecrase le profil actif avec vos reglages actuels."] = "P497",
    ["Sauvegarder sous... (nouveau nom)"] = "P498",
    ["Cree un nouveau profil avec le nom saisi, et vos reglages actuels."] = "P499",
    ["Creer ce nouveau profil"] = "P500",
    ["Cree ou ecrase un profil avec le nom saisi ci-dessus."] = "P501",
    ["Supprimer le profil selectionne"] = "P502",
    ["Supprime le profil selectionne ('D4 default' et 'Legacy default' sont proteges)."] = "P503",
    ["Decorations (Angel / Demon)"] = "P504",
    ["Afficher les decorations (Angel / Demon)"] = "P505",
    ["Premier plan (devant les orbes)"] = "P506",
    ["Inverser les cotes (Angel/Demon)"] = "P507",
    ["Cadre ornemental : taille (px)"] = "P508",
    ["Ombre interne : taille (px)"] = "P509",
    ["Separateur central : taille (px)"] = "P510",
    ["Glow : taille (px)"] = "P511",
    ["Taille de base (px)"] = "P512",
    ["Largeur (%)"] = "P513",
    ["Hauteur (%)"] = "P514",
    ["Ecartement depuis le centre (px)"] = "P515",
    ["Decalage vertical (px)"] = "P516",
    ["Taille du cadre circulaire des orbes Legacy. 166 = valeur XML par defaut. Reduire pour eviter le depassement quand les orbes sont agrandis. [ID: B93]"] = "P517",
    ["Taille de la couche d'ombre interne (Shade.dds) des orbes Legacy. 150 = valeur par defaut. [ID: B94]"] = "P518",
    ["Taille du separateur entre Magie et Endurance (Split.dds). 166 = valeur par defaut. [ID: B95]"] = "P519",
    ["Taille du glow des orbes Legacy. 150 = valeur par defaut. [ID: B96]"] = "P520",
    ["Affiche ou masque les images decoratives Angel et Demon de chaque cote des orbes (Legacy uniquement). [ID: LD10]"] = "P521",
    ["Taille de reference des images Angel et Demon. La largeur et hauteur sont des pourcentages de cette valeur. [ID: LD11]"] = "P522",
    ["Distance horizontale entre le centre de l'ecran et chaque image. 0 = centre. [ID: LD12]"] = "P523",
    ["Deplace les decorations vers le haut (negatif) ou le bas (positif). [ID: LD13]"] = "P524",
    ["Affiche les decorations devant tous les elements. Desactive = arriere-plan. [ID: LD14]"] = "P525",
    ["Echange les positions : Angel a gauche, Demon a droite. [ID: LD15]"] = "P526",
    ["Largeur en % de la taille de base. [ID: LD16]"] = "P527",
    ["Hauteur en % de la taille de base. [ID: LD17]"] = "P528",
}

local function LocalizeLiteral(value)
    if type(value) ~= "string" then
        return value
    end
    local key = LOCALIZED_LITERAL_KEYS[value]
    if key ~= nil then
        return L(key)
    end
    local base, idTag = value:match("^(.-)(%s*%[ID:%s*%w+%])$")
    if base and idTag then
        local baseKey = LOCALIZED_LITERAL_KEYS[base]
        if baseKey ~= nil then
            return L(baseKey) .. idTag
        end
    end
    return value
end

local function LocalizeOptionsData(optionsData)
    for _, option in ipairs(optionsData) do
        option.name = LocalizeLiteral(option.name)
        option.text = LocalizeLiteral(option.text)
        option.tooltip = LocalizeLiteral(option.tooltip)
        if option.choices ~= nil then
            for index, choice in ipairs(option.choices) do
                option.choices[index] = LocalizeLiteral(choice)
            end
        end
        -- Descend dans les submenus
        if option.controls ~= nil then
            LocalizeOptionsData(option.controls)
        end
    end
end

-- ============================================================
-- Système de profils (account-wide, partageable entre persos)
-- ============================================================

local SV_PROFILES_VER = 1
-- DiabloOrbs.profiles et DiabloOrbs.charConfig sont initialisés dans OnAddOnLoaded

-- Profils ancrés dans l'addon — recréés au démarrage, non-supprimables
local BUILTIN_PROFILES = {
    ["D4 default"] = {
        ["THEME"] = "d4",
        ["D4_BACKPLATE_WIDTH_SCALE"] = 60, ["D4_LABEL_FORMAT"] = "full", ["D4_BACKGROUND_LAYER_ALPHA"] = 100,
        ["D4_BACKGROUND_LAYER_OFFSET_X"] = 1, ["SHOW_FOOD_TIMER"] = true, ["D4_SEAM_OFFSET_X"] = 0,
        ["D4_SHOW_ULTIMATE_BAR_BACKGROUND"] = true, ["LEGACY_SOLO_QUICKSLOT_OFFSET_X"] = 0,
        ["D4_LABEL_INNER_SHADE_COLOR_R"] = 0, ["D4_BACKBAR_OFFSET_X"] = 0, ["D4_ULTIMATE_BAR_OFFSET_Y"] = 0,
        ["LOW_RESOURCE_GLOW_ALERT_SIZE"] = 100, ["STAMINA_COLOR_R"] = 0, ["SHOW_ULTIMATE_BAR_BACKGROUND"] = false,
        ["ULTIMATE_TEXT_COLOR_B"] = 0.6, ["D4_SLOT_SMOKE_INTENSITY"] = 0, ["D4_BORDER_LAYER_SIZE"] = 103,
        ["D4_ULTIMATE_BAR_BG_SOLO_OFFSET_Y"] = 51, ["LEGACY_BACKBAR_SLOT_GAP"] = 12, ["D4_SEAM_VISIBLE"] = true,
        ["LEGACY_ORB_LAYER_GLOBAL_SCALE"] = 100, ["LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_R"] = 0,
        ["D4_BACKBAR_ULT_OFFSET_X"] = -5, ["SHIELD_LABEL_OFFSET_X"] = 0, ["ORB_TINT_LAYER_ALPHA"] = 68,
        ["ULTIMATE_BAR_BG_SOLO_OFFSET_Y"] = 0, ["ENABLE_ACTION_BAR_MODULE"] = true, ["D4_MAGICKA_COLOR_R"] = 0,
        ["D4_BAR_SLOTS_OFFSET_Y"] = -38, ["LEGACY_DECO_GAP_X"] = 411, ["ULTIMATE_READY_COLOR_B"] = 0.25,
        ["D4_SOLO_BAR_WIDTH_SCALE"] = 92, ["LABEL_TEXT_ALPHA"] = 100, ["D4_LABEL_SCALE"] = 1.1,
        ["D4_GLOW_LAYER_OFFSET_X"] = 0, ["D4_BACKPLATE_HEIGHT_SCALE"] = 60, ["D4_LABEL_OFFSET_Y"] = 0,
        ["D4_SEAM_ADDITIVE"] = false, ["D4_FILL_LAYER_OFFSET_Y"] = -15, ["D4_BACKGROUND_LAYER_OFFSET_Y"] = 9,
        ["D4_LABEL_INNER_BACKDROP_ALPHA"] = 35, ["SHIELD_ALPHA"] = 1, ["VALUE_TOOLTIP_BORDER_ALPHA"] = 100,
        ["D4_ORB_TINT_LAYER_COLOR_G"] = 0.1, ["LOW_RESOURCE_GLOW_ALERT_ALPHA"] = 100, ["ULTIMATE_BAR_OFFSET_Y"] = 0,
        ["D4_SOLO_ORB_OFFSET_Y"] = 2, ["SHOW_ULTIMATE_BAR"] = true, ["D4_BORDER_LAYER_VISIBLE"] = true,
        ["ULTIMATE_BAR_FILL_ALPHA"] = 90, ["D4_BACKBAR_ULT_GAP"] = 10, ["BORDER_PULSE_ENABLED"] = true,
        ["STAMINA_COLOR_G"] = 1, ["LEGACY_BACKBAR_SLOT_SIZE"] = 61, ["D4_OVERLAY_LAYER_VISIBLE"] = true,
        ["D4_GLOW_INTERNAL_ONLY"] = true, ["LEGACY_ORB_OFFSET_Y"] = -9, ["ULTIMATE_BAR_BG_DUAL_WIDTH_SCALE"] = 100,
        ["SHOW_ACTION_BAR_BACKGROUNDS"] = true, ["INACTIVE_BACK_BAR_DESATURATION"] = 35,
        ["LABEL_INNER_SHADE_ALPHA"] = 73, ["D4_SOLO_ORB_INSET_X"] = 279, ["ACTION_BAR_HOTKEY_OFFSET_X"] = -15,
        ["LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_B"] = 1, ["ORB_TINT_LAYER_COLOR_R"] = 0.1,
        ["D4_MAGICKA_COLOR_G"] = 0.4, ["D4_BAR_SLOTS_OFFSET_Y_DUAL"] = -64, ["ULTIMATE_READY_COLOR_G"] = 0.86,
        ["D4_SOLO_BAR_HEIGHT_SCALE"] = 124, ["D4_BAR_ULTIMATE_OFFSET_X"] = -15, ["D4_ULTIMATE_BAR_BG_ALPHA"] = 100,
        ["D4_ORB_BACKPLATE_PRESET"] = 16, ["LEGACY_SOLO_ACTION_BAR_CENTER_SLOTS_GAP_X"] = 6,
        ["LOW_RESOURCE_GLOW_ALERT_ENABLED"] = true, ["D4_SHOW_OFFBAR"] = true, ["D4_ORB_INSET_X"] = 311,
        ["BORDER_PULSE_B"] = 0, ["LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_G"] = 0.4,
        ["ULTIMATE_BAR_BG_SOLO_WIDTH_SCALE"] = 100, ["D4_ORB_OFFSET_Y"] = 2, ["D4_SEAM_COLOR_G"] = 0.0901960805,
        ["D4_ULTIMATE_BAR_SOLO_HEIGHT"] = 11, ["D4_SLOT_HIGHLIGHT_ALPHA"] = 100, ["LEGACY_DUAL_ORB_OFFSET_Y"] = -4,
        ["D4_BACKGROUND_LAYER_BRIGHTNESS"] = 60, ["D4_LABEL_CENTER_GAP_X"] = -40, ["D4_ORB_TINT_LAYER_COLOR_B"] = 0.1,
        ["D4_GLOW_CENTER_GAP_X"] = 65, ["LEGACY_BACKBAR_ULT_OFFSET_X"] = 0, ["D4_MAGICKA_COLOR_B"] = 1,
        ["ULTIMATE_BAR_DUAL_HEIGHT"] = 10, ["ACTION_BAR_HOTKEY_SCALE"] = 100, ["D4_SLOT_BORDER_DARKNESS"] = 0,
        ["STAMINA_COLOR_B"] = 0, ["LABEL_CENTER_GAP_X"] = 42, ["LEGACY_DECO_FOREGROUND"] = false,
        ["SMOKE_ALPHA"] = 1, ["D4_BORDER_LAYER_OFFSET_Y"] = -9, ["ULTIMATE_PULSE_MIN_ALPHA"] = 0.5,
        ["LABEL_INNER_BACKDROP_ALPHA"] = 35, ["GLOW_INTERNAL_ONLY"] = true, ["INACTIVE_BACK_BAR_ALPHA"] = 55,
        ["ORB_TINT_LAYER_COLOR_G"] = 0.1, ["LEGACY_BG_DUAL_MIDDLE_OFFSET_Y"] = -127, ["ULTIMATE_BAR_WIDTH_SCALE"] = 100,
        ["D4_ULTIMATE_BAR_FILL_ALPHA"] = 45, ["D4_BAR_TEXTURE_SCALE"] = 120, ["SHADE_ALPHA"] = 0,
        ["D4_LABEL_INSIDE_HEALTH_OFFSET_X"] = 1, ["D4_ORB_COMBINED_GAP_X"] = 0, ["LEGACY_INTERFACE_SCALE"] = 100,
        ["D4_BACKGROUND_LAYER_HEIGHT"] = 106, ["D4_STAMINA_COLOR_G"] = 1, ["D4_SEAM_OFFSET_Y"] = -1,
        ["D4_SLOT_BORDER_ADVANCED"] = false, ["LEGACY_SOLO_ULTIMATE_OFFSET_X"] = 0, ["D4_ORB_SIZE"] = 188,
        ["D4_BACKGROUND_LAYER_VISIBLE"] = true, ["ULTIMATE_TEXT_FONT_SIZE"] = 16, ["LEGACY_SOLO_ORB_OFFSET_X"] = 10,
        ["HEALTH_COLOR_R"] = 1, ["D4_UNIFIED_ORB_ALPHA"] = 100, ["LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_R"] = 0.2,
        ["LEGACY_BACKBAR_ULT_GAP"] = 11, ["D4_SLOT_BORDER_CONTRAST"] = 100, ["ULTIMATE_BAR_DUAL_OFFSET_Y"] = 0,
        ["ACTION_BAR_HOTKEY_POSITION"] = "inside", ["D4_STAMINA_COLOR_R"] = 0, ["LABEL_INSIDE_HEALTH_OFFSET_X"] = 0,
        ["D4_GLOW_LAYER_ALPHA"] = 100, ["D4_BORDER_LAYER_OFFSET_X"] = -9, ["LEGACY_DECO_MIRROR"] = true,
        ["BORDER_PULSE_G"] = 0, ["ULTIMATE_PULSE_MAX_ALPHA"] = 0.95, ["SHIELD_COLOR_R"] = 0,
        ["ULTIMATE_BAR_BG_SOLO_HEIGHT"] = 16, ["D4_SLOT_HIGHLIGHT_DUAL_ALPHA"] = 100, ["D4_BACKBAR_SLOT_SIZE"] = 61,
        ["ULTIMATE_PULSE_SPEED"] = 1.6, ["SMOKEBG_BRIGHTNESS"] = 0, ["D4_BACKGROUND_EDGE_LIGHT_BOOST"] = 70,
        ["SHOW_ACTION_BAR_WEAPON_SWAP"] = false, ["ULTIMATE_BAR_BG_COLOR_G"] = 1, ["D4_GLOBAL_TINT_G"] = 1,
        ["D4_BACKBAR_SCALE"] = 80, ["D4_SEAM_ALPHA"] = 45, ["D4_LABEL_OUTER_PADDING_Y"] = -28,
        ["D4_ULTIMATE_BAR_DUAL_WIDTH_SCALE"] = 82, ["BORDER_ALPHA"] = 1, ["SHIELD_COLOR_B"] = 1,
        ["D4_ORB_HEALTH_GAP_X"] = -4, ["SHOW_ACTION_BAR_HOTKEYS"] = true, ["LEGACY_BACKBAR_ULT_OFFSET_Y"] = 0,
        ["D4_FILL_LAYER_COMBO_OFFSET_Y"] = 0, ["ORB_COLOR_BOOST"] = 100, ["D4_LABEL_TEXT_ALPHA"] = 100,
        ["GLOW_CENTER_GAP_X"] = 65, ["SHIELD_VISUAL_RESPONSE"] = 130, ["D4_GLOW_CONTRAST"] = 395,
        ["ULTIMATE_BAR_BG_DUAL_OFFSET_Y"] = 0, ["D4_SEAM_SIZE"] = 100, ["LEGACY_BG_SOLO_MIDDLE_OFFSET_Y"] = -127,
        ["D4_BAR_SCALE"] = 100, ["ULTIMATE_BAR_SOLO_OFFSET_Y"] = -2, ["D4_FILL_LAYER_ALPHA"] = 90,
        ["D4_SEAM_WIDTH"] = 137, ["LABEL_OUTER_PADDING_Y"] = -28, ["D4_ORB_COLOR_BOOST"] = 115,
        ["D4_BAR_QUICKSLOT_OFFSET_Y"] = 0, ["SHOW_ACTION_BAR_COMPANION_ULTIMATE"] = true, ["SHIELD_COLOR_G"] = 1,
        ["ULTIMATE_TEXT_COLOR_G"] = 0.84, ["D4_OVERLAY_LAYER_SIZE"] = 92, ["D4_IDLE_HIGHLIGHT_ALPHA"] = 50,
        ["D4_SEAM_COLOR_R"] = 0.1294117719, ["D4_SHADE_LAYER_OFFSET_Y"] = 0, ["D4_BACKGROUND_ADDITIVE_STAMINA"] = true,
        ["LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_B"] = 0.1, ["LEGACY_BG_DUAL_MIDDLE_HEIGHT"] = 256,
        ["LEGACY_ULTIMATE_OFFSET_X"] = 0, ["INACTIVE_BACK_BAR_ALPHA_DUAL"] = 60, ["ULTIMATE_BAR_BG_COLOR_B"] = 1,
        ["HEALTH_COLOR_B"] = 0, ["D4_GLOW_TINT"] = 0, ["ULTIMATE_TEXT_ALPHA"] = 100,
        ["D4_SLOT_HIGHLIGHT_SOLO_ALPHA"] = 100, ["D4_BACKBAR_DESATURATION"] = 79,
        ["D4_ULTIMATE_BAR_BG_COLOR_G"] = 1, ["LABEL_TEXT_ALPHA"] = 100, ["D4_GLOBAL_TINT_B"] = 1,
        ["D4_LABEL_OUTER_PADDING_X"] = 0, ["D4_ORB_BRIGHTNESS"] = 100, ["D4_BACKGROUND_LAYER_SIZE"] = 100,
        ["D4_LABEL_POSITION_MODE"] = "inside", ["LABEL_POSITION_MODE"] = "inside",
        ["D4_ADDITIVE_ORB_OFFSET_X"] = 0, ["D4_FILL_LAYER_HEALTH_OFFSET_Y"] = 0,
        ["D4_LABEL_INNER_SHADE_ALPHA"] = 35, ["LEGACY_DECO_VISIBLE"] = false, ["D4_BACKBAR_SLOT_GAP"] = 5,
        ["D4_SHIELD_LABEL_OFFSET_Y"] = -32, ["LABEL_OUTER_PADDING_X"] = 12, ["LEGACY_DUAL_ORB_OFFSET_X"] = 20,
        ["D4_GLOW_CENTER_GAP_X"] = 65, ["LEGACY_BG_SOLO_MIDDLE_OFFSET_X"] = 0, ["ULTIMATE_BAR_BG_DUAL_HEIGHT"] = 16,
        ["D4_BACKGROUND_ADDITIVE_STAMINA"] = true, ["LEGACY_BG_SOLO_MIDDLE_WIDTH"] = 400,
        ["SHOW_ACTION_BAR_ULTIMATE_WIDGET"] = true, ["D4_SHIELD_RING_SCALE"] = 125,
        ["D4_BORDER_PULSE_ENABLED"] = true, ["D4_LABEL_INNER_STYLE"] = "light",
        ["D4_ULTIMATE_BAR_BG_DUAL_WIDTH_SCALE"] = 86, ["D4_FILL_LAYER_VISIBLE"] = true,
        ["LEGACY_SHADE_SIZE"] = 160, ["LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_B"] = 0.1, ["SHIELD_RING_SCALE"] = 100,
        ["D4_GLOW_OFFSET_Y"] = 0, ["D4_BACKGROUND_NEGATIVE"] = true, ["LEGACY_BG_DUAL_LEFT_OFFSET_X"] = 69,
        ["SHIELD_LABEL_OFFSET_Y"] = -39, ["LABEL_INSIDE_SWAP_MANA_STAMINA"] = false,
        ["D4_DUAL_ORB_INSET_X"] = 278, ["ULTIMATE_BAR_DUAL_WIDTH_SCALE"] = 103,
        ["LEGACY_BACKBAR_OFFSET_Y"] = -59, ["D4_ULTIMATE_BAR_HEIGHT"] = 8, ["ULTIMATE_BAR_SOLO_WIDTH_SCALE"] = 100,
        ["D4_OVERLAY_LAYER_GAP_X"] = 0, ["D4_ULTIMATE_BAR_BG_COLOR_B"] = 1, ["D4_HEALTH_COLOR_B"] = 0,
        ["D4_SHADE_LAYER_VISIBLE"] = true, ["D4_BAR_QUICKSLOT_OFFSET_X"] = 0, ["D4_BAR_OFFSET_Y"] = 1,
        ["LEGACY_BG_DUAL_RIGHT_OFFSET_X"] = -68, ["D4_ADDITIVE_ORB_GAP_X"] = 0, ["HEALTH_COLOR_R"] = 1,
        ["D4_SHADE_LAYER_OFFSET_X"] = 0, ["ULTIMATE_READY_COLOR_R"] = 1,
        ["D4_ULTIMATE_BAR_BG_DUAL_OFFSET_Y"] = -30, ["D4_ALL_SLOT_BORDER_ALPHA"] = 100,
        ["LEGACY_QUICKSLOT_OFFSET_X"] = 0, ["D4_SEAM_SIZE"] = 100, ["D4_SEAM_COLOR_B"] = 0,
        ["D4_BORDER_LAYER_GAP_X"] = 0, ["ORB_TINT_LAYER_ENABLED"] = false, ["D4_BORDER_LAYER_ALPHA"] = 100,
        ["D4_SHIELD_COLOR_G"] = 1, ["ULTIMATE_TEXT_MODE"] = "value", ["D4_BACKGROUND_LAYER_GLOBAL_X"] = 46,
        ["D4_ORB_TINT_LAYER_ENABLED"] = false, ["D4_GLOW_LAYER_VISIBLE"] = true, ["LEGACY_SOLO_ORB_OFFSET_Y"] = -10,
        ["D4_BORDER_PULSE_B"] = 0, ["LEGACY_BACKBAR_ALPHA"] = 40, ["LABEL_FORMAT"] = "full",
        ["D4_OVERLAY_LAYER_OFFSET_X"] = -2, ["D4_LABEL_INNER_SHADE_COLOR_B"] = 0, ["D4_FILL_TINT_STRENGTH"] = 100,
        ["D4_GLOW_LAYER_OFFSET_Y"] = 2, ["D4_MIN_SHADE_ALPHA"] = 0, ["D4_OVERLAY_LAYER_OFFSET_Y"] = -2,
        ["LEGACY_BACKBAR_SCALE"] = 79, ["D4_SHIELD_LABEL_OFFSET_X"] = 0, ["LABEL_INNER_SHADE_COLOR_B"] = 0,
        ["GLOW_OFFSET_Y"] = 0, ["D4_ULTIMATE_BAR_DUAL_OFFSET_Y"] = -30, ["D4_FILL_LAYER_GLOBAL_X"] = 10,
        ["D4_ULTIMATE_BAR_WIDTH_SCALE"] = 100, ["D4_HEALTH_COLOR_G"] = 0, ["D4_GLOW_LAYER_SIZE"] = 87,
        ["D4_ORB_TINT_LAYER_COLOR_R"] = 0.1, ["D4_GLOW_INTENSITY"] = 500, ["LEGACY_DECO_SIZE"] = 210,
        ["ULTIMATE_TEXT_COLOR_R"] = 0.94, ["LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_R"] = 1,
        ["D4_SHIELD_COLOR_R"] = 0, ["ULTIMATE_BAR_SOLO_HEIGHT"] = 8, ["D4_BORDER_PULSE_R"] = 1,
        ["D4_DUAL_BAR_WIDTH_SCALE"] = 92, ["D4_ORB_BRIGHTNESS"] = 100, ["LEGACY_SHOW_BACKBAR"] = true,
        ["LEGACY_DUAL_ACTION_BAR_CENTER_SLOTS_GAP_X"] = 6, ["ORB_TINT_LAYER_COLOR_B"] = 0.1,
        ["D4_BAR_ULTIMATE_OFFSET_Y"] = 0, ["D4_SHADE_LAYER_VISIBLE"] = true, ["NUMBER_FONT_FAMILY"] = "dum1",
        ["D4_SHIELD_LAYER_LEVEL"] = 10, ["ACTION_BAR_HOTKEY_ALPHA"] = 100, ["D4_BACKGROUND_LAYER_WIDTH"] = 106,
        ["D4_BAR_BRIGHTNESS"] = 120, ["GLOW_MAX_ALPHA"] = 0.9, ["LEGACY_BG_SOLO_RIGHT_OFFSET_X"] = -83,
        ["D4_BACKGROUND_ORB_GAP_X"] = 107, ["D4_SEAM_BRIGHTNESS"] = 0, ["ACTION_BAR_CENTER_SLOTS_GAP_X"] = 2,
        ["D4_SLOT_HIGHLIGHT_SOLO_ALPHA"] = 100, ["D4_OVERLAY_BRIGHTNESS"] = 75,
        ["LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_G"] = 0.2, ["MAGICKA_COLOR_G"] = 0.4,
        ["D4_OVERLAY_LAYER_ALPHA"] = 58, ["LEGACY_DUAL_ULTIMATE_OFFSET_X"] = 0, ["D4_DUAL_ORB_INSET_X"] = 278,
        ["D4_GLOW_MAX_ALPHA"] = 0.8, ["SPLIT_ALPHA"] = 1, ["D4_SEAM_COLOR_B"] = 0,
        ["D4_BORDER_LAYER_GAP_X"] = 0, ["LABEL_SCALE"] = 0.95, ["ULTIMATE_BAR_BG_ALPHA"] = 100,
        ["ULTIMATE_BAR_HEIGHT"] = 8, ["LEGACY_ACTION_BAR_CENTER_SLOTS_GAP_X"] = 6, ["D4_BORDER_PULSE_G"] = 0,
        ["LEGACY_DUAL_QUICKSLOT_OFFSET_X"] = 1, ["ULTIMATE_BAR_BG_COLOR_R"] = 1, ["ULTIMATE_READY_COLOR_R"] = 1,
        ["D4_BACKGROUND_NEGATIVE"] = true, ["D4_BACKPLATE_OFFSET_Y"] = 0, ["SHOW_D4_SLOT_BORDERS"] = true,
        ["ULTIMATE_TEXT_ALPHA"] = 100, ["LOW_RESOURCE_WARNING_PERCENT"] = 20, ["HEALTH_COLOR_G"] = 0,
        ["D4_SHADE_LAYER_ALPHA"] = 100, ["D4_FILL_LAYER_SIZE"] = 86, ["D4_LABEL_INNER_SHADE_COLOR_G"] = 0,
        ["LEGACY_BG_SOLO_MIDDLE_HEIGHT"] = 256, ["LABEL_INNER_STYLE"] = "light", ["LABEL_INNER_SHADE_COLOR_G"] = 0,
        ["D4_BACKBAR_OFFSET_Y"] = -34, ["LEGACY_BACKBAR_DESATURATION"] = 83, ["D4_MIN_SHADE_ALPHA"] = 0,
        ["D4_ULTIMATE_BAR_BG_COLOR_B"] = 1, ["LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_B"] = 1,
        ["D4_ULTIMATE_BAR_DUAL_HEIGHT"] = 11, ["D4_SHOW_SHIELD_LABEL"] = true, ["SHOW_ULTIMATE_TEXT"] = true,
        ["ORB_BRIGHTNESS"] = 100, ["D4_HEALTH_COLOR_R"] = 1, ["D4_ULTIMATE_BAR_BG_COLOR_R"] = 1,
        ["D4_SHOW_ULTIMATE_BAR"] = true, ["LEGACY_DECO_WIDTH"] = 100, ["MAGICKA_COLOR_R"] = 0,
        ["D4_DUAL_BAR_HEIGHT_SCALE"] = 120, ["D4_ULTIMATE_BAR_BG_COLOR_G"] = 1, ["LABEL_OFFSET_Y"] = 0,
        ["D4_HEALTH_COLOR_B"] = 0, ["D4_ULTIMATE_BAR_BG_SOLO_WIDTH_SCALE"] = 83,
        ["D4_BACKBAR_ULT_OFFSET_Y"] = 0, ["D4_FILL_LAYER_OFFSET_X"] = 0, ["LEGACY_BORDER_SIZE"] = 173,
        ["D4_GLOBAL_TINT_INTENSITY"] = 0, ["LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_G"] = 0.9,
        ["D4_ULTIMATE_BAR_HEIGHT"] = 8, ["MAGICKA_COLOR_B"] = 1, ["LEGACY_BG_SOLO_LEFT_OFFSET_X"] = 80,
        ["LEGACY_GLOW_SIZE"] = 160, ["LEGACY_BACKBAR_OFFSET_X"] = 0, ["D4_SHIELD_ALPHA"] = 1,
        ["ACTION_BAR_HOTKEY_ONLY_IN_COMBAT"] = false, ["LABEL_INNER_SHADE_COLOR_R"] = 0,
        ["D4_COMPANION_SLOT_BORDER_DARKNESS"] = 0, ["D4_SHOW_LIVE_PREVIEW"] = false,
        ["D4_OVERLAY_LAYER_OFFSET_Y"] = -2, ["LEGACY_BG_DUAL_MIDDLE_WIDTH"] = 400,
        ["INACTIVE_BACK_BAR_DESATURATION_DUAL"] = 43, ["D4_LABEL_INSIDE_SWAP_MANA_STAMINA"] = true,
        ["D4_SHIELD_COLOR_B"] = 1, ["D4_ORB_GLOBAL_GAP_X"] = -17, ["D4_SEAM_HEIGHT"] = 92,
        ["D4_SHADE_LAYER_GAP_X"] = 0, ["LEGACY_ORB_OFFSET_X"] = 14, ["D4_OVERLAY_CONTRAST"] = 70,
        ["D4_ULTIMATE_BAR_BG_SOLO_HEIGHT"] = 26, ["D4_DUAL_BAR_OFFSET_Y"] = 46,
        ["ACTION_BAR_HOTKEY_OFFSET_Y"] = -13, ["LEGACY_SPLIT_SIZE"] = 165, ["D4_GLOBAL_TINT_R"] = 1,
        ["LEGACY_DECO_HEIGHT"] = 100, ["LEGACY_DECO_OFFSET_Y"] = 0, ["D4_ULTIMATE_BAR_SOLO_OFFSET_Y"] = 54,
        ["D4_SOLO_BAR_OFFSET_Y"] = 10, ["D4_BACKPLATE_INSET_X"] = 223, ["SHOW_SHIELD_LABEL"] = true,
        ["LABEL_INNER_SHADE_COLOR_R"] = 0, ["D4_SHADE_LAYER_SIZE"] = 102, ["D4_OVERLAY_CONTRAST"] = 70,
        ["D4_ULTIMATE_BAR_BG_SOLO_HEIGHT"] = 26, ["LANGUAGE_MODE"] = "auto",
    },
    ["Legacy default"] = {
        ["THEME"] = "legacy",
        ["D4_BACKPLATE_WIDTH_SCALE"] = 60, ["LEGACY_DECO_HEIGHT"] = 100, ["D4_LABEL_FORMAT"] = "full",
        ["D4_BACKGROUND_LAYER_ALPHA"] = 100, ["D4_BACKGROUND_LAYER_OFFSET_X"] = 1, ["SHOW_FOOD_TIMER"] = true,
        ["D4_SEAM_OFFSET_X"] = 0, ["D4_SHOW_ULTIMATE_BAR_BACKGROUND"] = true,
        ["LEGACY_SOLO_QUICKSLOT_OFFSET_X"] = 0, ["D4_LABEL_INNER_SHADE_COLOR_R"] = 0,
        ["D4_BACKBAR_OFFSET_X"] = 0, ["D4_ORB_TINT_LAYER_COLOR_R"] = 0.1, ["LOW_RESOURCE_GLOW_ALERT_SIZE"] = 100,
        ["STAMINA_COLOR_R"] = 0, ["SHOW_ULTIMATE_BAR_BACKGROUND"] = false, ["ULTIMATE_TEXT_COLOR_B"] = 0.6,
        ["LEGACY_BG_DUAL_MIDDLE_HEIGHT"] = 256, ["D4_BORDER_LAYER_SIZE"] = 103,
        ["D4_ULTIMATE_BAR_BG_SOLO_OFFSET_Y"] = 51, ["LEGACY_BACKBAR_SLOT_GAP"] = 12, ["D4_SEAM_VISIBLE"] = true,
        ["LEGACY_ORB_LAYER_GLOBAL_SCALE"] = 100, ["LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_R"] = 0,
        ["D4_BACKBAR_ULT_OFFSET_X"] = -5, ["SHIELD_LABEL_OFFSET_X"] = 0, ["ORB_TINT_LAYER_ALPHA"] = 68,
        ["ULTIMATE_BAR_BG_SOLO_OFFSET_Y"] = 0, ["ENABLE_ACTION_BAR_MODULE"] = true, ["D4_MAGICKA_COLOR_R"] = 0,
        ["D4_BAR_SLOTS_OFFSET_Y"] = -38, ["INACTIVE_BACK_BAR_ALPHA_DUAL"] = 60, ["ULTIMATE_READY_COLOR_B"] = 0.25,
        ["D4_SOLO_BAR_WIDTH_SCALE"] = 92, ["BORDER_PULSE_R"] = 1, ["D4_LABEL_SCALE"] = 1.1,
        ["D4_GLOW_LAYER_OFFSET_X"] = 0, ["D4_BACKPLATE_HEIGHT_SCALE"] = 60, ["D4_LABEL_OFFSET_Y"] = 0,
        ["D4_SEAM_ADDITIVE"] = false, ["D4_FILL_LAYER_OFFSET_Y"] = -15, ["D4_BACKGROUND_LAYER_OFFSET_Y"] = 9,
        ["LANGUAGE_MODE"] = "auto", ["SHIELD_ALPHA"] = 1, ["VALUE_TOOLTIP_BORDER_ALPHA"] = 100,
        ["D4_ORB_TINT_LAYER_COLOR_G"] = 0.1, ["LOW_RESOURCE_GLOW_ALERT_ALPHA"] = 100,
        ["ULTIMATE_BAR_OFFSET_Y"] = 0, ["D4_SOLO_ORB_OFFSET_Y"] = 2, ["SHOW_ULTIMATE_BAR"] = true,
        ["D4_BORDER_LAYER_VISIBLE"] = true, ["ULTIMATE_BAR_FILL_ALPHA"] = 90, ["D4_BACKBAR_ULT_GAP"] = 10,
        ["BORDER_PULSE_ENABLED"] = true, ["STAMINA_COLOR_G"] = 1, ["LEGACY_BACKBAR_SLOT_SIZE"] = 61,
        ["D4_OVERLAY_LAYER_VISIBLE"] = true, ["D4_GLOW_INTERNAL_ONLY"] = true, ["LEGACY_ORB_OFFSET_Y"] = -9,
        ["ULTIMATE_BAR_BG_DUAL_WIDTH_SCALE"] = 100, ["SHOW_ACTION_BAR_BACKGROUNDS"] = true,
        ["LEGACY_DECO_OFFSET_Y"] = 0, ["LABEL_INNER_SHADE_ALPHA"] = 73, ["D4_SOLO_ORB_INSET_X"] = 279,
        ["ACTION_BAR_HOTKEY_OFFSET_X"] = -15, ["LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_B"] = 1,
        ["ORB_TINT_LAYER_COLOR_R"] = 0.1, ["D4_MAGICKA_COLOR_G"] = 0.4, ["D4_BAR_SLOTS_OFFSET_Y_DUAL"] = -64,
        ["ULTIMATE_READY_COLOR_G"] = 0.86, ["D4_SOLO_BAR_HEIGHT_SCALE"] = 124, ["D4_BAR_ULTIMATE_OFFSET_X"] = -15,
        ["D4_ULTIMATE_BAR_BG_ALPHA"] = 100, ["D4_ORB_BACKPLATE_PRESET"] = 16,
        ["LEGACY_SOLO_ACTION_BAR_CENTER_SLOTS_GAP_X"] = 6, ["LOW_RESOURCE_GLOW_ALERT_ENABLED"] = true,
        ["D4_SHOW_OFFBAR"] = true, ["D4_ORB_INSET_X"] = 311, ["BORDER_PULSE_B"] = 0,
        ["LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_G"] = 0.4, ["ULTIMATE_BAR_BG_SOLO_WIDTH_SCALE"] = 100,
        ["D4_ORB_OFFSET_Y"] = 2, ["D4_SEAM_COLOR_G"] = 0.0901960805, ["D4_ULTIMATE_BAR_SOLO_HEIGHT"] = 11,
        ["D4_SLOT_HIGHLIGHT_ALPHA"] = 100, ["LEGACY_DUAL_ORB_OFFSET_Y"] = -3, ["D4_BACKGROUND_LAYER_BRIGHTNESS"] = 60,
        ["D4_LABEL_CENTER_GAP_X"] = -40, ["D4_ORB_TINT_LAYER_COLOR_B"] = 0.1, ["D4_GLOW_INTENSITY"] = 500,
        ["LEGACY_BACKBAR_ULT_OFFSET_X"] = 0, ["D4_MAGICKA_COLOR_B"] = 1, ["ULTIMATE_BAR_DUAL_HEIGHT"] = 10,
        ["ACTION_BAR_HOTKEY_SCALE"] = 100, ["D4_SLOT_BORDER_DARKNESS"] = 0, ["STAMINA_COLOR_B"] = 0,
        ["LABEL_CENTER_GAP_X"] = 42, ["LEGACY_DECO_FOREGROUND"] = false, ["SMOKE_ALPHA"] = 1,
        ["D4_BORDER_LAYER_OFFSET_Y"] = -9, ["ULTIMATE_PULSE_MIN_ALPHA"] = 0.5, ["LABEL_INNER_BACKDROP_ALPHA"] = 35,
        ["GLOW_INTERNAL_ONLY"] = true, ["INACTIVE_BACK_BAR_ALPHA"] = 55,
        ["ORB_TINT_LAYER_COLOR_G"] = 0.1, ["LEGACY_BG_DUAL_MIDDLE_OFFSET_Y"] = -123,
        ["ULTIMATE_BAR_WIDTH_SCALE"] = 100, ["D4_ULTIMATE_BAR_FILL_ALPHA"] = 45, ["D4_BAR_TEXTURE_SCALE"] = 120,
        ["SHADE_ALPHA"] = 0, ["D4_LABEL_INSIDE_HEALTH_OFFSET_X"] = 1, ["D4_ORB_COMBINED_GAP_X"] = 0,
        ["LEGACY_INTERFACE_SCALE"] = 100, ["D4_BACKGROUND_LAYER_HEIGHT"] = 106, ["D4_STAMINA_COLOR_G"] = 1,
        ["D4_SEAM_OFFSET_Y"] = -1, ["D4_SLOT_BORDER_ADVANCED"] = false, ["LEGACY_SOLO_ULTIMATE_OFFSET_X"] = 0,
        ["D4_ORB_SIZE"] = 188, ["D4_BACKGROUND_LAYER_VISIBLE"] = true, ["ULTIMATE_TEXT_FONT_SIZE"] = 16,
        ["LEGACY_SOLO_ORB_OFFSET_X"] = 14, ["D4_ULTIMATE_BAR_SOLO_WIDTH_SCALE"] = 80,
        ["D4_UNIFIED_ORB_ALPHA"] = 100, ["LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_R"] = 0.2,
        ["LEGACY_BACKBAR_ULT_GAP"] = 11, ["D4_SLOT_BORDER_CONTRAST"] = 100, ["ULTIMATE_BAR_DUAL_OFFSET_Y"] = 0,
        ["ACTION_BAR_HOTKEY_POSITION"] = "inside", ["D4_STAMINA_COLOR_R"] = 0,
        ["LABEL_INSIDE_HEALTH_OFFSET_X"] = 0, ["D4_GLOW_LAYER_ALPHA"] = 100, ["D4_BORDER_LAYER_OFFSET_X"] = -9,
        ["LEGACY_DECO_MIRROR"] = true, ["BORDER_PULSE_G"] = 0, ["ULTIMATE_PULSE_MAX_ALPHA"] = 0.95,
        ["SHIELD_COLOR_R"] = 0, ["ULTIMATE_BAR_BG_SOLO_HEIGHT"] = 16, ["D4_SLOT_HIGHLIGHT_DUAL_ALPHA"] = 100,
        ["D4_BACKBAR_SLOT_SIZE"] = 61, ["ULTIMATE_PULSE_SPEED"] = 1.6, ["SMOKEBG_BRIGHTNESS"] = 0,
        ["D4_BACKGROUND_EDGE_LIGHT_BOOST"] = 70, ["SHOW_ACTION_BAR_WEAPON_SWAP"] = false,
        ["ULTIMATE_BAR_BG_COLOR_G"] = 1, ["D4_GLOBAL_TINT_G"] = 1, ["D4_BACKBAR_SCALE"] = 80,
        ["D4_SEAM_ALPHA"] = 45, ["D4_LABEL_OUTER_PADDING_Y"] = -28, ["D4_ULTIMATE_BAR_DUAL_WIDTH_SCALE"] = 82,
        ["BORDER_ALPHA"] = 1, ["SHIELD_COLOR_B"] = 1, ["D4_ORB_HEALTH_GAP_X"] = -4,
        ["SHOW_ACTION_BAR_HOTKEYS"] = true, ["LEGACY_BACKBAR_ULT_OFFSET_Y"] = 0,
        ["D4_FILL_LAYER_COMBO_OFFSET_Y"] = 0, ["ORB_COLOR_BOOST"] = 100, ["D4_LABEL_TEXT_ALPHA"] = 100,
        ["GLOW_CENTER_GAP_X"] = 65, ["SHIELD_VISUAL_RESPONSE"] = 130, ["D4_GLOW_CONTRAST"] = 395,
        ["ULTIMATE_BAR_BG_DUAL_OFFSET_Y"] = 0, ["D4_BORDER_PULSE_R"] = 1, ["LEGACY_BG_SOLO_MIDDLE_OFFSET_Y"] = -127,
        ["D4_BAR_SCALE"] = 100, ["ULTIMATE_BAR_SOLO_OFFSET_Y"] = -2, ["D4_FILL_LAYER_ALPHA"] = 90,
        ["D4_SEAM_WIDTH"] = 137, ["LABEL_OUTER_PADDING_Y"] = -28, ["D4_ORB_COLOR_BOOST"] = 115,
        ["LEGACY_DUAL_QUICKSLOT_OFFSET_X"] = 1, ["LEGACY_SPLIT_SIZE"] = 165, ["D4_ULTIMATE_BAR_OFFSET_Y"] = 0,
        ["SHOW_ACTION_BAR_COMPANION_ULTIMATE"] = true, ["SHIELD_COLOR_G"] = 1, ["ULTIMATE_TEXT_COLOR_G"] = 0.84,
        ["D4_OVERLAY_LAYER_SIZE"] = 92, ["D4_BACKBAR_ALPHA"] = 55, ["D4_IDLE_HIGHLIGHT_ALPHA"] = 50,
        ["D4_SHADE_LAYER_OFFSET_Y"] = 0, ["D4_SEAM_COLOR_R"] = 0.1294117719,
        ["LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_B"] = 0.1, ["INACTIVE_BACK_BAR_DESATURATION"] = 35,
        ["LEGACY_ULTIMATE_OFFSET_X"] = 0, ["LEGACY_BG_DUAL_MIDDLE_OFFSET_X"] = 0,
        ["ULTIMATE_BAR_BG_COLOR_B"] = 1, ["HEALTH_COLOR_B"] = 0, ["LOW_RESOURCE_WARNING_PERCENT"] = 20,
        ["D4_GLOW_TINT"] = 0, ["ULTIMATE_TEXT_ALPHA"] = 100, ["D4_SLOT_HIGHLIGHT_SOLO_ALPHA"] = 100,
        ["D4_BACKBAR_DESATURATION"] = 79, ["D4_ULTIMATE_BAR_BG_COLOR_G"] = 1, ["LABEL_TEXT_ALPHA"] = 100,
        ["D4_GLOBAL_TINT_B"] = 1, ["D4_LABEL_OUTER_PADDING_X"] = 0, ["D4_ORB_BRIGHTNESS"] = 100,
        ["D4_BACKGROUND_LAYER_SIZE"] = 100, ["D4_LABEL_POSITION_MODE"] = "inside",
        ["LABEL_POSITION_MODE"] = "inside", ["D4_ADDITIVE_ORB_OFFSET_X"] = 0,
        ["D4_FILL_LAYER_HEALTH_OFFSET_Y"] = 0, ["D4_LABEL_INNER_SHADE_ALPHA"] = 35,
        ["LEGACY_DECO_VISIBLE"] = true, ["D4_BACKBAR_SLOT_GAP"] = 5, ["D4_SHIELD_LABEL_OFFSET_Y"] = -32,
        ["LABEL_OUTER_PADDING_X"] = 12, ["LEGACY_DUAL_ORB_OFFSET_X"] = 24, ["D4_GLOW_CENTER_GAP_X"] = 65,
        ["LEGACY_BG_SOLO_MIDDLE_OFFSET_X"] = 0, ["ULTIMATE_BAR_BG_DUAL_HEIGHT"] = 16,
        ["D4_BACKGROUND_ADDITIVE_STAMINA"] = true, ["LEGACY_BG_SOLO_MIDDLE_WIDTH"] = 400,
        ["SHOW_ACTION_BAR_ULTIMATE_WIDGET"] = true, ["D4_SHIELD_RING_SCALE"] = 125,
        ["D4_BORDER_PULSE_ENABLED"] = true, ["D4_LABEL_INNER_STYLE"] = "light",
        ["D4_ULTIMATE_BAR_BG_DUAL_WIDTH_SCALE"] = 86, ["D4_FILL_LAYER_VISIBLE"] = true,
        ["LEGACY_SHADE_SIZE"] = 160, ["LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_B"] = 0.1,
        ["SHIELD_RING_SCALE"] = 100, ["D4_GLOW_OFFSET_Y"] = 0, ["D4_BACKGROUND_NEGATIVE"] = true,
        ["LEGACY_BG_DUAL_LEFT_OFFSET_X"] = 69, ["SHIELD_LABEL_OFFSET_Y"] = -39,
        ["LABEL_INSIDE_SWAP_MANA_STAMINA"] = false, ["D4_DUAL_ORB_INSET_X"] = 278,
        ["ULTIMATE_BAR_DUAL_WIDTH_SCALE"] = 103, ["LEGACY_BACKBAR_OFFSET_Y"] = -55,
        ["D4_ULTIMATE_BAR_HEIGHT"] = 8, ["ULTIMATE_BAR_SOLO_WIDTH_SCALE"] = 100,
        ["D4_OVERLAY_LAYER_GAP_X"] = 0, ["D4_ULTIMATE_BAR_BG_COLOR_B"] = 1, ["D4_HEALTH_COLOR_B"] = 0,
        ["D4_SHADE_LAYER_VISIBLE"] = true, ["D4_BAR_QUICKSLOT_OFFSET_X"] = 0, ["D4_BAR_OFFSET_Y"] = 1,
        ["LEGACY_BG_DUAL_RIGHT_OFFSET_X"] = -68, ["D4_ADDITIVE_ORB_GAP_X"] = 0, ["HEALTH_COLOR_R"] = 1,
        ["D4_SHADE_LAYER_OFFSET_X"] = 0, ["ULTIMATE_READY_COLOR_R"] = 1,
        ["D4_ULTIMATE_BAR_BG_DUAL_OFFSET_Y"] = -30, ["D4_ALL_SLOT_BORDER_ALPHA"] = 100,
        ["LEGACY_QUICKSLOT_OFFSET_X"] = 0, ["D4_SEAM_SIZE"] = 100, ["D4_SEAM_COLOR_B"] = 0,
        ["D4_BORDER_LAYER_GAP_X"] = 0, ["ORB_TINT_LAYER_ENABLED"] = false, ["D4_BORDER_LAYER_ALPHA"] = 100,
        ["D4_SHIELD_COLOR_G"] = 1, ["ULTIMATE_TEXT_MODE"] = "value", ["D4_BACKGROUND_LAYER_GLOBAL_X"] = 46,
        ["D4_ORB_TINT_LAYER_ENABLED"] = false, ["D4_GLOW_LAYER_VISIBLE"] = true,
        ["LEGACY_SOLO_ORB_OFFSET_Y"] = -10, ["D4_BORDER_PULSE_B"] = 0, ["LEGACY_BACKBAR_ALPHA"] = 40,
        ["LABEL_FORMAT"] = "full", ["D4_OVERLAY_LAYER_OFFSET_X"] = -2, ["D4_LABEL_INNER_SHADE_COLOR_B"] = 0,
        ["D4_FILL_TINT_STRENGTH"] = 100, ["D4_GLOW_LAYER_OFFSET_Y"] = 2, ["D4_MIN_SHADE_ALPHA"] = 0,
        ["D4_OVERLAY_LAYER_OFFSET_Y"] = -2, ["LEGACY_BACKBAR_SCALE"] = 79, ["D4_SHIELD_LABEL_OFFSET_X"] = 0,
        ["LABEL_INNER_SHADE_COLOR_B"] = 0, ["GLOW_OFFSET_Y"] = 0, ["D4_ULTIMATE_BAR_DUAL_OFFSET_Y"] = -30,
        ["D4_FILL_LAYER_GLOBAL_X"] = 10, ["D4_ULTIMATE_BAR_WIDTH_SCALE"] = 100, ["D4_HEALTH_COLOR_G"] = 0,
        ["D4_STAMINA_COLOR_B"] = 0, ["D4_SLOT_SMOKE_INTENSITY"] = 0, ["D4_BACKPLATE_OFFSET_X"] = 85,
        ["LEGACY_DECO_SIZE"] = 200, ["ULTIMATE_TEXT_COLOR_R"] = 0.94, ["D4_GLOBAL_TINT_INTENSITY"] = 0,
        ["D4_BACKPLATE_INSET_X"] = 223, ["D4_GLOW_BRIGHTNESS"] = 500, ["D4_USE_TYPED_FILL_TEXTURES"] = false,
        ["D4_DUAL_BAR_WIDTH_SCALE"] = 92, ["LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_R"] = 1,
        ["LEGACY_SHOW_BACKBAR"] = true, ["LEGACY_DUAL_ACTION_BAR_CENTER_SLOTS_GAP_X"] = 6,
        ["LEGACY_ACTION_BAR_CENTER_SLOTS_GAP_X"] = 6, ["ULTIMATE_BAR_SOLO_HEIGHT"] = 8,
        ["LEGACY_ORB_OFFSET_X"] = 14, ["NUMBER_FONT_FAMILY"] = "dum1", ["D4_SHIELD_LAYER_LEVEL"] = 10,
        ["ACTION_BAR_HOTKEY_ALPHA"] = 100, ["D4_BACKGROUND_LAYER_WIDTH"] = 106, ["D4_BAR_BRIGHTNESS"] = 120,
        ["GLOW_MAX_ALPHA"] = 0.9, ["LEGACY_BG_SOLO_RIGHT_OFFSET_X"] = -83, ["D4_BACKGROUND_ORB_GAP_X"] = 107,
        ["D4_SEAM_BRIGHTNESS"] = 0, ["ACTION_BAR_CENTER_SLOTS_GAP_X"] = 2, ["ORB_TINT_LAYER_COLOR_B"] = 0.1,
        ["D4_OVERLAY_BRIGHTNESS"] = 75, ["LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_G"] = 0.2,
        ["MAGICKA_COLOR_G"] = 0.4, ["LABEL_SCALE"] = 0.95, ["D4_BAR_ULTIMATE_OFFSET_Y"] = 0,
        ["D4_ULTIMATE_BAR_SOLO_OFFSET_Y"] = 54, ["D4_BAR_QUICKSLOT_OFFSET_Y"] = 0, ["D4_GLOBAL_TINT_R"] = 1,
        ["D4_SHADE_LAYER_SIZE"] = 102, ["INACTIVE_BACK_BAR_DESATURATION_DUAL"] = 43,
        ["D4_OVERLAY_LAYER_ALPHA"] = 58, ["ULTIMATE_BAR_BG_ALPHA"] = 100,
        ["D4_LABEL_INSIDE_SWAP_MANA_STAMINA"] = true, ["D4_GLOW_LAYER_SIZE"] = 87, ["D4_BORDER_PULSE_G"] = 0,
        ["D4_LABEL_INNER_BACKDROP_ALPHA"] = 35, ["ULTIMATE_BAR_BG_COLOR_R"] = 1,
        ["ACTION_BAR_HOTKEY_OFFSET_Y"] = -13, ["LEGACY_DECO_WIDTH"] = 100, ["D4_BACKPLATE_OFFSET_Y"] = 0,
        ["SHOW_D4_SLOT_BORDERS"] = true, ["D4_GLOW_MAX_ALPHA"] = 0.8, ["D4_ULTIMATE_BAR_BG_DUAL_HEIGHT"] = 23,
        ["SHOW_ACTION_BAR_SLOTS"] = true, ["D4_SHADE_LAYER_ALPHA"] = 100, ["D4_FILL_LAYER_SIZE"] = 86,
        ["D4_LABEL_INNER_SHADE_COLOR_G"] = 0, ["LABEL_OFFSET_Y"] = 0, ["LABEL_INNER_STYLE"] = "light",
        ["LABEL_INNER_SHADE_COLOR_G"] = 0, ["D4_BACKBAR_OFFSET_Y"] = -34, ["LEGACY_BACKBAR_DESATURATION"] = 83,
        ["D4_FILL_LAYER_HEALTH_OFFSET_X"] = 0, ["D4_ULTIMATE_BAR_BG_COLOR_R"] = 1,
        ["D4_DUAL_ORB_OFFSET_Y"] = 2, ["D4_ULTIMATE_BAR_DUAL_HEIGHT"] = 11, ["D4_SHOW_SHIELD_LABEL"] = true,
        ["SHOW_ULTIMATE_TEXT"] = true, ["ORB_BRIGHTNESS"] = 100, ["HEALTH_COLOR_G"] = 0,
        ["LEGACY_BG_SOLO_MIDDLE_HEIGHT"] = 256, ["D4_SHOW_ULTIMATE_BAR"] = true, ["ULTIMATE_BAR_HEIGHT"] = 8,
        ["D4_HEALTH_COLOR_R"] = 1, ["D4_DUAL_BAR_HEIGHT_SCALE"] = 120, ["D4_DUAL_BAR_OFFSET_Y"] = 46,
        ["D4_SOLO_BAR_OFFSET_Y"] = 10, ["D4_SHIELD_COLOR_R"] = 0, ["SHOW_SHIELD_LABEL"] = true,
        ["LEGACY_DECO_GAP_X"] = 405, ["D4_BACKBAR_ULT_OFFSET_Y"] = 0, ["D4_FILL_LAYER_OFFSET_X"] = 0,
        ["LEGACY_BORDER_SIZE"] = 173, ["D4_ULTIMATE_BAR_BG_SOLO_WIDTH_SCALE"] = 83,
        ["LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_G"] = 0.9, ["LEGACY_GLOW_SIZE"] = 160, ["MAGICKA_COLOR_B"] = 1,
        ["LEGACY_BG_SOLO_LEFT_OFFSET_X"] = 80, ["ACTION_BAR_HOTKEY_ONLY_IN_COMBAT"] = false,
        ["LEGACY_BACKBAR_OFFSET_X"] = 0, ["D4_SHIELD_ALPHA"] = 1, ["D4_COMPANION_SLOT_BORDER_DARKNESS"] = 0,
        ["MAGICKA_COLOR_R"] = 0, ["D4_ORB_TINT_LAYER_ALPHA"] = 35, ["D4_SHOW_LIVE_PREVIEW"] = false,
        ["LEGACY_BG_DUAL_MIDDLE_WIDTH"] = 400, ["LABEL_INNER_SHADE_COLOR_R"] = 0,
        ["LEGACY_DUAL_ULTIMATE_OFFSET_X"] = 0, ["SPLIT_ALPHA"] = 1, ["D4_SHIELD_COLOR_B"] = 1,
        ["D4_ORB_GLOBAL_GAP_X"] = -17, ["D4_SEAM_HEIGHT"] = 92, ["D4_SHADE_LAYER_GAP_X"] = 0,
        ["LOW_RESOURCE_FRACTIONATE_COMBINED"] = true, ["D4_OVERLAY_CONTRAST"] = 70,
        ["D4_ULTIMATE_BAR_BG_SOLO_HEIGHT"] = 26,
    },
}
local PROTECTED_PROFILE_NAMES = { ["D4 default"] = true, ["Legacy default"] = true }

local function DeepCopy(src)
    if type(src) ~= "table" then return src end
    local dst = {}
    for k, v in pairs(src) do
        dst[k] = DeepCopy(v)
    end
    return dst
end

local function ProfileExists(name)
    return DiabloOrbs.profiles ~= nil and DiabloOrbs.profiles[name] ~= nil
end

local function ListProfiles()
    local list = {}
    if DiabloOrbs.profiles then
        for name, _ in pairs(DiabloOrbs.profiles) do
            table.insert(list, name)
        end
    end
    table.sort(list)
    return list
end

local function SaveCurrentToProfile(name)
    if DiabloOrbs.profiles == nil or SETTINGS == nil then return end
    if PROTECTED_PROFILE_NAMES[name] then return end
    -- Copier uniquement les clés connues (DEFAULT_SETTINGS) pour éviter les méthodes ZO_SavedVars
    local snapshot = {}
    for k, _ in pairs(DEFAULT_SETTINGS) do
        snapshot[k] = SETTINGS[k]
    end
    DiabloOrbs.profiles[name] = snapshot
end

local function LoadProfile(name)
    if DiabloOrbs.profiles == nil or SETTINGS == nil then return end
    if not ProfileExists(name) then return end
    local src = DiabloOrbs.profiles[name]
    local prevTheme = SETTINGS.THEME
    -- src est une vraie table Lua, pairs() est sûr ici
    for k, v in pairs(src) do
        SETTINGS[k] = v
    end
    if DiabloOrbs.charConfig then
        DiabloOrbs.charConfig.activeProfile = name
    end
    -- Reload UI si changement de thème (D4 <-> Legacy)
    local newTheme = src.THEME and NormalizeThemeKey(src.THEME)
    local oldTheme = prevTheme and NormalizeThemeKey(prevTheme)
    if newTheme and oldTheme and newTheme ~= oldTheme then
        ReloadUI()
        return
    end
    -- Même thème : appliquer à chaud
    if SETTINGS.THEME then
        local normalizedTheme = NormalizeThemeKey(SETTINGS.THEME)
        ThemeManager:SetTheme(normalizedTheme)
        SETTINGS.THEME = ThemeManager:GetCurrentTheme()
    end
end

local function DeleteProfile(name)
    if PROTECTED_PROFILE_NAMES[name] then return end
    if DiabloOrbs.profiles then
        DiabloOrbs.profiles[name] = nil
    end
end

local function RenameProfile(oldName, newName)
    if oldName == "Default" then return end
    if DiabloOrbs.profiles == nil then return end
    if newName == nil or newName == "" or ProfileExists(newName) then return end
    DiabloOrbs.profiles[newName] = DiabloOrbs.profiles[oldName]
    DiabloOrbs.profiles[oldName] = nil
    if DiabloOrbs.charConfig and DiabloOrbs.charConfig.activeProfile == oldName then
        DiabloOrbs.charConfig.activeProfile = newName
    end
end

local function GetActiveProfileName()
    if DiabloOrbs.charConfig then
        return DiabloOrbs.charConfig.activeProfile or "D4 default"
    end
    return "Default"
end

-- ============================================================

local function RegisterSettingsPanel(topLevelCtrl)
    local LAM2 = LibAddonMenu2
    if LAM2 == nil then
        return
    end

    local panelId = NAME .. "Options"
    local panelData = {
        type = "panel",
        name = "DiabloOrbs",
        displayName = "DiabloOrbs",
        author = "Forsion, BulDeZir - Continued...",
        version = "2.0.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local function IsCurrentThemeD4()
        return ThemeManager:GetCurrentTheme() == "d4"
    end

    local function IsCurrentThemeLegacy()
        return ThemeManager:GetCurrentTheme() ~= "d4"
    end

    local function IsNotD4Theme()
        return IsCurrentThemeLegacy()
    end

    local function IsModeSolo()
        return SETTINGS ~= nil and SETTINGS.D4_SHOW_OFFBAR == false
    end
    local function IsModeDual()
        return not IsModeSolo()
    end
    local function IsNotD4OrSolo()
        return IsNotD4Theme() or IsModeSolo()
    end
    local function IsNotD4OrDual()
        return IsNotD4Theme() or IsModeDual()
    end

    local function IsActionBarModuleDisabled()
        return SETTINGS ~= nil and SETTINGS.ENABLE_ACTION_BAR_MODULE == false
    end

    local function AreActionBarSlotsDisabled()
        return IsActionBarModuleDisabled() or (SETTINGS ~= nil and SETTINGS.SHOW_ACTION_BAR_SLOTS == false)
    end

    local function IsActionBarUltimateWidgetDisabledLocal()
        return SETTINGS ~= nil and SETTINGS.SHOW_ACTION_BAR_ULTIMATE_WIDGET == false
    end

    local function HideD4LayerFineTuning()
        return true
    end

    local function IsLabelInsideMode()
        return NormalizeLabelPositionMode(GetThemeSetting("LABEL_POSITION_MODE")) == "inside"
    end

    local function IsD4AdditiveDisabled()
        return IsNotD4Theme() or (SETTINGS.D4_BACKGROUND_NEGATIVE ~= true)
    end

    local function IsD4GlowStylingDisabled()
        return IsNotD4Theme() or (SETTINGS.D4_GLOW_LAYER_VISIBLE == false)
    end

    local function IsD4OverlayStylingDisabled()
        return IsNotD4Theme() or (SETTINGS.D4_OVERLAY_LAYER_VISIBLE == false)
    end

    local function IsD4SeamStylingDisabled()
        return IsNotD4Theme() or (SETTINGS.D4_SEAM_VISIBLE == false)
    end

    local optionsData = {
        {
            type = "description",
            text = "Parametres de DiabloOrbs.",
            width = "full",
        },
        {
            type = "header",
            name = "General",
        },
        {
            type = "description",
            text = "Reglages generaux de DiabloOrbs.",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Langue de l'interface",
            tooltip = L("LANG_MODE_TIP") .. " [ID: A01]",
            choices = { L("LANG_MODE_AUTO"), "English", "Francais", "Deutsch", "Espanol", "Italiano", "Русский" },
            choicesValues = { "auto", "en", "fr", "de", "es", "it", "ru" },
            getFunc = function()
                local mode = SETTINGS.LANGUAGE_MODE
                if mode == nil or (not SUPPORTED_LANGUAGE_CODES[mode]) then
                    return "auto"
                end
                return mode
            end,
            setFunc = function(value)
                SETTINGS.LANGUAGE_MODE = value
                updateUltimate(topLevelCtrl)
                RefreshAllBars()
            end,
            default = DEFAULT_SETTINGS.LANGUAGE_MODE,
            width = "full",
        },
        {
            type = "description",
            text = L("LANG_MODE_HINT"),
            width = "full",
        },
        {
            type = "dropdown",
            name = "Theme visuel",
            tooltip = "Choisit le theme des textures (Legacy ou D4). Un reloadui sera lance automatiquement pour appliquer le changement. [ID: A02]",
            choices = { "Legacy", "D4" },
            choicesValues = { "legacy", "d4" },
            getFunc = function()
                return NormalizeThemeKey(SETTINGS.THEME)
            end,
            setFunc = function(value)
                local normalizedTheme = NormalizeThemeKey(value)
                if ThemeManager:SetTheme(normalizedTheme) then
                    SETTINGS.THEME = normalizedTheme
                    RefreshTheme(topLevelCtrl)
                    if LAM2.RequestRefreshIfNeeded ~= nil then
                        LAM2:RequestRefreshIfNeeded(panelId)
                    end
                    zo_callLater(function()
                        ReloadUI("ingame")
                    end, 100)
                end
            end,
            default = DEFAULT_SETTINGS.THEME,
            width = "full",
        },
        {
            type = "checkbox",
            name = "[Theme D4] Activer la barre secondaire (mode Dual)",
            tooltip = "Affiche une deuxieme barre en arriere-plan avec la texture dual. Desactiver pour n'afficher qu'une seule barre. (Theme D4 uniquement) [ID: A03]",
            getFunc = function() return IsD4ShowOffbar() end,
            setFunc = function(value)
                SETTINGS.D4_SHOW_OFFBAR = value
                RefreshTheme(topLevelCtrl)
            end,
            default = DEFAULT_SETTINGS.D4_SHOW_OFFBAR,
            width = "full",
        },
        {
            type = "checkbox",
            name = "[Theme Legacy] Activer la barre secondaire (mode Dual)",
            tooltip = "Affiche les icones de la barre inactive en arriere-plan en mode Dual, avec le fond dual Legacy. (Theme Legacy uniquement) [ID: A04]",
            getFunc = function() return IsLegacyShowBackbar() end,
            setFunc = function(value)
                SETTINGS.LEGACY_SHOW_BACKBAR = value
                RefreshTheme(topLevelCtrl)
                ApplyLegacyBackbarLayout(topLevelCtrl)
            end,
            default = DEFAULT_SETTINGS.LEGACY_SHOW_BACKBAR,
            width = "full",
        },
        {
            type = "description",
            text = "|cFFAA00[!] Pour un rendu optimal (solo et dual), activez dans|r |cFFFFFFReglages > Combat|r |cFFAA00:|r |cFFFFFF\"Rangee arriere de la barre de competences\"|r |cFFAA00et|r |cFFFFFF\"Minuteries de barre de competences\"|r|cFFAA00. (Tous themes)|r",
            width = "full",
        },
        {
            type = "button",
            name = L("RELOAD_UI_NAME"),
            tooltip = L("RELOAD_UI_TIP") .. " [ID: A07]",
            func = function()
                ReloadUI("ingame")
            end,
            width = "full",
        },
        -- --------------------------------------------------------
        -- Submenu : Profils
        -- --------------------------------------------------------
        {
            type = "submenu",
            name = L("Profils"),
            controls = {
                {
                    type = "description",
                    text = L("Gerez vos profils de reglages. Un profil sauvegarde l'ensemble de vos parametres visuels. Vous pouvez partager un profil entre plusieurs personnages du meme compte."),
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = L("Profil actif"),
                    tooltip = L("Selectionner le profil a charger. Cliquez sur 'Charger le profil' pour appliquer."),
                    choices = {},
                    choicesValues = {},
                    getFunc = function()
                        return GetActiveProfileName()
                    end,
                    setFunc = function(value)
                        if DiabloOrbs.charConfig then
                            DiabloOrbs._pendingProfileLoad = value
                        end
                    end,
                    reference = "DiabloOrbs_ProfileDropdown",
                    width = "full",
                },
                {
                    type = "button",
                    name = L("Charger le profil selectionne"),
                    tooltip = L("Applique les reglages du profil selectionne sur ce personnage."),
                    func = function()
                        local target = DiabloOrbs._pendingProfileLoad or GetActiveProfileName()
                        if not ProfileExists(target) then
                            d("[DiabloOrbs] Profil introuvable : " .. tostring(target))
                            return
                        end
                        LoadProfile(target)
                        RefreshTheme(topLevelCtrl)
                        RefreshAllBars()
                        local panelCtrl = GetControl(panelId)
                        if panelCtrl and panelCtrl.RefreshPanel then
                            panelCtrl:RefreshPanel()
                        end
                        d("[DiabloOrbs] Profil charge : " .. target)
                    end,
                    width = "full",
                },
                {
                    type = "button",
                    name = L("Sauvegarder (ecraser le profil actif)"),
                    tooltip = L("Ecrase le profil actif avec vos reglages actuels."),
                    func = function()
                        local name = GetActiveProfileName()
                        if PROTECTED_PROFILE_NAMES[name] then
                            d("[DiabloOrbs] " .. L("P529"))
                            return
                        end
                        SaveCurrentToProfile(name)
                        local ddCtrl = DiabloOrbs_ProfileDropdown
                        if ddCtrl and ddCtrl.UpdateChoices then
                            local list = ListProfiles()
                            ddCtrl:UpdateChoices(list, list)
                        end
                        d("[DiabloOrbs] Profil '" .. name .. "' sauvegarde.")
                    end,
                    width = "full",
                },
                {
                    type = "editbox",
                    name = L("Sauvegarder sous... (nouveau nom)"),
                    tooltip = L("Cree un nouveau profil avec le nom saisi, et vos reglages actuels."),
                    getFunc = function() return DiabloOrbs._newProfileName or "" end,
                    setFunc = function(value) DiabloOrbs._newProfileName = value end,
                    isMultiline = false,
                    width = "full",
                },
                {
                    type = "button",
                    name = L("Creer ce nouveau profil"),
                    tooltip = L("Cree ou ecrase un profil avec le nom saisi ci-dessus."),
                    func = function()
                        local name = DiabloOrbs._newProfileName
                        if name == nil or name == "" then
                            d("[DiabloOrbs] " .. L("P531"))
                            return
                        end
                        if PROTECTED_PROFILE_NAMES[name] then
                            d("[DiabloOrbs] " .. L("P532"))
                            return
                        end
                        SaveCurrentToProfile(name)
                        if DiabloOrbs.charConfig then
                            DiabloOrbs.charConfig.activeProfile = name
                        end
                        DiabloOrbs._pendingProfileLoad = name
                        DiabloOrbs._newProfileName = ""
                        local ddCtrl = DiabloOrbs_ProfileDropdown
                        if ddCtrl and ddCtrl.UpdateChoices then
                            local list = ListProfiles()
                            ddCtrl:UpdateChoices(list, list)
                        end
                        d("[DiabloOrbs] Nouveau profil cree : " .. name)
                    end,
                    width = "full",
                },
                {
                    type = "button",
                    name = L("Supprimer le profil selectionne"),
                    tooltip = L("Supprime le profil selectionne ('D4 default' et 'Legacy default' sont proteges)."),
                    func = function()
                        local target = DiabloOrbs._pendingProfileLoad or GetActiveProfileName()
                        if PROTECTED_PROFILE_NAMES[target] then
                            d("[DiabloOrbs] " .. L("P530"))
                            return
                        end
                        DeleteProfile(target)
                        if DiabloOrbs.charConfig and DiabloOrbs.charConfig.activeProfile == target then
                            DiabloOrbs.charConfig.activeProfile = "D4 default"
                        end
                        DiabloOrbs._pendingProfileLoad = nil
                        local ddCtrl = DiabloOrbs_ProfileDropdown
                        if ddCtrl and ddCtrl.UpdateChoices then
                            local list = ListProfiles()
                            ddCtrl:UpdateChoices(list, list)
                        end
                        d("[DiabloOrbs] Profil supprime : " .. target)
                    end,
                    width = "full",
                },
            },
        },
        {
            type = "submenu",
            name = "Orbes D4",
            controls = {
            {
                type = "header",
                name = "Position et taille — reglages globaux",
            },
            {
                type = "description",
                text = "Ces reglages deplacent ou redimensionnent l'ensemble des orbes et socles.",
                width = "full",
            },
            {
                type = "slider",
                name = "Taille des orbes (px)",
                tooltip = "Ajuste la taille globale des orbes D4 et de leurs couches, avec une plage etendue. [ID: B01]",
                min = 110,
                max = 240,
                step = 1,
                getFunc = function() return SETTINGS.D4_ORB_SIZE or DEFAULT_SETTINGS.D4_ORB_SIZE end,
                setFunc = function(value)
                    SETTINGS.D4_ORB_SIZE = value
                    RefreshTheme(topLevelCtrl)
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_ORB_SIZE,
                width = "full",
            },
            {
                type = "slider",
                name = "Opacite globale orbes + socles (%)",
                tooltip = "Controle la transparence globale des orbes et de leurs socles. [ID: B02]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.D4_UNIFIED_ORB_ALPHA or DEFAULT_SETTINGS.D4_UNIFIED_ORB_ALPHA end,
                setFunc = function(value)
                    SETTINGS.D4_UNIFIED_ORB_ALPHA = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_UNIFIED_ORB_ALPHA,
                width = "full",
            },
            {
                type = "slider",
                name = "Luminosite des socles (preset)",
                tooltip = "Choisit une variante DDS plus ou moins eclaircie pour les socles sous les orbes. [ID: B03]",
                min = 0,
                max = 20,
                step = 1,
                getFunc = function() return SETTINGS.D4_ORB_BACKPLATE_PRESET or DEFAULT_SETTINGS.D4_ORB_BACKPLATE_PRESET end,
                setFunc = function(value)
                    SETTINGS.D4_ORB_BACKPLATE_PRESET = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_ORB_BACKPLATE_PRESET,
                width = "full",
            },
            {
                type = "slider",
                name = "Ecartement depuis le centre — Solo (px)",
                tooltip = "Distance des orbes depuis le centre de l'ecran en mode solo. [ID: B04]",
                min = 60,
                max = 400,
                step = 1,
                getFunc = function() return SETTINGS.D4_SOLO_ORB_INSET_X or DEFAULT_SETTINGS.D4_SOLO_ORB_INSET_X end,
                setFunc = function(value)
                    SETTINGS.D4_SOLO_ORB_INSET_X = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_SOLO_ORB_INSET_X,
                width = "half",
            },
            {
                type = "slider",
                name = "Ecartement depuis le centre — Dual (px)",
                tooltip = "Distance des orbes depuis le centre en mode dual (barre secondaire activee). [ID: B05]",
                min = 60,
                max = 400,
                step = 1,
                getFunc = function() return SETTINGS.D4_DUAL_ORB_INSET_X or DEFAULT_SETTINGS.D4_DUAL_ORB_INSET_X end,
                setFunc = function(value)
                    SETTINGS.D4_DUAL_ORB_INSET_X = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_DUAL_ORB_INSET_X,
                width = "half",
            },
            {
                type = "slider",
                name = "Position verticale des orbes — Solo (px)",
                tooltip = "Monte/descend les orbes et socles en mode solo (barre secondaire desactivee). [ID: B06]",
                min = -60,
                max = 60,
                step = 1,
                getFunc = function() return SETTINGS.D4_SOLO_ORB_OFFSET_Y or DEFAULT_SETTINGS.D4_SOLO_ORB_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.D4_SOLO_ORB_OFFSET_Y = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_SOLO_ORB_OFFSET_Y,
                width = "half",
            },
            {
                type = "slider",
                name = "Position verticale des orbes — Dual (px)",
                tooltip = "Monte/descend les orbes et socles en mode dual (barre secondaire activee). [ID: B07]",
                min = -60,
                max = 60,
                step = 1,
                getFunc = function() return SETTINGS.D4_DUAL_ORB_OFFSET_Y or DEFAULT_SETTINGS.D4_DUAL_ORB_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.D4_DUAL_ORB_OFFSET_Y = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_DUAL_ORB_OFFSET_Y,
                width = "half",
            },
            {
                type = "header",
                name = "Remplissage — decalage fin",
            },
            {
                type = "description",
                text = "Ajuste l'alignement du remplissage a l'interieur des orbes.",
                width = "full",
            },
            {
                type = "slider",
                name = "Ecart symetrique du remplissage (px)",
                tooltip = "Decale la couche de remplissage (smoke) a l'interieur des orbes : sante vers la gauche et combinee vers la droite du meme montant. [ID: B08]",
                min = -200,
                max = 200,
                step = 1,
                getFunc = function() return SETTINGS.D4_ORB_GLOBAL_GAP_X or DEFAULT_SETTINGS.D4_ORB_GLOBAL_GAP_X end,
                setFunc = function(value)
                    SETTINGS.D4_ORB_GLOBAL_GAP_X = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_ORB_GLOBAL_GAP_X,
                width = "full",
            },
            {
                type = "slider",
                name = "Decalage remplissage — Orbe Sante (px)",
                tooltip = "Decale uniquement la couche de remplissage (smoke) a l'interieur de l'orbe de vie sur l'axe X. [ID: B09]",
                min = -120,
                max = 120,
                step = 1,
                getFunc = function() return SETTINGS.D4_ORB_HEALTH_GAP_X or DEFAULT_SETTINGS.D4_ORB_HEALTH_GAP_X end,
                setFunc = function(value)
                    SETTINGS.D4_ORB_HEALTH_GAP_X = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_ORB_HEALTH_GAP_X,
                width = "full",
            },
            {
                type = "slider",
                name = "Decalage remplissage — Orbe combine (px)",
                tooltip = "Decale uniquement la couche de remplissage (smoke) a l'interieur de l'orbe combinee mana/endurance sur l'axe X. [ID: B10]",
                min = -120,
                max = 120,
                step = 1,
                getFunc = function() return SETTINGS.D4_ORB_COMBINED_GAP_X or DEFAULT_SETTINGS.D4_ORB_COMBINED_GAP_X end,
                setFunc = function(value)
                    SETTINGS.D4_ORB_COMBINED_GAP_X = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_ORB_COMBINED_GAP_X,
                width = "full",
            },
            {
                type = "header",
                name = "Couche 1 : Fond colore",
            },
            {
                type = "checkbox",
                name = "Afficher le fond colore",
                tooltip = "Affiche ou masque la couche de fond colore a l'interieur des orbes D4. [ID: B11]",
                getFunc = function() return SETTINGS.D4_BACKGROUND_LAYER_VISIBLE end,
                setFunc = function(value)
                    SETTINGS.D4_BACKGROUND_LAYER_VISIBLE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_VISIBLE,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 1 : opacite (%)",
                tooltip = "Regle l'opacite de la couche de fond colore des orbes D4. [ID: B12]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.D4_BACKGROUND_LAYER_ALPHA or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_ALPHA end,
                setFunc = function(value)
                    SETTINGS.D4_BACKGROUND_LAYER_ALPHA = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_ALPHA,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 1 : luminosite (%)",
                tooltip = "Ajuste la luminosite de D4OrbFill.dds, utilise ici comme base neutre de l'orbe. [ID: B13]",
                min = 0,
                max = 200,
                step = 5,
                getFunc = function() return SETTINGS.D4_BACKGROUND_LAYER_BRIGHTNESS or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_BRIGHTNESS end,
                setFunc = function(value)
                    SETTINGS.D4_BACKGROUND_LAYER_BRIGHTNESS = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_BRIGHTNESS,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 1 : largeur (%)",
                tooltip = "Ajuste la largeur de la couche de fond colore des orbes D4. [ID: B14]",
                min = 50,
                max = 150,
                step = 1,
                getFunc = function() return SETTINGS.D4_BACKGROUND_LAYER_WIDTH or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_WIDTH end,
                setFunc = function(value)
                    SETTINGS.D4_BACKGROUND_LAYER_WIDTH = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_WIDTH,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 1 : hauteur (%)",
                tooltip = "Ajuste la hauteur de la couche de fond colore des orbes D4. [ID: B15]",
                min = 50,
                max = 150,
                step = 1,
                getFunc = function() return SETTINGS.D4_BACKGROUND_LAYER_HEIGHT or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_HEIGHT end,
                setFunc = function(value)
                    SETTINGS.D4_BACKGROUND_LAYER_HEIGHT = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_HEIGHT,
                width = "half",
            },
            {
                type = "slider",
                name = "Intensite globale des couleurs (%)",
                tooltip = "Renforce ou adoucit la couleur du fond Smoke.dds pour toutes les ressources D4. [ID: B16]",
                min = 80,
                max = 200,
                step = 5,
                getFunc = function() return SETTINGS.D4_ORB_COLOR_BOOST or DEFAULT_SETTINGS.D4_ORB_COLOR_BOOST end,
                setFunc = function(value)
                    SETTINGS.D4_ORB_COLOR_BOOST = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_ORB_COLOR_BOOST,
                width = "full",
            },
            {
                type = "slider",
                name = "Luminosite globale du fond (%)",
                tooltip = "Regle la luminosite generale du fond colore Smoke.dds des orbes D4. [ID: B17]",
                min = 50,
                max = 200,
                step = 5,
                getFunc = function() return SETTINGS.D4_ORB_BRIGHTNESS or DEFAULT_SETTINGS.D4_ORB_BRIGHTNESS end,
                setFunc = function(value)
                    SETTINGS.D4_ORB_BRIGHTNESS = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_ORB_BRIGHTNESS,
                width = "full",
            },
            {
                type = "slider",
                name = "Couche 1 : offset X (px)",
                tooltip = "Decale la couche 1 entiere a gauche/droite, sans toucher l'ecart des orbes. [ID: B22]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_BACKGROUND_LAYER_OFFSET_X or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_OFFSET_X end,
                setFunc = function(value)
                    SETTINGS.D4_BACKGROUND_LAYER_OFFSET_X = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_OFFSET_X,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 1 : offset Y (px)",
                tooltip = "Decale la couche de fond colore vers le haut ou le bas. [ID: B23]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_BACKGROUND_LAYER_OFFSET_Y or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.D4_BACKGROUND_LAYER_OFFSET_Y = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_OFFSET_Y,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 1 : ecart entre les orbes (px)",
                tooltip = "Ajuste l'ecartement horizontal des orbes vie/combinee autour du centre en couche 1. [ID: B24]",
                min = -150,
                max = 150,
                step = 1,
                getFunc = function() return SETTINGS.D4_BACKGROUND_ORB_GAP_X or DEFAULT_SETTINGS.D4_BACKGROUND_ORB_GAP_X end,
                setFunc = function(value)
                    SETTINGS.D4_BACKGROUND_ORB_GAP_X = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_BACKGROUND_ORB_GAP_X,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 1 : offset global X (px)",
                tooltip = "Deplace les 3 instances de la couche de fond (sante + mana + endu) dans la meme direction. [ID: B25]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_BACKGROUND_LAYER_GLOBAL_X or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_GLOBAL_X end,
                setFunc = function(value)
                    SETTINGS.D4_BACKGROUND_LAYER_GLOBAL_X = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_GLOBAL_X,
                width = "half",
            },
            {
                type = "header",
                name = "Couche 2 : Smoke colore",
            },
            {
                type = "checkbox",
                name = "Afficher le smoke",
                tooltip = "Affiche ou masque la couche de remplissage Smoke des orbes D4. [ID: B26]",
                getFunc = function() return SETTINGS.D4_FILL_LAYER_VISIBLE end,
                setFunc = function(value)
                    SETTINGS.D4_FILL_LAYER_VISIBLE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_FILL_LAYER_VISIBLE,
                width = "half",
            },
            {
                type = "colorpicker",
                name = "Couche 2 : couleur Sante D4",
                tooltip = "Couleur du remplissage Smoke pour l'orbe de sante D4. [ID: B18]",
                getFunc = function() return SETTINGS.D4_HEALTH_COLOR_R or DEFAULT_SETTINGS.D4_HEALTH_COLOR_R, SETTINGS.D4_HEALTH_COLOR_G or DEFAULT_SETTINGS.D4_HEALTH_COLOR_G, SETTINGS.D4_HEALTH_COLOR_B or DEFAULT_SETTINGS.D4_HEALTH_COLOR_B, 1 end,
                setFunc = function(r, g, b)
                    SETTINGS.D4_HEALTH_COLOR_R = r
                    SETTINGS.D4_HEALTH_COLOR_G = g
                    SETTINGS.D4_HEALTH_COLOR_B = b
                    RefreshAllBars()
                end,
                default = function() return DEFAULT_SETTINGS.D4_HEALTH_COLOR_R, DEFAULT_SETTINGS.D4_HEALTH_COLOR_G, DEFAULT_SETTINGS.D4_HEALTH_COLOR_B, 1 end,
                width = "full",
            },
            {
                type = "colorpicker",
                name = "Couche 2 : couleur Magie D4",
                tooltip = "Couleur du remplissage Smoke pour l'orbe de magie D4. [ID: B19]",
                getFunc = function() return SETTINGS.D4_MAGICKA_COLOR_R or DEFAULT_SETTINGS.D4_MAGICKA_COLOR_R, SETTINGS.D4_MAGICKA_COLOR_G or DEFAULT_SETTINGS.D4_MAGICKA_COLOR_G, SETTINGS.D4_MAGICKA_COLOR_B or DEFAULT_SETTINGS.D4_MAGICKA_COLOR_B, 1 end,
                setFunc = function(r, g, b)
                    SETTINGS.D4_MAGICKA_COLOR_R = r
                    SETTINGS.D4_MAGICKA_COLOR_G = g
                    SETTINGS.D4_MAGICKA_COLOR_B = b
                    RefreshAllBars()
                end,
                default = function() return DEFAULT_SETTINGS.D4_MAGICKA_COLOR_R, DEFAULT_SETTINGS.D4_MAGICKA_COLOR_G, DEFAULT_SETTINGS.D4_MAGICKA_COLOR_B, 1 end,
                width = "full",
            },
            {
                type = "colorpicker",
                name = "Couche 2 : couleur Endurance D4",
                tooltip = "Couleur du remplissage Smoke pour l'orbe d'endurance D4. [ID: B20]",
                getFunc = function() return SETTINGS.D4_STAMINA_COLOR_R or DEFAULT_SETTINGS.D4_STAMINA_COLOR_R, SETTINGS.D4_STAMINA_COLOR_G or DEFAULT_SETTINGS.D4_STAMINA_COLOR_G, SETTINGS.D4_STAMINA_COLOR_B or DEFAULT_SETTINGS.D4_STAMINA_COLOR_B, 1 end,
                setFunc = function(r, g, b)
                    SETTINGS.D4_STAMINA_COLOR_R = r
                    SETTINGS.D4_STAMINA_COLOR_G = g
                    SETTINGS.D4_STAMINA_COLOR_B = b
                    RefreshAllBars()
                end,
                default = function() return DEFAULT_SETTINGS.D4_STAMINA_COLOR_R, DEFAULT_SETTINGS.D4_STAMINA_COLOR_G, DEFAULT_SETTINGS.D4_STAMINA_COLOR_B, 1 end,
                width = "full",
            },
            {
                type = "colorpicker",
                name = "Couche 2 : couleur Bouclier D4",
                tooltip = "Couleur du remplissage Smoke pour le bouclier D4. [ID: B21]",
                getFunc = function() return SETTINGS.D4_SHIELD_COLOR_R or DEFAULT_SETTINGS.D4_SHIELD_COLOR_R, SETTINGS.D4_SHIELD_COLOR_G or DEFAULT_SETTINGS.D4_SHIELD_COLOR_G, SETTINGS.D4_SHIELD_COLOR_B or DEFAULT_SETTINGS.D4_SHIELD_COLOR_B, 1 end,
                setFunc = function(r, g, b)
                    SETTINGS.D4_SHIELD_COLOR_R = r
                    SETTINGS.D4_SHIELD_COLOR_G = g
                    SETTINGS.D4_SHIELD_COLOR_B = b
                    RefreshAllBars()
                end,
                default = function() return DEFAULT_SETTINGS.D4_SHIELD_COLOR_R, DEFAULT_SETTINGS.D4_SHIELD_COLOR_G, DEFAULT_SETTINGS.D4_SHIELD_COLOR_B, 1 end,
                width = "full",
            },
            {
                type = "slider",
                name = "Couche 2 : opacite (%)",
                tooltip = "Regle l'opacite de la couche de remplissage Smoke des orbes D4. [ID: B27]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.D4_FILL_LAYER_ALPHA or DEFAULT_SETTINGS.D4_FILL_LAYER_ALPHA end,
                setFunc = function(value)
                    SETTINGS.D4_FILL_LAYER_ALPHA = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_FILL_LAYER_ALPHA,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 2 : taille (%)",
                tooltip = "Ajuste la taille de la couche de remplissage Smoke des orbes D4. [ID: B28]",
                min = 50,
                max = 150,
                step = 1,
                getFunc = function() return SETTINGS.D4_FILL_LAYER_SIZE or DEFAULT_SETTINGS.D4_FILL_LAYER_SIZE end,
                setFunc = function(value)
                    SETTINGS.D4_FILL_LAYER_SIZE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_FILL_LAYER_SIZE,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 2 : ecart centre (px)",
                tooltip = "Valeur positive = mana/endu s'ecartent du centre (smoke layer), valeur negative = elles se rapprochent. [ID: B29]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_FILL_LAYER_OFFSET_X or DEFAULT_SETTINGS.D4_FILL_LAYER_OFFSET_X end,
                setFunc = function(value)
                    SETTINGS.D4_FILL_LAYER_OFFSET_X = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_FILL_LAYER_OFFSET_X,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 2 : offset Y (px)",
                tooltip = "Decale la couche Smoke vers le haut ou le bas. [ID: B30]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_FILL_LAYER_OFFSET_Y or DEFAULT_SETTINGS.D4_FILL_LAYER_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.D4_FILL_LAYER_OFFSET_Y = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_FILL_LAYER_OFFSET_Y,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 2 : offset global X (px)",
                tooltip = "Deplace les 3 instances de la couche de remplissage (sante + mana + endu) dans la meme direction. [ID: B31]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_FILL_LAYER_GLOBAL_X or DEFAULT_SETTINGS.D4_FILL_LAYER_GLOBAL_X end,
                setFunc = function(value)
                    SETTINGS.D4_FILL_LAYER_GLOBAL_X = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_FILL_LAYER_GLOBAL_X,
                width = "half",
            },
            {
                type = "header",
                name = "Couche 3 : Lumiere additive",
            },
            {
                type = "checkbox",
                name = "Activer la lumiere additive",
                tooltip = "Superpose D4OrbBack2 en mode additif pour eclaircir l'orbe sans recolorer le fond. [ID: B32]",
                getFunc = function() return SETTINGS.D4_BACKGROUND_NEGATIVE == true end,
                setFunc = function(value)
                    SETTINGS.D4_BACKGROUND_NEGATIVE = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BACKGROUND_NEGATIVE,
                width = "half",
            },
            {
                type = "checkbox",
                name = "Appliquer sur l'endurance",
                tooltip = "Active le mode additif sur l'endurance de l'orbe combine D4 (sinon seule la magie est utilisee). [ID: B33]",
                getFunc = function() return SETTINGS.D4_BACKGROUND_ADDITIVE_STAMINA == true end,
                setFunc = function(value)
                    SETTINGS.D4_BACKGROUND_ADDITIVE_STAMINA = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_BACKGROUND_ADDITIVE_STAMINA,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 3 : intensite (%)",
                tooltip = "Intensite de l'overlay additif D4OrbBack2. [ID: B34]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.D4_BACKGROUND_EDGE_LIGHT_BOOST or DEFAULT_SETTINGS.D4_BACKGROUND_EDGE_LIGHT_BOOST end,
                setFunc = function(value)
                    SETTINGS.D4_BACKGROUND_EDGE_LIGHT_BOOST = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_BACKGROUND_EDGE_LIGHT_BOOST,
                width = "half",
                disabled = IsD4AdditiveDisabled,
            },
            {
                type = "slider",
                name = "Couche 3 : ecart entre les orbes (px)",
                tooltip = "Ajuste l'ecartement miroir des orbes de la couche additive (magie/endurance). [ID: B35]",
                min = -150,
                max = 150,
                step = 1,
                getFunc = function() return SETTINGS.D4_ADDITIVE_ORB_GAP_X or DEFAULT_SETTINGS.D4_ADDITIVE_ORB_GAP_X end,
                setFunc = function(value)
                    SETTINGS.D4_ADDITIVE_ORB_GAP_X = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_ADDITIVE_ORB_GAP_X,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 3 : offset X (px)",
                tooltip = "Translate les deux orbes de la couche additive ensemble a gauche/droite. [ID: B36]",
                min = -150,
                max = 150,
                step = 1,
                getFunc = function() return SETTINGS.D4_ADDITIVE_ORB_OFFSET_X or DEFAULT_SETTINGS.D4_ADDITIVE_ORB_OFFSET_X end,
                setFunc = function(value)
                    SETTINGS.D4_ADDITIVE_ORB_OFFSET_X = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_ADDITIVE_ORB_OFFSET_X,
                width = "half",
            },
            {
                type = "header",
                name = "Couche 4 : Glow",
            },
            {
                type = "checkbox",
                name = "Afficher le glow",
                tooltip = "Affiche ou masque la couche de glow lumineux des orbes D4. [ID: B37]",
                getFunc = function() return SETTINGS.D4_GLOW_LAYER_VISIBLE end,
                setFunc = function(value)
                    SETTINGS.D4_GLOW_LAYER_VISIBLE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_GLOW_LAYER_VISIBLE,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 4 : opacite (%)",
                tooltip = "Regle l'opacite de la couche de glow des orbes D4. [ID: B38]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.D4_GLOW_LAYER_ALPHA or DEFAULT_SETTINGS.D4_GLOW_LAYER_ALPHA end,
                setFunc = function(value)
                    SETTINGS.D4_GLOW_LAYER_ALPHA = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_GLOW_LAYER_ALPHA,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 4 : luminosite (%)",
                tooltip = "100 = normal, jusqu'a 500 pour tres lumineux. [ID: B39]",
                min = 0,
                max = 500,
                step = 5,
                getFunc = function() return SETTINGS.D4_GLOW_BRIGHTNESS or DEFAULT_SETTINGS.D4_GLOW_BRIGHTNESS end,
                setFunc = function(value)
                    SETTINGS.D4_GLOW_BRIGHTNESS = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_GLOW_BRIGHTNESS,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 4 : teinte couleur de l'orbe (%)",
                tooltip = "0 = glow blanc pur. 100 = glow teinte couleur de l'orbe. [ID: B40]",
                min = 0,
                max = 100,
                step = 5,
                getFunc = function() return SETTINGS.D4_GLOW_TINT or DEFAULT_SETTINGS.D4_GLOW_TINT end,
                setFunc = function(value)
                    SETTINGS.D4_GLOW_TINT = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_GLOW_TINT,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 4 : taille (%)",
                tooltip = "Ajuste la taille de la couche de glow des orbes D4. [ID: B41]",
                min = 50,
                max = 150,
                step = 1,
                getFunc = function() return SETTINGS.D4_GLOW_LAYER_SIZE or DEFAULT_SETTINGS.D4_GLOW_LAYER_SIZE end,
                setFunc = function(value)
                    SETTINGS.D4_GLOW_LAYER_SIZE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_GLOW_LAYER_SIZE,
                width = "half",
                hidden = HideD4LayerFineTuning,
            },
            {
                type = "slider",
                name = "Couche 4 : offset X (px)",
                tooltip = "Decale la couche de glow a gauche ou a droite. [ID: B42]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_GLOW_LAYER_OFFSET_X or DEFAULT_SETTINGS.D4_GLOW_LAYER_OFFSET_X end,
                setFunc = function(value)
                    SETTINGS.D4_GLOW_LAYER_OFFSET_X = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_GLOW_LAYER_OFFSET_X,
                width = "half",
                hidden = HideD4LayerFineTuning,
            },
            {
                type = "slider",
                name = "Couche 4 : offset Y (px)",
                tooltip = "Decale la couche de glow vers le haut ou le bas. [ID: B43]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_GLOW_LAYER_OFFSET_Y or DEFAULT_SETTINGS.D4_GLOW_LAYER_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.D4_GLOW_LAYER_OFFSET_Y = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_GLOW_LAYER_OFFSET_Y,
                width = "half",
                hidden = HideD4LayerFineTuning,
            },
            {
                type = "slider",
                name = "Intensite max du glow d'alerte D4 (%)",
                tooltip = "Intensite maximale de l'aureole lumineuse autour des orbes D4 lors d'une alerte ressource. [ID: D4_F02]",
                min = 10,
                max = 100,
                step = 5,
                getFunc = function() return zo_round((SETTINGS.D4_GLOW_MAX_ALPHA or DEFAULT_SETTINGS.D4_GLOW_MAX_ALPHA) * 100) end,
                setFunc = function(value)
                    SETTINGS.D4_GLOW_MAX_ALPHA = value / 100
                    RefreshAllBars()
                end,
                default = zo_round(DEFAULT_SETTINGS.D4_GLOW_MAX_ALPHA * 100),
                width = "full",
            },
            {
                type = "checkbox",
                name = "Glow interne strict D4 (sans debordement)",
                tooltip = "Active un glow contenu a l'interieur des orbes D4. Desactive = glow plus dramatique qui depasse un peu. [ID: D4_F09]",
                getFunc = function() return SETTINGS.D4_GLOW_INTERNAL_ONLY end,
                setFunc = function(value)
                    SETTINGS.D4_GLOW_INTERNAL_ONLY = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_GLOW_INTERNAL_ONLY,
                width = "full",
            },
            {
                type = "slider",
                name = "Ecart des glows D4 depuis le centre (px)",
                tooltip = "Eloigne ou rapproche les glows D4 de magicka et stamina par rapport au centre. [ID: D4_F10]",
                min = 10,
                max = 120,
                step = 1,
                getFunc = function() return SETTINGS.D4_GLOW_CENTER_GAP_X or DEFAULT_SETTINGS.D4_GLOW_CENTER_GAP_X end,
                setFunc = function(value)
                    SETTINGS.D4_GLOW_CENTER_GAP_X = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_GLOW_CENTER_GAP_X,
                width = "full",
                disabled = function() return SETTINGS.D4_GLOW_INTERNAL_ONLY end,
            },
            {
                type = "slider",
                name = "Offset vertical glow D4 (px)",
                tooltip = "Deplace verticalement les deux glows D4 en meme temps, en conservant le miroir parfait gauche/droite. [ID: D4_F11]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_GLOW_OFFSET_Y or DEFAULT_SETTINGS.D4_GLOW_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.D4_GLOW_OFFSET_Y = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_GLOW_OFFSET_Y,
                width = "full",
            },
            {
                type = "header",
                name = "Couche 5 : Ombre",
            },
            {
                type = "checkbox",
                name = "Afficher l'ombre",
                tooltip = "Affiche ou masque la couche d'ombre des orbes D4. [ID: B44]",
                getFunc = function() return SETTINGS.D4_SHADE_LAYER_VISIBLE end,
                setFunc = function(value)
                    SETTINGS.D4_SHADE_LAYER_VISIBLE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SHADE_LAYER_VISIBLE,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 5 : opacite (%)",
                tooltip = "Regle l'opacite de la couche d'ombre des orbes D4. [ID: B45]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.D4_SHADE_LAYER_ALPHA or DEFAULT_SETTINGS.D4_SHADE_LAYER_ALPHA end,
                setFunc = function(value)
                    SETTINGS.D4_SHADE_LAYER_ALPHA = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SHADE_LAYER_ALPHA,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 5 : taille (%)",
                tooltip = "Ajuste la taille de la couche d'ombre des orbes D4. [ID: B46]",
                min = 50,
                max = 150,
                step = 1,
                getFunc = function() return SETTINGS.D4_SHADE_LAYER_SIZE or DEFAULT_SETTINGS.D4_SHADE_LAYER_SIZE end,
                setFunc = function(value)
                    SETTINGS.D4_SHADE_LAYER_SIZE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SHADE_LAYER_SIZE,
                width = "half",
                hidden = HideD4LayerFineTuning,
            },
            {
                type = "slider",
                name = "Couche 5 : offset X (px)",
                tooltip = "Decale la couche d'ombre a gauche ou a droite. [ID: B47]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_SHADE_LAYER_OFFSET_X or DEFAULT_SETTINGS.D4_SHADE_LAYER_OFFSET_X end,
                setFunc = function(value)
                    SETTINGS.D4_SHADE_LAYER_OFFSET_X = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SHADE_LAYER_OFFSET_X,
                width = "half",
                hidden = HideD4LayerFineTuning,
            },
            {
                type = "slider",
                name = "Couche 5 : offset Y (px)",
                tooltip = "Decale la couche d'ombre vers le haut ou le bas. [ID: B48]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_SHADE_LAYER_OFFSET_Y or DEFAULT_SETTINGS.D4_SHADE_LAYER_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.D4_SHADE_LAYER_OFFSET_Y = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SHADE_LAYER_OFFSET_Y,
                width = "half",
                hidden = HideD4LayerFineTuning,
            },
            {
                type = "slider",
                name = "Couche 5 : ecart entre les orbes (px)",
                tooltip = "Ecarte la couche d'ombre : sante vers la gauche, mana/endu vers la droite. [ID: B49]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_SHADE_LAYER_GAP_X or DEFAULT_SETTINGS.D4_SHADE_LAYER_GAP_X end,
                setFunc = function(value)
                    SETTINGS.D4_SHADE_LAYER_GAP_X = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SHADE_LAYER_GAP_X,
                width = "half",
                hidden = HideD4LayerFineTuning,
            },
            {
                type = "header",
                name = "Couche 6 : Contour principal",
            },
            {
                type = "checkbox",
                name = "Afficher le contour",
                tooltip = "Affiche ou masque le contour principal des orbes D4. [ID: B50]",
                getFunc = function() return SETTINGS.D4_BORDER_LAYER_VISIBLE end,
                setFunc = function(value)
                    SETTINGS.D4_BORDER_LAYER_VISIBLE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_BORDER_LAYER_VISIBLE,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 6 : opacite (%)",
                tooltip = "Regle l'opacite du contour principal des orbes D4. [ID: B51]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.D4_BORDER_LAYER_ALPHA or DEFAULT_SETTINGS.D4_BORDER_LAYER_ALPHA end,
                setFunc = function(value)
                    SETTINGS.D4_BORDER_LAYER_ALPHA = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_BORDER_LAYER_ALPHA,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 6 : taille (%)",
                tooltip = "Ajuste la taille du contour principal des orbes D4. [ID: B52]",
                min = 50,
                max = 150,
                step = 1,
                getFunc = function() return SETTINGS.D4_BORDER_LAYER_SIZE or DEFAULT_SETTINGS.D4_BORDER_LAYER_SIZE end,
                setFunc = function(value)
                    SETTINGS.D4_BORDER_LAYER_SIZE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_BORDER_LAYER_SIZE,
                width = "half",
                hidden = HideD4LayerFineTuning,
            },
            {
                type = "slider",
                name = "Couche 6 : offset X (px)",
                tooltip = "Decale le contour principal a gauche ou a droite. [ID: B53]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_BORDER_LAYER_OFFSET_X or DEFAULT_SETTINGS.D4_BORDER_LAYER_OFFSET_X end,
                setFunc = function(value)
                    SETTINGS.D4_BORDER_LAYER_OFFSET_X = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_BORDER_LAYER_OFFSET_X,
                width = "half",
                hidden = HideD4LayerFineTuning,
            },
            {
                type = "slider",
                name = "Couche 6 : offset Y (px)",
                tooltip = "Decale le contour principal vers le haut ou le bas. [ID: B54]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_BORDER_LAYER_OFFSET_Y or DEFAULT_SETTINGS.D4_BORDER_LAYER_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.D4_BORDER_LAYER_OFFSET_Y = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_BORDER_LAYER_OFFSET_Y,
                width = "half",
                hidden = HideD4LayerFineTuning,
            },
            {
                type = "slider",
                name = "Couche 6 : ecart entre les orbes (px)",
                tooltip = "Ecarte la couche de contour : sante vers la gauche, mana/endu vers la droite. [ID: B55]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_BORDER_LAYER_GAP_X or DEFAULT_SETTINGS.D4_BORDER_LAYER_GAP_X end,
                setFunc = function(value)
                    SETTINGS.D4_BORDER_LAYER_GAP_X = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_BORDER_LAYER_GAP_X,
                width = "half",
                hidden = HideD4LayerFineTuning,
            },
            {
                type = "header",
                name = "Couche 7 : Trait de separation",
            },
            {
                type = "checkbox",
                name = "Afficher le trait",
                tooltip = "Affiche un trait simple entre mana et endurance. [ID: B56]",
                getFunc = function() return SETTINGS.D4_SEAM_VISIBLE ~= false end,
                setFunc = function(value)
                    SETTINGS.D4_SEAM_VISIBLE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SEAM_VISIBLE,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 7 : opacite (%)",
                tooltip = "Regle l'opacite du trait de separation mana/endurance. [ID: B57]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.D4_SEAM_ALPHA or DEFAULT_SETTINGS.D4_SEAM_ALPHA end,
                setFunc = function(value)
                    SETTINGS.D4_SEAM_ALPHA = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SEAM_ALPHA,
                width = "half",
                disabled = IsD4SeamStylingDisabled,
            },
            {
                type = "colorpicker",
                name = "Couche 7 : couleur",
                tooltip = "Choisit la couleur du trait entre mana et endurance. [ID: B58]",
                getFunc = function()
                    return SETTINGS.D4_SEAM_COLOR_R or DEFAULT_SETTINGS.D4_SEAM_COLOR_R,
                           SETTINGS.D4_SEAM_COLOR_G or DEFAULT_SETTINGS.D4_SEAM_COLOR_G,
                           SETTINGS.D4_SEAM_COLOR_B or DEFAULT_SETTINGS.D4_SEAM_COLOR_B,
                           1
                end,
                setFunc = function(r, g, b)
                    SETTINGS.D4_SEAM_COLOR_R = r
                    SETTINGS.D4_SEAM_COLOR_G = g
                    SETTINGS.D4_SEAM_COLOR_B = b
                    RefreshAllBars()
                end,
                default = {
                    DEFAULT_SETTINGS.D4_SEAM_COLOR_R,
                    DEFAULT_SETTINGS.D4_SEAM_COLOR_G,
                    DEFAULT_SETTINGS.D4_SEAM_COLOR_B,
                },
                width = "half",
                disabled = IsD4SeamStylingDisabled,
            },
            {
                type = "slider",
                name = "Couche 7 : taille (% de l'orbe)",
                tooltip = "Taille globale du separateur en pourcentage de la taille de l'orbe. [ID: B59]",
                min = 10,
                max = 200,
                step = 5,
                getFunc = function() return SETTINGS.D4_SEAM_SIZE or DEFAULT_SETTINGS.D4_SEAM_SIZE end,
                setFunc = function(value)
                    SETTINGS.D4_SEAM_SIZE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SEAM_SIZE,
                width = "half",
                disabled = IsD4SeamStylingDisabled,
            },
            {
                type = "slider",
                name = "Couche 7 : largeur (px)",
                tooltip = "Largeur du trait de separation en pixels. [ID: B59b]",
                min = 1,
                max = 500,
                step = 1,
                getFunc = function() return SETTINGS.D4_SEAM_WIDTH or DEFAULT_SETTINGS.D4_SEAM_WIDTH end,
                setFunc = function(value)
                    SETTINGS.D4_SEAM_WIDTH = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SEAM_WIDTH,
                width = "half",
                disabled = IsD4SeamStylingDisabled,
            },
            {
                type = "slider",
                name = "Couche 7 : hauteur (% de l'orbe)",
                tooltip = "Hauteur du trait de separation en pourcentage de la taille de l'orbe. [ID: B60]",
                min = 10,
                max = 200,
                step = 1,
                getFunc = function() return SETTINGS.D4_SEAM_HEIGHT or DEFAULT_SETTINGS.D4_SEAM_HEIGHT end,
                setFunc = function(value)
                    SETTINGS.D4_SEAM_HEIGHT = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SEAM_HEIGHT,
                width = "half",
                disabled = IsD4SeamStylingDisabled,
            },
            {
                type = "slider",
                name = "Couche 7 : luminosite (%)",
                tooltip = "Ajuste la luminosite du trait de separation. [ID: B61]",
                min = 0,
                max = 200,
                step = 5,
                getFunc = function() return SETTINGS.D4_SEAM_BRIGHTNESS or DEFAULT_SETTINGS.D4_SEAM_BRIGHTNESS end,
                setFunc = function(value)
                    SETTINGS.D4_SEAM_BRIGHTNESS = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SEAM_BRIGHTNESS,
                width = "half",
                disabled = IsD4SeamStylingDisabled,
            },
            {
                type = "checkbox",
                name = "Couche 7 : mode additif",
                tooltip = "Active un rendu plus lumineux de la separation (utile sur fonds sombres). [ID: B62]",
                getFunc = function() return SETTINGS.D4_SEAM_ADDITIVE ~= false end,
                setFunc = function(value)
                    SETTINGS.D4_SEAM_ADDITIVE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SEAM_ADDITIVE,
                width = "half",
                disabled = IsD4SeamStylingDisabled,
            },
            {
                type = "slider",
                name = "Couche 7 : offset X (px)",
                tooltip = "Decale le trait de separation a gauche ou a droite. [ID: B63]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_SEAM_OFFSET_X or DEFAULT_SETTINGS.D4_SEAM_OFFSET_X end,
                setFunc = function(value)
                    SETTINGS.D4_SEAM_OFFSET_X = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SEAM_OFFSET_X,
                width = "half",
                disabled = IsD4SeamStylingDisabled,
            },
            {
                type = "slider",
                name = "Couche 7 : offset Y (px)",
                tooltip = "Decale le trait de separation vers le haut ou le bas. [ID: B64]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_SEAM_OFFSET_Y or DEFAULT_SETTINGS.D4_SEAM_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.D4_SEAM_OFFSET_Y = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SEAM_OFFSET_Y,
                width = "half",
                disabled = IsD4SeamStylingDisabled,
            },
            {
                type = "header",
                name = "Couche 8 : Surcouche contour",
            },
            {
                type = "checkbox",
                name = "Afficher la surcouche",
                tooltip = "Affiche ou masque la surcouche contour des orbes D4. [ID: B65]",
                getFunc = function() return SETTINGS.D4_OVERLAY_LAYER_VISIBLE end,
                setFunc = function(value)
                    SETTINGS.D4_OVERLAY_LAYER_VISIBLE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_OVERLAY_LAYER_VISIBLE,
                width = "half",
            },
            {
                type = "slider",
                name = "Couche 8 : opacite (%)",
                tooltip = "Regle l'opacite de la surcouche contour des orbes D4. [ID: B66]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.D4_OVERLAY_LAYER_ALPHA or DEFAULT_SETTINGS.D4_OVERLAY_LAYER_ALPHA end,
                setFunc = function(value)
                    SETTINGS.D4_OVERLAY_LAYER_ALPHA = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_OVERLAY_LAYER_ALPHA,
                width = "half",
                disabled = IsD4OverlayStylingDisabled,
            },
            {
                type = "slider",
                name = "Couche 8 : luminosite (%)",
                tooltip = "100 = normal. Monter pour plus de luminosite, baisser pour assombrir. [ID: B67]",
                min = 0,
                max = 200,
                step = 5,
                getFunc = function() return SETTINGS.D4_OVERLAY_BRIGHTNESS or DEFAULT_SETTINGS.D4_OVERLAY_BRIGHTNESS end,
                setFunc = function(value)
                    SETTINGS.D4_OVERLAY_BRIGHTNESS = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_OVERLAY_BRIGHTNESS,
                width = "half",
                disabled = IsD4OverlayStylingDisabled,
            },
            {
                type = "slider",
                name = "Couche 8 : contraste (%)",
                tooltip = "0 = mode normal (alpha). 100 = mode additif (plus de punch et luminosite sur fond sombre). [ID: B68]",
                min = 0,
                max = 100,
                step = 5,
                getFunc = function() return SETTINGS.D4_OVERLAY_CONTRAST or DEFAULT_SETTINGS.D4_OVERLAY_CONTRAST end,
                setFunc = function(value)
                    SETTINGS.D4_OVERLAY_CONTRAST = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_OVERLAY_CONTRAST,
                width = "half",
                disabled = IsD4OverlayStylingDisabled,
            },
            {
                type = "slider",
                name = "Couche 8 : taille (%)",
                tooltip = "Ajuste la taille de la surcouche contour des orbes D4. [ID: B69]",
                min = 50,
                max = 150,
                step = 1,
                getFunc = function() return SETTINGS.D4_OVERLAY_LAYER_SIZE or DEFAULT_SETTINGS.D4_OVERLAY_LAYER_SIZE end,
                setFunc = function(value)
                    SETTINGS.D4_OVERLAY_LAYER_SIZE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_OVERLAY_LAYER_SIZE,
                width = "half",
                hidden = HideD4LayerFineTuning,
                disabled = IsD4OverlayStylingDisabled,
            },
            {
                type = "slider",
                name = "Couche 8 : offset X (px)",
                tooltip = "Decale la surcouche contour a gauche ou a droite. [ID: B70]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_OVERLAY_LAYER_OFFSET_X or DEFAULT_SETTINGS.D4_OVERLAY_LAYER_OFFSET_X end,
                setFunc = function(value)
                    SETTINGS.D4_OVERLAY_LAYER_OFFSET_X = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_OVERLAY_LAYER_OFFSET_X,
                width = "half",
                hidden = HideD4LayerFineTuning,
                disabled = IsD4OverlayStylingDisabled,
            },
            {
                type = "slider",
                name = "Couche 8 : offset Y (px)",
                tooltip = "Decale la surcouche contour vers le haut ou le bas. [ID: B71]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_OVERLAY_LAYER_OFFSET_Y or DEFAULT_SETTINGS.D4_OVERLAY_LAYER_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.D4_OVERLAY_LAYER_OFFSET_Y = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_OVERLAY_LAYER_OFFSET_Y,
                width = "half",
                hidden = HideD4LayerFineTuning,
                disabled = IsD4OverlayStylingDisabled,
            },
            {
                type = "slider",
                name = "Couche 8 : ecart entre les orbes (px)",
                tooltip = "Ecarte la couche d'overlay : sante vers la gauche, mana/endu vers la droite. [ID: B72]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_OVERLAY_LAYER_GAP_X or DEFAULT_SETTINGS.D4_OVERLAY_LAYER_GAP_X end,
                setFunc = function(value)
                    SETTINGS.D4_OVERLAY_LAYER_GAP_X = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_OVERLAY_LAYER_GAP_X,
                width = "half",
                hidden = HideD4LayerFineTuning,
                disabled = IsD4OverlayStylingDisabled,
            },
            },
        },
        {
            type = "submenu",
            name = "Orbes Legacy",
            controls = {
            {
                type = "header",
                name = "Position et taille",
            },
            {
                type = "slider",
                name = "Taille globale des orbes (%)",
                tooltip = "Redimensionne homothetiquement tous les calques des orbes Legacy ensemble. [ID: B75]",
                min = 70,
                max = 180,
                step = 1,
                getFunc = function() return SETTINGS.LEGACY_ORB_LAYER_GLOBAL_SCALE or DEFAULT_SETTINGS.LEGACY_ORB_LAYER_GLOBAL_SCALE end,
                setFunc = function(value)
                    SETTINGS.LEGACY_ORB_LAYER_GLOBAL_SCALE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.LEGACY_ORB_LAYER_GLOBAL_SCALE,
                width = "full",
            },
            -- Solo
            {
                type = "header",
                name = "Position orbes — Solo",
            },
            {
                type = "slider",
                name = "Decalage vertical (px)",
                tooltip = "Deplace les orbes vers le haut ou le bas en mode solo. [ID: B77s]",
                min = -100, max = 100, step = 1,
                getFunc = function() return SETTINGS.LEGACY_SOLO_ORB_OFFSET_Y or DEFAULT_SETTINGS.LEGACY_SOLO_ORB_OFFSET_Y end,
                setFunc = function(value) SETTINGS.LEGACY_SOLO_ORB_OFFSET_Y = value ; RefreshTheme(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_SOLO_ORB_OFFSET_Y,
                width = "half",
            },
            {
                type = "slider",
                name = "Ecartement horizontal (px)",
                tooltip = "Ecarte les orbes par rapport a la barre en mode solo. [ID: B78s]",
                min = -50, max = 150, step = 1,
                getFunc = function() return SETTINGS.LEGACY_SOLO_ORB_OFFSET_X or DEFAULT_SETTINGS.LEGACY_SOLO_ORB_OFFSET_X end,
                setFunc = function(value) SETTINGS.LEGACY_SOLO_ORB_OFFSET_X = value ; RefreshTheme(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_SOLO_ORB_OFFSET_X,
                width = "half",
            },
            -- Dual
            {
                type = "header",
                name = "Position orbes — Dual",
            },
            {
                type = "slider",
                name = "Decalage vertical (px)",
                tooltip = "Deplace les orbes vers le haut ou le bas en mode dual. [ID: B77d]",
                min = -100, max = 100, step = 1,
                getFunc = function() return SETTINGS.LEGACY_DUAL_ORB_OFFSET_Y or DEFAULT_SETTINGS.LEGACY_DUAL_ORB_OFFSET_Y end,
                setFunc = function(value) SETTINGS.LEGACY_DUAL_ORB_OFFSET_Y = value ; RefreshTheme(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_DUAL_ORB_OFFSET_Y,
                width = "half",
            },
            {
                type = "slider",
                name = "Ecartement horizontal (px)",
                tooltip = "Ecarte les orbes par rapport a la barre en mode dual. [ID: B78d]",
                min = -50, max = 150, step = 1,
                getFunc = function() return SETTINGS.LEGACY_DUAL_ORB_OFFSET_X or DEFAULT_SETTINGS.LEGACY_DUAL_ORB_OFFSET_X end,
                setFunc = function(value) SETTINGS.LEGACY_DUAL_ORB_OFFSET_X = value ; RefreshTheme(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_DUAL_ORB_OFFSET_X,
                width = "half",
            },
            {
                type = "slider",
                name = L("Cadre ornemental : taille (px)"),
                tooltip = "Taille du cadre circulaire des orbes Legacy. 166 = valeur XML par defaut. Reduire pour eviter le depassement quand les orbes sont agrandis. [ID: B93]",
                min = 100,
                max = 200,
                step = 1,
                getFunc = function() return SETTINGS.LEGACY_BORDER_SIZE or DEFAULT_SETTINGS.LEGACY_BORDER_SIZE end,
                setFunc = function(value)
                    SETTINGS.LEGACY_BORDER_SIZE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.LEGACY_BORDER_SIZE,
                width = "full",
            },
            {
                type = "slider",
                name = L("Ombre interne : taille (px)"),
                tooltip = "Taille de la couche d'ombre interne (Shade.dds) des orbes Legacy. 150 = valeur par defaut. [ID: B94]",
                min = 80,
                max = 200,
                step = 1,
                getFunc = function() return SETTINGS.LEGACY_SHADE_SIZE or DEFAULT_SETTINGS.LEGACY_SHADE_SIZE end,
                setFunc = function(value)
                    SETTINGS.LEGACY_SHADE_SIZE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.LEGACY_SHADE_SIZE,
                width = "full",
            },
            {
                type = "slider",
                name = L("Separateur central : taille (px)"),
                tooltip = "Taille du separateur entre Magie et Endurance (Split.dds). 166 = valeur par defaut. [ID: B95]",
                min = 80,
                max = 200,
                step = 1,
                getFunc = function() return SETTINGS.LEGACY_SPLIT_SIZE or DEFAULT_SETTINGS.LEGACY_SPLIT_SIZE end,
                setFunc = function(value)
                    SETTINGS.LEGACY_SPLIT_SIZE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.LEGACY_SPLIT_SIZE,
                width = "full",
            },
            {
                type = "slider",
                name = L("Glow : taille (px)"),
                tooltip = "Taille du glow des orbes Legacy. 150 = valeur par defaut. [ID: B96]",
                min = 80,
                max = 300,
                step = 1,
                getFunc = function() return SETTINGS.LEGACY_GLOW_SIZE or DEFAULT_SETTINGS.LEGACY_GLOW_SIZE end,
                setFunc = function(value)
                    SETTINGS.LEGACY_GLOW_SIZE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.LEGACY_GLOW_SIZE,
                width = "full",
            },
            {
                type = "header",
                name = "Apparence",
            },
            {
                type = "slider",
                name = "Transparence du smoke (%)",
                tooltip = "Ajuste l'opacite des effets de fumee sur les orbes de ressources. [ID: B76]",
                min = 10,
                max = 100,
                step = 5,
                getFunc = function() return zo_round(SETTINGS.SMOKE_ALPHA * 100) end,
                setFunc = function(value)
                    SETTINGS.SMOKE_ALPHA = value / 100
                    RefreshAllBars()
                end,
                default = zo_round(DEFAULT_SETTINGS.SMOKE_ALPHA * 100),
                width = "full",
            },
            {
                type = "slider",
                name = "Luminosite du fond (%)",
                tooltip = "0% = fond sombre. 100% = fond plus lumineux. [ID: B77]",
                min = 0,
                max = 100,
                step = 5,
                getFunc = function() return SETTINGS.SMOKEBG_BRIGHTNESS end,
                setFunc = function(value)
                    SETTINGS.SMOKEBG_BRIGHTNESS = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.SMOKEBG_BRIGHTNESS,
                width = "full",
            },
            {
                type = "slider",
                name = "Intensite globale des couleurs (%)",
                tooltip = "Boost global des couleurs des orbes. 100% = normal, au-dessus = plus vif. [ID: B78]",
                min = 80,
                max = 200,
                step = 5,
                getFunc = function() return SETTINGS.ORB_COLOR_BOOST end,
                setFunc = function(value)
                    SETTINGS.ORB_COLOR_BOOST = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.ORB_COLOR_BOOST,
                width = "full",
            },
            {
                type = "slider",
                name = "Luminosite globale (%)",
                tooltip = "Ajuste la luminosite globale du remplissage des orbes. 100% = normal. [ID: B79]",
                min = 50,
                max = 200,
                step = 5,
                getFunc = function() return SETTINGS.ORB_BRIGHTNESS or DEFAULT_SETTINGS.ORB_BRIGHTNESS end,
                setFunc = function(value)
                    SETTINGS.ORB_BRIGHTNESS = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.ORB_BRIGHTNESS,
                width = "full",
            },
            {
                type = "checkbox",
                name = "Activer couche de fond teintee",
                tooltip = "Ajoute une couche de couleur derriere le remplissage des orbes principaux. [ID: B80]",
                getFunc = function() return SETTINGS.ORB_TINT_LAYER_ENABLED == true end,
                setFunc = function(value)
                    SETTINGS.ORB_TINT_LAYER_ENABLED = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.ORB_TINT_LAYER_ENABLED,
                width = "full",
            },
            {
                type = "slider",
                name = "Opacite couche teintee (%)",
                tooltip = "Regle l'opacite de la couche de couleur supplementaire derriere les orbes. [ID: B81]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.ORB_TINT_LAYER_ALPHA or DEFAULT_SETTINGS.ORB_TINT_LAYER_ALPHA end,
                setFunc = function(value)
                    SETTINGS.ORB_TINT_LAYER_ALPHA = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.ORB_TINT_LAYER_ALPHA,
                width = "full",
                disabled = function() return SETTINGS.ORB_TINT_LAYER_ENABLED ~= true end,
            },
            {
                type = "colorpicker",
                name = "Couleur couche teintee",
                tooltip = "Choisit la couleur de la couche de fond ajoutee aux orbes. [ID: B82]",
                getFunc = function()
                    return SETTINGS.ORB_TINT_LAYER_COLOR_R or DEFAULT_SETTINGS.ORB_TINT_LAYER_COLOR_R,
                           SETTINGS.ORB_TINT_LAYER_COLOR_G or DEFAULT_SETTINGS.ORB_TINT_LAYER_COLOR_G,
                           SETTINGS.ORB_TINT_LAYER_COLOR_B or DEFAULT_SETTINGS.ORB_TINT_LAYER_COLOR_B,
                           1
                end,
                setFunc = function(r, g, b)
                    SETTINGS.ORB_TINT_LAYER_COLOR_R = r
                    SETTINGS.ORB_TINT_LAYER_COLOR_G = g
                    SETTINGS.ORB_TINT_LAYER_COLOR_B = b
                    RefreshAllBars()
                end,
                default = {
                    DEFAULT_SETTINGS.ORB_TINT_LAYER_COLOR_R,
                    DEFAULT_SETTINGS.ORB_TINT_LAYER_COLOR_G,
                    DEFAULT_SETTINGS.ORB_TINT_LAYER_COLOR_B,
                },
                width = "full",
                disabled = function() return SETTINGS.ORB_TINT_LAYER_ENABLED ~= true end,
            },
            {
                type = "slider",
                name = "Intensite du contour sombre (%)",
                tooltip = "0% = contour sombre invisible. 100% = contour sombre complet. [ID: B83]",
                min = 0,
                max = 100,
                step = 5,
                getFunc = function() return zo_round(SETTINGS.SHADE_ALPHA * 100) end,
                setFunc = function(value)
                    SETTINGS.SHADE_ALPHA = value / 100
                    RefreshAllBars()
                end,
                default = zo_round(DEFAULT_SETTINGS.SHADE_ALPHA * 100),
                width = "full",
            },
            {
                type = "slider",
                name = "Opacite du cadre circulaire (%)",
                tooltip = "Ajuste l'opacite du cadre ornemental des orbes. [ID: B84]",
                min = 0,
                max = 100,
                step = 5,
                getFunc = function() return zo_round(SETTINGS.BORDER_ALPHA * 100) end,
                setFunc = function(value)
                    SETTINGS.BORDER_ALPHA = value / 100
                    RefreshAllBars()
                end,
                default = zo_round(DEFAULT_SETTINGS.BORDER_ALPHA * 100),
                width = "full",
            },
            {
                type = "slider",
                name = "Opacite du separateur double barre (%)",
                tooltip = "Ajuste l'opacite de la ligne de separation entre Magie et Endurance. [ID: B85]",
                min = 0,
                max = 100,
                step = 5,
                getFunc = function() return zo_round(SETTINGS.SPLIT_ALPHA * 100) end,
                setFunc = function(value)
                    SETTINGS.SPLIT_ALPHA = value / 100
                    RefreshAllBars()
                end,
                default = zo_round(DEFAULT_SETTINGS.SPLIT_ALPHA * 100),
                width = "full",
            },
            {
                type = "header",
                name = "Couleurs",
            },
            {
                type = "colorpicker",
                name = "Couleur Sante (Legacy)",
                tooltip = "Couleur de remplissage de l'orbe de sante en theme Legacy. [ID: B89]",
                getFunc = function() return SETTINGS.HEALTH_COLOR_R, SETTINGS.HEALTH_COLOR_G, SETTINGS.HEALTH_COLOR_B, 1 end,
                setFunc = function(r, g, b, a)
                    SETTINGS.HEALTH_COLOR_R = r
                    SETTINGS.HEALTH_COLOR_G = g
                    SETTINGS.HEALTH_COLOR_B = b
                    RefreshAllBars()
                end,
                default = function() return DEFAULT_SETTINGS.HEALTH_COLOR_R, DEFAULT_SETTINGS.HEALTH_COLOR_G, DEFAULT_SETTINGS.HEALTH_COLOR_B, 1 end,
                width = "full",
            },
            {
                type = "colorpicker",
                name = "Couleur Magie (Legacy)",
                tooltip = "Couleur de remplissage de l'orbe de magie en theme Legacy. [ID: B90]",
                getFunc = function() return SETTINGS.MAGICKA_COLOR_R, SETTINGS.MAGICKA_COLOR_G, SETTINGS.MAGICKA_COLOR_B, 1 end,
                setFunc = function(r, g, b, a)
                    SETTINGS.MAGICKA_COLOR_R = r
                    SETTINGS.MAGICKA_COLOR_G = g
                    SETTINGS.MAGICKA_COLOR_B = b
                    RefreshAllBars()
                end,
                default = function() return DEFAULT_SETTINGS.MAGICKA_COLOR_R, DEFAULT_SETTINGS.MAGICKA_COLOR_G, DEFAULT_SETTINGS.MAGICKA_COLOR_B, 1 end,
                width = "full",
            },
            {
                type = "colorpicker",
                name = "Couleur Endurance (Legacy)",
                tooltip = "Couleur de remplissage de l'orbe d'endurance en theme Legacy. [ID: B91]",
                getFunc = function() return SETTINGS.STAMINA_COLOR_R, SETTINGS.STAMINA_COLOR_G, SETTINGS.STAMINA_COLOR_B, 1 end,
                setFunc = function(r, g, b, a)
                    SETTINGS.STAMINA_COLOR_R = r
                    SETTINGS.STAMINA_COLOR_G = g
                    SETTINGS.STAMINA_COLOR_B = b
                    RefreshAllBars()
                end,
                default = function() return DEFAULT_SETTINGS.STAMINA_COLOR_R, DEFAULT_SETTINGS.STAMINA_COLOR_G, DEFAULT_SETTINGS.STAMINA_COLOR_B, 1 end,
                width = "full",
            },
            -- Decorations Angel / Demon (Legacy uniquement)
            {
                type = "header",
                name = L("Decorations (Angel / Demon)"),
            },
            {
                type = "checkbox",
                name = L("Afficher les decorations (Angel / Demon)"),
                tooltip = "Affiche ou masque les images decoratives Angel et Demon de chaque cote des orbes (Legacy uniquement). [ID: LD10]",
                getFunc = function() return SETTINGS.LEGACY_DECO_VISIBLE ~= false end,
                setFunc = function(v)
                    SETTINGS.LEGACY_DECO_VISIBLE = v
                    ApplyThemeTexturesToControls(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.LEGACY_DECO_VISIBLE,
                width = "full",
            },
            {
                type = "checkbox",
                name = L("Premier plan (devant les orbes)"),
                tooltip = "Affiche les decorations devant tous les elements. Desactive = arriere-plan. [ID: LD14]",
                getFunc = function() return SETTINGS.LEGACY_DECO_FOREGROUND == true end,
                setFunc = function(v)
                    SETTINGS.LEGACY_DECO_FOREGROUND = v
                    ApplyThemeTexturesToControls(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.LEGACY_DECO_FOREGROUND,
                width = "half",
                disabled = function() return IsCurrentThemeD4() or SETTINGS.LEGACY_DECO_VISIBLE == false end,
            },
            {
                type = "checkbox",
                name = L("Inverser les cotes (Angel/Demon)"),
                tooltip = "Echange les positions : Angel a gauche, Demon a droite. [ID: LD15]",
                getFunc = function() return SETTINGS.LEGACY_DECO_MIRROR == true end,
                setFunc = function(v)
                    SETTINGS.LEGACY_DECO_MIRROR = v
                    ApplyThemeTexturesToControls(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.LEGACY_DECO_MIRROR,
                width = "half",
                disabled = function() return IsCurrentThemeD4() or SETTINGS.LEGACY_DECO_VISIBLE == false end,
            },
            {
                type = "slider",
                name = L("Taille de base (px)"),
                tooltip = "Taille de reference des images Angel et Demon. La largeur et hauteur sont des pourcentages de cette valeur. [ID: LD11]",
                min = 50,
                max = 600,
                step = 1,
                getFunc = function() return SETTINGS.LEGACY_DECO_SIZE or DEFAULT_SETTINGS.LEGACY_DECO_SIZE end,
                setFunc = function(v)
                    SETTINGS.LEGACY_DECO_SIZE = v
                    ApplyThemeTexturesToControls(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.LEGACY_DECO_SIZE,
                width = "full",
                disabled = function() return IsCurrentThemeD4() or SETTINGS.LEGACY_DECO_VISIBLE == false end,
            },
            {
                type = "slider",
                name = L("Largeur (%)"),
                tooltip = "Largeur en % de la taille de base. [ID: LD16]",
                min = 10,
                max = 300,
                step = 1,
                getFunc = function() return SETTINGS.LEGACY_DECO_WIDTH or DEFAULT_SETTINGS.LEGACY_DECO_WIDTH end,
                setFunc = function(v)
                    SETTINGS.LEGACY_DECO_WIDTH = v
                    ApplyThemeTexturesToControls(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.LEGACY_DECO_WIDTH,
                width = "half",
                disabled = function() return IsCurrentThemeD4() or SETTINGS.LEGACY_DECO_VISIBLE == false end,
            },
            {
                type = "slider",
                name = L("Hauteur (%)"),
                tooltip = "Hauteur en % de la taille de base. [ID: LD17]",
                min = 10,
                max = 300,
                step = 1,
                getFunc = function() return SETTINGS.LEGACY_DECO_HEIGHT or DEFAULT_SETTINGS.LEGACY_DECO_HEIGHT end,
                setFunc = function(v)
                    SETTINGS.LEGACY_DECO_HEIGHT = v
                    ApplyThemeTexturesToControls(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.LEGACY_DECO_HEIGHT,
                width = "half",
                disabled = function() return IsCurrentThemeD4() or SETTINGS.LEGACY_DECO_VISIBLE == false end,
            },
            {
                type = "slider",
                name = L("Ecartement depuis le centre (px)"),
                tooltip = "Distance horizontale entre le centre de l'ecran et chaque image. 0 = centre. [ID: LD12]",
                min = 0,
                max = 600,
                step = 1,
                getFunc = function() return SETTINGS.LEGACY_DECO_GAP_X or DEFAULT_SETTINGS.LEGACY_DECO_GAP_X end,
                setFunc = function(v)
                    SETTINGS.LEGACY_DECO_GAP_X = v
                    ApplyThemeTexturesToControls(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.LEGACY_DECO_GAP_X,
                width = "half",
                disabled = function() return IsCurrentThemeD4() or SETTINGS.LEGACY_DECO_VISIBLE == false end,
            },
            {
                type = "slider",
                name = L("Decalage vertical (px)"),
                tooltip = "Deplace les decorations vers le haut (negatif) ou le bas (positif). [ID: LD13]",
                min = -200,
                max = 200,
                step = 1,
                getFunc = function() return SETTINGS.LEGACY_DECO_OFFSET_Y or DEFAULT_SETTINGS.LEGACY_DECO_OFFSET_Y end,
                setFunc = function(v)
                    SETTINGS.LEGACY_DECO_OFFSET_Y = v
                    ApplyThemeTexturesToControls(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.LEGACY_DECO_OFFSET_Y,
                width = "half",
                disabled = function() return IsCurrentThemeD4() or SETTINGS.LEGACY_DECO_VISIBLE == false end,
            },
            },
        },
        {
            type = "submenu",
            name = "Bouclier",
            controls = {
            {
                type = "header",
                name = "Visuel — Legacy",
            },
            {
                type = "slider",
                name = "Opacite du bouclier Legacy (%)",
                tooltip = "Ajuste l'opacite de l'effet visuel du bouclier magique. [ID: B86]",
                min = 0,
                max = 100,
                step = 5,
                getFunc = function() return zo_round(SETTINGS.SHIELD_ALPHA * 100) end,
                setFunc = function(value)
                    SETTINGS.SHIELD_ALPHA = value / 100
                    RefreshAllBars()
                end,
                default = zo_round(DEFAULT_SETTINGS.SHIELD_ALPHA * 100),
                width = "full",
            },
            {
                type = "slider",
                name = "Taille du cercle bouclier Legacy (%)",
                tooltip = "Ajuste l'epaisseur visuelle du cercle de bouclier dans l'orbe de vie (theme Legacy). [ID: B87]",
                min = 60,
                max = 200,
                step = 5,
                getFunc = function() return SETTINGS.SHIELD_RING_SCALE or DEFAULT_SETTINGS.SHIELD_RING_SCALE end,
                setFunc = function(value)
                    SETTINGS.SHIELD_RING_SCALE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.SHIELD_RING_SCALE,
                width = "full",
            },
            {
                type = "colorpicker",
                name = "Couleur Bouclier (Legacy)",
                tooltip = "Couleur du bouclier en theme Legacy. [ID: B92]",
                getFunc = function() return SETTINGS.SHIELD_COLOR_R, SETTINGS.SHIELD_COLOR_G, SETTINGS.SHIELD_COLOR_B, 1 end,
                setFunc = function(r, g, b, a)
                    SETTINGS.SHIELD_COLOR_R = r
                    SETTINGS.SHIELD_COLOR_G = g
                    SETTINGS.SHIELD_COLOR_B = b
                    RefreshAllBars()
                end,
                default = function() return DEFAULT_SETTINGS.SHIELD_COLOR_R, DEFAULT_SETTINGS.SHIELD_COLOR_G, DEFAULT_SETTINGS.SHIELD_COLOR_B, 1 end,
                width = "full",
            },
            {
                type = "header",
                name = "Visuel — D4",
            },
            {
                type = "slider",
                name = "Opacite du bouclier D4 (%)",
                tooltip = "Ajuste l'opacite du visuel de bouclier pour le theme D4. [ID: B73]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return zo_round((SETTINGS.D4_SHIELD_ALPHA or DEFAULT_SETTINGS.D4_SHIELD_ALPHA) * 100) end,
                setFunc = function(value)
                    SETTINGS.D4_SHIELD_ALPHA = value / 100
                    RefreshAllBars()
                end,
                default = zo_round(DEFAULT_SETTINGS.D4_SHIELD_ALPHA * 100),
                width = "full",
            },
            {
                type = "slider",
                name = "Taille du cercle bouclier D4 (%)",
                tooltip = "Ajuste l'epaisseur visuelle du cercle de bouclier dans l'orbe de vie (theme D4). [ID: B87b]",
                min = 60,
                max = 200,
                step = 5,
                getFunc = function() return SETTINGS.D4_SHIELD_RING_SCALE or DEFAULT_SETTINGS.D4_SHIELD_RING_SCALE end,
                setFunc = function(value)
                    SETTINGS.D4_SHIELD_RING_SCALE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SHIELD_RING_SCALE,
                width = "full",
            },
            {
                type = "slider",
                name = "Niveau de couche bouclier D4",
                tooltip = "Ajuste l'ordre de rendu du bouclier D4. Plus eleve = dessine plus au-dessus. [ID: B74]",
                min = 0,
                max = 20,
                step = 1,
                getFunc = function() return SETTINGS.D4_SHIELD_LAYER_LEVEL or DEFAULT_SETTINGS.D4_SHIELD_LAYER_LEVEL end,
                setFunc = function(value)
                    SETTINGS.D4_SHIELD_LAYER_LEVEL = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SHIELD_LAYER_LEVEL,
                width = "full",
            },
            {
                type = "header",
                name = "Commun",
            },
            {
                type = "slider",
                name = "Reactivite visuelle du bouclier (%)",
                tooltip = "Rend le bouclier visuellement plus rapide (haut) ou plus progressif (bas). 100% = lineaire. [ID: B88]",
                min = 50,
                max = 200,
                step = 5,
                getFunc = function() return SETTINGS.SHIELD_VISUAL_RESPONSE end,
                setFunc = function(value)
                    SETTINGS.SHIELD_VISUAL_RESPONSE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.SHIELD_VISUAL_RESPONSE,
                width = "full",
            },
            {
                type = "header",
                name = "Label — Legacy",
            },
            {
                type = "checkbox",
                name = "Afficher valeur bouclier (Legacy)",
                tooltip = "Affiche la valeur numerique du bouclier en theme Legacy. [ID: E06]",
                getFunc = function() return SETTINGS.SHOW_SHIELD_LABEL ~= false end,
                setFunc = function(value)
                    SETTINGS.SHOW_SHIELD_LABEL = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.SHOW_SHIELD_LABEL,
                width = "full",
            },
            {
                type = "slider",
                name = "Bouclier Legacy : offset horizontal (px)",
                tooltip = "Deplace independamment le texte du bouclier en Legacy. [ID: E07]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.SHIELD_LABEL_OFFSET_X or DEFAULT_SETTINGS.SHIELD_LABEL_OFFSET_X end,
                setFunc = function(value)
                    SETTINGS.SHIELD_LABEL_OFFSET_X = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.SHIELD_LABEL_OFFSET_X,
                width = "full",
                disabled = function() return SETTINGS.SHOW_SHIELD_LABEL == false end,
            },
            {
                type = "slider",
                name = "Bouclier Legacy : offset vertical (px)",
                tooltip = "Monte ou descend independamment le texte du bouclier en Legacy. [ID: E08]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.SHIELD_LABEL_OFFSET_Y or DEFAULT_SETTINGS.SHIELD_LABEL_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.SHIELD_LABEL_OFFSET_Y = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.SHIELD_LABEL_OFFSET_Y,
                width = "full",
                disabled = function() return SETTINGS.SHOW_SHIELD_LABEL == false end,
            },
            {
                type = "header",
                name = "Label — D4",
            },
            {
                type = "checkbox",
                name = "Afficher valeur bouclier (D4)",
                tooltip = "Affiche la valeur numerique du bouclier en theme D4. [ID: E09]",
                getFunc = function() return SETTINGS.D4_SHOW_SHIELD_LABEL ~= false end,
                setFunc = function(value)
                    SETTINGS.D4_SHOW_SHIELD_LABEL = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SHOW_SHIELD_LABEL,
                width = "full",
            },
            {
                type = "slider",
                name = "Bouclier D4 : offset horizontal (px)",
                tooltip = "Deplace independamment le texte du bouclier en D4. [ID: E10]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_SHIELD_LABEL_OFFSET_X or DEFAULT_SETTINGS.D4_SHIELD_LABEL_OFFSET_X end,
                setFunc = function(value)
                    SETTINGS.D4_SHIELD_LABEL_OFFSET_X = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SHIELD_LABEL_OFFSET_X,
                width = "full",
                disabled = function() return SETTINGS.D4_SHOW_SHIELD_LABEL == false end,
            },
            {
                type = "slider",
                name = "Bouclier D4 : offset vertical (px)",
                tooltip = "Monte ou descend independamment le texte du bouclier en D4. [ID: E11]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_SHIELD_LABEL_OFFSET_Y or DEFAULT_SETTINGS.D4_SHIELD_LABEL_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.D4_SHIELD_LABEL_OFFSET_Y = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_SHIELD_LABEL_OFFSET_Y,
                width = "full",
                disabled = function() return SETTINGS.D4_SHOW_SHIELD_LABEL == false end,
            },
            },
        },
        {
            type = "submenu",
            name = "Texte et valeurs",
            controls = {
            {
                type = "header",
                name = "Infos et valeurs",
            },
            {
                type = "description",
                text = "Organisation: famille de police commune, puis reglages separes pour valeurs des orbes et texte de jauge ultime.",
                width = "full",
            },
            {
                type = "checkbox",
                name = "Inverser mana/endurance (interieur)",
                tooltip = "Inverse l'emplacement horizontal des valeurs mana et endurance quand l'affichage est en mode interieur. Independant par theme (D4 / Legacy). [ID: E12]",
                getFunc = function() return GetThemeSetting("LABEL_INSIDE_SWAP_MANA_STAMINA") == true end,
                setFunc = function(value)
                    SetThemeSetting("LABEL_INSIDE_SWAP_MANA_STAMINA", value)
                    RefreshTheme(topLevelCtrl)
                    for _, bar in ipairs(allBars) do
                        bar:ApplyAttributeLabel()
                    end
                end,
                default = function()
                    if ThemeManager:GetCurrentTheme() == "d4" then
                        return DEFAULT_SETTINGS.D4_LABEL_INSIDE_SWAP_MANA_STAMINA
                    else
                        return DEFAULT_SETTINGS.LABEL_INSIDE_SWAP_MANA_STAMINA
                    end
                end,
                width = "full",
                disabled = function() return not IsLabelInsideMode() end,
            },
            {
                type = "header",
                name = "Typographie commune",
            },
            {
                type = "description",
                text = "La police est commune; la taille des textes orbes et jauge ultime est reglee separement.",
                width = "full",
            },
            {
                type = "dropdown",
                name = "Police des nombres (commun tous themes)",
                tooltip = "Choisit la police utilisee pour les valeurs des orbes et le texte d'ultime. Les polices custom utilisent les fichiers dans DiabloOrbs/Fonts (sinon retour auto a la police ESO). [ID: E01]",
                choices = (function()
                    local labels = {}
                    for _, entry in ipairs(CUSTOM_NUMBER_FONTS) do
                        table.insert(labels, entry.label)
                    end
                    return labels
                end)(),
                choicesValues = (function()
                    local values = {}
                    for _, entry in ipairs(CUSTOM_NUMBER_FONTS) do
                        table.insert(values, entry.key)
                    end
                    return values
                end)(),
                getFunc = function()
                    return NormalizeNumberFontFamily(SETTINGS.NUMBER_FONT_FAMILY or DEFAULT_SETTINGS.NUMBER_FONT_FAMILY)
                end,
                setFunc = function(value)
                    local normValue = NormalizeNumberFontFamily(value)
                    DebugPrint("Dropdown setFunc selected='" .. tostring(value) .. "' normalized='" .. tostring(normValue) .. "'")
                    SETTINGS.NUMBER_FONT_FAMILY = normValue
                    RefreshAllBars()
                    updateUltimate(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.NUMBER_FONT_FAMILY,
                width = "full",
            },
            {
                type = "header",
                name = "Valeurs des orbes",
            },
            {
                type = "slider",
                name = "Taille des valeurs (%)",
                tooltip = "Regle la taille du texte des valeurs/pourcentages affiches sur les orbes. [ID: E02]",
                min = 70,
                max = 180,
                step = 5,
                getFunc = function() return zo_round(GetThemeSetting("LABEL_SCALE") * 100) end,
                setFunc = function(value)
                    SetThemeSetting("LABEL_SCALE", value / 100)
                    RefreshAllBars()
                end,
                default = function() return zo_round(DEFAULT_SETTINGS.LABEL_SCALE * 100) end,
                width = "full",
            },
            {
                type = "slider",
                name = "Opacite texte valeurs (%)",
                tooltip = "Regle l'opacite du texte des valeurs, quel que soit son placement. [ID: E03]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return GetThemeSetting("LABEL_TEXT_ALPHA") end,
                setFunc = function(value)
                    SetThemeSetting("LABEL_TEXT_ALPHA", value)
                    RefreshAllBars()
                end,
                default = function() return DEFAULT_SETTINGS.LABEL_TEXT_ALPHA end,
                width = "full",
            },
            {
                type = "dropdown",
                name = "Affichage des valeurs de ressources",
                tooltip = "Choisit comment afficher les valeurs numeriques sur les orbes. [ID: E04]",
                choices = { "Masque", "Valeur (ex: 23k)", "Valeur complete (ex: 23456)", "Pourcentage (ex: 75%)" },
                choicesValues = { "hidden", "value", "full", "percent" },
                getFunc = function()
                    local normalized = NormalizeLabelFormat(GetThemeSetting("LABEL_FORMAT"))
                    return normalized
                end,
                setFunc = function(value)
                    SetThemeSetting("LABEL_FORMAT", value)
                    for _, bar in ipairs(allBars) do
                        bar:ApplyAttributeLabel()
                    end
                end,
                default = function() return DEFAULT_SETTINGS.LABEL_FORMAT end,
                width = "full",
            },
            {
                type = "dropdown",
                name = "Position des valeurs",
                tooltip = "Exterieur = position classique. Interieur = texte place au centre des orbes. [ID: E05]",
                choices = { "Exterieur", "Interieur" },
                choicesValues = { "outside", "inside" },
                getFunc = function()
                    local mode = NormalizeLabelPositionMode(GetThemeSetting("LABEL_POSITION_MODE"))
                    return mode
                end,
                setFunc = function(value)
                    SetThemeSetting("LABEL_POSITION_MODE", value)
                    RefreshTheme(topLevelCtrl)
                    for _, bar in ipairs(allBars) do
                        bar:ApplyAttributeLabel()
                    end
                end,
                default = function() return DEFAULT_SETTINGS.LABEL_POSITION_MODE end,
                width = "full",
            },
            {
                type = "dropdown",
                name = "Style texte interieur",
                tooltip = "Eclairci = texte clair avec ombrage sombre. Assombri = texte fonce avec ombrage clair. [ID: E13]",
                choices = { "Aucun", "Eclairci", "Assombri" },
                choicesValues = { "none", "light", "dark" },
                getFunc = function()
                    return NormalizeLabelInnerStyle(GetThemeSetting("LABEL_INNER_STYLE"))
                end,
                setFunc = function(value)
                    SetThemeSetting("LABEL_INNER_STYLE", value)
                    for _, bar in ipairs(allBars) do
                        bar:ApplyAttributeLabel()
                    end
                end,
                default = function() return DEFAULT_SETTINGS.LABEL_INNER_STYLE end,
                width = "full",
                disabled = function() return not IsLabelInsideMode() end,
            },
            {
                type = "slider",
                name = "Opacite ombrage texte interieur (%)",
                tooltip = "Regle l'opacite de la vraie ombre de texte appliquee derriere les valeurs placees dans l'orbe. [ID: E14]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return GetThemeSetting("LABEL_INNER_SHADE_ALPHA") end,
                setFunc = function(value)
                    SetThemeSetting("LABEL_INNER_SHADE_ALPHA", value)
                    for _, bar in ipairs(allBars) do
                        bar:ApplyAttributeLabel()
                    end
                end,
                default = function() return DEFAULT_SETTINGS.LABEL_INNER_SHADE_ALPHA end,
                width = "full",
                disabled = function() return not IsLabelInsideMode() end,
            },
            {
                type = "slider",
                name = "Opacite fond contraste interieur (%)",
                tooltip = "Regle l'opacite du fond de contraste derriere les valeurs placees dans l'orbe. [ID: E15]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return GetThemeSetting("LABEL_INNER_BACKDROP_ALPHA") end,
                setFunc = function(value)
                    SetThemeSetting("LABEL_INNER_BACKDROP_ALPHA", value)
                    for _, bar in ipairs(allBars) do
                        bar:ApplyAttributeLabel()
                    end
                end,
                default = function() return DEFAULT_SETTINGS.LABEL_INNER_BACKDROP_ALPHA end,
                width = "full",
                disabled = function() return not IsLabelInsideMode() end,
            },
            {
                type = "colorpicker",
                name = "Couleur ombrage texte interieur",
                tooltip = "Choix de la couleur d'ombrage appliquee derriere le texte au centre des orbes. [ID: E16]",
                getFunc = function()
                    return GetThemeSetting("LABEL_INNER_SHADE_COLOR_R"),
                           GetThemeSetting("LABEL_INNER_SHADE_COLOR_G"),
                           GetThemeSetting("LABEL_INNER_SHADE_COLOR_B"),
                           1
                end,
                setFunc = function(r, g, b)
                    SetThemeSetting("LABEL_INNER_SHADE_COLOR_R", r)
                    SetThemeSetting("LABEL_INNER_SHADE_COLOR_G", g)
                    SetThemeSetting("LABEL_INNER_SHADE_COLOR_B", b)
                    for _, bar in ipairs(allBars) do
                        bar:ApplyAttributeLabel()
                    end
                end,
                default = function()
                    return DEFAULT_SETTINGS.LABEL_INNER_SHADE_COLOR_R, DEFAULT_SETTINGS.LABEL_INNER_SHADE_COLOR_G, DEFAULT_SETTINGS.LABEL_INNER_SHADE_COLOR_B, 1
                end,
                width = "full",
                disabled = function() return not IsLabelInsideMode() end,
            },
            {
                type = "slider",
                name = "Exterieur : padding horizontal (px)",
                tooltip = "Regle l'ecart lateral des valeurs exterieures par rapport aux bords des orbes. [ID: E17]",
                min = -40,
                max = 40,
                step = 1,
                getFunc = function() return GetThemeSetting("LABEL_OUTER_PADDING_X") end,
                setFunc = function(value)
                    SetThemeSetting("LABEL_OUTER_PADDING_X", value)
                    RefreshTheme(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.LABEL_OUTER_PADDING_X end,
                width = "full",
                disabled = IsLabelInsideMode,
            },
            {
                type = "slider",
                name = "Exterieur : padding vertical (px)",
                tooltip = "Regle la position haut/bas des valeurs exterieures. [ID: E18]",
                min = -80,
                max = 40,
                step = 1,
                getFunc = function() return GetThemeSetting("LABEL_OUTER_PADDING_Y") end,
                setFunc = function(value)
                    SetThemeSetting("LABEL_OUTER_PADDING_Y", value)
                    RefreshTheme(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.LABEL_OUTER_PADDING_Y end,
                width = "full",
                disabled = IsLabelInsideMode,
            },
            {
                type = "slider",
                name = "Interieur : orbe gauche offset horizontal (px)",
                tooltip = "Deplace horizontalement la valeur de l'orbe gauche (sante) autour du centre. [ID: E19]",
                min = -40,
                max = 40,
                step = 1,
                getFunc = function() return GetThemeSetting("LABEL_INSIDE_HEALTH_OFFSET_X") end,
                setFunc = function(value)
                    SetThemeSetting("LABEL_INSIDE_HEALTH_OFFSET_X", value)
                    RefreshTheme(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.LABEL_INSIDE_HEALTH_OFFSET_X end,
                width = "full",
                disabled = function() return not IsLabelInsideMode() end,
            },
            {
                type = "slider",
                name = "Interieur : ecart miroir mana/endu (px)",
                tooltip = "Ecarte ou rapproche les valeurs mana/endurance du centre de l'orbe scinde. [ID: E20]",
                min = -100,
                max = 100,
                step = 1,
                getFunc = function() return GetThemeSetting("LABEL_CENTER_GAP_X") end,
                setFunc = function(value)
                    SetThemeSetting("LABEL_CENTER_GAP_X", value)
                    RefreshTheme(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.LABEL_CENTER_GAP_X end,
                width = "full",
                disabled = function() return not IsLabelInsideMode() end,
            },
            {
                type = "slider",
                name = "Offset vertical texte valeurs (px)",
                tooltip = "Monte ou descend le texte des valeurs des orbes. [ID: E21]",
                min = -40,
                max = 40,
                step = 1,
                getFunc = function() return GetThemeSetting("LABEL_OFFSET_Y") end,
                setFunc = function(value)
                    SetThemeSetting("LABEL_OFFSET_Y", value)
                    RefreshTheme(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.LABEL_OFFSET_Y end,
                width = "full",
            },
            {
                type = "slider",
                name = "Opacite bordure tooltip valeurs (%)",
                tooltip = "Regle l'opacite de la bordure decorative autour du texte des valeurs. [ID: E22]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.VALUE_TOOLTIP_BORDER_ALPHA or DEFAULT_SETTINGS.VALUE_TOOLTIP_BORDER_ALPHA end,
                setFunc = function(value)
                    SETTINGS.VALUE_TOOLTIP_BORDER_ALPHA = value
                    for _, bar in ipairs(allBars) do
                        bar:ApplyAttributeLabel()
                    end
                end,
                default = DEFAULT_SETTINGS.VALUE_TOOLTIP_BORDER_ALPHA,
                width = "full",
            },
            },
        },
        {
            type = "submenu",
            name = "Barre d'action — Commun",
            controls = {
            {
                type = "header",
                name = "Base",
            },
            {
                type = "description",
                text = "Options communes de la barre d'action DiabloOrbs. Les reglages marques solo/dual permettent un comportement distinct selon le mode detecte.",
                width = "full",
            },
            {
                type = "checkbox",
                name = "Confier la barre d'action a DiabloOrbs",
                tooltip = "Active la gestion des slots/hotkeys/armes par DiabloOrbs. Si desactive, DiabloOrbs conserve les elements visuels (skins/fonds/jauge ultime) mais laisse la gestion des slots a un autre addon. [ID: A05]",
                getFunc = function() return SETTINGS.ENABLE_ACTION_BAR_MODULE end,
                setFunc = function(value)
                    SETTINGS.ENABLE_ACTION_BAR_MODULE = value
                    if not value then
                        SETTINGS.D4_SHOW_LIVE_PREVIEW = false
                    end
                    RefreshTheme(topLevelCtrl)
                    if topLevelCtrl.UpdateLivePreviewVisibility then
                        topLevelCtrl.UpdateLivePreviewVisibility()
                    end
                end,
                default = DEFAULT_SETTINGS.ENABLE_ACTION_BAR_MODULE,
                width = "full",
            },
            {
                type = "description",
                text = "Mode 2 barres: ces reglages s'appliquent a la barre secondaire affichee en permanence quand un systeme dual est detecte.",
                width = "full",
            },
            {
                type = "checkbox",
                name = "Afficher le fond/support de barre DiabloOrbs",
                tooltip = "Affiche ou masque le fond de barre, les habillages et les supports visuels de la barre d'action DiabloOrbs. [ID: C01]",
                getFunc = function() return SETTINGS.SHOW_ACTION_BAR_BACKGROUNDS end,
                setFunc = function(value)
                    SETTINGS.SHOW_ACTION_BAR_BACKGROUNDS = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.SHOW_ACTION_BAR_BACKGROUNDS,
                width = "full",
            },
            {
                type = "checkbox",
                name = "Afficher les slots de competences DiabloOrbs",
                tooltip = "Affiche ou masque les slots de competences geres par DiabloOrbs. Pratique pour ne garder que le fond, ou inversement. [ID: C02]",
                getFunc = function() return SETTINGS.SHOW_ACTION_BAR_SLOTS end,
                setFunc = function(value)
                    SETTINGS.SHOW_ACTION_BAR_SLOTS = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.SHOW_ACTION_BAR_SLOTS,
                width = "full",
                disabled = IsActionBarModuleDisabled,
            },
            {
                type = "checkbox",
                name = "Afficher la jauge ultime centrale DiabloOrbs",
                tooltip = "Active ou coupe completement le widget d'ultime central de DiabloOrbs, independamment des autres parties de la barre. [ID: C03]",
                getFunc = function() return SETTINGS.SHOW_ACTION_BAR_ULTIMATE_WIDGET end,
                setFunc = function(value)
                    SETTINGS.SHOW_ACTION_BAR_ULTIMATE_WIDGET = value
                    RefreshTheme(topLevelCtrl)
                    updateUltimate(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.SHOW_ACTION_BAR_ULTIMATE_WIDGET,
                width = "full",
            },
            {
                type = "slider",
                name = "Opacite barre inactive 2 barres (%)",
                tooltip = "Regle l'opacite de la barre secondaire inactive quand une configuration 2 barres est detectee. [ID: C14]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.INACTIVE_BACK_BAR_ALPHA_DUAL end,
                setFunc = function(value)
                    SETTINGS.INACTIVE_BACK_BAR_ALPHA_DUAL = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.INACTIVE_BACK_BAR_ALPHA_DUAL,
                width = "full",
                disabled = AreActionBarSlotsDisabled,
            },
            {
                type = "slider",
                name = "Desaturation barre inactive 2 barres (%)",
                tooltip = "Ajuste l'effet de desaturation sur la barre secondaire inactive en mode 2 barres. [ID: C15]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.INACTIVE_BACK_BAR_DESATURATION_DUAL end,
                setFunc = function(value)
                    SETTINGS.INACTIVE_BACK_BAR_DESATURATION_DUAL = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.INACTIVE_BACK_BAR_DESATURATION_DUAL,
                width = "full",
                disabled = AreActionBarSlotsDisabled,
            },
            {
                type = "checkbox",
                name = "Afficher l'indicateur de changement d'arme",
                tooltip = "Affiche le controle de changement d'arme sur la barre standard et la fleche sur la version dual quand disponible. [ID: C16]",
                getFunc = function() return SETTINGS.SHOW_ACTION_BAR_WEAPON_SWAP end,
                setFunc = function(value)
                    SETTINGS.SHOW_ACTION_BAR_WEAPON_SWAP = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.SHOW_ACTION_BAR_WEAPON_SWAP,
                width = "full",
                disabled = IsActionBarModuleDisabled,
            },
            {
                type = "checkbox",
                name = "Afficher l'ultime du compagnon",
                tooltip = "Affiche ou masque le slot d'ultime du compagnon sans toucher au reste de la barre. [ID: C17]",
                getFunc = function() return SETTINGS.SHOW_ACTION_BAR_COMPANION_ULTIMATE end,
                setFunc = function(value)
                    SETTINGS.SHOW_ACTION_BAR_COMPANION_ULTIMATE = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.SHOW_ACTION_BAR_COMPANION_ULTIMATE,
                width = "full",
                disabled = AreActionBarSlotsDisabled,
            },
            {
                type = "header",
                name = "Raccourcis",
            },
            {
                type = "checkbox",
                name = "Afficher les raccourcis des slots",
                tooltip = "Affiche les textes/raccourcis clavier sur les slots de la barre d'action quand l'interface clavier est utilisee. [ID: C04]",
                getFunc = function() return SETTINGS.SHOW_ACTION_BAR_HOTKEYS end,
                setFunc = function(value)
                    SETTINGS.SHOW_ACTION_BAR_HOTKEYS = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.SHOW_ACTION_BAR_HOTKEYS,
                width = "full",
                disabled = AreActionBarSlotsDisabled,
            },
            {
                type = "dropdown",
                name = "Position des raccourcis",
                tooltip = "Choisit la position des textes de raccourcis des competences: au-dessus, en dessous, ou a l'interieur des cases. [ID: C05]",
                choices = { "En haut", "En bas", "A l'interieur" },
                choicesValues = { "top", "bottom", "inside" },
                getFunc = function()
                    local value = NormalizeActionBarHotkeyPosition(SETTINGS.ACTION_BAR_HOTKEY_POSITION)
                    if SETTINGS.ACTION_BAR_HOTKEY_POSITION ~= value then
                        SETTINGS.ACTION_BAR_HOTKEY_POSITION = value
                    end
                    return value
                end,
                setFunc = function(value)
                    SETTINGS.ACTION_BAR_HOTKEY_POSITION = NormalizeActionBarHotkeyPosition(value)
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_POSITION,
                width = "full",
                disabled = function() return AreActionBarSlotsDisabled() or SETTINGS.SHOW_ACTION_BAR_HOTKEYS == false end,
            },
            {
                type = "slider",
                name = "Taille des raccourcis (%)",
                tooltip = "Ajuste la taille du texte des raccourcis des competences. [ID: C06]",
                min = 70,
                max = 180,
                step = 1,
                getFunc = function() return SETTINGS.ACTION_BAR_HOTKEY_SCALE or DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_SCALE end,
                setFunc = function(value)
                    SETTINGS.ACTION_BAR_HOTKEY_SCALE = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_SCALE,
                width = "full",
                disabled = function() return AreActionBarSlotsDisabled() or SETTINGS.SHOW_ACTION_BAR_HOTKEYS == false end,
            },
            {
                type = "slider",
                name = "Opacite des raccourcis (%)",
                tooltip = "Ajuste la transparence du texte des raccourcis des competences. [ID: C07]",
                min = 10,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.ACTION_BAR_HOTKEY_ALPHA or DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_ALPHA end,
                setFunc = function(value)
                    SETTINGS.ACTION_BAR_HOTKEY_ALPHA = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_ALPHA,
                width = "full",
                disabled = function() return AreActionBarSlotsDisabled() or SETTINGS.SHOW_ACTION_BAR_HOTKEYS == false end,
            },
            {
                type = "slider",
                name = "Offset X raccourcis (px)",
                tooltip = "Decale horizontalement le texte des raccourcis sur les slots. [ID: C08]",
                min = -30,
                max = 30,
                step = 1,
                getFunc = function() return SETTINGS.ACTION_BAR_HOTKEY_OFFSET_X or DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_OFFSET_X end,
                setFunc = function(value)
                    SETTINGS.ACTION_BAR_HOTKEY_OFFSET_X = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_OFFSET_X,
                width = "full",
                disabled = function() return AreActionBarSlotsDisabled() or SETTINGS.SHOW_ACTION_BAR_HOTKEYS == false end,
            },
            {
                type = "slider",
                name = "Offset Y raccourcis (px)",
                tooltip = "Decale verticalement le texte des raccourcis sur les slots. [ID: C09]",
                min = -30,
                max = 30,
                step = 1,
                getFunc = function() return SETTINGS.ACTION_BAR_HOTKEY_OFFSET_Y or DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.ACTION_BAR_HOTKEY_OFFSET_Y = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_OFFSET_Y,
                width = "full",
                disabled = function() return AreActionBarSlotsDisabled() or SETTINGS.SHOW_ACTION_BAR_HOTKEYS == false end,
            },
            {
                type = "checkbox",
                name = "Raccourcis visibles seulement en combat",
                tooltip = "Si active, les raccourcis de competences s'affichent uniquement en combat. [ID: C10]",
                getFunc = function() return SETTINGS.ACTION_BAR_HOTKEY_ONLY_IN_COMBAT or DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_ONLY_IN_COMBAT end,
                setFunc = function(value)
                    SETTINGS.ACTION_BAR_HOTKEY_ONLY_IN_COMBAT = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_ONLY_IN_COMBAT,
                width = "full",
                disabled = function() return AreActionBarSlotsDisabled() or SETTINGS.SHOW_ACTION_BAR_HOTKEYS == false end,
            },
            },
        },
        {
            type = "submenu",
            name = "Barre d'action — D4",
            controls = {
            {
                type = "header",
                name = "Teinte globale D4",
            },
            {
                type = "description",
                text = "Applique une teinte coloree sur le cadre des orbes, les socles, la surcouche contour, le fond de la barre d'action et le fond de la jauge ultime en theme D4.",
                width = "full",
            },
            {
                type = "colorpicker",
                name = "Couleur de teinte D4",
                tooltip = "Couleur appliquee sur les elements D4 (cadre, socles, surcouche, barre, jauge). [ID: GT01]",
                getFunc = function()
                    return SETTINGS.D4_GLOBAL_TINT_R or DEFAULT_SETTINGS.D4_GLOBAL_TINT_R,
                           SETTINGS.D4_GLOBAL_TINT_G or DEFAULT_SETTINGS.D4_GLOBAL_TINT_G,
                           SETTINGS.D4_GLOBAL_TINT_B or DEFAULT_SETTINGS.D4_GLOBAL_TINT_B,
                           1
                end,
                setFunc = function(r, g, b)
                    SETTINGS.D4_GLOBAL_TINT_R = r
                    SETTINGS.D4_GLOBAL_TINT_G = g
                    SETTINGS.D4_GLOBAL_TINT_B = b
                    RefreshTheme(topLevelCtrl)
                end,
                default = function()
                    return DEFAULT_SETTINGS.D4_GLOBAL_TINT_R, DEFAULT_SETTINGS.D4_GLOBAL_TINT_G, DEFAULT_SETTINGS.D4_GLOBAL_TINT_B, 1
                end,
                width = "full",
            },
            {
                type = "slider",
                name = "Intensite de la teinte (%)",
                tooltip = "0 = pas de teinte (couleur originale), 100 = teinte pleine. [ID: GT02]",
                min = 0,
                max = 100,
                step = 5,
                getFunc = function() return SETTINGS.D4_GLOBAL_TINT_INTENSITY or DEFAULT_SETTINGS.D4_GLOBAL_TINT_INTENSITY end,
                setFunc = function(value)
                    SETTINGS.D4_GLOBAL_TINT_INTENSITY = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_GLOBAL_TINT_INTENSITY,
                width = "full",
            },
            {
                type = "header",
                name = "Bordures et contours",
            },
            {
                type = "description",
                text = "Habillage des boutons de la barre d'action en theme D4 : bordures, smoke, compagnon.",
                width = "full",
            },
            {
                type = "slider",
                name = "D4 : ecart horizontal des 5 slots (px)",
                tooltip = "Ajuste l'ecart des 5 slots centraux en theme D4. [ID: C11]",
                min = -20,
                max = 30,
                step = 1,
                getFunc = function() return SETTINGS.ACTION_BAR_CENTER_SLOTS_GAP_X or DEFAULT_SETTINGS.ACTION_BAR_CENTER_SLOTS_GAP_X end,
                setFunc = function(value)
                    SETTINGS.ACTION_BAR_CENTER_SLOTS_GAP_X = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.ACTION_BAR_CENTER_SLOTS_GAP_X,
                width = "full",
                disabled = AreActionBarSlotsDisabled,
            },
            {
                type = "checkbox",
                name = "Afficher les bordures de slots D4",
                tooltip = "Active ou coupe les bordures de slots ajoutees par DiabloOrbs en theme D4. [ID: C18]",
                getFunc = function() return SETTINGS.SHOW_D4_SLOT_BORDERS end,
                setFunc = function(value)
                    SETTINGS.SHOW_D4_SLOT_BORDERS = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.SHOW_D4_SLOT_BORDERS,
                width = "full",
                disabled = AreActionBarSlotsDisabled,
            },
            {
                type = "slider",
                name = "Opacite contours boutons D4 (%)",
                tooltip = "Reglage principal de l'opacite des contours de boutons D4 (raccourci, 5 slots, ultime et compagnon). [ID: C19]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.D4_ALL_SLOT_BORDER_ALPHA end,
                setFunc = function(value)
                    SETTINGS.D4_ALL_SLOT_BORDER_ALPHA = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_ALL_SLOT_BORDER_ALPHA,
                width = "full",
                disabled = AreActionBarSlotsDisabled,
            },
            {
                type = "slider",
                name = "Noirceur contours boutons D4 (%)",
                tooltip = "Assombrit tous les contours de boutons de competences D4. [ID: C20]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.D4_SLOT_BORDER_DARKNESS or DEFAULT_SETTINGS.D4_SLOT_BORDER_DARKNESS end,
                setFunc = function(value)
                    SETTINGS.D4_SLOT_BORDER_DARKNESS = value
                    ApplyD4SpellSlotBorders()
                end,
                default = DEFAULT_SETTINGS.D4_SLOT_BORDER_DARKNESS,
                width = "full",
                disabled = AreActionBarSlotsDisabled,
            },
            {
                type = "slider",
                name = "Contraste contours boutons D4 (%)",
                tooltip = "Renforce le contraste du contour (100 = normal, >100 = plus marque). [ID: C21]",
                min = 50,
                max = 200,
                step = 1,
                getFunc = function() return SETTINGS.D4_SLOT_BORDER_CONTRAST or DEFAULT_SETTINGS.D4_SLOT_BORDER_CONTRAST end,
                setFunc = function(value)
                    SETTINGS.D4_SLOT_BORDER_CONTRAST = value
                    ApplyD4SpellSlotBorders()
                end,
                default = DEFAULT_SETTINGS.D4_SLOT_BORDER_CONTRAST,
                width = "full",
                disabled = AreActionBarSlotsDisabled,
            },
            {
                type = "slider",
                name = "Intensite smoke boutons D4 (%)",
                tooltip = "Ajoute un voile Smoke teinte par les couleurs d'orbes pour fondre les boutons dans le theme. [ID: C22]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.D4_SLOT_SMOKE_INTENSITY or DEFAULT_SETTINGS.D4_SLOT_SMOKE_INTENSITY end,
                setFunc = function(value)
                    SETTINGS.D4_SLOT_SMOKE_INTENSITY = value
                    ApplyD4SpellSlotBorders()
                end,
                default = DEFAULT_SETTINGS.D4_SLOT_SMOKE_INTENSITY,
                width = "full",
                disabled = AreActionBarSlotsDisabled,
            },
            {
                type = "slider",
                name = "Assombrissement contour slot compagnon (%)",
                tooltip = "Assombrit uniquement le contour du slot compagnon, sans modifier les autres contours D4. [ID: C23]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.D4_COMPANION_SLOT_BORDER_DARKNESS or DEFAULT_SETTINGS.D4_COMPANION_SLOT_BORDER_DARKNESS end,
                setFunc = function(value)
                    SETTINGS.D4_COMPANION_SLOT_BORDER_DARKNESS = value
                    ApplyD4SpellSlotBorders()
                end,
                default = DEFAULT_SETTINGS.D4_COMPANION_SLOT_BORDER_DARKNESS,
                width = "full",
                disabled = AreActionBarSlotsDisabled,
            },
            {
                type = "checkbox",
                name = "Afficher reglages avances solo/dual des contours",
                tooltip = "Affiche les reglages separes solo/dual pour affiner l'intensite des contours. L'opacite principale reste le reglage recommande. [ID: C24]",
                getFunc = function() return SETTINGS.D4_SLOT_BORDER_ADVANCED == true end,
                setFunc = function(value)
                    SETTINGS.D4_SLOT_BORDER_ADVANCED = value
                    if LAM2.RequestRefreshIfNeeded ~= nil then
                        LAM2:RequestRefreshIfNeeded(panelId)
                    end
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_SLOT_BORDER_ADVANCED,
                width = "full",
                disabled = AreActionBarSlotsDisabled,
            },
            {
                type = "slider",
                name = "Intensite additionnelle contours D4 solo (%)",
                tooltip = "Reglage avance: intensite solo multipliee avec l'opacite principale. [ID: C25]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.D4_SLOT_HIGHLIGHT_SOLO_ALPHA end,
                setFunc = function(value)
                    SETTINGS.D4_SLOT_HIGHLIGHT_SOLO_ALPHA = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_SLOT_HIGHLIGHT_SOLO_ALPHA,
                width = "full",
                disabled = AreActionBarSlotsDisabled,
            },
            {
                type = "slider",
                name = "Intensite additionnelle contours D4 dual (%)",
                tooltip = "Reglage avance: intensite dual multipliee avec l'opacite principale. [ID: C26]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.D4_SLOT_HIGHLIGHT_DUAL_ALPHA end,
                setFunc = function(value)
                    SETTINGS.D4_SLOT_HIGHLIGHT_DUAL_ALPHA = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_SLOT_HIGHLIGHT_DUAL_ALPHA,
                width = "full",
                disabled = AreActionBarSlotsDisabled,
            },
            {
                type = "header",
                name = "Fond de barre D4",
            },
            {
                type = "slider",
                name = "Taille fond barre D4 (%)",
                tooltip = "Ajuste la taille reelle du fond de barre D4. 100 = taille source, plus haut agrandit la barre complete, plus bas la reduit. [ID: C27]",
                min = 60,
                max = 160,
                step = 5,
                getFunc = function() return SETTINGS.D4_BAR_TEXTURE_SCALE or DEFAULT_SETTINGS.D4_BAR_TEXTURE_SCALE end,
                setFunc = function(value)
                    SETTINGS.D4_BAR_TEXTURE_SCALE = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BAR_TEXTURE_SCALE,
                width = "full",
            },
            {
                type = "slider",
                name = "Largeur fond D4 sans barre secondaire (%)",
                tooltip = "Ajuste la largeur du fond de barre D4 quand la barre secondaire est desactivee. [ID: C28]",
                min = 50,
                max = 180,
                step = 1,
                getFunc = function() return SETTINGS.D4_SOLO_BAR_WIDTH_SCALE or DEFAULT_SETTINGS.D4_SOLO_BAR_WIDTH_SCALE end,
                setFunc = function(value)
                    SETTINGS.D4_SOLO_BAR_WIDTH_SCALE = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_SOLO_BAR_WIDTH_SCALE,
                width = "half",
            },
            {
                type = "slider",
                name = "Hauteur fond D4 sans barre secondaire (%)",
                tooltip = "Ajuste la hauteur du fond de barre D4 quand la barre secondaire est desactivee. [ID: C29]",
                min = 50,
                max = 180,
                step = 1,
                getFunc = function() return SETTINGS.D4_SOLO_BAR_HEIGHT_SCALE or DEFAULT_SETTINGS.D4_SOLO_BAR_HEIGHT_SCALE end,
                setFunc = function(value)
                    SETTINGS.D4_SOLO_BAR_HEIGHT_SCALE = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_SOLO_BAR_HEIGHT_SCALE,
                width = "half",
            },
            {
                type = "slider",
                name = "Largeur fond D4 avec barre secondaire (%)",
                tooltip = "Ajuste la largeur du fond de barre D4 quand la barre secondaire est activee. [ID: C30]",
                min = 50,
                max = 180,
                step = 1,
                getFunc = function() return SETTINGS.D4_DUAL_BAR_WIDTH_SCALE or DEFAULT_SETTINGS.D4_DUAL_BAR_WIDTH_SCALE end,
                setFunc = function(value)
                    SETTINGS.D4_DUAL_BAR_WIDTH_SCALE = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_DUAL_BAR_WIDTH_SCALE,
                width = "half",
            },
            {
                type = "slider",
                name = "Hauteur fond D4 avec barre secondaire (%)",
                tooltip = "Ajuste la hauteur du fond de barre D4 quand la barre secondaire est activee. [ID: C31]",
                min = 50,
                max = 180,
                step = 1,
                getFunc = function() return SETTINGS.D4_DUAL_BAR_HEIGHT_SCALE or DEFAULT_SETTINGS.D4_DUAL_BAR_HEIGHT_SCALE end,
                setFunc = function(value)
                    SETTINGS.D4_DUAL_BAR_HEIGHT_SCALE = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_DUAL_BAR_HEIGHT_SCALE,
                width = "half",
            },
            {
                type = "slider",
                name = "Echelle contenu barre D4 (%)",
                tooltip = "Ajuste les touches et icones a l'interieur de la barre D4. Le contenu suit maintenant automatiquement la taille du fond, puis ce reglage affine le resultat. [ID: C32]",
                min = 50,
                max = 300,
                step = 5,
                getFunc = function() return SETTINGS.D4_BAR_SCALE or DEFAULT_SETTINGS.D4_BAR_SCALE end,
                setFunc = function(value)
                    SETTINGS.D4_BAR_SCALE = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BAR_SCALE,
                width = "full",
            },
            {
                type = "slider",
                name = "Offset vertical barre - Solo (px)",
                tooltip = "Monte ou descend la barre en mode solo (barre secondaire desactivee). [ID: C33]",
                min = -200,
                max = 200,
                step = 1,
                getFunc = function() return SETTINGS.D4_SOLO_BAR_OFFSET_Y or DEFAULT_SETTINGS.D4_SOLO_BAR_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.D4_SOLO_BAR_OFFSET_Y = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_SOLO_BAR_OFFSET_Y,
                width = "half",
            },
            {
                type = "slider",
                name = "Offset vertical barre - Dual (px)",
                tooltip = "Monte ou descend la barre en mode dual (barre secondaire activee). [ID: C34]",
                min = -200,
                max = 200,
                step = 1,
                getFunc = function() return SETTINGS.D4_DUAL_BAR_OFFSET_Y or DEFAULT_SETTINGS.D4_DUAL_BAR_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.D4_DUAL_BAR_OFFSET_Y = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_DUAL_BAR_OFFSET_Y,
                width = "half",
            },
            {
                type = "slider",
                name = "Luminosite barre D4 (%)",
                tooltip = "Ajuste la luminosite de la barre D4 avec les 2 textures de base uniquement. 100 = rendu source, en dessous assombrit, au-dessus eclaircit. [ID: C35]",
                min = 40,
                max = 140,
                step = 5,
                getFunc = function() return SETTINGS.D4_BAR_BRIGHTNESS or DEFAULT_SETTINGS.D4_BAR_BRIGHTNESS end,
                setFunc = function(value)
                    SETTINGS.D4_BAR_BRIGHTNESS = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BAR_BRIGHTNESS,
                width = "full",
            },
            {
                type = "slider",
                name = "Offset slot raccourci D4 (px)",
                tooltip = "Deplace l'objet de raccourci (quickslot) a gauche ou droite dans la barre D4. Utile pour recaler l'alignement apres changement de taille. [ID: C36]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_BAR_QUICKSLOT_OFFSET_X or DEFAULT_SETTINGS.D4_BAR_QUICKSLOT_OFFSET_X end,
                setFunc = function(value)
                    SETTINGS.D4_BAR_QUICKSLOT_OFFSET_X = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BAR_QUICKSLOT_OFFSET_X,
                width = "full",
            },
            {
                type = "slider",
                name = "Offset slot ultime D4 (px)",
                tooltip = "Deplace le slot ultime a gauche ou droite dans la barre D4 (negatif = vers la gauche). Utile pour recaler l'alignement apres changement de taille. [ID: C37]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_BAR_ULTIMATE_OFFSET_X or DEFAULT_SETTINGS.D4_BAR_ULTIMATE_OFFSET_X end,
                setFunc = function(value)
                    SETTINGS.D4_BAR_ULTIMATE_OFFSET_X = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BAR_ULTIMATE_OFFSET_X,
                width = "full",
            },
            {
                type = "slider",
                name = "Offset vertical 5 slots - solo bar (px)",
                tooltip = "Deplace les 5 slots centraux en mode solo. [ID: C38]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_BAR_SLOTS_OFFSET_Y or DEFAULT_SETTINGS.D4_BAR_SLOTS_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.D4_BAR_SLOTS_OFFSET_Y = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BAR_SLOTS_OFFSET_Y,
                width = "half",
            },
            {
                type = "slider",
                name = "Offset vertical 5 slots - dual bar (px)",
                tooltip = "Deplace les 5 slots centraux en mode dual. [ID: C39]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_BAR_SLOTS_OFFSET_Y_DUAL or DEFAULT_SETTINGS.D4_BAR_SLOTS_OFFSET_Y_DUAL end,
                setFunc = function(value)
                    SETTINGS.D4_BAR_SLOTS_OFFSET_Y_DUAL = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BAR_SLOTS_OFFSET_Y_DUAL,
                width = "half",
            },
            {
                type = "slider",
                name = "Offset vertical slot raccourci D4 (px)",
                tooltip = "Deplace l'objet de raccourci (quickslot) vers le haut ou bas independamment du fond de barre. [ID: C40]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_BAR_QUICKSLOT_OFFSET_Y or DEFAULT_SETTINGS.D4_BAR_QUICKSLOT_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.D4_BAR_QUICKSLOT_OFFSET_Y = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BAR_QUICKSLOT_OFFSET_Y,
                width = "full",
            },
            {
                type = "slider",
                name = "Offset vertical slot ultime D4 (px)",
                tooltip = "Deplace le slot ultime vers le haut ou bas independamment du fond de barre. [ID: C41]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.D4_BAR_ULTIMATE_OFFSET_Y or DEFAULT_SETTINGS.D4_BAR_ULTIMATE_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.D4_BAR_ULTIMATE_OFFSET_Y = value
                    RefreshTheme(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BAR_ULTIMATE_OFFSET_Y,
                width = "full",
            },
            {
                type = "slider",
                name = "Reflet au repos D4 (%)",
                tooltip = "Intensite du reflet permanent hors alerte ressource. [ID: C42]",
                min = 0,
                max = 60,
                step = 1,
                getFunc = function() return SETTINGS.D4_IDLE_HIGHLIGHT_ALPHA or DEFAULT_SETTINGS.D4_IDLE_HIGHLIGHT_ALPHA end,
                setFunc = function(value)
                    SETTINGS.D4_IDLE_HIGHLIGHT_ALPHA = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_IDLE_HIGHLIGHT_ALPHA,
                width = "full",
            },
            {
                type = "slider",
                name = "Ombre minimale D4 (%)",
                tooltip = "Force une ombre interne minimale pour verifier l'imbrication des couches. [ID: C43]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.D4_MIN_SHADE_ALPHA or DEFAULT_SETTINGS.D4_MIN_SHADE_ALPHA end,
                setFunc = function(value)
                    SETTINGS.D4_MIN_SHADE_ALPHA = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.D4_MIN_SHADE_ALPHA,
                width = "full",
            },
            {
                type = "header",
                name = "Backbar (barre inactive D4)",
            },
            {
                type = "description",
                text = "Affiche les slots de la barre inactive en arriere-plan en mode dual. Seul le mode D4 est concerne.",
                width = "full",
            },
            {
                type = "slider",
                name = "Offset horizontal (px)",
                tooltip = "Decale la backbar vers la gauche ou la droite par rapport a la barre active. [ID: C44]",
                min = -200,
                max = 200,
                step = 1,
                getFunc = function() return SETTINGS.D4_BACKBAR_OFFSET_X or DEFAULT_SETTINGS.D4_BACKBAR_OFFSET_X end,
                setFunc = function(value)
                    SETTINGS.D4_BACKBAR_OFFSET_X = value
                    ApplyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BACKBAR_OFFSET_X,
                width = "full",
            },
            {
                type = "slider",
                name = "Offset vertical (px)",
                tooltip = "Decale la backbar vers le haut (negatif) ou le bas par rapport a la barre active. Par defaut -28 pour voir environ 20% des slots. [ID: C45]",
                min = -200,
                max = 200,
                step = 1,
                getFunc = function() return SETTINGS.D4_BACKBAR_OFFSET_Y or DEFAULT_SETTINGS.D4_BACKBAR_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.D4_BACKBAR_OFFSET_Y = value
                    ApplyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BACKBAR_OFFSET_Y,
                width = "full",
            },
            {
                type = "slider",
                name = "Opacite (%)",
                tooltip = "Transparence de la backbar. 0 = invisible, 100 = opaque. [ID: C46]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.D4_BACKBAR_ALPHA or DEFAULT_SETTINGS.D4_BACKBAR_ALPHA end,
                setFunc = function(value)
                    SETTINGS.D4_BACKBAR_ALPHA = value
                    ApplyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BACKBAR_ALPHA,
                width = "half",
            },
            {
                type = "slider",
                name = "Desaturation (%)",
                tooltip = "Desature les icones de la backbar pour les distinguer visuellement de la barre active. [ID: C47]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.D4_BACKBAR_DESATURATION or DEFAULT_SETTINGS.D4_BACKBAR_DESATURATION end,
                setFunc = function(value)
                    SETTINGS.D4_BACKBAR_DESATURATION = value
                    ApplyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BACKBAR_DESATURATION,
                width = "half",
            },
            {
                type = "slider",
                name = "Echelle (%)",
                tooltip = "Taille des slots de la backbar. 80 = plus petits que la barre active pour accentuer la profondeur. [ID: C48]",
                min = 30,
                max = 120,
                step = 1,
                getFunc = function() return SETTINGS.D4_BACKBAR_SCALE or DEFAULT_SETTINGS.D4_BACKBAR_SCALE end,
                setFunc = function(value)
                    SETTINGS.D4_BACKBAR_SCALE = value
                    ApplyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BACKBAR_SCALE,
                width = "full",
            },
            {
                type = "slider",
                name = "Taille slots backbar (px)",
                tooltip = "Taille de chaque icone de la backbar en pixels. [ID: C49]",
                min = 20,
                max = 64,
                step = 1,
                getFunc = function() return SETTINGS.D4_BACKBAR_SLOT_SIZE or DEFAULT_SETTINGS.D4_BACKBAR_SLOT_SIZE end,
                setFunc = function(value)
                    SETTINGS.D4_BACKBAR_SLOT_SIZE = value
                    ApplyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BACKBAR_SLOT_SIZE,
                width = "half",
            },
            {
                type = "slider",
                name = "Espacement slots (px)",
                tooltip = "Ecart entre chaque slot de competence de la backbar. [ID: C50]",
                min = 0,
                max = 20,
                step = 1,
                getFunc = function() return SETTINGS.D4_BACKBAR_SLOT_GAP or DEFAULT_SETTINGS.D4_BACKBAR_SLOT_GAP end,
                setFunc = function(value)
                    SETTINGS.D4_BACKBAR_SLOT_GAP = value
                    ApplyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BACKBAR_SLOT_GAP,
                width = "half",
            },
            {
                type = "slider",
                name = "Ecart ultime (px)",
                tooltip = "Espace supplementaire entre le slot 5 et l'ultime. [ID: C51]",
                min = 0,
                max = 60,
                step = 1,
                getFunc = function() return SETTINGS.D4_BACKBAR_ULT_GAP or DEFAULT_SETTINGS.D4_BACKBAR_ULT_GAP end,
                setFunc = function(value)
                    SETTINGS.D4_BACKBAR_ULT_GAP = value
                    ApplyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BACKBAR_ULT_GAP,
                width = "half",
            },
            {
                type = "slider",
                name = "Offset X ultime (px)",
                tooltip = "Decale l'ultime horizontalement par rapport au slot 5. [ID: C52]",
                min = -30,
                max = 30,
                step = 1,
                getFunc = function() return SETTINGS.D4_BACKBAR_ULT_OFFSET_X or DEFAULT_SETTINGS.D4_BACKBAR_ULT_OFFSET_X end,
                setFunc = function(value)
                    SETTINGS.D4_BACKBAR_ULT_OFFSET_X = value
                    ApplyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BACKBAR_ULT_OFFSET_X,
                width = "half",
            },
            {
                type = "slider",
                name = "Offset Y ultime (px)",
                tooltip = "Decale l'ultime verticalement par rapport aux autres slots. [ID: C53]",
                min = -30,
                max = 30,
                step = 1,
                getFunc = function() return SETTINGS.D4_BACKBAR_ULT_OFFSET_Y or DEFAULT_SETTINGS.D4_BACKBAR_ULT_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.D4_BACKBAR_ULT_OFFSET_Y = value
                    ApplyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.D4_BACKBAR_ULT_OFFSET_Y,
                width = "half",
            },
            },
        },
        {
            type = "submenu",
            name = "Legacy — Fond et backbar",
            controls = {
            {
                type = "header",
                name = "Slots — Solo",
            },
            -- Legacy solo
            {
                type = "slider",
                name = "Ecart horizontal des 5 slots (px)",
                tooltip = "Ajuste l'ecart des 5 slots centraux en Legacy solo. [ID: C11b]",
                min = -20, max = 30, step = 1,
                getFunc = function() return SETTINGS.LEGACY_SOLO_ACTION_BAR_CENTER_SLOTS_GAP_X or DEFAULT_SETTINGS.LEGACY_SOLO_ACTION_BAR_CENTER_SLOTS_GAP_X end,
                setFunc = function(value) SETTINGS.LEGACY_SOLO_ACTION_BAR_CENTER_SLOTS_GAP_X = value ; RefreshTheme(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_SOLO_ACTION_BAR_CENTER_SLOTS_GAP_X,
                width = "full", disabled = AreActionBarSlotsDisabled,
            },
            {
                type = "slider",
                name = "Ecart ultime depuis le bord (px)",
                tooltip = "Decale le slot ultime en Legacy solo. [ID: C11c]",
                min = -50, max = 50, step = 1,
                getFunc = function() return SETTINGS.LEGACY_SOLO_ULTIMATE_OFFSET_X or DEFAULT_SETTINGS.LEGACY_SOLO_ULTIMATE_OFFSET_X end,
                setFunc = function(value) SETTINGS.LEGACY_SOLO_ULTIMATE_OFFSET_X = value ; RefreshTheme(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_SOLO_ULTIMATE_OFFSET_X,
                width = "half", disabled = AreActionBarSlotsDisabled,
            },
            {
                type = "slider",
                name = "Ecart raccourci depuis le bord (px)",
                tooltip = "Decale le slot raccourci en Legacy solo. [ID: C11d]",
                min = -50, max = 50, step = 1,
                getFunc = function() return SETTINGS.LEGACY_SOLO_QUICKSLOT_OFFSET_X or DEFAULT_SETTINGS.LEGACY_SOLO_QUICKSLOT_OFFSET_X end,
                setFunc = function(value) SETTINGS.LEGACY_SOLO_QUICKSLOT_OFFSET_X = value ; RefreshTheme(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_SOLO_QUICKSLOT_OFFSET_X,
                width = "half", disabled = AreActionBarSlotsDisabled,
            },
            -- Legacy dual
            {
                type = "header",
                name = "Slots — Dual",
            },
            {
                type = "slider",
                name = "Ecart horizontal des 5 slots (px)",
                tooltip = "Ajuste l'ecart des 5 slots centraux en Legacy dual. [ID: C11e]",
                min = -20, max = 30, step = 1,
                getFunc = function() return SETTINGS.LEGACY_DUAL_ACTION_BAR_CENTER_SLOTS_GAP_X or DEFAULT_SETTINGS.LEGACY_DUAL_ACTION_BAR_CENTER_SLOTS_GAP_X end,
                setFunc = function(value) SETTINGS.LEGACY_DUAL_ACTION_BAR_CENTER_SLOTS_GAP_X = value ; RefreshTheme(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_DUAL_ACTION_BAR_CENTER_SLOTS_GAP_X,
                width = "full", disabled = AreActionBarSlotsDisabled,
            },
            {
                type = "slider",
                name = "Ecart ultime depuis le bord (px)",
                tooltip = "Decale le slot ultime en Legacy dual. [ID: C11f]",
                min = -50, max = 50, step = 1,
                getFunc = function() return SETTINGS.LEGACY_DUAL_ULTIMATE_OFFSET_X or DEFAULT_SETTINGS.LEGACY_DUAL_ULTIMATE_OFFSET_X end,
                setFunc = function(value) SETTINGS.LEGACY_DUAL_ULTIMATE_OFFSET_X = value ; RefreshTheme(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_DUAL_ULTIMATE_OFFSET_X,
                width = "half", disabled = AreActionBarSlotsDisabled,
            },
            {
                type = "slider",
                name = "Ecart raccourci depuis le bord (px)",
                tooltip = "Decale le slot raccourci en Legacy dual. [ID: C11g]",
                min = -50, max = 50, step = 1,
                getFunc = function() return SETTINGS.LEGACY_DUAL_QUICKSLOT_OFFSET_X or DEFAULT_SETTINGS.LEGACY_DUAL_QUICKSLOT_OFFSET_X end,
                setFunc = function(value) SETTINGS.LEGACY_DUAL_QUICKSLOT_OFFSET_X = value ; RefreshTheme(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_DUAL_QUICKSLOT_OFFSET_X,
                width = "half", disabled = AreActionBarSlotsDisabled,
            },
            -- Fond solo
            {
                type = "header",
                name = "Fond solo (ActionBarXp)",
            },
            {
                type = "slider", name = "Middle : largeur (px)", tooltip = "Largeur du fond solo Middle. [ID: LS01]",
                min = 100, max = 800, step = 2,
                getFunc = function() return SETTINGS.LEGACY_BG_SOLO_MIDDLE_WIDTH or DEFAULT_SETTINGS.LEGACY_BG_SOLO_MIDDLE_WIDTH end,
                setFunc = function(v) SETTINGS.LEGACY_BG_SOLO_MIDDLE_WIDTH = v ; ApplyThemeTexturesToControls(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_BG_SOLO_MIDDLE_WIDTH, width = "half",
            },
            {
                type = "slider", name = "Middle : hauteur (px)", tooltip = "Hauteur du fond solo Middle. [ID: LS02]",
                min = 50, max = 512, step = 2,
                getFunc = function() return SETTINGS.LEGACY_BG_SOLO_MIDDLE_HEIGHT or DEFAULT_SETTINGS.LEGACY_BG_SOLO_MIDDLE_HEIGHT end,
                setFunc = function(v) SETTINGS.LEGACY_BG_SOLO_MIDDLE_HEIGHT = v ; ApplyThemeTexturesToControls(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_BG_SOLO_MIDDLE_HEIGHT, width = "half",
            },
            {
                type = "slider", name = "Middle : offset X (px)", tooltip = "Decale le Middle horizontalement. [ID: LS03]",
                min = -200, max = 200, step = 1,
                getFunc = function() return SETTINGS.LEGACY_BG_SOLO_MIDDLE_OFFSET_X or DEFAULT_SETTINGS.LEGACY_BG_SOLO_MIDDLE_OFFSET_X end,
                setFunc = function(v) SETTINGS.LEGACY_BG_SOLO_MIDDLE_OFFSET_X = v ; ApplyThemeTexturesToControls(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_BG_SOLO_MIDDLE_OFFSET_X, width = "half",
            },
            {
                type = "slider", name = "Middle : offset Y (px)", tooltip = "Decale le Middle verticalement. [ID: LS04]",
                min = -200, max = 200, step = 1,
                getFunc = function() return SETTINGS.LEGACY_BG_SOLO_MIDDLE_OFFSET_Y or DEFAULT_SETTINGS.LEGACY_BG_SOLO_MIDDLE_OFFSET_Y end,
                setFunc = function(v) SETTINGS.LEGACY_BG_SOLO_MIDDLE_OFFSET_Y = v ; ApplyThemeTexturesToControls(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_BG_SOLO_MIDDLE_OFFSET_Y, width = "half",
            },
            {
                type = "slider", name = "Left : overlap X (px)", tooltip = "Chevauchement du Left sur le Middle. [ID: LS05]",
                min = -200, max = 200, step = 1,
                getFunc = function() return SETTINGS.LEGACY_BG_SOLO_LEFT_OFFSET_X or DEFAULT_SETTINGS.LEGACY_BG_SOLO_LEFT_OFFSET_X end,
                setFunc = function(v) SETTINGS.LEGACY_BG_SOLO_LEFT_OFFSET_X = v ; ApplyThemeTexturesToControls(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_BG_SOLO_LEFT_OFFSET_X, width = "half",
            },
            {
                type = "slider", name = "Right : overlap X (px)", tooltip = "Chevauchement du Right sur le Middle. [ID: LS06]",
                min = -200, max = 200, step = 1,
                getFunc = function() return SETTINGS.LEGACY_BG_SOLO_RIGHT_OFFSET_X or DEFAULT_SETTINGS.LEGACY_BG_SOLO_RIGHT_OFFSET_X end,
                setFunc = function(v) SETTINGS.LEGACY_BG_SOLO_RIGHT_OFFSET_X = v ; ApplyThemeTexturesToControls(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_BG_SOLO_RIGHT_OFFSET_X, width = "half",
            },
            -- Fond dual
            {
                type = "header",
                name = "Fond dual (DiabloOrbsDualBarXp)",
            },
            {
                type = "slider", name = "Middle : largeur (px)", tooltip = "Largeur du fond dual Middle. [ID: LD01]",
                min = 100, max = 800, step = 2,
                getFunc = function() return SETTINGS.LEGACY_BG_DUAL_MIDDLE_WIDTH or DEFAULT_SETTINGS.LEGACY_BG_DUAL_MIDDLE_WIDTH end,
                setFunc = function(v) SETTINGS.LEGACY_BG_DUAL_MIDDLE_WIDTH = v ; ApplyThemeTexturesToControls(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_BG_DUAL_MIDDLE_WIDTH, width = "half",
                disabled = function() return not IsLegacyShowBackbar() end,
            },
            {
                type = "slider", name = "Middle : hauteur (px)", tooltip = "Hauteur du fond dual Middle. [ID: LD02]",
                min = 50, max = 512, step = 2,
                getFunc = function() return SETTINGS.LEGACY_BG_DUAL_MIDDLE_HEIGHT or DEFAULT_SETTINGS.LEGACY_BG_DUAL_MIDDLE_HEIGHT end,
                setFunc = function(v) SETTINGS.LEGACY_BG_DUAL_MIDDLE_HEIGHT = v ; ApplyThemeTexturesToControls(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_BG_DUAL_MIDDLE_HEIGHT, width = "half",
                disabled = function() return not IsLegacyShowBackbar() end,
            },
            {
                type = "slider", name = "Middle : offset X (px)", tooltip = "Decale le Middle dual horizontalement. [ID: LD03]",
                min = -200, max = 200, step = 1,
                getFunc = function() return SETTINGS.LEGACY_BG_DUAL_MIDDLE_OFFSET_X or DEFAULT_SETTINGS.LEGACY_BG_DUAL_MIDDLE_OFFSET_X end,
                setFunc = function(v) SETTINGS.LEGACY_BG_DUAL_MIDDLE_OFFSET_X = v ; ApplyThemeTexturesToControls(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_BG_DUAL_MIDDLE_OFFSET_X, width = "half",
                disabled = function() return not IsLegacyShowBackbar() end,
            },
            {
                type = "slider", name = "Middle : offset Y (px)", tooltip = "Decale le Middle dual verticalement. [ID: LD04]",
                min = -200, max = 200, step = 1,
                getFunc = function() return SETTINGS.LEGACY_BG_DUAL_MIDDLE_OFFSET_Y or DEFAULT_SETTINGS.LEGACY_BG_DUAL_MIDDLE_OFFSET_Y end,
                setFunc = function(v) SETTINGS.LEGACY_BG_DUAL_MIDDLE_OFFSET_Y = v ; ApplyThemeTexturesToControls(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_BG_DUAL_MIDDLE_OFFSET_Y, width = "half",
                disabled = function() return not IsLegacyShowBackbar() end,
            },
            {
                type = "slider", name = "Left : overlap X (px)", tooltip = "Chevauchement du Left dual sur le Middle. [ID: LD05]",
                min = -200, max = 200, step = 1,
                getFunc = function() return SETTINGS.LEGACY_BG_DUAL_LEFT_OFFSET_X or DEFAULT_SETTINGS.LEGACY_BG_DUAL_LEFT_OFFSET_X end,
                setFunc = function(v) SETTINGS.LEGACY_BG_DUAL_LEFT_OFFSET_X = v ; ApplyThemeTexturesToControls(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_BG_DUAL_LEFT_OFFSET_X, width = "half",
                disabled = function() return not IsLegacyShowBackbar() end,
            },
            {
                type = "slider", name = "Right : overlap X (px)", tooltip = "Chevauchement du Right dual sur le Middle. [ID: LD06]",
                min = -200, max = 200, step = 1,
                getFunc = function() return SETTINGS.LEGACY_BG_DUAL_RIGHT_OFFSET_X or DEFAULT_SETTINGS.LEGACY_BG_DUAL_RIGHT_OFFSET_X end,
                setFunc = function(v) SETTINGS.LEGACY_BG_DUAL_RIGHT_OFFSET_X = v ; ApplyThemeTexturesToControls(topLevelCtrl) end,
                default = DEFAULT_SETTINGS.LEGACY_BG_DUAL_RIGHT_OFFSET_X, width = "half",
                disabled = function() return not IsLegacyShowBackbar() end,
            },
            {
                type = "slider",
                name = "Offset horizontal (px)",
                tooltip = "Decale la backbar Legacy vers la gauche ou la droite. [ID: L02]",
                min = -200, max = 200, step = 1,
                getFunc = function() return SETTINGS.LEGACY_BACKBAR_OFFSET_X or DEFAULT_SETTINGS.LEGACY_BACKBAR_OFFSET_X end,
                setFunc = function(value)
                    SETTINGS.LEGACY_BACKBAR_OFFSET_X = value
                    ApplyLegacyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.LEGACY_BACKBAR_OFFSET_X,
                width = "full",
                disabled = function() return not IsLegacyShowBackbar() end,
            },
            {
                type = "slider",
                name = "Offset vertical (px)",
                tooltip = "Decale la backbar Legacy vers le haut (negatif) ou le bas. [ID: L03]",
                min = -200, max = 200, step = 1,
                getFunc = function() return SETTINGS.LEGACY_BACKBAR_OFFSET_Y or DEFAULT_SETTINGS.LEGACY_BACKBAR_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.LEGACY_BACKBAR_OFFSET_Y = value
                    ApplyLegacyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.LEGACY_BACKBAR_OFFSET_Y,
                width = "full",
                disabled = function() return not IsLegacyShowBackbar() end,
            },
            {
                type = "slider",
                name = "Opacite (%)",
                tooltip = "Transparence des icones de la backbar Legacy. [ID: L04]",
                min = 0, max = 100, step = 1,
                getFunc = function() return SETTINGS.LEGACY_BACKBAR_ALPHA or DEFAULT_SETTINGS.LEGACY_BACKBAR_ALPHA end,
                setFunc = function(value)
                    SETTINGS.LEGACY_BACKBAR_ALPHA = value
                    ApplyLegacyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.LEGACY_BACKBAR_ALPHA,
                width = "half",
                disabled = function() return not IsLegacyShowBackbar() end,
            },
            {
                type = "slider",
                name = "Desaturation (%)",
                tooltip = "Desature les icones pour les distinguer de la barre active. [ID: L05]",
                min = 0, max = 100, step = 1,
                getFunc = function() return SETTINGS.LEGACY_BACKBAR_DESATURATION or DEFAULT_SETTINGS.LEGACY_BACKBAR_DESATURATION end,
                setFunc = function(value)
                    SETTINGS.LEGACY_BACKBAR_DESATURATION = value
                    ApplyLegacyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.LEGACY_BACKBAR_DESATURATION,
                width = "half",
                disabled = function() return not IsLegacyShowBackbar() end,
            },
            {
                type = "slider",
                name = "Echelle (%)",
                tooltip = "Taille globale de la backbar Legacy. [ID: L06]",
                min = 30, max = 120, step = 1,
                getFunc = function() return SETTINGS.LEGACY_BACKBAR_SCALE or DEFAULT_SETTINGS.LEGACY_BACKBAR_SCALE end,
                setFunc = function(value)
                    SETTINGS.LEGACY_BACKBAR_SCALE = value
                    ApplyLegacyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.LEGACY_BACKBAR_SCALE,
                width = "full",
                disabled = function() return not IsLegacyShowBackbar() end,
            },
            {
                type = "slider",
                name = "Taille slots (px)",
                tooltip = "Taille de chaque icone en pixels. [ID: L07]",
                min = 20, max = 64, step = 1,
                getFunc = function() return SETTINGS.LEGACY_BACKBAR_SLOT_SIZE or DEFAULT_SETTINGS.LEGACY_BACKBAR_SLOT_SIZE end,
                setFunc = function(value)
                    SETTINGS.LEGACY_BACKBAR_SLOT_SIZE = value
                    ApplyLegacyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.LEGACY_BACKBAR_SLOT_SIZE,
                width = "half",
                disabled = function() return not IsLegacyShowBackbar() end,
            },
            {
                type = "slider",
                name = "Espacement slots (px)",
                tooltip = "Ecart entre chaque slot. [ID: L08]",
                min = 0, max = 20, step = 1,
                getFunc = function() return SETTINGS.LEGACY_BACKBAR_SLOT_GAP or DEFAULT_SETTINGS.LEGACY_BACKBAR_SLOT_GAP end,
                setFunc = function(value)
                    SETTINGS.LEGACY_BACKBAR_SLOT_GAP = value
                    ApplyLegacyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.LEGACY_BACKBAR_SLOT_GAP,
                width = "half",
                disabled = function() return not IsLegacyShowBackbar() end,
            },
            {
                type = "slider",
                name = "Ecart ultime (px)",
                tooltip = "Espace supplementaire entre le slot 5 et l'ultime. [ID: L09]",
                min = 0, max = 60, step = 1,
                getFunc = function() return SETTINGS.LEGACY_BACKBAR_ULT_GAP or DEFAULT_SETTINGS.LEGACY_BACKBAR_ULT_GAP end,
                setFunc = function(value)
                    SETTINGS.LEGACY_BACKBAR_ULT_GAP = value
                    ApplyLegacyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.LEGACY_BACKBAR_ULT_GAP,
                width = "half",
                disabled = function() return not IsLegacyShowBackbar() end,
            },
            {
                type = "slider",
                name = "Offset X ultime (px)",
                tooltip = "Decale l'ultime horizontalement. [ID: L10]",
                min = -30, max = 30, step = 1,
                getFunc = function() return SETTINGS.LEGACY_BACKBAR_ULT_OFFSET_X or DEFAULT_SETTINGS.LEGACY_BACKBAR_ULT_OFFSET_X end,
                setFunc = function(value)
                    SETTINGS.LEGACY_BACKBAR_ULT_OFFSET_X = value
                    ApplyLegacyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.LEGACY_BACKBAR_ULT_OFFSET_X,
                width = "half",
                disabled = function() return not IsLegacyShowBackbar() end,
            },
            {
                type = "slider",
                name = "Offset Y ultime (px)",
                tooltip = "Decale l'ultime verticalement. [ID: L11]",
                min = -30, max = 30, step = 1,
                getFunc = function() return SETTINGS.LEGACY_BACKBAR_ULT_OFFSET_Y or DEFAULT_SETTINGS.LEGACY_BACKBAR_ULT_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.LEGACY_BACKBAR_ULT_OFFSET_Y = value
                    ApplyLegacyBackbarLayout(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.LEGACY_BACKBAR_ULT_OFFSET_Y,
                width = "half",
                disabled = function() return not IsLegacyShowBackbar() end,
            },
            },
        },
        {
            type = "submenu",
            name = "Jauge ultime",
            controls = {
            {
                type = "header",
                name = "Jauge",
            },
            {
                type = "checkbox",
                name = "Afficher la jauge d'ultime",
                tooltip = "Affiche ou masque la jauge d'ultime au centre de la barre d'action. [ID: D01]",
                getFunc = function() return GetThemeSetting("SHOW_ULTIMATE_BAR") end,
                setFunc = function(value)
                    SetThemeSetting("SHOW_ULTIMATE_BAR", value)
                    local line = GetControl(topLevelCtrl, "Line")
                    line:SetHidden(not value)
                    local lineValue = GetOrCreateUltimateTextLabel(topLevelCtrl)
                    if lineValue ~= nil then
                        lineValue:SetHidden((not value) or (not SETTINGS.SHOW_ULTIMATE_TEXT))
                    end
                    updateUltimate(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.SHOW_ULTIMATE_BAR end,
                width = "full",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "description",
                text = "Reglages independants par theme (D4 ou Legacy), avec valeurs distinctes solo/dual.",
                width = "full",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "slider",
                name = "Opacite remplissage jauge (%)",
                tooltip = "Attenue la jauge d'ultime sans impacter le texte affiche dessus. [ID: D02]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return GetThemeSetting("ULTIMATE_BAR_FILL_ALPHA") end,
                setFunc = function(value)
                    SetThemeSetting("ULTIMATE_BAR_FILL_ALPHA", value)
                    updateUltimate(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.ULTIMATE_BAR_FILL_ALPHA end,
                width = "full",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "header",
                name = "Fond",
            },
            {
                type = "description",
                text = "Le fond suit le theme actif (D4: fond_jauge.dds, Legacy: UltimateGaugeBackground.dds). Les sliders ci-dessous pilotent taille/offset/opacite.",
                width = "full",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "checkbox",
                name = "Afficher fond de jauge ultime",
                tooltip = "Affiche le fond decoratif derriere la jauge d'ultime. [ID: D03]",
                getFunc = function() return GetThemeSetting("SHOW_ULTIMATE_BAR_BACKGROUND") ~= false end,
                setFunc = function(value)
                    SetThemeSetting("SHOW_ULTIMATE_BAR_BACKGROUND", value)
                    RefreshTheme(topLevelCtrl)
                    updateUltimate(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.SHOW_ULTIMATE_BAR_BACKGROUND end,
                width = "full",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "slider",
                name = "Opacite fond de jauge (%)",
                tooltip = "Regle la transparence du fond de jauge sans toucher au texte. [ID: D04]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return GetThemeSetting("ULTIMATE_BAR_BG_ALPHA") end,
                setFunc = function(value)
                    SetThemeSetting("ULTIMATE_BAR_BG_ALPHA", value)
                    RefreshTheme(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.ULTIMATE_BAR_BG_ALPHA end,
                width = "full",
                disabled = function() return IsActionBarUltimateWidgetDisabledLocal() or GetThemeSetting("SHOW_ULTIMATE_BAR_BACKGROUND") == false end,
            },
            {
                type = "colorpicker",
                name = "Couleur du fond de jauge",
                tooltip = "Teinte appliquee au fond de jauge. [ID: D05]",
                getFunc = function()
                    return GetThemeSetting("ULTIMATE_BAR_BG_COLOR_R"), GetThemeSetting("ULTIMATE_BAR_BG_COLOR_G"), GetThemeSetting("ULTIMATE_BAR_BG_COLOR_B"), 1
                end,
                setFunc = function(r, g, b)
                    SetThemeSetting("ULTIMATE_BAR_BG_COLOR_R", r)
                    SetThemeSetting("ULTIMATE_BAR_BG_COLOR_G", g)
                    SetThemeSetting("ULTIMATE_BAR_BG_COLOR_B", b)
                    RefreshTheme(topLevelCtrl)
                end,
                default = function()
                    return DEFAULT_SETTINGS.ULTIMATE_BAR_BG_COLOR_R, DEFAULT_SETTINGS.ULTIMATE_BAR_BG_COLOR_G, DEFAULT_SETTINGS.ULTIMATE_BAR_BG_COLOR_B, 1
                end,
                width = "full",
                disabled = function() return IsActionBarUltimateWidgetDisabledLocal() or GetThemeSetting("SHOW_ULTIMATE_BAR_BACKGROUND") == false end,
            },
            {
                type = "slider",
                name = "Largeur fond jauge solo (%)",
                tooltip = "Ajuste la largeur du fond de jauge en mode solo. [ID: D06]",
                min = 50,
                max = 180,
                step = 1,
                getFunc = function() return GetThemeSetting("ULTIMATE_BAR_BG_SOLO_WIDTH_SCALE") end,
                setFunc = function(value)
                    SetThemeSetting("ULTIMATE_BAR_BG_SOLO_WIDTH_SCALE", value)
                    RefreshTheme(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.ULTIMATE_BAR_BG_SOLO_WIDTH_SCALE end,
                width = "half",
                disabled = function() return IsActionBarUltimateWidgetDisabledLocal() or GetThemeSetting("SHOW_ULTIMATE_BAR_BACKGROUND") == false end,
            },
            {
                type = "slider",
                name = "Hauteur fond jauge solo (px)",
                tooltip = "Ajuste la hauteur du fond de jauge en mode solo. [ID: D07]",
                min = 4,
                max = 64,
                step = 1,
                getFunc = function() return GetThemeSetting("ULTIMATE_BAR_BG_SOLO_HEIGHT") end,
                setFunc = function(value)
                    SetThemeSetting("ULTIMATE_BAR_BG_SOLO_HEIGHT", value)
                    RefreshTheme(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.ULTIMATE_BAR_BG_SOLO_HEIGHT end,
                width = "half",
                disabled = function() return IsActionBarUltimateWidgetDisabledLocal() or GetThemeSetting("SHOW_ULTIMATE_BAR_BACKGROUND") == false end,
            },
            {
                type = "slider",
                name = "Offset vertical fond jauge solo (px)",
                tooltip = "Monte ou descend le fond de jauge en mode solo. [ID: D08]",
                min = -60,
                max = 60,
                step = 1,
                getFunc = function() return GetThemeSetting("ULTIMATE_BAR_BG_SOLO_OFFSET_Y") end,
                setFunc = function(value)
                    SetThemeSetting("ULTIMATE_BAR_BG_SOLO_OFFSET_Y", value)
                    RefreshTheme(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.ULTIMATE_BAR_BG_SOLO_OFFSET_Y end,
                width = "half",
                disabled = function() return IsActionBarUltimateWidgetDisabledLocal() or GetThemeSetting("SHOW_ULTIMATE_BAR_BACKGROUND") == false end,
            },
            {
                type = "slider",
                name = "Largeur fond jauge dual (%)",
                tooltip = "Ajuste la largeur du fond de jauge en mode dual. [ID: D09]",
                min = 50,
                max = 180,
                step = 1,
                getFunc = function() return GetThemeSetting("ULTIMATE_BAR_BG_DUAL_WIDTH_SCALE") end,
                setFunc = function(value)
                    SetThemeSetting("ULTIMATE_BAR_BG_DUAL_WIDTH_SCALE", value)
                    RefreshTheme(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.ULTIMATE_BAR_BG_DUAL_WIDTH_SCALE end,
                width = "half",
                disabled = function() return IsActionBarUltimateWidgetDisabledLocal() or GetThemeSetting("SHOW_ULTIMATE_BAR_BACKGROUND") == false end,
            },
            {
                type = "slider",
                name = "Hauteur fond jauge dual (px)",
                tooltip = "Ajuste la hauteur du fond de jauge en mode dual. [ID: D10]",
                min = 4,
                max = 64,
                step = 1,
                getFunc = function() return GetThemeSetting("ULTIMATE_BAR_BG_DUAL_HEIGHT") end,
                setFunc = function(value)
                    SetThemeSetting("ULTIMATE_BAR_BG_DUAL_HEIGHT", value)
                    RefreshTheme(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.ULTIMATE_BAR_BG_DUAL_HEIGHT end,
                width = "half",
                disabled = function() return IsActionBarUltimateWidgetDisabledLocal() or GetThemeSetting("SHOW_ULTIMATE_BAR_BACKGROUND") == false end,
            },
            {
                type = "slider",
                name = "Offset vertical fond jauge dual (px)",
                tooltip = "Monte ou descend le fond de jauge en mode dual. [ID: D11]",
                min = -60,
                max = 60,
                step = 1,
                getFunc = function() return GetThemeSetting("ULTIMATE_BAR_BG_DUAL_OFFSET_Y") end,
                setFunc = function(value)
                    SetThemeSetting("ULTIMATE_BAR_BG_DUAL_OFFSET_Y", value)
                    RefreshTheme(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.ULTIMATE_BAR_BG_DUAL_OFFSET_Y end,
                width = "half",
                disabled = function() return IsActionBarUltimateWidgetDisabledLocal() or GetThemeSetting("SHOW_ULTIMATE_BAR_BACKGROUND") == false end,
            },
            {
                type = "slider",
                name = "Largeur jauge ultime solo (%)",
                tooltip = "Ajuste la largeur de la jauge ultime en mode solo. [ID: D12]",
                min = 50,
                max = 180,
                step = 1,
                getFunc = function() return GetThemeSetting("ULTIMATE_BAR_SOLO_WIDTH_SCALE") end,
                setFunc = function(value)
                    SetThemeSetting("ULTIMATE_BAR_SOLO_WIDTH_SCALE", value)
                    RefreshTheme(topLevelCtrl)
                    updateUltimate(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.ULTIMATE_BAR_SOLO_WIDTH_SCALE end,
                width = "half",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "slider",
                name = "Hauteur jauge ultime solo (px)",
                tooltip = "Ajuste l'epaisseur verticale de la jauge ultime en mode solo. [ID: D13]",
                min = 2,
                max = 24,
                step = 1,
                getFunc = function() return GetThemeSetting("ULTIMATE_BAR_SOLO_HEIGHT") end,
                setFunc = function(value)
                    SetThemeSetting("ULTIMATE_BAR_SOLO_HEIGHT", value)
                    RefreshTheme(topLevelCtrl)
                    updateUltimate(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.ULTIMATE_BAR_SOLO_HEIGHT end,
                width = "half",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "slider",
                name = "Offset vertical jauge ultime solo (px)",
                tooltip = "Monte ou descend la jauge ultime en mode solo. [ID: D14]",
                min = -60,
                max = 60,
                step = 1,
                getFunc = function() return GetThemeSetting("ULTIMATE_BAR_SOLO_OFFSET_Y") end,
                setFunc = function(value)
                    SetThemeSetting("ULTIMATE_BAR_SOLO_OFFSET_Y", value)
                    RefreshTheme(topLevelCtrl)
                    updateUltimate(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.ULTIMATE_BAR_SOLO_OFFSET_Y end,
                width = "half",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "slider",
                name = "Largeur jauge ultime dual (%)",
                tooltip = "Ajuste la largeur de la jauge ultime en mode dual. [ID: D15]",
                min = 50,
                max = 180,
                step = 1,
                getFunc = function() return GetThemeSetting("ULTIMATE_BAR_DUAL_WIDTH_SCALE") end,
                setFunc = function(value)
                    SetThemeSetting("ULTIMATE_BAR_DUAL_WIDTH_SCALE", value)
                    RefreshTheme(topLevelCtrl)
                    updateUltimate(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.ULTIMATE_BAR_DUAL_WIDTH_SCALE end,
                width = "half",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "slider",
                name = "Hauteur jauge ultime dual (px)",
                tooltip = "Ajuste l'epaisseur verticale de la jauge ultime en mode dual. [ID: D16]",
                min = 2,
                max = 24,
                step = 1,
                getFunc = function() return GetThemeSetting("ULTIMATE_BAR_DUAL_HEIGHT") end,
                setFunc = function(value)
                    SetThemeSetting("ULTIMATE_BAR_DUAL_HEIGHT", value)
                    RefreshTheme(topLevelCtrl)
                    updateUltimate(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.ULTIMATE_BAR_DUAL_HEIGHT end,
                width = "half",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "slider",
                name = "Offset vertical jauge ultime dual (px)",
                tooltip = "Monte ou descend la jauge ultime en mode dual. [ID: D17]",
                min = -60,
                max = 60,
                step = 1,
                getFunc = function() return GetThemeSetting("ULTIMATE_BAR_DUAL_OFFSET_Y") end,
                setFunc = function(value)
                    SetThemeSetting("ULTIMATE_BAR_DUAL_OFFSET_Y", value)
                    RefreshTheme(topLevelCtrl)
                    updateUltimate(topLevelCtrl)
                end,
                default = function() return DEFAULT_SETTINGS.ULTIMATE_BAR_DUAL_OFFSET_Y end,
                width = "half",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "header",
                name = "Texte",
            },
            {
                type = "description",
                text = "Le texte ultime est independant du pulse de la jauge et reste lisible en permanence.",
                width = "full",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "checkbox",
                name = "Afficher le texte actuel/cout sur la jauge",
                tooltip = "Affiche le texte de progression d'ultime directement sur la jauge centrale. [ID: D18]",
                getFunc = function() return SETTINGS.SHOW_ULTIMATE_TEXT end,
                setFunc = function(value)
                    SETTINGS.SHOW_ULTIMATE_TEXT = value
                    local lineValue = GetOrCreateUltimateTextLabel(topLevelCtrl)
                    if lineValue ~= nil then
                        lineValue:SetHidden((not value) or (not GetThemeSetting("SHOW_ULTIMATE_BAR")))
                    end
                    updateUltimate(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.SHOW_ULTIMATE_TEXT,
                width = "full",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "dropdown",
                name = "Format du texte d'ultime",
                tooltip = "Choisit le format affiche sur la jauge ultime. [ID: D19]",
                choices = { "Valeur (actuel/cout)", "Pourcentage" },
                choicesValues = { "value", "percent" },
                getFunc = function() return SETTINGS.ULTIMATE_TEXT_MODE end,
                setFunc = function(value)
                    SETTINGS.ULTIMATE_TEXT_MODE = value
                    updateUltimate(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.ULTIMATE_TEXT_MODE,
                width = "full",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "slider",
                name = "Taille police texte ultime",
                tooltip = "Regle la taille de la police du texte affiche sur la jauge ultime. [ID: D20]",
                min = 10,
                max = 36,
                step = 1,
                getFunc = function() return SETTINGS.ULTIMATE_TEXT_FONT_SIZE or DEFAULT_SETTINGS.ULTIMATE_TEXT_FONT_SIZE end,
                setFunc = function(value)
                    SETTINGS.ULTIMATE_TEXT_FONT_SIZE = value
                    updateUltimate(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.ULTIMATE_TEXT_FONT_SIZE,
                width = "full",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "slider",
                name = "Opacite texte ultime (%)",
                tooltip = "Regle l'opacite du texte de la jauge ultime sans affecter le pulse de la barre. [ID: D21]",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SETTINGS.ULTIMATE_TEXT_ALPHA or DEFAULT_SETTINGS.ULTIMATE_TEXT_ALPHA end,
                setFunc = function(value)
                    SETTINGS.ULTIMATE_TEXT_ALPHA = value
                    updateUltimate(topLevelCtrl)
                end,
                default = DEFAULT_SETTINGS.ULTIMATE_TEXT_ALPHA,
                width = "full",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "colorpicker",
                name = "Couleur texte ultime",
                tooltip = "Choisit la couleur du texte affiche sur la jauge ultime. [ID: D22]",
                getFunc = function()
                    return SETTINGS.ULTIMATE_TEXT_COLOR_R or DEFAULT_SETTINGS.ULTIMATE_TEXT_COLOR_R,
                           SETTINGS.ULTIMATE_TEXT_COLOR_G or DEFAULT_SETTINGS.ULTIMATE_TEXT_COLOR_G,
                           SETTINGS.ULTIMATE_TEXT_COLOR_B or DEFAULT_SETTINGS.ULTIMATE_TEXT_COLOR_B,
                           1
                end,
                setFunc = function(r, g, b)
                    SETTINGS.ULTIMATE_TEXT_COLOR_R = r
                    SETTINGS.ULTIMATE_TEXT_COLOR_G = g
                    SETTINGS.ULTIMATE_TEXT_COLOR_B = b
                    updateUltimate(topLevelCtrl)
                end,
                default = {
                    DEFAULT_SETTINGS.ULTIMATE_TEXT_COLOR_R,
                    DEFAULT_SETTINGS.ULTIMATE_TEXT_COLOR_G,
                    DEFAULT_SETTINGS.ULTIMATE_TEXT_COLOR_B,
                },
                width = "full",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "colorpicker",
                name = "Couleur quand ultime est prete",
                tooltip = "Couleur appliquee a la jauge centrale quand l'ultime est prete. [ID: D23]",
                getFunc = function()
                    return SETTINGS.ULTIMATE_READY_COLOR_R, SETTINGS.ULTIMATE_READY_COLOR_G, SETTINGS.ULTIMATE_READY_COLOR_B, 1
                end,
                setFunc = function(r, g, b, a)
                    SETTINGS.ULTIMATE_READY_COLOR_R = r
                    SETTINGS.ULTIMATE_READY_COLOR_G = g
                    SETTINGS.ULTIMATE_READY_COLOR_B = b
                    updateUltimate(topLevelCtrl)
                end,
                default = function()
                    return DEFAULT_SETTINGS.ULTIMATE_READY_COLOR_R, DEFAULT_SETTINGS.ULTIMATE_READY_COLOR_G, DEFAULT_SETTINGS.ULTIMATE_READY_COLOR_B, 1
                end,
                width = "full",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "slider",
                name = "Vitesse pulse ultime",
                tooltip = "Vitesse du clignotement quand l'ultime est prete. [ID: D24]",
                min = 5,
                max = 40,
                step = 1,
                getFunc = function() return zo_round(SETTINGS.ULTIMATE_PULSE_SPEED * 10) end,
                setFunc = function(value)
                    SETTINGS.ULTIMATE_PULSE_SPEED = value / 10
                    updateUltimate(topLevelCtrl)
                end,
                default = zo_round(DEFAULT_SETTINGS.ULTIMATE_PULSE_SPEED * 10),
                width = "full",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "slider",
                name = "Pulse alpha min (%)",
                tooltip = "Opacite minimale du pulse de la jauge ultime. [ID: D25]",
                min = 10,
                max = 100,
                step = 5,
                getFunc = function() return zo_round(SETTINGS.ULTIMATE_PULSE_MIN_ALPHA * 100) end,
                setFunc = function(value)
                    SETTINGS.ULTIMATE_PULSE_MIN_ALPHA = value / 100
                    updateUltimate(topLevelCtrl)
                end,
                default = zo_round(DEFAULT_SETTINGS.ULTIMATE_PULSE_MIN_ALPHA * 100),
                width = "full",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            {
                type = "slider",
                name = "Pulse alpha max (%)",
                tooltip = "Opacite maximale du pulse de la jauge ultime. [ID: D26]",
                min = 10,
                max = 100,
                step = 5,
                getFunc = function() return zo_round(SETTINGS.ULTIMATE_PULSE_MAX_ALPHA * 100) end,
                setFunc = function(value)
                    SETTINGS.ULTIMATE_PULSE_MAX_ALPHA = value / 100
                    updateUltimate(topLevelCtrl)
                end,
                default = zo_round(DEFAULT_SETTINGS.ULTIMATE_PULSE_MAX_ALPHA * 100),
                width = "full",
                disabled = IsActionBarUltimateWidgetDisabledLocal,
            },
            },
        },
        {
            type = "submenu",
            name = "Alertes",
            controls = {
            {
                type = "header",
                name = "Alertes",
            },
            {
                type = "slider",
                name = "Seuil alerte ressources (%)",
                tooltip = "Declenche l'effet glow quand une ressource passe sous ce pourcentage. [ID: F01]",
                min = 5,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.LOW_RESOURCE_WARNING_PERCENT end,
                setFunc = function(value)
                    SETTINGS.LOW_RESOURCE_WARNING_PERCENT = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.LOW_RESOURCE_WARNING_PERCENT,
                width = "full",
            },
            {
                type = "slider",
                name = "Intensite max du glow d'alerte (%)",
                tooltip = "Intensite maximale de l'aureole lumineuse autour des orbes lors d'une alerte ressource. [ID: F02]",
                min = 10,
                max = 100,
                step = 5,
                getFunc = function() return zo_round(SETTINGS.GLOW_MAX_ALPHA * 100) end,
                setFunc = function(value)
                    SETTINGS.GLOW_MAX_ALPHA = value / 100
                    RefreshAllBars()
                end,
                default = zo_round(DEFAULT_SETTINGS.GLOW_MAX_ALPHA * 100),
                width = "full",
            },
            {
                type = "checkbox",
                name = "Activer le glow d'alerte pour seuil bas",
                tooltip = "Active un glow d'alerte lorsqu'une ressource tombe sous le seuil. [ID: F03]",
                getFunc = function() return SETTINGS.LOW_RESOURCE_GLOW_ALERT_ENABLED end,
                setFunc = function(value)
                    SETTINGS.LOW_RESOURCE_GLOW_ALERT_ENABLED = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_ENABLED,
                width = "full",
            },
            {
                type = "checkbox",
                name = "Fractionner alerte orbe combine",
                tooltip = "En mode legacy, chaque moitie (mana/endurance) gere son propre etat d'alerte. [ID: F04]",
                getFunc = function() return SETTINGS.LOW_RESOURCE_FRACTIONATE_COMBINED end,
                setFunc = function(value)
                    SETTINGS.LOW_RESOURCE_FRACTIONATE_COMBINED = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.LOW_RESOURCE_FRACTIONATE_COMBINED,
                width = "full",
            },
            {
                type = "colorpicker",
                name = "Couleur glow d'alerte Sante (RGB)",
                tooltip = "Couleur du glow d'alerte basse ressource pour l'orbe de sante. [ID: F05]",
                getFunc = function() return SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_R, SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_G, SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_B, 1 end,
                setFunc = function(r, g, b, a)
                    SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_R = r
                    SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_G = g
                    SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_B = b
                    RefreshAllBars()
                end,
                default = function() return DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_R, DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_G, DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_B, 1 end,
                width = "full",
            },
            {
                type = "colorpicker",
                name = "Couleur glow d'alerte Magie (RGB)",
                tooltip = "Couleur du glow d'alerte basse ressource pour l'orbe de magie. [ID: F06]",
                getFunc = function() return SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_R, SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_G, SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_B, 1 end,
                setFunc = function(r, g, b, a)
                    SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_R = r
                    SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_G = g
                    SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_B = b
                    RefreshAllBars()
                end,
                default = function() return DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_R, DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_G, DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_B, 1 end,
                width = "full",
            },
            {
                type = "colorpicker",
                name = "Couleur glow d'alerte Endurance (RGB)",
                tooltip = "Couleur du glow d'alerte basse ressource pour l'orbe d'endurance. [ID: F07]",
                getFunc = function() return SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_R, SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_G, SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_B, 1 end,
                setFunc = function(r, g, b, a)
                    SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_R = r
                    SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_G = g
                    SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_B = b
                    RefreshAllBars()
                end,
                default = function() return DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_R, DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_G, DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_B, 1 end,
                width = "full",
            },
            {
                type = "slider",
                name = "Opacite glow d'alerte (%)",
                tooltip = "Opacite du glow d'alerte basse ressource. [ID: F08]",
                min = 0,
                max = 100,
                step = 5,
                getFunc = function() return SETTINGS.LOW_RESOURCE_GLOW_ALERT_ALPHA end,
                setFunc = function(value)
                    SETTINGS.LOW_RESOURCE_GLOW_ALERT_ALPHA = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_ALPHA,
                width = "full",
            },
            {
                type = "slider",
                name = "Taille glow d'alerte (%)",
                tooltip = "Taille du glow d'alerte basse ressource par rapport a la taille normale du glow. 100 = identique. [ID: F08b]",
                min = 50,
                max = 200,
                step = 5,
                getFunc = function() return SETTINGS.LOW_RESOURCE_GLOW_ALERT_SIZE or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_SIZE end,
                setFunc = function(value)
                    SETTINGS.LOW_RESOURCE_GLOW_ALERT_SIZE = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_SIZE,
                width = "full",
            },
            {
                type = "checkbox",
                name = "Glow interne strict (sans debordement)",
                tooltip = "Active un glow contenu a l'interieur des orbes. Desactive = glow plus dramatique qui depasse un peu. [ID: F09]",
                getFunc = function() return SETTINGS.GLOW_INTERNAL_ONLY end,
                setFunc = function(value)
                    SETTINGS.GLOW_INTERNAL_ONLY = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.GLOW_INTERNAL_ONLY,
                width = "full",
            },
            {
                type = "slider",
                name = "Ecart des glows depuis le centre (px)",
                tooltip = "Eloigne ou rapproche les glows de magicka et stamina par rapport au centre. Augmentez pour plus d'ecart. [ID: F10]",
                min = 10,
                max = 120,
                step = 1,
                getFunc = function() return SETTINGS.GLOW_CENTER_GAP_X or DEFAULT_SETTINGS.GLOW_CENTER_GAP_X end,
                setFunc = function(value)
                    SETTINGS.GLOW_CENTER_GAP_X = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.GLOW_CENTER_GAP_X,
                width = "full",
                disabled = function() return SETTINGS.GLOW_INTERNAL_ONLY end,
            },
            {
                type = "slider",
                name = "Offset vertical glow miroir (px)",
                tooltip = "Deplace verticalement les deux glows en meme temps, en conservant le miroir parfait gauche/droite. [ID: F11]",
                min = -80,
                max = 80,
                step = 1,
                getFunc = function() return SETTINGS.GLOW_OFFSET_Y or DEFAULT_SETTINGS.GLOW_OFFSET_Y end,
                setFunc = function(value)
                    SETTINGS.GLOW_OFFSET_Y = value
                    RefreshAllBars()
                end,
                default = DEFAULT_SETTINGS.GLOW_OFFSET_Y,
                width = "full",
            },
            {
                type = "checkbox",
                name = "Activer le pulse de couleur sur le cadre",
                tooltip = "Quand la ressource est faible, le cadre ornemental pulse dans la couleur d'alerte choisie. [ID: F12]",
                getFunc = function() return GetThemeSetting("BORDER_PULSE_ENABLED") end,
                setFunc = function(value)
                    SetThemeSetting("BORDER_PULSE_ENABLED", value)
                    RefreshAllBars()
                end,
                default = function() return DEFAULT_SETTINGS.BORDER_PULSE_ENABLED end,
                width = "full",
            },
            {
                type = "colorpicker",
                name = "Couleur du pulse d'alerte",
                tooltip = "Couleur du cadre quand la ressource est faible. Defaut : rouge. [ID: F13]",
                getFunc = function() return GetThemeSetting("BORDER_PULSE_R"), GetThemeSetting("BORDER_PULSE_G"), GetThemeSetting("BORDER_PULSE_B"), 1 end,
                setFunc = function(r, g, b, a)
                    SetThemeSetting("BORDER_PULSE_R", r)
                    SetThemeSetting("BORDER_PULSE_G", g)
                    SetThemeSetting("BORDER_PULSE_B", b)
                    RefreshAllBars()
                end,
                default = function() return DEFAULT_SETTINGS.BORDER_PULSE_R, DEFAULT_SETTINGS.BORDER_PULSE_G, DEFAULT_SETTINGS.BORDER_PULSE_B, 1 end,
                width = "full",
            },
            },
        },
        -- --------------------------------------------------------
    }

    -- Peupler dynamiquement le dropdown des profils
    for _, ctrl in ipairs(optionsData) do
        if ctrl.type == "submenu" and ctrl.controls then
            for _, subCtrl in ipairs(ctrl.controls) do
                if subCtrl.reference == "DiabloOrbs_ProfileDropdown" then
                    subCtrl.choices = ListProfiles()
                    subCtrl.choicesValues = ListProfiles()
                    break
                end
            end
        end
    end

    LocalizeOptionsData(optionsData)

    LAM2:RegisterAddonPanel(panelId, panelData)
    LAM2:RegisterOptionControls(panelId, optionsData)
end

-------------------------------------------------------------------------------------------------
-- Modify default styles --
local function GetCompanionUltimateButton()
    return ZO_ActionBar_GetButton(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1, HOTBAR_CATEGORY_COMPANION)
end

local function ForEachManagedActionButton(includeCompanion, callback)
    if callback == nil then
        return
    end

    local quickSlotButton = ZO_ActionBar_GetButton(1, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    callback(quickSlotButton, 1, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)

    for i = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + ACTION_BAR_SLOTS_PER_PAGE - 1 do
        local actionButton = ZO_ActionBar_GetButton(i)
        callback(actionButton, i, HOTBAR_CATEGORY_PRIMARY)
    end

    local ultimateSlotIndex = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1
    local ultimateButton = ZO_ActionBar_GetButton(ultimateSlotIndex)
    callback(ultimateButton, ultimateSlotIndex, HOTBAR_CATEGORY_PRIMARY)

    if includeCompanion then
        local companionButton = GetCompanionUltimateButton()
        callback(companionButton, ultimateSlotIndex, HOTBAR_CATEGORY_COMPANION)
    end
end

local function SetManagedActionBarSlotsHidden(hidden)
    ForEachManagedActionButton(true, function(button)
        if button ~= nil and button.slot ~= nil then
            button.slot:SetHidden(hidden)
        end
    end)
end

local function SetD4SpellSlotBorderVisible(slotControl, visible)
    if slotControl == nil then
        return
    end

    local border = GetControl(slotControl, "D4SpellSlotBorder")
    local smoke = GetControl(slotControl, "D4SpellSlotSmoke")
    if not visible then
        if border ~= nil then
            border:SetHidden(true)
        end
        if smoke ~= nil then
            smoke:SetHidden(true)
        end
        return
    end

    if border == nil then
        local name = slotControl:GetName() .. "D4SpellSlotBorder"
        border = WINDOW_MANAGER:CreateControl(name, slotControl, CT_TEXTURE)
        border:SetDrawLayer(1)
        border:SetDrawLevel(40)
    end

    if smoke == nil then
        local name = slotControl:GetName() .. "D4SpellSlotSmoke"
        smoke = WINDOW_MANAGER:CreateControl(name, slotControl, CT_TEXTURE)
        smoke:SetDrawLayer(1)
        smoke:SetDrawLevel(34)
    end

    border:ClearAnchors()
    border:SetAnchor(CENTER, slotControl, CENTER, 0, 0)
    border:SetDimensions(52, 52)
    border:SetTexture(ThemeManager:GetTexturePath("D4SpellSlotBorder.dds"))
    local companionButton = GetCompanionUltimateButton()
    local isCompanionSlot = companionButton ~= nil and companionButton.slot == slotControl
    local baseDarkness = zo_max(0, zo_min(100, SETTINGS.D4_SLOT_BORDER_DARKNESS or DEFAULT_SETTINGS.D4_SLOT_BORDER_DARKNESS))
    local companionDarkness = isCompanionSlot and (SETTINGS.D4_COMPANION_SLOT_BORDER_DARKNESS or DEFAULT_SETTINGS.D4_COMPANION_SLOT_BORDER_DARKNESS) or 0
    local darknessPercent = zo_max(0, zo_min(100, baseDarkness + companionDarkness))
    local contrast = zo_max(50, zo_min(200, SETTINGS.D4_SLOT_BORDER_CONTRAST or DEFAULT_SETTINGS.D4_SLOT_BORDER_CONTRAST)) / 100
    local tone = 1 - (darknessPercent / 100)
    tone = Clamp01(((tone - 0.5) * contrast) + 0.5)
    border:SetColor(tone, tone, tone, 1)
    local isDual = IsActionBarCurrentlyDual()
    local alphaSetting = isDual and SETTINGS.D4_SLOT_HIGHLIGHT_DUAL_ALPHA or SETTINGS.D4_SLOT_HIGHLIGHT_SOLO_ALPHA
    if alphaSetting == nil then
        alphaSetting = SETTINGS.D4_SLOT_HIGHLIGHT_ALPHA or DEFAULT_SETTINGS.D4_SLOT_HIGHLIGHT_ALPHA
    end
    local globalAlphaSetting = SETTINGS.D4_ALL_SLOT_BORDER_ALPHA
    if globalAlphaSetting == nil then
        globalAlphaSetting = DEFAULT_SETTINGS.D4_ALL_SLOT_BORDER_ALPHA
    end
    local modeAlpha = zo_max(0, zo_min(100, alphaSetting)) / 100
    local globalAlpha = zo_max(0, zo_min(100, globalAlphaSetting)) / 100
    border:SetAlpha(modeAlpha * globalAlpha)
    border:SetHidden(false)

    local smokeIntensity = zo_max(0, zo_min(100, SETTINGS.D4_SLOT_SMOKE_INTENSITY or DEFAULT_SETTINGS.D4_SLOT_SMOKE_INTENSITY)) / 100
    smoke:SetHidden(smokeIntensity <= 0)
    if smokeIntensity > 0 then
        local boost = GetCurrentOrbColorBoost() / 100
        local hR, hG, hB = GetOrbColor(POWERTYPE_HEALTH)
        local mR, mG, mB = GetOrbColor(POWERTYPE_MAGICKA)
        local sR, sG, sB = GetOrbColor(POWERTYPE_STAMINA)
        local tintR = Clamp01((((hR + mR + sR) / 3) * boost) * 0.9)
        local tintG = Clamp01((((hG + mG + sG) / 3) * boost) * 0.9)
        local tintB = Clamp01((((hB + mB + sB) / 3) * boost) * 0.9)

        smoke:ClearAnchors()
        smoke:SetAnchor(TOPLEFT, slotControl, TOPLEFT, -3, -3)
        smoke:SetAnchor(BOTTOMRIGHT, slotControl, BOTTOMRIGHT, 3, 3)
        smoke:SetTexture(ThemeManager:GetTexturePath("Smoke.dds"))
        smoke:SetColor(tintR, tintG, tintB, 1)
        smoke:SetAlpha(smokeIntensity * 0.55)
    end
end

local function ApplyCenterSlotsGap(topLevelCtrl, style, actionBarContainer)
    if topLevelCtrl == nil or style == nil then
        return
    end

    local firstSlotIndex = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1
    local lastSlotIndex = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + ACTION_BAR_SLOTS_PER_PAGE - 1
    local centerSlotIndex = firstSlotIndex + zo_floor((ACTION_BAR_SLOTS_PER_PAGE - 1) / 2)
    local centerActionButton = ZO_ActionBar_GetButton(centerSlotIndex)
    if centerActionButton == nil or centerActionButton.slot == nil then
        return
    end

    local barParent = actionBarContainer or GetControl(topLevelCtrl, 'ActionBarContainer')
    if barParent == nil then
        return
    end

    local isD4Layout = (ThemeManager:GetCurrentTheme() == "d4")
    local gapOffsetSetting
    if isD4Layout then
        gapOffsetSetting = SETTINGS.ACTION_BAR_CENTER_SLOTS_GAP_X or DEFAULT_SETTINGS.ACTION_BAR_CENTER_SLOTS_GAP_X
    else
        local lmp = GetLegacyModePrefix()
        gapOffsetSetting = SETTINGS[lmp.."ACTION_BAR_CENTER_SLOTS_GAP_X"] or DEFAULT_SETTINGS[lmp.."ACTION_BAR_CENTER_SLOTS_GAP_X"]
    end

    local slotWidth = style.abilitySlotWidth or 50
    local baseGap = style.abilitySlotOffsetX or 0
    local finalGap = baseGap + gapOffsetSetting
    local minGap = -slotWidth + 4
    if finalGap < minGap then
        finalGap = minGap
    end

    local slotsOffsetY = 0
    if ThemeManager:GetCurrentTheme() == "d4" then
        local isDual = SETTINGS.D4_SHOW_OFFBAR ~= false
        local slotKey = isDual and "D4_BAR_SLOTS_OFFSET_Y_DUAL" or "D4_BAR_SLOTS_OFFSET_Y"
        slotsOffsetY = SETTINGS[slotKey] or DEFAULT_SETTINGS[slotKey]
    end

    for slotIndex = firstSlotIndex, lastSlotIndex do
        local button = ZO_ActionBar_GetButton(slotIndex)
        if button ~= nil and button.slot ~= nil then
            button.slot:ClearAnchors()
        end
    end

    centerActionButton.slot:SetAnchor(BOTTOM, barParent, BOTTOM, 0, slotsOffsetY)

    for offset = 1, zo_floor(ACTION_BAR_SLOTS_PER_PAGE / 2) do
        local leftButton = ZO_ActionBar_GetButton(centerSlotIndex - offset)
        local leftAnchorTarget = ZO_ActionBar_GetButton(centerSlotIndex - offset + 1)
        if leftButton ~= nil and leftButton.slot ~= nil and leftAnchorTarget ~= nil and leftAnchorTarget.slot ~= nil then
            leftButton.slot:SetAnchor(RIGHT, leftAnchorTarget.slot, LEFT, -finalGap, 0)
        end

        local rightButton = ZO_ActionBar_GetButton(centerSlotIndex + offset)
        local rightAnchorTarget = ZO_ActionBar_GetButton(centerSlotIndex + offset - 1)
        if rightButton ~= nil and rightButton.slot ~= nil and rightAnchorTarget ~= nil and rightAnchorTarget.slot ~= nil then
            rightButton.slot:SetAnchor(LEFT, rightAnchorTarget.slot, RIGHT, finalGap, 0)
        end
    end
end


-- Cache des contrôles avec SetDesaturation, indexé par le contrôle racine.
-- Evite de reparcourir le tree à chaque appel : on le construit une fois, on réutilise.
local desatControlsCache = {}

local function BuildDesatCache(control, result, depth)
    if control == nil or depth > 4 then return end
    if control.SetDesaturation ~= nil then
        result[#result + 1] = control
    end
    if control.GetNumChildren == nil or control.GetChild == nil then return end
    local childCount = control:GetNumChildren() or 0
    for i = 1, childCount do
        local child = control:GetChild(i)
        if child ~= nil then BuildDesatCache(child, result, depth + 1) end
    end
end

local function ApplyDesaturationToAll(rootControl, desaturation)
    if rootControl == nil then return end
    local cached = desatControlsCache[rootControl]
    if cached == nil then
        cached = {}
        BuildDesatCache(rootControl, cached, 0)
        desatControlsCache[rootControl] = cached
    end
    for i = 1, #cached do
        cached[i]:SetDesaturation(desaturation)
    end
end

local function ApplyActionBarVisualOptions(actionBarContainer)
    -- Compatibilité interne : alias local pour les quelques appels directs restants
    local function ApplyDesaturationRecursive(control, desaturation, depth)
        ApplyDesaturationToAll(control, desaturation)
    end

    local function ApplyHotkeyStateToButton(button, show, position)
        if button == nil or button.buttonText == nil then
            return
        end

        button.buttonText:SetHidden(not show)
        if not show then
            return
        end

        local anchorTarget = button.slot or button
        if anchorTarget == nil then
            return
        end

        if button.buttonText.ClearAnchors ~= nil then
            button.buttonText:ClearAnchors()
        end

        local hotkeyScale = zo_max(70, zo_min(180, SETTINGS.ACTION_BAR_HOTKEY_SCALE or DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_SCALE)) / 100
        local hotkeyAlpha = zo_max(10, zo_min(100, SETTINGS.ACTION_BAR_HOTKEY_ALPHA or DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_ALPHA)) / 100
        local hotkeyOffsetX = SETTINGS.ACTION_BAR_HOTKEY_OFFSET_X or DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_OFFSET_X
        local hotkeyOffsetY = SETTINGS.ACTION_BAR_HOTKEY_OFFSET_Y or DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_OFFSET_Y

        if button.buttonText.SetScale ~= nil then
            button.buttonText:SetScale(hotkeyScale)
        end
        if button.buttonText.SetAlpha ~= nil then
            button.buttonText:SetAlpha(hotkeyAlpha)
        end

        if position == "top" then
            button.buttonText:SetAnchor(BOTTOM, anchorTarget, TOP, hotkeyOffsetX, hotkeyOffsetY)
        elseif position == "inside" then
            button.buttonText:SetAnchor(CENTER, anchorTarget, CENTER, hotkeyOffsetX, hotkeyOffsetY)
        else
            button.buttonText:SetAnchor(TOP, anchorTarget, BOTTOM, hotkeyOffsetX, hotkeyOffsetY)
        end
    end

    if not IsActionBarModuleEnabled() then
        if ZO_ActionBar1WeaponSwap ~= nil then
            ZO_ActionBar1WeaponSwap:SetHidden(false)
            ZO_WeaponSwap_SetPermanentlyHidden(ZO_ActionBar1WeaponSwap, false)
        end

        if ZO_ActionBar1KeybindBG ~= nil then
            ZO_ActionBar1KeybindBG:SetHidden(false)
        end

        if not IsInGamepadPreferredMode() then
            ForEachManagedActionButton(true, function(button)
                ApplyHotkeyStateToButton(button, true, NormalizeActionBarHotkeyPosition(SETTINGS.ACTION_BAR_HOTKEY_POSITION))
            end)
        end

        SetManagedActionBarSlotsHidden(false)

        if actionBarContainer ~= nil then
            actionBarContainer:SetAlpha(1)
            ApplyDesaturationRecursive(actionBarContainer, 0, 0)
            actionBarContainer:SetHidden(true)
        end
            return
    end

    local showHotkeys = (SETTINGS ~= nil and SETTINGS.SHOW_ACTION_BAR_HOTKEYS == true)
    local hotkeysOnlyInCombat = (SETTINGS ~= nil and SETTINGS.ACTION_BAR_HOTKEY_ONLY_IN_COMBAT == true)
    if hotkeysOnlyInCombat and IsUnitInCombat ~= nil then
        showHotkeys = showHotkeys and IsUnitInCombat("player")
    end
    local hotkeyPosition = NormalizeActionBarHotkeyPosition(SETTINGS ~= nil and SETTINGS.ACTION_BAR_HOTKEY_POSITION)
    local showWeaponSwap = (SETTINGS ~= nil and SETTINGS.SHOW_ACTION_BAR_WEAPON_SWAP == true)
    local showSlots = AreActionBarSlotsEnabled()
    local showCompanionUltimate = showSlots and ((SETTINGS == nil) or (SETTINGS.SHOW_ACTION_BAR_COMPANION_ULTIMATE ~= false))

    SetManagedActionBarSlotsHidden(not showSlots)

    if ZO_ActionBar1WeaponSwap ~= nil then
        ZO_ActionBar1WeaponSwap:SetHidden(not showWeaponSwap)
        ZO_WeaponSwap_SetPermanentlyHidden(ZO_ActionBar1WeaponSwap, not showWeaponSwap)
    end

    if ZO_ActionBar1KeybindBG ~= nil then
        ZO_ActionBar1KeybindBG:SetHidden(not showHotkeys)
    end

    if showSlots and not IsInGamepadPreferredMode() then
        ForEachManagedActionButton(true, function(button)
            ApplyHotkeyStateToButton(button, showHotkeys, hotkeyPosition)
        end)
    end

    local companionButton = GetCompanionUltimateButton()
    if companionButton ~= nil and companionButton.slot ~= nil then
        companionButton.slot:SetHidden(not showCompanionUltimate)
    end

    if actionBarContainer ~= nil then
        -- Approche hybride D4 : l'actionBarContainer natif d'ESO affiche la barre inactive
        -- (icônes, animations cooldown) avec alpha/désaturation configurés.
        -- DiabloOrbs gère l'affichage complet via backbarContainer (icônes + glows custom).
        -- En thème Legacy : comportement standard alpha/désat.
        local inactiveAlphaSetting = SETTINGS.INACTIVE_BACK_BAR_ALPHA_DUAL
        if inactiveAlphaSetting == nil then
            inactiveAlphaSetting = SETTINGS.INACTIVE_BACK_BAR_ALPHA or DEFAULT_SETTINGS.INACTIVE_BACK_BAR_ALPHA
        end
        local inactiveDesaturationSetting = SETTINGS.INACTIVE_BACK_BAR_DESATURATION_DUAL
        if inactiveDesaturationSetting == nil then
            inactiveDesaturationSetting = SETTINGS.INACTIVE_BACK_BAR_DESATURATION or DEFAULT_SETTINGS.INACTIVE_BACK_BAR_DESATURATION
        end

        if ThemeManager:GetCurrentTheme() == "d4" then
            -- Mode D4 : on garde actionBarContainer visible pour conserver les animations
            -- de cooldown de la barre active (timers, effets visuels ESO natifs).
            actionBarContainer:SetHidden(not showSlots)
            actionBarContainer:SetAlpha(1)
            ApplyDesaturationRecursive(actionBarContainer, 0, 0)
        else
            local inactiveAlpha = zo_max(0, zo_min(100, inactiveAlphaSetting)) / 100
            local inactiveDesaturation = zo_max(0, zo_min(100, inactiveDesaturationSetting)) / 100
            actionBarContainer:SetHidden(not showSlots)
            actionBarContainer:SetAlpha(showSlots and inactiveAlpha or 1)
            ApplyDesaturationRecursive(actionBarContainer, showSlots and inactiveDesaturation or 0, 0)
            zo_callLater(function()
                local arrow = GetControl(actionBarContainer, "Arrow")
                if arrow ~= nil then
                    arrow:SetHidden((not showWeaponSwap) or (not showSlots))
                end
            end, 150)
        end
    end

end

ApplyD4SpellSlotBorders = function()
    local isD4Theme = IsActionBarModuleEnabled()
        and AreActionBarSlotsEnabled()
        and (ThemeManager:GetCurrentTheme() == "d4")
        and (SETTINGS == nil or SETTINGS.SHOW_D4_SLOT_BORDERS ~= false)

    ForEachManagedActionButton(true, function(button)
        if button ~= nil then
            SetD4SpellSlotBorderVisible(button.slot, isD4Theme)
        end
    end)
end

local function RestyleDoubleActionBar(topLevelCtrl, style, actionBarContainer)

    local anchorControl = ZO_ActionBar1:GetNamedChild('WeaponSwap')
    local barParent = GetControl(topLevelCtrl, 'ActionBarContainer')

    local quickSlotButton = ZO_ActionBar_GetButton(1, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    if quickSlotButton == nil or quickSlotButton.slot == nil then
        return
    end
    quickSlotButton.slot:ClearAnchors()

    -- D4: apply quickslot offset setting; Legacy: bare left-edge anchor
    if ThemeManager:GetCurrentTheme() == "d4" then
        local quickSlotOffsetX = SETTINGS.D4_BAR_QUICKSLOT_OFFSET_X or DEFAULT_SETTINGS.D4_BAR_QUICKSLOT_OFFSET_X
        local quickSlotOffsetY = SETTINGS.D4_BAR_QUICKSLOT_OFFSET_Y or DEFAULT_SETTINGS.D4_BAR_QUICKSLOT_OFFSET_Y
        quickSlotButton.slot:SetAnchor(LEFT, barParent, LEFT, quickSlotOffsetX, quickSlotOffsetY)
    else
        quickSlotButton.slot:SetAnchor(LEFT, barParent, LEFT)
    end

    anchorControl:ClearAnchors()
    anchorControl:SetAnchor(LEFT, barParent, LEFT, style.dualBarOffsetX, 0)
end

local function RestyleActionBar(topLevelCtrl, style, actionBarContainer)
    local isGamePad = IsInGamepadPreferredMode()
    local template = 'DiabloFrame'

    if not IsActionBarModuleEnabled() then
        ApplyActionBarSlotScale(1)
        ApplyActionBarVisualOptions(actionBarContainer)
        ApplyD4SpellSlotBorders()
        return
    end

    local companionButton = GetCompanionUltimateButton()
    if companionButton ~= nil and companionButton.slot ~= nil then
        companionButton.slot:ClearAnchors()
        companionButton.slot:SetAnchor(RIGHT, GuiRoot, RIGHT, -(style.abilitySlotOffsetX + 13), style.abilitySlotWidth)
    end

    ZO_HUDEquipmentStatus:ClearAnchors()
    ZO_HUDEquipmentStatus:SetAnchor(RIGHT, GuiRoot, RIGHT, -(style.abilitySlotOffsetX + 13), 0)

    local barParent = GetControl(topLevelCtrl, 'ActionBarContainer')
    local offsetX = ((style.abilitySlotWidth + style.abilitySlotOffsetX) * 5) / 2

    -- In D4 mode, scale offsetX to match the visual slot scale so center-5 stays
    -- aligned with quickslot (left) and ultimate (right) as the bar texture scales.
    if ThemeManager:GetCurrentTheme() == "d4" then
        local d4Scale = GetD4ActionBarSlotScale(style, actionBarContainer ~= nil)
        offsetX = offsetX * d4Scale
    end

    if actionBarContainer ~= nil then
        template = 'DiabloFrameDouble'
        RestyleDoubleActionBar(topLevelCtrl, style, actionBarContainer)
    else
        local quickSlotButton = ZO_ActionBar_GetButton(1, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
        if quickSlotButton == nil or quickSlotButton.slot == nil then
            return
        end
        quickSlotButton.slot:ClearAnchors()

        local firstActionButton = ZO_ActionBar_GetButton(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1)
        if firstActionButton == nil or firstActionButton.slot == nil then
            return
        end
        firstActionButton.slot:ClearAnchors()
        local slotsOffsetY = 0
        if ThemeManager:GetCurrentTheme() == "d4" then
            local isDual = SETTINGS.D4_SHOW_OFFBAR ~= false
            local slotKey = isDual and "D4_BAR_SLOTS_OFFSET_Y_DUAL" or "D4_BAR_SLOTS_OFFSET_Y"
            slotsOffsetY = SETTINGS[slotKey] or DEFAULT_SETTINGS[slotKey]
        end
        firstActionButton.slot:SetAnchor(BOTTOMLEFT, barParent, BOTTOM, -offsetX, slotsOffsetY)

        local ultimateButton = ZO_ActionBar_GetButton(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1)
        if ultimateButton == nil or ultimateButton.slot == nil then
            return
        end
        ultimateButton.slot:ClearAnchors()

        -- D4: apply per-slot offset settings for fine-tuning; Legacy: edge anchors
        if ThemeManager:GetCurrentTheme() == "d4" then
            local quickSlotOffsetX = SETTINGS.D4_BAR_QUICKSLOT_OFFSET_X or DEFAULT_SETTINGS.D4_BAR_QUICKSLOT_OFFSET_X
            local quickSlotOffsetY = SETTINGS.D4_BAR_QUICKSLOT_OFFSET_Y or DEFAULT_SETTINGS.D4_BAR_QUICKSLOT_OFFSET_Y
            local ultimateOffsetX  = SETTINGS.D4_BAR_ULTIMATE_OFFSET_X  or DEFAULT_SETTINGS.D4_BAR_ULTIMATE_OFFSET_X
            local ultimateOffsetY  = SETTINGS.D4_BAR_ULTIMATE_OFFSET_Y  or DEFAULT_SETTINGS.D4_BAR_ULTIMATE_OFFSET_Y
            -- Anchor relative to bar center (BOTTOM) using slot-based offsets,
            -- so changing the bar texture size does not move quickslot/ultimate.
            local slotWidth   = style.abilitySlotWidth or 50
            local slotSpacing = style.abilitySlotOffsetX or 0
            local gapSetting  = SETTINGS.ACTION_BAR_CENTER_SLOTS_GAP_X or DEFAULT_SETTINGS.ACTION_BAR_CENTER_SLOTS_GAP_X
            local finalGap    = slotSpacing + gapSetting
            local d4Scale     = GetD4ActionBarSlotScale(style, false)
            local halfSpan    = (5 * slotWidth + 4 * finalGap) / 2
            local edgeDist    = (halfSpan + finalGap + slotWidth / 2) * d4Scale
            local isDual = SETTINGS.D4_SHOW_OFFBAR ~= false
            local slotKey = isDual and "D4_BAR_SLOTS_OFFSET_Y_DUAL" or "D4_BAR_SLOTS_OFFSET_Y"
            local slotsOffsetY = SETTINGS[slotKey] or DEFAULT_SETTINGS[slotKey]
            quickSlotButton.slot:SetAnchor(BOTTOM, barParent, BOTTOM, -edgeDist + quickSlotOffsetX, slotsOffsetY + quickSlotOffsetY)
            ultimateButton.slot:SetAnchor(BOTTOM,  barParent, BOTTOM,  edgeDist + ultimateOffsetX,  slotsOffsetY + ultimateOffsetY)
        else
            local lmp2 = GetLegacyModePrefix()
            local legacyUltOffX   = SETTINGS[lmp2.."ULTIMATE_OFFSET_X"]  or DEFAULT_SETTINGS[lmp2.."ULTIMATE_OFFSET_X"]
            local legacyQuickOffX = SETTINGS[lmp2.."QUICKSLOT_OFFSET_X"] or DEFAULT_SETTINGS[lmp2.."QUICKSLOT_OFFSET_X"]
            quickSlotButton.slot:SetAnchor(BOTTOMLEFT,  barParent, BOTTOMLEFT,  legacyQuickOffX, 0)
            ultimateButton.slot:SetAnchor(BOTTOMRIGHT, barParent, BOTTOMRIGHT, -legacyUltOffX,  0)
        end
    end

    ApplyCenterSlotsGap(topLevelCtrl, style, actionBarContainer)

    -- Set TLC width manually instead of ApplyTemplateToControl to prevent
    -- orb/anchor reset on style re-apply (swimming, building exit, etc.).
    local isGamepad = IsInGamepadPreferredMode()
    if template == 'DiabloFrameDouble' then
        topLevelCtrl:SetWidth(isGamepad and 605 or 404)
    else
        topLevelCtrl:SetWidth(isGamepad and 560 or 400)
    end

    if ThemeManager:GetCurrentTheme() == "d4" then
        ApplyActionBarSlotScale(GetD4ActionBarSlotScale(style, actionBarContainer ~= nil))
    else
        ApplyActionBarSlotScale(1)
    end
    ApplyActionBarVisualOptions(actionBarContainer)
    ApplyD4SpellSlotBorders()
end

-------------------------------------------------------------------------------------------------
-- - --
-------------------------------------------------------------------------------------------------

local DiabloFramesStatusBar = ZO_Object:Subclass()
function DiabloFramesStatusBar:New(...)
    local bar = ZO_Object.New(self)
    bar:Initialize(...)
    return bar
end

function DiabloFramesStatusBar:Initialize(control, powerType)
    self.control = control
    self.glow = GetControl(control, 'Glow')
    self.smoke = GetControl(control, 'Smoke')
    self.smokeBg = GetControl(control, 'SmokeBg')
    self.borderShade = GetControl(control, 'BorderShade')
    self.border = GetControl(control, 'Border')
    self.borderOverlay = GetControl(control, 'BorderOverlay')
    self.split = GetControl(control, 'Split')
    -- Séparateur central stylisé (ligne nette + halo additif)
    if self.orbSeam == nil and (powerType == POWERTYPE_MAGICKA or powerType == POWERTYPE_STAMINA) then
        local name = control:GetName() .. 'OrbSeam'
        self.orbSeam = WINDOW_MANAGER:CreateControl(name, control, CT_TEXTURE)
        self.orbSeam:SetDrawLayer(1)
        self.orbSeam:SetDrawLevel(55)
        self.orbSeam:SetMouseEnabled(false)
        self.orbSeam:SetHidden(true)
    end
    if self.additiveOverlay == nil then
        local name = control:GetName() .. 'AdditiveOverlay'
        self.additiveOverlay = WINDOW_MANAGER:CreateControl(name, control, CT_TEXTURE)
        self.additiveOverlay:SetDrawLayer(1)
        self.additiveOverlay:SetDrawLevel(8)
        self.additiveOverlay:SetMouseEnabled(false)
        self.additiveOverlay:SetHidden(true)
    end
    if self.orbTintLayer == nil and (powerType == POWERTYPE_HEALTH or powerType == POWERTYPE_MAGICKA or powerType == POWERTYPE_STAMINA) then
        local name = control:GetName() .. 'OrbTintLayer'
        self.orbTintLayer = WINDOW_MANAGER:CreateControl(name, control, CT_TEXTURE)
        self.orbTintLayer:SetTexture("esoui/art/miscellaneous/white.dds")
        self.orbTintLayer:SetDrawLayer(1)
        self.orbTintLayer:SetDrawLevel(2)
        self.orbTintLayer:SetMouseEnabled(false)
        self.orbTintLayer:SetHidden(true)
    end
    self.label = GetControl(control, 'Label')
    self.powerType = powerType
    self.alwaysShowLabel = false
    self.isShield = (powerType == ATTRIBUTE_VISUAL_POWER_SHIELDING)
    self.value = 0
    self.min = 0
    self.max = 0
    self.lastLabelText = nil
    self.lastLabelScale = nil
    self.lastLabelFontKey = nil
    self.labelBaseFontFile = nil
    self.labelBaseFontHeight = nil
    self.labelBaseFontStyle = nil
    self.lastLabelHidden = nil
    self.lastRenderedPercent = nil
    self.lastVisualRevision = -1
    self.lastLowResourceState = nil
    self.lastBorderPulseState = nil
    self.lastGlowLayoutInternalOnly = nil
    if self.label ~= nil and self.label.GetFontInfo ~= nil then
        local fontFile, fontHeight, fontStyle = self.label:GetFontInfo()
        self.labelBaseFontFile = fontFile
        self.labelBaseFontHeight = fontHeight
        self.labelBaseFontStyle = fontStyle
    end
    local colorData = smokeBgColors[powerType]
    if colorData then
        self.smokeBgDark   = colorData.dark
        self.smokeBgBright = colorData.bright
    end
    local baseCoordLeft, baseCoordRight, baseAnchorX, ttIcon = unpack(powerSettings[powerType])
    self.baseCoordLeft = baseCoordLeft
    self.baseCoordRight = baseCoordRight
    self.baseAnchorX = baseAnchorX

    if self.glow ~= nil then
        self.glow:SetDrawLayer(1)
        self.glow:SetDrawLevel(60)
        self.glowAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("DiabloFrameGlowTemplate", self.glow)

        self.glow:SetHandler("OnMouseEnter", function(trigger)
            local hp = zo_round(self.value).." / "..zo_round(self.max)
            local text = zo_iconTextFormat(ttIcon, "70%", "70%", hp)
            if self.combinedSibling ~= nil and ThemeManager:GetCurrentTheme() == "d4" then
                local sib = self.combinedSibling
                local sibIcon = ({
                    [POWERTYPE_MAGICKA] = "esoui/art/icons/alchemy/crafting_alchemy_trait_restoremagicka.dds",
                    [POWERTYPE_STAMINA] = "esoui/art/icons/alchemy/crafting_alchemy_trait_restorestamina.dds",
                })[sib.powerType]
                local sibHp = zo_round(sib.value).." / "..zo_round(sib.max)
                if sibIcon then
                    text = text .. "\n" .. zo_iconTextFormat(sibIcon, "70%", "70%", sibHp)
                else
                    text = text .. "\n" .. sibHp
                end
            end
            InitializeTooltip(InformationTooltip, trigger, CENTER, 0, 25, TOP)
            SetTooltipText(InformationTooltip, text)
        end)
        self.glow:SetHandler("OnMouseExit", function()
            ClearTooltip(InformationTooltip)
        end)
    end

    if self.border ~= nil then
        self.borderPulseAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("DiabloFrameGlowTemplate", self.border)
    end
end

function DiabloFramesStatusBar:SetValue(value)
    if self.value == value then
        return
    end
    self.value = value
    self:ApplyTexture()
    self:ApplyAttributeLabel()
end

function DiabloFramesStatusBar:GetValue()
    return self.value
end

function DiabloFramesStatusBar:GetMax()
    return self.max
end

function DiabloFramesStatusBar:SetMinMax(min, max)
    if self.min == min and self.max == max then
        return
    end
    self.min = min
    self.max = max
end

function DiabloFramesStatusBar:ApplySmokeAlpha()
    self:ApplyTexture()
end

function DiabloFramesStatusBar:ApplyAttributeLabel()
    if self.label == nil then return end
    local fmt = NormalizeLabelFormat(GetThemeSetting("LABEL_FORMAT"))
    if GetThemeSetting("LABEL_FORMAT") ~= fmt then
        SetThemeSetting("LABEL_FORMAT", fmt)
    end
    local container = self.label:GetParent()
    local shouldHide = (fmt == "hidden")
    if self.isShield and (not IsShieldLabelEnabled()) then
        shouldHide = true
    end
    if self.alwaysShowLabel then
        shouldHide = false
    end

    if self.lastLabelHidden ~= shouldHide then
        container:SetHidden(shouldHide)
        self.lastLabelHidden = shouldHide
    end

    if fmt == "hidden" then
        return
    end

    local text
    if fmt == "percent" then
        local pct = (self.max ~= 0) and zo_round((self.value / self.max) * 100) or 0
        text = pct .. '%'
    elseif fmt == "full" then
        text = FormatFullOrbValue(self.value)
    else
        text = zo_round((self.value / 1000)) .. 'k'
    end

    if self.lastLabelText ~= text then
        self.label:SetText(text)
        self.lastLabelText = text
    end

    local currentFontKey = NormalizeNumberFontFamily(SETTINGS.NUMBER_FONT_FAMILY or DEFAULT_SETTINGS.NUMBER_FONT_FAMILY)
    local labelScale = GetThemeSetting("LABEL_SCALE")
    if self.lastLabelScale ~= labelScale or self.lastLabelFontKey ~= currentFontKey then
        ApplyValueLabelFont(
            self.label,
            labelScale,
            self.labelBaseFontFile,
            self.labelBaseFontHeight,
            self.labelBaseFontStyle
        )
        self.lastLabelScale = labelScale
        self.lastLabelFontKey = currentFontKey
    end

    local labelPositionMode = NormalizeLabelPositionMode(GetThemeSetting("LABEL_POSITION_MODE"))
    if GetThemeSetting("LABEL_POSITION_MODE") ~= labelPositionMode then
        SetThemeSetting("LABEL_POSITION_MODE", labelPositionMode)
    end
    local insideMode = (labelPositionMode == "inside")
    local effectiveInsideMode = insideMode and (not self.isShield)
    local labelStyle = NormalizeLabelInnerStyle(GetThemeSetting("LABEL_INNER_STYLE"))
    if GetThemeSetting("LABEL_INNER_STYLE") ~= labelStyle then
        SetThemeSetting("LABEL_INNER_STYLE", labelStyle)
    end
    local labelAlpha = zo_max(0, zo_min(100, GetThemeSetting("LABEL_TEXT_ALPHA"))) / 100
    local shadeAlpha = zo_max(0, zo_min(100, GetThemeSetting("LABEL_INNER_SHADE_ALPHA"))) / 100
    local backdropAlpha = zo_max(0, zo_min(100, GetThemeSetting("LABEL_INNER_BACKDROP_ALPHA"))) / 100
    local shadeR = Clamp01(GetThemeSetting("LABEL_INNER_SHADE_COLOR_R"))
    local shadeG = Clamp01(GetThemeSetting("LABEL_INNER_SHADE_COLOR_G"))
    local shadeB = Clamp01(GetThemeSetting("LABEL_INNER_SHADE_COLOR_B"))

    local labelOffsetY = GetThemeSetting("LABEL_OFFSET_Y")
    local labelGapX = GetThemeSetting("LABEL_CENTER_GAP_X")
    if container ~= nil and (self.powerType == POWERTYPE_HEALTH or self.powerType == POWERTYPE_MAGICKA or self.powerType == POWERTYPE_STAMINA or self.isShield) then
        if container.SetDrawLayer ~= nil and container.SetDrawLevel ~= nil then
            container:SetDrawLayer(1)
            container:SetDrawLevel(60)
        end
        if self.label.SetDrawLayer ~= nil and self.label.SetDrawLevel ~= nil then
            self.label:SetDrawLayer(1)
            self.label:SetDrawLevel(62)
        end
        ApplyValueLabelContainerSize(self.label, container, effectiveInsideMode)
        if self.isShield then
            local shieldOffsetX, shieldOffsetY = GetShieldLabelOffsets()
            container:ClearAnchors()
            container:SetAnchor(TOP, self.control, TOP, shieldOffsetX, shieldOffsetY)
        else
            ApplyValueLabelAnchor(container, self.control, self.powerType, effectiveInsideMode, labelGapX, labelOffsetY)
        end
    end

    local backdrop = self.labelBackdrop
    local shadowLabel = self.labelShadow
    if backdrop == nil and container ~= nil then
        local parentName = self.control and self.control.GetName and self.control:GetName()
        if parentName ~= nil and parentName ~= "" then
            local backdropName = parentName .. "LabelBackdrop"
            backdrop = _G[backdropName]
            if backdrop == nil then
                backdrop = WINDOW_MANAGER:CreateControl(backdropName, container, CT_TEXTURE)
                backdrop:SetDrawLayer(1)
                backdrop:SetDrawLevel(61)
                backdrop:SetMouseEnabled(false)
                backdrop:SetAnchorFill()
                backdrop:SetTexture("esoui/art/miscellaneous/white.dds")
            end
            self.labelBackdrop = backdrop
        end
    end
    if shadowLabel == nil and container ~= nil then
        local parentName = self.control and self.control.GetName and self.control:GetName()
        if parentName ~= nil and parentName ~= "" then
            local shadowLabelName = parentName .. "LabelShadow"
            shadowLabel = _G[shadowLabelName]
            if shadowLabel == nil then
                shadowLabel = WINDOW_MANAGER:CreateControl(shadowLabelName, container, CT_LABEL)
                shadowLabel:SetMouseEnabled(false)
                shadowLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
                shadowLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            end
            self.labelShadow = shadowLabel
        end
    end
    if backdrop ~= nil and backdrop.SetDrawLayer ~= nil and backdrop.SetDrawLevel ~= nil then
        backdrop:SetDrawLayer(1)
        backdrop:SetDrawLevel(60)
    end
    if shadowLabel ~= nil and shadowLabel.SetDrawLayer ~= nil and shadowLabel.SetDrawLevel ~= nil then
        shadowLabel:SetDrawLayer(1)
        shadowLabel:SetDrawLevel(61)
    end
    if shadowLabel ~= nil then
        shadowLabel:ClearAnchors()
        shadowLabel:SetAnchor(TOPLEFT, container, TOPLEFT, 1, 1)
        shadowLabel:SetDimensions(container:GetDimensions())
        shadowLabel:SetText(text)
        ApplyValueLabelFont(
            shadowLabel,
            GetThemeSetting("LABEL_SCALE"),
            self.labelBaseFontFile,
            self.labelBaseFontHeight,
            self.labelBaseFontStyle
        )
    end

    self.label:SetAlpha(labelAlpha)

    if effectiveInsideMode and (labelStyle ~= "none") and (not shouldHide) then
        if labelStyle == "dark" then
            self.label:SetColor(0.08, 0.08, 0.08, 1)
            if backdrop ~= nil then
                backdrop:SetHidden(backdropAlpha <= 0)
                backdrop:SetColor(shadeR, shadeG, shadeB, 0.72 * backdropAlpha)
            end
            if shadowLabel ~= nil then
                shadowLabel:SetHidden(shadeAlpha <= 0)
                shadowLabel:SetColor(shadeR, shadeG, shadeB, shadeAlpha)
                shadowLabel:SetAlpha(labelAlpha)
            end
        else
            self.label:SetColor(1, 1, 1, 1)
            if backdrop ~= nil then
                backdrop:SetHidden(backdropAlpha <= 0)
                backdrop:SetColor(shadeR, shadeG, shadeB, backdropAlpha)
            end
            if shadowLabel ~= nil then
                shadowLabel:SetHidden(shadeAlpha <= 0)
                shadowLabel:SetColor(shadeR, shadeG, shadeB, shadeAlpha)
                shadowLabel:SetAlpha(labelAlpha)
            end
        end
    else
        self.label:SetColor(1, 1, 1, 1)
        if backdrop ~= nil then
            backdrop:SetHidden(true)
        end
        if shadowLabel ~= nil then
            shadowLabel:SetHidden(true)
        end
    end

    local tooltipBorder = self.tooltipBorder
    if tooltipBorder == nil then
        local parentName = self.control and self.control.GetName and self.control:GetName()
        if parentName ~= nil and parentName ~= "" then
            local borderName = parentName .. "TooltipBorder"
            tooltipBorder = _G[borderName]
            if tooltipBorder == nil then
                tooltipBorder = WINDOW_MANAGER:CreateControl(borderName, container, CT_TEXTURE)
                tooltipBorder:SetDrawLayer(1)
                tooltipBorder:SetDrawLevel(63)
                tooltipBorder:SetMouseEnabled(false)
                tooltipBorder:SetAnchorFill()
                tooltipBorder:SetTexture(ThemeManager:GetTexturePath("TooltipBorder.dds"))
            end
            self.tooltipBorder = tooltipBorder
        end
    end
    if tooltipBorder ~= nil and tooltipBorder.SetDrawLayer ~= nil and tooltipBorder.SetDrawLevel ~= nil then
        tooltipBorder:SetDrawLayer(1)
        tooltipBorder:SetDrawLevel(63)
    end
    if tooltipBorder ~= nil then
        tooltipBorder:SetTexture(ThemeManager:GetTexturePath("TooltipBorder.dds"))
        local showTooltipBorder = (not shouldHide) and (not effectiveInsideMode)
        tooltipBorder:SetHidden(not showTooltipBorder)
        if showTooltipBorder then
            local borderAlpha = zo_max(0, zo_min(100, SETTINGS.VALUE_TOOLTIP_BORDER_ALPHA or DEFAULT_SETTINGS.VALUE_TOOLTIP_BORDER_ALPHA)) / 100
            tooltipBorder:SetAlpha(borderAlpha)
        end
    end

end

function DiabloFramesStatusBar:ApplyGlowLayout()
    if self.glow == nil then
        return
    end

    local isD4Theme = (ThemeManager:GetCurrentTheme() == "d4")
    local fractionated = SETTINGS.LOW_RESOURCE_FRACTIONATE_COMBINED or DEFAULT_SETTINGS.LOW_RESOURCE_FRACTIONATE_COMBINED
    if self.powerType == POWERTYPE_MAGICKA and not isD4Theme and not fractionated then
        self.glow:SetHidden(true)
        return
    end

    local orbSize = GetD4OrbSize()
    local glowScale = orbSize / 150

    local glowLayerScale = isD4Theme and GetD4LayerScale("D4_GLOW_LAYER_SIZE") or 1
    local glowOffsetX = isD4Theme and GetD4LayerOffset("D4_GLOW_LAYER_OFFSET_X") or 0
    local glowOffsetYKey = isD4Theme and "D4_GLOW_OFFSET_Y" or "GLOW_OFFSET_Y"
    local glowCenterGapKey = isD4Theme and "D4_GLOW_CENTER_GAP_X" or "GLOW_CENTER_GAP_X"
    local glowInternalOnlyKey = isD4Theme and "D4_GLOW_INTERNAL_ONLY" or "GLOW_INTERNAL_ONLY"
    local globalGlowOffsetY = SETTINGS[glowOffsetYKey] or DEFAULT_SETTINGS[glowOffsetYKey]
    local glowOffsetY = (isD4Theme and GetD4LayerOffset("D4_GLOW_LAYER_OFFSET_Y") or 0) + globalGlowOffsetY

    self.glow:ClearAnchors()
    self.glow:SetTextureCoords(0, 1, 0, 1)
    local glowCenterGap = (SETTINGS[glowCenterGapKey] or DEFAULT_SETTINGS[glowCenterGapKey]) * glowScale

    local mirrorSign = (self.powerType == POWERTYPE_HEALTH) and -1 or 1

    if SETTINGS[glowInternalOnlyKey] then
        self.glow:SetAnchor(CENTER, self.control, CENTER, glowOffsetX, glowOffsetY)
        if isD4Theme then
            self.glow:SetDimensions(orbSize * glowLayerScale, orbSize * glowLayerScale)
        else
            local sg = GetLegacyOrbLayerScale()
            if sg > 0 then
                local lgpx = SETTINGS.LEGACY_GLOW_SIZE or DEFAULT_SETTINGS.LEGACY_GLOW_SIZE
                local gs = zo_floor(lgpx / sg + 0.5)
                self.glow:SetDimensions(gs, gs)
            end
        end
        self.glow:SetTextureCoords(0, 1, 0, 1)
    else
        -- Mirror strict: same vertical axis, equal distance from center on X.
        self.glow:SetAnchor(CENTER, self.control, CENTER, (mirrorSign * glowCenterGap) + glowOffsetX, glowOffsetY)
        if isD4Theme then
            self.glow:SetDimensions(250 * glowScale * glowLayerScale, 250 * glowScale * glowLayerScale)
        else
            local sg = GetLegacyOrbLayerScale()
            if sg > 0 then
                local lgpx = SETTINGS.LEGACY_GLOW_SIZE or DEFAULT_SETTINGS.LEGACY_GLOW_SIZE
                local gs = zo_floor(lgpx / sg + 0.5)
                self.glow:SetDimensions(gs, gs)
            end
        end
        self.glow:SetTextureCoords(0, 1, 0, 1)
    end

    self.lastGlowLayoutInternalOnly = SETTINGS[glowInternalOnlyKey]
end

function DiabloFramesStatusBar:ApplyTexture()

    local orbSize = GetD4OrbSize()
    local isD4Theme = (ThemeManager:GetCurrentTheme() == "d4")
    if self.control ~= nil and self.control.SetScale ~= nil then
        if isD4Theme then
            self.control:SetScale(1)
        else
            self.control:SetScale(GetLegacyOrbLayerScale())
        end
    end
    local orbScale = orbSize / 150
    local borderSize = orbSize
    local unifiedOrbAlpha = isD4Theme and GetD4UnifiedOrbAlpha() or 1

    local percent = 0
    if self.value >= self.max then
        percent = 100
    elseif self.max ~= 0 then
        percent = zo_roundToNearest((self.value / self.max) * 100, 0.1)
    end

    percent = zo_max(0, percent - 3) -- visual fix

    if self.lastRenderedPercent == percent and self.lastVisualRevision == VISUAL_SETTINGS_REV then
        return
    end

    self.lastRenderedPercent = percent
    self.lastVisualRevision = VISUAL_SETTINGS_REV

    local height = (orbSize / 100) * percent
    height = zo_max(0, zo_min(orbSize, height))
    local coordTop = 1 - (percent / 100)

    local d4FillScale = isD4Theme and GetD4LayerScale("D4_FILL_LAYER_SIZE") or 1
    local smokeHeight = height * d4FillScale
    smokeHeight = zo_max(0, zo_min(orbSize, smokeHeight))
    local smokeAnchorY = orbSize - smokeHeight

    local d4SmokeAnchorY = smokeAnchorY
    if isD4Theme and self.powerType == POWERTYPE_HEALTH then
        D4HealthSmokeAnchorY = smokeAnchorY
    end

    if self.glow ~= nil then
        self:ApplyGlowLayout()
        local d4GlowVisible = (not isD4Theme) or IsD4LayerVisible("D4_GLOW_LAYER_VISIBLE")
        local d4GlowLayerAlpha = isD4Theme and GetD4LayerAlpha("D4_GLOW_LAYER_ALPHA") or 1
        local glowBrightness = isD4Theme and (zo_max(0, zo_min(300, SETTINGS.D4_GLOW_BRIGHTNESS or DEFAULT_SETTINGS.D4_GLOW_BRIGHTNESS)) / 100) or 1
        local glowIntensity = isD4Theme and (zo_max(0, zo_min(300, SETTINGS.D4_GLOW_INTENSITY or DEFAULT_SETTINGS.D4_GLOW_INTENSITY)) / 100) or 1
        local glowContrast = isD4Theme and (zo_max(0, zo_min(200, SETTINGS.D4_GLOW_CONTRAST or DEFAULT_SETTINGS.D4_GLOW_CONTRAST)) / 100) or 1
        local glowTint = isD4Theme and (zo_max(0, zo_min(100, SETTINGS.D4_GLOW_TINT or DEFAULT_SETTINGS.D4_GLOW_TINT)) / 100) or 0
        local gwR, gwG, gwB = GetOrbColor(self.powerType)
        local threshold = SETTINGS.LOW_RESOURCE_WARNING_PERCENT or DEFAULT_SETTINGS.LOW_RESOURCE_WARNING_PERCENT
        local isLowResource = percent < threshold

        if isLowResource and (SETTINGS.LOW_RESOURCE_GLOW_ALERT_ENABLED or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_ENABLED) then
            self.glow:SetTexture(ThemeManager:GetTexturePath("glow_alert.dds"))
        else
            self.glow:SetTexture(ThemeManager:GetTexturePath("Glow.dds"))
        end

        local fractionated = SETTINGS.LOW_RESOURCE_FRACTIONATE_COMBINED or DEFAULT_SETTINGS.LOW_RESOURCE_FRACTIONATE_COMBINED
        if not isD4Theme and self.powerType == POWERTYPE_STAMINA and not fractionated then
            -- Legacy combined right orb behavior (non fractionné): partage couleur et état.
            isLowResource, gwR, gwG, gwB = GetRightOrbGlowVisual()
        end

        local shouldShowGlow = d4GlowVisible or isLowResource
        self.glow:SetHidden(not shouldShowGlow)

        local gwC = Clamp01(glowBrightness * glowIntensity)
        local gwFR = Clamp01(gwC * (1 - glowTint) + gwR * glowTint)
        local gwFG = Clamp01(gwC * (1 - glowTint) + gwG * glowTint)
        local gwFB = Clamp01(gwC * (1 - glowTint) + gwB * glowTint)

        local function applyContrast(value, contrast)
            return Clamp01(((value - 0.5) * contrast) + 0.5)
        end
        if isD4Theme then
            gwFR = applyContrast(gwFR, glowContrast)
            gwFG = applyContrast(gwFG, glowContrast)
            gwFB = applyContrast(gwFB, glowContrast)
        end

        local glowScaleAlpha = Clamp01(gwC)

        if isLowResource and (SETTINGS.LOW_RESOURCE_GLOW_ALERT_ENABLED or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_ENABLED) then
            if self.powerType == POWERTYPE_HEALTH then
                gwFR = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_R or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_R
                gwFG = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_G or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_G
                gwFB = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_B or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_HEALTH_B
            elseif self.powerType == POWERTYPE_MAGICKA then
                gwFR = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_R or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_R
                gwFG = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_G or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_G
                gwFB = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_B or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_B
            elseif self.powerType == POWERTYPE_STAMINA then
                if not isD4Theme and not fractionated then
                    local magBar = GetBarByPowerType(POWERTYPE_MAGICKA)
                    local stamBar = GetBarByPowerType(POWERTYPE_STAMINA)
                    local magLow = magBar ~= nil and GetBarVisualPercent(magBar) < threshold
                    local stamLow = stamBar ~= nil and GetBarVisualPercent(stamBar) < threshold
                    if magLow and stamLow then
                        local mr = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_R or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_R
                        local mg = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_G or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_G
                        local mb = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_B or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_B
                        local sr = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_R or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_R
                        local sg = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_G or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_G
                        local sb = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_B or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_B
                        gwFR = Clamp01((mr + sr) / 2)
                        gwFG = Clamp01((mg + sg) / 2)
                        gwFB = Clamp01((mb + sb) / 2)
                    elseif magLow then
                        gwFR = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_R or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_R
                        gwFG = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_G or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_G
                        gwFB = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_B or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_MAGICKA_B
                    else
                        gwFR = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_R or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_R
                        gwFG = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_G or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_G
                        gwFB = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_B or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_B
                    end
                else
                    gwFR = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_R or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_R
                    gwFG = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_G or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_G
                    gwFB = SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_B or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_COLOR_STAMINA_B
                end
            end
        end

        if isLowResource and (SETTINGS.LOW_RESOURCE_GLOW_ALERT_ENABLED or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_ENABLED) then
            local alertSizePct = zo_max(50, zo_min(200, SETTINGS.LOW_RESOURCE_GLOW_ALERT_SIZE or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_SIZE)) / 100
            local curW, curH = self.glow:GetDimensions()
            self.glow:SetDimensions(curW * alertSizePct, curH * alertSizePct)
        end

        local glowLuma = (0.2126 * gwFR) + (0.7152 * gwFG) + (0.0722 * gwFB)
        local glowAlphaBalance = zo_max(0.75, zo_min(1.35, 0.42 / zo_max(0.12, glowLuma)))
        local alertAlphaFactor = (SETTINGS.LOW_RESOURCE_GLOW_ALERT_ALPHA or DEFAULT_SETTINGS.LOW_RESOURCE_GLOW_ALERT_ALPHA) / 100
        if isLowResource then
            local glowMaxAlpha = isD4Theme and (SETTINGS.D4_GLOW_MAX_ALPHA or DEFAULT_SETTINGS.D4_GLOW_MAX_ALPHA) or (SETTINGS.GLOW_MAX_ALPHA or DEFAULT_SETTINGS.GLOW_MAX_ALPHA)
            self.glow:SetColor(gwFR, gwFG, gwFB, glowMaxAlpha * alertAlphaFactor * d4GlowLayerAlpha * unifiedOrbAlpha * glowAlphaBalance * glowScaleAlpha)
            if self.lastLowResourceState ~= true and not self.glowAnimation:IsPlaying() then
                self.glowAnimation:PlayFromStart()
            end
        else
            local d4IdleGlow = zo_max(0, zo_min(100, SETTINGS.D4_IDLE_HIGHLIGHT_ALPHA or DEFAULT_SETTINGS.D4_IDLE_HIGHLIGHT_ALPHA)) / 100
            local idleGlowAlpha = isD4Theme and (d4IdleGlow * d4GlowLayerAlpha * unifiedOrbAlpha * glowAlphaBalance * glowScaleAlpha) or 0
            if self.lastLowResourceState ~= false then
                self.glowAnimation:Stop()
                self.glow:SetColor(gwFR, gwFG, gwFB, d4GlowVisible and idleGlowAlpha or 0)
            elseif isD4Theme and d4GlowVisible then
                self.glow:SetColor(gwFR, gwFG, gwFB, idleGlowAlpha)
            end
        end
        self.lastLowResourceState = isLowResource
    end


    self.smoke:SetHeight(height)

    if self.border ~= nil then
        local d4BorderVisible = (not isD4Theme) or IsD4LayerVisible("D4_BORDER_LAYER_VISIBLE")
        local d4BorderAlpha = isD4Theme and GetD4LayerAlpha("D4_BORDER_LAYER_ALPHA") or 1
        local d4BorderScale = isD4Theme and GetD4LayerScale("D4_BORDER_LAYER_SIZE") or 1
        local d4BorderOffsetX = isD4Theme and GetD4LayerOffset("D4_BORDER_LAYER_OFFSET_X") or 0
        local d4BorderOffsetY = isD4Theme and GetD4LayerOffset("D4_BORDER_LAYER_OFFSET_Y") or 0
        local d4BorderGapX = isD4Theme and (SETTINGS.D4_BORDER_LAYER_GAP_X or DEFAULT_SETTINGS.D4_BORDER_LAYER_GAP_X) or 0
        local borderMirror = (self.powerType == POWERTYPE_HEALTH) and -1 or 1
        self.border:SetHidden(not d4BorderVisible)
        if isD4Theme then
            local borderLayerSize = zo_floor((borderSize * d4BorderScale) + 0.5)
            self.border:SetDimensions(borderLayerSize, borderLayerSize)
            self.border:ClearAnchors()
            self.border:SetAnchor(CENTER, self.control, CENTER, (borderMirror * d4BorderGapX) + d4BorderOffsetX, d4BorderOffsetY)
        else
            local s = GetLegacyOrbLayerScale()
            if s > 0 then
                local legacyBorderPx = SETTINGS.LEGACY_BORDER_SIZE or DEFAULT_SETTINGS.LEGACY_BORDER_SIZE
                local bs = zo_floor(legacyBorderPx / s + 0.5)
                self.border:SetDimensions(bs, bs)
            end
        end
        local shouldPulse = self.borderPulseAnimation ~= nil
                            and GetThemeSetting("BORDER_PULSE_ENABLED")
                            and percent < SETTINGS.LOW_RESOURCE_WARNING_PERCENT
        if shouldPulse then
            self.border:SetColor(GetThemeSetting("BORDER_PULSE_R"), GetThemeSetting("BORDER_PULSE_G"), GetThemeSetting("BORDER_PULSE_B"), 1)
            if self.lastBorderPulseState ~= true and not self.borderPulseAnimation:IsPlaying() then
                self.border:SetAlpha(unifiedOrbAlpha)
                self.borderPulseAnimation:PlayFromStart()
            end
        else
            if self.lastBorderPulseState ~= false then
                if self.borderPulseAnimation ~= nil and self.borderPulseAnimation:IsPlaying() then
                    self.borderPulseAnimation:Stop()
                end
                self.border:SetAlpha(d4BorderVisible and (SETTINGS.BORDER_ALPHA * d4BorderAlpha * unifiedOrbAlpha) or 0)
                if isD4Theme then
                    self.border:SetColor(GetD4TintedColor(1))
                else
                    self.border:SetColor(1, 1, 1, 1)
                end
            end
            if isD4Theme then
                self.border:SetAlpha(d4BorderVisible and (d4BorderAlpha * unifiedOrbAlpha) or 0)
            end
        end
        self.lastBorderPulseState = shouldPulse
    end

    local baseR, baseG, baseB = GetOrbColor(self.powerType)
    local boost = GetCurrentOrbColorBoost() / 100
    local orbBrightness = zo_max(50, zo_min(200, GetCurrentOrbBrightness())) / 100
    local smokeR = Clamp01(baseR * boost * orbBrightness)
    local smokeG = Clamp01(baseG * boost * orbBrightness)
    local smokeB = Clamp01(baseB * boost * orbBrightness)
    local horizInset = 0.001
    local topInset = 0.0005
    local smokeLeft = self.baseCoordLeft
    local smokeRight = self.baseCoordRight

    local skipSplitInset = isD4Theme and (self.powerType == POWERTYPE_MAGICKA or self.powerType == POWERTYPE_STAMINA)
    if not skipSplitInset then
        if smokeLeft < smokeRight then
            smokeLeft = smokeLeft + horizInset
            smokeRight = smokeRight - horizInset
        elseif smokeLeft > smokeRight then
            smokeLeft = smokeLeft - horizInset
            smokeRight = smokeRight + horizInset
        end
    end

    local smokeAnchorX = self.baseAnchorX
    local smokeBgInsetY = 5
    local smokeWidth = nil
    if isD4Theme then
        smokeAnchorX = self.baseAnchorX * orbScale
        smokeBgInsetY = 0
        if self.powerType == POWERTYPE_HEALTH then
            smokeWidth = orbSize
        elseif self.powerType == POWERTYPE_MAGICKA or self.powerType == POWERTYPE_STAMINA then
            smokeWidth = orbSize / 2
        end
    else
        local controlWidth = self.control:GetWidth()
        if controlWidth == nil or controlWidth <= 0 then
            controlWidth = orbSize
        end
        local coordSpan = zo_abs(self.baseCoordRight - self.baseCoordLeft)
        if coordSpan <= 0 then
            coordSpan = 1
        end
        smokeWidth = zo_max(1, controlWidth * coordSpan)
    end

    local d4FillVisible = (not isD4Theme) or IsD4LayerVisible("D4_FILL_LAYER_VISIBLE")
    local d4FillAlpha = isD4Theme and GetD4LayerAlpha("D4_FILL_LAYER_ALPHA") or 1
    local smokeAlpha = isD4Theme and 1 or SETTINGS.SMOKE_ALPHA
    -- d4FillScale already declared above for smoke height calculation
    local d4FillOffsetX = isD4Theme and GetD4LayerOffset("D4_FILL_LAYER_OFFSET_X") or 0
    local d4FillOffsetY = isD4Theme and GetD4LayerOffset("D4_FILL_LAYER_OFFSET_Y") or 0
    local d4SmokeHealthOffsetY = isD4Theme and (SETTINGS.D4_FILL_LAYER_HEALTH_OFFSET_Y or DEFAULT_SETTINGS.D4_FILL_LAYER_HEALTH_OFFSET_Y) or 0
    local d4SmokeComboOffsetY = isD4Theme and (SETTINGS.D4_FILL_LAYER_COMBO_OFFSET_Y or DEFAULT_SETTINGS.D4_FILL_LAYER_COMBO_OFFSET_Y) or 0
    local d4OrbGlobalGapX = isD4Theme and (SETTINGS.D4_ORB_GLOBAL_GAP_X or DEFAULT_SETTINGS.D4_ORB_GLOBAL_GAP_X) or 0
    local d4BackgroundOrbGapX = isD4Theme and (SETTINGS.D4_BACKGROUND_ORB_GAP_X or DEFAULT_SETTINGS.D4_BACKGROUND_ORB_GAP_X) or 0
    local d4AdditiveOrbGapX = isD4Theme and (SETTINGS.D4_ADDITIVE_ORB_GAP_X or DEFAULT_SETTINGS.D4_ADDITIVE_ORB_GAP_X) or 0
    local d4AdditiveOrbOffsetX = isD4Theme and (SETTINGS.D4_ADDITIVE_ORB_OFFSET_X or DEFAULT_SETTINGS.D4_ADDITIVE_ORB_OFFSET_X) or 0
    local d4OrbHealthGapX = isD4Theme and (SETTINGS.D4_ORB_HEALTH_GAP_X or DEFAULT_SETTINGS.D4_ORB_HEALTH_GAP_X) or 0
    local d4OrbCombinedGapX = isD4Theme and (SETTINGS.D4_ORB_COMBINED_GAP_X or DEFAULT_SETTINGS.D4_ORB_COMBINED_GAP_X) or 0
    -- Offset global : décale les 3 instances de la couche dans la même direction (même signe pour health et combined)
    local d4FillGlobalX = isD4Theme and (SETTINGS.D4_FILL_LAYER_GLOBAL_X or DEFAULT_SETTINGS.D4_FILL_LAYER_GLOBAL_X) or 0
    local d4BackgroundGlobalX = isD4Theme and (SETTINGS.D4_BACKGROUND_LAYER_GLOBAL_X or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_GLOBAL_X) or 0

    self.smoke:SetHidden(not d4FillVisible)
    self.smoke:SetColor(smokeR, smokeG, smokeB, 1)
    self.smoke:ClearAnchors()
    if self.isShield then
        if isD4Theme and self.smoke.SetDrawLevel ~= nil then
            self.smoke:SetDrawLevel(GetD4ShieldLayerLevel())
        elseif self.smoke.SetDrawLevel ~= nil then
            self.smoke:SetDrawLevel(6)
        end
        local ringScaleSetting = isD4Theme and (SETTINGS.D4_SHIELD_RING_SCALE or DEFAULT_SETTINGS.D4_SHIELD_RING_SCALE) or (SETTINGS.SHIELD_RING_SCALE or DEFAULT_SETTINGS.SHIELD_RING_SCALE)
        local ringScale = zo_max(0.6, ringScaleSetting / 100)
        local ringSize = 150 * ringScale
        self.smoke:SetDimensions(ringSize, ringSize)
        self.smoke:SetAnchor(CENTER, self.control, CENTER, 0, 0)
        self.smoke:SetTextureCoords(0, 1, 0, 1)
        local shieldFill = zo_min(1, zo_max(0, self.max > 0 and (self.value / self.max) or 0))
        local response = zo_max(50, SETTINGS.SHIELD_VISUAL_RESPONSE)
        local exponent = 100 / response
        local visualFill = shieldFill ^ exponent
        self.smoke:SetAlpha(GetShieldOpacity() * visualFill * unifiedOrbAlpha)
    else
        if smokeWidth ~= nil then
            self.smoke:SetWidth(smokeWidth * d4FillScale)
        end
        self.smoke:SetHeight(smokeHeight)
        self.smoke:SetTextureCoords(smokeLeft, smokeRight, coordTop + topInset, 1)
        if isD4Theme and (self.powerType == POWERTYPE_MAGICKA or self.powerType == POWERTYPE_STAMINA) then
            -- Center-gap control for split right orb in D4, plus global smoke gap between health and combined.
            local splitGapX = d4FillOffsetX
            local combinedGlobalGapX = (d4OrbGlobalGapX * 0.5) + d4OrbCombinedGapX
            local comboOffsetY = d4SmokeComboOffsetY
            if self.powerType == POWERTYPE_MAGICKA then
                self.smoke:SetAnchor(TOPRIGHT, self.control, TOP, -splitGapX + combinedGlobalGapX + d4FillGlobalX, d4SmokeAnchorY + d4FillOffsetY + comboOffsetY)
            else
                self.smoke:SetAnchor(TOPLEFT, self.control, TOP, splitGapX + combinedGlobalGapX + d4FillGlobalX, d4SmokeAnchorY + d4FillOffsetY + comboOffsetY)
            end
        elseif isD4Theme then
            -- Health smoke est positionné avec gap indépendant + ajustement global.
            local healthGlobalGapX = -(d4OrbGlobalGapX * 0.5) + d4OrbHealthGapX
            local combinedGlobalGapX = (d4OrbGlobalGapX * 0.5) + d4OrbCombinedGapX
            local healthOffsetX = isD4Theme and (SETTINGS.D4_FILL_LAYER_HEALTH_OFFSET_X or DEFAULT_SETTINGS.D4_FILL_LAYER_HEALTH_OFFSET_X) or 0
            local healthOffsetY = d4SmokeHealthOffsetY
            self.smoke:SetAnchor(TOPLEFT, self.control, TOPLEFT, smokeAnchorX + healthGlobalGapX + healthOffsetX + d4FillGlobalX, d4SmokeAnchorY + d4FillOffsetY + healthOffsetY)
            -- for magicka and stamina we also use combinedGlobalGapX, but their code block already overrides.
        else
            self.smoke:SetAnchor(TOPLEFT, self.control, TOPLEFT, smokeAnchorX + d4FillOffsetX, smokeAnchorY + d4FillOffsetY)
        end
        if self.smoke.SetBlendMode ~= nil then
            if isD4Theme and TEX_BLEND_MODE_MODULATE ~= nil then
                self.smoke:SetBlendMode(TEX_BLEND_MODE_MODULATE)
            else
                self.smoke:SetBlendMode(TEX_BLEND_MODE_ALPHA)
            end
        end
        if isD4Theme and self.smoke.SetDrawLayer ~= nil and self.smoke.SetDrawLevel ~= nil then
            self.smoke:SetDrawLayer(1)
            self.smoke:SetDrawLevel(5)
        end
        self.smoke:SetAlpha(d4FillVisible and (smokeAlpha * d4FillAlpha * unifiedOrbAlpha) or 0)
    end

    if self.borderShade ~= nil then
        local d4ShadeVisible = (not isD4Theme) or IsD4LayerVisible("D4_SHADE_LAYER_VISIBLE")
        local d4ShadeAlpha = isD4Theme and GetD4LayerAlpha("D4_SHADE_LAYER_ALPHA") or 1
        local d4ShadeScale = isD4Theme and GetD4LayerScale("D4_SHADE_LAYER_SIZE") or 1
        local d4ShadeOffsetX = isD4Theme and GetD4LayerOffset("D4_SHADE_LAYER_OFFSET_X") or 0
        local d4ShadeOffsetY = isD4Theme and GetD4LayerOffset("D4_SHADE_LAYER_OFFSET_Y") or 0
        local d4ShadeGapX = isD4Theme and (SETTINGS.D4_SHADE_LAYER_GAP_X or DEFAULT_SETTINGS.D4_SHADE_LAYER_GAP_X) or 0
        local shadeMirror = (self.powerType == POWERTYPE_HEALTH) and -1 or 1
        self.borderShade:SetHidden(not d4ShadeVisible)
        if isD4Theme then
            local shadeSize = zo_floor((orbSize * d4ShadeScale) + 0.5)
            self.borderShade:SetDimensions(shadeSize, shadeSize)
            self.borderShade:ClearAnchors()
            self.borderShade:SetAnchor(CENTER, self.control, CENTER, (shadeMirror * d4ShadeGapX) + d4ShadeOffsetX, d4ShadeOffsetY)
        else
            local s = GetLegacyOrbLayerScale()
            if s > 0 then
                local legacyShadePx = SETTINGS.LEGACY_SHADE_SIZE or DEFAULT_SETTINGS.LEGACY_SHADE_SIZE
                local ss = zo_floor(legacyShadePx / s + 0.5)
                self.borderShade:SetDimensions(ss, ss)
            end
        end
        local shadeAlpha
        if isD4Theme then
            shadeAlpha = d4ShadeAlpha
        else
            shadeAlpha = SETTINGS.SHADE_ALPHA
        end
        self.borderShade:SetAlpha(d4ShadeVisible and (shadeAlpha * unifiedOrbAlpha) or 0)
    end

    -- Split legacy: always hidden in D4 theme; keep for non-D4 compatibility
    local d4SplitVisible = (not isD4Theme) and IsD4LayerVisible("D4_SPLIT_LAYER_VISIBLE")
    if self.split ~= nil then
        local seamVisible = isD4Theme and (SETTINGS.D4_SEAM_VISIBLE ~= false)
                            and (self.powerType == POWERTYPE_MAGICKA)
        if isD4Theme then
            self.split:SetHidden(not seamVisible)
            if seamVisible then
                local seamAlpha = zo_max(0, zo_min(100, SETTINGS.D4_SEAM_ALPHA or DEFAULT_SETTINGS.D4_SEAM_ALPHA)) / 100
                local seamOffsetX = SETTINGS.D4_SEAM_OFFSET_X or DEFAULT_SETTINGS.D4_SEAM_OFFSET_X
                local seamOffsetY = SETTINGS.D4_SEAM_OFFSET_Y or DEFAULT_SETTINGS.D4_SEAM_OFFSET_Y
                local seamR = Clamp01(SETTINGS.D4_SEAM_COLOR_R or DEFAULT_SETTINGS.D4_SEAM_COLOR_R)
                local seamG = Clamp01(SETTINGS.D4_SEAM_COLOR_G or DEFAULT_SETTINGS.D4_SEAM_COLOR_G)
                local seamB = Clamp01(SETTINGS.D4_SEAM_COLOR_B or DEFAULT_SETTINGS.D4_SEAM_COLOR_B)
                local seamBrightness = zo_max(0, zo_min(200, SETTINGS.D4_SEAM_BRIGHTNESS or DEFAULT_SETTINGS.D4_SEAM_BRIGHTNESS)) / 100
                local seamAdditive = (SETTINGS.D4_SEAM_ADDITIVE ~= false)
                local seamSizePct = zo_max(10, zo_min(200, SETTINGS.D4_SEAM_SIZE or DEFAULT_SETTINGS.D4_SEAM_SIZE)) / 100
                local seamSize = zo_floor(orbSize * seamSizePct + 0.5)
                local seamWidth = zo_max(1, zo_min(500, zo_floor((SETTINGS.D4_SEAM_WIDTH or DEFAULT_SETTINGS.D4_SEAM_WIDTH) + 0.5)))
                local seamHeightPct = zo_max(10, zo_min(200, SETTINGS.D4_SEAM_HEIGHT or DEFAULT_SETTINGS.D4_SEAM_HEIGHT)) / 100
                local seamHeight = zo_max(8, zo_floor((seamSize * seamHeightPct) + 0.5))
                self.split:SetTexture(ThemeManager:GetTexturePath("Split_bar.dds"))
                self.split:SetDimensions(seamWidth, seamHeight)
                self.split:SetColor(Clamp01(seamR * seamBrightness), Clamp01(seamG * seamBrightness), Clamp01(seamB * seamBrightness), 1)
                if self.split.SetBlendMode ~= nil then
                    self.split:SetBlendMode(seamAdditive and TEX_BLEND_MODE_ADD or TEX_BLEND_MODE_ALPHA)
                end
                self.split:ClearAnchors()
                self.split:SetAnchor(CENTER, self.control, CENTER, seamOffsetX, seamOffsetY)
                self.split:SetAlpha(seamAlpha * unifiedOrbAlpha)
            end
        else
            self.split:SetHidden(not d4SplitVisible)
            if d4SplitVisible then
                local s = GetLegacyOrbLayerScale()
                if s > 0 then
                    local legacySplitPx = SETTINGS.LEGACY_SPLIT_SIZE or DEFAULT_SETTINGS.LEGACY_SPLIT_SIZE
                    self.split:SetDimensions(zo_floor(legacySplitPx / s + 0.5), zo_floor(legacySplitPx / s + 0.5))
                end
                self.split:SetAlpha(SETTINGS.SPLIT_ALPHA * unifiedOrbAlpha)
            end
        end
    end
    if self.borderOverlay ~= nil then
        local useD4BorderOverlay = isD4Theme and (self.powerType == POWERTYPE_HEALTH or self.powerType == POWERTYPE_MAGICKA)
        if useD4BorderOverlay then
            local overlayVisible = IsD4LayerVisible("D4_OVERLAY_LAYER_VISIBLE")
            local overlayScale = GetD4LayerScale("D4_OVERLAY_LAYER_SIZE")
            local overlayOffsetX = GetD4LayerOffset("D4_OVERLAY_LAYER_OFFSET_X")
            local overlayOffsetY = GetD4LayerOffset("D4_OVERLAY_LAYER_OFFSET_Y")
            local overlayGapX = SETTINGS.D4_OVERLAY_LAYER_GAP_X or DEFAULT_SETTINGS.D4_OVERLAY_LAYER_GAP_X
            local overlayMirror = (self.powerType == POWERTYPE_HEALTH) and -1 or 1
            self.borderOverlay:SetHidden(not overlayVisible)
            if overlayVisible then
                local overlaySize = zo_floor((borderSize * overlayScale) + 0.5)
                self.borderOverlay:SetDimensions(overlaySize, overlaySize)
                self.borderOverlay:ClearAnchors()
                self.borderOverlay:SetAnchor(CENTER, self.control, CENTER, (overlayMirror * overlayGapX) + overlayOffsetX, overlayOffsetY)
                local ovBrightness = zo_max(0, zo_min(200, SETTINGS.D4_OVERLAY_BRIGHTNESS or DEFAULT_SETTINGS.D4_OVERLAY_BRIGHTNESS)) / 100
                local ovContrast = zo_max(0, zo_min(100, SETTINGS.D4_OVERLAY_CONTRAST or DEFAULT_SETTINGS.D4_OVERLAY_CONTRAST)) / 100
                local obc = Clamp01(ovBrightness)
                self.borderOverlay:SetColor(GetD4TintedColor(obc))
                if self.borderOverlay.SetBlendMode ~= nil then
                    if ovContrast > 0.5 then
                        self.borderOverlay:SetBlendMode(TEX_BLEND_MODE_ADD)
                    else
                        self.borderOverlay:SetBlendMode(TEX_BLEND_MODE_ALPHA)
                    end
                end
                local effectiveAlpha = GetD4LayerAlpha("D4_OVERLAY_LAYER_ALPHA")
                if ovContrast > 0.5 then
                    effectiveAlpha = Clamp01(effectiveAlpha * ovBrightness)
                end
                self.borderOverlay:SetAlpha(Clamp01(effectiveAlpha) * unifiedOrbAlpha)
            end
        else
            self.borderOverlay:SetHidden(true)
        end
    end

    if self.smokeBg ~= nil then
        local d4BackgroundVisible = (not isD4Theme) or IsD4LayerVisible("D4_BACKGROUND_LAYER_VISIBLE")
        local d4BackgroundHost = (self.powerType ~= POWERTYPE_STAMINA)
        local d4BackgroundAlpha = isD4Theme and GetD4LayerAlpha("D4_BACKGROUND_LAYER_ALPHA") or 1
        local d4BackgroundScale = isD4Theme and (zo_max(50, zo_min(150, SETTINGS.D4_BACKGROUND_LAYER_SIZE or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_SIZE)) / 100) or 1
        local d4BackgroundWidthScale = isD4Theme and (zo_max(50, zo_min(150, SETTINGS.D4_BACKGROUND_LAYER_WIDTH or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_WIDTH)) / 100) or 1
        local d4BackgroundHeightScale = isD4Theme and (zo_max(50, zo_min(150, SETTINGS.D4_BACKGROUND_LAYER_HEIGHT or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_HEIGHT)) / 100) or 1
        local d4BackgroundOffsetX = isD4Theme and (SETTINGS.D4_BACKGROUND_LAYER_OFFSET_X or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_OFFSET_X) or 0
        local d4BackgroundOffsetY = isD4Theme and (SETTINGS.D4_BACKGROUND_LAYER_OFFSET_Y or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_OFFSET_Y) or 0
        local d4BackgroundBrightness = isD4Theme and (zo_max(0, zo_min(200, SETTINGS.D4_BACKGROUND_LAYER_BRIGHTNESS or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_BRIGHTNESS)) / 100) or 1
        local smokeBgTopCoord = isD4Theme and 0 or (coordTop + topInset)
        local smokeBgHeightBase = isD4Theme and orbSize or zo_max(0, (height - smokeBgInsetY))
        local smokeBgAnchorY = isD4Theme and 0 or (smokeAnchorY - smokeBgInsetY)
        local smokeBgWidthBase = isD4Theme and orbSize or smokeWidth
        if smokeBgWidthBase == nil or smokeBgWidthBase <= 0 then
            smokeBgWidthBase = orbSize
        end
        local smokeBgCenterOffsetX = isD4Theme and 0 or ((smokeAnchorX + (smokeBgWidthBase / 2)) - (orbSize / 2))
        if isD4Theme and not d4BackgroundHost then
            d4BackgroundVisible = false
        end
        if self.smokeBg.SetDrawLayer ~= nil and self.smokeBg.SetDrawLevel ~= nil then
            self.smokeBg:SetDrawLayer(1)
            self.smokeBg:SetDrawLevel(3)
        end

        self.smokeBg:SetHidden(not d4BackgroundVisible)
        self.smokeBg:SetWidth(smokeBgWidthBase * d4BackgroundScale * d4BackgroundWidthScale)
        self.smokeBg:SetHeight(zo_max(0, smokeBgHeightBase * d4BackgroundScale * d4BackgroundHeightScale))
        self.smokeBg:ClearAnchors()
        if isD4Theme then
            self.smokeBg:SetTextureCoords(0, 1, smokeBgTopCoord, 1)
        else
            self.smokeBg:SetTextureCoords(smokeLeft, smokeRight, smokeBgTopCoord, 1)
        end

        if isD4Theme then
            if self.powerType == POWERTYPE_MAGICKA or self.powerType == POWERTYPE_STAMINA then
                local splitGapX = d4FillOffsetX
                local combinedGlobalGapX = d4BackgroundOrbGapX * 0.5
                local comboOffsetY = d4SmokeComboOffsetY
                if self.powerType == POWERTYPE_MAGICKA then
                    self.smokeBg:SetAnchor(TOPRIGHT, self.control, TOP, -splitGapX + combinedGlobalGapX + d4BackgroundOffsetX + d4BackgroundGlobalX, d4FillOffsetY + comboOffsetY + d4BackgroundOffsetY)
                else
                    self.smokeBg:SetAnchor(TOPLEFT, self.control, TOP, splitGapX + combinedGlobalGapX + d4BackgroundOffsetX + d4BackgroundGlobalX, d4FillOffsetY + comboOffsetY + d4BackgroundOffsetY)
                end
            else
                local healthGlobalGapX = -(d4BackgroundOrbGapX * 0.5)
                local healthOffsetX = SETTINGS.D4_FILL_LAYER_HEALTH_OFFSET_X or DEFAULT_SETTINGS.D4_FILL_LAYER_HEALTH_OFFSET_X
                local healthOffsetY = d4SmokeHealthOffsetY
                self.smokeBg:SetAnchor(TOPLEFT, self.control, TOPLEFT, smokeAnchorX + healthGlobalGapX + healthOffsetX + d4BackgroundOffsetX + d4BackgroundGlobalX, d4FillOffsetY + healthOffsetY + d4BackgroundOffsetY)
            end
        else
            self.smokeBg:SetAnchor(TOPLEFT, self.control, TOPLEFT, smokeAnchorX + d4BackgroundOffsetX, smokeBgAnchorY + d4BackgroundOffsetY)
        end
        if self.smokeBg.SetBlendMode ~= nil then
            self.smokeBg:SetBlendMode(TEX_BLEND_MODE_ALPHA)
        end
        self.smokeBg:SetAlpha(d4BackgroundVisible and (d4BackgroundAlpha * unifiedOrbAlpha) or 0)
        if isD4Theme then
            local neutral = Clamp01(d4BackgroundBrightness)
            self.smokeBg:SetColor(neutral, neutral, neutral, 1)
        elseif self.smokeBgDark ~= nil then
            local t = SETTINGS.SMOKEBG_BRIGHTNESS / 100
            local darkMul = 0.25 + (0.75 * t)
            local r = Clamp01(baseR * darkMul * boost * d4BackgroundBrightness)
            local g = Clamp01(baseG * darkMul * boost * d4BackgroundBrightness)
            local b = Clamp01(baseB * darkMul * boost * d4BackgroundBrightness)
            self.smokeBg:SetColor(r, g, b, 1)
        end
    end

    if self.orbTintLayer ~= nil then
        local tintEnabled, tintAlpha, tintR, tintG, tintB = GetCurrentOrbTintLayerSettings()
        if isD4Theme then
            tintEnabled = false
        end
        self.orbTintLayer:SetHidden(not tintEnabled)
        if tintEnabled then
            local tintScale = isD4Theme and (zo_max(50, zo_min(150, SETTINGS.D4_BACKGROUND_LAYER_SIZE or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_SIZE)) / 100) or 1
            local tintOffsetX = isD4Theme and (SETTINGS.D4_BACKGROUND_LAYER_OFFSET_X or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_OFFSET_X) or 0
            local tintOffsetY = isD4Theme and (SETTINGS.D4_BACKGROUND_LAYER_OFFSET_Y or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_OFFSET_Y) or 0
            local tintWidth = smokeWidth
            if tintWidth == nil or tintWidth <= 0 then
                tintWidth = self.control:GetWidth()
                if tintWidth == nil or tintWidth <= 0 then
                    tintWidth = orbSize
                end
            end

            self.orbTintLayer:SetWidth(tintWidth * tintScale)
            self.orbTintLayer:SetHeight(orbSize * tintScale)
            self.orbTintLayer:SetTextureCoords(smokeLeft, smokeRight, 0, 1)
            self.orbTintLayer:ClearAnchors()
            self.orbTintLayer:SetAnchor(TOPLEFT, self.control, TOPLEFT, smokeAnchorX + tintOffsetX, tintOffsetY)
            if self.orbTintLayer.SetBlendMode ~= nil then
                self.orbTintLayer:SetBlendMode(TEX_BLEND_MODE_ALPHA)
            end
            self.orbTintLayer:SetColor(tintR, tintG, tintB, 1)
            self.orbTintLayer:SetAlpha(tintAlpha * unifiedOrbAlpha)
        end
    end

    -- Overlay additif D4: utilise TEX_BLEND_MODE_ADD sur D4OrbBack2 pour eclaircir l'orbe.
    -- Les zones sombres de la texture n'ajoutent rien; les zones claires illuminent.
    if self.additiveOverlay ~= nil then
        local addBoost = isD4Theme and (zo_max(0, zo_min(100, SETTINGS.D4_BACKGROUND_EDGE_LIGHT_BOOST or DEFAULT_SETTINGS.D4_BACKGROUND_EDGE_LIGHT_BOOST)) / 100) or 0
        local addEnabled = isD4Theme and (SETTINGS.D4_BACKGROUND_NEGATIVE == true) and (addBoost > 0)
        local addHost = (self.powerType ~= POWERTYPE_STAMINA) or (SETTINGS.D4_BACKGROUND_ADDITIVE_STAMINA == true)
        addEnabled = addEnabled and addHost
        self.additiveOverlay:SetHidden(not addEnabled)
        if addEnabled then
            local addScale = isD4Theme and (zo_max(50, zo_min(150, SETTINGS.D4_BACKGROUND_LAYER_SIZE or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_SIZE)) / 100) or 1
            local addOffsetX = isD4Theme and (SETTINGS.D4_BACKGROUND_LAYER_OFFSET_X or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_OFFSET_X) or 0
            local addOffsetY = isD4Theme and (SETTINGS.D4_BACKGROUND_LAYER_OFFSET_Y or DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_OFFSET_Y) or 0
            if self.additiveOverlay.SetBlendMode ~= nil then
                self.additiveOverlay:SetBlendMode(TEX_BLEND_MODE_ADD)
            end
            if smokeWidth ~= nil then
                self.additiveOverlay:SetWidth(smokeWidth * addScale)
            end
            self.additiveOverlay:SetHeight(orbSize * addScale)
            self.additiveOverlay:SetTextureCoords(smokeLeft, smokeRight, 0, 1)
            self.additiveOverlay:ClearAnchors()

            local d4AdditiveHalfGap = d4AdditiveOrbGapX * 0.5
            if isD4Theme and (self.powerType == POWERTYPE_MAGICKA or self.powerType == POWERTYPE_STAMINA) then
                local splitGapX = d4FillOffsetX
                local additiveGlobalGapX = d4AdditiveHalfGap
                local comboOffsetY = d4SmokeComboOffsetY
                local y = d4FillOffsetY + comboOffsetY + addOffsetY
                if self.powerType == POWERTYPE_MAGICKA then
                    self.additiveOverlay:SetAnchor(TOPRIGHT, self.control, TOP, -splitGapX + additiveGlobalGapX + addOffsetX + d4AdditiveOrbOffsetX, y)
                else
                    self.additiveOverlay:SetAnchor(TOPLEFT, self.control, TOP, splitGapX + additiveGlobalGapX + addOffsetX + d4AdditiveOrbOffsetX, y)
                end
            else
                local healthGlobalGapX = -(d4AdditiveHalfGap)
                local healthOffsetX = SETTINGS.D4_FILL_LAYER_HEALTH_OFFSET_X or DEFAULT_SETTINGS.D4_FILL_LAYER_HEALTH_OFFSET_X
                local healthOffsetY = d4SmokeHealthOffsetY
                local y = d4FillOffsetY + healthOffsetY + addOffsetY
                self.additiveOverlay:SetAnchor(TOPLEFT, self.control, TOPLEFT, smokeAnchorX + healthGlobalGapX + healthOffsetX + addOffsetX + d4AdditiveOrbOffsetX, y)
            end

            self.additiveOverlay:SetColor(1, 1, 1, 1)
            self.additiveOverlay:SetAlpha(addBoost * unifiedOrbAlpha)
        end
    end
end
-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
local ultimatePulseUpdaterRegistered = false
local ultimatePulseControl = nil
local cachedUltimateCost = nil

local function StartUltimatePulseUpdater(control)
    if ultimatePulseUpdaterRegistered then
        return
    end

    ultimatePulseUpdaterRegistered = true
    ultimatePulseControl = control
    -- Pré-cache des settings au démarrage du pulse (évite 5 lectures SETTINGS à chaque tick 33ms)
    local cachedMinA  = zo_min(SETTINGS.ULTIMATE_PULSE_MIN_ALPHA, SETTINGS.ULTIMATE_PULSE_MAX_ALPHA)
    local cachedMaxA  = zo_max(SETTINGS.ULTIMATE_PULSE_MIN_ALPHA, SETTINGS.ULTIMATE_PULSE_MAX_ALPHA)
    local cachedSpeed = SETTINGS.ULTIMATE_PULSE_SPEED * 6.28318530718
    local cachedRange = cachedMaxA - cachedMinA
    EVENT_MANAGER:RegisterForUpdate(NAME .. "UltimatePulse", 33, function()
        local pulseControl = ultimatePulseControl
        if pulseControl == nil then
            return
        end
        local wave = (math.sin(GetFrameTimeSeconds() * cachedSpeed) + 1) * 0.5
        pulseControl:SetAlpha((cachedMinA + cachedRange * wave) * GetUltimateBarFillAlpha())
    end)
end

local function StopUltimatePulseUpdater()
    if not ultimatePulseUpdaterRegistered then
        return
    end

    EVENT_MANAGER:UnregisterForUpdate(NAME .. "UltimatePulse")
    ultimatePulseUpdaterRegistered = false
    ultimatePulseControl = nil
end

local function TryGetSlotAbilityCost(slotIndex, hotbarCategory)
    if GetSlotAbilityCost == nil then
        return nil
    end

    local ok, cost = pcall(GetSlotAbilityCost, slotIndex, hotbarCategory)
    if ok and type(cost) == "number" and cost > 0 then
        return cost
    end

    ok, cost = pcall(GetSlotAbilityCost, slotIndex)
    if ok and type(cost) == "number" and cost > 0 then
        return cost
    end

    return nil
end

local function GetCurrentUltimateCost(powerMax)
    local slotIndex = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1
    local categories = {}

    if HOTBAR_CATEGORY_PRIMARY ~= nil then
        categories[#categories + 1] = HOTBAR_CATEGORY_PRIMARY
    end
    if HOTBAR_CATEGORY_BACKUP ~= nil then
        categories[#categories + 1] = HOTBAR_CATEGORY_BACKUP
    end

    for _, hotbarCategory in ipairs(categories) do
        local cost = TryGetSlotAbilityCost(slotIndex, hotbarCategory)
        if cost ~= nil then
            return cost
        end
    end

    local fallback = TryGetSlotAbilityCost(slotIndex, nil)
    if fallback ~= nil then
        return fallback
    end

    return powerMax
end

local function RefreshCachedUltimateCost(powerMax)
    cachedUltimateCost = zo_max(1, zo_round(GetCurrentUltimateCost(powerMax)))
end

local function SetUltimateBarText(topLevelCtrl, currentUltimate, cost)
    local lineValue = GetOrCreateUltimateTextLabel(topLevelCtrl)
    if lineValue == nil then
        return
    end

    ApplyUltimateTextVisual(lineValue)

    lineValue:SetHidden((not IsActionBarUltimateWidgetEnabled()) or (not SETTINGS.SHOW_ULTIMATE_TEXT) or (not GetThemeSetting("SHOW_ULTIMATE_BAR")))
    if (not IsActionBarUltimateWidgetEnabled()) or (not SETTINGS.SHOW_ULTIMATE_TEXT) or (not GetThemeSetting("SHOW_ULTIMATE_BAR")) then
        return
    end

    if SETTINGS.ULTIMATE_TEXT_MODE == "percent" then
        local shownUltimate = zo_min(currentUltimate, cost)
        local pct = (cost > 0) and zo_round((shownUltimate / cost) * 100) or 0
        lineValue:SetText(pct .. "%")
    else
        lineValue:SetText(zo_strformat("<<1>>/<<2>>", zo_round(currentUltimate), cost))
    end
end

updateUltimate = function(topLevelCtrl)
    local control = GetControl(topLevelCtrl, 'Line')

    if (not IsActionBarUltimateWidgetEnabled()) or (not GetThemeSetting("SHOW_ULTIMATE_BAR")) then
        StopUltimatePulseUpdater()
        control:SetValue(0)
        control.ttt = nil
        control.ultimatePulseActive = false
        control:SetAlpha(GetUltimateBarFillAlpha())
        control:SetColor(0.73, 0.30, 0.04, 1)
        SetUltimateBarText(topLevelCtrl, 0, 1)
        return
    end

    local currentUltimate, powerMax = GetUnitPower("player", POWERTYPE_ULTIMATE)
    if cachedUltimateCost == nil or cachedUltimateCost <= 0 then
        RefreshCachedUltimateCost(powerMax)
    end
    local cost = cachedUltimateCost

    local shownValue = zo_min(currentUltimate, cost)
    ZO_StatusBar_SmoothTransition(control, shownValue, cost)
    SetUltimateBarText(topLevelCtrl, currentUltimate, cost)

    local isReady = currentUltimate >= cost
    if isReady then
        control:SetAlpha(zo_max(0, zo_min(1, SETTINGS.ULTIMATE_PULSE_MAX_ALPHA or DEFAULT_SETTINGS.ULTIMATE_PULSE_MAX_ALPHA)) * GetUltimateBarFillAlpha())
        StartUltimatePulseUpdater(control)
        control.ultimatePulseActive = true
        control:SetColor(SETTINGS.ULTIMATE_READY_COLOR_R, SETTINGS.ULTIMATE_READY_COLOR_G, SETTINGS.ULTIMATE_READY_COLOR_B, 1)
        local overflow = zo_max(0, zo_round(currentUltimate) - cost)
        if overflow > 0 then
            control.ttt = zo_strformat(L("ULT_TT_READY_OVER"), zo_round(currentUltimate), cost, overflow)
        else
            control.ttt = zo_strformat(L("ULT_TT_READY"), zo_round(currentUltimate), cost)
        end
    else
        StopUltimatePulseUpdater()
        control.ultimatePulseActive = false
        control:SetAlpha(GetUltimateBarFillAlpha())
        control:SetColor(0.73, 0.30, 0.04, 1)
        control.ttt = zo_strformat(L("ULT_TT_NORMAL"), zo_round(currentUltimate), cost)
    end
end

function DiabloOrbs.InitializeFrame(topLevelCtrl)

    local function OnAddOnLoaded(_, addonName)
        if addonName == NAME then

            SETTINGS = ZO_SavedVars:NewCharacterIdSettings("DiabloOrbsSavedVariables", SV_VER, nil, DEFAULT_SETTINGS)

            -- Profils partagés (account-wide) + association perso→profil (per-character)
            -- On stocke dans une clé "data" pour éviter la pollution par les métaméthodes ZO_SavedVars
            local _profilesSV = ZO_SavedVars:NewAccountWide("DiabloOrbsSavedVariables", SV_PROFILES_VER, "profiles", { data = {} })
            local _charConfigSV = ZO_SavedVars:NewCharacterIdSettings("DiabloOrbsSavedVariables", SV_PROFILES_VER, "charConfig", { activeProfile = "D4 default" })
            if _profilesSV.data == nil then _profilesSV.data = {} end
            DiabloOrbs.profiles = _profilesSV.data
            DiabloOrbs.charConfig = _charConfigSV
            -- Recréer les profils built-in (toujours à jour, non-supprimables)
            local isFirstRun = (SETTINGS.firstRun ~= false)
            for builtinName, builtinData in pairs(BUILTIN_PROFILES) do
                DiabloOrbs.profiles[builtinName] = DeepCopy(builtinData)
            end
            -- Supprimer l'ancien profil "Default" générique s'il existe
            DiabloOrbs.profiles["Default"] = nil
            -- Premier lancement uniquement : appliquer le profil D4 default pour que
            -- l'interface ne soit pas brute. On détecte via firstRun ET l'absence de THEME
            -- (un utilisateur existant a forcément un THEME sauvegardé).
            if isFirstRun and SETTINGS.THEME == nil then
                SETTINGS.firstRun = false
                local d4data = DiabloOrbs.profiles["D4 default"]
                if d4data then
                    for k, v in pairs(d4data) do
                        SETTINGS[k] = v
                    end
                end
            else
                SETTINGS.firstRun = false
            end

            if SETTINGS.SHOW_ULTIMATE_BAR == nil then
                SETTINGS.SHOW_ULTIMATE_BAR = SETTINGS.SHOW_FOOD_TIMER ~= false
            end
            if SETTINGS.ENABLE_ACTION_BAR_MODULE == nil then SETTINGS.ENABLE_ACTION_BAR_MODULE = DEFAULT_SETTINGS.ENABLE_ACTION_BAR_MODULE end
            if SETTINGS.SHOW_ACTION_BAR_BACKGROUNDS == nil then SETTINGS.SHOW_ACTION_BAR_BACKGROUNDS = DEFAULT_SETTINGS.SHOW_ACTION_BAR_BACKGROUNDS end
            if SETTINGS.SHOW_ACTION_BAR_SLOTS == nil then SETTINGS.SHOW_ACTION_BAR_SLOTS = DEFAULT_SETTINGS.SHOW_ACTION_BAR_SLOTS end
            if SETTINGS.SHOW_ACTION_BAR_ULTIMATE_WIDGET == nil then SETTINGS.SHOW_ACTION_BAR_ULTIMATE_WIDGET = DEFAULT_SETTINGS.SHOW_ACTION_BAR_ULTIMATE_WIDGET end
            if SETTINGS.SHOW_ACTION_BAR_HOTKEYS == nil then SETTINGS.SHOW_ACTION_BAR_HOTKEYS = DEFAULT_SETTINGS.SHOW_ACTION_BAR_HOTKEYS end
            if SETTINGS.ACTION_BAR_HOTKEY_POSITION == nil then SETTINGS.ACTION_BAR_HOTKEY_POSITION = DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_POSITION end
            SETTINGS.ACTION_BAR_HOTKEY_POSITION = NormalizeActionBarHotkeyPosition(SETTINGS.ACTION_BAR_HOTKEY_POSITION)
            if SETTINGS.ACTION_BAR_HOTKEY_SCALE == nil then SETTINGS.ACTION_BAR_HOTKEY_SCALE = DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_SCALE end
            if SETTINGS.ACTION_BAR_HOTKEY_ALPHA == nil then SETTINGS.ACTION_BAR_HOTKEY_ALPHA = DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_ALPHA end
            if SETTINGS.ACTION_BAR_HOTKEY_OFFSET_X == nil then SETTINGS.ACTION_BAR_HOTKEY_OFFSET_X = DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_OFFSET_X end
            if SETTINGS.ACTION_BAR_HOTKEY_OFFSET_Y == nil then SETTINGS.ACTION_BAR_HOTKEY_OFFSET_Y = DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_OFFSET_Y end
            if SETTINGS.ACTION_BAR_HOTKEY_ONLY_IN_COMBAT == nil then SETTINGS.ACTION_BAR_HOTKEY_ONLY_IN_COMBAT = DEFAULT_SETTINGS.ACTION_BAR_HOTKEY_ONLY_IN_COMBAT end
            if SETTINGS.SHOW_ACTION_BAR_WEAPON_SWAP == nil then SETTINGS.SHOW_ACTION_BAR_WEAPON_SWAP = DEFAULT_SETTINGS.SHOW_ACTION_BAR_WEAPON_SWAP end
            if SETTINGS.SHOW_ACTION_BAR_COMPANION_ULTIMATE == nil then SETTINGS.SHOW_ACTION_BAR_COMPANION_ULTIMATE = DEFAULT_SETTINGS.SHOW_ACTION_BAR_COMPANION_ULTIMATE end
            if SETTINGS.SHOW_D4_SLOT_BORDERS == nil then SETTINGS.SHOW_D4_SLOT_BORDERS = DEFAULT_SETTINGS.SHOW_D4_SLOT_BORDERS end
            if SETTINGS.D4_SLOT_BORDER_ADVANCED == nil then SETTINGS.D4_SLOT_BORDER_ADVANCED = DEFAULT_SETTINGS.D4_SLOT_BORDER_ADVANCED end
            if SETTINGS.D4_SLOT_HIGHLIGHT_ALPHA == nil then SETTINGS.D4_SLOT_HIGHLIGHT_ALPHA = DEFAULT_SETTINGS.D4_SLOT_HIGHLIGHT_ALPHA end
            if SETTINGS.D4_SLOT_HIGHLIGHT_SOLO_ALPHA == nil then SETTINGS.D4_SLOT_HIGHLIGHT_SOLO_ALPHA = SETTINGS.D4_SLOT_HIGHLIGHT_ALPHA end
            if SETTINGS.D4_SLOT_HIGHLIGHT_DUAL_ALPHA == nil then SETTINGS.D4_SLOT_HIGHLIGHT_DUAL_ALPHA = SETTINGS.D4_SLOT_HIGHLIGHT_ALPHA end
            if SETTINGS.INACTIVE_BACK_BAR_ALPHA == nil then SETTINGS.INACTIVE_BACK_BAR_ALPHA = DEFAULT_SETTINGS.INACTIVE_BACK_BAR_ALPHA end
            if SETTINGS.INACTIVE_BACK_BAR_DESATURATION == nil then SETTINGS.INACTIVE_BACK_BAR_DESATURATION = DEFAULT_SETTINGS.INACTIVE_BACK_BAR_DESATURATION end
            if SETTINGS.INACTIVE_BACK_BAR_ALPHA_DUAL == nil then SETTINGS.INACTIVE_BACK_BAR_ALPHA_DUAL = SETTINGS.INACTIVE_BACK_BAR_ALPHA end
            if SETTINGS.INACTIVE_BACK_BAR_DESATURATION_DUAL == nil then SETTINGS.INACTIVE_BACK_BAR_DESATURATION_DUAL = SETTINGS.INACTIVE_BACK_BAR_DESATURATION end
            if SETTINGS.D4_ORB_SIZE == nil then SETTINGS.D4_ORB_SIZE = DEFAULT_SETTINGS.D4_ORB_SIZE end
            if SETTINGS.D4_ORB_INSET_X == nil then SETTINGS.D4_ORB_INSET_X = DEFAULT_SETTINGS.D4_ORB_INSET_X end
            -- Migration: solo/dual ORB_INSET_X héritent de la valeur existante
            if SETTINGS.D4_SOLO_ORB_INSET_X == nil then SETTINGS.D4_SOLO_ORB_INSET_X = SETTINGS.D4_ORB_INSET_X end
            if SETTINGS.D4_DUAL_ORB_INSET_X == nil then SETTINGS.D4_DUAL_ORB_INSET_X = SETTINGS.D4_ORB_INSET_X end
            if SETTINGS.D4_ORB_GLOBAL_GAP_X == nil then SETTINGS.D4_ORB_GLOBAL_GAP_X = DEFAULT_SETTINGS.D4_ORB_GLOBAL_GAP_X end
            if SETTINGS.D4_BACKGROUND_ORB_GAP_X == nil then SETTINGS.D4_BACKGROUND_ORB_GAP_X = DEFAULT_SETTINGS.D4_BACKGROUND_ORB_GAP_X end
            if SETTINGS.D4_ADDITIVE_ORB_GAP_X == nil then SETTINGS.D4_ADDITIVE_ORB_GAP_X = DEFAULT_SETTINGS.D4_ADDITIVE_ORB_GAP_X end
            if SETTINGS.D4_ADDITIVE_ORB_OFFSET_X == nil then SETTINGS.D4_ADDITIVE_ORB_OFFSET_X = DEFAULT_SETTINGS.D4_ADDITIVE_ORB_OFFSET_X end
            if SETTINGS.D4_FILL_LAYER_GLOBAL_X == nil then SETTINGS.D4_FILL_LAYER_GLOBAL_X = DEFAULT_SETTINGS.D4_FILL_LAYER_GLOBAL_X end
            if SETTINGS.D4_BACKGROUND_LAYER_GLOBAL_X == nil then SETTINGS.D4_BACKGROUND_LAYER_GLOBAL_X = DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_GLOBAL_X end
            if SETTINGS.D4_SHADE_LAYER_GAP_X == nil then SETTINGS.D4_SHADE_LAYER_GAP_X = DEFAULT_SETTINGS.D4_SHADE_LAYER_GAP_X end
            if SETTINGS.D4_BORDER_LAYER_GAP_X == nil then SETTINGS.D4_BORDER_LAYER_GAP_X = DEFAULT_SETTINGS.D4_BORDER_LAYER_GAP_X end
            if SETTINGS.D4_OVERLAY_LAYER_GAP_X == nil then SETTINGS.D4_OVERLAY_LAYER_GAP_X = DEFAULT_SETTINGS.D4_OVERLAY_LAYER_GAP_X end
            if SETTINGS.D4_ORB_OFFSET_Y == nil then SETTINGS.D4_ORB_OFFSET_Y = DEFAULT_SETTINGS.D4_ORB_OFFSET_Y end
            -- Migration: solo/dual ORB_OFFSET_Y héritent de la valeur existante
            if SETTINGS.D4_SOLO_ORB_OFFSET_Y == nil then SETTINGS.D4_SOLO_ORB_OFFSET_Y = SETTINGS.D4_ORB_OFFSET_Y end
            if SETTINGS.D4_DUAL_ORB_OFFSET_Y == nil then SETTINGS.D4_DUAL_ORB_OFFSET_Y = SETTINGS.D4_ORB_OFFSET_Y end
            if SETTINGS.D4_UNIFIED_ORB_ALPHA == nil then SETTINGS.D4_UNIFIED_ORB_ALPHA = DEFAULT_SETTINGS.D4_UNIFIED_ORB_ALPHA end
            -- Migration D4_BAR_MODE -> D4_SHOW_OFFBAR
            if SETTINGS.D4_SHOW_OFFBAR == nil then
                if SETTINGS.D4_BAR_MODE == "dual" then
                    SETTINGS.D4_SHOW_OFFBAR = true
                elseif SETTINGS.D4_BAR_MODE == "solo" then
                    SETTINGS.D4_SHOW_OFFBAR = false
                else
                    SETTINGS.D4_SHOW_OFFBAR = DEFAULT_SETTINGS.D4_SHOW_OFFBAR
                end
                SETTINGS.D4_BAR_MODE = nil
            end
            if SETTINGS.D4_BAR_TEXTURE_SCALE == nil then SETTINGS.D4_BAR_TEXTURE_SCALE = DEFAULT_SETTINGS.D4_BAR_TEXTURE_SCALE end
            if SETTINGS.D4_SOLO_BAR_WIDTH_SCALE == nil then SETTINGS.D4_SOLO_BAR_WIDTH_SCALE = DEFAULT_SETTINGS.D4_SOLO_BAR_WIDTH_SCALE end
            if SETTINGS.D4_SOLO_BAR_HEIGHT_SCALE == nil then SETTINGS.D4_SOLO_BAR_HEIGHT_SCALE = DEFAULT_SETTINGS.D4_SOLO_BAR_HEIGHT_SCALE end
            if SETTINGS.D4_DUAL_BAR_WIDTH_SCALE == nil then SETTINGS.D4_DUAL_BAR_WIDTH_SCALE = DEFAULT_SETTINGS.D4_DUAL_BAR_WIDTH_SCALE end
            if SETTINGS.D4_DUAL_BAR_HEIGHT_SCALE == nil then SETTINGS.D4_DUAL_BAR_HEIGHT_SCALE = DEFAULT_SETTINGS.D4_DUAL_BAR_HEIGHT_SCALE end
            if SETTINGS.D4_BAR_SCALE == nil then SETTINGS.D4_BAR_SCALE = DEFAULT_SETTINGS.D4_BAR_SCALE end
            if SETTINGS.D4_BAR_OFFSET_Y == nil then SETTINGS.D4_BAR_OFFSET_Y = DEFAULT_SETTINGS.D4_BAR_OFFSET_Y end
            -- Migration: solo/dual BAR_OFFSET_Y héritent de la valeur existante
            if SETTINGS.D4_SOLO_BAR_OFFSET_Y == nil then SETTINGS.D4_SOLO_BAR_OFFSET_Y = SETTINGS.D4_BAR_OFFSET_Y end
            if SETTINGS.D4_DUAL_BAR_OFFSET_Y == nil then SETTINGS.D4_DUAL_BAR_OFFSET_Y = SETTINGS.D4_BAR_OFFSET_Y end
            if SETTINGS.ULTIMATE_BAR_WIDTH_SCALE == nil then SETTINGS.ULTIMATE_BAR_WIDTH_SCALE = DEFAULT_SETTINGS.ULTIMATE_BAR_WIDTH_SCALE end
            if SETTINGS.ULTIMATE_BAR_HEIGHT == nil then SETTINGS.ULTIMATE_BAR_HEIGHT = DEFAULT_SETTINGS.ULTIMATE_BAR_HEIGHT end
            if SETTINGS.ULTIMATE_BAR_OFFSET_Y == nil then SETTINGS.ULTIMATE_BAR_OFFSET_Y = DEFAULT_SETTINGS.ULTIMATE_BAR_OFFSET_Y end
            if SETTINGS.ULTIMATE_BAR_SOLO_WIDTH_SCALE == nil then SETTINGS.ULTIMATE_BAR_SOLO_WIDTH_SCALE = SETTINGS.ULTIMATE_BAR_WIDTH_SCALE end
            if SETTINGS.ULTIMATE_BAR_SOLO_HEIGHT == nil then SETTINGS.ULTIMATE_BAR_SOLO_HEIGHT = SETTINGS.ULTIMATE_BAR_HEIGHT end
            if SETTINGS.ULTIMATE_BAR_SOLO_OFFSET_Y == nil then SETTINGS.ULTIMATE_BAR_SOLO_OFFSET_Y = SETTINGS.ULTIMATE_BAR_OFFSET_Y end
            if SETTINGS.ULTIMATE_BAR_DUAL_WIDTH_SCALE == nil then SETTINGS.ULTIMATE_BAR_DUAL_WIDTH_SCALE = SETTINGS.ULTIMATE_BAR_WIDTH_SCALE end
            if SETTINGS.ULTIMATE_BAR_DUAL_HEIGHT == nil then SETTINGS.ULTIMATE_BAR_DUAL_HEIGHT = SETTINGS.ULTIMATE_BAR_HEIGHT end
            if SETTINGS.ULTIMATE_BAR_DUAL_OFFSET_Y == nil then SETTINGS.ULTIMATE_BAR_DUAL_OFFSET_Y = SETTINGS.ULTIMATE_BAR_OFFSET_Y end
            if SETTINGS.SHOW_ULTIMATE_BAR_BACKGROUND == nil then SETTINGS.SHOW_ULTIMATE_BAR_BACKGROUND = DEFAULT_SETTINGS.SHOW_ULTIMATE_BAR_BACKGROUND end
            if SETTINGS.ULTIMATE_TEXT_FONT_SIZE == nil then SETTINGS.ULTIMATE_TEXT_FONT_SIZE = DEFAULT_SETTINGS.ULTIMATE_TEXT_FONT_SIZE end
            if SETTINGS.ULTIMATE_TEXT_ALPHA == nil then SETTINGS.ULTIMATE_TEXT_ALPHA = DEFAULT_SETTINGS.ULTIMATE_TEXT_ALPHA end
            if SETTINGS.ULTIMATE_TEXT_COLOR_R == nil then SETTINGS.ULTIMATE_TEXT_COLOR_R = DEFAULT_SETTINGS.ULTIMATE_TEXT_COLOR_R end
            if SETTINGS.ULTIMATE_TEXT_COLOR_G == nil then SETTINGS.ULTIMATE_TEXT_COLOR_G = DEFAULT_SETTINGS.ULTIMATE_TEXT_COLOR_G end
            if SETTINGS.ULTIMATE_TEXT_COLOR_B == nil then SETTINGS.ULTIMATE_TEXT_COLOR_B = DEFAULT_SETTINGS.ULTIMATE_TEXT_COLOR_B end
            if SETTINGS.ULTIMATE_BAR_FILL_ALPHA == nil then SETTINGS.ULTIMATE_BAR_FILL_ALPHA = DEFAULT_SETTINGS.ULTIMATE_BAR_FILL_ALPHA end
            if SETTINGS.ULTIMATE_BAR_BG_ALPHA == nil then SETTINGS.ULTIMATE_BAR_BG_ALPHA = DEFAULT_SETTINGS.ULTIMATE_BAR_BG_ALPHA end
            if SETTINGS.ULTIMATE_BAR_BG_COLOR_R == nil then SETTINGS.ULTIMATE_BAR_BG_COLOR_R = DEFAULT_SETTINGS.ULTIMATE_BAR_BG_COLOR_R end
            if SETTINGS.ULTIMATE_BAR_BG_COLOR_G == nil then SETTINGS.ULTIMATE_BAR_BG_COLOR_G = DEFAULT_SETTINGS.ULTIMATE_BAR_BG_COLOR_G end
            if SETTINGS.ULTIMATE_BAR_BG_COLOR_B == nil then SETTINGS.ULTIMATE_BAR_BG_COLOR_B = DEFAULT_SETTINGS.ULTIMATE_BAR_BG_COLOR_B end
            if SETTINGS.ULTIMATE_BAR_BG_SOLO_WIDTH_SCALE == nil then SETTINGS.ULTIMATE_BAR_BG_SOLO_WIDTH_SCALE = SETTINGS.ULTIMATE_BAR_SOLO_WIDTH_SCALE end
            if SETTINGS.ULTIMATE_BAR_BG_SOLO_HEIGHT == nil then SETTINGS.ULTIMATE_BAR_BG_SOLO_HEIGHT = SETTINGS.ULTIMATE_BAR_SOLO_HEIGHT end
            if SETTINGS.ULTIMATE_BAR_BG_SOLO_OFFSET_Y == nil then SETTINGS.ULTIMATE_BAR_BG_SOLO_OFFSET_Y = SETTINGS.ULTIMATE_BAR_SOLO_OFFSET_Y end
            if SETTINGS.ULTIMATE_BAR_BG_DUAL_WIDTH_SCALE == nil then SETTINGS.ULTIMATE_BAR_BG_DUAL_WIDTH_SCALE = SETTINGS.ULTIMATE_BAR_DUAL_WIDTH_SCALE end
            if SETTINGS.ULTIMATE_BAR_BG_DUAL_HEIGHT == nil then SETTINGS.ULTIMATE_BAR_BG_DUAL_HEIGHT = SETTINGS.ULTIMATE_BAR_DUAL_HEIGHT end
            if SETTINGS.ULTIMATE_BAR_BG_DUAL_OFFSET_Y == nil then SETTINGS.ULTIMATE_BAR_BG_DUAL_OFFSET_Y = SETTINGS.ULTIMATE_BAR_DUAL_OFFSET_Y end
            if SETTINGS.D4_BACKPLATE_OFFSET_X == nil then SETTINGS.D4_BACKPLATE_OFFSET_X = DEFAULT_SETTINGS.D4_BACKPLATE_OFFSET_X end
            if SETTINGS.D4_BACKPLATE_OFFSET_Y == nil then SETTINGS.D4_BACKPLATE_OFFSET_Y = DEFAULT_SETTINGS.D4_BACKPLATE_OFFSET_Y end
            if SETTINGS.D4_BACKPLATE_WIDTH_SCALE == nil then SETTINGS.D4_BACKPLATE_WIDTH_SCALE = DEFAULT_SETTINGS.D4_BACKPLATE_WIDTH_SCALE end
            if SETTINGS.D4_BACKPLATE_HEIGHT_SCALE == nil then SETTINGS.D4_BACKPLATE_HEIGHT_SCALE = DEFAULT_SETTINGS.D4_BACKPLATE_HEIGHT_SCALE end
            if SETTINGS.D4_SHOW_LIVE_PREVIEW == nil then SETTINGS.D4_SHOW_LIVE_PREVIEW = DEFAULT_SETTINGS.D4_SHOW_LIVE_PREVIEW end
            if SETTINGS.D4_BACKPLATE_INSET_X == nil then SETTINGS.D4_BACKPLATE_INSET_X = DEFAULT_SETTINGS.D4_BACKPLATE_INSET_X end
            -- Migration: abandon du systeme a presets DDS. On repart sur une luminosite simple en pourcentage.
            if SETTINGS.D4_BAR_BRIGHTNESS == nil then SETTINGS.D4_BAR_BRIGHTNESS = DEFAULT_SETTINGS.D4_BAR_BRIGHTNESS end
            SETTINGS.D4_BAR_BRIGHTNESS_PRESET = nil
            if SETTINGS.D4_ORB_BACKPLATE_PRESET == nil then SETTINGS.D4_ORB_BACKPLATE_PRESET = DEFAULT_SETTINGS.D4_ORB_BACKPLATE_PRESET end
            if SETTINGS.D4_IDLE_HIGHLIGHT_ALPHA == nil then SETTINGS.D4_IDLE_HIGHLIGHT_ALPHA = DEFAULT_SETTINGS.D4_IDLE_HIGHLIGHT_ALPHA end
            if SETTINGS.D4_MIN_SHADE_ALPHA == nil then SETTINGS.D4_MIN_SHADE_ALPHA = DEFAULT_SETTINGS.D4_MIN_SHADE_ALPHA end
            if SETTINGS.D4_FILL_LAYER_ALPHA == nil then SETTINGS.D4_FILL_LAYER_ALPHA = DEFAULT_SETTINGS.D4_FILL_LAYER_ALPHA end
            if SETTINGS.D4_FILL_LAYER_VISIBLE == nil then SETTINGS.D4_FILL_LAYER_VISIBLE = DEFAULT_SETTINGS.D4_FILL_LAYER_VISIBLE end
            if SETTINGS.D4_USE_TYPED_FILL_TEXTURES == nil then SETTINGS.D4_USE_TYPED_FILL_TEXTURES = DEFAULT_SETTINGS.D4_USE_TYPED_FILL_TEXTURES end
            if SETTINGS.D4_FILL_TINT_STRENGTH == nil then SETTINGS.D4_FILL_TINT_STRENGTH = DEFAULT_SETTINGS.D4_FILL_TINT_STRENGTH end
            if SETTINGS.D4_FILL_LAYER_SIZE == nil then SETTINGS.D4_FILL_LAYER_SIZE = DEFAULT_SETTINGS.D4_FILL_LAYER_SIZE end
            if SETTINGS.D4_FILL_LAYER_OFFSET_X == nil then SETTINGS.D4_FILL_LAYER_OFFSET_X = DEFAULT_SETTINGS.D4_FILL_LAYER_OFFSET_X end
            if SETTINGS.D4_FILL_LAYER_OFFSET_Y == nil then SETTINGS.D4_FILL_LAYER_OFFSET_Y = DEFAULT_SETTINGS.D4_FILL_LAYER_OFFSET_Y end
            if SETTINGS.D4_BACKGROUND_LAYER_ALPHA == nil then SETTINGS.D4_BACKGROUND_LAYER_ALPHA = DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_ALPHA end
            if SETTINGS.D4_BACKGROUND_LAYER_VISIBLE == nil then SETTINGS.D4_BACKGROUND_LAYER_VISIBLE = DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_VISIBLE end
            if SETTINGS.D4_BACKGROUND_LAYER_BRIGHTNESS == nil then SETTINGS.D4_BACKGROUND_LAYER_BRIGHTNESS = DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_BRIGHTNESS end
            if SETTINGS.D4_BACKGROUND_LAYER_SIZE == nil then SETTINGS.D4_BACKGROUND_LAYER_SIZE = DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_SIZE end
            if SETTINGS.D4_BACKGROUND_LAYER_WIDTH == nil then SETTINGS.D4_BACKGROUND_LAYER_WIDTH = DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_WIDTH end
            if SETTINGS.D4_BACKGROUND_LAYER_HEIGHT == nil then SETTINGS.D4_BACKGROUND_LAYER_HEIGHT = DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_HEIGHT end
            if SETTINGS.D4_BACKGROUND_LAYER_OFFSET_X == nil then SETTINGS.D4_BACKGROUND_LAYER_OFFSET_X = DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_OFFSET_X end
            if SETTINGS.D4_BACKGROUND_LAYER_OFFSET_Y == nil then SETTINGS.D4_BACKGROUND_LAYER_OFFSET_Y = DEFAULT_SETTINGS.D4_BACKGROUND_LAYER_OFFSET_Y end
            if SETTINGS.D4_BACKGROUND_NEGATIVE == nil then SETTINGS.D4_BACKGROUND_NEGATIVE = DEFAULT_SETTINGS.D4_BACKGROUND_NEGATIVE end
            if SETTINGS.D4_BACKGROUND_EDGE_LIGHT_BOOST == nil then SETTINGS.D4_BACKGROUND_EDGE_LIGHT_BOOST = DEFAULT_SETTINGS.D4_BACKGROUND_EDGE_LIGHT_BOOST end
            if SETTINGS.D4_GLOW_LAYER_ALPHA == nil then SETTINGS.D4_GLOW_LAYER_ALPHA = DEFAULT_SETTINGS.D4_GLOW_LAYER_ALPHA end
            if SETTINGS.D4_GLOW_LAYER_VISIBLE == nil then SETTINGS.D4_GLOW_LAYER_VISIBLE = DEFAULT_SETTINGS.D4_GLOW_LAYER_VISIBLE end
            if SETTINGS.D4_GLOW_LAYER_SIZE == nil then SETTINGS.D4_GLOW_LAYER_SIZE = DEFAULT_SETTINGS.D4_GLOW_LAYER_SIZE end
            if SETTINGS.D4_GLOW_LAYER_OFFSET_X == nil then SETTINGS.D4_GLOW_LAYER_OFFSET_X = DEFAULT_SETTINGS.D4_GLOW_LAYER_OFFSET_X end
            if SETTINGS.D4_GLOW_LAYER_OFFSET_Y == nil then SETTINGS.D4_GLOW_LAYER_OFFSET_Y = DEFAULT_SETTINGS.D4_GLOW_LAYER_OFFSET_Y end
            if SETTINGS.D4_SHADE_LAYER_ALPHA == nil then SETTINGS.D4_SHADE_LAYER_ALPHA = DEFAULT_SETTINGS.D4_SHADE_LAYER_ALPHA end
            if SETTINGS.D4_SHADE_LAYER_VISIBLE == nil then SETTINGS.D4_SHADE_LAYER_VISIBLE = DEFAULT_SETTINGS.D4_SHADE_LAYER_VISIBLE end
            if SETTINGS.D4_SHADE_LAYER_SIZE == nil then SETTINGS.D4_SHADE_LAYER_SIZE = DEFAULT_SETTINGS.D4_SHADE_LAYER_SIZE end
            if SETTINGS.D4_SHADE_LAYER_OFFSET_X == nil then SETTINGS.D4_SHADE_LAYER_OFFSET_X = DEFAULT_SETTINGS.D4_SHADE_LAYER_OFFSET_X end
            if SETTINGS.D4_SHADE_LAYER_OFFSET_Y == nil then SETTINGS.D4_SHADE_LAYER_OFFSET_Y = DEFAULT_SETTINGS.D4_SHADE_LAYER_OFFSET_Y end
            if SETTINGS.D4_BORDER_LAYER_ALPHA == nil then SETTINGS.D4_BORDER_LAYER_ALPHA = DEFAULT_SETTINGS.D4_BORDER_LAYER_ALPHA end
            if SETTINGS.D4_BORDER_LAYER_VISIBLE == nil then SETTINGS.D4_BORDER_LAYER_VISIBLE = DEFAULT_SETTINGS.D4_BORDER_LAYER_VISIBLE end
            if SETTINGS.D4_BORDER_LAYER_SIZE == nil then SETTINGS.D4_BORDER_LAYER_SIZE = DEFAULT_SETTINGS.D4_BORDER_LAYER_SIZE end
            if SETTINGS.D4_BORDER_LAYER_OFFSET_X == nil then SETTINGS.D4_BORDER_LAYER_OFFSET_X = DEFAULT_SETTINGS.D4_BORDER_LAYER_OFFSET_X end
            if SETTINGS.D4_BORDER_LAYER_OFFSET_Y == nil then SETTINGS.D4_BORDER_LAYER_OFFSET_Y = DEFAULT_SETTINGS.D4_BORDER_LAYER_OFFSET_Y end
            if SETTINGS.D4_SEAM_VISIBLE == nil then SETTINGS.D4_SEAM_VISIBLE = DEFAULT_SETTINGS.D4_SEAM_VISIBLE end
            if SETTINGS.D4_SEAM_ALPHA == nil then SETTINGS.D4_SEAM_ALPHA = DEFAULT_SETTINGS.D4_SEAM_ALPHA end
            if SETTINGS.D4_SEAM_COLOR_R == nil then SETTINGS.D4_SEAM_COLOR_R = DEFAULT_SETTINGS.D4_SEAM_COLOR_R end
            if SETTINGS.D4_SEAM_COLOR_G == nil then SETTINGS.D4_SEAM_COLOR_G = DEFAULT_SETTINGS.D4_SEAM_COLOR_G end
            if SETTINGS.D4_SEAM_COLOR_B == nil then SETTINGS.D4_SEAM_COLOR_B = DEFAULT_SETTINGS.D4_SEAM_COLOR_B end
            if SETTINGS.D4_SEAM_WIDTH == nil then SETTINGS.D4_SEAM_WIDTH = DEFAULT_SETTINGS.D4_SEAM_WIDTH end
            if SETTINGS.D4_SEAM_HEIGHT == nil then SETTINGS.D4_SEAM_HEIGHT = DEFAULT_SETTINGS.D4_SEAM_HEIGHT end
            if SETTINGS.D4_SEAM_BRIGHTNESS == nil then SETTINGS.D4_SEAM_BRIGHTNESS = DEFAULT_SETTINGS.D4_SEAM_BRIGHTNESS end
            if SETTINGS.D4_SEAM_ADDITIVE == nil then SETTINGS.D4_SEAM_ADDITIVE = DEFAULT_SETTINGS.D4_SEAM_ADDITIVE end
            if SETTINGS.D4_SEAM_OFFSET_X == nil then SETTINGS.D4_SEAM_OFFSET_X = DEFAULT_SETTINGS.D4_SEAM_OFFSET_X end
            if SETTINGS.D4_SEAM_OFFSET_Y == nil then SETTINGS.D4_SEAM_OFFSET_Y = DEFAULT_SETTINGS.D4_SEAM_OFFSET_Y end
            if SETTINGS.D4_GLOW_BRIGHTNESS == nil then SETTINGS.D4_GLOW_BRIGHTNESS = DEFAULT_SETTINGS.D4_GLOW_BRIGHTNESS end
            if SETTINGS.D4_GLOW_TINT == nil then SETTINGS.D4_GLOW_TINT = DEFAULT_SETTINGS.D4_GLOW_TINT end
            if SETTINGS.D4_OVERLAY_BRIGHTNESS == nil then SETTINGS.D4_OVERLAY_BRIGHTNESS = DEFAULT_SETTINGS.D4_OVERLAY_BRIGHTNESS end
            if SETTINGS.D4_OVERLAY_CONTRAST == nil then SETTINGS.D4_OVERLAY_CONTRAST = DEFAULT_SETTINGS.D4_OVERLAY_CONTRAST end
            if SETTINGS.D4_OVERLAY_LAYER_ALPHA == nil then SETTINGS.D4_OVERLAY_LAYER_ALPHA = DEFAULT_SETTINGS.D4_OVERLAY_LAYER_ALPHA end
            if SETTINGS.D4_OVERLAY_LAYER_VISIBLE == nil then SETTINGS.D4_OVERLAY_LAYER_VISIBLE = DEFAULT_SETTINGS.D4_OVERLAY_LAYER_VISIBLE end
            if SETTINGS.D4_OVERLAY_LAYER_SIZE == nil then SETTINGS.D4_OVERLAY_LAYER_SIZE = DEFAULT_SETTINGS.D4_OVERLAY_LAYER_SIZE end
            if SETTINGS.D4_OVERLAY_LAYER_OFFSET_X == nil then SETTINGS.D4_OVERLAY_LAYER_OFFSET_X = DEFAULT_SETTINGS.D4_OVERLAY_LAYER_OFFSET_X end
            if SETTINGS.D4_OVERLAY_LAYER_OFFSET_Y == nil then SETTINGS.D4_OVERLAY_LAYER_OFFSET_Y = DEFAULT_SETTINGS.D4_OVERLAY_LAYER_OFFSET_Y end
            if SETTINGS.D4_BAR_QUICKSLOT_OFFSET_X == nil then SETTINGS.D4_BAR_QUICKSLOT_OFFSET_X = DEFAULT_SETTINGS.D4_BAR_QUICKSLOT_OFFSET_X end
            if SETTINGS.D4_BAR_QUICKSLOT_OFFSET_Y == nil then SETTINGS.D4_BAR_QUICKSLOT_OFFSET_Y = DEFAULT_SETTINGS.D4_BAR_QUICKSLOT_OFFSET_Y end
            if SETTINGS.D4_BAR_ULTIMATE_OFFSET_X == nil then SETTINGS.D4_BAR_ULTIMATE_OFFSET_X = DEFAULT_SETTINGS.D4_BAR_ULTIMATE_OFFSET_X end
            if SETTINGS.D4_BAR_ULTIMATE_OFFSET_Y == nil then SETTINGS.D4_BAR_ULTIMATE_OFFSET_Y = DEFAULT_SETTINGS.D4_BAR_ULTIMATE_OFFSET_Y end
            if SETTINGS.D4_BAR_SLOTS_OFFSET_Y == nil then SETTINGS.D4_BAR_SLOTS_OFFSET_Y = DEFAULT_SETTINGS.D4_BAR_SLOTS_OFFSET_Y end
            if SETTINGS.D4_BAR_SLOTS_OFFSET_Y_DUAL == nil then SETTINGS.D4_BAR_SLOTS_OFFSET_Y_DUAL = DEFAULT_SETTINGS.D4_BAR_SLOTS_OFFSET_Y_DUAL end
            if SETTINGS.ACTION_BAR_CENTER_SLOTS_GAP_X == nil then SETTINGS.ACTION_BAR_CENTER_SLOTS_GAP_X = DEFAULT_SETTINGS.ACTION_BAR_CENTER_SLOTS_GAP_X end
            if SETTINGS.D4_ALL_SLOT_BORDER_ALPHA == nil then SETTINGS.D4_ALL_SLOT_BORDER_ALPHA = DEFAULT_SETTINGS.D4_ALL_SLOT_BORDER_ALPHA end
            if SETTINGS.D4_SLOT_BORDER_DARKNESS == nil then SETTINGS.D4_SLOT_BORDER_DARKNESS = DEFAULT_SETTINGS.D4_SLOT_BORDER_DARKNESS end
            if SETTINGS.D4_SLOT_BORDER_CONTRAST == nil then SETTINGS.D4_SLOT_BORDER_CONTRAST = DEFAULT_SETTINGS.D4_SLOT_BORDER_CONTRAST end
            if SETTINGS.D4_SLOT_SMOKE_INTENSITY == nil then SETTINGS.D4_SLOT_SMOKE_INTENSITY = DEFAULT_SETTINGS.D4_SLOT_SMOKE_INTENSITY end
            if SETTINGS.D4_COMPANION_SLOT_BORDER_DARKNESS == nil then SETTINGS.D4_COMPANION_SLOT_BORDER_DARKNESS = DEFAULT_SETTINGS.D4_COMPANION_SLOT_BORDER_DARKNESS end
            if SETTINGS.LABEL_POSITION_MODE == nil then SETTINGS.LABEL_POSITION_MODE = DEFAULT_SETTINGS.LABEL_POSITION_MODE end
            if SETTINGS.LABEL_INSIDE_SWAP_MANA_STAMINA == nil then SETTINGS.LABEL_INSIDE_SWAP_MANA_STAMINA = DEFAULT_SETTINGS.LABEL_INSIDE_SWAP_MANA_STAMINA end
            if SETTINGS.LABEL_INNER_STYLE == nil then SETTINGS.LABEL_INNER_STYLE = DEFAULT_SETTINGS.LABEL_INNER_STYLE end
            if SETTINGS.LABEL_TEXT_ALPHA == nil then SETTINGS.LABEL_TEXT_ALPHA = DEFAULT_SETTINGS.LABEL_TEXT_ALPHA end
            if SETTINGS.LABEL_INNER_SHADE_ALPHA == nil then SETTINGS.LABEL_INNER_SHADE_ALPHA = DEFAULT_SETTINGS.LABEL_INNER_SHADE_ALPHA end
            if SETTINGS.LABEL_INNER_BACKDROP_ALPHA == nil then SETTINGS.LABEL_INNER_BACKDROP_ALPHA = DEFAULT_SETTINGS.LABEL_INNER_BACKDROP_ALPHA end
            if SETTINGS.LABEL_INNER_SHADE_COLOR_R == nil then SETTINGS.LABEL_INNER_SHADE_COLOR_R = DEFAULT_SETTINGS.LABEL_INNER_SHADE_COLOR_R end
            if SETTINGS.LABEL_INNER_SHADE_COLOR_G == nil then SETTINGS.LABEL_INNER_SHADE_COLOR_G = DEFAULT_SETTINGS.LABEL_INNER_SHADE_COLOR_G end
            if SETTINGS.LABEL_INNER_SHADE_COLOR_B == nil then SETTINGS.LABEL_INNER_SHADE_COLOR_B = DEFAULT_SETTINGS.LABEL_INNER_SHADE_COLOR_B end
            if SETTINGS.LABEL_OUTER_PADDING_X == nil then SETTINGS.LABEL_OUTER_PADDING_X = DEFAULT_SETTINGS.LABEL_OUTER_PADDING_X end
            if SETTINGS.LABEL_OUTER_PADDING_Y == nil then SETTINGS.LABEL_OUTER_PADDING_Y = DEFAULT_SETTINGS.LABEL_OUTER_PADDING_Y end
            if SETTINGS.LABEL_INSIDE_HEALTH_OFFSET_X == nil then SETTINGS.LABEL_INSIDE_HEALTH_OFFSET_X = DEFAULT_SETTINGS.LABEL_INSIDE_HEALTH_OFFSET_X end
            if SETTINGS.LABEL_CENTER_GAP_X == nil then SETTINGS.LABEL_CENTER_GAP_X = DEFAULT_SETTINGS.LABEL_CENTER_GAP_X end
            if SETTINGS.LABEL_OFFSET_Y == nil then SETTINGS.LABEL_OFFSET_Y = DEFAULT_SETTINGS.LABEL_OFFSET_Y end
            if SETTINGS.SHOW_SHIELD_LABEL == nil then SETTINGS.SHOW_SHIELD_LABEL = DEFAULT_SETTINGS.SHOW_SHIELD_LABEL end
            if SETTINGS.SHIELD_LABEL_OFFSET_X == nil then SETTINGS.SHIELD_LABEL_OFFSET_X = DEFAULT_SETTINGS.SHIELD_LABEL_OFFSET_X end
            if SETTINGS.SHIELD_LABEL_OFFSET_Y == nil then SETTINGS.SHIELD_LABEL_OFFSET_Y = DEFAULT_SETTINGS.SHIELD_LABEL_OFFSET_Y end
            if SETTINGS.D4_SHOW_SHIELD_LABEL == nil then SETTINGS.D4_SHOW_SHIELD_LABEL = SETTINGS.SHOW_SHIELD_LABEL end
            if SETTINGS.D4_SHIELD_LABEL_OFFSET_X == nil then SETTINGS.D4_SHIELD_LABEL_OFFSET_X = SETTINGS.SHIELD_LABEL_OFFSET_X end
            if SETTINGS.D4_SHIELD_LABEL_OFFSET_Y == nil then SETTINGS.D4_SHIELD_LABEL_OFFSET_Y = SETTINGS.SHIELD_LABEL_OFFSET_Y end
            if SETTINGS.NUMBER_FONT_FAMILY == nil then SETTINGS.NUMBER_FONT_FAMILY = DEFAULT_SETTINGS.NUMBER_FONT_FAMILY end
            if SETTINGS.LEGACY_INTERFACE_SCALE == nil then SETTINGS.LEGACY_INTERFACE_SCALE = DEFAULT_SETTINGS.LEGACY_INTERFACE_SCALE end
            if SETTINGS.LEGACY_ORB_LAYER_GLOBAL_SCALE == nil then SETTINGS.LEGACY_ORB_LAYER_GLOBAL_SCALE = DEFAULT_SETTINGS.LEGACY_ORB_LAYER_GLOBAL_SCALE end
            if SETTINGS.ORB_BRIGHTNESS == nil then SETTINGS.ORB_BRIGHTNESS = DEFAULT_SETTINGS.ORB_BRIGHTNESS end
            if SETTINGS.ORB_TINT_LAYER_ENABLED == nil then SETTINGS.ORB_TINT_LAYER_ENABLED = DEFAULT_SETTINGS.ORB_TINT_LAYER_ENABLED end
            if SETTINGS.ORB_TINT_LAYER_ALPHA == nil then SETTINGS.ORB_TINT_LAYER_ALPHA = DEFAULT_SETTINGS.ORB_TINT_LAYER_ALPHA end
            if SETTINGS.ORB_TINT_LAYER_COLOR_R == nil then SETTINGS.ORB_TINT_LAYER_COLOR_R = DEFAULT_SETTINGS.ORB_TINT_LAYER_COLOR_R end
            if SETTINGS.ORB_TINT_LAYER_COLOR_G == nil then SETTINGS.ORB_TINT_LAYER_COLOR_G = DEFAULT_SETTINGS.ORB_TINT_LAYER_COLOR_G end
            if SETTINGS.ORB_TINT_LAYER_COLOR_B == nil then SETTINGS.ORB_TINT_LAYER_COLOR_B = DEFAULT_SETTINGS.ORB_TINT_LAYER_COLOR_B end
            if SETTINGS.D4_ORB_COLOR_BOOST == nil then SETTINGS.D4_ORB_COLOR_BOOST = SETTINGS.ORB_COLOR_BOOST or DEFAULT_SETTINGS.D4_ORB_COLOR_BOOST end
            if SETTINGS.D4_ORB_BRIGHTNESS == nil then SETTINGS.D4_ORB_BRIGHTNESS = SETTINGS.ORB_BRIGHTNESS or DEFAULT_SETTINGS.D4_ORB_BRIGHTNESS end
            if SETTINGS.D4_ORB_TINT_LAYER_ENABLED == nil then SETTINGS.D4_ORB_TINT_LAYER_ENABLED = SETTINGS.ORB_TINT_LAYER_ENABLED or DEFAULT_SETTINGS.D4_ORB_TINT_LAYER_ENABLED end
            if SETTINGS.D4_ORB_TINT_LAYER_ALPHA == nil then SETTINGS.D4_ORB_TINT_LAYER_ALPHA = SETTINGS.ORB_TINT_LAYER_ALPHA or DEFAULT_SETTINGS.D4_ORB_TINT_LAYER_ALPHA end
            if SETTINGS.D4_ORB_TINT_LAYER_COLOR_R == nil then SETTINGS.D4_ORB_TINT_LAYER_COLOR_R = SETTINGS.ORB_TINT_LAYER_COLOR_R or DEFAULT_SETTINGS.D4_ORB_TINT_LAYER_COLOR_R end
            if SETTINGS.D4_ORB_TINT_LAYER_COLOR_G == nil then SETTINGS.D4_ORB_TINT_LAYER_COLOR_G = SETTINGS.ORB_TINT_LAYER_COLOR_G or DEFAULT_SETTINGS.D4_ORB_TINT_LAYER_COLOR_G end
            if SETTINGS.D4_ORB_TINT_LAYER_COLOR_B == nil then SETTINGS.D4_ORB_TINT_LAYER_COLOR_B = SETTINGS.ORB_TINT_LAYER_COLOR_B or DEFAULT_SETTINGS.D4_ORB_TINT_LAYER_COLOR_B end
            if SETTINGS.D4_HEALTH_COLOR_R == nil then SETTINGS.D4_HEALTH_COLOR_R = SETTINGS.HEALTH_COLOR_R or DEFAULT_SETTINGS.D4_HEALTH_COLOR_R end
            if SETTINGS.D4_HEALTH_COLOR_G == nil then SETTINGS.D4_HEALTH_COLOR_G = SETTINGS.HEALTH_COLOR_G or DEFAULT_SETTINGS.D4_HEALTH_COLOR_G end
            if SETTINGS.D4_HEALTH_COLOR_B == nil then SETTINGS.D4_HEALTH_COLOR_B = SETTINGS.HEALTH_COLOR_B or DEFAULT_SETTINGS.D4_HEALTH_COLOR_B end
            if SETTINGS.D4_MAGICKA_COLOR_R == nil then SETTINGS.D4_MAGICKA_COLOR_R = SETTINGS.MAGICKA_COLOR_R or DEFAULT_SETTINGS.D4_MAGICKA_COLOR_R end
            if SETTINGS.D4_MAGICKA_COLOR_G == nil then SETTINGS.D4_MAGICKA_COLOR_G = SETTINGS.MAGICKA_COLOR_G or DEFAULT_SETTINGS.D4_MAGICKA_COLOR_G end
            if SETTINGS.D4_MAGICKA_COLOR_B == nil then SETTINGS.D4_MAGICKA_COLOR_B = SETTINGS.MAGICKA_COLOR_B or DEFAULT_SETTINGS.D4_MAGICKA_COLOR_B end
            if SETTINGS.D4_STAMINA_COLOR_R == nil then SETTINGS.D4_STAMINA_COLOR_R = SETTINGS.STAMINA_COLOR_R or DEFAULT_SETTINGS.D4_STAMINA_COLOR_R end
            if SETTINGS.D4_STAMINA_COLOR_G == nil then SETTINGS.D4_STAMINA_COLOR_G = SETTINGS.STAMINA_COLOR_G or DEFAULT_SETTINGS.D4_STAMINA_COLOR_G end
            if SETTINGS.D4_STAMINA_COLOR_B == nil then SETTINGS.D4_STAMINA_COLOR_B = SETTINGS.STAMINA_COLOR_B or DEFAULT_SETTINGS.D4_STAMINA_COLOR_B end
            if SETTINGS.D4_SHIELD_COLOR_R == nil then SETTINGS.D4_SHIELD_COLOR_R = SETTINGS.SHIELD_COLOR_R or DEFAULT_SETTINGS.D4_SHIELD_COLOR_R end
            if SETTINGS.D4_SHIELD_COLOR_G == nil then SETTINGS.D4_SHIELD_COLOR_G = SETTINGS.SHIELD_COLOR_G or DEFAULT_SETTINGS.D4_SHIELD_COLOR_G end
            if SETTINGS.D4_SHIELD_COLOR_B == nil then SETTINGS.D4_SHIELD_COLOR_B = SETTINGS.SHIELD_COLOR_B or DEFAULT_SETTINGS.D4_SHIELD_COLOR_B end
            if SETTINGS.D4_SHIELD_ALPHA == nil then SETTINGS.D4_SHIELD_ALPHA = SETTINGS.SHIELD_ALPHA or DEFAULT_SETTINGS.D4_SHIELD_ALPHA end
            if SETTINGS.D4_SHIELD_LAYER_LEVEL == nil then SETTINGS.D4_SHIELD_LAYER_LEVEL = DEFAULT_SETTINGS.D4_SHIELD_LAYER_LEVEL end
            if SETTINGS.GLOW_CENTER_GAP_X == nil then SETTINGS.GLOW_CENTER_GAP_X = DEFAULT_SETTINGS.GLOW_CENTER_GAP_X end
            if SETTINGS.GLOW_OFFSET_Y == nil then SETTINGS.GLOW_OFFSET_Y = DEFAULT_SETTINGS.GLOW_OFFSET_Y end
            if SETTINGS.D4_GLOW_MAX_ALPHA == nil then SETTINGS.D4_GLOW_MAX_ALPHA = SETTINGS.GLOW_MAX_ALPHA or DEFAULT_SETTINGS.D4_GLOW_MAX_ALPHA end
            if SETTINGS.D4_GLOW_INTERNAL_ONLY == nil then SETTINGS.D4_GLOW_INTERNAL_ONLY = SETTINGS.GLOW_INTERNAL_ONLY end
            if SETTINGS.D4_GLOW_CENTER_GAP_X == nil then SETTINGS.D4_GLOW_CENTER_GAP_X = SETTINGS.GLOW_CENTER_GAP_X or DEFAULT_SETTINGS.D4_GLOW_CENTER_GAP_X end
            if SETTINGS.D4_GLOW_OFFSET_Y == nil then SETTINGS.D4_GLOW_OFFSET_Y = SETTINGS.GLOW_OFFSET_Y or DEFAULT_SETTINGS.D4_GLOW_OFFSET_Y end
            -- Migration des clés indépendantes par thème (ULTIMATE_BAR, LABEL, BORDER_PULSE)
            local THEME_MIGRATION_VERSION = 1
            if (SETTINGS.THEME_MIGRATION_VERSION or 0) < THEME_MIGRATION_VERSION then
                for _, key in ipairs(THEME_INDEPENDENT_KEYS) do
                    local d4key = "D4_" .. key
                    if SETTINGS[d4key] == nil then
                        SETTINGS[d4key] = SETTINGS[key] or DEFAULT_SETTINGS[d4key]
                    end
                end
                SETTINGS.THEME_MIGRATION_VERSION = THEME_MIGRATION_VERSION
            end
            if SETTINGS.VALUE_TOOLTIP_BORDER_ALPHA == nil then SETTINGS.VALUE_TOOLTIP_BORDER_ALPHA = DEFAULT_SETTINGS.VALUE_TOOLTIP_BORDER_ALPHA end
            if SETTINGS.D4_BACKBAR_OFFSET_X == nil then SETTINGS.D4_BACKBAR_OFFSET_X = DEFAULT_SETTINGS.D4_BACKBAR_OFFSET_X end
            if SETTINGS.D4_BACKBAR_OFFSET_Y == nil then SETTINGS.D4_BACKBAR_OFFSET_Y = DEFAULT_SETTINGS.D4_BACKBAR_OFFSET_Y end
            if SETTINGS.D4_BACKBAR_ALPHA == nil then SETTINGS.D4_BACKBAR_ALPHA = DEFAULT_SETTINGS.D4_BACKBAR_ALPHA end
            if SETTINGS.D4_BACKBAR_DESATURATION == nil then SETTINGS.D4_BACKBAR_DESATURATION = DEFAULT_SETTINGS.D4_BACKBAR_DESATURATION end
            if SETTINGS.D4_BACKBAR_SCALE == nil then SETTINGS.D4_BACKBAR_SCALE = DEFAULT_SETTINGS.D4_BACKBAR_SCALE end
            if SETTINGS.LEGACY_SHOW_BACKBAR == nil then SETTINGS.LEGACY_SHOW_BACKBAR = DEFAULT_SETTINGS.LEGACY_SHOW_BACKBAR end
            if SETTINGS.LEGACY_SOLO_ORB_OFFSET_Y == nil then SETTINGS.LEGACY_SOLO_ORB_OFFSET_Y = DEFAULT_SETTINGS.LEGACY_SOLO_ORB_OFFSET_Y end
            if SETTINGS.LEGACY_SOLO_ORB_OFFSET_X == nil then SETTINGS.LEGACY_SOLO_ORB_OFFSET_X = DEFAULT_SETTINGS.LEGACY_SOLO_ORB_OFFSET_X end
            if SETTINGS.LEGACY_DUAL_ORB_OFFSET_Y == nil then SETTINGS.LEGACY_DUAL_ORB_OFFSET_Y = DEFAULT_SETTINGS.LEGACY_DUAL_ORB_OFFSET_Y end
            if SETTINGS.LEGACY_DUAL_ORB_OFFSET_X == nil then SETTINGS.LEGACY_DUAL_ORB_OFFSET_X = DEFAULT_SETTINGS.LEGACY_DUAL_ORB_OFFSET_X end
            if SETTINGS.LEGACY_SOLO_ACTION_BAR_CENTER_SLOTS_GAP_X == nil then SETTINGS.LEGACY_SOLO_ACTION_BAR_CENTER_SLOTS_GAP_X = DEFAULT_SETTINGS.LEGACY_SOLO_ACTION_BAR_CENTER_SLOTS_GAP_X end
            if SETTINGS.LEGACY_SOLO_ULTIMATE_OFFSET_X == nil then SETTINGS.LEGACY_SOLO_ULTIMATE_OFFSET_X = DEFAULT_SETTINGS.LEGACY_SOLO_ULTIMATE_OFFSET_X end
            if SETTINGS.LEGACY_SOLO_QUICKSLOT_OFFSET_X == nil then SETTINGS.LEGACY_SOLO_QUICKSLOT_OFFSET_X = DEFAULT_SETTINGS.LEGACY_SOLO_QUICKSLOT_OFFSET_X end
            if SETTINGS.LEGACY_DUAL_ACTION_BAR_CENTER_SLOTS_GAP_X == nil then SETTINGS.LEGACY_DUAL_ACTION_BAR_CENTER_SLOTS_GAP_X = DEFAULT_SETTINGS.LEGACY_DUAL_ACTION_BAR_CENTER_SLOTS_GAP_X end
            if SETTINGS.LEGACY_DUAL_ULTIMATE_OFFSET_X == nil then SETTINGS.LEGACY_DUAL_ULTIMATE_OFFSET_X = DEFAULT_SETTINGS.LEGACY_DUAL_ULTIMATE_OFFSET_X end
            if SETTINGS.LEGACY_DUAL_QUICKSLOT_OFFSET_X == nil then SETTINGS.LEGACY_DUAL_QUICKSLOT_OFFSET_X = DEFAULT_SETTINGS.LEGACY_DUAL_QUICKSLOT_OFFSET_X end
            if SETTINGS.LEGACY_BG_SOLO_MIDDLE_WIDTH == nil then SETTINGS.LEGACY_BG_SOLO_MIDDLE_WIDTH = DEFAULT_SETTINGS.LEGACY_BG_SOLO_MIDDLE_WIDTH end
            if SETTINGS.LEGACY_BG_SOLO_MIDDLE_HEIGHT == nil then SETTINGS.LEGACY_BG_SOLO_MIDDLE_HEIGHT = DEFAULT_SETTINGS.LEGACY_BG_SOLO_MIDDLE_HEIGHT end
            if SETTINGS.LEGACY_BG_SOLO_MIDDLE_OFFSET_X == nil then SETTINGS.LEGACY_BG_SOLO_MIDDLE_OFFSET_X = DEFAULT_SETTINGS.LEGACY_BG_SOLO_MIDDLE_OFFSET_X end
            if SETTINGS.LEGACY_BG_SOLO_MIDDLE_OFFSET_Y == nil then SETTINGS.LEGACY_BG_SOLO_MIDDLE_OFFSET_Y = DEFAULT_SETTINGS.LEGACY_BG_SOLO_MIDDLE_OFFSET_Y end
            if SETTINGS.LEGACY_BG_SOLO_LEFT_OFFSET_X == nil then SETTINGS.LEGACY_BG_SOLO_LEFT_OFFSET_X = DEFAULT_SETTINGS.LEGACY_BG_SOLO_LEFT_OFFSET_X end
            if SETTINGS.LEGACY_BG_SOLO_RIGHT_OFFSET_X == nil then SETTINGS.LEGACY_BG_SOLO_RIGHT_OFFSET_X = DEFAULT_SETTINGS.LEGACY_BG_SOLO_RIGHT_OFFSET_X end
            if SETTINGS.LEGACY_BG_DUAL_MIDDLE_WIDTH == nil then SETTINGS.LEGACY_BG_DUAL_MIDDLE_WIDTH = DEFAULT_SETTINGS.LEGACY_BG_DUAL_MIDDLE_WIDTH end
            if SETTINGS.LEGACY_BG_DUAL_MIDDLE_HEIGHT == nil then SETTINGS.LEGACY_BG_DUAL_MIDDLE_HEIGHT = DEFAULT_SETTINGS.LEGACY_BG_DUAL_MIDDLE_HEIGHT end
            if SETTINGS.LEGACY_BG_DUAL_MIDDLE_OFFSET_X == nil then SETTINGS.LEGACY_BG_DUAL_MIDDLE_OFFSET_X = DEFAULT_SETTINGS.LEGACY_BG_DUAL_MIDDLE_OFFSET_X end
            if SETTINGS.LEGACY_BG_DUAL_MIDDLE_OFFSET_Y == nil then SETTINGS.LEGACY_BG_DUAL_MIDDLE_OFFSET_Y = DEFAULT_SETTINGS.LEGACY_BG_DUAL_MIDDLE_OFFSET_Y end
            if SETTINGS.LEGACY_BG_DUAL_LEFT_OFFSET_X == nil then SETTINGS.LEGACY_BG_DUAL_LEFT_OFFSET_X = DEFAULT_SETTINGS.LEGACY_BG_DUAL_LEFT_OFFSET_X end
            if SETTINGS.LEGACY_BG_DUAL_RIGHT_OFFSET_X == nil then SETTINGS.LEGACY_BG_DUAL_RIGHT_OFFSET_X = DEFAULT_SETTINGS.LEGACY_BG_DUAL_RIGHT_OFFSET_X end
            if SETTINGS.LEGACY_BACKBAR_OFFSET_X == nil then SETTINGS.LEGACY_BACKBAR_OFFSET_X = DEFAULT_SETTINGS.LEGACY_BACKBAR_OFFSET_X end
            if SETTINGS.LEGACY_BACKBAR_OFFSET_Y == nil then SETTINGS.LEGACY_BACKBAR_OFFSET_Y = DEFAULT_SETTINGS.LEGACY_BACKBAR_OFFSET_Y end
            if SETTINGS.LEGACY_BACKBAR_ALPHA == nil then SETTINGS.LEGACY_BACKBAR_ALPHA = DEFAULT_SETTINGS.LEGACY_BACKBAR_ALPHA end
            if SETTINGS.LEGACY_BACKBAR_DESATURATION == nil then SETTINGS.LEGACY_BACKBAR_DESATURATION = DEFAULT_SETTINGS.LEGACY_BACKBAR_DESATURATION end
            if SETTINGS.LEGACY_BACKBAR_SCALE == nil then SETTINGS.LEGACY_BACKBAR_SCALE = DEFAULT_SETTINGS.LEGACY_BACKBAR_SCALE end
            if SETTINGS.LEGACY_BACKBAR_SLOT_SIZE == nil then SETTINGS.LEGACY_BACKBAR_SLOT_SIZE = DEFAULT_SETTINGS.LEGACY_BACKBAR_SLOT_SIZE end
            if SETTINGS.LEGACY_BACKBAR_SLOT_GAP == nil then SETTINGS.LEGACY_BACKBAR_SLOT_GAP = DEFAULT_SETTINGS.LEGACY_BACKBAR_SLOT_GAP end
            if SETTINGS.LEGACY_BACKBAR_ULT_GAP == nil then SETTINGS.LEGACY_BACKBAR_ULT_GAP = DEFAULT_SETTINGS.LEGACY_BACKBAR_ULT_GAP end
            if SETTINGS.LEGACY_BACKBAR_ULT_OFFSET_X == nil then SETTINGS.LEGACY_BACKBAR_ULT_OFFSET_X = DEFAULT_SETTINGS.LEGACY_BACKBAR_ULT_OFFSET_X end
            if SETTINGS.LEGACY_BACKBAR_ULT_OFFSET_Y == nil then SETTINGS.LEGACY_BACKBAR_ULT_OFFSET_Y = DEFAULT_SETTINGS.LEGACY_BACKBAR_ULT_OFFSET_Y end
            if SETTINGS.D4_GLOBAL_TINT_R == nil then SETTINGS.D4_GLOBAL_TINT_R = DEFAULT_SETTINGS.D4_GLOBAL_TINT_R end
            if SETTINGS.D4_GLOBAL_TINT_G == nil then SETTINGS.D4_GLOBAL_TINT_G = DEFAULT_SETTINGS.D4_GLOBAL_TINT_G end
            if SETTINGS.D4_GLOBAL_TINT_B == nil then SETTINGS.D4_GLOBAL_TINT_B = DEFAULT_SETTINGS.D4_GLOBAL_TINT_B end
            if SETTINGS.D4_GLOBAL_TINT_INTENSITY == nil then SETTINGS.D4_GLOBAL_TINT_INTENSITY = DEFAULT_SETTINGS.D4_GLOBAL_TINT_INTENSITY end
            -- Décorations Legacy (Angel / Demon)
            if SETTINGS.LEGACY_DECO_VISIBLE == nil then SETTINGS.LEGACY_DECO_VISIBLE = DEFAULT_SETTINGS.LEGACY_DECO_VISIBLE end
            if SETTINGS.LEGACY_DECO_SIZE == nil then SETTINGS.LEGACY_DECO_SIZE = DEFAULT_SETTINGS.LEGACY_DECO_SIZE end
            if SETTINGS.LEGACY_DECO_WIDTH == nil then SETTINGS.LEGACY_DECO_WIDTH = DEFAULT_SETTINGS.LEGACY_DECO_WIDTH end
            if SETTINGS.LEGACY_DECO_HEIGHT == nil then SETTINGS.LEGACY_DECO_HEIGHT = DEFAULT_SETTINGS.LEGACY_DECO_HEIGHT end
            if SETTINGS.LEGACY_DECO_GAP_X == nil then SETTINGS.LEGACY_DECO_GAP_X = DEFAULT_SETTINGS.LEGACY_DECO_GAP_X end
            if SETTINGS.LEGACY_DECO_OFFSET_Y == nil then SETTINGS.LEGACY_DECO_OFFSET_Y = DEFAULT_SETTINGS.LEGACY_DECO_OFFSET_Y end
            if SETTINGS.LEGACY_DECO_FOREGROUND == nil then SETTINGS.LEGACY_DECO_FOREGROUND = DEFAULT_SETTINGS.LEGACY_DECO_FOREGROUND end
            if SETTINGS.LEGACY_DECO_MIRROR == nil then SETTINGS.LEGACY_DECO_MIRROR = DEFAULT_SETTINGS.LEGACY_DECO_MIRROR end

            -- Initialize theme
            ThemeManager:SetTheme(NormalizeThemeKey(SETTINGS.THEME or ThemeManager.DEFAULT_THEME))
            SETTINGS.THEME = ThemeManager:GetCurrentTheme()
            DiabloOrbs._debugTopLevelCtrl = topLevelCtrl
            if SLASH_COMMANDS ~= nil then
                SLASH_COMMANDS["/dorbsd4"] = function()
                    DiabloOrbs.DebugD4BarState()
                end
                SLASH_COMMANDS["/dorbscd"] = function()
                    local activeCat = GetActiveHotbarCategory and GetActiveHotbarCategory() or HOTBAR_CATEGORY_PRIMARY
                    local now = GetGameTimeMilliseconds()
                    d(string.format("[DiabloOrbs] activeCat=%s now=%d", tostring(activeCat), now))
                    for i = 1, BACKBAR_SLOT_COUNT do
                        local ref = backbarSlotRefs[i]
                        if ref then
                            local s, dur, enabled = GetSlotCooldownInfo(ref.slotIndex, activeCat)
                            local isReady = (not enabled) or (dur == 0) or (now >= s + dur)
                            d(string.format("  slot[%d] idx=%d start=%d dur=%d enabled=%s ready=%s",
                                i, ref.slotIndex, s or 0, dur or 0, tostring(enabled), tostring(isReady)))
                        end
                    end
                end
                SLASH_COMMANDS["/dorbsab2"] = function()
                    -- Explorer l'arbre de ZO_ActionBar2 pour identifier les contrôles enfants
                    local function DumpControl(ctrl, depth)
                        if ctrl == nil then return end
                        local indent = string.rep("  ", depth)
                        local name = ctrl:GetName() or "(no name)"
                        local ctype = ctrl:GetType() or "?"
                        local hidden = ctrl:IsHidden()
                        local alpha = ctrl:GetAlpha()
                        d(string.format("%s[%s] type=%d hidden=%s alpha=%.2f", indent, name, ctype, tostring(hidden), alpha))
                        if depth < 3 and ctrl.GetNumChildren then
                            local count = ctrl:GetNumChildren() or 0
                            for i = 1, count do
                                local child = ctrl:GetChild(i)
                                if child then DumpControl(child, depth + 1) end
                            end
                        end
                    end
                    -- Lister tous les slots backup disponibles
                    d("[DiabloOrbs] === Slots BACKUP ===")
                    for slotIdx = 1, 12 do
                        local btn = ZO_ActionBar_GetButton and ZO_ActionBar_GetButton(slotIdx, HOTBAR_CATEGORY_BACKUP)
                        if btn and btn.slot then
                            local slotName = btn.slot:GetName() or "?"
                            d(string.format("  slotIdx=%d name=%s hidden=%s", slotIdx, slotName, tostring(btn.slot:IsHidden())))
                        end
                    end
                    -- Détail complet du slot ultime backup
                    d("[DiabloOrbs] === Detail slot ultime BACKUP ===")
                    local ultBtn = ZO_ActionBar_GetButton and ZO_ActionBar_GetButton(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1, HOTBAR_CATEGORY_BACKUP)
                    if ultBtn and ultBtn.slot then
                        DumpControl(ultBtn.slot, 0)
                    end
                end
            end
            RefreshTheme(topLevelCtrl)
            
            RegisterSettingsPanel(topLevelCtrl)

            -----------------
            -- POWER POOLS --
            -----------------
            local pools = {
                [POWERTYPE_HEALTH] = DiabloFramesStatusBar:New(GetControl(topLevelCtrl, 'Health'), POWERTYPE_HEALTH),
                [POWERTYPE_MAGICKA] = DiabloFramesStatusBar:New(GetControl(topLevelCtrl, 'Magicka'), POWERTYPE_MAGICKA),
                [POWERTYPE_STAMINA] = DiabloFramesStatusBar:New(GetControl(topLevelCtrl, 'Stamina'), POWERTYPE_STAMINA),
                [POWERTYPE_MOUNT_STAMINA] = DiabloFramesStatusBar:New(GetControl(topLevelCtrl, 'MountStamina'), POWERTYPE_MOUNT_STAMINA),
                [POWERTYPE_WEREWOLF] = DiabloFramesStatusBar:New(GetControl(topLevelCtrl, 'WerewolfTimer'), POWERTYPE_WEREWOLF),
            }
            pools[POWERTYPE_MAGICKA].combinedSibling = pools[POWERTYPE_STAMINA]
            pools[POWERTYPE_STAMINA].combinedSibling = pools[POWERTYPE_MAGICKA]
            local lastUltimatePowerValue = nil
            local lastUltimatePowerMax = nil
            EVENT_MANAGER:RegisterForEvent(NAME, EVENT_POWER_UPDATE, function(_, _, _, powerType, powerValue, powerMax)
                local pool = pools[powerType]
                if pool ~= nil then
                    ZO_StatusBar_SmoothTransition(pool, powerValue, powerMax)
                end
                if powerType == POWERTYPE_ULTIMATE then
                    if lastUltimatePowerValue == powerValue and lastUltimatePowerMax == powerMax then
                        return
                    end
                    lastUltimatePowerValue = powerValue
                    lastUltimatePowerMax = powerMax
                    updateUltimate(topLevelCtrl)
                end
            end)
            EVENT_MANAGER:AddFilterForEvent(NAME, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")

            -----------------
            -- SHIELD --
            -----------------
            local shield = DiabloFramesStatusBar:New(GetControl(topLevelCtrl, 'Shield'), ATTRIBUTE_VISUAL_POWER_SHIELDING)

            EVENT_MANAGER:RegisterForEvent(NAME, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, function(_, _, unitAttributeVisual, _, _, _, value)
                if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
                    shield.label:GetParent():SetHidden(NormalizeLabelFormat(GetThemeSetting("LABEL_FORMAT")) == "hidden")
                    ZO_StatusBar_SmoothTransition(shield, value, pools[POWERTYPE_HEALTH]:GetMax())
                end
            end)
            EVENT_MANAGER:AddFilterForEvent(NAME, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, "player")

            EVENT_MANAGER:RegisterForEvent(NAME, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, function(_, _, unitAttributeVisual, _, _, _, _, newValue)
                if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
                    ZO_StatusBar_SmoothTransition(shield, newValue, pools[POWERTYPE_HEALTH]:GetMax())
                end
            end)
            EVENT_MANAGER:AddFilterForEvent(NAME, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG, "player")

            EVENT_MANAGER:RegisterForEvent(NAME, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, function(_, _, unitAttributeVisual)
                if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
                    ZO_StatusBar_SmoothTransition(shield, 0, pools[POWERTYPE_HEALTH]:GetMax())
                    shield.label:GetParent():SetHidden(true)
                end
            end)
            EVENT_MANAGER:AddFilterForEvent(NAME, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, "player")

            -----------------
            -- MOUNT STATE --
            -----------------
            EVENT_MANAGER:RegisterForEvent(NAME, EVENT_MOUNTED_STATE_CHANGED, function(_, state)
                pools[POWERTYPE_MOUNT_STAMINA].control:SetHidden(not state)
            end)

            -----------------
            -- WW STATE --
            -----------------
            EVENT_MANAGER:RegisterForEvent(NAME, EVENT_WEREWOLF_STATE_CHANGED, function(_, state)
                pools[POWERTYPE_WEREWOLF].control:SetHidden(not state)
            end)

            -----------------
            -- INIT BARS --
            -----------------
            for _, bar in pairs(pools) do
                allBars[#allBars + 1] = bar
            end
            allBars[#allBars + 1] = shield

            -----------------
            -- ULTIMATE --
            -----------------
            local function RefreshActionSkillVisuals()
                local actionBarContainer = GetControl(topLevelCtrl, "ActionBarContainer")
                ApplyActionBarVisualOptions(actionBarContainer)
                ApplyD4SpellSlotBorders()
            end

            if EVENT_ACTION_SLOTS_FULL_UPDATE ~= nil then
                EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ACTION_SLOTS_FULL_UPDATE, function()
                    local _, powerMax = GetUnitPower("player", POWERTYPE_ULTIMATE)
                    RefreshCachedUltimateCost(powerMax)
                    updateUltimate(topLevelCtrl)
                    RefreshActionSkillVisuals()
                end)
            end
            if EVENT_ACTIVE_WEAPON_PAIR_CHANGED ~= nil then
                -- Named functions pour éviter la création de closures anonymes à chaque swap (GC pressure)
                local weaponSwapPending = false
                -- Supprime les slots natifs de la barre inactive en mode D4.
                -- ESO les force visibles après chaque swap (animations cooldown) : on pulse
                -- un timer rapide pendant 1s post-swap pour écraser chaque tentative ESO,
                -- puis on arrête. Coût = 10 ticks × 100ms uniquement lors d'un swap.
                local function OnWeaponSwapDelayed()
                    weaponSwapPending = false
                    RefreshTheme(topLevelCtrl)
                end
                EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function()
                    local _, powerMax = GetUnitPower("player", POWERTYPE_ULTIMATE)
                    RefreshCachedUltimateCost(powerMax)
                    updateUltimate(topLevelCtrl)
                    -- Throttle RefreshTheme: ESO peut envoyer l'event deux fois rapidement,
                    -- on ne déclenche le refresh complet qu'une seule fois par swap.
                    if not weaponSwapPending then
                        weaponSwapPending = true
                        zo_callLater(OnWeaponSwapDelayed, 50)
                    end
                end)
            end
            if EVENT_ACTION_SLOT_UPDATED ~= nil then
                EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ACTION_SLOT_UPDATED, function()
                    RefreshActionSkillVisuals()
                    -- ESO peut ré-ancrer le buttonText du quickslot après cet event
                    -- (ex: activation d'une potion longue durée met à jour l'icône et écrase notre anchor)
                    zo_callLater(RefreshActionSkillVisuals, 150)
                    -- Les icônes de la backbar peuvent changer si on réassigne des skills
                    zo_callLater(RefreshBackbarIcons, 100)
                    zo_callLater(RefreshLegacyBackbarIcons, 100)
                end)
            end

            if EVENT_ACTIVE_QUICKSLOT_CHANGED ~= nil then
                EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ACTIVE_QUICKSLOT_CHANGED, function()
                    zo_callLater(RefreshActionSkillVisuals, 150)
                end)
            end

            if EVENT_PLAYER_COMBAT_STATE ~= nil then
                EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
                    RefreshActionSkillVisuals()
                end)
            end

            -----------------
            -- FRAGMENT --
            -----------------
            local fragment = ZO_HUDFadeSceneFragment:New(topLevelCtrl)
            HUD_SCENE:AddFragment(fragment)
            HUD_UI_SCENE:AddFragment(fragment)
            
            -- Aperçu automatique : affiche l'interface dès que le panneau LAM est ouvert,
            -- la masque à nouveau quand on quitte les menus.
            topLevelCtrl.ForceVisibleInMenus = false

            -- Override fragment's SetHidden to respect live preview flag
            local originalFragmentSetHidden = fragment.SetHidden
            function fragment:SetHidden(hidden)
                if topLevelCtrl.ForceVisibleInMenus then
                    return
                end
                originalFragmentSetHidden(self, hidden)
            end

            local function SetLivePreview(active)
                if not IsActionBarModuleEnabled() then active = false end
                topLevelCtrl.ForceVisibleInMenus = active
                if active then
                    topLevelCtrl:SetHidden(false)
                    fragment:SetHidden(false)
                    if not topLevelCtrl.livePreviewLoopActive then
                        topLevelCtrl.livePreviewLoopActive = true
                        EVENT_MANAGER:RegisterForUpdate(NAME .. "LivePreview", 250, function()
                            if not topLevelCtrl.ForceVisibleInMenus then
                                EVENT_MANAGER:UnregisterForUpdate(NAME .. "LivePreview")
                                topLevelCtrl.livePreviewLoopActive = false
                                return
                            end
                            topLevelCtrl:SetHidden(false)
                            if ZO_ActionBar1 then ZO_ActionBar1:SetHidden(false) end
                        end)
                    end
                end
            end

            topLevelCtrl.UpdateLivePreviewVisibility = function() SetLivePreview(topLevelCtrl.ForceVisibleInMenus) end

            -- Active le preview quand le panneau DiabloOrbs est affiché dans LAM,
            -- désactive quand on quitte les options.
            CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
                if panel and panel.data and panel.data.name == "DiabloOrbs" then
                    SetLivePreview(true)
                end
            end)
            CALLBACK_MANAGER:RegisterCallback("LAM-BeforePanelControlsCreated", function(panel)
                if panel and panel.data and panel.data.name == "DiabloOrbs" then
                    SetLivePreview(true)
                end
            end)
            CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
                SetLivePreview(false)
            end)
            
            local function UpdateDeathFragment()
                fragment:SetHiddenForReason("Dead", IsUnitDead("player"))
            end
            PLAYER_ATTRIBUTE_BARS_FRAGMENT:SetHiddenForReason('DiabloFrames', true)
            EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_DEAD, UpdateDeathFragment)
            EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_ALIVE, UpdateDeathFragment)

            -----------------
            -- PLAYER_ACTIVATED --
            -----------------
            EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, function()
                UpdateDeathFragment()

                for powerType in pairs(pools) do
                    local powerValue, powerMax = GetUnitPower("player", powerType)
                    ZO_StatusBar_SmoothTransition(pools[powerType], powerValue, powerMax)
                end

                do
                    local _, powerMax = GetUnitPower("player", POWERTYPE_ULTIMATE)
                    RefreshCachedUltimateCost(powerMax)
                end

                shield:SetMinMax(0, pools[POWERTYPE_HEALTH]:GetMax())
                shield:SetValue(0)
                shield:ApplyAttributeLabel()

                for _, bar in ipairs(allBars) do
                    bar:ApplySmokeAlpha()
                    bar:ApplyAttributeLabel()
                end

                updateUltimate(topLevelCtrl)
                GetControl(topLevelCtrl, 'Line'):SetHidden(not GetThemeSetting("SHOW_ULTIMATE_BAR"))

                pools[POWERTYPE_MOUNT_STAMINA].control:SetHidden(not IsMounted())

                -- Re-apply action hotkey anchors after initial UI boot because
                -- ESO can re-anchor keybind labels shortly after PLAYER_ACTIVATED.
                RefreshActionSkillVisuals()
                zo_callLater(function()
                    RefreshActionSkillVisuals()
                end, 300)
                -- Legacy backbar : re-appliquer après activation car ESO peut réinitialiser
                -- les contrôles d'action après PLAYER_ACTIVATED.
                ApplyLegacyBackbarLayout(topLevelCtrl)
                zo_callLater(function()
                    ApplyLegacyBackbarLayout(topLevelCtrl)
                end, 500)
            end)

            -----------------
            -- APPLY STYLE --
            -----------------
            styleManager = ZO_PlatformStyle:New(function(style)
                ApplyThemeTextureRedirects()
                if AltAB_ActionBar ~= nil then
                    RestyleActionBar(topLevelCtrl, style, AltAB_ActionBar)
                else
                    RestyleActionBar(topLevelCtrl, style)
                end
                if ThemeManager:GetCurrentTheme() == "legacy" then
                    ApplyThemeTexturesToControls(topLevelCtrl)
                end
                ApplyLegacyBackbarLayout(topLevelCtrl)
            end, KEYBOARD_CONSTANTS, GAMEPAD_CONSTANTS)

            styleManager:Apply()
            ApplyThemeTexturesToControls(topLevelCtrl)
            EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ACTIVE_COMPANION_STATE_CHANGED, function() styleManager:Apply() end)


            EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
        end
    end

    EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end


