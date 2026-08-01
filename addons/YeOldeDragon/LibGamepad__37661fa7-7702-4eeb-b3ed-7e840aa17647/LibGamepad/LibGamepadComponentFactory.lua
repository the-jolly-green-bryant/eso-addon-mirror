LibGamepad = LibGamepad or {}

LibGamepad.PANEL_EXTENSIONS = LibGamepad.PANEL_EXTENSIONS or 99
LibGamepad.CONST_SYSTEM_EXTENSIONS = LibGamepad.CONST_SYSTEM_EXTENSIONS or 9999

local Factory = LibGamepad.ComponentFactory or {}
LibGamepad.ComponentFactory = Factory

function Factory.EnsurePanelStorage(panelId)
	if not GAMEPAD_SETTINGS_DATA[panelId] then
		GAMEPAD_SETTINGS_DATA[panelId] = {}
	end

	return GAMEPAD_SETTINGS_DATA[panelId]
end

function Factory.CreatePanelContext(panelId, system, panelLabel)
	if panelLabel and panelLabel ~= "" then
		ZO_CreateStringId("SI_SETTINGSYSTEMPANEL" .. tostring(panelId), panelLabel)
	end

	Factory.EnsurePanelStorage(panelId)

	return {
		panelId = panelId,
		system = system,
		sharedOptionsTable = {
			[system] = {},
		},
	}
end

function Factory.AssignOptionIdentity(optionData, panelId, system, settingId)
	optionData.panel = panelId
	optionData.system = system
	optionData.settingId = settingId
	return optionData
end

function Factory.AppendOption(context, optionData, sharedCopyMutator)
	table.insert(GAMEPAD_SETTINGS_DATA[context.panelId], optionData)

	local sharedCopy = ZO_ShallowTableCopy(optionData)
	if sharedCopyMutator then
		sharedCopyMutator(sharedCopy, optionData)
	end

	context.sharedOptionsTable[context.system][optionData.settingId] = sharedCopy
	return optionData, sharedCopy
end

function Factory.CloneAssignAndAppendOption(context, optionTemplate, nextSettingId, sharedCopyMutator)
	local optionData = ZO_ShallowTableCopy(optionTemplate)
	if not optionData.settingId then
		optionData.settingId = nextSettingId
		nextSettingId = nextSettingId + 1
	end

	Factory.AssignOptionIdentity(optionData, context.panelId, context.system, optionData.settingId)
	Factory.AppendOption(context, optionData, sharedCopyMutator)
	return optionData, nextSettingId
end

function Factory.CommitPanelContext(context)
	if ZO_SharedOptions and ZO_SharedOptions.AddTableToPanel then
		ZO_SharedOptions.AddTableToPanel(context.panelId, context.sharedOptionsTable)
	end
end

function Factory.CreateSectionHeaderMarker(headerText)
	return {
		isSectionHeader = true,
		headerText = headerText,
	}
end

function Factory.ApplyPendingHeader(optionData, pendingHeaderText)
	if pendingHeaderText and not optionData.header then
		local headerText = pendingHeaderText
		optionData.header = function()
			return headerText
		end
		return nil
	end

	return pendingHeaderText
end

function Factory.CreateSubmenuEntry(label, targetPanelId, options)
	label = label or ""

	local entry = {
		controlType = OPTIONS_INVOKE_CALLBACK,
		text = label,
		gamepadTextOverride = (options and options.gamepadTextOverride) or label,
		customTemplate = "LibGamepad_OptionsSubmenuRow",
		callback = function(control)
			if GAMEPAD_OPTIONS then
				LibGamepad.PushMenu(targetPanelId)
			end
		end,
	}

	if options then
		entry.header = options.header
		entry.disabled = options.disabled

		if options.tooltipFunction then
			entry.gamepadCustomTooltipFunction = options.tooltipFunction
		elseif options.tooltipText and options.tooltipText ~= "" then
			entry.gamepadCustomTooltipFunction = function(tooltipControl)
				GAMEPAD_TOOLTIPS:LayoutTextBlockTooltip(tooltipControl, options.tooltipText)
			end
		end
	end

	return entry
end