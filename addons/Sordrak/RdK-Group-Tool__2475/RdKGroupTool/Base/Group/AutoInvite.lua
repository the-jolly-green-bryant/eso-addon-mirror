-- RdK Group Tool Auto Invite
-- By @s0rdrak (PC / EU)

RdKGTool.group.ai = RdKGTool.group.ai or {}
local RdKGToolAI = RdKGTool.group.ai
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolGroup = RdKGToolUtil.group
RdKGToolUtil.chatSystem = RdKGToolUtil.chatSystem or {}
local RdKGToolChat = RdKGToolUtil.chatSystem

local wm = WINDOW_MANAGER

RdKGToolAI.callbackName = RdKGTool.addonName .. "AutoInvite"

RdKGToolAI.constants = RdKGToolAI.constants or {}
RdKGToolAI.constants.BODY_CONTROL_NAME = "RdKGTool.group.ai.AutoInviteControl"
RdKGToolAI.constants.RESTRICTIONS_NONE = 1
RdKGToolAI.constants.RESTRICTIONS_GUILD = 2
RdKGToolAI.constants.RESTRICTIONS_GUILD_FRIEND = 3
RdKGToolAI.constants.RESTRICTIONS_FRIEND = 4
RdKGToolAI.constants.RESTRICTIONS_SPECIFIC_GUILD = 5
RdKGToolAI.constants.RESTRICTIONS_SPECIFIC_GUILD_FRIEND = 6
RdKGToolAI.constants.RESTRICTIONS = {}
RdKGToolAI.constants.PREFIX = "AI"
RdKGToolAI.constants.references = RdKGToolAI.constants.references or {}
RdKGToolAI.constants.references.AI_ENABLED_CHECKBOX = "RdKGTool.menu.AIEnabledCheckbox"
RdKGToolAI.constants.references.AI_INVITE_TEXTBOX = "RdKGTool.menu.AIInviteStringTextbox"

RdKGToolAI.config = RdKGToolAI.config or {}
RdKGToolAI.config.font = "$(BOLD_FONT)|$(KB_20)soft-shadow-thick"

RdKGToolAI.state = {}
RdKGToolAI.state.enabled = false
RdKGToolAI.state.isLeader = false
RdKGToolAI.state.previousStateRunning = false
RdKGToolAI.state.offliner = {}

RdKGToolAI.aiVars = nil

RdKGToolAI.slashCmd = "/ai"


