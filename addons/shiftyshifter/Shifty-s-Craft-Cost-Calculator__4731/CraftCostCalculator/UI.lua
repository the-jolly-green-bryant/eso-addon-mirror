--[[
	UI: results window, chat output, inventory context menu.

	Columns: Type | Need | Own | Miss | Material | Unit | Cost
	Cost is based on missing materials only (Need - Own).
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.UI = CCC.UI or {}
local UI = CCC.UI

local CATEGORY_LABEL = {
	base = "Base",
	style = "Style",
	trait = "Trait",
	improvement = "Improve",
	ingredient = "Ingredient",
	glyph = "Glyph",
	llc = "Material",
}

local STATION_NAMES = {
	[CRAFTING_TYPE_BLACKSMITHING] = "Blacksmithing",
	[CRAFTING_TYPE_CLOTHIER] = "Clothing",
	[CRAFTING_TYPE_WOODWORKING] = "Woodworking",
	[CRAFTING_TYPE_JEWELRYCRAFTING] = "Jewelry",
	[CRAFTING_TYPE_PROVISIONING] = "Provisioning",
}

-- Column layout (x offsets from row left, widths)
local COL = {
	typeX = 0, typeW = 62,
	needX = 66, needW = 40,
	ownX = 110, ownW = 40,
	missX = 154, missW = 40,
	iconX = 202, iconW = 24,
	nameX = 228, nameW = 142,
	unitX = 378, unitW = 88,
	subX = 474, subW = 100,
}
local ROW_HEIGHT = 26
local MAX_ROWS = 14
local MAX_KNOW_ROWS = 4
local KNOW_ROW_HEIGHT = 20
local WINDOW_WIDTH = 610
local WINDOW_HEIGHT = 560
local CONTENT_WIDTH = COL.subX + COL.subW
local PAD = 18
local FOOTER_HEIGHT = 136
local ACTION_BTN_W = 178
local ACTION_BTN_H = 24

local COLOR_HEADER = {0.65, 0.65, 0.65, 1}
local COLOR_NORMAL = {0.92, 0.92, 0.92, 1}
local COLOR_MISSING = {1.0, 0.55, 0.55, 1}
local COLOR_OWNED = {0.45, 0.85, 0.55, 1}
local COLOR_GOLD = {0.95, 0.85, 0.4, 1}
local COLOR_MUTED = {0.72, 0.72, 0.72, 1}
local COLOR_COMPARE_BAD = {1.0, 0.42, 0.42, 1}   -- craft more expensive than market
local COLOR_COMPARE_GOOD = {0.45, 0.88, 0.55, 1} -- craft cheaper than market
local COLOR_COMPARE_EVEN = {0.85, 0.85, 0.7, 1}
local COLOR_WARN = {1.0, 0.78, 0.35, 1}

function UI:Init(addon)
	UI.addon = addon
	UI.rows = {}
	UI.knowRows = {}
	UI:CreateWindow()
	UI:RegisterContextMenu()
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

function UI:CreateColumnHeader(wm, parent)
	local header = wm:CreateControl(CCC.Name .. "WindowHeader", parent, CT_CONTROL)
	header:SetDimensions(CONTENT_WIDTH, ROW_HEIGHT)
	header:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)

	local function headerCell(suffix, x, w, text, align)
		local label = makeLabel(wm, CCC.Name .. "WindowHeader" .. suffix, header, "ZoFontGameSmall")
		label:SetDimensions(w, ROW_HEIGHT)
		label:SetAnchor(TOPLEFT, header, TOPLEFT, x, 0)
		label:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT)
		setLabelColor(label, COLOR_HEADER)
		label:SetText(text)
		return label
	end

	headerCell("Type", COL.typeX, COL.typeW, "Type", TEXT_ALIGN_LEFT)
	headerCell("Need", COL.needX, COL.needW, "Need", TEXT_ALIGN_RIGHT)
	headerCell("Own", COL.ownX, COL.ownW, "Own", TEXT_ALIGN_RIGHT)
	headerCell("Miss", COL.missX, COL.missW, "Miss", TEXT_ALIGN_RIGHT)
	headerCell("Name", COL.nameX, COL.nameW, "Material", TEXT_ALIGN_LEFT)
	headerCell("Unit", COL.unitX, COL.unitW, "Unit", TEXT_ALIGN_RIGHT)
	headerCell("Sub", COL.subX, COL.subW, "Cost", TEXT_ALIGN_RIGHT)

	local rule = wm:CreateControl(CCC.Name .. "WindowHeaderRule", parent, CT_TEXTURE)
	rule:SetDimensions(CONTENT_WIDTH, 1)
	rule:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, 2)
	rule:SetColor(0.55, 0.48, 0.32, 0.7)

	UI.header = header
	UI.headerRule = rule
end

