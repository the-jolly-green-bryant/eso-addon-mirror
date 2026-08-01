BSCAllianceRanking = BSCAllianceRanking or {}
local BSCARI = BSCAllianceRanking
---------------------------------------------------------------------------------------------------------------------------------
AllianceTierView_Keyboard = ZO_InitializingObject:Subclass()

local characters = { }

function BSCARI:UpdateCharData()
	characters = { }
	local pRank = GetUnitAvARank("player")
    local campaignID = GetAssignedCampaignId()
	
    local currentTier, nextTierProgress, nextTierTotal = 0, 0, 25000
    local campaignDuration = 0
	local nowTime = os.time()
	local GSUCE = 0

	if campaignID and campaignID > 0 then
		currentTier, nextTierProgress, nextTierTotal = GetPlayerCampaignRewardTierInfo(campaignID)
		local rulesetId = GetCampaignRulesetId(campaignID)
		if rulesetId then
			campaignDuration = GetCampaignRulesetDurationInSeconds(rulesetId) or 0
		end
		GSUCE = GetSecondsUntilCampaignEnd(campaignID) or 0
	end

    local expireTime = nowTime + GSUCE
	
	for Index = 1, GetNumCharacters() do	
		local name, _, _, _, _, alliance, id, _ = GetCharacterInfo(Index)		
		local bAdd = true
		
		for i, v in pairs(BSCARI.SVA.CHAR_LIST) do			
			if v.id == id then
				bAdd = false
				
				-- Reset Info on Campaign End
				local secondsUntilCampaignExpire = os.difftime(v.expireTime, os.time())			
				if secondsUntilCampaignExpire <= 0 then
					BSCARI.SVA.CHAR_LIST[i].tier = 0
					BSCARI.SVA.CHAR_LIST[i].TierTotal = 25000 
					BSCARI.SVA.CHAR_LIST[i].TierProgress = 0 
					BSCARI.SVA.CHAR_LIST[i].expireTime = os.time() + ((v.campaignID and v.campaignID > 0 and GetSecondsUntilCampaignEnd(v.campaignID)) or 0)				
				end
			
				-- Update Current data 
				if v.id == BSCARI.CurrentCharID and GSUCE > 0 then
					BSCARI.SVA.CHAR_LIST[i].name = zo_strformat("<<1>>", name)
					BSCARI.SVA.CHAR_LIST[i].alliance = alliance
					BSCARI.SVA.CHAR_LIST[i].tier = currentTier
					BSCARI.SVA.CHAR_LIST[i].TierTotal = nextTierTotal
					BSCARI.SVA.CHAR_LIST[i].TierProgress = nextTierProgress
					BSCARI.SVA.CHAR_LIST[i].expireTime = expireTime
					BSCARI.SVA.CHAR_LIST[i].campaignID = campaignID 
					BSCARI.SVA.CHAR_LIST[i].campaignDuration = campaignDuration
					BSCARI.SVA.CHAR_LIST[i].pRank = pRank
				end
			
				table.insert(characters, 
				{
					id = v.id, 
					name = zo_strformat("<<1>>", v.name), 
					alliance = v.alliance,
					tier = v.tier, 
					TierTotal = v.TierTotal, 
					TierProgress = v.TierProgress, 
					expireTime = v.expireTime, 
					campaignID = v.campaignID, 
					campaignDuration = v.campaignDuration,
					pRank = v.pRank,
				})
			end
		end
		-- Missing char add
		if bAdd then
			
			local tier = 0
			local tierT = 0
			local tierP = 0
			local expiT = 0
			local campID = -1
			local campDu = 0
			local pR = 1
			-- Update Current data 
			if id == BSCARI.CurrentCharID then
				tier = currentTier
				tierT = nextTierTotal
				tierP = nextTierProgress
				expiT = expireTime
				campID = campaignID
				campDu = campaignDuration
				pR = pRank
			end
		
			if BSCARI.SVA.CHAR_LIST == nil then BSCARI.SVA.CHAR_LIST = {} end			
			if BSCARI.SVA.CHAR_LIST[Index] == nil then BSCARI.SVA.CHAR_LIST[Index] = {} end
			
			BSCARI.SVA.CHAR_LIST[Index].id = id
			BSCARI.SVA.CHAR_LIST[Index].name = zo_strformat("<<1>>", name)
			BSCARI.SVA.CHAR_LIST[Index].alliance = alliance
			BSCARI.SVA.CHAR_LIST[Index].tier = tier
			BSCARI.SVA.CHAR_LIST[Index].TierTotal = tierT
			BSCARI.SVA.CHAR_LIST[Index].TierProgress = tierP
			BSCARI.SVA.CHAR_LIST[Index].expireTime = expiT
			BSCARI.SVA.CHAR_LIST[Index].campaignID = campID
			BSCARI.SVA.CHAR_LIST[Index].campaignDuration = campDu
			BSCARI.SVA.CHAR_LIST[Index].pRank = pR
			
			table.insert(characters, 
			{
				id = id, 
				name = zo_strformat("<<1>>", name), 
				alliance = alliance,
				tier = tier, 
				TierTotal = tierT, 
				TierProgress = tierP, 
				expireTime = expiT, 
				campaignID = campID, 
				campaignDuration = campDu,
				pRank = pR,
			})
		end
	end
	
	-- sorting by alliance and name
	table.sort(characters, function(a,b) 
		if a.alliance == b.alliance then
			return a.name < b.name
		end		
		return a.alliance < b.alliance 
	end)
