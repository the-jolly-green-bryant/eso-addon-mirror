
local Utils = FasterTravel.Utils

local Campaign = {}

local ZONE_INDEX_CYRODIIL = FasterTravel.Location.Data.ZONE_INDEX_CYRODIIL

local _campaignIcons = {
	home = "EsoUI/Art/Campaign/campaignBrowser_homeCampaign.dds",
	guest = "EsoUI/Art/Campaign/campaignBrowser_guestCampaign.dds",
	joining = "EsoUI/Art/Campaign/campaignBrowser_queued.dds",
	ready = "EsoUI/Art/Campaign/campaignBrowser_ready.dds"
}

local _populationFactionIcons = {
	"EsoUI/Art/Campaign/campaignBrowser_columnHeader_AD.dds",
	"EsoUI/Art/Campaign/campaignBrowser_columnHeader_EP.dds",
	"EsoUI/Art/Campaign/campaignBrowser_columnHeader_DC.dds"
}

local _populationFactionColors = {
function() return GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE,ALLIANCE_ALDMERI_DOMINION) end ,
function() return GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE,ALLIANCE_EBONHEART_PACT) end ,
function() return GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE,ALLIANCE_DAGGERFALL_COVENANT) end
}



local _alliances = {1,2,3}

local function GetSelectionCampaignPopulation(index)
	return Utils.map(_alliances,function(i)
		return GetSelectionCampaignPopulationData(index, i)
	end)
end 

local function GetSelectionCampaignTimesTable(index)
	local start,finish = GetSelectionCampaignTimes(index)
	return {start=start,finish=finish}
end


local function GetCampaignScores(id)

	local keepScore, resourceValue, outpostValue, defensiveScrollValue, offensiveScrollValue = GetCampaignHoldingScoreValues(id)
	local underdogLeaderAlliance = GetCampaignUnderdogLeaderAlliance(id)
	
	return Utils.map(_alliances,function(i)
		
		local score = GetCampaignAllianceScore(id, i)
        local keeps = GetTotalCampaignHoldings(id, HOLDINGTYPE_KEEP, i)
        local resources = GetTotalCampaignHoldings(id, HOLDINGTYPE_RESOURCE, i)
        local outposts = GetTotalCampaignHoldings(id, HOLDINGTYPE_OUTPOST, i)
        local defensiveScrolls = GetTotalCampaignHoldings(id, HOLDINGTYPE_DEFENSIVE_ARTIFACT, i)
        local offensiveScrolls = GetTotalCampaignHoldings(id, HOLDINGTYPE_OFFENSIVE_ARTIFACT, i)
        local potentialScore = GetCampaignAlliancePotentialScore(id, i)
        local isUnderpop = IsUnderpopBonusEnabled(id, i)

		return {
            alliance = i,
            score = score,
            keeps = keeps,
            resources = resources,
            outposts = outposts,
			offensiveScrolls = offensiveScrolls,
			defensiveScrolls = defensiveScrolls,
            scrolls = defensiveScrolls + offensiveScrolls,
            potentialScore = potentialScore,
            isUnderdog = underdogLeaderAlliance ~= 0 and underdogLeaderAlliance ~= i,
            isUnderpop = isUnderpop,
        }
	
	end)
  
end

local function GetCampaignNodeInfo(id)
	if id == nil or id == 0 then return nil end 
	local rulesetId = GetCampaignRulesetId(id)
    local rulesetType = GetCampaignRulesetType(rulesetId)
	local rulesetName = GetCampaignRulesetName(rulesetId)
	local rulesetDesc = GetCampaignRulesetDescription(rulesetId)
	
	local node = { 
			id=id,
			name = zo_strformat(SI_CAMPAIGN_NAME, GetCampaignName(id)),
			group = GetNumSelectionCampaignGroupMembers(i),
			friends = GetNumSelectionCampaignFriends(i),
			guildies = GetNumSelectionCampaignGuildMembers(i),
			nodeIndex = id,
			zoneIndex = ZONE_INDEX_CYRODIIL,
			assigned = GetAssignedCampaignId() == id,
			guest = GetGuestCampaignId() == id,
			home = GetAssignedCampaignId() == id,
			isCampaign = true,
			rulesetId = rulesetId,
			rulesetType = rulesetType,
			rulesetName = rulesetName,
			rulesetDesc = rulesetDesc,
			scores = GetCampaignScores(id)
		}
		
	return node 
end

