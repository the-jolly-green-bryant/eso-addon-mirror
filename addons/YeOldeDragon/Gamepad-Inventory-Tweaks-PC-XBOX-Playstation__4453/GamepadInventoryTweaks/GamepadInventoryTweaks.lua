local ADDON_NAME = "GamepadInventoryTweaks"
local INVENTORY_CATEGORY_LIST = "categoryList"
local INVENTORY_ITEM_LIST = "itemList"
local INVENTORY_CRAFT_BAG_LIST = "craftBagList"
local INVENTORY_VENGEANCE_CATEGORY_LIST = "vengeanceCategoryList"
local INVENTORY_VENGEANCE_ITEM_LIST = "vengeanceItemList"

local ACTIVE_ROW_ALPHA = 1.0
local DIMMED_ROW_ALPHA = 0.1
local TRACE_ENABLED = false

-- Visual fake category bar tuning (easy to tweak later)
local VISUAL_FILTER_BAR_VERTICAL_OFFSET = 70
local VISUAL_FILTER_BAR_VERTICAL_OFFSET_WITH_SEARCH = 70
local VISUAL_FILTER_BAR_VERTICAL_OFFSET_WITHOUT_SEARCH = 70
local VISUAL_FILTER_BAR_CRAFT_BAG_EXTRA_OFFSET_WITH_SEARCH = 40
local VISUAL_FILTER_BAR_TITLE_OFFSET_Y = -2
local VISUAL_FILTER_BAR_SEARCH_GAP_Y = 0
local VISUAL_FILTER_BAR_TOP_DIVIDER_OFFSET_Y = -26
local VISUAL_FILTER_BAR_MAX_VISIBLE_PIPS = 9
local VISUAL_FILTER_BAR_COUNTER_OFFSET_X = -8
local VISUAL_FILTER_BAR_COUNTER_OFFSET_Y = -2

local logger

local function InitLogger()
	if logger then
		return
	end

	if LibDebugLogger and type(LibDebugLogger.Create) == "function" then
		logger = LibDebugLogger:Create(ADDON_NAME)
		if TRACE_ENABLED and logger and type(logger.SetMinLevelOverride) == "function" and LibDebugLogger.LOG_LEVEL_DEBUG then
			logger:SetMinLevelOverride(LibDebugLogger.LOG_LEVEL_DEBUG)
		end
	end
end

local function FormatTrace(...)
	local args = { ... }
	if #args == 0 then
		return ""
	end

	if type(args[1]) == "string" and #args > 1 then
		local ok, formatted = pcall(string.format, unpack(args))
		if ok then
			return formatted
		end
	end

	for i = 1, #args do
		args[i] = tostring(args[i])
	end
	return table.concat(args, " ")
end

local function TraceDebug(...)
	if not (TRACE_ENABLED and logger and logger.Debug) then
		return
	end
	logger:Debug(FormatTrace(...))
end

local function TraceInfo(...)
	if not (TRACE_ENABLED and logger and logger.Info) then
		return
	end
	logger:Info(FormatTrace(...))
end

local function IsFeatureEnabled()
	return GamepadInventoryTweaks.SV and GamepadInventoryTweaks.SV.EnableActiveCategoryOnly
end

local function IsHideMundusEnabled()
	return GamepadInventoryTweaks.SV and GamepadInventoryTweaks.SV.HideMundusInInventoryMenu
end

local function IsSupportedItemListType(listType)
	return listType == INVENTORY_ITEM_LIST
		or listType == INVENTORY_CRAFT_BAG_LIST
		or listType == INVENTORY_VENGEANCE_ITEM_LIST
end

local function IsInventoryPageListType(listType)
	return listType == INVENTORY_CATEGORY_LIST
		or listType == INVENTORY_ITEM_LIST
		or listType == INVENTORY_CRAFT_BAG_LIST
		or listType == INVENTORY_VENGEANCE_CATEGORY_LIST
		or listType == INVENTORY_VENGEANCE_ITEM_LIST
end

local function IsReturnNavigation(fromListType, toListType)
	return (fromListType == INVENTORY_ITEM_LIST and toListType == INVENTORY_CATEGORY_LIST)
		or (fromListType == INVENTORY_VENGEANCE_ITEM_LIST and toListType == INVENTORY_VENGEANCE_CATEGORY_LIST)
end

local function IsSupportedItemContext(inventory)
	return inventory and IsSupportedItemListType(inventory.currentListType)
end

local function IsShowSearchAllInventoryPagesEnabled()
	-- Backward-compatible: stored value is Hide*, UI now exposes Show* semantics.
	return not (GamepadInventoryTweaks.SV and GamepadInventoryTweaks.SV.HideSearchOnAllInventoryPages)
end

local function IsShowSearchCraftBagEnabled()
	-- Backward-compatible: stored value is Hide*, UI now exposes Show* semantics.
	return not (GamepadInventoryTweaks.SV and GamepadInventoryTweaks.SV.HideSearchOnCraftBagPage)
end

local function IsShowSearchBankEnabled()
	-- Backward-compatible: stored value is Hide*, UI now exposes Show* semantics.
	return not (GamepadInventoryTweaks.SV and GamepadInventoryTweaks.SV.HideSearchOnBankPage)
end

local function IsShowSearchGuildBankEnabled()
	-- Backward-compatible: stored value is Hide*, UI now exposes Show* semantics.
	return not (GamepadInventoryTweaks.SV and GamepadInventoryTweaks.SV.HideSearchOnGuildBankPage)
end

local function ShouldHideInventorySearch(inventory)
	if not (inventory and inventory.currentListType) then
		return false
	end

	local listType = inventory.currentListType

	-- Craft Bag option has priority over the global inventory option.
	if listType == INVENTORY_CRAFT_BAG_LIST then
		return not IsShowSearchCraftBagEnabled()
	end

	local showAllPages = IsShowSearchAllInventoryPagesEnabled()
	if (not showAllPages) and IsInventoryPageListType(listType) then
		return true
	end

	return false
end

local function ApplyInventorySearchVisibility(inventory)
	if not (inventory and type(inventory.SetTextSearchEntryHidden) == "function") then
		return
	end

	-- Important: when switching between inventory pages while the visual bar stays visible,
	-- the search control may still be anchored under the previous bar position.
	-- Restore its original anchor first to avoid cumulative vertical drift.
	local bars = GamepadInventoryTweaks.visualBars
	local inventoryBar = bars and bars["inventory"]
	if inventoryBar and inventoryBar.searchCtrl and inventoryBar.searchOrigRelTo then
		inventoryBar.searchCtrl:ClearAnchors()
		inventoryBar.searchCtrl:SetAnchor(TOPLEFT, inventoryBar.searchOrigRelTo, BOTTOMLEFT, inventoryBar.searchOrigOffsetX or 0, inventoryBar.searchOrigOffsetY or 0)
	end

	inventory:SetTextSearchEntryHidden(ShouldHideInventorySearch(inventory))
	if bars and bars["inventory"] then
		bars["inventory"].searchCtrl = nil
		bars["inventory"].searchOrigRelTo = nil
		bars["inventory"].searchOrigOffsetX = nil
		bars["inventory"].searchOrigOffsetY = nil
	end
end

local function GetGuildBankCurrentList(guildBank)
	return guildBank and guildBank.GetCurrentList and guildBank:GetCurrentList() or nil
end

local function IsGuildBankContextActive(guildBank)
	if not guildBank then
		return false
	end

	if type(IsGuildBankOpen) == "function" and not IsGuildBankOpen() then
		return false
	end

	if guildBank.scene and guildBank.scene.IsShowing and not guildBank.scene:IsShowing() then
		return false
	end

	return true
end

