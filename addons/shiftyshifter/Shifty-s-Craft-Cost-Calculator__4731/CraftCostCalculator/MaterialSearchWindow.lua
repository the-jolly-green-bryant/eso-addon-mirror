--[[
	MaterialSearchWindow
	Dialog for searching crafting materials and adding them to the Shopping List.
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.MaterialSearchWindow = CCC.MaterialSearchWindow or {}
local MSW = CCC.MaterialSearchWindow

local COL = {
	iconX = 0, iconW = 24,
	nameX = 30, nameW = 200,
	catX = 238, catW = 150,
	priceX = 396, priceW = 90,
}
local ROW_HEIGHT = 28
local MAX_ROWS = 12
local WINDOW_WIDTH = 520
local WINDOW_HEIGHT = 600
local CONTENT_WIDTH = COL.priceX + COL.priceW
local PAD = 18
-- Footer stack (from bottom): selected, qty row, rule, status
local FOOTER_SELECTED_Y = -16
local FOOTER_QTY_Y = -46
local FOOTER_RULE_Y = -78
local FOOTER_STATUS_Y = -98
local LIST_BOTTOM_Y = -118 -- list ends above status row
local SEARCH_DEBOUNCE_MS = 75
local SEARCH_RESULT_LIMIT = 50
local DEBOUNCE_NAME = "CCC_MaterialSearchDebounce"

local COLOR_HEADER = {0.65, 0.65, 0.65, 1}
local COLOR_NORMAL = {0.92, 0.92, 0.92, 1}
local COLOR_MISSING = {1.0, 0.55, 0.55, 1}
local COLOR_MUTED = {0.72, 0.72, 0.72, 1}
local COLOR_GOLD = {0.95, 0.85, 0.4, 1}
local COLOR_SELECTED = {0.35, 0.32, 0.18, 0.85}
local COLOR_ROW_HOVER = {0.25, 0.23, 0.14, 0.55}

function MSW:Init(addon)
	MSW.addon = addon
	MSW.rows = {}
	MSW.results = {}
	MSW.selectedIndex = nil
	MSW.selectedEntry = nil
	MSW:CreateWindow()
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

function MSW:CreateEditBox(wm, parent, name, width, height, maxChars)
	local editBg = wm:CreateControlFromVirtual(name .. "BG", parent, "ZO_EditBackdrop")
	editBg:SetDimensions(width, height)
	editBg:SetMouseEnabled(true)
	editBg:SetDrawLevel(2)

	local editBox = wm:CreateControlFromVirtual(name, editBg, "ZO_DefaultEditForBackdrop")
	editBox:SetAnchor(TOPLEFT, editBg, TOPLEFT, 6, 2)
	editBox:SetAnchor(BOTTOMRIGHT, editBg, BOTTOMRIGHT, -6, -2)
	editBox:SetFont("ZoFontGame")
	editBox:SetColor(0.9, 0.9, 0.9, 1)
	editBox:SetMaxInputChars(maxChars or 128)
	editBox:SetMouseEnabled(true)
	editBox:SetDrawLevel(3)
	if editBox.SetEditEnabled then
		editBox:SetEditEnabled(true)
	end

	editBg:SetHandler("OnMouseUp", function()
		if editBox.TakeFocus then
			editBox:TakeFocus()
		end
	end)

	return editBg, editBox
end

function MSW:CreateColumnHeader(wm, parent)
	local header = wm:CreateControl(CCC.Name .. "MSHeader", parent, CT_CONTROL)
	header:SetDimensions(CONTENT_WIDTH, ROW_HEIGHT)
	header:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)

	local function headerCell(suffix, x, w, text, align)
		local label = makeLabel(wm, CCC.Name .. "MSHeader" .. suffix, header, "ZoFontGameSmall")
		label:SetDimensions(w, ROW_HEIGHT)
		label:SetAnchor(TOPLEFT, header, TOPLEFT, x, 0)
		label:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT)
		setLabelColor(label, COLOR_HEADER)
		label:SetText(text)
		return label
	end

	headerCell("Name", COL.nameX, COL.nameW, GetString(CCC_MATERIAL_SEARCH_COL_NAME), TEXT_ALIGN_LEFT)
	headerCell("Cat", COL.catX, COL.catW, GetString(CCC_MATERIAL_SEARCH_COL_CATEGORY), TEXT_ALIGN_LEFT)
	headerCell("Price", COL.priceX, COL.priceW, GetString(CCC_MATERIAL_SEARCH_COL_PRICE), TEXT_ALIGN_RIGHT)

	local rule = wm:CreateControl(CCC.Name .. "MSHeaderRule", parent, CT_TEXTURE)
	rule:SetDimensions(CONTENT_WIDTH, 1)
	rule:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, 2)
	rule:SetColor(0.55, 0.48, 0.32, 0.7)

	MSW.header = header
	MSW.headerRule = rule
