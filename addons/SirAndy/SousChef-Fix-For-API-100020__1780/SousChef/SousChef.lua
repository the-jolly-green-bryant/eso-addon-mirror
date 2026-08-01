--[[------------------------------------------------------------------
--SousChef.lua
--Author: Wobin

inspired by ingeniousclown's Research Assistant
Thanks to Ayantir for the French translations, and sirinsidiator for the German

------------------------------------------------------------------]]--

SousChef = {}
SousChef.Utility = {}
SousChef.Media = {}
SousChef.version = "2.19-beta1"

local SousChef = SousChef
local u = SousChef.Utility

local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")

local BACKPACK = ZO_PlayerInventoryBackpack
local BANK = ZO_PlayerBankBackpack
local GUILD_BANK = ZO_GuildBankBackpack

SousChef.Pantry = {}
SousChef.Cookbook = {}
SousChef.CookbookIndex = {}
SousChef.ReverseCookbook = {}
SousChef.settings = nil
SousChef.slotLines = {}
SousChef.hookedFunctions = {}
SousChef.hookedDataFunction = nil
SousChef.lang = GetCVar("Language.2")
if SousChef.lang ~= "en" and SousChef.lang ~= "de" and SousChef.lang ~= "fr" then SousChef.lang = "en" end

local rowHandler = {}

-- FUNCTIONS
-- AddRecipe(Cookbook, link) adds the linked recipe to the player cookbook if it isn't there already.
local function AddRecipe(Cookbook, link)
	for _,v in pairs(Cookbook) do
		if v == link then return end
	end
	table.insert(Cookbook, link)
end

-- RefreshViews() incorporates changes to the rendered inventory if it is visible.
function SousChef:RefreshViews()
	ZO_ScrollList_RefreshVisible(BACKPACK)
	ZO_ScrollList_RefreshVisible(BANK)
	ZO_ScrollList_RefreshVisible(GUILD_BANK)
end

-- every time you change the main character in the settings menu, you need to update the "player" cookbook, cookbook index, pantry, and reverse cookbook with the new character's data
local function ChangeMainChar()
	if SousChef.settings.mainChar == "(current)" then
		SousChef.CookbookIndex = SousChef.settings.CookbookIndex[GetUnitName("player")]
	else
		SousChef.CookbookIndex = SousChef.settings.CookbookIndex[SousChef.settings.mainChar]
	end

	SousChef.Cookbook = {}
	SousChef.Pantry = {}
	SousChef.ReverseCookbook = {}
	if SousChef.CookbookIndex == nil then SousChef.CookbookIndex = {} end
	for name, data in pairs(SousChef.CookbookIndex) do
		SousChef.Cookbook[u.CleanString((GetRecipeResultItemInfo(data.listIndex, data.recipeIndex)))] = true
		local _, _, _, level, color, specialType = GetRecipeInfo(data.listIndex, data.recipeIndex)
		for ingredient = 1, data.numIngredients do
			local ingredientID = u.GetItemID(GetRecipeIngredientItemLink(data.listIndex, data.recipeIndex, ingredient))
			if SousChef.Pantry[ingredientID] == nil then
				if GetItemLinkItemType(GetRecipeIngredientItemLink(listIndex, recipeIndex, ingredientIndex)) == ITEMTYPE_FLAVOR then
					SousChef.settings.Pantry[link] = 2
				elseif GetItemLinkItemType(GetRecipeIngredientItemLink(listIndex, recipeIndex, ingredientIndex)) == ITEMTYPE_SPICE then
					SousChef.settings.Pantry[link] = 1
				elseif ingredient <= color then
					-- if this is a base ingredient, record the skill it governs
					if ingredient == 1 and (data.listIndex == 1 or data.listIndex == 4 or data.listIndex == 5 or data.listIndex == 7) then
						-- meats
						SousChef.Pantry[ingredientID] = 3
					elseif (ingredient == 1 and (data.listIndex == 2 or data.listIndex == 6) or (ingredient == 2 and (data.listIndex == 4 or data.listIndex == 7))) then
						-- fruits
						SousChef.Pantry[ingredientID] = 4
					elseif (ingredient == 1 and data.listIndex == 3) or (ingredient == 2 and (data.listIndex == 5 or data.listIndex == 6)) or (ingredient == 3 and data.listIndex == 7) then
						-- veggies
						SousChef.Pantry[ingredientID] = 5
					elseif (ingredient == 1 and (data.listIndex == 8 or data.listIndex == 11 or data.listIndex == 12 or data.listIndex == 14)) then
						-- booze
						SousChef.Pantry[ingredientID] = 6
					elseif (ingredient == 1 and (data.listIndex == 9 or data.listIndex == 13)) or (ingredient == 2 and (data.listIndex == 11 or data.listIndex == 14)) then
						-- tea
						SousChef.Pantry[ingredientID] = 7
					else
						-- probably tonics
						SousChef.Pantry[ingredientID] = 8
					end
				else
					-- this is a leveller, record whether it makes food or drinks
					SousChef.Pantry[ingredientID] = specialType + 8
				end
			end
			if not SousChef.ReverseCookbook[ingredientID] then SousChef.ReverseCookbook[ingredientID] = {} end
			AddRecipe(SousChef.ReverseCookbook[ingredientID], name)
		end
	end
