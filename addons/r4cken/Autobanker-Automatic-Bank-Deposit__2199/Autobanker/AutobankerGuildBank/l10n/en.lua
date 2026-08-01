local strings = {
    -- General strings in ABGB
    ABGB_INIT = "Autobanker Guild Bank Initialized...",

    -- Guild profile system
    ABGB_EDIT_PROFILE = "Edit profile for :",
    ABGB_EDIT_PROFILE_TOOLTIP =
    "Pick guild to edit, each guild has it's own settings. If you join a guild always reloadui",
    ABGB_ENABLE_GUILD = "Enable deposit for this guild?",
    ABGB_ENABLE_GUILD_TOOLTIP = "When OFF guild deposits is completely ignored",
    ABGB_AUTOMODE = "Auto deposit when a guild bank opens",
    ABGB_AUTOMODE_TOOLTIP =
    "If OFF nothing fires until you press the deposit keybind. The keybind always works either way.",
    ABGB_MODE_HEADER = "Deposit Mode",
    ABGB_GUILD_DISABLED = "AutobankerGB this guild is disabled in settings.",

    -- Category Headers
    ABGB_CRAFT = "Crafting Materials",
    ABGB_CON_RECIPES = "Consumables & Recipes",
    ABGB_MAPS = "Maps, Surveys & Writs",
    ABGB_CURR = "Currency Settings",
    ABGB_TOOLS_NAME = "All PVP Items",

    -- Deposit Filters - Crafting
    ABGB_MATERIALS_NAME = "Materials",
    ABGB_MATERIALS_TOOLTIP = "Blacksmithing, Clothier, Jewelry & Woodworking",
    ABGB_UPGRADEMATERIALS_NAME = "Improvement Materials",
    ABGB_UPMATDES = "Platings, Resins, Tannins & Tempers",
    ABGB_TRAITMATERIALS_NAME = "Trait Materials",
    ABGB_TRAITDES = "Armor, Jewelry & Weapons",
    ABGB_INGREDIENT_NAME = "Provisioning Ingredients",

    -- Deposit Filters - Consumables
    ABGB_SGE = "Empty Soul Gems",
    ABGB_SGF = "Filled Soul Gems",
    ABGB_RECIPE = "Furnishing and Provisioning",
    ABGB_REPAIR_KITS = "Repair Kits",
    ABGB_RK_TOOLTIP = "Petty, Minor, Lesser, Common, Greater and Equipment Repair Kits",
    ABGB_STYLE_PAGE = "Collectible Style Pages",
    ABGB_RECIPE_F = "Furnishing Recipes",
    ABGB_RECIPE_P = "Provisioning Recipes",

    -- Deposit Filters - Special Items
    ABGB_WRITS = "Master Writ Envelopes",
    ABGB_WRITS_TOOLTIP = "Deposits all Unopened Master Writ Envelopes.",
    ABGB_SURVEYS = "Crafting Survey Reports",
    ABGB_SURVEYS_TOOLTIP = "Deposits all Unidentified Survey Reports.",
    ABGB_TREASURE_MAP = "Unopened Treasure Maps",
    ABGB_TREASURE_MAP_TOOLTIP = "Deposits all Unopened Treasure Maps.",

    -- Global settings
    ABGB_GLOBAL = "Account-Wide Settings",
    ABGB_GLOBAL_TOOLTIP = "Use same settings for all characters?",
    ABGB_WARNING = "Changing this will reload the UI.",

    -- Notifications
    ABGB_NOTIFICATION_DEPOSIT = "Display items deposited.",
    ABGB_NOTIFICATION_AMOUNT = "Display item amount deposited.",
    ABGB_NOTIFICATION_TOOLTIP = "Displayed in chat.",

    -- Logic & Interaction
    ABGB_TRANSACTION_FORMAT = "AutobankerGB Transferred <<2>>x <<t:1>>.",
    ABGB_TRANSFER_FORMAT = "AutobankerGB Transferred <<1>> <<1[item/items]>>",
    ABGB_TRANSFER_FINISHED = "Autobanker Guild Bank Finished",
    ABGB_CURRENCY_DEPOSIT_FORMAT = "AutobankerGB deposited ",
    ABGB_NO_ELIGIBLE = "No items found matching your deposit filters.",
    ABGB_KEYBIND_NAME = "Deposit to Guild Bank",
    ABGB_CURR1 = "Deposit Gold",
    ABGB_CURR1_TOOLTIP = "Deposit gold every time you run Autobanker Guild Bank",
    ABGB_SLIDER_TOOLTIPGOLD = "Amount of gold to deposit.",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
