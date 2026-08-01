--------------------------------------------
---------- RAEIH LEGATUS SETTINGS ----------
--------------------------------------------
local WM = GetWindowManager()
local LMP = RAEIH.LMP

-- CREATE LEGATUS
function RAEIH.CreateLegatus()
	if RAEIH_Legatus == nil and RAEIH.SavedVars.EnableLegatus == true then
		-- Shorten Variables
		local lW = GuiRoot:GetDimensions()
		local lH = RAEIH.SavedVars.InfoHubIconH
		local lX = RAEIH.SavedVars.LegatusX
		local lY = RAEIH.SavedVars.LegatusY
		local lBA = RAEIH.SavedVars.LegatusBA
		-- Container
		RAEIH_LegatusCO = WM:CreateTopLevelWindow("RAEIH_LegatusCO")
		RAEIH_LegatusCO:SetDimensions(lW, lH)
		RAEIH_LegatusCO:SetClampedToScreen(true)
		RAEIH_LegatusCO:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, lX, lY)
		RAEIH_LegatusCO:SetMouseEnabled(true)
		RAEIH_LegatusCO:SetMovable(not RAEIH.SavedVars.LockLegatusCO)
		RAEIH_LegatusCO:SetHandler("OnReceiveDrag", RAEIH.StartMovingLegatusCO)
		RAEIH_LegatusCO:SetHandler("OnMouseUp", RAEIH.StopMovingLegatusCO)
		RAEIH_LegatusCO:SetHidden(not RAEIH.SavedVars.EnableLegatus)
		-- Legatus Backdrop
		RAEIH_LegatusCO_Backdrop = WM:CreateControl("RAEIH_LegatusCO_Backdrop", RAEIH_LegatusCO, CT_BACKDROP)
		RAEIH_LegatusCO_Backdrop:SetAnchorFill(RAEIH_LegatusCO)
		RAEIH_LegatusCO_Backdrop:SetCenterColor(0, 0, 0, 0)
		RAEIH_LegatusCO_Backdrop:SetEdgeColor(0, 0, 0, 0)
		-- Legatus Background
		RAEIH_LegatusCO_Background = WM:CreateControl("RAEIH_LegatusCO_Background", RAEIH_LegatusCO, CT_TEXTURE)
		RAEIH_LegatusCO_Background:SetTexture(RAEIH.Backgrounds[RAEIH.SavedVars.LegatusBGTX])
		RAEIH_LegatusCO_Background:SetAnchorFill(RAEIH_LegatusCO)
		RAEIH_LegatusCO_Background:SetAlpha(0)
		-- Main Placeholder
		RAEIH_Legatus = WM:CreateTopLevelWindow("RAEIH_Legatus")
		RAEIH_Legatus:SetDimensions(lW, lH)
		RAEIH_Legatus:SetClampedToScreen(true)
		RAEIH_Legatus:SetAnchor(TOPLEFT, RAEIH_LegatusCO, TOPLEFT, lX, lY)
		RAEIH_Legatus:SetMouseEnabled(false)
		RAEIH_Legatus:SetMovable(false)
		-- Module Prep.
		if RAEIH.SavedVars.LgtCreateFirstTime then

			RAEIH.SavedVars.ShowFPS = true
			RAEIH_FPS:SetHidden(true)

			RAEIH.SavedVars.ShowLatency = true
			RAEIH_Latency:SetHidden(true)

			RAEIH.SavedVars.ShowLUAMemory = true
			RAEIH_LUAMemory:SetHidden(true)

			RAEIH.SavedVars.ShowTime = true
			RAEIH_Time:SetHidden(true)

			RAEIH.SavedVars.ShowZone = true
			RAEIH_Zone:SetHidden(true)

			RAEIH.SavedVars.ShowCoordinates = true
			RAEIH_Coordinates:SetHidden(true)

			RAEIH.SavedVars.ShowLVR = true
			RAEIH_LVR:SetHidden(true)

			RAEIH.SavedVars.ShowXVP = true
			RAEIH_XVP:SetHidden(true)

			RAEIH.SavedVars.ShowXVPperHour = true
			RAEIH_XVPperHour:SetHidden(true)

			RAEIH.SavedVars.ShowGold = true
			RAEIH_Gold:SetHidden(true)

			RAEIH.SavedVars.ShowGoldperHour = true
			RAEIH_GoldperHour:SetHidden(true)

			RAEIH.SavedVars.ShowBankedGold = true
			RAEIH_BankedGold:SetHidden(true)

			RAEIH.SavedVars.ShowDurability = true
			RAEIH_Durability:SetHidden(true)

			RAEIH.SavedVars.ShowRepairCost = true
			RAEIH_RepairCost:SetHidden(true)

			RAEIH.SavedVars.ShowBagSlots = true
			RAEIH_BagSlots:SetHidden(true)

			RAEIH.SavedVars.ShowBankSlots = true
			RAEIH_BankSlots:SetHidden(true)

			RAEIH.SavedVars.ShowThievery = true
			RAEIH_Thievery:SetHidden(true)

			RAEIH.SavedVars.ShowBounty = true
			RAEIH_Bounty:SetHidden(true)

			RAEIH.SavedVars.ShowRiding = true
			RAEIH_Riding:SetHidden(true)

			RAEIH.SavedVars.ShowBlacksmithing = true
			RAEIH_Blacksmithing:SetHidden(true)

			RAEIH.SavedVars.ShowWoodworking = true
			RAEIH_Woodworking:SetHidden(true)

			RAEIH.SavedVars.ShowClothing = true
			RAEIH_Clothing:SetHidden(true)

			RAEIH.SavedVars.ShowSoulGems = true
			RAEIH_SoulGems:SetHidden(true)

			RAEIH.SavedVars.ShowWeaponCharge = true
			RAEIH_WeaponCharge:SetHidden(true)

			RAEIH.SavedVars.ShowAttributePoints = true
			RAEIH_AttributePoints:SetHidden(true)

			RAEIH.SavedVars.ShowSkyShards = true
			RAEIH_SkyShards:SetHidden(true)

			RAEIH.SavedVars.ShowSkillPoints = true
			RAEIH_SkillPoints:SetHidden(true)

			RAEIH.SavedVars.ShowChampionXP = true
			RAEIH_ChampionXP:SetHidden(true)

			RAEIH.SavedVars.ShowAlliancePoints = true
			RAEIH_AlliancePoints:SetHidden(true)

			RAEIH.SavedVars.ShowAvARank = true
			RAEIH_AvARank:SetHidden(true)

			RAEIH.SavedVars.ShowAchievementPoints = true
			RAEIH_AchievementPoints:SetHidden(true)

			RAEIH.SavedVars.ShowFriends = true
			RAEIH_Friends:SetHidden(true)

			RAEIH.SavedVars.ShowPlayerInfo = true
			RAEIH_TimePlayed:SetHidden(true)

			RAEIH.SavedVars.ShowCombatState = true
			RAEIH_CombatState:SetHidden(true)

			RAEIH.SavedVars.ShowVampirism = true
			RAEIH_Vampirism:SetHidden(true)

			RAEIH.SavedVars.ShowLycanthropy = true
			RAEIH_Lycanthropy:SetHidden(true)

			RAEIH.SavedVars.ShowNotification = true
			RAEIH_Notification:SetHidden(true)

			-- String
			RAEIH_Legatus_String = WM:CreateControl("RAEIH_Legatus_String", RAEIH_LegatusCO, CT_LABEL)
			RAEIH_Legatus_String:SetAnchorFill(RAEIH_LegatusCO)
			RAEIH_Legatus_String:SetHorizontalAlignment(1)
			RAEIH_Legatus_String:SetVerticalAlignment(1)
			local font = LMP:Fetch('font', RAEIH.SavedVars.InfoHubFont)
			local size = RAEIH.SavedVars.InfoHubFontSize
			local style = RAEIH.FontStyles[RAEIH.SavedVars.InfoHubFontStyle]
			local fontFormat = font .. "|" .. size .. "|" .. style
			RAEIH_Legatus_String:SetFont(fontFormat)
			RAEIH_Legatus_String:SetText("|c3A5FCDRAETIA|r InfoHub |c3A5FCD" .. RAEIH.Version .. "|r - Legatus activated! Open \"Legatus Hub\" panel to choose your modules or just click on \"Use Predefined Modules\" button there to activate default module list")

			RAEIH.SavedVars.LgtCreateFirstTime = false
		end
	end
