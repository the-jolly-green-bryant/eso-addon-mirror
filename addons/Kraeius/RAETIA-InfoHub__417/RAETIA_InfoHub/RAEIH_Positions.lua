local WM = GetWindowManager()

-- 0, 1, 2 / 3, 1, 4

-- INFOHUB ICON SIZE
function RAEIH.ChangeIHIconSize()

	local newWidth = RAEIH.SavedVars.InfoHubIconW
	local newHeight = RAEIH.SavedVars.InfoHubIconH

	RAEIH.SavedVars.FPSIconW = newWidth
	RAEIH.SavedVars.FPSIconH = newHeight
	RAEIH_FPS_Icon:SetDimensions(RAEIH.SavedVars.FPSIconW, RAEIH.SavedVars.FPSIconH)

	RAEIH.SavedVars.LatencyIconW = newWidth
	RAEIH.SavedVars.LatencyIconH = newHeight
	RAEIH_Latency_Icon:SetDimensions(RAEIH.SavedVars.LatencyIconW, RAEIH.SavedVars.LatencyIconH)

	RAEIH.SavedVars.LUAMemoryIconW = newWidth
	RAEIH.SavedVars.LUAMemoryIconH = newHeight
	RAEIH_LUAMemory_Icon:SetDimensions(RAEIH.SavedVars.LUAMemoryIconW, RAEIH.SavedVars.LUAMemoryIconH)

	RAEIH.SavedVars.TimeIconW = newWidth
	RAEIH.SavedVars.TimeIconH = newHeight
	RAEIH_Time_Icon:SetDimensions(RAEIH.SavedVars.TimeIconW, RAEIH.SavedVars.TimeIconH)

	RAEIH.SavedVars.ZoneIconW = newWidth
	RAEIH.SavedVars.ZoneIconH = newHeight
	RAEIH_Zone_Icon:SetDimensions(RAEIH.SavedVars.ZoneIconW, RAEIH.SavedVars.ZoneIconH)

	RAEIH.SavedVars.CoordinatesIconW = newWidth
	RAEIH.SavedVars.CoordinatesIconH = newHeight
	RAEIH_Coordinates_Icon:SetDimensions(RAEIH.SavedVars.CoordinatesIconW, RAEIH.SavedVars.CoordinatesIconH)

	RAEIH.SavedVars.LVRIconW = newWidth
	RAEIH.SavedVars.LVRIconH = newHeight
	RAEIH_LVR_Icon:SetDimensions(RAEIH.SavedVars.LVRIconW, RAEIH.SavedVars.LVRIconH)

	RAEIH.SavedVars.XVPIconW = newWidth
	RAEIH.SavedVars.XVPIconH = newHeight
	RAEIH_XVP_Icon:SetDimensions(RAEIH.SavedVars.XVPIconW, RAEIH.SavedVars.XVPIconH)

	RAEIH.SavedVars.XVPperHourIconW = newWidth
	RAEIH.SavedVars.XVPperHourIconH = newHeight
	RAEIH_XVPperHour_Icon:SetDimensions(RAEIH.SavedVars.XVPperHourIconW, RAEIH.SavedVars.XVPperHourIconH)

	RAEIH.SavedVars.GoldIconW = newWidth
	RAEIH.SavedVars.GoldIconH = newHeight
	RAEIH_Gold_Icon:SetDimensions(RAEIH.SavedVars.GoldIconW, RAEIH.SavedVars.GoldIconH)

	RAEIH.SavedVars.GoldperHourIconW = newWidth
	RAEIH.SavedVars.GoldperHourIconH = newHeight
	RAEIH_GoldperHour_Icon:SetDimensions(RAEIH.SavedVars.GoldperHourIconW, RAEIH.SavedVars.GoldperHourIconH)

	RAEIH.SavedVars.BankedGoldIconW = newWidth
	RAEIH.SavedVars.BankedGoldIconH = newHeight
	RAEIH_BankedGold_Icon:SetDimensions(RAEIH.SavedVars.BankedGoldIconW, RAEIH.SavedVars.BankedGoldIconH)

	RAEIH.SavedVars.DurabilityIconW = newWidth
	RAEIH.SavedVars.DurabilityIconH = newHeight
	RAEIH_Durability_Icon:SetDimensions(RAEIH.SavedVars.DurabilityIconW, RAEIH.SavedVars.DurabilityIconH)

	RAEIH.SavedVars.RepairCostIconW = newWidth
	RAEIH.SavedVars.RepairCostIconH = newHeight
	RAEIH_RepairCost_Icon:SetDimensions(RAEIH.SavedVars.RepairCostIconW, RAEIH.SavedVars.RepairCostIconH)

	RAEIH.SavedVars.BagSlotsIconW = newWidth
	RAEIH.SavedVars.BagSlotsIconH = newHeight
	RAEIH_BagSlots_Icon:SetDimensions(RAEIH.SavedVars.BagSlotsIconW, RAEIH.SavedVars.BagSlotsIconH)

	RAEIH.SavedVars.BankSlotsIconW = newWidth
	RAEIH.SavedVars.BankSlotsIconH = newHeight
	RAEIH_BankSlots_Icon:SetDimensions(RAEIH.SavedVars.BankSlotsIconW, RAEIH.SavedVars.BankSlotsIconH)

	RAEIH.SavedVars.ThieveryIconW = newWidth
	RAEIH.SavedVars.ThieveryIconH = newHeight
	RAEIH_Thievery_Icon:SetDimensions(RAEIH.SavedVars.ThieveryIconW, RAEIH.SavedVars.ThieveryIconH)

	RAEIH.SavedVars.BountyIconW = newWidth
	RAEIH.SavedVars.BountyIconH = newHeight
	RAEIH_Bounty_Icon:SetDimensions(RAEIH.SavedVars.BountyIconW, RAEIH.SavedVars.BountyIconH)

	RAEIH.SavedVars.RidingIconW = newWidth
	RAEIH.SavedVars.RidingIconH = newHeight
	RAEIH_Riding_Icon:SetDimensions(RAEIH.SavedVars.RidingIconW, RAEIH.SavedVars.RidingIconH)

	RAEIH.SavedVars.BlacksmithingIconW = newWidth
	RAEIH.SavedVars.BlacksmithingIconH = newHeight
	RAEIH_Blacksmithing_Icon:SetDimensions(RAEIH.SavedVars.BlacksmithingIconW, RAEIH.SavedVars.BlacksmithingIconH)

	RAEIH.SavedVars.WoodworkingIconW = newWidth
	RAEIH.SavedVars.WoodworkingIconH = newHeight
	RAEIH_Woodworking_Icon:SetDimensions(RAEIH.SavedVars.WoodworkingIconW, RAEIH.SavedVars.WoodworkingIconH)

	RAEIH.SavedVars.ClothingIconW = newWidth
	RAEIH.SavedVars.ClothingIconH = newHeight
	RAEIH_Clothing_Icon:SetDimensions(RAEIH.SavedVars.ClothingIconW, RAEIH.SavedVars.ClothingIconH)

	RAEIH.SavedVars.SoulGemsIconW = newWidth
	RAEIH.SavedVars.SoulGemsIconH = newHeight
	RAEIH_SoulGems_Icon:SetDimensions(RAEIH.SavedVars.SoulGemsIconW, RAEIH.SavedVars.SoulGemsIconH)	

	RAEIH.SavedVars.WeaponChargeIconW = newWidth
	RAEIH.SavedVars.WeaponChargeIconH = newHeight
	RAEIH_WeaponCharge_Icon:SetDimensions(RAEIH.SavedVars.WeaponChargeIconW, RAEIH.SavedVars.WeaponChargeIconH)

	RAEIH.SavedVars.AttributePointsIconW = newWidth
	RAEIH.SavedVars.AttributePointsIconH = newHeight
	RAEIH_AttributePoints_Icon:SetDimensions(RAEIH.SavedVars.AttributePointsIconW, RAEIH.SavedVars.AttributePointsIconH)

	RAEIH.SavedVars.SkyShardsIconW = newWidth
	RAEIH.SavedVars.SkyShardsIconH = newHeight
	RAEIH_SkyShards_Icon:SetDimensions(RAEIH.SavedVars.SkyShardsIconW, RAEIH.SavedVars.SkyShardsIconH)

	RAEIH.SavedVars.SkillPointsIconW = newWidth
	RAEIH.SavedVars.SkillPointsIconH = newHeight
	RAEIH_SkillPoints_Icon:SetDimensions(RAEIH.SavedVars.SkillPointsIconW, RAEIH.SavedVars.SkillPointsIconH)

	RAEIH.SavedVars.ChampionXPIconW = newWidth
	RAEIH.SavedVars.ChampionXPIconH = newHeight
	RAEIH_ChampionXP_Icon:SetDimensions(RAEIH.SavedVars.ChampionXPIconW, RAEIH.SavedVars.ChampionXPIconH)

	RAEIH.SavedVars.AlliancePointsIconW = newWidth
	RAEIH.SavedVars.AlliancePointsIconH = newHeight
	RAEIH_AlliancePoints_Icon:SetDimensions(RAEIH.SavedVars.AlliancePointsIconW, RAEIH.SavedVars.AlliancePointsIconH)

	RAEIH.SavedVars.AvARankIconW = newWidth
	RAEIH.SavedVars.AvARankIconH = newHeight
	RAEIH_AvARank_Icon:SetDimensions(RAEIH.SavedVars.AvARankIconW, RAEIH.SavedVars.AvARankIconH)

	RAEIH.SavedVars.AchievementPointsIconW = newWidth
	RAEIH.SavedVars.AchievementPointsIconH = newHeight
	RAEIH_AchievementPoints_Icon:SetDimensions(RAEIH.SavedVars.AchievementPointsIconW, RAEIH.SavedVars.AchievementPointsIconH)

	RAEIH.SavedVars.FriendsIconW = newWidth
	RAEIH.SavedVars.FriendsIconH = newHeight
	RAEIH_Friends_Icon:SetDimensions(RAEIH.SavedVars.FriendsIconW, RAEIH.SavedVars.FriendsIconH)

	RAEIH.SavedVars.TimePlayedIconW = newWidth
	RAEIH.SavedVars.TimePlayedIconH = newHeight
	RAEIH_TimePlayed_Icon:SetDimensions(RAEIH.SavedVars.TimePlayedIconW, RAEIH.SavedVars.TimePlayedIconH)

	RAEIH.SavedVars.CombatStateIconW = newWidth
	RAEIH.SavedVars.CombatStateIconH = newHeight
	RAEIH_CombatState_Icon:SetDimensions(RAEIH.SavedVars.CombatStateIconW, RAEIH.SavedVars.CombatStateIconH)

	RAEIH.SavedVars.VampirismIconW = newWidth
	RAEIH.SavedVars.VampirismIconH = newHeight
	RAEIH_Vampirism_Icon:SetDimensions(RAEIH.SavedVars.VampirismIconW, RAEIH.SavedVars.VampirismIconH)

	RAEIH.SavedVars.LycanthropyIconW = newWidth
	RAEIH.SavedVars.LycanthropyIconH = newHeight
	RAEIH_Lycanthropy_Icon:SetDimensions(RAEIH.SavedVars.LycanthropyIconW, RAEIH.SavedVars.LycanthropyIconH)

	RAEIH.SavedVars.CraftingXPIconW = newWidth
	RAEIH.SavedVars.CraftingXPIconH = newHeight
	RAEIH_CraftingXP_Icon:SetDimensions(RAEIH.SavedVars.CraftingXPIconW, RAEIH.SavedVars.CraftingXPIconH)

	RAEIH.SavedVars.NotificationIconW = newWidth
	RAEIH.SavedVars.NotificationIconH = newHeight
	RAEIH_Notification_Icon:SetDimensions(RAEIH.SavedVars.NotificationIconW, RAEIH.SavedVars.NotificationIconH)	

	RAEIH.SetModules()
	RAEIH.FormatModules()
	RAEIH.OrganizeModules()

