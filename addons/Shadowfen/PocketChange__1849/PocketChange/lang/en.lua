local localization_strings = {
	PC_NAME = "PocketChange",
	POCKETCHANGE_ACCOUNTWIDE = "Apply these settings account-wide:",
	POCKETCHANGE_ACCOUNTWIDE_TT = "If ON, these settings apply account-wide instead of just to this one character.",
	POCKETCHANGE_CURRENCY = "Currency Levels",
	POCKETCHANGE_DEPOSIT = "Deposited:",
	POCKETCHANGE_WITHDRAWAL = "Withdrew:",
	POCKETCHANGE_DESCRIPTION = "If you carry higher amounts of currencies on you, everything is transferred to the bank above the value. If you are carrying less than the limits, currency is withdrawn from the bank to your pockets (if available).",
    
    POCKETCHANGE_AUTOMANAGEMENT = "Control the automatic deposit and withdrawal of currencies. Currencies will be automatically deposited and withdrawn to maintain your selected target values unless you specifically disable them.",
    PC_DISABLE_AUTOGOLD = "Disable auto-deposit for gold",
    PC_DISABLE_AUTOAP = "Disable auto-deposit for alliance points",
    PC_DISABLE_AUTOTELVAR = "Disable auto-deposit for telvar stones",
    PC_DISABLE_AUTOVOUCHER = "Disable auto-deposit for writ vouchers",
    POCKETCHANGE_DISABLEAUTO_TT = "Disable the automatic deposit/withdrawal for this currency",
	
	PC_SUPPLIES = "Supply Minimum Level Notifications",
	PC_SUPPLIES_DESC = "Get notifications for supply levels below your minimums.",
	PC_NOTIFY_LP = "Notify on lockpicks",
	PC_LOCKPICKS = "Minimum # of Lockpicks",
	PC_SUPPLIES_NEEDED = "Need more supplies",
	PC_NOTIFY_RK = "Notify on Repair kits",
	PC_REPAIRKITS = "Minimum # of Repair kits",
	PC_NOTIFY_SG = "Notify on soul gems",
	PC_SOULGEMS = "Minimum # of Soul Gems",
	PC_NOTIFY_ESG = "Notify on empty soul gems",
	PC_ESOULGEMS = "Minimum # of empty Soul Gems",
	PC_NOTIFY_MAIN = "Notify on main weapon poisons",
	PC_MAINPOISONS = "Minimum # of main weapon poisons",
	PC_NOTIFY_BKUP = "Notify on backup weapon poisons",
	PC_BKUPPOISONS = "Minimum # of backup weapon poisons",
	PC_ITEM_LOCKPICKS = "Lockpicks",
	PC_ITEM_GEMS="Soul Gems",
	PC_ITEM_EMPTYGEMS="Empty Soul Gems",
	PC_ITEM_KITS="Repair Kits",
	PC_ITEM_MAIN="Main Weapon Poisons",
	PC_ITEM_BKUP="Backup Weapon Poisons",
	
	PC_NOPT_NO = "No",
	PC_NOPT_CHAT = "Chat only",
	PC_NOPT_BOTH = "Chat and Sound",
	
    PC_SLASH_HELP = "Print this help message",
    PC_SLASH_SETTINGS = "Open settings window for PocketChange",
    PC_SLASH_DEBUG = "Toggle debug messages for PocketChange",

	POCKETCHANGE_ENABLE_DEBUG = "Debug messages in chat are enabled.",
    POCKETCHANGE_DISABLE_DEBUG = "Debug messages in chat are disabled.",
	
	SI_CURRENCY_GOLD = "Gold",
	SI_CURRENCY_ALLIANCE_POINTS = "Alliance points",
	SI_CURRENCY_TELVAR_STONES = "Telvar Stones",
	SI_CURRENCY_WRIT_VOUCHERS = "Writ Vouchers",
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end