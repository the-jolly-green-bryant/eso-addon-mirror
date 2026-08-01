--[[
Author: Jarth
Filename: Settings_List.lua
]] --
-------------------------------------------------------------------------------------------------
-- VARIABLES --
-------------------------------------------------------------------------------------------------
local base = CollectionBars
local texts = base.Texts

-------------------------------------------------------------------------------------------------
-- FUNCTIONS --
-------------------------------------------------------------------------------------------------
CBs_Settings_List = ZO_SortFilterList:Subclass()

function CBs_Settings_List:New(...)
	base:Debug("CBs_Settings_List:New", ...)

	self.list = ZO_SortFilterList.New(self, ...)
	self.masterListType = "Collectibles"
	return self.list
end

function CBs_Settings_List:Initialize(category, ...)
	base:Debug("CBs_Settings_List:Initialize", ...)

	ZO_SortFilterList.Initialize(self, ...)
	self.category = category
	self.masterList = {}

	if not (self.category and self.category.Enabled) then
		self.masterListType = "Categories"
	end

	self:SetAlternateRowBackgrounds(false)
	self:AppendDataTypes()
end

-------------------------------------------------------------------------------------------------
-- FUNCTIONS - Append DataTypes --
-------------------------------------------------------------------------------------------------

function CBs_Settings_List:AppendDataTypes()
	base:Debug("CBs_Settings_List:AppendDataTypes")

	local listRowAnd = string.format(texts.FormatAbbreviationLowDash .. "_ListRow_%%s", "Settings")
	local dataTypes = {
		[10] = {
			name = string.format(listRowAnd, "Checkbox"),
			height = 40,
			func = function(...)
				self:SetupRow_Checkbox(...)
			end
		},
		[11] = {
			name = string.format(listRowAnd, "Category_Title"),
			height = 40,
			func = function(...)
				self:SetupRow_Category_Title(...)
			end
		},
		[15] = {
			name = string.format(listRowAnd, "Category_Checkbox"),
			height = 40,
			func = function(...)
				self:SetupRow_Category_Checkbox(...)
			end
		},
		[20] = {
			name = string.format(listRowAnd, "Dropdown"),
			height = 40,
			func = function(...)
				self:SetupRow_Dropdown(...)
			end
		},
		[30] = {
			name = string.format(listRowAnd, "Slider"),
			height = 40,
			func = function(...)
				self:SetupRow_Slider(...)
			end
		},
		[40] = {
			name = string.format(listRowAnd, "EditBox"),
			height = 40,
			func = function(...)
				self:SetupRow_EditBox(...)
			end
		},
		[50] = {
			name = string.format(listRowAnd, "Title"),
			height = 40,
			func = function(...)
				self:SetupRow_Title(...)
			end
		},
		[60] = {
			name = string.format(listRowAnd, "Button"),
			height = 40,
			func = function(...)
				self:SetupRow_Button(...)
			end
		},
		[100] = {
			name = string.format(listRowAnd, "Divider"),
			height = 6,
			func = function(...)
				ZO_SortFilterList.SetupRow(self, ...)
			end
		}
	}

	for index, dataType in pairs(dataTypes) do
		ZO_ScrollList_AddDataType(self.list, index, dataType.name, dataType.height, dataType.func)
	end
end

-------------------------------------------------------------------------------------------------
-- FUNCTIONS - Append and Setup RowTypes --
-------------------------------------------------------------------------------------------------

function CBs_Settings_List:AppendRow_Checkbox(listType, data)
	base:Debug("CBs_Settings_List:AppendRow_Checkbox", listType, data)

	data.listType = listType
	data.dataTypeId = 10
	table.insert(self.masterList, data)
end

function CBs_Settings_List:SetupRow_Checkbox(control, data)
	base:Debug("CBs_Settings_List:SetupRow_Checkbox", control, data)

	control.data = data
	ZO_SortFilterList.SetupRow(self, control, data)

	control.checkbox = GetControl(control, "Checkbox")

	if control.checkbox then
		control.checkbox.tooltipText = data.tooltipText
		ZO_CheckButton_SetCheckState(control.checkbox, control.data.funcGet and control.data.funcGet())
		ZO_CheckButton_SetLabelText(control.checkbox, data.name)

		if control.checkbox.label then
			control.checkbox.label.defaultNormalColor = ZO_DEFAULT_ENABLED_COLOR
			control.checkbox.label:ClearAnchors()
			control.checkbox.label:SetAnchor(TOPLEFT, control, TOPLEFT, 0)
			control.checkbox.label:SetAnchor(BOTTOMRIGHT, control.checkbox, BOTTOMLEFT)
		end

		ZO_CheckButton_SetTooltipAnchor(control.checkbox, TOP, control.checkbox.label)
		ZO_CheckButton_SetToggleFunction(control.checkbox, control.data.funcSet)
		ZO_CheckButton_SetEnableState(control.checkbox, not (control.data.disabledFunc and control.data.disabledFunc()))
	end
