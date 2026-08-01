-- Checklist control: multi-select ComboBox popup (Home Tours Tags pattern).

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

local function ResolveTooltipText(tooltip)
	if tooltip == nil then
		return nil
	end
	local tooltipType = type(tooltip)
	if tooltipType == "function" then
		return tooltip()
	elseif tooltipType == "number" then
		return GetString(tooltip)
	elseif tooltipType == "string" and #tooltip > 0 then
		return tooltip
	end
	return nil
end

local function ShowItemOrRowTooltip(setting, item)
	local text
	if item then
		text = ResolveTooltipText(item.tooltip)
	end
	if not text and setting then
		text = ResolveTooltipText(setting.tooltipText)
	end
	if text then
		GAMEPAD_TOOLTIPS:LayoutSettingTooltip(GAMEPAD_LEFT_TOOLTIP, text, "")
	else
		GAMEPAD_TOOLTIPS:Reset(GAMEPAD_LEFT_TOOLTIP)
	end
end

local function ValueInList(list, value)
	if type(list) ~= "table" then
		return false
	end
	for i = 1, #list do
		if list[i] == value then
			return true
		end
	end
	return false
end

local function CopyValueList(list)
	local copy = {}
	if type(list) ~= "table" then
		return copy
	end
	for i = 1, #list do
		copy[i] = list[i]
	end
	return copy
end

local function GetSelectedValues(dropdown)
	local selected = {}
	local data = dropdown and dropdown.currentItemData
	if not data then
		return selected
	end
	local items = data:GetSelectedItems()
	for i = 1, #items do
		local item = items[i]
		selected[#selected + 1] = item.data ~= nil and item.data or item.name
	end
	return selected
end

-- Closed selected text: inset by arrow so CENTER matches the control (same as Dropdown).
local function CenterClosedSelectedText(dropdown)
	local label = dropdown.m_selectedItemText
	local container = dropdown.m_container
	if not label or not container then
		return
	end
	local arrow = container:GetNamedChild("OpenDropdown")
	local inset = 27
	if arrow then
		inset = arrow:GetWidth() + 3
	end
	local font = dropdown.m_font or ZO_GAMEPAD_COMBO_BOX_FONT
	label:SetFont(font)
	label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	label:ClearAnchors()
	label:SetAnchor(TOPLEFT, container, TOPLEFT, inset, 0)
	label:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, -inset, 0)
end

local function EnsureChecklistDropdown(dropdown)
	if not dropdown or dropdown._lcmChecklistReady then
		return
	end
	dropdown._lcmChecklistReady = true
	dropdown._lcmSettingsDropdown = true
	CenterClosedSelectedText(dropdown)
end

local function RestoreChecklistItemLayout(control)
	if not control then
		return
	end
	local checkBox = control:GetNamedChild("CheckBox")
	local nameControl = control.nameControl or control:GetNamedChild("Name")
	if not checkBox or not nameControl then
		return
	end
	checkBox:ClearAnchors()
	checkBox:SetAnchor(LEFT, control, LEFT, 0, 0)
	nameControl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	nameControl:ClearAnchors()
	nameControl:SetAnchor(LEFT, checkBox, RIGHT, 0, 0)
	nameControl:SetAnchor(RIGHT, control, RIGHT, 0, 0, ANCHOR_CONSTRAINS_X)
end

local function ApplyCenteredChecklistItemLayout(control)
	if not control then
		return
	end
	local checkBox = control:GetNamedChild("CheckBox")
	local nameControl = control.nameControl or control:GetNamedChild("Name")
	if not checkBox or not nameControl then
		return
	end
	local inset = (checkBox.GetWidth and checkBox:GetWidth() or 24) + 12
	checkBox:ClearAnchors()
	checkBox:SetAnchor(RIGHT, control, RIGHT, -3, 0)
	nameControl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	nameControl:ClearAnchors()
	nameControl:SetAnchor(LEFT, control, LEFT, inset, 0)
	nameControl:SetAnchor(RIGHT, control, RIGHT, -inset, 0, ANCHOR_CONSTRAINS_X)
