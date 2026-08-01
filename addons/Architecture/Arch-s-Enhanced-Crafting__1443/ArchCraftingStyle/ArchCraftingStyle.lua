ArchCraftingStyle = ZO_Object:Subclass()

local STYLE_RESET_MODE_AUTOMATIC = 1
local STYLE_RESET_MODE_ON_ZONE = 2

local STYLE_RESET_MODE_STRINGS = {
	"Automatic",
	"On Zone Change",
 }
local STYLE_RESET_MODES = {
	[ STYLE_RESET_MODE_STRINGS[STYLE_RESET_MODE_AUTOMATIC] ] = STYLE_RESET_MODE_AUTOMATIC,
	[ STYLE_RESET_MODE_STRINGS[STYLE_RESET_MODE_ON_ZONE] ] = STYLE_RESET_MODE_ON_ZONE,
}

local LAM = LibAddonMenu2

function ArchCraftingStyle:BuildStyleNameIndex()
	self.styleNames = {}
	
	for i = 1, GetNumValidItemStyles() do
		local styleItemIndex = GetValidItemStyleId(i)
		local itemName = GetSmithingStyleItemInfo(styleItemIndex)
		if itemName ~= "" and styleItemIndex ~= 36 then -- 36 = "Crown Mimic Stone"
			table.insert(self.styleNames, {styleItemIndex,itemName,i})
		end
	end
end

