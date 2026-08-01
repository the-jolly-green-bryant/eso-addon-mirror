-- MAIN EVENT
function RAEIH.RegisterFirstEvent()
	EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_ADD_ON_LOADED, RAEIH.OnAddOnLoaded)
end

-- GENERAL EVENTS
function  RAEIH.RegisterEvents(register)
	if register == true then
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_ZONE_CHANGED, RAEIH.Event_NewZone)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_ZONE_UPDATED, RAEIH.Event_NewZone)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_ZONE_CHANNEL_CHANGED, RAEIH.Event_NewZone)		
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_LEVEL_UPDATE, RAEIH.Event_LevelUpdated)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_VETERAN_RANK_UPDATE, RAEIH.Event_VRUpdated)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_EXPERIENCE_UPDATE, RAEIH.Event_XPUpdated)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_VETERAN_POINTS_UPDATE, RAEIH.Event_VPUpdated)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_UNSPENT_CHAMPION_POINTS_CHANGED, RAEIH.Event_XPUpdated)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_MONEY_UPDATE, RAEIH.Event_GoldUpdated)
		-- EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS, RAEIH.Event_MailGoldTaken)
		-- EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_MAIL_READABLE, RAEIH.Event_MailReadable)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_BANKED_MONEY_UPDATE, RAEIH.Event_BankedGoldUpdated)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_PLAYER_COMBAT_STATE, RAEIH.Event_CombatStateUpdated)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_WEREWOLF_STATE_CHANGED, RAEIH_Event_WWStateUpdated)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, RAEIH.Event_WepPairChanged)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_INVENTORY_BOUGHT_BAG_SPACE, RAEIH.Event_BagSpaceBought)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_INVENTORY_BOUGHT_BANK_SPACE, RAEIH.Event_BankSpaceBought)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, RAEIH.Event_SingeSlotUpdated)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_INVENTORY_FULL_UPDATE, RAEIH.Event_AllSlotsUpdated)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_INVENTORY_ITEM_USED, RAEIH.Event_ItemUsed)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_OPEN_STORE, RAEIH.Event_StorePanelOpened)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_SKILL_POINTS_CHANGED, RAEIH.Event_SkillPointsUpdated)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_ALLIANCE_POINT_UPDATE, RAEIH.Event_AlliancePointsUpdated)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_ACHIEVEMENT_AWARDED, RAEIH.Event_AchievementAwarded)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_FRIEND_PLAYER_STATUS_CHANGED, RAEIH.Event_FriendStatusUpdated)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_STATS_UPDATED, RAEIH.Event_StatsUpdated)
		-- EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_COMBAT_EVENT, RAEIH.Event_CombatUpdated)
		-- EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_EFFECT_CHANGED, RAEIH.Event_EffectChanged)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_SKILL_XP_UPDATE, RAEIH.SetCraftingXP)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_CRAFTING_STATION_INTERACT, RAEIH.Event_CraftingOpened)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_END_CRAFTING_STATION_INTERACT, RAEIH.Event_CraftingClosed)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_CHAT_MESSAGE_CHANNEL, RAEIH.Event_NotificationMessageUpdated)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_RETICLE_TARGET_CHANGED, RAEIH.SetReticle)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_RETICLE_TARGET_PLAYER_CHANGED, RAEIH.SetReticle)
		-- EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_STEALTH_STATE_CHANGED, RAEIH.StealthUpdated)
		-- EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_DISGUISE_STATE_CHANGED, RAEIH.DisguiseUpdated)
		-- EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_ACTION_SLOT_STATE_UPDATED, RAEIH.Event_ActionSlotUpdated)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_ACTION_LAYER_POPPED, RAEIH.Event_ActionLayerPopped)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_ACTION_LAYER_PUSHED, RAEIH.Event_ActionLayerPushed)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_START_FAST_TRAVEL_INTERACTION, RAEIH.Event_FastTravelStarted)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_END_FAST_TRAVEL_INTERACTION, RAEIH.Event_FastTravelEnded)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_MOUNTED_STATE_CHANGED, RAEIH_Event_MountStateChanged)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_PLAYER_ACTIVATED, RAEIH.Event_PlayerActivated)
		EVENT_MANAGER:RegisterForEvent(RAEIH.Name, EVENT_GAME_FOCUS_CHANGED, RAEIH_Event_GameFocusChanged)			
	else
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_ZONE_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_ZONE_UPDATED)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_ZONE_CHANNEL_CHANGED)		
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_LEVEL_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_VETERAN_RANK_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_EXPERIENCE_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_VETERAN_POINTS_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_UNSPENT_CHAMPION_POINTS_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_MONEY_UPDATE)
		-- EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS)
		-- EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_MAIL_READABLE)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_BANKED_MONEY_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_PLAYER_COMBAT_STATE)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_WEREWOLF_STATE_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_INVENTORY_BOUGHT_BAG_SPACE)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_INVENTORY_BOUGHT_BANK_SPACE)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_INVENTORY_FULL_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_INVENTORY_ITEM_USED)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_OPEN_STORE)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_SKILL_POINTS_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_ALLIANCE_POINT_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_ACHIEVEMENT_AWARDED)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_FRIEND_PLAYER_STATUS_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_STATS_UPDATED)
		-- EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_COMBAT_EVENT)
		-- EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_EFFECT_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_SKILL_XP_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_CRAFTING_STATION_INTERACT)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_END_CRAFTING_STATION_INTERACT)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_CHAT_MESSAGE_CHANNEL)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_RETICLE_TARGET_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_RETICLE_TARGET_PLAYER_CHANGED)
		-- EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_STEALTH_STATE_CHANGED)
		-- EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_DISGUISE_STATE_CHANGED)
		-- EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_ACTION_SLOT_STATE_UPDATED)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_ACTION_LAYER_POPPED)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_ACTION_LAYER_PUSHED)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_START_FAST_TRAVEL_INTERACTION)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_END_FAST_TRAVEL_INTERACTION)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_MOUNTED_STATE_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_PLAYER_ACTIVATED)
		EVENT_MANAGER:UnregisterForEvent(RAEIH.Name, EVENT_GAME_FOCUS_CHANGED)
	end