end

-- ParseRecipes() goes through the player's known recipes and records their info.
function SousChef:ParseRecipes()
	local lists = GetNumRecipeLists()

	for listIndex = 1, lists do
		local name, count = GetRecipeListInfo(listIndex)
		for recipeIndex = 1, count do
			if GetRecipeInfo(listIndex, recipeIndex) then
				-- Store the recipes known:
				local recipeName = u.CleanString((GetRecipeResultItemInfo(listIndex, recipeIndex)))
				if not SousChef.settings.Cookbook[recipeName] then SousChef.settings.Cookbook[recipeName] = {} end
				SousChef.settings.Cookbook[recipeName][GetUnitName("player")] = true

				-- now record information about the recipe's ingregients
				local _, _, ingredientCount, level, color, specialType = GetRecipeInfo(listIndex, recipeIndex)
				-- store the recipe's index numbers and number of ingredients
				local resultLink = GetRecipeResultItemLink(listIndex, recipeIndex)
				local coloredName = u.GetColoredLinkName(resultLink)
				if not SousChef.settings.CookbookIndex[GetUnitName("player")] then SousChef.settings.CookbookIndex[GetUnitName("player")] = {} end
				SousChef.settings.CookbookIndex[GetUnitName("player")][coloredName] = {listIndex = listIndex, recipeIndex = recipeIndex, numIngredients = ingredientCount}
				-- now, for every ingredient in the current recipe...
				for ingredientIndex = 1, ingredientCount do
					local link = u.GetItemID(GetRecipeIngredientItemLink(listIndex, recipeIndex, ingredientIndex, LINK_STYLE_DEFAULT))
					-- Store the fact that the ingredient is used, if we don't already know that
					if SousChef.settings.Pantry[link] == nil then
						if GetItemLinkItemType(GetRecipeIngredientItemLink(listIndex, recipeIndex, ingredientIndex)) == ITEMTYPE_FLAVOR then
							SousChef.settings.Pantry[link] = 2
						elseif GetItemLinkItemType(GetRecipeIngredientItemLink(listIndex, recipeIndex, ingredientIndex)) == ITEMTYPE_SPICE then
							SousChef.settings.Pantry[link] = 1
						elseif ingredientIndex <= color then
							-- if this is a base ingredient, record the skill it governs
							if ingredientIndex == 1 and (listIndex == 1 or listIndex == 4 or listIndex == 5 or listIndex == 7) then
								-- meats
								SousChef.settings.Pantry[link] = 3
							elseif (ingredientIndex == 1 and (listIndex == 2 or listIndex == 6) or (ingredientIndex == 2 and (listIndex == 4 or listIndex == 7))) then
								-- fruits
								SousChef.settings.Pantry[link] = 4
							elseif (ingredientIndex == 1 and listIndex == 3) or (ingredientIndex == 2 and (listIndex == 5 or listIndex == 6)) or (ingredientIndex == 3 and listIndex == 7) then
								-- veggies
								SousChef.settings.Pantry[link] = 5
							elseif (ingredientIndex == 1 and (listIndex == 8 or listIndex == 11 or listIndex == 12 or listIndex == 14)) then
								-- booze
								SousChef.settings.Pantry[link] = 6
							elseif (ingredientIndex == 1 and (listIndex == 9 or listIndex == 13)) or (ingredientIndex == 2 and (listIndex == 11 or listIndex == 14)) then
								-- tea
								SousChef.settings.Pantry[link] = 7
							else
								-- probably tonics
								SousChef.settings.Pantry[link] = 8
							end
						else
							-- this is a leveller, record whether it makes food or drinks
							SousChef.settings.Pantry[link] = specialType + 8
						end
					end
					-- Store the recipe it's used in to the reverseCookbook
					if not SousChef.settings.ReverseCookbook[link] then SousChef.settings.ReverseCookbook[link] = {} end
					AddRecipe(SousChef.settings.ReverseCookbook[link], coloredName)
				end
			end
		end
	end

	ChangeMainChar()
	SousChef:RefreshViews()