local function IsSupportedGuildBankList(guildBank, list)
	return guildBank and list and (list == guildBank.withdrawList or list == guildBank.depositList)
end

local function ShouldHideGuildBankSearch(guildBank)
	if not IsGuildBankContextActive(guildBank) then
		return false
	end

	local currentList = GetGuildBankCurrentList(guildBank)
	if not IsSupportedGuildBankList(guildBank, currentList) then
		return false
	end

	return not IsShowSearchGuildBankEnabled()
end

local function ApplyGuildBankSearchVisibility(guildBank)
	if not (guildBank and type(guildBank.SetTextSearchEntryHidden) == "function") then
		return
	end

	if not IsGuildBankContextActive(guildBank) then
		return
	end

	-- Important: when switching guild bank pages while the visual bar stays visible,
	-- the search control may still be anchored under the previous bar position.
	-- Restore its original anchor first to avoid cumulative vertical drift.
	local bars = GamepadInventoryTweaks.visualBars
	local guildBar = bars and bars["guildBank"]
	if guildBar and guildBar.searchCtrl and guildBar.searchOrigRelTo then
		guildBar.searchCtrl:ClearAnchors()
		guildBar.searchCtrl:SetAnchor(TOPLEFT, guildBar.searchOrigRelTo, BOTTOMLEFT, guildBar.searchOrigOffsetX or 0, guildBar.searchOrigOffsetY or 0)
	end

	guildBank:SetTextSearchEntryHidden(ShouldHideGuildBankSearch(guildBank))
	if bars and bars["guildBank"] then
		bars["guildBank"].searchCtrl = nil
		bars["guildBank"].searchOrigRelTo = nil
		bars["guildBank"].searchOrigOffsetX = nil
		bars["guildBank"].searchOrigOffsetY = nil
	end
end

local function GetBankCurrentList(banking)
	return banking and banking.GetCurrentList and banking:GetCurrentList() or nil
end

local function IsBankContextActive(banking)
	if not banking then
		return false
	end

	if type(IsBankOpen) == "function" and not IsBankOpen() then
		return false
	end

	if banking.scene and banking.scene.IsShowing and not banking.scene:IsShowing() then
		return false
	end

	return true
end

local function IsSupportedBankList(banking, list)
	return banking and list and (list == banking.withdrawList or list == banking.depositList)
end

local function ShouldHideBankSearch(banking)
	if not IsBankContextActive(banking) then
		return false
	end

	local currentList = GetBankCurrentList(banking)
	if not IsSupportedBankList(banking, currentList) then
		return false
	end

	return not IsShowSearchBankEnabled()
end

local function ApplyBankSearchVisibility(banking)
	if not (banking and type(banking.SetTextSearchEntryHidden) == "function") then
		return
	end

	if not IsBankContextActive(banking) then
		return
	end

	-- Important: when switching bank pages while the visual bar stays visible,
	-- the search control may still be anchored under the previous bar position.
	-- Restore its original anchor first to avoid cumulative vertical drift.
	local bars = GamepadInventoryTweaks.visualBars
	local bankBar = bars and bars["bank"]
	if bankBar and bankBar.searchCtrl and bankBar.searchOrigRelTo then
		bankBar.searchCtrl:ClearAnchors()
		bankBar.searchCtrl:SetAnchor(TOPLEFT, bankBar.searchOrigRelTo, BOTTOMLEFT, bankBar.searchOrigOffsetX or 0, bankBar.searchOrigOffsetY or 0)
	end

	banking:SetTextSearchEntryHidden(ShouldHideBankSearch(banking))
	if bars and bars["bank"] then
		bars["bank"].searchCtrl = nil
		bars["bank"].searchOrigRelTo = nil
		bars["bank"].searchOrigOffsetX = nil
		bars["bank"].searchOrigOffsetY = nil
	end
end

local function IsBankTransferSlot(inventorySlot)
	if not (inventorySlot and type(IsBankOpen) == "function" and IsBankOpen()) then
		return false
	end

	local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
	if bagId == nil or slotIndex == nil then
		bagId = inventorySlot.bagId
		slotIndex = inventorySlot.slotIndex
	end

	if bagId == nil or slotIndex == nil then
		return false
	end

	if bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK then
		return true
	end

	return type(IsHouseBankBag) == "function" and IsHouseBankBag(bagId) or bagId == BAG_BACKPACK
end

local function TrySafeBankTransfer(inventorySlot)
	if not IsBankTransferSlot(inventorySlot) then
		return false
	end

	local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
	if bagId == nil or slotIndex == nil then
		bagId = inventorySlot.bagId
		slotIndex = inventorySlot.slotIndex
	end

	if bagId == nil or slotIndex == nil then
		return false
	end

	-- CRITICAL: Always use CallSecureProtected for protected functions.
	-- Direct function calls inherit the "insecure" taint from this context.
	if type(CallSecureProtected) ~= "function" then
		return false
	end

	local ok1, result1 = pcall(function()
		CallSecureProtected("PickupInventoryItem", bagId, slotIndex)
	end)

	if not ok1 then
		return false
	end

	local ok2, result2 = pcall(function()
		CallSecureProtected("PlaceInTransfer")
	end)

	return ok2
end

local function InstallBankPrimaryActionSafetyHook()
	if GamepadInventoryTweaks.BankPrimaryActionSafetyHookInstalled then
		return
	end

	SecurePostHook("ZO_InventorySlot_DiscoverSlotActionsFromActionList", function(inventorySlot, slotActions)
		if not IsBankTransferSlot(inventorySlot) then
			return
		end

		if not (slotActions and slotActions.m_slotActions) then
			return
		end

		local primaryAction = slotActions.m_slotActions[1]
		if not primaryAction then
			return
		end

		local originalCallback = primaryAction[2]
		if type(originalCallback) ~= "function" then
			return
		end

		if primaryAction.gitBankSafeWrapped then
			return
		end

		primaryAction[2] = function(...)
			local ok, result = pcall(originalCallback, ...)
			if ok then
				return result
			end

			local err = tostring(result)
			local shouldFallback = string.find(err, "function expected instead of nil", 1, true)
				or string.find(err, "PickupInventoryItem", 1, true)
				or string.find(err, "PlaceInTransfer", 1, true)

			if shouldFallback and TrySafeBankTransfer(inventorySlot) then
				TraceInfo("Bank primary action fallback applied for bag=%s slot=%s", tostring(inventorySlot.bagId), tostring(inventorySlot.slotIndex))
				return true
			end

			error(result)
		end

		primaryAction.gitBankSafeWrapped = true
	end)

	GamepadInventoryTweaks.BankPrimaryActionSafetyHookInstalled = true
end

local function ExtractItemData(selectedData)
	if not selectedData then
		return nil
	end
	return selectedData.itemData or selectedData
end

local function GetCurrentCategoryName(itemData)
	if not itemData then
		return nil
	end
	return itemData.bestGamepadItemCategoryName or ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription(itemData)
end

local function GetActiveSourceList(inventory)
	if not inventory then
		return nil
	end

	if inventory.currentListType == INVENTORY_CRAFT_BAG_LIST then
		return inventory.craftBagList
	elseif inventory.currentListType == INVENTORY_VENGEANCE_ITEM_LIST then
		return inventory.vengeanceItemList
	end

	return inventory.itemList
end

local function GetListForDescriptor(inventory, listDescriptor)
	if not inventory then
		return nil
	end

	if listDescriptor == INVENTORY_CATEGORY_LIST then
		return inventory.categoryList
	elseif listDescriptor == INVENTORY_ITEM_LIST then
		return inventory.itemList
	elseif listDescriptor == INVENTORY_CRAFT_BAG_LIST then
		return inventory.craftBagList
	elseif listDescriptor == INVENTORY_VENGEANCE_CATEGORY_LIST then
		return inventory.vengeanceCategoryList
	elseif listDescriptor == INVENTORY_VENGEANCE_ITEM_LIST then
		return inventory.vengeanceItemList
	end

	return nil
