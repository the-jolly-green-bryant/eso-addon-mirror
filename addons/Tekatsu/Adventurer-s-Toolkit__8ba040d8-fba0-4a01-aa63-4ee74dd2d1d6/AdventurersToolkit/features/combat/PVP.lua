-- ============================================
-- PVP DASHBOARD - Adventurer's Toolkit
-- Comprehensive Cyrodiil & Battlegrounds Tracker
-- ============================================

NWT.PVP = {
    isOpen = false,
    sceneInitialized = false,
    currentTab = 1,
    tabs = { "Cyrodiil", "Battlegrounds", "Leaderboards" },
    loginTime = 0,
    emperor = nil,
    campaignScores = {},
    scrolls = {},
    inBattleground = false,
    bgStartTime = 0,
}

-- Alliance constants for reference
local AD = ALLIANCE_ALDMERI_DOMINION
local EP = ALLIANCE_EBONHEART_PACT  
local DC = ALLIANCE_DAGGERFALL_COVENANT

-- ============================================
-- SAVED VARIABLES DEFAULTS
-- ============================================
NWT.PVP_DEFAULTS = {
    -- Always-on Cyrodiil stats
    allTime = {
        apEarned = 0,
        kills = 0,
        deaths = 0,
        firstTracked = 0,
    },
    today = {
        date = "",
        apEarned = 0,
        kills = 0,
        deaths = 0,
        loginAP = 0,
    },
    -- Session goals
    goals = {
        apTarget = 0,
        killTarget = 0,
    },
    -- Battlegrounds stats  
    battlegrounds = {
        matches = 0,
        wins = 0,
        losses = 0,
        kills = 0,
        deaths = 0,
        assists = 0,
        medals = 0,
        totalScore = 0,
        matchHistory = {},
    },
    -- Historical tracking (last 7 days)
    history = {},
    -- Persistent tracking
    killFeed = {},
    hotspots = {},
    nemesis = {},
    victims = {},
    -- Emperor tracking
    lastEmperor = nil,
}

-- ============================================
-- INITIALIZATION
-- ============================================
function NWT.InitPVPData()
    if not NWT.savedVars.pvp then
        NWT.savedVars.pvp = ZO_DeepTableCopy(NWT.PVP_DEFAULTS)
    end
    for k, v in pairs(NWT.PVP_DEFAULTS) do
        if NWT.savedVars.pvp[k] == nil then
            NWT.savedVars.pvp[k] = ZO_DeepTableCopy(v)
        end
    end
    
    -- Set login time
    NWT.PVP.loginTime = GetTimeStamp()
    
    -- Check if we need to reset "today" stats (new day)
    local today = GetDate()
    local pvp = NWT.savedVars.pvp
    if pvp.today.date ~= today then
        pvp.today = {
            date = today,
            apEarned = 0,
            kills = 0,
            deaths = 0,
            loginAP = GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_CHARACTER),
        }
    end
    
    -- Set first tracked time if not set
    if pvp.allTime.firstTracked == 0 then
        pvp.allTime.firstTracked = GetTimeStamp()
    end
    
    -- Initialize goals if missing
    if not pvp.goals then
        pvp.goals = { apTarget = 0, killTarget = 0 }
    end
    
    -- Initialize history if missing
    if not pvp.history then
        pvp.history = {}
    end
    
    -- Save yesterday's stats to history (if we have data)
    NWT.SaveDailyHistory()
    
    -- Fetch initial campaign data
    NWT.RefreshCampaignData()
end

-- ============================================
-- HISTORICAL TRACKING
-- ============================================
function NWT.SaveDailyHistory()
    local pvp = NWT.savedVars.pvp
    local today = GetDate()
    
    -- Only save if we have yesterday's data and it's a new day
    if pvp.today.date ~= "" and pvp.today.date ~= today then
        local entry = {
            date = pvp.today.date,
            ap = pvp.today.apEarned or 0,
            kills = pvp.today.kills or 0,
            deaths = pvp.today.deaths or 0,
        }
        table.insert(pvp.history, 1, entry)
        -- Keep only last 7 days
        while #pvp.history > 7 do table.remove(pvp.history) end
    end
end

function NWT.GetHistoryStats()
    local pvp = NWT.savedVars.pvp
    local totalAP, totalKills, totalDeaths, days = 0, 0, 0, 0
    for _, entry in ipairs(pvp.history or {}) do
        totalAP = totalAP + (entry.ap or 0)
        totalKills = totalKills + (entry.kills or 0)
        totalDeaths = totalDeaths + (entry.deaths or 0)
        days = days + 1
    end
    return {
        avgAP = days > 0 and math.floor(totalAP / days) or 0,
        avgKills = days > 0 and math.floor(totalKills / days) or 0,
        avgDeaths = days > 0 and math.floor(totalDeaths / days) or 0,
        totalDays = days,
    }
end

-- ============================================
-- CAMPAIGN DATA (Emperor, Scores, Scrolls)
-- ============================================
function NWT.RefreshCampaignData()
    local campaignId = GetCurrentCampaignId and GetCurrentCampaignId() or 0
    if campaignId == 0 then return end
    
    -- Get emperor info
    if DoesCurrentCampaignHaveEmperor then
        local hasEmperor = DoesCurrentCampaignHaveEmperor(campaignId)
        if hasEmperor and GetCampaignEmperorInfo then
            local emperorAlliance, emperorName, emperorDisplayName = GetCampaignEmperorInfo(campaignId)
            NWT.PVP.emperor = {
                name = emperorDisplayName or emperorName or "Unknown",
                alliance = emperorAlliance,
            }
        else
            NWT.PVP.emperor = nil
        end
    end
    
    -- Get campaign scores
    if GetCampaignAllianceScore then
        NWT.PVP.campaignScores = {
            [AD] = GetCampaignAllianceScore(campaignId, AD) or 0,
            [EP] = GetCampaignAllianceScore(campaignId, EP) or 0,
            [DC] = GetCampaignAllianceScore(campaignId, DC) or 0,
        }
    end
    
    -- Get scroll status (simplified - would need keep iteration for full data)
    NWT.PVP.scrolls = NWT.GetScrollStatus(campaignId)
end

function NWT.GetScrollStatus(campaignId)
    local scrolls = { ad = 0, ep = 0, dc = 0 }
    -- Scrolls are tracked through keeps - simplified count
    -- In full implementation, would iterate through GetNumKeeps and check scroll temples
    if GetNumArtifactScoreBonuses then
        scrolls.ad = GetNumArtifactScoreBonuses(campaignId, AD) or 0
        scrolls.ep = GetNumArtifactScoreBonuses(campaignId, EP) or 0
        scrolls.dc = GetNumArtifactScoreBonuses(campaignId, DC) or 0
    end
    return scrolls
end

function NWT.OnEmperorChanged(eventCode, campaignId)
    NWT.RefreshCampaignData()
    if NWT.PVP.isOpen then NWT.UpdatePVPDashboard() end
end

function NWT.OnCoronation(eventCode, campaignId, emperorName, emperorAlliance, emperorDisplayName)
    NWT.PVP.emperor = {
        name = emperorDisplayName or emperorName,
        alliance = emperorAlliance,
    }
    NWT.savedVars.pvp.lastEmperor = NWT.PVP.emperor
    if NWT.PVP.isOpen then NWT.UpdatePVPDashboard() end
end

function NWT.OnDeposition(eventCode, campaignId, emperorName, emperorAlliance, abdication, emperorDisplayName)
    NWT.PVP.emperor = nil
    if NWT.PVP.isOpen then NWT.UpdatePVPDashboard() end
end

function NWT.OnCampaignScoreChanged(eventCode)
    NWT.RefreshCampaignData()
    if NWT.PVP.isOpen then NWT.UpdatePVPDashboard() end
end

-- ============================================
-- SESSION GOALS
-- ============================================
function NWT.SetAPGoal(target)
    local pvp = NWT.savedVars.pvp
    pvp.goals.apTarget = target or 0
end

function NWT.SetKillGoal(target)
    local pvp = NWT.savedVars.pvp
    pvp.goals.killTarget = target or 0
end

function NWT.GetGoalProgress()
    local pvp = NWT.savedVars.pvp
    local goals = pvp.goals or {}
    local today = pvp.today or {}
    
    local apProg = goals.apTarget > 0 and math.min(100, (today.apEarned or 0) / goals.apTarget * 100) or 0
    local killProg = goals.killTarget > 0 and math.min(100, (today.kills or 0) / goals.killTarget * 100) or 0
    
    return {
        apTarget = goals.apTarget or 0,
        apCurrent = today.apEarned or 0,
        apPercent = apProg,
        killTarget = goals.killTarget or 0,
        killCurrent = today.kills or 0,
        killPercent = killProg,
    }
end

-- ============================================
-- AP TRACKING (Always On)
-- ============================================
function NWT.OnAPUpdate(eventCode, alliancePoints, playSound, difference, reason)
    if difference <= 0 then return end
    
    local pvp = NWT.savedVars.pvp
    pvp.allTime.apEarned = (pvp.allTime.apEarned or 0) + difference
    pvp.today.apEarned = (pvp.today.apEarned or 0) + difference
end

function NWT.GetAPPerHour()
    local pvp = NWT.savedVars.pvp
    if NWT.PVP.loginTime == 0 then return 0 end
    local elapsed = GetTimeStamp() - NWT.PVP.loginTime
    if elapsed < 60 then return 0 end
    return math.floor((pvp.today.apEarned or 0) / (elapsed / 3600))
end

function NWT.GetRankProgress()
    local currentAP = GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_CHARACTER)
    local rank, subRank = GetUnitAvARank("player")
    local rankName = GetAvARankName(GetUnitGender("player"), rank)
    local subRankStart, nextSubRank, rankStart, nextRank = GetAvARankProgress(currentAP)
    
    local progress = 0
    local toNext = 0
    if nextRank > rankStart then
        progress = (currentAP - rankStart) / (nextRank - rankStart)
        toNext = nextRank - currentAP
    end
    
    local nextRankName = rank < 50 and GetAvARankName(GetUnitGender("player"), rank + 1) or "Max Rank"
    
    return {
        rank = rank,
        rankName = rankName,
        nextRankName = nextRankName,
        progress = progress,
        toNextRank = toNext,
        currentAP = currentAP,
    }