end

-- New Zone
function RAEIH.Event_NewZone()
	if RAEIH.SavedVars.ShowZone == true then
		RAEIH.SetZone()
	end
end

-- Level Updated
function RAEIH.Event_LevelUpdated()
	if RAEIH.SavedVars.ShowLVR == true then
		RAEIH.SetLVR()
	end
	if RAEIH.SavedVars.ShowXVP == true then
		RAEIH.SetXVP()
	end
	if RAEIH.SavedVars.ShowAttributePoints == true then
		RAEIH.SetAttributePoints()
	end
	if RAEIH.SavedVars.ShowChampionXP == true then
		RAEIH.SetChampionXP()
	end
end

-- VR Updated
function RAEIH.Event_VRUpdated()
	if RAEIH.SavedVars.ShowLVR == true then
		RAEIH.SetLVR()
	end
	if RAEIH.SavedVars.ShowXVP == true then
		RAEIH.SetXVP()
	end
	if RAEIH.SavedVars.ShowAttributePoints == true then
		RAEIH.SetAttributePoints()
	end
	if RAEIH.SavedVars.ShowChampionXP == true then
		RAEIH.SetChampionXP()
	end
end

-- XP Updated
function RAEIH.Event_XPUpdated()
	if RAEIH.SavedVars.ShowLVR == true then
		RAEIH.SetLVR()
	end
	if RAEIH.SavedVars.ShowXVP == true then
		RAEIH.SetXVP()
	end
	if RAEIH.SavedVars.ShowAttributePoints == true then
		RAEIH.SetAttributePoints()
	end
	if RAEIH.SavedVars.ShowChampionXP == true then
		RAEIH.SetChampionXP()
	end
end

-- VP Updated
function RAEIH.Event_VPUpdated()
	if RAEIH.SavedVars.ShowLVR == true then
		RAEIH.SetLVR()
	end
	if RAEIH.SavedVars.ShowXVP == true then
		RAEIH.SetXVP()
	end
	if RAEIH.SavedVars.ShowAttributePoints == true then
		RAEIH.SetAttributePoints()
	end
	if RAEIH.SavedVars.ShowChampionXP == true then
		RAEIH.SetChampionXP()
	end