end

local function GetVisualList(sourceList)
	if not sourceList then
		return nil, "source list nil"
	end

	if type(sourceList.GetParametricList) == "function" then
		local parametricList = sourceList:GetParametricList()
		if parametricList then
			return parametricList, "source:GetParametricList()"
		end
	end

	if type(sourceList.GetNumEntries) == "function" and type(sourceList.GetEntryData) == "function" then
		return sourceList, "source list direct"
	end

	return nil, "unsupported list interface"
end

local function ResolveVisualList(inventory)
	local sourceList = GetActiveSourceList(inventory)
	if not sourceList and inventory and inventory.GetCurrentList then
		sourceList = inventory:GetCurrentList()
	end
	return GetVisualList(sourceList)
end

local function ResolveActiveCategoryName(inventory)
	if not IsSupportedItemContext(inventory) then
		return nil
	end

	if inventory.gitActiveCategoryName and inventory.gitActiveCategoryName ~= "" then
		return inventory.gitActiveCategoryName
	end

	local sourceList = GetActiveSourceList(inventory)
	local selectedData = sourceList and sourceList.GetTargetData and sourceList:GetTargetData() or nil
	local activeCategoryName = GetCurrentCategoryName(ExtractItemData(selectedData))
	inventory.gitActiveCategoryName = activeCategoryName
	return activeCategoryName
end

local function ResolveBankActiveCategoryName(banking)
	local currentList = GetBankCurrentList(banking)
	if not IsSupportedBankList(banking, currentList) then
		return nil
	end

	if banking.gbtActiveCategoryName and banking.gbtActiveCategoryName ~= "" then
		return banking.gbtActiveCategoryName
	end

	local selectedData = currentList.GetTargetData and currentList:GetTargetData() or nil
	local itemData = ExtractItemData(selectedData)
	if not itemData or itemData.bagId == nil or itemData.slotIndex == nil then
		banking.gbtActiveCategoryName = nil
		return nil
	end

	local activeCategoryName = GetCurrentCategoryName(itemData)
	banking.gbtActiveCategoryName = activeCategoryName
	return activeCategoryName
end

local function ResolveGuildBankActiveCategoryName(guildBank)
	if not IsGuildBankContextActive(guildBank) then
		return nil
	end

	local currentList = GetGuildBankCurrentList(guildBank)
	if not IsSupportedGuildBankList(guildBank, currentList) then
		return nil
	end

	if guildBank.gbtGuildActiveCategoryName and guildBank.gbtGuildActiveCategoryName ~= "" then
		return guildBank.gbtGuildActiveCategoryName
	end

	local selectedData = currentList.GetTargetData and currentList:GetTargetData() or nil
	local itemData = ExtractItemData(selectedData)
	if not itemData or itemData.bagId == nil or itemData.slotIndex == nil then
		guildBank.gbtGuildActiveCategoryName = nil
		return nil
	end

	local activeCategoryName = GetCurrentCategoryName(itemData)
	guildBank.gbtGuildActiveCategoryName = activeCategoryName
	return activeCategoryName
end

local function IsInventoryVisualBarContextActive(inventory)
	return IsSupportedItemContext(inventory)
end

local function IsBankCategorySortActive(banking)
	local currentList = GetBankCurrentList(banking)
	if not IsSupportedBankList(banking, currentList) then
		return false
	end

	return currentList.currentSortType == ITEM_LIST_SORT_TYPE_CATEGORY
end

local function IsGuildBankCategorySortActive(guildBank)
	if not IsGuildBankContextActive(guildBank) then
		return false
	end

	local currentList = GetGuildBankCurrentList(guildBank)
	if not IsSupportedGuildBankList(guildBank, currentList) then
		return false
	end

	return currentList.currentSortType == ITEM_LIST_SORT_TYPE_CATEGORY
end

local function BuildCategorySequenceFromVisualList(visualList)
	if not visualList then
		return {}
	end

	local getEntryData = visualList.GetEntryData
	local getNumEntries = visualList.GetNumEntries
	if type(getEntryData) ~= "function" or type(getNumEntries) ~= "function" then
		return {}
	end

	local categories = {}
	local seen = {}
	local numEntries = visualList:GetNumEntries()
	for i = 1, numEntries do
		local entryData = visualList:GetEntryData(i)
		local itemData = ExtractItemData(entryData)
		if itemData and itemData.bagId ~= nil and itemData.slotIndex ~= nil then
			local categoryName = GetCurrentCategoryName(itemData)
			if categoryName and categoryName ~= "" and not seen[categoryName] then
				seen[categoryName] = true
				table.insert(categories, categoryName)
			end
		end
	end

	return categories
end

local function FindActiveCategoryIndex(categories, activeCategoryName)
	if not (categories and activeCategoryName and activeCategoryName ~= "") then
		return 1
	end

	for i = 1, #categories do
		if categories[i] == activeCategoryName then
			return i
		end
	end

	return 1
end

local function ComputePipWindow(totalCategories, activeIndex)
	local windowSize = zo_min(totalCategories, VISUAL_FILTER_BAR_MAX_VISIBLE_PIPS)
	if totalCategories <= windowSize then
		return windowSize, activeIndex, activeIndex, 1
	end

	local halfWindow = zo_floor(windowSize / 2)
	local windowStart = activeIndex - halfWindow
	local maxWindowStart = totalCategories - windowSize + 1
	if windowStart < 1 then
		windowStart = 1
	elseif windowStart > maxWindowStart then
		windowStart = maxWindowStart
	end

	local visibleActiveIndex = activeIndex - windowStart + 1
	return windowSize, visibleActiveIndex, activeIndex, windowStart
end

