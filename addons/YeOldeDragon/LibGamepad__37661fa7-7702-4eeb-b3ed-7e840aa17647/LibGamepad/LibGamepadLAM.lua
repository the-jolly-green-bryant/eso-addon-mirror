local ADDON_NAME = "LibGamepadLAM"
local CONST_SYSTEM_EXTENSIONS = LibGamepad.CONST_SYSTEM_EXTENSIONS
local Factory = LibGamepad.ComponentFactory

LibGamepadLAM = LibGamepadLAM or {}
LibGamepadLAM.CachedPanels = {}
LibGamepadLAM.CachedOptions = {}
LibGamepadLAM.EditboxDialogs = {} -- Cache dialog definitions, keyed by option reference
LibGamepadLAM.DIVIDER_TEXT = "|cebe7bc________________|r"

-- Set to true to enable debug output to chat
local DEBUG = false
local function dbg(msg)
	if DEBUG then
		d("[LibGamepadLAM] " .. tostring(msg))
	end
end

-- Dialog name used for the single shared editbox dialog
local EDITBOX_DIALOG_NAME = "LIBGAMEPADLAM_EDITBOX_INPUT"

-- Original references to LAM functions prior to monkey-patching
local originalRegisterAddonPanel
local originalRegisterOptionControls

local function InterceptRegisterAddonPanel(self, addonID, panelData)
	dbg("Intercepting LAM panel: " .. tostring(addonID))
	-- Call original function
	local panel = originalRegisterAddonPanel(self, addonID, panelData)
	-- Cache panel data for Gamepad parsing later
	LibGamepadLAM.CachedPanels[addonID] = panelData
	return panel
end

local function StripGamepadOnly(optionsTable)
	if not optionsTable then
		return
	end
	for i = #optionsTable, 1, -1 do
		local opt = optionsTable[i]
		if opt.gamepadOnly then
			table.remove(optionsTable, i)
		elseif opt.type == "submenu" and opt.controls then
			StripGamepadOnly(opt.controls)
		end
	end
end

local function InterceptRegisterOptionControls(self, addonID, optionsTable)
	dbg("Intercepting LAM options for: " .. tostring(addonID))

	-- Cache options table for Gamepad parsing later. Do a deep copy first so our modifications below dont destroy the tree
	LibGamepadLAM.CachedOptions[addonID] = ZO_DeepTableCopy(optionsTable)

	-- We mutate the original table by removing any gamepadOnly nodes so they never reach the PC Keyboard Setting UI system
	StripGamepadOnly(optionsTable)

	-- Call original function with the stripped table
	originalRegisterOptionControls(self, addonID, optionsTable)
end

-- Inject our interceptors into LibAddonMenu
local function HookLibAddonMenu()
	local LAM = LibAddonMenu2
	if not LAM then
		return
	end

	-- Ensure we only hook once
	if not LibGamepadLAM.HookedLAM then
		originalRegisterAddonPanel = LAM.RegisterAddonPanel
		originalRegisterOptionControls = LAM.RegisterOptionControls

		LAM.RegisterAddonPanel = function(self, addonID, panelData)
			return InterceptRegisterAddonPanel(self, addonID, panelData)
		end

		LAM.RegisterOptionControls = function(self, addonID, optionsTable)
			InterceptRegisterOptionControls(self, addonID, optionsTable)
		end

		LibGamepadLAM.HookedLAM = true
		dbg("Successfully hooked into LibAddonMenu-2.0")
	end
end

-- Resolve a LAM text field: may be a function, a number (ESO string ID), or a plain string.
-- Mirrors LibAddonMenu2.util.GetStringFromValue.
local function GetLAMString(value)
	if type(value) == "function" then
		return value() or ""
	elseif type(value) == "number" then
		return GetString(value) or ""
	end
	return value or ""
end

-- Remove ESO inline color tags from a string (e.g. |cFFFFFF...|r).
local function StripESOColorMarkup(value)
	local text = tostring(value or "")
	text = text:gsub("|[cC]%x%x%x%x%x%x", "")
	text = text:gsub("|[rR]", "")
	return text
end

