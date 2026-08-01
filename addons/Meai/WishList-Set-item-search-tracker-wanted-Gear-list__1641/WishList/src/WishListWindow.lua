WishList = WishList or {}
local WL = WishList
local libSets = WL.LibSets
WL.searchBoxLastSelected = {}

-- ZO_SortFilterList:RefreshData()      =>  BuildMasterList()   =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshFilters()                           =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshSort()                                                      =>  SortScrollList()    =>  CommitScrollList()

local WL_getGearMarkerTexture = WL.getGearMarkerTexture
local WL_getGearTooltipText   = WL.getGearTooltipText

------------------------------------------------
--- WishList Window -> ZO_SortFilterList
------------------------------------------------
WishListWindow = ZO_SortFilterList:Subclass()

--Update the title of a scene's fragment with a new text
local function WLW_UpdateSceneFragmentTitle(sceneName, fragment, childName, newTitle)
    childName = childName or "Label"
    if sceneName == nil or fragment == nil or newTitle == nil then return false end
    local sm = SCENE_MANAGER
    if not sm then return false end
    local currentScene = sm.currentScene
    local currentSceneName = currentScene.name
    if not currentScene or not currentSceneName or not currentSceneName == sceneName or not currentScene.fragments then return end
    for _, fragmentInCurrentScene in ipairs(currentScene.fragments) do
        if fragmentInCurrentScene == fragment then
            if fragmentInCurrentScene then
                local fragmentCtrl = fragmentInCurrentScene.control
                if fragmentCtrl then
                    local fragmentCtrlChildLabel = fragmentCtrl:GetNamedChild(childName)
                    if fragmentCtrlChildLabel and fragmentCtrlChildLabel.SetText then
                        fragmentCtrlChildLabel:SetText(newTitle)
                    end
                end
            end
            return true
        end
    end
    return false
end

function WishListWindow:New( control )
	local list = ZO_SortFilterList.New(self, control)
	list.frame = control
	list:Setup()
	return(list)
end

function WishListWindow:Setup( )
--d("[WishListWindow:Setup]")
    WL.comingFromSortScrollListSetupFunction = true
	--Dialogs
	WL.WishListWindowAddItemInitialize(WishListAddItemDialog)
    WL.WishListWindowRemoveItemInitialize(WishListRemoveItemDialog)
    WL.WishListWindowReloadItemsInitialize(WishListReloadItemsDialog)
    WL.WishListWindowRemoveAllItemsInitialize(WishListRemoveAllItemsDialog)
    WL.WishListWindowChooseCharInitialize(WishListChooseCharDialog)
    WL.WishListWindowClearHistoryInitialize(WishListClearHistoryDialog)
    WL.WishListWindowChangeQualityInitialize(WishListChangeQualityDialog)
    WL.WishListWindowAddGearMarkerInitialize(WishListAddGearMarkerDialog)
    WL.WishListWindowRemoveGearMarkerInitialize(WishListRemoveGearMarkerDialog)

	--Scroll UI
	ZO_ScrollList_AddDataType(self.list, WISHLIST_DATA, "WishListRow", 30, function(control, data)
        self:SetupItemRow(control, data)
    end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self:SetAlternateRowBackgrounds(true)

	self.masterList = { }

    --Build the sortkeys depending on the settings
    --self:BuildSortKeys() --> Will be called internally in "self.sortHeaderGroup:SelectAndResetSortForKey"
	self.currentSortKey = "name"
	self.currentSortOrder = ZO_SORT_ORDER_UP
	self.sortHeaderGroup:SelectAndResetSortForKey(self.currentSortKey) -- Will call "SortScrollList" internally
	--The sort function
    self.sortFunction = function( listEntry1, listEntry2 )
        if     self.currentSortKey == nil or self.sortKeys[self.currentSortKey] == nil
            or listEntry1.data == nil or listEntry1.data[self.currentSortKey] == nil
            or listEntry2.data == nil or listEntry2.data[self.currentSortKey] == nil then
            return nil
        end
        return(ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, self.sortKeys, self.currentSortOrder))
	end
    --LibScrollableMenu - Add scrollable dropdown helper at the search dropdown
    local searchDropControl = self.frame:GetNamedChild("SearchDrop")
    self.searchDropControl = searchDropControl
    self.searchDrop = ZO_ComboBox_ObjectFromContainer(searchDropControl)
    self.searchDrop.scrollHelper = AddCustomScrollableComboBoxDropdownMenu(self.frame, searchDropControl, { visibleRowsDropdown = 15, visibleRowsSubmenu = 15, sortEntries = true })
    WL.initializeSearchDropdown(self, WISHLIST_TAB_SEARCH, "set")

    --Character/toon dropdown box
    WL.charsData = WL.charsData or {}
    if ZO_IsTableEmpty(WL.charsData) then
        WL.charsData = WL.buildCharsDropEntries()
    end

    --LibScrollableMenu - Add scrollable dropdown helper at the character dropdown
    local charsDropControl       = self.frame:GetNamedChild("CharsDrop")
    self.charsDropControl       = charsDropControl
    self.charsDrop = ZO_ComboBox_ObjectFromContainer(charsDropControl)
    self.charsDrop.scrollHelper = AddCustomScrollableComboBoxDropdownMenu(self.frame, charsDropControl, { visibleRowsDropdown = 15, visibleRowsSubmenu = 15, sortEntries = true })
    WL.initializeSearchDropdown(self, WISHLIST_TAB_WISHLIST, "char")

    --Search box and search functions
	self.searchBox = self.frame:GetNamedChild("SearchBox")
	self.searchBox:SetHandler("OnTextChanged", function() self:RefreshFilters() end)
    self.searchBox:SetHandler("OnMouseUp", function(ctrl, mouseButton, upInside)
        if mouseButton == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            self:OnSearchEditBoxContextMenu(self.searchBox)
        end
    end)
	self.search = ZO_StringSearch:New()
	self.search:AddProcessor(WL.sortType, function(stringSearch, data, searchTerm, cache)
        return(self:ProcessItemEntry(stringSearch, data, searchTerm, cache))
    end)
    --Sort headers
	self.headers = self.frame:GetNamedChild("Headers")
    self.headerDate = self.headers:GetNamedChild("DateTime")
    self.headerSetItemCollectionState = self.headers:GetNamedChild("SetItemCollectionState")
    self.headerGear = self.headers:GetNamedChild("Gear")
    self.headerName = self.headers:GetNamedChild("Name")
	self.headerArmorOrWeaponType = self.headers:GetNamedChild("ArmorOrWeaponType")
	self.headerSlot = self.headers:GetNamedChild("Slot")
	self.headerTrait = self.headers:GetNamedChild("Trait")
    self.headerQuality = self.headers:GetNamedChild("Quality")
    self.headerUsername = self.headers:GetNamedChild("UserName")
    self.headerLocality = self.headers:GetNamedChild("Locality")

	--No Sets Loaded UI
	self.labelNoSets = self.frame:GetNamedChild("labelNoSets")
	self.labelNoSets:SetText(GetString(WISHLIST_NO_SETS_LOADED))

	self.buttonLoadSets = self.frame:GetNamedChild("buttonLoadSets")
	self.buttonLoadSets:SetText(GetString(WISHLIST_LOAD_SETS))

	--Loading Sets UI
	self.labelLoadingSets = self.frame:GetNamedChild("labelLoadingSets")
	self.labelLoadingSets:SetText(zo_strformat(GetString(WISHLIST_SETS_LOADED), WL.accData.setCount))

    --Add the WishList scene
	WL.scene = ZO_Scene:New(WISHLIST_SCENE_NAME, SCENE_MANAGER)
    WL.scene:AddFragment(ZO_SetTitleFragment:New(WISHLIST_TITLE))
	WL.scene:AddFragment(ZO_FadeSceneFragment:New(WishListFrame))
	WL.scene:AddFragment(TITLE_FRAGMENT)
	WL.scene:AddFragment(RIGHT_BG_FRAGMENT)
	WL.scene:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
	WL.scene:AddFragment(CODEX_WINDOW_SOUNDS)
	WL.scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
	WL.scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)

    --Build initial masterlist via self:BuildMasterList()
--d("[WL.Setup] RefreshData > BuildMasterList ???")
    self:RefreshData()
end

local function resetSortGroupHeader(currentTab)
--d("[WL.resetSortGroupHeader]")
    if WL.window.sortHeaderGroup then
        local saveData = WL.data
        local sortHeaderKey = saveData.sortKey[currentTab] or "name"
        local sortOrder = saveData.sortOrder[currentTab]

        WL.window.currentSortKey = sortHeaderKey
        WL.window.currentSortOrder = sortOrder
        WL.window.sortHeaderGroup:SelectAndResetSortForKey(sortHeaderKey)
        --Select the sort header again to invert the sort order, if last sort order was inverted
        if sortOrder == ZO_SORT_ORDER_DOWN then
            WL.window.sortHeaderGroup:SelectHeaderByKey(sortHeaderKey)
        end
    end
end

function WL.saveSortGroupHeader(currentTab)
--d("[WL.saveSortGroupHeader]")
    if WL.window then
        local saveData = WL.data
        saveData.sortKey[currentTab]    = WL.window.currentSortKey
        saveData.sortOrder[currentTab]  = WL.window.currentSortOrder
    end
end

function WishListWindow:updateSortHeaderAnchorsAndPositions(wlTab, nameHeaderWidth, nameHeaderHeight)
--d("[WishListWindow]:updateSortHeaderAnchorsAndPositions")
    if wlTab == WISHLIST_TAB_SEARCH then
        if WL.CurrentState == WISHLIST_TAB_STATE_SETS_LOADED then
            self.headerDate:ClearAnchors()
            self.headerName:ClearAnchors()
            self.headerName:SetAnchor(TOPLEFT, self.headers, nil, 0, 0)
            self.headerName:SetDimensions(nameHeaderWidth, nameHeaderHeight)
            self.headerLocality:ClearAnchors()
            self.headerLocality:SetAnchor(TOPLEFT, self.headerName, TOPRIGHT, 0, 0)
            self.headerLocality:SetAnchor(TOPRIGHT, self.headers, TOPRIGHT, -16, 0)
        end
    elseif wlTab == WISHLIST_TAB_WISHLIST then
        self.headerDate:ClearAnchors()
        self.headerDate:SetAnchor(TOPLEFT, self.headers, nil, 0, 0)
        self.headerName:ClearAnchors()
        self.headerName:SetAnchor(TOPLEFT, self.headerDate, TOPRIGHT, 0, 0)
        self.headerName:SetDimensions(200, nameHeaderHeight)
        self.headerQuality:ClearAnchors()
        self.headerQuality:SetAnchor(LEFT, self.headerTrait, RIGHT, 0, 0)
        self.headerLocality:ClearAnchors()
        self.headerSetItemCollectionState:ClearAnchors()
        self.headerSetItemCollectionState:SetAnchor(TOPLEFT, self.headerQuality, TOPRIGHT, 0, 0)
        --self.headerSetItemCollectionState:SetAnchor(RIGHT, self.headers, RIGHT, -16, 0)
        self.headerGear:ClearAnchors()
        self.headerGear:SetAnchor(TOPLEFT, self.headerSetItemCollectionState, TOPRIGHT, 0, 0)
        self.headerGear:SetAnchor(RIGHT, self.headers, RIGHT, -4, 0)
    elseif wlTab == WISHLIST_TAB_HISTORY then
        self.headerDate:ClearAnchors()
        self.headerDate:SetAnchor(TOPLEFT, self.headers, nil, 0, 0)
        self.headerName:ClearAnchors()
        self.headerName:SetAnchor(TOPLEFT, self.headerDate, TOPRIGHT, 0, 0)
        self.headerName:SetDimensions(200, nameHeaderHeight)
        self.headerLocality:ClearAnchors()
        self.headerLocality:SetAnchor(TOPLEFT, self.headerUsername, TOPRIGHT, 0, 0)
        self.headerLocality:SetAnchor(TOPRIGHT, self.headers, TOPRIGHT, -16, 0)
    end
end


function WishListWindow:UpdateUI(state)
	WL.CurrentState = state
--d("[WishListWindow:UpdateUI] state: " ..tostring(state) .. ", currentTab: " ..tostring(WL.CurrentTab))

    ------------------------------------------------------------------------------------------------------------------------
    --SEARCH tab
	if WL.CurrentTab == WISHLIST_TAB_SEARCH then
		--Set the texture of the search button to "pressed"
        local normalSearchTexture = "/esoui/art/menubar/gamepad/gp_playermenu_icon_activityfinder.dds"
        local normalListTexture = "/esoui/art/journal/journal_tabicon_cadwell_up.dds"
        local normalHistoryTexture = "/esoui/art/guild/tabicon_history_up.dds"
        WishListFrameTabSearch:SetNormalTexture(normalSearchTexture)
        WishListFrameTabList:SetNormalTexture(normalListTexture)
        WishListFrameTabHistory:SetNormalTexture(normalHistoryTexture)

