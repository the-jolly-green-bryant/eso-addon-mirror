local ADDON_NAME = "LibGamepad"
local PANEL_EXTENSIONS = LibGamepad.PANEL_EXTENSIONS
local CONST_SYSTEM_EXTENSIONS = LibGamepad.CONST_SYSTEM_EXTENSIONS
local Factory = LibGamepad.ComponentFactory

local function IsLibGamepadSettingsData(data)
	return data ~= nil and data.system == CONST_SYSTEM_EXTENSIONS
end

local function IsNativeSliderTemplateName(templateName)
	return templateName == "ZO_GamepadOptionsSliderRow" or templateName == "ZO_GamepadOptionsSliderRowWithHeader"
end

-- ZO_SharedOptions.GetSettingsData() returns the SAME object reference that was
-- passed to AddTableToPanel. ESO then mutates it (e.g. data.header = nil).
-- We must therefore pass COPIES to ZO_SharedOptions so GAMEPAD_SETTINGS_DATA
-- entries remain untouched. We can use ZO_ShallowTableCopy for this.

local function InjectMainMenuShortcut()
	if not ZO_MENU_ENTRIES then
		return
	end

	-- Check if we already injected it
	for i, entry in ipairs(ZO_MENU_ENTRIES) do
		if entry.data and entry.data.isLibGamepadShortcut then
			return
		end
	end

	-- Create a custom entry for the Main Menu (Options/Start screen)
	local data = {
		name = GetString(SI_GAMEPAD_ADDON_MENU_CATEGORY_ADDON_MANAGER),
		icon = "esoui/art/options/gamepad/gp_options_addons.dds",
		isLibGamepadShortcut = true,
		isVisibleCallback = function()
			return LibGamepad.SV and LibGamepad.SV.ShowMainMenuShortcut
		end,
		activatedCallback = function()
			if GAMEPAD_OPTIONS then
				GAMEPAD_OPTIONS.currentCategory = PANEL_EXTENSIONS
				if
					IsInUI("pregame")
					and not IsAccountLoggedIn()
					and ZO_PregameStateManager_GetCurrentState() ~= "FirstTimeAccessibilitySettings"
				then
					GAMEPAD_OPTIONS_PANEL_SCENE:AddTemporaryFragment(PREGAME_ANIMATED_BACKGROUND_FRAGMENT)
				end
				SCENE_MANAGER:Push("gamepad_options_panel")
			end
		end,
	}

	local entry = ZO_GamepadEntryData:New(data.name, data.icon)
	entry:SetIconTintOnSelection(true)
	entry:SetIconDisabledTintOnSelection(true)
	entry.data = data
	entry.id = CONST_SYSTEM_EXTENSIONS -- Required by ZO_MainMenuManager_Gamepad:RefreshMainList

	-- Insert between "Options" and "Quit"/"Logout" when possible.
	-- Fallback order:
	-- 1) Before first Quit/Log out entry after Options
	-- 2) Right after Options
	-- 3) End of the list
	local optionsIndex
	local quitOrLogoutIndex
	for i, existingEntry in ipairs(ZO_MENU_ENTRIES) do
		if ZO_MENU_MAIN_ENTRIES and existingEntry.id == ZO_MENU_MAIN_ENTRIES.OPTIONS then
			optionsIndex = i
		elseif ZO_MENU_MAIN_ENTRIES and (existingEntry.id == ZO_MENU_MAIN_ENTRIES.QUIT or existingEntry.id == ZO_MENU_MAIN_ENTRIES.LOG_OUT) then
			if not quitOrLogoutIndex and (not optionsIndex or i > optionsIndex) then
				quitOrLogoutIndex = i
			end
		end
	end

	if quitOrLogoutIndex then
		table.insert(ZO_MENU_ENTRIES, quitOrLogoutIndex, entry)
	elseif optionsIndex then
		table.insert(ZO_MENU_ENTRIES, optionsIndex + 1, entry)
	else
		table.insert(ZO_MENU_ENTRIES, entry)
	end

	if MAIN_MENU_GAMEPAD then
		MAIN_MENU_GAMEPAD:UpdateEntryEnabledStates()
	end
