--[[
Author: Jarth
Filename: CollectionBars.lua
]] --
-------------------------------------------------------------------------------------------------
-- VARIABLES --
-------------------------------------------------------------------------------------------------
local base = CollectionBars
local texts = base.Texts

-------------------------------------------------------------------------------------------------
--  FUNCTIONS --
-------------------------------------------------------------------------------------------------

function base.OnAddOnLoaded(_, addonName)
	base:InitializeLog("OnAddOnLoaded", addonName)

	if addonName == base.Addon.Name then
		base:SetSavedSettings() -- Incomplete saved settings - For SetLogsEnabled
		base:SetLogsEnabled()
		base:GenerateCategories()
		base:SetSavedSettings() -- Complete saved settings
		base:InitializeBindings()
		base:InitializeCombineFrame()
		base:InitializeWithSavedData()
		base:InitializeSettingsSlash()

		EVENT_MANAGER:UnregisterForEvent(base.Addon.Name, EVENT_ADD_ON_LOADED)
	end

	base:Info("OnAddOnLoaded:end", addonName)
end

function base:InitializeWithSavedData()
	base:Debug("InitializeWithSavedData")

	for categoryId, category in pairs(base.Categories) do
		category.Saved = base.Saved.Categories[categoryId]

		if category.Saved.Enabled then
			base:InitializeCategory(category)
		end
	end

	base:InitializeCombine()
	base:RestoreCombine()
end

function base:InitializeCategory(category)
	base:Debug("InitializeCategory", category)

	base:CreateCategory(category)
	base:SetupLabel(category)
	base:RestoreFrame(category)
end

function base:InitializeCombineFrame()
	base:Debug("InitializeCombineFrame")

	base.Global.Combine.Frames.Frame = base:GetFrame(texts.CombineFrameName, texts.CombineFrameName)
	base.Global.Combine.Frames.HideAll = base:GetFrame(texts.CombineFrameNameHideAll, texts.CombineFrameNameHideAll)
end

function base:CreateCategory(category)
	base:Debug("CreateCategory", category)

	category.Collection = {}
	category.CollectionOrdered = {}
	category.Unlocked = GetTotalUnlockedCollectiblesByCategoryType(category.CategoryType)

	if category.Unlocked > base.Global.HighestUnlocked then
		base.Global.HighestUnlocked = category.Unlocked
	end

	for _, collectibleData in ZO_CollectibleCategoryData.SortedCollectibleIterator(category.CategoryData, {ZO_CollectibleData.IsShownInCollection}) do
		local isUnlocked = collectibleData:IsUnlocked()
		-- TODO: Insert if new, update if exists...
		if isUnlocked or category.Saved.Menu.ShowDisabled then
			local collectibleId = collectibleData:GetId()
			-- TODO: IMPLEMENT BETTER TOOLTIPS...     function ZO_Tooltip:LayoutCollectible(collectibleId, deprecatedCollectionName, collectibleName, collectibleNickname, isPurchasable, description, hint, deprecatedArg, categoryType, showVisualLayerInfo, cooldownSecondsRemaining, showBlockReason)
			category.Collection[collectibleId] = {
				Id = collectibleId,
				Name = collectibleData:GetName(),
				EnabledTexture = collectibleData:GetIcon(),
				Disabled = not isUnlocked,
				Tooltip = string.format("%s\n%s", collectibleData:GetDescription(), collectibleData:GetHint()),
				CollectibleData = collectibleData
			}
			table.insert(category.CollectionOrdered, category.Collection[collectibleId])
		end
	end

	category.Frames.Frame = base:GetFrame(string.format(texts.FormatCategoryName, category.Id), string.format(texts.FormatAbbreviationLowDash, "Frame"))
end

function base:RestoreFrames()
	base:Debug("RestoreFrames")

	for _, category in pairs(base.Categories) do
		base:RestoreFrame(category)
	end

	base:RestoreCombine()
end

function base:HideOthers(newCategory)
	base:Debug("HideOthers", newCategory)

	for _, category in pairs(base.Categories) do
		if category.Saved.Enabled and category.Saved.Bar.IsCombined and not category.Saved.Bar.HideAll and category ~= newCategory then
			category.Saved.Bar.HideAll = not category.Saved.Bar.HideAll
			base:RestoreFrame(category)
		end
	end
end

function base:RestoreFrame(category)
	base:Debug("RestoreFrame", category)

	if category.Saved.Enabled then
		base:RestoreLabel(category)
		base:SetupButtons(category)
		base:SetFrameAndCombineSize(category)
		base:RestorePosition(category.Frames.Frame, category.Saved)
		base:UpdateToggleSettings(category)
		base:UpdateMoveFrame(category)
		base:UpdateFragment(category)
	else
		base:RemoveLabel(category)
		base:RemoveFrame(category)
	end
end

function base:RemoveFrame(category)
	base:Debug("RemoveFrame", category)

	base:RemoveFragments(category)

	for _, button in pairs(category.Buttons) do
		if button ~= nil then
			button:SetHidden(true)
		end
	end

	if category.Frames.Frame ~= nil then
		base:Debug("RemoveFrame:hide", category.Frames.Frame)

		category.Frames.Frame:SetHidden(true)
	end
end

function base:InitializeCombine()
	base.Global.Combine.Saved = base.Saved.Combine
end

function base:RestoreCombine()
	base:Debug("RestoreCombine")

	base:RestoreCombineLabels()
	base:RestorePosition(base.Global.Combine.Frames.Frame, base.Saved.Combine)
	base:UpdateMoveFrame(base.Global.Combine)
	base:UpdateFragment(base.Global.Combine)
end

-------------------------------------------------------------------------------------------------
-- FUNCTIONS --
-------------------------------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(base.Addon.Name, EVENT_ADD_ON_LOADED, base.OnAddOnLoaded)