-- Helper to properly detect if the Gamepad UI is active,
-- accommodating both standard Gamepad Mode and the Accessibility Mode which forces Gamepad UI on PC.
function LibGamepadLAM.IsGamepadUIActive()
	if IsInGamepadPreferredMode() then
		return true
	end
	-- Fallback for Accessibility Mode
	if GetSetting_Bool and SETTING_TYPE_ACCESSIBILITY and ACCESSIBILITY_SETTING_ACCESSIBILITY_MODE then
		return GetSetting_Bool(SETTING_TYPE_ACCESSIBILITY, ACCESSIBILITY_SETTING_ACCESSIBILITY_MODE)
	end
	return false
end

-- Resolve a LAM tooltip field, which may be a string, a function, or nil.
local function ResolveLAMTextValue(value)
	local current = value
	local remainingCalls = 3

	-- Some addons return callbacks from callbacks. Resolve a few levels defensively.
	while type(current) == "function" and remainingCalls > 0 do
		local ok, result = pcall(current)
		if not ok then
			return ""
		end
		current = result
		remainingCalls = remainingCalls - 1
	end

	if type(current) == "number" then
		return GetString(current) or ""
	elseif type(current) == "string" then
		return current
	end

	-- Unsupported type (table/function/boolean/etc): hide text rather than surfacing internals.
	return ""
end

-- Resolve a LAM tooltip field, which may be a string, a function, or nil.
local function GetLAMTooltip(lamOption)
	return ResolveLAMTextValue(lamOption.tooltip)
end

-- Resolve a LAM warning field, and append it to the tooltip
local function GetLAMTooltipWithWarning(lamOption)
	local tooltipText = GetLAMTooltip(lamOption)
	local warningText = ResolveLAMTextValue(lamOption.warning)

	if warningText ~= "" then
		if tooltipText ~= "" then
			tooltipText = tooltipText .. "\n\n"
		end
		tooltipText = tooltipText .. "|cFF0000" .. warningText .. "|r"
	end

	return tooltipText ~= "" and tooltipText or nil
end

-- Wraps a setter function to display a UIAlert that a UI Reload is needed
local function ApplyRequiresReload(lamOption, originalSetter)
	return function(...)
		if originalSetter then
			originalSetter(...)
		end
		if lamOption.requiresReload then
			ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(SI_LIBGAMEPAD_RELOAD_UI_WARNING))
		end
	end
end

-- Build a gamepadCustomTooltipFunction only when there is content to show.
-- Returns nil if tooltip is empty so ESO resets the tooltip automatically.
local function MakeTooltipFunc(tooltipText)
	if not tooltipText or tooltipText == "" then
		return nil
	end
	return function(tooltipControl)
		GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(tooltipControl, tooltipText)
	end
end

