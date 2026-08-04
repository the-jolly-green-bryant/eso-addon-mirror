
--[[ LuXhrys Modular Add-On System ]]
--[[ Written by Xhrysanth (PSNA) ]]
--[[ LibExtendedInventory ]]
--[[ LXIInbox.lua ]]
--[[ LOAD ORDER FIFTH ]]


--[[ DISCLAIMER
This Add-on is not created by, affiliated with, or sponsored by, ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
]]

--[[ Information, attribution, copyright, and license:
This file is part of the core module for the LuXhrys add-on system for the Elder Scrolls Online.

This code chunk implements mailbox functions for the LuXhrys add-on system for the Elder Scrolls Online.

Written and copyright (c) 2026 by Xhrysanth (PSNA). License terms to be determined. Currently, and until this notice changes, all rights are reserved, except those that belong to ZeniMax Media Inc., which provides the API used by this software.
]]


--[[ ==========================> DECLARATIONS <=========================== ]]--


-- ========================= [ Dependency Check ] ========================== --


assert (LUXHRYS.LXI ~= nil, string.format ("[LuXhrysLXII] CRIT: LuXhrysLXIO not available. This chunk will not be loaded."))


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

local ADDON_CHUNK_NAME = "Inbox"
local ADDON_CHUNK_SHORT_NAME = "I"
local ADDON_DEBUG_NAME = ADDON_SYSTEM_NAME .. ADDON_MODULE_SHORT_NAME .. ADDON_CHUNK_SHORT_NAME


-- ===================== [ Localize Global Functions ] ===================== --


-------------------------------------------------------------------------------
--| C functions |--------------------------------------------------------------
-------------------------------------------------------------------------------


local GetNumMailItems = GetNumMailItems
local HasUnreadMail = HasUnreadMail
local HasUnreceivedMail = HasUnreceivedMail
local GetNumUnreadMail = GetNumUnreadMail

local GetNextMailId = GetNextMailId

local GetMailAttachmentInfo = GetMailAttachmentInfo
local GetAttachedItemLink = GetAttachedItemLink
local GetAttachedItemInfo = GetAttachedItemInfo
local RequestOpenMailbox = RequestOpenMailbox
local RequestReadMail = RequestReadMail
local CloseMailbox = CloseMailbox
local IsReadMailInfoReady = IsReadMailInfoReady
local GetMailFlags = GetMailFlags
local GetNumMailItemsByCategory = GetNumMailItemsByCategory
local GetMailIdByIndex = GetMailIdByIndex
--local GetMailSender = GetMailSender

local GetWorldName = GetWorldName

local IsConsoleUI = IsConsoleUI
local IsInGamepadPreferredMode = IsInGamepadPreferredMode

local AreId64sEqual = AreId64sEqual
local Id64ToString = Id64ToString
local StringToId64 = StringToId64

local GetTimeStamp = GetTimeStamp

local IsUnitInCombat = IsUnitInCombat

local GetInteractionType = GetInteractionType
local IsInteracting = IsInteracting
--local GetGameTimeMilliseconds = GetGameTimeMilliseconds


-------------------------------------------------------------------------------
--| ZOS Lua functions |--------------------------------------------------------
-------------------------------------------------------------------------------

local ToString = tostring



--local XI_ParseLink = ZO_LinkHandler_ParseLink
--local XI_IconFormat = zo_iconFormat
--local XI_TableInsert = table.insert
local TableRemove = table.remove
--local XI_StrFormat = string.format
--local zo_strformat = zo_strformat
local NonContiguousCount = NonContiguousCount
local zo_callLater = zo_callLater
local ZO_PreHook = ZO_PreHook
local d = d


-------------------------------------------------------------------------------
--| From LXICommon |-----------------------------------------------------------
-------------------------------------------------------------------------------


local OPTIONS
local Debug = LUXHRYS.Debug
local STATE
local Bag = LUXHRYS.Bag
local icons = LUXHRYS.icons
local Location = LUXHRYS.Location
local ItemKey = LUXHRYS.ItemKey
local COLORS

local BAG_INBOX = Bag.BAG_INBOX

-------------------------------------------------------------------------------
--| From LXIDatabase |---------------------------------------------------------
-------------------------------------------------------------------------------


local ItemCache = LUXHRYS.ItemCache


-------------------------------------------------------------------------------
--| From LXICounts |-----------------------------------------------------------
-------------------------------------------------------------------------------


local BagUtils = LUXHRYS.BagUtils
--local COUNTS


--[[ =====================> MODULE-SCOPE VARIABLES <====================== ]]--


local _

local MailboxView = {}


--[[ ====================> MODULE DESIGN INFORMATION <==================== ]]--