function UI:CreateRow(index)
	local wm = GetWindowManager()
	local parent = UI.listContainer
	local row = wm:CreateControl(CCC.Name .. "WindowRow" .. index, parent, CT_CONTROL)
	row:SetDimensions(CONTENT_WIDTH, ROW_HEIGHT)
	row:SetHidden(true)

	local function cell(suffix, x, w, align)
		local label = makeLabel(wm, CCC.Name .. "WindowRow" .. index .. suffix, row, "ZoFontGame")
		label:SetDimensions(w, ROW_HEIGHT)
		label:SetAnchor(TOPLEFT, row, TOPLEFT, x, 0)
		label:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT)
		setLabelColor(label, COLOR_NORMAL)
		return label
	end

	row.typeLabel = cell("Type", COL.typeX, COL.typeW, TEXT_ALIGN_LEFT)
	row.needLabel = cell("Need", COL.needX, COL.needW, TEXT_ALIGN_RIGHT)
	row.ownLabel = cell("Own", COL.ownX, COL.ownW, TEXT_ALIGN_RIGHT)
	row.missLabel = cell("Miss", COL.missX, COL.missW, TEXT_ALIGN_RIGHT)

	local icon = wm:CreateControl(CCC.Name .. "WindowRow" .. index .. "Icon", row, CT_TEXTURE)
	icon:SetDimensions(22, 22)
	icon:SetAnchor(TOPLEFT, row, TOPLEFT, COL.iconX, 2)
	icon:SetDrawLevel(1)
	icon:SetHidden(true)
	row.icon = icon

	row.nameLabel = cell("Name", COL.nameX, COL.nameW, TEXT_ALIGN_LEFT)
	row.unitLabel = cell("Unit", COL.unitX, COL.unitW, TEXT_ALIGN_RIGHT)
	row.subLabel = cell("Sub", COL.subX, COL.subW, TEXT_ALIGN_RIGHT)

	local stripe = wm:CreateControl(CCC.Name .. "WindowRow" .. index .. "Stripe", row, CT_TEXTURE)
	stripe:SetAnchorFill(row)
	stripe:SetDrawLevel(0)
	stripe:SetColor(1, 1, 1, (index % 2 == 0) and 0.04 or 0)
	row.stripe = stripe

	row.typeLabel:SetDrawLevel(1)
	row.needLabel:SetDrawLevel(1)
	row.ownLabel:SetDrawLevel(1)
	row.missLabel:SetDrawLevel(1)
	row.nameLabel:SetDrawLevel(1)
	row.unitLabel:SetDrawLevel(1)
	row.subLabel:SetDrawLevel(1)

	UI.rows[index] = row
	return row
end

function UI:GetRow(index)
	return UI.rows[index] or UI:CreateRow(index)
end

