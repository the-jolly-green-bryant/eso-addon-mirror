local LMP = RAEIH.LMP
local uTag = "player"
local startingGameTime = GetGameTimeMilliseconds()
local startingGold = GetCurrentMoney()
local gainedGold = 0
local iconGold = zo_iconFormat("esoui/art/currency/currency_gold.dds", 16, 16)

function RAEIH.CreateGoldperHour()
	local WM = GetWindowManager()
	if RAEIH_GoldperHour == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.GoldperHourX
		local mY = RAEIH.SavedVars.GoldperHourY
		local mW = RAEIH.SavedVars.GoldperHourIconW + 10
		local mH = RAEIH.SavedVars.GoldperHourIconH
		local iX = RAEIH.SavedVars.GoldperHourIconX
		local iY = RAEIH.SavedVars.GoldperHourIconY
		local iW = RAEIH.SavedVars.GoldperHourIconW
		local iH = RAEIH.SavedVars.GoldperHourIconH
		local bA = RAEIH.SavedVars.GoldperHourBA
		-- Main Placeholder
		RAEIH_GoldperHour = WM:CreateTopLevelWindow("RAEIH_GoldperHour")
		RAEIH_GoldperHour:SetClampedToScreen(true)
		RAEIH_GoldperHour:SetDrawLevel(1)
		RAEIH_GoldperHour:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_GoldperHour:SetMouseEnabled(true)
		RAEIH_GoldperHour:SetMovable(not RAEIH.SavedVars.LockGoldperHour)
		RAEIH_GoldperHour:SetHandler("OnReceiveDrag", RAEIH.StartMovingGoldperHour)
		RAEIH_GoldperHour:SetHandler("OnMouseUp", RAEIH.StopMovingGoldperHour)
		RAEIH_GoldperHour:SetHidden(not RAEIH.SavedVars.ShowGoldperHour)
		-- Icon
		RAEIH_GoldperHour_Icon = WM:CreateControl("RAEIH_GoldperHour_Icon", RAEIH_GoldperHour, CT_TEXTURE)
		RAEIH_GoldperHour_Icon:SetTexture(RAEIH.Icons.GoldperHour)
		RAEIH_GoldperHour_Icon:SetDimensions(iW, iH)
		RAEIH_GoldperHour_Icon:SetSimpleAnchor(RAEIH_GoldperHour, iX, iY)
		-- String
		RAEIH_GoldperHour_String = WM:CreateControl("RAEIH_GoldperHour_String", RAEIH_GoldperHour, CT_LABEL)
		RAEIH_GoldperHour_String:SetSimpleAnchor(RAEIH_GoldperHour, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_GoldperHour_String:SetHorizontalAlignment(CENTER)
		RAEIH_GoldperHour_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_GoldperHour_Backdrop = WM:CreateControl("RAEIH_GoldperHour_Backdrop", RAEIH_GoldperHour, CT_BACKDROP)
		RAEIH_GoldperHour_Backdrop:SetAnchorFill(RAEIH_GoldperHour)
		RAEIH_GoldperHour_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_GoldperHour_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetGoldperHour()

	local clrDft = "|c" .. RAEIH.SavedVars.GoldperHourDefaultColour
	local clrGoldperHour = "|c" .. RAEIH.SavedVars.GoldperHourColour

	local elapsedTime = GetGameTimeMilliseconds() - startingGameTime
	local lootedGold = GetCurrentMoney(uTag) - startingGold

	if lootedGold > 0 then
		gainedGold = gainedGold + lootedGold
	end

	local goldPerHour = RAEIH.Round(gainedGold / (elapsedTime / 3600000))
	startingGold = GetCurrentMoney(uTag)

	if RAEIH.SavedVars.TSFormat == "Point (.)" then
		goldPerHour = string.gsub(tostring(goldPerHour), "%.", ",")
	else
		goldPerHour = tostring(goldPerHour)
	end

	RAEIH.GoldperHourText = clrGoldperHour .. goldPerHour .. clrDft .. iconGold .. "/h"
	RAEIH_GoldperHour_String:SetText(RAEIH.GoldperHourText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatGoldperHour()

	local font = LMP:Fetch('font', RAEIH.SavedVars.GoldperHourFont)
	local size = RAEIH.SavedVars.GoldperHourFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.GoldperHourFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_GoldperHour_String:SetFont(fontFormat)

end

function RAEIH.OrganizeGoldperHour()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.GoldperHourX
	local mY = RAEIH.SavedVars.GoldperHourY
	local mW = RAEIH.SavedVars.GoldperHourIconW + RAEIH_GoldperHour_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.GoldperHourIconH
	local iX = RAEIH.SavedVars.GoldperHourIconX
	local iY = RAEIH.SavedVars.GoldperHourIconY
	local iW = RAEIH.SavedVars.GoldperHourIconW
	local iH = RAEIH.SavedVars.GoldperHourIconH
	local bA = RAEIH.SavedVars.GoldperHourBA
	-- Update General Dimensions
	RAEIH_GoldperHour:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_GoldperHour_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_GoldperHour_Icon:ClearAnchors()
	RAEIH_GoldperHour_Icon:SetSimpleAnchor(RAEIH_GoldperHour, iX, iY)
	-- Update String Anchor
	RAEIH_GoldperHour_String:ClearAnchors()
	RAEIH_GoldperHour_String:SetSimpleAnchor(RAEIH_GoldperHour, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_GoldperHour_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingGoldperHour()
	RAEIH_GoldperHour:StartMoving()
end

function RAEIH.StopMovingGoldperHour()
	RAEIH_GoldperHour:StopMovingOrResizing()
	RAEIH.SavedVars.GoldperHourX = RAEIH_GoldperHour:GetLeft()
	RAEIH.SavedVars.GoldperHourY = RAEIH_GoldperHour:GetTop()
end