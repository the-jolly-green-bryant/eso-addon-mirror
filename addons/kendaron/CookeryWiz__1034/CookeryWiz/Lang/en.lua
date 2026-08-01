--[[
  1.0.45: Added
        CWL_BUTTON_TOOLTIP_FAVOURITE_CHANGE
        CWL_COMBO_TOOLTIP_FILTER_FAVOURITE
  1.0.46:Added
        CWL_INGREDIENT_STOCK_LEVELS_TOOLTIP
        CWL_LABEL_OPTIONS_DISABLE_WRIT_COLLECTION_TEXT
  1.0.69:Added
        CWL_LABEL_TOOLTIP_TIME_REMAINING
]]--

CookeryWizLanguage = {}

local function cwl(obj)
  CookeryWizLanguage.language[#CookeryWizLanguage.language + 1] = obj
  return #CookeryWizLanguage.language
end


CookeryWizLanguage.language = {
  
}

CWL_COOKERYWIZ_NAME = cwl("CookeryWiz")
CWL_COOKERYWIZ_TITLE = cwl("Cookery Wiz")
CWL_COOKERYWIZMAILER_TITLE = cwl("Mail Known Recipes")
CWL_COOKERYWIZOPTIONS_TITLE = cwl("Options")
CWL_COOKERYWIZSTOCKPILES_TITLE = cwl("Item Stockpiles")

CWL_AGS = cwl("Awesome Guild Store")

CWL_FILTER_ALL = cwl("All")
CWL_FILTER_KNOWN = cwl("Known")
CWL_FILTER_UNKNOWN = cwl("Unknown")
CWL_FILTER_QUANTITY = cwl("Quantity")
CWL_FILTER_TEXT_BLANK = cwl("Filter Text...")
CWL_FILTER_INGREDIENT = cwl("Ingredient")
CWL_FILTER_COOKABLE = cwl("Cookable")
CWL_FILTER_FAVOURITES = cwl("Favourites")

-- Mailer entries
CWL_LABEL_MAILER_DESCRIPTION_TEXT = cwl("This will send a list of your known recipes to the receiver. They must have CookeryWiz installed to use it")
CWL_LABEL_MAILER_ADDRESS_TEXT = cwl("To Recipient")
CWL_LABEL_MAILER_CHARACTER_TEXT = cwl("From Character")
CWL_LABEL_MAILER_SENT_SUCCESS = cwl("Mail Sent")
CWL_LABEL_MAILER_SENT_FAILED = cwl("Failed Sending Mail")

CWL_LABEL_MAILER_CONTACTS_TEXT = cwl("Contacts")

CWL_BUTTON_MAILER_TOOLTIP_ADD_TO_CONTACTS = cwl("Add to contacts")
CWL_BUTTON_MAILER_TOOLTIP_REMOVE_FROM_CONTACTS = cwl("Remove from contacts")

CWL_EDIT_MAILER_ADDRESS_BLANK_TEXT = cwl("Enter address ...")

CWL_BUTTON_MAILER_TOOLTIP_SENDMAIL = cwl("Send known recipes to recipient")
CWL_BUTTON_MAILER_SENDMAIL = cwl("Send")

CWL_BUTTON_MAILER_TOOLTIP_SEND_TO_CONTACTS = cwl("Send known recipes to all contacts")
CWL_BUTTON_MAILER_SEND_TO_CONTACTS = cwl("Send to contacts")

-- Options
CWL_LABEL_OPTIONS_GENERAL_OPTIONS_TEXT = cwl("General Options")
CWL_LABEL_OPTIONS_ACCOUNT_OPTIONSL_TEXT = cwl("Character Options")
CWL_LABEL_OPTIONS_IMPORTED_OPTIONS_TEXT = cwl("Imported Character Options")

CWL_LABEL_KNOWLEDGE_ICON_TEXT = cwl("Knowledge Icon")

CWL_LABEL_OPTIONS_ACCOUNT_CHARACTER_TEXT = cwl("Character")
CWL_LABEL_OPTIONS_IMPORTED_CHARACTER_TEXT = cwl("Character")
CWL_LABEL_OPTIONS_DISABLE_MINI_ICON_TEXT = cwl("Disable Mini Icon")
CWL_LABEL_OPTIONS_ENABLE_CHAT_THEME_TEXT = cwl("Enable Chat Theme")
CWL_LABEL_OPTIONS_ENABLE_AGS_TEXT = cwl("Enable integration with AGS (Beta)")
CWL_LABEL_OPTIONS_ENABLE_DELETE_READ_MAIL_TEXT = cwl("Delete read mail")
CWL_LABEL_OPTIONS_DISABLE_WRIT_COLLECTION_TEXT = cwl("Disable writ collection")

CWL_LABEL_OPTIONS_COOKING_STATION_INTERACTION = cwl("Cooking Station Interaction")

CWL_COMBO_OPTION_INTERACTION_NONE = cwl("None")
CWL_COMBO_OPTION_INTERACTION_DISPLAY = cwl("Display CookeryWiz")
CWL_COMBO_OPTION_INTERACTION_REPLACE = cwl("Replace Default")

CWL_LABEL_OPTIONS_DISPLAY_TICKS = cwl("Display ticks for known recipes")

CWL_BUTTON_OPTIONS_DISABLE = cwl("Disable")
CWL_BUTTON_OPTIONS_ENABLE = cwl("Enable")
CWL_BUTTON_OPTIONS_DELETE = cwl("Delete")

CWL_BUTTON_OPTIONS_DISABLE_TOOLTIP = cwl("Stop %s from using this character.")
CWL_BUTTON_OPTIONS_ENABLE_TOOLTIP = cwl("Allow %s to use this character.")
CWL_BUTTON_OPTIONS_DELETE_TOOLTIP = cwl("Delete this imported character.")
CWL_BUTTON_OPTIONS_DISABLE_MINI_ICON_TOOLTIP = cwl("Do not show mini icon.")
CWL_BUTTON_OPTIONS_ENABLE_CHAT_THEME_TOOLTIP = cwl("Enable chat theme for main dialog.")
CWL_BUTTON_OPTIONS_ENABLE_AGS_TOOLTIP = cwl("Enable integration with %s. If %s is open then searching for known recipes will be determined by the selected character in %s")
--CWL_BUTTON_OPTIONS_ENABLE_DISPLAY_ON_CRAFTING_STATION_USE_TOOLTIP = cwl("Show %s when interacting with a cooking station")
CWL_BUTTON_OPTIONS_ENABLE_DELETE_READ_MAIL_TOOLTIP = cwl("Delete any mail that is meant for %s")
CWL_LABEL_OPTIONS_ENABLE_RECIPE_KNOWLEDGE_ICON_TOOLTIP = cwl("Show an icon that indicates which characters know a recipe")
CWL_LABEL_OPTIONS_DISABLE_WRIT_COLLECTION_TOOLTIP= cwl("Disable the automatic writ item collection from the bank.")

CWL_LABEL_OPTIONS_DISPLAY_TICKS_TOOLTIP = cwl("Display or hide tick icons in the recipe scroll list.")


-- Guild bank
CWL_BUTTON_GUILDBANK_COLLECT_IDLE = cwl("Idle")
CWL_BUTTON_GUILDBANK_COLLECT_WRIT_FOOD = cwl("Collect Writ Items")
CWL_BUTTON_GUILDBANK_COLLECT_WRIT_FOOD_DONE = cwl("Collect Writ Items Done")
CWL_BUTTON_GUILDBANK_COLLECTING_WRIT_FOOD = cwl("Collecting %s")

CWL_BUTTON_GUILDBANK_STOCKPILING_COMPLETE = cwl("Stockpiling Complete")

-- Stockpiles
CWL_DROPDOWN_GUILDBANK_STOCKPILING_START = cwl("Start Stockpiling")

CWL_LABEL_STOCKPILES_ENABLE_STOCKPILE_CONTROL_TOOLTIP = cwl("Toggle stockpile control for '%s' and '%s'")

CWL_BUTTON_STOCKPILES_HEADER_ENABLE = CWL_BUTTON_OPTIONS_ENABLE
CWL_BUTTON_STOCKPILES_HEADER_MAXIMUM = cwl("Max")
CWL_BUTTON_STOCKPILES_HEADER_NAME = cwl("Name")
CWL_BUTTON_STOCKPILES_HEADER_TOTAL = cwl("Total")

CWL_STOCKPILE_KEEP_AMOUNT_CONTROLLED_TOOLTIP = cwl("Keep %s %s in %s")
CWL_STOCKPILE_KEEP_AMOUNT_NOT_CONTROLLED_TOOLTIP = cwl("%s not under stockpile control")

CWL_BUTTON_STOCKPILES_UNLIMITED = cwl("Unlimited")
CWL_BUTTON_STOCKPILES_DEFAULT_MAX = cwl("Default Max")

CWL_BUTTON_STOCKPILES_SET_TO_DEFAULTS = cwl("Set")

CWL_LABEL_ACTION_TEXT = cwl("For items of quality:")
CWL_LABEL_STOCKPILES_ENABLE = cwl("Enable")

CWL_LABEL_SELECTION_BAG = cwl("Bag")
CWL_LABEL_SELECTION_BANK = cwl("Bank")

CWL_BUTTON_STOCKPILES_ENABLE_TOOLTIP = cwl("Check this to let %s maintain inventory stocks for this item.")

CWL_BUTTON_STOCKPILES_HEADER_ENABLE_TOOLTIP = cwl("Click to sort by which items are under stockpile control.")
CWL_BUTTON_STOCKPILES_HEADER_MAXIMUM_TOOLTIP = cwl("Click to sort by the maximum quantity to be kept.")
CWL_BUTTON_STOCKPILES_HEADER_TOTAL_TOOLTIP = cwl("Click to sort by the currently avilable number of items")
CWL_BUTTON_STOCKPILES_HEADER_NAME_TOOLTIP = cwl("Click to sort by item name.")

CWL_BUTTON_STOCKPILES_ENABLE_ALL_STOCKPILES_TOOLTIP = cwl("Toggle stockpile control for all '%s' and '%s' items.")

CWL_COMBO_OPTION_STOCKPILES_ACTION_ENABLE = cwl("Enable stockpile control")
CWL_COMBO_OPTION_STOCKPILES_ACTION_DISABLE = cwl("Disable stockpile control")
CWL_COMBO_OPTION_STOCKPILES_ACTION_DEFAULT = cwl("Set max to default")
CWL_COMBO_OPTION_STOCKPILES_ACTION_NONE = cwl("Set max to none")
CWL_COMBO_OPTION_STOCKPILES_ACTION_UNLIMITED = cwl("Set max to unlimited")
    
-- Main dialog
CWL_EDIT_TOOLTIP_SEARCH = cwl("Enter text to filter recipes")
CWL_EDIT_TOOLTIP_COPY_LINK = cwl("Copy the selected link using your keyboard controls")

CWL_MENU_ITEM_LINK_RECIPE_IN_CHAT = cwl("Link Recipe in Chat - %s")
CWL_MENU_ITEM_LINK_FOOD_IN_CHAT = cwl("Link Food in Chat - %s")
CWL_MENU_ITEM_LINK_COOK_MAXIMUM = cwl("Cook Maximum (%u) - %s")

CWL_NOTIFY_WRIT_ADDED = cwl("Adding Writ Food")
CWL_NOTIFY_NOT_SCANNING = cwl("%s Not Scanning Mailbox: [%u] items")
CWL_NOTIFY_SCANNING = cwl("%s Scanning Mailbox: [%u] items")
CWL_NOTIFY_IMPORTING_CHARACTER = cwl("%s Importing character %s")
CWL_NOTIFY_CRAFTING = cwl("Crafting %s [%u]")
CWL_NOTIFY_NO_ITEMS_LEFT = cwl("No items left we can cook")
CWL_NOTIFY_MAIL_MISSING_BODY = cwl("Problem: Mail has no body")
CWL_NOTIFY_BLANK_ADDRESS = cwl("You must enter an address")
CWL_NOTIFY_COOKING_CANCELLED = cwl("Cooking Cancelled")
CWL_NOTIFY_RECIPE_LEARNT = cwl("%s: New recipe learnt!")
CWL_NOTIFY_FOOD_COLLECTED = cwl("%s: Collected writ food %s")
CWL_NOTIFY_WRIT_FOOD_ADDED = cwl("%s: Added writ food %s")

CWL_NOTIFY_NO_BAG_SPACE = cwl("%s: No free bag space for food")
CWL_NOTIFY_INCORRECT_IMPORT_VERSION = cwl("%s: Cannot import known recipes as sender version is incorrect")
CWL_NOTIFY_NO_BAG_SPACE_FOR_SPLIT = cwl("%s: No free bag space for splitting food from guild")

CWL_CHAT_OPTION_TOGGLE = cwl("toggle")
CWL_CHAT_OPTION_SHOW = cwl("show")
CWL_CHAT_OPTION_HIDE = cwl("hide")
CWL_CHAT_OPTION_RESET = cwl("reset")
CWL_CHAT_OPTION_FETCH_DELAY = cwl("fetchdelay")
CWL_CHAT_OPTION_CELEBRATE = cwl("celebrate")
CWL_CHAT_OPTION_UPDATE_MISSING = cwl("updatemissing")
CWL_CHAT_OPTION_MISSING_RECIPES = cwl("missingrecipes")
CWL_CHAT_OPTION_MISSING_INGREDIENTS = cwl("missingingredients")
CWL_CHAT_OPTION_INVALID = cwl("Invalid options")
CWL_CHAT_OPTION_FETCH_DELAY_SET = cwl("Fetch delay set to %u")

CWL_CHAT_OPTION_ICON_COUNT = cwl("iconcount");
CWL_CHAT_OPTION_ICON_COUNT_SET = cwl("Icon count set to %u")

CWL_COMBO_TOOLTIP_CHARACTER = cwl("View recipes for character")
CWL_COMBO_TOOLTIP_RECIPE_CATEGORY = cwl("Filter recipes by category")
CWL_COMBO_TOOLTIP_FILTER_LEVEL = cwl("Filter recipes by food level")
CWL_COMBO_TOOLTIP_FILTER_FAVOURITE = cwl("Filter recipes by favourites")

CWL_BUTTON_TOOLTIP_CLEAR_SEARCH = cwl("Clear search text")
CWL_BUTTON_TOOLTIP_OPTIONS = cwl("Options")
CWL_BUTTON_TOOLTIP_CLEAR_ORDERS = cwl("Clear quantity for every recipe")
CWL_BUTTON_TOOLTIP_COOK = cwl("Cook all orders when using a Cooking Fire")
CWL_BUTTON_TOOLTIP_COOK_CANCEL = cwl("Cancel the cooking process")
CWL_BUTTON_TOOLTIP_MAILER = cwl("Mail")
CWL_BUTTON_TOOLTIP_RELOAD = cwl("Refresh recipes and ingredients")
CWL_BUTTON_TOOLTIP_CLOSE = cwl("Close")
CWL_BUTTON_TOOLTIP_EXPAND = cwl("Expand")
CWL_BUTTON_TOOLTIP_SHRINK = cwl("Shrink")
CWL_BUTTON_TOOLTIP_COLLAPSE = cwl("Collapse")

CWL_BUTTON_TOOLTIP_FREE_SPACE = cwl("Free slots in bag")

CWL_BUTTON_TOOLTIP_QUALITY_FILTER = cwl("Click to filter recipes on quality")

CWL_BUTTON_TOOLTIP_FAVOURITE_ADD = cwl("Click to add to favourites")
CWL_BUTTON_TOOLTIP_FAVOURITE_REMOVE = cwl("Click to remove from favourites")
CWL_BUTTON_TOOLTIP_FAVOURITE_CHANGE = cwl("Click to change to next favourite type")

CWL_ICON_KNOWN_RECIPE_TOOLTIP = cwl("Recipe known by everyone")
CWL_ICON_UNKNOWN_RECIPE_TOOLTIP = cwl("Recipe Unknown by")

CWL_INGREDIENT_STOCK_LEVELS_TOOLTIP = cwl("Stock Levels")

CWL_BUTTON_COOK = cwl("Cook")
CWL_BUTTON_COOK_CANCEL = cwl("Cancel")

CWL_BUTTON_CLEAR_ORDERS = cwl("Clear Orders")

CWL_QUEST_PROVISIONER_WRIT_TITLE = cwl("Provisioner Writ")

-- Recipe scroll list
CWL_LABEL_TOOLTIP_RECIPES_CAN_COOK = cwl("Total number of items you could cook")
CWL_LABEL_TOOLTIP_RECIPES_EXISTING_QUANTITY = cwl("Total number of existing food items in bag and bank")

-- Ingredients scroll list
CWL_LABEL_TOOLTIP_INGREDIENTS_CONSUMED = cwl("The number of ingredients consumed by cooking the selected recipes.")
CWL_LABEL_TOOLTIP_INGREDIENTS_AVAILABLE = cwl("The number of ingredients available in bag and bank.")

--CWL_QUEST_PROVISIONER_WRIT_CRAFT = cwl("Craft")
--CWL_QUEST_PROVISIONER_WRIT_ACQUIRE = cwl("Acquire")

CWL_LABEL_TOOLTIP_TIME_REMAINING = cwl("Estimated cooking time")


CWL_OR_FUNCTION = cwl(function(item1, item2)
    return item1.." or "..item2
  end)