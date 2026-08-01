-- Section control: centered chip layout, drill-in rows, pool factory.

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

-- ZO_GamepadMenuEntryTemplateWithArrow is a left-indented nav row.
-- When centered + drill-in: full-width chip like other options controls —
-- label centered on the header axis, chevron fixed on the chip's right.
-- Stock left layout keeps the far-right arrow (no chip).
local SECTION_ARROW_GAP = 10
local SECTION_MEASURE_FONT = "ZoFontGamepad34"
local SECTION_CHIP_TEXTURE = "LibConsoleMenu/media/textures/eso_submenu_normal.dds"
local SECTION_CHIP_TEXTURE_SELECTED = "LibConsoleMenu/media/textures/eso_submenu_selected.dds"
local SECTION_CHIP_TEXTURE_DISABLED = "LibConsoleMenu/media/textures/eso_submenu_disabled.dds"
local SECTION_CHIP_PAD_X = 28
local SECTION_CHIP_PAD_Y = 8

local function CaptureSectionArrowStockAnchor(control)
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

local function RestoreSectionArrowStock(control)
	local arrow = control.arrow
	local stock = control.lcmArrowStock
	if not arrow or not stock then
		return
	end
	arrow:ClearAnchors()
	arrow:SetAnchor(stock.point, control, stock.relativePoint, stock.offsetX, stock.offsetY)
end

local function MeasureSectionLabelWidth(text, label)
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
	local font = rawget(_G, SECTION_MEASURE_FONT)
	if font and GetStringWidthScaled then
		local space = rawget(_G, "SPACE") or 0
		local width = GetStringWidthScaled(font, text, 1, space)
		if width and width > 0 then
			return width
		end
	end
	return 0
end

local function EnsureSectionChip(control)
	if control.lcmChip then
		return control.lcmChip
	end
	local chip = WINDOW_MANAGER:CreateControl(control:GetName() .. "LcmChip", control, CT_TEXTURE)
	chip:SetTexture(SECTION_CHIP_TEXTURE)
	chip.lcmTexturePath = SECTION_CHIP_TEXTURE
	chip:SetDrawLayer(DL_CONTROLS)
	chip:SetDrawLevel(-1)
	chip:SetMouseEnabled(false)
	chip:SetHidden(true)
	control.lcmChip = chip
	return chip
end

local function HideSectionChip(control)
	if control.lcmChip then
		control.lcmChip:SetHidden(true)
	end
end

-- Chip art: normal / selected / disabled DDS. No tint hacks — art carries the look.
local function ApplySectionChipAppearance(chip, selected, enabled)
	if not chip or chip:IsHidden() then
		return
	end
	local path
	if not enabled then
		path = SECTION_CHIP_TEXTURE_DISABLED
	elseif selected then
		path = SECTION_CHIP_TEXTURE_SELECTED
	else
		path = SECTION_CHIP_TEXTURE
	end
	if chip.lcmTexturePath ~= path then
		chip:SetTexture(path)
		chip.lcmTexturePath = path
	end
	if chip.SetDesaturation then
		chip:SetDesaturation(0)
	end
	chip:SetColor(1, 1, 1, 1)
end

local function ApplySectionLabelLayout(control, center, showArrow, selected, enabled)
	local label = control and control.label
	if not label then
		return
	end

	if control.lcmSectionLabelIndent == nil then
		control.lcmSectionLabelIndent = ZO_GAMEPAD_DEFAULT_LIST_ENTRY_INDENT or 0
		control.lcmSectionLabelWidth = label:GetWidth()
	end
	CaptureSectionArrowStockAnchor(control)

	local arrow = control.arrow
	label:ClearAnchors()

	if center and showArrow and arrow then
		local chip = EnsureSectionChip(control)
		local textHeight = label:GetTextHeight()
		local chipHeight = zo_max(textHeight, arrow:GetHeight()) + SECTION_CHIP_PAD_Y * 2

		chip:SetHidden(false)
		chip:ClearAnchors()
		chip:SetDimensions(control:GetWidth(), chipHeight)
		chip:SetAnchor(CENTER, control, CENTER, 0, 0)
		ApplySectionChipAppearance(chip, selected, enabled ~= false)

		if label.SetHorizontalAlignment then
			label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		end
		label:SetAnchor(LEFT, chip, LEFT, SECTION_CHIP_PAD_X, 0)
		label:SetAnchor(RIGHT, chip, RIGHT, -SECTION_CHIP_PAD_X, 0)

		arrow:ClearAnchors()
		arrow:SetAnchor(RIGHT, chip, RIGHT, -SECTION_CHIP_PAD_X, 0)

		control:SetHeight(zo_max(chipHeight, textHeight + 4))
	elseif center then
		HideSectionChip(control)
		label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
		label:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
		if label.SetHorizontalAlignment then
			label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		end
		RestoreSectionArrowStock(control)
		control:SetHeight(label:GetTextHeight() + 4)
	else
		HideSectionChip(control)
		label:SetAnchor(TOPLEFT, control, TOPLEFT, control.lcmSectionLabelIndent, 0)
		label:SetWidth(control.lcmSectionLabelWidth)
		if label.SetHorizontalAlignment then
			label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		end
		RestoreSectionArrowStock(control)
		control:SetHeight(label:GetTextHeight() + 4)
	end
