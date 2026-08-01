-- RdK Group Tool Cyrodiil Log
-- By @s0rdrak (PC / EU)

RdKGTool.toolbox = RdKGTool.toolbox or {}
local RdKGToolTB = RdKGTool.toolbox
RdKGToolTB.cl = RdKGToolTB.cl or {}
local RdKGToolCL = RdKGToolTB.cl
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.cyrodiil = RdKGToolUtil.cyrodiil or {}
local RdKGToolCyro = RdKGToolUtil.cyrodiil
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGToolUtil.allianceColor = RdKGToolUtil.allianceColor or {}
local RdKGToolAC = RdKGToolUtil.allianceColor
RdKGToolUtil.math = RdKGToolUtil.math or {}
local RdKGToolMath = RdKGToolUtil.math
RdKGToolUtil.chatSystem = RdKGToolUtil.chatSystem or {}
local RdKGToolChat = RdKGToolUtil.chatSystem
RdKGToolUtil.group = RdKGToolUtil.group
local RdKGToolGroup = RdKGToolUtil.group

RdKGToolCL.callbackName = RdKGTool.addonName .. "CyrodiilLog"

RdKGToolCL.config = {}

RdKGToolCL.constants = RdKGToolCL.constants or {}
RdKGToolCL.constants.PREFIX = "CL"

RdKGToolCL.state = {}
RdKGToolCL.state.initialized = false
RdKGToolCL.state.registredConsumers = false
RdKGToolCL.state.registredCyrodiilConsumers = false
RdKGToolCL.state.language = ""
RdKGToolCL.state.flipMessagePrevention = {}

function RdKGToolCL.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolCL.callbackName, RdKGToolCL.OnProfileChanged)
	RdKGToolCL.state.language = GetCVar("Language.2")
	RdKGToolCL.state.initialized = true
	RdKGToolCL.SetEnabled(RdKGToolCL.clVars.enabled)
end

function RdKGToolCL.GetDefaults()
	local defaults = {}
	defaults.enabled = false
	defaults.guildClaimEnalbled = false
	defaults.guildLostEnabled = false
	defaults.statusUAEnabled = false
	defaults.statusUALostEnabled = false
	defaults.keepAllianceChangedEnabled = false
	defaults.tickDefense = true
	defaults.tickOffense = true
	defaults.scrollsEnabled = true
	defaults.emperorEnabled = true
	defaults.questEnabled = true
	defaults.battlegroundEnabled = true
	defaults.daedricArtifactEnabled = true
	return defaults
end

function RdKGToolCL.SetEnabled(value)
	if RdKGToolCL.state.initialized == true and value ~= nil then
		RdKGToolCL.clVars.enabled = value
		if value == true then
			if RdKGToolCL.state.registredConsumers == false then
				EVENT_MANAGER:RegisterForEvent(RdKGToolCL.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolCL.OnPlayerActivated)
			end
			RdKGToolCL.state.registredConsumers = true
		else
			if RdKGToolCL.state.registredConsumers == true then
				EVENT_MANAGER:UnregisterForEvent(RdKGToolCL.callbackName, EVENT_PLAYER_ACTIVATED)
			end
			RdKGToolCL.state.registredConsumers = false
		end
		RdKGToolCL.OnPlayerActivated()
	end
end

function RdKGToolCL.Print(message)
	if message ~= nil then
		--d(message)
		--message = string.format("|c%s%s|r", RdKGToolChat.GetBodyColorHex(), message)
		RdKGToolChat.SendChatMessage(message, RdKGToolCL.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_NORMAL)
	end
end

--callbacks
function RdKGToolCL.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolCL.clVars = currentProfile.toolbox.cl
		RdKGToolCL.SetEnabled(RdKGToolCL.clVars.enabled)
	end
end

function RdKGToolCL.OnPlayerActivated(eventCode, initial)
	if RdKGToolCL.clVars.enabled == true and RdKGToolUtil.IsInCyrodiil() == true then
		if RdKGToolCL.state.registredCyrodiilConsumers == false then
			RdKGToolCyro.AddConsumer(RdKGToolCL.callbackName, nil, RdKGToolCL.HandleMessage)
			RdKGToolCL.state.registredCyrodiilConsumers = true
		end
	else
		if RdKGToolCL.state.registredCyrodiilConsumers == true then
			RdKGToolCyro.RemoveConsumer(RdKGToolCL.callbackName)
			RdKGToolCL.state.registredCyrodiilConsumers = false
		end
	end
