if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LibConsoleMenu = LibConsoleMenu

local Templates = {
	[LibConsoleMenu.CT_TOGGLE] = "ZO_GamepadOptionsCheckboxRow",
	[LibConsoleMenu.CT_SLIDER] = "LibConsoleMenuGamepadSlider",
	[LibConsoleMenu.CT_EDIT] = "LibConsoleMenuGamepadEdit",
	[LibConsoleMenu.CT_SELECTOR] = "ZO_GamepadHorizontalListRow",
	[LibConsoleMenu.CT_DROPDOWN] = "LibConsoleMenuGamepadDropdown",
	[LibConsoleMenu.CT_CHECKLIST] = "LibConsoleMenuGamepadChecklist",
	[LibConsoleMenu.CT_COLORPICKER] = "ZO_GamepadOptionsColorRow",
	[LibConsoleMenu.CT_ICONPICKER] = "LibConsoleMenuGamepadIconPicker",
	[LibConsoleMenu.CT_BUTTON] = "ZO_GamepadOptionsLabelRow",
	[LibConsoleMenu.CT_SUBMENU] = "ZO_GamepadMenuEntryTemplateWithArrow",
}

-- Native-style inline group label (options center or nav left).
function LibConsoleMenu:AddSettingEntry(setting)
	local list = self.list
	local templateName = LibConsoleMenu.ResolveSettingEntryTemplate(list, setting, Templates[setting.type])
	list:AddEntry(templateName, setting)
end


function LibConsoleMenu.AddonSettings:InitHandlers()
	CALLBACK_MANAGER:RegisterCallback(
		"LibConsoleMenu_AddonSelected",
		function()
			if self.selected then
				self:CleanUp()
				self.selected = false
			end
		end
	)
end

function LibConsoleMenu.AddonSettings:CreateControls()
	local list = LibConsoleMenu.scrollList:GetCurrentList() or LibConsoleMenu.scrollList:GetMainList()
	list:Clear()
	list.lastLcmHeader = nil
	LibConsoleMenu.list = list

	local hasDefaults = false

	local currentSubmenu = list.currentSubmenu
	for i = 1, #self.settings do
		local setting = self.settings[i]
		if setting.currentSubmenu == currentSubmenu then
			setting:CreateControl()
			hasDefaults = hasDefaults or setting.default ~= nil
		end
	end
	self:AssignCenteredSubmenuArrowColumns(currentSubmenu)
	self.hasDefaults = hasDefaults
	list:Commit()
	LibConsoleMenu.needUpdate = false
end

function LibConsoleMenu.AddonSettings:UpdateControls()
	local list = LibConsoleMenu.scrollList:GetCurrentList() or LibConsoleMenu.scrollList:GetMainList()
	local currentSubmenu = list.currentSubmenu
	for i = 1, #self.settings do
		local setting = self.settings[i]
		if setting.currentSubmenu == currentSubmenu then
			setting:UpdateControl()
		end
	end
	list:RefreshVisible()
	LibConsoleMenu.needUpdate = false
end

function LibConsoleMenu.AddonSettings:RefreshSelection()
	local list = LibConsoleMenu.list
	if #self.settings > 0 then
		local selectedIndex =
			list:FindFirstIndexByEval(
			function(data)
				return data == self.lastSelectedRow
			end
		) or list:CalculateFirstSelectableIndex()

		list:EnableAnimation(false)
		list:SetSelectedIndex(selectedIndex)
		list:EnableAnimation(true)
	end
end

local SELECT_FIRST_UPDATE_NAME = "LibConsoleMenu_SelectFirstRow"
local selectFirstToken = 0
local SELECT_FIRST_RETRY_MS = 50

function LibConsoleMenu:CancelDeferredSelectFirstRow()
	selectFirstToken = selectFirstToken + 1
	EVENT_MANAGER:UnregisterForUpdate(SELECT_FIRST_UPDATE_NAME)
end

local function ApplySelectFirstRow()
	local list = LibConsoleMenu.list
	if not list then
		return
	end
	list:EnableAnimation(false)
	list:SetSelectedIndex(list:CalculateFirstSelectableIndex())
	list:EnableAnimation(true)
end