end

-- INFOHUB X ICON POSITION
function RAEIH.ChangeIconPosIHX()

	local newXPos = RAEIH.SavedVars.InfoHubIconX

	RAEIH.SavedVars.FPSIconX = newXPos
	RAEIH.SavedVars.LatencyIconX = newXPos
	RAEIH.SavedVars.LUAMemoryIconX = newXPos	
	RAEIH.SavedVars.TimeIconX = newXPos
	RAEIH.SavedVars.ZoneIconX = newXPos
	RAEIH.SavedVars.CoordinatesIconX = newXPos
	RAEIH.SavedVars.LVRIconX = newXPos
	RAEIH.SavedVars.XVPIconX = newXPos
	RAEIH.SavedVars.XVPperHourIconX = newXPos
	RAEIH.SavedVars.GoldIconX = newXPos
	RAEIH.SavedVars.GoldperHourIconX = newXPos
	RAEIH.SavedVars.BankedGoldIconX = newXPos
	RAEIH.SavedVars.DurabilityIconX = newXPos
	RAEIH.SavedVars.RepairCostIconX = newXPos
	RAEIH.SavedVars.BagSlotsIconX = newXPos
	RAEIH.SavedVars.BankSlotsIconX = newXPos
	RAEIH.SavedVars.ThieveryIconX = newXPos
	RAEIH.SavedVars.BountyIconX = newXPos
	RAEIH.SavedVars.RidingIconX = newXPos
	RAEIH.SavedVars.BlacksmithingIconX = newXPos
	RAEIH.SavedVars.WoodworkingIconX = newXPos
	RAEIH.SavedVars.ClothingIconX = newXPos
	RAEIH.SavedVars.SoulGemsIconX = newXPos	
	RAEIH.SavedVars.WeaponChargeIconX = newXPos
	RAEIH.SavedVars.AttributePointsIconX = newXPos
	RAEIH.SavedVars.SkyShardsIconX = newXPos
	RAEIH.SavedVars.SkillPointsIconX = newXPos
	RAEIH.SavedVars.ChampionXPIconX = newXPos
	RAEIH.SavedVars.AlliancePointsIconX = newXPos
	RAEIH.SavedVars.AvARankIconX = newXPos
	RAEIH.SavedVars.AchievementPointsIconX = newXPos
	RAEIH.SavedVars.FriendsIconX = newXPos
	RAEIH.SavedVars.TimePlayedIconX = newXPos
	RAEIH.SavedVars.CombatStateIconX = newXPos
	RAEIH.SavedVars.VampirismIconX = newXPos
	RAEIH.SavedVars.LycanthropyIconX = newXPos
	RAEIH.SavedVars.CraftingXPIconX = newXPos
	RAEIH.SavedVars.NotificationIconX = newXPos

	RAEIH.SetModules()
	RAEIH.FormatModules()
	RAEIH.OrganizeModules()