function RdKGToolAI.Initialize()
	--vars
	RdKGTool.profile.AddProfileChangeListener(RdKGToolAI.callbackName, RdKGToolAI.OnProfileChanged)
	RdKGToolAI.constants.RESTRICTIONS[RdKGToolAI.constants.RESTRICTIONS_NONE] = RdKGTool.menu.constants.AI_CHAT_RESTRICTIONS_NONE
	RdKGToolAI.constants.RESTRICTIONS[RdKGToolAI.constants.RESTRICTIONS_GUILD] = RdKGTool.menu.constants.AI_CHAT_RESTRICTIONS_GUILD
	RdKGToolAI.constants.RESTRICTIONS[RdKGToolAI.constants.RESTRICTIONS_GUILD_FRIEND] = RdKGTool.menu.constants.AI_CHAT_RESTRICTIONS_GUILD_FRIEND
	RdKGToolAI.constants.RESTRICTIONS[RdKGToolAI.constants.RESTRICTIONS_FRIEND] = RdKGTool.menu.constants.AI_CHAT_RESTRICTIONS_FRIEND
	RdKGToolAI.constants.RESTRICTIONS[RdKGToolAI.constants.RESTRICTIONS_SPECIFIC_GUILD] = RdKGTool.menu.constants.AI_CHAT_RESTRICTIONS_SPECIFIC_GUILD
	RdKGToolAI.constants.RESTRICTIONS[RdKGToolAI.constants.RESTRICTIONS_SPECIFIC_GUILD_FRIEND] = RdKGTool.menu.constants.AI_CHAT_RESTRICTIONS_SPECIFIC_GUILD_FRIEND
	
	ZO_CreateStringId("SI_BINDING_NAME_RDKGTOOL_TOGGLE_AI", RdKGToolAI.constants.TOGGLE_AI)
	
	--UI
	
	RdKGToolAI.groupFragement = ZO_FadeSceneFragment:New(RdKGTool_AutoInvite)
	local data =
		{
			name = RdKGToolAI.constants.AI_MENU_NAME,
			categoryFragment = RdKGToolAI.groupFragement,
			normalIcon = "EsoUI/Art/Guild/tabIcon_history_up.dds",
			pressedIcon = "EsoUI/Art/Guild/tabIcon_history_down.dds",
			mouseoverIcon = "EsoUI/Art/Guild/tabIcon_history_over.dds",
			priority = 500
		}
		
		
	
	GROUP_MENU_KEYBOARD:AddCategory(data)

	RdKGToolAI.groupFragement.bodyControl = wm:CreateControl(RdKGToolAI.constants.BODY_CONTROL_NAME, RdKGTool_AutoInvite, CT_CONTROL)
	RdKGToolAI.groupFragement.bodyControl:SetAnchor(TOPLEFT, ZO_GroupList, TOPLEFT, 0, 0)

	
	local checkbox = {}
	checkbox.width = 600
	checkbox.height = 26
	checkbox.isEnabled = true
	checkbox.isChecked = RdKGToolAI.state.enabled
	checkbox.text = RdKGToolAI.constants.AI_ENABLED
	checkbox.OnCheckChanged = RdKGToolAI.OnCheckChanged
	
	RdKGToolAI.groupFragement.bodyControl.enabledCheckbox = RdKGToolUtil.ui.CreateCheckBox(RdKGToolAI.groupFragement.bodyControl, checkbox, nil)
	RdKGToolAI.groupFragement.bodyControl.enabledCheckbox:SetAnchor(TOPLEFT, RdKGToolAI.groupFragement.bodyControl, TOPLEFT, 0, 0)
	
	RdKGToolAI.groupFragement.bodyControl.inviteControl = wm:CreateControl(nil, RdKGToolAI.groupFragement.bodyControl, CT_CONTROL)
	RdKGToolAI.groupFragement.bodyControl.inviteControl:SetDimensions(600,26)
	RdKGToolAI.groupFragement.bodyControl.inviteControl:SetAnchor(TOPLEFT, RdKGToolAI.groupFragement.bodyControl, TOPLEFT, 0, 30)
	
	RdKGToolAI.groupFragement.bodyControl.inviteControl.label = wm:CreateControl(nil, RdKGToolAI.groupFragement.bodyControl.inviteControl, CT_LABEL)
	RdKGToolAI.groupFragement.bodyControl.inviteControl.label:SetDimensions(400,26)
	RdKGToolAI.groupFragement.bodyControl.inviteControl.label:SetAnchor(TOPLEFT, RdKGToolAI.groupFragement.bodyControl.inviteControl, TOPLEFT, 0, 0)
	RdKGToolAI.groupFragement.bodyControl.inviteControl.label:SetFont(RdKGToolAI.config.font)
	RdKGToolAI.groupFragement.bodyControl.inviteControl.label:SetText(RdKGToolAI.constants.AI_INVITE_TEXT)
	
	RdKGToolAI.groupFragement.bodyControl.inviteControl.bd = wm:CreateControlFromVirtual(nil, RdKGToolAI.groupFragement.bodyControl.inviteControl, "ZO_EditBackdrop")
	RdKGToolAI.groupFragement.bodyControl.inviteControl.editbox = wm:CreateControlFromVirtual(nil, RdKGToolAI.groupFragement.bodyControl.inviteControl.bd, "ZO_DefaultEditForBackdrop")

	RdKGToolAI.groupFragement.bodyControl.inviteControl.bd:SetAnchor(TOPLEFT, RdKGToolAI.groupFragement.bodyControl.inviteControl, TOPLEFT, 400, 0)
	RdKGToolAI.groupFragement.bodyControl.inviteControl.bd:SetDimensions(200,26)
	
	RdKGToolAI.groupFragement.bodyControl.inviteControl.editbox:SetMaxInputChars(64)
	RdKGToolAI.groupFragement.bodyControl.inviteControl.editbox:SetHandler("OnTextChanged", RdKGToolAI.OnInviteTextChanged)
	RdKGToolAI.groupFragement.bodyControl.inviteControl.editbox:SetAnchor(TOPLEFT, RdKGToolAI.groupFragement.bodyControl.inviteControl, TOPLEFT, 400, 0)
	RdKGToolAI.groupFragement.bodyControl.inviteControl.editbox:SetDimensions(200,26)
	RdKGToolAI.groupFragement.bodyControl.inviteControl.editbox:SetText(RdKGToolAI.aiVars.inviteText)
	EVENT_MANAGER:RegisterForEvent(RdKGToolAI.callbackName, EVENT_GROUP_MEMBER_JOINED, RdKGToolAI.OnMemberJoined)
	EVENT_MANAGER:RegisterForEvent(RdKGToolAI.callbackName, EVENT_LEADER_UPDATE, RdKGToolAI.OnLeaderUpdated)
	EVENT_MANAGER:RegisterForEvent(RdKGToolAI.callbackName, EVENT_CHAT_MESSAGE_CHANNEL, RdKGToolAI.ChatMessageReceived)
	EVENT_MANAGER:RegisterForEvent(RdKGToolAI.callbackName, EVENT_GROUP_MEMBER_LEFT, RdKGToolAI.OnMemberLeft)
	EVENT_MANAGER:RegisterForEvent(RdKGToolAI.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolAI.OnPlayerActivated)
	
	RdKGToolAI.OnLeaderUpdated(EVENT_LEADER_UPDATE, nil)
	
	SLASH_COMMANDS[RdKGToolAI.slashCmd] = RdKGToolAI.CustomSlashCmd
end

