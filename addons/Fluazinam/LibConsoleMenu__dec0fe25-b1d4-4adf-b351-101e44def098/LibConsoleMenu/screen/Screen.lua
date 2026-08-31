if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LibConsoleMenu = LibConsoleMenu

local Templates = {
	[LibConsoleMenu.CT_TOGGLE] = "ZO_GamepadOptionsCheckboxRow",
	[LibConsoleMenu.CT_SLIDER] = "LibConsoleMenuGamepadSlider",
	[LibConsoleMenu.CT_EDITBOX] = {
		default = "LibConsoleMenuGamepadEditBox",
		multiLine = "LibConsoleMenuGamepadEditBoxMultiline",
	},
	[LibConsoleMenu.CT_SELECTOR] = "ZO_GamepadHorizontalListRow",
	[LibConsoleMenu.CT_DROPDOWN] = "LibConsoleMenuGamepadDropdown",
	[LibConsoleMenu.CT_CHECKLIST] = "LibConsoleMenuGamepadChecklist",
	[LibConsoleMenu.CT_COLORPICKER] = "ZO_GamepadOptionsColorRow",
	[LibConsoleMenu.CT_ICONPICKER] = "LibConsoleMenuGamepadIconPicker",
	[LibConsoleMenu.CT_BUTTON] = "ZO_GamepadOptionsLabelRow",
	[LibConsoleMenu.CT_SUBMENU] = "ZO_GamepadMenuEntryTemplateWithArrow",
}

local function ResolveTemplate(setting)
	local entry = Templates[setting.type]
	if type(entry) == "table" then
		if setting.multiLine and entry.multiLine then
			return entry.multiLine
		end
		return entry.default
	end
	return entry
end

-- Native-style inline group label (options center or nav left).
function LibConsoleMenu:AddControlEntry(setting)
	local list = self.list
	local templateName = LibConsoleMenu.ResolveSettingEntryTemplate(list, setting, ResolveTemplate(setting))
	list:AddEntry(templateName, setting)
end


function LibConsoleMenu.AddonMenu:InitHandlers()
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

function LibConsoleMenu.AddonMenu:CreateControls()
	local list = LibConsoleMenu.scrollList:GetCurrentList() or LibConsoleMenu.scrollList:GetMainList()
	list:Clear()
	list.lastLcmSection = nil
	LibConsoleMenu.list = list

	local hasDefaults = false

	local currentSubmenu = list.currentSubmenu
	for i = 1, #self.controls do
		local setting = self.controls[i]
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

function LibConsoleMenu.AddonMenu:UpdateControls()
	local list = LibConsoleMenu.scrollList:GetCurrentList() or LibConsoleMenu.scrollList:GetMainList()
	local currentSubmenu = list.currentSubmenu
	for i = 1, #self.controls do
		local setting = self.controls[i]
		if setting.currentSubmenu == currentSubmenu then
			setting:UpdateControl()
		end
	end
	list:RefreshVisible()
	LibConsoleMenu.needUpdate = false
end

function LibConsoleMenu.AddonMenu:RefreshSelection()
	local list = LibConsoleMenu.list
	if #self.controls > 0 then
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

function LibConsoleMenu.AddonMenu:SelectFirstRow()
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

function LibConsoleMenu.AddonMenu:SetupSubmenus()
	local controls = self.controls
	local currentSubmenu = nil
	for i = 1, #controls do
		local setting = controls[i]
		local isSubmenu = setting.type == LibConsoleMenu.CT_SUBMENU
		-- After a submenu and its descendants, resume under that submenu's parent.
		if setting.popAfterSubmenu then
			currentSubmenu = setting.popAfterSubmenu.parentSubmenu
		elseif isSubmenu then
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

function LibConsoleMenu:RefreshCurrentMenu()
	-- Called from out-side, therefore need to check this (again)
	if LibConsoleMenu.needUpdate and LibConsoleMenu.currentMenu ~= nil then
		LibConsoleMenu.currentMenu:UpdateControls()
	end
end

function LibConsoleMenu:SelectFirstAddon()
	LibConsoleMenu.currentMenu = LibConsoleMenu.menus[1]
	if not LibConsoleMenu.currentMenu.selected then
		LibConsoleMenu.currentMenu:Select()
	end
end

-- Root: addon name + version. Nested: submenu title only. Author header merges on top.
function LibConsoleMenu:RefreshSceneHeader()
	local header = self.scrollList and self.scrollList.header
	local addon = self.currentMenu
	if not header or not addon then
		return
	end

	local list = self.scrollList:GetCurrentList() or self.list
	local submenu = list and list.currentSubmenu
	local headerData = {}

	if submenu then
		headerData.titleText = submenu:GetString(submenu:GetValueOrCallback(submenu.labelText))
		headerData.subtitleText = nil
	else
		headerData.titleText = addon.displayTitle or addon.title
		headerData.subtitleText = addon.version
	end

	local config = LibConsoleMenu.GetActiveHeaderConfig()
	LibConsoleMenu.MergeHeaderData(headerData, config)

	LibConsoleMenu.UpdateHeaderFocusControlRegistration(config)
	LibConsoleMenu.PrepareMessageBandForRefresh(header, headerData)
	ZO_GamepadGenericHeader_RefreshData(header, headerData)
	LibConsoleMenu.ApplyHeaderControlLayout(header, headerData)
	LibConsoleMenu.RefreshHeaderControl(config)