function LibConsoleMenu.AddonSettings:SelectFirstRow()
	-- Immediate snap, then a short deferred re-snap so leftover stick/D-pad
	-- input after a fast A-press cannot leave us on row 2.
	ApplySelectFirstRow()

	selectFirstToken = selectFirstToken + 1
	local token = selectFirstToken
	EVENT_MANAGER:UnregisterForUpdate(SELECT_FIRST_UPDATE_NAME)
	EVENT_MANAGER:RegisterForUpdate(
		SELECT_FIRST_UPDATE_NAME,
		SELECT_FIRST_RETRY_MS,
		function()
			EVENT_MANAGER:UnregisterForUpdate(SELECT_FIRST_UPDATE_NAME)
			if token ~= selectFirstToken then
				return
			end
			local list = LibConsoleMenu.list
			if not list then
				return
			end
			-- Only correct if leftover input moved us; avoid a second select sound.
			local firstIndex = list:CalculateFirstSelectableIndex()
			if list:GetSelectedIndex() == firstIndex then
				return
			end
			ApplySelectFirstRow()
		end
	)
end

function LibConsoleMenu.AddonSettings:SetupSubmenus()
	local settings = self.settings
	local currentSubmenu = nil
	for i = 1, #settings do
		local setting = settings[i]
		local isSubmenu = setting.type == LibConsoleMenu.CT_SUBMENU
		if isSubmenu then
			-- Default: root sibling. nested=true keeps current parent.
			if not setting.nested then
				currentSubmenu = nil
			elseif setting.popSubmenu and currentSubmenu then
				currentSubmenu = currentSubmenu.parentSubmenu
			end
		elseif setting.popSubmenu and currentSubmenu then
			currentSubmenu = currentSubmenu.parentSubmenu
		end
		setting.currentSubmenu = currentSubmenu
		if isSubmenu then
			setting.parentSubmenu = currentSubmenu
			if setting.subMenu ~= false then
				currentSubmenu = setting
			end
		end
	end
end


local MAX_SUBMENU_DEPTH = 8

function LibConsoleMenu.GetSubmenuDepth(submenu)
	local depth = 0
	local node = submenu
	while node do
		depth = depth + 1
		node = node.parentSubmenu
	end
	return depth
end

local function GetSubmenuListName(depth)
	if depth <= 1 then
		return "Submenu"
	end
	return "Submenu" .. depth
end

function LibConsoleMenu:GetSubmenuListAtDepth(depth)
	if depth < 1 then
		return self.scrollList:GetMainList()
	end
	if depth > MAX_SUBMENU_DEPTH then
		depth = MAX_SUBMENU_DEPTH
	end
	return self.scrollList:GetList(GetSubmenuListName(depth))
end

function LibConsoleMenu:RefreshAddonSettings()
	-- Called from out-side, therefore need to check this (again)
	if LibConsoleMenu.needUpdate and LibConsoleMenu.currentSettings ~= nil then
		LibConsoleMenu.currentSettings:UpdateControls()
	end
end

function LibConsoleMenu:SelectFirstAddon()
	LibConsoleMenu.currentSettings = LibConsoleMenu.addons[1]
	if not LibConsoleMenu.currentSettings.selected then
		LibConsoleMenu.currentSettings:Select()
	end
end

-- Root: addon name + version. Nested: submenu title only. Never author/messageText.
function LibConsoleMenu:RefreshSceneHeader()
	local header = self.scrollList and self.scrollList.header
	local addon = self.currentSettings
	if not header or not addon then
		return
	end

	local list = self.scrollList:GetCurrentList() or self.list
	local submenu = list and list.currentSubmenu
	local headerData = {}

	if submenu then
		headerData.titleText = submenu:GetString(submenu:GetValueOrCallback(submenu.labelText))
		headerData.subtitleText = nil
		headerData.messageText = nil
	else
		headerData.titleText = addon.displayName or addon.name
		headerData.subtitleText = addon.version
		headerData.messageText = nil
	end

	ZO_GamepadGenericHeader_RefreshData(header, headerData)
end

function LibConsoleMenu:GoBack()
	local submenu = self.list and self.list.currentSubmenu
	if submenu then
		self:CancelDeferredSelectFirstRow()
		if type(submenu.onExit) == "function" then
			submenu.onExit(submenu)
		end
		local parent = submenu.parentSubmenu
		local targetList
		if parent then
			targetList = self:GetSubmenuListAtDepth(LibConsoleMenu.GetSubmenuDepth(parent))
			targetList.currentSubmenu = parent
		else
			targetList = self.scrollList:GetMainList()
			targetList.currentSubmenu = nil
		end
		-- Switch lists so the parametric screen plays the back transition.
		self.scrollList:SetCurrentList(targetList)
		if LibConsoleMenu.currentSettings then
			-- Reselect the submenu we drilled into (e.g. FPS under Analytics).
			LibConsoleMenu.currentSettings.lastSelectedRow = submenu
			LibConsoleMenu.currentSettings:CreateControls()
			LibConsoleMenu.currentSettings:RefreshSelection()
		end
		self:RefreshSceneHeader()
		PlaySound(SOUNDS.GAMEPAD_MENU_BACK)
	else
		SCENE_MANAGER:HideCurrentScene()
	end