end

-- ============================================
-- KILL/DEATH TRACKING (Always On)
-- ============================================
function NWT.OnPVPKillFeed(eventCode, killLocation, killerDisplayName, killerCharacterName, killerAlliance, killerRank, victimDisplayName, victimCharacterName, victimAlliance, victimRank, isKillLocation)
    -- Debug: uncomment next line to see if event fires
    -- d("[PVP DEBUG] Kill feed: " .. tostring(killerDisplayName) .. " killed " .. tostring(victimDisplayName))
    
    local pvp = NWT.savedVars.pvp
    local myDisplayName = GetDisplayName()
    
    -- Track Hotspots (Action Density)
    if isKillLocation and killLocation and killLocation ~= "" then
        pvp.hotspots = pvp.hotspots or {}
        if not pvp.hotspots[killLocation] then
            pvp.hotspots[killLocation] = { deaths = 0, lastUpdate = 0 }
        end
        pvp.hotspots[killLocation].deaths = pvp.hotspots[killLocation].deaths + 1
        pvp.hotspots[killLocation].lastUpdate = GetTimeStamp()
        
        -- Clean up old hotspots
        local now = GetTimeStamp()
        for loc, data in pairs(pvp.hotspots) do
            if now - data.lastUpdate > 600 then -- 10 minutes
                pvp.hotspots[loc] = nil
            end
        end
    end

    local entry = {
        timestamp = GetTimeStamp(),
        killerName = killerDisplayName,
        killerAlliance = killerAlliance,
        victimName = victimDisplayName,
        victimAlliance = victimAlliance,
    }
    
    if killerDisplayName == myDisplayName then
        entry.type = "kill"
        pvp.allTime.kills = (pvp.allTime.kills or 0) + 1
        pvp.today.kills = (pvp.today.kills or 0) + 1
        pvp.victims[victimDisplayName] = (pvp.victims[victimDisplayName] or 0) + 1
        table.insert(pvp.killFeed, 1, entry)
    elseif victimDisplayName == myDisplayName then
        entry.type = "death"
        pvp.allTime.deaths = (pvp.allTime.deaths or 0) + 1
        pvp.today.deaths = (pvp.today.deaths or 0) + 1
        pvp.nemesis[killerDisplayName] = (pvp.nemesis[killerDisplayName] or 0) + 1
        table.insert(pvp.killFeed, 1, entry)
    end
    
    while #pvp.killFeed > 100 do table.remove(pvp.killFeed) end
    
    if NWT.PVP.isOpen then NWT.UpdatePVPDashboard() end
end

function NWT.GetKDRatio(kills, deaths)
    return kills / math.max(1, deaths)
end

function NWT.GetNemesis()
    local pvp = NWT.savedVars.pvp
    local maxKills, nemesis = 0, nil
    for name, count in pairs(pvp.nemesis or {}) do
        if count > maxKills then maxKills, nemesis = count, name end
    end
    return nemesis, maxKills
end

function NWT.GetTopVictim()
    local pvp = NWT.savedVars.pvp
    local maxKills, victim = 0, nil
    for name, count in pairs(pvp.victims or {}) do
        if count > maxKills then maxKills, victim = count, name end
    end
    return victim, maxKills
end

function NWT.GetNearestKeepName(normalizedX, normalizedY)
    local numKeeps = GetNumKeeps and GetNumKeeps() or 0
    local closestKeep, closestDist = nil, 999
    
    for i = 1, numKeeps do
        local keepId, bgContext = GetKeepKeysByIndex(i)
        if keepId then
            local pinType, keepX, keepY = GetKeepPinInfo(keepId, bgContext)
            if keepX and keepY then
                local dist = math.sqrt((normalizedX - keepX)^2 + (normalizedY - keepY)^2)
                if dist < closestDist then
                    closestDist = dist
                    closestKeep = keepId
                end
            end
        end
    end
    
    -- Always return closest keep name if found (no distance limit)
    if closestKeep then
        local name = GetKeepName(closestKeep)
        if name and name ~= "" then
            return name
        end
    end
    return nil
end

function NWT.GetTopHotspots()
    -- Use campaign-wide kill location data (the crossed swords on map)
    local sorted = {}
    local numLocations = GetNumKillLocations and GetNumKillLocations() or 0
    
    for i = 1, numLocations do
        local pinType, normalizedX, normalizedY = GetKillLocationPinInfo(i)
        local adKills = GetNumKillLocationAllianceKills(i, ALLIANCE_ALDMERI_DOMINION) or 0
        local epKills = GetNumKillLocationAllianceKills(i, ALLIANCE_EBONHEART_PACT) or 0
        local dcKills = GetNumKillLocationAllianceKills(i, ALLIANCE_DAGGERFALL_COVENANT) or 0
        local totalKills = adKills + epKills + dcKills
        
        if totalKills > 0 then
            -- Find nearest keep to get location name
            local locationName = NWT.GetNearestKeepName(normalizedX, normalizedY) or "Open Field"
            table.insert(sorted, { 
                name = locationName, 
                deaths = totalKills,
                ad = adKills,
                ep = epKills,
                dc = dcKills,
                x = normalizedX,
                y = normalizedY,
                killLocationIndex = i,
            })
        end
    end
    
    table.sort(sorted, function(a, b) return a.deaths > b.deaths end)
    return sorted
end

-- ============================================
-- BATTLEGROUNDS TRACKING
-- ============================================
function NWT.OnBattlegroundStateChanged(eventCode, previousState, currentState)
    local pvp = NWT.savedVars.pvp
    local bg = pvp.battlegrounds
    
    if currentState == BATTLEGROUND_STATE_RUNNING then
        -- Match started
        NWT.PVP.inBattleground = true
        NWT.PVP.bgStartTime = GetTimeStamp()
    elseif currentState == BATTLEGROUND_STATE_POSTGAME then
        -- Match ended
        NWT.PVP.inBattleground = false
        bg.matches = (bg.matches or 0) + 1
        
        -- Determine if we won
        if GetBattlegroundLocalPlayerTeam and GetBattlegroundWinningTeam then
            local myTeam = GetBattlegroundLocalPlayerTeam()
            local winningTeam = GetBattlegroundWinningTeam()
            if myTeam == winningTeam then
                bg.wins = (bg.wins or 0) + 1
            else
                bg.losses = (bg.losses or 0) + 1
            end
        end
        
        -- Get match stats
        if GetScoreboardEntryInfo then
            local numEntries = GetNumScoreboardEntries and GetNumScoreboardEntries() or 0
            for i = 1, numEntries do
                local characterName, displayName, battlegroundTeam, isLocalPlayer = GetScoreboardEntryInfo(i)
                if isLocalPlayer then
                    local kills = GetScoreboardEntryScoreByType(i, SCORE_TRACKER_TYPE_KILL) or 0
                    local deaths = GetScoreboardEntryScoreByType(i, SCORE_TRACKER_TYPE_DEATH) or 0
                    local assists = GetScoreboardEntryScoreByType(i, SCORE_TRACKER_TYPE_ASSIST) or 0
                    local score = GetScoreboardEntryScoreByType(i, SCORE_TRACKER_TYPE_SCORE) or 0
                    local medals = GetScoreboardEntryNumMedals and GetScoreboardEntryNumMedals(i) or 0
                    
                    bg.kills = (bg.kills or 0) + kills
                    bg.deaths = (bg.deaths or 0) + deaths
                    bg.assists = (bg.assists or 0) + assists
                    bg.totalScore = (bg.totalScore or 0) + score
                    bg.medals = (bg.medals or 0) + medals
                    
                    -- Save to match history
                    local matchEntry = {
                        timestamp = GetTimeStamp(),
                        kills = kills,
                        deaths = deaths,
                        assists = assists,
                        score = score,
                        won = GetBattlegroundLocalPlayerTeam() == GetBattlegroundWinningTeam(),
                    }
                    table.insert(bg.matchHistory, 1, matchEntry)
                    while #bg.matchHistory > 20 do table.remove(bg.matchHistory) end
                    break
                end
            end
        end
    end
    
    if NWT.PVP.isOpen then NWT.UpdatePVPDashboard() end
end

function NWT.OnBattlegroundKill(eventCode, killedName, killedDisplayName, killedTeam, killerName, killerDisplayName, killerTeam, killType, killingAbilityId)
    -- Track kills/deaths during BG
    local pvp = NWT.savedVars.pvp
    local myDisplayName = GetDisplayName()
    
    if killerDisplayName == myDisplayName then
        -- We got a kill in BG - also counts toward today's stats
        pvp.today.kills = (pvp.today.kills or 0) + 1
        pvp.allTime.kills = (pvp.allTime.kills or 0) + 1
    elseif killedDisplayName == myDisplayName then
        -- We died in BG
        pvp.today.deaths = (pvp.today.deaths or 0) + 1
        pvp.allTime.deaths = (pvp.allTime.deaths or 0) + 1
    end
    
    if NWT.PVP.isOpen then NWT.UpdatePVPDashboard() end
end

function NWT.GetBGStats()
    local pvp = NWT.savedVars.pvp
    local bg = pvp.battlegrounds or {}
    
    local winRate = bg.matches > 0 and (bg.wins / bg.matches * 100) or 0
    local kd = NWT.GetKDRatio(bg.kills or 0, bg.deaths or 0)
    local avgScore = bg.matches > 0 and math.floor((bg.totalScore or 0) / bg.matches) or 0
    
    return {
        matches = bg.matches or 0,
        wins = bg.wins or 0,
        losses = bg.losses or 0,
        winRate = winRate,
        kills = bg.kills or 0,
        deaths = bg.deaths or 0,
        assists = bg.assists or 0,
        kd = kd,
        medals = bg.medals or 0,
        avgScore = avgScore,
    }
end

