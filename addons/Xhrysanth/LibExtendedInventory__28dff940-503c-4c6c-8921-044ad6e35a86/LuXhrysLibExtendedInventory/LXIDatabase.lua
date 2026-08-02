
--[[ LuXhrys Modular Add-On System ]]
--[[ Written by Xhrysanth (PSNA) ]]
--[[ LibExtendedInventory ]]
--[[ LXIDatabase.lua ]]
--[[ LOAD ORDER THIRD ]]


--[[ DISCLAIMER
This Add-on is not created by, affiliated with, or sponsored by, ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
]]

--[[ Information, attribution, copyright, and license:
This file is part of the core module for the LuXhrys add-on system for the Elder Scrolls Online.

This code chunk implements database functions for the LuXhrys add-on system for the Elder Scrolls Online.

Written and copyright (c) 2026 by Xhrysanth (PSNA). License terms to be determined. Currently, and until this notice changes, all rights are reserved, except those that belong to ZeniMax Media Inc., which provides the API used by this software.
]]


--[[ ==========================> DECLARATIONS <=========================== ]]--


-- ========================= [ Dependency Check ] ========================== --


assert (LUXHRYS.LXI ~= nil, "[LuXhrysLXID] CRIT: LuXhrysLXIO not available. This chunk will not be loaded.")


-- ============================== [ Metadata ] ============================= --


local ADDON_SYSTEM_NAME = LUXHRYS.METADATA.ADDON_SYSTEM_NAME
local ADDON_AUTHOR = LUXHRYS.METADATA.ADDON_AUTHOR
local ADDON_COPYRIGHT_AND_LICENSE = LUXHRYS.METADATA.ADDON_COPYRIGHT_AND_LICENSE
local ADDON_DISCLAIMER = LUXHRYS.METADATA.ADDON_DISCLAIMER
local ADDON_DESCRIPTION = LUXHRYS.METADATA.ADDON_DESCRIPTION

local ADDON_MODULE_NAME = LUXHRYS.LXI.METADATA.ADDON_MODULE_NAME
local ADDON_MODULE_SHORT_NAME = LUXHRYS.LXI.METADATA.ADDON_MODULE_SHORT_NAME
local ADDON_NAME = LUXHRYS.LXI.METADATA.ADDON_NAME
local ADDON_MODULE_VERSION = LUXHRYS.LXI.METADATA.ADDON_MODULE_VERSION
local ADDON_MODULE_DESCRIPTION = LUXHRYS.LXI.METADATA.ADDON_MODULE_DESCRIPTION

local ADDON_CHUNK_NAME = "Database"
local ADDON_CHUNK_SHORT_NAME = "D"
local ADDON_DEBUG_NAME = ADDON_SYSTEM_NAME .. ADDON_MODULE_SHORT_NAME .. ADDON_CHUNK_SHORT_NAME


-- ===================== [ Localize Global Functions ] ===================== --

-- We localize any functions that are called more than once or twice.

-------------------------------------------------------------------------------
--| C functions |--------------------------------------------------------------
-------------------------------------------------------------------------------


--local GetItemLink = GetItemLink
local GetItemLinkItemId = GetItemLinkItemId
local GetItemLinkName = GetItemLinkName
local GetItemLinkItemType = GetItemLinkItemType
local GetItemLinkStacks = GetItemLinkStacks
local GetItemLinkDisplayQuality = GetItemLinkDisplayQuality
local GetItemLinkIcon = GetItemLinkIcon

local GetGameTimeMilliseconds = GetGameTimeMilliseconds

local GetItemLinkFurnitureDataId = GetItemLinkFurnitureDataId
local GetFurnitureDataCategoryInfo = GetFurnitureDataCategoryInfo
local GetFurnitureCategoryInfo = GetFurnitureCategoryInfo
local GetItemLinkWeaponType = GetItemLinkWeaponType
local GetItemLinkArmorType = GetItemLinkArmorType

local IsItemLinkPlaceableFurniture = IsItemLinkPlaceableFurniture
local GetTimeStamp = GetTimeStamp

