-- Edit box control (single-line and multiLine templates).

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

LCM.changeControlStateFunctions[LCM.CT_EDITBOX] = function(control, state, selected)
	LCM.SetNameControlState(control, state, selected)
	local editBackdrop = control:GetNamedChild("ValueTextField")
	if editBackdrop then
		editBackdrop:GetNamedChild("Edit"):SetEditEnabled(state)
	end
end

local function hasLabel(self)
	local label = self.labelText
	if label == nil then
		return false
	end
	if type(label) == "string" and label == "" then
		return false
	end
	local resolved = self:GetString(self:GetValueOrCallback(label))
	return resolved ~= nil and resolved ~= ""
end

LCM.updateControlFunctions[LCM.CT_EDITBOX] = function(self, control)
	control:SetHidden(false)
	local nameControl = control:GetNamedChild("Name")
	local valueControl = control:GetNamedChild("Value")
	local align, _, indentPx = LCM.ResolveRowAlign(self, LCM.currentMenu)
	indentPx = indentPx or 0
	local showLabel = hasLabel(self)

	if nameControl then
		if showLabel then
			nameControl:SetHidden(false)
			nameControl:SetText(self:GetString(self:GetValueOrCallback(self.labelText)))
			LCM.ApplyNameLabelAlign(nameControl, align, indentPx)
		else
			nameControl:SetText("")
			nameControl:SetHidden(true)
		end
	end

	if valueControl then
		valueControl:ClearAnchors()
		local root = control:GetNamedChild("RootSpacer") or control
		if showLabel and nameControl then
			-- Value is stock FullWidth under Name. When Name is left-indented, keep
			-- the box at RootSpacer left (offset -indent) so it stays full content width.
			valueControl:SetAnchor(TOPLEFT, nameControl, BOTTOMLEFT, -indentPx, 0)
		else
			valueControl:SetAnchor(TOPLEFT, root, TOPLEFT, 0, 0)
		end
	end

	local editControl = control.editBox
	if not editControl then
		return
	end
	editControl:SetTextType(self.textType or TEXT_TYPE_ALL)
	editControl:SetMaxInputChars(self.maxInputChars or MAX_HELP_DESCRIPTION_BODY)
	local placeholder = self.placeholderText
	if placeholder ~= nil then
		editControl:SetDefaultText(self:GetString(self:GetValueOrCallback(placeholder)) or "")
	else
		editControl:SetDefaultText("")
	end
	editControl:SetAsPassword(self.isPassword == true)
	editControl:SetText(self.getFunction() or "")
	editControl:SetColor(ZO_NORMAL_TEXT:UnpackRGB())
end

LCM.createControlFunctions[LCM.CT_EDITBOX] = LCM.CreateControlListEntry

LCM.cleanControlFunctions[LCM.CT_EDITBOX] = function(self)
	self.control:SetHidden(true)
end

LCM.setupControlFunctions[LCM.CT_EDITBOX] = function(self, params)
	self.textType = params.textType
	self.maxInputChars = params.maxInputCharacters
	self.multiLine = params.multiLine == true
	self.placeholderText = params.placeholderText
	self.isPassword = params.isPassword == true
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
	if not data or data.multiLine then
		return
	end
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

function LCM.CreateEditBoxPoolFactory()
	return function(control)
		local editControl = control:GetNamedChild("ValueTextFieldEdit")
		-- multiLine: leave Enter unbound for newline insert (stock multiline templates).
		if control.isLcmMultiLine then
			editControl:SetHandler("OnEnter", nil)
		else
			editControl:SetHandler("OnEnter", editOnEnter)
		end
		editControl:SetHandler("OnEscape", editOnEscape)
		editControl:SetHandler("OnFocusLost", editOnFocusLost)
		editControl:SetHandler("OnFocusGained", editOnFocusGained)
		control.editBox = editControl
		function control:Activate()
			editOnFocusGained(editControl)
		end
		function control:SetValue(value)
			local box = self.editBox
			box:SetText(value)
		end
	end
end
