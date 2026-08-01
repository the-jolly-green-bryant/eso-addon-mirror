-- RdK Group Tool Util Versioning
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.versioning = RdKGToolUtil.versioning or {}
local RdKGToolVersioning = RdKGToolUtil.versioning
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolGroup = RdKGToolUtil.group
RdKGToolUtil.networking = RdKGToolUtil.networking or {}
local RdKGToolNetworking = RdKGToolUtil.networking
RdKGToolUtil.roster = RdKGToolUtil.roster or {}
local RdKGToolRoster = RdKGToolUtil.roster
RdKGToolUtil.chatSystem = RdKGToolUtil.chatSystem or {}
local RdKGToolChat = RdKGToolUtil.chatSystem

RdKGToolVersioning.callbackName = RdKGTool.addonName .. "UtilVersioning"
RdKGToolVersioning.queueCallbackName = RdKGTool.addonName .. "UtilVersioningQueue"


RdKGToolVersioning.config = {}
RdKGToolVersioning.config.featureInterval = 100
RdKGToolVersioning.config.sendInterval = 900000
RdKGToolVersioning.config.requestInterval = 2000

RdKGToolVersioning.constants = {}
RdKGToolVersioning.constants.NO_MESSAGE_INTERVAL = 30000
RdKGToolVersioning.constants.INFORMATION_REQUEST_ALL = 25
RdKGToolVersioning.constants.PREFIX = "Version"

RdKGToolVersioning.state = {}
RdKGToolVersioning.state.clientVersion = {}
RdKGToolVersioning.state.clientVersion.major = 0
RdKGToolVersioning.state.clientVersion.minor = 0
RdKGToolVersioning.state.clientVersion.revision = 0
RdKGToolVersioning.state.clientOutOfDate = false
RdKGToolVersioning.state.isInGroup = false
RdKGToolVersioning.state.requestQueue = {}

RdKGToolVersioning.state.lastMessage = nil
RdKGToolVersioning.state.lastMessageTimeStamp = nil

--functions
function RdKGToolVersioning.Initialize()
	RdKGToolGroup.AddFeature(RdKGToolVersioning.callbackName, RdKGToolGroup.features.FEATURE_GROUP_VERSIONING, RdKGToolVersioning.config.featureInterval)
	RdKGToolGroup.SetVersionCheckCallback(RdKGToolVersioning.CheckVersionInformation)
	RdKGToolVersioning.state.clientVersion = RdKGToolVersioning.GetVersionArray(RdKGTool.versionString)
	
	if GetGroupSize() ~= 0 then
		RdKGToolVersioning.GroupMemberOnJoined()
	end
	
	EVENT_MANAGER:RegisterForEvent(RdKGToolVersioning.callbackName, EVENT_GROUP_MEMBER_JOINED, RdKGToolVersioning.GroupMemberOnJoined)
	EVENT_MANAGER:RegisterForEvent(RdKGToolVersioning.callbackName, EVENT_GROUP_MEMBER_LEFT, RdKGToolVersioning.GroupMemberOnLeft)
	RdKGToolNetworking.AddRawMessageHandler(RdKGToolVersioning.callbackName, RdKGToolVersioning.HandleRawVersioningRequestNetworkMessage)
	EVENT_MANAGER:RegisterForUpdate(RdKGToolVersioning.queueCallbackName, RdKGToolVersioning.config.requestInterval, RdKGToolVersioning.SendQueuedRequests)
end