end

-- Shared definitions for the 3 built-in core options.
-- Each entry is the single source of truth used for both GAMEPAD_SETTINGS_DATA and ZO_SharedOptions.
local function BuildCoreOptions()
	return {
		{
			panel = PANEL_EXTENSIONS,
			system = CONST_SYSTEM_EXTENSIONS,
			settingId = LibGamepad.SETTING_ID_ADDONS_TOGGLE,
			controlType = OPTIONS_INVOKE_CALLBACK,
			header = function()
				return GetString(SI_LIBGAMEPAD_ADDONS_GENERAL_HEADER)
			end,
			text = GetString(SI_GAMEPAD_MOD_BROWSER_SUBSCRIBED_HEADER),
			gamepadTextOverride = GetString(SI_GAMEPAD_MOD_BROWSER_SUBSCRIBED_HEADER),
			tooltipText = GetString(SI_LIBGAMEPAD_ADDONS_TOGGLE_TT),
			gamepadCustomTooltipFunction = function(tooltipControl)
				GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(tooltipControl, GetString(SI_LIBGAMEPAD_ADDONS_TOGGLE_TT))
			end,
		},
		{
			panel = PANEL_EXTENSIONS,
			system = CONST_SYSTEM_EXTENSIONS,
			settingId = LibGamepad.SETTING_ID_DEBUG_SHORTCUT,
			controlType = OPTIONS_CHECKBOX,
			header = function()
				return GetString(SI_LIBGAMEPAD_ADDONS_GENERAL_HEADER)
			end,
			text = GetString(SI_LIBGAMEPAD_DEBUG_SHORTCUT),
			gamepadTextOverride = GetString(SI_LIBGAMEPAD_DEBUG_SHORTCUT),
			tooltipText = GetString(SI_LIBGAMEPAD_DEBUG_SHORTCUT_TT),
			gamepadCustomTooltipFunction = function(tooltipControl)
				GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(tooltipControl, GetString(SI_LIBGAMEPAD_DEBUG_SHORTCUT_TT))
			end,
			GetSettingOverride = function()
				return LibGamepad.SV and LibGamepad.SV.ShowMainMenuShortcut
			end,
			SetSettingOverride = function(control, value)
				LibGamepad.SV.ShowMainMenuShortcut = value
				if MAIN_MENU_GAMEPAD then
					MAIN_MENU_GAMEPAD:UpdateEntryEnabledStates()
				end
			end,
		},
	}
end