end

function MSW:CreateRow(index)
	local wm = GetWindowManager()
	local parent = MSW.listContainer
	local row = wm:CreateControl(CCC.Name .. "MSRow" .. index, parent, CT_CONTROL)
	row:SetDimensions(CONTENT_WIDTH, ROW_HEIGHT)
	row:SetHidden(true)
	row:SetMouseEnabled(true)

	local bg = wm:CreateControl(CCC.Name .. "MSRow" .. index .. "BG", row, CT_TEXTURE)
	bg:SetAnchorFill(row)
	bg:SetDrawLevel(0)
	bg:SetColor(1, 1, 1, (index % 2 == 0) and 0.04 or 0)
	row.bg = bg
	row.baseAlpha = (index % 2 == 0) and 0.04 or 0

	local icon = wm:CreateControl(CCC.Name .. "MSRow" .. index .. "Icon", row, CT_TEXTURE)
	icon:SetDimensions(22, 22)
	icon:SetAnchor(TOPLEFT, row, TOPLEFT, COL.iconX, 3)
	icon:SetDrawLevel(1)
	icon:SetHidden(true)
	row.icon = icon

	local nameLabel = makeLabel(wm, CCC.Name .. "MSRow" .. index .. "Name", row, "ZoFontGame")
	nameLabel:SetDimensions(COL.nameW, ROW_HEIGHT)
	nameLabel:SetAnchor(TOPLEFT, row, TOPLEFT, COL.nameX, 0)
	nameLabel:SetDrawLevel(1)
	setLabelColor(nameLabel, COLOR_NORMAL)
	row.nameLabel = nameLabel

	local catLabel = makeLabel(wm, CCC.Name .. "MSRow" .. index .. "Cat", row, "ZoFontGameSmall")
	catLabel:SetDimensions(COL.catW, ROW_HEIGHT)
	catLabel:SetAnchor(TOPLEFT, row, TOPLEFT, COL.catX, 0)
	catLabel:SetDrawLevel(1)
	setLabelColor(catLabel, COLOR_MUTED)
	row.catLabel = catLabel

	local priceLabel = makeLabel(wm, CCC.Name .. "MSRow" .. index .. "Price", row, "ZoFontGame")
	priceLabel:SetDimensions(COL.priceW, ROW_HEIGHT)
	priceLabel:SetAnchor(TOPLEFT, row, TOPLEFT, COL.priceX, 0)
	priceLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	priceLabel:SetDrawLevel(1)
	setLabelColor(priceLabel, COLOR_NORMAL)
	row.priceLabel = priceLabel

	row:SetHandler("OnMouseEnter", function()
		if MSW.selectedIndex ~= index then
			row.bg:SetColor(COLOR_ROW_HOVER[1], COLOR_ROW_HOVER[2], COLOR_ROW_HOVER[3], COLOR_ROW_HOVER[4])
		end
	end)
	row:SetHandler("OnMouseExit", function()
		MSW:ApplyRowBackground(row, index)
	end)
	row:SetHandler("OnMouseUp", function()
		MSW:SelectResult(index)
	end)

	MSW.rows[index] = row
	return row
end

function MSW:GetRow(index)
	return MSW.rows[index] or MSW:CreateRow(index)
end

function MSW:ApplyRowBackground(row, index)
	if MSW.selectedIndex == index then
		row.bg:SetColor(COLOR_SELECTED[1], COLOR_SELECTED[2], COLOR_SELECTED[3], COLOR_SELECTED[4])
	else
		row.bg:SetColor(1, 1, 1, row.baseAlpha or 0)
	end
end

