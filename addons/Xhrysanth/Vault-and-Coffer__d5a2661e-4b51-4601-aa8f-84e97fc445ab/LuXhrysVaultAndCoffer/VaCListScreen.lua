
--[[ Vault and Coffer ]]
--[[ ListScreen.lua ]]
--[[ LOAD ORDER THIRD ]]

--[[ ==========================> DECLARATIONS <=========================== ]]--


-- ========================= [ Dependency Check ] ========================== --


assert (LUXHRYS.VAC.METADATA.ADDON_MODULE_NAME == "VaultAndCoffer", "[LuXhrysVaCL] CRIT: LuXhrysVaCT not available. This chunk will not be loaded.")


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

local ADDON_CHUNK_NAME = "ListScreen"
local ADDON_CHUNK_SHORT_NAME = "L"
local ADDON_DEBUG_NAME = ADDON_SYSTEM_NAME .. ADDON_MODULE_SHORT_NAME .. ADDON_CHUNK_SHORT_NAME


-- ===================== [ Localize Global Functions ] ===================== --

-------------------------------------------------------------------------------
--| C functions |--------------------------------------------------------------
-------------------------------------------------------------------------------


local GetItemLink = GetItemLink
local GetItemLinkName = GetItemLinkName
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

--local IsConsoleUI = IsConsoleUI
--local IsInGamepadPreferredMode = IsInGamepadPreferredMode

--local GetNumTradingHouseListings = GetNumTradingHouseListings
--local GetNumMailItems = GetNumMailItems
--local HasUnreadMail = HasUnreadMail
--local GetMailItemInfo = GetMailItemInfo
--local GetNumBuybackItems = GetNumBuybackItems
--local GetNumHouseFurnishingsPlaced = GetNumHouseFurnishingsPlaced
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
--local HasUnlockedFurnitureVault = ZO_HousingEditorState.HasUnlockedFurnitureVault

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
--local GetGameTimeMilliseconds = GetGameTimeMilliseconds

local GetString = GetString
local GetTimeStamp = GetTimeStamp

local CanItemLinkBePreviewed = CanItemLinkBePreviewed
local IsCurrentlyPreviewing = IsCurrentlyPreviewing
local GetNumItemLinkPreviewVariations = GetNumItemLinkPreviewVariations
local ApplyChangesToPreviewCollectionShown = ApplyChangesToPreviewCollectionShown

local CreateControlFromVirtual = CreateControlFromVirtual
local IsCharacterPreviewingAvailable = IsCharacterPreviewingAvailable

local GetItemLinkFilterTypeInfo = GetItemLinkFilterTypeInfo
local GetItemLinkEquippedComparisonEquipSlots = GetItemLinkEquippedComparisonEquipSlots

local GetWornBagForGameplayActorCategory = GetWornBagForGameplayActorCategory
local GetItemLinkActorCategory = GetItemLinkActorCategory
local GetWornItemInfo = GetWornItemInfo


-------------------------------------------------------------------------------
--| Native Lua functions |-----------------------------------------------------
-------------------------------------------------------------------------------


--local ParseLink = ZO_LinkHandler_ParseLink
--local IconFormat = zo_iconFormat
--local TableInsert = table.insert
--local TableRemove = table.remove
--local StrFormat = string.format


-------------------------------------------------------------------------------
--| ZOS Lua functions |--------------------------------------------------------
-------------------------------------------------------------------------------


--local ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription = ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription

local ZO_TableOrderingFunction = ZO_TableOrderingFunction
local ZO_Scene = ZO_Scene
local ZO_SimpleSceneFragment = ZO_SimpleSceneFragment
local ZO_FadeSceneFragment = ZO_FadeSceneFragment
local ZO_Gamepad_ParametricList_Screen = ZO_Gamepad_ParametricList_Screen
local ZO_SharedGamepadEntry_OnSetup = ZO_SharedGamepadEntry_OnSetup
local ZO_GamepadMenuEntryTemplateParametricListFunction = ZO_GamepadMenuEntryTemplateParametricListFunction
local ZO_BackgroundFragment = ZO_BackgroundFragment

local ZO_Gamepad_AddBackNavigationKeybindDescriptors = ZO_Gamepad_AddBackNavigationKeybindDescriptors


local ZO_AppendNarration = ZO_AppendNarration
local ZO_GetSharedGamepadEntryDefaultNarrationText = ZO_GetSharedGamepadEntryDefaultNarrationText

local ZO_GamepadEntryData = ZO_GamepadEntryData

local ZO_GamepadGenericHeader_Activate = ZO_GamepadGenericHeader_Activate
local ZO_GamepadGenericHeader_Deactivate = ZO_GamepadGenericHeader_Deactivate
local ZO_GamepadGenericHeader_Refresh = ZO_GamepadGenericHeader_Refresh
local ZO_InventoryUtils_UpdateTooltipEquippedIndicatorText = ZO_InventoryUtils_UpdateTooltipEquippedIndicatorText

local ZO_Ingame_SavedVariables = ZO_Ingame_SavedVariables


-------------------------------------------------------------------------------
--| From LXICommon |-----------------------------------------------------------
-------------------------------------------------------------------------------


--local optionDefaults = LUXHRYS.optionDefaults
local OPTIONS
local Debug = LUXHRYS.Debug
--local Startup = LUXHRYS.Startup
--local Async = LUXHRYS.Async
--local StrUtils = LUXHRYS.StrUtils
--local Alerts = LUXHRYS.Alerts
--local STATE = LUXHRYS.STATE
local Bag = LUXHRYS.Bag
local Location = LUXHRYS.Location
--local LinkUtils = LUXHRYS.LinkUtils
--local ItemKey = LUXHRYS.ItemKey
local ItemInfo = LUXHRYS.ItemInfo
--local icons = LUXHRYS.icons
local COLORS


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


local DBLOOKUP


-------------------------------------------------------------------------------
--| From VaCTooltips |---------------------------------------------------------
-------------------------------------------------------------------------------


local TOOLTIPS_GAMEPAD


--[[ ============================> FUNCTIONS <============================ ]]--


-- ======== [ Vault and Coffer ListScreenGamepad Utility Functions ] ======= --


-------------------------------------------------------------------------------
--| Sorting Descriptors and Functions |----------------------------------------
-------------------------------------------------------------------------------


local SORT_BY_CATEGORY =
{
    bestItemCategoryName = { tiebreaker = "name" },
    displayQuality = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    stackCount = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    sellPrice = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    name = { tiebreaker = "requiredLevel" },
    requiredLevel = { tiebreaker = "requiredChampionPoints", isNumeric = true },
    requiredChampionPoints = { tiebreaker = "iconFile", isNumeric = true },
    iconFile = { tieBreakerSortOrder = ZO_SORT_ORDER_UP },
		uniqueId = { tieBreakerSortOrder = ZO_SORT_ORDER_UP }
}

local SORT_BY_FURNISHING_CATEGORY =
{
    bestItemFurnishingCategoryName = { tiebreaker = "name" },
    displayQuality = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    stackCount = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    sellPrice = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    name = { tiebreaker = "requiredLevel" },
    iconFile = { tieBreakerSortOrder = ZO_SORT_ORDER_UP },
		uniqueId = { tieBreakerSortOrder = ZO_SORT_ORDER_UP }
}

