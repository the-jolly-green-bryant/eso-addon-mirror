--[[
	BuildCostUI
	Dedicated Build Cost Calculator window (separate from single-item UI).

	Import CCC export → equipment table → lazy per-piece craft costs →
	expandable material breakdown → totals → shopping list.
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.BuildCostUI = CCC.BuildCostUI or {}
local BCUI = CCC.BuildCostUI

local WINDOW_WIDTH = 1040
local WINDOW_HEIGHT = 760
local PAD = 16
local CONTENT_WIDTH = WINDOW_WIDTH - (PAD * 2)
local ROW_HEIGHT = 24
local MAT_ROW_HEIGHT = 22
local MAX_ROW_CONTROLS = 16 -- pooled row controls; visible count is computed from height
local IMPORT_HEIGHT = 88
local IMPORT_COLLAPSED_HEIGHT = 28
local FOOTER_HEIGHT = 72
local FILTER_HEIGHT = 26
local SUMMARY_HEIGHT = 36

-- Equipment columns
local COL = {
	expX = 0, expW = 26,
	slotX = 28, slotW = 78,
	setX = 108, setW = 138,
	typeX = 250, typeW = 62,
	weightX = 316, weightW = 62,
	traitX = 382, traitW = 82,
	enchX = 468, enchW = 96,
	qualX = 568, qualW = 48,
	lvlX = 620, lvlW = 52,
	craftX = 676, craftW = 48,
	fullCostX = 728, fullCostW = 100,
	missCostX = 832, missCostW = 100,
}

-- Material sub-row columns (indented)
local MCOL = {
	iconX = 40, iconW = 22,
	nameX = 66, nameW = 174,
	needX = 248, needW = 56,
	ownX = 308, ownW = 56,
	missX = 368, missW = 56,
	unitX = 432, unitW = 88,
	subX = 528, subW = 100,
}

local COLOR_HEADER = {0.65, 0.65, 0.65, 1}
local COLOR_NORMAL = {0.92, 0.92, 0.92, 1}
local COLOR_MISSING = {1.0, 0.55, 0.55, 1}
local COLOR_OWNED = {0.45, 0.85, 0.55, 1}
local COLOR_GOLD = {0.95, 0.85, 0.4, 1}
local COLOR_MUTED = {0.72, 0.72, 0.72, 1}
local COLOR_TITLE = {0.85, 0.78, 0.55, 1}
local COLOR_WARN = {1.0, 0.72, 0.42, 1}
local COLOR_MAT = {0.78, 0.78, 0.82, 1}

local PLACEHOLDER = "Paste your CCC Build Export here...\n\nExample:\nCCC1:eyJ2IjoxLCJuIjoiLi4uIn0="

local FILTERS = {
	{ id = "all", label = "All" },
	{ id = "costed", label = "With Cost" },
	{ id = "mythics", label = "Mythics" },
	{ id = "skipped", label = "Skipped" },
	{ id = "weapons", label = "Weapons" },
	{ id = "armor", label = "Armor" },
	{ id = "jewelry", label = "Jewelry" },
}

function BCUI:Init(addon)
	BCUI.addon = addon
	BCUI.rows = {}
	BCUI.filterButtons = {}
	BCUI.scrollOffset = 0
	BCUI.placeholderActive = true
	BCUI.importExpanded = true
	BCUI:CreateWindow()

	addon.BuildCostCalculator:SetUpdateCallback(function()
		if BCUI:IsVisible() then
			BCUI:Refresh()
		end
	end)
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

function BCUI:CreateWindow()
	local wm = GetWindowManager()
	local control = wm:CreateTopLevelWindow(CCC.Name .. "BuildWindow")
	control:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
	control:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	control:SetMovable(true)
	control:SetMouseEnabled(true)
	control:SetClampedToScreen(true)
	control:SetHidden(true)
	control:SetDrawLayer(DL_OVERLAY)
	control:SetResizeHandleSize(8)
	control:SetHandler("OnRectChanged", function()
		if BCUI:IsVisible() then
			BCUI:Refresh()
		end
	end)

	local bg = wm:CreateControl(CCC.Name .. "BuildWindowBG", control, CT_BACKDROP)
	bg:SetAnchorFill(control)
	bg:SetCenterColor(0.06, 0.06, 0.07, 0.96)
	bg:SetEdgeColor(0.55, 0.48, 0.32, 1)
	bg:SetEdgeTexture("", 1, 1, 2)

	local title = makeLabel(wm, CCC.Name .. "BuildWindowTitle", control, "ZoFontWinH2")
	setLabelColor(title, COLOR_TITLE)
	title:SetAnchor(TOPLEFT, control, TOPLEFT, PAD, 12)
	title:SetText(GetString(CCC_BUILD_TITLE))

	local closeBtn = makeTextButton(wm, CCC.Name .. "BuildWindowClose", control, "", 28, 28)
	closeBtn:SetAnchor(TOPRIGHT, control, TOPRIGHT, -10, 8)
	CCC.Utilities:ApplyCloseButtonTextures(closeBtn)
	closeBtn:SetHandler("OnClicked", function()
		control:SetHidden(true)
	end)

	-- Import section (expandable — collapses after a successful import)
	local importHost = wm:CreateControl(CCC.Name .. "BuildImportHost", control, CT_CONTROL)
	importHost:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 10)
	importHost:SetDimensions(CONTENT_WIDTH, IMPORT_HEIGHT + 40)
	BCUI.importHost = importHost

	-- Collapsed bar (shown after import)
	local collapsedHost = wm:CreateControl(CCC.Name .. "BuildImportCollapsed", importHost, CT_CONTROL)
	collapsedHost:SetAnchor(TOPLEFT, importHost, TOPLEFT, 0, 0)
	collapsedHost:SetDimensions(CONTENT_WIDTH, IMPORT_COLLAPSED_HEIGHT)
	collapsedHost:SetHidden(true)
	BCUI.collapsedHost = collapsedHost

	local collapsedLabel = makeLabel(wm, CCC.Name .. "BuildImportedLabel", collapsedHost, "ZoFontGame")
	setLabelColor(collapsedLabel, COLOR_NORMAL)
	collapsedLabel:SetAnchor(LEFT, collapsedHost, LEFT, 0, 0)
	collapsedLabel:SetDimensions(CONTENT_WIDTH - 240, IMPORT_COLLAPSED_HEIGHT)
	BCUI.collapsedLabel = collapsedLabel

	local changeBtn = makeTextButton(wm, CCC.Name .. "BuildChangeImportBtn", collapsedHost,
		GetString(CCC_BUILD_BTN_CHANGE_IMPORT), 120, 24)
	changeBtn:SetAnchor(RIGHT, collapsedHost, RIGHT, -90, 0)
	changeBtn:SetHandler("OnClicked", function()
		BCUI:SetImportExpanded(true)
	end)

	local clearCollapsedBtn = makeTextButton(wm, CCC.Name .. "BuildClearCollapsedBtn", collapsedHost,
		GetString(CCC_BUILD_BTN_CLEAR), 80, 24)
	clearCollapsedBtn:SetAnchor(RIGHT, collapsedHost, RIGHT, 0, 0)
	clearCollapsedBtn:SetHandler("OnClicked", function()
		BCUI:OnClear()
	end)

	-- Expanded paste UI
	local expandedHost = wm:CreateControl(CCC.Name .. "BuildImportExpanded", importHost, CT_CONTROL)
	expandedHost:SetAnchor(TOPLEFT, importHost, TOPLEFT, 0, 0)
	expandedHost:SetDimensions(CONTENT_WIDTH, IMPORT_HEIGHT + 40)
	BCUI.expandedHost = expandedHost

	local importLabel = makeLabel(wm, CCC.Name .. "BuildImportLabel", expandedHost, "ZoFontGameSmall")
	setLabelColor(importLabel, COLOR_HEADER)
	importLabel:SetAnchor(TOPLEFT, expandedHost, TOPLEFT, 0, 0)
	importLabel:SetText(GetString(CCC_BUILD_IMPORT_LABEL))
	BCUI.importLabel = importLabel

	-- ESO requires virtual edit templates — raw CT_EDITBOX is not reliably editable.
	local editBg = wm:CreateControlFromVirtual(CCC.Name .. "BuildEditBG", expandedHost, "ZO_EditBackdrop")
	editBg:SetDimensions(CONTENT_WIDTH, IMPORT_HEIGHT)
	editBg:SetAnchor(TOPLEFT, importLabel, BOTTOMLEFT, 0, 4)
	editBg:SetMouseEnabled(true)
	editBg:SetDrawLevel(2)

	local editBox = wm:CreateControlFromVirtual(
		CCC.Name .. "BuildEdit",
		editBg,
		"ZO_DefaultEditMultiLineForBackdrop"
	)
	-- Fallback if the multiline virtual is unavailable on this client.
	if not editBox then
		editBox = wm:CreateControlFromVirtual(
			CCC.Name .. "BuildEdit",
			editBg,
			"ZO_DefaultEditForBackdrop"
		)
	end
	editBox:SetAnchor(TOPLEFT, editBg, TOPLEFT, 6, 4)
	editBox:SetAnchor(BOTTOMRIGHT, editBg, BOTTOMRIGHT, -6, -4)
	editBox:SetFont("ZoFontGameSmall")
	editBox:SetColor(0.9, 0.9, 0.9, 1)
	editBox:SetMaxInputChars(24000)
	editBox:SetMouseEnabled(true)
	editBox:SetDrawLevel(3)
	if editBox.SetEditEnabled then
		editBox:SetEditEnabled(true)
	end
	if editBox.SetMultiLine then
		editBox:SetMultiLine(true)
	end
	editBox:SetText(PLACEHOLDER)

	local function focusImportEdit()
		if editBox.TakeFocus then
			editBox:TakeFocus()
		end
	end

	editBg:SetHandler("OnMouseUp", function()
		focusImportEdit()
	end)
	editBox:SetHandler("OnMouseDown", function()
		focusImportEdit()
	end)
	editBox:SetHandler("OnFocusGained", function()
		if BCUI.placeholderActive then
			editBox:SetText("")
			BCUI.placeholderActive = false
		end
	end)
	BCUI.editBox = editBox
	BCUI.editBg = editBg
	BCUI.focusImportEdit = focusImportEdit

	local btnRow = wm:CreateControl(CCC.Name .. "BuildBtnRow", expandedHost, CT_CONTROL)
	btnRow:SetAnchor(TOPLEFT, editBg, BOTTOMLEFT, 0, 8)
	btnRow:SetDimensions(CONTENT_WIDTH, 28)
	BCUI.btnRow = btnRow

	local importBtn = makeTextButton(wm, CCC.Name .. "BuildImportBtn", btnRow, GetString(CCC_BUILD_BTN_IMPORT), 120, 26)
	importBtn:SetAnchor(TOPLEFT, btnRow, TOPLEFT, 0, 0)
	importBtn:SetHandler("OnClicked", function()
		BCUI:OnImport()
	end)

	local clearBtn = makeTextButton(wm, CCC.Name .. "BuildClearBtn", btnRow, GetString(CCC_BUILD_BTN_CLEAR), 80, 26)
	clearBtn:SetAnchor(TOPLEFT, importBtn, TOPRIGHT, 10, 0)
	clearBtn:SetHandler("OnClicked", function()
		BCUI:OnClear()
	end)

	local status = makeLabel(wm, CCC.Name .. "BuildStatus", btnRow, "ZoFontGameSmall")
	setLabelColor(status, COLOR_WARN)
	status:SetAnchor(LEFT, clearBtn, RIGHT, 14, 0)
	status:SetDimensions(CONTENT_WIDTH - 230, 26)
	BCUI.statusLabel = status

	-- Summary (anchored below import host — import host height changes when collapsed)
	local summary = makeLabel(wm, CCC.Name .. "BuildSummary", control, "ZoFontGame")
	setLabelColor(summary, COLOR_NORMAL)
	summary:SetAnchor(TOPLEFT, importHost, BOTTOMLEFT, 0, 10)
	summary:SetDimensions(CONTENT_WIDTH, SUMMARY_HEIGHT)
	summary:SetMaxLineCount(2)
	summary:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
	BCUI.summaryLabel = summary

	-- Filters
	local filterHost = wm:CreateControl(CCC.Name .. "BuildFilters", control, CT_CONTROL)
	filterHost:SetAnchor(TOPLEFT, summary, BOTTOMLEFT, 0, 6)
	filterHost:SetDimensions(CONTENT_WIDTH, FILTER_HEIGHT)
	BCUI.filterHost = filterHost

	local fx = 0
	for i = 1, #FILTERS do
		local f = FILTERS[i]
		local btn = makeTextButton(wm, CCC.Name .. "BuildFilter" .. f.id, filterHost, f.label, 96, 24)
		btn:SetAnchor(TOPLEFT, filterHost, TOPLEFT, fx, 0)
		btn.filterId = f.id
		btn:SetHandler("OnClicked", function()
			BCUI.addon.BuildCostCalculator:SetFilter(f.id)
			BCUI.scrollOffset = 0
			BCUI:RefreshFilterButtons()
			BCUI:Refresh()
		end)
		BCUI.filterButtons[f.id] = btn
		fx = fx + 102
	end

	-- Footer host first so the list can anchor above it (prevents overlap).
	local footerHost = wm:CreateControl(CCC.Name .. "BuildFooterHost", control, CT_CONTROL)
	footerHost:SetDimensions(CONTENT_WIDTH, FOOTER_HEIGHT)
	footerHost:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, PAD, -PAD)
	footerHost:SetDrawLevel(10)
	BCUI.footerHost = footerHost

	local footerBg = wm:CreateControl(CCC.Name .. "BuildFooterBG", footerHost, CT_BACKDROP)
	footerBg:SetAnchorFill(footerHost)
	footerBg:SetCenterColor(0.06, 0.06, 0.07, 1)
	footerBg:SetEdgeColor(0, 0, 0, 0)
	footerBg:SetDrawLevel(0)

	local footerRule = wm:CreateControl(CCC.Name .. "BuildFooterRule", footerHost, CT_TEXTURE)
	footerRule:SetDimensions(CONTENT_WIDTH, 1)
	footerRule:SetAnchor(TOPLEFT, footerHost, TOPLEFT, 0, 0)
	footerRule:SetColor(0.55, 0.48, 0.32, 0.7)
	footerRule:SetDrawLevel(1)

	local totals = makeLabel(wm, CCC.Name .. "BuildTotals", footerHost, "ZoFontGameSmall")
	setLabelColor(totals, COLOR_MUTED)
	totals:SetAnchor(BOTTOMLEFT, footerHost, BOTTOMLEFT, 0, -4)
	totals:SetDimensions(CONTENT_WIDTH - 230, 20)
	totals:SetMaxLineCount(1)
	totals:SetDrawLevel(2)
	BCUI.totalsLabel = totals

	local totalGold = makeLabel(wm, CCC.Name .. "BuildTotalGold", footerHost, "ZoFontWinH3")
	setLabelColor(totalGold, COLOR_GOLD)
	totalGold:SetAnchor(TOPLEFT, footerHost, TOPLEFT, 0, 12)
	totalGold:SetDimensions(CONTENT_WIDTH - 320, 24)
	totalGold:SetDrawLevel(2)
	BCUI.totalGoldLabel = totalGold

	local shopBtn = makeTextButton(wm, CCC.Name .. "BuildShopBtn", footerHost, GetString(CCC_BUILD_BTN_SHOPPING), 310, 28)
	shopBtn:SetAnchor(BOTTOMRIGHT, footerHost, BOTTOMRIGHT, 0, -4)
	shopBtn:SetEnabled(false)
	shopBtn:SetDrawLevel(2)
	shopBtn:SetHandler("OnClicked", function()
		BCUI:OnAddToShoppingList()
	end)
	BCUI.shopBtn = shopBtn

	-- List fills the gap between filters and footer.
	local listHost = wm:CreateControl(CCC.Name .. "BuildListHost", control, CT_CONTROL)
	listHost:SetAnchor(TOPLEFT, filterHost, BOTTOMLEFT, 0, 8)
	listHost:SetAnchor(BOTTOMRIGHT, footerHost, TOPRIGHT, 0, -8)
	listHost:SetMouseEnabled(true)
	listHost:SetDrawLevel(5)
	listHost:SetHandler("OnMouseWheel", function(_, delta)
		BCUI:OnScroll(delta)
	end)
	BCUI.listHost = listHost

	local listBg = wm:CreateControl(CCC.Name .. "BuildListBG", listHost, CT_BACKDROP)
	listBg:SetAnchorFill(listHost)
	listBg:SetCenterColor(0.05, 0.05, 0.06, 0.5)
	listBg:SetEdgeColor(0.40, 0.36, 0.28, 0.6)
	listBg:SetEdgeTexture("", 1, 1, 1)
	listBg:SetDrawLevel(0)
	listBg:SetMouseEnabled(false)

	BCUI:CreateColumnHeader(wm, listHost)

	local listContainer = wm:CreateControl(CCC.Name .. "BuildList", listHost, CT_CONTROL)
	listContainer:SetAnchor(TOPLEFT, BCUI.headerRule, BOTTOMLEFT, 0, 4)
	listContainer:SetAnchor(BOTTOMRIGHT, listHost, BOTTOMRIGHT, -2, -2)
	listContainer:SetMouseEnabled(true)
	listContainer:SetDrawLevel(1)
	BCUI.listContainer = listContainer

	for i = 1, MAX_ROW_CONTROLS do
		BCUI:CreateRow(i)
	end

	local emptyIcon = CCC.Utilities:CreateEmptyPlaceholder(wm, CCC.Name .. "BuildEmptyIcon",
		listContainer, CCC.Utilities.ICON_PATHS.emptyCraft, 48)
	emptyIcon:SetAnchor(CENTER, listContainer, CENTER, 0, -10)
	BCUI.emptyIcon = emptyIcon

	BCUI.window = control
	BCUI:RefreshFilterButtons()
	BCUI:SetImportExpanded(true)
	BCUI:ShowEmptyState()
