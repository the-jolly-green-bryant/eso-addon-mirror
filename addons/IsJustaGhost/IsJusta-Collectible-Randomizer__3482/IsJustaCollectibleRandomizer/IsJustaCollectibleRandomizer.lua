
--[[

- - - 2.1.4
○ removed debug text

- - - 2.1.3
○ Active collectible now added to the left of the randomizers in keyboard mode
- right-click browse to real collectible category and location

- - - 2.1.2
○ Active collectible now added to the left of the randomizers in keyboard mode
- right-click browse to real collectible location
- top of category list in gamepad mode
○ improved Collectible not ready" alerts
○ fixed error "IsJustaCollectibleRandomizer.lua:548: attempt to index a nil value"
○ 

- - - 2.1.1
○ fixed error "IsJustaCollectibleRandomizer.lua:612: function expected instead of nil"

- - - 2.1
○ made some improvements on use. Now will delay fire if used to soon and,
-- will prevent most "Collectible not ready" alerts when used repeatedly
○ improved compatibility with IsJusta Favorite Collectibles
○ added the unequip collectible

- - - 2
○ completely rewrote it based off of the subclass used by random mounts.

- - - 1.2
○ fixed errors caused by zos renaming functions in collectibledatamanager.lua

- - -1.1.2
○ fixed icon from initially showing even if random mount is disabled.

- - -1.1.1
○ added icon to show if random mount is enabled

○ added keybind to toggle random mount on use

- - -1.0.3
○ fixed issues related to update 35

- - -1.0.2
○ fixed random mount selecting a non-favorite on load, if use favorites is enabled
○ "Random Mount" will now mount on delay if waiting to mount.
○ fixed random collectible not showing in mounts or non-combat pets
○ 


- - -1.0.1
○ removed time block on use. It was only suitable for randomMount
○ 


- - -1
○ Fixed: error Attempt to access a private function caused from loading in a player house.
○ Fixed: integration with IsJusta Favorite Collectibles


○ added randomizers to companion
- not based on settings.
○ 
○ 

]]

--[[
	on right-click
	if is in same category
		else open category
	move to item
	on double click
		unselect 
]]
---------------------------------------------------------------------------------------------------------------
-- locals
---------------------------------------------------------------------------------------------------------------
local addonInfo = {
	displayName = "|cFF00FFIsJusta|r |cffffffCollectible Randomizer|r",
	name = "IsJustaCollectibleRandomizer",
	version = "2.1.4",
}
-- addonInfo.name
local defaults = {
	useRandom = {},
	randomFavorite = {}
}

local svVersion = 1

local RANDOM_COLLECTIBLE_TYPE_NONE = 0
local RANDOM_COLLECTIBLE_TYPE_FAVORITE = 1
local RANDOM_COLLECTIBLE_TYPE_ANY = 2

local VAR_CATEGOY_ID_APPEARANCE	= 13
local VAR_CATEGOY_ID_MEMENTOS	= 5
local VAR_CATEGOY_ID_VANITY_PET	= 3

local activeUnequipCollectible
local optionalCategories = {
	[VAR_CATEGOY_ID_APPEARANCE]	= {},
	[VAR_CATEGOY_ID_MEMENTOS]	= {},
	[VAR_CATEGOY_ID_VANITY_PET]	= {},
}

do -- Build loalized names or optional categories to use in lam options
	for categoryId, category in pairs(optionalCategories) do
		-- Add names to each toplevel category in optionalCategories.
		category.name = GetCollectibleCategoryNameByCategoryId(categoryId)
		defaults.useRandom[categoryId] = true
	end
end

local function getLastCollectibleId()
	local lastId = 0
	
	for collectibleId , v in pairs(ZO_COLLECTIBLE_DATA_MANAGER.collectibleIdToDataMap) do
		if lastId < collectibleId then
			lastId = collectibleId
		end
	end
	return lastId
end
local lastZOCollectibleId = getLastCollectibleId()

local customColectibleId_To_ColectibleData_Map = {}
local function getCustomCollectibleIdFromRandomType(randomType)
	for collectibleId, collectibleData in pairs(customColectibleId_To_ColectibleData_Map) do
		if (collectibleData.GetRandomType and collectibleData:GetRandomType() == randomType) or randomType ~= nil then
			return collectibleId
		end
	end
	IJA_COLLECTIBLERANDOMIZER.customColectibleId_To_ColectibleData_Map = customColectibleId_To_ColectibleData_Map
end

-- Generate mapped orderedCollectibles by category ids. 
-- This is done so we can grab all collectibles for all subcategories in non-combat pets.
-- Generate mapped category types by category ids
categoryId_To_OrderedCollectibles_Map = {}
categoryId_To_CategoryType_Map = {}


local function onCollectionUpdated()
	categoryId_To_OrderedCollectibles_Map = {}
	for categoryId, categoryData in pairs(ZO_COLLECTIBLE_DATA_MANAGER.collectibleCategoryIdToDataMap) do
		if categoryData.isTopLevelCategory then
			local categoryId = categoryData:GetId()
			if optionalCategories[categoryId] then
				if categoryId == VAR_CATEGOY_ID_MEMENTOS then
					-- mementos
					categoryId_To_OrderedCollectibles_Map[categoryId] = categoryData.orderedCollectibles
					categoryId_To_CategoryType_Map[categoryId] = COLLECTIBLE_CATEGORY_TYPE_MEMENTO
				elseif categoryId == VAR_CATEGOY_ID_APPEARANCE then
					-- appearence
					for k, subCategoryData in pairs(categoryData.orderedSubcategories) do
						categoryId_To_OrderedCollectibles_Map[subCategoryData:GetId()] = subCategoryData.orderedCollectibles
						categoryId_To_CategoryType_Map[subCategoryData:GetId()] = subCategoryData.orderedCollectibles[1]:GetCategoryType()
					end
				elseif categoryId == VAR_CATEGOY_ID_VANITY_PET then
					-- non-combat pets
					local orderedCollectibles = {}
					local subcategoryIds = {}
					for k, subCategoryData in pairs(categoryData.orderedSubcategories) do
						for k, collectibleData in pairs(subCategoryData.orderedCollectibles) do
							table.insert(orderedCollectibles, collectibleData)
						end
						table.insert(subcategoryIds, subCategoryData:GetId())
					end
					for k, subcategoryId in pairs(subcategoryIds) do
						categoryId_To_OrderedCollectibles_Map[subcategoryId] = orderedCollectibles
						categoryId_To_CategoryType_Map[subcategoryId] = COLLECTIBLE_CATEGORY_TYPE_VANITY_PET
					end
					-- Favorites subcategories are a negative of their parent
					categoryId_To_OrderedCollectibles_Map[-categoryId] = orderedCollectibles
					categoryId_To_CategoryType_Map[-categoryId] = COLLECTIBLE_CATEGORY_TYPE_VANITY_PET
				end
			end
		end
	end
	
	if IJA_COLLECTIBLERANDOMIZER then
		IJA_COLLECTIBLERANDOMIZER.categoryId_To_OrderedCollectibles_Map = categoryId_To_OrderedCollectibles_Map
		IJA_COLLECTIBLERANDOMIZER.categoryId_To_CategoryType_Map = categoryId_To_CategoryType_Map
	end
