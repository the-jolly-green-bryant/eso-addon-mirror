local strings = {

    SI_ESOPLUSFREETRIALNOTIF_NOTIFICATION_AVAILABLE = "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|c00FF00ESO Plus Available|r",
    SI_ESOPLUSFREETRIALNOTIF_NOTIFICATION_UNAVAILABLE = "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|cFF0000No ESO Plus Subscription|r",
    
    SI_ESOPLUSFREETRIALNOTIF_NOTIFICATION_LIBADDOMENU = "|cFF0000[ESO Plus]|r LibAddonMenu-2.0 not found. Please check and install it.",
    
    SI_ESOPLUSFREETRIALNOTIF_STRING_MENU = "|cCCECC0Date|r                |c98FB98Status|r",
    
    SI_ESOPLUSFREETRIALNOTIF_ESWAGROM = "|cEEEE00Let's ask @Eswagrom...|r",
    
    SI_ESOPLUSFREETRIALNOTIF_ESWAGROM_A = "|c2DF5F8[@Eswagrom] whispers: Hello, free trial is available USE IT NOW|r",
    SI_ESOPLUSFREETRIALNOTIF_ESWAGROM_C = "|c5EB9D7[@Eswagrom]: Hey, what about the free trial?|r",
    SI_ESOPLUSFREETRIALNOTIF_ESWAGROM_B = "|c2DF5F8[@Eswagrom] whispers: Hello, currently no subscription -_-|r",
    
    SI_ESOPLUSFREETRIALNOTIF_CHAT_NOTIFICATION = "Send notifications to chat",
    SI_ESOPLUSFREETRIALNOTIF_CHAT_NOTIFICATION_A = "|c00FF00If OFF, automatic chat message won't be sent, only manual /esoplus check remains.|r",
    
    SI_ESOPLUSFREETRIALNOTIF_FONT = "Font size in table",
    SI_ESOPLUSFREETRIALNOTIF_FONT_A = "|c00FF00Changes font size in status history window (from 8 to 24)|r",
    
    SI_ESOPLUSFREETRIALNOTIF_AVA = "|t15:15:/esoui/art/interaction/accept.dds|t |c00FF00available|r |t15:15:/esoui/art/interaction/accept.dds|t",
    SI_ESOPLUSFREETRIALNOTIF_UNAVA = "|cFF0000X|r |cFF0000unavailable|r |cFF0000X|r",

    SI_ESOPLUSFREETRIALNOTIF_HISTORY = "Subscription record table",
    SI_ESOPLUSFREETRIALNOTIF_HISTORY_A = "|c00FF00Opens a separate window with info about your free trial.|r",
    
    SI_ESOPLUSFREETRIALNOTIF_RESET_WINDOW = "|cEEEE00Window position reset.|r",
    
    SI_ESOPLUSFREETRIALNOTIF_ADDON_NAME = "|c00FF00EsoPlus Records|r",
    
    SI_ESOPLUSFREETRIALNOTIF_DEFAULTS_SETTINGS = "|cFF6347Reset Settings!!!|r",
    SI_ESOPLUSFREETRIALNOTIF_DEFAULTS_SETTINGS_A = "|cFF6347Reverts all addon settings to 'just installed'. Resets position, size, transparency, font, visibility, line count (will delete lines above recorded limit!!! initially 2000) and history.|r",
    
    -- Info submenu
    SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS = "|c00FF00About ESO Plus|r",
    SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_A = "|c9999FF/esoplus|r |cFF6347write in chat for manual check!|r This addon saves records of receiving a free subscription, so you will always know exactly on which day it was activated or absent. By default, the history stores up to 2000 records. What does this mean in practice? Each record in the table takes up one line per day. Thus, the limit of 2000 lines covers a period of approximately 2000/365≈5.48 years. In other words, the addon will store your subscription history for almost five and a half years.",

    SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AA = "|c00FF00APIs used by this addon|r",
    SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAA = "|c00FF00API (Application Programming Interface)|r — it's a set of rules that allow your addon to interact with the game server. In simple terms: it's a list of allowed commands defining its capabilities. For implementation were used:",
    
    SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AB = "|c00FF00* HasEsoPlusFreeTrialNotification()|r",
    SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAB = "** _Returns:_ *bool* _hasFreeTrialNotification_",
    
    SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AC = "|c00FF00* ClearEsoPlusFreeTrialNotification()|r",
    SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAC = "This addon has no keybind function to call a custom user history table, because the addon is purely informational. You'll almost never need this table. The author deliberately didn't add such a button due to game limitations: only 100 slots are available for custom keys, so filling them with unnecessary elements is impractical.",
    
    SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AD = "|c00FF00Automatic Check Function!!!|r",
    SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAD = "|c9999FFAutomatic checks happen every 15 minutes regardless of addon settings, so you don't miss activation if it happens later that day. This timer is completely safe for performance. Here's why:|r |cFFFFC5Execution frequency Once every 15 minutes — extremely rare for a game engine. For comparison: ESO client itself processes tens of thousands of events per second (animation, rendering, network packets). One function every 15 minutes is a drop in the ocean. - All operations here are pure logic: reading account status via built-in API (HasEsoPlus...), working with local Lua table, and outputting to chat (d()). No heavy calculations, loops over large arrays, file or network access. Calls like ZO_SavedVars, d(), ClearEsoPlus... are optimized by ZOS devs and run in microseconds.|r |cffd700Ping|r is determined by internet quality and ESO server load. Local Lua timer doesn't send data more often than the game already does. |c1E90FFComparison with other addons.|r Many popular addons use much more frequent timers: |cADD8E6- Inventory Insight|r — checks inventory on open; |cADD8E6- Combat Metrics|r — analyzes every combat tick (dozens per second); — even standard UI updates 60+ times/sec. This |cADD8E6timer|r of 900 seconds looks like 'once in an era' against this backdrop.",

    SI_ESOPLUSFREETRIALNOTIF_ADDON_NAME_INFO = "|cFF6347The table is below:|r",
    SI_ESOPLUSFREETRIALNOTIF_ADDON_NAME_INFO_A = "|c9999FFThe table shows up to 20 record cycles, from which date to which date EsoPlus was available or unavailable.|r |cFFFFCOpen the table:|r",

    SI_ESOPLUSFREETRIALNOTIF_HISTORY_LINES = "Number of lines to record",
    SI_ESOPLUSFREETRIALNOTIF_HISTORY_LINES_A = "|c00FF00How many lines will be saved in the SavedVariables file history [affects file size and recording duration, upon reaching the limit, it will be overwritten] (от 100 до 5000 number of possible lines)|r",

    SI_ESOPLUSFREETRIALNOTIF_GENERAL_INFO_RECORDS = "|ccdfff3All records|r",
    SI_ESOPLUSFREETRIALNOTIF_GENERAL_INFO_ESOPLUS = "|ccdfff3INFORMATION|r",

    SI_ESOPLUSFREETRIALNOTIF_CHANGELOG = "changelog",

    SI_ESOPLUSFREETRIALNOTIF_CHANGELOGA = "EsoPlusFreeTrialNotification V1.0",
    SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_A = "first version",
    SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_AA = "with the old LibStub library",

    SI_ESOPLUSFREETRIALNOTIF_CHANGELOGB = "EsoPlusFreeTrialNotification v1.1",
    SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_B = "changes for ESOUI:",
    SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_BB = "1 removed connection to LibStub, added connection to LibAddonMenu-2.0\n 2 all language files with local strings\n 3 Fixed global variables without a local reference to speed up access to the G table\n 4 fixed some minor changes similar to those described above.",

    SI_ESOPLUSFREETRIALNOTIF_CHANGELOGC = "EsoPlusFreeTrialNotification v1.2",
    SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_C = "Code Optimization, Part One",
    SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_CC = "1. Single Global Table Unified Namespace\n **Implemented correctly.\n Only one global table is used: ESOPLUSFREETRIALNOTIFICATION_ESWAGROM with a local alias EPFTN.\n 2. Access Optimization G optimization\n Using local EPFTN ... is considered very good coding style. This speeds up table access at the micro level by caching the reference on the Lua stack, which avoids repeatedly searching the slow global table G on every function call. 3.\n Integrated Settings Menu: The external settings file .xml was completely removed. All settings and entries are now handled within the system, and for ease of use, the modern LibAddonMenu-2.0 library is utilized.\n 4. Changed\n Code Optimization:\n All unused settings were removed and most lines of legacy code were deleted to significantly reduce its size.\n The remaining codebase was significantly optimized; the logic is now minimal, clear, and easy to maintain.\n 5. Fixed\n Scrollable UI Table: The issue with the internal data table was resolved. A fully functional vertical scrollbar was implemented, allowing users to easily navigate through records.",

    SI_ESOPLUSFREETRIALNOTIF_CHANGELOGD = "EsoPlusFreeTrialNotification v1.3",
    SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_D = "table optimization",
    SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_DD = "1). History Table Optimization\n * **What has changed:**\n The logic for displaying entries in the history table has been completely reworked. Previously, each row was a separate UI element with individual formatting, which led to visual errors and delays when processing large amounts of data.\n Text color merging issues have been fixed.\n The one-second delay upon opening the addon window has been eliminated.\n> Why did this happen?\n This is a classic game interface optimization problem:\n Memory Optimization: Each color change increases the load on the CPU and RAM. The engine groups elements with identical styles to reduce the number of objects to render.\n Engine Limitation (ZO_ScrollList): The ESO API has a limit on the number of unique text formats within a scrollable list. After reaching a threshold value of approximately 128 lines, the engine stops processing individual color labels (|c...) and begins applying the previous group's style to all subsequent entries.\n Default Merging: Since many rows share the same formatting, the user interface considers them a single logical block and applies a unified style from bottom to top.\n New Solution:\n The history now stores only the last 20 periods of EsoPlus availability/unavailability. This provides sufficient information volume and guarantees that the table opens instantly without any delay.\n Important Note: The data volume in the SavedVariables file (even if it contains 2000-5000 records) does not affect in-game performance at all. The limitation applies exclusively to UI rendering.\n **2). Secure Localization Loading\n * **The language translation system has been improved. English now serves as a safe base anchor (main language), after which the user's chosen localization is loaded on top. This makes the text initialization process more stable and predictable.\n **3). Code Cleanup\n * **All unused functions and variables were removed from the main addon file. The codebase is now cleaner, lighter, and easier to maintain."

}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end