end

local function BuildList()
	BSCARI:UpdateCharData()	
	for rank, v in pairs(characters) do	
		AllianceTierView_Keyboard.list[rank]:GetNamedChild("CharName"):SetText("|t24:24:"..GetAvARankIcon(v.pRank).."|t|r"..GetAllianceColor(v.alliance):Colorize(v.name))	
		if v.campaignID > 0 then
			local campaignName = GetAllianceColor(v.alliance):Colorize(ZO_CachedStrFormat(SI_CAMPAIGN_NAME, GetCampaignName(v.campaignID)))		
			local timeDiff, secondsToUpdate = FormatTimeSeconds(os.difftime(v.expireTime, os.time()),  TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR_NO_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
						
			AllianceTierView_Keyboard.list[rank]:GetNamedChild("CampaignName"):SetText(campaignName)		
			AllianceTierView_Keyboard.list[rank]:GetNamedChild("TimeRemaining"):SetText(timeDiff)
					
			local color = "|cb30000"
			local info = " [" ..v.TierProgress.."/"..v.TierTotal.."]"
			if v.tier == 1 then
				color = "|cff9933" 
			elseif v.tier == 2 then
				color = "|cfcd25d" 
			elseif v.tier == 3 then
				color = "|c00b300" 
				info = " Max Tier!"
			end
			AllianceTierView_Keyboard.list[rank]:GetNamedChild("TierInfo"):SetText(color.." [" .. v.tier .. "/3]"..info.." |r " )
		else
			-- emtpy data
			AllianceTierView_Keyboard.list[rank]:GetNamedChild("TierInfo"):SetText("|cffcc00 - |r")
			AllianceTierView_Keyboard.list[rank]:GetNamedChild("CampaignName"):SetText("|cffcc00 No Info |r")		
			AllianceTierView_Keyboard.list[rank]:GetNamedChild("TimeRemaining"):SetText("|cffcc00 - |r")
		end
		AllianceTierView_Keyboard.list[rank]:ClearAnchors()
		if rank > 1 then
			local post = rank -1
			AllianceTierView_Keyboard.list[rank]:SetAnchor(TOPLEFT, AllianceTierView_Keyboard.list[post], BOTTOMLEFT, 0, 0)
		else
			AllianceTierView_Keyboard.list[rank]:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 0)
		end
		
		-- Mark current char
		if v.id == BSCARI.CurrentCharID then
			AllianceTierView_Keyboard.list[rank]:GetNamedChild("SelectBox"):SetHidden(false)
		else
			AllianceTierView_Keyboard.list[rank]:GetNamedChild("SelectBox"):SetHidden(true)
		end		
	end

	-- Hide stale rows when character count changed.
	for index = #characters + 1, #AllianceTierView_Keyboard.list do
		AllianceTierView_Keyboard.list[index]:SetHidden(true)
	end
end


function AllianceTierView_Keyboard:Refresh()
	BuildList()
end

function AllianceTierView_Keyboard:Initialize(control)
    AllianceTierView_Keyboard.control = control	
	AllianceTierView_Keyboard.list = { }	
	--
	for Index = 1, GetNumCharacters() do				
		AllianceTierView_Keyboard.list[Index] = WINDOW_MANAGER:CreateControlFromVirtual("CampaignTierViewRow"..Index, CampaignTierViewPanelScrollChildRankings, "AllianceTierViewRow")
		--			
	end	
	BSCARI.ALLIANCE_TIERVIEW_FRAGMENT = ZO_FadeSceneFragment:New(control)
	BSCARI.ALLIANCE_TIERVIEW_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_FRAGMENT_SHOWING then
			self:Refresh()
        end
    end)
end

function AllianceTierView_Keyboard_OnInitialize(control)
    BSCARI.ALLIANCE_TIERVIEW = AllianceTierView_Keyboard:New(control)
end