end

-----
-- Settings_ParametricList class
-----


local Settings_ParametricList = ZO_Gamepad_ParametricList_Screen:Subclass()

function Settings_ParametricList:New(control)
	return ZO_Gamepad_ParametricList_Screen.New(self, control)
end

function Settings_ParametricList:Initialize(control)
	ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, LibConsoleMenu.scene)
	-- L2/R2 jump between rows that have a header (same as native GAMEPAD_OPTIONS).
	self:SetListsUseTriggerKeybinds(true)
end

function Settings_ParametricList:PerformUpdate()
end

function Settings_ParametricList:InitializeKeybindStripDescriptors()
	local CONTROL_TYPES_WITH_PRIMARY_ACTION = {
		[LibConsoleMenu.CT_TOGGLE] = true,
		[LibConsoleMenu.CT_BUTTON] = true,
		[LibConsoleMenu.CT_COLORPICKER] = true,
		[LibConsoleMenu.CT_EDIT] = true,
		[LibConsoleMenu.CT_SUBMENU] = true,
		[LibConsoleMenu.CT_DROPDOWN] = true,
		[LibConsoleMenu.CT_CHECKLIST] = true,
	}
	local CONTROL_TYPES_WITH_INPUT = {
		[LibConsoleMenu.CT_SLIDER] = true,
		[LibConsoleMenu.CT_SELECTOR] = true,
		[LibConsoleMenu.CT_ICONPICKER] = true,
	}
	local lastActiveInput
	self.keybindStripDescriptor = {
		{
			alignment = KEYBIND_STRIP_ALIGN_LEFT,
			name = function()
				local data = LibConsoleMenu.list:GetSelectedData()
				if data and data.type == LibConsoleMenu.CT_TOGGLE then
					return GetString(SI_GAMEPAD_TOGGLE_OPTION)
				elseif data and data.type == LibConsoleMenu.CT_BUTTON then
					return data:GetString(data:GetValueOrCallback(data.buttonText) or GetString(SI_GAMEPAD_SELECT_OPTION))
				else
					return GetString(SI_GAMEPAD_SELECT_OPTION)
				end
			end,
			keybind = "UI_SHORTCUT_PRIMARY",
			gamepadOrder = 1, -- PRIMARY already maps to 1, but just to be explicit. 
			callback = function()
				local control = LibConsoleMenu.list:GetSelectedControl()
				local data = LibConsoleMenu.list:GetSelectedData()
				if not data then
					return
				end
				local controlType = data.type
				if data:IsDisabled() then
					return
				end
				if controlType == LibConsoleMenu.CT_TOGGLE then
					ZO_CheckButton_OnClicked(control:GetNamedChild("Checkbox"))
				elseif controlType == LibConsoleMenu.CT_BUTTON then
					PlaySound(SOUNDS.DEFAULT_CLICK)
					LibConsoleMenu.list:GetSelectedData():ValueChanged(control)
				elseif controlType == LibConsoleMenu.CT_COLORPICKER then
					control:ShowDialog()
				elseif controlType == LibConsoleMenu.CT_EDIT or controlType == LibConsoleMenu.CT_SUBMENU or controlType == LibConsoleMenu.CT_DROPDOWN or controlType == LibConsoleMenu.CT_CHECKLIST then
					control:Activate()
				end
			end,
			enabled = function()
				local data = LibConsoleMenu.list:GetSelectedData()
				return data and not data:IsDisabled()
			end,
			visible = function()
				local data = LibConsoleMenu.list:GetSelectedData()
				local control = LibConsoleMenu.list:GetSelectedControl()
				if lastActiveInput then
					if control == nil or lastActiveInput ~= control then
						lastActiveInput:Deactivate()
						lastActiveInput = nil
					end
				end
				local showingInfoPanel = false
				if data then
					if type(data.tooltipText) == "function" then
						showingInfoPanel = true -- Not supported
					elseif type(data.tooltipText) == "string" and #data.tooltipText > 0 then
						showingInfoPanel = true
					elseif type(data.tooltipText) == "number" and data.tooltipText > 0 then
						showingInfoPanel = true
					end
					if CONTROL_TYPES_WITH_INPUT[data.type] and not data:IsDisabled() then
						lastActiveInput = control
						lastActiveInput:Activate()
					end
				end
				if showingInfoPanel then
					local text
					if type(data.tooltipText) == "function" then
						text = data:tooltipText()
					elseif type(data.tooltipText) == "string" then
						text = data.tooltipText
					elseif type(data.tooltipText) == "number" then
						text = GetString(data.tooltipText)
					end
					GAMEPAD_TOOLTIPS:LayoutSettingTooltip(GAMEPAD_LEFT_TOOLTIP, text, "")
				else
					GAMEPAD_TOOLTIPS:Reset(GAMEPAD_LEFT_TOOLTIP)
				end

				return data and CONTROL_TYPES_WITH_PRIMARY_ACTION[data.type]
			end
		},
		{
			alignment = KEYBIND_STRIP_ALIGN_RIGHT,
			name = GetString(SI_LCM_SLIDER_LARGE_DECREASE),
			keybind = "UI_SHORTCUT_LEFT_SHOULDER",
			gamepadOrder = 2,
			callback = function()
				LibConsoleMenu.NudgeFocusedSlider(-1)
			end,
			visible = function()
				local data = LibConsoleMenu.list:GetSelectedData()
				return data and data.type == LibConsoleMenu.CT_SLIDER and not data:IsDisabled()
			end,
		},
		{
			alignment = KEYBIND_STRIP_ALIGN_RIGHT,
			name = GetString(SI_LCM_SLIDER_LARGE_INCREASE),
			keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
			gamepadOrder = 1,
			callback = function()
				LibConsoleMenu.NudgeFocusedSlider(1)
			end,
			visible = function()
				local data = LibConsoleMenu.list:GetSelectedData()
				return data and data.type == LibConsoleMenu.CT_SLIDER and not data:IsDisabled()
			end,
		},
	}
	LibConsoleMenu.AppendDefaultsKeybinds(self.keybindStripDescriptor)
	local function OnBack()
		LibConsoleMenu:GoBack()
	end
	ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, OnBack)
	LibConsoleMenu.scene:RegisterCallback(
		"StateChange",
		function(oldState, newState)
			-- Stock House Tours: deactivate open ComboBoxes when the screen hides.
			if newState == SCENE_HIDING then
				if lastActiveInput then
					lastActiveInput:Deactivate()
					lastActiveInput = nil
				end
				local selectedControl = LibConsoleMenu.list and LibConsoleMenu.list:GetSelectedControl()
				if selectedControl and selectedControl.Deactivate then
					selectedControl:Deactivate()
				end
			end
		end
	)
