local LMP = RAEIH.LMP
local uTag = "player"

--local current, maximum, effectiveMax = GetUnitPower( 'player' , POWERTYPE_WEREWOLF )

function RAEIH.CreateLycanthropy()
	local WM = GetWindowManager()
	if RAEIH_Lycanthropy == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.LycanthropyX
		local mY = RAEIH.SavedVars.LycanthropyY
		local mW = RAEIH.SavedVars.LycanthropyIconW + 10
		local mH = RAEIH.SavedVars.LycanthropyIconH
		local iX = RAEIH.SavedVars.LycanthropyIconX
		local iY = RAEIH.SavedVars.LycanthropyIconY
		local iW = RAEIH.SavedVars.LycanthropyIconW
		local iH = RAEIH.SavedVars.LycanthropyIconH
		local bA = RAEIH.SavedVars.LycanthropyBA
		-- Main Placeholder
		RAEIH_Lycanthropy = WM:CreateTopLevelWindow("RAEIH_Lycanthropy")
		RAEIH_Lycanthropy:SetClampedToScreen(true)
		RAEIH_Lycanthropy:SetDrawLevel(1)
		RAEIH_Lycanthropy:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_Lycanthropy:SetMouseEnabled(true)
		RAEIH_Lycanthropy:SetMovable(not RAEIH.SavedVars.LockLycanthropy)
		RAEIH_Lycanthropy:SetHandler("OnReceiveDrag", RAEIH.StartMovingLycanthropy)
		RAEIH_Lycanthropy:SetHandler("OnMouseUp", RAEIH.StopMovingLycanthropy)
		RAEIH_Lycanthropy:SetHidden(not RAEIH.SavedVars.ShowLycanthropy)
		-- Icon
		RAEIH_Lycanthropy_Icon = WM:CreateControl("RAEIH_Lycanthropy_Icon", RAEIH_Lycanthropy, CT_TEXTURE)
		RAEIH_Lycanthropy_Icon:SetTexture(RAEIH.Icons.Lycanthropy)
		RAEIH_Lycanthropy_Icon:SetDimensions(iW, iH)
		RAEIH_Lycanthropy_Icon:SetSimpleAnchor(RAEIH_Lycanthropy, iX, iY)
		-- String
		RAEIH_Lycanthropy_String = WM:CreateControl("RAEIH_Lycanthropy_String", RAEIH_Lycanthropy, CT_LABEL)
		RAEIH_Lycanthropy_String:SetSimpleAnchor(RAEIH_Lycanthropy, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_Lycanthropy_String:SetHorizontalAlignment(CENTER)
		RAEIH_Lycanthropy_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_Lycanthropy_Backdrop = WM:CreateControl("RAEIH_Lycanthropy_Backdrop", RAEIH_Lycanthropy, CT_BACKDROP)
		RAEIH_Lycanthropy_Backdrop:SetAnchorFill(RAEIH_Lycanthropy)
		RAEIH_Lycanthropy_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_Lycanthropy_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetLycanthropy()

	local clrDft = "|c" .. RAEIH.SavedVars.LycanthropyDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.LycanthropyAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.LycanthropyWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.LycanthropyNormalColour

	local cr, max, eMax = GetUnitPower(uTag, POWERTYPE_WEREWOLF)
	cr = RAEIH.Round(cr/33.33)
	local wwStatus = nil
	if cr >= 20 then
		clr = clrN
		wwStatus = "Werewolf"
	elseif cr < 20 and cr > 10 then
		clr = clrW
		wwStatus = "Werewolf"
	else
		clr = clrA
		wwStatus = "Feed!"
	end

	if cr == 0 then
		if RAEIH.SavedVars.AutoShowLycanthropy == true then
			RAEIH_Lycanthropy:SetHidden(true)
		end	
		RAEIH.LycanthropyText = clrN .. "Normal Form"			
	else
		if RAEIH.SavedVars.AutoShowLycanthropy == true then
			RAEIH_Lycanthropy:SetHidden(false)
		end
		RAEIH.LycanthropyText = clr .. wwStatus .. clrDft .. " » " .. clr .. tostring(cr) .. "s"		
	end

	RAEIH_Lycanthropy_String:SetText(RAEIH.LycanthropyText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatLycanthropy()

	local font = LMP:Fetch('font', RAEIH.SavedVars.LycanthropyFont)
	local size = RAEIH.SavedVars.LycanthropyFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.LycanthropyFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_Lycanthropy_String:SetFont(fontFormat)

end

function RAEIH.OrganizeLycanthropy()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.LycanthropyX
	local mY = RAEIH.SavedVars.LycanthropyY
	local mW = RAEIH.SavedVars.LycanthropyIconW + RAEIH_Lycanthropy_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.LycanthropyIconH
	local iX = RAEIH.SavedVars.LycanthropyIconX
	local iY = RAEIH.SavedVars.LycanthropyIconY
	local iW = RAEIH.SavedVars.LycanthropyIconW
	local iH = RAEIH.SavedVars.LycanthropyIconH
	local bA = RAEIH.SavedVars.LycanthropyBA
	-- Update General Dimensions
	RAEIH_Lycanthropy:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_Lycanthropy_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_Lycanthropy_Icon:ClearAnchors()
	RAEIH_Lycanthropy_Icon:SetSimpleAnchor(RAEIH_Lycanthropy, iX, iY)
	-- Update String Anchor
	RAEIH_Lycanthropy_String:ClearAnchors()
	RAEIH_Lycanthropy_String:SetSimpleAnchor(RAEIH_Lycanthropy, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_Lycanthropy_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingLycanthropy()
	RAEIH_Lycanthropy:StartMoving()
end

function RAEIH.StopMovingLycanthropy()
	RAEIH_Lycanthropy:StopMovingOrResizing()
	RAEIH.SavedVars.LycanthropyX = RAEIH_Lycanthropy:GetLeft()
	RAEIH.SavedVars.LycanthropyY = RAEIH_Lycanthropy:GetTop()
end