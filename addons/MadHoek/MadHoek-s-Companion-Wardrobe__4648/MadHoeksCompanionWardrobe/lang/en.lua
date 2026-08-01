-- STRINGS - ENGLISH:
-- lang/en.lua

-- ==================================================
-- Panel / LAM Settings
-- ==================================================
ZO_CreateStringId("MHCWL_PANEL", "|cA02EF7MadHoek's Companion Wardrobe|r")
ZO_CreateStringId("MHCWL_PANEL_MAIN_HEADER", "General")

ZO_CreateStringId("MHCWL_WINDOW_OPEN_WITH", "Open with companion menu")
ZO_CreateStringId("MHCWL_WINDOW_OPEN_WITH_TOOLTIP", "Open the Companion Wardrobe main window with the companion menu.")
ZO_CreateStringId("MHCWL_MENU_BUTTON_OPEN_WITH", "Show companion menu button")
ZO_CreateStringId("MHCWL_MENU_BUTTON_OPEN_WITH_TOOLTIP", "Shows the Companion Wardrobe toggle button inside the companion menu.")

ZO_CreateStringId("MHCWL_SETTINGS_RESET_COMPANION_BUTTON_POSITION", "Reset")
ZO_CreateStringId("MHCWL_SETTINGS_RESET_COMPANION_BUTTON_POSITION_TOOLTIP", "Reset the Companion Wardrobe menu button to its default position.")
ZO_CreateStringId("MHCWL_NOTIFY_COMPANION_BUTTON_POSITION_RESET", "Companion menu button position reset.")

ZO_CreateStringId("MHCWL_SETTINGS_TOOLTIP_MODE", "Tooltip mode")
ZO_CreateStringId("MHCWL_SETTINGS_TOOLTIP_MODE_TOOLTIP", "Controls how much tooltip help the addon shows.")
ZO_CreateStringId("MHCWL_SETTINGS_TOOLTIP_MODE_OFF", "Off")
ZO_CreateStringId("MHCWL_SETTINGS_TOOLTIP_MODE_SIMPLE", "Simple")
ZO_CreateStringId("MHCWL_SETTINGS_TOOLTIP_MODE_TUTORIAL", "Tutorial")

ZO_CreateStringId("MHCWL_SETTINGS_ACTIVE_HIGHLIGHT_COLOR", "Active loadout highlight color")
ZO_CreateStringId("MHCWL_SETTINGS_ACTIVE_HIGHLIGHT_COLOR_TOOLTIP", "Sets the tint color of the active loadout selection highlight.")
ZO_CreateStringId("MHCWL_SETTINGS_ACTIVE_HIGHLIGHT_COLOR_RESET", "Reset")
ZO_CreateStringId("MHCWL_SETTINGS_ACTIVE_HIGHLIGHT_COLOR_RESET_TOOLTIP", "Reset the active loadout highlight color to its default.")
ZO_CreateStringId("MHCWL_NOTIFY_ACTIVE_HIGHLIGHT_COLOR_RESET", "Active highlight color reset.")

ZO_CreateStringId("MHCWL_ADVANCED_HEADER", "Advanced")
ZO_CreateStringId("MHCWL_ADVANCED_HEADER_TOOLTIP", "Advanced options")

ZO_CreateStringId("MHCWL_SETTINGS_SILHOUETTE_MODE", "Companion silhouette mode")
ZO_CreateStringId("MHCWL_SETTINGS_SILHOUETTE_MODE_TOOLTIP", "Select how Companion Wardrobe chooses the silhouette in the inspect window.")
ZO_CreateStringId("MHCWL_SETTINGS_SILHOUETTE_MODE_AUTO", "Auto by race and gender")
ZO_CreateStringId("MHCWL_SETTINGS_SILHOUETTE_MODE_COMPANION_ID", "By known companion")

