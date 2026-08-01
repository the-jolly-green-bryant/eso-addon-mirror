-- Label control.

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

LCM.updateControlFunctions[LCM.CT_LABEL] = function(self, control)
	local label = control.label
	label:SetText(self:GetString(self:GetValueOrCallback(self.labelText)))
	if self.canSelect ~= nil then
		control.canSelect = self:GetValueOrCallback(self.canSelect)
	else
		self.canSelect = self.tooltipText ~= nil
	end
	control:SetHeight(label:GetTextHeight())
end

LCM.createControlFunctions[LCM.CT_LABEL] = LCM.AddControlEntry

LCM.cleanControlFunctions[LCM.CT_LABEL] = function(self)
	self.control.label:SetText(nil)
end

LCM.setupControlFunctions[LCM.CT_LABEL] = function(self, params)
	self.labelText = params.label
	self.tooltipText = params.tooltip
	self.canSelect = params.canSelect
end

local LABEL_FONTS = {
	{ font = "ZoFontGamepad34", lineLimit = 5 },
	{ font = "ZoFontGamepad27", lineLimit = 6 },
	{ font = "ZoFontGamepad22", lineLimit = 7 },
}

function LCM.CreateLabelPoolFactory()
	return function(control)
		local label = control:GetNamedChild("Name")
		control.label = label
		ZO_FontAdjustingWrapLabel_OnInitialized(label, LABEL_FONTS, TEXT_WRAP_MODE_ELLIPSIS)
	end
end
