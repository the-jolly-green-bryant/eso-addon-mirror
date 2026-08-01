local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateCraftingXP()
	local WM = GetWindowManager()
	if RAEIH_CraftingXP == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.CraftingXPX
		local mY = RAEIH.SavedVars.CraftingXPY
		local mW = RAEIH.SavedVars.CraftingXPIconW + 10
		local mH = RAEIH.SavedVars.CraftingXPIconH
		local iX = RAEIH.SavedVars.CraftingXPIconX
		local iY = RAEIH.SavedVars.CraftingXPIconY
		local iW = RAEIH.SavedVars.CraftingXPIconW
		local iH = RAEIH.SavedVars.CraftingXPIconH
		local bA = RAEIH.SavedVars.CraftingXPBA
		-- Main Placeholder
		RAEIH_CraftingXP = WM:CreateTopLevelWindow("RAEIH_CraftingXP")
		RAEIH_CraftingXP:SetClampedToScreen(true)
		RAEIH_CraftingXP:SetDrawLevel(1)
		RAEIH_CraftingXP:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_CraftingXP:SetMouseEnabled(true)
		RAEIH_CraftingXP:SetMovable(not RAEIH.SavedVars.LockCraftingXP)
		RAEIH_CraftingXP:SetHandler("OnReceiveDrag", RAEIH.StartMovingCraftingXP)
		RAEIH_CraftingXP:SetHandler("OnMouseUp", RAEIH.StopMovingCraftingXP)
		RAEIH_CraftingXP:SetHidden(not RAEIH.SavedVars.ShowCraftingXP)
		-- Icon
		RAEIH_CraftingXP_Icon = WM:CreateControl("RAEIH_CraftingXP_Icon", RAEIH_CraftingXP, CT_TEXTURE)
		RAEIH_CraftingXP_Icon:SetTexture(RAEIH.Icons.CraftingXP)
		RAEIH_CraftingXP_Icon:SetDimensions(iW, iH)
		RAEIH_CraftingXP_Icon:SetSimpleAnchor(RAEIH_CraftingXP, iX, iY)
		-- String
		RAEIH_CraftingXP_String = WM:CreateControl("RAEIH_CraftingXP_String", RAEIH_CraftingXP, CT_LABEL)
		RAEIH_CraftingXP_String:SetSimpleAnchor(RAEIH_CraftingXP, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_CraftingXP_String:SetHorizontalAlignment(CENTER)
		RAEIH_CraftingXP_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_CraftingXP_Backdrop = WM:CreateControl("RAEIH_CraftingXP_Backdrop", RAEIH_CraftingXP, CT_BACKDROP)
		RAEIH_CraftingXP_Backdrop:SetAnchorFill(RAEIH_CraftingXP)
		RAEIH_CraftingXP_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_CraftingXP_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetCraftingXP(eventCode, skillType, skillIndex, reason, rank, previousXP, currentXP)

	local clrDft = "|c" .. RAEIH.SavedVars.CraftingXPDefaultColour
	local clrV = "|c" .. RAEIH.SavedVars.CraftingXPValueColour
	RAEIH.CraftingXPText = clrDft .. "Waiting to Craft"

	if eventCode ~= nil then

		local sType = 8
		local name, rank = GetSkillLineInfo(sType, skillIndex)
		local oldXP, newXP = previousXP, currentXP
		local xpGain = newXP - oldXP

		if RAEIH.SavedVars.TSFormat == "Point (.)" then
			xpGain = RAEIH.ThousandsSeparatorPoint(xpGain)
		else
			xpGain = RAEIH.ThousandsSeparatorComma(xpGain)
		end
		RAEIH.CraftingXPText = clrV .. "+" .. xpGain .. clrDft .. " XP Gained for " .. name .. " (Rank: " .. clrV .. rank .. clrDft .. ")"
	end
	RAEIH_CraftingXP_String:SetText(RAEIH.CraftingXPText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatCraftingXP()

	local font = LMP:Fetch('font', RAEIH.SavedVars.CraftingXPFont)
	local size = RAEIH.SavedVars.CraftingXPFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.CraftingXPFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_CraftingXP_String:SetFont(fontFormat)

end

function RAEIH.OrganizeCraftingXP()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.CraftingXPX
	local mY = RAEIH.SavedVars.CraftingXPY
	local mW = RAEIH.SavedVars.CraftingXPIconW + RAEIH_CraftingXP_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.CraftingXPIconH
	local iX = RAEIH.SavedVars.CraftingXPIconX
	local iY = RAEIH.SavedVars.CraftingXPIconY
	local iW = RAEIH.SavedVars.CraftingXPIconW
	local iH = RAEIH.SavedVars.CraftingXPIconH
	local bA = RAEIH.SavedVars.CraftingXPBA
	-- Update General Dimensions
	RAEIH_CraftingXP:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_CraftingXP_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_CraftingXP_Icon:ClearAnchors()
	RAEIH_CraftingXP_Icon:SetSimpleAnchor(RAEIH_CraftingXP, iX, iY)
	-- Update String Anchor
	RAEIH_CraftingXP_String:ClearAnchors()
	RAEIH_CraftingXP_String:SetSimpleAnchor(RAEIH_CraftingXP, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_CraftingXP_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingCraftingXP()
	RAEIH_CraftingXP:StartMoving()
end

function RAEIH.StopMovingCraftingXP()
	RAEIH_CraftingXP:StopMovingOrResizing()
	RAEIH.SavedVars.CraftingXPX = RAEIH_CraftingXP:GetLeft()
	RAEIH.SavedVars.CraftingXPY = RAEIH_CraftingXP:GetTop()
end