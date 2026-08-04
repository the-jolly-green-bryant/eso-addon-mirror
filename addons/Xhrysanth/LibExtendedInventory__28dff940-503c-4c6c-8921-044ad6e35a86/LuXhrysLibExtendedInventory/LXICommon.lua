
--[[ LuXhrys Modular Add-On System ]]
--[[ Written by Xhrysanth (PSNA) ]]
--[[ LibExtendedInventory ]]
--[[ LXICommon.lua ]]
--[[ LOAD ORDER SECOND ]]


--[[ DISCLAIMER
This Add-on is not created by, affiliated with, or sponsored by, ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
]]

--[[ Information, attribution, copyright, and license:
This file is part of the core module for the LuXhrys add-on system for the Elder Scrolls Online.

This code chunk implements common functions for the LuXhrys add-on system for the Elder Scrolls Online.

Written and copyright (c) 2026 by Xhrysanth (PSNA). License terms to be determined. Currently, and until this notice changes, all rights are reserved, except those that belong to ZeniMax Media Inc., which provides the API used by this software.
]]


--[[ ==========================> DECLARATIONS <=========================== ]]--


-- ========================= [ Dependency Check ] ========================== --


assert (LUXHRYS.LXI ~= nil, "[LuXhrysLXICo] CRIT: LuXhrysLXIO not available. This chunk will not be loaded.")


-- ============================== [ Metadata ] ============================= --


-- Some alternative name ideas.
--local ADDON_MODULE_NAME = "WarehouseManager"
--local ADDON_MODULE_NAME = "Stock and Trade"
--local ADDON_MODULE_NAME = "Personal Banker"
--local ADDON_MODULE_NAME = "Chest and Coffer"
--local ADDON_MODULE_NAME = "Vault and Coffer" <-- Probably my favorite.
--local ADDON_MODULE_NAME = "BagMan or Bag Manager"
--local ADDON_MODULE_NAME = "ExtendedInventory"


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

local ADDON_CHUNK_NAME = "Common"
local ADDON_CHUNK_SHORT_NAME = "Co"
local ADDON_DEBUG_NAME = ADDON_SYSTEM_NAME .. ADDON_MODULE_SHORT_NAME .. ADDON_CHUNK_SHORT_NAME


-- ===================== [ Localize Global Functions ] ===================== --


-------------------------------------------------------------------------------
--| C functions |--------------------------------------------------------------
-------------------------------------------------------------------------------


local GetString = GetString

local GetTotalUserAddOnMemoryPoolUsageMB = GetTotalUserAddOnMemoryPoolUsageMB

local IsConsoleUI = IsConsoleUI
local IsInGamepadPreferredMode = IsInGamepadPreferredMode

local GetCurrencyKeyboardIcon = GetCurrencyKeyboardIcon
local GetCurrencyGamepadIcon = GetCurrencyGamepadIcon

local GetCurrentCharacterId = GetCurrentCharacterId

local GetItemLinkItemType = GetItemLinkItemType
local GetItemLinkItemId = GetItemLinkItemId
local CanItemLinkBeVirtual = CanItemLinkBeVirtual
local IsItemLinkPlaceableFurniture = IsItemLinkPlaceableFurniture

local GetBagUseableSize = GetBagUseableSize

local IsCollectibleUnlocked = IsCollectibleUnlocked
local GetCollectibleForBag = GetCollectibleForBag
local GetTotalCollectiblesByCategoryType = GetTotalCollectiblesByCategoryType
local GetCollectibleIdFromType = GetCollectibleIdFromType

local IsBankOpen = IsBankOpen

local IsGuildBankOpen = IsGuildBankOpen
local GetSelectedGuildBankId = GetSelectedGuildBankId

local GetNumBuybackItems = GetNumBuybackItems

local GetCurrentZoneHouseId = GetCurrentZoneHouseId
local IsOwnerOfCurrentHouse = IsOwnerOfCurrentHouse

local HasActiveCompanion = HasActiveCompanion
local GetCompanionCollectibleId = GetCompanionCollectibleId
local GetActiveCompanionDefId = GetActiveCompanionDefId

local IsCurrentCampaignVengeanceRuleset = IsCurrentCampaignVengeanceRuleset

local CanSellOnTradingHouse = CanSellOnTradingHouse
local GetSelectedTradingHouseGuildId = GetSelectedTradingHouseGuildId
local GetNumTradingHouseListings = GetNumTradingHouseListings

local DoesGuildHavePrivilege = DoesGuildHavePrivilege
local DoesPlayerHaveGuildPermission = DoesPlayerHaveGuildPermission
local GetHousingPrimaryHouse = GetHousingPrimaryHouse

local IsESOPlusSubscriber = IsESOPlusSubscriber

-------------------------------------------------------------------------------
--| Native Lua functions |-----------------------------------------------------
-------------------------------------------------------------------------------


local StrFormat = string.format
local ToUpper = string.upper
local ToLower = string.lower
local ToNumber = tonumber
local ToString = tostring

-------------------------------------------------------------------------------
--| ZOS Lua functions |--------------------------------------------------------
-------------------------------------------------------------------------------


--local HasUnlockedFurnitureVault = ZO_HousingEditorState:HasUnlockedFurnitureVault
--local HousingEditorState = ZO_HousingEditorState
--local ParseLink = ZO_LinkHandler_ParseLink
local zo_iconFormatInheritColor = zo_iconFormatInheritColor
local ZO_Alert = ZO_Alert
local ZO_ColorDef = ZO_ColorDef
--local ZO_ClearTable = ZO_ClearTable
--local TableInsert = table.insert
--local TableRemove = table.remove
local d = d


-------------------------------------------------------------------------------
--| From LXIDatabase |---------------------------------------------------------
-------------------------------------------------------------------------------


local DBLOOKUP



local Debug = {}
local Async = {}
local StrUtils = {}
local Alerts = {}
local Bag = {}
local State = ZO_InitializingObject:Subclass ()
local icons = {}
local Location = {}
local LinkUtils = {}
local ItemKey = {}
local ItemInfo = {}
local Colors = ZO_InitializingObject:Subclass ()


--[[ ============================> FUNCTIONS <============================ ]]--


-- ============================= [ Debugging ] ============================= --


-- Event names for debugging

local eventNames = {

	[EVENT_PLAYER_ACTIVATED] = "EVENT_PLAYER_ACTIVATED",
	[EVENT_PLAYER_DEACTIVATED] = "EVENT_PLAYER_DEACTIVATED",
	[EVENT_ZONE_CHANGED] = "EVENT_ZONE_CHANGED",
	[EVENT_ZONE_UPDATE] = "EVENT_ZONE_UPDATE",

	-- Events for backpack, worn,  bags:
	[EVENT_ITEM_SLOT_CHANGED] = "EVENT_ITEM_SLOT_CHANGED",
	[EVENT_INVENTORY_FULL_UPDATE] = "EVENT_INVENTORY_FULL_UPDATE",
	[EVENT_INVENTORY_SINGLE_SLOT_UPDATE] = "EVENT_INVENTORY_SINGLE_SLOT_UPDATE",
	[EVENT_INVENTORY_ITEM_DESTROYED] = "EVENT_INVENTORY_ITEM_DESTROYED",
	[EVENT_INVENTORY_ITEM_USED] = "EVENT_INVENTORY_ITEM_USED",
	[EVENT_INVENTORY_ITEMS_AUTO_TRANSFERRED_TO_CRAFT_BAG] = "EVENT_INVENTORY_ITEMS_AUTO_TRANSFERRED_TO_CRAFT_BAG",
--	[EVENT_CRAFT_BAG_AUTO_TRANSFER_NOTIFICATION_CLEARED] = "EVENT_CRAFT_BAG_AUTO_TRANSFER_NOTIFICATION_CLEARED",
--	[EVENT_STACKED_ALL_ITEMS_IN_BAG] = "EVENT_STACKED_ALL_ITEMS_IN_BAG",

	-- Buyback:

	[EVENT_UPDATE_BUYBACK] = "EVENT_UPDATE_BUYBACK",
	[EVENT_BUYBACK_RECEIPT] = "EVENT_BUYBACK_RECEIPT",
	[EVENT_BUY_RECEIPT] = "EVENT_BUY_RECEIPT",
	[EVENT_SELL_RECEIPT] = "EVENT_SELL_RECEIPT",

	-- Placed furnishings:

	[EVENT_HOUSING_FURNITURE_PLACED] = "EVENT_HOUSING_FURNITURE_PLACED",
	[EVENT_HOUSING_FURNITURE_REMOVED] = "EVENT_HOUSING_FURNITURE_REMOVED",
	[EVENT_HOUSING_FURNITURE_STATE_CHANGED] = "EVENT_HOUSING_FURNITURE_STATE_CHANGED",
	[EVENT_HOUSE_FURNITURE_COUNT_UPDATED]  = "EVENT_HOUSE_FURNITURE_COUNT_UPDATED",

	-- Mail and attachments:

	[EVENT_MAIL_INBOX_UPDATE] = "EVENT_MAIL_INBOX_UPDATE",
	[EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS] = "EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS",
	[EVENT_MAIL_WITH_ATTACHMENTS_AVAILABLE] = "EVENT_MAIL_WITH_ATTACHMENTS_AVAILABLE",
	[EVENT_MAIL_TAKE_ALL_ATTACHMENTS_IN_CATEGORY_RESPONSE] = "EVENT_MAIL_TAKE_ALL_ATTACHMENTS_IN_CATEGORY_RESPONSE",
	[EVENT_MAIL_OPEN_MAILBOX] = "EVENT_MAIL_OPEN_MAILBOX",
	[EVENT_MAIL_READABLE] = "EVENT_MAIL_READABLE",
	[EVENT_MAIL_CLOSE_MAILBOX] = "EVENT_MAIL_CLOSE_MAILBOX",
	[EVENT_MAIL_REMOVED] = "EVENT_MAIL_REMOVED",

	-- Guild bank:

	[EVENT_GUILD_BANK_ITEM_ADDED] = "EVENT_GUILD_BANK_ITEM_ADDED",
	[EVENT_GUILD_BANK_ITEM_REMOVED] = "EVENT_GUILD_BANK_ITEM_REMOVED",
	[EVENT_GUILD_BANK_UPDATED_QUANTITY] = "EVENT_GUILD_BANK_UPDATED_QUANTITY",
	[EVENT_GUILD_BANK_ITEMS_READY] = "EVENT_GUILD_BANK_ITEMS_READY",

	-- Guild trader:

	[EVENT_OPEN_TRADING_HOUSE] = "EVENT_OPEN_TRADING_HOUSE",
	[EVENT_CLOSE_TRADING_HOUSE] = "EVENT_CLOSE_TRADING_HOUSE",

	-- Crafting:

	[EVENT_CRAFT_COMPLETED] = "EVENT_CRAFT_COMPLETED",
	[EVENT_DAILY_LOGIN_REWARDS_CLAIMED] = "EVENT_DAILY_LOGIN_REWARDS_CLAIMED",
	[EVENT_LOOT_RECEIVED] = "EVENT_LOOT_RECEIVED",
	[EVENT_TRADE_SUCCEEDED] = "EVENT_TRADE_SUCCEEDED"

}

-- Platform IDs

local platformNames = {
	[UI_PLATFORM_PC] = "PC",
	[UI_PLATFORM_PS4] = "PS4",
	[UI_PLATFORM_PS5] = "PS5",
	[UI_PLATFORM_REUSE_ME] = "UNKNOWN",
	[UI_PLATFORM_XBOX] = "Xbox"
}


--[[ NOT IMPLEMENTED
-- Debugging categories

DEBUG_LVL_TERSE =			0x00000001
DEBUG_LVL_BASIC =			0x00000002
DEBUG_LVL_ENHANCED =	0x00000004
DEBUG_LVL_VERBOSE =		0x00000008

DEBUG_CAT_COMMON =		0x00000010
DEBUG_CAT_INTERFACE =	0x00000020
DEBUG_CAT_DATABASE =	0x00000040
DEBUG_CAT_INBOX =			0x00000080
DEBUG_CAT_COUNTS =		0x00000100
DEBUG_CAT_TRANSFERS =	0x00000200
DEBUG_CAT_HOOKS =			0x00000400
DEBUG_CAT_MAIIN =			0x00000800


options.Debug.debugFlags = DEBUG_LVL_VERBOSE
]]




-- Debugging functions

function Debug.Msg (debugLevel, chunk, func, ...)
	if not LUXHRYS.OPTIONS or not LUXHRYS.OPTIONS.debug.debugLevel or LUXHRYS.OPTIONS.debug.debugLevel >= debugLevel then
--		d (StrFormat ("[%s] %s | MB used: %.2f", ADDON_NAME, StrFormat (...), GetTotalUserAddOnMemoryPoolUsageMB ()))
		d ("[" .. chunk .. ":" .. func .. "] " ..
		StrFormat (...) ..
		StrFormat (" || MB used: %.2f", GetTotalUserAddOnMemoryPoolUsageMB ())
		)
	end
end


function Debug.EventName (eventID)
	return eventNames[eventID]
end


function Debug.PlatformName (platformID)
	return platformNames[platformID]
end


function Debug.MemoryFlush ()
	local startMem = collectgarbage ("count")
	collectgarbage("collect")
	collectgarbage("collect") -- Apparently, once is not enough.
	Debug.Msg (0, ADDON_DEBUG_NAME, "D_MF", "Approximately %.2f MB freed.", (startMem - collectgarbage ("count")) / 1000)
end


LUXHRYS.Debug = Debug


-- ====================== [ Asynchronous Processing ] ====================== --




function Async.Initialize (namespace)
	if LUXHRYS.OPTIONS.async.useAsync then
		if not LibAsync then
			Debug.Msg (0, ADDON_DEBUG_NAME, "A_I", "WARN: LibAsync is not present. Disabling asynchronous processing. You will need to reenable it in the options settings to try again.")
			LUXHRYS.OPTIONS.async.useAsync = false
		else
			local task = LibAsync:Create (namespace)
			if task ~= nil then
				Debug.Msg (0, ADDON_DEBUG_NAME, "A_I", "INFO: LibAsync successfully loaded for %s. Asynchronous processing enabled.", namespace)
				return task
			else
				LUXHRYS.OPTIONS.async.useAsync = false
				Debug.Msg (0, ADDON_DEBUG_NAME, "A_I", "WARN: Even though LibAsync is present, there was a problem loading it. Disabling asynchronous processing. You will need to reenable it in the options settings to try again.")
			end -- if self.asyncTask
		end -- if not LibAsync
	end -- if OPTIONS.async.useAsync
end


LUXHRYS.Async = Async


-- ========================= [ String Utilities ] ========================== --




function StrUtils.SentenceCase (text)
	return text:gsub ("^%l", ToUpper)
end
--XMT.StrSentenceCase = XMT_StrSentenceCase


local function StringTitleCase (initial, rest)
	return initial:upper () .. rest:lower ()
end


