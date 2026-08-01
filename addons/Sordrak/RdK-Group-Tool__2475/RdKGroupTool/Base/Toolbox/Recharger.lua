-- RdK Group Tool Recharger
-- By @s0rdrak (PC / EU)

RdKGTool.toolbox.recharger = RdKGTool.toolbox.recharger or {}
local RdKGToolRecharger = RdKGTool.toolbox.recharger
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.inventory = RdKGToolUtil.inventory or {}
local RdKGToolInventory = RdKGToolUtil.inventory
RdKGToolUtil.chatSystem = RdKGToolUtil.chatSystem or {}
local RdKGToolChat = RdKGToolUtil.chatSystem

RdKGToolRecharger.constants = RdKGToolRecharger.constants or {}
RdKGToolRecharger.constants.PREFIX = "Recharger"

RdKGToolRecharger.callbackName = RdKGTool.addonName .. "Recharger"

RdKGToolRecharger.config = {}
RdKGToolRecharger.config.slots = {}
RdKGToolRecharger.config.slots[1] = EQUIP_SLOT_MAIN_HAND
RdKGToolRecharger.config.slots[2] = EQUIP_SLOT_OFF_HAND
RdKGToolRecharger.config.slots[3] = EQUIP_SLOT_BACKUP_MAIN
RdKGToolRecharger.config.slots[4] = EQUIP_SLOT_BACKUP_OFF

RdKGToolRecharger.state = {}
RdKGToolRecharger.state.initialized = false
RdKGToolRecharger.state.alreadyEnabled = false
RdKGToolRecharger.state.noSoulGemsMessageShown = false

function RdKGToolRecharger.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolRecharger.callbackName, RdKGToolRecharger.OnProfileChanged)
	
	RdKGToolRecharger.state.initialized = true
	RdKGToolRecharger.SetEnabled(RdKGToolRecharger.rcVars.enabled)
	if RdKGToolRecharger.rcVars.alerts.login == true then
		EVENT_MANAGER:RegisterForEvent(RdKGToolRecharger.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolRecharger.OnPlayerActivated)
	end
end

function RdKGToolRecharger.GetDefaults()
	local defaults = {}
	defaults.enabled = true
	defaults.sendChatMessages = true
	defaults.percent = 5
	defaults.alerts = {}
	defaults.alerts.login = true
	defaults.alerts.empty = true
	defaults.alerts.threshold = true
	defaults.threshold = 100
	defaults.checkInterval = 10
	return defaults
end

function RdKGToolRecharger.SetEnabled(value)
	if RdKGToolRecharger.state.initialized == true and value ~= nil then
		RdKGToolRecharger.rcVars.enabled = value
		if value == true then
			if RdKGToolRecharger.state.alreadyEnabled == true then
				EVENT_MANAGER:UnregisterForUpdate(RdKGToolRecharger.callbackName)
			end
			EVENT_MANAGER:RegisterForUpdate(RdKGToolRecharger.callbackName, RdKGToolRecharger.rcVars.checkInterval * 1000, RdKGToolRecharger.OnUpdate)
			RdKGToolRecharger.state.alreadyEnabled = true
		else
			if RdKGToolRecharger.state.alreadyEnabled == true then
				EVENT_MANAGER:UnregisterForUpdate(RdKGToolRecharger.callbackName)
			end
			RdKGToolRecharger.state.alreadyEnabled = false
		end
	end
end

--internal functions
function RdKGToolRecharger.GetNextSouldGemIndex(soulGems)
	local retVal = nil
	if soulGems ~= nil and #soulGems > 0 then
		retVal = soulGems[1].slot
		local currentStack = soulGems[1].stack
		for i = 1, #soulGems - 1 do
			if soulGems[i].stack < soulGems[i + 1].stack and soulGems[i].stack < currentStack then
				retVal = soulGems.slot
				currentStack = soulGems[i].stack
			end
		end
	end
	return retVal
end

function RdKGToolRecharger.RemoveSoulGem(soulGems, bagIndex)
	if soulGems ~= nil and bagIndex ~= nil then
		for i = 1, #soulGems do
			if soulGems[i].slot == bagIndex then
				soulGems[i].stack = soulGems[i].stack - 1
				if soulGems[i].stack <= 0 then
					table.remove(soulGems,i)
				end
				break
			end
		end
	end
end

