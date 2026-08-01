local NAME = "AltGroupFramesBuffTracker"
local SV_VER = 5

local SETTINGS
local ACCOUNT_SETTINGS

ALTGF_BuffDebuffIcon_Keyboard_XY = 30
ALTGF_BuffDebuffIcon_Keyboard_Inner_XY = ALTGF_BuffDebuffIcon_Keyboard_XY - 4
ALTGF_BuffDebuffIcon_Gamepad_XY = 40
ALTGF_BuffDebuffIcon_Gamepad_Inner_XY = ALTGF_BuffDebuffIcon_Gamepad_XY - 4
ALTGF_BuffDebuffIcon_Offset = 3

local iconOverrides = {}

local function anyBorderAssigned()
	for _, assignment in pairs(SETTINGS.TRACK) do
		if type(assignment) == "string" and assignment:sub(1, 6) == "border" then
			return true
		end
	end
	return false
end


local function countTracked()
	local num = 0
	for _, assignment in pairs(SETTINGS.TRACK) do
		if assignment == "icons" then num = num + 1 end
	end
	return num
end

local function applyInsideAnchorsToFrame(UnitFrame)
	local frameCtrl  = UnitFrame:GetControl()
	local borderAreaH = SETTINGS.INSIDE_FRAME and anyBorderAssigned()
		and (SETTINGS.NUM_BORDERS * SETTINGS.BORDER_THICK) or -2

	-- Border bars: stack borders downwards visually, but anchor upwards inside frame
	if UnitFrame.borderCooldowns then
		local prev = nil
		for i = 1, 3 do
			local n = SETTINGS.INSIDE_FRAME and 4 - i or i
			local b = UnitFrame.borderCooldowns[n]
			if n <= SETTINGS.NUM_BORDERS and b then
				b.control:ClearAnchors()
				if not SETTINGS.INSIDE_FRAME then
					b.control:SetAnchor(TOPLEFT,  prev or frameCtrl, BOTTOMLEFT,  0, 0)
					b.control:SetAnchor(TOPRIGHT, prev or frameCtrl, BOTTOMRIGHT, 0, 0)
				elseif prev ~= nil then
					b.control:SetAnchor(BOTTOMLEFT,  prev, TOPLEFT,  0, 0)
					b.control:SetAnchor(BOTTOMRIGHT, prev, TOPRIGHT, 0, 0)
				else
					b.control:SetAnchor(BOTTOMLEFT,  frameCtrl, BOTTOMLEFT,  1, 1)
					b.control:SetAnchor(BOTTOMRIGHT, frameCtrl, BOTTOMRIGHT, -1, -1)
				end
				prev = b.control
			end
		end
	end

	if ALT_GROUP_FRAMES.SETTINGS.SINGLE_ROW_FRAME then
		if UnitFrame.levelControl then
			UnitFrame.levelControl:ClearAnchors()
			UnitFrame.levelControl:SetAnchor(RIGHT, frameCtrl, RIGHT, 0, -borderAreaH / 2)
		end
		if UnitFrame.iconControl then
			UnitFrame.iconControl:ClearAnchors()
			UnitFrame.iconControl:SetAnchor(LEFT, frameCtrl, LEFT, 5, -borderAreaH / 2)
		end
	else
		if UnitFrame.resourceNumbersControl then
			UnitFrame.resourceNumbersControl:ClearAnchors()
			UnitFrame.resourceNumbersControl:SetAnchor(BOTTOMRIGHT, frameCtrl, BOTTOMRIGHT, -4, -borderAreaH)
		end
		if UnitFrame.iconControl then
			UnitFrame.iconControl:ClearAnchors()
			UnitFrame.iconControl:SetAnchor(BOTTOMLEFT, frameCtrl, BOTTOMLEFT, 4, -borderAreaH)
		end
	end
end

