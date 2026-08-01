--[[
  Copyright 2025: Xavier "XJDHDR" du Hecquet de Rauville

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.

  This Source Code Form is "Incompatible With Secondary Licenses", as
  defined by the Mozilla Public License, v. 2.0.
]]--

local XjFragmentCollectibleTracker = {
	bIsModInitialised = false,
	sAddonName = "XjFragmentCollectibleTracker",
	sAddonNameUserFriendly = "Fragment Collectible Tracker",
	libDebugLogger = nil,

	iSavedVarVersion = 2509,
	sSavedVarsTableName = "XjFragmentCollectibleTrackerSavedVars",
	tabSettings = {
		bColourBlind = false,
		bDebugMode = false,
	},

	sBaseTextColour = "",
	sNoColour = "",
	sYesColour = "",

	sBulletPoint = "",
	sCollectibleIsNotUnlockedText = "",
	sCollectibleIsUnlockedText = "",
	sHeadingText = "",
	sRequirementsHeadingText = "",
}


function XjFragmentCollectibleTracker:AddFragmentDataToTooltip(TooltipControl, iSelectedItemCollectibleId)
	local iSelectedCollectibleCategoryType = GetCollectibleCategoryType(iSelectedItemCollectibleId)
	if (iSelectedCollectibleCategoryType ~= COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT)
	then
		if (self.tabSettings.bDebugMode)
		then
			TooltipControl:AddLine("Debug data:", "ZoFontWinH3", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			TooltipControl:AddLine("Selected item Collectible Id: " .. tostring(iSelectedItemCollectibleId), "ZoFontGameMedium", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			TooltipControl:AddLine("Selected item category type: " .. tostring(iSelectedCollectibleCategoryType), "ZoFontGameMedium", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		end
		return
	end

	local iSelectedItemCombinationId = GetCollectibleReferenceId(iSelectedItemCollectibleId)
	local iTotalUnlockedCollectiblesForCombinationId = GetCombinationNumUnlockedCollectibles(iSelectedItemCombinationId)

	if (iTotalUnlockedCollectiblesForCombinationId <= 0)
	then
		if (self.tabSettings.bDebugMode)
		then
			TooltipControl:AddLine("Debug data:", "ZoFontWinH3", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			TooltipControl:AddLine("Selected fragment Collectible Id: " .. tostring(iSelectedItemCollectibleId), "ZoFontGameMedium", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			TooltipControl:AddLine("Selected fragment Combination Id: " .. tostring(iSelectedItemCombinationId), "ZoFontGameMedium", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			TooltipControl:AddLine("This Combination ID has no associated collectibles.", "ZoFontGameMedium", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		end
		return
	end

	self:BuildFragmentTooltip(TooltipControl, iSelectedItemCombinationId, iSelectedItemCollectibleId, iTotalUnlockedCollectiblesForCombinationId)
end

function XjFragmentCollectibleTracker:BuildFragmentTooltip(TooltipControl, iSelectedItemCombinationId, iSelectedItemCollectibleId, iTotalUnlockedCollectiblesForCombinationId)
	ZO_Tooltip_AddDivider(TooltipControl)
	TooltipControl:AddLine(self.sHeadingText, "ZoFontWinH3", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)

	local tabDebugMessageLines = {}
	if (self.tabSettings.bDebugMode)
	then
		table.insert(tabDebugMessageLines, "Selected fragment Collectible Id: " .. tostring(iSelectedItemCollectibleId))
		table.insert(tabDebugMessageLines, "Selected fragment Combination Id: " .. tostring(iSelectedItemCombinationId))
	end

	for i = 1, iTotalUnlockedCollectiblesForCombinationId
	do
		local iCurrentCombinationUnlockedCollectibleId = GetCombinationUnlockedCollectibleId(iSelectedItemCombinationId, i)
		if (self.tabSettings.bDebugMode)
		then
			table.insert(tabDebugMessageLines, "Fragment unlockable collectible #" .. tostring(i) .. ": " .. tostring(iCurrentCombinationUnlockedCollectibleId))
		end

		self:AddCurrentUnlockedCollectibleDataToTooltip(TooltipControl, iCurrentCombinationUnlockedCollectibleId, iSelectedItemCombinationId, iSelectedItemCollectibleId, tabDebugMessageLines)
	end

	if (self.tabSettings.bDebugMode)
	then
		TooltipControl:AddLine("Debug data:", "ZoFontWinH3", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
		for _, sTableEntry in ipairs(tabDebugMessageLines)
		do
			TooltipControl:AddLine(sTableEntry, "ZoFontGameMedium", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		end
	end
end

function XjFragmentCollectibleTracker:AddCurrentUnlockedCollectibleDataToTooltip(TooltipControl, iCurrentUnlockableCollectibleId, iCurrentUnlockableCombinationId, iSelectedItemCollectibleId, tabDebugMessageLines)
	local sCollectibleName, _, texCollectibleIcon, _, bIsCollectibleUnlocked, _, _, _, _ = GetCollectibleInfo(iCurrentUnlockableCollectibleId)
	local sCollectibleCategoryName = GetCollectibleCategoryNameByCollectibleId(iCurrentUnlockableCollectibleId)

	local sCollectibleIconInText = zo_iconTextFormatNoSpace(texCollectibleIcon, 48, 48, textureColorDummy, inheritColor)
	local sCollectibleInfoText = sCollectibleIconInText .. "|cC5C29E" .. sCollectibleName .. " (" .. sCollectibleCategoryName .. ")|r"
	TooltipControl:AddLine(sCollectibleInfoText, "ZoFontGameMedium", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)

	local sIsThisCollectibleUnlockedText = (bIsCollectibleUnlocked and self.sCollectibleIsUnlockedText or self.sCollectibleIsNotUnlockedText)
	TooltipControl:AddLine(sIsThisCollectibleUnlockedText, "ZoFontGameMedium", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)

	if (self.tabSettings.bDebugMode)
	then
		table.insert(tabDebugMessageLines, "Unlockable Collectible data: " .. sCollectibleName .. ", Unlocked: " .. tostring(bIsCollectibleUnlocked) .. ", " .. sCollectibleCategoryName)
	end

	local iTotalCombinationComponents = GetCombinationNumCollectibleComponents(iCurrentUnlockableCombinationId)
	if (iTotalCombinationComponents <= 0)
	then
		if (self.tabSettings.bDebugMode)
		then
			table.insert(tabDebugMessageLines, "This Combination ID has no components associated with it.")
		end

		return
	end

	self:WriteTooltipRequirementsLines(TooltipControl, iCurrentUnlockableCombinationId, iSelectedItemCollectibleId, iTotalCombinationComponents, tabDebugMessageLines)
end

function XjFragmentCollectibleTracker:WriteTooltipRequirementsLines(TooltipControl, iCombinationId, iStoreItemCollectibleId, iNumCombinationComponents, tabDebugMessageLines)
	TooltipControl:AddLine("", "", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	TooltipControl:AddLine(self.sRequirementsHeadingText, "ZoFontWinH3", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)

	local tabFragmentRequirements = {}
	local tabNonFragmentRequirements = {}
	for i = 1, iNumCombinationComponents
	do
		local iComponentCollectibleId = GetCombinationCollectibleComponentId(iCombinationId, i)

		if (self.tabSettings.bDebugMode)
		then
			table.insert(tabDebugMessageLines, "Collectible Id for Component #" .. tostring(i) .. ": " .. tostring(iComponentCollectibleId))
		end

		self:GetCurrentRequirementData(iComponentCollectibleId, iStoreItemCollectibleId, tabFragmentRequirements, tabNonFragmentRequirements, tabDebugMessageLines)
	end

	for i = 1, #tabFragmentRequirements
	do
		TooltipControl:AddLine(tabFragmentRequirements[i], "ZoFontGameMedium", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
	end

	for i = 1, #tabNonFragmentRequirements
	do
		TooltipControl:AddLine(tabNonFragmentRequirements[i], "ZoFontGameMedium", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
	end
end

function XjFragmentCollectibleTracker:GetCurrentRequirementData(iCollectibleId, iStoreItemCollectibleId, tabFragmentRequirements, tabNonFragmentRequirements, tabDebugMessageLines)
	local sCollectibleName, _, texCollectibleIcon, _, bIsCollectibleUnlocked, _, _, iCollectibleCategoryType, _ = GetCollectibleInfo(iCollectibleId)
	local sCollectibleIcon = zo_iconTextFormatNoSpace(texCollectibleIcon, 24, 24, textureColorDummy, inheritColor)

	if (self.tabSettings.bDebugMode)
	then
		table.insert(tabDebugMessageLines, "Component data: " .. sCollectibleName .. ", Is Unlocked: " .. tostring(bIsCollectibleUnlocked) .. ", Category: " .. tostring(iCollectibleCategoryType))
	end

	local sCollectibleText
	if (bIsCollectibleUnlocked)
	then
		sCollectibleText = self.sBulletPoint .. sCollectibleIcon .. self.sYesColour .. sCollectibleName .. "|r"
	else
		sCollectibleText = self.sBulletPoint .. sCollectibleIcon .. self.sNoColour .. sCollectibleName .. "|r"
	end

	if (iCollectibleCategoryType ~= COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT)
	then
		local sCollectibleCategoryName = GetCollectibleCategoryNameByCollectibleId(iCollectibleId)
		sCollectibleText = sCollectibleText .. " " .. self.sBaseTextColour .. "(" .. sCollectibleCategoryName .. ")|r"
	end

	if (iCollectibleId == iStoreItemCollectibleId)
	then
		sCollectibleText = sCollectibleText .. " " .. self.sBaseTextColour .. "(selected)|r"
	end

	if (iCollectibleCategoryType ~= COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT)
	then
		table.insert(tabNonFragmentRequirements, sCollectibleText)
	else
		table.insert(tabFragmentRequirements, sCollectibleText)
	end
end

function XjFragmentCollectibleTracker:Init()
	if (self.bIsModInitialised == true)
	then
		return
	end

	self.bIsModInitialised = true
	EVENT_MANAGER:UnregisterForEvent(self.sAddonName, EVENT_ADD_ON_LOADED)

	if (self.LibDebugLogger ~= nil)
	then
		self.libDebugLogger = LibDebugLogger(self.sAddonName)
	end

	self.tabSettings = ZO_SavedVars:NewAccountWide(self.sSavedVarsTableName, self.iSavedVarVersion, nil, self.tabSettings)

	self:SetAllStringConstants()
	self:CreateAddonMenu()

	ZO_PostHook(ItemTooltip, "SetCollectible", self.SetCollectibleEventHandler)
	ZO_PostHook(ItemTooltip, "SetStoreItem", self.SetStoreItemEventHandler)
end

function XjFragmentCollectibleTracker:CreateAddonMenu()
	if (LibAddonMenu2 == nil)
	then
		return
	end

	local LAM = LibAddonMenu2
	local panelName = self.sAddonName .. "SettingsPanel"

	local panelData = {
		type = "panel",
		name = self.sAddonNameUserFriendly,
		author = "XJDHDR",
	}
	LAM:RegisterAddonPanel(panelName, panelData)

	local optionsData = {
		{
			type = "checkbox",
			name = "Colourblind Mode",
			tooltip = "Change collected/uncollected colours from |c00FF00Green|r/|cFF0000Red|r to |c00B0FFCapri Blue|r/|cC83220Prismatic Red|r.",

			getFunc = function()
				return self.tabSettings.bColourBlind
			end,

			setFunc = function(value)
			   self.tabSettings.bColourBlind = value
			   self:SetColourblindSensitiveStringConstants()
			end,
		},
		{
			type = "checkbox",
			name = "Debug Data",
			tooltip = "Adds debug related info to the tooltips.",

			getFunc = function()
				return self.tabSettings.bDebugMode
			end,

			setFunc = function(value)
				self.tabSettings.bDebugMode = value
			end,
		},
	}
	LAM:RegisterOptionControls(panelName, optionsData)
end

function XjFragmentCollectibleTracker:SetAllStringConstants()
	self.sBaseTextColour = "|cC5C29E"
	self.sHeadingTextColour = "|cFFFFFF"

	self.sBulletPoint = self.sBaseTextColour .. "•|r"
	self.sHeadingText = self.sHeadingTextColour .. "Unlockable Collectibles:|r"
	self.sRequirementsHeadingText = self.sHeadingTextColour .. "Requirements:|r"

	self:SetColourblindSensitiveStringConstants()
end

function XjFragmentCollectibleTracker:SetColourblindSensitiveStringConstants()
	if (self.tabSettings.bColourBlind)
	then
		self.sNoColour = "|cC83220"
		self.sYesColour = "|c00B0FF"
	else
		self.sNoColour = "|cFF0000"
		self.sYesColour = "|c00FF00"
	end

	self.sCollectibleIsNotUnlockedText = self.sNoColour .. "Unlocked: No|r"
	self.sCollectibleIsUnlockedText = self.sYesColour .. "Unlocked: Yes|r"
end


-- Event Handlers --
function XjFragmentCollectibleTracker.OnAddonLoadedEventHandler(_, _)
	XjFragmentCollectibleTracker:Init()
end

function XjFragmentCollectibleTracker.SetCollectibleEventHandler(TooltipControl, iCollectibleId)
	XjFragmentCollectibleTracker:AddFragmentDataToTooltip(TooltipControl, iCollectibleId)
end

function XjFragmentCollectibleTracker.SetStoreItemEventHandler(TooltipControl, iStoreItemSlotIndex)
	local iCollectibleId = GetStoreCollectibleInfo(iStoreItemSlotIndex)
	XjFragmentCollectibleTracker:AddFragmentDataToTooltip(TooltipControl, iCollectibleId)
end


EVENT_MANAGER:RegisterForEvent(XjFragmentCollectibleTracker.sAddonName, EVENT_ADD_ON_LOADED, XjFragmentCollectibleTracker.OnAddonLoadedEventHandler)
