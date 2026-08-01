
--Register LAM with LibStub
local MAJOR, MINOR = "LibSortIt-1.0", 4
local libsi, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not libsi then return end	--the same or newer version of this lib is already loaded into memory 

-------------------------------------------
--  Debug Library  --
-------------------------------------------
LibSortIt = {}
local tLibSortItPacks = {}	
local GAME_SORTKEYS = ZO_Inventory_GetDefaultHeaderSortKeys()


-------------------------------------------
--  Initialize Stuff  --
-------------------------------------------
-- Turn this on to have debug messages put into LibSortIt.debug[YourAddonName]
local debugMode = true
if debugMode then
	-- This gives access to the LibSortIt table that holds all addon->Data(callback, sortKeys, sortPacks, ect...)
	-- So you can see how everything is structured. In a few places it will even 
	-- print debug messages to LibSortIt.Addons[YourAddon].debug
	-- mainly its just covering a few errors that involve creating SortKeys & SortPacks
	-- YOU SHOULDN'T BE MESSING WITH ANY OF IT, but you can use this to check and make sure
	-- that your keys, packs, data, whatever is loaded properly. If your trying to create a pack
	-- and its not showing up, you can check the table to see if it was loaded or not, ect...
	LibSortIt.Addons = tLibSortItPacks
	
	-- This is the GAMES SortKey table, do not mess with this. But This opens it up
	-- so you can see it in the debug window. Do note SortKeys are only put into this
	-- table by SortIt when the keys are used, when a sortPackage is set, so you wont
	-- find all of your keys here, only current keys in use (or possibly keys already used 
	-- during the currently loaded game).
	LibSortIt.GAME_SORTKEYS = GAME_SORTKEYS
end

------------------------------------------------------------------
--  Debug Msg Function											--
------------------------------------------------------------------
local function DebugMsg(_AddonName, _Msg)
	if not debugMode then return end
	if not tLibSortItPacks[_AddonName]["debug"] then
		tLibSortItPacks[_AddonName]["debug"] = {}
	end
	table.insert(tLibSortItPacks[_AddonName]["debug"], _Msg)
end

------------------------------------------------------------------
--  Set Up New Addon Info										--
-- 	Creates necessary tables & info for each addon				--
------------------------------------------------------------------
local function SetUpNewAddonInfo(_AddonName, _Callback)
	-- Setup a table to hold information about this addon
	if not tLibSortItPacks[_AddonName] then
		tLibSortItPacks[_AddonName] = {
			["debug"] = {},
			callback = _Callback,
			curPackName = {
				[INVENTORY_BACKPACK] = "",
				[INVENTORY_BANK] = "",
				[INVENTORY_GUILD_BANK] = "",
			},
			sortKeys = {},
			sortPacks = {},
		}
	end
end

--**************************************************************--
--  Functions handling the Insertion of Sort Key Data			--
--**************************************************************--

------------------------------------------------------------------
--[[ 	Optional Function: 	Update Bag Data						--
--	Can be called from EVENT_INVENTORY_SINGLE_SLOT_UPDATE 		--
--	Updates Sort data on inventory items, for new/moved items 	--
--	If you have some reason to require the data at times other	--
--	than at when LibSortIt sorts								--]]
------------------------------------------------------------------
function libsi:UpdateBagData( _iBagId, _iSlotId, _Callback)
	if not (_iBagId and _iSlotId) then end
	if type(_Callback) ~= "function" then return false end
	
	local iItemType = GetItemType(_iBagId,_iSlotId)
	-- BAG_WORN can't be sorted or Item no longer exists (moved, destroyed, or sold)
	if ((_iBagId == BAG_WORN) or (iItemType == ITEMTYPE_NONE)) then return end
	
	-- Convert the bag to an inventoryType, and grab the slot
	local iInventory = PLAYER_INVENTORY.bagToInventoryType[_iBagId]
	local tSlot 	 = PLAYER_INVENTORY.inventories[iInventory].slots[_iSlotId]
	
	if not tSlot then 
		PLAYER_INVENTORY:RefreshAllInventorySlots(iInventory)
		tSlot 	 = PLAYER_INVENTORY.inventories[iInventory].slots[_iSlotId]
	end
	
	if not tSlot then 
		table.insert(LibSortIt, "Still nil")
		return
	end
	-- Call the Callback to get the data to be inserted into the slot
	
	local tSortKeys 	= _Callback(_iBagId, _iSlotId)
	for key, data in pairs(tSortKeys) do
		if _iBagId == nil then
			table.insert(LibSortIt, "_iBagId is nil")
		elseif _iSlotId == nil then
			table.insert(LibSortIt, "slot  is nil")
		elseif key == nil  then
			table.insert(LibSortIt, "key is nil")
		elseif data == nil then
			table.insert(LibSortIt, "dat is nil")
		elseif tSlot == nil then
			table.insert(LibSortIt, "tSlot is nil")
			table.insert(LibSortIt, "bag: ".._iBagId..", slot: ".._iSlotId)
		end
		tSlot[key] = data
	end
