-- Button control.

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

LCM.changeControlStateFunctions[LCM.CT_BUTTON] = function(control, state, selected)
	LCM.SetNameControlState(control, state, selected)
end

LCM.updateControlFunctions[LCM.CT_BUTTON] = function(self, control)
	control:SetHidden(false)
	control:GetNamedChild("Name"):SetText(self:GetString(self:GetValueOrCallback(self.labelText) or self:GetValueOrCallback(self.buttonText)))
end

LCM.createControlFunctions[LCM.CT_BUTTON] = LCM.AddControlEntry

LCM.cleanControlFunctions[LCM.CT_BUTTON] = function(self)
end

LCM.setupControlFunctions[LCM.CT_BUTTON] = function(self, params)
	self.clickHandler = params.clickHandler
	self.labelText = params.label
	self.tooltipText = params.tooltip
	self.default = params.default
	self.ignoreDefault = params.ignoreDefault
	self.disable = params.disable
	self.buttonText = params.buttonText
end