function StrUtils.TitleCase (text)
--	return text:gsub ("(%a)([%w]*)", StringTitleCase)
	return text:gsub ("(%a[%w]*)", StrUtils.SentenceCase)
end
--XMT.StrTitleCase = XMT_StrTitleCase


LUXHRYS.StrUtils = StrUtils


-- ========================== [ General Alerts ] =========================== --




function Alerts.CornerAlert (message)
	if not message or message == "" then return end
	ZO_Alert (UI_ALERT_CATEGORY_ALERT, SOUNDS.DEFAULT_CLICK, message)
end


LUXHRYS.Alerts = Alerts


-- =========================== [ Inventory bags ] ========================== --




-------------------------------------------------------------------------------
--| Bag Names |----------------------------------------------------------------
-------------------------------------------------------------------------------


-- Define our own bags in addition to the standard ones.

local BAG_PLACED_FURNISHINGS = -1
local BAG_INBOX = -2
local BAG_TRADER = -3
local BAG_CUSTOM_MIN_VALUE = -3

Bag.BAG_PLACED_FURNISHINGS = BAG_PLACED_FURNISHINGS
Bag.BAG_INBOX = BAG_INBOX
Bag.BAG_TRADER = BAG_TRADER
Bag.BAG_CUSTOM_MIN_VALUE = BAG_CUSTOM_MIN_VALUE


-- Get friendly names for bags to use in user-facing text.

--[[
    "Bank", -- SI_HOUSINGFURNITURELOCATIONFILTER4
    "House Storage", -- SI_HOUSINGFURNITURELOCATIONFILTER8
    "Collectibles", -- SI_HOUSINGFURNITURELOCATIONFILTER16
    "Furnishing Vault", -- SI_HOUSINGFURNITURELOCATIONFILTER32
]]

local housingStorageString = ToLower (StrFormat ("%s %s", GetString (SI_ITEMTYPE34), GetString (SI_HOUSINGFURNITURELOCATIONFILTER8))) -- "collectible house storage"

local bagNames =
{
	[BAG_WORN] = ToLower (GetString (SI_CRAFT_ADVISOR_TOOLTIP_EQUIP_TAB)), -- "equipped gear",
	[BAG_BACKPACK] = "backpack",
	[BAG_BANK] = ToLower (GetString (SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_BANK)), --"bank", -- always visible
	[BAG_GUILDBANK] = ToLower (GetString (SI_CURRENCYLOCATION2)), -- "guild bank",
	[BAG_BUYBACK] = ToLower (GetString (SI_ITEMFILTERTYPE8)), -- "vendor buyback",
	[BAG_VIRTUAL] = ToLower (GetString (SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_CRAFT_BAG)), -- "craft bag", -- always visible
	[BAG_SUBSCRIBER_BANK] = ToLower (GetString (SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_BANK)), -- "bank", -- always visible
	[BAG_HOUSE_BANK_ONE] = housingStorageString, --"collectible house storage"
	[BAG_HOUSE_BANK_TWO] = housingStorageString, --"collectible house storage",
	[BAG_HOUSE_BANK_THREE] = housingStorageString, --"collectible house storage",
	[BAG_HOUSE_BANK_FOUR] = housingStorageString, --"collectible house storage",
	[BAG_HOUSE_BANK_FIVE] = housingStorageString, --"collectible house storage",
	[BAG_HOUSE_BANK_SIX] = housingStorageString, --"collectible house storage",
	[BAG_HOUSE_BANK_SEVEN] = housingStorageString, --"collectible house storage",
	[BAG_HOUSE_BANK_EIGHT] = housingStorageString, --"collectible house storage",
	[BAG_HOUSE_BANK_NINE] = housingStorageString, --"collectible house storage", -- future?
	[BAG_HOUSE_BANK_TEN] = housingStorageString, --"collectible house storage", -- future?	[BAG_COMPANION_WORN] = true,
	[BAG_COMPANION_WORN] = ToLower (StrFormat ("%s %s", GetString (SI_GAMEPAD_EQUIPPED_COMPANION_ITEM_HEADER), GetString (SI_INVENTORY_MODE_ITEMS))), -- "companion equipped items",
	[BAG_FURNITURE_VAULT] = ToLower (GetString (SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_FURNITURE_VAULT)), -- "furniture vault",
	[BAG_VENGEANCE] = ToLower (GetString (SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_VENGEANCE)), -- "vengeance bag",
	[BAG_PLACED_FURNISHINGS] = "placed furniture",
	[BAG_INBOX] = ToLower (StrFormat ("%s %s", GetString (SI_WINDOW_TITLE_MAIL), GetString (SI_WINDOW_TITLE_INBOX_MAIL))), -- "mail inbox",
	[BAG_TRADER] = ToLower (GetString (SI_GUILDMETADATAATTRIBUTE8)), -- "guild trader"
}


--function Bags.GetBagName (bagID)
function Bag.GetName (bagID, titleCase)
	return titleCase == true and StrUtils.TitleCase (bagNames[bagID]) or bagNames[bagID]
end


-------------------------------------------------------------------------------
--| Bag Tracking |-------------------------------------------------------------
-------------------------------------------------------------------------------


-- Define different bag tracking behaviors.

local UNTRACKED = 0
local TRACKED = 1
local TRACKED_IN_STORE = 2
local TRACKED_IN_GUILDBANK = 3
local TRACKED_WHILE_COMPANION = 4
local TRACKED_IN_HOUSE = 5
local TRACKED_IN_PVP = 6
local TRACKED_IN_MAILBOX = 7
local TRACKED_IN_TRADER = 8
local TRACKED_AT_LOGOUT = 9


-- We realy didn't end up using this that much. TODO: Consider refectoring to just be tracked or untracked.

local howIsBagTracked =
{
	[BAG_WORN] = TRACKED,
	[BAG_BACKPACK] = TRACKED_AT_LOGOUT,
	[BAG_BANK] = UNTRACKED, -- always visible
	[BAG_GUILDBANK] = TRACKED_IN_GUILDBANK, -- not sure about this one
	[BAG_BUYBACK] = TRACKED_IN_STORE,
	[BAG_VIRTUAL] = UNTRACKED, -- always visible
	[BAG_SUBSCRIBER_BANK] = UNTRACKED, -- always visible

-- TODO: Check for existence of each bag on load/first time entering house.

	[BAG_HOUSE_BANK_ONE] = TRACKED_IN_HOUSE,
	[BAG_HOUSE_BANK_TWO] = TRACKED_IN_HOUSE,
	[BAG_HOUSE_BANK_THREE] = TRACKED_IN_HOUSE,
	[BAG_HOUSE_BANK_FOUR] = TRACKED_IN_HOUSE,
	[BAG_HOUSE_BANK_FIVE] = TRACKED_IN_HOUSE,
	[BAG_HOUSE_BANK_SIX] = TRACKED_IN_HOUSE,
	[BAG_HOUSE_BANK_SEVEN] = TRACKED_IN_HOUSE,
	[BAG_HOUSE_BANK_EIGHT] = TRACKED_IN_HOUSE,
	[BAG_HOUSE_BANK_NINE] = UNTRACKED, -- future?
	[BAG_HOUSE_BANK_TEN] = UNTRACKED, -- future?
	[BAG_FURNITURE_VAULT] = TRACKED_IN_HOUSE,

	[BAG_COMPANION_WORN] = TRACKED_WHILE_COMPANION,
	[BAG_VENGEANCE] = TRACKED_IN_PVP,

	[BAG_PLACED_FURNISHINGS] = TRACKED_IN_HOUSE,
	[BAG_INBOX] = TRACKED_IN_MAILBOX,
	[BAG_TRADER] = TRACKED_IN_TRADER
}


--function Bags.HowIsBagTracked (bagID)
function Bag.HowTracked (bagID)
	return howIsBagTracked[bagID] or UNTRACKED
end


--function Bags.IsBagTracked (bagID)
function Bag.IsTracked (bagID)

	Debug.Msg (3, ADDON_DEBUG_NAME, "B_IBT", "Called with bagID %d. Tracked? %s, How? %s", bagID, tostring (LUXHRYS.OPTIONS.bagTracking[bagID]), tostring (Bag.HowTracked (bagID)))

	return LUXHRYS.OPTIONS.bagTracking[bagID] and Bag.HowTracked (bagID) ~= UNTRACKED

end


function Bag.IsAnyHousingStorageTracked ()

	for bagID = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
		if State.IsHousingStorageCollected (bagID) and Bag.IsTracked (bagID) then
			return true
		end
	end

	return false
end


-------------------------------------------------------------------------------
--| Bag Queries |--------------------------------------------------------------
-------------------------------------------------------------------------------


--function Bags.IsValidBag (bagID)
function Bag.IsValid (bagID)
	if not bagID or bagID < BAG_CUSTOM_MIN_VALUE or bagID > BAG_MAX_VALUE then
		return false
	else
		return true
	end
end



-- This function returns whether a storage location is available at the moment. Compare to STATE.IsBagUnlocked, which evaluates whether a player has a storage feature unlocked.

--function Bags.IsBagAvailable (bagID)
function Bag.IsAvailable (bagID)
	if not Bag.IsValid (bagID) or GetBagUseableSize () == 0 then
		return false
	elseif bagID == BAG_BANK or bagID == BAG_SUBSCRIBER_BANK then
		return IsBankOpen ()
	elseif bagID == BAG_GUILDBANK then
		return IsGuildBankOpen ()
	elseif bagID == BAG_BUYBACK then
		return LUXHRYS.STATE:IsStoreOpen ()
	elseif bagID >= BAG_HOUSE_BANK_ONE and bagID <= BAG_HOUSE_BANK_TEN then
		return IsOwnerOfCurrentHouse () and State.IsHousingStorageCollected (bagID)
	elseif bagID == BAG_COMPANION_WORN then
		return HasActiveCompanion ()
	elseif bagID == BAG_FURNITURE_VAULT then
		return IsOwnerOfCurrentHouse () and HOUSING_EDITOR_STATE:HasUnlockedFurnitureVault ()
--[[ TODO? Don't think we'll ever need to check whether we can deposit.
HOUSING_EDITOR_STATE:CanDepositIntoFurnitureVault()
]]
	elseif bagID == BAG_VENGEANCE then
		return IsCurrentCampaignVengeanceRuleset ()
	elseif bagID == BAG_INBOX then
		return LUXHRYS.STATE:IsMailboxOpen () or LUXHRYS.STATE.IsPlayerReadingMail ()
	elseif bagID == BAG_TRADER then
--		Debug.Msg (3, "IBA: Trader. Guild ID: %s. Can sell? %s. Num listings: %s.", GetSelectedTradingHouseGuildId (), tostring (CanSellOnTradingHouse (GetSelectedTradingHouseGuildId ())), GetNumTradingHouseListings ())
		return CanSellOnTradingHouse (GetSelectedTradingHouseGuildId ()) and GetNumTradingHouseListings ()
	elseif bagID == BAG_PLACED_FURNISHINGS then
		return IsOwnerOfCurrentHouse ()
	elseif bagID >= BAG_CUSTOM_MIN_VALUE and bagID < BAG_MAX_VALUE then
		return true
	else
		return false
	end
end
--XMT.IsBagAvailable = XMT_IsBagAvailable


--function Bags.IsBagTrackedAndAvailable (bagID)
function Bag.IsTrackedAndAvailable (bagID)
	return Bag.IsTracked (bagID) and Bag.IsAvailable (bagID)
end


LUXHRYS.Bag = Bag


-- ==================== [ State and Feature Tracking ] ===================== --


-------------------------------------------------------------------------------
--| Initialization |-----------------------------------------------------------
-------------------------------------------------------------------------------




function State:Initialize ()

	self.storeIsOpen = false
	self.mailboxIsOpen = false


end


-------------------------------------------------------------------------------
--| State Tracking |-----------------------------------------------------------
-------------------------------------------------------------------------------


function State:IsStoreOpen ()
	-- This is a little more robust than tracking ourselves, but there may be no buyback.
	return GetNumBuybackItems () > 0 or self.storeIsOpen == true
--[[	if GetNumBuybackItems () > 0 then
		return true
	else
		return self.storeIsOpen
	end]]
end


-- This function returns whether the player is reading mail. If true, then the mailbox must be open.

function State.IsPlayerReadingMail ()
	if IsConsoleUI () or IsInGamepadPreferredMode () then
		return GAMEPAD_MAIL_INBOX_FRAGMENT:IsShowing () or SCENE_MANAGER:IsShowing ("gamepad_mail_inbox")
-- Have also seen (SCENE_MANAGER:IsShowing("mailManagerGamepad") and MAIL_MANAGER_GAMEPAD.activeFragment == GAMEPAD_MAIL_INBOX_FRAGMENT)
	else
		return SCENE_MANAGER:IsShowing ("MailInbox")
	end
end


-- This function returns whether the mailbox is open. It should not to be conflated with the player reading mail, since we can open the mailbox programatically without the UI being shown.

function State:IsMailboxOpen ()
	return self.mailboxIsOpen == true or State.IsPlayerReadingMail ()
end


-------------------------------------------------------------------------------
--| Unlocked Feature Functions |-----------------------------------------------
-------------------------------------------------------------------------------


-- Check whether bags unlocked.
-- TODO: Deprecate this? called mostly by State.IsBagUnlocked and State.IsAnyHousingStorageCollected. Why not just include it there?
function State.IsHousingStorageCollected (bagID)
	return IsCollectibleUnlocked (GetCollectibleForBag (bagID))
end


function State.IsAnyHousingStorageCollected ()

	for bagID = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
		if State.IsHousingStorageCollected (bagID) then
			return true
		end
	end

	return false

end


function State.IsAnyCompanionCollected ()

	-- Thanks to Calamath: https://www.esoui.com/forums/showpost.php?p=44159&postcount=5

	for index = 1, GetTotalCollectiblesByCategoryType (COLLECTIBLE_CATEGORY_TYPE_COMPANION) do
			if IsCollectibleUnlocked (GetCollectibleIdFromType (COLLECTIBLE_CATEGORY_TYPE_COMPANION, index)) then
				return true
			end
	end
	return false
end


-- This function returns whether a player has a storage feature unlocked. Compare to Bag.IsAvailable, which evaluates whether a storage location is available at the moment.

function State.IsBagUnlocked (bagID)
	if not Bag.IsValid (bagID) then
		return false
	elseif bagID == BAG_SUBSCRIBER_BANK then
		return IsESOPlusSubscriber ()
	elseif bagID == BAG_GUILDBANK then
		local currentGuildID
		for i = 1, GetNumGuilds () do
			currentGuildID = GetGuildId (i)
			if DoesGuildHavePrivilege (currentGuildID, GUILD_PRIVILEGE_BANK_DEPOSIT)
			and DoesPlayerHaveGuildPermission (currentGuildID, GUILD_PERMISSION_BANK_WITHDRAW)
			then
				return true
			end
		end
		return false
	elseif bagID >= BAG_HOUSE_BANK_ONE and bagID <= BAG_HOUSE_BANK_TEN then
		return State.IsHousingStorageCollected (bagID)
	elseif bagID == BAG_COMPANION_WORN then
		return State.IsAnyCompanionCollected ()
	elseif bagID == BAG_FURNITURE_VAULT then
		return State.IsHousingStorageCollected (bagID) -- also available: IsCollectibleUnlocked (GetFurnitureVaultCollectibleId ())
