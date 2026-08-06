-- Dropdown control: gamepad ComboBox popup (Character / Home Tours pattern).

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

local function FindItemIndex(items, target)
	if not items or target == nil then
		return nil
	end
	for i = 1, #items do
		local item = items[i]
		if item == target or item.name == target or item.data == target then
			return i
		end
	end
	return nil
end

-- Stock ComboBox items are left-anchored; center them in the full-width popup.
local function CenterDropdownItemLabel(nameControl)
	if not nameControl then
		return
	end
	nameControl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	nameControl:ClearAnchors()
	nameControl:SetAnchor(CENTER, nameControl:GetParent(), CENTER)
end

-- Popup item controls live in a shared GAMEPAD_COMBO_BOX_DROPDOWN pool — restore stock
-- left layout so Character / Housing combos are not left centered after an LCM open.
local function RestoreStockDropdownItemLabel(nameControl)
	if not nameControl then
		return
	end
	nameControl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	nameControl:ClearAnchors()
	nameControl:SetAnchor(LEFT, nameControl:GetParent(), LEFT)
end

local function ApplyDropdownItemLabelLayout(dropdown, control)
	local nameControl = control and (control.nameControl or control:GetNamedChild("Name"))
	if not nameControl then
		return
	end
	-- Multi-select items (e.g. Home Tours tags / Checklist) keep Name beside CheckBox.
	if control:GetNamedChild("CheckBox") then
		return
	end
	if dropdown and dropdown._lcmSettingsDropdown and dropdown._lcmDropdownCenterItems then
		CenterDropdownItemLabel(nameControl)
	else
		RestoreStockDropdownItemLabel(nameControl)
	end
end

-- Closed selected text spans TOPLEFT→arrow, so plain CENTER alignment looks left-leaning.
-- Inset both sides by the arrow width so the text center matches the control center.
-- Use the popup unselected font (27) instead of stock SelectedItemText (34).
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

local function RestoreStockClosedSelectedText(dropdown, indentPx)
	local label = dropdown.m_selectedItemText
	local container = dropdown.m_container
	if not label or not container then
		return
	end
	indentPx = indentPx or 0
	local arrow = container:GetNamedChild("OpenDropdown")
	local font = dropdown.m_font or ZO_GAMEPAD_COMBO_BOX_FONT
	label:SetFont(font)
	label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	label:ClearAnchors()
	label:SetAnchor(TOPLEFT, container, TOPLEFT, indentPx, 0)
	if arrow then
		label:SetAnchor(RIGHT, arrow, LEFT, -3, 0, ANCHOR_CONSTRAINS_X)
	else
		label:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, 0, 0)
	end
end

local function ApplyClosedSelectedTextLayout(dropdown)
	if not dropdown then
		return
	end
	if dropdown._lcmDropdownCenterItems then
		CenterClosedSelectedText(dropdown)
	else
		RestoreStockClosedSelectedText(dropdown, dropdown._lcmLeftIndentPx or 0)
	end
end

-- Class-level so non-LCM combos restore pooled item layout after we center for settings.
local classItemLayoutHooked = false
local function EnsureClassLevelItemLayoutHook()
	if classItemLayoutHooked then
		return
	end
	classItemLayoutHooked = true

	local orgSetup = ZO_ComboBox_Gamepad.SetupMenuItemControl
	function ZO_ComboBox_Gamepad.SetupMenuItemControl(self, control, item)
		orgSetup(self, control, item)
		ApplyDropdownItemLabelLayout(self, control)
	end

	local orgSelected = ZO_ComboBox_Gamepad.OnItemSelected
	function ZO_ComboBox_Gamepad.OnItemSelected(self, control, data)
		orgSelected(self, control, data)
		ApplyDropdownItemLabelLayout(self, control)
	end

	local orgDeselected = ZO_ComboBox_Gamepad.OnItemDeselected
	function ZO_ComboBox_Gamepad.OnItemDeselected(self, control, data)
		orgDeselected(self, control, data)
		ApplyDropdownItemLabelLayout(self, control)
	end
end

local function EnsureDropdownLayout(dropdown)
	if not dropdown or dropdown._lcmDropdownReady then
		return
	end
	dropdown._lcmDropdownReady = true
	dropdown._lcmSettingsDropdown = true
	-- Default center until update applies the setting's align.
	dropdown._lcmDropdownCenterItems = true
	ApplyClosedSelectedTextLayout(dropdown)
	EnsureClassLevelItemLayoutHook()
end

-- Match toggle/selector: disabled rows show SI_CHECK_BUTTON_DISABLED instead of the value.
local function ApplyDropdownSelectedText(dropdown, enabled)
	if not dropdown then
		return
	end
	if not enabled then
		dropdown:SetSelectedItemText(GetString(SI_CHECK_BUTTON_DISABLED))
	elseif dropdown.m_selectedItemData then
		dropdown:SetSelectedItemText(dropdown.m_selectedItemData.name)
	end
end

