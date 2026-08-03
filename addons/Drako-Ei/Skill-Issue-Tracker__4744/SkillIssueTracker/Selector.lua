local SIT = SkillIssueTracker
local selector = SIT.selector
local target = SIT.target
selector.players = {}
selector.currentTeam = nil
selector.totalTeams = 0
selector.gameType = nil

local GAME_DEATHMATCH = 2

-- Basic normalization values
local AVERAGE_TOTAL_DAMAGE = 500000
local AVERAGE_TOTAL_HEALING = 500000
local AVERAGE_HEALTH = 35000
local EXECUTE_RANGE = 0.5

-- Returns a numeric value, higher is better, for how much we should focus on this player.
selector.evaluatePlayer = function(characterName)
    
    if not selector.isPlayerTracked(characterName) then return nil end
    local data = selector.players[characterName]
    if data.isDead then return nil end
    if selector.isPlayerPermanentlyDead(characterName) then return nil end

    local weights = SIT.savedVars.presets[SIT.savedVars.usingPreset]

    -- Ignore players that have not been seen for a while
    if weights.ignoreIfUnseenFor ~= 0 then
        if data.seenAt and (GetFrameTimeMilliseconds() - data.seenAt) > (weights.ignoreIfUnseenFor * 1000) then
            return nil
        end
    end

    local score = 0

    -- Bully low level players
    if data.level < 50 then
        score = score + weights.lowLevel
    end

    -- Bully low CP players
    if data.cp < 160 then
        score = score + weights.lowCP
    end

    -- Scoring based on performance
    score = score + weights.damageDone * (data.damageDone / AVERAGE_TOTAL_DAMAGE)
    score = score + weights.healingDone * (data.healingDone / AVERAGE_TOTAL_HEALING)
    score = score + weights.kills * data.kills
    score = score + weights.assists * data.assists

    -- Punish players that die often, especially if lives are limited
    score = score + weights.deaths * data.deaths * (selector.areLivesLimited() and 1.5 or 1.0)

    -- Bonus score if player was almost executed
    local executeRangeLife = data.maxHealth * EXECUTE_RANGE
    if data.life_minimumHealthObserved > 0 and data.life_minimumHealthObserved < executeRangeLife then
        local minimumHealthPercent = data.life_minimumHealthObserved / data.maxHealth        
        score = score + weights.almostDied * (1.0 - minimumHealthPercent)
    end

    -- Punish score for permablockers and shield spammers
    local blockRatio = 0
    local shieldRatio = 0
    if data.unblockedHits > 0 then
        blockRatio = data.blockedHits / data.unblockedHits
        shieldRatio = data.shieldedHits / data.unblockedHits
    end
    score = score - weights.permablockerPenalty * blockRatio
    score = score - weights.shieldSpammerPenalty * shieldRatio

    -- Punish healthy players
    score = score - weights.maxHealthPenalty * (data.maxHealth / AVERAGE_HEALTH)
    
    -- Punish players that recover from damage without dying
    score = score - weights.tankedDamagePenalty * (data.life_damageTaken / AVERAGE_HEALTH)

    return score

end

-- Returns true if the player is being tracked, false otherwise
selector.isPlayerTracked = function(characterName)
    return selector.players[characterName] ~= nil
end

selector.areLivesLimited = function()
    if selector.gameType == GAME_DEATHMATCH and selector.totalTeams == 2 then
        return true
    end
    return false
end

selector.isPlayerPermanentlyDead = function(characterName)
    if not selector.isPlayerTracked(characterName) then return false end
    if not selector.areLivesLimited() then return false end
    local playerInfo = selector.players[characterName]
    if playerInfo.deaths >= 3 then
        return true
    end
    return false
end

selector.accumulatePlayerInformation = function(characterName, dict)
    if not selector.isPlayerTracked(characterName) then return end
    for key, value in pairs(dict) do
        if selector.players[characterName][key] ~= nil then
            selector.players[characterName][key] = selector.players[characterName][key] + value
        end
    end
