-- RdK Group Tool Util Networking
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.networking = RdKGToolUtil.networking or {}
local RdKGToolNetworking = RdKGToolUtil.networking
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGToolUtil.math = RdKGToolUtil.math or {}
local RdKGToolMath = RdKGToolUtil.math
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolGroup = RdKGToolUtil.group

--local LGPS = LibGPS2
--local LMP = LibMapPing
--local lib3d = LibStub("Lib3D2")
--local lib3d = Lib3D

local LGB = LibGroupBroadcast

RdKGToolNetworking.callbackName = RdKGTool.addonName .. "UtilNetworking"

RdKGToolNetworking.config = {}
RdKGToolNetworking.config.updateInterval = 1000
RdKGToolNetworking.config.mapIndex = 23
RdKGToolNetworking.config.mapStepSize = 1.4285034012573e-005
RdKGToolNetworking.config.urgentMessageInterval = 3000

RdKGToolNetworking.messageTypes = {}

RdKGToolNetworking.messageTypes.MESSAGE_ID_HP = 60
RdKGToolNetworking.messageTypes.MESSAGE_ID_DMG = 50
RdKGToolNetworking.messageTypes.MESSAGE_ID_BOOM = 190
RdKGToolNetworking.messageTypes.MESSAGE_ID_SYNERGY = 110
RdKGToolNetworking.messageTypes.MESSAGE_ID_ROLE = 109
RdKGToolNetworking.messageTypes.MESSAGE_ID_VERSION_INFORMATION = 189
RdKGToolNetworking.messageTypes.MESSAGE_ID_VERSION_REQUEST = 188
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_REQUEST = 170
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_1 = 169
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_2 = 168
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_3 = 167
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_4 = 166
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_5 = 165
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_6 = 164
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_7 = 163
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_8 = 162
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_9 = 161
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_CLIENT_CONFIGURATION_AOE = 150
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_CLIENT_CONFIGURATION_SOUND = 149
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_CLIENT_CONFIGURATION_GRAPHICS = 148
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_REQUEST_EQUIPMENT_INFORMATION = 140
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_1 = 139
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_2 = 138
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_3 = 137
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_4 = 136
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_5 = 135
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_CHAMPION_INFORMATION = 134
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_STATS_INFORMATION = 133
RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_SKILLS_INFORMATION = 132

RdKGToolNetworking.messageIdentifiers = {}
RdKGToolNetworking.messageIdentifiers.adminResponse = {}
RdKGToolNetworking.messageIdentifiers.adminResponse.graphics = {}
RdKGToolNetworking.messageIdentifiers.adminResponse.graphics.MESSAGE_1 = 0
RdKGToolNetworking.messageIdentifiers.adminResponse.graphics.MESSAGE_2 = 1
RdKGToolNetworking.messageIdentifiers.adminResponse.graphics.MESSAGE_3 = 2
RdKGToolNetworking.messageIdentifiers.adminResponse.graphics.MESSAGE_4 = 3
RdKGToolNetworking.messageIdentifiers.adminResponse.graphics.MESSAGE_5 = 4
RdKGToolNetworking.messageIdentifiers.adminResponse.graphics.MESSAGE_6 = 5
RdKGToolNetworking.messageIdentifiers.adminResponse.graphics.MESSAGE_7 = 6
RdKGToolNetworking.messageIdentifiers.adminResponse.graphics.MESSAGE_8 = 7
RdKGToolNetworking.messageIdentifiers.adminResponse.stats = {}
RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_MAGICKA = 0
RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_HEALTH = 1
RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_STAMINA = 2
RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_MAGICKA_RECOVERY = 3
RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_HEALTH_RECOVERY = 4
RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_STAMINA_RECOVERY = 5
RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_SPELL_DAMAGE = 6
RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_WEAPON_DAMAGE = 7
RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_SPELL_PENETRATION = 8
RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_WEAPON_PENETRATION = 9
RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_CRITICAL = 10
RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_SPELL_RESISTANCE = 11
RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_PHYSICAL_RESISTANCE = 12
RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_CRITICAL_RESISTANCE = 13
RdKGToolNetworking.messageIdentifiers.adminResponse.admin = {}
RdKGToolNetworking.messageIdentifiers.adminResponse.admin.MESSAGE_1 = 0
RdKGToolNetworking.messageIdentifiers.adminResponse.admin.MESSAGE_2 = 1
RdKGToolNetworking.messageIdentifiers.adminResponse.admin.MESSAGE_3 = 2
RdKGToolNetworking.messageIdentifiers.adminResponse.admin.MESSAGE_4 = 3
RdKGToolNetworking.messageIdentifiers.adminResponse.admin.MESSAGE_5 = 4
RdKGToolNetworking.messageIdentifiers.adminResponse.admin.MESSAGE_6 = 5
RdKGToolNetworking.messageIdentifiers.adminResponse.admin.MESSAGE_7 = 6
RdKGToolNetworking.messageIdentifiers.adminResponse.admin.MESSAGE_8 = 7