--local GetString = GetString


-------------------------------------------------------------------------------
--| ZOS Lua functions |--------------------------------------------------------
-------------------------------------------------------------------------------


--local ParseLink = ZO_LinkHandler_ParseLink
--local IconFormat = zo_iconFormat
--local TableInsert = table.insert
--local TableRemove = table.remove
--local TableConcat = table.concat
local ToString = tostring
local ToNumber = tonumber
--local StrFormat = string.format

local d = d
local zo_strformat = zo_strformat
local ZO_ClearTable = ZO_ClearTable
local ZO_ClearNumericallyIndexedTable = ZO_ClearNumericallyIndexedTable
local ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription = ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription
local NonContiguousCount = NonContiguousCount

-------------------------------------------------------------------------------
--| From LXICommon |-----------------------------------------------------------
-------------------------------------------------------------------------------


--local optionDefaults = LUXHRYS.optionDefaults
local OPTIONS
local Debug = LUXHRYS.Debug
local Async = LUXHRYS.Async
local Bag = LUXHRYS.Bag
local Location = LUXHRYS.Location
local LinkUtils = LUXHRYS.LinkUtils
local ItemInfo = LUXHRYS.ItemInfo


local BAG_PLACED_FURNISHINGS = Bag.BAG_PLACED_FURNISHINGS
local BAG_INBOX = Bag.BAG_INBOX
local BAG_TRADER = Bag.BAG_TRADER


local LOCATION_TYPE_FILTER_ALL = Location.LOCATION_TYPE_FILTER_ALL
local LOCATION_TYPE_FILTER_BACKPACK = Location.LOCATION_TYPE_FILTER_BACKPACK
local LOCATION_TYPE_FILTER_COLLECTIBLE_STORAGE = Location.LOCATION_TYPE_FILTER_COLLECTIBLE_STORAGE
local LOCATION_TYPE_FILTER_FURNITURE_VAULT = Location.LOCATION_TYPE_FILTER_FURNITURE_VAULT
local LOCATION_TYPE_FILTER_HOUSE = Location.LOCATION_TYPE_FILTER_HOUSE
local LOCATION_TYPE_FILTER_TRADER = Location.LOCATION_TYPE_FILTER_TRADER
local LOCATION_TYPE_FILTER_INBOX = Location.LOCATION_TYPE_FILTER_INBOX
local LOCATION_TYPE_FILTER_GUILD = Location.LOCATION_TYPE_FILTER_GUILD
local LOCATION_TYPE_FILTER_WORN = Location.LOCATION_TYPE_FILTER_WORN
local LOCATION_TYPE_FILTER_BUYBACK = Location.LOCATION_TYPE_FILTER_BUYBACK
local LOCATION_TYPE_FILTER_COMPANION = Location.LOCATION_TYPE_FILTER_COMPANION
local LOCATION_TYPE_FILTER_VENGEANCE = Location.LOCATION_TYPE_FILTER_VENGEANCE


--[[ ============================> FUNCTIONS <============================ ]]--


-- ============================ [ The Database ] =========================== --


local Database = ZO_InitializingObject:Subclass ()


-------------------------------------------------------------------------------
--| Initialization |-----------------------------------------------------------
-------------------------------------------------------------------------------


function Database:Initialize ()

	-- The database.

--	self.db = sampleDB -- not compatible with DBKeys

	local defaultDB =
	{
		characterAliases = {},
		data = {}
	}

	self.database = ZO_SavedVars:NewAccountWide(ADDON_SYSTEM_NAME .. ADDON_MODULE_NAME .. "_SV", OPTIONS.databaseVersion, "database", defaultDB, GetWorldName ())

	self.db = self.database.data
	self.characterAliases = self.database.characterAliases

	self.lastUpdate = 0

end


-------------------------------------------------------------------------------
--| Debugging functions |------------------------------------------------------
-------------------------------------------------------------------------------


function Database:Dump ()
	Debug.Msg (1, ADDON_DEBUG_NAME, "DB_D", "Dumping raw database.")
	d (self.db)
	d ("Database variable type: " .. type (self.db))
	Debug.Msg (1, ADDON_DEBUG_NAME, "DB_D", "Dump complete.")