--......................................................................................................................
        --Sets are not loaded yet -> Show load button
        if WL.CurrentState == WISHLIST_TAB_STATE_NO_SETS then
            --WLW_UpdateSceneFragmentTitle(WISHLIST_SCENE_NAME, TITLE_FRAGMENT, "Label", GetString(WISHLIST_TITLE) ..  " - " .. zo_strformat(GetString(WISHLIST_SETS_LOADED), 0))
            WLW_UpdateSceneFragmentTitle(WISHLIST_SCENE_NAME, TITLE_FRAGMENT, "Label", GetString(WISHLIST_TITLE) .. " - " .. GetString(WISHLIST_BUTTON_SEARCH_TT):upper())

            --No Sets Loaded
            self.setsLoading = false
            --Disable the Wishlist tab button
            WishListFrameTabList:SetEnabled(false)

            --No Sets Loaded UI
            self.frame:GetNamedChild("labelNoSets"):SetHidden(false)
            self.frame:GetNamedChild("buttonLoadSets"):SetHidden(false)

            --Sets Loaded UI
            self.frame:GetNamedChild("SetsLastScanned"):SetHidden(true)
            self.frame:GetNamedChild("Reload"):SetHidden(true)
            self.frame:GetNamedChild("RemoveAll"):SetHidden(true)
            self.frame:GetNamedChild("CopyWishList"):SetHidden(true)
            self.frame:GetNamedChild("RemoveHistory"):SetHidden(true)
            self.frame:GetNamedChild("Search"):SetHidden(true)
            self.frame:GetNamedChild("SearchDrop"):SetHidden(true)
            self.frame:GetNamedChild("CharsDrop"):SetHidden(true)
            self.frame:GetNamedChild("List"):SetHidden(true)
            self.searchBox:SetHidden(true)

            self.frame:GetNamedChild("Headers"):SetHidden(true)
            self.headerDate:SetHidden(true)
            self.headerSetItemCollectionState:SetHidden(true)
            self.headerGear:SetHidden(true)
            self.headerArmorOrWeaponType:SetHidden(true)
            self.headerSlot:SetHidden(true)
            self.headerTrait:SetHidden(true)
            self.headerUsername:SetHidden(true)
            self.headerLocality:SetHidden(true)

            --Reset the sortGroupHeader
            resetSortGroupHeader(WL.CurrentTab)

            --Sets Loading UI
            self.labelLoadingSets:SetHidden(true)

            --......................................................................................................................
            --Sets are currently loading -> Update label with count of sets & items
        elseif WL.CurrentState == WISHLIST_TAB_STATE_SETS_LOADING then
            --WLW_UpdateSceneFragmentTitle(WISHLIST_SCENE_NAME, TITLE_FRAGMENT, "Label", GetString(WISHLIST_TITLE) .. " - " .. GetString(WISHLIST_LOADING_SETS))
            WLW_UpdateSceneFragmentTitle(WISHLIST_SCENE_NAME, TITLE_FRAGMENT, "Label", GetString(WISHLIST_TITLE) .. " - " .. GetString(WISHLIST_BUTTON_SEARCH_TT):upper())

            --Sets Loading
            self.setsLoading = true
            --Disable the Wishlist tab button
            WishListFrameTabList:SetEnabled(false)

            --No Sets Loaded UI
            self.frame:GetNamedChild("labelNoSets"):SetHidden(true)
            self.frame:GetNamedChild("buttonLoadSets"):SetHidden(true)

            --Sets Loaded UI
            self.frame:GetNamedChild("SetsLastScanned"):SetHidden(true)
            self.frame:GetNamedChild("Reload"):SetHidden(true)
            self.frame:GetNamedChild("RemoveAll"):SetHidden(true)
            self.frame:GetNamedChild("CopyWishList"):SetHidden(true)
            self.frame:GetNamedChild("RemoveHistory"):SetHidden(true)
            self.frame:GetNamedChild("Search"):SetHidden(true)
            self.frame:GetNamedChild("SearchDrop"):SetHidden(true)
            self.frame:GetNamedChild("CharsDrop"):SetHidden(true)
            self.frame:GetNamedChild("List"):SetHidden(true)
            self.searchBox:SetHidden(true)

            self.frame:GetNamedChild("Headers"):SetHidden(true)
            self.headerDate:SetHidden(true)
            self.headerSetItemCollectionState:SetHidden(true)
            self.headerGear:SetHidden(true)
            self.headerArmorOrWeaponType:SetHidden(true)
            self.headerSlot:SetHidden(true)
            self.headerTrait:SetHidden(true)
            self.headerUsername:SetHidden(true)
            self.headerLocality:SetHidden(true)

            --Sets Loading UI
            self.labelLoadingSets:SetHidden(false)
            --......................................................................................................................
            --Sets are loaded -> Show them in list
        elseif WL.CurrentState == WISHLIST_TAB_STATE_SETS_LOADED then
            WLW_UpdateSceneFragmentTitle(WISHLIST_SCENE_NAME, TITLE_FRAGMENT, "Label", GetString(WISHLIST_TITLE) .. " - " .. GetString(WISHLIST_BUTTON_SEARCH_TT):upper())

            --Sets Loaded
            self.setsLoading = false
            --Enable the Wishlist tab button again
            WishListFrameTabList:SetEnabled(true)

            --No Sets Loaded UI
            self.frame:GetNamedChild("labelNoSets"):SetHidden(true)
            self.frame:GetNamedChild("buttonLoadSets"):SetHidden(true)

            --Sets Loaded UI
            if WL.accData.setsLastScanned ~= nil and WL.accData.setsLastScanned > 0 then
                local setsLastScanned = WL.getDateTimeFormatted(WL.accData.setsLastScanned)
                local libSetsVersionInfo = ""
                if libSets and libSets.name and libSets.version then
                    libSetsVersionInfo = setsLastScanned .. "\n" .. libSets.name .. " v" .. tostring(libSets.version)
                    setsLastScanned = libSetsVersionInfo
                end
                self.frame:GetNamedChild("SetsLastScanned"):SetText(setsLastScanned)
                self.frame:GetNamedChild("SetsLastScanned"):SetHidden(false)
            end
            self.frame:GetNamedChild("Reload"):SetHidden(false)
            self.frame:GetNamedChild("RemoveAll"):SetHidden(true)
            self.frame:GetNamedChild("CopyWishList"):SetHidden(true)
            self.frame:GetNamedChild("RemoveHistory"):SetHidden(true)
            self.frame:GetNamedChild("Search"):SetHidden(false)
            self.frame:GetNamedChild("SearchDrop"):SetHidden(false)
            self.frame:GetNamedChild("CharsDrop"):SetHidden(true)

            self.frame:GetNamedChild("Headers"):SetHidden(false)
            self.headerDate:SetHidden(true)
            self.headerSetItemCollectionState:SetHidden(true)
            self.headerGear:SetHidden(true)
            self.headerArmorOrWeaponType:SetHidden(true)
            self.headerSlot:SetHidden(true)
            self.headerTrait:SetHidden(true)
            self.headerQuality:SetHidden(true)
            self.headerUsername:SetHidden(true)
            self.headerLocality:SetHidden(false)

            self.frame:GetNamedChild("List"):SetHidden(false)
            WL.initializeSearchDropdown(self, WL.CurrentTab, "set")
            self.searchBox:SetHidden(false)

            --Sets Loading UI
            self.labelLoadingSets:SetHidden(true)

            --Reset the sortGroupHeader
            resetSortGroupHeader(WL.CurrentTab)

            self:RefreshData()
        end

------------------------------------------------------------------------------------------------------------------------
    --WISHLIST tab
	elseif WL.CurrentTab == WISHLIST_TAB_WISHLIST then
        WLW_UpdateSceneFragmentTitle(WISHLIST_SCENE_NAME, TITLE_FRAGMENT, "Label", GetString(WISHLIST_TITLE) .. " - " .. GetString(WISHLIST_BUTTON_WISHLIST_TT):upper())
        --Set the texture of the search button to "pressed"
        local normalSearchTexture = "/esoui/art/miscellaneous/search_icon.dds"
        local normalListTexture = "/esoui/art/journal/journal_tabicon_cadwell_down.dds"
        local normalHistoryTexture = "/esoui/art/guild/tabicon_history_up.dds"
        WishListFrameTabSearch:SetNormalTexture(normalSearchTexture)
        WishListFrameTabList:SetNormalTexture(normalListTexture)
        WishListFrameTabHistory:SetNormalTexture(normalHistoryTexture)

		--No Sets Loaded UI
		self.frame:GetNamedChild("labelNoSets"):SetHidden(true)
		self.frame:GetNamedChild("buttonLoadSets"):SetHidden(true)

		--Sets Loaded UI
        self.frame:GetNamedChild("SetsLastScanned"):SetHidden(true)
		self.frame:GetNamedChild("Reload"):SetHidden(true)
        self.frame:GetNamedChild("RemoveAll"):SetHidden(false)
        self.frame:GetNamedChild("CopyWishList"):SetHidden(false)
        self.frame:GetNamedChild("RemoveHistory"):SetHidden(true)
        WL.updateRemoveAllButon(self.frame:GetNamedChild("RemoveAll"), self.frame:GetNamedChild("CopyWishList"))
        self.frame:GetNamedChild("Search"):SetHidden(false)
		self.frame:GetNamedChild("SearchDrop"):SetHidden(false)
        self.frame:GetNamedChild("CharsDrop"):SetHidden(false)

        self.frame:GetNamedChild("Headers"):SetHidden(false)
        self.headerDate:SetHidden(false)
        self.headerSetItemCollectionState:SetHidden(false)
        self.headerGear:SetHidden(false)
		self.headerArmorOrWeaponType:SetHidden(false)
		self.headerSlot:SetHidden(false)
		self.headerTrait:SetHidden(false)
        self.headerQuality:SetHidden(false)
        self.headerUsername:SetHidden(true)
        self.headerLocality:SetHidden(true)

        WL.initializeSearchDropdown(self, WL.CurrentTab, "set")
		self.searchBox:SetHidden(false)

		--Sets Loading UI
		self.labelLoadingSets:SetHidden(true)

    	self.searchBox:Clear()

        --Reset the sortGroupHeader
        resetSortGroupHeader(WL.CurrentTab)

		self:RefreshData()

------------------------------------------------------------------------------------------------------------------------
    --HISTORY tab
    elseif WL.CurrentTab == WISHLIST_TAB_HISTORY then
        WLW_UpdateSceneFragmentTitle(WISHLIST_SCENE_NAME, TITLE_FRAGMENT, "Label", GetString(WISHLIST_TITLE) .. " - " .. GetString(WISHLIST_HISTORY_TITLE):upper())
        --Set the texture of the search button to "pressed"
        local normalSearchTexture = "/esoui/art/miscellaneous/search_icon.dds"
        local normalListTexture = "/esoui/art/journal/journal_tabicon_cadwell_up.dds"
        local normalHistoryTexture = "/esoui/art/guild/tabicon_history_down.dds"
        WishListFrameTabSearch:SetNormalTexture(normalSearchTexture)
        WishListFrameTabList:SetNormalTexture(normalListTexture)
        WishListFrameTabHistory:SetNormalTexture(normalHistoryTexture)

        --No Sets Loaded UI
        self.frame:GetNamedChild("labelNoSets"):SetHidden(true)
        self.frame:GetNamedChild("buttonLoadSets"):SetHidden(true)

        --Sets Loaded UI
        self.frame:GetNamedChild("SetsLastScanned"):SetHidden(true)
        self.frame:GetNamedChild("Reload"):SetHidden(true)
        --WL.updateRemoveAllButon(self.frame:GetNamedChild("RemoveAll"), self.frame:GetNamedChild("CopyWishList"))
        self.frame:GetNamedChild("RemoveAll"):SetHidden(true)
        self.frame:GetNamedChild("CopyWishList"):SetHidden(true)
        self.frame:GetNamedChild("RemoveHistory"):SetHidden(false)
        self.frame:GetNamedChild("Search"):SetHidden(false)
        self.frame:GetNamedChild("SearchDrop"):SetHidden(false)
        self.frame:GetNamedChild("CharsDrop"):SetHidden(false)

        self.frame:GetNamedChild("Headers"):SetHidden(false)
        self.headerDate:SetHidden(false)
        self.headerSetItemCollectionState:SetHidden(true)
        self.headerGear:SetHidden(true)
        self.headerArmorOrWeaponType:SetHidden(false)
        self.headerSlot:SetHidden(false)
        self.headerTrait:SetHidden(false)
        self.headerQuality:SetHidden(true)
        self.headerUsername:SetHidden(false)
        self.headerLocality:SetHidden(false)

        WL.initializeSearchDropdown(self, WL.CurrentTab, "set")
        self.searchBox:SetHidden(false)

        --Sets Loading UI
        self.labelLoadingSets:SetHidden(true)

        self.searchBox:Clear()

        --Reset the sortGroupHeader
        resetSortGroupHeader(WL.CurrentTab)

        self:RefreshData()
	end
    self:updateSortHeaderAnchorsAndPositions(WL.CurrentTab, WL.maxNameColumnWidth, 32)
