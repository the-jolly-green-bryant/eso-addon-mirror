local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateTimePlayed()
	local WM = GetWindowManager()
	if RAEIH_TimePlayed == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.TimePlayedX
		local mY = RAEIH.SavedVars.TimePlayedY
		local mW = RAEIH.SavedVars.TimePlayedIconW + 10
		local mH = RAEIH.SavedVars.TimePlayedIconH
		local iX = RAEIH.SavedVars.TimePlayedIconX
		local iY = RAEIH.SavedVars.TimePlayedIconY
		local iW = RAEIH.SavedVars.TimePlayedIconW
		local iH = RAEIH.SavedVars.TimePlayedIconH
		local bA = RAEIH.SavedVars.TimePlayedBA
		-- Main Placeholder
		RAEIH_TimePlayed = WM:CreateTopLevelWindow("RAEIH_TimePlayed")
		RAEIH_TimePlayed:SetClampedToScreen(true)
		RAEIH_TimePlayed:SetDrawLevel(1)
		RAEIH_TimePlayed:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_TimePlayed:SetMouseEnabled(true)
		RAEIH_TimePlayed:SetMovable(not RAEIH.SavedVars.LockTimePlayed)
		RAEIH_TimePlayed:SetHandler("OnReceiveDrag", RAEIH.StartMovingTimePlayed)
		RAEIH_TimePlayed:SetHandler("OnMouseUp", RAEIH.StopMovingTimePlayed)
		RAEIH_TimePlayed:SetHidden(not RAEIH.SavedVars.ShowTimePlayed)
		-- Icon
		RAEIH_TimePlayed_Icon = WM:CreateControl("RAEIH_TimePlayed_Icon", RAEIH_TimePlayed, CT_TEXTURE)
		RAEIH_TimePlayed_Icon:SetTexture(RAEIH.Icons.TimePlayed)
		RAEIH_TimePlayed_Icon:SetDimensions(iW, iH)
		RAEIH_TimePlayed_Icon:SetSimpleAnchor(RAEIH_TimePlayed, iX, iY)
		-- String
		RAEIH_TimePlayed_String = WM:CreateControl("RAEIH_TimePlayed_String", RAEIH_TimePlayed, CT_LABEL)
		RAEIH_TimePlayed_String:SetSimpleAnchor(RAEIH_TimePlayed, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_TimePlayed_String:SetHorizontalAlignment(CENTER)
		RAEIH_TimePlayed_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_TimePlayed_Backdrop = WM:CreateControl("RAEIH_TimePlayed_Backdrop", RAEIH_TimePlayed, CT_BACKDROP)
		RAEIH_TimePlayed_Backdrop:SetAnchorFill(RAEIH_TimePlayed)
		RAEIH_TimePlayed_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_TimePlayed_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetTimePlayed()

	local clrDft = "|c" .. RAEIH.SavedVars.TimePlayedDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.TimePlayedAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.TimePlayedWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.TimePlayedNormalColour
	local clr = clrDft

	local isHour = false
	local timePlayed = RAEIH.Round(GetGameTimeMilliseconds() / 60000)
	if timePlayed >= 60 then 
		timePlayed = RAEIH.Round(timePlayed / 60)
		isHour = true
	end

	local totalTimePlayed = RAEIH.Round(GetSecondsPlayed() / 3600)

	if RAEIH.SavedVars.TSFormat == "Point (.)" then
		timePlayed = RAEIH.ThousandsSeparatorPoint(timePlayed)
		totalTimePlayed = RAEIH.ThousandsSeparatorPoint(totalTimePlayed)
	else
		timePlayed = RAEIH.ThousandsSeparatorComma(timePlayed)
		totalTimePlayed = RAEIH.ThousandsSeparatorComma(totalTimePlayed)
	end

	if isHour then 
		timePlayed = timePlayed .. "h"
	else
		timePlayed = timePlayed .. "m"
	end

	totalTimePlayed = totalTimePlayed .. "h"

	-- if cAlliance == 3 then
	-- 	cAlliance = "Daggerfall Covenant"
	-- elseif cAlliance == 2 then
	-- 	cAlliance = "Ebonheart Pack"
	-- elseif cAlliance == 1 then
	-- 	cAlliance = "Aldmeri Dominion"
	-- else
	-- 	cAlliance = "No Allegiance"
	-- end

	RAEIH.TimePlayedText = clrN .. totalTimePlayed .. clrDft .. " (" .. clrN .. timePlayed .. clrDft .. ")"
	RAEIH_TimePlayed_String:SetText(RAEIH.TimePlayedText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatTimePlayed()

	local font = LMP:Fetch('font', RAEIH.SavedVars.TimePlayedFont)
	local size = RAEIH.SavedVars.TimePlayedFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.TimePlayedFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_TimePlayed_String:SetFont(fontFormat)

end

function RAEIH.OrganizeTimePlayed()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.TimePlayedX
	local mY = RAEIH.SavedVars.TimePlayedY
	local mW = RAEIH.SavedVars.TimePlayedIconW + RAEIH_TimePlayed_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.TimePlayedIconH
	local iX = RAEIH.SavedVars.TimePlayedIconX
	local iY = RAEIH.SavedVars.TimePlayedIconY
	local iW = RAEIH.SavedVars.TimePlayedIconW
	local iH = RAEIH.SavedVars.TimePlayedIconH
	local bA = RAEIH.SavedVars.TimePlayedBA
	-- Update General Dimensions
	RAEIH_TimePlayed:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_TimePlayed_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_TimePlayed_Icon:ClearAnchors()
	RAEIH_TimePlayed_Icon:SetSimpleAnchor(RAEIH_TimePlayed, iX, iY)
	-- Update String Anchor
	RAEIH_TimePlayed_String:ClearAnchors()
	RAEIH_TimePlayed_String:SetSimpleAnchor(RAEIH_TimePlayed, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_TimePlayed_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingTimePlayed()
	RAEIH_TimePlayed:StartMoving()
end

function RAEIH.StopMovingTimePlayed()
	RAEIH_TimePlayed:StopMovingOrResizing()
	RAEIH.SavedVars.TimePlayedX = RAEIH_TimePlayed:GetLeft()
	RAEIH.SavedVars.TimePlayedY = RAEIH_TimePlayed:GetTop()
end