-- EN Language file, made by PhaeroX
local strings = {
  PXIP_RAW_ANCESTOR_SILK                             = "raw ancestor silk",
  PXIP_RAW_ANCESTOR_SILK_REFINED_NAME                = "Ancestor Silk",
  PXIP_RAW_ANCESTOR_SILK_SHORT_NAME                  = "S",
  
  PXIP_RUBEDITE_ORE                                  = "rubedite ore",
  PXIP_RUBEDITE_ORE_REFINED_NAME                     = "Rubedite Ingot",
  PXIP_RUBEDITE_ORE_SHORT_NAME                       = "I",
  
  PXIP_ROUGH_RUBY_ASH                                = "rough ruby ash",
  PXIP_ROUGH_RUBY_ASH_REFINED_NAME                   = "Sanded Ruby Ash",
  PXIP_ROUGH_RUBY_ASH_SHORT_NAME                     = "A",

  PXIP_RUBEDO_HIDE_SCRAPS                            = "rubedo hide scraps",
  PXIP_RUBEDO_HIDE_SCRAPS_REFINED_NAME               = "Rubedo Leather",
  PXIP_RUBEDO_HIDE_SCRAPS_SHORT_NAME                 = "L",

  PXIP_SETTINGS_DISPLAY_NAME                         = "PhaeroX Info Panel",
  PXIP_SETTINGS_AUTHOR                               = "|c28b712PhaeroX|r",
  PXIP_SETTINGS_HEADER_TEXT                          = "PhaeroX Info Panel Settings:",
  PXIP_SETTINGS_GENERAL_OPTIONS                      = "General Options",
  PXIP_SETTINGS_FONT_COLOR                           = "Font Color",
  PXIP_SETTINGS_FONT_COLOR_TOOLTIP                   = "Select the font color to display the writ status:",
  PXIP_SETTINGS_FONT_SCALE                           = "Font Scale",
  PXIP_SETTINGS_BACKGROUND_TRANSPARENCY              = "Background Transparency",
  PXIP_SETTINGS_TOGGLE_NOTIFY_OPTIONS                = "Toggle and Notify Options",
  PXIP_SETTINGS_SHOW_DATE_TIME                       = "Show time of last update:",
  PXIP_SETTINGS_SHOW_LAST_LOOT                       = "Show last loot:",
  PXIP_SETTINGS_NOTIFY_ABOUT_LOOT_OVER               = "Notify about loot over",
  PXIP_SETTINGS_NOTIFY_ABOUT_LOOT_OVER_TOOLTIP       = "-1 will disable this feature, 0 will show loot notifications on everything.",
  PXIP_SETTINGS_SHOW_BEST_LOOT                       = "Show best loot:",
  PXIP_SETTINGS_SHOW_2ND_BEST_LOOT                   = "Show 2nd best loot:",
  PXIP_SETTINGS_SHOW_3RD_BEST_LOOT                   = "Show 3rd best loot:",
  PXIP_SETTINGS_SHOW_4TH_BEST_LOOT                   = "Show 4th best loot:",
  PXIP_SETTINGS_SHOW_5TH_BEST_LOOT                   = "Show 5th best loot:",
  PXIP_SETTINGS_SHOW_MATERIAL_INFO                   = "Show material info on Ancestor Silk, etc",
  PXIP_SETTINGS_SHOW_CONDENSED_MATERIAL_INFO         = "Show condensed material info:",
  PXIP_SETTINGS_SHOW_CONDENSED_MATERIAL_INFO_TOOLTIP = "Instead of using 4 lines to display your material inventory, we'll use only one.",
  PXIP_SETTINGS_SHOW_ACHIEVEMENT_POINTS              = "Show achievement points:",
  PXIP_SETTINGS_SHOW_ENLIGHTENED_POOL                = "Show enlightened pool:",
  PXIP_SETTINGS_SHOW_TOTAL_MINUTES_PLAYED            = "Show total minutes played:",
  PXIP_SETTINGS_SHOW_LEVEL_PROGRESS                  = "Show level progress:",
  PXIP_SETTINGS_SHOW_GRIND_STATUS                    = "Show grind status:",
  PXIP_SETTINGS_SHOW_GRIND_STATUS_TOOLTIP            = "Show stats on how long it will take you to reach the next level.",
  PXIP_SETTINGS_SHOW_TOTAL_GOLD_MADE                 = "Show total gold made:",
  PXIP_SETTINGS_SHOW_TOTAL_XP_GAINED                 = "Show total XP gained:",
  PXIP_SETTINGS_SHOW_TOTAL_WRIT_VOUCHERS             = "Show total writ vouchers:",
  PXIP_SETTINGS_SHOW_LAST_LOREBOOK_LEARNED           = "Show last lorebook learned:",
  PXIP_SETTINGS_SHOW_LORE_BOOK_NOTIICATION           = "Show lore book notification:",
  PXIP_SETTINGS_SHOW_LORE_BOOK_NOTIICATION_TOOLTIP   = "Show a notification when you learn a new lore book, and some detailed information about what you have discovered.",
  PXIP_SETTINGS_SHOW_WRIT_VOUCHERS                   = "Show writ status:",
  PXIP_SETTINGS_SHOW_CONDENSED_WRIT_VOUCHERS         = "Show condensed writ status:",
  PXIP_SETTINGS_SHOW_CONDENSED_WRIT_VOUCHERS_TOOLTIP = "Instead of using up to 6 lines to display writ status, one line will be used with initials being either red or green, indicating not done/done.",

  PXIP_BINDINGS_RESET                                = "Reset PhaeroX Info Panel",
  PXIP_BINDINGS_TOGGLE                               = "Toggle PhaeroX Info Panel",

  PXIP_BEST_LOOT_SO_FAR                              = "Best loot so far: ",
  PXIP_LEARNED                                       = "Learned: ",
  PXIP_IN                                            = " in ",
  PXIP_KNOWN                                         = " (Known ",

  -- This text is important. The code looks for these texts to determine writ quests and their status:
  PXIP_WRITS_DELIVER                                 = "Deliver",
  PXIP_WRITS_COMPLETED                               = "Completed",
  PXIP_WRITS_BLACKSMITHING_SUBSTRING                 = "Black",
  PXIP_WRITS_CLOTHING_SUBSTRING                      = "Cloth",
  PXIP_WRITS_WOODWORKING_SUBSTRING                   = "Wood",
  PXIP_WRITS_ALCHEMY_SUBSTRING                       = "Alchem",
  PXIP_WRITS_ENCHANTING_SUBSTRING                    = "Enchant",
  PXIP_WRITS_PROVISIONING_SUBSTRING                  = "Prov",
  PXIP_WRITS_ALL_WRITS_DONE                          = "All writs done|r -- ",
  PXIP_WRITS_TIME_TO_TURN_THEM_IN                    = "Time to turn them in!!",

  PXIP_CP                                            = "CP",
  PXIP_LEVEL                                         = "Level",
  PXIP_LAST                                          = "Last: ",
  PXIP_BEST                                          = "Best: ",
  PXIP_2ND                                           = "2nd: ",
  PXIP_3RD                                           = "3rd: ",
  PXIP_4TH                                           = "4th: ",
  PXIP_5TH                                           = "5th: ",
  PXIP_ACHIEVEMENT_POINTS                            = "Achievement Points: ",
  PXIP_ENLIGHTENED_POOL                              = "Enlightened Pool: ",
  PXIP_ENLIGHTENED_POOL_EXHAUSTED                    = "Enlightened pool exhausted...",
  PXIP_TOTAL_MINS_PLAYED                             = "Total Mins Played: ",
  PXIP_LEVEL_PROGRESS                                = "Level Progress: ",
  PXIP_GRIND_STATUS_1                                = "Grind Status: You will reach ",
  PXIP_GRIND_STATUS_2                                = " in ",
  PXIP_GRIND_STATUS_3                                = " minutes.",
  PXIP_TOTAL_GOLD_MADE_1                             = "Total Gold Made: ",
  PXIP_TOTAL_GOLD_MADE_2                             = "|r / minute)",
  PXIP_TOTAL_XP_MADE_1                               = "Total XP Made: ",
  PXIP_TOTAL_XP_MADE_2                               = "|r / minute)",
  PXIP_TOTAL_WRIT_VOUCHERS                           = "Total Writ Vouchers: ",

  PXIP_BLACKSMITHING_LETTER                          = "B|r",
  PXIP_CLOTHING_LETTER                               = "C|r",
  PXIP_WOODWORKING_LETTER                            = "W|r",
  PXIP_ALCHEMY_LETTER                                = "A|r",
  PXIP_ENCHANTING_LETTER                             = "E|r",
  PXIP_PROVISIONING_LETTER                           = "P|r",

  -- V0.0.15 -- New strings:
  PXIP_SETTINGS_CUSTOM_INVENTORY_MONITOR             = "Custom Inventory Monitor",

  -- V0.0.18 -- New strings:
  PXIP_SETTINGS_SHOW_BIS_LOOT_NOTIFICATIONS          = "Show BiS Loot Notifications",
  PXIP_SETTINGS_SHOW_BIS_LOOT_NOTIFICATIONS_TOOLTIP  = "Show Best in Slot Loot Notifications. Will let you know when you get divine in light/medium, or when you get the correct trait on heavy set pieces.",
  PXIP_SETTINGS_HIDE_INFO_PANEL_WHEN_USING_INVENTORY = "Hide Info Panel when using Inventory etc.",
  PXIP_SETTINGS_HIDE_INFO_PANEL_WHEN_USING_INVENTORY_TOOLTIP = "Hide info panel when looking at inventory, interactiving with stations etc.",

  -- V0.0.20 -- New strings:
  PXIP_SETTINGS_SHOW_GROUP_LOOT                      = "Show group loot",

  -- V0.0.21 -- New strings:
  PXIP_SETTINGS_PLAY_SOUND_ON_NOTIFY_ABOUT_LOOT_ABOVE= "Toggle sound on notify about loot above a value",
  PXIP_SETTINGS_PLAY_SOUND_ON_NOTIFY_ABOUT_LOOT_ABOVE_TOOLTIP= "Toggles whether or not to play a sound when you are notified about loot over a certain value.",

  -- V0.0.23 -- New strings:
  PXIP_SETTINGS_LAST_LOOT_LINES                      = "Last loot lines:",
  PXIP_SETTINGS_LAST_LOOT_LINES_TOOLTIP              = "The number of last loot items to display.",

  -- V0.0.24 -- New strings:
  PXIP_SETTINGS_WINDOW_SETTINGS                      = "Window Settings",
  PXIP_SETTINGS_SHOW_WINDOW                          = "Show Window",
  PXIP_SETTINGS_PVP                                  = "PVP Settings",
  PXIP_SETTINGS_SHOW_PVP_INFORMATION                 = "Show PVP Information",
  PXIP_SETTINGS_SHOW_PVP_INFOIRMATION_TOOLTIP        = "Show information about current Alliance Points earned and alliance points earned per minutes.",
  PXIP_SETTINGS_MONITOR_INVENTORY                    = "Monitor Inventory",
  PXIP_SETTINGS_SHOW_PVP_ONLY_WHEN_IN_PVP            = "Show PVP information only when in a PVP campaign",
  PXIP_SETTINGS_SHOW_PVP_RANK                        = "Show PVP rank",
  PXIP_SETTINGS_SHOW_PVP_QUEUE_TIME_WHEN_QUEUED      = "Show PVP queue time when queued",
  PXIP_GAINED                                        = "Gained ",
  PXIP_NOW_AT                                        = " Now at ",

  -- V0.0.25 -- New strings:
  PXIP_SETTINGS_SHOW_LAST_LOOT_IN_CHAT               = "Log the last loot to the chat window.",
  PXIP_SETTINGS_SHOW_LAST_LOOT_AND_TOTAL_GOLD_IN_CHAT= "Also log the total gold and gold/minute to chat.",
  PXIP_SETTINGS_SHOW_LAST_LOOT_TRAIT                 = "Also show trait with last loot.",
  PXIP_SETTINGS_SHOW_ACHIEVEMENT_PROGRESS_IN_CHAT    = "Log to chat when you make progress on an achievement.",

  -- V0.0.31 -- New strings:
  PXIP_SETTINGS_SHOW_DIVIDERLINE                     = "Show divider line around your materials.",
  PXIP_SETTINGS_SHOW_DIVIDERLINE_TOOLTIP             = "Show divider line around your materials such as ancestor silk, rubdedite ore etc.",

  -- V0.0.33 -- New strings:
  PXIP_SETTINGS_VENDOR_AUTOMATION                    = "Vendor Automation",
  PXIP_SETTINGS_VENDOR_AUTOMATION_ENABLE             = "Enable Vendor Automation",
  PXIP_SETTINGS_VENDOR_AUTOMATION_ENABLE_TOOLTIP     = "Enable automatic purchasing from vendor as defined below.",
  PXIP_VENDOR_AUTOMATION_MAX_GOLD_LIMIT              = "Do not spend more than",
  PXIP_VENDOR_AUTOMATION_MAX_GOLD_LIMIT_TOOLTIP      = "When talking to a vendor, purchasing will not exceed this gold amount.",
  PXIP_VENDOR_AUTOMATION_MAX_UNIT_PRICE              = "Max unit price",
  PXIP_VENDOR_AUTOMATION_MAX_UNIT_PRICE_TOOLTIP      = "Will not buy any items with a unit price exceeding this value.",
  PXIP_VENDOR_AUTOMATION_INVENTORY_COUNT             = "Inventory count you want",
  PXIP_VENDOR_AUTOMATION_INVENTORY_COUNT_TOOLTIP     = "This is the inventory you want to have. I you want 200 and have 190, 10 will be purchased.",
  PXIP_VENDOR_AUTOMATION_DEBUG                       = "Show chat debugging information.",
  PXIP_VENDOR_AUTOMATION_DESCRIPTION                 = "This section is intended to automate the purchasing of style items such as Molybdenum, Bone, etc. and runes from the ESO ingame vendor. You set the amount you want of each in your inventory, the price per unit max, the max gold you want to spend in total per session, and the addon will take care of the rest. Let's say you want to always have 25 of each inventory. Then lets say you have 21 Molybdenum, this addon will buy 4 Molybdenum and move on to the next. It will not go above the set spending limits per visit. Use this with caution and at your own risk. This was made to avoid the tedious task of buying a couple hundred style materials manually.",
  PXIP_SETTINGS_GUILDBANK_AUTOMATION                 = "Guildbank Automation",
  PXIP_SETTINGS_GUILDBANK_AUTOMATION_DESCRIPTION     = "Here you can automate depositing or withdrawing money from a set guildbank. You set the money you want to have on your character, say 50k, and if you have above that on your character when you interact with the set guildbank, you will deposit the amount above 50k, and vice versa if you are below 50k, you will withdraw from the guild bank, up until you hold 50k on your character.",
  PXIP_SETTINGS_GUILDBANK_AUTOMATION_ENABLE          = "Enable Guildbank Automation",
  PXIP_GUILDBANK_NAME                                = "Name of guildbank to enable automation for:",
  PXIP_GUILDBANK_AUTOMATION_AMOUNT                   = "Amount of gold to have on character:",
  PXIP_GUILDBANK_AUTOMATION_AMOUNT_DESCRIPTION       = "The amount of gold you want to have on your character.",

  -- V1.0.4 -- New strings:
  PXIP_WRITS_JEWELRY_SUBSTRING                       = "Jewelry",
  PXIP_JEWELRY_LETTER                                = "J|r",

  -- V1.0.6 -- New strings:
  PXIP_PLATINUM_DUST                                 = "Platinum Dust",
  PXIP_PLATINUM_OUNCE                                = "Platinum Ounce",
  PXIP_PLATINUM_SHORT_NAME                           = "P",
  PXIP_SETTINGS_MONITOR_RESEARCH                     = "Monitor Research",
  PXIP_SETTINGS_MONITOR_RESEARCH_DESCRIPTION         = "Monitor how much time is left on researching individual crafting skill lines.",
  PXIP_SETTINGS_MONITOR_RESEARCH_ENABLE              = "Enable research monitoring",
  PXIP_SETTINGS_BLACKSMITHING                        = "Blacksmithing",
  PXIP_SETTINGS_CLOTHING                             = "Clothing",
  PXIP_SETTINGS_WOODWORKING                          = "Woodworking",
  PXIP_SETTINGS_ALCHEMY                              = "Alchemy",
  PXIP_SETTINGS_ENCHANTING                           = "Enchanting",
  PXIP_SETTINGS_PROVISIONING                         = "Provisioning",
  PXIP_SETTINGS_JEWELRY                              = "Jewelry",
  PXIP_SETTINGS_RESEARCH_SHOW_CONDENSED              = "Show research times in condensed one line format",
  PXIP_JEWELRY_LETTER                                = "J|r",

  -- V1.0.10 -- New strings:
  PXIP_SETTINGS_SHOW_BEST_LOOT_NOTIFICATION          = "Show Best Loot Notifications.",
  PXIP_SETTINGS_SHOW_BEST_LOOT_NOTIFICATION_TOOLTIP  = "Whenever you loot an item that has the highest value so far during your game session, you will be notified on the center of your screen.",

  -- V1.0.13 -- New strings:
  PXIP_SETTINGS_SHOW_SURVEYS_FOR_CURRENT_ZONE        = "Show current survey count for current zone:",
  PXIP_SETTINGS_SHOW_SURVEYS_FOR_CURRENT_ZONE_TOOLTIP= "Show current survey count you have for the current zone your are in.",
  PXIP_SURVEYS_IN_ZONE                               = "Surveys in zone:",
  PXIP_ENLIGHTENED_POOL_ABOVE_ONE_MILLION            = "Enlightened pool at or above 1 million!",

  -- V1.0.15 -- New strings:
  PXIP_SETTINGS_SHOW_FISHING_STATISTICS              = "Show fishing statistics:",
  PXIP_SETTINGS_SHOW_FISHING_STATISTICS_TOOLTIP      = "Show how many fish you catch total and for your current session.",
  PXIP_FISH_CAUGHT                                   = "Fish Caught:",

  -- V1.0.16 -- New strings:
  PXIP_SETTINGS_SHOW_TOTAL_ZONE_MINUTES_PLAYED       = "Show total minutes played in current zone:",
  PXIP_TIME_PLAYED_IN_ZONE                           = "In Current Zone:"
}

for stringId, stringValue in pairs(strings) do
  ZO_CreateStringId(stringId, stringValue)
  SafeAddVersion(stringId, 1)
end