end

function LibConsoleMenu.RefreshSelectedListRow()
	local list = LibConsoleMenu.list
	if not list then
		return
	end
	local selectedControl = list:GetSelectedControl()
	local selectedData = list:GetSelectedData()
	if selectedControl then
		selectedControl:SetAlpha(ZO_GamepadMenuEntryTemplate_GetAlpha(true))
	end
	if selectedData and selectedData.control then
		selectedData:SetEnabled(not selectedData:IsDisabled(), true)
	end
	list:RefreshVisible()
end

function LibConsoleMenu:GoBack()
	local submenu = self.list and self.list.currentSubmenu
	if submenu then
		self:CancelDeferredSelectFirstRow()
		local scrollList = self.scrollList
		if scrollList and scrollList:IsHeaderActive() then
			scrollList:ExitHeader()
		end
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
		if LibConsoleMenu.currentMenu then
			-- Reselect the submenu we drilled into (e.g. FPS under Analytics).
			LibConsoleMenu.currentMenu.lastSelectedRow = submenu
			LibConsoleMenu.currentMenu:CreateControls()
			LibConsoleMenu.currentMenu:RefreshSelection()
		end
		self:RefreshSceneHeader()
		if scrollList then
			scrollList:ActivateCurrentList()
			scrollList:RefreshKeybinds()
		end
		LibConsoleMenu.RefreshSelectedListRow()
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

function Settings_ParametricList:OnDeferredInitialize()
	LibConsoleMenu.InitializeHeaderWidget(self)
end

function Settings_ParametricList:CanEnterHeader()
	local widget = self.headerControlWidget
	return widget and not widget:IsHidden()
end

function Settings_ParametricList:OnEnterHeader()
	local config = LibConsoleMenu.GetActiveHeaderConfig()
	local controlConfig = config and config.control
	if controlConfig and controlConfig.tooltip then
		local tooltip = controlConfig.tooltip
		local text
		if type(tooltip) == "function" then
			text = tooltip()
		elseif type(tooltip) == "number" then
			text = GetString(tooltip)
		else
			text = tooltip
		end
		if type(text) == "string" and #text > 0 then
			GAMEPAD_TOOLTIPS:LayoutSettingTooltip(GAMEPAD_LEFT_TOOLTIP, text, "")
		end
	end
	KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
end

function Settings_ParametricList:OnLeaveHeader()
	GAMEPAD_TOOLTIPS:Reset(GAMEPAD_LEFT_TOOLTIP)
	if self.headerControlDropdown then
		self.headerControlDropdown:Deactivate()
	end
	KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
end

function Settings_ParametricList:RequestLeaveHeader()
	if not self.headerFocus or not self.headerFocus:IsActive() then
		return
	end

	if self:CanLeaveHeader() then
		self.headerFocus:Deactivate()
		self:OnLeaveHeader()
		local REQUESTED_BY_HEADER = true
		self:ActivateCurrentList(REQUESTED_BY_HEADER)
		self:RefreshKeybinds()
		LibConsoleMenu.RefreshSelectedListRow()
	end
end

