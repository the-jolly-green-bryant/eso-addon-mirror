-- Icon picker control: path list or atlas sheet (texture + atlasSizeX/Y).

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

LCM.changeControlStateFunctions[LCM.CT_ICONPICKER] = function(control, state, selected)
	LCM.SetNameControlState(control, state, selected)
	if selected == nil then
		selected = LCM.list and LCM.list:GetSelectedControl() == control
	end
	local combobox = control:GetDropDown()
	combobox:SetSelectedFromParent(selected)
	combobox:RefreshVisible()
end

LCM.updateControlFunctions[LCM.CT_ICONPICKER] = function(self, control)
	control:GetNamedChild("Name"):SetText(self:GetString(self:GetValueOrCallback(self.labelText)))
	local combobox = control:GetDropDown()
	combobox:SetOnSelectedDataChangedCallback(nil)
	combobox:Clear()
	-- Match stock OptionsScrollListSelectionChanged: ignore initial/rebuild selection.
	local callback = function(data, oldData, reselectingDuringRebuild)
		if data and oldData ~= nil and reselectingDuringRebuild ~= true then
			self:ValueChanged(control, data.index, data.icon)
		end
	end
	if self.texture then
		if self.atlasIndices then
			for _, i in ipairs(self.atlasIndices) do
				combobox:AddEntry({index = i, data = self})
			end
		else
			for i = self.atlasStart, self.atlasEnd do
				combobox:AddEntry({index = i, data = self})
			end
		end
	else
		local items = self:GetValueOrCallback(self.items) or {}
		for i = 1, #items do
			combobox:AddEntry({index = i, icon = items[i], data = self})
		end
	end
	combobox:Commit()
	combobox:SetSelectedIndex(combobox:FindIndexFromData({index = self.getFunction()}, combobox.equalityFunction) or self.default or 0, false, true)
	combobox:SetOnSelectedDataChangedCallback(callback)
end

LCM.createControlFunctions[LCM.CT_ICONPICKER] = LCM.AddControlEntry

LCM.cleanControlFunctions[LCM.CT_ICONPICKER] = function(self)
	local combobox = self.control:GetDropDown()
	combobox:SetOnSelectedDataChangedCallback(nil)
end

LCM.setupControlFunctions[LCM.CT_ICONPICKER] = function(self, params)
	self.items = params.items
	self.texture = params.texture
	self.atlasSizeX = params.atlasSizeX
	self.atlasSizeY = params.atlasSizeY
	self.atlasStart = params.atlasStart or 1
	if params.atlasEnd then
		self.atlasEnd = params.atlasEnd
	elseif params.atlasSizeX and params.atlasSizeY then
		self.atlasEnd = params.atlasSizeX * params.atlasSizeY
	else
		self.atlasEnd = nil
	end
	self.atlasIndices = params.atlasIndices
	self.labelText = params.label
	self.tooltipText = params.tooltip
	self.setFunction = params.setFunction
	self.getFunction = params.getFunction
	self.default = params.default
	self.ignoreDefault = params.ignoreDefault
	self.disable = params.disable
end

local function equalityFunctionIconPicker(leftData, rightData)
	return leftData.index == rightData.index
end

function LCM.CreateIconPickerPoolFactory()
	return function(control)
		local horizontalListObject = control.horizontalListObject
		horizontalListObject.equalityFunction = equalityFunctionIconPicker
		control:GetNamedChild("HorizontalList"):SetHeight(64)
		function control:Activate()
			self:GetDropDown():Activate()
		end
		function control:Deactivate()
			self:GetDropDown():Deactivate()
		end
		function control:GetDropDown()
			return self.horizontalListObject
		end
		function control:SetValue(index)
			local combobox = self:GetDropDown()
			local callback = combobox.onSelectedDataChangedCallback
			combobox:SetOnSelectedDataChangedCallback(nil)
			local selectedIndex = combobox:FindIndexFromData({index = index}, combobox.equalityFunction)
			if selectedIndex ~= nil then
				combobox:SetSelectedIndex(selectedIndex, true, true)
			end
			combobox:SetOnSelectedDataChangedCallback(callback)
		end
	end
end

local function GetAtlasCoordinatesFor(n, atlasSizeX, atlasSizeY)
	if n > atlasSizeX * atlasSizeY then
		error(("Index is too big! Max atlas index must be less than %d x %d (%d), requested %d"):format(atlasSizeX, atlasSizeY, atlasSizeX * atlasSizeY, n))
	end

	n = n - 1
	local X, Y = n % atlasSizeX, math.floor(n / atlasSizeX)
	local xStep, yStep = 1 / atlasSizeX, 1 / atlasSizeY

	return xStep * X, xStep * (X + 1), yStep * Y, yStep * (Y + 1)
end

-- Horizontal icon strip for path lists and atlas sheets (called from Controls.xml OnInitialized).
function LCM_GamepadHorizontalListRow_Initialize(self)
	self.GetHeight = function(control)
		return control.label:GetTextHeight() + control.horizontalListControl:GetHeight()
	end
	self.label = self:GetNamedChild("Name")
	self.horizontalListControl = self:GetNamedChild("HorizontalList")

	local function setupFunction(control, data, selected, reselectingDuringRebuild, enabled, selectedFromParent)
		local icon = control:GetNamedChild("Icon")
		local setting = data.data
		if setting.texture then
			icon:SetTexture(setting.texture)
			icon:SetTextureCoords(GetAtlasCoordinatesFor(data.index, setting.atlasSizeX, setting.atlasSizeY))
		else
			icon:SetTexture(data.icon)
			icon:SetTextureCoords(0, 1, 0, 1)
		end
		local color = selectedFromParent and ZO_SELECTED_TEXT or ZO_DISABLED_TEXT
		icon:SetColor(color:UnpackRGBA())
	end

	self.horizontalListObject = ZO_HorizontalScrollList_Gamepad:New(self.horizontalListControl, "LCM_GamepadHorizontalListEntry", 1, setupFunction)
	self.horizontalListObject:SetAllowWrapping(true)
end
