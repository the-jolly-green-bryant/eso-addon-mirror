
--[[ LuXhrys Modular Add-On System ]]
--[[ Written by Xhrysanth (PSNA) ]]
--[[ LibExtendedInventory ]]
--[[ LXICounts.lua ]]
--[[ LOAD ORDER FOURTH ]]


--[[ DISCLAIMER
This Add-on is not created by, affiliated with, or sponsored by, ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
]]

--[[ Information, attribution, copyright, and license:
This file is part of the core module for the LuXhrys add-on system for the Elder Scrolls Online.

This code chunk implements counting functions for the LuXhrys add-on system for the Elder Scrolls Online.

Written and copyright (c) 2026 by Xhrysanth (PSNA). License terms to be determined. Currently, and until this notice changes, all rights are reserved, except those that belong to ZeniMax Media Inc., which provides the API used by this software.
]]


--[[ ==========================> DECLARATIONS <=========================== ]]--


-- ========================= [ Dependency Check ] ========================== --


assert (LUXHRYS.LXI ~= nil, string.format ("[LuXhrysLXICt] CRIT: LuXhrysLXIO not available. This chunk will not be loaded."))


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

local ADDON_CHUNK_NAME = "Counts"
local ADDON_CHUNK_SHORT_NAME = "Ct"
local ADDON_DEBUG_NAME = ADDON_SYSTEM_NAME .. ADDON_MODULE_SHORT_NAME .. ADDON_CHUNK_SHORT_NAME


-- ===================== [ Localize Global Functions ] ===================== --


-------------------------------------------------------------------------------
--| C functions |--------------------------------------------------------------
-------------------------------------------------------------------------------


local GetItemLink = GetItemLink
local GetSlotStackSize = GetSlotStackSize
local GetPlacedFurnitureLink = GetPlacedFurnitureLink

local GetNumTradingHouseListings = GetNumTradingHouseListings
local GetNumBuybackItems = GetNumBuybackItems
local GetBagUseableSize = GetBagUseableSize

local GetNextGuildBankSlotId = GetNextGuildBankSlotId
local GetNextFurnitureVaultSlotId = GetNextFurnitureVaultSlotId
local GetNextMailId = GetNextMailId
local GetNextVirtualBagSlotId = GetNextVirtualBagSlotId
local GetNextPlacedHousingFurnitureId = GetNextPlacedHousingFurnitureId

local GetBuybackItemInfo = GetBuybackItemInfo
local GetBuybackItemLink = GetBuybackItemLink
local GetTradingHouseListingItemLink = GetTradingHouseListingItemLink
local GetTradingHouseListingItemInfo = GetTradingHouseListingItemInfo


-------------------------------------------------------------------------------
--| Native Lua functions |-----------------------------------------------------
-------------------------------------------------------------------------------


--local StrFormat = string.format
--local TableInsert = table.insert
--local TableRemove = table.remove


-------------------------------------------------------------------------------
--| ZOS Lua functions |--------------------------------------------------------
-------------------------------------------------------------------------------


--local HasUnlockedFurnitureVault = ZO_HousingEditorState.HasUnlockedFurnitureVault
--local ZO_LinkHandler_ParseLink = ZO_LinkHandler_ParseLink
--local zo_iconFormat = zo_iconFormat


-------------------------------------------------------------------------------
--| From LXICommon |-----------------------------------------------------------
-------------------------------------------------------------------------------


local OPTIONS
local Debug = LUXHRYS.Debug
local Async = LUXHRYS.Async
local STATE
local Bag = LUXHRYS.Bag
--local Location = LUXHRYS.Location
local LinkUtils = LUXHRYS.LinkUtils
local ItemKey = LUXHRYS.ItemKey

local BAG_PLACED_FURNISHINGS = Bag.BAG_PLACED_FURNISHINGS
local BAG_INBOX = Bag.BAG_INBOX
local BAG_TRADER = Bag.BAG_TRADER


-------------------------------------------------------------------------------
--| From LXIDatabase |---------------------------------------------------------
-------------------------------------------------------------------------------


local ItemCache = LUXHRYS.ItemCache


--[[ ============================> FUNCTIONS <============================ ]]--