function UI:CreateWindow()
	local wm = GetWindowManager()
	local control = wm:CreateTopLevelWindow(CCC.Name .. "Window")
	control:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
	control:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	control:SetMovable(true)
	control:SetMouseEnabled(true)
	control:SetClampedToScreen(true)
	control:SetHidden(true)
	control:SetDrawLayer(DL_OVERLAY)

	local bg = wm:CreateControl(CCC.Name .. "WindowBG", control, CT_BACKDROP)
	bg:SetAnchorFill(control)
	bg:SetCenterColor(0.06, 0.06, 0.07, 0.96)
	bg:SetEdgeColor(0.55, 0.48, 0.32, 1)
	bg:SetEdgeTexture("", 1, 1, 2)

	local title = makeLabel(wm, CCC.Name .. "WindowTitle", control, "ZoFontWinH2")
	title:SetColor(0.85, 0.78, 0.55, 1)
	title:SetAnchor(TOPLEFT, control, TOPLEFT, PAD, 14)
	title:SetText(CCC.DisplayName)

	local closeBtn = wm:CreateControl(CCC.Name .. "WindowClose", control, CT_BUTTON)
	closeBtn:SetDimensions(28, 28)
	closeBtn:SetAnchor(TOPRIGHT, control, TOPRIGHT, -10, 10)
	closeBtn:SetMouseEnabled(true)
	CCC.Utilities:ApplyCloseButtonTextures(closeBtn)
	closeBtn:SetHandler("OnClicked", function()
		control:SetHidden(true)
	end)

	local subtitle = makeLabel(wm, CCC.Name .. "WindowSubtitle", control, "ZoFontGame")
	subtitle:SetColor(0.9, 0.9, 0.9, 1)
	subtitle:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 8)
	subtitle:SetDimensions(CONTENT_WIDTH, 28)
	subtitle:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
	UI.subtitleLabel = subtitle

	local meta = makeLabel(wm, CCC.Name .. "WindowMeta", control, "ZoFontGameSmall")
	setLabelColor(meta, COLOR_MUTED)
	meta:SetAnchor(TOPLEFT, subtitle, BOTTOMLEFT, 0, 2)
	meta:SetDimensions(CONTENT_WIDTH, 36)
	meta:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
	meta:SetMaxLineCount(2)
	UI.metaLabel = meta

	-- Knowledge / Requirements section (Master Writs)
	local knowHost = wm:CreateControl(CCC.Name .. "WindowKnowHost", control, CT_CONTROL)
	knowHost:SetAnchor(TOPLEFT, meta, BOTTOMLEFT, 0, 4)
	knowHost:SetDimensions(CONTENT_WIDTH, 22 + (MAX_KNOW_ROWS * KNOW_ROW_HEIGHT))
	knowHost:SetHidden(true)
	UI.knowHost = knowHost

	local knowStatus = makeLabel(wm, CCC.Name .. "WindowKnowStatus", knowHost, "ZoFontGameBold")
	knowStatus:SetAnchor(TOPLEFT, knowHost, TOPLEFT, 0, 0)
	knowStatus:SetDimensions(CONTENT_WIDTH, 20)
	UI.knowStatusLabel = knowStatus

	UI.knowRows = {}
	for i = 1, MAX_KNOW_ROWS do
		local row = wm:CreateControl(CCC.Name .. "WindowKnowRow" .. i, knowHost, CT_CONTROL)
		row:SetDimensions(CONTENT_WIDTH, KNOW_ROW_HEIGHT)
		row:SetAnchor(TOPLEFT, knowHost, TOPLEFT, 0, 20 + (i - 1) * KNOW_ROW_HEIGHT)
		row:SetHidden(true)

		local kindLabel = makeLabel(wm, CCC.Name .. "WindowKnowRow" .. i .. "Kind", row, "ZoFontGameSmall")
		kindLabel:SetDimensions(52, KNOW_ROW_HEIGHT)
		kindLabel:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
		setLabelColor(kindLabel, COLOR_MUTED)

		local icon = wm:CreateControl(CCC.Name .. "WindowKnowRow" .. i .. "Icon", row, CT_TEXTURE)
		icon:SetDimensions(16, 16)
		icon:SetAnchor(LEFT, kindLabel, RIGHT, 6, 0)
		icon:SetHidden(true)

		-- Width is tightened to text in PopulateKnowledge so status sits next to the name.
		local nameLabel = makeLabel(wm, CCC.Name .. "WindowKnowRow" .. i .. "Name", row, "ZoFontGameSmall")
		nameLabel:SetDimensions(200, KNOW_ROW_HEIGHT)
		nameLabel:SetAnchor(LEFT, kindLabel, RIGHT, 8, 0)

		local statusLabel = makeLabel(wm, CCC.Name .. "WindowKnowRow" .. i .. "Status", row, "ZoFontGameSmall")
		statusLabel:SetDimensions(100, KNOW_ROW_HEIGHT)
		statusLabel:SetAnchor(LEFT, nameLabel, RIGHT, 10, 0)

		local priceLabel = makeLabel(wm, CCC.Name .. "WindowKnowRow" .. i .. "Price", row, "ZoFontGameSmall")
		priceLabel:SetDimensions(120, KNOW_ROW_HEIGHT)
		priceLabel:SetAnchor(TOPRIGHT, row, TOPRIGHT, 0, 0)
		priceLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
		setLabelColor(priceLabel, COLOR_MUTED)

		row.kindLabel = kindLabel
		row.icon = icon
		row.nameLabel = nameLabel
		row.statusLabel = statusLabel
		row.priceLabel = priceLabel
		UI.knowRows[i] = row
	end

	local listHost = wm:CreateControl(CCC.Name .. "WindowListHost", control, CT_CONTROL)
	-- Anchored under meta until a knowledge section is shown (see PopulateKnowledge).
	listHost:SetAnchor(TOPLEFT, meta, BOTTOMLEFT, 0, 6)
	listHost:SetDimensions(CONTENT_WIDTH, 12 + ROW_HEIGHT + 4 + (MAX_ROWS * ROW_HEIGHT))
	UI.listHost = listHost

	UI:CreateColumnHeader(wm, listHost)

	local listContainer = wm:CreateControl(CCC.Name .. "WindowList", listHost, CT_CONTROL)
	listContainer:SetAnchor(TOPLEFT, UI.headerRule, BOTTOMLEFT, 0, 4)
	listContainer:SetDimensions(CONTENT_WIDTH, MAX_ROWS * ROW_HEIGHT)
	UI.listContainer = listContainer

	for i = 1, 8 do
		UI:CreateRow(i)
	end

	local footerRule = wm:CreateControl(CCC.Name .. "WindowFooterRule", control, CT_TEXTURE)
	footerRule:SetDimensions(CONTENT_WIDTH, 1)
	footerRule:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, PAD, -(FOOTER_HEIGHT + 6))
	footerRule:SetColor(0.55, 0.48, 0.32, 0.7)

	local note = makeLabel(wm, CCC.Name .. "WindowNote", control, "ZoFontGameSmall")
	setLabelColor(note, {1.0, 0.72, 0.42, 1})
	note:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, PAD, -(FOOTER_HEIGHT - 2))
	note:SetDimensions(CONTENT_WIDTH - ACTION_BTN_W - 12, 14)
	UI.noteLabel = note

	-- Hero total: full craft cost (buy every required material)
	local fullTotal = makeLabel(wm, CCC.Name .. "WindowFullTotal", control, "ZoFontWinH3")
	setLabelColor(fullTotal, COLOR_GOLD)
	fullTotal:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, PAD, -58)
	fullTotal:SetDimensions(CONTENT_WIDTH - ACTION_BTN_W - 12, 22)
	UI.fullTotalLabel = fullTotal

	-- Secondary: what the player still needs after owned mats
	local total = makeLabel(wm, CCC.Name .. "WindowTotal", control, "ZoFontGameSmall")
	setLabelColor(total, COLOR_MUTED)
	total:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, PAD, -36)
	total:SetDimensions(CONTENT_WIDTH - ACTION_BTN_W - 12, 16)
	UI.totalLabel = total

	-- Market + compare on one quiet line (hidden when no market price)
	local market = makeLabel(wm, CCC.Name .. "WindowMarket", control, "ZoFontGameSmall")
	setLabelColor(market, COLOR_MUTED)
	market:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, PAD, -16)
	market:SetDimensions(CONTENT_WIDTH - ACTION_BTN_W - 12, 16)
	UI.marketLabel = market

	local function makeActionButton(name, text, bottomOffset)
		local btn = wm:CreateControl(name, control, CT_BUTTON)
		btn:SetDimensions(ACTION_BTN_W, ACTION_BTN_H)
		btn:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -PAD, bottomOffset)
		btn:SetFont("ZoFontGameBold")
		btn:SetNormalFontColor(0.85, 0.78, 0.55, 1)
		btn:SetMouseOverFontColor(1.0, 0.92, 0.7, 1)
		btn:SetPressedFontColor(0.7, 0.62, 0.4, 1)
		btn:SetDisabledFontColor(0.45, 0.45, 0.45, 1)
		btn:SetText(text)
		btn:SetMouseEnabled(true)
		return btn
	end

	local upgradeBtn = makeActionButton(CCC.Name .. "WindowUpgrade", GetString(CCC_BTN_CALCULATE_UPGRADE), -98)
	upgradeBtn:SetEnabled(false)
	upgradeBtn:SetHandler("OnClicked", function()
		UI:OpenUpgradeCostCalculator()
	end)
	UI.upgradeCostBtn = upgradeBtn

	local knowBtn = makeActionButton(CCC.Name .. "WindowAddKnowledge", GetString(CCC_BTN_ADD_KNOWLEDGE_SHOPPING), -70)
	knowBtn:SetEnabled(false)
	knowBtn:SetHandler("OnClicked", function()
		UI:AddMissingKnowledgeToShoppingList()
	end)
	UI.addKnowledgeBtn = knowBtn

	local addBtn = makeActionButton(CCC.Name .. "WindowAddShopping", GetString(CCC_BTN_ADD_TO_SHOPPING_LIST), -42)
	addBtn:SetEnabled(false)
	addBtn:SetHandler("OnClicked", function()
		UI:AddCurrentToShoppingList()
	end)
	UI.addShoppingBtn = addBtn

	local viewBtn = makeActionButton(CCC.Name .. "WindowViewShopping", GetString(CCC_BTN_VIEW_SHOPPING_LIST), -14)
	viewBtn:SetHandler("OnClicked", function()
		UI:OpenShoppingList()
	end)
	UI.viewShoppingBtn = viewBtn

	UI.window = control