end

function Settings_ParametricList:SetupList(list)
end

-----

local function OptionsWindowFragmentStateChangeRefresh(oldState, newState)
	if newState == SCENE_FRAGMENT_HIDING then
		LibConsoleMenu.needUpdate = true
		if LibConsoleMenu.currentSettings then
			LibConsoleMenu.currentSettings.lastSelectedRow = LibConsoleMenu.list:GetSelectedData()
		end
		-- Leave any open submenu so onExit previews clear when settings close.
		local submenu = LibConsoleMenu.list and LibConsoleMenu.list.currentSubmenu
		if submenu and type(submenu.onExit) == "function" then
			submenu.onExit(submenu)
		end
		-- Also close ComboBox popups if scene hide was skipped (e.g. fragment-only hide).
		local selectedControl = LibConsoleMenu.list and LibConsoleMenu.list:GetSelectedControl()
		if selectedControl and selectedControl.Deactivate then
			selectedControl:Deactivate()
		end
	elseif newState == SCENE_FRAGMENT_SHOWING then
		if LibConsoleMenu.needUpdate and LibConsoleMenu.currentSettings ~= nil then
			LibConsoleMenu:RefreshAddonSettings()
		elseif LibConsoleMenu.currentSettings == nil and #LibConsoleMenu.addons == 1 then
			LibConsoleMenu:SelectFirstAddon()
		end
		if LibConsoleMenu.currentSettings then
			if LibConsoleMenu.list.currentSubmenu then
				LibConsoleMenu.list.currentSubmenu = nil
				LibConsoleMenu.scrollList:SetCurrentList(LibConsoleMenu.scrollList:GetMainList())
				LibConsoleMenu.currentSettings:CreateControls()
			else
				LibConsoleMenu.currentSettings:RefreshSelection()
			end
			LibConsoleMenu:RefreshSceneHeader()
		end
	end
