
--[[ LuXhrys Modular Add-On System ]]
--[[ Written by Xhrysanth (PSNA) ]]
--[[ Vault and Coffer ]]
--[[ VACTooltips.lua ]]
--[[ LOAD ORDER FIRST ]]


--[[ DISCLAIMER
This Add-on is not created by, affiliated with, or sponsored by, ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
]]

--[[ Information, attribution, copyright, and license:
This file is part of the core module for the LuXhrys add-on system for the Elder Scrolls Online.

This code chunk contains tooltip functions for the LuXhrys add-on system for the Elder Scrolls Online.

Written and copyright (c) 2026 by Xhrysanth (PSNA). License terms to be determined. Currently, and until this notice changes, all rights are reserved, except those that belong to ZeniMax Media Inc., which provides the API used by this software.
]]


--[[ =========================> AUTHORIZATION <=========================== ]]--


do
	local playerName = GetDisplayName ()

	assert (playerName == "@Xhrysanth" or playerName == "Xhrysanth", string.format ("[LuXhrysVaCT] CRIT: Not an authorized user. This chunk will not be loaded."))
end


--[[ ==========================> DECLARATIONS <=========================== ]]--


-- ============================= [ Namespace ] ============================= --


assert (LUXHRYS.LXI ~= nil, string.format ("[LuXhrysVaCT] CRIT: LuXhrysLXIO not available. This chunk will not be loaded."))
--assert (LUXHRYS.DBLOOKUP ~= nil, string.format ("[LuXhrysVaCT] CRIT: LuXhrysLXID not available. This chunk will not be loaded."))


-- ============================== [ Metadata ] ============================= --


local ADDON_SYSTEM_NAME = LUXHRYS.METADATA.ADDON_SYSTEM_NAME
local ADDON_AUTHOR = LUXHRYS.METADATA.ADDON_AUTHOR
local ADDON_COPYRIGHT_AND_LICENSE = LUXHRYS.METADATA.ADDON_COPYRIGHT_AND_LICENSE
local ADDON_DISCLAIMER = LUXHRYS.METADATA.ADDON_DISCLAIMER
local ADDON_DESCRIPTION = LUXHRYS.METADATA.ADDON_DESCRIPTION

local ADDON_MODULE_NAME = "VaultAndCoffer"
local ADDON_MODULE_SHORT_NAME = "VaC"
local ADDON_NAME = ADDON_SYSTEM_NAME .. ADDON_MODULE_NAME
local ADDON_MODULE_VERSION = "0.2a" -- Can we substitute with reading a var provided by the API?
local ADDON_MODULE_DESCRIPTION = "Inventory UI for the LuXhrys add-on system for the Elder Scrolls Online."

LUXHRYS.VAC = {}

LUXHRYS.VAC.METADATA =
{
	ADDON_MODULE_NAME = ADDON_MODULE_NAME,
	ADDON_MODULE_SHORT_NAME = ADDON_MODULE_SHORT_NAME,
	ADDON_NAME = ADDON_NAME,
	ADDON_MODULE_VERSION = ADDON_MODULE_VERSION,
	ADDON_MODULE_DESCRIPTION = ADDON_MODULE_DESCRIPTION
}

local ADDON_CHUNK_NAME = "Tooltips"
local ADDON_CHUNK_SHORT_NAME = "T"
local ADDON_DEBUG_NAME = ADDON_SYSTEM_NAME .. ADDON_MODULE_SHORT_NAME .. ADDON_CHUNK_SHORT_NAME


-- ===================== [ Localize Global Functions ] ===================== --


-------------------------------------------------------------------------------
--| C functions |--------------------------------------------------------------
-------------------------------------------------------------------------------


local GetItemLink = GetItemLink
local GetItemId = GetItemId
--local GetItemLinkItemType = GetItemLinkItemType
--local GetSlotStackSize = GetSlotStackSize
--local GetPlacedFurnitureLink = GetPlacedFurnitureLink
local GetItemLinkItemId = GetItemLinkItemId
--local GetCollectibleIdFromFurnitureId = GetCollectibleIdFromFurnitureId
--local GetCollectibleLink = GetCollectibleLink
--local GetCurrentZoneHouseId = GetCurrentZoneHouseId
local IsOwnerOfCurrentHouse = IsOwnerOfCurrentHouse
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
--local GetHouseCategoryType = GetHouseCategoryType
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
--local StringToId64 = StringToId64
--local GetGameTimeMilliseconds = GetGameTimeMilliseconds
--local GetString = GetString

