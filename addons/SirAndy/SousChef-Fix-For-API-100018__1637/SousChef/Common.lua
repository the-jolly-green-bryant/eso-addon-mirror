local SousChef = SousChef
local u = SousChef.Utility
local m = SousChef.Media
local str = SousChef.Strings[SousChef.lang]

local BACKPACK = ZO_PlayerInventoryBackpack
local BANK = ZO_PlayerBankBackpack
local GUILD_BANK = ZO_GuildBankBackpack

m.COOKING = {
	[[SousChef/media/Spice.dds]], --food spice
	[[SousChef/media/Flavour.dds]], -- drink flavouring
	[[/esoui/art/treeicons/provisioner_indexicon_meat_down.dds]], -- meat
	[[//esoui/art/progression/progression_indexicon_race_down.dds]], -- fruit
	[[/esoui/art/compass/ava_farm_neutral.dds]], -- veggies
	[[/esoui/art/treeicons/provisioner_indexicon_spirits_down.dds]], -- booze
	[[/esoui/art/treeicons/provisioner_indexicon_beer_down.dds]], -- teas
	[[/esoui/art/crafting/alchemy_tabicon_solvent_down.dds]], -- tonics
	[[/esoui/art/treeicons/provisioner_indexicon_stew_down.dds]], -- general foods
	[[/esoui/art/inventory/inventory_quest_tabicon_active.dds]] -- general drinks
}

m.CANLEARN = [[/esoui/art/loot/loot_finesseitem.dds]]

local INVENTORIES = {
	[PLAYER_INVENTORY.inventories[1].listView]	= {GetItemLink, "bagId", "slotIndex"}, -- Backpack
	[PLAYER_INVENTORY.inventories[3].listView]	= {GetItemLink, "bagId", "slotIndex"}, -- Bank
	[PLAYER_INVENTORY.inventories[4].listView]	= {GetItemLink, "bagId", "slotIndex"}, -- GuildBank
	[LOOT_WINDOW.list]							= {GetLootItemLink, "lootId", nil},	  -- LootWindow
	[STORE_WINDOW.list]							= {GetStoreItemLink, "slotIndex", nil},	-- Vendor
}
local rowClicked = {}

function SousChef.HookInventory()
	for list, funcs in pairs(INVENTORIES) do
		if list and list.dataTypes and list.dataTypes[1] then
			local listName = list:GetName()
			SousChef.hookedFunctions[listName] = list.dataTypes[1].setupCallback
			if SousChef.hookedFunctions[listName] then
				list.dataTypes[1].setupCallback =
					function(rowControl, slot)
						SousChef.hookedFunctions[listName](rowControl, slot)
						SousChef.AddRankToSlot(rowControl, funcs)
					end
			else
				d("SousChef could not hook into the Inventory")
			end
		end
	end

	ZO_ScrollList_RefreshVisible(BACKPACK)
	ZO_ScrollList_RefreshVisible(BANK)
	ZO_ScrollList_RefreshVisible(GUILD_BANK)
	if not SousChef.settings.showOnClick then
		ZO_PreHookHandler(ItemTooltip, "OnShow", function() zo_callLater(function() SousChef.AddDetails(moc()) end, 500) return false end)
		ZO_PreHookHandler(ItemTooltip, "OnUpdate", function() zo_callLater(function() SousChef.AddDetails(moc()) end, 500) return false end)
		ZO_PreHookHandler(ItemTooltip, "OnHide", function() rowClicked = nil return false end )
	end
end

function SousChef.getIcon(row)
	local rankIcon = SousChef.slotLines[row:GetName()]
	if(not rankIcon) then
		rankIcon =  WINDOW_MANAGER:CreateControl(row:GetName() .. "SousChef", row, CT_TEXTURE)
		SousChef.slotLines[row:GetName()] = rankIcon
		if SousChef.settings.showOnClick then
			ZO_PreHookHandler(row, "OnMouseDown", SousChef.AddDetails)
			ZO_PreHookHandler(row, "OnMouseExit", function(self) rowClicked = nil return false end )
		end
		rankIcon:SetMouseEnabled(true)
	end
	return rankIcon
end

local function CalculateHowManyCouldBeCreated(recipeListIndex, recipeIndex, numIngredients)
	local minCount

	for ingredientIndex = 1, numIngredients do
		local _, _, requiredQuantity = GetRecipeIngredientItemInfo(recipeListIndex, recipeIndex, ingredientIndex)
		local ingredientCount = GetCurrentRecipeIngredientCount(recipeListIndex, recipeIndex, ingredientIndex)

		minCount = zo_min(zo_floor(ingredientCount / requiredQuantity), minCount or math.huge)
		if minCount == 0 then
			return 0
		end
	end

	return minCount or 0
end

-- add details to the item tooltip
function SousChef.AddDetails(row)
	if not row.dataEntry or not row.dataEntry.data or rowClicked == row then return false end
	rowClicked = row
	local rowInfo = row.dataEntry.data
	local bagId = rowInfo.bagId or rowInfo.lootId
	local slotIndex = rowInfo.slotIndex
	if bagId == nil then
		if slotIndex == nil then return false end
		bagId = slotIndex + 0
		slotIndex = nil
	end
	local itemLink = (slotIndex and GetItemLink(bagId, slotIndex))
		or (LOOT_WINDOW_FRAGMENT.state == "shown" and GetLootItemLink(bagId))
		-- If there are no search results present in memory, GetTradingHouseSearchResultItemLink will crash to desktop
		or (TRADING_HOUSE:IsAtTradingHouse() and TRADING_HOUSE.m_numItemsOnPage ~= nil and TRADING_HOUSE.m_numItemsOnPage ~= 0 and GetTradingHouseSearchResultItemLink(bagId))
		or (GetTradingHouseListingItemLink(bagId))
		or (GetGuildSpecificItemLink(bagId))
		or (TRADE_FRAGMENT.state == "shown" and GetTradeItemLink(bagId))
		or (STORE_FRAGMENT.state == "shown" and GetStoreItemLink(bagId))
		or (BUY_BACK_FRAGMENT.state == "shown" and GetBuybackItemLink(bagId))
		or (MAIL_INBOX_FRAGMENT.state == "shown" and MAIL_INBOX.GetOpenMailId() and GetAttachedItemLink(MAIL_INBOX.GetOpenMailId(), bagId))
	if itemLink == "" then return false end

	-- item is a recipe
	if GetItemLinkItemType(itemLink) == ITEMTYPE_RECIPE then
		ZO_Tooltip_AddDivider(ItemTooltip)
		local resultLink = GetItemLinkRecipeResultItemLink(itemLink)

		-- $$$ SirAndy: Fixed API version 15 switch to Champion Points
		-- local level = GetLevelOrVeteranRankString(GetItemLinkRequiredLevel(resultLink), GetItemLinkRequiredVeteranRank(resultLink), 20)
		local level = GetLevelOrChampionPointsString(GetItemLinkRequiredLevel(resultLink), GetItemLinkRequiredChampionPoints(resultLink), 20)

		ItemTooltip:AddLine(zo_strformat(str.TOOLTIP_CREATES, level, GetItemLinkName(resultLink)), "ZoFontWinH5", 1, 1, 1, BOTTOM)
		if SousChef.settings.showAltKnowledge then
			local knownBy = SousChef.settings.Cookbook[u.CleanString(GetItemLinkName(resultLink))]
			if knownBy then
				ItemTooltip:AddLine(str.TOOLTIP_KNOWN_BY, "ZoFontWinH5", 1,1,1, BOTTOM, MODIFY_TEXT_TYPE_UPPERCASE)
				ItemTooltip:AddLine(u.TableKeyConcat(knownBy))
			end
		end
		return false
	end

	--if we're only showing items on the shopping list, and we've already hidden this item, then don't touch it!
	if SousChef.settings.onlyShowShopping and SousChef.slotLines[row:GetName()] and SousChef.slotLines[row:GetName()]:IsHidden() then return end

	--item is an ingredient
	local itemId = u.GetItemID(itemLink) -- Get itemId of inventory or loot or store slot
	local usableIngredient
	if SousChef.settings.showAltIngredientKnowledge then
		usableIngredient = SousChef.settings.ReverseCookbook[itemId]
	else
		usableIngredient = SousChef.ReverseCookbook[itemId]
	end
	if usableIngredient then
		ZO_Tooltip_AddDivider(ItemTooltip)
		ItemTooltip:AddLine(str.TOOLTIP_USED_IN, "ZoFontWinH5", 1,1,1, BOTTOM, MODIFY_TEXT_TYPE_UPPERCASE)
		for i,v in ipairs(usableIngredient) do
			local line = zo_strformat("<<t:1>>", v)
			if type(SousChef.settings.shoppingList[v]) == "table" and next(SousChef.settings.shoppingList[v]) then
				line = "*(" .. u.TableKeyConcat(SousChef.settings.shoppingList[v])..") ".. line
			end
			if SousChef.settings.showCounts then
				local bookmark = SousChef.CookbookIndex[v]
				if bookmark then
					local count = CalculateHowManyCouldBeCreated(bookmark.listIndex, bookmark.recipeIndex, bookmark.numIngredients)
					if count > 0 then
						line = line .." - (" .. count .. ")"
					end
				end
			end
			ItemTooltip:AddLine(line)
		end
	end
	return false
end

function SousChef.AddRecipeToIgnoreList(link)
	if GetItemLinkInfo(link) ~= "" then link = string.match(link, "([%w\128-\244 ]+)%]") end
	SousChef.settings.ignoredRecipes[link] = true
	d(str.SC_ADDING1 .. link .. str.SC_ADDING2)

end

function SousChef.RemoveRecipeFromIgnoreList(link)
	if GetItemLinkInfo(link) ~= "" then link = string.match(link, "([%w\128-\244 ]+)%]") end
	if not SousChef.settings.ignoredRecipes[link] then d(link .. str.SC_NOT_FOUND) return end
	SousChef.settings.ignoredRecipes[link] = nil
	d(str.SC_REMOVING1 .. link .. str.SC_REMOVING2)
end

function SousChef.ListIgnoredRecipes()
	d(str.SC_IGNORED)
	 for recipe in pairs(SousChef.settings.ignoredRecipes) do
		d(recipe)
	end
end