end

function BCUI:CreateColumnHeader(wm, parent)
	local header = wm:CreateControl(CCC.Name .. "BuildHeader", parent, CT_CONTROL)
	header:SetDimensions(CONTENT_WIDTH, ROW_HEIGHT)
	header:SetAnchor(TOPLEFT, parent, TOPLEFT, 2, 2)
	header:SetDrawLevel(2)

	local function headerCell(suffix, x, w, text, sortKey, align)
		local label = makeLabel(wm, CCC.Name .. "BuildHeader" .. suffix, header, "ZoFontGameSmall")
		label:SetDimensions(w, ROW_HEIGHT)
		label:SetAnchor(TOPLEFT, header, TOPLEFT, x, 0)
		label:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT)
		setLabelColor(label, COLOR_HEADER)
		label:SetText(text)
		if sortKey then
			label:SetMouseEnabled(true)
			label:SetHandler("OnMouseUp", function()
				BCUI.addon.BuildCostCalculator:SetSort(sortKey)
				BCUI.scrollOffset = 0
				BCUI:Refresh()
			end)
		end
		return label
	end

	headerCell("Exp", COL.expX, COL.expW, "", nil, TEXT_ALIGN_CENTER)
	headerCell("Slot", COL.slotX, COL.slotW, "Slot", "slot")
	headerCell("Set", COL.setX, COL.setW, "Set", "set")
	headerCell("Type", COL.typeX, COL.typeW, "Type", "type")
	headerCell("Weight", COL.weightX, COL.weightW, "Weight", nil)
	headerCell("Trait", COL.traitX, COL.traitW, "Trait", "trait")
	headerCell("Ench", COL.enchX, COL.enchW, "Enchant", nil)
	headerCell("Qual", COL.qualX, COL.qualW, "Quality", "quality")
	headerCell("Lvl", COL.lvlX, COL.lvlW, "Level", nil)
	headerCell("Craft", COL.craftX, COL.craftW, "Craftable", "costable", TEXT_ALIGN_CENTER)
	headerCell("FullCost", COL.fullCostX, COL.fullCostW, "Craft Cost", "fullCost", TEXT_ALIGN_RIGHT)
	headerCell("MissCost", COL.missCostX, COL.missCostW, "Missing", "cost", TEXT_ALIGN_RIGHT)

	local rule = wm:CreateControl(CCC.Name .. "BuildHeaderRule", parent, CT_TEXTURE)
	rule:SetDimensions(CONTENT_WIDTH - 4, 1)
	rule:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, 2)
	rule:SetColor(0.55, 0.48, 0.32, 0.7)
	rule:SetDrawLevel(2)

	BCUI.header = header
	BCUI.headerRule = rule