local function UpdateWithSelectionCampainScores(index,scores)
	
	local underdogLeaderAlliance = GetSelectionCampaignUnderdogLeaderAlliance(index)

	return Utils.map(_alliances,function(i)
		local s = scores[i]
		s.score = GetSelectionCampaignAllianceScore(index,i)
		s.isUnderdog = underdogLeaderAlliance ~= 0 and underdogLeaderAlliance ~= i
		return s
	end)
end

local function GetCampaignLookup()

	local count = GetNumSelectionCampaigns()
	
	local lookup = {}
	
	local id 
	
	local node 
	
	for i=1,count do 
		
		id = GetSelectionCampaignId(i)
		
		node = GetCampaignNodeInfo(id)
		
		node.population = GetSelectionCampaignPopulation(i)
		
		node.times = GetSelectionCampaignTimesTable(i)
		
		UpdateWithSelectionCampainScores(i,node.scores)
		
		lookup[id] = node
		
	end 

	return lookup
end


local function GetPlayerCampaignsLookup()
	local nodes = {
		home = GetAssignedCampaignId(),
		guest = GetGuestCampaignId(),
		current = GetCurrentCampaignId(),
		assigned = GetAssignedCampaignId()
	}
	
	local lookup = GetCampaignLookup()
	
	for k,v in pairs(nodes) do
		nodes[k] = lookup[k]
	end
	
	return nodes
end

local _nextRefresh = 0 
local _refreshTimeout = 60000
local _dirty = true 

local function SetDirty()
	_dirty = true
end

local function Refresh()
	QueryCampaignSelectionData()
end

local function RefreshIfRequired()
	
	if _dirty == false then 
		
		local t = GetGameTimeMilliseconds()
		
		if t >= _nextRefresh then 
			_nextRefresh = t + _refreshTimeout
			_dirty = true
		end 
	end 

	if _dirty == true then 
		Refresh()
		_dirty = false
	end 
end

local function GetPlayerCampaigns()

	local ids = {GetAssignedCampaignId(),GetGuestCampaignId()}
	
	local lookup = GetCampaignLookup()
	
	local nodes = {}
	local node
	
	for i,id in ipairs(ids) do
	
		node = lookup[id]
		if node ~= nil then 
			table.insert(nodes,node)
		end
	end
	
	if #nodes > 1 then 
		table.sort(nodes,function(x,y)
			return x.name < y.name
		end)
	end
	
	return nodes
end 

local function GetPopulationText(population)
	return GetString("SI_CAMPAIGNPOPULATIONTYPE", population)
end

local function IsPlayerQueued(id,group)
	if group == true then 
		return IsQueuedForCampaign(id, CAMPAIGN_QUEUE_GROUP)
	elseif group == false then 
		return IsQueuedForCampaign(id, CAMPAIGN_QUEUE_INDIVIDUAL)
	end
	return IsQueuedForCampaign(id, CAMPAIGN_QUEUE_INDIVIDUAL) or IsQueuedForCampaign(id, CAMPAIGN_QUEUE_GROUP)
end

local function GetQueueState(id,group)
	if group == true then 
		return GetCampaignQueueState(id, CAMPAIGN_QUEUE_GROUP)
	else
		return GetCampaignQueueState(id, CAMPAIGN_QUEUE_INDIVIDUAL)
	end 
end

local function IsQueueState(id,state,isGroup)
	if isGroup ~= nil then 
		return GetQueueState(id,isGroup) == state
	end 
	return GetQueueState(id,false) == state or GetQueueState(id,true) == state
end 

local function IsGroupOnline()
	local count = GetGroupSize()
	
	local pChar = string.lower(GetUnitName("player"))
	
	for i = 1, count do 
		local unitTag = GetGroupUnitTagByIndex(i)
		local unitName = GetUnitName(unitTag)

		if unitTag ~= nil and IsUnitOnline(unitTag) == true and string.lower(unitName) ~= pChar then 
			return true
		end
	end
	
	return false 
end

local function CanQueue(id,group)
	group = group or 0 
	
    local canQueueIndividual = false
    local canQueueGroup = false
	
	if(GetCurrentCampaignId() ~= id and DoesPlayerMeetCampaignRequirements(id)) then
		if(GetAssignedCampaignId() == id or GetGuestCampaignId() == id) then
			canQueueIndividual = not IsQueuedForCampaign(id, CAMPAIGN_QUEUE_INDIVIDUAL)
			if(not IsQueuedForCampaign(id, CAMPAIGN_QUEUE_GROUP)) then
				if(IsUnitGrouped("player") and IsUnitGroupLeader("player") ) then
					canQueueGroup = IsGroupOnline()
				end
			end        
		end
	end

    return canQueueIndividual, canQueueGroup
	
end

