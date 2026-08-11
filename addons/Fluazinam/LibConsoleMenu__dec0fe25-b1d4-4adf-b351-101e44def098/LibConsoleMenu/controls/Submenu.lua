-- Submenu control: centered chip layout, drill-in rows, pool factory.

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

-- ZO_GamepadMenuEntryTemplateWithArrow is a left-indented nav row.
-- When centered + drill-in: full-width chip like other options controls —
-- label centered on the header axis, chevron fixed on the chip's right.
-- Stock left layout keeps the far-right arrow (no chip).
--
-- Chip art (one plate per row, per header group).
-- Edge ownership: the row above owns each join (its bottom edge).
--   first / solo → top_bottom; other rows → bottom
--   focused → selected; row directly below focus → top_bottom (top faces the gap)
--   Disabled stays a full plate until dedicated art is ready.
local SUBMENU_MEASURE_FONT = "ZoFontGamepad34"
local SUBMENU_CHIP_TEXTURE_TOP_BOTTOM = "LibConsoleMenu/media/textures/eso_submenu_normal_top_bottom.dds"
local SUBMENU_CHIP_TEXTURE_BOTTOM = "LibConsoleMenu/media/textures/eso_submenu_normal_bottom.dds"
local SUBMENU_CHIP_TEXTURE_SELECTED = "LibConsoleMenu/media/textures/eso_submenu_selected.dds"
local SUBMENU_CHIP_TEXTURE_DISABLED = "LibConsoleMenu/media/textures/eso_submenu_disabled.dds"
local SUBMENU_CHIP_PAD_X = 28
local SUBMENU_CHIP_PAD_Y = 8

local SUBMENU_WRAP_FONTS = {
	{ font = "ZoFontGamepad34", lineLimit = 5 },
	{ font = "ZoFontGamepad27", lineLimit = 6 },
	{ font = "ZoFontGamepad22", lineLimit = 7 },
}

local function CaptureSubmenuArrowStockAnchor(control)
	local arrow = control.arrow
	if not arrow or control.lcmArrowStock then
		return
	end
	local isValid, point, _, relativePoint, offsetX, offsetY = arrow:GetAnchor(0)
	if isValid then
		control.lcmArrowStock = {
			point = point,
			relativePoint = relativePoint,
			offsetX = offsetX,
			offsetY = offsetY,
		}
	else
		control.lcmArrowStock = {
			point = RIGHT,
			relativePoint = RIGHT,
			offsetX = 0,
			offsetY = 0,
		}
	end
end

local function RestoreSubmenuArrowStock(control)
	local arrow = control.arrow
	local stock = control.lcmArrowStock
	if not arrow or not stock then
		return
	end
	arrow:ClearAnchors()
	arrow:SetAnchor(stock.point, control, stock.relativePoint, stock.offsetX, stock.offsetY)
end

local function MeasureSubmenuLabelWidth(text, label)
	if type(text) ~= "string" or text == "" then
		return 0
	end
	if label then
		if label.GetStringWidth then
			local width = label:GetStringWidth(text)
			if width and width > 0 then
				return width
			end
		end
		if label.GetTextWidth and label.GetText and label:GetText() == text then
			local width = label:GetTextWidth()
			if width and width > 0 then
				return width
			end
		end
	end
	local font = rawget(_G, SUBMENU_MEASURE_FONT)
	if font and GetStringWidthScaled then
		local space = rawget(_G, "SPACE") or 0
		local width = GetStringWidthScaled(font, text, 1, space)
		if width and width > 0 then
			return width
		end
	end
	return 0
end

local function EnsureSubmenuChip(control)
	if control.lcmChip then
		return control.lcmChip
	end
	local chip = WINDOW_MANAGER:CreateControl(control:GetName() .. "LcmChip", control, CT_TEXTURE)
	chip:SetTexture(SUBMENU_CHIP_TEXTURE_TOP_BOTTOM)
	chip.lcmTexturePath = SUBMENU_CHIP_TEXTURE_TOP_BOTTOM
	chip:SetDrawLayer(DL_CONTROLS)
	chip:SetDrawLevel(-1)
	chip:SetMouseEnabled(false)
	chip:SetHidden(true)
	control.lcmChip = chip
	return chip