local settingsOverride
local function applyStyleSettings()
	if settingsOverride ~= nil then
		ALT_GROUP_FRAMES:RemoveOverrideSettings(settingsOverride)
		settingsOverride = nil
	end

	local numTrack = countTracked()
	local hasBorder = anyBorderAssigned()

	if SETTINGS.ENABLED and (numTrack > 0 or hasBorder) then
		local baseHeight = ALT_GROUP_FRAMES.SETTINGS.UNIT_FRAME_HEIGHT
		settingsOverride = ALT_GROUP_FRAMES:OverrideSettings()

		local iconSize = IsInGamepadPreferredMode() and ALTGF_BuffDebuffIcon_Gamepad_XY or ALTGF_BuffDebuffIcon_Keyboard_XY
		local iconAreaW = numTrack > 0 and (ALTGF_BuffDebuffIcon_Offset + numTrack * (iconSize + ALTGF_BuffDebuffIcon_Offset)) or 0
		local borderH = hasBorder and (SETTINGS.NUM_BORDERS * SETTINGS.BORDER_THICK) or 0

		-- Icon row lives in the horizontal gap to the right of the frame
		if iconAreaW > 0 then
			settingsOverride.UNIT_FRAME_PAD_X = iconAreaW
		end

		-- Borders: enlarge the frame height (inside) or claim the vertical gap (outside)
		if borderH > 0 then
			if SETTINGS.INSIDE_FRAME then
				settingsOverride.UNIT_FRAME_HEIGHT = baseHeight + borderH
			else
				settingsOverride.UNIT_FRAME_PAD_Y = borderH
			end
		end
	end
