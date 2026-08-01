-- ============================================
-- English Localization
-- ============================================
LoreTooltips = LoreTooltips or {}
LoreTooltips.Localization = LoreTooltips.Localization or {}

LoreTooltips.Localization["en"] = {

-- System Messages (Database)
    DB_CRITICAL_ERROR   = "CRITICAL ERROR",
    DB_CONFLICT_HEADER  = "Database conflict!",
    DB_CONFLICT_DESC    = "Multiple libraries detected: |cFFD700<<1>>|r",
    DB_CONFLICT_ACTION  = "Please disable one of them and Reload UI.",    
    DB_WARNING_HEADER   = "WARNING",
    DB_MISSING_HEADER   = "No database library detected.",
    DB_MISSING_DESC     = "Please install: |cE6D48F LibLoreLibraryCesarska|r (PL) or |cE6D48F LibLoreLibraryUESP|r (EN).",    
    DB_SUCCESS_LOADED   = "Database loaded: |cFFD700<<1>>|r (<<2>> entries).",

    -- Interface (existing)
    BACK_BUTTON = "<< Back",
    SHOW_REFS_BUTTON = "Show references",
    SELECT_TOPIC_DROPDOWN = "Select topic from text",
    CLOSE_BUTTON = "Close",
    COPY_LINK_BUTTON = "Copy link",
    COPY_LINK_POPUP_TITLE = "Press (Ctrl+C) to copy link",
    POPUP_CLOSE = "Close",
    SOURCE_LABEL = "Source",
    UNKNOWN_SOURCE = "Unknown",
    LORE_BUTTON_TEXT = "LORE",
    LIBRARY_MENU_ENTRY = "LoreTooltips Library",
    GAMEPAD_DIALOG_TITLE = "Available references",
    
    -- Keybinds (existing)
    KEYBIND_NEXT_TOPIC = "Next topic",
    KEYBIND_PREV_OPTION = "Previous Option",
    KEYBIND_NEXT_OPTION = "Next Option",
    KEYBIND_SELECT = "Select",
    KEYBIND_SHOW_LORE = "Show Lore",
    DIALOG_SELECT_OPTION = "Select",
    DIALOG_CANCEL = "Cancel",

    -- --- MENU SETTINGS (NEW) ---
    MENU_HEADER = "LoreTooltips Settings",
    MENU_COLORS_HEADER = "Highlight Colors",
    MENU_COLOR_DIALOG = "Dialog Color",
    MENU_COLOR_DIALOG_DESC = "Choose the highlight color for keywords in NPC dialogs.",
    MENU_COLOR_BOOK = "Book Color",
    MENU_COLOR_BOOK_DESC = "Choose the highlight color for books (Lore Library).",
    MENU_COLOR_JOURNAL = "Journal Color",
    MENU_COLOR_JOURNAL_DESC = "Choose the highlight color for quest journal text.",
    MENU_OPTIONS_HEADER = "General Options",
    MENU_FORCE_POLISH = "Force Polish Language",
    MENU_FORCE_POLISH_DESC = "Forces Polish lore descriptions even if you play on the English client.",
    MENU_DEBUG = "Debug Mode",
    MENU_DEBUG_DESC = "Shows additional debug messages in chat (for developers).",
	MENU_RESET_COLOR_LABEL = "Reset color",
	MENU_RESET_COLOR_BUTTON = "Reset to default"
}