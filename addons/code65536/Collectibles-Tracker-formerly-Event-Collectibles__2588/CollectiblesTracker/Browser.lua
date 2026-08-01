local LCCC = LibCodesCommonCode
local LMAC = LibMultiAccountCollectibles
local LEJ = LibExtendedJournal
local CollectiblesTracker = CollectiblesTracker


--------------------------------------------------------------------------------
-- Extended Journal
--------------------------------------------------------------------------------

local DATA_TYPE = 1
local SORT_TYPE = 1

local Tabs = {
	ct = {
		name = "CollectiblesTracker",
		title = SI_COLLECTIBLESTRACKER_TITLE,
		order = 400,
		icon = "/esoui/art/mainmenu/menubar_collections_",
		frameName = "CollectiblesTrackerFrame",
		binding = "COLLECTIBLESTRACKER",
		slashCommand = "/collectiblestracker",
	},

	ec = {
		name = "EventCollectibles",
		title = SI_EVENTCOLLECTIBLES_TITLE,
		order = 410,
		icon = "/esoui/art/treeicons/achievements_indexicon_events_",
		frameName = "EventCollectiblesFrame",
		binding = "EVENTCOLLECTIBLES",
		slashCommand = "/eventcollectibles",
	},
}

local ContextMenuItems = { }

function CollectiblesTracker.InitializeBrowser( )
	for key, tab in pairs(Tabs) do
		tab.control = WINDOW_MANAGER:CreateControlFromVirtual(tab.frameName, GuiRoot, "CollectiblesListFrame")
		tab.initialized = 0
		tab.dirtiness = 0

		LEJ.RegisterTab(tab.name, {
			title = tab.title,
			subtitle = tab.subtitle,
			order = tab.order,
			iconPrefix = tab.icon,
			control = tab.control,
			binding = tab.binding,
			slashCommands = tab.slashCommand and { tab.slashCommand },
			callbackShow = function( )
				CollectiblesTracker.LazyInitializeBrowser(key)
				CollectiblesTracker.RefreshBrowser(key, true)
			end,
		})
	end
end

function CollectiblesTracker.LazyInitializeBrowser( key )
	local tab = Tabs[key]
	if (tab.initialized == 0) then
		tab.initialized = 1

		-- Instantiate the browser
		tab.obj = CollectiblesList:New(tab.control, ContextMenuItems, key)

		-- Listen for changes
		local refresh = function( )
			tab.dirtiness = 1
			CollectiblesTracker.RefreshBrowser(key)
		end

		if (LMAC) then
			LMAC.RegisterForCallback(CollectiblesTracker.name .. key, LMAC.EVENT_COLLECTION_UPDATED, refresh)
		else
			EVENT_MANAGER:RegisterForEvent(CollectiblesTracker.name .. key, EVENT_COLLECTIBLES_UNLOCK_STATE_CHANGED, refresh)
		end

		tab.initialized = 2
	end
end

function CollectiblesTracker.RefreshBrowser( key, noActiveCheck )
	local tab = Tabs[key]
	if (tab.initialized > 1 and tab.dirtiness > 0 and (noActiveCheck or LEJ.IsTabActive(tab.name))) then
		tab.obj:RefreshData()
		tab.dirtiness = 0
	end
end


--------------------------------------------------------------------------------
-- Register Context Menu
--------------------------------------------------------------------------------

function CollectiblesTracker.RegisterContextMenuItem( func )
	table.insert(ContextMenuItems, func)
end

CollectiblesTracker.RegisterContextMenuItem(function( data )
	return SI_ITEM_ACTION_LINK_TO_CHAT, function( )
		ZO_LinkHandler_InsertLink(data.itemLink)
	end
end)

CollectiblesTracker.RegisterContextMenuItem(function( data )
	local obj = Tabs[data.key].obj
	local hideVars = obj.vars.hide
	local hideState = hideVars[data.id]
	return GetString("SI_COLLECTIBLESTRACKER_HIDE", hideState and 1 or 0), function( )
		hideVars[data.id] = not hideState and true or nil
		obj:RefreshFilters()
		obj:RefreshShowHiddenState()
	end
end)

