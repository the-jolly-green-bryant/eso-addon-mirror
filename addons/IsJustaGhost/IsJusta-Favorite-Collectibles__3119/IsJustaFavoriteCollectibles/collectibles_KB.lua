local IJA_FavoriteCollectibles = IJA_FAVORITECOLLECTIBLES

local function getCurrentCategoryData(self)
	if self.categoryTree then
		return self.categoryTree:GetSelectedData()
	end
end

local function ShouldAddCollectible(filterType, categoryData, collectibleData)
	if filterType == SI_COLLECTIONS_BOOK_FILTER_SHOW_ALL then
		return categoryData:IsValidForCategory(collectibleData)
	end

	if collectibleData:IsUnlocked() then
		if categoryData:IsValidForCategory(collectibleData) then
			if filterType == SI_COLLECTIONS_BOOK_FILTER_SHOW_UNLOCKED then
				return true
			elseif filterType == SI_COLLECTIONS_BOOK_FILTER_SHOW_USABLE then
				return collectibleData:IsValidForPlayer()
			elseif filterType == SI_COLLECTIONS_BOOK_FILTER_SHOW_NEW then
				return collectibleData:IsNew()
			else
				return false
			end
		end
	else
		return filterType == SI_COLLECTIONS_BOOK_FILTER_SHOW_LOCKED
	end
end

local function buildContentList(self, categoryData, collectiblesData, setDefaults)
	if IJA_COLLECTIBLERANDOMIZER then
		IJA_COLLECTIBLERANDOMIZER.BuildRandomizers_Keyboard(self, categoryData)
	else
		ZO_AbstractGridScrollList.ClearGridList(self.gridListPanelList)
		ZO_EntryDataPool.ReleaseAllObjects(self.entryDataObjectPool)
	end
	
	local gridListPanelList = self.gridListPanelList
	local defaultTilesProcessed = false

	local collectibleCategoryTypesInCategory = categoryData:GetCollectibleCategoryTypesInCategory()
	if not defaultTilesProcessed and collectibleCategoryTypesInCategory[COLLECTIBLE_CATEGORY_TYPE_MOUNT] then
		setDefaults(gridListPanelList, collectibleCategoryTypesInCategory)
		defaultTilesProcessed = true
	end
	for _, collectibleData in ipairs(collectiblesData) do
		if ShouldAddCollectible(self.categoryFilterComboBox.filterType, categoryData, collectibleData) then

			local entryData = self.entryDataObjectPool:AcquireObject()
			entryData:SetDataSource(collectibleData)
			entryData.gridHeaderTemplate = ZO_GRID_SCROLL_LIST_DEFAULT_HEADER_TEMPLATE_KEYBOARD
			entryData.gridHeaderName = categoryData:GetBestCollectibleHeader(collectibleData)

			if self.hotbarCategory then
				entryData.utilityWheel = self.wheel
			else
				entryData.utilityWheel = nil
			end
			gridListPanelList:AddEntry(entryData, "ZO_CollectibleTile_Keyboard_Control")
		end
	end

	gridListPanelList:CommitGridList()
end

