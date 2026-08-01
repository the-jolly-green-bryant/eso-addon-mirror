local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateAchievementPoints()
	local WM = GetWindowManager()
	if RAEIH_AchievementPoints == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.AchievementPointsX
		local mY = RAEIH.SavedVars.AchievementPointsY
		local mW = RAEIH.SavedVars.AchievementPointsIconW + 10
		local mH = RAEIH.SavedVars.AchievementPointsIconH
		local iX = RAEIH.SavedVars.AchievementPointsIconX
		local iY = RAEIH.SavedVars.AchievementPointsIconY
		local iW = RAEIH.SavedVars.AchievementPointsIconW
		local iH = RAEIH.SavedVars.AchievementPointsIconH
		local bA = RAEIH.SavedVars.AchievementPointsBA
		-- Main Placeholder
		RAEIH_AchievementPoints = WM:CreateTopLevelWindow("RAEIH_AchievementPoints")
		RAEIH_AchievementPoints:SetClampedToScreen(true)
		RAEIH_AchievementPoints:SetDrawLevel(1)
		RAEIH_AchievementPoints:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_AchievementPoints:SetMouseEnabled(true)
		RAEIH_AchievementPoints:SetMovable(not RAEIH.SavedVars.LockAchievementPoints)
		RAEIH_AchievementPoints:SetHandler("OnReceiveDrag", RAEIH.StartMovingAchievementPoints)
		RAEIH_AchievementPoints:SetHandler("OnMouseUp", RAEIH.StopMovingAchievementPoints)
		RAEIH_AchievementPoints:SetHidden(not RAEIH.SavedVars.ShowAchievementPoints)
		-- Icon
		RAEIH_AchievementPoints_Icon = WM:CreateControl("RAEIH_AchievementPoints_Icon", RAEIH_AchievementPoints, CT_TEXTURE)
		RAEIH_AchievementPoints_Icon:SetTexture(RAEIH.Icons.AchievementPoints)
		RAEIH_AchievementPoints_Icon:SetDimensions(iW, iH)
		RAEIH_AchievementPoints_Icon:SetSimpleAnchor(RAEIH_AchievementPoints, iX, iY)
		-- String
		RAEIH_AchievementPoints_String = WM:CreateControl("RAEIH_AchievementPoints_String", RAEIH_AchievementPoints, CT_LABEL)
		RAEIH_AchievementPoints_String:SetSimpleAnchor(RAEIH_AchievementPoints, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_AchievementPoints_String:SetHorizontalAlignment(CENTER)
		RAEIH_AchievementPoints_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_AchievementPoints_Backdrop = WM:CreateControl("RAEIH_AchievementPoints_Backdrop", RAEIH_AchievementPoints, CT_BACKDROP)
		RAEIH_AchievementPoints_Backdrop:SetAnchorFill(RAEIH_AchievementPoints)
		RAEIH_AchievementPoints_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_AchievementPoints_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetAchievementPoints()

	local clrDft = "|c" .. RAEIH.SavedVars.AchievementPointsDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.AchievementPointsAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.AchievementPointsWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.AchievementPointsNormalColour
	local clr = clrDft

	local achPts = GetEarnedAchievementPoints()
	local totalAchPts = GetTotalAchievementPoints()
	local achPerc = RAEIH.Round(achPts / totalAchPts * 100)

	if achPerc < 25 then
		clr = clrA
	elseif achPerc >= 25 and achPerc < 75  then
		clr = clrW
	else
		clr = clrN
	end

	if RAEIH.SavedVars.TSFormat == "Point (.)" then
		achPts = RAEIH.ThousandsSeparatorPoint(achPts)
		totalAchPts = RAEIH.ThousandsSeparatorPoint(totalAchPts)
		achPerc = string.gsub(tostring(achPerc), "%.", ",") .. "%"
	else
		achPts = RAEIH.ThousandsSeparatorComma(achPts)
		totalAchPts = RAEIH.ThousandsSeparatorComma(totalAchPts)
		achPerc = tostring(achPerc) .. "%"
	end

	if RAEIH.SavedVars.AchievementPointsFormat == "Current/Max (%)" then
		RAEIH.AchievementPointsText = clr .. achPts .. clrDft .. "/" .. totalAchPts .. " (" .. clr .. achPerc .. clrDft .. ")"

	elseif RAEIH.SavedVars.AchievementPointsFormat == "Current/Max" then
		RAEIH.AchievementPointsText = clr .. achPts .. clrDft .. "/" .. totalAchPts

	else
		RAEIH.AchievementPointsText = clr .. achPerc
	end
	RAEIH_AchievementPoints_String:SetText(RAEIH.AchievementPointsText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatAchievementPoints()

	local font = LMP:Fetch('font', RAEIH.SavedVars.AchievementPointsFont)
	local size = RAEIH.SavedVars.AchievementPointsFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.AchievementPointsFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_AchievementPoints_String:SetFont(fontFormat)

end

function RAEIH.OrganizeAchievementPoints()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.AchievementPointsX
	local mY = RAEIH.SavedVars.AchievementPointsY
	local mW = RAEIH.SavedVars.AchievementPointsIconW + RAEIH_AchievementPoints_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.AchievementPointsIconH
	local iX = RAEIH.SavedVars.AchievementPointsIconX
	local iY = RAEIH.SavedVars.AchievementPointsIconY
	local iW = RAEIH.SavedVars.AchievementPointsIconW
	local iH = RAEIH.SavedVars.AchievementPointsIconH
	local bA = RAEIH.SavedVars.AchievementPointsBA
	-- Update General Dimensions
	RAEIH_AchievementPoints:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_AchievementPoints_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_AchievementPoints_Icon:ClearAnchors()
	RAEIH_AchievementPoints_Icon:SetSimpleAnchor(RAEIH_AchievementPoints, iX, iY)
	-- Update String Anchor
	RAEIH_AchievementPoints_String:ClearAnchors()
	RAEIH_AchievementPoints_String:SetSimpleAnchor(RAEIH_AchievementPoints, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_AchievementPoints_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingAchievementPoints()
	RAEIH_AchievementPoints:StartMoving()
end

function RAEIH.StopMovingAchievementPoints()
	RAEIH_AchievementPoints:StopMovingOrResizing()
	RAEIH.SavedVars.AchievementPointsX = RAEIH_AchievementPoints:GetLeft()
	RAEIH.SavedVars.AchievementPointsY = RAEIH_AchievementPoints:GetTop()
end