local function EnsureVisualFilterBar(hostKey, headerControl)
	if not (headerControl and headerControl.GetName) then
		return nil
	end

	GamepadInventoryTweaks.visualBars = GamepadInventoryTweaks.visualBars or {}
	local existing = GamepadInventoryTweaks.visualBars[hostKey]
	if existing and existing.root and existing.root.GetParent and existing.root:GetParent() == headerControl then
		return existing
	end

	local barName = string.format("%s_%sFakeFilterBar", headerControl:GetName(), hostKey)
	local root = WINDOW_MANAGER:CreateControlFromVirtual(barName, headerControl, "ZO_GamepadHeaderHorizontalDividerWithTabs")

	local anchorBase = headerControl:GetNamedChild("DividerSimple")
		or headerControl:GetNamedChild("DividerPipped")
		or headerControl:GetNamedChild("TitleContainer")
		or headerControl

	root:ClearAnchors()
	root:SetAnchor(TOPLEFT, anchorBase, BOTTOMLEFT, 0, VISUAL_FILTER_BAR_VERTICAL_OFFSET)
	root:SetAnchor(TOPRIGHT, anchorBase, BOTTOMRIGHT, 0, VISUAL_FILTER_BAR_VERTICAL_OFFSET)
	root:SetHidden(true)

	local topDivider = WINDOW_MANAGER:CreateControlFromVirtual(barName .. "TopDivider", headerControl, "ZO_GamepadHeaderHorizontalDividerSimple")
	topDivider:ClearAnchors()
	topDivider:SetAnchor(BOTTOMLEFT, root, TOPLEFT, 0, VISUAL_FILTER_BAR_TOP_DIVIDER_OFFSET_Y)
	topDivider:SetAnchor(BOTTOMRIGHT, root, TOPRIGHT, 0, VISUAL_FILTER_BAR_TOP_DIVIDER_OFFSET_Y)
	topDivider:SetHidden(true)

	-- Force divider render above the category bar controls.
	local dividerCore = topDivider:GetNamedChild("Divider")
	if dividerCore then
		local function ElevateDividerTexture(texture)
			if texture then
				texture:SetDrawLayer(DL_OVERLAY)
				texture:SetDrawLevel(10)
			end
		end
		ElevateDividerTexture(dividerCore:GetNamedChild("Left"))
		ElevateDividerTexture(dividerCore:GetNamedChild("Center"))
		ElevateDividerTexture(dividerCore:GetNamedChild("Right"))
	end

	local title = WINDOW_MANAGER:CreateControlFromVirtual(barName .. "Title", root, "ZO_GamepadScreenHeaderContextTitleTextTemplate")
	title:ClearAnchors()
	title:SetAnchor(BOTTOM, root, TOP, 0, VISUAL_FILTER_BAR_TITLE_OFFSET_Y)
	title:SetText("")

	local counter = WINDOW_MANAGER:CreateControlFromVirtual(barName .. "Counter", root, "ZO_GamepadScreenHeaderContextTitleTextTemplate")
	counter:ClearAnchors()
	--counter:SetAnchor(BOTTOMRIGHT, root, TOPRIGHT, VISUAL_FILTER_BAR_COUNTER_OFFSET_X, VISUAL_FILTER_BAR_COUNTER_OFFSET_Y) -- right aligned on the top divider, with a fixed vertical gap, to avoid vertical drift when the search field is shown/hidden and the bar is repositioned
	counter:SetAnchor(TOP, root, BOTTOM, 0, 0) -- under bar, with a fixed vertical gap, to avoid vertical drift when the search field is shown/hidden and the bar is repositioned
	counter:SetText("")

	local leftIcon = root:GetNamedChild("LeftIcon")
	local rightIcon = root:GetNamedChild("RightIcon")
	if leftIcon and rightIcon then
		local leftDescriptor =
		{
			name = "",
			keybind = "UI_SHORTCUT_LEFT_TRIGGER",
			ethereal = true,
			narrateEthereal = false,
			callback = function() end,
		}
		local rightDescriptor =
		{
			name = "",
			keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
			ethereal = true,
			narrateEthereal = false,
			callback = function() end,
		}
		leftIcon:SetKeybindButtonDescriptor(leftDescriptor)
		rightIcon:SetKeybindButtonDescriptor(rightDescriptor)
	end

	local pipsControl = root:GetNamedChild("Pips")
	local pips = pipsControl and ZO_GamepadPipCreator:New(pipsControl) or nil

	local barData =
	{
		root = root,
		topDivider = topDivider,
		title = title,
		counter = counter,
		leftIcon = leftIcon,
		rightIcon = rightIcon,
		pips = pips,
		pipsControl = pipsControl,
		lastActiveCategoryName = nil,
		lastNumPips = nil,
		lastActiveIndex = nil,
		lastTotalCategories = nil,
		lastWindowStart = nil,
	}

	GamepadInventoryTweaks.visualBars[hostKey] = barData
	return barData
end

-- Positionne la barre juste au-dessus du champ de recherche (sous les données du header).
-- Doit être appelé APRÈS que ZO_GamepadGenericHeader_Refresh / RefreshData ait résolu ses anchors.
local function RepositionBarAboveSearch(hostKey, headerControl)
	local bars = GamepadInventoryTweaks.visualBars
	local bar = bars and bars[hostKey]
	if not (bar and bar.root and not bar.root:IsHidden()) then return end
	if bar.searchCtrl then return end  -- déjà repositionné

	local searchCtrl = headerControl and headerControl.headerFocusControl
	if not searchCtrl then return end

	-- Lire l'anchor original du search field (défini par AdjustHeaderFocusControlAnchors)
	local isValid, _, relTo, _, offsetX, offsetY = searchCtrl:GetAnchor(0)
	if not (isValid and relTo) then return end

	-- Sauvegarder pour restauration lors du masquage
	bar.searchCtrl       = searchCtrl
	bar.searchOrigRelTo  = relTo
	bar.searchOrigOffsetX = offsetX or 0
	bar.searchOrigOffsetY = offsetY or 0

	-- Calculer l'offset Y depuis le haut du header jusqu'au bas de relTo (= top du search)
	local searchIsHidden = searchCtrl:IsHidden()
	local verticalOffset = searchIsHidden and VISUAL_FILTER_BAR_VERTICAL_OFFSET_WITHOUT_SEARCH or VISUAL_FILTER_BAR_VERTICAL_OFFSET_WITH_SEARCH
	if not searchIsHidden and hostKey == "inventory" and GAMEPAD_INVENTORY and GAMEPAD_INVENTORY.currentListType == INVENTORY_CRAFT_BAG_LIST then
		verticalOffset = verticalOffset + VISUAL_FILTER_BAR_CRAFT_BAG_EXTRA_OFFSET_WITH_SEARCH
	end
	local yFromHeader = relTo:GetBottom() - headerControl:GetTop() + (offsetY or 0) + verticalOffset

	-- Ancrer la barre sur toute la largeur du header, à la hauteur du search
	bar.root:ClearAnchors()
	bar.root:SetAnchor(TOPLEFT,  headerControl, TOPLEFT,  0, yFromHeader)
	bar.root:SetAnchor(TOPRIGHT, headerControl, TOPRIGHT, 0, yFromHeader)

	-- Repousser le search vers le bas, sous la barre uniquement s'il est visible.
	-- S'il est masqué, on utilise juste sa position comme référence d'ancrage.
	if not searchCtrl:IsHidden() then
		searchCtrl:ClearAnchors()
		searchCtrl:SetAnchor(TOPLEFT, bar.root, BOTTOMLEFT, 0, VISUAL_FILTER_BAR_SEARCH_GAP_Y)
	end
end

local function HideVisualFilterBar(hostKey)
	local bars = GamepadInventoryTweaks.visualBars
	local bar = bars and bars[hostKey]
	if not bar or not bar.root then
		return
	end

	-- Restaurer l'anchor du search field si on l'avait déplacé
	if bar.searchCtrl and bar.searchOrigRelTo then
		bar.searchCtrl:ClearAnchors()
		bar.searchCtrl:SetAnchor(TOPLEFT, bar.searchOrigRelTo, BOTTOMLEFT, bar.searchOrigOffsetX or 0, bar.searchOrigOffsetY or 0)
		bar.searchCtrl       = nil
		bar.searchOrigRelTo  = nil
		bar.searchOrigOffsetX = nil
		bar.searchOrigOffsetY = nil
	end

	bar.root:SetHidden(true)
	if bar.topDivider then
		bar.topDivider:SetHidden(true)
	end
	if bar.title then
		bar.title:SetText("")
	end
	if bar.counter then
		bar.counter:SetText("")
	end
	if bar.pips then
		bar.pips:RefreshPips(0, 0)
	end
	if bar.leftIcon then
		bar.leftIcon:SetHidden(true)
	end
	if bar.rightIcon then
		bar.rightIcon:SetHidden(true)
	end
	bar.lastActiveCategoryName = nil
	bar.lastNumPips = nil
	bar.lastActiveIndex = nil
	bar.lastTotalCategories = nil
	bar.lastWindowStart = nil
end

