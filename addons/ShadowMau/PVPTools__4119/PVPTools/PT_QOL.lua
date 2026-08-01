-- ***** Pawprint's PVP Tools - Quality Of Life *****



--------------------------------------------------
-- Initialize our namespace and variables
--------------------------------------------------
if not PVPTools then PVPTools = {} end
if not PVPTools.QOL then PVPTools.QOL = {} end
local PT = PVPTools
local QOL = PVPTools.QOL
QOL.multiMountsList = {}
local QOLTag = "|c62d27f[QOL] |r"


--------------------------------------------------
-- SETTINGS FUNCTIONS
--------------------------------------------------


--------------------------------------------------
-- ToggleCenterAnnounce - toggle use of the center screen announcements
--------------------------------------------------
function QOL.ToggleCenterAnnounce()
	if PT.debug then PT.DebugEntry("PVPTools.QOL.ToggleCenterAnnounce") end
	
	PVPTools.ASV.settingsQOLCenterAnnounce = not PVPTools.ASV.settingsQOLCenterAnnounce
end


--------------------------------------------------
-- ToggleAlert - toggle use of the right side announcements
--------------------------------------------------
function QOL.ToggleAlert()
	if PT.debug then PT.DebugEntry("PVPTools.QOL.ToggleAlert") end
	
	PVPTools.ASV.settingsQOLAlert = not PVPTools.ASV.settingsQOLAlert
end


