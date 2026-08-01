local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateXVP()
	local WM = GetWindowManager()
	if RAEIH_XVP == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.XVPX
		local mY = RAEIH.SavedVars.XVPY
		local mW = RAEIH.SavedVars.XVPIconW + 10
		local mH = RAEIH.SavedVars.XVPIconH
		local iX = RAEIH.SavedVars.XVPIconX
		local iY = RAEIH.SavedVars.XVPIconY
		local iW = RAEIH.SavedVars.XVPIconW
		local iH = RAEIH.SavedVars.XVPIconH
		local bA = RAEIH.SavedVars.XVPBA
		-- Main Placeholder
		RAEIH_XVP = WM:CreateTopLevelWindow("RAEIH_XVP")
		RAEIH_XVP:SetClampedToScreen(true)
		RAEIH_XVP:SetDrawLevel(1)
		RAEIH_XVP:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_XVP:SetMouseEnabled(true)
		RAEIH_XVP:SetMovable(not RAEIH.SavedVars.LockXVP)
		RAEIH_XVP:SetHandler("OnReceiveDrag", RAEIH.StartMovingXVP)
		RAEIH_XVP:SetHandler("OnMouseUp", RAEIH.StopMovingXVP)
		RAEIH_XVP:SetHidden(not RAEIH.SavedVars.ShowXVP)
		-- Icon
		RAEIH_XVP_Icon = WM:CreateControl("RAEIH_XVP_Icon", RAEIH_XVP, CT_TEXTURE)
		RAEIH_XVP_Icon:SetTexture(RAEIH.Icons.XVP)
		RAEIH_XVP_Icon:SetDimensions(iW, iH)
		RAEIH_XVP_Icon:SetSimpleAnchor(RAEIH_XVP, iX, iY)
		-- String
		RAEIH_XVP_String = WM:CreateControl("RAEIH_XVP_String", RAEIH_XVP, CT_LABEL)
		RAEIH_XVP_String:SetSimpleAnchor(RAEIH_XVP, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_XVP_String:SetHorizontalAlignment(CENTER)
		RAEIH_XVP_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_XVP_Backdrop = WM:CreateControl("RAEIH_XVP_Backdrop", RAEIH_XVP, CT_BACKDROP)
		RAEIH_XVP_Backdrop:SetAnchorFill(RAEIH_XVP)
		RAEIH_XVP_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_XVP_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end

	RAEIH.isChampion = RAEIH.isChampion or IsUnitChampion(uTag)
end

function RAEIH.SetXVP()

	local clrDft = "|c" .. RAEIH.SavedVars.XVPDefaultColour
	local clrES = "|c" .. RAEIH.SavedVars.XVPESColour
	local clrMS = "|c" .. RAEIH.SavedVars.XVPMSColour
	local clrLS = "|c" .. RAEIH.SavedVars.XVPLSColour

	local xp = 0
	local xpMax = 1

	RAEIH.isChampion = RAEIH.isChampion or IsUnitChampion(uTag)

	if RAEIH.isChampion then
		xp = GetUnitChampionPoints(uTag)
		xpMax = 501		
	else
		xp = GetUnitXP(uTag)
		xpMax = GetUnitXPMax(uTag)
	end
	
	-- Adding this back in.  Should be fine now. 6/8/16
	local xpPerc = RAEIH.Round(xp / xpMax * 100)

	local clr = clrDft
	if xpPerc > 75 then
		clr = clrLS
	elseif xpPerc <= 75 and xpPerc >= 25 then
		clr = clrMS
	else
		clr = clrES
	end
	
	if RAEIH.SavedVars.TSFormat == "Point (.)" then
	xp = RAEIH.ThousandsSeparatorPoint(xp)
	xpMax = RAEIH.ThousandsSeparatorPoint(xpMax)
	xpPerc = string.gsub(tostring(xpPerc), "%.", ",") .. "%"
	else
		xp = RAEIH.ThousandsSeparatorComma(xp)
		xpMax = RAEIH.ThousandsSeparatorComma(xpMax)
		xpPerc = tostring(xpPerc) .. "%"
	end
	
	if RAEIH.SavedVars.XVPFormat == "Current/Max (%)" then
		RAEIH.XVPText = clr .. xp .. clrDft .. "/" .. xpMax .. " (" .. clr .. xpPerc .. clrDft .. ")"
	elseif RAEIH.SavedVars.XVPFormat == "Current/Max" then
		RAEIH.XVPText = clr .. xp .. clrDft .. "/" .. xpMax
	else
		RAEIH.XVPText = clr .. xpPerc
	end

	RAEIH_XVP_String:SetText(RAEIH.XVPText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatXVP()

	local font = LMP:Fetch('font', RAEIH.SavedVars.XVPFont)
	local size = RAEIH.SavedVars.XVPFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.XVPFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_XVP_String:SetFont(fontFormat)

end

function RAEIH.OrganizeXVP()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.XVPX
	local mY = RAEIH.SavedVars.XVPY
	local mW = RAEIH.SavedVars.XVPIconW + RAEIH_XVP_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.XVPIconH
	local iX = RAEIH.SavedVars.XVPIconX
	local iY = RAEIH.SavedVars.XVPIconY
	local iW = RAEIH.SavedVars.XVPIconW
	local iH = RAEIH.SavedVars.XVPIconH
	local bA = RAEIH.SavedVars.XVPBA
	-- Update General Dimensions
	RAEIH_XVP:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_XVP_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_XVP_Icon:ClearAnchors()
	RAEIH_XVP_Icon:SetSimpleAnchor(RAEIH_XVP, iX, iY)
	-- Update String Anchor
	RAEIH_XVP_String:ClearAnchors()
	RAEIH_XVP_String:SetSimpleAnchor(RAEIH_XVP, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_XVP_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingXVP()
	RAEIH_XVP:StartMoving()
end

function RAEIH.StopMovingXVP()
	RAEIH_XVP:StopMovingOrResizing()
	RAEIH.SavedVars.XVPX = RAEIH_XVP:GetLeft()
	RAEIH.SavedVars.XVPY = RAEIH_XVP:GetTop()
end