end

------------------------------------------------------------------
--[[  Insert Bag Data											--
--	Used to initialize all SortKey data for an inventoryType	--
--	_Callback function should return a table containing Sort	--
--	Key data for all custom SortKeys							--]]
------------------------------------------------------------------
local function InsertBagData(_iInventory, _Callback)
	-- Banks do not populate until a few ms after their open event fires
	-- Refresh slots to make sure they are populated before attempting to insert data.
	-- Also prevents problems if backpack hasn't populated as addon loads
	--*************************************************************************--
	-- THIS IS CAUSING PROBLEMS WITH THE GUILD BANK, THAT DAMN SPINNING WHEEL WHERE IT DOES NOT UPDATE THE ITEMS FAST ENOUGH AND SOMETIMES IT DOESN'T UPDATE THEM AT ALL...the refresh is comming back with TSLOTS = {} empty.
	--[[
	if _iInventory ~= INVENTORY_GUILD_BANK then 
		PLAYER_INVENTORY:RefreshAllInventorySlots(_iInventory)
	end
	--]]
	--*************************************************************************--
	
	--local iInventory 	= PLAYER_INVENTORY.inventories[_iInventory]
	local tSlots 		= PLAYER_INVENTORY.inventories[_iInventory].slots
	
	if not tSlot then 
		-- THIS IS CAUSING PROBLEMS WITH THE GUILD BANK, THAT DAMN SPINNING WHEEL WHERE IT DOES NOT UPDATE THE ITEMS FAST ENOUGH AND SOMETIMES IT DOESN'T UPDATE THEM AT ALL...the refresh is comming back with TSLOTS = {} empty.
		if _iInventory ~= INVENTORY_GUILD_BANK then 
			PLAYER_INVENTORY:RefreshAllInventorySlots(_iInventory)
			tSlot 	 = PLAYER_INVENTORY.inventories[_iInventory].slots[_iSlotId]
		end
	end
	
	if not tSlots then return end
	
	-- Call the Callback to get the data to be inserted into the slot
	for slotId,tSlotData in pairs(tSlots) do
		local tSortKeys 	= _Callback(tSlotData.bagId, slotId)
		for sSortKeyName, sSortKeyData in pairs(tSortKeys) do
			tSlotData[sSortKeyName] = sSortKeyData
		end
	end
end

------------------------------------------------------------------
-- 	Optional Function: LibSortIt calls this on its own when 	--
--[[	a sort is applied Data is inserted during each sort		--
--	Can be used if you need data inserted for other purposes	--
-- 	at other times												--
------------------------------------------------------------------
--  Insert SortKey Data											--
--	Should only be called once on Addon Initialize()			--
--	Initialize/insert data for all inventory types 				--
--	(except Inv quest of course)								--]]
------------------------------------------------------------------
function libsi:InsertSortKeyData(_iInventory, _Callback)
	-- Make sure its a valid inventory
	if (_iInventory ~= INVENTORY_BACKPACK) and (_iInventory ~= INVENTORY_BANK) 
	and (_iInventory ~= INVENTORY_GUILD_BANK) then return false end
	if type(_Callback) ~= "function" then return false end
	
	-- Initialize data for each inventoryType
	InsertBagData(_iInventory, _Callback)
