--[[
	ShoppingListUI
	Dedicated shopping list window: Material | Qty | Unit | Cost | Remove.
	Rows scroll with the mouse wheel when the list exceeds the visible area.
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.ShoppingListUI = CCC.ShoppingListUI or {}
local SLUI = CCC.ShoppingListUI

local COL = {
	iconX = 0, iconW = 24,
	nameX = 28, nameW = 192,
	qtyX = 228, qtyW = 48,
	unitX = 284, unitW = 88,
	subX = 380, subW = 100,
	rmX = 488, rmW = 28,
}
local ROW_HEIGHT = 26
local MAX_ROW_CONTROLS = 16
local WINDOW_WIDTH = 540
local WINDOW_HEIGHT = 520
local CONTENT_WIDTH = COL.rmX + COL.rmW
local PAD = 18
local FOOTER_HEIGHT = 72
local LIST_BOTTOM_Y = -(FOOTER_HEIGHT + 10)

local COLOR_HEADER = {0.65, 0.65, 0.65, 1}
local COLOR_NORMAL = {0.92, 0.92, 0.92, 1}
local COLOR_MISSING = {1.0, 0.55, 0.55, 1}
local COLOR_GOLD = {0.95, 0.85, 0.4, 1}
local COLOR_MUTED = {0.72, 0.72, 0.72, 1}

function SLUI:Init(addon)
	SLUI.addon = addon
	SLUI.rows = {}
	SLUI.entries = {}
	SLUI.scrollOffset = 0
	SLUI:CreateWindow()
end

local function makeLabel(wm, name, parent, font)
	local label = wm:CreateControl(name, parent, CT_LABEL)
	label:SetFont(font or "ZoFontGame")
	label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
	label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	label:SetMouseEnabled(false)
	return label
end

local function setLabelColor(label, color)
	label:SetColor(color[1], color[2], color[3], color[4])
end

local function goldText(amount)
	return CCC.Utilities:FormatGoldText(amount, 0)
end

local function makeTextButton(wm, name, parent, text, w, h)
	local btn = wm:CreateControl(name, parent, CT_BUTTON)
	btn:SetDimensions(w, h)
	btn:SetFont("ZoFontGameBold")
	btn:SetNormalFontColor(0.85, 0.78, 0.55, 1)
	btn:SetMouseOverFontColor(1.0, 0.92, 0.7, 1)
	btn:SetPressedFontColor(0.7, 0.62, 0.4, 1)
	btn:SetDisabledFontColor(0.45, 0.45, 0.45, 1)
	btn:SetText(text)
	btn:SetMouseEnabled(true)
	return btn
end

function SLUI:CreateColumnHeader(wm, parent)
	local header = wm:CreateControl(CCC.Name .. "SLHeader", parent, CT_CONTROL)
	header:SetDimensions(CONTENT_WIDTH, ROW_HEIGHT)
	header:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)

	local function headerCell(suffix, x, w, text, align)
		local label = makeLabel(wm, CCC.Name .. "SLHeader" .. suffix, header, "ZoFontGameSmall")
		label:SetDimensions(w, ROW_HEIGHT)
		label:SetAnchor(TOPLEFT, header, TOPLEFT, x, 0)
		label:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT)
		setLabelColor(label, COLOR_HEADER)
		label:SetText(text)
		return label
	end

	headerCell("Name", COL.nameX, COL.nameW, "Material", TEXT_ALIGN_LEFT)
	headerCell("Qty", COL.qtyX, COL.qtyW, "Qty", TEXT_ALIGN_RIGHT)
	headerCell("Unit", COL.unitX, COL.unitW, "Unit", TEXT_ALIGN_RIGHT)
	headerCell("Sub", COL.subX, COL.subW, "Cost", TEXT_ALIGN_RIGHT)
	headerCell("Rm", COL.rmX, COL.rmW, "", TEXT_ALIGN_CENTER)

	local rule = wm:CreateControl(CCC.Name .. "SLHeaderRule", parent, CT_TEXTURE)
	rule:SetDimensions(CONTENT_WIDTH, 1)
	rule:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, 2)
	rule:SetColor(0.55, 0.48, 0.32, 0.7)

	SLUI.header = header
	SLUI.headerRule = rule