--[[ ==============unreadMailCache EXPLANATION============================ ]]--
--[[ We can generally use the GetBagContents function for the inbox, but   ]]--
--[[ each slotIndex is a mail message with multiple potential attachments. ]]--
--[[ Therefore, we need a second loop. However, the mail data is only      ]]--
--[[ available when the mailbox is open. We can do that programatically,   ]]--
--[[ as long as we take care to not close it while the user has the UI     ]]--
--[[ open. The second challenge is that there is no way to read what the   ]]--
--[[ attachments are, which is the whole point, without the message being  ]]--
--[[ set as read. If the mail has already been read, we can examine it right   ]]--
--[[ away. If not, and we read it, it gets marked as read. I can't see that]]--
--[[ as a viable way to do things, so we'll have to track when the user    ]]--
--[[ actually reads a message ourselves, and display the new mail icon     ]]--
--[[ until that happens. Now, when requesting to read a message, it does   ]]--
--[[ not happen synchronously. We need to wait for an event to know that   ]]--
--[[ it is ready. We'll create a cache to keep track of which messages we  ]]--
--[[ have to process asychronously and also whether the user has actually  ]]--
--[[ read the message. We can ignore messages with no attachments.         ]]--
--[[                                                                       ]]--
--[[ Cache structure:                                                      ]]--
--[[                                                                       ]]--
--[[ unreadMailCache = {length, mailData}                                  ]]--
--[[                                                                       ]]--
--[[ mailData[mailID] = false     - not requested read, not processed      ]]--
--[[                    true      - requested read, not processed          ]]--
--[[                    0         - processed, but not read by user        ]]--
--[[                    timestamp - timestamp when first read by user      ]]--
--[[                                                                       ]]--
--[[ The mailData will first be used for keeping a list of messages to     ]]--
--[[ scan. The mailData for a particular message needs to persist until    ]]--
--[[ such time as the user reads the message.                              ]]--
--[[                                                                       ]]--
--[[ ===================================================================== ]]--


--[[

mailCache =
{
	length = 0,
	numUnrequestedRead = 0,
	numUnprocessed = 0,
	numUnread = 0,
	currentlyReadRequested = 0 or mailID,
	dirty = false,
	mailData = {},
}

mailData =
{
	[safeMailID] =
	{
		firstAdded = time,
		numAttachments = number,
		attachments =
		{
			itemKey = stackCount,
			...
		},
--		processingStatus =	false (not requested read, not processed) -- this isn't really needed?
--												true (requested read, not processed)
--												time (when processed),
		playerRead = false or time,
		dirty = false
	}
}

]]


--[[ ============================> FUNCTIONS <============================ ]]--




-- ==================== [ Mailbox Iteration Functions ] ==================== --


-- reminder, iterator functions take `state, index` and return `index, ...`

local function GetNextMailID (_, slotIndex)
	return GetNextMailId (slotIndex)
end

-- reminder: this iterator factory returns `iterator, state, initialIndex`

local function IterateMailMessages () -- (lastMessageAdded) -- This argument is a safeMailID, so need to convert to id64 for use!
--		if not lastMessageAdded or lastMessageAdded == 0 then
--			lastMessageAdded = nil -- the proper starting value for the GetNextMailId function
--		else
--			lastMessageAdded = StringToId64 (lastMessageAdded)
--		end
	return GetNextMailID, -1, nil -- lastMessageAdded -- start at lastMessageAdded
end


-- ============================== [ Mailbox ] ============================== --


local Mailbox = ZO_InitializingObject:Subclass ()



-------------------------------------------------------------------------------
--| Utility Functions |--------------------------------------------------------
-------------------------------------------------------------------------------


function Mailbox:DoesAttachmentDataMatch (safeMailID, serverAttachmentCount)

	local cacheAttachmentCount = self.mailData[safeMailID].attachments and NonContiguousCount (self.mailData[safeMailID].attachments)

	return self.mailData[safeMailID].numAttachments == serverAttachmentCount -- There have been no updates to the number of attachments.
	and not (self.mailData[safeMailID].numAttachments > 0 and (cacheAttachmentCount == nil or cacheAttachmentCount ~= self.mailData[safeMailID].numAttachments)) -- Server says there are attachments but we don't know about them.
	and not (self.mailData[safeMailID].numAttachments == 0 and cacheAttachmentCount ~= nil) -- We have attachments but server says there are none.
end


function Mailbox:AreAnyMessagesDirty ()
	for safeMailID, mailInfo in pairs (self.mailData) do
		if mailInfo.dirty then return true end
	end
	return false
end


function Mailbox:DoesCacheNeedUpdates ()
--		self.mailboxAwaitingOpeningFlag
		Debug.Msg (
			4,
			ADDON_DEBUG_NAME,
			"M_DCNU",
			"Called. Cache dirty? %s    Messages dirty? %s\r\nHas unread mail? %s    HasUnreceivedMail? %s    Number of unread messages: %d\r\n",
			ToString (self.mailCache.dirty),
			ToString (self:AreAnyMessagesDirty ()),
			ToString (HasUnreadMail ()),
			ToString (HasUnreceivedMail ()),
			GetNumUnreadMail ()
		)
		return self.mailCache.dirty
		or self:AreAnyMessagesDirty ()
		or HasUnreadMail ()
		or HasUnreceivedMail ()
		or GetNumUnreadMail () > 0
--		or not self.firstRunCompleteFlag
		or self.mailCache.length ~= GetNumMailItems ()
end


function Mailbox:DoesMailboxNeedOpening ()
	Debug.Msg (4, ADDON_DEBUG_NAME, "M_DMNO", "Called. Does mailbox need opening? %s", ToString (not STATE.mailboxIsOpen and self:DoesCacheNeedUpdates ()))

	return not STATE.mailboxIsOpen
--	and not self.requestedMailboxOpenFlag
	and self:DoesCacheNeedUpdates ()
end


function Mailbox:CanMailboxBeOpenedNow ()
--[[
	return not STATE.mailboxIsOpen
--	and not self.requestedMailboxOpenFlag
	and not STATE.IsPlayerReadingMail ()
	and not IsUnitInCombat ("player")
	and not IsInteracting ()
	and GetInteractionType () == INTERACTION_NONE
]]
	return not (
		STATE.mailboxIsOpen
		or STATE.IsPlayerReadingMail ()
		or IsUnitInCombat ("player")
		or IsInteracting ()
		or GetInteractionType () ~= INTERACTION_NONE
	)
end


-------------------------------------------------------------------------------
--| Mailbox Functions |--------------------------------------------------------
-------------------------------------------------------------------------------


-- These functions are roughly in reverse order of operation.


-- The mail cache is up to date. Transfer attachment information to item cache for submission to the database.

function Mailbox:TransferCache ()

	local currentLocationCode

	local itemCache = ItemCache:New (BAG_INBOX, false)

	for safeMailID, mailInfo in pairs (self.mailData) do -- Should be quick for most players; do not use async! TODO: Switch to async if necessary.

		currentLocationCode = Location.GetCodeForBagInCurrentState (BAG_INBOX, safeMailID)

		if mailInfo.numAttachments > 0 and mailInfo.attachments ~= nil then
			for itemKey, stackCount in pairs (mailInfo.attachments) do
				itemCache:Update (itemKey, stackCount, currentLocationCode)
			end
--		else
--			Debug.Msg (1, ADDON_DEBUG_NAME, "M_TC", "No attachments. Setting message %s dirty.", safeMailID)
--			mailInfo.dirty = true
		end
	end

	itemCache:Process () -- Should be quick for most players; do not use async! TODO: Switch to async if necessary.

end -- TransferCache


function Mailbox:ProcessAttachments (safeMailID)

	Debug.Msg (2, ADDON_DEBUG_NAME, "M_PA", "Called for message %s.", safeMailID)

	-- These are insurmountable barriers to processing this message right now.

	if not safeMailID -- bad argument
	or not STATE.mailboxIsOpen -- can't access this right now
	or not IsReadMailInfoReady (StringToId64 (safeMailID)) -- message not ready
	then return nil end

	local mailID = StringToId64 (safeMailID)
	local serverAttachmentCount = GetMailAttachmentInfo (mailID)
	local currentTimeStamp = GetTimeStamp ()

	Debug.Msg (4, ADDON_DEBUG_NAME, "M_PA", "Message %s has cache attachment count %d; server has attachment count %d; cache attachments exist: %s.", safeMailID, self.mailData[safeMailID].numAttachments, serverAttachmentCount, self.mailData[safeMailID].attachments ~= nil and "Yes" or "No")

	-- One more check to make sure we should proceed.

--	if type (self.mailData[safeMailID].processingStatus) == "number" -- has already been processed.
--	and 
	if self:DoesAttachmentDataMatch (safeMailID, serverAttachmentCount)
	then
		Debug.Msg (4, ADDON_DEBUG_NAME, "M_PA", "Message %s attachment info is consistent. Clearing dirty and exiting early.", safeMailID)
		self.mailData[safeMailID].dirty = false
		self.mailData[safeMailID].lastUpdated = currentTimeStamp
		self.mailCache.lastUpdated = currentTimeStamp
		return nil
	else
		Debug.Msg (3, ADDON_DEBUG_NAME, "M_PA", "Message %s attachment info is not consistent.", safeMailID)
	end


	if serverAttachmentCount > 0 then

		local currentStackCount, currentItemKey
		self.mailData[safeMailID].attachments = {} -- Start from scratch to keep things simple.

		-- This is limited to six attachments, so we won't worry about using async.

		for attachmentIndex = 1, serverAttachmentCount do

			_, currentStackCount = GetAttachedItemInfo (mailID, attachmentIndex)

			if currentStackCount and currentStackCount > 0 then

				currentItemKey = ItemKey.Get (GetAttachedItemLink (mailID, attachmentIndex, LINK_STYLE_DEFAULT))

				if currentItemKey and currentItemKey ~= "" then
	Debug.Msg (4, ADDON_DEBUG_NAME, "M_PA", "Setting attachment on message %s to %s with quantity %d.", safeMailID, currentItemKey, currentStackCount)

					self.mailData[safeMailID].attachments[currentItemKey] = (self.mailData[safeMailID].attachments[currentItemKey] or 0) + currentStackCount

				end -- if currentItemKey and currentItemKey ~= ""

			end -- if currentStackCount and currentStackCount > 0

--			currentStackCount, currentItemKey = nil, nil

		end -- for attachmentIndex = 1, serverAttachmentCount

	else -- serverAttachmentCount > 0 -- Attachments, if there ever were any, have been taken.

		Debug.Msg (4, ADDON_DEBUG_NAME, "M_PA", "Removing attachment data for message %s.", safeMailID)

		self.mailData[safeMailID].attachments = nil
		self.mailData[safeMailID].numAttachments = 0

	end -- serverAttachmentCount > 0

	Debug.Msg (3, ADDON_DEBUG_NAME, "M_PA", "Finished processing attachments for message %s. Clearing dirty.", safeMailID)
--	self.mailData[safeMailID].processingStatus = currentTimeStamp
	self.mailData[safeMailID].dirty = false
	self.mailData[safeMailID].lastUpdated = currentTimeStamp
	self.mailCache.lastUpdated = currentTimeStamp

end -- ProcessAttachments


function Mailbox:RequestReadMessage (safeMailID)

	Debug.Msg (3, ADDON_DEBUG_NAME, "M_RRM", "Requesting read access for mail message %s.", safeMailID)

	local requestResult = RequestReadMail (StringToId64 (safeMailID))

	if requestResult == REQUEST_READ_MAIL_RESULT_NOT_IN_MAIL_INTERACTION then
		Debug.Msg (2, ADDON_DEBUG_NAME, "M_RRM", "Request for mailID %s read access failed because mailbox is not open. Setting dirty.", safeMailID)
		self.mailData[safeMailID].dirty = true
	elseif requestResult == REQUEST_READ_MAIL_RESULT_NO_SUCH_MAIL then -- Delete this now.
		Debug.Msg (2, ADDON_DEBUG_NAME, "M_RRM", "Request for mailID %s read access failed because the message no longer exists. Removing it from the cache and setting the cache dirty.", safeMailID)
		self.mailData[safeMailID] = nil
		self.mailCache.dirty = true
--		self.mailData[safeMailID].processingStatus = true
	else -- requestResult ~= REQUEST_READ_MAIL_RESULT_NOT_IN_MAIL_INTERACTION and requestResult ~= REQUEST_READ_MAIL_RESULT_NO_SUCH_MAIL
		Debug.Msg (4, ADDON_DEBUG_NAME, "M_RRM", "Request succeeded for mail message %s.", safeMailID)
	end -- requestResult ~= REQUEST_READ_MAIL_RESULT_NOT_IN_MAIL_INTERACTION and requestResult ~= REQUEST_READ_MAIL_RESULT_NO_SUCH_MAIL

end -- RequestReadMessage


-------------------------------------------------------------------------------
--| Mail Cache Manager |-------------------------------------------------------
-------------------------------------------------------------------------------

-- /script LUXHRYS.Debug.MC_Dump ()

-- Updates the mailCache. When either the cache or a message is set dirty, this will be called every 500 ms until nothing is dirty.

function Mailbox:OnUpdate ()

	Debug.Msg (2, ADDON_DEBUG_NAME, "M_OU", "Mail cache manager running. Cache is %sdirty. Mailbox is currently %sopen.", self.mailCache.dirty == true and "" or "not ", STATE.mailboxIsOpen == true and "" or "not ")

	if self:DoesMailboxNeedOpening () then -- and not STATE.mailboxIsOpen -- already included in DoesMailboxNeedOpening
		Debug.Msg (3, ADDON_DEBUG_NAME, "M_OU", "Mailbox needs to be opened.")
		if self:CanMailboxBeOpenedNow () then
			Debug.Msg (4, ADDON_DEBUG_NAME, "M_OU", "Requesting mailbox opening.")
			self.requestedMailboxOpenFlag = true
			RequestOpenMailbox ()
		else
			Debug.Msg (4, ADDON_DEBUG_NAME, "M_OU", "Mailbox cannot be opened right now. Will try again later.")
		end
		return -- Try again next call.
	end

	local currentSafeMailID, currentNumAttachments
	local startingTimeStamp, currentTimeStamp = 0, 0

	-- First, cycle through all messages on the server. If any of them are not in the cache, add them. Inspect any already in the cache.

	if self.mailCache.dirty then -- This is a list of limited size. Skip async to keep timing simpler.
		startingTimeStamp = GetTimeStamp ()
		Debug.Msg (3, ADDON_DEBUG_NAME, "M_OU", "Mail cache is dirty. Processing server messages.")
--		for mailID in IterateMailMessages () do
		for mailID in BagUtils.IterateBagSlots (BAG_INBOX) do
			currentSafeMailID = Id64ToString (mailID)
			currentNumAttachments = GetMailAttachmentInfo (mailID)
			currentTimeStamp = GetTimeStamp ()
			if not self.mailData[currentSafeMailID] then -- Make a new cache entry.
				Debug.Msg (4, ADDON_DEBUG_NAME, "M_OU", "Adding new mail cache entry for server message %s.", currentSafeMailID)
				self.mailData[currentSafeMailID] =
				{
					firstAdded = currentTimeStamp,
					lastUpdated = currentTimeStamp,
					numAttachments = currentNumAttachments,
--					processingStatus = false, -- Not requested read, not processed.
					playerRead = false, --GetMailFlags (mailID), -- Chances are slim that the player will beat us to a new message, but you never know.
					dirty = currentNumAttachments > 0 and true or false
				}
				self:RequestReadMessage (currentSafeMailID)
			else -- if not self.mailData[currentSafeMailID] -- This message is already in the cache. Sanity check time.
				if not self:DoesAttachmentDataMatch (currentSafeMailID, currentNumAttachments) then -- Something isn't right. Let's reprocess it.
					Debug.Msg (2, ADDON_DEBUG_NAME, "M_OU", "Server message %s is already in the mail cache, but has a problem. Setting dirty. Timestamp: %s", currentSafeMailID, currentTimeStamp)
					self.mailData[currentSafeMailID].dirty = true
				end -- if not self:DoesAttachmentDataMatch (currentSafeMailID, currentNumAttachments)
				self.mailData[currentSafeMailID].lastUpdated = currentTimeStamp
			end -- if not self.mailData[currentSafeMailID]
		end -- for mailID in IterateMailMessages ()
		self.mailCache.lastUpdated = currentTimeStamp
		Debug.Msg (3, ADDON_DEBUG_NAME, "M_OU", "Done processing server messages. Clearing cache dirty.")
		self.mailCache.dirty = false -- This means that the cache is up to date.
	end -- if self.mailCache.dirty


	-- Now, loop through the mail cache, processing any messages that are dirty.

	local currentMailID
	local cacheSize = 0

	Debug.Msg (3, ADDON_DEBUG_NAME, "M_OU", "Inspecting mail cache messages for attachments. Timestamp: %s", GetTimeStamp ())

	for safeMailID, mailInfo in pairs (self.mailData) do
		currentMailID = StringToId64 (safeMailID)
		currentTimeStamp = GetTimeStamp ()
		if mailInfo.lastUpdated < startingTimeStamp then -- This cache entry was not touched in the current update. We take this opportunity to remove presumed lost items. -- TODO: Is there a more robust check?
			Debug.Msg (4, ADDON_DEBUG_NAME, "M_OU", "Removing message %s from mail cache because it is not on the server. Start time: %s.", safeMailID, ToString (startingTimeStamp))
			self.mailData[safeMailID] = nil
		else
			-- Do we need to process this cache entry?
			if mailInfo.dirty == true -- This got set somewhere. Need to process.
--			or mailInfo.processingStatus == false -- Not requested read, not processed (newly added), but dirty was not set for some reason.
			or mailInfo.numAttachments ~= GetMailAttachmentInfo (currentMailID) -- Attachment count mismatch.
			or (mailInfo.numAttachments > 0 and (not mailInfo.attachments or NonContiguousCount (mailInfo.attachments) == 0)) -- Server says there are attachments but we don't know about them.
			or mailInfo.numAttachments == 0 and self.mailData[safeMailID].attachments -- We have attachments but server says there are none.
			then
				-- Make sure to catch messages that somehow escaped being scanned before.
				Debug.Msg (4, ADDON_DEBUG_NAME, "M_OU", "Server message %s has %d attachments, %d attachments in mailInfo. Timestamp: %s", safeMailID, mailInfo.numAttachments, mailInfo.attachments and NonContiguousCount (mailInfo.attachments) or 0, currentTimeStamp)
				if IsReadMailInfoReady (currentMailID) then
					Debug.Msg (4, ADDON_DEBUG_NAME, "M_OU", "Message information already available. Processing attachments for mail message %s.", safeMailID)
					self:ProcessAttachments (safeMailID)
	--				mailInfo.lastUpdated = currentTimeStamp -- already done in ProcessAttachments
				else -- if IsReadMailInfoReady (currentMailID)
					self:RequestReadMessage (safeMailID)
				end -- if IsReadMailInfoReady (currentMailID)
			end -- if mailInfo.dirty == true


		end -- if mailInfo.lastUpdated < startingTimeStamp

		cacheSize = cacheSize + 1
--		unprocessedCount = unprocessedCount + (type (mailInfo.processingStatus) == "boolean" and 1 or 0)
--		unreadCount = unreadCount + (mailInfo.playerRead == false and 1 or 0)
	end -- for safeMailID, mailInfo in pairs (self.mailData)

	self.mailCache.length = cacheSize
--	self.mailCache.numUnprocessed = unprocessedCount
--	self.mailCache.numUnread = unreadCount

	Debug.Msg (3, ADDON_DEBUG_NAME, "M_OU", "Done updating mail cache of length %d.", self.mailCache.length)

	-- We should be done scanning the mailbox.


	if self.requestedMailboxOpenFlag then
		self.requestedMailboxOpenFlag = false
	end

	EVENT_MANAGER:UnregisterForUpdate (ADDON_DEBUG_NAME)
	self.cacheManagerIsRunning = false

	-- Make sure that the player is not reading mail.

	if STATE.IsPlayerReadingMail () then
		Debug.Msg (3, ADDON_DEBUG_NAME, "M_OU", "Player is reading mail. Player must close mailbox.")
--		if self.mailCache.lastUpdated > startingTimeStamp then
			Debug.Msg (3, ADDON_DEBUG_NAME, "M_OU", "Transferring cache. Timestamp: %s", GetTimeStamp ())
			self:TransferCache ()
--		end
	else
		Debug.Msg (3, ADDON_DEBUG_NAME, "M_OU", "Closing mailbox.")
		CloseMailbox ()
	end

end -- OnUpdate


-------------------------------------------------------------------------------
-- | Initialization functions |------------------------------------------------
-------------------------------------------------------------------------------


function Mailbox:InitializeCallbacks ()


	-- Start the mail cache manager.

	local function OnUpdateCallback ()
		self:OnUpdate ()
	end

	local function UpdateIfNeeded ()
		Debug.Msg (2, ADDON_DEBUG_NAME, "M_IC_UIN", "Called. Cache updates needed? %s. Cache manager running? %s.", ToString (self:DoesCacheNeedUpdates ()), ToString (self.cacheManagerIsRunning))
		if self:DoesCacheNeedUpdates () and not self.cacheManagerIsRunning then
			self.cacheManagerIsRunning = true
			Debug.Msg (2, ADDON_DEBUG_NAME, "M_IC_UIN", "Starting cache manager.")
			EVENT_MANAGER:RegisterForUpdate(ADDON_DEBUG_NAME, OPTIONS.mail.pollingInterval, OnUpdateCallback)
		end
	end


	-- 1. If the server tells us mail is available, or the player loads in, check mail.

	local function OnMailAvailable (eventID)
		Debug.Msg (3, ADDON_DEBUG_NAME, "M_IC_OMA", "Called with event %d.", eventID)
--		if eventID == EVENT_MAIL_INBOX_UPDATE -- This seems to fire more often than useful. TODO: Make sure we're not missing anything.
		if eventID == EVENT_GUILD_MAIL_UPDATE
		or eventID == EVENT_MAIL_WITH_ATTACHMENTS_AVAILABLE
		then
			Debug.Msg (4, ADDON_DEBUG_NAME, "M_IC_OMA", "Setting cache dirty.")
			self.mailCache.dirty = true
		end
		UpdateIfNeeded ()
	end

	EVENT_MANAGER:RegisterForEvent (ADDON_NAME, EVENT_MAIL_INBOX_UPDATE, OnMailAvailable)
	EVENT_MANAGER:RegisterForEvent (ADDON_NAME, EVENT_GUILD_MAIL_UPDATE, OnMailAvailable)
	EVENT_MANAGER:RegisterForEvent (ADDON_NAME, EVENT_MAIL_WITH_ATTACHMENTS_AVAILABLE, OnMailAvailable)
	EVENT_MANAGER:RegisterForEvent (ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnMailAvailable)


	-- 2. Let the cache manager know that the mailbox is open.

	local function OnMailboxOpened ()
		Debug.Msg (3, ADDON_DEBUG_NAME, "M_IC_OMO", "Called.")
--		self.mailboxAwaitingOpeningFlag = false
--		self.mailboxAlreadyClosedFlag = false
		STATE.mailboxIsOpen = true
		UpdateIfNeeded ()
		if STATE.IsPlayerReadingMail () then
			MailboxView.OnViewMailbox ()
		end
	end

	EVENT_MANAGER:RegisterForEvent (ADDON_NAME, EVENT_MAIL_OPEN_MAILBOX, OnMailboxOpened)


	-- 3. Mail read information became available. Run the manager if needed.

	local function OnMailReadable (_, mailID)
		local safeMailID = Id64ToString (mailID)
		Debug.Msg (3, ADDON_DEBUG_NAME, "M_IC_OMRdb", "Called for message %s. Setting dirty.", safeMailID)
--		self.requestedReadMailFlag = false
		self.mailData[safeMailID].dirty = true
		UpdateIfNeeded ()
	end

	EVENT_MANAGER:RegisterForEvent (ADDON_NAME, EVENT_MAIL_READABLE, OnMailReadable)


	-- 4. Submit itemCache (or reopen mailbox if not finished)

	local function OnMailboxClosed ()
		Debug.Msg (3, ADDON_DEBUG_NAME, "M_IC_OMC", "Called.")

		if STATE.mailboxIsOpen then
			STATE.mailboxIsOpen = false
			if not self:DoesCacheNeedUpdates () then

				-- The cache manager is no longer needed.

				EVENT_MANAGER:UnregisterForUpdate (ADDON_DEBUG_NAME)
				self.cacheManagerIsRunning = false


			end
			-- Submit the cache to the database.
			Debug.Msg (3, ADDON_DEBUG_NAME, "M_IC_OMC", "Transferring cache.")
			self:TransferCache ()
		end
		UpdateIfNeeded () -- Check to make sure that we don't need anything more.
	end

	EVENT_MANAGER:RegisterForEvent (ADDON_NAME, EVENT_MAIL_CLOSE_MAILBOX, OnMailboxClosed)


	-- This will be called when the user actually reads the mail text using ReadMail, something we will never do.

	local function OnMailRead (mailID)
		local safeMailID = Id64ToString (mailID)
		Debug.Msg (3, ADDON_DEBUG_NAME, "M_IC_OMR", "Called for message %s.", safeMailID)
		self.mailData[safeMailID].playerRead = GetTimeStamp ()
		if STATE.IsPlayerReadingMail () then
			MailboxView.ClearUnreadIcon (mailID) -- This will remove new mail icons for messages we had previously read and the user just read.
		end
		return false
	end

	ZO_PreHook ("ReadMail", OnMailRead) -- We never call this. TODO: May need to be updated for FurnitureShowcase.


	-- Attachments taken. Taking attachments is usually all-or-none, but in cases where inventory is full but some items can be stacked, partial takings have occurred in the past. This behavior may have changed, but let's write for the more complex case.

	local function OnAttachmentsTaken (eventID, mailIDOrTakeAttachmentResult, categoryID)
		if eventID == EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS then
			local safeMailID = Id64ToString (mailIDOrTakeAttachmentResult)
			Debug.Msg (3, ADDON_DEBUG_NAME, "M_IC_OAT", "Called for event %d and message %s. Current server attachments: %s. Timestamp: %s. Setting message and cache dirty.", eventID, safeMailID, GetMailAttachmentInfo (mailIDOrTakeAttachmentResult), GetTimeStamp ())
			self.mailData[safeMailID].dirty = true
			self.mailCache.dirty = true
		elseif eventID == EVENT_MAIL_TAKE_ALL_ATTACHMENTS_IN_CATEGORY_RESPONSE
		and mailIDOrTakeAttachmentResult == MAIL_TAKE_ATTACHMENT_RESULT_SUCCESS
		then
			Debug.Msg (3, ADDON_DEBUG_NAME, "M_IC_OAT", "Called for event %d and category %d. Setting all messages in category or cache dirty.", eventID, categoryID)
			local currentSafeMailID
			for i = 1, GetNumMailItemsByCategory (categoryID) do
				currentSafeMailID = Id64ToString (GetMailIdByIndex (categoryID, i))
				if self.mailData[currentSafeMailID] then
					self.mailData[currentSafeMailID].dirty = true
				else
					self.mailCache.dirty = true
				end -- if self.mailData[currentSafeMailID]
			end -- for i = 1, GetNumMailItemsByCategory (categoryID)
		else
			return
		end -- if eventID == EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS
		UpdateIfNeeded ()
	end

	EVENT_MANAGER:RegisterForEvent (ADDON_NAME, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, OnAttachmentsTaken)
	EVENT_MANAGER:RegisterForEvent (ADDON_NAME, EVENT_MAIL_TAKE_ALL_ATTACHMENTS_IN_CATEGORY_RESPONSE, OnAttachmentsTaken)


	-- Message deleted. Remove from cache.

	local function OnMessageRemoved (eventID, mailID, success)
		if eventID == EVENT_DELETE_MAIL_RESPONSE and success == false then return end
		local safeMailID = Id64ToString (mailID)
		Debug.Msg (3, ADDON_DEBUG_NAME, "M_IC_OMRem", "Called for event %d and message %s. Setting message or cache dirty.", eventID, safeMailID)
		if self.mailData[safeMailID] then
			self.mailData[safeMailID].dirty = true
		else
			self.mailCache.dirty = true
		end
		UpdateIfNeeded ()
	end

	EVENT_MANAGER:RegisterForEvent (ADDON_NAME, EVENT_MAIL_REMOVED, OnMessageRemoved)
	EVENT_MANAGER:RegisterForEvent (ADDON_NAME, EVENT_DELETE_MAIL_RESPONSE, OnMessageRemoved)


	-- Run update. This should really only matter when we receive new messages; if we read a message, we already know about that.

	local function OnNumUnreadChanged (_, numUnread)
		Debug.Msg (3, ADDON_DEBUG_NAME, "M_IC_ONUC", "Called with %d unread messages. %setting cache dirty.", numUnread, numUnread ~= 0 and "S" or "Not s")
		self.mailCache.dirty = numUnread ~= 0 and true or false
		UpdateIfNeeded ()
	end

	EVENT_MANAGER:RegisterForEvent (ADDON_NAME, EVENT_MAIL_NUM_UNREAD_CHANGED, OnNumUnreadChanged)

	-- Do initial scan. Wait a few seconds for other startup tasks to finish. Player probably won't try to access mailbox so quickly and, if they do, it's addressed elsewhere.

	zo_callLater (UpdateIfNeeded, 3000)

end


function Mailbox:Initialize ()

	-- Tracking is turned off and we have no previous data.

	if OPTIONS.bagTracking[BAG_INBOX] == false
	and
	(
		not LuXhrysLibExtendedInventory_SV
		and not LuXhrysLibExtendedInventory_SV["NA Megaserver"]
		and not LuXhrysLibExtendedInventory_SV["NA Megaserver"]["@Xhrysanth"]
		and not LuXhrysLibExtendedInventory_SV["NA Megaserver"]["@Xhrysanth"]["$AccountWide"]
		and not LuXhrysLibExtendedInventory_SV["NA Megaserver"]["@Xhrysanth"]["$AccountWide"]["mailCache"]
	)
	then return end


	-- Set up saved variables.

	local defaultMailCache =
	{
		length = 0,
		lastUpdated = 0,
--		numUnrequestedRead = 0,
--		numUnprocessed = 0,
--		numUnread = 0,
--		currentlyReadRequested = 0,
--		lastMessageAdded = 0,
		dirty = true,
		mailData = {}
	}

	self.mailCache = ZO_SavedVars:NewAccountWide (ADDON_SYSTEM_NAME .. ADDON_MODULE_NAME .. "_SV", OPTIONS.mailCacheVersion, "mailCache", defaultMailCache, GetWorldName ())
--	self.mailCache = defaultMailCache

	if OPTIONS.mail.rebuild == true then
		Debug.Msg (0, ADDON_DEBUG_NAME, "M_I", "INFO: Rebuilding mail cache.")
		self.mailCache:ResetToDefaults ()
		OPTIONS.mail.rebuild = false
	end

--	self.lastMessageAdded = self.mailCache.lastMessageAdded

	self.mailData = self.mailCache.mailData

-- 	self.mailCache.length = NonContiguousCount (self.mailData) -- Now done below.


	-- If we have mail tracking turned off, we end here.

	if OPTIONS.bagTracking[BAG_INBOX] == false then return end


	Debug.Msg (2, ADDON_DEBUG_NAME, "M_I", "Starting...")

	-- Tracking flags to avoid multiple overlapping calls and closing mailbox on user.

	self.mailCache.dirty = true -- Is it possible that there are messages to be added?
--	self.mailboxAwaitingOpeningFlag = false
	self.requestedMailboxOpenFlag = false
--	self.requestedReadMailFlag = false
--	self.mailboxAlreadyClosedFlag = false
--	self.processingClosedMailboxFlag = false
--	self.firstRunCompleteFlag = false
	self.cacheManagerIsRunning = false

	local cacheSize = 0

	-- Set every mail cache message to dirty to force inspecting them. Count the cache size while we're at it.

	for _, mailInfo in pairs (self.mailData) do
		mailInfo.dirty = true
		cacheSize = cacheSize + 1
	end -- for safeMailID, mailInfo in pairs (self.mailData)

	self.mailCache.length = cacheSize

	self:InitializeCallbacks ()

end


-------------------------------------------------------------------------------
--| Debugging functions |------------------------------------------------------
-------------------------------------------------------------------------------


function Mailbox:Dump ()
	Debug.Msg (0, ADDON_DEBUG_NAME, "MB_D", "INFO: Dumping raw mail cache.")
	d ("\r\nCache:\r\n", self.mailCache)
	d ("\r\nIndividual attributes:\r\n", self.mailCache.dirty, self.mailCache.lastUpdated, self.mailCache.length)
	d ("\r\nData:\r\n", self.mailCache.mailData)
	d ("Mail cache variable type: " .. type (self.mailCache))
	Debug.Msg (0, ADDON_DEBUG_NAME, "MB_D", "INFO: Dump complete.")
end


-- Try to limit access to the mail cache. Initialized below.

local LUXHRYS_INBOX


-- We still want to be able to dump it from the command line.

function LUXHRYS.Debug.MC_Dump ()
	LUXHRYS_INBOX:Dump ()
end


-- ============================= [ MailUtils ] ============================= --


local MailUtils = {}


-- Have we requested that the mailbox is open?

function MailUtils.IsRequestedOpen ()
	return LUXHRYS_INBOX.requestedMailboxOpenFlag == true
end


-- Do we think that the mailbox is open?

function MailUtils.IsOpen ()
	return STATE.mailboxIsOpen == true
end


function MailUtils.IsMessageInMailCache (safeMailID)
	return LUXHRYS_INBOX.mailData[safeMailID] ~= nil
end


function MailUtils.IsMailCacheMessageUnreadByPlayer (safeMailID)
	return LUXHRYS_INBOX.mailData[safeMailID] ~= nil
	and LUXHRYS_INBOX.mailData[safeMailID].playerRead == false
end


LUXHRYS.MailUtils = MailUtils



--[[
local function HasServerMarkedMailMessageAsRead (mailID)
	return select (5, GetMailItemInfo (mailID)) == false
end



We should never need to scan a mail message twice.

Two approaches:

1. Scan all available mail, then request access to unavailable mail, then scan that.

2. Request access to all unavailable mail, then scan everything once that is done.

Second approach seems better.

ORIGINAL VERSION:

On activation, if unread mail exists or is firstRun, add it to unreadMailCache if it has attachments. Done: EVENT_PLAYER_ACTIVATED->GetBagContents->AddToOrUpdateUnreadMailCache
If unread messages, open mailbox. Done: ->XI_RequestOpenMailbox + SetRequestedMailboxOpenFlag
On mailbox opening, request access to all unread messages with attachments, adding to unreadMailCache as we go. On first run, scan read messages as well. EVENT_MAIL_OPEN_MAILBOX->ProcessUnreadMail
On mail readable, check HasUnreadMail and, when it reaches zero, GetMailMessageAttachments for unprocessed items in cache. EVENT_MAIL_READABLE->GetMailMessageAttachments
FinalizeMailbox->EVENT_MAIL_MAILBOX_CLOSED->OnCloseMailbox->ProcessItemCache

Well, I really already knew that you can't get info about mail until the mailbox is open...really, I did! Try again.

MAILBOX OPEN VERSION:

On activation, if unread mail exists or is firstRun, open mailbox. EVENT_PLAYER_ACTIVATED->XI_RequestOpenMailbox + SetRequestedMailboxOpenFlag Done.
Add unread messages to unreadMailCache if it has attachments. EVENT_MAIL_OPEN_MAILBOX->GetBagContents->AddToOrUpdateUnreadMailCache Done.
Once done adding messages to unreadMailCache, request access to them. ->ProcessUnreadMail Done.
On mail readable, check HasUnreadMail and, when it reaches zero, GetMailMessageAttachments for unprocessed items in cache. EVENT_MAIL_READABLE->HasUnreadMail==false->GetMailMessageAttachments Done.
FinalizeMailbox->EVENT_MAIL_MAILBOX_CLOSED->OnCloseMailbox->ProcessItemCache





]]


-- ============================ [ MailboxView ] ============================ --

-- Display tinted new icon in mail message that the add-on has scanned but the
-- player has not actually read. Scanning a message makes the game think that
-- the player has read it and the standard icon disappears.


-- | Helper functions |--------------------------------------------------------


-- There does not appear to be a way to clear a single icon, so we'll need to
-- reset and then set all of them from scratch. Reusing ZOS code. EDIT: Wrote one.


-- Addition to ZO_GamepadEntryData to natively remove either the normal or selected icon, or both.
-- TODO: It's not clear what the behavior is if no normal texture exists but a selected one does.

function ZO_GamepadEntryData:RemoveIcon (normalTexture, selectedTexture)
	Debug.Msg (3, "ZO_GED", "RI", "Called for object %s, icon %s and selected icon %s.", ToString (self), ToString (normalTexture), ToString (selectedTexture))
	if (normalTexture and self.iconsNormal) or (selectedTexture and self.iconsSelected) then
		for i = 1, self.numIcons do
			if normalTexture and self.iconsNormal[i] == normalTexture then -- We want to remove normal icon.
				if selectedTexture and self.iconsSelected[i] == selectedTexture then -- We also want to remove selected icon.
					Debug.Msg (4, "ZO_GED", "RI", "Removing both icons.")
					TableRemove (self.iconsNormal, i)
					TableRemove (self.iconsSelected, i)
					self.numIcons = self.numIcons - 1 -- Since we removed an entry, need to decrement this.
					return true
				else -- We don't want to remove selected icon, so we can't delete the entry. Set to false as in ZO_GamepadEntryData:AddIconSubtype.
					Debug.Msg (4, "ZO_GED", "RI", "Removing only normal icon.")
					self.iconsNormal[i] = false
					return true
				end -- if self.iconsSelected[i] == selectedTexture
			elseif selectedTexture and self.iconsSelected[i] == selectedTexture then -- We did not want to remove normal icon but we do want to remove the selected icon. We can't delete the entry, so set to false.
				Debug.Msg (4, "ZO_GED", "RI", "Removing only selected icon.")
				self.iconsSelected[i] = false
					return true
			else
				Debug.Msg (4, "ZO_GED", "RI", "Taking no action.")
			end -- if self.iconsNormal[i] == normalTexture
		end -- for i = 1, self.numIcons
	end -- if self.iconsNormal and self.iconsSelected
	return false
end


-- For keyboard, the MultiIcon functions are attached directly to the icon control, with XML calling ZO_MultiIcon_Initialize in esoui/libraries/zo_multiicon/zo_multiicon.lua. There's no way to reliably add to the MultiIcon collection of functions because any control created before we add a removal function will not have access to it. Thus, we will write a local one.

local function RemoveIcon (self, iconTexture)
	Debug.Msg (1, ADDON_DEBUG_NAME, "RI", "Removing icon %s.", ToString (iconTexture))
	if self.iconData then
		for index, existingIconData in ipairs (self.iconData) do -- We're only removing one element, so no need to iterate in reverse.
			if existingIconData.iconTexture == iconTexture then
				TableRemove (self.iconData[index])
				return true
			end
		end
	end
	return false
end


--| Common mailbox functions for both keyboard/mouse and gamepad |-------------


-- TODO: Cycle through existing icons to identify which need to be set again. Also, see if we can just set the icon entry to nil. Maybe add a function to the class?

-- We use our own copy of the standard new icon so we don't accidentally remove one that the base game put there. Initialized at the bottom.

local ICON_TEXTURE_KEYBOARD
local ICON_TEXTURE_COLORED_GAMEPAD


function MailboxView.ClearUnreadIcon (mailID)
	local safeMailID = Id64ToString (mailID)
	if IsConsoleUI () or IsInGamepadPreferredMode () then
		local entryData = MAIL_GAMEPAD.inbox.mailEntryDataById[safeMailID]
		Debug.Msg (4, ADDON_DEBUG_NAME, "MV_CUI", "Called for message %s.", safeMailID)
		if entryData:RemoveIcon (icons.general.ICON_NEW_LARGE) then
			MAIL_GAMEPAD.inbox.mailList:RefreshVisible ()
		end
	else -- if IsConsoleUI () or IsInGamepadPreferredMode ()
		local iconTexture = MAIL_INBOX:GetMailData (mailID).node:GetControl ().iconTexture
		if RemoveIcon (iconTexture, ICON_TEXTURE_KEYBOARD) then
			iconTexture:Show ()
		end
	end
end
--5001188491
--45851
--/script d (MAIL_GAMEPAD.inbox.mailEntryDataById["5006628481"])

function MailboxView.SetUnreadIcon (mailID)
	if IsConsoleUI () or IsInGamepadPreferredMode () then
		if not AreId64sEqual (MAIL_GAMEPAD.inbox:GetActiveMailId (), mailID) then -- Not currently reading it.
			local safeMailID = Id64ToString (mailID)
			Debug.Msg (2, ADDON_DEBUG_NAME, "MV_SUI", "Called for message %s. Setting %s icon.", safeMailID, icons.general.ICON_NEW_LARGE)
			MAIL_GAMEPAD.inbox.mailEntryDataById[safeMailID]:AddIcon (icons.general.ICON_NEW_LARGE)
--			MAIL_GAMEPAD.inbox.mailList:RefreshVisible () -- We shouldn't need this since commit is being called.
		end -- if not AreId64sEqual (MAIL_GAMEPAD:GetActiveMailId (), mailID)
	else -- if IsConsoleUI () or IsInGamepadPreferredMode ()
		local mailData = MAIL_INBOX:GetMailData (mailID)
		if MAIL_INBOX.navigationTree:GetSelectedNode () == mailData.node then
			mailData.node:GetControl ().iconTexture:AddIcon (ICON_TEXTURE_KEYBOARD, COLORS.GetCurrentTint ().ICON)
--			MAIL_INBOX.navigationTree:RefreshVisible (false) -- should be called by Commit, which we prehooked for this callback
		end -- if MAIL_INBOX.navigationTree:GetSelectedNode () == mailData.node
	end -- if IsConsoleUI () or IsInGamepadPreferredMode ()
end -- MailboxView.SetUnreadIcon


MailboxView.commitAlreadyHooked = false

function MailboxView.OnViewMailbox () -- called when OPEN_MAILBOX fires. This is for updating the icons.

	if not STATE.IsPlayerReadingMail () then return end

	Debug.Msg (2, ADDON_DEBUG_NAME, "MV_OVM", "Called.")

	if IsConsoleUI () or IsInGamepadPreferredMode () then
		if MailboxView.commitAlreadyHooked == false and MAIL_GAMEPAD.inbox.mailList ~= nil and MAIL_GAMEPAD.inbox.mailList.Commit ~= nil then
		Debug.Msg (1, ADDON_DEBUG_NAME, "MV_OVM", "Hooking gamepad.")
			ZO_PreHook (MAIL_GAMEPAD.inbox.mailList, "Commit", MailboxView.OnViewMailbox)
			MailboxView.commitAlreadyHooked = true
		end -- if commitAlreadyHooked == false and MAIL_GAMEPAD.inbox.mailList ~= nil and MAIL_GAMEPAD.inbox.mailList.Commit ~= nil
	else -- if IsConsoleUI () or IsInGamepadPreferredMode ()
		if MailboxView.commitAlreadyHooked == false and MAIL_INBOX.navigationTree ~= nil and MAIL_INBOX.navigationTree.Commit ~= nil then
		Debug.Msg (1, ADDON_DEBUG_NAME, "MV_OVM", "Hooking keyboard.")
			ZO_PreHook (MAIL_INBOX.navigationTree, "Commit", MailboxView.OnViewMailbox)
			MailboxView.commitAlreadyHooked = true
		end -- if commitAlreadyHooked == false and MAIL_INBOX.navigationTree ~= nil and MAIL_INBOX.navigationTree.Commit ~= nil
	end -- if IsConsoleUI () or IsInGamepadPreferredMode ()

	if STATE.IsPlayerReadingMail () then
		local currentSafeMailID
		Debug.Msg (3, ADDON_DEBUG_NAME, "MV_OVM", "Iterating inbox.")
		for mailID in BagUtils.IterateBagSlots (BAG_INBOX) do
			currentSafeMailID = Id64ToString (mailID)
			if not GetMailFlags (mailID) -- Server thinks this message has been read by the player.
			and MailUtils.IsMessageInMailCache (currentSafeMailID) -- It's in the cache.
			and MailUtils.IsMailCacheMessageUnreadByPlayer (currentSafeMailID) -- It's in the cache but not actually read by the player.
			then
				Debug.Msg (4, ADDON_DEBUG_NAME, "MV_OVM", "Setting icon.")
				MailboxView.SetUnreadIcon (mailID)
			else
				Debug.Msg (4, ADDON_DEBUG_NAME, "MV_OVM", "Clearing icon.")
				MailboxView.ClearUnreadIcon (mailID)
			end -- if not GetMailFlags (mailID) and MailUtils.IsMessageInMailCache (currentSafeMailID) and MailUtils.IsMailCacheMessageUnreadByPlayer (currentSafeMailID)
--			currentSafeMailID = nil
		end -- for mailID in BagUtils.IterateBagSlots (BAG_INBOX)
	end -- if STATE.IsPlayerReadingMail ()

	Debug.Msg (3, ADDON_DEBUG_NAME, "MV_OVM", "Completed.")

	return false -- For prehooked function to continue normally.

end -- MailboxView.OnViewMailbox


LUXHRYS.MailboxView = MailboxView


-- =========================== [ Initialization ] ========================== --


-- Some "classes" rely on OPTIONS or use saved variables, which cannot be
-- initialized until EVENT_ADD_ON_LOADED.

local function InitializeInbox ()
	Debug.Msg (1, ADDON_DEBUG_NAME, "II", "Initializing %s Manager.", ADDON_CHUNK_NAME)
	OPTIONS = LUXHRYS.OPTIONS
	STATE = LUXHRYS.STATE
	COLORS = LUXHRYS.COLORS
	ICON_TEXTURE_KEYBOARD = icons.general.ICON_NEW_SMALL
	ICON_TEXTURE_COLORED_GAMEPAD = COLORS:GetColorizedIcon (icons.general.ICON_NEW_LARGE, 64, 64)
--		COUNTS = LUXHRYS.COUNTS
	LUXHRYS_INBOX = Mailbox:New ()
	EVENT_MANAGER:UnregisterForEvent (ADDON_DEBUG_NAME, EVENT_ADD_ON_LOADED)
	Debug.Msg (1, ADDON_DEBUG_NAME, "II", "%s Manager initialization %s.", ADDON_CHUNK_NAME, LUXHRYS_INBOX ~= nil and "successful" or "failed")
end


EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_PLAYER_ACTIVATED, InitializeInbox)


--[[

local MailUtils = LUXHRYS.MailUtils
local MailboxView = LUXHRYS.MailboxView

]]