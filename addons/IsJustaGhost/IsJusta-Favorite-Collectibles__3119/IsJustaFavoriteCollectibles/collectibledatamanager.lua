-- collectibledatamanager
local IJA_FavoriteCollectibles = IJA_FAVORITECOLLECTIBLES
local _perCharacter = false
local _favorites = {}
local _savedVars = {}

local VAR_COLLECTIBLE_CATEGORY_SPECIALIZATION_FAVORITES = COLLECTIBLE_CATEGORY_SPECIALIZATION_MAX_VALUE + 1
COLLECTIBLE_CATEGORY_SPECIALIZATION_MAX_VALUE = VAR_COLLECTIBLE_CATEGORY_SPECIALIZATION_FAVORITES

local function getSortSubcategoryIndicies(left, right)
	local leftSubcategoryIndex 	= select(2, left:GetCategoryData():GetCategoryIndicies()) or 0
	local rightSubcategoryIndex = select(2, right:GetCategoryData():GetCategoryIndicies()) or 0
	return leftSubcategoryIndex, rightSubcategoryIndex
end


local function getSortSubcategoryNames(left, right)
	local leftSubcategoryName = left:GetCategoryData():GetFormattedName() or ''
	local rightSubcategoryName = right:GetCategoryData():GetFormattedName() or ''
	return leftSubcategoryName, rightSubcategoryName
end

---------------------------------------------------------------------------------------------------------------
-- Added ZO_Collectible* functions
---------------------------------------------------------------------------------------------------------------
function ZO_CollectibleCategoryData:GetBestCollectibleHeader(collectibleData)
	if collectibleData:IsFavorite() then
		return GetString(SI_COLLECTIONS_FAVORITES_CATEGORY_HEADER)
	else
		local headerState = collectibleData:IsUnlocked() and COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED or COLLECTIBLE_UNLOCK_STATE_LOCKED
		return GetString("SI_COLLECTIBLEUNLOCKSTATE", headerState)
	end
end

function ZO_CollectibleCategoryData:IsFavoritesCategory()
	return self.categorySpecialization == VAR_COLLECTIBLE_CATEGORY_SPECIALIZATION_FAVORITES
end

-- Added to be able to refresh the sort order without rebuilding the collection
-- is this in use anymore?
function ZO_CollectibleCategoryData:RefreshSort()
	self.specializedSortedCollectibles.dirty = true
	self.specializedSortedCollectibles:RefreshSort()
end

function ZO_CollectibleCategoryData:IsValidForCategory(collectibleData)
	return true
end

--[[ZO_DefaultSortedCollectibles

]]
-- Force refresh sort.
local org_ZO_DefaultSortedCollectibles_GetCollectibles = ZO_DefaultSortedCollectibles.GetCollectibles
function ZO_DefaultSortedCollectibles:GetCollectibles()
	self.dirty = true

    return org_ZO_DefaultSortedCollectibles_GetCollectibles(self)
end

local org_SpecializedSortedCollectibles_GetCollectibles = ZO_SpecializedSortedCollectibles.GetCollectibles
function ZO_SpecializedSortedCollectibles:GetCollectibles()
	self.dirty = true
    return org_SpecializedSortedCollectibles_GetCollectibles(self)
end

---------------------------------------------------------------------------------------------------------------
-- Modified ZO_Collectible* functions
---------------------------------------------------------------------------------------------------------------
-- Modified to use the stored subcategoryIndex instead of the table index. Since I insert the Favorites
-- subcategory into index 1, the table indexes will all be off by 1. Returning the wrong subcategoryData, including nil.
function ZO_CollectibleCategoryData:GetSubcategoryData(subcategoryIndex)
	if self.isTopLevelCategory then
		for _, subcategoryData in ipairs(self.orderedSubcategories) do
			if subcategoryData.subcategoryIndex == subcategoryIndex then
				return subcategoryData
			end
		end
	end
	return nil