end

-- auto-junk ingredients if they're not in the shopping list
local function AutoJunker()
	local bagSize = GetBagSize(BAG_BACKPACK)
	for i = 0, bagSize do
		local itemLink = GetItemLink(BAG_BACKPACK, i)
		if itemLink ~= "" then
			local itemType = GetItemLinkItemType(itemLink)
			if itemType == ITEMTYPE_FLAVORING or itemType == ITEMTYPE_SPICE or itemType == ITEMTYPE_INGREDIENT then
				if not SousChef:IsOnShoppingList(u.GetItemID(itemLink)) then
					SetItemIsJunk(BAG_BACKPACK, i, true)
				end
			end
		end
	end
end

-- removes a character from SousChef's saved variables
local function DeleteCharacter(charName)
	-- remove any of the character's recipes from the shopping list
	for recipe, people in pairs(SousChef.settings.shoppingList) do
		people[charName] = nil
		if NonContiguousCount(people) == 0 then SousChef.settings.shoppingList[recipe] = nil end
	end

	-- record all the recipes that only the deleted character knows
	local soloRecipes = {}
	-- remove the character from the cookbook
	for recipe, people in pairs(SousChef.settings.Cookbook) do
		people[charName] = nil
		if NonContiguousCount(people) == 0 then
			table.insert(soloRecipes, recipe)
			SousChef.settings.Cookbook[recipe] = nil
		end
	end

	-- record any ingredients that only the deleted character could use
	local soloIngredients = {}
	-- if we're removing any recipes, remove them from the reverse cookbook
	-- first, get the removed recipe info from the cookbook index
	for recipe, recipeInfo in pairs(SousChef.settings.CookbookIndex[charName]) do
		for i, delRecipe in ipairs(soloRecipes) do
			if (u.CleanString(string.sub(recipe, 9, -3))) == delRecipe then
				for j = 1, recipeInfo.numIngredients, 1 do
					local ingrNum = u.GetItemID(GetRecipeIngredientItemLink(recipeInfo.listIndex, recipeInfo.recipeIndex, j))
					for k, rName in pairs(SousChef.settings.ReverseCookbook[ingrNum]) do
						if rName == recipe then
							SousChef.settings.ReverseCookbook[ingrNum][k] = nil
							if NonContiguousCount(SousChef.settings.ReverseCookbook[ingrNum]) == 0 then
								table.insert(soloIngredients, ingrNum)
								SousChef.settings.ReverseCookbook[ingrNum] = nil
							end
						end
					end
				end
			end
		end
	end

	-- remove any ingredients from the pantry that we no longer know how to use
	for i, ingredient in ipairs(soloIngredients) do
		SousChef.settings.Pantry[ingredient] = nil
	end

	-- remove the character from the cookbook index
	SousChef.settings.CookbookIndex[charName] = nil

	-- remove the character from the list of known characters
	for k, v in pairs(SousChef.settings.knownChars) do
		if v == charName then
			table.remove(SousChef.settings.knownChars, k)
			break
		end
	end

	-- and finally, refresh the data currently in memory
	ChangeMainChar()
end