--------------------------------------------------
-- ToggleMultiMountOnly - toggle use of multimount only
--------------------------------------------------
function QOL.ToggleMultiMountOnly(hotkey)
	if PT.debug then PT.DebugEntry("PVPTools.QOL.ToggleMultiMountOnly") end
	
	if FavoriteMount then
		PVPTools.ASV.settingsQOLMultimountOn = false
		QOL.ResetCharacterMountInfo()
		PT.CheckEventRegistrations()
		PT.AMS.DisplayMessage("|c62d27f[QOL] keybind passed to FavoriteMount|r")
		FavoriteMount.SetOnlyMultimount(not FavoriteMount.CSV.onlyMultiMount, true)
	else
		PVPTools.ASV.settingsQOLMultimountOn = not PVPTools.ASV.settingsQOLMultimountOn
		if PVPTools.ASV.settingsQOLMultimountOn then 
			QOL.PopulateMultiMountsList()
			QOL.SaveCharacterMountInfo()
			PT.CheckEventRegistrations()
			QOL.SwitchMount(false)
			PVPTools.AMS.DisplayMessage("|c62d27fStart using multimounts only|r", "qol")
		else
			if PVPTools.CSV.randomMountType == RANDOM_MOUNT_TYPE_NONE then
				UseCollectible(PVPTools.CSV.savedMount, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
			else
				SetRandomMountType(PVPTools.CSV.randomMountType, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
			end
			
			QOL.ResetCharacterMountInfo()
			PT.CheckEventRegistrations()
			PVPTools.AMS.DisplayMessage("|c62d27fStop using multimounts only|r", "qol")		
		end
		if hotkey then PlaySound(SOUNDS.ARMORY_OPEN) end
	end
end


--------------------------------------------------
-- ToggleAutoAcceptQueue - toggle automatically accepting PVP queues
--------------------------------------------------
function QOL.ToggleAutoAcceptQueue()
	if PT.debug then PT.DebugEntry("PVPTools.QOL.ToggleAutoAcceptQueue") end
	
	PVPTools.ASV.settingsQOLAutoAcceptQueue = not PVPTools.ASV.settingsQOLAutoAcceptQueue
	
	if PVPTools.ASV.settingsQOLAutoAcceptQueue then
		PT.CheckEventRegistrations()
	else
		PT.CheckEventRegistrations()
	end
end


--------------------------------------------------
-- ToggleEmergencyExit - toggle using the PVP queue options
--------------------------------------------------
function QOL.ToggleEmergencyExit()
	if PT.debug then PT.DebugEntry("PVPTools.QOL.ToggleEmergencyExit") end
	
	PVPTools.ASV.settingsQOLEmergencyExit = not PVPTools.ASV.settingsQOLEmergencyExit
end


--------------------------------------------------
-- ToggleQueueGroup - option to queue the entire group if you are in a group and are group leader
--------------------------------------------------
function QOL.ToggleQueueGroup()
	if PT.debug then PT.DebugEntry("PVPTools.QOL.ToggleQueueGroup") end
	
	PVPTools.ASV.settingsQOLQueueGroup = not PVPTools.ASV.settingsQOLQueueGroup
end

--------------------------------------------------
-- MULTIMOUNT FUNCTIONS
--------------------------------------------------


--------------------------------------------------
-- ResetCharacterMountInfo - reset the mount related character saved variables back to defaults
--------------------------------------------------
function QOL.ResetCharacterMountInfo()
	if PT.debug then PT.DebugEntry("PVPTools.QOL.ResetCharacterMountInfo") end
	
	PVPTools.CSV.randomMountType = RANDOM_MOUNT_TYPE_NONE
	PVPTools.CSV.savedMount = 2
end


--------------------------------------------------
-- SaveCharacterMountInfo - save the mount information for the current character
--------------------------------------------------
function QOL.SaveCharacterMountInfo()
	if PT.debug then PT.DebugEntry("PVPTools.QOL.SaveCharacterMountInfo") end
	
	local randomMountType = GetRandomMountType(GAMEPLAY_ACTOR_CATEGORY_PLAYER)
	
	if (randomMountType == RANDOM_MOUNT_TYPE_NONE) and (PVPTools.CSV.savedMount == 2) then
		PVPTools.CSV.savedMount = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
	else
		PVPTools.CSV.randomMountType = randomMountType
	end
end


--------------------------------------------------
-- PopulateMultiMountsList - populate a list of unlocked multimounts
--------------------------------------------------
function QOL.PopulateMultiMountsList()
	if PT.debug then PT.DebugEntry("PVPTools.QOL.PopulateMultiMountsList") end
	-- TODO if the favorite mount addon is active then settingsQOLMultimountOn should be set to false and the saved variables reset to default.
	local multiMountCounter = 0
	local totalUnlockedMounts = GetTotalUnlockedCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
	if totalUnlockedMounts > 0 then
		for counter = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MOUNT) do
			local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MOUNT, counter)
			local name, description, unlockedTexture, lockedTexture, unlocked, purchasable, isActive, categoryType, hint = GetCollectibleInfo(collectibleId)
			if unlocked and (hint ~= "" and string.find(hint, "Multi%-Rider")) then
				multiMountCounter = multiMountCounter + 1
				QOL.multiMountsList[multiMountCounter] = collectibleId
			end
		end
	end
end


