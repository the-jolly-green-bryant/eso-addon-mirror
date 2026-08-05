local LCCC = LibCodesCommonCode
local LIS = LibItemSets
local LMAS = LibMultiAccountSets
local LUP = LibUndauntedPledges
local LEJ = LibExtendedJournal
local ItemBrowser = ItemBrowser

-- Ensure LMAS is 3.0 or newer
if (LMAS and not LMAS.GetServerAndAccountList) then LMAS = nil end


--------------------------------------------------------------------------------
-- Extended Journal
--------------------------------------------------------------------------------

local TAB_NAME = "ItemBrowser"
local FRAME = ItemBrowserFrame
local DATA_TYPE = 1
local SORT_TYPE = 1

local Initialized = 0
local Dirtiness = 0
local AlwaysRefreshOnShow = false
local ContextMenuItems = { }

function ItemBrowser.InitializeBrowser( )
	LEJ.RegisterTab(TAB_NAME, {
		title = SI_ITEMBROWSER_TITLE,
		order = 200,
		iconPrefix = "/esoui/art/collections/collections_tabicon_itemsets_",
		control = FRAME,
		settingsPanel = ItemBrowser.settingsPanel,
		binding = "ITEMBROWSER",
		slashCommands = { "/itembrowser", "/ib" },
		callbackShow = function( )
			ItemBrowser.LazyInitializeBrowser()
			ItemBrowser.RefreshBrowser(true)
		end,
	})
end

function ItemBrowser.LazyInitializeBrowser( )
	if (Initialized == 0) then
		Initialized = 1

		ItemBrowser.LazyInitializeBrowserLookupTables()

		-- Instantiate the browser
		ItemBrowser.list = ItemBrowserList:New(FRAME, ContextMenuItems)

		-- Listen for changes
		if (LMAS) then
			LMAS.RegisterForCallback(ItemBrowser.name, LMAS.EVENT_COLLECTION_UPDATED, ItemBrowser.RefreshCollections)
		else
			EVENT_MANAGER:RegisterForEvent(ItemBrowser.name, EVENT_ITEM_SET_COLLECTIONS_UPDATED, ItemBrowser.RefreshCollections)
			EVENT_MANAGER:RegisterForEvent(ItemBrowser.name, EVENT_ITEM_SET_COLLECTION_UPDATED, ItemBrowser.RefreshCollections)
		end

		-- Keep the current zone filter updated
		LCCC.MonitorZoneChanges(ItemBrowser.name, function( )
			if (Dirtiness == 0) then
				Dirtiness = 1
			end
			ItemBrowser.RefreshBrowser()
		end)

		Initialized = 2
	end
end

function ItemBrowser.RefreshBrowser( noActiveCheck )
	if (Initialized > 1 and (Dirtiness > 0 or AlwaysRefreshOnShow) and (noActiveCheck or LEJ.IsTabActive(TAB_NAME))) then
		if (Dirtiness == 1 or (Dirtiness == 0 and AlwaysRefreshOnShow)) then
			ItemBrowser.list:RefreshFilters()
		else
			ItemBrowser.list:RefreshCollectionCount()
		end
		Dirtiness = 0
	end
end

function ItemBrowser.RefreshCollections( )
	Dirtiness = 2
	ItemBrowser.RefreshBrowser()
end


--------------------------------------------------------------------------------
-- Register Context Menu
--------------------------------------------------------------------------------

function ItemBrowser.RegisterContextMenuItem( func )
	table.insert(ContextMenuItems, func)
end

ItemBrowser.RegisterContextMenuItem(function( data )
	return SI_ITEM_ACTION_LINK_TO_CHAT, function( )
		ZO_LinkHandler_InsertLink(data.itemLink:gsub(":0(:0:%d+:0|h|h)$", ":1%1", 1))
	end
end)

ItemBrowser.RegisterContextMenuItem(function( data )
	local setId, label, mode = data.setId
	if (not ItemBrowser.vars.favorites[setId]) then
		label, mode = SI_COLLECTIBLE_ACTION_ADD_FAVORITE, true
	else
		label, mode = SI_COLLECTIBLE_ACTION_REMOVE_FAVORITE, nil
	end

	return label, function( )
		ItemBrowser.vars.favorites[setId] = mode
		ItemBrowser.list:RefreshFilters()
	end
end)