-- Thanks Dolg (quick change)
function ArchCraftingStyle:StyleCompiler()
	self:BuildStyleNameIndex()
	
	local submenuTable = {}
	local styleNames = self.styleNames
	
	for k, v in ipairs(styleNames) do
		local option = {
			type = "checkbox",
			name = zo_strformat("<<1>>", v[2]),
			tooltip = "",
			getFunc = function() return self.sv.styles[v[1]] end,
			setFunc = function(value)
				self.sv.styles[v[1]] = value
			end,
		}
		submenuTable[#submenuTable + 1] = option
	end
	
	local imperial = table.remove(submenuTable, 34)
	table.insert(submenuTable, 10, imperial)
	
	return submenuTable
end

function ArchCraftingStyle:SetupOptions()
	local addonDisplayName = "|c0066FFArch's|r Enhanced Crafting"

	local panelData = {
		type = "panel",
		name = addonDisplayName,
		displayName = addonDisplayName,
		author = "|c0066FFArchitecture|r",
		--version = self.version,
		registerForRefresh = true,
		registerForDefaults = false,
	}
	
	local optionsTable = {
		-- Style Material
		{
			type = "header",
			name = "Automatically Choose Style Material",
			width = "full",
		},
		{
			type = "checkbox",
			name = "Choose by Largest Quantity",
			tooltip = "Enables or disables the automated behavior of defaulting the style material to be the one with the largest quantity.",
			getFunc = function() return self.sv.enabled end,
			setFunc = function(value)
				self.sv.enabled = value
			end,
			width = "full",
		},
		{
			type = "dropdown",
			name = "Style Reset Frequency",
			tooltip = "Sets how frequently the crafting style material will be automatically changed. Automatic will change the style material each time a crafting window is opened.",
			warning = "Changing this dropdown will initially trigger the automatic selection of the default style material upon the first crafting station interaction.",
			choices = STYLE_RESET_MODE_STRINGS,
			disabled = function() return not self.sv.enabled end,
			getFunc = function() return STYLE_RESET_MODE_STRINGS[self.sv.styleResetMode] end,
			setFunc = function(value)
				self.sv.styleResetMode = STYLE_RESET_MODES[value]
				
				self.zoneHasChanged = true
			end,
			width = "full",
		},
		
		-- Refinement
		{
			type = "header",
			name = "Raw Material Refinement",
			width = "full",
		},
		{
			type = "checkbox",
			name = "Only Show Refinable",
			tooltip = "Hide raw materials which have a stack count less than the minimum amount required to refine.",
			getFunc = function() return self.sv.enabledRefinement end,
			setFunc = function(value)
				self.sv.enabledRefinement = value
				
				if (value) then
					self:AddRefinementHooks()
				else
					if (self.SMITHING_GAMEPAD_refinementPanel_inventory_Refresh) then
						----SMITHING.refinementPanel.inventory.Refresh = self.SMITHING_refinementPanel_inventory_Refresh
						----ZO_SharedSmithingExtraction_IsExtractableOrRefinableItem = ZO_SharedSmithingExtraction_IsExtractableOrRefinableItem_Original
						ZO_SharedSmithingExtraction_IsRefinableItem = ZO_SharedSmithingExtraction_IsRefinableItem_Original
						
						SMITHING_GAMEPAD.refinementPanel.inventory.Refresh = self.SMITHING_GAMEPAD_refinementPanel_inventory_Refresh
					else
						ReloadUI()
					end
				end
				
			end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Fast Refinement / Deconstruction",
			tooltip = "Automatically select the refinement material or deconstruction material after each action or upon initially opening the refinement or deconstruction panel",
			--disabled = function() return true end,
			getFunc = function() return self.sv.enabledAutoSelectRefinement end,
			setFunc = function(value)
				self.sv.enabledAutoSelectRefinement = value
				
				if (value) then
				--	self:InitializeRefinement()
				else
					ReloadUI()
				end
			
			end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Deconstruction Optimized Sort",
			tooltip = "The items are ordered in a more logical manner within the deconstruction panel (i.e. set items and high value items are near the end of the list)",
			getFunc = function() return self.sv.enableOptimizedDeconSort end,
			setFunc = function(value)
				self.sv.enableOptimizedDeconSort = value
			end,
			width = "full",
		},
		
		-- Auto Max Improvement
		{
			type = "header",
			name = "Item Improvement",
			width = "full",
		},
		{
			type = "checkbox",
			name = "Automatic Max Improvement",
			tooltip = "Prepopulates the amount of improvement materials to the maximum by default (i.e. to ensure 100% improvement chance by default when resources are sufficient).",
			getFunc = function() return self.sv.enabledMaxImprovement end,
			setFunc = function(value)
				self.sv.enabledMaxImprovement = value
				
				if (value) then
					self:InitializeImprovement()
				else
					ReloadUI()
				end
			
			end,
			width = "full",
		},
	}
	
	table.insert(optionsTable, {
		type = "submenu",
		name = "Crafting Style Materials",
		tooltip = "Select which style stones are used for \"Automatically Choose Style Material\" option above (note: if the automatic style feature above is disabled then these options are ignored)",
		controls = self:StyleCompiler(),
		reference = "EnhancedCraftingStyleSubmenu",
	})

	LAM:RegisterAddonPanel(self.name, panelData)
	LAM:RegisterOptionControls(self.name, optionsTable)
end

function ArchCraftingStyle:SetStyleIndexGP(styleIndex)
	if SMITHING_GAMEPAD and SMITHING_GAMEPAD.creationPanel and SMITHING_GAMEPAD.creationPanel.styleList then
		SMITHING_GAMEPAD.creationPanel.styleList:SetSelectedDataIndex(styleIndex)
		SMITHING_GAMEPAD.creationPanel.styleList:RefreshVisible()
	end
end

--Needs to be refactored to reuse code from keyboard version!
function ArchCraftingStyle:UpdateCraftingStyleByItemCountGP()
	local function maxStyle(piece)
		local max = -1
		for i, v in pairs(self.sv.styles) do
			if GetCurrentSmithingStyleItemCount(i)>GetCurrentSmithingStyleItemCount(max) and IsSmithingStyleKnown(i, piece) then 
				if GetCurrentSmithingStyleItemCount(i)>0 and v then
					max = i
				end
			end
		end
		return max
	end

	if not SMITHING_GAMEPAD or not SMITHING_GAMEPAD.creationPanel or not SMITHING_GAMEPAD.creationPanel.GetSelectedPatternIndex then
		return
	end

	local patternIndex = SMITHING_GAMEPAD.creationPanel:GetSelectedPatternIndex()
	
	if not patternIndex then
		return
	end

	local maxItemStyle = maxStyle(patternIndex)
	
	if maxItemStyle and maxItemStyle ~= nil and maxItemStyle >= 0 then
		local targetItemStyleIndex = GetStyleIndex(maxItemStyle)
		
		if targetItemStyleIndex and targetItemStyleIndex ~= nil and targetItemStyleIndex >= 1 then
			self:SetStyleIndex(targetItemStyleIndex)
		end
	end
end

function ArchCraftingStyle:SetStyleIndex(styleIndex)
	if SMITHING and SMITHING.creationPanel and SMITHING.creationPanel.styleList then
		SMITHING.creationPanel.styleList:SetSelectedDataIndex(styleIndex)
		SMITHING.creationPanel.styleList:RefreshVisible()
	end
end

function ArchCraftingStyle:UpdateCraftingStyleByItemCount()
	local function maxStyle(piece)
		local max = -1
		for i, v in pairs(self.sv.styles) do
			if GetCurrentSmithingStyleItemCount(i)>GetCurrentSmithingStyleItemCount(max) and IsSmithingStyleKnown(i, piece) then 
				if GetCurrentSmithingStyleItemCount(i)>0 and v then
					max = i
				end
			end
		end
		return max
	end

	if not SMITHING or not SMITHING.creationPanel or not SMITHING.creationPanel.GetSelectedPatternIndex then
		return
	end

	local patternIndex = SMITHING.creationPanel:GetSelectedPatternIndex()
	
	if not patternIndex then
		return
	end

	local maxItemStyle = maxStyle(patternIndex)

	if maxItemStyle and maxItemStyle ~= nil and maxItemStyle >= 0 then
		local targetItemStyleIndex = GetStyleIndex(maxItemStyle)
	
		if targetItemStyleIndex and targetItemStyleIndex ~= nil and targetItemStyleIndex >= 1 then
			self:SetStyleIndex(targetItemStyleIndex)
		end
	end
end

function GetCurrentStyleIndexMapping()
	local SC
	if IsInGamepadPreferredMode() then
		SC = SMITHING_GAMEPAD
	else
		SC = SMITHING
	end

	if not SC or not SC.creationPanel or not SC.creationPanel.styleList or not SC.creationPanel.styleList.list then
		return {}
	end

	-- "itemStyleIndices" (key: itemStyle, value: styleIndex)
	local itemStyleIndices = {}

	for i, v in pairs(SC.creationPanel.styleList.list) do
		if i and v and v.itemStyleId then
			--itemStyleIndices[v.itemStyle] = v.styleIndex;
			--itemStyleIndices[v.styleIndex] = v.itemStyle;
			itemStyleIndices[v.itemStyleId] = i;
		end
	end

	-- returns the mapping between itemStyle and styleIndex
	return itemStyleIndices
end

function GetStyleIndex(itemStyle)
	local styleIndexMapping = GetCurrentStyleIndexMapping()

	if styleIndexMapping and styleIndexMapping ~= nil and itemStyle and itemStyle ~= nil then
		return styleIndexMapping[itemStyle]
	end

	return 0
end

-- Global Pollution
function ZO_SharedSmithingExtraction_IsExtractableOrRefinableItem_Original(bagId, slotIndex)
	return CanItemBeSmithingExtractedOrRefined(bagId, slotIndex, GetCraftingInteractionType()) and not IsItemPlayerLocked(bagId, slotIndex)
end

function ZO_SharedSmithingExtraction_IsRefinableItem_Original(bagId, slotIndex)
	return CanItemBeRefined(bagId, slotIndex, GetCraftingInteractionType())
end

function ZO_IsMinimumRefinementRawMaterial_Keyboard_Predicate(bagId, slotIndex)
	--local icon, stackCount, sellPrice, meetsUsageRequirement, locked, equipType, _, quality = GetItemInfo(bagId, slotIndex)
	--local _, itemType = GetItemCraftingInfo(bagId, slotIndex)
	--local itemType = GetItemType(bagId, slotIndex) -- Special DLC raw material items are item type 17
	--local stackCount = SMITHING_GAMEPAD.refinementPanel.inventory:GetStackCount(bagId, slotIndex)
	local itemLink = GetItemLink(bagId, slotIndex)
	local bagCount, bankCount, craftBagCount = GetItemLinkStacks(itemLink)
	local stackCount = bagCount + bankCount + craftBagCount
	local filterType = ZO_CraftingUtils_GetSmithingFilterFromItem(bagId, slotIndex)
	return CanItemBeSmithingExtractedOrRefined(bagId, slotIndex, GetCraftingInteractionType()) and not IsItemPlayerLocked(bagId, slotIndex) and ((filterType == ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS and stackCount >= GetRequiredSmithingRefinementStackSize()))
	--SMITHING_FILTER_TYPE_RAW_MATERIALS
	--ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS
end

--NOTE: THIS VERSION IS NO LONGER USED (use the function above)
function ZO_IsMinimumRefinementRawMaterial_Predicate(bagId, slotIndex)
	--local icon, stackCount, sellPrice, meetsUsageRequirement, locked, equipType, _, quality = GetItemInfo(bagId, slotIndex)
	--local _, itemType = GetItemCraftingInfo(bagId, slotIndex)
	--local itemType = GetItemType(bagId, slotIndex) -- Special DLC raw material items are item type 17
	--local stackCount = SMITHING_GAMEPAD.refinementPanel.inventory:GetStackCount(bagId, slotIndex)
	local itemLink = GetItemLink(bagId, slotIndex)
	local bagCount, bankCount, craftBagCount = GetItemLinkStacks(itemLink)
	local stackCount = bagCount + bankCount + craftBagCount
	local filterType = ZO_CraftingUtils_GetSmithingFilterFromItem(bagId, slotIndex)
	return CanItemBeSmithingExtractedOrRefined(bagId, slotIndex, GetCraftingInteractionType()) and not IsItemPlayerLocked(bagId, slotIndex) and ((filterType == ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS and stackCount >= GetRequiredSmithingRefinementStackSize()) or (filterType ~= ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS))
end

function ArchCraftingStyle:AddExtractionHooks()
	-- Save original function
	self.SMITHING_GAMEPAD_deconstructionPanel_inventory_Refresh = SMITHING_GAMEPAD.deconstructionPanel.inventory.Refresh
	
	SMITHING_GAMEPAD.deconstructionPanel.inventory.Refresh = function(data)
		-- The remainder is boilerplate due to how ZOS coded the gamepad extraction list
		local validItemIds = SMITHING_GAMEPAD.deconstructionPanel.inventory:EnumerateInventorySlotsAndAddToScrollData(ZO_IsMinimumRefinementRawMaterial_Predicate, ZO_SharedSmithingExtraction_DoesItemPassFilter, SMITHING_GAMEPAD.deconstructionPanel.inventory.filterType, data)
		local function sortInventoryComparator(a, b)
			a.itemLink = a.itemLink or GetItemLink(a.bagId, a.slotIndex)
			b.itemLink = b.itemLink or GetItemLink(b.bagId, b.slotIndex)
			local aLinkBindType = GetItemLinkBindType(a.itemLink)
			local bLinkBindType = GetItemLinkBindType(b.itemLink)
			a.linkCrafted = a.linkCrafted or GetItemCreatorName(a.bagId, a.slotIndex)
			b.linkCrafted = b.linkCrafted or GetItemCreatorName(b.bagId, b.slotIndex)
			local _, aLinkSetInfo, _, _, _ = GetItemLinkSetInfo(a.itemLink)
			local _, bLinkSetInfo, _, _, _ = GetItemLinkSetInfo(b.itemLink)
			a.traitType = a.traitType or GetItemTrait(a.bagId, a.slotIndex)
			b.traitType = b.traitType or GetItemTrait(b.bagId, b.slotIndex)
			--d(a)
			return ((a.customSortData < b.customSortData) or
				(a.customSortData == b.customSortData and a.linkCrafted < b.linkCrafted) or
				(a.customSortData == b.customSortData and a.linkCrafted == b.linkCrafted and aLinkSetInfo < bLinkSetInfo) or
				(a.customSortData == b.customSortData and a.linkCrafted == b.linkCrafted and aLinkSetInfo == bLinkSetInfo and aLinkBindType < bLinkBindType) or
				(a.customSortData == b.customSortData and a.linkCrafted == b.linkCrafted and aLinkSetInfo == bLinkSetInfo and aLinkBindType == bLinkBindType and a.sellPrice < b.sellPrice) or
				(a.customSortData == b.customSortData and a.linkCrafted == b.linkCrafted and aLinkSetInfo == bLinkSetInfo and aLinkBindType == bLinkBindType and a.sellPrice == b.sellPrice and a.quality < b.quality) or
				(a.customSortData == b.customSortData and a.linkCrafted == b.linkCrafted and aLinkSetInfo == bLinkSetInfo and aLinkBindType == bLinkBindType and a.sellPrice == b.sellPrice and a.quality == b.quality and a.traitType < b.traitType) or
				(a.customSortData == b.customSortData and a.linkCrafted == b.linkCrafted and aLinkSetInfo == bLinkSetInfo and aLinkBindType == bLinkBindType and a.sellPrice == b.sellPrice and a.quality == b.quality and a.traitType == b.traitType and a.itemType < b.itemType) or
				(a.customSortData == b.customSortData and a.linkCrafted == b.linkCrafted and aLinkSetInfo == bLinkSetInfo and aLinkBindType == bLinkBindType and a.sellPrice == b.sellPrice and a.quality == b.quality and a.traitType == b.traitType and a.itemType == b.itemType and a.text < b.text) or
				(a.customSortData == b.customSortData and a.linkCrafted == b.linkCrafted and aLinkSetInfo == bLinkSetInfo and aLinkBindType == bLinkBindType and a.sellPrice == b.sellPrice and a.quality == b.quality and a.traitType == b.traitType and a.itemType == b.itemType and a.text == b.text and GetItemUniqueId(a.bagId, a.slotIndex) < GetItemUniqueId(b.bagId, b.slotIndex)))
		end
		
		if self.sv.enableOptimizedDeconSort then
			table.sort(SMITHING_GAMEPAD.deconstructionPanel.inventory.list.dataList, sortInventoryComparator)
		end
		
		SMITHING_GAMEPAD.deconstructionPanel.inventory.owner:OnInventoryUpdate(validItemIds)
		
		-- handle no items in a filter cases / show text to the user
		--SMITHING_GAMEPAD.deconstructionPanel.inventory.noItemsLabel:SetHidden(#data > 0)
	end
end

function ArchCraftingStyle:AddRefinementHooks()
	-- Save original function
	self.SMITHING_GAMEPAD_refinementPanel_inventory_Refresh = SMITHING_GAMEPAD.refinementPanel.inventory.Refresh
	
	SMITHING_GAMEPAD.refinementPanel.inventory.Refresh = function(data)
		-- The remainder is boilerplate due to how ZOS coded the gamepad refinement list
		local validItemIds = SMITHING_GAMEPAD.refinementPanel.inventory:EnumerateInventorySlotsAndAddToScrollData(ZO_IsMinimumRefinementRawMaterial_Predicate, ZO_SharedSmithingExtraction_DoesItemPassFilter, SMITHING_GAMEPAD.refinementPanel.inventory.filterType, data)
		
		SMITHING_GAMEPAD.refinementPanel.inventory.owner:OnInventoryUpdate(validItemIds)
		
		-- handle no items in a filter cases / show text to the user
		--SMITHING_GAMEPAD.refinementPanel.inventory.noItemsLabel:SetHidden(#data > 0)
		
	end
	
--[[
	self.SMITHING_refinementPanel_inventory_Refresh = SMITHING.refinementPanel.inventory.Refresh

	SMITHING.refinementPanel.inventory.Refresh = function(data)
		local validItems
		if SMITHING.refinementPanel.inventory.filterType == SMITHING_FILTER_TYPE_RAW_MATERIALS then
			validItems = SMITHING.refinementPanel.inventory:EnumerateInventorySlotsAndAddToScrollData(ZO_IsMinimumRefinementRawMaterial_Keyboard_Predicate, ZO_SharedSmithingExtraction_DoesItemPassFilter, SMITHING.refinementPanel.inventory.filterType, data) --ZO_IsMinimumRefinementRawMaterial_Predicate
			
			SMITHING.refinementPanel.inventory.owner:OnInventoryUpdate(validItems) --, SMITHING.refinementPanel.inventory.filterType)
			
			SMITHING.refinementPanel.inventory:SetNoItemLabelHidden(#data > 0)
		else
			validItems = SMITHING.extractionPanel.inventory:GetIndividualInventorySlotsAndAddToScrollData(ZO_SharedSmithingExtraction_IsExtractableItem, ZO_SharedSmithingExtraction_DoesItemPassFilter, SMITHING.extractionPanel.inventory.filterType, data)
			
			SMITHING.extractionPanel.inventory.owner:OnInventoryUpdate(validItems, SMITHING.extractionPanel.inventory.filterType)
			
			SMITHING.extractionPanel.inventory:SetNoItemLabelHidden(#data > 0)
		end
		
		
	end]]
	
	-- Scary, but it works for now
	--ZO_SharedSmithingExtraction_IsExtractableOrRefinableItem = ZO_IsMinimumRefinementRawMaterial_Predicate
	
	ZO_SharedSmithingExtraction_IsRefinableItem = ZO_IsMinimumRefinementRawMaterial_Keyboard_Predicate
end

function ArchCraftingStyle:CheckStyleResetMode()
	return self.sv.styleResetMode == STYLE_RESET_MODE_AUTOMATIC or (self.sv.styleResetMode == STYLE_RESET_MODE_ON_ZONE and self.zoneHasChanged)
end

function ArchCraftingStyle:AddHooks()
	--KEYBOARD
	local origFunc = SMITHING.creationPanel.SetHidden
	
	SMITHING.creationPanel.SetHidden = function(...)
		origFunc(...)

		if not hidden and self.sv.enabled then
			if self:CheckStyleResetMode() then
				self:UpdateCraftingStyleByItemCount()
			end
			
			self.zoneHasChanged = false
		end
	end

	--GAMEPAD
	local origFuncGP = SMITHING_GAMEPAD.creationPanel.OnRefreshAllLists

	SMITHING_GAMEPAD.creationPanel.OnRefreshAllLists = function(...)
		origFuncGP(...)

		if self.sv.enabled then
			if self:CheckStyleResetMode() then
				self:UpdateCraftingStyleByItemCountGP()
			end
			
			self.zoneHasChanged = false
		end
	end
end

function ArchCraftingStyle:OnPlayerActivated()
	--d("|cFF0000Called!|r")
	self.zoneHasChanged = true
end

function ArchCraftingStyle:DefineColors()
	self.color = {}
	self.color.yellow = "|cFFFF00"
	self.color.lightYellow = "|cFFFFCC"
	self.color.green = "|c00FF00"
	self.color.magenta = "|cFF00FF"
	self.color.red = "|cFF0000"
	self.color.darkOrange = "|cFFA500"
	self.color.iconYellow = "|cFFFF33"
	self.color.iconOrange = "|cFF6600"
	self.color.grey = "|c626255"
	self.color.brightOrange = "|cE68A00"
end

function ArchCraftingStyle:Initialize(addonName)
	self:DefineColors()
	
	ZO_CreateStringId("SI_BINDING_NAME_ARCHCRAFTING_SEL_HIGHEST_Q_STYLE", self.color.darkOrange .. "Reset Style Material|r " .. self.color.magenta .. "- Set a hotkey to recalculate and select the style material with the highest quantity")
	
	self.name = addonName

	self.sv = {}

	local defaults = {
		enabled = true,
		styles = {true,true,true,true,true,true,true,true,true,true,},
		styleResetMode = STYLE_RESET_MODE_AUTOMATIC,
		
		enabledRefinement = true,
		enabledAutoSelectRefinement = false,
		enabledMaxImprovement = true,
		enableOptimizedDeconSort = false
	}

	self.sv = ZO_SavedVars:New(self.name.."_SavedVariables", 2, nil, defaults)
	
	self:SetupOptions(self.name)
	
	self.zoneHasChanged = true

	if self.sv.enabled then
		--if self.sv.styleResetMode == STYLE_RESET_MODE_ON_ZONE then
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function() self:OnPlayerActivated() end)
		--end
		
		self:AddHooks()
	end
	
	if self.sv.enabledRefinement then
		self:AddRefinementHooks()
	end
	
	if true then
		self:AddExtractionHooks()
	end
	
	if self.sv.enabledMaxImprovement then
		self:InitializeImprovement()
	end
	
	--if self.sv.enabledAutoSelectRefinement then
		--self:InitializeRefinement()
	--end
	
end

ARCH_CRAFTING = ArchCraftingStyle:New()

local function ArchCraftingStyle_Init(eventType, addonName)
	if addonName ~= "ArchCraftingStyle" then
		return
	end
	
	ARCH_CRAFTING:Initialize(addonName)
end

EVENT_MANAGER:RegisterForEvent("ArchCraftingStyleInit", EVENT_ADD_ON_LOADED, ArchCraftingStyle_Init)