end
onCollectionUpdated()
--ZO_COLLECTIBLE_DATA_MANAGER:RegisterCallback("OnCollectionUpdated", onCollectionUpdated)

local function getActiveSystemObject()
	local systemObject = SYSTEMS:GetObject('collectionsBook')
	if not systemObject.scene:IsShowing() then
		systemObject = SYSTEMS:GetObject('collectionsBookCompanion')
	end
	return systemObject
end

local function getActorCategory()
	local systemObject = getActiveSystemObject()
	return systemObject.actorCategory
end

local function isInHouse()
	return GetCurrentZoneHouseId() ~= 0
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------

local function getCurrentCategoryData(object)
	return object.categoryTree:GetSelectedData()
end

local function browseToCollectible(object, collectibleId, collectibleData)
--	d( 'browseToCollectible')
	
	object.refreshGroups:UpdateRefreshGroups() --In case we need to rebuild the categories before we select a category
	local currentCategoryData = object.categoryTree:GetSelectedData() or {}
			
	if COMPANION_KEYBOARD_FRAGMENT:IsShowing() then
	else
		if collectibleData then
	-- d( 'has collectible data')
			local categoryData = collectibleData:GetCategoryData()

			if currentCategoryData ~= categoryData then
				currentCategoryData = categoryData
			end
			
			if currentCategoryData then
	--	d( 'has category data')
					--Select the category or subcategory of the collectible
				local categoryNode = object.categoryNodeLookupData[currentCategoryData:GetId()]
				if categoryNode then
					-- d( 'has node')
					object.categoryTree:SelectNode(categoryNode)
				end
				
				local entryData = object:GetEntryByCollectibleId(collectibleId)
				if entryData then
					-- d( 'has entry data')
					local NO_CALLBACK = nil
					local ANIMATE_INSTANTLY = true
					object.gridListPanelList:ScrollDataToCenter(entryData, NO_CALLBACK, ANIMATE_INSTANTLY)
				else
					-- not working
					local categoryNode = object.categoryNodeLookupData[currentCategoryData:GetParentData():GetId()]
					if categoryNode then
						object.categoryTree:SelectNode(categoryNode)
					end
				end
			end
		end
	end
end

---------------------------------------------------------------------------------------------------------------
-- Random tile
---------------------------------------------------------------------------------------------------------------

-- 1.	full tooltip

local random_collectibleTile = ZO_CollectibleImitationTile_Keyboard:Subclass()

-- Tooltip
function random_collectibleTile:RefreshMouseoverVisuals()
	if self:IsMousedOver() then
		local description = self.imitationCollectibleData:GetDescription(self:GetActorCategory())
		if description then
			-- Tooltip
			ClearTooltip(InformationTooltip)
			local offsetX = self.control:GetParent():GetLeft() - self.control:GetLeft() - 5
			InitializeTooltip(InformationTooltip, self.control, RIGHT, offsetX, 0, LEFT)

			local DEFAULT_FONT = ""
			local r, g, b = ZO_NORMAL_TEXT:UnpackRGB()
			InformationTooltip:AddLine(self.imitationCollectibleData:GetName(), DEFAULT_FONT, r, g, b)
			
			ZO_Tooltip_AddDivider(InformationTooltip)
			
			InformationTooltip:AddLine(description, DEFAULT_FONT, r, g, b)

			if self:IsActive() and self.imitationCollectibleData.GetActiveCollectibleText then
				local activeCollectibleText = self.imitationCollectibleData:GetActiveCollectibleText(self:GetActorCategory())
				if activeCollectibleText ~= nil and activeCollectibleText ~= "" then
					ZO_Tooltip_AddDivider(InformationTooltip)
					InformationTooltip:AddLine(activeCollectibleText, DEFAULT_FONT, r, g, b)
				end
			end

			if not self.imitationCollectibleData:IsUsable(self:GetActorCategory()) then
				local errorR, errorG, errorB = ZO_ERROR_COLOR:UnpackRGB()
				InformationTooltip:AddLine(self.imitationCollectibleData:GetBlockReason(self:GetActorCategory()), DEFAULT_FONT, errorR, errorG, errorB)
			end
		end
	end
	self:RefreshTitleLabelColor()
end

function random_collectibleTile:GetActorCategory()
	return self.imitationCollectibleData:GetActorCategory()
end

function random_collectibleTile:Use()
	self.imitationCollectibleData:Use(self:GetActorCategory())
end

function random_collectibleTile:ShowMenu()
	local collectibleData = self.imitationCollectibleData
	if collectibleData then
		ClearMenu()
		self:AddMenuOptions()
		ShowMenu(self.control)
	end
end

function random_collectibleTile:AddMenuOptions()
	local collectibleData = self.imitationCollectibleData

	--Use
	if collectibleData:IsUsable(self:GetActorCategory()) then
		local stringId = self:GetPrimaryInteractionStringId()
		if stringId then
			local function UseCollectible()
				if IsCurrentlyPreviewing() then
					ITEM_PREVIEW_KEYBOARD:EndCurrentPreview()
				end
				collectibleData:Use(self:GetActorCategory())
			end
			AddMenuItem(GetString(stringId), UseCollectible)
		end
	end