function RdKGToolRecharger.GetSoulGemsStackCount(soulGems)
	local retVal = 0
	if soulGems ~= nil then
		for i = 1, #soulGems do
			retVal = retVal + soulGems[i].stack
		end
	end
	return retVal
end

--callbacks
function RdKGToolRecharger.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolRecharger.rcVars = currentProfile.toolbox.recharger
		RdKGToolRecharger.SetEnabled(RdKGToolRecharger.rcVars.enabled)
	end
end

function RdKGToolRecharger.OnPlayerActivated(event)
	if event == EVENT_PLAYER_ACTIVATED then
		EVENT_MANAGER:UnregisterForEvent(RdKGToolRecharger.callbackName, EVENT_PLAYER_ACTIVATED)
		local soulGems = RdKGToolInventory.GetSoulGemsInventoryInformation()
		local soulGemsLeft = RdKGToolRecharger.GetSoulGemsStackCount(soulGems)
		if soulGemsLeft < RdKGToolRecharger.rcVars.threshold then
			RdKGToolChat.SendChatMessage(string.format(RdKGToolRecharger.constants.MESSAGE_WARNING_LOW_SOULGEMS, RdKGToolRecharger.rcVars.threshold), RdKGToolRecharger.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING, RdKGToolRecharger.rcVars.sendChatMessages)
		end
	end
end

function RdKGToolRecharger.OnUpdate()
	--d("interval: " .. RdKGToolRecharger.rcVars.checkInterval)
	if IsUnitDead("player") == false then
		local soulGems = RdKGToolInventory.GetSoulGemsInventoryInformation()
		local showNoSoulGemsMessage = false
		local weaponHasBeenCharged = false
		for i = 1, #RdKGToolRecharger.config.slots do
			local charges, maxCharges = GetChargeInfoForItem(BAG_WORN,RdKGToolRecharger.config.slots[i])
			local percent = charges / maxCharges * 100
			if percent <= RdKGToolRecharger.rcVars.percent then
				local bagIndex = RdKGToolRecharger.GetNextSouldGemIndex(soulGems)
				if bagIndex ~= nil and bagIndex >= 0 then
					ChargeItemWithSoulGem(BAG_WORN,RdKGToolRecharger.config.slots[i],BAG_BACKPACK, bagIndex)
					RdKGToolRecharger.RemoveSoulGem(soulGems, bagIndex)
					RdKGToolRecharger.state.noSoulGemsMessageShown = false
					weaponHasBeenCharged = true
					RdKGToolChat.SendChatMessage(string.format(RdKGToolRecharger.constants.MESSAGE_SUCCESS, GetItemLink(BAG_WORN,RdKGToolRecharger.config.slots[i]), percent), RdKGToolRecharger.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_NORMAL, RdKGToolRecharger.rcVars.sendChatMessages)
				else
					showNoSoulGemsMessage = true
					return
				end
			end
		end
		if weaponHasBeenCharged == true and RdKGToolRecharger.rcVars.alerts.threshold == true then
			local soulGemsLeft = RdKGToolRecharger.GetSoulGemsStackCount(soulGems)
			if soulGemsLeft < RdKGToolRecharger.rcVars.threshold then
				RdKGToolChat.SendChatMessage(string.format(RdKGToolRecharger.constants.MESSAGE_WARNING_LOW_SOULGEMS, RdKGToolRecharger.rcVars.threshold), RdKGToolRecharger.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING, RdKGToolRecharger.rcVars.sendChatMessages)
			end
		end
		if RdKGToolRecharger.state.noSoulGemsMessageShown == false and showNoSoulGemsMessage == true and RdKGToolRecharger.rcVars.alerts.empty == true then
			RdKGToolRecharger.state.noSoulGemsMessageShown = true
			RdKGToolChat.SendChatMessage(RdKGToolRecharger.constants.MESSAGE_WARNING_NO_SOULGEMS, RdKGToolRecharger.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING, RdKGToolRecharger.rcVars.sendChatMessages)
		end
	end
end