--[[ TODO? Don't think we'll ever need to check whether we can deposit.
HOUSING_EDITOR_STATE:CanDepositIntoFurnitureVault()
]]
	elseif bagID == BAG_VENGEANCE then
		return GetUnitEffectiveLevel ("player") > 9
	elseif bagID == BAG_TRADER then
--		Debug.Msg (3, "IBA: Trader. Guild ID: %s. Can sell? %s. Num listings: %s.", GetSelectedTradingHouseGuildId (), tostring (CanSellOnTradingHouse (GetSelectedTradingHouseGuildId ())), GetNumTradingHouseListings ())
		local currentGuildID
		for i = 1, GetNumGuilds () do
			currentGuildID = GetGuildId (i)
			if DoesGuildHavePrivilege (currentGuildID, GUILD_PRIVILEGE_TRADING_HOUSE)
			and DoesPlayerHaveGuildPermission (currentGuildID, GUILD_PERMISSION_STORE_SELL) -- No easy way to find out whether player has listings while not in guild trader screen. Could probably be tracked with a flag.
			then
				return true
			end
		end
		return false
	elseif bagID == BAG_PLACED_FURNISHINGS then
		return GetHousingPrimaryHouse () ~= 0 -- TODO: Can a player who owns a home not have a primary set?
	elseif bagID >= BAG_CUSTOM_MIN_VALUE and bagID < BAG_MAX_VALUE then
		return true
	else
		return false
	end
end


LUXHRYS.STATE = State:New ()


-- ================================ [ Icons ] ============================== --


-------------------------------------------------------------------------------
--| Constants |----------------------------------------------------------------
-------------------------------------------------------------------------------


local addonAssetPath = ADDON_NAME .. "/Assets/"
--local addonAssetPath = "/XhrysTest/Assets/"

local ICON_STORAGE_BAG = addonAssetPath .. "bag_"
local ICON_STORAGE_BANK = addonAssetPath .. "bank_"
local ICON_STORAGE_BUYBACK = addonAssetPath .. "buyback_"
local ICON_STORAGE_COMPANION = addonAssetPath .. "companion_"
local ICON_STORAGE_CRAFT_BAG = addonAssetPath .. "craft_bag_"
local ICON_STORAGE_WORN = addonAssetPath .. "equipment_"
local ICON_STORAGE_VAULT = addonAssetPath .. "furniture_vault_"
local ICON_STORAGE_GUILD_BANK = addonAssetPath .. "guild_bank_"
local ICON_STORAGE_TRADER = addonAssetPath .. "guild_trader_"
local ICON_STORAGE_HOUSING_STORAGE = addonAssetPath .. "house_bank_"
local ICON_STORAGE_PLACED_FURNITURE = addonAssetPath .. "housing_"
local ICON_STORAGE_INBOX = addonAssetPath .. "mail_inbox_"
local ICON_STORAGE_CHARACTER = addonAssetPath .. "other_character_"
local ICON_STORAGE_VENGEANCE = addonAssetPath .. "vengeance_bag_"

local ICON_SMALL = "32.dds"
local ICON_LARGE = "64.dds"



--[[
icons.tooltipStackCount =
{
	[BAG_WORN] = ICON_STORAGE_WORN .. ICON_SMALL,
	[BAG_BACKPACK] = ICON_STORAGE_CHARACTER .. ICON_SMALL,
	[BAG_BANK] = ICON_STORAGE_BANK .. ICON_SMALL, -- Shouldn't need this
	[BAG_GUILDBANK] = ICON_STORAGE_GUILD_BANK .. ICON_SMALL,
	[BAG_BUYBACK] = ICON_STORAGE_BUYBACK .. ICON_SMALL,
	[BAG_VIRTUAL] = ICON_STORAGE_CRAFT_BAG .. ICON_SMALL, -- Shouldn't need this
	[BAG_SUBSCRIBER_BANK] = ICON_STORAGE_BANK .. ICON_SMALL, -- Shouldn't need this
	[BAG_HOUSE_BANK_ONE] = ICON_STORAGE_HOUSING_STORAGE .. ICON_SMALL,
	[BAG_HOUSE_BANK_TWO] = ICON_STORAGE_HOUSING_STORAGE .. ICON_SMALL,
	[BAG_HOUSE_BANK_THREE] = ICON_STORAGE_HOUSING_STORAGE .. ICON_SMALL,
	[BAG_HOUSE_BANK_FOUR] = ICON_STORAGE_HOUSING_STORAGE .. ICON_SMALL,
	[BAG_HOUSE_BANK_FIVE] = ICON_STORAGE_HOUSING_STORAGE .. ICON_SMALL,
	[BAG_HOUSE_BANK_SIX] = ICON_STORAGE_HOUSING_STORAGE .. ICON_SMALL,
	[BAG_HOUSE_BANK_SEVEN] = ICON_STORAGE_HOUSING_STORAGE .. ICON_SMALL,
	[BAG_HOUSE_BANK_EIGHT] = ICON_STORAGE_HOUSING_STORAGE .. ICON_SMALL,
	[BAG_HOUSE_BANK_NINE] = ICON_STORAGE_HOUSING_STORAGE .. ICON_SMALL,
	[BAG_HOUSE_BANK_TEN] = ICON_STORAGE_HOUSING_STORAGE .. ICON_SMALL,
	[BAG_COMPANION_WORN] = ICON_STORAGE_COMPANION .. ICON_SMALL,
	[BAG_FURNITURE_VAULT] = ICON_STORAGE_VAULT .. ICON_SMALL,
	[BAG_VENGEANCE] = ICON_STORAGE_VENGEANCE .. ICON_SMALL,
	[BAG_INBOX] = ICON_STORAGE_INBOX .. ICON_SMALL,
	[BAG_TRADER] = ICON_STORAGE_TRADER .. ICON_SMALL,
	[BAG_PLACED_FURNISHINGS] = ICON_STORAGE_PLACED_FURNITURE .. ICON_SMALL
}
]]

--[[
icons.tooltipStackCount =
{
	[LOCATION_TYPE_FILTER_ALL] = "EsoUI/Art/inventory/gamepad/gp_inventory_icon_miscellaneous.dds", -- Undefined / Miscellaneous / Placeholder to have the same number of elements in this table as extendedStackCounts.
	[LOCATION_TYPE_FILTER_BACKPACK] = ICON_STORAGE_CHARACTER .. ICON_SMALL, -- BAG_BACKPACK
	[LOCATION_TYPE_FILTER_COLLECTIBLE_STORAGE] = ICON_STORAGE_HOUSING_STORAGE .. ICON_SMALL, -- BAG_HOUSE_BANK_ONE
	[LOCATION_TYPE_FILTER_FURNITURE_VAULT] = ICON_STORAGE_VAULT .. ICON_SMALL, -- BAG_FURNITURE_VAULT
	[LOCATION_TYPE_FILTER_HOUSE] = ICON_STORAGE_PLACED_FURNITURE .. ICON_SMALL, -- BAG_PLACED_FURNISHINGS
	[LOCATION_TYPE_FILTER_TRADER] = ICON_STORAGE_TRADER .. ICON_SMALL, -- BAG_TRADER
	[LOCATION_TYPE_FILTER_INBOX] = ICON_STORAGE_INBOX .. ICON_SMALL, -- BAG_INBOX
	[LOCATION_TYPE_FILTER_GUILD] = ICON_STORAGE_GUILD_BANK .. ICON_SMALL, -- BAG_GUILDBANK
	[LOCATION_TYPE_FILTER_WORN] = ICON_STORAGE_WORN .. ICON_SMALL, -- BAG_WORN
	[LOCATION_TYPE_FILTER_BUYBACK] = ICON_STORAGE_BUYBACK .. ICON_SMALL, -- BAG_BUYBACK
	[LOCATION_TYPE_FILTER_COMPANION] = ICON_STORAGE_COMPANION .. ICON_SMALL, -- BAG_COMPANION_WORN
	[LOCATION_TYPE_FILTER_VENGEANCE] = ICON_STORAGE_VENGEANCE .. ICON_SMALL -- BAG_VENGEANCE
}
]]

icons.general =
{
	ICON_NEW_ORIGINAL_MINT_32 = addonAssetPath .. "new_icon_mint.dds",
	ICON_NEW_ORIGINAL_MINT_64 = addonAssetPath .. "gp_icon_new_64_mint.dds",
	ICON_NEW_SMALL = addonAssetPath .. "new_" .. ICON_SMALL,
	ICON_NEW_LARGE = addonAssetPath .. "new_" .. ICON_LARGE,
	ICON_BAG_BACKPACK_SMALL = ICON_STORAGE_BAG .. ICON_SMALL,
	ICON_BAG_BACKPACK_LARGE = ICON_STORAGE_BAG .. ICON_LARGE,
	ICON_OTHER_CHARACTER_SMALL = ICON_STORAGE_CHARACTER .. ICON_SMALL,
	ICON_OTHER_CHARACTER_LARGE = ICON_STORAGE_CHARACTER .. ICON_LARGE,
	ICON_COMPANION_EQUIPPED_SMALL = ICON_STORAGE_COMPANION .. ICON_SMALL,
	ICON_COMPANION_EQUIPPED_LARGE = ICON_STORAGE_COMPANION .. ICON_LARGE,
	ICON_HOUSE_SMALL = ICON_STORAGE_PLACED_FURNITURE .. ICON_SMALL,
	ICON_HOUSE_LARGE = ICON_STORAGE_PLACED_FURNITURE .. ICON_LARGE,
	ICON_TRADER_SMALL = ICON_STORAGE_TRADER .. ICON_SMALL,
	ICON_TRADER_LARGE = ICON_STORAGE_TRADER .. ICON_LARGE,
	ICON_CRAFTING_LARGE = "EsoUI/Art/Icons/mapKey/mapKey_crafting.dds",
	ICON_SOURCING_VALUE_LARGE = "EsoUI/Art/Icons/servicetooltipicons/gamepad/gp_servicetooltipicon_generalgoods.dds",
	ICON_VENDOR_SMALL = "EsoUI/Art/Icons/mapKey/mapKey_vendor.dds",
	ICON_VENDOR_LARGE = "EsoUI/Art/Icons/mapKey/mapKey_vendor.dds",
	ICON_CURRENCY_GOLD_SMALL = GetCurrencyKeyboardIcon (CURT_MONEY),
	ICON_CURRENCY_GOLD_LARGE = GetCurrencyGamepadIcon (CURT_MONEY),
	ICON_CURRENCY_CROWN_SMALL = GetCurrencyKeyboardIcon (CURT_CROWNS),
	ICON_CURRENCY_CROWN_LARGE = GetCurrencyGamepadIcon (CURT_CROWNS),
	ICON_CURRENCY_AP_SMALL = GetCurrencyKeyboardIcon (CURT_ALLIANCE_POINTS),
	ICON_CURRENCY_AP_LARGE = GetCurrencyGamepadIcon (CURT_ALLIANCE_POINTS),
	ICON_CURRENCY_TELVAR_SMALL = GetCurrencyKeyboardIcon (CURT_TELVAR_STONES),
	ICON_CURRENCY_TELVAR_LARGE = GetCurrencyGamepadIcon (CURT_TELVAR_STONES),
	ICON_CURRENCY_VOUCHERS_SMALL = GetCurrencyKeyboardIcon (CURT_WRIT_VOUCHERS),
	ICON_CURRENCY_VOUCHERS_LARGE = GetCurrencyGamepadIcon (CURT_WRIT_VOUCHERS),
	ICON_CURRENCY_GEMS_SMALL = GetCurrencyKeyboardIcon (CURT_CROWN_GEMS),
	ICON_CURRENCY_GEMS_LARGE = GetCurrencyGamepadIcon (CURT_CROWN_GEMS),
	ICON_CURRENCY_SEALS_SMALL = GetCurrencyKeyboardIcon (CURT_SEALS),
	ICON_CURRENCY_SEALS_LARGE = GetCurrencyGamepadIcon (CURT_SEALS),
	ICON_CURRENCY_TRADEBARS_SMALL = GetCurrencyKeyboardIcon (CURT_TRADE_BARS),
	ICON_CURRENCY_TRADEBARS_LARGE = GetCurrencyGamepadIcon (CURT_TRADE_BARS),
	ICON_CURRENCY_KEYS_SMALL = GetCurrencyKeyboardIcon (CURT_UNDAUNTED_KEYS),
	ICON_CURRENCY_KEYS_LARGE = GetCurrencyGamepadIcon (CURT_UNDAUNTED_KEYS),
	ICON_CURRENCY_FORTUNES_SMALL = GetCurrencyKeyboardIcon (CURT_ARCHIVAL_FORTUNES),
	ICON_CURRENCY_FORTUNES_LARGE = GetCurrencyGamepadIcon (CURT_ARCHIVAL_FORTUNES),
	ICON_CURRENCY_TOMES_SMALL = GetCurrencyKeyboardIcon (CURT_TOME_POINTS),
	ICON_CURRENCY_TOMES_LARGE = GetCurrencyGamepadIcon (CURT_TOME_POINTS),
	ICON_CURRENCY_FRAGMENTS_SMALL = GetCurrencyKeyboardIcon (CURT_IMPERIAL_FRAGMENTS),
	ICON_CURRENCY_FRAGMENTS_LARGE = GetCurrencyGamepadIcon (CURT_IMPERIAL_FRAGMENTS),
--[[	ICON_CURRENCY_PROOF_SMALL = GetCurrencyKeyboardIcon (currencyType),
	ICON_CURRENCY_PROOF_LARGE = GetCurrencyGamepadIcon (currencyType),
	ICON_CURRENCY_TOKEN_SMALL = GetCurrencyKeyboardIcon (currencyType),
	ICON_CURRENCY_TOKEN_LARGE = GetCurrencyGamepadIcon (currencyType),
	ICON_CURRENCY_MERIT_SMALL = GetCurrencyKeyboardIcon (currencyType),
	ICON_CURRENCY_MERIT_LARGE = GetCurrencyGamepadIcon (currencyType)]]
}