--local GetItemLinkDisplayQuality = GetItemLinkDisplayQuality
--local GetItemLinkIcon = GetItemLinkIcon
--local GetItemLinkName = GetItemLinkName

local GetUnitActiveMundusStoneBuffIndices = GetUnitActiveMundusStoneBuffIndices
local GetUnitBuffInfo = GetUnitBuffInfo
local GetAbilityNumDerivedStats = GetAbilityNumDerivedStats
local GetAbilityDerivedStatAndEffectByIndex = GetAbilityDerivedStatAndEffectByIndex

local CompareItemLinkToCurrentlyEquipped = CompareItemLinkToCurrentlyEquipped

local GetString = GetString
local GetPlayerStat = GetPlayerStat
local GetCriticalStrikeChance = GetCriticalStrikeChance

local GetColorizedIcon = GetColorizedIcon
local GetColorizedText = GetColorizedText


-------------------------------------------------------------------------------
--| ZOS Lua functions |--------------------------------------------------------
-------------------------------------------------------------------------------


--local HasUnlockedFurnitureVault = ZO_HousingEditorState.HasUnlockedFurnitureVault
--local HousingEditorState = ZO_HousingEditorState
--local ParseLink = ZO_LinkHandler_ParseLink
--local zo_iconFormat = zo_iconFormat
--local ZO_Alert = ZO_Alert
--local ClearTable = ZO_ClearTable

local zo_strformat = zo_strformat
local ZO_GetStatDeltaLookupFromItemComparisonReturns = ZO_GetStatDeltaLookupFromItemComparisonReturns
local zo_iconTextFormatNoSpaceAlignedRight = zo_iconTextFormatNoSpaceAlignedRight
local zo_iconTextFormatNoSpace = zo_iconTextFormatNoSpace

local ZO_InitializingObject = ZO_InitializingObject
local zo_iconFormatInheritColor = zo_iconFormatInheritColor
local ZO_Tooltip_AddDivider = ZO_Tooltip_AddDivider

--ZO_INVENTORY_STAT_GROUPS
--SI_STAT_NAME_FORMAT
--ZO_STAT_MUNDUS_ICONS
--ZO_SORT_ORDER_UP


-------------------------------------------------------------------------------
--| Native Lua functions |-----------------------------------------------------
-------------------------------------------------------------------------------


--local TableRemove = table.remove
--local TableInsert = table.insert
local StrFormat = string.format


-------------------------------------------------------------------------------
--| From LXICommon |-----------------------------------------------------------
-------------------------------------------------------------------------------


--local optionDefaults = LUXHRYS.optionDefaults
--local OPTIONS = LUXHRYS.OPTIONS
local Debug = LUXHRYS.Debug
--local Startup = LUXHRYS.Startup
--local StrUtils = LUXHRYS.StrUtils
--local Alerts = LUXHRYS.Alerts
--local STATE = LUXHRYS.STATE
local Bag = LUXHRYS.Bag
local Location = LUXHRYS.Location
local LinkUtils = LUXHRYS.LinkUtils
local ItemKey = LUXHRYS.ItemKey
local ItemInfo = LUXHRYS.ItemInfo
local icons = LUXHRYS.icons
local COLORS

local BAG_PLACED_FURNISHINGS = Bag.BAG_PLACED_FURNISHINGS
local BAG_INBOX = Bag.BAG_INBOX
local BAG_TRADER = Bag.BAG_TRADER

local LOCATION_TYPE_FILTER_MIN = Location.LOCATION_TYPE_FILTER_MIN

-------------------------------------------------------------------------------
--| From LXIDatabase |---------------------------------------------------------
-------------------------------------------------------------------------------


local DBLOOKUP



--| 7. Local vars for this module |--------------------------------------------


--local GI_SavedVars = ZO_Ingame_SavedVariables.Default["@Xhrysanth"]["$AccountWide"].GamepadInventory

--local playerAlreadyActivatedOnce = false
--local playerWasViewingInfoPanel = false