RdKGToolNetworking.protocolTypes = {}
RdKGToolNetworking.protocolTypes.LEGACY = 102
RdKGToolNetworking.protocolTypes.ADMIN = 103
RdKGToolNetworking.protocolTypes.VERSION = 104
RdKGToolNetworking.protocolTypes.HEARTBEAT = 105
RdKGToolNetworking.protocolTypes.SYNERGY = 106
RdKGToolNetworking.protocolTypes.HPDMG = 107

RdKGToolNetworking.messageIdentifiers.roleMessage = {}
RdKGToolNetworking.messageIdentifiers.roleMessage.MESSAGE_ADMIN_SET_ROLE = 255

RdKGToolNetworking.state = {}
RdKGToolNetworking.state.initialized = false
RdKGToolNetworking.state.isRunning = false
RdKGToolNetworking.state.queues = {}
RdKGToolNetworking.state.queues.critical = {}
RdKGToolNetworking.state.queues.high = {}
RdKGToolNetworking.state.queues.medium = {}
RdKGToolNetworking.state.queues.low = {}
RdKGToolNetworking.state.lastUrgentMessage = 0
RdKGToolNetworking.state.rawMessageHandlers = {}

RdKGToolNetworking.constants = RdKGToolNetworking.constants or {}
RdKGToolNetworking.constants.priorities = RdKGToolNetworking.constants.priorities or {}
RdKGToolNetworking.constants.priorities.CRITICAL = 1
RdKGToolNetworking.constants.priorities.HIGH = 2
RdKGToolNetworking.constants.priorities.MEDIUM = 3
RdKGToolNetworking.constants.priorities.LOW = 4
RdKGToolNetworking.constants.urgentSelection = RdKGToolNetworking.constants.urgentSelection or {}
RdKGToolNetworking.constants.urgentMode = {}
RdKGToolNetworking.constants.urgentMode.DIRECT = 1
RdKGToolNetworking.constants.urgentMode.CRITICAL = 2

