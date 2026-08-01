local strings = {
	-- General strings in AB (Autobanker)
	AB_INIT = "Autobanker Initialized...",
	AB_TRIGGER_AUTOBANKER = "Run Autobanker",
	AB_MANUAL_OVERRIDE = "Automatic Autobanker transfers",
	AB_MANUAL_OVERRIDE_TOOLTIP =
	"This option allows you to manually activate Autobanker with a button press on the bottom of the banking interaction scene instead of having Autobanker automatically depositing for you.",

	-- Autobanker Menu - Deposit filters
	AB_RESEARCHABLE = "Researchable items",
	AB_TOOLS_NAME = "All PVP Items",
	AB_MAPS = "Maps",
	AB_MATDES = "Blacksmithing, Clothier, Jewelry & Woodworking",
	AB_TRAITDES = "Armor, Jewelry & Weapons",
	AB_UPMATDES = "Platings, Resins, Tannins & Tempers",
	AB_MATERIALS_NAME = "Materials",
	AB_UPGRADEMATERIALS_NAME = "Improvement Materials",
	AB_RAWMATERIALS_NAME = "Raw Materials",
	AB_TRAITMATERIALS_NAME = "Trait Materials",
	AB_INGREDIENT_NAME = "Provisioning Ingredients",
	AB_SGE = "Empty Soul Gems",
	AB_SGF = "Filled Soul Gems",
	AB_RECIPE_F = "Furnishing Recipes",
	AB_RECIPE_P = "Provisioning Recipes",
	AB_DRINKS = "Drinks",
	AB_REPAIR_KITS = "Repair Kits",
	AB_RK_TOOLTIP = "Petty, Minor, Lesser, Common, Greater and Equipment Repair Kits",
	AB_LP = "Lockpicks",
	AB_STYLE_PAGE = "Bound Style Pages",
	AB_FURNISHING_TOOLTIP = "Deposits Furniture to Bank only",
	AB_WRITS = "Master Writ Envelopes",
	AB_WRITS_TOOLTIP = "Deposits all Unopened Master Writ Envelopes.",
	AB_SURVEYS = "Crafting Survey Reports",
	AB_SURVEYS_TOOLTIP = "Deposits all Unidentified Survey Reports.",
	AB_TREASURE_MAP = "Unopened Treasure Maps",
	AB_TREASURE_MAP_TOOLTIP = "Deposits all Unopened Treasure Maps.",

	-- Global settings
	AB_GLOBAL = "Account-Wide Settings",
	AB_GLOBAL_TOOLTIP = "Use same settings for all characters?",

	-- Notifications
	AB_NOTIFICATION_DEPOSIT = "Show the items deposited.",
	AB_NOTIFICATION_AMOUNT = "Show the number of items deposited.",
	AB_NOTIFICATION_TOOLTIP = "Displayed in chat.",

	-- String formatting
	AB_TRANSACTION_FORMAT = "Autobanker Transferred <<2>>x <<t:1>>.",
	AB_COUNT_FORMAT = "Autobanker Transferred <<1>> <<1[item/items]>>",
	AB_SLIDER_TOOLTIP = "Autobanker will deposit everything above the slider threshold",
	AB_CURT_TRANSFER_FORMAT = "Autobanker Deposited",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
