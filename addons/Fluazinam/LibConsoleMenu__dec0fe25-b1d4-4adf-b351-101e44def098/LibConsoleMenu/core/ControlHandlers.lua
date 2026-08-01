-- Shared control helpers + AddonSettingsControl dispatch.
-- Individual types live under controls/*.lua and register into the handler tables.

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

function LCM.SetNameControlState(control, enabled, selected)
	-- Match ZO_GamepadOptions SetSelectedStateOnControl: dim unselected rows, tint Name, grow font.
	if selected == nil then
		selected = LCM.list and LCM.list:GetSelectedControl() == control
	end
	control:SetAlpha(ZO_GamepadMenuEntryTemplate_GetAlpha(selected))
	local nameControl = control:GetNamedChild("Name")
	if nameControl then
		local color = ZO_GamepadMenuEntryTemplate_GetLabelColor(selected, not enabled)
		nameControl:SetColor(color:UnpackRGB())
		SetMenuEntryFontFace(nameControl, selected)
	end
end

function LCM.AddControlEntry(self)
	LCM:AddSettingEntry(self)
end

function LCM.AddonSettingsControl:SetupControl(params)
	local setup = LCM.setupControlFunctions[self.type]
	if setup then
		setup(self, params)
	end
	self.popSection = params.popSection
	self.headerText = params.header
	self.headerAlign = params.headerAlign
end

function LCM.AddonSettingsControl:CreateControl(lastControl)
	local create = LCM.createControlFunctions[self.type]
	if create then
		create(self, lastControl)
	end
end

function LCM.AddonSettingsControl:SetEnabled(state, selected)
	local change = LCM.changeControlStateFunctions[self.type]
	if self.control and change then
		change(self.control, state, selected)
	end
end

function LCM.AddonSettingsControl:UpdateControl()
	local updateFunc = LCM.updateControlFunctions[self.type]
	if self.control and updateFunc then
		updateFunc(self, self.control)
	end
	self:SetEnabled(not self:IsDisabled())
end

function LCM.AddonSettingsControl:CleanUp()
	self:SetEnabled(true)
end
