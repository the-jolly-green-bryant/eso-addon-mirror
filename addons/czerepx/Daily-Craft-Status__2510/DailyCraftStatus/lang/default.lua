local _addon = _G["DailyCraftStatus"]

_addon.default_translation = {
	["Missing translations"] = "",
--	["Missing translations"] = "|cFF4040Please help translate this add-on, send translations with in-game mail to @czerepx",

-- popup menu commands
	["Lock"] = "Lock",
	["Save"] = "Save",
	["Unlock"] = "Unlock",
	["Toggle Stock"] = "Toggle Stock",
	["Toggle Raw Stock"] = "Toggle Raw Stock",
	["Toggle Surveys"] = "Toggle Surveys",
	["Always On"] = "Always On",
	["Auto-hide"] = "Auto-hide",
	["Mail Stock"] = "Count Mail in Stock",
	["Loot Mail"] = "Loot Hirelings Mail",
	["Pick Up Survey"] = "Pick Up at Bank",
	["Clear Survey Pick List"] = "Clear Pick List",
	["Settings"] = "Settings",
	["Alts Status"] = "Other Characters",

--options menu
	["Account Settings"] = "Account Settings",
	["Low Threshold"] = "Low Quantity Threshold (Quest Items)",
	["Low Quantity"] = "Low Quantity (Quest Items)",
	["Auto-save position"] = "Auto-save position for each character",
	["Use Icons"] = "Use Icons for Quest Status",
	["Low Stock Warn"] = "Low Material Stock Warning",
	["Show Marker After Daily Reset"] = "Show Marker After Daily Reset",
	["Show Marker For Riding Training"] = "Show Marker For Riding Training",
	["Track Alts Data"] = "Track Additional Data for Characters",
	["Preserve Icon in UI mode"] = "Keep Dock Icon in UI Mode",
	["Keep Visible On Warnings"] = "Keep Visible On Warnings",
	["Separate Backpack Quantity"] = "Separate Backpack Quantity for Materials",
	["Show in HUD Only"] = "Show in Main View (HUD) Only",
	["Character Settings"] = "Character Settings",
	["Show Stock"] = "Show Processed Materials Stock",
	["Show Raw Stock"] = "Show Raw Materials Stock",
	["Show Surveys"] = "Show Surveys",
	["Show Inventory Space"] = "Show Free Inventory Space",
	["Always Visible"] = "Always Visible",
	["Appearance"] = "Appearance",
	["Single Row Display"] = "Single Row Display",
	["Align To Bar Center"] = "Align To Bar Center",
	["UI Scale"] = "Font Size",
	["Background Style"] = "Background Style",
	["Share Appearance"] = "Same Appearance for All Characters",
	["Low Mat Threshold"] = "Low Material Quantity Threshold",
	["Own Low Stock"] = "Own Low Material Quantity",
	["Find Item"] = "Find (in bags and base crafting materials)",
	["Search Results"] = "Results",
	["Low Stock"] = "Low Stock (optional, stock will be underlined)",
	["High Stock"] = "High Stock (optional, item will be hidden)",
	["Add Item"] = "Add Item",
	["Custom Materials"] =  "Custom Materials",
	["Custom Materials (All Characters)"] = "Custom Materials (All Characters)",
	["Item"] =  "Item",
	["Custom Materials Help"] = 
			"Search for items below, or use 'Link In Chat' command to paste the item link to Chat, and then copy the link here. " ..
			"You can also use numeric item ID, or your own text/reminder. To delete an item, just clear the text field."
			,
	["Survey Statistics"] =  "Survey Statistics",
	["Survey Statistics Help"] = 
			"Define your own survey statistics using digits below, in any order.\n" ..
			"0 - Total Surveys, 1 - Best by Location, 2 - 2nd Best, 3 - 3rd Best, " ..
			"4 - Best in Craglorn, 5 - Surveys in Backpack, 6 - Total in Craglorn\n"..
			"Example: type 50 to see only backpack and total count"
			,
	["Display Pattern"] =  "Display Pattern",
	["Research Tracking"] =  "Available Research",
	["Include Consumables"] =  "  - include Alchemy & Enchanting",
}	
