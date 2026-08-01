
--[[ LuXhrys Modular Add-On System ]]
--[[ Written by Xhrysanth (PSNA) ]]
--[[ Vault and Coffer ]]
--[[ VaCInfoPanel.lua ]]
--[[ LOAD ORDER SECOND ]]


--[[ DISCLAIMER
This Add-on is not created by, affiliated with, or sponsored by, ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
]]

--[[ Information, attribution, copyright, and license:
This file is part of the core module for the LuXhrys add-on system for the Elder Scrolls Online.

This code chunk contains information panel functions for the LuXhrys add-on system for the Elder Scrolls Online.

Written and copyright (c) 2026 by Xhrysanth (PSNA). License terms to be determined. Currently, and until this notice changes, all rights are reserved, except those that belong to ZeniMax Media Inc., which provides the API used by this software.
]]


--[[ ==========================> DECLARATIONS <=========================== ]]--


-- ============================= [ Namespace ] ============================= --


assert (LUXHRYS.VAC.METADATA.ADDON_MODULE_NAME == "VaultAndCoffer", "[LuXhrysVaCI] CRIT: LuXhrysVaCT not available. This chunk will not be loaded.")


-- ============================== [ Metadata ] ============================= --



local ADDON_SYSTEM_NAME = LUXHRYS.METADATA.ADDON_SYSTEM_NAME
local ADDON_AUTHOR = LUXHRYS.METADATA.ADDON_AUTHOR
local ADDON_COPYRIGHT_AND_LICENSE = LUXHRYS.METADATA.ADDON_COPYRIGHT_AND_LICENSE
local ADDON_DISCLAIMER = LUXHRYS.METADATA.ADDON_DISCLAIMER
local ADDON_DESCRIPTION = LUXHRYS.METADATA.ADDON_DESCRIPTION

local ADDON_MODULE_NAME = LUXHRYS.VAC.METADATA.ADDON_MODULE_NAME
local ADDON_MODULE_SHORT_NAME = LUXHRYS.VAC.METADATA.ADDON_MODULE_SHORT_NAME
local ADDON_NAME = LUXHRYS.VAC.METADATA.ADDON_NAME
local ADDON_MODULE_VERSION = LUXHRYS.VAC.METADATA.ADDON_MODULE_VERSION
local ADDON_MODULE_DESCRIPTION = LUXHRYS.VAC.METADATA.ADDON_MODULE_DESCRIPTION

local ADDON_CHUNK_NAME = "InfoPanel"
local ADDON_CHUNK_SHORT_NAME = "I"
local ADDON_DEBUG_NAME = ADDON_SYSTEM_NAME .. ADDON_MODULE_SHORT_NAME .. ADDON_CHUNK_SHORT_NAME


-- ===================== [ Localize Global Functions ] ===================== --


-------------------------------------------------------------------------------
--| C functions |--------------------------------------------------------------
-------------------------------------------------------------------------------


--local GetItemLink = GetItemLink
--local GetItemId = GetItemId
--local GetItemLinkItemType = GetItemLinkItemType
--local GetSlotStackSize = GetSlotStackSize
--local GetPlacedFurnitureLink = GetPlacedFurnitureLink
--local GetItemLinkItemId = GetItemLinkItemId
--local GetCollectibleIdFromFurnitureId = GetCollectibleIdFromFurnitureId
--local GetCollectibleLink = GetCollectibleLink
--local GetCurrentZoneHouseId = GetCurrentZoneHouseId
--local IsOwnerOfCurrentHouse = IsOwnerOfCurrentHouse
--local CanItemLinkBeVirtual = CanItemLinkBeVirtual
--local IsItemLinkPlaceableFurniture = IsItemLinkPlaceableFurniture
--local CanItemLinkBeUsedToLearn = CanItemLinkBeUsedToLearn

--local IsCollectibleUnlocked = IsCollectibleUnlocked
--local CanSellOnTradingHouse = CanSellOnTradingHouse
--local GetSelectedTradingHouseGuildId = GetSelectedTradingHouseGuildId

--local IsConsoleUI = IsConsoleUI
--local IsInGamepadPreferredMode = IsInGamepadPreferredMode

--local GetNumTradingHouseListings = GetNumTradingHouseListings
--local GetNumMailItems = GetNumMailItems
--local HasUnreadMail = HasUnreadMail
--local GetMailItemInfo = GetMailItemInfo
--local GetNumBuybackItems = GetNumBuybackItems
--local GetNumHouseFurnishingsPlaced = GetNumHouseFurnishingsPlaced
local GetHouseCategoryType = GetHouseCategoryType
--local GetBagSize = GetBagSize
--local GetBagUseableSize = GetBagUseableSize

--local GetNextGuildBankSlotId = GetNextGuildBankSlotId
--local GetNextFurnitureVaultSlotId = GetNextFurnitureVaultSlotId
--local GetNextMailId = GetNextMailId
--local GetNextVirtualBagSlotId = GetNextVirtualBagSlotId
--local GetNextPlacedHousingFurnitureId = GetNextPlacedHousingFurnitureId

--local GetBuybackItemInfo = GetBuybackItemInfo
--local GetTradingHouseListingItemLink = GetTradingHouseListingItemLink
--local GetTradingHouseListingItemInfo = GetTradingHouseListingItemInfo

--local GetCollectibleForBag = GetCollectibleForBag

--local IsBankOpen = IsBankOpen
--local IsGuildBankOpen = IsGuildBankOpen
--local HasActiveCompanion = HasActiveCompanion

--local GetMailAttachmentInfo = GetMailAttachmentInfo
--local GetAttachedItemLink = GetAttachedItemLink
--local GetAttachedItemInfo = GetAttachedItemInfo
--local RequestOpenMailbox = RequestOpenMailbox
--local RequestReadMail = RequestReadMail
--local CloseMailbox = CloseMailbox
--local IsReadMailInfoReady = IsReadMailInfoReady

--local Id64ToString = Id64ToString
local StringToId64 = StringToId64
--local GetGameTimeMilliseconds = GetGameTimeMilliseconds
local GetString = GetString

--local GetItemLinkDisplayQuality = GetItemLinkDisplayQuality
--local GetItemLinkIcon = GetItemLinkIcon
--local GetItemLinkName = GetItemLinkName

local GetCharacterNameById = GetCharacterNameById
local GetCompanionName = GetCompanionName

local GetGuildIndex = GetGuildIndex
local GetGuildName = GetGuildName

-------------------------------------------------------------------------------
--| Native Lua functions |-----------------------------------------------------
-------------------------------------------------------------------------------


--local TableInsert = table.insert
--local TableRemove = table.remove
local TableSort = table.sort

local StrFormat = string.format
local ToNumber = tonumber

-------------------------------------------------------------------------------
--| ZOS Lua functions |--------------------------------------------------------
-------------------------------------------------------------------------------


--local HasUnlockedFurnitureVault = ZO_HousingEditorState.HasUnlockedFurnitureVault
--local HousingEditorState = ZO_HousingEditorState
--local ParseLink = ZO_LinkHandler_ParseLink
--local IconFormat = zo_iconFormat
--local Alert = ZO_Alert
--local ClearTable = ZO_ClearTable

local zo_strformat = zo_strformat
--local ZO_GetStatDeltaLookupFromItemComparisonReturns = ZO_GetStatDeltaLookupFromItemComparisonReturns
--local zo_iconTextFormatNoSpaceAlignedRight = zo_iconTextFormatNoSpaceAlignedRight
--local zo_iconTextFormatNoSpace = zo_iconTextFormatNoSpace

--local ZO_InitializingObject = ZO_InitializingObject
--local zo_iconFormatInheritColor = zo_iconFormatInheritColor
local ZO_TableOrderingFunction = ZO_TableOrderingFunction
local ZO_FadeSceneFragment = ZO_FadeSceneFragment
local ZO_GridScrollList_Gamepad = ZO_GridScrollList_Gamepad
local ZO_GridSquareEntryData_Shared = ZO_GridSquareEntryData_Shared

local ZO_Gamepad_AddBackNavigationKeybindDescriptors = ZO_Gamepad_AddBackNavigationKeybindDescriptors


-------------------------------------------------------------------------------
--| From LXICommon |-----------------------------------------------------------
-------------------------------------------------------------------------------


--local optionDefaults = LUXHRYS.optionDefaults
local OPTIONS = LUXHRYS.LXI.OPTIONS
local Debug = LUXHRYS.LXI.Debug
--local StrUtils = LUXHRYS.StrUtils
--local STATE = LUXHRYS.STATE
local Bag = LUXHRYS.LXI.Bag
local Location = LUXHRYS.LXI.Location
local ItemInfo = LUXHRYS.LXI.ItemInfo
local icons = LUXHRYS.LXI.icons
--local COLORS = LUXHRYS.COLORS

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


-------------------------------------------------------------------------------
--| From LXIDatabase |---------------------------------------------------------
-------------------------------------------------------------------------------


local DBLOOKUP = LUXHRYS.LXI.DBLOOKUP


--[[ ============================> CONSTANTS <============================ ]]--


do


	-- Based on constants defined in zo_stats_gamepad.lua

--[[

ZO_ADVANCED_STATS_GAMEPAD_CONSTANTS_ENTRY_WIDTH = 350
ZO_ADVANCED_STATS_GAMEPAD_CONSTANTS_ENTRY_HEIGHT = 40
ZO_ADVANCED_STATS_GAMEPAD_CONSTANTS_HEADER_WIDTH = 700
ZO_ADVANCED_STATS_GAMEPAD_CONSTANTS_GRID_PADDING_X = 40
ZO_ADVANCED_STATS_GAMEPAD_CONSTANTS_GRID_PADDING_Y = 0
ZO_ADVANCED_STATS_GAMEPAD_CONSTANTS_SECTION_SPACING = 40

Original values:

LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_GAMEPAD_CONSTANTS_HEADER_WIDTH = 680 -- 683 (wide tooltip width) rounded
LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_GAMEPAD_CONSTANTS_HEADER_HEIGHT = 96
LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_GAMEPAD_CONSTANTS_CONTENT_WIDTH = 650
LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_GAMEPAD_CONSTANTS_ENTRY_WIDTH = 325 -- 650/2
LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_GAMEPAD_CONSTANTS_ENTRY_HEIGHT = 40
LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_GAMEPAD_CONSTANTS_GRID_PADDING_X = 40
LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_GAMEPAD_CONSTANTS_GRID_PADDING_Y = 0
LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_GAMEPAD_CONSTANTS_ROW_INDENT = 40
LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_GAMEPAD_CONSTANTS_COUNTS_TABLE_FIRST_COLUMN_WIDTH = 240
LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_GAMEPAD_CONSTANTS_COUNTS_TABLE_COLUMN_WIDTH = 120
LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_GAMEPAD_CONSTANTS_COUNTS_TABLE_ROW_HEIGHT = 80
LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_GAMEPAD_CONSTANTS_SECTION_SPACING = 40
]]

	local INFO_PANEL_GAMEPAD_CONSTANTS = {}

	-- Base constants

	INFO_PANEL_GAMEPAD_CONSTANTS.COMMON =
	{
		GRID_PADDING_X = 8,
		GRID_PADDING_Y = 4,
		MAIN_HEADER_HEIGHT = 96,
		SECTION_HEADER_ICON_SIZE = 48,
		SECTION_HEADER_TEXT_OFFSET = 10,
		TABLE_ROW_HEIGHT = 48,
		TABLE_ROW_INDENT = 6,
		TABLE_ICON_HEADER_HALF_ICON_SIZE = 16,
		TABLE_VALUE_COLUMN_HALF_WIDTH = 24,
	}

	-- Quadrant panel width is 470, horizontal insets are 40 each, leaving 390 usable width.
