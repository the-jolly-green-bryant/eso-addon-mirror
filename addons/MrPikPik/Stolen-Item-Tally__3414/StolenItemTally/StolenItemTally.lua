StolenTally = StolenTally or {}
local StolenTally = StolenTally

StolenTally.name = "StolenItemTally"
StolenTally.version = "1.0"

StolenTally.defaults = {
	pickpocketed = {},
	stolen = {},
	money = 0,
}

StolenTally.currentSession = {
	pickpocketed = {},
	stolen = {},
	money = 0,
}

--ITEM_DISPLAY_QUALITY_LEGENDARY  = 5
--ITEM_DISPLAY_QUALITY_ARTIFACT   = 4
--ITEM_DISPLAY_QUALITY_ARCANE     = 3
--ITEM_DISPLAY_QUALITY_MAGIC      = 2
--ITEM_DISPLAY_QUALITY_NORMAL     = 1
--ITEM_DISPLAY_QUALITY_TRASH      = 0 

-- Gets a stripped but working itemlink. Loses ALL additional information except itemid
local function GetStrippedItemLink(itemId)
	return "|H0:item:" .. itemId .. string.rep(":0", 20) .. "|h|h"
end

-- Adds an item to the counts
local function AddItem(itemLink, amount, pickpocketed)
	local itemId   = GetItemLinkItemId(itemLink)
	local itemLink = GetStrippedItemLink(itemId)


	local quality = GetItemLinkDisplayQuality(itemLink)
	 
	local state = pickpocketed and "pickpocketed" or "stolen"
	
	-- Failsafe generated values
	if not StolenTally.SV[state][quality] then
		StolenTally.SV[state][quality] = {}
	end
	if not StolenTally.SV[state][quality][itemId] then
		StolenTally.SV[state][quality][itemId] = 0
	end
	
	if not StolenTally.currentSession[state][quality] then
		StolenTally.currentSession[state][quality] = {}
	end
	if not StolenTally.currentSession[state][quality][itemId] then
		StolenTally.currentSession[state][quality][itemId] = 0
	end
	
	if pickpocketed then		
		-- Current session (volatile)
		StolenTally.currentSession["stolen"][quality][itemId] = StolenTally.currentSession["stolen"][quality][itemId] - amount
		StolenTally.currentSession["pickpocketed"][quality][itemId] = StolenTally.currentSession["pickpocketed"][quality][itemId] + amount	
		
		-- Total count (persistent)
		StolenTally.SV["stolen"][quality][itemId] = StolenTally.SV["stolen"][quality][itemId] - amount
		if StolenTally.SV["stolen"][quality][itemId] == 0 then
			StolenTally.SV["stolen"][quality][itemId] = nil
		end
		StolenTally.SV["pickpocketed"][quality][itemId] = StolenTally.SV["pickpocketed"][quality][itemId] + amount	
	else	
		-- Current session (volatile)
		StolenTally.currentSession["stolen"][quality][itemId] = StolenTally.currentSession["stolen"][quality][itemId] + amount
		
		-- Total count (persistent)
		StolenTally.SV["stolen"][quality][itemId] = StolenTally.SV["stolen"][quality][itemId] + amount
	end
end

local function OnInventorySlotUpdate(event, bagId, slotId, isNewItem, itemSound, inventoryUpdateReason, stackCountChange)
	if isNewItem and stackCountChange > 0 then
		local itemLink = GetItemLink(bagId, slotId)
		if itemLink ~= nil and itemLink ~= "" then
			if IsItemStolen(bagId, slotId) then
				AddItem(itemLink, stackCountChange, false)
			end
		end
	end
end

local function OnCurrencyUpdate(event, currencyType, currencyLocation, newAmount, oldAmount, reason)
	if reason == CURRENCY_CHANGE_REASON_LOOT_STOLEN and currencyType == CURT_MONEY and currencyLocation == CURRENCY_LOCATION_CHARACTER then
		amount = newAmount - oldAmount
		StolenTally.SV.money = StolenTally.SV.money + amount
	end
end

local function OnLootReceived(event, receivedBy, itemLink, quantity, soundCategory, lootType, self, isPickpocketLoot, questItemIcon, itemId, isStolen)
    if not self then return end
	if not lootType == LOOT_TYPE_ITEM then return end

	if isPickpocketLoot then
		AddItem(itemLink, quantity, isPickpocketLoot)
	end
end


local function IsRecipe(itemLink)
	local type, subtype = GetItemLinkItemType(itemLink)
	return type == ITEMTYPE_RECIPE and (
		subtype == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK or
		subtype == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD)