end

-- DISABLE LEGATUS
function RAEIH.DisableLegatus()
	if  RAEIH_Legatus ~= nil and RAEIH.SavedVars.EnableLegatus == false then
		RAEIH_LegatusCO:SetHidden(not RAEIH.SavedVars.EnableLegatus)
		RAEIH_Legatus:SetHidden(not RAEIH.SavedVars.EnableLegatus)
		local guiNumChildren = GuiRoot:GetNumChildren()
		for i = 1, guiNumChildren do
			local userData = GuiRoot:GetChild(i)
			if userData ~= nil then
				local controlName = userData:GetName()
				if controlName:match("RAEIH_") and controlName ~= "RAEIH_Subtitles" and controlName ~= "RAEIH_Reticle" then
					local isValid, posA, relative, posB, X, Y  = userData:GetAnchor()
					userData:ClearAnchors()
					userData:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, X, Y)
					userData:SetClampedToScreen(true)
					userData:SetMouseEnabled(true)
					userData:SetMovable(true)
				end
			end
		end
	end
end

-- ORGANIZE LEGATUS
function RAEIH.OrganizeLegatus()

	if RAEIH.SavedVars.EnableLegatus == true and RAEIH_Legatus ~= nil and RAEIH.InfoHubHidingTriggered == false then

		local XW = 0
		local H = 0
		local lgtPadding = RAEIH.SavedVars.LegatusPadding

		if RAEIH.SavedVars.InfoHubIconH == "16" or
			RAEIH.SavedVars.InfoHubIconH == "24" then
			H = RAEIH.SavedVars.InfoHubFontSize * 2
		else
			H = RAEIH.SavedVars.InfoHubIconH
		end

		local L1CName = RAEIH.MDN[RAEIH.SavedVars.L1CName]
		local L2CName = RAEIH.MDN[RAEIH.SavedVars.L2CName]
		local L3CName = RAEIH.MDN[RAEIH.SavedVars.L3CName]
		local L4CName = RAEIH.MDN[RAEIH.SavedVars.L4CName]
		local L5CName = RAEIH.MDN[RAEIH.SavedVars.L5CName]
		local L6CName = RAEIH.MDN[RAEIH.SavedVars.L6CName]
		local L7CName = RAEIH.MDN[RAEIH.SavedVars.L7CName]
		local L8CName = RAEIH.MDN[RAEIH.SavedVars.L8CName]
		local L9CName = RAEIH.MDN[RAEIH.SavedVars.L9CName]
		local L10CName = RAEIH.MDN[RAEIH.SavedVars.L10CName]
		local L11CName = RAEIH.MDN[RAEIH.SavedVars.L11CName]
		local L12CName = RAEIH.MDN[RAEIH.SavedVars.L12CName]
		local L13CName = RAEIH.MDN[RAEIH.SavedVars.L13CName]
		local L14CName = RAEIH.MDN[RAEIH.SavedVars.L14CName]
		local L15CName = RAEIH.MDN[RAEIH.SavedVars.L15CName]
		local L16CName = RAEIH.MDN[RAEIH.SavedVars.L16CName]
		local L17CName = RAEIH.MDN[RAEIH.SavedVars.L17CName]
		local L18CName = RAEIH.MDN[RAEIH.SavedVars.L18CName]
		local L19CName = RAEIH.MDN[RAEIH.SavedVars.L19CName]
		local L20CName = RAEIH.MDN[RAEIH.SavedVars.L20CName]

		local XL1CName = RAEIH.MDN[RAEIH.SavedVars.XL1CName]
		local XL2CName = RAEIH.MDN[RAEIH.SavedVars.XL2CName]
		local XL3CName = RAEIH.MDN[RAEIH.SavedVars.XL3CName]
		local XL4CName = RAEIH.MDN[RAEIH.SavedVars.XL4CName]
		local XL5CName = RAEIH.MDN[RAEIH.SavedVars.XL5CName]
		local XL6CName = RAEIH.MDN[RAEIH.SavedVars.XL6CName]
		local XL7CName = RAEIH.MDN[RAEIH.SavedVars.XL7CName]
		local XL8CName = RAEIH.MDN[RAEIH.SavedVars.XL8CName]
		local XL9CName = RAEIH.MDN[RAEIH.SavedVars.XL9CName]
		local XL10CName = RAEIH.MDN[RAEIH.SavedVars.XL10CName]
		local XL11CName = RAEIH.MDN[RAEIH.SavedVars.XL11CName]
		local XL12CName = RAEIH.MDN[RAEIH.SavedVars.XL12CName]
		local XL13CName = RAEIH.MDN[RAEIH.SavedVars.XL13CName]
		local XL14CName = RAEIH.MDN[RAEIH.SavedVars.XL14CName]
		local XL15CName = RAEIH.MDN[RAEIH.SavedVars.XL15CName]
		local XL16CName = RAEIH.MDN[RAEIH.SavedVars.XL16CName]
		local XL17CName = RAEIH.MDN[RAEIH.SavedVars.XL17CName]
		local XL18CName = RAEIH.MDN[RAEIH.SavedVars.XL18CName]
		local XL19CName = RAEIH.MDN[RAEIH.SavedVars.XL19CName]
		local XL20CName = RAEIH.MDN[RAEIH.SavedVars.XL20CName]

		local mTableSize = #RAEIH.MD.CName

		-- Legatus I
		for i = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i]
			if ctrlName == L1CName then
				if RAEIH_Legatus_String ~= nil then
					RAEIH_Legatus_String:SetHidden(true)
					RAEIH_Legatus_String:SetText("")
					RAEIH_Legatus_String = nil
				end
				local ctrlUD = RAEIH.MD.UD[i]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL1CName and L1CName ~= XL1CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL1CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL1CName = nil
				end
			end
		end

		-- Legatus II
		for i2 = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i2]
			if ctrlName == L2CName then
				local ctrlUD = RAEIH.MD.UD[i2]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL2CName and L2CName ~= XL2CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL2CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i2]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL2CName = nil
				end
			end
		end

		-- Legatus III
		for i3 = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i3]
			if ctrlName == L3CName then
				local ctrlUD = RAEIH.MD.UD[i3]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL3CName and L3CName ~= XL3CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL3CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i3]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL3CName = nil
				end
			end
		end

		-- Legatus IV
		for i4 = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i4]
			if ctrlName == L4CName then
				local ctrlUD = RAEIH.MD.UD[i4]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL4CName and L4CName ~= XL4CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL4CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i4]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL4CName = nil
				end
			end
		end

		-- Legatus V
		for i5 = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i5]
			if ctrlName == L5CName then
				local ctrlUD = RAEIH.MD.UD[i5]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL5CName and L5CName ~= XL5CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL5CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i5]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL5CName = nil
				end
			end
		end

		-- Legatus VI
		for i6 = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i6]
			if ctrlName == L6CName then
				local ctrlUD = RAEIH.MD.UD[i6]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL6CName and L6CName ~= XL6CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL6CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i6]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL6CName = nil
				end
			end
		end

		-- Legatus VII
		for i7 = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i7]
			if ctrlName == L7CName then
				local ctrlUD = RAEIH.MD.UD[i7]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL7CName and L7CName ~= XL7CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL7CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i7]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL7CName = nil
				end
			end
		end

		-- Legatus VIII
		for i8 = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i8]
			if ctrlName == L8CName then
				local ctrlUD = RAEIH.MD.UD[i8]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL8CName and L8CName ~= XL8CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL8CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i8]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL8CName = nil
				end
			end
		end

		-- Legatus IX
		for i9 = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i9]
			if ctrlName == L9CName then
				local ctrlUD = RAEIH.MD.UD[i9]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL9CName and L9CName ~= XL9CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL9CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i9]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL9CName = nil
				end
			end
		end

		-- Legatus X
		for i10 = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i10]
			if ctrlName == L10CName then
				local ctrlUD = RAEIH.MD.UD[i10]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL10CName and L10CName ~= XL10CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL10CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i10]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL10CName = nil
				end
			end
		end

		-- Legatus XI
		for i11 = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i11]
			if ctrlName == L11CName then
				local ctrlUD = RAEIH.MD.UD[i11]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL11CName and L11CName ~= XL11CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL11CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i11]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL11CName = nil
				end
			end
		end

		-- Legatus XII
		for i12 = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i12]
			if ctrlName == L12CName then
				local ctrlUD = RAEIH.MD.UD[i12]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL12CName and L12CName ~= XL12CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL12CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i12]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL12CName = nil
				end
			end
		end

		-- Legatus XIII
		for i13 = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i13]
			if ctrlName == L13CName then
				local ctrlUD = RAEIH.MD.UD[i13]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL13CName and L13CName ~= XL13CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL13CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i13]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL13CName = nil
				end
			end
		end

		-- Legatus XIV
		for i14 = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i14]
			if ctrlName == L14CName then
				local ctrlUD = RAEIH.MD.UD[i14]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL14CName and L14CName ~= XL14CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL14CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i14]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL14CName = nil
				end
			end
		end

		-- Legatus XV
		for i15 = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i15]
			if ctrlName == L15CName then
				local ctrlUD = RAEIH.MD.UD[i15]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL15CName and L15CName ~= XL15CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL15CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i15]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL15CName = nil
				end
			end
		end

		-- Legatus XVI
		for i16 = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i16]
			if ctrlName == L16CName then
				local ctrlUD = RAEIH.MD.UD[i16]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL16CName and L16CName ~= XL16CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL16CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i16]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL16CName = nil
				end
			end
		end

		-- Legatus XVII
		for i17 = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i17]
			if ctrlName == L17CName then
				local ctrlUD = RAEIH.MD.UD[i17]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL17CName and L17CName ~= XL17CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL17CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i17]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL17CName = nil
				end
			end
		end

		-- Legatus XVIII
		for i18 = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i18]
			if ctrlName == L18CName then
				local ctrlUD = RAEIH.MD.UD[i18]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL18CName and L18CName ~= XL18CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL18CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i18]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL18CName = nil
				end
			end
		end

		-- Legatus XIX
		for i19 = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i19]
			if ctrlName == L19CName then
				local ctrlUD = RAEIH.MD.UD[i19]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL19CName and L19CName ~= XL19CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL19CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i19]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL19CName = nil
				end
			end
		end

		-- Legatus XX
		for i20 = 1, mTableSize do
			local ctrlName = RAEIH.MD.CName[i20]
			if ctrlName == L20CName then
				local ctrlUD = RAEIH.MD.UD[i20]
				ctrlUD:SetHidden(false)
				ctrlUD:SetClampedToScreen(false)
				ctrlUD:SetMouseEnabled(false)
				ctrlUD:SetMovable(false)
				ctrlUD:ClearAnchors()
				ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, 0)
				local ctrlNumChildren = ctrlUD:GetNumChildren()
				for k = 1, ctrlNumChildren do
					local ctrlChildUD = ctrlUD:GetChild(k)
					if ctrlChildUD ~= nil then
						local ctrlChildName = ctrlChildUD:GetName()
						if ctrlChildName:find("_String") then
							XW = XW + (RAEIH.SavedVars.InfoHubIconW + ctrlChildUD:GetWidth()) + lgtPadding
						end
					end
				end
			end
			if ctrlName == XL20CName and L20CName ~= XL20CName then
				RAEIH.MSCTable()
				local isItFound = false
				for k = 1, #RAEIH.MDSC do
					if RAEIH.SavedVars.XL20CName == RAEIH.MDSC[k] then
						isItFound = true
					end
				end
				if isItFound == false then
					local ctrlUD = RAEIH.MD.UD[i20]
					ctrlUD:SetHidden(true)
					ctrlUD:SetClampedToScreen(true)
					ctrlUD:SetMouseEnabled(true)
					ctrlUD:SetMovable(true)
					ctrlUD:ClearAnchors()
					ctrlUD:SetSimpleAnchor(RAEIH_Legatus, XW, H)
					RAEIH.SavedVars.XL20CName = nil
				end
			end
		end

		-- Set Dimensions
		if RAEIH.SavedVars.LegatusAlignment == "Screen-Wide Left" then
			RAEIH_LegatusCO:SetDimensions(GuiRoot:GetDimensions(), H)
			RAEIH_Legatus:SetDimensions(XW + 10, H)
			RAEIH_Legatus:ClearAnchors()
			RAEIH_Legatus:SetAnchor(TOPLEFT, RAEIH_LegatusCO, TOPLEFT, 0, 0)
		elseif RAEIH.SavedVars.LegatusAlignment == "Screen-Wide Center" then
			RAEIH_LegatusCO:SetDimensions(GuiRoot:GetDimensions(), H)
			RAEIH_Legatus:SetDimensions(XW + 10, H)
			RAEIH_Legatus:ClearAnchors()
			RAEIH_Legatus:SetAnchor(CENTER, RAEIH_LegatusCO, CENTER, 0, 0)

		elseif RAEIH.SavedVars.LegatusAlignment == "Screen-Wide Right" then
			RAEIH_LegatusCO:SetDimensions(GuiRoot:GetDimensions(), H)
			RAEIH_Legatus:SetDimensions(XW + 10, H)
			RAEIH_Legatus:ClearAnchors()
			RAEIH_Legatus:SetAnchor(TOPRIGHT, RAEIH_LegatusCO, TOPRIGHT, 0, 0)

		elseif RAEIH.SavedVars.LegatusAlignment == "Bar-Wide Movable" then
			RAEIH_LegatusCO:SetDimensions(XW + 10, H)
			RAEIH_Legatus:SetDimensions(XW + 10, H)
			RAEIH_Legatus:ClearAnchors()
			RAEIH_Legatus:SetAnchor(TOPLEFT, RAEIH_LegatusCO, TOPLEFT, 0, 0)
		end

		-- Set BG/BG
		if RAEIH.SavedVars.LegatusBGType == "Solid Colour" then
			RAEIH_LegatusCO_Background:SetHidden(true)
			RAEIH_LegatusCO_Backdrop:SetHidden(false)
			local r, g, b, a = RAEIH.HexToRGBforLGT(RAEIH.SavedVars.LegatusBRGB)
			RAEIH_LegatusCO_Backdrop:SetCenterColor(r, g, b, a)
		elseif RAEIH.SavedVars.LegatusBGType == "Texture" then
			RAEIH_LegatusCO_Backdrop:SetHidden(true)
			RAEIH_LegatusCO_Background:SetHidden(false)
			RAEIH_LegatusCO_Background:SetTexture(RAEIH.Backgrounds[RAEIH.SavedVars.LegatusBGTX])
			local r, g, b, a = RAEIH.HexToRGBforLGT(RAEIH.SavedVars.LegatusBRGB)
			RAEIH_LegatusCO_Background:SetColor(r, g, b, a)
		end

		-- Update Module Statuses
		RAEIH.UpdateModuleStatuses()
	end