-- ZO_GAMEPAD_QUADRANT_3_RIGHT_REFERENCE_OFFSET - ZO_GAMEPAD_QUADRANT_2_RIGHT_OFFSET
-- ZO_GAMEPAD_QUADRANT_4_LEFT_COORD - ZO_GAMEPAD_QUADRANT_2_RIGHT_COORD

	INFO_PANEL_GAMEPAD_CONSTANTS.QUADRANT =
	{
		CONTENT_WIDTH = ZO_GAMEPAD_CONTENT_WIDTH -- 390
	}

	INFO_PANEL_GAMEPAD_CONSTANTS.WIDE =
	{
		CONTENT_WIDTH = ZO_GAMEPAD_PANEL_WIDE_WIDTH -- 683
	}


	-- Derived constants

	INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.SECTION_HEADER_HEIGHT = INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.SECTION_HEADER_ICON_SIZE

	INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.TABLE_ICON_HEADER_ICON_SIZE = INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.TABLE_ICON_HEADER_HALF_ICON_SIZE + INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.TABLE_ICON_HEADER_HALF_ICON_SIZE

	INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.TABLE_VALUE_COLUMN_WIDTH = INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.TABLE_VALUE_COLUMN_HALF_WIDTH + INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.TABLE_VALUE_COLUMN_HALF_WIDTH

	INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.TABLE_ICON_HEADER_RIGHT_OFFSET = INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.TABLE_VALUE_COLUMN_HALF_WIDTH - INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.TABLE_ICON_HEADER_HALF_ICON_SIZE


	INFO_PANEL_GAMEPAD_CONSTANTS.QUADRANT.SECTION_HEADER_LABEL_WIDTH = INFO_PANEL_GAMEPAD_CONSTANTS.QUADRANT.CONTENT_WIDTH - INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.SECTION_HEADER_ICON_SIZE - INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.SECTION_HEADER_TEXT_OFFSET

	INFO_PANEL_GAMEPAD_CONSTANTS.QUADRANT.ENTRY_WIDTH = INFO_PANEL_GAMEPAD_CONSTANTS.QUADRANT.CONTENT_WIDTH -
	INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.TABLE_ROW_INDENT

	INFO_PANEL_GAMEPAD_CONSTANTS.QUADRANT.TABLE_1N1V_FIRST_COLUMN_WIDTH = INFO_PANEL_GAMEPAD_CONSTANTS.QUADRANT.ENTRY_WIDTH - INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.TABLE_VALUE_COLUMN_WIDTH - INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.GRID_PADDING_X

	INFO_PANEL_GAMEPAD_CONSTANTS.QUADRANT.TABLE_1N2V_FIRST_COLUMN_WIDTH = INFO_PANEL_GAMEPAD_CONSTANTS.QUADRANT.TABLE_1N1V_FIRST_COLUMN_WIDTH - INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.TABLE_VALUE_COLUMN_WIDTH - INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.GRID_PADDING_X

	INFO_PANEL_GAMEPAD_CONSTANTS.QUADRANT.TABLE_1N3V_FIRST_COLUMN_WIDTH = INFO_PANEL_GAMEPAD_CONSTANTS.QUADRANT.TABLE_1N2V_FIRST_COLUMN_WIDTH - INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.TABLE_VALUE_COLUMN_WIDTH - INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.GRID_PADDING_X

	INFO_PANEL_GAMEPAD_CONSTANTS.QUADRANT.TABLE_1N4V_FIRST_COLUMN_WIDTH = INFO_PANEL_GAMEPAD_CONSTANTS.QUADRANT.TABLE_1N3V_FIRST_COLUMN_WIDTH - INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.TABLE_VALUE_COLUMN_WIDTH - INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.GRID_PADDING_X

	INFO_PANEL_GAMEPAD_CONSTANTS.QUADRANT.TABLE_2N1V_FIRST_TWO_COLUMN_WIDTHS = (INFO_PANEL_GAMEPAD_CONSTANTS.QUADRANT.TABLE_1N1V_FIRST_COLUMN_WIDTH -  INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.GRID_PADDING_X) / 2

	INFO_PANEL_GAMEPAD_CONSTANTS.QUADRANT.TABLE_1N1V_FIRST_COLUMN_WIDTH = INFO_PANEL_GAMEPAD_CONSTANTS.QUADRANT.ENTRY_WIDTH - INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.TABLE_VALUE_COLUMN_WIDTH - INFO_PANEL_GAMEPAD_CONSTANTS.COMMON.GRID_PADDING_X


--	INFO_PANEL_GAMEPAD_CONSTANTS.WIDE.PANEL_WIDTH = ZO_GAMEPAD_QUADRANT_4_LEFT_REFERENCE_OFFSET - ZO_GAMEPAD_QUADRANT_2_RIGHT_OFFSET
--	INFO_PANEL_GAMEPAD_CONSTANTS.WIDE.PANEL_WIDTH = ZO_GAMEPAD_PANEL_WIDE_WIDTH
	INFO_PANEL_GAMEPAD_CONSTANTS.WIDE.PANEL_WIDTH = ZO_GAMEPAD_QUADRANT_3_RIGHT_REFERENCE_OFFSET - ZO_GAMEPAD_QUADRANT_2_RIGHT_OFFSET - ZO_GAMEPAD_ALLEY_WIDTH
	INFO_PANEL_GAMEPAD_CONSTANTS.WIDE.LEFT_OFFSET = ZO_GAMEPAD_QUADRANT_2_RIGHT_OFFSET + ZO_GAMEPAD_ALLEY_WIDTH


	LUXHRYS.INFO_PANEL_GAMEPAD_CONSTANTS = INFO_PANEL_GAMEPAD_CONSTANTS

--[[
	-- Define globals for XML

	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_WIDE_GAMEPAD_CONSTANTS_MAIN_HEADER_WIDTH = 680 -- 683 (wide tooltip width) rounded
	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_MAIN_HEADER_WIDTH = 374
	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_MAIN_HEADER_HEIGHT = 96 -- was 96

	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_WIDE_GAMEPAD_CONSTANTS_CONTENT_WIDTH = 640 -- was 650
	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_CONTENT_WIDTH = 374 -- 450 -- was 470

	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_SECTION_HEADER_ICON_SIZE = 48
	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_SECTION_HEADER_INDENT = 10
	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_SECTION_HEADER_HEIGHT = LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_SECTION_HEADER_ICON_SIZE
	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_SECTION_HEADER_LABEL_WIDTH = LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_CONTENT_WIDTH - LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_SECTION_HEADER_ICON_SIZE - LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_SECTION_HEADER_INDENT

	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_X = 8
	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_Y = 4
	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_ROW_INDENT = 6

	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_ENTRY_WIDTH = LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_CONTENT_WIDTH - LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_ROW_INDENT
	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_COUNTS_TABLE_HALF_ICON_SIZE = 16

	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_COUNTS_TABLE_ICON_SIZE = LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_COUNTS_TABLE_HALF_ICON_SIZE * 2

	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_COUNTS_TABLE_HALF_COLUMN_WIDTH = 24
	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_COUNTS_TABLE_COLUMN_WIDTH = LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_COUNTS_TABLE_HALF_COLUMN_WIDTH * 2


	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_WIDE_GAMEPAD_CONSTANTS_TABLE_FIRST_COLUMN_WIDTH = 240
	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_TABLE_FIRST_COLUMN_WIDTH = 156

	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_TABLE_FIRST_COLUMN_WIDTH_TWO_COLUMNS = LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_ENTRY_WIDTH - LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_COUNTS_TABLE_COLUMN_WIDTH - LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_X

	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_TABLE_FIRST_COLUMN_WIDTH_THREE_COLUMNS = LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_TABLE_FIRST_COLUMN_WIDTH_TWO_COLUMNS - LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_COUNTS_TABLE_COLUMN_WIDTH - LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_X

	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_TABLE_FIRST_COLUMN_WIDTH_FOUR_COLUMNS = LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_TABLE_FIRST_COLUMN_WIDTH_THREE_COLUMNS - LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_COUNTS_TABLE_COLUMN_WIDTH - LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_X

	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_TABLE_FIRST_COLUMN_WIDTH_FIVE_COLUMNS = LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_TABLE_FIRST_COLUMN_WIDTH_FOUR_COLUMNS - LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_COUNTS_TABLE_COLUMN_WIDTH - LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_X

	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_TABLE_2N1V_FIRST_TWO_COLUMN_WIDTHS = EXTENDED_INVENTORY_INFO_PANEL_GAMEPAD_CONSTANTS.QUADRANT.TABLE_2N1V_FIRST_TWO_COLUMN_WIDTHS

	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_COUNTS_TABLE_ICON_RIGHT_OFFSET = LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_COUNTS_TABLE_HALF_COLUMN_WIDTH - LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_COUNTS_TABLE_HALF_ICON_SIZE

	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_TABLE_FIRST_COLUMN_WIDTH_AFTER_INDENT = LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_TABLE_FIRST_COLUMN_WIDTH - LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_ROW_INDENT


--	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_COUNTS_TABLE_ICON_RIGHT_OFFSET = LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_COUNTS_TABLE_HALF_COLUMN_WIDTH - LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_X

	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_TABLE_ROW_HEIGHT = 40

	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_SECTION_SPACING = 40

	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_WIDE_GAMEPAD_CONSTANTS_ENTRY_WIDTH = 320 -- 640/2

	LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_ENTRY_HEIGHT = 48


	LUXHRYS_EXTENDED_INVENTORY_GAMEPAD_QUADRANT_3_WIDE_PANEL_WIDTH = EXTENDED_INVENTORY_INFO_PANEL_GAMEPAD_CONSTANTS.WIDE.PANEL_WIDTH
	LUXHRYS_EXTENDED_INVENTORY_GAMEPAD_QUADRANT_3_WIDE_LEFT_OFFSET = EXTENDED_INVENTORY_INFO_PANEL_GAMEPAD_CONSTANTS.WIDE.LEFT_OFFSET
]]

end


--[[ ============================> FUNCTIONS <============================ ]]--


-- ============ [ Vault and Coffer InfoPanel Utility Functions ] =========== --


-------------------------------------------------------------------------------
--| Sorting Functions |--------------------------------------------------------
-------------------------------------------------------------------------------


-- TODO: Make these more customizable?

