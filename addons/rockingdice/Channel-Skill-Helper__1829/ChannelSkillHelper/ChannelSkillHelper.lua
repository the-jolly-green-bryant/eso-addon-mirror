------------------
--LOAD LIBRARIES--
------------------

--load LibAddonsMenu-2.0
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0");

----------------------
--INITIATE VARIABLES--
----------------------

--create Addon UI table
ChannelSkillHelperData = {};
--define name of addon
ChannelSkillHelperData.name = "ChannelSkillHelper";
--define addon version number
ChannelSkillHelperData.version = 1.01; 
 
ChannelSkillHelper = {} 

local slotData = {}
local enabled = true

local function onActionSlotUpdated(eventCode, slotNum)
	--d("EVENT_ACTION_SLOT_UPDATED: " .. slotNum)
	if (slotNum < 3 or slotNum > 7) then return end
	
	local abilityId = GetSlotBoundId(slotNum)
	if abilityId then
		slotData[slotNum].abilityId = abilityId
		local channeled, castTime, channelTime = GetAbilityCastInfo(abilityId)
		slotData[slotNum].isChannel = channeled
		slotData[slotNum].castTime = castTime
		slotData[slotNum].channelTime = channelTime
		slotData[slotNum].isInstant = castTime == 0 and channelTime == 0
		if slotData[slotNum].lastUsedEndTime == nil then
			slotData[slotNum].lastUsedEndTime = 0 
		end
		--d(slotData[slotNum])
	end
end

local function onActionSlotsFullUpdate(eventCode, isHotbarSwap)
	--d("EVENT_ACTION_SLOTS_FULL_UPDATE")
	for i = 3, 7 do
		slotData[i] = {}
		onActionSlotUpdated(nil, i)
	end
end

local function triggerAddonLoaded(eventCode, addonName)
	if  (addonName == ChannelSkillHelperData.name) then
		EVENT_MANAGER:UnregisterForEvent(ChannelSkillHelperData.name, EVENT_ADD_ON_LOADED);
		onActionSlotsFullUpdate()
		
		for i = 3, 7 do 
			local button = ZO_ActionBar_GetButton(i)
			local function channelSkillCheck(self) 
				if not enabled then
					return false
				end
				local currentTime = GetGameTimeMilliseconds()
				local slotNum = self:GetSlot()  
				if currentTime > slotData[slotNum].lastUsedEndTime  then 
					--d("false", currentTime, slotData[slotNum].lastUsedEndTime)
					return false
				else
					--d("true", currentTime, slotData[slotNum].lastUsedEndTime)
					return true
				end 
			end
			ZO_PreHook(button, "HandlePressAndRelease", channelSkillCheck)
			ZO_PreHook(button, "HandleRelease", channelSkillCheck)  
		end

	end
end
 
local function onActionSlotAbilityUsed(eventCode, slotNum)
	--d("EVENT_ACTION_SLOT_ABILITY_USED: " .. slotNum)
	if (slotNum < 3 or slotNum > 7) then return end
	local data = slotData[slotNum]
	if not data.isInstant then 
		local delayTime
		if data.isChannel then
			delayTime = data.channelTime
		else
			delayTime = data.castTime
		end
		data.lastUsedEndTime = GetGameTimeMilliseconds() + delayTime + GetLatency() + 100
		--d("lastUsedEndTime: ".. data.lastUsedEndTime)
	end 
end 


local function commandExec(text)
	if text == "on" then
		--enable this add-on
		enabled = true
		d("[Channel Skill Helper] Enabled")
	elseif text == "off" then
		enabled = false
		d("[Channel Skill Helper] Disabled")
	else
		d("[Channel Skill Helper] \nUsage: \n Enable: /csh on\n Disable: /csh off")
	end
end
 
SLASH_COMMANDS["/csh"] = commandExec

EVENT_MANAGER:RegisterForEvent(ChannelSkillHelperData.name, EVENT_ADD_ON_LOADED, triggerAddonLoaded)
EVENT_MANAGER:RegisterForEvent(ChannelSkillHelperData.name, EVENT_ACTION_SLOT_ABILITY_USED, onActionSlotAbilityUsed)
EVENT_MANAGER:RegisterForEvent(ChannelSkillHelperData.name, EVENT_ACTION_SLOTS_FULL_UPDATE, onActionSlotsFullUpdate)
EVENT_MANAGER:RegisterForEvent(ChannelSkillHelperData.name, EVENT_ACTION_SLOT_UPDATED, onActionSlotUpdated)