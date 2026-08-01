local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateBlacksmithing()
	local WM = GetWindowManager()
	if RAEIH_Blacksmithing == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.BlacksmithingX
		local mY = RAEIH.SavedVars.BlacksmithingY
		local mW = RAEIH.SavedVars.BlacksmithingIconW + 10
		local mH = RAEIH.SavedVars.BlacksmithingIconH
		local iX = RAEIH.SavedVars.BlacksmithingIconX
		local iY = RAEIH.SavedVars.BlacksmithingIconY
		local iW = RAEIH.SavedVars.BlacksmithingIconW
		local iH = RAEIH.SavedVars.BlacksmithingIconH
		local bA = RAEIH.SavedVars.BlacksmithingBA
		-- Main Placeholder
		RAEIH_Blacksmithing = WM:CreateTopLevelWindow("RAEIH_Blacksmithing")
		RAEIH_Blacksmithing:SetClampedToScreen(true)
		RAEIH_Blacksmithing:SetDrawLevel(1)
		RAEIH_Blacksmithing:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_Blacksmithing:SetMouseEnabled(true)
		RAEIH_Blacksmithing:SetMovable(not RAEIH.SavedVars.LockBlacksmithing)
		RAEIH_Blacksmithing:SetHandler("OnReceiveDrag", RAEIH.StartMovingBlacksmithing)
		RAEIH_Blacksmithing:SetHandler("OnMouseUp", RAEIH.StopMovingBlacksmithing)
		RAEIH_Blacksmithing:SetHidden(not RAEIH.SavedVars.ShowBlacksmithing)
		-- Icon
		RAEIH_Blacksmithing_Icon = WM:CreateControl("RAEIH_Blacksmithing_Icon", RAEIH_Blacksmithing, CT_TEXTURE)
		RAEIH_Blacksmithing_Icon:SetTexture(RAEIH.Icons.Blacksmithing)
		RAEIH_Blacksmithing_Icon:SetDimensions(iW, iH)
		RAEIH_Blacksmithing_Icon:SetSimpleAnchor(RAEIH_Blacksmithing, iX, iY)
		-- String
		RAEIH_Blacksmithing_String = WM:CreateControl("RAEIH_Blacksmithing_String", RAEIH_Blacksmithing, CT_LABEL)
		RAEIH_Blacksmithing_String:SetSimpleAnchor(RAEIH_Blacksmithing, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_Blacksmithing_String:SetHorizontalAlignment(CENTER)
		RAEIH_Blacksmithing_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_Blacksmithing_Backdrop = WM:CreateControl("RAEIH_Blacksmithing_Backdrop", RAEIH_Blacksmithing, CT_BACKDROP)
		RAEIH_Blacksmithing_Backdrop:SetAnchorFill(RAEIH_Blacksmithing)
		RAEIH_Blacksmithing_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_Blacksmithing_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetBlacksmithing()

	local clrDft = "|c" .. RAEIH.SavedVars.BlacksmithingDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.BlacksmithingAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.BlacksmithingWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.BlacksmithingNormalColour

	local clrT = clrDft

	local BS = CRAFTING_TYPE_BLACKSMITHING

	local nRLines = GetNumSmithingResearchLines(BS) -- 14
	local maxRS = GetMaxSimultaneousSmithingResearch(BS) -- 3
	local sInUse = 0
	local lRTime = 99999999

	for i = 1, nRLines do
		local iName, iTX, iTRNum, iNextRTime = GetSmithingResearchLineInfo(BS, i) -- One of 14
		for k = 1, iTRNum do
			local rTTime, rRTime = GetSmithingResearchLineTraitTimes(BS, i, k)
			if rTTime ~= nil and rRTime ~= nil then
				sInUse = sInUse + 1
				if rRTime < lRTime then
					lRTime = rRTime
				end
			end
		end
	end

	local rStatus = "Gathering Information..."
	local tStatus = "Calculating..."

	lRTimeD = RAEIH.Round(lRTime / (60 * 60 * 24))
	lRTimeH = RAEIH.Round(lRTime / (60 *60))
	lRTimeM = RAEIH.Round(lRTime / 60)
	lRTimeS = RAEIH.Round(lRTime)

	if sInUse ~= maxRS and sInUse ~= 0 then
		rStatus = clrW .. "BS" .. clrDft .. " (" .. clrW .. sInUse .. clrDft .. "/" .. clrA .. maxRS .. clrDft .. ")"
	elseif sInUse ~= maxRS and sInUse == 0 then
		rStatus = clrA .. "BS" .. clrDft .. " (" .. clrA .. sInUse .. clrDft .. "/" .. clrA .. maxRS .. clrDft .. ")"
	elseif sInUse == maxRS then
		rStatus = clrN .. "BS" .. clrDft .. " (" .. clrN .. sInUse .. clrDft .. "/" .. clrN .. maxRS .. clrDft .. ")"
	else
		rStatus = clrA .. "Error! Please report"
	end

	if lRTimeD > 1 and sInUse ~= 0 then
		tStatus = clrDft .. " - " .. clrN .. lRTimeD .. "d"
	elseif lRTimeD <= 1 and lRTimeH >= 24 then
		tStatus = clrDft .. " - " .. clrW .. lRTimeD .. "d"
	elseif lRTimeH <= 24 and lRTimeH > 1 then
		tStatus = clrDft .. " - " .. clrW .. lRTimeH .. "h"
	elseif lRTimeM < 60 and lRTimeM ~= 0 then
		tStatus = clrDft .. " - " .. clrA .. lRTimeM .. "m"
	elseif lRTimeM < 1 and lRTimeS > 0 then
		tStatus = clrDft .. " - " .. clrA .. lRTimeS .. "s" .. clrDft .. " (" .. clrA .. "Almost Done!" .. clrDft .. ")"
	else
		tStatus = ""
	end
	RAEIH.BlacksmithingText = rStatus .. tStatus
	RAEIH_Blacksmithing_String:SetText(RAEIH.BlacksmithingText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatBlacksmithing()

	local font = LMP:Fetch('font', RAEIH.SavedVars.BlacksmithingFont)
	local size = RAEIH.SavedVars.BlacksmithingFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.BlacksmithingFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_Blacksmithing_String:SetFont(fontFormat)

end

function RAEIH.OrganizeBlacksmithing()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.BlacksmithingX
	local mY = RAEIH.SavedVars.BlacksmithingY
	local mW = RAEIH.SavedVars.BlacksmithingIconW + RAEIH_Blacksmithing_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.BlacksmithingIconH
	local iX = RAEIH.SavedVars.BlacksmithingIconX
	local iY = RAEIH.SavedVars.BlacksmithingIconY
	local iW = RAEIH.SavedVars.BlacksmithingIconW
	local iH = RAEIH.SavedVars.BlacksmithingIconH
	local bA = RAEIH.SavedVars.BlacksmithingBA
	-- Update General Dimensions
	RAEIH_Blacksmithing:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_Blacksmithing_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_Blacksmithing_Icon:ClearAnchors()
	RAEIH_Blacksmithing_Icon:SetSimpleAnchor(RAEIH_Blacksmithing, iX, iY)
	-- Update String Anchor
	RAEIH_Blacksmithing_String:ClearAnchors()
	RAEIH_Blacksmithing_String:SetSimpleAnchor(RAEIH_Blacksmithing, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_Blacksmithing_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingBlacksmithing()
	RAEIH_Blacksmithing:StartMoving()
end

function RAEIH.StopMovingBlacksmithing()
	RAEIH_Blacksmithing:StopMovingOrResizing()
	RAEIH.SavedVars.BlacksmithingX = RAEIH_Blacksmithing:GetLeft()
	RAEIH.SavedVars.BlacksmithingY = RAEIH_Blacksmithing:GetTop()
end