local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateSoulGems()
	local WM = GetWindowManager()
	if RAEIH_SoulGems == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.SoulGemsX
		local mY = RAEIH.SavedVars.SoulGemsY
		local mW = RAEIH.SavedVars.SoulGemsIconW + 10
		local mH = RAEIH.SavedVars.SoulGemsIconH
		local iX = RAEIH.SavedVars.SoulGemsIconX
		local iY = RAEIH.SavedVars.SoulGemsIconY
		local iW = RAEIH.SavedVars.SoulGemsIconW
		local iH = RAEIH.SavedVars.SoulGemsIconH
		local bA = RAEIH.SavedVars.SoulGemsBA
		-- Main Placeholder
		RAEIH_SoulGems = WM:CreateTopLevelWindow("RAEIH_SoulGems")
		RAEIH_SoulGems:SetClampedToScreen(true)
		RAEIH_SoulGems:SetDrawLevel(1)
		RAEIH_SoulGems:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_SoulGems:SetMouseEnabled(true)
		RAEIH_SoulGems:SetMovable(not RAEIH.SavedVars.LockSoulGems)
		RAEIH_SoulGems:SetHandler("OnReceiveDrag", RAEIH.StartMovingSoulGems)
		RAEIH_SoulGems:SetHandler("OnMouseUp", RAEIH.StopMovingSoulGems)
		RAEIH_SoulGems:SetHidden(not RAEIH.SavedVars.ShowSoulGems)
		-- Icon
		RAEIH_SoulGems_Icon = WM:CreateControl("RAEIH_SoulGems_Icon", RAEIH_SoulGems, CT_TEXTURE)
		RAEIH_SoulGems_Icon:SetTexture(RAEIH.Icons.SoulGems)
		RAEIH_SoulGems_Icon:SetDimensions(iW, iH)
		RAEIH_SoulGems_Icon:SetSimpleAnchor(RAEIH_SoulGems, iX, iY)
		-- String
		RAEIH_SoulGems_String = WM:CreateControl("RAEIH_SoulGems_String", RAEIH_SoulGems, CT_LABEL)
		RAEIH_SoulGems_String:SetSimpleAnchor(RAEIH_SoulGems, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_SoulGems_String:SetHorizontalAlignment(CENTER)
		RAEIH_SoulGems_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_SoulGems_Backdrop = WM:CreateControl("RAEIH_SoulGems_Backdrop", RAEIH_SoulGems, CT_BACKDROP)
		RAEIH_SoulGems_Backdrop:SetAnchorFill(RAEIH_SoulGems)
		RAEIH_SoulGems_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_SoulGems_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetSoulGems()

	local clrDft = "|c" .. RAEIH.SavedVars.SoulGemsDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.SoulGemsAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.SoulGemsWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.SoulGemsNormalColour
	local clr = clrDft

	local level = GetUnitEffectiveLevel(uTag)

	local usESGName, usESGIcon, usESGStack = GetSoulGemInfo(SOUL_GEM_TYPE_EMPTY, level, true)
	local usFSGName, usFSGIcon, usFSGStack = GetSoulGemInfo(SOUL_GEM_TYPE_FILLED, level, true)
	local usTSGStack = usESGStack + usFSGStack

	-- 25/100 (Empty: 75)

	if usESGStack >= usFSGStack and usFSGStack ~= 0 then
		clr = clrW
	elseif usESGStack >= usFSGStack and usFSGStack == 0 then
		clr = clrA
	else
		clr = clrN
	end

	if RAEIH.SavedVars.SoulGemsFormat == "Filled/Total (Empty)" then
		RAEIH.SoulGemsText = clr .. usFSGStack .. clrDft .. "/" .. usTSGStack .. " (E: " .. clr .. usESGStack .. clrDft .. ")"
	elseif RAEIH.SavedVars.SoulGemsFormat == "Filled/Total" then
		RAEIH.SoulGemsText = clr .. usFSGStack .. clrDft .. "/" .. usTSGStack
	elseif RAEIH.SavedVars.SoulGemsFormat == "Empty/Total" then
		RAEIH.SoulGemsText = clr .. usESGStack .. clrDft .. "/" .. usTSGStack
	elseif RAEIH.SavedVars.SoulGemsFormat == "Empty/Filled" then
		RAEIH.SoulGemsText = clr .. usESGStack .. clrDft .. "/" .. usFSGStack
	end
	RAEIH_SoulGems_String:SetText(RAEIH.SoulGemsText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatSoulGems()

	local font = LMP:Fetch('font', RAEIH.SavedVars.SoulGemsFont)
	local size = RAEIH.SavedVars.SoulGemsFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.SoulGemsFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_SoulGems_String:SetFont(fontFormat)

end

function RAEIH.OrganizeSoulGems()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.SoulGemsX
	local mY = RAEIH.SavedVars.SoulGemsY
	local mW = RAEIH.SavedVars.SoulGemsIconW + RAEIH_SoulGems_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.SoulGemsIconH
	local iX = RAEIH.SavedVars.SoulGemsIconX
	local iY = RAEIH.SavedVars.SoulGemsIconY
	local iW = RAEIH.SavedVars.SoulGemsIconW
	local iH = RAEIH.SavedVars.SoulGemsIconH
	local bA = RAEIH.SavedVars.SoulGemsBA
	-- Update General Dimensions
	RAEIH_SoulGems:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_SoulGems_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_SoulGems_Icon:ClearAnchors()
	RAEIH_SoulGems_Icon:SetSimpleAnchor(RAEIH_SoulGems, iX, iY)
	-- Update String Anchor
	RAEIH_SoulGems_String:ClearAnchors()
	RAEIH_SoulGems_String:SetSimpleAnchor(RAEIH_SoulGems, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_SoulGems_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingSoulGems()
	RAEIH_SoulGems:StartMoving()
end

function RAEIH.StopMovingSoulGems()
	RAEIH_SoulGems:StopMovingOrResizing()
	RAEIH.SavedVars.SoulGemsX = RAEIH_SoulGems:GetLeft()
	RAEIH.SavedVars.SoulGemsY = RAEIH_SoulGems:GetTop()
end