local function ApplyDropdownColors(dropdown, selected, enabled)
	if not dropdown then
		return
	end
	-- Gamepad ComboBox has no SetEnabled; dim via stock selected-item colors.
	if enabled then
		dropdown:SetNormalColor(ZO_DISABLED_TEXT:UnpackRGB())
		dropdown:SetHighlightedColor(ZO_SELECTED_TEXT:UnpackRGB())
	else
		-- Match selector: tertiary dim whether focused or not (not DISABLED_SELECTED).
		local dimR, dimG, dimB = ZO_GAMEPAD_DISABLED_UNSELECTED_COLOR:UnpackRGB()
		dropdown:SetNormalColor(dimR, dimG, dimB)
		dropdown:SetHighlightedColor(dimR, dimG, dimB)
	end
	dropdown:SetSelectedItemTextColor(selected)
	ApplyDropdownSelectedText(dropdown, enabled)
end

LCM.changeControlStateFunctions[LCM.CT_DROPDOWN] = function(control, state, selected)
	LCM.SetNameControlState(control, state, selected)
	if selected == nil then
		selected = LCM.list and LCM.list:GetSelectedControl() == control
	end
	ApplyDropdownColors(control.dropdown, selected, state)
end

LCM.updateControlFunctions[LCM.CT_DROPDOWN] = function(self, control, selected, enabled)
	local nameControl = control:GetNamedChild("Name")
	local label = self:GetString(self:GetValueOrCallback(self.labelText))
	local align, _, indentPx = LCM.ResolveRowAlign(self, LCM.currentSettings)
	if nameControl then
		nameControl:SetText(label)
		LCM.ApplyNameLabelAlign(nameControl, align, indentPx)
	end

	local dropdown = control.dropdown
	dropdown:SetSortsItems(false)
	dropdown:SetName(label)
	dropdown._lcmDropdownCenterItems = align ~= "left"
	dropdown._lcmLeftIndentPx = 0
	ApplyClosedSelectedTextLayout(dropdown)

	if control._lcmOnItemSelected then
		dropdown:UnregisterCallback("OnItemSelected", control._lcmOnItemSelected)
		control._lcmOnItemSelected = nil
	end

	local items = self:GetValueOrCallback(self.items) or {}
	local suppressCallbacks = true

	local function OnConfirmed(_, name, item)
		if suppressCallbacks then
			return
		end
		self:ValueChanged(control, name, item)
	end

	dropdown:ClearItems()
	for i = 1, #items do
		local item = items[i]
		local entry = dropdown:CreateItemEntry(item.name, OnConfirmed)
		entry.data = item.data
		entry.tooltip = item.tooltip
		entry.lcmItem = item
		dropdown:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
	end

	local current = self.getFunction and self.getFunction()
	local index = FindItemIndex(items, current) or FindItemIndex(items, self.default) or 1
	if index and dropdown:GetNumItems() >= index then
		dropdown:SelectItemByIndex(index, ZO_COMBOBOX_SUPPRESS_UPDATE)
	end
	suppressCallbacks = false

	control._lcmOnItemSelected = function(_, itemData)
		ShowItemOrRowTooltip(self, itemData and (itemData.lcmItem or itemData))
	end
	dropdown:RegisterCallback("OnItemSelected", control._lcmOnItemSelected)

	dropdown:SetDeactivatedCallback(function()
		ShowItemOrRowTooltip(self, nil)
	end)

	if selected == nil then
		selected = LCM.list and LCM.list:GetSelectedControl() == control
	end
	if enabled == nil then
		enabled = not self:IsDisabled()
	end
	ApplyDropdownColors(dropdown, selected, enabled)
end

LCM.createControlFunctions[LCM.CT_DROPDOWN] = LCM.AddControlEntry

LCM.cleanControlFunctions[LCM.CT_DROPDOWN] = function(self, control)
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

LCM.setupControlFunctions[LCM.CT_DROPDOWN] = function(self, params)
	self.items = params.items
	self.labelText = params.label
	self.tooltipText = params.tooltip
	self.setFunction = params.setFunction
	self.getFunction = params.getFunction
	self.default = params.default
	self.ignoreDefault = params.ignoreDefault
	self.disable = params.disable
	self.align = params.align
	self.indent = params.indent
end

function LCM.CreateDropdownPoolFactory()
	return function(control)
		if not control.dropdown then
			local dropdownControl = control:GetNamedChild("Dropdown")
			control.dropdown = ZO_ComboBox_ObjectFromContainer(dropdownControl)
		end
		EnsureDropdownLayout(control.dropdown)
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
		function control:SetValue(data)
			local dropdown = self.dropdown
			if not dropdown then
				return
			end
			local setting = self.data
			local items = setting and setting:GetValueOrCallback(setting.items) or {}
			local index = FindItemIndex(items, data)
			if index then
				dropdown:SelectItemByIndex(index, ZO_COMBOBOX_SUPPRESS_UPDATE)
			end
			if setting and setting:IsDisabled() then
				ApplyDropdownSelectedText(dropdown, false)
			end
		end
	end
end