end



function LibConsoleMenu:CreateAddonSettingsPanel()
	local insertPosition = 0
	for i = 1, #ZO_MENU_ENTRIES do
		if ZO_MENU_ENTRIES[i].id == ZO_MENU_MAIN_ENTRIES.ACTIVITY_FINDER then
			insertPosition = i
			break
		end
	end
	if insertPosition == 0 then
		return
	end

	local control = WINDOW_MANAGER:CreateControlFromVirtual("LibConsoleMenuList", GuiRoot, "LibConsoleMenuGamepadTopLevel")

	local fragment = ZO_FadeSceneFragment:New(control)

	self.container = control:GetNamedChild("MaskContainer")

	local scene = ZO_Scene:New("LibConsoleMenuScene", SCENE_MANAGER)
	scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
	scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD_OPTIONS)
	scene:AddFragment(FRAME_EMOTE_FRAGMENT_SYSTEM)
	scene:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
	scene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
	scene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
	scene:AddFragment(fragment)
	self.scene = scene

	self.scrollList = Settings_ParametricList:New(control)
	self.list = self.scrollList:GetMainList()
	local headerPadding = GAMEPAD_HEADER_DEFAULT_PADDING or 80
	local headerSelectedPadding = GAMEPAD_HEADER_SELECTED_PADDING or -40
	if GAMEPAD_OPTIONS_HEADER_SELECTED_PADDING ~= nil then
		headerSelectedPadding = GAMEPAD_OPTIONS_HEADER_SELECTED_PADDING
	end
	self.list:SetHeaderPadding(headerPadding, headerSelectedPadding)
	for depth = 1, MAX_SUBMENU_DEPTH do
		local submenuList = self.scrollList:AddList(GetSubmenuListName(depth))
		submenuList = submenuList or self.scrollList:GetList(GetSubmenuListName(depth))
		if submenuList and submenuList.SetHeaderPadding then
			submenuList:SetHeaderPadding(headerPadding, headerSelectedPadding)
		end
	end

	CALLBACK_MANAGER:RegisterCallback(
		"LibConsoleMenu_AddonSelected",
		function(_, addonSettings)
			LibConsoleMenu.currentSettings = addonSettings
			self:CancelDeferredSelectFirstRow()
			self.list.currentSubmenu = nil
			addonSettings:SetupSubmenus()
			self.scrollList:SetCurrentList(self.scrollList:GetMainList())
			addonSettings:CreateControls()
		end
	)

	self:InjectIntoAddonsMenu()
end