local SORT_BY_NAME =
{
    name = { tiebreaker = "requiredLevel" },
    requiredLevel = { tiebreaker = "requiredChampionPoints", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    requiredChampionPoints = { tiebreaker = "iconFile", isNumeric = true },
    displayQuality = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    stackCount = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    sellPrice = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    iconFile = { tieBreakerSortOrder = ZO_SORT_ORDER_UP }
}

local SORT_BY_QUANTITY =
{
    stackCount = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    name = { tiebreaker = "requiredLevel" },
    displayQuality = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    sellPrice = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    requiredLevel = { tiebreaker = "requiredChampionPoints", isNumeric = true },
    requiredChampionPoints = { tiebreaker = "iconFile", isNumeric = true },
    iconFile = { tieBreakerSortOrder = ZO_SORT_ORDER_UP }
}

local SORT_BY_LEVEL =
{
    requiredLevel = { tiebreaker = "requiredChampionPoints", isNumeric = true },
    name = { tiebreaker = "requiredLevel" },
    displayQuality = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    stackCount = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    sellPrice = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    requiredChampionPoints = { tiebreaker = "iconFile", isNumeric = true },
    iconFile = { tieBreakerSortOrder = ZO_SORT_ORDER_UP }
}

local SORT_BY_CP =
{
    requiredChampionPoints = { tiebreaker = "iconFile", isNumeric = true },
    displayQuality = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    stackCount = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    sellPrice = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    name = { tiebreaker = "requiredLevel" },
    requiredLevel = { tiebreaker = "requiredChampionPoints", isNumeric = true },
    iconFile = { tieBreakerSortOrder = ZO_SORT_ORDER_UP }
}

local SORT_BY_QUALITY =
{
    displayQuality = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    name = { tiebreaker = "requiredLevel" },
    stackCount = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    sellPrice = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    requiredLevel = { tiebreaker = "requiredChampionPoints", isNumeric = true },
    requiredChampionPoints = { tiebreaker = "iconFile", isNumeric = true },
    iconFile = { tieBreakerSortOrder = ZO_SORT_ORDER_UP }
}

local SORT_BY_SELL_PRICE =
{
    sellPrice = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    stackCount = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    name = { tiebreaker = "requiredLevel" },
    displayQuality = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    requiredLevel = { tiebreaker = "requiredChampionPoints", isNumeric = true },
    requiredChampionPoints = { tiebreaker = "iconFile", isNumeric = true },
    iconFile = { tieBreakerSortOrder = ZO_SORT_ORDER_UP }
}

local SORT_BY_MARKET_PRICE =
{
    bestItemCategoryName = { tiebreaker = "name" },
    displayQuality = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    stackCount = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    sellPrice = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    name = { tiebreaker = "requiredLevel" },
    requiredLevel = { tiebreaker = "requiredChampionPoints", isNumeric = true },
    requiredChampionPoints = { tiebreaker = "iconFile", isNumeric = true },
    iconFile = { tieBreakerSortOrder = ZO_SORT_ORDER_UP }
}

local SORT_BY_CRAFTING_COST =
{
    bestItemCategoryName = { tiebreaker = "name" },
    displayQuality = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    stackCount = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    sellPrice = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    name = { tiebreaker = "requiredLevel" },
    requiredLevel = { tiebreaker = "requiredChampionPoints", isNumeric = true },
    requiredChampionPoints = { tiebreaker = "iconFile", isNumeric = true },
    iconFile = { tieBreakerSortOrder = ZO_SORT_ORDER_UP }
}

local SORT_BY_PURCHASE_PRICE_GOLD =
{
    displayQuality = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    stackCount = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    sellPrice = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    name = { tiebreaker = "requiredLevel" },
    requiredLevel = { tiebreaker = "requiredChampionPoints", isNumeric = true },
    requiredChampionPoints = { tiebreaker = "iconFile", isNumeric = true },
    iconFile = { tieBreakerSortOrder = ZO_SORT_ORDER_UP }
}

local SORT_BY_TRAIT =
{
    displayQuality = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    stackCount = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    sellPrice = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    name = { tiebreaker = "requiredLevel" },
    requiredLevel = { tiebreaker = "requiredChampionPoints", isNumeric = true },
    requiredChampionPoints = { tiebreaker = "iconFile", isNumeric = true },
    iconFile = { tieBreakerSortOrder = ZO_SORT_ORDER_UP }
}

local SORT_BY_EXPIRATION =
{
    displayQuality = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    stackCount = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    sellPrice = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    name = { tiebreaker = "requiredLevel" },
    requiredLevel = { tiebreaker = "requiredChampionPoints", isNumeric = true },
    requiredChampionPoints = { tiebreaker = "iconFile", isNumeric = true },
    iconFile = { tieBreakerSortOrder = ZO_SORT_ORDER_UP }
}

--local SORT_CUSTOM = OPTIONS.VaC.listScreenCustomSortOrder -- TODO: Not sure it's worth keeping this.


local SORT_DEFAULT = SORT_BY_CATEGORY


local function LuXhrys_VaC_DefaultItemSortComparator (left, right)
    return ZO_TableOrderingFunction(left, right, "bestItemCategoryName", SORT_DEFAULT, ZO_SORT_ORDER_UP)
end

local function LuXhrys_VaC_DefaultFurnishingItemSortComparator (left, right)
    return ZO_TableOrderingFunction(left, right, "bestItemFurnishingCategoryName", SORT_BY_FURNISHING_CATEGORY, ZO_SORT_ORDER_UP)
end


-------------------------------------------------------------------------------
--| Previewing Functions |-----------------------------------------------------
-------------------------------------------------------------------------------


local function IsPreviewing ()

	if IsCurrentlyPreviewing () then
		return true
	end

	if ITEM_PREVIEW_GAMEPAD and ITEM_PREVIEW_GAMEPAD:IsInteractionCameraPreviewEnabled () then
		return true
	end

	return false

end


local function CanEntryDataBePreviewed (entryData)

--	DebugMsg (1, "CEDBP: Called.") -- entryData? %s. itemLink? %s.", not entryData and "No" or "Yes", not entryData.itemLink and "No" or "Yes")

	if not entryData then
--		DebugMsg (1, "CEDBP: No entryData. Exiting early and returning false.")
		return false
	end

	if entryData and entryData.itemLink then
		if GetItemLinkActorCategory (entryData.itemLink) == GAMEPLAY_ACTOR_CATEGORY_COMPANION then

--			DebugMsg (1, "CEDBP: Returning false because item is companion gear.")

			return false
		end
--		DebugMsg (1, "CEDBP: Can item %s be previewed? %s.", entryData.itemLink, CanItemLinkBePreviewed (entryData.itemLink) and "Yes" or "No")

		return CanItemLinkBePreviewed (entryData.itemLink)
	end

--	DebugMsg (1, "CEDBP: Exiting and returning false.") -- Can item %s be previewed? %s.", entryData.itemLink, CanItemLinkBePreviewed (entryData.itemLink) and "Yes" or "No")

	return false
end


-------------------------------------------------------------------------------
--| Comparison Mode Functions |------------------------------------------------
-------------------------------------------------------------------------------


local function IsComparisonModeEnabled (itemLink)
--	Debug.Msg (1, ADDON_DEBUG_NAME, "ICME", "Called. Item link is %s.", tostring (filterType))
	local filterType = GetItemLinkFilterTypeInfo (itemLink)
--	Debug.Msg (1, ADDON_DEBUG_NAME, "ICME", "Called. Item filter type is %s.", tostring (filterType))
	return filterType == ITEMFILTERTYPE_JEWELRY or filterType == ITEMFILTERTYPE_ARMOR or filterType == ITEMFILTERTYPE_WEAPONS
end


-------------------------------------------------------------------------------
--| Miscellaneous Functions |--------------------------------------------------
-------------------------------------------------------------------------------


local function GetEquipSlotFromItemLink (itemLink)

--	Debug.Msg (1, ADDON_DEBUG_NAME, "GESFIL", "Called.")

	if not itemLink or type (itemLink) ~= "string" then
		Debug.Msg (1, ADDON_DEBUG_NAME, "GESFIL", "Mismatch on type check. Returning early.")
		return nil
	end

	local equipSlot1, equipSlot2 = GetItemLinkEquippedComparisonEquipSlots (itemLink)

--	Debug.Msg (1, ADDON_DEBUG_NAME, "GESFIL", "ES1: %d. ES2: %d.", equipSlot1, equipSlot2)

	if equipSlot1 ~= EQUIP_SLOT_NONE then
--		Debug.Msg (1, ADDON_DEBUG_NAME, "GESFIL", "Completed. ES1: %s.", tostring (equipSlot1))
		return equipSlot1
	end

	-- For jewelry, I presume? Possibly for main/off hand, but not sure. It's there, so I'll use it.

	if equipSlot2 ~= EQUIP_SLOT_NONE then
--		Debug.Msg (1, ADDON_DEBUG_NAME, "GESFIL", "Completed. ES2: %s.", tostring (equipSlot2))
		return equipSlot2
	end

	return nil

end


-------------------------------------------------------------------------------
--| Main Menu Entry |----------------------------------------------------------
-------------------------------------------------------------------------------


-- Adapted from CreateEntry in esoui/ingame/mainmenu/gamepad/zo_mainmenu_gamepad.lua.

local function CreateMenuEntry (id, data)
	local name = data.name
	if type (name) == "function" then
		name = "" --will be updated whenever the list is generated
	end

	local entry = ZO_GamepadEntryData:New (name, data.icon, nil, nil, data.isNewCallback)
	entry:SetIconTintOnSelection (true)
	entry:SetIconDisabledTintOnSelection (true)

	local header = data.header
	if header then
		entry:SetHeader (header)
	end

--	entry.canLevel = data.canLevel -- Probably will never need this?
	entry.narrationText = data.narrationText
	entry.subLabelsNarrationText = data.subLabelsNarrationText

	if data.subMenu then
		entry.subMenu = {}
		for submenuEntryId, subMenuData in ipairs (data.subMenu) do
--			table.insert(entry.subMenu, CreateMenuEntry(submenuEntryId, subMenuData))
			entry.subMenu[#entry.subMenu + 1] = CreateMenuEntry (submenuEntryId, subMenuData)
		end
	end

	entry.data = data
	entry.id = id

	return entry

end


local GAMEPAD_VAULT_AND_COFFER_SCENE_NAME = "LuXhrys_VaC_VaultAndCoffer_ListScreen"


local function CreateMainMenuEntry ()

	-- Where do we insert our extended inventory menu?

	local menuPosition = 0

	for index = 1, #ZO_MENU_ENTRIES do
		if ZO_MENU_ENTRIES[index].id == ZO_MENU_MAIN_ENTRIES.INVENTORY then
			menuPosition = index
			break
		end
	end

	Debug.Msg (3, ADDON_DEBUG_NAME, "CMME", "menuPosition is %d.", menuPosition)


	if menuPosition == 0 then return end


	-- Define and insert our menu entry.

	local LYXHRYS_VAULT_AND_COFFER_MAIN_MENU_ENTRY_DATA =
	{
		scene = GAMEPAD_VAULT_AND_COFFER_SCENE_NAME,
--		customTemplate = "ZO_GamepadMenuEntryTemplate",
		name = "INVENTORY+",
		icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_inventory.dds",
		narrationText = SCREEN_NARRATION_MANAGER:CreateNarratableObject ("Inventory Plus"),
--		overrideNameColors = function () return GetCurrentTextRGBAValues (), GetCurrentTextRGBAValues (LUXHRYS.TINT_MODE_DIM) end,
		overrideNameColors = function () return COLORS:GetCurrentTint ("TEXT"), COLORS:GetCurrentTint ("TEXTDARK") end,
--		overrideIconTintColors = function () return GetCurrentIconRGBAValues (), GetCurrentIconRGBAValues (LUXHRYS.TINT_MODE_DIM) end
		overrideIconTintColors = function () return COLORS:GetCurrentTint ("ICON"), COLORS:GetCurrentTint ("ICONDARK") end,
	}

-- See function NewMenuEntrySetup(control, data, selected, reselectingDuringRebuild, enabled, active) in esoui/ingame/mainmenu/gamepad/zo_mainmenu_gamepad.lua for tinting procedure.


	Debug.Msg (3, ADDON_DEBUG_NAME, "CMME", "Inserting menu item.")


	table.insert (ZO_MENU_ENTRIES, menuPosition + 1, CreateMenuEntry ("LuXhrysVaultAndCoffer", LYXHRYS_VAULT_AND_COFFER_MAIN_MENU_ENTRY_DATA))

	Debug.Msg (2, ADDON_DEBUG_NAME, "CMME", "Refreshing main menu list.")


	MAIN_MENU_GAMEPAD:RefreshMainList ()

end


-- ================ [ Vault and Coffer ListScreenGamepad ] ================= --


local ListScreenGamepad = ZO_Gamepad_ParametricList_Screen:Subclass ()


-------------------------------------------------------------------------------
-- | Preview Functions |-------------------------------------------------------
-------------------------------------------------------------------------------


-- True for hide, false for unhide.

function ListScreenGamepad:GetSceneFragment (fragment)
	for index = 1, #self.scene.fragments do
		if self.scene.fragments[index] == fragment then
			return self.scene.fragments[index]
		end
	end
	return nil
end


function ListScreenGamepad:ItemLinkPreview (itemLink)

	ITEM_PREVIEW_GAMEPAD:ClearPreviewCollection ()

	local numVariations = GetNumItemLinkPreviewVariations (itemLink)

	Debug.Msg (4, ADDON_DEBUG_NAME, "LSG_ILP", "%s variations of %s to preview.", numVariations, itemLink)

	if self.scene:HasFragment (FRAME_TARGET_BLUR_GAMEPAD_FRAGMENT) then
--		self:GetSceneFragment (FRAME_TARGET_BLUR_GAMEPAD_FRAGMENT):Hide ()
		FRAME_TARGET_BLUR_GAMEPAD_FRAGMENT:Hide ()
	end

	if self.infoPanel and not self.infoPanel:IsHidden () then
		self.playerWasViewingInfoPanel = true
		self.infoPanel:SetHidden (true)
		self.infoPanelBackgroundFragment:Hide ()
	end

	ITEM_PREVIEW_GAMEPAD:PreviewItemLink (itemLink, 1)

end


function ListScreenGamepad:EndPreview ()

	if self.scene:HasFragment (FRAME_TARGET_BLUR_GAMEPAD_FRAGMENT) then
--		self:GetSceneFragment (FRAME_TARGET_BLUR_GAMEPAD_FRAGMENT):Show ()
		FRAME_TARGET_BLUR_GAMEPAD_FRAGMENT:Show ()
	end

	ITEM_PREVIEW_GAMEPAD:EndCurrentPreview ()

	ApplyChangesToPreviewCollectionShown ()

	if self.playerWasViewingInfoPanel then
		self.playerWasViewingInfoPanel = false
		self.infoPanel:SetHidden (false)
		self.infoPanelBackgroundFragment:Show ()
	end
end


-------------------------------------------------------------------------------
-- | Comparison Mode Functions |-----------------------------------------------
-------------------------------------------------------------------------------


local GI_SavedVars = ZO_Ingame_SavedVariables.Default["@Xhrysanth"]["$AccountWide"].GamepadInventory

function ListScreenGamepad:ChangeComparisonMode (itemLink)
--	local itemLink = self.list:GetTargetData ().itemLink
	if IsComparisonModeEnabled (itemLink) then
		GI_SavedVars.useStatComparisonTooltip = not GI_SavedVars.useStatComparisonTooltip
		self:UpdateTooltips (itemLink, GAMEPAD_RIGHT_TOOLTIP)
		--Re-narrate when the stat comparison tooltip is toggled
		SCREEN_NARRATION_MANAGER:QueueParametricListEntry (self.list)
	end
end


-------------------------------------------------------------------------------
-- | Initialization Functions |------------------------------------------------
-------------------------------------------------------------------------------


-- This is called by New, which is called by XML control through the instantiator at the end of this chunk.

function ListScreenGamepad:Initialize (control)

	Debug.Msg (2, ADDON_DEBUG_NAME, "LSG_I", "Called.")

	-- Create the scene.

	self.scene = ZO_Scene:New (GAMEPAD_VAULT_AND_COFFER_SCENE_NAME, SCENE_MANAGER)

	-- Add fragments.

	self.fragment = ZO_SimpleSceneFragment:New (LuXhrys_VaultAndCoffer_GamepadInventoryTopLevel)
--	self.fragment = ZO_SimpleSceneFragment:New (control)
	self.fragment:SetHideOnSceneHidden (true)

	self.scene:AddFragmentGroup (FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
	self.scene:AddFragmentGroup (FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
--	self.scene:AddFragmentGroup ({ FRAME_TARGET_GAMEPAD_FRAGMENT, FRAME_PLAYER_FRAGMENT })
	-- The preview options fragment needs to be added before the ITEM_PREVIEW_GAMEPAD fragment
	self.scene:AddFragment (GAMEPAD_NAV_QUADRANT_2_3_4_ITEM_PREVIEW_OPTIONS_FRAGMENT)
	self.scene:AddFragment (self.fragment)
	self.scene:AddFragment (FRAME_EMOTE_FRAGMENT_INVENTORY)
	self.scene:AddFragment (GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
	self.scene:AddFragment (MINIMIZE_CHAT_FRAGMENT)
	self.scene:AddFragment (GAMEPAD_MENU_SOUND_FRAGMENT)
	self.scene:AddFragment (ITEM_PREVIEW_GAMEPAD:GetFragment ())

	self.controlFragment = ZO_FadeSceneFragment:New (control)
	self.scene:AddFragment (self.controlFragment)

	-- Initialize the inventory list.

	ZO_Gamepad_ParametricList_Screen.Initialize (self, control, ZO_GAMEPAD_HEADER_TABBAR_CREATE, true, self.scene)

--	/script d (XMenuTest.EXTENDED_INVENTORY.list == XMenuTest.EXTENDED_INVENTORY.referenceList)

	-- This is our dynamic list, which will be generated for each tab on demand. While we could use the reference list for the first tab, filtering and sorting will be implemented later which would require modifying that list. If the user wants to look at the entire list, we can simply copy it to the dynamic list and add the entryData.
--	Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_I", "currentList exists? %s Main list exists? %s currentList is Main list? %s",
--		self:GetCurrentList () == nil and "No" or "Yes",
--		self:GetMainList () == nil and "No" or "Yes",
--		tostring ((self:GetMainList () or false) == (self:GetCurrentList () or true)))

--d (self:GetMainList ())
--d (self:GetCurrentList ())

	self.list = self:GetMainList ()
	self.list:SetNoItemText (GetString(SI_GAMEPAD_INVENTORY_EMPTY))
--	self:SetCurrentList (self.list)


	-- This is our master list, which will contain the entire inventory.

	self.referenceList = {}
	self.lastReferenceUpdate = 0
	self.referenceListAvailable = false

--	Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_I", "currentList exists? %s Main list exists? %s currentList is Main list? %s", self:GetCurrentList () == nil and "No" or "Yes", self:GetMainList () == nil and "No" or "Yes", tostring ((self:GetMainList () or false) == (self:GetCurrentList () or true)))

	-- Keybinds are initialized by the parent class using the InitializeKeybindStripDescriptors function below.

	-- ZOS: Generate the trigger keybinds so we can add/remove them later when necessary.
	-- These are used for jumping to the next or previous category header in the body of the list.
	-- These should be added by list Initialize->SetCurrentList->EnableCurrentList->ActivateCurrentList

	self:SetListsUseTriggerKeybinds (true)


	self.list:AddDataTemplate ("ZO_GamepadMenuEntryTemplate", ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction)

	self.list:AddDataTemplateWithHeader ("ZO_GamepadMenuEntryTemplate", ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "ZO_GamepadMenuEntryHeaderTemplate")


	self.playerWasViewingInfoPanel = false
--[[
	-- Set up "More Info" panel.

	-- TODO: Make this panel optional.
	-- TODO: Make this panel switch if scale/resolution changes.


	-- First, get screen resolution.

	local infoPanelContainerTemplate
	local guiRight = select (3, GuiRoot:GetScreenRect ())

-- 1920, 2017, 2065, 2371 (each value on the high end of the UI options scaling slider for 1920x1080 resolution)

	-- Choose panel size based on screen resolution/scaling.

	if guiRight < 2066 then
		infoPanelContainerTemplate = "LuXhrys_VaultAndCoffer_InfoPanel_Quadrant4InfoPanelContainer_Template_Gamepad"
		self.infoPanelBackgroundFragment = GAMEPAD_NAV_QUADRANT_4_BACKGROUND_FRAGMENT
	elseif guiRight < 2370 then
		infoPanelContainerTemplate = "LuXhrys_VaultAndCoffer_InfoPanel_Quadrant3InfoPanelContainer_Template_Gamepad"
		self.infoPanelBackgroundFragment = ZO_FadeSceneFragment:New (LuXhrys_VaultAndCoffer_TopLevel_Gamepad_Quadrant_3_Background)
		ZO_BackgroundFragment:Mixin (self.infoPanelBackgroundFragment)
	else
		infoPanelContainerTemplate = "LuXhrys_VaultAndCoffer_InfoPanel_Quadrant3WideInfoPanelContainer_Template_Gamepad"
		self.infoPanelBackgroundFragment = ZO_FadeSceneFragment:New (LuXhrys_VaultAndCoffer_TopLevel_Gamepad_Quadrant_3_Wide_Background)
		ZO_BackgroundFragment:Mixin (self.infoPanelBackgroundFragment)
	end

	self.scene:AddFragment (self.infoPanelBackgroundFragment)


	-- The InfoPanel is initialized by when created.

	self.infoPanelContainer = CreateControlFromVirtual ("InfoPanelContainer", self.control, infoPanelContainerTemplate)
	self.infoPanelFragment = self.infoPanel.fragment
	self.scene:AddFragment (self.infoPanelFragment)
]]

	-- Add the scene to the main menu.

--	CreateMainMenuEntry ()


	-- Remove from global access.
-- LUXHRYS.VaC_ListScreen_Gamepad_OnInitialize = nil


	Debug.Msg (2, ADDON_DEBUG_NAME, "LSG_I", "Completed.")

end -- ListScreenGamepad:Initialize


function ListScreenGamepad:OnDeferredInitialize ()

	Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_ODI", "Called.")



	-- ZO_Gamepad_ParametricList_Screen:Initialize () creates the header for us, but we still
	-- need to set up the tab bar and initialize the bag location filters to be used for each position on
	-- the tab bar. We can't initialize tabs until options are loaded, which isn't until the loading event fires.

	self.tabBarEntries = self:InitializeTabBar ()
	self:InitializeHeader ()
	self:InitializeTextSearch ()



--	self.list:SetSoundEnabled(true)


--	self.list:SetReselectBehavior (ZO_PARAMETRIC_SCROLL_LIST_RESELECT_BEHAVIOR.MATCH_OR_RESET_TO_DEFAULT)


--	Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_ODI", "currentList exists? %s Main list exists? %s currentList is Main list? %s", self:GetCurrentList () == nil and "No" or "Yes", LUXHRYS.EXTENDED_INVENTORY:GetMainList () == nil and "No" or "Yes", tostring ((LUXHRYS.EXTENDED_INVENTORY:GetMainList () or false) == (LUXHRYS.EXTENDED_INVENTORY:GetCurrentList () or true)))
	Debug.Msg (4, ADDON_DEBUG_NAME, "LSG_ODI", "currentList exists? %s Main list exists? %s currentList is Main list? %s", self:GetCurrentList () == nil and "No" or "Yes", self:GetMainList () == nil and "No" or "Yes", tostring ((self:GetMainList () or false) == (self:GetCurrentList () or true)))

	-- Initialize the additional filters that players can choose to apply to the list.

-- TODO: This is a big project getting all the categories and dropdowns figured out.
--	self:InitializeAdditionalFilters ()


	-- We don't expect the list to change during viewing since the user cannot act on the items. The mail
	-- inbox is probably the only exception, and we could probably implement that pretty easily. The same
	-- should largely apply to currency; only AP or Tel Var are probably able to change without the user
	-- taking some action (lagging rewards or death, respectively). Showing the currency wasn't really in
	-- the plan, but it could be helpful to have it as a reference when viewing pricing for items on
	-- tooltips.

--[[
	local function RefreshCurrencies()
		if not self.control:IsHidden() then
			self:RefreshHeader(BLOCK_TABBAR_CALLBACK)
			--Refresh the currency tooltip if it is open.
			if self.currentlySelectedData.isCurrencyEntry then
				self:UpdateCategoryLeftTooltip(self.currentlySelectedData)
				self:UpdateRightTooltip()
			end
		end
	end

	self.control:RegisterForEvent(EVENT_CURRENCY_UPDATE, RefreshCurrencies)
	self.control:RegisterForEvent(EVENT_CURRENCY_CAPS_CHANGED, RefreshCurrencies)
]]
--[[
	local function RefreshSelectedData()
		if not self.control:IsHidden() and self:GetCurrentList() and self:GetCurrentList():IsActive() then
			self:SetSelectedInventoryData(self.currentlySelectedData)
		end
	end

	self.control:RegisterForEvent(EVENT_PLAYER_DEAD, RefreshSelectedData)
	self.control:RegisterForEvent(EVENT_PLAYER_REINCARNATED, RefreshSelectedData)


	self.onRefreshActionsCallback = function()
		if self.itemList and self.itemList:IsActive() then
			SCREEN_NARRATION_MANAGER:QueueParametricListEntry(self.itemList)
		end
	end
]]

	self:Update ()

	Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_ODI", "Completed.")

end -- ListScreenGamepad:OnDeferredInitialize



-- ZOS: A function, which must be overridden in a sub-class, which should setup a keybind descriptor table and assign it to self.keybindStripDescriptor.

function ListScreenGamepad:InitializeKeybindStripDescriptors ()

	Debug.Msg (2, ADDON_DEBUG_NAME, "LSG_IKSD", "Called.")

--[[ Why does this exist?
	local function GetActiveTargetData ()
		return self.list:GetTargetData ()
	end
]]

	local function PreviewVisibilityFunction ()
--		Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_IKSD_PVF", "Called.")
		if not IsPreviewing () then
--			Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_IKSD_PVF", "Not currently previewing. Is previewing available? %s.", IsCharacterPreviewingAvailable () and "Yes" or "No")
--			local activeTargetData = self.list:GetTargetData ()
			return CanEntryDataBePreviewed (self.activeTargetData) and IsCharacterPreviewingAvailable ()
		end
		return true
	end

	local function PreviewCallbackFunction ()
--		Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_IKSD_PCF", "Called.")
		if IsPreviewing () then
			self:EndPreview ()
		else
--					local currentItemList = self:GetCurrentList()
--			local activeTargetData = self.list:GetTargetData ()
			if self.activeTargetData and self.activeTargetData.itemLink then
				if self.infoPanel and self.infoPanelGridList:IsActive () then -- this keybind strip should be disabled when in the gridList, but check to make sure.
					self.infoPanel:ExitGridList ()
				end
				self:ItemLinkPreview (self.activeTargetData.itemLink)
			end
		end
		self:RefreshKeybinds ()
		SCREEN_NARRATION_MANAGER:QueueParametricListEntry (self.list)
	end

	local function ComparisonVisibilityFunction ()
--		Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_IKSD_CVF", "Called.") -- TargetData exists? %s.", self.list:GetTargetData () and "Yes" or "No")
	--				local obj = _self
	--				local list = obj.list
	--				local td = list.GetTargetData (obj) or "None"

	--				local targetData =
--		local activeTargetData = self.list:GetTargetData ()
		if not self.activeTargetData then
			Debug.Msg (4, ADDON_DEBUG_NAME, "LSG_IKSD_CVF", "activeTargetData is not defined. Exiting early and returning false.")
--assert (false)
			return false
		end
		if not self.activeTargetData.itemLink then
			Debug.Msg (4, ADDON_DEBUG_NAME, "LSG_IKSD_CVF", "itemLink is not defined. Exiting early and returning false.")
			return false
		end

--		Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_IKSD_CVF", "itemLink is defined. Proceeding.")

		if IsComparisonModeEnabled (self.activeTargetData.itemLink) then
			local equipSlot = GetEquipSlotFromItemLink (self.activeTargetData.itemLink)
			local wornBag = GetWornBagForGameplayActorCategory (GetItemLinkActorCategory (self.activeTargetData.itemLink))
			return GetWornItemInfo (wornBag, equipSlot)
		end
		return false
	end

	local function ComparisonCallbackFunction ()
--		local activeTargetData = self.list:GetTargetData ()
--		if IsComparisonModeEnabled (self.activeTargetData.itemLink) then
			self:ChangeComparisonMode (self.activeTargetData.itemLink)
--		end
	end


-- /script d (GAMEPAD_INVENTORY.savedVars.useStatComparisonTooltip)


--[[ TODO: Consider this!
	visible = function() return self.itemList:GetNumItems() > 0 end
]]

-- sort, categorize, search, link in chat, item list

-- X button (Primary): Show expanded tooltip?
-- Circle (Negative): Back
-- Square (Secondary): Preview
-- Triangle (Tertiary): Open filter/sort options?
-- Square hold (Quaternary): Search for this item.
-- Triangle hold (Quinary): Link in chat
-- L3
-- R3: Reset search

	self.keybindStripDescriptor = {
		alignment = KEYBIND_STRIP_ALIGN_LEFT,
		{ -- Show detailed tooltip?
--				name = GetString(SI_NOTIFICATIONS_MORE_INFO), -- "More Info" -- SI_GUILD_HISTORY_SHOW_MORE), -- "Show More"
--				name = GetString(SI_STATS_MUNDUS_INFO_BUTTON), -- "View More Info" -- SI_GUILD_HISTORY_SHOW_MORE), -- "Show More"
			name = GetString(SI_QUEST_TRACKER_MENU_SHOW_IN_JOURNAL), -- "Show Details" -- SI_GUILD_HISTORY_SHOW_MORE), -- "Show More"
			keybind = "UI_SHORTCUT_PRIMARY", -- X
			order = -500,
			enabled = function ()
				return not IsPreviewing ()
			end,
			callback = function ()
				self:DeactivateMainList ()
				if self.infoPanel then
					self.infoPanel:EnterGridList ()
				end
			end
		},
		KEYBIND_STRIP:GetDefaultGamepadBackButtonDescriptor (), -- Circle - Back
		{
			disabledDuringSceneHiding = true,
			name = function()
				if IsPreviewing () then
					return GetString(SI_PREVIEW_CLEAR_INVENTORY_PREVIEW) -- end preview
				else
					return GetString(SI_CRAFTING_ENTER_PREVIEW_MODE) -- preview
				end
			end,
			keybind = "UI_SHORTCUT_SECONDARY", -- Square
			order = 3000,
--			callback = function()
--			end,
			enabled = function ()
				return LUXHRYS.LIP ~= nil and OPTIONS.VaC.previewingEnabled == true
			end,
			visible = PreviewVisibilityFunction,
			callback = PreviewCallbackFunction
		},
		{ -- Bring up sort/filter dialog.
			name = GetString (SI_GAMEPAD_SORT_OPTION) .. " / " .. GetString(SI_GAMEPAD_BANK_FILTER_HEADER), -- "Sort / Filter"
			keybind = "UI_SHORTCUT_TERTIARY", -- Triangle
			order = 2000,
			callback = function()
			end
		},
		{ -- Put item name in search box and refresh? Or fill in all filter criteria too?
			name = GetString(SI_TRADING_HOUSE_SEARCH_FROM_ITEM), -- "Search for Item"
			keybind = "UI_SHORTCUT_QUATERNARY", -- Square (Hold)
			order = 1500,
			callback = function()
			end
		},
		{ -- Link item in chat.
			name = GetString (SI_ITEM_ACTION_LINK_TO_CHAT), -- "Link in Chat"
			keybind = "UI_SHORTCUT_QUINARY", -- Triangle (Hold)
			order = 2500,
			callback = function()
			end
		},
		{
			alignment = KEYBIND_STRIP_ALIGN_RIGHT,
			name = GetString (SI_GAMEPAD_INVENTORY_TOGGLE_ITEM_COMPARE_MODE), -- "Toggle View"
			keybind = "UI_SHORTCUT_INPUT_LEFT", -- D-Pad Left
			ethereal = true, -- We want the function, but we don't need to show it.
			order = 3500,
			enabled = ComparisonVisibilityFunction,
			callback = ComparisonCallbackFunction
		},
		{
			alignment = KEYBIND_STRIP_ALIGN_RIGHT,
			name = GetString (SI_GAMEPAD_INVENTORY_TOGGLE_ITEM_COMPARE_MODE), -- "Toggle View"
			keybind = "UI_SHORTCUT_INPUT_RIGHT", -- D-Pad Right
			order = 4000,
			visible = ComparisonVisibilityFunction,
			callback = ComparisonCallbackFunction
		},
	}


	self.textSearchKeybindStripDescriptor =
	{
		alignment = KEYBIND_STRIP_ALIGN_LEFT,
		{
			{
				keybind = "UI_SHORTCUT_PRIMARY",
				name = function()
					return GetString (SI_GAMEPAD_SELECT_OPTION) -- "Select"
				end,
				callback = function()
					self:SetTextSearchFocused (true) -- CHANGE ME?
				end,
			},
			{
				keybind = "UI_SHORTCUT_QUATERNARY",
				name = GetString (SI_TRADING_HOUSE_RESET_SEARCH), -- "Reset Search"
				callback = function ()
					self:ClearSearchText ()
				end,

			}
		}
	}


	ZO_Gamepad_AddBackNavigationKeybindDescriptors (
		self.textSearchKeybindStripDescriptor,
		GAME_NAVIGATION_TYPE_BUTTON,
		function()
			self:OnBackButtonClicked()
		end
	)