end

local function IsBlueprint(itemLink)
	local type, subtype = GetItemLinkItemType(itemLink)
	return type == ITEMTYPE_RECIPE and (
		subtype == SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING or
		subtype == SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING or
		subtype == SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING or
		subtype == SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING or
		subtype == SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING or
		subtype == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING or
		subtype == SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING)
end

local function IsStylePage(itemLink)
	local type, subtype = GetItemLinkItemType(itemLink)
	return type == ITEMTYPE_RACIAL_STYLE_MOTIF
end

local function IsFurnishing(itemLink)
	local type, subtype = GetItemLinkItemType(itemLink)
	return type == ITEMTYPE_FURNISHING
end


local function ShowAllLootedItems()
	local items = {}
	local colors = {}
	
	for quality = ITEM_DISPLAY_QUALITY_TRASH, ITEM_DISPLAY_QUALITY_LEGENDARY do
		colors[quality] = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality))
		if StolenTally.SV["stolen"][quality] then
			for id, c in pairs(StolenTally.SV["stolen"][quality]) do
				local itemLink = GetStrippedItemLink(id)
				table.insert(items, colors[quality]:Colorize(GetItemLinkName(itemLink)))
			end
		end
		if StolenTally.SV["pickpocketed"][quality] then
			for id, c in pairs(StolenTally.SV["pickpocketed"][quality]) do
				local itemLink = GetStrippedItemLink(id)
				table.insert(items, colors[quality]:Colorize(GetItemLinkName(itemLink)))
			end
		end
	end
	local text = table.concat(items, ", ")
	d(text)
	LORE_READER:Show("All stolen times", text, BOOK_MEDIUM_YELLOWED_PAPER, true)
end

