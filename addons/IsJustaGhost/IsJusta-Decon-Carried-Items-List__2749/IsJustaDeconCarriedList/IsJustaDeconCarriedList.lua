--[[

- - - 3.3.2
○ patched filtering to prioritize enabled filters

- - - 3.3.1
○ patched filtering to not always include the default filter

- - - 3.3
○ changed how initializing per system object is handled
○ added option to prevent stolen items from being added with "Add All".
○ added, allow stolen by quality, filter

- - - 3.2.6
○ removed debug output

- - - 3.2.5
○ compatibility update

- - - 3.2.4
○ stepping up the version to make sure it does not conflict with being updated by clients

- - - 3.2.3
○ removed debug messages
○ chagned when the setting for include banked items is set
○ hid the include bank check box in keyboard mode
○ fixed resetting to show banked
○ 

- - - 3.2.2
○ fixed BOP and trad-able dialoge not showing when warn is active.
○ fixed keyboard mode not refreshing keybind when changing inventories
○ improved compatibility with Advacned Filters

- - - 3.2.1
○ fixed filtering so now filters are check in priority from top to bottom in the settings.
-- If a filter is enabled and, that item falls under a filter below it, the last filter will be the one used even if it's disabled.
-- If a researchable item falls under any other filter, it will be ignored if the filter researchable is disabled.
○ again, hoping that the Add All Keybind updates properly. Changed a variable in the check.

- - - 3.2
○ updated default filters to work with libFilters
○ added libFilters universalDeconTabKeyToLibFiltersFilterType of "carried" tab
○ added limited compatibility with Advanced Filters

- - - 3.1
○ fixed gamepad mode not letting category change in clothier station
○ fixed keyboard crafting stations causing error
○ Add All keybind now checks if extraction slot has items if un-added item would exceed max
-- this will properly change the keybind from Add ALl to Clear Selections.

- - - 3
○ simplified functionality to allow easier management
○ added option to allow filtered Add All to happen on open
]]
--[[
- - - 2.8
○ updated API version
○ added option to allow the inclusion of Bind on Pickup and Trade-able using a dialog
○ moved initializing default qualities to before savedvariables are initialized to allow resetting to default.
○ 

- - - 2.7.1
○ added filtering for Bind on Pickup and Tradeable

- - - 2.7
○ change how filtering is done
- each "trait" has it's own filter settings
○ 

- - - 2.6
○ added minimum quality to filters
○ updated API version


- - - 2.5.5
○ HOTFIX update for gamepad mode. No longer relying on the initial GetCurrentFilter check since it will cause errors for gamepad mode.
	Now IsCustomTab will handle discrepancies.


○ HOTFIX for gamepad mode. Implemented an overwrite to the newly added function to gamepad mode GetCurrentFilter
	this function was requested in order to make functionality match keyboard mode. However the function is incomplete.

- - - 2.5.3
○ HOTFIX for gamepad mode. Implemented an overwrite to the newly added function to gamepad mode GetCurrentFilter
	this function was requested in order to make functionality match keyboard mode. However the function is incomplete.


- - - 2.5.2
○ attempt to fix Advanced Filters conflict by removing some unused experimental lib functions.


- - - 2.5.1
○ attempt to fix Advanced Filters conflict.

- - - 2.5
○ completely rewrote the entire addon.
○ added support for the deconstruction assistant
-- the deconstruction assistant will now have a "Carried" tab.
○ automation improvement. If "Open to decon" is enabled, it will only do so if there are deconstruct-able items on you.
○ If "Auto open Assistant." is enabled, interacting with the decon assistant will auto enter deconstruct.
-- if deconstruct-able carried items are present, it will auto select the "Carried" tab.
○ added max item quality to requirements for automation, select-able in the settings.
○ 



-- further testing of exceedsMaxStack
TBUG.slashCommand(args)


]]

local addonData = {
	displayName = "|cFF00FFIsJusta|r |cffffffDecon Carried List|r",
	name = "IsJustaDeconCarriedList",
	prefix = "IJA_DCI",
	version = "3.3.2",
}

local defaults = {
	openToUni = false,
	addOnOpen = false,
	ignoreStolen = false,
	warnTradeable = false,
	ignoreTradeable = false,
	cleanRefinementTab = true,
	traitOptions = {},
}

local ADDON_SHORT_NAME = addonData.prefix

local svVersion = 2.7

---------------------------------------------------------------------------------------------------------------
-- Locals
---------------------------------------------------------------------------------------------------------------

local TAB_KEY = 'carried'
local PLATFORM_MODE_KB = 'keyboard'
local PLATFORM_MODE_GP = 'gamepad'
local INTERFACE_MODE = IsInGamepadPreferredMode() and PLATFORM_MODE_GP or PLATFORM_MODE_KB
local IS_ADD_ALL_VISIBLE
local HAS_DECONSTRUCTABLE

local CONFIRM_INCLUDE_BOB_AND_TRADEABLE_DIALOG = 'IJA_Decon_confirm_include_BOP_and_tradeable_dialog'

local savedVars
local Add_All = {}

---------------------------------------------------------------------------------------------------------------
-- Filters
---------------------------------------------------------------------------------------------------------------

local VAR_DEFAULT_STRING = GetString(SI_ITEM_RECONSTRUCTION_DEFAULT_TRAIT)

local function defaultQualityFilter(filter, displayQuality)
	return filter:PassesQuality(displayQuality)
end

local filterTable = {
	{ -- default
		name = VAR_DEFAULT_STRING,
		id = 'default',
	},
	{ -- stolen
		name = GetString(SI_GAMEPAD_ITEM_STOLEN_LABEL),
		id = 'stolen',
		disabledCondition = function() return savedVars.ignoreStolen end,
	},
	{ -- setItems
		name = GetString(SI_ITEM_SETS_BOOK_TITLE),
		id = 'setItems',
	},
	{ -- ITEM_TRAIT_INFORMATION_ORNATE
		name = GetString(SI_ITEMTRAITTYPE10),
		id = ITEM_TRAIT_INFORMATION_ORNATE,
	},
	{ -- ITEM_TRAIT_INFORMATION_INTRICATE
		name = GetString(SI_ITEMTRAITTYPE9),
		id = ITEM_TRAIT_INFORMATION_INTRICATE,
	},
	{ -- ITEM_TRAIT_INFORMATION_RETRAITED
		name = GetString('SI_ITEMTRAITINFORMATION', ITEM_TRAIT_INFORMATION_RETRAITED),
		id = ITEM_TRAIT_INFORMATION_RETRAITED,
	},
	{ -- ITEM_TRAIT_INFORMATION_RECONSTRUCTED
		name = GetString('SI_ITEMTRAITINFORMATION', ITEM_TRAIT_INFORMATION_RECONSTRUCTED),
		id = ITEM_TRAIT_INFORMATION_RECONSTRUCTED,
	},
	{ -- ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED
		name = GetString('SI_ITEMTRAITINFORMATION', ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED),
		id = ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED,
	},
}

local qualityFilters = {}

local VAR_QUALITY_DEFAULT_MIN = 0
local VAR_QUALITY_DEFAULT_MAX = 3

---------------------------------------------------------------------------------------------------------------