local function EnterQueue(id,name,group)

	local canQueueIndividual, canQueueGroup = CanQueue(id)
	
	if canQueueIndividual == true and canQueueGroup == true  then
		ZO_Dialogs_ReleaseDialog("CAMPAIGN_QUEUE")
		ZO_Dialogs_ShowDialog("CAMPAIGN_QUEUE", {campaignId = id}, {mainTextParams = {name}})
	elseif canQueueGroup == true then
		QueueForCampaign(id, CAMPAIGN_QUEUE_GROUP)
	elseif canQueueIndividual == true then 
		QueueForCampaign(id, CAMPAIGN_QUEUE_INDIVIDUAL)
	end
	
end

local function LeaveQueue(id,isGroup)
	if isGroup == nil or isGroup == false then 
		LeaveCampaignQueue(id, false)
	end
	if isGroup == nil or isGroup == true then 
		LeaveCampaignQueue(id, true)
	end 
end

local function EnterLeaveOrJoin(id,name,group,isGroup)
	
	if IsPlayerQueued(id,isGroup) == true then
		
		local state = GetQueueState(id,isGroup)
		if state == CAMPAIGN_QUEUE_REQUEST_STATE_WAITING then 
			LeaveQueue(id,isGroup)
		elseif state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then 
			-- need to know isGroup
			isGroup = isGroup or (IsPlayerQueued(id,true) and GetQueueState(id,true) == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING)
			ZO_Dialogs_ReleaseDialog("CAMPAIGN_QUEUE_READY")
			ZO_Dialogs_ShowDialog("CAMPAIGN_QUEUE_READY", {campaignId = id, isGroup = isGroup}, {mainTextParams = {name}})
		end
	else
		return EnterQueue(id,name,group)
	end 

end

local _stateTextIds ={
	[CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_JOIN] = SI_CAMPAIGN_BROWSER_QUEUE_PENDING_JOIN,
	[CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_LEAVE] = SI_CAMPAIGN_BROWSER_QUEUE_PENDING_LEAVE,
	[CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_ACCEPT] = SI_CAMPAIGN_BROWSER_QUEUE_PENDING_ACCEPT,
	
}

local function GetStateText(state,id,isGroup)

	local strId

	if state == CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_JOIN or state == CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_LEAVE or state == CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_ACCEPT then
	
		strId = _stateTextIds[state]
	
		if strId ~= nil then 
			return GetString(strId)
		end 
		
	elseif state == CAMPAIGN_QUEUE_REQUEST_STATE_WAITING then
	
		local pos = GetCampaignQueuePosition(id, isGroup)
		
		strId = (isGroup == true and SI_CAMPAIGN_BROWSER_GROUP_QUEUED) or SI_CAMPAIGN_BROWSER_SOLO_QUEUED
		
		return zo_strformat(GetString(strId), pos)
		
	elseif state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then
	
		seconds = ZO_FormatTime(GetCampaignQueueRemainingConfirmationSeconds(id, isGroup), TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
		
		strId = (isGroup == true and SI_CAMPAIGN_BROWSER_GROUP_READY) or SI_CAMPAIGN_BROWSER_SOLO_READY
		
		return zo_strformat(GetString(strId), seconds)
	end
	
	return ""
end

local function GetQueueStateText(id)
	local individualState = GetQueueState(id,false)
	local groupState = GetQueueState(id,true)

	local itext = GetStateText(individualState,id,false)
	
	local gtext = GetStateText(groupState,id,true)
	
	return {individual=itext, group=gtext}
end

Campaign.FACTION_IDS = _alliances

Campaign.ICON_ID_HOME = "home"
Campaign.ICON_ID_GUEST = "guest"
Campaign.ICON_ID_JOINING = "joining"
Campaign.ICON_ID_READY = "ready"

Campaign.ICONS_FACTION_POPULATION = _populationFactionIcons
Campaign.COLOURS_FACTION_POPULATION = _populationFactionColors

Campaign.GetIcon = function(key)
	return _campaignIcons[key]
end

Campaign.GetPopulationText = GetPopulationText

Campaign.GetQueueStateText = GetQueueStateText

Campaign.GetPlayerCampaigns = GetPlayerCampaigns
Campaign.IsPlayerQueued = IsPlayerQueued
Campaign.GetQueueState = GetQueueState
Campaign.IsQueueState = IsQueueState
Campaign.EnterLeaveOrJoin =  EnterLeaveOrJoin


Campaign.SetDirty = SetDirty
Campaign.RefreshIfRequired = RefreshIfRequired

FasterTravel.Campaign = Campaign 