-- =========================== [ Bag Iteration ] =========================== --


local BagUtils = {}


-- We need to pass the bagID during the async for loop but don't want to
-- create an anonymous function. These are copied from the ZOS functions with
-- an additional return to mimic pairs for LibAsync For:Do loops.

-- reminder: this iterator factory returns `iterator, state, initialIndex`

function BagUtils.IterateBagSlots (bagIDToIterate)

	Debug.Msg (2, ADDON_DEBUG_NAME, "BU_IBS", "Called for bag %d (%s).", bagIDToIterate, Bag.GetName (bagIDToIterate, true))

	-- reminder, iterator functions take `state, index` and return `index, ...`

	local function GetNextSlotIndex (bagID, slotIndex)
		Debug.Msg (3, ADDON_DEBUG_NAME, "BU_IBS", "Called for bag: %s, previous: %s.", tostring (bagID), tostring (slotIndex))

		if bagID == BAG_GUILDBANK then
			return GetNextGuildBankSlotId (slotIndex)
		elseif bagID == BAG_VIRTUAL then
			return GetNextVirtualBagSlotId (slotIndex)
		elseif bagID == BAG_FURNITURE_VAULT then
			return GetNextFurnitureVaultSlotId (slotIndex)
		elseif bagID == BAG_PLACED_FURNISHINGS then
			return GetNextPlacedHousingFurnitureId (slotIndex) -- !! uses id64
		elseif bagID == BAG_INBOX then
			return GetNextMailId (slotIndex)
		else
			return nil
		end
	end

	local function GetNextBagSlotIndex (lastSlotIndex, slotIndex)
		if slotIndex < lastSlotIndex then
			return slotIndex + 1
		else
			return nil
		end
	end -- GetNextSlotIndex

	-- This first set has custom slot functions.

	if bagIDToIterate == BAG_GUILDBANK
	or bagIDToIterate == BAG_VIRTUAL
	or bagIDToIterate == BAG_FURNITURE_VAULT
	or bagIDToIterate == BAG_PLACED_FURNISHINGS
	or bagIDToIterate == BAG_INBOX
	then
		Debug.Msg (3, ADDON_DEBUG_NAME, "BU_IBS", "BAG_INBOX")
		return GetNextSlotIndex, bagIDToIterate, nil
	else -- The remainder simply increment.
		local lastSlotIndex

		if bagIDToIterate == BAG_BUYBACK then
			lastSlotIndex = GetNumBuybackItems () - 1
		elseif bagIDToIterate == BAG_TRADER then
			lastSlotIndex = GetNumTradingHouseListings () - 1 -- This should be for the current trader only.
		else
			lastSlotIndex = GetBagUseableSize (bagIDToIterate) - 1 -- This will equal -1 for inaccessible bags and for will skip it.
		end

		Debug.Msg (4, ADDON_DEBUG_NAME, "BU_IBS", "Sized bag: Bag %d, First slot -1, Last slot %d.", bagIDToIterate, lastSlotIndex)

		return GetNextBagSlotIndex, lastSlotIndex, -1 -- Start at -1, so the first iteration is 0

	end -- if bagIDToIterate
end -- IterateBagSlots


LUXHRYS.BagUtils = BagUtils


-- ============================== [ Counts ] =============================== --

-- Counts is for full inventory scans only. Single slot changes are handled in Transfers.


local Counts = ZO_InitializingObject:Subclass ()


-------------------------------------------------------------------------------
--| Counting Functions |-------------------------------------------------------
-------------------------------------------------------------------------------

-- BAG_WORN (0), BAG_BACKPACK (1), BAG_BANK (2), BAG_SUBSCRIBER_BANK (6),
-- BAG_HOUSE_BANK_ONE through TEN (7-16), BAG_COMPANION_WORN (17)