end

--[[
local function IsCollectibleSlottable(collectibleId)
end
if collectibleId > lastZOCollectibleId then
end
]]

---------------------------------------------------------------------------------------------------------------
-- Active tile
---------------------------------------------------------------------------------------------------------------

local active_collectibleImitationTile = random_collectibleTile:Subclass()

function active_collectibleImitationTile:Reset()
	self.imitationCollectibleData = nil

	self:SetCanFocus(false)
	local INSTANT = true
	self:SetHighlightHidden(true, INSTANT)
	
	self.cornerTagTexture = self.control:GetNamedChild("CornerTag")
	self.favoriteIcon = self.control:GetNamedChild("IconFavoriteIcon")
	self.cooldownIcon = self.control:GetNamedChild("CooldownIcon")
end

function active_collectibleImitationTile:OnMouseExit()
	ZO_ContextualActionsTile_Keyboard.OnMouseExit(self)
	ClearTooltip(InformationTooltip)
	ClearTooltip(ItemTooltip)
end

function active_collectibleImitationTile:LayoutPlatform(imitationCollectibleData)
	if not imitationCollectibleData.GetName then return end
	self.imitationCollectibleData = imitationCollectibleData
	
	self:SetCanFocus(true)

	-- Title
	self:SetTitle(imitationCollectibleData:GetName())

	local desaturation = imitationCollectibleData:IsBlocked(self:GetActorCategory()) and 1 or 0
	self:GetHighlightControl():SetDesaturation(desaturation)
	
	-- Icon/Highlight
	
	local iconTexture = self:GetIconTexture()
	local isLocked = imitationCollectibleData:IsLocked()
	iconTexture:SetTexture(imitationCollectibleData:GetIcon())
	ZO_SetDefaultIconSilhouette(iconTexture, isLocked)
	iconTexture:SetDesaturation(desaturation)

	self:Refresh()
end

function active_collectibleImitationTile:Refresh()
	-- Status
	local statusMultiIcon = self.statusMultiIcon
	statusMultiIcon:ClearIcons()

	if self:IsActive() and not self.imitationCollectibleData:ShouldSuppressActiveState(self:GetActorCategory()) then
		statusMultiIcon:AddIcon(ZO_CHECK_ICON)
	end

	statusMultiIcon:Show()

	self:UpdateKeybinds()

	-- Mouseover
	self:RefreshMouseoverVisuals()
end

function active_collectibleImitationTile:OnMouseUp(button, upInside)
	if upInside then
		if button == MOUSE_BUTTON_INDEX_RIGHT then
			self:ShowMenu()
		else
		--[[
			local collectibleData = self:GetCollectibleData()
			local collectibleId = collectibleData:GetId()
			browseToCollectible(getActiveSystemObject(), collectibleId, collectibleData)
		]]
		end
	end
end

function active_collectibleImitationTile:OnMouseDoubleClick(button)
	if button == MOUSE_BUTTON_INDEX_LEFT then
		local collectibleData = self:GetCollectibleData()
		
		if collectibleData and collectibleData:IsUsable(self:GetActorCategory()) then
			if IsCurrentlyPreviewing() then
				ITEM_PREVIEW_KEYBOARD:EndCurrentPreview()
			end
			self.imitationCollectibleData:Use(self:GetActorCategory())
		end
	end
end

function active_collectibleImitationTile:AddMenuOptions()
	local collectibleData = self:GetCollectibleData()

	--Use
	if collectibleData:IsUsable(self:GetActorCategory()) then
		local stringId = self:GetPrimaryInteractionStringId()
		if stringId then
			local function UseCollectible()
				self.imitationCollectibleData:Use(self:GetActorCategory())
			end
			AddMenuItem(GetString(stringId), UseCollectible)
		end
	end

	local collectibleId = collectibleData:GetId()

	local object = getActiveSystemObject()
	--Assign and Remove
	if collectibleData:IsUnlocked() then
		local function browseTo()
			browseToCollectible(object, collectibleId, collectibleData)
		end
		AddMenuItem(GetString(SI_IJA_BROWSTO), browseTo)
	end
end

function active_collectibleImitationTile:GetCollectibleData()
	if self.imitationCollectibleData.GetActiveCollectibleData then
		return self.imitationCollectibleData:GetActiveCollectibleData()
	end
	return self.imitationCollectibleData
end

function active_collectibleImitationTile:RefreshMouseoverVisuals()
	local collectibleData = self:GetCollectibleData()
	if collectibleData and self:IsMousedOver() then
		-- Tooltip
		ClearTooltip(ItemTooltip)
		local offsetX = self.control:GetParent():GetLeft() - self.control:GetLeft() - 5
		InitializeTooltip(ItemTooltip, self.control, RIGHT, offsetX, 0, LEFT)
		
		local SHOW_NICKNAME = true
		local SHOW_PURCHASABLE_HINT = true
		local SHOW_BLOCK_REASON = true
		ItemTooltip:SetCollectible(collectibleData:GetId(), SHOW_NICKNAME, SHOW_PURCHASABLE_HINT, SHOW_BLOCK_REASON, self:GetActorCategory())
	end

	self:RefreshTitleLabelColor()
end

---------------------------------------------------------------------------------------------------------------
-- ZO_CollectibleData
---------------------------------------------------------------------------------------------------------------
--[[
local SUPPORTED_HOTBAR_CATEGORY_DATA = {
	[VAR_CATEGOY_ID_APPEARANCE] = HOTBAR_CATEGORY_TOOL_WHEEL
}

local origGetHotbarForCollectibleCategoryId = GetHotbarForCollectibleCategoryId
function GetHotbarForCollectibleCategoryId(categoryId)
	if SUPPORTED_HOTBAR_CATEGORY_DATA[categoryId] then
		return SUPPORTED_HOTBAR_CATEGORY_DATA[categoryId]
	end
	return origGetHotbarForCollectibleCategoryId(categoryId)
end

function ZO_CollectibleData:IsSlottable()
	local slottable = IsCollectibleSlottable(self.collectibleId)
	if not slottable then
		slottable = self.randomCollectibleType ~= nil
	end
	d( 'IsSlottable ' .. slottable)
    return slottable
end
]]