end

function RdKGToolCL.HandleMessage(eventData)
	--d(eventData)
	local bodyColor = RdKGToolChat.GetBodyColorHex()
	if eventData.event == RdKGToolCyro.constants.events.GUILD_CLAIM and RdKGToolCL.clVars.guildClaimEnalbled == true then
		RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_KEEP_GUILD_CLAIM, RdKGToolAC.DyeAllianceString(eventData.playerName, eventData.alliance), bodyColor,  RdKGToolAC.DyeAllianceString(eventData.keepName, eventData.alliance), bodyColor,  RdKGToolAC.DyeAllianceString(eventData.guildName, eventData.alliance)))
	elseif eventData.event == RdKGToolCyro.constants.events.GUILD_LOST and RdKGToolCL.clVars.guildLostEnabled == true then
		RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_KEEP_GUILD_LOST, RdKGToolAC.DyeAllianceString(eventData.guildName, eventData.previousOwningAlliance), bodyColor, RdKGToolAC.DyeAllianceString(eventData.keepName, eventData.previousOwningAlliance)))
	elseif eventData.event == RdKGToolCyro.constants.events.STATUS_UA and RdKGToolCL.clVars.statusUAEnabled == true then
		RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_KEEP_STATUS_UA, RdKGToolAC.DyeAllianceString(eventData.keepName, eventData.alliance), bodyColor))
	elseif eventData.event == RdKGToolCyro.constants.events.STATUS_UA_LOST and RdKGToolCL.clVars.statusUALostEnabled == true then
		if RdKGToolCL.state.flipMessagePrevention[eventData.keepId] == nil or RdKGToolCL.state.flipMessagePrevention[eventData.keepId] + 1000 < GetGameTimeMilliseconds() then
			RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_KEEP_STATUS_UA_LOST, RdKGToolAC.DyeAllianceString(eventData.keepName, eventData.alliance), bodyColor))
		end
	elseif eventData.event == RdKGToolCyro.constants.events.KEEP_OWNER_CHANGED and RdKGToolCL.clVars.keepAllianceChangedEnabled == true then
		local alliance = GetAllianceName(eventData.alliance)
		RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_KEEP_OWNER_CHANGED, RdKGToolAC.DyeAllianceString(eventData.keepName, eventData.alliance), bodyColor, RdKGToolAC.DyeAllianceString(alliance, eventData.alliance)))
		RdKGToolCL.state.flipMessagePrevention[eventData.keepId] = GetGameTimeMilliseconds()
	elseif eventData.event == RdKGToolCyro.constants.events.TICK_DEFENSE and RdKGToolCL.clVars.tickDefense == true then
		RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_TICK_DEFENSE, bodyColor, eventData.apGained, bodyColor, RdKGToolAC.DyeAllianceString(eventData.keepName, eventData.alliance)))
	elseif eventData.event == RdKGToolCyro.constants.events.TICK_OFFENSE and RdKGToolCL.clVars.tickOffense == true then
		RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_TICK_OFFENSE, bodyColor, eventData.apGained, bodyColor, RdKGToolAC.DyeAllianceString(eventData.keepName, eventData.alliance)))
	elseif eventData.event == RdKGToolCyro.constants.events.SCROLL_PICKED_UP and RdKGToolCL.clVars.scrollsEnabled == true then
		local name = RdKGToolGroup.GetNameFromDisplayCharName(eventData.charName, eventData.displayName)
		if RdKGToolCL.state.language == "de" then
			RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_SCROLL_PICKED_UP, RdKGToolAC.DyeAllianceString(name, eventData.playerAlliance), bodyColor, RdKGToolAC.DyeAllianceString(eventData.scroll, eventData.scrollAlliance), bodyColor))
		else
			RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_SCROLL_PICKED_UP, RdKGToolAC.DyeAllianceString(name, eventData.playerAlliance), bodyColor, RdKGToolAC.DyeAllianceString(eventData.scroll, eventData.scrollAlliance)))
		end
	elseif eventData.event == RdKGToolCyro.constants.events.SCROLL_DROPPED and RdKGToolCL.clVars.scrollsEnabled == true then
		local name = RdKGToolGroup.GetNameFromDisplayCharName(eventData.charName, eventData.displayName)
		if RdKGToolCL.state.language == "de" then
			RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_SCROLL_DROPPED, RdKGToolAC.DyeAllianceString(name, eventData.playerAlliance), bodyColor, RdKGToolAC.DyeAllianceString(eventData.scroll, eventData.scrollAlliance), bodyColor))
		else
			RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_SCROLL_DROPPED, RdKGToolAC.DyeAllianceString(name, eventData.playerAlliance), bodyColor, RdKGToolAC.DyeAllianceString(eventData.scroll, eventData.scrollAlliance)))
		end
	elseif eventData.event == RdKGToolCyro.constants.events.SCROLL_RETURNED and RdKGToolCL.clVars.scrollsEnabled == true then
		local name = RdKGToolGroup.GetNameFromDisplayCharName(eventData.charName, eventData.displayName)
		if RdKGToolCL.state.language == "de" then
			RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_SCROLL_RETURNED, RdKGToolAC.DyeAllianceString(name, eventData.playerAlliance), bodyColor, RdKGToolAC.DyeAllianceString(eventData.scroll, eventData.scrollAlliance), bodyColor))
		else
			RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_SCROLL_RETURNED, RdKGToolAC.DyeAllianceString(name, eventData.playerAlliance), bodyColor, RdKGToolAC.DyeAllianceString(eventData.scroll, eventData.scrollAlliance)))
		end
	elseif eventData.event == RdKGToolCyro.constants.events.SCROLL_RETURNED_BY_TIMER and RdKGToolCL.clVars.scrollsEnabled == true then
		local name = RdKGToolGroup.GetNameFromDisplayCharName(eventData.charName, eventData.displayName)
		RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_SCROLL_RETURNED_BY_TIMER, RdKGToolAC.DyeAllianceString(eventData.scroll, eventData.scrollAlliance), bodyColor))
	elseif eventData.event == RdKGToolCyro.constants.events.SCROLL_CAPTURED and RdKGToolCL.clVars.scrollsEnabled == true then
		local name = RdKGToolGroup.GetNameFromDisplayCharName(eventData.charName, eventData.displayName)
		if RdKGToolCL.state.language == "de" then
			RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_SCROLL_CAPTURED, RdKGToolAC.DyeAllianceString(name, eventData.playerAlliance), bodyColor, RdKGToolAC.DyeAllianceString(eventData.scroll, eventData.scrollAlliance), bodyColor, RdKGToolAC.DyeAllianceString(eventData.keepName, eventData.playerAlliance), bodyColor))
		else
			RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_SCROLL_CAPTURED, RdKGToolAC.DyeAllianceString(name, eventData.playerAlliance), bodyColor, RdKGToolAC.DyeAllianceString(eventData.scroll, eventData.scrollAlliance), bodyColor, RdKGToolAC.DyeAllianceString(eventData.keepName, eventData.playerAlliance)))
		end
	elseif eventData.event == RdKGToolCyro.constants.events.EMPEROR_CORONATED and RdKGToolCL.clVars.emperorEnabled == true then
		local name = RdKGToolGroup.GetNameFromDisplayCharName(eventData.charName, eventData.displayName)
		RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_EMPEROR_CORONATED, RdKGToolAC.DyeAllianceString(name, eventData.alliance), bodyColor))
	elseif eventData.event == RdKGToolCyro.constants.events.EMPEROR_DEPOSED and RdKGToolCL.clVars.emperorEnabled == true then
		local name = RdKGToolGroup.GetNameFromDisplayCharName(eventData.charName, eventData.displayName)
		RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_EMPEROR_DEPOSED, RdKGToolAC.DyeAllianceString(name, eventData.alliance), bodyColor))
	elseif eventData.event == RdKGToolCyro.constants.events.QUEST_REWARD and RdKGToolCL.clVars.questEnabled == true then
		RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_QUEST_REWARD, bodyColor, eventData.apGained, bodyColor))
	elseif eventData.event == RdKGToolCyro.constants.events.BATTLEGROUND_REWARD and RdKGToolCL.clVars.battlegroundEnabled == true then
		RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_BATTLEGROUND_REWARD, bodyColor, eventData.apGained, bodyColor))
	elseif eventData.event == RdKGToolCyro.constants.events.BATTLEGROUND_MEDAL_REWARD and RdKGToolCL.clVars.battlegroundEnabled == true then
		RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_BATTLEGROUND_MEDAL_REWARD, bodyColor, eventData.apGained, bodyColor))
	elseif eventData.event == RdKGToolCyro.constants.events.DAEDRIC_ARTIFACT_SPAWNED and RdKGToolCL.clVars.daedricArtifactEnabled == true then
		RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_DAEDRIC_ARTIFACT_SPAWNED, bodyColor, eventData.objectiveName))
	elseif eventData.event == RdKGToolCyro.constants.events.DAEDRIC_ARTIFACT_REVEALED and RdKGToolCL.clVars.daedricArtifactEnabled == true then
			RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_DAEDRIC_ARTIFACT_REVEALED, bodyColor, eventData.objectiveName))
	elseif eventData.event == RdKGToolCyro.constants.events.DAEDRIC_ARTIFACT_DROPPED and RdKGToolCL.clVars.daedricArtifactEnabled == true then
		RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_DAEDRIC_ARTIFACT_DROPPED, bodyColor, eventData.objectiveName, RdKGToolAC.DyeAllianceString(GetAllianceName(eventData.alliance), eventData.alliance), bodyColor))
	elseif eventData.event == RdKGToolCyro.constants.events.DAEDRIC_ARTIFACT_TAKEN and RdKGToolCL.clVars.daedricArtifactEnabled == true then
		RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_DAEDRIC_ARTIFACT_TAKEN, bodyColor, eventData.objectiveName, RdKGToolAC.DyeAllianceString(GetAllianceName(eventData.alliance), eventData.alliance), bodyColor))
	elseif eventData.event == RdKGToolCyro.constants.events.DAEDRIC_ARTIFACT_DESPAWNED and RdKGToolCL.clVars.daedricArtifactEnabled == true then
		RdKGToolCL.Print(string.format(RdKGToolCL.constants.MESSAGE_DAEDRIC_ARTIFACT_DESPAWNED, bodyColor, eventData.objectiveName))
	end