end

-- Gold Updated
function RAEIH.Event_GoldUpdated(eventCode, newMoney, oldMoney, reason)
	-- d("Reason: " .. reason)
	if RAEIH.SavedVars.EnableChamberlain == true then
		RAEIH.SetChamberlain(eventCode, newMoney, oldMoney, reason)
	end
	if RAEIH.SavedVars.ShowGold == true then
		RAEIH.SetGold()
	end
	if RAEIH.SavedVars.ShowBagSlots == true then
		RAEIH.SetBagSlots()
	end
	if RAEIH.SavedVars.ShowBankSlots == true then
		RAEIH.SetBankSlots()
	end
	if RAEIH.SavedVars.ShowRepairCost == true then
		RAEIH.SetRepairCost()
	end
	if RAEIH.SavedVars.ShowWeaponCharge == true then
		RAEIH.SetWeaponCharge()
	end
	if RAEIH.SavedVars.ShowThievery == true then
		RAEIH.SetThievery()
	end
end

-- function RAEIH.Event_MailReadable(eventCode, mailId)
-- 	d("Mail readable event executed. Mail ID is " .. tostring(mailId))
-- 	local senderAccName, senderChName, subject, icon, isUnread, isFromSystem, isFromCS, isReturned, attachmentsNum, attachedMoney, codAmount, expireTime, receivedXSecAgo = GetMailItemInfo(mailId)
-- 	d("Sender: " .. senderAccName .. " // Subject: " .. subject .. " // Is Unread: " .. tostring(isUnread) .. " // Is From System: " .. tostring(isFromSystem) .. " // Att. Num: " .. tostring(attachmentsNum) .. " // Att. Money: " .. tostring(attachedMoney))
-- end

-- function RAEIH.Event_MailGoldTaken(eventCode, mailId)
-- 	d("Mail gold taken event executed. Mail ID was " .. tostring(mailId))
-- 	local senderAccName, senderChName, subject, icon, isUnread, isFromSystem, isFromCS, isReturned, attachmentsNum, attachedMoney, codAmount, expireTime, receivedXSecAgo = GetMailItemInfo(mailId)
-- 	d("Sender: " .. senderAccName .. " // Subject: " .. subject .. " // Is Unread: " .. tostring(isUnread) .. " // Is From System: " .. tostring(isFromSystem) .. " // Att. Num: " .. tostring(attachmentsNum) .. " // Att. Money: " .. tostring(attachedMoney))
-- end

-- Banked Gold Updated
function RAEIH.Event_BankedGoldUpdated()
	if RAEIH.SavedVars.ShowBankedGold == true then
		RAEIH.SetBankedGold()
	end	
end

local fCombatCheck = 0

-- Combat State Updated
function RAEIH.Event_CombatStateUpdated()
	if RAEIH.SavedVars.ShowCombatState == true then
		RAEIH.SetCombatState()
	end
	if RAEIH.SavedVars.ShowDurability == true then
		RAEIH.SetDurability()
	end
	if RAEIH.SavedVars.ShowRepairCost == true then
		RAEIH.SetRepairCost()
	end
	if RAEIH.SavedVars.ShowWeaponCharge == true then
		RAEIH.SetWeaponCharge()
	end
	if RAEIH.SavedVars.AutoSheatWeapon == true then
		local inCombat = IsUnitInCombat("player")
		if inCombat == false and fCombatCheck == 0 then
			zo_callLater(RAEIH.Event_CombatStateUpdated, RAEIH.SavedVars.SheatTimer)
			fCombatCheck = 1
		elseif inCombat == false and fCombatCheck == 1 then
			TogglePlayerWield()
			fCombatCheck = 0
		end
	end
	if RAEIH.SavedVars.SCCByCombat == true then
		RAEIH.SCCByCombat()
	end		
end

-- Stealth State Updated
-- function RAEIH.StealthUpdated(eventCode, unitTag, stealthState)
-- 	d("Stealth Updated, Unit Tag: " .. unitTag .. " / State: " .. tostring(stealthState))
-- end