--------------------------------------------------
-- SwitchMount - randomly select a new mount
--------------------------------------------------
function QOL.SwitchMount(mounted)
	if PT.debug then PT.DebugEntry("PVPTools.QOL.SwitchMount") end
	
	if (not mounted) then
		local activeMount = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
		local newMount = activeMount
		
		if #QOL.multiMountsList == 1 then
			newMount = QOL.multiMountsList[1]
		elseif #QOL.multiMountsList > 1 then
			while activeMount == newMount do
				newMount = QOL.multiMountsList[math.random(#QOL.multiMountsList)]
			end
		end
		
		if PT.debug then PT.DebugEntry(PT.Spacer().."Active mount: "..activeMount.." - New mount: "..newMount) end
		if newMount ~= activeMount then
			zo_callLater(function() PVPTools.QOL.FireMountSwitch(newMount, 0) end, 1500)
		end
	end
end


--------------------------------------------------
-- FireMountSwitch - make up to five attempts to activate the new mount
--------------------------------------------------
function QOL.FireMountSwitch(newMount, counter)
	if PT.debug then
		PT.DebugEntry("PVPTools.QOL.FireMountSwitch")
		PT.DebugEntry(PT.Spacer().."New Mount: "..newMount.." Attemp: "..counter)
	end
	
	if counter < 5 then
		if not IsCollectibleActive(newMount) then
			if not IsMounted() then
				UseCollectible(newMount, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
				counter = counter + 1
				zo_callLater(function() PVPTools.QOL.FireMountSwitch(newMount, counter) end, (500 * counter))
			end
		end
	end
end


--------------------------------------------------
-- RideMultimount - attempt to use the target's multimount as a passenger
--------------------------------------------------
function QOL.RideMultimount()
	UseMountAsPassenger(GetUnitNameHighlightedByReticle())
end


--------------------------------------------------
-- KEEP RECALL STONE FUNCTIONS
--------------------------------------------------


--------------------------------------------------
-- UseKeepRecallStone - attempt to use a keep recall stone
--------------------------------------------------
function QOL.UseRecallStone()
	if PT.debug then PT.DebugEntry("PVPTools.QOL.UseRecallStone") end
	-- TODO Rewrite to use new function PVPTools.FindSlotInBackpackByItemName(itemName)
	-- TODO Edit code for more efficiency
	
	if IsInCyrodiil() then
		local recallStoneId = 141731 --https://esoitem.uesp.net/itemLink.php?&itemid=141731&quality=5
		local bag = BAG_BACKPACK
		local slot = ZO_GetNextBagSlotIndex(bag)
	
		while slot do
			if GetItemId(bag, slot) == recallStoneId then break end
			-- GetSlotStackSize(bagid, slotindex)
			slot = ZO_GetNextBagSlotIndex(bag, slot)
		end
	
		if slot then
			local remaining = GetItemTotalCount(bag, slot) - 1
			if remaining < 5 then
				PT.AMS.DisplayMessage("|cFFFF00You have "..remaining.." Keep Recall Stones left|r", "qol")
				PlaySound(PT.soundWarning)
			end
			if IsProtectedFunction("UseItem") then
				CallSecureProtected("UseItem", bag, slot) -- https://wiki.esoui.com/API#Protected_Functions
			else
				UseItem(bag, slot)
			end
		else
			PT.AMS.DisplayMessage("|cFFFF00You have NO Keep Recall Stones left|r", "qol")
			PlaySound(PT.soundWarning)
		end
	end
	
	if IsInImperialCity() then
		local recallStoneId = 68347 --https://esoitem.uesp.net/itemLink.php?&itemid=68347&quality=5
		local bag = BAG_BACKPACK
		local slot = ZO_GetNextBagSlotIndex(bag)
	
		while slot do
			if GetItemId(bag, slot) == recallStoneId then break end
			-- GetSlotStackSize(bagid, slotindex)
			slot = ZO_GetNextBagSlotIndex(bag, slot)
		end
	
		if slot then
			local remaining = GetItemTotalCount(bag, slot) - 1
			if remaining < 5 then
				PT.AMS.DisplayMessage("|cFFFF00You have "..remaining.." Sigil of Imperial Retreat left|r", "qol")
				PlaySound(PT.soundWarning)
			end
			if IsProtectedFunction("UseItem") then
				CallSecureProtected("UseItem", bag, slot) -- https://wiki.esoui.com/API#Protected_Functions
			else
				UseItem(bag, slot)
			end
		else
			PT.AMS.DisplayMessage("|cFFFF00You have NO Sigil of Imperial Retreat left|r", "qol")
			PlaySound(PT.soundWarning)

		end
	end
end


--------------------------------------------------
-- PVP QUEUE FUNCTIONS
--------------------------------------------------


--------------------------------------------------
-- EmergencyQueueOut - queue from Cyrodiil to Imperial City or Imperial City to Cyrodiil with a single keystroke
--------------------------------------------------
--[[		-- Ability to queue out of Imperial City is not limited by ZOS.  This is kept in case they every reverse that decision
function QOL.EmergencyQueueOut()
	if PT.debug then PT.DebugEntry("PVPTools.QOL.EmergencyQueueOut") end
	
	-- START HERE IF RESTORED
	To get the campaign instance names and number
	
	/script for i=1,150 do d(string.format('%d: %s', i, GetCampaignName(i))) end
	
	
	The available campaigns will have to be hard coded because of limitations requiring the Campaign Manager to initialize. Using the below script will only work after the Alliance War window has been opened at least once.  There is currently no way to see which campaigns are active until opening the Alliance War window.
	
	/script 
		for _, campaignData in ipairs(CAMPAIGN_BROWSER_MANAGER.selectionCampaignList) do
			df("%d - %s", campaignData.id, campaignData.name)
		end
	
	REMOVED FROM BINDINGS.XML
	<Action name = "PVPTOOLS_EMERGENCY_EXIT">
		<Down>PVPTools.QOL.EmergencyQueueOut()</Down>
	</Action>
	
	--  END HERE IF RESTORED
	
	local bringTheGroup = false
	local targetCampaign = 0

	if PT.IsPVPZone() then
		if 	PT.IsGrouped() and 
			PT.IsLeader() and 
			PVPTools.ASV.settingsQOLQueueGroup 
		then
			bringTheGroup = true
		end
		
		-- With the changes in update 49, we can not queue from cyrodiil to cyrodiil.  So we will just simplify things and if in cyrodiil, just queue for alternate cyrodiil campaign
		if IsInCyrodiil() then
			
			-- Campaign IC 103 = Ravenwatch and 101 = Blackreach
			if GetCurrentCampaignId() == 103 then targetCampaign = 101 else targetCampaign = 103 end
			
			if QOL.IsCampaignFull(targetCampaign) then
				PVPTools.AMS.DisplayMessage(GetCampaignName(targetCampaign).."is full . . . ", "qol")
				
				if targetCampaign == 103 then targetCampaign = 101 else targetCampaign = 103 end
				
				PVPTools.AMS.DisplayMessage("Trying "..GetCampaignName(targetCampaign).." instead", "qol")
			end
		elseif IsInImperialCity() then
			
			-- Campaign ID 95 = CP IC and 96 = No CP IC
			if GetCurrentCampaignId() == 96 then targetCampaign = 95 else targetCampaign = 96 end
			
			if QOL.IsCampaignFull(targetCampaign) then
				PVPTools.AMS.DisplayMessage(GetCampaignName(targetCampaign).."is full . . . ", "qol")
				
				if targetCampaign == 96 then targetCampaign = 95 else targetCampaign = 96 end
				
				PVPTools.AMS.DisplayMessage("Trying "..GetCampaignName(targetCampaign).." instead", "qol")
			end
		end
		
		if (not IsQueuedForCampaign(targetCampaign, bringTheGroup)) then
			QueueForCampaign(targetCampaign, bringTheGroup)
			PVPTools.AMS.DisplayMessage("Queued for "..GetCampaignName(targetCampaign), "qol")
			PlaySound(PT.soundEmergencyQueue)
		else
			PVPTools.AMS.DisplayMessage("Already in queue for "..GetCampaignName(targetCampaign))
		end
	end
end
--]]

--------------------------------------------------
-- IsCampaignFull - is the population low enough to queue in quickly
--------------------------------------------------
function QOL.IsCampaignFull(campaignId)
	if PT.debug then PT.DebugEntry("PVPTools.QOL.IsCampaignFull") end
	
	for selectionIndex = 1, GetNumSelectionCampaigns() do
		if GetSelectionCampaignId(selectionIndex) == campaignId then
			if GetSelectionCampaignPopulationData(selectionIndex, PT.MyAlliance()) == CAMPAIGN_POP_FULL then
				return true
			end
		end
	end
	return false
end


--------------------------------------------------
-- AutoAcceptQueue - process the change in queue state and automatically accept queue when it is ready
--------------------------------------------------
function QOL.AutoAcceptQueue(campaignId, isGroup, campaignQueueRequestStateType)
	if PT.debug then PT.DebugEntry("PVPTools.QOL.AutoAcceptQueue") end
	
	if campaignQueueRequestStateType == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then
		PT.AMS.DisplayMessage("Accepting Queue "..GetCampaignName(campaignId), "qol")
		ConfirmCampaignEntry(campaignId, isGroup, true)
	elseif campaignQueueRequestStateType == CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_ACCEPT then
		PT.AMS.DisplayMessage("Entering "..GetCampaignName(campaignId), "qol")
	end	
end


--------------------------------------------------
-- QueueSiegeFee - Add the target's name to the queue to send a joke message to a person who has stolen one of your siege engines
--------------------------------------------------
function QOL.QueueSiegeFee(targetUnitName, targetAlliance)
	if PT.debug then PT.DebugEntry("PVPTools.QOL.QueueSiegeFeeMessage") end
	
	if IsInCyrodiil() then
		if targetAlliance == PT.MyAlliance() then 
			local found = false
			for index, value in ipairs(PT.siegeFeeQueue) do
				if value == targetUnitName then found = true
				break end
			end
			
			if not found then
				table.insert(PT.siegeFeeQueue, targetUnitName)
			end
		
			if (PT.siegeFeeQueue and PT.InCombat()) then
				EVENT_MANAGER:RegisterForEvent(PT.name, EVENT_PLAYER_COMBAT_STATE, QOL.SendSiegeFeeMessage)
			else
				QOL.SendSiegeFeeMessage(nil, false)
			end
		end
	end
end


--------------------------------------------------
-- SendSiegeFeeMessage - Called by the Combat State event to determine if we can send mail messages to people in the queue and send the messages if the person in the queue is eleigible.
--------------------------------------------------
function QOL.SendSiegeFeeMessage(eventCode, inCombat)
	if PT.debug then PT.DebugEntry("PVPTools.QOL.SendSiegeFeeMessage") end
	
	if not inCombat then
		RequestOpenMailbox()
		-- need to add in a delay to allow the mail api to fully initialize in case this is the first time the mail is being opened since login otherwise the messages may not send
		zo_callLater(function ()
			for index, value in ipairs(PT.siegeFeeQueue) do
				if not QOL.IsInDailyFeeTable(value) then
					SendMail(value, "|cDB8C3C Siege Rental Fee |r", "I am honored you used my siege during our latest battle in Cyrodiil.  Siege is expensive so I ask you pay a small rental fee of 25 |t24:24:/esoui/art/currency/alliancepoints_32.dds|t.  You can avoid future fees, by placing your own siege.\n\n|u32:0::  |u |t64:64:/esoui/art/icons/ava_siege_weapon_001.dds|t  |u64:64::  |u |t64:64:/esoui/art/icons/ava_siege_weapon_001.dds|t \n\nFailure to pay may bring an adventurer (complaining about an arrow to the knee) to your house who craves sweetrolls.\n\n |u64:64::  |u |t64:64:/esoui/art/icons/crowncrate_sweetroll.dds|t")
					table.insert(PT.ASV.settingsQOLDailySiegeTable, value)
					PT.AMS.DisplayMessage("Siege fee sent to "..value, "qol")
				end
			end
			CloseMailbox()
			PT.siegeFeeQueue = {}
			EVENT_MANAGER:UnregisterForEvent(PT.name, EVENT_PLAYER_COMBAT_STATE)
		end, 500)
	end
end


--------------------------------------------------
-- IsInDailyFeeTable - Check if we have already sent a fee message to this person today.  Returns true if the name is found.
--------------------------------------------------
function QOL.IsInDailyFeeTable(name)
	if PT.debug then PT.DebugEntry("PVPTools.QOL.CheckDailyFeeTable") end
	
	for index, dailyName in ipairs(PT.ASV.settingsQOLDailySiegeTable) do
		if name == dailyName then return true end
	end
	
	return false
end

-- TODO  Invite to group keybind