end

-- Triggered when a player is resurrected, updates the player information accordingly
selector.onPlayerResurrect = function(characterName)
    if not selector.isPlayerTracked(characterName) then return end
    local p = selector.players[characterName]
    if not p.isDead then return end
    p.isDead = false
end

-- Triggered when a player dies, updates the player information accordingly
selector.onPlayerDeath = function(characterName)
    
    -- reset this life's damage and hit counts (direct assignment, not accumulation)
    local p = selector.players[characterName]
    if p.isDead then return end
    p.life_damageTaken = 0
    p.life_blockedHits = 0
    p.life_shieldedHits = 0
    p.life_unblockedHits = 0
    p.life_minimumHealthObserved = -1
    p.isDead = true

    -- Trigger update immediately if we got the target
    if target.isTargeted(characterName) then
        selector.update(GetFrameTimeMilliseconds())
    end

end

-- Upserts new player for tracking
selector.savePlayerInformation = function(characterName, dict)
    if not selector.players[characterName] then 
        selector.players[characterName] = {
            maxHealth = 0,
            currentHealth = 0,
            class = nil,
            race = nil,
            level = 0,
            cp = 0,
            damageDone = 0,
            healingDone = 0,
            kills = 0,
            deaths = 0,
            assists = 0,
            isDead = false,
            damageTaken = 0,
            blockedHits = 0,
            shieldedHits = 0,
            unblockedHits = 0,
            life_damageTaken = 0,
            life_blockedHits = 0,
            life_shieldedHits = 0,
            life_unblockedHits = 0,
            life_minimumHealthObserved = -1,
            seenAt = GetFrameTimeMilliseconds()
        }
    end

    -- Update dict values
    for key, value in pairs(selector.players[characterName]) do
        if dict[key] ~= nil then
            selector.players[characterName][key] = dict[key]
        end
    end

    -- Only update minimum health if a real health reading was provided and the player is not dead
    if not selector.players[characterName].isDead and dict.currentHealth ~= nil then
        local minHealth = selector.players[characterName].life_minimumHealthObserved
        if minHealth == -1 or selector.players[characterName].currentHealth < minHealth then
            selector.players[characterName].life_minimumHealthObserved = selector.players[characterName].currentHealth
        end
    end

end

-- Called at the start of a battleground to set the current team
selector.setCurrentTeam = function()
    local numEntries = GetNumScoreboardEntries()
    local roundIndex = GetCurrentBattlegroundRoundIndex()
    local uniqueTeamIds = {}
    for entryIndex = 1, numEntries do
        local characterName,
            displayName,
            battlegroundAlliance,
            isLocalPlayer =
            GetScoreboardEntryInfo(entryIndex, roundIndex)
        if isLocalPlayer then
            selector.currentTeam = battlegroundAlliance
        end
        uniqueTeamIds[battlegroundAlliance] = true
    end

    local totalTeams = 0
    for teamId, _ in pairs(uniqueTeamIds) do
        totalTeams = totalTeams + 1
    end
    selector.totalTeams = totalTeams
    
end

-- Called on damage done, updates the player information accordingly
selector.integrateDamageEvent = function(result, targetName, hitValue, abilityId, time)

    if not selector.isPlayerTracked(targetName) then return end

    local data = {
        damageTaken = hitValue,
        blockedHits = (result == ACTION_RESULT_BLOCKED_DAMAGE) and 1 or 0,
        shieldedHits = (result == ACTION_RESULT_DAMAGE_SHIELDED) and 1 or 0,
        unblockedHits = (result == ACTION_RESULT_DAMAGE) and 1 or 0,
    }

    -- Accumulate the damage taken and hit counts for the player's current life
    data["life_damageTaken"] = data.damageTaken
    data["life_blockedHits"] = data.blockedHits
    data["life_shieldedHits"] = data.shieldedHits
    data["life_unblockedHits"] = data.unblockedHits

    selector.accumulatePlayerInformation(targetName, data)

