YeOldeInfos.QUEST_NAME = {
	[CRAFTING_TYPE_BLACKSMITHING] = "Blacksmith Writ",
	[CRAFTING_TYPE_CLOTHIER] = "Clothier Writ",
	[CRAFTING_TYPE_ENCHANTING] = "Enchanter Writ",
	[CRAFTING_TYPE_ALCHEMY] = "Alchemist Writ",
	[CRAFTING_TYPE_PROVISIONING] = "Provisioner Writ",
	[CRAFTING_TYPE_WOODWORKING] = "Woodworker Writ",
	[CRAFTING_TYPE_JEWELRYCRAFTING] = "Jewelry Crafting Writ",
}

YeOldeInfos.STATES = {
	[YeOldeInfos.CraftingQuestStatus.UNAVAILABLE] = "Unavailable",
	[YeOldeInfos.CraftingQuestStatus.AVAILABLE] = "Available",
	[YeOldeInfos.CraftingQuestStatus.ACTIVE] = "Active",
	[YeOldeInfos.CraftingQuestStatus.READY_TO_DELIVER] = "Ready to deliver",
	[YeOldeInfos.CraftingQuestStatus.COMPLETED] = "Completed",
	[YeOldeInfos.CraftingQuestStatus.UNKNOWN] = "Unknown",
}

YeOldeInfos.COND_DELIVER = "Deliver"