local function InitializeOptions()
	if not IsInGamepadPreferredMode() then
		return
	end

	local coreOptions = BuildCoreOptions()
	local extensionPanelContext = Factory.CreatePanelContext(PANEL_EXTENSIONS, CONST_SYSTEM_EXTENSIONS)

	-- Populate GAMEPAD_SETTINGS_DATA with core options
	for _, option in ipairs(coreOptions) do
		Factory.AppendOption(extensionPanelContext, option)
	end

	-- Add registered extension options at the end
	if LibGamepad.ExtensionOptions then
		for _, option in ipairs(LibGamepad.ExtensionOptions) do
			Factory.AppendOption(extensionPanelContext, option, function(sharedCopy)
				sharedCopy.header = GetString(SI_LIBGAMEPAD_ADDONS_HEADER)
			end)
		end
	end

	-- Initialize shared Gamepad Reload UI confirmation dialog
	if not ESO_Dialogs["LIBGAMEPAD_RELOADUI_CONFIRM"] then
		ESO_Dialogs["LIBGAMEPAD_RELOADUI_CONFIRM"] = {
			gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
			title = { text = GetString(SI_LIBGAMEPAD_ADDONS_RELOADUI) },
			mainText = { text = GetString(SI_LIBGAMEPAD_RELOAD_UI_WARNING) },
			tooltipText = GetString(SI_LIBGAMEPAD_RELOAD_UI_WARNING),
			buttons = {
				{
					text = SI_DIALOG_CONFIRM,
					callback = function(dialog)
						ReloadUI()
					end,
				},
				{
					text = SI_DIALOG_CANCEL,
				},
			},
		}
	end

	-- Register the option data with ZO_SharedOptions using COPIES of the source entries.
	-- ZO_SharedOptions.GetSettingsData() returns the very object stored here, and ESO
	-- mutates it (e.g. data.header = nil). Using copies protects GAMEPAD_SETTINGS_DATA.
	Factory.CommitPanelContext(extensionPanelContext)

	-- Hook the callback for OPTIONS_INVOKE_CALLBACK for our specific option
	ZO_PreHook("ZO_Options_InvokeCallback", function(control)
		if control.data and control.data.system == CONST_SYSTEM_EXTENSIONS then
			if control.data.panel == PANEL_EXTENSIONS and control.data.settingId == LibGamepad.SETTING_ID_ADDONS_TOGGLE then
				-- Open the addon manager
				SCENE_MANAGER:Push("gamepad_addons")
				return true
			elseif control.data.panel == PANEL_EXTENSIONS and control.data.settingId == LibGamepad.SETTING_ID_RELOAD_UI then
				-- Reload UI
				ReloadUI()
				return true
			elseif control.data.callback then
				-- Execute custom callback defined by an extension
				control.data.callback(control)
				return true
			end
		end
		-- Fallback to original
		return false
	end)

	-- 2. Register the Custom Category in the Options Menu
	ZO_CreateStringId("SI_SETTINGSYSTEMPANEL99", GetString(SI_GAMEPAD_ADDON_MENU_CATEGORY_ADDON_MANAGER))
	local extensionsCategoryData = ZO_GamepadEntryData:New(
		GetString(SI_GAMEPAD_ADDON_MENU_CATEGORY_ADDON_MANAGER),
		"/esoui/art/options/gamepad/gp_options_addons.dds"
	)

	extensionsCategoryData.sortOrder = 110
	extensionsCategoryData.panelId = PANEL_EXTENSIONS
	extensionsCategoryData:SetIconTintOnSelection(true)

	-- In Gamepad GUI, when a category is selected, the list on the right is populated
	-- using GAMEPAD_SETTINGS_DATA[categoryData.panelId] if the callback is nil.
	-- However, for custom categories, ZO_GamepadOptions expects a standard panelId or custom setup.
	-- zo_options_gamepad.lua uses `panelId` to find options in GAMEPAD_SETTINGS_DATA.
	extensionsCategoryData.callback = function()
		if GAMEPAD_OPTIONS then
			GAMEPAD_OPTIONS.currentCategory = PANEL_EXTENSIONS
			SCENE_MANAGER:Push("gamepad_options_panel")
		end
	end

	if GAMEPAD_OPTIONS then
		GAMEPAD_OPTIONS:RegisterCustomCategory(extensionsCategoryData)

		-- Register all LibGamepad custom templates (defined in LibGamepadTemplates.xml).
		-- We hook SetupOptionsList because the list object isn't created until
		-- ZO_GamepadOptions:OnDeferredInitialize() fires (first time the screen opens).
		local function RegisterCustomTemplates(self, list)
			-- ── Submenu arrow row ──────────────────────────────────────────────────
			-- Looks like a normal label row but adds a right-arrow texture.
			local function ArrowEntrySetup(control, data, selected, reselectingDuringRebuild, enabled, active)
				control.data = data
				GAMEPAD_OPTIONS:InitializeControl(control, selected)
				-- Tint the arrow to match the label colour (selected / unselected / disabled)
				local arrow = control:GetNamedChild("Arrow")
				if arrow then
					local isEnabled = data.enabled ~= false
					local color = ZO_GamepadMenuEntryTemplate_GetLabelColor(selected, not isEnabled)
					arrow:SetColor(color:UnpackRGBA())
				end
			end

			list:AddDataTemplate(
				"LibGamepad_OptionsSubmenuRow",
				ArrowEntrySetup,
				ZO_GamepadMenuEntryTemplateParametricListFunction
			)
			list:AddDataTemplateWithHeader(
				"LibGamepad_OptionsSubmenuRow",
				ArrowEntrySetup,
				ZO_GamepadMenuEntryTemplateParametricListFunction,
				nil,
				"ZO_GamepadOptionsHeaderTemplate"
			)

			-- ── Section header row (LAM "header" type) ─────────────────────────────
			local HEADER_SELECTED_COLOR = ZO_ColorDef:New(0xDA / 255, 0x8A / 255, 0x00 / 255, 1) -- amber
			local HEADER_UNSELECTED_COLOR = ZO_ColorDef:New(0x99 / 255, 0x60 / 255, 0x00 / 255, 1) -- dimmed amber

			local function SectionHeaderSetup(control, data, selected, reselectingDuringRebuild, enabled, active)
				control.data = data
				GAMEPAD_OPTIONS:InitializeControl(control, selected)
				local label = control:GetNamedChild("Name")
				if label then
					local color = selected and HEADER_SELECTED_COLOR or HEADER_UNSELECTED_COLOR
					label:SetColor(color:UnpackRGBA())
				end
			end

			list:AddDataTemplate(
				"LibGamepad_OptionsSectionHeaderRow",
				SectionHeaderSetup,
				ZO_GamepadMenuEntryTemplateParametricListFunction
			)
			list:AddDataTemplateWithHeader(
				"LibGamepad_OptionsSectionHeaderRow",
				SectionHeaderSetup,
				ZO_GamepadMenuEntryTemplateParametricListFunction,
				nil,
				"ZO_GamepadOptionsHeaderTemplate"
			)

			-- ── Description row (LAM "description" type) ───────────────────────────
			local DESCRIPTION_COLOR = ZO_ColorDef:New(0.70, 0.70, 0.70, 1) -- light gray

			local function DescriptionEntrySetup(control, data, selected, reselectingDuringRebuild, enabled, active)
				control.data = data
				GAMEPAD_OPTIONS:InitializeControl(control, selected)
				local label = control:GetNamedChild("Name")
				if label then
					label:SetColor(DESCRIPTION_COLOR:UnpackRGBA())
				end
			end

			list:AddDataTemplate(
				"LibGamepad_OptionsDescriptionRow",
				DescriptionEntrySetup,
				ZO_GamepadMenuEntryTemplateParametricListFunction
			)
			list:AddDataTemplateWithHeader(
				"LibGamepad_OptionsDescriptionRow",
				DescriptionEntrySetup,
				ZO_GamepadMenuEntryTemplateParametricListFunction,
				nil,
				"ZO_GamepadOptionsHeaderTemplate"
			)

			-- ── Enhanced slider row ───────────────────────────────────────────────────
			local function FormatSliderValue(data, v)
				if data.valueFormat then
					return string.format(data.valueFormat, v)
				elseif data.clampedToDecimals and data.clampedToDecimals > 0 then
					return string.format("%." .. tostring(data.clampedToDecimals) .. "f", v)
				end
				return tostring(zo_round(v))
			end

			local function LibGamepadSliderSetup(control, data, selected, reselectingDuringRebuild, enabled, active)
				control.data = data
				GAMEPAD_OPTIONS:InitializeControl(control, selected)

				local slider = control:GetNamedChild("Slider")
				local minLabel = control:GetNamedChild("MinLabel")
				local maxLabel = control:GetNamedChild("MaxLabel")
				local valueLabel = control:GetNamedChild("ValueLabel")

				if not (slider and minLabel and maxLabel and valueLabel) then
					return
				end

				local sliderMin, sliderMax = slider:GetMinMax()
				minLabel:SetText(FormatSliderValue(data, sliderMin))
				maxLabel:SetText(FormatSliderValue(data, sliderMax))

				-- Update the value label text (position is fixed at bar centre via XML).
				local function UpdateThumbLabel()
					local value = slider:GetValue()
					valueLabel:SetText(FormatSliderValue(data, value))
				end

				UpdateThumbLabel()

				-- On Console, SetSetting is a private C function inaccessible from addon
				-- (insecure) code. ZO_Options_SliderOnValueChanged → SetSettingFromControl
				-- always calls SetSetting unconditionally, even when SetSettingOverride is
				-- present, causing a security error on PS5/Xbox. All LibGamepad sliders use
				-- SetSettingOverride, so we call it directly and skip the native chain.
				slider:SetHandler("OnValueChanged", function(s, value, reason)
					if IsLibGamepadSettingsData(data) and data.SetSettingOverride then
						local valueFormat = data.valueFormat or "%d"
						local formattedValue = string.format(valueFormat, value)
						data.SetSettingOverride(control, formattedValue)
					else
						-- Safety net: if this custom template is ever applied to a native slider,
						-- keep ESO's native setting pipeline intact.
						ZO_Options_SliderOnValueChanged(s, value, reason)
					end
					UpdateThumbLabel()
				end)
			end

			list:AddDataTemplate(
				"LibGamepad_SliderRow",
				LibGamepadSliderSetup,
				ZO_GamepadMenuEntryTemplateParametricListFunction
			)
			list:AddDataTemplateWithHeader(
				"LibGamepad_SliderRow",
				LibGamepadSliderSetup,
				ZO_GamepadMenuEntryTemplateParametricListFunction,
				nil,
				"ZO_GamepadOptionsHeaderTemplate"
			)
		end

		SecurePostHook(GAMEPAD_OPTIONS, "SetupOptionsList", RegisterCustomTemplates)

		-- If SetupOptionsList already ran (e.g. options screen opened before PLAYER_ACTIVATED),
		-- register the templates immediately into the existing list.
		if GAMEPAD_OPTIONS.optionsList then
			RegisterCustomTemplates(GAMEPAD_OPTIONS, GAMEPAD_OPTIONS.optionsList)
		end

		-- Monkey-patch AddSettingGroup so that options with data.customTemplate use the
		-- specified template name instead of the one resolved from TEMPLATE_NAMES[controlType].
		-- The patch wraps optionsList.AddEntry for the FULL duration of the call (not just
		-- the first item) and restores it cleanly afterwards.
		local origAddSettingGroup = GAMEPAD_OPTIONS.AddSettingGroup
		GAMEPAD_OPTIONS.AddSettingGroup = function(self, panelId)
			local list = self.optionsList
			local origAddEntry = list.AddEntry

			-- Install wrapper
			list.AddEntry = function(l, templateName, data, ...)
				local resolvedTemplate = templateName

				if data and data.customTemplate then
					-- Explicit override: carry the "WithHeader" suffix over to the custom name.
					local suffix = templateName:match("WithHeader$")
					local wantedTemplate = data.customTemplate .. (suffix and "WithHeader" or "")

					-- Hard safety guard: never allow LibGamepad slider template on native settings.
					if wantedTemplate:match("^LibGamepad_SliderRow") and not IsLibGamepadSettingsData(data) then
						resolvedTemplate = templateName
					else
						resolvedTemplate = wantedTemplate
					end
				elseif data and IsLibGamepadSettingsData(data) and IsNativeSliderTemplateName(templateName) then
					-- Auto-upgrade all slider rows to the enhanced template, even when the
					-- caller (e.g. GamepadUITweaks) didn't set customTemplate explicitly.
					-- IMPORTANT: limit this to LibGamepad custom settings only, otherwise
					-- native ESO panels (e.g. Video/UI scale) lose their SetSetting pipeline.
					resolvedTemplate = templateName:gsub("ZO_GamepadOptionsSliderRow", "LibGamepad_SliderRow")
				end

				return origAddEntry(l, resolvedTemplate, data, ...)
			end

			local result = origAddSettingGroup(self, panelId)

			-- Always restore, even if an error occurs inside AddSettingGroup
			list.AddEntry = origAddEntry
			return result
		end

		-- Add the Reload UI Keybind (Y) to the options panels
		local function InjectReloadKeybind()
			if not GAMEPAD_OPTIONS or type(GAMEPAD_OPTIONS.keybindStripDescriptor) ~= "table" then
				return
			end

			-- Prevent duplicate injection
			for _, kb in ipairs(GAMEPAD_OPTIONS.keybindStripDescriptor) do
				if
					kb.keybind == "UI_SHORTCUT_TERTIARY"
					and kb.name == GetString(SI_BINDING_NAME_LIBGAMEPAD_RELOAD_UI)
				then
					return
				end
			end

			local reloadKeybind = {
				alignment = KEYBIND_STRIP_ALIGN_RIGHT,
				name = GetString(SI_BINDING_NAME_LIBGAMEPAD_RELOAD_UI),
				keybind = "UI_SHORTCUT_TERTIARY",
				visible = function()
					-- Only show if we're at the root, or if we're in a sub-panel and don't need to apply settings
					if GAMEPAD_OPTIONS:IsAtRoot() then
						return true
					else
						return not GAMEPAD_OPTIONS.settingsNeedApply
					end
				end,
				callback = function()
					ZO_Dialogs_ShowGamepadDialog("LIBGAMEPAD_RELOADUI_CONFIRM")
				end,
			}
			table.insert(GAMEPAD_OPTIONS.keybindStripDescriptor, reloadKeybind)

			-- If the scene is currently showing, force a refresh of the keybind strip
			if SCENE_MANAGER:IsShowing("gamepad_options_root") or SCENE_MANAGER:IsShowing("gamepad_options_panel") then
				KEYBIND_STRIP:UpdateKeybindButtonGroup(GAMEPAD_OPTIONS.keybindStripDescriptor)
			end
		end

		if GAMEPAD_OPTIONS then
			SecurePostHook(GAMEPAD_OPTIONS, "InitializeKeybindStrip", InjectReloadKeybind)
			-- Call it once in case it's already initialized
			InjectReloadKeybind()
		end
	end

	InjectMainMenuShortcut()