end

local classChecklistLayoutHooked = false
local function EnsureClassChecklistLayoutHook()
	if classChecklistLayoutHooked then
		return
	end
	classChecklistLayoutHooked = true

	local orgSetup = ZO_MultiSelection_ComboBox_Gamepad.SetupMenuItemControl
	function ZO_MultiSelection_ComboBox_Gamepad.SetupMenuItemControl(self, control, item)
		orgSetup(self, control, item)
		if self and self._lcmChecklistCenterItems then
			ApplyCenteredChecklistItemLayout(control)
		else
			RestoreChecklistItemLayout(control)
		end
	end

	local orgSelected = ZO_ComboBox_Gamepad.OnItemSelected
	function ZO_ComboBox_Gamepad.OnItemSelected(self, control, data)
		orgSelected(self, control, data)
		if control and control:GetNamedChild("CheckBox") then
			if self and self._lcmChecklistCenterItems then
				ApplyCenteredChecklistItemLayout(control)
			else
				RestoreChecklistItemLayout(control)
			end
		end
	end

	local orgDeselected = ZO_ComboBox_Gamepad.OnItemDeselected
	function ZO_ComboBox_Gamepad.OnItemDeselected(self, control, data)
		orgDeselected(self, control, data)
		if control and control:GetNamedChild("CheckBox") then
			if self and self._lcmChecklistCenterItems then
				ApplyCenteredChecklistItemLayout(control)
			else
				RestoreChecklistItemLayout(control)
			end
		end
	end
end

local function ApplyChecklistColors(dropdown, selected, enabled)
	if not dropdown then
		return
	end
	if enabled then
		dropdown:SetNormalColor(ZO_DISABLED_TEXT:UnpackRGB())
		dropdown:SetHighlightedColor(ZO_SELECTED_TEXT:UnpackRGB())
	else
		dropdown:SetNormalColor(ZO_GAMEPAD_DISABLED_UNSELECTED_COLOR:UnpackRGB())
		dropdown:SetHighlightedColor(ZO_GAMEPAD_DISABLED_SELECTED_COLOR:UnpackRGB())
	end
	dropdown:SetSelectedItemTextColor(selected)
end

local function RebuildChecklistData(setting, dropdown, selectedValues)
	local items = setting:GetValueOrCallback(setting.items) or {}
	local data = ZO_MultiSelection_ComboBox_Data_Gamepad:New()

	local function OnItemToggled()
		if dropdown._lcmSuppressCallbacks then
			return
		end
		setting:ValueChanged(GetSelectedValues(dropdown))
	end

	for i = 1, #items do
		local item = items[i]
		local entry = ZO_ComboBox_Base:CreateItemEntry(item.name, OnItemToggled)
		entry.data = item.data
		entry.tooltip = item.tooltip
		entry.lcmItem = item
		data:AddItem(entry)
		if ValueInList(selectedValues, item.data) or ValueInList(selectedValues, item.name) then
			data:SetItemSelected(entry, true)
		end
	end

	dropdown:LoadData(data)
end

LCM.changeControlStateFunctions[LCM.CT_CHECKLIST] = function(control, state, selected)
	LCM.SetNameControlState(control, state, selected)
	if selected == nil then
		selected = LCM.list and LCM.list:GetSelectedControl() == control
	end
	ApplyChecklistColors(control.dropdown, selected, state)
end