end

--menu interaction
function RdKGToolCL.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.CL_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CL_ENABLED,
					getFunc = RdKGToolCL.GetClEnabled,
					setFunc = RdKGToolCL.SetClEnabled
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CL_GUILD_CLAIM_ENABLED,
					getFunc = RdKGToolCL.GetClGuildClaimEnabled,
					setFunc = RdKGToolCL.SetClGuildClaimEnabled
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CL_GUILD_LOST_ENABLED,
					getFunc = RdKGToolCL.GetClGuildLostEnabled,
					setFunc = RdKGToolCL.SetClGuildLostEnabled
				},
				[4] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CL_UA_ENABLED,
					getFunc = RdKGToolCL.GetClStatusUAEnabled,
					setFunc = RdKGToolCL.SetClStatusUAEnabled
				},
				[5] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CL_UA_LOST_ENABLED,
					getFunc = RdKGToolCL.GetClStatusUALostEnabled,
					setFunc = RdKGToolCL.SetClStatusUALostEnabled
				},
				[6] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CL_KEEP_ALLIANCE_CHANGED_ENABLED,
					getFunc = RdKGToolCL.GetClKeepAllianceChangedEnabled,
					setFunc = RdKGToolCL.SetClKeepAllianceChangedEnabled
				},
				[7] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CL_TICK_DEFENSE,
					getFunc = RdKGToolCL.GetClTickDefenseEnabled,
					setFunc = RdKGToolCL.SetClTickDefenseEnabled
				},
				[8] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CL_TICK_OFFENSE,
					getFunc = RdKGToolCL.GetClTickOffenseEnabled,
					setFunc = RdKGToolCL.SetClTickOffenseEnabled
				},
				[9] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CL_SCROLL_NOTIFICATIONS,
					getFunc = RdKGToolCL.GetClScrollsEnabled,
					setFunc = RdKGToolCL.SetClScrollsEnabled
				},
				[10] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CL_EMPEROR_ENABLED,
					getFunc = RdKGToolCL.GetClEmperorEnabled,
					setFunc = RdKGToolCL.SetClEmperorEnabled
				},
				[11] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CL_QUEST_ENABLED,
					getFunc = RdKGToolCL.GetClQuestEnabled,
					setFunc = RdKGToolCL.SetClQuestEnabled
				},
				[12] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CL_BATTLEGROUND_ENABLED,
					getFunc = RdKGToolCL.GetClBattlegroundEnabled,
					setFunc = RdKGToolCL.SetClBattlegroundEnabled
				},
				[13] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CL_DAEDRIC_ARTIFACT_ENABLED,
					getFunc = RdKGToolCL.GetClDaedricArtifactEnabled,
					setFunc = RdKGToolCL.SetClDaedricArtifactEnabled
				},
			}
		}
	}
	return menu