end

-- Hook into player activated to register the options after all addons are loaded
EVENT_MANAGER:RegisterForEvent("LibGamepad_Options_Init", EVENT_PLAYER_ACTIVATED, function(event)
	EVENT_MANAGER:UnregisterForEvent("LibGamepad_Options_Init", EVENT_PLAYER_ACTIVATED)

	-- Wait until player activated so extensions have finished calling RegisterOption
	InitializeOptions()
end)

-- Extension API
LibGamepad.ExtensionOptions = {}
LibGamepad.NextExtensionSettingId = 10 -- Start IDs for extensions at 10 to leave room for core settings

-- ---------------------------------------------------------------------------
-- Navigation stack for Submenus
-- ---------------------------------------------------------------------------
local NavStack = {}

local function DeactivateActiveOptionsControl()
	if not GAMEPAD_OPTIONS then
		return
	end

	if type(GAMEPAD_OPTIONS.DeactivateSelectedControl) == "function" then
		GAMEPAD_OPTIONS:DeactivateSelectedControl()
		return
	end

	-- Fallback safety for older implementations
	local selectedControl = GAMEPAD_OPTIONS.optionsList and GAMEPAD_OPTIONS.optionsList:GetSelectedControl()
	if selectedControl then
		if selectedControl.slider and type(selectedControl.slider.Deactivate) == "function" then
			selectedControl.slider:Deactivate()
		elseif selectedControl.horizontalListObject and type(selectedControl.horizontalListObject.Deactivate) == "function" then
			selectedControl.horizontalListObject:Deactivate()
		end
	end
