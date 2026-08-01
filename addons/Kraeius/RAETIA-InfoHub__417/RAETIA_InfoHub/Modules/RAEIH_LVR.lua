local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateLVR()
	local WM = GetWindowManager()
	if RAEIH_LVR == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.LVRX
		local mY = RAEIH.SavedVars.LVRY
		local mW = RAEIH.SavedVars.LVRIconW + 10
		local mH = RAEIH.SavedVars.LVRIconH
		local iX = RAEIH.SavedVars.LVRIconX
		local iY = RAEIH.SavedVars.LVRIconY
		local iW = RAEIH.SavedVars.LVRIconW
		local iH = RAEIH.SavedVars.LVRIconH
		local bA = RAEIH.SavedVars.LVRBA
		-- Main Placeholder
		RAEIH_LVR = WM:CreateTopLevelWindow("RAEIH_LVR")
		RAEIH_LVR:SetClampedToScreen(true)
		RAEIH_LVR:SetDrawLevel(1)
		RAEIH_LVR:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_LVR:SetMouseEnabled(true)
		RAEIH_LVR:SetMovable(not RAEIH.SavedVars.LockLVR)
		RAEIH_LVR:SetHandler("OnReceiveDrag", RAEIH.StartMovingLVR)
		RAEIH_LVR:SetHandler("OnMouseUp", RAEIH.StopMovingLVR)
		RAEIH_LVR:SetHidden(not RAEIH.SavedVars.ShowLVR)
		-- Icon
		RAEIH_LVR_Icon = WM:CreateControl("RAEIH_LVR_Icon", RAEIH_LVR, CT_TEXTURE)
		RAEIH_LVR_Icon:SetTexture(RAEIH.Icons.LVR)
		RAEIH_LVR_Icon:SetDimensions(iW, iH)
		RAEIH_LVR_Icon:SetSimpleAnchor(RAEIH_LVR, iX, iY)
		-- String
		RAEIH_LVR_String = WM:CreateControl("RAEIH_LVR_String", RAEIH_LVR, CT_LABEL)
		RAEIH_LVR_String:SetSimpleAnchor(RAEIH_LVR, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_LVR_String:SetHorizontalAlignment(CENTER)
		RAEIH_LVR_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_LVR_Backdrop = WM:CreateControl("RAEIH_LVR_Backdrop", RAEIH_LVR, CT_BACKDROP)
		RAEIH_LVR_Backdrop:SetAnchorFill(RAEIH_LVR)
		RAEIH_LVR_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_LVR_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end

	RAEIH.isVeteran = RAEIH.isVeteran or IsUnitVeteran(uTag)
	RAEIH.hasMaxVR = RAEIH.hasMaxVR or (GetUnitVeteranRank(uTag) == 16)
end

function RAEIH.SetLVR()
	local clrDft = "|c" .. RAEIH.SavedVars.LVRDefaultColour
	local clrLVR = "|c" .. RAEIH.SavedVars.LVRColour

	--RAEIH.isVeteran = RAEIH.isVeteran or IsUnitVeteran(uTag)

	RAEIH.isChampion = RAEIH.isChampion or IsUnitChampion(uTag)
	
	if RAEIH.isChampion then
		RAEIH.LVRText = clrDft .. "CP-" .. clrLVR .. GetPlayerChampionPointsEarned()
	else
		RAEIH.LVRText = clrDft .. "L-" .. clrLVR .. GetUnitLevel(uTag)
	end

	RAEIH_LVR_String:SetText(RAEIH.LVRText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatLVR()

	local font = LMP:Fetch('font', RAEIH.SavedVars.LVRFont)
	local size = RAEIH.SavedVars.LVRFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.LVRFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_LVR_String:SetFont(fontFormat)

end

function RAEIH.OrganizeLVR()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.LVRX
	local mY = RAEIH.SavedVars.LVRY
	local mW = RAEIH.SavedVars.LVRIconW + RAEIH_LVR_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.LVRIconH
	local iX = RAEIH.SavedVars.LVRIconX
	local iY = RAEIH.SavedVars.LVRIconY
	local iW = RAEIH.SavedVars.LVRIconW
	local iH = RAEIH.SavedVars.LVRIconH
	local bA = RAEIH.SavedVars.LVRBA
	-- Update General Dimensions
	RAEIH_LVR:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_LVR_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_LVR_Icon:ClearAnchors()
	RAEIH_LVR_Icon:SetSimpleAnchor(RAEIH_LVR, iX, iY)
	-- Update String Anchor
	RAEIH_LVR_String:ClearAnchors()
	RAEIH_LVR_String:SetSimpleAnchor(RAEIH_LVR, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_LVR_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingLVR()
	RAEIH_LVR:StartMoving()
end

function RAEIH.StopMovingLVR()
	RAEIH_LVR:StopMovingOrResizing()
	RAEIH.SavedVars.LVRX = RAEIH_LVR:GetLeft()
	RAEIH.SavedVars.LVRY = RAEIH_LVR:GetTop()
end