-- STRING_DEFINITIONS — English localization for the addon
local strings = {
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_AVAILABLE"] = "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|c00FF00ESO Plus Available|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_UNAVAILABLE"] = "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|cFF0000No ESO Plus Subscription|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_LIBADDOMENU"] = "|cFF0000[ESO Plus]|r LibAddonMenu-2.0 not found. Please check and install it.",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_STRING_MENU"] = "|cCCECC0Date|r                |c98FB98Status|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM"] = "|cEEEE00Let's ask @Eswagrom...|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_A"] = "|c2DF5F8[@Eswagrom] whispers: Hello, free trial is available USE IT NOW|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_C"] = "|c5EB9D7[@Eswagrom]: Hey, what about the free trial?|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_B"] = "|c2DF5F8[@Eswagrom] whispers: Hello, currently no subscription -_-|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CHAT_NOTIFICATION"] = "Send notifications to chat",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CHAT_NOTIFICATION_A"] = "|c00FF00If OFF, automatic chat message won't be sent, only manual /esoplus check remains.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_FONT"] = "Font size in table",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_FONT_A"] = "|c00FF00Changes font size in status history window (from 8 to 24)|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_AVA"] = "|c00FF00available|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_UNAVA"] = "|cFF0000unavailable|r",

    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY"] = "Subscription record table",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_A"] = "|c00FF00Opens a separate window with info about your free trial.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_LOCK"] = "Lock window position",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_LOCK_A"] = "|c00FF00Prevents dragging the window around screen|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_AAA"] = "Window background transparency",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_BBB"] = "Reset window position",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CCC"] = "Update status history",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_UPDATE_WINDOW_H"] = "|c00FF00If something bugged in history window — update, maybe it helps you.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_RESET_WINDOW"] = "|cEEEE00Window position reset.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME"] = "|c00FF00EsoPlus Records|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS"] = "|cFF6347Reset Settings!!!|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS_A"] = "|cFF6347Reverts all addon settings to 'just installed'. Resets position, size, transparency, font, visibility, line count (will delete lines above recorded limit!!! initially 2000) and history.|r",
    
    -- Info submenu
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS"] = "|c00FF00About ESO Plus|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_A"] = "|c9999FF/esoplus|r |cFF6347write in chat for manual check!|r This addon saves records of receiving a free subscription, so you will always know exactly on which day it was activated or absent. By default, the history stores up to 2000 records. What does this mean in practice? Each record in the table takes up one line per day. Thus, the limit of 2000 lines covers a period of approximately 2000/365≈5.48 years. In other words, the addon will store your subscription history for almost five and a half years.",

    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AA"] = "|c00FF00APIs used by this addon|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAA"] = "|c00FF00API (Application Programming Interface)|r — it's a set of rules that allow your addon to interact with the game server. In simple terms: it's a list of allowed commands defining its capabilities. For implementation were used:",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AB"] = "|c00FF00* HasEsoPlusFreeTrialNotification()|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAB"] = "** _Returns:_ *bool* _hasFreeTrialNotification_",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AC"] = "|c00FF00* ClearEsoPlusFreeTrialNotification()|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAC"] = "This addon has no keybind function to call a custom user history table, because the addon is purely informational. You'll almost never need this table. The author deliberately didn't add such a button due to game limitations: only 100 slots are available for custom keys, so filling them with unnecessary elements is impractical.",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AD"] = "|c00FF00Automatic Check Function!!!|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAD"] = "|c9999FFAutomatic checks happen every 15 minutes regardless of addon settings, so you don't miss activation if it happens later that day. This timer is completely safe for performance. Here's why:|r |cFFFFC5Execution frequency Once every 15 minutes — extremely rare for a game engine. For comparison: ESO client itself processes tens of thousands of events per second (animation, rendering, network packets). One function every 15 minutes is a drop in the ocean. - All operations here are pure logic: reading account status via built-in API (HasEsoPlus...), working with local Lua table, and outputting to chat (d()). No heavy calculations, loops over large arrays, file or network access. Calls like ZO_SavedVars, d(), ClearEsoPlus... are optimized by ZOS devs and run in microseconds.|r |cffd700Ping|r is determined by internet quality and ESO server load. Local Lua timer doesn't send data more often than the game already does. |c1E90FFComparison with other addons.|r Many popular addons use much more frequent timers: |cADD8E6- Inventory Insight|r — checks inventory on open; |cADD8E6- Combat Metrics|r — analyzes every combat tick (dozens per second); — even standard UI updates 60+ times/sec. This |cADD8E6timer|r of 900 seconds looks like 'once in an era' against this backdrop.",

["STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME_INFORMATION"] ="|cFF6347The table is now below:|r",
["STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME_INFORMATION_A"] ="|c9999FFWhen displaying a large number of records (2000 by default), the table may open with a one-second delay, this is normal.|r |cFFFFC5Open the table:|r",

["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES"] = "Number of lines to record",
["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES_A"] = "|c00FF00How many lines will be saved in the SavedVariables file history [affects file size and recording duration, upon reaching the limit, it will be overwritten] (от 100 до 5000 number of possible lines)|r",

["STRING_ESOPLUSFREETRIALNOTIFICATION_GENERAL_INFORMATION__ALLRECORDS"] = "|ccdfff3All records|r",
["STRING_ESOPLUSFREETRIALNOTIFICATION_GENERAL_INFORMATION_ESOPLUS"] = "|ccdfff3INFORMATION|r"

}

-- Register all strings in one loop — ESOUI REQUIREMENT!
for stringId, text in pairs(strings) do
    ZO_CreateStringId(stringId, text)
end