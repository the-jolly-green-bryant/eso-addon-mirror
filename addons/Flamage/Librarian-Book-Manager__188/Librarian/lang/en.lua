local strings = {
    -- Bindings
    SI_BINDING_NAME_LIBRARIAN_TOGGLE_LIBRARIAN = "Toggle Librarian",
    SI_BINDING_NAME_LIBRARIAN_RELOAD_UI = "Reload UI",

    -- Main Window
    LIBRARIAN_WINDOW_TITLE_LIBRARIAN = "Librarian",
    LIBRARIAN_SORT_TYPE_UNREAD = "Read",
    LIBRARIAN_SORT_TYPE_FOUND = "Found",
    LIBRARIAN_SORT_TYPE_TITLE = "Title",
    LIBRARIAN_SORT_TYPE_CATEGORY = "Category",
    LIBRARIAN_SORT_TYPE_WORD_COUNT = "Words",
    LIBRARIAN_MARK_UNREAD = "Mark as Unread",
    LIBRARIAN_MARK_READ = "Mark as Read",
    LIBRARIAN_BOOK_COUNT = "%d Books",
    LIBRARIAN_UNREAD_COUNT = "%s (%d Unread)",
    LIBRARIAN_SHOW_ALL_BOOKS = "Show books for all characters",
    LIBRARIAN_NEW_BOOK_FOUND = "Book added to librarian",
    LIBRARIAN_NEW_BOOK_FOUND_WITH_TITLE = "Book added to librarian: %s",
    LIBRARIAN_FULLTEXT_SEARCH = "Full-text Search:",
    LIBRARIAN_TITLE_SEARCH = "Only title Search:",
    LIBRARIAN_SEARCH_HINT = "Enter text to search for.",
    LIBRARIAN_NO_CATEGORY = "No Category",
    LIBRARIAN_LOCKED_CATEGORY = "Locked Category",
    LIBRARIAN_GO_TO_CATEGORY = "Go to Category",
    LIBRARIAN_RELOAD_REMINDER = "ReloadUI suggested to update Librarian database.",
    LIBRARIAN_BACKUP_REMINDER = "Remember to backup your Librarian SavedVariables regularly.  Look up Librarian on ESOUI for instructions.",
    LIBRARIAN_COULD_NOT_READ = "The current character doesn't know this book, you can't read it",
    LIBRARIAN_DELETE_BOOK = "Delete Book",
    LIBRARIAN_DELETE_BOOK_PROMPT_TITLE = "Delete Book",
    LIBRARIAN_DELETE_BOOK_PROMPT_MESSAGE = "Are you sure you want to delete <<1>> ?\nTo have this book back in Librarian, you will have to find this book in the world and open it again.",

    -- Settings
    LIBRARIAN_SETTINGS_DISPLAY_NAME = "Librarian Book Manager",
    LIBRARIAN_SETTINGS_TIME = "Time Format",
    LIBRARIAN_SETTINGS_TIME_TOOLTIP = "Select a format to display times in",
    LIBRARIAN_SETTINGS_ALERT = "Alert Settings",
    LIBRARIAN_SETTINGS_ALERT_TOOLTIP = "Select a style of alert",
    LIBRARIAN_SETTINGS_RELOADUI_REMINDER = "ReloadUI reminder after",
    LIBRARIAN_SETTINGS_RELOADUI_REMINDER_TOOLTIP = "Reminder to type /reloadui after this number of new books are discovered.",
    LIBRARIAN_SETTINGS_SHOW_HIDDEN_BOOK = "Show Hidden Book",
    LIBRARIAN_SETTINGS_SHOW_HIDDEN_BOOK_TOOLTIP = "ESO has some hidden book collection and hide some book from you in the lore library. For example the full motif book containing all 14 pages are part of these hidden books. So, if you want to have your book count matching between the lore library and Librarian, you need to uncheck this",
    LIBRARIAN_SETTINGS_UNREAD_INDICATOR_READER = "Unread Indicator (Reader)",
    LIBRARIAN_SETTINGS_UNREAD_INDICATOR_READER_TOOLTIP = "Show an unread indicator next to the title of a book when reading it.",
    LIBRARIAN_SETTINGS_ICON_TRANSPARENCY = "Indicator Transparency",
    LIBRARIAN_SETTINGS_ICON_TRANSPARENCY_TOOLTIP = "How transparent do you want the unread indicator to be (100 fully visible, 0 fully transparent).",
    LIBRARIAN_SETTINGS_UNREAD_INDICATOR_LIBRARY = "Unread Indicator (Library)",
    LIBRARIAN_SETTINGS_UNREAD_INDICATOR_LIBRARY_TOOLTIP = "Show an unread indicator in the lore library menu next to the collections having an unread book and next to the book which are unread.",
    LIBRARIAN_SETTINGS_CHARACTER_SPIN = "Character Spin",
    LIBRARIAN_SETTINGS_CHARACTER_SPIN_TOOLTIP = "Allow the character to spin and face the camera when Librarian is open.",
    LIBRARIAN_SETTINGS_IMPORT = "Import from Lore Library",
    LIBRARIAN_SETTINGS_IMPORT_TOOLTIP = "Import any missing books from the Lore Library.  Works with all books once Eidetic Memory is unlocked.",
    
    LIBRARIAN_SETTINGS_TIME_12 = "12 hour",
    LIBRARIAN_SETTINGS_TIME_24 = "24 hour",
    LIBRARIAN_SETTINGS_ALERT_NONE = "None",
    LIBRARIAN_SETTINGS_ALERT_CHAT = "Chat only",
    LIBRARIAN_SETTINGS_ALERT_NOTIFICATION = "Alert only",
    LIBRARIAN_SETTINGS_ALERT_BOTH = "Both",
    LIBRARIAN_SETTINGS_RELOAD_REMNDER_NEVER = "Never",
    LIBRARIAN_SETTINGS_RELOAD_REMNDER_1 = "1 new book",
    LIBRARIAN_SETTINGS_RELOAD_REMNDER_5 = "5 new books",
    LIBRARIAN_SETTINGS_RELOAD_REMNDER_10 = "10 new books",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
