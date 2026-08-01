-- RdK Group Tool Role Assignment
-- By @s0rdrak (PC / EU)

RdKGTool.toolbox = RdKGTool.toolbox or {}
local RdKGToolTB = RdKGTool.toolbox
RdKGToolTB.ra = RdKGToolTB.ra or {}
local RdKGToolRa = RdKGToolTB.ra
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolUtilGroup = RdKGToolUtil.group
RdKGToolUtil.networking = RdKGToolUtil.networking or {}
local RdKGToolNetworking = RdKGToolUtil.networking
RdKGToolUtil.chatSystem = RdKGToolUtil.chatSystem or {}
local RdKGToolChat = RdKGToolUtil.chatSystem

RdKGToolRa.constants = RdKGToolRa.constants or {}
RdKGToolRa.constants.PREFIX = "RA"

RdKGToolRa.callbackName = RdKGTool.addonName .. "RoleAssignment"

RdKGToolRa.config = {}
RdKGToolRa.config.updateInterval = 30000

RdKGToolRa.state = {}
RdKGToolRa.state.registredConsumers = false
RdKGToolRa.state.initialized = false
RdKGToolRa.state.lastMessages = nil

function RdKGToolRa.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolRa.callbackName, RdKGToolRa.OnProfileChanged)

	RdKGToolRa.state.roles = {}
	RdKGToolRa.state.roles[RdKGToolUtilGroup.constants.roles.ROLE_RAPID] = RdKGToolUtilGroup.constants.ROLE_RAPID
	RdKGToolRa.state.roles[RdKGToolUtilGroup.constants.roles.ROLE_PURGE] = RdKGToolUtilGroup.constants.ROLE_PURGE
	RdKGToolRa.state.roles[RdKGToolUtilGroup.constants.roles.ROLE_HEAL] = RdKGToolUtilGroup.constants.ROLE_HEAL
	RdKGToolRa.state.roles[RdKGToolUtilGroup.constants.roles.ROLE_DD] = RdKGToolUtilGroup.constants.ROLE_DD
	RdKGToolRa.state.roles[RdKGToolUtilGroup.constants.roles.ROLE_SYNERGY] = RdKGToolUtilGroup.constants.ROLE_SYNERGY
	RdKGToolRa.state.roles[RdKGToolUtilGroup.constants.roles.ROLE_CC] = RdKGToolUtilGroup.constants.ROLE_CC
	RdKGToolRa.state.roles[RdKGToolUtilGroup.constants.roles.ROLE_SUPPORT] = RdKGToolUtilGroup.constants.ROLE_SUPPORT
	RdKGToolRa.state.roles[RdKGToolUtilGroup.constants.roles.ROLE_PLACEHOLDER] = RdKGToolUtilGroup.constants.ROLE_PLACEHOLDER
	RdKGToolRa.state.roles[RdKGToolUtilGroup.constants.roles.ROLE_APPLICANT] = RdKGToolUtilGroup.constants.ROLE_APPLICANT
	RdKGToolRa.state.roles[RdKGToolUtilGroup.constants.roles.ROLE_APPLICANT + 1] = "-"
	
	RdKGToolRa.state.initialized = true
	
	RdKGToolRa.SetEnabled(RdKGToolRa.raVars.enabled)
end

function RdKGToolRa.GetDefaults()
	local defaults = {}
	defaults.enabled = true
	defaults.allowOverride = true
	return defaults
end

