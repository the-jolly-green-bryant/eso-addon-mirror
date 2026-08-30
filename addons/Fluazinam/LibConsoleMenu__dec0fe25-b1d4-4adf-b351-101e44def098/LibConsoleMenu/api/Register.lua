-- CreateAddonMenu / AddonMenu:AddOptions - menu registration (console only).
-- Nested submenus compile to CT_SUBMENU with nested/popSubmenu/popAfterSubmenuIndex flags.
-- submenu icon = texture path (shown only when the row is not centered; tinted on selection).
-- centered submenus: chip textures normal / selected / disabled.
-- type = "header" / type = "section" become native inline list headers.
-- type = "section" is authoring sugar: expands to a header + its options (same page).
-- Nested author key on submenu/section is options (not controls).
-- align = "center" | "leftIndent" | "leftFlush" (default center).
--   leftIndent = nav icon column; leftFlush = content edge.
-- Supported: Dropdown/Checklist/Button/Edit/Header = all three; Submenu = center|leftIndent;
--   other controls = center only. Unsupported values are clamped.
-- childrenAlign on menu / submenu sets the default for immediate children of that page.
-- iconpicker: choices = path list, or texture + atlasSizeX/Y for a spritesheet.

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

LCM.menuData = LCM.menuData or {}

local function AddToIndexed(out, option)
	out[#out + 1] = option
end

-- Expand type = "section" into a pending-style header entry + children (same page).
-- Nested sections and sections inside submenu.options are expanded recursively.
-- Does not mutate the author table (submenus get a shallow copy with new options).
local function ExpandSections(optionsTable)
	local out = {}
	if not optionsTable then
		return out
	end

	for i = 1, #optionsTable do
		local entry = optionsTable[i]
		if entry then
			if entry.type == "section" then
				out[#out + 1] = {
					type = "header",
					name = entry.name,
					align = entry.align,
				}
				local children = ExpandSections(entry.options or {})
				for j = 1, #children do
					out[#out + 1] = children[j]
				end
			elseif entry.type == "submenu" then
				local copy = {}
				for key, value in pairs(entry) do
					copy[key] = value
				end
				copy.options = ExpandSections(entry.options or {})
				out[#out + 1] = copy
			else
				out[#out + 1] = entry
			end
		end
	end

	return out
end

-- pendingHeader is { text, align } from a preceding type = "header" / section.
local function ConsumePendingHeader(pendingHeader)
	if pendingHeader then
		return pendingHeader.text, pendingHeader.align
	end
	return nil, nil
end

local function BuildChoiceItems(entry)
	local choices = entry.choices or {}
	local items = {}
	local labelMap = {}
	for i = 1, #choices do
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

local function ConvertSelector(entry, out, pendingHeader)
	local items, labelMap = BuildChoiceItems(entry)
	local getFunc = entry.getFunc
	local setFunc = entry.setFunc
	local header, headerAlign = ConsumePendingHeader(pendingHeader)
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
		popSubmenu = entry._popSubmenu,
		popAfterSubmenuIndex = entry._popAfterSubmenuIndex,
	})
end

local function ConvertDropdown(entry, out, pendingHeader)
	local items, labelMap = BuildChoiceItems(entry)
	local getFunc = entry.getFunc
	local setFunc = entry.setFunc
	local header, headerAlign = ConsumePendingHeader(pendingHeader)
	local align = entry.align
	AddToIndexed(out, {
		type = LCM.CT_DROPDOWN,
		label = entry.name,
		tooltip = entry.tooltip,
		default = entry.default,
		disable = entry.disabled,
		header = header,
		headerAlign = headerAlign,
		items = items,
		align = align,
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
		popSubmenu = entry._popSubmenu,
		popAfterSubmenuIndex = entry._popAfterSubmenuIndex,
	})
end

local function ConvertChecklist(entry, out, pendingHeader)
	local items = BuildChoiceItems(entry)
	local getFunc = entry.getFunc
	local setFunc = entry.setFunc
	local header, headerAlign = ConsumePendingHeader(pendingHeader)
	local align = entry.align
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
		selectionTextFormat = entry.selectionTextFormat,
		align = align,
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
		popSubmenu = entry._popSubmenu,
		popAfterSubmenuIndex = entry._popAfterSubmenuIndex,
	})
end

local function ConvertIconPicker(entry, out, pendingHeader)
	local header, headerAlign = ConsumePendingHeader(pendingHeader)
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
		items = entry.choices,
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
		popSubmenu = entry._popSubmenu,
		popAfterSubmenuIndex = entry._popAfterSubmenuIndex,
	})
end

local ConvertOptions

local function ConvertSubmenu(entry, out, depth, needPop, pendingHeader)
	local header, headerAlign = ConsumePendingHeader(pendingHeader)
	local submenu = {
		type = LCM.CT_SUBMENU,
		label = entry.name,
		tooltip = entry.tooltip,
		header = header,
		headerAlign = headerAlign,
		screenHeaderConfig = entry.screenHeader,
		nested = depth > 0,
		popSubmenu = needPop and depth > 0,
		popAfterSubmenuIndex = entry._popAfterSubmenuIndex,
		align = entry.align,
		childrenAlign = entry.childrenAlign,
		icon = entry.icon,
		disable = entry.disabled,
		onEnter = entry.onEnter,
		onExit = entry.onExit,
	}
	AddToIndexed(out, submenu)
	local submenuIndex = #out
	ConvertOptions(entry.options or {}, out, depth + 1)
	-- Next sibling resumes under this submenu's parent (index into compiled list).
	return submenuIndex
end

