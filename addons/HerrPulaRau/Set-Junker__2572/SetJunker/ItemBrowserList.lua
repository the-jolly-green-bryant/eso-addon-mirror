local ITEMBROWSER_DATA = 1

ItemBrowserList = ZO_SortFilterList:Subclass()

function ItemBrowserList:New( control )
	local list = ZO_SortFilterList.New(self, control)
	list.frame = control
	list:Setup()
	return(list)
end

function ItemBrowserList:Setup( )
	ZO_ScrollList_AddDataType(self.list, ITEMBROWSER_DATA, "ItemBrowserRow", 30, function(control, data) self:SetupItemRow(control, data) end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self:SetAlternateRowBackgrounds(true)

	self.masterList = { }

	local sortKeys = {
		["junk"]     = { caseInsensitive = true },
		["name"]     = { caseInsensitive = true },
		["itemType"] = { caseInsensitive = true, tiebreaker = "name" },
		["source"]   = { caseInsensitive = true, tiebreaker = "itemType" },
	}

	self.currentSortKey = "name"
	self.currentSortOrder = ZO_SORT_ORDER_UP
	self.sortHeaderGroup:SelectAndResetSortForKey(self.currentSortKey)
	self.sortFunction = function( listEntry1, listEntry2 )
		return(ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, sortKeys, self.currentSortOrder))
	end

	self.filterDrop = ZO_ComboBox_ObjectFromContainer(self.frame:GetNamedChild("FilterDrop"))
	self:InitializeComboBox(self.filterDrop, "SI_ITEMBROWSER_FILTERDROP", 8)

	local armorPreferredTraitsContainer = SetDetailedOptions:GetNamedChild("JunkDuplicates"):GetNamedChild("Traits"):GetNamedChild("ArmorPreferredTrait")
	SetJunker.preferredArmorTrait = ZO_ComboBox_ObjectFromContainer(armorPreferredTraitsContainer)
	SetJunker:InitializeArmorTraitsComboBox(SetJunker.preferredArmorTrait)

	local weaponPreferredTraitsContainer = SetDetailedOptions:GetNamedChild("JunkDuplicates"):GetNamedChild("Traits"):GetNamedChild("WeaponPreferredTrait")
	SetJunker.preferredWeaponTrait = ZO_ComboBox_ObjectFromContainer(weaponPreferredTraitsContainer)
	SetJunker:InitializeWeaponTraitsComboBox(SetJunker.preferredWeaponTrait)

	local jewelRarityContainer = SetDetailedOptions:GetNamedChild("Keep"):GetNamedChild("NeverJunkJewels"):GetNamedChild("JewelRarity")
	SetJunker.jewelRarity = ZO_ComboBox_ObjectFromContainer(jewelRarityContainer)
	SetJunker:InitializeComboBox(SetJunker.jewelRarity, "SI_SETJUNKER_RARITY", 6, jewelRarityContainer)

	local itemsContainer = SetDetailedOptions:GetNamedChild("Keep"):GetNamedChild("NeverJunkItems"):GetNamedChild("ItemRarity")
	SetJunker.itemRarity = ZO_ComboBox_ObjectFromContainer(itemsContainer)
	SetJunker:InitializeComboBox(SetJunker.itemRarity, "SI_SETJUNKER_RARITY", 6, itemsContainer)

	local glyphsContainer = SetDetailedOptions:GetNamedChild("Keep"):GetNamedChild("NeverJunkGlyphs"):GetNamedChild("GlyphRarity")
	SetJunker.glyphRarity = ZO_ComboBox_ObjectFromContainer(glyphsContainer)
	SetJunker:InitializeComboBox(SetJunker.glyphRarity, "SI_SETJUNKER_RARITY", 6, glyphsContainer)

	self.searchDrop = ZO_ComboBox_ObjectFromContainer(self.frame:GetNamedChild("SearchDrop"))
	self:InitializeComboBox(self.searchDrop, "SI_ITEMBROWSER_SEARCHDROP", 2)

	self.searchBox = self.frame:GetNamedChild("SearchBox")
	self.searchBox:SetHandler("OnTextChanged", function() self:RefreshFilters() end)
	self.search = ZO_StringSearch:New()
	self.search:AddProcessor(ItemBrowser.sortType, function(stringSearch, data, searchTerm, cache) return(self:ProcessItemEntry(stringSearch, data, searchTerm, cache)) end)

	ItemBrowser.scene = ZO_Scene:New("ItemBrowserScene", SCENE_MANAGER)
	ItemBrowser.scene:AddFragment(ZO_SetTitleFragment:New(SI_ITEMBROWSER_TITLE))
	ItemBrowser.scene:AddFragment(ZO_FadeSceneFragment:New(ItemBrowserFrame))
	ItemBrowser.scene:AddFragment(TITLE_FRAGMENT)
	ItemBrowser.scene:AddFragment(RIGHT_BG_FRAGMENT)
	ItemBrowser.scene:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
	ItemBrowser.scene:AddFragment(CODEX_WINDOW_SOUNDS)
	ItemBrowser.scene:AddFragment(ZO_FadeSceneFragment:New(SetDetailedOptions))
	ItemBrowser.scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
	ItemBrowser.scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_CENTERED)

	self:RefreshData()
end