function MSW:CreateWindow()
	local wm = GetWindowManager()
	local control = wm:CreateTopLevelWindow(CCC.Name .. "MSWindow")
	control:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
	control:SetAnchor(CENTER, GuiRoot, CENTER, 80, 20)
	control:SetMovable(true)
	control:SetMouseEnabled(true)
	control:SetClampedToScreen(true)
	control:SetHidden(true)
	control:SetDrawLayer(DL_OVERLAY)

	local bg = wm:CreateControl(CCC.Name .. "MSWindowBG", control, CT_BACKDROP)
	bg:SetAnchorFill(control)
	bg:SetCenterColor(0.06, 0.06, 0.07, 0.96)
	bg:SetEdgeColor(0.55, 0.48, 0.32, 1)
	bg:SetEdgeTexture("", 1, 1, 2)

	local title = makeLabel(wm, CCC.Name .. "MSWindowTitle", control, "ZoFontWinH2")
	title:SetColor(0.85, 0.78, 0.55, 1)
	title:SetAnchor(TOPLEFT, control, TOPLEFT, PAD, 14)
	title:SetText(GetString(CCC_MATERIAL_SEARCH_TITLE))

	local closeBtn = makeTextButton(wm, CCC.Name .. "MSWindowClose", control, "", 28, 28)
	closeBtn:SetAnchor(TOPRIGHT, control, TOPRIGHT, -10, 10)
	CCC.Utilities:ApplyCloseButtonTextures(closeBtn)
	closeBtn:SetHandler("OnClicked", function()
		MSW:Hide()
	end)

	local subtitle = makeLabel(wm, CCC.Name .. "MSWindowSubtitle", control, "ZoFontGameSmall")
	setLabelColor(subtitle, COLOR_MUTED)
	subtitle:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 4)
	subtitle:SetDimensions(CONTENT_WIDTH - 40, 18)
	subtitle:SetText(GetString(CCC_MATERIAL_SEARCH_HINT))
	MSW.subtitleLabel = subtitle

	local searchBg, searchEdit = MSW:CreateEditBox(wm, control, CCC.Name .. "MSSearch", CONTENT_WIDTH, 28, 80)
	searchBg:SetAnchor(TOPLEFT, subtitle, BOTTOMLEFT, 0, 10)
	searchEdit:SetHandler("OnTextChanged", function()
		MSW:OnSearchTextChanged()
	end)
	searchEdit:SetHandler("OnEnter", function()
		MSW:RunSearchNow()
	end)
	MSW.searchBg = searchBg
	MSW.searchEdit = searchEdit

	local listHost = wm:CreateControl(CCC.Name .. "MSWindowListHost", control, CT_CONTROL)
	listHost:SetAnchor(TOPLEFT, searchBg, BOTTOMLEFT, 0, 10)
	listHost:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, PAD, LIST_BOTTOM_Y)
	listHost:SetWidth(CONTENT_WIDTH)
	MSW.listHost = listHost

	MSW:CreateColumnHeader(wm, listHost)

	local listContainer = wm:CreateControl(CCC.Name .. "MSWindowList", listHost, CT_CONTROL)
	listContainer:SetAnchor(TOPLEFT, MSW.headerRule, BOTTOMLEFT, 0, 4)
	listContainer:SetAnchor(BOTTOMLEFT, listHost, BOTTOMLEFT, 0, 0)
	listContainer:SetWidth(CONTENT_WIDTH)
	MSW.listContainer = listContainer

	for i = 1, MAX_ROWS do
		MSW:CreateRow(i)
	end

	local emptyIcon = CCC.Utilities:CreateEmptyPlaceholder(wm, CCC.Name .. "MSWindowEmptyIcon",
		listContainer, CCC.Utilities.ICON_PATHS.emptySearch, 48)
	emptyIcon:SetAnchor(CENTER, listContainer, CENTER, 0, -18)
	MSW.emptyIcon = emptyIcon

	local empty = makeLabel(wm, CCC.Name .. "MSWindowEmpty", control, "ZoFontGame")
	setLabelColor(empty, COLOR_MUTED)
	empty:SetAnchor(TOP, emptyIcon, BOTTOM, 0, 8)
	empty:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	empty:SetText(GetString(CCC_MATERIAL_SEARCH_EMPTY))
	empty:SetHidden(true)
	MSW.emptyLabel = empty

	-- Footer stack is bottom-anchored so it never collides with the list/status.
	local status = makeLabel(wm, CCC.Name .. "MSWindowStatus", control, "ZoFontGameSmall")
	setLabelColor(status, COLOR_MUTED)
	status:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, PAD, FOOTER_STATUS_Y)
	status:SetDimensions(CONTENT_WIDTH, 16)
	MSW.statusLabel = status

	local footerRule = wm:CreateControl(CCC.Name .. "MSWindowFooterRule", control, CT_TEXTURE)
	footerRule:SetDimensions(CONTENT_WIDTH, 1)
	footerRule:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, PAD, FOOTER_RULE_Y)
	footerRule:SetColor(0.55, 0.48, 0.32, 0.7)

	local qtyLabel = makeLabel(wm, CCC.Name .. "MSQtyLabel", control, "ZoFontGame")
	setLabelColor(qtyLabel, COLOR_NORMAL)
	qtyLabel:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, PAD, FOOTER_QTY_Y)
	qtyLabel:SetText(GetString(CCC_MATERIAL_SEARCH_QTY))
	MSW.qtyLabel = qtyLabel

	local qtyBg, qtyEdit = MSW:CreateEditBox(wm, control, CCC.Name .. "MSQty", 72, 26, 6)
	qtyBg:SetAnchor(LEFT, qtyLabel, RIGHT, 10, 0)
	qtyEdit:SetText("1")
	qtyEdit:SetHandler("OnTextChanged", function()
		MSW:UpdateAddEnabled()
	end)
	qtyEdit:SetHandler("OnEnter", function()
		MSW:OnAddClicked()
	end)
	MSW.qtyBg = qtyBg
	MSW.qtyEdit = qtyEdit

	local addBtn = makeTextButton(wm, CCC.Name .. "MSAddBtn", control, GetString(CCC_MATERIAL_SEARCH_ADD), 100, 28)
	addBtn:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -PAD, FOOTER_QTY_Y + 4)
	addBtn:SetHandler("OnClicked", function()
		MSW:OnAddClicked()
	end)
	MSW.addBtn = addBtn

	local selectedIcon = wm:CreateControl(CCC.Name .. "MSSelectedIcon", control, CT_TEXTURE)
	selectedIcon:SetDimensions(18, 18)
	selectedIcon:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, PAD, FOOTER_SELECTED_Y - 1)
	selectedIcon:SetHidden(true)
	MSW.selectedIcon = selectedIcon

	local selected = makeLabel(wm, CCC.Name .. "MSSelected", control, "ZoFontGameSmall")
	setLabelColor(selected, COLOR_GOLD)
	selected:SetAnchor(LEFT, selectedIcon, RIGHT, 6, 0)
	selected:SetDimensions(CONTENT_WIDTH - 140, 16)
	MSW.selectedLabel = selected

	MSW.window = control
	MSW:UpdateAddEnabled()