--XMT_GAMEPAD_NEW_ICON_64 = ADDON_NAME .. "/Assets/gp_icon_new_64_mint.dds"
--XMT_KEYBOARD_NEW_ICON = ADDON_NAME .. "/Assets/new_icon_mint.dds"
--[[
icons.currency =
{
	CURT_MONEY = icons.general.ICON_CURRENCY_GOLD_LARGE,
	CURT_CROWNS = ICON_CURRENCY_CROWN_LARGE,
	CURT_ALLIANCE_POINTS = ICON_CURRENCY_AP_LARGE
	CURT_TELVAR_STONES = ICON_CURRENCY_TELVAR_LARGE
	CURT_WRIT_VOUCHERS = ICON_CURRENCY_VOUCHERS_LARGE
	CURT_CROWN_GEMS = ICON_CURRENCY_GEMS_LARGE
	CURT_SEALS = ICON_CURRENCY_SEALS_LARGE
	CURT_TRADE_BARS = ICON_CURRENCY_TRADEBARS_LARGE
	CURT_UNDAUNTED_KEYS = ICON_CURRENCY_KEYS_LARGE
	CURT_ARCHIVAL_FORTUNES = ICON_CURRENCY_FORTUNES_LARGE
	CURT_TOME_POINTS = ICON_CURRENCY_TOMES_LARGE
	CURT_IMPERIAL_FRAGMENTS = ICON_CURRENCY_FRAGMENTS_LARGE
	 = ICON_CURRENCY_PROOF_LARGE
	 = ICON_CURRENCY_TOKEN_LARGE
	 = ICON_CURRENCY_MERIT_LARGE

}
]]
-- TODO: find 32x32 versions?
icons.tooltipCurrency =
{
	Gold64 = "bank/bank_tabicon_gold_up.dds",
	Telvar64 = "bank/bank_tabicon_telvar_up.dds"

}


LUXHRYS.icons = icons


-- ============================ [ Location Types and Codes ] =========================== --




-------------------------------------------------------------------------------
--| Location Types and Filters |-----------------------------------------------
-------------------------------------------------------------------------------

-- Location types


local LOCATION_TYPE_BAG =									1
local LOCATION_TYPE_CHAR =								2
local LOCATION_TYPE_GUILD =								3
local LOCATION_TYPE_HOUSE =								4
local LOCATION_TYPE_BUYBACK =							5
local LOCATION_TYPE_INBOX =								6
local LOCATION_TYPE_COMPANION =						7
local LOCATION_TYPE_COLLECTIBLE_STORAGE =	8
local LOCATION_TYPE_TRADER =							9
local LOCATION_TYPE_VENGEANCE =						10
local LOCATION_TYPE_WORN =								11


--XMT.LOCATION_TYPE_COMBINED = LOCATION_TYPE_COMBINED
Location.LOCATION_TYPE_BAG = LOCATION_TYPE_BAG
Location.LOCATION_TYPE_CHAR = LOCATION_TYPE_CHAR
Location.LOCATION_TYPE_GUILD = LOCATION_TYPE_GUILD
Location.LOCATION_TYPE_HOUSE = LOCATION_TYPE_HOUSE
Location.LOCATION_TYPE_BUYBACK = LOCATION_TYPE_BUYBACK
Location.LOCATION_TYPE_INBOX = LOCATION_TYPE_INBOX
Location.LOCATION_TYPE_COMPANION = LOCATION_TYPE_COMPANION
Location.LOCATION_TYPE_COLLECTIBLE_STORAGE = LOCATION_TYPE_COLLECTIBLE_STORAGE
Location.LOCATION_TYPE_TRADER = LOCATION_TYPE_TRADER
Location.LOCATION_TYPE_VENGEANCE = LOCATION_TYPE_VENGEANCE
Location.LOCATION_TYPE_WORN = LOCATION_TYPE_WORN


-- Location type filter categories.


local LOCATION_TYPE_FILTER_MIN = 1
local LOCATION_TYPE_FILTER_ALL = 1
local LOCATION_TYPE_FILTER_BACKPACK = 2
local LOCATION_TYPE_FILTER_COLLECTIBLE_STORAGE = 3
local LOCATION_TYPE_FILTER_FURNITURE_VAULT = 4
local LOCATION_TYPE_FILTER_HOUSE = 5
local LOCATION_TYPE_FILTER_TRADER = 6
local LOCATION_TYPE_FILTER_INBOX = 7
local LOCATION_TYPE_FILTER_GUILD = 8
local LOCATION_TYPE_FILTER_WORN = 9
local LOCATION_TYPE_FILTER_BUYBACK = 10
local LOCATION_TYPE_FILTER_COMPANION = 11
local LOCATION_TYPE_FILTER_VENGEANCE = 12
local LOCATION_TYPE_FILTER_MAX = 12


Location.LOCATION_TYPE_FILTER_MIN = LOCATION_TYPE_FILTER_MIN
Location.LOCATION_TYPE_FILTER_ALL = LOCATION_TYPE_FILTER_ALL
Location.LOCATION_TYPE_FILTER_BACKPACK = LOCATION_TYPE_FILTER_BACKPACK
Location.LOCATION_TYPE_FILTER_COLLECTIBLE_STORAGE = LOCATION_TYPE_FILTER_COLLECTIBLE_STORAGE
Location.LOCATION_TYPE_FILTER_FURNITURE_VAULT = LOCATION_TYPE_FILTER_FURNITURE_VAULT
Location.LOCATION_TYPE_FILTER_HOUSE = LOCATION_TYPE_FILTER_HOUSE
Location.LOCATION_TYPE_FILTER_TRADER = LOCATION_TYPE_FILTER_TRADER
Location.LOCATION_TYPE_FILTER_INBOX = LOCATION_TYPE_FILTER_INBOX
Location.LOCATION_TYPE_FILTER_GUILD = LOCATION_TYPE_FILTER_GUILD
Location.LOCATION_TYPE_FILTER_WORN = LOCATION_TYPE_FILTER_WORN
Location.LOCATION_TYPE_FILTER_BUYBACK = LOCATION_TYPE_FILTER_BUYBACK
Location.LOCATION_TYPE_FILTER_COMPANION = LOCATION_TYPE_FILTER_COMPANION
Location.LOCATION_TYPE_FILTER_VENGEANCE = LOCATION_TYPE_FILTER_VENGEANCE
Location.LOCATION_TYPE_FILTER_MAX = LOCATION_TYPE_FILTER_MAX


local locationTypeFilters =
{
	{ -- LOCATION_TYPE_FILTER_ALL
		bag = -100,
		name = GetString (SI_GAMEPAD_HOUSING_FURNITURE_LOCATION_FILTER_ALL_TEXT),
		tooltipIcon = "EsoUI/Art/inventory/gamepad/gp_inventory_icon_miscellaneous.dds"
	},
	{ -- LOCATION_TYPE_FILTER_BACKPACK
		bag = BAG_BACKPACK,
		name = GetString (SI_CURRENCYLOCATION0) .. " " .. GetString (SI_GAMEPAD_INVENTORY_CATEGORY_HEADER),
		tooltipIcon = ICON_STORAGE_CHARACTER .. ICON_SMALL
	},
	{ -- LOCATION_TYPE_FILTER_COLLECTIBLE_STORAGE
		bag = BAG_HOUSE_BANK_ONE,
		name = GetString (SI_HOUSINGFURNITURELOCATIONFILTER8),
		tooltipIcon = ICON_STORAGE_HOUSING_STORAGE .. ICON_SMALL
	},
	{ -- LOCATION_TYPE_FILTER_FURNITURE_VAULT
		bag = BAG_FURNITURE_VAULT,
		name = GetString (SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_FURNITURE_VAULT),
		tooltipIcon = ICON_STORAGE_VAULT .. ICON_SMALL
	},
	{ -- LOCATION_TYPE_FILTER_HOUSE
		bag = BAG_PLACED_FURNISHINGS,
		name = GetString (SI_COLLECTIBLECATEGORYTYPE19) .. " " .. GetString (SI_GENERIC_FURNITURE_TEXT),
		tooltipIcon = ICON_STORAGE_PLACED_FURNITURE .. ICON_SMALL
	},
	{ -- LOCATION_TYPE_FILTER_TRADER
		bag = BAG_TRADER,
		name = GetString (SI_GUILDMETADATAATTRIBUTE8),
		tooltipIcon = ICON_STORAGE_TRADER .. ICON_SMALL
	},
	{ -- LOCATION_TYPE_FILTER_INBOX
		bag = BAG_INBOX,
		name = GetString (SI_WINDOW_TITLE_INBOX_MAIL),
		tooltipIcon = ICON_STORAGE_INBOX .. ICON_SMALL
	},
	{ -- LOCATION_TYPE_FILTER_GUILD
		bag = BAG_GUILDBANK,
		name = GetString (SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER),
		tooltipIcon = ICON_STORAGE_GUILD_BANK .. ICON_SMALL
	},
	{ -- LOCATION_TYPE_FILTER_WORN
		bag = BAG_WORN,
		name = GetString (SI_GAMEPAD_EQUIPPED_ITEM_HEADER),
		tooltipIcon = ICON_STORAGE_WORN .. ICON_SMALL
	},
	{ -- LOCATION_TYPE_FILTER_BUYBACK
		bag = BAG_BUYBACK,
		name = GetString (SI_ITEMFILTERTYPE8),
		tooltipIcon = ICON_STORAGE_BUYBACK .. ICON_SMALL
	},
	{ -- LOCATION_TYPE_FILTER_COMPANION
		bag = BAG_COMPANION_WORN,
		name = GetString (SI_GAMEPAD_EQUIPPED_COMPANION_ITEM_HEADER),
		tooltipIcon = ICON_STORAGE_COMPANION .. ICON_SMALL
	},
	{ -- LOCATION_TYPE_FILTER_VENGEANCE
		bag = BAG_VENGEANCE,
		name = GetString (SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_VENGEANCE),
		tooltipIcon = ICON_STORAGE_VENGEANCE .. ICON_SMALL
	}
}

Location.locationTypeFilters = locationTypeFilters

--[[
local locationTypeBagMap =
{
	[LOCATION_TYPE_FILTER_ALL] = -100, -- Placeholder to have ma
	[LOCATION_TYPE_FILTER_BACKPACK] = BAG_BACKPACK,
	[LOCATION_TYPE_FILTER_COLLECTIBLE_STORAGE] = BAG_HOUSE_BANK_ONE,
	[LOCATION_TYPE_FILTER_FURNITURE_VAULT] = BAG_FURNITURE_VAULT,
	[LOCATION_TYPE_FILTER_HOUSE] = BAG_PLACED_FURNISHINGS,
	[LOCATION_TYPE_FILTER_TRADER] = BAG_TRADER,
	[LOCATION_TYPE_FILTER_INBOX] = BAG_INBOX,
	[LOCATION_TYPE_FILTER_GUILD] = BAG_GUILDBANK,
	[LOCATION_TYPE_FILTER_WORN] = BAG_WORN,
	[LOCATION_TYPE_FILTER_BUYBACK] = BAG_BUYBACK,
	[LOCATION_TYPE_FILTER_COMPANION] = BAG_COMPANION_WORN,
	[LOCATION_TYPE_FILTER_VENGEANCE] = BAG_VENGEANCE
}
]]

-- User-facing names, mainly for tab titles.

--[[ USE LOCALIZED VERSION BELOW
local locationFilterTypeNames =
{
	[LOCATION_FILTER_TYPE_ALL] =									"ALL LOCATIONS",
	[LOCATION_FILTER_TYPE_BACKPACK] =							"BACKPACK",
	[LOCATION_FILTER_TYPE_COLLECTIBLE_STORAGE] =	"GUILD BANK",
	[LOCATION_FILTER_TYPE_FURNITURE_VAULT] =			"PLACED FURNITURE",
	[LOCATION_FILTER_TYPE_HOUSE] =								"BUYBACK",
	[LOCATION_FILTER_TYPE_TRADER] =								"INBOX",
	[LOCATION_FILTER_TYPE_INBOX] =								"COMPANION",
	[LOCATION_FILTER_TYPE_GUILD] =								"HOUSING STORAGE",
	[LOCATION_FILTER_TYPE_WORN] =									"GUILD TRADER",
	[LOCATION_FILTER_TYPE_BUYBACK] =							"VENGEANCE",
	[LOCATION_FILTER_TYPE_COMPANION] =						"EQUIPPED"
	[LOCATION_FILTER_TYPE_VENGEANCE] =
}


local locationTypeFilterNames =
{
	[LOCATION_TYPE_FILTER_ALL] =									GetString (SI_GAMEPAD_HOUSING_FURNITURE_LOCATION_FILTER_ALL_TEXT),
	[LOCATION_TYPE_FILTER_BACKPACK] =							GetString (SI_CURRENCYLOCATION0) .. " " .. GetString (SI_GAMEPAD_INVENTORY_CATEGORY_HEADER),
	[LOCATION_TYPE_FILTER_COLLECTIBLE_STORAGE] =	GetString (SI_HOUSINGFURNITURELOCATIONFILTER8),
	[LOCATION_TYPE_FILTER_FURNITURE_VAULT] =			GetString (SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_FURNITURE_VAULT),
	[LOCATION_TYPE_FILTER_HOUSE] =								GetString (SI_COLLECTIBLECATEGORYTYPE19) .. " " .. GetString (SI_GENERIC_FURNITURE_TEXT),
--SI_MODINSTALLSTATE3 "PLACED FURNITURE",SI_GROUP_FINDER_TOOLTIP_APPLIED_LABEL SI_CRAFTED_ABILITY_SLOTTED_TOOLTIP_HEADER SI_CRAFTED_ABILITY_CONFIGURED_TOOLTIP_HEADER
	[LOCATION_TYPE_FILTER_TRADER] =								GetString (SI_GUILDMETADATAATTRIBUTE8),
	[LOCATION_TYPE_FILTER_INBOX] =								GetString (SI_WINDOW_TITLE_INBOX_MAIL),
	[LOCATION_TYPE_FILTER_GUILD] =								GetString (SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER),
	[LOCATION_TYPE_FILTER_WORN] =									GetString (SI_GAMEPAD_EQUIPPED_ITEM_HEADER),
	[LOCATION_TYPE_FILTER_BUYBACK] =							GetString (SI_ITEMFILTERTYPE8),
	[LOCATION_TYPE_FILTER_COMPANION] =						GetString (SI_GAMEPAD_EQUIPPED_COMPANION_ITEM_HEADER),
	[LOCATION_TYPE_FILTER_VENGEANCE] = 						GetString (SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_VENGEANCE)
}
]]

--[[ LOCALIZED VERSION
local locationTypeNames =
{
	[LOCATION_TYPE_BAG] =									"ALL LOCATIONS", SI_GAMEPAD_HOUSING_FURNITURE_LOCATION_FILTER_ALL_TEXT
	[LOCATION_TYPE_CHAR] =								"BACKPACK", SI_BUGCATEGORY0 or SI_CURRENCYLOCATION0 + SI_GAMEPAD_INVENTORY_CATEGORY_HEADER
	[LOCATION_TYPE_GUILD] =								GetString (SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER),
	[LOCATION_TYPE_HOUSE] =								"PLACED FURNITURE", SI_HOUSING_FURNITURE_TAB_PLACE + SI_GENERIC_FURNITURE_TEXT
	[LOCATION_TYPE_BUYBACK] =							"BUYBACK", SI_ITEMFILTERTYPE8
	[LOCATION_TYPE_INBOX] =								"INBOX", SI_WINDOW_TITLE_INBOX_MAIL
	[LOCATION_TYPE_COMPANION] =						"COMPANION", SI_GAMEPAD_EQUIPPED_COMPANION_ITEM_HEADER
	[LOCATION_TYPE_COLLECTIBLE_STORAGE] =	"HOUSING STORAGE", SI_HOUSINGFURNITURELOCATIONFILTER8 or SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_HOUSE_BANK
	[LOCATION_TYPE_TRADER] =							"GUILD TRADER", SI_GUILDMETADATAATTRIBUTE8
	[LOCATION_TYPE_VENGEANCE] =						"VENGEANCE", SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_VENGEANCE
	[LOCATION_TYPE_WORN] =								"EQUIPPED" , SI_GAMEPAD_EQUIPPED_ITEM_HEADER or SI_CRAFT_ADVISOR_TOOLTIP_EQUIP_TAB
}

-- SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_FURNITURE_VAULT
]]