end

function SLUI:CreateRow(index)
	local wm = GetWindowManager()
	local parent = SLUI.listContainer
	local row = wm:CreateControl(CCC.Name .. "SLRow" .. index, parent, CT_CONTROL)
	row:SetDimensions(CONTENT_WIDTH, ROW_HEIGHT)
	row:SetHidden(true)
	row:SetMouseEnabled(true)

	local function cell(suffix, x, w, align)
		local label = makeLabel(wm, CCC.Name .. "SLRow" .. index .. suffix, row, "ZoFontGame")
		label:SetDimensions(w, ROW_HEIGHT)
		label:SetAnchor(TOPLEFT, row, TOPLEFT, x, 0)
		label:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT)
		setLabelColor(label, COLOR_NORMAL)
		return label
	end

	local icon = wm:CreateControl(CCC.Name .. "SLRow" .. index .. "Icon", row, CT_TEXTURE)
	icon:SetDimensions(22, 22)
	icon:SetAnchor(TOPLEFT, row, TOPLEFT, COL.iconX, 2)
	icon:SetDrawLevel(1)
	icon:SetHidden(true)
	row.icon = icon

	row.nameLabel = cell("Name", COL.nameX, COL.nameW, TEXT_ALIGN_LEFT)
	row.qtyLabel = cell("Qty", COL.qtyX, COL.qtyW, TEXT_ALIGN_RIGHT)
	row.unitLabel = cell("Unit", COL.unitX, COL.unitW, TEXT_ALIGN_RIGHT)
	row.subLabel = cell("Sub", COL.subX, COL.subW, TEXT_ALIGN_RIGHT)

	local stripe = wm:CreateControl(CCC.Name .. "SLRow" .. index .. "Stripe", row, CT_TEXTURE)
	stripe:SetAnchorFill(row)
	stripe:SetDrawLevel(0)
	stripe:SetColor(1, 1, 1, (index % 2 == 0) and 0.04 or 0)
	row.stripe = stripe

	local removeBtn = makeTextButton(wm, CCC.Name .. "SLRow" .. index .. "Rm", row, "", COL.rmW, ROW_HEIGHT - 4)
	removeBtn:SetAnchor(TOPLEFT, row, TOPLEFT, COL.rmX, 2)
	removeBtn:SetDrawLevel(1)
	CCC.Utilities:ApplyRemoveButtonTextures(removeBtn)
	removeBtn:SetHandler("OnClicked", function()
		if row.itemId then
			SLUI.addon.ShoppingList:Remove(row.itemId)
			SLUI:Refresh()
		end
	end)
	row.removeBtn = removeBtn

	row.nameLabel:SetDrawLevel(1)
	row.qtyLabel:SetDrawLevel(1)
	row.unitLabel:SetDrawLevel(1)
	row.subLabel:SetDrawLevel(1)

	-- Wheel events over rows should still scroll the list.
	row:SetHandler("OnMouseWheel", function(_, delta)
		SLUI:OnScroll(delta)
	end)

	SLUI.rows[index] = row
	return row
end

function SLUI:GetRow(index)
	return SLUI.rows[index] or SLUI:CreateRow(index)
end

function SLUI:GetVisibleRowCapacity()
	if not SLUI.listContainer then
		return 8
	end
	local height = SLUI.listContainer:GetHeight() or 0
	if height < ROW_HEIGHT then
		return 1
	end
	return math.min(MAX_ROW_CONTROLS, math.max(1, math.floor(height / ROW_HEIGHT)))
end