function RdKGToolNetworking.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolNetworking.callbackName, RdKGToolNetworking.OnProfileChanged)
	RdKGToolNetworking.LGB = LGB:RegisterHandler("RdKGroupTool", "RdKGroupToolHandler")
	RdKGToolNetworking.LGB:SetDisplayName("RdK Group Tool")
	RdKGToolNetworking.LGB:SetDescription("RdK Group Tool - PvP AddOn -> https://www.esoui.com/downloads/info2475-RdKGroupTool.html \r\nPlease use the AddOn configuration (/rdk menu) to further configure the AddOn.")
	RdKGToolNetworking.protocols = {}
	RdKGToolNetworking.protocols.legacy = RdKGToolNetworking.LGB:DeclareProtocol(RdKGToolNetworking.protocolTypes.LEGACY, "RdKGroupToolLegacyProtocol")
	RdKGToolNetworking.protocols.legacy:AddField(LGB.CreateNumericField("numeric"))
	RdKGToolNetworking.protocols.legacy:OnData(RdKGToolNetworking.LgbLegacyOnData)
	RdKGToolNetworking.protocols.legacy:Finalize({isRelevantInCombat = true, replaceQueuedMessages = false})
	
	RdKGToolNetworking.protocols.admin = RdKGToolNetworking.LGB:DeclareProtocol(RdKGToolNetworking.protocolTypes.ADMIN, "RdKGroupToolAdminProtocol")
	RdKGToolNetworking.protocols.admin:AddField(LGB.CreateNumericField("numeric"))
	RdKGToolNetworking.protocols.admin:OnData(RdKGToolNetworking.LgbAdminOnData)
	RdKGToolNetworking.protocols.admin:Finalize({isRelevantInCombat = false, replaceQueuedMessages = false})
	
	RdKGToolNetworking.protocols.version = RdKGToolNetworking.LGB:DeclareProtocol(RdKGToolNetworking.protocolTypes.VERSION, "RdKGroupToolVersionProtocol")
	RdKGToolNetworking.protocols.version:AddField(LGB.CreateNumericField("numeric"))
	RdKGToolNetworking.protocols.version:OnData(RdKGToolNetworking.LgbVersionOnData)
	RdKGToolNetworking.protocols.version:Finalize({isRelevantInCombat = false, replaceQueuedMessages = false})
	
	RdKGToolNetworking.protocols.heartbeat = RdKGToolNetworking.LGB:DeclareProtocol(RdKGToolNetworking.protocolTypes.HEARTBEAT, "RdKGroupToolHeartbeatProtocol")
	RdKGToolNetworking.protocols.heartbeat:AddField(LGB.CreateNumericField("numeric"))
	RdKGToolNetworking.protocols.heartbeat:OnData(RdKGToolNetworking.LgbHeartbeatOnData)
	RdKGToolNetworking.protocols.heartbeat:Finalize({isRelevantInCombat = true, replaceQueuedMessages = true})
	
	RdKGToolNetworking.protocols.synergy = RdKGToolNetworking.LGB:DeclareProtocol(RdKGToolNetworking.protocolTypes.SYNERGY, "RdKGroupToolSynergyProtocol")
	RdKGToolNetworking.protocols.synergy:AddField(LGB.CreateNumericField("numeric"))
	RdKGToolNetworking.protocols.synergy:OnData(RdKGToolNetworking.LgbSynergyOnData)
	RdKGToolNetworking.protocols.synergy:Finalize({isRelevantInCombat = true, replaceQueuedMessages = false})
	
	RdKGToolNetworking.protocols.hpDmg = RdKGToolNetworking.LGB:DeclareProtocol(RdKGToolNetworking.protocolTypes.HPDMG, "RdKGroupToolHpDmgProtocol")
	RdKGToolNetworking.protocols.hpDmg:AddField(LGB.CreateNumericField("numeric"))
	RdKGToolNetworking.protocols.hpDmg:OnData(RdKGToolNetworking.LgbHpDmgOnData)
	RdKGToolNetworking.protocols.hpDmg:Finalize({isRelevantInCombat = true, replaceQueuedMessages = false})
	
	
	--RdKGToolNetworking.protocols.legacy:Send()
	
	RdKGToolNetworking.state.initialized = true
	RdKGToolNetworking.SetEnabled(RdKGToolNetworking.netVars.enabled)
end

function RdKGToolNetworking.GetDefaults()
	local defaults = {}
	defaults.enabled = true
	--defaults.mode = RdKGToolNetworking.constants.urgentMode.CRITICAL
	--defaults.updateInterval = RdKGToolNetworking.config.updateInterval
	return defaults
end

function RdKGToolNetworking.SetEnabled(value)
	if RdKGToolNetworking.state.initialized == true and value ~= nil then
		RdKGToolNetworking.netVars.enabled = value
		if value == true then
			if RdKGToolNetworking.state.isRunning == true then
				RdKGToolNetworking.Disable()
				RdKGToolNetworking.Enable()
			else
				RdKGToolNetworking.Enable()
			end
		else
			if RdKGToolNetworking.state.isRunning == true then
				RdKGToolNetworking.Disable()
			else
				--Nothing to do
			end
		end
	end
end