end

--- True when the current craft result can open the Upgrade Cost Calculator.
function UI:CanOpenUpgradeCost(result)
	if not result or not result.craftInfo then
		return false
	end
	local info = result.craftInfo
	if info.isMasterWrit then
		return false
	end
	local calc = UI.addon.UpgradeCostCalculator
	return calc and calc:IsSupportedStation(info.station)
end

function UI:OpenUpgradeCostCalculator()
	local result = UI.currentResult
	if not result or not UI:CanOpenUpgradeCost(result) then
		d(GetString(CCC_UPGRADE_ERR_NO_RESULT))
		return
	end
	if not UI.addon.UpgradeCostUI then
		return
	end
	UI.addon.UpgradeCostUI:Open(result.craftInfo, result.itemLink)
end

--- Count materials with shortfall > 0 in the current result.
function UI:CountMissingMaterials(result)
	if not result or not result.lines then
		return 0
	end
	local n = 0
	for i = 1, #result.lines do
		if (result.lines[i].shortfall or 0) > 0 then
			n = n + 1
		end
	end
	return n
end

function UI:OpenShoppingList()
	if UI.addon.ShoppingListUI then
		UI.addon.ShoppingListUI:Show()
	end
end

function UI:AddCurrentToShoppingList()
	local result = UI.currentResult
	if not result then
		d(GetString(CCC_MSG_SHOPPING_LIST_NO_RESULT))
		return
	end

	local added, merged, totalQty = UI.addon.ShoppingList:AddFromResult(result)
	if (added + merged) == 0 or totalQty == 0 then
		d(GetString(CCC_MSG_SHOPPING_LIST_NONE))
		return
	end

	d(zo_strformat(GetString(CCC_MSG_SHOPPING_LIST_ADDED), added + merged, added, merged))

	if UI.addon.ShoppingListUI then
		UI.addon.ShoppingListUI:Show()
	end
end

function UI:AddMissingKnowledgeToShoppingList()
	local result = UI.currentResult
	if not result or not result.knowledge then
		d(GetString(CCC_MSG_KNOWLEDGE_SHOPPING_NONE))
		return
	end

	local added, merged, totalQty = UI.addon.ShoppingList:AddMissingKnowledge(result.knowledge)
	if (added + merged) == 0 or totalQty == 0 then
		d(GetString(CCC_MSG_KNOWLEDGE_SHOPPING_NONE))
		return
	end

	d(zo_strformat(GetString(CCC_MSG_KNOWLEDGE_SHOPPING_ADDED), added + merged, added, merged))

	if UI.addon.ShoppingListUI then
		UI.addon.ShoppingListUI:Show()
	end