local function DoReport(arg)
	local data = StolenTally.SV
	if arg == "session" then
		data = StolenTally.currentSession
	elseif arg == "reset" then
		StolenTally.SV = StolenTally.defaults
		return
	elseif arg == "showall" then
		-- Intended for debugging, may be interesting for users nontheless
		ShowAllLootedItems()
		return
	elseif arg == "help" or arg ~= "total" then
		CHAT_ROUTER:AddSystemMessage(GetString(STOLEN_TALLY_USAGE_1))
		CHAT_ROUTER:AddSystemMessage(GetString(STOLEN_TALLY_USAGE_2))
		CHAT_ROUTER:AddSystemMessage(GetString(STOLEN_TALLY_USAGE_3))
      --CHAT_ROUTER:AddSystemMessage(GetString(STOLEN_TALLY_USAGE_4))
		CHAT_ROUTER:AddSystemMessage(GetString(STOLEN_TALLY_USAGE_5))
		CHAT_ROUTER:AddSystemMessage(GetString(STOLEN_TALLY_USAGE_6))
		return
	end
	
	-- Gather counts
	local count = {}
	for quality = ITEM_DISPLAY_QUALITY_TRASH, ITEM_DISPLAY_QUALITY_LEGENDARY do
		count[quality] = {
			total      = 0,
			recipe     = 0,
			blueprint  = 0,
			stylepage  = 0,
			furnishing = 0,
			other      = 0,
			
			p_total      = 0,
			p_recipe     = 0,
			p_blueprint  = 0,
			p_stylepage  = 0,
			p_furnishing = 0,
			p_other      = 0,
		}
		
		if data["stolen"][quality] then
			for id, c in pairs(data["stolen"][quality]) do
				local itemLink = GetStrippedItemLink(id)
				
				count[quality].total = count[quality].total + c
				if IsBlueprint(itemLink) then
					count[quality].blueprint = count[quality].blueprint + c
				elseif IsRecipe(itemLink) then
					count[quality].recipe = count[quality].recipe + c
				elseif IsStylePage(itemLink) then
					count[quality].stylepage = count[quality].stylepage + c
				elseif IsFurnishing(itemLink) then
					count[quality].furnishing = count[quality].furnishing + c
				else
					count[quality].other = count[quality].other + c
				end
			end
		end
		
		if data["pickpocketed"][quality] then
			for id, c in pairs(data["pickpocketed"][quality]) do
				local itemLink = GetStrippedItemLink(id)
				
				count[quality].total   = count[quality].total   + c
				count[quality].p_total = count[quality].p_total + c
				
				if IsBlueprint(itemLink) then
					count[quality].blueprint   = count[quality].blueprint   + c
					count[quality].p_blueprint = count[quality].p_blueprint + c
				elseif IsRecipe(itemLink) then
					count[quality].recipe   = count[quality].recipe   + c
					count[quality].p_recipe = count[quality].p_recipe + c
				elseif IsStylePage(itemLink) then
					count[quality].stylepage   = count[quality].stylepage   + c
					count[quality].p_stylepage = count[quality].p_stylepage + c
				elseif IsFurnishing(itemLink) then
					count[quality].furnishing   = count[quality].furnishing   + c
					count[quality].p_furnishing = count[quality].p_furnishing + c
				else
					count[quality].other   = count[quality].other   + c
					count[quality].p_other = count[quality].p_other + c
				end
			end
		end
		
	end
	
	local lines = {}
	local totals = {
		total      = 0,
		blueprint  = 0,
		recipe     = 0,
		stylepage  = 0,
		furnishing = 0,
		[ITEM_DISPLAY_QUALITY_TRASH]     = 0,
		[ITEM_DISPLAY_QUALITY_NORMAL]    = 0,
		[ITEM_DISPLAY_QUALITY_MAGIC]     = 0,
		[ITEM_DISPLAY_QUALITY_ARCANE]    = 0,
		[ITEM_DISPLAY_QUALITY_ARTIFACT]  = 0,
		[ITEM_DISPLAY_QUALITY_LEGENDARY] = 0,
	}
	
	-- Opener line
	table.insert(lines, GetString(arg == "total" and STOLEN_TALLY_HEADER or STOLEN_TALLY_HEADER_SESSION))
	table.insert(lines, "")
	
	-- Generate per rarity reports
	for quality = ITEM_DISPLAY_QUALITY_NORMAL, ITEM_DISPLAY_QUALITY_LEGENDARY do
		local c = count[quality]
		local color = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality))
		
		table.insert(lines, zo_strformat(GetString("STOLEN_TALLY_MAIN_LINE_FORMAT", quality), color:Colorize(GetString("STOLEN_TALLY_QUALITY", quality)), c.total, c.blueprint, c.recipe, c.furnishing, c.stylepage))
		table.insert(lines, zo_strformat(GetString("STOLEN_TALLY_SUB_LINE_FORMAT", quality), c.p_total, c.p_blueprint, c.p_recipe, c.p_furnishing, c.p_stylepage))
		table.insert(lines, "")
		
		totals.total      = totals.total + c.total
		totals.blueprint  = totals.blueprint + c.blueprint
		totals.recipe     = totals.recipe + c.recipe + c.p_recipe
		totals.stylepage  = totals.stylepage + c.stylepage
		totals.furnishing = totals.furnishing + c.furnishing
		totals[quality]   = totals[quality] + c.total
	end
	
	-- Generate total report
	table.insert(lines, zo_strformat(STOLEN_TALLY_TOTAL_LINE_FORMAT, totals.total, totals.blueprint, totals.recipe, totals.furnishing, totals.stylepage))
	table.insert(lines, "")
	
	-- Stolen Gold
	table.insert(lines, zo_strformat(STOLEN_TALLY_MONEY, data.money))
	table.insert(lines, "")

	-- Generate percentages
	for quality = ITEM_DISPLAY_QUALITY_NORMAL, ITEM_DISPLAY_QUALITY_LEGENDARY do
		local color = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality))
		table.insert(lines, zo_strformat("<<1>>: <<2>>%", color:Colorize(GetString("STOLEN_TALLY_QUALITY", quality)), string.format("%.2f", (totals[quality] / totals.total) * 100)))
	end
	
	-- Display book
	local title = GetString(arg == "total" and STOLEN_TALLY_TITLE or STOLEN_TALLY_TITLE_SESSION)
	local text = table.concat(lines, "\n")
	LORE_READER:Show(title, text, BOOK_MEDIUM_YELLOWED_PAPER, true)
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= StolenTally.name then return end
    EVENT_MANAGER:UnregisterForEvent(StolenTally.name, EVENT_ADD_ON_LOADED)

	StolenTally.SV = ZO_SavedVars:New("StolenItemTallySavedVars", 1.0, nil, StolenTally.defaults)

    EVENT_MANAGER:RegisterForEvent(StolenTally.name, EVENT_LOOT_RECEIVED, OnLootReceived)
	EVENT_MANAGER:RegisterForEvent(StolenTally.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySlotUpdate)
	EVENT_MANAGER:RegisterForEvent(StolenTally.name, EVENT_CURRENCY_UPDATE, OnCurrencyUpdate)
	
	SLASH_COMMANDS["/stolentally"] = DoReport
end
EVENT_MANAGER:RegisterForEvent(StolenTally.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)