function ZO_CollectibleData:GetRandomType()
	return self.randomCollectibleType
end

---------------------------------------------------------------------------------------------------------------
-- Main class
---------------------------------------------------------------------------------------------------------------
--local CustomCollectible = ZO_InitializingObject:Subclass()
local CustomCollectible = ZO_CollectibleData:Subclass()

function CustomCollectible:Initialize(categoryId, collectibleId, randomCollectibleType)
	self.categoryId = categoryId
	self.collectibleId = collectibleId
	self.randomCollectibleType = randomCollectibleType
	self.isCustom = true
	self:Refresh()
end

function CustomCollectible:GetCategoryId()
	return self.categoryId
end

function CustomCollectible:GetCategoryType()
	return categoryId_To_CategoryType_Map[self.categoryId]
end

function CustomCollectible:Refresh()
	self.actorCategory = getActorCategory()
	self.categoryData = ZO_COLLECTIBLE_DATA_MANAGER:GetCategoryDataById(self:GetCategoryId())
	
	
	
	if self:GetCategoryType() == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET then
		self.name = GetString(SI_COLLECTIBLE_ACTION_DISMISS)
	else
		self.name = GetString(SI_COLLECTIBLE_ACTION_PUT_AWAY)
	end
	
	local collectibleId = GetActiveCollectibleByType(self:GetCategoryType(), self.actorCategory)
	self.collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
end

function CustomCollectible:GetBlockReason()
	return ""
end

function CustomCollectible:GetUnlockState()
	return COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED
end

function CustomCollectible:IsActive(actorCategory)
	return false
end

function CustomCollectible:IsLocked()
	return false
end

function CustomCollectible:IsHouse()
	return false
end

function CustomCollectible:IsStory()
	return false
end

function CustomCollectible:GetActorCategory()
	return getActorCategory()
end

function CustomCollectible:IsUsable(actorCategory)
	actorCategory = actorCategory or GAMEPLAY_ACTOR_CATEGORY_PLAYER
	return not self:IsActiveStateSuppressed(actorCategory) or IsCollectibleUsable(self.collectibleId, actorCategory)
end

function CustomCollectible:IsActiveStateSuppressed(actorCategory)
	if self:IsActive(actorCategory) then
		return true
	end

	return self:ShouldSuppressActiveState(actorCategory)
end

function CustomCollectible:ShouldSuppressActiveState(actorCategory)
	if self:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET) and isInHouse() then
		return true
	elseif self:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_COMPANION) and HasSuppressedCompanion() then
		return true
	elseif self:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_ABILITY_FX_OVERRIDE) then
		return true
	end
	return false
end

function CustomCollectible:IsUnlocked()
	return true
end

function CustomCollectible:GetDescription()
	return GetCollectibleDescription(self.collectibleId)
end

function CustomCollectible:IsFavorite()
	return true
end

function CustomCollectible:IsNew()
	return false
end

function CustomCollectible:IsBlocked(actorCategory)
	if self:GetActiveCollectibleId(actorCategory) == 0 then
		return self:IsUsable(actorCategory)
	end

	return not self:IsUsable(actorCategory)
end

--[[
function CustomCollectible:IsLocked()
	return self:GetUnlockState() == COLLECTIBLE_UNLOCK_STATE_LOCKED
end
]]

function CustomCollectible:IsOwned()
	return self:GetUnlockState() == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED
end

function CustomCollectible:IsPurchasable()
	return true
end

function CustomCollectible:Use(collectibleId, actorCategory)
	if self:IsBlocked(actorCategory) then
		self:Use(collectibleId, actorCategory)
		return
	end
	
	UseCollectible(collectibleId, actorCategory)
	self.lastUsed = collectibleId
	self.inUse = false
	
	if not IsInGamepadPreferredMode then
		COLLECTIONS_BOOK:UpdateCollectionLater()
	end
end

function CustomCollectible:GetCooldownDuration()
	local remainingMs, durationMs = GetCollectibleCooldownAndDuration(self:GetActiveCollectibleId())
	return remainingMs, durationMs + 100
end

---------------------------------------------------------------------------------------------------------------
-- Random class
---------------------------------------------------------------------------------------------------------------
local RandomCollectibleData = CustomCollectible:Subclass()

function RandomCollectibleData:Refresh()
	self.actorCategory = getActorCategory()
	self.orderedCollectibles = self:GetOrderedCollectibes()
	self.name = GetString("SI_IJA_RANDOM_COLLECTIBLE", self.randomCollectibleType)
end

function RandomCollectibleData:GetRandomType()
	return self.randomCollectibleType
end

function RandomCollectibleData:GetDescription()
	return zo_strformat(GetString('SI_IJA_RANDOM_TOOLTIP_DESCRIPTION', self.randomCollectibleType), ZO_WHITE:Colorize(GetString('SI_COLLECTIBLECATEGORYTYPE', self:GetCategoryType())))
end

do
	local RANDOM_COLLECTIBLE_TYPE_ICONS =
	{
		[RANDOM_COLLECTIBLE_TYPE_FAVORITE] = 'IsJustaCollectibleRandomizer/assets/ija_random_favorite_collectible.dds',
		[RANDOM_COLLECTIBLE_TYPE_ANY] = 'IsJustaCollectibleRandomizer/assets/ija_random_collectible.dds',
	}

	function RandomCollectibleData:GetIcon()
		return RANDOM_COLLECTIBLE_TYPE_ICONS[self.randomCollectibleType]
	end
end

function RandomCollectibleData:IsBlocked(actorCategory)
	if self.randomCollectibleType == RANDOM_COLLECTIBLE_TYPE_FAVORITE and not self:HasAnyFavorites(actorCategory) then
		return true
	elseif self.randomCollectibleType == RANDOM_COLLECTIBLE_TYPE_ANY and not self:HasAnyUnlockedCollectibles(actorCategory) then
		return true
	end

	return not self:IsUsable(actorCategory)