end

--**********************************************************--
--  UTILITY FUNCTIONS										--
--**********************************************************--
----------------------------------------------------------------------
-- Should Reverse Tiebreaker										--
--[[ Determines if the tiebreaker should be reversed by comparing	--
-- current order (ASC or Desc) and next keys sort order				--]]
-----------------------------------------------------------------------
local function ShouldReverseTiebreaker(_bCurrentOrder, _bNextOrder)
	if _bCurrentOrder == _bNextOrder then
		 return false
	else
		return true
	end
end

----------------------------------------------------------------------
-- Should Reverse Tiebreaker										--
-- Checks Key data in a key table to make sure it is ok				--
-----------------------------------------------------------------------
local function IsKeyDataOk(_AddonName, _tKeyTable)
	local tCallbackReturnedKeys = tLibSortItPacks[_AddonName].CallbackReturnedKeys
	if not (_tKeyTable and _tKeyTable.displayName and _tKeyTable.key) then 
		DebugMsg(_AddonName, "Data missing from one of your key tables")
		return false 
	end
	if type(_tKeyTable.isNumeric) ~= "boolean" then 
		DebugMsg(_AddonName, "Key: ".._tKeyTable.key..", isNumeric property is not boolean. It will not be created.")
		return false 
	end
	-- If key not returned by callback function
	if not tCallbackReturnedKeys[_tKeyTable.key] then 
		DebugMsg(_AddonName, "Key: ".._tKeyTable.key.." is not returned by your callback function. It will not be created.")
		return false 
	end
	return true
end


--------------------------------------------------------------------------
-- CheckAllKeys															--
--[[ Loops through checking that all available sortKeys are returned	--
--	By the callback function, if any SortKey is no longer returned		--
--	It removes it from the available tables, then it loops through		--
--	Every SortPack & sees if any SortPacks have keys that no longer		--
--	Exist, if so it removes the pack as well							--]]
-----------------------------------------------------------------------
local function CheckAllKeys(_AddonName)
	local tReturnedKeys = tLibSortItPacks[_AddonName].CallbackReturnedKeys
	local tAddonSortKeys = tLibSortItPacks[_AddonName].sortKeys
	local tAddonSortPacks = tLibSortItPacks[_AddonName].sortPacks
	
	for SortKey in pairs(tAddonSortKeys) do
		if not tReturnedKeys[SortKey] then
			DebugMsg(_AddonName, SortKey..": is not returned by your callback function. The key has been removed.")
			tAddonSortKeys[SortKey] = nil
		end
	end
	for k1, PackTable in pairs(tAddonSortPacks) do
		local bAllKeysFound = true
		for k2, KeyTable in pairs(PackTable.sortKeys) do
			if not tReturnedKeys[KeyTable.key] then
				bAllKeysFound = false
			end
		end
		if not bAllKeysFound then
			DebugMsg(_AddonName, "Sort Pack: "..tAddonSortPacks[k1].displayName..", contains sortKeys that no longer exist. The SortPack has been removed.")
			tAddonSortPacks[k1] = nil
		end
	end
end

----------------------------------------------------------------------
--  Debug Function: Save All Addon Keys								--
--[[ 	Saves All addon keys returned by the callback function		--
--	So we can check to see if all used keys will be returned		--]]
-----------------------------------------------------------------------
local function SaveReturnedSortKeys(_AddonName, _Callback)
	-- Clear the table in case someone tries to change the callback at runtime
	tLibSortItPacks[_AddonName].CallbackReturnedKeys = {}
	local tCallbackReturnedKeys = tLibSortItPacks[_AddonName].CallbackReturnedKeys
	
	-- Get SortKeys returned by callback
	local tData 	= _Callback(1, 1342)
	local tSortKeys = {}
	
	for sKeyName, KeyData in pairs(tData) do
		-- Set to true for boolean check when we look to see if key exists
		tCallbackReturnedKeys[sKeyName] = true
	end
	
	table.sort(tCallbackReturnedKeys)
	return true
