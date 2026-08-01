local currencyChangeReasons =
{
    [CURRENCY_CHANGE_REASON_ABILITY_UPGRADE_PURCHASE] = "Unknown (ABILITY_UPGRADE_PURCHASE)",
    [CURRENCY_CHANGE_REASON_ACHIEVEMENT]              = "Unknown (ACHIEVEMENT)",
    [CURRENCY_CHANGE_REASON_ACTION]                   = "Unknown (ACTION)",
    [CURRENCY_CHANGE_REASON_BAGSPACE]                 = "Bag upgrade",
    [CURRENCY_CHANGE_REASON_BANKSPACE]                = "Bank upgrade",
    [CURRENCY_CHANGE_REASON_BANK_DEPOSIT]             = "Deposit",
    [CURRENCY_CHANGE_REASON_BANK_FEE]                 = "Unknown (BANK_FEE)",
    [CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL]          = "Withdrawal",
    [CURRENCY_CHANGE_REASON_BATTLEGROUND]             = "Unknown (BATTLEGROUND)",
    [CURRENCY_CHANGE_REASON_BOUNTY_CONFISCATED]       = "Bounty",
    [CURRENCY_CHANGE_REASON_BOUNTY_PAID_FENCE]        = "Bounty",
    [CURRENCY_CHANGE_REASON_BOUNTY_PAID_GUARD]        = "Bounty",
    [CURRENCY_CHANGE_REASON_BUYBACK]                  = "Buyback",
    [CURRENCY_CHANGE_REASON_CASH_ON_DELIVERY]         = "Cash on delivery",
    [CURRENCY_CHANGE_REASON_COMMAND]                  = "Unknown (COMMAND)",
    [CURRENCY_CHANGE_REASON_CONSUME_FOOD_DRINK]       = "Unknown (CONSUME_FOOD_DRINK)",
    [CURRENCY_CHANGE_REASON_CONSUME_POTION]           = "Unknown (CONSUME_POTION)",
    [CURRENCY_CHANGE_REASON_CONVERSATION]             = "Dialogue option",
    [CURRENCY_CHANGE_REASON_CRAFT]                    = "Outfit Station",
    [CURRENCY_CHANGE_REASON_DEATH]                    = "Unknown (DEATH)",
    [CURRENCY_CHANGE_REASON_DECONSTRUCT]              = "Unknown (DECONSTRUCT)",
    [CURRENCY_CHANGE_REASON_EDIT_GUILD_HERALDRY]      = "Guild heraldry edit",
    [CURRENCY_CHANGE_REASON_FEED_MOUNT]               = "Mount upgrade",
    [CURRENCY_CHANGE_REASON_GUILD_BANK_DEPOSIT]       = "Guild deposit",
    [CURRENCY_CHANGE_REASON_GUILD_BANK_WITHDRAWAL]    = "Guild withdrawal",
    [CURRENCY_CHANGE_REASON_GUILD_FORWARD_CAMP]       = "Unknown (GUILD_FORWARD_CAMP)",
--    [CURRENCY_CHANGE_REASON_GUILD_STANDARD]           = "Unknown (GUILD_STANDARD)", --P5YCH3 - This enum was removed in update 36 - Firesong.
    [CURRENCY_CHANGE_REASON_GUILD_TABARD]             = "Unknown (GUILD_TABARD)",
    [CURRENCY_CHANGE_REASON_HARVEST_REAGENT]          = "Unknown (HARVEST_REAGENT)",
--    [CURRENCY_CHANGE_REASON_HOOKPOINT_STORE]          = "Unknown (HOOKPOINT_STORE)", --P5YCH3 --This enum was removed prior to update 28.
    [CURRENCY_CHANGE_REASON_JUMP_FAILURE_REFUND]      = "Unknown (JUMP_FAILURE_REFUND)",
    [CURRENCY_CHANGE_REASON_KEEP_REPAIR]              = "Keep Repair",
--    [CURRENCY_CHANGE_REASON_KEEP_REWARD]              = "Keep Reward", --P5YCH3 --This enum was replaced in update 19 - Wolfhunter.
    [CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD]    = "Keep Reward",
    [CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD]    = "Keep Reward",
    [CURRENCY_CHANGE_REASON_KEEP_UPGRADE]             = "Keep Upgrade",
    [CURRENCY_CHANGE_REASON_KILL]                     = "Kill",
    [CURRENCY_CHANGE_REASON_LOOT]                     = "Loot",
    [CURRENCY_CHANGE_REASON_LOOT_STOLEN]              = "Theft",
    [CURRENCY_CHANGE_REASON_MAIL]                     = "Mail attachment",
    [CURRENCY_CHANGE_REASON_MEDAL]                    = "Unknown (MEDAL)",
    [CURRENCY_CHANGE_REASON_PICKPOCKET]               = "Pickpocketing",
    [CURRENCY_CHANGE_REASON_PLAYER_INIT]              = "Unknown (PLAYER_INIT)",
    [CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER]        = "Unknown (PVP_KILL_TRANSFER)",
    [CURRENCY_CHANGE_REASON_PVP_RESURRECT]            = "Unknown (PVP_RESURRECT)",
    [CURRENCY_CHANGE_REASON_QUESTREWARD]              = "Quest reward",
    [CURRENCY_CHANGE_REASON_RECIPE]                   = "Unknown (RECIPE)",
    [CURRENCY_CHANGE_REASON_REFORGE]                  = "Unknown (REFORGE)",
    [CURRENCY_CHANGE_REASON_RESEARCH_TRAIT]           = "Unknown (RESEARCH_TRAIT)",
    [CURRENCY_CHANGE_REASON_RESPEC_ATTRIBUTES]        = "Attribute respec",
    [CURRENCY_CHANGE_REASON_RESPEC_CHAMPION]          = "Champion points respec",
    [CURRENCY_CHANGE_REASON_RESPEC_MORPHS]            = "Morph respec",
    [CURRENCY_CHANGE_REASON_RESPEC_SKILLS]            = "Skill respec",
    [CURRENCY_CHANGE_REASON_REWARD]                   = "Daily Reward",
    [CURRENCY_CHANGE_REASON_SELL_STOLEN]              = "Fence",
    [CURRENCY_CHANGE_REASON_SOULWEARY]                = "Unknown (SOULWEARY)",
    [CURRENCY_CHANGE_REASON_SOUL_HEAL]                = "Unknown (SOUL_HEAL)",
    [CURRENCY_CHANGE_REASON_STABLESPACE]              = "Unknown (STABLESPACE)",
    [CURRENCY_CHANGE_REASON_STUCK]                    = "Stuck",
    [CURRENCY_CHANGE_REASON_TRADE]                    = "Trade",
    [CURRENCY_CHANGE_REASON_TRADINGHOUSE_LISTING]     = "Guild store listing",
    [CURRENCY_CHANGE_REASON_TRADINGHOUSE_PURCHASE]    = "Guild store purchase",
    [CURRENCY_CHANGE_REASON_TRADINGHOUSE_REFUND]      = "Guild store refund",
    [CURRENCY_CHANGE_REASON_TRAIT_REVEAL]             = "Unknown (TRAIT_REVEAL)",
    [CURRENCY_CHANGE_REASON_TRAVEL_GRAVEYARD]         = "Wayshrine",
    [CURRENCY_CHANGE_REASON_VENDOR]                   = "Vendor",
    [CURRENCY_CHANGE_REASON_VENDOR_LAUNDER]           = "Laundering",
    [CURRENCY_CHANGE_REASON_VENDOR_REPAIR]            = "Equipment repairs",
}

