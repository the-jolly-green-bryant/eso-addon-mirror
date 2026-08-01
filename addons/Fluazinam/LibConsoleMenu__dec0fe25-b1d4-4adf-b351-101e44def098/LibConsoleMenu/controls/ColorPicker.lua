-- Color picker control.

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

-- Stock ZO_Options SetupColorOptionActivated (optionswindowtemplate.lua).
local COLOR_SWATCH_ENABLED_ALPHA = 1
local COLOR_SWATCH_DISABLED_ALPHA = 0.5

local function ApplyColorSwatchActivated(control, activated)
	local alpha = activated and COLOR_SWATCH_ENABLED_ALPHA or COLOR_SWATCH_DISABLED_ALPHA
	local color = control.texture or control:GetNamedChild("Color")
	local border = control:GetNamedChild("Border")
	if color then
		color:SetAlpha(alpha)
	end
	if border then
		border:SetAlpha(alpha)
	end
end

LCM.changeControlStateFunctions[LCM.CT_COLORPICKER] = function(control, state, selected)
	LCM.SetNameControlState(control, state, selected)
	ApplyColorSwatchActivated(control, state)
end

LCM.updateControlFunctions[LCM.CT_COLORPICKER] = function(self, control)
	local label = control:GetNamedChild("Name")
	label:SetText(self:GetString(self:GetValueOrCallback(self.labelText)))
	-- SetColor can reset texture alpha; re-apply disabled dim afterward.
	self.control:GetNamedChild("Color"):SetColor(self.getFunction())
	ApplyColorSwatchActivated(self.control, not self:IsDisabled())
end

LCM.createControlFunctions[LCM.CT_COLORPICKER] = LCM.AddControlEntry

LCM.cleanControlFunctions[LCM.CT_COLORPICKER] = function(self)
	self.control:GetNamedChild("Name"):SetText(nil)
end

LCM.setupControlFunctions[LCM.CT_COLORPICKER] = function(self, params)
	self.labelText = params.label
	self.tooltipText = params.tooltip
	self.setFunction = params.setFunction
	self.getFunction = params.getFunction
	self.default = params.default
	self.ignoreDefault = params.ignoreDefault
	self.disable = params.disable
end

local function colorOnSelect(control)
	local data = control.data
	local function colorOnColorSet(r, g, b, a)
		data:ValueChanged(r, g, b, a)
		control.texture:SetColor(data.getFunction())
		ApplyColorSwatchActivated(control, not data:IsDisabled())
	end
	SYSTEMS:GetObject("colorPicker"):Show(colorOnColorSet, data.getFunction())
end

function LCM.CreateColorPickerPoolFactory()
	return function(control)
		control.texture = control:GetNamedChild("Color")
		function control:ShowDialog()
			return colorOnSelect(self)
		end
		function control:SetValue(...)
			self.texture:SetColor(...)
			local data = self.data
			ApplyColorSwatchActivated(self, not (data and data:IsDisabled()))
		end
	end
end

-- Patch the shared gamepad color dialog once (alpha triggers + console-safe font/anchors).
SecurePostHook(
	COLOR_PICKER_GAMEPAD,
	"UpdateDirectionalInput",
	function(self, deltaS)
		local left = GetGamepadLeftTriggerMagnitude()
		local right = GetGamepadRightTriggerMagnitude()
		local currentAlpha = self.alphaSlider:GetValue()
		local net = right - left
		self.alphaSlider:SetValue(currentAlpha + net / 50)
	end
)

COLOR_PICKER_GAMEPAD.alphaLabel:SetFont("ZoFontGamepad22") -- Stock alpha label uses a PC fontdef that does not load on console.
COLOR_PICKER_GAMEPAD.alphaSlider:SetAnchor(TOP, COLOR_PICKER_GAMEPAD.alphaSlider:GetParent():GetNamedChild("ColorSelect"), BOTTOM, 0, 80)
COLOR_PICKER_GAMEPAD.alphaLabel:ClearAnchors()
COLOR_PICKER_GAMEPAD.alphaLabel:SetAnchor(RIGHT, COLOR_PICKER_GAMEPAD.alphaSlider, LEFT, -10, 0)
