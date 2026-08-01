-- Create namespace
DsRGuildPvPcyro = {}
local DsRGuildPvPcyro = DsRGuildPvPcyro  or {}

DsRGuildPvPcyro.callbackName = "DsRGuildPvPcyro"

DsRGuildPvPcyro.config = {}
DsRGuildPvPcyro.config.updateInterval = 1000
DsRGuildPvPcyro.config.siegeTimeout = 30000
DsRGuildPvPcyro.config.previousOwnerThreshold = 5000

DsRGuildPvPcyro.state = {}
DsRGuildPvPcyro.state.registredConsumers = false
DsRGuildPvPcyro.state.initializedItems = false
DsRGuildPvPcyro.state.campaignId = 0
DsRGuildPvPcyro.state.consumers = {}
DsRGuildPvPcyro.state.resources = {}
DsRGuildPvPcyro.state.keeps = {}
DsRGuildPvPcyro.state.outposts = {}
DsRGuildPvPcyro.state.villages = {}
DsRGuildPvPcyro.state.destructibles = {}
DsRGuildPvPcyro.state.temples = {}
DsRGuildPvPcyro.state.scrolls = {}

DsRGuildPvPcyro.constants = {}
DsRGuildPvPcyro.constants.resourceType = {}
DsRGuildPvPcyro.constants.resourceType.FARM = 1
DsRGuildPvPcyro.constants.resourceType.MINE = 2
DsRGuildPvPcyro.constants.resourceType.LUMBER = 3
DsRGuildPvPcyro.constants.events = {}
DsRGuildPvPcyro.constants.events.GUILD_CLAIM = 1
DsRGuildPvPcyro.constants.events.GUILD_LOST = 2
DsRGuildPvPcyro.constants.events.STATUS_UA = 3
DsRGuildPvPcyro.constants.events.STATUS_UA_LOST = 4
DsRGuildPvPcyro.constants.events.KEEP_OWNER_CHANGED = 5
DsRGuildPvPcyro.constants.events.TICK_DEFENSE = 6
DsRGuildPvPcyro.constants.events.TICK_OFFENSE = 7
DsRGuildPvPcyro.constants.events.SCROLL_PICKED_UP = 8
DsRGuildPvPcyro.constants.events.SCROLL_DROPPED = 9
DsRGuildPvPcyro.constants.events.SCROLL_RETURNED = 10
DsRGuildPvPcyro.constants.events.SCROLL_RETURNED_BY_TIMER = 11
DsRGuildPvPcyro.constants.events.SCROLL_CAPTURED = 12
DsRGuildPvPcyro.constants.events.EMPEROR_CORONATED = 13
DsRGuildPvPcyro.constants.events.EMPEROR_DEPOSED = 14
DsRGuildPvPcyro.constants.events.QUEST_REWARD = 15
DsRGuildPvPcyro.constants.events.BATTLEGROUND_REWARD = 16
DsRGuildPvPcyro.constants.events.BATTLEGROUND_MEDAL_REWARD = 16
DsRGuildPvPcyro.constants.events.DAEDRIC_ARTIFACT_SPAWNED = 17		-- Volendrung aufgetaucht
DsRGuildPvPcyro.constants.events.DAEDRIC_ARTIFACT_REVEALED = 18		-- Volendrung Enthüllt
DsRGuildPvPcyro.constants.events.DAEDRIC_ARTIFACT_DROPPED = 19		-- Volendrung fallen gelassen
DsRGuildPvPcyro.constants.events.DAEDRIC_ARTIFACT_TAKEN = 20		-- Volendrung genommen
DsRGuildPvPcyro.constants.events.DAEDRIC_ARTIFACT_DESPAWNED = 21	-- Volendrung vernichtet
DsRGuildPvPcyro.constants.flipTimes = {}
DsRGuildPvPcyro.constants.flipTimes.KEEP = 20000
DsRGuildPvPcyro.constants.flipTimes.OUTPOST = 20000
DsRGuildPvPcyro.constants.flipTimes.RESOURCE = 20000
DsRGuildPvPcyro.constants.PREFIX = "Cyro"

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.Initialize()
	EVENT_MANAGER:RegisterForEvent(DsRGuildPvPcyro.callbackName, EVENT_PLAYER_ACTIVATED, DsRGuildPvPcyro.OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(DsRGuildPvPcyro.callbackName, EVENT_ALLIANCE_POINT_UPDATE, DsRGuildPvPcyro.OnApUpdate)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.formatTime(delta, inclueSec, doAdditional)
    local sec = delta % 60
    delta = (delta - sec) / 60
    local min = delta % 60
    local out = min .. "m"

	if doAdditional == true then
		if min == 0 then
		    if sec == 0 then
			    out = '  '.."now"
			else
			    out = '  '..sec.."s"
			end
		elseif min > 9 then
            out = '  '..out 		
		else
		    if sec < 10 then sec = "0"..sec end
			out = '  '..min..":"..sec
		end
	end
    if inclueSec then
        out = out .. " " .. sec .. "s"
    end
    return out
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.AddConsumer(name, updateCallback, messageCallback)
	if name ~= nil then
		local entryFound = false
		for i = 1, #DsRGuildPvPcyro.state.consumers do
			if DsRGuildPvPcyro.state.consumers.name == name then
				entryFound = true
				break
			end
		end
		if entryFound == false then
			local entry = {}
			entry.name = name
			entry.updateCallback = updateCallback
			entry.messageCallback = messageCallback
			table.insert(DsRGuildPvPcyro.state.consumers, entry)
			DsRGuildPvPcyro.OnPlayerActivated()
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.RemoveConsumer(name)
	if name ~= nil then
		for i = 1, #DsRGuildPvPcyro.state.consumers do
			if DsRGuildPvPcyro.state.consumers[i].name == name then
				table.remove(DsRGuildPvPcyro.state.consumers, i)
				break
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.NotifyUpdateConsumers(itemsOfInterest)
	if DsRGuildPvPcyro.state.consumers ~= nil then
		for i = 1, #DsRGuildPvPcyro.state.consumers do
			if type(DsRGuildPvPcyro.state.consumers[i].updateCallback) == "function" then
				DsRGuildPvPcyro.state.consumers[i].updateCallback(itemsOfInterest)
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.NotifyMessageConsumers(eventData)
	if DsRGuildPvPcyro.state.consumers ~= nil then
		for i = 1, #DsRGuildPvPcyro.state.consumers do
			if DsRGuildPvPcyro.state.consumers[i].messageCallback ~= nil and type(DsRGuildPvPcyro.state.consumers[i].messageCallback) == "function" then
				DsRGuildPvPcyro.state.consumers[i].messageCallback(eventData)
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.AdjustResourceName(name)
	name = name:gsub("%^.d$", ""):gsub("Castle ",""):gsub("[fF]ort ",""):gsub("Keep ",""):gsub("Feste ",""):gsub("Kastell ",""):gsub("Kastells ",""):gsub("Burg ",""):gsub("der ", ""):gsub("die ", ""):gsub("das ", ""):gsub("des ", ""):gsub("lager", ""):gsub("Bauernhof", "Farm"):gsub("mill",""):gsub("la bastille ", ""):gsub("de la ", " "):gsub(" de "," "):gsub(" du ", " "):gsub(" la ", " "):gsub(" le ", " "):gsub(" les ", " "):gsub("la ferme", "ferme"):gsub("la scierie", "scierie"):gsub("la mine", "mine"):gsub("le château", ""):gsub(" château ", " "):gsub(" bastille ", " ")
	return name
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.AdjustKeepName(name)
	name = name:gsub(",..$", ""):gsub("%^.d$", ""):gsub("Castle ",""):gsub("le fort ", ""):gsub("[fF]ort ",""):gsub("Keep ",""):gsub("Keep",""):gsub("Feste ",""):gsub("Kastell ",""):gsub("Burg ",""):gsub("avant.poste d[eu] ", ""):gsub("bastille d[eu]s? ", ""):gsub("fort de la ", ""):gsub("der ", ""):gsub("das ", ""):gsub("die ", ""):gsub("la bastille ", ""):gsub("de la ", " "):gsub(" de "," "):gsub(" du ", " "):gsub(" la ", " "):gsub(" le ", " "):gsub(" les ", " "):gsub("le château", ""):gsub(" château ", " "):gsub(" bastille ", " "):gsub("de la", " ")
	return name
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.AdjustOutpostName(name)
	-- name = name:gsub("Outpost","")
	name = name:gsub("Outpost",""):gsub("der ", ""):gsub("die ", ""):gsub("das ", "")
	return name
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.AdjustTempleName(name)
	name = name:gsub("Scroll ","")
	return name
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.InitResources(gameTime)
	local resources = { 22, 23, 24, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57,
						61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85 ,86, 87}
	DsRGuildPvPcyro.state.resources = {}
	for i = 1, #resources do
		DsRGuildPvPcyro.state.resources[resources[i]] = {}
		DsRGuildPvPcyro.state.resources[resources[i]].id = resources[i]
		DsRGuildPvPcyro.state.resources[resources[i]].keepType = GetKeepType(resources[i])
		DsRGuildPvPcyro.state.resources[resources[i]].name = DsRGuildPvPcyro.AdjustResourceName(zo_strformat("<<1>>", GetKeepName(resources[i])))
		DsRGuildPvPcyro.state.resources[resources[i]].isUnderAttack = GetKeepUnderAttack(resources[i],  BGQUERY_LOCAL)
		if DsRGuildPvPcyro.state.resources[resources[i]].isUnderAttack == true then
			DsRGuildPvPcyro.state.resources[resources[i]].underAttackSince = gameTime
		else
			DsRGuildPvPcyro.state.resources[resources[i]].underAttackSince = nil
		end
		DsRGuildPvPcyro.state.resources[resources[i]].attackStatusLostAt = 0
		DsRGuildPvPcyro.state.resources[resources[i]].underAttackFor = 0
		DsRGuildPvPcyro.state.resources[resources[i]].siegeWeapons = {}
		DsRGuildPvPcyro.state.resources[resources[i]].siegeWeapons.AD = GetNumSieges(resources[i], BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
		DsRGuildPvPcyro.state.resources[resources[i]].siegeWeapons.DC = GetNumSieges(resources[i], BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
		DsRGuildPvPcyro.state.resources[resources[i]].siegeWeapons.EP = GetNumSieges(resources[i], BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
		DsRGuildPvPcyro.state.resources[resources[i]].owningAlliance = GetKeepAlliance(resources[i], BGQUERY_LOCAL)
		DsRGuildPvPcyro.state.resources[resources[i]].previousOwningAlliance = GetKeepAlliance(resources[i], BGQUERY_LOCAL)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.InitKeeps(gameTime)
	DsRGuildPvPcyro.state.keeps = {}
	for i = 3, 20 do
		DsRGuildPvPcyro.state.keeps[i] = {}
		DsRGuildPvPcyro.state.keeps[i].id = i
		DsRGuildPvPcyro.state.keeps[i].keepType = GetKeepType(i)
		DsRGuildPvPcyro.state.keeps[i].name = DsRGuildPvPcyro.AdjustKeepName(zo_strformat("<<1>>", GetKeepName(i)))
		DsRGuildPvPcyro.state.keeps[i].isUnderAttack = GetKeepUnderAttack(i,  BGQUERY_LOCAL)
		if DsRGuildPvPcyro.state.keeps[i].isUnderAttack == true then
			DsRGuildPvPcyro.state.keeps[i].underAttackSince = gameTime
		else
			DsRGuildPvPcyro.state.keeps[i].underAttackSince = nil
		end
		DsRGuildPvPcyro.state.keeps[i].attackStatusLostAt = 0
		DsRGuildPvPcyro.state.keeps[i].underAttackFor = 0
		DsRGuildPvPcyro.state.keeps[i].siegeWeapons = {}
		DsRGuildPvPcyro.state.keeps[i].siegeWeapons.AD = GetNumSieges(i, BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
		DsRGuildPvPcyro.state.keeps[i].siegeWeapons.DC = GetNumSieges(i, BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
		DsRGuildPvPcyro.state.keeps[i].siegeWeapons.EP = GetNumSieges(i, BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
		DsRGuildPvPcyro.state.keeps[i].resources = {}
		DsRGuildPvPcyro.state.keeps[i].resources.farm = DsRGuildPvPcyro.state.resources[GetResourceKeepForKeep(i, RESOURCETYPE_FOOD)]
		DsRGuildPvPcyro.state.keeps[i].resources.farm.rType = DsRGuildPvPcyro.constants.resourceType.FARM
		DsRGuildPvPcyro.state.keeps[i].resources.lumber = DsRGuildPvPcyro.state.resources[GetResourceKeepForKeep(i, RESOURCETYPE_WOOD)]
		DsRGuildPvPcyro.state.keeps[i].resources.lumber.rType = DsRGuildPvPcyro.constants.resourceType.LUMBER
		DsRGuildPvPcyro.state.keeps[i].resources.mine = DsRGuildPvPcyro.state.resources[GetResourceKeepForKeep(i, RESOURCETYPE_ORE)]
		DsRGuildPvPcyro.state.keeps[i].resources.mine.rType = DsRGuildPvPcyro.constants.resourceType.MINE
		DsRGuildPvPcyro.state.keeps[i].owningAlliance = GetKeepAlliance(i, BGQUERY_LOCAL)
		DsRGuildPvPcyro.state.keeps[i].previousOwningAlliance = GetKeepAlliance(i, BGQUERY_LOCAL)
	end
	
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.InitOutposts(gameTime)
	local outposts = {132, 133, 134, 163, 164, 165}
	DsRGuildPvPcyro.state.outposts = {}
	for i = 1, #outposts do
		DsRGuildPvPcyro.state.outposts[outposts[i]] = {}
		DsRGuildPvPcyro.state.outposts[outposts[i]].id = outposts[i]
		DsRGuildPvPcyro.state.outposts[outposts[i]].keepType = GetKeepType(outposts[i])
		DsRGuildPvPcyro.state.outposts[outposts[i]].name = zo_strformat("<<1>>", GetKeepName(outposts[i]))
		DsRGuildPvPcyro.state.outposts[outposts[i]].isUnderAttack = GetKeepUnderAttack(outposts[i],  BGQUERY_LOCAL)
		if DsRGuildPvPcyro.state.outposts[outposts[i]].isUnderAttack == true then
			DsRGuildPvPcyro.state.outposts[outposts[i]].underAttackSince = gameTime
		else
			DsRGuildPvPcyro.state.outposts[outposts[i]].underAttackSince = nil
		end
		DsRGuildPvPcyro.state.outposts[outposts[i]].attackStatusLostAt = 0
		DsRGuildPvPcyro.state.outposts[outposts[i]].underAttackFor = 0
		DsRGuildPvPcyro.state.outposts[outposts[i]].siegeWeapons = {}
		DsRGuildPvPcyro.state.outposts[outposts[i]].siegeWeapons.AD = GetNumSieges(outposts[i], BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
		DsRGuildPvPcyro.state.outposts[outposts[i]].siegeWeapons.DC = GetNumSieges(outposts[i], BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
		DsRGuildPvPcyro.state.outposts[outposts[i]].siegeWeapons.EP = GetNumSieges(outposts[i], BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
		DsRGuildPvPcyro.state.outposts[outposts[i]].owningAlliance = GetKeepAlliance(outposts[i], BGQUERY_LOCAL)
		DsRGuildPvPcyro.state.outposts[outposts[i]].previousOwningAlliance = GetKeepAlliance(outposts[i], BGQUERY_LOCAL)
	end
	
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.InitVillages(gameTime)
	local villages = {149, 151, 152}
	DsRGuildPvPcyro.state.villages = {}
	for i = 1, #villages do
		DsRGuildPvPcyro.state.villages[villages[i]] = {}
		DsRGuildPvPcyro.state.villages[villages[i]].id = villages[i]
		DsRGuildPvPcyro.state.villages[villages[i]].keepType = GetKeepType(villages[i])
		DsRGuildPvPcyro.state.villages[villages[i]].name = zo_strformat("<<1>>", GetKeepName(villages[i]))
		DsRGuildPvPcyro.state.villages[villages[i]].isUnderAttack = GetKeepUnderAttack(villages[i],  BGQUERY_LOCAL)
		if DsRGuildPvPcyro.state.villages[villages[i]].isUnderAttack == true then
			DsRGuildPvPcyro.state.villages[villages[i]].underAttackSince = gameTime
		else
			DsRGuildPvPcyro.state.villages[villages[i]].underAttackSince = nil
		end
		DsRGuildPvPcyro.state.villages[villages[i]].attackStatusLostAt = 0
		DsRGuildPvPcyro.state.villages[villages[i]].underAttackFor = 0
		DsRGuildPvPcyro.state.villages[villages[i]].siegeWeapons = {}
		DsRGuildPvPcyro.state.villages[villages[i]].siegeWeapons.AD = GetNumSieges(villages[i], BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
		DsRGuildPvPcyro.state.villages[villages[i]].siegeWeapons.DC = GetNumSieges(villages[i], BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
		DsRGuildPvPcyro.state.villages[villages[i]].siegeWeapons.EP = GetNumSieges(villages[i], BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
		DsRGuildPvPcyro.state.villages[villages[i]].owningAlliance = GetKeepAlliance(villages[i], BGQUERY_LOCAL)
		DsRGuildPvPcyro.state.villages[villages[i]].previousOwningAlliance = GetKeepAlliance(villages[i], BGQUERY_LOCAL)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.InitDestructibles(gameTime)
	DsRGuildPvPcyro.state.destructibles = {}
	for i = 154, 162 do
		DsRGuildPvPcyro.state.destructibles[i] = {}
		DsRGuildPvPcyro.state.destructibles[i].id = i
		DsRGuildPvPcyro.state.destructibles[i].keepType = GetKeepType(i)
		DsRGuildPvPcyro.state.destructibles[i].name = DsRGuildPvPcyro.AdjustResourceName(zo_strformat("<<1>>", GetKeepName(i)))
		DsRGuildPvPcyro.state.destructibles[i].isUnderAttack = GetKeepUnderAttack(i,  BGQUERY_LOCAL)
		if DsRGuildPvPcyro.state.destructibles[i].isUnderAttack == true then
			DsRGuildPvPcyro.state.destructibles[i].underAttackSince = gameTime
		else
			DsRGuildPvPcyro.state.destructibles[i].underAttackSince = nil
		end
		DsRGuildPvPcyro.state.destructibles[i].attackStatusLostAt = 0
		DsRGuildPvPcyro.state.destructibles[i].underAttackFor = 0
		DsRGuildPvPcyro.state.destructibles[i].isPassable = IsKeepPassable(i, BGQUERY_LOCAL)
		DsRGuildPvPcyro.state.destructibles[i].directionalAccess = GetKeepDirectionalAccess(i, BGQUERY)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.InitTemples(gameTime)
	DsRGuildPvPcyro.state.temples = {}
	for i = 118, 123 do
		DsRGuildPvPcyro.state.temples[i] = {}
		DsRGuildPvPcyro.state.temples[i].id = i
		DsRGuildPvPcyro.state.temples[i].keepType = GetKeepType(i)
		DsRGuildPvPcyro.state.temples[i].name = zo_strformat("<<1>>", DsRGuildPvPcyro.AdjustTempleName(GetKeepName(i)))
		DsRGuildPvPcyro.state.temples[i].isUnderAttack = GetKeepUnderAttack(i,  BGQUERY_LOCAL)
		if DsRGuildPvPcyro.state.temples[i].isUnderAttack == true then
			DsRGuildPvPcyro.state.temples[i].underAttackSince = gameTime
		else
			DsRGuildPvPcyro.state.temples[i].underAttackSince = nil
		end
		DsRGuildPvPcyro.state.temples[i].attackStatusLostAt = 0
		DsRGuildPvPcyro.state.temples[i].underAttackFor = 0
		DsRGuildPvPcyro.state.temples[i].siegeWeapons = {}
		DsRGuildPvPcyro.state.temples[i].siegeWeapons.AD = GetNumSieges(i, BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
		DsRGuildPvPcyro.state.temples[i].siegeWeapons.DC = GetNumSieges(i, BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
		DsRGuildPvPcyro.state.temples[i].siegeWeapons.EP = GetNumSieges(i, BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
		DsRGuildPvPcyro.state.temples[i].owningAlliance = GetKeepAlliance(i, BGQUERY_LOCAL)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.AddObjectives()
	local numObjectives = GetNumObjectives()
	for i = 1, numObjectives do
		local keepId, objectiveId, bgqueryType = GetObjectiveIdsForIndex(i)
		if bgqueryType == BGQUERY_ASSIGNED_AND_LOCAL or bgqueryType == BGQUERY_LOCAL then
			if DsRGuildPvPcyro.state.keeps[keepId] ~= nil then
				DsRGuildPvPcyro.state.keeps[keepId].objectives = DsRGuildPvPcyro.state.keeps[keepId].objectives or {}
				if DsRGuildPvPcyro.state.keeps[keepId].objectives[1] == nil then
					DsRGuildPvPcyro.state.keeps[keepId].objectives[1] = {}
					DsRGuildPvPcyro.state.keeps[keepId].objectives[1].id = objectiveId
					DsRGuildPvPcyro.state.keeps[keepId].objectives[1].state = 100
					DsRGuildPvPcyro.state.keeps[keepId].objectives[1].holdingAlliance = DsRGuildPvPcyro.state.keeps[keepId].owningAlliance
				elseif DsRGuildPvPcyro.state.keeps[keepId].objectives[2] == nil then
					DsRGuildPvPcyro.state.keeps[keepId].objectives[2] = {}
					DsRGuildPvPcyro.state.keeps[keepId].objectives[2].id = objectiveId
					DsRGuildPvPcyro.state.keeps[keepId].objectives[2].state = 100
					DsRGuildPvPcyro.state.keeps[keepId].objectives[2].holdingAlliance = DsRGuildPvPcyro.state.keeps[keepId].owningAlliance
				end
			elseif DsRGuildPvPcyro.state.resources[keepId] ~= nil then
				DsRGuildPvPcyro.state.resources[keepId].objectives = DsRGuildPvPcyro.state.resources[keepId].objectives or {}
				DsRGuildPvPcyro.state.resources[keepId].objectives[1] = {}
				DsRGuildPvPcyro.state.resources[keepId].objectives[1].id = objectiveId
				DsRGuildPvPcyro.state.resources[keepId].objectives[1].state = 100
				DsRGuildPvPcyro.state.resources[keepId].objectives[1].holdingAlliance = DsRGuildPvPcyro.state.resources[keepId].owningAlliance
			elseif DsRGuildPvPcyro.state.outposts[keepId] ~= nil then
				DsRGuildPvPcyro.state.outposts[keepId].objectives = DsRGuildPvPcyro.state.outposts[keepId].objectives or {}
				if DsRGuildPvPcyro.state.outposts[keepId].objectives[1] == nil then
					DsRGuildPvPcyro.state.outposts[keepId].objectives[1] = {}
					DsRGuildPvPcyro.state.outposts[keepId].objectives[1].id = objectiveId
					DsRGuildPvPcyro.state.outposts[keepId].objectives[1].state = 100
					DsRGuildPvPcyro.state.outposts[keepId].objectives[1].holdingAlliance = DsRGuildPvPcyro.state.outposts[keepId].owningAlliance
				else
					DsRGuildPvPcyro.state.outposts[keepId].objectives[2] = {}
					DsRGuildPvPcyro.state.outposts[keepId].objectives[2].id = objectiveId
					DsRGuildPvPcyro.state.outposts[keepId].objectives[2].state = 100
					DsRGuildPvPcyro.state.outposts[keepId].objectives[2].holdingAlliance = DsRGuildPvPcyro.state.outposts[keepId].owningAlliance
				end
			elseif DsRGuildPvPcyro.state.villages[keepId] ~= nil then
				DsRGuildPvPcyro.state.villages[keepId].objectives = DsRGuildPvPcyro.state.villages[keepId].objectives or {}
				if DsRGuildPvPcyro.state.villages[keepId].objectives[1] == nil then
					DsRGuildPvPcyro.state.villages[keepId].objectives[1] = {}
					DsRGuildPvPcyro.state.villages[keepId].objectives[1].id = objectiveId
					DsRGuildPvPcyro.state.villages[keepId].objectives[1].state = 100
					DsRGuildPvPcyro.state.villages[keepId].objectives[1].holdingAlliance = DsRGuildPvPcyro.state.villages[keepId].owningAlliance
				elseif DsRGuildPvPcyro.state.villages[keepId].objectives[2] == nil then
					DsRGuildPvPcyro.state.villages[keepId].objectives[2] = {}
					DsRGuildPvPcyro.state.villages[keepId].objectives[2].id = objectiveId
					DsRGuildPvPcyro.state.villages[keepId].objectives[2].state = 100
					DsRGuildPvPcyro.state.villages[keepId].objectives[2].holdingAlliance = DsRGuildPvPcyro.state.villages[keepId].owningAlliance
				else
					DsRGuildPvPcyro.state.villages[keepId].objectives[3] = {}
					DsRGuildPvPcyro.state.villages[keepId].objectives[3].id = objectiveId
					DsRGuildPvPcyro.state.villages[keepId].objectives[3].state = 100
					DsRGuildPvPcyro.state.villages[keepId].objectives[3].holdingAlliance = DsRGuildPvPcyro.state.villages[keepId].owningAlliance
				end
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.ResetObjective(keeps)
	for key, keep in pairs(keeps) do
		if keep.objectives ~= nil then
			for i = 1, #keep.objectives do
				keep.objectives[i].state = 100
				keep.objectives[i].holdingAlliance = keep.owningAlliance
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.ResetObjectives()
	DsRGuildPvPcyro.ResetObjective(DsRGuildPvPcyro.state.keeps)
	DsRGuildPvPcyro.ResetObjective(DsRGuildPvPcyro.state.outposts)
	DsRGuildPvPcyro.ResetObjective(DsRGuildPvPcyro.state.resources)
	DsRGuildPvPcyro.ResetObjective(DsRGuildPvPcyro.state.villages)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.GetResources()
	return DsRGuildPvPcyro.state.resources
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.GetKeeps()
	return DsRGuildPvPcyro.state.keeps
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.GetOutposts()
	return DsRGuildPvPcyro.state.outposts
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.GetVillages()
	return DsRGuildPvPcyro.state.villages
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.GetDestructibles()
	return DsRGuildPvPcyro.state.destructibles
end

function DsRGuildPvPcyro.GetTemples()
	return DsRGuildPvPcyro.state.temples
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.InitState()
	local gameTime = GetGameTimeMilliseconds()
	DsRGuildPvPcyro.InitResources(gameTime)
	DsRGuildPvPcyro.InitKeeps(gameTime)
	DsRGuildPvPcyro.InitOutposts(gameTime)
	DsRGuildPvPcyro.InitVillages(gameTime)
	DsRGuildPvPcyro.InitDestructibles(gameTime)
	DsRGuildPvPcyro.InitTemples(gameTime)
	DsRGuildPvPcyro.AddObjectives()
	DsRGuildPvPcyro.InitScrolls()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.InitScrolls()
	DsRGuildPvPcyro.state.scrolls = {}
	for key, scrollKeep in pairs(DsRGuildPvPcyro.state.temples) do
		local scroll = {}
		scroll.id = GetKeepArtifactObjectiveId(key)
		local name, _, _ = GetObjectiveInfo(key, scroll.id, BGQUERY_LOCAL)
		scroll.name = zo_strformat("<<1>>", name)
		scroll.alliance = GetKeepAlliance(key, BGQUERY_LOCAL)
		table.insert(DsRGuildPvPcyro.state.scrolls, scroll)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.GetItemsOfInterest()
	return DsRGuildPvPcyro.state.itemsOfInterest
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.UpdateItemsOfInterest(itemsOfInterest)
	DsRGuildPvPcyro.state.itemsOfInterest = itemsOfInterest
	DsRGuildPvPcyro.NotifyUpdateConsumers(itemsOfInterest)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.GetItemByKeepId(keepId)
	if keepId ~= nil then
		if DsRGuildPvPcyro.state.resources[keepId] ~= nil then
			return DsRGuildPvPcyro.state.resources[keepId]
		elseif DsRGuildPvPcyro.state.keeps[keepId] ~= nil then
			return DsRGuildPvPcyro.state.keeps[keepId]
		elseif DsRGuildPvPcyro.state.outposts[keepId] ~= nil then
			return DsRGuildPvPcyro.state.outposts[keepId]
		elseif DsRGuildPvPcyro.state.villages[keepId] ~= nil then
			return DsRGuildPvPcyro.state.villages[keepId]
		elseif DsRGuildPvPcyro.state.temples[keepId] ~= nil then
			return DsRGuildPvPcyro.state.temples[keepId]
		end
	end
	return nil
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.UpdateItem(items, gameTime)
	local itemsOfInterest = {}
	for key, item in pairs(items) do
		local itemOfInterest = false
		local previousOwningAlliance = item.owningAlliance
		item.owningAlliance = GetKeepAlliance(key, BGQUERY_LOCAL)
		if item.previousOwningAllianceTimestamp == nil or item.previousOwningAllianceTimestamp + DsRGuildPvPcyro.config.previousOwnerThreshold < gameTime then
			item.previousOwningAlliance = previousOwningAlliance
			item.previousOwningAllianceTimestamp = gameTime
		end
		local previousAttackState = item.isUnderAttack
		item.isUnderAttack = GetKeepUnderAttack(key,  BGQUERY_LOCAL)
		item.underAttackFor = 0
		item.isCoolingDown = true
		
		if item.owningAlliance ~= previousOwningAlliance and DsRGuildPvPcyro.state.destructibles[key] == nil then
			itemOfInterest = true
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
			eventData.event = DsRGuildPvPcyro.constants.events.KEEP_OWNER_CHANGED
			eventData.keepId = key
			eventData.keepName = zo_strformat("<<1>>", GetKeepName(key))
			eventData.alliance = item.owningAlliance
			eventData.previousOwningAlliance = previousOwningAlliance
			DsRGuildPvPcyro.NotifyMessageConsumers(eventData)
		end
		if previousAttackState == false and item.isUnderAttack == true then
			--throw isUaMessage
			local eventData = {}
			eventData.event = DsRGuildPvPcyro.constants.events.STATUS_UA
			eventData.keepId = key
			eventData.keepName = zo_strformat("<<1>>", GetKeepName(key))
			eventData.alliance = item.owningAlliance
			eventData.previousOwningAlliance = previousOwningAlliance
			DsRGuildPvPcyro.NotifyMessageConsumers(eventData)
			if item.attackStatusLostAt ~= 0 and item.attackStatusLostAt + DsRGuildPvPcyro.config.siegeTimeout < gameTime then
				item.underAttackSince = gameTime
			end
		elseif previousAttackState == true and item.isUnderAttack == false then
			--throw isUaLostMessage
			local eventData = {}
			eventData.event = DsRGuildPvPcyro.constants.events.STATUS_UA_LOST
			eventData.keepId = key
			eventData.keepName = zo_strformat("<<1>>", GetKeepName(key))
			eventData.alliance = item.owningAlliance
			eventData.previousOwningAlliance = previousOwningAlliance
			DsRGuildPvPcyro.NotifyMessageConsumers(eventData)
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
			if item.attackStatusLostAt ~= 0 and item.attackStatusLostAt + DsRGuildPvPcyro.config.siegeTimeout > gameTime then
				itemOfInterest = true
				--d("not under attack")
				if item.interestingSince == nil then
					item.interestingSince = gameTime
				end
				item.underAttackFor = gameTime - item.interestingSince
			end
		end
		if DsRGuildPvPcyro.state.destructibles[key] == nil then
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
			elseif item.lastSiegeWeaponSeen ~= nil and item.lastSiegeWeaponSeen + DsRGuildPvPcyro.config.siegeTimeout > gameTime then
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

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.AdjustItemsOfInterest(oldItems, newItems)
	if newItems ~= nil then
		for i = 1, #newItems do
			table.insert(oldItems, newItems[i])
		end
	end
	return oldItems
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.SortItemsOfInterest(itemA, itemB)
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
			return false
		end
	end
	return false
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.GetFlagStatePercent(state, owningAlliance, holdingAlliance)
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

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.GetFlipConstant(keepType)
	if keepType == KEEPTYPE_KEEP then
		return DsRGuildPvPcyro.constants.flipTimes.KEEP
	elseif keepType == KEEPTYPE_OUTPOST then
		return DsRGuildPvPcyro.constants.flipTimes.OUTPOST
	elseif keepType == KEEPTYPE_RESOURCE then
		return DsRGuildPvPcyro.constants.flipTimes.RESOURCE
	else
		return 0
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.FlagsAtFlipState(objectives, owningAlliance)
	local flips = false
	if objectives ~= nil then
		local flipedFlags = 0
		for i = 1, #objectives do
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

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.AdjustKeepFlipping(keep)
	local flipTime = DsRGuildPvPcyro.GetFlipConstant(keep.keepType)
	if flipTime > 0 then
		if keep.flipsAt == nil and DsRGuildPvPcyro.FlagsAtFlipState(keep.objectives, keep.owningAlliance) == true then
			keep.flipsAt = GetGameTimeMilliseconds() + flipTime
		elseif keep.flipsAt ~= nil and DsRGuildPvPcyro.FlagsAtFlipState(keep.objectives, keep.owningAlliance) == true then
		else
			keep.flipsAt = nil
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.GetScrollAlliance(artifactName)
	local alliance = 0
	for i = 1, #DsRGuildPvPcyro.state.scrolls do
		if DsRGuildPvPcyro.state.scrolls[i].name == artifactName then
			alliance = DsRGuildPvPcyro.state.scrolls[i].alliance
			break
		end
	end
	return alliance
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.AdjustCoordinates(keeps)
	if keeps ~= nil then
		for key, keep in pairs(keeps) do
			local _, x, y = GetKeepPinInfo(key, BGQUERY_LOCAL)
			keep.x = x
			keep.y = y
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.AdjustKeepCoordinates()
	DsRGuildPvPcyro.AdjustCoordinates(DsRGuildPvPcyro.state.keeps)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.AdjustOutpostCoordinates()
	DsRGuildPvPcyro.AdjustCoordinates(DsRGuildPvPcyro.state.outposts)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.AdjustVillageCoordinates()
	DsRGuildPvPcyro.AdjustCoordinates(DsRGuildPvPcyro.state.villages)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.TempDebugPrint(name, value)
	-- d(name .. value)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
--callbacks
function DsRGuildPvPcyro.OnPlayerActivated()
	if DsRGuildPvPstatus.IsInCyrodiil() == true then
		if DsRGuildPvPcyro.state.initializedItems == false then
			DsRGuildPvPcyro.InitState()
			DsRGuildPvPcyro.state.initializedItems = true
		end
		if DsRGuildPvPcyro.state.registredConsumers == false and #DsRGuildPvPcyro.state.consumers > 0 then
			
			DsRGuildPvPcyro.state.registredConsumers = true
			DsRGuildPvPcyro.state.campaignId = GetCurrentCampaignId()
			EVENT_MANAGER:RegisterForEvent(DsRGuildPvPcyro.callbackName, EVENT_GUILD_CLAIM_KEEP_CAMPAIGN_NOTIFICATION, DsRGuildPvPcyro.OnGuildClaimKeepCampaignNotification)
			EVENT_MANAGER:RegisterForEvent(DsRGuildPvPcyro.callbackName, EVENT_GUILD_LOST_KEEP_CAMPAIGN_NOTIFICATION, DsRGuildPvPcyro.OnGuildLostKeepCampaignNotification)
			EVENT_MANAGER:RegisterForEvent(DsRGuildPvPcyro.callbackName, EVENT_OBJECTIVE_CONTROL_STATE, DsRGuildPvPcyro.OnObjectiveControlState)
			EVENT_MANAGER:RegisterForEvent(DsRGuildPvPcyro.callbackName, EVENT_ARTIFACT_CONTROL_STATE, DsRGuildPvPcyro.OnScrollState)
			EVENT_MANAGER:RegisterForEvent(DsRGuildPvPcyro.callbackName, EVENT_CORONATE_EMPEROR_NOTIFICATION , DsRGuildPvPcyro.OnCoronateEmperorNotification)
			EVENT_MANAGER:RegisterForEvent(DsRGuildPvPcyro.callbackName, EVENT_DEPOSE_EMPEROR_NOTIFICATION , DsRGuildPvPcyro.OnDeposeEmperorNotification)
			EVENT_MANAGER:RegisterForEvent(DsRGuildPvPcyro.callbackName, EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED, DsRGuildPvPcyro.OnDaedricArtifactObjectiveStateChanged)
			EVENT_MANAGER:RegisterForEvent(DsRGuildPvPcyro.callbackName, EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED, DsRGuildPvPcyro.OnDaedricArtifactObjectiveSpawnedButNoRevealed)
			EVENT_MANAGER:RegisterForUpdate(DsRGuildPvPcyro.callbackName, DsRGuildPvPcyro.config.updateInterval, DsRGuildPvPcyro.CyroUpdateLoop)
		end
		if #DsRGuildPvPcyro.state.consumers > 0 then
			DsRGuildPvPcyro.ResetObjectives()
		end
	else
		if DsRGuildPvPcyro.state.registredConsumers == true then
			EVENT_MANAGER:UnregisterForEvent(DsRGuildPvPcyro.callbackName, EVENT_ARTIFACT_CONTROL_STATE)
			EVENT_MANAGER:UnregisterForEvent(DsRGuildPvPcyro.callbackName, EVENT_OBJECTIVE_CONTROL_STATE)
			EVENT_MANAGER:UnregisterForEvent(DsRGuildPvPcyro.callbackName, EVENT_GUILD_CLAIM_KEEP_CAMPAIGN_NOTIFICATION)
			EVENT_MANAGER:UnregisterForEvent(DsRGuildPvPcyro.callbackName, EVENT_GUILD_LOST_KEEP_CAMPAIGN_NOTIFICATION)
			EVENT_MANAGER:UnregisterForEvent(DsRGuildPvPcyro.callbackName, EVENT_CORONATE_EMPEROR_NOTIFICATION)
			EVENT_MANAGER:UnregisterForEvent(DsRGuildPvPcyro.callbackName, EVENT_DEPOSE_EMPEROR_NOTIFICATION)
			EVENT_MANAGER:UnregisterForEvent(DsRGuildPvPcyro.callbackName, EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(DsRGuildPvPcyro.callbackName, EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED)
			EVENT_MANAGER:UnregisterForUpdate(DsRGuildPvPcyro.callbackName)
			DsRGuildPvPcyro.state.registredConsumers = false
			DsRGuildPvPcyro.state.campaignId = 0
		end
		DsRGuildPvPcyro.state.initializedItems = false
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.CyroUpdateLoop()
	if DsRGuildPvPstatus.IsInCyrodiil() == true then
		local itemsOfInterest = {}
		local gameTime = GetGameTimeMilliseconds()
		itemsOfInterest = DsRGuildPvPcyro.AdjustItemsOfInterest(itemsOfInterest, DsRGuildPvPcyro.UpdateItem(DsRGuildPvPcyro.state.resources, gameTime))
		itemsOfInterest = DsRGuildPvPcyro.AdjustItemsOfInterest(itemsOfInterest, DsRGuildPvPcyro.UpdateItem(DsRGuildPvPcyro.state.keeps, gameTime))
		itemsOfInterest = DsRGuildPvPcyro.AdjustItemsOfInterest(itemsOfInterest, DsRGuildPvPcyro.UpdateItem(DsRGuildPvPcyro.state.outposts, gameTime))
		itemsOfInterest = DsRGuildPvPcyro.AdjustItemsOfInterest(itemsOfInterest, DsRGuildPvPcyro.UpdateItem(DsRGuildPvPcyro.state.villages, gameTime))
		itemsOfInterest = DsRGuildPvPcyro.AdjustItemsOfInterest(itemsOfInterest, DsRGuildPvPcyro.UpdateItem(DsRGuildPvPcyro.state.destructibles, gameTime))
		itemsOfInterest = DsRGuildPvPcyro.AdjustItemsOfInterest(itemsOfInterest, DsRGuildPvPcyro.UpdateItem(DsRGuildPvPcyro.state.temples, gameTime))
		if #itemsOfInterest > 1 then
			table.sort(itemsOfInterest, DsRGuildPvPcyro.SortItemsOfInterest)
		end
		DsRGuildPvPcyro.UpdateItemsOfInterest(itemsOfInterest)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.OnGuildClaimKeepCampaignNotification(eventCode, campaignId, keepId, guildName, playerName)
	if DsRGuildPvPcyro.state.campaignId == campaignId then
		local eventData = {}
		eventData.event = DsRGuildPvPcyro.constants.events.GUILD_CLAIM
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
		DsRGuildPvPcyro.NotifyMessageConsumers(eventData)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.OnGuildLostKeepCampaignNotification(eventCode, campaignId, keepId, guildName)
	if DsRGuildPvPcyro.state.campaignId == campaignId then
		local eventData = {}
		eventData.event = DsRGuildPvPcyro.constants.events.GUILD_LOST
		eventData.keepName = zo_strformat("<<1>>", GetKeepName(keepId))
		eventData.keepId = keepId
		eventData.guildName = guildName
		local item = DsRGuildPvPcyro.GetItemByKeepId(keepId)
		local alliance = GetKeepAlliance(keepId, BGQUERY_LOCAL)
		if alliance ~= nil then
			eventData.alliance = alliance
		else
			eventData.alliance = 0
		end
		local item = DsRGuildPvPcyro.state.resources[keepId] or DsRGuildPvPcyro.state.keeps[keepId] or DsRGuildPvPcyro.state.outposts[keepId] or DsRGuildPvPcyro.state.villages[keepId]
		if item ~= nil and item.previousOwningAlliance ~= nil then
			eventData.previousOwningAlliance = item.previousOwningAlliance
		else
			eventData.previousOwningAlliance = 0
		end
		DsRGuildPvPcyro.NotifyMessageConsumers(eventData)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.OnObjectiveControlState(eventCode, keepId, objectiveId, battlegroundContext, objectiveName, objectiveType, objectiveControlEvent, objectiveControlState, holdingAlliance, attackingAlliance, pinType)
	local keep = DsRGuildPvPcyro.GetItemByKeepId(keepId)
	if keep ~= nil then
		local objectives = keep.objectives
		local objective = nil
		if objectives == nil then
			DsRGuildPvPcyro.AddObjectives()
		end
		if objectives ~= nil then
			for i = 1, #objectives do
				if objectives[i].id == objectiveId then
					objective = objectives[i]
					break
				end
			end
		else
			DsRGuildPvPcyro.TempDebugPrint("OnObjectiveControlState objectives", "nil")
		end
		if objective ~= nil then
			objective.holdingAlliance = holdingAlliance
			if objective.holdingAlliance == 0 then
				objective.holdingAlliance = attackingAlliance
			end
			objective.state = DsRGuildPvPcyro.GetFlagStatePercent(objectiveControlState, keep.owningAlliance, holdingAlliance)
			DsRGuildPvPcyro.AdjustKeepFlipping(keep)
			DsRGuildPvPcyro.UpdateItemsOfInterest(DsRGuildPvPcyro.state.itemsOfInterest)
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.OnApUpdate(eventCode, alliancePoints, playSound, difference, reason, keepId)
	if reason == CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD then
		local eventData = {}
		eventData.event = DsRGuildPvPcyro.constants.events.TICK_DEFENSE
		eventData.keepName = zo_strformat("<<1>>", GetKeepName(keepId))
		eventData.keepId = keepId
		eventData.apGained = difference
		local alliance = GetKeepAlliance(keepId, BGQUERY_LOCAL)
		if alliance ~= nil then
			eventData.alliance = alliance
		else
			eventData.alliance = 0
		end
		DsRGuildPvPcyro.NotifyMessageConsumers(eventData)
	elseif reason == CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD then
		local eventData = {}
		eventData.event = DsRGuildPvPcyro.constants.events.TICK_OFFENSE
		eventData.keepName = zo_strformat("<<1>>", GetKeepName(keepId))
		eventData.keepId = keepId
		eventData.apGained = difference
		local alliance = GetUnitAlliance("player")
		if alliance ~= nil then
			eventData.alliance = alliance
		else
			eventData.alliance = 0
		end
		DsRGuildPvPcyro.NotifyMessageConsumers(eventData)
	elseif reason == CURRENCY_CHANGE_REASON_QUESTREWARD then
		local eventData = {}
		eventData.event = DsRGuildPvPcyro.constants.events.QUEST_REWARD
		eventData.apGained = difference
		DsRGuildPvPcyro.NotifyMessageConsumers(eventData)
	elseif reason == CURRENCY_CHANGE_REASON_BATTLEGROUND then
		local eventData = {}
		eventData.event = DsRGuildPvPcyro.constants.events.BATTLEGROUND_REWARD
		eventData.apGained = difference
		DsRGuildPvPcyro.NotifyMessageConsumers(eventData)
	elseif reason == CURRENCY_CHANGE_REASON_MEDAL then
		local eventData = {}
		eventData.event = DsRGuildPvPcyro.constants.events.BATTLEGROUND_MEDAL_REWARD
		eventData.apGained = difference
		DsRGuildPvPcyro.NotifyMessageConsumers(eventData)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.OnScrollState(eventCode, artifactName, keepId, characterName, playerAlliance, objectiveControlEvent, objectiveControlState, campaignId, displayName)
	if DsRGuildPvPcyro.state.campaignId == campaignId then
		artifactName = zo_strformat("<<1>>", artifactName)
		if objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_DROPPED then
			local eventData = {}
			eventData.event = DsRGuildPvPcyro.constants.events.SCROLL_DROPPED
			eventData.charName = characterName
			eventData.displayName = displayName
			eventData.playerAlliance = playerAlliance
			eventData.scrollAlliance = DsRGuildPvPcyro.GetScrollAlliance(artifactName)
			eventData.scroll = artifactName
			DsRGuildPvPcyro.NotifyMessageConsumers(eventData)
		elseif objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_TAKEN then
			local eventData = {}
			eventData.event = DsRGuildPvPcyro.constants.events.SCROLL_PICKED_UP
			eventData.charName = characterName
			eventData.displayName = displayName
			eventData.playerAlliance = playerAlliance
			eventData.scrollAlliance = DsRGuildPvPcyro.GetScrollAlliance(artifactName)
			eventData.scroll = artifactName
			DsRGuildPvPcyro.NotifyMessageConsumers(eventData)
		elseif objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_RETURNED then
			local eventData = {}
			eventData.event = DsRGuildPvPcyro.constants.events.SCROLL_RETURNED
			eventData.charName = characterName
			eventData.displayName = displayName
			eventData.playerAlliance = playerAlliance
			eventData.scrollAlliance = DsRGuildPvPcyro.GetScrollAlliance(artifactName)
			eventData.scroll = artifactName
			DsRGuildPvPcyro.NotifyMessageConsumers(eventData)
		elseif objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_RETURNED_BY_TIMER then
			local eventData = {}
			eventData.event = DsRGuildPvPcyro.constants.events.SCROLL_RETURNED_BY_TIMER
			eventData.scroll = artifactName
			eventData.scrollAlliance = DsRGuildPvPcyro.GetScrollAlliance(artifactName)
			DsRGuildPvPcyro.NotifyMessageConsumers(eventData)
		elseif objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_CAPTURED then
			local eventData = {}
			eventData.event = DsRGuildPvPcyro.constants.events.SCROLL_CAPTURED
			eventData.charName = characterName
			eventData.displayName = displayName
			eventData.playerAlliance = playerAlliance
			eventData.scrollAlliance = DsRGuildPvPcyro.GetScrollAlliance(artifactName)
			eventData.scroll = artifactName
			eventData.keepId = keepId
			eventData.keepName = zo_strformat("<<1>>", GetKeepName(keepId))
			DsRGuildPvPcyro.NotifyMessageConsumers(eventData)
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.OnCoronateEmperorNotification(eventCode, campaignId, characterName, emperorAlliance, displayName)
	if DsRGuildPvPcyro.state.campaignId == campaignId then
		local eventData = {}
		eventData.event = DsRGuildPvPcyro.constants.events.EMPEROR_CORONATED
		eventData.charName = characterName
		eventData.displayName = displayName
		eventData.alliance = emperorAlliance
		DsRGuildPvPcyro.NotifyMessageConsumers(eventData)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.OnDeposeEmperorNotification(eventCode, campaignId, characterName, emperorAlliance, abdication, displayName)
	if DsRGuildPvPcyro.state.campaignId == campaignId then
		local eventData = {}
		eventData.event = DsRGuildPvPcyro.constants.events.EMPEROR_DEPOSED
		eventData.charName = characterName
		eventData.displayName = displayName
		eventData.alliance = emperorAlliance
		eventData.abdication = abdication
		DsRGuildPvPcyro.NotifyMessageConsumers(eventData)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- VOLENDRUNG
function DsRGuildPvPcyro.OnDaedricArtifactObjectiveSpawnedButNoRevealed(eventCode, daedricArtifactId)
	local actVolIcon  = zo_iconFormat("/esoui/art/hud/volendrung/daedricartifact_volendrung_single.dds", 34, 34)
	local VolNeu  	  = zo_iconFormat("/esoui/art/mappins/ava_daedricartifact_volendrung_neutral.dds", 26, 26)
	
	local rootControl = DsRGuildPvPstatus.controls.TLW.rootControl
	rootControl.Volendrung:SetText(actVolIcon .. "  " .. VolNeu .. GetString(DsRGuildPvP_VolendrungACT))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPcyro.OnDaedricArtifactObjectiveStateChanged(eventCode, objectiveKeepId, objectiveObjectiveId, battlegroundContext, objectiveControlEvent, objectiveControlState, holderAlliance, lastHolderAlliance, holderRawCharacterName, holderDisplayName, lastHolderRawCharacterName, lastHolderDisplayName, pinType, daedricArtifactId)
	local ColorAD 		 = GetAllianceColor(1):GetBright() 			   -- 1 = Aldmeri
	local ColorEP 		 = GetAllianceColor(2):GetBright() 			   -- 2 = Ebenerz
	local ColorDC 		 = GetAllianceColor(3):GetBright() 			   -- 3 = Dolchsturz

	local defVolIcon = zo_iconFormat("/esoui/art/hud/volendrung/daedricartifact_volendrung_empty.dds", 34, 34)
	local actVolIcon = zo_iconFormat("/esoui/art/hud/volendrung/daedricartifact_volendrung_single.dds", 34, 34)

	local VolNeu  = zo_iconFormat("/esoui/art/mappins/ava_daedricartifact_volendrung_neutral.dds", 26, 26)
	local VolDC   = zo_iconFormat("/esoui/art/mappins/ava_daedricartifact_volendrung_daggerfall.dds", 26, 26)
	local VolEP   = zo_iconFormat("/esoui/art/mappins/ava_daedricartifact_volendrung_ebonheart.dds", 26, 26)
	local VolAD   = zo_iconFormat("/esoui/art/mappins/ava_daedricartifact_volendrung_aldmeri.dds", 26, 26)

	local rootControl = DsRGuildPvPstatus.controls.TLW.rootControl
		
	if IsInCampaign() then
		if objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_SPAWNED then -- Volendrung Enthüllt
			rootControl.Volendrung:SetText(actVolIcon .. "  " .. VolNeu .. GetString(DsRGuildPvP_VolendrungRELEAVED))
		elseif objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_DROPPED then -- Volendrung fallen gelassen
			rootControl.Volendrung:SetText(actVolIcon .. "  " .. VolNeu .. GetString(DsRGuildPvP_VolendrungDROPPED))
		elseif objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_TAKEN then -- Volendrung genommen
			if holderAlliance == 1 then
				rootControl.Volendrung:SetText(actVolIcon .. "  " .. VolAD .. " " .. ColorAD:Colorize(GetString(DsR_Aldmeri)))
			elseif holderAlliance == 2 then
				rootControl.Volendrung:SetText(actVolIcon .. "  " .. VolEP .. " " .. ColorEP:Colorize(GetString(DsR_Ebonheart)))
			elseif holderAlliance == 3 then
				rootControl.Volendrung:SetText(actVolIcon .. "  " .. VolDC .. " " .. ColorDC:Colorize(GetString(DsR_Daggerfall)))
			end
		elseif objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_ITERATION_END then  -- Volendrung vernichtet
			rootControl.Volendrung:SetText(defVolIcon .. GetString(DsRGuildPvP_VolendrungInACT))
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Stats, Points
function DsRGuildPvPcyro.PvPStandStats()
	-- local campaignID = GetAssignedCampaignId()
	local campaignID = GetCurrentCampaignId()

	for campaignIndex = 1, GetNumSelectionCampaigns() do 
		if campaignID == GetSelectionCampaignId(campaignIndex) then 
			campaignIDX = campaignIndex
		end
	end

	local ColorAD = GetAllianceColor(1):GetBright() -- 1 = Aldmeri
	local ColorEP = GetAllianceColor(2):GetBright() -- 2 = Ebenerz
	local ColorDC = GetAllianceColor(3):GetBright() -- 3 = Dolchsturz

	-- Points
    DsRGuildPvPcyro.ad_points = GetCampaignAlliancePotentialScore(campaignID, ALLIANCE_ALDMERI_DOMINION)
    DsRGuildPvPcyro.dc_points = GetCampaignAlliancePotentialScore(campaignID, ALLIANCE_DAGGERFALL_COVENANT)
    DsRGuildPvPcyro.ep_points = GetCampaignAlliancePotentialScore(campaignID, ALLIANCE_EBONHEART_PACT)

	local ADpoints = ColorAD:Colorize("+" .. DsRGuildPvPcyro.ad_points)
	local EPpoints = ColorEP:Colorize("+" .. DsRGuildPvPcyro.ep_points)
	local DCpoints = ColorDC:Colorize("+" .. DsRGuildPvPcyro.dc_points)

	-- Population
	DsRGuildPvPcyro.ad_pop = GetSelectionCampaignPopulationData(campaignIDX, ALLIANCE_ALDMERI_DOMINION)
    DsRGuildPvPcyro.dc_pop = GetSelectionCampaignPopulationData(campaignIDX, ALLIANCE_DAGGERFALL_COVENANT)
    DsRGuildPvPcyro.ep_pop = GetSelectionCampaignPopulationData(campaignIDX, ALLIANCE_EBONHEART_PACT)

	local ADpopulate = ColorAD:Colorize(zo_iconFormatInheritColor(ZO_CampaignBrowser_GetPopulationIcon(DsRGuildPvPcyro.ad_pop), 26, 26))
	local DCpopulate = ColorDC:Colorize(zo_iconFormatInheritColor(ZO_CampaignBrowser_GetPopulationIcon(DsRGuildPvPcyro.dc_pop), 26, 26))
	local EPpopulate = ColorEP:Colorize(zo_iconFormatInheritColor(ZO_CampaignBrowser_GetPopulationIcon(DsRGuildPvPcyro.ep_pop), 26, 26))

	-- Timer for update
	time   = DsRGuildPvPcyro.formatTime(GetSecondsUntilCampaignScoreReevaluation(campaignID), true, false)

	return time, ADpoints, EPpoints, DCpoints, ADpopulate, DCpopulate, EPpopulate
end