do

	local currentItemKey, currentStackCount

	function Counts:GetBagSlotContents (slotID)

		Debug.Msg (3, ADDON_DEBUG_NAME, "C_GBSC", "Called. Current location code is %s.", self.itemCache.locationCode or "--")

		currentItemKey, currentStackCount = nil, nil

		if self.itemCache.bagID == BAG_BUYBACK then
			currentStackCount = select (3, GetBuybackItemInfo (slotID))
			if currentStackCount and currentStackCount > 0 then
				currentItemKey = ItemKey.Get (GetBuybackItemLink (slotID))
			end -- if currentStackCount and currentStackCount > 0
		elseif self.itemCache.bagID == BAG_PLACED_FURNISHINGS then
			currentItemKey = ItemKey.Get (GetPlacedFurnitureLink (slotID, LINK_STYLE_DEFAULT))
			if currentItemKey and currentItemKey ~= "" then
				currentStackCount = 1
			end -- currentItemKey and currentItemKey ~= ""
		elseif self.itemCache.bagID == BAG_INBOX then
			assert (false, "C_GBSC: BAG_INBOX no longer supported.")
	--[[ MOVED TO Inbox.lua
			Debug.Msg (3, ADDON_DEBUG_NAME, "C_GBSC", "Mail message %s has %d attachments.",  Id64ToString (slotID), GetMailAttachmentInfo (slotID))
			if GetMailAttachmentInfo (slotID) > 0 then
				Debug.Msg (1, ADDON_DEBUG_NAME, "C_GBSC", "Submitting message %s to mail cache.", Id64ToString (slotID))
				AddToOrUpdateUnreadMailCache (slotID)
			end
			return -- special case since we're not building an itemCache.
	]]
		elseif self.itemCache.bagID == BAG_TRADER then
			currentStackCount = select (4, GetTradingHouseListingItemInfo (slotID))
			if currentStackCount and currentStackCount > 0 then
				currentItemKey = ItemKey.Get (GetTradingHouseListingItemLink (slotID, LINK_STYLE_DEFAULT))
			end -- currentStackCountt and currentStackCount > 0
		else -- if self.itemCache.bagID == BAG_NUMBER
			-- Regular bag
			currentStackCount = GetSlotStackSize (self.itemCache.bagID, slotID)
			if currentStackCount and currentStackCount > 0 then
				currentItemKey = ItemKey.Get (GetItemLink (self.itemCache.bagID, slotID))
			end
		end -- if self.itemCache.bagID == BAG_NUMBER

		if currentItemKey and currentItemKey ~= "" then
			self.itemCache:Update (currentItemKey, currentStackCount)
		end -- if currentItemKey and currentItemKey ~= ""

		Debug.Msg (3, ADDON_DEBUG_NAME, "C_GBSC", "Bag %d, Slot %d: %s", self.itemCache.bagID, slotID, LinkUtils.StripItemLink (currentItemKey) or "--")

	end -- GetBagSlotContents

end


function Counts:GetBagContents (bagID)

	if self.itemCache then return end -- Never run two scans at once, which can happen with asynchronous processing. We'll come back soon and try again.

	Debug.Msg (1, ADDON_DEBUG_NAME, "C_GBC", "Scanning content of bag ID %d (%s).", bagID, Bag.GetName (bagID, true))

	local function IterateBagSlots (bagIDToIterate)
		return BagUtils.IterateBagSlots (bagIDToIterate)
	end

	local function GetBagSlotContents (slotID)
		self:GetBagSlotContents (slotID)
	end

	local function ProcessItemCache ()
		self.itemCache:Process ()
	end

	local function FinalizeScan ()
		self.dirtyButUnavailable[bagID] = nil
		self.bagDirtyStatus[bagID] = false
		self.itemCache = nil
	end


	-- Create item or from current bag inventory.

	self.itemCache = ItemCache:New (bagID, self.asyncTask ~= nil)

	if bagID == BAG_INBOX then
		assert (false, "GBC: BAG_INBOX no longer supported.")
	else -- if bagID == BAG_INBOX
		if self.asyncTask then
			Debug.Msg (2, ADDON_DEBUG_NAME, "C_GBC", "Calling GBSC using async.")
			self.asyncTask:For (IterateBagSlots (bagID)):Do (GetBagSlotContents)
			:Then (Debug.Msg (2, ADDON_DEBUG_NAME, "C_GBC", "Calling PIC using async."))
			:Then (ProcessItemCache)
			:Finally (FinalizeScan) -- This should never fire before the scan is finished because we are calling it with Finally.
		else -- if self.asyncTask
			Debug.Msg (2, ADDON_DEBUG_NAME, "C_GBC", "Calling GBSC without async.")
			for slotID in BagUtils.IterateBagSlots (bagID) do
				self:GetBagSlotContents (slotID)
			end
			Debug.Msg (2, ADDON_DEBUG_NAME, "C_GBC", "Calling PIC without async.")
			self.itemCache:Process () -- Submit the cache to the database.
			FinalizeScan () -- This should never fire before the scan is finished because we are not using async.
		end -- if if self.asyncTask
	end -- if bagID == BAG_INBOX

	Debug.Msg (1, ADDON_DEBUG_NAME, "C_GBC", "Finished scanning content of bag ID %d (%s).", bagID, Bag.GetName (bagID, true))