function RdKGToolAI.GetDefaults()
	local defaults = {}
	defaults.inviteText = "rdk"
	defaults.maxGroupSize = 24
	defaults.pvpOnly = false
	defaults.sendChatMessages = true
	defaults.autokick = true
	defaults.autokickTime = 30
	defaults.channels = {}
	defaults.channels["G1"] = true
	defaults.channels["O1"] = true
	defaults.channels["G2"] = true
	defaults.channels["O2"] = true
	defaults.channels["G3"] = true
	defaults.channels["O3"] = true
	defaults.channels["G4"] = true
	defaults.channels["O4"] = true
	defaults.channels["G5"] = true
	defaults.channels["O5"] = true
	defaults.channels["EMOTE"] = false
	defaults.channels["SAY"] = false
	defaults.channels["YELL"] = false
	defaults.channels["GROUP"] = false
	defaults.channels["TELL"] = true
	defaults.channels["ZONE"] = false
	defaults.channels["ENZONE"] = false
	defaults.channels["FRZONE"] = false
	defaults.channels["DEZONE"] = false
	defaults.channels["JPZONE"] = false
	defaults.restrictions = RdKGToolAI.constants.RESTRICTIONS_GUILD_FRIEND
	defaults.alwaysShowLeave = true
	return defaults
end

function RdKGToolAI.CustomSlashCmd(param)
	RdKGToolChat.SendChatMessage(string.format("%s %s", RdKGToolAI.slashCmd, param), RdKGToolAI.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_NORMAL, RdKGToolAI.aiVars.sendChatMessages)
	--d(string.format("%s %s", RdKGToolAI.slashCmd, param))
	param = {zo_strsplit(" ", zo_strtrim(param))}
	RdKGToolAI.SlashCmd(param)
end

function RdKGToolAI.SlashCmd(param)
	--d(param)
	if #param > 0 then
		local inviteString = ""
		for i = 1, #param do
			inviteString = inviteString .. " " .. param[i]
		end
		inviteString = zo_strtrim(inviteString)
		if inviteString ~= "" then
			RdKGToolAI.aiVars.inviteText = inviteString
			RdKGToolAI.groupFragement.bodyControl.inviteControl.editbox:SetText(inviteString)
			RdKGToolAI.SetAIInviteText(inviteString)
			
			RdKGToolAI.state.enabled = true
			RdKGToolAI.groupFragement.bodyControl.enabledCheckbox:SetChecked(true)
			RdKGToolAI.SetAICheckedState(true)
			
			RdKGToolAI.SetKickCheck()
		end
	else
		RdKGToolAI.state.enabled = false
		RdKGToolAI.groupFragement.bodyControl.enabledCheckbox:SetChecked(false)
		RdKGToolAI.SetAICheckedState(false)
		RdKGToolAI.SetKickCheck()
	end
end

function RdKGToolAI.GetMenu()
	local menu = {
	
	}
	return menu
end

function RdKGToolAI.IsChatAllowed(channelType)
	--channelType (12 - 16 g1-5, 17-21 o1-5)
	--6: emote
	--0: say
	--1: yell
	--3: group
	--4: whisper (tell) (2 is real)
	--31: zone
	--32: enzone
	--33: frzone
	--34: dezone
	--35: jpzone
	local retVal = false
	if channelType ~= nil and (
	(channelType == 12 and RdKGToolAI.aiVars.channels["G1"] == true) or
	(channelType == 13 and RdKGToolAI.aiVars.channels["G2"] == true) or
	(channelType == 14 and RdKGToolAI.aiVars.channels["G3"] == true) or
	(channelType == 15 and RdKGToolAI.aiVars.channels["G4"] == true) or
	(channelType == 16 and RdKGToolAI.aiVars.channels["G5"] == true) or
	(channelType == 17 and RdKGToolAI.aiVars.channels["O1"] == true) or
	(channelType == 18 and RdKGToolAI.aiVars.channels["O2"] == true) or
	(channelType == 19 and RdKGToolAI.aiVars.channels["O3"] == true) or
	(channelType == 20 and RdKGToolAI.aiVars.channels["O4"] == true) or
	(channelType == 21 and RdKGToolAI.aiVars.channels["O5"] == true) or
	(channelType == 0 and RdKGToolAI.aiVars.channels["SAY"] == true) or
	(channelType == 1 and RdKGToolAI.aiVars.channels["YELL"] == true) or
	(channelType == 2 and RdKGToolAI.aiVars.channels["TELL"] == true) or
	(channelType == 6 and RdKGToolAI.aiVars.channels["EMOTE"] == true) or
	(channelType == 31 and RdKGToolAI.aiVars.channels["ZONE"] == true) or
	(channelType == 32 and RdKGToolAI.aiVars.channels["ENZONE"] == true) or
	(channelType == 33 and RdKGToolAI.aiVars.channels["FRZONE"] == true) or
	(channelType == 34 and RdKGToolAI.aiVars.channels["DEZONE"] == true) or
	(channelType == 35 and RdKGToolAI.aiVars.channels["JPZONE"] == true)
	) then
		retVal = true
	end
	return retVal
end


function RdKGToolAI.IsAllowedToInvite()
	local isAllowed = false
	if GetGroupSize() == 0 then
		isAllowed = true
	else
		isAllowed = RdKGToolAI.state.isLeader
	end
	
	return isAllowed
end