local CARRIED_DECONSTRUCTION_FILTER_TYPE = {
	key = TAB_KEY,
	filter = {
		bags = {
			BAG_BACKPACK
		},
	},
	displayName = GetString("SI_SMITHINGFILTERTYPE", IJA_SMITHING_FILTER_TYPE_CARRIED),
	iconUp = "EsoUI/Art/MainMenu/menuBar_inventory_up.dds",
	iconDown = "EsoUI/Art/MainMenu/menuBar_inventory_down.dds",
	iconOver = "EsoUI/Art/MainMenu/menuBar_inventory_over.dds",
	iconDisabled = "EsoUI/Art/MainMenu/menuBar_inventory_disabled.dds",
}

	--[[
		ZO_UNIVERSAL_DECONSTRUCTION_FILTER_TYPES[i] = {
			key = "all",
			filter = {
				itemTypes = {
					ITEMTYPE_GLYPH_ARMOR,
					ITEMTYPE_GLYPH_JEWELRY,
					ITEMTYPE_GLYPH_WEAPON,
					ITEMTYPE_ARMOR,
					ITEMTYPE_WEAPON,
				},
			},
			displayName = GetString("SI_ITEMTYPEDISPLAYCATEGORY", ITEM_TYPE_DISPLAY_CATEGORY_ALL),
			iconUp = "EsoUI/Art/Inventory/inventory_tabIcon_all_up.dds",
			iconDown = "EsoUI/Art/Inventory/inventory_tabIcon_all_down.dds",
			iconOver = "EsoUI/Art/Inventory/inventory_tabIcon_all_over.dds",
			iconDisabled = "EsoUI/Art/Inventory/inventory_tabIcon_all_disabled.dds",
		
		
		filterData.filter = {
            itemFilterTypes = {
				ITEMFILTERTYPE_ARMOR,
				ITEMFILTERTYPE_WEAPONS,
				ITEMFILTERTYPE_JEWELRY,
				ITEMFILTERTYPE_ENCHANTING,
            },
        }
	]]
		
-- Need to replace the "all" filter to include all items. Leaving it at nil will result in
-- when selecting "All" in keyboard mode will automatically select the carried tab.
for i, filterData in pairs(ZO_UNIVERSAL_DECONSTRUCTION_FILTER_TYPES) do
	if filterData.key == "all" then
		filterData.filter = {
			itemTypes = {
				ITEMTYPE_GLYPH_ARMOR,
				ITEMTYPE_GLYPH_JEWELRY,
				ITEMTYPE_GLYPH_WEAPON,
				ITEMTYPE_ARMOR,
				ITEMTYPE_WEAPON,
			},
		}
		
		break
	end
end

-- Add the "Carried" tab to the filters.
table.insert(ZO_UNIVERSAL_DECONSTRUCTION_FILTER_TYPES, CARRIED_DECONSTRUCTION_FILTER_TYPE)
--[[ original
ZO_UNIVERSAL_DECONSTRUCTION_FILTER_TYPES = {
	{ key = "enchantments",
		filter =
		{
			itemTypes =
			{
				ITEMTYPE_GLYPH_ARMOR,
				ITEMTYPE_GLYPH_JEWELRY,
				ITEMTYPE_GLYPH_WEAPON,
			},
		},
		displayName = GetString("SI_ITEMTYPEDISPLAYCATEGORY", ITEM_TYPE_DISPLAY_CATEGORY_GLYPH),
		iconUp = "EsoUI/Art/Inventory/inventory_tabIcon_Craftbag_enchanting_up.dds",
		iconDown = "EsoUI/Art/Inventory/inventory_tabIcon_Craftbag_enchanting_down.dds",
		iconOver = "EsoUI/Art/Inventory/inventory_tabIcon_Craftbag_enchanting_over.dds",
		iconDisabled = "EsoUI/Art/Inventory/inventory_tabIcon_Craftbag_enchanting_disabled.dds",
	},
	{ key = "jewelry",
		tooltipText = ZO_GetJewelryCraftingLockedMessage,
		enabled = ZO_IsJewelryCraftingEnabled,
		filter =
		{
			itemFilterTypes =
			{
				ITEMFILTERTYPE_JEWELRY,
			},
		},
		displayName = GetString("SI_SMITHINGFILTERTYPE", SMITHING_FILTER_TYPE_JEWELRY),
		iconUp = "EsoUI/Art/Crafting/jewelry_tabIcon_icon_up.dds",
		iconDown = "EsoUI/Art/Crafting/jewelry_tabIcon_down.dds",
		iconOver = "EsoUI/Art/Crafting/jewelry_tabIcon_icon_over.dds",
		iconDisabled = "EsoUI/Art/Crafting/jewelry_tabIcon_icon_disabled.dds",
	},
	{ key = "armor",
		filter =
		{
			itemFilterTypes =
			{
				ITEMFILTERTYPE_ARMOR,
			},
		},
		displayName = GetString("SI_SMITHINGFILTERTYPE", SMITHING_FILTER_TYPE_ARMOR),
		iconUp = "EsoUI/Art/Inventory/inventory_tabIcon_armor_up.dds",
		iconDown = "EsoUI/Art/Inventory/inventory_tabIcon_armor_down.dds",
		iconOver = "EsoUI/Art/Inventory/inventory_tabIcon_armor_over.dds",
		iconDisabled = "EsoUI/Art/Inventory/inventory_tabIcon_armor_disabled.dds",
	},
	{ key = "weapons",
		filter =
		{
			itemFilterTypes =
			{
				ITEMFILTERTYPE_WEAPONS,
			},
		},
		displayName = GetString("SI_SMITHINGFILTERTYPE", SMITHING_FILTER_TYPE_WEAPONS),
		iconUp = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_up.dds",
		iconDown = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_down.dds",
		iconOver = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_over.dds",
		iconDisabled = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_disabled.dds",
	},
	{ key = "all",
		filter = nil,
		displayName = GetString("SI_ITEMTYPEDISPLAYCATEGORY", ITEM_TYPE_DISPLAY_CATEGORY_ALL),
		iconUp = "EsoUI/Art/Inventory/inventory_tabIcon_all_up.dds",
		iconDown = "EsoUI/Art/Inventory/inventory_tabIcon_all_down.dds",
		iconOver = "EsoUI/Art/Inventory/inventory_tabIcon_all_over.dds",
		iconDisabled = "EsoUI/Art/Inventory/inventory_tabIcon_all_disabled.dds",
	},
}
]]

---------------------------------------------------------------------------------------------------------------
-- Filters
---------------------------------------------------------------------------------------------------------------

local Quality_Filters = ZO_InitializingObject:Subclass()

function Quality_Filters:Initialize(trait, options)
	self.trait = trait
	self.options = options
end

function Quality_Filters:IsEnabled()
	return self.options.enabled
end

function Quality_Filters:GetMin()
	return self.options.min
end

function Quality_Filters:GetMax()
	return self.options.max
end

function Quality_Filters:PassesQuality(displayQuality)
	return (displayQuality >= self:GetMin() and displayQuality <= self:GetMax())
end

function Quality_Filters:IgnoreTradeable(bagId, slotIndex)
	if IsItemBoPAndTradeable(bagId, slotIndex) then
		return savedVars.ignoreTradeable
	end
	return false
end

--------------------------------------------------------------------------------------------------------------
-- Local functions
--------------------------------------------------------------------------------------------------------------

local function get_AddAll_Params(panel)
	return panel, Add_All.GetFilteredItems(panel)
end

local function canSmithingFilterBeCraftedHere(filterType)
	if filterType == IJA_SMITHING_FILTER_TYPE_CARRIED then
		return true
	end
	return ZO_CraftingUtils_CanSmithingFilterBeCraftedHere(filterType)
end

local function getStacksPerIteraction(panel)
--	if panel.IsInRefineMode and panel:IsInRefineMode() then
	if panel.isRefinementOnly then
		return GetRequiredSmithingRefinementStackSize()
	end
	return 1
end

local function isItemLocked(bagId, slotIndex)
	if INTERFACE_MODE ~= PLATFORM_MODE_GP and FCOIS and FCOIS.IsDeconstructionLocked(bagId, slotIndex) then
		return true
	end
	if IsItemPlayerLocked(bagId, slotIndex) then
		return true
	end
end
	
local function qualityFilter(filter, displayQuality)
	if filter:IsEnabled() then
		return defaultQualityFilter(filter, displayQuality)
	end
	return false
end

local function shouldAddItem(bagId, slotIndex)
	local filters = {}
	
	-- only need to run this onse per item
	if IsItemBoPAndTradeable(bagId, slotIndex) then
		return savedVars.ignoreTradeable
	end
	
	-- Add relevent filters in order
	if IsItemStolen(bagId, slotIndex) then
		if savedVars.ignoreStolen then
			return false
		else
			table.insert(filters, qualityFilters['stolen'])
		end
	end

	-- Quality filters.
	local hasSet = GetItemLinkSetInfo(GetItemLink(bagId, slotIndex))
	if hasSet then
		table.insert(filters, qualityFilters['setItems'])
	end
	
	local traitInformation = GetItemTraitInformation(bagId, slotIndex)
	if qualityFilters[traitInformation] then
		table.insert(filters, qualityFilters[traitInformation])
	end
	
	if ZO_IsTableEmpty(filters) then
		table.insert(filters, qualityFilters['default'])
	end
	
	local displayQuality = GetItemDisplayQuality(bagId, slotIndex)
	
	for _, filter in ipairs(filters) do
		if not qualityFilter(filter, displayQuality) then
			return false
		end
	end
	return true
end

local function wouldItemExceedMaxStack(panel, bagId, slotIndex)
    local newStackCount = panel.extractionSlot:GetStackCount() + zo_max(1, panel.inventory:GetStackCount(bagId, slotIndex)) -- non virtual items will have a stack count of 0, but still count as 1 item
    local stackCountPerIteration = getStacksPerIteraction(panel)
    local maxStackCount = MAX_ITERATIONS_PER_DECONSTRUCTION * stackCountPerIteration
	
	return newStackCount > maxStackCount
end

local function hasMaxStack(panel)
	local stackCountPerIteration = getStacksPerIteraction(panel)
    local maxStackCount = MAX_ITERATIONS_PER_DECONSTRUCTION * stackCountPerIteration
	
	local stackCount = panel.extractionSlot:GetStackCount() or 0
	
	return (stackCount >= maxStackCount)
end

local function hasCarriedDeconstructableItems()
	if HAS_DECONSTRUCTABLE == nil then
		-- If not at a crafting station, use custom comparator to return all deconstruct-able items.
		local comparator = GetCraftingInteractionType() > 0 and ZO_SharedSmithingExtraction_IsExtractableItem or ZO_UniversalDeconstructionPanel_Shared.IsDeconstructableItem
		local filteredDataTable = SHARED_INVENTORY:GenerateFullSlotData(comparator, BAG_BACKPACK)
		
		for k, itemData in pairs(filteredDataTable) do
			if shouldAddItem(itemData.bagId, itemData.slotIndex) then
				HAS_DECONSTRUCTABLE = true
				return true
			end
		end
		HAS_DECONSTRUCTABLE = false
	end
	
	
	return HAS_DECONSTRUCTABLE 
end

local function getList(inventory)
	local list = inventory.list.dataList or ZO_ScrollList_GetDataList(inventory.list)
	return list
end

local function areAnyItemsNotAdded(panel)
	if panel.extractionSlot:HasItems() and hasMaxStack(panel) then
		return false
	end
	
	local deconTable, hasBOPAndTradeable = Add_All.GetFilteredItems(panel)
	if not #deconTable == 0 then return false end
	
	local notAdded = false
	for k, itemData in pairs(deconTable) do
		if itemData ~= nil then
			-- return true for first filtered item not added to extraction slot.
			if not panel.extractionSlot:ContainsBagAndSlot(itemData.bagId, itemData.slotIndex) then
				return not wouldItemExceedMaxStack(panel, itemData.bagId, itemData.slotIndex)
			end
		end
	end
	-- Return false for no remaining items not added
	return false
end

local function isAddAllEnabled(mode, panel)
	local shouldUse = false

	if mode == SMITHING_MODE_DECONSTRUCTION then
		local filterType = panel:GetFilterType()
		if type(filterType) == 'table' then
			shouldUse = filterType.bags or savedVars.addAllForOthers
		else
			shouldUse = filterType == IJA_SMITHING_FILTER_TYPE_CARRIED or savedVars.addAllForOthers
		end
	elseif mode == SMITHING_MODE_REFINEMENT then
		shouldUse = true
	end

	if shouldUse then
		return areAnyItemsNotAdded(panel)
	end

	return false
end

---------------------------------------------------------------------------------------------------------------
-- Modified smithing filters
---------------------------------------------------------------------------------------------------------------

function Add_All:TryAddItemToCraft(bagId, slotIndex)
    local newStackCount = self.extractionSlot:GetStackCount() + zo_max(1, self.inventory:GetStackCount(bagId, slotIndex)) -- non virtual items will have a stack count of 0, but still count as 1 item
    local stackCountPerIteration = getStacksPerIteraction(self)
    local maxStackCount = MAX_ITERATIONS_PER_DECONSTRUCTION * stackCountPerIteration

	if self.extractionSlot:GetNumItems() >= MAX_ITEM_SLOTS_PER_DECONSTRUCTION then
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString("SI_TRADESKILLRESULT", CRAFTING_RESULT_TOO_MANY_CRAFTING_INPUTS))
	elseif self.extractionSlot:HasItems() and newStackCount > maxStackCount then
		-- prevent slotting if it would take us above the iteration limit, but allow it if nothing else has been slotted yet so we can support single stacks that are larger than the limit
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString("SI_TRADESKILLRESULT", CRAFTING_RESULT_TOO_MANY_CRAFTING_ITERATIONS))
	else
		return ZO_CraftingMultiSlotBase.AddItem(self.extractionSlot, bagId, slotIndex)
	end