--local EXTENDED_INVENTORY_SCENE_GAMEPAD_NAME = "extended_inventory_list"


--[[ ============================> FUNCTIONS <============================ ]]--


-- ======================[ itemLink Stat Comparison ]======================= --


-- Custom item comparison function to accept itemLink instead of bagID/slotID.

function ZO_Tooltip:LayoutItemLinkStatComparison (itemLink, comparisonSlot)

	local statEffects = {}
	local activeMundusStoneBuffIndices = { GetUnitActiveMundusStoneBuffIndices("player") }
	for _, buffIndex in ipairs(activeMundusStoneBuffIndices) do
		local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", buffIndex)
		local numStatsForAbility = GetAbilityNumDerivedStats(abilityId)
		for i = 1, numStatsForAbility do
			local statType, effectValue = GetAbilityDerivedStatAndEffectByIndex(abilityId, i)
			local statEffect =
			{
					statType = statType,
					effect = effectValue,
			}
			table.insert(statEffects, statEffect)
		end
	end

	local statDeltaLookup

	statDeltaLookup = ZO_GetStatDeltaLookupFromItemComparisonReturns(CompareItemLinkToCurrentlyEquipped(itemLink, comparisonSlot))

	for _, statGroup in ipairs(ZO_INVENTORY_STAT_GROUPS) do
		local statSection = self:AcquireSection(self:GetStyle("itemComparisonStatSection"))
		for _, stat in ipairs(statGroup) do
			local statName = zo_strformat(SI_STAT_NAME_FORMAT, GetString("SI_DERIVEDSTATS", stat))
			local currentValue = GetPlayerStat(stat)
			local statDelta = statDeltaLookup[stat] or 0
			local valueToShow = currentValue + statDelta

			local isMundusStat = false
			for _, statEffect in ipairs(statEffects) do
				if stat == statEffect.statType then
					isMundusStat = true
				end
			end

			if stat == STAT_SPELL_CRITICAL or stat == STAT_CRITICAL_STRIKE then
				local newPercent = GetCriticalStrikeChance(valueToShow)
				valueToShow = zo_strformat(SI_STAT_VALUE_PERCENT, newPercent)
			end

			local colorStyle = self:GetStyle("itemComparisonStatValuePairDefaultColor")
			if statDelta ~= 0 then
				local icon
				if statDelta > 0 then
					colorStyle = self:GetStyle("succeeded")
					icon = "EsoUI/Art/Buttons/Gamepad/gp_upArrow.dds"
				else
					colorStyle = self:GetStyle("failed")
					icon = "EsoUI/Art/Buttons/Gamepad/gp_downArrow.dds"
				end
				local INHERIT_COLOR = true
				local NO_GRAMMAR = true
				valueToShow = zo_iconTextFormatNoSpaceAlignedRight(icon, 24, 24, valueToShow, INHERIT_COLOR, NO_GRAMMAR)
			end

			if isMundusStat then
				valueToShow = zo_iconTextFormatNoSpace(ZO_STAT_MUNDUS_ICONS[MUNDUS_STONE_INVALID], 24, 24, valueToShow)
			end

			local statValuePair = statSection:AcquireStatValuePair(self:GetStyle("itemComparisonStatValuePair"))
			statValuePair:SetStat(statName, self:GetStyle("statValuePairStat"))
			statValuePair:SetValue(valueToShow, self:GetStyle("itemComparisonStatValuePairValue"), colorStyle)
			statSection:AddStatValuePair(statValuePair)
		end
		self:AddSection(statSection)
	end
end


--===============================| Tooltips |================================--


-------------------------------------------------------------------------------
--| Common tooltip functions for both keyboard/mouse and gamepad |-------------
-------------------------------------------------------------------------------



-------------------------------------------------------------------------------
--| Gamepad tooltip functions |------------------------------------------------
-------------------------------------------------------------------------------


local TooltipsGamepad = ZO_InitializingObject:Subclass ()


--local function GetGamepadTooltipFormattedStackCountString (iconTexture, iconColor, quantity, textColor)
local function GetGamepadTooltipFormattedStackCountString (iconTexture, quantity, narrationString)
	local stackCountString = StrFormat ("%s %s", COLORS:GetColorizedIcon (iconTexture, 24, 24), COLORS:GetColorizedText (quantity))
	narrationString = StrFormat (SI_GAMEPAD_INVENTORY_STACK_COUNT_NARRATION_FORMATTER, GetString (narrationString), quantity)
	return stackCountString, narrationString