function ItemBrowserList:BuildMasterList( )
	self.masterList = {}
	SetJunker.config.customConfig = 1
	for i = 1, #ItemBrowserData.items do
		table.insert(self.masterList, ItemBrowser.CreateEntryFromRaw(ItemBrowserData.items[i]))
	end
end

function ItemBrowserList:FilterScrollList( )
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

	self.searchType = self.searchDrop:GetSelectedItemData().id
	local filterId = self.filterDrop:GetSelectedItemData().id
	local searchInput = self.searchBox:GetText()

	for i = 1, #self.masterList do
		local data = self.masterList[i]

		if ( (filterId == 1 or (data.zoneType[filterId - 2] and not (filterId > 2 and filterId < 7 and data.zoneType[0]))) and
		     (searchInput == "" or self:CheckForMatch(data, searchInput)) ) then
			table.insert(scrollData, ZO_ScrollList_CreateDataEntry(ITEMBROWSER_DATA, data))
		end
	end

	if (#scrollData ~= #self.masterList) then
		self.frame:GetNamedChild("Counter"):SetText(string.format("%d / %d", #scrollData, #self.masterList))
	else
		self.frame:GetNamedChild("Counter"):SetText("")
	end
end

function ItemBrowserList:SortScrollList( )
	if (self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
		local scrollData = ZO_ScrollList_GetDataList(self.list)
		table.sort(scrollData, self.sortFunction)
	end

	self:RefreshVisible()
end

function ItemBrowserList:SetupItemRow( control, data )
	control.data = data

	control:GetNamedChild("Junk").normalColor = ZO_NORMAL_TEXT
	control:GetNamedChild("Junk"):SetText(data.junk)

	control:GetNamedChild("Name").normalColor = ZO_DEFAULT_TEXT
	control:GetNamedChild("Name"):SetText(data.name)

	control:GetNamedChild("Type").nonRecolorable = true
	control:GetNamedChild("Type"):SetColor(data.color:UnpackRGBA())
	control:GetNamedChild("Type"):SetText(data.itemType)

	control:GetNamedChild("Source").normalColor = ZO_DEFAULT_TEXT
	control:GetNamedChild("Source"):SetText(data.source)

	ZO_SortFilterList.SetupRow(self, control, data)
end

function ItemBrowserList:OrderedSearch( haystack, needles )
	-- A search for "spell damage" should match "Spell and Weapon Damage" but
	-- not "damage from enemy spells", so search term order must be considered

	haystack = haystack:lower()
	needles = needles:lower()

	local i = 0

	for needle in needles:gmatch("%S+") do
		i = haystack:find(needle, i + 1, true)
		if (not i) then return(false) end
	end

	return(true)
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
			for i = 1, #bonuses do
				if (self:OrderedSearch(bonuses[i], searchQuery)) then
					found = true
					break
				end
			end

			if (found == exclude) then return(false) end
		end

		curpos = delim + 1
		if (delim ~= 0) then exclude = searchInput:sub(delim, delim) == "-" end
	until delim == 0

	return(true)
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
				if (self.search:IsMatch(searchFragment, data)) then return(true) end
			elseif (self.searchType == 2) then
				if (type(data.bonuses) == "number") then
					-- Lazy initialization of set bonus data
					data.bonuses = ItemBrowser.GetSetBonuses(data.itemLink, data.bonuses)
				end
				if (self:SearchSetBonuses(data.bonuses, searchFragment)) then return(true) end
			end
		end

		curpos = delim + 1
	until delim == 0

	return(false)
end

function ItemBrowserList:ProcessItemEntry( stringSearch, data, searchTerm, cache )
	if ( zo_plainstrfind(data.name:lower(), searchTerm) or
	     zo_plainstrfind(data.subname:lower(), searchTerm) or
	     zo_plainstrfind(data.itemType:lower(), searchTerm) or
	     zo_plainstrfind(data.source:lower(), searchTerm) ) then
		return(true)
	end

	return(false)
end

function ItemBrowserList:InitializeComboBox( control, prefix, max )
	control:SetSortsItems(false)
	control:ClearItems()

	local callback = function( comboBox, entryText, entry, selectionChanged )
		self:RefreshFilters()
	end

	for i = 1, max do
		local entry = ZO_ComboBox:CreateItemEntry(GetString(prefix, i), callback)
		entry.id = i
		control:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
	end

	control:SelectItemByIndex(1, true)
end

function ItemBrowserRow_OnMouseEnter( control )
	ItemBrowser.list:Row_OnMouseEnter(control)

	InitializeTooltip(ItemBrowserTooltip, ItemBrowserFrame, TOPRIGHT, -100, 0, TOPLEFT)
	ItemBrowserTooltip:SetLink(control.data.itemLink)
	SetJunker.currentItemLink = control.data.itemLink;
end

function ItemBrowserRow_OnMouseExit( control )
	ItemBrowser.list:Row_OnMouseExit(control)

	ClearTooltip(ItemBrowserTooltip)
end

function ItemBrowserRow_OnMouseUp( control )
	if control.data.junk == 'OFF' then
		SetJunker.deactivateDetailedOptions(control.data.setId, control.data.name);
	else
		SetJunker.activateDetailedOptions(control.data.setId, control.data.name);
	end

	ItemBrowser.list:RefreshVisible()
end
