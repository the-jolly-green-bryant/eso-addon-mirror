local LMP = RAEIH.LMP
local uTag = "player"
local iconGold = zo_iconFormat("esoui/art/currency/currency_gold.dds", 16, 16)

function RAEIH.CreateThievery()
	local WM = GetWindowManager()
	if RAEIH_Thievery == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.ThieveryX
		local mY = RAEIH.SavedVars.ThieveryY
		local mW = RAEIH.SavedVars.ThieveryIconW + 10
		local mH = RAEIH.SavedVars.ThieveryIconH
		local iX = RAEIH.SavedVars.ThieveryIconX
		local iY = RAEIH.SavedVars.ThieveryIconY
		local iW = RAEIH.SavedVars.ThieveryIconW
		local iH = RAEIH.SavedVars.ThieveryIconH
		local bA = RAEIH.SavedVars.ThieveryBA
		-- Main Placeholder
		RAEIH_Thievery = WM:CreateTopLevelWindow("RAEIH_Thievery")
		RAEIH_Thievery:SetClampedToScreen(true)
		RAEIH_Thievery:SetDrawLevel(1)
		RAEIH_Thievery:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_Thievery:SetMouseEnabled(true)
		RAEIH_Thievery:SetMovable(not RAEIH.SavedVars.LockThievery)
		RAEIH_Thievery:SetHandler("OnReceiveDrag", RAEIH.StartMovingThievery)
		RAEIH_Thievery:SetHandler("OnMouseUp", RAEIH.StopMovingThievery)
		RAEIH_Thievery:SetHidden(not RAEIH.SavedVars.ShowThievery)
		-- Icon
		RAEIH_Thievery_Icon = WM:CreateControl("RAEIH_Thievery_Icon", RAEIH_Thievery, CT_TEXTURE)
		RAEIH_Thievery_Icon:SetTexture(RAEIH.Icons.Thievery)
		RAEIH_Thievery_Icon:SetDimensions(iW, iH)
		RAEIH_Thievery_Icon:SetSimpleAnchor(RAEIH_Thievery, iX, iY)
		-- String
		RAEIH_Thievery_String = WM:CreateControl("RAEIH_Thievery_String", RAEIH_Thievery, CT_LABEL)
		RAEIH_Thievery_String:SetSimpleAnchor(RAEIH_Thievery, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_Thievery_String:SetHorizontalAlignment(CENTER)
		RAEIH_Thievery_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_Thievery_Backdrop = WM:CreateControl("RAEIH_Thievery_Backdrop", RAEIH_Thievery, CT_BACKDROP)
		RAEIH_Thievery_Backdrop:SetAnchorFill(RAEIH_Thievery)
		RAEIH_Thievery_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_Thievery_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetThievery()

	local clrDft = "|c" .. RAEIH.SavedVars.ThieveryDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.ThieveryAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.ThieveryWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.ThieveryNormalColour
	local clrG = "|c" .. RAEIH.SavedVars.ThieveryGoldColour
	local clrFE = clrDft
	local clrSE = clrDft

--	local rae_bagID = 1
--	local rae_slots = PLAYER_INVENTORY.inventories[rae_bagID].slots
	local rae_bagID = BAG_BACKPACK
	local rae_slots = PLAYER_INVENTORY.inventories[rae_bagID].slots[1]

	local rae_stItCount = 0
	local rae_siTotalValue = 0

-----------------------------------------------------------------------------------------------------------------
	--New values to help calculate the total stolen items value (including the Thieves Guild haggling bonus).
    local hagglingBonus = GetNonCombatBonus(NON_COMBAT_BONUS_HAGGLING)
    local hasHagglingBonus = GetNonCombatBonus(NON_COMBAT_BONUS_HAGGLING) > 0
-----------------------------------------------------------------------------------------------------------------

	for i, slot in pairs(rae_slots) do

		local rae_isStolen = IsItemStolen(rae_bagID, i)

		if rae_isStolen == true then
			-- local rae_siName = GetItemName(rae_bagID, i)
			local rae_siTx, rae_siStack, rae_siValue = GetItemInfo(rae_bagID, i)
			local rae_siLastValue = rae_siStack * rae_siValue
			
-----------------------------------------------------------------------------------------------------------------
			--Psyche: If the player has haggling skill then calculate the new total stolen item value accordingly..
			if hasHagglingBonus then
				local originaltotalvalue = rae_siTotalValue + rae_siLastValue --total without bonus.
				rae_siTotalValue = math.floor(originaltotalvalue + rae_siLastValue / 100 * hagglingBonus) --add the bonus on top of that total.
			else
				rae_siTotalValue = rae_siTotalValue + rae_siLastValue --total without bonus.
			end
-----------------------------------------------------------------------------------------------------------------

			rae_stItCount = rae_stItCount + rae_siStack
		end
	end

	local rae_fTotal, rae_fUsed = GetFenceLaunderTransactionInfo()
	local rae_sTotal, rae_sUsed = GetFenceSellTransactionInfo()

	local fePerc = RAEIH.Round(rae_fUsed / rae_fTotal * 100)
	local sePerc = RAEIH.Round(rae_sUsed / rae_sTotal * 100)

	if fePerc <= 25 then
		clrFE = clrN
	elseif fePerc > 25 and fePerc < 75 then
		clrFE = clrW
	else
		clrFE = clrA
	end

	if sePerc <= 25 then
		clrSE = clrN
	elseif sePerc > 25 and sePerc < 75 then
		clrSE = clrW
	else
		clrSE = clrA
	end

	if rae_stItCount == 0 then
		clr = clrN
	elseif rae_stItCount > 0 and rae_stItCount < 40 then
		clr = clrW
	else
		clr = clrA
	end

	if RAEIH.SavedVars.TSFormat == "Point (.)" then rae_siTotalValue = RAEIH.ThousandsSeparatorPoint(rae_siTotalValue)
	else rae_siTotalValue = RAEIH.ThousandsSeparatorComma(rae_siTotalValue) end

	if RAEIH.SavedVars.ThieveryFormat == "SI (TV) » US/TS - UF/TF" then
		RAEIH.ThieveryText = clr .. rae_stItCount .. clrDft .. " (" .. clrG .. rae_siTotalValue .. iconGold .. clrDft .. ") » S: " .. clrSE .. rae_sUsed .. clrDft .. "/" .. clrSE .. rae_sTotal .. clrDft .. " - F: " .. clrFE .. rae_fUsed .. clrDft .. "/" .. clrFE .. rae_fTotal
	elseif RAEIH.SavedVars.ThieveryFormat == "SI (TV) » US/TS" then
		RAEIH.ThieveryText = clr .. rae_stItCount .. clrDft .. " (" .. clrG .. rae_siTotalValue .. iconGold .. clrDft .. ") » S: " .. clrSE .. rae_sUsed .. clrDft .. "/" .. clrSE .. rae_sTotal
	elseif RAEIH.SavedVars.ThieveryFormat == "SI (TV) » UF/TF" then
		RAEIH.ThieveryText = clr .. rae_stItCount .. clrDft .. " (" .. clrG .. rae_siTotalValue .. iconGold .. clrDft .. ") » F: " .. clrFE .. rae_fUsed .. clrDft .. "/" .. clrFE .. rae_fTotal
	elseif RAEIH.SavedVars.ThieveryFormat == "US/TS - UF/TF" then
		RAEIH.ThieveryText = clrDft .. "S: " .. clrSE .. rae_sUsed .. clrDft .. "/" .. clrSE .. rae_sTotal .. clrDft .. " - F: " .. clrFE .. rae_fUsed .. clrDft .. "/" .. clrFE .. rae_fTotal
	elseif RAEIH.SavedVars.ThieveryFormat == "SI (TV)" then
		RAEIH.ThieveryText = clr .. rae_stItCount .. clrDft .. " (" .. clrG .. rae_siTotalValue .. iconGold .. clrDft .. ")"
	end
	RAEIH_Thievery_String:SetText(RAEIH.ThieveryText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatThievery()

	local font = LMP:Fetch('font', RAEIH.SavedVars.ThieveryFont)
	local size = RAEIH.SavedVars.ThieveryFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.ThieveryFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_Thievery_String:SetFont(fontFormat)

end

function RAEIH.OrganizeThievery()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.ThieveryX
	local mY = RAEIH.SavedVars.ThieveryY
	local mW = RAEIH.SavedVars.ThieveryIconW + RAEIH_Thievery_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.ThieveryIconH
	local iX = RAEIH.SavedVars.ThieveryIconX
	local iY = RAEIH.SavedVars.ThieveryIconY
	local iW = RAEIH.SavedVars.ThieveryIconW
	local iH = RAEIH.SavedVars.ThieveryIconH
	local bA = RAEIH.SavedVars.ThieveryBA
	-- Update General Dimensions
	RAEIH_Thievery:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_Thievery_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_Thievery_Icon:ClearAnchors()
	RAEIH_Thievery_Icon:SetSimpleAnchor(RAEIH_Thievery, iX, iY)
	-- Update String Anchor
	RAEIH_Thievery_String:ClearAnchors()
	RAEIH_Thievery_String:SetSimpleAnchor(RAEIH_Thievery, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_Thievery_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingThievery()
	RAEIH_Thievery:StartMoving()
end

function RAEIH.StopMovingThievery()
	RAEIH_Thievery:StopMovingOrResizing()
	RAEIH.SavedVars.ThieveryX = RAEIH_Thievery:GetLeft()
	RAEIH.SavedVars.ThieveryY = RAEIH_Thievery:GetTop()
end