--[[
function RdKGToolNetworking.SendUrgentMessage(message)
	--d("sending urgent message")
	if RdKGToolNetworking.netVars.mode == RdKGToolNetworking.constants.urgentMode.CRITICAL then
		return nil
	end
	local messageSent = false
	if RdKGToolNetworking.netVars.enabled == true then
	--[-[
		if message ~= nil and message.b0 ~= nil and message.b1 ~= nil and message.b2 ~= nil and message.b3 ~= nil then
			if RdKGToolNetworking.state.lastUrgentMessage + RdKGToolNetworking.config.urgentMessageInterval < GetGameTimeMilliseconds() then
				LGPS:PushCurrentMap()
				SetMapToMapListIndex(RdKGToolNetworking.config.mapIndex)

				LMP:SetMapPing(MAP_PIN_TYPE_PING, MAP_TYPE_LOCATION_CENTERED, RdKGToolNetworking.EncodeMessage(message.b0, message.b1, message.b2, message.b3))
				LGPS:PopCurrentMap()
				message.sent = true
					
				if GetGroupSize() == 0 then
					message.isPingOwner = true
					message.pingType = MAP_PIN_TYPE_PING
					message.pingTag = "player"
					RdKGToolNetworking.HandleRawMessage(message)
				end
				RdKGToolNetworking.state.lastUrgentMessage = GetGameTimeMilliseconds()
				messageSent = true
			else
				messageSent = false
			end
		else
			messageSent = true
		end
	else
		messageSent = true
		--]-]
	end
	return messageSent
end
]]

function RdKGToolNetworking.LgbLegacyOnData(unitTag, data)
	--d("LEGACY: Received data from " .. GetUnitName(unitTag))
    --d("LEGACY: myNumber: " .. data.numeric)
	local message = {}
	message.b0, message.b1, message.b2, message.b3 = RdKGToolNetworking.Encode4ByteInt24(data.numeric)
	message.pingType = 0 -- old implementation - ping type
	message.pingTag = unitTag
	message.x = 0 -- old implementation via map pins - x coordinate
	message.y = 0 -- old implementation via map pins - y coordinate
	message.isPingOwner = false -- old implementation - ping owner
	
	RdKGToolNetworking.HandleRawMessage(message)
end

function RdKGToolNetworking.SendMessage(message, priority)
	if RdKGToolNetworking.netVars.enabled == true then
		local numericVal = RdKGToolNetworking.Decode4ByteInt24(message.b0, message.b1, message.b2, message.b3)
		message.sent = true
		RdKGToolNetworking.protocols.legacy:Send({numeric=numericVal})
		if GetGroupSize() == 0 then
			message.pingTag = "player"
			RdKGToolNetworking.HandleRawMessage(message)
		end
		--d("message sent")
	end
--[[
	if RdKGToolNetworking.netVars.enabled == true then
		local queues = RdKGToolNetworking.state.queues
		local queue = queues.low
		local priorities = RdKGToolNetworking.constants.priorities
		if priority == priorities.CRITICAL then
			queue = queues.critical
		elseif priority == priorities.HIGH then
			queue = queues.high
		elseif priority == priorities.MEDIUM then
			queue = queues.medium
		end
		message.priority = priority
		table.insert(queue, message)
	else
		if GetGroupSize() == 0 then
			message.pingTag = "player"
		else
			message.pingTag = RdKGToolGroup.GetUnitTagForPlayer()
		end
		RdKGToolNetworking.HandleRawMessage(message)
	end
	]]
end

function RdKGToolNetworking.LgbAdminOnData(unitTag, data)
	--d("Admin: Received data from " .. GetUnitName(unitTag))
    --d("Admin: myNumber: " .. data.numeric)
	local message = {}
	message.b0, message.b1, message.b2, message.b3 = RdKGToolNetworking.Encode4ByteInt24(data.numeric)
	message.pingType = 0 -- old implementation - ping type
	message.pingTag = unitTag
	message.x = 0 -- old implementation via map pins - x coordinate
	message.y = 0 -- old implementation via map pins - y coordinate
	message.isPingOwner = false -- old implementation - ping owner
	
	RdKGToolNetworking.HandleRawMessage(message)
end

function RdKGToolNetworking.SendAdminMessage(message, priority)
	if RdKGToolNetworking.netVars.enabled == true then
		local numericVal = RdKGToolNetworking.Decode4ByteInt24(message.b0, message.b1, message.b2, message.b3)
		message.sent = true
		RdKGToolNetworking.protocols.admin:Send({numeric=numericVal})
		--d("message sent")
		if GetGroupSize() == 0 then
			message.pingTag = "player"
			RdKGToolNetworking.HandleRawMessage(message)
		end
	end
