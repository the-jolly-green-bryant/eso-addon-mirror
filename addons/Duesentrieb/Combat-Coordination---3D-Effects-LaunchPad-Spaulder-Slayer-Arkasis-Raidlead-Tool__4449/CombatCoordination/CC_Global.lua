----------------------------------------------------------------------------------------------------
-- GLOBAL NAMESPACE AND DEFAULTS
----------------------------------------------------------------------------------------------------
CombatCoordination = {
    NAME = "CombatCoordination",
    AUTHOR = "@Duesentrieb",
    ADDONVERSION = 0008,
    VERSION = "20260913",
    CHAT = "|cFF7F00[CC]|r",

    ----------------------------------------------------------------------------------------------------
    -- DEFAULT VALUES
    ----------------------------------------------------------------------------------------------------
    Default = {
        enableAddon = true,
        enableDebug = false,
        isTextureVisible = false,
    },

    ---@type table|any
    SV = {},
    SVVersion = 1,
    SVName = "CombatCoordinationVariables",

    -- VOLATILES
    enablePreview = false,
    addOnLoaded = false,

    Modules = {},
    UnitNames = {},
    GroupData = {},

    ChatButton = nil,

    SIZE_ICON_LAM_PANEL = 24,
    SIZE_ICON_LAM_SM = 24,
    SIZE_ICON_LAM_TEXT = 20,
    SIZE_ICON_DISPLAYPANEL = 16,

    SIZE_ICON_LCM = 16,

    SKILL_TYPE_FIXED  = 0,
    SKILL_TYPE_RANGED = 1,
    SKILL_TYPE_TARGET = 2,

    RoleName = {
        [0] = "[Offline]",
        [1] = "[DPS]",
        [2] = "[Tank]",
        [3] = "[Unknown]",
        [4] = "[Heal]"
    },

    RoleIcon = {
        [0] = "/esoui/art/journal/journal_tabicon_cadwell_up.dds",
        [1] = "/esoui/art/lfg/lfg_icon_dps.dds",
        [2] = "/esoui/art/lfg/lfg_icon_tank.dds",
        [3] = "/esoui/art/journal/journal_tabicon_cadwell_up.dds",
        [4] = "/esoui/art/lfg/lfg_icon_healer.dds",
    },

    ITEM_SLOTS = {
        EQUIP_SLOT_HEAD, EQUIP_SLOT_SHOULDERS,
        EQUIP_SLOT_CHEST, EQUIP_SLOT_HAND, EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET,
        EQUIP_SLOT_NECK, EQUIP_SLOT_RING1, EQUIP_SLOT_RING2,
        EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND,
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

    -- TERTIARY COLORS <3 FOR GRP MEMBERS
    GroupColors = {
        [1]        = { 1.0, 0,   0,   0.75 },
        [2]        = { 1.0, 0.5, 0,   0.75 },
        [3]        = { 1.0, 1.0, 0,   0.75 },
        [4]        = { 0.5, 1.0, 0,   0.75 },
        [5]        = { 0,   1.0, 0,   0.75 },
        [6]        = { 0,   1.0, 0.5, 0.75 },
        [7]        = { 0,   1.0, 1.0, 0.75 },
        [8]        = { 0,   0.5, 1.0, 0.75 },
        [9]        = { 0,   0,   1.0, 0.75 },
        [10]       = { 0.5, 0,   1.0, 0.75 },
        [11]       = { 1.0, 0,   1.0, 0.75 },
        [12]       = { 1.0, 0,   0.5, 0.75 },
        ["player"] = { 1.0, 0.5, 0,   0.75 },
    },

    ----------------------------------------------------------------------------------------------------
    DRAW_TIER_CHOICES   = { "High (2)", "Medium (1)", "Low (0)", },
    DRAW_TIER_VALUES    = { DT_HIGH, DT_MEDIUM, DT_LOW, },
    DRAW_LAYER_CHOICES  = { "Overlay (3)", "Text (2)", "Controls (1)", "Background (0)", },
    DRAW_LAYER_VALUES   = { DL_OVERLAY, DL_TEXT, DL_CONTROLS, DL_BACKGROUND, },
    ----------------------------------------------------------------------------------------------------
    FONT_STYLE_CHOICES  = { "Bold Font", "Medium Font", "Chat Font", "Gamepad Bold Font", "Gamepad Medium Font", "Gamepad Light Font", "Antique Font", "Handwritten Font", "Stone Tablet Font"},
    FONT_STYLE_VALUES   = { "$(BOLD_FONT)", "$(MEDIUM_FONT)", "$(CHAT_FONT)", "$(GAMEPAD_BOLD_FONT)", "$(GAMEPAD_MEDIUM_FONT)", "$(GAMEPAD_LIGHT_FONT)", "$(ANTIQUE_FONT)", "$(HANDWRITTEN_FONT)", "$(STONE_TABLET_FONT)"},
    FONT_WEIGHT_CHOICES = { "Thick Outline", "Soft Shadow Thick", "Soft Shadow Thin", "None", },
    FONT_WEIGHT_VALUES  = { "thick-outline", "soft-shadow-thick", "soft-shadow-thin", "none", },
    ----------------------------------------------------------------------------------------------------
    TIMER_CHOICES       = { "Enabled: Floating", "Enabled: Ground", "Disabled", },
    TIMER_VALUES        = { 2, 1, 0, },
    ----------------------------------------------------------------------------------------------------
    CIRCLE_CHOICES = { "Circle CC", "Circle 4 Clean", "Circle 8 Clean", "Circle 16 Clean", "Circle 32 Clean", "Circle 48 Clean", "Circle 64 Clean", "Circle ESO", "Circle Red John", },
    CIRCLE_VALUES = {
        "/textures/circle_cc.dds",
        "/textures/circle_4_clean.dds",
        "/textures/circle_8_clean.dds",
        "/textures/circle_16_clean.dds",
        "/textures/circle_32_clean.dds",
        "/textures/circle_48_clean.dds",
        "/textures/circle_64_clean.dds",
        "/textures/circle_eso.dds",
        "/textures/circle_redjohn.dds",
    },
    ----------------------------------------------------------------------------------------------------
    SQUARE_CHOICES = { "Square 4 Clean", "Square 8 Clean", "Square 16 Clean", "Square 32 Clean", "Square 48 Clean", "Square 64 Clean", },
    SQUARE_VALUES = {
        "/textures/square_4_clean.dds",
        "/textures/square_8_clean.dds",
        "/textures/square_16_clean.dds",
        "/textures/square_32_clean.dds",
        "/textures/square_48_clean.dds",
        "/textures/square_64_clean.dds",
    },
    ----------------------------------------------------------------------------------------------------
    CHEVRON_CHOICES = { "Chevron 4 Clean", "Chevron 8 Clean", "Chevron 16 Clean", "Chevron 32 Clean", "Chevron 64 Clean", },
    CHEVRON_VALUES = {
        "/textures/chevron_4_clean.dds",
        "/textures/chevron_8_clean.dds",
        "/textures/chevron_16_clean.dds",
        "/textures/chevron_32_clean.dds",
        "/textures/chevron_64_clean.dds",
    },
    ----------------------------------------------------------------------------------------------------
    ARC_CHOICES = { "Arc 16 Clean", "Arc 32 Clean", "Arc 48 Clean", },
    ARC_VALUES = {
        "/textures/arc_16_clean.dds",
        "/textures/arc_32_clean.dds",
        "/textures/arc_48_clean.dds",
    },
    ----------------------------------------------------------------------------------------------------
    LETTER_CHOICES = { "Letter L/R", },
    LETTER_VALUES = {
        "/textures/letter_query.dds",
    },

    DEATH_SOUNDS_CHOICES = {
        "Outfitting Mace",
        "Outfitting Light",
        "Undaunted Transact",
        "Lockpicking Unlocked",
    },
    DEATH_SOUNDS_VALUES = {
        SOUNDS.OUTFIT_WEAPON_TYPE_MACE,
        SOUNDS.OUTFIT_ARMOR_TYPE_LIGHT,
        SOUNDS.UNDAUNTED_KEY_TRANSACT,
        SOUNDS.LOCKPICKING_UNLOCKED,
    },

    NOTIFICATION_SOUNDS_CHOICES = {
        "Ability Ultimate Ready",
        "Justice State Changed",
        "Fanfare Sparks",
        "New Notification",
        "BG Flag Returned",
        "Level Up Reward Claim",
        "Item Apply Enchant",
        "Console Game Enter",
        "Raid Trial Failed",
        "Champion Points Committed",
        "BG Flag Captured",
        "Quest Complete",
    },

    NOTIFICATION_SOUNDS_VALUES = {
        SOUNDS.ABILITY_ULTIMATE_READY,
        SOUNDS.JUSTICE_STATE_CHANGED,
        SOUNDS.GIFT_INVENTORY_VIEW_FANFARE_SPARKS,
        SOUNDS.NEW_NOTIFICATION,
        SOUNDS.BATTLEGROUND_CAPTURE_FLAG_RETURNED,
        SOUNDS.LEVEL_UP_REWARD_CLAIM_APPEAR,
        SOUNDS.INVENTORY_ITEM_APPLY_ENCHANT,
        SOUNDS.CONSOLE_GAME_ENTER,
        SOUNDS.RAID_TRIAL_FAILED,
        SOUNDS.CHAMPION_POINTS_COMMITTED,
        SOUNDS.BATTLEGROUND_CAPTURE_FLAG_CAPTURED_BY_OTHER_TEAM,
        SOUNDS.QUEST_COMPLETED,
    },

    PROC_SOUNDS_CHOICES = {
        "Collectible On Cooldown",
        "Telvar Multiplier Max",
        "Justice Pickpocket Bonus",
        "BG BallTaken Other Team",
        "Telvar Multiplier Up",
        "Ability Morph Purchased",
        "Objective Complete",
        "Telvar Gained",
        "Crown Crates Card Flipping",
        "Fanfare Sparks",
        "Crown Crates Selected",
        "Crown Crates Chosen",
        "Ability Upgrade Purchased",
        "Ability Ultimate Ready",
    },

    PROC_SOUNDS_VALUES = {
        SOUNDS.COLLECTIBLE_ON_COOLDOWN,
        SOUNDS.TELVAR_MULTIPLIERMAX,
        SOUNDS.JUSTICE_PICKPOCKET_BONUS,
        SOUNDS.BATTLEGROUND_MURDERBALL_TAKEN_OTHER_TEAM,
        SOUNDS.TELVAR_MULTIPLIERUP,
        SOUNDS.ACTIVE_SKILL_MORPH_CHOSEN,
        SOUNDS.QUEST_OBJECTIVE_COMPLETE,
        SOUNDS.TELVAR_GAINED,
        SOUNDS.CROWN_CRATES_CARD_FLIPPING,
        SOUNDS.GIFT_INVENTORY_VIEW_FANFARE_SPARKS,
        SOUNDS.CROWN_CRATES_MANIFEST_SELECTED,
        SOUNDS.CROWN_CRATES_MANIFEST_CHOSEN,
        SOUNDS.PASSIVE_SKILL_RANK_INCREASED,
        SOUNDS.ABILITY_ULTIMATE_READY,
    },
}