end

function Add_All:Callback(deconTable, hasBOPAndTradeable, filterBypass)
	local includeTradeable = not savedVars.ignoreTradeable
	
	if type(deconTable) == 'table' and #deconTable > 0 then
		local itemAdded = false
		if hasBOPAndTradeable and savedVars.warnTradeable then
			ZO_Dialogs_ShowPlatformDialog(CONFIRM_INCLUDE_BOB_AND_TRADEABLE_DIALOG, {object = self, deconTable = deconTable})
		end
		
		for k, itemData in pairs(deconTable) do
			if itemData ~= nil then
				local bagId, slotIndex, isBoPAndTradeable = itemData.bagId, itemData.slotIndex, itemData.isBoPAndTradeable
				
				if not self.extractionSlot:ContainsBagAndSlot(bagId, slotIndex) then
					if not isBoPAndTradeable or (includeTradeable and not savedVars.warnTradeable) or filterBypass then
						if Add_All.TryAddItemToCraft(self, bagId, slotIndex) then
							itemAdded = true
						else
							break -- stop adding items
						end
					end
				end
			end
		end
		
		if itemAdded then
		--	self.panel:UpdateSelection() -- gamepad
			-- We only want to play the sound once, not for every item added.
			PlaySound(SOUNDS.SMITHING_ITEM_TO_EXTRACT_PLACED)

			if self.isGamepad then
				self:RefreshTooltip()
				ZO_GamepadCraftingUtils_PlaySlotBounceAnimation(self.extractionSlot)
			end
		end

		if self.isGamepad then
			self.inventory:PerformFullRefresh()
		end
	end
	self:UpdateKeybindButtonGroup()
end

function Add_All:GetFilteredItems()
	if not self.inventory.list then return end
	local filterFunction = Add_All:GetItemFilterFunction(shouldAddItem)
	
	local list = getList(self.inventory)
	if not list then return false end
		
	local hasBOPAndTradeable = false
	
	local dataTable = {}
	for itemId, itemInfo in ipairs(list) do
		local itemData = Add_All.PlatformGetItemData(self, itemInfo)
		local bagId, slotIndex = itemData.bagId, itemData.slotIndex
		local isBoPAndTradeable = IsItemBoPAndTradeable(bagId, slotIndex) or false
		
		if not hasBOPAndTradeable then
			hasBOPAndTradeable = isBoPAndTradeable
		end
		
		if filterFunction(bagId, slotIndex) then
			table.insert(dataTable, {
				bagId = bagId,
				slotIndex = slotIndex, 
				isBoPAndTradeable = isBoPAndTradeable
			})
		end
	end
	
	return dataTable, hasBOPAndTradeable
