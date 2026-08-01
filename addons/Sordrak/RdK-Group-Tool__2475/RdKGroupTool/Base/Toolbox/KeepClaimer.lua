-- RdK Group Tool Keep Claimer
-- By @s0rdrak (PC / EU)

RdKGTool.toolbox.kc = RdKGTool.toolbox.kc or {}
local RdKGToolKc = RdKGTool.toolbox.kc
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
local RdKGToolRoster = RdKGToolUtil.roster

RdKGToolKc.constants = RdKGToolKc.constants or {}

RdKGToolKc.callbackName = RdKGTool.addonName .. "KeepClaimer"

RdKGToolKc.config = {}
RdKGToolKc.config.updateInterval = 5

RdKGToolKc.state = {}
RdKGToolKc.state.initialized = false
RdKGToolKc.state.registeredConsumer = false


function RdKGToolKc.Initialize()
	if RdKGToolRoster.IsRdKMember(GetUnitDisplayName("player")) == true then
		RdKGTool.profile.AddProfileChangeListener(RdKGToolKc.callbackName, RdKGToolKc.OnProfileChanged)
		
		RdKGToolKc.state.initialized = true
		RdKGToolKc.SetEnabled(RdKGToolKc.kcVars.enabled)
	end
end

function RdKGToolKc.GetDefaults()
	local defaults = {}
	defaults.enabled = true
	defaults.claimKeep = true
	defaults.claimOutpost = false
	defaults.claimResource = false
	defaults.guilds = {}
	defaults.guilds[1] = "Retter des Kaiserreiches"
	defaults.guilds[2] = "The Inglorious Smurfs"
	defaults.guilds[3] = "-"
	defaults.guilds[4] = "-"
	defaults.guilds[5] = "-"
	return defaults
end

function RdKGToolKc.SetEnabled(value)
	if RdKGToolKc.state.initialized == true and value ~= nil then
		RdKGToolKc.kcVars.enabled = value
		if value == true then
			if RdKGToolKc.state.registeredConsumer == false then
				EVENT_MANAGER:RegisterForEvent(RdKGToolKc.callbackName, EVENT_START_KEEP_GUILD_CLAIM_INTERACTION, RdKGToolKc.OnStartKeepGuildClaimInteraction)
				--EVENT_MANAGER:RegisterForEvent(RdKGToolKc.callbackName, EVENT_END_KEEP_GUILD_CLAIM_INTERACTION, RdKGToolKc.OnEndKeepGuildClaimInteraction)
				RdKGToolKc.state.registeredConsumer = true
			end
		else
			if RdKGToolKc.state.registeredConsumer == true then
				EVENT_MANAGER:UnregisterForEvent(RdKGToolKc.callbackName, EVENT_START_KEEP_GUILD_CLAIM_INTERACTION)
				--EVENT_MANAGER:UnregisterForEvent(RdKGToolKc.callbackName, EVENT_END_KEEP_GUILD_CLAIM_INTERACTION)
				RdKGToolKc.state.registeredConsumer = false
			end
		end
	end
end

--internal functions
function RdKGToolKc.GetNextClaimingGuildIndex()
	local retVal = nil
	for i = 1, #RdKGToolKc.kcVars.guilds do
		if RdKGToolKc.kcVars.guilds[i] ~= nil and RdKGToolKc.kcVars.guilds[i] ~= "" and RdKGToolKc.kcVars.guilds[i] ~= "-" then
			local guildId = RdKGToolRoster.GetGuildIdForName(RdKGToolKc.kcVars.guilds[i])
			if guildId ~= nil then
				if DoesGuildHaveClaimedKeep(GetGuildId(guildId)) == false then
					retVal = guildId
					break
				end
			else
				RdKGToolKc.kcVars.guilds[i] = ""
			end			
		end
	end
	return retVal
end

--callbacks
function RdKGToolKc.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolKc.kcVars = currentProfile.toolbox.kc
		RdKGToolKc.SetEnabled(RdKGToolKc.kcVars.enabled)
	end
end

--[[
function RdKGToolKc.OnEndKeepGuildClaimInteraction(event)
	if event == EVENT_END_KEEP_GUILD_CLAIM_INTERACTION then
		--d("dialog left")
	end
end
]]