end

function RdKGToolNetworking.LgbVersionOnData(unitTag, data)
	--d("Version: Received data from " .. GetUnitName(unitTag))
    --d("Version: myNumber: " .. data.numeric)
	local message = {}
	message.b0, message.b1, message.b2, message.b3 = RdKGToolNetworking.Encode4ByteInt24(data.numeric)
	message.pingType = 0 -- old implementation - ping type
	message.pingTag = unitTag
	message.x = 0 -- old implementation via map pins - x coordinate
	message.y = 0 -- old implementation via map pins - y coordinate
	message.isPingOwner = false -- old implementation - ping owner
	
	RdKGToolNetworking.HandleRawMessage(message)
end

function RdKGToolNetworking.SendVersionMessage(message, priority)
	if RdKGToolNetworking.netVars.enabled == true then
		local numericVal = RdKGToolNetworking.Decode4ByteInt24(message.b0, message.b1, message.b2, message.b3)
		message.sent = true
		RdKGToolNetworking.protocols.version:Send({numeric=numericVal})
		--d("message sent")
		if GetGroupSize() == 0 then
			message.pingTag = "player"
			RdKGToolNetworking.HandleRawMessage(message)
		end
	end
end

function RdKGToolNetworking.LgbHeartbeatOnData(unitTag, data)
	--d("Heartbeat: Received data from " .. GetUnitName(unitTag))
    --d("Heartbeat: myNumber: " .. data.numeric)
	local message = {}
	message.b0, message.b1, message.b2, message.b3 = RdKGToolNetworking.Encode4ByteInt24(data.numeric)
	message.pingType = 0 -- old implementation - ping type
	message.pingTag = unitTag
	message.x = 0 -- old implementation via map pins - x coordinate
	message.y = 0 -- old implementation via map pins - y coordinate
	message.isPingOwner = false -- old implementation - ping owner
	
	RdKGToolNetworking.HandleRawMessage(message)
end

function RdKGToolNetworking.SendHeartbeatMessage(message, priority)
	if RdKGToolNetworking.netVars.enabled == true then
		local numericVal = RdKGToolNetworking.Decode4ByteInt24(message.b0, message.b1, message.b2, message.b3)
		message.sent = true
		RdKGToolNetworking.protocols.heartbeat:Send({numeric=numericVal})
		--d("message sent")
		if GetGroupSize() == 0 then
			message.pingTag = "player"
			RdKGToolNetworking.HandleRawMessage(message)
		end
	end
end

function RdKGToolNetworking.LgbSynergyOnData(unitTag, data)
	--d("Synergy: Received data from " .. GetUnitName(unitTag))
    --d("Synergy: myNumber: " .. data.numeric)
	local message = {}
	message.b0, message.b1, message.b2, message.b3 = RdKGToolNetworking.Encode4ByteInt24(data.numeric)
	message.pingType = 0 -- old implementation - ping type
	message.pingTag = unitTag
	message.x = 0 -- old implementation via map pins - x coordinate
	message.y = 0 -- old implementation via map pins - y coordinate
	message.isPingOwner = false -- old implementation - ping owner
	
	RdKGToolNetworking.HandleRawMessage(message)
end

function RdKGToolNetworking.SendSynergyMessage(message, priority)
	if RdKGToolNetworking.netVars.enabled == true then
		local numericVal = RdKGToolNetworking.Decode4ByteInt24(message.b0, message.b1, message.b2, message.b3)
		message.sent = true
		RdKGToolNetworking.protocols.synergy:Send({numeric=numericVal})
		--d("message sent")
		if GetGroupSize() == 0 then
			message.pingTag = "player"
			RdKGToolNetworking.HandleRawMessage(message)
		end
	end
end

function RdKGToolNetworking.LgbHpDmgOnData(unitTag, data)
	--d("HpDmg: Received data from " .. GetUnitName(unitTag))
    --d("HpDmg: myNumber: " .. data.numeric)
	local message = {}
	message.b0, message.b1, message.b2, message.b3 = RdKGToolNetworking.Encode4ByteInt24(data.numeric)
	message.pingType = 0 -- old implementation - ping type
	message.pingTag = unitTag
	message.x = 0 -- old implementation via map pins - x coordinate
	message.y = 0 -- old implementation via map pins - y coordinate
	message.isPingOwner = false -- old implementation - ping owner
	
	RdKGToolNetworking.HandleRawMessage(message)
