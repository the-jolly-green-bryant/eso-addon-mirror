-- Screen header band: merge author screenHeader into headerData; header control widget (dropdown).

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

LCM.SCREEN_HEADER_PASSTHROUGH_KEYS = {
	"titleText",
	"titleTextAlignment",
	"titleTextNarration",
	"subtitleText",
	"subtitleTextNarration",
	"messageText",
	"messageTextAlignment",
	"messageTextNarration",
	"data1HeaderText",
	"data1Text",
	"data1HeaderTextNarration",
	"data1TextNarration",
	"data2HeaderText",
	"data2Text",
	"data2HeaderTextNarration",
	"data2TextNarration",
	"data3HeaderText",
	"data3Text",
	"data3HeaderTextNarration",
	"data3TextNarration",
	"data4HeaderText",
	"data4Text",
	"data4HeaderTextNarration",
	"data4TextNarration",
}

local function ResolveAuthorString(value)
	if value == nil then
		return nil
	end
	if type(value) == "function" then
		return value()
	end
	if type(value) == "number" then
		return GetString(value)
	end
	return value
end

function LCM.GetActiveScreenHeaderConfig()
	local scrollList = LCM.scrollList
	if not scrollList then
		return nil
	end
	local list = scrollList:GetCurrentList() or LCM.list
	local submenu = list and list.currentSubmenu
	if submenu and submenu.screenHeaderConfig then
		return submenu.screenHeaderConfig
	end
	local addon = LCM.currentMenu
	if addon and addon.screenHeaderConfig then
		return addon.screenHeaderConfig
	end
	return nil
end

function LCM.MergeScreenHeaderData(headerData, config)
	if not config then
		return headerData
	end
	for i = 1, #LCM.SCREEN_HEADER_PASSTHROUGH_KEYS do
		local key = LCM.SCREEN_HEADER_PASSTHROUGH_KEYS[i]
		if config[key] ~= nil then
			headerData[key] = config[key]
		end
	end
	return headerData
end

local function BuildChoiceItems(choices)
	local items = {}
	local labelMap = {}
	for i = 1, #(choices or {}) do
		local choice = choices[i]
		local name
		local value
		local tooltip
		if type(choice) == "table" then
			name = choice.name
			value = choice.value
			if value == nil then
				value = name
			end
			if name == nil then
				name = tostring(value)
			end
			tooltip = choice.tooltip
		else
			name = choice
			value = choice
		end
		items[i] = { name = name, data = value, tooltip = tooltip }
		if value ~= nil then
			labelMap[value] = name
		end
	end
	return items, labelMap
end

local function FindItemIndex(items, target)
	if not items or target == nil then
		return nil
	end
	for i = 1, #items do
		local item = items[i]
		if item.data == target or item.name == target then
			return i
		end
	end
	return nil
end

LCM_Screen_Header_Control_Focus = ZO_InitializingCallbackObject:Subclass()

function LCM_Screen_Header_Control_Focus:Initialize(dropdownControl)
	self.control = dropdownControl
	self.dropdown = ZO_ComboBox_ObjectFromContainer(dropdownControl)
	LCM.EnsureDropdownLayout(self.dropdown)
	self.active = false
	self.enabled = true
end

function LCM_Screen_Header_Control_Focus:Activate()
	self.active = true
	self:Update()
	self:FireCallbacks("FocusActivated")
end

function LCM_Screen_Header_Control_Focus:Enable()
	self.enabled = true
	self:Update()
end

function LCM_Screen_Header_Control_Focus:Deactivate()
	self.active = false
	self:Update()
	self:FireCallbacks("FocusDeactivated")
end

function LCM_Screen_Header_Control_Focus:Disable()
	self.enabled = false
	self:Update()
end

function LCM_Screen_Header_Control_Focus:Update()
	local normalColor = self.enabled and ZO_GAMEPAD_UNSELECTED_COLOR or ZO_GAMEPAD_DISABLED_UNSELECTED_COLOR
	local highlightColor = self.enabled and ZO_GAMEPAD_SELECTED_COLOR or ZO_GAMEPAD_DISABLED_SELECTED_COLOR
	self.dropdown:SetNormalColor(normalColor:UnpackRGB())
	self.dropdown:SetHighlightedColor(highlightColor:UnpackRGB())
	self.dropdown:SetSelectedItemTextColor(self.active)
end

function LCM_Screen_Header_Control_Focus:IsActive()
	return self.active
end