local function initializeCollectibles_Character()
	local function GetCollectiblesDataFromCategory(categoryData, sorted)
		local collectiblesData = {}

		local searchResults = COLLECTIONS_BOOK_SINGLETON:GetSearchResults()
		local searchResultsSubcategory = nil
		if searchResults then
			local categoryIndex, subcategoryIndex = categoryData:GetCategoryIndicies()
			local categoryResults = searchResults[categoryIndex]
			if categoryResults then
				local effectiveSubcategoryIndex = subcategoryIndex or ZO_COLLECTIONS_SEARCH_ROOT
				searchResultsSubcategory = categoryResults[effectiveSubcategoryIndex]
			end
		end
		
		local iterator = sorted and ZO_CollectibleCategoryData.SortedCollectibleIterator or ZO_CollectibleCategoryData.CollectibleIterator
		for _, collectibleData in iterator(categoryData, {ZO_CollectibleData.IsFavoriteCategory}) do
			if not searchResultsSubcategory or searchResultsSubcategory[collectibleData:GetIndex()] then
				table.insert(collectiblesData, collectibleData)
			end
		end

		return collectiblesData
	end

	SecurePostHook(COLLECTIONS_BOOK, 'BuildContentList', function(self, categoryData)
		categoryData.specializedSortedCollectibles:HandleUserFlagsChanged()
		categoryData.specializedSortedCollectibles:RefreshSort()
			
	--	categoryData:RefreshSort()
		if not categoryData:IsFavoritesCategory() then return end
		local function setDefaults(gridListPanelList, collectibleCategoryTypesInCategory)
			local randomMountEntryData = self.entryDataObjectPool:AcquireObject()
			local setRandomFavoriteMountData = ZO_RandomMountCollectibleData:New(RANDOM_MOUNT_TYPE_FAVORITE)
			randomMountEntryData:SetDataSource(setRandomFavoriteMountData)
			randomMountEntryData.gridHeaderTemplate = ZO_GRID_SCROLL_LIST_DEFAULT_HEADER_TEMPLATE_KEYBOARD
			randomMountEntryData.gridHeaderName = ""
			gridListPanelList:AddEntry(randomMountEntryData, "ZO_CollectibleImitationTile_Keyboard_Control")

			randomMountEntryData = self.entryDataObjectPool:AcquireObject()
			local setAnyRandomMountData = ZO_RandomMountCollectibleData:New(RANDOM_MOUNT_TYPE_ANY)
			randomMountEntryData:SetDataSource(setAnyRandomMountData)
			randomMountEntryData.gridHeaderTemplate = ZO_GRID_SCROLL_LIST_DEFAULT_HEADER_TEMPLATE_KEYBOARD
			randomMountEntryData.gridHeaderName = ""
			gridListPanelList:AddEntry(randomMountEntryData, "ZO_CollectibleImitationTile_Keyboard_Control")
		end
		
		if categoryData then
			
			local SORTED = true
			local collectiblesData = GetCollectiblesDataFromCategory(categoryData, SORTED)
			buildContentList(self, categoryData, collectiblesData, setDefaults)
		end
	end)
	
	SecurePostHook(COLLECTIONS_BOOK, 'OnDeferredInitialize', function(self)
		function self:GetCurrentCategoryData()
			return getCurrentCategoryData(self)
		end
	end)
end