function RdKGToolVersioning.CheckVersionInformation(player)
	if player ~= nil and player.clientVersion ~= nil then
		--d(player.clientVersion)
		--d(RdKGToolVersioning.state.clientVersion)
		if RdKGToolVersioning.VersionBiggerThan(RdKGToolVersioning.state.clientVersion, player.clientVersion) then
			--d("Other client has an older version")
			if player.clientVersion.versionAlertSent == false then
				player.clientVersion.versionAlertSent = true
				RdKGToolVersioning.SendClientVersionInformation()
			end
		elseif RdKGToolVersioning.VersionLesserThan(RdKGToolVersioning.state.clientVersion, player.clientVersion) then
			--d("Other client has a newer version")
			if RdKGToolVersioning.state.clientOutOfDate == false then
				RdKGToolChat.SendChatMessage(RdKGToolVersioning.constants.CLIENT_OUT_OF_DATE, RdKGToolVersioning.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING)
				RdKGToolVersioning.state.clientOutOfDate = true
			end
		end
	end
end

function RdKGToolVersioning.VersionBiggerThan(versionA, versionB)
	local bigger = false
		if versionA.major > versionB.major or
		   (versionA.major == versionB.major and versionA.minor > versionB.minor) or
		   (versionA.major == versionB.major and versionA.minor == versionB.minor and versionA.revision > versionB.revision) then
			bigger = true
		end
	return bigger
end

function RdKGToolVersioning.VersionLesserThan(versionA, versionB)
	local lesser = false
		if versionA.major < versionB.major or
		   (versionA.major == versionB.major and versionA.minor < versionB.minor) or
		   (versionA.major == versionB.major and versionA.minor == versionB.minor and versionA.revision < versionB.revision) then
			lesser = true
		end
	return lesser
end

function RdKGToolVersioning.GetVersionArray(versionString)
	local versionInformation = {}
	versionInformation.major, versionInformation.minor, versionInformation.revision = 0,0,0
	if versionString ~= nil then
		local tempVersion = {zo_strsplit(".", versionString)}
		if tempVersion[1] ~= nil then
			versionInformation.major = tonumber(tempVersion[1])
		end
		if tempVersion[2] ~= nil then
			versionInformation.minor = tonumber(tempVersion[2])
		end
		if tempVersion[3] ~= nil then
			versionInformation.revision = tonumber(tempVersion[3])
		end
	end
	return versionInformation
end

function RdKGToolVersioning.GetHighestKnownVersionNumber()
	local version = nil
	local players = RdKGToolGroup.GetGroupInformation()
	if players ~= nil then
		for i = 1, #players do
			if version == nil or (version ~= nil and players[i].clientVersion ~= nil and players[i].clientVersion.major ~= nil and players[i].minor ~= nil and players[i].revision ~= nil and RdKGToolVersioning.VersionBiggerThan(players[i].clientVersion, version) == true) then
				version = players[i].clientVersion
			end
		end
	end
	if version ~= nil then
		local copy = {}
		copy.major = version.major
		copy.minor = version.minor
		copy.revision = version.revision
		version = copy
	end
	return version
end

function RdKGToolVersioning.SendClientVersionInformation()
	--d("send client information")
	if (RdKGToolVersioning.state.lastMessage == nil or RdKGToolVersioning.state.lastMessage.sent == true) and (RdKGToolVersioning.state.lastMessageTimeStamp == nil or RdKGToolVersioning.state.lastMessageTimeStamp + RdKGToolVersioning.constants.NO_MESSAGE_INTERVAL < GetGameTimeMilliseconds()) then
		local message = {}
		message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_VERSION_INFORMATION
		message.b1 = RdKGToolVersioning.state.clientVersion.major
		message.b2 = RdKGToolVersioning.state.clientVersion.minor
		message.b3 = RdKGToolVersioning.state.clientVersion.revision
		message.sent = false
		RdKGToolVersioning.state.lastMessage = message
		RdKGToolNetworking.SendVersionMessage(message, RdKGToolNetworking.constants.priorities.MEDIUM)
		RdKGToolVersioning.state.lastMessageTimeStamp = GetGameTimeMilliseconds()
		--d(message)
	end
end