--	ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, function()
--		self:OnBackButtonClicked()
--	end)

	Debug.Msg (3, ADDON_DEBUG_NAME, "LSG_IKSD", "Completed.")

end

-- Header tabs

-- LUXHRYS.options.extendedInventoryTabOrder =
-- {
	-- TAB_POSITION_ONE		= LOCATION_TYPE_FILTER_ALL,
	-- TAB_POSITION_TWO		= LOCATION_TYPE_FILTER_BACKPACK,
	-- TAB_POSITION_THREE	= LOCATION_TYPE_FILTER_HOUSE,
	-- TAB_POSITION_FOUR		= LOCATION_TYPE_FILTER_WORN,
	-- TAB_POSITION_FIVE		= LOCATION_TYPE_FILTER_BUYBACK,
-- --	TAB_POSITION_SIX		= LOCATION_TYPE_FILTER_INBOX
-- }

-- TODO: Implement the other filters.

local LUXHRYS_VAULT_AND_COFFER_LOCATION_TYPE_FILTERS =
{
	[LOCATION_TYPE_FILTER_ALL] =
	{
		filterType = nil, -- Show all items
		text = Location.GetTypeFilterName (LOCATION_TYPE_FILTER_ALL, true)
	},
	[LOCATION_TYPE_FILTER_BACKPACK] =
	{
		filterType =
		{
			locationTypes =
			{
				LOCATION_TYPE_CHAR
			}
		},
		text = Location.GetTypeFilterName (LOCATION_TYPE_FILTER_BACKPACK, true)
--		disabled =
	},
	[LOCATION_TYPE_FILTER_HOUSE] =
	{
		filterType =
		{
			locationTypes =
			{
				LOCATION_TYPE_HOUSE
			}
		},
		text = Location.GetTypeFilterName (LOCATION_TYPE_FILTER_HOUSE, true)
	},
	[LOCATION_TYPE_FILTER_INBOX] =
	{
		filterType =
		{
			locationTypes =
			{
				LOCATION_TYPE_INBOX
			}
		},
		text = Location.GetTypeFilterName (LOCATION_TYPE_FILTER_INBOX, true),
		disabled = function () return not options.isBagTracked[BAG_INBOX] end
	},
	[LOCATION_TYPE_FILTER_WORN] =
	{
		filterType =
		{
			locationTypes =
			{
				LOCATION_TYPE_WORN
			}
		},
		text = Location.GetTypeFilterName (LOCATION_TYPE_FILTER_WORN, true)
	},
	[LOCATION_TYPE_FILTER_BUYBACK] =
	{
		filterType =
		{
			locationTypes =
			{
				LOCATION_TYPE_BUYBACK
			}
		},
		text = Location.GetTypeFilterName (LOCATION_TYPE_FILTER_BUYBACK, true)
	},
}