local function initializeCollectibles_Companion()
	local function GetCollectiblesDataFromCategory(categoryData, sorted)
		local collectiblesData = {}

		local searchResults = COLLECTIONS_BOOK_SINGLETON:GetSearchResults()
		local searchResultsSubcategory = nil
		if searchResults then
			local categoryIndex, subcategoryIndex = categoryData:GetCategoryIndicies()
			local categoryResults = searchResults[categoryIndex]
			if categoryResults then
				local effectiveSubcategoryIndex = subcategoryIndex or ZO_COLLECTIONS_SEARCH_ROOT
				searchResultsSubcategory = categoryResults[effectiveSubcategoryIndex]
			end
		end

		local iterator = sorted and ZO_CollectibleCategoryData.SortedCollectibleIterator or ZO_CollectibleCategoryData.CollectibleIterator
		for _, collectibleData in iterator(categoryData, {ZO_CollectibleData.IsFavoriteCategory}) do
			if (not searchResultsSubcategory or searchResultsSubcategory[collectibleData:GetIndex()]) and collectibleData:IsCollectibleCategoryCompanionUsable() then
				table.insert(collectiblesData, collectibleData)
			end
		end

		return collectiblesData
	end

	SecurePostHook(COMPANION_COLLECTION_BOOK_KEYBOARD, 'BuildContentList', function(self, categoryData)
		if not categoryData:IsFavoritesCategory() then return end
		local imitationTilesProcessed = false
		local function setDefaults(gridListPanelList, collectibleCategoryTypesInCategory)
              if not imitationTilesProcessed then
				for categoryType in pairs(collectibleCategoryTypesInCategory) do
					local setToDefaultCollectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetSetToDefaultCollectibleData(categoryType, GAMEPLAY_ACTOR_CATEGORY_COMPANION)
					if setToDefaultCollectibleData then
						local defaultEntryData = self.entryDataObjectPool:AcquireObject()
						defaultEntryData:SetDataSource(setToDefaultCollectibleData)
						defaultEntryData.gridHeaderTemplate = ZO_GRID_SCROLL_LIST_DEFAULT_HEADER_TEMPLATE_KEYBOARD
						defaultEntryData.gridHeaderName = ""
						gridListPanelList:AddEntry(defaultEntryData, "ZO_CollectibleImitationTile_Keyboard_Control")
					end
				end

				if collectibleCategoryTypesInCategory[COLLECTIBLE_CATEGORY_TYPE_MOUNT] then
					local randomMountEntryData = self.entryDataObjectPool:AcquireObject()
					local setAnyRandomMountData = ZO_RandomMountCollectibleData:New(RANDOM_MOUNT_TYPE_ANY)
					randomMountEntryData:SetDataSource(setAnyRandomMountData)
					randomMountEntryData.gridHeaderTemplate = ZO_GRID_SCROLL_LIST_DEFAULT_HEADER_TEMPLATE_KEYBOARD
					randomMountEntryData.gridHeaderName = ""
					gridListPanelList:AddEntry(randomMountEntryData, "ZO_CollectibleImitationTile_Keyboard_Control")
				end

				imitationTilesProcessed = true
			end
		end

		if categoryData then
			local SORTED = true
			local collectiblesData = GetCollectiblesDataFromCategory(categoryData, SORTED)
			
			buildContentList(self, categoryData, collectiblesData, setDefaults)
		end
	--	ZO_COLLECTIBLE_DATA_MANAGER:OnCollectionUpdated()
    end)

	SecurePostHook(COMPANION_COLLECTION_BOOK_KEYBOARD, 'OnDeferredInitialize', function(self)
		function self:GetCurrentCategoryData()
			return getCurrentCategoryData(self)
		end
	end)
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------

function IJA_FavoriteCollectibles:InitializeCollectibles_KB()
	SELECTED_DATA = self.selectedData
	
	initializeCollectibles_Character()
	initializeCollectibles_Companion()

	-- Must run to refresh the collection when changing tabs. Favorites subcategories would show all in category
	-- when changing from Outfit Styles to Collectibles if was last in a Favorites subcategory.
    COLLECTIONS_BOOK.scene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
			COLLECTIONS_BOOK:UpdateCollectionLater()
        end
    end)
	
--	HOUSING_BOOK_KEYBOARD:RefreshListInternal()
	
	local function getSystemObject()
		if COLLECTIONS_BOOK.scene:IsShowing() then
			return COLLECTIONS_BOOK
		elseif COMPANION_COLLECTION_BOOK_KEYBOARD.scene:IsShowing() then
			return COMPANION_COLLECTION_BOOK_KEYBOARD
		end
	end
	
	-- force refresh on collectible when used so the keyboard active collectible is properly marked in the Favorites categories
	-- otherwise, "using" (set active) the collectible only refreshes it in it's original category.
	local function useCollectiblesHook(collectibleData, actorCategory)
		if IsInGamepadPreferredMode() then
			-- not needed in gamepad mode
		else
			local object = getSystemObject()
			local currentCategoryData = object:GetCurrentCategoryData()
			
			if currentCategoryData then
				-- only run loop on Favorite subcategories
				if currentCategoryData:IsFavoritesCategory() then
					EVENT_MANAGER:UnregisterForUpdate("IJA_UpdateCollectionLater")
					local function updateCollectionLater()
						EVENT_MANAGER:UnregisterForUpdate("IJA_UpdateCollectionLater")
						object:UpdateCollectionLater()
					end
					-- Update it on delay so the system has enough time to set the collectible as active
					EVENT_MANAGER:RegisterForUpdate("IJA_UpdateCollectionLater", 200, updateCollectionLater)
				end
			end
		end
	end
	
	SecurePostHook(ZO_CollectibleData, "Use", useCollectiblesHook)