end -- WishListWindow:UpdateUI(state)

function WishListWindow:BuildMasterList(calledFromFilterFunction)
    calledFromFilterFunction = calledFromFilterFunction or false
--d("[WishListWindow:BuildMasterList]calledFromFilterFunction: " ..tostring(calledFromFilterFunction))
    --Sets tab row creation from savedvars sets list
------------------------------------------------------------------------------------------------------------------------
	if WL.CurrentTab == WISHLIST_TAB_SEARCH then
        self.masterList = {}
        local setsData = WL.accData.sets
		for setId, setData in pairs(setsData) do
			table.insert(self.masterList, WL.CreateEntryForSet(setId, setData))
		end
        self:updateSortHeaderAnchorsAndPositions(WL.CurrentTab, WL.maxNameColumnWidth, 32)

------------------------------------------------------------------------------------------------------------------------
	--Wishlist tab row creation from wishlist savedvars items
    elseif WL.CurrentTab == WISHLIST_TAB_WISHLIST then
        self.masterList = {}
        --Update the current selected character data
        WL.checkCurrentCharData(false)
        local selectedCharData = WL.CurrentCharData
        if selectedCharData == nil then return false end
--d(">Chardata found: " .. selectedCharData.name)
        local wishList = WL.getWishListSaveVars(selectedCharData, "WishListWindow:BuildMasterList")
        if wishList == nil or #wishList == 0 then return false end
        --Scan the items on your WishList (currently selected char) for set item collection markers
        WL.scanWishListForAlreadyKnownSetItemCollectionEntries(WL.CurrentCharData, true, wishList)