end

function BCUI:CreateRow(index)
	local wm = GetWindowManager()
	local parent = BCUI.listContainer
	local row = wm:CreateControl(CCC.Name .. "BuildRow" .. index, parent, CT_CONTROL)
	row:SetDimensions(CONTENT_WIDTH - 4, ROW_HEIGHT)
	row:SetHidden(true)
	row:SetMouseEnabled(true)
	row:SetDrawLevel(2)

	local stripe = wm:CreateControl(CCC.Name .. "BuildRow" .. index .. "Stripe", row, CT_TEXTURE)
	stripe:SetAnchorFill(row)
	stripe:SetDrawLevel(0)
	stripe:SetColor(1, 1, 1, 0)
	stripe:SetMouseEnabled(false)
	row.stripe = stripe

	local function cell(suffix, x, w, align, font)
		local label = makeLabel(wm, CCC.Name .. "BuildRow" .. index .. suffix, row, font or "ZoFontGameSmall")
		label:SetDimensions(w, ROW_HEIGHT)
		label:SetAnchor(TOPLEFT, row, TOPLEFT, x, 0)
		label:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT)
		setLabelColor(label, COLOR_NORMAL)
		label:SetDrawLevel(1)
		return label
	end

	local function toggleThisRow()
		if row.entryIndex then
			BCUI.addon.BuildCostCalculator:ToggleExpanded(row.entryIndex)
			BCUI:Refresh()
		end
	end

	row.expBtn = makeTextButton(wm, CCC.Name .. "BuildRow" .. index .. "Exp", row, "", COL.expW, ROW_HEIGHT - 4)
	row.expBtn:SetAnchor(TOPLEFT, row, TOPLEFT, COL.expX, 2)
	row.expBtn:SetDrawLevel(5)
	row.expBtn:SetMouseEnabled(true)
	CCC.Utilities:ApplyExpandButtonTextures(row.expBtn, false)
	-- Text-only CT_BUTTONs are unreliable with OnClicked; use OnMouseUp.
	row.expBtn:SetHandler("OnMouseUp", function(_, _button, upInside)
		if upInside then
			toggleThisRow()
		end
	end)

	row.slotLabel = cell("Slot", COL.slotX, COL.slotW)
	row.setLabel = cell("Set", COL.setX, COL.setW)
	row.typeLabel = cell("Type", COL.typeX, COL.typeW)
	row.weightLabel = cell("Weight", COL.weightX, COL.weightW)
	row.traitLabel = cell("Trait", COL.traitX, COL.traitW)
	row.enchLabel = cell("Ench", COL.enchX, COL.enchW)
	row.qualLabel = cell("Qual", COL.qualX, COL.qualW)
	row.lvlLabel = cell("Lvl", COL.lvlX, COL.lvlW)
	row.craftLabel = cell("Craft", COL.craftX, COL.craftW, TEXT_ALIGN_CENTER)
	row.fullCostLabel = cell("FullCost", COL.fullCostX, COL.fullCostW, TEXT_ALIGN_RIGHT)
	row.costLabel = cell("Cost", COL.missCostX, COL.missCostW, TEXT_ALIGN_RIGHT)

	-- Material-mode labels (reuse row; hide piece labels when showing mats)
	local matIcon = wm:CreateControl(CCC.Name .. "BuildRow" .. index .. "MatIcon", row, CT_TEXTURE)
	matIcon:SetDimensions(20, 20)
	matIcon:SetAnchor(TOPLEFT, row, TOPLEFT, MCOL.iconX, 2)
	matIcon:SetDrawLevel(1)
	matIcon:SetHidden(true)
	row.matIcon = matIcon

	row.matName = cell("MatName", MCOL.nameX, MCOL.nameW)
	row.matNeed = cell("MatNeed", MCOL.needX, MCOL.needW, TEXT_ALIGN_RIGHT)
	row.matOwn = cell("MatOwn", MCOL.ownX, MCOL.ownW, TEXT_ALIGN_RIGHT)
	row.matMiss = cell("MatMiss", MCOL.missX, MCOL.missW, TEXT_ALIGN_RIGHT)
	row.matUnit = cell("MatUnit", MCOL.unitX, MCOL.unitW, TEXT_ALIGN_RIGHT)
	row.matSub = cell("MatSub", MCOL.subX, MCOL.subW, TEXT_ALIGN_RIGHT)

	row.msgLabel = cell("Msg", 40, CONTENT_WIDTH - 50)
	setLabelColor(row.msgLabel, COLOR_WARN)

	BCUI.rows[index] = row
	return row