function ListScreenGamepad:GetTabBarEntries ()
	return self.tabBarEntries
end


function ListScreenGamepad:InitializeTabBar ()

		Debug.Msg (2, ADDON_DEBUG_NAME, "LSG_ITB", "Called.")

	local tabBarEntries = {}
	local baseTab, thisTabFilterIndex
	local NARRATE_HEADER = true
	local NARRATE_SUB_HEADER = true

--	local function TabBarCallbackFunction (tabData)
	local function TabBarCallbackFunction ()
		self:OnTabBarCategoryChanged (self.header.tabBar:GetTargetData ())
		--Re-narrate on tab change
		if self:GetCurrentList () and SCREEN_NARRATION_MANAGER then
			SCREEN_NARRATION_MANAGER:QueueParametricListEntry(self:GetCurrentList (), NARRATE_HEADER, NARRATE_SUB_HEADER)
		end
	end


--	for tabIndex, locationTypeFilter in ipairs (OPTIONS.VaC.listScreenTabOrder) do
	for i = 1, #OPTIONS.VaC.listScreenTabOrder do
		baseTab = LUXHRYS_VAULT_AND_COFFER_LOCATION_TYPE_FILTERS[OPTIONS.VaC.listScreenTabOrder[i]]
		if baseTab then
			thisTabFilterIndex = OPTIONS.VaC.listScreenTabOrder[i]