end

--[[
function TooltipsGamepad:OnAddTopLinesToTopSection (topSection, itemLink, showPlayerLocked, tradeBoPData)
	Debug.Msg (1, ADDON_DEBUG_NAME, "TG_OATLTTS", "Called. itemLink is %s.", tostring (LinkUtils.StripItemLink (itemLink)))
	self.hookedItemLink = itemLink
	self.hookedAddTopLinesToTopSectionCalled = true
	return false -- let the hooked function continue normally.
end
]]




--[[	OnAddSectionEvenIfEmpty (): This function can be called from many places and we need to make sure that we hook the one being called
			from AddTopLinesToTopSection (). Once we get a succsssful hook, we add additional item counts before section is added to tooltip. ]]--
--[[
function TooltipsGamepad:OnAddSectionEvenIfEmpty (object, tooltipSectionToModify)

  -- Filter out calls that don't come from ZO_TooltipSection:AddTopLinesToTopSection () using the flag.

  if not self.hookedAddTopLinesToTopSectionCalled then
    return false -- let the hooked function continue normally.
  end

--	d (string.format("[ExtInv] Gamepad tooltip being created for item %s.", hookedItemLink))

	local narrationText = StrFormat (SI_GAMEPAD_INVENTORY_STACK_COUNT_NARRATION_FORMATTER, GetString (SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_BANK), "8") -- TODO: get local version of strformat

	-- Trial 1

	local greenCountColor = ZO_ColorDef:New ((163/255), 1, (218/255), 1)
	local greenIconColor = ZO_ColorDef:New ((139/255), (217/255), (186/255), 1)

	local quantity = Tint_MintGreen.BASE_TEXT_WHITE:Colorize ("8")
	tooltipSectionToModify:AddLineWithCustomNarration (zo_iconTextFormat (icons.tooltipStackCount[BAG_FURNITURE_VAULT], 24, 24, quantity), narrationText)
	tooltipSectionToModify:AddLineWithCustomNarration (Tint_MintGreen.BASE_TEXT_WHITE:Colorize (zo_iconTextFormat (icons.tooltipStackCount[BAG_PLACED_FURNISHINGS], 24, 24, "17", true), narrationText)) -- <-- This works for the icon too!

	-- Trial 2

	local testIcon = zo_iconFormatInheritColor (icons.tooltipStackCount[BAG_COMPANION_WORN], 24, 24)
	testIcon = greenIconColor:Colorize (testIcon)

	local testString = StrFormat ("%s %s", testIcon, Tint_MintGreen.BASE_TEXT_WHITE:Colorize ("73"))

	tooltipSectionToModify:AddLineWithCustomNarration (testString, narrationText)

	-- Trial 3

--	tooltipSectionToModify:AddLine ("T2") -- <-- This is the correct one!

--	tooltipSectionToModify:AddLineWithCustomNarration (GetGamepadTooltipFormattedStackCountString (icons.tooltipStackCount[BAG_TRADER], 33))


--	local otherCharacterWornCount, otherCharacterBackPackCount, guildBankCount, buybackCount, collectibleHousingStorageCount, companionWornCount, furnitureVaultCount, vengeanceCount, placedFurnitureCount, mailboxCount, guildTraderCount = DBLOOKUP:GetExtendedStackCount (self.hookedItemLink)

	local extendedStackCounts = { DBLOOKUP:GetExtendedStackCount (self.hookedItemLink) }

	for i = 1, #extendedStackCounts do
		if extendedStackCounts[i] > 0 then
			tooltipSectionToModify:AddLineWithCustomNarration (GetGamepadTooltipFormattedStackCountString (icons.tooltipStackCount[extendedStackCountBags[i](((((( NEED ANOTHER ] HERE!!!! )))))), extendedStackCounts[i], Bags.GetName (extendedStackCountBags[i], true)))
		end
	end


	if otherCharacterWornCount > 0 then
		tooltipSectionToModify:AddLineWithCustomNarration (GetGamepadTooltipFormattedStackCountString (icons.tooltipStackCount[BAG_WORN], otherCharacterWornCount, GAMEPAD_INVENTORY_STACK_COUNT_BAG_WORN))
	end
	if otherCharacterBackPackCount > 0 then
		tooltipSectionToModify:AddLineWithCustomNarration (GetGamepadTooltipFormattedStackCountString (icons.tooltipStackCount[BAG_BACKPACK], otherCharacterBackPackCount, SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_BACKPACK))
	end
	if guildBankCount > 0 then
		tooltipSectionToModify:AddLineWithCustomNarration (GetGamepadTooltipFormattedStackCountString (icons.tooltipStackCount[BAG_GUILDBANK], guildBankCount, GAMEPAD_INVENTORY_STACK_COUNT_BAG_GUILDBANK))
	end
	if buybackCount > 0 then
		tooltipSectionToModify:AddLineWithCustomNarration (GetGamepadTooltipFormattedStackCountString (icons.tooltipStackCount[BAG_BUYBACK], buybackCount, GAMEPAD_INVENTORY_STACK_COUNT_BAG_BUYBACK))
	end
	if collectibleHousingStorageCount > 0 then
		tooltipSectionToModify:AddLineWithCustomNarration (GetGamepadTooltipFormattedStackCountString (icons.tooltipStackCount[BAG_HOUSE_BANK_ONE], collectibleHousingStorageCount, SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_HOUSE_BANK))
	end
	if companionWornCount > 0 then
		tooltipSectionToModify:AddLineWithCustomNarration (GetGamepadTooltipFormattedStackCountString (icons.tooltipStackCount[BAG_COMPANION_WORN], companionWornCount, GAMEPAD_INVENTORY_STACK_COUNT_BAG_COMPANION_WORN))
	end
	if furnitureVaultCount > 0 then
		tooltipSectionToModify:AddLineWithCustomNarration (GetGamepadTooltipFormattedStackCountString (icons.tooltipStackCount[BAG_FURNITURE_VAULT], furnitureVaultCount, SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_FURNITURE_VAULT))
	end
	if vengeanceCount > 0 then
		tooltipSectionToModify:AddLineWithCustomNarration (GetGamepadTooltipFormattedStackCountString (icons.tooltipStackCount[BAG_VENGEANCE], vengeanceCount, SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_VENGEANCE))
	end
	if mailboxCount > 0 then
		tooltipSectionToModify:AddLineWithCustomNarration (GetGamepadTooltipFormattedStackCountString (icons.tooltipStackCount[BAG_INBOX], mailboxCount, Bag.GetName (BAG_INBOX, true)))
	end
	if guildTraderCount > 0 then
		tooltipSectionToModify:AddLineWithCustomNarration (GetGamepadTooltipFormattedStackCountString (icons.tooltipStackCount[BAG_TRADER], guildTraderCount, Bag.GetName (BAG_TRADER, true)))
	end
	if placedFurnitureCount > 0 then
		tooltipSectionToModify:AddLineWithCustomNarration (GetGamepadTooltipFormattedStackCountString (icons.tooltipStackCount[BAG_PLACED_FURNISHINGS], placedFurnitureCount, Bag.GetName (BAG_PLACED_FURNISHINGS, true)))
	end


--	hookedTopSubsection = nil
	self.hookedItemLink = nil
	self.hookedAddTopLinesToTopSectionCalled = false

--	d ("XT variables reset.")

	return false -- let the hooked function continue normally.

end
]]