end
--[[ original
function ZO_CollectibleCategoryData:GetSubcategoryData(subcategoryIndex)
	if self.isTopLevelCategory then
		return self.orderedSubcategories[subcategoryIndex]
	end
	return nil
end
]]

-- Modified to prevent duplicate collectibles from appearing in keyboard quickslot inventory lists
-- This is needed for categories with a "Favorites" subcategory, to prevent those items from being listed.
function ZO_CollectibleCategoryData:AppendAllCollectibleDataObjects(foundCollectibleDataObjects, collectibleFilterFunctions, sorted)
	local iterator = sorted and ZO_CollectibleCategoryData.SortedCollectibleIterator or ZO_CollectibleCategoryData.CollectibleIterator

	for _, collectibleData in iterator(self, collectibleFilterFunctions) do
		table.insert(foundCollectibleDataObjects, collectibleData)
	end

	if self.isTopLevelCategory then
		for _, subcategoryData in ipairs(self.orderedSubcategories) do
			if KEYBOARD_QUICKSLOT_FRAGMENT:IsShowing() then
				if subcategoryData:IsStandardCategory() then
					subcategoryData:AppendAllCollectibleDataObjects(foundCollectibleDataObjects, collectibleFilterFunctions, sorted)
				end
			else
				subcategoryData:AppendAllCollectibleDataObjects(foundCollectibleDataObjects, collectibleFilterFunctions, sorted)
			end
		end
	end

	return foundCollectibleDataObjects
end
--[[ original
function ZO_CollectibleCategoryData:AppendAllCollectibleDataObjects(foundCollectibleDataObjects, collectibleFilterFunctions, sorted)
	local iterator = sorted and ZO_CollectibleCategoryData.SortedCollectibleIterator or ZO_CollectibleCategoryData.CollectibleIterator

	for _, collectibleData in iterator(self, collectibleFilterFunctions) do
		table.insert(foundCollectibleDataObjects, collectibleData)
	end

	if self.isTopLevelCategory then
		for _, subcategoryData in ipairs(self.orderedSubcategories) do
			subcategoryData:AppendAllCollectibleDataObjects(foundCollectibleDataObjects, collectibleFilterFunctions, sorted)
		end
	end

	return foundCollectibleDataObjects
end
]]

-- Modified to prevent Favorites subcategories from being shown when empty
function ZO_CollectibleCategoryData:HasShownCollectiblesInCollection()
	if self:IsFavoritesCategory() then
		return self:HasShownCollectiblesInCollection()
	else
		for _, collectibleData in ipairs(self.orderedCollectibles) do
			if not collectibleData:IsHiddenFromCollection(self) then
				return true
			end
		end
	end

	if self.isTopLevelCategory then
		for _, subcategoryData in ipairs(self.orderedSubcategories) do
			if subcategoryData:HasShownCollectiblesInCollection() then
				return true
			end
		end
	end

	return false
end
--[[ original
function ZO_CollectibleCategoryData:HasShownCollectiblesInCollection()
	for _, collectibleData in ipairs(self.orderedCollectibles) do
		if not collectibleData:IsHiddenFromCollection(self) then
			return true
		end
	end

	if self.isTopLevelCategory then
		for _, subcategoryData in ipairs(self.orderedSubcategories) do
			if subcategoryData:HasShownCollectiblesInCollection() then
				return true
			end
		end
	end

	return false
end
]]

---------------------------------------------------------------------------------------------------------------
-- Favorite subcategory
---------------------------------------------------------------------------------------------------------------
local FavoritesCategoryData = ZO_CollectibleCategoryData:Subclass()