end

function RdKGToolNetworking.SendHpDmgMessage(message, priority)
	if RdKGToolNetworking.netVars.enabled == true then
		local numericVal = RdKGToolNetworking.Decode4ByteInt24(message.b0, message.b1, message.b2, message.b3)
		message.sent = true
		RdKGToolNetworking.protocols.hpDmg:Send({numeric=numericVal})
		--d("message sent")
		if GetGroupSize() == 0 then
			message.pingTag = "player"
			RdKGToolNetworking.HandleRawMessage(message)
		end
	end
end

function RdKGToolNetworking.IsRawMessageHandlerRegistred(name)
	local isRegistred = false
	for i = 1, #RdKGToolNetworking.state.rawMessageHandlers do
		if RdKGToolNetworking.state.rawMessageHandlers[i].name == name then
			isRegistred = true
			break
		end
	end
	return isRegistred
end

function RdKGToolNetworking.AddRawMessageHandler(name, messageCallback)
	if name ~= nil and messageCallback ~= nil then
		if RdKGToolNetworking.IsRawMessageHandlerRegistred(name) == false then
			local newHandler = {}
			newHandler.name = name
			newHandler.handleRawMessage = messageCallback
			table.insert(RdKGToolNetworking.state.rawMessageHandlers, newHandler)
		end
	end
end

function RdKGToolNetworking.RemoveRawMessageHandler(name)
	if name ~= nil then
		local handlers = RdKGToolNetworking.state.rawMessageHandlers
		for i = 1, #handlers do
			if handlers[i].name == name then
				table.remove(handlers, i)
				--i = i - 1
				break
			end
		end
	end
end

--Careful not to mess up arrays and b1, b2, b3
function RdKGToolNetworking.EncodeBitArrayToMessage(array)
	local b1, b2, b3 = 0,0,0
	b1 = RdKGToolMath.EncodeBitArrayHelper(array, 0)
	b2 = RdKGToolMath.EncodeBitArrayHelper(array, 8)
	b3 = RdKGToolMath.EncodeBitArrayHelper(array, 16)
	return b1, b2, b3
end

--Careful not to mess up arrays and b1, b2, b3
function RdKGToolNetworking.DecodeMessageFromBitArray(b1, b2, b3)
	local array = {}
	local tempArray = RdKGToolMath.DecodeBitArrayHelper(b1)
	for i = 1, 8 do
		array[i] = tempArray[i]
	end
	tempArray =RdKGToolMath.DecodeBitArrayHelper(b2)
	local localIndex = 1
	for i = 9, 16 do
		array[i] = tempArray[localIndex]
		localIndex = localIndex + 1
	end
	tempArray =RdKGToolMath.DecodeBitArrayHelper(b3)
	localIndex = 1
	for i = 17, 24 do
		array[i] = tempArray[localIndex]
		localIndex = localIndex + 1
	end
	return array
end

function RdKGToolNetworking.Decode4ByteInt24(b0, b1, b2, b3)
	return (b0 * 16777216) + (b1 * 65536) + (b2 * 256) + b3
end

function RdKGToolNetworking.Encode4ByteInt24(int24)
	local b0 = math.floor(int24 / 16777216)
	local b1 = math.floor((int24 % 16777216) / 65536)
    local b2 = math.floor((int24 % 16777216 % 65536) / 256)
    local b3 = int24 % 256

    return b0, b1, b2, b3
end

-- Compatible with Taos Group Tools Hp / Dmg calculations
function RdKGToolNetworking.DecodeInt24(b1, b2, b3)
    return (b1 * 65536) + (b2 * 256) + b3
end

-- Compatible with Taos Group Tools Hp / Dmg calculations
function RdKGToolNetworking.EncodeInt24(int24)
    local b1 = math.floor(int24 / 65536)
    local b2 = math.floor((int24 % 65536) / 256)
    local b3 = int24 % 256

    return b1, b2, b3
end