function RdKGToolRa.SetEnabled(value)
	if RdKGToolRa.state.initialized == true and value ~= nil then
		RdKGToolRa.raVars.enabled = value
		if value == true then
			RdKGToolRa.AdjustRole()
			if RdKGToolRa.state.registredConsumers == false then
				EVENT_MANAGER:RegisterForEvent(RdKGToolRa.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolRa.OnPlayerActivated)
				EVENT_MANAGER:RegisterForUpdate(RdKGToolRa.callbackName, RdKGToolRa.config.updateInterval, RdKGToolRa.SendRoleLoop)
				RdKGToolNetworking.AddRawMessageHandler(RdKGToolRa.callbackName, RdKGToolRa.HandleRawNetworkMessage)
			end
			RdKGToolRa.state.registredConsumers = true
		else
			if RdKGToolRa.state.registredConsumers == true then
				RdKGToolNetworking.RemoveRawMessageHandler(RdKGToolRa.callbackName)
				EVENT_MANAGER:UnregisterForEvent(RdKGToolRa.callbackName, EVENT_PLAYER_ACTIVATED)
				EVENT_MANAGER:UnregisterForUpdate(RdKGToolRa.callbackName)
			end
			RdKGToolRa.state.registredConsumers = false
		end
		RdKGToolRa.OnPlayerActivated()
	end
end