for i, value in pairs(currencyChangeReasons) do
    ZO_CreateStringId("SI_GOLD_LEDGER_REASON"..i, value)
end

ZO_CreateStringId("SI_BINDING_NAME_LEDGER_TOGGLE"        , "Open/close Ledger")
ZO_CreateStringId("SI_GOLD_LEDGER_EMPTY"                 , "No record found for the selected criteria.")
ZO_CreateStringId("SI_GOLD_LEDGER_HEADER_TIMESTAMP"      , "Time")
ZO_CreateStringId("SI_GOLD_LEDGER_HEADER_CHARACTER"      , "Character")
ZO_CreateStringId("SI_GOLD_LEDGER_HEADER_REASON"         , "Reason")
ZO_CreateStringId("SI_GOLD_LEDGER_HEADER_VARIATION"      , "Variation")
ZO_CreateStringId("SI_GOLD_LEDGER_HEADER_BALANCE"        , "Balance")
ZO_CreateStringId("SI_GOLD_LEDGER_PERIOD_1_HOUR"         , "Last 1 hour")
ZO_CreateStringId("SI_GOLD_LEDGER_PERIOD_1_DAY"          , "Last 1 day")
ZO_CreateStringId("SI_GOLD_LEDGER_PERIOD_1_WEEK"         , "Last 1 week")
ZO_CreateStringId("SI_GOLD_LEDGER_PERIOD_1_MONTH"        , "Last 1 month")
ZO_CreateStringId("SI_GOLD_LEDGER_PERIOD_1_QUARTER"      , "Last 1 quarter")
ZO_CreateStringId("SI_GOLD_LEDGER_PERIOD_1_YEAR"         , "Last 1 year")
ZO_CreateStringId("SI_GOLD_LEDGER_ALL_CHARACTERS"        , "Any character")
ZO_CreateStringId("SI_GOLD_LEDGER_BANK_CHARACTER"        , "Bank")
ZO_CreateStringId("SI_GOLD_LEDGER_MERGE_LABEL"           , "Merge Similar")
ZO_CreateStringId("SI_GOLD_LEDGER_SEARCH_LABEL"          , "Search by reason.")
ZO_CreateStringId("SI_GOLD_LEDGER_SUMMARY1"              , "Balance changed by <<1>> in the <<z:2>>.")
ZO_CreateStringId("SI_GOLD_LEDGER_SUMMARY2"              , "You profited most from <<1>> (<<2>>) and spent most on <<3>> (<<4>>).")
ZO_CreateStringId("SI_GOLD_LEDGER_SUMMARY2_EXPENSE"      , "You spent most on <<1>> (<<2>>).")
ZO_CreateStringId("SI_GOLD_LEDGER_SUMMARY2_PROFIT"       , "You profited most from <<1>> (<<2>>).")
ZO_CreateStringId("SI_GOLD_LEDGER_SUMMARY_EMPTY"         , "")
------------------------------------------------
--P5YCH3 - New translation values.
------------------------------------------------
ZO_CreateStringId("SI_GOLD_LEDGER_MAIN_WINDOW_INVENTORY_BUTTON"         , "Inventory")
ZO_CreateStringId("SI_GOLD_LEDGER_MAIN_WINDOW_INVENTORY_BUTTON_TOOLTIP" , "• Left Click:\nOpen your inventory menu.")
ZO_CreateStringId("SI_GOLD_LEDGER_MAIN_WINDOW_SETTINGS_BUTTON"          , "Settings")
ZO_CreateStringId("SI_GOLD_LEDGER_MAIN_WINDOW_SETTINGS_BUTTON_TOOLTIP"  , "• Left Click:\nOpen the addon settings.")