-- ==================================================
-- Debug Settings
-- ==================================================
ZO_CreateStringId("MHCWL_DEBUG_HEADER", "Debug")
ZO_CreateStringId("MHCWL_DEBUG_HEADER_TOOLTIP", "Debug options")

ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_MODE", "Enable debug mode")
ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_MODE_TOOLTIP", "Enables developer slash commands and debug messages in chat.")

ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_MESSAGES", "Enable debug messages")
ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_MESSAGES_TOOLTIP", "Shows automatic debug messages in chat.")

ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_FORCE_LOCKED", "Force locked companion skills")
ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_FORCE_LOCKED_TOOLTIP", "Debug only. Treat companion skills as locked to test warnings.")

ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_SLOT7_ULTIMATE", "Show skill slot 7 in ultimate")
ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_SLOT7_ULTIMATE_TOOLTIP", "Debug only. Displays companion skill slot 7 in the ultimate slot for inspect view testing.")

ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_TIMINGS", "Timing safety buffer")
ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_TIMINGS_TOOLTIP", "Adds extra milliseconds to queued addon actions. Increase this if gear loading or autofetch is unreliable.")

-- ==================================================
-- Color Settings / Profiles
-- ==================================================
ZO_CreateStringId("MHCWL_COLORS_HEADER", "Colors")
ZO_CreateStringId("MHCWL_COLORS_HEADER_TOOLTIP", "Color settings")

ZO_CreateStringId("MHCWL_SETTINGS_LOADOUT_COLOR_HEADER", "Loadout Colors")
ZO_CreateStringId("MHCWL_SETTINGS_LOADOUT_COLOR_HEADER_TOOLTIP", "Color and visual loadout settings")

ZO_CreateStringId("MHCWL_COLOR_PROFILE", "Color Profile")
ZO_CreateStringId("MHCWL_COLOR_PROFILE_STANDARD", "Standard")
ZO_CreateStringId("MHCWL_COLOR_PROFILE_ROLE", "Roles")
ZO_CreateStringId("MHCWL_COLOR_PROFILE_CUSTOM", "Custom")

ZO_CreateStringId("MHCWL_COLOR_PROFILE_TOOLTIP", "Choose the loadout color preset. Standard and Roles reset their preset colors when changed. Custom keeps your own color names and colors.")

ZO_CreateStringId("MHCWL_COLOR_SLOT_ENABLED", "Enable")
ZO_CreateStringId("MHCWL_COLOR_SLOT_NAME", "Name")
ZO_CreateStringId("MHCWL_COLOR_SLOT_COLOR", "Color")

ZO_CreateStringId("MHCWL_COLOR_USE_FOR_FAVORITES", "Use color for favorites")

ZO_CreateStringId("MHCWL_COLOR_DEFAULT", "Default")
ZO_CreateStringId("MHCWL_COLOR_RED", "Red")
ZO_CreateStringId("MHCWL_COLOR_ORANGE", "Orange")
ZO_CreateStringId("MHCWL_COLOR_YELLOW", "Yellow")
ZO_CreateStringId("MHCWL_COLOR_GREEN", "Green")
ZO_CreateStringId("MHCWL_COLOR_BLUE", "Blue")
ZO_CreateStringId("MHCWL_COLOR_PURPLE", "Purple")
ZO_CreateStringId("MHCWL_COLOR_CUSTOM", "Custom")
ZO_CreateStringId("MHCWL_COLOR_COLOR", "Color")

ZO_CreateStringId("MHCWL_COLOR_ROLE_TANK", "Tank")
ZO_CreateStringId("MHCWL_COLOR_ROLE_HEALER", "Healer")
ZO_CreateStringId("MHCWL_COLOR_ROLE_DPS", "DPS")
ZO_CreateStringId("MHCWL_COLOR_ROLE_SUPPORT", "Support")

-- ==================================================
-- Generic UI / Windows
-- ==================================================
ZO_CreateStringId("MHCWL_WINDOW_MAIN_TITLE", "Companion Wardrobe")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_TITLE", "Options")
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_TITLE", "Inspect Loadout")
ZO_CreateStringId("MHCWL_WINDOW_RENAME_TITLE", "Rename Loadout")
ZO_CreateStringId("MHCWL_WINDOW_EXPORT_TITLE", "Export Loadout")
ZO_CreateStringId("MHCWL_WINDOW_IMPORT_TITLE", "Import Loadout")