-- Disguise State Updated
-- function RAEIH.DisguiseUpdated(eventCode, unitTag, disguiseState)
-- 	d("Disguise Updated, Unit Tag: " .. unitTag .. " / State: " .. tostring(disguiseState))
-- end

-- WW State Updated
function RAEIH_Event_WWStateUpdated(eventCode, werewolf)
	if werewolf then 
		RAEIH.InWWState = true 
	else 
		RAEIH.InWWState = false
	end
end

-- Weapon Pair Changed
function RAEIH.Event_WepPairChanged()
	if RAEIH.SavedVars.ShowDurability == true then
		RAEIH.SetDurability()
	end
	if RAEIH.SavedVars.ShowRepairCost == true then
		RAEIH.SetRepairCost()
	end
	if RAEIH.SavedVars.ShowWeaponCharge == true then
		RAEIH.SetWeaponCharge()
	end
end

-- Bag Space Bought
function RAEIH.Event_BagSpaceBought()
	if RAEIH.SavedVars.ShowBagSlots == true then
		RAEIH.SetBagSlots()
	end
end

-- Bank Space Bought
function RAEIH.Event_BankSpaceBought()
	if RAEIH.SavedVars.ShowBankSlots == true then
		RAEIH.SetBankSlots()
	end
end

-- Single Slot Updated
function RAEIH.Event_SingeSlotUpdated()
	if IsUnderArrest() then return end
	if RAEIH.SavedVars.ShowBagSlots == true then
		RAEIH.SetBagSlots()
	end
	if RAEIH.SavedVars.ShowBankSlots == true then
		RAEIH.SetBankSlots()
	end
	if RAEIH.SavedVars.ShowDurability == true then
		RAEIH.SetDurability()
	end
	if RAEIH.SavedVars.ShowRepairCost == true then
		RAEIH.SetRepairCost()
	end
	if RAEIH.SavedVars.ShowSoulGems == true then
		RAEIH.SetSoulGems()
	end	
	if RAEIH.SavedVars.ShowWeaponCharge == true then
		RAEIH.SetWeaponCharge()
	end
	if RAEIH.SavedVars.ShowThievery == true then
		RAEIH.SetThievery()
	end
	if RAEIH.SavedVars.AutoWeaponChargeEnabled == true then
		RAEIH.SGtoUse = nil
		RAEIH.SGtoUseTier = nil
		RAEIH.SGtoUseILink = nil
	end
end

-- All Slots Updated
function RAEIH.Event_AllSlotsUpdated()
	if RAEIH.SavedVars.ShowBagSlots == true then
		RAEIH.SetBagSlots()
	end
	if RAEIH.SavedVars.ShowBankSlots == true then
		RAEIH.SetBankSlots()
	end
	if RAEIH.SavedVars.ShowDurability == true then
		RAEIH.SetDurability()
	end
	if RAEIH.SavedVars.ShowRepairCost == true then
		RAEIH.SetRepairCost()
	end
	if RAEIH.SavedVars.ShowSoulGems == true then
		RAEIH.SetSoulGems()
	end	
	if RAEIH.SavedVars.ShowWeaponCharge == true then
		RAEIH.SetWeaponCharge()
	end
	if RAEIH.SavedVars.ShowThievery == true then
		RAEIH.SetThievery()
	end
	if RAEIH.SavedVars.AutoWeaponChargeEnabled == true then
		RAEIH.SGtoUse = nil
		RAEIH.SGtoUseTier = nil
		RAEIH.SGtoUseILink = nil
	end
end

-- Item Used
function RAEIH.Event_ItemUsed()
	if RAEIH.SavedVars.ShowBagSlots == true then
		RAEIH.SetBagSlots()
	end
	if RAEIH.SavedVars.ShowBankSlots == true then
		RAEIH.SetBankSlots()
	end
	if RAEIH.SavedVars.ShowDurability == true then
		RAEIH.SetDurability()
	end
	if RAEIH.SavedVars.ShowRepairCost == true then
		RAEIH.SetRepairCost()
	end
	if RAEIH.SavedVars.ShowSoulGems == true then
		RAEIH.SetSoulGems()
	end	
	if RAEIH.SavedVars.ShowWeaponCharge == true then
		RAEIH.SetWeaponCharge()
	end
	if RAEIH.SavedVars.ShowThievery == true then
		RAEIH.SetThievery()
	end
	if RAEIH.SavedVars.AutoWeaponChargeEnabled == true then
		RAEIH.SGtoUse = nil
		RAEIH.SGtoUseTier = nil
		RAEIH.SGtoUseILink = nil
	end
