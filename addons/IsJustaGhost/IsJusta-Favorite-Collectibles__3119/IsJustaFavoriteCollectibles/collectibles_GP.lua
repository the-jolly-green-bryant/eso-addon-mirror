local IJA_FavoriteCollectibles = IJA_FAVORITECOLLECTIBLES
---------------------------------------------------------------------------------------------------------------
--
---------------------------------------------------------------------------------------------------------------
local function buildCollectionList(self, categoryData, resetSelectionToTop, setDefaults, template)
    local collectionListInfo = self.collectionList
    local collectionList = collectionListInfo.list

    collectionListInfo.titleText = nil

	local usedHeadres = {}
    self.updateList = {}

	if IJA_COLLECTIBLERANDOMIZER then
		IJA_COLLECTIBLERANDOMIZER.BuildRandomizers_Gamepad(self, categoryData, template)
	else
		ZO_ParametricScrollList.Clear(self.collectionList.list)
	end
	local collectibleCategoryTypesInCategory = categoryData:GetCollectibleCategoryTypesInCategory()
	
	local defaultTilesProcessed = false
	if not defaultTilesProcessed then
		setDefaults(collectionList, collectibleCategoryTypesInCategory)
		defaultTilesProcessed = true
	end

	local collectibleFilters = categoryData:GetCollectibleFilters()
    for _, collectibleData in categoryData:SortedCollectibleIterator({ZO_CollectibleData.IsFavoriteCategory}) do
 --   for _, collectibleData in categoryData:SortedCollectibleIterator(collectibleFilters) do
        local entryData = self:BuildCollectibleData(collectibleData)
		
		if categoryData:IsValidForCategory(collectibleData) then
			local headerName = categoryData:GetBestCollectibleHeader(collectibleData)
			
			if not usedHeadres[headerName] then
				usedHeadres[headerName] = true
				entryData:SetHeader(headerName)
				collectionList:AddEntryWithHeader(template, entryData)	
			else
				collectionList:AddEntry(template, entryData)
			end
			
			if collectibleData:IsUnlocked() then
				table.insert(self.updateList, entryData)
			end
		end
    end

    collectionList:Commit(resetSelectionToTop)

    KEYBIND_STRIP:UpdateKeybindButtonGroup(collectionListInfo.keybind)

    self.currentCategoryData = categoryData
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
local function initializeCollectibles_Character()
	GAMEPAD_COLLECTIONS_BOOK.entryTemplate = "ZO_GamepadCollectibleEntryTemplate"
	
	SecurePostHook(GAMEPAD_COLLECTIONS_BOOK, 'BuildCollectionList', function(self, categoryData)
		if not categoryData:IsFavoritesCategory() then return end

		local function setDefaults(collectionList, collectibleCategoryTypesInCategory)
			if collectibleCategoryTypesInCategory[COLLECTIBLE_CATEGORY_TYPE_MOUNT] then
				local setRandomFavoriteMountData = ZO_RandomMountCollectibleData:New(RANDOM_MOUNT_TYPE_FAVORITE)
				local randomFavoriteMountEntryData = self:BuildCollectibleCategorySetRandomSelectionData(setRandomFavoriteMountData)
				ZO_UpdateCollectibleEntryDataIconVisuals(randomFavoriteMountEntryData, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
				collectionList:AddEntry("ZO_GamepadCollectibleEntryTemplate", randomFavoriteMountEntryData)

				local setRandomMountData = ZO_RandomMountCollectibleData:New(RANDOM_MOUNT_TYPE_ANY)
				local randomMountEntryData = self:BuildCollectibleCategorySetRandomSelectionData(setRandomMountData)
				ZO_UpdateCollectibleEntryDataIconVisuals(randomMountEntryData, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
				collectionList:AddEntry("ZO_GamepadCollectibleEntryTemplate", randomMountEntryData)
			end
		end

		buildCollectionList(self, categoryData, resetSelectionToTop, setDefaults, "ZO_GamepadCollectibleEntryTemplate")
	end)
end

local function initializeCollectibles_Companion()
	COMPANION_COLLECTION_BOOK_GAMEPAD.entryTemplate = "ZO_GamepadCompanionCollectible"
	
	SecurePostHook(COMPANION_COLLECTION_BOOK_GAMEPAD, 'BuildCollectionList', function(self, categoryData)
		if not categoryData:IsFavoritesCategory() then return end
		
		local function setDefaults(collectionList, collectibleCategoryTypesInCategory)
			for categoryType in pairs(collectibleCategoryTypesInCategory) do
				local setToDefaultCollectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetSetToDefaultCollectibleData(categoryType, GAMEPLAY_ACTOR_CATEGORY_COMPANION)
				if setToDefaultCollectibleData then
					local defaultEntryData = self:BuildCollectibleCategorySetToDefaultData(setToDefaultCollectibleData)
					collectionList:AddEntry("ZO_GamepadCompanionCollectible", defaultEntryData)
				end
			end
			
			if collectibleCategoryTypesInCategory[COLLECTIBLE_CATEGORY_TYPE_MOUNT] then
				local setRandomMountData = ZO_RandomMountCollectibleData:New(RANDOM_MOUNT_TYPE_ANY)
				local randomMountEntryData = self:BuildCollectibleCategorySetRandomSelectionData(setRandomMountData)
				ZO_UpdateCollectibleEntryDataIconVisuals(randomMountEntryData, GAMEPLAY_ACTOR_CATEGORY_COMPANION)
				collectionList:AddEntry("ZO_GamepadCompanionCollectible", randomMountEntryData)
			end
		end
		
		buildCollectionList(self, categoryData, resetSelectionToTop, setDefaults, 'ZO_GamepadCompanionCollectible')
	end)
end

function IJA_FavoriteCollectibles:InitializeCollectibles_GP()
	initializeCollectibles_Character()
	initializeCollectibles_Companion()
end

function GAMEPAD_COLLECTIONS_BOOK:GetCurrentCategoryData()
    return self.currentCategoryData
end

function COMPANION_COLLECTION_BOOK_GAMEPAD:GetCurrentCategoryData()
    return self.currentCategoryData
end