end

-- Checks to see if a SortKey exists for this addon
function libsi:DoesSortKeyExist(_AddonName, _sSortKey)
	if not (tLibSortItPacks[_AddonName] and tLibSortItPacks[_AddonName].sortKeys) then return end
	local tPackKeys = tLibSortItPacks[_AddonName].sortKeys
	if tPackKeys[_sSortKey] then
		return true
	end
	return false
end

-- Checks to see if a SortKey exists for this addon
function libsi:DoesSortPackNameExist(_AddonName, _sSortPackName)
	if not (tLibSortItPacks[_AddonName] and tLibSortItPacks[_AddonName].sortPacks) then return end
	if not _sSortPackName then return end
	local tSortPacks = tLibSortItPacks[_AddonName].sortPacks
	
	for k,v in pairs(tSortPacks) do
		if v.displayName == _sSortPackName
			then return true
		end
	end
	return false
end

-- Called when a sortPack is deleted. Checks to see if it is the current sortPack in any of the
-- Inventories & if so, changes to the next sortPack & saves the new current sortPack for that inventory
local function CheckCurrentSortPackForRemoval(_AddonName, _sDisplayName)
	if not (tLibSortItPacks[_AddonName] and tLibSortItPacks[_AddonName].curPackName) then return end
	if not _sDisplayName then return end
	local curBackpackSortPack = tLibSortItPacks[_AddonName].curPackName[INVENTORY_BACKPACK]
	local curBankSortPack = tLibSortItPacks[_AddonName].curPackName[INVENTORY_BANK]
	local curGuildSortPack = tLibSortItPacks[_AddonName].curPackName[INVENTORY_GUILD_BANK]
	
	if _sDisplayName == curBackpackSortPack then
		local nextSortPack = libsi:GetNextSortPack(_AddonName, _sDisplayName)
		tLibSortItPacks[_AddonName].curPackName[INVENTORY_BACKPACK] = nextSortPack.displayName
		
	elseif _sDisplayName == curBankSortPack then
		local nextSortPack = libsi:GetNextSortPack(_AddonName, _sDisplayName)
		tLibSortItPacks[_AddonName].curPackName[INVENTORY_BANK] = nextSortPack.displayName
		
	elseif _sDisplayName == curGuildSortPack then
		local nextSortPack = libsi:GetNextSortPack(_AddonName, _sDisplayName)
		tLibSortItPacks[_AddonName].curPackName[INVENTORY_GUILD_BANK] = nextSortPack.displayName
	end
end

-- Delete a SortPack by its SortPack _sDisplayName
function libsi:RemoveSortPack(_AddonName, _sDisplayName)
	if not (tLibSortItPacks[_AddonName] and tLibSortItPacks[_AddonName].sortPacks) then return end
	if not _sDisplayName then return end
	local tSortPacks = tLibSortItPacks[_AddonName].sortPacks
	
	for key, SortPack in pairs(tSortPacks) do 
		if SortPack.displayName == _sDisplayName then
			CheckCurrentSortPackForRemoval(_AddonName, _sDisplayName)
			table.remove(tLibSortItPacks[_AddonName].sortPacks, key)
			return
		end
	end
end

-- If you made the keys you should know if its numeric, but LibSortIt
-- Uses this to look up the information, I figured no harm in leaving it accessible
-- if someone finds a good use for it.
function libsi:GetIsKeyNumeric(_AddonName, _KeyName)
	if not (tLibSortItPacks[_AddonName] and tLibSortItPacks[_AddonName].sortKeys[_KeyName]) then
		return 
	end
	return tLibSortItPacks[_AddonName].sortKeys[_KeyName].isNumeric
end





--**********************************************************--
--  GET DISPLAY NAME FUNCTIONS								--
--**********************************************************--