ZO_CreateStringId("SI_GOLD_LEDGER_TITLE"                          , "Gold Ledger")
ZO_CreateStringId("SI_GOLD_LEDGER_SETTINGS_HEADER"                , "Settings")
ZO_CreateStringId("SI_GOLD_LEDGER_VIEW_LEDGER_BUTTON"             , "View Gold Ledger")
ZO_CreateStringId("SI_GOLD_LEDGER_VIEW_LEDGER_BUTTON_TOOLTIP"     , "Track your money across sessions. View a convenient overview detailing how your gold is collected or spent.")

ZO_CreateStringId("SI_GOLD_LEDGER_VIEW_INVENTORY_BUTTON"          , "View Inventory")
ZO_CreateStringId("SI_GOLD_LEDGER_VIEW_INVENTORY_BUTTON_TOOLTIP"  , "Open your inventory menu.")
ZO_CreateStringId("SI_GOLD_LEDGER_SHOW_INVENTORY_OPTION"          , "Show Inventory Icon")
ZO_CreateStringId("SI_GOLD_LEDGER_SHOW_INVENTORY_OPTION_TOOLTIP"  , "Show the Gold Ledger icon within the inventory menu.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_HIDE_WINDOW_OPTION"      , "Banker Button Hides Main Window")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_HIDE_WINDOW_TOOLTIP"     , "When you use the banker button the main display will be hidden.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_ASSISTANT"               , "Banker Assistant")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_ASSISTANT_TOOLTIP"       , "Select which assistant will be used when the banker button is clicked.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_ASSISTANT"             , "Merchant Assistant")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_ASSISTANT_TOOLTIP"     , "Select which assistant will be used when the merchant button is clicked.")
ZO_CreateStringId("SI_GOLD_LEDGER_ICON_TOOLTIP"                   , ZO_HIGHLIGHT_TEXT:Colorize("Gold Ledger\n---------------") .. "\n• Left Click:\nDrag and drop to move this window.\n\n• Middle Click:\nOpen the addon settings menu.\n\n• Right Click:\nView your inventory menu.")
ZO_CreateStringId("SI_GOLD_LEDGER_INVENTORY_ICON_TOOLTIP"         , ZO_HIGHLIGHT_TEXT:Colorize("Gold Ledger\n---------------") .. "\n• Left Click:\nOpen Gold Ledger.\n\n• Middle Click:\nOpen the addon settings menu.\n\n• Right Click:\nDrag and drop to reposition the Gold Ledger icon.")
ZO_CreateStringId("SI_GOLD_LEDGER_CURRENT_BANK_BALANCE_TOOLTIP"   , "Current bank balance.\n\n• Left Click:\nToggle your personal banker assistant.")
ZO_CreateStringId("SI_GOLD_LEDGER_CURRENT_BAG_BALANCE_TOOLTIP"    , "Current bag balance.\n\n• Left Click:\nOpen your inventory menu.\n\n• Right Click:\nSpawn your personal merchant assistant.\n\n• Middle Click:\nSpawn your personal fence assistant.")
ZO_CreateStringId("SI_GOLD_LEDGER_CONSOLE_COMMANDS"               , "Console Commands")
ZO_CreateStringId("SI_GOLD_LEDGER_COMMAND_GOLD_LEDGER"            , "Toggles the Gold Ledger display window.")
ZO_CreateStringId("SI_GOLD_LEDGER_COMMAND_GOLD_LEDGER_SHORT"      , "Toggles the Gold Ledger display window.")
ZO_CreateStringId("SI_GOLD_LEDGER_COMMAND_LEDGER"                 , "Toggles the Gold Ledger display window.")
ZO_CreateStringId("SI_GOLD_LEDGER_COMMAND_LEDGER_SHORT"           , "Toggles the Gold Ledger display window.")
ZO_CreateStringId("SI_GOLD_LEDGER_COMMAND_LEDGER_SETTINGS"        , "Opens the addon settings panel (this menu).")
ZO_CreateStringId("SI_GOLD_FUNCTIONS_HEADER"                      , "Gold Ledger - Functions")
ZO_CreateStringId("SI_GOLD_SETTINGS_HEADER"                       , "Gold Ledger - Settings (This Menu)")