ItemBrowser.RegisterContextMenuItem(function( data )
	return "ID", data.setId
end)


--------------------------------------------------------------------------------
-- LibMultiAccountSets Support
--------------------------------------------------------------------------------

local SelectedServer, SelectedAccount
local CountUnlockedSlots = GetNumItemSetCollectionSlotsUnlocked
local GetCurrencyCost = GetItemReconstructionCurrencyOptionCost
if (LMAS) then
	CountUnlockedSlots = function(...) return LMAS.GetNumItemSetCollectionSlotsUnlockedForAccountEx(SelectedServer, SelectedAccount, ...) end
	GetCurrencyCost = function(...) return LMAS.GetItemReconstructionCurrencyOptionCostForAccountEx(SelectedServer, SelectedAccount, ...) end
	SelectedServer = LCCC.GetServerName()
end


--------------------------------------------------------------------------------
-- LibUndauntedPledges Support
--------------------------------------------------------------------------------

local function CheckForPledge( zoneIds )
	if (LUP) then
		for _, zoneId in ipairs(zoneIds) do
			if (LUP.IsPledge(zoneId, 0, SelectedServer)) then
				return true
			end
		end
		return false
	else
		return true
	end
end


--------------------------------------------------------------------------------
-- Sourcing Filter IDs
--  1: All Categories
--  2: Collectible
--  3: Crafted
--  4: Overland
--  5: PvP
--  6: Dungeons
--  7: Trials
--  8: Arenas
--  9: Antiquities
-- 10: Bind On Equip
-- 11: Bind On Pickup
-- 12: Current Zone
-- 13: Favorites
-- 14: Today's Pledges
--------------------------------------------------------------------------------

local FILTER_ID_ALL = 1
local FILTER_ID_CURZONE = 12
local FILTER_ID_FAVORITES = 13
local FILTER_ID_PLEDGES = 14
local FILTER_ID_MAX = FILTER_ID_PLEDGES + (LUP and 0 or -1)


--------------------------------------------------------------------------------
-- Miscellaneous Helpers
--------------------------------------------------------------------------------

local SPECIAL_SETTYPE_FLAGS, FLAG_TO_SETTYPE_LABELS, FILTERID_TO_FLAG

function ItemBrowser.LazyInitializeBrowserLookupTables( )
	SPECIAL_SETTYPE_FLAGS = { LIS.SPECIAL_CRAFTABLE, LIS.SPECIAL_ABILITY_WEAPON, LIS.SPECIAL_MONSTER_SET, LIS.SPECIAL_MYTHIC }

	FLAG_TO_SETTYPE_LABELS = {
		[LIS.ARMOR_WEIGHT_L] = { ZO_CachedStrFormat("<<C:1>>", GetString("SI_ARMORTYPE", ARMORTYPE_LIGHT)), LCCC.RGBAToInt32(GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER, COMBAT_MECHANIC_FLAGS_MAGICKA)) },
		[LIS.ARMOR_WEIGHT_M] = { ZO_CachedStrFormat("<<C:1>>", GetString("SI_ARMORTYPE", ARMORTYPE_MEDIUM)), LCCC.RGBAToInt32(GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER, COMBAT_MECHANIC_FLAGS_STAMINA)) },
		[LIS.ARMOR_WEIGHT_H] = { ZO_CachedStrFormat("<<C:1>>", GetString("SI_ARMORTYPE", ARMORTYPE_HEAVY)), LCCC.RGBAToInt32(GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER, COMBAT_MECHANIC_FLAGS_HEALTH)) },
		[LIS.ARMOR_WEIGHT_ALL] = { GetString("SI_DYEHUECATEGORY", DYE_HUE_CATEGORY_MIXED), 0x66CCCCFF },
		[LIS.ARMOR_WEIGHT_NONE] = { GetString("SI_GAMEPADITEMCATEGORY", GAMEPAD_ITEM_CATEGORY_JEWELRY), LCCC.RGBAToInt32(GetItemQualityColor(ITEM_DISPLAY_QUALITY_ARTIFACT):UnpackRGBA()) },
		[LIS.SPECIAL_CRAFTABLE] = { GetString(SI_ITEMBROWSER_TYPE_CRAFTED), 0xFF99CCFF },
		[LIS.SPECIAL_ABILITY_WEAPON] = { ZO_CachedStrFormat("<<C:1>>", GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON)), LCCC.RGBAToInt32(GetItemQualityColor(ITEM_DISPLAY_QUALITY_LEGENDARY):UnpackRGBA()) },
		[LIS.SPECIAL_MONSTER_SET] = { GetString(SI_ITEMBROWSER_TYPE_MONSTER), 0x885533FF },
		[LIS.SPECIAL_MYTHIC] = { GetString("SI_ITEMDISPLAYQUALITY", ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE), LCCC.RGBAToInt32(GetItemQualityColor(ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE):UnpackRGBA()) },
	}

	FILTERID_TO_FLAG = {
		[ 2] = LIS.SET_IS_COLLECTIBLE,
		[ 3] = LIS.SPECIAL_CRAFTABLE,
		[ 4] = LIS.SOURCE_TYPE_OVERLAND + LIS.SET_IS_COLLECTIBLE,
		[ 5] = LIS.SOURCE_TYPE_PVP + LIS.SET_IS_COLLECTIBLE,
		[ 6] = LIS.SOURCE_TYPE_DUNGEON,
		[ 7] = LIS.SOURCE_TYPE_TRIAL,
		[ 8] = LIS.SOURCE_TYPE_ARENA,
		[ 9] = LIS.SOURCE_TYPE_ANTIQUITIES,
		[10] = LIS.SET_IS_BIND_ON_EQUIP,
		[11] = LIS.SET_IS_BIND_ON_PICKUP,
	}