end

function Add_All:GetItemFilterFunction(filterFunction)
	return function(bagId, slotIndex, filterType)
		if isItemLocked(bagId, slotIndex) then
			return false
		end
			
		return filterFunction(bagId, slotIndex, filterType)
	end
end

function Add_All:PlatformGetItemData(itemInfo)
	if itemInfo.data then
		return itemInfo.data
	end
	
	return itemInfo
end

---------------------------------------------------------------------------------------------------------------
-- Initialize systems compatibility
---------------------------------------------------------------------------------------------------------------

local panel_Gamepad = {}
function panel_Gamepad:RefreshUniversalTabs()
	self.tabBarEntries = {}
	for _, filterData in ZO_NumericallyIndexedTableReverseIterator(ZO_UNIVERSAL_DECONSTRUCTION_FILTER_TYPES) do
		local entry =
		{
			filterType = filterData.filter,
			text = filterData.displayName,
			disabled = filterData.enabled == false,
			callback = function()
				if not ZO_CraftingUtils_IsPerformingCraftProcess() then
					self:SetFilterType(filterData.filter, filterData)
					--Re-narrate on tab change
					local NARRATE_HEADER = true
					SCREEN_NARRATION_MANAGER:QueueParametricListEntry(self.inventory.list, NARRATE_HEADER)
					
				end
			end,
		}
		table.insert(self.tabBarEntries, entry)
	end
	self:InitializeFilters()
end
	
function panel_Gamepad:InitializeForPanel(parent, scene)
	self.parent = parent
	self.isGamepad = true
	
	local function setShowBank(panel)
		if self.savedVars then
			local filterChanged = self.savedVars.includeBankedItemsChecked ~= true
			if filterChanged then
				self.savedVars.includeBankedItemsChecked = true
				self:SetupSavedVars()
				
				if self.filters then
					-- Univarsal only
					local FILTER_INCLUDE_BANKED = 1
					self.filters[FILTER_INCLUDE_BANKED].checked = true
				end
			end
		end
	end
	setShowBank(self)
	
	local keybindStripDescriptor = {
		keybind = "UI_SHORTCUT_QUINARY",
		gamepadOrder = 1030,
		name = function()
			if isAddAllEnabled(self.parent:GetMode(), self) then
				return GetString(SI_IJADECON_AUTOADD)
			else
				return GetString(SI_CRAFTING_CLEAR_SELECTIONS)
			end
		end,
		callback = function()
			if isAddAllEnabled(self.parent:GetMode(), self) then
				Add_All.Callback(get_AddAll_Params(self))
			else
				if self.extractionSlot:GetItemBagAndSlot(1) then
					self.extractionSlot:ClearItems()
					self.inventory:PerformFullRefresh()
				end
			end
		end,
		enabled = function()
			if not ZO_CraftingUtils_IsPerformingCraftProcess() then
				return isAddAllEnabled(self.parent:GetMode(), self) or self.extractionSlot:HasItems()
			end
			return false
		end,
		visible = function()
			if not ZO_CraftingUtils_IsPerformingCraftProcess() then
				if isAddAllEnabled(self.parent:GetMode(), self) then
					return true
				end

				local bagId, slotIndex = self.inventory:CurrentSelectionBagAndSlot()
				return (bagId ~= nil and slotIndex ~= nil)
			end
			return false
		end,
	}

	table.insert(self.keybindStripDescriptor, keybindStripDescriptor)
	
	ZO_CraftingUtils_ConnectKeybindButtonGroupToCraftingProcess(self.keybindStripDescriptor)
	ZO_Gamepad_AddListTriggerKeybindDescriptors(self.keybindStripDescriptor, self.inventory.list)
	
	-- In gamepad mode, the keybindStripDescriptor is per panel
	self.UpdateKeybindButtonGroup = function()
		KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
		IS_ADD_ALL_VISIBLE = nil
	end

	scene:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWING then
			setShowBank(self)
		elseif newState == SCENE_SHOWN then
			if savedVars.addOnOpen then
				if hasCarriedDeconstructableItems() then
					Add_All.Callback(get_AddAll_Params(self))
				end
			end
			self:UpdateKeybindButtonGroup()
		end
	end)
	
	SecurePostHook(self, 'SetFilterType', function()
		-- Lets make sure to undo changes made by users in between tabs.
		-- Don't want them to freek out over seening the lists empty
		setShowBank(self)
	end)
end

function panel_Gamepad:InitializeForCarriedTab()
	local function AddTabEntry(tabBarEntries, filterType)
		if filterType == IJA_SMITHING_FILTER_TYPE_CARRIED or ZO_CraftingUtils_CanSmithingFilterBeCraftedHere(filterType) then
			local entry = {}
			entry.text = GetString("SI_SMITHINGFILTERTYPE", filterType)
			entry.callback = function()
				if not ZO_CraftingUtils_IsPerformingCraftProcess() then
					self.deconstructionPanel:SetFilterType(filterType)
					local NARRATE_HEADER = true
					SCREEN_NARRATION_MANAGER:QueueParametricListEntry(self.deconstructionPanel.inventory.list, NARRATE_HEADER)
				end
			end
			entry.filterType = filterType

			table.insert(tabBarEntries, entry)
		end
	end

	GAMEPAD_SMITHING_DECONSTRUCT_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWING then
			local tabBarEntries = {}
			
			AddTabEntry(tabBarEntries, IJA_SMITHING_FILTER_TYPE_CARRIED)
			AddTabEntry(tabBarEntries, SMITHING_FILTER_TYPE_WEAPONS)
			AddTabEntry(tabBarEntries, SMITHING_FILTER_TYPE_ARMOR)
			AddTabEntry(tabBarEntries, SMITHING_FILTER_TYPE_JEWELRY)

			local titleString = ZO_GamepadCraftingUtils_GetLineNameForCraftingType(GetCraftingInteractionType())

			ZO_GamepadCraftingUtils_SetupGenericHeader(self, titleString, tabBarEntries)


			if #tabBarEntries > 1 then
				ZO_GamepadGenericHeader_Activate(self.header)
			end
			ZO_GamepadCraftingUtils_RefreshGenericHeader(self)
			
   --		 self.deconstructionPanel.inventory:HandleDirtyEvent()
		end
	end)
	
	GAMEPAD_SMITHING_REFINE_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWING then
			local titleString = GetString(SI_SMITHING_TAB_REFINEMENT)

			ZO_GamepadCraftingUtils_SetupGenericHeader(self, titleString)
			ZO_GamepadCraftingUtils_RefreshGenericHeader(self)
	  --	  self.deconstructionPanel.inventory:HandleDirtyEvent()
		end
	end)
	
	GAMEPAD_SMITHING_ROOT_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if not savedVars.openToDecon then return end
		if hasCarriedDeconstructableItems() then
			if SCENE_MANAGER:GetPreviousSceneName() == 'hud' then
				if newState == SCENE_SHOWING then
					jo_callLaterOnNextScene(ADDON_SHORT_NAME .. '_AutoSelectDecon', function()
						zo_callLater(function()
							ZO_GamepadGenericHeader_SetActiveTabIndex(self.header, 1, true)
						end, 100)
					end)
				elseif newState == SCENE_SHOWN then
					self:SetMode(SMITHING_MODE_DECONSTRUCTION)
				end
			end
		end
	end)
	
	panel_Gamepad.RefreshUniversalTabs(UNIVERSAL_DECONSTRUCTION_GAMEPAD.deconstructionPanel)
	panel_Gamepad.InitializeForPanel(self.deconstructionPanel, self, GAMEPAD_SMITHING_DECONSTRUCT_SCENE)
	panel_Gamepad.InitializeForPanel(self.refinementPanel, self, GAMEPAD_SMITHING_REFINE_SCENE)
	panel_Gamepad.InitializeForPanel(UNIVERSAL_DECONSTRUCTION_GAMEPAD.deconstructionPanel, UNIVERSAL_DECONSTRUCTION_GAMEPAD, UNIVERSAL_DECONSTRUCTION_GAMEPAD_SCENE)