local STRINGS = {
	SI_YEOLDEINFOS_ACCOUNT_CURRENCY_HEADER = "Account Currencies",
	SI_YEOLDEINFOS_BAG = "Bag",
	SI_YEOLDEINFOS_BANK = "Bank: <<1>>",
	SI_YEOLDEINFOS_BAR_CONTENT = "Bar Content",
    SI_YEOLDEINFOS_BARS_OPTIONS = "Bar options",
	SI_YEOLDEINFOS_CRAFTING_MATS = "Crafting Mats",
	SI_YEOLDEINFOS_CURRENCY_ALLIANCE_POINTS = "Alliance Points",
	SI_YEOLDEINFOS_CURRENCY_ARCHIVAL_FORTUNES = "Archival Fortunes",
	SI_YEOLDEINFOS_CURRENCY_CHAOTIC_CREATIA = "Transmute Crystals",
	SI_YEOLDEINFOS_CURRENCY_CROWN_GEMS = "Crown Gems",
	SI_YEOLDEINFOS_CURRENCY_CROWNS = "Crowns",
	SI_YEOLDEINFOS_CURRENCY_ENDEAVOR_SEALS = "Seals of Endeavor",
	SI_YEOLDEINFOS_CURRENCY_HEADER = "Player Currencies",
	SI_YEOLDEINFOS_CURRENCY_IMPERIAL_FRAGMENTS = "Imperial Fragments",
	SI_YEOLDEINFOS_CURRENCY_TELVAR_STONES = "Tel Var Stones",
	SI_YEOLDEINFOS_CURRENCY_TOME_POINTS = "Tome Points",
	SI_YEOLDEINFOS_CURRENCY_TRADE_BARS = "Trade Bars",
	SI_YEOLDEINFOS_CURRENCY_WRIT_VOUCHERS = "Writ Vouchers",
	SI_YEOLDEINFOS_FONT_OPTIONS = "Font Options",
	SI_YEOLDEINFOS_FONT_SIZE = "Font size",
	SI_YEOLDEINFOS_FONT_TYPE = "Font type",
	SI_YEOLDEINFOS_HIDE_BAR_WHEN_COMPLETED = "Hide bar when all tasks are completed",
	SI_YEOLDEINFOS_HIDE_BLOC_WHEN_COMPLETED = "Hide each completed task",
	SI_YEOLDEINFOS_HIDE_IN_MENU = "Hide in menus",
	SI_YEOLDEINFOS_ICON_SIZE = "Icon scaling",
	SI_YEOLDEINFOS_INV = "Inv: <<1>>",
	SI_YEOLDEINFOS_MAIL_HIDE_IF_NO_MAIL = "Hide if no new mail",
	SI_YEOLDEINFOS_MAIL_HIDE_TEXT = "Hide info text",
	SI_YEOLDEINFOS_MATERIALS = "Materials :",
	SI_YEOLDEINFOS_MIN_CRAFTING_MATS = "Minimum amount recommended",
	SI_YEOLDEINFOS_MOVE_BAR = "Move in screen",
	SI_YEOLDEINFOS_PROMO_EVENTS_HEADER = "Promotional Events",
	SI_YEOLDEINFOS_PROMO_EVENTS_HIDE_WHEN_NO_EVENT = "Hide when no active event",
	SI_YEOLDEINFOS_PROMO_EVENTS_NONE = "No active promotional event.",
	SI_YEOLDEINFOS_SHOW_EXT_SETTINGS = "Advanced customizations",
    SI_YEOLDEINFOS_SHOW_ONLY_IF_TRAIN = "Only show if you need to train",
	SI_YEOLDEINFOS_SHOW_STAMP_ICON = "Show small icons (stamps)",
	SI_YEOLDEINFOS_SPEED_DEFAULT = "Base speed",
	SI_YEOLDEINFOS_SPEED_OPTIONS_DESC = "Speed calculation values",
	SI_YEOLDEINFOS_SPEED_UPDATE_INTERVAL = "Refresh rate",
	SI_YEOLDEINFOS_TIME_FORMAT = "24H time format",
	SI_YEOLDEINFOS_TIME_SHOW_ICONS = "Show icons",
	SI_YEOLDEINFOS_TT_CRAFTING_HIDE_BAR =
		"Hide the entire crafting bar when all your active writs are completed or ready to deliver",
	SI_YEOLDEINFOS_TT_CRAFTING_HIDE_BLOC =
		"Hide the icon for a specific crafting writ once it is completed or ready to deliver",
	SI_YEOLDEINFOS_TT_CURRENCY_ALLIANCE_POINTS = "Toggle the display of the Alliance Points currency widget.",
	SI_YEOLDEINFOS_TT_CURRENCY_ARCHIVAL_FORTUNES = "Toggle the display of Archival Fortunes.",
	SI_YEOLDEINFOS_TT_CURRENCY_CHAOTIC_CREATIA = "Toggle the display of Transmute Crystals.",
	SI_YEOLDEINFOS_TT_CURRENCY_CROWN_GEMS = "Toggle the display of Crown Gems.",
	SI_YEOLDEINFOS_TT_CURRENCY_CROWNS = "Toggle the display of Crowns.",
	SI_YEOLDEINFOS_TT_CURRENCY_ENDEAVOR_SEALS = "Toggle the display of Seals of Endeavor.",
	SI_YEOLDEINFOS_TT_CURRENCY_IMPERIAL_FRAGMENTS = "Toggle the display of Imperial Fragments.",
	SI_YEOLDEINFOS_TT_CURRENCY_TELVAR_STONES = "Toggle the display of the Tel Var Stones currency widget.",
	SI_YEOLDEINFOS_TT_CURRENCY_TOME_POINTS = "Toggle the display of Tome Points.",
	SI_YEOLDEINFOS_TT_CURRENCY_TRADE_BARS = "Toggle the display of Trade Bars.",
	SI_YEOLDEINFOS_TT_CURRENCY_WRIT_VOUCHERS = "Toggle the display of the Writ Vouchers currency widget.",
	SI_YEOLDEINFOS_TT_FONT_SIZE = "Change the size of the text",
	SI_YEOLDEINFOS_TT_FONT_TYPE = "Change the font used for the text",
	SI_YEOLDEINFOS_TT_HIDE_IN_MENU = "Hide the bar when you open the game menus",
	SI_YEOLDEINFOS_TT_ICON_SIZE = "Change the size of the icons",
	SI_YEOLDEINFOS_TT_MAIL_HIDE = "Hide the mail bar completely when you have no new mail",
	SI_YEOLDEINFOS_TT_MAIL_HIDE_TEXT = "Hide the text '1' and only show the mail icon when you have new mail",
	SI_YEOLDEINFOS_TT_MIN_CRAFTING_MATS =
		"Minimum amount of materials to keep in your inventory for each crafting type",
	SI_YEOLDEINFOS_TT_MOVE_BAR = "Move the bar using the left joystick (Gamepad only)",
	SI_YEOLDEINFOS_TT_PROMO_HIDE = "Hide the promotional events bar when there are no active events",
	SI_YEOLDEINFOS_TT_SHOW_EXT_SETTINGS = "When enabled, font settings are available for each bar, as well as some other optons.",
	SI_YEOLDEINFOS_TT_SHOW_STAMP_ICON =
		"Display a small icon on top of the main icon for specific states (e.g. full bags)",
	SI_YEOLDEINFOS_TT_SPEED_CALIBRATE = "Set the speed value that corresponds to 100%",
	SI_YEOLDEINFOS_TT_SPEED_UPDATE =
		"Lower values will update the speed more often, but may impact performance (in milliseconds)",
	SI_YEOLDEINFOS_TT_TIME_FORMAT = "Use the 24-hour format instead of 12-hour AM/PM",
	SI_YEOLDEINFOS_TT_TIME_SHOW_ICONS = "Show a sun or moon icon next to the time",
	SI_YEOLDEINFOS_TT_TRAIN_READY =
		"Only show the mount training bar when your mount is ready to be trained",
	SI_YEOLDEINFOS_UNTRACKED_MATS = "(Untracked materials for this type)",
}

local function RegisterString(stringIdName, value)
	local existingStringId = _G[stringIdName]
	if existingStringId == nil then
		ZO_CreateStringId(stringIdName, value)
	else
		SafeAddString(existingStringId, value, 2)
	end
end

for stringIdName, value in pairs(STRINGS) do
	RegisterString(stringIdName, value)
end