end

function LibGamepad.PushMenu(targetPanelId)
	if not GAMEPAD_OPTIONS then
		return
	end

	-- Ensure no slider/horizontal-list remains active while changing panel content.
	DeactivateActiveOptionsControl()

	-- Save the current panel ID AND the currently selected item index so we can
	-- restore the selection when the user presses B to go back.
	local selectedIndex = GAMEPAD_OPTIONS.optionsList and GAMEPAD_OPTIONS.optionsList:GetSelectedIndex() or 1
	table.insert(NavStack, { panelId = GAMEPAD_OPTIONS.currentCategory, selectedIndex = selectedIndex })

	GAMEPAD_OPTIONS.overrideBackCallback = function()
		DeactivateActiveOptionsControl()

		local entry = table.remove(NavStack)
		if not entry then
			GAMEPAD_OPTIONS.overrideBackCallback = nil
			GAMEPAD_OPTIONS.overrideBackName = nil
			return
		end

		GAMEPAD_OPTIONS.currentCategory = entry.panelId

		if #NavStack == 0 then
			-- Back to the root: clear the override completely
			GAMEPAD_OPTIONS.overrideBackCallback = nil
			GAMEPAD_OPTIONS.overrideBackName = nil
		else
			-- Still inside a nested panel: keep the same callback so the
			-- next press continues popping the stack
			GAMEPAD_OPTIONS.overrideBackName = GetString(SI_GAMEPAD_BACK_OPTION)
		end

		GAMEPAD_OPTIONS:RefreshHeader()
		GAMEPAD_OPTIONS:RefreshOptionsList()

		-- Restore selection to the item the user was on before navigating into the subpanel
		if entry.selectedIndex and GAMEPAD_OPTIONS.optionsList then
			GAMEPAD_OPTIONS.optionsList:SetSelectedIndexWithoutAnimation(entry.selectedIndex, true)
		end
	end
	GAMEPAD_OPTIONS.overrideBackName = GetString(SI_GAMEPAD_BACK_OPTION)

	GAMEPAD_OPTIONS.currentCategory = targetPanelId
	GAMEPAD_OPTIONS:RefreshHeader()
	GAMEPAD_OPTIONS:RefreshOptionsList()

	-- En entrant dans un nouveau panneau, toujours positionner sur le 1er item sélectionnable
	if GAMEPAD_OPTIONS.optionsList then
		GAMEPAD_OPTIONS.optionsList:SetFirstIndexSelected()
	end
