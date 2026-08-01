-- TraitTimer English Localization (default)

-- Craft type names
ZO_CreateStringId("TT_CRAFT_BLACKSMITHING", "Blacksmithing")
ZO_CreateStringId("TT_CRAFT_CLOTHIER", "Clothier")
ZO_CreateStringId("TT_CRAFT_WOODWORKING", "Woodworking")
ZO_CreateStringId("TT_CRAFT_JEWELRY", "Jewelry")

-- Status labels
ZO_CreateStringId("TT_STATUS_DONE", "DONE!")
ZO_CreateStringId("TT_STATUS_NO_RESEARCH", "No active research")
ZO_CreateStringId("TT_STATUS_SLOTS_USED", "<<1>>/<<2>> slots")

-- Alerts
ZO_CreateStringId("TT_ALERT_COMPLETE", "Research complete: <<1>> - <<2>>")
ZO_CreateStringId("TT_ALERT_CHAT", "|cFFFF00[TraitTimer]|r Research complete: <<1>> - <<2>> (<<3>>)")
ZO_CreateStringId("TT_ALERT_FREE_SLOT", "|cFFFF00[TraitTimer]|r <<1>> has a free research slot!")

-- Time format
ZO_CreateStringId("TT_TIME_DAYS", "<<1>>d <<2>>h <<3>>m")
ZO_CreateStringId("TT_TIME_HOURS", "<<1>>h <<2>>m <<3>>s")
ZO_CreateStringId("TT_TIME_MINUTES", "<<1>>m <<2>>s")

-- Minimized summary
ZO_CreateStringId("TT_SUMMARY_ACTIVE", "<<1>> active")

-- Column headers
ZO_CreateStringId("TT_COL_ITEM", "Item")
ZO_CreateStringId("TT_COL_TRAIT", "Trait")
ZO_CreateStringId("TT_COL_TIME", "Time")
ZO_CreateStringId("TT_COL_MISSING", "Missing")

-- View modes
ZO_CreateStringId("TT_MODE_TIMERS", "Timers")
ZO_CreateStringId("TT_MODE_MISSING", "Missing Traits")
ZO_CreateStringId("TT_MISSING_HEADER", "<<1>>/<<2>> known")
ZO_CreateStringId("TT_MISSING_NONE", "All traits researched!")
ZO_CreateStringId("TT_MISSING_COUNT", "<<1>> missing")

-- Slash command feedback
ZO_CreateStringId("TT_CMD_LOCKED", "|cFFFF00[TraitTimer]|r Widget locked.")
ZO_CreateStringId("TT_CMD_UNLOCKED", "|cFFFF00[TraitTimer]|r Widget unlocked.")
ZO_CreateStringId("TT_CMD_SHOWN", "|cFFFF00[TraitTimer]|r Widget shown.")
ZO_CreateStringId("TT_CMD_HIDDEN", "|cFFFF00[TraitTimer]|r Widget hidden.")
ZO_CreateStringId("TT_CMD_HELP", "|cFFFF00[TraitTimer]|r Commands: /tt (toggle) | /tt lock | /tt scan | /tt missing | /tt width <n>")
ZO_CreateStringId("TT_CMD_SCAN_HEADER", "|cFFFF00[TraitTimer]|r --- Research Summary ---")
ZO_CreateStringId("TT_CMD_SCAN_LINE", "|cFFFF00[TraitTimer]|r <<1>>: <<2>> - <<3>> (<<4>>)")
ZO_CreateStringId("TT_CMD_SCAN_NONE", "|cFFFF00[TraitTimer]|r No active research.")
ZO_CreateStringId("TT_CMD_WIDTH_SET", "|cFFFF00[TraitTimer]|r Width set to <<1>>.")
ZO_CreateStringId("TT_CMD_WIDTH_RANGE", "|cFFFF00[TraitTimer]|r Width must be between <<1>> and <<2>>.")
ZO_CreateStringId("TT_CMD_WIDTH_CURRENT", "|cFFFF00[TraitTimer]|r Current width: <<1>>. Usage: /tt width 500")

-- Settings panel (LibAddonMenu)
ZO_CreateStringId("TT_SETTINGS_GENERAL", "General")
ZO_CreateStringId("TT_SETTINGS_HIDE_COMBAT", "Hide in combat")
ZO_CreateStringId("TT_SETTINGS_HIDE_COMBAT_TT", "Hide the widget when entering combat.")
ZO_CreateStringId("TT_SETTINGS_LOCK", "Lock position")
ZO_CreateStringId("TT_SETTINGS_LOCK_TT", "Prevent the widget from being dragged.")
ZO_CreateStringId("TT_SETTINGS_VIEW_MODE", "Default view")
ZO_CreateStringId("TT_SETTINGS_VIEW_MODE_TT", "View to display when logging in.")
ZO_CreateStringId("TT_SETTINGS_BG_ALPHA", "Background opacity")
ZO_CreateStringId("TT_SETTINGS_BG_ALPHA_TT", "Adjust the background transparency (0 = invisible, 100 = opaque).")
ZO_CreateStringId("TT_SETTINGS_RESET", "Reset position & size")
ZO_CreateStringId("TT_SETTINGS_RESET_TT", "Reset the widget to its default position and size.")