end

-- INFOHUB Y ICON POSITION
function RAEIH.ChangeIconPosIHY()

	local newYPos = RAEIH.SavedVars.InfoHubIconY

	RAEIH.SavedVars.FPSIconY = newYPos
	RAEIH.SavedVars.LatencyIconY = newYPos
	RAEIH.SavedVars.LUAMemoryIconY = newYPos	
	RAEIH.SavedVars.TimeIconY = newYPos
	RAEIH.SavedVars.ZoneIconY = newYPos
	RAEIH.SavedVars.CoordinatesIconY = newYPos
	RAEIH.SavedVars.LVRIconY = newYPos
	RAEIH.SavedVars.XVPIconY = newYPos
	RAEIH.SavedVars.XVPperHourIconY = newYPos
	RAEIH.SavedVars.GoldIconY = newYPos
	RAEIH.SavedVars.GoldperHourIconY = newYPos
	RAEIH.SavedVars.BankedGoldIconY = newYPos
	RAEIH.SavedVars.DurabilityIconY = newYPos
	RAEIH.SavedVars.RepairCostIconY = newYPos
	RAEIH.SavedVars.BagSlotsIconY = newYPos
	RAEIH.SavedVars.BankSlotsIconY = newYPos
	RAEIH.SavedVars.ThieveryIconY = newYPos
	RAEIH.SavedVars.BountyIconY = newYPos
	RAEIH.SavedVars.RidingIconY = newYPos
	RAEIH.SavedVars.BlacksmithingIconY = newYPos
	RAEIH.SavedVars.WoodworkingIconY = newYPos
	RAEIH.SavedVars.ClothingIconY = newYPos
	RAEIH.SavedVars.SoulGemsIconY = newYPos	
	RAEIH.SavedVars.WeaponChargeIconY = newYPos
	RAEIH.SavedVars.AttributePointsIconY = newYPos
	RAEIH.SavedVars.SkyShardsIconY = newYPos
	RAEIH.SavedVars.SkillPointsIconY = newYPos
	RAEIH.SavedVars.ChampionXPIconY = newYPos
	RAEIH.SavedVars.AlliancePointsIconY = newYPos
	RAEIH.SavedVars.AvARankIconY = newYPos
	RAEIH.SavedVars.AchievementPointsIconY = newYPos
	RAEIH.SavedVars.FriendsIconY = newYPos
	RAEIH.SavedVars.TimePlayedIconY = newYPos
	RAEIH.SavedVars.CombatStateIconY = newYPos
	RAEIH.SavedVars.VampirismIconY = newYPos
	RAEIH.SavedVars.LycanthropyIconY = newYPos
	RAEIH.SavedVars.CraftingXPIconY = newYPos
	RAEIH.SavedVars.NotificationIconY = newYPos	

	RAEIH.SetModules()
	RAEIH.FormatModules()
	RAEIH.OrganizeModules()