end


-------------------------------------------------------------------------------
--| Inventory Manager |--------------------------------------------------------
-------------------------------------------------------------------------------


-- Our inventory scanning manager. When a bag is set dirty, this will be called every 500 ms. If
-- a scan is in progress, we wait until the next call. Once all scans are complete, unregister.
-- Inspired by code from esoui/libraries/refresh/refresh.lua.

function Counts:OnUpdate ()

	if self.itemCache then return end -- Already doing a scan.

	for bagID, isDirty in pairs (self.bagDirtyStatus) do
		if isDirty == true then
			if Bag.IsAvailable (bagID) then
				self:GetBagContents (bagID) -- This will return immediately if a scan is already in progress.
				return -- Allow some time for the bag to be scanned asynchronously; we'll be back soon.
			else -- Not currently accessible. We'll need to check again at the end because it could become available before the loop ends.
				self.dirtyButUnavailable[bagID] = true
				self.bagDirtyStatus[bagID] = false
			end
		end
	end

	-- Check to see if any bags became available since we last checked.

	for bagID, _ in pairs (self.dirtyButUnavailable) do
			if Bag.IsAvailable (bagID) then
				self.dirtyButUnavailable[bagID] = nil
				self:GetBagContents (bagID)
				return -- allow some time for the bag to be scanned asynchronously; we'll be back soon.
			end
	end

	-- We've made it through the entire loop with nothing dirty that we can currently scan.

	EVENT_MANAGER:UnregisterForUpdate (ADDON_DEBUG_NAME)

end


-------------------------------------------------------------------------------
--| Initialization |-----------------------------------------------------------
-------------------------------------------------------------------------------


function Counts:InitializeCallbacks ()

	local function OnUpdateCallback ()
		self:OnUpdate ()
	end

	local function OnPlayerActivated ()

		if not self.playerAlreadyActivatedOnce then
			if OPTIONS.async.useAsync then
				self.asyncTask = Async.Initialize (ADDON_DEBUG_NAME .. "_C")
			end
			self.playerAlreadyActivatedOnce = true
		end

		self.bagDirtyStatus[BAG_WORN] = true and Bag.IsTrackedAndAvailable (BAG_WORN)
		self.bagDirtyStatus[BAG_BACKPACK] = true and Bag.IsTrackedAndAvailable (BAG_BACKPACK)
		self.bagDirtyStatus[BAG_VENGEANCE] = true and Bag.IsTrackedAndAvailable (BAG_VENGEANCE)

		for bagID = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_EIGHT do -- TODO: Should set to BAG_HOUSE_BANK_TEN?
			self.bagDirtyStatus[bagID] = true and Bag.IsTrackedAndAvailable (bagID)
		end

		self.bagDirtyStatus[BAG_FURNITURE_VAULT] = true and Bag.IsTrackedAndAvailable (BAG_FURNITURE_VAULT)
		self.bagDirtyStatus[BAG_PLACED_FURNISHINGS] = true and Bag.IsTrackedAndAvailable (BAG_PLACED_FURNISHINGS)

		EVENT_MANAGER:RegisterForUpdate(ADDON_DEBUG_NAME, OPTIONS.counting.pollingInterval, OnUpdateCallback)

	end

	EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)


	local function OnGuildBankChanged ()
		self.bagDirtyStatus[BAG_GUILDBANK] = true and Bag.IsTrackedAndAvailable (BAG_GUILDBANK)
		EVENT_MANAGER:RegisterForUpdate(ADDON_DEBUG_NAME, OPTIONS.counting.pollingInterval, OnUpdateCallback)
	end

	EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_OPEN_GUILD_BANK, OnGuildBankChanged)
