local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateBankSlots()
	local WM = GetWindowManager()
	if RAEIH_BankSlots == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.BankSlotsX
		local mY = RAEIH.SavedVars.BankSlotsY
		local mW = RAEIH.SavedVars.BankSlotsIconW + 10
		local mH = RAEIH.SavedVars.BankSlotsIconH
		local iX = RAEIH.SavedVars.BankSlotsIconX
		local iY = RAEIH.SavedVars.BankSlotsIconY
		local iW = RAEIH.SavedVars.BankSlotsIconW
		local iH = RAEIH.SavedVars.BankSlotsIconH
		local bA = RAEIH.SavedVars.BankSlotsBA
		-- Main Placeholder
		RAEIH_BankSlots = WM:CreateTopLevelWindow("RAEIH_BankSlots")
		RAEIH_BankSlots:SetClampedToScreen(true)
		RAEIH_BankSlots:SetDrawLevel(1)
		RAEIH_BankSlots:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_BankSlots:SetMouseEnabled(true)
		RAEIH_BankSlots:SetMovable(not RAEIH.SavedVars.LockBankSlots)
		RAEIH_BankSlots:SetHandler("OnReceiveDrag", RAEIH.StartMovingBankSlots)
		RAEIH_BankSlots:SetHandler("OnMouseUp", RAEIH.StopMovingBankSlots)
		RAEIH_BankSlots:SetHidden(not RAEIH.SavedVars.ShowBankSlots)
		-- Icon
		RAEIH_BankSlots_Icon = WM:CreateControl("RAEIH_BankSlots_Icon", RAEIH_BankSlots, CT_TEXTURE)
		RAEIH_BankSlots_Icon:SetTexture(RAEIH.Icons.BankSlots)
		RAEIH_BankSlots_Icon:SetDimensions(iW, iH)
		RAEIH_BankSlots_Icon:SetSimpleAnchor(RAEIH_BankSlots, iX, iY)
		-- String
		RAEIH_BankSlots_String = WM:CreateControl("RAEIH_BankSlots_String", RAEIH_BankSlots, CT_LABEL)
		RAEIH_BankSlots_String:SetSimpleAnchor(RAEIH_BankSlots, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_BankSlots_String:SetHorizontalAlignment(CENTER)
		RAEIH_BankSlots_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_BankSlots_Backdrop = WM:CreateControl("RAEIH_BankSlots_Backdrop", RAEIH_BankSlots, CT_BACKDROP)
		RAEIH_BankSlots_Backdrop:SetAnchorFill(RAEIH_BankSlots)
		RAEIH_BankSlots_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_BankSlots_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetBankSlots()

	local clrDft = "|c" .. RAEIH.SavedVars.BankSlotsDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.BankSlotsAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.BankSlotsWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.BankSlotsNormalColour
	local clr = clrDft

--	local totalSlots = GetBagSize(BAG_BANK) --Psyche: This line did not calculate ESO+ members total bank space accurately.
	local totalSlots = GetBagSize(BAG_BANK) + GetBagUseableSize(BAG_SUBSCRIBER_BANK) --Fixed.
--	local usedSlots = GetNumBagUsedSlots(BAG_BANK) ----Psyche: This line did not calculate ESO+ members used space accurately.
	local usedSlots = GetNumBagUsedSlots(BAG_BANK) + GetNumBagUsedSlots(BAG_SUBSCRIBER_BANK) --Fixed.
--	local freeSlots = GetNumBagFreeSlots(BAG_BANK) --Psyche: This line did not calculate ESO+ members available space accurately.
	local freeSlots = totalSlots - usedSlots --Fixed.

	local usagePercentage = RAEIH.Round(usedSlots / totalSlots * 100)

	if usagePercentage <= 25 then
		clr = clrN
	elseif usagePercentage > 25 and usagePercentage < 75 then
		clr = clrW
	else
		clr = clrA
	end

	if RAEIH.SavedVars.BankSlotsFormat == "Used/Total (Free)" then
		RAEIH.BankSlotsText = clr .. usedSlots .. clrDft .. "/" .. totalSlots .. " (F: " .. clr .. freeSlots .. clrDft .. ")"
	elseif RAEIH.SavedVars.BankSlotsFormat == "Used/Total" then
		RAEIH.BankSlotsText = clr .. usedSlots .. clrDft .. "/" .. totalSlots
	elseif RAEIH.SavedVars.BankSlotsFormat == "Free/Total" then
		RAEIH.BankSlotsText = clr .. freeSlots .. clrDft .. "/" .. totalSlots
	end
	RAEIH_BankSlots_String:SetText(RAEIH.BankSlotsText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatBankSlots()

	local font = LMP:Fetch('font', RAEIH.SavedVars.BankSlotsFont)
	local size = RAEIH.SavedVars.BankSlotsFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.BankSlotsFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_BankSlots_String:SetFont(fontFormat)

end

function RAEIH.OrganizeBankSlots()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.BankSlotsX
	local mY = RAEIH.SavedVars.BankSlotsY
	local mW = RAEIH.SavedVars.BankSlotsIconW + RAEIH_BankSlots_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.BankSlotsIconH
	local iX = RAEIH.SavedVars.BankSlotsIconX
	local iY = RAEIH.SavedVars.BankSlotsIconY
	local iW = RAEIH.SavedVars.BankSlotsIconW
	local iH = RAEIH.SavedVars.BankSlotsIconH
	local bA = RAEIH.SavedVars.BankSlotsBA
	-- Update General Dimensions
	RAEIH_BankSlots:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_BankSlots_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_BankSlots_Icon:ClearAnchors()
	RAEIH_BankSlots_Icon:SetSimpleAnchor(RAEIH_BankSlots, iX, iY)
	-- Update String Anchor
	RAEIH_BankSlots_String:ClearAnchors()
	RAEIH_BankSlots_String:SetSimpleAnchor(RAEIH_BankSlots, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_BankSlots_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingBankSlots()
	RAEIH_BankSlots:StartMoving()
end

function RAEIH.StopMovingBankSlots()
	RAEIH_BankSlots:StopMovingOrResizing()
	RAEIH.SavedVars.BankSlotsX = RAEIH_BankSlots:GetLeft()
	RAEIH.SavedVars.BankSlotsY = RAEIH_BankSlots:GetTop()
end