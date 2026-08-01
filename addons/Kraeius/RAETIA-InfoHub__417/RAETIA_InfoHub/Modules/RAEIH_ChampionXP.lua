local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateChampionXP()
	local WM = GetWindowManager()
	if RAEIH_ChampionXP == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.ChampionXPX
		local mY = RAEIH.SavedVars.ChampionXPY
		local mW = RAEIH.SavedVars.ChampionXPIconW + 10
		local mH = RAEIH.SavedVars.ChampionXPIconH
		local iX = RAEIH.SavedVars.ChampionXPIconX
		local iY = RAEIH.SavedVars.ChampionXPIconY
		local iW = RAEIH.SavedVars.ChampionXPIconW
		local iH = RAEIH.SavedVars.ChampionXPIconH
		local bA = RAEIH.SavedVars.ChampionXPBA
		-- Main Placeholder
		RAEIH_ChampionXP = WM:CreateTopLevelWindow("RAEIH_ChampionXP")
		RAEIH_ChampionXP:SetClampedToScreen(true)
		RAEIH_ChampionXP:SetDrawLevel(1)
		RAEIH_ChampionXP:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_ChampionXP:SetMouseEnabled(true)
		RAEIH_ChampionXP:SetMovable(not RAEIH.SavedVars.LockChampionXP)
		RAEIH_ChampionXP:SetHandler("OnReceiveDrag", RAEIH.StartMovingChampionXP)
		RAEIH_ChampionXP:SetHandler("OnMouseUp", RAEIH.StopMovingChampionXP)
		RAEIH_ChampionXP:SetHidden(not RAEIH.SavedVars.ShowChampionXP)
		-- Icon
		RAEIH_ChampionXP_Icon = WM:CreateControl("RAEIH_ChampionXP_Icon", RAEIH_ChampionXP, CT_TEXTURE)
		RAEIH_ChampionXP_Icon:SetTexture(RAEIH.Icons.ChampionXP)
		RAEIH_ChampionXP_Icon:SetDimensions(iW, iH)
		RAEIH_ChampionXP_Icon:SetSimpleAnchor(RAEIH_ChampionXP, iX, iY)
		-- String
		RAEIH_ChampionXP_String = WM:CreateControl("RAEIH_ChampionXP_String", RAEIH_ChampionXP, CT_LABEL)
		RAEIH_ChampionXP_String:SetSimpleAnchor(RAEIH_ChampionXP, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_ChampionXP_String:SetHorizontalAlignment(CENTER)
		RAEIH_ChampionXP_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_ChampionXP_Backdrop = WM:CreateControl("RAEIH_ChampionXP_Backdrop", RAEIH_ChampionXP, CT_BACKDROP)
		RAEIH_ChampionXP_Backdrop:SetAnchorFill(RAEIH_ChampionXP)
		RAEIH_ChampionXP_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_ChampionXP_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end

	RAEIH.IsChUnlocked = IsChampionSystemUnlocked()
end

function RAEIH.SetChampionXP()

	if RAEIH.IsChUnlocked == true then

		local clrDft = "|c" .. RAEIH.SavedVars.ChampionXPDefaultColour
		local clrES = "|c" .. RAEIH.SavedVars.ChampionXPESColour
		local clrMS = "|c" .. RAEIH.SavedVars.ChampionXPMSColour
		local clrLS = "|c" .. RAEIH.SavedVars.ChampionXPLSColour
		local clrEN = "|c" .. RAEIH.SavedVars.ChampionXPENColour
		local clr = clrDft
		
		local uP = 0
		local att = 1
		
		while att <= 3 do
			uP = uP + GetNumUnspentChampionPoints(att)
			att = att + 1
		end		

		local chXP = GetPlayerChampionXP()
		local chPTEarned = GetPlayerChampionPointsEarned()
		local chXPMax = GetNumChampionXPInChampionPoint(chPTEarned)
------------------------------------------------------------------------------------------------------------
--Psyche: Temporarily removed constellation group names from 'RAEIH_ChampionXP' module (causing errors).
------------------------------------------------------------------------------------------------------------
--		local chAttRank = GetChampionPointAttributeForRank(chPTEarned + 1) --Broken function.
--		local chAttRank = GetChampionPointPoolForRank(chPTEarned + 1) --Fixed.
--		local chNextSign = ZO_Champion_GetConstellationGroupNameFromAttribute(chAttRank) -- "Warrior", "Thief" or "Mage" | Broken function.
--		local chNextSign = ZO_Champion_GetUnformattedConstellationGroupNameFromAttribute(chAttRank) --WIP fix.
--		chNextSign = RAEIH.NormString(chNextSign)
------------------------------------------------------------------------------------------------------------

		if uP > 0 then chPTEarned = (chPTEarned - uP) .. clrDft .. "+" .. clrMS .. uP end
		if chXPMax == nil then chXPMax = 400000 end

		local chXPPerc = RAEIH.Round(chXP / chXPMax * 100)
		
		if chXPPerc > 75 then
			clr = clrLS
		elseif chXPPerc <= 75 and chXPPerc >= 25 then
			clr = clrMS
		else
			clr = clrES
		end

		if RAEIH.SavedVars.TSFormat == "Point (.)" then
			chXP = RAEIH.ThousandsSeparatorPoint(chXP)
			chXPMax = RAEIH.ThousandsSeparatorPoint(chXPMax)
			chXPPerc = string.gsub(tostring(chXPPerc), "%.", ",") .. "%"
		else
			chXP = RAEIH.ThousandsSeparatorComma(chXP)
			chXPMax = RAEIH.ThousandsSeparatorComma(chXPMax)
			chXPPerc = tostring(chXPPerc) .. "%"
		end

		local enXP = GetEnlightenedPool()		
		
		if enXP == 0 then

------------------------------------------------------------------------------------------------------------
--Psyche: Temporarily removed constellation group names from 'RAEIH_ChampionXP' module (causing errors).
------------------------------------------------------------------------------------------------------------
--			if RAEIH.SavedVars.ChampionXPFormat == "CP » Current/Max (%) » Sign" then
--				RAEIH.ChampionXPText = clr .. chPTEarned .. clrDft .. " » CXP: " .. clr .. chXP .. clrDft .. "/" .. chXPMax .. " (" .. clr .. chXPPerc .. clrDft .. ") » " .. clr .. chNextSign
--				RAEIH.ChampionXPText = clr .. chPTEarned .. clrDft .. " » CXP: " .. clr .. chXP .. clrDft .. "/" .. chXPMax .. " (" .. clr .. chXPPerc .. clrDft .. ") » " .. clr
--			elseif RAEIH.SavedVars.ChampionXPFormat == "CP » Current/Max (%)" then
			if RAEIH.SavedVars.ChampionXPFormat == "CP » Current/Max (%)" then
				RAEIH.ChampionXPText = clr .. chPTEarned .. clrDft .. " » CXP: " .. clr .. chXP .. clrDft .. "/" .. chXPMax .. " (" .. clr .. chXPPerc .. clrDft .. ")"
--			elseif RAEIH.SavedVars.ChampionXPFormat == "(CP) Current/Max » Sign" then
--				RAEIH.ChampionXPText = clrDft .. "(" .. clr .. chPTEarned .. clrDft .. ") CXP: " .. clr .. chXP .. clrDft .. "/" .. chXPMax .. clrDft .. " » " .. clr .. chNextSign
--				RAEIH.ChampionXPText = clrDft .. "(" .. clr .. chPTEarned .. clrDft .. ") CXP: " .. clr .. chXP .. clrDft .. "/" .. chXPMax .. clrDft .. " » " .. clr
			elseif RAEIH.SavedVars.ChampionXPFormat == "(CP) Current/Max" then
				RAEIH.ChampionXPText = clrDft .. "(" .. clr .. chPTEarned .. clrDft .. ") CXP: " .. clr .. chXP .. clrDft .. "/" .. chXPMax
--			elseif RAEIH.SavedVars.ChampionXPFormat == "CP » % » Sign" then
--				RAEIH.ChampionXPText = clr .. chPTEarned .. clrDft .. " » CXP: " .. clr .. chXPPerc .. clrDft .. " » " .. clr .. chNextSign
--				RAEIH.ChampionXPText = clr .. chPTEarned .. clrDft .. " » CXP: " .. clr .. chXPPerc .. clrDft .. " » " .. clr
			else
				RAEIH.ChampionXPText = clr .. chPTEarned .. clrDft .. " » CXP: " .. clr .. chXPPerc
			end

		elseif enXP ~= 0 then

			if RAEIH.SavedVars.TSFormat == "Point (.)" then
				enXP = RAEIH.ThousandsSeparatorPoint(enXP)
			else
				enXP = RAEIH.ThousandsSeparatorComma(enXP)
			end

--			if RAEIH.SavedVars.ChampionXPFormat == "CP » Current/Max (%) » Sign" then
--				RAEIH.ChampionXPText = clr .. chPTEarned .. clrDft .. " » CXP: " .. clr .. chXP .. clrDft .. "/" .. chXPMax .. " (" .. clr .. chXPPerc .. clrDft .. ") {EN: " .. clrEN .. enXP .. clrDft .. "} » " .. clr .. chNextSign
--				RAEIH.ChampionXPText = clr .. chPTEarned .. clrDft .. " » CXP: " .. clr .. chXP .. clrDft .. "/" .. chXPMax .. " (" .. clr .. chXPPerc .. clrDft .. ") {EN: " .. clrEN .. enXP .. clrDft .. "} » " .. clr
--			elseif RAEIH.SavedVars.ChampionXPFormat == "CP » Current/Max (%)" then
			if RAEIH.SavedVars.ChampionXPFormat == "CP » Current/Max (%)" then
				RAEIH.ChampionXPText = clr .. chPTEarned .. clrDft .. " » CXP: " .. clr .. chXP .. clrDft .. "/" .. chXPMax .. " (" .. clr .. chXPPerc .. clrDft .. ") {EN: " .. clrEN .. enXP .. clrDft .. "}"
--			elseif RAEIH.SavedVars.ChampionXPFormat == "(CP) Current/Max » Sign" then
--				RAEIH.ChampionXPText = clrDft .. "(" .. clr .. chPTEarned .. clrDft .. ") CXP: " .. clr .. chXP .. clrDft .. "/" .. chXPMax .. clrDft .. " (EN: " .. clrEN .. enXP .. clrDft .. ") » " .. clr .. chNextSign
--				RAEIH.ChampionXPText = clrDft .. "(" .. clr .. chPTEarned .. clrDft .. ") CXP: " .. clr .. chXP .. clrDft .. "/" .. chXPMax .. clrDft .. " (EN: " .. clrEN .. enXP .. clrDft .. ") » " .. clr
			elseif RAEIH.SavedVars.ChampionXPFormat == "(CP) Current/Max" then
				RAEIH.ChampionXPText = clrDft .. "(" .. clr .. chPTEarned .. clrDft .. ") CXP: " .. clr .. chXP .. clrDft .. "/" .. chXPMax .. " (EN: " .. clrEN .. enXP .. clrDft .. ")"
--			elseif RAEIH.SavedVars.ChampionXPFormat == "CP » % » Sign" then
--				RAEIH.ChampionXPText = clr .. chPTEarned .. clrDft .. " » CXP: " .. clr .. chXPPerc .. clrDft .. " (EN: " .. clrEN .. enXP .. clrDft .. ") » " .. clr .. chNextSign
--				RAEIH.ChampionXPText = clr .. chPTEarned .. clrDft .. " » CXP: " .. clr .. chXPPerc .. clrDft .. " (EN: " .. clrEN .. enXP .. clrDft .. ") » " .. clr
			else
				RAEIH.ChampionXPText = clr .. chPTEarned .. clrDft .. " » CXP: " .. clr .. chXPPerc .. clrDft .. " (EN: " .. clrEN .. enXP .. clrDft .. ")"
			end
------------------------------------------------------------------------------------------------------------
		end	
		RAEIH_ChampionXP_String:SetText(RAEIH.ChampionXPText)
		RAEIH.OrganizeLegatus()

	else

		local clr = "|c" .. RAEIH.SavedVars.ChampionXPESColour
		RAEIH.ChampionXPText = clr .. "Locked"
		RAEIH_ChampionXP_String:SetText(RAEIH.ChampionXPText)
		RAEIH.OrganizeLegatus()

	end
end

function RAEIH.FormatChampionXP()

	local font = LMP:Fetch('font', RAEIH.SavedVars.ChampionXPFont)
	local size = RAEIH.SavedVars.ChampionXPFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.ChampionXPFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_ChampionXP_String:SetFont(fontFormat)

end

function RAEIH.OrganizeChampionXP()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.ChampionXPX
	local mY = RAEIH.SavedVars.ChampionXPY
	local mW = RAEIH.SavedVars.ChampionXPIconW + RAEIH_ChampionXP_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.ChampionXPIconH
	local iX = RAEIH.SavedVars.ChampionXPIconX
	local iY = RAEIH.SavedVars.ChampionXPIconY
	local iW = RAEIH.SavedVars.ChampionXPIconW
	local iH = RAEIH.SavedVars.ChampionXPIconH
	local bA = RAEIH.SavedVars.ChampionXPBA
	-- Update General Dimensions
	RAEIH_ChampionXP:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_ChampionXP_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_ChampionXP_Icon:ClearAnchors()
	RAEIH_ChampionXP_Icon:SetSimpleAnchor(RAEIH_ChampionXP, iX, iY)
	-- Update String Anchor
	RAEIH_ChampionXP_String:ClearAnchors()
	RAEIH_ChampionXP_String:SetSimpleAnchor(RAEIH_ChampionXP, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_ChampionXP_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingChampionXP()
	RAEIH_ChampionXP:StartMoving()
end

function RAEIH.StopMovingChampionXP()
	RAEIH_ChampionXP:StopMovingOrResizing()
	RAEIH.SavedVars.ChampionXPX = RAEIH_ChampionXP:GetLeft()
	RAEIH.SavedVars.ChampionXPY = RAEIH_ChampionXP:GetTop()
end