function RdKGToolAI.ValidRestrictions(fromDisplayName) 
	local hasValidRestrictions = false
	if RdKGToolAI.aiVars.restrictions == RdKGToolAI.constants.RESTRICTIONS_NONE then
		hasValidRestrictions = true
	elseif RdKGToolAI.aiVars.restrictions == RdKGToolAI.constants.RESTRICTIONS_GUILD then
		hasValidRestrictions = RdKGToolUtil.roster.IsGuildMemberByAccountName(fromDisplayName)
	elseif RdKGToolAI.aiVars.restrictions == RdKGToolAI.constants.RESTRICTIONS_GUILD_FRIEND then
		hasValidRestrictions = RdKGToolUtil.roster.IsGuildMemberByAccountName(fromDisplayName) or RdKGToolUtil.roster.IsFriendByAccountName(fromDisplayName)
	elseif RdKGToolAI.aiVars.restrictions == RdKGToolAI.constants.RESTRICTIONS_FRIEND then
		hasValidRestrictions = RdKGToolUtil.roster.IsFriendByAccountName(fromDisplayName)
	elseif RdKGToolAI.aiVars.restrictions == RdKGToolAI.constants.RESTRICTIONS_SPECIFIC_GUILD then
		hasValidRestrictions = RdKGToolUtil.roster.IsGuildMemberByAccountName(fromDisplayName, {RdKGToolAI.aiVars.channels["G1"], RdKGToolAI.aiVars.channels["G2"], RdKGToolAI.aiVars.channels["G3"], RdKGToolAI.aiVars.channels["G4"], RdKGToolAI.aiVars.channels["G5"]})
	elseif RdKGToolAI.aiVars.restrictions == RdKGToolAI.constants.RESTRICTIONS_SPECIFIC_GUILD_FRIEND then
		hasValidRestrictions = RdKGToolUtil.roster.IsGuildMemberByAccountName(fromDisplayName, {RdKGToolAI.aiVars.channels["G1"], RdKGToolAI.aiVars.channels["G2"], RdKGToolAI.aiVars.channels["G3"], RdKGToolAI.aiVars.channels["G4"], RdKGToolAI.aiVars.channels["G5"]}) or RdKGToolUtil.roster.IsFriendByAccountName(fromDisplayName)
	end

	return hasValidRestrictions
end

function RdKGToolAI.SetKickCheck()
	if RdKGToolAI.aiVars.autokick == true and RdKGToolAI.state.enabled == true then
		if RdKGToolAI.state.previousStateRunning == false then
			RdKGToolAI.state.offliner = {}
			RdKGToolAI.CreateOfflinerList()
			EVENT_MANAGER:RegisterForUpdate(RdKGToolAI.callbackName, 1000, RdKGToolAI.CheckForKick)
			EVENT_MANAGER:RegisterForEvent(RdKGToolAI.callbackName, EVENT_GROUP_MEMBER_CONNECTED_STATUS, RdKGToolAI.OnMemberConnectedStatus)
			EVENT_MANAGER:RegisterForEvent(RdKGToolAI.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolAI.CreateOfflinerList)
		end
			RdKGToolAI.state.previousStateRunning = true
	else
		EVENT_MANAGER:UnregisterForUpdate(RdKGToolAI.callbackName)
		EVENT_MANAGER:UnregisterForEvent(RdKGToolAI.callbackName, EVENT_GROUP_MEMBER_CONNECTED_STATUS)
		EVENT_MANAGER:UnregisterForEvent(RdKGToolAI.callbackName, EVENT_PLAYER_ACTIVATED)
		RdKGToolAI.state.previousStateRunning = false
		RdKGToolAI.state.offliner = {}
	end
end

function RdKGToolAI.CreateOfflinerList()
	local size = GetGroupSize()
	
	for i = 1, size do
		local unitTag = GetGroupUnitTagByIndex(i)
		if IsUnitOnline(unitTag) == false then
			local exists = false
			local name = GetUnitName(unitTag)
			for i = 1, #RdKGToolAI.state.offliner do
				if RdKGToolAI.state.offliner[i].name == name then
					exists = true
					break
				end
			end
			if exists == false then
				local character = {}
				character.name = name
				character.timeStamp = GetTimeStamp()
				table.insert(RdKGToolAI.state.offliner, character)
			end
		else
			for i = 1, #RdKGToolAI.state.offliner do
				if RdKGToolAI.state.offliner[i].name == name then
					table.remove(RdKGToolAI.state.offliner, i)
					i = i - 1
				end
			end
		end
	end
end

--profile synchronization
function RdKGToolAI.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolAI.state.enabled = false
		RdKGToolAI.aiVars = currentProfile.group.ai
	end
end

--callbacks
function RdKGToolAI.OnInviteTextChanged()
	local inviteString = RdKGToolAI.groupFragement.bodyControl.inviteControl.editbox:GetText()
	
	if inviteString ~= nil and inviteString ~= RdKGToolAI.aiVars.inviteText then
		--d("state adjustment needed")
		RdKGToolAI.aiVars.inviteText = inviteString
		RdKGToolAI.SetAIInviteText(inviteString)
	end
end