--Bankers
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_TOGGLED_TYTHIS"          , "Tythis Andromo the Banker has been toggled.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_UNAVAILABLE_TYTHIS"      , "Tythis Andromo the Banker is not unlocked. Cannot toggle.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_ALTERNATIVE_TYTHIS"      , "Tythis Andromo the Banker has been toggled instead.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_TOGGLED_EZABI"           , "Ezabi the Banker has been toggled.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_UNAVAILABLE_EZABI"       , "Ezabi the Banker is not unlocked. Cannot toggle.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_ALTERNATIVE_EZABI"       , "Ezabi the Banker has been toggled instead.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_TOGGLED_JANGLEPLUME"     , "Baron Jangleplume the Banker has been toggled.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_UNAVAILABLE_JANGLEPLUME" , "Baron Jangleplume the Banker is not unlocked. Cannot toggle.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_ALTERNATIVE_JANGLEPLUME" , "Baron Jangleplume the Banker has been toggled instead.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_TOGGLED_FACTOTUM"        , "Factotum Property Steward has been toggled.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_UNAVAILABLE_FACTOTUM"    , "Factotum Property Steward is not unlocked. Cannot toggle.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_ALTERNATIVE_FACTOTUM"    , "Factotum Property Steward has been toggled instead.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_TOGGLED_PYROCLAST"       , "Pyroclast, Infernace Conservator has been toggled.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_UNAVAILABLE_PYROCLAST"   , "Pyroclast, Infernace Conservator is not unlocked. Cannot toggle.")
ZO_CreateStringId("SI_GOLD_LEDGER_BANKER_ALTERNATIVE_PYROCLAST"   , "Pyroclast, Infernace Conservator has been toggled instead.")

