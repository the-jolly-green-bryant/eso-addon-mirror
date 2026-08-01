local WG = SDC_WareGuild

--[[
For translation, you have to copy this file and rename it in xx.lua, and translated the strings below. 
you can get the xx for your language by typing following line in game chat
/script d(GetCVar("language.2"))
]]

WG.Lang = {
  --Craft Type, No Need to Translate
  ["BLACKSMITH"] = GetString(SI_ITEMFILTERTYPE13),
  ["CLOTH"] = GetString(SI_ITEMFILTERTYPE14),
  ["ENCHANT"] = GetString(SI_ITEMFILTERTYPE17),
  ["ALCHEMY"] = GetString(SI_ITEMFILTERTYPE16),
  ["COOK"] = GetString(SI_ITEMFILTERTYPE18),
  ["WOOD"] = GetString(SI_ITEMFILTERTYPE15),
  ["JEWELRY"] = GetString(SI_ITEMFILTERTYPE25),
  
  ["STYLE"] = GetString(SI_ITEMFILTERTYPE19),
  ["TRAIT"] = GetString(SI_ITEMFILTERTYPE20),
  
  --Info Displayed in Chat Window, Need to Translate
  
  ["CHAT_FUZZY"] = " (Fuzzy)", --Added to ItemName Matched by ItemId
  
  ["CHAT_TAKE_TO"] = "Keep <<1>> x <<2>>", -- <<1>> ItemName, <<2>> Quantity
  ["CHAT_TAKE_ALL"] = "Withdraw All <<1>>", -- <<1>> ItemName
  
  ["CHAT_STORE_TO"] = "Keep <<1>> x <<2>>", -- <<1>> ItemName, <<2>> Quantity
  ["CHAT_STORE_ALL"] = "Store All <<1>>", -- <<1>> ItemName
  ["CHAT_STORE_ALL_TYPE"] = "Store All <<1>> Materials", -- <<1>> Craft Type
  
  ["CHAT_DAILY_WRITS"] = "Withdraw Items for Daily Writs",
  
  ["CHAT_NE_TAKE"] = "[<<1>>] Not Enough <<2>> to Withdraw", -- <<1>> Guild Name, <<2>> ItemName
  ["CHAT_NE_STORE"] = "[<<1>>] Not Enough <<2>> to Store", -- <<1>> Guild Name, <<2>> ItemName
  
  ["CHAT_DONE"] = "Done!",
  ["CHAT_NO_WORK"] = "Do Nothing!",
  ["CHAT_STOP"] = "Stop!",
  ["CHAT_ERROR"] = "Something Error",
  
  ["CHAT_BACKBAG_FULL"] = "BackBag Full",
  ["CHAT_GUILD_BANK_FULL"] = "Guild Bank Full",
  
  --Setting, Need to Translate
  
  ["SETTING_CHARACTER_CONFIG"] = "Configuration by Character",
  ["SETTING_CHARACTER_CONFIG_TOOLTIP"] = "Default Use Account Configuration",
  
  ["SETTING_AUTO_OPEN_STORE"] = "Auto-Open Guild Banks When Need for Storage",
  ["SETTING_AUTO_OPEN_STORE_TOOLTIP"] = "Only work when WG finds the items that need to be stored.\r\nNot work for [Store Until ?]",
  
  ["SETTING_AUTO_OPEN_WRITS"] = "Auto-Open Guild Banks When Daily Writs",
  ["SETTING_AUTO_OPEN_WRITS_TOOLTIP"] = "Only work when [Withdraw for Daily Writs] steps exist, and hold daily writs",
  
  ["SETTING_AUTO_CLOSE"] = "Auto-Close Guild Banks",
  ["SETTING_AUTO_CLOSE_TOOLTIP"] = "Only work after WG really move some items",
  
  ["SETTING_STEPS_LOG"] = "Display Operation Log",
  ["SETTING_STEPS_LOG_TOOLTIP"] = "Output what WG actually did at each step",
  
  ["SETTING_BAN_STORE_WRITS"] = "Disable Storage Steps When holds Daily Writs",
  ["SETTING_BAN_STORE_WRITS_TOOLTIP"] = "If you want to use guild banks for daily writs, you should turn on this option",
  
  ["SETTING_IGNORE_INVENTORY"] = "[Withdraw for Daily Writs] Ignore Inventory",
  ["SETTING_IGNORE_INVENTORY_TOOLTIP"] = "When on, this step ignores materials already in your backpack, personal bank and crafting packages for crafting the required productions. (For example, a total of 42 materials are needed and 30 are already available. When enabled, it will attempt to take 42 materials out of the guild bank instead of 12)",
  
  ["SETTING_NE_TAKE"] = "When Not Enough, Withdraw the Remaining",
  ["SETTING_NE_TAKE_TOOLTIP"] = "When off, withdraw steps were skipped for lack of items",
  
  ["SETTING_NE_STORE"] = "When Not Enough, Store the Remaining",
  ["SETTING_NE_STORE_TOOLTIP"] = "When off, store steps were completely skipped for lack of items",
  
  ["SETTING_IGNORE_FCOIS"] = "Ignoe FCO ItemSaver",
  ["SETTING_IGNORE_FCOIS_TOOLTIP"] = "Ignore the restrictions of FCO ItemSaver on depositing / withdrawing guild bank items",
  
  ["SETTING_HEADER_SELECT_GUILD"] = "Select Guild Banks",
  ["SETTING_GUILD_TIPS"] = "Tips:\r\nProceed in order, please make sure the access to Guild Banks\r\nUI needs to be reloaded after joining a new guild", -- \r\n Line Feed
  
  ["GUILD_ITEM_SCROLL"] = "Select Item from Backbag to Create Steps",
  
  ["GUILD_FUZZY"] = "Fuzzy Matching",
  ["GUILD_FUZZY_TOOLTIP"] = "Match by ItemLink or ItemId (fuzzy mode). Not recommended to turn on",
  
  ["GUILD_UPDATE_ITEM_LIST"] = "Update Item List",
  ["GUILD_TAKE_ALL"] = "Withdraw All",
  ["GUILD_STORE_ALL"] = "Store All",
  
  ["GUILD_TAKE_TO_SLIDER"] = "Keep Item x ? in Backbag",
  ["GUILD_TAKE_TO"] = "Withdraw Until ?",
  
  ["GUILD_STORE_TO_SLIDER"] = "Keep Item x ? in Guild Bank",
  ["GUILD_STORE_TO"] = "Store Until ?",
  
  ["GUILD_STORE_ALL_TYPE_DROP"] = "Select Material Type to Store",
  ["GUILD_STORE_ALL_TYPE"] = "Store Craft Materials",
  
  ["GUILD_TAKE_WRITS"] = "Withdraw for Daily Writs",
  ["GUILD_TAKE_WRITS_TOOLTIP"] = "This requires receiving daily writs first!\nEach guild only needs to add once, the rules are as follows: \nTake out the missing raw materials for BlackSmith, Clothing, Woodworking, Jewelry and Enchanting\nTake out the finished products for Cooking and Alchemy\nTake out the materials to submitt for Enchanting and Alchemy\n*Style materials are not included",
  
  ["GUILD_HEADER_STEPS"] = "Operating Steps",
  ["GUILD_STEPS_SLIDER"] = "Select the Row of Step",
  ["GUILD_STEPS_EMPTY"] = "Empty Steps",
  ["GUILD_STEPS_DELETE"] = "Delete Selected Step",
  
  ["CLIP"] = "Clipboard",
  ["CLIP_PASTE"] = "Paste",
  
  ["SETTING_BOTTOM_TIPS"] = "Recommended to Read the Detailed Instructions of WG on the ESOUI",
}