end

function BCUI:GetRow(index)
	return BCUI.rows[index] or BCUI:CreateRow(index)
end

function BCUI:RefreshFilterButtons()
	local active = BCUI.addon.BuildCostCalculator:GetFilter()
	for id, btn in pairs(BCUI.filterButtons) do
		if id == active then
			btn:SetNormalFontColor(1.0, 0.92, 0.7, 1)
		else
			btn:SetNormalFontColor(0.85, 0.78, 0.55, 1)
		end
	end
end

function BCUI:GetVisibleRowCapacity()
	if not BCUI.listContainer then
		return 8
	end
	local height = BCUI.listContainer:GetHeight() or 0
	if height < ROW_HEIGHT then
		return 1
	end
	return math.min(MAX_ROW_CONTROLS, math.max(1, math.floor(height / ROW_HEIGHT)))
end

function BCUI:OnScroll(delta)
	local rows = BCUI.addon.BuildCostCalculator:GetDisplayRows()
	local capacity = BCUI:GetVisibleRowCapacity()
	local maxOff = math.max(0, #rows - capacity)
	BCUI.scrollOffset = zo_clamp(BCUI.scrollOffset - delta, 0, maxOff)
	BCUI:Refresh()
end

function BCUI:SetPieceMode(row, enabled)
	row.expBtn:SetHidden(not enabled)
	row.slotLabel:SetHidden(not enabled)
	row.setLabel:SetHidden(not enabled)
	row.typeLabel:SetHidden(not enabled)
	row.weightLabel:SetHidden(not enabled)
	row.traitLabel:SetHidden(not enabled)
	row.enchLabel:SetHidden(not enabled)
	row.qualLabel:SetHidden(not enabled)
	row.lvlLabel:SetHidden(not enabled)
	row.craftLabel:SetHidden(not enabled)
	row.fullCostLabel:SetHidden(not enabled)
	row.costLabel:SetHidden(not enabled)
end

function BCUI:SetMatMode(row, enabled)
	if not enabled then
		CCC.Utilities:ApplyItemIcon(row.matIcon, nil)
	end
	row.matName:SetHidden(not enabled)
	row.matNeed:SetHidden(not enabled)
	row.matOwn:SetHidden(not enabled)
	row.matMiss:SetHidden(not enabled)
	row.matUnit:SetHidden(not enabled)
	row.matSub:SetHidden(not enabled)
end

function BCUI:ClearRow(row)
	row:SetHidden(true)
	row.entryIndex = nil
	row.msgLabel:SetHidden(true)
	BCUI:SetPieceMode(row, false)
	BCUI:SetMatMode(row, false)
	row.expBtn:SetHidden(true)
	CCC.Utilities:ApplyItemIcon(row.matIcon, nil)
end

function BCUI:PopulatePieceRow(row, entry, stripeIndex)
	local resolver = BCUI.addon.BuildPieceResolver
	local piece = entry.piece
	local category = entry.category

	BCUI:SetPieceMode(row, true)
	BCUI:SetMatMode(row, false)
	row.msgLabel:SetHidden(true)
	row.expBtn:SetHidden(false)
	CCC.Utilities:ApplyExpandButtonTextures(row.expBtn, entry.expanded)
	row.entryIndex = entry.index

	row.stripe:SetColor(1, 1, 1, (stripeIndex % 2 == 0) and 0.045 or 0)

	local color = entry.costable and COLOR_NORMAL or COLOR_MUTED
	if entry.isMythic then
		color = COLOR_WARN
	elseif entry.calcState == "error" then
		color = COLOR_MISSING
	end

	local labels = {
		row.slotLabel, row.setLabel, row.typeLabel, row.weightLabel,
		row.traitLabel, row.enchLabel, row.qualLabel, row.lvlLabel,
		row.craftLabel, row.fullCostLabel, row.costLabel,
	}
	for i = 1, #labels do
		setLabelColor(labels[i], color)
	end

	row.slotLabel:SetText(resolver:GetSlotLabel(piece.slot))
	row.setLabel:SetText(piece.setName or "—")
	row.typeLabel:SetText(resolver:GetItemTypeLabel(piece, category))
	row.weightLabel:SetText(resolver:GetWeightLabel(piece, category))
	row.traitLabel:SetText(piece.trait or "—")
	row.enchLabel:SetText(piece.enchantment or "—")
	row.qualLabel:SetText(resolver:GetQualityLabel(piece.quality or (entry.craftInfo and entry.craftInfo.quality)))

	local lvl
	if piece.isChampionPoint or (entry.craftInfo and entry.craftInfo.isCP) then
		lvl = "CP" .. tostring(piece.level or (entry.craftInfo and entry.craftInfo.level) or 160)
	else
		lvl = "Lv " .. tostring(piece.level or (entry.craftInfo and entry.craftInfo.level) or "—")
	end
	row.lvlLabel:SetText(lvl)

	if entry.isMythic then
		setLabelColor(row.craftLabel, COLOR_WARN)
		row.craftLabel:SetText("Mythic")
	elseif entry.costable then
		setLabelColor(row.craftLabel, COLOR_OWNED)
		row.craftLabel:SetText("Yes")
	else
		setLabelColor(row.craftLabel, COLOR_MISSING)
		row.craftLabel:SetText("No")
	end

	if entry.calcState == "pending" then
		row.fullCostLabel:SetText("…")
		row.costLabel:SetText("…")
	elseif entry.calcState == "error" then
		setLabelColor(row.fullCostLabel, COLOR_MISSING)
		setLabelColor(row.costLabel, COLOR_MISSING)
		row.fullCostLabel:SetText("Error")
		row.costLabel:SetText("Error")
	elseif entry.calcState == "skipped" then
		row.fullCostLabel:SetText("—")
		row.costLabel:SetText("—")
	else
		if entry.fullCraftCost ~= nil then
			setLabelColor(row.fullCostLabel, COLOR_GOLD)
			row.fullCostLabel:SetText(goldText(entry.fullCraftCost))
		else
			row.fullCostLabel:SetText("—")
		end
		if entry.craftCost ~= nil then
			setLabelColor(row.costLabel, COLOR_GOLD)
			row.costLabel:SetText(goldText(entry.craftCost))
		else
			row.costLabel:SetText("—")
		end
	end
end

function BCUI:PopulateMatRow(row, line, stripeIndex)
	BCUI:SetPieceMode(row, false)
	BCUI:SetMatMode(row, true)
	row.msgLabel:SetHidden(true)
	row.expBtn:SetHidden(true)
	row.entryIndex = nil

	row.stripe:SetColor(0.35, 0.40, 0.55, (stripeIndex % 2 == 0) and 0.10 or 0.06)

	local shortfall = line.shortfall or 0
	local fullyOwned = shortfall == 0
	local color = line.missing and COLOR_MISSING or (fullyOwned and COLOR_OWNED or COLOR_MAT)

	setLabelColor(row.matName, color)
	setLabelColor(row.matNeed, color)
	setLabelColor(row.matOwn, color)
	setLabelColor(row.matMiss, fullyOwned and COLOR_OWNED or (shortfall > 0 and COLOR_MISSING or color))
	setLabelColor(row.matUnit, color)
	setLabelColor(row.matSub, color)

	CCC.Utilities:ApplyItemIcon(row.matIcon,
		CCC.Utilities:ResolveItemIcon(line.itemLink, line.icon))

	row.matName:SetText(zo_strformat("<<1>>", line.name or "?"))
	row.matNeed:SetText(tostring(line.required or line.quantity or 0))
	row.matOwn:SetText(tostring(line.owned or 0))
	row.matMiss:SetText(tostring(shortfall))

	if fullyOwned then
		row.matUnit:SetText(line.unitPrice and goldText(line.unitPrice) or "—")
		row.matSub:SetText(goldText(0))
	elseif line.missing then
		row.matUnit:SetText("N/A")
		row.matSub:SetText("N/A")
	else
		row.matUnit:SetText(goldText(line.unitPrice))
		row.matSub:SetText(goldText(line.subtotal))
	end
end

function BCUI:PopulateMessageRow(row, text, stripeIndex)
	BCUI:SetPieceMode(row, false)
	BCUI:SetMatMode(row, false)
	row.expBtn:SetHidden(true)
	row.msgLabel:SetHidden(false)
	row.entryIndex = nil
	row.stripe:SetColor(0.5, 0.35, 0.2, 0.08)
	row.msgLabel:SetText(text or "")
end

function BCUI:SetImportExpanded(expanded)
	BCUI.importExpanded = expanded and true or false
	if BCUI.expandedHost then
		BCUI.expandedHost:SetHidden(not BCUI.importExpanded)
	end
	if BCUI.collapsedHost then
		BCUI.collapsedHost:SetHidden(BCUI.importExpanded)
	end
	if BCUI.importHost then
		local h = BCUI.importExpanded and (IMPORT_HEIGHT + 40) or IMPORT_COLLAPSED_HEIGHT
		BCUI.importHost:SetDimensions(CONTENT_WIDTH, h)
	end
	if BCUI:IsVisible() then
		-- List height depends on import host size; refresh row capacity.
		zo_callLater(function()
			if BCUI:IsVisible() then
				BCUI:Refresh()
			end
		end, 10)
	end
end

function BCUI:UpdateCollapsedImportLabel()
	if not BCUI.collapsedLabel then
		return
	end
	local calc = BCUI.addon.BuildCostCalculator
	if not calc:HasBuild() then
		BCUI.collapsedLabel:SetText("")
		return
	end
	local summary = calc:GetSummary()
	local name = summary.name or "Build"
	if summary.setupName and summary.setupName ~= "" then
		name = name .. "  ·  " .. summary.setupName
	end
	BCUI.collapsedLabel:SetText(zo_strformat(GetString(CCC_BUILD_IMPORTED_LABEL), name))
end

function BCUI:ShowEmptyState()
	BCUI.summaryLabel:SetText(GetString(CCC_BUILD_SUMMARY_EMPTY))
	BCUI.totalsLabel:SetText("")
	BCUI.totalGoldLabel:SetText("")
	BCUI.shopBtn:SetEnabled(false)
	if BCUI.emptyIcon then
		BCUI.emptyIcon:SetHidden(false)
	end
	for i = 1, #BCUI.rows do
		BCUI:ClearRow(BCUI.rows[i])
	end
end

function BCUI:Refresh()
	if not BCUI.window then
		return
	end

	local calc = BCUI.addon.BuildCostCalculator
	if not calc:HasBuild() then
		BCUI:ShowEmptyState()
		return
	end

	if BCUI.emptyIcon then
		BCUI.emptyIcon:SetHidden(true)
	end

	local summary = calc:GetSummary()
	local nameLine = summary.name or ""
	if summary.setupName and summary.setupName ~= "" then
		nameLine = nameLine .. "  ·  " .. summary.setupName
	end

	-- Avoid zo_strformat + embedded newlines (can collapse and mash words together).
	BCUI.summaryLabel:SetText(string.format(
		"%s\nPieces: %d  ·  With cost: %d  ·  Mythics: %d  ·  Skipped: %d",
		nameLine,
		summary.totalPieces or 0,
		summary.costedPieces or 0,
		summary.mythicPieces or 0,
		summary.skippedPieces or 0
	))

	BCUI:UpdateCollapsedImportLabel()

	local displayRows = calc:GetDisplayRows()
	local capacity = BCUI:GetVisibleRowCapacity()
	local maxOff = math.max(0, #displayRows - capacity)
	BCUI.scrollOffset = zo_clamp(BCUI.scrollOffset, 0, maxOff)

	for i = 1, MAX_ROW_CONTROLS do
		local row = BCUI:GetRow(i)
		if i > capacity then
			BCUI:ClearRow(row)
		else
			local dataIndex = BCUI.scrollOffset + i
			local data = displayRows[dataIndex]
			if not data then
				BCUI:ClearRow(row)
			else
				row:ClearAnchors()
				row:SetAnchor(TOPLEFT, BCUI.listContainer, TOPLEFT, 2, (i - 1) * ROW_HEIGHT)
				row:SetHidden(false)
				if data.kind == "piece" then
					BCUI:PopulatePieceRow(row, data.entry, dataIndex)
				elseif data.kind == "material" then
					BCUI:PopulateMatRow(row, data.line, dataIndex)
				else
					BCUI:PopulateMessageRow(row, data.text, dataIndex)
				end
			end
		end
	end

	local pendingNote = ""
	if summary.calculating or (summary.pending or 0) > 0 then
		pendingNote = "  ·  " .. zo_strformat(GetString(CCC_BUILD_CALC_PENDING), summary.pending)
	end

	-- Hero: full build craft cost; secondary: what you still need
	if summary.hasPriced then
		BCUI.totalGoldLabel:SetText(zo_strformat(
			GetString(CCC_BUILD_TOTAL_TTC),
			CCC.Utilities:FormatGoldText(summary.totalTtcMaterialValue, 0)
		) .. pendingNote)

		local fmt = summary.complete and CCC_BUILD_TOTAL_MISSING or CCC_BUILD_TOTAL_MISSING_PARTIAL
		BCUI.totalsLabel:SetText(zo_strformat(
			GetString(fmt),
			CCC.Utilities:FormatGoldText(summary.totalMissingMaterialCost, 0)
		))
	else
		BCUI.totalGoldLabel:SetText(GetString(CCC_BUILD_TOTAL_NONE) .. pendingNote)
		BCUI.totalsLabel:SetText("")
	end

	BCUI.shopBtn:SetEnabled((summary.costedPieces or 0) > 0 and (summary.pending or 0) == 0)
end

function BCUI:OnImport()
	local text = BCUI.editBox:GetText() or ""
	if BCUI.placeholderActive then
		BCUI:SetStatus(GetString(CCC_BUILD_ERR_EMPTY), true)
		return
	end

	local ok, err = BCUI.addon.BuildCostCalculator:ImportExport(text)
	if not ok then
		BCUI:SetStatus(err or GetString(CCC_BUILD_ERR_IMPORT), true)
		return
	end

	BCUI.scrollOffset = 0
	BCUI:SetStatus(GetString(CCC_BUILD_MSG_IMPORTED), false)
	BCUI:RefreshFilterButtons()
	BCUI:SetImportExpanded(false)
	BCUI:Refresh()
end

function BCUI:OnClear()
	BCUI.addon.BuildCostCalculator:Clear()
	BCUI.editBox:SetText(PLACEHOLDER)
	BCUI.placeholderActive = true
	BCUI.scrollOffset = 0
	BCUI:SetStatus("", false)
	BCUI:SetImportExpanded(true)
	BCUI:ShowEmptyState()
end

function BCUI:OnAddToShoppingList()
	local added, merged, totalQty = BCUI.addon.BuildCostCalculator:AddEntireBuildToShoppingList()
	if (added + merged) == 0 or totalQty == 0 then
		d(GetString(CCC_MSG_SHOPPING_LIST_NONE))
		BCUI:SetStatus(GetString(CCC_MSG_SHOPPING_LIST_NONE), true)
		return
	end

	d(zo_strformat(GetString(CCC_MSG_SHOPPING_LIST_ADDED), added + merged, added, merged))
	BCUI:SetStatus(zo_strformat(GetString(CCC_MSG_SHOPPING_LIST_ADDED), added + merged, added, merged), false)

	if BCUI.addon.ShoppingListUI and BCUI.addon.ShoppingListUI:IsVisible() then
		BCUI.addon.ShoppingListUI:Refresh()
	end
end

function BCUI:SetStatus(text, isError)
	if not text or text == "" then
		BCUI.statusLabel:SetText("")
		return
	end
	local kind = isError and "fail" or "ok"
	BCUI.statusLabel:SetText(CCC.Utilities:FormatStatusText(kind, text))
	if isError then
		setLabelColor(BCUI.statusLabel, COLOR_MISSING)
	else
		setLabelColor(BCUI.statusLabel, COLOR_OWNED)
	end
end

function BCUI:Show()
	if BCUI.window then
		BCUI.window:SetHidden(false)
		-- Keep import collapsed when a build is already loaded.
		if BCUI.addon.BuildCostCalculator:HasBuild() and BCUI.importExpanded then
			BCUI:SetImportExpanded(false)
		elseif not BCUI.addon.BuildCostCalculator:HasBuild() and not BCUI.importExpanded then
			BCUI:SetImportExpanded(true)
		end
		BCUI:RefreshFilterButtons()
		BCUI:Refresh()
		-- Height may not be final on the first frame after show.
		zo_callLater(function()
			if BCUI:IsVisible() then
				BCUI:Refresh()
			end
		end, 10)
	end
end

function BCUI:Toggle()
	if not BCUI.window then
		return
	end
	if BCUI.window:IsHidden() then
		BCUI:Show()
	else
		BCUI.window:SetHidden(true)
	end
end

function BCUI:IsVisible()
	return BCUI.window and not BCUI.window:IsHidden()
end
