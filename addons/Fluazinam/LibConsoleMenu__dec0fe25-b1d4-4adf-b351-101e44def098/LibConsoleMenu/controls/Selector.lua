-- Selector control: horizontal scroll list (left/right under the label).

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

LCM.changeControlStateFunctions[LCM.CT_SELECTOR] = function(control, state, selected)
	LCM.SetNameControlState(control, state, selected)
	if selected == nil then
		selected = LCM.list and LCM.list:GetSelectedControl() == control
	end
	local dropdown = control:GetDropDown()
	-- List enabled feeds setup's `enabled`. Stock keeps value tertiary when disabled
	-- (ZO_GAMEPAD_DISABLED_UNSELECTED_COLOR), not Name gold.
	dropdown:SetEnabled(state)
	dropdown:SetSelectedFromParent(selected)
	dropdown:RefreshVisible()
end

LCM.updateControlFunctions[LCM.CT_SELECTOR] = function(self, control, selected, enabled)
	control:GetNamedChild("Name"):SetText(self:GetString(self:GetValueOrCallback(self.labelText)))
	local combobox = control:GetDropDown()
	combobox:SetOnSelectedDataChangedCallback(nil)
	combobox:Clear()
	-- Match stock OptionsScrollListSelectionChanged: ignore initial/rebuild selection.
	local callback = function(data, oldData, reselectingDuringRebuild)
		if data and oldData ~= nil and reselectingDuringRebuild ~= true then
			self:ValueChanged(control, data.name, data)
		end
	end
	local items = self:GetValueOrCallback(self.items)
	for i = 1, #items do
		combobox:AddEntry(items[i])
	end
	combobox:Commit()
	combobox:SetSelectedIndex(combobox:FindIndexFromData(self.getFunction(), combobox.equalityFunction) or self.default or 0, false, true)
	combobox:SetOnSelectedDataChangedCallback(callback)
	if selected == nil then
		selected = LCM.list and LCM.list:GetSelectedControl() == control
	end
	if enabled == nil then
		enabled = not self:IsDisabled()
	end
	combobox:SetEnabled(enabled)
	combobox:SetSelectedFromParent(selected)
	combobox:RefreshVisible()
end

LCM.createControlFunctions[LCM.CT_SELECTOR] = LCM.AddControlEntry

LCM.cleanControlFunctions[LCM.CT_SELECTOR] = function(self)
	local combobox = self.control:GetDropDown()
	combobox:SetOnSelectedDataChangedCallback(nil)
end

LCM.setupControlFunctions[LCM.CT_SELECTOR] = function(self, params)
	self.items = params.items
	self.labelText = params.label
	self.tooltipText = params.tooltip
	self.setFunction = params.setFunction
	self.getFunction = params.getFunction
	self.default = params.default
	self.ignoreDefault = params.ignoreDefault
	self.disable = params.disable
end

local function setupSelector(control, data, selected, reselectingDuringRebuild, enabled, selectedFromParent)
	if not enabled then
		control:SetText(GetString(SI_CHECK_BUTTON_DISABLED))
		control:SetColor(ZO_GAMEPAD_DISABLED_UNSELECTED_COLOR:UnpackRGBA())
	else
		control:SetText(data.name)
		local color = ZO_GamepadMenuEntryTemplate_GetLabelColor(selectedFromParent, false)
		control:SetColor(color:UnpackRGBA())
	end
end

local function equalityFunctionSelector(leftData, rightData)
	if leftData == rightData then
		return true
	end
	local leftName = type(leftData) == "table" and leftData.name or leftData
	local rightName = type(rightData) == "table" and rightData.name or rightData
	if leftName ~= nil and leftName == rightName then
		return true
	end
	local leftVal = type(leftData) == "table" and leftData.data or leftData
	local rightVal = type(rightData) == "table" and rightData.data or rightData
	return leftVal ~= nil and leftVal == rightVal
end

function LCM.CreateSelectorPoolFactory()
	return function(control)
		local horizontalListObject = control.horizontalListObject
		horizontalListObject.setupFunction = setupSelector
		horizontalListObject.equalityFunction = equalityFunctionSelector
		function control:Activate()
			self:GetDropDown():Activate()
		end
		function control:Deactivate()
			self:GetDropDown():Deactivate()
		end
		function control:GetDropDown()
			return self.horizontalListObject
		end
		function control:SetValue(data)
			local combobox = self:GetDropDown()
			-- registerForRefresh sync must not re-fire setFunc.
			local callback = combobox.onSelectedDataChangedCallback
			combobox:SetOnSelectedDataChangedCallback(nil)
			local index = combobox:FindIndexFromData(data, combobox.equalityFunction)
			if index ~= nil then
				combobox:SetSelectedIndex(index, true, true)
			end
			combobox:SetOnSelectedDataChangedCallback(callback)
		end
	end
end