end

local function HideSubmenuChip(control)
	local chip = control and control.lcmChip
	if chip then
		chip:SetHidden(true)
	end
	-- Legacy overlay edges from the prior fill+edge approach — keep hidden if present.
	if chip and chip.lcmEdgeTop then
		chip.lcmEdgeTop:SetHidden(true)
	end
	if chip and chip.lcmEdgeBottom then
		chip.lcmEdgeBottom:SetHidden(true)
	end
end

local function IsCenteredSubmenuSetting(setting, panel)
	if not setting or setting.type ~= LCM.CT_SUBMENU or setting.subMenu == false then
		return false
	end
	local align = LCM.ResolveRowAlign(setting, panel)
	return align == "center"
end

-- Consecutive centered chips under the same header share one edge frame.
local function AssignChipEdgeRolesForSettings(settings, currentSubmenu, panel)
	local run = {}
	local function FlushRun()
		local count = #run
		for i = 1, count do
			local setting = run[i]
			setting.lcmChipIsFirst = i == 1
			setting.lcmChipPrev = run[i - 1]
			setting.lcmChipNext = run[i + 1]
		end
		ZO_ClearNumericallyIndexedTable(run)
	end

	local previousGroup
	for i = 1, #settings do
		local setting = settings[i]
		if setting.currentSubmenu == currentSubmenu then
			if IsCenteredSubmenuSetting(setting, panel) then
				local group = setting.lcmArrowGroup or ""
				if previousGroup ~= nil and group ~= previousGroup then
					FlushRun()
				end
				run[#run + 1] = setting
				previousGroup = group
			else
				FlushRun()
				previousGroup = nil
			end
		end
	end
	FlushRun()
end

local function IsSettingControlSelected(setting, selectedControl)
	return setting and setting.control and setting.control == selectedControl
end

local function ResolveChipTexturePath(setting, selected, enabled)
	if not enabled then
		return SUBMENU_CHIP_TEXTURE_DISABLED
	end
	if selected then
		return SUBMENU_CHIP_TEXTURE_SELECTED
	end
	if not setting then
		return SUBMENU_CHIP_TEXTURE_TOP_BOTTOM
	end

	local list = LCM.list
	local selectedControl = list and list:GetSelectedControl()
	-- Directly below focus: top faces the gap; bottom still owns the next join.
	if IsSettingControlSelected(setting.lcmChipPrev, selectedControl) then
		return SUBMENU_CHIP_TEXTURE_TOP_BOTTOM
	end

	-- First (and solo) opens the group and owns the join below.
	if setting.lcmChipIsFirst then
		return SUBMENU_CHIP_TEXTURE_TOP_BOTTOM
	end

	return SUBMENU_CHIP_TEXTURE_BOTTOM
end

local function SetChipTexture(chip, path)
	if chip.lcmTexturePath ~= path then
		chip:SetTexture(path)
		chip.lcmTexturePath = path
	end
end

-- Exclusive plate per role (top / top_bottom / bottom / selected / disabled).
local function ApplySubmenuChipAppearance(control, selected, enabled)
	local chip = control and control.lcmChip
	if not chip or chip:IsHidden() then
		return
	end

	enabled = enabled ~= false
	SetChipTexture(chip, ResolveChipTexturePath(control.data, selected, enabled))

	if chip.lcmEdgeTop then
		chip.lcmEdgeTop:SetHidden(true)
	end
	if chip.lcmEdgeBottom then
		chip.lcmEdgeBottom:SetHidden(true)
	end
	if chip.SetDesaturation then
		chip:SetDesaturation(0)
	end
	chip:SetColor(1, 1, 1, 1)
end

local function RefreshCenteredSubmenuChipEdges(setting)
	local panel = LCM.currentMenu
	if not panel or not setting then
		return
	end
	local group = setting.lcmArrowGroup or ""
	local currentSubmenu = setting.currentSubmenu
	local list = LCM.list
	for i = 1, #panel.controls do
		local other = panel.controls[i]
		if other.currentSubmenu == currentSubmenu and IsCenteredSubmenuSetting(other, panel) and (other.lcmArrowGroup or "") == group then
			local control = other.control
			if control and control.lcmChip and not control.lcmChip:IsHidden() then
				local isSelected = list and list:GetSelectedControl() == control
				ApplySubmenuChipAppearance(control, isSelected, not other:IsDisabled())
			end
		end
	end
end

-- Selected: grow to 42 only when the title still fits on one line in the chip.
-- MaxLineCount must be 1 when selected — leaving the wrap stack's limit (5–7)
-- lets long titles wrap and double GetTextHeight.
-- Label stays symmetrically padded so centered text lines up under headers
-- (chevron draws on top of the right pad; do not inset only the right side).
-- Unselected: restore wrap OnUpdate so very long labels can drop to 27/22.
local SUBMENU_FONT_SELECTED = "ZoFontGamepad42"
local SUBMENU_FONT_UNSELECTED = "ZoFontGamepad34"

local function SetSubmenuWrapEnabled(label, enabled)
	if not label then
		return
	end
	if enabled then
		if label.lcmWrapOnUpdate then
			label:SetHandler("OnUpdate", label.lcmWrapOnUpdate)
		end
		if label.MarkDirty then
			label:MarkDirty()
		end
	else
		if label.lcmWrapOnUpdate == nil then
			label.lcmWrapOnUpdate = label:GetHandler("OnUpdate")
		end
		label:SetHandler("OnUpdate", nil)
	end
end

local function ApplySubmenuLabelFont(label, selected, availableWidth)
	if not label then
		return
	end
	if selected then
		SetSubmenuWrapEnabled(label, false)
		if label.SetMaxLineCount then
			label:SetMaxLineCount(1)
		end
		local useSelected = true
		if availableWidth and availableWidth > 0 then
			label:SetFont(SUBMENU_FONT_SELECTED)
			label:SetWidth(availableWidth)
			local lines = label.GetNumLines and label:GetNumLines() or 1
			local truncated = label.WasTruncated and label:WasTruncated()
			if lines > 1 or truncated then
				useSelected = false
			end
		end
		label:SetFont(useSelected and SUBMENU_FONT_SELECTED or SUBMENU_FONT_UNSELECTED)
	else
		label:SetFont(SUBMENU_FONT_UNSELECTED)
		SetSubmenuWrapEnabled(label, true)
	end
end

local function ApplySubmenuLabelLayout(control, center, showArrow, selected, enabled)
	local label = control and control.label
	if not label then
		return
	end

	if control.lcmSubmenuLabelIndent == nil then
		control.lcmSubmenuLabelIndent = ZO_GAMEPAD_DEFAULT_LIST_ENTRY_INDENT or 0
		control.lcmSubmenuLabelWidth = label:GetWidth()
	end
	CaptureSubmenuArrowStockAnchor(control)

	local arrow = control.arrow
	label:ClearAnchors()

	if center and showArrow and arrow then
		local chip = EnsureSubmenuChip(control)
		local availableWidth = control:GetWidth() - SUBMENU_CHIP_PAD_X * 2

		ApplySubmenuLabelFont(label, selected, availableWidth)

		chip:SetHidden(false)
		chip:ClearAnchors()
		chip:SetAnchor(CENTER, control, CENTER, 0, 0)
		ApplySubmenuChipAppearance(control, selected, enabled ~= false)

		if label.SetHorizontalAlignment then
			label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		end
		-- Symmetric pads — keeps label center aligned with header axis.
		label:SetAnchor(LEFT, chip, LEFT, SUBMENU_CHIP_PAD_X, 0)
		label:SetAnchor(RIGHT, chip, RIGHT, -SUBMENU_CHIP_PAD_X, 0)

		-- Keep chevron position identical to stock/left-aligned rows.
		RestoreSubmenuArrowStock(control)

		local textHeight = label:GetTextHeight()
		local chipHeight = zo_max(textHeight, arrow:GetHeight()) + SUBMENU_CHIP_PAD_Y * 2
		chip:SetDimensions(control:GetWidth(), chipHeight)
		control:SetHeight(chipHeight)
	elseif center then
		HideSubmenuChip(control)
		ApplySubmenuLabelFont(label, selected, control:GetWidth())
		label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
		label:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
		if label.SetHorizontalAlignment then
			label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		end
		RestoreSubmenuArrowStock(control)
		control:SetHeight(label:GetTextHeight() + 4)
	else
		HideSubmenuChip(control)
		ApplySubmenuLabelFont(label, selected, control.lcmSubmenuLabelWidth)
		label:SetAnchor(TOPLEFT, control, TOPLEFT, control.lcmSubmenuLabelIndent, 0)
		label:SetWidth(control.lcmSubmenuLabelWidth)
		if label.SetHorizontalAlignment then
			label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		end
		RestoreSubmenuArrowStock(control)
		control:SetHeight(label:GetTextHeight() + 4)
	end
end

local function ResolveSubmenuCenter(setting)
	local align = LCM.ResolveRowAlign(setting, LCM.currentMenu)
	return align == "center"
end

local function ApplySubmenuArrowVisibility(control, center, showArrow, selected)
	local arrow = control and control.arrow
	if not arrow then
		return
	end
	-- Centered submenus only show the chevron while focused.
	local hideArrow = (not showArrow) or (center and not selected)
	arrow:SetHidden(hideArrow)
end

local function RelayoutSubmenuControl(control, selected, enabled)
	local setting = control and control.data
	if not setting then
		return
	end
	local showArrow = setting.subMenu ~= false
	ApplySubmenuLabelLayout(control, ResolveSubmenuCenter(setting), showArrow, selected, enabled)
end

-- Per header-group max label width for centered drill-in chevrons.
function LCM.AddonMenu:AssignCenteredSubmenuArrowColumns(currentSubmenu)
	AssignChipEdgeRolesForSettings(self.controls, currentSubmenu, self)
	local maxByGroup = {}
	for i = 1, #self.controls do
		local setting = self.controls[i]
		if setting.currentSubmenu == currentSubmenu and IsCenteredSubmenuSetting(setting, self) then
			local text = setting:GetString(setting:GetValueOrCallback(setting.labelText))
			local width = MeasureSubmenuLabelWidth(text, setting.control and setting.control.label)
			local group = setting.lcmArrowGroup or ""
			if width > (maxByGroup[group] or 0) then
				maxByGroup[group] = width
			end
		end
	end
	for i = 1, #self.controls do
		local setting = self.controls[i]
		if setting.currentSubmenu == currentSubmenu then
			if IsCenteredSubmenuSetting(setting, self) then
				setting.lcmCenteredArrowMaxWidth = maxByGroup[setting.lcmArrowGroup or ""] or 0
			else
				setting.lcmCenteredArrowMaxWidth = nil
			end
		end
	end
end

LCM.changeControlStateFunctions[LCM.CT_SUBMENU] = function(control, state, selected)
	if selected == nil then
		selected = LCM.list and LCM.list:GetSelectedControl() == control
	end
	local setting = control and control.data
	local showArrow = setting and setting.subMenu ~= false
	local center = setting and ResolveSubmenuCenter(setting) or false
	ApplySubmenuArrowVisibility(control, center, showArrow, selected)
	local color = ZO_GamepadMenuEntryTemplate_GetLabelColor(selected, not state)
	local r, g, b = color:UnpackRGB()
	if control.label then
		control.label:SetColor(r, g, b, 1)
	end
	if control.arrow and not control.arrow:IsHidden() then
		control.arrow:SetColor(r, g, b, control.arrow:GetControlAlpha())
	end
	if control.icon and not control.icon:IsHidden() then
		control.icon:SetColor(r, g, b, control.icon:GetControlAlpha())
	end
	ApplySubmenuChipAppearance(control, selected, state)
	control:SetAlpha(ZO_GamepadMenuEntryTemplate_GetAlpha(selected))
	RelayoutSubmenuControl(control, selected, state)
	if center then
		RefreshCenteredSubmenuChipEdges(setting)
	end
end

LCM.updateControlFunctions[LCM.CT_SUBMENU] = function(self, control, selected, enabled)
	local label = control.label
	label:SetText(self:GetString(self:GetValueOrCallback(self.labelText)))
	local showArrow = self.subMenu ~= false

	local center = ResolveSubmenuCenter(self)

	if selected == nil then
		selected = LCM.list and LCM.list:GetSelectedControl() == control
	end
	enabled = not self:IsDisabled()
	ApplySubmenuArrowVisibility(control, center, showArrow, selected)

	ApplySubmenuLabelLayout(control, center, showArrow, selected, enabled)

	local color = ZO_GamepadMenuEntryTemplate_GetLabelColor(selected, not enabled)
	local r, g, b = color:UnpackRGB()
	label:SetColor(r, g, b, 1)
	if control.arrow and showArrow then
		control.arrow:SetColor(r, g, b, control.arrow:GetControlAlpha())
	end

	local icon = control.icon
	if icon then
		local iconPath = self:GetValueOrCallback(self.icon)
		local showIcon = not center and type(iconPath) == "string" and iconPath ~= ""

		local highlight = control.iconHighlight
		if highlight == nil then
			highlight = icon.GetNamedChild and icon:GetNamedChild("Highlight")
			control.iconHighlight = highlight or false
		end
		if highlight then
			highlight:SetHidden(true)
		end

		if not showIcon then
			if icon.ClearIcons then
				icon:ClearIcons()
			end
			icon:SetHidden(true)
		else
			if icon.ClearIcons and icon.AddIcon and icon.Show then
				icon:ClearIcons()
				icon:AddIcon(iconPath, color)
				icon:Show()
			else
				icon:SetHidden(false)
				icon:SetTexture(iconPath)
			end
			icon:SetColor(r, g, b, icon:GetControlAlpha())
		end
	end
end

LCM.createControlFunctions[LCM.CT_SUBMENU] = LCM.CreateControlListEntry

LCM.cleanControlFunctions[LCM.CT_SUBMENU] = function(self)
	(self.control.label or self.control:GetNamedChild("Label")):SetText(nil)
end

LCM.setupControlFunctions[LCM.CT_SUBMENU] = function(self, params)
	self.labelText = params.label
	self.tooltipText = params.tooltip
	self.subMenu = params.subMenu -- false = non-entering row (no arrow / no Activate)
	self.nested = params.nested
	self.popSubmenu = params.popSubmenu
	self.popAfterSubmenu = params.popAfterSubmenu
	self.popAfterSubmenuIndex = params.popAfterSubmenuIndex
	self.align = params.align
	self.centerSubmenu = params.centerSubmenu -- legacy alias for align
	self.icon = params.icon
	self.disable = params.disable
	self.onEnter = params.onEnter
	self.onExit = params.onExit
end

function LCM.CreateSubmenuPoolFactory()
	return function(control)
		local label = control:GetNamedChild("Label")
		control.label = label
		control.arrow = control:GetNamedChild("Arrow")
		CaptureSubmenuArrowStockAnchor(control)
		control.icon = control:GetNamedChild("Icon") or control.icon
		if control.icon then
			control.iconHighlight = control.icon:GetNamedChild("Highlight")
			if control.iconHighlight then
				control.iconHighlight:SetHidden(true)
			end
			if control.icon.ClearIcons then
				control.icon:ClearIcons()
			end
			control.icon:SetHidden(true)
		end
		control:SetWidth(ZO_GAMEPAD_CONTENT_WIDTH)
		control.lcmSubmenuLabelIndent = ZO_GAMEPAD_DEFAULT_LIST_ENTRY_INDENT or 0
		control.lcmSubmenuLabelWidth = label:GetWidth()
		ZO_FontAdjustingWrapLabel_OnInitialized(label, SUBMENU_WRAP_FONTS, TEXT_WRAP_MODE_ELLIPSIS)
		function control:Activate()
			if self.data and (self.data.subMenu == false or self.data:IsDisabled()) then
				return
			end
			local submenu = self.data
			local targetList = LCM:GetSubmenuListAtDepth(LCM.GetSubmenuDepth(submenu))
			targetList.currentSubmenu = submenu
			LCM.scrollList:SetCurrentList(targetList)
			LCM.currentMenu.lastSelectedRow = nil
			LCM.currentMenu:CreateControls()
			LCM.currentMenu:SelectFirstRow()
			LCM:RefreshSceneHeader()
			PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
			if type(submenu.onEnter) == "function" then
				submenu.onEnter(submenu)
			end
		end
	end
end