end

-- MOVE LEGATUS
function RAEIH.StartMovingLegatusCO()
	RAEIH_LegatusCO:StartMoving()
end

function RAEIH.StopMovingLegatusCO()
	RAEIH_LegatusCO:StopMovingOrResizing()
	RAEIH.SavedVars.LegatusX = RAEIH_LegatusCO:GetLeft()
	RAEIH.SavedVars.LegatusY = RAEIH_LegatusCO:GetTop()
end

-- ADD PREDEFINED MODULES
function RAEIH.LGTPredModules()
	RAEIH.SavedVars.XL1CName = RAEIH.SavedVars.L1CName
	RAEIH.SavedVars.L1CName = "FPS"
	RAEIH.SavedVars.XL2CName = RAEIH.SavedVars.L2CName
	RAEIH.SavedVars.L2CName = "Time"
	RAEIH.SavedVars.XL3CName = RAEIH.SavedVars.L3CName
	RAEIH.SavedVars.L3CName = "Zone"
	RAEIH.SavedVars.XL4CName = RAEIH.SavedVars.L4CName
	RAEIH.SavedVars.L4CName = "Coordinates"
	RAEIH.SavedVars.XL5CName = RAEIH.SavedVars.L5CName
	RAEIH.SavedVars.L5CName = "LVR"
	RAEIH.SavedVars.XL6CName = RAEIH.SavedVars.L6CName
	RAEIH.SavedVars.L6CName = "XVP"
	RAEIH.SavedVars.XL7CName = RAEIH.SavedVars.L7CName
	RAEIH.SavedVars.L7CName = "Gold"
	RAEIH.SavedVars.XL8CName = RAEIH.SavedVars.L8CName
	RAEIH.SavedVars.L8CName = "Banked Gold"
	RAEIH.SavedVars.XL9CName = RAEIH.SavedVars.L9CName
	RAEIH.SavedVars.L9CName = "Bag Slots"
	RAEIH.SavedVars.XL10CName = RAEIH.SavedVars.L10CName
	RAEIH.SavedVars.L10CName = "Bank Slots"
	RAEIH.SavedVars.XL11CName = RAEIH.SavedVars.L11CName
	RAEIH.SavedVars.L11CName = "Soul Gems"
	RAEIH.SavedVars.XL12CName = RAEIH.SavedVars.L12CName
	RAEIH.SavedVars.L12CName = "Weapon Charge"
	RAEIH.SavedVars.XL13CName = RAEIH.SavedVars.L13CName
	RAEIH.SavedVars.L13CName = "Durability"
	RAEIH.SavedVars.XL14CName = RAEIH.SavedVars.L14CName
	RAEIH.SavedVars.L14CName = "Repair Cost"
	RAEIH.SavedVars.XL15CName = RAEIH.SavedVars.L15CName
	RAEIH.SavedVars.L15CName = "Skill Points"
	RAEIH.SavedVars.XL16CName = RAEIH.SavedVars.L16CName
	RAEIH.SavedVars.L16CName = "Mount"
	RAEIH.SavedVars.XL17CName = RAEIH.SavedVars.L17CName
	RAEIH.SavedVars.L17CName = "Blacksmithing"
	RAEIH.SavedVars.XL18CName = RAEIH.SavedVars.L18CName
	RAEIH.SavedVars.L18CName = "Woodworking"
	RAEIH.SavedVars.XL19CName = RAEIH.SavedVars.L19CName
	RAEIH.SavedVars.L19CName = "Clothing"
	RAEIH.SavedVars.XL20CName = RAEIH.SavedVars.L20CName
	RAEIH.SavedVars.L20CName = "Friends"
	RAEIH.OrganizeLegatus()