------------------------------------------------------------------
--  Get All Addon Sort Pack Display Names						--
------------------------------------------------------------------
function libsi:GetAllSortPackDisplayNames(_AddonName)
	if not tLibSortItPacks[_AddonName] then return end
	local tAddonPackDisplayNames = {}
	
	for iKey, tSortPackTable in pairs(tLibSortItPacks[_AddonName].sortPacks) do
		table.insert(tAddonPackDisplayNames, tSortPackTable.displayName)
	end
	table.sort(tAddonPackDisplayNames)
	return tAddonPackDisplayNames
end

------------------------------------------------------------------
--  Get All Addon Sort Key Display Names						--
------------------------------------------------------------------
function libsi:GetAllSortKeyDisplayNames(_AddonName)
	if not tLibSortItPacks[_AddonName] then  return end
	
	local tAddonKeyDisplayNames = {}
	
	for sSortKey, tSortKeyTable in pairs(tLibSortItPacks[_AddonName].sortKeys) do
		table.insert(tAddonKeyDisplayNames, tSortKeyTable.displayName)
	end
	table.sort(tAddonKeyDisplayNames)
	return tAddonKeyDisplayNames
end

------------------------------------------------------------------
--  Get Addon Sort Key Display Name								--
------------------------------------------------------------------
function libsi:GetSortKeyDisplayName(_AddonName, _sKeyName)
	if not (tLibSortItPacks[_AddonName] and tLibSortItPacks[_AddonName].sortKeys) then return end
	local tSortKeys = tLibSortItPacks[_AddonName].sortKeys
	if not tSortKeys[_sKeyName] then return end
	
	return tSortKeys[_sKeyName].displayName
end

--**********************************************************--
--  GET SORT PACK FUNCTIONS									--
--**********************************************************--
--[[ Basically same as GetNextSortPack except it takes a display name
-- Searches for the Next sort pack by display name. If already at the last 
-- sortPack in the table, returns the first sortPack, or nil
--]]
function libsi:GetNextSortPack(_AddonName, _sDisplayName)
	if not (tLibSortItPacks[_AddonName] and tLibSortItPacks[_AddonName].sortPacks) then return end
	if not _sDisplayName then return end
	local tSortPacks = tLibSortItPacks[_AddonName].sortPacks
	
	for k, SortPack in ipairs(tSortPacks) do
		if SortPack.displayName == _sDisplayName then
			if tSortPacks[k+1] then
				return tSortPacks[k+1]
			else
				return tSortPacks[1]
			end
		end
	end
	-- If its not found
	return tSortPacks[1]
end

function libsi:GetCurSortPack(_AddonName, _sDisplayName)
	if not (tLibSortItPacks[_AddonName] and tLibSortItPacks[_AddonName].sortPacks) then return end
	if not _sDisplayName then return end
	local tSortPacks = tLibSortItPacks[_AddonName].sortPacks
	
	for k, SortPack in ipairs(tSortPacks) do
		if SortPack.displayName == _sDisplayName then
			return tSortPacks[k]
		end
	end
	-- If its not found
	return tSortPacks[1]
end

function libsi:GetSortPackStartingOrder(_AddonName, _sDisplayName)
	if not (tLibSortItPacks[_AddonName] and tLibSortItPacks[_AddonName].sortPacks) then return end
	if not _sDisplayName then return end
	local tSortPacks = tLibSortItPacks[_AddonName].sortPacks
	
	for k, SortPack in ipairs(tSortPacks) do
		if SortPack.displayName == _sDisplayName then
			return SortPack.startAscOrder
		end
	end
end
	
function libsi:GetCurSortPackName(_AddonName, _iInventory)
	if not (tLibSortItPacks[_AddonName] and tLibSortItPacks[_AddonName].curPackName) then return end
	if not _iInventory then return end
	
	return tLibSortItPacks[_AddonName].curPackName[_iInventory]
end

