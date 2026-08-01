local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateAttributePoints()
	local WM = GetWindowManager()
	if RAEIH_AttributePoints == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.AttributePointsX
		local mY = RAEIH.SavedVars.AttributePointsY
		local mW = RAEIH.SavedVars.AttributePointsIconW + 10
		local mH = RAEIH.SavedVars.AttributePointsIconH
		local iX = RAEIH.SavedVars.AttributePointsIconX
		local iY = RAEIH.SavedVars.AttributePointsIconY
		local iW = RAEIH.SavedVars.AttributePointsIconW
		local iH = RAEIH.SavedVars.AttributePointsIconH
		local bA = RAEIH.SavedVars.AttributePointsBA
		-- Main Placeholder
		RAEIH_AttributePoints = WM:CreateTopLevelWindow("RAEIH_AttributePoints")
		RAEIH_AttributePoints:SetClampedToScreen(true)
		RAEIH_AttributePoints:SetDrawLevel(1)
		RAEIH_AttributePoints:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_AttributePoints:SetMouseEnabled(true)
		RAEIH_AttributePoints:SetMovable(not RAEIH.SavedVars.LockAttributePoints)
		RAEIH_AttributePoints:SetHandler("OnReceiveDrag", RAEIH.StartMovingAttributePoints)
		RAEIH_AttributePoints:SetHandler("OnMouseUp", RAEIH.StopMovingAttributePoints)
		RAEIH_AttributePoints:SetHidden(not RAEIH.SavedVars.ShowAttributePoints)
		-- Icon
		RAEIH_AttributePoints_Icon = WM:CreateControl("RAEIH_AttributePoints_Icon", RAEIH_AttributePoints, CT_TEXTURE)
		RAEIH_AttributePoints_Icon:SetTexture(RAEIH.Icons.AttributePoints)
		RAEIH_AttributePoints_Icon:SetDimensions(iW, iH)
		RAEIH_AttributePoints_Icon:SetSimpleAnchor(RAEIH_AttributePoints, iX, iY)
		-- String
		RAEIH_AttributePoints_String = WM:CreateControl("RAEIH_AttributePoints_String", RAEIH_AttributePoints, CT_LABEL)
		RAEIH_AttributePoints_String:SetSimpleAnchor(RAEIH_AttributePoints, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_AttributePoints_String:SetHorizontalAlignment(CENTER)
		RAEIH_AttributePoints_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_AttributePoints_Backdrop = WM:CreateControl("RAEIH_AttributePoints_Backdrop", RAEIH_AttributePoints, CT_BACKDROP)
		RAEIH_AttributePoints_Backdrop:SetAnchorFill(RAEIH_AttributePoints)
		RAEIH_AttributePoints_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_AttributePoints_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetAttributePoints()

	local clrDft = "|c" .. RAEIH.SavedVars.AttributePointsDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.AttributePointsAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.AttributePointsWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.AttributePointsNormalColour
	local clr = clrDft

	local unspent = GetAttributeUnspentPoints(uTag)
	local total = GetUnitLevel(uTag) + GetUnitVeteranRank(uTag) - 1
	local spent = total - unspent

	if unspent == 0 then
		clr = clrN
	else
		clr = clrA
	end

	if RAEIH.SavedVars.AttributePointsFormat == "Spent/Total (Unspent)" then
		RAEIH.AttributePointsText = clr .. spent .. clrDft .. "/" .. total .. " (U: " .. clr .. unspent .. clrDft .. ")"
	elseif RAEIH.SavedVars.AttributePointsFormat == "Spent/Total" then
		RAEIH.AttributePointsText = clr .. spent .. clrDft .. "/" .. total
	elseif RAEIH.SavedVars.AttributePointsFormat == "Unspent/Total" then
		RAEIH.AttributePointsText = clr .. unspent .. clrDft .. "/" .. total
	end
	RAEIH_AttributePoints_String:SetText(RAEIH.AttributePointsText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatAttributePoints()

	local font = LMP:Fetch('font', RAEIH.SavedVars.AttributePointsFont)
	local size = RAEIH.SavedVars.AttributePointsFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.AttributePointsFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_AttributePoints_String:SetFont(fontFormat)

end

function RAEIH.OrganizeAttributePoints()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.AttributePointsX
	local mY = RAEIH.SavedVars.AttributePointsY
	local mW = RAEIH.SavedVars.AttributePointsIconW + RAEIH_AttributePoints_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.AttributePointsIconH
	local iX = RAEIH.SavedVars.AttributePointsIconX
	local iY = RAEIH.SavedVars.AttributePointsIconY
	local iW = RAEIH.SavedVars.AttributePointsIconW
	local iH = RAEIH.SavedVars.AttributePointsIconH
	local bA = RAEIH.SavedVars.AttributePointsBA
	-- Update General Dimensions
	RAEIH_AttributePoints:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_AttributePoints_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_AttributePoints_Icon:ClearAnchors()
	RAEIH_AttributePoints_Icon:SetSimpleAnchor(RAEIH_AttributePoints, iX, iY)
	-- Update String Anchor
	RAEIH_AttributePoints_String:ClearAnchors()
	RAEIH_AttributePoints_String:SetSimpleAnchor(RAEIH_AttributePoints, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_AttributePoints_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingAttributePoints()
	RAEIH_AttributePoints:StartMoving()
end

function RAEIH.StopMovingAttributePoints()
	RAEIH_AttributePoints:StopMovingOrResizing()
	RAEIH.SavedVars.AttributePointsX = RAEIH_AttributePoints:GetLeft()
	RAEIH.SavedVars.AttributePointsY = RAEIH_AttributePoints:GetTop()
end