--Unfortunately, this code has to be used to integrate with addons like taos
--Original code comes from libgroupsocket
function RdKGToolNetworking.DecodeMessage(x, y)
	x = math.floor(x / RdKGToolNetworking.config.mapStepSize + 0.5)
	y = math.floor(y / RdKGToolNetworking.config.mapStepSize + 0.5)

	local b0 = math.floor(x / 0x100)
	local b1 = x % 0x100
	local b2 = math.floor(y / 0x100)
	local b3 = y % 0x100

	return b0, b1, b2, b3
end

--Unfortunately, this code has to be used to integrate with addons like taos
--Original code comes from libgroupsocket
function RdKGToolNetworking.EncodeMessage(b0, b1, b2, b3)
	b0 = b0 or 0
	b1 = b1 or 0
	b2 = b2 or 0
	b3 = b3 or 0
	return (b0 * 0x100 + b1) * RdKGToolNetworking.config.mapStepSize, (b2 * 0x100 + b3) * RdKGToolNetworking.config.mapStepSize
end

--[[
function RdKGToolNetworking.GetUrgentMode()
	return RdKGToolNetworking.netVars.mode
end]]

--internal functions
function RdKGToolNetworking.Enable()
	--LMP:RegisterCallback("BeforePingAdded", RdKGToolNetworking.OnBeforePingAdded)
	--LMP:RegisterCallback("AfterPingRemoved", RdKGToolNetworking.OnAfterPingRemoved)
	--[[
	local updateInterval = RdKGToolNetworking.netVars.updateInterval
	if updateInterval < 1000 and updateInterval > 3000 then
		updateInterval = RdKGToolNetworking.config.updateInterval
	end]]
	--d(updateInterval)
	--EVENT_MANAGER:RegisterForUpdate(RdKGToolNetworking.callbackName, updateInterval, RdKGToolNetworking.OnSendData)
	
	RdKGToolNetworking.state.isRunning = true
end

function RdKGToolNetworking.Disable()
	--LMP:UnregisterCallback("BeforePingAdded", RdKGToolNetworking.OnBeforePingAdded)
	--LMP:UnregisterCallback("AfterPingRemoved", RdKGToolNetworking.OnAfterPingRemoved)
	--EVENT_MANAGER:UnregisterForUpdate(RdKGToolNetworking.callbackName)
	RdKGToolNetworking.state.isRunning = false
end

function RdKGToolNetworking.HandleRawMessage(message)
	--d(message)
	--[[
	if message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_VERSION_INFORMATION then
		d("received MESSAGE_ID_VERSION_INFORMATION")
	end
	if message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_VERSION_REQUEST then
		d("received MESSAGE_ID_VERSION_REQUEST")
	end
	]]
	if message ~= nil then
		local handlers = RdKGToolNetworking.state.rawMessageHandlers
		for i = 1, #handlers do
			handlers[i].handleRawMessage(message)
		end
	end
end

--callbacks
function RdKGToolNetworking.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolNetworking.netVars = currentProfile.util.networking
		if RdKGToolNetworking.state.initialized == true then
			RdKGToolNetworking.SetEnabled(RdKGToolNetworking.netVars.enabled)
		end
	end
end
--[[
function RdKGToolNetworking.OnBeforePingAdded(pingType, pingTag, x, y, isPingOwner)
	--d("received")
	if (pingType == MAP_PIN_TYPE_PING) then
		LGPS:PushCurrentMap()
		SetMapToMapListIndex(RdKGToolNetworking.config.mapIndex)
		--d(pingTag)
		x, y = LMP:GetMapPing(pingType, pingTag)

		LGPS:PopCurrentMap()
		LMP:SuppressPing(pingType, pingTag)
		
		local message = {}
		message.b0, message.b1, message.b2, message.b3 = RdKGToolNetworking.DecodeMessage(x,y)
		message.pingType = pingType
		message.pingTag = pingTag
		message.x = x
		message.y = y
		message.isPingOwner = isPingOwner
		
		RdKGToolNetworking.HandleRawMessage(message)
	end
end

function RdKGToolNetworking.OnAfterPingRemoved(pingType, pingTag, x, y, isPingOwner)
	if (pingType == MAP_PIN_TYPE_PING) then
			
		LMP:UnsuppressPing(pingType, pingTag)
	end
end
]]