end

function RandomCollectibleData:GetBlockReason(actorCategory)
	if not self:IsUsable(actorCategory) then
		local collectible = self.orderedCollectibles[1]
		
		if self.randomCollectibleType == RANDOM_COLLECTIBLE_TYPE_FAVORITE and not self:HasAnyFavorites() then
			return zo_strformat(SI_COLLECTIBLE_REQUIRES_FAVORITE, GetString("SI_COLLECTIBLECATEGORYTYPE", self:GetCategoryType()))
		elseif self.randomCollectibleType == RANDOM_COLLECTIBLE_TYPE_ANY and not self:HasAnyUnlockedCollectibles() then
			return zo_strformat(SI_COLLECTIBLE_REQUIRES_UNLOCKED_COLLECTIBLE, GetString("SI_COLLECTIBLECATEGORYTYPE", self:GetCategoryType()))
		elseif collectible then
			local blockReason = GetCollectibleBlockReason(collectible:GetId(), GAMEPLAY_ACTOR_CATEGORY_PLAYER)
			return zo_strformat(GetString("SI_COLLECTIBLEUSAGEBLOCKREASON", blockReason))
		end
	end

	return ""
end

function RandomCollectibleData:Use(actorCategory)
	if self.inUse then return end
	
	local collectibleId = self:GetRandomCollectible(actorCategory)
	if collectibleId then
		self.inUse = true
		
		local remainingMs, durationMs = self:GetCooldownDuration()
		zo_callLater(function()
			 CustomCollectible.Use(self, collectibleId, actorCategory)
		end, durationMs)
	end
end

function RandomCollectibleData:GetActiveCollectibleText(actorCategory)
	local collectibleId = GetActiveCollectibleByType(self:GetCategoryType(), actorCategory)
	local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
	if collectibleData then
		return zo_strformat(SI_IJA_ACTIVE_RANDOM_COLLECTIBLE, ZO_SELECTED_TEXT:Colorize(collectibleData:GetName()))
	end
end

function RandomCollectibleData:GetPrimaryInteractionStringId(actorCategory)
	return SI_ITEM_ACTION_USE
end

function RandomCollectibleData:GetOrderedCollectibes()
	return categoryId_To_OrderedCollectibles_Map[self.categoryId] or {}
end

function RandomCollectibleData:GetUnlockedCollectibes(actorCategory)
	local unlockedCollectibles = {}
	for k, collectibleData in pairs(self.orderedCollectibles) do
		if collectibleData:IsUnlocked() and GetActiveCollectibleByType(self:GetCategoryType(), actorCategory) ~= collectibleData:GetId() then
			table.insert(unlockedCollectibles, collectibleData)
		end
	end
	
	return unlockedCollectibles
end

function RandomCollectibleData:GetFavoriteCollectibes(actorCategory)
	local favoriteCollectibles = {}
	for k, collectibleData in pairs(self:GetUnlockedCollectibes(actorCategory)) do
		if collectibleData:IsFavorite() then
			table.insert(favoriteCollectibles, collectibleData)
		end
	end
	
	return favoriteCollectibles
end

