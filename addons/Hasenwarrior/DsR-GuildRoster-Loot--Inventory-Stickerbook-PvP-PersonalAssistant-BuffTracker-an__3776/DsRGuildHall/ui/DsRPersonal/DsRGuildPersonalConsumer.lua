-- Create namespace
DsRGuildPersonalConsumer = {}
local DsRGuildPersonalConsumer = DsRGuildPersonalConsumer  or {}
local LFDB = LIB_FOOD_DRINK_BUFF

DsRGuildPersonalConsumer.name = "DsRGuildPersonalConsumer"

local update_timer_period 				= 30000 	-- milliseconds
local player_unit_tag     				= "player"
local low_inventory_warning_threshold 	= 5 -- items
local consumed_message_delay 			= 1000 -- milliseconds

local SPRINT_STATE_ACTIVE 	= 1
local SPRINT_STATE_NONE 	= 0

-------------------------------------------------------------------------------------------------------------------------------------------------
local function IsPlayerSprinting()
	local hotbarCategory = HOTBAR_CATEGORY_BACKUP
	if GetActiveWeaponPairInfo() == ACTIVE_WEAPON_PAIR_MAIN then
		hotbarCategory = HOTBAR_CATEGORY_PRIMARY
	end
	for i = 3,  8 do
		local slotHighlighted = not ActionSlotHasNonCostStateFailure(i, hotbarCategory)
		if slotHighlighted then
		   return SPRINT_STATE_NONE
		end    
	end 
	return SPRINT_STATE_ACTIVE
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function IsUnitAbleToUseFood(unitTag) -- Returns: boolean isAbleToUseFood
	if IsUnitInCombat(unitTag) then return
	elseif IsUnitDeadOrReincarnating(unitTag) then return
	elseif IsUnitSwimming(unitTag) then return
	elseif IsPlayerInteractingWithObject() then return
	elseif IsScryingInProgress() then return
	elseif IsDiggingGameActive() then return
	elseif TRIBUTE_SCENE:IsShowing() then return
	elseif IsPlayerSprinting() == SPRINT_STATE_ACTIVE then return
	else return true end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- General
-------------------------------------------------------------------------------------------------------------------------------------------------
local function GetBackpackInventory(itemLink)
	local inventoryCount = 0

	if itemLink == "" then return inventoryCount end

	local numSlots = GetBagSize(BAG_BACKPACK)
	
	for slotIndex = 0, numSlots do
		local slotItemLink = GetItemLink(BAG_BACKPACK, slotIndex)
		if slotItemLink == itemLink then
			local itemCount = GetItemTotalCount(BAG_BACKPACK, slotIndex)
			inventoryCount = inventoryCount + itemCount
		end
	end
	return inventoryCount
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function CanUseItem(bagId, slotIndex)
	local usable, usableOnlyFromActionSlot = IsItemUsable(bagId, slotIndex)
	local canInteract = CanInteractWithItem(bagId, slotIndex)
	return usable and not usableOnlyFromActionSlot and canInteract
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function ShowLowInventoryWarning(itemLink)
	local remainingInventory = GetBackpackInventory(itemLink)

	if remainingInventory <= low_inventory_warning_threshold then
		d(" |c9fb6cd[DsR-Consumer]|r " .. zo_strformat(GetString(DsRGuildPersonal_ConsumeAttention), remainingInventory))
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function VerifyConsumed(itemLink)
	local isBuffActive, timeLeftInSeconds, abilityId = LFDB:IsFoodBuffActiveAndGetTimeLeft(player_unit_tag)
	return isBuffActive and timeLeftInSeconds > 100
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function ShowConsumedMessage(itemLink)
	if VerifyConsumed(itemLink) then
		d(" |c9fb6cd[DsR-Consumer]|r " .. GetString(DsRGuildPersonal_ConsumeEating) .. itemLink)
		ShowLowInventoryWarning(itemLink)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- ConsumeXP