-- SousChefCreateSettings() creates the configuration menu for the add-on
local function SousChefCreateSettings()
	local str = SousChef.Strings[SousChef.lang]
	local panelData = {
		type = "panel",
		name = "Sous Chef",
		displayName = "Sous Chef",
		author = "Wobin & KatKat42 & CrazyDutchGuy",
		version = SousChef.version,
		registerForRefresh = true,
		slashCommand = "/souschef",
	}

	LAM:RegisterAddonPanel("SousChefSettings", panelData)

	local optionsMenu = { }
	table.insert(optionsMenu, {
		type = "dropdown",
		name = str.MENU_MAIN_CHAR,
		tooltip = str.MENU_MAIN_CHAR_TOOLTIP,
		choices = SousChef.settings.knownChars,
		getFunc = function() return SousChef.settings.mainChar end,
		setFunc = function(value)
			SousChef.settings.mainChar = value
			ChangeMainChar()
			SousChef.RefreshViews()
		end,
		disabled = function() return not SousChef.settings.processRecipes end,
	})
	table.insert(optionsMenu, {
		type = "header",
		name = str.MENU_RECIPE_HEADER,
		width = "full",
	})
	table.insert(optionsMenu, {
		type = "checkbox",
		name = str.MENU_PROCESS_RECIPES,
		tooltip = str.MENU_PROCESS_RECIPES_TOOLTIP,
		getFunc = function() return SousChef.settings.processRecipes end,
		setFunc = function(value) SousChef.settings.processRecipes = value SousChef.RefreshViews() end,
		width = "full",
	})
	table.insert(optionsMenu, {
		type = "dropdown",
		name = str.MENU_MARK_IF_KNOWN,
		tooltip = str.MENU_MARK_IF_KNOWN_TOOLTIP,
		choices = {str.MENU_KNOWN, str.MENU_UNKNOWN},
		getFunc = function()
			if SousChef.settings.checkKnown == "known" then
				return str.MENU_KNOWN
			elseif SousChef.settings.checkKnown == "unknown" then
				return str.MENU_UNKNOWN
			else
				-- can't happen
				d("Yikes! MENU_MARK_IF_KNOWN getter")
				return str.MENU_UNKNOWN
			end
		end,
		setFunc = function(valueString)
			if valueString == str.MENU_KNOWN then
				SousChef.settings.checkKnown = "known"
			elseif valueString == str.MENU_UNKNOWN then
				SousChef.settings.checkKnown = "unknown"
			else
				-- can't happen
				d("Oops! MENU_MARK_IF_KNOWN setter")
				SousChef.settings.checkKnown = "unknown"
			end
			SousChef.RefreshViews()
		end,
		disabled = function() return not SousChef.settings.processRecipes end,
	})
	table.insert(optionsMenu, {
		type = "checkbox",
		name = str.MENU_MARK_IF_ALT_KNOWS,
		tooltip = str.MENU_MARK_IF_ALT_KNOWS_TOOLTIP,
		getFunc = function() return SousChef.settings.markAlt end,
		setFunc = function(value) SousChef.settings.markAlt = value SousChef:RefreshViews() SousChef.RefreshViews() end,
		disabled = function() return (not SousChef.settings.processRecipes) or (SousChef.settings.checkKnown == "known") end,
	})

	table.insert(optionsMenu, {
		type = "header",
		name = str.MENU_RECIPE_TOOLTIP_HEADER,
		width = "full",
	})
	table.insert(optionsMenu, {
		type = "checkbox",
		name = str.MENU_TOOLTIP_IF_ALT_KNOWS,
		tooltip = str.MENU_TOOLTIP_IF_ALT_KNOWS_TOOLTIP,
		getFunc = function() return SousChef.settings.showAltKnowledge end,
		setFunc = function(value) SousChef.settings.showAltKnowledge = value SousChef:RefreshViews() end,
		disabled = function() return not SousChef.settings.processRecipes end,
	})

	table.insert(optionsMenu, {
		type = "header",
		name = str.MENU_TOOLTIP_HEADER,
		width = "full",
	})
	table.insert(optionsMenu, {
		type = "checkbox",
		name = str.MENU_TOOLTIP_CLICK,
		tooltip = str.MENU_TOOLTIP_CLICK_TOOLTIP,
		warning = str.MENU_RELOAD,
		getFunc = function() return SousChef.settings.showOnClick end,
		setFunc = function(value) SousChef.settings.showOnClick = value end,
	})
	table.insert(optionsMenu, {
		type = "checkbox",
		name = str.MENU_RESULT_COUNTS,
		tooltip = str.MENU_RESULT_COUNTS_TOOLTIP,
		getFunc = function() return SousChef.settings.showCounts end,
		setFunc = function(value) SousChef.settings.showCounts = value end,
	})
	table.insert(optionsMenu, {
		type = "checkbox",
		name = str.MENU_ALT_USE,
		tooltip = str.MENU_ALT_USE_TOOLTIP,
		getFunc = function() return SousChef.settings.showAltIngredientKnowledge end,
		setFunc = function(value) SousChef.settings.showAltIngredientKnowledge = value SousChef:RefreshViews() end,
	})

	table.insert(optionsMenu, {
		type = "header",
		name = str.MENU_INDICATOR_HEADER,
		width = "full",
	})
	table.insert(optionsMenu, {
		type = "colorpicker",
		name = str.MENU_INDICATOR_COLOR,
		tooltip = str.MENU_INDICATOR_COLOR_TOOLTIP,
		getFunc = function() return SousChef.settings.colour[1], SousChef.settings.colour[2], SousChef.settings.colour[3] end,
		setFunc = function(r,g,b)
			SousChef.settings.colour[1] = r
			SousChef.settings.colour[2] = g
			SousChef.settings.colour[3] = b
			SousChef:RefreshViews()
		end,
	})
	table.insert(optionsMenu, {
		type = "colorpicker",
		name = str.MENU_SHOPPING_COLOR,
		tooltip = str.MENU_SHOPPING_COLOR_TOOLTIP,
		getFunc = function() return SousChef.settings.shoppingColour[1], SousChef.settings.shoppingColour[2], SousChef.settings.shoppingColour[3] end,
		setFunc = function(r,g,b)
			SousChef.settings.shoppingColour[1] = r
			SousChef.settings.shoppingColour[2] = g
			SousChef.settings.shoppingColour[3] = b
			SousChef:RefreshViews()
		end,
	})
	table.insert(optionsMenu, {
		type = "checkbox",
		name = str.MENU_SHOW_ALT_SHOPPING,
		tooltip = str.MENU_SHOW_ALT_SHOPPING_TOOLTIP,
		getFunc = function() return SousChef.settings.showAltShopping end,
		setFunc = function(value) SousChef.settings.showAltShopping = value SousChef:RefreshViews() end,
	})
	table.insert(optionsMenu, {
		type = "checkbox",
		name = str.MENU_ONLY_MARK_SHOPPING,
		tooltip = str.MENU_ONLY_MARK_SHOPPING_TOOLTIP,
		getFunc = function() return SousChef.settings.onlyShowShopping end,
		setFunc = function(value) SousChef.settings.onlyShowShopping = value SousChef:RefreshViews() end,
	})
	table.insert(optionsMenu, {
		type = "checkbox",
		name = str.MENU_AUTO_JUNK,
		tooltip = str.MENU_AUTO_JUNK_TOOLTIP,
		getFunc = function() return SousChef.settings.autoJunk end,
		setFunc = function(value)
			if value then
				SousChef.settings.autoJunk = true
				EVENT_MANAGER:RegisterForEvent("SousChefLootJunker", EVENT_LOOT_CLOSED, function(...) zo_callLater(AutoJunker, 100) end)
			else
				SousChef.settings.autoJunk = false
				EVENT_MANAGER:UnregisterForEvent("SousChefLootJunker", EVENT_LOOT_CLOSED)
			end
		end,
		warning = str.MENU_AUTO_JUNK_WARNING,
	})
	table.insert(optionsMenu, {
		type = "checkbox",
		name = str.MENU_SORT_INGREDIENTS,
		tooltip = str.MENU_SORT_INGREDIENTS_TOOLTIP,
		getFunc = function() return SousChef.settings.sortKnownIngredients end,
		setFunc = function(value)
			SousChef.settings.sortKnownIngredients = not SousChef.settings.sortKnownIngredients
			if not SousChef.settings.sortKnownIngredients then
				SousChef.UnregisterSort()
			else
				SousChef.SetupSort()
			end
			SousChef.RefreshViews()
		end,
	})
	local charList = { " " }
	for k, v in pairs(SousChef.settings.knownChars) do
		if v ~= "(current)" then table.insert(charList, v) end
	end
	local charToDelete = " "
	table.insert(optionsMenu, {
		type = "submenu",
		name = str.MENU_DELETE_CHAR,
		 controls = {
			[1] = {
				type = "dropdown",
				name = str.MENU_DELETE_CHAR,
				tooltip = str.MENU_DELETE_CHAR_TOOLTIP,
				choices = charList,
				getFunc = function() return charToDelete end,
				setFunc = function(value) charToDelete = value end,
			},
			[2] = {
				type = "button",
				name = str.MENU_DELETE_CHAR_BUTTON,
				tooltip = str.MENU_DELETE_CHAR_WARNING,
				func = function() DeleteCharacter(charToDelete) end,
			},
		 }
	})

	LAM:RegisterOptionControls("SousChefSettings", optionsMenu)
