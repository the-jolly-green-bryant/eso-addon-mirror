
--[[
LibLootSummary English Localization (Reference Implementation)

This file serves as the reference localization for all text strings used
in LibLootSummary. All other language files should maintain the same
structure and string constant names with translated values.

String Constants:
- UI labels and tooltips for LibAddonMenu integration
- Fallback text for error conditions and missing translations
- Format strings for counters and output formatting

Technical Notes:
- Uses ZO_CreateStringId for proper ESO string registration
- String constants follow SI_LLS_* naming convention  
- Fallback strings provide graceful degradation for missing translations
- All strings support ESO's placeholder system (<<1>>, <<X:1>>, etc.)
]]

ZO_CreateStringId("SI_LLS_ITEM_SUMMARY", "Item Summary")
ZO_CreateStringId("SI_LLS_ITEM_SUMMARY_TOOLTIP", "<<1>> will print a summary of items when done.")
ZO_CreateStringId("SI_LLS_LOOT_SUMMARY", "Loot History Summary")
ZO_CreateStringId("SI_LLS_LOOT_SUMMARY_TOOLTIP", "<<1>> will print a summary of loot when done.")
ZO_CreateStringId("SI_LLS_MIN_ITEM_QUALITY", "Minimum Item Quality")
ZO_CreateStringId("SI_LLS_MIN_ITEM_QUALITY_TOOLTIP", "Filter out any items with a quality less than this minimum quality from appearing in the summary.")
ZO_CreateStringId("SI_LLS_MIN_LOOT_QUALITY", "Minimum Loot Quality")
ZO_CreateStringId("SI_LLS_MIN_LOOT_QUALITY_TOOLTIP", "Filter out any loot with a quality less than this minimum quality from appearing in the summary.")
ZO_CreateStringId("SI_LLS_SHOW_ITEM_ICONS", "Show Item Icons")
ZO_CreateStringId("SI_LLS_SHOW_ITEM_ICONS_TOOLTIP", "Display icons to the left of item names that appear in the summary.")
ZO_CreateStringId("SI_LLS_ICON_SIZE", "Icon Size")
ZO_CreateStringId("SI_LLS_ICON_SIZE_TOOLTIP", "Set icon size in percent.")
ZO_CreateStringId("SI_LLS_SHOW_LOOT_ICONS", "Show Loot Icons")
ZO_CreateStringId("SI_LLS_SHOW_LOOT_ICONS_TOOLTIP", "Display icons to the left of loot names that appear in the summary.")
ZO_CreateStringId("SI_LLS_SHOW_ITEM_TRAITS", "Show Item Trait Names")
ZO_CreateStringId("SI_LLS_SHOW_ITEM_TRAITS_TOOLTIP", "Display trait names in parenthesis to the right of item names that appear in the summary.")
ZO_CreateStringId("SI_LLS_SHOW_LOOT_TRAITS", "Show Loot Trait Names")
ZO_CreateStringId("SI_LLS_SHOW_LOOT_TRAITS_TOOLTIP", "Display trait names in parenthesis to the right of loot names that appear in the summary.")
ZO_CreateStringId("SI_LLS_HIDE_ITEM_SINGLE_QTY", "Hide Quantity for Single Items")
ZO_CreateStringId("SI_LLS_HIDE_ITEM_SINGLE_QTY_TOOLTIP", "Quantities will only be printed to the right of item names that have a quantity greater than one.")
ZO_CreateStringId("SI_LLS_HIDE_LOOT_SINGLE_QTY", "Hide Quantity for Single Items")
ZO_CreateStringId("SI_LLS_HIDE_LOOT_SINGLE_QTY_TOOLTIP", "Quantities will only be printed to the right of loot names that have a quantity greater than one.")
ZO_CreateStringId("SI_LLS_COMBINE_DUPLICATES", "Combine Repeated Items")
ZO_CreateStringId("SI_LLS_COMBINE_DUPLICATES_TOOLTIP", "Links that appear more than once in the summary are combined into a single link and their quantities are summed together.")
ZO_CreateStringId("SI_LLS_SHOW_ITEM_NOT_COLLECTED", "<<1>> Show Uncollected Sets Icons")
ZO_CreateStringId("SI_LLS_SHOW_ITEM_NOT_COLLECTED_TOOLTIP", "Display icons to the right of item names if their set pieces are not collected.")
ZO_CreateStringId("SI_LLS_SHOW_LOOT_NOT_COLLECTED", "<<1>> Show Uncollected Sets Icons")
ZO_CreateStringId("SI_LLS_SHOW_LOOT_NOT_COLLECTED_TOOLTIP", "Display icons to the right of loot names if their set pieces are not collected.")
ZO_CreateStringId("SI_LLS_SORT_ORDER_TOOLTIP", "Choose how the summary will be sorted")
ZO_CreateStringId("SI_LLS_DELIMITER", "List Delimiter")
ZO_CreateStringId("SI_LLS_DELIMITER_TOOLTIP", "Choose which characters will separate summary entries. \"\\n\" signifies that all list entries appear on separate lines.")
ZO_CreateStringId("SI_LLS_LINK_STYLE", "Link Style")
ZO_CreateStringId("SI_LLS_LINK_STYLE_TOOLTIP", "Choose how links will appear.")
ZO_CreateStringId("SI_LLS_QUOTES", "\"<<X:1>>\"")
ZO_CreateStringId("SI_LLS_SHOW_COUNTER", "<<1>> Count")
ZO_CreateStringId("SI_LLS_SHOW_COUNTER_TOOLTIP", "Displays a count of <<1>> at the end of the summary.")
ZO_CreateStringId("SI_LLS_COUNTER_FORMAT_SINGLE", "(<<1>> <<2>>)")
ZO_CreateStringId("SI_LLS_COUNTER_FORMAT_PLURAL", "(<<1*2>>)")
ZO_CreateStringId("SI_LLS_PLURAL", "<<1*2>>")

-- Fallback strings for error conditions and missing localization
ZO_CreateStringId("SI_LLS_FALLBACK_SHOW_UNCOLLECTED", "Show Uncollected Set Icons")
ZO_CreateStringId("SI_LLS_FALLBACK_SETTINGS_FOR", "Settings for")
ZO_CreateStringId("SI_LLS_FALLBACK_SHOW_COUNTER", "Show Counter")
ZO_CreateStringId("SI_LLS_FALLBACK_SHOW_COUNT_OF", "Show count of")
ZO_CreateStringId("SI_LLS_FALLBACK_ITEMS", "Items")
ZO_CreateStringId("SI_LLS_FALLBACK_ITEMS_LOWER", "items")
ZO_CreateStringId("SI_LLS_ERROR_CONSTANTS_NOT_DEFINED", "String constants not defined")
ZO_CreateStringId("SI_LLS_ERROR_VALUES_NOT_LOADED", "String values not loaded")