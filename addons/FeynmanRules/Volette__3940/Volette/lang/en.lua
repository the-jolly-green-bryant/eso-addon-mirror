local localizationStrings = {
    VOLETTE_YES = "Yes",
    VOLETTE_NO = "No",

    VOLETTE_REQUIRES_RELOADUI = "Requires to reload the UI.",
    VOLETTE_RELOADUI_DIALOG_TITLE = "Reload UI",
    VOLETTE_RELOADUI_DIALOG_DESCRIPTION = "The change will take effect next time you reload the UI. Would you like to do it now?",
        
    VOLETTE_CONFIRM_DIALOG_TITLE = "Confirmation",
    VOLETTE_CONFIRM_DIALOG_DESCRIPTION = "Do you confirm this action?",
    
    VOLETTE_HQ_OWNER_CRAFT = "Crafting HQ's owner",
    VOLETTE_HQ_OWNER_PARSE = "Parsing HQ's owner",
    VOLETTE_HQ_OWNER_MISSING = "You must choose the HQ owner in the settings.",

    VOLETTE_CONTACTS_ENABLE = "Enable Contacts Menu",
    VOLETTE_CONTACTS_ENABLE_TOOLTIP = "Enable to get an additional contacts menu next to your friends list",
    VOLETTE_CONTACTS_ADDED = "<<1>> was added to the contacts.",
    VOLETTE_CONTACTS_REMOVED = "<<1>> was removed from the contacts.",
    VOLETTE_CONTACTS_EXISTS = "<<1>> is already in the contacts.",
    VOLETTE_CONTACTS_WAS_INVITED = "<<1>> was invited.",
    VOLETTE_CONTACTS_WHISPER_BUTTON_TOOLTIP = "Whisper",
    VOLETTE_CONTACTS_INVITE_BUTTON_TOOLTIP = "Invite",
    VOLETTE_CONTACTS_REMOVE_BUTTON_TOOLTIP = "Remove from list",
    VOLETTE_CONTACTS_PIN_BUTTON_TOOLTIP = "Pin",
    VOLETTE_CONTACTS_UNPIN_BUTTON_TOOLTIP = "Unpin",

    VOLETTE_TRAVEL_WAYSHRINE_CHOICE = "Select a house next to a wayshrine",
    VOLETTE_TRAVEL_WAYSHRINE_CHOICE_TOOLTIP = "Attempts to port outside this house when using the command |cffcc00/v-wayshrine|r. If you don't own this house, another will be used.",
    VOLETTE_TRAVEL_AUTO = "Auto",
    VOLETTE_TRAVEL_WAYSHRINE_RECOMMENDATION = "You must own one of the compatible houses. \"<<1>>\" is recommended.",
    VOLETTE_TRAVEL_WAYSHRINE_PORTING = "Porting outside \"<<1>>\".",
    VOLETTE_TRAVEL_SEARCHING_ANOTHER_WAYSHRINE = "You must own \"<<1>>\". Trying to find another house...",

    VOLETTE_SAVINGS_SUBMENU_TITLE = "Savings",
    VOLETTE_SAVINGS_SUBMENU_DESCRIPTION = "Don't let your wealth sit on alts! Automatically deposit your currencies into the bank when they start to accumulate.",
    VOLETTE_SAVINGS_ENABLE = "|c66a3ffEnable|r",
    VOLETTE_SAVINGS_MINIMUM_AMOUNT = "Minimum amount",
    VOLETTE_SAVINGS_MAXIMUM_AMOUNT = "Maximum amount",
    VOLETTE_SAVINGS_MINIMUM_AMOUNT_TOOLTIP = "Your characters will always have at least this amount in their bags.",
    VOLETTE_SAVINGS_MAXIMUM_AMOUNT_TOOLTIP = "Your characters will never keep more than this amount in their bags.",
    VOLETTE_SAVINGS_ENABLE_FOR_DESCRIPTION = "Enable for the following characters:",
    VOLETTE_SAVINGS_DEPOSIT = "Deposit: <<1>>",
    VOLETTE_SAVINGS_WITHDRAWAL = "Withdrawal: <<1>>",
    VOLETTE_SAVINGS_NOT_ENOUGH_CURRENCIES = "Could not find <<1>> in the bank.",

    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HOME = "Port to primary residence",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HQ_CRAFT = "Port to crafting HQ",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HQ_PARSE = "Port to parsing HQ",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_WAYSHRINE = "Port to wayshrine",

}

for stringId, stringValue in pairs(localizationStrings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