end
-------------------------------------
--Settings Menu--
-------------------------------------
local function InitializeAddonMenu()
	local LAM2 = LibAddonMenu2

	-- Build predefined ID list (used for TRACK cleanup)
	local abilityIdChoices = {}
	for _, buff in ipairs(ALTGF_BUFFS) do
		abilityIdChoices[#abilityIdChoices + 1] = buff.id
	end

	-- clear old/unused abilityId settings (if ALTGF_BUFFS or CUSTOM_IDS changed)
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
		author = "|c943810BulDeZir|r",
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
			end,
		},
		{
			type = "checkbox",
			name = "Borders inside frame",
			tooltip = "When enabled, border bars are drawn inside the frame's own visual area (the frame grows taller). Icons always occupy the gap to the right of the frame.",
			disabled = function() return not SETTINGS.ENABLED end,
			default = false,
			getFunc = function() return SETTINGS.INSIDE_FRAME end,
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
			disabled = function() return not SETTINGS.ENABLED end,
			default = 1,
			getFunc = function() return SETTINGS.NUM_BORDERS end,
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
			disabled = function() return not SETTINGS.ENABLED end,
			default = function() return ZO_ColorDef:New(unpack(SETTINGS.BORDER_COLORS[1])) end,
			getFunc = function() return unpack(SETTINGS.BORDER_COLORS[1]) end,
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
			disabled = function() return not SETTINGS.ENABLED end,
			default = function() return ZO_ColorDef:New(unpack(SETTINGS.BORDER_COLORS[2])) end,
			getFunc = function() return unpack(SETTINGS.BORDER_COLORS[2]) end,
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
			disabled = function() return not SETTINGS.ENABLED end,
			default = function() return ZO_ColorDef:New(unpack(SETTINGS.BORDER_COLORS[3])) end,
			getFunc = function() return unpack(SETTINGS.BORDER_COLORS[3]) end,
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
			disabled = function() return not SETTINGS.ENABLED end,
			default = function() return 4 end,
			getFunc = function() return zo_round(SETTINGS.BORDER_THICK) end,
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
			type = "slider",
			name = "Icon duration font size",
			min = 8,
			max = 24,
			step = 1,
			disabled = function() return not SETTINGS.ENABLED end,
			default = 14,
			getFunc = function() return SETTINGS.FONT_SIZE end,
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
		getFunc = function() return currentFilter end,
		setFunc = function(text) ApplyFilter(text) end,
	}
	table.insert(OptionControls, filterEditboxData)

	-- Buff list: one custom LAM control owns all rows so we can re-anchor on filter
	local buffListControl
	local buffRowControls = {}
	local buffHdrControls = {}

	local DROPDOWN_ROW_H = 30

	-- Labels for each assignment key, in order they appear in dropdowns
	local ASSIGNMENT_OPTIONS = {
		{ label = "None",     key = nil       },
		{ label = "Icons",    key = "icons"    },
		{ label = "Border 1", key = "border1" },
		{ label = "Border 2", key = "border2" },
		{ label = "Border 3", key = "border3" },
	}

	local function keyToLabel(key)
		for _, opt in ipairs(ASSIGNMENT_OPTIONS) do
			if opt.key == key then return opt.label end
		end
		return "None"
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
				SETTINGS.TRACK[capturedId] = optKey
				greyRow(iconTex, nameLabel, optKey == nil)
				ALT_GROUP_FRAMES:RefreshView(true)
			end)
			comboBox:AddItem(entry)
		end
		comboBox:SetSelectedItemText(keyToLabel(currentKey))
		greyRow(iconTex, nameLabel, currentKey == nil)
	end

	LayoutBuffList = function(filter)
		if not buffListControl then return end

		-- First pass: which categories have at least one matching buff
		local catVisible = {}
		for _, buff in ipairs(ALTGF_BUFFS) do
			if filter == "" or zo_strformat(SI_UNIT_NAME, GetAbilityName(buff.id)):lower():find(filter, 1, true) ~= nil then
				catVisible[buff.cat] = true
			end
		end

		-- Second pass: re-anchor visible controls into a tight chain, collapse hidden ones
		local prevCtrl = nil
		local totalH = 0
		local seenCat = {}

		for _, buff in ipairs(ALTGF_BUFFS) do
			local cat = buff.cat
			if not seenCat[cat] then
				seenCat[cat] = true
				local hdr = buffHdrControls[cat]
				if hdr then
					if catVisible[cat] then
						hdr:ClearAnchors()
						hdr:SetAnchor(TOPLEFT, prevCtrl or buffListControl, prevCtrl and BOTTOMLEFT or TOPLEFT, 0, prevCtrl and CUSTOM_PAD or 0)
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
				local visible = filter == "" or zo_strformat(SI_UNIT_NAME, GetAbilityName(buff.id)):lower():find(filter, 1, true) ~= nil
				if visible then
					rowData.row:ClearAnchors()
					rowData.row:SetAnchor(TOPLEFT, prevCtrl or buffListControl, prevCtrl and BOTTOMLEFT or TOPLEFT, 0, prevCtrl and CUSTOM_PAD or 0)
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
		if not buffListControl then return end

		local wm = WINDOW_MANAGER
		local panelWidth = buffListControl:GetWidth()

		-- Build name→count and suffix lookup; suffix only applied on actual collisions
		local nameCount = {}
		local suffixById = {}
		for _, buff in ipairs(ALTGF_BUFFS) do
			local n = zo_strformat(SI_UNIT_NAME, GetAbilityName(buff.id))
			if n ~= "" then nameCount[n] = (nameCount[n] or 0) + 1 end
			if buff.suffix then suffixById[buff.id] = buff.suffix end
		end
		local function displayName(id)
			local n = zo_strformat(SI_UNIT_NAME, GetAbilityName(id))
			if n == "" then return "[" .. id .. "]" end
			if suffixById[id] and nameCount[n] and nameCount[n] > 1 then
				return n .. " (" .. suffixById[id] .. ")"
			end
			return n
		end

		-- Create one header label per category
		local seenCat = {}
		for _, buff in ipairs(ALTGF_BUFFS) do
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
		for _, buff in ipairs(ALTGF_BUFFS) do
			local abilityId = buff.id
			if not buffRowControls[abilityId] then
				local row = wm:CreateControl(nil, buffListControl, CT_CONTROL)

				local iconTex = wm:CreateControl(nil, row, CT_TEXTURE)
				iconTex:SetDimensions(DROPDOWN_ROW_H, DROPDOWN_ROW_H)
				iconTex:SetTexture(iconOverrides[abilityId] or GetAbilityIcon(abilityId))
				iconTex:SetAnchor(LEFT, row, LEFT, 2, 0)

				local nameLabel = wm:CreateControl(nil, row, CT_LABEL)
				nameLabel:SetFont("ZoFontGame")
				nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
				nameLabel:SetAnchor(LEFT, iconTex, RIGHT, 6, 0)
				nameLabel:SetText(displayName(abilityId))

				local comboBoxCtrl = wm:CreateControlFromVirtual("ALTGF_BuffCombo" .. abilityId, row, "ZO_ComboBox")
				comboBoxCtrl:SetDimensions(130, DROPDOWN_ROW_H)
				comboBoxCtrl:SetAnchor(RIGHT, row, RIGHT, 0, 0)

				buffRowControls[abilityId] = { row = row, iconTex = iconTex, nameLabel = nameLabel, comboBoxCtrl = comboBoxCtrl }
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
		disabled = function() return not reloadNeeded end,
		func = function() ReloadUI() end,
		width = "half",
	})

	local customControl, addLabel, addEditbox
	local customRows = {}

	local function RefreshCustomList()
		if not customControl then return end

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
			local icon = iconOverrides[abilityId] or GetAbilityIcon(abilityId)
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
						if existingId == id then found = true; break end
					end
					if not found then
						table.insert(ACCOUNT_SETTINGS.CUSTOM_IDS, id)
						addEditbox:SetText("")
						RefreshCustomList()
						reloadNeeded = true
						local reloadBtn = _G["ALTGF_ReloadUIBtn"]
						if reloadBtn and reloadBtn.UpdateDisabled then reloadBtn:UpdateDisabled() end
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