end

---------------------------------------------------------------------------------------------------------------
-- Keyboard Housing Book
---------------------------------------------------------------------------------------------------------------
do
	SecurePostHook(HOUSING_BOOK_KEYBOARD, 'OnDeferredInitialize', function(self)
		function self:OnSceneShown()
			self.refreshGroups:UpdateRefreshGroups()
		end
		
		function self.categoryLayoutObject:ResetCategoryLists()
			self.favoritesList = {}
			self.unlockedList = {}
			self.lockedList = {}

			self.categorizedLists = {
				{
					name = GetString(SI_IJA_FC_FAVES),
					normalIcon = "/esoui/art/treeicons/achievements_indexicon_champion_up.dds",
					pressedIcon = "/esoui/art/treeicons/achievements_indexicon_champion_down.dds",
					mouseoverIcon = "/esoui/art/treeicons/achievements_indexicon_champion_over.dds",
					collectibles = self.favoritesList,
				},
				{
					name = GetString("SI_COLLECTIBLEUNLOCKSTATE", COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED),
					normalIcon = "EsoUI/Art/Collections/collections_categoryIcon_unlocked_up.dds",
					pressedIcon = "EsoUI/Art/Collections/collections_categoryIcon_unlocked_down.dds",
					mouseoverIcon = "EsoUI/Art/Collections/collections_categoryIcon_unlocked_over.dds",
					collectibles = self.unlockedList,
				},
				{
					name = GetString("SI_COLLECTIBLEUNLOCKSTATE", COLLECTIBLE_UNLOCK_STATE_LOCKED),
					normalIcon = "EsoUI/Art/Collections/collections_categoryIcon_locked_up.dds",
					pressedIcon = "EsoUI/Art/Collections/collections_categoryIcon_locked_down.dds",
					mouseoverIcon = "EsoUI/Art/Collections/collections_categoryIcon_locked_over.dds",
					collectibles = self.lockedList,
				}
			}

			ZO_ClearNumericallyIndexedTable(self.specializedSortedCollectibles)
			self:BuildData()
		end
		--	/script HOUSING_BOOK_KEYBOARD.categoryLayoutObject:RefreshCategorizedLists()
		function self.categoryLayoutObject:RefreshCategorizedLists()
			local unlockedList = self.unlockedList
			local lockedList = self.lockedList
			local favoritesList =  self.favoritesList
			ZO_ClearNumericallyIndexedTable(unlockedList)
			ZO_ClearNumericallyIndexedTable(lockedList)
			ZO_ClearNumericallyIndexedTable(favoritesList)
			
			local relevantCollectibles = self.specializedSortedCollectibles:GetCollectibles()
			
			local added = {}
			for _, collectibleData in ipairs(relevantCollectibles) do
				if not added[collectibleData:GetId()] then
					added[collectibleData:GetId()] = true
					
					if collectibleData:IsFavorite() then
						table.insert(favoritesList, collectibleData)
					elseif collectibleData:IsUnlocked() then
						table.insert(unlockedList, collectibleData)
					else
						table.insert(lockedList, collectibleData)
					end
				end
			end
		end
		
		-- Could just add funcion instead of hook it.
		SecurePostHook(HOUSING_BOOK_KEYBOARD, 'TreeEntry_OnMouseUp', function(self, control, upInside, button)
			if button == MOUSE_BUTTON_INDEX_LEFT and upInside then
				self:RequestJumpToCurrentHouse()
			end
		end)
		
		self.categoryLayoutObject:ResetCategoryLists()
		self:RefreshList()
	end)
end