--Merchants
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_TOGGLED_NUZHIMEH"          , "Nuzhimeh the Merchant has been toggled.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_UNAVAILABLE_NUZHIMEH"      , "Nuzhimeh the Merchant is not unlocked. Cannot toggle.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_ALTERNATIVE_NUZHIMEH"      , "Nuzhimeh the Merchant has been toggled instead.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_TOGGLED_FEZEZ"             , "Fezez the Merchant has been toggled.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_UNAVAILABLE_FEZEZ"         , "Fezez the Merchant is not unlocked. Cannot toggle.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_ALTERNATIVE_FEZEZ"         , "Fezez the Merchant has been toggled instead.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_TOGGLED_FACTOTEM"          , "Factotum Commerce Delegate has been toggled.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_UNAVAILABLE_FACTOTEM"      , "Factotum Commerce Delegate is not unlocked. Cannot toggle.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_ALTERNATIVE_FACTOTEM"      , "Factotum Commerce Delegate has been toggled instead.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_TOGGLED_PEDDLER"           , "Peddler of Prizes, the Merchant has been toggled.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_UNAVAILABLE_PEDDLER"       , "Peddler of Prizes, the Merchant is not unlocked. Cannot toggle.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_ALTERNATIVE_PEDDLER"       , "Peddler of Prizes, the Merchant has been toggled instead.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_TOGGLED_HOARFROST"         , "Hoarfrost, Takubar Trader has been toggled.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_UNAVAILABLE_HOARFROST"     , "Hoarfrost, Takubar Trader is not unlocked. Cannot toggle.")
ZO_CreateStringId("SI_GOLD_LEDGER_MERCHANT_ALTERNATIVE_HOARFROST"     , "Hoarfrost, Takubar Trader has been toggled instead.")

--Fences
ZO_CreateStringId("SI_GOLD_LEDGER_FENCE_TOGGLED_PIRHARRI"          , "Pirharri the Smuggler has been toggled.")
ZO_CreateStringId("SI_GOLD_LEDGER_FENCE_UNAVAILABLE_PIRHARRI"      , "Pirharri the Smuggler is not unlocked. Cannot toggle.")

--ZO_CreateStringId("SI_GOLD_LEDGER_WIP"                            , "Placeholder text.")
------------------------------------------------