function RdKGToolAI.ChatMessageReceived(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
	--d(fromName) d(fromDisplayName)
	if RdKGToolAI.state.enabled == true and ((RdKGToolAI.aiVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea()) or RdKGToolAI.aiVars.pvpOnly == false) then
		if eventCode == EVENT_CHAT_MESSAGE_CHANNEL and string.lower(text) == string.lower(RdKGToolAI.aiVars.inviteText) then
			local bodyColor = RdKGToolChat.GetBodyColorHex()
			local warningColor = RdKGToolChat.GetWarningColorHex()
			local playerColor = RdKGToolChat.GetPlayerColorHex()
			if RdKGToolAI.IsChatAllowed(channelType) and GetGroupSize() < RdKGToolAI.aiVars.maxGroupSize and RdKGToolAI.ValidRestrictions(fromDisplayName) == true then
				if RdKGToolAI.IsAllowedToInvite() then
					if GetGroupSize() < 12 then
						RdKGToolChat.SendChatMessage(string.format(RdKGToolAI.constants.AI_SENT_INVITE_TO, playerColor, RdKGToolGroup.GetNameLinkFromDisplayCharName(fromName, fromDisplayName), bodyColor), RdKGToolAI.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_NORMAL, RdKGToolAI.aiVars.sendChatMessages)
						GroupInviteByName(fromDisplayName)
					else
						RdKGToolChat.SendChatMessage(RdKGToolAI.constants.AI_FULL_GROUP, RdKGToolAI.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_NORMAL, RdKGToolAI.aiVars.sendChatMessages)
					end
				else
					RdKGToolChat.SendChatMessage(string.format(RdKGToolAI.constants.AI_NOT_LEADER_SEND_TO, playerColor, RdKGToolGroup.GetNameLinkFromDisplayCharName(fromName, fromDisplayName), warningColor), RdKGToolAI.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING, RdKGToolAI.aiVars.sendChatMessages)
				end
			else
				RdKGToolChat.SendChatMessage(string.format(RdKGToolAI.constants.AI_REQUIREMENTS_NOT_MET, playerColor, RdKGToolGroup.GetNameLinkFromDisplayCharName(fromName, fromDisplayName), warningColor), RdKGToolAI.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING, RdKGToolAI.aiVars.sendChatMessages)
			end
		end
	end
end

function RdKGToolAI.OnLeaderUpdated(eventCode, leaderTag)
	if eventCode == EVENT_LEADER_UPDATE then
		RdKGToolAI.state.isLeader = false
		for i = 1, GetGroupSize() do
			local unitTag = GetGroupUnitTagByIndex(i)
			if GetUnitName("player") == GetUnitName(GetGroupUnitTagByIndex(i)) or GetDisplayName() == GetUnitName(GetGroupUnitTagByIndex(i)) then
				RdKGToolAI.state.isLeader = IsUnitGroupLeader(GetGroupUnitTagByIndex(i))
				break
			end
		end
	end
end

function RdKGToolAI.OnMemberJoined(eventCode, memberName)
	if eventCode == EVENT_GROUP_MEMBER_JOINED then
		RdKGToolAI.state.isLeader = false
		for i = 1, GetGroupSize() do
			local unitTag = GetGroupUnitTagByIndex(i)
			if GetUnitName("player") == GetUnitName(GetGroupUnitTagByIndex(i)) or GetDisplayName() == GetUnitName(GetGroupUnitTagByIndex(i)) then
				RdKGToolAI.state.isLeader = IsUnitGroupLeader(GetGroupUnitTagByIndex(i))
				break
			end
		end
	end
end

function RdKGToolAI.CheckForKick()
	if RdKGToolAI.aiVars.autokick == true then
		local now = GetTimeStamp()
		for i = 1, #RdKGToolAI.state.offliner do
			local offliner = RdKGToolAI.state.offliner[i]
			if offliner == nil then
				table.remove(RdKGToolAI.state.offliner, i)
				i = i - 1
			elseif GetDiffBetweenTimeStamps(now, offliner.timeStamp) >= RdKGToolAI.aiVars.autokickTime then
				local unitTag = RdKGToolUtil.GetUnitTagFromGroupMemberName(offliner.name)
				if unitTag ~= nil then
					local bodyColor = RdKGToolChat.GetBodyColorHex()
					RdKGToolChat.SendChatMessage(string.format(RdKGToolAI.constants.AI_AUTO_KICK_MESSAGE, bodyColor, RdKGToolGroup.GetNameLinkFromDisplayCharName(offliner.name, offliner.displayName), bodyColor), RdKGToolAI.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_NORMAL, RdKGToolAI.aiVars.sendChatMessages)
					GroupKick(unitTag)
					table.remove(RdKGToolAI.state.offliner, i)
					i = i - 1
				else
					table.remove(RdKGToolAI.state.offliner, i)
					i = i - 1
				end

			end
		end
	end

end

function RdKGToolAI.OnMemberConnectedStatus(eventCode, unitTag, isOnline)
	if eventCode == EVENT_GROUP_MEMBER_CONNECTED_STATUS then
		local name = GetUnitName(unitTag)
		local displayName = GetUnitDisplayName(unitTag)
		if isOnline == false then
			local identified = false
			
			for i = 1, #RdKGToolAI.state.offliner do
				if RdKGToolAI.state.offliner[i].name == name then
					identified = true
					break
				end
			end
			
			if identified == false then
				local character = {}
				character.name = name
				character.displayName = displayName
				character.timeStamp = GetTimeStamp()
				table.insert(RdKGToolAI.state.offliner, character)
			end
		else
			for i = 1, #RdKGToolAI.state.offliner do
				if RdKGToolAI.state.offliner[i].name == name then
					table.remove(RdKGToolAI.state.offliner, i)
					break
				end
			end
		end
		
	end
end

function RdKGToolAI.OnKeyBinding()
	RdKGToolAI.state.enabled = not RdKGToolAI.state.enabled
	if RdKGToolAI.state.enabled == false then
		RdKGToolChat.SendChatMessage(RdKGToolAI.constants.AI_ENABLED_FALSE, RdKGToolAI.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_NORMAL, RdKGToolAI.aiVars.sendChatMessages)
	else
		RdKGToolChat.SendChatMessage(RdKGToolAI.constants.AI_ENABLED_TRUE, RdKGToolAI.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_NORMAL, RdKGToolAI.aiVars.sendChatMessages)
	end
	RdKGToolAI.state.enabled = RdKGToolAI.state.enabled
	RdKGToolAI.groupFragement.bodyControl.enabledCheckbox:SetChecked(RdKGToolAI.state.enabled)
	RdKGToolAI.SetAICheckedState(RdKGToolAI.state.enabled)
	RdKGToolAI.SetKickCheck()
end

function RdKGToolAI.OnMemberLeft(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
	if eventCode == EVENT_GROUP_MEMBER_LEFT then
		if reason ~= GROUP_LEAVE_REASON_KICKED and (RdKGToolAI.aiVars.alwaysShowLeave == true or (RdKGToolAI.aiVars.alwaysShowLeave == false and RdKGToolAI.state.enabled == true)) then
			if string.sub(memberDisplayName, 1, 1) == "@" then
				local bodyColor = RdKGToolChat.GetBodyColorHex()
				local playerColor = RdKGToolChat.GetPlayerColorHex()
				RdKGToolChat.SendChatMessage(string.format(RdKGToolAI.constants.AI_MEMBER_LEFT, playerColor, RdKGToolGroup.GetNameLinkFromDisplayCharName(memberCharacterName, memberDisplayName), bodyColor), RdKGToolAI.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_NORMAL, RdKGToolAI.aiVars.sendChatMessages)
			end
		end
		
	end
end

function RdKGToolAI.OnPlayerActivated(eventCode, initial)
	RdKGToolAI.OnLeaderUpdated(EVENT_LEADER_UPDATE, nil)
end

--menu interaction
function RdKGToolAI.GetMenu()
	local menu = {
	[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.AI_HEADER,
			--width = "full",
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.AI_ENABLED,
					getFunc = RdKGToolAI.GetAIEnabled,
					setFunc = RdKGToolAI.SetAIEnabled,
					reference = RdKGToolAI.constants.references.AI_ENABLED_CHECKBOX
				},
				[2] = {
					type = "editbox",
					name = RdKGToolMenu.constants.AI_INVITE_TEXT,
					getFunc = RdKGToolAI.GetInviteText,
					setFunc = RdKGToolAI.SetInviteText,
					isMultiline = false,
					width = "full",
					default = "",
					reference = RdKGToolAI.constants.references.AI_INVITE_TEXTBOX
				},
				[3] = {
					type = "slider",
					name = RdKGToolMenu.constants.AI_GROUP_SIZE,
					min = 2,
					max = 24,
					step = 1,
					getFunc = RdKGToolAI.GetMaxGroupSize,
					setFunc = RdKGToolAI.SetMaxGroupSize,
					width = "full",
					default = 24
				},
				[4] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.AI_PVP_CHECK,
					getFunc = RdKGToolAI.GetAIPvpOnly,
					setFunc = RdKGToolAI.SetAIPvpOnly
				},
				[5] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.AI_SEND_CHAT_MESSAGES,
					getFunc = RdKGToolAI.GetAISendChatMessages,
					setFunc = RdKGToolAI.SetAISendChatMessages
				},
				[6] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.AI_SHOW_MEMBER_LEFT,
					getFunc = RdKGToolAI.GetAIShowMemberLeft,
					setFunc = RdKGToolAI.SetAIShowMemberLeft
				},
				[7] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.AI_AUTO_KICK,
					getFunc = RdKGToolAI.GetAutoKickEnabled,
					setFunc = RdKGToolAI.SetAutoKickEnabled
				},
				[8] = {
					type = "slider",
					name = RdKGToolMenu.constants.AI_AUTO_KICK_TIME,
					min = 1,
					max = 600,
					step = 1,
					getFunc = RdKGToolAI.GetAutoKickEnabledTime,
					setFunc = RdKGToolAI.SetAutoKickEnabledTime,
					width = "full",
					default = 30
				},
				[9] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.AI_CHAT,
					width = "full"
				},
				[10] = {
					type = "checkbox",
					name = RdKGToolUtil.constants.G1,
					getFunc = function() return RdKGToolAI.GetAIChatEnabled("G1") end,
					setFunc = function(value) RdKGToolAI.SetAIChatEnabled("G1", value) end
				},
				[11] = {
					type = "checkbox",
					name = RdKGToolUtil.constants.O1,
					getFunc = function() return RdKGToolAI.GetAIChatEnabled("O1") end,
					setFunc = function(value) RdKGToolAI.SetAIChatEnabled("O1", value) end
				},
				[12] = {
					type = "checkbox",
					name = RdKGToolUtil.constants.G2,
					getFunc = function() return RdKGToolAI.GetAIChatEnabled("G2") end,
					setFunc = function(value) RdKGToolAI.SetAIChatEnabled("G2", value) end
				},
				[13] = {
					type = "checkbox",
					name = RdKGToolUtil.constants.O2,
					getFunc = function() return RdKGToolAI.GetAIChatEnabled("O2") end,
					setFunc = function(value) RdKGToolAI.SetAIChatEnabled("O2", value) end
				},
				[14] = {
					type = "checkbox",
					name = RdKGToolUtil.constants.G3,
					getFunc = function() return RdKGToolAI.GetAIChatEnabled("G3") end,
					setFunc = function(value) RdKGToolAI.SetAIChatEnabled("G3", value) end
				},
				[15] = {
					type = "checkbox",
					name = RdKGToolUtil.constants.O3,
					getFunc = function() return RdKGToolAI.GetAIChatEnabled("O3") end,
					setFunc = function(value) RdKGToolAI.SetAIChatEnabled("O3", value) end
				},
				[16] = {
					type = "checkbox",
					name = RdKGToolUtil.constants.G4,
					getFunc = function() return RdKGToolAI.GetAIChatEnabled("G4") end,
					setFunc = function(value) RdKGToolAI.SetAIChatEnabled("G4", value) end
				},
				[17] = {
					type = "checkbox",
					name = RdKGToolUtil.constants.O4,
					getFunc = function() return RdKGToolAI.GetAIChatEnabled("O4") end,
					setFunc = function(value) RdKGToolAI.SetAIChatEnabled("O4", value) end
				},
				[18] = {
					type = "checkbox",
					name = RdKGToolUtil.constants.G5,
					getFunc = function() return RdKGToolAI.GetAIChatEnabled("G5") end,
					setFunc = function(value) RdKGToolAI.SetAIChatEnabled("G5", value) end
				},
				[19] = {
					type = "checkbox",
					name = RdKGToolUtil.constants.O5,
					getFunc = function() return RdKGToolAI.GetAIChatEnabled("O5") end,
					setFunc = function(value) RdKGToolAI.SetAIChatEnabled("O5", value) end
				},
				[20] = {
					type = "checkbox",
					name = RdKGToolUtil.constants.EMOTE,
					getFunc = function() return RdKGToolAI.GetAIChatEnabled("EMOTE") end,
					setFunc = function(value) RdKGToolAI.SetAIChatEnabled("EMOTE", value) end
				},
				[21] = {
					type = "checkbox",
					name = RdKGToolUtil.constants.SAY,
					getFunc = function() return RdKGToolAI.GetAIChatEnabled("SAY") end,
					setFunc = function(value) RdKGToolAI.SetAIChatEnabled("SAY", value) end
				},
				[22] = {
					type = "checkbox",
					name = RdKGToolUtil.constants.YELL,
					getFunc = function() return RdKGToolAI.GetAIChatEnabled("YELL") end,
					setFunc = function(value) RdKGToolAI.SetAIChatEnabled("YELL", value) end
				},
				[23] = {
					type = "checkbox",
					name = RdKGToolUtil.constants.TELL,
					getFunc = function() return RdKGToolAI.GetAIChatEnabled("TELL") end,
					setFunc = function(value) RdKGToolAI.SetAIChatEnabled("TELL", value) end
				},
				[24] = {
					type = "checkbox",
					name = RdKGToolUtil.constants.ZONE,
					getFunc = function() return RdKGToolAI.GetAIChatEnabled("ZONE") end,
					setFunc = function(value) RdKGToolAI.SetAIChatEnabled("ZONE", value) end
				},
				[25] = {
					type = "checkbox",
					name = RdKGToolUtil.constants.ENZONE,
					getFunc = function() return RdKGToolAI.GetAIChatEnabled("ENZONE") end,
					setFunc = function(value) RdKGToolAI.SetAIChatEnabled("ENZONE", value) end
				},
				[26] = {
					type = "checkbox",
					name = RdKGToolUtil.constants.FRZONE,
					getFunc = function() return RdKGToolAI.GetAIChatEnabled("FRZONE") end,
					setFunc = function(value) RdKGToolAI.SetAIChatEnabled("FRZONE", value) end
				},
				[27] = {
					type = "checkbox",
					name = RdKGToolUtil.constants.DEZONE,
					getFunc = function() return RdKGToolAI.GetAIChatEnabled("DEZONE") end,
					setFunc = function(value) RdKGToolAI.SetAIChatEnabled("DEZONE", value) end
				},
				[28] = {
					type = "checkbox",
					name = RdKGToolUtil.constants.JPZONE,
					getFunc = function() return RdKGToolAI.GetAIChatEnabled("JPZONE") end,
					setFunc = function(value) RdKGToolAI.SetAIChatEnabled("JPZONE", value) end
				},
				[29] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.AI_CHAT_RESTRICTIONS,
					choices = RdKGToolAI.GetAvailableAIRestrictions(),
					getFunc = RdKGToolAI.GetSelectedAIRestriction,
					setFunc = RdKGToolAI.SetSelectedAIRestriction,
					width = "full"
				}
			}
		},
	}
	return menu
