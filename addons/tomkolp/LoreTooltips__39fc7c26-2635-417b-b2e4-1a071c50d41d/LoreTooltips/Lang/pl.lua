-- ============================================
-- Polish Localization
-- ============================================
LoreTooltips = LoreTooltips or {}
LoreTooltips.Localization = LoreTooltips.Localization or {}

LoreTooltips.Localization["pl"] = {

	-- Nowe komunikaty systemowe (Bazy Danych)
    DB_CRITICAL_ERROR   = "BŁĄD KRYTYCZNY",
    DB_CONFLICT_HEADER  = "Konflikt baz danych!",
    DB_CONFLICT_DESC    = "Wykryto wiele bibliotek naraz: |cFFD700<<1>>|r",
    DB_CONFLICT_ACTION  = "Proszę wyłącz jedną z nich i przeładuj UI.",    
    DB_WARNING_HEADER   = "OSTRZEŻENIE",
    DB_MISSING_HEADER   = "Brak bazy danych.",
    DB_MISSING_DESC     = "Zainstaluj: |cE6D48F LibLoreLibraryCesarska|r (PL) lub |cE6D48F LibLoreLibraryUESP|r (EN).",    
    DB_SUCCESS_LOADED   = "Załadowano bazę: |cFFD700<<1>>|r (<<2>> wpisów).",
	
    -- Interfejs (istniejące)
    BACK_BUTTON = "<< Wróć",
    SHOW_REFS_BUTTON = "Pokaż odnośniki",
    SELECT_TOPIC_DROPDOWN = "Wybierz temat z tekstu",
    CLOSE_BUTTON = "Zamknij",
    COPY_LINK_BUTTON = "Kopiuj link",
    COPY_LINK_POPUP_TITLE = "Naciśnij (Ctrl+C) żeby skopiować link",
    POPUP_CLOSE = "Zamknij",
    SOURCE_LABEL = "Źródło",
    UNKNOWN_SOURCE = "Nieznany",
    LORE_BUTTON_TEXT = "LORE",
    LIBRARY_MENU_ENTRY = "Biblioteka LoreTooltips",
    GAMEPAD_DIALOG_TITLE = "Dostępne odnośniki",
    
    -- Keybinds (istniejące)
    KEYBIND_NEXT_TOPIC = "Następny temat",
    KEYBIND_PREV_OPTION = "Poprzednia Opcja",
    KEYBIND_NEXT_OPTION = "Następna Opcja",
    KEYBIND_SELECT = "Wybierz",
    KEYBIND_SHOW_LORE = "Pokaż Lore",
    DIALOG_SELECT_OPTION = "Wybierz",
    DIALOG_CANCEL = "Anuluj",

    -- --- MENU SETTINGS (NOWE) ---
    MENU_HEADER = "Ustawienia LoreTooltips",
    MENU_COLORS_HEADER = "Kolory Podświetlania",
    MENU_COLOR_DIALOG = "Kolor w Dialogach",
    MENU_COLOR_DIALOG_DESC = "Wybierz kolor, jakim podświetlane są słowa kluczowe w oknach dialogowych NPC.",
    MENU_COLOR_BOOK = "Kolor w Książkach",
    MENU_COLOR_BOOK_DESC = "Wybierz kolor podświetlenia w czytanych książkach (Lore Library).",
    MENU_COLOR_JOURNAL = "Kolor w Dzienniku",
    MENU_COLOR_JOURNAL_DESC = "Wybierz kolor podświetlenia w treści zadań w dzienniku.",
    MENU_OPTIONS_HEADER = "Opcje Ogólne",
    MENU_FORCE_POLISH = "Wymuś Język Polski",
    MENU_FORCE_POLISH_DESC = "Jeśli grasz na angielskim kliencie (EN), włącz to, aby opisy LoreTooltips wyświetlały się po polsku.",
    MENU_DEBUG = "Tryb Debugowania",
    MENU_DEBUG_DESC = "Wyświetla dodatkowe komunikaty na czacie (dla twórców).",
	MENU_RESET_COLOR_BUTTON = "Resetowanie koloru",
	MENU_RESET_COLOR_BUTTON = "Przywróć domyślny"
}