function SLUI:OnScroll(delta)
	local count = #(SLUI.entries or {})
	local capacity = SLUI:GetVisibleRowCapacity()
	local maxOff = math.max(0, count - capacity)
	SLUI.scrollOffset = zo_clamp(SLUI.scrollOffset - delta, 0, maxOff)
	SLUI:PopulateRows()
	SLUI:UpdateScrollNote(count, capacity)
end

function SLUI:CreateWindow()
	local wm = GetWindowManager()
	local control = wm:CreateTopLevelWindow(CCC.Name .. "SLWindow")
	control:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
	control:SetAnchor(CENTER, GuiRoot, CENTER, 40, 40)
	control:SetMovable(true)
	control:SetMouseEnabled(true)
	control:SetClampedToScreen(true)
	control:SetHidden(true)
	control:SetDrawLayer(DL_OVERLAY)

	local bg = wm:CreateControl(CCC.Name .. "SLWindowBG", control, CT_BACKDROP)
	bg:SetAnchorFill(control)
	bg:SetCenterColor(0.06, 0.06, 0.07, 0.96)
	bg:SetEdgeColor(0.55, 0.48, 0.32, 1)
	bg:SetEdgeTexture("", 1, 1, 2)

	local title = makeLabel(wm, CCC.Name .. "SLWindowTitle", control, "ZoFontWinH2")
	title:SetColor(0.85, 0.78, 0.55, 1)
	title:SetAnchor(TOPLEFT, control, TOPLEFT, PAD, 14)
	title:SetText(GetString(CCC_SHOPPING_LIST_TITLE))

	local closeBtn = makeTextButton(wm, CCC.Name .. "SLWindowClose", control, "", 28, 28)
	closeBtn:SetAnchor(TOPRIGHT, control, TOPRIGHT, -10, 10)
	CCC.Utilities:ApplyCloseButtonTextures(closeBtn)
	closeBtn:SetHandler("OnClicked", function()
		control:SetHidden(true)
	end)

	local subtitle = makeLabel(wm, CCC.Name .. "SLWindowSubtitle", control, "ZoFontGameSmall")
	setLabelColor(subtitle, COLOR_MUTED)
	subtitle:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 6)
	subtitle:SetDimensions(CONTENT_WIDTH - 260, 20)
	SLUI.subtitleLabel = subtitle

	local clearBtn = makeTextButton(wm, CCC.Name .. "SLWindowClear", control, GetString(CCC_SHOPPING_LIST_CLEAR), 110, 24)
	clearBtn:SetAnchor(TOPRIGHT, control, TOPRIGHT, -44, 40)
	clearBtn:SetHandler("OnClicked", function()
		SLUI.addon.ShoppingList:Clear()
		SLUI.scrollOffset = 0
		SLUI:Refresh()
		d(GetString(CCC_MSG_SHOPPING_LIST_CLEARED))
	end)
	SLUI.clearBtn = clearBtn

	local addMaterialBtn = makeTextButton(wm, CCC.Name .. "SLWindowAddMaterial", control,
		GetString(CCC_SHOPPING_LIST_ADD_MATERIAL), 140, 24)
	addMaterialBtn:SetAnchor(RIGHT, clearBtn, LEFT, -12, 0)
	addMaterialBtn:SetHandler("OnClicked", function()
		if SLUI.addon.MaterialSearchWindow then
			SLUI.addon.MaterialSearchWindow:Show()
		end
	end)
	SLUI.addMaterialBtn = addMaterialBtn

	local footerRule = wm:CreateControl(CCC.Name .. "SLWindowFooterRule", control, CT_TEXTURE)
	footerRule:SetDimensions(CONTENT_WIDTH, 1)
	footerRule:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, PAD, -(FOOTER_HEIGHT + 6))
	footerRule:SetColor(0.55, 0.48, 0.32, 0.7)

	local note = makeLabel(wm, CCC.Name .. "SLWindowNote", control, "ZoFontGameSmall")
	setLabelColor(note, {1.0, 0.72, 0.42, 1})
	note:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, PAD, -52)
	note:SetDimensions(CONTENT_WIDTH, 16)
	SLUI.noteLabel = note

	local total = makeLabel(wm, CCC.Name .. "SLWindowTotal", control, "ZoFontWinH3")
	setLabelColor(total, COLOR_GOLD)
	total:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, PAD, -16)
	total:SetDimensions(CONTENT_WIDTH, 24)
	SLUI.totalLabel = total

	-- List fills the space between header and footer (no overflow).
	local listHost = wm:CreateControl(CCC.Name .. "SLWindowListHost", control, CT_CONTROL)
	listHost:SetAnchor(TOPLEFT, subtitle, BOTTOMLEFT, 0, 8)
	listHost:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, PAD, LIST_BOTTOM_Y)
	listHost:SetWidth(CONTENT_WIDTH)
	listHost:SetMouseEnabled(true)
	listHost:SetHandler("OnMouseWheel", function(_, delta)
		SLUI:OnScroll(delta)
	end)
	SLUI.listHost = listHost

	SLUI:CreateColumnHeader(wm, listHost)

	local listContainer = wm:CreateControl(CCC.Name .. "SLWindowList", listHost, CT_CONTROL)
	listContainer:SetAnchor(TOPLEFT, SLUI.headerRule, BOTTOMLEFT, 0, 4)
	listContainer:SetAnchor(BOTTOMLEFT, listHost, BOTTOMLEFT, 0, 0)
	listContainer:SetWidth(CONTENT_WIDTH)
	listContainer:SetMouseEnabled(true)
	listContainer:SetHandler("OnMouseWheel", function(_, delta)
		SLUI:OnScroll(delta)
	end)
	SLUI.listContainer = listContainer

	for i = 1, MAX_ROW_CONTROLS do
		SLUI:CreateRow(i)
	end

	local emptyIcon = CCC.Utilities:CreateEmptyPlaceholder(wm, CCC.Name .. "SLWindowEmptyIcon",
		listContainer, CCC.Utilities.ICON_PATHS.emptyBag, 48)
	emptyIcon:SetAnchor(CENTER, listContainer, CENTER, 0, -18)
	SLUI.emptyIcon = emptyIcon

	local empty = makeLabel(wm, CCC.Name .. "SLWindowEmpty", control, "ZoFontGame")
	setLabelColor(empty, COLOR_MUTED)
	empty:SetAnchor(TOP, emptyIcon, BOTTOM, 0, 8)
	empty:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	empty:SetText(GetString(CCC_SHOPPING_LIST_EMPTY))
	empty:SetHidden(true)
	SLUI.emptyLabel = empty

	SLUI.window = control
