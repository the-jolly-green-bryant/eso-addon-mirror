local s = {
    -- Slot headers (naprawione)
    HT_SETTINGS_P1 = "1. Priority Slot",
    HT_SETTINGS_P2 = "2. Priority Slot",
    HT_SETTINGS_P3 = "3. Priority Slot",
    HT_SETTINGS_ASSIGN = "Assign Character",
    HT_SETTINGS_NONE = "None selected",
    
    -- Priority dropdown options
    HT_SETTINGS_PRIORITY_TRUE = "Use craft priority (ignores price limit)",
    HT_SETTINGS_PRIORITY_FALSE = "Use global price limit",
    HT_SETTINGS_PRIORITY_MOTIF = "Motifs",
    HT_SETTINGS_PRIORITY_RECIPE = "Recipes",
    HT_SETTINGS_PRIORITY_PLAN = "Plans",
    HT_SETTINGS_PRIORITY_TOOLTIP = "|cFFFF00Priority mode:|r 'Use craft priority' = always first chance, ignores price limit. 'Use global price limit' = first chance but only if price ≤ limit.",
    
    -- Trader section
    HT_SETTINGS_TRADER_SECTION = "4. Trader (Sell leftovers)",
    HT_SETTINGS_TRADER = "Assign Trader",
    HT_SETTINGS_TRADER_TOOLTIP = "|cFFFF00Trader mode:|r This character will withdraw and SELL any item that no other character wants (all priority characters already know it, or it's too expensive for standard characters).",
    
    -- Global settings
    HT_SETTINGS_GLOBAL = "Global Settings",
    HT_SETTINGS_STYLE = "Autolearn Outfit Styles",
    HT_SETTINGS_STYLE_TOOLTIP = "|cFFFF00Outfit Styles:|r Automatically learn any outfit style page (account-wide).",
    HT_SETTINGS_BLOCK = "Block Unbound Learning & Withdrawal",
    HT_SETTINGS_BLOCK_TOOLTIP = "|cFFFF00Unbound Scripts:|r Prevent automatic learning and withdrawal of unbound scripts. Only Trader can withdraw them for sale.",
    HT_SETTINGS_MIN_SCRIPTS = "Min. scripts per type to keep in bank",
    HT_SETTINGS_MIN_SCRIPTS_TOOLTIP = "|cFFFF00Scripts:|r Any script above this amount will be automatically sold to a vendor (price is fixed).",
    
    -- Price limits
    HT_SETTINGS_LIMIT_SEC = "Shared Price Limits (Gold)",
    HT_SETTINGS_L_MOTIF = "Limit: Motifs",
    HT_SETTINGS_L_RECIPE = "Limit: Recipes",
    HT_SETTINGS_L_PLAN = "Limit: Plans",
}
for id, v in pairs(s) do 
    ZO_CreateStringId(id, v) 
end