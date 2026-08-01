local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateAvARank()
	local WM = GetWindowManager()
	if RAEIH_AvARank == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.AvARankX
		local mY = RAEIH.SavedVars.AvARankY
		local mW = RAEIH.SavedVars.AvARankIconW + 10
		local mH = RAEIH.SavedVars.AvARankIconH
		local iX = RAEIH.SavedVars.AvARankIconX
		local iY = RAEIH.SavedVars.AvARankIconY
		local iW = RAEIH.SavedVars.AvARankIconW
		local iH = RAEIH.SavedVars.AvARankIconH
		local bA = RAEIH.SavedVars.AvARankBA
		-- Main Placeholder
		RAEIH_AvARank = WM:CreateTopLevelWindow("RAEIH_AvARank")
		RAEIH_AvARank:SetClampedToScreen(true)
		RAEIH_AvARank:SetDrawLevel(1)
		RAEIH_AvARank:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_AvARank:SetMouseEnabled(true)
		RAEIH_AvARank:SetMovable(not RAEIH.SavedVars.LockAvARank)
		RAEIH_AvARank:SetHandler("OnReceiveDrag", RAEIH.StartMovingAvARank)
		RAEIH_AvARank:SetHandler("OnMouseUp", RAEIH.StopMovingAvARank)
		RAEIH_AvARank:SetHidden(not RAEIH.SavedVars.ShowAvARank)
		-- Icon
		RAEIH_AvARank_Icon = WM:CreateControl("RAEIH_AvARank_Icon", RAEIH_AvARank, CT_TEXTURE)
		RAEIH_AvARank_Icon:SetTexture(RAEIH.Icons.AvARank)
		RAEIH_AvARank_Icon:SetDimensions(iW, iH)
		RAEIH_AvARank_Icon:SetSimpleAnchor(RAEIH_AvARank, iX, iY)
		-- String
		RAEIH_AvARank_String = WM:CreateControl("RAEIH_AvARank_String", RAEIH_AvARank, CT_LABEL)
		RAEIH_AvARank_String:SetSimpleAnchor(RAEIH_AvARank, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_AvARank_String:SetHorizontalAlignment(CENTER)
		RAEIH_AvARank_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_AvARank_Backdrop = WM:CreateControl("RAEIH_AvARank_Backdrop", RAEIH_AvARank, CT_BACKDROP)
		RAEIH_AvARank_Backdrop:SetAnchorFill(RAEIH_AvARank)
		RAEIH_AvARank_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_AvARank_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

-- local uARPoint = GetUnitAvARankPoints("player")
-- d("AvA Rank Point: " .. uARPoint)
-- local uAR, uSAR = GetUnitAvARank("player")
-- d("AvA Rank: " .. uAR .. " // Sub AvA Rank: " .. uSAR)
-- local lARIcon = GetLargeAvARankIcon(uAR)
-- local sRStart, sRAt, rSAt, nRAt = GetAvARankProgress(uARPoint)
-- d("Sub Rank Start: " .. sRStart .. " // Sub Rank At: " .. sRAt .. " // Rank Start At: " .. rSAt .. " Next Rank At: " .. nRAt)
-- local aRPNeed = GetNumPointsNeededForAvARank(uAR)
-- d("Rank Point Needed: " .. aRPNeed)
-- d("----------")
-- d("Rank Current: " .. uARPoint - aRPNeed .. " / Max: " .. nRAt - rSAt)

function RAEIH.SetAvARank()

	if RAEIH.SavedVars.AvAAutoShow and IsPlayerInAvAWorld() then
		RAEIH_AvARank:SetHidden(false)
	elseif RAEIH.SavedVars.AvAAutoShow and IsPlayerInAvAWorld() == false then
		RAEIH_AvARank:SetHidden(true)
	end

	local clrDft = "|c" .. RAEIH.SavedVars.AvARankDefaultColour
	local clrAvARank = "|c" .. RAEIH.SavedVars.AvARankColour
	local clrES = "|c" .. RAEIH.SavedVars.AvARankESColour
	local clrMS = "|c" .. RAEIH.SavedVars.AvARankMSColour
	local clrLS = "|c" .. RAEIH.SavedVars.AvARankLSColour
	local clrAP = "|c" .. RAEIH.SavedVars.AvARankAPColour
	local clr = clrDft

	local campID = GetAssignedCampaignId()
	local gCampID = GetGuestCampaignId()
	local campName = GetCampaignName(campID)
	local gCampName = GetCampaignName(gCampID)

	local cAvARank = GetUnitAvARank(uTag)
	local cAvARankPoints = GetUnitAvARankPoints(uTag)
	local cGender = GetUnitGender(uTag)

	local cAvARankName = GetAvARankName(cGender, cAvARank)	

	local cAvARPNeeded = GetNumPointsNeededForAvARank(cAvARank)
	local cCurAvARProgress = cAvARankPoints - cAvARPNeeded	

	local __, __, rStart, rEnd = GetAvARankProgress(cAvARankPoints)
	local cMaxAvARProgress = rEnd - rStart

	local cAlliPoints = GetAlliancePoints()

	local iAlliPoints = zo_iconFormat(RAEIH.Icons.AlliancePoints, RAEIH.SavedVars.AvARankIconW, RAEIH.SavedVars.AvARankIconH)
	local iAvARankPath = GetLargeAvARankIcon(cAvARank)	
	local iAvARank = zo_iconFormat(iAvARankPath, RAEIH.SavedVars.AvARankIconW - 4, RAEIH.SavedVars.AvARankIconH - 4)	

	local cAvARankProgressPerc = RAEIH.Round(cCurAvARProgress / cMaxAvARProgress * 100)

	local cAvARankNameNext, iAvARankPathNext, iAvARankNext = nil

	if cAvARank ~= 50 then
		cAvARankNameNext = " " .. GetAvARankName(cGender, cAvARank + 1)
		iAvARankPathNext = GetLargeAvARankIcon(cAvARank + 1)
		iAvARankNext = " » " .. zo_iconFormat(iAvARankPathNext, RAEIH.SavedVars.AvARankIconW - 4, RAEIH.SavedVars.AvARankIconH - 4)
	else
		cAvARankNameNext = ""
		iAvARankNext = ""
	end

	local campText

	if campID == 0 and gCampID == 0 then
		campText = clrES .. "No Campaign"
	elseif campID ~= 0 and gCampID == 0 then
		campText = clrAvARank .. campName
	elseif campID == 0 and gCampID ~= 0 then
		campText = clrAvARank .. gCampName
	else 	
		campText = clrAvARank .. campName .. clrDft .. " || " .. clrAvARank .. gCampName
	end
	
	if cAvARankProgressPerc > 75 then
		clr = clrLS
	elseif cAvARankProgressPerc <= 75 and cAvARankProgressPerc >= 25 then
		clr = clrMS
	else
		clr = clrES
	end

	if RAEIH.SavedVars.TSFormat == "Point (.)" then
		cAlliPoints = RAEIH.ThousandsSeparatorPoint(cAlliPoints)
		cCurAvARProgress = RAEIH.ThousandsSeparatorPoint(cCurAvARProgress)
		cMaxAvARProgress = RAEIH.ThousandsSeparatorPoint(cMaxAvARProgress)
		cAvARankProgressPerc = string.gsub(tostring(cAvARankProgressPerc), "%.", ",") .. "%"
	else
		cAlliPoints = RAEIH.ThousandsSeparatorComma(cAlliPoints)
		cCurAvARProgress = RAEIH.ThousandsSeparatorComma(cCurAvARProgress)
		cMaxAvARProgress = RAEIH.ThousandsSeparatorComma(cMaxAvARProgress)
		cAvARankProgressPerc = tostring(cAvARankProgressPerc) .. "%"
	end

	if RAEIH.SavedVars.AvARankDetailed == true then
		RAEIH.AvARankText = campText .. "\n" .. cAvARank .. clrDft .. " » " .. clr .. cCurAvARProgress .. clrDft .. " / " .. clr .. cMaxAvARProgress .. clrDft .. " (" .. clr .. cAvARankProgressPerc .. clrDft .. ") ||" .. iAlliPoints .. " " .. clrAP .. cAlliPoints .. "\n" .. clrDft .. cAvARankName .. " " .. iAvARank .. iAvARankNext .. cAvARankNameNext 
	elseif RAEIH.SavedVars.AvARankFormat == "Rank » Current/Max (%)" then
		RAEIH.AvARankText = clrAvARank .. cAvARank .. iAvARank .. clrDft .. " » " .. clr .. cCurAvARProgress .. clrDft .. " / " .. clr .. cMaxAvARProgress .. clrDft .. " (" .. clr .. cAvARankProgressPerc .. clrDft .. ")"
	elseif RAEIH.SavedVars.AvARankFormat == "Current/Max (%)" then
		RAEIH.AvARankText = clr .. cCurAvARProgress .. clrDft .. " / " .. clr .. cMaxAvARProgress .. clrDft .. " (" .. clr .. cAvARankProgressPerc .. clrDft .. ")"
	elseif RAEIH.SavedVars.AvARankFormat == "Current/Max" then
		RAEIH.AvARankText = clr .. cCurAvARProgress .. clrDft .. " / " .. clr .. cMaxAvARProgress
	elseif RAEIH.SavedVars.AvARankFormat == "Rank » %" then
		RAEIH.AvARankText = clrAvARank .. cAvARank .. iAvARank .. clrDft .. " » " .. clr .. cAvARankProgressPerc
	else
		RAEIH.AvARankText = clr .. cAvARankProgressPerc
	end

	RAEIH_AvARank_String:SetText(RAEIH.AvARankText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatAvARank()

	local font = LMP:Fetch('font', RAEIH.SavedVars.AvARankFont)
	local size = RAEIH.SavedVars.AvARankFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.AvARankFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_AvARank_String:SetFont(fontFormat)

end

function RAEIH.OrganizeAvARank()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.AvARankX
	local mY = RAEIH.SavedVars.AvARankY
	local mW = RAEIH.SavedVars.AvARankIconW + RAEIH_AvARank_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.AvARankIconH
	local iX = RAEIH.SavedVars.AvARankIconX
	local iY = RAEIH.SavedVars.AvARankIconY
	local iW = RAEIH.SavedVars.AvARankIconW
	local iH = RAEIH.SavedVars.AvARankIconH
	local bA = RAEIH.SavedVars.AvARankBA
	-- Update General Dimensions
	RAEIH_AvARank:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_AvARank_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_AvARank_Icon:ClearAnchors()
	RAEIH_AvARank_Icon:SetSimpleAnchor(RAEIH_AvARank, iX, iY)
	-- Update String Anchor
	RAEIH_AvARank_String:ClearAnchors()
	RAEIH_AvARank_String:SetSimpleAnchor(RAEIH_AvARank, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_AvARank_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingAvARank()
	RAEIH_AvARank:StartMoving()
end

function RAEIH.StopMovingAvARank()
	RAEIH_AvARank:StopMovingOrResizing()
	RAEIH.SavedVars.AvARankX = RAEIH_AvARank:GetLeft()
	RAEIH.SavedVars.AvARankY = RAEIH_AvARank:GetTop()
end