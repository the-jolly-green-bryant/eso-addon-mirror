-- Screen header band: merge author header into headerData; header control widget (dropdown).

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

LCM.HEADER_PASSTHROUGH_KEYS = {
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

function LCM.GetActiveHeaderConfig()
	local scrollList = LCM.scrollList
	if not scrollList then
		return nil
	end
	local list = scrollList:GetCurrentList() or LCM.list
	local submenu = list and list.currentSubmenu
	if submenu and submenu.headerConfig then
		return submenu.headerConfig
	end
	local addon = LCM.currentMenu
	if addon and addon.headerConfig then
		return addon.headerConfig
	end
	return nil
end

function LCM.MergeHeaderData(headerData, config)
	if not config then
		return headerData
	end
	for i = 1, #LCM.HEADER_PASSTHROUGH_KEYS do
		local key = LCM.HEADER_PASSTHROUGH_KEYS[i]
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

local HEADER_CONTROL_OFFSET_Y = 25

local function HeaderDataHasField(headerData, key)
	if not headerData or headerData[key] == nil then
		return false
	end
	local value = headerData[key]
	if type(value) == "function" then
		value = value()
	elseif type(value) == "number" then
		value = GetString(value)
	end
	return value ~= nil and value ~= ""
end

local function HeaderDataHasMessage(headerData)
	return HeaderDataHasField(headerData, "messageText")
end

-- Stock Message band anchors (DATA_PAIRS_SEPARATE). Restored when Message is hidden so a
-- Home Tours / outfit style Message+25 widget anchor does not keep Demo-inflated offsets.
-- Clear text too: ProcessData hides Message without clearing it, so BOTTOM anchors stay too low.
local function ResetMessageBandLayout(header)
	local message = header:GetNamedChild("Message")
	local divider = header:GetNamedChild("DividerSimple")
	if message and divider then
		message:SetText("")
		message:ClearAnchors()
		message:SetAnchor(TOPLEFT, divider, BOTTOMLEFT, 0, ZO_GAMEPAD_CONTENT_DIVIDER_INFO_PADDING_Y)
		message:SetAnchor(TOPRIGHT, divider, BOTTOMRIGHT, 0, ZO_GAMEPAD_CONTENT_HEADER_DIVIDER_INFO_BOTTOM_PADDING_Y)
	end
end

function LCM.PrepareMessageBandForRefresh(header, headerData)
	if header and not HeaderDataHasMessage(headerData) then
		ResetMessageBandLayout(header)
	end
end

-- Last visible header band: message, else highest data row, else collapsed Message slot.
local function GetHeaderControlAnchorTarget(header, headerData)
	local message = header:GetNamedChild("Message")
	if HeaderDataHasMessage(headerData) then
		return message
	end
	for i = 4, 1, -1 do
		local hasRow = HeaderDataHasField(headerData, "data" .. i .. "HeaderText")
			or HeaderDataHasField(headerData, "data" .. i .. "Text")
		if hasRow then
			local valueControl = header:GetNamedChild("Data" .. i)
			if valueControl and not valueControl:IsHidden() then
				return valueControl
			end
			local headerControl = header:GetNamedChild("Data" .. i .. "Header")
			if headerControl and not headerControl:IsHidden() then
				return headerControl
			end
		end
	end
	return message
end

function LCM.ApplyHeaderControlLayout(header, headerData)
	if not header then
		return
	end
	if not HeaderDataHasMessage(headerData) then
		ResetMessageBandLayout(header)
	end
	if not header.headerFocusControl then
		return
	end
	local anchorTo = GetHeaderControlAnchorTarget(header, headerData)
	if anchorTo then
		local widget = header.headerFocusControl
		widget:ClearAnchors()
		widget:SetAnchor(TOP, anchorTo, BOTTOM, 0, HEADER_CONTROL_OFFSET_Y)
	end
end

local HEADER_VALUE_FONT = "ZoFontGamepad34"

local function ApplyHeaderDropdownClosedLayout(dropdown)
	local label = dropdown.m_selectedItemText
	local container = dropdown.m_container
	if not label or not container then
		return
	end
	local arrow = container:GetNamedChild("OpenDropdown")
	label:SetFont(HEADER_VALUE_FONT)
	label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	label:ClearAnchors()
	label:SetAnchor(CENTER, container, CENTER, 0, 0)
	if arrow then
		arrow:ClearAnchors()
		arrow:SetAnchor(LEFT, label, RIGHT, 10, 4)
	end
end

function LCM.OnHeaderDropdownSelectionConfirmed()
	local scrollList = LCM.scrollList
	local menu = LCM.currentMenu
	if scrollList then
		if scrollList:IsHeaderActive() then
			scrollList:RequestLeaveHeader()
		else
			-- setFunc may rebuild via ExitHeader (no list re-activation); ensure list focus.
			local REQUESTED_BY_HEADER = true
			scrollList:ActivateCurrentList(REQUESTED_BY_HEADER)
			scrollList:RefreshKeybinds()
		end
	end
	if menu then
		menu:SelectFirstRow()
	end
	LCM.RefreshSelectedListRow()
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

function LCM.UpdateHeaderFocusControlRegistration(config)
	local scrollList = LCM.scrollList
	if not scrollList or not scrollList.headerControlWidget then
		return
	end

	local header = scrollList.header
	local widget = scrollList.headerControlWidget
	local controlConfig = config and config.control
	local hasControl = controlConfig and controlConfig.type == "dropdown"

	if hasControl then
		widget:SetHidden(false)
		if header then
			ZO_GamepadGenericHeader_SetHeaderFocusControl(header, widget, scrollList.headerControlFocus)
		end
	else
		widget:SetHidden(true)
		if header then
			ZO_GamepadGenericHeader_SetHeaderFocusControl(header, nil, nil)
		end
		if scrollList.headerControlDropdown then
			scrollList.headerControlDropdown:Deactivate()
		end
		if scrollList:IsHeaderActive() then
			scrollList:ExitHeader()
		end
	end
end

function LCM.RefreshHeaderControl(config)
	local scrollList = LCM.scrollList
	if not scrollList or not scrollList.headerControlWidget then
		return
	end

	local dropdown = scrollList.headerControlDropdown
	local titleLabel = scrollList.headerControlTitle
	local controlConfig = config and config.control

	if not controlConfig or controlConfig.type ~= "dropdown" then
		return
	end

	if not dropdown then
		return
	end

	if dropdown:IsDropdownVisible() then
		dropdown:Deactivate()
	end

	local title = ResolveAuthorString(controlConfig.name) or ""
	if titleLabel then
		titleLabel:SetText(title)
	end

	LCM.EnsureDropdownLayout(dropdown)
	dropdown._lcmDropdownCenterItems = true
	dropdown._lcmHeaderDropdownOutfitLayout = true
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

	local function OnConfirmed(_, name, item, selectionChanged)
		if suppressCallbacks then
			return
		end
		if setFunc then
			setFunc(item and item.data or name)
		end
		if selectionChanged then
			LCM.OnHeaderDropdownSelectionConfirmed()
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
	ApplyHeaderDropdownClosedLayout(dropdown)
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

function LCM.InitializeHeaderWidget(scrollList)
	if not scrollList or scrollList._lcmHeaderInitialized then
		return
	end
	scrollList._lcmHeaderInitialized = true

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

function LCM.DeactivateHeaderControl()
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