--			table.insert (tabBarEntries,
			tabBarEntries[#tabBarEntries + 1] =
			{
				text = baseTab.text,
				tabFilterIndex = thisTabFilterIndex,
				tabIndex = i,
				filterType = baseTab.filterType,
				callback = TabBarCallbackFunction --function (tabData) TabBarCallbackFunction (tabData) end
--					self:OnTabBarCategoryChanged (self.header.tabBar:GetTargetData ())
					--Re-narrate on tab change
--					if self:GetCurrentList () and SCREEN_NARRATION_MANAGER then
--						SCREEN_NARRATION_MANAGER:QueueParametricListEntry(self:GetCurrentList (), NARRATE_HEADER, NARRATE_SUB_HEADER)
--					end
--				end
			}
			thisTabFilterIndex = nil
		end
	end

	Debug.Msg (3, ADDON_DEBUG_NAME, "LSG_ITB", "Completed.")

	return tabBarEntries
end


function ListScreenGamepad:OnTabBarCategoryChanged(selectedTabData)

	Debug.Msg (2, ADDON_DEBUG_NAME, "LSG_OTBCC", "Called. New tab filter index is %d.", selectedTabData.tabFilterIndex or 0)


	if not selectedTabData then return end

	if self:IsShowing() then
		self:RefreshKeybinds ()
	end

	self.currentFilterType = selectedTabData.filterType
	self.currentTabFilterIndex = selectedTabData.tabFilterIndex

	if self:IsHeaderActive() then
		self:RequestLeaveHeader()
	end

	GAMEPAD_TOOLTIPS:Reset(GAMEPAD_LEFT_TOOLTIP)
	GAMEPAD_TOOLTIPS:Reset(GAMEPAD_RIGHT_TOOLTIP)

--	ZO_GamepadGenericHeader_RefreshData (self.header, self.headerData)

--	ZO_Gamepad_ParametricList_Screen.OnTabBarCategoryChanged (self, selectedFilterData)

	self:Update()

--	ZO_GamepadGenericHeader_SetActiveTabIndex (self.header, selectedTabData.tabIndex)
--	ZO_GamepadGenericHeader_Refresh (self.header, selectedTabData.tabIndex)

--	if self.header.tabBar and self.header.tabBar.Activate then
--		self.header.tabBar:Activate ()
--	end

	Debug.Msg (3, ADDON_DEBUG_NAME, "OTBCC", "Completed.")

end

--[[
function ListScreenGamepad:OnTabBarCategoryChanged(selectedFilterData)

	if not selectedFilterData then return end

	self.currentFilterType = selectedFilterData.filterType
	ZO_GamepadGenericHeader_RefreshData (self.header, self.headerData)

--	ZO_Gamepad_ParametricList_Screen.OnTabBarCategoryChanged (self, selectedFilterData)

	self:Update()

end
]]

-- /script d (XMenuTest.EXTENDED_INVENTORY.header.tabBar:GetTargetData ())


-- Header

function ListScreenGamepad:InitializeHeader ()

	local function UpdateTitleText ()
		local selectedTab = self.header.tabBar:GetTargetData ()
		if selectedTab then
			return selectedTab.text
		end
		return ""
	end

	Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_IH", "Called.")

	if not self.header.tabBar.keybindStripDescriptor then
		Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_IH", "Header tabBar descriptor does not exist.")
	end

	-- Update tabBar keybind callbacks to allow for wrapping. This should not need any attention beyond overwriting the defaults.
-- /script d (XMenuTest.EXTENDED_INVENTORY.header.tabBar.keybindStripDescriptor)
-- XMenuTest.EXTENDED_INVENTORY.header.tabBar:MoveNext () -- Works!

	if self.header.tabBar.keybindStripDescriptor ~= nil then

		self.header.tabBar.keybindStripDescriptor =
		{
			{
				--Even though this is an ethereal keybind, the name will still be read during screen narration
				name = GetString(SI_SCREEN_NARRATION_TABBAR_PREVIOUS_KEYBIND),
				keybind = "UI_SHORTCUT_LEFT_SHOULDER",
				ethereal = true,
				narrateEthereal = function()
					return #self.header.tabBar.dataList > 1
				end,
				etherealNarrationOrder = 100,
				callback = function()
					if self.header.tabBar.active then
						if self.infoPanelGridList and self.infoPanelGridList:IsActive () then -- if the infoPanel is active, we need to exit it.
							self.infoPanel:ExitGridList ()
						end
						self.header.tabBar:MovePrevious (OPTIONS.VaC.wrapTabBar)
					end
				end,
			},
			{
				--Even though this is an ethereal keybind, the name will still be read during screen narration
				name = GetString(SI_SCREEN_NARRATION_TABBAR_NEXT_KEYBIND),
				keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
				ethereal = true,
				narrateEthereal = function()
					return #self.header.tabBar.dataList > 1
				end,
				etherealNarrationOrder = 101,
				callback = function()
					if self.header.tabBar.active then
						if self.infoPanelGridList and self.infoPanelGridList:IsActive () then -- if the infoPanel is active, we need to exit it.
							self.InfoPanel:ExitGridList ()
						end
						self.header.tabBar:MoveNext (OPTIONS.VaC.wrapTabBar)
					end
				end,
			}
		}

	end


	self.headerData =
	{
		tabBarEntries = self:GetTabBarEntries (),
		titleText = UpdateTitleText,


--[[
		data1HeaderText = GetString(SI_GAMEPAD_INVENTORY_AVAILABLE_FUNDS),
		data1Text = UpdateGold,
		data1TextNarration = ZO_Currency_GetPlayerCarriedGoldNarration,

		data2HeaderText = GetString(SI_GAMEPAD_INVENTORY_CAPACITY),
		data2Text = UpdateCapacityString,
]]
	}


--ZO_GamepadGenericHeader_Refresh (XMenuTest.EXTENDED_INVENTORY.header, XMenuTest.EXTENDED_INVENTORY.headerData)

	ZO_GamepadGenericHeader_Refresh(self.header, self.headerData, false)

--	local SELECT_DEFAULT_ENTRY = true

--	self:OnTabBarCategoryChanged(LUXHRYS.options.listScreenTabOrder[TAB_POSITION_ONE])
-- /script d (GAMEPAD_TOOLTIPS.ShowGenericHeader (GAMEPAD_LEFT_TOOLTIP, GAMEPAD_TOOLTIPS:GetTooltipInfo(GAMEPAD_LEFT_TOOLTIP)))

	Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_IH", "Completed.")

end










-- Sort


-- Filter




-- Search


function ListScreenGamepad:InitializeTextSearch ()

	Debug.Msg (2, ADDON_DEBUG_NAME, "LSG_ITS", "Called.")

	local function OnTextSearchTextChanged (editBox)
		self.searchText = editBox:GetText ()
		if self.searchText and self.searchText ~= "" then
			self:UpdateList ()
		end
	end

	self:AddSearch (self.textSearchKeybindStripDescriptor, OnTextSearchTextChanged)

--self:ActivateTextSearch() from gamepadinventory.lua

	Debug.Msg (2, ADDON_DEBUG_NAME, "LSG_ITS", "Completed.")

end









-- List Management

function ListScreenGamepad:RefreshReferenceList () -- TODO: Implement update callback from database changes.

	Debug.Msg (2, ADDON_DEBUG_NAME, "LSG_RRL", "Called. Creting new reference list? %s", self.referenceList ~= nil and "No" or "Yes")
	

	self.referenceListAvailable = false

	-- If we are using asynchronous processing, we'll need a callback.

--[[
	local function callbackFunction (inventoryList)
		table.sort (inventoryList, XMT_VaC_DefaultItemSortComparator)
		self.referenceList = inventoryList
	end
]]

	local function callbackFunction ()
		assert (self.referenceList and type (self.referenceList == "table"), "[" .. ADDON_DEBUG_NAME .. ":LSG_RRL_cF] CRIT: Error updating reference inventory.")
		Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_RRL_cF", "Performing initial sort.")
		table.sort (self.referenceList, LuXhrys_VaC_DefaultItemSortComparator) -- TODO: Do custom sorting here!
		Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_RRL_cF", "Sorting complete.")
		self.lastReferenceUpdate = GetTimeStamp ()
		self.referenceListAvailable = true
		if self:GetCurrentList () == self.list then
			self:RefreshDynamicList ()
		end
	end

	assert (self.referenceList, "[" .. ADDON_DEBUG_NAME .. ":LSG_RRL] CRIT: No reference list.")
	assert (callbackFunction, "[" .. ADDON_DEBUG_NAME .. ":LSG_RRL] CRIT: No callback.")
	assert (DBLOOKUP.GenerateInventoryListItemData, "[" .. ADDON_DEBUG_NAME .. ":LSG_RRL] CRIT: No generator.")

	-- Send reference list to database to be updated.

	DBLOOKUP:GenerateInventoryListItemData (self.referenceList, callbackFunction)

	Debug.Msg (3, ADDON_DEBUG_NAME, "LSG_RRL", "Completed.")

end


do

	local function GetItemNarrationText (entryData, entryControl)
		local narrations = {}

		ZO_AppendNarration (narrations, ZO_GetSharedGamepadEntryDefaultNarrationText (entryData, entryControl))

		if IsPreviewing () then
			-- Generate the standard parametric list entry narration
			if ITEM_PREVIEW_GAMEPAD.currentPreviewTypeObject then
				local itemLink = ITEM_PREVIEW_GAMEPAD.currentPreviewTypeObject and ITEM_PREVIEW_GAMEPAD.currentPreviewTypeObject.itemLink
				if itemLink then
					ZO_AppendNarration (narrations, SCREEN_NARRATION_MANAGER:CreateNarratableObject (GetItemLinkName (itemLink)))
				end
					ZO_AppendNarration (narrations, ITEM_PREVIEW_GAMEPAD:GetPreviewSpinnerNarrationText ())
			end
		end

		return narrations
	end


	function ListScreenGamepad:RefreshDynamicList ()

	Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_RDL", "Called. RefList type: %s; RefList length via #: %s", type (self.referenceList), tostring (#self.referenceList))

	if not self.referenceListAvailable or self:GetCurrentList () ~= self.list then return end

	self.list:Clear ()

	-- TODO: Make sure that we have generated the reference list ahead of time.

	if not self.referenceList or #self.referenceList == 0 then
		self.list:SetNoItemText(GetString(SI_GAMEPAD_INVENTORY_EMPTY))
		return
	end -- if not self.referenceList or #self.referenceList == 0

-- function ZO_GamepadEntryData:Initialize(text, icon, selectedIcon, highlight, isNew)

	local lastBestItemCategoryName, entryData

	local loopCount, entryCount, headerCount = 0, 0, 0

	Debug.Msg (4, ADDON_DEBUG_NAME, "LSG_RDL", "Current filter? %s. Current tabFilterIndex? %s.", tostring (self.currentFilterType), tostring (self.currentTabFilterIndex))


	local inventoryList

	-- If this is a furniture-only list, we want to sort by furniture category. We'll need an extra loop and sort.

	if (self.currentTabFilterIndex == LOCATION_TYPE_FILTER_FURNITURE_VAULT
	or self.currentTabFilterIndex == LOCATION_TYPE_FILTER_HOUSE)
	then
		inventoryList = {}
		for i = 1, #self.referenceList do
			if self.referenceList[i].itemType == ITEMTYPE_FURNISHING then
				inventoryList[#inventoryList + 1] = self.referenceList[i]
			end
		end -- for
		table.sort (inventoryList, LuXhrys_VaC_DefaultFurnishingItemSortComparator)
	else
		inventoryList = self.referenceList
	end

	local passesFilters


--	local stackCountBackpack, stackCountBank, stackCountCraftBag, stackCountHouseBanks, stackCountFurnitureVault, stackCountVengeanceBag

--	local allCharacterBackpackCount, collectibleHousingStorageCount, furnitureVaultCount, placedFurnitureCount, guildTraderCount, mailboxCount, guildBankCount, allCharacterWornCount, allCharacterBuybackCount, companionWornCount, allCharacterVengeanceCount


	local stackCountBank, stackCountCraftBag, stackCountVengeanceBag, extendedStackCounts, totalStackCount, _


--	for _, itemData in ipairs (self.referenceList) do
	for i = 1, #inventoryList do -- TODO: Implement async.

		loopCount = loopCount + 1

--[[
	-- 1. APPLY DYNAMIC FILTERS (Your upcoming location tabs and search box text features plug in right here!)
	local passesFilters = true

	-- Example filter hook matching your structural options:
	-- if self.currentFilterType then
	--     -- Filter logic evaluating itemData against self.currentFilterType.locationTypes
	-- end

	if passesFilters then
]]

		passesFilters = true
-- /script d (LUXHRYS.LISTSCREEN_GAMEPAD.referenceList[5].extendedStackCounts[LUXHRYS.LISTSCREEN_GAMEPAD.currentTabFilterIndex])

		-- Apply tab filter (locationType)


		_, stackCountBank, stackCountCraftBag, _, _, stackCountVengeanceBag = GetItemLinkStacks (inventoryList[i].itemLink)

	-- These are used only here. Tooltips get extended stack counts independently, where the current character's inventory is not included. Therefore, we should include the inventory for all characters here.

--	allCharacterBackpackCount, collectibleHousingStorageCount, furnitureVaultCount, placedFurnitureCount, guildTraderCount, mailboxCount, guildBankCount, allCharacterWornCount, allCharacterBuybackCount, companionWornCount, allCharacterVengeanceCount
--d (DBLOOKUP.GetItemInfo (inventoryList[i].itemKey), "\r\n", { ItemInfo.GetExtendedStackCounts (DBLOOKUP.GetItemInfo (inventoryList[i].itemKey), true) })
		extendedStackCounts = { ItemInfo.GetExtendedStackCounts (DBLOOKUP.GetItemInfo (inventoryList[i].itemKey), true) }

--[[
	itemData.extendedStackCounts = -- TODO: Make sure vengeance bag math is right. All the others ignore current character's inventory in GetExtendedStackCounts. TODO: Except maybe backpack?
	{
		[LOCATION_TYPE_FILTER_ALL] = allCharacterWornCount + allCharacterBackpackCount + guildBankCount + allCharacterBuybackCount + collectibleHousingStorageCount + companionWornCount + furnitureVaultCount + allCharacterVengeanceCount + placedFurnitureCount + mailboxCount + guildTraderCount + stackCountBank + stackCountCraftBag,
		[LOCATION_TYPE_FILTER_BACKPACK] = allCharacterBackpackCount,
		[LOCATION_TYPE_FILTER_COLLECTIBLE_STORAGE] = collectibleHousingStorageCount,
		[LOCATION_TYPE_FILTER_FURNITURE_VAULT] = furnitureVaultCount,
		[LOCATION_TYPE_FILTER_HOUSE] = placedFurnitureCount,
		[LOCATION_TYPE_FILTER_TRADER] = guildTraderCount,
		[LOCATION_TYPE_FILTER_INBOX] = mailboxCount,
		[LOCATION_TYPE_FILTER_GUILD] = guildBankCount,
		[LOCATION_TYPE_FILTER_WORN] = allCharacterWornCount,
		[LOCATION_TYPE_FILTER_BUYBACK] = allCharacterBuybackCount,
		[LOCATION_TYPE_FILTER_COMPANION] = companionWornCount,
		[LOCATION_TYPE_FILTER_VENGEANCE] = allCharacterVengeanceCount
	}
]]

	-- We'll set stackCount (for list entry icon overlay, not to be conflated with stackCounts above) during the dynamic list generation depending on the filters used. This adds a bit of time, but moved here from GetItemData to save memory since we only need the count applying to the current tab and otherwise don't need the information.

--		totalStackCount = allCharacterWornCount + allCharacterBackpackCount + guildBankCount + allCharacterBuybackCount + collectibleHousingStorageCount + companionWornCount + furnitureVaultCount + allCharacterVengeanceCount + placedFurnitureCount + mailboxCount + guildTraderCount + stackCountBank + stackCountCraftBag + stackCountFurnitureVault - stackCountVengeanceBag

		if self.currentTabFilterIndex == LOCATION_TYPE_FILTER_ALL then
			totalStackCount = 0
			for _, count in ipairs (extendedStackCounts) do
				totalStackCount = totalStackCount + count
			end
			inventoryList[i].stackCount = totalStackCount + stackCountBank + stackCountCraftBag - stackCountVengeanceBag
		else -- if self.currentTabFilterIndex == LOCATION_TYPE_FILTER_ALL ...
			if extendedStackCounts[self.currentTabFilterIndex - 1] < 1 then -- -1 because LOCATION_TYPE_FILTER_ALL would normally be in key 1, but GetExtendedStackCounts does not return it.
				passesFilters = false
			else -- if extendedStackCounts[self.currentTabFilterIndex] < 1
				inventoryList[i].stackCount = extendedStackCounts[self.currentTabFilterIndex - 1]
			end -- if extendedStackCounts[self.currentTabFilterIndex] < 1
		end -- if self.currentTabFilterIndex == LOCATION_TYPE_FILTER_ALL ...


--			Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_RDL", "Passed? %s. Current tabFilterIndex? %d. Stack count? %d.", tostring (passesFilters), self.currentTabFilterIndex, inventoryList[i].extendedStackCounts[self.currentTabFilterIndex])
--if loopCount == 105 then d (inventoryList[i].extendedStackCounts) end

	-- TODO: Do filtering and sorting here!


		-- Category filters.



		-- Text search is fairly expensive, so do it after all the other filters have been applied and the amount of data to search has been reduced.

		if passesFilters and self.searchText and self.searchText ~= "" then
--			if string.find (inventoryList[i].name, self.searchText) == nil then
			if inventoryList[i].name:find (self.searchText) == nil then
				passesFilters = false
			end -- inventoryList[i].name:find (self.searchText) == nil
		end -- if passesFilters and self.searchText and self.searchText ~= ""


		if passesFilters then

			entryData = ZO_GamepadEntryData:New (inventoryList[i].name, inventoryList[i].iconFile)
			entryData:InitializeInventoryVisualData (inventoryList[i])

			entryData.itemData = inventoryList[i]

			-- TODO: This is another thing I fear will cause problems.
	--		ZO_InventorySlot_SetType(entryData, SLOT_TYPE_GAMEPAD_INVENTORY_ITEM)

			-- TODO: We'll need to filter out Vengeance when we're in that mode.
	--if IsCurrentCampaignVengeanceRuleset()

--			if self.entrySetupCallback then
--				self.entrySetupCallback(entry)
--			end

--			entryData:SetIconTintOnSelection(true)
--			entryData.setup = ZO_SharedGamepadEntry_OnSetup
--			entryData.soundEnabled = true



			if (self.currentTabFilterIndex == LOCATION_TYPE_FILTER_FURNITURE_VAULT
			or self.currentTabFilterIndex == LOCATION_TYPE_FILTER_HOUSE)
			and inventoryList[i].bestItemFurnishingCategoryName ~= lastBestItemCategoryName
			then
				headerCount = headerCount + 1
				lastBestItemCategoryName = inventoryList[i].bestItemFurnishingCategoryName
				entryData:SetHeader (lastBestItemCategoryName)
				self.list:AddEntryWithHeader ("ZO_GamepadMenuEntryTemplate", entryData)
			elseif not (self.currentTabFilterIndex == LOCATION_TYPE_FILTER_FURNITURE_VAULT
			or self.currentTabFilterIndex == LOCATION_TYPE_FILTER_HOUSE)
			and inventoryList[i].bestItemCategoryName ~= lastBestItemCategoryName
			then
				headerCount = headerCount + 1
				lastBestItemCategoryName = inventoryList[i].bestItemCategoryName
				entryData:SetHeader (lastBestItemCategoryName)
				self.list:AddEntryWithHeader ("ZO_GamepadMenuEntryTemplate", entryData)
--					self.list:AddEntry ("XMT_GamepadItemEntryTemplateWithHeader", entryData)
			else -- if inventoryList[i].bestItemCategoryName ~= lastBestItemCategoryName

				entryCount = entryCount + 1

				self.list:AddEntry ("ZO_GamepadMenuEntryTemplate", entryData)
--					self.list:AddEntry ("XMT_GamepadItemSubEntryTemplate", entryData)
			end -- if inventoryList[i].bestItemCategoryName ~= lastBestItemCategoryName

			entryData.narrationText = GetItemNarrationText

		end -- if passesFilters
	end -- for i = 1, inventoryList

	-- TODO: Resort if furniture only with furniture categories.
--		table.sort (inventoryList, XMT_VaC_DefaultItemSortComparator)

	self.list:Commit ()

	Debug.Msg (3, ADDON_DEBUG_NAME, "LSG_RDL", "Completed. Loop iterated %d times. %d entries and %d headers.", loopCount, entryCount, headerCount)

	end -- ListScreenGamepad:RefreshDynamicList


end -- do


function ListScreenGamepad:ActivateMainList ()
	if self:IsCurrentList (self.list) and not self.list:IsActive () then
		self:ActivateCurrentList ()
		KEYBIND_STRIP:AddKeybindButtonGroup (self.keybindStripDescriptor)
	end
end

function ListScreenGamepad:DeactivateMainList ()
	if self:IsCurrentList (self.list) and self.list:IsActive () then
		self:DeactivateCurrentList ()
		KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
	end
end


-- /script d (DIRECTIONAL_INPUT:IsListening (MAIN_MENU_GAMEPAD))
-- /script d (DIRECTIONAL_INPUT:Activate (MAIN_MENU_GAMEPAD, MAIN_MENU_GAMEPAD.control))

-- /script d (DIRECTIONAL_INPUT:IsListening (XMenuTest.EXTENDED_INVENTORY))


-- List management


-- Returns whether item compare mode should be set.

function ListScreenGamepad:UpdateTooltips (itemLink, tooltip)

	Debug.Msg (3, ADDON_DEBUG_NAME, "LSG_UT", "Called. ItemLink is %s.", itemLink)

	if self:IsHeaderActive() then
--		Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_UT", "Header is active. Returning early.")
		return
	end

--	GAMEPAD_TOOLTIPS:ClearTooltip (GAMEPAD_RIGHT_TOOLTIP)

	local equipSlot = GetEquipSlotFromItemLink (itemLink)
	local actorCategory = GetItemLinkActorCategory (itemLink)
	local wornBag = GetWornBagForGameplayActorCategory (actorCategory)
	local isWearing = GetWornItemInfo (wornBag, equipSlot)
	local isWearingSame = GetItemLink (wornBag, equipSlot) == itemLink

-- /script d (ZO_Ingame_SavedVariables.Default["@Xhrysanth"]["$AccountWide"].GamepadInventory.useStatComparisonTooltip) -- Works

--local tmp = GI_SavedVars.useStatComparisonTooltip
--	Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_UT", "ES: %s. Is wearing? %s. Use tooltip? %s.", tostring (equipSlot), tostring (isWearing), tmp and "Yes" or "No")


	if not tooltip or tooltip == GAMEPAD_LEFT_TOOLTIP then
		GAMEPAD_TOOLTIPS:ClearTooltip (GAMEPAD_LEFT_TOOLTIP, true)

		TOOLTIPS_GAMEPAD:CallingListScreenTooltip (itemLink)
		if GAMEPAD_TOOLTIPS:LayoutItem(GAMEPAD_LEFT_TOOLTIP, itemLink) and isWearing and isWearingSame then
			ZO_InventoryUtils_UpdateTooltipEquippedIndicatorText (GAMEPAD_LEFT_TOOLTIP, equipSlot, actorCategory) -- blocks stack counts from showing TODO: Does it? I don't think so.
--		GAMEPAD_TOOLTIPS:LayoutItem(GAMEPAD_LEFT_TOOLTIP, itemLink)
--		else
--			GAMEPAD_TOOLTIPS:ClearTooltip (GAMEPAD_LEFT_TOOLTIP)
		end
	end

	GAMEPAD_TOOLTIPS:ClearTooltip (GAMEPAD_RIGHT_TOOLTIP)

	if not IsComparisonModeEnabled (itemLink) then
--		Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_UT", "Item is not wearable. Returning early.")
--		GAMEPAD_TOOLTIPS:ClearTooltip (GAMEPAD_RIGHT_TOOLTIP)
		return
	end


	if (not tooltip or tooltip == GAMEPAD_RIGHT_TOOLTIP) then

		local LAYOUT_BAG_ITEM_DEFAULT_SHOW_COMBINED_COUNT = nil
		local LAYOUT_BAG_ITEM_EXTRA_DATA = { showSuppression = true }

		if not isWearing or GI_SavedVars.useStatComparisonTooltip then

	--		ZOS uses GAMEPAD_TOOLTIPS:LayoutItemStatComparison(GAMEPAD_RIGHT_TOOLTIP, wornBag, equipSlot, itemLink)

			-- This is a custom function to allow using an itemLink, otherwise identical to GAMEPAD_TOOLTIPS:LayoutItemStatComparison.
			GAMEPAD_TOOLTIPS:LayoutItemLinkStatComparison(GAMEPAD_RIGHT_TOOLTIP, itemLink, equipSlot)
			GAMEPAD_TOOLTIPS:SetStatusLabelText (GAMEPAD_RIGHT_TOOLTIP, GetString(SI_GAMEPAD_INVENTORY_ITEM_COMPARE_TOOLTIP_TITLE))

		-- for equipped comparison: function ZO_LayoutItemLinkEquippedComparison(tooltipType, itemLink, showSecondSlot) in itemtooltips.lua. Note: all this does is figure out equip slots and then calls LayoutBagItem. Since we've already done the other work, let's just call LayoutBagItem.

		elseif GAMEPAD_TOOLTIPS:LayoutBagItem (GAMEPAD_RIGHT_TOOLTIP, wornBag, equipSlot, LAYOUT_BAG_ITEM_DEFAULT_SHOW_COMBINED_COUNT, LAYOUT_BAG_ITEM_EXTRA_DATA) then
				ZO_InventoryUtils_UpdateTooltipEquippedIndicatorText (GAMEPAD_RIGHT_TOOLTIP, equipSlot, actorCategory)
		else
--			GAMEPAD_TOOLTIPS:ClearTooltip (GAMEPAD_RIGHT_TOOLTIP)
		end
	end

--[[ TODO: Compare companion gear. Here's ZOS' code from 2048-2058 of esoui/ingame/inventory/gamepad/gamepadinventory.lua:

	local selectedItemData = self.currentlySelectedData
	if targetCategoryData.equipSlot then
		local equipSlotHasItem = GetWornItemInfo(BAG_WORN, targetCategoryData.equipSlot)
		if selectedItemData and (not equipSlotHasItem or self.savedVars.useStatComparisonTooltip) then
			GAMEPAD_TOOLTIPS:LayoutItemStatComparison(GAMEPAD_RIGHT_TOOLTIP, selectedItemData.bagId, selectedItemData.slotIndex, targetCategoryData.equipSlot)
			GAMEPAD_TOOLTIPS:SetStatusLabelText(GAMEPAD_RIGHT_TOOLTIP, GetString(SI_GAMEPAD_INVENTORY_ITEM_COMPARE_TOOLTIP_TITLE))
		elseif GAMEPAD_TOOLTIPS:LayoutBagItem(GAMEPAD_RIGHT_TOOLTIP, BAG_WORN, targetCategoryData.equipSlot, LAYOUT_BAG_ITEM_DEFAULT_SHOW_COMBINED_COUNT, LAYOUT_BAG_ITEM_EXTRA_DATA) then
			self:UpdateTooltipEquippedIndicatorText(GAMEPAD_RIGHT_TOOLTIP, targetCategoryData.equipSlot)
		end
	elseif selectedItemData and targetCategoryData.filterType == ITEMFILTERTYPE_COMPANION then
		ZO_LayoutBagItemEquippedComparison(GAMEPAD_RIGHT_TOOLTIP, selectedItemData.bagId, selectedItemData.slotIndex)
]]

end


-- A function, which may be overridden in a sub-class, and is called whenever the item list's target data is changed.
function ListScreenGamepad:OnTargetChanged(list, targetData, oldTargetData) --, reachedTarget, targetSelectedIndex)

--	Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OTC", "Called.")


	if not targetData then
		Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OTC", "No targetData. Exiting early.")
		return
	end

	self.activeTargetData = targetData

	-- Don't want a tooltip for a category header in the list. It shouldn't be targetable, but you never know. TODO: Test

--	Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OTC", "itemLink present? " .. (targetData.itemLink ~= nil and targetData.itemLink or "No"))

--	targetData.itemComparisonModeEnabled = self:UpdateRightTooltip (targetData.itemLink) and true or false
--[[	activeList = self:GetCurrentList ()
	if activeList then
		Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OTC", "activeList good. Type: %s. GetTargetData exists? %s.", type (activeList), not activeList.GetTargetData and "No" or "Yes")
		activeTarget = activeList:GetTargetData ()
		if activeTarget then
			Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OTC", "activeTarget good.")
			activeTarget.itemComparisonModeEnabled = self:UpdateRightTooltip (targetData.itemLink) and true or false
		else
			Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OTC", "activeTarget bad.")
		end
	else
		Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OTC", "activeList bad.")
	end
]]

--	Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OTC", "Item comparison mode is %s.", self.list:GetTargetData ().itemComparisonModeEnabled and "enabled" or "disabled")
--	self.list:GetTargetData ().itemComparisonModeEnabled = self:UpdateRightTooltip (targetData.itemLink) and true or false


--	Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OTC", "Laying out left tooltip for %s.", targetData.itemLink)
--[[
	local equipSlot = GetEquipSlotFromItemLink (targetData.itemLink)
	local actorCategory = GetItemLinkActorCategory (targetData.itemLink)
	local wornBag = GetWornBagForGameplayActorCategory (actorCategory)--	Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OTC", "Calling URT with itemLink %s.", targetData.itemLink)
	local isWearing = GetWornItemInfo (wornBag, equipSlot)--	Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OTC", "itemLink is present: %s. Calling URT.", targetData.itemLink)
	local isWearingSame = GetItemLink (wornBag, equipSlot) == targetData.itemLink

	if GAMEPAD_TOOLTIPS:LayoutItem(GAMEPAD_LEFT_TOOLTIP, targetData.itemLink) and isWearing and isWearingSame then
		ZO_InventoryUtils_UpdateTooltipEquippedIndicatorText (GAMEPAD_LEFT_TOOLTIP, equipSlot, actorCategory)
	end
]]

	self:UpdateTooltips (targetData.itemLink)


	if self.keybindStripDescriptor then
		KEYBIND_STRIP:UpdateKeybindButtonGroup (self.keybindStripDescriptor)
	end


--[[

		local equipSlot1, equipSlot2 = GetItemLinkEquippedComparisonEquipSlots (targetData.itemLink)
		local equipSlot

		Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OTC", "ES1: %d. ES2: %d.", equipSlot1, equipSlot2)

		if equipSlot1 ~= EQUIP_SLOT_NONE then
			if GetWornItemInfo (BAG_WORN, equipSlot1) then
				equipSlot = equipSlot1
				Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OTC", "ES1: %s.", tostring (equipSlot))
			end
		end

		if not equipSlot and equipSlot2 ~= EQUIP_SLOT_NONE then
			if GetWornItemInfo (BAG_WORN, equipSlot2) then
				equipSlot = equipSlot1
				Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OTC", "ES2: %s.", tostring (equipSlot))
			end
		end

		if equipSlot then

				Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OTC", "ES: %s", tostring (equipSlot))

	--		ZO_LayoutItemLinkEquippedComparison(GAMEPAD_RIGHT_TOOLTIP, targetData.itemLink) --, showSecondSlot)
				GAMEPAD_TOOLTIPS:LayoutItemStatComparison(GAMEPAD_RIGHT_TOOLTIP, BAG_WORN, equipSlot, targetData.itemLink)
				GAMEPAD_TOOLTIPS:SetStatusLabelText(GAMEPAD_RIGHT_TOOLTIP, GetString(SI_GAMEPAD_INVENTORY_ITEM_COMPARE_TOOLTIP_TITLE))
	-- for equipped comparison: function ZO_LayoutItemLinkEquippedComparison(tooltipType, itemLink, showSecondSlot) in itemtooltips.lua

		end
]]


	if IsPreviewing () then
		if CanEntryDataBePreviewed (targetData) then
			self:ItemLinkPreview (targetData.itemLink)
		else
			self:EndPreview ()
		end
	end

	if self.infoPanel then
		self.infoPanel:Update (targetData)
	end

--	Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OTC", "Completed.")

end


function ListScreenGamepad:OnShowing ()

	Debug.Msg (2, ADDON_DEBUG_NAME, "LSG_OS", "Called.")

--[[
	if not self.header.tabBar.active and self.header.tabBar.Activate then
		self.header.tabBar:Activate ()
	end]]

	ZO_GamepadGenericHeader_Activate (self.header)

	Debug.Msg (4, ADDON_DEBUG_NAME, "LSG_OS", "Current filter type: %s. Current Tab Filter Index: %s.", tostring (self.currentFilterType), tostring (self.currentTabFilterIndex))

	-- This calls PerformUpdate if needed. Also activates direction input.
	ZO_Gamepad_ParametricList_Screen.OnShowing (self)

--	ZO_GamepadGenericHeader_SetActiveTabIndex(self.header, 1)

--	self:ActivateCurrentList ()

--	ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)
--	ZO_GamepadGenericHeader_Activate(self.header)