--[[
function RdKGToolNetworking.OnSendData()
	---[-[
	local b0 = 1
	local b1 = math.random(100) -- ulti
	local b2 = math.random(100) -- magicka
	local b3 = math.random(100) -- stamina
	]-]
	--d(GetGameTimeMilliseconds())
	--d("update" .. GetGameTimeMilliseconds())
	if lib3d:IsValidZone() and RdKGToolNetworking.state.lastUrgentMessage + 1000 < GetGameTimeMilliseconds() then
		local queues = RdKGToolNetworking.state.queues
		local queue = nil
		if #queues.critical > 0 then
			queue = queues.critical
		elseif #queues.high > 0 then
			queue = queues.high
		elseif #queues.medium > 0 then
			queue = queues.medium
		elseif #queues.low > 0 then
			queue = queues.low
		end

		if queue ~= nil and #queue > 0 then
			local message = queue[1]
			if message ~= nil and message.b0 ~= nil and message.b1 ~= nil and message.b2 ~= nil and message.b3 ~= nil then
				LGPS:PushCurrentMap()
				SetMapToMapListIndex(RdKGToolNetworking.config.mapIndex)
				---[-[
				if message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_VERSION_INFORMATION then
					d("sent MESSAGE_ID_VERSION_INFORMATION")
				end
				if message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_VERSION_REQUEST then
					d("sent MESSAGE_ID_VERSION_REQUEST")
				end
				]-]
				table.remove(queue, 1)
				LMP:SetMapPing(MAP_PIN_TYPE_PING, MAP_TYPE_LOCATION_CENTERED, RdKGToolNetworking.EncodeMessage(message.b0, message.b1, message.b2, message.b3))
				LGPS:PopCurrentMap()
				message.sent = true
				
				if GetGroupSize() == 0 then
					message.isPingOwner = true
					message.pingType = MAP_PIN_TYPE_PING
					message.pingTag = "player"
					RdKGToolNetworking.HandleRawMessage(message)
				end
			else
				if message ~= nil then
					message.sent = true
					table.remove(queue, 1)
				end
			end
			--d("message sent")
		end
	end
end
]]

--menu interactions
function RdKGToolNetworking.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.NET_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.NET_ENABLED,
					getFunc = RdKGToolNetworking.GetNetEnabled,
					setFunc = RdKGToolNetworking.SetNetEnabled
				}--[[,
				[2] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.NET_URGENT_MODE,
					choices = RdKGToolNetworking.GetNetUrgentModes(),
					getFunc = RdKGToolNetworking.GetNetUrgentMode,
					setFunc = RdKGToolNetworking.SetNetUrgentMode
				},
				[3] = {
					type = "slider",
					name = RdKGToolMenu.constants.NET_INTERVAL,
					min = 1000,
					max = 3000,
					step = 10,
					getFunc = RdKGToolNetworking.GetNetInterval,
					setFunc = RdKGToolNetworking.SetNetInterval,
					width = "full",
					default = RdKGToolNetworking.config.updateInterval
				},--]]
			}
		},
	}
	return menu
end

function RdKGToolNetworking.GetNetEnabled()
	return RdKGToolNetworking.netVars.enabled
end

function RdKGToolNetworking.SetNetEnabled(value)
	RdKGToolNetworking.SetEnabled(value)
end
--[[
function RdKGToolNetworking.GetNetUrgentModes()
	return RdKGToolNetworking.constants.urgentSelection
end

function RdKGToolNetworking.GetNetUrgentMode()
	return RdKGToolNetworking.constants.urgentSelection[RdKGToolNetworking.netVars.mode]
end

function RdKGToolNetworking.SetNetUrgentMode(value)
		if value ~= nil then
		for i = 1, #RdKGToolNetworking.constants.urgentSelection do
			if RdKGToolNetworking.constants.urgentSelection[i] == value then
				RdKGToolNetworking.netVars.mode = i
				break
			end
		end
	end
end

function RdKGToolNetworking.GetNetInterval()
	return RdKGToolNetworking.netVars.updateInterval
end

function RdKGToolNetworking.SetNetInterval(value)
	RdKGToolNetworking.netVars.updateInterval = value
	RdKGToolNetworking.SetNetEnabled(RdKGToolNetworking.netVars.enabled)
end
]]