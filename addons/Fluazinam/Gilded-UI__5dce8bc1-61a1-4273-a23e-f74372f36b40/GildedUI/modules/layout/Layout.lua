if not GildedUI then return end

local Addon = GildedUI

-- Shared layout helpers (ghost previews, future movers).

function Addon:CreateLayoutGhostStack(name, entries, width, rowHeight, gap)
	local wm = WINDOW_MANAGER
	local root = wm:CreateTopLevelWindow(name)
	root:SetMouseEnabled(false)
	root:SetMovable(false)
	root:SetClampedToScreen(false)
	root:SetDrawLayer(DL_OVERLAY)
	root:SetDrawLevel(100)
	root:SetHidden(true)
	root:SetResizeToFitDescendents(true)

	local previous
	local rows = {}
	for i, entry in ipairs(entries) do
		local row = wm:CreateControl(name .. "_Row" .. i, root, CT_CONTROL)
		row:SetDimensions(width, rowHeight)
		if previous then
			row:SetAnchor(TOPLEFT, previous, BOTTOMLEFT, 0, gap)
		else
			row:SetAnchor(TOPLEFT, root, TOPLEFT, 0, 0)
		end

		local backdrop = wm:CreateControl(name .. "_BG" .. i, row, CT_BACKDROP)
		backdrop:SetAnchorFill(row)
		backdrop:SetCenterColor(0.12, 0.12, 0.14, 0.75)
		backdrop:SetEdgeColor(0.85, 0.75, 0.45, 0.9)
		backdrop:SetEdgeTexture("", 1, 1, 2)

		local label = wm:CreateControl(name .. "_Label" .. i, row, CT_LABEL)
		label:SetFont("ZoFontGamepad27")
		label:SetColor(0.95, 0.9, 0.7, 1)
		label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
		label:SetAnchor(TOPLEFT, row, TOPLEFT, 10, 0)
		label:SetAnchor(BOTTOMRIGHT, row, BOTTOMRIGHT, -10, 0)
		label:SetText(entry)

		row.gildedLabel = label
		rows[i] = row
		previous = row
	end

	root.gildedRows = rows
	return root
end

local function ApplyGhostLabelAlignment(root, align)
	if not root or not root.gildedRows then
		return
	end
	local horizontal = align or TEXT_ALIGN_RIGHT
	for i = 1, #root.gildedRows do
		local label = root.gildedRows[i].gildedLabel
		if label then
			label:SetHorizontalAlignment(horizontal)
		end
	end
end

-- rightAligned: pin TOPRIGHT to GuiRoot TOPRIGHT (posX = offset from right edge).
-- Otherwise TOPLEFT to GuiRoot TOPLEFT.
function Addon:ApplyLayoutGhostStack(root, posX, posY, scale, visible, rightAligned, align)
	if not root then
		return
	end
	root:ClearAnchors()
	if rightAligned then
		root:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, posX or 0, posY or 0)
	else
		root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, posX or 0, posY or 0)
	end
	root:SetScale(scale or 1)
	root:SetHidden(not visible)
	ApplyGhostLabelAlignment(root, align)
end