ZO_CreateStringId("MHCWL_LOADOUT", "Loadout ")
ZO_CreateStringId("MHCWL_RENAME_TEXT", "Enter a new name:")
ZO_CreateStringId("MHCWL_EMPTY_MARKER", " |c888888(empty)|r")
ZO_CreateStringId("MHCWL_UNKNOWN", "Unknown")

ZO_CreateStringId("MHCWL_PAGE_LABEL", "Page <<1>>/<<2>>")

-- ==================================================
-- Main Window Actions
-- ==================================================
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_SAVE_GEAR", "Save Gear")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_SAVE_SKILLS", "Save Skills")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_LOAD_GEAR", "Load Gear")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_LOAD_SKILLS", "Load Skills")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT", "Import")

-- ==================================================
-- Buttons / Basic Tooltips
-- ==================================================
ZO_CreateStringId("MHCWL_BUTTON_LOCK", "Lock")
ZO_CreateStringId("MHCWL_BUTTON_UNLOCK", "Unlock")
ZO_CreateStringId("MHCWL_BUTTON_FAVORITE", "Favorite")
ZO_CreateStringId("MHCWL_BUTTON_UNFAVORITE", "Unfavorite")

ZO_CreateStringId("MHCWL_TOOLTIP_CLOSE", "Close")
ZO_CreateStringId("MHCWL_TOOLTIP_SETTINGS", "Settings")
ZO_CreateStringId("MHCWL_TOOLTIP_ACTIVE", "Active")
ZO_CreateStringId("MHCWL_TOOLTIP_SELECT", "Select")
ZO_CreateStringId("MHCWL_TOOLTIP_SAVE", "Save")
ZO_CreateStringId("MHCWL_TOOLTIP_RENAME", "Rename")
ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT", "Inspect")
ZO_CreateStringId("MHCWL_TOOLTIP_DELETE", "Delete")
ZO_CreateStringId("MHCWL_TOOLTIP_ADD", "Add")
ZO_CreateStringId("MHCWL_TOOLTIP_PAGE_PREVIOUS", "Previous")
ZO_CreateStringId("MHCWL_TOOLTIP_PAGE_NEXT", "Next")

ZO_CreateStringId("MHCWL_TOOLTIP_EMPTY_GEAR", "Empty")
ZO_CreateStringId("MHCWL_TOOLTIP_EMPTY_SKILL", "Empty")
ZO_CreateStringId("MHCWL_TOOLTIP_LOCKED_LEVEL", "Locked\nUnlocks at Companion Level <<1>>")

ZO_CreateStringId("MHCWL_TOOLTIP_HIDE_NORMAL_LOADOUTS", "Hide normal")
ZO_CreateStringId("MHCWL_TOOLTIP_SHOW_NORMAL_LOADOUTS", "Show normal")
ZO_CreateStringId("MHCWL_TOOLTIP_HIDE_FAVORITE_LOADOUTS", "Hide favorites")
ZO_CreateStringId("MHCWL_TOOLTIP_SHOW_FAVORITE_LOADOUTS", "Show favorites")

ZO_CreateStringId("MHCWL_TOOLTIP_QUEUE_MISSING_GEAR_FETCH", "Click to queue missing gear for bank fetch.")

-- ==================================================
-- Sorting
-- ==================================================
ZO_CreateStringId("MHCWL_SORTING_PREFIX", "Sorting: ")

ZO_CreateStringId("MHCWL_SORT_MODE_SLOT_ORDER", "Slot Order")
ZO_CreateStringId("MHCWL_SORT_MODE_ALL_AZ", "All A-Z")
ZO_CreateStringId("MHCWL_SORT_MODE_FAVORITES_AZ", "Favorites A-Z")
ZO_CreateStringId("MHCWL_SORT_MODE_FAVORITES_SLOT", "Favorites Slot")

-- ==================================================
-- Inspect Window
-- ==================================================
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_GEAR_HEADER", "Gear")
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_SKILLS_HEADER", "Skills")