end

-- Skill Points Updated
function RAEIH.Event_SkillPointsUpdated()
	if RAEIH.SavedVars.ShowSkillPoints == true then
		RAEIH.SetSkillPoints()
	end
	if RAEIH.SavedVars.ShowSkyShards == true then
		RAEIH.SetSkyShards()
	end
end

-- Alliance Points Updated
function RAEIH.Event_AlliancePointsUpdated()
	if RAEIH.SavedVars.ShowAlliancePoints == true then
		RAEIH.SetAlliancePoints()
	end
	if RAEIH.SavedVars.ShowAvARank == true then
		RAEIH.SetAvARank()
	end
end

-- Achievements Awarded
function RAEIH.Event_AchievementAwarded()
	if RAEIH.SavedVars.ShowAchievementPoints == true then
		RAEIH.SetAchievementPoints()
	end
end

-- Friend Status Updated
function RAEIH.Event_FriendStatusUpdated()
	if RAEIH.SavedVars.ShowFriends == true then
		RAEIH.SetFriends()
	end
end

-- Stats Updated
function RAEIH.Event_StatsUpdated()
	if RAEIH.SavedVars.ShowAttributePoints == true then
		RAEIH.SetAttributePoints()
	end
end

-- Crafting Screen Opened
function RAEIH.Event_CraftingOpened()
	local clrDft = "|c" .. RAEIH.SavedVars.CraftingXPDefaultColour
	RAEIH.CraftingXPText = clrDft .. "Waiting to Craft"
	RAEIH_CraftingXP_String:SetText(RAEIH.CraftingXPText)
	if RAEIH.SavedVars.AutoShowCraftingXP == true then
		RAEIH_CraftingXP:SetHidden(false)	
	end
end

-- Crafting Screen Closed
function RAEIH.Event_CraftingClosed()
	local clrDft = "|c" .. RAEIH.SavedVars.CraftingXPDefaultColour
	RAEIH.CraftingXPText = clrDft .. "Waiting to Craft"
	RAEIH_CraftingXP_String:SetText(RAEIH.CraftingXPText)
	if RAEIH.SavedVars.AutoShowCraftingXP == true then
		RAEIH_CraftingXP:SetHidden(true)	
	end
end

-- Store Panel Opened
function RAEIH.Event_StorePanelOpened()
	if RAEIH.SavedVars.AutoRepairEnabled == true then
		RAEIH.AutoRepairItems()
	end
end

-- Mount State Changed
function RAEIH_Event_MountStateChanged(eventCode, mounted)
	if RAEIH.SavedVars.SWWM == true and mounted == true then
		RAEIH.SWWM_Refresh()
	end
end

-- PLAYER ACTIVATED
local isMDDone = false
function RAEIH.Event_PlayerActivated()

	RAEIH.ChangeReticleTexture()
	RAEIH.LegatusCFAdj()
	RAEIH.CreateGrid()

	if isMDDone == false then
		RAEIH.CreateModuleTable()
		isMDDone = true
	end

	if RAEIH.SavedVars.EnableLegatus == true then		
		RAEIH.CreateLegatus()
		RAEIH.OrganizeLegatus()
	end

	if RAEIH.SavedVars.ShowZone == true then
		RAEIH.SetZone()
	end

	if RAEIH.SavedVars.SWWM == true and IsMounted() == true then
		zo_callLater(RAEIH.SWWM_Refresh, 3000)
		zo_callLater(RAEIH.SWWM_Refresh, 12000)
	end

	if RAEIH.SavedVars.InfoHubFirstTime == true then
		local clrDft = "|cFFFFFF"
		local clrR = "|c3A5FCD"
		d(clrDft .. "Welcome to the " .. clrR .. "RAETIA " .. clrDft .. "InfoHub" .. clrR .. tostring(RAEIH.Version) .. "\n" .. clrDft .. "Enter to InfoHub settings to get started...")
		RAEIH.SavedVars.InfoHubFirstTime = false
	end

	if RAEIH.SavedVars.AvAAutoShow == true and RAEIH_AvARank ~= nil then
		RAEIH.SetAvARank()
	end

	RAEIH.SavedVars.ZDone = false
	RAEIH.SavedVars.AnimTracker = false
	-- RAEIH.FragmentManager()	