function RdKGToolKc.OnUpdate()
	local guildId = RdKGToolKc.GetNextClaimingGuildIndex()
	if guildId ~= nil and GetGuildClaimInteractionKeepId() ~= 0 and GetGuildId(guildId) ~= nil and GetGuildId(guildId) ~= 0 then
		
		local secondsToClaim = GetSecondsUntilKeepClaimAvailable(GetGuildClaimInteractionKeepId(), BGQUERY_LOCAL)
		if secondsToClaim == 0 then
			ClaimInteractionKeepForGuild(GetGuildId(guildId))
			EVENT_MANAGER:UnregisterForEvent(RdKGToolKc.callbackName)
		end
	else
		EVENT_MANAGER:UnregisterForEvent(RdKGToolKc.callbackName)
	end
end

function RdKGToolKc.OnStartKeepGuildClaimInteraction(event)
	if event == EVENT_START_KEEP_GUILD_CLAIM_INTERACTION then
		--d("event fired")
		local keepType = GetKeepType(GetGuildClaimInteractionKeepId())
		if (keepType == KEEPTYPE_KEEP and RdKGToolKc.kcVars.claimKeep == true) or (keepType == KEEPTYPE_OUTPOST and RdKGToolKc.kcVars.claimOutpost == true) or (keepType == KEEPTYPE_RESOURCE and RdKGToolKc.kcVars.claimResource == true) then
			--d("claim claim claim:P")
			EVENT_MANAGER:RegisterForUpdate(RdKGToolKc.callbackName, RdKGToolKc.config.updateInterval, RdKGToolKc.OnUpdate)
		end
		--GetGuildClaimedKeep(number guildLuaId) : number claimedKeepId, number claimedKeepCampaignId
		--DoesGuildHaveClaimedKeep(number guildLuaId) : boolean hasClaimedKeep
		--ClaimInteractionKeepForGuild(number guildLuaId) 
		--GetKeepType(number keepId) : number keepType 
		--GetNumKeeps()
		--GetKeepName(number keepId) : string keepName
		--GetResourceKeepForKeep(number parentKeepId, number KeepResourceType resourceType)  : number keepId
		--GetKeepResourceType(number keepId) : number KeepResourceType resourceType
		--GetSecondsUntilKeepClaimAvailable(number keepId, number BattlegroundQueryContextType battlegroundContext) : number secondsUntilAvailable
		--GetGuildClaimInteractionKeepId() : number keepId
		--GetInteractionKeepId() : number keepId
		--IsKeepTypeClaimable(number KeepType keepType) : boolean isClaimable
		
		-- KeepType
		----KEEPTYPE_ARTIFACT_GATE
		----KEEPTYPE_ARTIFACT_KEEP
		----KEEPTYPE_BORDER_KEEP
		----KEEPTYPE_IMPERIAL_CITY_DISTRICT
		----KEEPTYPE_KEEP
		----KEEPTYPE_OUTPOST
		----KEEPTYPE_RESOURCE
		----KEEPTYPE_TOWN 
		--KeepResourceType
		----RESOURCETYPE_FOOD
		----RESOURCETYPE_NONE
		----RESOURCETYPE_ORE
		----RESOURCETYPE_WOOD 
		--BattlegroundQueryContextType
		----BGQUERY_ASSIGNED_AND_LOCAL
		----BGQUERY_ASSIGNED_CAMPAIGN
		----BGQUERY_LOCAL
		----BGQUERY_UNKNOWN 
	end
end