--[[
	Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OS", "Laying out tooltip for %s.", targetData.itemLink)
		GAMEPAD_TOOLTIPS:LayoutItem(GAMEPAD_LEFT_TOOLTIP, targetData.itemLink)

		local equipSlot1, equipSlot2 = GetItemLinkEquippedComparisonEquipSlots (targetData.itemLink)
		local equipSlot

		Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OS", "ES1: %d. ES2: %d.", equipSlot1, equipSlot2)

		if equipSlot1 ~= EQUIP_SLOT_NONE then
			if GetWornItemInfo (BAG_WORN, equipSlot1) then
				equipSlot = equipSlot1
				Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OS", "ES1: %s.", tostring (equipSlot))
			end
		end

		if not equipSlot and equipSlot2 ~= EQUIP_SLOT_NONE then
			if GetWornItemInfo (BAG_WORN, equipSlot2) then
				equipSlot = equipSlot1
				Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OS", "ES2: %s.", tostring (equipSlot))
			end
		end

		if equipSlot then

				Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OS", "ES: %s", tostring (equipSlot))

	--		ZO_LayoutItemLinkEquippedComparison(GAMEPAD_RIGHT_TOOLTIP, targetData.itemLink) --, showSecondSlot)
				GAMEPAD_TOOLTIPS:LayoutItemStatComparison(GAMEPAD_RIGHT_TOOLTIP, BAG_WORN, equipSlot, targetData.itemLink)
				GAMEPAD_TOOLTIPS:SetStatusLabelText(GAMEPAD_RIGHT_TOOLTIP, GetString(SI_GAMEPAD_INVENTORY_ITEM_COMPARE_TOOLTIP_TITLE))
	-- for equipped comparison: function ZO_LayoutItemLinkEquippedComparison(tooltipType, itemLink, showSecondSlot) in itemtooltips.lua

		end
]]