--	EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_CLOSE_GUILD_BANK, OnGuildBankChanged)
	EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_GUILD_BANK_SELECTED, OnGuildBankChanged)
--	EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_GUILD_BANK_DESELECTED, OnGuildBankChanged)
	EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_GUILD_BANK_ITEMS_READY, OnGuildBankChanged)
--	EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_GUILD_BANK_OPEN_ERROR, OnGuildBankChanged)


	local function OnStoreOpened ()
		STATE.storeIsOpen = true
		self.bagDirtyStatus[BAG_BUYBACK] = true and Bag.IsTracked (BAG_BUYBACK) -- Don't check availability because event callback order is not guaranteed. Give time for the store open flag to be set. Availability will be checked again.
		EVENT_MANAGER:RegisterForUpdate(ADDON_DEBUG_NAME, OPTIONS.counting.pollingInterval, OnUpdateCallback)
	end

	local function OnStoreClosed ()
		STATE.storeIsOpen = false
	end

	EVENT_MANAGER:RegisterForEvent(ADDON_DEBUG_NAME, EVENT_OPEN_STORE, OnStoreOpened)
	EVENT_MANAGER:RegisterForEvent(ADDON_DEBUG_NAME, EVENT_CLOSE_STORE, OnStoreClosed)


	local function OnCompanionChanged ()
		self.bagDirtyStatus[BAG_COMPANION_WORN] = true and Bag.IsTrackedAndAvailable (BAG_COMPANION_WORN)
		EVENT_MANAGER:RegisterForUpdate(ADDON_DEBUG_NAME, OPTIONS.counting.pollingInterval, OnUpdateCallback)
	end

	EVENT_MANAGER:RegisterForEvent(ADDON_DEBUG_NAME, EVENT_COMPANION_ACTIVATED, OnCompanionChanged)
--	EVENT_MANAGER:RegisterForEvent(ADDON_DEBUG_NAME, EVENT_COMPANION_DEACTIVATED, OnCompanionChanged)


	local function OnTraderChanged ()
		self.bagDirtyStatus[BAG_TRADER] = true and Bag.IsTrackedAndAvailable (BAG_TRADER)
		EVENT_MANAGER:RegisterForUpdate(ADDON_DEBUG_NAME, OPTIONS.counting.pollingInterval, OnUpdateCallback)
	end

	EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_OPEN_TRADING_HOUSE, OnTraderChanged)
--	EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_CLOSE_TRADING_HOUSE, OnTraderChanged)
	EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_TRADING_HOUSE_SELECTED_GUILD_CHANGED, OnTraderChanged)


	local function OnFullInventoryUpdate (eventCode, arg1)
		if eventCode == EVENT_ARMORY_BUILD_SAVE_RESPONSE
		and arg1 and arg1 ~= ARMORY_BUILD_SAVE_RESULT_SUCCESS
		then return end

		self.bagDirtyStatus[BAG_COMPANION_WORN] = true and Bag.IsTrackedAndAvailable (BAG_COMPANION_WORN) -- Only bag not included in OnPlayerActivated that can be accessed without interaction.
		OnPlayerActivated () -- OnUpdate callback is set here
	end

	EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_INVENTORY_FULL_UPDATE, OnFullInventoryUpdate)
	EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_ARMORY_BUILD_SAVE_RESPONSE, OnFullInventoryUpdate)

	-- Do initial scan.

	OnPlayerActivated ()

end


