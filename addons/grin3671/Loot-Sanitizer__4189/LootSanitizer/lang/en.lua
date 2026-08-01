ZO_CreateStringId("LOOTSANITIZER_NAME"                            , "LootSanitizer")
ZO_CreateStringId("LOOTSANITIZER_ACTION"                          , "destroed")
ZO_CreateStringId("LOOTSANITIZER_BINDACTION"                      , "binded")

ZO_CreateStringId("LOOTSANITIZER_LCMACTION_JUNK_ON"               , "|t30:30:esoui/art/inventory/inventory_tabIcon_junk_up.dds|t Marks as junk")
ZO_CreateStringId("LOOTSANITIZER_LCMACTION_JUNK_OFF"              , "|t30:30:esoui/art/inventory/inventory_tabIcon_junk_up.dds|t Stops automarking")
ZO_CreateStringId("LOOTSANITIZER_LCMACTION_BURN_ON"               , "|t30:30:esoui/art/inventory/inventory_tabIcon_trash_up.dds|t Always |cff0000destoy|r")
ZO_CreateStringId("LOOTSANITIZER_LCMACTION_BURN_OFF"              , "|t30:30:esoui/art/inventory/inventory_tabIcon_trash_up.dds|t Stops autodestroying")

ZO_CreateStringId("LOOTSANITIZER_WARNING"                         , "|cff0000Attention!|r |cc5c29eDestroyed items cannot be returned. Hold Shift before picking up an item to prevent the addon from destroying it.|r")

ZO_CreateStringId("LOOTSANITIZER_MESSAGE_DESTROY_SUCCESS"         , "[<<1>>] destroed <<2>>.") -- 1:addonName 2:itemLink
ZO_CreateStringId("LOOTSANITIZER_MESSAGE_BIND_SUCCESS"            , "[<<1>>] binded <<2>>.") -- 1:addonName 2:itemLink
ZO_CreateStringId("LOOTSANITIZER_MESSAGE_JUNK_SELL_SUCCESS"       , "[<<1>>] selled <<2>> items from Junk tab for <<3>> gold.") -- 1:addonName 2:selledItemCount 3:selleditemPrice
ZO_CreateStringId("LOOTSANITIZER_MESSAGE_RECIPE_LEARN_SUCCESS"    , "[<<1>>] learned recipe <<2>>.") -- 1:addonName 2:itemLink
ZO_CreateStringId("LOOTSANITIZER_MESSAGE_RECIPE_LEARN_FAILURE"    , "[<<1>>] couldn't learn <<2>> automatically.") -- 1:addonName 2:itemLink
ZO_CreateStringId("LOOTSANITIZER_MESSAGE_SHIFT_STOP_DESTROY"      , "[<<1>>] averts destroying of <<2>> by holding Shift.") -- 1:addonName 2:itemLink
ZO_CreateStringId("LOOTSANITIZER_MESSAGE_ADDON_STOP_DESTROY"      , "[<<1>>] averts destroying of <<2>> due to MRL addon tracking.") -- 1:addonName 2:itemLink

ZO_CreateStringId("LOOTSANITIZER_WORKMODE_CONTROL"                , "Addon handles items")
ZO_CreateStringId("LOOTSANITIZER_WORKMODE_CONTROL_NO"             , "Never")
ZO_CreateStringId("LOOTSANITIZER_WORKMODE_CONTROL_AUTOLOOT"       , "Only at Autoloot")
ZO_CreateStringId("LOOTSANITIZER_WORKMODE_CONTROL_ALWAYS"         , "Always")

ZO_CreateStringId("LOOTSANITIZER_CHAT_NOTIFY"                     , "Chat notifications")
ZO_CreateStringId("LOOTSANITIZER_CHAT_NOTIFY_NO"                  , "Disabled")
ZO_CreateStringId("LOOTSANITIZER_CHAT_NOTIFY_DELETE"              , "About deletion")
ZO_CreateStringId("LOOTSANITIZER_CHAT_NOTIFY_DEV"                 , "Developer mode")