local INFO_PANEL_CHARACTER_INVENTORY_SORT =
{
    characterID = { tiebreaker = "locationType" },
    locationType = { tiebreaker = "count", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    count = { tiebreaker = ZO_SORT_ORDER_UP, isNumeric = true }
}


local function LuXhrys_VaC_InfoPanel_CharacterInventorySortComparator (left, right)
--    return ZO_TableOrderingFunction(left, right, "bestGamepadItemCategoryName", SORT_DEFAULT, ZO_SORT_ORDER_UP)
    return ZO_TableOrderingFunction(left, right, "characterID", INFO_PANEL_CHARACTER_INVENTORY_SORT, ZO_SORT_ORDER_UP)
end


local INFO_PANEL_COMPANION_INVENTORY_SORT =
{
    companionName = { tiebreaker = "companionID", tieBreakerSortOrder = ZO_SORT_ORDER_UP },
    companionID = { tiebreaker = "count", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    count = { tiebreaker = ZO_SORT_ORDER_UP, isNumeric = true }
}


local function LuXhrys_VaC_InfoPanel_CompanionEquippedInventorySortComparator (left, right)
--    return ZO_TableOrderingFunction(left, right, "bestGamepadItemCategoryName", SORT_DEFAULT, ZO_SORT_ORDER_UP)
    return ZO_TableOrderingFunction(left, right, "companionID", INFO_PANEL_COMPANION_INVENTORY_SORT, ZO_SORT_ORDER_UP)
end


local INFO_PANEL_PLACED_FURNITURE_INVENTORY_SORT =
{
    houseName = { tiebreaker = "houseCategory" },
    houseCategory = { tiebreaker = "houseID", tieBreakerSortOrder = ZO_SORT_ORDER_UP },
    houseID = { tiebreaker = "count", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    count = { tiebreaker = ZO_SORT_ORDER_UP, isNumeric = true }
}


local function LuXhrys_VaC_InfoPanel_PlacedFurnitureInventorySortComparator (left, right)
    return ZO_TableOrderingFunction(left, right, "houseName", INFO_PANEL_PLACED_FURNITURE_INVENTORY_SORT, ZO_SORT_ORDER_UP)
end


local INFO_PANEL_LISTING_INFORMATION_SORT =
{
    guildIndex = { tiebreaker = "guildName", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    guildName = { tiebreaker = "guildID", tieBreakerSortOrder = ZO_SORT_ORDER_UP },
    guildID = { tiebreaker = "count", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    count = { tiebreaker = ZO_SORT_ORDER_UP, isNumeric = true }
}


local function LuXhrys_VaC_InfoPanel_ListingInformationSortComparator (left, right)
    return ZO_TableOrderingFunction(left, right, "guildName", INFO_PANEL_PLACED_FURNITURE_INVENTORY_SORT, ZO_SORT_ORDER_UP)
end



-- ===================== [ Vault and Coffer InfoPanel ] ==================== --


--[[ InfoPanel

	-- InfoPanel - A custom tooltip for additional information about an item. We don't repeat most account-wide inventory locations because they appear on the standard tooltip. Placed furniture is the exception.

	-- Add InfoPanel Title - Should be font size 54, wrapped to next line, title case, with color by item quality.


	-- Add InfoPanel Character Inventory - Only appears when any characters have the item in their BAG_WORN, BAG_BACKPACK, BAG_BUYBACK, or BAG_VENGEANCE. BAG_WORN and BAG_VENGEANCE should indicate if the item cannnot be placed therein.


	-- Add character names for those who possess the item. TODO: add the ability to show character build if an equippable item.


	-- Add InfoPanel Companion Inventory if any companions have the item equipped.


	-- Instead of adding companion names for those who possess the item, just list the names of those who have it equipped. TODO: add the ability to show companion build.


	-- Add Placed Furniture Inventory if the item is placeable furniture and it is placed somewhere. List only houses where item is placed.


	-- Add InfoPanel Item Sourcing and Value.


	-- If item is craftable or is a recipe, show recipe, then list all characters and whether they know the recipe. Show how the recipe can be obtained and if any are in stock. TODO: add the ability to get extended inventory information about the recipe if the present item is the product of the recipe. We will need lookup table to map products to recipes, and LibCharacterKnowledge can indicate whether characters know the recipe.


	-- Add other sources of the item. LibSets can be used for gear sets once ported to console.
	-- GetItemLinkItemSetCollectionSlot(*string* _itemLink_) ** _Returns:_ *id64* _slot_
	-- GetNextItemSetCollectionId(*integer:nilable* _lastItemSetId_)
	-- GetItemLinkSetInfo(*string* _itemLink_, *bool* _equipped_) ** _Returns:_ *bool* _hasSet_, *string* _setName_, *integer* _numBonuses_, *integer* _numNormalEquipped_, *integer* _maxEquipped_, *integer* _setId_, *integer* _numPerfectedEquipped_

]]


local InfoPanelGamepad = ZO_InitializingObject:Subclass ()



local INFOPANEL_CATEGORY_CHARACTER_INVENTORY = 1
local INFOPANEL_CATEGORY_COMPANION_EQUIPPED = 2
local INFOPANEL_CATEGORY_PLACED_FURNITURE = 3
local INFOPANEL_CATEGORY_CRAFTING_INFO = 4
local INFOPANEL_CATEGORY_SOURCING_AND_VALUE = 5


-------------------------------------------------------------------------------
--| Initialization Functions |-------------------------------------------------
-------------------------------------------------------------------------------


-- The InfoPanel control is created from virtual by ListScreenGamepad. It is then initialized by the XML by creating an instance of this object at the end of this chunk. The argument "control" is the topmost container control for the InfoPanel (the same one created by the list screen).

function InfoPanelGamepad:Initialize (control)

	Debug.Msg (2, ADDON_DEBUG_NAME, "IPG_I", "Called.")


	self.infoPanel = control
	self.header = self.infoPanel:GetNamedChild ("MainHeaderContainer"):GetNamedChild ("Header")
	self.title = self.infoPanel.header:GetNamedChild ("TitleContainer"):GetNamedChild ("Title")


	-- Create fragment.

	self.fragment = ZO_FadeSceneFragment:New (self.control)


	-- Set shortcuts to parent and active target.

	self.parent = self:GetParent ()
	self.parentActiveTargetData = self.parent.activeTargetData


	-- Create the GridScrollList that makes up the main part of the InfoPanel.

	self.gridList = ZO_GridScrollList_Gamepad:New (self.infoPanel:GetNamedChild ("MainContentContainer"):GetNamedChild ("InfoPanel"))


	-- Initialize section category order list.

	self:InitializeSectionCategories ()


	-- Initialize GridList templates

	self:InitializeTemplates ()


	-- Initialize keybinds.

	self:InitializeKeybindStripDescriptors ()


	-- Set up selection change callback to show an additional panel. -- TODO: Implement this.

--	self.gridList:SetOnSelectedDataChangedCallback(function(...) self:OnSelectionChanged(...) end )
	self.gridList:SetOnSelectedDataChangedCallback (function () self:OnSelectionChanged () end)


	-- Hide the infoPanel until needed.

	self.infoPanel:SetHidden (true)


	Debug.Msg (2, ADDON_DEBUG_NAME, "IPG_I", "Completed.")

end


function InfoPanelGamepad:InitializeSectionCategories ()

	self.sectionCategories = -- TODO: Make the order of this list customizable.
	{
		{
			defaultSortOrder = 1,
			sortOrder = 1,
			callback = function (categoryData, targetData) self:UpdateCharacterInventory (categoryData, targetData) end,
			sectionTitleText = Location.GetTypeFilterName (LOCATION_TYPE_FILTER_BACKPACK), -- "Character Inventory"
			sectionIconFile = icons.general.ICON_OTHER_CHARACTER_LARGE
		},
		{
			defaultSortOrder = 2,
			sortOrder = 2,
			callback = function (categoryData, targetData) self:UpdateCompanionEquipped (categoryData, targetData) end,
			sectionTitleText = Location.GetTypeFilterName (LOCATION_TYPE_FILTER_COMPANION), -- "Companion Equipped"
			sectionIconFile = icons.general.ICON_COMPANION_EQUIPPED_LARGE
		},
		{
			defaultSortOrder = 3,
			sortOrder = 3,
			callback = function (categoryData, targetData) self:UpdatePlacedFurniture (categoryData, targetData) end,
			sectionTitleText = StrFormat ("%s %s", Location.GetTypeFilterName (LOCATION_TYPE_FILTER_HOUSE), GetString (SI_GAMEPAD_INVENTORY_CATEGORY_HEADER)), -- "House Furniture Inventory"
			sectionIconFile = icons.general.ICON_HOUSE_LARGE
		},
		{
			defaultSortOrder = 4,
			sortOrder = 4,
			callback = function (categoryData, targetData) self:UpdateListingInfo (categoryData, targetData) end,
			sectionTitleText =  GetString (SI_TRADING_HOUSE_MODE_LISTINGS), -- "Listings"
			sectionIconFile = icons.general.ICON_TRADER_LARGE
		},
		{
			defaultSortOrder = 5,
			sortOrder = 5,
			callback = function (categoryData, targetData) self:UpdateCraftingInfo (categoryData, targetData) end,
			sectionTitleText =  GetString (SI_BUGCATEGORY2), -- "Crafting"
			sectionIconFile = icons.general.ICON_CRAFTING_LARGE
		},
		{
			defaultSortOrder = 6,
			sortOrder = 6,
			callback = function (categoryData, targetData) self:UpdateSourcingAndValue (categoryData, targetData) end,
			sectionTitleText = zo_strformat (
				"<<1>> <<2>><<3>><<4>>",
				GetString (SI_TRADING_HOUSE_COLUMN_ITEM), -- "Item"
				GetString (SI_ITEMLISTSORTTYPE5), -- "Value"
				GetString (SI_LIST_AND_SEPARATOR), -- " and "
				GetString (SI_ITEMTAGCATEGORY3) -- "Sources"
			),
			sectionIconFile = icons.general.ICON_SOURCING_VALUE_LARGE
		}
	}

	-- Remove from global access.
-- LUXHRYS.VaC_InfoPanel_Gamepad_OnInitialize = nil

end


function InfoPanelGamepad:InitializeTemplates ()

	-- These functions take the passed data and set them to the controls for display. See next section below.


	-- This is a plain, single-label control with alignment option.

	local function SetupGenericTableRowEntry (control, data, list)

		control.nameLabel:SetText (data.nameLabelText)

		if data.textAlign and type (data.textAlign) == "number" then
			control.nameLabel:SetHorizontalAlignment (data.textAlign)
		end

	end

	-- Name and value pair.

	local function SetupNameValuePairTableRowEntry (control, data, list)
		control.nameLabel:SetText (data.nameLabelText)
		control.valueLabel:SetText (data.valueLabelText)
	end

	-- Table row entry: Two names and one value.

	local function SetupTwoNamesOneValueTableRowEntry (control, data, list)
		control.nameLabel1:SetText (data.nameLabel1Text)
		control.nameLabel2:SetText (data.nameLabel2Text)
		control.valueLabel:SetText (data.valueLabelText)
	end

	-- Table row entry: name and two values.

	local function SetupNameTwoValuesTableRowEntry (control, data, list)
		control.nameLabel:SetText (data.nameLabelText)
		control.valueLabel1:SetText (data.valueLabel1Text)
		control.valueLabel2:SetText (data.valueLabel2Text)
	end

	-- Table row entry: name and four values.

	local function SetupNameFourValuesTableRowEntry (control, data, list)
		control.nameLabel:SetText (data.nameLabelText)
		control.valueLabel1:SetText (data.valueLabel1Text)
		control.valueLabel2:SetText (data.valueLabel2Text)
		control.valueLabel3:SetText (data.valueLabel3Text)
		control.valueLabel4:SetText (data.valueLabel4Text)
	end

	local function SetupSectionHeaderEntry (control, data, list)

		control.icon:SetTexture (data.sectionIconFile)
--		control.icon:SetColor (ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA()) -- Color?

		control.title:SetText (data.sectionTitleText)
--		control.sectionTitle:SetColor(STAT_LOWER_COLOR:UnpackRGBA ()) -- Color?
	end

	local function SetupSubTitleEntry (control, data, list)
		control.subSectionIcon:SetTexture (data.subSectionIconFile)
		control.subSectionTitle:SetText (data.subSectionTitleText)
	end

	-- Table header entry to go with name and four values rows.

	local function SetupTableIconHeaderEntry (control, data, list)
		control.tableHeaderIcon1:SetTexture (data.tableHeaderIcon1File)
		control.tableHeaderIcon2:SetTexture (data.tableHeaderIcon2File)
		control.tableHeaderIcon3:SetTexture (data.tableHeaderIcon3File)
		control.tableHeaderIcon4:SetTexture (data.tableHeaderIcon4File)
	end

	-- Placed furniture inventory.

	local function SetupPlacedFurnitureInventoryTableRowEntry (control, data, list)
		control.nameLabel:SetText (data.nameLabelText)
		control.categoryLabel:SetText (data.categoryLabelText)
		control.valueLabel:SetText (data.valueLabelText)
	end


	-- These functions are called when entries are added to the list. They call the indicated setup function above to assign values to the controls.


	-- Generic text row (single label), generally used for something like "No results found." Not selectable.

	self.gridList:AddEntryTemplate (
		"LuXhrys_VaC_InfoPanel_GenericEntryRow_Template_Gamepad",
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_ENTRY_WIDTH,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_ENTRY_HEIGHT,
		SetupGenericTableRowEntry,
		nil,
		nil,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_X,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_Y
	)

	-- Generic table row entry name/value pair. Selectable. (companion equipped inventory, value section)

	self.gridList:AddEntryTemplate (
		"LuXhrys_VaC_InfoPanel_NameValuePairEntryRow_Template_Gamepad",
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_ENTRY_WIDTH,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_ENTRY_HEIGHT,
		SetupNameValuePairTableRowEntry,
		nil,
		nil,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_X,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_Y,
		nil,
		true -- TODO: Show sourcing details upon selection.
	)

	-- Table row entry: Two names and one value.

	self.gridList:AddEntryTemplate (
		"LuXhrys_VaC_InfoPanel_TwoNamesOneValueEntryRow_Template_Gamepad",
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_ENTRY_WIDTH,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_ENTRY_HEIGHT,
		SetupTwoNamesOneValueTableRowEntry,
		nil,
		nil,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_X,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_Y,
		nil,
		true -- TODO: Show sourcing details upon selection.
	)

	-- Table row entry: name and two values.
	-- Listings: guild name, quantity, price; also furniture store, # for sale, price
	-- Placed furniture: house name, house category, and quantity placed

	self.gridList:AddEntryTemplate (
		"LuXhrys_VaC_InfoPanel_NameTwoValuesEntryRow_Template_Gamepad",
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_ENTRY_WIDTH,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_ENTRY_HEIGHT,
		SetupNameTwoValuesTableRowEntry,
		nil,
		nil,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_X,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_Y,
		nil,
		true -- TODO: Show guild tooltip upon selection? Maybe show # of listings, or all info? Show house tooltip upon selection?
	)

	-- Table row entry: name and four values (character inventory, listings information)

	self.gridList:AddEntryTemplate (
		"LuXhrys_VaC_InfoPanel_NameFourValuesEntryRow_Template_Gamepad",
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_ENTRY_WIDTH,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_ENTRY_HEIGHT,
		SetupNameFourValuesTableRowEntry,
		nil,
		nil,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_X,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_Y,
		nil,
		true -- TODO: Show character build, house stats upon selection?
	)


	-- Crafting information: whether craftable, whether known, recipe/result link, recipe (shouldn't need, on tooltip), ingredient sources and cost (add to tooltip?), total cost to craft (TODO: latter two might be later)


	-- Item sourcing and value TODO: most of this



	-- Section header with icon

	self.gridList:AddEntryTemplate (
		"LuXhrys_VaC_InfoPanel_SectionTitle_Template_Gamepad",
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_SECTION_HEADER_WIDTH,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_SECTION_HEADER_HEIGHT,
		SetupSectionHeaderEntry,
		nil,
		nil,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_X,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_Y
	)

	--   Table subheader icon and name

	self.gridList:AddEntryTemplate (
		"LuXhrys_VaC_InfoPanel_SubSectionTitleRow_Template_Gamepad",
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_ENTRY_WIDTH,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_ENTRY_HEIGHT,
		SetupSubTitleEntry,
		nil,
		nil,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_X,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_Y
	)


	-- Special table row entry for character inventory table icon header bar

	self.gridList:AddEntryTemplate (
		"LuXhrys_VaC_InfoPanel_TableIconHeader_Template_Gamepad",
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_NARROW_GAMEPAD_CONSTANTS_ENTRY_WIDTH,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_ENTRY_HEIGHT,
		SetupTableIconHeaderEntry,
		nil,
		nil,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_X,
		LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_GRID_PADDING_Y
	)

end


function InfoPanelGamepad:InitializeKeybindStripDescriptors ()

	self.keybindStripDescriptor = {}

	ZO_Gamepad_AddBackNavigationKeybindDescriptors (
		self.keybindStripDescriptor,
		GAME_NAVIGATION_TYPE_BUTTON,
		function()
			self:ExitGridList()
			self.parent:ActivateMainList() -- TODO: Is this the right function?
		end
	)

end


-------------------------------------------------------------------------------
--| Main Header Functions |----------------------------------------------------
-------------------------------------------------------------------------------


-- Main header (above gridlist)

function InfoPanelGamepad:UpdateMainHeaderText ()

	Debug.Msg (2, ADDON_DEBUG_NAME, "IPG_UMHT", "Called.")

--	local targetData = self.parentActiveTargetData

	self.title:SetText (self.parentActiveTargetData.name)

	Debug.Msg (2, ADDON_DEBUG_NAME, "IPG_UMHT", "Completed.")

end


-------------------------------------------------------------------------------
--| GridList Management Functions |--------------------------------------------
-------------------------------------------------------------------------------


-- TODO: Change extended tooltip?

function InfoPanelGamepad:OnSelectionChanged (previousData, newData)


-- Tooltips!
--[[

    --If we don't have new data this means we no longer have anything selected, so we want to hide the tooltip completely
    if not newData then
        local DO_NOT_RETAIN_FRAGMENT = false
        GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP, DO_NOT_RETAIN_FRAGMENT)
    else
        local RETAIN_FRAGMENT = true;
        GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP, RETAIN_FRAGMENT)
        GAMEPAD_TOOLTIPS:LayoutAdvancedAttributeTooltip(GAMEPAD_RIGHT_TOOLTIP, newData)
    end


]]
end


function InfoPanelGamepad:EnterGridList ()
	self.gridList:Activate ()
	KEYBIND_STRIP:AddKeybindButtonGroup (self.keybindStripDescriptor)
end


function InfoPanelGamepad:ExitGridList ()
	self.gridList:Deactivate ()
	KEYBIND_STRIP:RemoveKeybindButtonGroup (self.keybindStripDescriptor)
end


-------------------------------------------------------------------------------
--| GridList Section Functions |-----------------------------------------------
-------------------------------------------------------------------------------


--/ Main Update Function /-----------------------------------------------------


function InfoPanelGamepad:Update (targetData)

	Debug.Msg (2, ADDON_DEBUG_NAME, "IPG_U", "Called.")

	self.gridList:ClearGridList ()

--	local targetData = self.parentActiveTargetData
--	local categoryCallback, categoryTitle, categoryIcon

	for categoryIndex, categoryData in ipairs (self.sectionCategories) do

--		categoryCallback = unpack (categoryData)

--		categoryCallback (categoryData, targetData)
		categoryData.callback (categoryData, targetData)

	end

	self.gridList:CommitGridList ()
	self.gridList:RefreshGridList ()
	self:SetHidden (false)


	Debug.Msg (2, ADDON_DEBUG_NAME, "IPG_U", "Completed.")

end


--/ Section Header Common Function /-------------------------------------------


function InfoPanelGamepad:AddSectionHeader (categoryData)

	Debug.Msg (2, ADDON_DEBUG_NAME, "IPG_ASH", "Called.")

	local sectionData =
	{
		sectionTitleText = categoryData.sectionTitleText,
		sectionIconFile = categoryData.sectionIconFile,
		narrationText = function (entryData)
			return SCREEN_NARRATION_MANAGER:CreateNarratableObject (entryData.sectionTitleText)
		end
	}

	self.gridList:AddEntry (ZO_GridSquareEntryData_Shared:New (sectionData), "LuXhrys_VaC_InfoPanel_SectionTitle_Template_Gamepad")

	Debug.Msg (2, ADDON_DEBUG_NAME, "IPG_ASH", "Completed.")

end


--/ Character Inventory Section /----------------------------------------------


function InfoPanelGamepad:UpdateCharacterInventory (categoryData, targetData)

	Debug.Msg (2, ADDON_DEBUG_NAME, "IPG_UChI", "Called.")

--	local itemData = targetData.itemData

	assert (targetData.itemData == nil, "[" .. ADDON_DEBUG_NAME .. ":IPG_UChI] No itemData.")

	if targetData.itemData.extendedStackCounts[LOCATION_TYPE_FILTER_WORN] > 0
	or targetData.itemData.extendedStackCounts[LOCATION_TYPE_FILTER_BACKPACK] > 0
	or targetData.itemData.extendedStackCounts[LOCATION_TYPE_FILTER_BUYBACK] > 0
	or targetData.itemData.extendedStackCounts[LOCATION_TYPE_FILTER_VENGEANCE] > 0
	then

		self:AddSectionHeader (categoryData)

		local itemInfo = DBLOOKUP:GetItemInfo (targetData.itemKey)

		-- Pull the data out of the itemInfo.

		local sectionData = {}

		local itemCountData


		for locationCode, count in ItemInfo.GetLocationCodesAndStackCountsByCharacterIter (itemInfo) do

			count = ToNumber (count)

			if count > 0 then

				itemCountData = {}

				itemCountData.locationType, itemCountData.characterID = Location.GetCodeTypeAndID (locationCode)
				itemCountData.count = count

--[[				if not sectionData.characterID then
					sectionData.characterID = {}
				end

				if sectionData.characterID.locationType then
					Debug.Msg (1, "UIPCI: Location type %d appears twice in itemInfo. Summing counts.", locationType)
					sectionData.characterID.locationType = sectionData.characterID.locationType + count
				else
					sectionData.characterID.locationType = count
				end
]]

--				TableInsert (sectionData, itemCountData)
				sectionData[#sectionData + 1] = itemCountData

			end -- if count > 0 then

		end -- for locationCode, count in GetItemInfoLocationCodesAndStackCountsByCharacterIter (itemInfo) do

		TableSort (sectionData, LuXhrys_VaC_InfoPanel_CharacterInventorySortComparator)


		-- Now that we have our data sorted by characterID and locationType, let's build a per-character table.

		itemCountData = {}

		local countData = {}

		for index = 1, #sectionData do

			-- We don't know if this is the last member of the category until the next iteration, so we'll add the data from the previous iteration to the table here. On the last iteration, we'll need to add a special exception to add it at the end (see below).

			if itemCountData.characterID and itemCountData.characterID ~= sectionData[index].characterID then
--				TableInsert (countData, itemCountData)
				countData[#countData + 1] = itemCountData
				itemCountData = {}
			end

			itemCountData.characterID = sectionData[index].characterID

			if sectionData[index].locationType == LOCATION_TYPE_CHAR then
				itemCountData.backpackCount = sectionData[index].count
			elseif sectionData[index].locationType == LOCATION_TYPE_BUYBACK then
				itemCountData.buybackCount = sectionData[index].count
			elseif sectionData[index].locationType == LOCATION_TYPE_VENGEANCE then
				itemCountData.vengeanceCount = sectionData[index].count
			elseif sectionData[index].locationType == LOCATION_TYPE_WORN then
				itemCountData.equippedCount = sectionData[index].count
			else
				assert (false, "[" .. ADDON_DEBUG_NAME .. ":IPG_UChI] Invalid location type %s exists for character inventory.", ToNumber (sectionData[index].locationType))
			end

			-- Last entry, so we cannot add it on the next iteration.

			if index == #sectionData then
--				TableInsert (countData, itemCountData)
				countData[#countData + 1] = itemCountData
			end

		end -- for index = 1, #sectionData do


		-- Add the icon header row.

		local rowData =
		{
			tableHeaderIcon1File = icons.tooltipStackCount[BAG_WORN],
			tableHeaderIcon2File = icons.general.ICON_BAG_BACKPACK_SMALL,
			tableHeaderIcon3File = icons.tooltipStackCount[BAG_BUYBACK],
			tableHeaderIcon4File = icons.tooltipStackCount[BAG_VENGEANCE]
		}

		self.gridList:AddEntry (ZO_GridSquareEntryData_Shared:New (rowData), "LuXhrys_VaC_InfoPanel_TableIconHeader_Template_Gamepad")


		-- Now that we have data organized by character, let's build our entryData and add them.

		local LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_CHARACTER_INVENTORY_ROW_NARRATION_FORMATTER_ONE = "<<1>> <<2>> <<3>> <<4>> <<5>>"
		local LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_CHARACTER_INVENTORY_ROW_NARRATION_FORMATTER_TWO = " <<1>> <<2>> <<3>> <<4>>"

		rowData = nil

		for index = 1, #countData do

			rowData =
			{
				nameLabelText = zo_strformat ("<<C:1>>", GetCharacterNameById (StringToId64 (countData[index].characterID))),
				valueLabel1Text = countData[index].equippedCount or 0,
        valueLabel2Text = countData[index].backpackCount or 0,
        valueLabel3Text = countData[index].buybackCount or 0,
        valueLabel4Text = countData[index].vengeanceCount or 0,
				narrationText = function (entryData)

					-- Use zo_strformat to ensure that any remaining localization is done. It's limited to seven args, so split it up.

					local narration1 = zo_strformat (
						LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_CHARACTER_INVENTORY_ROW_NARRATION_FORMATTER_ONE,
						entryData.nameLabelText,
						Location.GetTypeFilterName (LOCATION_TYPE_FILTER_WORN),
						entryData.valueLabel1Text,
						Location.GetTypeFilterName (LOCATION_TYPE_FILTER_BACKPACK),
						entryData.valueLabel2Text
					)

					local narration2 = zo_strformat (
						LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_CHARACTER_INVENTORY_ROW_NARRATION_FORMATTER_TWO,
						Location.GetTypeFilterName (LOCATION_TYPE_FILTER_BUYBACK),
						entryData.valueLabel3Text,
						Location.GetTypeFilterName (LOCATION_TYPE_FILTER_VENGEANCE),
						entryData.valueLabel4Text
					)

					return SCREEN_NARRATION_MANAGER:CreateNarratableObject (StrFormat ("%s %s", narration1, narration2))
				end
			}

			-- TODO: Show build tooltip for that character.

			self.gridList:AddEntry (ZO_GridSquareEntryData_Shared:New (rowData), "LuXhrys_VaC_InfoPanel_NameFourValuesEntryRow_Template_Gamepad")

--			rowData = {} -- this is set to a new table on the next iteration, no need to clear here

		end -- for index = 1, #countData do

	end -- if targetData.itemData.extendedStackCounts[LOCATION_TYPE_FILTER_WORN] > 1 or ...

	self.gridList:AddLineBreak (LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMMON_GAMEPAD_CONSTANTS_SECTION_SPACING)

	Debug.Msg (2, ADDON_DEBUG_NAME, "IPG_UChI", "Completed.")

end


--/ Companion Equipped Inventory Section /-------------------------------------


function InfoPanelGamepad:UpdateCompanionEquipped (categoryData, targetData)

	Debug.Msg (1, ADDON_DEBUG_NAME, "IPG_UCE: Called.")

	if targetData.itemData.extendedStackCounts[LOCATION_TYPE_FILTER_COMPANION] > 0 then

		self:AddSectionHeader (categoryData)

		local itemInfo = DBLOOKUP:GetItemInfo (targetData.itemKey)

		-- Pull the data out of the itemInfo.

		local sectionData = {}

		local companionCountData

		for locationCode, count in ItemInfo.GetLocationCodesAndStackCountsByCompanionIter (itemInfo) do

			count = ToNumber (count)

			if count > 0 then

				companionCountData =
				{
					companionID = ToNumber (Location.GetCodeID (locationCode)),
					companionName = zo_strformat (SI_COMPANION_NAME_FORMATTER, GetCompanionName (companionCountData.companionID)),
					count = count
				}

--				TableInsert (sectionData, companionCountData)
				sectionData[#sectionData + 1] = companionCountData

			end -- if count > 0 then

		end -- for locationCode, count in GetItemInfoLocationCodesAndStackCountsByCompanionIter (itemInfo) do

		TableSort (sectionData, LuXhrys_VaC_InfoPanel_CompanionEquippedInventorySortComparator)



		-- Now that we have data organized by character, let's build our entryData and add them.

--		local LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMPANION_EQUIPPED_INVENTORY_ROW_NARRATION_FORMATTER = "<<C:1>> <<2>> <<3>> <<4>> <<5>>"
		local LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMPANION_EQUIPPED_INVENTORY_ROW_NARRATION_FORMATTER = "<<C:1>> <<2>> <<3>>"


		local rowData

		for index = 1, #sectionData do

			rowData =
			{
				nameLabelText = sectionData[index].companionName,
        valueLabelText = sectionData[index].count or 0,
				narrationText = function (entryData)

					-- Use zo_strformat to ensure that any remaining localization is done.

					local narration = zo_strformat (
						LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_COMPANION_EQUIPPED_INVENTORY_ROW_NARRATION_FORMATTER,
						entryData.nameLabelText,
--						GetString (SI_SMITHING_HEADER_ITEM), -- "Slot"
--						entryData.categoryLabelText,
--						zo_strformat ( StrFormat ("%s %s", GetString (SI_GAMEPAD_EQUIPPED_ITEM_HEADER), GetString (SI_UTILITY_WHEEL_SLOT_FORMATTER)), entryData.categoryLabelText), -- "Equipped Slot <<slotName>>"
--						GetLocationTypeFilterName (LOCATION_TYPE_FILTER_COMPANION), -- "Companion Equipped"
						entryData.valueLabelText,
						GetString (SI_CRAFTED_ABILITY_SLOTTED_TOOLTIP_HEADER) -- "Slotted"
					)

					return SCREEN_NARRATION_MANAGER:CreateNarratableObject (narration)

				end

			}

			-- TODO: Show build tooltip for that companion.
			-- Which slots?

			self.gridList:AddEntry (ZO_GridSquareEntryData_Shared:New (rowData), "LuXhrys_VaC_InfoPanel_NameValuePairEntryRow_Template_Gamepad")

--			rowData = {}

		end -- for index = 1, #countData do

	end -- if targetData.itemData.extendedStackCounts[LOCATION_TYPE_FILTER_COMPANION] > 1 then

	Debug.Msg (1, ADDON_DEBUG_NAME, "IPG_UCE: Completed.")

end


--/ Placed Furniture Inventory Section /---------------------------------------


function InfoPanelGamepad:UpdatePlacedFurniture (categoryData, targetData)

	Debug.Msg (1, ADDON_DEBUG_NAME, "IPG_UPF: Called with %s placed items.", targetData.itemData.extendedStackCounts[LOCATION_TYPE_FILTER_HOUSE])

	if targetData.itemData.extendedStackCounts[LOCATION_TYPE_FILTER_HOUSE] > 0 then

		self:AddSectionHeader (categoryData)

		local itemInfo = DBLOOKUP:GetItemInfo (targetData.itemKey)

		-- Pull the data out of the itemInfo.

		local sectionData = {}

		local locationCountData

		for locationCode, count in ItemInfo.GetLocationCodesAndStackCountsByTypeIter (itemInfo, Location.GetTypePrefix (LOCATION_TYPE_HOUSE)) do

			count = ToNumber (count)

			if count > 0 then

				locationCountData =
				{
					houseID = ToNumber (Location.GetCodeID (locationCode)),
					houseName = HOUSING_SOCIAL_MANAGER:GetHouseName (locationCountData.houseID),
					houseCategoryName = GetString ("SI_HOUSECATEGORYTYPE", GetHouseCategoryType (locationCountData.houseID)),
					count = count
				}

--				TableInsert (sectionData, locationCountData)
				sectionData[#sectionData + 1] = locationCountData

			end -- if count > 0 then

		end -- for locationCode, count in LUXHRYS_GetItemInfoLocationCodesAndStackCountsByTypeIter (itemInfo) do

		TableSort (sectionData, LuXhrys_VaC_InfoPanel_PlacedFurnitureInventorySortComparator)


		local LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_PLACED_FURNISHING_ROW_NARRATION_FORMATTER = "<<1>>: <<2>>, <<3>>: <<4>>, <<5>> <<6>>"

		local rowData

		for index = 1, #sectionData do

			rowData =
			{
				nameLabel1Text = sectionData[index].houseName,
				nameLabel2Text = sectionData[index].houseCategoryName, -- TODO: This may be coming out.
        valueLabelText = sectionData[index].count or 0,
				narrationText = function (entryData)

					-- Use zo_strformat to ensure that any remaining localization is done.

					local narration = zo_strformat (
						LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_PLACED_FURNISHING_ROW_NARRATION_FORMATTER,
						GetString (SI_HOUSE_TOURS_FILTERS_HOUSE_DROPDOWN_HEADER), -- "House Name"
						entryData.nameLabelText,
						GetString (SI_HOUSE_TOURS_FILTERS_HOUSE_CATEGORY_DROPDOWN_HEADER), -- "House Category"
						entryData.categoryLabelText,
						entryData.valueLabelText,
						GetString (SI_INVENTORY_MODE_ITEMS) -- "Items"
					)

					return SCREEN_NARRATION_MANAGER:CreateNarratableObject (narration)

				end

			}

			-- TODO: Show house stats tooltip for each house?

			self.gridList:AddEntry (ZO_GridSquareEntryData_Shared:New (rowData), "LuXhrys_VaC_InfoPanel_TwoNamesOneValueEntryRow_Template_Gamepad")

--			rowData = {}

		end -- for index = 1, #countData do

	end -- if targetData.itemData.extendedStackCounts[LOCATION_TYPE_FILTER_HOUSE] > 1 then

	Debug.Msg (1, ADDON_DEBUG_NAME, "IPG_UPF: Completed.")

end


--/ Guild Trader and Furniture Showcase Listings Section /---------------------


function InfoPanelGamepad:UpdateListingInfo (categoryData, targetData)

	Debug.Msg (1, ADDON_DEBUG_NAME, "IPG_ULI: Called.")

	self:AddSectionHeader (categoryData)

	local rowData

	-- If there are no listings, still print the section with "No results found."

	if targetData.itemData.extendedStackCounts[LOCATION_TYPE_FILTER_TRADER] < 1 then

		-- an alternative: SI_DEATH_PROMPT_NO_SOUL_GEMS_PVP -- "No <<1>> found" used with SI_TRADING_HOUSE_MODE_LISTINGS -- "Listings"

		rowData = {
			nameLabelText = GetString (SI_GAMEPAD_MOD_BROWSER_NO_RESULTS), -- "No results found."
			textAlign = TEXT_ALIGN_CENTER
		}

		self.gridList:AddEntry (ZO_GridSquareEntryData_Shared:New (rowData), "LuXhrys_VaC_InfoPanel_GenericEntryRow_Template_Gamepad")

		return

	end

	-- Guild trader listings

	if targetData.itemData.extendedStackCounts[LOCATION_TYPE_FILTER_TRADER] > 0 then

		local itemInfo = DBLOOKUP:GetItemInfo (targetData.itemKey)

		-- Pull the data out of the itemInfo.

		local sectionData = {}

		local listingData

-- Guild Name, Qty Listed, Total Price, Total Profit, Expiry

		for locationCode, count in ItemInfo.GetLocationCodesAndStackCountsByTypeIter (itemInfo, Location.GetTypePrefix (LOCATION_TYPE_TRADER)) do

			count = ToNumber (count)

			if count > 0 then

				listingData =
				{
					guildID = ToNumber (Location.GetCodeID (locationCode)),
					guildIndex = GetGuildIndex (listingData.guildID),
					guildName = GetGuildName (listingData.guildID),
					count = count,
					totalPrice = 0, -- I think we'll have to add these to the database :(
					totalProfit = 0,
					expiry = 0
--			listingData.expiry = ZO_FormatTime (itemData.timeRemaining, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT, TIME_FORMAT_PRECISION_TWELVE_HOUR_NO_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
				}

--[[
* GetTradingHousePostPriceInfo(*integer* _desiredPostPrice_)
** _Returns:_ *integer* _listingFee_, *integer* _tradingHouseCut_, *integer* _expectedProfit_

* GetTradingHouseListingPercentage()
** _Returns:_ *number* _listingPercentage_

* GetTradingHouseCutPercentage()
** _Returns:_ *number* _cutPercentage_
]]
--				TableInsert (sectionData, listingData)
				sectionData[#sectionData + 1] = listingData

			end -- if count > 0 then

		end -- for locationCode, count in GetItemInfoLocationCodesAndStackCountsByCharacterIter (itemInfo) do

		TableSort (sectionData, LuXhrys_VaC_InfoPanel_ListingInformationSortComparator)


		-- Now that we have data organized by character, let's build our entryData and add them.

		local LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_LISTING_INFORMATION_ROW_NARRATION_FORMATTER_ONE = "<<1>>: <<2>>, <<3>> <<4>>: <<5>>, <<6>>"
		local LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_LISTINg_INFORMATION_ROW_NARRATION_FORMATTER_TWO = " <<1>>, <<2>>: <<3>>, <<4>> <<5>>"


		for index = 1, #sectionData do

			rowData =
			{
				nameLabelText = sectionData[index].guildName,
				valueLabel1Text = sectionData[index].count or 0,
        valueLabel2Text = sectionData[index].totalPrice or 0,
        valueLabel3Text = sectionData[index].totalProfit or 0,
        valueLabel4Text = sectionData[index].expiry or "",
				narrationText = function (entryData)

					-- Use zo_strformat to ensure that any remaining localization is done. It's limited to seven args, so split it up.

					local narration1 = zo_strformat (
						LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_LISTING_INFORMATION_ROW_NARRATION_FORMATTER_ONE,
						GetString (SI_GUILDMETADATAATTRIBUTE1), -- "Guild Name"
						entryData.nameLabelText,
						GetString (SI_GAMEPAD_QUANTITY_SPINNER_TEMPLATE_LABEL), -- "Quantity"
						GetString (SI_HOUSE_TOURS_MANAGE_LISTING_STATUS_LISTED), -- "Listed"
						entryData.valueLabel1Text,
						GetString (SI_TRADING_HOUSE_POSTING_PRICE_TOTAL) -- "Total Price:"
					)

					local narration2 = zo_strformat (
						LUXHRYS_EXTENDED_INVENTORY_INFO_PANEL_LISTINg_INFORMATION_ROW_NARRATION_FORMATTER_TWO,
						entryData.valueLabel2Text,
						GetString (SI_TRADING_HOUSE_POSTING_PROFIT), -- "Profit"
						entryData.valueLabel3Text,
						GetString (SI_MAIL_INBOX_EXPIRES_HEADER), -- "Expires In:"
						entryData.valueLabel4Text
					)

					return SCREEN_NARRATION_MANAGER:CreateNarratableObject (StrFormat ("%s %s", narration1, narration2))
				end
			}

			-- TODO: Show something for each guild or listing?

			self.gridList:AddEntry (ZO_GridSquareEntryData_Shared:New (rowData), "LuXhrys_VaC_InfoPanel_NameFourValuesEntryRow_Template_Gamepad")

--			rowData = {}

		end -- for index = 1, #countData do

	end -- if targetData.itemData.extendedStackCounts[LOCATION_TYPE_FILTER_TRADER] > 0 then

		-- Furniture store listings go here.

	Debug.Msg (1, ADDON_DEBUG_NAME, "IPG_ULI: Completed.")

end


--/ Crafting Information Section /---------------------------------------------


function InfoPanelGamepad:UpdateCraftingInfo (categoryData, targetData)

	Debug.Msg (1, ADDON_DEBUG_NAME, "IPG_UCrI: Called with itemType %d.", targetData.itemData.itemType)

	if targetData.itemData.itemType == ITEMTYPE_RECIPE then -- This item is a recipe.

		self:AddSectionHeader (categoryData)

	end
--[[
	GetItemLinkRecipeResultItemLink(*string* _itemLink_, *[LinkStyle|#LinkStyle]* _linkStyle_)

IsItemLinkRecipeKnown(*string* _itemLink_)



	elseif targetData.itemData.itemType == ITEMTYPE_FURNISHING then end



if IsItemLinkFurnitureRecipe(targetData.itemData.itemLink) or 0 then end

GetItemLinkRecipeNumIngredients(*string* _itemLink_)
GetItemLinkRecipeIngredientItemLink(*string* _itemLink_, *luaindex* _index_, *[LinkStyle|#LinkStyle]* _linkStyle_)
GetItemLinkRecipeNumTradeskillRequirements(*string* _itemLink_)

* GetItemLinkRecipeIngredientInfo(*string* _itemLink_, *luaindex* _index_)
** _Returns:_ *string* _ingredientName_, *integer* _amountInInventoryAndBank_, *integer* _amountRequired_

* GetItemLinkRecipeTradeskillRequirement(*string* _itemLink_, *luaindex* _tradeskillIndex_)
** _Returns:_ *[TradeskillType|#TradeskillType]* _tradeskill_, *integer* _requiredLevel_


* GetItemLinkRecipeQualityRequirement(*string* _itemLink_)
** _Returns:_ *integer* _qualityRequirement_

* GetItemLinkRecipeCraftingSkillType(*string* _itemLink_)
** _Returns:_ *[TradeskillType|#TradeskillType]* _craftingSkillType_

* GetItemLinkReagentTraitInfo(*string* _itemLink_, *luaindex* _index_)
** _Returns:_ *bool:nilable* _known_, *string:nilable* _name_

* GetItemLinkItemStyle(*string* _itemLink_)
** _Returns:_ *integer* _style_


* GetSmithingPatternMaterialItemInfo(*luaindex* _patternIndex_, *luaindex* _materialIndex_)
** _Returns:_ *string* _itemName_, *textureName* _icon_, *integer* _stack_, *integer* _sellPrice_, *bool* _meetsUsageRequirement_, *[EquipType|#EquipType]* _equipType_, *integer* _itemStyleId_, *[ItemDisplayQuality|#ItemDisplayQuality]* _displayQuality_, *integer* _itemInstanceId_, *integer* _skillRequirement_, *integer* _createsItemOfLevel_, *bool* _isChampionPoint_

* GetSmithingPatternMaterialItemLink(*luaindex* _patternIndex_, *luaindex* _materialIndex_, *[LinkStyle|#LinkStyle]* _linkStyle_)
** _Returns:_ *string* _link_

* GetSmithingPatternArmorType(*luaindex* _patternIndex_)
** _Returns:_ *[ArmorType|#ArmorType]* _armorType_


* GetSmithingPatternInfoForItemSet(*integer* _itemTemplateId_, *integer* _itemSetId_, *integer* _materialItemId_, *[ItemTraitType|#ItemTraitType]* _traitType_)
** _Returns:_ *luaindex:nilable* _patternIndex_, *luaindex:nilable* _materialIndex_, *integer:nilable* _resultingItemId_
]]


	Debug.Msg (1, ADDON_DEBUG_NAME, "IPG_UCrI: Completed.")

end


--/ Item Sourcing and Value Section /------------------------------------------


function InfoPanelGamepad:UpdateSourcingAndValue (categoryData, targetData)

	Debug.Msg (1, ADDON_DEBUG_NAME, "IPG_USAV: Called.")

--[[

* GetItemLinkInfo(*string* _itemLink_)
** _Returns:_ *string* _icon_, *integer* _sellPrice_, *bool* _meetsUsageRequirement_, *[EquipType|#EquipType]* _equipType_, *integer* _itemStyleId_

* GetItemSellValueWithBonuses(*[Bag|#Bag]* _bagId_, *integer* _slotIndex_)
** _Returns:_ *integer* _sellPrice_


* GetStoreEntryInfo(*luaindex* _entryIndex_)
** _Returns:_ *textureName* _icon_, *string* _name_, *integer* _stack_, *integer* _price_, *integer* _sellPrice_, *bool* _meetsRequirementsToBuy_, *bool* _meetsRequirementsToUse_, *integer* _quality_, *bool* _questNameColor_, *[CurrencyType|#CurrencyType]* _currencyType1_, *integer* _currencyQuantity1_, *[CurrencyType|#CurrencyType]* _currencyType2_, *integer* _currencyQuantity2_, *[StoreEntryType|#StoreEntryType]* _entryType_, *[StoreFailure|#StoreFailure]* _buyStoreFailure_, *integer* _buyErrorStringId_, *integer* _actorCategory_



* GetItemSetName(*integer* _itemSetId_)
** _Returns:_ *string* _name_

* GetItemSetType(*integer* _itemSetId_)
** _Returns:_ *[ItemSetType|#ItemSetType]* _type_

* GetItemSetUnperfectedSetId(*integer* _itemSetId_)
** _Returns:_ *integer* _unperfectedSetId_

* GetNumItemSetCollectionPieces(*integer* _itemSetId_)
** _Returns:_ *integer* _numPieces_

* GetItemSetCollectionPieceInfo(*integer* _itemSetId_, *luaindex* _index_)
** _Returns:_ *integer* _pieceId_, *[ItemSetCollectionSlot_id64|#ItemSetCollectionSlot_id64]* _slot_



* GetParentZoneId(*integer* _zoneId_)
** _Returns:_ *integer* _parentZoneId_

* GetZoneNameById(*integer* _zoneId_)
** _Returns:_ *string* _name_

* GetFastTravelNodeZoneDisplayType(*luaindex* _nodeIndex_)
** _Returns:_ *[ZoneDisplayType|#ZoneDisplayType]* _zoneDisplayType_


* GetItemSetInfo(*integer* _itemSetId_)
** _Returns:_ *bool* _hasSet_, *string* _setName_, *integer* _numBonuses_, *integer* _numNormalEquipped_, *integer* _numPerfectedEquipped_, *integer* _maxEquipped_

* GetItemSetBonusInfo(*integer* _itemSetId_, *luaindex* _index_)
** _Returns:_ *integer* _numRequired_, *string* _bonusDescription_, *bool* _isPerfectedBonus_

]]

	Debug.Msg (1, ADDON_DEBUG_NAME, "IPG_USAV: Completed.")

end



function LUXHRYS.VaC_InfoPanel_Gamepad_OnInitialize (control)
	Debug.Msg (2, ADDON_DEBUG_NAME, "LSG_OI", "UI initializing.")
	LUXHRYS.INFO_PANEL_GAMEPAD = InfoPanelGamepad:New (control)
	Debug.Msg (2, ADDON_DEBUG_NAME, "LSG_OI", "UI initialized.")
end





--[[

    "Clear Selections", -- SI_CRAFTING_CLEAR_SELECTIONS

--    "Seller: <<1>>", -- SI_TRADING_HOUSE_SEARCH_RESULT_SELLER_FORMATTER
--    "Seller: |cffffff<<1>>", -- SI_TRADING_HOUSE_BROWSE_ITEM_SELLER_NAME
--    "Cannot Sell", -- SI_ITEMSELLINFORMATION4
--    "Invalid Item.", -- SI_STOREITEMRESULT1
--    "List for sale", -- SI_GAMEPAD_TRADING_HOUSE_CONFIRM_SELL_DIALOG_TITLE
--    "My Listings", -- SI_HOUSE_TOURS_MANAGE_LISTINGS
--    "My Listing", -- SI_GROUP_FINDER_MY_GROUP_LISTING
--    "Listed", -- SI_HOUSE_TOURS_MANAGE_LISTING_STATUS_LISTED
--    "Not Listed", -- SI_HOUSE_TOURS_MANAGE_LISTING_STATUS_NOT_LISTED
--     "Manage Listing", -- SI_HOUSE_TOURS_MANAGE_LISTING
--     "Listed", -- SI_SCREEN_NARRATION_LISTED_RESIDENCE_ICON_NARRATION
--     "Not Listed", -- SI_GUILDRECRUITMENTSTATUSATTRIBUTEVALUE0
--    "Listed", -- SI_GUILDRECRUITMENTSTATUSATTRIBUTEVALUE1
--    "List Item", -- SI_TRADING_HOUSE_POST_ITEM
--    "Add to Listing", -- SI_TRADING_HOUSE_ADD_ITEM_TO_LISTING
--    "Remove from Listing", -- SI_TRADING_HOUSE_REMOVE_PENDING_POST
--    "Select an item in your inventory to list it for sale.", -- SI_TRADING_HOUSE_SELECT_AN_ITEM_TO_SELL
--    "Available for purchase!", -- SI_HOUSING_BOOK_AVAILABLE_FOR_PURCHASE
--    "Quantity", -- SI_CRAFTING_QUANTITY_HEADER
--    "Quantity", -- SI_TRADING_HOUSE_POSTING_QUANTITY
--    "Quantity", -- SI_GAMEPAD_QUANTITY_SPINNER_TEMPLATE_LABEL
--    "Quantity", -- SI_TAMRIEL_TOMES_CURRENCY_REDEMPTION_QUANTITY_LABEL
--    "Quantity", -- SI_MARKET_CONFIRM_PURCHASE_QUANTITY_LABEL
--    "Their Offer", -- SI_GAMEPAD_TRADE_VIEW_THEIR_OFFER_KEYBIND
--    "My Offer", -- SI_GAMEPAD_TRADE_VIEW_MY_OFFER_KEYBIND
    "Cost", -- SI_REPAIR_SORT_TYPE_COST
    "Cost", -- SI_LAUNDER_SORT_TYPE_COST
    "Buy", -- SI_STORE_MODE_BUY
    "Sell", -- SI_STORE_MODE_SELL
    "Cost:", -- SI_KEYBOARD_SKILL_RESPEC_CONFIRM_DIALOG_COST_HEADER
    "Purchase", -- SI_SKILLS_PURCHASE_CONFIRM
    "Sell", -- SI_SKILLS_SELL_CONFIRM
    "Cost:", -- SI_RESTYLE_SHEET_APPLY_COST_LABEL
    "Cost:", -- SI_OUTFIT_CONFIRM_COMMIT_COST_HEADER_KEYBOARD
    "Cost:", -- SI_HOOK_POINT_STORE_COST
    "Purchase", -- SI_HOOK_POINT_STORE_PURCHASE
    "Cost:", -- SI_SELECT_HOME_CAMPAIGN_COST_LABEL
    "Cost", -- SI_GAMEPAD_SKILL_RESPEC_CONFIRM_DIALOG_COST_HEADER
    "Cost", -- SI_GAMEPAD_BUY_BAG_SPACE_COST
    "Cost:", -- SI_GUILD_HERALDRY_DIALOG_COST_HEADER
    "Cost", -- SI_RETRAIT_STATION_RETRAIT_COST_HEADER
    "Cost", -- SI_ITEM_RECONSTRUCTION_COST_HEADER
    "Total Cost", -- SI_ITEM_RECONSTRUCTION_TOTAL_COST
    "Cost:", -- SI_MARKET_CONFIRM_PURCHASE_COST_LABEL
    "Normal Cost:", -- SI_MARKET_CONFIRM_PURCHASE_NORMAL_COST_LABEL
    "Purchase", -- SI_MARKET_CONFIRM_PURCHASE_RECIPIENT_SELECTOR_HEADER
    "Cost", -- SI_ABILITY_TOOLTIP_RESOURCE_COST_LABEL
    "Bid", -- SI_GAMEPAD_GUILD_KIOSK_BID_AMOUNT_LABEL
    "Submit Bid", -- SI_GUILD_KIOSK_INITIAL_BID
    "Item", -- SI_TRADING_HOUSE_COLUMN_ITEM
    "Item", -- SI_CROWN_CRATE_REWARD_TYPE_ITEM
    "Item", -- SI_GAMEPAD_ACHIEVEMENTS_ITEM_LABEL
    "Item Furnishings", -- SI_HOUSINGFURNISHINGLIMITTYPE0

    "Store", -- SI_INTERACT_OPTION_STORE

    "Inventory", -- SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES1303
    "Inventory", -- SI_INVENTORY_MENU_INVENTORY
    "Inventory", -- SI_GAMEPAD_INVENTORY_CATEGORY_HEADER
    "Inventory", -- SI_MAIN_MENU_INVENTORY
    "Inventory", -- SI_BINDING_NAME_TOGGLE_INVENTORY
    "Inventory", -- SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_BACKPACK
    "Inventory", -- SI_HOUSINGFURNITURELOCATIONFILTER2
    "Inventory", -- SI_BAG1


    "Cannot craft this item", -- SI_TRADESKILLRESULT132
    "Add Item", -- SI_GAMEPAD_TRADE_ATTACH_ITEMS

	-- "Listings", -- SI_TRADING_HOUSE_MODE_LISTINGS
	-- "My Listings", -- SI_HOUSE_TOURS_MANAGE_LISTINGS
  -- "My Listing", -- SI_GROUP_FINDER_MY_GROUP_LISTING
	-- "Guild", -- SI_TRADING_HOUSE_GUILD_LABEL
	-- "Listing Fee", -- SI_TRADING_HOUSE_POSTING_LISTING_FEE
	-- "House Cut", -- SI_TRADING_HOUSE_POSTING_TH_CUT
	-- "Profit", -- SI_TRADING_HOUSE_POSTING_PROFIT
	-- "Furniture", -- SI_GENERIC_FURNITURE_TEXT
	-- "Store", -- SI_CROWN_STORE_MENU_CROWN_STORE_LABEL
	-- "Store", -- SI_GAMEPAD_GUILD_HUB_STORE_HEADER
	-- "Listed", -- SI_HOUSE_TOURS_MANAGE_LISTING_STATUS_LISTED
	-- "Listed", -- SI_SCREEN_NARRATION_LISTED_RESIDENCE_ICON_NARRATION
  -- "Not Listed", -- SI_HOUSE_TOURS_MANAGE_LISTING_STATUS_NOT_LISTED
	-- "Not Listed", -- SI_GUILDRECRUITMENTSTATUSATTRIBUTEVALUE0
	-- "Listed", -- SI_GUILDRECRUITMENTSTATUSATTRIBUTEVALUE1
  -- "Manage Listing", -- SI_HOUSE_TOURS_MANAGE_LISTING
  -- "Remove Listing", -- SI_HOUSE_TOURS_REMOVE_LISTING
  -- "Create Listing", -- SI_GAMEPAD_TRADING_HOUSE_CREATE_LISTING_TITLE
    "Furniture List", -- SI_HOUSING_FURNITURE_TAB_FURNITURE_LIST
    "Buy Item", -- SI_TRADING_HOUSE_BUY_ITEM
    "Buy Item", -- SI_TRADING_HOUSE_PURCHASE_ITEM_DIALOG_TITLE
    "List Item", -- SI_TRADING_HOUSE_POST_ITEM
    "Purchase", -- SI_GAMEPAD_TRADING_HOUSE_CONFIRM_BUY_DIALOG_TITLE
    "Purchase", -- SI_GUILD_HERALDRY_DIALOG_PURCHASE_TITLE
    "Buy", -- SI_TRADING_HOUSE_PURCHASE_ITEM_DIALOG_CONFIRM
    "Purchase", -- SI_PROMPT_TITLE_CONFIRM_PURCHASE
    "Purchase", -- SI_HOUSING_FURNITURE_TAB_PURCHASE
    "Purchase Options", -- SI_HOUSING_HUD_FRAGMENT_PURCHASE_KEYBIND
    "Purchase", -- SI_HOUSING_FURNITURE_BROWSER_PURCHASE_KEYBIND
    "Quantity", -- SI_MARKET_CONFIRM_PURCHASE_QUANTITY_LABEL
    "Price", -- SI_GAMEPAD_MARKET_BUNDLES_TOOLTIP_PRICE
    "Price", -- SI_TRADINGHOUSELISTINGSORTTYPE1
    "Price", -- SI_TRADINGHOUSEFEATURECATEGORY6
    "Price", -- SI_INVENTORY_SORT_TYPE_PRICE
    "Price", -- SI_STORE_SORT_TYPE_PRICE

--		"Guild Traders & Vendors", -- SI_MODBROWSERCATEGORYTYPE6

--    "Show Details", -- SI_QUEST_TRACKER_MENU_SHOW_IN_JOURNAL
--    "Show More", -- SI_GUILD_HISTORY_SHOW_MORE
--    "Show All", -- SI_GAMEPAD_GUILD_HISTORY_SUBCATEGORY_ALL
--    "Show Tooltip", -- SI_GAMEPAD_GIFT_INVENTORY_VIEW_WINDOW_SHOW_TOOLTIP_KEYBIND
--    "Hide Tooltip", -- SI_GAMEPAD_GIFT_INVENTORY_VIEW_WINDOW_HIDE_TOOLTIP_KEYBIND
--    "Show Details", -- SI_WORLD_MAP_FILTERS_SHOW_DETAILS
--    "Show Information", -- SI_WORLD_MAP_ACTION_SHOW_INFORMATION
--    "Hide Information", -- SI_WORLD_MAP_ACTION_HIDE_INFORMATION
--    "Show On Map", -- SI_QUEST_JOURNAL_SHOW_ON_MAP
--    "Show only the items that can be created based on what is available in inventory", -- SI_CRAFTING_HAVE_MATERIALS_TOOLTIP
--    "Show only the items that can be created based on learned knowledge", -- SI_CRAFTING_HAVE_KNOWLEDGE_TOOLTIP
 --   "Show only the items that can be used for the selected crafting quest", -- SI_CRAFTING_IS_QUEST_ITEM_TOOLTIP
 --   "Show only the items that can be created based on learned skills", -- SI_CRAFTING_HAVE_SKILLS_TOOLTIP
 --   "Show only the items that can be created based on ingredients available in inventory", -- SI_CRAFTING_HAVE_INGREDIENTS_TOOLTIP
--    "Show Summary", -- SI_ENDLESS_DUNGEON_BUFF_TRACKER_SWITCH_TO_SUMMARY_KEYBIND
--    "Show On Map", -- SI_ADVENTURE_ZONE_VIEW_SHOW_ON_MAP

--    "Show on map", -- SI_QUEST_SHOW_ON_MAP_BUTTON_TOOLTIP
--    "Show on map", -- SI_QUEST_TRACKER_MENU_SHOW_ON_MAP
--    "Show Details", -- SI_QUEST_TRACKER_MENU_SHOW_IN_JOURNAL
--    "Show Achievement", -- SI_COLLECTIBLE_ACTION_SHOW_ACHIEVEMENT
--    "Link In Chat", -- SI_GUILD_RECRUITMENT_LINK_IN_CHAT
--    "Link in Chat", -- SI_ITEM_ACTION_LINK_TO_CHAT
--    "Link Invite in Chat", -- SI_HOUSING_LINK_IN_CHAT
--    "Link Invite in Mail", -- SI_HOUSING_LINK_IN_MAIL




--* GetNumItemLinkPreviewVariations(*string* _itemLink_)
--** _Returns:_ *integer* _numVariations_


-- See universaldeconstructionpanel_gamepad.lua for filters and option dialogs

--     "Reset Search", -- SI_TRADING_HOUSE_RESET_SEARCH
--    "Search For Item", -- SI_TRADING_HOUSE_SEARCH_FROM_ITEM
--    "Search", -- SI_MARKET_SEARCH_EDIT_DEFAULT
--    "Filter By:", -- SI_MARKET_SEARCH_FILTER_BY_LABEL
--    "Search", -- SI_SCREEN_NARRATION_EDIT_BOX_SEARCH_NAME
--    "Clear", -- SI_CHAMPION_SYSTEM_CLEAR_POINTS
--    "No items found. Modify your search and try again.", -- SI_TRADINGHOUSESEARCHOUTCOME1
--    "There are no items that match both your filters and your item name text. Please modify your search and try again.", -- SI_TRADINGHOUSESEARCHOUTCOME2
--    "Cancel Search", -- SI_GROUP_WINDOW_CANCEL_SEARCH
--    "Start Search", -- SI_TRADING_HOUSE_DO_SEARCH
--    "Refine your search with additional filters.", -- SI_GROUP_FINDER_ADDITIONAL_FILTERS_TOOLTIP
--    "Refresh your current search.", -- SI_GROUP_FINDER_REFRESH_SEARCH_TOOLTIP
--    "Search", -- SI_GAMEPAD_HELP_SEARCH
--    "Search - <<1>>", -- SI_GAMEPAD_HELP_SEARCH_TITLE
--    "Enter Search Text", -- SI_GAMEPAD_HELP_SEARCH_PROMPT
--    "Reset Search", -- SI_TRADING_HOUSE_RESET_SEARCH
--    "Search For Item", -- SI_TRADING_HOUSE_SEARCH_FROM_ITEM
--    "No furnishings match the search.", -- SI_HOUSING_FURNITURE_NO_SEARCH_RESULTS
--    "No furnishings matching the search were found in: <<1>>.", -- SI_HOUSING_FURNITURE_NO_SEARCH_RESULTS_IN_CATEGORY
--    "Enter Search Text", -- SI_GAMEPAD_MARKET_SEARCH_PROMPT
--    "Sort", -- SI_GAMEPAD_SORT_OPTION
--    "Search", -- SI_GAMEPAD_BANK_SEARCH_DEFAULT_TEXT
--    "<<1>>", -- SI_GAMEPAD_BANK_FILTER_ENTRY_FORMATTER
--    "Filter / Sort (<<1>><<X:2>>)", -- SI_GAMEPAD_BANK_FILTER_KEYBIND
--    "Filter", -- SI_GAMEPAD_BANK_FILTER_HEADER
--    "Sort Type", -- SI_GAMEPAD_BANK_SORT_TYPE_HEADER
--    "Sort Order", -- SI_GAMEPAD_BANK_SORT_ORDER_HEADER
--    "Ascending / A-Z", -- SI_GAMEPAD_BANK_SORT_ORDER_UP_TEXT
--    "Descending / Z-A", -- SI_GAMEPAD_BANK_SORT_ORDER_DOWN_TEXT



function ZO_GamepadInventory:UpdateItemLeftTooltip(selectedData)
    if selectedData and not self:IsHeaderActive() then
        GAMEPAD_TOOLTIPS:ResetScrollTooltipToTop(GAMEPAD_RIGHT_TOOLTIP)
        if selectedData.filterData then
            if ZO_InventoryUtils_DoesNewItemMatchFilterType(selectedData, ITEMFILTERTYPE_QUEST) then
                if selectedData.toolIndex then
                    GAMEPAD_TOOLTIPS:LayoutQuestItem(GAMEPAD_LEFT_TOOLTIP, GetQuestToolQuestItemId(selectedData.questIndex, selectedData.toolIndex))
                else
                    GAMEPAD_TOOLTIPS:LayoutQuestItem(GAMEPAD_LEFT_TOOLTIP, GetQuestConditionQuestItemId(selectedData.questIndex, selectedData.stepIndex, selectedData.conditionIndex))
                end
            else
                GAMEPAD_TOOLTIPS:LayoutBagItem(GAMEPAD_LEFT_TOOLTIP, selectedData.bagId, selectedData.slotIndex, LAYOUT_BAG_ITEM_DEFAULT_SHOW_COMBINED_COUNT, LAYOUT_BAG_ITEM_EXTRA_DATA)
            end

            if selectedData.isEquippedInCurrentCategory or selectedData.isEquippedInAnotherCategory or selectedData.equipSlot then
                local slotIndex = selectedData.bagId == BAG_WORN and selectedData.slotIndex or nil --equipped quickslottables slotIndex is not the same as slot index's in BAG_WORN
                self:UpdateTooltipEquippedIndicatorText(GAMEPAD_LEFT_TOOLTIP, slotIndex)
            else
                GAMEPAD_TOOLTIPS:ClearStatusLabel(GAMEPAD_LEFT_TOOLTIP)
            end
        else
            GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_LEFT_TOOLTIP)
        end
    else
        GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_LEFT_TOOLTIP)
    end
end


function ZO_GamepadInventory:RefreshActiveItemList(selectDefaultEntry)
	local activeCategoryList
	local activeItemList
	local backingBag
	local currentCategoryType
	if self.currentListType == INVENTORY_ITEM_LIST or self.itemList:IsActive() then
		activeCategoryList = self.categoryList
		activeItemList = self.itemList
		backingBag = BAG_BACKPACK
		currentCategoryType = INVENTORY_CATEGORY_LIST
	elseif self.currentListType == INVENTORY_VENGEANCE_ITEM_LIST or self.vengeanceItemList:IsActive() then
		activeCategoryList = self.vengeanceCategoryList
		activeItemList = self.vengeanceItemList
		backingBag = BAG_VENGEANCE
		currentCategoryType = INVENTORY_VENGEANCE_CATEGORY_LIST
	end

	if activeItemList then
		-- Order matters:
		local targetCategoryData = activeCategoryList:GetTargetData()
		activeItemList:Clear()

		if activeCategoryList:IsEmpty() then
			return
		end

		local filteredEquipSlot = targetCategoryData.equipSlot
		local nonEquipableFilterType = targetCategoryData.filterType
		local filteredDataTable

		local isQuestItemFilter = nonEquipableFilterType == ITEMFILTERTYPE_QUEST
		--special case for quest items
		if isQuestItemFilter then
			filteredDataTable = {}
			local questCache = SHARED_INVENTORY:GenerateFullQuestCache()
			for _, questItems in pairs(questCache) do
				for _, questItem in pairs(questItems) do
					if self:GetQuestItemDataFilterComparator(questItem.questItemId) then
						table.insert(filteredDataTable, questItem)
						questItem.bestItemCategoryName = zo_strformat(SI_INVENTORY_HEADER, GetBestQuestItemCategoryDescription(questItem))
					end
				end
			end
			table.sort(filteredDataTable, ZO_GamepadInventory_QuestItemSortComparator)
		else
			local comparator = self:GetItemDataFilterComparator(filteredEquipSlot, nonEquipableFilterType)

			filteredDataTable = SHARED_INVENTORY:GenerateFullSlotData(comparator, backingBag, BAG_WORN)
			for _, itemData in pairs(filteredDataTable) do
				itemData.bestItemCategoryName = zo_strformat(SI_INVENTORY_HEADER, GetBestItemCategoryDescription(itemData))
			end
			table.sort(filteredDataTable, ZO_GamepadInventory_DefaultItemSortComparator)
		end

		local lastBestItemCategoryName
		for _, itemData in ipairs(filteredDataTable) do
			local entryData = ZO_GamepadEntryData:New(itemData.name, itemData.iconFile)
			entryData:InitializeInventoryVisualData(itemData)

			if itemData.bagId == BAG_WORN then
				entryData.isEquippedInCurrentCategory = itemData.slotIndex == filteredEquipSlot
				entryData.isEquippedInAnotherCategory = itemData.slotIndex ~= filteredEquipSlot

				entryData.isHiddenByWardrobe = WouldEquipmentBeHidden(itemData.slotIndex or EQUIP_SLOT_NONE, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
			elseif isQuestItemFilter then
				local slotIndex = FindActionSlotMatchingSimpleAction(ACTION_TYPE_QUEST_ITEM, itemData.questItemId, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
				entryData.isEquippedInCurrentCategory = slotIndex ~= nil
			else
				local slotIndex = FindActionSlotMatchingItem(itemData.bagId, itemData.slotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
				entryData.isEquippedInCurrentCategory = slotIndex ~= nil
			end

			local remaining, duration
			if isQuestItemFilter then
				if itemData.toolIndex then
					remaining, duration = GetQuestToolCooldownInfo(itemData.questIndex, itemData.toolIndex)
				elseif itemData.stepIndex and itemData.conditionIndex then
					remaining, duration = GetQuestItemCooldownInfo(itemData.questIndex, itemData.stepIndex, itemData.conditionIndex)
				end

				ZO_InventorySlot_SetType(entryData, SLOT_TYPE_QUEST_ITEM)
			else
				remaining, duration = GetItemCooldownInfo(itemData.bagId, itemData.slotIndex)

				ZO_InventorySlot_SetType(entryData, SLOT_TYPE_GAMEPAD_INVENTORY_ITEM)
			end
			if remaining > 0 and duration > 0 then
				entryData:SetCooldown(remaining, duration)
			end

			entryData:SetIgnoreTraitInformation(true)

			if IsCurrentCampaignVengeanceRuleset() and activeCategoryList == self.categoryList then
				entryData.enabled = not IsItemVisuallyDisabledInVengeance(itemData.bagId, itemData.slotIndex)
			end

			if itemData.bestItemCategoryName ~= lastBestItemCategoryName then
				lastBestItemCategoryName = itemData.bestItemCategoryName

				entryData:SetHeader(lastBestItemCategoryName)
				activeItemList:AddEntry("ZO_GamepadItemSubEntryTemplateWithHeader", entryData)
			else
				activeItemList:AddEntry("ZO_GamepadItemSubEntryTemplate", entryData)
			end

			entryData.narrationText = GetItemNarrationText
		end

		-- ESO-785986: ItemList keybinds depend on self.selectedItemFilterType
		-- which is set by CategoryList being updated when the ItemList is refreshed
		local DONT_SELECT_DEFAULT = nil
		local FORCE_UPDATE = true
		self:RefreshActiveCategoryList(DONT_SELECT_DEFAULT, FORCE_UPDATE)

		-- ESO-871103: Must refresh the category list first so that self.currentlySelectData
		-- remains data in itemList rather than being set to the selected data in category list
		activeItemList:Commit()
		self:UpdateItemLeftTooltip(self.currentlySelectedData)

		if not ZO_GamepadInventory.AreCategoryListEntriesEqual(targetCategoryData, activeCategoryList:GetTargetData()) then
			-- The category has changed; clear the item list and switch to the category list.
			activeItemList:Clear()
			local DO_NOT_SELECT_DEFAULT_ENTRY = false
			self:SwitchActiveList(currentCategoryType, DO_NOT_SELECT_DEFAULT_ENTRY)
		end
	end
end



function XMT_VaC_ListScreen_Gamepad:SetupList(list)
	list:AddDataTemplate("ZO_GamepadMenuEntryTemplate", ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction)
	list:AddDataTemplateWithHeader("ZO_GamepadMenuEntryTemplate", ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "ZO_GamepadMenuEntryHeaderTemplate")
	list:SetNoItemText(XMT_GetString(SI_GAMEPAD_INVENTORY_EMPTY))
end
]]