local LMP = RAEIH.LMP
local uTag = "player"
local startingGameTime = 0
local startingXP = 0
local startingVP = 0
local startingCXP = 0
local gainedXP = 0
local gainedVP = 0
local gainedCXP = 0

function RAEIH.CreateXVPperHour()
	local WM = GetWindowManager()
	if RAEIH_XVPperHour == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.XVPperHourX
		local mY = RAEIH.SavedVars.XVPperHourY
		local mW = RAEIH.SavedVars.XVPperHourIconW + 10
		local mH = RAEIH.SavedVars.XVPperHourIconH
		local iX = RAEIH.SavedVars.XVPperHourIconX
		local iY = RAEIH.SavedVars.XVPperHourIconY
		local iW = RAEIH.SavedVars.XVPperHourIconW
		local iH = RAEIH.SavedVars.XVPperHourIconH
		local bA = RAEIH.SavedVars.XVPperHourBA
		-- Main Placeholder
		RAEIH_XVPperHour = WM:CreateTopLevelWindow("RAEIH_XVPperHour")
		RAEIH_XVPperHour:SetClampedToScreen(true)
		RAEIH_XVPperHour:SetDrawLevel(1)
		RAEIH_XVPperHour:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_XVPperHour:SetMouseEnabled(true)
		RAEIH_XVPperHour:SetMovable(not RAEIH.SavedVars.LockXVPperHour)
		RAEIH_XVPperHour:SetHandler("OnReceiveDrag", RAEIH.StartMovingXVPperHour)
		RAEIH_XVPperHour:SetHandler("OnMouseUp", RAEIH.StopMovingXVPperHour)
		RAEIH_XVPperHour:SetHidden(not RAEIH.SavedVars.ShowXVPperHour)
		-- Icon
		RAEIH_XVPperHour_Icon = WM:CreateControl("RAEIH_XVPperHour_Icon", RAEIH_XVPperHour, CT_TEXTURE)
		RAEIH_XVPperHour_Icon:SetTexture(RAEIH.Icons.XVPperHour)
		RAEIH_XVPperHour_Icon:SetDimensions(iW, iH)
		RAEIH_XVPperHour_Icon:SetSimpleAnchor(RAEIH_XVPperHour, iX, iY)
		-- String
		RAEIH_XVPperHour_String = WM:CreateControl("RAEIH_XVPperHour_String", RAEIH_XVPperHour, CT_LABEL)
		RAEIH_XVPperHour_String:SetSimpleAnchor(RAEIH_XVPperHour, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_XVPperHour_String:SetHorizontalAlignment(CENTER)
		RAEIH_XVPperHour_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_XVPperHour_Backdrop = WM:CreateControl("RAEIH_XVPperHour_Backdrop", RAEIH_XVPperHour, CT_BACKDROP)
		RAEIH_XVPperHour_Backdrop:SetAnchorFill(RAEIH_XVPperHour)
		RAEIH_XVPperHour_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_XVPperHour_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end

	startingGameTime = GetGameTimeMilliseconds()
	startingXP = GetUnitXP(uTag)
	startingVP = GetUnitVeteranPoints(uTag)
	startingCXP = GetPlayerChampionXP()

	RAEIH.isVeteran = RAEIH.isVeteran or IsUnitVeteran(uTag)
	RAEIH.hasMaxVR = RAEIH.hasMaxVR or (GetUnitVeteranRank(uTag) == 16)
end

function RAEIH.SetXVPperHour()

	local clrDft = "|c" .. RAEIH.SavedVars.XVPperHourDefaultColour
	local clrXVPperHour = "|c" .. RAEIH.SavedVars.XVPperHourColour

	local elapsedTime = GetGameTimeMilliseconds() - startingGameTime

	RAEIH.isVeteran = RAEIH.isVeteran or IsUnitVeteran(uTag)

	if RAEIH.isVeteran then
		RAEIH.hasMaxVR = RAEIH.hasMaxVR or (GetUnitVeteranRank(uTag) == 16)
	end

	if not RAEIH.hasMaxVR then
		if RAEIH.isVeteran then
			local currentVP = GetUnitVeteranPoints(uTag)
			local earnedVP = currentVP - startingVP

			if earnedVP > 0 then
				gainedVP = gainedVP + earnedVP
			end

			local vpPerHour = RAEIH.Round(gainedVP / (elapsedTime / 3600000), 2)
			startingVP = currentVP

			if RAEIH.SavedVars.TSFormat == "Point (.)" then
				vpPerHour = string.gsub(string.format("%04.02f", vpPerHour), "%.", ",")
			else
				vpPerHour = string.format("%04.02f", vpPerHour)
			end

			RAEIH.XVPperHourText = clrXVPperHour .. vpPerHour .. clrDft .. " VP/h"
		else
			local currentXP = GetUnitXP(uTag)
			local earnedXP = currentXP - startingXP

			if earnedXP > 0 then
				gainedXP = gainedXP + earnedXP
			end

			local xpPerHour = RAEIH.Round(gainedXP / (elapsedTime / 3600000), 2)
			startingXP = currentXP

			if RAEIH.SavedVars.TSFormat == "Point (.)" then
				xpPerHour = string.gsub(string.format("%04.02f", xpPerHour), "%.", ",")
			else
				xpPerHour = string.format("%04.02f", xpPerHour)
			end

			RAEIH.XVPperHourText = clrXVPperHour .. xpPerHour .. clrDft .. " XP/h"
		end
	else
		local currentCXP = GetPlayerChampionXP()
		local earnedCXP = currentCXP - startingCXP

		if earnedCXP > 0 then
			gainedCXP = gainedCXP + earnedCXP
		end

		local cxpPerHour = RAEIH.Round(gainedCXP / (elapsedTime / 3600000))
		startingCXP = currentCXP

		if RAEIH.SavedVars.TSFormat == "Point (.)" then
			cxpPerHour = string.gsub(tostring(cxpPerHour), "%.", ",")
		else
			cxpPerHour = tostring(cxpPerHour)
		end

		RAEIH.XVPperHourText = clrXVPperHour .. cxpPerHour .. clrDft .. " CXP/h"
	end

	RAEIH_XVPperHour_String:SetText(RAEIH.XVPperHourText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatXVPperHour()

	local font = LMP:Fetch('font', RAEIH.SavedVars.XVPperHourFont)
	local size = RAEIH.SavedVars.XVPperHourFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.XVPperHourFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_XVPperHour_String:SetFont(fontFormat)

end

function RAEIH.OrganizeXVPperHour()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.XVPperHourX
	local mY = RAEIH.SavedVars.XVPperHourY
	local mW = RAEIH.SavedVars.XVPperHourIconW + RAEIH_XVPperHour_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.XVPperHourIconH
	local iX = RAEIH.SavedVars.XVPperHourIconX
	local iY = RAEIH.SavedVars.XVPperHourIconY
	local iW = RAEIH.SavedVars.XVPperHourIconW
	local iH = RAEIH.SavedVars.XVPperHourIconH
	local bA = RAEIH.SavedVars.XVPperHourBA
	-- Update General Dimensions
	RAEIH_XVPperHour:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_XVPperHour_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_XVPperHour_Icon:ClearAnchors()
	RAEIH_XVPperHour_Icon:SetSimpleAnchor(RAEIH_XVPperHour, iX, iY)
	-- Update String Anchor
	RAEIH_XVPperHour_String:ClearAnchors()
	RAEIH_XVPperHour_String:SetSimpleAnchor(RAEIH_XVPperHour, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_XVPperHour_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingXVPperHour()
	RAEIH_XVPperHour:StartMoving()
end

function RAEIH.StopMovingXVPperHour()
	RAEIH_XVPperHour:StopMovingOrResizing()
	RAEIH.SavedVars.XVPperHourX = RAEIH_XVPperHour:GetLeft()
	RAEIH.SavedVars.XVPperHourY = RAEIH_XVPperHour:GetTop()
end