local function UpdateVisualFilterBar(hostKey, headerControl, activeCategoryName, categories)
	if not IsFeatureEnabled() then
		HideVisualFilterBar(hostKey)
		return
	end

	local bar = EnsureVisualFilterBar(hostKey, headerControl)
	if not bar then
		return
	end

	if not categories or #categories == 0 or not activeCategoryName or activeCategoryName == "" then
		HideVisualFilterBar(hostKey)
		return
	end

	local totalCategories = #categories
	local activeIndex = FindActiveCategoryIndex(categories, activeCategoryName)
	local visiblePips, visibleActiveIndex, globalActiveIndex, windowStart = ComputePipWindow(totalCategories, activeIndex)

	bar.root:SetHidden(false)
	if bar.topDivider then
		bar.topDivider:SetHidden(false)
	end

	if bar.title and bar.lastActiveCategoryName ~= activeCategoryName then
		bar.title:SetText(zo_strupper(tostring(activeCategoryName)))
		bar.lastActiveCategoryName = activeCategoryName
	end

	if bar.leftIcon and bar.rightIcon then
		local showShoulders = totalCategories > 1
		bar.leftIcon:SetHidden(not showShoulders)
		bar.rightIcon:SetHidden(not showShoulders)
	end

	if bar.counter then
		bar.counter:SetText(string.format("%d/%d", globalActiveIndex, totalCategories))
	end

	if bar.pips and (bar.lastNumPips ~= visiblePips or bar.lastActiveIndex ~= visibleActiveIndex or bar.lastWindowStart ~= windowStart) then
		bar.pips:RefreshPips(visiblePips, visibleActiveIndex)
		bar.lastNumPips = visiblePips
		bar.lastActiveIndex = visibleActiveIndex
		bar.lastWindowStart = windowStart
		bar.lastTotalCategories = totalCategories
	end

	-- Positionner la barre au-dessus du search field (sous les données du header)
	RepositionBarAboveSearch(hostKey, headerControl)
end

local function UpdateInventoryVisualFilterBar(inventory)
	if not (inventory and inventory.header) then
		return
	end

	if not IsInventoryVisualBarContextActive(inventory) then
		HideVisualFilterBar("inventory")
		return
	end

	local visualList = ResolveVisualList(inventory)
	local categories = BuildCategorySequenceFromVisualList(visualList)
	local activeCategoryName = ResolveActiveCategoryName(inventory)
	UpdateVisualFilterBar("inventory", inventory.header, activeCategoryName, categories)
end

local function UpdateBankVisualFilterBar(banking)
	if not (banking and banking.header) then
		return
	end

	if not IsBankCategorySortActive(banking) then
		HideVisualFilterBar("bank")
		return
	end

	local currentList = GetBankCurrentList(banking)
	if not IsSupportedBankList(banking, currentList) then
		HideVisualFilterBar("bank")
		return
	end

	local visualList = currentList.list or currentList
	local categories = BuildCategorySequenceFromVisualList(visualList)
	local activeCategoryName = ResolveBankActiveCategoryName(banking)
	UpdateVisualFilterBar("bank", banking.header, activeCategoryName, categories)
end

local function UpdateGuildBankVisualFilterBar(guildBank)
	if not (guildBank and guildBank.header) then
		return
	end

	if not IsGuildBankCategorySortActive(guildBank) then
		HideVisualFilterBar("guildBank")
		return
	end

	local currentList = GetGuildBankCurrentList(guildBank)
	if not IsSupportedGuildBankList(guildBank, currentList) then
		HideVisualFilterBar("guildBank")
		return
	end

	local visualList = currentList.list or currentList
	local categories = BuildCategorySequenceFromVisualList(visualList)
	local activeCategoryName = ResolveGuildBankActiveCategoryName(guildBank)
	UpdateVisualFilterBar("guildBank", guildBank.header, activeCategoryName, categories)
end

local function RefreshListView(list)
	if type(list.RefreshVisible) == "function" then
		list:RefreshVisible()
	elseif type(list.Commit) == "function" then
		list:Commit()
	end
end

local function ResetListSelectionToTop(list)
	if not list then
		return
	end

	if type(list.SetFirstIndexSelected) == "function" then
		list:SetFirstIndexSelected(ZO_PARAMETRIC_MOVEMENT_TYPES and ZO_PARAMETRIC_MOVEMENT_TYPES.JUMP_PREVIOUS)
		return
	end

	if type(list.SetSelectedIndexWithoutAnimation) == "function" then
		list:SetSelectedIndexWithoutAnimation(1, true, false)
		return
	end

	if type(list.SetSelectedIndex) == "function" then
		list:SetSelectedIndex(1, true, false)
	end
end

local function FindFirstMatchingEntryIndex(list, predicate)
	if not (list and predicate) then
		return nil
	end

	local getEntryData = list.GetEntryData
	if type(getEntryData) ~= "function" then
		return nil
	end

	local entryCount
	if type(list.GetNumEntries) == "function" then
		entryCount = list:GetNumEntries()
	elseif type(list.GetNumItems) == "function" then
		entryCount = list:GetNumItems()
	end

	if not entryCount or entryCount <= 0 then
		return nil
	end

	for index = 1, entryCount do
		local entryData = list:GetEntryData(index)
		if entryData and predicate(entryData) then
			return index
		end
	end

	return nil
end

local function SetListSelectedIndex(list, index)
	if not (list and index and index >= 1) then
		return
	end

	if type(list.SetSelectedIndexWithoutAnimation) == "function" then
		list:SetSelectedIndexWithoutAnimation(index, true, false)
		return
	end

	if type(list.SetSelectedIndex) == "function" then
		list:SetSelectedIndex(index, true, false)
		return
	end

	if index == 1 then
		ResetListSelectionToTop(list)
	end
end

local function SelectPreferredInventoryRootCategory(list)
	local currencyIndex = FindFirstMatchingEntryIndex(list, function(entryData)
		return entryData.isCurrencyEntry == true
	end)

	if currencyIndex then
		SetListSelectedIndex(list, currencyIndex)
		return true
	end

	ResetListSelectionToTop(list)
	return false
end

local function RemoveMundusEntriesFromInventoryCategoryList(inventory)
	if not (inventory and inventory.categoryList and IsHideMundusEnabled()) then
		return
	end

	local categoryList = inventory.categoryList
	if type(categoryList.GetNumEntries) ~= "function" or type(categoryList.GetEntryData) ~= "function" or type(categoryList.RemoveEntry) ~= "function" then
		return
	end

	local removedAny = false
	for index = categoryList:GetNumEntries(), 1, -1 do
		local entryData = categoryList:GetEntryData(index)
		if entryData and entryData.isMundusEntry then
			categoryList:RemoveEntry(nil, entryData)
			removedAny = true
		end
	end

	if removedAny then
		if type(categoryList.Commit) == "function" then
			categoryList:Commit()
		end
		if inventory.currentListType == INVENTORY_CATEGORY_LIST then
			SelectPreferredInventoryRootCategory(categoryList)
		end
		TraceInfo("Mundus entries removed from inventory category menu")
	end
end

local function ApplyActiveCategoryFocus(inventory)
	local list, listSource = ResolveVisualList(inventory)
	if not list then
		TraceDebug("ApplyActiveCategoryFocus skipped (%s)", tostring(listSource))
		return
	end

	TraceDebug("ApplyActiveCategoryFocus deferred list source=%s", tostring(listSource))
	inventory.gitDeferredFocusToken = (inventory.gitDeferredFocusToken or 0) + 1
	local token = inventory.gitDeferredFocusToken
	zo_callLater(function()
		if not inventory or inventory.gitDeferredFocusToken ~= token then
			return
		end

		if inventory.control and inventory.control.IsHidden and inventory.control:IsHidden() then
			return
		end

		RefreshListView(list)
		UpdateInventoryVisualFilterBar(inventory)
	end, 0)
end