function RandomCollectibleData:GetRandomCollectible(actorCategory)
	local unlockedCollectibles = {}
		
	if self.randomCollectibleType == RANDOM_COLLECTIBLE_TYPE_FAVORITE then
		unlockedCollectibles = self:GetFavoriteCollectibes(actorCategory)
	else
		unlockedCollectibles = self:GetUnlockedCollectibes(actorCategory)
	end
	if #unlockedCollectibles > 0 then
		local collectibleData = unlockedCollectibles[zo_random(1, #unlockedCollectibles)]
		return collectibleData:GetId()
	end
	
end

function RandomCollectibleData:HasAnyFavorites(actorCategory)
	return #self:GetFavoriteCollectibes(actorCategory) > 0
end

function RandomCollectibleData:HasAnyUnlockedCollectibles(actorCategory)
	return #self:GetUnlockedCollectibes(actorCategory) > 0
end

function RandomCollectibleData:GetUnBlockedCollectibes(actorCategory)
	local unblockedCollectibles = {}
	for k, collectibleData in pairs(self.orderedCollectibles) do
		if collectibleData:IsUsable() and GetActiveCollectibleByType(self:GetCategoryType(), actorCategory) ~= collectibleData:GetId() then
			table.insert(unblockedCollectibles, collectibleData)
		end
	end
	
	return unblockedCollectibles
end

function RandomCollectibleData:HasAnyUnBlockedCollectibles(actorCategory)
	return #self:GetUnBlockedCollectibes(actorCategory) > 0
end

function RandomCollectibleData:GetActiveCollectibleId()
	return GetActiveCollectibleByType(self:GetCategoryType(), self.actorCategory) or 0
end

---------------------------------------------------------------------------------------------------------------
-- Active collectible class
---------------------------------------------------------------------------------------------------------------
local ActiveCollectible = CustomCollectible:Subclass()

function ActiveCollectible:Refresh()
--	d( 'ActiveCollectible:Refresh')
	if self:GetCategoryType() == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET then
		self.name = GetString(SI_COLLECTIBLE_ACTION_DISMISS)
	else
		self.name = GetString(SI_COLLECTIBLE_ACTION_PUT_AWAY)
	end
	self.actorCategory = getActorCategory()
	
	local collectibleId = GetActiveCollectibleByType(self:GetCategoryType(), self.actorCategory)
	self.collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
	assert(self.collectibleData ~= self, 'collectibleData is being returned as self')
end

--[[
function ActiveCollectible:GetActiveCollectibleId(actorCategory)
	return GetActiveCollectibleByType(self:GetCategoryType(), actorCategory)
end
]]

function ActiveCollectible:GetDescription()
	return GetCollectibleDescription(self:GetActiveCollectibleId())
end

function ActiveCollectible:GetIcon()
	local collectibleId = self:GetActiveCollectibleId()
	if collectibleId > 0 then
		return GetCollectibleIcon(collectibleId)
	end
	return 'EsoUI/Art/Collections/collections_categoryIcon_locked_up.dds'
end

function ActiveCollectible:IsBlocked(actorCategory)
	local collectibleData = self:GetActiveCollectibleData()
	if self:GetActiveCollectibleId() == 0 then
		return true
	elseif self.collectibleData then
		return self.collectibleData:IsBlocked(actorCategory)
	end

	return false
end

function ActiveCollectible:Use(actorCategory)
	if self.inUse then return end
	
	local collectibleId = self:GetActiveCollectibleId()
	if collectibleId then
		self.inUse = true
		
		local remainingMs, durationMs = self:GetCooldownDuration()
		zo_callLater(function()
			 CustomCollectible.Use(self, collectibleId, actorCategory)
		end, durationMs)
	end
end


function ActiveCollectible:IsRenameable()
	return self.collectibleData:IsRenameable()
end

function ActiveCollectible:GetBlockReason(actorCategory)
	if self:GetActiveCollectibleId() == 0 then
		return zo_strformat(SI_IJA_BLOCK_REASON_NOT_ATIVE, GetString("SI_COLLECTIBLECATEGORYTYPE", self:GetCategoryType()))
	end

	return ""
end

function ActiveCollectible:GetNameWithNickname()
	if not self.cachedNameWithNickname then
		local nickname = self.collectibleData:GetNickname()
		if nickname and nickname ~= "" then
			self.cachedNameWithNickname = zo_strformat(SI_COLLECTIBLE_NAME_WITH_NICKNAME_FORMATTER, self.collectibleData:GetName(), nickname)
		else
			self.cachedNameWithNickname = self.collectibleData:GetFormattedName()
		end
	end

	return self.cachedNameWithNickname
end

function ActiveCollectible:GetPrimaryInteractionStringId(actorCategory)
	local categoryType = self:GetCategoryType()
	if categoryType == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET or categoryType == COLLECTIBLE_CATEGORY_TYPE_ASSISTANT or categoryType == COLLECTIBLE_CATEGORY_TYPE_COMPANION then
		return SI_COLLECTIBLE_ACTION_DISMISS
	else
		return SI_COLLECTIBLE_ACTION_PUT_AWAY
	end
end

function ActiveCollectible:GetRawNameWithNickname()
	local nickname = self.collectibleData:GetNickname()
	if nickname and nickname ~= "" then
		return zo_strformat(SI_COLLECTIBLE_NAME_WITH_NICKNAME_RAW, self.collectibleData:GetName(), nickname)
	else
		return self.collectibleData:GetName()
	end
end

function ActiveCollectible:GetDescription()
	return GetCollectibleDescription(self:GetActiveCollectibleId())
end

function ActiveCollectible:GetUnlockState()
	local collectibleData = self:GetActiveCollectibleData()
	if self.collectibleData and self.collectibleData ~= self then
		return self.collectibleData:GetUnlockState()
	else
--		d( 'ActiveCollectible:GetUnlockState collectibleData == self')
	end
end

function ActiveCollectible:IsUnlocked()
	return self:GetUnlockState() ~= COLLECTIBLE_UNLOCK_STATE_LOCKED
end

-- Get Active
function ActiveCollectible:GetActiveCollectibleId()
	return GetActiveCollectibleByType(self:GetCategoryType(), self.actorCategory) or 0
end

function ActiveCollectible:GetActiveCollectibleData()
	return ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(self:GetActiveCollectibleId())
end

function ActiveCollectible:GetActiveCollectibleText(actorCategory)
	return GetCollectibleDescription(self:GetActiveCollectibleId())
end

function ActiveCollectible:GetActiveInfo()
	return self:GetActiveCollectibleId(), self:GetActiveCollectibleData(), self:GetActiveCollectibleData():GetCategoryData() 
end

---------------------------------------------------------------------------------------------------------------
-- Addon
---------------------------------------------------------------------------------------------------------------
local addon = ZO_CollectibleDataManager:Subclass()

function addon:Initialize(control)
	self.control = control
	zo_mixin(self, addonInfo)
	
	local function OnLoaded(_, name)
		if name ~= self.name then return end
		self.control:UnregisterForEvent(EVENT_ADD_ON_LOADED)
		
		local AccountWideSavedVars = ZO_SavedVars:NewAccountWide("IJA_CollectibleRandomizer_SavedVars", svVersion, nil, defaults, GetWorldName())
		self.savedVars = AccountWideSavedVars
	--	self:InitializeSettings()
		self:RegisterSystems()
		
	end
	control:RegisterForEvent( EVENT_ADD_ON_LOADED, OnLoaded)
	
	local function onPlayerActivated()
		self.control:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
--			d( self.displayName .. " version: " .. self.version)
		self:InitializeForPlatforms()
		self:InitializeHooks()
	end
	self.control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, onPlayerActivated)
end

function addon:InitializeForPlatforms()
	local gamepadTeplates = {
		[GAMEPAD_COLLECTIONS_BOOK] = {
			template = 'ZO_GamepadCollectibleEntryTemplate', 
			scene = GAMEPAD_COLLECTIONS_BOOK_SCENE,
		},
		[COMPANION_COLLECTION_BOOK_GAMEPAD] = {
			template = 'ZO_GamepadCompanionCollectible', 
			scene = COMPANION_COLLECTION_BOOK_GAMEPAD_SCENE,
		},
	}
	
	-- We need to disable the orginal methods used to clear data so it does not clear the freshly added randomizers.
	local function initializeForGamepadMode()
		local function overwriteClearAndRelease(object)
			object.RefreshActiveCollectibleInfo = function(self, collectibleData, actorCategory)
				local tooltip = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
				
				local topSection = tooltip:AcquireSection(tooltip:GetStyle("collectionsTopSection"))
				tooltip:AddSection(topSection)

				local bodySection = tooltip:AcquireSection(tooltip:GetStyle("collectionsInfoSection"))
				bodySection:AddTexture(ZO_GAMEPAD_HEADER_DIVIDER_TEXTURE, tooltip:GetStyle("dividerLine"))
				bodySection:AddLine(collectibleData:GetName(), tooltip:GetStyle("title"))

				bodySection:AddLine(collectibleData:GetDescription(actorCategory), tooltip:GetStyle("bodyDescription"))
				
				local blockReason = imitationCollectibleData:IsBlocked(actorCategory) and imitationCollectibleData:GetBlockReason(actorCategory) or nil
				if blockReason ~= nil and blockReason ~= "" then
					bodySection:AddLine(blockReason, self:GetStyle("bodyDescription"), self:GetStyle("failed"))
				end

				self:AddSection(bodySection)
			end
			object.ClearAndReset = function(self)
				self.collectionList.list.Clear = function() end
				ZO_ParametricScrollList.Clear(self.collectionList.list)
			end

			object.Restore = function(self)
				self.collectionList.list.Clear = ZO_ParametricScrollList.Clear
			end
		end
		overwriteClearAndRelease(GAMEPAD_COLLECTIONS_BOOK)
		overwriteClearAndRelease(COMPANION_COLLECTION_BOOK_GAMEPAD)
		-- Add self.scene to gamepad objects
		GAMEPAD_COLLECTIONS_BOOK.scene = GAMEPAD_COLLECTIONS_BOOK_SCENE
		COMPANION_COLLECTION_BOOK_GAMEPAD.scene = COMPANION_COLLECTION_BOOK_GAMEPAD_SCENE
	end
	initializeForGamepadMode()
	
	local function initializeForKeyboardMode(object)
		local HIDE_CALLBACK = nil
		local CENTER_ENTRIES = true --TODO: Remove this when it's the default
		local COLLECTIBLE_TILE_GRID_PADDING = 10
		object.gridListPanelList:AddEntryTemplate("IJA_CollectibleTile_Keyboard_Control", ZO_COLLECTIBLE_TILE_KEYBOARD_DIMENSIONS_X, ZO_COLLECTIBLE_TILE_KEYBOARD_DIMENSIONS_Y, ZO_DefaultGridTileEntrySetup, HIDE_CALLBACK, ZO_DefaultGridTileEntryReset, COLLECTIBLE_TILE_GRID_PADDING, COLLECTIBLE_TILE_GRID_PADDING, CENTER_ENTRIES)
		object.gridListPanelList:AddEntryTemplate("IJA_CollectibleRandomizerTile_Keyboard_Control", ZO_COLLECTIBLE_TILE_KEYBOARD_DIMENSIONS_X, ZO_COLLECTIBLE_TILE_KEYBOARD_DIMENSIONS_Y, ZO_DefaultGridTileEntrySetup, HIDE_CALLBACK, ZO_DefaultGridTileEntryReset, COLLECTIBLE_TILE_GRID_PADDING, COLLECTIBLE_TILE_GRID_PADDING, CENTER_ENTRIES)
			
		object.RefreshActiveCollectibleInfo = function(self, collectibleData, actorCategory)
			ZO_Tooltip_AddDivider(InformationTooltip)
			
			InformationTooltip:AddLine(collectibleData:GetName(), "ZoFontWinH2", ZO_SELECTED_TEXT:UnpackRGBA())
			InformationTooltip:AddLine(collectibleData:GetDescription(actorCategory), DEFAULT_FONT, r, g, b)
			
			if self.collectibleData:IsBlocked(self:GetActorCategory()) then
				local errorR, errorG, errorB = ZO_ERROR_COLOR:UnpackRGB()
				InformationTooltip:AddLine(self.collectibleData:GetBlockReason(self:GetActorCategory()), DEFAULT_FONT, errorR, errorG, errorB)
			end
		end

		local function overwriteClearAndRelease(object)
			object.ClearAndReset = function(self)
				self.gridListPanelList.ClearGridList = function() end
				self.entryDataObjectPool.ReleaseAllObjects = function() end
				
				ZO_AbstractGridScrollList.ClearGridList(self.gridListPanelList)
				ZO_EntryDataPool.ReleaseAllObjects(self.entryDataObjectPool)
			end

			object.Restore = function(self)
				self.gridListPanelList.ClearGridList = ZO_AbstractGridScrollList.ClearGridList
				self.entryDataObjectPool.ReleaseAllObjects = ZO_EntryDataPool.ReleaseAllObjects
			end
		end
		overwriteClearAndRelease(object)
	end
	
	for k, object in pairs({COLLECTIONS_BOOK, COMPANION_COLLECTION_BOOK_KEYBOARD}) do
		SecurePostHook(object, 'OnDeferredInitialize', function()
			initializeForKeyboardMode(object)
		end)
	end
end

do -- Safely set system objects
	local systemObjects = {
		[GAMEPLAY_ACTOR_CATEGORY_PLAYER] = {
			['gamepad'] = GAMEPAD_COLLECTIONS_BOOK,
			['keyboard'] = COLLECTIONS_BOOK,
		},
		[GAMEPLAY_ACTOR_CATEGORY_COMPANION] = {
			['gamepad'] = COMPANION_COLLECTION_BOOK_GAMEPAD,
			['keyboard'] = COMPANION_COLLECTION_BOOK_KEYBOARD,
		},
	}
	local function safeRegisterSystemObject(objectName, object, platform, actorCategory)
		local system = SYSTEMS:GetSystem(objectName)
		object.actorCategory = actorCategory
		if system[platform] == nil then
			system[platform] = object
		end
	end

	function addon:RegisterSystems()
		for actorCategory, object in pairs(systemObjects) do
			local objectName = actorCategory == GAMEPLAY_ACTOR_CATEGORY_PLAYER and 'collectionsBook' or 'collectionsBookCompanion'
			safeRegisterSystemObject(objectName, object.gamepad, 'gamepadObject', actorCategory)
			safeRegisterSystemObject(objectName, object.keyboard, 'keyboardObject', actorCategory)
		end
	end
end

function addon:InitializeHooks()
	ZO_PreHook(GAMEPAD_COLLECTIONS_BOOK, 'BuildCollectionList', function(object, categoryData)
		if categoryData.IsFavoritesCategory and categoryData:IsFavoritesCategory() then return end
		self.BuildRandomizers_Gamepad(object, categoryData, "ZO_GamepadCollectibleEntryTemplate", GAMEPLAY_ACTOR_CATEGORY_PLAYER)
	end)

	ZO_PreHook(COMPANION_COLLECTION_BOOK_GAMEPAD, 'BuildCollectionList', function(object, categoryData)
		if categoryData.IsFavoritesCategory and categoryData:IsFavoritesCategory() then return end
		self.BuildRandomizers_Gamepad(object, categoryData, "ZO_GamepadCompanionCollectible", GAMEPLAY_ACTOR_CATEGORY_COMPANION)
	end)

	ZO_PreHook(COLLECTIONS_BOOK, 'BuildContentList', function(object, categoryData)
		if categoryData.IsFavoritesCategory and categoryData:IsFavoritesCategory() then return end
		self.BuildRandomizers_Keyboard(object, categoryData, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
	end)

	ZO_PreHook(COMPANION_COLLECTION_BOOK_KEYBOARD, 'BuildContentList', function(object, categoryData)
		if categoryData.IsFavoritesCategory and categoryData:IsFavoritesCategory() then return end
		self.BuildRandomizers_Keyboard(object, categoryData, GAMEPLAY_ACTOR_CATEGORY_COMPANION)
	end)
	
	local function onCollectibleUpdated(collectibleId)
		if activeUnequipCollectible then
			local object = getActiveSystemObject()
			if IsInGamepadPreferredMode() then
				object:OnCollectibleUpdated()
			else
				object:OnCollectionUpdated()
			end
		end
	end
	ZO_COLLECTIBLE_DATA_MANAGER:RegisterCallback("OnCollectibleUpdated", onCollectibleUpdated)
end

local function getNewCollectibleData(builder, categoryId, randomType)
	local lastCollectibleId = getLastCollectibleId()
	local newCollectibleId = getCustomCollectibleIdFromRandomType(randomType)
	
	if newCollectibleId == nil then
		newCollectibleId = lastCollectibleId + 1
	end
	
	local newCollectibleData = builder:New(categoryId, newCollectibleId, randomType)
	customColectibleId_To_ColectibleData_Map[newCollectibleId] = newCollectibleData
	ZO_COLLECTIBLE_DATA_MANAGER:MapCollectibleData(newCollectibleData)
	return newCollectibleData
end

function addon:BuildRandomizers_Keyboard(categoryData, actorCategory)
	self:ClearAndReset()
	activeUnequipCollectible = nil
	local categoryId = categoryData:GetId()
	if categoryId_To_OrderedCollectibles_Map[categoryId] then
		local gridListPanelList = self.gridListPanelList
		
		for k, randomType in ipairs({RANDOM_COLLECTIBLE_TYPE_FAVORITE, RANDOM_COLLECTIBLE_TYPE_ANY}) do
			local entryData = self.entryDataObjectPool:AcquireObject()
			local collectibleData = getNewCollectibleData(RandomCollectibleData, categoryId, randomType)
			collectibleData.actorCategory = actorCategory
			
			entryData:SetDataSource(collectibleData)
			entryData.gridHeaderTemplate = ZO_GRID_SCROLL_LIST_DEFAULT_HEADER_TEMPLATE_KEYBOARD
			entryData.gridHeaderName = ""
			gridListPanelList:AddEntry(entryData, "IJA_CollectibleRandomizerTile_Keyboard_Control")
		end
		
		if categoryId_To_CategoryType_Map[categoryId] ~= COLLECTIBLE_CATEGORY_TYPE_MEMENTO then
			local entryData = self.entryDataObjectPool:AcquireObject()
			local collectibleData = getNewCollectibleData(ActiveCollectible, categoryId)
			collectibleData.actorCategory = actorCategory
			
			entryData:SetDataSource(collectibleData)
			entryData.gridHeaderTemplate = ZO_GRID_SCROLL_LIST_DEFAULT_HEADER_TEMPLATE_KEYBOARD
			entryData.gridHeaderName = ""
			gridListPanelList:AddEntry(entryData, "IJA_CollectibleTile_Keyboard_Control")
			activeUnequipCollectible = collectibleData
		end
	end
	zo_callLater(function() self:Restore() end, 100)
end

function addon:BuildRandomizers_Gamepad(categoryData, template, actorCategory)
	self:ClearAndReset()
	activeUnequipCollectible = nil
	local categoryId = categoryData:GetId()
	if categoryId_To_OrderedCollectibles_Map[categoryId] then
		local collectionListInfo = self.collectionList
		local collectionList = collectionListInfo.list
		
		for k, randomType in ipairs({RANDOM_COLLECTIBLE_TYPE_FAVORITE, RANDOM_COLLECTIBLE_TYPE_ANY}) do
			local collectibleData = getNewCollectibleData(RandomCollectibleData, categoryId, randomType)
			collectibleData.actorCategory = actorCategory
			
			local entryData = self:BuildCollectibleCategorySetRandomSelectionData(collectibleData)
			ZO_UpdateCollectibleEntryDataIconVisuals(entryData, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
			collectionList:AddEntry(template, entryData)
		end
		
		if categoryId_To_CategoryType_Map[categoryId] ~= COLLECTIBLE_CATEGORY_TYPE_MEMENTO then
			local collectibleData = getNewCollectibleData(ActiveCollectible, categoryId)
			collectibleData.actorCategory = actorCategory
			
			local entryData = self:BuildCollectibleCategorySetRandomSelectionData(collectibleData)
			ZO_UpdateCollectibleEntryDataIconVisuals(entryData, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
			collectionList:AddEntry(template, entryData)
			activeUnequipCollectible = collectibleData
		end
	end
	zo_callLater(function() self:Restore() end, 100)
end

---------------------------------------------------------------------------------------------------------------
-- XML Handlers
---------------------------------------------------------------------------------------------------------------
function IJA_CollectibleRandomizer_Initialize( ... )
	IJA_COLLECTIBLERANDOMIZER = addon:New( ... )
end

function addon:InitializeKeyboardImitationTile(control)
	random_collectibleTile:New(control)
end

function addon:InitializeKeyboardTile(control)
	active_collectibleImitationTile:New(control)
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
