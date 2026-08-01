-- Lionas's Food & Drink Reminder
-- Author: Lionas
-- English specific file

-- enable/disable
ZO_CreateStringId("LIO_FADR_ENABLE", " is Enabled.")
ZO_CreateStringId("LIO_FADR_DISABLE", " is Disabled.")

-- notification
ZO_CreateStringId("LIO_FADR_NEAR_EXPIRE_HOUR_MIN", "The effect of the meal goes off after <<1>> hour(s) <<2>> min(s).")
ZO_CreateStringId("LIO_FADR_NEAR_EXPIRE_MIN", "The effect of the meal goes off after <<1>> min(s).")
ZO_CreateStringId("LIO_FADR_NEAR_EXPIRE_CLOSED", "The effect of the meal goes off soon.")
ZO_CreateStringId("LIO_FADR_NEAR_EXPIRED", "You lost effect of the meal!")

ZO_CreateStringId("LIO_FADR_SHOULD_EAT_DRINK", "There is no effect of the meal!")

-- menus
ZO_CreateStringId("LIO_FADR_DESCRIPTION", "The add-on it notify of the state of the meal.")
ZO_CreateStringId("LIO_FADR_ENABLE_TITLE", "Enable notification")
ZO_CreateStringId("LIO_FADR_ENABLE_TOOLTIP", "If you enable notifying of the state of the meal, please check out.")
ZO_CreateStringId("LIO_FADR_NOTIFY_THRESHOLD_TITLE", "Threshold of Notify[min(s)]")
ZO_CreateStringId("LIO_FADR_NOTIFY_THRESHOLD_TOOLTIP", "Notify the state of meal if it'll be below this time.")
ZO_CreateStringId("LIO_FADR_NOTIFY_IN_DUNGEON_TITLE", "Notify in dungeon")
ZO_CreateStringId("LIO_FADR_NOTIFY_IN_DUNGEON_TOOLTIP", "If you enable notifying of the state of the meal in dungeon, please check out.")
ZO_CreateStringId("LIO_FADR_ENABLE_NOTIFY_TO_CHAT_TITLE", "Notify to chat")
ZO_CreateStringId("LIO_FADR_ENABLE_NOTIFY_TO_CHAT_TOOLTIP", "If you enable notifying of the state of the meal to chat, please check out.")
ZO_CreateStringId("LIO_FADR_NOTIFY_BY_ZONE_CHANGING_TITLE", "Notify by zone changing")
ZO_CreateStringId("LIO_FADR_NOTIFY_BY_ZONE_CHANGING_TOOLTIP", "If you enable notifying of the state of the meal by zone changing, please check out.")
ZO_CreateStringId("LIO_FADR_NOTIFY_COOLDOWN_TITLE", "Notification prohibition time[sec(s)]")
ZO_CreateStringId("LIO_FADR_NOTIFY_COOLDOWN_TOOLTIP", "Notification does not occur since the last notification to this period of time has elapsed.")
ZO_CreateStringId("LIO_FADR_DEBUG_TITLE", "Enable debug output")
ZO_CreateStringId("LIO_FADR_DEBUG_TOOLTIP", "If issues are occured, please check out for report.")

ZO_CreateStringId("LIO_FADR_TOP_SETTING_HEADER", "General")
ZO_CreateStringId("LIO_FADR_ZONE_SETTING_HEADER", "Zone Change")
ZO_CreateStringId("LIO_FADR_DEBUG_SETTING_HEADER", "For debug")

ZO_CreateStringId("LIO_FADR_ENABLE_NONE_TITLE", "Notify even if buff is already expired")
ZO_CreateStringId("LIO_FADR_ENABLE_NONE_TOOLTIP", "If you want to be notified immediately when your character is active or when you moved zone or entered the dungeon after meals buff expired, please check out.")

ZO_CreateStringId("LIO_FADR_ENABLE_NOTIFY_ICON_TITLE", "Enable icon notification")
ZO_CreateStringId("LIO_FADR_ENABLE_NOTIFY_ICON_TOOLTIP", "If you enable notifying with icon, please check it.")

ZO_CreateStringId("LIO_FADR_ENABLE_ACCOUNTWIDE_TITLE", "Enable account-wide settings")
ZO_CreateStringId("LIO_FADR_ENABLE_ACCOUNTWIDE_TOOLTIP", "If you enable to use account-wide settings, please check it.")
ZO_CreateStringId("LIO_FADR_UI_WARN", "Changing this option will trigger a reload of the user interface.")

-- keybinds
ZO_CreateStringId("SI_BINDING_NAME_LIO_FADR_ACTIVATE", "Enable/Disable Notify")
