local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateFPS()
	local WM = GetWindowManager()
	if RAEIH_FPS == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.FPSX
		local mY = RAEIH.SavedVars.FPSY
		local mW = RAEIH.SavedVars.FPSIconW + 10
		local mH = RAEIH.SavedVars.FPSIconH
		local iX = RAEIH.SavedVars.FPSIconX
		local iY = RAEIH.SavedVars.FPSIconY
		local iW = RAEIH.SavedVars.FPSIconW
		local iH = RAEIH.SavedVars.FPSIconH
		local bA = RAEIH.SavedVars.FPSBA
		-- Main Placeholder
		RAEIH_FPS = WM:CreateTopLevelWindow("RAEIH_FPS")
		RAEIH_FPS:SetClampedToScreen(true)
		RAEIH_FPS:SetDrawLevel(1)
		RAEIH_FPS:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_FPS:SetMouseEnabled(true)
		RAEIH_FPS:SetMovable(not RAEIH.SavedVars.LockFPS)
		RAEIH_FPS:SetHandler("OnReceiveDrag", RAEIH.StartMovingFPS)
		RAEIH_FPS:SetHandler("OnMouseUp", RAEIH.StopMovingFPS)
		RAEIH_FPS:SetHidden(not RAEIH.SavedVars.ShowFPS)
		-- Icon
		RAEIH_FPS_Icon = WM:CreateControl("RAEIH_FPS_Icon", RAEIH_FPS, CT_TEXTURE)
		RAEIH_FPS_Icon:SetTexture(RAEIH.Icons.FPS)
		RAEIH_FPS_Icon:SetDimensions(iW, iH)
		RAEIH_FPS_Icon:SetSimpleAnchor(RAEIH_FPS, iX, iY)
		-- String
		RAEIH_FPS_String = WM:CreateControl("RAEIH_FPS_String", RAEIH_FPS, CT_LABEL)
		RAEIH_FPS_String:SetSimpleAnchor(RAEIH_FPS, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_FPS_String:SetHorizontalAlignment(CENTER)
		RAEIH_FPS_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_FPS_Backdrop = WM:CreateControl("RAEIH_FPS_Backdrop", RAEIH_FPS, CT_BACKDROP)
		RAEIH_FPS_Backdrop:SetAnchorFill(RAEIH_FPS)
		RAEIH_FPS_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_FPS_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetFPS()

	local clrDft = "|c" .. RAEIH.SavedVars.FPSDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.FPSAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.FPSWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.FPSNormalColour

	local fps = RAEIH.Round(GetFramerate())

	if fps >= 40 then
		clr = clrN
	elseif fps >= 30 then
		clr = clrW
	else
		clr = clrA
	end

	if RAEIH.SavedVars.TSFormat == "Point (.)" then
		RAEIH.FPSText = clr .. string.gsub(tostring(fps), "%.", ",")
	else
		RAEIH.FPSText = clr .. tostring(fps)
	end
	RAEIH_FPS_String:SetText(RAEIH.FPSText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatFPS()

	local font = LMP:Fetch('font', RAEIH.SavedVars.FPSFont)
	local size = RAEIH.SavedVars.FPSFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.FPSFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_FPS_String:SetFont(fontFormat)

end

function RAEIH.OrganizeFPS()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.FPSX
	local mY = RAEIH.SavedVars.FPSY
	local mW = RAEIH.SavedVars.FPSIconW + RAEIH_FPS_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.FPSIconH
	local iX = RAEIH.SavedVars.FPSIconX
	local iY = RAEIH.SavedVars.FPSIconY
	local iW = RAEIH.SavedVars.FPSIconW
	local iH = RAEIH.SavedVars.FPSIconH
	local bA = RAEIH.SavedVars.FPSBA
	-- Update General Dimensions
	RAEIH_FPS:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_FPS_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_FPS_Icon:ClearAnchors()
	RAEIH_FPS_Icon:SetSimpleAnchor(RAEIH_FPS, iX, iY)
	-- Update String Anchor
	RAEIH_FPS_String:ClearAnchors()
	RAEIH_FPS_String:SetSimpleAnchor(RAEIH_FPS, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_FPS_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingFPS()
	RAEIH_FPS:StartMoving()
end

function RAEIH.StopMovingFPS()
	RAEIH_FPS:StopMovingOrResizing()
	RAEIH.SavedVars.FPSX = RAEIH_FPS:GetLeft()
	RAEIH.SavedVars.FPSY = RAEIH_FPS:GetTop()
end