local function ApplyBankActiveCategoryFocus(banking)
	local currentList = GetBankCurrentList(banking)
	if not IsSupportedBankList(banking, currentList) then
		return
	end

	banking.gbtDeferredFocusToken = (banking.gbtDeferredFocusToken or 0) + 1
	local token = banking.gbtDeferredFocusToken
	zo_callLater(function()
		if not banking or banking.gbtDeferredFocusToken ~= token then
			return
		end

		if banking.control and banking.control.IsHidden and banking.control:IsHidden() then
			return
		end

		RefreshListView(currentList.list or currentList)
		UpdateBankVisualFilterBar(banking)
	end, 0)
end

local function ApplyGuildBankActiveCategoryFocus(guildBank)
	if not IsGuildBankContextActive(guildBank) then
		return
	end

	local currentList = GetGuildBankCurrentList(guildBank)
	if not IsSupportedGuildBankList(guildBank, currentList) then
		return
	end

	RefreshListView(currentList.list or currentList)
	UpdateGuildBankVisualFilterBar(guildBank)
end

local function InstallEntryVisualSetupHook()
	if GamepadInventoryTweaks.EntryVisualSetupHookInstalled then
		TraceDebug("InstallEntryVisualSetupHook skipped (already installed)")
		return
	end

	SecurePostHook("ZO_SharedGamepadEntry_OnSetup", function(control, data, selected)
		local inventory = GAMEPAD_INVENTORY
		local banking = GAMEPAD_BANKING
		if not (control and data) then
			return
		end

		local itemData = ExtractItemData(data)
		if not itemData then
			return
		end

		-- Keep this restricted to actual inventory slot entries.
		if itemData.bagId == nil or itemData.slotIndex == nil then
			return
		end

		local shouldDim = false
		local activeCategoryName
		if inventory and IsFeatureEnabled() and IsSupportedItemListType(inventory.currentListType) then
			activeCategoryName = ResolveActiveCategoryName(inventory)
			if activeCategoryName and activeCategoryName ~= "" then
				shouldDim = GetCurrentCategoryName(itemData) ~= activeCategoryName
			end
		elseif banking and IsFeatureEnabled() and IsSupportedBankList(banking, GetBankCurrentList(banking)) then
			activeCategoryName = ResolveBankActiveCategoryName(banking)
			if activeCategoryName and activeCategoryName ~= "" then
				shouldDim = GetCurrentCategoryName(itemData) ~= activeCategoryName
			end
		elseif GAMEPAD_GUILD_BANK and IsFeatureEnabled() and IsGuildBankContextActive(GAMEPAD_GUILD_BANK) and IsSupportedGuildBankList(GAMEPAD_GUILD_BANK, GetGuildBankCurrentList(GAMEPAD_GUILD_BANK)) then
			activeCategoryName = ResolveGuildBankActiveCategoryName(GAMEPAD_GUILD_BANK)
			if activeCategoryName and activeCategoryName ~= "" then
				shouldDim = GetCurrentCategoryName(itemData) ~= activeCategoryName
			end
		end

		local alpha = shouldDim and DIMMED_ROW_ALPHA or ACTIVE_ROW_ALPHA
		control:SetAlpha(alpha)

		local headerLabel = control.headerControl or control.header or control:GetNamedChild("Header")
		if headerLabel and headerLabel.SetAlpha then
			headerLabel:SetAlpha(alpha)
		end

		local icon = control.icon or control:GetNamedChild("Icon")
		if icon then
			if shouldDim then
				icon:SetColor(0.70, 0.70, 0.70, 1)
				if icon.SetDesaturation then
					icon:SetDesaturation(1)
				end
			else
				icon:SetColor(1, 1, 1, 1)
				if icon.SetDesaturation then
					icon:SetDesaturation(0)
				end
			end
		end

		TraceDebug(
			"EntrySetup shouldDim=%s alpha=%.2f item=%s category=%s active=%s selected=%s",
			tostring(shouldDim),
			alpha,
			tostring(itemData.name),
			tostring(GetCurrentCategoryName(itemData)),
			tostring(activeCategoryName),
			tostring(selected)
		)
	end)

	GamepadInventoryTweaks.EntryVisualSetupHookInstalled = true
	TraceInfo("InstallEntryVisualSetupHook installed")
end

local function InstallCategoryHeaderSetupHook()
	if GamepadInventoryTweaks.CategoryHeaderSetupHookInstalled then
		TraceDebug("InstallCategoryHeaderSetupHook skipped (already installed)")
		return
	end

	local function IsInsideTabBar(control)
		local current = control
		while current do
			if current.GetName then
				local name = current:GetName()
				if type(name) == "string" and string.find(name, "TabBar", 1, true) then
					return true
				end
			end
			current = current.GetParent and current:GetParent() or nil
		end
		return false
	end

	SecurePostHook("ZO_GamepadMenuHeaderTemplate_Setup", function(control, data)
		local inventory = GAMEPAD_INVENTORY
		local banking = GAMEPAD_BANKING
		if not (control and data) then
			return
		end

		-- Important: don't dim generic header/tab bar controls, only list category headers.
		if IsInsideTabBar(control) then
			return
		end

		if not IsFeatureEnabled() then
			return
		end

		local activeCategoryName
		if inventory and IsSupportedItemListType(inventory.currentListType) then
			activeCategoryName = ResolveActiveCategoryName(inventory)
		elseif banking and IsSupportedBankList(banking, GetBankCurrentList(banking)) then
			activeCategoryName = ResolveBankActiveCategoryName(banking)
		elseif GAMEPAD_GUILD_BANK and IsGuildBankContextActive(GAMEPAD_GUILD_BANK) and IsSupportedGuildBankList(GAMEPAD_GUILD_BANK, GetGuildBankCurrentList(GAMEPAD_GUILD_BANK)) then
			activeCategoryName = ResolveGuildBankActiveCategoryName(GAMEPAD_GUILD_BANK)
		else
			return
		end

		if not activeCategoryName or activeCategoryName == "" then
			return
		end

		local headerText = data.text
		if type(headerText) == "function" then
			headerText = headerText(data)
		end

		if type(headerText) ~= "string" or headerText == "" then
			return
		end

		local shouldDimHeader = headerText ~= activeCategoryName
		local alpha = shouldDimHeader and DIMMED_ROW_ALPHA or ACTIVE_ROW_ALPHA
		control:SetAlpha(alpha)
		if control.text and control.text.SetAlpha then
			control.text:SetAlpha(alpha)
		end

		TraceDebug("HeaderSetup shouldDim=%s alpha=%.2f header=%s active=%s", tostring(shouldDimHeader), alpha, tostring(headerText), tostring(activeCategoryName))
	end)

	GamepadInventoryTweaks.CategoryHeaderSetupHookInstalled = true
	TraceInfo("InstallCategoryHeaderSetupHook installed")
end

local function UpdateBankActiveCategoryFromSelection(banking, selectedData)
	if not banking then
		return
	end

	local currentList = GetBankCurrentList(banking)
	if not IsSupportedBankList(banking, currentList) or not IsFeatureEnabled() then
		banking.gbtActiveCategoryName = nil
		HideVisualFilterBar("bank")
		ApplyBankActiveCategoryFocus(banking)
		return
	end

	local itemData = ExtractItemData(selectedData)
	if not itemData or itemData.bagId == nil or itemData.slotIndex == nil then
		banking.gbtActiveCategoryName = nil
		UpdateBankVisualFilterBar(banking)
		ApplyBankActiveCategoryFocus(banking)
		return
	end

	banking.gbtActiveCategoryName = GetCurrentCategoryName(itemData)
	UpdateBankVisualFilterBar(banking)
	ApplyBankActiveCategoryFocus(banking)