function FavoritesCategoryData:BuildData(categoryIndex, subcategoryIndex, info)
	self.categoryIndex, self.subcategoryIndex = categoryIndex, subcategoryIndex
	self.categoryId = - GetCollectibleCategoryId(categoryIndex)

	self.name = GetString(SI_IJA_FC_FAVES)
	self.numSubcategories = 0
	self.isTopLevelCategory = false
	self.noIcon = true
	
	self.categorySpecialization = VAR_COLLECTIBLE_CATEGORY_SPECIALIZATION_FAVORITES
	self.specializedSortedCollectibles = self:CreateSpecializedSortedCollectiblesTable()

	-- add all collectibles from all Subcategories
	self.orderedCollectibles = self:GetAllCollectibleDataObjects(info.categoryFilterFunctions, info.collectibleFilterFunctions, sorted)
	
	for k, collectibleData in pairs(self.orderedCollectibles) do
		self.specializedSortedCollectibles:InsertCollectible(collectibleData)
	end
	self.specializedSortedCollectibles:OnInsertFinished()

	ZO_COLLECTIBLE_DATA_MANAGER:MapCategoryData(self)
end

-- Using a custom CategoryIterator that does not reset the collection. 
-- Doing so would undo previously added Favorites subcategories.
function FavoritesCategoryData:CategoryIterator(categoryFilterFunctions)
--	self:CleanCollection()
	-- This only works because we use the categoryObjectPool like a numerically indexed table
	return ZO_FilteredNumericallyIndexedTableIterator(ZO_COLLECTIBLE_DATA_MANAGER.categoryObjectPool:GetActiveObjects(), categoryFilterFunctions)
end

function FavoritesCategoryData:GetAllCollectibleDataObjects(categoryFilterFunctions, collectibleFilterFunctions, sorted)
	local foundCollectibleDataObjects = {}
	for _, categoryData in self:CategoryIterator(categoryFilterFunctions) do
		categoryData:AppendAllCollectibleDataObjects(foundCollectibleDataObjects, collectibleFilterFunctions, sorted)
	end
	return foundCollectibleDataObjects
end

function FavoritesCategoryData:HasAnyUnlockedCollectibles()
	for _, collectibleData in ipairs(self.orderedCollectibles) do
		if collectibleData:IsUnlocked() and collectibleData:IsFavorite() then
			return true
		end
	end
	return false
end

function FavoritesCategoryData:HasShownCollectiblesInCollection()
	for _, collectibleData in ipairs(self.orderedCollectibles) do
		if collectibleData:IsFavorite() and collectibleData:IsShownInCollection() then
			return true
		end
	end
	return false
end

function FavoritesCategoryData:HasAnyCompanionUsableCollectibles()
	for _, collectibleData in ipairs(self.orderedCollectibles) do
		if collectibleData:IsCollectibleCategoryCompanionUsable() and collectibleData:IsCollectibleAvailableToCompanion() then
			return true
		end
	end
	return false
end

do
	-- TODO: determine if i want to keep this as it is to allow randomizers to be put in favorites
	function FavoritesCategoryData:GetCollectibleFilters()
		return {ZO_CollectibleData.IsFavoriteCategory}
	end

	function FavoritesCategoryData:IsValidForCategory(collectibleData)
		if _savedVars.filterInvalid and not collectibleData:IsValidForPlayer() then
			return false
		end

		return collectibleData:IsFavoriteCategory()
	end
end

function FavoritesCategoryData:GetName()
	return GetString(SI_IJA_FC_FAVES)
end

function FavoritesCategoryData:GetBestCollectibleHeader(collectibleData)
	if collectibleData:IsPrimaryResidence() then
		return GetString(SI_HOUSING_PRIMARY_RESIDENCE_HEADER)
	elseif _savedVars.sort ~= 0 then
		return GetCollectibleCategoryNameByCategoryId(collectibleData:GetCategoryData():GetId())
	else
		local headerState = collectibleData:IsUnlocked() and COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED or COLLECTIBLE_UNLOCK_STATE_LOCKED
	--	return GetString("SI_COLLECTIBLEUNLOCKSTATE", headerState)
		return GetString(SI_COLLECTIONS_FAVORITES_CATEGORY_HEADER)
	end
end