-------------------------------------
--Custom Container Object--
-------------------------------------
local UnitBuffTrackerContrainer = ZO_BuffDebuff_ContainerObject:Subclass()

function UnitBuffTrackerContrainer:New(UnitFrame, rowKey, ...)
	local object = ZO_BuffDebuff_ContainerObject.New(self, ...)

	object.iconControlTemplate = "ALTGF_BuffDebuffIcon"
	object.unitFrame = UnitFrame
	object.rowKey = rowKey
	object.combatEventBuffs = {}

	return object
end

function UnitBuffTrackerContrainer:SetIconControlTemplate(t)
	self.iconControlTemplate = t
end

function UnitBuffTrackerContrainer:ShouldContextuallyShow()
	return SETTINGS.ENABLED
end

function UnitBuffTrackerContrainer:CreateMetaPool(container, buffControlPool)
	local metaPool = ZO_MetaPool:New(buffControlPool)
	metaPool.container = container

	local function OnAcquired(control)
		control:ClearAnchors()

		if control.platformStyle ~= self.currentPlatformStyle then
			control.platformStyle = self.currentPlatformStyle
			ApplyTemplateToControl(control, ZO_GetPlatformTemplate(self.iconControlTemplate))
		end

		if not metaPool.firstControl then
			metaPool.firstControl = control
			control:SetAnchor(LEFT, container)
		else
			control:SetAnchor(LEFT, metaPool.lastControl, RIGHT, ALTGF_BuffDebuffIcon_Offset, 0)
		end

		metaPool.lastControl = control

		control:SetParent(container)
	end

	local function OnReset(control)
		control.blinkAnimation:Stop()

		control.cooldown:ResetCooldown()
		control.cooldown:SetHidden(true)
	end

	metaPool:SetCustomAcquireBehavior(OnAcquired)
	metaPool:SetCustomResetBehavior(OnReset)

	return metaPool
end

-------------------------------------
--Custom Style--
-------------------------------------
local UnitBuffTrackerStyle = ZO_BuffDebuffStyleObject:Subclass()

function UnitBuffTrackerStyle:New(...)
	return ZO_BuffDebuffStyleObject.New(self, ...)
end

