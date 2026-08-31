-- CreateAddonMenu / AddonMenu:AddOptions - menu registration (console only).
-- Nested submenus compile to CT_SUBMENU with nested/popSubmenu/popAfterSubmenuIndex flags.
-- submenu icon = texture path (shown only when the row is not centered; tinted on selection).
-- centered submenus: chip textures normal / selected / disabled.
-- type = "section" stamps a list section title on the first child row (same page).
-- Nested author key on submenu/section is options (not controls).
-- align = "center" | "leftIndent" | "leftFlush" (default center).
--   leftIndent = nav icon column; leftFlush = content edge.
-- Supported: Dropdown/Checklist/Button/Edit = all three; Submenu = center|leftIndent;
--   other controls = center only. Unsupported values are clamped.
-- childrenAlign on menu / submenu sets the default for immediate children of that page.
-- iconpicker: choices = path list, or texture + atlasSizeX/Y for a spritesheet.
-- header on CreateAddonMenu / submenu = screen header.

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

LCM.menuData = LCM.menuData or {}

local function AddToIndexed(out, option)
	out[#out + 1] = option
end

-- pendingSection is { text, align } from a preceding type = "section".
local function ConsumePendingSection(pendingSection)
	if pendingSection then
		return pendingSection.text, pendingSection.align
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

local function ConvertSelector(entry, out, pendingSection)
	local items, labelMap = BuildChoiceItems(entry)
	local getFunc = entry.getFunc
	local setFunc = entry.setFunc
	local sectionTitle, sectionAlign = ConsumePendingSection(pendingSection)
	AddToIndexed(out, {
		type = LCM.CT_SELECTOR,
		label = entry.name,
		tooltip = entry.tooltip,
		default = entry.default,
		disable = entry.disabled,
		sectionTitle = sectionTitle,
		sectionAlign = sectionAlign,
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

local function ConvertDropdown(entry, out, pendingSection)
	local items, labelMap = BuildChoiceItems(entry)
	local getFunc = entry.getFunc
	local setFunc = entry.setFunc
	local sectionTitle, sectionAlign = ConsumePendingSection(pendingSection)
	local align = entry.align
	AddToIndexed(out, {
		type = LCM.CT_DROPDOWN,
		label = entry.name,
		tooltip = entry.tooltip,
		default = entry.default,
		disable = entry.disabled,
		sectionTitle = sectionTitle,
		sectionAlign = sectionAlign,
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

local function ConvertChecklist(entry, out, pendingSection)
	local items = BuildChoiceItems(entry)
	local getFunc = entry.getFunc
	local setFunc = entry.setFunc
	local sectionTitle, sectionAlign = ConsumePendingSection(pendingSection)
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
		sectionTitle = sectionTitle,
		sectionAlign = sectionAlign,
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

local function ConvertIconPicker(entry, out, pendingSection)
	local sectionTitle, sectionAlign = ConsumePendingSection(pendingSection)
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
		sectionTitle = sectionTitle,
		sectionAlign = sectionAlign,
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

local function ConvertSubmenu(entry, out, depth, needPop, pendingSection)
	local sectionTitle, sectionAlign = ConsumePendingSection(pendingSection)
	local submenu = {
		type = LCM.CT_SUBMENU,
		label = entry.name,
		tooltip = entry.tooltip,
		sectionTitle = sectionTitle,
		sectionAlign = sectionAlign,
		headerConfig = entry.header,
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

ConvertOptions = function(optionsTable, out, depth, initialPendingSection, initialClosedSubmenu)
	out = out or {}
	depth = depth or 0
	local closedSubmenu = initialClosedSubmenu
	local pendingSection = initialPendingSection
	optionsTable = optionsTable or {}

	for i = 1, #optionsTable do
		local entry = optionsTable[i]
		if entry then
			local entryType = entry.type

			if entryType == "section" then
				-- Compile children into the same `out` so popAfterSubmenuIndex stays valid.
				local sectionPending = {
					text = entry.name,
					align = entry.align,
				}
				local _, leftover, childClosed = ConvertOptions(
					entry.options or {},
					out,
					depth,
					sectionPending,
					closedSubmenu
				)
				pendingSection = leftover
				closedSubmenu = childClosed
			elseif entryType == "submenu"
				or entryType == "selector"
				or entryType == "dropdown"
				or entryType == "checklist"
				or entryType == "iconpicker"
				or entryType == "toggle"
				or entryType == "slider"
				or entryType == "colorpicker"
				or entryType == "button"
				or entryType == "editbox"
			then
				if closedSubmenu then
					entry._popAfterSubmenuIndex = closedSubmenu
					entry._popSubmenu = true
					closedSubmenu = nil
				end

				if entryType == "submenu" then
					closedSubmenu = ConvertSubmenu(entry, out, depth, entry._popSubmenu, pendingSection)
					pendingSection = nil
					entry._popSubmenu = nil
					entry._popAfterSubmenuIndex = nil
				elseif entryType == "selector" then
					ConvertSelector(entry, out, pendingSection)
					pendingSection = nil
				elseif entryType == "dropdown" then
					ConvertDropdown(entry, out, pendingSection)
					pendingSection = nil
				elseif entryType == "checklist" then
					ConvertChecklist(entry, out, pendingSection)
					pendingSection = nil
				elseif entryType == "iconpicker" then
					ConvertIconPicker(entry, out, pendingSection)
					pendingSection = nil
				elseif entryType == "toggle" then
					local sectionTitle, sectionAlign = ConsumePendingSection(pendingSection)
					AddToIndexed(out, {
						type = LCM.CT_TOGGLE,
						label = entry.name,
						tooltip = entry.tooltip,
						default = entry.default,
						disable = entry.disabled,
						sectionTitle = sectionTitle,
						sectionAlign = sectionAlign,
						getFunction = entry.getFunc,
						setFunction = entry.setFunc,
						togglePreset = entry.preset,
						toggleValues = entry.values,
						popSubmenu = entry._popSubmenu,
						popAfterSubmenuIndex = entry._popAfterSubmenuIndex,
					})
					pendingSection = nil
				elseif entryType == "slider" then
					local sectionTitle, sectionAlign = ConsumePendingSection(pendingSection)
					AddToIndexed(out, {
						type = LCM.CT_SLIDER,
						label = entry.name,
						tooltip = entry.tooltip,
						default = entry.default,
						disable = entry.disabled,
						sectionTitle = sectionTitle,
						sectionAlign = sectionAlign,
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
					pendingSection = nil
				elseif entryType == "colorpicker" then
					local sectionTitle, sectionAlign = ConsumePendingSection(pendingSection)
					AddToIndexed(out, {
						type = LCM.CT_COLORPICKER,
						label = entry.name,
						tooltip = entry.tooltip,
						default = entry.default,
						disable = entry.disabled,
						sectionTitle = sectionTitle,
						sectionAlign = sectionAlign,
						getFunction = entry.getFunc,
						setFunction = entry.setFunc,
						popSubmenu = entry._popSubmenu,
						popAfterSubmenuIndex = entry._popAfterSubmenuIndex,
					})
					pendingSection = nil
				elseif entryType == "button" then
					local sectionTitle, sectionAlign = ConsumePendingSection(pendingSection)
					local align = entry.align
					AddToIndexed(out, {
						type = LCM.CT_BUTTON,
						label = entry.name,
						buttonText = entry.name,
						tooltip = entry.tooltip,
						disable = entry.disabled,
						sectionTitle = sectionTitle,
						sectionAlign = sectionAlign,
						align = align,
						clickHandler = entry.func,
						popSubmenu = entry._popSubmenu,
						popAfterSubmenuIndex = entry._popAfterSubmenuIndex,
					})
					pendingSection = nil
				elseif entryType == "editbox" then
					local sectionTitle, sectionAlign = ConsumePendingSection(pendingSection)
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
						sectionTitle = sectionTitle,
						sectionAlign = sectionAlign,
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
					pendingSection = nil
				end
			end
		end
	end

	return out, pendingSection, closedSubmenu
end

-- menuId = unique string (folder / Addon.name); menuData = { title, author, version, category, enableDefaults, enableReset, resetFunc, childrenAlign, collapseToggleLabels, collapseSliderLabels, header, ... }
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
		header = menuData.header,
	})
end

-- Append author options (callable again). Nested submenu/section children use options = { ... }.
-- A trailing empty type = "section" is kept for the next AddOptions call (_pendingSection).
function LCM.AddonMenu:AddOptions(optionsTable)
	assert(type(optionsTable) == "table", "AddOptions: optionsTable required")
	local compiled, pendingSection = ConvertOptions(optionsTable, {}, 0, self._pendingSection)
	self._pendingSection = pendingSection
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