end

function RdKGToolAI.GetAIEnabled()
	return RdKGToolAI.state.enabled
end

function RdKGToolAI.SetAIEnabled(value)
	RdKGToolAI.state.enabled = value
	RdKGToolAI.groupFragement.bodyControl.enabledCheckbox:SetChecked(value)
	RdKGToolAI.SetKickCheck()
end

function RdKGToolAI.GetInviteText()
	return RdKGToolAI.aiVars.inviteText
end

function RdKGToolAI.SetInviteText(value)
	RdKGToolAI.aiVars.inviteText = value
	RdKGToolAI.groupFragement.bodyControl.inviteControl.editbox:SetText(value)
end

function RdKGToolAI.GetMaxGroupSize()
	return RdKGToolAI.aiVars.maxGroupSize
end

function RdKGToolAI.SetMaxGroupSize(value)
	RdKGToolAI.aiVars.maxGroupSize = value
end

function RdKGToolAI.GetAIPvpOnly()
	return RdKGToolAI.aiVars.pvpOnly
end

function RdKGToolAI.SetAIPvpOnly(value)
	RdKGToolAI.aiVars.pvpOnly = value
end

function RdKGToolAI.GetAISendChatMessages()
	return RdKGToolAI.aiVars.sendChatMessages
end

function RdKGToolAI.SetAISendChatMessages(value)
	RdKGToolAI.aiVars.sendChatMessages = value
