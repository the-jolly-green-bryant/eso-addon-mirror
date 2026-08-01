local LMP = RAEIH.LMP
local uTag = "player"
local iconGold = zo_iconFormat("esoui/art/currency/currency_gold.dds", 16, 16)

function RAEIH.CreateGold()
	local WM = GetWindowManager()
	if RAEIH_Gold == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.GoldX
		local mY = RAEIH.SavedVars.GoldY
		local mW = RAEIH.SavedVars.GoldIconW + 10
		local mH = RAEIH.SavedVars.GoldIconH
		local iX = RAEIH.SavedVars.GoldIconX
		local iY = RAEIH.SavedVars.GoldIconY
		local iW = RAEIH.SavedVars.GoldIconW
		local iH = RAEIH.SavedVars.GoldIconH
		local bA = RAEIH.SavedVars.GoldBA
		-- Main Placeholder
		RAEIH_Gold = WM:CreateTopLevelWindow("RAEIH_Gold")
		RAEIH_Gold:SetClampedToScreen(true)
		RAEIH_Gold:SetDrawLevel(1)
		RAEIH_Gold:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_Gold:SetMouseEnabled(true)
		RAEIH_Gold:SetMovable(not RAEIH.SavedVars.LockGold)
		RAEIH_Gold:SetHandler("OnReceiveDrag", RAEIH.StartMovingGold)
		RAEIH_Gold:SetHandler("OnMouseUp", RAEIH.StopMovingGold)
		RAEIH_Gold:SetHidden(not RAEIH.SavedVars.ShowGold)
		-- Icon
		RAEIH_Gold_Icon = WM:CreateControl("RAEIH_Gold_Icon", RAEIH_Gold, CT_TEXTURE)
		RAEIH_Gold_Icon:SetTexture(RAEIH.Icons.Gold)
		RAEIH_Gold_Icon:SetDimensions(iW, iH)
		RAEIH_Gold_Icon:SetSimpleAnchor(RAEIH_Gold, iX, iY)
		-- String
		RAEIH_Gold_String = WM:CreateControl("RAEIH_Gold_String", RAEIH_Gold, CT_LABEL)
		RAEIH_Gold_String:SetSimpleAnchor(RAEIH_Gold, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_Gold_String:SetHorizontalAlignment(CENTER)
		RAEIH_Gold_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_Gold_Backdrop = WM:CreateControl("RAEIH_Gold_Backdrop", RAEIH_Gold, CT_BACKDROP)
		RAEIH_Gold_Backdrop:SetAnchorFill(RAEIH_Gold)
		RAEIH_Gold_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_Gold_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetGold()

	local clrDft = "|c" .. RAEIH.SavedVars.GoldDefaultColour
	local gold = GetCurrentMoney(uTag)

	if RAEIH.SavedVars.TSFormat == "Point (.)" then
		gold = RAEIH.ThousandsSeparatorPoint(gold)
	else
		gold = RAEIH.ThousandsSeparatorComma(gold)
	end

	RAEIH.GoldText = clrDft .. gold .. iconGold
	RAEIH_Gold_String:SetText(RAEIH.GoldText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatGold()

	local font = LMP:Fetch('font', RAEIH.SavedVars.GoldFont)
	local size = RAEIH.SavedVars.GoldFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.GoldFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_Gold_String:SetFont(fontFormat)

end

function RAEIH.OrganizeGold()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.GoldX
	local mY = RAEIH.SavedVars.GoldY
	local mW = RAEIH.SavedVars.GoldIconW + RAEIH_Gold_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.GoldIconH
	local iX = RAEIH.SavedVars.GoldIconX
	local iY = RAEIH.SavedVars.GoldIconY
	local iW = RAEIH.SavedVars.GoldIconW
	local iH = RAEIH.SavedVars.GoldIconH
	local bA = RAEIH.SavedVars.GoldBA
	-- Update General Dimensions
	RAEIH_Gold:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_Gold_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_Gold_Icon:ClearAnchors()
	RAEIH_Gold_Icon:SetSimpleAnchor(RAEIH_Gold, iX, iY)
	-- Update String Anchor
	RAEIH_Gold_String:ClearAnchors()
	RAEIH_Gold_String:SetSimpleAnchor(RAEIH_Gold, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_Gold_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingGold()
	RAEIH_Gold:StartMoving()
end

function RAEIH.StopMovingGold()
	RAEIH_Gold:StopMovingOrResizing()
	RAEIH.SavedVars.GoldX = RAEIH_Gold:GetLeft()
	RAEIH.SavedVars.GoldY = RAEIH_Gold:GetTop()
end