ZO_CreateStringId("MHCWL_WINDOW_INSPECT_SKILL_SLOTNAME", "Slot ")
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_SKILL_ULTIMATE_SLOTNAME", "Ultimate")

ZO_CreateStringId("MHCWL_WINDOW_INSPECT_DROPDOWN_ACTIVE", "Load")
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_DROPDOWN_ACQUIRE_GEAR", "Acquire Gear")
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_DROPDOWN_STORE_GEAR", "Store Gear")
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_DROPDOWN_RENAME", "Rename")
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_DROPDOWN_DUPLICATE", "Duplicate")
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_DROPDOWN_EXPORT", "Export")
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_DROPDOWN_IMPORT", "Import")

ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_SWITCH_VIEW", "Switch visual/text view")
ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_ARMOR", "Armor")
ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_WEAPONS", "Jewelry & Weapons")
ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_SKILLS", "Skills")
ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_COLOR", "Change loadout name color")

ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_ACTIVE", "Load")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_ACQUIRE_GEAR", "Fetch Gear")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_STORE_GEAR", "Store Gear")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_RENAME", "Rename")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_DUPLICATE", "Duplicate")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_EXPORT", "Export")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_IMPORT", "Import")

-- ==================================================
-- Inspect Text View
-- ==================================================
ZO_CreateStringId("MHCWL_INSPECT_TEXT_EMPTY", "Empty")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_GEAR", "Gear")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_LIGHT", "Light")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_MEDIUM", "Medium")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_HEAVY", "Heavy")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_NECKLACE", "Necklace")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_RING", "Ring")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_NO_TRAIT", "No Trait")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_UNKNOWN", "Unknown")

ZO_CreateStringId("MHCWL_INSPECT_TEXT_ARMOR_HEADER", "ARMOR")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_JEWELRY_HEADER", "JEWELRY")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_WEAPONS_HEADER", "WEAPONS")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_SKILLS_HEADER", "SKILLS")

ZO_CreateStringId("MHCWL_INSPECT_TEXT_BLOCKED", "Blocked - ")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_TWO_HANDED_WEAPON", "Two-Handed Weapon")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_WEAPON_DAMAGE", "<<1>> / Damage: <<2>>")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_SKILL_BASE_VALUES", "Base Values: Cast <<1>> / Tgt <<2>> / Dur <<3>> / CD <<4>>")

ZO_CreateStringId("MHCWL_INSPECT_TEXT_WEAPON", "Weapon")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_TRAIT", "Trait")

-- ==================================================
-- Import / Export Windows
-- ==================================================
ZO_CreateStringId("MHCWL_WINDOW_EXPORT_INFO", "Copy the export text below:")
ZO_CreateStringId("MHCWL_WINDOW_IMPORT_INFO", "Paste import text below:")
ZO_CreateStringId("MHCWL_WINDOW_IMPORT_INFO_OVERWRITE", "Paste import text below. Overwrites the inspected loadout.")
ZO_CreateStringId("MHCWL_WINDOW_IMPORT_INFO_CREATE", "Paste import text below. Creates a new loadout.")

ZO_CreateStringId("MHCWL_WINDOW_IMPORT_BUTTON", "Import")
ZO_CreateStringId("MHCWL_WINDOW_IMPORT_BUTTON_TOOLTIP", "Import")

ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_EXPORT_GEAR", "Gear")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_EXPORT_GEAR_TOOLTIP", "Export gear only")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_EXPORT_GEAR_TOOLTIP_TUTORIAL", "Export Gear\n\nExport only the saved companion gear from this loadout.")

ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_EXPORT_SKILLS", "Skills")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_EXPORT_SKILLS_TOOLTIP", "Export skills only")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_EXPORT_SKILLS_TOOLTIP_TUTORIAL", "Export Skills\n\nExport only the saved companion skills from this loadout.")

ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_GEAR", "Gear")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_GEAR_TOOLTIP", "Import gear only")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_GEAR_TOOLTIP_TUTORIAL", "Import Gear\n\nImport only the saved companion gear from the pasted loadout.")

ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_SKILLS", "Skills")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_SKILLS_TOOLTIP", "Import skills only")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_SKILLS_TOOLTIP_TUTORIAL", "Import Skills\n\nImport only the saved companion skills from the pasted loadout.")

ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_FAVORITE", "Favorite")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_FAVORITE_TOOLTIP", "Import as favorite")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_FAVORITE_TOOLTIP_TUTORIAL", "Import as Favorite\n\nMark the imported loadout as a favorite.")