end

function MSW:ClearRows()
	for i = 1, #MSW.rows do
		local row = MSW.rows[i]
		row:SetHidden(true)
		row.entry = nil
		CCC.Utilities:ApplyItemIcon(row.icon, nil)
	end
end

function MSW:PopulateRows(results)
	MSW:ClearRows()

	local count = math.min(#results, MAX_ROWS)
	for i = 1, count do
		local entry = results[i]
		local row = MSW:GetRow(i)
		row:ClearAnchors()
		row:SetAnchor(TOPLEFT, MSW.listContainer, TOPLEFT, 0, (i - 1) * ROW_HEIGHT)
		row:SetHidden(false)
		row.entry = entry

		row.nameLabel:SetText(zo_strformat("<<1>>", entry.name or "?"))
		row.catLabel:SetText(entry.categoryLabel or entry.category or "")

		CCC.Utilities:ApplyItemIcon(row.icon, entry.icon)

		local unitPrice = MSW.addon.PriceProvider:GetUnitPrice(entry.itemLink)
		if unitPrice then
			setLabelColor(row.priceLabel, COLOR_NORMAL)
			row.priceLabel:SetText(goldText(unitPrice))
		else
			setLabelColor(row.priceLabel, COLOR_MISSING)
			row.priceLabel:SetText("N/A")
		end

		MSW:ApplyRowBackground(row, i)
	end
end

function MSW:SelectResult(index)
	local entry = MSW.results[index]
	if not entry then
		return
	end

	MSW.selectedIndex = index
	MSW.selectedEntry = entry

	for i = 1, math.min(#MSW.results, MAX_ROWS) do
		local row = MSW.rows[i]
		if row and not row:IsHidden() then
			MSW:ApplyRowBackground(row, i)
		end
	end

	CCC.Utilities:ApplyItemIcon(MSW.selectedIcon, entry.icon)
	MSW.selectedLabel:SetText(zo_strformat(GetString(CCC_MATERIAL_SEARCH_SELECTED), entry.name or "?"))
	MSW:UpdateAddEnabled()
end

function MSW:ClearSelection()
	MSW.selectedIndex = nil
	MSW.selectedEntry = nil
	MSW.selectedLabel:SetText("")
	CCC.Utilities:ApplyItemIcon(MSW.selectedIcon, nil)
	for i = 1, #MSW.rows do
		local row = MSW.rows[i]
		if row and not row:IsHidden() then
			MSW:ApplyRowBackground(row, i)
		end
	end
	MSW:UpdateAddEnabled()
end

function MSW:ParseQuantity()
	local text = MSW.qtyEdit and MSW.qtyEdit:GetText() or ""
	local qty = tonumber(zo_strtrim(text))
	if not qty or qty ~= zo_floor(qty) or qty < 1 then
		return nil
	end
	return qty
end

function MSW:UpdateAddEnabled()
	local ok = MSW.selectedEntry ~= nil and MSW:ParseQuantity() ~= nil
	if MSW.addBtn then
		MSW.addBtn:SetEnabled(ok)
	end
end

function MSW:CancelDebounce()
	EVENT_MANAGER:UnregisterForUpdate(DEBOUNCE_NAME)
end

function MSW:OnSearchTextChanged()
	MSW:CancelDebounce()
	EVENT_MANAGER:RegisterForUpdate(DEBOUNCE_NAME, SEARCH_DEBOUNCE_MS, function()
		MSW:CancelDebounce()
		MSW:RunSearchNow()
	end)
end

function MSW:RunSearchNow()
	MSW:CancelDebounce()
	if not MSW.window then
		return
	end

	MSW.addon.MaterialSearchService:EnsureIndex()

	local query = MSW.searchEdit and MSW.searchEdit:GetText() or ""
	local results = MSW.addon.MaterialSearchService:Search(query, { limit = SEARCH_RESULT_LIMIT })
	MSW.results = results
	MSW:ClearSelection()
	MSW:PopulateRows(results)

	local total = #results
	local empty = total == 0
	MSW.emptyLabel:SetHidden(not empty)
	if MSW.emptyIcon then
		MSW.emptyIcon:SetHidden(not empty)
	end

	local statusText
	if query == nil or zo_strtrim(query) == "" then
		statusText = zo_strformat(GetString(CCC_MATERIAL_SEARCH_STATUS_ALL), total)
	elseif total == 0 then
		statusText = GetString(CCC_MATERIAL_SEARCH_STATUS_NONE)
	elseif total >= SEARCH_RESULT_LIMIT then
		statusText = zo_strformat(GetString(CCC_MATERIAL_SEARCH_STATUS_CAPPED), SEARCH_RESULT_LIMIT)
	else
		statusText = zo_strformat(GetString(CCC_MATERIAL_SEARCH_STATUS), total)
	end
	MSW.statusLabel:SetText(CCC.Utilities:FormatStatusText("search", statusText))
end

function MSW:OnAddClicked()
	local entry = MSW.selectedEntry
	local qty = MSW:ParseQuantity()
	if not entry or not qty then
		MSW:UpdateAddEnabled()
		return
	end

	local ok, err, added, merged, qtyAdded = MSW.addon.MaterialSearchService:AddToShoppingList(entry.itemId, qty)
	if not ok then
		d(err or GetString(CCC_MATERIAL_SEARCH_QTY_INVALID))
		return
	end

	d(zo_strformat(GetString(CCC_MSG_SHOPPING_LIST_ADDED), qtyAdded, added, merged))

	if MSW.addon.ShoppingListUI and MSW.addon.ShoppingListUI:IsVisible() then
		MSW.addon.ShoppingListUI:Refresh()
	end

	-- Keep window open for more adds; reset qty to 1 and keep selection.
	if MSW.qtyEdit then
		MSW.qtyEdit:SetText("1")
	end
	MSW:UpdateAddEnabled()
end

function MSW:Show()
	if not MSW.window then
		return
	end

	MSW.addon.MaterialSearchService:EnsureIndex()

	if MSW.searchEdit then
		MSW.searchEdit:SetText("")
	end
	if MSW.qtyEdit then
		MSW.qtyEdit:SetText("1")
	end

	MSW:RunSearchNow()
	MSW.window:SetHidden(false)

	if MSW.searchEdit and MSW.searchEdit.TakeFocus then
		MSW.searchEdit:TakeFocus()
	end
end

function MSW:Hide()
	MSW:CancelDebounce()
	if MSW.window then
		MSW.window:SetHidden(true)
	end
end

function MSW:Toggle()
	if not MSW.window then
		return
	end
	if MSW.window:IsHidden() then
		MSW:Show()
	else
		MSW:Hide()
	end
end

function MSW:IsVisible()
	return MSW.window and not MSW.window:IsHidden()
end