ConvertOptions = function(optionsTable, out, depth, initialPendingHeader)
	out = out or {}
	depth = depth or 0
	local closedSubmenu = nil
	local pendingHeader = initialPendingHeader
	optionsTable = ExpandSections(optionsTable or {})

	for i = 1, #optionsTable do
		local entry = optionsTable[i]
		if entry then
			local entryType = entry.type
			if closedSubmenu and entryType ~= "header" then
				entry._popAfterSubmenuIndex = closedSubmenu
				entry._popSubmenu = true
				closedSubmenu = nil
			end

			if entryType == "header" then
				pendingHeader = {
					text = entry.name,
					align = entry.align,
				}
			elseif entryType == "submenu" then
				closedSubmenu = ConvertSubmenu(entry, out, depth, entry._popSubmenu, pendingHeader)
				pendingHeader = nil
				entry._popSubmenu = nil
				entry._popAfterSubmenuIndex = nil
			elseif entryType == "selector" then
				ConvertSelector(entry, out, pendingHeader)
				pendingHeader = nil
			elseif entryType == "dropdown" then
				ConvertDropdown(entry, out, pendingHeader)
				pendingHeader = nil
			elseif entryType == "checklist" then
				ConvertChecklist(entry, out, pendingHeader)
				pendingHeader = nil
			elseif entryType == "iconpicker" then
				ConvertIconPicker(entry, out, pendingHeader)
				pendingHeader = nil
			elseif entryType == "toggle" then
				local header, headerAlign = ConsumePendingHeader(pendingHeader)
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
					togglePreset = entry.preset,
					toggleValues = entry.values,
					popSubmenu = entry._popSubmenu,
					popAfterSubmenuIndex = entry._popAfterSubmenuIndex,
				})
				pendingHeader = nil
			elseif entryType == "slider" then
				local header, headerAlign = ConsumePendingHeader(pendingHeader)
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
					popSubmenu = entry._popSubmenu,
					popAfterSubmenuIndex = entry._popAfterSubmenuIndex,
				})
				pendingHeader = nil
			elseif entryType == "colorpicker" then
				local header, headerAlign = ConsumePendingHeader(pendingHeader)
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
					popSubmenu = entry._popSubmenu,
					popAfterSubmenuIndex = entry._popAfterSubmenuIndex,
				})
				pendingHeader = nil
			elseif entryType == "button" then
				local header, headerAlign = ConsumePendingHeader(pendingHeader)
				local align = entry.align
				AddToIndexed(out, {
					type = LCM.CT_BUTTON,
					label = entry.name,
					buttonText = entry.name,
					tooltip = entry.tooltip,
					disable = entry.disabled,
					header = header,
					headerAlign = headerAlign,
					align = align,
					clickHandler = entry.func,
					popSubmenu = entry._popSubmenu,
					popAfterSubmenuIndex = entry._popAfterSubmenuIndex,
				})
				pendingHeader = nil
			elseif entryType == "editbox" then
				local header, headerAlign = ConsumePendingHeader(pendingHeader)
				local align = entry.align
				local label = entry.name
				if label == "" then
					label = nil
				end
				AddToIndexed(out, {
					type = LCM.CT_EDITBOX,
					label = label,
					tooltip = entry.tooltip,
					default = entry.default,
					disable = entry.disabled,
					header = header,
					headerAlign = headerAlign,
					align = align,
					maxInputCharacters = entry.maxInputCharacters,
					textType = entry.textType,
					multiLine = entry.multiLine,
					placeholderText = entry.placeholderText,
					isPassword = entry.isPassword,
					getFunction = entry.getFunc,
					setFunction = entry.setFunc,
					popSubmenu = entry._popSubmenu,
					popAfterSubmenuIndex = entry._popAfterSubmenuIndex,
				})
				pendingHeader = nil
			end
		end
	end

	return out, pendingHeader
end

-- menuId = unique string (folder / Addon.name); menuData = { title, author, version, category, enableDefaults, enableReset, resetFunc, childrenAlign, collapseToggleLabels, collapseSliderLabels, ... }
-- category = MOD_BROWSER_CATEGORY_TYPE_* or string alias (e.g. "UTILITY"); drives Add-ons submenu icon.
function LCM:CreateAddonMenu(menuId, menuData)
	if not IsConsoleUI() then
		return
	end
	assert(type(menuId) == "string" and menuId ~= "", "CreateAddonMenu: menuId required")
	assert(type(menuData) == "table" and menuData.title, "CreateAddonMenu: menuData.title required")

	self.menuData[menuId] = menuData

	return self:_CreateMenuInstance(menuData.title, {
		menuId = menuId,
		enableDefaults = menuData.enableDefaults,
		enableReset = menuData.enableReset,
		resetFunction = menuData.resetFunc,
		author = menuData.author,
		version = menuData.version,
		category = menuData.category,
		childrenAlign = menuData.childrenAlign,
		collapseToggleLabels = menuData.collapseToggleLabels,
		collapseSliderLabels = menuData.collapseSliderLabels,
		screenHeader = menuData.screenHeader,
	})
end

-- Append author options (callable again). Nested submenu/section children use options = { ... }.
-- A trailing type = "header" with no row in the same batch is kept for the next AddOptions call.
function LCM.AddonMenu:AddOptions(optionsTable)
	assert(type(optionsTable) == "table", "AddOptions: optionsTable required")
	local compiled, pendingHeader = ConvertOptions(optionsTable, {}, 0, self._pendingHeader)
	self._pendingHeader = pendingHeader
	if #compiled > 0 then
		self:AddControls(compiled)
	end
	return self
end

-- Compile an options table without attaching to a menu (advanced).
function LCM:ConvertOptions(optionsTable)
	local out = ConvertOptions(optionsTable or {}, {}, 0)
	return out
end