end

LibGamepad.VirtualSubmenuPanelId = 3000 -- Submenu panel ID starts at 3000 for standard submenus

--[[
	Generates a standard rich tooltip for sliders containing description, Min, Max, and Default values.
	@param tooltipControl The tooltip control element
	@param optionTable The original Gamepad UI option config table
	@param currentValue The current value
	@param tooltipText A description text to prepend (Optional)
	@param defaultValue The option's default value to display (Optional)
]]
function LibGamepad.ApplySliderTooltip(tooltipControl, optionTable, currentValue, tooltipText, defaultValue)
	local formattedValueString, formattedMinString, formattedMaxString =
		ZO_Options_GetFormattedSliderValues(optionTable, currentValue)

	local tip = ""

	-- Add description first if it exists
	if tooltipText and tooltipText ~= "" then
		tip = tip .. tooltipText .. "\n"
	end

	if defaultValue ~= nil then
		local formattedDefaultString = tostring(math.floor(defaultValue))
		tip = tip
			.. "\n|c777777"
			.. ZO_CachedStrFormat(SI_SET_DEFAULT_COLLECTIBLE_NAME_FORMAT, tostring(formattedDefaultString))
			.. "|r"
	end

	GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(tooltipControl, tip)
end

--[[
	Registers a new option to the Gamepad Extensions menu.
	@param optionData (table) The standard ZO_SharedOptions standard entry table.
]]
function LibGamepad.RegisterOption(optionData)
	if not optionData then
		return
	end

	-- Assign internal properties
	if not optionData.settingId then
		optionData.settingId = LibGamepad.NextExtensionSettingId
		LibGamepad.NextExtensionSettingId = LibGamepad.NextExtensionSettingId + 1
	end
	Factory.AssignOptionIdentity(optionData, PANEL_EXTENSIONS, CONST_SYSTEM_EXTENSIONS, optionData.settingId)

	table.insert(LibGamepad.ExtensionOptions, optionData)

	-- Dynamically inject if the options menu was already initialized
	if GAMEPAD_SETTINGS_DATA and GAMEPAD_SETTINGS_DATA[PANEL_EXTENSIONS] then
		local extensionPanelContext = Factory.CreatePanelContext(PANEL_EXTENSIONS, CONST_SYSTEM_EXTENSIONS)
		Factory.AppendOption(extensionPanelContext, optionData, function(sharedCopy, sourceOption)
			if not sourceOption.header then
				sharedCopy.header = GetString(SI_LIBGAMEPAD_ADDONS_HEADER)
			end
		end)
		Factory.CommitPanelContext(extensionPanelContext)
	end
