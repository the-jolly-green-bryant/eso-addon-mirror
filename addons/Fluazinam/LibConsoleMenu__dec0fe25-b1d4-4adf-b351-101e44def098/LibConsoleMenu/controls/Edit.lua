-- Edit box control.

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

LCM.changeControlStateFunctions[LCM.CT_EDIT] = function(control, state, selected)
	LCM.SetNameControlState(control, state, selected)
	local editBackdrop = control:GetNamedChild("ValueTextField")
	editBackdrop:GetNamedChild("Edit"):SetEditEnabled(state)
end

LCM.updateControlFunctions[LCM.CT_EDIT] = function(self, control)
	control:SetHidden(false)
	local nameControl = control:GetNamedChild("Name")
	local align, _, indentPx = LCM.ResolveRowAlign(self, LCM.currentMenu)
	indentPx = indentPx or 0
	if nameControl then
		nameControl:SetText(self:GetString(self:GetValueOrCallback(self.labelText)))
		LCM.ApplyNameLabelAlign(nameControl, align, indentPx)
		-- Value is stock FullWidth (CONTENT_WIDTH) TOPLEFT under Name. When Name is
		-- left-indented, keep the box at RootSpacer left (offset -indent) so it stays
		-- full content width and does not widen the row / half-shift the entry.
		local valueControl = control:GetNamedChild("Value")
		if valueControl then
			valueControl:ClearAnchors()
			valueControl:SetAnchor(TOPLEFT, nameControl, BOTTOMLEFT, -indentPx, 0)
		end
	end
	local editControl = control.editBox
	editControl:SetTextType(self.textType or TEXT_TYPE_ALL)
	editControl:SetMaxInputChars(self.maxInputChars or MAX_HELP_DESCRIPTION_BODY)
	editControl:SetText(self.getFunction() or "")
	editControl:SetColor(ZO_NORMAL_TEXT:UnpackRGB())
end

LCM.createControlFunctions[LCM.CT_EDIT] = LCM.CreateControlListEntry

LCM.cleanControlFunctions[LCM.CT_EDIT] = function(self)
	self.control:SetHidden(true)
end

LCM.setupControlFunctions[LCM.CT_EDIT] = function(self, params)
	self.textType = params.textType
	self.maxInputChars = params.maxChars
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

local function editGetData(editControl)
	return editControl:GetParent():GetParent():GetParent().data
end

local function editOnEnter(control)
	local data = editGetData(control)
	data:ValueChanged(control:GetText())
	control:LoseFocus()
end

local function editOnEscape(control)
	local data = editGetData(control)
	control:SetText(data.getFunction() or "")
	control:LoseFocus()
end

local function editOnFocusLost(control)
	local data = editGetData(control)
	data:ValueChanged(control:GetText())
	control:SetColor(ZO_NORMAL_TEXT:UnpackRGB())
	control:SetText(data.getFunction() or "")
	control:SetCursorPosition(0)
end

local function editOnFocusGained(control)
	local data = editGetData(control)
	control:SetColor(ZO_HIGHLIGHT_TEXT:UnpackRGB())
	control:SetCursorPosition(ZoUTF8StringLength(control:GetText()) + 1)
	control:TakeFocus()
end

function LCM.CreateEditPoolFactory()
	return function(control)
		local editControl = control:GetNamedChild("ValueTextFieldEdit")
		editControl:SetHandler("OnEnter", editOnEnter)
		editControl:SetHandler("OnEscape", editOnEscape)
		editControl:SetHandler("OnFocusLost", editOnFocusLost)
		editControl:SetHandler("OnFocusGained", editOnFocusGained)
		control.editBox = editControl
		function control:Activate()
			editOnFocusGained(editControl)
		end
		function control:SetValue(value)
			local editControl = self.editBox
			editControl:SetText(value)
		end
	end
end
