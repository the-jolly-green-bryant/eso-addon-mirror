-- RdK Group Tool Cyrodiil
-- By @s0rdrak (PC / EU)

RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.cyrodiil = RdKGToolUtil.cyrodiil or {}
local RdKGToolCyro = RdKGToolUtil.cyrodiil
RdKGToolUtil.chatSystem = RdKGToolUtil.chatSystem or {}
local RdKGToolChat = RdKGToolUtil.chatSystem


RdKGToolCyro.callbackName = RdKGTool.addonName .. "UtilCyro"


RdKGToolCyro.config = {}
RdKGToolCyro.config.updateInterval = 1000
RdKGToolCyro.config.siegeTimeout = 30000
RdKGToolCyro.config.previousOwnerThreshold = 5000

RdKGToolCyro.state = {}
RdKGToolCyro.state.registredConsumers = false
RdKGToolCyro.state.initializedItems = false
RdKGToolCyro.state.campaignId = 0
RdKGToolCyro.state.consumers = {}

RdKGToolCyro.state.resources = {}
RdKGToolCyro.state.keeps = {}
RdKGToolCyro.state.outposts = {}
RdKGToolCyro.state.villages = {}
RdKGToolCyro.state.destructibles = {}
RdKGToolCyro.state.temples = {}
RdKGToolCyro.state.scrolls = {}

RdKGToolCyro.constants = {}
RdKGToolCyro.constants.resourceType = {}
RdKGToolCyro.constants.resourceType.FARM = 1
RdKGToolCyro.constants.resourceType.MINE = 2
RdKGToolCyro.constants.resourceType.LUMBER = 3
RdKGToolCyro.constants.events = {}
RdKGToolCyro.constants.events.GUILD_CLAIM = 1
RdKGToolCyro.constants.events.GUILD_LOST = 2
RdKGToolCyro.constants.events.STATUS_UA = 3
RdKGToolCyro.constants.events.STATUS_UA_LOST = 4
RdKGToolCyro.constants.events.KEEP_OWNER_CHANGED = 5
RdKGToolCyro.constants.events.TICK_DEFENSE = 6
RdKGToolCyro.constants.events.TICK_OFFENSE = 7
RdKGToolCyro.constants.events.SCROLL_PICKED_UP = 8
RdKGToolCyro.constants.events.SCROLL_DROPPED = 9
RdKGToolCyro.constants.events.SCROLL_RETURNED = 10
RdKGToolCyro.constants.events.SCROLL_RETURNED_BY_TIMER = 11
RdKGToolCyro.constants.events.SCROLL_CAPTURED = 12
RdKGToolCyro.constants.events.EMPEROR_CORONATED = 13
RdKGToolCyro.constants.events.EMPEROR_DEPOSED = 14
RdKGToolCyro.constants.events.QUEST_REWARD = 15
RdKGToolCyro.constants.events.BATTLEGROUND_REWARD = 16
RdKGToolCyro.constants.events.BATTLEGROUND_MEDAL_REWARD = 16
RdKGToolCyro.constants.events.DAEDRIC_ARTIFACT_SPAWNED = 17
RdKGToolCyro.constants.events.DAEDRIC_ARTIFACT_REVEALED = 18
RdKGToolCyro.constants.events.DAEDRIC_ARTIFACT_DROPPED = 19
RdKGToolCyro.constants.events.DAEDRIC_ARTIFACT_TAKEN = 20
RdKGToolCyro.constants.events.DAEDRIC_ARTIFACT_DESPAWNED = 21
RdKGToolCyro.constants.flipTimes = {}
RdKGToolCyro.constants.flipTimes.KEEP = 20000
RdKGToolCyro.constants.flipTimes.OUTPOST = 20000
RdKGToolCyro.constants.flipTimes.RESOURCE = 20000
RdKGToolCyro.constants.PREFIX = "Cyro"

