--
-- Calamath's Shortcut Pie Menu [CSPM]
--
-- Copyright (c) 2021 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--

if not CShortcutPieMenu then return end
local CSPM = CShortcutPieMenu:SetSharedEnvironment()
-- ---------------------------------------------------------------------------------------
local L = GetString
local LAM = LibAddonMenu2

-- ---------------------------------------------------------------------------------------
-- Adjustable Initializing Object Template Class                                 rel.1.0.2
-- ---------------------------------------------------------------------------------------
-- In general, object attributes should be closed internally. This template class is an exception, as it is adjustable through an external attribute table.
-- The intended use is that the external attribute table is a subset of the internal attribute table and is primarily stored within the save data variables.

CT_AdjustableInitializingObject = ZO_InitializingObject:Subclass()
function CT_AdjustableInitializingObject:Initialize(overriddenAttrib)
	self._attrib = self._attrib or {}
	self._overriddenAttrib = overriddenAttrib or {}
	self._hasOverriddenAttrib = overriddenAttrib ~= nil
end
--[[
function CT_AdjustableInitializingObject:RegisterOverriddenAttributeTable(overriddenAttrib)
	-- If the external attribute table not be specified in the constructor, it could be registered with this method only once.
	if self._hasOverriddenAttrib or type(overriddenAttrib) ~= "table" then
		return false
	else
		self._overriddenAttrib = overriddenAttrib
		self._hasOverriddenAttrib = true
		return true
	end
end
]]
function CT_AdjustableInitializingObject:GetAttribute(key)
	if self._overriddenAttrib[key] ~= nil then
		return self._overriddenAttrib[key]
	else
		return self._attrib[key]
	end
end

function CT_AdjustableInitializingObject:SetAttribute(key, value)
	if self._overriddenAttrib[key] ~= nil then
		self._overriddenAttrib[key] = value
	else
		self._attrib[key] = value
	end
end

function CT_AdjustableInitializingObject:SetAttributes(attributeTable)
	if type(attributeTable) ~= "table" then return end
	for k, v in pairs(attributeTable) do
		self:SetAttribute(k, v)
	end
end

function CT_AdjustableInitializingObject:ResetAttributeToDefault(key)
	if self._attrib[key] and self._overriddenAttrib[key] then
		self._overriddenAttrib[key] = self._attrib[k]
	end
end

function CT_AdjustableInitializingObject:ResetAllAttributesToDefaults()
	for k, v in pairs(self._overriddenAttrib) do
		if self._attrib[k] then
			self._overriddenAttrib[k] = self._attrib[k]
		end
	end
end


-- ---------------------------------------------------------------------------------------
-- Tooltip Controller Template Class                                             rel.1.0.3
-- ---------------------------------------------------------------------------------------
CT_TooltipController = ZO_InitializingObject:Subclass()
function CT_TooltipController:Initialize(tooltip)
	self.tooltip = tooltip
end

-- Removes the owner of the tooltip and hides the tooltip.
function CT_TooltipController:ClearTooltip()
	return ClearTooltip(self.tooltip)
end

-- Clears the contents of the tooltip, anchors the tooltip and displays it on the screen.
function CT_TooltipController:InitializeTooltip(owner, point, offsetX, offsetY, relativePoint)
	return InitializeTooltip(self.tooltip, owner, point, offsetX, offsetY, relativePoint)
end

function CT_TooltipController:AddDivider()
-- NOTE:The releasing of the objects in the tooltip divider pool is performed by the OnCleared event handler of the ZO_BaseTooltipBehavior tooltip template.
	return ZO_Tooltip_AddDivider(self.tooltip)
end

function CT_TooltipController:AddControl(control, cell, useLastRow)
	return self.tooltip:AddControl(control, cell, useLastRow)
end

function CT_TooltipController:AddHeaderControl(control, headerRow, headerSide)
	return self.tooltip:AddHeaderControl(control, headerRow, headerSide)
end

function CT_TooltipController:AddHeaderLine(text, font, headerRow, headerSide, r, g, b)
	return self.tooltip:AddHeaderLine(text, font, headerRow, headerSide, r, g, b)
end

function CT_TooltipController:AddLine(text, font, r, g, b, lineAnchor, modifyTextType, textAlignment, setToFullSize, minWidth)
	return self.tooltip:AddLine(text, font, r, g, b, lineAnchor, modifyTextType, textAlignment, setToFullSize, minWidth)
end