--d (self.activeTargetData)
--	local targetData = self.list:GetTargetData ()
	local itemLink = self.activeTargetData and self.activeTargetData.itemLink or nil

	if itemLink then
--		Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OS", "activeTargetData.itemLink is set.")

--		Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OS", "Laying out left tooltip for %s.", itemLink)
--		GAMEPAD_TOOLTIPS:LayoutItem(GAMEPAD_LEFT_TOOLTIP, itemLink)

--		Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OS", "itemLink is present: %s. Calling URT.", itemLink)
--		self:UpdateRightTooltip (itemLink)
		self:UpdateTooltips (itemLink)
--	else
--		Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_OS", "activeTargetData.itemLink is not set.")
--		self.infoPanel:Update (self.activeTargetData)

	end


-- This is done by OnStateChanged in esoui/common/gamepad/zo_gamepadparametricscrolllistscreen.lua.
--	KEYBIND_STRIP:AddKeybindButtonGroup (self.keybindStripDescriptor)

	Debug.Msg (3, ADDON_DEBUG_NAME, "LSG_OS", "Completed.")

end

--[[
function ListScreenGamepad:MovePrevious (allowWrapping, suppressFailSound)

Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_MP", "Called. allowWrapping? %s. suppressFailSound? %s.", tostring (allowWrapping or "nil"), tostring (suppressFailSound or "nil"))

ZO_GamepadTabBarScrollList.MovePrevious(self, allowWrapping, suppressFailSound)

end

function ListScreenGamepad:MoveNext (allowWrapping, suppressFailSound)

Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_MN", "Called. allowWrapping? %s. suppressFailSound? %s.", tostring (allowWrapping or "nil"), tostring (suppressFailSound or "nil"))

ZO_GamepadTabBarScrollList.MoveNext (self, allowWrapping, suppressFailSound)

end
]]


