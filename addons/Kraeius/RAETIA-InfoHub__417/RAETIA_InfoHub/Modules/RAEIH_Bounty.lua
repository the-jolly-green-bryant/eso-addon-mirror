local LMP = RAEIH.LMP
local uTag = "player"
local iconGold = zo_iconFormat("esoui/art/currency/currency_gold.dds", 16, 16)

function RAEIH.CreateBounty()
	local WM = GetWindowManager()
	if RAEIH_Bounty == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.BountyX
		local mY = RAEIH.SavedVars.BountyY
		local mW = RAEIH.SavedVars.BountyIconW + 10
		local mH = RAEIH.SavedVars.BountyIconH
		local iX = RAEIH.SavedVars.BountyIconX
		local iY = RAEIH.SavedVars.BountyIconY
		local iW = RAEIH.SavedVars.BountyIconW
		local iH = RAEIH.SavedVars.BountyIconH
		local bA = RAEIH.SavedVars.BountyBA
		-- Main Placeholder
		RAEIH_Bounty = WM:CreateTopLevelWindow("RAEIH_Bounty")
		RAEIH_Bounty:SetClampedToScreen(true)
		RAEIH_Bounty:SetDrawLevel(1)
		RAEIH_Bounty:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_Bounty:SetMouseEnabled(true)
		RAEIH_Bounty:SetMovable(not RAEIH.SavedVars.LockBounty)
		RAEIH_Bounty:SetHandler("OnReceiveDrag", RAEIH.StartMovingBounty)
		RAEIH_Bounty:SetHandler("OnMouseUp", RAEIH.StopMovingBounty)
		RAEIH_Bounty:SetHidden(not RAEIH.SavedVars.ShowBounty)
		-- Icon
		RAEIH_Bounty_Icon = WM:CreateControl("RAEIH_Bounty_Icon", RAEIH_Bounty, CT_TEXTURE)
		RAEIH_Bounty_Icon:SetTexture(RAEIH.Icons.Bounty)
		RAEIH_Bounty_Icon:SetDimensions(iW, iH)
		RAEIH_Bounty_Icon:SetSimpleAnchor(RAEIH_Bounty, iX, iY)
		-- String
		RAEIH_Bounty_String = WM:CreateControl("RAEIH_Bounty_String", RAEIH_Bounty, CT_LABEL)
		RAEIH_Bounty_String:SetSimpleAnchor(RAEIH_Bounty, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_Bounty_String:SetHorizontalAlignment(CENTER)
		RAEIH_Bounty_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_Bounty_Backdrop = WM:CreateControl("RAEIH_Bounty_Backdrop", RAEIH_Bounty, CT_BACKDROP)
		RAEIH_Bounty_Backdrop:SetAnchorFill(RAEIH_Bounty)
		RAEIH_Bounty_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_Bounty_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

-- INFAMY_THRESHOLD_DISREPUTABLE = 1
-- INFAMY_THRESHOLD_FUGITIVE = 3
-- INFAMY_THRESHOLD_NOTORIOUS = 2
-- INFAMY_THRESHOLD_UPSTANDING = 0

function RAEIH.SetBounty()

	local clrDft = "|c" .. RAEIH.SavedVars.BountyDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.BountyAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.BountyWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.BountyNormalColour
	local clrG = "|c" .. RAEIH.SavedVars.BountyGoldColour
	local clr = clrDft

	local infamy = GetInfamy()
	local boTimer = GetBounty() / 2
	local bounty = GetFullBountyPayoffAmount()
	local heat = GetPlayerInfamyData()
	local inDesc = "Upstanding"
	local inStat = GetInfamyLevel(infamy)

	if inStat == 0 then
		inDesc = "Upstanding"
		clr = clrN
	elseif inStat == 1 then
		inDesc = "Disreputable"
		clr = clrW
	elseif inStat == 2 then
		inDesc = "Notorious"
		clr = clrW
	elseif inStat == 3 then
		inDesc = "Fugitive"
		clr = clrA
	else
		inDesc = "None"
		clr = clrN
	end

	if bounty == 0 then 
		bounty = "No Bounty"
	else
		bounty = bounty .. iconGold 
	end

	if heat == 0 then 
		heat = "None"
	else
		heat = heat
	end

	if RAEIH.SavedVars.BountyFormat == "Status (Bounty)/BT (HE)" then
		RAEIH.BountyText = clr .. inDesc .. clrDft .. " (" .. clrG .. bounty .. clrDft .. ") / BT: " .. clr .. boTimer .. "m" .. clrDft .. " (HE: " .. clr .. heat .. clrDft .. ")"
	elseif RAEIH.SavedVars.BountyFormat == "Status (Bounty) » BT" then
		RAEIH.BountyText = clr .. inDesc .. clrDft .. " (" .. clrG .. bounty .. clrDft .. ") / BT: " .. clr .. boTimer .. "m"
	elseif RAEIH.SavedVars.BountyFormat == "Status (Bounty)" then
		RAEIH.BountyText = clr .. inDesc .. clrDft .. " (" .. clrG .. bounty .. clrDft .. ")"
	end
	RAEIH_Bounty_String:SetText(RAEIH.BountyText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatBounty()

	local font = LMP:Fetch('font', RAEIH.SavedVars.BountyFont)
	local size = RAEIH.SavedVars.BountyFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.BountyFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_Bounty_String:SetFont(fontFormat)

end

function RAEIH.OrganizeBounty()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.BountyX
	local mY = RAEIH.SavedVars.BountyY
	local mW = RAEIH.SavedVars.BountyIconW + RAEIH_Bounty_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.BountyIconH
	local iX = RAEIH.SavedVars.BountyIconX
	local iY = RAEIH.SavedVars.BountyIconY
	local iW = RAEIH.SavedVars.BountyIconW
	local iH = RAEIH.SavedVars.BountyIconH
	local bA = RAEIH.SavedVars.BountyBA
	-- Update General Dimensions
	RAEIH_Bounty:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_Bounty_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_Bounty_Icon:ClearAnchors()
	RAEIH_Bounty_Icon:SetSimpleAnchor(RAEIH_Bounty, iX, iY)
	-- Update String Anchor
	RAEIH_Bounty_String:ClearAnchors()
	RAEIH_Bounty_String:SetSimpleAnchor(RAEIH_Bounty, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_Bounty_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingBounty()
	RAEIH_Bounty:StartMoving()
end

function RAEIH.StopMovingBounty()
	RAEIH_Bounty:StopMovingOrResizing()
	RAEIH.SavedVars.BountyX = RAEIH_Bounty:GetLeft()
	RAEIH.SavedVars.BountyY = RAEIH_Bounty:GetTop()
end