end

-- Called on reticle over event, gets extra information
selector.integratePlayerFromReticleInformation = function(targetInfo)
    local characterName = targetInfo.characterName
    if selector.isPlayerTracked(characterName) then
        selector.savePlayerInformation(characterName, targetInfo)

        -- Trigger death and ressurect events
        if targetInfo.isUnitDead then
            if not selector.players[characterName].isDead then
                selector.onPlayerDeath(characterName)
            end
        else
            if selector.players[characterName].isDead then
                selector.onPlayerResurrect(characterName)
            end
        end

    end

end

-- Called on update cycle every 5 seconds
selector.integrateBattlegroundScores = function()


    local numEntries = GetNumScoreboardEntries()
    local roundIndex = GetCurrentBattlegroundRoundIndex()
    local activePlayers = {}
    local uniqueTeamIds = {}

    for entryIndex = 1, numEntries do
        local characterName,
            displayName,
            battlegroundAlliance,
            isLocalPlayer =
            GetScoreboardEntryInfo(entryIndex, roundIndex)
        characterName = zo_strformat(SI_UNIT_NAME, characterName)
        local damage = GetScoreboardEntryScoreByType(entryIndex,SCORE_TRACKER_TYPE_DAMAGE_DONE,roundIndex)
        local healing = GetScoreboardEntryScoreByType(entryIndex,SCORE_TRACKER_TYPE_HEALING_DONE,roundIndex)
        local kills = GetScoreboardEntryScoreByType(entryIndex,SCORE_TRACKER_TYPE_KILL,roundIndex)
        local deaths = GetScoreboardEntryScoreByType(entryIndex,SCORE_TRACKER_TYPE_DEATH,roundIndex)
        local assists = GetScoreboardEntryScoreByType(entryIndex,SCORE_TRACKER_TYPE_ASSISTS,roundIndex)

        -- In case alliance is not set
        if isLocalPlayer then
            selector.currentTeam = battlegroundAlliance
        end

        -- Only track enemy players
        if selector.currentTeam and battlegroundAlliance ~= selector.currentTeam then 
            
            -- If player is already tracked and dies, trigger event
            if selector.isPlayerTracked(characterName) then
                if selector.players[characterName].deaths ~= deaths then
                    selector.onPlayerDeath(characterName)
                end
            end
            
            selector.savePlayerInformation(characterName, {
                damageDone = damage,
                healingDone = healing,
                kills = kills,
                deaths = deaths,
                assists = assists
            })
        end

        -- Tracks teams and active players
        uniqueTeamIds[battlegroundAlliance] = true
        activePlayers[characterName] = true

    end

    -- Remove rage quitters, get rekt
    for name, playerInfo in pairs(selector.players) do
        if not activePlayers[name] then
            selector.players[name] = nil
        end
    end

    -- Update maximum teams, in case bg loaded with a missing team, or a team quits
    local totalTeams = 0
    for teamId, _ in pairs(uniqueTeamIds) do
        totalTeams = totalTeams + 1
    end
    if totalTeams > selector.totalTeams then
        selector.totalTeams = totalTeams
    end

end

selector.reset = function()
    selector.players = {}
    selector.currentTeam = nil
    selector.totalTeams = 0
    selector.gameType = nil
end

-- Called every 5 seconds to make calculations to change target
selector.update = function(time)

    -- Updates the score
    selector.integrateBattlegroundScores()

    local targetScore = 0
    local targetPlayer = nil
    for name, playerInfo in pairs(selector.players) do
        local score = selector.evaluatePlayer(name)
        if score and score > targetScore then
            targetScore = score
            targetPlayer = name
        end
    end
    if targetPlayer then
        target.setTarget(targetPlayer, SIT.savedVars.markerType)
    else
        target.reset()
    end

end

selector.initialize = function()
    selector.setCurrentTeam()
    selector.gameType = GetCurrentBattlegroundGameType()
end