end

function RdKGToolAI.GetAIShowMemberLeft()
	return RdKGToolAI.aiVars.alwaysShowLeave
end

function RdKGToolAI.SetAIShowMemberLeft(value)
	RdKGToolAI.aiVars.alwaysShowLeave = value
end

function RdKGToolAI.GetAutoKickEnabled()
	return RdKGToolAI.aiVars.autokick
end

function RdKGToolAI.SetAutoKickEnabled(value)
	RdKGToolAI.aiVars.autokick = value
	RdKGToolAI.SetKickCheck()
end

function RdKGToolAI.GetAutoKickEnabledTime()
	return RdKGToolAI.aiVars.autokickTime
end

function RdKGToolAI.SetAutoKickEnabledTime(value)
	RdKGToolAI.aiVars.autokickTime = value
end

function RdKGToolAI.GetAIChatEnabled(channel)
	return RdKGToolAI.aiVars.channels[channel]
end

function RdKGToolAI.SetAIChatEnabled(channel, value)
	RdKGToolAI.aiVars.channels[channel] = value
end

function RdKGToolAI.GetAvailableAIRestrictions()
	return {
		RdKGToolAI.constants.RESTRICTIONS[RdKGToolAI.constants.RESTRICTIONS_NONE],
		RdKGToolAI.constants.RESTRICTIONS[RdKGToolAI.constants.RESTRICTIONS_GUILD],
		RdKGToolAI.constants.RESTRICTIONS[RdKGToolAI.constants.RESTRICTIONS_GUILD_FRIEND],
		RdKGToolAI.constants.RESTRICTIONS[RdKGToolAI.constants.RESTRICTIONS_FRIEND],
		RdKGToolAI.constants.RESTRICTIONS[RdKGToolAI.constants.RESTRICTIONS_SPECIFIC_GUILD],
		RdKGToolAI.constants.RESTRICTIONS[RdKGToolAI.constants.RESTRICTIONS_SPECIFIC_GUILD_FRIEND]
	}
