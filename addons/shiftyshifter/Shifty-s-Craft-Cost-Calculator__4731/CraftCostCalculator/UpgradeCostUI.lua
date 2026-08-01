--[[
	UpgradeCostUI
	Dedicated window for the Upgrade Cost Calculator.

	Shows each quality step (e.g. White → Green) with owned-material totals,
	plus a current-quality selector and summary footer.
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.UpgradeCostUI = CCC.UpgradeCostUI or {}
local UCUI = CCC.UpgradeCostUI

local MAX_STEPS = 4
local WINDOW_WIDTH = 520
local WINDOW_HEIGHT_BASE = 300
local PAD = 18
local CONTENT_WIDTH = WINDOW_WIDTH - (PAD * 2)
local STEP_HEIGHT = 56
local STEP_GAP = 8
local STEP_ICON = 36
local STEP_COST_W = 110
local QUALITY_BTN_W = 86
local QUALITY_BTN_H = 26
local FOOTER_HEIGHT = 100
local ACTION_BTN_W = 178
local ACTION_BTN_H = 24

local COLOR_HEADER = {0.65, 0.65, 0.65, 1}
local COLOR_NORMAL = {0.92, 0.92, 0.92, 1}
local COLOR_MISSING = {1.0, 0.55, 0.55, 1}
local COLOR_OWNED = {0.45, 0.85, 0.55, 1}
local COLOR_GOLD = {0.95, 0.85, 0.4, 1}
local COLOR_MUTED = {0.62, 0.62, 0.62, 1}
local COLOR_TITLE = {0.85, 0.78, 0.55, 1}
local COLOR_STEP_BG = {0.11, 0.11, 0.13, 0.88}
local COLOR_STEP_EDGE = {0.35, 0.32, 0.24, 0.45}

-- Same numeric tiers as UpgradeCostCalculator (game globals may be missing mid-tiers).
local QUALITY_NORMAL = ITEM_FUNCTIONAL_QUALITY_NORMAL or 1
local QUALITY_FINE = ITEM_FUNCTIONAL_QUALITY_FINE or 2
local QUALITY_SUPERIOR = ITEM_FUNCTIONAL_QUALITY_SUPERIOR or 3
local QUALITY_EPIC = ITEM_FUNCTIONAL_QUALITY_EPIC or 4
local QUALITY_LEGENDARY = ITEM_FUNCTIONAL_QUALITY_LEGENDARY or 5

local QUALITY_COLORS = {
	[QUALITY_NORMAL] = {0.88, 0.88, 0.88, 1},
	[QUALITY_FINE] = {0.35, 0.82, 0.40, 1},
	[QUALITY_SUPERIOR] = {0.40, 0.62, 0.95, 1},
	[QUALITY_EPIC] = {0.72, 0.38, 0.90, 1},
	[QUALITY_LEGENDARY] = {0.95, 0.82, 0.35, 1},
}

function UCUI:Init(addon)
	UCUI.addon = addon
	UCUI.stepPanels = {}
	UCUI.qualityButtons = {}
	UCUI.fromQuality = QUALITY_NORMAL
	UCUI.craftInfo = nil
	UCUI.itemLink = nil
	UCUI.currentResult = nil
	UCUI:CreateWindow()
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

function UCUI:CreateQualitySelector(wm, parent)
	local host = wm:CreateControl(CCC.Name .. "UpgradeQualityHost", parent, CT_CONTROL)
	host:SetDimensions(CONTENT_WIDTH, 52)
	UCUI.qualityHost = host

	local label = makeLabel(wm, CCC.Name .. "UpgradeQualityLabel", host, "ZoFontGameSmall")
	setLabelColor(label, COLOR_HEADER)
	label:SetAnchor(TOPLEFT, host, TOPLEFT, 0, 0)
	label:SetText(GetString(CCC_UPGRADE_CURRENT_QUALITY))
	UCUI.qualityLabel = label

	local btnRow = wm:CreateControl(CCC.Name .. "UpgradeQualityBtns", host, CT_CONTROL)
	btnRow:SetAnchor(TOPLEFT, label, BOTTOMLEFT, 0, 6)
	btnRow:SetDimensions(CONTENT_WIDTH, QUALITY_BTN_H)

	local qualities = UCUI.addon.UpgradeCostCalculator:GetSelectableQualities()
	local gap = 8
	for i = 1, #qualities do
		local q = qualities[i]
		local name = UCUI.addon.UpgradeCostCalculator:GetQualityName(q)
		local btn = makeTextButton(wm, CCC.Name .. "UpgradeQualityBtn" .. q, btnRow, name, QUALITY_BTN_W, QUALITY_BTN_H)
		btn:SetAnchor(TOPLEFT, btnRow, TOPLEFT, (i - 1) * (QUALITY_BTN_W + gap), 0)
		btn.quality = q
		btn:SetHandler("OnClicked", function()
			UCUI:SetFromQuality(q)
		end)
		UCUI.qualityButtons[q] = btn
	end

	local target = makeLabel(wm, CCC.Name .. "UpgradeTargetLabel", host, "ZoFontGameSmall")
	setLabelColor(target, COLOR_MUTED)
	target:SetAnchor(TOPRIGHT, host, TOPRIGHT, 0, 28)
	target:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	target:SetText(GetString(CCC_UPGRADE_TARGET_GOLD))
	UCUI.targetLabel = target
end

function UCUI:CreateStepPanel(index)
	local wm = GetWindowManager()
	local parent = UCUI.stepsContainer
	local panel = wm:CreateControl(CCC.Name .. "UpgradeStep" .. index, parent, CT_CONTROL)
	panel:SetDimensions(CONTENT_WIDTH, STEP_HEIGHT)
	panel:SetHidden(true)

	local bg = wm:CreateControl(CCC.Name .. "UpgradeStep" .. index .. "BG", panel, CT_BACKDROP)
	bg:SetAnchorFill(panel)
	bg:SetCenterColor(COLOR_STEP_BG[1], COLOR_STEP_BG[2], COLOR_STEP_BG[3], COLOR_STEP_BG[4])
	bg:SetEdgeColor(COLOR_STEP_EDGE[1], COLOR_STEP_EDGE[2], COLOR_STEP_EDGE[3], COLOR_STEP_EDGE[4])
	bg:SetEdgeTexture("", 1, 1, 1)
	panel.bg = bg

	local accent = wm:CreateControl(CCC.Name .. "UpgradeStep" .. index .. "Accent", panel, CT_TEXTURE)
	accent:SetDimensions(3, STEP_HEIGHT - 10)
	accent:SetAnchor(LEFT, panel, LEFT, 5, 0)
	accent:SetColor(0.55, 0.48, 0.32, 1)
	panel.accent = accent

	local icon = wm:CreateControl(CCC.Name .. "UpgradeStep" .. index .. "Icon", panel, CT_TEXTURE)
	icon:SetDimensions(STEP_ICON, STEP_ICON)
	icon:SetAnchor(LEFT, panel, LEFT, 16, 0)
	icon:SetHidden(true)
	panel.icon = icon

	local textLeft = 16 + STEP_ICON + 10
	local textWidth = CONTENT_WIDTH - textLeft - STEP_COST_W - 14

	local path = makeLabel(wm, CCC.Name .. "UpgradeStep" .. index .. "Path", panel, "ZoFontGameSmall")
	path:SetAnchor(TOPLEFT, panel, TOPLEFT, textLeft, 8)
	path:SetDimensions(textWidth, 14)
	setLabelColor(path, COLOR_MUTED)
	panel.pathLabel = path

	local mat = makeLabel(wm, CCC.Name .. "UpgradeStep" .. index .. "Mat", panel, "ZoFontGameBold")
	mat:SetAnchor(TOPLEFT, path, BOTTOMLEFT, 0, 1)
	mat:SetDimensions(textWidth, 18)
	setLabelColor(mat, COLOR_NORMAL)
	panel.matLabel = mat

	local status = makeLabel(wm, CCC.Name .. "UpgradeStep" .. index .. "Status", panel, "ZoFontGameBold")
	status:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -12, 10)
	status:SetDimensions(STEP_COST_W, 18)
	status:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	setLabelColor(status, COLOR_GOLD)
	panel.statusLabel = status

	local meta = makeLabel(wm, CCC.Name .. "UpgradeStep" .. index .. "Meta", panel, "ZoFontGameSmall")
	meta:SetAnchor(TOPRIGHT, status, BOTTOMRIGHT, 0, 1)
	meta:SetDimensions(STEP_COST_W, 14)
	meta:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	setLabelColor(meta, COLOR_MUTED)
	panel.metaLabel = meta

	UCUI.stepPanels[index] = panel
	return panel
end

function UCUI:CreateWindow()
	local wm = GetWindowManager()
	local control = wm:CreateTopLevelWindow(CCC.Name .. "UpgradeWindow")
	control:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT_BASE + MAX_STEPS * (STEP_HEIGHT + STEP_GAP))
	control:SetAnchor(CENTER, GuiRoot, CENTER, 80, 20)
	control:SetMovable(true)
	control:SetMouseEnabled(true)
	control:SetClampedToScreen(true)
	control:SetHidden(true)
	control:SetDrawLayer(DL_OVERLAY)

	local bg = wm:CreateControl(CCC.Name .. "UpgradeWindowBG", control, CT_BACKDROP)
	bg:SetAnchorFill(control)
	bg:SetCenterColor(0.06, 0.06, 0.07, 0.96)
	bg:SetEdgeColor(0.55, 0.48, 0.32, 1)
	bg:SetEdgeTexture("", 1, 1, 2)

	local title = makeLabel(wm, CCC.Name .. "UpgradeWindowTitle", control, "ZoFontWinH2")
	setLabelColor(title, COLOR_TITLE)
	title:SetAnchor(TOPLEFT, control, TOPLEFT, PAD, 14)
	title:SetText(GetString(CCC_UPGRADE_TITLE))

	local closeBtn = wm:CreateControl(CCC.Name .. "UpgradeWindowClose", control, CT_BUTTON)
	closeBtn:SetDimensions(28, 28)
	closeBtn:SetAnchor(TOPRIGHT, control, TOPRIGHT, -10, 10)
	closeBtn:SetMouseEnabled(true)
	CCC.Utilities:ApplyCloseButtonTextures(closeBtn)
	closeBtn:SetHandler("OnClicked", function()
		control:SetHidden(true)
	end)

	local subtitle = makeLabel(wm, CCC.Name .. "UpgradeWindowSubtitle", control, "ZoFontGame")
	setLabelColor(subtitle, COLOR_NORMAL)
	subtitle:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 8)
	subtitle:SetDimensions(CONTENT_WIDTH, 24)
	subtitle:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
	UCUI.subtitleLabel = subtitle

	local meta = makeLabel(wm, CCC.Name .. "UpgradeWindowMeta", control, "ZoFontGameSmall")
	setLabelColor(meta, COLOR_MUTED)
	meta:SetAnchor(TOPLEFT, subtitle, BOTTOMLEFT, 0, 2)
	meta:SetDimensions(CONTENT_WIDTH, 18)
	UCUI.metaLabel = meta

	UCUI:CreateQualitySelector(wm, control)
	UCUI.qualityHost:SetAnchor(TOPLEFT, meta, BOTTOMLEFT, 0, 10)

	local pathRule = wm:CreateControl(CCC.Name .. "UpgradePathRule", control, CT_TEXTURE)
	pathRule:SetDimensions(CONTENT_WIDTH, 1)
	pathRule:SetAnchor(TOPLEFT, UCUI.qualityHost, BOTTOMLEFT, 0, 10)
	pathRule:SetColor(0.55, 0.48, 0.32, 0.7)

	local stepsContainer = wm:CreateControl(CCC.Name .. "UpgradeSteps", control, CT_CONTROL)
	stepsContainer:SetAnchor(TOPLEFT, pathRule, BOTTOMLEFT, 0, 10)
	stepsContainer:SetDimensions(CONTENT_WIDTH, MAX_STEPS * (STEP_HEIGHT + STEP_GAP))
	UCUI.stepsContainer = stepsContainer

	for i = 1, MAX_STEPS do
		UCUI:CreateStepPanel(i)
	end

	local footerRule = wm:CreateControl(CCC.Name .. "UpgradeFooterRule", control, CT_TEXTURE)
	footerRule:SetDimensions(CONTENT_WIDTH, 1)
	footerRule:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, PAD, -(FOOTER_HEIGHT + 4))
	footerRule:SetColor(0.55, 0.48, 0.32, 0.7)
	UCUI.footerRule = footerRule

	local note = makeLabel(wm, CCC.Name .. "UpgradeNote", control, "ZoFontGameSmall")
	setLabelColor(note, {1.0, 0.72, 0.42, 1})
	note:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, PAD, -(FOOTER_HEIGHT - 2))
	note:SetDimensions(CONTENT_WIDTH - ACTION_BTN_W - 12, 14)
	UCUI.noteLabel = note

	-- Hero: full upgrade cost
	local fullTotal = makeLabel(wm, CCC.Name .. "UpgradeFullTotal", control, "ZoFontWinH3")
	setLabelColor(fullTotal, COLOR_GOLD)
	fullTotal:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, PAD, -42)
	fullTotal:SetDimensions(CONTENT_WIDTH - ACTION_BTN_W - 12, 22)
	UCUI.fullTotalLabel = fullTotal

	-- Secondary: what the player still needs after owned mats
	local total = makeLabel(wm, CCC.Name .. "UpgradeTotal", control, "ZoFontGameSmall")
	setLabelColor(total, COLOR_MUTED)
	total:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, PAD, -18)
	total:SetDimensions(CONTENT_WIDTH - ACTION_BTN_W - 12, 16)
	UCUI.totalLabel = total

	local function makeActionButton(name, text, bottomOffset)
		local btn = makeTextButton(wm, name, control, text, ACTION_BTN_W, ACTION_BTN_H)
		btn:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -PAD, bottomOffset)
		return btn
	end

	local addBtn = makeActionButton(CCC.Name .. "UpgradeAddShopping", GetString(CCC_BTN_ADD_TO_SHOPPING_LIST), -42)
	addBtn:SetEnabled(false)
	addBtn:SetHandler("OnClicked", function()
		UCUI:AddCurrentToShoppingList()
	end)
	UCUI.addShoppingBtn = addBtn

	local viewBtn = makeActionButton(CCC.Name .. "UpgradeViewShopping", GetString(CCC_BTN_VIEW_SHOPPING_LIST), -14)
	viewBtn:SetHandler("OnClicked", function()
		UCUI:OpenShoppingList()
	end)
	UCUI.viewShoppingBtn = viewBtn

	UCUI.window = control
