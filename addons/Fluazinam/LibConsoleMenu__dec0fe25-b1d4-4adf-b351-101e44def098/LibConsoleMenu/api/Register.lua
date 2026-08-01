-- RegisterAddonPanel / RegisterOptionControls — panel and control registration (console only).
-- Nested submenus compile to CT_SECTION with nested/popSection flags.
-- submenu icon = texture path (shown only when the row is not centered; tinted on selection).
-- centered submenus: chip textures normal / selected / disabled.
-- type = "header" / option.header become native inline list headers.
-- header align = "center" (options) | "left" (nav). Default center.
-- iconpicker: choices = path list, or texture + atlasSizeX/Y for a spritesheet.

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

LCM.panelData = LCM.panelData or {}
LCM.optionTables = LCM.optionTables or {}
LCM.compiledPanels = LCM.compiledPanels or {}

local function AddToIndexed(out, option)
	out[#out + 1] = option
end

-- pendingHeader is { text, align } from a preceding type = "header".
-- Controls may also set header / headerAlign (or align) directly.
local function ConsumeHeader(entry, pendingHeader)
	if entry.header then
		return entry.header, LCM.NormalizeHeaderAlign(entry.headerAlign or entry.align)
	end
	if pendingHeader then
		return pendingHeader.text, pendingHeader.align
	end
	return nil, nil
end

local function BuildChoiceItems(entry)
	local choices = entry.choices or {}
	local values = entry.choicesValues
	local items = {}
	local labelMap = {}
	for i = 1, #choices do
		local choice = choices[i]
		local name
		local value
		local tooltip
		if type(choice) == "table" then
			name = choice.name or choice.label
			value = choice.value
			if value == nil then
				value = choice.data
			end
			if value == nil then
				value = name
			end
			if name == nil then
				name = tostring(value)
			end
			tooltip = choice.tooltip
		else
			name = choice
			if values then
				value = values[i]
			else
				value = choice
			end
		end
		items[i] = { name = name, data = value, tooltip = tooltip }
		if value ~= nil then
			labelMap[value] = name
		end
	end
	return items, labelMap
end

local function ConvertSelector(entry, out, pendingHeader)
	local items, labelMap = BuildChoiceItems(entry)
	local getFunc = entry.getFunc
	local setFunc = entry.setFunc
	local header, headerAlign = ConsumeHeader(entry, pendingHeader)
	AddToIndexed(out, {
		type = LCM.CT_SELECTOR,
		label = entry.name,
		tooltip = entry.tooltip,
		default = entry.default,
		disable = entry.disabled,
		header = header,
		headerAlign = headerAlign,
		items = items,
		getFunction = function()
			if not getFunc then
				return items[1] and items[1].name
			end
			local value = getFunc()
			return labelMap[value] or value
		end,
		setFunction = function(_, name, item)
			if setFunc then
				setFunc(item and item.data or name)
			end
		end,
		popSection = entry._popSection,
	})
end

local function ConvertDropdown(entry, out, pendingHeader)
	local items, labelMap = BuildChoiceItems(entry)
	local getFunc = entry.getFunc
	local setFunc = entry.setFunc
	local header, headerAlign = ConsumeHeader(entry, pendingHeader)
	AddToIndexed(out, {
		type = LCM.CT_DROPDOWN,
		label = entry.name,
		tooltip = entry.tooltip,
		default = entry.default,
		disable = entry.disabled,
		header = header,
		headerAlign = headerAlign,
		items = items,
		align = entry.align,
		getFunction = function()
			if not getFunc then
				return items[1] and items[1].name
			end
			local value = getFunc()
			return labelMap[value] or value
		end,
		setFunction = function(_, name, item)
			if setFunc then
				setFunc(item and item.data or name)
			end
		end,
		popSection = entry._popSection,
	})
end

local function ConvertChecklist(entry, out, pendingHeader)
	local items = BuildChoiceItems(entry)
	local getFunc = entry.getFunc
	local setFunc = entry.setFunc
	local header, headerAlign = ConsumeHeader(entry, pendingHeader)
	local default = entry.default
	if type(default) ~= "table" then
		default = {}
	end
	AddToIndexed(out, {
		type = LCM.CT_CHECKLIST,
		label = entry.name,
		tooltip = entry.tooltip,
		default = default,
		disable = entry.disabled,
		header = header,
		headerAlign = headerAlign,
		items = items,
		maxSelections = entry.maxSelections,
		noSelectionText = entry.noSelectionText,
		multiSelectionTextFormatter = entry.multiSelectionTextFormatter,
		align = entry.align,
		getFunction = function()
			if not getFunc then
				return {}
			end
			local value = getFunc()
			if type(value) ~= "table" then
				return {}
			end
			return value
		end,
		setFunction = function(selectedValues)
			if setFunc then
				setFunc(selectedValues or {})
			end
		end,
		popSection = entry._popSection,
	})
end

local function ConvertDescription(entry, out, pendingHeader)
	local header, headerAlign = ConsumeHeader(entry, pendingHeader)
	if entry.title and entry.title ~= "" then
		AddToIndexed(out, {
			type = LCM.CT_LABEL,
			label = entry.title,
			tooltip = entry.tooltip,
			header = header,
			headerAlign = headerAlign,
			popSection = entry._popSection,
		})
		entry._popSection = nil
		header = nil
		headerAlign = nil
	end
	if entry.text and entry.text ~= "" then
		AddToIndexed(out, {
			type = LCM.CT_LABEL,
			label = entry.text,
			tooltip = entry.tooltip,
			header = header,
			headerAlign = headerAlign,
			popSection = entry._popSection,
		})
	end
end

local function ConvertIconPicker(entry, out, pendingHeader)
	local header, headerAlign = ConsumeHeader(entry, pendingHeader)
	local atlasEnd = entry.atlasEnd
	if not atlasEnd and entry.atlasSizeX and entry.atlasSizeY then
		atlasEnd = entry.atlasSizeX * entry.atlasSizeY
	end
	AddToIndexed(out, {
		type = LCM.CT_ICONPICKER,
		label = entry.name,
		tooltip = entry.tooltip,
		default = entry.default,
		disable = entry.disabled,
		header = header,
		headerAlign = headerAlign,
		items = entry.choices or entry.icons or entry.items,
		texture = entry.texture,
		atlasSizeX = entry.atlasSizeX,
		atlasSizeY = entry.atlasSizeY,
		atlasStart = entry.atlasStart or 1,
		atlasEnd = atlasEnd,
		atlasIndices = entry.atlasIndices,
		getFunction = entry.getFunc,
		setFunction = function(_, index)
			if entry.setFunc then
				entry.setFunc(index)
			end
		end,
		popSection = entry._popSection,
	})
end

local ConvertControls

local function ConvertSubmenu(entry, out, depth, needPop, pendingHeader)
	local header, headerAlign = ConsumeHeader(entry, pendingHeader)
	local section = {
		type = LCM.CT_SECTION,
		label = entry.name,
		tooltip = entry.tooltip,
		header = header,
		headerAlign = headerAlign,
		nested = depth > 0,
		popSection = needPop and depth > 0,
		centerSubmenu = entry.centerSubmenu,
		icon = entry.icon,
		disable = entry.disabled,
		onEnter = entry.onEnter,
		onExit = entry.onExit,
	}
	AddToIndexed(out, section)
	ConvertControls(entry.controls or {}, out, depth + 1)
	return true -- caller should pop before next sibling
end

ConvertControls = function(optionsTable, out, depth)
	out = out or {}
	depth = depth or 0
	local needPop = false
	local pendingHeader = nil

	for i = 1, #optionsTable do
		local entry = optionsTable[i]
		if entry then
			local entryType = entry.type
			if needPop then
				if entryType ~= "header" then
					entry._popSection = true
					needPop = false
				end
			end

			if entryType == "header" then
				pendingHeader = {
					text = entry.name,
					align = LCM.NormalizeHeaderAlign(entry.align),
				}
			elseif entryType == "submenu" then
				needPop = ConvertSubmenu(entry, out, depth, entry._popSection, pendingHeader)
				pendingHeader = nil
				entry._popSection = nil
			elseif entryType == "selector" then
				ConvertSelector(entry, out, pendingHeader)
				pendingHeader = nil
			elseif entryType == "dropdown" then
				ConvertDropdown(entry, out, pendingHeader)
				pendingHeader = nil
			elseif entryType == "checklist" then
				ConvertChecklist(entry, out, pendingHeader)
				pendingHeader = nil
			elseif entryType == "description" then
				ConvertDescription(entry, out, pendingHeader)
				pendingHeader = nil
			elseif entryType == "iconpicker" then
				ConvertIconPicker(entry, out, pendingHeader)
				pendingHeader = nil
			elseif entryType == "toggle" or entryType == "checkbox" then
				local header, headerAlign = ConsumeHeader(entry, pendingHeader)
				AddToIndexed(out, {
					type = LCM.CT_TOGGLE,
					label = entry.name,
					tooltip = entry.tooltip,
					default = entry.default,
					disable = entry.disabled,
					header = header,
					headerAlign = headerAlign,
					getFunction = entry.getFunc,
					setFunction = entry.setFunc,
					popSection = entry._popSection,
				})
				pendingHeader = nil
			elseif entryType == "slider" then
				local header, headerAlign = ConsumeHeader(entry, pendingHeader)
				AddToIndexed(out, {
					type = LCM.CT_SLIDER,
					label = entry.name,
					tooltip = entry.tooltip,
					default = entry.default,
					disable = entry.disabled,
					header = header,
					headerAlign = headerAlign,
					min = entry.min,
					max = entry.max,
					step = entry.step,
					bigStep = entry.bigStep,
					format = entry.decimals and ("%." .. tostring(entry.decimals) .. "f") or entry.format,
					unit = entry.unit,
					getFunction = entry.getFunc,
					setFunction = entry.setFunc,
					popSection = entry._popSection,
				})
				pendingHeader = nil
			elseif entryType == "colorpicker" then
				local header, headerAlign = ConsumeHeader(entry, pendingHeader)
				AddToIndexed(out, {
					type = LCM.CT_COLORPICKER,
					label = entry.name,
					tooltip = entry.tooltip,
					default = entry.default,
					disable = entry.disabled,
					header = header,
					headerAlign = headerAlign,
					getFunction = entry.getFunc,
					setFunction = entry.setFunc,
					popSection = entry._popSection,
				})
				pendingHeader = nil
			elseif entryType == "button" then
				local header, headerAlign = ConsumeHeader(entry, pendingHeader)
				AddToIndexed(out, {
					type = LCM.CT_BUTTON,
					label = entry.name,
					buttonText = entry.name,
					tooltip = entry.tooltip,
					disable = entry.disabled,
					header = header,
					headerAlign = headerAlign,
					clickHandler = entry.func,
					popSection = entry._popSection,
				})
				pendingHeader = nil
			elseif entryType == "editbox" then
				local header, headerAlign = ConsumeHeader(entry, pendingHeader)
				AddToIndexed(out, {
					type = LCM.CT_EDIT,
					label = entry.name,
					tooltip = entry.tooltip,
					default = entry.default,
					disable = entry.disabled,
					header = header,
					headerAlign = headerAlign,
					maxChars = entry.maxChars,
					textType = entry.textType,
					getFunction = entry.getFunc,
					setFunction = entry.setFunc,
					popSection = entry._popSection,
				})
				pendingHeader = nil
			end
		end
	end

	return out
end

local function BuildPanel(addonID)
	local panelData = LCM.panelData[addonID]
	local optionsTable = LCM.optionTables[addonID]
	if not panelData or not optionsTable then
		return
	end
	if LCM.compiledPanels[addonID] then
		return LCM.compiledPanels[addonID]
	end

	local settings = LCM:AddAddon(panelData.name, {
		allowDefaults = panelData.registerForDefaults,
		allowRefresh = panelData.registerForRefresh,
		defaultsFunction = panelData.resetFunc,
		author = panelData.author,
		version = panelData.version,
		centerSubmenus = panelData.centerSubmenus,
		collapseToggleLabels = panelData.collapseToggleLabels,
		collapseSliderLabels = panelData.collapseSliderLabels,
	})

	local compiled = ConvertControls(optionsTable, {}, 0)
	for i = 1, #compiled do
		settings:AddSetting(compiled[i])
	end

	LCM.compiledPanels[addonID] = settings
	return settings
end

-- addonID = unique string; panelData = { name, author, version, registerForDefaults, registerForRefresh, resetFunc, centerSubmenus, collapseToggleLabels, collapseSliderLabels, ... }
function LCM:RegisterAddonPanel(addonID, panelData)
	if not IsConsoleUI() then
		return
	end
	assert(type(addonID) == "string" and addonID ~= "", "RegisterAddonPanel: addonID required")
	assert(type(panelData) == "table" and panelData.name, "RegisterAddonPanel: panelData.name required")

	self.panelData[addonID] = panelData
	BuildPanel(addonID)
end

-- optionsTable = control list (toggle, slider, selector, dropdown, checklist, submenu, iconpicker, ...); checkbox is an alias for toggle
function LCM:RegisterOptionControls(addonID, optionsTable)
	if not IsConsoleUI() then
		return
	end
	assert(type(addonID) == "string" and addonID ~= "", "RegisterOptionControls: addonID required")
	assert(type(optionsTable) == "table", "RegisterOptionControls: optionsTable required")

	self.optionTables[addonID] = optionsTable
	BuildPanel(addonID)
end

-- Compile an options table without registering a panel.
function LCM:ConvertOptionControls(optionsTable)
	return ConvertControls(optionsTable or {}, {}, 0)
end