end

-- CLEAR LEGATUS MODULE LIST
function RAEIH.LGTClearModuleList()
	RAEIH.SavedVars.XL1CName = RAEIH.SavedVars.L1CName
	RAEIH.SavedVars.L1CName = "Empty"
	RAEIH.SavedVars.XL2CName = RAEIH.SavedVars.L2CName
	RAEIH.SavedVars.L2CName = "Empty"
	RAEIH.SavedVars.XL3CName = RAEIH.SavedVars.L3CName
	RAEIH.SavedVars.L3CName = "Empty"
	RAEIH.SavedVars.XL4CName = RAEIH.SavedVars.L4CName
	RAEIH.SavedVars.L4CName = "Empty"
	RAEIH.SavedVars.XL5CName = RAEIH.SavedVars.L5CName
	RAEIH.SavedVars.L5CName = "Empty"
	RAEIH.SavedVars.XL6CName = RAEIH.SavedVars.L6CName
	RAEIH.SavedVars.L6CName = "Empty"
	RAEIH.SavedVars.XL7CName = RAEIH.SavedVars.L7CName
	RAEIH.SavedVars.L7CName = "Empty"
	RAEIH.SavedVars.XL8CName = RAEIH.SavedVars.L8CName
	RAEIH.SavedVars.L8CName = "Empty"
	RAEIH.SavedVars.XL9CName = RAEIH.SavedVars.L9CName
	RAEIH.SavedVars.L9CName = "Empty"
	RAEIH.SavedVars.XL10CName = RAEIH.SavedVars.L10CName
	RAEIH.SavedVars.L10CName = "Empty"
	RAEIH.SavedVars.XL11CName = RAEIH.SavedVars.L11CName
	RAEIH.SavedVars.L11CName = "Empty"
	RAEIH.SavedVars.XL12CName = RAEIH.SavedVars.L12CName
	RAEIH.SavedVars.L12CName = "Empty"
	RAEIH.SavedVars.XL13CName = RAEIH.SavedVars.L13CName
	RAEIH.SavedVars.L13CName = "Empty"
	RAEIH.SavedVars.XL14CName = RAEIH.SavedVars.L14CName
	RAEIH.SavedVars.L14CName = "Empty"
	RAEIH.SavedVars.XL15CName = RAEIH.SavedVars.L15CName
	RAEIH.SavedVars.L15CName = "Empty"
	RAEIH.SavedVars.XL16CName = RAEIH.SavedVars.L16CName
	RAEIH.SavedVars.L16CName = "Empty"
	RAEIH.SavedVars.XL17CName = RAEIH.SavedVars.L17CName
	RAEIH.SavedVars.L17CName = "Empty"
	RAEIH.SavedVars.XL18CName = RAEIH.SavedVars.L18CName
	RAEIH.SavedVars.L18CName = "Empty"
	RAEIH.SavedVars.XL19CName = RAEIH.SavedVars.L19CName
	RAEIH.SavedVars.L19CName = "Empty"
	RAEIH.SavedVars.XL20CName = RAEIH.SavedVars.L20CName
	RAEIH.SavedVars.L20CName = "Empty"
	RAEIH.OrganizeLegatus()
end