ZO_CreateStringId("LOOTSANITIZER_SOUND_CONTROL"                   , "Sound notifications")

ZO_CreateStringId("LOOTSANITIZER_EQUIPMENT_HEADER"                , "Equipment")
ZO_CreateStringId("LOOTSANITIZER_EQUIPMENT_CONTROL"               , "Delete simple equipment")
ZO_CreateStringId("LOOTSANITIZER_EQUIPMENT_CONTROL_COST"          , "Maximum cost of deleted items")
ZO_CreateStringId("LOOTSANITIZER_SIMPLECLOTHES_CONTROL"           , "Delete trash clothes")
ZO_CreateStringId("LOOTSANITIZER_EQUIPMENT_DESCRIPTION"           , "Only ordinary equipment with <<1>> price in the styles of the 9 common races and in the absence of crafting features is removed.") -- 1:itemPrice
ZO_CreateStringId("LOOTSANITIZER_SIMPLECLOTHES_DESCRIPTION"       , "Clothes is trash-quality equipable items without stats and sets. These items are usually used roleplaying and costs around  <<1>>. Example: <<2>>") -- 1:itemPrice 2:itemLink example

ZO_CreateStringId("LOOTSANITIZER_SETS_HEADER"                     , GetString(SI_ITEM_SETS_BOOK_TITLE))
ZO_CreateStringId("LOOTSANITIZER_SETS_CONTROL"                    , "Auto-Binding")
ZO_CreateStringId("LOOTSANITIZER_SETS_CONTROL_NO"                 , "Disabled")
ZO_CreateStringId("LOOTSANITIZER_SETS_CONTROL_GREEN"              , "Only <<1>> quality") -- 1:itemQuality
ZO_CreateStringId("LOOTSANITIZER_SETS_CONTROL_BLUE"               , "<<1>> and lower") -- 1:itemQuality
ZO_CreateStringId("LOOTSANITIZER_SETS_CONTROL_PURPLE"             , "<<1>> and lower") -- 1:itemQuality
ZO_CreateStringId("LOOTSANITIZER_SETS_DESCRIPTION"                , "Automatically bind new equipment of the selected quality to add it to the collection. Does not affect on BoP items.")

ZO_CreateStringId("LOOTSANITIZER_COMPANION_HEADER"                , GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COMPANION))
ZO_CreateStringId("LOOTSANITIZER_COMPANION_CONTROL"               , "Removing companion items")
ZO_CreateStringId("LOOTSANITIZER_COMPANION_CONTROL_NO"            , "Disabled")
ZO_CreateStringId("LOOTSANITIZER_COMPANION_CONTROL_WHITE"         , "Only <<1>> quality") -- 1:itemQuality
ZO_CreateStringId("LOOTSANITIZER_COMPANION_CONTROL_GREEN"         , "<<1>> and lower") -- 1:itemQuality
ZO_CreateStringId("LOOTSANITIZER_COMPANION_CONTROL_BLUE"          , "<<1>> and lower") -- 1:itemQuality

