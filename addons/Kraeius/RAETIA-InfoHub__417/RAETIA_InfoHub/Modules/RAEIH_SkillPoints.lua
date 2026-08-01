local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateSkillPoints()
	local WM = GetWindowManager()
	if RAEIH_SkillPoints == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.SkillPointsX
		local mY = RAEIH.SavedVars.SkillPointsY
		local mW = RAEIH.SavedVars.SkillPointsIconW + 10
		local mH = RAEIH.SavedVars.SkillPointsIconH
		local iX = RAEIH.SavedVars.SkillPointsIconX
		local iY = RAEIH.SavedVars.SkillPointsIconY
		local iW = RAEIH.SavedVars.SkillPointsIconW
		local iH = RAEIH.SavedVars.SkillPointsIconH
		local bA = RAEIH.SavedVars.SkillPointsBA
		-- Main Placeholder
		RAEIH_SkillPoints = WM:CreateTopLevelWindow("RAEIH_SkillPoints")
		RAEIH_SkillPoints:SetClampedToScreen(true)
		RAEIH_SkillPoints:SetDrawLevel(1)
		RAEIH_SkillPoints:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_SkillPoints:SetMouseEnabled(true)
		RAEIH_SkillPoints:SetMovable(not RAEIH.SavedVars.LockSkillPoints)
		RAEIH_SkillPoints:SetHandler("OnReceiveDrag", RAEIH.StartMovingSkillPoints)
		RAEIH_SkillPoints:SetHandler("OnMouseUp", RAEIH.StopMovingSkillPoints)
		RAEIH_SkillPoints:SetHidden(not RAEIH.SavedVars.ShowSkillPoints)
		-- Icon
		RAEIH_SkillPoints_Icon = WM:CreateControl("RAEIH_SkillPoints_Icon", RAEIH_SkillPoints, CT_TEXTURE)
		RAEIH_SkillPoints_Icon:SetTexture(RAEIH.Icons.SkillPoints)
		RAEIH_SkillPoints_Icon:SetDimensions(iW, iH)
		RAEIH_SkillPoints_Icon:SetSimpleAnchor(RAEIH_SkillPoints, iX, iY)
		-- String
		RAEIH_SkillPoints_String = WM:CreateControl("RAEIH_SkillPoints_String", RAEIH_SkillPoints, CT_LABEL)
		RAEIH_SkillPoints_String:SetSimpleAnchor(RAEIH_SkillPoints, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_SkillPoints_String:SetHorizontalAlignment(CENTER)
		RAEIH_SkillPoints_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_SkillPoints_Backdrop = WM:CreateControl("RAEIH_SkillPoints_Backdrop", RAEIH_SkillPoints, CT_BACKDROP)
		RAEIH_SkillPoints_Backdrop:SetAnchorFill(RAEIH_SkillPoints)
		RAEIH_SkillPoints_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_SkillPoints_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetSkillPoints()

	local clrDft = "|c" .. RAEIH.SavedVars.SkillPointsDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.SkillPointsAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.SkillPointsWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.SkillPointsNormalColour
	local clr = clrDft

	local spent = RAEIH.GetTotalSpentSkillPoints()
	local unspent = GetAvailableSkillPoints()
	local total = spent + unspent

	if unspent == 0 then
		clr = clrN
	else
		clr = clrA
	end

	if RAEIH.SavedVars.SkillPointsFormat == "Spent/Total (Unspent)" then
		RAEIH.SkillPointsText = clr .. spent .. clrDft .. "/" .. total .. " (U: " .. clr .. unspent .. clrDft .. ")"
	elseif RAEIH.SavedVars.SkillPointsFormat == "Spent/Total" then
		RAEIH.SkillPointsText = clr .. spent .. clrDft .. "/" .. total
	elseif RAEIH.SavedVars.SkillPointsFormat == "Unspent/Total" then
		RAEIH.SkillPointsText = clr .. unspent .. clrDft .. "/" .. total
	end
	RAEIH_SkillPoints_String:SetText(RAEIH.SkillPointsText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatSkillPoints()

	local font = LMP:Fetch('font', RAEIH.SavedVars.SkillPointsFont)
	local size = RAEIH.SavedVars.SkillPointsFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.SkillPointsFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_SkillPoints_String:SetFont(fontFormat)

end

function RAEIH.OrganizeSkillPoints()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.SkillPointsX
	local mY = RAEIH.SavedVars.SkillPointsY
	local mW = RAEIH.SavedVars.SkillPointsIconW + RAEIH_SkillPoints_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.SkillPointsIconH
	local iX = RAEIH.SavedVars.SkillPointsIconX
	local iY = RAEIH.SavedVars.SkillPointsIconY
	local iW = RAEIH.SavedVars.SkillPointsIconW
	local iH = RAEIH.SavedVars.SkillPointsIconH
	local bA = RAEIH.SavedVars.SkillPointsBA
	-- Update General Dimensions
	RAEIH_SkillPoints:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_SkillPoints_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_SkillPoints_Icon:ClearAnchors()
	RAEIH_SkillPoints_Icon:SetSimpleAnchor(RAEIH_SkillPoints, iX, iY)
	-- Update String Anchor
	RAEIH_SkillPoints_String:ClearAnchors()
	RAEIH_SkillPoints_String:SetSimpleAnchor(RAEIH_SkillPoints, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_SkillPoints_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingSkillPoints()
	RAEIH_SkillPoints:StartMoving()
end

function RAEIH.StopMovingSkillPoints()
	RAEIH_SkillPoints:StopMovingOrResizing()
	RAEIH.SavedVars.SkillPointsX = RAEIH_SkillPoints:GetLeft()
	RAEIH.SavedVars.SkillPointsY = RAEIH_SkillPoints:GetTop()
end