end

local function UpdateGuildBankActiveCategoryFromSelection(guildBank, selectedData)
	if not guildBank then
		return
	end

	if not IsGuildBankContextActive(guildBank) then
		guildBank.gbtGuildActiveCategoryName = nil
		HideVisualFilterBar("guildBank")
		return
	end

	local currentList = GetGuildBankCurrentList(guildBank)
	if not IsSupportedGuildBankList(guildBank, currentList) or not IsFeatureEnabled() then
		guildBank.gbtGuildActiveCategoryName = nil
		HideVisualFilterBar("guildBank")
		return
	end

	local itemData = ExtractItemData(selectedData)
	if not itemData or itemData.bagId == nil or itemData.slotIndex == nil then
		guildBank.gbtGuildActiveCategoryName = nil
		UpdateGuildBankVisualFilterBar(guildBank)
		return
	end

	guildBank.gbtGuildActiveCategoryName = GetCurrentCategoryName(itemData)
	UpdateGuildBankVisualFilterBar(guildBank)
end

local function UpdateActiveCategoryFromSelection(inventory, selectedData)
	if not inventory then
		return
	end

	if not IsSupportedItemListType(inventory.currentListType) then
		TraceDebug("UpdateActiveCategoryFromSelection skipped currentListType=%s", tostring(inventory.currentListType))
		HideVisualFilterBar("inventory")
		return
	end

	if not IsFeatureEnabled() then
		inventory.gitActiveCategoryName = nil
		HideVisualFilterBar("inventory")
		ApplyActiveCategoryFocus(inventory)
		return
	end

	local itemData = ExtractItemData(selectedData)
	if not itemData then
		TraceDebug("UpdateActiveCategoryFromSelection skipped (no itemData)")
		UpdateInventoryVisualFilterBar(inventory)
		return
	end

	local newCategoryName = GetCurrentCategoryName(itemData)
	local categoryChanged = false
	if newCategoryName and newCategoryName ~= "" and inventory.gitActiveCategoryName ~= newCategoryName then
		inventory.gitActiveCategoryName = newCategoryName
		categoryChanged = true
		TraceInfo("Active category changed -> %s", tostring(newCategoryName))
	end

	UpdateInventoryVisualFilterBar(inventory)
	if categoryChanged then
		ApplyActiveCategoryFocus(inventory)
	end
end

local function InstallInventoryHooks()
	if GamepadInventoryTweaks.HooksInstalled then
		TraceDebug("InstallInventoryHooks skipped (already installed)")
		return true
	end

	if not GAMEPAD_INVENTORY then
		TraceDebug("InstallInventoryHooks deferred (GAMEPAD_INVENTORY nil)")
		return false
	end

	InstallEntryVisualSetupHook()
	InstallCategoryHeaderSetupHook()

	SecurePostHook(GAMEPAD_INVENTORY, "SetSelectedInventoryData", function(self, selectedData)
		TraceDebug("Hook:SetSelectedInventoryData item=%s", selectedData and selectedData.itemData and tostring(selectedData.itemData.name) or "nil")
		UpdateActiveCategoryFromSelection(self, selectedData)
	end)

	SecurePostHook(GAMEPAD_INVENTORY, "SwitchActiveList", function(self, listDescriptor, selectDefaultEntry)
		TraceDebug("Hook:SwitchActiveList descriptor=%s selectDefault=%s", tostring(listDescriptor), tostring(selectDefaultEntry))
		ApplyInventorySearchVisibility(self)

		if IsInventoryPageListType(listDescriptor) and not IsReturnNavigation(self.previousListType, listDescriptor) then
			local openedList = GetListForDescriptor(self, listDescriptor)
			if listDescriptor == INVENTORY_CATEGORY_LIST then
				SelectPreferredInventoryRootCategory(openedList)
			else
				ResetListSelectionToTop(openedList)
			end
		end

		if not IsSupportedItemListType(listDescriptor) then
			self.gitActiveCategoryName = nil
			HideVisualFilterBar("inventory")
			ApplyActiveCategoryFocus(self)
			return
		end

		if not IsFeatureEnabled() then
			self.gitActiveCategoryName = nil
			HideVisualFilterBar("inventory")
			ApplyActiveCategoryFocus(self)
			return
		end

		local sourceList = GetActiveSourceList(self)
		local selectedData = sourceList and sourceList.GetTargetData and sourceList:GetTargetData() or nil
		local itemData = ExtractItemData(selectedData)
		if itemData then
			self.gitActiveCategoryName = GetCurrentCategoryName(itemData)
		end

		UpdateInventoryVisualFilterBar(self)
		ApplyActiveCategoryFocus(self)
	end)

	SecurePostHook(GAMEPAD_INVENTORY, "RefreshActiveItemList", function(self)
		UpdateInventoryVisualFilterBar(self)
		ApplyActiveCategoryFocus(self)
	end)

	SecurePostHook(GAMEPAD_INVENTORY, "RefreshCraftBagList", function(self)
		UpdateInventoryVisualFilterBar(self)
		ApplyActiveCategoryFocus(self)
	end)

	SecurePostHook(GAMEPAD_INVENTORY, "RefreshActiveCategoryList", function(self, selectDefaultEntry, forceUpdate)
		RemoveMundusEntriesFromInventoryCategoryList(self)
		ApplyInventorySearchVisibility(self)
	end)

	-- Après chaque refresh du header, AdjustHeaderFocusControlAnchors réinitialise l'anchor
	-- du search field. On invalide notre cache et on repostionne la barre si elle est active.
	SecurePostHook(GAMEPAD_INVENTORY, "RefreshHeader", function(self)
		ApplyInventorySearchVisibility(self)
		if not IsFeatureEnabled() then return end
		local bars = GamepadInventoryTweaks.visualBars
		if bars and bars["inventory"] then
			bars["inventory"].searchCtrl      = nil
			bars["inventory"].searchOrigRelTo = nil
		end
		UpdateInventoryVisualFilterBar(self)
	end)

	GamepadInventoryTweaks.HooksInstalled = true
	TraceInfo("InstallInventoryHooks installed")
	return true
end

local function InstallBankHooks()
	if GamepadInventoryTweaks.BankHooksInstalled then
		TraceDebug("InstallBankHooks skipped (already installed)")
		return true
	end

	if not GAMEPAD_BANKING then
		TraceDebug("InstallBankHooks deferred (GAMEPAD_BANKING nil)")
		return false
	end

	InstallBankPrimaryActionSafetyHook()

	SecurePostHook(GAMEPAD_BANKING, "OnTargetChangedCallback", function(self, targetData, oldTargetData)
		UpdateBankActiveCategoryFromSelection(self, targetData)
		UpdateBankVisualFilterBar(self)
	end)

	SecurePostHook(GAMEPAD_BANKING, "OnCategoryChangedCallback", function(self, selectedData)
		ApplyBankSearchVisibility(self)
		local currentList = GetBankCurrentList(self)
		local targetData = currentList and currentList.GetTargetData and currentList:GetTargetData() or nil
		UpdateBankActiveCategoryFromSelection(self, targetData)
		UpdateBankVisualFilterBar(self)
	end)

	SecurePostHook(GAMEPAD_BANKING, "OnOpenBank", function(self, bankBag)
		ApplyBankSearchVisibility(self)
	end)

	-- Idem pour la banque : RefreshHeaderData réinitialise l'anchor du search field.
	SecurePostHook(GAMEPAD_BANKING, "RefreshHeaderData", function(self)
		ApplyBankSearchVisibility(self)
		if not IsFeatureEnabled() then return end
		local bars = GamepadInventoryTweaks.visualBars
		if bars and bars["bank"] then
			bars["bank"].searchCtrl      = nil
			bars["bank"].searchOrigRelTo = nil
		end
		UpdateBankVisualFilterBar(self)
	end)

	GamepadInventoryTweaks.BankHooksInstalled = true
	TraceInfo("InstallBankHooks installed")
	return true