end

local function GetSetBonuses( itemLink, numBonuses )
	local bonuses = { }
	for i = 1, numBonuses do
		bonuses[i] = select(2, GetItemLinkSetBonusInfo(itemLink, false, i))
	end
	return bonuses
end

local function IsInTable( haystack, needle )
	for _, v in ipairs(haystack) do
		if (v == needle) then
			return true
		end
	end
	return false
end


--------------------------------------------------------------------------------
-- ItemBrowserList
--------------------------------------------------------------------------------

ItemBrowserList = ExtendedJournalSortFilterList:Subclass()
local ItemBrowserList = ItemBrowserList

function ItemBrowserList:Setup( )
	ZO_ScrollList_AddDataType(self.list, DATA_TYPE, "ItemBrowserListRow", 30, function(...) self:SetupItemRow(...) end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self:SetAlternateRowBackgrounds(true)

	self.masterList = { }

	local sortKeys = {
		["name"]     = { caseInsensitive = true },
		["itemType"] = { caseInsensitive = true, tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP },
		["source"]   = { caseInsensitive = true, tiebreaker = "itemType", tieBreakerSortOrder = ZO_SORT_ORDER_UP },
		["progress"] = { isNumeric = true, tiebreaker = "setSize" },
		["setSize"]  = { isNumeric = true, tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP },
	}

	self.currentSortKey = "name"
	self.currentSortOrder = ZO_SORT_ORDER_UP
	self.sortHeaderGroup:SelectAndResetSortForKey(self.currentSortKey)
	self.sortFunction = function( listEntry1, listEntry2 )
		return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, sortKeys, self.currentSortOrder)
	end

	self.filterDrop = ZO_ComboBox_ObjectFromContainer(self.frame:GetNamedChild("FilterDrop"))
	self:InitializeComboBox(self.filterDrop, { prefix = "SI_ITEMBROWSER_FILTERDROP", max = FILTER_ID_MAX }, ItemBrowser.vars.filterId)

	self.searchDrop = ZO_ComboBox_ObjectFromContainer(self.frame:GetNamedChild("SearchDrop"))
	self:InitializeComboBox(self.searchDrop, { prefix = "SI_ITEMBROWSER_SEARCHDROP", max = 2 })

	self.searchBox = self.frame:GetNamedChild("SearchBox")
	self.searchBox:SetHandler("OnTextChanged", function() self:RefreshFilters() end)
	self.search = self:InitializeSearch(SORT_TYPE)

	if (LMAS) then
		local servers = LMAS.GetServerAndAccountList(true)

		if (#servers > 1 or #servers[1].accounts > 1) then
			local control = self.frame:GetNamedChild("AccountDrop")
			control:GetNamedChild("Caption"):SetText(GetString(SI_LEJ_ACCOUNT))
			control:SetHidden(false)
			self.accountDrop = ZO_ComboBox_ObjectFromContainer(control)

			if (#servers > 1) then
				local control = self.frame:GetNamedChild("ServerDrop")
				control:GetNamedChild("Caption"):SetText(GetString(SI_LEJ_SERVER))
				control:SetHidden(false)
				self.serverDrop = ZO_ComboBox_ObjectFromContainer(control)
				self:InitializeComboBox(self.serverDrop, { list = servers, key = "server" }, nil, true, function( comboBox, entryText, entry, selectionChanged )
					SelectedServer = entryText
					self:RefreshAccountList()
				end)
			else
				self:RefreshAccountList()
			end
		end
	end

	self:RefreshData()
end

function ItemBrowserList:BuildMasterList( )
	self.masterList = { }
	for _, setId in ipairs(LIS.GetAllItemSetIds()) do
		local info = LIS.GetItemSetInfo(setId)

		-- Text and color for the type column, starting with special types
		local itemType, color
		for _, flag in ipairs(SPECIAL_SETTYPE_FLAGS) do
			if (LIS.CheckFlag(info.flags, flag)) then
				itemType, color = unpack(FLAG_TO_SETTYPE_LABELS[flag])
				if (info.craftTraits) then
					itemType = string.format("%s (%d)", itemType, info.craftTraits)
				end
				break
			end
		end

		-- If not a special type, then check armor weight
		if (not itemType) then
			itemType, color = unpack(FLAG_TO_SETTYPE_LABELS[BitAnd(info.flags, LIS.ARMOR_WEIGHT_MASK)])
		end

		-- Sourcing
		local sourceNames = { }
		for _, sourceId in ipairs(info.sourceIds) do
			local name = LIS.GetSourceName(sourceId)
			if (name ~= sourceNames[#sourceNames]) then -- Consolidate cases where a single location has multiple zoneIds
				table.insert(sourceNames, name)
			end
		end
		local source = table.concat(sourceNames, ", ")
		if (info.extraSourceInfo) then
			source = string.format("%s (%s)", source, info.extraSourceInfo)
		end

		-- Set collection
		local setSize, setFound, progress
		setSize = info.numCollectiblePieces
		if (setSize > 0) then
			setFound = CountUnlockedSlots(setId)
			if (ItemBrowser.vars.usePercentage) then
				progress = setFound / setSize
			else
				progress = 100 - (GetCurrencyCost(setId, CURT_CHAOTIC_CREATIA) or 100)
			end
		else
			setFound = 0
			progress = (ItemBrowser.vars.usePercentage) and 2 or 200
		end

		table.insert(self.masterList, {
			type = SORT_TYPE,
			setId = setId,
			name = info.setName,
			itemType = itemType,
			source = source,
			flags = info.flags,
			sourceIds = info.sourceIds,
			color = color,
			bonuses = info.numBonuses,
			itemLink = info.sampleItemLink,
			setSize = setSize,
			setFound = setFound,
			progress = progress,
		})
	end
end

function ItemBrowserList:FilterScrollList( )
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

	self.searchType = self.searchDrop:GetSelectedItemData().id
	local filterId = self.filterDrop:GetSelectedItemData().id
	ItemBrowser.vars.filterId = filterId

	local searchInput = self.searchBox:GetText()

	-- For the filters that can use flags
	local flagToCheck = FILTERID_TO_FLAG[filterId]

	-- Pre-check for the current zone ID; all of the "main" gear zones
	-- should have a valid zoneClassification, so if we can't match
	-- our current zone ID or our parent zone ID to a zoneClassification,
	-- then there's no point in checking against the zone IDs for each set
	local zoneId = 0
	if (filterId == FILTER_ID_CURZONE) then
		zoneId = LCCC.GetZoneId()
		if (not next(LIS.GetAllItemSetIdsForSource(zoneId))) then
			zoneId = GetParentZoneId(zoneId)
			if (not next(LIS.GetAllItemSetIdsForSource(zoneId))) then
				zoneId = 0
			end
		end
	end

	-- Because pledges can change over time, always refresh when show the window with that category active
	AlwaysRefreshOnShow = filterId == FILTER_ID_PLEDGES

	local totalCollectibles = 0
	local foundCollectibles = 0

	for _, data in ipairs(self.masterList) do
		if ( (filterId == FILTER_ID_ALL or (flagToCheck and LIS.CheckFlag(data.flags, flagToCheck)) or (filterId == FILTER_ID_FAVORITES and ItemBrowser.vars.favorites[data.setId]) or (filterId == FILTER_ID_PLEDGES and CheckForPledge(data.sourceIds)) or (zoneId > 0 and IsInTable(data.sourceIds, zoneId))) and
		     (searchInput == "" or self:CheckForMatch(data, searchInput)) ) then
			table.insert(scrollData, ZO_ScrollList_CreateDataEntry(DATA_TYPE, data))
			if (data.setSize > 0) then
				totalCollectibles = totalCollectibles + data.setSize
				foundCollectibles = foundCollectibles + data.setFound
			end
		end
	end

	self.frame:GetNamedChild("CollectedCount"):SetText((totalCollectibles > 0) and string.format(GetString(SI_ITEMBROWSER_COLLECTED_COUNT), foundCollectibles, totalCollectibles, 100 * foundCollectibles / totalCollectibles) or "")

	if (#scrollData ~= #self.masterList) then
		self.frame:GetNamedChild("Counter"):SetText(string.format("%d / %d", #scrollData, #self.masterList))
	else
		self.frame:GetNamedChild("Counter"):SetText(string.format("%d", #self.masterList))
	end
end

function ItemBrowserList:SetupItemRow( control, data )
	local cell, cell2

	cell = control:GetNamedChild("Name")
	cell.normalColor = ZO_DEFAULT_TEXT
	cell:SetText(data.name)

	cell = control:GetNamedChild("Type")
	cell.nonRecolorable = true
	cell:SetColor(LCCC.Int32ToRGBA(data.color))
	cell:SetText(data.itemType)

	cell = control:GetNamedChild("Source")
	cell.normalColor = ZO_DEFAULT_TEXT
	cell:SetText(data.source)

	cell = control:GetNamedChild("Collected")
	cell2 = control:GetNamedChild("CollectedCount")
	if (data.setSize > 0) then
		local color, ratio

		if (ItemBrowser.vars.usePercentage) then
			ratio = data.progress
			if (ratio == 0) then
				color = 0xFF0000CC
			elseif (ratio == 1) then
				color = 0x00FF00CC
			end
			cell:SetText(string.format("%d%%", 100 * ratio))
		else
			local cost = 100 - data.progress
			if (cost > 75) then
				color = 0xFF0000CC
			elseif (cost == 25) then
				color = 0x00FF00CC
			else
				ratio = (75 - cost) / 50
			end
			cell:SetText(ItemBrowser.FormatTransmuteCost(cost))
		end

		cell.nonRecolorable = true
		if (color) then
			cell:SetColor(LCCC.Int32ToRGBA(color))
		else
			cell:SetColor(LCCC.HSLToRGB((ratio * 0.6 + 0.15) / 3, 1, 0.5, 0.8))
		end

		cell2.nonRecolorable = true
		cell2:SetColor(LCCC.Int32ToRGBA(0xFFFFFF66))
		cell2:SetText(string.format("%d/%d", data.setFound, data.setSize))
	else
		cell:SetText("")
		cell2:SetText("")
	end

	self:SetupRow(control, data)
end

function ItemBrowserList:RefreshCollectionCount( )
	if (Initialized < 2) then return end

	for _, data in ipairs(self.masterList) do
		if (data.setSize > 0) then
			data.setFound = CountUnlockedSlots(data.setId)
			if (ItemBrowser.vars.usePercentage) then
				data.progress = data.setFound / data.setSize
			else
				data.progress = 100 - (GetCurrencyCost(data.setId, CURT_CHAOTIC_CREATIA) or 100)
			end
		end
	end

	self:RefreshFilters()
end

function ItemBrowserList:OrderedSearch( haystack, needles )
	-- A search for "spell damage" should match "Spell and Weapon Damage" but
	-- not "damage from enemy spells", so search term order must be considered

	haystack = haystack:lower()
	needles = needles:lower()

	local i = 0

	for needle in needles:gmatch("%S+") do
		i = haystack:find(needle, i + 1, true)
		if (not i) then return false end
	end

	return true
end

function ItemBrowserList:SearchSetBonuses( bonuses, searchInput )
	local curpos = 1
	local delim
	local exclude = false

	repeat
		local found = false

		delim = searchInput:find("[+,-]", curpos)
		if (not delim) then delim = 0 end

		local searchQuery = searchInput:sub(curpos, delim - 1)

		if (searchQuery:find("%S+")) then
			for _, bonus in ipairs(bonuses) do
				if (self:OrderedSearch(bonus, searchQuery)) then
					found = true
					break
				end
			end

			if (found == exclude) then return false end
		end

		curpos = delim + 1
		if (delim ~= 0) then exclude = searchInput:sub(delim, delim) == "-" end
	until delim == 0

	return true
end

function ItemBrowserList:CheckForMatch( data, searchInput )
	local curpos = 1
	local delim

	repeat
		delim = searchInput:find("|", curpos)
		if (not delim) then delim = 0 end

		local searchFragment = searchInput:sub(curpos, delim - 1)

		-- Allow empty query if it is the only (i.e., first and last) query
		if (searchFragment:find("%S+") or (curpos == 1 and delim == 0)) then
			if (self.searchType == 1) then
				if (self.search:IsMatch(searchFragment, data)) then return true end
			elseif (self.searchType == 2) then
				if (type(data.bonuses) == "number") then
					-- Lazy initialization of set bonus data
					data.bonuses = GetSetBonuses(data.itemLink, data.bonuses)
				end
				if (self:SearchSetBonuses(data.bonuses, searchFragment)) then return true end
			end
		end

		curpos = delim + 1
	until delim == 0

	return false
end

function ItemBrowserList:ProcessItemEntry( stringSearch, data, searchTerm, cache )
	if (searchTerm == "+") then
		return data.setSize == data.setFound
	elseif (searchTerm == "-") then
		return data.setSize > data.setFound
	end

	if ( zo_plainstrfind(data.name:lower(), searchTerm) or
	     zo_plainstrfind(data.itemType:lower(), searchTerm) or
	     zo_plainstrfind(data.source:lower(), searchTerm) ) then
		return true
	end

	return false
end

function ItemBrowserList:RefreshAccountList( )
	local accounts
	for _, server in ipairs(LMAS.GetServerAndAccountList(true)) do
		if (SelectedServer == server.server or not accounts) then
			accounts = server.accounts
		end
	end

	-- Try to keep the same account selected when changing servers
	local initialIndex
	for i, account in ipairs(accounts) do
		if (SelectedAccount == account) then
			initialIndex = i
		end
	end

	self:InitializeComboBox(self.accountDrop, { list = accounts }, initialIndex, true, function( comboBox, entryText, entry, selectionChanged )
		SelectedAccount = entryText
		self:RefreshCollectionCount()
	end)
end


--------------------------------------------------------------------------------
-- XML Handlers
--------------------------------------------------------------------------------

local Tooltip = ItemTooltip

function ItemBrowserListRow_OnMouseEnter( control )
	local data = ZO_ScrollList_GetData(control)
	ItemBrowser.list:Row_OnMouseEnter(control)

	local itemLink = data.itemLink
	Tooltip = LEJ.ItemTooltip(itemLink)
	ItemBrowser.AddTooltipExtension(Tooltip, itemLink, SelectedAccount, 0x0B, nil, SelectedServer) -- See FLAG_BROWSER_ITEM in Tooltip.lua
end

function ItemBrowserListRow_OnMouseExit( control )
	ItemBrowser.list:Row_OnMouseExit(control)

	ClearTooltip(Tooltip)
end

function ItemBrowserListRow_OnMouseUp( ... )
	ItemBrowser.list:Row_OnMouseUp(...)
end