---------------------------------------------------------------------------------------------------------------
-- Custom specilized sorted collectibles for custom sorting of the Favorits subcategories
---------------------------------------------------------------------------------------------------------------
local function defaultSort(collectibleNameLookupTable, left, right)
	local leftSortOrder = left:GetSortOrder()
	local rightSortOrder = right:GetSortOrder()
	if leftSortOrder ~= rightSortOrder then
		return leftSortOrder < rightSortOrder
	end

	local leftIsValidForPlayer = left:IsValidForPlayer()
	local rightIsValidForPlayer = right:IsValidForPlayer()
	if leftIsValidForPlayer ~= rightIsValidForPlayer then
		return leftIsValidForPlayer
	else
		return collectibleNameLookupTable[left:GetId()] < collectibleNameLookupTable[right:GetId()]
	end
end

local SpecializedSortedFavoritesByName = ZO_DefaultSortedCollectibles:Subclass()

function SpecializedSortedFavoritesByName:RefreshSort()
	if self.dirty then
		local collectibleNameLookupTable = self.collectibleNameLookupTable
		table.sort(self.sortedCollectibles, function(left, right)
			local leftIsPrimaryResidence = left:IsPrimaryResidence()
			local rightIsPrimaryResidence = right:IsPrimaryResidence()
			if leftIsPrimaryResidence ~= rightIsPrimaryResidence then
				return leftIsPrimaryResidence
			end
			
			local leftIsUnlocked = left:IsUnlocked()
			local rightIsUnlocked = right:IsUnlocked()
			if leftIsUnlocked ~= rightIsUnlocked then
				return leftIsUnlocked
			end

			return defaultSort(collectibleNameLookupTable, left, right)
		end)
	end

	self.dirty = false
end

local SpecializedSortedFavoritesByCategoryByIndex = ZO_DefaultSortedCollectibles:Subclass()

function SpecializedSortedFavoritesByCategoryByIndex:RefreshSort()
	if self.dirty then
		local collectibleNameLookupTable = self.collectibleNameLookupTable
		table.sort(self.sortedCollectibles, function(left, right)
			local leftIsPrimaryResidence = left:IsPrimaryResidence()
			local rightIsPrimaryResidence = right:IsPrimaryResidence()
			if leftIsPrimaryResidence ~= rightIsPrimaryResidence then
				return leftIsPrimaryResidence
			end
			
			
			local leftIsUnlocked = left:IsUnlocked()
			local rightIsUnlocked = right:IsUnlocked()
			if leftIsUnlocked ~= rightIsUnlocked then
				return leftIsUnlocked
			end
			
			local leftSubcategoryIndex, rightSubcategoryIndex = getSortSubcategoryIndicies(left, right)
			if leftSubcategoryIndex ~= rightSubcategoryIndex then
				return leftSubcategoryIndex < rightSubcategoryIndex
			end
			
			return defaultSort(collectibleNameLookupTable, left, right)
		end)
	end

	self.dirty = false
end

local SpecializedSortedFavoritesByCategoryByName = ZO_DefaultSortedCollectibles:Subclass()

function SpecializedSortedFavoritesByCategoryByName:RefreshSort()
	if self.dirty then
		local collectibleNameLookupTable = self.collectibleNameLookupTable
		table.sort(self.sortedCollectibles, function(left, right)
			local leftIsPrimaryResidence = left:IsPrimaryResidence()
			local rightIsPrimaryResidence = right:IsPrimaryResidence()
			if leftIsPrimaryResidence ~= rightIsPrimaryResidence then
				return leftIsPrimaryResidence
			end
			
			
			local leftIsUnlocked = left:IsUnlocked()
			local rightIsUnlocked = right:IsUnlocked()
			if leftIsUnlocked ~= rightIsUnlocked then
				return leftIsUnlocked
			end
			
			local leftSubcategoryName, rightSubcategoryName = getSortSubcategoryNames(left, right)
			if leftSubcategoryName ~= rightSubcategoryName then
				return leftSubcategoryName < rightSubcategoryName
			end

			return defaultSort(collectibleNameLookupTable, left, right)
		end)
	end

	self.dirty = false
end