CollectiblesTracker.RegisterContextMenuItem(function( data )
	return "ID", data.id
end)


--------------------------------------------------------------------------------
-- Third-Party Tabs
-- Must be run prior to EVENT_ADD_ON_LOADED
--------------------------------------------------------------------------------

function CollectiblesTracker.RegisterThirdPartyTab( key, tabInfo, dataGenerator )
	if (not Tabs[key]) then
		Tabs[key] = tabInfo
		CollectiblesTracker.dataGen[key] = dataGenerator
		CollectiblesTracker.defaults[key] = LCCC.MergeTables(nil, CollectiblesTracker.defaults.ct)
	end
end


--------------------------------------------------------------------------------
-- Workers for ProcessNumericTable
--------------------------------------------------------------------------------

local function CountFragmentsWorker( id, index, self, fragments )
	if (index > 1 and type(id) == "number") then
		if (self.IsCollectibleOwned(id)) then
			fragments.collected = fragments.collected + 1
		end
		table.insert(fragments.ids, id)
	end
end

local function BuildMasterListWorker( entry, _, self, i, source )
	local status, fragments
	if (type(entry) == "table") then
		if (#entry > 1) then
			fragments = {
				collected = 0,
				ids = { },
			}
			LCCC.ProcessNumericTable(entry, CountFragmentsWorker, self, fragments)
		end

		-- Initialize morph set if item is a base morph
		if (entry[#entry] == true) then
			self.morphSets[i] = {
				base = entry[1],
				owned = 0,
				total = 0,
			}
		end

		entry = entry[1]
	end

	local name, _, _, _, unlocked, _, _, categoryType = GetCollectibleInfo(entry)

	if (name == "" and Tabs[self.key].allowInvalid) then
		name = GetCollectibleName(entry)
		if (name == "") then
			name = string.format("#%d", entry)
		end
	end

	if (name ~= "") then
		if (LMAC) then unlocked = self.IsCollectibleOwned(entry) end

		if (unlocked) then
			status = 2
		elseif (fragments) then
			status = fragments.collected / #fragments.ids
		else
			status = 0
		end

		-- Process morph set stats
		if (fragments) then
			local set = self.morphSets[i]
			if (set) then
				if (unlocked) then
					set.owned = set.owned + 1
				end
				set.total = set.total + 1
			end
		end

		table.insert(self.masterList, {
			type = SORT_TYPE,
			id = entry,
			name = zo_strformat(SI_TOOLTIP_ITEM_NAME, name),
			status = status,
			fragmentsKnown = fragments and fragments.collected,
			fragments = fragments and fragments.ids,
			category = GetString("SI_COLLECTIBLECATEGORYTYPE", categoryType),
			source = source[1],
			sourceId = i,
			itemLink = string.format("|H1:collectible:%d|h|h", entry),
			key = self.key,
		})
	end
end


--------------------------------------------------------------------------------
-- CollectiblesList
--------------------------------------------------------------------------------

CollectiblesList = ExtendedJournalSortFilterList:Subclass()
local CollectiblesList = CollectiblesList

function CollectiblesList:Setup( key )
	self.key = key
	self.vars = CollectiblesTracker.vars[key]
	self.data = CollectiblesTracker.data[key]

	-- LibMultiAccountCollectibles Support
	self.IsCollectibleOwned = IsCollectibleOwnedByDefId
	if (LMAC) then
		self.IsCollectibleOwned = function(...) return LMAC.IsCollectibleOwnedByAccount(self.selectedServer, self.selectedAccount, ...) end
		self.selectedServer = LCCC.GetServerName()
	end

	ZO_ScrollList_AddDataType(self.list, DATA_TYPE, "CollectiblesListRow", 30, function(...) self:SetupItemRow(...) end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self:SetAlternateRowBackgrounds(true)

	local sortKeys = {
		["name"]     = { caseInsensitive = true },
		["status"]   = { isNumeric = true, tiebreaker = "source", tieBreakerSortOrder = ZO_SORT_ORDER_UP },
		["category"] = { caseInsensitive = true, tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP },
		["source"]   = { caseInsensitive = true, tiebreaker = "category", tieBreakerSortOrder = ZO_SORT_ORDER_UP },
	}

	self.currentSortKey = "source"
	self.currentSortOrder = ZO_SORT_ORDER_UP
	self.sortHeaderGroup:SelectAndResetSortForKey(self.currentSortKey)
	self.sortFunction = function( listEntry1, listEntry2 )
		return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, sortKeys, self.currentSortOrder)
	end

	self.showHidden = self.frame:GetNamedChild("ShowHidden")
	if (self.vars.showHidden) then
		ZO_CheckButton_SetChecked(self.showHidden)
	else
		ZO_CheckButton_SetUnchecked(self.showHidden)
	end
	ZO_CheckButton_SetToggleFunction(self.showHidden, function( )
		self.vars.showHidden = ZO_CheckButton_IsChecked(self.showHidden) and true or nil
		self:RefreshFilters()
	end)
	self:RefreshShowHiddenState()

	self.filterDrop = ZO_ComboBox_ObjectFromContainer(self.frame:GetNamedChild("FilterDrop"))
	self:InitializeComboBox(self.filterDrop, { list = self.data, key = 1 }, self.vars.filterId)

	self.searchBox = self.frame:GetNamedChild("SearchFieldBox")
	self.searchBox:SetHandler("OnTextChanged", function() self:RefreshFilters() end)
	self.search = self:InitializeSearch(SORT_TYPE)

	if (LMAC) then
		local servers = LMAC.GetServerAndAccountList(true)

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
					self.selectedServer = entryText
					self:RefreshAccountList()
				end)
			else
				self:RefreshAccountList()
			end
		end
	end

	self:RefreshData()
end

function CollectiblesList:BuildMasterList( )
	self.masterList = { }
	self.morphSets = { }

	for i, source in ipairs(self.data) do
		for j = 2, #source do
			LCCC.ProcessNumericTable(source[j], BuildMasterListWorker, self, i, source)
		end
	end
end

function CollectiblesList:FilterScrollList( )
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

	local filterId = self.filterDrop:GetSelectedItemData().id
	self.vars.filterId = filterId

	local searchInput = self.searchBox:GetText()

	local collected = 0

	for _, data in ipairs(self.masterList or { }) do
		if ( (filterId == 1 or filterId == data.sourceId) and
		     (self.vars.showHidden or not self.vars.hide[data.id]) and
		     (searchInput == "" or self.search:IsMatch(searchInput, data)) ) then
			table.insert(scrollData, ZO_ScrollList_CreateDataEntry(DATA_TYPE, data))
			if (data.status == 2) then
				collected = collected + 1
			end
		end
	end

	self.frame:GetNamedChild("CollectedCount"):SetText((#scrollData > 0) and string.format(GetString(SI_COLLECTIBLESTRACKER_COLLECTED_COUNT), collected, #scrollData, 100 * collected / #scrollData) or "")
end

function CollectiblesList:SetupItemRow( control, data )
	local cell

	cell = control:GetNamedChild("Name")
	cell.normalColor = ZO_DEFAULT_TEXT
	cell:SetText(data.name)
	control:GetNamedChild("Icon"):SetTexture(GetCollectibleIcon(data.id))

	cell = control:GetNamedChild("Status")
	cell.nonRecolorable = true
	if (data.status == 2) then
		cell:SetColor(0, 1, 0, 1)
		cell:SetText(GetString(SI_YES))
	else
		if (data.status == 0) then
			cell:SetColor(1, 0, 0, 1)
		else
			cell:SetColor(LCCC.HSLToRGB((data.status * 0.6 + 0.15) / 3, 1, 0.5, 1))
		end
		if (data.fragments) then
			cell:SetText(string.format("%d / %d", data.fragmentsKnown, #data.fragments))
		else
			cell:SetText(GetString(SI_NO))
		end
	end

	cell = control:GetNamedChild("Category")
	cell.normalColor = ZO_DEFAULT_TEXT
	cell:SetText(data.category)

	cell = control:GetNamedChild("Source")
	cell.normalColor = ZO_DEFAULT_TEXT
	cell:SetText(data.source)

	control:SetAlpha(self.vars.hide[data.id] and 0.5 or 1)

	self:SetupRow(control, data)
end

function CollectiblesList:ProcessItemEntry( stringSearch, data, searchTerm, cache )
	if ( zo_plainstrfind(data.name:lower(), searchTerm) or
	     (self.vars.filterId == 1 and zo_plainstrfind(data.source:lower(), searchTerm)) ) then
		return true
	end

	return false
end

function CollectiblesList:RefreshAccountList( )
	local accounts
	for _, server in ipairs(LMAC.GetServerAndAccountList(true)) do
		if (self.selectedServer == server.server or not accounts) then
			accounts = server.accounts
		end
	end

	-- Try to keep the same account selected when changing servers
	local initialIndex
	for i, account in ipairs(accounts) do
		if (self.selectedAccount == account) then
			initialIndex = i
		end
	end

	self:InitializeComboBox(self.accountDrop, { list = accounts }, initialIndex, true, function( comboBox, entryText, entry, selectionChanged )
		self.selectedAccount = entryText
		Tabs[self.key].dirtiness = 1
		CollectiblesTracker.RefreshBrowser(self.key)
	end)
end

function CollectiblesList:RefreshShowHiddenState( )
	local count = LCCC.CountTable(self.vars.hide)
	ZO_CheckButton_SetLabelText(self.showHidden, zo_strformat(SI_COLLECTIBLESTRACKER_SHOW_HIDDEN, count))
	self.showHidden:SetHidden(count == 0)
end

function CollectiblesList:IsIncompleteFragment( data )
	-- Simple cases
	if (not data.fragments) then return false end
	if (not self.IsCollectibleOwned(data.id)) then return true end

	-- Check if this is a base morph with partial completion of another copy
	local set = self.morphSets[data.sourceId]
	if (set and set.base == data.id) then
		for _, fragment in ipairs(data.fragments) do
			if (self.IsCollectibleOwned(fragment)) then
				return true
			end
		end
	end

	return false
end


--------------------------------------------------------------------------------
-- XML Handlers
--------------------------------------------------------------------------------

local Tooltip = ItemTooltip

local function GetObject( control, data )
	data = data or ZO_ScrollList_GetData(control)
	return data and data.key and Tabs[data.key].obj
end

function CollectiblesListRow_OnMouseEnter( control )
	local data = ZO_ScrollList_GetData(control)
	local obj = GetObject(nil, data)
	if (obj) then
		obj:Row_OnMouseEnter(control)
		Tooltip = LEJ.ItemTooltip({ collectibleId = data.id })
		if (LMAC and LMAC.AddTooltipExtension) then
			LMAC.AddTooltipExtension(Tooltip, data.id, obj.selectedServer)
		end
		if (obj:IsIncompleteFragment(data)) then
			local extension = LEJ.TooltipExtensionInitialize(false, nil, nil, "CollectibleFragments")
			local results = { }
			for _, fragment in ipairs(data.fragments) do
				table.insert(results, string.format("|c%06X%s|r", LEJ.GetTooltipColor(1, obj.IsCollectibleOwned(fragment) and 1 or 2), zo_strformat(SI_TOOLTIP_ITEM_NAME, GetCollectibleName(fragment))))
			end
			extension:AddSection(GetString(SI_ANTIQUITY_FRAGMENTS), table.concat(results, ", "))
			extension:Finalize(Tooltip)
		end
	end
end

function CollectiblesListRow_OnMouseExit( control )
	local obj = GetObject(control)
	if (obj) then
		obj:Row_OnMouseExit(control)
	end
	ClearTooltip(Tooltip)
end

function CollectiblesListRow_OnMouseUp( control, ... )
	local obj = GetObject(control)
	if (obj) then
		obj:Row_OnMouseUp(control, ...)
	end
end