--menu interaction
function RdKGToolKc.GetMenu()
	if RdKGToolRoster.IsRdKMember(GetUnitDisplayName("player")) == true then
		local menu = {
			[1] = {
				type = "submenu",
				name = RdKGToolMenu.constants.KC_HEADER,
				controls = {
					[1] = {
						type = "checkbox",
						name = RdKGToolMenu.constants.KC_ENABLED,
						getFunc = RdKGToolKc.GetKcEnabled,
						setFunc = RdKGToolKc.SetKcEnabled
					},
					[2] = {
						type = "checkbox",
						name = RdKGToolMenu.constants.KC_CLAIM_KEEPS,
						getFunc = RdKGToolKc.GetKcClaimKeeps,
						setFunc = RdKGToolKc.SetKcClaimKeeps
					},
					[3] = {
						type = "checkbox",
						name = RdKGToolMenu.constants.KC_CLAIM_OUTPOSTS,
						getFunc = RdKGToolKc.GetKcClaimOutposts,
						setFunc = RdKGToolKc.SetKcClaimOutposts
					},
					[4] = {
						type = "checkbox",
						name = RdKGToolMenu.constants.KC_CLAIM_RESOURCES,
						getFunc = RdKGToolKc.GetKcClaimResources,
						setFunc = RdKGToolKc.SetKcClaimResources
					},
					[5] = {
						type = "dropdown",
						name = RdKGToolMenu.constants.KC_GUILD_1,
						choices = RdKGToolKc.GetKcGuilds(),
						getFunc = function() return RdKGToolKc.GetKcGuild(1) end,
						setFunc = function(value) RdKGToolKc.SetKcGuild(1, value) end
					},
					[6] = {
						type = "dropdown",
						name = RdKGToolMenu.constants.KC_GUILD_2,
						choices = RdKGToolKc.GetKcGuilds(),
						getFunc = function() return RdKGToolKc.GetKcGuild(2) end,
						setFunc = function(value) RdKGToolKc.SetKcGuild(2, value) end
					},
					[7] = {
						type = "dropdown",
						name = RdKGToolMenu.constants.KC_GUILD_3,
						choices = RdKGToolKc.GetKcGuilds(),
						getFunc = function() return RdKGToolKc.GetKcGuild(3) end,
						setFunc = function(value) RdKGToolKc.SetKcGuild(3, value) end
					},
					[8] = {
						type = "dropdown",
						name = RdKGToolMenu.constants.KC_GUILD_4,
						choices = RdKGToolKc.GetKcGuilds(),
						getFunc = function() return RdKGToolKc.GetKcGuild(4) end,
						setFunc = function(value) RdKGToolKc.SetKcGuild(4, value) end
					},
					[9] = {
						type = "dropdown",
						name = RdKGToolMenu.constants.KC_GUILD_5,
						choices = RdKGToolKc.GetKcGuilds(),
						getFunc = function() return RdKGToolKc.GetKcGuild(5) end,
						setFunc = function(value) RdKGToolKc.SetKcGuild(5, value) end
					},
				}
			}
		}
		return menu
	else
		return nil
	end
end


function RdKGToolKc.GetKcEnabled()
	return RdKGToolKc.kcVars.enabled
end

function RdKGToolKc.SetKcEnabled(value)
	RdKGToolKc.SetEnabled(value)
end

function RdKGToolKc.GetKcClaimKeeps()
	return RdKGToolKc.kcVars.claimKeep
end

function RdKGToolKc.SetKcClaimKeeps(value)
	RdKGToolKc.kcVars.claimKeep = value
end

function RdKGToolKc.GetKcClaimOutposts()
	return RdKGToolKc.kcVars.claimOutpost
end

function RdKGToolKc.SetKcClaimOutposts(value)
	RdKGToolKc.kcVars.claimOutpost = value
end

function RdKGToolKc.GetKcClaimResources()
	return RdKGToolKc.kcVars.claimResource
end

function RdKGToolKc.SetKcClaimResources(value)
	RdKGToolKc.kcVars.claimResource = value
end

function RdKGToolKc.GetKcGuilds()
	local guilds = {}
	for i = 1, GetNumGuilds() do
		table.insert(guilds, GetGuildName(GetGuildId(i)))
	end
	table.insert(guilds, "-")
	return guilds
end

function RdKGToolKc.GetKcGuild(index)
	local retVal = "-"
	if RdKGToolKc.kcVars.guilds[index] ~= nil and RdKGToolKc.kcVars.guilds[index] ~= "" and RdKGToolKc.kcVars.guilds[index] ~= "-" then
		local tempName = RdKGToolRoster.GetGuildIdForName(RdKGToolKc.kcVars.guilds[index])
		if tempName ~= nil then
			retVal = RdKGToolKc.kcVars.guilds[index]
		else
			RdKGToolKc.kcVars.guilds[index] = "-"
		end
	else
		RdKGToolKc.kcVars.guilds[index] = "-"
	end
	return retVal
end

function RdKGToolKc.SetKcGuild(index, value)
	if index ~= nil and value ~= nil and index > 0 and index < 6 then
		RdKGToolKc.kcVars.guilds[index] = value
	end
end