ZO_CreateStringId("LOOTSANITIZER_MATERIALMOTIF_HEADER"            , "Style materials and motifs")
ZO_CreateStringId("LOOTSANITIZER_MATERIAL_CONTROL"                , "Delete style materials")
ZO_CreateStringId("LOOTSANITIZER_MATERIAL_CONTROL_NO"             , "Disabled")
ZO_CreateStringId("LOOTSANITIZER_MATERIAL_CONTROL_COMMON"         , "Only common")
ZO_CreateStringId("LOOTSANITIZER_MATERIAL_CONTROL_RARE"           , "Including rare")
ZO_CreateStringId("LOOTSANITIZER_MOTIF_CONTROL"                   , "Delete motifs")
ZO_CreateStringId("LOOTSANITIZER_MOTIF_CONTROL_NO"                , "Disabled")
ZO_CreateStringId("LOOTSANITIZER_MOTIF_CONTROL_COMMON"            , "Only common")
ZO_CreateStringId("LOOTSANITIZER_MOTIF_CONTROL_RARE"              , "Including rare")
ZO_CreateStringId("LOOTSANITIZER_MOTIFLEARN_CONTROL"              , "Automatically learn selected motifs")
ZO_CreateStringId("LOOTSANITIZER_MOTIFLEARN_CONTROL_TOOLTIP"      , "Selected crafting motifs, if unknown to the current character, will be automatically learned.")
ZO_CreateStringId("LOOTSANITIZER_MATERIALMOTIF_DESCRIPTION"       , "Common materials and motifs are items related to the 9 common races available to players. Rare are Barbarian, Old Elven, Daedric, and Primal.")
ZO_CreateStringId("LOOTSANITIZER_MATERIALSTOP_DESCRIPTION"        , "You can prevent style materials from being removed by using Tracking from the addon named ESO Master Recipe List.")

ZO_CreateStringId("LOOTSANITIZER_TRAIT_HEADER"                    , "Trait materials")
ZO_CreateStringId("LOOTSANITIZER_TRAIT_CONTROL"                   , "Delete trait materials")
ZO_CreateStringId("LOOTSANITIZER_TRAIT_CONTROL_TOOLTIP"           , "Only trait materials for armor and weapons will be removed excluding Nirnhoned.")
ZO_CreateStringId("LOOTSANITIZER_TRAIT_DESCRIPTION"               , "Removal of common trait materials for armor and weapons. Materials for Nirnhoned traits are not affected.")

ZO_CreateStringId("LOOTSANITIZER_INGREDIENT_HEADER"               , "Ingredients")
ZO_CreateStringId("LOOTSANITIZER_INGREDIENT_CONTROL"              , "Delete ingredients")
ZO_CreateStringId("LOOTSANITIZER_INGREDIENT_CONTROL_TOOLTIP"      , "Delete ingredients of common rarity.")
ZO_CreateStringId("LOOTSANITIZER_INGREDIENT_DESCRIPTION"          , "You can prevent ingredients from being removed by using Tracking from the addon named ESO Master Recipe List.")

ZO_CreateStringId("LOOTSANITIZER_LOCKPICK_HEADER"                 , "Lockpicks")
ZO_CreateStringId("LOOTSANITIZER_LOCKPICK_CONTROL"                , "Delete extra lockpicks")
ZO_CreateStringId("LOOTSANITIZER_LOCKPICK_SLIDER"                 , "Guarded stock of lockpicks")
ZO_CreateStringId("LOOTSANITIZER_LOCKPICK_SLIDER_TOOLTIP"         , "Stacks are indicated (x200).")
ZO_CreateStringId("LOOTSANITIZER_LOCKPICK_DESCRIPTION"            , "New lockpicks will be removed after the specified number of stacks is accumulated in the inventory.")

ZO_CreateStringId("LOOTSANITIZER_BAIT_HEADER"                     , "Baits")
ZO_CreateStringId("LOOTSANITIZER_BAIT_CONTROL"                    , "Delete extra baits")
ZO_CreateStringId("LOOTSANITIZER_BAIT_SLIDER"                     , "Guarded stock of baits")
ZO_CreateStringId("LOOTSANITIZER_BAIT_SLIDER_TOOLTIP"             , "Stacks are indicated (x200).")
ZO_CreateStringId("LOOTSANITIZER_BAIT_DESCRIPTION"                , "New baits will be removed after the specified number of stacks is accumulated in the inventory.")

ZO_CreateStringId("LOOTSANITIZER_GLYPH_HEADER"                    , "Glyphs")
ZO_CreateStringId("LOOTSANITIZER_GLYPH_CONTROL"                   , "Delete glyphs")
ZO_CreateStringId("LOOTSANITIZER_GLYPH_DESCRIPTION"               , "Removal of armor, weapon and jewelry glyphs of common rarity. Items created by players will not be deleted.")