end

function UI:CountPurchasableMissingKnowledge(result)
	if not result or not result.knowledge or not UI.addon.ShoppingList then
		return 0
	end
	return UI.addon.ShoppingList:CountPurchasableMissingKnowledge(result.knowledge)
end

function UI:Toggle()
	if UI.window then
		UI.window:SetHidden(not UI.window:IsHidden())
	end
end

function UI:Show()
	if UI.window then
		UI.window:SetHidden(false)
	end
end

function UI:IsVisible()
	return UI.window and not UI.window:IsHidden()
end

local function categoryLabel(category)
	return CATEGORY_LABEL[category] or category or "?"
end

local function goldText(amount)
	return CCC.Utilities:FormatGoldText(amount, 0)
end

--- Compare full craft cost vs finished-item / writ market price.
-- Returns empty text when there is no market price (avoids N/A noise in the UI).
-- @return text, colorTable|nil
function UI:BuildMarketComparison(fullTotal, marketPrice, isMasterWrit)
	if not fullTotal or fullTotal <= 0 then
		return "", COLOR_MUTED
	end
	if not marketPrice or marketPrice <= 0 then
		return "", COLOR_MUTED
	end

	local diffPct = ((fullTotal - marketPrice) / marketPrice) * 100
	local absPct = string.format("%.1f", zo_abs(diffPct))

	if zo_abs(diffPct) < 0.5 then
		return GetString(isMasterWrit and CCC_MSG_COMPARE_WRIT_EQUAL or CCC_MSG_COMPARE_EQUAL), COLOR_COMPARE_EVEN
	elseif diffPct > 0 then
		return zo_strformat(GetString(isMasterWrit and CCC_MSG_COMPARE_WRIT_MORE or CCC_MSG_COMPARE_MORE), absPct), COLOR_COMPARE_BAD
	else
		return zo_strformat(GetString(isMasterWrit and CCC_MSG_COMPARE_WRIT_LESS or CCC_MSG_COMPARE_LESS), absPct), COLOR_COMPARE_GOOD
	end
end

local function qualityDisplayName(addon, quality)
	if addon and addon.UpgradeCostCalculator and addon.UpgradeCostCalculator.GetQualityName then
		return addon.UpgradeCostCalculator:GetQualityName(quality)
	end
	return "Quality " .. tostring(quality or "?")
end

