BSCAllianceRanking = BSCAllianceRanking or {}
local BSCARI = BSCAllianceRanking

local AllianceWarRanks = { 
	700, 		900, 		6400, 		14400, 		25600, 		40000, 		57600, 		78400, 		102400, 	129600,
	160000, 	193600, 	230400, 	270400, 	313600,		360000,		409600,		462400,		518400,		577600,
	640000,		705600,		774400,		846400,		921600,		1000000, 	1081600, 	1166400, 	1254400, 	1345600,
	1440000, 	1537600,	1638400,	1742400,	1849600,	1960000,	2073600,	2190400,	2310400,	2433600,
	2560000,	2689600,	2822400,	2958400,	3097600,	3240000,	3385600,	3534400,	3686400,	3841600,	
}

local function GetAllianceRankPointDelta(rank)
	local pointsNeeded = GetNumPointsNeededForAvARank(rank)
	local previousPointsNeeded = rank > 1 and GetNumPointsNeededForAvARank(rank - 1) or 0

	if type(pointsNeeded) == "number" and type(previousPointsNeeded) == "number" then
		local delta = pointsNeeded - previousPointsNeeded
		if delta > 0 then
			return delta
		end
	end

	return AllianceWarRanks[rank] or 0
end

---------------------------------------------------------------------------------------------------------------------------------
AlliancePointsView_Keyboard = ZO_InitializingObject:Subclass()

local function BuildList()
	local pGender = GetUnitGender('player')
	local pRank = GetUnitAvARank("player")		
	local rankPoints = GetUnitAvARankPoints("player")	
    local _, _, rankStartsAt, nextRankAt = GetAvARankProgress(rankPoints)	
	local pointsHave = 0
	local pointsNeed = 0
	if(rankPoints >= nextRankAt) then	
		local lastRankPoints = GetNumPointsNeededForAvARank(pRank - 1)
        local maxRankPoints = GetNumPointsNeededForAvARank(pRank)
        local fullRankPoints = maxRankPoints - lastRankPoints
		pointsHave = fullRankPoints
		pointsNeed = fullRankPoints
	else
		pointsHave = rankPoints - rankStartsAt
		pointsNeed = nextRankAt - rankStartsAt
	end	
	
	local cacl_points_next = 0
	local calc_points_you_need = 0	
	for rank = 1, 50 do
		local rankname = zo_strformat("<<1>>", GetAvARankName(pGender, rank))
		local points = GetAllianceRankPointDelta(rank)
		
		local txtcolor = "|cE9C62A"
		if rank <= pRank then
			txtcolor = "|c219129"
		end		
		if rank == pRank + 1 then
			calc_points_you_need = calc_points_you_need + (pointsNeed - pointsHave)
		end
		if rank > pRank + 1 then
			calc_points_you_need = calc_points_you_need + points
		end	
		cacl_points_next = cacl_points_next + points
		local lblinfo = { txtcolor..rank, "|t23:23:"..GetAvARankIcon(rank).."|t|r"..txtcolor..rankname, txtcolor..zo_strformat(SI_NUMBER_FORMAT, points), txtcolor..zo_strformat(SI_NUMBER_FORMAT,cacl_points_next), txtcolor..zo_strformat(SI_NUMBER_FORMAT,calc_points_you_need), }
		AlliancePointsView_Keyboard.list[rank]:GetNamedChild("Rank"):SetText(lblinfo[1])
		AlliancePointsView_Keyboard.list[rank]:GetNamedChild("Name"):SetText(lblinfo[2])
		AlliancePointsView_Keyboard.list[rank]:GetNamedChild("PointsNeed"):SetText(lblinfo[3])
		AlliancePointsView_Keyboard.list[rank]:GetNamedChild("PointsNeedTotal"):SetText(lblinfo[4])
		AlliancePointsView_Keyboard.list[rank]:GetNamedChild("PointsNeedYou"):SetText(lblinfo[5])
		AlliancePointsView_Keyboard.list[rank]:ClearAnchors()
		if rank > 1 then
			local post = rank -1
			AlliancePointsView_Keyboard.list[rank]:SetAnchor(TOPLEFT, AlliancePointsView_Keyboard.list[post], BOTTOMLEFT, 0, 0)
		else
			AlliancePointsView_Keyboard.list[rank]:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 0)
		end
	end	
end

function AlliancePointsView_Keyboard:Refresh()
	BuildList()
end

function AlliancePointsView_Keyboard:Initialize(control)
    AlliancePointsView_Keyboard.control = control	
	AlliancePointsView_Keyboard.list = { }	
	for rank = 1, 50 do					
		AlliancePointsView_Keyboard.list[rank] = WINDOW_MANAGER:CreateControlFromVirtual("CampaignAPViewRow"..rank, CampaignAPViewPanelScrollChildRankings, "AlliancePointsViewRow")
	end
	BSCARI.ALLIANCE_POINTSVIEW_FRAGMENT = ZO_FadeSceneFragment:New(control)
	BSCARI.ALLIANCE_POINTSVIEW_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_FRAGMENT_SHOWING then
			self:Refresh()
        end
    end)
end

function AlliancePointsView_Keyboard_OnInitialize(control)
    BSCARI.ALLIANCE_POINTSVIEW = AlliancePointsView_Keyboard:New(control)
end