ZO_CreateStringId("LOOTSANITIZER_RUNE_HEADER"                     , "Runes")
ZO_CreateStringId("LOOTSANITIZER_RUNE_POTENCY_CONTROL"            , "Delete potency runes")
ZO_CreateStringId("LOOTSANITIZER_RUNE_ESSENCE_CONTROL"            , "Delete essence runes")
ZO_CreateStringId("LOOTSANITIZER_RUNE_DAILY_CONTROL"              , "Save runes for daily quest")
ZO_CreateStringId("LOOTSANITIZER_RUNE_DESCRIPTION"                , "All square power runes below level 10 are removed. Triangular essence runes <<1>>, <<2>> and <<3>> will not be removed. Essence runes <<4>>, <<5>> and <<6>> will be saved for daily crafting quests.")

ZO_CreateStringId("LOOTSANITIZER_TRASH_HEADER"                    , "Trash")
ZO_CreateStringId("LOOTSANITIZER_TRASH_CONTROL"                   , "Delete trash items")
ZO_CreateStringId("LOOTSANITIZER_TRASH_DESCRIPTION"               , "Removing items from the Trash category that cost <<1>>. Eg. <<2>>.") -- 1:itemPrice 2:itemLink example

ZO_CreateStringId("LOOTSANITIZER_JUNK_HEADER"                     , GetString("SI_ITEMTYPEDISPLAYCATEGORY", ITEM_TYPE_DISPLAY_CATEGORY_JUNK))
ZO_CreateStringId("LOOTSANITIZER_JUNK_DESCRIPTION"                , "Automatically transfer items to the Junk tab.")

ZO_CreateStringId("LOOTSANITIZER_JUNK_COMMON_CONTROL"             , "Regular Equipment")
ZO_CreateStringId("LOOTSANITIZER_JUNK_COMMON_CONTROL_OFF"         , "Disabled")
ZO_CreateStringId("LOOTSANITIZER_JUNK_COMMON_CONTROL_NORMAL"      , "Only <<1>> quality") -- 1:itemQuality
ZO_CreateStringId("LOOTSANITIZER_JUNK_COMMON_CONTROL_UNCOMMON"    , "<<1>> and lower") -- 1:itemQuality
ZO_CreateStringId("LOOTSANITIZER_JUNK_COMMON_CONTROL_RARE"        , "<<1>> and lower") -- 1:itemQuality
ZO_CreateStringId("LOOTSANITIZER_JUNK_COMMON_CONTROL_EPIC"        , "<<1>> and lower") -- 1:itemQuality
ZO_CreateStringId("LOOTSANITIZER_JUNK_COMMON_CONTROL_TOOLTIP"     , "Equipment without set bonuses with a known trait.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_ORNATE_CONTROL"             , "Ornate Equipment")
ZO_CreateStringId("LOOTSANITIZER_JUNK_ORNATE_CONTROL_TOOLTIP"     , "Equipment with the Ornate trait, intended for sale to merchants.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_MIDDLE_CONTROL"             , "Raw & Materials of average levels")
ZO_CreateStringId("LOOTSANITIZER_JUNK_MIDDLE_CONTROL_TOOLTIP"     , "Raw materials and materials are not of a minimum or maximum level.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_NOCRPT_CONTROL"             , "Non-craft Potions")
ZO_CreateStringId("LOOTSANITIZER_JUNK_NOCRPS_CONTROL"             , "Non-craft Poisons")
ZO_CreateStringId("LOOTSANITIZER_JUNK_NOCRFD_CONTROL"             , "Non-craft Dishes")
ZO_CreateStringId("LOOTSANITIZER_JUNK_NOCRDR_CONTROL"             , "Non-craft Drinks")
ZO_CreateStringId("LOOTSANITIZER_JUNK_SLVNPT_CONTROL"             , "Potion Solvents")
ZO_CreateStringId("LOOTSANITIZER_JUNK_SLVNPT_CONTROL_TOOLTIP"     , "Solvents for potions of any level.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_SLVNPS_CONTROL"             , "Poison Solvents")
ZO_CreateStringId("LOOTSANITIZER_JUNK_SLVNPS_CONTROL_TOOLTIP"     , "Solvents for poisons of any level.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_TRASH_CONTROL"              , "Trash")
ZO_CreateStringId("LOOTSANITIZER_JUNK_TRASH_CONTROL_TOOLTIP"      , "Items from the Trash category, intended for sale to merchants.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_TROVE_CONTROL"              , "Treasures")
ZO_CreateStringId("LOOTSANITIZER_JUNK_TROVE_CONTROL_TOOLTIP"      , "Items from the Treasures category, intended for sale to merchants (including stolen items!!).")
ZO_CreateStringId("LOOTSANITIZER_JUNK_RFISH_CONTROL"              , "Rare Fish")
ZO_CreateStringId("LOOTSANITIZER_JUNK_RFISH_CONTROL_TOOLTIP"      , "Items from the Rare Fish category, intended for sale to merchants.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_BAIT_CONTROL"               , "Baits")
ZO_CreateStringId("LOOTSANITIZER_JUNK_TROPHY_CONTROL"             , "Monster Trophy")
ZO_CreateStringId("LOOTSANITIZER_JUNK_TROPHY_CONTROL_TOOLTIP"     , "Items from the Monster Trophy category, intended for sale to merchants.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_EXCESS_REPAIRKIT_CONTROL"   , "Excess Repair Kits")
ZO_CreateStringId("LOOTSANITIZER_JUNK_EXCESS_REPAIRKIT_TOOLTIP"   , "Excess Repair Kits will be considered those that were received after collecting 1 full stack.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_EXCESS_SOULGEM_CONTROL"     , "Excess Soul Gems")
ZO_CreateStringId("LOOTSANITIZER_JUNK_EXCESS_SOULGEM_TOOLTIP"     , "Excess Soul Gems will be considered those that were received after collecting 1 full stack.")