-- Map LAM controls to LibGamepad controls
local function ConvertLAMOptionToGamepad(lamOption)
	local oType = lamOption.type
	local gpOption = {}

	-- Divider (visual separator)
	if oType == "divider" then
		gpOption.text = LibGamepadLAM.DIVIDER_TEXT
		gpOption.controlType = OPTIONS_INVOKE_CALLBACK
		-- canSelect = false : ZO_ParametricScrollList.MoveNext/MovePrevious skip items with this flag
		gpOption.canSelect = false
		gpOption.disabled = function()
			return true
		end

	-- Header / Description (Visual)
	elseif oType == "header" then
		-- LAM headers are structural separators. To match LibGamepad's native-looking
		-- section headers, they must feed the `header` field of the NEXT entry instead of
		-- becoming their own selectable/non-selectable text row.
		gpOption = Factory.CreateSectionHeaderMarker(GetLAMString(lamOption.name or lamOption.title))
	elseif oType == "description" then
		-- LAM description peut avoir un champ "title", "text", ou les deux.
		-- Certains addons n'utilisent que "title" (sans "text").
		local titleText = GetLAMString(lamOption.title)
		local bodyText = GetLAMString(lamOption.text)
		local rawText
		if titleText ~= "" and bodyText ~= "" then
			rawText = titleText .. "\n" .. bodyText
		else
			rawText = titleText ~= "" and titleText or bodyText
		end
		if lamOption.uppercase then
			rawText = string.upper(rawText)
		end
		gpOption.text = rawText
		gpOption.controlType = OPTIONS_INVOKE_CALLBACK
		gpOption.customTemplate = "LibGamepad_OptionsDescriptionRow"
		gpOption.canSelect = false
		gpOption.disabled = function()
			return true
		end

	-- Checkbox
	elseif oType == "checkbox" then
		gpOption.controlType = OPTIONS_CHECKBOX
		gpOption.text = GetLAMString(lamOption.name)
		gpOption.gamepadCustomTooltipFunction = MakeTooltipFunc(GetLAMTooltipWithWarning(lamOption))
		gpOption.GetSettingOverride = lamOption.getFunc
		gpOption.SetSettingOverride = ApplyRequiresReload(lamOption, function(control, value)
			lamOption.setFunc(value)
		end)
		gpOption.disabled = lamOption.disabled
		-- Forward optional gamepad SHOW/HIDE override texts set by the addon on the LAM option
		if lamOption.gamepadCheckedText then
			gpOption.gamepadCheckedTextOverride = lamOption.gamepadCheckedText
		end
		if lamOption.gamepadUncheckedText then
			gpOption.gamepadUncheckedTextOverride = lamOption.gamepadUncheckedText
		end

	-- Slider
	elseif oType == "slider" then
		local minVal = lamOption.min or 0
		local maxVal = lamOption.max or 1
		local step = lamOption.step -- optional, may be nil

		gpOption.controlType = OPTIONS_SLIDER
		gpOption.text = GetLAMString(lamOption.name)
		gpOption.minValue = minVal
		gpOption.maxValue = maxVal
		gpOption.showValue = true
		gpOption.showValueMin = minVal
		gpOption.showValueMax = maxVal

		-- Derive valueFormat from LAM's decimals field (default: integer display)
		local decimals = tonumber(lamOption.decimals) or 0
		if decimals > 0 then
			gpOption.valueFormat = "%." .. decimals .. "f"
		else
			gpOption.valueFormat = "%d"
		end

		-- Convert LAM's absolute step value to the ESO gamepad percentage-of-range step.
		-- ESO default step is DEFAULT_SLIDER_VALUE_STEP_PERCENT (6.66 %) of the range.
		-- If LAM didn't specify a step we leave gamepadValueStepPercent nil so ESO uses its default.
		if step and step > 0 then
			local range = maxVal - minVal
			if range > 0 then
				gpOption.gamepadValueStepPercent = (step / range) * 100
			end
		end

		gpOption.gamepadCustomTooltipFunction = function(tooltipControl)
			local currentValue = lamOption.getFunc and lamOption.getFunc() or minVal
			LibGamepad.ApplySliderTooltip(
				tooltipControl,
				gpOption,
				currentValue,
				GetLAMTooltipWithWarning(lamOption),
				lamOption.default
			)
		end

		gpOption.GetSettingOverride = lamOption.getFunc
		gpOption.SetSettingOverride = ApplyRequiresReload(lamOption, function(control, value)
			if lamOption.setFunc then
				lamOption.setFunc(value)
			end
			-- Update the tooltip dynamically while the user is changing the slider value
			if gpOption.gamepadCustomTooltipFunction then
				GAMEPAD_TOOLTIPS:ClearLines(GAMEPAD_LEFT_TOOLTIP)
				gpOption.gamepadCustomTooltipFunction(GAMEPAD_LEFT_TOOLTIP)
			end
		end)
		gpOption.disabled = lamOption.disabled
		-- Use the enhanced slider template that shows min / max and current value.
		gpOption.customTemplate = "LibGamepad_SliderRow"

	-- Dropdown (Finite List)
	elseif oType == "dropdown" then
		gpOption.controlType = OPTIONS_FINITE_LIST
		gpOption.text = GetLAMString(lamOption.name)
		gpOption.valid = lamOption.choicesValues or lamOption.choices
		gpOption.itemText = lamOption.choices

		gpOption.gamepadCustomTooltipFunction = MakeTooltipFunc(GetLAMTooltipWithWarning(lamOption))
		gpOption.GetSettingOverride = lamOption.getFunc
		gpOption.SetSettingOverride = ApplyRequiresReload(lamOption, function(control, value)
			lamOption.setFunc(value)
		end)
		gpOption.disabled = lamOption.disabled

	-- Editbox (Text Input)
	elseif oType == "editbox" then
		gpOption.controlType = OPTIONS_INVOKE_CALLBACK
		gpOption.text = GetLAMString(lamOption.name)
		gpOption.gamepadCustomTooltipFunction = function(tooltipControl)
			local currentValue = lamOption.getFunc and lamOption.getFunc() or ""
			local tip = GetString(SI_LIBGAMEPADLAM_EDITBOX_CURRENT_VALUE)
				.. " |cFFFFFF"
				.. tostring(currentValue)
				.. "|r"
			local tooltipText = GetLAMTooltipWithWarning(lamOption)
			if tooltipText and tooltipText ~= "" then
				tip = tip .. "\n\n" .. tooltipText
			end
			GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(tooltipControl, tip)
		end
		gpOption.callback = function(control)
			-- Pass the wrapper setFunc to the dialog payload so requiresReload works here as well
			local wrapperSetFunc = ApplyRequiresReload(lamOption, function(value)
				lamOption.setFunc(value)
			end)
			LibGamepadLAM.ShowEditboxDialog(lamOption, wrapperSetFunc)
		end
		gpOption.disabled = lamOption.disabled

	-- Submenu
	elseif oType == "submenu" then
		gpOption.isSubmenu = true
		gpOption.controlType = OPTIONS_INVOKE_CALLBACK
		gpOption.text = GetLAMString(lamOption.name)
		gpOption.customTemplate = "LibGamepad_OptionsSubmenuRow"
		gpOption.gamepadCustomTooltipFunction = MakeTooltipFunc(GetLAMTooltipWithWarning(lamOption))
		-- Callback handled externally by parent parser
		gpOption.disabled = lamOption.disabled

	-- Button
	elseif oType == "button" then
		gpOption.controlType = OPTIONS_INVOKE_CALLBACK
		gpOption.text = GetLAMString(lamOption.name)

		gpOption.gamepadCustomTooltipFunction = MakeTooltipFunc(GetLAMTooltipWithWarning(lamOption))
		gpOption.callback = function(control)
			if type(lamOption.func) == "function" then
				lamOption.func()
			end
		end
		gpOption.disabled = lamOption.disabled

	-- Unsupported / Fallback
	else
		gpOption.controlType = OPTIONS_INVOKE_CALLBACK
		gpOption.text = GetLAMString(lamOption.name) ~= "" and GetLAMString(lamOption.name) or "[Unknown Option]"
		gpOption.disabled = function()
			return true
		end
		-- Always show the "not implemented" message so the user understands why the option is disabled
		gpOption.gamepadCustomTooltipFunction = MakeTooltipFunc(GetString(SI_LIBGAMEPADLAM_NOT_IMPLEMENTED))
	end

	-- Common: Add default reset function if default is provided
	if lamOption.default ~= nil and lamOption.setFunc then
		gpOption.customResetToDefaultsFunction = function(control, settingData)
			local def = type(lamOption.default) == "function" and lamOption.default() or lamOption.default
			lamOption.setFunc(def)
		end
	end

	return gpOption