end

function RdKGToolAI.GetSelectedAIRestriction()
	return RdKGToolAI.constants.RESTRICTIONS[RdKGToolAI.aiVars.restrictions]
end

function RdKGToolAI.SetSelectedAIRestriction(value)
	if value ~= nil then
		for i = 1, #RdKGToolAI.constants.RESTRICTIONS do
			if RdKGToolAI.constants.RESTRICTIONS[i] == value then
				RdKGToolAI.aiVars.restrictions = i
				break
			end
		end
	end
end

--Auto Invite Callback
function RdKGToolAI.SetAICheckedState(state)
	local control = GetWindowManager():GetControlByName(RdKGToolAI.constants.references.AI_ENABLED_CHECKBOX)
	if control ~= nil then
		--d("changing state")
		control.value = state
		control:UpdateValue(false, state)
	end
end

function RdKGToolAI.SetAIInviteText(text)
	local control = GetWindowManager():GetControlByName(RdKGToolAI.constants.references.AI_INVITE_TEXTBOX)
	if control ~= nil then
		--d("changing state")
		control.value = text
		control:UpdateValue()
	end
end

--UI
function RdKGToolAI.OnCheckChanged(control, state)
	RdKGToolAI.state.enabled = state
	RdKGToolAI.SetAICheckedState(state)
	RdKGToolAI.SetKickCheck()
end
