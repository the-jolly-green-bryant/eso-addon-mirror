local LEJ = LibExtendedJournal
local LootLog = LootLog


--------------------------------------------------------------------------------
-- Extended Journal
--------------------------------------------------------------------------------

local TAB_NAME = "LootLogMats"
local FRAME = LootLogMatsFrame
local DATA_TYPE = 1
local SORT_TYPE = 1

local Initialized = false
local Dirtiness = 0

function LootLog.InitializeMats( )
	LEJ.RegisterTab(TAB_NAME, {
		title = SI_LOOTLOG_TITLE,
		subtitle = SI_LOOTLOG_SUBTITLE_MATS,
		order = 110,
		iconPrefix = "/esoui/art/inventory/inventory_tabicon_crafting_",
		control = FRAME,
		settingsPanel = LootLog.settingsPanel,
		callbackShow = function( )
			LootLog.LazyInitializeMats()
			LootLog.RefreshMats(true)
			LootLog.SetRetentionText(FRAME:GetNamedChild("History"))
		end,
	})
end

function LootLog.LazyInitializeMats( )
	if (not Initialized) then
		Initialized = true
		LootLog.mats = LootLogMats:New(FRAME)
		table.insert(LootLog.refreshCallbacks, function( refreshLevel )
			if (Dirtiness < refreshLevel) then
				Dirtiness = refreshLevel
			end
			LootLog.RefreshMats()
		end)
	end
end

function LootLog.RefreshMats( noActiveCheck )
	if (Initialized and Dirtiness > 1 and (noActiveCheck or LEJ.IsTabActive(TAB_NAME))) then
		LootLog.mats:RefreshData()
		Dirtiness = 0
	end
end


--------------------------------------------------------------------------------
-- LootLogMats
--------------------------------------------------------------------------------

LootLogMats = ExtendedJournalSortFilterList:Subclass()
local LootLogMats = LootLogMats

function LootLogMats:Setup( )
	ZO_ScrollList_AddDataType(self.list, DATA_TYPE, "LootLogMatsRow", 30, function(...) self:SetupItemRow(...) end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self:SetAlternateRowBackgrounds(true)

	self.scratch = {
		processed = { },
		counts = { },
		time = 0,
	}

	local sortKeys = {
		["item"]  = { caseInsensitive = true },
		["count"] = { isNumeric = true, tiebreaker = "item" },
		["total"] = { isNumeric = true, tiebreaker = "item" },
	}

	self.currentSortKey = "item"
	self.currentSortOrder = ZO_SORT_ORDER_UP
	self.sortHeaderGroup:SelectAndResetSortForKey(self.currentSortKey)
	self.sortFunction = function( listEntry1, listEntry2 )
		return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, sortKeys, self.currentSortOrder)
	end

	self.searchBox = self.frame:GetNamedChild("SearchFieldBox")
	self.searchBox:SetHandler("OnTextChanged", function() self:RefreshFilters() end)
	self.search = self:InitializeSearch(SORT_TYPE)

	self:RefreshData()
end

function LootLogMats:BuildMasterList( )
	self.masterList = { }

	if (Dirtiness == 3) then
		self.scratch = {
			processed = { },
			counts = { },
			time = 0,
		}
	end

	for key, group in pairs(LootLog.history) do
		if (not self.scratch.processed[key]) then
			self.scratch.processed[key] = 0
		end
		for i = self.scratch.processed[key] + 1, #group do
			self.scratch.processed[key] = i
			local entry = LootLog.Unpack(group[i])

			if (entry[4] == LootLog.self.userId) then
				local itemLink = entry[2]
				if (CanItemLinkBeVirtual(itemLink)) then
					if (not self.scratch.counts[itemLink]) then
						self.scratch.counts[itemLink] = entry[3]
					else
						self.scratch.counts[itemLink] = entry[3] + self.scratch.counts[itemLink]
					end

					if (self.scratch.time > entry[1] or self.scratch.time == 0) then
						self.scratch.time = entry[1]
					end
				end
			end
		end
	end

	for itemLink, count in pairs(self.scratch.counts) do
		local stackCountBackpack, stackCountBank, stackCountCraftBag = GetItemLinkStacks(itemLink)
		table.insert(self.masterList, {
			type = SORT_TYPE,
			itemLink = itemLink,
			item = LootLog.GetLinkName(itemLink),
			count = count,
			total = stackCountBackpack + stackCountBank + stackCountCraftBag,
		})
	end

	self.frame:GetNamedChild("Time"):SetText((self.scratch.time > 0) and string.format(GetString(SI_LOOTLOG_TIME_LABEL), os.date("%Y-%m-%d %H:%M:%S", self.scratch.time)) or "")
end

function LootLogMats:FilterScrollList( )
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

	local searchInput = self.searchBox:GetText()

	for _, data in ipairs(self.masterList or { }) do
		if (searchInput == "" or self.search:IsMatch(searchInput, data)) then
			table.insert(scrollData, ZO_ScrollList_CreateDataEntry(DATA_TYPE, data))
		end
	end

	self.frame:GetNamedChild("Counter"):SetText(string.format("%d", #scrollData))
end

function LootLogMats:SetupItemRow( control, data )
	local cell

	cell = control:GetNamedChild("Item")
	cell.normalColor = ZO_DEFAULT_TEXT
	cell:SetText(data.itemLink)
	control:GetNamedChild("Icon"):SetTexture(GetItemLinkIcon(data.itemLink))

	cell = control:GetNamedChild("Count")
	cell.normalColor = ZO_DEFAULT_TEXT
	cell:SetText(data.count)

	cell = control:GetNamedChild("Total")
	cell.normalColor = ZO_DEFAULT_TEXT
	cell:SetText(data.total)

	self:SetupRow(control, data)
end

function LootLogMats:ProcessItemEntry( stringSearch, data, searchTerm, cache )
	if ( zo_plainstrfind(data.item:lower(), searchTerm) ) then
		return true
	end

	return false
end


--------------------------------------------------------------------------------
-- XML Handlers
--------------------------------------------------------------------------------

local Tooltip = ItemTooltip

function LootLogMatsRow_OnMouseEnter( control )
	local data = ZO_ScrollList_GetData(control)
	LootLog.mats:Row_OnMouseEnter(control)

	Tooltip = LEJ.ItemTooltip(data.itemLink, ItemTooltip)
end

function LootLogMatsRow_OnMouseExit( control )
	LootLog.mats:Row_OnMouseExit(control)

	ClearTooltip(Tooltip)
end