-------------------------------------------------------------------------------------------------------------------------------------------------
local function IsValidXP(bagId, slotIndex)
	if not DsRGuildPersonalConsumer.IsXPbuff(bagId, slotIndex) then return false end
	return true
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function TryUseXPItem(bagId, slotIndex)
	if IsValidXP(bagId, slotIndex) then
		if CanUseItem(bagId, slotIndex) then
			local success = CallSecureProtected("UseItem", bagId, slotIndex)
			return success
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalConsumer.IsXPbuff(bagId, slotIndex)
	local itemId 	  = GetItemId(bagId, slotIndex)
	local itemTexture = GetItemInfo(bagId, slotIndex)

	if		itemId == 64221		then return	true	-- Psijic Ambrosia
	elseif	itemId == 120076	then return	true	-- Aetherial Ambrosia
	elseif	itemId == 115027	then return	true	-- Mythic Aetherial Ambrosia
	elseif  itemTexture:find("experiencescroll") then return true -- Experience Scrolls
	else return false end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function DsRGuildPersonalConsumer_TimeForConsumeXP()
	local paramsXP = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.BOOK_ACQUIRED)
	paramsXP:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
	paramsXP:SetLifespanMS(3500)

	local NoXPBuff = true

	local numBuffs         = GetNumBuffs(player_unit_tag)
	local hasActiveEffects = numBuffs > 0

	if hasActiveEffects then
		for i = 1, numBuffs do
			local buffName,_,timeEnding,_,_,iconFilename,_,_,_,_,abilityId,_,_ = GetUnitBuffInfo(player_unit_tag, i)
			if abilityId == 63570 or abilityId == 64210 or abilityId == 64537 or abilityId == 64630 
			or abilityId == 66776 or abilityId == 85501 or abilityId == 85502 or abilityId == 85503 or abilityId == 88445
			or abilityId == 89683 or abilityId == 99462 or abilityId == 99463 or abilityId == 135110 or abilityId == 138811
			then 
				local XPtimeLeftsec = math.floor(timeEnding - (GetFrameTimeMilliseconds()/1000))
				local XPtimeLeftmin = math.floor(XPtimeLeftsec / 60)

				local XPBuffer = math.floor(tonumber(DsRGuildLoot.sV.DsRReminderxpMinTime) * 60)

				if XPBuffer > 0 and XPtimeLeftsec <= XPBuffer then
					local XPAbIdName    = GetAbilityName(abilityId)
					local XPAdIdIcon    = GetAbilityIcon(abilityId)
					local XPAdIdColor   = "|cF7C42A"
					local XPmsg         = zo_iconTextFormat(XPAdIdIcon, 46, 46, "") .. XPAdIdColor .. XPAbIdName:gsub("%^.*", "")
					if XPtimeLeftsec < 119 then
						local XPmsgTime = zo_strformat(GetString(DsRGuildPersonal_ConsumeXPendSec), XPtimeLeftsec)
						paramsXP:SetText(XPmsg, XPmsgTime)
						CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(paramsXP)
					else
						local XPmsgTime = zo_strformat(GetString(DsRGuildPersonal_ConsumeXPendMin), XPtimeLeftmin)
						paramsXP:SetText(XPmsg, XPmsgTime)
						CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(paramsXP)
					end
				end
				NoXPBuff = false
			end
		end
		if NoXPBuff == true then 
			if DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoXPOnOff"] and DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatXP"] ~= nil then
				DsRGuildPersonalConsumer.EatXP()
			elseif DsRGuildLoot.sV.DsRReminderxpfalse == true then
				paramsXP:SetText(GetString(DsRGuildPersonal_ConsumeXPend))
				CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(paramsXP)
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalConsumer.EatXP()
	local numSlots = GetBagSize(BAG_BACKPACK)
	
	for slotIndex = 0, numSlots do
		local slotItemLink = GetItemLink(BAG_BACKPACK, slotIndex)
		if slotItemLink == DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatXP"] then
			local success = TryUseXPItem(BAG_BACKPACK, slotIndex)
			if success then
				zo_callLater(function() ShowConsumedMessage(slotItemLink) end, consumed_message_delay)	
				return true
			else
				return false
			end
		end
	end
	
	-- XP-Scroll wasn't found
	if DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoXPOnOff"] == true then
		d(" |c9fb6cd[DsR-Consumer]|r " .. GetString(DsRGuildPersonal_ConsumeAttentionA1) .. DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatXP"] .. GetString(DsRGuildPersonal_ConsumeAttentionA2))
		DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoXPOnOff"] = false
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- ConsumeAP
-------------------------------------------------------------------------------------------------------------------------------------------------
local function IsValidAP(bagId, slotIndex)
	if not DsRGuildPersonalConsumer.IsAPbuff(bagId, slotIndex) then return false end
	return true
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function TryUseAPItem(bagId, slotIndex)
	if IsValidAP(bagId, slotIndex) then
		if CanUseItem(bagId, slotIndex) then
			local success = CallSecureProtected("UseItem", bagId, slotIndex)
			return success
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalConsumer.IsAPbuff(bagId, slotIndex)
	local itemId 	  = GetItemId(bagId, slotIndex)
	
	if   	itemId == 171323	then return	true	-- Colovian War Torte
	elseif	itemId == 171329	then return	true	-- Molten War Torte
	elseif	itemId == 171432	then return	true	-- White-Gold War Torte
	else return false end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function DsRGuildPersonalConsumer_TimeForConsumeAP()
	local paramsAP = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.BOOK_ACQUIRED)
	paramsAP:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
	paramsAP:SetLifespanMS(3500)
			
	local NoAPBuff = true

	local APnumBuffs         = GetNumBuffs(player_unit_tag)
	local APhasActiveEffects = APnumBuffs > 0

	if APhasActiveEffects then
		for i = 1, APnumBuffs do
			local buffName,_,timeEnding,_,_,iconFilename,_,_,_,_,abilityId,_,_ = GetUnitBuffInfo(player_unit_tag, i)
			if abilityId == 137733 or abilityId == 147466 or abilityId == 147467 or abilityId == 147687
			or abilityId == 147733 or abilityId == 147734 or abilityId == 147797
			then 
				local APtimeLeftsec = math.floor(timeEnding - (GetFrameTimeMilliseconds()/1000))
				local APtimeLeftmin = math.floor(APtimeLeftsec / 60)

				local APBuffer = math.floor(tonumber(DsRGuildLoot.sV.DsRReminderapMinTime) * 60)
				if APBuffer > 0 and APtimeLeftsec <= APBuffer then
					local APAbIdName    = GetAbilityName(abilityId)
					local APAdIdIcon    = GetAbilityIcon(abilityId)
					local APAdIdColor   = "|cF7C42A"
					local APmsg         = zo_iconTextFormat(APAdIdIcon, 46, 46, "") .. APAdIdColor .. APAbIdName:gsub("%^.*", "")
					if APtimeLeftsec < 119 then
						local APmsgTime = zo_strformat(GetString(DsRGuildPersonal_ConsumeAPendSec), APtimeLeftsec)
						paramsAP:SetText(APmsg, APmsgTime)
						CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(paramsAP)
					else
						local APmsgTime = zo_strformat(GetString(DsRGuildPersonal_ConsumeAPendMin), APtimeLeftmin)
						paramsAP:SetText(APmsg, APmsgTime)
						CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(paramsAP)
					end
				end
				NoAPBuff = false
			end
		end
		
		local inPvPZone      = IsPlayerInPvP()
		local inImperialZone = IsInImperialCity()

		if inPvPZone == true and inImperialZone == false then
			if NoAPBuff == true then
				if DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoAPOnOff"] and DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatAP"] ~= nil then
					DsRGuildPersonalConsumer.EatAP()
				elseif DsRGuildLoot.sV.DsRReminderapfalse == true then
					paramsAP:SetText(GetString(DsRGuildPersonal_ConsumeAPend))
					CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(paramsAP)
				end
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function IsPlayerInPvP()
	return IsPlayerInAvAWorld() or IsActiveWorldBattleground()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalConsumer.EatAP()
	local numSlots = GetBagSize(BAG_BACKPACK)
	
	for slotIndex = 0, numSlots do
		local slotItemLink = GetItemLink(BAG_BACKPACK, slotIndex)
		if slotItemLink == DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatAP"] then
			local success = TryUseAPItem(BAG_BACKPACK, slotIndex)
			if success then
				zo_callLater(function() ShowConsumedMessage(slotItemLink) end, consumed_message_delay)	
				return true
			else
				return false
			end
		end
	end
	
	-- AP-Scroll wasn't found
	if DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoAPOnOff"] == true then
		d(" |c9fb6cd[DsR-Consumer]|r " .. GetString(DsRGuildPersonal_ConsumeAttentionA1) .. DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatAP"] .. GetString(DsRGuildPersonal_ConsumeAttentionA2))
		DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoAPOnOff"] = false
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Buff-Food
-------------------------------------------------------------------------------------------------------------------------------------------------
local function IsValidFoodOrDrink(bagId, slotIndex)
	local itemType = GetItemType(bagId, slotIndex)
	if DsRGuildPersonalConsumer.IsAPbuff(bagId, slotIndex) then return false end
	if DsRGuildPersonalConsumer.IsXPbuff(bagId, slotIndex) then return false end
	if not (itemType == ITEMTYPE_DRINK or itemType == ITEMTYPE_FOOD) then 
		return false
	end
	return true
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function TryUseFoodItem(bagId, slotIndex)
	if IsValidFoodOrDrink(bagId, slotIndex) then
		if CanUseItem(bagId, slotIndex) then
			local success = CallSecureProtected("UseItem", bagId, slotIndex)
			return success
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function DsRGuildPersonalConsumer_TimeForEatFood(FOODabilityId)
	local isBuffActive, timeLeftInSeconds, abilityId = LFDB:IsFoodBuffActiveAndGetTimeLeft(player_unit_tag)
	local timeLeftInMinutes = math.floor(timeLeftInSeconds / 60)

	local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_ANIMATED_CONTROL, SOUNDS.BOOK_ACQUIRED)

	params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
	params:SetLifespanMS(3500)

	if isBuffActive then
		local AbIdName  = GetAbilityName(FOODabilityId)
		local AdIdIcon  = GetAbilityIcon(FOODabilityId)
		local AdIdColor = "|c8525FA"
		local msgFood   = zo_iconTextFormat(AdIdIcon, 46, 46, "") .. AdIdColor .. AbIdName:gsub("%^.*", "")

		if timeLeftInSeconds < 119 then
			local msgTime = zo_strformat(GetString(DsRGuildPersonal_ConsumeFoodendSec), timeLeftInSeconds)
			params:SetText(msgFood, msgTime)

			CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
		else
			local msgTime = zo_strformat(GetString(DsRGuildPersonal_ConsumeFoodendMin), timeLeftInMinutes)
			params:SetText(msgFood, msgTime)

			CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalConsumer.EatFood()
	local numSlots = GetBagSize(BAG_BACKPACK)
	
	for slotIndex = 0, numSlots do
		local slotItemLink = GetItemLink(BAG_BACKPACK, slotIndex)
		if slotItemLink == DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatTyp"] then
			local success = TryUseFoodItem(BAG_BACKPACK, slotIndex)
			if success then
				zo_callLater(function() ShowConsumedMessage(slotItemLink) end, consumed_message_delay)	
				return true
			else
				return false
			end
		end
	end
	
	-- Bufffood wasn't found
	if DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatTime"] ~= "0" then
		d(" |c9fb6cd[DsR-Consumer]|r " .. GetString(DsRGuildPersonal_ConsumeAttentionA1) .. DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatTyp"] .. GetString(DsRGuildPersonal_ConsumeAttentionA2))
		DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatTime"] = "0"
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- OnUpdateTimer
-------------------------------------------------------------------------------------------------------------------------------------------------
local function DsRGuildPersonalConsumer_OnUpdateTimer() 
	if not IsUnitAbleToUseFood(player_unit_tag) then
		EVENT_MANAGER:RegisterForUpdate(DsRGuildPersonalConsumer.name, 5000, DsRGuildPersonalConsumer_OnUpdateTimer)
		return
	else
		EVENT_MANAGER:RegisterForUpdate(DsRGuildPersonalConsumer.name, update_timer_period, DsRGuildPersonalConsumer_OnUpdateTimer)
	end
	
	local isFoodBuffActive, foodTimeLeftInSeconds, FOODabilityId = LFDB:IsFoodBuffActiveAndGetTimeLeft(player_unit_tag)
	
	if DsRGuildLoot.sV.DsRReminderfoodOnOff == true then
		if isFoodBuffActive then
			local foodBuffer = math.floor(tonumber(DsRGuildLoot.sV.DsRReminderBuffFoodMinTime) * 60)
			if foodBuffer > 0 and foodTimeLeftInSeconds <= foodBuffer then
				DsRGuildPersonalConsumer_TimeForEatFood(FOODabilityId)
			end
		elseif DsRGuildLoot.sV.DsRReminderfoodfalse == true then
			local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.BOOK_ACQUIRED)
			params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
			params:SetLifespanMS(3500)
			
			params:SetText(GetString(DsRGuildPersonal_ConsumeFoodend))
			CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
		end
	end
	
	if DsRGuildLoot.sV.DsRReminderxpOnOff == true then
		DsRGuildPersonalConsumer_TimeForConsumeXP()
	end
	
	if DsRGuildLoot.sV.DsRReminderapOnOff == true then
		DsRGuildPersonalConsumer_TimeForConsumeAP()
	end

	if DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatTime"] == nil or DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatTime"] == 0 then return end
	if DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatTyp"] == nil or DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatTyp"] == "" then return end
	
	local AUTOfoodBuffer = math.floor(tonumber(DsRGuildPersonal.GetSettings()["DeconJunk"]["ConsumeAutoEatTime"]) * 60)

	if foodTimeLeftInSeconds <= AUTOfoodBuffer then
		DsRGuildPersonalConsumer.EatFood()
	end
end	

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Initialize
-------------------------------------------------------------------------------------------------------------------------------------------------
local function Initialize() 
	EVENT_MANAGER:RegisterForUpdate(DsRGuildPersonalConsumer.name, update_timer_period, DsRGuildPersonalConsumer_OnUpdateTimer)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- OnAddOnLoaded
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalConsumer.OnAddOnLoaded(event, name)
	EVENT_MANAGER:UnregisterForEvent(DsRGuildPersonalConsumer.Name, eventCode)
	if DsRGuildPersonal.ACCconfig.ConsumeOnOff then
		Initialize()
	end
end
