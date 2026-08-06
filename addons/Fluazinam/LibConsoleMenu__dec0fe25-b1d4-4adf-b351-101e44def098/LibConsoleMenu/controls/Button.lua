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
	local nameControl = control:GetNamedChild("Name")
	local text = self:GetString(self:GetValueOrCallback(self.labelText) or self:GetValueOrCallback(self.buttonText))
	local align, _, indentPx = LCM.ResolveRowAlign(self, LCM.currentSettings)
	if nameControl then
		nameControl:SetText(text)
		LCM.ApplyNameLabelAlign(nameControl, align, indentPx)
	end
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
	self.align = params.align
	self.indent = params.indent
end
