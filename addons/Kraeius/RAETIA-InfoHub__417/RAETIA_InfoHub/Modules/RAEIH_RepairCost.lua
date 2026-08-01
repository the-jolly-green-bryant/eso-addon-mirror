local LMP = RAEIH.LMP
local uTag = "player"
local iconGold = zo_iconFormat("esoui/art/currency/currency_gold.dds", 16, 16)

function RAEIH.CreateRepairCost()
	local WM = GetWindowManager()
	if RAEIH_RepairCost == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.RepairCostX
		local mY = RAEIH.SavedVars.RepairCostY
		local mW = RAEIH.SavedVars.RepairCostIconW + 10
		local mH = RAEIH.SavedVars.RepairCostIconH
		local iX = RAEIH.SavedVars.RepairCostIconX
		local iY = RAEIH.SavedVars.RepairCostIconY
		local iW = RAEIH.SavedVars.RepairCostIconW
		local iH = RAEIH.SavedVars.RepairCostIconH
		local bA = RAEIH.SavedVars.RepairCostBA
		-- Main Placeholder
		RAEIH_RepairCost = WM:CreateTopLevelWindow("RAEIH_RepairCost")
		RAEIH_RepairCost:SetClampedToScreen(true)
		RAEIH_RepairCost:SetDrawLevel(1)
		RAEIH_RepairCost:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_RepairCost:SetMouseEnabled(true)
		RAEIH_RepairCost:SetMovable(not RAEIH.SavedVars.LockRepairCost)
		RAEIH_RepairCost:SetHandler("OnReceiveDrag", RAEIH.StartMovingRepairCost)
		RAEIH_RepairCost:SetHandler("OnMouseUp", RAEIH.StopMovingRepairCost)
		RAEIH_RepairCost:SetHidden(not RAEIH.SavedVars.ShowRepairCost)
		-- Icon
		RAEIH_RepairCost_Icon = WM:CreateControl("RAEIH_RepairCost_Icon", RAEIH_RepairCost, CT_TEXTURE)
		RAEIH_RepairCost_Icon:SetTexture(RAEIH.Icons.RepairCost)
		RAEIH_RepairCost_Icon:SetDimensions(iW, iH)
		RAEIH_RepairCost_Icon:SetSimpleAnchor(RAEIH_RepairCost, iX, iY)
		-- String
		RAEIH_RepairCost_String = WM:CreateControl("RAEIH_RepairCost_String", RAEIH_RepairCost, CT_LABEL)
		RAEIH_RepairCost_String:SetSimpleAnchor(RAEIH_RepairCost, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_RepairCost_String:SetHorizontalAlignment(CENTER)
		RAEIH_RepairCost_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_RepairCost_Backdrop = WM:CreateControl("RAEIH_RepairCost_Backdrop", RAEIH_RepairCost, CT_BACKDROP)
		RAEIH_RepairCost_Backdrop:SetAnchorFill(RAEIH_RepairCost)
		RAEIH_RepairCost_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_RepairCost_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetRepairCost()

	local clrDft = "|c" .. RAEIH.SavedVars.RepairCostDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.RepairCostAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.RepairCostWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.RepairCostNormalColour
	local clr = clrDft

	local repairCost = GetRepairAllCost()
	local noRepairCost = "Nothing"

	if RAEIH.SavedVars.TSFormat == "Point (.)" then
		repairCostF = RAEIH.ThousandsSeparatorPoint(repairCost)
	else
		repairCostF = RAEIH.ThousandsSeparatorComma(repairCost)
	end

	if repairCost == 0 then
		clr = clrN
		RAEIH.RepairCostText = clr .. noRepairCost
	elseif repairCost > 0 and repairCost <= 1000 then
		clr = clrW
		RAEIH.RepairCostText = clr .. tostring(repairCostF) .. iconGold
	else
		clr = clrA
		RAEIH.RepairCostText = clr .. tostring(repairCostF) .. iconGold
	end
	RAEIH_RepairCost_String:SetText(RAEIH.RepairCostText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatRepairCost()

	local font = LMP:Fetch('font', RAEIH.SavedVars.RepairCostFont)
	local size = RAEIH.SavedVars.RepairCostFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.RepairCostFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_RepairCost_String:SetFont(fontFormat)

end

function RAEIH.OrganizeRepairCost()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.RepairCostX
	local mY = RAEIH.SavedVars.RepairCostY
	local mW = RAEIH.SavedVars.RepairCostIconW + RAEIH_RepairCost_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.RepairCostIconH
	local iX = RAEIH.SavedVars.RepairCostIconX
	local iY = RAEIH.SavedVars.RepairCostIconY
	local iW = RAEIH.SavedVars.RepairCostIconW
	local iH = RAEIH.SavedVars.RepairCostIconH
	local bA = RAEIH.SavedVars.RepairCostBA
	-- Update General Dimensions
	RAEIH_RepairCost:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_RepairCost_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_RepairCost_Icon:ClearAnchors()
	RAEIH_RepairCost_Icon:SetSimpleAnchor(RAEIH_RepairCost, iX, iY)
	-- Update String Anchor
	RAEIH_RepairCost_String:ClearAnchors()
	RAEIH_RepairCost_String:SetSimpleAnchor(RAEIH_RepairCost, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_RepairCost_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingRepairCost()
	RAEIH_RepairCost:StartMoving()
end

function RAEIH.StopMovingRepairCost()
	RAEIH_RepairCost:StopMovingOrResizing()
	RAEIH.SavedVars.RepairCostX = RAEIH_RepairCost:GetLeft()
	RAEIH.SavedVars.RepairCostY = RAEIH_RepairCost:GetTop()
end