function LibConsoleMenu:CreateControlPools()
	local function extendFactory(list, templateName, func)
		local pool = list.dataTypes[templateName].pool
		local orgFactory = pool.m_Factory
		pool.m_Factory = function(...)
			local control = orgFactory(...)
			func(control)
			return control
		end
	end
	local function update(control, data, selected, reselectingDuringRebuild, enabled, active)
		data.control = control
		control.data = data
		-- List `enabled` is not the setting disable flag — derive that ourselves.
		local settingEnabled = not data:IsDisabled()
		-- Update content first (e.g. SetColor), then apply enabled/selected visuals.
		LibConsoleMenu.updateControlFunctions[data.type](data, control, selected, settingEnabled)
		data:SetEnabled(settingEnabled, selected)

		local list = self.list
		if control:GetParent() ~= list.scrollControl then
			control:SetParent(list.scrollControl)
		end

		-- Header controls are created on the Main list scroll parent. Nested Submenu
		-- lists reparent the row — move the header with it or it stays invisible on Main.
		local headerControl = control.headerControl
		if headerControl then
			if headerControl:GetParent() ~= list.scrollControl then
				headerControl:SetParent(list.scrollControl)
			end
			local showHeader = data.header ~= nil and data.header ~= ""
			headerControl:SetHidden(not showHeader)
			if showHeader then
				LibConsoleMenu.LayoutHeaderControl(headerControl, control, LibConsoleMenu.NormalizeHeaderAlign(data.headerAlign))
				LibConsoleMenu.HeaderSetup(headerControl, data)
			end
		end
	end
	local function reset(control)
		local data = control.data
		if data then
			LibConsoleMenu.cleanControlFunctions[data.type](data, control)
			data.control = nil
			control.data = nil
		end
	end
	local function AddPool(type, suffix, factory)
		local list = self.scrollList:GetMainList()
		local templateName = Templates[type]
		local withHeaderName = templateName .. LibConsoleMenu.WITH_HEADER_SUFFIX
		local withNavHeaderName = templateName .. LibConsoleMenu.WITH_NAV_HEADER_SUFFIX
		list:AddDataTemplate(templateName, update, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, suffix, reset)
		-- Args: template, setup, parametric, equality, headerTemplate, headerSetup, poolPrefix, poolReset
		list:AddDataTemplateWithHeader(
			templateName,
			update,
			ZO_GamepadMenuEntryTemplateParametricListFunction,
			nil,
			LibConsoleMenu.HEADER_TEMPLATE_OPTIONS,
			LibConsoleMenu.HeaderSetup,
			suffix,
			reset
		)
		LibConsoleMenu.RegisterWithNavHeader(list, templateName, suffix, update, reset)
		if factory then
			extendFactory(list, templateName, factory)
			local basePool = list.dataTypes[templateName] and list.dataTypes[templateName].pool
			local headerDataType = list.dataTypes[withHeaderName]
			if headerDataType and headerDataType.pool and headerDataType.pool ~= basePool then
				extendFactory(list, withHeaderName, factory)
			end
			local navHeaderDataType = list.dataTypes[withNavHeaderName]
			if navHeaderDataType and navHeaderDataType.pool and navHeaderDataType.pool ~= basePool then
				extendFactory(list, withNavHeaderName, factory)
			end
		end
		-- Share templates with every nest-depth list (same pool/factories as Main).
		for depth = 1, MAX_SUBMENU_DEPTH do
			local submenuList = self.scrollList:GetList(GetSubmenuListName(depth))
			submenuList.dataTypes[templateName] = list.dataTypes[templateName]
			if list.dataTypes[withHeaderName] then
				submenuList.dataTypes[withHeaderName] = list.dataTypes[withHeaderName]
			end
			if list.dataTypes[withNavHeaderName] then
				submenuList.dataTypes[withNavHeaderName] = list.dataTypes[withNavHeaderName]
			end
		end
	end
	AddPool(
		self.CT_TOGGLE,
		"Toggle",
		LibConsoleMenu.CreateTogglePoolFactory()
	)
	AddPool(
		self.CT_SLIDER,
		"Slider",
		LibConsoleMenu.CreateSliderPoolFactory()
	)
	AddPool(
		self.CT_EDIT,
		"Edit",
		LibConsoleMenu.CreateEditPoolFactory()
	)
	AddPool(
		self.CT_SELECTOR,
		"Selector",
		LibConsoleMenu.CreateSelectorPoolFactory()
	)
	AddPool(
		self.CT_DROPDOWN,
		"DropDown",
		LibConsoleMenu.CreateDropdownPoolFactory()
	)
	AddPool(
		self.CT_CHECKLIST,
		"Checklist",
		LibConsoleMenu.CreateChecklistPoolFactory()
	)
	AddPool(
		self.CT_COLORPICKER,
		"ColorPicker",
		LibConsoleMenu.CreateColorPickerPoolFactory()
	)
	AddPool(
		self.CT_ICONPICKER,
		"IconPicker",
		LibConsoleMenu.CreateIconPickerPoolFactory()
	)
	AddPool(self.CT_BUTTON, "Button")
	AddPool(
		self.CT_SUBMENU,
		"SubmenuLabel",
		LibConsoleMenu.CreateSubmenuPoolFactory()
	)

	self.list:SetNoItemText(GetString(SI_GAMEPAD_MARKET_LOCKED_TITLE))
end

function LibConsoleMenu:CreateAddonList()
	self.scene:RegisterCallback("StateChange", OptionsWindowFragmentStateChangeRefresh)
end

local function OptionsWindowFragmentStateChange(oldState, newState)
	if newState ~= SCENE_SHOWING then
		return
	end

	MAIN_MENU_GAMEPAD_SCENE:UnregisterCallback("StateChange", OptionsWindowFragmentStateChange)

	LibConsoleMenu:Initialize()
end

MAIN_MENU_GAMEPAD_SCENE:RegisterCallback("StateChange", OptionsWindowFragmentStateChange)