function FavoritesCategoryData:CreateSpecializedSortedCollectiblesTable()
	if _savedVars.sort == 2 then
		return SpecializedSortedFavoritesByCategoryByIndex:New()
	elseif _savedVars.sort == 1 then
		return SpecializedSortedFavoritesByCategoryByName:New()
	else
		return SpecializedSortedFavoritesByName:New()
	end
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
IJA_FavoriteCollectibles.subcategoryObjectPool = ZO_ObjectPool:New(FavoritesCategoryData, ZO_ObjectPool_DefaultResetObject)

function IJA_FavoriteCollectibles:SetCollectibleDataManagerVariables()
	_savedVars = self.savedVars
--	_perCharacter = not self.savedVars.accountWide
	_favorites = self.favorites
--	ZO_COLLECTIBLE_DATA_MANAGER:RebuildCollection()
end

---------------------------------------------------------------------------------------------------------------
-- Added or modified to facilitate the use of per-character favorites
---------------------------------------------------------------------------------------------------------------
ZO_PreHook('SetOrClearCollectibleUserFlag', function(collectibleId, userFlag, isFavorite)
	if userFlag == COLLECTIBLE_USER_FLAG_FAVORITE then
		_favorites[collectibleId] = isFavorite or nil

		local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
		if not collectibleData:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_MOUNT) then
			-- We need to refresh the sort order on every change to prevent out of sorting.
			local categoryData = collectibleData:GetCategoryData()
			if categoryData then
				local specializedSortedCollectibles = categoryData:GetSpecializedSortedCollectiblesObject()
				specializedSortedCollectibles:HandleUserFlagsChanged(ZO_COLLECTIBLE_DATA_MANAGER)
			end
			
			ZO_COLLECTIBLE_DATA_MANAGER:FireCallbacks("OnCollectibleUserFlagsUpdated", collectibleId)
			if isFavorite then
				-- If we set it as favorite then stop here. Otherwise lets make sure it does not have the userflag set.
				return true
			end
		end
	end
end)

-- Allows for having more than 100 favorites.
function ZO_CollectibleData:IsFavorite()
	if self:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_MOUNT) then
		return self:IsUserFlagSet(COLLECTIBLE_USER_FLAG_FAVORITE)
	elseif self:IsFavoritable() then
		-- Only handle favoritale collectibles.
		return _favorites[self:GetId()]
	end
end

-- added
-- The filter for favorites category
function ZO_CollectibleData:IsFavoriteCategory()
	-- To allow for IsJustaColectibleRandomizer, we add self:GetId() < 0
	return self:IsShownInCollection() and (self:IsFavorite() or self:GetId() < 0)
end

--[[
function ZO_CollectibleCategoryData:IsMountCategory()
	self:GetCollectibleCategoryTypesInCategory()
	return self.collectibleCategoryTypesInCategory[COLLECTIBLE_CATEGORY_TYPE_MOUNT] or false
end

function ZO_CollectibleDataManager:HasAnyFavoriteMounts()
	for _, categoryData in self:CategoryIterator( { ZO_CollectibleCategoryData.IsMountCategory } ) do
		if categoryData:HasAnyFavoriteMounts() then
			return true
		end
	end
	return false
end

function ZO_CollectibleCategoryData:HasAnyFavoriteMounts()
	for _, collectibleData in ipairs(self.orderedCollectibles) do
		if collectibleData:IsUnlocked() and collectibleData:IsFavorite() then
			return true
		end
	end

	if self.isTopLevelCategory then
		for _, subcategoryData in ipairs(self.orderedSubcategories) do
		--	if subcategoryData:HasAnyUnlockedCollectibles() then
			if subcategoryData:HasAnyFavoriteMounts() then
				return true
			end
		end
	end

	return false
end
]]
--[[ 
function ZO_CollectibleDataManager:HasAnyFavoriteMounts()
	return DoesCollectibleCategoryContainAnyCollectiblesWithUserFlags(COLLECTIBLE_CATEGORY_TYPE_MOUNT, COLLECTIBLE_USER_FLAG_FAVORITE)
end
]]