function RdKGToolRa.SetPlayerRole(charName, displayName, role)
	local leader = RdKGToolUtilGroup.GetLeaderUnit()
	if leader ~= nil and leader.isPlayer == true then
		local players = RdKGToolUtilGroup.GetGroupInformation()
		if players ~= nil then
			local index = 0
			for i = 1, #players do
				if players[i].charName == charName and players[i].displayName == displayName then
					index = i
					break
				end
			end
			if index > 0 then
				local message = {}
				message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ROLE
				message.b1 = RdKGToolNetworking.messageIdentifiers.roleMessage.MESSAGE_ADMIN_SET_ROLE
				message.b2 = index
				message.b3 = role
				if message.b3 == nil then
					message.b3 = 0
				end
				message.sent = false
				RdKGToolNetworking.SendMessage(message, RdKGToolNetworking.constants.priorities.MEDIUM)
				RdKGToolChat.SendChatMessage("Set Role Message Sent: " .. message.b1 .. " - " .. message.b2 .. " - " .. message.b3, RdKGToolRa.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
			end
		end
	end
end

function RdKGToolRa.SendRole()
	if RdKGToolRa.raVars.enabled == true then
		local playerUnitTag = RdKGToolUtilGroup.GetUnitTagForPlayer()
		if playerUnitTag ~= nil then
			local player = RdKGToolUtilGroup.GetPlayerByUnitTag(playerUnitTag)
			if player ~= nil then
				if RdKGToolRa.state.lastMessages == nil or RdKGToolRa.state.lastMessages.sent == true then
					local role = player.role
					if role == nil then
						role = 0
					end
					local roleName = ""
					if role == 0 then
						roleName = RdKGToolRa.state.roles[RdKGToolUtilGroup.constants.roles.ROLE_APPLICANT + 1]
					else
						roleName = RdKGToolRa.state.roles[role]
					end
					local message = {}
					message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ROLE
					message.b1 = role
					message.b2 = 0
					message.b3 = 0
					message.sent = false
					RdKGToolNetworking.SendMessage(message, RdKGToolNetworking.constants.priorities.MEDIUM)
					RdKGToolRa.state.lastMessages = message
					RdKGToolChat.SendChatMessage("Role Message Sent: " .. message.b1 .. " - " .. roleName, RdKGToolRa.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
				end
			end
		end
	end
end

function RdKGToolRa.AdjustRole()
	if RdKGToolRa.raVars.enabled == true then
		local role = RdKGToolRa.charVars.selectedRole
		if role == RdKGToolUtilGroup.constants.roles.ROLE_APPLICANT + 1 then
			role = nil
		end
		RdKGToolUtilGroup.SetRole(GetUnitName("player") , GetUnitDisplayName("player"), role)
		RdKGToolRa.SendRole()
	end
end

--callbacks
function RdKGToolRa.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolRa.raVars = currentProfile.toolbox.ra
		local charVars = RdKGTool.profile.GetCharacterVars()
		charVars.ra = charVars.ra or {}
		RdKGToolRa.charVars = charVars.ra
		if RdKGToolRa.state.initialized == true then
			RdKGToolRa.SetEnabled(RdKGToolRa.raVars.enabled)
		end
	end
end

function RdKGToolRa.OnPlayerActivated(eventCode, initial)
	if RdKGToolRa.raVars.enabled == true then
		RdKGToolRa.SendRole()
	end
end

function RdKGToolRa.SendRoleLoop()
	if RdKGToolRa.raVars.enabled == true then
		if RdKGToolUtilGroup.IsGroupInCombat() == false then
			RdKGToolRa.SendRole()
		end
	end
end

function RdKGToolRa.HandleRawNetworkMessage(message)
	if message ~= nil and message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ROLE then
		RdKGToolChat.SendChatMessage("Role Message Received: " .. message.b1 .. " - " .. message.b2 .. " -- " .. message.b3, RdKGToolRa.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
		if RdKGToolRa.raVars.allowOverride == true and message.b1 ~= RdKGToolNetworking.messageIdentifiers.roleMessage.MESSAGE_ADMIN_SET_ROLE then
			local player = RdKGToolUtilGroup.GetPlayerByUnitTag(message.pingTag)
			if player ~= nil and player.isPlayer == false then
				player.role = message.b1
				if player.role == 0 then
					player.role = nil
				end
			end
		end
		local sender = RdKGToolUtilGroup.GetPlayerByUnitTag(message.pingTag)
		if sender ~= nil and sender.isLeader == true and message.b1 == RdKGToolNetworking.messageIdentifiers.roleMessage.MESSAGE_ADMIN_SET_ROLE then
			local players = RdKGToolUtilGroup.GetGroupInformation()
			if players ~= nil and message.b2 ~= nil and message.b2 >= 1 and message.b2 <= #players then
				local player = players[message.b2]
				local role = message.b3
				player.role = message.b3
				if player.role == 0 then
					player.role = nil
				end
				if player.isPlayer == true then
					if RdKGToolRa.state.lastMessages ~= nil and RdKGToolRa.state.lastMessages.sent == false then
						local queuedMessage = RdKGToolRa.state.lastMessages
						queuedMessage.b1 = message.b3
					end
				end
			end
		end
	end
end

--menu interaction
function RdKGToolRa.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.RA_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RA_ENABLED,
					getFunc = RdKGToolRa.GetRaEnabled,
					setFunc = RdKGToolRa.SetRaEnabled
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RA_OVERRIDE_ALLOWED,
					getFunc = RdKGToolRa.GetRaAllowOverride,
					setFunc = RdKGToolRa.SetRaAllowOverride
				},
				[3] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.RA_ROLE,
					choices = RdKGToolRa.GetRaRoles(),
					getFunc = RdKGToolRa.GetRaRole,
					setFunc = RdKGToolRa.SetRaRole
				},
			}
		},
	}
	return menu
end

function RdKGToolRa.GetRaEnabled()
	return RdKGToolRa.raVars.enabled
end

function RdKGToolRa.SetRaEnabled(value)
	RdKGToolRa.SetEnabled(value)
end

function RdKGToolRa.GetRaAllowOverride()
	return RdKGToolRa.raVars.allowOverride
end

function RdKGToolRa.SetRaAllowOverride(value)
	RdKGToolRa.raVars.allowOverride = value
end

function RdKGToolRa.GetRaRoles()
	return RdKGToolRa.state.roles
end

function RdKGToolRa.GetRaRole()
	local roles = RdKGToolRa.state.roles
	local selectedRole = "-"
	if roles[RdKGToolRa.charVars.selectedRole] ~= nil then
		selectedRole = roles[RdKGToolRa.charVars.selectedRole]
	end
	return selectedRole
end

function RdKGToolRa.SetRaRole(value)
	RdKGToolRa.charVars.selectedRole = nil
	if value ~= nil then
		local roles = RdKGToolRa.state.roles
		for i = 1, #roles do
			if roles[i] == value then
				RdKGToolRa.charVars.selectedRole = i
				break
			end
		end
	end
	RdKGToolRa.AdjustRole()
end