function UI:FormatCraftMeta(info)
	if not info then
		return ""
	end

	local levelText = info.isCP and ("CP" .. tostring(info.level)) or ("Level " .. tostring(info.level))
	local stationName = STATION_NAMES[info.station] or ("Station " .. tostring(info.station))
	local qualityName = qualityDisplayName(UI.addon, info.quality)

	if info.isMasterWrit then
		if info.knowledgeOnly and info.isProvisioning then
			return "Master Writ  ·  Provisioning  ·  Knowledge check"
		end
		if info.isProvisioning then
			local parts = {
				"Master Writ",
				"Provisioning",
				info.requiredItemName or "Recipe",
			}
			if info.vouchers and info.vouchers > 0 then
				parts[#parts + 1] = tostring(info.vouchers) .. " vouchers"
			end
			return table.concat(parts, "  ·  ")
		end
		local parts = {
			"Master Writ",
			stationName,
			info.requiredItemName or ("Pattern " .. tostring(info.pattern)),
			levelText .. " (cheapest)",
			qualityName,
		}
		if info.traitName then
			parts[#parts + 1] = info.traitName
		end
		if info.styleName then
			parts[#parts + 1] = info.styleName
		end
		if info.setName and info.setName ~= "" then
			parts[#parts + 1] = info.setName
		end
		if info.vouchers and info.vouchers > 0 then
			parts[#parts + 1] = tostring(info.vouchers) .. " vouchers"
		end
		return table.concat(parts, "  ·  ")
	end

	return string.format("%s  ·  %s  ·  %s", stationName, levelText, qualityName)
end

function UI:ClearKnowledgeRows()
	if not UI.knowRows then
		return
	end
	for i = 1, #UI.knowRows do
		local row = UI.knowRows[i]
		row:SetHidden(true)
		CCC.Utilities:ApplyItemIcon(row.icon, nil)
	end
end

function UI:PopulateKnowledge(result)
	UI:ClearKnowledgeRows()

	local knowledge = result and result.knowledge
	local show = knowledge and knowledge.hasRequirements
	if UI.knowHost then
		UI.knowHost:SetHidden(not show)
	end
	if not show then
		if UI.listHost and UI.metaLabel then
			UI.listHost:ClearAnchors()
			UI.listHost:SetAnchor(TOPLEFT, UI.metaLabel, BOTTOMLEFT, 0, 6)
		end
		return
	end

	if UI.listHost and UI.knowHost then
		UI.listHost:ClearAnchors()
		UI.listHost:SetAnchor(TOPLEFT, UI.knowHost, BOTTOMLEFT, 0, 4)
	end

	local section = GetString(CCC_KNOW_SECTION)
	if knowledge.ready then
		UI.knowStatusLabel:SetText(CCC.Utilities:FormatStatusText("ok",
			string.format("%s  ·  %s", section, GetString(CCC_KNOW_READY))))
		setLabelColor(UI.knowStatusLabel, COLOR_OWNED)
	else
		UI.knowStatusLabel:SetText(CCC.Utilities:FormatStatusText("fail",
			string.format("%s  ·  %s", section, GetString(CCC_KNOW_MISSING))))
		setLabelColor(UI.knowStatusLabel, COLOR_WARN)
	end

	local count = math.min(#knowledge.requirements, MAX_KNOW_ROWS)
	UI.knowHost:SetDimensions(CONTENT_WIDTH, 22 + (count * KNOW_ROW_HEIGHT))

	for i = 1, count do
		local req = knowledge.requirements[i]
		local row = UI.knowRows[i]
		row:SetHidden(false)

		row.kindLabel:SetText(req.kindLabel or req.kind or "?")

		local iconPath = CCC.Utilities:ResolveItemIcon(req.itemLink, req.icon)
		CCC.Utilities:ApplyItemIcon(row.icon, iconPath)

		row.nameLabel:ClearAnchors()
		if iconPath and iconPath ~= "" then
			row.nameLabel:SetAnchor(LEFT, row.icon, RIGHT, 6, 0)
		else
			row.nameLabel:SetAnchor(LEFT, row.kindLabel, RIGHT, 8, 0)
		end
		row.nameLabel:SetText(req.name or "?")
		-- Shrink name control to text so status sits immediately after it.
		local nameWidth = row.nameLabel:GetTextWidth() or 0
		if nameWidth < 40 then
			nameWidth = 40
		elseif nameWidth > 300 then
			nameWidth = 300
		end
		row.nameLabel:SetDimensions(nameWidth + 2, KNOW_ROW_HEIGHT)

		if req.known then
			row.statusLabel:SetText(CCC.Utilities:FormatStatusText("ok", GetString(CCC_KNOW_STATUS_KNOWN)))
			setLabelColor(row.statusLabel, COLOR_OWNED)
			setLabelColor(row.nameLabel, COLOR_OWNED)
		else
			row.statusLabel:SetText(CCC.Utilities:FormatStatusText("fail", GetString(CCC_KNOW_STATUS_UNKNOWN)))
			setLabelColor(row.statusLabel, COLOR_MISSING)
			setLabelColor(row.nameLabel, COLOR_MISSING)
		end

		-- TTC estimate for missing purchasable knowledge only (never added to craft total).
		if not req.known and req.itemId then
			if req.unitPrice then
				row.priceLabel:SetText(zo_strformat(GetString(CCC_KNOW_TTC_PRICE), goldText(req.unitPrice)))
			else
				row.priceLabel:SetText(GetString(CCC_KNOW_TTC_PRICE_NA))
			end
		else
			row.priceLabel:SetText("")
		end
	end
end

function UI:ClearRows()
	for i = 1, #UI.rows do
		local row = UI.rows[i]
		row:SetHidden(true)
		CCC.Utilities:ApplyItemIcon(row.icon, nil)
	end
end

function UI:PopulateRows(result)
	UI:ClearRows()

	if not result or not result.lines or #result.lines == 0 then
		return
	end

	local count = math.min(#result.lines, MAX_ROWS)
	for i = 1, count do
		local line = result.lines[i]
		local row = UI:GetRow(i)
		row:ClearAnchors()
		row:SetAnchor(TOPLEFT, UI.listContainer, TOPLEFT, 0, (i - 1) * ROW_HEIGHT)
		row:SetHidden(false)

		local shortfall = line.shortfall or line.quantity or 0
		local fullyOwned = shortfall == 0
		local baseColor = line.missing and COLOR_MISSING or (fullyOwned and COLOR_OWNED or COLOR_NORMAL)

		setLabelColor(row.typeLabel, baseColor)
		setLabelColor(row.needLabel, baseColor)
		setLabelColor(row.ownLabel, baseColor)
		setLabelColor(row.missLabel, fullyOwned and COLOR_OWNED or (shortfall > 0 and COLOR_MISSING or baseColor))
		setLabelColor(row.nameLabel, baseColor)
		setLabelColor(row.unitLabel, baseColor)
		setLabelColor(row.subLabel, baseColor)

		CCC.Utilities:ApplyItemIcon(row.icon,
			CCC.Utilities:ResolveItemIcon(line.itemLink, line.icon))

		row.typeLabel:SetText(categoryLabel(line.category))
		row.needLabel:SetText(tostring(line.required or line.quantity or 0))
		row.ownLabel:SetText(tostring(line.owned or 0))
		row.missLabel:SetText(tostring(shortfall))
		row.nameLabel:SetText(zo_strformat("<<1>>", line.name or "?"))

		if fullyOwned then
			row.unitLabel:SetText(line.unitPrice and goldText(line.unitPrice) or "—")
			row.subLabel:SetText(goldText(0))
		elseif line.missing then
			row.unitLabel:SetText("N/A")
			row.subLabel:SetText("N/A")
		else
			row.unitLabel:SetText(goldText(line.unitPrice))
			row.subLabel:SetText(goldText(line.subtotal))
		end
	end
end

function UI:ShowResult(result)
	if not UI.window then
		return
	end

	UI.currentResult = result
	UI.subtitleLabel:SetText(result.itemLink)

	local info = result.craftInfo
	UI.metaLabel:SetText(UI:FormatCraftMeta(info))

	UI:PopulateKnowledge(result)
	UI:PopulateRows(result)

	-- Hero: full craft cost only (keep short so the gold amount never truncates)
	if result.knowledgeOnly then
		UI.fullTotalLabel:SetText("")
	elseif result.fullTotal ~= nil then
		if result.complete then
			UI.fullTotalLabel:SetText(zo_strformat(GetString(CCC_MSG_FULL_TOTAL),
				CCC.Utilities:FormatGoldText(result.fullTotal, 0)))
		else
			UI.fullTotalLabel:SetText(zo_strformat(GetString(CCC_MSG_FULL_TOTAL_PARTIAL),
				CCC.Utilities:FormatGoldText(result.fullTotal, 0)))
		end
	else
		UI.fullTotalLabel:SetText("")
	end
	setLabelColor(UI.fullTotalLabel, COLOR_GOLD)

	-- Secondary: owned shortfall + market price on one line
	local isWrit = info and info.isMasterWrit
	local marketPrice = result.resultMarketPrice
	local needText = ""
	if not result.knowledgeOnly then
		if result.complete then
			needText = zo_strformat(GetString(CCC_MSG_TOTAL), CCC.Utilities:FormatGoldText(result.total, 0))
		else
			needText = zo_strformat(GetString(CCC_MSG_TOTAL_PARTIAL), CCC.Utilities:FormatGoldText(result.total, 0))
		end
	end
	if marketPrice and marketPrice > 0 then
		local marketStringId = isWrit and CCC_MSG_WRIT_MARKET or CCC_MSG_RESULT_MARKET
		local marketPart = zo_strformat(GetString(marketStringId),
			CCC.Utilities:FormatGoldText(marketPrice, 0))
		if needText ~= "" then
			needText = needText .. "  ·  " .. marketPart
		else
			needText = marketPart
		end
	end
	UI.totalLabel:SetText(needText)

	-- Compare on its own line so "cheaper/more expensive" never truncates mid-word
	local compareText, compareColor = "", COLOR_MUTED
	if not result.knowledgeOnly then
		compareText, compareColor = UI:BuildMarketComparison(result.fullTotal, marketPrice, isWrit)
	end
	if compareText and compareText ~= "" then
		UI.marketLabel:SetText(compareText)
		setLabelColor(UI.marketLabel, compareColor or COLOR_MUTED)
	else
		UI.marketLabel:SetText("")
	end

	-- Missing-knowledge reasons / ingredient warnings in the note area
	local notes = {}
	if result.ingredientWarning and result.ingredientWarning ~= "" then
		notes[#notes + 1] = result.ingredientWarning
	end
	if result.glyphWarning and result.glyphWarning ~= "" then
		notes[#notes + 1] = zo_strformat(GetString(CCC_MSG_GLYPH_WARNING), result.glyphWarning)
	end
	if result.craftInfo and result.craftInfo.glyphWarning and result.craftInfo.glyphWarning ~= ""
		and result.craftInfo.glyphWarning ~= result.glyphWarning then
		notes[#notes + 1] = zo_strformat(GetString(CCC_MSG_GLYPH_WARNING), result.craftInfo.glyphWarning)
	end
	if result.knowledge and not result.knowledge.ready and result.knowledge.missingReasons then
		for i = 1, #result.knowledge.missingReasons do
			notes[#notes + 1] = result.knowledge.missingReasons[i]
		end
	end
	if result.lines and #result.lines > MAX_ROWS then
		notes[#notes + 1] = string.format("+ %d more (see chat)", #result.lines - MAX_ROWS)
	end
	if result.missingCount and result.missingCount > 0 and UI.addon.Settings.showMissingPrices then
		notes[#notes + 1] = zo_strformat(GetString(CCC_MSG_MISSING_PRICES), result.missingCount)
	end
	local noteText = table.concat(notes, "  ·  ")
	if noteText ~= "" then
		noteText = CCC.Utilities:FormatStatusText("warn", noteText)
	end
	UI.noteLabel:SetText(noteText)

	if UI.addShoppingBtn then
		UI.addShoppingBtn:SetEnabled(UI:CountMissingMaterials(result) > 0)
	end
	if UI.addKnowledgeBtn then
		UI.addKnowledgeBtn:SetEnabled(UI:CountPurchasableMissingKnowledge(result) > 0)
	end
	if UI.upgradeCostBtn then
		local canUpgrade = UI:CanOpenUpgradeCost(result)
		UI.upgradeCostBtn:SetHidden(not canUpgrade)
		UI.upgradeCostBtn:SetEnabled(canUpgrade)
	end

	UI:Show()
end

function UI:PrintResultToChat(result)
	d(string.format("|cC5C29E%s|r — %s", CCC.DisplayName, result.itemLink))

	local info = result.craftInfo
	local meta = UI:FormatCraftMeta(info)
	if meta ~= "" then
		d("  " .. meta)
	end

	local knowledge = result.knowledge
	if knowledge and knowledge.hasRequirements then
		if knowledge.ready then
			d(string.format("  |c66CC66%s|r",
				CCC.Utilities:FormatStatusText("ok",
					string.format("%s: %s", GetString(CCC_KNOW_SECTION), GetString(CCC_KNOW_READY)))))
		else
			d(string.format("  |cFFAA55%s|r",
				CCC.Utilities:FormatStatusText("fail",
					string.format("%s: %s", GetString(CCC_KNOW_SECTION), GetString(CCC_KNOW_MISSING)))))
		end
		for i = 1, #knowledge.requirements do
			local req = knowledge.requirements[i]
			if req.known then
				d(string.format("  %s %s: %s — %s",
					CCC.Utilities:FormatStatusText("ok", ""),
					req.kindLabel or req.kind or "?",
					req.name or "?",
					GetString(CCC_KNOW_STATUS_KNOWN)))
			else
				local priceBit = ""
				if req.unitPrice then
					priceBit = " (" .. zo_strformat(GetString(CCC_KNOW_TTC_PRICE),
						CCC.Utilities:FormatGoldText(req.unitPrice, 0)) .. ")"
				end
				d(string.format("  %s %s: %s — %s%s",
					CCC.Utilities:FormatStatusText("fail", ""),
					req.kindLabel or req.kind or "?",
					req.name or "?",
					GetString(CCC_KNOW_STATUS_UNKNOWN),
					priceBit))
			end
		end
		if knowledge.missingReasons then
			for i = 1, #knowledge.missingReasons do
				d("  |cFF6666" .. knowledge.missingReasons[i] .. "|r")
			end
		end
	end

	if result.knowledgeOnly then
		if result.ingredientWarning and result.ingredientWarning ~= "" then
			d("  |cFFAA55" .. result.ingredientWarning .. "|r")
		end
		return
	end

	if result.glyphWarning and result.glyphWarning ~= "" then
		d("  |cFFAA55" .. zo_strformat(GetString(CCC_MSG_GLYPH_WARNING), result.glyphWarning) .. "|r")
	end

	for i = 1, #result.lines do
		local line = result.lines[i]
		local need = line.required or line.quantity or 0
		local owned = line.owned or 0
		local miss = line.shortfall or need
		if line.missing then
			d(string.format("  %s need %d / own %d / miss %d — |cFF6666no TTC price|r",
				line.itemLink, need, owned, miss))
		elseif miss == 0 then
			d(string.format("  %s need %d / own %d / miss 0 — |c66CC66owned|r (%s)",
				line.itemLink, need, owned, CCC.Utilities:FormatGoldText(0)))
		else
			d(string.format("  %s need %d / own %d / miss %d @ %s = %s",
				line.itemLink, need, owned, miss,
				CCC.Utilities:FormatGoldText(line.unitPrice, 0),
				CCC.Utilities:FormatGoldText(line.subtotal, 0)))
		end
	end

	if result.complete then
		d(string.format("|cF0D060Craft cost (missing mats): %s|r", CCC.Utilities:FormatGoldText(result.total, 0)))
	else
		d(string.format("|cF0D060Partial cost (missing mats): %s|r |cFFAA66(%d price gaps)|r",
			CCC.Utilities:FormatGoldText(result.total, 0), result.missingCount))
	end

	if result.fullTotal ~= nil then
		d(string.format("  Full craft cost (from zero): %s",
			CCC.Utilities:FormatGoldText(result.fullTotal, 0)))
	end

	local isWrit = info and info.isMasterWrit
	if result.resultMarketPrice then
		d(string.format("  %s: %s",
			isWrit and "Writ market price" or "Finished item market price",
			CCC.Utilities:FormatGoldText(result.resultMarketPrice, 0)))
	end

	local compareText = UI:BuildMarketComparison(result.fullTotal, result.resultMarketPrice, isWrit)
	if compareText and compareText ~= "" then
		d("  " .. compareText)
	end
end
function UI:RegisterContextMenu()
	local addon = UI.addon

	local function tryAdd(itemLink)
		if not addon.Settings.contextMenu then
			return
		end
		if not itemLink or itemLink == "" then
			return
		end
		if not CCC.Utilities:IsSupportedCraftInput(itemLink) then
			return
		end
		local label = CCC.Utilities:IsMasterWrit(itemLink)
			and GetString(CCC_CONTEXT_CALCULATE_WRIT)
			or GetString(CCC_CONTEXT_CALCULATE)
		AddCustomMenuItem(label, function()
			addon:ShowCostForLink(itemLink)
		end)
	end

	if LibCustomMenu and LibCustomMenu.RegisterContextMenu then
		LibCustomMenu:RegisterContextMenu(function(inventorySlot)
			local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
			if bagId and slotIndex then
				tryAdd(GetItemLink(bagId, slotIndex))
			end
		end)
		return
	end

	local original = ZO_InventorySlot_ShowContextMenu
	if original then
		ZO_InventorySlot_ShowContextMenu = function(inventorySlot)
			original(inventorySlot)
			local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
			if bagId and slotIndex then
				tryAdd(GetItemLink(bagId, slotIndex))
			end
		end
	end
end
