-- Row align helpers (shared; not a control type).
-- align = "center" | "leftIndent" | "leftFlush" (default center)
--   center     → options-style centered labels
--   leftIndent → left + ZO_GAMEPAD_DEFAULT_LIST_ENTRY_INDENT (nav / icon column)
--   leftFlush  → left flush to the content edge
-- Unsupported values are silently clamped (see ClampAlign).

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

local ALIGN_CENTER = "center"
local ALIGN_LEFT_INDENT = "leftIndent"
local ALIGN_LEFT_FLUSH = "leftFlush"

-- Full: center / leftIndent / leftFlush
local ALIGN_FULL = {
	[LCM.CT_DROPDOWN] = true,
	[LCM.CT_CHECKLIST] = true,
	[LCM.CT_BUTTON] = true,
	[LCM.CT_EDITBOX] = true,
}

-- Submenu: center / leftIndent only (leftFlush → center)
local ALIGN_SUBMENU = {
	[LCM.CT_SUBMENU] = true,
}

function LCM.NormalizeAlign(align)
	if align == ALIGN_LEFT_INDENT or align == ALIGN_LEFT_FLUSH then
		return align
	end
	return ALIGN_CENTER
end

function LCM.IsLeftAlign(align)
	align = LCM.NormalizeAlign(align)
	return align == ALIGN_LEFT_INDENT or align == ALIGN_LEFT_FLUSH
end

function LCM.AlignIndentPx(align)
	align = LCM.NormalizeAlign(align)
	if align == ALIGN_LEFT_INDENT then
		return ZO_GAMEPAD_DEFAULT_LIST_ENTRY_INDENT or 0
	end
	return 0
end

-- Clamp to what this control type supports.
function LCM.ClampAlign(controlType, align)
	align = LCM.NormalizeAlign(align)
	if ALIGN_FULL[controlType] then
		return align
	end
	if ALIGN_SUBMENU[controlType] then
		if align == ALIGN_LEFT_FLUSH then
			return ALIGN_CENTER
		end
		return align
	end
	-- Center-only types (toggle, slider, selector, colorpicker, iconpicker, …).
	return ALIGN_CENTER
end

-- Resolve the page-level childrenAlign for a setting.
local function GetPageChildrenAlign(setting, panel)
	if setting and setting.currentSubmenu then
		return setting.currentSubmenu.childrenAlign
	end
	return panel and panel.childrenAlign
end

-- Returns align, indentPx for a setting row.
function LCM.ResolveRowAlign(setting, panel)
	local controlType = setting and setting.type
	local align = setting and setting.align

	if align == nil then
		align = GetPageChildrenAlign(setting, panel)
	end

	align = LCM.ClampAlign(controlType, align)
	return align, LCM.AlignIndentPx(align)
end

-- Header / section: same precedence as rows. Returns align, indentPx.
function LCM.ResolveHeaderAlign(align, setting, panel)
	if align == nil then
		align = GetPageChildrenAlign(setting, panel)
	end
	align = LCM.NormalizeAlign(align)
	return align, LCM.AlignIndentPx(align)
end

-- Re-anchor a full-width Name label for center / leftIndent / leftFlush.
-- Prefer RootSpacer (ZO_GAMEPAD_CONTENT_WIDTH) — same as stock FullWidthLabel /
-- indented ComboBox. Anchoring to the list entry parent stretches past content
-- and pushes dropdown/checklist OpenDropdown off-screen.
-- TOPLEFT+TOPRIGHT only — never BOTTOMRIGHT. Value rows sit below Name;
-- vertical stretch to the row creates an anchor cycle.
function LCM.ApplyNameLabelAlign(nameControl, align, indentPx)
	if not nameControl then
		return
	end
	align = LCM.NormalizeAlign(align)
	indentPx = indentPx or 0
	local parent = nameControl:GetParent()
	if not parent then
		return
	end
	local relativeTo = parent:GetNamedChild("RootSpacer") or parent
	nameControl:ClearAnchors()
	if LCM.IsLeftAlign(align) then
		nameControl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		nameControl:SetAnchor(TOPLEFT, relativeTo, TOPLEFT, indentPx, 0)
		nameControl:SetAnchor(TOPRIGHT, relativeTo, TOPRIGHT, 0, 0)
	else
		nameControl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		nameControl:SetAnchor(TOPLEFT, relativeTo, TOPLEFT, 0, 0)
		nameControl:SetAnchor(TOPRIGHT, relativeTo, TOPRIGHT, 0, 0)
	end
end