ZO_CreateStringId("MHCWL_WINDOW_EXPORT_DIALOG_SELECT_ALL", "Select")
ZO_CreateStringId("MHCWL_WINDOW_EXPORT_DIALOG_SELECT_ALL_TOOLTIP", "Select All")
ZO_CreateStringId("MHCWL_WINDOW_EXPORT_DIALOG_SELECT_ALL_TOOLTIP_TUTORIAL", "Select All\n\nSelect the full export text so it can be copied.")

ZO_CreateStringId("MHCWL_EXPORTED_LOADOUT", "Exported Loadout")
ZO_CreateStringId("MHCWL_IMPORTED_LOADOUT", "Imported Loadout")

-- ==================================================
-- Notifications / Generic Loadout Actions
-- ==================================================
ZO_CreateStringId("MHCWL_NOTIFY_LOCKED", "Loadout is locked.")
ZO_CreateStringId("MHCWL_NOTIFY_SAVED", "Saved: ")
ZO_CreateStringId("MHCWL_NOTIFY_SAVED_GEAR", "Saved Gear only: ")
ZO_CreateStringId("MHCWL_NOTIFY_SAVED_SKILLS", "Saved Skills only: ")
ZO_CreateStringId("MHCWL_NOTIFY_DUPLICATED", "Duplicated: ")

-- ==================================================
-- Notifications / Import / Export
-- ==================================================
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_EMPTY", "Import text is empty.")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_PARSE_FAILED", "Import parse failed.")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_FORMAT_INVALID", "Invalid import format.")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_DATA_INVALID", "Import data is invalid.")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_INVALID_SCHEMA", "Unsupported import schema.")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_INVALID_VERSION", "Unsupported import version.")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_INVALID_TARGET", "Invalid import target.")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_NO_DATA_LOADOUT", "Import has no loadout data.")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_NO_ACTIVE_COMPANION", "No active companion.")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_MAX_LOADOUT_COUNT", "Maximum loadout count reached.")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_WRONG_COMPANION", "This loadout belongs to a different companion.")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_FAILED", "Import failed.")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORTED", "Imported: ")

ZO_CreateStringId("MHCWL_NOTIFY_EXPORT_SELECTED", "Export text selected. Press Ctrl+C to copy.")
ZO_CreateStringId("MHCWL_NOTIFY_EXPORT_FAILED", "Export failed.")

-- ==================================================
-- Notifications / Gear Fetch
-- ==================================================
ZO_CreateStringId("MHCWL_NOTIFY_NO_MISSING_GEAR", "No missing gear.")
ZO_CreateStringId("MHCWL_NOTIFY_NO_FETCHABLE_GEAR", "No fetchable gear found.")
ZO_CreateStringId("MHCWL_NOTIFY_GEAR_FETCH_QUEUED", "Gear fetch queued. Open your bank.")
ZO_CreateStringId("MHCWL_NOTIFY_GEAR_FETCH_CANCELED_EMPTY", "Gear fetch canceled: queue is empty.")

ZO_CreateStringId("MHCWL_NOTIFY_GEAR_FETCH_COMPLETE_MOVED", "Gear fetch complete. Moved ")
ZO_CreateStringId("MHCWL_NOTIFY_GEAR_FETCH_MOVED", "Moved ")
ZO_CreateStringId("MHCWL_NOTIFY_GEAR_FETCH_MISSING", " Missing ")
ZO_CreateStringId("MHCWL_NOTIFY_BACKPACK_FULL_COULD_NOT_MOVE", " Backpack full - could not move ")