end

function CBs_Settings_List:AppendRow_Category_Title(listType, data)
	base:Debug("CBs_Settings_List:AppendRow_Category_Title", listType, data)

	data.listType = listType
	data.dataTypeId = 11
	table.insert(self.masterList, data)
end

function CBs_Settings_List:SetupRow_Category_Title(control, data)
	base:Debug("CBs_Settings_List:SetupRow_Category_Title", control, data)

	control.data = data
	ZO_SortFilterList.SetupRow(self, control, control.data)
	local funcMouseEnter = nil
	local funcMouseExit = nil
	control:SetHidden(false)
	control:SetAlpha(1)

	if data.hasChildren then
		control:SetHandler("OnMouseUp", function()
			base.Global.ShowChildren[data.name] = not base.Global.ShowChildren[data.name]
			data.icon = base.ToggleButtonIcon[base.Global.ShowChildren[data.name] == base.ToggleButtonState.OPEN]
			base.Global.Settings.List:RefreshFilters()
		end)
		funcMouseEnter = function(_control)
			ZO_Tooltips_ShowTextTooltip(_control, BOTTOM, _control.data.tooltipText)
		end
		funcMouseExit = function()
			ZO_Tooltips_HideTextTooltip()
		end
	end

	self.SetNameText(control, control.data.name)
	self.SetupIcon(control, control.data, funcMouseEnter, funcMouseExit)
	self.SetActiveOrInactive(control)
end

function CBs_Settings_List:AppendRow_Category_Checkbox(listType, data)
	base:Debug("CBs_Settings_List:AppendRow_Category_Checkbox", listType, data)

	data.listType = listType
	data.dataTypeId = 15
	table.insert(self.masterList, data)
end

function CBs_Settings_List:SetupRow_Category_Checkbox(control, data)
	base:Debug("CBs_Settings_List:SetupRow_Category_Checkbox", control, data)

	control.data = data
	self:SetupRow_Checkbox(control, data)
	control.button = GetControl(control, "Button")

	if control.button then
		control.button:SetHidden(false)
		local isEnabled = control.data.funcGet and control.data.funcGet()
		ZO_CheckButton_SetEnableState(control.button, isEnabled)
		control.button:SetAlpha(isEnabled and 1 or 0.5)
		base:SetupSettingsFrameHandlers(control.button, data.tooltipText, function(_, button)
			PlaySound(SOUNDS.SINGLE_SETTING_RESET_TO_DEFAULT)
			control.data.funcCog(button)
		end)
	end

	local hasIcon = self.SetupIcon(control, data)
	if control.checkbox ~= nil and control.checkbox.label ~= nil and hasIcon then
		control.checkbox.label:SetAnchor(TOPLEFT, control, TOPLEFT, 26)
	end
end

function CBs_Settings_List:AppendRow_Dropdown(listType, data)
	base:Debug("CBs_Settings_List:AppendRow_Dropdown", listType, data)

	data.listType = listType
	data.dataTypeId = 20
	table.insert(self.masterList, data)
end

function CBs_Settings_List:SetupRow_Dropdown(control, data)
	base:Debug("CBs_Settings_List:SetupRow_Dropdown", control, data)

	control.data = data
	ZO_SortFilterList.SetupRow(self, control, data)

	control.dropdown = GetControl(control, "Dropdown")
	control.comboBox = ZO_ComboBox_ObjectFromContainer(control.dropdown)
	control.comboBox:SetSortsItems(false)
	control.comboBox:SetFont(texts.Font.ZoFontWinT1)
	control.comboBox:SetSpacing(4)
	control.comboBox.tooltipText = data.tooltipText

	self.SetNameText(control, control.data.name)
	self.RepopulateDropdownOptions(control)
	self.SetActiveOrInactive(control)
end

function CBs_Settings_List:AppendRow_Slider(listType, data)
	base:Debug("CBs_Settings_List:AppendRow_Slider", listType, data)

	data.listType = listType
	data.dataTypeId = 30
	table.insert(self.masterList, data)
end