function LCM.RefreshScreenHeaderControl(config)
	local scrollList = LCM.scrollList
	if not scrollList or not scrollList.headerControlWidget then
		return
	end

	local widget = scrollList.headerControlWidget
	local dropdown = scrollList.headerControlDropdown
	local titleLabel = scrollList.headerControlTitle
	local controlConfig = config and config.control

	if not controlConfig or controlConfig.type ~= "dropdown" then
		widget:SetHidden(true)
		if dropdown then
			dropdown:Deactivate()
		end
		if scrollList:IsHeaderActive() then
			scrollList:ExitHeader()
		end
		return
	end

	widget:SetHidden(false)

	local title = ResolveAuthorString(controlConfig.name) or ""
	if titleLabel then
		titleLabel:SetText(title)
	end

	if not dropdown then
		return
	end

	LCM.EnsureDropdownLayout(dropdown)
	dropdown._lcmDropdownCenterItems = true
	dropdown:SetSortsItems(false)
	dropdown:SetName(title)

	if scrollList._lcmHeaderOnItemSelected then
		dropdown:UnregisterCallback("OnItemSelected", scrollList._lcmHeaderOnItemSelected)
		scrollList._lcmHeaderOnItemSelected = nil
	end

	local items, labelMap = BuildChoiceItems(controlConfig.choices)
	local getFunc = controlConfig.getFunc
	local setFunc = controlConfig.setFunc
	local suppressCallbacks = true

	local function OnConfirmed(_, name, item)
		if suppressCallbacks then
			return
		end
		if setFunc then
			setFunc(item and item.data or name)
		end
	end

	dropdown:ClearItems()
	for i = 1, #items do
		local item = items[i]
		local entry = dropdown:CreateItemEntry(item.name, OnConfirmed)
		entry.data = item.data
		entry.tooltip = item.tooltip
		dropdown:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
	end

	local current
	if getFunc then
		current = getFunc()
	else
		current = items[1] and items[1].data
	end
	local index = FindItemIndex(items, current) or 1
	if dropdown:GetNumItems() >= index then
		dropdown:SelectItemByIndex(index, ZO_COMBOBOX_SUPPRESS_UPDATE)
	end
	LCM.ApplyClosedSelectedTextLayout(dropdown)
	suppressCallbacks = false

	scrollList._lcmHeaderOnItemSelected = function(_, itemData)
		local text
		if itemData and itemData.tooltip then
			text = ResolveAuthorString(itemData.tooltip)
		elseif controlConfig.tooltip then
			text = ResolveAuthorString(controlConfig.tooltip)
		end
		if text then
			GAMEPAD_TOOLTIPS:LayoutSettingTooltip(GAMEPAD_LEFT_TOOLTIP, text, "")
		else
			GAMEPAD_TOOLTIPS:Reset(GAMEPAD_LEFT_TOOLTIP)
		end
	end
	dropdown:RegisterCallback("OnItemSelected", scrollList._lcmHeaderOnItemSelected)

	dropdown:SetDeactivatedCallback(function()
		GAMEPAD_TOOLTIPS:Reset(GAMEPAD_LEFT_TOOLTIP)
		if scrollList:IsShowing() and scrollList:IsHeaderActive() then
			KEYBIND_STRIP:UpdateKeybindButtonGroup(scrollList.keybindStripDescriptor)
		end
	end)

	if scrollList.headerControlFocus then
		scrollList.headerControlFocus:Update()
	end
end

function LCM.InitializeScreenHeaderWidget(scrollList)
	if not scrollList or scrollList._lcmScreenHeaderInitialized then
		return
	end
	scrollList._lcmScreenHeaderInitialized = true

	local header = scrollList.header
	if not header then
		return
	end

	local widget = header:GetNamedChild("HeaderControl")
	if not widget then
		return
	end

	scrollList.headerControlWidget = widget
	scrollList.headerControlTitle = widget:GetNamedChild("Title")
	local dropdownControl = widget:GetNamedChild("Dropdown")
	if dropdownControl then
		scrollList.headerControlDropdown = ZO_ComboBox_ObjectFromContainer(dropdownControl)
		scrollList.headerControlFocus = LCM_Screen_Header_Control_Focus:New(dropdownControl)
		scrollList:SetupHeaderFocus(scrollList.headerControlFocus)
	end
	widget:SetHidden(true)
end

function LCM.DeactivateScreenHeaderControl()
	local scrollList = LCM.scrollList
	if not scrollList then
		return
	end
	if scrollList.headerControlDropdown then
		scrollList.headerControlDropdown:Deactivate()
	end
	if scrollList:IsHeaderActive() then
		scrollList:ExitHeader()
	end
end