function UnitBuffTrackerStyle:UpdateContainer(containerObject)
	ZO_ClearNumericallyIndexedTable(self.sortedBuffs)
	ZO_ClearNumericallyIndexedTable(self.sortedDebuffs)

	if containerObject:ShouldContextuallyShow() then
		local currentTime = GetFrameTimeSeconds()
		local unitTag = containerObject:GetUnitTag()
		local uid = 1

		local seenAbilityIds = {}

		for i = 1, GetNumBuffs(unitTag) do
			local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, _, castByPlayer =
				GetUnitBuffInfo(unitTag, i)
			local permanent = IsAbilityPermanent(abilityId)
			local timeRemainingS = timeEnding - currentTime

			if timeRemainingS > 0 and SETTINGS.TRACK[abilityId] == containerObject.rowKey then
				seenAbilityIds[abilityId] = true
				local data = {
					buffName = buffName,
					timeStarted = timeStarted,
					timeEnding = timeEnding,
					buffSlot = buffSlot,
					stackCount = stackCount,
					iconFilename = iconOverrides[abilityId] or iconFilename,
					buffType = buffType,
					effectType = effectType,
					abilityType = abilityType,
					statusEffectType = statusEffectType,
					abilityId = abilityId,
					uid = uid,
					duration = timeEnding - timeStarted,
					castByPlayer = castByPlayer,
					permanent = permanent,
					isArtificial = false,
				}
				local appropriateTable = (effectType == BUFF_EFFECT_TYPE_BUFF) and self.sortedBuffs
					or self.sortedDebuffs
				table.insert(appropriateTable, data)
				uid = uid + 1
			end
		end

		for abilityId, data in pairs(containerObject.combatEventBuffs) do
			if not seenAbilityIds[abilityId] then
				if currentTime < data.timeEnding then
					data.uid = uid
					local appropriateTable = (data.effectType == BUFF_EFFECT_TYPE_BUFF) and self.sortedBuffs
						or self.sortedDebuffs
					table.insert(appropriateTable, data)
					uid = uid + 1
				else
					containerObject.combatEventBuffs[abilityId] = nil
				end
			end
		end

		if #self.sortedBuffs then
			table.sort(self.sortedBuffs, self.SortCallbackFunction)
		end
		if #self.sortedDebuffs then
			table.sort(self.sortedDebuffs, self.SortCallbackFunction)
		end

		local buffPool, debuffPool = containerObject:GetPools()

		for _, data in ipairs(self.sortedBuffs) do
			local buffControl = buffPool:AcquireObject()
			buffControl.data = data
			self:SetupIcon(buffControl)
		end

		for _, data in ipairs(self.sortedDebuffs) do
			local debuffControl = debuffPool:AcquireObject()
			debuffControl.data = data
			self:SetupIcon(debuffControl)
		end
	end
end

function UnitBuffTrackerStyle:SetupIcon(control)
	ZO_BuffDebuffStyleObject.SetupIcon(self, control)
	local durationLabel = control:GetNamedChild("Duration")
	if durationLabel then
		durationLabel:SetFont("$(BOLD_FONT)|" .. SETTINGS.FONT_SIZE .. "|soft-shadow-thick")
	end
end

function UnitBuffTrackerStyle:SortFunction(buffData1, buffData2)
	-- fixed positions
	if buffData1.abilityId == buffData2.abilityId then
		return buffData1.uid < buffData2.uid
	else
		return buffData1.abilityId < buffData2.abilityId
	end
end

-------------------------------------
--Track Ability with UnitFrame Border
-------------------------------------
local BorderBuffTrack = ZO_Object:Subclass()

function BorderBuffTrack:New(...)
	local obj = ZO_Object.New(self)
	obj:Initialize(...)
	return obj
end