end

function RdKGToolCL.GetClEnabled()
	return RdKGToolCL.clVars.enabled
end

function RdKGToolCL.SetClEnabled(value)
	RdKGToolCL.SetEnabled(value)
end

function RdKGToolCL.GetClGuildClaimEnabled()
	return RdKGToolCL.clVars.guildClaimEnalbled
end

function RdKGToolCL.SetClGuildClaimEnabled(value)
	RdKGToolCL.clVars.guildClaimEnalbled = value
end

function RdKGToolCL.GetClGuildLostEnabled()
	return RdKGToolCL.clVars.guildLostEnabled
end

function RdKGToolCL.SetClGuildLostEnabled(value)
	RdKGToolCL.clVars.guildLostEnabled = value
end

function RdKGToolCL.GetClStatusUAEnabled()
	return RdKGToolCL.clVars.statusUAEnabled
end

function RdKGToolCL.SetClStatusUAEnabled(value)
	RdKGToolCL.clVars.statusUAEnabled = value
end

function RdKGToolCL.GetClStatusUALostEnabled()
	return RdKGToolCL.clVars.statusUALostEnabled
end

function RdKGToolCL.SetClStatusUALostEnabled(value)
	RdKGToolCL.clVars.statusUALostEnabled = value
end

function RdKGToolCL.GetClKeepAllianceChangedEnabled()
	return RdKGToolCL.clVars.keepAllianceChangedEnabled