end
-- UNIVERSAL_DECONSTRUCTION_GAMEPAD.deconstructionPanel

local panel_Keybaord = {}
function panel_Keybaord:RefreshUniversalTabs()
	local tabFilters = {}
	for _, filterData in ipairs(ZO_UNIVERSAL_DECONSTRUCTION_FILTER_TYPES) do
		local tabFilterData = self.inventory:CreateNewTabFilterData(filterData.filter, filterData.displayName, filterData.iconUp, filterData.iconDown, filterData.iconOver, filterData.iconDisabled)
		tabFilterData.filter = filterData
		tabFilterData.enabled = filterData.enabled
		if filterData.tooltipText then
			-- Only override the tooltip text if specified.
			tabFilterData.tooltipText = filterData.tooltipText
		end
		tabFilterData.callback = function(tabData)
			self.inventory:ChangeFilter(tabData)
			KEYBIND_STRIP:UpdateKeybindButtonGroup(self.owner.keybindStripDescriptor)
		end
		table.insert(tabFilters, tabFilterData)
	end

	self.inventory:SetFilters(tabFilters)
	self.inventory:SetActiveFilterByDescriptor(CARRIED_DECONSTRUCTION_FILTER_TYPE)
	
	ZO_ComboBox_ObjectFromContainer(self.craftingTypeFilters):ClearItems()
	self:InitializeFilters()
end

function panel_Keybaord:InitializeForPanel(scene)
	local function setShowBank()
		if self.deconstructionPanel then
			local panel = self.deconstructionPanel
			panel.savedVars.includeBankedItemsChecked = true
			ZO_CheckButton_SetCheckState(panel.includeBankedItemsCheckbox, panel.savedVars.includeBankedItemsChecked)
			panel.includeBankedItemsCheckbox:SetHidden(true)
		end
	end
	setShowBank()
	
	local function getPanelNameByMode(mode)
		if mode == SMITHING_MODE_REFINEMENT then
			return 'refinementPanel'
		elseif mode == SMITHING_MODE_DECONSTRUCTION then
			return 'deconstructionPanel'
		end
	end
	
	local function isVisible()
		local panelName = getPanelNameByMode(self.mode)
		if panelName then
			return isAddAllEnabled(self.mode, self[panelName]) or self[panelName].extractionSlot:HasItems()
		end
	end
	
	-- Clear selections / Cancel Research
	local newKeybindButton = {
		keybind = "UI_SHORTCUT_NEGATIVE",
		name = function()
			if self.mode == SMITHING_MODE_RESEARCH then
				return GetString(SI_CRAFTING_CANCEL_RESEARCH)
			else
				if self.mode == SMITHING_MODE_REFINEMENT then
					if isAddAllEnabled(self.mode, self.refinementPanel) then
						return GetString(SI_IJADECON_AUTOADD)
					end
				elseif self.mode == SMITHING_MODE_DECONSTRUCTION then
					if isAddAllEnabled(self.mode, self.deconstructionPanel) then
						return GetString(SI_IJADECON_AUTOADD)
					end
				end
				return GetString(SI_CRAFTING_CLEAR_SELECTIONS)
			end
		end,
		callback = function()
			if self.mode == SMITHING_MODE_REFINEMENT then
				if isAddAllEnabled(self.mode, self.refinementPanel) then
					Add_All.Callback(get_AddAll_Params(self.refinementPanel))
				else
					self.refinementPanel:ClearSelections()
				end
				self:UpdateKeybindButtonGroup()
			elseif self.mode == SMITHING_MODE_DECONSTRUCTION then
				if isAddAllEnabled(self.mode, self.deconstructionPanel) then
					Add_All.Callback(get_AddAll_Params(self.deconstructionPanel))
				else
					self:ClearSelections()
				end
				self:UpdateKeybindButtonGroup()
			elseif self.mode == SMITHING_MODE_IMPROVEMENT then
				self.improvementPanel:ClearSelections()
			elseif self.mode == SMITHING_MODE_RESEARCH then
				return self.researchPanel:CancelResearch()
			end
		end,
		enabled = function()
			if not ZO_CraftingUtils_IsPerformingCraftProcess() then
				if self.mode == SMITHING_MODE_REFINEMENT then
					return isAddAllEnabled(self.mode, self.refinementPanel) or self.refinementPanel.extractionSlot:HasItems()
				elseif self.mode == SMITHING_MODE_DECONSTRUCTION then
					return isAddAllEnabled(self.mode, self.deconstructionPanel) or self.deconstructionPanel.extractionSlot:HasItems()
				end
			end
			return true
		end,
		visible = function()
			if not ZO_CraftingUtils_IsPerformingCraftProcess() then
				if self.mode == SMITHING_MODE_REFINEMENT then
					return isVisible()
				elseif self.mode == SMITHING_MODE_DECONSTRUCTION then
					return isVisible()
				elseif self.mode == SMITHING_MODE_IMPROVEMENT then
					return self.improvementPanel:HasSelections()
				elseif self.mode == SMITHING_MODE_RESEARCH then
					return self.researchPanel:CanCancelResearch()
				end
			end
		end,
	}

	-- Replace the UI_SHORTCUT_NEGATIVE button with the new one.
	for k, keybindButton in pairs(self.keybindStripDescriptor) do
		if keybindButton.keybind == "UI_SHORTCUT_NEGATIVE" then
			self.keybindStripDescriptor[k] = newKeybindButton
			break
		end
	end
	
	ZO_CraftingUtils_ConnectKeybindButtonGroupToCraftingProcess(self.keybindStripDescriptor)
	
	-- In keyboard mode, the keybindStripDescriptor is in parent
	self.UpdateKeybindButtonGroup = function()
		KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
		IS_ADD_ALL_VISIBLE = nil
	end
	
	scene:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWING then
			setShowBank()
		elseif newState == SCENE_SHOWN then
			if savedVars.addOnOpen then
				if hasCarriedDeconstructableItems() then
					Add_All.Callback(get_AddAll_Params(self.deconstructionPanel))
				end
			end
			self:UpdateKeybindButtonGroup()
		end
	end)
	
	-- Add the parent's UpdateKeybindButtonGroup to each panel
	self.deconstructionPanel.UpdateKeybindButtonGroup = self.UpdateKeybindButtonGroup
	if self.refinementPanel then
		self.refinementPanel.UpdateKeybindButtonGroup = self.UpdateKeybindButtonGroup
	end
	
	-- Update the keybinds on changing invnetory tabs.
	SecurePostHook(self.deconstructionPanel.inventory, 'ChangeFilter', function()
		self:UpdateKeybindButtonGroup()
	end)
end