ZO_CreateStringId("LOOTSANITIZER_JUNK_AUTO_DESCRIPTION"           , "Auto-actions with items from the Junk tab.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_AUTOSELL_CONTROL"           , "Auto Sale")
ZO_CreateStringId("LOOTSANITIZER_JUNK_AUTOSELL_TOOLTIP"           , "Automatic sale of items from the Junk tab to a merchant.")
ZO_CreateStringId("LOOTSANITIZER_JUNK_RECIPE_AUTOLEARN_CONTROL"   , "Auto Learn Recipes")
ZO_CreateStringId("LOOTSANITIZER_JUNK_RECIPE_AUTOLEARN_TOOLTIP"   , "Automatically learn recipes that addon marked as junk.")

ZO_CreateStringId("LOOTSANITIZER_AUTOBURN_HEADER"                 , "Auto-destroying items")
ZO_CreateStringId("LOOTSANITIZER_DISPLAY_AUTOBURN_ACTION_CONTROL" , "Display auto-destroy action")
ZO_CreateStringId("LOOTSANITIZER_DISPLAY_AUTOBURN_ACTION_TOOLTIP" , "Action display in context menu of items.")

ZO_CreateStringId("LOOTSANITIZER_COMMAND_HEADER"                  , "Chat Commands")
ZO_CreateStringId("LOOTSANITIZER_COMMAND_DESCRIPTION"             , "Chat commands to help you interact with the addon.")
ZO_CreateStringId("LOOTSANITIZER_COMMAND_SETTINGS"                , "Open the settings window.")
ZO_CreateStringId("LOOTSANITIZER_COMMAND_SETTINGS_ALT"            , "Open the settings window (fallback option).")
ZO_CreateStringId("LOOTSANITIZER_COMMAND_STATISTICS"              , "Display the results of the addon's work in the chat.")