function libsi:GetNextSortPackName(_AddonName, _iInventory)
	if not (tLibSortItPacks[_AddonName] and tLibSortItPacks[_AddonName].sortPacks) then return end
	if not (_iInventory and tLibSortItPacks[_AddonName].curPackName[_iInventory]) then return end
	local sCurPackName = tLibSortItPacks[_AddonName].curPackName[_iInventory]
	local tSortPacks = tLibSortItPacks[_AddonName].sortPacks
	
	for k, SortPack in ipairs(tSortPacks) do
		if SortPack.displayName == sCurPackName then
			if tSortPacks[k+1] then
				return tSortPacks[k+1].displayName
			else
				return tSortPacks[1].displayName
			end
		end
	end
end
--**********************************************************--
--  KEY FUNCTIONS											--
--**********************************************************--

------------------------------------------------------------------
--  Get All Addon Sort Key Names								--
------------------------------------------------------------------
function libsi:GetAddonSortKeyNames(_AddonName)
	if not tLibSortItPacks[_AddonName] then return end
	
	local tAddonKeyNames = {}
	for sSortKeyName in pairs(tLibSortItPacks[_AddonName].sortKeys) do
		table.insert(tAddonKeyNames, sSortKeyName)
	end
	table.sort(tAddonKeyNames)
	return tAddonKeyNames
end

------------------------------------------------------------------
--  Get Addon Sort Key Name	 (from displayName)					--
------------------------------------------------------------------
function libsi:GetSortKeyNameFromDisplayName(_AddonName, _sKeyDisplayName)
	if not (tLibSortItPacks[_AddonName] and tLibSortItPacks[_AddonName].sortKeys) then return end
	if not _sKeyDisplayName then return end
	local tAddonKeys = tLibSortItPacks[_AddonName].sortKeys
	
	for SortKey, SortKeyTable in pairs(tAddonKeys) do
		if SortKeyTable.displayName == _sKeyDisplayName then
			return SortKey
		end
	end
	DebugMsg(_AddonName, "Key not found for key display name: ".._sKeyDisplayName)
end

--[[ Get All sortPack Keys for a given SortPack _sDisplayName
--	Returns The sortKey table for a SortPack
--	Contains all of the SortKeys for that SortPack --]]
function libsi:GetSortPackSortKeys(_AddonName, _sDisplayName)
	if not (tLibSortItPacks[_AddonName] and tLibSortItPacks[_AddonName].sortKeys) then return end
	if not _sDisplayName then return end
	local tSortPacks = tLibSortItPacks[_AddonName].sortPacks
	
	for key, SortPack in pairs(tSortPacks) do
		if SortPack.displayName == _sDisplayName then
			return SortPack.sortKeys
		end
	end
end

function libsi:GetPacksFirstSortKey(_AddonName, _sDisplayName)
	if not (tLibSortItPacks[_AddonName] and tLibSortItPacks[_AddonName].sortKeys) then return end
	if not _sDisplayName then return end
	local tSortPacks = tLibSortItPacks[_AddonName].sortPacks
	
	for key, SortPack in pairs(tSortPacks) do
		if SortPack.displayName == _sDisplayName then
			return SortPack.sortKeys[1].key
		end
	end
end

--**********************************************************--
--  SORT CHANGE FUNCTIONS									--
--**********************************************************--