--menu interactions
function RdKGToolRecharger.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.RECHARGER_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RECHARGER_ENABLED,
					getFunc = RdKGToolRecharger.GetRechargerEnabled,
					setFunc = RdKGToolRecharger.SetRechargerEnabled
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RECHARGER_SEND_CHAT_MESSAGES,
					getFunc = RdKGToolRecharger.GetRechargerSendChatMessages,
					setFunc = RdKGToolRecharger.SetRechargerSendChatMessages
				},
				[3] = {
					type = "slider",
					name = RdKGToolMenu.constants.RECHARGER_PERCENT,
					min = 0,
					max = 99,
					step = 1,
					getFunc = RdKGToolRecharger.GetRechargerPercent,
					setFunc = RdKGToolRecharger.SetRechargerPercent,
					width = "full",
					default = 5
				},
				[4] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RECHARGER_SOULGEMS_EMPTY_WARNING,
					getFunc = RdKGToolRecharger.GetRechargerEmptyWarningEnabled,
					setFunc = RdKGToolRecharger.SetRechargerEmptyWarningEnabled
				},
				[5] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RECHARGER_SOULGEMS_THRESHOLD_WARNING,
					getFunc = RdKGToolRecharger.GetRechargerThresholdWarningEnabled,
					setFunc = RdKGToolRecharger.SetRechargerThresholdWarningEnabled
				},
				[6] = {
					type = "slider",
					name = RdKGToolMenu.constants.RECHARGER_SOULGEMS_THRESHOLD_SLIDER,
					min = 0,
					max = 1000,
					step = 1,
					getFunc = RdKGToolRecharger.GetRechargerThreshold,
					setFunc = RdKGToolRecharger.SetRechargerThreshold,
					width = "full",
					default = 50
				},
				[7] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RECHARGER_SOULGEMS_EMPTY_LOGIN_WARNING,
					getFunc = RdKGToolRecharger.GetRechargerLoginWarningEnabled,
					setFunc = RdKGToolRecharger.SetRechargerLoginWarningEnabled
				},
				[8] = {
					type = "slider",
					name = RdKGToolMenu.constants.RECHARGER_INTERVAL,
					min = 1,
					max = 300,
					step = 1,
					getFunc = RdKGToolRecharger.GetRechargerCheckInterval,
					setFunc = RdKGToolRecharger.SetRechargerCheckInterval,
					width = "full",
					default = 10
				},
			}
		},
	}
	return menu
end

function RdKGToolRecharger.GetRechargerEnabled()
	return RdKGToolRecharger.rcVars.enabled
end

function RdKGToolRecharger.SetRechargerEnabled(value)
	RdKGToolRecharger.SetEnabled(value)
end

function RdKGToolRecharger.GetRechargerSendChatMessages()
	return RdKGToolRecharger.rcVars.sendChatMessages
end

function RdKGToolRecharger.SetRechargerSendChatMessages(value)
	RdKGToolRecharger.rcVars.sendChatMessages = value
end

function RdKGToolRecharger.GetRechargerPercent()
	return RdKGToolRecharger.rcVars.percent
end

function RdKGToolRecharger.SetRechargerPercent(value)
	RdKGToolRecharger.rcVars.percent = value
end

function RdKGToolRecharger.GetRechargerEmptyWarningEnabled()
	return RdKGToolRecharger.rcVars.alerts.empty
end

function RdKGToolRecharger.SetRechargerEmptyWarningEnabled(value)
	RdKGToolRecharger.rcVars.alerts.empty = value
end

function RdKGToolRecharger.GetRechargerThresholdWarningEnabled()
	return RdKGToolRecharger.rcVars.alerts.threshold
end

function RdKGToolRecharger.SetRechargerThresholdWarningEnabled(value)
	RdKGToolRecharger.rcVars.alerts.threshold = value
end

function RdKGToolRecharger.GetRechargerThreshold()
	return RdKGToolRecharger.rcVars.threshold
end

function RdKGToolRecharger.SetRechargerThreshold(value)
	RdKGToolRecharger.rcVars.threshold = value
end

function RdKGToolRecharger.GetRechargerLoginWarningEnabled()
	return RdKGToolRecharger.rcVars.alerts.login
end

function RdKGToolRecharger.SetRechargerLoginWarningEnabled(value)
	RdKGToolRecharger.rcVars.alerts.login = value
end

function RdKGToolRecharger.GetRechargerCheckInterval()
	return RdKGToolRecharger.rcVars.checkInterval
end

function RdKGToolRecharger.SetRechargerCheckInterval(value)
	RdKGToolRecharger.rcVars.checkInterval = value
	RdKGToolRecharger.SetEnabled(RdKGToolRecharger.rcVars.enabled)
end