function panel_Keybaord:InitializeForCarriedTab()
	local function canDeconstructSmithingItemsHere()
		return CanSmithingWeaponPatternsBeCraftedHere() or CanSmithingApparelPatternsBeCraftedHere() or CanSmithingJewelryPatternsBeCraftedHere()
	end

	ZO_MenuBar_ClearButtons(self.deconstructionPanel.inventory.tabs)

	self.deconstructionPanel.inventory:SetFilters{
		self.deconstructionPanel.inventory:CreateNewTabFilterData(SMITHING_FILTER_TYPE_JEWELRY, GetString("SI_SMITHINGFILTERTYPE", SMITHING_FILTER_TYPE_JEWELRY), "EsoUI/Art/Crafting/jewelry_tabIcon_icon_up.dds", "EsoUI/Art/Crafting/jewelry_tabIcon_down.dds", "EsoUI/Art/Crafting/jewelry_tabIcon_icon_over.dds", "EsoUI/Art/Inventory/inventory_tabIcon_jewelry_disabled.dds", CanSmithingJewelryPatternsBeCraftedHere),
		self.deconstructionPanel.inventory:CreateNewTabFilterData(SMITHING_FILTER_TYPE_ARMOR, GetString("SI_SMITHINGFILTERTYPE", SMITHING_FILTER_TYPE_ARMOR), "EsoUI/Art/Inventory/inventory_tabIcon_armor_up.dds", "EsoUI/Art/Inventory/inventory_tabIcon_armor_down.dds", "EsoUI/Art/Inventory/inventory_tabIcon_armor_over.dds", "EsoUI/Art/Inventory/inventory_tabIcon_armor_disabled.dds", CanSmithingApparelPatternsBeCraftedHere),
		self.deconstructionPanel.inventory:CreateNewTabFilterData(SMITHING_FILTER_TYPE_WEAPONS, GetString("SI_SMITHINGFILTERTYPE", SMITHING_FILTER_TYPE_WEAPONS), "EsoUI/Art/Inventory/inventory_tabIcon_weapons_up.dds", "EsoUI/Art/Inventory/inventory_tabIcon_weapons_down.dds", "EsoUI/Art/Inventory/inventory_tabIcon_weapons_over.dds", "EsoUI/Art/Inventory/inventory_tabIcon_weapons_disabled.dds", CanSmithingWeaponPatternsBeCraftedHere),
		self.deconstructionPanel.inventory:CreateNewTabFilterData(IJA_SMITHING_FILTER_TYPE_CARRIED, GetString("SI_SMITHINGFILTERTYPE", IJA_SMITHING_FILTER_TYPE_CARRIED), "EsoUI/Art/MainMenu/menuBar_inventory_up.dds", "EsoUI/Art/MainMenu/menuBar_inventory_down.dds", "EsoUI/Art/MainMenu/menuBar_inventory_over.dds", "EsoUI/Art/MainMenu/menuBar_inventory_disabled.dds", canDeconstructSmithingItemsHere),
	}
	
	SMITHING_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if not savedVars.openToDecon then return end
		if SCENE_MANAGER:GetPreviousSceneName() == 'hud' then
			if hasCarriedDeconstructableItems() then
				if newState == SCENE_SHOWING then
					ZO_MenuBar_SelectDescriptor(self.modeBar, SMITHING_MODE_DECONSTRUCTION)
				elseif newState == SCENE_SHOWN then
					self.deconstructionPanel.inventory:SetActiveFilterByDescriptor(IJA_SMITHING_FILTER_TYPE_CARRIED)
				end
			end
		end
	end)
	
	UNIVERSAL_DECONSTRUCTION.deconstructionPanel.owner = UNIVERSAL_DECONSTRUCTION
	panel_Keybaord.RefreshUniversalTabs(UNIVERSAL_DECONSTRUCTION.deconstructionPanel)
	panel_Keybaord.InitializeForPanel(self, SMITHING_SCENE)
	panel_Keybaord.InitializeForPanel(UNIVERSAL_DECONSTRUCTION, UNIVERSAL_DECONSTRUCTION_KEYBOARD_SCENE)
end

---------------------------------------------------------------------------------------------------------------
-- Main
---------------------------------------------------------------------------------------------------------------

local addon = ZO_InitializingObject:Subclass()

function addon:Initialize(control)
	self.control = control
	zo_mixin(self, addonData)
	self.platformObjects = {}
	
	local function OnLoaded(_, name)
		if name ~= self.name then return end
		self.control:UnregisterForEvent(EVENT_ADD_ON_LOADED)

		local AccountWideSavedVars = ZO_SavedVars:NewAccountWide("IJA_Decon_SavedVars", svVersion, nil, defaults, GetWorldName())
		self.savedVars = AccountWideSavedVars
		savedVars = AccountWideSavedVars

		
		self:SetupSettings()
		self:InitializeDialogue()
	
		local function OnGamepadPreferredModeChanged()
			INTERFACE_MODE = IsInGamepadPreferredMode() and PLATFORM_MODE_GP or PLATFORM_MODE_KB
		end
		ZO_PlatformStyle:New(OnGamepadPreferredModeChanged)

	end
	control:RegisterForEvent( EVENT_ADD_ON_LOADED, OnLoaded)

	local function onPlayerActivated()
		self.control:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
	--	d( self.displayName .. " version: " .. self.version)

		self:OnDefferedInitialize()
	end
	self.control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, onPlayerActivated)
end

function addon:InitializeDialogue()
	local function closeDialogue(name)
		ZO_Dialogs_ReleaseDialogOnButtonPress(name)
	end
	ZO_Dialogs_RegisterCustomDialog(CONFIRM_INCLUDE_BOB_AND_TRADEABLE_DIALOG,
	{
		blockDialogReleaseOnPress = true,
		canQueue = true,

		gamepadInfo = 
		{
			dialogType = GAMEPAD_DIALOGS.BASIC,
			allowRightStickPassThrough = true,
		},

		setup = function(dialog)
			self.destroyConfirmText = nil
			dialog:setupFunc()
		end,

		title =
		{
			text = SI_IJADECON_DIALOGUE_TITLE,
		},

		mainText = 
		{
			text = SI_IJADECON_DIALOGUE_DESCRIPTION,
		},
	  
		buttons = {
			{
		--		onShowCooldown = 2000,
				keybind = "DIALOG_PRIMARY",
				text = GetString(SI_YES),
				callback = function(dialog)
					local data = dialog.data
					local INCLUDE_TRADEABLE = false -- set false to skip trade-able check to show dialogue.
					local FILTER_BYPASS = true
					Add_All.Callback(data.object, data.deconTable, INCLUDE_TRADEABLE, FILTER_BYPASS)
					closeDialogue(CONFIRM_INCLUDE_BOB_AND_TRADEABLE_DIALOG)
				end,
			},
			{
				keybind = "DIALOG_NEGATIVE",
				text = GetString(SI_NO),
				callback = function()
					closeDialogue(CONFIRM_INCLUDE_BOB_AND_TRADEABLE_DIALOG)
				end,
			},
		},
		noChoiceCallback = function(dialog)
			closeDialogue(CONFIRM_INCLUDE_BOB_AND_TRADEABLE_DIALOG)
		end,
	})
end

function addon:InitializeUniversalChatterAutoSelect()
	local isUniDecon = {
		[GetString(SI_INTERACT_OPTION_UNIVERSAL_DECONSTRUCTION)] = true
	}
	
	local autoSelectCarried = {
		[PLATFORM_MODE_KB] = function(chatterOption)
			jo_callLaterOnNextScene(ADDON_SHORT_NAME .. '_AutoSelectCarried', function()
				UNIVERSAL_DECONSTRUCTION.deconstructionPanel.inventory:SetActiveFilterByDescriptor(CARRIED_DECONSTRUCTION_FILTER_TYPE.filter)
			end)
			SelectChatterOption(chatterOption)
		end,
		[PLATFORM_MODE_GP] =function(chatterOption)
			jo_callLaterOnNextScene(ADDON_SHORT_NAME .. '_AutoSelectCarried', function()
				zo_callLater(function()
					ZO_GamepadGenericHeader_SetActiveTabIndex(UNIVERSAL_DECONSTRUCTION_GAMEPAD.header, 1, true)
					-- Dose not pysically change inventory tabs.
                 --   UNIVERSAL_DECONSTRUCTION_GAMEPAD.deconstructionPanel:SetFilterType(CARRIED_DECONSTRUCTION_FILTER_TYPE.filter, CARRIED_DECONSTRUCTION_FILTER_TYPE)
				end, 100)
			end)
			SelectChatterOption(chatterOption)
		end,
	}
	
	local function onChatterBegin()
		if not self.savedVars.openToUni then return end
		local callback = autoSelectCarried[INTERFACE_MODE]
		if GetInteractionType() == INTERACTION_CONVERSATION then
		
			for i=1, GetChatterOptionCount() do
				local optionText = GetChatterOption(i)
				if isUniDecon[optionText] then
					if hasCarriedDeconstructableItems(self.savedVars) then
						callback(i)
					end
					return
				end
			end
		end
	end
	self.control:RegisterForEvent(EVENT_CHATTER_BEGIN, onChatterBegin)