end

-- Notification Message Updated
function RAEIH.Event_NotificationMessageUpdated(eventCode, messageType, fromName, text)
	RAEIH.SetSubtitles(eventCode, messageType, fromName, text)
	RAEIH.SetNotification(eventCode, messageType, fromName, text)
end

-- Action Layer Pushed (Screen Shown)
function RAEIH.Event_ActionLayerPushed(eventCode, layerIndex, activeLayerIndex)
	if RAEIH.SavedVars.ZDone == false and RAEIH.SavedVars.AWMZ == true then
		RAEIH.SavedVars.StartMapTimer = true		
	end
end

-- Action Layer Popped (Screen Hid)
function RAEIH.Event_ActionLayerPopped(eventCode, layerIndex, activeLayerIndex)
	if RAEIH.SavedVars.ZDone == true and RAEIH.SavedVars.AWMZ == true then
		RAEIH.SavedVars.ZDone = false
	end
end

-- Fast Travel Interaction Started
function RAEIH.Event_FastTravelStarted()
	if RAEIH.SavedVars.ZDone == false then
		RAEIH.SavedVars.StartMapTimer = true				
	end
end

-- Fast Travel Interaction Ended
function RAEIH.Event_FastTravelEnded()
	if RAEIH.SavedVars.ZDone == true then
		RAEIH.SavedVars.ZDone = false
	end
end

-- Game Focus Changed
function RAEIH_Event_GameFocusChanged(eventCode, hasFocus)
	if hasFocus == true and RAEIH.SavedVars.ShowSubtitles == true then
		-- d("Has focus...")
		RAEIH_Subtitles_String:SetHidden(true)
	end
end

-- Action Slot Updated

-- function RAEIH.Event_ActionSlotUpdated(eventCode, slotNum)
-- 	d("----------\nAction Slot Updated!")
-- end

-- Combat Updated

-- function RAEIH.Event_CombatUpdated(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log)	
-- 	d("----------\nEvent Code: " .. tostring(eventCode) .. "\nResult: " .. tostring(result) .. "\nIs Error: " .. tostring(isError) .. "\nAbility Name: " .. tostring(abilityName) .. "\nAbility Graphic: " .. tostring(abilityGraphic) .. "\nAbility Action Slot Type: " .. tostring(abilityActionSlotType) .. "\nSource Name: " .. tostring(sourceName) .. "\nSource Type: " .. tostring(sourceType) .. "\nTarget Name: " .. tostring(targetName) .. "\nTarget Type: " .. tostring(targetType) .. "\nHit Value: " .. tostring(hitValue) .. "\nPower Type: " .. tostring(powerType) .. "\nDamage Type: " .. tostring(damageType) .. "\nLog: " .. tostring(log))
-- end

-- Combat Effect Changed

-- function RAEIH.Event_EffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType)
-- 	d("----------\nEvent Code: " .. tostring(eventCode) .. "\nChange Type: " .. tostring(changeType) .. "\nEffect Slot: " .. tostring(effectSlot) .. "\nEffect Name: " .. tostring(effectName) .. "\nUnit Tag: " .. tostring(unitTag) .. "\nBegin Time: " .. tostring(beginTime) .. "\nEnd Time: " .. tostring(endTime) .. "\nStack Count: " .. tostring(stackCount) .. "\nIcon Name: " .. tostring(iconName) .. "\nBuff Type: " .. tostring(buffType) .. "\nEffect Type: " .. tostring(effectType) .. "\nAbility Type: " .. tostring(abilityType) .. "\nStatus Effect Type: " .. tostring(statusEffectType))
-- end