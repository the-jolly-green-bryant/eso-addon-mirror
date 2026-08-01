-- KayzarUI English Localization (default)
-- Uses ZO_CreateStringId for proper ESO localization support.

local strings = {
    KAYZARUI_ADDON_LOADED           = "loaded. All changes apply instantly. /kayzar for settings.",
    KAYZARUI_FRAMES_LOCKED          = "Frames locked.",
    KAYZARUI_FRAMES_UNLOCKED        = "Frames unlocked.",
    KAYZARUI_PANEL_NAME             = "KayzarUI",
    KAYZARUI_OPT_STYLE_PRESET       = "Style Preset",
    KAYZARUI_OPT_LOCK_FRAMES        = "Lock Frames",
    KAYZARUI_OPT_WELCOME            = "Welcome Message",
    KAYZARUI_OPT_ACCENT_COLOR       = "Accent",
    KAYZARUI_OPT_HEALTH_COLOR       = "Health",
    KAYZARUI_OPT_MAGICKA_COLOR      = "Magicka",
    KAYZARUI_OPT_STAMINA_COLOR      = "Stamina",
    KAYZARUI_OPT_ULTIMATE_COLOR     = "Ultimate",
    KAYZARUI_OPT_FRAME_BG_COLOR     = "Background",
    KAYZARUI_OPT_FRAME_BORDER_COLOR = "Border",
    KAYZARUI_OPT_ENABLED            = "Enabled",
    KAYZARUI_OPT_PLAYER_FRAME       = "Player Frame",
    KAYZARUI_OPT_TARGET_FRAME       = "Target Frame",
    KAYZARUI_OPT_BAR_WIDTH          = "Global Bar Width",
    KAYZARUI_OPT_SHOW_COOLDOWN      = "Cooldown Text",
    KAYZARUI_OPT_SHOW_ULT_COST      = "Ultimate Cost",
    KAYZARUI_LABEL_DEAD             = "DEAD",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