end

local function IsCenteredSectionSetting(setting, panel)
	if setting.type ~= LCM.CT_SECTION or setting.subMenu == false then
		return false
	end
	local center = setting.centerSubmenu
	if center == nil and panel then
		center = panel.centerSubmenus
	end
	return center == true
end

-- Per header-group max label width for centered drill-in chevrons.
function LCM.AddonSettings:AssignCenteredSectionArrowColumns(currentSection)
	local maxByGroup = {}
	for i = 1, #self.settings do
		local setting = self.settings[i]
		if setting.currentSection == currentSection and IsCenteredSectionSetting(setting, self) then
			local text = setting:GetString(setting:GetValueOrCallback(setting.labelText))
			local width = MeasureSectionLabelWidth(text, setting.control and setting.control.label)
			local group = setting.lcmArrowGroup or ""
			if width > (maxByGroup[group] or 0) then
				maxByGroup[group] = width
			end
		end
	end
	for i = 1, #self.settings do
		local setting = self.settings[i]
		if setting.currentSection == currentSection then
			if IsCenteredSectionSetting(setting, self) then
				setting.lcmCenteredArrowMaxWidth = maxByGroup[setting.lcmArrowGroup or ""] or 0
			else
				setting.lcmCenteredArrowMaxWidth = nil
			end
		end
	end
end

LCM.changeControlStateFunctions[LCM.CT_SECTION] = function(control, state, selected)
	if selected == nil then
		selected = LCM.list and LCM.list:GetSelectedControl() == control
	end
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
	ApplySectionChipAppearance(control.lcmChip, selected, state)
	control:SetAlpha(ZO_GamepadMenuEntryTemplate_GetAlpha(selected))
end

LCM.updateControlFunctions[LCM.CT_SECTION] = function(self, control, selected, enabled)
	local label = control.label
	label:SetText(self:GetString(self:GetValueOrCallback(self.labelText)))
	local showArrow = self.subMenu ~= false
	control.arrow:SetHidden(not showArrow)

	local center = self.centerSubmenu
	if center == nil and LCM.currentSettings then
		center = LCM.currentSettings.centerSubmenus
	end
	center = center == true

	if selected == nil then
		selected = LCM.list and LCM.list:GetSelectedControl() == control
	end
	enabled = not self:IsDisabled()

	ApplySectionLabelLayout(control, center, showArrow, selected, enabled)

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

LCM.createControlFunctions[LCM.CT_SECTION] = LCM.AddControlEntry

LCM.cleanControlFunctions[LCM.CT_SECTION] = function(self)
	(self.control.label or self.control:GetNamedChild("Label")):SetText(nil)
end

LCM.setupControlFunctions[LCM.CT_SECTION] = function(self, params)
	self.labelText = params.label
	self.tooltipText = params.tooltip
	self.subMenu = params.subMenu
	self.nested = params.nested
	self.popSection = params.popSection
	self.centerSubmenu = params.centerSubmenu
	self.icon = params.icon
	self.disable = params.disable
	self.onEnter = params.onEnter
	self.onExit = params.onExit
end

local SECTION_FONTS = {
	{ font = "ZoFontGamepad34", lineLimit = 5 },
	{ font = "ZoFontGamepad27", lineLimit = 6 },
	{ font = "ZoFontGamepad22", lineLimit = 7 },
}

function LCM.CreateSectionPoolFactory()
	return function(control)
		local label = control:GetNamedChild("Label")
		control.label = label
		control.arrow = control:GetNamedChild("Arrow")
		CaptureSectionArrowStockAnchor(control)
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
		control.lcmSectionLabelIndent = ZO_GAMEPAD_DEFAULT_LIST_ENTRY_INDENT or 0
		control.lcmSectionLabelWidth = label:GetWidth()
		ZO_FontAdjustingWrapLabel_OnInitialized(label, SECTION_FONTS, TEXT_WRAP_MODE_ELLIPSIS)
		function control:Activate()
			if self.data and (self.data.subMenu == false or self.data:IsDisabled()) then
				return
			end
			local section = self.data
			local targetList = LCM:GetSectionListAtDepth(LCM.GetSectionDepth(section))
			targetList.currentSection = section
			LCM.scrollList:SetCurrentList(targetList)
			LCM.currentSettings.lastSelectedRow = nil
			LCM.currentSettings:CreateControls()
			LCM.currentSettings:SelectFirstRow()
			PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
			if type(section.onEnter) == "function" then
				section.onEnter(section)
			end
		end
	end
end