-- ==================================================
-- Notifications / Gear Store
-- ==================================================
ZO_CreateStringId("MHCWL_NOTIFY_BANK_NOT_OPEN", "Bank is not open.")
ZO_CreateStringId("MHCWL_NOTIFY_OPEN_BANK_TO_STORE", "Open your bank to store gear.")
ZO_CreateStringId("MHCWL_NOTIFY_BANK_FULL", "Bank is full.")
ZO_CreateStringId("MHCWL_NOTIFY_NO_STORABLE_GEAR", "No storable gear found.")
ZO_CreateStringId("MHCWL_NOTIFY_GEAR_STORE_QUEUED", "Gear store queued. Open your bank.")
ZO_CreateStringId("MHCWL_NOTIFY_GEAR_STORE_CANCELED_EMPTY", "Gear store canceled: queue is empty.")

ZO_CreateStringId("MHCWL_NOTIFY_STORED_COMPANION_GEAR", "Stored companion gear: ")
ZO_CreateStringId("MHCWL_NOTIFY_STORED_GEAR", "Stored gear: ")

ZO_CreateStringId("MHCWL_NOTIFY_GEAR_STORE_COMPLETE_MOVED", "Gear store complete. Moved ")
ZO_CreateStringId("MHCWL_NOTIFY_GEAR_STORE_MOVED", "Moved ")
ZO_CreateStringId("MHCWL_NOTIFY_BANK_FULL_COULD_NOT_MOVE", " Bank full - could not move ")

ZO_CreateStringId("MHCWL_NOTIFY_ITEM_SINGULAR", "item")
ZO_CreateStringId("MHCWL_NOTIFY_ITEM_PLURAL", "items")

-- ==================================================
-- Warnings
-- ==================================================
ZO_CreateStringId("MHCWL_WARNING_TOOLTIP_TITLE", "Loadout warnings")
ZO_CreateStringId("MHCWL_WARNING_MISSING_GEAR", "Missing gear:")
ZO_CreateStringId("MHCWL_WARNING_LOCKED_SKILL_SLOTS", "Locked skill slots:")
ZO_CreateStringId("MHCWL_WARNING_INVALID_SKILLS", "Invalid saved skills:")
ZO_CreateStringId("MHCWL_WARNING_LOCKED_SKILL_LINES", "Locked Skill Lines")

-- ==================================================
-- Tutorial Tooltips / Main Window
-- ==================================================
ZO_CreateStringId("MHCWL_TOOLTIP_SAVE_TUTORIAL", "Save Loadout")
ZO_CreateStringId("MHCWL_TOOLTIP_RENAME_TUTORIAL", "Rename Loadout")
ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_TUTORIAL", "Inspect Loadout")
ZO_CreateStringId("MHCWL_TOOLTIP_DELETE_TUTORIAL", "Delete Loadout")
ZO_CreateStringId("MHCWL_TOOLTIP_ADD_TUTORIAL", "Add Loadout")
ZO_CreateStringId("MHCWL_TOOLTIP_PAGE_PREVIOUS_TUTORIAL", "Previous Page")
ZO_CreateStringId("MHCWL_TOOLTIP_PAGE_NEXT_TUTORIAL", "Next Page")

ZO_CreateStringId("MHCWL_BUTTON_FAVORITE_TUTORIAL", "Mark as Favorite")
ZO_CreateStringId("MHCWL_BUTTON_UNFAVORITE_TUTORIAL", "Remove from Favorites")
ZO_CreateStringId("MHCWL_BUTTON_LOCK_TUTORIAL", "Lock Loadout")
ZO_CreateStringId("MHCWL_BUTTON_UNLOCK_TUTORIAL", "Unlock Loadout")

ZO_CreateStringId("MHCWL_TOOLTIP_SORT_TUTORIAL", "Sort Loadouts")
ZO_CreateStringId("MHCWL_TOOLTIP_SORT_CURRENT_MODE", "Current mode:")
ZO_CreateStringId("MHCWL_TOOLTIP_SORT_CHANGE_TUTORIAL", "Click to change sorting mode.")