end

function addon:OnDefferedInitialize()
	self:SetupCompatibilityForOtherAddons()
	self:InitializeFIlters()
	
	panel_Gamepad.InitializeForCarriedTab(SMITHING_GAMEPAD)
	panel_Keybaord.InitializeForCarriedTab(SMITHING)

	self:InitializeUniversalChatterAutoSelect()
	
	local function onGamepadPreferredModeChanged()
		INTERFACE_MODE = IsInGamepadPreferredMode() and PLATFORM_MODE_GP or PLATFORM_MODE_KB
	end
	ZO_PlatformStyle:New(onGamepadPreferredModeChanged)
end

--[[
	root
	deconstructionPanel
	universalDeconstructionPanel
	refinementPanel
	rootScene
]]

---------------------------------------------------------------------------------------------------------------
-- Settings menu
---------------------------------------------------------------------------------------------------------------

function addon:SetupSettings()
	local LAM2 = LibAddonMenu2
	if not LAM2 then
		return
	end

	local panelData = {
		type = "panel",
		name = self.displayName,
		displayName = self.displayName,
		author = "IsJustaGhost",
		version = self.version,
		registerForRefresh = true,
		registerForDefaults = true
	}
	LAM2:RegisterAddonPanel(self.name .. '_LAM', panelData)

	local optionsTable = {
		{ type = "header",
 --		   name = GetString(),
			width = "full",
		},
		{ type = "checkbox",
			name = GetString(SI_IJADECON_USE_CLEAN_REFINMENT_TAB),
			tooltip = GetString(SI_IJADECON_USE_CLEAN_REFINMENT_TOOLTIP),
			getFunc = function() return self.savedVars.cleanRefinementTab end,
			setFunc = function(value)
				self.savedVars.cleanRefinementTab = value
			end,
			width = "full",
		},
		{ type = "divider",
			height = 10,
		},
		{ type = "checkbox",
			name = GetString(SI_IJADECON_OPEN_TO_DECON_ASSISTANT),
			tooltip = GetString(SI_IJADECON_OPEN_TO_DECON_ASSISTANT_TOOLTIP),
			getFunc = function() return self.savedVars.openToUni end,
			setFunc = function(value)
				self.savedVars.openToUni = value

				if value then
					CALLBACK_MANAGER:FireCallbacks("IJA_Decon_Register_StateChange")
				else
					CALLBACK_MANAGER:FireCallbacks("IJA_Decon_Unregister_StateChange")
				end
			end,
			width = "full",
		},
		{ type = "checkbox",
			name = GetString(SI_IJADECON_OPEN_TO_DECON_TAB),
			tooltip = GetString(SI_IJADECON_OPEN_TO_DECON_TAB_TOOLTIP),
			getFunc = function() return self.savedVars.openToDecon end,
			setFunc = function(value)
				self.savedVars.openToDecon = value

				if value then
					CALLBACK_MANAGER:FireCallbacks("IJA_Decon_Register_StateChange")
				else
					CALLBACK_MANAGER:FireCallbacks("IJA_Decon_Unregister_StateChange")
				end
			end,
			width = "full",
		},
		{ type = "checkbox",
			name = GetString(SI_IJADECON_AUTOADD_TITLE),
			tooltip = GetString(SI_IJADECON_AUTOADD_DESCRIPTION),
			getFunc = function() return self.savedVars.addOnOpen end,
			setFunc = function(value)
				self.savedVars.addOnOpen = value
			end,
			width = "full",
		},
		{ type = "divider",
			height = 10,
		},
		{ type = "checkbox",
			name = GetString(SI_IJADECON_IGNORE_BOP), -- 
			tooltip = GetString(SI_IJADECON_IGNORE_BOP_TOOLTIP),
			getFunc = function() return self.savedVars.ignoreTradeable end,
			setFunc = function(value)
				self.savedVars.ignoreTradeable = value
				if value then
					self.savedVars.warnTradeable = false
				end
			end,
			width = "full",
		},
		{ type = "checkbox",
			name = GetString(SI_IJADECON_WARN_BOP), -- 
			tooltip = GetString(SI_IJADECON_WARN_BOP_TOOLTIP),
			getFunc = function() return self.savedVars.warnTradeable end,
			setFunc = function(value)
				self.savedVars.warnTradeable = value
				
				if value then
					self.savedVars.ignoreTradeable = false
				end
			end,
			width = "full",
		},
		{ type = "divider",
			height = 10,
		},
		{ type = "checkbox",
			name = GetString(SI_IJADECON_USE_ADDALL_IGNORESTOLEN),
			tooltip = GetString(SI_IJADECON_USE_ADDALL_IGNORESTOLEN_TOOLTIP),
			getFunc = function() return self.savedVars.ignoreStolen end,
			setFunc = function(value)
				self.savedVars.ignoreStolen = value
				
				if value then
					if self.savedVars.traitOptions['stolen'] then
						self.savedVars.traitOptions['stolen'].enabled = false
					end
				end
			end,
			width = "full",
		},
		{ type = "checkbox",
			name = GetString(SI_IJADECON_USE_ADDALL_FOR_OTHERS),
			tooltip = GetString(SI_IJADECON_USE_ADDALL_FOR_OTHERS_TOOLTIP),
			getFunc = function() return self.savedVars.addAllForOthers end,
			setFunc = function(value)
				self.savedVars.addAllForOthers = value
			end,
			width = "full",
		},
		{ type = "header",
			name = GetString(SI_IJADECON_AUTOADD_HEADER),
			width = "full",
		},
		unpack(self:GetTraitOptionsTable())
	}
	LAM2:RegisterOptionControls(self.name .. '_LAM', optionsTable)
end

function addon:GetTraitOptionsTable()
	qualityFilters = {}
	local traitOptionsTable = {}
	for _, info in ipairs(filterTable) do
		local traitOption = self.savedVars.traitOptions[info.id]
		if not traitOption then
			traitOption = {
				['traitId'] = info.id,
				['enabled'] = false,
				['min'] = VAR_QUALITY_DEFAULT_MIN,
				['max'] = VAR_QUALITY_DEFAULT_MAX,
			}
			self.savedVars.traitOptions[info.id] = traitOption
		end

		local qualityFilter = Quality_Filters:New(info.id, traitOption)
		qualityFilters[info.id] = qualityFilter
		
		table.insert(traitOptionsTable, self:CreateTraitOption(info.id, info.name, traitOption, info))
	end
	
	-- For debugging
	self.qualityFilters = qualityFilters
	return traitOptionsTable
end

do
	local enabled = GetString(SI_ADDON_MANAGER_ENABLED)

	function addon:CreateTraitOption(trait, name, traitOption, info)
		local levelValues = {0,1,2,3,4,5,6}
		local levelChoices = {}
		for k, i in ipairs(levelValues) do
			local color = GetItemQualityColor(i)
			table.insert(levelChoices, color:Colorize(GetString('SI_ITEMDISPLAYQUALITY', i)))
		end
		
		local tooltipName = name == VAR_DEFAULT_STRING and GetString(SI_IJADECON_DEFAULT_TOOLTIP) or name
		
		local controlList = {
			{ type = "checkbox",
				name = enabled,
				tooltip = zo_strformat(GetString(SI_IJADECON_AUTOADD_TOOLTIP),tooltipName),
				getFunc = function() return traitOption.enabled end,
				setFunc = function(value)
					traitOption.enabled = value
				end,
				width = "full"
			},
			{ type = "dropdown",
				choices = levelChoices,
				choicesValues = levelValues,
				name = GetString(SI_IJADECON_MIN_QUALITY),
				getFunc = function() return traitOption.min end,
				setFunc = function(value)
					traitOption.min = value
					if value > traitOption.max then
						traitOption.max = value
					end
				end,
				width = "half",
			},
			{ type = "dropdown",
				choices = levelChoices,
				choicesValues = levelValues,
				name = GetString(SI_IJADECON_MAX_QUALITY),
				getFunc = function() return traitOption.max end,
				setFunc = function(value)
					traitOption.max = value
					if value < traitOption.min then
						traitOption.min = value
					end
				end,
				width = "half",
			},
		}
		
		local menu = {
			type = "submenu",
			name = name,
			reference = self.name .. name .. "_LAM",
			controls = controlList,
			disabled = info.disabledCondition
		}
		return menu
	end