end

-- UI POSITIONING
-- Grid
function RAEIH.CreateGrid(doIt)
	if (doIt and RAEIH_UI_Grid == nil) or (RAEIH.SavedVars.ShowGrid and RAEIH_UI_Grid == nil)  then

		local gNum = RAEIH.SavedVars.GridSize
		local guiW, guiH = GuiRoot:GetDimensions()
		local gDim = guiW / gNum
		local gYNumMax = guiH / gDim
		local gYNum = 1		
		
		RAEIH_UI_Grid = WM:CreateTopLevelWindow("RAEIH_UI_Grid")		
		RAEIH_UI_Grid:SetAnchorFill(GuiRoot)
		RAEIH_UI_Grid:SetMouseEnabled(false)		
		RAEIH_UI_Grid:SetMovable(false)

		local gX = 0
		local gY = 0
		local index = 1

		while index <= gNum do			
			local gName = "gridX_" .. tostring(index)	
			gName = WM:CreateControl(nil, RAEIH_UI_Grid, CT_BACKDROP)			
			gName:SetDimensions(gDim, gDim)
			gName:SetCenterColor(0, 0, 0, 0)
			gName:SetEdgeColor(0, 0, 0, 0.7)
			gName:SetEdgeTexture('', 2, 2, 1, 0)
			gName:SetSimpleAnchor(RAEIH_UI_Grid, gX, gY)
			gName:SetHidden(false)
			gX = gX + gDim
			index = index + 1
			if index == gNum + 1 and gYNum < gYNumMax then
				gX = 0
				gY = gY + gDim
				gYNum = gYNum + 1
				index = 1
			end
		end
	elseif doIt == false and RAEIH_UI_Grid ~= nil then
		RAEIH_UI_Grid:SetHidden(true)		
	elseif doIt == true and RAEIH_UI_Grid ~= nil then
		RAEIH_UI_Grid:SetHidden(false)
	end
end