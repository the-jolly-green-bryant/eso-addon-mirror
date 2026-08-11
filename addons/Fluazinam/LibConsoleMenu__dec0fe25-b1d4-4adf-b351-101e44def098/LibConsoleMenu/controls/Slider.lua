-- Slider control.

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

local function FormatSliderValue(value, formatString)
	local numberValue = tonumber(value) or 0
	return string.format(formatString, numberValue)
end

-- When authors omit format, derive precision from step (1 → whole numbers, 0.5 → 1 dp, 0.01 → 2 dp).
local function InferFormatFromStep(step)
	step = tonumber(step)
	if not step then
		return "%.0f"
	end

	local absStep = math.abs(step)
	local decimals = 0
	while decimals < 6 do
		local scaled = absStep * (10 ^ decimals)
		if math.abs(scaled - zo_round(scaled)) < 1e-8 then
			break
		end
		decimals = decimals + 1
	end

	if decimals == 0 then
		return "%.0f"
	end
	return "%." .. decimals .. "f"
end

-- Coarse shoulder step: min(step*10, ~1/4 range snapped to step); fall back to step if that spans the range.
local function InferBigStep(minValue, maxValue, step)
	step = tonumber(step) or 1
	minValue = tonumber(minValue) or 0
	maxValue = tonumber(maxValue) or minValue
	local range = maxValue - minValue
	if range <= 0 or step <= 0 then
		return step
	end

	local candidate = step * 10
	local quarter = math.max(step, zo_ceil((range / 4) / step) * step)
	local bigStep = math.min(candidate, quarter)
	if bigStep >= range then
		return step
	end
	return bigStep
end

local function BuildValueText(self, value)
	local formatted = FormatSliderValue(value, self.format)
	local unit = self:GetString(self:GetValueOrCallback(self.unit))
	if unit and #unit > 0 then
		return formatted .. unit
	end
	return formatted
end

local function ShouldShowSliderLabels(selected, enabled)
	if enabled == false then
		return false
	end
	local collapse = true
	local panel = LCM.currentMenu
	if panel and panel.collapseSliderLabels == false then
		collapse = false
	end
	return selected or not collapse
end

local function ApplySliderLabelVisibility(slider, show)
	if slider.label then
		slider.label:SetHidden(not show)
	end
	if slider.minLabel then
		slider.minLabel:SetHidden(not show)
	end
	if slider.maxLabel then
		slider.maxLabel:SetHidden(not show)
	end
end

LCM.changeControlStateFunctions[LCM.CT_SLIDER] = function(control, state, selected)
	LCM.SetNameControlState(control, state, selected)
	local slider = control and control.slider
	slider:SetEnabled(state)
	if selected == nil then
		selected = LCM.list and LCM.list:GetSelectedControl() == control
	end
	-- Native options tint the bar with the same label color (row alpha dims unselected).
	local color = ZO_GamepadMenuEntryTemplate_GetLabelColor(selected, not state)
	local r, g, b, a = color:UnpackRGBA()
	slider:SetColor(r, g, b, a)
	slider:GetNamedChild("Left"):SetColor(r, g, b, a)
	slider:GetNamedChild("Right"):SetColor(r, g, b, a)
	slider:GetNamedChild("Center"):SetColor(r, g, b, a)
	ApplySliderLabelVisibility(slider, ShouldShowSliderLabels(selected, state))
end

LCM.updateControlFunctions[LCM.CT_SLIDER] = function(self, control, selected)
	control:GetNamedChild("Name"):SetText(self:GetString(self:GetValueOrCallback(self.labelText)))
	if selected == nil then
		selected = LCM.list and LCM.list:GetSelectedControl() == control
	end
	local enabled = not self:IsDisabled()

	local slider = control.slider
	slider:SetHandler("OnValueChanged", nil)
	slider:SetMinMax(self.min, self.max)
	local value = self.getFunction() or 0
	slider:SetValue(value)
	slider.label:SetText(BuildValueText(self, value))
	slider.minLabel:SetText(tostring(self.min))
	slider.maxLabel:SetText(tostring(self.max))
	ApplySliderLabelVisibility(slider, ShouldShowSliderLabels(selected, enabled))
	slider:SetValueStep(self.step)
	slider:SetHandler(
		"OnValueChanged",
		function(control, value)
			local formattedValue = tonumber(FormatSliderValue(value, self.format))
			control.label:SetText(BuildValueText(self, formattedValue))
			self:ValueChanged(formattedValue)
		end
	)
end

LCM.createControlFunctions[LCM.CT_SLIDER] = LCM.CreateControlListEntry

LCM.cleanControlFunctions[LCM.CT_SLIDER] = function(self, control)
	control.slider:SetHandler("OnValueChanged", nil)
	control.slider:Deactivate()
end

LCM.setupControlFunctions[LCM.CT_SLIDER] = function(self, params)
	self.min = params.min
	self.max = params.max
	self.unit = params.unit
	self.step = params.step
	self.bigStep = params.bigStep or InferBigStep(params.min, params.max, params.step)
	self.format = params.format or InferFormatFromStep(params.step)
	self.labelText = params.label
	self.tooltipText = params.tooltip
	self.setFunction = params.setFunction
	self.getFunction = params.getFunction
	self.default = params.default
	self.ignoreDefault = params.ignoreDefault
	self.disable = params.disable
end

-- direction: -1 decrease, +1 increase. Uses shoulder bigStep while stick keeps fine step.
function LCM.NudgeFocusedSlider(direction)
	local list = LCM.list
	if not list then
		return
	end

	local data = list:GetSelectedData()
	local control = list:GetSelectedControl()
	if not data or not control or data.type ~= LCM.CT_SLIDER or data:IsDisabled() then
		return
	end

	local slider = control.slider
	if not slider then
		return
	end

	local current = tonumber(data.getFunction and data.getFunction() or slider:GetValue()) or 0
	local bigStep = data.bigStep or InferBigStep(data.min, data.max, data.step)
	local target = current + (direction * bigStep)
	if data.min ~= nil then
		target = math.max(data.min, target)
	end
	if data.max ~= nil then
		target = math.min(data.max, target)
	end

	local formattedValue = tonumber(FormatSliderValue(target, data.format or InferFormatFromStep(data.step)))
	if formattedValue == nil then
		return
	end

	-- OnValueChanged (set in update) refreshes the label and calls ValueChanged.
	if slider.SetValueWithSound then
		slider:SetValueWithSound(formattedValue)
	else
		local oldValue = slider:GetValue()
		slider:SetValue(formattedValue)
		if oldValue ~= slider:GetValue() then
			PlaySound(SOUNDS.DEFAULT_CLICK)
		end
	end
end

function LCM.CreateSliderPoolFactory()
	return function(control)
		local slider = control.slider or control:GetNamedChild("Slider")
		control.slider = slider
		control.label = control.label or control:GetNamedChild("Name")
		slider.label = control:GetNamedChild("ValueLabel")
		slider.minLabel = control:GetNamedChild("MinLabel")
		slider.maxLabel = control:GetNamedChild("MaxLabel")
		function control:Activate()
			self.slider:Activate()
		end
		function control:Deactivate()
			self.slider:Deactivate()
		end
		function control:SetValue(...)
			local slider = self.slider
			local handler = slider:GetHandler("OnValueChanged")
			slider:SetHandler("OnValueChanged", nil)
			slider:SetValue(...)
			local data = self.data
			if data and slider.label then
				local value = ...
				slider.label:SetText(BuildValueText(data, value))
			end
			slider:SetHandler("OnValueChanged", handler)
		end
	end
end
