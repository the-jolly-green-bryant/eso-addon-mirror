--
-- Calamath's BookFont Stylist [CBFS]
--
-- Copyright (c) 2020 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--

if not CBookFontStylist then return end
local CBFS = CBookFontStylist:SetSharedEnvironment()
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
-- LibAddonMenu SettingPanel Controller Template Class                           rel.2.0.2
-- ---------------------------------------------------------------------------------------
CT_LAMSettingPanelController = CT_AddonSettingPanelController:Subclass()
function CT_LAMSettingPanelController:Initialize(panelId, panelData, optionsData)
	CT_AddonSettingPanelController.Initialize(self, panelId, panelData, optionsData)
end
function CT_LAMSettingPanelController:InitializeSettingPanel(panelData, optionsData)
	if not self.panel then
		local panel = self:CreateSettingPanel(panelData, optionsData)
		self.panel = panel or _G[self.panelId]
		local function OnLAMPanelControlsCreated(panel)
			if panel ~= self.panel then return end
			CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", OnLAMPanelControlsCreated)
			self:OnPanelControlsCreated(panel)
			self.panelInitialized = true
		end
		CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", OnLAMPanelControlsCreated)

		local function OnLAMPanelOpened(panel)
			if panel ~= self.panel then return end
			self.panelOpened = true
			self:OnPanelOpened(panel)
		end
		CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", OnLAMPanelOpened)

		local function OnLAMPanelClosed(panel)
			if panel ~= self.panel then return end
			self.panelOpened = false
			self:OnPanelClosed(panel)
		end
		CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", OnLAMPanelClosed)
	end
end
function CT_LAMSettingPanelController:CreateSettingPanel(panelData, optionsData)
	LAM:RegisterAddonPanel(self.panelId, panelData)
	LAM:RegisterOptionControls(self.panelId, optionsData)
end
function CT_LAMSettingPanelController:OpenSettingPanel()
	if self.panel then
		LAM:OpenToPanel(self.panel)
	end
end

-- LAM Widget Utility functions
-- Obtains ZO_ComboBox object from LAM dropdown widget control.
function CT_LAMSettingPanelController.GetComboBoxObject_FromDropdownWidget(widgetControl)
	if widgetControl and type(widgetControl.data) == "table" and widgetControl.data.type == "dropdown" then
		local container = widgetControl.combobox
		return container and ZO_ComboBox_ObjectFromContainer(container)
	end
end