ZO_CreateStringId("MHCWL_TOOLTIP_SHOW_FAVORITES_TUTORIAL", "Show Favorite Loadouts")
ZO_CreateStringId("MHCWL_TOOLTIP_HIDE_FAVORITES_TUTORIAL", "Hide Favorite Loadouts")
ZO_CreateStringId("MHCWL_TOOLTIP_FAVORITES_FILTER_TUTORIAL", "Toggle visibility of favorite loadouts.")

ZO_CreateStringId("MHCWL_TOOLTIP_SHOW_NORMAL_TUTORIAL", "Show Normal Loadouts")
ZO_CreateStringId("MHCWL_TOOLTIP_HIDE_NORMAL_TUTORIAL", "Hide Normal Loadouts")
ZO_CreateStringId("MHCWL_TOOLTIP_NORMAL_FILTER_TUTORIAL", "Toggle visibility of normal loadouts.")

ZO_CreateStringId("MHCWL_TOOLTIP_SETTINGS_TUTORIAL", "Settings\n\nOpen Loadout Options.")
ZO_CreateStringId("MHCWL_TOOLTIP_CLOSE_TUTORIAL", "Close Window\n\nHide the Companion Wardrobe window.")

-- ==================================================
-- Tutorial Tooltips / Options Dropdown
-- ==================================================
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_SAVE_GEAR_TOOLTIP", "Save Gear")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_SAVE_GEAR_TOOLTIP_TUTORIAL", "Save Gear\n\nWhen saving a loadout, include currently equipped companion gear.")

ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_SAVE_SKILLS_TOOLTIP", "Save Skills")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_SAVE_SKILLS_TOOLTIP_TUTORIAL", "Save Skills\n\nWhen saving a loadout, include currently slotted companion skills.")

ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_LOAD_GEAR_TOOLTIP", "Load Gear")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_LOAD_GEAR_TOOLTIP_TUTORIAL", "Load Gear\n\nWhen loading a loadout, equip saved companion gear.")

ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_LOAD_SKILLS_TOOLTIP", "Load Skills")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_LOAD_SKILLS_TOOLTIP_TUTORIAL", "Load Skills\n\nWhen loading a loadout, slot saved companion skills.")

ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_TOOLTIP", "Import")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_TOOLTIP_TUTORIAL", "Import Loadout\n\nOpen the import dialog to paste a shared loadout and import it as a new loadout.")

ZO_CreateStringId("MHCWL_WINDOW_IMPORT_BUTTON_TOOLTIP_TUTORIAL", "Import Loadout\n\nImport the pasted loadout into the selected slot.")

-- ==================================================
-- Tutorial Tooltips / Inspect Window
-- ==================================================
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_ACTIVE_TUTORIAL", "Load Loadout\n\nSet this loadout active and apply it to your companion.")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_ACQUIRE_GEAR_TUTORIAL", "Fetch Missing Gear\n\nQueue missing saved gear for bank fetch.")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_STORE_GEAR_TUTORIAL", "Store Gear\n\nMove this loadout's gear from your inventory into the bank.")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_RENAME_TUTORIAL", "Rename Loadout\n\nChange the name of this loadout.")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_DUPLICATE_TUTORIAL", "Duplicate Loadout\n\nCreate a copy of this loadout.")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_EXPORT_TUTORIAL", "Export Loadout\n\nOpen the export dialog for sharing or backup.")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_IMPORT_TUTORIAL", "Import Loadout\n\nOverwrite this loadout with pasted import data.")

ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_SWITCH_VIEW_TUTORIAL", "Switch View\n\nSwitch between graphical and text inspect view.")

ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_ARMOR_TUTORIAL", "Armor View\n\nShow saved armor and jewelry as text.")
ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_WEAPONS_TUTORIAL", "Weapon View\n\nShow saved weapons as text.")
ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_SKILLS_TUTORIAL", "Skills View\n\nShow saved companion skills as text.")
ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_COLOR_TUTORIAL", "Loadout Color\n\nAssign a color category to this loadout.")

-- ==================================================
-- Keybindings
-- ==================================================
ZO_CreateStringId("SI_BINDING_NAME_MHCWL_WINDOW_TOGGLE", "Toggle Companion Wardrobe")