function RdKGToolVersioning.AddVersionInformationRequestToQueue(message)
	if message ~= nil and RdKGToolRoster.IsGuildOfficer(GetUnitDisplayName("player")) then
		--d(message)
		local queueMessage = true
		for i = 1, #RdKGToolVersioning.state.requestQueue do
			local messageEntry = RdKGToolVersioning.state.requestQueue[i]
			if message.b1 == messageEntry.message.b1 and messageEntry.message.sent == false then
				queueMessage = false
			end
		end
		if queueMessage == true then
			--d("adding to queue")
			table.insert(RdKGToolVersioning.state.requestQueue, {requestAdded = false, message = message})
		end
	end
end

function RdKGToolVersioning.RequestVersionInformation(unitTag)
	--d(unitTag)
	local message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_VERSION_REQUEST
	message.b1 = 0
	message.b2 = 0
	message.b3 = 0
	message.sent = false
	if unitTag ~= nil and unitTag ~= "player" then
		local players = RdKGToolGroup.GetGroupInformation()
		if players ~= nil then
			for i = 1, #players do
				if players[i].unitTag == unitTag then
					message.b1 = i
					break
				end
			end
		end
	elseif unitTag == nil then
		message.b1 = RdKGToolVersioning.constants.INFORMATION_REQUEST_ALL
	end
	if message.b1 > 0 then
		RdKGToolVersioning.AddVersionInformationRequestToQueue(message)
	end
end

function RdKGToolVersioning.ProcessVersionInformationRequest(requestingUnitTag, unitIndex)
	--d(requestingUnitTag)
	if unitIndex ~= nil and requestingUnitTag ~= nil then
		--if RdKGToolRoster.IsRdKAdmin(GetUnitDisplayName(requestingUnitTag)) then
		if RdKGToolRoster.IsGuildOfficerOf(GetUnitDisplayName("player"),GetUnitDisplayName(requestingUnitTag)) then
			--d("Version Information Requested")
			local players = RdKGToolGroup.GetGroupInformation()
			local sendInformation = false
			if unitIndex == RdKGToolVersioning.constants.INFORMATION_REQUEST_ALL then
				sendInformation = true
			elseif players ~= nil and players[unitIndex] ~= nil then
				local player = players[unitIndex]
				if player.charName == GetUnitName("player") and player.displayName == GetUnitDisplayName("player") then
					sendInformation = true
				end
			end
			if sendInformation == true then
				--d("send version information")
				RdKGToolVersioning.SendClientVersionInformation()
			end
		end
	end
end

--functions version fix
function RdKGToolVersioning.InitializeFixes(savedVars, charVars)
	RdKGToolVersioning.FixVars(savedVars, charVars, RdKGTool.versionString, savedVars.lastVersion)
	if savedVars.lastVersion ~= RdKGTool.versionString then
		savedVars.reported = nil
	end
	savedVars.lastVersion = RdKGTool.versionString
end

function RdKGToolVersioning.FixVars(savedVars, charVars, currentVersion, lastVersion)
	if lastVersion ~= nil then
		local current = RdKGToolVersioning.GetVersionArray(currentVersion)
		local last = RdKGToolVersioning.GetVersionArray(lastVersion)
		if RdKGToolVersioning.VersionLesserThan(last, RdKGToolVersioning.GetVersionArray("1.1.0")) then
			RdKGToolVersioning.Apply1d1d0Fix(savedVars)
		end
		if RdKGToolVersioning.VersionLesserThan(last, RdKGToolVersioning.GetVersionArray("1.2.1")) then
			RdKGToolVersioning.Apply1d2d1Fix(savedVars)
		end
		if RdKGToolVersioning.VersionLesserThan(last, RdKGToolVersioning.GetVersionArray("1.3.0")) then
			RdKGToolVersioning.Apply1d3d0Fix(savedVars)
		end
		if RdKGToolVersioning.VersionLesserThan(last, RdKGToolVersioning.GetVersionArray("1.12.0")) then
			RdKGToolVersioning.Apply1d12d0Fix(savedVars)
		end
		if RdKGToolVersioning.VersionLesserThan(last, RdKGToolVersioning.GetVersionArray("1.12.2")) then
			RdKGToolVersioning.Apply1d12d2Fix(savedVars)
		end
		if RdKGToolVersioning.VersionLesserThan(last, RdKGToolVersioning.GetVersionArray("2.0.1")) then
			RdKGToolVersioning.Apply2d0d1Fix(savedVars)
		end
		if RdKGToolVersioning.VersionLesserThan(last, RdKGToolVersioning.GetVersionArray("2.0.40")) then
			RdKGToolVersioning.Apply2d0d40Fix(savedVars)
		end
		if RdKGToolVersioning.VersionLesserThan(last, RdKGToolVersioning.GetVersionArray("2.0.43")) then
			RdKGToolVersioning.Apply2d0d43Fix(savedVars)
		end
		if RdKGToolVersioning.VersionLesserThan(last, RdKGToolVersioning.GetVersionArray("2.1.1")) then
			RdKGToolVersioning.Apply2d1d1Fix(savedVars)
		end
	end
