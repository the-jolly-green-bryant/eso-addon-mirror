local LMP = RAEIH.LMP
local uTag = "player"
local iconGold = zo_iconFormat("esoui/art/currency/currency_gold.dds", 16, 16)

function RAEIH.CreateDurability()
	local WM = GetWindowManager()
	if RAEIH_Durability == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.DurabilityX
		local mY = RAEIH.SavedVars.DurabilityY
		local mW = RAEIH.SavedVars.DurabilityIconW + 10
		local mH = RAEIH.SavedVars.DurabilityIconH
		local iX = RAEIH.SavedVars.DurabilityIconX
		local iY = RAEIH.SavedVars.DurabilityIconY
		local iW = RAEIH.SavedVars.DurabilityIconW
		local iH = RAEIH.SavedVars.DurabilityIconH
		local bA = RAEIH.SavedVars.DurabilityBA
		-- Main Placeholder
		RAEIH_Durability = WM:CreateTopLevelWindow("RAEIH_Durability")
		RAEIH_Durability:SetClampedToScreen(true)
		RAEIH_Durability:SetDrawLevel(1)
		RAEIH_Durability:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_Durability:SetMouseEnabled(true)
		RAEIH_Durability:SetMovable(not RAEIH.SavedVars.LockDurability)
		RAEIH_Durability:SetHandler("OnReceiveDrag", RAEIH.StartMovingDurability)
		RAEIH_Durability:SetHandler("OnMouseUp", RAEIH.StopMovingDurability)
		RAEIH_Durability:SetHidden(not RAEIH.SavedVars.ShowDurability)
		-- Icon
		RAEIH_Durability_Icon = WM:CreateControl("RAEIH_Durability_Icon", RAEIH_Durability, CT_TEXTURE)
		RAEIH_Durability_Icon:SetTexture(RAEIH.Icons.Durability)
		RAEIH_Durability_Icon:SetDimensions(iW, iH)
		RAEIH_Durability_Icon:SetSimpleAnchor(RAEIH_Durability, iX, iY)
		-- String
		RAEIH_Durability_String = WM:CreateControl("RAEIH_Durability_String", RAEIH_Durability, CT_LABEL)
		RAEIH_Durability_String:SetSimpleAnchor(RAEIH_Durability, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_Durability_String:SetHorizontalAlignment(CENTER)
		RAEIH_Durability_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_Durability_Backdrop = WM:CreateControl("RAEIH_Durability_Backdrop", RAEIH_Durability, CT_BACKDROP)
		RAEIH_Durability_Backdrop:SetAnchorFill(RAEIH_Durability)
		RAEIH_Durability_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_Durability_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.AutoRepairItems()
	local activePair, isLocked = GetActiveWeaponPairInfo()
	local eqSlots = nil
	if activePair == 1 then
		eqSlots = {0, 2, 3, 16, 6, 8, 9, 4, 5}
	elseif activePair == 2 then
		eqSlots = {0, 2, 3, 16, 6, 8, 9, 20, 21}
	else
		eqSlots = {0, 2, 3, 16, 6, 8, 9}
	end

	local tirCost = 0
	local riNum = 0

	for i, slot in ipairs(eqSlots) do
		local drbCheck = DoesItemHaveDurability(0, slot)
		if drbCheck == true then
			local iCond = GetItemCondition(0, slot)
			local iRCost = GetItemRepairCost(0, slot)
			if iCond < RAEIH.SavedVars.AutoRepairThreshold then
				tirCost = tirCost + iRCost
				riNum = riNum + 1
				local item = GetItemLink(0, slot, 1)
				RepairItem(0, slot)
				-- d(item .. " [" .. iCond .. "%] » " .. iRCost .. "g")
			end
		end
	end			
	if riNum == 1 then
		d(riNum .. " item repaired by InfoHub. You've paid " .. tirCost .. iconGold)
	elseif riNum > 0 then
		d(riNum .. " items repaired by InfoHub. You've paid " .. tirCost .. iconGold)
	end
end

function RAEIH.SetDurability()

	local clrDft = "|c" .. RAEIH.SavedVars.DurabilityDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.DurabilityAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.DurabilityWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.DurabilityNormalColour

	local bagID = 0

	local activePair, isLocked = GetActiveWeaponPairInfo()
	local eqSlots = nil
	local checkedEqS = 0

	local tiCond = 0

	local liCond = 100
	local liCondSlot = nil
	local liCondName = nil

	if activePair == 1 then
		eqSlots = {0, 2, 3, 16, 6, 8, 9, 4, 5}
	elseif activePair == 2 then
		eqSlots = {0, 2, 3, 16, 6, 8, 9, 20, 21}
	else
		eqSlots = {0, 2, 3, 16, 6, 8, 9}
	end

	for i, slot in ipairs(eqSlots) do
		local drbCheck = DoesItemHaveDurability(0, slot)

		if drbCheck == true then
			local iCond = GetItemCondition(0, slot)
			checkedEqS = checkedEqS + 1
			tiCond = tiCond + iCond

			if iCond < liCond then
				liCond = iCond
				liCondSlot = slot
			end
		end
	end

	local fiCond = tiCond / checkedEqS

	if liCondSlot == 0 then
		liCondName = "HD: "
	elseif liCondSlot == 2 then
		liCondName = "CH: "
	elseif liCondSlot == 3 then
		liCondName = "SH: "
	elseif liCondSlot == 16 then
		liCondName = "HN: "
	elseif liCondSlot == 6 then
		liCondName = "WS: "
	elseif liCondSlot == 8 then
		liCondName = "LG: "
	elseif liCondSlot == 9 then
		liCondName = "FT: "
	elseif liCondSlot == 4 then
		liCondName = "MH: "
	elseif liCondSlot == 5 then
		liCondName = "OH: "
	elseif liCondSlot == 20 then
		liCondName = "MH: "
	elseif liCondName == 21 then
		liCondName = "OH: "
	else
		liCondName = ""
	end

	if liCond < 25 then
		clrLI = clrA
	elseif liCond >= 25 and liCond < 75 then
		clrLI = clrW
	else
		clrLI = clrN
	end

	if fiCond < 25 then
		clrFI = clrA
		if RAEIH.SavedVars.NotificationDurability == true then
			RAEIH.NotificationText = clrA .. "Worn item durability < " .. clrW ..  RAEIH.Round(fiCond) .. "%" .. clrA .. "!"
			RAEIH_Notification_String:SetText(RAEIH.NotificationText)
			RAEIH.FirstTextAnim()
			RAEIH.SavedVars.StartNotificationTimer = true
			RAEIH.OrganizeLegatus()
		end
	elseif fiCond >= 25 and fiCond < 75 then
		clrFI = clrW
	else
		clrFI = clrN
	end

	fiCond = RAEIH.Round(fiCond)
	liCond = RAEIH.Round(liCond)

	if RAEIH.SavedVars.TSFormat == "Point (.)" then
		fiCond = string.gsub(tostring(fiCond), "%.", ",") .. "%"
		liCond = string.gsub(tostring(liCond), "%.", ",") .. "%"
	else
		fiCond = tostring(fiCond) .. "%"
		liCond = tostring(liCond) .. "%"
	end

	if RAEIH.SavedVars.DurabilityFormat == "General% (Lowest Item%)" then
		RAEIH.DurabilityText = clrFI .. fiCond .. clrDft .. " (" .. liCondName .. clrLI .. liCond .. clrDft .. ")"
	elseif RAEIH.SavedVars.DurabilityFormat == "General%" then
		RAEIH.DurabilityText = clrFI .. fiCond
	elseif RAEIH.SavedVars.DurabilityFormat == "Lowest Item%" then
		RAEIH.DurabilityText = clrDft .. liCondName .. clrLI .. liCond
	end

	if fiCond == "-1,#IND%" then
		RAEIH.DurabilityText = clrA .. "Oh Naked!"
	end

	RAEIH_Durability_String:SetText(RAEIH.DurabilityText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatDurability()

	local font = LMP:Fetch('font', RAEIH.SavedVars.DurabilityFont)
	local size = RAEIH.SavedVars.DurabilityFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.DurabilityFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_Durability_String:SetFont(fontFormat)

end

function RAEIH.OrganizeDurability()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.DurabilityX
	local mY = RAEIH.SavedVars.DurabilityY
	local mW = RAEIH.SavedVars.DurabilityIconW + RAEIH_Durability_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.DurabilityIconH
	local iX = RAEIH.SavedVars.DurabilityIconX
	local iY = RAEIH.SavedVars.DurabilityIconY
	local iW = RAEIH.SavedVars.DurabilityIconW
	local iH = RAEIH.SavedVars.DurabilityIconH
	local bA = RAEIH.SavedVars.DurabilityBA
	-- Update General Dimensions
	RAEIH_Durability:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_Durability_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_Durability_Icon:ClearAnchors()
	RAEIH_Durability_Icon:SetSimpleAnchor(RAEIH_Durability, iX, iY)
	-- Update String Anchor
	RAEIH_Durability_String:ClearAnchors()
	RAEIH_Durability_String:SetSimpleAnchor(RAEIH_Durability, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_Durability_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingDurability()
	RAEIH_Durability:StartMoving()
end

function RAEIH.StopMovingDurability()
	RAEIH_Durability:StopMovingOrResizing()
	RAEIH.SavedVars.DurabilityX = RAEIH_Durability:GetLeft()
	RAEIH.SavedVars.DurabilityY = RAEIH_Durability:GetTop()
end