function ListScreenGamepad:OnHiding ()

	Debug.Msg (2, ADDON_DEBUG_NAME, "LSG_OH", "Called.")

	-- This function currently does nothing, but leave it here in case they change it?
	ZO_Gamepad_ParametricList_Screen.OnHiding (self)

	-- Deactivate text search.

--[[ See 213-217 in esoui/ingame/tradinghouse/gamepad/tradinghouse_gamepad.lua for ideas:

function ZO_GamepadTradingHouse:DeactivateTextSearch()
	TEXT_SEARCH_MANAGER:DeactivateTextSearch("guildTraderTextSearch")
	TEXT_SEARCH_MANAGER:UnregisterCallback("UpdateSearchResults", self.onTextSearchResults)
	self:SetTextSearchEntryHidden(true)
end
]]

	-- Deactivate header. TODO? Do we need this?

--[[
	if self.header.tabBar.active and self.header.tabBar.Deactivate then
		self.header.tabBar:Deactivate ()
	end]]

	ZO_GamepadGenericHeader_Deactivate(self.header)

	-- Deactivate the infoPanel.

	if self.infoPanelGridList then
		self.infoPanel:ExitGridList ()
	end

	if self.infoPanel then
		self.infoPanel:SetHidden (true)
	end
	-- Deactivate any dropdowns.

	-- Disable keybinds. ZO_Gamepad_ParametricList_Screen:OnStateChanged does this for us.

	-- Unregister any event handlers.

	-- Reset tooltips.

	GAMEPAD_TOOLTIPS:Reset (GAMEPAD_LEFT_TOOLTIP)
	GAMEPAD_TOOLTIPS:Reset (GAMEPAD_RIGHT_TOOLTIP)

	-- Deactivate main list. ZO_Gamepad_ParametricList_Screen:OnStateChanged does this for us.

	Debug.Msg (3, ADDON_DEBUG_NAME, "LSG_OH", "Completed.")

end


--[[ Moved functionality back to PerformUpdate to better handle asynchronous loops.
function ListScreenGamepad:UpdateList ()

	Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_UL", "Called.")

	if not self.referenceList or #self.referenceList == 0 or DBLOOKUP:GetLastUpdateTime () > self.lastReferenceUpdate then
		self:RefreshReferenceList ()
	end

	local currentList = self:GetCurrentList ()

	if currentList and currentList == self.list then
		currentList:Clear ()
		self:RefreshDynamicList ()
		currentList:Commit ()
	end

	Debug.Msg (1, ADDON_DEBUG_NAME, "LSG_UL", "Completed.")

end
]]

-- A function, which must be overridden in a sub-class, which should add items to the list(s) as well as any other updates which are needed, such as updating the header or keybindstrip. In all cases, this should set self.dirty to false.

function ListScreenGamepad:PerformUpdate ()

	Debug.Msg (2, ADDON_DEBUG_NAME, "LSG_PU", "Called. Dirty flag is %sset.", self.dirty and "" or "not ")

	GAMEPAD_TOOLTIPS:Reset(GAMEPAD_LEFT_TOOLTIP)
	GAMEPAD_TOOLTIPS:Reset(GAMEPAD_RIGHT_TOOLTIP)

	local currentTabBarData = self.header.tabBar:GetTargetData ()

	self.currentFilterType = currentTabBarData.filterType
	self.currentTabFilterIndex = currentTabBarData.tabFilterIndex

	if not self.referenceList or #self.referenceList == 0 or DBLOOKUP:GetLastUpdateTime () > self.lastReferenceUpdate + 2000 then -- Give a couple of seconds so we don't refresh after every single item in the database is changed.
		self:RefreshReferenceList ()
	elseif self:GetCurrentList () == self.list then
		self:RefreshDynamicList ()
	end

	self.dirty = false

	Debug.Msg (3, ADDON_DEBUG_NAME, "LSG_PU", "Completed.")

end


-- ============================ [ Instantiator ] =========================== --


-- Called from XML "LuXhrys_VaultAndCoffer_GamepadInventoryTopLevel"

function LUXHRYS.VaC_ListScreen_Gamepad_OnInitialize (control)
	Debug.Msg (2, ADDON_DEBUG_NAME, "LSG_OI", "UI initializing.")
	LUXHRYS.LISTSCREEN_GAMEPAD = ListScreenGamepad:New (control)
	Debug.Msg (2, ADDON_DEBUG_NAME, "LSG_OI", "UI initialized.")
end


-- =========================== [ Initialization ] ========================== --


-- Some "classes" rely on OPTIONS or use saved variables, which cannot be
-- initialized until EVENT_ADD_ON_LOADED.

local function InitializeListScreen (_, addonName)
	if addonName and addonName == ADDON_NAME then
		Debug.Msg (1, ADDON_DEBUG_NAME, "ILS", "Initializing %s.", ADDON_CHUNK_NAME)
		OPTIONS = LUXHRYS.OPTIONS
		DBLOOKUP = LUXHRYS.DBLOOKUP
		COLORS = LUXHRYS.COLORS
		TOOLTIPS_GAMEPAD = LUXHRYS.TOOLTIPS_GAMEPAD
		CreateMainMenuEntry ()
		EVENT_MANAGER:UnregisterForEvent (ADDON_DEBUG_NAME, EVENT_ADD_ON_LOADED)
		Debug.Msg (1, ADDON_DEBUG_NAME, "ILS", "%s initialization complete.", ADDON_CHUNK_NAME)
	end
end

EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_ADD_ON_LOADED, InitializeListScreen)