end

function RdKGToolVersioning.Apply1d1d0Fix(savedVars)
	local profiles = savedVars.profiles
	for i = 1, #profiles do
		profiles[i].group.ftca.selectedSound = "CrownCrates_Purchased_With_Gems"
		profiles[i].group.ro.selectedSound = "BG_One_Minute_Warning"
	end
end

function RdKGToolVersioning.Apply1d2d1Fix(savedVars)
	local profiles = savedVars.profiles
	for i = 1, #profiles do
		if profiles[i].group.bft ~= nil then
			profiles[i].group.bft.enabled = true
		end
	end
end

function RdKGToolVersioning.Apply1d3d0Fix(savedVars)
	local profiles = savedVars.profiles
	for i = 1, #profiles do
		if profiles[i].group.bft ~= nil then
			profiles[i].toolbox.bft = profiles[i].group.bft
			profiles[i].group.bft = nil
		end
	end
end

function RdKGToolVersioning.Apply1d12d0Fix(savedVars)
	local profiles = savedVars.profiles
	for i = 1, #profiles do
		if profiles[i].group ~= nil and profiles[i].group.gb ~= nil and profiles[i].group.gb.roles ~= nil then
			for j = 1, #profiles[i].group.gb.roles - 1 do
				profiles[i].group.gb.roles[j].enabled = false
			end
		end
	end
end

function RdKGToolVersioning.Apply1d12d2Fix(savedVars)
	local profiles = savedVars.profiles
	for i = 1, #profiles do
		if profiles[i].group ~= nil and profiles[i].group.ro ~= nil and profiles[i].group.ro.ultimates ~= nil then
			profiles[i].group.ro.ultimates.groupSizeNegate = 1
			profiles[i].group.ro.ultimates.maxDistance = 50
		end
	end
end

function RdKGToolVersioning.Apply2d0d1Fix(savedVars)
	local profiles = savedVars.profiles
	for i = 1, #profiles do
		if profiles[i].group ~= nil and profiles[i].group.dt ~= nil and profiles[i].group.dt.fontColor ~= nil and profiles[i].group.dt.detonation ~= nil then
			profiles[i].group.dt.detonation.fontColor = profiles[i].group.dt.fontColor
			profiles[i].group.dt.fontColor = nil
		end
		if profiles[i].group ~= nil and profiles[i].group.dt ~= nil and profiles[i].group.dt.progressColor ~= nil and profiles[i].group.dt.detonation ~= nil then
			profiles[i].group.dt.detonation.progressColor = profiles[i].group.dt.progressColor
			profiles[i].group.dt.progressColor = nil
		end
	end
end

--New Arcanist Ulti (RO Split) Order
--[[
runebreak SO -> Übersetzungen
runebreak SP -> Übersetzungen
/script RdKGTool.util.versioning.Apply2d0d40Fix(RdKGTool.vars.acc)
]]