end

---------------------------------------------------------------------------------------------------------------
--
---------------------------------------------------------------------------------------------------------------

function IJA_Decon_Initialize( ... )
	IJA_DECON = addon:New( ... )
end

if not jo_callLaterOnNextScene then
	jo_callLaterOnNextScene = function(id, func, ...)
		local params = {...}
		local sceneName = SCENE_MANAGER:GetCurrentSceneName()
		local updateName = "JO_CallLaterOnNextScene_" .. id
		EVENT_MANAGER:UnregisterForUpdate(updateName)
		
		local function OnUpdateHandler()
			if SCENE_MANAGER:GetCurrentSceneName() ~= sceneName then
				EVENT_MANAGER:UnregisterForUpdate(updateName)
				func(unpack(params))
			end
		end
		
		EVENT_MANAGER:RegisterForUpdate(updateName, 100, OnUpdateHandler)
	end
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------

function addon:InitializeFIlters()
	if LibFilters3 then
		LibFilters3:InitializeLibFilters()
		LibFilters3.mapping.universalDeconTabKeyToLibFiltersFilterType[TAB_KEY] = LF_SMITHING_DECONSTRUCT
	end
	
	-- filterType is used to get items based on the selected tab. If custom tab is added then we need to get the filterType from the item.
	local function verifyOrGetSmithingFilterTypeFromItem(bagId, slotIndex, filterType)
		if filterType ~= nil and filterType == IJA_SMITHING_FILTER_TYPE_CARRIED then
			if not ZO_CraftingUtils_GetBaseSmithingFilter(filterType) then
				filterType = ZO_CraftingUtils_GetBaseSmithingFilter(ZO_CraftingUtils_GetSmithingFilterFromItem(bagId, slotIndex))
			end
		end
		return filterType
	end

	-- Needed to segregate items per bag by tab
	-- To make this compliant with libFilters, run the original first.
	local orig_DoesItemPassFilter = ZO_UniversalDeconstructionPanel_Shared.DoesItemPassFilter
	function ZO_UniversalDeconstructionPanel_Shared.DoesItemPassFilter(bagId, slotIndex, filterType)

		-- Get result from original or libFilters
		local result = orig_DoesItemPassFilter(bagId, slotIndex, filterType)
		if result then
			if filterType.bags then
				if not ZO_IsElementInNumericallyIndexedTable(filterType.bags, bagId) then
					return false
				end
			else
				if bagId == BAG_BACKPACK then
					return false
				end
			end
		end
		return result
	end

	--[[ original
	function ZO_UniversalDeconstructionPanel_Shared.DoesItemPassFilter(bagId, slotIndex, filterType)
		local itemFilterTypes = {GetItemFilterTypeInfo(bagId, slotIndex)}
		if ZO_IsElementInNumericallyIndexedTable(itemFilterTypes, ITEMFILTERTYPE_JEWELRY) and not ZO_IsJewelryCraftingEnabled() then
			return false
		end

		if filterType then
			if filterType.itemTypes then
				local itemType = GetItemType(bagId, slotIndex)
				if not ZO_AreIntersectingNumericallyIndexedTables(filterType.itemTypes, itemType) then
					return false
				end
			end

			if filterType.itemFilterTypes then
				if not ZO_AreIntersectingNumericallyIndexedTables(filterType.itemFilterTypes, itemFilterTypes) then
					return false
				end
			end
		end

		return true
	end
	]]

	-- Modified filter to allow clean refinement tab setting to function
	local orig_SharedSmithingExtraction_IsRefinableItem = ZO_SharedSmithingExtraction_IsRefinableItem
	function ZO_SharedSmithingExtraction_IsRefinableItem(bagId, slotIndex)
		-- Get result from original and filter by stack size if needed.
		local result = orig_SharedSmithingExtraction_IsRefinableItem(bagId, slotIndex)
		if result and savedVars.cleanRefinementTab then
			-- if enabled and has enough to refine
			local stack, maxStack = GetSlotStackSize(bagId, slotIndex)
			result = stack >= GetRequiredSmithingRefinementStackSize()
		end
		return result
	end
	--[[ original
	function ZO_SharedSmithingExtraction_IsRefinableItem(bagId, slotIndex)
		return CanItemBeRefined(bagId, slotIndex, GetCraftingInteractionType())
	end
	]]

	-- Needed to segregate items per bag by tab
	local orig_SharedSmithingExtraction_DoesItemPassFilter = ZO_SharedSmithingExtraction_DoesItemPassFilter
	function ZO_SharedSmithingExtraction_DoesItemPassFilter(bagId, slotIndex, filterType)
		local smithingFilterType = verifyOrGetSmithingFilterTypeFromItem(bagId, slotIndex, filterType)
		-- Get result from original or libFilters and filter by bagId if needed.
		local result = orig_SharedSmithingExtraction_DoesItemPassFilter(bagId, slotIndex, smithingFilterType)
		
		if result then
			if bagId == BAG_BACKPACK then
				-- Only carried or refine items should be in backpack.
				return filterType == IJA_SMITHING_FILTER_TYPE_CARRIED or filterType == SMITHING_FILTER_TYPE_RAW_MATERIALS
			else 
				-- Carried items should only be in backpack, all others can be in others.
				return filterType ~= IJA_SMITHING_FILTER_TYPE_CARRIED
			end
		end
	end
	--[[ original
	function ZO_SharedSmithingExtraction_DoesItemPassFilter(bagId, slotIndex, filterType)
		return ZO_CraftingUtils_GetSmithingFilterFromItem(bagId, slotIndex) == filterType
	end
	]]
end

function addon:SetupCompatibilityForOtherAddons()
	if AdvancedFilters then
		-- To enable AF tabs in Univearsal Deconstruction
		AdvancedFilters.universalDeconSelectedTabToActualInventories[TAB_KEY] = {INVENTORY_BACKPACK}
		AdvancedFilters.universalDeconKeyToAFFilterType[TAB_KEY] = ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ALL
		AdvancedFilters.universalDeconSelectedTabToAFInventoryType[TAB_KEY] = INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_ALL
		
		-- To enable AF tabs in smithing stations
		AdvancedFilters.mapCSFT2IFT[LF_JEWELRY_DECONSTRUCT][CRAFTING_TYPE_JEWELRYCRAFTING][IJA_SMITHING_FILTER_TYPE_CARRIED] = ITEMFILTERTYPE_AF_JEWELRY_CRAFTING
		AdvancedFilters.mapCSFT2IFT[LF_SMITHING_DECONSTRUCT][CRAFTING_TYPE_BLACKSMITHING][IJA_SMITHING_FILTER_TYPE_CARRIED] = ITEMFILTERTYPE_AF_WEAPONS_SMITHING
		AdvancedFilters.mapCSFT2IFT[LF_SMITHING_DECONSTRUCT][CRAFTING_TYPE_CLOTHIER][IJA_SMITHING_FILTER_TYPE_CARRIED] = ITEMFILTERTYPE_AF_ARMOR_CLOTHIER
		AdvancedFilters.mapCSFT2IFT[LF_SMITHING_DECONSTRUCT][CRAFTING_TYPE_WOODWORKING][IJA_SMITHING_FILTER_TYPE_CARRIED] = ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING

	end
end
