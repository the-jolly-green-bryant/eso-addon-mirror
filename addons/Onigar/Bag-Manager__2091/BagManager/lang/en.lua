---------------------------------------
-- English localization for Bag Manager
-- Author  : Onigar
-- Version : 0.1.0
---------------------------------------

-- all language convertable strings
local strings = {

	BM_ADDON_LONG_NAME					= "Bag Manager",
	BM_ADDON_DESCRIPTION				= "Automated Management of Character Bag Items", 
	
	BM_CHAR_VAR_FIXED					= "Fixed",
	BM_CHAR_VAR_EMPTY					= "Empty",
	BM_CHAR_VAR_NONE					= "None",

	BM_ONLY_PRE							= "[BM] Only ",
	BM_WITHDREW_PRE						= "[BM] Withdrew: ", 
	BM_DEPOSITED_PRE					= "[BM] Deposited: ", 

	BM_SOUL_GEMS_POST					= " Soul Gems",
	BM_SOUL_GEMS_AVAIL_POST				= " Soul Gems available in the bank",
	BM_SOUL_GEMS_EMPTY_POST				= " Soul Gems (Empty)",
	BM_SOUL_GEMS_EMPTY_AVAIL_POST		= " Soul Gems (Empty) available in the bank",

	BM_MAN_TYPE_TIP						= "Select the Management Type",
	BM_MAN_TYPE_POST					= " Management Type", 
	BM_FIXED_AMOUNT_POST				= " Fixed Amount",

	BM_SOUL_GEMS_TITLE_PRE				= "Soul Gems:",
	BM_SOUL_GEMS_FIXED_AMOUNT_TIP		= "Enter number of Filled Soul Gems to keep in your Bag",
	BM_SOUL_GEMS_EMPTY_TITLE_PRE		= "Empty Soul Gems:",
	BM_SOUL_GEMS_EMPTY_FIXED_AMOUNT_TIP	= "Enter number of Empty Soul Gems to keep in your Bag",

	BM_MAN_TYPE_OPTIONS					= "Management Type Options",
	BM_MAN_TYPE_FIXED_DESC				= " = Will keep preset amount in Bag",
	BM_MAN_TYPE_EMPTY_DESC				= " = All in Bag to Bank",
	BM_MAN_TYPE_NONE_DESC				= " = No Management",
	
	BM_ACCOUNT_WIDE_TITLE				= "Use Account Wide Settings",
	BM_ACCOUNT_WIDE_TIP					= "When set from [OFF] to [ON] it loads the Account Wide Settings and saves the Settings for all Characters, the reverse works the same way",

	BM_SHOW_DEBUG_MESSAGES				= "Show Debug Messages",
	BM_SHOW_DEBUG_MESSAGES_TIP			= "Useful in addon development only, not intended for normal use",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end