end

function UCUI:UpdateQualityButtons()
	for q, btn in pairs(UCUI.qualityButtons) do
		local color = QUALITY_COLORS[q] or COLOR_NORMAL
		if q == UCUI.fromQuality then
			btn:SetNormalFontColor(color[1], color[2], color[3], 1)
			btn:SetMouseOverFontColor(1, 1, 1, 1)
			btn:SetText(string.format("[%s]", UCUI.addon.UpgradeCostCalculator:GetQualityName(q)))
		else
			btn:SetNormalFontColor(color[1] * 0.75, color[2] * 0.75, color[3] * 0.75, 0.85)
			btn:SetMouseOverFontColor(color[1], color[2], color[3], 1)
			btn:SetText(UCUI.addon.UpgradeCostCalculator:GetQualityName(q))
		end
	end
end

function UCUI:ResizeForStepCount(stepCount)
	stepCount = math.max(1, math.min(stepCount or 1, MAX_STEPS))
	local stepsHeight = stepCount * (STEP_HEIGHT + STEP_GAP)
	UCUI.stepsContainer:SetDimensions(CONTENT_WIDTH, stepsHeight)
	UCUI.window:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT_BASE + stepsHeight)
end

function UCUI:ClearSteps()
	for i = 1, #UCUI.stepPanels do
		local panel = UCUI.stepPanels[i]
		panel:SetHidden(true)
		CCC.Utilities:ApplyItemIcon(panel.icon, nil)
	end
