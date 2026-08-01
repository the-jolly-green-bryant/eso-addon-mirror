local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.SCCByCombat()
	local inCombat = IsUnitInCombat(uTag)
	if inCombat == true then
		ZO_CompassFrameLeft:SetColor(RAEIH.HexToRGB(RAEIH.SavedVars.CombatStateAlertColour))
 	 	ZO_CompassFrameCenter:SetColor(RAEIH.HexToRGB(RAEIH.SavedVars.CombatStateAlertColour))
  		ZO_CompassFrameRight:SetColor(RAEIH.HexToRGB(RAEIH.SavedVars.CombatStateAlertColour))
	else
		ZO_CompassFrameLeft:SetColor(1,1,1)
 	 	ZO_CompassFrameCenter:SetColor(1,1,1)
  		ZO_CompassFrameRight:SetColor(1,1,1)
	end
end

function RAEIH.CreateCombatState()
	local WM = GetWindowManager()
	if RAEIH_CombatState == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.CombatStateX
		local mY = RAEIH.SavedVars.CombatStateY
		local mW = RAEIH.SavedVars.CombatStateIconW + 10
		local mH = RAEIH.SavedVars.CombatStateIconH
		local iX = RAEIH.SavedVars.CombatStateIconX
		local iY = RAEIH.SavedVars.CombatStateIconY
		local iW = RAEIH.SavedVars.CombatStateIconW
		local iH = RAEIH.SavedVars.CombatStateIconH
		local bA = RAEIH.SavedVars.CombatStateBA
		-- Main Placeholder
		RAEIH_CombatState = WM:CreateTopLevelWindow("RAEIH_CombatState")
		RAEIH_CombatState:SetClampedToScreen(true)
		RAEIH_CombatState:SetDrawLevel(1)
		RAEIH_CombatState:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_CombatState:SetMouseEnabled(true)
		RAEIH_CombatState:SetMovable(not RAEIH.SavedVars.LockCombatState)
		RAEIH_CombatState:SetHandler("OnReceiveDrag", RAEIH.StartMovingCombatState)
		RAEIH_CombatState:SetHandler("OnMouseUp", RAEIH.StopMovingCombatState)
		RAEIH_CombatState:SetHidden(not RAEIH.SavedVars.ShowCombatState)
		-- Icon
		RAEIH_CombatState_Icon = WM:CreateControl("RAEIH_CombatState_Icon", RAEIH_CombatState, CT_TEXTURE)
		RAEIH_CombatState_Icon:SetTexture(RAEIH.Icons.CombatState)
		RAEIH_CombatState_Icon:SetDimensions(iW, iH)
		RAEIH_CombatState_Icon:SetSimpleAnchor(RAEIH_CombatState, iX, iY)
		-- String
		RAEIH_CombatState_String = WM:CreateControl("RAEIH_CombatState_String", RAEIH_CombatState, CT_LABEL)
		RAEIH_CombatState_String:SetSimpleAnchor(RAEIH_CombatState, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_CombatState_String:SetHorizontalAlignment(CENTER)
		RAEIH_CombatState_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_CombatState_Backdrop = WM:CreateControl("RAEIH_CombatState_Backdrop", RAEIH_CombatState, CT_BACKDROP)
		RAEIH_CombatState_Backdrop:SetAnchorFill(RAEIH_CombatState)
		RAEIH_CombatState_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_CombatState_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetCombatState()

	local clrA = "|c" .. RAEIH.SavedVars.CombatStateAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.CombatStateWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.CombatStateNormalColour

	local inCombat = IsUnitInCombat(uTag)

	if inCombat == true then
		RAEIH.CombatStateText = clrA .. "In Combat!"
	else
		RAEIH.CombatStateText = clrN .. "Out of Combat"
	end
	RAEIH_CombatState_String:SetText(RAEIH.CombatStateText)
	RAEIH.OrganizeLegatus()

end

function RAEIH.FormatCombatState()

	local font = LMP:Fetch('font', RAEIH.SavedVars.CombatStateFont)
	local size = RAEIH.SavedVars.CombatStateFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.CombatStateFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_CombatState_String:SetFont(fontFormat)

end

function RAEIH.OrganizeCombatState()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.CombatStateX
	local mY = RAEIH.SavedVars.CombatStateY
	local mW = RAEIH.SavedVars.CombatStateIconW + RAEIH_CombatState_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.CombatStateIconH
	local iX = RAEIH.SavedVars.CombatStateIconX
	local iY = RAEIH.SavedVars.CombatStateIconY
	local iW = RAEIH.SavedVars.CombatStateIconW
	local iH = RAEIH.SavedVars.CombatStateIconH
	local bA = RAEIH.SavedVars.CombatStateBA
	-- Update General Dimensions
	RAEIH_CombatState:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_CombatState_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_CombatState_Icon:ClearAnchors()
	RAEIH_CombatState_Icon:SetSimpleAnchor(RAEIH_CombatState, iX, iY)
	-- Update String Anchor
	RAEIH_CombatState_String:ClearAnchors()
	RAEIH_CombatState_String:SetSimpleAnchor(RAEIH_CombatState, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_CombatState_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingCombatState()
	RAEIH_CombatState:StartMoving()
end

function RAEIH.StopMovingCombatState()
	RAEIH_CombatState:StopMovingOrResizing()
	RAEIH.SavedVars.CombatStateX = RAEIH_CombatState:GetLeft()
	RAEIH.SavedVars.CombatStateY = RAEIH_CombatState:GetTop()
end