--d(">>Building master list entries, count: " .. tostring(#wishList))
        for i = 1, #wishList do
			local item = wishList[i]
            --local itemTypeName, itemArmorOrWeaponTypeName, itemSlotName, itemTraitName, itemQualityName = WL.getItemTypeNamesForSortListEntry(item.itemType, item.armorOrWeaponType, item.slot, item.trait, item.quality)
--d(">>itemType: " .. tostring(itemTypeName) .. ", armorOrWeaponType: " .. tostring(itemArmorOrWeaponTypeName) .. ", slot: " ..tostring(itemSlotName) .. ", trait: " .. tostring(itemTraitName).. ", quality: " .. tostring(itemQualityName))
			table.insert(self.masterList, WL.CreateWishListEntryForItem(item))
        end

------------------------------------------------------------------------------------------------------------------------
    --Wishlist tab row creation from history
    elseif WL.CurrentTab == WISHLIST_TAB_HISTORY then
        self.masterList = {}
        --Update the current selected character data
        WL.checkCurrentCharData(false)
        local selectedCharData = WL.CurrentCharData
        if selectedCharData == nil then return false end
        local history = WL.getHistorySaveVars(selectedCharData)
        if history == nil or #history == 0 then return false end
        for i = 1, #history do
            local item = history[i]
--local itemTypeName, itemArmorOrWeaponTypeName, itemSlotName, itemTraitName = WL.getItemTypeNamesForSortListEntry(item.itemType, item.armorOrWeaponType, item.slot, item.trait)
--d(">>history itemType: " .. tostring(itemTypeName) .. ", armorOrWeaponType: " .. tostring(itemArmorOrWeaponTypeName) .. ", slot: " ..tostring(itemSlotName) .. ", trait: " .. tostring(itemTraitName))
            table.insert(self.masterList, WL.CreateHistoryEntryForItem(item))
        end

	end
end

--Setup the data of each row which gets added to the ZO_SortFilterList
function WishListWindow:SetupItemRow( control, data )
    if WL.comingFromSortScrollListSetupFunction then return end
    --local clientLang = WL.clientLang or WL.fallbackSetLang
    --d(">>>      [WishListWindow:SetupItemRow] " ..tostring(data.names[clientLang]))
    control.data = data
    --local updateSortHeaderDimensionsAndAnchors = false
    --SetItemCollection marker
    local setItemCollectionStateColumn   = control:GetNamedChild("SetItemCollectionState")
    local markerTextureSetItemCollection = setItemCollectionStateColumn:GetNamedChild("Marker")
    --Gear marker
    local gearColumn = control:GetNamedChild("Gear")
    local markerTextureGear = gearColumn:GetNamedChild("Marker")
    local nameColumn = control:GetNamedChild("Name")
    nameColumn.normalColor = ZO_DEFAULT_TEXT
    if not data.columnWidth then data.columnWidth = 200 end
    nameColumn:SetDimensions(data.columnWidth, 30)
    nameColumn:SetText(data.name)
    local armorOrWeaponTypeColumn = control:GetNamedChild("ArmorOrWeaponType")
    local slotColumn = control:GetNamedChild("Slot")
    local traitColumn = control:GetNamedChild("Trait")
    local dateColumn = control:GetNamedChild("DateTime")
    local qualityColumn = control:GetNamedChild("Quality")
    local userNameColumn = control:GetNamedChild("UserName")
    local localityColumn = control:GetNamedChild("Locality")
    localityColumn.localityName = nil
    ------------------------------------------------------------------------------------------------------------------------
    if WL.CurrentTab == WISHLIST_TAB_SEARCH then
        --d(">WISHLIST_TAB_SEARCH")
        setItemCollectionStateColumn:SetHidden(true)
        setItemCollectionStateColumn:ClearAnchors()
        gearColumn:SetHidden(true)
        gearColumn:ClearAnchors()
        markerTextureSetItemCollection:SetHidden(true)
        markerTextureSetItemCollection:SetTexture("")
        markerTextureSetItemCollection:SetMouseEnabled(false)
        markerTextureGear:SetHidden(true)
        markerTextureGear:SetTexture("")
        markerTextureGear:SetMouseEnabled(false)
        dateColumn:SetHidden(true)
        dateColumn:ClearAnchors()
        nameColumn:ClearAnchors()
        nameColumn:SetAnchor(LEFT, control, nil, 0, 0)
        nameColumn:SetHidden(false)
        userNameColumn:SetHidden(true)
        armorOrWeaponTypeColumn:SetHidden(true)
        slotColumn:SetHidden(true)
        traitColumn:SetHidden(true)
        qualityColumn:SetHidden(true)
        localityColumn:SetHidden(false)
        dateColumn:SetText("")
        armorOrWeaponTypeColumn:SetText("")
        slotColumn:SetText("")
        traitColumn:SetText("")
        qualityColumn:SetText("")
        localityColumn:ClearAnchors()
        localityColumn:SetAnchor(LEFT, nameColumn, RIGHT, 0, 0)
        localityColumn:SetText(data.locality)
        localityColumn.localityName = data.locality
        localityColumn:SetAnchor(RIGHT, control, RIGHT, -16, 0)
        ------------------------------------------------------------------------------------------------------------------------
    elseif WL.CurrentTab == WISHLIST_TAB_WISHLIST then
        --d(">WISHLIST_TAB_WISHLIST")
        local dateTimeStamp = data.timestamp
        local dateTimeStr = WL.getDateTimeFormatted(dateTimeStamp)
        dateColumn:ClearAnchors()
        dateColumn:SetAnchor(LEFT, control, nil, 0, 0)
        dateColumn:SetText(dateTimeStr)
        dateColumn:SetHidden(false)
        nameColumn:SetHidden(false)
        nameColumn:ClearAnchors()
        nameColumn:SetAnchor(LEFT, dateColumn, RIGHT, 0, 0)
        userNameColumn:SetHidden(true)
        qualityColumn:SetHidden(false)
        localityColumn:SetHidden(true)
        localityColumn:ClearAnchors()
        armorOrWeaponTypeColumn:SetHidden(false)
        slotColumn:SetHidden(false)
        traitColumn:SetHidden(false)
        armorOrWeaponTypeColumn.normalColor = ZO_DEFAULT_TEXT
        local armorOrWeaponTypeColumnText = ""
        if data.itemType == ITEMTYPE_WEAPON then
            --Weapon
            armorOrWeaponTypeColumnText = WL.WeaponTypes[data.armorOrWeaponType]
        elseif data.itemType == ITEMTYPE_ARMOR then
            --Armor
            armorOrWeaponTypeColumnText = WL.ArmorTypes[data.armorOrWeaponType]
        end
        armorOrWeaponTypeColumn:SetText(armorOrWeaponTypeColumnText)
        slotColumn.normalColor = ZO_DEFAULT_TEXT
        slotColumn:SetText(WL.SlotTypes[data.slot])
        traitColumn.normalColor = ZO_DEFAULT_TEXT
        --Add the icon to the trait column
        local traitId = data.trait
        local traitText = ""
        if traitId ~= nil then
            traitText = WL.TraitTypes[traitId]
            traitText = WL.buildItemTraitIconText(traitText, traitId)
        end
        traitColumn:SetText(traitText)
        local qualityText = ""
        if data.quality then
            qualityText = WL.quality[data.quality]
        end
        qualityColumn:ClearAnchors()
        qualityColumn:SetAnchor(LEFT, traitColumn, RIGHT, 0, 0)
        qualityColumn:SetText(qualityText)
        setItemCollectionStateColumn:SetHidden(false)
        setItemCollectionStateColumn:ClearAnchors()
        setItemCollectionStateColumn:SetAnchor(LEFT, qualityColumn, RIGHT, 0, 0)
        if data.knownInSetItemCollectionBook and data.knownInSetItemCollectionBook == 1 then
            markerTextureSetItemCollection:SetTexture(WISHLIST_TEXTURE_SETITEMCOLLECTION)
            markerTextureSetItemCollection:SetDimensions(26, 26)
            markerTextureSetItemCollection:SetColor(1, 1, 1, 1)
            markerTextureSetItemCollection:SetMouseEnabled(true)
            markerTextureSetItemCollection:SetHidden(false)
        else
            markerTextureSetItemCollection:SetTexture("")
            markerTextureSetItemCollection:SetHidden(true)
        end
        --setItemCollectionStateColumn:SetAnchor(RIGHT, control, RIGHT, -16, 0)
        gearColumn:SetHidden(false)
        gearColumn:ClearAnchors()
        gearColumn:SetAnchor(LEFT, setItemCollectionStateColumn, RIGHT, 0, 0)
        if data.gearId ~= nil and data.gearId > 0 then
            local gearMarkerTexture, gearMarkerTextureColor = WL_getGearMarkerTexture(data, false, nil, nil)
            if gearMarkerTexture ~= nil and gearMarkerTextureColor ~= nil then
                markerTextureGear:SetTexture(gearMarkerTexture)
                markerTextureGear:SetDimensions(26, 26)
                markerTextureGear:SetColor(gearMarkerTextureColor.r,gearMarkerTextureColor.g,gearMarkerTextureColor.b,gearMarkerTextureColor.a)
                markerTextureGear:SetMouseEnabled(true)
                markerTextureGear:SetHidden(false)
                markerTextureGear.data = {
                    tooltipText = WL_getGearTooltipText(data.gearId)
                }
                markerTextureGear:SetHandler("OnMouseEnter", function(ctrl)
                    if ctrl.data.tooltipText ~= nil and ctrl.data.tooltipText ~= "" then
                        ZO_Tooltips_ShowTextTooltip(ctrl, RIGHT, ctrl.data.tooltipText)
                    end
                end)
                markerTextureGear:SetHandler("OnMouseExit",  function() ZO_Tooltips_HideTextTooltip()  end)
            else
                markerTextureGear:SetTexture("")
                markerTextureGear:SetHidden(true)
                markerTextureGear:SetMouseEnabled(false)
                markerTextureGear:SetHandler("OnMouseEnter", nil)
                markerTextureGear:SetHandler("OnMouseExit",  nil)
                markerTextureGear.data = nil
            end
        else
            markerTextureGear:SetTexture("")
            markerTextureGear:SetHidden(true)
            markerTextureGear:SetMouseEnabled(false)
            markerTextureGear:SetHandler("OnMouseEnter", nil)
            markerTextureGear:SetHandler("OnMouseExit",  nil)
            markerTextureGear.data = nil
        end
        gearColumn:SetAnchor(RIGHT, control, RIGHT, -4, 0)
        ------------------------------------------------------------------------------------------------------------------------
    elseif WL.CurrentTab == WISHLIST_TAB_HISTORY then
        --d(">WISHLIST_TAB_HISTORY")
        setItemCollectionStateColumn:SetHidden(true)
        gearColumn:SetHidden(true)
        markerTextureSetItemCollection:SetHidden(true)
        markerTextureSetItemCollection:SetMouseEnabled(false)
        markerTextureGear:SetHidden(true)
        markerTextureGear:SetMouseEnabled(false)
        local dateTimeStamp = data.timestamp
        local dateTimeStr = WL.getDateTimeFormatted(dateTimeStamp)
        dateColumn:ClearAnchors()
        dateColumn:SetAnchor(LEFT, control, nil, 0, 0)
        dateColumn:SetText(dateTimeStr)
        dateColumn:SetHidden(false)
        nameColumn:SetHidden(false)
        nameColumn:ClearAnchors()
        nameColumn:SetAnchor(LEFT, dateColumn, RIGHT, 0, 0)
        qualityColumn:SetHidden(true)
        userNameColumn:SetHidden(false)
        local userNameText = ""
        if data.username ~= nil and data.username ~= "" then
            userNameText = data.username
        end
        if data.displayName ~= nil and data.displayName ~= "" then
            if userNameText ~= "" then
                userNameText = userNameText .. " [" .. data.displayName .. "]"
            else
                userNameText = data.displayName
            end
        end
        if userNameText == "" then
            userNameText = "???"
        end
        userNameColumn:SetText(userNameText)
        localityColumn:SetHidden(false)
        localityColumn:ClearAnchors()
        localityColumn:SetAnchor(LEFT, userNameColumn, RIGHT, 0, 0)
        localityColumn:SetText(data.locality)
        localityColumn.localityName = data.locality
        armorOrWeaponTypeColumn:SetHidden(false)
        slotColumn:SetHidden(false)
        traitColumn:SetHidden(false)
        armorOrWeaponTypeColumn.normalColor = ZO_DEFAULT_TEXT
        local armorOrWeaponTypeColumnText = ""
        if data.itemType == ITEMTYPE_WEAPON then
            --Weapon
            armorOrWeaponTypeColumnText = WL.WeaponTypes[data.armorOrWeaponType]
        elseif data.itemType == ITEMTYPE_ARMOR then
            --Armor
            armorOrWeaponTypeColumnText = WL.ArmorTypes[data.armorOrWeaponType]
        end
        armorOrWeaponTypeColumn:SetText(armorOrWeaponTypeColumnText)
        slotColumn.normalColor = ZO_DEFAULT_TEXT
        slotColumn:SetText(WL.SlotTypes[data.slot])
        traitColumn.normalColor = ZO_DEFAULT_TEXT
        --Add the icon to the trait column
        local traitId = data.trait
        local traitText = ""
        if traitId ~= nil then
            traitText = WL.TraitTypes[traitId]
            traitText = WL.buildItemTraitIconText(traitText, traitId)
        end
        traitColumn:SetText(traitText)
        qualityColumn:SetText("")
    end
    --Set the row to the list now
    ZO_SortFilterList.SetupRow(self, control, data)
end

function WL.createWindow(doShow)
    doShow = doShow or false
    if (not WL.window) then
        WL.window = WishListWindow:New(WishListFrame)
    end
    if doShow then
        --Reset variable
        WL.comingFromSortScrollListSetupFunction = false
        if WL.accData.setCount == 0 then
            WL.window:UpdateUI(WISHLIST_TAB_STATE_NO_SETS)
        else
            WL.window:UpdateUI(WISHLIST_TAB_STATE_SETS_LOADED)
        end
    end
end

function WishList:IsHidden()
    if WishListFrame == nil then return true end
    return WishListFrame:IsControlHidden()
end

function WishList:Show()
    WL.createWindow(true)

    if WishList:IsHidden() then
        SCENE_MANAGER:Show("WishListScene")
        WL.windowShown = true
    else
        SCENE_MANAGER:Hide("WishListScene")
        WL.windowShown = false
    end
end

function WL.updateRemoveAllButon(removeAllBtn, copyWishListButton)
    if not WL.windowShown then return false end
    --History
    if WL.CurrentTab == WISHLIST_TAB_HISTORY then
        if removeAllBtn == nil then
            removeAllBtn = WL.window.frame:GetNamedChild("RemoveHistory")
        end
        if removeAllBtn ~= nil then
            removeAllBtn:SetHidden(false)
            local isHistoryEmpty, _ = WL.IsHistoryEmpty(WL.CurrentCharData)
            if not isHistoryEmpty then
                removeAllBtn:SetEnabled(true)
            else
                removeAllBtn:SetEnabled(false)
            end
        end

    --WishList
    elseif WL.CurrentTab == WISHLIST_TAB_WISHLIST then
        if removeAllBtn == nil then
            removeAllBtn = WL.window.frame:GetNamedChild("RemoveAll")
        end
        if copyWishListButton == nil then
            copyWishListButton = WL.window.frame:GetNamedChild("CopyWishList")
        end
        if removeAllBtn ~= nil and copyWishListButton ~= nil then
            removeAllBtn:SetHidden(false)
            copyWishListButton:SetHidden(false)
            local isEmpty, _ = WL.IsEmpty(WL.CurrentCharData)
            if not isEmpty then
                removeAllBtn:SetEnabled(true)
                copyWishListButton:SetEnabled(true)
            else
                removeAllBtn:SetEnabled(false)
                copyWishListButton:SetEnabled(false)
            end
        end
    end
end

--Change the tabs at the WishList menu
function WL.SetTab(index)
    --Save the current sort order and key
    WL.saveSortGroupHeader(WL.CurrentTab)
    --Change to the new tab
    WL.CurrentTab = index
    --Clear the master list of the currently shown ZO_SortFilterList
    ZO_ScrollList_Clear(WL.window.list)
    WL.window.masterList = {}
    --Reset variable
    WL.comingFromSortScrollListSetupFunction = false
    --Update the UI (hide/show items)
    WL.window:UpdateUI(WL.CurrentState)
end


------------------------------------------------
--- WishList Window -> Filter & Sorting
------------------------------------------------
function WL.getItemTypeNamesForSortListEntry(itemType, armorOrWeaponType, slot, trait, quality)
    local itemTypes = WL.ItemTypes
    local traitTypes = WL.TraitTypes
    local slotNames = WL.SlotTypes
    local qualityNames = WL.quality
    local armorOrWeaponTypeName = ""
    if itemType == ITEMTYPE_WEAPON then
        armorOrWeaponTypeName = WL.WeaponTypes[armorOrWeaponType] or "HALLO"
    elseif itemType == ITEMTYPE_ARMOR then
        armorOrWeaponTypeName = WL.ArmorTypes[armorOrWeaponType] or "HALLO"
    end
    local itemTypeName = itemTypes[itemType] or ""
    local slotTypeName = slotNames[slot] or ""
    local traitTypeName = traitTypes[trait] or ""
    local qualityName = qualityNames[quality] or ""
    return itemTypeName, armorOrWeaponTypeName, slotTypeName, traitTypeName, qualityName
end

function WishListWindow:FilterScrollList()
--d("[WishListWindow:FilterScrollList]")
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

    --Get the search method chosen at the search dropdown
    local selectedItem = self.searchDrop:GetSelectedItemData()
    self.searchType = selectedItem ~= nil and selectedItem.id
    --Check the search text
    local searchInput = self.searchBox:GetText()

    local function checkIfMasterListRebuildNeeded(selfVar)
        --If not coming from setup function
        if not WL.comingFromSortScrollListSetupFunction then
--d("--->>>checkIfMasterListRebuildNeeded: true")
            selfVar:BuildMasterList(true)
        end
    end

------------------------------------------------------------------------------------------------------------------------
    --Sets tab - Changed set name search field or method
    if WL.CurrentTab == WISHLIST_TAB_SEARCH then
        --Rebuild the masterlist so the total list and counts are correct!
        checkIfMasterListRebuildNeeded(self)
        for i = 1, #self.masterList do
            --Get the data of each set item
            local data = self.masterList[i]
            --Search for text/set bonuses
            if searchInput == "" or self:CheckForMatch(data, searchInput) then
                table.insert(scrollData, ZO_ScrollList_CreateDataEntry(WISHLIST_DATA, data))
            end
        end

------------------------------------------------------------------------------------------------------------------------
    --WishList tab - Changed character
    elseif WL.CurrentTab == WISHLIST_TAB_WISHLIST then
        --Get the character ID from the chars/toon dropdown
        --local selectedCharData = self.charsDrop:GetSelectedItemData()
		WL.checkCurrentCharData(false)
        --Rebuild the masterlist so the total list and counts are correct!
        checkIfMasterListRebuildNeeded(self)
		--self.charId = selectedCharData.id
		self.charId = WL.CurrentCharData.id
        --WL.CurrentCharData.id = selectedCharData.id
        --local charNameWithoutTexture = string.gsub(selectedCharData.name, "|t%-?%d+%%?:%-?%d+%%?:.-|t%s*", "")
        --WL.CurrentCharData.name = selectedCharData.name
        --Get the WishList's SavedVariables data for the selected char ID now
        if self.charId ~= nil then
            --local accName = GetDisplayName()
            --local wishListOfCharId = WishList_Data["Default"][accName][self.charId]["Data"]["wishList"]
            local wishListOfCharId = WL.getWishListSaveVars(WL.CurrentCharData, "WishListWindow:FilterScrollList")
            if wishListOfCharId == nil or #wishListOfCharId == 0 then
                --Update the counter
                self:UpdateCounter(scrollData)
                WL.updateRemoveAllButon()
                return false
            end
--d(">MasterList count: " ..tostring(#self.masterList))
            --Add the saved wishlist items of the chosen character
            for i = 1, #self.masterList do
                --LibSets and other MasterList inserted data -> see function checkIfMasterListRebuildNeeded
                local mlData = self.masterList[i]
                --Get the data of each set item on the wishlist of the char
            --[[
                --All the data here was already created inside the MasterList via function checkIfMasterListRebuildNeeded
                --> WL.CreateWishListEntryForItem, so why was it "copied" here?
                local wlDataOfCharId = wishListOfCharId[i]
                local data = {}
                local itemId = wlDataOfCharId["id"]
                local itemLink = WL.buildItemLink(itemId, wlDataOfCharId["quality"])
                local _, _, numBonuses, _, _, _ = GetItemLinkSetInfo(itemLink, false)
                --Get the names for the sort & filter functions
                local itemTypeName, armorOrWeaponTypeName, slotTypeName, traitTypeName, qualityName = WL.getItemTypeNamesForSortListEntry(wlDataOfCharId["itemType"], wlDataOfCharId["armorOrWeaponType"], wlDataOfCharId["slot"], wlDataOfCharId["trait"], wlDataOfCharId["quality"])
                data["type"]                    = 1 -- for the search method to work -> Find the processor in zo_stringsearch:Process()
                data["id"]                      = itemId
                data["setId"]                   = wlDataOfCharId["setId"]
                data["itemType"]                = wlDataOfCharId["itemType"]
                data["itemTypeName"]            = itemTypeName
                data["trait"]                   = wlDataOfCharId["trait"]
                data["traitName"]               = traitTypeName
                data["armorOrWeaponType"]       = wlDataOfCharId["armorOrWeaponType"]
                data["armorOrWeaponTypeName"]   = armorOrWeaponTypeName
                data["slot"]                    = wlDataOfCharId["slot"]
                data["slotName"]                = slotTypeName
                data["quality"]                 = wlDataOfCharId["quality"]
                data["qualityName"]             = qualityName
                data["name"]                    = wlDataOfCharId["setName"]
                data["itemLink"]                = itemLink
                data["bonuses"]                 = numBonuses -- the number of the bonuses of the set
                data["timestamp"]               = wlDataOfCharId["timestamp"]
                data["isKnownInSetItemCollectionBook"] = wlDataOfCharId["isKnownInSetItemCollectionBook"]
                data["gearId"]     = wlDataOfCharId["gearId"]

                --Masterlist data
                if mlData then
                    data["setType"]         = mlData.setType
                    data["traitsNeeded"]    = mlData.traitsNeeded
                    data["dlcId"]           = mlData.dlcId
                    data["zoneIds"]         = mlData.zoneIds
                    data["wayshrines"]      = mlData.wayshrines
                    data["zoneIdNames"]     = mlData.zoneIdNames
                    data["wayshrineNames"]  = mlData.wayshrineNames
                    data["dlcName"]         = mlData.dlcName
                    data["setTypeName"]     = mlData.setTypeName
                    data["armorTypes"]      = mlData.armorTypes
                    data["dropMechanics"]   = mlData.dropMechanics
               end
            ]]
                --Filter out by name or set bonus
                if searchInput == "" or self:CheckForMatch(mlData, searchInput) then
                    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(WISHLIST_DATA, mlData))
                end
            end
        end
        WL.updateRemoveAllButon()

------------------------------------------------------------------------------------------------------------------------
    --History tab - Changed character
    elseif WL.CurrentTab == WISHLIST_TAB_HISTORY then
        --Get the character ID from the chars/toon dropdown
        --local selectedCharData = self.charsDrop:GetSelectedItemData()
        WL.checkCurrentCharData(false)
        --Rebuild the masterlist so the total list and counts are correct!
        checkIfMasterListRebuildNeeded(self)
        --self.charId = selectedCharData.id
        self.charId = WL.CurrentCharData.id
        --WL.CurrentCharData.id = selectedCharData.id
        --local charNameWithoutTexture = string.gsub(selectedCharData.name, "|t%-?%d+%%?:%-?%d+%%?:.-|t%s*", "")
        --WL.CurrentCharData.name = selectedCharData.name
        --Get the WishList's SavedVariables data for the selected char ID now
        if self.charId ~= nil then
            --local accName = GetDisplayName()
            --local wishListOfCharId = WishList_Data["Default"][accName][self.charId]["Data"]["wishList"]
            local historyOfCharId = WL.getHistorySaveVars(WL.CurrentCharData)
            if historyOfCharId == nil or #historyOfCharId == 0 then
                --Update the counter
                self:UpdateCounter(scrollData)
                WL.updateRemoveAllButon()
                return false
            end
--d(">MasterList count: " ..tostring(#self.masterList))
            --Add the saved history items of the chosen character
            for i = 1, #self.masterList do
                local histData = self.masterList[i]
            --[[
                --All the data here was already created inside the MasterList via function checkIfMasterListRebuildNeeded
                --> WL.CreateHistoryEntryForItem, so why was it "copied" here?
                --Get the data of each set item on the wishlist of the char
                local histDataOfCharId = historyOfCharId[i]
                local data = {}
                local itemId = histDataOfCharId["id"]
                local itemLink = WL.buildItemLink(itemId, histDataOfCharId["quality"])
                local _, _, numBonuses, _, _, _ = GetItemLinkSetInfo(itemLink, false)
                --Get the names for the sort & filter functions
                local itemTypeName, armorOrWeaponTypeName, slotTypeName, traitTypeName, qualityName = WL.getItemTypeNamesForSortListEntry(histDataOfCharId["itemType"], histDataOfCharId["armorOrWeaponType"], histDataOfCharId["slot"], histDataOfCharId["trait"], histDataOfCharId["quality"])
                data["type"]                    = 1 -- for the search method to work -> Find the processor in zo_stringsearch:Process()
                data["id"]                      = itemId
                data["setId"]                   = histDataOfCharId["setId"]
                data["itemType"]                = histDataOfCharId["itemType"]
                data["itemTypeName"]            = itemTypeName
                data["trait"]                   = histDataOfCharId["trait"]
                data["traitName"]               = traitTypeName
                data["armorOrWeaponType"]       = histDataOfCharId["armorOrWeaponType"]
                data["armorOrWeaponTypeName"]   = armorOrWeaponTypeName
                data["slot"]                    = histDataOfCharId["slot"]
                data["slotName"]                = slotTypeName
                data["quality"]                 = histDataOfCharId["quality"]
                data["qualityName"]             = qualityName
                data["name"]                    = histDataOfCharId["setName"]
                data["itemLink"]                = itemLink
                data["bonuses"]                 = numBonuses -- the number of the bonuses of the set
                data["timestamp"]               = histDataOfCharId["timestamp"]
                data["username"]                = histDataOfCharId["username"]
                if histDataOfCharId["displayName"] ~= nil then
                    data["displayName"]             = histDataOfCharId["displayName"]
                end
                data["locality"]                = histDataOfCharId["locality"]
                --LibSets data
                local mlData = self.masterList[i]
                if mlData then
                    data["setType"]         = mlData.setType
                    data["traitsNeeded"]    = mlData.traitsNeeded
                    data["dlcId"]           = mlData.dlcId
                    data["zoneIds"]         = mlData.zoneIds
                    data["wayshrines"]      = mlData.wayshrines
                    data["zoneIdNames"]      = mlData.zoneIdNames
                    data["wayshrineNames"]      = mlData.wayshrineNames
                    data["dlcName"]         = mlData.dlcName
                    data["setTypeName"]     = mlData.setTypeName
                    data["armorTypes"]      = mlData.armorTypes
                    data["dropMechanics"]   = mlData.dropMechanics
                end
            ]]
                --Filter out by name or set bonus
                if searchInput == "" or self:CheckForMatch(histData, searchInput) then
                    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(WISHLIST_DATA, histData))
                end
            end
        end
        WL.updateRemoveAllButon()
    end
    --Update the counter
    self:UpdateCounter(scrollData)
end

function WishListWindow:UpdateCounter(scrollData)
    --Update the counter (found by search/total) at the bottom right of the scroll list
    local listCountAndTotal = ""
    if self.masterList == nil or (self.masterList ~= nil and #self.masterList == 0) then
        listCountAndTotal = "0 / 0"
    else
        listCountAndTotal = string.format("%d / %d", #scrollData, #self.masterList)
    end
    self.frame:GetNamedChild("Counter"):SetText(listCountAndTotal)
end

--Build the sortheader key table, including a tiebraker chosen from the settings
function WL.getSortKeysWithTiebrakerFromSettings()
--d("[WishList]getSortKeysWithTiebrakerFromSettings")
    local sortKeys = {}
    local settings = WL.data
    local tieBreaker = settings.useSortTiebraker
    local noTiebraker = true
    local tiebrakerColumn
    local baseDataForSortKeys = {
        ["timestamp"]               = { isId64          = true, }, --isNumeric = true
        ["knownInSetItemCollectionBook"] = { caseInsensitive = true, isNumeric = true },
        ["gearId"]                  = { caseInsensitive = true, isNumeric = true },
        ["name"]                    = { caseInsensitive = true, },
        ["armorOrWeaponTypeName"]   = { caseInsensitive = true, },
        ["slotName"]                = { caseInsensitive = true, },
        ["traitName"]               = { caseInsensitive = true, },
        ["quality"]                 = { caseInsensitive = true, },
        ["username"]                = { caseInsensitive = true, },
        ["locality"]                = { caseInsensitive = true, },
    }
    if tieBreaker and tieBreaker ~= -1 then
        if  tieBreaker == 1 then --Name
            noTiebraker = false
            tiebrakerColumn = "name"
        elseif  tieBreaker == 2 then --ArmorOrWeaponType
            noTiebraker = false
            tiebrakerColumn = "armorOrWeaponTypeName"
        elseif  tieBreaker == 3 then --SlotName
            noTiebraker = false
            tiebrakerColumn = "slotName"
        elseif  tieBreaker == 4 then --Trait
            noTiebraker = false
            tiebrakerColumn = "traitName"
        elseif  tieBreaker == 5 then --Quality
            noTiebraker = false
            tiebrakerColumn = "quality"
        elseif  tieBreaker == 6 then --Username
            noTiebraker = false
            tiebrakerColumn = "username"
        elseif  tieBreaker == 7 then --Locality
            noTiebraker = false
            tiebrakerColumn = "locality"
        elseif  tieBreaker == 8 then --Timestamp
            noTiebraker = false
            tiebrakerColumn = "timestamp"
        end
        if noTiebraker == false and (tiebrakerColumn ~= nil and tiebrakerColumn ~= "") then
            --[[
            sortKeys = {
                ["timestamp"]               = { isId64          = true, tiebreaker = tostring(tiebrakerColumn) }, --isNumeric = true
                ["name"]                    = { caseInsensitive = true, tiebreaker = tostring(tiebrakerColumn) },
                ["armorOrWeaponTypeName"]   = { caseInsensitive = true, tiebreaker = tostring(tiebrakerColumn) },
                ["slotName"]                = { caseInsensitive = true, tiebreaker = tostring(tiebrakerColumn) },
                ["traitName"]               = { caseInsensitive = true, tiebreaker = tostring(tiebrakerColumn) },
                ["quality"]                 = { caseInsensitive = true, tiebreaker = tostring(tiebrakerColumn) },
                ["username"]                = { caseInsensitive = true, tiebreaker = tostring(tiebrakerColumn) },
                ["locality"]                = { caseInsensitive = true, tiebreaker = tostring(tiebrakerColumn) },
            }
            ]]
            for sortKeysKey, sortKeysBaseData in pairs(baseDataForSortKeys) do
                if sortKeysKey ~= nil and sortKeysBaseData ~= nil then
                    sortKeys[sortKeysKey] = {}
                    sortKeys[sortKeysKey] = sortKeysBaseData
                    if tiebrakerColumn ~= sortKeysKey then
                        sortKeys[sortKeysKey].tiebreaker = tostring(tiebrakerColumn)
                    end
                end
            end
        end
    end
    if noTiebraker == true then
        sortKeys = {
            ["timestamp"]               = { isId64          = true }, -- isNumeric = true
            ["knownInSetItemCollectionBook"] = { caseInsensitive = true, isNumeric = true },
            ["gearId"]                  = { caseInsensitive = true, isNumeric = true },
            ["name"]                    = { caseInsensitive = true },
            ["armorOrWeaponTypeName"]   = { caseInsensitive = true },
            ["slotName"]                = { caseInsensitive = true },
            ["traitName"]               = { caseInsensitive = true },
            ["quality"]                 = { caseInsensitive = true },
            ["username"]                = { caseInsensitive = true },
            ["locality"]                = { caseInsensitive = true },
        }
    end
    return sortKeys
end

function WishListWindow:BuildSortKeys()
--d("[WL.BuildSortKeys]")
    if WL.sortKeys ~= nil and type(WL.sortKeys) == "table" then
        self.sortKeys = WL.sortKeys
    else
        --Get the tiebraker for the 2nd sort after the selected column
        self.sortKeys = {
            ["timestamp"]               = { isId64          = true, tiebreaker = "name"  }, --isNumeric = true
            ["knownInSetItemCollectionBook"] = { caseInsensitive = true, isNumeric = true, tiebreaker = "name" },
            ["gearId"]                  = { caseInsensitive = true, isNumeric = true, tiebreaker = "name" },
            ["name"]                    = { caseInsensitive = true },
            ["armorOrWeaponTypeName"]   = { caseInsensitive = true, tiebreaker = "name" },
            ["slotName"]                = { caseInsensitive = true, tiebreaker = "name" },
            ["traitName"]               = { caseInsensitive = true, tiebreaker = "name" },
            ["quality"]                 = { caseInsensitive = true, tiebreaker = "name" },
            ["username"]                = { caseInsensitive = true, tiebreaker = "name" },
            ["locality"]                = { caseInsensitive = true, tiebreaker = "name" },
        }
    end
end

function WishListWindow:SortScrollList( )
    --Build the sortkeys depending on the settings
    self:BuildSortKeys()
    --Get the current sort header's key and direction
    self.currentSortKey = self.sortHeaderGroup:GetCurrentSortKey()
    self.currentSortOrder = self.sortHeaderGroup:GetSortDirection()
--d("[WishListWindow:SortScrollList] sortKey: " .. tostring(self.currentSortKey) .. ", sortOrder: " ..tostring(self.currentSortOrder))
	if (self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
        --If not coming from setup function
        if WL.comingFromSortScrollListSetupFunction then return end
        --Update the scroll list and re-sort it -> Calls "SetupItemRow" internally!
		local scrollData = ZO_ScrollList_GetDataList(self.list)
        if scrollData and #scrollData > 0 then
            table.sort(scrollData, self.sortFunction)
            self:RefreshVisible()
        end
	end
end

------------------------------------------------
--- Search/Filter Functions
------------------------------------------------
function WishListWindow:OrderedSearch( haystack, needles )
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

function WishListWindow:SearchSetBonuses( bonuses, searchInput )
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

function WishListWindow:SearchByCriteria(data, searchInput, searchType)
--d("[WLW:SearchByCriteria]searchType: " .. tostring(searchType) .. ", searchInput: " .. tostring(searchInput))
    if data == nil or searchInput == nil or searchInput == "" or searchType == nil then return nil end
    local searchValueType = type(searchInput)
    local searchInputLower
    local searchValueIsString = false
    local searchValueIsNumber = false
    local searchInputNumber = tonumber(searchInput)
    if searchInputNumber ~= nil then
        searchValueType = type(searchInputNumber)
        if searchValueType == "number" then
            searchValueIsNumber = true
        end
    else
        if searchValueType == "string" then
            searchValueIsString = true
            searchInputLower = searchInput:lower()
        end
    end

--[[
    data["type"]                    = 1 -- for the search method to work -> Find the processor in zo_stringsearch:Process()
    data["id"]                      = itemId
    data["setId"]                   = histDataOfCharId["setId"]
    data["itemType"]                = histDataOfCharId["itemType"]
    data["itemTypeName"]            = itemTypeName
    data["trait"]                   = histDataOfCharId["trait"]
    data["traitName"]               = traitTypeName
    data["armorOrWeaponType"]       = histDataOfCharId["armorOrWeaponType"]
    data["armorOrWeaponTypeName"]   = armorOrWeaponTypeName
    data["slot"]                    = histDataOfCharId["slot"]
    data["slotName"]                = slotTypeName
    data["quality"]                 = histDataOfCharId["quality"]
    data["qualityName"]             = qualityName
    data["name"]                    = histDataOfCharId["setName"]
    data["itemLink"]                = itemLink
    data["bonuses"]                 = numBonuses -- the number of the bonuses of the set
    data["timestamp"]               = histDataOfCharId["timestamp"]
    data["username"]                = histDataOfCharId["username"]
    data["displayName"]             = histDataOfCharId["displayName"]
    data["locality"]                = histDataOfCharId["locality"]
    data["knownInSetItemCollectionBook"] = histDataOfCharId["knownInSetItemCollectionBook"]
    data["gearId "]    = histDataOfCharId["gearId"]
    --LibSets data
    data["setType"]         = mlData.setType
    data["traitsNeeded"]    = mlData.traitsNeeded
    data["dlcId"]           = mlData.dlcId
    data["zoneIds"]         = mlData.zoneIds
    data["wayshrines"]      = mlData.wayshrines
    data["zoneIdNames"]     = mlData.zoneIdNames
    data["wayshrineNames"]  = mlData.wayshrineNames
    data["dlcName"]         = mlData.dlcName
    data["setTypeName"]     = mlData.setTypeName
    data["armorTypes"]      = mlData.armorTypes
    data["dropMechanics"]   = mlData.dropMechanics
]]
    --Search by item type
    if searchType == WISHLIST_SEARCH_TYPE_BY_TYPE then
        if searchValueIsString then
            local itemTypeName = data.itemTypeName
            if itemTypeName and itemTypeName ~= "" then
                if zo_plainstrfind(itemTypeName:lower(), searchInputLower) then
                    return true
                end
            end
        elseif searchValueIsNumber then
            local itemType = data.itemType
            if itemType ~= nil and itemType == searchInputNumber then return true end
        end

    --Search by armor type
    elseif searchType == WISHLIST_SEARCH_TYPE_BY_ARMORTYPE then
        --Are we searching at the WishList and/or History, then we are able to use the itemlink
        --Else we need to use the armorTypes table (e.g. at the set search, as there is only 1 example itemlink in the
        --dataEntry.data (could be a weapon or ring...)
        if WL.CurrentTab == WISHLIST_TAB_SEARCH then
            if data.armorTypes ~= nil then
                if searchValueIsNumber and searchInputNumber ~= nil then
                    if data.armorTypes[searchInputNumber] ~= nil and data.armorTypes[searchInputNumber] == true then
                        return true
                    end
                elseif searchValueIsString then
                    local armorTypes = WL.ArmorTypes
                    for armorTypeNr, armorTypeText in ipairs(armorTypes) do
                        if zo_plainstrfind(armorTypeText:lower(), searchInputLower) then
                            if data.armorTypes[armorTypeNr] == true then
                                return true
                            end
                        end
                    end
                    return
                end
            end
        else
            local itemLink = data["itemLink"]
            if itemLink then
                local itemType = GetItemLinkItemType(itemLink)
                if itemType and itemType == ITEMTYPE_ARMOR then
                    if searchValueIsString then
                        local armorOrWeaponTypeName = data.armorOrWeaponTypeName
                        if armorOrWeaponTypeName and armorOrWeaponTypeName ~= "" then
                            if zo_plainstrfind(armorOrWeaponTypeName:lower(), searchInputLower) then
                                return true
                            end
                        end
                    elseif searchValueIsNumber then
                        local armorOrWeaponType = data.armorOrWeaponType
                        if armorOrWeaponType ~= nil and armorOrWeaponType == searchInputNumber then return true end
                    end
                end
            end
        end

    --Search by weapon type
    elseif searchType == WISHLIST_SEARCH_TYPE_BY_WEAPONTYPE then
        --Are we searching at the WishList and/or History, then we are able to use the itemlink
        --Else we need to use the armorTypes table (e.g. at the set search, as there is only 1 example itemlink in the
        --dataEntry.data (could be a weapon or ring...)
        if WL.CurrentTab == WISHLIST_TAB_SEARCH then
            if data.weaponTypes ~= nil then
                if searchValueIsNumber and searchInputNumber ~= nil then
                    if data.weaponTypes[searchInputNumber] ~= nil and data.weaponTypes[searchInputNumber] == true then
                        return true
                    end
                elseif searchValueIsString then
                    local weaponTypes = WL.WeaponTypes
                    for weaponTypeNr, weaponTypeText in ipairs(weaponTypes) do
                        if zo_plainstrfind(weaponTypeText:lower(), searchInputLower) then
                            if data.weaponTypes[weaponTypeNr] == true then
                                return true
                            end
                        end
                    end
                    return
                end
            end
        else
            local itemLink = data["itemLink"]
            if itemLink then
                local itemType = GetItemLinkItemType(itemLink)
                if itemType and itemType == ITEMTYPE_WEAPON then
                    if searchValueIsString then
                        local armorOrWeaponTypeName = data.armorOrWeaponTypeName
                        if armorOrWeaponTypeName and armorOrWeaponTypeName ~= "" then
                            if zo_plainstrfind(armorOrWeaponTypeName:lower(), searchInputLower) then
                                return true
                            end
                        end
                    elseif searchValueIsNumber then
                        local armorOrWeaponType = data.armorOrWeaponType
                        if armorOrWeaponType ~= nil and armorOrWeaponType == searchInputNumber then return true end
                    end
                end
            end
        end
    --Search by slot
    elseif searchType == WISHLIST_SEARCH_TYPE_BY_SLOT then
        if searchValueIsString then
            local slotTypeName = data.slotName
            if slotTypeName and slotTypeName ~= "" then
                if zo_plainstrfind(slotTypeName:lower(), searchInputLower) then
                    return true
                end
            end
        elseif searchValueIsNumber then
            local slotType = data.slot
            if slotType ~= nil and slotType == searchInputNumber then return true end
        end

    --Search by trait
    elseif searchType == WISHLIST_SEARCH_TYPE_BY_TRAIT then
        if searchValueIsString then
            local traitTypeName = data.traitName
            if traitTypeName and traitTypeName ~= "" then
                if zo_plainstrfind(traitTypeName:lower(), searchInputLower) then
                    return true
                end
            end
        elseif searchValueIsNumber then
            local traitType = data.trait
            if traitType ~= nil and traitType == searchInputNumber then return true end
        end

    --Search by location
    elseif searchType == WISHLIST_SEARCH_TYPE_BY_LOCATION then
        if searchValueIsString then
            local location = data.locality
            if location and location ~= "" then
                if zo_plainstrfind(location:lower(), searchInputLower) then
                    return true
                end
            end
        end

    --Search by username
    elseif searchType == WISHLIST_SEARCH_TYPE_BY_USERNAME then
        if searchValueIsString then
            local charName = data.username
            local accName = data.displayName
            if (charName and charName ~= "") or (accName and accName ~= "") then
                if (charName and zo_plainstrfind(charName:lower(), searchInputLower)) or (accName and zo_plainstrfind(accName:lower(), searchInputLower)) then
                    return true
                end
            end
        end

    --Search by itemId
    elseif searchType == WISHLIST_SEARCH_TYPE_BY_ITEMID then
        local itemId = data.id
        if itemId and zo_plainstrfind(itemId, searchInput) then
            return true
        end

    --Search by date
    elseif searchType == WISHLIST_SEARCH_TYPE_BY_DATE then
        if searchValueIsString then
            local timestamp = data.timestamp
            if timestamp ~= nil then
                --Create the date format from the timestamp
                local dateTimeStr = WL.getDateTimeFormatted(timestamp)
                if dateTimeStr ~= "" then
                    if zo_plainstrfind(dateTimeStr:lower(), searchInputLower) then
                        return true
                    end
                end
                --and compare it to the entered date format
            end
        end

------------------------------------------------------------------------------------------------------------------------
--LibSets searches
------------------------------------------------------------------------------------------------------------------------
    --Search by setType
    elseif searchType == WISHLIST_SEARCH_TYPE_BY_LIBSETSSETTYPE then
        local setType = data.setType
        if searchValueIsString then
            local setTypeName = data.setTypeName
            if setTypeName and setTypeName ~= "" then
                --Get the translated setType to "en" if the current client language is not "en"
                local setTypeNameEN
                if not WL.clientLangIsEN then
                    setTypeNameEN = libSets.GetSetTypeName(setType, "en")
                end
                local setTypeNameLower = setTypeName:lower()
                if setTypeNameEN and setTypeNameEN ~= "" then
                    if (zo_plainstrfind(setTypeNameLower, searchInputLower) or zo_plainstrfind(setTypeNameEN:lower(), searchInputLower)) then
                        return true
                    end
                else
                    if zo_plainstrfind(setTypeNameLower, searchInputLower) then
                        return true
                    end
                end
            end
        elseif searchValueIsNumber then
            if setType ~= nil and setType == searchInputNumber then return true end
        end

    --Search by dlcId
    elseif searchType == WISHLIST_SEARCH_TYPE_BY_LIBSETSDLCID then
        if searchValueIsString then
            local dlcName = data.dlcName
            if dlcName and dlcName ~= "" then
                if zo_plainstrfind(dlcName:lower(), searchInputLower) then
                    return true
                end
            end
        elseif searchValueIsNumber then
            local dlcId = data.dlcId
            if dlcId ~= nil and dlcId == searchInputNumber then return true end
        end

    --Search by traitsNeeded
    elseif searchType == WISHLIST_SEARCH_TYPE_BY_LIBSETSTRAITSNEEDED then
        if searchValueIsNumber then
            local traitsNeeded = data.traitsNeeded
            if traitsNeeded ~= nil and traitsNeeded == searchInputNumber then return true end
        end

    --Search by zoneId
    elseif searchType == WISHLIST_SEARCH_TYPE_BY_LIBSETSZONEID then
        local zoneIds = data.zoneIds
        if zoneIds then
            if searchValueIsString then
                local zoneIdsNames = data.zoneIdNames
                if zoneIdsNames then
                    for _, zoneIdName in pairs(zoneIdsNames) do
                        if zo_plainstrfind(zoneIdName:lower(), searchInputLower) then
                            return true
                        end
                    end
                end
            elseif searchValueIsNumber then
                for _, zoneId in ipairs(zoneIds) do
                    if zoneId > 0 then
                        if zoneId == searchInputNumber then return true  end
                    end
                end
            end
        end

    --Search by wayshrine
    elseif searchType == WISHLIST_SEARCH_TYPE_BY_LIBSETSWAYSHRINENODEINDEX then
        local wayshrines = data.wayshrines
        if wayshrines then
            if searchValueIsString then
                local wayshrineNames = data.wayshrineNames
                if wayshrineNames then
                    for _, wayshrineName in pairs(wayshrineNames) do
                        if zo_plainstrfind(wayshrineName:lower(), searchInputLower) then
                            return true
                        end
                    end
                end
            elseif searchValueIsNumber then
                for _, wayshrineNodeIndex in ipairs(wayshrines) do
                    if wayshrineNodeIndex > 0 then
                        if wayshrineNodeIndex == searchInputNumber then return true  end
                    end
                end
            end
        end

    --Search by drop mechanic
    elseif searchType == WISHLIST_SEARCH_TYPE_BY_LIBSETSDROPMECHANIC then
        local dropMechanics = data.dropMechanics
        if dropMechanics then
            for _, dropMechanic in ipairs(dropMechanics) do
                if searchValueIsString then
                    local dropMechanicName = libSets.GetDropMechanicName(dropMechanic)
                    if dropMechanicName and dropMechanicName ~= "" then
                        if zo_plainstrfind(dropMechanicName:lower(), searchInputLower) then
                            return true
                        end
                    end
                elseif searchValueIsNumber then
                    if dropMechanic == searchInputNumber then return true end
                end
            end
        end
    end

    return false
end

function WishListWindow:CheckForMatch( data, searchInput )
    local searchType = self.searchType
    if searchType ~= nil then
--d("[WLW:CheckForMatch]searchType: " .. tostring(searchType) .. ", searchInput: " .. tostring(searchInput))
        --Search by name
        if searchType == WISHLIST_SEARCH_TYPE_BY_NAME then
            local isMatch = false
            local searchInputNumber = tonumber(searchInput)
            if searchInputNumber ~= nil then
                local searchValueType = type(searchInputNumber)
                if searchValueType == "number" then
                    isMatch = searchInputNumber == data.setId or false
                end
            else
                isMatch = self.search:IsMatch(searchInput, data)
            end
            return isMatch
        --Search by set bonus
        elseif (searchType == WISHLIST_SEARCH_TYPE_BY_SET_BONUS) then
            local bonuses = data.bonuses
            if (type(bonuses) == "number") then
                -- Lazy initialization of set bonus data
                data.bonuses = WL.GetSetBonuses(data.itemLink, bonuses)
            end
            return(self:SearchSetBonuses(data.bonuses, searchInput))
            --Search by type
        else
            local searchTypesForCriteria = WL.searchTypesForCriteria
            local searchTypeForCriteria = searchTypesForCriteria[searchType] or nil
            if searchTypeForCriteria ~= nil then
                return(self:SearchByCriteria(data, searchInput, searchType))
            end
        end
    end
	return(false)
end

function WishListWindow:ProcessItemEntry( stringSearch, data, searchTerm )
--d("[WLW.ProcessItemEntry] stringSearch: " ..tostring(stringSearch) .. ", setName: " .. tostring(data.name:lower()) .. ", searchTerm: " .. tostring(searchTerm))
	if ( zo_plainstrfind(data.name:lower(), searchTerm) ) then
		return(true)
	end
	return(false)
end

------------------------------------------------
--- Wish List Search Dropdown
------------------------------------------------
function WishListWindow:SearchNow(searchValue, resetSearchTextBox)
--d("[WishListWindow:SearchNow]searchValue: " ..tostring(searchValue))
    resetSearchTextBox = resetSearchTextBox or false
    if not searchValue then return end
    local searchBox = self.searchBox
    if not searchBox then return end
    searchBox:Clear()
    if searchValue == "" and resetSearchTextBox then return end
    searchBox:SetText(searchValue) --Will automatically raise self:RefreshFilters() as OnTextChanged event fires
end

--Search edit box context menu
function WishListWindow:OnSearchEditBoxContextMenu(editboxControl)
    local wlWindow = self
    local searchType = self.searchType
    --d("EditBox right clicked: " ..tostring(editboxControl:GetName()) ..", searchType: " ..tostring(searchType))
    if searchType == nil then return end
    local searchTypesForContextMenuCriteria = WL.searchTypesForContextMenuCriteria
    local searchTypeForContextMenuCriteria = searchTypesForContextMenuCriteria[searchType] or nil
    --Not supported search type? Then abort here
    if not searchTypeForContextMenuCriteria then return end
    local searchTypeText = WL.getSearchTypeText(searchType)
    if not searchTypeText or searchTypeText == "" then return end
    local contextMenuEntries = {}
    local contextSubMenuEntries = {}
    if     searchType == WISHLIST_SEARCH_TYPE_BY_ARMORTYPE   then
        local armorTypes = WL.ArmorTypes
        for armorTypeId, armorTypeText in ipairs(armorTypes) do
            table.insert(contextMenuEntries, {label = armorTypeText, callback = function() wlWindow:SearchNow(tostring(armorTypeId)) end})
        end

    elseif searchType == WISHLIST_SEARCH_TYPE_BY_WEAPONTYPE   then
        local weaponsTypes = WL.WeaponTypes
        for weaponTypeId,weaponTypeText in ipairs(weaponsTypes) do
            table.insert(contextMenuEntries, {label = weaponTypeText, callback = function() wlWindow:SearchNow(tostring(weaponTypeId)) end})
        end

    elseif searchType == WISHLIST_SEARCH_TYPE_BY_SLOT then
        local slotTypes = WL.SlotTypes
        for slotTypeId,slotTypeText in ipairs(slotTypes) do
            table.insert(contextMenuEntries, {label = slotTypeText, callback = function() wlWindow:SearchNow(tostring(slotTypeId)) end})
        end

    elseif searchType == WISHLIST_SEARCH_TYPE_BY_TRAIT then
        local traitTypes = WL.TraitTypes
        local traitTypesToExclude = {
            [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = true,
            [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = true,
            [WISHLIST_TRAIT_TYPE_SPECIAL] = true, --the "special" traits entry
            [WISHLIST_TRAIT_TYPE_ALL] = true, --the "all" traits entry
        }
        local traitHeadLines = {
            [ITEM_TRAIT_TYPE_WEAPON_POWERED]    = GetString(WISHLIST_WEAPONS),
            [ITEM_TRAIT_TYPE_ARMOR_STURDY]      = GetString(WISHLIST_ARMOR),
            [ITEM_TRAIT_TYPE_JEWELRY_HEALTHY]   = GetString(WISHLIST_JEWELRY),
        }
        local useSubMenuNr = 0
        local subMenuArmor = {}
        local subMenuWeapons = {}
        local subMenuJewelry = {}
        local subMenuTable = {
            [1] = subMenuArmor,
            [2] = subMenuWeapons,
            [3] = subMenuJewelry,
        }
        for traitTypeId, traitTypeText in ipairs(traitTypes) do
            if not traitTypesToExclude[traitTypeId] then
                local traitHeadlineText = traitHeadLines[traitTypeId] or ""
                if traitHeadlineText ~= nil and traitHeadlineText ~= "" then
                    useSubMenuNr = useSubMenuNr + 1
                end
                --Add submenu entry
                table.insert(subMenuTable[useSubMenuNr], {label = traitTypeText, callback = function() wlWindow:SearchNow(tostring(traitTypeId)) end})
            end
        end
        --Insert the nirnhorned trait types to armor and weapon now (as their trade ids are in between at the jewelry id range...) into the submenu entries
        -->One before the "Weapons" placeholder and one before the "Jewelry" placeholder
        table.insert(subMenuArmor, {label = traitTypes[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED], callback = function() wlWindow:SearchNow(tostring(ITEM_TRAIT_TYPE_ARMOR_NIRNHONED)) end})
        table.insert(subMenuWeapons, {label = traitTypes[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED], callback = function() wlWindow:SearchNow(tostring(ITEM_TRAIT_TYPE_WEAPON_NIRNHONED)) end})
        --Add the submenus to the contextSubMenuEntries table
        table.insert(contextSubMenuEntries, {subMenuName=traitHeadLines[ITEM_TRAIT_TYPE_WEAPON_POWERED],    subMenuEntries=subMenuArmor})
        table.insert(contextSubMenuEntries, {subMenuName=traitHeadLines[ITEM_TRAIT_TYPE_ARMOR_STURDY],      subMenuEntries=subMenuWeapons})
        table.insert(contextSubMenuEntries, {subMenuName=traitHeadLines[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY],   subMenuEntries=subMenuJewelry})

    elseif searchType == WISHLIST_SEARCH_TYPE_BY_LIBSETSSETTYPE then
        local setTypes = libSets.GetAllSetTypes()
        for setTypeId,allowed in ipairs(setTypes) do
            if allowed == true then
                local setTypeText = libSets.GetSetTypeName(setTypeId)
                if not setTypeText or setTypeText == "" then
                    setTypeText = libSets.GetSetTypeName(setTypeId, "en")
                end
                table.insert(contextMenuEntries, {label = setTypeText, callback = function() wlWindow:SearchNow(tostring(setTypeId)) end})
            end
        end

    elseif searchType == WISHLIST_SEARCH_TYPE_BY_LIBSETSDLCID then
        local dlcIDs = libSets.GetAllDLCIds()
        for dlcID,allowed in ipairs(dlcIDs) do
            if allowed == true then
                local dlcIdText = libSets.GetDLCName(dlcID)
                if not dlcIdText or dlcIdText == "" then
                    dlcIdText = libSets.GetDLCName(dlcID, "en")
                end
                table.insert(contextMenuEntries, {label = dlcIdText, callback = function() wlWindow:SearchNow(tostring(dlcID)) end})
            end
        end
        table.insert(contextMenuEntries, 1, {label = libSets.GetDLCName(DLC_BASE_GAME), callback = function() wlWindow:SearchNow(tostring(DLC_BASE_GAME)) end})

    elseif searchType == WISHLIST_SEARCH_TYPE_BY_LIBSETSDROPMECHANIC then
        local dropMechanics = libSets.GetAllDropMechanics()
        for dropMechanic,allowed in ipairs(dropMechanics) do
            if allowed == true then
                local dropMechanicText = libSets.GetDropMechanicName(dropMechanic)
                if not dropMechanicText or dropMechanicText == "" then
                    dropMechanicText = libSets.GetDropMechanicName(dropMechanic, "en")
                end
                table.insert(contextMenuEntries, {label = dropMechanicText, callback = function() wlWindow:SearchNow(tostring(dropMechanic)) end})
            end
        end

    end
    --Show the context menu, including submenus
    ClearMenu()
    AddCustomMenuItem("|c6F6F6F".. searchTypeText .."|r", function() wlWindow:SearchNow("", true) end)
    AddCustomMenuItem("-")
    if contextSubMenuEntries and #contextSubMenuEntries > 0 then
        for _, subMenuData in ipairs(contextSubMenuEntries) do
            AddCustomSubMenuItem(subMenuData.subMenuName, subMenuData.subMenuEntries)
        end
    elseif contextMenuEntries and #contextMenuEntries > 0 then
        for _, data in ipairs(contextMenuEntries) do
            AddCustomMenuItem(data.label, data.callback)
        end
    end
    ShowMenu(editboxControl)
end

------------------------------------------------
--- Wish List Row
------------------------------------------------
function WishListRow_OnMouseEnter( rowControlEnter )
	WL.window:Row_OnMouseEnter(rowControlEnter)
    local showItemLinkTooltip = false
    local showAdditionalTextTooltip = false
    if WL.CurrentTab ~= WISHLIST_TAB_HISTORY then
        showItemLinkTooltip = true
    else
        showItemLinkTooltip = true
        showAdditionalTextTooltip = true
    end
    if showItemLinkTooltip then
        WL.showItemLinkTooltip(rowControlEnter, WishListFrame, TOPRIGHT, -100, 0, TOPLEFT)
    end
    if showAdditionalTextTooltip then
        local data = rowControlEnter.data
        if data ~= nil then
            local clientLang = WL.clientLang or WL.fallbackSetLang
            local tooltipText = ""
            local nameVar = ""
            if data.names then
                nameVar = data.names[clientLang]
            elseif data.name then
                nameVar = data.name
            end
            tooltipText = GetString(WISHLIST_TOOLTIP_COLOR_KEY) .. GetString(WISHLIST_CONST_SET) .. "|r: " .. GetString(WISHLIST_TOOLTIP_COLOR_VALUE) .. nameVar .. "|r (" .. GetString(WISHLIST_CONST_BONUS) .. ": " .. GetString(WISHLIST_TOOLTIP_COLOR_VALUE) .. data.bonuses .. "|r, " .. GetString(WISHLIST_CONST_ID) .. ": " .. GetString(WISHLIST_TOOLTIP_COLOR_VALUE) .. data.setId .. "|r)"
            tooltipText = tooltipText .. "\n" .. GetString(WISHLIST_TOOLTIP_COLOR_KEY) .. GetString(WISHLIST_HEADER_LOCALITY) .. "|r: " .. GetString(WISHLIST_TOOLTIP_COLOR_VALUE) .. data.locality .. "|r"
            tooltipText = tooltipText .. "\n" .. GetString(WISHLIST_TOOLTIP_COLOR_KEY) .. GetString(WISHLIST_HEADER_NAME) .. "|r: " .. GetString(WISHLIST_TOOLTIP_COLOR_VALUE) ..data.username .. "|r"
            if data.displayName ~= nil and data.displayName ~= "" then
                tooltipText = tooltipText .. " [" .. data.displayName .. "]"
            end
            if data.timestamp ~= nil then
                local dateTimeStr = WL.getDateTimeFormatted(data.timestamp)
                tooltipText = tooltipText .. "\n" .. GetString(WISHLIST_TOOLTIP_COLOR_KEY) .. GetString(WISHLIST_HEADER_DATE) .. "|r: " .. GetString(WISHLIST_TOOLTIP_COLOR_VALUE) .. dateTimeStr .. "|r"
            end
            if tooltipText ~= "" then
                WL.ShowTooltip(rowControlEnter, TOP, tooltipText)
            end
        end
    end
end

function WishListRow_OnMouseExit( rowControlExit )
	WL.window:Row_OnMouseExit(rowControlExit)
    WL.hideItemLinkTooltip()
    WL.HideTooltip()
end

function WishListRow_OnMouseUp( rowControlUp, button, upInside )
    if upInside then
        WL.hideItemLinkTooltip()
        WL.HideTooltip()
        WL.showContextMenu(rowControlUp, button, upInside)
    end
end


------------------------------------------------
--- Combo Box Initializers
------------------------------------------------
function WL.initializeSearchDropdown(wishListWindow, currentTab, searchBoxType)
    if wishListWindow == nil then return false end
    currentTab = currentTab or WL.CurrentTab or WISHLIST_TAB_SEARCH
    searchBoxType = searchBoxType or "set"
--d("[WL.initializeSearchDropdown]currentTab: " ..tostring(currentTab) ..", searchBoxType: " ..tostring(searchBoxType))
    WL.checkCharsData()
    if currentTab == WISHLIST_TAB_WISHLIST and (WL.charsData == nil or #WL.charsData == 0) then return false end
    local currentTab2SearchDropValues = {
        [WISHLIST_TAB_SEARCH]   = {
            ["set"] = {dropdown=wishListWindow.searchDrop,  prefix=WISHLIST_SEARCHDROP_PREFIX,  entryCount=WISHLIST_TAB_SEARCH_ENTRY_COUNT,
                        exclude = {
                            [WISHLIST_SEARCH_TYPE_BY_NAME]                = false,
                            [WISHLIST_SEARCH_TYPE_BY_SET_BONUS]           = false,
                            [WISHLIST_SEARCH_TYPE_BY_ARMORTYPE]           = false,
                            [WISHLIST_SEARCH_TYPE_BY_WEAPONTYPE]          = false,
                            [WISHLIST_SEARCH_TYPE_BY_SLOT]                = true,
                            [WISHLIST_SEARCH_TYPE_BY_TRAIT]               = true,
                            [WISHLIST_SEARCH_TYPE_BY_ITEMID]              = true,
                            [WISHLIST_SEARCH_TYPE_BY_DATE]                = true,
                            [WISHLIST_SEARCH_TYPE_BY_LOCATION]            = true,
                            [WISHLIST_SEARCH_TYPE_BY_USERNAME]            = true,
                            [WISHLIST_SEARCH_TYPE_BY_LIBSETSSETTYPE]      = false,
                            [WISHLIST_SEARCH_TYPE_BY_LIBSETSDLCID]        = false,
                            [WISHLIST_SEARCH_TYPE_BY_LIBSETSTRAITSNEEDED] = false,
                            [WISHLIST_SEARCH_TYPE_BY_LIBSETSZONEID]       = false,
                            [WISHLIST_SEARCH_TYPE_BY_LIBSETSWAYSHRINENODEINDEX] = false,
                            [WISHLIST_SEARCH_TYPE_BY_LIBSETSDROPMECHANIC]           = false,
                        }, --exclude the search entries from the set search
            },
        },
        [WISHLIST_TAB_WISHLIST] = {
            ["set"] = {dropdown=wishListWindow.searchDrop,  prefix=WISHLIST_SEARCHDROP_PREFIX,  entryCount=WISHLIST_TAB_WHISLIST_ENTRY_COUNT,
                       exclude = {
                           [WISHLIST_SEARCH_TYPE_BY_NAME]                = false,
                           [WISHLIST_SEARCH_TYPE_BY_SET_BONUS]           = false,
                           [WISHLIST_SEARCH_TYPE_BY_ARMORTYPE]           = false,
                           [WISHLIST_SEARCH_TYPE_BY_WEAPONTYPE]          = false,
                           [WISHLIST_SEARCH_TYPE_BY_SLOT]                = false,
                           [WISHLIST_SEARCH_TYPE_BY_TRAIT]               = false,
                           [WISHLIST_SEARCH_TYPE_BY_ITEMID]              = false,
                           [WISHLIST_SEARCH_TYPE_BY_DATE]                = false,
                           [WISHLIST_SEARCH_TYPE_BY_LOCATION]            = true,
                           [WISHLIST_SEARCH_TYPE_BY_USERNAME]            = true,
                           [WISHLIST_SEARCH_TYPE_BY_LIBSETSSETTYPE]      = false,
                           [WISHLIST_SEARCH_TYPE_BY_LIBSETSDLCID]        = false,
                           [WISHLIST_SEARCH_TYPE_BY_LIBSETSTRAITSNEEDED] = false,
                           [WISHLIST_SEARCH_TYPE_BY_LIBSETSZONEID]       = false,
                           [WISHLIST_SEARCH_TYPE_BY_LIBSETSWAYSHRINENODEINDEX] = false,
                           [WISHLIST_SEARCH_TYPE_BY_LIBSETSDROPMECHANIC]           = false,
                       }, --exclude the search entries from the set search
            },
            ["char"]= {dropdown=wishListWindow.charsDrop,   prefix=WISHLIST_CHARSDROP_PREFIX,    entryCount=#WL.charsData},
        },
        [WISHLIST_TAB_HISTORY] = {
            ["set"] = {dropdown=wishListWindow.searchDrop,  prefix=WISHLIST_SEARCHDROP_PREFIX,  entryCount=WISHLIST_TAB_HISTORY_ENTRY_COUNT,
                       exclude = {
                           [WISHLIST_SEARCH_TYPE_BY_NAME]                = false,
                           [WISHLIST_SEARCH_TYPE_BY_SET_BONUS]           = false,
                           [WISHLIST_SEARCH_TYPE_BY_ARMORTYPE]           = false,
                           [WISHLIST_SEARCH_TYPE_BY_WEAPONTYPE]          = false,
                           [WISHLIST_SEARCH_TYPE_BY_SLOT]                = false,
                           [WISHLIST_SEARCH_TYPE_BY_TRAIT]               = false,
                           [WISHLIST_SEARCH_TYPE_BY_ITEMID]              = false,
                           [WISHLIST_SEARCH_TYPE_BY_DATE]                = false,
                           [WISHLIST_SEARCH_TYPE_BY_LOCATION]            = false,
                           [WISHLIST_SEARCH_TYPE_BY_USERNAME]            = false,
                           [WISHLIST_SEARCH_TYPE_BY_LIBSETSSETTYPE]      = false,
                           [WISHLIST_SEARCH_TYPE_BY_LIBSETSDLCID]        = false,
                           [WISHLIST_SEARCH_TYPE_BY_LIBSETSTRAITSNEEDED] = false,
                           [WISHLIST_SEARCH_TYPE_BY_LIBSETSZONEID]       = false,
                           [WISHLIST_SEARCH_TYPE_BY_LIBSETSWAYSHRINENODEINDEX] = false,
                           [WISHLIST_SEARCH_TYPE_BY_LIBSETSDROPMECHANIC]           = false,
                       }, --exclude the search entries from the set search
            },
            ["char"] = {dropdown=wishListWindow.charsDrop,   prefix=WISHLIST_CHARSDROP_PREFIX,    entryCount=#WL.charsData},
        },
    }
    local searchDropAtTab = currentTab2SearchDropValues[currentTab]
    local searchDropData = searchDropAtTab[searchBoxType]
    if searchDropData == nil then return false end
    --d(">searchDropData: " .. tostring(searchDropData.dropdown) ..", " ..tostring(searchDropData.prefix) .. ", " .. tostring(searchDropData.entryCount))
    wishListWindow:InitializeComboBox(searchDropData.dropdown, searchDropData.prefix, searchDropData.entryCount, searchDropData.exclude, searchBoxType )
end

function WishListWindow:InitializeComboBox( control, prefix, max, exclude, searchBoxType )
    local isCharCB = ((prefix == WISHLIST_CHARSDROP_PREFIX) or searchBoxType == "char") or false
    local isSetSearchCB = ((prefix == WISHLIST_SEARCHDROP_PREFIX) or searchBoxType == "set") or false
--d("[WishListWindow:InitializeComboBox]isSetSearchCB: " .. tostring(isSetSearchCB) .. ", isCharCB: " .. tostring(isCharCB) .. ", prefix: " .. tostring(prefix) ..", max: " .. tostring(max))
    --local setSearchCBEntryStart = WISHLIST_SEARCHDROP_PREFIX
    control:SetSortsItems(false)
    control:ClearItems()

    local callback = function( _, _, entry, _ ) --comboBox, entryText, entry, selectionChanged, oldItem )
        self:SetSearchBoxLastSelected(WL.CurrentTab, searchBoxType, entry.selectedIndex)
        self:RefreshFilters()
    end
    local function charTooltipFunc(charName, charData)
        local tooltipText
        if WL.CurrentTab == WISHLIST_TAB_WISHLIST then
            tooltipText = zo_strformat(WISHLIST_CHARDROPDOWN_ITEMCOUNT_WISHLIST, charName, WL.getWishListItemCount(charData))
        elseif WL.CurrentTab == WISHLIST_TAB_HISTORY then
            tooltipText = zo_strformat(WISHLIST_CHARDROPDOWN_ITEMCOUNT_HISTORY, charName, WL.getHistoryItemCount(charData))
        end
        return tooltipText
    end

    local selectedCharDataBeforeUpdate
    --local currentCharName
    local currentCharId = 0
    local itemToSelect = 1
    --local currentCharName = ""
    --Character combo box?
    if isCharCB then
        --currentCharName = GetUnitName("player")
        --Format the name
        --currentCharName = zo_strformat(SI_UNIT_NAME, currentCharName)
        selectedCharDataBeforeUpdate = WL.SelectedCharDataBeforeUpdate or nil
        if selectedCharDataBeforeUpdate ~= nil and selectedCharDataBeforeUpdate.charId ~= nil then
            currentCharId = selectedCharDataBeforeUpdate.charId
        else
            currentCharId = GetCurrentCharacterId()
        end
    end

--Normal entries
    local comboBoxMenuEntries = {
        --[[
        {
            name            = "Normal entry 1",
            callback        =   function(comboBox, itemName, item, selectionChanged, oldItem)
                d("Normal entry 1")
            end,
            icon			= "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_Staff_Frost_Up.dds",
            isNew			= true,
            --entries         = submenuEntries,
            --tooltip         =
        },
        {
            name            = "-", --Divider
        },
        ...
        ]]
    }

    local numEntriesAdded = 0
    for i = 1, max do
        if not exclude or (exclude and not exclude[i]) then
            local entry
            --Character combo box?
            if isCharCB then
                local charData = WL.charsData[i]
                local charNameToken = prefix .. tostring(charData.id)
                local charName = (charData and charData.name) or GetString(charNameToken)
                local charId = -1
                if charData ~= nil then
                    charId = charData.id
                    --[[
                    if charData.nameClean == currentCharName then
                        itemToSelect = i
                    end
                    ]]
                    if charId == currentCharId then
                        itemToSelect = i
                    end
                else
                    charId = i
                end

                numEntriesAdded = numEntriesAdded + 1

                entry = {
                    name            = charName,
                    --label           = ""
                    callback        = callback,
                    --icon			= "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_Staff_Frost_Up.dds",
                    --isNew			= true,
                    --entries         = submenuEntries,
                    tooltip         = function() return charTooltipFunc(charName, charData) end,

                    --Custom entry data
                    id = charId,
                    selectedIndex = numEntriesAdded,
                    nameClean = charData.nameClean,
                    class = charData.class,
                }
                table.insert(comboBoxMenuEntries, entry)

                --Search type combo box
            elseif isSetSearchCB then
                local entryText = GetString(prefix, i)

                numEntriesAdded = numEntriesAdded + 1

                entry = {
                    name            = entryText,
                    --label           = ""
                    callback        = callback,
                    --icon			= "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_Staff_Frost_Up.dds",
                    --isNew			= true,
                    --entries         = submenuEntries,
                    --tooltip         = tooltipText,

                    --Custom entry data
                    id = i,
                    selectedIndex = numEntriesAdded,
                }
                table.insert(comboBoxMenuEntries, entry)
            end
        end
    end

    --Add the entries (menu and submenu) to the combobox
    control:AddItems(comboBoxMenuEntries)

    if itemToSelect ~= nil then
        if isSetSearchCB then
            itemToSelect = self:GetSearchBoxLastSelected(WL.CurrentTab, "set")
        end
        control:SelectItemByIndex(itemToSelect, true)
    end


    --Character dropdown box?
    if isCharCB then
        --Set a variable to check if the dropdown of characters is currently visible
        ZO_PreHook(control, "SetVisible", function(self, visible)
            if(visible) then
                WL.activeCharDropdown = self
            else
                WL.activeCharDropdown = nil
            end
        end)

        --[[ Not working anymore since ZO_ComboBox is not using ZO_Menu anymore since API101040
             ->Code was moved to LibScrollableMenu code above, see comboBoxMenuEntries -> if isCharCB then
        --Show tooltips in WishList char dropdown entries, if the dropdown box is allowed
        ZO_PreHook("ZO_Menu_SetSelectedIndex", function(index)
            if(not WL.activeCharDropdown) then return end
            ZO_Tooltips_HideTextTooltip()
            if(not index or not ZO_Menu.items) then return end
            local mouseOverControl = WINDOW_MANAGER:GetMouseOverControl()
            if not mouseOverControl then return false end
            index = zo_max(zo_min(index, #ZO_Menu.items), 1)
            if index then
                local selectedControlItem = control.m_sortedItems[index]
                if selectedControlItem ~= nil and selectedControlItem.id ~= nil then
                    local charData = {}
                    charData.id = selectedControlItem.id
                    local tooltipText = ""
                    if WL.CurrentTab == WISHLIST_TAB_WISHLIST then
                        tooltipText = zo_strformat(WISHLIST_CHARDROPDOWN_ITEMCOUNT_WISHLIST, selectedControlItem.name, WL.getWishListItemCount(charData))
                    elseif WL.CurrentTab == WISHLIST_TAB_HISTORY then
                        tooltipText = zo_strformat(WISHLIST_CHARDROPDOWN_ITEMCOUNT_HISTORY, selectedControlItem.name, WL.getHistoryItemCount(charData))
                    end
                    if tooltipText ~= nil and tooltipText ~= "" then
                        ZO_Tooltips_ShowTextTooltip(mouseOverControl, LEFT, tooltipText)
                    end
                end
            end
        end)
        ]]

    end
end

function WishListWindow:SetSearchBoxLastSelected(wishListUITab, searchBoxType, selectedIndex)
    WL.searchBoxLastSelected[wishListUITab] = WL.searchBoxLastSelected[wishListUITab] or {}
    WL.searchBoxLastSelected[wishListUITab][searchBoxType] = selectedIndex
end

function WishListWindow:GetSearchBoxLastSelected(wishListUITab, searchBoxType)
    if WL.searchBoxLastSelected[wishListUITab] and WL.searchBoxLastSelected[wishListUITab][searchBoxType] then
        return WL.searchBoxLastSelected[wishListUITab][searchBoxType]
    end
    return 1
end