end

function RdKGToolCL.SetClKeepAllianceChangedEnabled(value)
	RdKGToolCL.clVars.keepAllianceChangedEnabled = value
end

function RdKGToolCL.GetClTickDefenseEnabled()
	return RdKGToolCL.clVars.tickDefense
end

function RdKGToolCL.SetClTickDefenseEnabled(value)
	RdKGToolCL.clVars.tickDefense = value
end

function RdKGToolCL.GetClTickOffenseEnabled()
	return RdKGToolCL.clVars.tickOffense
end

function RdKGToolCL.SetClTickOffenseEnabled(value)
	RdKGToolCL.clVars.tickOffense = value
end

function RdKGToolCL.GetClScrollsEnabled()
	return RdKGToolCL.clVars.scrollsEnabled
end

function RdKGToolCL.SetClScrollsEnabled(value)
	RdKGToolCL.clVars.scrollsEnabled = value
end

function RdKGToolCL.GetClEmperorEnabled()
	return RdKGToolCL.clVars.emperorEnabled
end

function RdKGToolCL.SetClEmperorEnabled(value)
	RdKGToolCL.clVars.emperorEnabled = value
end

function RdKGToolCL.GetClQuestEnabled()
	return RdKGToolCL.clVars.questEnabled
end

function RdKGToolCL.SetClQuestEnabled(value)
	RdKGToolCL.clVars.questEnabled = value
end

function RdKGToolCL.GetClBattlegroundEnabled()
	return RdKGToolCL.clVars.battlegroundEnabled
end

function RdKGToolCL.SetClBattlegroundEnabled(value)
	RdKGToolCL.clVars.battlegroundEnabled = value
end

function RdKGToolCL.GetClDaedricArtifactEnabled()
	return RdKGToolCL.clVars.daedricArtifactEnabled
end

function RdKGToolCL.SetClDaedricArtifactEnabled(value)
	RdKGToolCL.clVars.daedricArtifactEnabled = value
end