function CBs_Settings_List:SetupRow_Slider(control, data)
	base:Debug("CBs_Settings_List:SetupRow_Slider", control, data)

	control.data = data
	ZO_SortFilterList.SetupRow(self, control, control.data)

	control.slider = GetControl(control, "Slider")
	-- Need to override the existing value changed handler first so it doesn't run when we do the SetMinMax
	control.slider:SetHandler("OnValueChanged", nil)
	control.slider:SetMinMax(control.data.minValue, control.data.maxValue)
	control.slider:SetValueStep(control.data.valueStep or 1)
	control.slider:SetValue(data.funcGet())
	control.slider:SetHandler("OnValueChanged", control.data.funcSet)

	if data.default then
		if control.defaultMarkerControl == nil then
			control.defaultMarkerControl = CreateControlFromVirtual("$(parent)DefaultMarker", control.slider, "ZO_Options_DefaultMarker")
		end

		local offsetX = zo_clampedPercentBetween(data.minValue, data.maxValue, data.default) * control.slider:GetWidth()
		control.defaultMarkerControl:SetAnchor(TOP, control.slider, LEFT, offsetX + .25, 6)

		control.defaultMarkerControl:SetHandler("OnClicked", function()
			PlaySound(SOUNDS.SINGLE_SETTING_RESET_TO_DEFAULT)
			control.slider:SetValue(data.default)
			control.data.funcSet(control.slider, data.default)
		end)
	end

	local valueLabelControl = GetControl(control, "ValueLabel")

	if valueLabelControl and data.showValue then
		local shownVal = data.funcGet()

		if data.valueMin and data.valueMax and data.valueMax > data.valueMin then
			local range = data.maxValue - data.minValue
			local percentage = (shownVal - data.minValue) / range

			local shownRange = data.valueMax - data.valueMin
			shownVal = data.valueMin + percentage * shownRange
			shownVal = string.format(texts.Format.Decimal, shownVal)
		end

		valueLabelControl:SetText(shownVal)
	end

	self.SetNameText(control, control.data.name)
	self.SetActiveOrInactive(control)
end

function CBs_Settings_List:AppendRow_EditBox(listType, data)
	base:Debug("CBs_Settings_List:AppendRow_EditBox", listType, data)

	data.listType = listType
	data.dataTypeId = 40
	table.insert(self.masterList, data)
end

function CBs_Settings_List:SetupRow_EditBox(control, data)
	base:Debug("CBs_Settings_List:SetupRow_EditBox", control, data)

	control.data = data
	ZO_SortFilterList.SetupRow(self, control, control.data)

	control.editBox = GetControl(control, "EditBox")

	if control.editBox then
		ZO_EditDefaultText_Initialize(control.editBox)
		control.editBox:SetHandler("OnTextChanged", nil)
		control.editBox:SetText(data.funcGet())
		control.editBox:SetHandler("OnTextChanged", function()
			data.funcSet(control.editBox)
		end)
	end

	self.SetNameText(control, control.data.name)
	self.SetActiveOrInactive(control)
end

function CBs_Settings_List:AppendRow_Title(listType, data)
	base:Debug("CBs_Settings_List:AppendRow_Title", listType, data)

	data.listType = listType
	data.dataTypeId = 50
	table.insert(self.masterList, data)
end

function CBs_Settings_List:SetupRow_Title(control, data)
	base:Debug("CBs_Settings_List:SetupRow_Title", control, data)

	control.data = data
	ZO_SortFilterList.SetupRow(self, control, data)

	local fontOverrides = nil

	if data.hasChildren then
		fontOverrides = {font = texts.Font.ZoFontWinH4, modifyTextType = MODIFY_TEXT_TYPE_NONE}
	end

	self.SetNameText(control, data.name, fontOverrides)
	self.SetActiveOrInactive(control)
end

function CBs_Settings_List:AppendRow_Button(listType, data)
	base:Debug("CBs_Settings_List:AppendRow_Button", listType, data)

	data.listType = listType
	data.dataTypeId = 60
	table.insert(self.masterList, data)
end

function CBs_Settings_List:SetupRow_Button(control, data)
	base:Debug("CBs_Settings_List:SetupRow_Button", control, data)

	control.data = data
	ZO_SortFilterList.SetupRow(self, control, control.data)

	control.button = GetControl(control, "Button")

	if control.button then
		control.button:SetText(control.data.buttonName or "")
		control.button:SetHandler("OnClicked", function()
			control.data.funcSet()
		end)
	end

	self.SetNameText(control, control.data.name)
	self.SetActiveOrInactive(control)
end

function CBs_Settings_List:AppendRow_Divider(listType, data)
	base:Debug("CBs_Settings_List:AppendRow_Divider", listType, data)

	data.listType = listType
	data.dataTypeId = 100
	table.insert(self.masterList, data)
end

