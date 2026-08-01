local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateWoodworking()
	local WM = GetWindowManager()
	if RAEIH_Woodworking == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.WoodworkingX
		local mY = RAEIH.SavedVars.WoodworkingY
		local mW = RAEIH.SavedVars.WoodworkingIconW + 10
		local mH = RAEIH.SavedVars.WoodworkingIconH
		local iX = RAEIH.SavedVars.WoodworkingIconX
		local iY = RAEIH.SavedVars.WoodworkingIconY
		local iW = RAEIH.SavedVars.WoodworkingIconW
		local iH = RAEIH.SavedVars.WoodworkingIconH
		local bA = RAEIH.SavedVars.WoodworkingBA
		-- Main Placeholder
		RAEIH_Woodworking = WM:CreateTopLevelWindow("RAEIH_Woodworking")
		RAEIH_Woodworking:SetClampedToScreen(true)
		RAEIH_Woodworking:SetDrawLevel(1)
		RAEIH_Woodworking:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_Woodworking:SetMouseEnabled(true)
		RAEIH_Woodworking:SetMovable(not RAEIH.SavedVars.LockWoodworking)
		RAEIH_Woodworking:SetHandler("OnReceiveDrag", RAEIH.StartMovingWoodworking)
		RAEIH_Woodworking:SetHandler("OnMouseUp", RAEIH.StopMovingWoodworking)
		RAEIH_Woodworking:SetHidden(not RAEIH.SavedVars.ShowWoodworking)
		-- Icon
		RAEIH_Woodworking_Icon = WM:CreateControl("RAEIH_Woodworking_Icon", RAEIH_Woodworking, CT_TEXTURE)
		RAEIH_Woodworking_Icon:SetTexture(RAEIH.Icons.Woodworking)
		RAEIH_Woodworking_Icon:SetDimensions(iW, iH)
		RAEIH_Woodworking_Icon:SetSimpleAnchor(RAEIH_Woodworking, iX, iY)
		-- String
		RAEIH_Woodworking_String = WM:CreateControl("RAEIH_Woodworking_String", RAEIH_Woodworking, CT_LABEL)
		RAEIH_Woodworking_String:SetSimpleAnchor(RAEIH_Woodworking, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_Woodworking_String:SetHorizontalAlignment(CENTER)
		RAEIH_Woodworking_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_Woodworking_Backdrop = WM:CreateControl("RAEIH_Woodworking_Backdrop", RAEIH_Woodworking, CT_BACKDROP)
		RAEIH_Woodworking_Backdrop:SetAnchorFill(RAEIH_Woodworking)
		RAEIH_Woodworking_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_Woodworking_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetWoodworking()

	local clrDft = "|c" .. RAEIH.SavedVars.WoodworkingDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.WoodworkingAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.WoodworkingWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.WoodworkingNormalColour

	local clrT = clrDft

	local WW = CRAFTING_TYPE_WOODWORKING

	local nRLines = GetNumSmithingResearchLines(WW) -- 14
	local maxRS = GetMaxSimultaneousSmithingResearch(WW) -- 3
	local sInUse = 0
	local lRTime = 99999999

	for i = 1, nRLines do
		local iName, iTX, iTRNum, iNextRTime = GetSmithingResearchLineInfo(WW, i) -- One of 14
		for k = 1, iTRNum do
			local rTTime, rRTime = GetSmithingResearchLineTraitTimes(WW, i, k)
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
	lRTimeH = RAEIH.Round(lRTime / (60 * 60))
	lRTimeM = RAEIH.Round(lRTime / 60)
	lRTimeS = RAEIH.Round(lRTime)

	if sInUse ~= maxRS and sInUse ~= 0 then
		rStatus = clrW .. "WW" .. clrDft .. " (" .. clrW .. sInUse .. clrDft .. "/" .. clrA .. maxRS .. clrDft .. ")"
	elseif sInUse ~= maxRS and sInUse == 0 then
		rStatus = clrA .. "WW" .. clrDft .. " (" .. clrA .. sInUse .. clrDft .. "/" .. clrA .. maxRS .. clrDft .. ")"
	elseif sInUse == maxRS then
		rStatus = clrN .. "WW" .. clrDft .. " (" .. clrN .. sInUse .. clrDft .. "/" .. clrN .. maxRS .. clrDft .. ")"
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
	RAEIH.WoodworkingText = rStatus .. tStatus
	RAEIH_Woodworking_String:SetText(RAEIH.WoodworkingText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatWoodworking()

	local font = LMP:Fetch('font', RAEIH.SavedVars.WoodworkingFont)
	local size = RAEIH.SavedVars.WoodworkingFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.WoodworkingFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_Woodworking_String:SetFont(fontFormat)

end

function RAEIH.OrganizeWoodworking()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.WoodworkingX
	local mY = RAEIH.SavedVars.WoodworkingY
	local mW = RAEIH.SavedVars.WoodworkingIconW + RAEIH_Woodworking_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.WoodworkingIconH
	local iX = RAEIH.SavedVars.WoodworkingIconX
	local iY = RAEIH.SavedVars.WoodworkingIconY
	local iW = RAEIH.SavedVars.WoodworkingIconW
	local iH = RAEIH.SavedVars.WoodworkingIconH
	local bA = RAEIH.SavedVars.WoodworkingBA
	-- Update General Dimensions
	RAEIH_Woodworking:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_Woodworking_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_Woodworking_Icon:ClearAnchors()
	RAEIH_Woodworking_Icon:SetSimpleAnchor(RAEIH_Woodworking, iX, iY)
	-- Update String Anchor
	RAEIH_Woodworking_String:ClearAnchors()
	RAEIH_Woodworking_String:SetSimpleAnchor(RAEIH_Woodworking, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_Woodworking_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingWoodworking()
	RAEIH_Woodworking:StartMoving()
end

function RAEIH.StopMovingWoodworking()
	RAEIH_Woodworking:StopMovingOrResizing()
	RAEIH.SavedVars.WoodworkingX = RAEIH_Woodworking:GetLeft()
	RAEIH.SavedVars.WoodworkingY = RAEIH_Woodworking:GetTop()
end