function RdKGToolCyro.Initialize()
	EVENT_MANAGER:RegisterForEvent(RdKGToolCyro.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolCyro.OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(RdKGToolCyro.callbackName, EVENT_ALLIANCE_POINT_UPDATE, RdKGToolCyro.OnApUpdate)
end

function RdKGToolCyro.AddConsumer(name, updateCallback, messageCallback)
	if name ~= nil then
		local entryFound = false
		for i = 1, #RdKGToolCyro.state.consumers do
			if RdKGToolCyro.state.consumers.name == name then
				entryFound = true
				break
			end
		end
		if entryFound == false then
			local entry = {}
			entry.name = name
			entry.updateCallback = updateCallback
			entry.messageCallback = messageCallback
			table.insert(RdKGToolCyro.state.consumers, entry)
			RdKGToolCyro.OnPlayerActivated()
		end
	end
end

function RdKGToolCyro.RemoveConsumer(name)
	if name ~= nil then
		for i = 1, #RdKGToolCyro.state.consumers do
			if RdKGToolCyro.state.consumers[i].name == name then
				table.remove(RdKGToolCyro.state.consumers, i)
				break
			end
		end
	end
end

function RdKGToolCyro.NotifyUpdateConsumers(itemsOfInterest)
	if RdKGToolCyro.state.consumers ~= nil then
		for i = 1, #RdKGToolCyro.state.consumers do
			if type(RdKGToolCyro.state.consumers[i].updateCallback) == "function" then
				RdKGToolCyro.state.consumers[i].updateCallback(itemsOfInterest)
			end
		end
	end
end

function RdKGToolCyro.NotifyMessageConsumers(eventData)
	if RdKGToolCyro.state.consumers ~= nil then
		for i = 1, #RdKGToolCyro.state.consumers do
			if RdKGToolCyro.state.consumers[i].messageCallback ~= nil and type(RdKGToolCyro.state.consumers[i].messageCallback) == "function" then
				RdKGToolCyro.state.consumers[i].messageCallback(eventData)
			end
		end
	end
end

function RdKGToolCyro.AdjustResourceName(name)
	name = name:gsub("%^.d$", ""):gsub("Castle ",""):gsub("[fF]ort ",""):gsub("Keep ",""):gsub("Feste ",""):gsub("Kastell ",""):gsub("Kastells ",""):gsub("Burg ",""):gsub("der ", ""):gsub("die ", ""):gsub("das ", ""):gsub("des ", ""):gsub("lager", ""):gsub("Bauernhof", "Farm"):gsub("mill",""):gsub("la bastille ", ""):gsub("de la ", " "):gsub(" de "," "):gsub(" du ", " "):gsub(" la ", " "):gsub(" le ", " "):gsub(" les ", " "):gsub("la ferme", "ferme"):gsub("la scierie", "scierie"):gsub("la mine", "mine"):gsub("le château", ""):gsub(" château ", " "):gsub(" bastille ", " ")
	return name
end

function RdKGToolCyro.AdjustKeepName(name)
	name = name:gsub(",..$", ""):gsub("%^.d$", ""):gsub("Castle ",""):gsub("le fort ", ""):gsub("[fF]ort ",""):gsub("Keep ",""):gsub("Keep",""):gsub("Feste ",""):gsub("Kastell ",""):gsub("Burg ",""):gsub("avant.poste d[eu] ", ""):gsub("bastille d[eu]s? ", ""):gsub("fort de la ", ""):gsub("der ", ""):gsub("das ", ""):gsub("die ", ""):gsub("la bastille ", ""):gsub("de la ", " "):gsub(" de "," "):gsub(" du ", " "):gsub(" la ", " "):gsub(" le ", " "):gsub(" les ", " "):gsub("le château", ""):gsub(" château ", " "):gsub(" bastille ", " "):gsub("de la", " ")
	return name
end

function RdKGToolCyro.AdjustOutpostName(name)
	name = name:gsub("Outpost","")
	--name = name:gsub("Outpost",""):gsub("der ", ""):gsub("die ", ""):gsub("das ", "")
	return name
end

function RdKGToolCyro.AdjustTempleName(name)
	name = name:gsub("Scroll ","")
	return name
end

function RdKGToolCyro.InitResources(gameTime)
	local resources = { 22, 23, 24, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57,
						61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85 ,86, 87}
	RdKGToolCyro.state.resources = {}
	for i = 1, #resources do
		RdKGToolCyro.state.resources[resources[i]] = {}
		RdKGToolCyro.state.resources[resources[i]].id = resources[i]
		RdKGToolCyro.state.resources[resources[i]].keepType = GetKeepType(resources[i])
		RdKGToolCyro.state.resources[resources[i]].name = RdKGToolCyro.AdjustResourceName(zo_strformat("<<1>>", GetKeepName(resources[i])))
		RdKGToolCyro.state.resources[resources[i]].isUnderAttack = GetKeepUnderAttack(resources[i],  BGQUERY_LOCAL)
		if RdKGToolCyro.state.resources[resources[i]].isUnderAttack == true then
			RdKGToolCyro.state.resources[resources[i]].underAttackSince = gameTime
		else
			RdKGToolCyro.state.resources[resources[i]].underAttackSince = nil
		end
		RdKGToolCyro.state.resources[resources[i]].attackStatusLostAt = 0
		RdKGToolCyro.state.resources[resources[i]].underAttackFor = 0
		RdKGToolCyro.state.resources[resources[i]].siegeWeapons = {}
		RdKGToolCyro.state.resources[resources[i]].siegeWeapons.AD = GetNumSieges(resources[i], BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
		RdKGToolCyro.state.resources[resources[i]].siegeWeapons.DC = GetNumSieges(resources[i], BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
		RdKGToolCyro.state.resources[resources[i]].siegeWeapons.EP = GetNumSieges(resources[i], BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
		RdKGToolCyro.state.resources[resources[i]].owningAlliance = GetKeepAlliance(resources[i], BGQUERY_LOCAL)
		RdKGToolCyro.state.resources[resources[i]].previousOwningAlliance = GetKeepAlliance(resources[i], BGQUERY_LOCAL)
	end
end

function RdKGToolCyro.InitKeeps(gameTime)
--/script for i=3, 20 do d(GetKeepAlliance(i, BGQUERY_LOCAL) .. " - " .. GetKeepAlliance(i, BGQUERY_ASSIGNED_AND_LOCAL)) end
	RdKGToolCyro.state.keeps = {}
	for i = 3, 20 do
		RdKGToolCyro.state.keeps[i] = {}
		RdKGToolCyro.state.keeps[i].id = i
		RdKGToolCyro.state.keeps[i].keepType = GetKeepType(i)
		RdKGToolCyro.state.keeps[i].name = RdKGToolCyro.AdjustKeepName(zo_strformat("<<1>>", GetKeepName(i)))
		RdKGToolCyro.state.keeps[i].isUnderAttack = GetKeepUnderAttack(i,  BGQUERY_LOCAL)
		if RdKGToolCyro.state.keeps[i].isUnderAttack == true then
			RdKGToolCyro.state.keeps[i].underAttackSince = gameTime
		else
			RdKGToolCyro.state.keeps[i].underAttackSince = nil
		end
		RdKGToolCyro.state.keeps[i].attackStatusLostAt = 0
		RdKGToolCyro.state.keeps[i].underAttackFor = 0
		RdKGToolCyro.state.keeps[i].siegeWeapons = {}
		RdKGToolCyro.state.keeps[i].siegeWeapons.AD = GetNumSieges(i, BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
		RdKGToolCyro.state.keeps[i].siegeWeapons.DC = GetNumSieges(i, BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
		RdKGToolCyro.state.keeps[i].siegeWeapons.EP = GetNumSieges(i, BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
		RdKGToolCyro.state.keeps[i].resources = {}
		RdKGToolCyro.state.keeps[i].resources.farm = RdKGToolCyro.state.resources[GetResourceKeepForKeep(i, RESOURCETYPE_FOOD)]
		RdKGToolCyro.state.keeps[i].resources.farm.rType = RdKGToolCyro.constants.resourceType.FARM
		RdKGToolCyro.state.keeps[i].resources.lumber = RdKGToolCyro.state.resources[GetResourceKeepForKeep(i, RESOURCETYPE_WOOD)]
		RdKGToolCyro.state.keeps[i].resources.lumber.rType = RdKGToolCyro.constants.resourceType.LUMBER
		RdKGToolCyro.state.keeps[i].resources.mine = RdKGToolCyro.state.resources[GetResourceKeepForKeep(i, RESOURCETYPE_ORE)]
		RdKGToolCyro.state.keeps[i].resources.mine.rType = RdKGToolCyro.constants.resourceType.MINE
		RdKGToolCyro.state.keeps[i].owningAlliance = GetKeepAlliance(i, BGQUERY_LOCAL)
		RdKGToolCyro.state.keeps[i].previousOwningAlliance = GetKeepAlliance(i, BGQUERY_LOCAL)
		--local _, x, y = GetKeepPinInfo(i, BGQUERY_LOCAL)
		--RdKGToolCyro.state.keeps[i].x = x
		--RdKGToolCyro.state.keeps[i].y = y
	end
	
end

function RdKGToolCyro.InitOutposts(gameTime)
	local outposts = {132, 133, 134, 163, 164, 165}
	RdKGToolCyro.state.outposts = {}
	for i = 1, #outposts do
		RdKGToolCyro.state.outposts[outposts[i]] = {}
		RdKGToolCyro.state.outposts[outposts[i]].id = outposts[i]
		RdKGToolCyro.state.outposts[outposts[i]].keepType = GetKeepType(outposts[i])
		RdKGToolCyro.state.outposts[outposts[i]].name = zo_strformat("<<1>>", GetKeepName(outposts[i]))
		RdKGToolCyro.state.outposts[outposts[i]].isUnderAttack = GetKeepUnderAttack(outposts[i],  BGQUERY_LOCAL)
		if RdKGToolCyro.state.outposts[outposts[i]].isUnderAttack == true then
			RdKGToolCyro.state.outposts[outposts[i]].underAttackSince = gameTime
		else
			RdKGToolCyro.state.outposts[outposts[i]].underAttackSince = nil
		end
		RdKGToolCyro.state.outposts[outposts[i]].attackStatusLostAt = 0
		RdKGToolCyro.state.outposts[outposts[i]].underAttackFor = 0
		RdKGToolCyro.state.outposts[outposts[i]].siegeWeapons = {}
		RdKGToolCyro.state.outposts[outposts[i]].siegeWeapons.AD = GetNumSieges(outposts[i], BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
		RdKGToolCyro.state.outposts[outposts[i]].siegeWeapons.DC = GetNumSieges(outposts[i], BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
		RdKGToolCyro.state.outposts[outposts[i]].siegeWeapons.EP = GetNumSieges(outposts[i], BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
		RdKGToolCyro.state.outposts[outposts[i]].owningAlliance = GetKeepAlliance(outposts[i], BGQUERY_LOCAL)
		RdKGToolCyro.state.outposts[outposts[i]].previousOwningAlliance = GetKeepAlliance(outposts[i], BGQUERY_LOCAL)
	end
	
end

function RdKGToolCyro.InitVillages(gameTime)
	local villages = {149, 151, 152}
	RdKGToolCyro.state.villages = {}
	for i = 1, #villages do
		RdKGToolCyro.state.villages[villages[i]] = {}
		RdKGToolCyro.state.villages[villages[i]].id = villages[i]
		RdKGToolCyro.state.villages[villages[i]].keepType = GetKeepType(villages[i])
		RdKGToolCyro.state.villages[villages[i]].name = zo_strformat("<<1>>", GetKeepName(villages[i]))
		RdKGToolCyro.state.villages[villages[i]].isUnderAttack = GetKeepUnderAttack(villages[i],  BGQUERY_LOCAL)
		if RdKGToolCyro.state.villages[villages[i]].isUnderAttack == true then
			RdKGToolCyro.state.villages[villages[i]].underAttackSince = gameTime
		else
			RdKGToolCyro.state.villages[villages[i]].underAttackSince = nil
		end
		RdKGToolCyro.state.villages[villages[i]].attackStatusLostAt = 0
		RdKGToolCyro.state.villages[villages[i]].underAttackFor = 0
		RdKGToolCyro.state.villages[villages[i]].siegeWeapons = {}
		RdKGToolCyro.state.villages[villages[i]].siegeWeapons.AD = GetNumSieges(villages[i], BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
		RdKGToolCyro.state.villages[villages[i]].siegeWeapons.DC = GetNumSieges(villages[i], BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
		RdKGToolCyro.state.villages[villages[i]].siegeWeapons.EP = GetNumSieges(villages[i], BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
		RdKGToolCyro.state.villages[villages[i]].owningAlliance = GetKeepAlliance(villages[i], BGQUERY_LOCAL)
		RdKGToolCyro.state.villages[villages[i]].previousOwningAlliance = GetKeepAlliance(villages[i], BGQUERY_LOCAL)
	end
end

function RdKGToolCyro.InitDestructibles(gameTime)
	RdKGToolCyro.state.destructibles = {}
	for i = 154, 162 do
		RdKGToolCyro.state.destructibles[i] = {}
		RdKGToolCyro.state.destructibles[i].id = i
		RdKGToolCyro.state.destructibles[i].keepType = GetKeepType(i)
		RdKGToolCyro.state.destructibles[i].name = RdKGToolCyro.AdjustResourceName(zo_strformat("<<1>>", GetKeepName(i)))
		RdKGToolCyro.state.destructibles[i].isUnderAttack = GetKeepUnderAttack(i,  BGQUERY_LOCAL)
		if RdKGToolCyro.state.destructibles[i].isUnderAttack == true then
			RdKGToolCyro.state.destructibles[i].underAttackSince = gameTime
		else
			RdKGToolCyro.state.destructibles[i].underAttackSince = nil
		end
		RdKGToolCyro.state.destructibles[i].attackStatusLostAt = 0
		RdKGToolCyro.state.destructibles[i].underAttackFor = 0
		RdKGToolCyro.state.destructibles[i].isPassable = IsKeepPassable(i, BGQUERY_LOCAL)
		RdKGToolCyro.state.destructibles[i].directionalAccess = GetKeepDirectionalAccess(i, BGQUERY)
	end
end

function RdKGToolCyro.InitTemples(gameTime)
	RdKGToolCyro.state.temples = {}
	for i = 118, 123 do
		RdKGToolCyro.state.temples[i] = {}
		RdKGToolCyro.state.temples[i].id = i
		RdKGToolCyro.state.temples[i].keepType = GetKeepType(i)
		RdKGToolCyro.state.temples[i].name = zo_strformat("<<1>>", RdKGToolCyro.AdjustTempleName(GetKeepName(i)))
		RdKGToolCyro.state.temples[i].isUnderAttack = GetKeepUnderAttack(i,  BGQUERY_LOCAL)
		if RdKGToolCyro.state.temples[i].isUnderAttack == true then
			RdKGToolCyro.state.temples[i].underAttackSince = gameTime
		else
			RdKGToolCyro.state.temples[i].underAttackSince = nil
		end
		RdKGToolCyro.state.temples[i].attackStatusLostAt = 0
		RdKGToolCyro.state.temples[i].underAttackFor = 0
		RdKGToolCyro.state.temples[i].siegeWeapons = {}
		RdKGToolCyro.state.temples[i].siegeWeapons.AD = GetNumSieges(i, BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
		RdKGToolCyro.state.temples[i].siegeWeapons.DC = GetNumSieges(i, BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
		RdKGToolCyro.state.temples[i].siegeWeapons.EP = GetNumSieges(i, BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
		RdKGToolCyro.state.temples[i].owningAlliance = GetKeepAlliance(i, BGQUERY_LOCAL)
	end
end

function RdKGToolCyro.AddObjectives()
	local numObjectives = GetNumObjectives()
	for i = 1, numObjectives do
		local keepId, objectiveId, bgqueryType = GetObjectiveIdsForIndex(i)
		if bgqueryType == BGQUERY_ASSIGNED_AND_LOCAL or bgqueryType == BGQUERY_LOCAL then
			if RdKGToolCyro.state.keeps[keepId] ~= nil then
				RdKGToolCyro.state.keeps[keepId].objectives = RdKGToolCyro.state.keeps[keepId].objectives or {}
				if RdKGToolCyro.state.keeps[keepId].objectives[1] == nil then
					RdKGToolCyro.state.keeps[keepId].objectives[1] = {}
					RdKGToolCyro.state.keeps[keepId].objectives[1].id = objectiveId
					RdKGToolCyro.state.keeps[keepId].objectives[1].state = 100
					RdKGToolCyro.state.keeps[keepId].objectives[1].holdingAlliance = RdKGToolCyro.state.keeps[keepId].owningAlliance
				elseif RdKGToolCyro.state.keeps[keepId].objectives[2] == nil then
					RdKGToolCyro.state.keeps[keepId].objectives[2] = {}
					RdKGToolCyro.state.keeps[keepId].objectives[2].id = objectiveId
					RdKGToolCyro.state.keeps[keepId].objectives[2].state = 100
					RdKGToolCyro.state.keeps[keepId].objectives[2].holdingAlliance = RdKGToolCyro.state.keeps[keepId].owningAlliance
				end
			elseif RdKGToolCyro.state.resources[keepId] ~= nil then
				RdKGToolCyro.state.resources[keepId].objectives = RdKGToolCyro.state.resources[keepId].objectives or {}
				RdKGToolCyro.state.resources[keepId].objectives[1] = {}
				RdKGToolCyro.state.resources[keepId].objectives[1].id = objectiveId
				RdKGToolCyro.state.resources[keepId].objectives[1].state = 100
				RdKGToolCyro.state.resources[keepId].objectives[1].holdingAlliance = RdKGToolCyro.state.resources[keepId].owningAlliance
			elseif RdKGToolCyro.state.outposts[keepId] ~= nil then
				RdKGToolCyro.state.outposts[keepId].objectives = RdKGToolCyro.state.outposts[keepId].objectives or {}
				if RdKGToolCyro.state.outposts[keepId].objectives[1] == nil then
					RdKGToolCyro.state.outposts[keepId].objectives[1] = {}
					RdKGToolCyro.state.outposts[keepId].objectives[1].id = objectiveId
					RdKGToolCyro.state.outposts[keepId].objectives[1].state = 100
					RdKGToolCyro.state.outposts[keepId].objectives[1].holdingAlliance = RdKGToolCyro.state.outposts[keepId].owningAlliance
				else
					RdKGToolCyro.state.outposts[keepId].objectives[2] = {}
					RdKGToolCyro.state.outposts[keepId].objectives[2].id = objectiveId
					RdKGToolCyro.state.outposts[keepId].objectives[2].state = 100
					RdKGToolCyro.state.outposts[keepId].objectives[2].holdingAlliance = RdKGToolCyro.state.outposts[keepId].owningAlliance
				end
			elseif RdKGToolCyro.state.villages[keepId] ~= nil then
				RdKGToolCyro.state.villages[keepId].objectives = RdKGToolCyro.state.villages[keepId].objectives or {}
				if RdKGToolCyro.state.villages[keepId].objectives[1] == nil then
					RdKGToolCyro.state.villages[keepId].objectives[1] = {}
					RdKGToolCyro.state.villages[keepId].objectives[1].id = objectiveId
					RdKGToolCyro.state.villages[keepId].objectives[1].state = 100
					RdKGToolCyro.state.villages[keepId].objectives[1].holdingAlliance = RdKGToolCyro.state.villages[keepId].owningAlliance
				elseif RdKGToolCyro.state.villages[keepId].objectives[2] == nil then
					RdKGToolCyro.state.villages[keepId].objectives[2] = {}
					RdKGToolCyro.state.villages[keepId].objectives[2].id = objectiveId
					RdKGToolCyro.state.villages[keepId].objectives[2].state = 100
					RdKGToolCyro.state.villages[keepId].objectives[2].holdingAlliance = RdKGToolCyro.state.villages[keepId].owningAlliance
				else
					RdKGToolCyro.state.villages[keepId].objectives[3] = {}
					RdKGToolCyro.state.villages[keepId].objectives[3].id = objectiveId
					RdKGToolCyro.state.villages[keepId].objectives[3].state = 100
					RdKGToolCyro.state.villages[keepId].objectives[3].holdingAlliance = RdKGToolCyro.state.villages[keepId].owningAlliance
				end
			end
		end
	end
end

function RdKGToolCyro.ResetObjective(keeps)
	for key, keep in pairs(keeps) do
		if keep.objectives ~= nil then
			for i = 1, #keep.objectives do
				keep.objectives[i].state = 100
				keep.objectives[i].holdingAlliance = keep.owningAlliance
			end
		end
	end
end

function RdKGToolCyro.ResetObjectives()
	RdKGToolCyro.ResetObjective(RdKGToolCyro.state.keeps)
	RdKGToolCyro.ResetObjective(RdKGToolCyro.state.outposts)
	RdKGToolCyro.ResetObjective(RdKGToolCyro.state.resources)
	RdKGToolCyro.ResetObjective(RdKGToolCyro.state.villages)
	--RdKGToolCyro.ResetObjective(RdKGToolCyro.state.destructibles)
	--RdKGToolCyro.ResetObjective(RdKGToolCyro.state.temples)
end

function RdKGToolCyro.GetResources()
	return RdKGToolCyro.state.resources
end

function RdKGToolCyro.GetKeeps()
	return RdKGToolCyro.state.keeps
end

function RdKGToolCyro.GetOutposts()
	return RdKGToolCyro.state.outposts
end

function RdKGToolCyro.GetVillages()
	return RdKGToolCyro.state.villages
end

function RdKGToolCyro.GetDestructibles()
	return RdKGToolCyro.state.destructibles
end

function RdKGToolCyro.GetTemples()
	return RdKGToolCyro.state.temples
end

function RdKGToolCyro.InitState()
	local gameTime = GetGameTimeMilliseconds()
	RdKGToolCyro.InitResources(gameTime)
	RdKGToolCyro.InitKeeps(gameTime)
	RdKGToolCyro.InitOutposts(gameTime)
	RdKGToolCyro.InitVillages(gameTime)
	RdKGToolCyro.InitDestructibles(gameTime)
	RdKGToolCyro.InitTemples(gameTime)
	RdKGToolCyro.AddObjectives()
	RdKGToolCyro.InitScrolls()
end

function RdKGToolCyro.InitScrolls()
	RdKGToolCyro.state.scrolls = {}
	for key, scrollKeep in pairs(RdKGToolCyro.state.temples) do
		local scroll = {}
		scroll.id = GetKeepArtifactObjectiveId(key)
		local name, _, _ = GetObjectiveInfo(key, scroll.id, BGQUERY_LOCAL)
		scroll.name = zo_strformat("<<1>>", name)
		scroll.alliance = GetKeepAlliance(key, BGQUERY_LOCAL)
		table.insert(RdKGToolCyro.state.scrolls, scroll)
	end
end

function RdKGToolCyro.GetItemsOfInterest()
	return RdKGToolCyro.state.itemsOfInterest
end

function RdKGToolCyro.UpdateItemsOfInterest(itemsOfInterest)
	RdKGToolCyro.state.itemsOfInterest = itemsOfInterest
	RdKGToolCyro.NotifyUpdateConsumers(itemsOfInterest)
end

function RdKGToolCyro.GetItemByKeepId(keepId)
	if keepId ~= nil then
		if RdKGToolCyro.state.resources[keepId] ~= nil then
			return RdKGToolCyro.state.resources[keepId]
		elseif RdKGToolCyro.state.keeps[keepId] ~= nil then
			return RdKGToolCyro.state.keeps[keepId]
		elseif RdKGToolCyro.state.outposts[keepId] ~= nil then
			return RdKGToolCyro.state.outposts[keepId]
		elseif RdKGToolCyro.state.villages[keepId] ~= nil then
			return RdKGToolCyro.state.villages[keepId]
		elseif RdKGToolCyro.state.temples[keepId] ~= nil then
			return RdKGToolCyro.state.temples[keepId]
		end
	end
	return nil
end

function RdKGToolCyro.UpdateItem(items, gameTime)
	local itemsOfInterest = {}
	for key, item in pairs(items) do
		local itemOfInterest = false
		local previousOwningAlliance = item.owningAlliance
		item.owningAlliance = GetKeepAlliance(key, BGQUERY_LOCAL)
		if item.previousOwningAllianceTimestamp == nil or item.previousOwningAllianceTimestamp + RdKGToolCyro.config.previousOwnerThreshold < gameTime then
			item.previousOwningAlliance = previousOwningAlliance
			item.previousOwningAllianceTimestamp = gameTime
		end
		local previousAttackState = item.isUnderAttack
		item.isUnderAttack = GetKeepUnderAttack(key,  BGQUERY_LOCAL)
		item.underAttackFor = 0
		item.isCoolingDown = true
		
		if item.owningAlliance ~= previousOwningAlliance and RdKGToolCyro.state.destructibles[key] == nil then
			itemOfInterest = true
			--d("keep switched")
			if item.interestingSince == nil then
				item.interestingSince = gameTime
			end
			item.underAttackFor = gameTime - item.interestingSince
			if item.objectives ~= nil then
				for i = 1, #item.objectives do
					item.objectives[i].state = 100
					item.objectives[i].holdingAlliance = item.owningAlliance
				end
			end
			item.flipsAt = nil
			local eventData = {}
			eventData.event = RdKGToolCyro.constants.events.KEEP_OWNER_CHANGED
			eventData.keepId = key
			eventData.keepName = zo_strformat("<<1>>", GetKeepName(key))
			eventData.alliance = item.owningAlliance
			eventData.previousOwningAlliance = previousOwningAlliance
			RdKGToolCyro.NotifyMessageConsumers(eventData)
		end
		if previousAttackState == false and item.isUnderAttack == true then
			--throw isUaMessage
			local eventData = {}
			eventData.event = RdKGToolCyro.constants.events.STATUS_UA
			eventData.keepId = key
			eventData.keepName = zo_strformat("<<1>>", GetKeepName(key))
			eventData.alliance = item.owningAlliance
			eventData.previousOwningAlliance = previousOwningAlliance
			RdKGToolCyro.NotifyMessageConsumers(eventData)
			if item.attackStatusLostAt ~= 0 and item.attackStatusLostAt + RdKGToolCyro.config.siegeTimeout < gameTime then
				item.underAttackSince = gameTime
			end
		elseif previousAttackState == true and item.isUnderAttack == false then
			--throw isUaLostMessage
			local eventData = {}
			eventData.event = RdKGToolCyro.constants.events.STATUS_UA_LOST
			eventData.keepId = key
			eventData.keepName = zo_strformat("<<1>>", GetKeepName(key))
			eventData.alliance = item.owningAlliance
			eventData.previousOwningAlliance = previousOwningAlliance
			RdKGToolCyro.NotifyMessageConsumers(eventData)
			item.attackStatusLostAt = gameTime
		end
		if item.isUnderAttack == true then
			itemOfInterest = true
			--d("is under attack")
			if item.interestingSince == nil then
				item.interestingSince = gameTime
			end
			item.underAttackFor = gameTime - item.interestingSince
			item.isCoolingDown = false
		else
			if item.attackStatusLostAt ~= 0 and item.attackStatusLostAt + RdKGToolCyro.config.siegeTimeout > gameTime then
				itemOfInterest = true
				--d("not under attack")
				if item.interestingSince == nil then
					item.interestingSince = gameTime
				end
				item.underAttackFor = gameTime - item.interestingSince
			end
		end
		if RdKGToolCyro.state.destructibles[key] == nil then
			item.siegeWeapons.AD = GetNumSieges(key, BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
			item.siegeWeapons.DC = GetNumSieges(key, BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
			item.siegeWeapons.EP = GetNumSieges(key, BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
		
			if item.siegeWeapons.AD > 0 or item.siegeWeapons.DC > 0 or item.siegeWeapons.EP > 0 then
				itemOfInterest = true
				item.isCoolingDown = false
				--d("siege weapons deployed")
				if item.interestingSince == nil then
					item.interestingSince = gameTime
				end
				item.underAttackFor = gameTime - item.interestingSince
				item.lastSiegeWeaponSeen = gameTime
			elseif item.lastSiegeWeaponSeen ~= nil and item.lastSiegeWeaponSeen + RdKGToolCyro.config.siegeTimeout > gameTime then
				itemOfInterest = true
				if item.interestingSince == nil then
					item.interestingSince = gameTime
				end
				item.underAttackFor = gameTime - item.interestingSince
			else
				item.lastSiegeWeaponSeen = nil
			end
		end
		
		if item.keepType == KEEPTYPE_BRIDGE or item.keepType == KEEPTYPE_MILEGATE then
			item.isPassable = IsKeepPassable(key, BGQUERY_LOCAL)
			item.directionalAccess = GetKeepDirectionalAccess(key, BGQUERY)
		end
		if itemOfInterest == true then
			--d(key)
			table.insert(itemsOfInterest, item)
		else
			item.interestingSince = nil
		end
	end
	return itemsOfInterest
end

function RdKGToolCyro.AdjustItemsOfInterest(oldItems, newItems)
	if newItems ~= nil then
		for i = 1, #newItems do
			table.insert(oldItems, newItems[i])
		end
	end
	return oldItems
end

function RdKGToolCyro.SortItemsOfInterest(itemA, itemB)
	--d(itemA)
	--d(itemB)
	--d("----")
	if itemA == nil or itemB == nil or itemA.interestingSince == nil or itemB.interestingSince == nil then
		return true
	end
	if itemA.interestingSince > itemB.interestingSince then
		return false
	elseif itemA.interestingSince < itemB.interestingSince then
		return true
	else
		if itemA.name ~= nil and itemB.name ~= nil and itemA.name > itemB.name then
			return false
		elseif itemA.name ~= nil and itemB.name ~= nil and itemA.name < itemB.name then
			return true
		else
			--something is odd, there seems to be a subtle bug or table.sort is doing strange things
			--d("wtf")
			--d(#RdKGToolCyro.state.itemsOfInterest)
			--d(itemA)
			--d(itemB)
			return false
		end
	end
	return false
end

function RdKGToolCyro.GetFlagStatePercent(state, owningAlliance, holdingAlliance)
	local percent = 99
	if state == OBJECTIVE_CONTROL_STATE_AREA_ABOVE_CONTROL_THRESHOLD then
		if holdingAlliance == owningAlliance then
			percent = 90
		else
			percent = 51
		end
	elseif state == OBJECTIVE_CONTROL_STATE_AREA_NO_CONTROL then
		if holdingAlliance == 0 then
			percent = 0
		else
			percent = 10
		end
	elseif state == OBJECTIVE_CONTROL_STATE_AREA_MAX_CONTROL then
		percent = 100
	elseif state == OBJECTIVE_CONTROL_STATE_AREA_BELOW_CONTROL_THRESHOLD then
		if holdingAlliance == owningAlliance then
			percent = 40
		else
			percent = 10
		end
	end
	return percent
end

function RdKGToolCyro.GetFlipConstant(keepType)
	if keepType == KEEPTYPE_KEEP then
		return RdKGToolCyro.constants.flipTimes.KEEP
	elseif keepType == KEEPTYPE_OUTPOST then
		return RdKGToolCyro.constants.flipTimes.OUTPOST
	elseif keepType == KEEPTYPE_RESOURCE then
		return RdKGToolCyro.constants.flipTimes.RESOURCE
	else
		return 0
	end
end

function RdKGToolCyro.FlagsAtFlipState(objectives, owningAlliance)
	local flips = false
	if objectives ~= nil then
		local flipedFlags = 0
		--d("----------------------")
		--d("objective states: ")
		for i = 1, #objectives do
			--d("id: " .. objectives[i].id)
			--d("state: " .. objectives[i].state)
			if objectives[i].holdingAlliance ~= owningAlliance and objectives[i].state > 50 then
				flipedFlags = flipedFlags + 1
			else
				break
			end
		end
		if flipedFlags == #objectives then
			if #objectives == 1 then
				flips = true
			elseif #objectives == 2 and objectives[1].holdingAlliance == objectives[2].holdingAlliance then
				flips = true
			elseif #objectives == 3 and objectives[1].holdingAlliance == objectives[2].holdingAlliance and objectives[1].holdingAlliance == objectives[3].holdingAlliance then
				flips = true
			end
		end
	end
	return flips
end

function RdKGToolCyro.AdjustKeepFlipping(keep)
	local flipTime = RdKGToolCyro.GetFlipConstant(keep.keepType)
	if flipTime > 0 then
		if keep.flipsAt == nil and RdKGToolCyro.FlagsAtFlipState(keep.objectives, keep.owningAlliance) == true then
			keep.flipsAt = GetGameTimeMilliseconds() + flipTime
		elseif keep.flipsAt ~= nil and RdKGToolCyro.FlagsAtFlipState(keep.objectives, keep.owningAlliance) == true then
			--all good
		else
			keep.flipsAt = nil
		end
	end
end

function RdKGToolCyro.GetScrollAlliance(artifactName)
	local alliance = 0
	for i = 1, #RdKGToolCyro.state.scrolls do
		if RdKGToolCyro.state.scrolls[i].name == artifactName then
			alliance = RdKGToolCyro.state.scrolls[i].alliance
			break
		end
	end
	return alliance
end

function RdKGToolCyro.AdjustCoordinates(keeps)
	if keeps ~= nil then
		for key, keep in pairs(keeps) do
			local _, x, y = GetKeepPinInfo(key, BGQUERY_LOCAL)
			keep.x = x
			keep.y = y
		end
	end
end

function RdKGToolCyro.AdjustKeepCoordinates()
	RdKGToolCyro.AdjustCoordinates(RdKGToolCyro.state.keeps)
end

function RdKGToolCyro.AdjustOutpostCoordinates()
	RdKGToolCyro.AdjustCoordinates(RdKGToolCyro.state.outposts)
end

function RdKGToolCyro.AdjustVillageCoordinates()
	RdKGToolCyro.AdjustCoordinates(RdKGToolCyro.state.villages)
end

function RdKGToolCyro.TempDebugPrint(name, value)
	if value ~= nil and (type(value) == "number" or type(value) == "string") then
		RdKGToolChat.SendChatMessage(name .. ": " .. value, RdKGToolCyro.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
	elseif value ~= nil and type(value) == "boolean" then
		if value == true then
			RdKGToolChat.SendChatMessage(name .. ": true", RdKGToolCyro.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
		else
			RdKGToolChat.SendChatMessage(name .. ": false", RdKGToolCyro.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
		end
	end
end

--callbacks
function RdKGToolCyro.OnPlayerActivated()
	if RdKGToolUtil.IsInCyrodiil() == true then
		if RdKGToolCyro.state.initializedItems == false then
			RdKGToolCyro.InitState()
			RdKGToolCyro.state.initializedItems = true
		end
		if RdKGToolCyro.state.registredConsumers == false and #RdKGToolCyro.state.consumers > 0 then
			
			RdKGToolCyro.state.registredConsumers = true
			RdKGToolCyro.state.campaignId = GetCurrentCampaignId()
			EVENT_MANAGER:RegisterForEvent(RdKGToolCyro.callbackName, EVENT_GUILD_CLAIM_KEEP_CAMPAIGN_NOTIFICATION, RdKGToolCyro.OnGuildClaimKeepCampaignNotification)
			EVENT_MANAGER:RegisterForEvent(RdKGToolCyro.callbackName, EVENT_GUILD_LOST_KEEP_CAMPAIGN_NOTIFICATION, RdKGToolCyro.OnGuildLostKeepCampaignNotification)
			--EVENT_MANAGER:RegisterForEvent(RdKGToolCyro.callbackName, EVENT_ALLIANCE_POINT_UPDATE, RdKGToolCyro.OnApUpdate)
			EVENT_MANAGER:RegisterForEvent(RdKGToolCyro.callbackName, EVENT_OBJECTIVE_CONTROL_STATE, RdKGToolCyro.OnObjectiveControlState)
			EVENT_MANAGER:RegisterForEvent(RdKGToolCyro.callbackName, EVENT_ARTIFACT_CONTROL_STATE, RdKGToolCyro.OnScrollState)
			EVENT_MANAGER:RegisterForEvent(RdKGToolCyro.callbackName, EVENT_CORONATE_EMPEROR_NOTIFICATION , RdKGToolCyro.OnCoronateEmperorNotification)
			EVENT_MANAGER:RegisterForEvent(RdKGToolCyro.callbackName, EVENT_DEPOSE_EMPEROR_NOTIFICATION , RdKGToolCyro.OnDeposeEmperorNotification)
			EVENT_MANAGER:RegisterForEvent(RdKGToolCyro.callbackName, EVENT_ACTIVE_DAEDRIC_ARTIFACT_CHANGED, RdKGToolCyro.OnActiveDaedricArtifactChanged)
			EVENT_MANAGER:RegisterForEvent(RdKGToolCyro.callbackName, EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED, RdKGToolCyro.OnDaedricArtifactObjectiveStateChanged)
			EVENT_MANAGER:RegisterForEvent(RdKGToolCyro.callbackName, EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED, RdKGToolCyro.OnDaedricArtifactObjectiveSpawnedButNoRevealed)
			EVENT_MANAGER:RegisterForUpdate(RdKGToolCyro.callbackName, RdKGToolCyro.config.updateInterval, RdKGToolCyro.CyroUpdateLoop)
		end
		if #RdKGToolCyro.state.consumers > 0 then
			RdKGToolCyro.ResetObjectives()
		end
	else
		if RdKGToolCyro.state.registredConsumers == true then
			EVENT_MANAGER:UnregisterForEvent(RdKGToolCyro.callbackName, EVENT_ARTIFACT_CONTROL_STATE)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolCyro.callbackName, EVENT_OBJECTIVE_CONTROL_STATE)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolCyro.callbackName, EVENT_GUILD_CLAIM_KEEP_CAMPAIGN_NOTIFICATION)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolCyro.callbackName, EVENT_GUILD_LOST_KEEP_CAMPAIGN_NOTIFICATION)
			--EVENT_MANAGER:UnregisterForEvent(RdKGToolCyro.callbackName, EVENT_ALLIANCE_POINT_UPDATE)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolCyro.callbackName, EVENT_CORONATE_EMPEROR_NOTIFICATION)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolCyro.callbackName, EVENT_DEPOSE_EMPEROR_NOTIFICATION)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolCyro.callbackName, EVENT_ACTIVE_DAEDRIC_ARTIFACT_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolCyro.callbackName, EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolCyro.callbackName, EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED)
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolCyro.callbackName)
			RdKGToolCyro.state.registredConsumers = false
			RdKGToolCyro.state.campaignId = 0
		end
		RdKGToolCyro.state.initializedItems = false
	end
end

-- /script d(#RdKGTool.util.cyrodiil.state.itemsOfInterest)
function RdKGToolCyro.CyroUpdateLoop()
	if RdKGToolUtil.IsInCyrodiil() == true then
		local itemsOfInterest = {}
		local gameTime = GetGameTimeMilliseconds()
		itemsOfInterest = RdKGToolCyro.AdjustItemsOfInterest(itemsOfInterest, RdKGToolCyro.UpdateItem(RdKGToolCyro.state.resources, gameTime))
		itemsOfInterest = RdKGToolCyro.AdjustItemsOfInterest(itemsOfInterest, RdKGToolCyro.UpdateItem(RdKGToolCyro.state.keeps, gameTime))
		itemsOfInterest = RdKGToolCyro.AdjustItemsOfInterest(itemsOfInterest, RdKGToolCyro.UpdateItem(RdKGToolCyro.state.outposts, gameTime))
		itemsOfInterest = RdKGToolCyro.AdjustItemsOfInterest(itemsOfInterest, RdKGToolCyro.UpdateItem(RdKGToolCyro.state.villages, gameTime))
		itemsOfInterest = RdKGToolCyro.AdjustItemsOfInterest(itemsOfInterest, RdKGToolCyro.UpdateItem(RdKGToolCyro.state.destructibles, gameTime))
		itemsOfInterest = RdKGToolCyro.AdjustItemsOfInterest(itemsOfInterest, RdKGToolCyro.UpdateItem(RdKGToolCyro.state.temples, gameTime))
		--d("Sort: " .. #itemsOfInterest)
		if #itemsOfInterest > 1 then
			table.sort(itemsOfInterest, RdKGToolCyro.SortItemsOfInterest)
		end
		RdKGToolCyro.UpdateItemsOfInterest(itemsOfInterest)
	end
end


function RdKGToolCyro.OnGuildClaimKeepCampaignNotification(eventCode, campaignId, keepId, guildName, playerName)
	if RdKGToolCyro.state.campaignId == campaignId then
		--d("KeepId Claim: " .. keepId .. " -> " .. guildName .. " -> " .. playerName)
		local eventData = {}
		eventData.event = RdKGToolCyro.constants.events.GUILD_CLAIM
		eventData.keepName = zo_strformat("<<1>>", GetKeepName(keepId))
		eventData.keepId = keepId
		eventData.guildName = guildName
		local alliance = GetKeepAlliance(keepId, BGQUERY_LOCAL)
		if alliance ~= nil then
			eventData.alliance = alliance
		else
			eventData.alliance = 0
		end
		eventData.playerName = playerName
		RdKGToolCyro.NotifyMessageConsumers(eventData)
	end
end


function RdKGToolCyro.OnGuildLostKeepCampaignNotification(eventCode, campaignId, keepId, guildName)
	if RdKGToolCyro.state.campaignId == campaignId then
		--d("KeepId Lost: " .. keepId .. " -> " .. guildName)
		local eventData = {}
		eventData.event = RdKGToolCyro.constants.events.GUILD_LOST
		eventData.keepName = zo_strformat("<<1>>", GetKeepName(keepId))
		eventData.keepId = keepId
		eventData.guildName = guildName
		local item = RdKGToolCyro.GetItemByKeepId(keepId)
		local alliance = GetKeepAlliance(keepId, BGQUERY_LOCAL)
		if alliance ~= nil then
			eventData.alliance = alliance
		else
			eventData.alliance = 0
		end
		local item = RdKGToolCyro.state.resources[keepId] or RdKGToolCyro.state.keeps[keepId] or RdKGToolCyro.state.outposts[keepId] or RdKGToolCyro.state.villages[keepId]
		if item ~= nil and item.previousOwningAlliance ~= nil then
			eventData.previousOwningAlliance = item.previousOwningAlliance
		else
			eventData.previousOwningAlliance = 0
		end
		RdKGToolCyro.NotifyMessageConsumers(eventData)
	end
end

function RdKGToolCyro.OnObjectiveControlState(eventCode, keepId, objectiveId, battlegroundContext, objectiveName, objectiveType, objectiveControlEvent, objectiveControlState, holdingAlliance, attackingAlliance, pinType)
	--d(objectiveName)
	--d(holdingAlliance)
	--d(objectiveParam2)
	--d("keepId..:" .. keepId)
	--/script EVENT_MANAGER:RegisterForEvent("test", EVENT_OBJECTIVE_CONTROL_STATE,function(ec, kId, oId, bC, oName, oType, oCE, oCS, hA, aA, pT) d('---') d(oCS) d(hA) d('---') end)
	local keep = RdKGToolCyro.GetItemByKeepId(keepId)
	if keep ~= nil then
		--d("-----------------")
		--d("keepId: " .. keepId)
		--d("objectiveId: " .. objectiveId)
		--d("objectiveName: " .. objectiveName)
		--d("holdingAlliance: " .. holdingAlliance)
		--d("attackingAlliance: " .. attackingAlliance)
		local objectives = keep.objectives
		local objective = nil
		--Race Condition onplayer activated => GetNumObjectives() (likely all such methods...)
		if objectives == nil then
			RdKGToolChat.SendChatMessage("Race condition detected. Trying to fix it...", RdKGToolCyro.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
			RdKGToolCyro.AddObjectives()
		end
		if objectives ~= nil then
			for i = 1, #objectives do
				if objectives[i].id == objectiveId then
					objective = objectives[i]
					break
				end
			end
		else
			RdKGToolCyro.TempDebugPrint("OnObjectiveControlState objectives", "nil")
		end
		if objective ~= nil then
			objective.holdingAlliance = holdingAlliance
			if objective.holdingAlliance == 0 then
				objective.holdingAlliance = attackingAlliance
			end
			objective.state = RdKGToolCyro.GetFlagStatePercent(objectiveControlState, keep.owningAlliance, holdingAlliance)
			--d("state: " .. objective.state)
			RdKGToolCyro.AdjustKeepFlipping(keep)
			RdKGToolCyro.UpdateItemsOfInterest(RdKGToolCyro.state.itemsOfInterest)
		end
	end
end

function RdKGToolCyro.OnApUpdate(eventCode, alliancePoints, playSound, difference, reason, keepId)
	if reason == CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD then
		local eventData = {}
		eventData.event = RdKGToolCyro.constants.events.TICK_DEFENSE
		eventData.keepName = zo_strformat("<<1>>", GetKeepName(keepId))
		eventData.keepId = keepId
		eventData.apGained = difference
		local alliance = GetKeepAlliance(keepId, BGQUERY_LOCAL)
		if alliance ~= nil then
			eventData.alliance = alliance
		else
			eventData.alliance = 0
		end
		RdKGToolCyro.NotifyMessageConsumers(eventData)
	elseif reason == CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD then
		local eventData = {}
		eventData.event = RdKGToolCyro.constants.events.TICK_OFFENSE
		eventData.keepName = zo_strformat("<<1>>", GetKeepName(keepId))
		eventData.keepId = keepId
		eventData.apGained = difference
		local alliance = GetUnitAlliance("player")
		if alliance ~= nil then
			eventData.alliance = alliance
		else
			eventData.alliance = 0
		end
		RdKGToolCyro.NotifyMessageConsumers(eventData)
	elseif reason == CURRENCY_CHANGE_REASON_QUESTREWARD then
		local eventData = {}
		eventData.event = RdKGToolCyro.constants.events.QUEST_REWARD
		eventData.apGained = difference
		RdKGToolCyro.NotifyMessageConsumers(eventData)
	elseif reason == CURRENCY_CHANGE_REASON_BATTLEGROUND then
		local eventData = {}
		eventData.event = RdKGToolCyro.constants.events.BATTLEGROUND_REWARD
		eventData.apGained = difference
		RdKGToolCyro.NotifyMessageConsumers(eventData)
	elseif reason == CURRENCY_CHANGE_REASON_MEDAL then
		local eventData = {}
		eventData.event = RdKGToolCyro.constants.events.BATTLEGROUND_MEDAL_REWARD
		eventData.apGained = difference
		RdKGToolCyro.NotifyMessageConsumers(eventData)
	end
	--d("AP: " .. difference .. ", reason: " .. reason)
	--if keepId ~= nil then
	--	d("KeepId: " .. keepId)
	--end
end

function RdKGToolCyro.OnScrollState(eventCode, artifactName, keepId, characterName, playerAlliance, objectiveControlEvent, objectiveControlState, campaignId, displayName)
	if RdKGToolCyro.state.campaignId == campaignId then
		artifactName = zo_strformat("<<1>>", artifactName)
		if objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_DROPPED then
			local eventData = {}
			eventData.event = RdKGToolCyro.constants.events.SCROLL_DROPPED
			eventData.charName = characterName
			eventData.displayName = displayName
			eventData.playerAlliance = playerAlliance
			eventData.scrollAlliance = RdKGToolCyro.GetScrollAlliance(artifactName)
			eventData.scroll = artifactName
			RdKGToolCyro.NotifyMessageConsumers(eventData)
		elseif objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_TAKEN then
			local eventData = {}
			eventData.event = RdKGToolCyro.constants.events.SCROLL_PICKED_UP
			eventData.charName = characterName
			eventData.displayName = displayName
			eventData.playerAlliance = playerAlliance
			eventData.scrollAlliance = RdKGToolCyro.GetScrollAlliance(artifactName)
			eventData.scroll = artifactName
			RdKGToolCyro.NotifyMessageConsumers(eventData)
		elseif objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_RETURNED then
			local eventData = {}
			eventData.event = RdKGToolCyro.constants.events.SCROLL_RETURNED
			eventData.charName = characterName
			eventData.displayName = displayName
			eventData.playerAlliance = playerAlliance
			eventData.scrollAlliance = RdKGToolCyro.GetScrollAlliance(artifactName)
			eventData.scroll = artifactName
			RdKGToolCyro.NotifyMessageConsumers(eventData)
		elseif objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_RETURNED_BY_TIMER then
			local eventData = {}
			eventData.event = RdKGToolCyro.constants.events.SCROLL_RETURNED_BY_TIMER
			eventData.scroll = artifactName
			eventData.scrollAlliance = RdKGToolCyro.GetScrollAlliance(artifactName)
			RdKGToolCyro.NotifyMessageConsumers(eventData)
		elseif objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_CAPTURED then
			local eventData = {}
			eventData.event = RdKGToolCyro.constants.events.SCROLL_CAPTURED
			eventData.charName = characterName
			eventData.displayName = displayName
			eventData.playerAlliance = playerAlliance
			eventData.scrollAlliance = RdKGToolCyro.GetScrollAlliance(artifactName)
			eventData.scroll = artifactName
			eventData.keepId = keepId
			eventData.keepName = zo_strformat("<<1>>", GetKeepName(keepId))
			RdKGToolCyro.NotifyMessageConsumers(eventData)
		end
	end
end

function RdKGToolCyro.OnCoronateEmperorNotification(eventCode, campaignId, characterName, emperorAlliance, displayName)
	if RdKGToolCyro.state.campaignId == campaignId then
		local eventData = {}
		eventData.event = RdKGToolCyro.constants.events.EMPEROR_CORONATED
		eventData.charName = characterName
		eventData.displayName = displayName
		eventData.alliance = emperorAlliance
		RdKGToolCyro.NotifyMessageConsumers(eventData)
	end
end

function RdKGToolCyro.OnDeposeEmperorNotification(eventCode, campaignId, characterName, emperorAlliance, abdication, displayName)
	if RdKGToolCyro.state.campaignId == campaignId then
		local eventData = {}
		eventData.event = RdKGToolCyro.constants.events.EMPEROR_DEPOSED
		eventData.charName = characterName
		eventData.displayName = displayName
		eventData.alliance = emperorAlliance
		eventData.abdication = abdication
		RdKGToolCyro.NotifyMessageConsumers(eventData)
	end
end
			
function RdKGToolCyro.OnActiveDaedricArtifactChanged(eventCode, artifactId)
	RdKGToolCyro.TempDebugPrint("OnActiveDaedricArtifactChanged", artifactId)
end

function RdKGToolCyro.OnDaedricArtifactObjectiveSpawnedButNoRevealed(eventCode, daedricArtifactId)
	RdKGToolCyro.TempDebugPrint("OnDaedricArtifactObjectiveSpawnedButNoRevealed", "invoked")
	RdKGToolCyro.TempDebugPrint("daedricArtifactId", daedricArtifactId)
	local eventData = {}
	eventData.event = RdKGToolCyro.constants.events.DAEDRIC_ARTIFACT_SPAWNED
	if GetDaedricArtifactDisplayName ~= nil and GetDaedricArtifactDisplayName(daedricArtifactId) ~= nil or GetDaedricArtifactDisplayName(daedricArtifactId) ~= "" then
		eventData.objectiveName = GetDaedricArtifactDisplayName(daedricArtifactId)
	else
		eventData.objectiveName = "[Unknown]"
	end
	
	RdKGToolCyro.NotifyMessageConsumers(eventData)
	
end

function RdKGToolCyro.OnDaedricArtifactObjectiveStateChanged(eventCode, objectiveKeepId, objectiveObjectiveId, battlegroundContext, objectiveControlEvent, objectiveControlState, holderAlliance, lastHolderAlliance, holderRawCharacterName, holderDisplayName, lastHolderRawCharacterName, lastHolderDisplayName, pinType, daedricArtifactId)
	RdKGToolCyro.TempDebugPrint("OnDaedricArtifactObjectiveStateChanged", "invoked")
	RdKGToolCyro.TempDebugPrint("IsInCampaign", IsInCampaign())
	RdKGToolCyro.TempDebugPrint("objectiveKeepId", objectiveKeepId)
	RdKGToolCyro.TempDebugPrint("objectiveObjectiveId", objectiveObjectiveId)
	RdKGToolCyro.TempDebugPrint("battlegroundContext", battlegroundContext)
	RdKGToolCyro.TempDebugPrint("objectiveControlEvent", objectiveControlEvent)
	RdKGToolCyro.TempDebugPrint("objectiveControlState", objectiveControlState)
	RdKGToolCyro.TempDebugPrint("holderAlliance", holderAlliance)
	RdKGToolCyro.TempDebugPrint("lastHolderAlliance", lastHolderAlliance)
	RdKGToolCyro.TempDebugPrint("holderRawCharacterName", holderRawCharacterName)
	RdKGToolCyro.TempDebugPrint("holderDisplayName", holderDisplayName)
	RdKGToolCyro.TempDebugPrint("lastHolderRawCharacterName", lastHolderRawCharacterName)
	RdKGToolCyro.TempDebugPrint("lastHolderDisplayName", lastHolderDisplayName)
	RdKGToolCyro.TempDebugPrint("pinType", pinType)
	RdKGToolCyro.TempDebugPrint("daedricArtifactId", daedricArtifactId)
	
	RdKGToolCyro.TempDebugPrint("objectiveName", GetObjectiveInfo(objectiveKeepId, objectiveObjectiveId, battlegroundContext))
	if IsInCampaign() then
		local eventData = {}
		eventData.objectiveName = GetObjectiveInfo(objectiveKeepId, objectiveObjectiveId, battlegroundContext)
		if objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_SPAWNED then
			eventData.event = RdKGToolCyro.constants.events.DAEDRIC_ARTIFACT_REVEALED
		elseif objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_DROPPED then
			eventData.event = RdKGToolCyro.constants.events.DAEDRIC_ARTIFACT_DROPPED
		elseif objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_TAKEN then
			eventData.event = RdKGToolCyro.constants.events.DAEDRIC_ARTIFACT_TAKEN
		elseif objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_ITERATION_END then --This might be an other objective event!
			eventData.event = RdKGToolCyro.constants.events.DAEDRIC_ARTIFACT_DESPAWNED
		end
		eventData.alliance = holderAlliance
		if holderAlliance == 0 then
			eventData.alliance = lastHolderAlliance
		end
		RdKGToolCyro.NotifyMessageConsumers(eventData)
	end
end