end

-- SousChef_Loaded(eventCode, addOnName) runs when the EVENT_ADD_ON_LOADED event fires.
local function SousChef_Loaded(eventCode, addOnName)
	if(addOnName ~= "SousChef") then return end

	-- default config settings
	local defaults = {
		--watching = true,
		checkKnown = "unknown",
		markAlt = false,
		colour = {1, 1, 1},
		shoppingColour = {0,1,1},
		Cookbook = {},
		CookbookIndex = {},
		Pantry = {},
		ReverseCookbook = {},
		showAltKnowledge = false,
		showAltIngredientKnowledge = false,
		boldIcon = false,
		typeIcon = true,
		processRecipes = true,
		showSpecialIngredients = false,
		ignoredRecipes = {},
		showOnClick = false,
		showCounts = true,
		shoppingList = {},
		onlyShowShopping = false,
		qualityChecked = false,
		sortKnownIngredients = false,
		mainChar = GetUnitName("player"),
		knownChars = { "(current)" },
		autoJunk = false,
		showAltShopping = true,
	}

	local localized = SousChef.Strings[SousChef.lang]

	-- Fetch the saved variables
	SousChef.settings = ZO_SavedVars:NewAccountWide("SousChef_Settings", 11, SousChef.lang, defaults)
	-- if this character isn't in the list of known chars, add it
	local addMe = true
	local addCurrent = true
	for _, v in pairs(SousChef.settings.knownChars) do
		if GetUnitName("player") == v then addMe = false end
		if v == "(current)" then addCurrent = false end
	end
	if addMe then
		local myName = GetUnitName("player")
		table.insert(SousChef.settings.knownChars, GetUnitName("player"))
	end
	if addCurrent then
		table.insert(SousChef.settings.knownChars, "(current)")
	end

	-- define some slash commands
	SLASH_COMMANDS['/scstats'] = function()
		d(localized.SC_NUM_RECIPES_KNOWN.. NonContiguousCount(SousChef.settings.Cookbook))
		d(localized.SC_NUM_INGREDIENTS_TRACKED..NonContiguousCount(SousChef.settings.Pantry))
	end
	SLASH_COMMANDS['/sciadd'] = SousChef.AddRecipeToIgnoreList
	SLASH_COMMANDS['/sciremove'] = SousChef.RemoveRecipeFromIgnoreList
	SLASH_COMMANDS['/scilist'] = SousChef.ListIgnoredRecipes

	-- initialize the configuration menu
	SousChefCreateSettings()

	-- parse the recipes this character knows, in a second
	zo_callLater(SousChef.ParseRecipes, 500)

	SousChef:HookGetRecipeInfo()

	if SousChef.settings.sortKnownIngredients then SousChef.SetupSort() end

	ZO_CreateStringId("SI_BINDING_NAME_SC_MARK_RECIPE", localized.KEY_MARK)

	-- Now we register for some events, and hook into the function that sets the details on the inventory slot
	zo_callLater(SousChef.HookEvents, 2000)
