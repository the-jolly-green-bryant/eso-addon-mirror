local LMP = RAEIH.LMP
local uTag = "player"

RAEIH.AWCMWList = {
	-- Bow
	55973,
	55967,
	55937,
	55997,
	55991,
	55985,
	55979,
	-- Dagger
	55996,
	55990,
	55984,
	55978,
	55972,
	55966,
	55936,
	-- Greatsword
	55994,
	55988,
	55982,
	55976,
	55970,
	55964,
	55934,
	-- Ice Staff
	57449,
	57450,
	57451,
	57452,
	57453,
	57448,
	-- Inferno Staff
	55980,
	55974,
	55968,
	55938,
	55998,
	55992,
	55986,
	-- Lightning Staff
	57456,
	57457,
	57458,
	57459,
	57454,
	57455,
	-- Restoration Staff
	55993,
	55987,
	55981,
	55975,
	55969,
	55939,
	55999,
	-- Sword
	55995,
	55989,
	55983,
	55977,
	55971,
	55965,
	55935,
}

function RAEIH.CreateWeaponCharge()
	local WM = GetWindowManager()
	if RAEIH_WeaponCharge == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.WeaponChargeX
		local mY = RAEIH.SavedVars.WeaponChargeY
		local mW = RAEIH.SavedVars.WeaponChargeIconW + 10
		local mH = RAEIH.SavedVars.WeaponChargeIconH
		local iX = RAEIH.SavedVars.WeaponChargeIconX
		local iY = RAEIH.SavedVars.WeaponChargeIconY
		local iW = RAEIH.SavedVars.WeaponChargeIconW
		local iH = RAEIH.SavedVars.WeaponChargeIconH
		local bA = RAEIH.SavedVars.WeaponChargeBA
		-- Main Placeholder
		RAEIH_WeaponCharge = WM:CreateTopLevelWindow("RAEIH_WeaponCharge")
		RAEIH_WeaponCharge:SetClampedToScreen(true)
		RAEIH_WeaponCharge:SetDrawLevel(1)
		RAEIH_WeaponCharge:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_WeaponCharge:SetMouseEnabled(true)
		RAEIH_WeaponCharge:SetMovable(not RAEIH.SavedVars.LockWeaponCharge)
		RAEIH_WeaponCharge:SetHandler("OnReceiveDrag", RAEIH.StartMovingWeaponCharge)
		RAEIH_WeaponCharge:SetHandler("OnMouseUp", RAEIH.StopMovingWeaponCharge)
		RAEIH_WeaponCharge:SetHidden(not RAEIH.SavedVars.ShowWeaponCharge)
		-- Icon
		RAEIH_WeaponCharge_Icon = WM:CreateControl("RAEIH_WeaponCharge_Icon", RAEIH_WeaponCharge, CT_TEXTURE)
		RAEIH_WeaponCharge_Icon:SetTexture(RAEIH.Icons.WeaponCharge)
		RAEIH_WeaponCharge_Icon:SetDimensions(iW, iH)
		RAEIH_WeaponCharge_Icon:SetSimpleAnchor(RAEIH_WeaponCharge, iX, iY)
		-- String
		RAEIH_WeaponCharge_String = WM:CreateControl("RAEIH_WeaponCharge_String", RAEIH_WeaponCharge, CT_LABEL)
		RAEIH_WeaponCharge_String:SetSimpleAnchor(RAEIH_WeaponCharge, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_WeaponCharge_String:SetHorizontalAlignment(CENTER)
		RAEIH_WeaponCharge_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_WeaponCharge_Backdrop = WM:CreateControl("RAEIH_WeaponCharge_Backdrop", RAEIH_WeaponCharge, CT_BACKDROP)
		RAEIH_WeaponCharge_Backdrop:SetAnchorFill(RAEIH_WeaponCharge)
		RAEIH_WeaponCharge_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_WeaponCharge_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

RAEIH.SGtoUse = nil
RAEIH.SGtoUseTier = nil
RAEIH.SGtoUseILink = nil

function RAEIH.GetSoulGemInfo()

	local rae_bagID = BAG_BACKPACK
	local rae_slots = PLAYER_INVENTORY.inventories[rae_bagID].slots
	
	for i, slot in pairs(rae_slots) do

		local rae_isSG = IsItemSoulGem(SOUL_GEM_TYPE_FILLED, rae_bagID, i)		

		if rae_isSG == true and RAEIH.SGtoUse == nil then
			-- d("Soul gem found!")
			-- d("It was nil, processing...")
			local rae_sgTier = GetSoulGemItemInfo(rae_bagID, i)			
			local __, rae_sgStack, __ = GetItemInfo(rae_bagID, i)
			local rae_sgILink = GetItemLink(rae_bagID, i, LINK_STYLE_BRACKETS)
			-- d(rae_sgILink .. " x" .. tostring(rae_sgStack) .. " - Tier: " .. tostring(rae_sgTier))
			if rae_sgTier == 1 then RAEIH.SGtoUse = i RAEIH.SGtoUseTier = rae_sgTier RAEIH.SGtoUseILink = rae_sgILink
			elseif rae_sgTier == 2 then RAEIH.SGtoUse = i RAEIH.SGtoUseTier = rae_sgTier RAEIH.SGtoUseILink = rae_sgILink
			elseif rae_sgTier == 3 then RAEIH.SGtoUse = i RAEIH.SGtoUseTier = rae_sgTier RAEIH.SGtoUseILink = rae_sgILink
			elseif rae_sgTier == 4 then RAEIH.SGtoUse = i RAEIH.SGtoUseTier = rae_sgTier RAEIH.SGtoUseILink = rae_sgILink
			elseif rae_sgTier == 5 then RAEIH.SGtoUse = i RAEIH.SGtoUseTier = rae_sgTier RAEIH.SGtoUseILink = rae_sgILink
			elseif rae_sgTier == 6 then RAEIH.SGtoUse = i RAEIH.SGtoUseTier = rae_sgTier RAEIH.SGtoUseILink = rae_sgILink
			end
		elseif rae_isSG == true and RAEIH.SGtoUse ~= nil then
			-- d("Soul gem found!")
			-- d("It wasnt nil, processing...")
			local rae_sgTier = GetSoulGemItemInfo(rae_bagID, i)			
			local __, rae_sgStack, __ = GetItemInfo(rae_bagID, i)
			local rae_sgILink = GetItemLink(rae_bagID, i, LINK_STYLE_BRACKETS)
			-- d(rae_sgILink .. " x" .. tostring(rae_sgStack) .. " - Tier: " .. tostring(rae_sgTier))
			if rae_sgTier < RAEIH.SGtoUseTier then
				if rae_sgTier == 1 then RAEIH.SGtoUse = i RAEIH.SGtoUseTier = rae_sgTier RAEIH.SGtoUseILink = rae_sgILink
				elseif rae_sgTier == 2 then RAEIH.SGtoUse = i RAEIH.SGtoUseTier = rae_sgTier RAEIH.SGtoUseILink = rae_sgILink
				elseif rae_sgTier == 3 then RAEIH.SGtoUse = i RAEIH.SGtoUseTier = rae_sgTier RAEIH.SGtoUseILink = rae_sgILink
				elseif rae_sgTier == 4 then RAEIH.SGtoUse = i RAEIH.SGtoUseTier = rae_sgTier RAEIH.SGtoUseILink = rae_sgILink
				elseif rae_sgTier == 5 then RAEIH.SGtoUse = i RAEIH.SGtoUseTier = rae_sgTier RAEIH.SGtoUseILink = rae_sgILink
				elseif rae_sgTier == 6 then RAEIH.SGtoUse = i RAEIH.SGtoUseTier = rae_sgTier RAEIH.SGtoUseILink = rae_sgILink
				end
			end
		end
		-- d("After loop, SGtoUse is " .. tostring(RAEIH.SGtoUse) .. " // SGtoUseTier is " .. tostring(RAEIH.SGtoUseTier) .. " // Item is " .. tostring(RAEIH.SGtoUseILink))
	end
end

function RAEIH.SetWeaponCharge()

	local clrDft = "|c" .. RAEIH.SavedVars.WeaponChargeDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.WeaponChargeAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.WeaponChargeWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.WeaponChargeNormalColour
	local clr = clrDft

	local bagID = BAG_WORN
	local activePair, isLocked = GetActiveWeaponPairInfo()
	local mhRCStatus = nil
	local ohRCStatus = nil

	-- Active Pair is One

	if activePair == 1 then

		local isMainhandRC = IsItemChargeable(bagID, 4)
		local isOffhandRC = IsItemChargeable(bagID, 5)

		-- MH: Rechargeable & OH: Not Rechargeable

		if isMainhandRC == true and isOffhandRC == false then

			local mhCC, mhMC = GetChargeInfoForItem(bagID, 4)
			local mhPerc = RAEIH.Round(mhCC / mhMC * 100)

			-- Master Weapon Check

			local mwIL = GetItemLink(bagID, 4)
			local mwID = select(4,ZO_LinkHandler_ParseLink(mwIL))
			local isMW = false

			for i, slot in pairs(RAEIH.AWCMWList) do
				if RAEIH.AWCMWList[i] == mwID then
					isMW = true
				else
					isMW = false
				end
			end

			-- Assign Colour for Current Charge

			if mhPerc < 25 then
				clr = clrA
			elseif mhPerc >= 25 and mhPerc < 75  then
				clr = clrW
			else
				clr = clrN
			end

			if RAEIH.SavedVars.WeaponChargeFormat == "Current/Max (%)" then
				RAEIH.WeaponChargeText = clrDft .. "MH: " .. clr .. mhCC .. clrDft .. "/" .. mhMC .. " (" .. clr .. mhPerc .. "%" .. clrDft .. ")"

			elseif RAEIH.SavedVars.WeaponChargeFormat == "Current/Max" then
				RAEIH.WeaponChargeText = clrDft .. "MH: " .. clr .. mhCC .. clrDft .. "/" .. mhMC

			else
				RAEIH.WeaponChargeText = clrDft .. "MH: " .. clr .. mhPerc .. "%"
			end

			-- Auto Recharge Process

			if RAEIH.SavedVars.AutoChargeWeaponEnabled == true and mhPerc <= RAEIH.SavedVars.AutoChargeWeaponThreshold and isMW == false then
				RAEIH.GetSoulGemInfo()
				if RAEIH.SGtoUse ~= nil then
					ChargeItemWithSoulGem(BAG_WORN, 4, BAG_BACKPACK, RAEIH.SGtoUse)
					local rae_usedSG = GetItemLink(BAG_BACKPACK, RAEIH.SGtoUse, LINK_STYLE_BRACKETS)
					-- d("Mainhand weapon charged with " .. rae_usedSG .. "!")
					if RAEIH.SavedVars.NotificationRecharge == true then
						RAEIH.NotificationText = clrA .. "Mainhand weapon charged with " .. rae_usedSG .. clrA .. "!"
						RAEIH_Notification_String:SetText(RAEIH.NotificationText)
						RAEIH.FirstTextAnim()
						RAEIH.SavedVars.StartNotificationTimer = true
						RAEIH.OrganizeLegatus()
					end
				elseif RAEIH.SGtoUse == nil then
					if RAEIH.SavedVars.NotificationRecharge == true then
						RAEIH.NotificationText = clrA .. "No Soul Gem to charge weapon!"
						RAEIH_Notification_String:SetText(RAEIH.NotificationText)
						RAEIH.FirstTextAnim()
						RAEIH.SavedVars.StartNotificationTimer = true
						RAEIH.OrganizeLegatus()
					end
					-- d("Mainhand weapon can't be charged because there is no filled soul gem to use!")
				end
			end

		-- MH: Not Rechargeable & OH: Rechargeable

		elseif isMainhandRC == false and isOffhandRC == true then
			local clr = nil
			local ohCC, ohMC = GetChargeInfoForItem(bagID, 5)
			local ohPerc = RAEIH.Round(ohCC / ohMC * 100)

			-- Master Weapon Check

			local mwIL = GetItemLink(bagID, 5)
			local mwID = select(4,ZO_LinkHandler_ParseLink(mwIL))
			local isMW = false

			for i, slot in pairs(RAEIH.AWCMWList) do
				if RAEIH.AWCMWList[i] == mwID then
					isMW = true
				else
					isMW = false
				end
			end

			-- Assign Colour for Current Charge

			if ohPerc < 25 then
				clr = clrA
			elseif ohPerc >= 25 and ohPerc < 75  then
				clr = clrW
			else
				clr = clrN
			end

			if RAEIH.SavedVars.WeaponChargeFormat == "Current/Max (%)" then

				RAEIH.WeaponChargeText = clrDft .. "OH: " .. clr .. ohCC .. clrDft .. "/" .. ohMC .. " (" .. clr .. ohPerc .. "%" .. clrDft .. ")"
			elseif RAEIH.SavedVars.WeaponChargeFormat == "Current/Max" then
				RAEIH.WeaponChargeText = clrDft .. "OH: " .. clr .. ohCC .. clrDft .. "/" .. ohMC
			else
				RAEIH.WeaponChargeText = clrDft .. "OH: " .. clr .. ohPerc .. "%"
			end

			-- Auto Recharge Process

			if RAEIH.SavedVars.AutoChargeWeaponEnabled == true and ohPerc <= RAEIH.SavedVars.AutoChargeWeaponThreshold and isMW == false then
				RAEIH.GetSoulGemInfo()
				if RAEIH.SGtoUse ~= nil then
					ChargeItemWithSoulGem(BAG_WORN, 5, BAG_BACKPACK, RAEIH.SGtoUse)
					local rae_usedSG = GetItemLink(BAG_BACKPACK, RAEIH.SGtoUse, LINK_STYLE_BRACKETS)
					-- d("Offhand weapon charged with " .. rae_usedSG .. "!")
					if RAEIH.SavedVars.NotificationRecharge == true then
						RAEIH.NotificationText = clrA .. "Offhand weapon charged with " .. rae_usedSG .. clrA .. "!"
						RAEIH_Notification_String:SetText(RAEIH.NotificationText)
						RAEIH.FirstTextAnim()
						RAEIH.SavedVars.StartNotificationTimer = true
						RAEIH.OrganizeLegatus()
					end
				elseif RAEIH.SGtoUse == nil then
					if RAEIH.SavedVars.NotificationRecharge == true then
						RAEIH.NotificationText = clrA .. "No Soul Gem to charge weapon!"
						RAEIH_Notification_String:SetText(RAEIH.NotificationText)
						RAEIH.FirstTextAnim()
						RAEIH.SavedVars.StartNotificationTimer = true
						RAEIH.OrganizeLegatus()
					end
					-- d("Offhand weapon can't be charged because there is no filled soul gem to use!")
				end
			end

		-- MH: Rechargeable & OH: Rechargeable

		elseif isMainhandRC == true and isOffhandRC == true then
			local clrMH = nil
			local clrOH = nil

			local mhCC, mhMC = GetChargeInfoForItem(bagID, 4)
			local ohCC, ohMC = GetChargeInfoForItem(bagID, 5)

			local ohPerc = RAEIH.Round(ohCC / ohMC * 100)
			local mhPerc = RAEIH.Round(mhCC / mhMC * 100)

			-- Master Weapon Check

			local mwIL1 = GetItemLink(bagID, 4)
			local mwID1 = select(4,ZO_LinkHandler_ParseLink(mwIL1))
			local isMW1 = false

			for i, slot in pairs(RAEIH.AWCMWList) do
				if RAEIH.AWCMWList[i] == mwID1 then
					isMW1 = true
				else
					isMW1 = false
				end
			end

			-- Master Weapon Check 2

			local mwIL2 = GetItemLink(bagID, 5)
			local mwID2 = select(4,ZO_LinkHandler_ParseLink(mwIL2))
			local isMW2 = false

			for i, slot in pairs(RAEIH.AWCMWList) do
				if RAEIH.AWCMWList[i] == mwID2 then
					isMW2 = true
				else
					isMW2 = false
				end
			end

			-- Assing Colour for Current Charge (MH)

			if mhPerc < 25 then
				clrMH = clrA
			elseif mhPerc >= 25 and mhPerc < 75  then
				clrMH = clrW
			else
				clrMH = clrN
			end

			-- Assing Colour for Current Charge (OH)

			if ohPerc < 25 then
				clrOH = clrA
			elseif ohPerc >= 25 and ohPerc < 75  then
				clrOH = clrW
			else
				clrOH = clrN
			end

			if RAEIH.SavedVars.WeaponChargeFormat == "Current/Max (%)" then
				RAEIH.WeaponChargeText = clrDft .. "MH: " .. clrMH .. mhCC .. clrDft .. "/" .. mhMC .. " (" .. clrMH .. mhPerc .. "%" .. clrDft .. ")" .. " / " .. "OH: " .. clrOH .. ohCC .. clrDft .. "/" .. ohMC .. " (" .. clrOH .. ohPerc .. "%" .. clrDft .. ")"

			elseif RAEIH.SavedVars.WeaponChargeFormat == "Current/Max" then
				RAEIH.WeaponChargeText = clrDft .. "MH: " .. clrMH .. mhCC .. clrDft .. "/" .. mhMC .. " - " .. "OH: " .. clrOH .. ohCC .. clrDft .. "/" .. ohMC

			else
				RAEIH.WeaponChargeText = clrDft .. "MH: " .. clrMH .. mhPerc .. "%" .. clrDft .. " / " .. "OH: " .. clrOH .. ohPerc .. "%"
			end

			-- Auto Recharge Process

			if RAEIH.SavedVars.AutoChargeWeaponEnabled == true and mhPerc <= RAEIH.SavedVars.AutoChargeWeaponThreshold and isMW1 == false then
				RAEIH.GetSoulGemInfo()
				if RAEIH.SGtoUse ~= nil then
					ChargeItemWithSoulGem(BAG_WORN, 4, BAG_BACKPACK, RAEIH.SGtoUse)
					local rae_usedSG = GetItemLink(BAG_BACKPACK, RAEIH.SGtoUse, LINK_STYLE_BRACKETS)
					-- d("Mainhand weapon charged with " .. rae_usedSG .. "!")
					if RAEIH.SavedVars.NotificationRecharge == true then
						RAEIH.NotificationText = clrA .. "Mainhand weapon charged with " .. rae_usedSG .. clrA .. "!"
						RAEIH_Notification_String:SetText(RAEIH.NotificationText)
						RAEIH.FirstTextAnim()
						RAEIH.SavedVars.StartNotificationTimer = true
						RAEIH.OrganizeLegatus()
					end
				elseif RAEIH.SGtoUse == nil then
					if RAEIH.SavedVars.NotificationRecharge == true then
						RAEIH.NotificationText = clrA .. "No Soul Gem to charge weapon!"
						RAEIH_Notification_String:SetText(RAEIH.NotificationText)
						RAEIH.FirstTextAnim()
						RAEIH.SavedVars.StartNotificationTimer = true
						RAEIH.OrganizeLegatus()
					end
					-- d("Mainhand weapon can't be charged because there is no filled soul gem to use!")
				end
			end

			if RAEIH.SavedVars.AutoChargeWeaponEnabled == true and ohPerc <= RAEIH.SavedVars.AutoChargeWeaponThreshold and isMW2 == false then
				RAEIH.GetSoulGemInfo()
				if RAEIH.SGtoUse ~= nil then
					ChargeItemWithSoulGem(BAG_WORN, 5, BAG_BACKPACK, RAEIH.SGtoUse)
					local rae_usedSG = GetItemLink(BAG_BACKPACK, RAEIH.SGtoUse, LINK_STYLE_BRACKETS)
					-- d("Offhand weapon charged with " .. rae_usedSG .. "!")
					if RAEIH.SavedVars.NotificationRecharge == true then
						RAEIH.NotificationText = clrA .. "Offhand weapon charged with " .. rae_usedSG .. clrA .. "!"
						RAEIH_Notification_String:SetText(RAEIH.NotificationText)
						RAEIH.FirstTextAnim()
						RAEIH.SavedVars.StartNotificationTimer = true
						RAEIH.OrganizeLegatus()
					end
				elseif RAEIH.SGtoUse == nil then
					if RAEIH.SavedVars.NotificationRecharge == true then
						RAEIH.NotificationText = clrA .. "No Soul Gem to charge weapon!"
						RAEIH_Notification_String:SetText(RAEIH.NotificationText)
						RAEIH.FirstTextAnim()
						RAEIH.SavedVars.StartNotificationTimer = true
						RAEIH.OrganizeLegatus()
					end
					-- d("Offhand weapon can't be charged because there is no filled soul gem to use!")
				end
			end

		else
			RAEIH.WeaponChargeText = clrW .. "No Chargeable Weapon Set"
		end

	elseif activePair == 2 then

		local isMainhandRC = IsItemChargeable(bagID, 20)
		local isOffhandRC = IsItemChargeable(bagID, 21)

		-- MH: Rechargeable & OH: Not Rechargeable

		if isMainhandRC == true and isOffhandRC == false then
			local clr = nil
			local mhCC, mhMC = GetChargeInfoForItem(bagID, 20)
			local mhPerc = RAEIH.Round(mhCC / mhMC * 100)

			-- Master Weapon Check

			local mwIL = GetItemLink(bagID, 20)
			local mwID = select(4,ZO_LinkHandler_ParseLink(mwIL))
			local isMW = false

			for i, slot in pairs(RAEIH.AWCMWList) do
				if RAEIH.AWCMWList[i] == mwID then
					isMW = true
				else
					isMW = false
				end
			end

			-- Assign Colour for Current Charge

			if mhPerc < 25 then
				clr = clrA
			elseif mhPerc >= 25 and mhPerc < 75  then
				clr = clrW
			else
				clr = clrN
			end

			if RAEIH.SavedVars.WeaponChargeFormat == "Current/Max (%)" then

				RAEIH.WeaponChargeText = clrDft .. "MH: " .. clr .. mhCC .. clrDft .. "/" .. mhMC .. " (" .. clr .. mhPerc .. "%" .. clrDft .. ")"
			elseif RAEIH.SavedVars.WeaponChargeFormat == "Current/Max" then
				RAEIH.WeaponChargeText = clrDft .. "MH: " .. clr .. mhCC .. clrDft .. "/" .. mhMC
			else
				RAEIH.WeaponChargeText = clrDft .. "MH: " .. clr .. mhPerc .. "%"
			end

			-- Auto Recharge Process

			if RAEIH.SavedVars.AutoChargeWeaponEnabled == true and mhPerc <= RAEIH.SavedVars.AutoChargeWeaponThreshold and isMW == false then
				RAEIH.GetSoulGemInfo()
				if RAEIH.SGtoUse ~= nil then
					ChargeItemWithSoulGem(BAG_WORN, 20, BAG_BACKPACK, RAEIH.SGtoUse)
					local rae_usedSG = GetItemLink(BAG_BACKPACK, RAEIH.SGtoUse, LINK_STYLE_BRACKETS)
					-- d("Mainhand weapon charged with " .. rae_usedSG .. "!")
					if RAEIH.SavedVars.NotificationRecharge == true then
						RAEIH.NotificationText = clrA .. "Mainhand weapon charged with " .. rae_usedSG .. clrA .. "!"
						RAEIH_Notification_String:SetText(RAEIH.NotificationText)
						RAEIH.FirstTextAnim()
						RAEIH.SavedVars.StartNotificationTimer = true
						RAEIH.OrganizeLegatus()
					end
				elseif RAEIH.SGtoUse == nil then
					if RAEIH.SavedVars.NotificationRecharge == true then
						RAEIH.NotificationText = clrA .. "No Soul Gem to charge weapon!"
						RAEIH_Notification_String:SetText(RAEIH.NotificationText)
						RAEIH.FirstTextAnim()
						RAEIH.SavedVars.StartNotificationTimer = true
						RAEIH.OrganizeLegatus()
					end
					-- d("Mainhand weapon can't be charged because there is no filled soul gem to use!")
				end
			end

		-- MH: Not Rechargeable & OH: Rechargeable

		elseif isMainhandRC == false and isOffhandRC == true then
			local clr = nil
			local ohCC, ohMC = GetChargeInfoForItem(bagID, 21)
			local ohPerc = RAEIH.Round(ohCC / ohMC * 100)

			-- Master Weapon Check

			local mwIL = GetItemLink(bagID, 21)
			local mwID = select(4,ZO_LinkHandler_ParseLink(mwIL))
			local isMW = false

			for i, slot in pairs(RAEIH.AWCMWList) do
				if RAEIH.AWCMWList[i] == mwID then
					isMW = true
				else
					isMW = false
				end
			end

			-- Assign Colour for Current Charge

			if ohPerc < 25 then
				clr = clrA
			elseif ohPerc >= 25 and ohPerc < 75  then
				clr = clrW
			else
				clr = clrN
			end

			if RAEIH.SavedVars.WeaponChargeFormat == "Current/Max (%)" then

				RAEIH.WeaponChargeText = clrDft .. "OH: " .. clr .. ohCC .. clrDft .. "/" .. ohMC .. " (" .. clr .. ohPerc .. "%" .. clrDft .. ")"
			elseif RAEIH.SavedVars.WeaponChargeFormat == "Current/Max" then
				RAEIH.WeaponChargeText = clrDft .. "OH: " .. clr .. ohCC .. clrDft .. "/" .. ohMC
			else
				RAEIH.WeaponChargeText = clrDft .. "OH: " .. clr .. ohPerc .. "%"
			end

			-- Auto Recharge Process

			if RAEIH.SavedVars.AutoChargeWeaponEnabled == true and ohPerc <= RAEIH.SavedVars.AutoChargeWeaponThreshold and isMW == false then
				RAEIH.GetSoulGemInfo()
				if RAEIH.SGtoUse ~= nil then
					ChargeItemWithSoulGem(BAG_WORN, 21, BAG_BACKPACK, RAEIH.SGtoUse)
					local rae_usedSG = GetItemLink(BAG_BACKPACK, RAEIH.SGtoUse, LINK_STYLE_BRACKETS)
					-- d("Offhand weapon charged with " .. rae_usedSG .. "!")
					if RAEIH.SavedVars.NotificationRecharge == true then
						RAEIH.NotificationText = clrA .. "Offhand weapon charged with " .. rae_usedSG .. clrA .. "!"
						RAEIH_Notification_String:SetText(RAEIH.NotificationText)
						RAEIH.FirstTextAnim()
						RAEIH.SavedVars.StartNotificationTimer = true
						RAEIH.OrganizeLegatus()
					end
				elseif RAEIH.SGtoUse == nil then
					if RAEIH.SavedVars.NotificationRecharge == true then
						RAEIH.NotificationText = clrA .. "No Soul Gem to charge weapon!"
						RAEIH_Notification_String:SetText(RAEIH.NotificationText)
						RAEIH.FirstTextAnim()
						RAEIH.SavedVars.StartNotificationTimer = true
						RAEIH.OrganizeLegatus()
					end
					-- d("Offhand weapon can't be charged because there is no filled soul gem to use!")
				end
			end

		-- MH: Rechargeable & OH: Rechargeable

		elseif isMainhandRC == true and isOffhandRC == true then
			local clrMH = nil
			local clrOH = nil

			local mhCC, mhMC = GetChargeInfoForItem(bagID, 20)
			local ohCC, ohMC = GetChargeInfoForItem(bagID, 21)

			local ohPerc = RAEIH.Round(ohCC / ohMC * 100)
			local mhPerc = RAEIH.Round(mhCC / mhMC * 100)

			-- Master Weapon Check

			local mwIL1 = GetItemLink(bagID, 20)
			local mwID1 = select(4,ZO_LinkHandler_ParseLink(mwIL1))
			local isMW1 = false

			for i, slot in pairs(RAEIH.AWCMWList) do
				if RAEIH.AWCMWList[i] == mwID1 then
					isMW1 = true
				else
					isMW1 = false
				end
			end

			-- Master Weapon Check 2

			local mwIL2 = GetItemLink(bagID, 21)
			local mwID2 = select(4,ZO_LinkHandler_ParseLink(mwIL2))
			local isMW2 = false

			for i, slot in pairs(RAEIH.AWCMWList) do
				if RAEIH.AWCMWList[i] == mwID2 then
					isMW2 = true
				else
					isMW2 = false
				end
			end

			-- Assing Colour for Current Charge (MH)

			if mhPerc < 25 then
				clrMH = clrA
			elseif mhPerc >= 25 and mhPerc < 75  then
				clrMH = clrW
			else
				clrMH = clrN
			end

			-- Assing Colour for Current Charge (OH)

			if ohPerc < 25 then
				clrOH = clrA
			elseif ohPerc >= 25 and ohPerc < 75  then
				clrOH = clrW
			else
				clrOH = clrN
			end

			if RAEIH.SavedVars.WeaponChargeFormat == "Current/Max (%)" then
				RAEIH.WeaponChargeText = clrDft .. "MH: " .. clrMH .. mhCC .. clrDft .. "/" .. mhMC .. " (" .. clrMH .. mhPerc .. "%" .. clrDft .. ")" .. " / " .. "OH: " .. clrOH .. ohCC .. clrDft .. "/" .. ohMC .. " (" .. clrOH .. ohPerc .. "%" .. clrDft .. ")"

			elseif RAEIH.SavedVars.WeaponChargeFormat == "Current/Max" then
				RAEIH.WeaponChargeText = clrDft .. "MH: " .. clrMH .. mhCC .. clrDft .. "/" .. mhMC .. " - " .. "OH: " .. clrOH .. ohCC .. clrDft .. "/" .. ohMC

			else
				RAEIH.WeaponChargeText = clrDft .. "MH: " .. clrMH .. mhPerc .. "%" .. clrDft .. " / " .. "OH: " .. clrOH .. ohPerc .. "%"
			end

			-- Auto Recharge Process

			if RAEIH.SavedVars.AutoChargeWeaponEnabled == true and mhPerc <= RAEIH.SavedVars.AutoChargeWeaponThreshold and isMW1 == false then
				RAEIH.GetSoulGemInfo()
				if RAEIH.SGtoUse ~= nil then
					ChargeItemWithSoulGem(BAG_WORN, 20, BAG_BACKPACK, RAEIH.SGtoUse)
					local rae_usedSG = GetItemLink(BAG_BACKPACK, RAEIH.SGtoUse, LINK_STYLE_BRACKETS)
					-- d("Mainhand weapon charged with " .. rae_usedSG .. "!")
					if RAEIH.SavedVars.NotificationRecharge == true then
						RAEIH.NotificationText = clrA .. "Mainhand weapon charged with " .. rae_usedSG .. clrA .. "!"
						RAEIH_Notification_String:SetText(RAEIH.NotificationText)
						RAEIH.FirstTextAnim()
						RAEIH.SavedVars.StartNotificationTimer = true
						RAEIH.OrganizeLegatus()
					end
				elseif RAEIH.SGtoUse == nil then
					if RAEIH.SavedVars.NotificationRecharge == true then
						RAEIH.NotificationText = clrA .. "No Soul Gem to charge weapon!"
						RAEIH_Notification_String:SetText(RAEIH.NotificationText)
						RAEIH.FirstTextAnim()
						RAEIH.SavedVars.StartNotificationTimer = true
						RAEIH.OrganizeLegatus()
					end
					-- d("Mainhand weapon can't be charged because there is no filled soul gem to use!")
				end
			end

			if RAEIH.SavedVars.AutoChargeWeaponEnabled == true and ohPerc <= RAEIH.SavedVars.AutoChargeWeaponThreshold and isMW2 == false then
				RAEIH.GetSoulGemInfo()
				if RAEIH.SGtoUse ~= nil then
					ChargeItemWithSoulGem(BAG_WORN, 21, BAG_BACKPACK, RAEIH.SGtoUse)
					local rae_usedSG = GetItemLink(BAG_BACKPACK, RAEIH.SGtoUse, LINK_STYLE_BRACKETS)
					-- d("Offhand weapon charged with " .. rae_usedSG .. "!")
					if RAEIH.SavedVars.NotificationRecharge == true then
						RAEIH.NotificationText = clrA .. "Offhand weapon charged with " .. rae_usedSG .. clrA .. "!"
						RAEIH_Notification_String:SetText(RAEIH.NotificationText)
						RAEIH.FirstTextAnim()
						RAEIH.SavedVars.StartNotificationTimer = true
						RAEIH.OrganizeLegatus()
					end
				elseif RAEIH.SGtoUse == nil then
					if RAEIH.SavedVars.NotificationRecharge == true then
						RAEIH.NotificationText = clrA .. "No Soul Gem to charge weapon!"
						RAEIH_Notification_String:SetText(RAEIH.NotificationText)
						RAEIH.FirstTextAnim()
						RAEIH.SavedVars.StartNotificationTimer = true
						RAEIH.OrganizeLegatus()
					end
					-- d("Offhand weapon can't be charged because there is no filled soul gem to use!")
				end
			end
		else
			RAEIH.WeaponChargeText = clrW .. "No Chargeable Weapon Set"
		end

	else
		RAEIH.WeaponChargeText = clrA .. "No Active Weapon Set!"
	end
	RAEIH_WeaponCharge_String:SetText(RAEIH.WeaponChargeText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatWeaponCharge()

	local font = LMP:Fetch('font', RAEIH.SavedVars.WeaponChargeFont)
	local size = RAEIH.SavedVars.WeaponChargeFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.WeaponChargeFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_WeaponCharge_String:SetFont(fontFormat)

end

function RAEIH.OrganizeWeaponCharge()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.WeaponChargeX
	local mY = RAEIH.SavedVars.WeaponChargeY
	local mW = RAEIH.SavedVars.WeaponChargeIconW + RAEIH_WeaponCharge_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.WeaponChargeIconH
	local iX = RAEIH.SavedVars.WeaponChargeIconX
	local iY = RAEIH.SavedVars.WeaponChargeIconY
	local iW = RAEIH.SavedVars.WeaponChargeIconW
	local iH = RAEIH.SavedVars.WeaponChargeIconH
	local bA = RAEIH.SavedVars.WeaponChargeBA
	-- Update General Dimensions
	RAEIH_WeaponCharge:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_WeaponCharge_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_WeaponCharge_Icon:ClearAnchors()
	RAEIH_WeaponCharge_Icon:SetSimpleAnchor(RAEIH_WeaponCharge, iX, iY)
	-- Update String Anchor
	RAEIH_WeaponCharge_String:ClearAnchors()
	RAEIH_WeaponCharge_String:SetSimpleAnchor(RAEIH_WeaponCharge, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_WeaponCharge_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingWeaponCharge()
	RAEIH_WeaponCharge:StartMoving()
end

function RAEIH.StopMovingWeaponCharge()
	RAEIH_WeaponCharge:StopMovingOrResizing()
	RAEIH.SavedVars.WeaponChargeX = RAEIH_WeaponCharge:GetLeft()
	RAEIH.SavedVars.WeaponChargeY = RAEIH_WeaponCharge:GetTop()
end