LCM.updateControlFunctions[LCM.CT_CHECKLIST] = function(self, control, selected, enabled)
	local nameControl = control:GetNamedChild("Name")
	local label = self:GetString(self:GetValueOrCallback(self.labelText))
	local align = self:GetValueOrCallback(self.align) or "center"
	if nameControl then
		nameControl:SetText(label)
		nameControl:SetHorizontalAlignment(align == "left" and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER)
	end

	local dropdown = control.dropdown
	dropdown:SetSortsItems(false)
	dropdown:SetName(label)
	dropdown._lcmChecklistCenterItems = align ~= "left"

	if control._lcmOnItemSelected then
		dropdown:UnregisterCallback("OnItemSelected", control._lcmOnItemSelected)
		control._lcmOnItemSelected = nil
	end

	local maxSelections = self:GetValueOrCallback(self.maxSelections)
	if type(maxSelections) == "number" then
		dropdown:SetMaxSelections(maxSelections)
	else
		dropdown:SetMaxSelections(nil)
	end

	local noSelectionText = self:GetValueOrCallback(self.noSelectionText)
	if noSelectionText then
		dropdown:SetNoSelectionText(noSelectionText)
	else
		dropdown:SetNoSelectionText()
	end

	local formatter = self:GetValueOrCallback(self.multiSelectionTextFormatter)
	if formatter then
		dropdown:SetMultiSelectionTextFormatter(formatter)
	else
		dropdown:SetMultiSelectionTextFormatter()
	end

	dropdown._lcmSuppressCallbacks = true
	local current = self.getFunction and self.getFunction() or {}
	RebuildChecklistData(self, dropdown, current)
	dropdown._lcmSuppressCallbacks = false

	control._lcmOnItemSelected = function(_, itemData)
		ShowItemOrRowTooltip(self, itemData and (itemData.lcmItem or itemData))
	end
	dropdown:RegisterCallback("OnItemSelected", control._lcmOnItemSelected)

	dropdown:SetDeactivatedCallback(function()
		ShowItemOrRowTooltip(self, nil)
		if not dropdown._lcmSuppressCallbacks then
			self:ValueChanged(GetSelectedValues(dropdown))
		end
	end)

	if selected == nil then
		selected = LCM.list and LCM.list:GetSelectedControl() == control
	end
	if enabled == nil then
		enabled = not self:IsDisabled()
	end
	ApplyChecklistColors(dropdown, selected, enabled)
end

LCM.createControlFunctions[LCM.CT_CHECKLIST] = LCM.AddControlEntry

LCM.cleanControlFunctions[LCM.CT_CHECKLIST] = function(self, control)
	control = control or self.control
	local dropdown = control and control.dropdown
	if not dropdown then
		return
	end
	if control._lcmOnItemSelected then
		dropdown:UnregisterCallback("OnItemSelected", control._lcmOnItemSelected)
		control._lcmOnItemSelected = nil
	end
	dropdown:SetDeactivatedCallback(nil)
	dropdown:ClearItems()
end

LCM.setupControlFunctions[LCM.CT_CHECKLIST] = function(self, params)
	self.items = params.items
	self.labelText = params.label
	self.tooltipText = params.tooltip
	self.setFunction = params.setFunction
	self.getFunction = params.getFunction
	self.default = params.default
	self.ignoreDefault = params.ignoreDefault
	self.disable = params.disable
	self.maxSelections = params.maxSelections
	self.noSelectionText = params.noSelectionText
	self.multiSelectionTextFormatter = params.multiSelectionTextFormatter
	self.align = params.align or "center"
end

function LCM.CreateChecklistPoolFactory()
	return function(control)
		if not control.dropdown then
			local dropdownControl = control:GetNamedChild("Dropdown")
			control.dropdown = ZO_ComboBox_ObjectFromContainer(dropdownControl)
		end
		EnsureChecklistDropdown(control.dropdown)
		EnsureClassChecklistLayoutHook()
		function control:Activate()
			if self.dropdown then
				self.dropdown:Activate()
			end
		end
		function control:Deactivate()
			if self.dropdown then
				self.dropdown:Deactivate()
			end
		end
		function control:GetDropDown()
			return self.dropdown
		end
		function control:SetValue(selectedValues)
			local dropdown = self.dropdown
			local setting = self.data
			if not dropdown or not setting then
				return
			end
			dropdown._lcmSuppressCallbacks = true
			RebuildChecklistData(setting, dropdown, CopyValueList(selectedValues))
			dropdown._lcmSuppressCallbacks = false
		end
	end
end