end

function SLUI:ClearRows()
	for i = 1, #SLUI.rows do
		local row = SLUI.rows[i]
		row:SetHidden(true)
		row.itemId = nil
		CCC.Utilities:ApplyItemIcon(row.icon, nil)
	end
end

function SLUI:PopulateRows()
	SLUI:ClearRows()

	local entries = SLUI.entries or {}
	local capacity = SLUI:GetVisibleRowCapacity()
	local maxOff = math.max(0, #entries - capacity)
	SLUI.scrollOffset = zo_clamp(SLUI.scrollOffset or 0, 0, maxOff)

	for i = 1, capacity do
		local dataIndex = SLUI.scrollOffset + i
		local entry = entries[dataIndex]
		local row = SLUI:GetRow(i)
		if not entry then
			row:SetHidden(true)
			row.itemId = nil
			CCC.Utilities:ApplyItemIcon(row.icon, nil)
		else
			row:ClearAnchors()
			row:SetAnchor(TOPLEFT, SLUI.listContainer, TOPLEFT, 0, (i - 1) * ROW_HEIGHT)
			row:SetHidden(false)
			row.itemId = entry.itemId

			row.stripe:SetColor(1, 1, 1, (dataIndex % 2 == 0) and 0.04 or 0)

			local color = entry.missing and COLOR_MISSING or COLOR_NORMAL
			setLabelColor(row.nameLabel, color)
			setLabelColor(row.qtyLabel, color)
			setLabelColor(row.unitLabel, color)
			setLabelColor(row.subLabel, color)

			CCC.Utilities:ApplyItemIcon(row.icon,
				CCC.Utilities:ResolveItemIcon(entry.itemLink, entry.icon))

			row.nameLabel:SetText(zo_strformat("<<1>>", entry.name or "?"))
			row.qtyLabel:SetText(tostring(entry.quantity or 0))

			if entry.missing then
				row.unitLabel:SetText("N/A")
				row.subLabel:SetText("N/A")
			else
				row.unitLabel:SetText(goldText(entry.unitPrice))
				row.subLabel:SetText(goldText(entry.subtotal))
			end
		end
	end

	-- Hide unused pooled rows beyond capacity.
	for i = capacity + 1, #SLUI.rows do
		SLUI.rows[i]:SetHidden(true)
		SLUI.rows[i].itemId = nil
		CCC.Utilities:ApplyItemIcon(SLUI.rows[i].icon, nil)
	end
end

function SLUI:UpdateScrollNote(count, capacity, missingCount)
	local notes = {}
	local maxOff = math.max(0, count - capacity)
	if maxOff > 0 then
		local from = SLUI.scrollOffset + 1
		local to = math.min(count, SLUI.scrollOffset + capacity)
		notes[#notes + 1] = string.format("%d–%d of %d  ·  scroll for more", from, to, count)
	end
	if missingCount and missingCount > 0 and SLUI.addon.Settings.showMissingPrices then
		notes[#notes + 1] = zo_strformat(GetString(CCC_MSG_MISSING_PRICES), missingCount)
	end
	local noteText = table.concat(notes, "  ·  ")
	if noteText ~= "" and missingCount and missingCount > 0 and SLUI.addon.Settings.showMissingPrices then
		noteText = CCC.Utilities:FormatStatusText("warn", noteText)
	end
	SLUI.noteLabel:SetText(noteText)
end

function SLUI:Refresh()
	if not SLUI.window then
		return
	end

	local entries, total, complete, missingCount = SLUI.addon.ShoppingList:GetPricedEntries()
	local count = #entries
	SLUI.entries = entries

	SLUI.subtitleLabel:SetText(zo_strformat(GetString(CCC_SHOPPING_LIST_COUNT), count))
	SLUI.clearBtn:SetEnabled(count > 0)
	local empty = count == 0
	SLUI.emptyLabel:SetHidden(not empty)
	if SLUI.emptyIcon then
		SLUI.emptyIcon:SetHidden(not empty)
	end

	local capacity = SLUI:GetVisibleRowCapacity()
	local maxOff = math.max(0, count - capacity)
	SLUI.scrollOffset = zo_clamp(SLUI.scrollOffset or 0, 0, maxOff)

	SLUI:PopulateRows()
	SLUI:UpdateScrollNote(count, capacity, missingCount)

	if count == 0 then
		SLUI.totalLabel:SetText(GetString(CCC_SHOPPING_LIST_TOTAL_EMPTY))
	elseif complete then
		SLUI.totalLabel:SetText(zo_strformat(GetString(CCC_SHOPPING_LIST_TOTAL),
			CCC.Utilities:FormatGoldText(total, 0)))
	else
		SLUI.totalLabel:SetText(zo_strformat(GetString(CCC_SHOPPING_LIST_TOTAL_PARTIAL),
			CCC.Utilities:FormatGoldText(total, 0)))
	end
end

function SLUI:Show()
	if not SLUI.window then
		return
	end
	SLUI:Refresh()
	SLUI.window:SetHidden(false)
end

function SLUI:Toggle()
	if not SLUI.window then
		return
	end
	if SLUI.window:IsHidden() then
		SLUI:Show()
	else
		SLUI.window:SetHidden(true)
	end
end

function SLUI:IsVisible()
	return SLUI.window and not SLUI.window:IsHidden()
end
