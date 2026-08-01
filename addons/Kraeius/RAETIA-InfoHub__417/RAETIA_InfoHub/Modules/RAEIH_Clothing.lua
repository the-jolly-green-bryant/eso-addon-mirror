local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateClothing()
	local WM = GetWindowManager()
	if RAEIH_Clothing == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.ClothingX
		local mY = RAEIH.SavedVars.ClothingY
		local mW = RAEIH.SavedVars.ClothingIconW + 10
		local mH = RAEIH.SavedVars.ClothingIconH
		local iX = RAEIH.SavedVars.ClothingIconX
		local iY = RAEIH.SavedVars.ClothingIconY
		local iW = RAEIH.SavedVars.ClothingIconW
		local iH = RAEIH.SavedVars.ClothingIconH
		local bA = RAEIH.SavedVars.ClothingBA
		-- Main Placeholder
		RAEIH_Clothing = WM:CreateTopLevelWindow("RAEIH_Clothing")
		RAEIH_Clothing:SetClampedToScreen(true)
		RAEIH_Clothing:SetDrawLevel(1)
		RAEIH_Clothing:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_Clothing:SetMouseEnabled(true)
		RAEIH_Clothing:SetMovable(not RAEIH.SavedVars.LockClothing)
		RAEIH_Clothing:SetHandler("OnReceiveDrag", RAEIH.StartMovingClothing)
		RAEIH_Clothing:SetHandler("OnMouseUp", RAEIH.StopMovingClothing)
		RAEIH_Clothing:SetHidden(not RAEIH.SavedVars.ShowClothing)
		-- Icon
		RAEIH_Clothing_Icon = WM:CreateControl("RAEIH_Clothing_Icon", RAEIH_Clothing, CT_TEXTURE)
		RAEIH_Clothing_Icon:SetTexture(RAEIH.Icons.Clothing)
		RAEIH_Clothing_Icon:SetDimensions(iW, iH)
		RAEIH_Clothing_Icon:SetSimpleAnchor(RAEIH_Clothing, iX, iY)
		-- String
		RAEIH_Clothing_String = WM:CreateControl("RAEIH_Clothing_String", RAEIH_Clothing, CT_LABEL)
		RAEIH_Clothing_String:SetSimpleAnchor(RAEIH_Clothing, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_Clothing_String:SetHorizontalAlignment(CENTER)
		RAEIH_Clothing_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_Clothing_Backdrop = WM:CreateControl("RAEIH_Clothing_Backdrop", RAEIH_Clothing, CT_BACKDROP)
		RAEIH_Clothing_Backdrop:SetAnchorFill(RAEIH_Clothing)
		RAEIH_Clothing_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_Clothing_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetClothing()

	local clrDft = "|c" .. RAEIH.SavedVars.ClothingDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.ClothingAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.ClothingWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.ClothingNormalColour

	local clrT = clrDft

	local CL = CRAFTING_TYPE_CLOTHIER

	local nRLines = GetNumSmithingResearchLines(CL) -- 14
	local maxRS = GetMaxSimultaneousSmithingResearch(CL) -- 3
	local sInUse = 0
	local lRTime = 99999999

	for i = 1, nRLines do
		local iName, iTX, iTRNum, iNextRTime = GetSmithingResearchLineInfo(CL, i) -- One of 14
		for k = 1, iTRNum do
			local rTTime, rRTime = GetSmithingResearchLineTraitTimes(CL, i, k)
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
		rStatus = clrW .. "CL" .. clrDft .. " (" .. clrW .. sInUse .. clrDft .. "/" .. clrA .. maxRS .. clrDft .. ")"
	elseif sInUse ~= maxRS and sInUse == 0 then
		rStatus = clrA .. "CL" .. clrDft .. " (" .. clrA .. sInUse .. clrDft .. "/" .. clrA .. maxRS .. clrDft .. ")"
	elseif sInUse == maxRS then
		rStatus = clrN .. "CL" .. clrDft .. " (" .. clrN .. sInUse .. clrDft .. "/" .. clrN .. maxRS .. clrDft .. ")"
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
	RAEIH.ClothingText = rStatus .. tStatus
	RAEIH_Clothing_String:SetText(RAEIH.ClothingText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatClothing()

	local font = LMP:Fetch('font', RAEIH.SavedVars.ClothingFont)
	local size = RAEIH.SavedVars.ClothingFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.ClothingFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_Clothing_String:SetFont(fontFormat)

end

function RAEIH.OrganizeClothing()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.ClothingX
	local mY = RAEIH.SavedVars.ClothingY
	local mW = RAEIH.SavedVars.ClothingIconW + RAEIH_Clothing_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.ClothingIconH
	local iX = RAEIH.SavedVars.ClothingIconX
	local iY = RAEIH.SavedVars.ClothingIconY
	local iW = RAEIH.SavedVars.ClothingIconW
	local iH = RAEIH.SavedVars.ClothingIconH
	local bA = RAEIH.SavedVars.ClothingBA
	-- Update General Dimensions
	RAEIH_Clothing:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_Clothing_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_Clothing_Icon:ClearAnchors()
	RAEIH_Clothing_Icon:SetSimpleAnchor(RAEIH_Clothing, iX, iY)
	-- Update String Anchor
	RAEIH_Clothing_String:ClearAnchors()
	RAEIH_Clothing_String:SetSimpleAnchor(RAEIH_Clothing, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_Clothing_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingClothing()
	RAEIH_Clothing:StartMoving()
end

function RAEIH.StopMovingClothing()
	RAEIH_Clothing:StopMovingOrResizing()
	RAEIH.SavedVars.ClothingX = RAEIH_Clothing:GetLeft()
	RAEIH.SavedVars.ClothingY = RAEIH_Clothing:GetTop()
end