--------------------------------------------
-- English localization for Currency Manager
-- Author  : CaseyOmah
-- Version : 0.1.0
--------------------------------------------

-- all language convertable strings
local strings = {

	CM_ADDON_LONG_NAME				= "Currency Manager",
	
	CM_CHAR_VAR_EMPTY				= "Dump",
	CM_CHAR_VAR_FIXED				= "Managed",
	CM_CHAR_VAR_NONE				= "None",

	CM_PRE_DEPOSITED				= "[CM] Deposited: ",
	CM_PRE_ONLY						= "[CM] Only ",
	CM_PRE_WITHDREW					= "[CM] Withdrew: ",

	CM_AP							= "Alliance Points",
	CM_GOLD							= "Gold",
	CM_TEL_VAR						= "Tel Var Stones",
	CM_WRIT_VOUCHER					= "Writ Vouchers",
	
	CM_POST_AVAIL					= " available in your bank",
	CM_POST_WRIT_VOUCHERS			= " Writ Vouchers",
	
	CM_INTO_YOUR_BANK				= " into your Bank",
	CM_FROM_YOUR_BANK				= " from your Bank",

	CM_ADDON_DESCRIPTION			= "Automated Management of Character Bankable Money",
	CM_TELVAR_DESCRIPTION			= "Note: Multiplier Amounts are x2 at 100, x3 at 1,000, x4 at 10,000",
	
	CM_AMOUNT						= " amount of ",
	CM_MANAGEMENT_TYPE_TIP			= "Select the Management Type",
	CM_MAX							= " Max ",
	CM_MAXIMUM						= " maximum ",
	CM_MIN							= " Min ",
	CM_MINIMUM						= " minimum ",
	CM_POST_MANAGEMENT_TYPE			= " Management Type",
	CM_POST_FIXED_AMOUNT			= " Managed Amount",
	CM_POST_AMOUNT_TIP				= " to keep in your Bag",
	CM_POST_STEP_TIP				= " moved at a time",
	CM_PRE_SEL						= "Select",
	CM_PRE_TIP						= "Enter the",

	CM_MANAGEMENT_TYPE_OPTIONS		= "Management Type Options",
	CM_MAN_TYPE_EMPTY_DESC			= " = All in Bag to Bank",
	CM_MAN_TYPE_FIXED_DESC			= " = Will keep managed amount in Bag",
	CM_MAN_TYPE_NONE_DESC			= " = No Management (Default)",
	
	CM_ACCOUNT_WIDE_TITLE			= "Use Account Wide Settings",
	CM_ACCOUNT_WIDE_TIP				= "When set from [OFF] to [ON] it loads the Account Wide Settings and saves the Settings for all Characters, the reverse works the same way",

}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	-- SafeAddVersion(stringId, 1)
end