function TooltipsGamepad:Initialize ()

	Debug.Msg (4, ADDON_DEBUG_NAME, "TG_I", "Setting itemLink to nil and hATLTTS to false.")
	self.hookedItemLink = nil
--	self.hookedAddTopLinesToTopSectionCalled = false


	local function OnAddTopLinesToTopSection (object, topSection, itemLink, showPlayerLocked, tradeBoPData)
		Debug.Msg (2, ADDON_DEBUG_NAME, "TG_OATLTTS", "Called. itemLink is %s (%s). from ListScreen? %s", tostring (LinkUtils.StripItemLink (itemLink)), tostring (itemLink), tostring (self.listScreenTooltip ~= nil))
		self.hookedItemLink = itemLink and ItemKey.Get (itemLink) or nil
--		self.hookedAddTopLinesToTopSectionCalled = itemLink and true or false
		return false -- let the hooked function continue normally.
	end

	local function OnAddSectionEvenIfEmpty (object, tooltipSectionToModify)
		Debug.Msg (4, ADDON_DEBUG_NAME, "TG_OASEIE", "Called. hATLTTS called? %s. itemLink is %s. from ListScreen? %s", tostring (self.hookedItemLink ~= nil), tostring (LinkUtils.StripItemLink (self.hookedItemLink)), tostring (self.listScreenTooltip))

		local itemLink = self.listScreenTooltip or self.hookedItemLink