--function Location.GetLocationTypeFilterName (locationFilterType, upperCase)
function Location.GetTypeFilterName (locationFilterType, upperCase)

	if not locationFilterType or locationFilterType == "" then
		return nil
	end

	if upperCase and upperCase == true then
		return ToUpper (locationTypeFilters[locationFilterType].name)
	else
		return locationTypeFilters[locationFilterType].name
	end

end


-------------------------------------------------------------------------------
--| Location Code Functions |--------------------------------------------------
-------------------------------------------------------------------------------



-- Location code prefixes. TODO: RENAME!!!

local LOCATION_TYPE_CODE_PREFIX =
{
	[LOCATION_TYPE_BAG] =										"B", -- bagID
	[LOCATION_TYPE_CHAR] =									"C", -- characterID
	[LOCATION_TYPE_GUILD] =									"G", -- guildID
	[LOCATION_TYPE_HOUSE] =									"H", -- houseID, for placed furnishings
	[LOCATION_TYPE_BUYBACK] =								"K", -- characterID, since each character has their own
	[LOCATION_TYPE_INBOX] =									"M", -- mailID
	[LOCATION_TYPE_COMPANION] =							"N", -- collectible ID; companionDefID is unique to each character, it appears
	[LOCATION_TYPE_COLLECTIBLE_STORAGE] =		"S", -- functionally an alias to all the BAG_HOUSE_BANK_... locations
	[LOCATION_TYPE_TRADER] =								"T", -- guildID
	[LOCATION_TYPE_VENGEANCE] =							"V", -- characterID
	[LOCATION_TYPE_WORN] =									"W" -- characterID
}
Location.LOCATION_TYPE_CODE_PREFIX = LOCATION_TYPE_CODE_PREFIX


-- Given a location code letter prefix, returns the numeric location type.

--function Location.GetLocationCodePrefixLocationType (locationCodePrefix)
function Location.GetCodePrefixType (locationCodePrefix)

	if not locationCodePrefix or locationCodePrefix == "" then
		return nil
	end

	for locationType, locationTypePrefix in ipairs (LOCATION_TYPE_CODE_PREFIX) do
		if locationTypePrefix == locationCodePrefix then
			return locationType
		end
	end

	return nil

end


-- Given a location code, returns the numeric location type and the location ID.

--function Location.GetLocationCodeLocationTypeAndID (locationCode)
function Location.GetCodeTypeAndID (locationCode)

	if not locationCode or locationCode == "" then
		return nil
	end

	return Location.GetCodePrefixType (locationCode:sub (1, 1)), Location.GetCodeID (locationCode)

end


-- Given a numeric location type, returns the location type letter prefix.

--function Location.GetLocationTypeLocationPrefix (locationType)
function Location.GetTypePrefix (locationType)
--TODO: Robustify with type checks?

	if locationType and type (locationType) == "number" then
		return LOCATION_TYPE_CODE_PREFIX[locationType]
	end

	return nil

end


-- Given a location type and locationID, returns the location code.

--function Location.GetLocationCode (locationType, locationID)
function Location.GetCode (locationType, locationID)

	if not locationType or not locationID or locationType == "" or locationID == "" then
		return nil
	end


	-- If the location type uses a character ID as the location, use an alias to reduce database size.

	if locationType == LOCATION_TYPE_CHAR
	or locationType == LOCATION_TYPE_BUYBACK
	or locationType == LOCATION_TYPE_VENGEANCE
	or locationType == LOCATION_TYPE_WORN
	then
		locationID = ToString (DBLOOKUP:GetOrCreateCharacterIDAlias (locationID))
	end

	return Location.GetTypePrefix (locationType) .. (locationID)

end


-- Given a location code, returns the location ID.

--function Location.GetLocationCodeLocationID (locationCode)
function Location.GetCodeID (locationCode)

	if not locationCode or locationCode == "" then
		return nil
	end

	return locationCode:sub (2)

end


-- Get location code for current character, location, and interaction status.

--function Location.GetLocationCodeForBagInCurrentState (bagID, extraInformation)
function Location.GetCodeForBagInCurrentState (bagID, extraInformation)

--	Debug.Msg (2, "GLCFBICS called. Bag %d, extraInformation %s.", bagID, extraInformation or "--")

	if not bagID then return nil end
--[[ These other conditions seem too limiting; we might want the location code even just to read the db.
	or not XMT_IsBagTracked (bagID)
	or not XMT_IsBagAvailable (bagID)
	then
		bagID = bagID or nil
		local bTracked = XMT_IsBagTracked (bagID) or nil
		local bAvailable = XMT_IsBagAvailable (bagID) or nil
		Debug.Msg (1, "GLCFBICS failed: Bag %s, Is Tracked: %s, Is Available: %s.",
			tostring (bagID), tostring (bTracked), tostring (bAvailable))
		return nil
	end
]]
	if bagID == BAG_WORN then
--		Debug.Msg (4, "GLCFBICS: Returning %s.", Location.GetLocationCode (LOCATION_TYPE_WORN, GetCurrentCharacterId ()))
		return Location.GetCode (LOCATION_TYPE_WORN, GetCurrentCharacterId ())
	elseif bagID == BAG_BACKPACK then
--		Debug.Msg (4, "GLCFBICS: Returning %s.", Location.GetLocationCode (LOCATION_TYPE_CHAR, GetCurrentCharacterId ()))
		return Location.GetCode (LOCATION_TYPE_CHAR, GetCurrentCharacterId ())
	elseif bagID == BAG_GUILDBANK then
		return Location.GetCode (LOCATION_TYPE_GUILD, GetSelectedGuildBankId ())
	elseif bagID == BAG_BUYBACK then
		return Location.GetCode (LOCATION_TYPE_BUYBACK, GetCurrentCharacterId ())
	elseif bagID == BAG_HOUSE_BANK_ONE
	or bagID == BAG_HOUSE_BANK_ONE
	or bagID == BAG_HOUSE_BANK_TWO
	or bagID == BAG_HOUSE_BANK_THREE
	or bagID == BAG_HOUSE_BANK_FOUR
	or bagID == BAG_HOUSE_BANK_FIVE
	or bagID == BAG_HOUSE_BANK_SIX
	or bagID == BAG_HOUSE_BANK_SEVEN
	or bagID == BAG_HOUSE_BANK_EIGHT
	or bagID == BAG_HOUSE_BANK_NINE
	or bagID == BAG_HOUSE_BANK_TEN
	or bagID == BAG_FURNITURE_VAULT
--	or bagID == BAG_BANK -- never tracked
--	or bagID == BAG_VIRTUAL -- never tracked
--	or bagID == BAG_SUBSCRIBER_BANK -- never tracked
	then
		return Location.GetCode (LOCATION_TYPE_BAG, bagID)
	elseif bagID == BAG_COMPANION_WORN then
		return Location.GetCode (LOCATION_TYPE_COMPANION, GetCompanionCollectibleId (GetActiveCompanionDefId ()))
	elseif bagID == BAG_VENGEANCE then
		return Location.GetCode (LOCATION_TYPE_VENGEANCE, GetCurrentCharacterId ())
	elseif bagID == BAG_PLACED_FURNISHINGS then
		return Location.GetCode (LOCATION_TYPE_HOUSE, GetCurrentZoneHouseId ())
	elseif bagID == BAG_INBOX then
--		extraInformation = tonumber (extraInformation) or 0
		extraInformation = extraInformation or 0
--		Debug.Msg (3, "GLCFBICS: Returning %s.", Location.GetLocationCode (LOCATION_TYPE_INBOX, extraInformation))
		return Location.GetCode (LOCATION_TYPE_INBOX, extraInformation)
	elseif bagID == BAG_TRADER then
		return Location.GetCode (LOCATION_TYPE_TRADER, GetSelectedTradingHouseGuildId ())
	else
		return nil
	end

end


LUXHRYS.Location = Location


-- ===================== [ itemLink Utility Functions ] ==================== --




-------------------------------------------------------------------------------
--| Link Creation Functions |--------------------------------------------------
-------------------------------------------------------------------------------


-- TODO: ZOS has Lua functions for some of this. Not sure which are better.

local function CreateFullItemLinkFromItemInfo (linkStyle, itemID, itemSubType, internalLevel, enchantId, enchantSubType, enchantLevel, writ1OrTransmuteTrait, writ2, writ3, writ4, writ5, writ6, flags, itemStyle, isCrafted, isBound, isStolen, charges, potionEffectOrWritReward, displayName)

		return StrFormat ("|H%d:item:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d:0:0:%d:%d:%d:%d:%d:%d:%d|h%s|h", linkStyle, itemID, itemSubType, internalLevel, enchantId, enchantSubType, enchantLevel, writ1OrTransmuteTrait, writ2, writ3, writ4, writ5, writ6, flags, itemStyle, isCrafted, isBound, isStolen, charges, potionEffectOrWritReward, displayName)

end


local function CreateSimpleItemLinkForMatching (itemLink)

-- Only consider base item, level/CP, itemID, quality, and trait. TODO: also consider style? maybe make it an option?

		return itemLink.gsub ("|H%d:item:(%d+:%d+:%d+):%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d:%d:%d+:(%d+):%d+:%d+:%d+:%d+:%d+|h(%w+)|h", ("|H0:item:%1:0:0:0:0:0:0:0:0:0:0:0:0:%2:0:0:0:0:0|h%3|h"))

end


local function CreatePartialItemLinkFromItemInfo (linkStyle, itemID, itemSubType, internalLevel, enchantId, enchantSubType, enchantLevel, itemStyle, isCrafted, displayName)

	-- Trust we are receiving good args. TODO: check arg validity.

	return StrFormat ("|H%d:item:%d:%d:%d:%d:%d:%d:0:0:0:0:0:0:0:0:0:%d:%d:0:0:10000:0|h%s|h", linkStyle, itemID, itemSubType, internalLevel, enchantId, enchantSubType, enchantLevel, itemStyle, isCrafted, displayName)

end


function LinkUtils.CreateSimpleItemLinkFromItemID (itemID)

--	return "|H1:item:" .. itemID .. ":1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h"
	return "|H1:item:" .. itemID .. ":1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"

end


-------------------------------------------------------------------------------
--| Link Utility Functions |---------------------------------------------------
-------------------------------------------------------------------------------