function RdKGToolVersioning.Apply2d0d40Fix(savedVars)
	local profiles = savedVars.profiles
	for i = 1, #profiles do
		if profiles[i].group ~= nil and profiles[i].group.ro ~= nil and profiles[i].group.ro.groups ~= nil and profiles[i].group.ro.groups.ultimateGroups ~= nil then
			local ultimateGroups = profiles[i].group.ro.groups.ultimateGroups
			for j = 38, 25, -1 do
				ultimateGroups[j + 3].group = ultimateGroups[j].group
				ultimateGroups[j + 3].priority = ultimateGroups[j].priority
			end
			ultimateGroups[25].group = 1
			ultimateGroups[25].priority = 20
			ultimateGroups[26].group = 3
			ultimateGroups[26].priority = 20
			ultimateGroups[27].group = 3
			ultimateGroups[27].priority = 30
			--d("profile " .. i .. " done")
		end
	end
	--d("done with fix")
end


function RdKGToolVersioning.Apply2d0d43Fix(savedVars)
	local profiles = savedVars.profiles
	for i = 1, #profiles do
		local smItems = profiles[i].toolbox.sm.items
		smItems[1].minimum = 0 -- Old repair kit
		smItems[1].maximum = 0 -- Old repair kit
		smItems[2].minimum = 0 -- Old repair kit
		smItems[2].maximum = 0 -- Old repair kit
		smItems[3].minimum = 0 -- Old repair kit
		smItems[3].maximum = 0 -- Old repair kit
		smItems[17].minimum = 0 -- Old repair kit
		smItems[17].maximum = 0 -- Old repair kit
	end
	
end

function RdKGToolVersioning.Apply2d1d1Fix(savedVars)
	local profiles = savedVars.profiles
	for i = 1, #profiles do
		local netItems = profiles[i].util.networking
		netItems.mode = nil
		netItems.updateInterval = nil
	end
end

--callbacks
function RdKGToolVersioning.SendQueuedRequests()
	--d(#RdKGToolVersioning.state.requestQueue)
	for i = 1, #RdKGToolVersioning.state.requestQueue do
		local messageEntry = RdKGToolVersioning.state.requestQueue[i]
		if messageEntry ~= nil and messageEntry.message ~= nil and messageEntry.message.sent == true then
			table.remove(RdKGToolVersioning.state.requestQueue, i)
			i = i - 1
		elseif messageEntry ~= nil then
			if messageEntry.requestAdded == true then
				--Already on Network Queue
			else
				messageEntry.requestAdded = true
				--d("sending message")
				RdKGToolNetworking.SendVersionMessage(messageEntry.message, RdKGToolNetworking.constants.priorities.MEDIUM)
			end
		end
	end
end

function RdKGToolVersioning.SendLoop()
	--d("sent")
	RdKGToolVersioning.SendClientVersionInformation()
end

function RdKGToolVersioning.GroupMemberOnJoined(...)
	if RdKGToolVersioning.state.isInGroup == false then
		RdKGToolVersioning.state.isInGroup = true
		RdKGToolVersioning.SendClientVersionInformation()
		EVENT_MANAGER:RegisterForUpdate(RdKGToolVersioning.callbackName,  RdKGToolVersioning.config.sendInterval, RdKGToolVersioning.SendLoop)
	end
end

function RdKGToolVersioning.GroupMemberOnLeft(...)
	if GetGroupSize() ~= 0 then
		RdKGToolVersioning.state.isInGroup = true
	else
		RdKGToolVersioning.state.isInGroup = false
		EVENT_MANAGER:UnregisterForUpdate(RdKGToolVersioning.callbackName)
	end
end

function RdKGToolVersioning.HandleRawVersioningRequestNetworkMessage(message)
	if message ~= nil and message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_VERSION_REQUEST then
		--d("version request received")
		--d(message)
		RdKGToolVersioning.ProcessVersionInformationRequest(message.pingTag, message.b1)
	end
end