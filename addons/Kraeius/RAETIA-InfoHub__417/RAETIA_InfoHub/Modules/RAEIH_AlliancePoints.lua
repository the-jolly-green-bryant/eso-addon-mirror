local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateAlliancePoints()
	local WM = GetWindowManager()
	if RAEIH_AlliancePoints == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.AlliancePointsX
		local mY = RAEIH.SavedVars.AlliancePointsY
		local mW = RAEIH.SavedVars.AlliancePointsIconW + 10
		local mH = RAEIH.SavedVars.AlliancePointsIconH
		local iX = RAEIH.SavedVars.AlliancePointsIconX
		local iY = RAEIH.SavedVars.AlliancePointsIconY
		local iW = RAEIH.SavedVars.AlliancePointsIconW
		local iH = RAEIH.SavedVars.AlliancePointsIconH
		local bA = RAEIH.SavedVars.AlliancePointsBA
		-- Main Placeholder
		RAEIH_AlliancePoints = WM:CreateTopLevelWindow("RAEIH_AlliancePoints")
		RAEIH_AlliancePoints:SetClampedToScreen(true)
		RAEIH_AlliancePoints:SetDrawLevel(1)
		RAEIH_AlliancePoints:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_AlliancePoints:SetMouseEnabled(true)
		RAEIH_AlliancePoints:SetMovable(not RAEIH.SavedVars.LockAlliancePoints)
		RAEIH_AlliancePoints:SetHandler("OnReceiveDrag", RAEIH.StartMovingAlliancePoints)
		RAEIH_AlliancePoints:SetHandler("OnMouseUp", RAEIH.StopMovingAlliancePoints)
		RAEIH_AlliancePoints:SetHidden(not RAEIH.SavedVars.ShowAlliancePoints)
		-- Icon
		RAEIH_AlliancePoints_Icon = WM:CreateControl("RAEIH_AlliancePoints_Icon", RAEIH_AlliancePoints, CT_TEXTURE)
		RAEIH_AlliancePoints_Icon:SetTexture(RAEIH.Icons.AlliancePoints)
		RAEIH_AlliancePoints_Icon:SetDimensions(iW, iH)
		RAEIH_AlliancePoints_Icon:SetSimpleAnchor(RAEIH_AlliancePoints, iX, iY)
		-- String
		RAEIH_AlliancePoints_String = WM:CreateControl("RAEIH_AlliancePoints_String", RAEIH_AlliancePoints, CT_LABEL)
		RAEIH_AlliancePoints_String:SetSimpleAnchor(RAEIH_AlliancePoints, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_AlliancePoints_String:SetHorizontalAlignment(CENTER)
		RAEIH_AlliancePoints_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_AlliancePoints_Backdrop = WM:CreateControl("RAEIH_AlliancePoints_Backdrop", RAEIH_AlliancePoints, CT_BACKDROP)
		RAEIH_AlliancePoints_Backdrop:SetAnchorFill(RAEIH_AlliancePoints)
		RAEIH_AlliancePoints_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_AlliancePoints_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetAlliancePoints()

	local clrDft = "|c" .. RAEIH.SavedVars.AlliancePointsDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.AlliancePointsAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.AlliancePointsWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.AlliancePointsNormalColour
	local clr = clrDft

	local avaPts = GetAlliancePoints()

	if RAEIH.SavedVars.TSFormat == "Point (.)" then
		avaPts = RAEIH.ThousandsSeparatorPoint(avaPts)
	else
		avaPts = RAEIH.ThousandsSeparatorComma(avaPts)
	end
	RAEIH.AlliancePointsText = clrDft .. avaPts
	RAEIH_AlliancePoints_String:SetText(RAEIH.AlliancePointsText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatAlliancePoints()

	local font = LMP:Fetch('font', RAEIH.SavedVars.AlliancePointsFont)
	local size = RAEIH.SavedVars.AlliancePointsFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.AlliancePointsFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_AlliancePoints_String:SetFont(fontFormat)

end

function RAEIH.OrganizeAlliancePoints()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.AlliancePointsX
	local mY = RAEIH.SavedVars.AlliancePointsY
	local mW = RAEIH.SavedVars.AlliancePointsIconW + RAEIH_AlliancePoints_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.AlliancePointsIconH
	local iX = RAEIH.SavedVars.AlliancePointsIconX
	local iY = RAEIH.SavedVars.AlliancePointsIconY
	local iW = RAEIH.SavedVars.AlliancePointsIconW
	local iH = RAEIH.SavedVars.AlliancePointsIconH
	local bA = RAEIH.SavedVars.AlliancePointsBA
	-- Update General Dimensions
	RAEIH_AlliancePoints:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_AlliancePoints_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_AlliancePoints_Icon:ClearAnchors()
	RAEIH_AlliancePoints_Icon:SetSimpleAnchor(RAEIH_AlliancePoints, iX, iY)
	-- Update String Anchor
	RAEIH_AlliancePoints_String:ClearAnchors()
	RAEIH_AlliancePoints_String:SetSimpleAnchor(RAEIH_AlliancePoints, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_AlliancePoints_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingAlliancePoints()
	RAEIH_AlliancePoints:StartMoving()
end

function RAEIH.StopMovingAlliancePoints()
	RAEIH_AlliancePoints:StopMovingOrResizing()
	RAEIH.SavedVars.AlliancePointsX = RAEIH_AlliancePoints:GetLeft()
	RAEIH.SavedVars.AlliancePointsY = RAEIH_AlliancePoints:GetTop()
end