function CT_TooltipController:AddVerticalPadding(paddingY)
	return self.tooltip:AddVerticalPadding(paddingY)
end

-- Clears the contents of the tooltip without changing the tooltip visibility and anchors.
function CT_TooltipController:ClearLines()
	return self.tooltip:ClearLines()
end

function CT_TooltipController:GetOwner()
	return self.tooltip:GetOwner()
end

-- Set the tooltip owner and anchor the tooltip.
function CT_TooltipController:SetOwner(owner, point, offsetX, offsetY, relativePoint)
	return self.tooltip:SetOwner(owner, point, offsetX, offsetY, relativePoint)
end

-- some additional methods...
-- Returns the display status state of the tooltip
function CT_TooltipController:IsTooltipShown()
	return not self.tooltip:IsControlHidden()
end

-- Change only the display state of the tooltip to shown.
function CT_TooltipController:Show()
	self.tooltip:SetHidden(false)
end

-- Change only the display state of the tooltip to hidden.
function CT_TooltipController:Hide()
	self.tooltip:SetHidden(true)
end


-- ---------------------------------------------------------------------------------------
-- LAMSettingPanel Controller Template Class                                     rel.1.0.1
-- ---------------------------------------------------------------------------------------
CT_LAMSettingPanelController = ZO_InitializingObject:Subclass()
function CT_LAMSettingPanelController:Initialize(panelId, panelData, optionsData)
	if type(panelId) ~= "string" or panelId == "" then return end
	self.panelId = panelId
	self.panelInitialized = false
	self.panelOpened = false
	if panelData and optionsData then
		self:InitializeSettingPanel(panelData, optionsData)
	end
end
function CT_LAMSettingPanelController:InitializeSettingPanel(panelData, optionsData)
	if not self.panel then
		local panel = self:CreateSettingPanel(panelData, optionsData)
		self.panel = panel or _G[self.panelId]
		local function OnLAMPanelControlsCreated(panel)
			if panel ~= self.panel then return end
			CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", OnLAMPanelControlsCreated)
			self:OnLAMPanelControlsCreated(panel)
			self.panelInitialized = true
		end
		CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", OnLAMPanelControlsCreated)

		local function OnLAMPanelOpened(panel)
			if panel ~= self.panel then return end
			self.panelOpened = true
			self:OnLAMPanelOpened(panel)
		end
		CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", OnLAMPanelOpened)

		local function OnLAMRefreshPanel(panel)
			if panel ~= self.panel then return end
			self:OnLAMRefreshPanel(panel)
		end
		CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", OnLAMRefreshPanel)

		local function OnLAMPanelClosed(panel)
			if panel ~= self.panel then return end
			self.panelOpened = false
			self:OnLAMPanelClosed(panel)
		end
		CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", OnLAMPanelClosed)
	end
end
function CT_LAMSettingPanelController:CreateSettingPanel(panelData, optionsData)
	LAM:RegisterAddonPanel(self.panelId, panelData)
	LAM:RegisterOptionControls(self.panelId, optionsData)
end
function CT_LAMSettingPanelController:GetPanelId()
	return self.panelId
end
function CT_LAMSettingPanelController:IsPanelInitialized()
	return self.panelInitialized
end
function CT_LAMSettingPanelController:IsPanelShown()
	return self.panelOpened
end
function CT_LAMSettingPanelController:GetSettingPanel()
	return self.panel
end
function CT_LAMSettingPanelController:OpenSettingPanel()
	if self.panel then
		LAM:OpenToPanel(self.panel)
	end
end
function CT_LAMSettingPanelController:OnLAMPanelControlsCreated(panel)
--  Should be overridden if needed
end
function CT_LAMSettingPanelController:OnLAMPanelOpened(panel)
--  Should be overridden if needed
end
function CT_LAMSettingPanelController:OnLAMRefreshPanel(panel)
--  Should be overridden if needed
end
function CT_LAMSettingPanelController:OnLAMPanelClosed(panel)
--  Should be overridden if needed
end

-- LAM Widget Utility functions
-- Obtains ZO_ComboBox object from LAM dropdown widget control.
function CT_LAMSettingPanelController.GetComboBoxObject_FromDropdownWidget(widgetControl)
	if widgetControl and type(widgetControl.data) == "table" and widgetControl.data.type == "dropdown" then
		local container = widgetControl.combobox
		return container and ZO_ComboBox_ObjectFromContainer(container)
	end
end

