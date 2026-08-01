local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateBagSlots()
	local WM = GetWindowManager()
	if RAEIH_BagSlots == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.BagSlotsX
		local mY = RAEIH.SavedVars.BagSlotsY
		local mW = RAEIH.SavedVars.BagSlotsIconW + 10
		local mH = RAEIH.SavedVars.BagSlotsIconH
		local iX = RAEIH.SavedVars.BagSlotsIconX
		local iY = RAEIH.SavedVars.BagSlotsIconY
		local iW = RAEIH.SavedVars.BagSlotsIconW
		local iH = RAEIH.SavedVars.BagSlotsIconH
		local bA = RAEIH.SavedVars.BagSlotsBA
		-- Main Placeholder
		RAEIH_BagSlots = WM:CreateTopLevelWindow("RAEIH_BagSlots")
		RAEIH_BagSlots:SetClampedToScreen(true)
		RAEIH_BagSlots:SetDrawLevel(1)
		RAEIH_BagSlots:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_BagSlots:SetMouseEnabled(true)
		RAEIH_BagSlots:SetMovable(not RAEIH.SavedVars.LockBagSlots)
		RAEIH_BagSlots:SetHandler("OnReceiveDrag", RAEIH.StartMovingBagSlots)
		RAEIH_BagSlots:SetHandler("OnMouseUp", RAEIH.StopMovingBagSlots)
		RAEIH_BagSlots:SetHidden(not RAEIH.SavedVars.ShowBagSlots)
		-- Icon
		RAEIH_BagSlots_Icon = WM:CreateControl("RAEIH_BagSlots_Icon", RAEIH_BagSlots, CT_TEXTURE)
		RAEIH_BagSlots_Icon:SetTexture(RAEIH.Icons.BagSlots)
		RAEIH_BagSlots_Icon:SetDimensions(iW, iH)
		RAEIH_BagSlots_Icon:SetSimpleAnchor(RAEIH_BagSlots, iX, iY)
		-- String
		RAEIH_BagSlots_String = WM:CreateControl("RAEIH_BagSlots_String", RAEIH_BagSlots, CT_LABEL)
		RAEIH_BagSlots_String:SetSimpleAnchor(RAEIH_BagSlots, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_BagSlots_String:SetHorizontalAlignment(CENTER)
		RAEIH_BagSlots_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_BagSlots_Backdrop = WM:CreateControl("RAEIH_BagSlots_Backdrop", RAEIH_BagSlots, CT_BACKDROP)
		RAEIH_BagSlots_Backdrop:SetAnchorFill(RAEIH_BagSlots)
		RAEIH_BagSlots_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_BagSlots_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetBagSlots()

	local clrDft = "|c" .. RAEIH.SavedVars.BagSlotsDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.BagSlotsAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.BagSlotsWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.BagSlotsNormalColour
	local clr = clrDft

	local totalSlots = GetBagSize(BAG_BACKPACK)
	local usedSlots = GetNumBagUsedSlots(BAG_BACKPACK)
	local freeSlots = GetNumBagFreeSlots(BAG_BACKPACK)

	local usagePercentage = RAEIH.Round(usedSlots / totalSlots * 100)

	if usagePercentage <= 25 then
		clr = clrN
	elseif usagePercentage > 25 and usagePercentage < 75 then
		clr = clrW
	else
		clr = clrA
	end

	if RAEIH.SavedVars.BagSlotsFormat == "Used/Total (Free)" then
		RAEIH.BagSlotsText = clr .. usedSlots .. clrDft .. "/" .. totalSlots .. " (F: " .. clr .. freeSlots .. clrDft .. ")"
	elseif RAEIH.SavedVars.BagSlotsFormat == "Used/Total" then
		RAEIH.BagSlotsText = clr .. usedSlots .. clrDft .. "/" .. totalSlots
	elseif RAEIH.SavedVars.BagSlotsFormat == "Free/Total" then
		RAEIH.BagSlotsText = clr .. freeSlots .. clrDft .. "/" .. totalSlots
	end
	RAEIH_BagSlots_String:SetText(RAEIH.BagSlotsText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatBagSlots()

	local font = LMP:Fetch('font', RAEIH.SavedVars.BagSlotsFont)
	local size = RAEIH.SavedVars.BagSlotsFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.BagSlotsFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_BagSlots_String:SetFont(fontFormat)

end

function RAEIH.OrganizeBagSlots()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.BagSlotsX
	local mY = RAEIH.SavedVars.BagSlotsY
	local mW = RAEIH.SavedVars.BagSlotsIconW + RAEIH_BagSlots_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.BagSlotsIconH
	local iX = RAEIH.SavedVars.BagSlotsIconX
	local iY = RAEIH.SavedVars.BagSlotsIconY
	local iW = RAEIH.SavedVars.BagSlotsIconW
	local iH = RAEIH.SavedVars.BagSlotsIconH
	local bA = RAEIH.SavedVars.BagSlotsBA
	-- Update General Dimensions
	RAEIH_BagSlots:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_BagSlots_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_BagSlots_Icon:ClearAnchors()
	RAEIH_BagSlots_Icon:SetSimpleAnchor(RAEIH_BagSlots, iX, iY)
	-- Update String Anchor
	RAEIH_BagSlots_String:ClearAnchors()
	RAEIH_BagSlots_String:SetSimpleAnchor(RAEIH_BagSlots, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_BagSlots_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingBagSlots()
	RAEIH_BagSlots:StartMoving()
end

function RAEIH.StopMovingBagSlots()
	RAEIH_BagSlots:StopMovingOrResizing()
	RAEIH.SavedVars.BagSlotsX = RAEIH_BagSlots:GetLeft()
	RAEIH.SavedVars.BagSlotsY = RAEIH_BagSlots:GetTop()
end