end


-------------------------------------------------------------------------------
--| Helper functions to reduce file/table size |-------------------------------
-------------------------------------------------------------------------------


	local function UncondenseDelimiterRepetitions (input)
		local returnValue = ":0"
		return returnValue:rep (ToNumber (input:match ("%d+")))
	--	for _ = 1, ToNumber (input:match ("%d+")) do
	--		returnValue = returnValue .. ":0"
	--	end
	--	return returnValue
	end


	local function UncondenseZeroRepetitions (input)
		local returnValue = "0"
		return returnValue:rep (tonumber (input:match ("%d+")))
	end


	local function CondenseDelimiterRepetitions (input)
		-- 'input' is the whole match (e.g., "AAA")
	--	return TableConcat ({input:sub (1, 1), #input}) -- Slightly slower.
		return input:sub (1, 1) .. #input
	end


	local function CondenseZeroRepetitions (input)
	--	return input:sub (1, 1) .. #input
		return "x" .. #input
	end


	local function ItemKeyToDBKey (itemKey)

		Debug.Msg (2, ADDON_DEBUG_NAME, "IKTDK", "Called with itemKey type %s.", type (itemKey))

	--if type (itemKey) == "table" then d (itemKey, itemKey[1]) end

		Debug.Msg (4, ADDON_DEBUG_NAME, "IKTDK", "itemKey is %s.", LinkUtils.StripItemLink (tostring (itemKey)))

		if type (itemKey) == "number" then return itemKey end

	--  return itemKey:gsub ("^|H%d:item:(.+)|h|h$", "%1"):gsub (":0", "!"):gsub ("!+", CondenseDelimiterRepetitions)
	--  local dbKey = itemKey:gsub ("^|H%d:item:(.+)|h|h$", "%1"):gsub (":0", "!"):gsub ("!+", CondenseDelimiterRepetitions)

		local dbKey = LinkUtils.StripItemLink (itemKey):gsub (":0", "!"):gsub ("!+", CondenseDelimiterRepetitions):gsub ("00+", CondenseZeroRepetitions)

		Debug.Msg (3, ADDON_DEBUG_NAME, "IKTDK", "Returning dbKey %s.", dbKey)
		return dbKey

	end


	local function DBKeyToItemKey (dbKey)
		local keyType = type (dbKey)
		if type (dbKey) == "number" then return dbKey end
		return dbKey:gsub ("x%d+", UncondenseZeroRepetitions):gsub ("!%d+", UncondenseDelimiterRepetitions):gsub ("^(.+)$", "|H0:item:%1|h|h")
	end


	-------------------------------------------------------------------------------
	--| Core database functions |--------------------------------------------------
	-------------------------------------------------------------------------------


	-- We'll use extra robust type checks to make sure everything is valid.

	function Database:Get (itemKey)

		Debug.Msg (2, ADDON_DEBUG_NAME, "DB_G", "Called with itemKey %s.", tostring (LinkUtils.StripItemLink (itemKey)))

		if itemKey and (type (itemKey == "number") or type (itemKey == "string")) then
	--		return self.db[ItemKeyToDBKey (itemKey)] or nil
			local returnValue = self.db[ItemKeyToDBKey (itemKey)]
			Debug.Msg (4, ADDON_DEBUG_NAME, "DB_G", "Returning itemInfo %s.", tostring (returnValue))
			return returnValue
		end

	end


	function Database:Set (itemKey, itemInfo)

		Debug.Msg (2, ADDON_DEBUG_NAME, "DB_S", "Called with args %s, %s.", LinkUtils.StripItemLink (itemKey) or "--", itemInfo or "--")

		if itemKey and (type (itemKey == "number") or type (itemKey == "string"))
		and (itemInfo == nil or (itemInfo and type (itemInfo) == "string"))
		then
			Debug.Msg (4, ADDON_DEBUG_NAME, "DB_S", "Set %s to %s.", LinkUtils.StripItemLink (itemKey) or "--", itemInfo or "--")
			self.db[ItemKeyToDBKey (itemKey)] = itemInfo
			self.lastUpdate = GetTimeStamp ()
		end

	end


	function Database:Clear (itemKey)

		Debug.Msg (2, ADDON_DEBUG_NAME, "DB_C", "Called with arg %s.", LinkUtils.StripItemLink (itemKey) or "--")

		if itemKey and (type (itemKey == "number") or type (itemKey == "string"))
		and self:Get (itemKey)
		then
			Debug.Msg (4, ADDON_DEBUG_NAME, "DB_C", "Cleared.", LinkUtils.StripItemLink (itemKey) or "--")
			self.db[ItemKeyToDBKey (itemKey)] = nil
			self.lastUpdate = GetTimeStamp ()
		end

	end


	function Database:Reset (includeAliases)
		Debug.Msg (0, ADDON_DEBUG_NAME, "DB_R", "WARN: Resetting database. All previous inventory data are lost.")
		ZO_ClearTable (self.db)
		if includeAliases and includeAliases == true then
			ZO_ClearTable (self.characterAliases)
		end
	end

	-- Try to limit access to the database. Initialized below.

	local DB


	-- We still want to be able to dump it from the command line.

	function LUXHRYS.Debug.DB_Dump ()
		DB:Dump ()
	end

	function LUXHRYS.Debug.DB_Reset ()
		DB:Reset ()
	end



-- ============================= [ ItemCache ] ============================= --


local ItemCache = ZO_InitializingObject:Subclass ()


--[[ ItemCache is used to facilitate inventory scans. Format is
itemKey=stackCount except for BAG_INBOX, which will be itemKey=itemInfo
because of multiple locations per mailbox.
]]


function ItemCache:Initialize (bagID, useAsync, callbackFunction)

	self.cache = {}

	if not Bag.IsAvailable (bagID) and bagID ~= BAG_INBOX then -- We create the cache after the mailbox is closed.
		Debug.Msg (1, ADDON_DEBUG_NAME, "IC_I", "Invalid or unavailable bag ID %s.", ToString (bagID))
		return
	end

	self.bagID = bagID

	if bagID == BAG_INBOX then
--		SetCurrentLocationCode ("M0")
		self.locationCode = "M0"
	else
--		SetCurrentLocationCode (Location.GetCodeForBagInCurrentState (bagID))
		self.locationCode = Location.GetCodeForBagInCurrentState (bagID)
	end

	Debug.Msg (3, ADDON_DEBUG_NAME, "IC_I", "New item cache created for bag ID %s, location code %s.", ToString (bagID), self.locationCode)

	useAsync = useAsync == true or false

	if useAsync and OPTIONS.async.useAsync then
		self.asyncTask = Async.Initialize (ADDON_DEBUG_NAME .. "_IC_" .. GetGameTimeMilliseconds ())
	end

	-- The callback, which is optional, is called after processing has finished. Typically used to remove the itemCache from the "class" calling it.

	if callbackFunction and type (callbackFunction) == "function" then
		self.callbackFunction = callbackFunction
	end

end


--| Utility functions |--------------------------------------------------------


function ItemCache:Update (itemKey, stackCountDelta, overrideLocationCode)
	self.cache[itemKey] = ItemInfo.IncreaseOrDecreaseLocationCodeStackCount (
		self.cache[itemKey],
		overrideLocationCode or self.locationCode, -- override is for BAG_INBOX
		stackCountDelta
	)
end


-- We assume that the itemCache has the complete count for its location.
-- For each item in db, see if it's in itemcache. If yes, update db for
-- location and delete from itemcache. If not, delete from db for location.
-- This function is robust to handle multiple locationIDs per itemInfo.

function ItemCache:ProcessDBItem (dbKey, itemInfo)

	-- This function is called from a loop iterating over the database. The
	-- database uses compressed keys, which we now need to uncompress to
	-- make them usable.

	local itemKey = DBKeyToItemKey (dbKey)

	Debug.Msg (2, ADDON_DEBUG_NAME, "IC_PDBI", "Processing itemKey %s with database itemInfo %s and locationCode %s. (%s)", LinkUtils.StripItemLink (itemKey), itemInfo, ToString (self.locationCode), self.locationCode == "M0" and "Yes" or "No")

	-- Mailbox is tricky because there are multiple locations in the "bag." We'll
	-- just delete every inbox location from the db itemInfo. We'll then add the
	-- inbox locations present in the cache.
-- Doesn't work because we don't reprocess every message every time. Attachments can never change, so we shouldn't need to worry about this.
	if self.locationCode == "M0" then -- this is BAG_INBOX
		Debug.Msg (3, ADDON_DEBUG_NAME, "IC_PDBI", "Clearing all mailbox locations for db item %s, itemInfo %s.", itemKey, itemInfo)
		itemInfo = ItemInfo.ClearInboxLocations (itemInfo)
		DB:Set (itemKey, itemInfo)
	end


	if self.cache[itemKey] then -- itemKey is in the cache

		local dbStackCount

		for locationCode, cacheStackCount in ItemInfo.GetLocationCodesAndStackCountsIter (self.cache[itemKey]) do -- loop through the cache itemInfo

			cacheStackCount = ToNumber (cacheStackCount)

--[[			-- Clear this mailID location in the itemInfo. Not certain this is necessary, since IODIDLSC should address the same item appearing in multiple attachments.

			if GetCurrentLocationCode () == "MO" then -- this is BAG_INBOX
				ItemInfo.SetLocationCodeStackCount (itemInfo, locationCode, 0)
			end
]]
			dbStackCount = ItemInfo.GetLocationCodeStackCount (itemInfo, locationCode)

--			if dbStackCount and dbStackCount > 0 then -- this item is in the db at this location
				Debug.Msg (3, ADDON_DEBUG_NAME, "IC_PDBI", "Processing location %s with db count %s and cache count %s.", locationCode, dbStackCount or "--", cacheStackCount)

				if dbStackCount ~= cacheStackCount then -- count mismatch; set it
					Debug.Msg (4, ADDON_DEBUG_NAME, "IC_PDBI", "Setting %s in db location %s to count %s.", LinkUtils.StripItemLink (itemKey), locationCode, cacheStackCount)
--					DB:Set (itemKey, ItemInfo.SetLocationCodeStackCount (itemInfo, locationCode, cacheStackCount))

					itemInfo = ItemInfo.SetLocationCodeStackCount (itemInfo, locationCode, cacheStackCount)
				end -- dbStackCount ~= cacheStackCount

				-- remove from cache

--				Debug.Msg (1, ADDON_DEBUG_NAME, "IC_PDBI", "Removing %s from itemCache itemInfo %s.", LinkUtils.StripItemLink (itemKey), self.cache[itemKey] or "--")
--				self.cache[itemKey] = ItemInfo.SetLocationCodeStackCount (self.cache[itemKey], locationCode, 0)

--			end -- if dbStackCount

--			dbStackCount = nil -- shouldn't need this because of reassignment at top of loop

		end -- for locationCode

		DB:Set (itemKey, itemInfo)

		self.cache[itemKey] = nil

	elseif self.locationCode ~= "M0" and ItemInfo.GetLocationCodeStackCount (itemInfo, self.locationCode) then -- not in the cache at this location, delete from db

		local updatedItemInfo = ItemInfo.SetLocationCodeStackCount (itemInfo, self.locationCode, 0)

		Debug.Msg (4, ADDON_DEBUG_NAME, "IC_PDBI", "Clearing %s in db location %s with itemInfo %s.", LinkUtils.StripItemLink (itemKey), ToString (self.locationCode), tostring (updatedItemInfo))

		if updatedItemInfo then
			DB:Set (itemKey, updatedItemInfo)
		else
			DB:Clear (itemKey)
		end

	end -- if self.cache[itemKey]

--	if currentBagID == BAG_INBOX then currentLocationCode = nil end


end -- ProcessDBItemForItemCache

--					Debug.Msg (3, "PDBIFIC: Item %s is in db but not itemCache. Removing from db.", itemKey)
--					DB_Set (itemKey, ItemInfo.SetLocationCodeStackCount (itemInfo, locationCode, 0), true)


-- The only items left in the item cache should be items that were not already
-- in the db. For each item in the cache, we add it to the db.

local function ProcessCacheItem (cacheKey, cacheItemInfo)

	Debug.Msg (2, ADDON_DEBUG_NAME, "PICI", "Processing itemKey %s with itemCache itemInfo %s.", cacheKey, cacheItemInfo)

	for locationCode, cacheStackCount in ItemInfo.GetLocationCodesAndStackCountsIter (cacheItemInfo) do -- loop through the itemCache itemInfo
		DB:Set (cacheKey, ItemInfo.SetLocationCodeStackCount (DB:Get (cacheKey), locationCode, cacheStackCount), true)
--		Debug.Msg (3, "PICI: Removing %s from itemCache.", cacheKey)
--		self.cache[cacheKey] = ItemInfo.SetLocationCodeStackCount (self.cache[cacheKey], locationCode, 0)

	end

end

--[[
function ItemCache:ProcessDBItemForMailCache (itemKey, itemInfo)
	Debug.Msg (2, ADDON_DEBUG_NAME, "PDBIFMC", "Clearing mailbox location for db item %s.", LinkUtils.StripItemLink (itemKey))
	itemInfo = ItemInfo.ClearInboxLocations (itemInfo)
	self.ProcessDBItem (itemKey, itemInfo)
end
]]

-- Write the cache to the database. When this function is done, the itemCache is no longer usable and a new instance must be created.

function ItemCache:Process ()

--	Debug.Msg (2, "PIC: Called with bagID: %s, itemCache: %s.", bagID or "--", itemCache or "--")

	Debug.Msg (3, ADDON_DEBUG_NAME, "IC_P", "Called with bagID %d.", self.bagID)
	Debug.Msg (1, ADDON_DEBUG_NAME, "IC_P", "Processing item cache for locationCode %s. Cache size: %d", self.locationCode or "--", NonContiguousCount (self.cache))

	local function ProcessDBItem (itemKey, itemInfo)
		self:ProcessDBItem (itemKey, itemInfo)
	end
--[[
	local function ProcessCacheItem ()
		self:ProcessCacheItem (itemKey, itemInfo)
	end
]]
	local function Clear ()
		Debug.Msg (3, ADDON_DEBUG_NAME, "IC_P_C", "Clearing item cache.")
		ZO_ClearTable (self.cache)
		self.cache = nil
	end

--d (self.cache)
if self.bagID == BAG_INBOX then d (self.cache) end

	if self.asyncTask then
		Debug.Msg (3, ADDON_DEBUG_NAME, "IC_P", "Processing existing database for item cache using async.")
		self.asyncTask:For (pairs (DB.db)): Do (ProcessDBItem)
--			function (itemKey, itemInfo)
--				Debug.Msg (2, "PIC async itemCache: itemKey %s; itemInfo %s.", itemKey, itemInfo)
--			end
--		)
		:Then (Debug.Msg (3, ADDON_DEBUG_NAME, "IC_P", "Processing remaining item cache using async."))
		:For (pairs (self.cache)): Do (ProcessCacheItem)
		:Finally (Clear)
	else
		Debug.Msg (3, ADDON_DEBUG_NAME, "IC_P", "Processing existing database for item cache without async.")
		for dbKey, itemInfo in pairs (DB.db) do
--			Debug.Msg (1, "PIC sync itemCache: itemKey %s; itemInfo %s.", itemKey, itemInfo)
			self:ProcessDBItem (dbKey, itemInfo)
		end
		Debug.Msg (3, ADDON_DEBUG_NAME, "IC_P", "Processing remaining item cache without async.")
		for itemKey, itemInfo in pairs (self.cache) do
			ProcessCacheItem (itemKey, itemInfo)
		end

		Clear ()
	end

end


LUXHRYS.ItemCache = ItemCache




-- Returns stack count of an item in all locations tracked by this add-on,
-- excluding the current character for backpack and equipped items.
-- TODO: Implement matching on same ID but different links, depending on settings.

--[[ TODO: SHOULD NOW BE DEPRECATED
function DBLookup.GetExtendedStackCount (itemKey)

	itemKey = GetItemKey (itemKey)

	Debug.Msg (2, "GESC: Called with itemKey %s.", LinkUtils.StripItemLink (itemKey))


	local itemInfo = DB:Get (itemKey)

	Debug.Msg (3, "GESC: Database contains itemInfo %s.", ToString (itemInfo))

	return ItemInfo.GetExtendedStackCounts (itemInfo)

end
--XI.GetExtendedStackCount = XI_GetExtendedStackCount



--local function XI_GetExtendedBagList (bagID)
--end
]]


-- ================ [ Vault and Coffer Database Functions ] ================ --

local function GetBestFurnitureCategoryDescription (itemData)

	local categoryType

	-- TODO: This should only seperate into furnishing categories if location tab is on placed furniture or vault, or if filter is set to furniture only. DONE: Added arg to indicate whether furniture should be subdivided.

	if itemData.itemType == ITEMTYPE_FURNISHING then

		itemData.isPlaceableFurniture = IsItemLinkPlaceableFurniture (itemData.itemLink)

		local furnitureDataID = GetItemLinkFurnitureDataId (itemData.itemLink)

		if furnitureDataID ~= 0 then
			local categoryID = GetFurnitureDataCategoryInfo (furnitureDataID)
			if categoryID then
				local categoryName = GetFurnitureCategoryInfo (categoryID)
				if categoryName ~= "" then
					return categoryName
				end
			end
		end
	end

	return nil

end


-- There are some performance considerations here. This is used to generate the master reference list for the Vault and Coffer list screen, in which the displayed list filters this to get the shorter list without having to loop the entire database and gather all this data again. It's run during deferred initialization and then every time a change has happened (dirtied). This should be the more costly (in terms of time, to make the displayed lists snappier) list to generate but we need to limit memory usage.


-- TODO: To reduce size, make sure we use everything that we set.

local function GetItemData (itemKey, itemInfo, uniqueId)

	local itemData = {}

	itemData.itemKey = itemKey

	if type (itemKey) == "number" then
		itemData.itemID = itemKey
		itemData.itemLink = LinkUtils.CreateSimpleItemLinkFromItemID (itemData.itemID)
	else
		itemData.itemLink = itemKey
		itemData.itemID = GetItemLinkItemId (itemData.itemLink)
	end

	itemData.name = zo_strformat (SI_TOOLTIP_ITEM_NAME, GetItemLinkName (itemData.itemLink))
	itemData.text = itemData.name

	-- TODO: I am hoping that this uniqueId is not going to be a problem, otherwise we'll need to get it from the original inventory scan.

	itemData.uniqueId = ADDON_DEBUG_NAME .. uniqueId

	itemData.displayQuality = GetItemLinkDisplayQuality (itemData.itemLink)

	itemData.icon = GetItemLinkIcon (itemData.itemLink)
--		itemData.iconFile = itemData.icon

	itemData.actorCategory = GetItemLinkActorCategory (itemData.itemLink)
	itemData.itemType, itemData.specializedItemType = GetItemLinkItemType (itemData.itemLink)
	itemData.equipType = GetItemLinkEquipType (itemData.itemLink)

	itemData.bestItemCategoryName = ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription (itemData)
	
	if itemData.itemType == ITEMTYPE_FURNISHING then
		itemData.bestItemFurnishingCategoryName = GetBestFurnitureCategoryDescription (itemData)
	end

	return itemData

end


-- ============== [ Miscellaneous Database Lookup Functions ] ============== --


local DatabaseLookup = ZO_InitializingObject:Subclass ()


function DatabaseLookup:GetCharacterIDAlias (characterID)
	return DB.characterAliases[characterID] or nil
end


function DatabaseLookup:GetOrCreateCharacterIDAlias (characterID)
	if type (characterID) == string then characterID = ToNumber (characterID) end
	if DB.characterAliases[characterID] then return DB.characterAliases[characterID] end
	local highestExistingAlias = 0
	for characterID, alias in pairs (DB.characterAliases) do
		highestExistingAlias = alias > highestExistingAlias and alias or highestExistingAlias
	end
	DB.characterAliases[characterID] = highestExistingAlias + 1
	return DB.characterAliases[characterID]
end


function DatabaseLookup:GetCharacterAliasID (characterAlias)
	for characterID, alias in pairs (DB.characterAliases) do
		if alias == characterAlias then return characterID end
	end
	return nil
end


function DatabaseLookup.GetItemInfo (itemKey)
	Debug.Msg (2, ADDON_DEBUG_NAME, "DL_GII", "Called. itemKey is %s.", tostring (itemKey))
	local returnValue = DB:Get (itemKey)
	Debug.Msg (3, ADDON_DEBUG_NAME, "DL_GII", "Returning itemInfo %s.", tostring (returnValue))
--	return DB:Get (itemKey)
	return returnValue
end

function DatabaseLookup.GetLastUpdateTime ()
	return DB.lastUpdate
end

-- TODO: Implement async
-- TODO: Implement in-menu refresh of master reference list, then update displayed list next time it is generated.

function DatabaseLookup:GenerateInventoryListItemData (inventoryList, callbackFunction)

	Debug.Msg (2, ADDON_DEBUG_NAME, "DL_GILID", "Called.")


	-- It's much faster and memory-efficient to clear and reuse a table than to create a new one.

	assert (inventoryList and type (inventoryList == "table"), "[" .. ADDON_DEBUG_NAME .. "DL_GILID] CRIT: No data table submitted.")

	ZO_ClearNumericallyIndexedTable (inventoryList)

	local uniqueId = 0

	local function BuildItemData (dbKey, itemInfo)
		uniqueId = uniqueId + 1
--		TableInsert (inventoryList, GetItemData (DBKeyToItemKey (dbKey), itemInfo, uniqueId))
		inventoryList[#inventoryList + 1] = GetItemData (DBKeyToItemKey (dbKey), itemInfo, uniqueId)
	end

	if self.asyncTask then
		self.asyncTask:For (pairs (DB.db)):Do (BuildItemData)
		:Finally (callbackFunction)
	else
		for dbKey, itemInfo in pairs (DB.db) do
			BuildItemData (dbKey, itemInfo)
		end
		callbackFunction ()
	end

	Debug.Msg (2, ADDON_DEBUG_NAME, "DL_GILID", "Completed.")


end


function DatabaseLookup:Initialize ()
	if OPTIONS.async.useAsync then
		self.asyncTask = Async.Initialize (ADDON_DEBUG_NAME .. "_DL")
	end
end


-- =========================== [ Initialization ] ========================== --


-- Some "classes" rely on OPTIONS or use saved variables, which cannot be
-- initialized until EVENT_ADD_ON_LOADED.

local function InitializeDatabase (_, addonName)
	if addonName and addonName == ADDON_NAME then
		Debug.Msg (1, ADDON_DEBUG_NAME, "ID", "Initializing %s.", ADDON_CHUNK_NAME)

		OPTIONS = LUXHRYS.OPTIONS
		DB = Database:New ()

		LUXHRYS.DBLOOKUP = DatabaseLookup:New ()

		EVENT_MANAGER:UnregisterForEvent (ADDON_DEBUG_NAME, EVENT_ADD_ON_LOADED)

		Debug.Msg (1, ADDON_DEBUG_NAME, "ID", "%s initialization complete.  DB: %s.  DL: %s.", ADDON_CHUNK_NAME, DB ~= nil and "successful" or "failed", LUXHRYS.DBLOOKUP ~= nil and "successful" or "failed")
	end
end


EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_ADD_ON_LOADED, InitializeDatabase)


--[[

local ItemCache = XLPUS.ItemCache
local DBLOOKUP = XLPUS.DBLOOKUP

]]