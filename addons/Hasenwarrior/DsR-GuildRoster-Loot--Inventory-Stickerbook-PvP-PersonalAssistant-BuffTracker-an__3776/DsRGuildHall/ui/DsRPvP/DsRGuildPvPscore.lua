-- Create namespace
DsRGuildPvPscore = {}
local DsRGuildPvPscore = DsRGuildPvPscore  or {}

local initTries = 0

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPscore.ScoreWindow_OnInitialized()
    -- Warteschlange muss sein, da ich die SavedVariable brauche

	if not DsRGuildPvP.pvp then 
        initTries = initTries + 1
        if initTries <= 10 then zo_callLater(function() DsRGuildPvPscore.ScoreWindow_OnInitialized() end, 1000) end
    else
	    DsRGuildPvPscore.ScoreWindow_RestorePosition()
	    DsRScoreWindow:SetMovable(not( DsRGuildPvP.pvp.statsBarLocked))
		local DsRGuildHall_hud_scene = ZO_SimpleSceneFragment:New(DsRScoreWindow)
		HUD_SCENE:AddFragment(DsRGuildHall_hud_scene)
		HUD_UI_SCENE:AddFragment(DsRGuildHall_hud_scene)

		local currentAvARank
		local rankProgAvA, rankMaxAvA
	
		currentAvARank = GetUnitAvARank("player")
		local function GetCurrentRankProgress()
			local rankPoints = GetUnitAvARankPoints("player")
			local _, _, rankStartsAt, nextRankAt = GetAvARankProgress(rankPoints)
			if rankPoints >= nextRankAt then
				local lastRankPoints = GetNumPointsNeededForAvARank(currentAvARank - 1)
				local maxRankPoints = GetNumPointsNeededForAvARank(currentAvARank)
				local fullRankPoints = maxRankPoints - lastRankPoints
	
				return fullRankPoints, fullRankPoints
			else
				return rankPoints - rankStartsAt, nextRankAt - rankStartsAt
			end
		end
		rankProgAvA, rankMaxAvA = GetCurrentRankProgress()
		local ProgressPoint = tostring(math.floor(100*(rankProgAvA/rankMaxAvA)))

		DsRGuildPvPscore.ScoreWindow_Update(ProgressPoint)
		DsRGuildPvPscore.ScoreWindow_Scale()
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPscore.ScoreWindow_Update(ProgressPoint)
	local statsStr = nil

	local kills 		 =  DsRGuildPvP.pvp.sessionStats.kills or 0
	local killingblows   =  DsRGuildPvP.pvp.sessionStats.killingBlows or 0
	local killingBlowsAD =  DsRGuildPvP.pvp.sessionStats.killingBlowsAD or 0
	local killingBlowsEP =  DsRGuildPvP.pvp.sessionStats.killingBlowsEP or 0
	local killingBlowsDC =  DsRGuildPvP.pvp.sessionStats.killingBlowsDC or 0
	local deaths 		 =  DsRGuildPvP.pvp.sessionStats.deaths or 0
	local ap 			 =  DsRGuildPvP.pvp.sessionStats.alliancePoints or 0
	local tv 			 =  GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
	local killsPerDeath  = kills or 0

	local ColorAD 		 = GetAllianceColor(1):GetBright() 			   -- 1 = Aldmeri
	local ColorEP 		 = GetAllianceColor(2):GetBright() 			   -- 2 = Ebenerz
	local ColorDC 		 = GetAllianceColor(3):GetBright() 			   -- 3 = Dolchsturz

	local IconAD   	     = zo_iconFormat("/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds", 36, 40)    		   -- 1 = Aldmeri
	local IconEP   	     = zo_iconFormat("/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds", 36, 40)  		   -- 2 = Ebenerz
	local IconDC   	     = zo_iconFormat("/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds", 36, 40) 		   -- 3 = Dolchsturz

	if deaths > 0 then killsPerDeath = kills/deaths end

	-- Namens
	local killingBlowsStr = string.format("|cC0FF3E%s|r", GetString(DsRGuildPvP_KillingBlow))
	local killsStr 		  = string.format("|c97FFFF%s|r", GetString(DsRGuildPvP_KillingChat))
	local deathsStr 	  = string.format("|cFF0000%s|r", GetString(DsRGuildPvP_KillingDeath))
	local apStr 		  = string.format("|c2ADC22%s|r", GetString(DsRGuildPvP_KillingAP))
	local TVStr 		  = string.format("|c5C6BFF%s|r", GetString(DsRGuildPvP_KillingTV))

	-- Kills
		-- AD
	valStr 				    = tostring(killingBlowsAD)
	valStr 				    = ColorAD:Colorize(valStr)
	local killingBlowsCouAD = valStr
		-- EP
	valStr 				    = tostring(killingBlowsEP)
	valStr 				    = ColorEP:Colorize(valStr)
	local killingBlowsCouEP = valStr
		-- DC
	valStr 				    = tostring(killingBlowsDC)
	valStr 				    = ColorDC:Colorize(valStr)
	local killingBlowsCouDC = valStr
		-- Battleground
	valStr 				    = tostring(killingblows)
	local killingBlowsCou   = valStr

	-- Assist
	valStr 			 = tostring(kills)
	local killsCou   = valStr
		
	-- Tode
	valStr 			= tostring(deaths)
	valStrkilldeath = 0
	if kills > 0 and deaths > 0 then valStrkilldeath = string.format("%.1f", killsPerDeath) end
	valStrdeath 	    = string.format("|cFF0000%s|r", valStr)
	valkilldeathsCou    = string.format("|cFF0000%s|r", valStrkilldeath)
	local deathsCou     = valStrdeath
	local killdeathsCou = valkilldeathsCou
		
	-- AP
	local apNum = FormatIntegerWithDigitGrouping(ap, ".", 3)
	valStr 		= string.format("|cFFFFFF%s|r", tostring(apNum))
	local apCou = valStr

	-- TV
	local tvNum = FormatIntegerWithDigitGrouping(tv, ".", 3)
	valStr 		= string.format("|cFFFFFF%s|r", tostring(tvNum))
	local tvCou = valStr

	local currentAvARank
	local rankProgAvA, rankMaxAvA

	-- PvP Rank
	currentAvARank   = GetUnitAvARank("player")
	rankIcon 	     = GetAvARankIcon(GetUnitAvARank("player"))
	local Ranksymbol = string.format("|cffff00|t64:64:%s:inheritcolor|t|r", tostring(rankIcon))
	local RankTxT	 = string.format("|cf5ff8f%s|r", tostring(currentAvARank))

	-- Rank percent
	local function GetCurrentRankProgress()
		local rankPoints = GetUnitAvARankPoints("player")
		local _, _, rankStartsAt, nextRankAt = GetAvARankProgress(rankPoints)
		if rankPoints >= nextRankAt then
			local lastRankPoints = GetNumPointsNeededForAvARank(currentAvARank - 1)
			local maxRankPoints = GetNumPointsNeededForAvARank(currentAvARank)
			local fullRankPoints = maxRankPoints - lastRankPoints

			return fullRankPoints, fullRankPoints
		else
			return rankPoints - rankStartsAt, nextRankAt - rankStartsAt
		end
	end
	rankProgAvA, rankMaxAvA = GetCurrentRankProgress()
	local ProgressPoint = tostring(math.floor(100*(rankProgAvA/rankMaxAvA)))

	valStrPercentTxT  = string.format("|c0096FF%s%s|r", tostring(ProgressPoint), "%")
	local RankPercent = valStrPercentTxT


	if IsInImperialCity() then
		local youralliance = GetUnitAlliance("player")
        if youralliance == 1 then
			statsStrAPTVtxt   = string.format("%s",TVStr)
			statsStrKillstxt  = string.format("%s",killingBlowsStr)
			statsStrAssisttxt = string.format("%s",killsStr)

			countStrAPTVpoints   = string.format("%s",tvCou)
			countStrKillspoints  = string.format("%s%s %s%s", IconEP, killingBlowsCouEP, IconDC, killingBlowsCouDC)
			countStrAssistpoints = string.format("%s",killsCou)
			countStrDpoints      = string.format("%s",deathsCou)
			countStrKDpoints     = string.format("%s", killdeathsCou)
        elseif youralliance == 2 then
			statsStrAPTVtxt   = string.format("%s",TVStr)
			statsStrKillstxt  = string.format("%s",killingBlowsStr)
			statsStrAssisttxt = string.format("%s",killsStr)

			countStrAPTVpoints   = string.format("%s",tvCou)
			countStrKillspoints  = string.format("%s%s %s%s", IconAD, killingBlowsCouAD, IconDC, killingBlowsCouDC)
			countStrAssistpoints = string.format("%s",killsCou)
			countStrDpoints      = string.format("%s",deathsCou)
			countStrKDpoints     = string.format("%s", killdeathsCou)
        elseif youralliance == 3 then
			statsStrAPTVtxt   = string.format("%s",TVStr)
			statsStrKillstxt  = string.format("%s",killingBlowsStr)
			statsStrAssisttxt = string.format("%s",killsStr)

			countStrAPTVpoints   = string.format("%s",tvCou)
			countStrKillspoints  = string.format("%s%s %s%s", IconAD, killingBlowsCouAD, IconEP, killingBlowsCouEP)
			countStrAssistpoints = string.format("%s",killsCou)
			countStrDpoints      = string.format("%s",deathsCou)
			countStrKDpoints     = string.format("%s", killdeathsCou)
    	end
	elseif IsPlayerInAvAWorld() then
		local youralliance = GetUnitAlliance("player")
        if youralliance == 1 then
			statsStrAPTVtxt   = string.format("%s",apStr)
			statsStrKillstxt  = string.format("%s",killingBlowsStr)
			statsStrAssisttxt = string.format("%s",killsStr)

			countStrAPTVpoints   = string.format("%s",apCou)
			countStrKillspoints  = string.format("%s%s %s%s", IconEP, killingBlowsCouEP, IconDC, killingBlowsCouDC)
			countStrAssistpoints = string.format("%s",killsCou)
			countStrDpoints      = string.format("%s",deathsCou)
			countStrKDpoints     = string.format("%s", killdeathsCou)
        elseif youralliance == 2 then
			statsStrAPTVtxt   = string.format("%s",apStr)
			statsStrKillstxt  = string.format("%s",killingBlowsStr)
			statsStrAssisttxt = string.format("%s",killsStr)

			countStrAPTVpoints   = string.format("%s",apCou)
			countStrKillspoints  = string.format("%s%s %s%s", IconAD, killingBlowsCouAD, IconDC, killingBlowsCouDC)
			countStrAssistpoints = string.format("%s",killsCou)
			countStrDpoints      = string.format("%s",deathsCou)
			countStrKDpoints     = string.format("%s", killdeathsCou)
        elseif youralliance == 3 then
			statsStrAPTVtxt   = string.format("%s", apStr)
			statsStrKillstxt  = string.format("%s", killingBlowsStr)
			statsStrAssisttxt = string.format("%s", killsStr)

			countStrAPTVpoints   = string.format("%s", apCou)
			countStrKillspoints  = string.format("%s%s %s%s", IconAD, killingBlowsCouAD, IconEP, killingBlowsCouEP)
			countStrAssistpoints = string.format("%s", killsCou)
			countStrDpoints      = string.format("%s", deathsCou)
			countStrKDpoints     = string.format("%s", killdeathsCou)
        end
	elseif IsActiveWorldBattleground() then
		statsStrAPTVtxt   = string.format("%s", apStr)
		statsStrKillstxt  = string.format("%s", killingBlowsStr)
		statsStrAssisttxt = string.format("%s", killsStr)

		countStrAPTVpoints   = string.format("%s", apCou)
		countStrKillspoints  = string.format("%s", killingBlowsCou)
		countStrAssistpoints = string.format("%s", killsCou)
		countStrDpoints      = string.format("%s", deathsCou)
		countStrKDpoints     = string.format("%s", killdeathsCou)
	else
		statsStrAPTVtxt   = string.format("%s", apStr)
		statsStrKillstxt  = string.format("%s", killingBlowsStr)
		statsStrAssisttxt = string.format("%s", killsStr)

		countStrAPTVpoints   = string.format("0")
		countStrKillspoints  = string.format("0")
		countStrAssistpoints = string.format("0")
		countStrDpoints      = string.format("0")
		countStrKDpoints     = string.format("0")
	end

	local qStr 	  = nil
	local timeStr = nil

	if DsRGuildPvP.queuedCampaignID then
		if DsRGuildPvP.queueState 	  == CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_JOIN 	 then qStr = GetString(DsRGuildPvP_qstate_QUEUEING)
		elseif DsRGuildPvP.queueState == CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_ACCEPT then qStr = GetString(DsRGuildPvP_qstate_ENTERING)
		elseif DsRGuildPvP.queueState == CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_LEAVE  then qStr = GetString(DsRGuildPvP_qstate_LEAVING)
		elseif DsRGuildPvP.queueState == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING 	 then qStr = GetString(DsRGuildPvP_qstate_CONFIRMING)
		elseif DsRGuildPvP.queueState == CAMPAIGN_QUEUE_REQUEST_STATE_WAITING 		 then qStr = GetString(DsRGuildPvP_qstate_WAITING)
		elseif DsRGuildPvP.queueState == CAMPAIGN_QUEUE_REQUEST_STATE_FINISHED 	 	 then qStr = GetString(DsRGuildPvP_qstate_FINISHED)
		else qStr = GetString(DsRGuildPvP_qstate_UNKNOWN) end

		qStr = string.format(qStr, GetCampaignName(DsRGuildPvP.queuedCampaignID) or GetString(DsRGuildPvP_qstate_UNKNOWN_Q))

		if DsRGuildPvP.queueState == CAMPAIGN_QUEUE_REQUEST_STATE_WAITING and DsRGuildPvP.queuePosition ~= nil then
			qStrPos = string.format(GetString(DsRGuildPvP_qstate_Q_NUMBER), DsRGuildPvP.queuePosition)

			if DsRGuildPvP.queueTimeInSecs and DsRGuildPvP.queueTimeInSecs > 0 then
				timeStr = FormatTimeSeconds(DsRGuildPvP.queueTimeInSecs, 
											TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, 
											TIME_FORMAT_PRECISION_SECONDS, 
											TIME_FORMAT_DIRECTION_DESCENDING)
				timeStr = string.format("%s", timeStr)
			end 
		end
	end

	DsRScoreWindowBackground:SetHidden(false)
	DsRScoreWindowBackgroundPercent:SetHidden(false)

	DsRScoreWindowAPTVtxt:SetHidden(false)
	DsRScoreWindowAPTVpoints:SetHidden(false)
	DsRScoreWindowKillstxt:SetHidden(false)
	DsRScoreWindowKillspoints:SetHidden(false)
	DsRScoreWindowAssisttxt:SetHidden(false)
	DsRScoreWindowAssistpoints:SetHidden(false)
	DsRScoreWindowDtxt:SetHidden(false)
	DsRScoreWindowDpoints:SetHidden(false)
	DsRScoreWindowKDtxt:SetHidden(false)
	DsRScoreWindowKDpoints:SetHidden(false)
	DsRScoreWindowRanksymbol:SetHidden(false)
	DsRScoreWindowRankTxT:SetHidden(false)
	DsRScoreWindowPercentTxT:SetHidden(false)

	DsRScoreWindowAPTVtxt:SetText(statsStrAPTVtxt)
	DsRScoreWindowAPTVpoints:SetText(countStrAPTVpoints)
	DsRScoreWindowKillstxt:SetText(statsStrKillstxt)
	DsRScoreWindowKillspoints:SetText(countStrKillspoints)
	DsRScoreWindowAssisttxt:SetText(statsStrAssisttxt)
	DsRScoreWindowAssistpoints:SetText(countStrAssistpoints)
	DsRScoreWindowDpoints:SetText(countStrDpoints)
	DsRScoreWindowKDpoints:SetText(countStrKDpoints)
	DsRScoreWindowRanksymbol:SetText(Ranksymbol)
	DsRScoreWindowRankTxT:SetText(RankTxT)
	DsRScoreWindowPercentTxT:SetText(RankPercent)

	DsRScoreWindowBackground:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter.dds", 400, 200))
	
	local ProgressPoint = tonumber(ProgressPoint) or 0
	if ProgressPoint > 0 and ProgressPoint <= 5 then
		DsRScoreWindowBackgroundPercent:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter005.dds", 400, 200))
	elseif ProgressPoint > 5 and ProgressPoint <= 10 then
		DsRScoreWindowBackgroundPercent:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter010.dds", 400, 200))
	elseif ProgressPoint > 10 and ProgressPoint <= 15 then
		DsRScoreWindowBackgroundPercent:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter015.dds", 400, 200))
	elseif ProgressPoint > 15 and ProgressPoint <= 20 then
		DsRScoreWindowBackgroundPercent:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter020.dds", 400, 200))
	elseif ProgressPoint > 20 and ProgressPoint <= 25 then
		DsRScoreWindowBackgroundPercent:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter025.dds", 400, 200))
	elseif ProgressPoint > 25 and ProgressPoint <= 30 then
		DsRScoreWindowBackgroundPercent:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter030.dds", 400, 200))
	elseif ProgressPoint > 30 and ProgressPoint <= 35 then
		DsRScoreWindowBackgroundPercent:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter035.dds", 400, 200))
	elseif ProgressPoint > 35 and ProgressPoint <= 40 then
		DsRScoreWindowBackgroundPercent:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter040.dds", 400, 200))
	elseif ProgressPoint > 40 and ProgressPoint <= 45 then
		DsRScoreWindowBackgroundPercent:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter045.dds", 400, 200))
	elseif ProgressPoint > 45 and ProgressPoint <= 50 then
		DsRScoreWindowBackgroundPercent:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter050.dds", 400, 200))
	elseif ProgressPoint > 50 and ProgressPoint <= 55 then
		DsRScoreWindowBackgroundPercent:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter055.dds", 400, 200))
	elseif ProgressPoint > 55 and ProgressPoint <= 60 then
		DsRScoreWindowBackgroundPercent:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter060.dds", 400, 200))
	elseif ProgressPoint > 60 and ProgressPoint <= 65 then
		DsRScoreWindowBackgroundPercent:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter065.dds", 400, 200))
	elseif ProgressPoint > 65 and ProgressPoint <= 70 then
		DsRScoreWindowBackgroundPercent:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter070.dds", 400, 200))
	elseif ProgressPoint > 70 and ProgressPoint <= 75 then
		DsRScoreWindowBackgroundPercent:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter075.dds", 400, 200))
	elseif ProgressPoint > 75 and ProgressPoint <= 80 then
		DsRScoreWindowBackgroundPercent:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter080.dds", 400, 200))
	elseif ProgressPoint > 80 and ProgressPoint <= 85 then
		DsRScoreWindowBackgroundPercent:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter085.dds", 400, 200))
	elseif ProgressPoint > 85 and ProgressPoint <= 90 then
		DsRScoreWindowBackgroundPercent:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter090.dds", 400, 200))
	elseif ProgressPoint > 90 and ProgressPoint <= 95 then
		DsRScoreWindowBackgroundPercent:SetText(zo_iconFormat("/DsRGuildHall/misc/killcount/DsR_KillCounter095.dds", 400, 200))
	end

	if DsRGuildPvP.pvp.enableQueueBar == true then
		if DsRGuildPvP.pvp.hideInPvE == true and IsPlayerInAvAWorld() == false and IsActiveWorldBattleground() == false and IsInImperialCity() == false then
			DsRScoreWindow:SetHidden(true)
			DsRScoreWindowBackground:SetHidden(true)
			DsRScoreWindowBackgroundPercent:SetHidden(true)

			DsRScoreWindowAPTVtxt:SetHidden(true)
			DsRScoreWindowAPTVpoints:SetHidden(true)
			DsRScoreWindowKillstxt:SetHidden(true)
			DsRScoreWindowKillspoints:SetHidden(true)
			DsRScoreWindowAssisttxt:SetHidden(true)
			DsRScoreWindowAssistpoints:SetHidden(true)
			DsRScoreWindowDtxt:SetHidden(true)
			DsRScoreWindowDpoints:SetHidden(true)
			DsRScoreWindowKDtxt:SetHidden(true)
			DsRScoreWindowKDpoints:SetHidden(true)
			DsRScoreWindowRanksymbol:SetHidden(true)
			DsRScoreWindowRankTxT:SetHidden(true)
			DsRScoreWindowPercentTxT:SetHidden(true)

		else
			DsRScoreWindow:SetHidden(false)
			DsRScoreWindowBackground:SetHidden(false)
			DsRScoreWindowBackgroundPercent:SetHidden(false)

			DsRScoreWindowAPTVtxt:SetHidden(false)
			DsRScoreWindowAPTVpoints:SetHidden(false)
			DsRScoreWindowKillstxt:SetHidden(false)
			DsRScoreWindowKillspoints:SetHidden(false)
			DsRScoreWindowAssisttxt:SetHidden(false)
			DsRScoreWindowAssistpoints:SetHidden(false)
			DsRScoreWindowDtxt:SetHidden(false)
			DsRScoreWindowDpoints:SetHidden(false)
			DsRScoreWindowKDtxt:SetHidden(false)
			DsRScoreWindowKDpoints:SetHidden(false)
			DsRScoreWindowRanksymbol:SetHidden(false)
			DsRScoreWindowRankTxT:SetHidden(false)
			DsRScoreWindowPercentTxT:SetHidden(false)
		end
	else
		DsRScoreWindow:SetHidden(true)
		DsRScoreWindowBackground:SetHidden(true)
		DsRScoreWindowBackgroundPercent:SetHidden(true)

		DsRScoreWindowAPTVtxt:SetHidden(true)
		DsRScoreWindowAPTVpoints:SetHidden(true)
		DsRScoreWindowKillstxt:SetHidden(true)
		DsRScoreWindowKillspoints:SetHidden(true)
		DsRScoreWindowAssisttxt:SetHidden(true)
		DsRScoreWindowAssistpoints:SetHidden(true)
		DsRScoreWindowDtxt:SetHidden(true)
		DsRScoreWindowDpoints:SetHidden(true)
		DsRScoreWindowKDtxt:SetHidden(true)
		DsRScoreWindowKDpoints:SetHidden(true)
		DsRScoreWindowRanksymbol:SetHidden(true)
		DsRScoreWindowRankTxT:SetHidden(true)
		DsRScoreWindowPercentTxT:SetHidden(true)
	end

	if qStr then
		DsRScoreWindowQueue:SetHidden(false)
		DsRScoreWindowQueue:SetText(string.format("|cffff00%s|r", qStr))

		if DsRGuildPvP.pvp.enableQueueBar == true then
			DsRScoreWindow:SetHidden(false)
			DsRScoreWindowBackground:SetHidden(false)
			DsRScoreWindowBackgroundPercent:SetHidden(false)

			DsRScoreWindowAPTVtxt:SetHidden(false)
			DsRScoreWindowAPTVpoints:SetHidden(false)
			DsRScoreWindowKillstxt:SetHidden(false)
			DsRScoreWindowKillspoints:SetHidden(false)
			DsRScoreWindowAssisttxt:SetHidden(false)
			DsRScoreWindowAssistpoints:SetHidden(false)
			DsRScoreWindowDtxt:SetHidden(false)
			DsRScoreWindowDpoints:SetHidden(false)
			DsRScoreWindowKDtxt:SetHidden(false)
			DsRScoreWindowKDpoints:SetHidden(false)
			DsRScoreWindowRanksymbol:SetHidden(false)
			DsRScoreWindowRankTxT:SetHidden(false)
			DsRScoreWindowPercentTxT:SetHidden(false)
		end
	else 
		DsRScoreWindowQueue:SetHidden(true) 
	end
	if timeStr then
		DsRScoreWindowQueuePos:SetHidden(false)
		DsRScoreWindowQueuePos:SetText(string.format("|cffff00Pos:|r |cFF0000%s|r", qStrPos))
		DsRScoreWindowQueueTime:SetHidden(false)
		DsRScoreWindowQueueTime:SetText(string.format("|cffff00Time:|r |cFF0000%s|r", timeStr))
	else
		DsRScoreWindowQueuePos:SetHidden(true)
		DsRScoreWindowQueueTime:SetHidden(true)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPscore.ScoreWindow_Scale()
	DsRGuildPvP.pvp.scoreWindowScale =  DsRGuildPvP.pvp.scoreWindowScale or 0
	local scaleModifier = 1 + ( DsRGuildPvP.pvp.scoreWindowScale/100)
	if DsRScoreWindow:GetScale() ~= scaleModifier then DsRScoreWindow:SetScale(scaleModifier) end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPscore.ScoreWindow_SaveAnchor()
	local isValidAnchor, currAnchorPoint, relativeTo, relativePoint, currXOff, currYOff, anchorConstrains = DsRScoreWindow:GetAnchor()

	DsRGuildPvP.pvp.scoreWindowanchorPoint = currAnchorPoint
	DsRGuildPvP.pvp.scoreWindowxOff        = currXOff
	DsRGuildPvP.pvp.scoreWindowyOff        = currYOff
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPscore.ScoreWindow_OnMoveStop()
	DsRGuildPvPscore.ScoreWindow_SaveAnchor()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPscore.ScoreWindow_RestorePosition()
	
	if DsRGuildPvP.pvp.scoreWindowanchorPoint and ( not DsRGuildPvP.pvp.scoreWindowanchorPoint and not DsRGuildPvP.pvp.scoreWindowxOff and not DsRGuildPvP.pvp.scoreWindowyOff) then
		DsRGuildPvP.pvp.scoreWindowanchorPoint = DsRGuildPvP.pvp.scoreWindowanchorPoint
		DsRGuildPvP.pvp.scoreWindowxOff 	   = DsRGuildPvP.pvp.scoreWindowxOff
		DsRGuildPvP.pvp.scoreWindowyOff 	   = DsRGuildPvP.pvp.scoreWindowyOff
	end

	if ( not DsRGuildPvP.pvp.scoreWindowanchorPoint and not DsRGuildPvP.pvp.scoreWindowxOff and not DsRGuildPvP.pvp.scoreWindowyOff) then DsRGuildPvPscore.ScoreWindow_SaveAnchor() end

	DsRScoreWindow:ClearAnchors()
	DsRScoreWindow:SetAnchor( DsRGuildPvP.pvp.scoreWindowanchorPoint, GuiRoot, nil,  DsRGuildPvP.pvp.scoreWindowxOff,  DsRGuildPvP.pvp.scoreWindowyOff)
end