-- Can accept links or IDs. Will not return robust matching on IDs for gear or other items that need links, so it is only as good as the data passed to it.
function LinkUtils.ItemLinksMatchForCounting (itemLink1, itemLink2)

	if type (itemLink1) == "number" then
		if type (itemLink2) == "number" then
			return itemLink1 == itemLink2 -- both are numbers (IDs)
		else
			return itemLink1 == GetItemLinkItemId (itemLink2) -- one is an ID and the other a link, match only on ID? Or should we do it the other way around?
		end
	else
		if type (itemLink2) == "number" then
			return GetItemLinkItemId (itemLink1) == itemLink2 -- one is a link and the other an ID, match only on ID
		else
			-- First check to see if itemIDs are the same. If not, we don't need to worry about the rest.

			if GetItemLinkItemId (itemLink1) ~= GetItemLinkItemId (itemLink2) then return false end

			-- Here is where we have to consider level/CP, itemID, quality, and trait. We will NOT match on enchantment (unless it's a glyph).

			return CreateSimpleItemLinkForMatching (itemLink1) == CreateSimpleItemLinkForMatching (itemLink2)

		end
	end

end


local itemTypeNeedsLink = { -- TODO: look up uncertain items to see if their links encode any information.
	[ITEMTYPE_NONE] =													false,
	[ITEMTYPE_WEAPON] =												true,		-- Probably too difficult to determine whether it is a base item.
	[ITEMTYPE_ARMOR] =												true,		-- Probably too difficult to determine whether it is a base item.
	[ITEMTYPE_PLUG] =													true,		-- What is this?
	[ITEMTYPE_FOOD] =													true,		-- Not sure on this one.
	[ITEMTYPE_TROPHY] =												true,		-- Alliance information is probably in link; do we care?
	[ITEMTYPE_SIEGE] =												true,		-- Alliance information is probably in link; do we care?
	[ITEMTYPE_POTION] =												true,
	[ITEMTYPE_RACIAL_STYLE_MOTIF] =						false,	-- We don't care about level information.
	[ITEMTYPE_TOOL] =													false,	-- I don't think so, but there may be exceptions.
	[ITEMTYPE_INGREDIENT] =										false,	-- Can store in craft bag.
	[ITEMTYPE_ADDITIVE] =											false,	-- Can store in craft bag.
	[ITEMTYPE_DRINK] =												true,		-- Not sure on this one.
	[ITEMTYPE_COSTUME] =											false,
	[ITEMTYPE_DISGUISE] =											false,
	[ITEMTYPE_TABARD] =												true,		-- Not sure on this one. Might have guild info?
	[ITEMTYPE_LURE] =													false,	-- Can store in craft bag.
	[ITEMTYPE_RAW_MATERIAL] =									false,	-- Can store in craft bag.
	[ITEMTYPE_CONTAINER] =										true,
	[ITEMTYPE_SOUL_GEM] =											true,		-- Not sure on this one.
	[ITEMTYPE_GLYPH_WEAPON] =									true,
	[ITEMTYPE_GLYPH_ARMOR] =									true,
	[ITEMTYPE_LOCKPICK] =											false,
	[ITEMTYPE_WEAPON_BOOSTER] =								false,	-- Can store in craft bag.
	[ITEMTYPE_ARMOR_BOOSTER] =								false,	-- Can store in craft bag.
	[ITEMTYPE_ENCHANTMENT_BOOSTER] =					false,	-- Not sure what this is?
	[ITEMTYPE_GLYPH_JEWELRY] =								true,
	[ITEMTYPE_SPICE] =												false,	-- Can store in craft bag.
	[ITEMTYPE_FLAVORING] =										false,	-- Can store in craft bag.
	[ITEMTYPE_RECIPE] =												false,
	[ITEMTYPE_POISON] =												true,
	[ITEMTYPE_REAGENT] =											false,	-- Can store in craft bag.
	[ITEMTYPE_DEPRECATED] =										true,
	[ITEMTYPE_POTION_BASE] =									true,		-- Can store in craft bag.
	[ITEMTYPE_COLLECTIBLE] =									true,
	[ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] =		false,	-- Can store in craft bag.
	[ITEMTYPE_BLACKSMITHING_MATERIAL] =				false,	-- Can store in craft bag.
	[ITEMTYPE_WOODWORKING_RAW_MATERIAL] =			false,	-- Can store in craft bag.
	[ITEMTYPE_WOODWORKING_MATERIAL] =					false,	-- Can store in craft bag.
	[ITEMTYPE_CLOTHIER_RAW_MATERIAL] =				false,	-- Can store in craft bag.
	[ITEMTYPE_CLOTHIER_MATERIAL] =						false,	-- Can store in craft bag.
	[ITEMTYPE_BLACKSMITHING_BOOSTER] =				false,	-- Can store in craft bag.
	[ITEMTYPE_WOODWORKING_BOOSTER] =					false,	-- Can store in craft bag.
	[ITEMTYPE_CLOTHIER_BOOSTER] =							false,	-- Can store in craft bag.
	[ITEMTYPE_STYLE_MATERIAL] =								false,	-- Can store in craft bag.
	[ITEMTYPE_ARMOR_TRAIT] =									false,	-- Can store in craft bag.
	[ITEMTYPE_WEAPON_TRAIT] =									false,	-- Can store in craft bag.
	[ITEMTYPE_AVA_REPAIR] =										false,	-- Not sure on this one. Might have alliance info?
--	[ITEMTYPE_TRASH] =												true,		-- Not sure on this.
	[ITEMTYPE_TRASH] =												true,		-- Not sure on this.
	[ITEMTYPE_DEPRECATED_2] =									true,
	[ITEMTYPE_MOUNT] =												true,		-- This should be a collectible?
	[ITEMTYPE_ENCHANTING_RUNE_POTENCY] =			false,	-- Can store in craft bag.
	[ITEMTYPE_ENCHANTING_RUNE_ASPECT] =				false,	-- Can store in craft bag.
	[ITEMTYPE_ENCHANTING_RUNE_ESSENCE] =			false,	-- Can store in craft bag.
	[ITEMTYPE_FISH] =													true,		-- Not sure on this.
	[ITEMTYPE_CROWN_REPAIR] =									false,	-- Not sure on this.
	[ITEMTYPE_TREASURE] =											true,		-- Not sure on this.
	[ITEMTYPE_CROWN_ITEM] =										true,		-- Not sure on this.
	[ITEMTYPE_POISON_BASE] =									false,	-- Can store in craft bag.
	[ITEMTYPE_DYE_STAMP] =										true,		-- Not sure on this one.
	[ITEMTYPE_MASTER_WRIT] =									true,
	[ITEMTYPE_FURNISHING] =										false,	-- Can store in furniture vault.
	[ITEMTYPE_FURNISHING_MATERIAL] =					false,	-- Can store in craft bag.
	[ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] =	false,	-- Can store in craft bag.
	[ITEMTYPE_JEWELRYCRAFTING_MATERIAL] =			false,	-- Can store in craft bag.
	[ITEMTYPE_JEWELRYCRAFTING_BOOSTER] =			false,	-- Can store in craft bag.
	[ITEMTYPE_JEWELRY_TRAIT] =								false,	-- Can store in craft bag.
	[ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] =	false,	-- Can store in craft bag.
	[ITEMTYPE_JEWELRY_RAW_TRAIT] =						false,	-- Can store in craft bag.
	[ITEMTYPE_RECALL_STONE] =									true,		-- Not sure on this one.
	[ITEMTYPE_CONTAINER_CURRENCY] =						true,
	[ITEMTYPE_GROUP_REPAIR] =									false,
	[ITEMTYPE_CRAFTED_ABILITY] =							true,
	[ITEMTYPE_CRAFTED_ABILITY_SCRIPT] =				true,		-- Not sure on this one.
	[ITEMTYPE_SCRIBING_INK] =									true		-- Can store in craft bag.
}


function LinkUtils.ItemLinkTypeNeedsLink (itemLink)

	if CanItemLinkBeVirtual (itemLink) -- Crafting materials never need a link.
	or IsItemLinkPlaceableFurniture (itemLink) -- Furniture never needs a link.
--	or CanItemLinkBeUsedToLearn (itemLink) -- This probably applies to item sets, and equipment needs links.
	then
		return false
	end

	return itemTypeNeedsLink[GetItemLinkItemType (itemLink)] or false -- Determine by category.

end


-- Strip links for display as text in the game, or as part of data size reduction

function LinkUtils.StripItemLink (itemLink)

	if not itemLink then return nil end
	if type (itemLink) ~= "string" then return itemLink end

	return itemLink:gsub ("^|H%d:item:(.+)|h%w*|h$", "%1")

end


LUXHRYS.LinkUtils = LinkUtils


-- ========================= [ ItemKey functions ] ========================= --



--function ItemKey.GetItemKey (itemKey)
function ItemKey.Get (itemKey)

	if not itemKey then return "" end

	if type (itemKey) == "string" and tonumber (itemKey) == nil then

		if not itemKey:find(":item:") then -- a link but not an item
			return ""
		elseif LinkUtils.ItemLinkTypeNeedsLink (itemKey) then -- already an itemLink, this item needs a link
			return itemKey
		else -- already an itemLink, but we only need an itemID
			return GetItemLinkItemId (itemKey)
		end

	else -- not a link

		itemKey = tonumber (itemKey)

		if itemKey == nil then return "" end

		local itemLink = LinkUtils.CreateSimpleItemLinkFromItemID (itemKey) -- make it a link

		if LinkUtils.ItemLinkTypeNeedsLink (itemLink) then -- this item needs an itemLink
			return itemLink
		else -- an itemID is fine
			return itemKey
		end

	end

end


LUXHRYS.ItemKey = ItemKey


-- ========================= [ itemInfo functions ] ======================== --

-- Alas, itemData was already taken. Using itemInfo to avoid confusion.
-- These don't write to the database, just help with preparing database entries.

-- TODO: There are a ton of functions here. Any way to consolidate?




-------------------------------------------------------------------------------
--| Constants |----------------------------------------------------------------
-------------------------------------------------------------------------------


local ITEMINFO_LOCATION_DELIMITER = ";"
local ITEMINFO_COUNT_DELIMITER = ":"


-------------------------------------------------------------------------------
--| Utility Functions |--------------------------------------------------------
-------------------------------------------------------------------------------


-- Strips extra location delimiters

local function StripItemInfoLocationExtraDelimiters (itemInfo)

	return itemInfo:gsub ("^" .. ITEMINFO_LOCATION_DELIMITER .. "*(.-)" .. ITEMINFO_LOCATION_DELIMITER .. "*$", "%1")
	:gsub (ITEMINFO_LOCATION_DELIMITER .. ITEMINFO_LOCATION_DELIMITER .. "+", ITEMINFO_LOCATION_DELIMITER)
--	return itemInfo:gsub (StrFormat ("^%s*(.-)%s*$", ITEMINFO_LOCATION_DELIMITER, ITEMINFO_LOCATION_DELIMITER), "%1"):gsub (StrFormat ("%s%s+", ITEMINFO_LOCATION_DELIMITER, ITEMINFO_LOCATION_DELIMITER), ITEMINFO_LOCATION_DELIMITER)

end


-------------------------------------------------------------------------------
--| Iteration Functions |------------------------------------------------------
-------------------------------------------------------------------------------


-- Returns iterator of all locationCodes in itemInfo by type

--function ItemInfo.GetItemInfoLocationCodesByTypeIter (itemInfo, locationType)
function ItemInfo.GetLocationCodesByTypePrefixIter (itemInfo, locationType)

	if not itemInfo or itemInfo == "" or not locationType or type (locationType) ~= "string" or #locationType ~= 1 then return nil end

	return itemInfo:gmatch ("(" .. locationType .. "%w+)" .. ITEMINFO_COUNT_DELIMITER .. "%d+")
--	return itemInfo:gmatch (StrFormat ("(%s%s+)%s%s+", locationType, "%w", ITEMINFO_COUNT_DELIMITER , "%d"))

end


-- Returns iterator of all locationCodes in itemInfo by type as a table

--function ItemInfo.GetItemInfoLocationCodesByType (itemInfo, locationType)
function ItemInfo.GetLocationCodesByType (itemInfo, locationType)

	local locationCodes = {}

	for locationCode in pairs (ItemInfo.GetocationCodesByTypeIter (itemInfo, locationType)) do
--		TableInsert (locationCodes, locationCode)
		locationCodes[#locationCodes + 1] = locationCode
	end

	return locationCodes

end


-- Returns iterator of all locationCodes and stack counts in itemInfo by locationCodePrefix

--function ItemInfo.GetItemInfoLocationCodesAndStackCountsByTypeIter (itemInfo, locationCodePrefix)
function ItemInfo.GetLocationCodesAndStackCountsByTypeIter (itemInfo, locationCodePrefix)

	if not itemInfo or itemInfo == "" or not locationCodePrefix or type (locationCodePrefix) ~= "string" or #locationCodePrefix ~= 1 then return nil end

	return itemInfo:gmatch ("(" .. locationCodePrefix .. "%w+)" .. ITEMINFO_COUNT_DELIMITER .. "(%d+)")
--	return itemInfo:gmatch (StrFormat ("(%s%s+)%s(%s+)", locationCodePrefix, "%w", ITEMINFO_COUNT_DELIMITER,"%d"))

end


-- Returns characterIDs and stack counts for LOCATION_TYPE_WORN, LOCATION_TYPE_CHAR, LOCATION_TYPE_BUYBACK, and LOCATION_TYPE_VENGEANCE, mainly for the InfoPanel.

--function ItemInfo.GetItemInfoLocationCodesAndStackCountsByCharacterIter (itemInfo)
function ItemInfo.GetLocationCodesAndStackCountsByCharacterIter (itemInfo)

	if not itemInfo or itemInfo == "" then return nil end

	local locationCodePrefixes = "[" .. LOCATION_TYPE_CODE_PREFIX[LOCATION_TYPE_CHAR] .. LOCATION_TYPE_CODE_PREFIX[LOCATION_TYPE_BUYBACK] .. LOCATION_TYPE_CODE_PREFIX[LOCATION_TYPE_VENGEANCE] .. LOCATION_TYPE_CODE_PREFIX[LOCATION_TYPE_WORN] .. "]"
--	local locationCodePrefixes = StrFormat ("[%s%s%s%s]", LOCATION_TYPE_CODE_PREFIX[LOCATION_TYPE_CHAR], LOCATION_TYPE_CODE_PREFIX[LOCATION_TYPE_BUYBACK], LOCATION_TYPE_CODE_PREFIX[LOCATION_TYPE_VENGEANCE], LOCATION_TYPE_CODE_PREFIX[LOCATION_TYPE_WORN])

	return itemInfo:gmatch ("(" .. locationCodePrefixes .. "%w+)" .. ITEMINFO_COUNT_DELIMITER .. "(%d+)")
--	return itemInfo:gmatch (StrFormat ("(%s%s+)%s(%s+)", locationCodePrefixes, "%w", ITEMINFO_COUNT_DELIMITER, "%d"))

end


-- Returns characterIDs and stack counts for LOCATION_TYPE_COMPANION, mainly for the InfoPanel.

--function ItemInfo.GetItemInfoLocationCodesAndStackCountsByCompanionIter (itemInfo)
function ItemInfo.GetLocationCodesAndStackCountsByCompanionIter (itemInfo)

	if not itemInfo or itemInfo == "" then return nil end

	return itemInfo:gmatch ("([" .. LOCATION_TYPE_COMPANION .. "]%w+)" .. ITEMINFO_COUNT_DELIMITER.. "(%d+)")
--	return itemInfo:gmatch (StrFormat ("([%s]%s+)%s(%s+)", LOCATION_TYPE_COMPANION, "%w", ITEMINFO_COUNT_DELIMITER, "%d"))

end


-- Returns iterator of all location codes and stack counts in itemInfo

--function ItemInfo.GetItemInfoLocationCodesAndStackCountsIter (itemInfo)
function ItemInfo.GetLocationCodesAndStackCountsIter (itemInfo)

	if not itemInfo or itemInfo == "" then
		return nil
	end

--[[
	local returnTable = {}

	for itemLocation, stackCount in itemInfo:gmatch ("(%w+):(%w+)") do
		TableInsert (returnTable, itemLocation)
	end

	return unpack (returnTable)
]]

	return itemInfo:gmatch ("(%w+)" .. ITEMINFO_COUNT_DELIMITER .. "(%d+)")
--	return itemInfo:gmatch (StrFormat ("(%s+)%s(%s+)", "%w", ITEMINFO_COUNT_DELIMITER, "%d"))

end


-------------------------------------------------------------------------------
--| ItemInfo Query Functions |-------------------------------------------------
-------------------------------------------------------------------------------


-- Returns all numeric item location types in an itemInfo as a table

--function ItemInfo.GetItemInfoLocationTypes (itemInfo, excludeCurrentCharacter)
function ItemInfo.GetLocationTypes (itemInfo, excludeCurrentCharacter)

	local locationType
	local locationTypes = {}

	for locationCode in pairs (ItemInfo.GetLocationCodesAndStackCountsIter (itemInfo)) do

		locationType = Location.GetCodeType (locationCode)

		if not ((excludeCurrentCharacter and excludeCurrentCharacter == true)
		and locationCode:sub (2) == GetCurrentCharacterId () -- Remember, this returns a string.
		and (locationType == LOCATION_TYPE_CHAR
		or locationType == LOCATION_TYPE_BUYBACK
		or locationType == LOCATION_TYPE_COMPANION
		or locationType == LOCATION_TYPE_VENGEANCE
		or locationType == LOCATION_TYPE_WORN))
		then
--			TableInsert (locationTypes, locationType)
			locationTypes[#locationTypes + 1] = locationType
		end

	end

	return locationTypes

end


-- Returns bag IDs included in an itemInfo. Practically, it only returns housing storage/furniture vault, since those are the only things we use bagIDs for.

--function ItemInfo.GetItemInfoBagIDs (itemInfo)
function ItemInfo.GetBagIDs (itemInfo)

	local bagIDs = {}

	for locationCode in pairs (ItemInfo.GetLocationCodesAndStackCountsIter (itemInfo)) do

		if ItemInfo.GetLocationCodeLocationType (locationCode) == LOCATION_TYPE_BAG then
--			TableInsert (bagIDs, tonumber (locationCode:sub (2)))
			bagIDs[#bagIDs + 1] = tonumber (locationCode:sub (2))
		end

	end

	return bagIDs

end


-- Returns the first location code in itemInfo

--function ItemInfo.GetItemInfoFirstLocationCode (itemInfo)
function ItemInfo.GetFirstLocationCode (itemInfo)

	if not itemInfo or itemInfo == "" then
		return nil
	end

	return itemInfo:match ("(%w+)" .. ITEMINFO_COUNT_DELIMITER)
--	return itemInfo:match (StrFormat ("(%s+)%s", "%w", ITEMINFO_COUNT_DELIMITER))

end


-- Returns the number of locations in the itemInfo -- TODO: Robustify for duplicates?

--function ItemInfo.GetItemInfoLocationCount (itemInfo, locationCode)
function ItemInfo.GetLocationCount (itemInfo, locationCode)

	if not itemInfo or itemInfo == "" or not locationCode or locationCode == "" then
		return nil
	end

	local numSubs = select (2, itemInfo:gsub ("(%w+)" .. ITEMINFO_COUNT_DELIMITER .. "%d+", ""))
--	local numSubs = select (2, itemInfo:gsub (StrFormat ("(%s+)%s%s+", "%w", ITEMINFO_COUNT_DELIMITER "%d", "")))

	if numSubs == 0 then
		return nil -- Distinguish between no entries and entries with 0 count.
	else
		return tonumber (numSubs)
	end

end


-- Returns the number of times a locationCode appears in the itemInfo. Good for finding duplicates.

--function ItemInfo.GetItemInfoLocationCodeCount (itemInfo, locationCode)
function ItemInfo.GetLocationCodeCount (itemInfo, locationCode)

	if not itemInfo or itemInfo == "" or not locationCode or locationCode == "" then
		return nil
	end

	local numSubs = select (2, itemInfo:gsub ("(" .. locationCode .. ")" .. ITEMINFO_COUNT_DELIMITER .. "%d+", ""))
--	local numSubs = select (2, itemInfo:gsub (StrFormat ("(%s)%s%s+", locationCode, ITEMINFO_COUNT_DELIMITER, "%d", "")))

	if numSubs == 0 then
		return nil -- Distinguish between no entries and entries with 0 count.
	else
		return tonumber (numSubs)
	end

end


-- Returns the stackCount for a location in the itemInfo -- TODO: Robustify for duplicates?

--function ItemInfo.GetItemInfoLocationCodeStackCount (itemInfo, locationCode)
function ItemInfo.GetLocationCodeStackCount (itemInfo, locationCode)

--	Debug.Msg (2, "GIDLCSC: called with args %s, %s.", itemInfo or "--", locationCode or "--")

	if not itemInfo or itemInfo == "" or not locationCode or locationCode == "" then
		return nil
	end

--[[
	if itemInfo:find (locationCode .. ":") then -- item exists in db at this location
		return tonumber (itemInfo:match (locationCode .. ":(%d+)"))
	else -- item exists in db, but not at this location
		return 0
	end
]]

	local stackCount, numSubs = itemInfo:gsub ("^.-" .. locationCode .. ITEMINFO_COUNT_DELIMITER .. "(%d+).-$", "%1")
--	local stackCount, numSubs = itemInfo:gsub (StrFormat ("^.-%s%s(%s+).-$", locationCode, ITEMINFO_COUNT_DELIMITER, "%d"), "%1")

	if numSubs == 0 then
		return nil -- Distinguish between no entries and entries with 0 count.
	else
		return tonumber (stackCount)
	end

end


-- Returns stack count of an item in a locationCode, optionally not counting items held by the current character

--function ItemInfo.GetItemInfoLocationTypeStackCount (itemInfo, locationType, excludeCurrentCharacter)
function ItemInfo.GetLocationTypeStackCount (itemInfo, locationType, excludeCurrentCharacter)


--if locationType == LOCATION_TYPE_HOUSE then d ("GIILTSC: Called with itemInfo " .. itemInfo) end


	if not itemInfo or itemInfo == "" or not locationType or type (locationType) ~= "number" then
--if locationType == LOCATION_TYPE_HOUSE then d ("GIILTSC: Exiting early and returning nil. locationType length " .. locationType) end

		return nil end

	local stackCount = 0

	-- Collectible housing storage

	if locationType == LOCATION_TYPE_COLLECTIBLE_STORAGE then
		for bagID = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
			if State.IsHousingStorageCollected (bagID) then
				stackCount = stackCount + (ItemInfo.GetLocationCodeStackCount (itemInfo, Location.GetCodeForBagInCurrentState (bagID)) or 0)
			end
		end

		return stackCount
	end

--if locationType == LOCATION_TYPE_HOUSE then d ("GIILTSC: Passed storage loop. itemInfo: " .. itemInfo) end


	-- Everything else

	for locationCode, count in ItemInfo.GetLocationCodesAndStackCountsByTypeIter (itemInfo, Location.GetTypePrefix (locationType)) do

--[[
		if locationCode == "H124" then
			Debug.Msg (1, ADDON_DEBUG_NAME, "II_GLTSC", "Checkpoint 1 with itemInfo %s; locationType %s; count %s.", tostring (itemInfo), tostring (locationType), tostring (count))
		end
]]

		-- Do we want to exclude items associated with the current character? Useful for tooltips.

		if excludeCurrentCharacter ~= true then
			stackCount = stackCount + count
		elseif
--		not ((locationType == LOCATION_TYPE_WORN and locationCode == Location.GetCode (LOCATION_TYPE_WORN, GetCurrentCharacterId ()))
		not (locationType == LOCATION_TYPE_CHAR and locationCode == Location.GetCode (LOCATION_TYPE_CHAR, GetCurrentCharacterId ()))
--		or (locationType == LOCATION_TYPE_BUYBACK and locationCode == Location.GetCode (LOCATION_TYPE_BUYBACK, GetCurrentCharacterId ())))
		then
			stackCount = stackCount + count
		end
	end

	return stackCount

end


-- Returns stack count of an item in all locations tracked by this add-on,
-- optionally excluding the current character for backpack items.
-- (for tooltips).
-- TODO: Implement custom exclusions if needed.
-- TODO: Implement matching on same ID but different links, depending on settings.

--function ItemInfo.GetItemInfoExtendedStackCounts (itemInfo)
function ItemInfo.GetExtendedStackCounts (itemInfo, includeCurrent)

	if not itemInfo or type (itemInfo) ~= "string" or itemInfo == "" then

--		Debug.Msg ("GIESC: " .. itemInfo or "No" .. ", " .. type (itemInfo) .. ", " .. tostring (itemInfo))

		Debug.Msg (3, ADDON_DEBUG_NAME, "II_GESC", "Invalid itemInfo %s.", tostring (itemInfo))

		return 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	end
--d (ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_CHAR, true))

--[[
--	local allCharacterWornCount = ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_WORN, true) or 0
	local allCharacterWornCount = ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_WORN) or 0 -- Used to not count current character, but base game doesn't show worn item counts on tooltip.
	local allCharacterBackpackCount = ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_CHAR, includeCurrent ~= true) or 0
	local guildBankCount = ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_GUILD) or 0
	local buybackCount = ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_BUYBACK) or 0
	local collectibleHousingStorageCount = ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_COLLECTIBLE_STORAGE) or 0
	local companionWornCount = ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_COMPANION) or 0
	local furnitureVaultCount = ItemInfo.GetLocationCodeStackCount (itemInfo, Location.GetCodeForBagInCurrentState (BAG_FURNITURE_VAULT)) or 0 -- TODO: this is probably not right
	local vengeanceCount = ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_VENGEANCE) or 0
	local placedFurnitureCount = ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_HOUSE) or 0
	local mailboxCount = ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_INBOX) or 0
	local guildTraderCount = ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_TRADER) or 0

	return allCharacterWornCount, allCharacterBackpackCount, guildBankCount, buybackCount, collectibleHousingStorageCount, companionWornCount, furnitureVaultCount, vengeanceCount, placedFurnitureCount, mailboxCount, guildTraderCount
]]

	return ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_CHAR, includeCurrent ~= true) or 0,
	ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_COLLECTIBLE_STORAGE) or 0,
	ItemInfo.GetLocationCodeStackCount (itemInfo, Location.GetCodeForBagInCurrentState (BAG_FURNITURE_VAULT)) or 0, -- TODO: this is probably not right
	ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_HOUSE) or 0,
	ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_TRADER) or 0,
	ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_INBOX) or 0,
	ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_GUILD) or 0,
	ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_WORN) or 0, -- Used to not count current character, but base game doesn't show worn item counts on tooltip.
	ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_BUYBACK) or 0,
	ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_COMPANION) or 0,
	ItemInfo.GetLocationTypeStackCount (itemInfo, LOCATION_TYPE_VENGEANCE) or 0

