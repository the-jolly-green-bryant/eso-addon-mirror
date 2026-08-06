-- Row align + indent helpers (shared; not a control type).
-- align = "center" | "left" (default center)
-- indent = true | false (default true; ignored when align == "center")
--   left + indent   → ZO_GAMEPAD_DEFAULT_LIST_ENTRY_INDENT (nav / icon column)
--   left + no indent → flush to content edge

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

-- Full: center / left+indent / left+flush
local ALIGN_FULL = {
	[LCM.CT_DROPDOWN] = true,
	[LCM.CT_CHECKLIST] = true,
	[LCM.CT_BUTTON] = true,
	[LCM.CT_EDIT] = true,
}

-- Submenu: center / left+indent only (flush coerced to indented)
local ALIGN_LEFT_CENTER = {
	[LCM.CT_SUBMENU] = true,
}

-- Standalone headers use string type "header" via Normalize only.

function LCM.NormalizeAlign(align)
	if align == "left" then
		return "left"
	end
	return "center"
end

-- Effective left inset in pixels. Center → 0. Left + indent false → 0. Else nav indent.
function LCM.ResolveIndent(align, indent)
	align = LCM.NormalizeAlign(align)
	if align ~= "left" then
		return 0
	end
	if indent == false then
		return 0
	end
	return ZO_GAMEPAD_DEFAULT_LIST_ENTRY_INDENT or 0
end

-- Whether this control type allows flush-left (indent = false).
function LCM.SupportsFlushAlign(controlType)
	return ALIGN_FULL[controlType] == true
end

-- Whether this control type allows left (indented or flush where supported).
function LCM.SupportsLeftAlign(controlType)
	return ALIGN_FULL[controlType] == true or ALIGN_LEFT_CENTER[controlType] == true
end

-- Returns align, indentBool, indentPx for a setting row.
-- Submenu: centerSubmenu / panel.centerSubmenus when align unset; flush coerced off.
-- Center-only types: always center.
function LCM.ResolveRowAlign(setting, panel)
	local controlType = setting and setting.type
	local align = setting and setting.align
	local indent = setting and setting.indent

	if controlType == LCM.CT_SUBMENU then
		if align == nil then
			local center = setting.centerSubmenu
			if center == nil and panel then
				center = panel.centerSubmenus
			end
			align = (center == true) and "center" or "left"
		end
		align = LCM.NormalizeAlign(align)
		-- Submenu never flush.
		indent = true
		return align, indent, LCM.ResolveIndent(align, indent)
	end

	if not LCM.SupportsLeftAlign(controlType) then
		return "center", true, 0
	end

	align = LCM.NormalizeAlign(align)
	if align == "center" then
		return "center", true, 0
	end

	if indent == nil then
		indent = true
	else
		indent = indent ~= false
	end

	if not LCM.SupportsFlushAlign(controlType) then
		indent = true
	end

	return align, indent, LCM.ResolveIndent(align, indent)
end

-- Header rows: align + indent (full support). Returns align, indentPx.
function LCM.ResolveHeaderAlign(align, indent)
	align = LCM.NormalizeAlign(align)
	if align == "center" then
		return "center", 0
	end
	if indent == nil then
		indent = true
	end
	return "left", LCM.ResolveIndent(align, indent)
end

-- Re-anchor a full-width Name label for center / left+indent / left+flush.
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
	if align == "left" then
		nameControl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		nameControl:SetAnchor(TOPLEFT, relativeTo, TOPLEFT, indentPx, 0)
		nameControl:SetAnchor(TOPRIGHT, relativeTo, TOPRIGHT, 0, 0)
	else
		nameControl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		nameControl:SetAnchor(TOPLEFT, relativeTo, TOPLEFT, 0, 0)
		nameControl:SetAnchor(TOPRIGHT, relativeTo, TOPRIGHT, 0, 0)
	end
end