function Settings_ParametricList:InitializeKeybindStripDescriptors()
	local CONTROL_TYPES_WITH_PRIMARY_ACTION = {
		[LibConsoleMenu.CT_TOGGLE] = true,
		[LibConsoleMenu.CT_BUTTON] = true,
		[LibConsoleMenu.CT_COLORPICKER] = true,
		[LibConsoleMenu.CT_EDITBOX] = true,
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
				if self:IsHeaderActive() then
					if self.headerControlDropdown then
						self.headerControlDropdown:Activate()
					end
					return
				end
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
				elseif controlType == LibConsoleMenu.CT_EDITBOX or controlType == LibConsoleMenu.CT_SUBMENU or controlType == LibConsoleMenu.CT_DROPDOWN or controlType == LibConsoleMenu.CT_CHECKLIST then
					control:Activate()
				end
			end,
			enabled = function()
				if self:IsHeaderActive() then
					return true
				end
				local data = LibConsoleMenu.list:GetSelectedData()
				return data and not data:IsDisabled()
			end,
			visible = function()
				if self:IsHeaderActive() then
					if lastActiveInput then
						lastActiveInput:Deactivate()
						lastActiveInput = nil
					end
					GAMEPAD_TOOLTIPS:Reset(GAMEPAD_LEFT_TOOLTIP)
					return true
				end
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
				LibConsoleMenu.DeactivateHeaderControl()
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
		if LibConsoleMenu.currentMenu then
			LibConsoleMenu.currentMenu.lastSelectedRow = LibConsoleMenu.list:GetSelectedData()
		end
		-- Leave any open submenu so onExit previews clear when settings close.
		local submenu = LibConsoleMenu.list and LibConsoleMenu.list.currentSubmenu
		if submenu and type(submenu.onExit) == "function" then
			submenu.onExit(submenu)
		end
		-- Also close ComboBox popups if scene hide was skipped (e.g. fragment-only hide).
		LibConsoleMenu.DeactivateHeaderControl()
		local selectedControl = LibConsoleMenu.list and LibConsoleMenu.list:GetSelectedControl()
		if selectedControl and selectedControl.Deactivate then
			selectedControl:Deactivate()
		end
	elseif newState == SCENE_FRAGMENT_SHOWING then
		if LibConsoleMenu.needUpdate and LibConsoleMenu.currentMenu ~= nil then
			LibConsoleMenu:RefreshCurrentMenu()
		elseif LibConsoleMenu.currentMenu == nil and #LibConsoleMenu.menus == 1 then
			LibConsoleMenu:SelectFirstAddon()
		end
		if LibConsoleMenu.currentMenu then
			if LibConsoleMenu.list.currentSubmenu then
				LibConsoleMenu.list.currentSubmenu = nil
				LibConsoleMenu.scrollList:SetCurrentList(LibConsoleMenu.scrollList:GetMainList())
				LibConsoleMenu.currentMenu:CreateControls()
			else
				LibConsoleMenu.currentMenu:RefreshSelection()
			end
			LibConsoleMenu:RefreshSceneHeader()
		end
	end
end



function LibConsoleMenu:CreateSharedMenuScene()
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
	LibConsoleMenu.InitializeHeaderWidget(self.scrollList)
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
		function(_, AddonMenu)
			LibConsoleMenu.currentMenu = AddonMenu
			self:CancelDeferredSelectFirstRow()
			self.list.currentSubmenu = nil
			AddonMenu:SetupSubmenus()
			self.scrollList:SetCurrentList(self.scrollList:GetMainList())
			AddonMenu:CreateControls()
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
				LibConsoleMenu.LayoutSectionLabel(
					headerControl,
					control,
					data.sectionAlign,
					data.sectionIndentPx or 0
				)
				LibConsoleMenu.SectionSetup(headerControl, data)
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

	local function RegisterTemplateVariants(list, templateName, poolSuffix)
		-- Args: template, setup, parametric, equality, headerTemplate, headerSetup, poolPrefix, poolReset
		list:AddDataTemplate(templateName, update, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, poolSuffix, reset)
		list:AddDataTemplateWithHeader(
			templateName,
			update,
			ZO_GamepadMenuEntryTemplateParametricListFunction,
			nil,
			LibConsoleMenu.SECTION_TEMPLATE_OPTIONS,
			LibConsoleMenu.SectionSetup,
			poolSuffix,
			reset
		)
		LibConsoleMenu.RegisterWithNavSection(list, templateName, poolSuffix, update, reset)
	end

	local function ExtendTemplateFactories(list, names, factory)
		local baseName = names[1]
		extendFactory(list, baseName, factory)
		local basePool = list.dataTypes[baseName] and list.dataTypes[baseName].pool
		for i = 2, #names do
			local name = names[i]
			local dataType = list.dataTypes[name]
			if dataType and dataType.pool and dataType.pool ~= basePool then
				extendFactory(list, name, factory)
			end
		end
	end

	local function ShareTemplatesWithSubmenus(list, names)
		for depth = 1, MAX_SUBMENU_DEPTH do
			local submenuList = self.scrollList:GetList(GetSubmenuListName(depth))
			for _, name in ipairs(names) do
				if list.dataTypes[name] then
					submenuList.dataTypes[name] = list.dataTypes[name]
				end
			end
		end
	end

	local function RegisterTemplatePool(templateName, poolSuffix, factory)
		local list = self.scrollList:GetMainList()
		local names = {
			templateName,
			templateName .. LibConsoleMenu.WITH_SECTION_SUFFIX,
			templateName .. LibConsoleMenu.WITH_NAV_SECTION_SUFFIX,
		}

		RegisterTemplateVariants(list, templateName, poolSuffix)
		if factory then
			ExtendTemplateFactories(list, names, factory)
		end
		ShareTemplatesWithSubmenus(list, names)
	end

	-- Templates[controlType] is either a string (one template) or
	-- { default = "...", multiLine = "..." }. suffix matches that shape.
	local function AddPool(controlType, suffix, factory)
		local entry = Templates[controlType]
		if type(entry) == "table" then
			RegisterTemplatePool(entry.default, suffix.default, factory)
			if entry.multiLine then
				RegisterTemplatePool(entry.multiLine, suffix.multiLine, factory)
			end
		else
			RegisterTemplatePool(entry, suffix, factory)
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
		self.CT_EDITBOX,
		{ default = "EditBox", multiLine = "EditBoxMulti" },
		LibConsoleMenu.CreateEditBoxPoolFactory()
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