--	allCharacterBackpackCount, collectibleHousingStorageCount, furnitureVaultCount, placedFurnitureCount, guildTraderCount, mailboxCount, guildBankCount, allCharacterWornCount, buybackCount, companionWornCount, vengeanceCount

end

--[[
local LOCATION_TYPE_FILTER_ALL = 1
local LOCATION_TYPE_FILTER_BACKPACK = 2
local LOCATION_TYPE_FILTER_COLLECTIBLE_STORAGE = 3
local LOCATION_TYPE_FILTER_FURNITURE_VAULT = 4
local LOCATION_TYPE_FILTER_HOUSE = 5
local LOCATION_TYPE_FILTER_TRADER = 6
local LOCATION_TYPE_FILTER_INBOX = 7
local LOCATION_TYPE_FILTER_GUILD = 8
local LOCATION_TYPE_FILTER_WORN = 9
local LOCATION_TYPE_FILTER_BUYBACK = 10
local LOCATION_TYPE_FILTER_COMPANION = 11
local LOCATION_TYPE_FILTER_VENGEANCE = 12
]]
-------------------------------------------------------------------------------
--| ItemInfo Modification Functions |------------------------------------------
-------------------------------------------------------------------------------


-- Delets a location from the itemInfo

local function ClearItemInfoLocation (itemInfo, locationCode)

	Debug.Msg (3, ADDON_DEBUG_NAME, "CIIL", "Called with args %s, %s.", itemInfo or "--", locationCode or "--")

	if not locationCode or locationCode == "" then return nil end

	if not ItemInfo.GetLocationCodeStackCount (itemInfo, locationCode) then -- item exists in itemInfo, but not at this location
		Debug.Msg (4, ADDON_DEBUG_NAME, "CIIL", "No change. Returning itemInfo %s.", itemInfo or "--")
		return itemInfo
	end

	itemInfo = itemInfo:gsub (locationCode .. ITEMINFO_COUNT_DELIMITER .. "%d+", "")
--	itemInfo = itemInfo:gsub (StrFormat ("%s%s%s+", locationCode, ITEMINFO_COUNT_DELIMITER, "%d", ""))
	itemInfo = StripItemInfoLocationExtraDelimiters (itemInfo)

	-- If there is no longer any count at all for this item, delete it.

	if not itemInfo or itemInfo == "" then
		Debug.Msg (4, ADDON_DEBUG_NAME, "CIIL", "Returning nil.")
		return nil
	else
		Debug.Msg (4, ADDON_DEBUG_NAME, "CIIL", "Made changes. Returning itemInfo %s.", itemInfo or "--")
		return itemInfo
	end

end


-- Sets the number of items in a location to the itemInfo

--function ItemInfo.SetItemInfoLocationCodeStackCount (itemInfo, locationCode, stackCount)
function ItemInfo.SetLocationCodeStackCount (itemInfo, locationCode, stackCount)

	Debug.Msg (2, ADDON_DEBUG_NAME, "II_SLCSC", "Called with itemInfo %s, locationCode %s, stackCount %s.", itemInfo or "--", locationCode or "--", stackCount or -1)

	if not locationCode or locationCode == "" then return nil end

--	if itemInfo then d ("SIDLC:", itemInfo) else d ("SIDLC: no itemInfo") end
--	if locationCode then d ("SIDLC:", locationCode) else d ("SIDLC: no locationCode") end
--	if stackCount then d ("SIDLC:", stackCount) else d ("SIDLC: no stackCount") end

	if stackCount == 0 then return ClearItemInfoLocation (itemInfo, locationCode) end

	if not itemInfo or itemInfo == "" then
		Debug.Msg (2, ADDON_DEBUG_NAME, "II_SLCSC", "No previous itemInfo. Returning %s.", locationCode .. ITEMINFO_COUNT_DELIMITER .. stackCount)
		return locationCode .. ITEMINFO_COUNT_DELIMITER .. stackCount
--		return StrFormat ("%s%s%s", locationCode, ITEMINFO_COUNT_DELIMITER, stackCount)
	elseif not ItemInfo.GetLocationCodeStackCount (itemInfo, locationCode) then
		Debug.Msg (2, ADDON_DEBUG_NAME, "II_SLCSC", "No entries for this location in itemInfo. Returning %s.", itemInfo .. ITEMINFO_LOCATION_DELIMITER .. locationCode .. ITEMINFO_COUNT_DELIMITER .. stackCount)
		return itemInfo .. ITEMINFO_LOCATION_DELIMITER .. locationCode .. ITEMINFO_COUNT_DELIMITER .. stackCount
--		return StrFormat ("%s%s%s%s%s", itemInfo, ITEMINFO_LOCATION_DELIMITER, locationCode, ITEMINFO_COUNT_DELIMITER, stackCount)
	else
		Debug.Msg (2, ADDON_DEBUG_NAME, "II_SLCSC", "Update count in this location.")
		return itemInfo:gsub ("^(.-" .. locationCode .. ITEMINFO_COUNT_DELIMITER .. ")%d+(.-)$", "%1" .. stackCount .. "%2")
--		return itemInfo:gsub (StrFormat ("^(.-%s%s)%s+(.-)$", locationCode, ITEMINFO_COUNT_DELIMITER, "%d"), StrFormat ("%s%s%s", "%1", stackCount, "%2"))
	end

end


-- Deletes all inbox locations from the itemInfo

--function ItemInfo.ClearItemInfoInboxLocations (itemInfo)
function ItemInfo.ClearInboxLocations (itemInfo)
	for locationCode in ItemInfo.GetLocationCodesByTypePrefixIter (itemInfo, Location.GetTypePrefix (LOCATION_TYPE_INBOX)) do
		itemInfo = ClearItemInfoLocation (itemInfo, locationCode)
	end
	return itemInfo
end


-- Increases or decreases the number of items in a location in the itemInfo

--function ItemInfo.IncreaseOrDecreaseItemInfoLocationCodeStackCount (itemInfo, locationCode, stackCountDelta)
function ItemInfo.IncreaseOrDecreaseLocationCodeStackCount (itemInfo, locationCode, stackCountDelta)

--	if itemInfo then d ("IODIDLC:", itemInfo) else d ("IODIDLC: no itemInfo") end
--	if locationCode then d ("IODIDLC:", locationCode) else d ("IODIDLC: no locationCode") end
--	if stackCountDelta then d ("IODIDLC:", stackCountDelta) else d ("IODIDLC: no stackCountDelta") end

	if not stackCountDelta or stackCountDelta == 0 then return itemInfo end

	local oldCount

	if not itemInfo or itemInfo == "" then
		oldCount = 0
	else
		oldCount = ItemInfo.GetLocationCodeStackCount (itemInfo, locationCode)
	end

	itemInfo = itemInfo or ""
	oldCount = oldCount or 0

	Debug.Msg (2, ADDON_DEBUG_NAME, "II_IODLCSC", "Calling II_SLCSC (%s, %s, %d)", itemInfo, locationCode or "--", oldCount + stackCountDelta)
	return ItemInfo.SetLocationCodeStackCount (itemInfo, locationCode, oldCount + stackCountDelta)

