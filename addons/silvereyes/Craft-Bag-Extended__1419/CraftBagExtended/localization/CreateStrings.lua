for stringId, value in pairs(CRAFTBAGEXTENDED_STRINGS) do
    local stringValue
    if type(value) == "table" then
        for i=2,#value do
            if type(value[i]) == "string" then
                value[i] = _G[value[i]]
            end
            value[i] = GetString(value[i])
        end
        stringValue = zo_strformat(unpack(value))
    else
        stringValue = value
    end
    ZO_CreateStringId(stringId, stringValue)
end
CRAFTBAGEXTENDED_STRINGS = nil

-- Addon title
ZO_CreateStringId("SI_CBE", "|c99CCEFCraft Bag Extended|r")

-- Combine the built-in "Deposit" and "Quantity" terms,
ZO_CreateStringId("SI_CBE_CRAFTBAG_BANK_DEPOSIT", 
    GetString(SI_ITEM_ACTION_BANK_DEPOSIT)
    ..GetString(SI_CBE_WORD_BREAK)
    ..GetString(SI_TRADING_HOUSE_POSTING_QUANTITY))

ZO_CreateStringId("SI_CBE_CRAFTBAG_BANK_WITHDRAW", 
    GetString(SI_ITEM_ACTION_BANK_WITHDRAW)
    ..GetString(SI_CBE_WORD_BREAK)
    ..GetString(SI_TRADING_HOUSE_POSTING_QUANTITY))
    
-- Combine the built-in "Add" and "Quantity" terms
ZO_CreateStringId("SI_CBE_CRAFTBAG_MAIL_ATTACH", 
    GetString(SI_GAMEPAD_MAIL_SEND_ATTACH_ITEM)
    ..GetString(SI_CBE_WORD_BREAK)
    ..GetString(SI_TRADING_HOUSE_POSTING_QUANTITY))

-- Combine the built-in "Retrieve" and "Quantity" terms,
ZO_CreateStringId("SI_CBE_CRAFTBAG_RETRIEVE_QUANTITY", 
    GetString(SI_ITEM_ACTION_REMOVE_ITEMS_FROM_CRAFT_BAG)
    ..GetString(SI_CBE_WORD_BREAK)
    ..GetString(SI_TRADING_HOUSE_POSTING_QUANTITY))

-- Combine the built-in "Stow" and "Quantity" terms,
ZO_CreateStringId("SI_CBE_CRAFTBAG_STOW_QUANTITY", 
    GetString(SI_ITEM_ACTION_ADD_ITEMS_TO_CRAFT_BAG)
    ..GetString(SI_CBE_WORD_BREAK)
    ..GetString(SI_TRADING_HOUSE_POSTING_QUANTITY))
    
-- Combine the built-in "Add" and "Quantity" terms
ZO_CreateStringId("SI_CBE_CRAFTBAG_TRADE_ADD", 
    GetString(SI_GAMEPAD_TRADE_ADD)
    ..GetString(SI_CBE_WORD_BREAK)
    ..GetString(SI_TRADING_HOUSE_POSTING_QUANTITY))

-- Combine the built-in "Sell" and "Quantity" terms,
ZO_CreateStringId("SI_CBE_CRAFTBAG_SELL_QUANTITY", 
    GetString(SI_ITEM_ACTION_SELL)
    ..GetString(SI_CBE_WORD_BREAK)
    ..GetString(SI_TRADING_HOUSE_POSTING_QUANTITY))

-- Item cannot be stored in the craft bag
local guildBankString = GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER)
local craftBagString = GetString(SI_GAMEPAD_INVENTORY_CRAFT_BAG_HEADER)
local lowerGuildBankString = LocaleAwareToLower(guildBankString)
local lowerCraftBagString = LocaleAwareToLower(craftBagString)
local invalidItemString = string.gsub(GetString(SI_GUILDBANKRESULT4), guildBankString, craftBagString)
invalidItemString = string.gsub(invalidItemString, lowerGuildBankString, lowerCraftBagString)
ZO_CreateStringId("SI_CBE_CRAFTBAG_ITEM_INVALID", invalidItemString)