function BorderBuffTrack:Initialize(UnitFrame, borderIndex, prevBorderControl)
	local ns = "BuffCooldown" .. UnitFrame:GetUnitTag() .. borderIndex
	self.borderKey = "border" .. borderIndex
	self.activeBuffs = {}  -- [abilityId] = { startTime, endTime }

	self.control = CreateControlFromVirtual(ns, UnitFrame:GetControl(), "ALTGF_Cooldown")
	self.control:SetValue(0)
	self.control:SetHidden(true)
	self.control:SetDrawLayer(DL_OVERLAY)  -- above all DL_CONTROLS content (bg, HP, shields …)
	self.control:SetDrawLevel(5)
	self.control:SetColor(unpack(SETTINGS.BORDER_COLORS[borderIndex]))
	self:SetThickness(SETTINGS.BORDER_THICK)

	-- Stack below the previous border if one exists; otherwise use XML default (below frame)
	if prevBorderControl then
		self.control:ClearAnchors()
		self.control:SetAnchor(TOPLEFT, prevBorderControl, BOTTOMLEFT, 0, 0)
		self.control:SetAnchor(TOPRIGHT, prevBorderControl, BOTTOMRIGHT, 0, 0)
	end

	local function OnAnimationTransitionUpdate(animation, progress)
		local newBarValue = zo_lerp(animation.initialValue, animation.endValue, progress)
		self.control:SetValue(newBarValue)
	end

	self.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ALTGF_StatusBarGrowTemplate")
	local customAnimation = self.animation:GetFirstAnimation()
	customAnimation:SetUpdateFunction(OnAnimationTransitionUpdate)

	local function PlayAnim(duration, currentRemaining)
		self.control:SetMinMax(0, duration * 1000)
		customAnimation.initialValue = currentRemaining * 1000
		customAnimation.endValue = 0
		customAnimation:SetDuration(currentRemaining * 1000)
		self.control:SetHidden(false)
		self.animation:PlayFromStart()
	end

	-- Find and display the active buff with the longest remaining duration
	function self:UpdateDisplay()
		local now = GetFrameTimeSeconds()
		local bestEndTime = 0
		local bestStartTime = 0
		for _, info in pairs(self.activeBuffs) do
			if info.endTime > now and info.endTime > bestEndTime then
				bestEndTime = info.endTime
				bestStartTime = info.startTime
			end
		end
		if bestEndTime > 0 then
			PlayAnim(bestEndTime - bestStartTime, bestEndTime - now)
		else
			self:Reset()
		end
	end
end

function BorderBuffTrack:SetThickness(value)
	self.control:SetHeight(value)
end

function BorderBuffTrack:SetColor(...)
	self.control:SetColor(...)
end

function BorderBuffTrack:Reset()
	self.animation:Stop()
	self.control:SetValue(0)
	self.control:SetHidden(true)
end

-------------------------------------
--Init--
-------------------------------------