end

-- ---------------------------------------------------------------------------
-- Navigation stack
-- ---------------------------------------------------------------------------
-- Handled by LibGamepad.PushMenu in LibGamepadOptions.lua

-- Once the game is ready and all addons are loaded, we convert LAM to LibGamepad
local function InitializeExtension()
	local currentLamPanelId = 1000 -- Start assigning virtual panel IDs from 1000 to avoid conflicts
	local count = 0

	dbg("Initializing extension. Processing cached LAM data...")

	-- Build a deterministic alphabetical list of addon IDs for display ordering.
	local sortedAddonIDs = {}
	for addonID in pairs(LibGamepadLAM.CachedPanels) do
		sortedAddonIDs[#sortedAddonIDs + 1] = addonID
	end

	table.sort(sortedAddonIDs, function(a, b)
		local panelA = LibGamepadLAM.CachedPanels[a] or {}
		local panelB = LibGamepadLAM.CachedPanels[b] or {}

		local nameA = string.lower(StripESOColorMarkup(panelA.displayName or panelA.name or a))
		local nameB = string.lower(StripESOColorMarkup(panelB.displayName or panelB.name or b))

		if nameA == nameB then
			return tostring(a) < tostring(b)
		end

		return nameA < nameB
	end)

	for _, addonID in ipairs(sortedAddonIDs) do
		local panelData = LibGamepadLAM.CachedPanels[addonID]
		local optionsTable = LibGamepadLAM.CachedOptions[addonID]
		if optionsTable and #optionsTable > 0 then
			local menuEntryName = StripESOColorMarkup(panelData.displayName or panelData.name or addonID)
			local virtualPanelId = currentLamPanelId
			currentLamPanelId = currentLamPanelId + 1
			local virtualPanelContext =
				Factory.CreatePanelContext(virtualPanelId, CONST_SYSTEM_EXTENSIONS, panelData.name or addonID)

			-- Create a root button for this LAM Addon in the "Extensions - Options" panel
			local rootOption = Factory.CreateSubmenuEntry(menuEntryName, virtualPanelId, {
				header = function()
					return GetString(SI_LIBGAMEPAD_ADDONS_HEADER)
				end,
				tooltipFunction = function(tooltipControl)
					local authorInfo = ""
					if panelData.author then
						authorInfo = "\n\nAuthor: " .. panelData.author
					end
					GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(
						tooltipControl,
						"Manage options for " .. (panelData.name or addonID) .. authorInfo
					)
				end,
			})

			local settingIdCounter = 1
			local pendingHeaderText = nil

			-- Convert all controls for this LAM addon
			for _, lamOption in ipairs(optionsTable) do
				local gpOption = ConvertLAMOptionToGamepad(lamOption)

				if gpOption.isSectionHeader then
					pendingHeaderText = gpOption.headerText
				else
					pendingHeaderText = Factory.ApplyPendingHeader(gpOption, pendingHeaderText)

					-- If it's a submenu, we need to create yet another virtual panel
					if gpOption.isSubmenu then
						local submenuVirtualPanelId = currentLamPanelId
						currentLamPanelId = currentLamPanelId + 1
						local submenuPanelContext = Factory.CreatePanelContext(
							submenuVirtualPanelId,
							CONST_SYSTEM_EXTENSIONS,
							GetLAMString(lamOption.name)
						)
						local submenuSettingIdCounter = 1
						local pendingSubmenuHeaderText = nil

						for _, subLamOption in ipairs(lamOption.controls or {}) do
							local subGpOption = ConvertLAMOptionToGamepad(subLamOption)

							if subGpOption.isSectionHeader then
								pendingSubmenuHeaderText = subGpOption.headerText
							else
								pendingSubmenuHeaderText = Factory.ApplyPendingHeader(subGpOption, pendingSubmenuHeaderText)
								_, submenuSettingIdCounter = Factory.CloneAssignAndAppendOption(
									submenuPanelContext,
									subGpOption,
									submenuSettingIdCounter
								)
							end
						end
						Factory.CommitPanelContext(submenuPanelContext)

						gpOption = Factory.CreateSubmenuEntry(gpOption.text, submenuVirtualPanelId, {
							header = gpOption.header,
							disabled = gpOption.disabled,
							tooltipFunction = gpOption.gamepadCustomTooltipFunction,
						})
					end

					_, settingIdCounter = Factory.CloneAssignAndAppendOption(
						virtualPanelContext,
						gpOption,
						settingIdCounter
					)
				end
			end

			-- Register the options into ZO_SharedOptions
			Factory.CommitPanelContext(virtualPanelContext)

			if LibGamepad then
				LibGamepad.RegisterOption(rootOption)
				count = count + 1
				dbg("Registered " .. tostring(addonID) .. " into LibGamepad extensions menu")
			end
		end
	end

	dbg("Initialization complete. Processed " .. tostring(count) .. " LAM panels.")
end

--[[
	Opens a Gamepad text-input dialog to edit an LAM editbox option.
	Uses a PARAMETRIC dialog with a ZO_GamepadTextFieldItem entry so the
	virtual keyboard is available on consoles.  On PC the edit box simply
	receives focus and the player types normally.

	@param lamOption (table) The original LAM option table (must have .getFunc / .setFunc)
	@param wrapperSetFunc (function) Forwarded setFunc with pre-applied requiresReload hook, if any.
]]
function LibGamepadLAM.ShowEditboxDialog(lamOption, wrapperSetFunc)
	-- Register the dialog only once (ESO caches by name)
	if not ESO_Dialogs[EDITBOX_DIALOG_NAME] then
		ESO_Dialogs[EDITBOX_DIALOG_NAME] = {
			gamepadInfo = {
				dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
			},
			title = {
				text = function(dialog)
					return dialog.data and dialog.data.optionName or ""
				end,
			},
			mainText = {
				text = function(dialog)
					return GetString(SI_LIBGAMEPADLAM_EDITBOX_PROMPT)
				end,
			},
			setup = function(dialog)
				-- Nothing extra needed; the framework calls setupFunc itself
			end,
			parametricList = {
				{
					template = "ZO_GamepadTextFieldItem",
					header = GetString(SI_LIBGAMEPADLAM_EDITBOX_FIELD_HEADER),
					setup = function(control, data, selected, reselectingDuringRebuild, enabled, active)
						local dialog = data.dialog
						local editBoxContainer = control:GetNamedChild("TextField")
						local editBox = editBoxContainer and editBoxContainer:GetNamedChild("Edit")
						if not editBox then
							return
						end

						local currentValue = dialog.data and dialog.data.getFunc and dialog.data.getFunc() or ""
						editBox:SetText(tostring(currentValue))
						editBox:SetDefaultText(GetString(SI_LIBGAMEPADLAM_EDITBOX_PLACEHOLDER))
						editBox:SetMaxInputChars(dialog.data and dialog.data.maxChars or 512)

						-- Track edits so we can pass the final value on confirm
						editBox:SetHandler("OnTextChanged", function(self)
							if dialog.data then
								dialog.data.pendingValue = self:GetText()
							end
						end)

						-- Pre-populate pendingValue in case the user confirms without typing
						if dialog.data then
							dialog.data.pendingValue = tostring(currentValue)
						end

						control.highlight:SetHidden(not selected)

						-- Auto-focus when the entry becomes selected and active
						if selected and active then
							editBox:TakeFocus()
						end
					end,
					callback = function(dialog)
						-- Pressing A on the text-field entry toggles the edit box focus
						local listControl = dialog.entryList:GetSelectedControl()
						if listControl then
							local editBoxContainer = listControl:GetNamedChild("TextField")
							local editBox = editBoxContainer and editBoxContainer:GetNamedChild("Edit")
							if editBox then
								if editBox:HasFocus() then
									editBox:LoseFocus()
								else
									editBox:TakeFocus()
								end
							end
						end
					end,
				},
			},
			buttons = {
				{
					keybind = "DIALOG_PRIMARY",
					text = SI_DIALOG_CONFIRM,
					callback = function(dialog)
						if dialog.data and dialog.data.setFunc and dialog.data.pendingValue ~= nil then
							dialog.data.setFunc(dialog.data.pendingValue)
						end
					end,
				},
				{
					keybind = "DIALOG_NEGATIVE",
					text = SI_DIALOG_CANCEL,
					-- No action: dialog closes without saving
				},
			},
		}
	end

	-- Show the dialog, passing the current lamOption as runtime data
	ZO_Dialogs_ShowGamepadDialog(EDITBOX_DIALOG_NAME, {
		optionName = GetLAMString(lamOption.name),
		getFunc = lamOption.getFunc,
		setFunc = wrapperSetFunc or lamOption.setFunc,
		maxChars = lamOption.maxChars or 512,
		pendingValue = nil,
	})
end

-- Hook early on ADDON_LOADED to ensure we catch LAM before it's used by others
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(event, loadedAddonName)
	if loadedAddonName == "LibAddonMenu-2.0" or LibAddonMenu2 then
		HookLibAddonMenu()
	end
end)

-- Process all cached LAM options once player activated
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
	InitializeExtension()
end)