------------------------------------------------------------------
--[[  Change Sort:  By Sort SortPack _sDisplayName 				 --
-- 	This may not have been the best way to handle this, but the --
-- 	Reason I'm setting the ZO_Inventory_GetDefaultHeaderSortKey --
--	Here is because I'm allowing different packages to use the 	--
--	same SortKeys with different properties (tiebreakers/order)	--
--	Rather than forcing addons to create a different SortKey 	--
--	name for every possible configuration/use of the SortKey, 	--
--	The keys are saved in packages by LibSortIt & when a sort 	--
--	is chosen we look up the pack & keys and set the keys the	--
--	way that this pack wants it									--]]
------------------------------------------------------------------
function libsi:ChangeSort(_AddonName, _sDisplayName, _iInventory, _SortOrder)
	if not (tLibSortItPacks[_AddonName] and tLibSortItPacks[_AddonName].sortPacks) then return end
	
	-- Make sure its a valid inventory
	if (_iInventory ~= INVENTORY_BACKPACK) and (_iInventory ~= INVENTORY_BANK) 
	and (_iInventory ~= INVENTORY_GUILD_BANK) then return end
	
	-- ensure that the needed sortKey data is there
	self:InsertSortKeyData(_iInventory, tLibSortItPacks[_AddonName].callback)
	-- need to change this to display Name
	local tPackKeys = self:GetSortPackSortKeys(_AddonName, _sDisplayName)
	
	if not tPackKeys then return end -- SortPack does not exist
	
	for i = 1, #tPackKeys do
		-- Set Key the way this package wants it
		GAME_SORTKEYS[tPackKeys[i].key] = {
			isNumeric = tPackKeys[i].isNumeric, 
			tiebreaker = tPackKeys[i].tiebreaker, 
			reverseTiebreakerSortOrder = tPackKeys[i].reverseTiebreakerSortOrder,
		}
	end
	
	-- Grab the inventory & set the currentSortKey
	local inventory 	 = PLAYER_INVENTORY.inventories[_iInventory]
	tLibSortItPacks[_AddonName].curPackName[_iInventory] = _sDisplayName
	
	-- Change the sort to the First Key in the SortPack
	PLAYER_INVENTORY:ChangeSort(tPackKeys[1].key, _iInventory, _SortOrder)
end

----------------------------------------------------------------------------------------------------------------------
--[[ Change Pack																									--
-- This does everything that libsi:ChangeSort does except the actual inventory sort call							--
-- It updates the callback info for each item in the inventory, and sets up the new sortKeys						--
-- in the game for use, and saves the sortPack as the currently active sortPack for the given inventory				--
-- BUT does NOT change the sort. This might not seem that useful, but if someone wants to hook into					--
-- the sortHeaderGroups onHeaderClicked event, like I did for my SortIt addon, they may want to do all of this		--
-- but yet let the game handle the actual sort call for the inventory, so it keeps all of the sortHeaderGroup 		--
-- info up to date for them.																						--]]
----------------------------------------------------------------------------------------------------------------------
function libsi:ChangePack(_AddonName, _sDisplayName, _iInventory)
	if not (tLibSortItPacks[_AddonName] and tLibSortItPacks[_AddonName].sortPacks) then return end
	if not _sDisplayName then return end
	
	-- Make sure its a valid inventory
	if (_iInventory ~= INVENTORY_BACKPACK) and (_iInventory ~= INVENTORY_BANK) 
	and (_iInventory ~= INVENTORY_GUILD_BANK) then return end
	
	-- ensure that the needed sortKey data is there
	self:InsertSortKeyData(_iInventory, tLibSortItPacks[_AddonName].callback)
	-- need to change this to display Name
	local tPackKeys = self:GetSortPackSortKeys(_AddonName, _sDisplayName)
	
	if not tPackKeys then return end -- SortPack does not exist
	
	for i = 1, #tPackKeys do
		-- Set Key the way this package wants it
		GAME_SORTKEYS[tPackKeys[i].key] = {
			isNumeric = tPackKeys[i].isNumeric, 
			tiebreaker = tPackKeys[i].tiebreaker, 
			reverseTiebreakerSortOrder = tPackKeys[i].reverseTiebreakerSortOrder,
		}
	end
	
	-- Grab the inventory & set the currentSortKey
	local inventory 	 = PLAYER_INVENTORY.inventories[_iInventory]
	tLibSortItPacks[_AddonName].curPackName[_iInventory] = _sDisplayName
end


