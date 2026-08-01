--------------------------------------------
-- English localization for Currency Manager
-- Author  : Onigar
-- Version : 1.15.0
--------------------------------------------

-- all language convertable strings
local strings = {

	CM_TEST_TEXT					= " Test AaBbCc",
	CM_TEST_TEXT_LONG				= " Test AaBbCc 12345 67890 AaBbCc",

	CM_ADDON_LONG_NAME				= "Currency Manager",
	
	CM_CHAR_VAR_FIXED				= "Fixed",
	CM_CHAR_VAR_EMPTY				= "Empty",
	CM_CHAR_VAR_NONE				= "None",

	CM_PRE_ONLY						= "[CM] Only ",
	CM_PRE_WITHDREW					= "[CM] Withdrew: ",
	CM_PRE_DEPOSITED				= "[CM] Deposited: ",
	CM_POST_GOLD					= " Gold",
	CM_POST_GOLD_AVAILABLE			= " Gold available in your bank",
	CM_POST_TEL_VAR					= " Tel Var Stones",
	CM_POST_TEL_VAR_AVAILABLE		= " Tel Var Stones available in your bank",
	CM_POST_AP						= " Alliance Points",
	CM_POST_AP_AVAILABLE			= " Alliance Points available in your bank",
	CM_POST_WRIT_VOUCHERS			= " Writ Vouchers",
	CM_POST_WRIT_VOUCH_AVAILABLE	= " Writ Vouchers available in your bank",
	
	CM_INTO_YOUR_BANK				= " into your Bank",
	CM_FROM_YOUR_BANK				= " from your Bank",

	CM_ADDON_DESCRIPTION			= "Automated Management of Character Bankable Currencies",

	CM_MANAGEMENT_TYPE_TIP			= "Select the Management Type",
	CM_POST_MANAGEMENT_TYPE			= " Management Type",
	CM_POST_FIXED_AMOUNT			= " Fixed Amount",

	CM_PRE_GOLD_TITLE				= "Gold:",
	CM_GOLD_FIXED_AMOUNT_TIP		= "Enter the Gold to keep in your Bag",

	CM_PRE_TEL_VAR_TITLE			= "Tel Var Stones:",
	CM_TEL_VAR_FIXED_AMOUNT_TIP		= "Enter the Tel Var Stones to keep in your Bag",
	CM_TEL_VAR_MULTIPLIER_NOTE		= "Note: Stone Multiplier Amounts are, 100=x2, 1,000=x3, 10,000=x4",

	CM_AP_TITLE						= "Alliance Points:",
	CM_AP_FIXED_AMOUNT_TIP			= "Enter the Alliance Points to keep in your Bag",

	CM_WRIT_VOUCHER_TITLE			= "Writ Vouchers:",
	CM_WRIT_FIXED_AMOUNT_TIP		= "Enter the Writ Vouchers to keep in your Bag",

	CM_MANAGEMENT_TYPE_OPTIONS		= "Management Type Options",
	CM_MAN_TYPE_FIXED_DESC			= " = Will keep preset amount in Bag",
	CM_MAN_TYPE_EMPTY_DESC			= " = All in Bag to Bank",
	CM_MAN_TYPE_NONE_DESC			= " = No Management (Default)",
	
	CM_ACCOUNT_WIDE_TITLE			= "Use Account Wide Settings",
	CM_ACCOUNT_WIDE_TIP				= "When changed you need to use the ReloadUI button to load the saved settings",

}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end