end

local function InstallGuildBankHooks()
	if GamepadInventoryTweaks.GuildBankHooksInstalled then
		TraceDebug("InstallGuildBankHooks skipped (already installed)")
		return true
	end

	if not GAMEPAD_GUILD_BANK then
		TraceDebug("InstallGuildBankHooks deferred (GAMEPAD_GUILD_BANK nil)")
		return false
	end

	local function DeferGuildBankUpdate(callback)
		if type(callback) ~= "function" then
			return
		end
		zo_callLater(function()
			if IsGuildBankContextActive(GAMEPAD_GUILD_BANK) then
				callback()
			end
		end, 0)
	end

	SecurePostHook(GAMEPAD_GUILD_BANK, "OnTargetChangedCallback", function(self, targetData, oldTargetData)
		DeferGuildBankUpdate(function()
			UpdateGuildBankActiveCategoryFromSelection(self, targetData)
			UpdateGuildBankVisualFilterBar(self)
		end)
	end)

	SecurePostHook(GAMEPAD_GUILD_BANK, "OnCategoryChangedCallback", function(self, selectedData)
		DeferGuildBankUpdate(function()
			ApplyGuildBankSearchVisibility(self)
			local currentList = GetGuildBankCurrentList(self)
			local targetData = currentList and currentList.GetTargetData and currentList:GetTargetData() or nil
			UpdateGuildBankActiveCategoryFromSelection(self, targetData)
			UpdateGuildBankVisualFilterBar(self)
		end)
	end)

	SecurePostHook(GAMEPAD_GUILD_BANK, "RefreshGuildBank", function(self)
		DeferGuildBankUpdate(function()
			ApplyGuildBankSearchVisibility(self)
			UpdateGuildBankVisualFilterBar(self)
		end)
	end)

	-- Idem pour la banque de guilde : RefreshHeaderData réinitialise l'anchor du search field.
	SecurePostHook(GAMEPAD_GUILD_BANK, "RefreshHeaderData", function(self)
		DeferGuildBankUpdate(function()
			ApplyGuildBankSearchVisibility(self)
			if not IsFeatureEnabled() then return end
			local bars = GamepadInventoryTweaks.visualBars
			if bars and bars["guildBank"] then
				bars["guildBank"].searchCtrl      = nil
				bars["guildBank"].searchOrigRelTo = nil
			end
			UpdateGuildBankVisualFilterBar(self)
		end)
	end)

	GamepadInventoryTweaks.GuildBankHooksInstalled = true
	TraceInfo("InstallGuildBankHooks installed")
	return true
end

local function EnsureInventoryHooksInstalled()
	if InstallInventoryHooks() then
		return
	end

	local retryEventName = ADDON_NAME .. "_HOOK_RETRY"
	local attempts = 0
	EVENT_MANAGER:UnregisterForUpdate(retryEventName)
	EVENT_MANAGER:RegisterForUpdate(retryEventName, 250, function()
		attempts = attempts + 1
		if InstallInventoryHooks() or attempts >= 40 then
			EVENT_MANAGER:UnregisterForUpdate(retryEventName)
		end
	end)
end

local function EnsureBankHooksInstalled()
	if InstallBankHooks() then
		return
	end

	local retryEventName = ADDON_NAME .. "_BANK_HOOK_RETRY"
	local attempts = 0
	EVENT_MANAGER:UnregisterForUpdate(retryEventName)
	EVENT_MANAGER:RegisterForUpdate(retryEventName, 250, function()
		attempts = attempts + 1
		if InstallBankHooks() or attempts >= 40 then
			EVENT_MANAGER:UnregisterForUpdate(retryEventName)
		end
	end)
end

local function EnsureGuildBankHooksInstalled()
	if InstallGuildBankHooks() then
		return
	end

	local retryEventName = ADDON_NAME .. "_GUILD_BANK_HOOK_RETRY"
	local attempts = 0
	EVENT_MANAGER:UnregisterForUpdate(retryEventName)
	EVENT_MANAGER:RegisterForUpdate(retryEventName, 250, function()
		attempts = attempts + 1
		if InstallGuildBankHooks() or attempts >= 40 then
			EVENT_MANAGER:UnregisterForUpdate(retryEventName)
		end
	end)
end

local function RegisterOptions()
	if type(GamepadInventoryTweaks.RegisterOptions) ~= "function" then
		return
	end

	GamepadInventoryTweaks.CreateSettingsMenu(
		{
			ApplyInventorySearchVisibility = ApplyInventorySearchVisibility,
			ApplyBankSearchVisibility = ApplyBankSearchVisibility,
			ApplyGuildBankSearchVisibility = ApplyGuildBankSearchVisibility,
			UpdateInventoryVisualFilterBar = UpdateInventoryVisualFilterBar,
			ApplyActiveCategoryFocus = ApplyActiveCategoryFocus,
			UpdateBankVisualFilterBar = UpdateBankVisualFilterBar,
			ApplyBankActiveCategoryFocus = ApplyBankActiveCategoryFocus,
			UpdateGuildBankVisualFilterBar = UpdateGuildBankVisualFilterBar,
			ApplyGuildBankActiveCategoryFocus = ApplyGuildBankActiveCategoryFocus,
		}
	)
end

local function InitializeExtension()
	InitLogger()

	GamepadInventoryTweaks.SV = ZO_SavedVars:NewAccountWide(
		GamepadInventoryTweaks.SavedVarName,
		GamepadInventoryTweaks.SavedVarVersion,
		nil,
		GamepadInventoryTweaks.DefaultSettings
	)

	EnsureInventoryHooksInstalled()
	EnsureBankHooksInstalled()
	EnsureGuildBankHooksInstalled()
	RegisterOptions()

	EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED)
		EnsureInventoryHooksInstalled()
		EnsureBankHooksInstalled()
		EnsureGuildBankHooksInstalled()
		if GAMEPAD_INVENTORY then
			ApplyInventorySearchVisibility(GAMEPAD_INVENTORY)
		end
		if GAMEPAD_BANKING then
			ApplyBankSearchVisibility(GAMEPAD_BANKING)
		end
		if GAMEPAD_GUILD_BANK then
			ApplyGuildBankSearchVisibility(GAMEPAD_GUILD_BANK)
		end
	end)

	EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_MODE_CHANGED", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function(_, isGamepadPreferred)
		if isGamepadPreferred then
			EnsureInventoryHooksInstalled()
			EnsureBankHooksInstalled()
			EnsureGuildBankHooksInstalled()
			if GAMEPAD_INVENTORY then
				ApplyInventorySearchVisibility(GAMEPAD_INVENTORY)
				UpdateInventoryVisualFilterBar(GAMEPAD_INVENTORY)
			end
			if GAMEPAD_BANKING then
				ApplyBankSearchVisibility(GAMEPAD_BANKING)
				UpdateBankVisualFilterBar(GAMEPAD_BANKING)
			end
			if GAMEPAD_GUILD_BANK then
				ApplyGuildBankSearchVisibility(GAMEPAD_GUILD_BANK)
				UpdateGuildBankVisualFilterBar(GAMEPAD_GUILD_BANK)
			end
		else
			HideVisualFilterBar("inventory")
			HideVisualFilterBar("bank")
			HideVisualFilterBar("guildBank")
		end
	end)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, addonName)
	if addonName ~= ADDON_NAME then
		return
	end

	InitLogger()
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
	InitializeExtension()
end)