--		if not self.listScreenTooltip and not self.hookedAddTopLinesToTopSectionCalled then
--		if self.listScreenTooltip then
--			itemLink = self.listScreenTooltip
--		elseif self.hookedItemLink then
--			itemLink = self.hookedItemLink
--		else
		if not itemLink then
			return false -- let the hooked function continue normally.
		end

		Debug.Msg (4, ADDON_DEBUG_NAME, "TG_OASEIE", "DBLOOKUP exists: %s. GII exists: %s.", (DBLOOKUP ~= nil and "True" or "False"), (DBLOOKUP.GetItemInfo ~= nil and "True" or "False"))

--		Debug.Msg (4, ADDON_DEBUG_NAME, "TG_OASEIE", "itemLink is %s. ItemInfo is %s.", tostring (LinkUtils.StripItemLink (itemLink)), tostring (DBLOOKUP.GetItemInfo (itemLink)))

		-- For extended stack counts, these are used only for the tooltip, where the current character's inventory is not included. The List Screen gets them independently and includes all characters. Here, we should include the inventory for other characters only for bags where the base game will show its own counts, and skip bags entirely that the base game will show. This means the backpack should only include other characters' counts, and we should show housing storage and furniture vault only when not in a house we own.

--		Debug.Msg (1, ADDON_DEBUG_NAME, "TG_OASEIE", "Calling II_GESC with itemLink %s; itemInfo %s; itemKey %s", itemLink,  ))

		local extendedStackCounts = { ItemInfo.GetExtendedStackCounts (DBLOOKUP.GetItemInfo (ItemKey.Get (itemLink)), false) }
--		local extendedStackCounts = { ItemInfo.GetExtendedStackCounts (DBLOOKUP.GetItemInfo (itemLink), self.listScreenTooltip ~= nil) }
--/script d (LUXHRYS.ItemInfo.GetExtendedStackCounts (LUXHRYS.DBLOOKUP:GetItemInfo (tostring (LUXHRYS.TOOLTIPS_GAMEPAD.hookedItemLink))))

--[[
if self.listScreenTooltip then
d (extendedStackCounts)
end
]]

		for i = 1, #extendedStackCounts do -- Skip LOCATION_TYPE_FILTER_ALL

--[[
			if self.listScreenTooltip then


			Debug.Msg (1, ADDON_DEBUG_NAME, "TG_OASEIE", "itemLink is %s. Stack count %d/%d is %s.",
				tostring (LinkUtils.StripItemLink (itemLink)),
				i,
				#extendedStackCounts,
				extendedStackCounts[i]
			)
			end
]]

			if extendedStackCounts[i] > 0 then
--				if (i + 1 == LOCATION_TYPE_FILTER_COLLECTIBLE_STORAGE or i + 1 == LOCATION_TYPE_FILTER_FURNITURE_VAULT)
--				and IsOwnerOfCurrentHouse ()
				if not IsOwnerOfCurrentHouse ()
				or (i + 1 ~= LOCATION_TYPE_FILTER_COLLECTIBLE_STORAGE and i + 1 ~= LOCATION_TYPE_FILTER_FURNITURE_VAULT)
				then
--				else
					tooltipSectionToModify:AddLineWithCustomNarration (
						GetGamepadTooltipFormattedStackCountString (
	--						icons.tooltipStackCount[i],
							Location.locationTypeFilters[i + 1].tooltipIcon,
							extendedStackCounts[i],
	--						Bag.GetName (self.extendedStackCountBags[i], true)
							Bag.GetName (Location.locationTypeFilters[i + 1].bag, true)
						)
					)
				end
			end
		end

		Debug.Msg (4, ADDON_DEBUG_NAME, "TG_OASEIE", "setting itemLink to nil and hATLTTS to false.")

		self.hookedItemLink = nil
		self.listScreenTooltip = nil