function Counts:Initialize ()

	self.playerAlreadyActivatedOnce = false

	self.bagDirtyStatus =
	{
		[BAG_WORN] = true and Bag.IsTracked (BAG_WORN),
		[BAG_BACKPACK] = true and Bag.IsTracked (BAG_BACKPACK),
		[BAG_BANK] = true and Bag.IsTracked (BAG_BANK), -- always visibl)e
		[BAG_GUILDBANK] = true and Bag.IsTracked (BAG_GUILDBANK),
		[BAG_BUYBACK] = true and Bag.IsTracked (BAG_BUYBACK),
		[BAG_VIRTUAL] = true and Bag.IsTracked (BAG_VIRTUAL), -- always visible
		[BAG_SUBSCRIBER_BANK] = true and Bag.IsTracked (BAG_SUBSCRIBER_BANK), -- always visible
		[BAG_HOUSE_BANK_ONE] = true and Bag.IsTracked (BAG_HOUSE_BANK_ONE),
		[BAG_HOUSE_BANK_TWO] = true and Bag.IsTracked (BAG_HOUSE_BANK_TWO),
		[BAG_HOUSE_BANK_THREE] = true and Bag.IsTracked (BAG_HOUSE_BANK_THREE),
		[BAG_HOUSE_BANK_FOUR] = true and Bag.IsTracked (BAG_HOUSE_BANK_FOUR),
		[BAG_HOUSE_BANK_FIVE] = true and Bag.IsTracked (BAG_HOUSE_BANK_FIVE),
		[BAG_HOUSE_BANK_SIX] = true and Bag.IsTracked (BAG_HOUSE_BANK_SIX),
		[BAG_HOUSE_BANK_SEVEN] = true and Bag.IsTracked (BAG_HOUSE_BANK_SEVEN),
		[BAG_HOUSE_BANK_EIGHT] = true and Bag.IsTracked (BAG_HOUSE_BANK_EIGHT),
		[BAG_HOUSE_BANK_NINE] = true and Bag.IsTracked (BAG_HOUSE_BANK_NINE), -- future?
		[BAG_HOUSE_BANK_TEN] = true and Bag.IsTracked (BAG_HOUSE_BANK_TEN), -- future?
		[BAG_COMPANION_WORN] = true and Bag.IsTracked (BAG_COMPANION_WORN),
		[BAG_FURNITURE_VAULT] = true and Bag.IsTracked (BAG_FURNITURE_VAULT),
		[BAG_VENGEANCE] = true and Bag.IsTracked (BAG_VENGEANCE), -- visible only when in vengeance zone
		[BAG_PLACED_FURNISHINGS] = true and Bag.IsTracked (BAG_PLACED_FURNISHINGS),
--		[BAG_INBOX] = true and Bag.IsTracked (BAG_INBOX),
		[BAG_TRADER] = true and Bag.IsTracked (BAG_TRADER)
	}

	self.dirtyButUnavailable = {}

	self:InitializeCallbacks ()

end


-- TODO: Is there any reason this needs to be accessed from other chunks?
local COUNTS


-- =========================== [ Initialization ] ========================== --


-- Some "classes" rely on OPTIONS or use saved variables, which cannot be
-- initialized until EVENT_ADD_ON_LOADED.

local function InitializeCounts (_, addonName)
	if addonName and addonName == ADDON_NAME then
		Debug.Msg (1, ADDON_DEBUG_NAME, "IC", "Initializing %s.", ADDON_CHUNK_NAME)
		STATE = LUXHRYS.STATE
		EVENT_MANAGER:UnregisterForEvent (ADDON_DEBUG_NAME, EVENT_ADD_ON_LOADED)
		Debug.Msg (1, ADDON_DEBUG_NAME, "IC", "%s initialization complete.", ADDON_CHUNK_NAME)
	end
end


EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_ADD_ON_LOADED, InitializeCounts)



local function InitializeInventoryManager ()
	Debug.Msg (1, ADDON_DEBUG_NAME, "IIM", "Starting %s.", ADDON_CHUNK_NAME)
	OPTIONS = LUXHRYS.OPTIONS
	COUNTS = Counts:New ()
	EVENT_MANAGER:UnregisterForEvent (ADDON_DEBUG_NAME, EVENT_PLAYER_ACTIVATED)
	Debug.Msg (1, ADDON_DEBUG_NAME, "IIM", "%s %s.", ADDON_CHUNK_NAME, COUNTS ~= nil and "now available" or "has failed to start")
end


EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_PLAYER_ACTIVATED, InitializeInventoryManager)






--[[

local BagUtils = LUXHRYS.BagUtils
local COUNTS = LUXHRYS.COUNTS

]]