--**********************************************************--
--  SORT KEY & SORT PACK CREATION FUNCTIONS					--
-- Used by LibSortIt to create a single SortPack 			-- 
--**********************************************************--
local function CreateSortPack(_AddonName, _tPackTable)
	if not (_tPackTable.displayName and _tPackTable.sortKeys) then 
		DebugMsg(_AddonName, "CreateSortPacks: One of your sortPacks is missing a displayName or sortKeys table.")
		return false 
	end
	if not (_tPackTable.sortKeys[1] and type(_tPackTable.sortKeys[1].Asc) == "boolean") then 
		DebugMsg(_AddonName, "CreateSortPacks: One of your sortPacks is missing the first sortKey or the Asc property is not boolean.")
		return false 
	end
	-- hold in temp table, to make sure all keys/data is ok before adding it
	local tCurSortPack = {}
	tCurSortPack.sortKeys = {}
	tCurSortPack.displayName = _tPackTable.displayName
	-- Save starting order so we know which direction to start our sorts from
	tCurSortPack.startAscOrder = _tPackTable.sortKeys[1].Asc
	
	for iOrder, tKeyTable in ipairs(_tPackTable.sortKeys) do
		if not libsi:DoesSortKeyExist(_AddonName, tKeyTable.key) then 
			DebugMsg(_AddonName, "CreateSortPacks: In one of your sortPacks, the sortKey: "..tKeyTable.key.." is not returned by your callback function. The sortPack will not be created.")
			return false 
		end
		if type(tKeyTable.Asc) ~= "boolean" then return false end
		
		local temp = {}
		temp.key = tKeyTable.key
		temp.tiebreaker = libsi:GetSortKeyDisplayName(_AddonName, tKeyTable.key)
		temp.isNumeric = libsi:GetIsKeyNumeric(_AddonName, tKeyTable.key)
		
		if iOrder == #_tPackTable.sortKeys then
			temp.reverseTiebreakerSortOrder = ShouldReverseTiebreaker(tKeyTable.Asc, true)
			temp.tiebreaker = "name"
		else
			temp.reverseTiebreakerSortOrder = ShouldReverseTiebreaker(tKeyTable.Asc, _tPackTable.sortKeys[iOrder+1].Asc)
			temp.tiebreaker = _tPackTable.sortKeys[iOrder+1].key
		end
		-- Insert key into temp SortPack
		table.insert(tCurSortPack.sortKeys, temp)
	end
	-- We don't care if it exists, make a new one
	table.insert(tLibSortItPacks[_AddonName].sortPacks, tCurSortPack)
end

--[[ Addons call this to create SortPacks, we loop through each pack
-- Calling CreateSortPack to create each of the SortPacks
-- NOTE: You must call CreateSortKeys in your addon first 
-- If you do not create the SortKeys first the creation of SortPacks will
-- fail because LibSortIt checks to make sure that the keys exist or
-- else refuses to create the sortPack --]]
function libsi:CreateSortPacks(_AddonName, _tSortPacks)
	if not (_AddonName and _tSortPacks) then  
		DebugMsg(_AddonName, "CreateSortPacks Parameter: Invalid AddonName or SortPack Table.")
		return 
	end
	for k,PackTable in ipairs(_tSortPacks) do
		CreateSortPack(_AddonName, PackTable)
	end
end

--[[ SetUpNewAddonInfo: Sets up tables needed by LibSortIt
--	SaveReturnedSortKeys: Checks your Callback function & saves all keys returned by it
--	CheckAllKeys: Checks all sortKeys, the new sortKeys & ones already created
--	against the keys returned by your callback function to verify they all exist
--	Also checks all sortPacks to ensure they dont use any invalid keys, if so it deletes the sortPack
--]]
function libsi:CreateSortKeys(_AddonName, _Callback, _tKeyPacks)
	if not (_AddonName and _tKeyPacks) then 
		DebugMsg(_AddonName, "CreateSortKeys Parameter: Missing Addon name or Key table.")
		return false 
	end
	if type(_Callback) ~= "function" then 
		DebugMsg(_AddonName, "Your callback function, is not a function. CreateSortKeys aborted.")
		return false 
	end
	
	SetUpNewAddonInfo(_AddonName, _Callback)
	SaveReturnedSortKeys(_AddonName, _Callback)
	
	for k, tKeyTable in pairs(_tKeyPacks) do
		-- Allow them to overwrite keys, don't check if it exists
		if IsKeyDataOk(_AddonName, tKeyTable) then
			tLibSortItPacks[_AddonName].sortKeys[tKeyTable.key] = tKeyTable
		end
	end
	CheckAllKeys(_AddonName)
end

	
	
	
	
	
	
	
	
	
	
	
	
	