-------------------------------------------------------------------------------------------------
-- FUNCTIONS - SetupRowType - Helpers --
-------------------------------------------------------------------------------------------------
function CBs_Settings_List.RepopulateDropdownOptions(control)
	base:Debug("CBs_Settings_List.RepopulateDropdownOptions", control)

	control.comboBox:ClearItems()

	local selectedValue = control.data.funcGet()
	local selectedEntry = nil

	for _, optionValue in pairs(control.data.choices or {}) do
		local entry = ZO_ComboBox:CreateItemEntry(optionValue, control.data.funcSet)
		control.comboBox:AddItem(entry)

		if optionValue == selectedValue then
			selectedEntry = entry
		end
	end

	control.comboBox:SelectItem(selectedEntry)
end

function CBs_Settings_List.SetNameText(control, text, fontOverrides)
	base:Debug("CBs_Settings_List.SetNameText", control, text, fontOverrides)

	if control.label == nil then
		control.label = GetControl(control, "Name")
	end

	if control.label ~= nil then
		if fontOverrides ~= nil then
			control.label:SetFont(fontOverrides.font)
			control.label:SetModifyTextType(fontOverrides.modifyTextType)
		end

		control.label:SetText(text or "")
	end
end

function CBs_Settings_List.SetupIcon(control, data, funcMouseEnter, funcMouseExit)
	base:Debug("CBs_Settings_List.SetupIcon", control, data)

	if control.icon == nil then
		control.icon = GetControl(control, "Icon")
	end

	if control.icon ~= nil then
		local hasIcon = data.icon ~= nil
		control.icon:SetHidden(not hasIcon)
		control.icon:SetTexture(data.icon and data.icon[base.IconState.NORMAL])

		if data.icon[base.IconState.NORMAL] ~= nil and data.icon[base.IconState.OVER] ~= nil then
			control:SetHandler("OnMouseEnter", function()
				control.icon:SetTexture(data.icon[base.IconState.OVER])
				if funcMouseEnter ~= nil then
					funcMouseEnter(control)
				end
			end)
			control:SetHandler("OnMouseExit", function()
				control.icon:SetTexture(data.icon[base.IconState.NORMAL])
				if funcMouseExit ~= nil then
					funcMouseExit(control)
				end
			end)
		end

		return hasIcon
	end
end

function CBs_Settings_List.SetActiveOrInactive(control)
	base:Debug("CBs_Settings_List.SetActiveOrInactive", control)

	local disabled = control.data.disabledFunc and control.data.disabledFunc()
	local disabledColor = ZO_DEFAULT_DISABLED_COLOR
	local enabledColor = ZO_DEFAULT_ENABLED_COLOR
	local function SetColor(label)
		if label then
			local color = enabledColor

			if disabled then
				label:SetColor(disabledColor:UnpackRGBA())
			end

			label:SetColor(color:UnpackRGBA())
		end

	end

	local function SetEnabled(element)
		if element then
			element:SetEnabled(not disabled)
		end
	end

	control.label = GetControl(control, "Name")
	SetColor(control.label)

	control.valueLabelControl = GetControl(control, "ValueLabel")
	SetColor(control.valueLabelControl)

	SetEnabled(control.button)
	SetEnabled(control.comboBox)
	SetEnabled(control.slider)

	if control.editBox then
		ZO_DefaultEdit_SetEnabled(control.editBox, not disabled)
	end
end

-------------------------------------------------------------------------------------------------
-- FUNCTIONS - MasterList --
-------------------------------------------------------------------------------------------------
function CBs_Settings_List:BuildMasterList()
	base:Debug("CBs_Settings_List:BuildMasterList")

	self.masterList = {}

	base.AppendMasterListTypeGeneral(self, "General")
	base.AppendMasterListTypeCategories(self, "Categories")
	base.AppendMasterListTypeCombined(self, "Combined")

	if self.category then
		base.AppendMasterListTypeCollectibles(self, "Collectibles")
		base.AppendMasterListTypeCategory(self, "Category")
	else
		base.AppendMasterListTypeNoCategory(self, "Collectibles")
		base.AppendMasterListTypeNoCategory(self, "Category")
	end
end

function CBs_Settings_List:FilterScrollList()
	base:Debug("CBs_Settings_List:FilterScrollList")

	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

	for _, listElement in ipairs(self.masterList) do
		if self.masterListType == nil or self.masterListType == listElement.listType then
			if self.masterListType == "Categories" and listElement.parentKey ~= nil then
				local showChildren = base.Global.ShowChildren[listElement.parentKey]

				if showChildren then
					scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(listElement.dataTypeId, listElement)
				end
			else
				scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(listElement.dataTypeId, listElement)
			end
		end
	end
end

function CBs_Settings_List:SortScrollList()
end