--		self.hookedAddTopLinesToTopSectionCalled = false

		return false -- let the hooked function continue normally.

	end


	ZO_PreHook (ZO_Tooltip, "AddTopLinesToTopSection", OnAddTopLinesToTopSection)
	ZO_PreHook (ZO_TooltipSection, "AddSectionEvenIfEmpty", OnAddSectionEvenIfEmpty)


end


function TooltipsGamepad:CallingListScreenTooltip (itemLink)
	self.listScreenTooltip = itemLink
end


-------------------------------------------------------------------------------
--| Keyboard/mouse tooltip functions |-----------------------------------------
-------------------------------------------------------------------------------


local TooltipsKeyboard = ZO_InitializingObject:Subclass ()


local function GetKeyboardTooltipFormattedStackCountString (iconTexture, iconColor, quantity, textColor)
	local stackCountString = iconColor:Colorize (zo_iconFormatInheritColor (iconTexture, 24, 24))
	stackCountString = StrFormat ("%s %s", stackCountString, textColor:Colorize (quantity))
	return stackCountString
end



--[[ OnOnAddGameData () -- MAYBE USEFUL LATER
	Trying to write into the top section after any function causes formatting
	problems, but hooking OnAddGameDate () and writing the second time it is
	called may be a way to write below the item name and divider.


local function OnOnAddGameData (tooltip, gameDataType)

	d ("1. OnOnAddGameData called.")

--	d ("Child:", ItemTooltip:GetNamedChild ("StackCount"))
--d (tooltipControl)

		tooltip:AddLine ("")
		tooltip:AddLine ("")
		tooltip:AddLine ("")
		tooltip:AddLine ("")


		ItemTooltip:AddLine ("OAGD: ItemTooltip. ItemTooltip. ItemTooltip.")
		tooltip:AddLine ("OAGD: tooltip. tooltip. tooltip.")

--	tooltipControl:AddDivider ()
--	tooltipControl:AddLine ("Test text.")

	return false

end
]]

local function OnInitializeTooltip (tooltip)

	Debug.Msg (3, ADDON_DEBUG_NAME, "IPG_I", "Called.")
d (ItemTooltip, tooltip)

--	ZO_Tooltip_AddDivider(tooltip)
--	ItemTooltip:AddLine ("OIT: ItemTooltip. ItemTooltip. ItemTooltip.")
--	tooltip:AddLine ("OIT: tooltip. tooltip. tooltip.")

--	local r, g, b = Tint_MintGreen.BASE_ICON_WHITE:UnpackRGB()

	ItemTooltip:AddHeaderLine("OIT: ItemTooltip", "ZoFontWinH5", 1, TOOLTIP_HEADER_SIDE_RIGHT, COLORS:GetCurrentTextRGBValues ())
	tooltip:AddHeaderLine("OIT: tooltip", "ZoFontWinH5", 1, TOOLTIP_HEADER_SIDE_RIGHT, COLORS:GetCurrentTextRGBValues ())

	return false

end


--[[ PROBABLY REMOVE
function OnLayoutItem (tooltip)

	d ("OnLayoutItem called.", tooltip)
	d (tooltip:GetNamedChild ("topSubsectionItemDetails"))


	return false

end
]]


--[[ ItemTooltip children

	ItemTooltipBG
	ItemTooltipCharges
	ItemTooltipCondition
	ItemTooltipSellPrice
	ItemTooltipFadeLeft
	ItemTooltipFadeRight
	ItemTooltipIcon

	all children beyond this return nil objects. There are always at least 23 children.
]]

--[[ OnSetBagItem (): main tooltip function for keyboard and mouse.
	Hooking SetBagItem () appears to be the most useful because the hook only
	fires once and using this object writes to the bottom of the tooltip.

	ItemTooltip:SetBagItem(bag, index, ITEM_TOOLTIP_DISPLAY_FLAGS_SHOW_SUPPRESSION)

]]


local function OnSetBagItem (tooltipControl, bagID, slotIndex)

