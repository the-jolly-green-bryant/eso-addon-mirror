local LMP = RAEIH.LMP
local uTag = "player"
local iconGold = zo_iconFormat("esoui/art/currency/currency_gold.dds", 16, 16)

function RAEIH.CreateBankedGold()
	local WM = GetWindowManager()
	if RAEIH_BankedGold == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.BankedGoldX
		local mY = RAEIH.SavedVars.BankedGoldY
		local mW = RAEIH.SavedVars.BankedGoldIconW + 10
		local mH = RAEIH.SavedVars.BankedGoldIconH
		local iX = RAEIH.SavedVars.BankedGoldIconX
		local iY = RAEIH.SavedVars.BankedGoldIconY
		local iW = RAEIH.SavedVars.BankedGoldIconW
		local iH = RAEIH.SavedVars.BankedGoldIconH
		local bA = RAEIH.SavedVars.BankedGoldBA
		-- Main Placeholder
		RAEIH_BankedGold = WM:CreateTopLevelWindow("RAEIH_BankedGold")
		RAEIH_BankedGold:SetClampedToScreen(true)
		RAEIH_BankedGold:SetDrawLevel(1)
		RAEIH_BankedGold:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_BankedGold:SetMouseEnabled(true)
		RAEIH_BankedGold:SetMovable(not RAEIH.SavedVars.LockBankedGold)
		RAEIH_BankedGold:SetHandler("OnReceiveDrag", RAEIH.StartMovingBankedGold)
		RAEIH_BankedGold:SetHandler("OnMouseUp", RAEIH.StopMovingBankedGold)
		RAEIH_BankedGold:SetHidden(not RAEIH.SavedVars.ShowBankedGold)
		-- Icon
		RAEIH_BankedGold_Icon = WM:CreateControl("RAEIH_BankedGold_Icon", RAEIH_BankedGold, CT_TEXTURE)
		RAEIH_BankedGold_Icon:SetTexture(RAEIH.Icons.BankedGold)
		RAEIH_BankedGold_Icon:SetDimensions(iW, iH)
		RAEIH_BankedGold_Icon:SetSimpleAnchor(RAEIH_BankedGold, iX, iY)
		-- String
		RAEIH_BankedGold_String = WM:CreateControl("RAEIH_BankedGold_String", RAEIH_BankedGold, CT_LABEL)
		RAEIH_BankedGold_String:SetSimpleAnchor(RAEIH_BankedGold, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_BankedGold_String:SetHorizontalAlignment(CENTER)
		RAEIH_BankedGold_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_BankedGold_Backdrop = WM:CreateControl("RAEIH_BankedGold_Backdrop", RAEIH_BankedGold, CT_BACKDROP)
		RAEIH_BankedGold_Backdrop:SetAnchorFill(RAEIH_BankedGold)
		RAEIH_BankedGold_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_BankedGold_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetBankedGold()

	local clrDft = "|c" .. RAEIH.SavedVars.BankedGoldDefaultColour
	local bankedGold = GetBankedMoney(uTag)

	if RAEIH.SavedVars.TSFormat == "Point (.)" then
		bankedGold = RAEIH.ThousandsSeparatorPoint(bankedGold)
	else
		bankedGold = RAEIH.ThousandsSeparatorComma(bankedGold)
	end

	RAEIH.BankedGoldText = clrDft .. bankedGold .. iconGold
	RAEIH_BankedGold_String:SetText(RAEIH.BankedGoldText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatBankedGold()

	local font = LMP:Fetch('font', RAEIH.SavedVars.BankedGoldFont)
	local size = RAEIH.SavedVars.BankedGoldFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.BankedGoldFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_BankedGold_String:SetFont(fontFormat)

end

function RAEIH.OrganizeBankedGold()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.BankedGoldX
	local mY = RAEIH.SavedVars.BankedGoldY
	local mW = RAEIH.SavedVars.BankedGoldIconW + RAEIH_BankedGold_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.BankedGoldIconH
	local iX = RAEIH.SavedVars.BankedGoldIconX
	local iY = RAEIH.SavedVars.BankedGoldIconY
	local iW = RAEIH.SavedVars.BankedGoldIconW
	local iH = RAEIH.SavedVars.BankedGoldIconH
	local bA = RAEIH.SavedVars.BankedGoldBA
	-- Update General Dimensions
	RAEIH_BankedGold:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_BankedGold_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_BankedGold_Icon:ClearAnchors()
	RAEIH_BankedGold_Icon:SetSimpleAnchor(RAEIH_BankedGold, iX, iY)
	-- Update String Anchor
	RAEIH_BankedGold_String:ClearAnchors()
	RAEIH_BankedGold_String:SetSimpleAnchor(RAEIH_BankedGold, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_BankedGold_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingBankedGold()
	RAEIH_BankedGold:StartMoving()
end

function RAEIH.StopMovingBankedGold()
	RAEIH_BankedGold:StopMovingOrResizing()
	RAEIH.SavedVars.BankedGoldX = RAEIH_BankedGold:GetLeft()
	RAEIH.SavedVars.BankedGoldY = RAEIH_BankedGold:GetTop()
end