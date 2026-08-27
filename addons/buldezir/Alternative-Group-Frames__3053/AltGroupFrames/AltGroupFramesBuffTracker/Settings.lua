-------------------------------------
--Settings Menu--
-------------------------------------
ALTGF_BUFF_TRACKER.initializeAddonMenu = function()
	local LAM2 = LibAddonMenu2
	local SETTINGS = ALTGF_BUFF_TRACKER.SETTINGS
	local ACCOUNT_SETTINGS = ALTGF_BUFF_TRACKER.ACCOUNT_SETTINGS

	-- Build predefined ID list (used for TRACK cleanup)
	local abilityIdChoices = {}
	for _, buff in ipairs(ALTGF_BUFF_TRACKER.BUFFS) do
		abilityIdChoices[#abilityIdChoices + 1] = buff.id
	end

	-- clear old/unused abilityId settings (if ALTGF_BUFF_TRACKER.BUFFS or CUSTOM_IDS changed)
	for abilityId, _ in pairs(SETTINGS.TRACK) do
		local inPredefined = ZO_IndexOfElementInNumericallyIndexedTable(abilityIdChoices, abilityId) ~= nil
		local inCustom = ZO_IndexOfElementInNumericallyIndexedTable(ACCOUNT_SETTINGS.CUSTOM_IDS, abilityId) ~= nil
		if not inPredefined and not inCustom then
			SETTINGS.TRACK[abilityId] = nil
		end
	end

	LAM2:RegisterAddonPanel("ALTGF_BuffTrackerSettings", {
		type = "panel",
		name = "Alternative Group Frames Buffs",
		displayName = "Alternative Group Frames Buff Tracker",
		author = "|c943810BulDeZir|r, Glande-Pas",
		version = string.format("|c00FF00%s|r", 1),
	})

	local reloadNeeded = false

	local OptionControls = {
		{
			type = "description",
			text = "This module settings are Character-wide", -- \n|cff0000This module is in BETA state and may have bugs|r
		},
		{
			type = "checkbox",
			name = "Enabled",
			requiresReload = true,
			default = true,
			getFunc = function()
				return SETTINGS.ENABLED
			end,
			setFunc = function(newValue)
				SETTINGS.ENABLED = newValue
				if SETTINGS.ENABLED then
					ALTGF_BUFF_TRACKER.Initialize()
				end
			end,
		},
		{
			type = "checkbox",
			name = "Borders inside frame",
			tooltip = "When enabled, border bars are drawn inside the frame's own visual area (the frame grows taller). Icons always occupy the gap to the right of the frame.",
			disabled = function()
				return not SETTINGS.ENABLED
			end,
			default = false,
			getFunc = function()
				return SETTINGS.INSIDE_FRAME
			end,
			setFunc = function(newValue)
				SETTINGS.INSIDE_FRAME = newValue
				ALT_GROUP_FRAMES:RefreshView(true)
			end,
		},
		{
			type = "divider",
		},
		{
			type = "slider",
			name = "Border bars",
			tooltip = "Number of cooldown border bars shown below each unit frame.",
			min = 0,
			max = 3,
			step = 1,
			disabled = function()
				return not SETTINGS.ENABLED
			end,
			default = 1,
			getFunc = function()
				return SETTINGS.NUM_BORDERS
			end,
			setFunc = function(newValue)
				SETTINGS.NUM_BORDERS = newValue
				ALT_GROUP_FRAMES:ForEach(function(UnitFrame)
					if UnitFrame.borderCooldowns then
						for i = newValue + 1, 3 do
							if UnitFrame.borderCooldowns[i] then
								UnitFrame.borderCooldowns[i]:Reset()
							end
						end
					end
				end)
				ALT_GROUP_FRAMES:RefreshView(true)
			end,
		},
		{
			type = "colorpicker",
			name = "Border 1 color",
			disabled = function()
				return not SETTINGS.ENABLED
			end,
			default = function()
				return ZO_ColorDef:New(unpack(SETTINGS.BORDER_COLORS[1]))
			end,
			getFunc = function()
				return unpack(SETTINGS.BORDER_COLORS[1])
			end,
			setFunc = function(...)
				SETTINGS.BORDER_COLORS[1] = { ... }
				ALT_GROUP_FRAMES:ForEach(function(UnitFrame)
					if UnitFrame.borderCooldowns and UnitFrame.borderCooldowns[1] then
						UnitFrame.borderCooldowns[1]:SetColor(unpack(SETTINGS.BORDER_COLORS[1]))
					end
				end)
			end,
		},
		{
			type = "colorpicker",
			name = "Border 2 color",
			disabled = function()
				return not SETTINGS.ENABLED
			end,
			default = function()
				return ZO_ColorDef:New(unpack(SETTINGS.BORDER_COLORS[2]))
			end,
			getFunc = function()
				return unpack(SETTINGS.BORDER_COLORS[2])
			end,
			setFunc = function(...)
				SETTINGS.BORDER_COLORS[2] = { ... }
				ALT_GROUP_FRAMES:ForEach(function(UnitFrame)
					if UnitFrame.borderCooldowns and UnitFrame.borderCooldowns[2] then
						UnitFrame.borderCooldowns[2]:SetColor(unpack(SETTINGS.BORDER_COLORS[2]))
					end
				end)
			end,
		},
		{
			type = "colorpicker",
			name = "Border 3 color",
			disabled = function()
				return not SETTINGS.ENABLED
			end,
			default = function()
				return ZO_ColorDef:New(unpack(SETTINGS.BORDER_COLORS[3]))
			end,
			getFunc = function()
				return unpack(SETTINGS.BORDER_COLORS[3])
			end,
			setFunc = function(...)
				SETTINGS.BORDER_COLORS[3] = { ... }
				ALT_GROUP_FRAMES:ForEach(function(UnitFrame)
					if UnitFrame.borderCooldowns and UnitFrame.borderCooldowns[3] then
						UnitFrame.borderCooldowns[3]:SetColor(unpack(SETTINGS.BORDER_COLORS[3]))
					end
				end)
			end,
		},
		{
			type = "slider",
			name = "Frame border thickness",
			min = 2,
			max = 8,
			step = 1,
			disabled = function()
				return not SETTINGS.ENABLED
			end,
			default = function()
				return 4
			end,
			getFunc = function()
				return zo_round(SETTINGS.BORDER_THICK)
			end,
			setFunc = function(newValue)
				SETTINGS.BORDER_THICK = zo_round(newValue)
				ALT_GROUP_FRAMES:ForEach(function(UnitFrame)
					if UnitFrame.borderCooldowns then
						for _, border in ipairs(UnitFrame.borderCooldowns) do
							border:SetThickness(SETTINGS.BORDER_THICK)
						end
					end
				end)
				ALT_GROUP_FRAMES:RefreshView(true)
			end,
		},
		{
			type = "checkbox",
			name = "Stack borders",
			tooltip = "When enabled, border bars are drawn on top of each other for same-location different-color tacking",
			disabled = function()
				return not SETTINGS.ENABLED
			end,
			default = false,
			getFunc = function()
				return SETTINGS.STACK_BORDERS
			end,
			setFunc = function(newValue)
				SETTINGS.STACK_BORDERS = newValue
				ALT_GROUP_FRAMES:RefreshView(true)
			end,
		},
		{
			type = "slider",
			name = "Icon duration font size",
			min = 8,
			max = 24,
			step = 1,
			disabled = function()
				return not SETTINGS.ENABLED
			end,
			default = 14,
			getFunc = function()
				return SETTINGS.FONT_SIZE
			end,
			setFunc = function(newValue)
				SETTINGS.FONT_SIZE = newValue
				BUFF_DEBUFF:UpdateAllContainerObjects()
			end,
		},
		{
			type = "header",
			name = "Buffs, debuffs, cooldowns to track",
		},
	}

	local customRowControls = {}
	local currentFilter = ""
	local CUSTOM_ROW_H = 30
	local CUSTOM_PAD = 2
	local BUFF_HDR_H = 20
	local ApplyFilter
	local LayoutBuffList

	local filterEditboxData = {
		type = "editbox",
		name = "Filter",
		isExtraWide = true,
		reference = "ALTGF_FilterEditbox",
		getFunc = function()
			return currentFilter
		end,
		setFunc = function(text)
			ApplyFilter(text)
		end,
	}
	table.insert(OptionControls, filterEditboxData)

	-- Buff list: one custom LAM control owns all rows so we can re-anchor on filter
	local buffListControl
	local buffRowControls = {}
	local buffHdrControls = {}

	local DROPDOWN_ROW_H = 30

	-- Labels for each assignment key, in order they appear in dropdowns
	local ASSIGNMENT_OPTIONS = {
		{ label = "None", key = nil },
		{ label = "Icons", key = "icons" },
		{ label = "Border 1", key = "border1" },
		{ label = "Border 2", key = "border2" },
		{ label = "Border 3", key = "border3" },
	}

	local function keyToLabel(key)
		for _, opt in ipairs(ASSIGNMENT_OPTIONS) do
			if opt.key == key then
				return opt.label
			end
		end
		return ASSIGNMENT_OPTIONS[0].label
	end

	local function greyRow(iconTex, nameLabel, greyed)
		local c = greyed and 0.5 or 1
		iconTex:SetColor(c, c, c, 1)
		nameLabel:SetColor(c, c, c, 1)
	end

	local function populateComboBox(comboBox, capturedId, iconTex, nameLabel)
		comboBox:ClearItems()
		local currentKey = SETTINGS.TRACK[capturedId]
		for _, opt in ipairs(ASSIGNMENT_OPTIONS) do
			local optKey = opt.key
			local entry = comboBox:CreateItemEntry(opt.label, function()
				if optKey then
					ALTGF_BUFF_TRACKER.startTracking(capturedId, optKey)
				else
					ALTGF_BUFF_TRACKER.stopTracking(capturedId)
				end
				greyRow(iconTex, nameLabel, optKey == nil)
				ALT_GROUP_FRAMES:RefreshView(true)
			end)
			comboBox:AddItem(entry)
		end
		comboBox:SetSelectedItemText(keyToLabel(currentKey))
		greyRow(iconTex, nameLabel, currentKey == nil)
	end

	LayoutBuffList = function(filter)
		if not buffListControl then
			return
		end

		-- First pass: which categories have at least one matching buff
		local catVisible = {}
		for _, buff in ipairs(ALTGF_BUFF_TRACKER.BUFFS) do
			if
				filter == ""
				or zo_strformat(SI_UNIT_NAME, GetAbilityName(buff.id)):lower():find(filter, 1, true) ~= nil
			then
				catVisible[buff.cat] = true
			end
		end

		-- Second pass: re-anchor visible controls into a tight chain, collapse hidden ones
		local prevCtrl = nil
		local totalH = 0
		local seenCat = {}

		for _, buff in ipairs(ALTGF_BUFF_TRACKER.BUFFS) do
			local cat = buff.cat
			if not seenCat[cat] then
				seenCat[cat] = true
				local hdr = buffHdrControls[cat]
				if hdr then
					if catVisible[cat] then
						hdr:ClearAnchors()
						hdr:SetAnchor(
							TOPLEFT,
							prevCtrl or buffListControl,
							prevCtrl and BOTTOMLEFT or TOPLEFT,
							0,
							prevCtrl and CUSTOM_PAD or 0
						)
						hdr:SetHeight(BUFF_HDR_H)
						hdr:SetHidden(false)
						prevCtrl = hdr
						totalH = totalH + BUFF_HDR_H + CUSTOM_PAD
					else
						hdr:SetHeight(0)
						hdr:SetHidden(true)
					end
				end
			end

			local rowData = buffRowControls[buff.id]
			if rowData then
				local visible = filter == ""
					or zo_strformat(SI_UNIT_NAME, GetAbilityName(buff.id)):lower():find(filter, 1, true) ~= nil
				if visible then
					rowData.row:ClearAnchors()
					rowData.row:SetAnchor(
						TOPLEFT,
						prevCtrl or buffListControl,
						prevCtrl and BOTTOMLEFT or TOPLEFT,
						0,
						prevCtrl and CUSTOM_PAD or 0
					)
					rowData.row:SetHeight(DROPDOWN_ROW_H)
					rowData.row:SetHidden(false)
					prevCtrl = rowData.row
					totalH = totalH + DROPDOWN_ROW_H + CUSTOM_PAD
				else
					rowData.row:SetHeight(0)
					rowData.row:SetHidden(true)
				end
			end
		end

		buffListControl:SetHeight(math.max(1, totalH))
	end

	local function BuildBuffList()
		if not buffListControl then
			return
		end

		local wm = WINDOW_MANAGER
		local panelWidth = buffListControl:GetWidth()

		-- Build name→count and suffix lookup; suffix only applied on actual collisions
		local nameCount = {}
		local suffixById = {}
		for _, buff in ipairs(ALTGF_BUFF_TRACKER.BUFFS) do
			local n = zo_strformat(SI_UNIT_NAME, GetAbilityName(buff.id))
			if n ~= "" then
				nameCount[n] = (nameCount[n] or 0) + 1
			end
			if buff.suffix then
				suffixById[buff.id] = buff.suffix
			end
		end
		local function displayName(id)
			local n = zo_strformat(SI_UNIT_NAME, GetAbilityName(id))
			if n == "" then
				return "[" .. id .. "]"
			end
			if suffixById[id] and nameCount[n] and nameCount[n] > 1 then
				return n .. " (" .. suffixById[id] .. ")"
			end
			return n
		end

		-- Create one header label per category
		local seenCat = {}
		for _, buff in ipairs(ALTGF_BUFF_TRACKER.BUFFS) do
			if not seenCat[buff.cat] then
				seenCat[buff.cat] = true
				if not buffHdrControls[buff.cat] then
					local hdr = wm:CreateControl(nil, buffListControl, CT_LABEL)
					hdr:SetFont("ZoFontWinH4")
					hdr:SetColor(0.9, 0.9, 0.6, 1)
					hdr:SetWidth(panelWidth)
					hdr:SetText(buff.cat)
					hdr:SetVerticalAlignment(TEXT_ALIGN_CENTER)
					buffHdrControls[buff.cat] = hdr
				end
			end
		end

		-- Create one row per buff
		for _, buff in ipairs(ALTGF_BUFF_TRACKER.BUFFS) do
			local abilityId = buff.id
			if not buffRowControls[abilityId] then
				local row = wm:CreateControl(nil, buffListControl, CT_CONTROL)

				local iconTex = wm:CreateControl(nil, row, CT_TEXTURE)
				iconTex:SetDimensions(DROPDOWN_ROW_H, DROPDOWN_ROW_H)
				iconTex:SetTexture(ALTGF_BUFF_TRACKER.iconOverrides[abilityId] or GetAbilityIcon(abilityId))
				iconTex:SetAnchor(LEFT, row, LEFT, 2, 0)

				local nameLabel = wm:CreateControl(nil, row, CT_LABEL)
				nameLabel:SetFont("ZoFontGame")
				nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
				nameLabel:SetAnchor(LEFT, iconTex, RIGHT, 6, 0)
				nameLabel:SetText(displayName(abilityId))

				local comboBoxCtrl = wm:CreateControlFromVirtual("ALTGF_BuffCombo" .. abilityId, row, "ZO_ComboBox")
				comboBoxCtrl:SetDimensions(130, DROPDOWN_ROW_H)
				comboBoxCtrl:SetAnchor(RIGHT, row, RIGHT, 0, 0)

				buffRowControls[abilityId] =
					{ row = row, iconTex = iconTex, nameLabel = nameLabel, comboBoxCtrl = comboBoxCtrl }
			end

			-- Refresh state (also called on panel re-open)
			local rowData = buffRowControls[abilityId]
			local capturedId = abilityId
			local comboBox = ZO_ComboBox_ObjectFromContainer(rowData.comboBoxCtrl)
			populateComboBox(comboBox, capturedId, rowData.iconTex, rowData.nameLabel)

			rowData.row:SetWidth(panelWidth)
		end

		LayoutBuffList(currentFilter)
	end

	ApplyFilter = function(text)
		currentFilter = text and text:lower() or ""
		LayoutBuffList(currentFilter)
		for abilityId, row in pairs(customRowControls) do
			local name = zo_strformat(SI_UNIT_NAME, GetAbilityName(abilityId))
			local visible = currentFilter == "" or name:lower():find(currentFilter, 1, true) ~= nil
			row:SetHeight(visible and CUSTOM_ROW_H or 0)
			row:SetHidden(not visible)
		end
	end

	table.insert(OptionControls, {
		type = "custom",
		minHeight = 0,
		maxHeight = 4000,
		createFunc = function(ctrl)
			buffListControl = ctrl
			BuildBuffList()
		end,
	})

	-- Custom section
	table.insert(OptionControls, { type = "header", name = "Custom" })
	table.insert(OptionControls, {
		type = "button",
		name = "Reload UI",
		reference = "ALTGF_ReloadUIBtn",
		tooltip = "Custom IDs added since the last reload are not yet tracked. Click to reload.",
		disabled = function()
			return not reloadNeeded
		end,
		func = function()
			ReloadUI()
		end,
		width = "half",
	})

	local customControl, addLabel, addEditbox
	local customRows = {}

	local function RefreshCustomList()
		if not customControl then
			return
		end

		for _, row in ipairs(customRows) do
			row:SetHidden(true)
			row:ClearAnchors()
		end
		customRowControls = {}

		local wm = WINDOW_MANAGER
		local panelWidth = customControl:GetWidth()
		local prevControl = addLabel

		for i, abilityId in ipairs(ACCOUNT_SETTINGS.CUSTOM_IDS) do
			local row = customRows[i]
			if not row then
				row = wm:CreateControl(nil, customControl, CT_CONTROL)

				local iconTex = wm:CreateControl(nil, row, CT_TEXTURE)
				iconTex:SetDimensions(CUSTOM_ROW_H, CUSTOM_ROW_H)
				iconTex:SetAnchor(LEFT, row, LEFT, 0, 0)
				row.iconTex = iconTex

				local nameLabel = wm:CreateControl(nil, row, CT_LABEL)
				nameLabel:SetAnchor(LEFT, iconTex, RIGHT, 4, 0)
				nameLabel:SetAnchor(RIGHT, row, RIGHT, -(130 + 4 + 70 + 4), 0)
				nameLabel:SetFont("ZoFontGame")
				nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
				row.nameLabel = nameLabel

				local comboBoxCtrl = wm:CreateControlFromVirtual("ALTGF_CustomCombo" .. abilityId, row, "ZO_ComboBox")
				comboBoxCtrl:SetDimensions(130, CUSTOM_ROW_H)
				comboBoxCtrl:SetAnchor(RIGHT, row, RIGHT, -(70 + 4), 0)
				row.comboBoxCtrl = comboBoxCtrl

				local removeBtn = wm:CreateControlFromVirtual(nil, row, "ZO_DefaultButton")
				removeBtn:SetDimensions(70, CUSTOM_ROW_H - 2)
				removeBtn:SetAnchor(RIGHT, row, RIGHT, 0, 0)
				removeBtn:SetText("Remove")
				row.removeBtn = removeBtn

				customRows[i] = row
			end

			local name = zo_strformat(SI_UNIT_NAME, GetAbilityName(abilityId))
			local icon = ALTGF_BUFF_TRACKER.iconOverrides[abilityId] or GetAbilityIcon(abilityId)
			local known = name ~= ""
			row.nameLabel:SetText(known and name or ("[" .. abilityId .. "]"))
			row.iconTex:SetTexture(known and icon or "EsoUI/Art/Icons/icon_missing.dds")

			local capturedId = abilityId
			local comboBox = ZO_ComboBox_ObjectFromContainer(row.comboBoxCtrl)
			populateComboBox(comboBox, capturedId, row.iconTex, row.nameLabel)

			row.removeBtn:SetHandler("OnClicked", function()
				SETTINGS.TRACK[capturedId] = nil
				for j, id in ipairs(ACCOUNT_SETTINGS.CUSTOM_IDS) do
					if id == capturedId then
						table.remove(ACCOUNT_SETTINGS.CUSTOM_IDS, j)
						break
					end
				end
				RefreshCustomList()
				ALT_GROUP_FRAMES:RefreshView(true)
			end)

			row:SetHeight(CUSTOM_ROW_H)
			row:SetWidth(panelWidth)
			row:SetAnchor(TOPLEFT, prevControl, BOTTOMLEFT, 0, CUSTOM_PAD)
			row:SetHidden(false)
			prevControl = row
			customRowControls[abilityId] = row
		end

		if currentFilter ~= "" then
			for abilityId, row in pairs(customRowControls) do
				local name = zo_strformat(SI_UNIT_NAME, GetAbilityName(abilityId))
				local visible = name:lower():find(currentFilter, 1, true) ~= nil
				row:SetHeight(visible and CUSTOM_ROW_H or 0)
				row:SetHidden(not visible)
			end
		end
	end

	table.insert(OptionControls, {
		type = "custom",
		minHeight = CUSTOM_ROW_H,
		maxHeight = 800,
		createFunc = function(ctrl)
			customControl = ctrl
			local wm = WINDOW_MANAGER
			local panelWidth = ctrl:GetWidth()

			addLabel = wm:CreateControl(nil, ctrl, CT_LABEL)
			addLabel:SetAnchor(TOPLEFT, ctrl, TOPLEFT, 0, 0)
			addLabel:SetHeight(CUSTOM_ROW_H)
			addLabel:SetWidth(panelWidth - 130 - 80)
			addLabel:SetFont("ZoFontGame")
			addLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
			addLabel:SetText("New buff or debuff id:")

			local addBg = wm:CreateControlFromVirtual(nil, ctrl, "ZO_EditBackdrop")
			addBg:SetHeight(CUSTOM_ROW_H)
			addBg:SetWidth(128)
			addBg:SetAnchor(TOPLEFT, addLabel, TOPRIGHT, 5, 0)

			addEditbox = wm:CreateControlFromVirtual(nil, addBg, "ZO_DefaultEditForBackdrop")
			addEditbox:SetTextType(TEXT_TYPE_NUMERIC_UNSIGNED_INT)
			addEditbox:SetMaxInputChars(10)
			addEditbox:SetAnchor(TOPLEFT, addBg, TOPLEFT, 2, 2)
			addEditbox:SetAnchor(BOTTOMRIGHT, addBg, BOTTOMRIGHT, -2, -2)

			local addBtn = wm:CreateControlFromVirtual(nil, ctrl, "ZO_DefaultButton")
			addBtn:SetDimensions(70, CUSTOM_ROW_H)
			addBtn:SetAnchor(TOPRIGHT, ctrl, TOPRIGHT, 0, 0)
			addBtn:SetText("Add")
			addBtn:SetHandler("OnClicked", function()
				local id = tonumber(addEditbox:GetText())
				if id and id > 0 then
					local found = false
					for _, existingId in ipairs(ACCOUNT_SETTINGS.CUSTOM_IDS) do
						if existingId == id then
							found = true
							break
						end
					end
					if not found then
						table.insert(ACCOUNT_SETTINGS.CUSTOM_IDS, id)
						addEditbox:SetText("")
						RefreshCustomList()
						reloadNeeded = true
						local reloadBtn = _G["ALTGF_ReloadUIBtn"]
						if reloadBtn and reloadBtn.UpdateDisabled then
							reloadBtn:UpdateDisabled()
						end
					end
				end
			end)

			RefreshCustomList()
		end,
	})

	LAM2:RegisterOptionControls("ALTGF_BuffTrackerSettings", OptionControls)

	-- Hook OnTextChanged on the inner editbox for live filtering
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
		if panel:GetName() == "ALTGF_BuffTrackerSettings" then
			local filterRow = _G["ALTGF_FilterEditbox"]
			if filterRow and filterRow.editbox then
				filterRow.editbox:SetHandler("OnTextChanged", function(self)
					ApplyFilter(self:GetText())
				end)
			end
		end
	end)
end