--[[ ALL DEBUG CODE
	d ("3. OnSetBagItem called.", tooltip)
	d (tooltip)
	ItemTooltip:AddLine ("OSBI: ItemTooltip. ItemTooltip. ItemTooltip.")
	tooltip:AddLine ("OSBI: tooltip. tooltip. tooltip.")

	d ("tooltip: ", tooltip)
	d ("ItemTooltip: ", ItemTooltip)
	local numChildren = ItemTooltip:GetNumChildren ()

	d ("# children:", numChildren)

	for i = 1, numChildren do
		child = ItemTooltip:GetChild (i)
		if not child then
			d("Child not visible:", i)
		else
			d ("Child:", child, child:GetName ())
		end
	end
]]

	Debug.Msg (1, ADDON_DEBUG_NAME, "OSBI", "OnSetBagItem called on item tooltip %s.", tostring(tooltipControl))

	local itemLink = GetItemLink (bagID, slotIndex)
	local itemID = GetItemId (bagID, slotIndex)

	tooltipControl:AddLine ()
	ZO_Tooltip_AddDivider (tooltipControl)

	Debug.Msg (1, ADDON_DEBUG_NAME, "OSBI", "Keyboard/mouse item tooltip being created for item %s with link %s.", itemID, itemLink)
	tooltipControl:AddLine (StrFormat("OSBI: tooltip for item %s.", itemID))


--	local icon = Tint_MintGreen.BASE_ICON_WHITE:Colorize (zo_iconFormatInheritColor ("EsoUI/Art/Tooltips/icon_house_bank.dds", 24, 24))
	local icon = GetColorizedIcon (icons.tooltipStackCount.BAG_GUILD_BANK, 24, 24)
--	tooltipControl:AddLine (GetIconAndCountString (icon, 37, Tint_MintGreen.BASE_TEXT_WHITE))
	tooltipControl:AddLine (StrFormat ("%s %s", icon, GetColorizedText (37)))

	return false

end


local function OnSetLink (tooltipControl, itemLink)

	Debug.Msg (1, ADDON_DEBUG_NAME, "OSL", "OnSetLink called on popup tooltip %s.", tostring(tooltipControl))


--	itemLink = tooltipControl.lastLink
	local itemID = GetItemLinkItemId (itemLink)

	tooltipControl:AddLine ()
	ZO_Tooltip_AddDivider (tooltipControl)

	Debug.Msg (1, ADDON_DEBUG_NAME, "OSL", "Keyboard/mouse popup tooltip being created for item %s with link %s.", itemID or "nil", itemLink or "nil")
	tooltipControl:AddLine (string.format("OSL: tooltip for item %s.", itemID or "nil"))


--	local icon = Tint_MintGreen.BASE_ICON_WHITE:Colorize (zo_iconFormatInheritColor ("EsoUI/Art/Tooltips/icon_house_bank.dds", 24, 24))
	local icon = GetColorizedIcon (icons.tooltipStackCount.BAG_VIRTUAL, 24, 24)
--	tooltipControl:AddLine (GetIconAndCountString (icon, 37, Tint_MintGreen.BASE_TEXT_WHITE))
	tooltipControl:AddLine (StrFormat ("%s %s", icon, GetColorizedText (42)))

	return false

end


--LUXHRYS.TOOLTIPS_KEYBOARD = TooltipsKeyboard:New ()


-- =========================== [ Initialization ] ========================== --


-- Some "classes" rely on OPTIONS or use saved variables, which cannot be
-- initialized until EVENT_ADD_ON_LOADED.

local function InitializeTooltips (_, addonName)
	if addonName and addonName == ADDON_NAME then
		Debug.Msg (1, ADDON_DEBUG_NAME, "IT", "Initializing %s.", ADDON_CHUNK_NAME)

		COLORS = LUXHRYS.COLORS
		DBLOOKUP = LUXHRYS.DBLOOKUP
		LUXHRYS.TOOLTIPS_GAMEPAD = TooltipsGamepad:New ()

		EVENT_MANAGER:UnregisterForEvent (ADDON_DEBUG_NAME, EVENT_ADD_ON_LOADED)

		Debug.Msg (1, ADDON_DEBUG_NAME, "IT", "%s initialization %s.", ADDON_CHUNK_NAME, LUXHRYS.TOOLTIPS_GAMEPAD ~= nil and "successful" or "failed")
	end
end


EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_ADD_ON_LOADED, InitializeTooltips)