-- ============================================
-- TEL VAR TRACKING
-- ============================================
function NWT.GetTelVarInfo()
    local current = GetCurrencyAmount(CURT_TELVAR_STONES, CURRENCY_LOCATION_CHARACTER)
    local multiplier = 1
    if current >= 10000 then multiplier = 4
    elseif current >= 1000 then multiplier = 3
    elseif current >= 100 then multiplier = 2
    end
    local riskAmount = math.floor(current * 0.5)
    
    local tierColor = "00FF00"
    if current >= 10000 then tierColor = "FFD700"
    elseif current >= 1000 then tierColor = "9932CC"
    elseif current >= 100 then tierColor = "4169E1"
    end
    
    return { current = current, multiplier = multiplier, riskAmount = riskAmount, tierColor = tierColor }
end

-- ============================================
-- ALLIANCE COLORS
-- ============================================
local ALLIANCE_COLORS = {
    [ALLIANCE_ALDMERI_DOMINION] = "FFCC00",
    [ALLIANCE_EBONHEART_PACT] = "FF4444",
    [ALLIANCE_DAGGERFALL_COVENANT] = "4488FF",
}

function NWT.GetAllianceColor(alliance)
    return ALLIANCE_COLORS[alliance] or "FFFFFF"
end

-- ============================================
-- UI UPDATE
-- ============================================
function NWT.UpdatePVPDashboard()
    local ui = ATK_PVP_UI
    if not ui then return end
    
    local pvp = NWT.savedVars.pvp
    local allTime = pvp.allTime or {}
    local today = pvp.today or {}
    
    -- Determine which tab we're on
    local isCyrodiilTab = NWT.PVP.currentTab == 1
    local isBattlegroundsTab = NWT.PVP.currentTab == 2
    local isLeaderboardsTab = NWT.PVP.currentTab == 3
    
    -- Header subtitle - show current zone or "Battlegrounds"
    local headerCtrl = ui:GetNamedChild("Header")
    if headerCtrl then
        local title = headerCtrl:GetNamedChild("Title")
        local subtitle = headerCtrl:GetNamedChild("Subtitle")
        
        if isCyrodiilTab then
            if title then title:SetText("CYRODIIL STATS") end
            if subtitle then
                local zoneName = GetPlayerActiveZoneName and GetPlayerActiveZoneName() or ""
                subtitle:SetText(zoneName)
            end
        elseif isBattlegroundsTab then
            if title then title:SetText("BATTLEGROUNDS") end
            if subtitle then subtitle:SetText("Match Statistics") end
        else
            if title then title:SetText("LEADERBOARDS") end
            local lbTypeName = NWT.GetBGLeaderboardTypeName(NWT.PVP.leaderboardType)
            if subtitle then subtitle:SetText(lbTypeName) end
        end
    end
    
    -- Get shared data
    local elapsed = GetTimeStamp() - NWT.PVP.loginTime
    local sessionTime = string.format("%dh %02dm", math.floor(elapsed / 3600), math.floor((elapsed % 3600) / 60))
    local apPerHour = NWT.GetAPPerHour()
    local rankInfo = NWT.GetRankProgress()
    local todayKD = NWT.GetKDRatio(today.kills or 0, today.deaths or 0)
    local allTimeKD = NWT.GetKDRatio(allTime.kills or 0, allTime.deaths or 0)
    local nemesis, nemesisKills = NWT.GetNemesis()
    local victim, victimKills = NWT.GetTopVictim()
    local telVar = NWT.GetTelVarInfo()
    local goals = NWT.GetGoalProgress()
    local history = NWT.GetHistoryStats()
    local bgStats = NWT.GetBGStats()
    
    local content = ui:GetNamedChild("Content")
    if not content then return end
    
    -- Reset CenterCol layout (Leaderboards tab modifies anchors/dimensions)
    local centerCol = content:GetNamedChild("CenterCol")
    if centerCol then
        centerCol:ClearAnchors()
        centerCol:SetAnchor(TOP, content, TOP, 0, 0)
        centerCol:SetDimensions(440, 620)
        
        local dividerReset = centerCol:GetNamedChild("Divider")
        if dividerReset then dividerReset:SetHidden(false) end
        local campaignReset = centerCol:GetNamedChild("CampaignLabel")
        if campaignReset then campaignReset:SetHidden(false) end
        local emperorReset = centerCol:GetNamedChild("EmperorLabel")
        if emperorReset then emperorReset:SetHidden(false) end
        local scoresReset = centerCol:GetNamedChild("ScoresLabel")
        if scoresReset then scoresReset:SetHidden(false) end
        
        local popHeader = centerCol:GetNamedChild("PopHeader")
        if popHeader then
            popHeader:ClearAnchors()
            popHeader:SetAnchor(TOP, centerCol, TOP, 0, 155)
            popHeader:SetHidden(false)
            popHeader:SetText("FACTION POPULATION")
        end
        local popAD = centerCol:GetNamedChild("PopAD")
        if popAD then
            popAD:ClearAnchors()
            popAD:SetAnchor(TOP, centerCol, TOP, 0, 190)
            popAD:SetDimensions(400, 35)
            popAD:SetHidden(false)
        end
        local popEP = centerCol:GetNamedChild("PopEP")
        if popEP then popEP:SetHidden(false) end
        local popDC = centerCol:GetNamedChild("PopDC")
        if popDC then popDC:SetHidden(false) end
        local divider2 = centerCol:GetNamedChild("Divider2")
        if divider2 then divider2:SetHidden(false) end
        local quietHeader = centerCol:GetNamedChild("QuietHeader")
        if quietHeader then
            quietHeader:ClearAnchors()
            quietHeader:SetAnchor(TOP, centerCol, TOP, 0, 320)
            quietHeader:SetHidden(false)
            quietHeader:SetText("QUIET KEEPS")
        end
        local quietSub = centerCol:GetNamedChild("QuietSubHeader")
        if quietSub then quietSub:SetHidden(false) end
        local quietList = centerCol:GetNamedChild("QuietList")
        if quietList then
            quietList:ClearAnchors()
            quietList:SetAnchor(TOP, centerCol, TOP, 0, 375)
            quietList:SetDimensions(420, 250)
            quietList:SetHidden(false)
        end
    end
    
    if isCyrodiilTab then
        -- ========== CYRODIIL TAB ==========
        
        -- LEFT COLUMN: Today's Stats + Goals
        local leftCol = content:GetNamedChild("LeftCol")
        if leftCol then
            leftCol:SetHidden(false)
            
            local timeLabel = leftCol:GetNamedChild("TimeLabel")
            if timeLabel then timeLabel:SetText("|cFFFFFFOnline:|r " .. sessionTime) end
            
            local apLabel = leftCol:GetNamedChild("APLabel")
            if apLabel then 
                local apText = "|cFFFFFFAP Earned:|r |cFFD700" .. ZO_CommaDelimitNumber(today.apEarned or 0) .. "|r"
                if goals.apTarget > 0 then
                    apText = apText .. " |c888888(" .. string.format("%.0f%%", goals.apPercent) .. ")|r"
                end
                apLabel:SetText(apText)
            end
            
            local aphrLabel = leftCol:GetNamedChild("APHrLabel")
            if aphrLabel then aphrLabel:SetText("|cFFFFFFAP/Hour:|r |c00FF00" .. ZO_CommaDelimitNumber(apPerHour) .. "|r") end
            
            local killsLabel = leftCol:GetNamedChild("KillsLabel")
            if killsLabel then 
                local killText = "|c00FF00Kills:|r " .. (today.kills or 0)
                if goals.killTarget > 0 then
                    killText = killText .. " |c888888(" .. string.format("%.0f%%", goals.killPercent) .. ")|r"
                end
                killsLabel:SetText(killText)
            end
            
            local deathsLabel = leftCol:GetNamedChild("DeathsLabel")
            if deathsLabel then deathsLabel:SetText("|cFF4444Deaths:|r " .. (today.deaths or 0)) end
            
            local kdLabel = leftCol:GetNamedChild("KDLabel")
            if kdLabel then kdLabel:SetText("|cFFFFFFRatio:|r |cFFD700" .. string.format("%.2f", todayKD) .. "|r K/D") end
            
            local nemLabel = leftCol:GetNamedChild("NemesisLabel")
            if nemLabel then 
                local nemText = nemesis and ("|cFF4444" .. nemesis .. "|r (" .. nemesisKills .. ")") or "|c555555None|r"
                nemLabel:SetText("|cFFFFFFNemesis:|r " .. nemText)
            end
            
            local vicLabel = leftCol:GetNamedChild("VictimLabel")
            if vicLabel then
                local vicText = victim and ("|c00FF00" .. victim .. "|r (" .. victimKills .. ")") or "|c555555None|r"
                vicLabel:SetText("|cFFFFFFVictim:|r " .. vicText)
            end
            
            local telLabel = leftCol:GetNamedChild("TelVarLabel")
            if telLabel then
                if telVar.current > 0 then
                    telLabel:SetText("|c9932CCTel Var:|r |c" .. telVar.tierColor .. ZO_CommaDelimitNumber(telVar.current) .. "|r")
                else
                    telLabel:SetText("|c555555Tel Var: N/A|r")
                end
            end
            
            local riskLabel = leftCol:GetNamedChild("TelVarRiskLabel")
            if riskLabel then
                if telVar.current > 0 then
                    riskLabel:SetText("|cFF4444Risk:|r " .. ZO_CommaDelimitNumber(telVar.riskAmount) .. " (" .. telVar.multiplier .. "x)")
                else
                    riskLabel:SetText("")
                end
            end
        end
        
        -- CENTER COLUMN: Campaign Info, Population, Quiet Keeps
        local centerCol = content:GetNamedChild("CenterCol")
        if centerCol then
            centerCol:SetHidden(false)
            
            -- Campaign and Emperor info
            local campaignId = GetCurrentCampaignId and GetCurrentCampaignId() or 0
            local campaignName = (campaignId > 0 and GetCampaignName) and GetCampaignName(campaignId) or "Not in Cyrodiil"
            
            local campLabel = centerCol:GetNamedChild("CampaignLabel")
            if campLabel then campLabel:SetText("|cFFD700" .. campaignName .. "|r") end
            
            -- Emperor display
            local empLabel = centerCol:GetNamedChild("EmperorLabel")
            if empLabel then
                if NWT.PVP.emperor then
                    local empColor = NWT.GetAllianceColor(NWT.PVP.emperor.alliance)
                    empLabel:SetText("|cFFD700Emperor:|r |c" .. empColor .. NWT.PVP.emperor.name .. "|r")
                else
                    empLabel:SetText("|c555555No Emperor|r")
                end
            end
            
            -- Campaign scores
            local scoresLabel = centerCol:GetNamedChild("ScoresLabel")
            if scoresLabel then
                local scores = NWT.PVP.campaignScores or {}
                local adScore = scores[AD] or 0
                local epScore = scores[EP] or 0
                local dcScore = scores[DC] or 0
                if adScore > 0 or epScore > 0 or dcScore > 0 then
                    scoresLabel:SetText("|cFFCC00AD|r " .. adScore .. "  |cFF4444EP|r " .. epScore .. "  |c4488FFDC|r " .. dcScore)
                else
                    scoresLabel:SetText("|c555555Scores unavailable|r")
                end
            end
            
            -- Faction Population
            local campaignIndex = nil
            if GetNumSelectionCampaigns then
                for i = 1, GetNumSelectionCampaigns() do
                    local id = GetSelectionCampaignId(i)
                    if id == campaignId then campaignIndex = i break end
                end
            end
            
            local popAD = centerCol:GetNamedChild("PopAD")
            local popEP = centerCol:GetNamedChild("PopEP")
            local popDC = centerCol:GetNamedChild("PopDC")
            
            if campaignIndex and GetSelectionCampaignPopulationData then
                local adPop = GetSelectionCampaignPopulationData(campaignIndex, ALLIANCE_ALDMERI_DOMINION)
                local epPop = GetSelectionCampaignPopulationData(campaignIndex, ALLIANCE_EBONHEART_PACT)
                local dcPop = GetSelectionCampaignPopulationData(campaignIndex, ALLIANCE_DAGGERFALL_COVENANT)
                if popAD then popAD:SetText("AD: " .. NWT.GetPopulationText(adPop)) end
                if popEP then popEP:SetText("EP: " .. NWT.GetPopulationText(epPop)) end
                if popDC then popDC:SetText("DC: " .. NWT.GetPopulationText(dcPop)) end
            else
                if popAD then popAD:SetText("AD: --") end
                if popEP then popEP:SetText("EP: --") end
                if popDC then popDC:SetText("DC: --") end
            end
            
            -- Quiet Keeps (no fighting nearby)
            local quietKeeps = NWT.GetQuietKeeps()
            local quietList = centerCol:GetNamedChild("QuietList")
            if quietList then
                local playerAlliance = GetUnitAlliance("player")
                for i = 1, 7 do
                    local row = quietList:GetNamedChild("Row" .. i)
                    if row then
                        local keep = quietKeeps[i]
                        if keep then
                            local allyColor = NWT.GetAllianceColor(keep.alliance)
                            local isEnemy = keep.alliance ~= playerAlliance and keep.alliance ~= 0
                            local prefix = isEnemy and "|cFF4444[ATTACK]|r " or ""
                            row:SetText(prefix .. "|c" .. allyColor .. keep.name .. "|r")
                            row:SetHidden(false)
                        else
                            row:SetHidden(true)
                        end
                    end
                end
            end
        end
        
        -- RIGHT: Hotspots & Kill Feed
        local rightCol = content:GetNamedChild("RightCol")
        if rightCol then
            rightCol:SetHidden(false)
            
            local hotspots = NWT.GetTopHotspots()
            NWT.PVP.hotspotData = hotspots
            if NWT.PVP.hotspotIndex > #hotspots then NWT.PVP.hotspotIndex = math.max(1, #hotspots) end
            
            local hotspotList = rightCol:GetNamedChild("HotspotList")
            if hotspotList then
                for i = 1, 5 do
                    local row = hotspotList:GetNamedChild("Row" .. i)
                    if row then
                        local data = hotspots[i]
                        if data then
                            -- Show location name with alliance kill breakdown
                            local selected = (i == NWT.PVP.hotspotIndex)
                            local prefix = selected and "|cFFFF00> |r" or "  "
                            local nameColor = selected and "FFFF00" or "FFFFFF"
                            local text = prefix .. "|c" .. nameColor .. data.name .. "|r: "
                            text = text .. "|cFFCC00" .. (data.ad or 0) .. "|r/|cFF4444" .. (data.ep or 0) .. "|r/|c4488FF" .. (data.dc or 0) .. "|r"
                            row:SetText(text)
                            row:SetHidden(false)
                        else
                            row:SetHidden(true)
                        end
                    end
                end
            end

            local list = rightCol:GetNamedChild("List")
            if list then
                local feed = pvp.killFeed or {}
                local emptyLabel = list:GetNamedChild("Empty")
                
                if #feed == 0 then
                    if emptyLabel then emptyLabel:SetHidden(false) end
                else
                    if emptyLabel then emptyLabel:SetHidden(true) end
                end
                
                for i = 1, 9 do
                    local row = list:GetNamedChild("Row" .. i)
                    if row then
                        local entry = feed[i]
                        if entry then
                            local timeAgo = GetTimeStamp() - entry.timestamp
                            local timeStr = timeAgo < 60 and (timeAgo .. "s") or (timeAgo < 3600 and (math.floor(timeAgo / 60) .. "m") or (math.floor(timeAgo / 3600) .. "h"))
                            
                            if entry.type == "kill" then
                                row:SetText("|c00FF00▲|r |c" .. NWT.GetAllianceColor(entry.victimAlliance) .. entry.victimName .. "|r |c555555" .. timeStr .. "|r")
                            else
                                row:SetText("|cFF4444▼|r |c" .. NWT.GetAllianceColor(entry.killerAlliance) .. entry.killerName .. "|r |c555555" .. timeStr .. "|r")
                            end
                            row:SetHidden(false)
                        else
                            row:SetText("")
                            row:SetHidden(true)
                        end
                    end
                end
            end
        end
        
    elseif isBattlegroundsTab then
        -- ========== BATTLEGROUNDS TAB ==========
        
        local leftCol = content:GetNamedChild("LeftCol")
        if leftCol then
            leftCol:SetHidden(false)
            
            local timeLabel = leftCol:GetNamedChild("TimeLabel")
            if timeLabel then timeLabel:SetText("|cFFFFFFMatches:|r " .. bgStats.matches) end
            
            local apLabel = leftCol:GetNamedChild("APLabel")
            if apLabel then apLabel:SetText("|c00FF00Wins:|r " .. bgStats.wins .. " |c888888(" .. string.format("%.1f%%", bgStats.winRate) .. ")|r") end
            
            local aphrLabel = leftCol:GetNamedChild("APHrLabel")
            if aphrLabel then aphrLabel:SetText("|cFF4444Losses:|r " .. bgStats.losses) end
            
            local killsLabel = leftCol:GetNamedChild("KillsLabel")
            if killsLabel then killsLabel:SetText("|c00FF00Kills:|r " .. bgStats.kills) end
            
            local deathsLabel = leftCol:GetNamedChild("DeathsLabel")
            if deathsLabel then deathsLabel:SetText("|cFF4444Deaths:|r " .. bgStats.deaths) end
            
            local kdLabel = leftCol:GetNamedChild("KDLabel")
            if kdLabel then kdLabel:SetText("|cFFFFFFRatio:|r |cFFD700" .. string.format("%.2f", bgStats.kd) .. "|r K/D") end
            
            local nemLabel = leftCol:GetNamedChild("NemesisLabel")
            if nemLabel then nemLabel:SetText("|c00FFFFAssists:|r " .. bgStats.assists) end
            
            local vicLabel = leftCol:GetNamedChild("VictimLabel")
            if vicLabel then vicLabel:SetText("|cFFD700Medals:|r " .. bgStats.medals) end
            
            local telLabel = leftCol:GetNamedChild("TelVarLabel")
            if telLabel then telLabel:SetText("|cFFFFFFAvg Score:|r " .. bgStats.avgScore) end
            
            local riskLabel = leftCol:GetNamedChild("TelVarRiskLabel")
            if riskLabel then riskLabel:SetText("") end
        end
        
        -- Center column: Recent match history
        local centerCol = content:GetNamedChild("CenterCol")
        if centerCol then
            centerCol:SetHidden(false)
            
            local totalAPLabel = centerCol:GetNamedChild("TotalAPLabel")
            if totalAPLabel then totalAPLabel:SetText("|cFFFFFFRECENT MATCHES|r") end
            
            -- Show last 5 matches in available labels
            local bg = pvp.battlegrounds or {}
            local matchHist = bg.matchHistory or {}
            
            local labels = {"TotalKillsLabel", "TotalDeathsLabel", "TotalKDLabel", "RankLabel", "RankProgressLabel"}
            for i, labelName in ipairs(labels) do
                local label = centerCol:GetNamedChild(labelName)
                if label then
                    local match = matchHist[i]
                    if match then
                        local result = match.won and "|c00FF00W|r" or "|cFF4444L|r"
                        label:SetText(result .. " K:" .. match.kills .. " D:" .. match.deaths .. " S:" .. match.score)
                    else
                        label:SetText("")
                    end
                end
            end
            
            local rankToNextLabel = centerCol:GetNamedChild("RankToNextLabel")
            if rankToNextLabel then rankToNextLabel:SetText("") end
            
            local campLabel = centerCol:GetNamedChild("CampaignLabel")
            if campLabel then campLabel:SetText("") end
            
            local allyLabel = centerCol:GetNamedChild("AllianceLabel")
            if allyLabel then allyLabel:SetText("") end
            
            local empLabel = centerCol:GetNamedChild("EmperorLabel")
            if empLabel then empLabel:SetText("") end
            
            local scoresLabel = centerCol:GetNamedChild("ScoresLabel")
            if scoresLabel then scoresLabel:SetText("") end
        end
        
        -- Right column: Show leaderboard (or fallback to 7-day averages if not available)
        local rightCol = content:GetNamedChild("RightCol")
        if rightCol then
            rightCol:SetHidden(false)
            
            local hotspotList = rightCol:GetNamedChild("HotspotList")
            local list = rightCol:GetNamedChild("List")
            
            if NWT.PVP.leaderboardsAvailable and QueryBattlegroundLeaderboardData then
                -- Query leaderboard if not already loaded
                local lbType = NWT.PVP.leaderboardType
                if not NWT.PVP.leaderboardData[lbType] then
                    NWT.QueryBGLeaderboard(lbType)
                end
                
                -- Get player's leaderboard info
                local myRank, myScore = NWT.GetBGLeaderboardPlayerInfo(lbType)
                local lbTypeName = NWT.GetBGLeaderboardTypeName(lbType)
                local secondsUntilEnd, _ = NWT.GetBGLeaderboardSchedule(lbType)
                
                -- Show leaderboard header in hotspot list area
                if hotspotList then
                    local row1 = hotspotList:GetNamedChild("Row1")
                    if row1 then 
                        row1:SetText("|cFFD700LEADERBOARD:|r |c00FFFF" .. lbTypeName .. "|r")
                        row1:SetHidden(false) 
                    end
                    
                    local row2 = hotspotList:GetNamedChild("Row2")
                    if row2 then 
                        if myRank > 0 then
                            row2:SetText("|cFFFFFFYour Rank:|r |cFFD700#" .. myRank .. "|r  Score: |c00FF00" .. ZO_CommaDelimitNumber(myScore) .. "|r")
                        else
                            row2:SetText("|c888888Not ranked this week|r")
                        end
                        row2:SetHidden(false) 
                    end
                    
                    local row3 = hotspotList:GetNamedChild("Row3")
                    if row3 then
                        if secondsUntilEnd > 0 then
                            local hours = math.floor(secondsUntilEnd / 3600)
                            local days = math.floor(hours / 24)
                            local timeStr = days > 0 and (days .. "d " .. (hours % 24) .. "h") or (hours .. "h")
                            row3:SetText("|c888888Resets in:|r " .. timeStr)
                        else
                            row3:SetText("")
                        end
                        row3:SetHidden(false)
                    end
                    
                    local row4 = hotspotList:GetNamedChild("Row4")
                    if row4 then row4:SetText("|c555555[D-Pad] Cycle Type|r"); row4:SetHidden(false) end
                    
                    local row5 = hotspotList:GetNamedChild("Row5")
                    if row5 then row5:SetText(""); row5:SetHidden(true) end
                end
                
                -- Show top leaderboard entries in list area
                if list then
                    local emptyLabel = list:GetNamedChild("Empty")
                    local entries = NWT.PVP.leaderboardData[lbType] or {}
                    
                    if #entries == 0 then
                        if emptyLabel then 
                            emptyLabel:SetText("|c888888Loading leaderboard...|r")
                            emptyLabel:SetHidden(false) 
                        end
                    else
                        if emptyLabel then emptyLabel:SetHidden(true) end
                    end
                    
                    -- Show top 9 entries
                    for i = 1, 9 do
                        local row = list:GetNamedChild("Row" .. i)
                        if row then
                            local entry = entries[i]
                            if entry then
                                local rankColor = "FFFFFF"
                                if entry.rank == 1 then rankColor = "FFD700"
                                elseif entry.rank == 2 then rankColor = "C0C0C0"
                                elseif entry.rank == 3 then rankColor = "CD7F32"
                                elseif entry.rank <= 10 then rankColor = "00FFFF"
                                end
                                
                                local displayName = entry.displayName or "Unknown"
                                if #displayName > 18 then displayName = displayName:sub(1, 16) .. ".." end
                                
                                row:SetText("|c" .. rankColor .. "#" .. entry.rank .. "|r " .. displayName .. " |c00FF00" .. ZO_CommaDelimitNumber(entry.score) .. "|r")
                                row:SetHidden(false)
                            else
                                row:SetHidden(true)
                            end
                        end
                    end
                end
            else
                -- Fallback: Show 7-day averages (leaderboard API not available)
                if hotspotList then
                    local row1 = hotspotList:GetNamedChild("Row1")
                    if row1 then row1:SetText("|cFFFFFF7-DAY AVERAGES|r"); row1:SetHidden(false) end
                    
                    local row2 = hotspotList:GetNamedChild("Row2")
                    if row2 then row2:SetText("|cFFD700Avg AP:|r " .. ZO_CommaDelimitNumber(history.avgAP)); row2:SetHidden(false) end
                    
                    local row3 = hotspotList:GetNamedChild("Row3")
                    if row3 then row3:SetText("|c00FF00Avg Kills:|r " .. history.avgKills); row3:SetHidden(false) end
                    
                    local row4 = hotspotList:GetNamedChild("Row4")
                    if row4 then row4:SetText("|cFF4444Avg Deaths:|r " .. history.avgDeaths); row4:SetHidden(false) end
                    
                    local row5 = hotspotList:GetNamedChild("Row5")
                    if row5 then row5:SetText("|c888888(" .. history.totalDays .. " days tracked)|r"); row5:SetHidden(false) end
                end
                
                -- Clear list area
                if list then
                    local emptyLabel = list:GetNamedChild("Empty")
                    if emptyLabel then emptyLabel:SetHidden(true) end
                    for i = 1, 9 do
                        local row = list:GetNamedChild("Row" .. i)
                        if row then row:SetHidden(true) end
                    end
                end
            end
        end
    elseif isLeaderboardsTab then
        -- ========== LEADERBOARDS TAB ==========
        -- Use CENTER column as the main large panel, hide left and right
        
        local lbType = NWT.PVP.leaderboardType or 1
        local lbIndex = NWT.PVP.leaderboardIndex or 1
        local lbNames = {"Competitive", "Deathmatch", "Flag Games", "Land Grab"}
        local lbName = lbNames[lbIndex] or "Competitive"
        if BG_LEADERBOARD_TYPES and BG_LEADERBOARD_TYPES[lbIndex] then
            lbName = BG_LEADERBOARD_TYPES[lbIndex].name or lbName
        end
        
        -- Query leaderboard data if API available
        if NWT.PVP.leaderboardsAvailable and not NWT.PVP.leaderboardData[lbType] then
            NWT.QueryBGLeaderboard(lbType)
        end
        
        local myRank, myScore = 0, 0
        local secondsUntilEnd = 0
        if NWT.PVP.leaderboardsAvailable then
            myRank, myScore = NWT.GetBGLeaderboardPlayerInfo(lbType)
            secondsUntilEnd, _ = NWT.GetBGLeaderboardSchedule(lbType)
        end
        
        -- Hide side columns
        local leftCol = content:GetNamedChild("LeftCol")
        if leftCol then leftCol:SetHidden(true) end
        
        local rightCol = content:GetNamedChild("RightCol")
        if rightCol then rightCol:SetHidden(true) end
        
        -- Use center column as main leaderboard display
        local centerCol = content:GetNamedChild("CenterCol")
        if centerCol then
            centerCol:SetHidden(false)
            -- Reposition to center and make wider
            centerCol:ClearAnchors()
            centerCol:SetAnchor(TOP, content, TOP, 0, 0)
            centerCol:SetDimensions(900, 620)
            
            -- Hide Cyrodiil-specific labels
            local campaignLabel = centerCol:GetNamedChild("CampaignLabel")
            if campaignLabel then campaignLabel:SetHidden(true) end
            local emperorLabel = centerCol:GetNamedChild("EmperorLabel")
            if emperorLabel then emperorLabel:SetHidden(true) end
            local scoresLabel = centerCol:GetNamedChild("ScoresLabel")
            if scoresLabel then scoresLabel:SetHidden(true) end
            local divider = centerCol:GetNamedChild("Divider")
            if divider then divider:SetHidden(true) end
            
            -- Repurpose PopHeader for leaderboard type selector
            local popHeader = centerCol:GetNamedChild("PopHeader")
            if popHeader then
                popHeader:SetHidden(false)
                popHeader:SetText("|cFFD700< |c00FFFF" .. lbName .. "|r |cFFD700>|r")
                popHeader:ClearAnchors()
                popHeader:SetAnchor(TOP, centerCol, TOP, 0, 25)
            end
            
            -- Repurpose PopAD for player rank
            local popAD = centerCol:GetNamedChild("PopAD")
            if popAD then
                popAD:SetHidden(false)
                local rankText = myRank > 0 and ("|cFFD700Your Rank: #" .. myRank .. " |c00FF00Score: " .. ZO_CommaDelimitNumber(myScore) .. "|r") or "|c888888Not Ranked Yet|r"
                popAD:SetText(rankText)
                popAD:ClearAnchors()
                popAD:SetAnchor(TOP, centerCol, TOP, 0, 70)
            end
            
            -- Hide EP and DC labels
            local popEP = centerCol:GetNamedChild("PopEP")
            if popEP then popEP:SetHidden(true) end
            local popDC = centerCol:GetNamedChild("PopDC")
            if popDC then popDC:SetHidden(true) end
            
            -- Hide divider2
            local divider2 = centerCol:GetNamedChild("Divider2")
            if divider2 then divider2:SetHidden(true) end
            
            -- Repurpose QuietHeader for TOP PLAYERS header
            local quietHeader = centerCol:GetNamedChild("QuietHeader")
            if quietHeader then
                quietHeader:SetHidden(false)
                quietHeader:SetText("|cFFD700TOP PLAYERS|r")
                quietHeader:ClearAnchors()
                quietHeader:SetAnchor(TOP, centerCol, TOP, 0, 120)
            end
            
            -- Hide QuietSubHeader
            local quietSub = centerCol:GetNamedChild("QuietSubHeader")
            if quietSub then quietSub:SetHidden(true) end
            
            -- Use QuietList for leaderboard entries
            local quietList = centerCol:GetNamedChild("QuietList")
            if quietList then
                quietList:SetHidden(false)
                quietList:ClearAnchors()
                quietList:SetAnchor(TOP, centerCol, TOP, 0, 160)
                quietList:SetDimensions(850, 420)
                
                local entries = NWT.PVP.leaderboardData[lbType] or {}
                
                for i = 1, 7 do
                    local row = quietList:GetNamedChild("Row" .. i)
                    if row then
                        local entry = entries[i]
                        if entry then
                            local rankColor = "FFFFFF"
                            if entry.rank == 1 then rankColor = "FFD700"
                            elseif entry.rank == 2 then rankColor = "C0C0C0"
                            elseif entry.rank == 3 then rankColor = "CD7F32"
                            elseif entry.rank <= 10 then rankColor = "00FFFF"
                            end
                            
                            local displayName = entry.displayName or "Unknown"
                            if #displayName > 25 then displayName = displayName:sub(1, 23) .. ".." end
                            local scoreStr = ZO_CommaDelimitNumber(entry.score)
                            
                            local rankStr = string.format("|c%s#%-2d|r", rankColor, entry.rank)
                            row:SetText(rankStr .. "  " .. displayName .. "   |c00FF00" .. scoreStr .. "|r")
                            row:SetHidden(false)
                        elseif i == 1 and #entries == 0 then
                            row:SetText("|c888888Loading leaderboard...|r")
                            row:SetHidden(false)
                        else
                            row:SetHidden(true)
                        end
                    end
                end
            end
        end
    end
    
    -- Footer - show tab switch hint
    local footer = ui:GetNamedChild("Footer")
    if footer then
        local nextTab = NWT.PVP.tabs[(NWT.PVP.currentTab % #NWT.PVP.tabs) + 1]
        local mapHint = isCyrodiilTab and "|cFF6600[A]|r Show on Map   " or ""
        local dpadHint = isLeaderboardsTab and "|cFF6600[D-Pad]|r Change Type   " or ""
        footer:SetText(mapHint .. dpadHint .. "|cFF6600[LB/RB]|r " .. nextTab .. "   |cFF6600[X]|r Refresh   |c888888[B] Back|r")
    end
end

-- ============================================
-- SCENE MANAGEMENT
-- ============================================
function NWT.GetQuietKeeps()
    -- Find keeps that are NOT under attack and have no nearby kill locations
    local quietKeeps = {}
    local numKeeps = GetNumKeeps and GetNumKeeps() or 0
    local killLocations = {}
    
    -- Build list of kill location coordinates
    local numKillLocs = GetNumKillLocations and GetNumKillLocations() or 0
    for i = 1, numKillLocs do
        local _, x, y = GetKillLocationPinInfo(i)
        if x and y then
            table.insert(killLocations, {x = x, y = y})
        end
    end
    
    for i = 1, numKeeps do
        local keepId, bgContext = GetKeepKeysByIndex(i)
        if keepId then
            local keepType = GetKeepType(keepId)
            -- Only check actual keeps (not resources, outposts, etc.)
            if keepType == KEEPTYPE_KEEP or keepType == KEEPTYPE_BORDER_KEEP or keepType == KEEPTYPE_OUTPOST then
                local underAttack = GetKeepUnderAttack(keepId, bgContext)
                if not underAttack then
                    local keepName = GetKeepName(keepId)
                    local alliance = GetKeepAlliance(keepId, bgContext)
                    local _, keepX, keepY = GetKeepPinInfo(keepId, bgContext)
                    
                    -- Check if any kill location is near this keep
                    local hasNearbyFighting = false
                    if keepX and keepY then
                        for _, loc in ipairs(killLocations) do
                            local dist = math.sqrt((keepX - loc.x)^2 + (keepY - loc.y)^2)
                            if dist < 0.08 then -- Close enough to be "nearby"
                                hasNearbyFighting = true
                                break
                            end
                        end
                    end
                    
                    if not hasNearbyFighting and keepName and keepName ~= "" then
                        table.insert(quietKeeps, {
                            name = keepName,
                            alliance = alliance,
                            keepId = keepId,
                            x = keepX,
                            y = keepY,
                        })
                    end
                end
            end
        end
    end
    
    -- Sort by alliance (enemy keeps first for attack opportunities)
    local playerAlliance = GetUnitAlliance("player")
    table.sort(quietKeeps, function(a, b)
        local aEnemy = (a.alliance ~= playerAlliance and a.alliance ~= 0) and 1 or 0
        local bEnemy = (b.alliance ~= playerAlliance and b.alliance ~= 0) and 1 or 0
        if aEnemy ~= bEnemy then return aEnemy > bEnemy end
        return a.name < b.name
    end)
    
    return quietKeeps
end

function NWT.GetPopulationText(popType)
    if popType == CAMPAIGN_POP_LOW then return "Low"
    elseif popType == CAMPAIGN_POP_MEDIUM then return "Medium"
    elseif popType == CAMPAIGN_POP_HIGH then return "High"
    elseif popType == CAMPAIGN_POP_FULL then return "Full"
    else return "?" end
end

function NWT.UpdatePVPHotspotSelection()
    local ui = ATK_PVP_UI
    if not ui then return end
    local content = ui:GetNamedChild("Content")
    if not content then return end
    local rightCol = content:GetNamedChild("RightCol")
    if not rightCol then return end
    local hotspotList = rightCol:GetNamedChild("HotspotList")
    if not hotspotList then return end
    
    local hotspots = NWT.PVP.hotspotData or {}
    for i = 1, 5 do
        local row = hotspotList:GetNamedChild("Row" .. i)
        if row then
            local data = hotspots[i]
            if data then
                local selected = (i == NWT.PVP.hotspotIndex)
                local prefix = selected and "|cFFFF00> |r" or "  "
                local nameColor = selected and "FFFF00" or "FFFFFF"
                local text = prefix .. "|c" .. nameColor .. data.name .. "|r: "
                text = text .. "|cFFCC00" .. (data.ad or 0) .. "|r/|cFF4444" .. (data.ep or 0) .. "|r/|c4488FF" .. (data.dc or 0) .. "|r"
                row:SetText(text)
            end
        end
    end
end

function NWT.InitPVPDashboardScene()
    if NWT.PVP.sceneInitialized then return end
    local ui = ATK_PVP_UI
    if not ui then return end
    
    PVP_DASHBOARD_SCENE = ZO_Scene:New("pvpDashboardScene", SCENE_MANAGER)
    PVP_DASHBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    PVP_DASHBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    PVP_DASHBOARD_SCENE:AddFragment(ZO_SimpleSceneFragment:New(ui))
    
    NWT.PVP.hotspotIndex = 1
    NWT.PVP.hotspotData = {}
    
    NWT.PVPKeybinds = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        { name = "Show on Map", keybind = "UI_SHORTCUT_PRIMARY", callback = function()
            local data = NWT.PVP.hotspotData[NWT.PVP.hotspotIndex]
            if data and data.x and data.y and NWT.PVP.currentTab == 1 then
                local targetX, targetY, targetName = data.x, data.y, data.name or "Battle"
                
                -- Close dashboard and open map
                NWT.ClosePVPDashboard()
                zo_callLater(function()
                    ZO_WorldMap_ShowWorldMap()
                    
                    -- Navigate to Cyrodiil map
                    zo_callLater(function()
                        local cyroIndex = GetCyrodiilMapIndex and GetCyrodiilMapIndex()
                        
                        local function doPanAndPing()
                            -- Re-fetch coordinates from kill location after map switch
                            local freshX, freshY = targetX, targetY
                            if data.killLocationIndex and GetKillLocationPinInfo then
                                local _, nx, ny = GetKillLocationPinInfo(data.killLocationIndex)
                                if nx and ny then
                                    freshX, freshY = nx, ny
                                end
                            end
                            
                            local pz = ZO_WorldMap_GetPanAndZoom()
                            if pz and pz.PanToNormalizedPosition then
                                pz:PanToNormalizedPosition(freshX, freshY)
                            end
                            zo_callLater(function()
                                PingMap(MAP_PIN_TYPE_RALLY_POINT, MAP_TYPE_LOCATION_CENTERED, freshX, freshY)
                            end, 300)
                        end
                        
                        -- Always switch to Cyrodiil first
                        if cyroIndex then
                            SetMapToMapListIndex(cyroIndex)
                            CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
                        end
                        -- Wait for map to settle then pan/ping
                        zo_callLater(doPanAndPing, 1000)
                    end, 300)
                end, 200)
                PlaySound(SOUNDS.MAP_PING)
            end
        end },
        { name = "Refresh", keybind = "UI_SHORTCUT_SECONDARY", callback = function() 
            NWT.RefreshCampaignData()
            NWT.UpdatePVPDashboard() 
            PlaySound(SOUNDS.POSITIVE_CLICK) 
        end },
        { name = "Reset Today", keybind = "UI_SHORTCUT_TERTIARY", callback = function()
            local pvp = NWT.savedVars.pvp
            pvp.today = {
                date = GetDate(),
                apEarned = 0,
                kills = 0,
                deaths = 0,
                loginAP = GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_CHARACTER),
            }
            pvp.killFeed = {}
            pvp.nemesis = {}
            pvp.victims = {}
            pvp.hotspots = {}
            NWT.PVP.loginTime = GetTimeStamp()
            NWT.UpdatePVPDashboard()
            PlaySound(SOUNDS.POSITIVE_CLICK)
            NWT.Debug("|cFF6600[PVP]|r Today's stats reset!")
        end },
        { name = "Next Tab", keybind = "UI_SHORTCUT_RIGHT_SHOULDER", callback = function()
            NWT.PVP.currentTab = NWT.PVP.currentTab + 1
            if NWT.PVP.currentTab > #NWT.PVP.tabs then NWT.PVP.currentTab = 1 end
            NWT.UpdatePVPDashboard()
            PlaySound(SOUNDS.HORIZONTAL_LIST_TRACK_POSITIVE)
        end },
        { name = "Prev Tab", keybind = "UI_SHORTCUT_LEFT_SHOULDER", callback = function()
            NWT.PVP.currentTab = NWT.PVP.currentTab - 1
            if NWT.PVP.currentTab < 1 then NWT.PVP.currentTab = #NWT.PVP.tabs end
            NWT.PVP.hotspotIndex = 1
            NWT.UpdatePVPDashboard()
            PlaySound(SOUNDS.HORIZONTAL_LIST_TRACK_NEGATIVE)
        end },
        { name = "Select Battle", keybind = "UI_SHORTCUT_INPUT_UP", callback = function()
            if NWT.PVP.currentTab == 1 and #NWT.PVP.hotspotData > 0 then
                NWT.PVP.hotspotIndex = NWT.PVP.hotspotIndex - 1
                if NWT.PVP.hotspotIndex < 1 then NWT.PVP.hotspotIndex = #NWT.PVP.hotspotData end
                NWT.UpdatePVPHotspotSelection()
                PlaySound(SOUNDS.GAMEPAD_MENU_UP)
            elseif NWT.PVP.currentTab == 3 then
                -- Cycle leaderboard type backwards on Leaderboards tab
                NWT.CycleBGLeaderboardType(-1)
                NWT.UpdatePVPDashboard()
                PlaySound(SOUNDS.GAMEPAD_MENU_UP)
            end
        end },
        { name = "Select Battle", keybind = "UI_SHORTCUT_INPUT_DOWN", callback = function()
            if NWT.PVP.currentTab == 1 and #NWT.PVP.hotspotData > 0 then
                NWT.PVP.hotspotIndex = NWT.PVP.hotspotIndex + 1
                if NWT.PVP.hotspotIndex > #NWT.PVP.hotspotData then NWT.PVP.hotspotIndex = 1 end
                NWT.UpdatePVPHotspotSelection()
                PlaySound(SOUNDS.GAMEPAD_MENU_DOWN)
            elseif NWT.PVP.currentTab == 3 then
                -- Cycle leaderboard type forwards on Leaderboards tab
                NWT.CycleBGLeaderboardType(1)
                NWT.UpdatePVPDashboard()
                PlaySound(SOUNDS.GAMEPAD_MENU_DOWN)
            end
        end },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(NWT.PVPKeybinds, GAME_NAVIGATION_TYPE_BUTTON, function() NWT.ClosePVPDashboard() end)
    
    PVP_DASHBOARD_SCENE:RegisterCallback("StateChange", function(os, ns)
        if ns == SCENE_SHOWING then
            if KEYBIND_STRIP then KEYBIND_STRIP:AddKeybindButtonGroup(NWT.PVPKeybinds) end
            NWT.PVP.isOpen = true
            NWT.UpdatePVPDashboard()
        elseif ns == SCENE_HIDDEN then
            if KEYBIND_STRIP then KEYBIND_STRIP:RemoveKeybindButtonGroup(NWT.PVPKeybinds) end
            NWT.PVP.isOpen = false
        end
    end)
    
    NWT.PVP.sceneInitialized = true
end

function NWT.OpenPVPDashboard()
    if NWT.PVP.isOpen then return end
    if not NWT.PVP.sceneInitialized then NWT.InitPVPDashboardScene() end
    NWT.UpdatePVPDashboard()
    SCENE_MANAGER:Push("pvpDashboardScene")
end

function NWT.ClosePVPDashboard()
    if PVP_DASHBOARD_SCENE then SCENE_MANAGER:Hide("pvpDashboardScene") end
end

-- ============================================
-- BATTLEGROUND LEADERBOARDS
-- ============================================
NWT.PVP.leaderboardData = {}
NWT.PVP.leaderboardType = 1 -- Default, will be set properly if constants exist
NWT.PVP.leaderboardsAvailable = false

local BG_LEADERBOARD_TYPES = {}

-- Initialize leaderboard types safely (constants may not exist on all platforms)
-- Use simple 1-4 index for navigation, map to actual constants
NWT.PVP.leaderboardIndex = 1  -- Simple 1-4 index for D-pad
local function InitBGLeaderboardTypes()
    if BATTLEGROUND_LEADERBOARD_TYPE_COMPETITIVE then
        NWT.PVP.leaderboardsAvailable = true
        BG_LEADERBOARD_TYPES = {
            { type = BATTLEGROUND_LEADERBOARD_TYPE_COMPETITIVE, name = "Competitive" },
            { type = BATTLEGROUND_LEADERBOARD_TYPE_DEATHMATCH, name = "Deathmatch" },
            { type = BATTLEGROUND_LEADERBOARD_TYPE_FLAG_GAMES, name = "Flag Games" },
            { type = BATTLEGROUND_LEADERBOARD_TYPE_LAND_GRAB, name = "Land Grab" },
        }
        NWT.PVP.leaderboardType = BG_LEADERBOARD_TYPES[1].type
    else
        -- Fallback for platforms without leaderboard constants
        BG_LEADERBOARD_TYPES = {
            { type = 1, name = "Competitive" },
            { type = 2, name = "Deathmatch" },
            { type = 3, name = "Flag Games" },
            { type = 4, name = "Land Grab" },
        }
        NWT.PVP.leaderboardType = 1
    end
end
InitBGLeaderboardTypes()

function NWT.QueryBGLeaderboard(leaderboardType)
    leaderboardType = leaderboardType or NWT.PVP.leaderboardType
    if QueryBattlegroundLeaderboardData then
        local readyState = QueryBattlegroundLeaderboardData(leaderboardType)
        if readyState == LEADERBOARD_DATA_READY then
            NWT.OnBGLeaderboardDataReceived(nil, leaderboardType)
        end
    end
end

function NWT.OnBGLeaderboardDataReceived(eventCode, battlegroundType)
    if not GetNumBattlegroundLeaderboardEntries then return end
    
    local numEntries = GetNumBattlegroundLeaderboardEntries(battlegroundType) or 0
    local entries = {}
    
    for i = 1, math.min(numEntries, 100) do -- Cap at top 100
        local rank, displayName, characterName, score = GetBattlegroundLeaderboardEntryInfo(battlegroundType, i)
        if rank and displayName then
            table.insert(entries, {
                rank = rank,
                displayName = displayName,
                characterName = characterName,
                score = score or 0,
            })
        end
    end
    
    NWT.PVP.leaderboardData[battlegroundType] = entries
    
    if NWT.PVP.isOpen and NWT.PVP.currentTab == 2 then
        NWT.UpdatePVPDashboard()
    end
end

function NWT.GetBGLeaderboardPlayerInfo(leaderboardType)
    leaderboardType = leaderboardType or NWT.PVP.leaderboardType
    if GetBattlegroundLeaderboardLocalPlayerInfo then
        local rank, score = GetBattlegroundLeaderboardLocalPlayerInfo(leaderboardType)
        return rank or 0, score or 0
    end
    return 0, 0
end

function NWT.GetBGLeaderboardSchedule(leaderboardType)
    leaderboardType = leaderboardType or NWT.PVP.leaderboardType
    if GetBattlegroundLeaderboardsSchedule then
        local secondsUntilEnd, secondsUntilNextStart = GetBattlegroundLeaderboardsSchedule(leaderboardType)
        return secondsUntilEnd or 0, secondsUntilNextStart or 0
    end
    return 0, 0
end

function NWT.GetBGLeaderboardTypeName(leaderboardType)
    for _, entry in ipairs(BG_LEADERBOARD_TYPES) do
        if entry.type == leaderboardType then return entry.name end
    end
    return "Unknown"
end

function NWT.CycleBGLeaderboardType(direction)
    -- Use simple index-based cycling (1 → 2 → 3 → 4 → 1)
    NWT.PVP.leaderboardIndex = NWT.PVP.leaderboardIndex + (direction or 1)
    
    if NWT.PVP.leaderboardIndex > 4 then NWT.PVP.leaderboardIndex = 1 end
    if NWT.PVP.leaderboardIndex < 1 then NWT.PVP.leaderboardIndex = 4 end
    
    -- Get the actual type from the index
    local typeInfo = BG_LEADERBOARD_TYPES[NWT.PVP.leaderboardIndex]
    if typeInfo then
        NWT.PVP.leaderboardType = typeInfo.type
    end
    
    NWT.QueryBGLeaderboard()
end

-- ============================================
-- LEADERBOARD SCENE
-- ============================================
NWT.PVP.leaderboardSceneOpen = false
NWT.PVP.leaderboardSceneInitialized = false
NWT.PVP.leaderboardTypeIndex = 1

function NWT.UpdateLeaderboardUI()
    local ui = ATK_Leaderboard_UI
    if not ui then return end
    
    local lbType = NWT.PVP.leaderboardType
    local lbTypeName = NWT.GetBGLeaderboardTypeName(lbType)
    
    -- Update header
    local header = ui:GetNamedChild("Header")
    if header then
        local subtitle = header:GetNamedChild("Subtitle")
        if subtitle then subtitle:SetText(lbTypeName .. " Leaderboard") end
    end
    
    -- Update left panel - type selector
    local leftPanel = ui:GetNamedChild("LeftPanel")
    if leftPanel then
        for i, typeInfo in ipairs(BG_LEADERBOARD_TYPES) do
            local typeLabel = leftPanel:GetNamedChild("Type" .. i)
            if typeLabel then
                local isSelected = typeInfo.type == lbType
                local color = isSelected and "00FFFF" or "888888"
                local prefix = isSelected and "|cFFD700> |r" or "  "
                typeLabel:SetText(prefix .. "|c" .. color .. typeInfo.name .. "|r")
            end
        end
        
        -- Player rank
        local myRank, myScore = NWT.GetBGLeaderboardPlayerInfo(lbType)
        local yourRank = leftPanel:GetNamedChild("YourRank")
        local yourScore = leftPanel:GetNamedChild("YourScore")
        
        if yourRank then
            if myRank > 0 then
                local rankColor = "FFFFFF"
                if myRank == 1 then rankColor = "FFD700"
                elseif myRank == 2 then rankColor = "C0C0C0"
                elseif myRank == 3 then rankColor = "CD7F32"
                elseif myRank <= 10 then rankColor = "00FFFF"
                elseif myRank <= 50 then rankColor = "00FF00"
                end
                yourRank:SetText("|c" .. rankColor .. "#" .. myRank .. "|r")
            else
                yourRank:SetText("|c555555Not Ranked|r")
            end
        end
        if yourScore then
            if myScore > 0 then
                yourScore:SetText("|c00FF00" .. ZO_CommaDelimitNumber(myScore) .. "|r points")
            else
                yourScore:SetText("")
            end
        end
        
        -- Reset timer
        local resetLabel = leftPanel:GetNamedChild("ResetLabel")
        local resetTime = leftPanel:GetNamedChild("ResetTime")
        local secondsUntilEnd, _ = NWT.GetBGLeaderboardSchedule(lbType)
        
        if resetLabel then resetLabel:SetText("Resets in:") end
        if resetTime then
            if secondsUntilEnd > 0 then
                local hours = math.floor(secondsUntilEnd / 3600)
                local days = math.floor(hours / 24)
                local remainingHours = hours % 24
                local minutes = math.floor((secondsUntilEnd % 3600) / 60)
                
                local timeStr
                if days > 0 then
                    timeStr = string.format("|cFFFFFF%dd %dh %dm|r", days, remainingHours, minutes)
                else
                    timeStr = string.format("|cFFFFFF%dh %dm|r", hours, minutes)
                end
                resetTime:SetText(timeStr)
            else
                resetTime:SetText("|c888888Unknown|r")
            end
        end
    end
    
    -- Update center panel - leaderboard list
    local centerPanel = ui:GetNamedChild("CenterPanel")
    if centerPanel then
        local list = centerPanel:GetNamedChild("List")
        if list then
            local entries = NWT.PVP.leaderboardData[lbType] or {}
            local emptyLabel = list:GetNamedChild("Empty")
            
            if #entries == 0 then
                if emptyLabel then
                    emptyLabel:SetText("|c888888Loading leaderboard data...|r")
                    emptyLabel:SetHidden(false)
                end
            else
                if emptyLabel then emptyLabel:SetHidden(true) end
            end
            
            -- Display up to 20 entries
            for i = 1, 20 do
                local row = list:GetNamedChild("Row" .. i)
                if row then
                    local entry = entries[i]
                    if entry then
                        local rankColor = "FFFFFF"
                        if entry.rank == 1 then rankColor = "FFD700"
                        elseif entry.rank == 2 then rankColor = "C0C0C0"
                        elseif entry.rank == 3 then rankColor = "CD7F32"
                        elseif entry.rank <= 10 then rankColor = "00FFFF"
                        elseif entry.rank <= 50 then rankColor = "00FF00"
                        end
                        
                        local displayName = entry.displayName or "Unknown"
                        -- Pad rank for alignment
                        local rankStr = string.format("|c%s#%-3d|r", rankColor, entry.rank)
                        local scoreStr = ZO_CommaDelimitNumber(entry.score)
                        
                        row:SetText(rankStr .. "  " .. displayName .. "  |c00FF00" .. scoreStr .. "|r")
                        row:SetHidden(false)
                    else
                        row:SetHidden(true)
                    end
                end
            end
        end
    end
    
    -- Update footer
    local footer = ui:GetNamedChild("Footer")
    if footer then
        footer:SetText("|cFF6600[D-Pad Up/Down]|r Change Type   |cFF6600[X]|r Refresh   |c888888[B] Back|r")
    end
end

function NWT.InitLeaderboardScene()
    if NWT.PVP.leaderboardSceneInitialized then return end
    local ui = ATK_Leaderboard_UI
    if not ui then return end
    
    LEADERBOARD_SCENE = ZO_Scene:New("leaderboardScene", SCENE_MANAGER)
    LEADERBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    LEADERBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    LEADERBOARD_SCENE:AddFragment(ZO_SimpleSceneFragment:New(ui))
    
    NWT.LeaderboardKeybinds = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        { name = "Refresh", keybind = "UI_SHORTCUT_SECONDARY", callback = function()
            NWT.QueryBGLeaderboard()
            PlaySound(SOUNDS.POSITIVE_CLICK)
        end },
        { name = "Prev Type", keybind = "UI_SHORTCUT_INPUT_UP", callback = function()
            NWT.CycleBGLeaderboardType(-1)
            NWT.UpdateLeaderboardUI()
            PlaySound(SOUNDS.GAMEPAD_MENU_UP)
        end },
        { name = "Next Type", keybind = "UI_SHORTCUT_INPUT_DOWN", callback = function()
            NWT.CycleBGLeaderboardType(1)
            NWT.UpdateLeaderboardUI()
            PlaySound(SOUNDS.GAMEPAD_MENU_DOWN)
        end },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(NWT.LeaderboardKeybinds, GAME_NAVIGATION_TYPE_BUTTON, function() NWT.CloseLeaderboard() end)
    
    LEADERBOARD_SCENE:RegisterCallback("StateChange", function(os, ns)
        if ns == SCENE_SHOWING then
            if KEYBIND_STRIP then KEYBIND_STRIP:AddKeybindButtonGroup(NWT.LeaderboardKeybinds) end
            NWT.PVP.leaderboardSceneOpen = true
            NWT.QueryBGLeaderboard()
            NWT.UpdateLeaderboardUI()
        elseif ns == SCENE_HIDDEN then
            if KEYBIND_STRIP then KEYBIND_STRIP:RemoveKeybindButtonGroup(NWT.LeaderboardKeybinds) end
            NWT.PVP.leaderboardSceneOpen = false
        end
    end)
    
    NWT.PVP.leaderboardSceneInitialized = true
end

function NWT.OpenLeaderboard()
    if NWT.PVP.leaderboardSceneOpen then return end
    if not NWT.PVP.leaderboardSceneInitialized then NWT.InitLeaderboardScene() end
    if not NWT.PVP.leaderboardSceneInitialized then
        d("|cFF6600[PVP]|r Leaderboard UI not available")
        return
    end
    SCENE_MANAGER:Push("leaderboardScene")
end

function NWT.CloseLeaderboard()
    if LEADERBOARD_SCENE then SCENE_MANAGER:Hide("leaderboardScene") end
end

-- ============================================
-- EVENT REGISTRATION (Always On)
-- ============================================
function NWT.RegisterPVPEvents()
    -- Core PVP events
    EVENT_MANAGER:RegisterForEvent("ATK_PVP_AP", EVENT_ALLIANCE_POINT_UPDATE, NWT.OnAPUpdate)
    EVENT_MANAGER:RegisterForEvent("ATK_PVP_KILL", EVENT_PVP_KILL_FEED_DEATH, NWT.OnPVPKillFeed)
    
    -- Campaign events
    EVENT_MANAGER:RegisterForEvent("ATK_PVP_EMPEROR", EVENT_CAMPAIGN_EMPEROR_CHANGED, NWT.OnEmperorChanged)
    EVENT_MANAGER:RegisterForEvent("ATK_PVP_CORONATION", EVENT_CORONATE_EMPEROR_NOTIFICATION, NWT.OnCoronation)
    EVENT_MANAGER:RegisterForEvent("ATK_PVP_DEPOSITION", EVENT_DEPOSE_EMPEROR_NOTIFICATION, NWT.OnDeposition)
    EVENT_MANAGER:RegisterForEvent("ATK_PVP_SCORE", EVENT_CAMPAIGN_SCORE_DATA_CHANGED, NWT.OnCampaignScoreChanged)
    EVENT_MANAGER:RegisterForEvent("ATK_PVP_KILLS", EVENT_KILL_LOCATIONS_UPDATED, function() if NWT.PVP.isOpen then NWT.UpdatePVPDashboard() end end)
    
    -- Battleground events
    EVENT_MANAGER:RegisterForEvent("ATK_PVP_BG_STATE", EVENT_BATTLEGROUND_STATE_CHANGED, NWT.OnBattlegroundStateChanged)
    EVENT_MANAGER:RegisterForEvent("ATK_PVP_BG_KILL", EVENT_BATTLEGROUND_KILL, NWT.OnBattlegroundKill)
    EVENT_MANAGER:RegisterForEvent("ATK_PVP_BG_LEADERBOARD", EVENT_BATTLEGROUND_LEADERBOARD_DATA_RECEIVED, NWT.OnBGLeaderboardDataReceived)
end

function NWT.RegisterPVPSlashCommands()
    SLASH_COMMANDS["/pvp"] = function()
        if NWT.PVP.isOpen then NWT.ClosePVPDashboard() else NWT.OpenPVPDashboard() end
    end
    
    SLASH_COMMANDS["/leaderboard"] = function()
        if NWT.PVP.leaderboardSceneOpen then NWT.CloseLeaderboard() else NWT.OpenLeaderboard() end
    end
    SLASH_COMMANDS["/lb"] = SLASH_COMMANDS["/leaderboard"]
    
    -- Goal setting commands
    SLASH_COMMANDS["/pvpgoal"] = function(args)
        local params = {}
        for word in args:gmatch("%S+") do table.insert(params, word) end
        
        if params[1] == "ap" and params[2] then
            local target = tonumber(params[2])
            if target then
                NWT.SetAPGoal(target)
                d("|cFF6600[PVP]|r AP goal set to " .. ZO_CommaDelimitNumber(target))
            end
        elseif params[1] == "kills" and params[2] then
            local target = tonumber(params[2])
            if target then
                NWT.SetKillGoal(target)
                d("|cFF6600[PVP]|r Kill goal set to " .. target)
            end
        elseif params[1] == "clear" then
            NWT.SetAPGoal(0)
            NWT.SetKillGoal(0)
            d("|cFF6600[PVP]|r Goals cleared")
        else
            d("|cFF6600[PVP]|r Usage: /pvpgoal ap <amount> | /pvpgoal kills <amount> | /pvpgoal clear")
        end
        if NWT.PVP.isOpen then NWT.UpdatePVPDashboard() end
    end
end
