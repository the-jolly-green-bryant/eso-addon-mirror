-- Toggle control (On/Off). type = "toggle"; "checkbox" is accepted as an alias.
-- Visuals follow ZO_GamepadOptions: focused shows both On/Off; unfocused shows the
-- active value centered and greyed (checkbox.selected + ZO_DISABLED_TEXT).

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

local function CaptureAnchors(control)
	local anchors = {}
	for i = 0, 1 do
		local isValid, point, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor(i)
		if isValid then
			anchors[#anchors + 1] = { point, relativeTo, relativePoint, offsetX, offsetY }
		end
	end
	return anchors
end

local function RestoreAnchors(control, anchors)
	control:ClearAnchors()
	if not anchors then
		return
	end
	for i = 1, #anchors do
		local a = anchors[i]
		control:SetAnchor(a[1], a[2], a[3], a[4], a[5])
	end
end

local function CenterLabelUnderName(label, nameControl)
	label:ClearAnchors()
	-- Match native: single value sits centered under the option name.
	label:SetAnchor(TOP, nameControl, BOTTOM, 0, 0)
	label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
end

LCM.changeControlStateFunctions[LCM.CT_TOGGLE] = function(control, state, selected)
	LCM.SetNameControlState(control, state, selected)
	local checkbox = control.checkbox
	if checkbox then
		if selected == nil then
			selected = LCM.list and LCM.list:GetSelectedControl() == control
		end
		checkbox.selected = selected and state
	end
end

LCM.updateControlFunctions[LCM.CT_TOGGLE] = function(self, control, selected, enabled)
	control:GetNamedChild("Name"):SetText(self:GetString(self:GetValueOrCallback(self.labelText)))

	if selected == nil then
		selected = LCM.list and LCM.list:GetSelectedControl() == control
	end
	-- Always use setting disable — ignore parametric-list enabled.
	enabled = not self:IsDisabled()

	local collapse = true
	local panel = LCM.currentSettings
	if panel and panel.collapseToggleLabels == false then
		collapse = false
	end

	local function applyToggleVisual(row, state)
		local onLabel = row:GetNamedChild("On")
		local offLabel = row:GetNamedChild("Off")
		local nameControl = row:GetNamedChild("Name")
		local checkbox = row.checkbox

		-- Native ZO_GamepadOptions SetSelectedStateOnControl.
		checkbox.selected = selected and enabled

		if state then
			ZO_CheckButton_SetChecked(checkbox)
		else
			ZO_CheckButton_SetUnchecked(checkbox)
		end

		-- Disabled rows stay collapsed to the active value (same as unfocused).
		local showBoth = enabled and (selected or not collapse)
		if showBoth then
			RestoreAnchors(onLabel, row.lcmToggleOnAnchors)
			RestoreAnchors(offLabel, row.lcmToggleOffAnchors)
			onLabel:SetHorizontalAlignment(row.lcmToggleOnAlign or TEXT_ALIGN_LEFT)
			offLabel:SetHorizontalAlignment(row.lcmToggleOffAlign or TEXT_ALIGN_LEFT)
			onLabel:SetHidden(false)
			offLabel:SetHidden(false)
			-- Focused (or non-collapse): highlight the active choice like stock On/Off pair.
			if state then
				onLabel:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGB())
				offLabel:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGB())
			else
				onLabel:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGB())
				offLabel:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGB())
			end
		else
			-- Unfocused or disabled: only the active value, centered under Name.
			onLabel:SetHidden(not state)
			offLabel:SetHidden(state)
			local activeLabel = state and onLabel or offLabel
			local inactiveLabel = state and offLabel or onLabel
			RestoreAnchors(inactiveLabel, state and row.lcmToggleOffAnchors or row.lcmToggleOnAnchors)
			inactiveLabel:SetHorizontalAlignment(state and row.lcmToggleOffAlign or row.lcmToggleOnAlign or TEXT_ALIGN_LEFT)
			CenterLabelUnderName(activeLabel, nameControl)
			-- Disabled: same tertiary as selector values (not Name gold when focused).
			if not enabled then
				activeLabel:SetColor(ZO_GAMEPAD_DISABLED_UNSELECTED_COLOR:UnpackRGBA())
			else
				activeLabel:SetColor(ZO_GamepadMenuEntryTemplate_GetLabelColor(selected, false):UnpackRGBA())
			end
		end
	end

	local checkbox = control.checkbox
	ZO_CheckButton_SetToggleFunction(checkbox, nil)
	applyToggleVisual(self.control, self.getFunction())
	ZO_CheckButton_SetToggleFunction(
		checkbox,
		function(btn, state)
			applyToggleVisual(btn:GetParent(), state)
			self:ValueChanged(state)
		end
	)
end

LCM.createControlFunctions[LCM.CT_TOGGLE] = LCM.AddControlEntry

LCM.cleanControlFunctions[LCM.CT_TOGGLE] = function(self)
	ZO_CheckButton_SetToggleFunction(self.control:GetNamedChild("Checkbox"), nil)
end

LCM.setupControlFunctions[LCM.CT_TOGGLE] = function(self, params)
	self.labelText = params.label
	self.tooltipText = params.tooltip
	self.setFunction = params.setFunction
	self.getFunction = params.getFunction
	self.default = params.default
	self.ignoreDefault = params.ignoreDefault
	self.disable = params.disable
	self.canSelect = params.canSelect
end

function LCM.CreateTogglePoolFactory()
	return function(control)
		local checkbox = control:GetNamedChild("Checkbox")
		local onLabel = control:GetNamedChild("On")
		local offLabel = control:GetNamedChild("Off")
		control.lcmToggleOnAnchors = CaptureAnchors(onLabel)
		control.lcmToggleOffAnchors = CaptureAnchors(offLabel)
		control.lcmToggleOnAlign = onLabel:GetHorizontalAlignment()
		control.lcmToggleOffAlign = offLabel:GetHorizontalAlignment()
		checkbox.SetText = function(control, text)
		end
		function control:SetValue()
			local data = control.data
			if data then
				LCM.updateControlFunctions[data.type](data, self)
			end
		end
		control.checkbox = checkbox
	end
end
