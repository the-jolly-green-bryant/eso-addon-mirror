local strings = {
	BANKIR_MENU_PROFILES = "Profiles",
	BANKIR_MENU_PROFILE_SELECT = "Select profile",
	BANKIR_MENU_PROFILE_SELECT_DESC = "Select settings profile for your current character",
	BANKIR_MENU_PROFILE_EDIT_NAME = "Edit profile name",
	BANKIR_MENU_PROFILE_NEW = "New profile",
	BANKIR_MENU_PROFILE_COPY = "Copy profile",
	BANKIR_MENU_PROFILE_COPY_DESC = "Will create a new profile that is a copy of the current profile",
	BANKIR_MENU_PROFILE_DELETE = "Delete profile",
	BANKIR_MENU_PROFILE_DELETE_WARNING = "This will completely remove the currently selected profile!",
	BANKIR_MENU_MOVE_LOCKED_ITEMS = "Move locked items",
	BANKIR_MENU_MOVE_LOCKED_ITEMS_DESC = "Allow moving items locked by the player",
	BANKIR_MENU_SHOW_DEPOSIT_NOT_ALLOWED_MESSAGE = "Show 'Deposit not allowed' message",
	BANKIR_MENU_SHOW_DEPOSIT_NOT_ALLOWED_MESSAGE_DESC = "Print in chat if item deposit failed",
	BANKIR_MENU_BANK_SELECT = "Bank bag to set up",
	BANKIR_MENU_BANK_SELECT_DESC = "Select which bank bag to set up.\nThe list contains bank, all unlocked house coffers, and all your guild banks.\nThe settings below will apply to the bank bag selected here",
	BANKIR_MENU_CURRENCY_DEPOSIT = "Deposit <<1>> <<2>>",
	BANKIR_MENU_CURRENCY_DEPOSIT_DESC = "Deposit the currency exceeding the slider value into the bank",
	BANKIR_MENU_CURRENCY_WITHDRAW = "Withdraw <<1>> <<2>>",
	BANKIR_MENU_CURRENCY_WITHDRAW_DESC = "Withdraw currency from the bank if character has less than the slider value",
	BANKIR_MENU_CURRENCY_AMOUNT = "Amount to keep on character",
	BANKIR_MENU_CURRENCY_AMOUNT_DESC = "Select how much currency to keep on character",
	BANKIR_MENU_MAX_STACKS_TO_PUSH = "Max stacks in bank",
	BANKIR_MENU_MAX_STACKS_DESC = "Maximum number of full stacks allowed in the bank bag.\nIf bank has less stacks, Bankir will try to fulfill them from the inventory",
	BANKIR_MENU_MIN_ITEMS_TO_PULL = "Min items in bag",
	BANKIR_MENU_MIN_ITEMS_DESC = "Minimal number of items to keep at character's inventory.\nIf character has less, Bankir will try to get them from bank, when available",
	BANKIR_MENU_QUALITY_SELECT = "Min quality",
	BANKIR_MENU_QUALITY_SELECT_DESC = "The rule will apply to items with quality equal to or higher than the selected level",
	
	BANKIR_CHAT_REQUIRED_FOR_QUESTS = "<<1>> x<<2>> required for quests",
	BANKIR_CHAT_NO_FREE_SPACE = "No free space left in <<1>> for <<2>>.",
}

-- Create the string values, so other languages can add new versions
for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end