end

-- HookEvents() registers the add-on for some events
function SousChef.HookEvents()
	-- let us know if we're opening a trading house, so we can look at its contents
	EVENT_MANAGER:RegisterForEvent("SousChefTrading", EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, SousChef.HookTrading)
	-- let us know if we've learned a new recipe, so we can integrate it into our cookbook
	EVENT_MANAGER:RegisterForEvent("SousChefLearnt", EVENT_RECIPE_LEARNED, SousChef.ParseRecipes)
	-- if the user has turned on auto-junking unmarked ingredients, set that up
	if SousChef.settings.autoJunk then
		EVENT_MANAGER:RegisterForEvent("SousChefLootJunker", EVENT_LOOT_CLOSED, function(...) zo_callLater(AutoJunker, 100) end)
	end
	-- let us know when we open a crafting station, so we can sort the recipe tree
	EVENT_MANAGER:RegisterForEvent("SousChefProvi", EVENT_CRAFTING_STATION_INTERACT, function(...) SousChef:HookRecipeTree(...) end)
	EVENT_MANAGER:RegisterForEvent("SousChefProviEnd", EVENT_END_CRAFTING_STATION_INTERACT, function() SousChef:UnhookRecipeTree() end)
	-- and finally, hook the opening of the inventory, bank, guild bank, and loot windows so we can add icons and hook the tooltips
	SousChef.HookInventory()
end

EVENT_MANAGER:RegisterForEvent("SousChefLoaded", EVENT_ADD_ON_LOADED, SousChef_Loaded)