end


LUXHRYS.ItemInfo = ItemInfo

--[[
-- ============================ [ ??? ] =========================== --


--| User interface |-----------------------------------------------------------

-- TODO: What are these for again?

-- Strings --------------------------------------------------------------------

local LUXHRYS_GAMEPAD_INVENTORY_STACK_COUNT_BAG_WORN = "Equipped Items"
local LUXHRYS_GAMEPAD_INVENTORY_STACK_COUNT_BAG_GUILDBANK = "Guild Bank"
local LUXHRYS_GAMEPAD_INVENTORY_STACK_COUNT_BAG_BUYBACK = "Vendor Buyback"
local LUXHRYS_GAMEPAD_INVENTORY_STACK_COUNT_BAG_COMPANION_WORN = "Companion-Equipped Items"
local LUXHRYS_GAMEPAD_INVENTORY_STACK_COUNT_BAG_INBOX = "Mailbox"
local LUXHRYS_GAMEPAD_INVENTORY_STACK_COUNT_BAG_TRADER = "Guild Trader"
local LUXHRYS_GAMEPAD_INVENTORY_STACK_COUNT_BAG_PLACED_FURNISHINGS = "Placed Furniture"

LUXHRYS.GAMEPAD_INVENTORY_STACK_COUNT_BAG_WORN = LUXHRYS_GAMEPAD_INVENTORY_STACK_COUNT_BAG_WORN
LUXHRYS.GAMEPAD_INVENTORY_STACK_COUNT_BAG_GUILDBANK = LUXHRYS_GAMEPAD_INVENTORY_STACK_COUNT_BAG_GUILDBANK
LUXHRYS.GAMEPAD_INVENTORY_STACK_COUNT_BAG_BUYBACK = LUXHRYS_GAMEPAD_INVENTORY_STACK_COUNT_BAG_BUYBACK
LUXHRYS.GAMEPAD_INVENTORY_STACK_COUNT_BAG_COMPANION_WORN = LUXHRYS_GAMEPAD_INVENTORY_STACK_COUNT_BAG_COMPANION_WORN
LUXHRYS.GAMEPAD_INVENTORY_STACK_COUNT_BAG_INBOX = LUXHRYS_GAMEPAD_INVENTORY_STACK_COUNT_BAG_INBOX
LUXHRYS.GAMEPAD_INVENTORY_STACK_COUNT_BAG_TRADER = LUXHRYS_GAMEPAD_INVENTORY_STACK_COUNT_BAG_TRADER
LUXHRYS.GAMEPAD_INVENTORY_STACK_COUNT_BAG_PLACED_FURNISHINGS = LUXHRYS_GAMEPAD_INVENTORY_STACK_COUNT_BAG_PLACED_FURNISHINGS
]]

-- =============================== [ Colors ] ============================== --




--[[
	We want everything in mint green, but we should maintain the same
	relationship between icon and text that the base game does. They use ivory
	for the icon and white for the text, so we'll make white icons a little
	darker.
]]


-------------------------------------------------------------------------------
--| Utility Functions |--------------------------------------------------------
-------------------------------------------------------------------------------


local function GetCustomColorDef (colorTable, darkeningFactor)

	darkeningFactor = darkeningFactor or 1

	return ZO_ColorDef:New (
		colorTable.r*darkeningFactor,
		colorTable.g*darkeningFactor,
		colorTable.b*darkeningFactor,
		colorTable.a
	)

end


-------------------------------------------------------------------------------
--| Initialization |-----------------------------------------------------------
-------------------------------------------------------------------------------


function Colors:Initialize ()

	self.TINT_MODE_NORMAL = 0
	self.TINT_MODE_DIM = 1
	self.TINT_MODE_BRIGHT = 2

	self.tint = {
		TEXT = function ()
			return ZO_ColorDef:New (
				LUXHRYS.OPTIONS.masterColor.r,
				LUXHRYS.OPTIONS.masterColor.g,
				LUXHRYS.OPTIONS.masterColor.b,
				LUXHRYS.OPTIONS.masterColor.a
			)
			end,
		TEXTDARK = function ()
			return ZO_ColorDef:New (
				LUXHRYS.OPTIONS.masterColor.r*LUXHRYS.OPTIONS.masterColor.selectedDarkeningFactor,
				LUXHRYS.OPTIONS.masterColor.g*LUXHRYS.OPTIONS.masterColor.selectedDarkeningFactor,
				LUXHRYS.OPTIONS.masterColor.b*LUXHRYS.OPTIONS.masterColor.selectedDarkeningFactor,
				LUXHRYS.OPTIONS.masterColor.a
			)
			end,
		ICON = function ()
			return ZO_ColorDef:New (
				LUXHRYS.OPTIONS.masterColor.r*LUXHRYS.OPTIONS.masterColor.iconDarkeningFactor,
				LUXHRYS.OPTIONS.masterColor.g*LUXHRYS.OPTIONS.masterColor.iconDarkeningFactor,
				LUXHRYS.OPTIONS.masterColor.b*LUXHRYS.OPTIONS.masterColor.iconDarkeningFactor,
				LUXHRYS.OPTIONS.masterColor.a
			)
			end,
		ICONDARK = function ()
			return ZO_ColorDef:New (
				LUXHRYS.OPTIONS.masterColor.r*LUXHRYS.OPTIONS.masterColor.iconDarkeningFactor*LUXHRYS.OPTIONS.masterColor.selectedDarkeningFactor,
				LUXHRYS.OPTIONS.masterColor.g*LUXHRYS.OPTIONS.masterColor.iconDarkeningFactor*LUXHRYS.OPTIONS.masterColor.selectedDarkeningFactor,
				LUXHRYS.OPTIONS.masterColor.b*LUXHRYS.OPTIONS.masterColor.iconDarkeningFactor*LUXHRYS.OPTIONS.masterColor.selectedDarkeningFactor,
				LUXHRYS.OPTIONS.masterColor.a
			)
			end
	}

		Debug.Msg (2, ADDON_DEBUG_NAME, "C_I", "Initialized")

end


-------------------------------------------------------------------------------
--| Color Query Functions |----------------------------------------------------
-------------------------------------------------------------------------------


-- Real-time values based on player-set options.

function Colors:GetCurrentTint (style)
	return self.tint[style] ()
end
--XMT.Tint_CurrentSetting = XMT_Tint_CurrentSetting


function Colors:GetCurrentTextRGBValues (tintMode)
--	return XMT_Tint_CurrentSetting ().TEXT.r, XMT_Tint_CurrentSetting ().TEXT.g, XMT_Tint_CurrentSetting ().TEXT.b

	if not tintMode or tintMode == self.TINT_MODE_NORMAL then
		return self.tint.TEXT ():UnpackRGB ()
	elseif tintMode == self.TINT_MODE_DIM then
		return self.tint.TEXTDARK ():UnpackRGB ()
--	elseif tintMode == 2 then -- Reserved if we ever need a bright version
--		return XMT_Tint_CurrentSetting ().TEXTBRIGHT:UnpackRGB ()
	end

	return self.tint.TEXT ():UnpackRGB ()

end


function Colors:GetCurrentIconRGBValues (tintMode)
--	return XMT_Tint_CurrentSetting ().ICON.r, XMT_Tint_CurrentSetting ().ICON.g, XMT_Tint_CurrentSetting ().ICON.b

	if not tintMode or tintMode == self.TINT_MODE_NORMAL then
		return self.tint.ICON ():UnpackRGB ()
	elseif tintMode == self.TINT_MODE_DIM then
		return self.tint.ICONDARK ():UnpackRGB ()
--	elseif tintMode == 2 then -- Reserved if we ever need a bright version
--		return XMT_Tint_CurrentSetting ().ICONBRIGHT:UnpackRGB ()
	end

	return self.tint.ICON ():UnpackRGB ()
end


function Colors:GetCurrentTextRGBAValues (tintMode)
--	return XMT_Tint_CurrentSetting ().TEXT.r, XMT_Tint_CurrentSetting ().TEXT.g, XMT_Tint_CurrentSetting ().TEXT.b, XMT_Tint_CurrentSetting ().TEXT.a

	if not tintMode or tintMode == self.TINT_MODE_NORMAL then
		return self.tint.TEXT ():UnpackRGBA ()
	elseif tintMode == self.TINT_MODE_DIM then
		return self.tint.TEXTDARK ():UnpackRGBA ()
--	elseif tintMode == 2 then -- Reserved if we ever need a bright version
--		return XMT_Tint_CurrentSetting ().TEXTBRIGHT:UnpackRGBA ()
	end

	return self.tint.TEXT ():UnpackRGBA ()
end


function Colors:GetCurrentIconRGBAValues (tintMode)
--	return XMT_Tint_CurrentSetting ().ICON.r, XMT_Tint_CurrentSetting ().ICON.g, XMT_Tint_CurrentSetting ().ICON.b, XMT_Tint_CurrentSetting ().ICON.a

	if not tintMode or tintMode == self.TINT_MODE_NORMAL then
		return self.tint.ICON ():UnpackRGBA ()
	elseif tintMode == self.TINT_MODE_DIM then
		return self.tint.ICONDARK ():UnpackRGBA ()
--	elseif tintMode == 2 then -- Reserved if we ever need a bright version
--		return XMT_Tint_CurrentSetting ().ICONBRIGHT:UnpackRGBA ()
	end

	return self.tint.ICON ():UnpackRGBA ()
end


function Colors:GetColorizedText (text, useDefault)
	if useDefault and useDefault == true then
		return GetCustomColorDef (
			{
				r = LUXHRYS.optionDefaults.masterColor.r,
				g = LUXHRYS.optionDefaults.masterColor.g,
				b = LUXHRYS.optionDefaults.masterColor.b,
				a = LUXHRYS.optionDefaults.masterColor.a
			} --,
--			LUXHRYS.optionDefaults.masterColor.darkeningFactor
			):Colorize (text)
	else
		return self.tint.TEXT ():Colorize (text)
	end
end


function Colors:GetColorizedIcon (iconTexture, xSize, ySize, useDefault)
	if useDefault and useDefault == true then
		return GetCustomColorDef (
			{
				r = LUXHRYS.optionDefaults.masterColor.r,
				g = LUXHRYS.optionDefaults.masterColor.g,
				b = LUXHRYS.optionDefaults.masterColor.b,
				a = LUXHRYS.optionDefaults.masterColor.a
			} --,
--			LUXHRYS.optionDefaults.masterColor.darkeningFactor
			):Colorize (zo_iconFormatInheritColor (iconTexture, xSize, ySize))
	else
		return self.tint.ICON ():Colorize (zo_iconFormatInheritColor (iconTexture, xSize, ySize))
	end
end



-------------------------------------------------------------------------------
--| DEPRECATED FUNCTIONS -- TO BE REMOVED |------------------------------------
-------------------------------------------------------------------------------


Colors.Tint_SystemTooltipDefault = {
BASE_ICON_WHITE = ZO_ColorDef:New ((192/255), (192/255), (155/255), 1),
}

Colors.Tint_MintGreen = {
BASE_ICON_WHITE = ZO_ColorDef:New ((139/255), (217/255), (186/255), 1),
BASE_ICON_IVORY = ZO_ColorDef:New ((163/255), 1, (218/255), 1),
BASE_ICON_GREY = ZO_ColorDef:New ((163/255), 1, (218/255), 1),
BASE_TEXT_WHITE = ZO_ColorDef:New ((163/255), 1, (218/255), 1)
}
--XMT.Tint_MintGreen = XMT_Tint_MintGreen


-- =========================== [ Initialization ] ========================== --


-- Some "classes" rely on OPTIONS or use saved variables, which cannot be
-- initialized until EVENT_ADD_ON_LOADED.

local function InitializeCommon (_, addonName)
	if addonName and addonName == ADDON_NAME then
		Debug.Msg (1, ADDON_DEBUG_NAME, "IC", "Initializing %s.", ADDON_CHUNK_NAME)
		LUXHRYS.COLORS = Colors:New ()
		EVENT_MANAGER:UnregisterForEvent (ADDON_DEBUG_NAME, EVENT_ADD_ON_LOADED)
		Debug.Msg (1, ADDON_DEBUG_NAME, "IC", "%s initialization %s.", ADDON_CHUNK_NAME, LUXHRYS.COLORS ~= nil and "successful" or "failed")
	end
end


EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_ADD_ON_LOADED, InitializeCommon)



-- We need STATE and COLORS for this, which won't initialize until after
-- OPTIONS. We'll delay initializing the setting panel.

local function InitializeCommonAdditionalClasses (_, addonName)
	Debug.Msg (1, ADDON_DEBUG_NAME, "ICAC", "Accessing additional classes for %s.", ADDON_CHUNK_NAME)

	DBLOOKUP = LUXHRYS.DBLOOKUP

	EVENT_MANAGER:UnregisterForEvent (ADDON_DEBUG_NAME, EVENT_PLAYER_ACTIVATED)

	Debug.Msg (1, ADDON_DEBUG_NAME, "ICAC", "Additional classes now available.")
end


EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_PLAYER_ACTIVATED, InitializeCommonAdditionalClasses)



--[[

local optionDefaults = LUXHRYS.optionDefaults
local OPTIONS = LUXHRYS.OPTIONS
local Debug = LUXHRYS.Debug
local Startup = LUXHRYS.Startup
local Async = LUXHRYS.Async
local StrUtils = LUXHRYS.StrUtils
local Alerts = LUXHRYS.Alerts
local STATE = LUXHRYS.STATE
local Bag = LUXHRYS.Bag
local Location = LUXHRYS.Location
local LinkUtils = LUXHRYS.LinkUtils
local ItemKey = LUXHRYS.ItemKey
local ItemInfo = LUXHRYS.ItemInfo
local icons = LUXHRYS.icons
local COLORS = LUXHRYS.COLORS


local BAG_PLACED_FURNISHINGS = Bag.BAG_PLACED_FURNISHINGS
local BAG_INBOX = Bag.BAG_INBOX
local BAG_TRADER = Bag.BAG_TRADER


local LOCATION_TYPE_BAG = Location.LOCATION_TYPE_BAG
local LOCATION_TYPE_CHAR = Location.LOCATION_TYPE_CHAR
local LOCATION_TYPE_GUILD = Location.LOCATION_TYPE_GUILD
local LOCATION_TYPE_HOUSE = Location.LOCATION_TYPE_HOUSE
local LOCATION_TYPE_BUYBACK = Location.LOCATION_TYPE_BUYBACK
local LOCATION_TYPE_INBOX = Location.LOCATION_TYPE_INBOX
local LOCATION_TYPE_COMPANION = Location.LOCATION_TYPE_COMPANION
local LOCATION_TYPE_TRADER = Location.LOCATION_TYPE_TRADER
local LOCATION_TYPE_WORN = Location.LOCATION_TYPE_WORN


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

]]
