local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateRiding()
	local WM = GetWindowManager()
	if RAEIH_Riding == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.RidingX
		local mY = RAEIH.SavedVars.RidingY
		local mW = RAEIH.SavedVars.RidingIconW + 10
		local mH = RAEIH.SavedVars.RidingIconH
		local iX = RAEIH.SavedVars.RidingIconX
		local iY = RAEIH.SavedVars.RidingIconY
		local iW = RAEIH.SavedVars.RidingIconW
		local iH = RAEIH.SavedVars.RidingIconH
		local bA = RAEIH.SavedVars.RidingBA
		-- Main Placeholder
		RAEIH_Riding = WM:CreateTopLevelWindow("RAEIH_Riding")
		RAEIH_Riding:SetClampedToScreen(true)
		RAEIH_Riding:SetDrawLevel(1)
		RAEIH_Riding:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_Riding:SetMouseEnabled(true)
		RAEIH_Riding:SetMovable(not RAEIH.SavedVars.LockRiding)
		RAEIH_Riding:SetHandler("OnReceiveDrag", RAEIH.StartMovingRiding)
		RAEIH_Riding:SetHandler("OnMouseUp", RAEIH.StopMovingRiding)
		RAEIH_Riding:SetHidden(not RAEIH.SavedVars.ShowRiding)
		-- Icon
		RAEIH_Riding_Icon = WM:CreateControl("RAEIH_Riding_Icon", RAEIH_Riding, CT_TEXTURE)
		RAEIH_Riding_Icon:SetTexture(RAEIH.Icons.Riding)
		RAEIH_Riding_Icon:SetDimensions(iW, iH)
		RAEIH_Riding_Icon:SetSimpleAnchor(RAEIH_Riding, iX, iY)
		-- String
		RAEIH_Riding_String = WM:CreateControl("RAEIH_Riding_String", RAEIH_Riding, CT_LABEL)
		RAEIH_Riding_String:SetSimpleAnchor(RAEIH_Riding, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_Riding_String:SetHorizontalAlignment(CENTER)
		RAEIH_Riding_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_Riding_Backdrop = WM:CreateControl("RAEIH_Riding_Backdrop", RAEIH_Riding, CT_BACKDROP)
		RAEIH_Riding_Backdrop:SetAnchorFill(RAEIH_Riding)
		RAEIH_Riding_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_Riding_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetRiding()

	local clrDft = "|c" .. RAEIH.SavedVars.RidingDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.RidingAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.RidingWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.RidingNormalColour
	local clr = clrDft

	local hmTime = GetTimeUntilCanBeTrained() / (60 * 60 * 1000)
	local inv, maxInv, sta, maxSta, spd, maxSpd = GetRidingStats()

	if hmTime == 0 and inv == maxInv and sta == maxSta and spd == maxSpd then
		RAEIH.RidingText = clrN .. "Maxed"
	elseif hmTime == 0 then
		RAEIH.RidingText = clrA .. "Train!"
	elseif hmTime <= 1 then
		RAEIH.RidingText = clrA .. "<1h"
	elseif hmTime > 1 and hmTime <= 5 then
		RAEIH.RidingText = clrW .. string.gsub(string.format("\%.0f", hmTime), "%.", ",") .. "h"
	elseif hmTime > 5 and hmTime < 21 then
		RAEIH.RidingText = clrN .. string.gsub(string.format("\%.0f", hmTime), "%.", ",") .. "h"
	else
		RAEIH.RidingText = clrA .. "Error, please report!"
	end
	RAEIH_Riding_String:SetText(RAEIH.RidingText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatRiding()

	local font = LMP:Fetch('font', RAEIH.SavedVars.RidingFont)
	local size = RAEIH.SavedVars.RidingFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.RidingFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_Riding_String:SetFont(fontFormat)

end

function RAEIH.OrganizeRiding()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.RidingX
	local mY = RAEIH.SavedVars.RidingY
	local mW = RAEIH.SavedVars.RidingIconW + RAEIH_Riding_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.RidingIconH
	local iX = RAEIH.SavedVars.RidingIconX
	local iY = RAEIH.SavedVars.RidingIconY
	local iW = RAEIH.SavedVars.RidingIconW
	local iH = RAEIH.SavedVars.RidingIconH
	local bA = RAEIH.SavedVars.RidingBA
	-- Update General Dimensions
	RAEIH_Riding:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_Riding_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_Riding_Icon:ClearAnchors()
	RAEIH_Riding_Icon:SetSimpleAnchor(RAEIH_Riding, iX, iY)
	-- Update String Anchor
	RAEIH_Riding_String:ClearAnchors()
	RAEIH_Riding_String:SetSimpleAnchor(RAEIH_Riding, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_Riding_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingRiding()
	RAEIH_Riding:StartMoving()
end

function RAEIH.StopMovingRiding()
	RAEIH_Riding:StopMovingOrResizing()
	RAEIH.SavedVars.RidingX = RAEIH_Riding:GetLeft()
	RAEIH.SavedVars.RidingY = RAEIH_Riding:GetTop()
end

function RAEIH.SWWM_Refresh()
	local getSetting = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM)
	SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, 1 - getSetting)
	SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, getSetting)
end