end

--[[
	Creates and registers a nested virtual panel and returns the arrow-button option that navigates into it.
	Use this to embed a sub-sub-menu inside an existing `optionsTable` passed to `RegisterSubmenu`.

	@param label       (string)  Visible label of the arrow entry + title of the nested panel.
	@param optionsTable (table)  Option entries belonging to the nested panel.
	@param tooltipText (string, optional) Tooltip shown when the arrow entry is selected.
	@return arrowEntry (table)  An OPTIONS_INVOKE_CALLBACK entry with customTemplate = LibGamepad_OptionsSubmenuRow.
	        Returns nil if optionsTable is empty/nil.
]]
function LibGamepad.CreateNestedSubmenuEntry(label, optionsTable, tooltipText)
	if not optionsTable or #optionsTable == 0 then
		return nil
	end

	local nestedPanelId = LibGamepad.VirtualSubmenuPanelId
	LibGamepad.VirtualSubmenuPanelId = LibGamepad.VirtualSubmenuPanelId + 1
	local nestedPanelContext = Factory.CreatePanelContext(nestedPanelId, CONST_SYSTEM_EXTENSIONS, label)

	local settingIdCounter = 1
	local pendingHeaderText = nil
	for _, gpOption in ipairs(optionsTable) do
		if gpOption.isSectionHeader then
			pendingHeaderText = gpOption.headerText
		else
			pendingHeaderText = Factory.ApplyPendingHeader(gpOption, pendingHeaderText)
			_, settingIdCounter = Factory.CloneAssignAndAppendOption(nestedPanelContext, gpOption, settingIdCounter)
		end
	end

	Factory.CommitPanelContext(nestedPanelContext)

	return Factory.CreateSubmenuEntry(label, nestedPanelId, {
		tooltipText = tooltipText,
	})