local function Initialize()
	local styleObject = UnitBuffTrackerStyle:New("ALTGF_BuffDebuffCenterOutStyle_Template")

	local controlPool = ZO_ControlPool:New("ALTGF_BuffDebuffIcon", nil, "FGBuff")

	-- Hook global RefreshView so our settings adjustments survive every data/style refresh.
	local altgfRefreshView = ALT_GROUP_FRAMES.RefreshView
	ALT_GROUP_FRAMES.RefreshView = function(self, recurse)
		altgfRefreshView(self, false)
		applyStyleSettings()
		if recurse then ALT_GROUP_FRAMES:ForEach(function(unitFrame)
			unitFrame:RefreshView()
			unitFrame:RefreshPosition()
		end) end
	end

	local function initFrame(UnitFrame)
		local overridenUnitTag = UnitFrame:GetUnitTag() == "player" and "customplayer" or UnitFrame:GetUnitTag()
		if BUFF_DEBUFF.containerObjectsByUnitTag[overridenUnitTag] ~= nil then return end

		local unitTag = UnitFrame:GetUnitTag()
		local frameCtrl = UnitFrame:GetControl()

		-- Hook RefreshView so our anchor adjustments survive every data/style refresh.
		-- We shadow the class method with an instance field on this specific UnitFrame.
		local classRefreshView = UnitFrame.RefreshView
		UnitFrame.RefreshView = function(self, ...)
			classRefreshView(self, ...)
			applyInsideAnchorsToFrame(self)
		end

		-- Create 3 borders, each stacked below the previous
		UnitFrame.borderCooldowns = {}
		local prevBorderCtrl = nil
		for i = 1, 3 do
			local border = BorderBuffTrack:New(UnitFrame, i, prevBorderCtrl)
			UnitFrame.borderCooldowns[i] = border
			prevBorderCtrl = border.control
		end

		-- Create the single icon row container
		local containerControl = CreateControlFromVirtual(
			"AltGroupBuffDebuff" .. unitTag,
			frameCtrl,
			"ZO_BuffDebuffContainerTemplate"
		)
		containerControl:ClearAnchors()
		containerControl:SetAnchor(RIGHT, UnitFrame:GetControl(), RIGHT, 0, 0)
		containerControl:SetDrawLayer(DL_OVERLAY)
		containerControl:SetDrawLevel(5)

		local containerObject = UnitBuffTrackerContrainer:New(
			UnitFrame,
			"icons",
			containerControl,
			controlPool,
			unitTag,
			EVENT_PLAYER_ACTIVATED
		)
		containerObject:SetStyleObject(styleObject, true)
		BUFF_DEBUFF:AddContainerObject(overridenUnitTag, containerObject)

		-- Combat-event handler for the icon
		local function handleCombatEventIcon(_, result, _, _, _, _, _, _, rawTargetName, _, hitValue, _, _, _, _, targetUnitId, abilityId)
			if not SETTINGS.ENABLED then return end
			if result ~= ACTION_RESULT_EFFECT_GAINED and result ~= ACTION_RESULT_EFFECT_GAINED_DURATION and result ~= ACTION_RESULT_EFFECT_FADED then return end
			if SETTINGS.TRACK[abilityId] ~= "icons" then return end

			local unitMatches = UnitFrame.unitId ~= nil and UnitFrame.unitId == targetUnitId
				or zo_strformat(SI_UNIT_NAME, rawTargetName) == zo_strformat(SI_UNIT_NAME, GetUnitName(unitTag))
			if not unitMatches then return end

			if result == ACTION_RESULT_EFFECT_FADED then
				containerObject.combatEventBuffs[abilityId] = nil
			else
				local now = GetFrameTimeSeconds()
				local duration = hitValue / 1000
				containerObject.combatEventBuffs[abilityId] = {
					buffName = zo_strformat(SI_UNIT_NAME, GetAbilityName(abilityId)),
					timeStarted = now,
					timeEnding = now + duration,
					buffSlot = 0,
					stackCount = 1,
					iconFilename = iconOverrides[abilityId] or GetAbilityIcon(abilityId),
					buffType = 1,
					effectType = BUFF_EFFECT_TYPE_BUFF,
					abilityType = 0,
					statusEffectType = 0,
					abilityId = abilityId,
					uid = 0,
					duration = duration,
					castByPlayer = false,
					permanent = false,
					isArtificial = true,
				}
			end
			containerObject:Update()
		end

		EVENT_MANAGER:RegisterForEvent("ALTGF_Container_" .. unitTag .. "_gained", EVENT_COMBAT_EVENT, handleCombatEventIcon)
		EVENT_MANAGER:AddFilterForEvent("ALTGF_Container_" .. unitTag .. "_gained", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)

		EVENT_MANAGER:RegisterForEvent("ALTGF_Container_" .. unitTag .. "_duration", EVENT_COMBAT_EVENT, handleCombatEventIcon)
		EVENT_MANAGER:AddFilterForEvent("ALTGF_Container_" .. unitTag .. "_duration", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)

		EVENT_MANAGER:RegisterForEvent("ALTGF_Container_" .. unitTag .. "_faded", EVENT_COMBAT_EVENT, handleCombatEventIcon)
		EVENT_MANAGER:AddFilterForEvent("ALTGF_Container_" .. unitTag .. "_faded", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)

		-- Single effect-changed handler for borders, routing by borderKey
		EVENT_MANAGER:RegisterForEvent("ALTGF_Border_" .. unitTag, EVENT_EFFECT_CHANGED,
			function(_, changeType, _, _, _, beginTime, endTime, _, _, _, _, _, _, _, unitId, abilityId)
				if not UnitFrame.unitId then UnitFrame.unitId = unitId end
				if not SETTINGS.ENABLED then return end
				local assignment = SETTINGS.TRACK[abilityId]
				if not assignment or assignment:sub(1, 6) ~= "border" then return end
				local borderIdx = tonumber(assignment:sub(7))
				if not borderIdx or borderIdx > SETTINGS.NUM_BORDERS then return end
				local border = UnitFrame.borderCooldowns[borderIdx]
				if not border then return end
				if changeType == EFFECT_RESULT_FADED then
					border.activeBuffs[abilityId] = nil
				else
					border.activeBuffs[abilityId] = { startTime = beginTime, endTime = endTime }
				end
				border:UpdateDisplay()
			end
		)
		EVENT_MANAGER:AddFilterForEvent("ALTGF_Border_" .. unitTag, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, unitTag)

		-- Single combat-event handler for borders (unit tag filter available?; match by name/id)
		local function handleCombatEventBorder(_, result, _, _, _, _, _, _, rawTargetName, _, hitValue, _, _, _, _, targetUnitId, abilityId)
			if not SETTINGS.ENABLED then return end
			if result ~= ACTION_RESULT_EFFECT_GAINED and result ~= ACTION_RESULT_EFFECT_GAINED_DURATION and result ~= ACTION_RESULT_EFFECT_FADED then return end
			local assignment = SETTINGS.TRACK[abilityId]
			if not assignment or assignment:sub(1, 6) ~= "border" then return end
			local borderIdx = tonumber(assignment:sub(7))
			if not borderIdx or borderIdx > SETTINGS.NUM_BORDERS then return end
			local border = UnitFrame.borderCooldowns[borderIdx]
			if not border then return end

			local unitMatches = UnitFrame.unitId ~= nil and UnitFrame.unitId == targetUnitId
				or zo_strformat(SI_UNIT_NAME, rawTargetName) == zo_strformat(SI_UNIT_NAME, GetUnitName(unitTag))
			if not unitMatches then return end

			if result == ACTION_RESULT_EFFECT_FADED then
				border.activeBuffs[abilityId] = nil
			else
				local now = GetFrameTimeSeconds()
				local duration = hitValue / 1000
				border.activeBuffs[abilityId] = { startTime = now, endTime = now + duration }
			end
			border:UpdateDisplay()
		end

		EVENT_MANAGER:RegisterForEvent("ALTGF_BorderCombat_" .. unitTag .. "_gained", EVENT_COMBAT_EVENT, handleCombatEventBorder)
		EVENT_MANAGER:AddFilterForEvent("ALTGF_BorderCombat_" .. unitTag .. "_gained", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)

		EVENT_MANAGER:RegisterForEvent("ALTGF_BorderCombat_" .. unitTag .. "_duration", EVENT_COMBAT_EVENT, handleCombatEventBorder)
		EVENT_MANAGER:AddFilterForEvent("ALTGF_BorderCombat_" .. unitTag .. "_duration", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)

		EVENT_MANAGER:RegisterForEvent("ALTGF_BorderCombat_" .. unitTag .. "_faded", EVENT_COMBAT_EVENT, handleCombatEventBorder)
		EVENT_MANAGER:AddFilterForEvent("ALTGF_BorderCombat_" .. unitTag .. "_faded", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)

		-- Apply inside/outside anchors for this new frame immediately
		applyInsideAnchorsToFrame(UnitFrame)
	end
	CALLBACK_MANAGER:RegisterCallback(ALT_GROUP_FRAMES.EVENT.UNIT_FRAME_CREATED, initFrame)
	ALT_GROUP_FRAMES:ForEach(initFrame)

	ZO_PlatformStyle:New(function()
		ALT_GROUP_FRAMES:RefreshView()
	end, 1, 2)
end

local function OnAddOnLoaded(_, addonName)
	if addonName == NAME then
		EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)

		for _, buff in ipairs(ALTGF_BUFFS) do
			if buff.icon then iconOverrides[buff.id] = buff.icon end
		end

		SETTINGS = ZO_SavedVars:NewCharacterIdSettings("AltGroupFramesBuffTrackerSV", SV_VER, nil, {
			ENABLED = true,
			INSIDE_FRAME = false,
			TRACK = {},       -- [abilityId] = "icons"|"border1"|"border2"|"border3"
			NUM_BORDERS = 1,
			BORDER_COLORS = {
				{ 0.2, 0.75, 0.15, 1 },
				{ 0.2, 0.55, 0.90, 1 },
				{ 0.9, 0.55, 0.15, 1 },
			},
			BORDER_THICK = 4,
			FONT_SIZE = 14,
		})
		ACCOUNT_SETTINGS = ZO_SavedVars:NewAccountWide("AltGroupFramesBuffTrackerAccountSV", 1, nil, {
			CUSTOM_IDS = {},
		})

		InitializeAddonMenu()

		if SETTINGS.ENABLED then
			Initialize()
		end
	end
end

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