end

function UCUI:PopulateSteps(result)
	UCUI:ClearSteps()
	if not result or not result.steps then
		UCUI:ResizeForStepCount(1)
		return
	end

	local count = math.min(#result.steps, MAX_STEPS)
	UCUI:ResizeForStepCount(count)

	for i = 1, count do
		local step = result.steps[i]
		local panel = UCUI.stepPanels[i]
		panel:ClearAnchors()
		panel:SetAnchor(TOPLEFT, UCUI.stepsContainer, TOPLEFT, 0, (i - 1) * (STEP_HEIGHT + STEP_GAP))
		panel:SetHidden(false)

		local accentColor = QUALITY_COLORS[step.toQuality] or COLOR_TITLE
		panel.accent:SetColor(accentColor[1], accentColor[2], accentColor[3], 1)

		panel.pathLabel:SetText(step.label or "")
		setLabelColor(panel.pathLabel, accentColor)

		CCC.Utilities:ApplyItemIcon(panel.icon,
			CCC.Utilities:ResolveItemIcon(step.itemLink, step.icon))

		panel.matLabel:SetText(zo_strformat(GetString(CCC_UPGRADE_STEP_MAT),
			zo_strformat("<<1>>", step.name or "?"),
			step.required or 0))
		setLabelColor(panel.matLabel, COLOR_NORMAL)

		local shortfall = step.shortfall or 0
		local fullyOwned = shortfall == 0

		if fullyOwned then
			panel.statusLabel:SetText(GetString(CCC_UPGRADE_STEP_READY))
			setLabelColor(panel.statusLabel, COLOR_OWNED)
			panel.metaLabel:SetText(zo_strformat(GetString(CCC_UPGRADE_STEP_HAVE),
				step.owned or 0))
			setLabelColor(panel.metaLabel, COLOR_MUTED)
		else
			if step.missing then
				panel.statusLabel:SetText(GetString(CCC_UPGRADE_STEP_COST_NA))
				setLabelColor(panel.statusLabel, COLOR_MISSING)
			else
				panel.statusLabel:SetText(zo_strformat(GetString(CCC_UPGRADE_STEP_COST),
					goldText(step.subtotal)))
				setLabelColor(panel.statusLabel, COLOR_GOLD)
			end
			panel.metaLabel:SetText(zo_strformat(GetString(CCC_UPGRADE_STEP_NEED),
				shortfall))
			setLabelColor(panel.metaLabel, COLOR_MISSING)
		end
	end
end

function UCUI:CountMissingMaterials(result)
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

function UCUI:OpenShoppingList()
	if UCUI.addon.ShoppingListUI then
		UCUI.addon.ShoppingListUI:Show()
	end
end

function UCUI:AddCurrentToShoppingList()
	local result = UCUI.currentResult
	if not result then
		d(GetString(CCC_MSG_SHOPPING_LIST_NO_RESULT))
		return
	end

	local added, merged, totalQty = UCUI.addon.ShoppingList:AddFromResult(result)
	if (added + merged) == 0 or totalQty == 0 then
		d(GetString(CCC_MSG_SHOPPING_LIST_NONE))
		return
	end

	d(zo_strformat(GetString(CCC_MSG_SHOPPING_LIST_ADDED), added + merged, added, merged))

	if UCUI.addon.ShoppingListUI then
		UCUI.addon.ShoppingListUI:Show()
	end
end

function UCUI:ShowResult(result)
	if not UCUI.window or not result then
		return
	end

	UCUI.currentResult = result
	UCUI.fromQuality = result.fromQuality
	UCUI.subtitleLabel:SetText(result.itemLink or "")
	UCUI.metaLabel:SetText(string.format("%s  ·  %s → %s",
		result.stationName or "",
		result.fromName or "?",
		result.toName or "?"))

	UCUI:UpdateQualityButtons()
	UCUI:PopulateSteps(result)

	-- Note: only price-gap warnings (owned status is visible on step rows)
	local notes = {}
	if result.missingCount and result.missingCount > 0 and UCUI.addon.Settings.showMissingPrices then
		notes[#notes + 1] = zo_strformat(GetString(CCC_MSG_MISSING_PRICES), result.missingCount)
	end
	local noteText = table.concat(notes, "  ·  ")
	if noteText ~= "" then
		noteText = CCC.Utilities:FormatStatusText("warn", noteText)
	end
	UCUI.noteLabel:SetText(noteText)

	-- Hero: full upgrade cost
	if result.fullTotal ~= nil then
		if result.complete then
			UCUI.fullTotalLabel:SetText(zo_strformat(GetString(CCC_UPGRADE_TOTAL_FULL),
				CCC.Utilities:FormatGoldText(result.fullTotal, 0)))
		else
			UCUI.fullTotalLabel:SetText(zo_strformat(GetString(CCC_UPGRADE_TOTAL_FULL_PARTIAL),
				CCC.Utilities:FormatGoldText(result.fullTotal, 0)))
		end
	else
		UCUI.fullTotalLabel:SetText("")
	end

	-- Secondary: what you still need after owned mats
	if result.complete then
		UCUI.totalLabel:SetText(zo_strformat(GetString(CCC_UPGRADE_TOTAL_MISSING),
			CCC.Utilities:FormatGoldText(result.total, 0)))
	else
		UCUI.totalLabel:SetText(zo_strformat(GetString(CCC_UPGRADE_TOTAL_MISSING_PARTIAL),
			CCC.Utilities:FormatGoldText(result.total, 0)))
	end

	if UCUI.addShoppingBtn then
		UCUI.addShoppingBtn:SetEnabled(UCUI:CountMissingMaterials(result) > 0)
	end

	UCUI:Show()
end

function UCUI:Recalculate()
	if not UCUI.craftInfo or not UCUI.itemLink then
		return
	end

	local result, err = UCUI.addon.UpgradeCostCalculator:Calculate(
		UCUI.craftInfo,
		UCUI.itemLink,
		UCUI.fromQuality
	)
	if not result then
		d(string.format("|cFF6666Upgrade Cost Calculator:|r %s", err or "Unknown error"))
		return
	end
	UCUI:ShowResult(result)
end

function UCUI:SetFromQuality(quality)
	if quality == UCUI.fromQuality and UCUI.currentResult then
		return
	end
	UCUI.fromQuality = quality
	UCUI:Recalculate()
end

--- Open calculator for a craft result (or raw craftInfo + link).
function UCUI:Open(craftInfo, itemLink, fromQuality)
	if not craftInfo or not itemLink then
		return
	end
	if craftInfo.isMasterWrit then
		d("|cFF6666Upgrade Cost Calculator:|r " .. GetString(CCC_UPGRADE_ERR_WRIT))
		return
	end
	if not UCUI.addon.UpgradeCostCalculator:IsSupportedStation(craftInfo.station) then
		d("|cFF6666Upgrade Cost Calculator:|r " .. GetString(CCC_UPGRADE_ERR_STATION))
		return
	end

	UCUI.craftInfo = craftInfo
	UCUI.itemLink = itemLink
	UCUI.fromQuality = fromQuality or UCUI.addon.UpgradeCostCalculator:DefaultFromQuality(craftInfo)
	UCUI:Recalculate()
end

function UCUI:Refresh()
	if not UCUI:IsVisible() then
		return
	end
	UCUI:Recalculate()
end

function UCUI:Show()
	if UCUI.window then
		UCUI.window:SetHidden(false)
	end
end

function UCUI:Hide()
	if UCUI.window then
		UCUI.window:SetHidden(true)
	end
end

function UCUI:IsVisible()
	return UCUI.window and not UCUI.window:IsHidden()
end

function UCUI:Toggle()
	if UCUI:IsVisible() then
		UCUI:Hide()
	elseif UCUI.craftInfo and UCUI.itemLink then
		UCUI:Recalculate()
	end
end