end

--[[
	Registers a submenu in the Extensions menu.
	@param addonId (string) Unique identifier for the addon.
	@param optionsTable (table) Table of option entries to insert into the submenu.
	@param tooltipText (string, optional) Tooltip description for the submenu element.
	@param headerText (string, optional) Header text to separate sections on the root view.
]]
function LibGamepad.RegisterSubmenu(addonId, optionsTable, tooltipText, headerText)
	if not optionsTable or #optionsTable == 0 then
		return
	end

	local virtualPanelId = LibGamepad.VirtualSubmenuPanelId
	LibGamepad.VirtualSubmenuPanelId = LibGamepad.VirtualSubmenuPanelId + 1
	local virtualPanelContext = Factory.CreatePanelContext(virtualPanelId, CONST_SYSTEM_EXTENSIONS, addonId)

	-- 1. Create the entry in the root menu that will push the sub-menu layout
	local rootOption = Factory.CreateSubmenuEntry(addonId, virtualPanelId, {
		header = function()
			return headerText or GetString(SI_LIBGAMEPAD_ADDONS_HEADER)
		end,
		tooltipText = tooltipText,
	})

	local settingIdCounter = 1
	local pendingHeaderText = nil

	for _, gpOption in ipairs(optionsTable) do
		if gpOption.isSectionHeader then
			pendingHeaderText = gpOption.headerText
		else
			pendingHeaderText = Factory.ApplyPendingHeader(gpOption, pendingHeaderText)
			_, settingIdCounter = Factory.CloneAssignAndAppendOption(virtualPanelContext, gpOption, settingIdCounter)
		end
	end

	-- 3. Expose them to ESO and register the root node into LibGamepad
	Factory.CommitPanelContext(virtualPanelContext)

	LibGamepad.RegisterOption(rootOption)
end
