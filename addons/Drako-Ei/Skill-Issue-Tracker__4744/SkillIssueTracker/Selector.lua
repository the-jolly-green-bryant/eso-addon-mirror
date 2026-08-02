local SIT = SkillIssueTracker
local selector = SIT.selector
local target = SIT.target
selector.players = {}
selector.currentTeam = nil
selector.totalTeams = 0
selector.gameType = nil

-- /script d(GetCurrentBattlegroundGameType())
local GAME_DEATHMATCH = 2

-- Returns a numeric value, higher is better, for how much we should focus on this player.
selector.evaluatePlayer = function(characterName)
    
    if not selector.isPlayerTracked(characterName) then return nil end

    local data = selector.players[characterName]

    -- Ignore player if its dead, until seen again alive
    if data.isDead then return nil end

    -- Ignore player if permanently dead (3 deaths in a 2 team deathmatch)
    if selector.isPlayerPermanentlyDead(characterName) then return nil end

    -- If somehow a low level player is here, they should have high priority
    local missingLevels = 50 - data.level
    local missingCP = 160 - math.min(data.cp, 160)

    -- Targets with less health are easier to kill, so we want to focus them more, average health is 30k
    local health = data.maxHealth
    local minimumHealthObserved = data.life_minimumHealthObserved
    if minimumHealthObserved == -1 then
        minimumHealthObserved = health
    end

    -- Perma block players are annoying to kill, players that keep their shields up are more aware but they are easier than perma block players
    local blockRatio = 0
    local shieldRatio = 0
    if data.unblockedHits > 0 then
        blockRatio = data.blockedHits / data.unblockedHits
        shieldRatio = data.shieldedHits / data.unblockedHits
    end

    -- If the player has taken a lot of damage in this life, he is tanking, so we want to focus him less
    local sustainedDamageRecived = data.life_damageTaken

    -- Players that die more often are easier to kill, this should matter more if selector.areLivesLimited() is true
    local deaths = data.deaths

    -- Performance of players, for example, we may want to focus more a healer, or a player doing a lot of damage
    local assists = data.assists
    local kills = data.kills
    local damageDone = data.damageDone
    local healingDone = data.healingDone

    -- === PRIMARY: Kill ease ===
    -- How close to dying is the player? Normalize against average health of ~30k
    local avgHealth = 30000
    local healthScore = math.max(0, avgHealth - minimumHealthObserved) / avgHealth  -- 0..1, higher = closer to dead

    -- Low level / low CP players are easier to kill
    local levelBonus = (missingLevels * 0.5 + missingCP * 0.05) / avgHealth

    -- Block/shield ratios make the player harder to kill; perma-blockers (blockRatio >= 1) are strongly penalised
    local hardToKillPenalty = blockRatio * 2.0 + shieldRatio * 0.5

    -- Players that have died often are easier targets
    local deathBonus = deaths * 0.05

    local killEase = (1.0 + healthScore * 2.0 + levelBonus + deathBonus)
                     / (1.0 + hardToKillPenalty)

    -- Small tiebreaker only — should not override kill ease
    local avgOutput = 100000
    local threatScore = (damageDone + healingDone * 0.5) / avgOutput * 0.08
                        + kills * 0.02 + assists * 0.005

    -- If the player has absorbed a lot of damage this life but never got close to dying,
    -- they are likely very tanky — reduce their priority strongly.
    -- Ramps faster (30k to max) and caps higher (0.85).
    local dyingThreshold = (health > 0 and health or avgHealth) * 0.3
    local tankPenalty = 0
    if sustainedDamageRecived > 10000 and minimumHealthObserved > dyingThreshold then
        tankPenalty = math.min(0.85, sustainedDamageRecived / 30000)
    end

    local score = (killEase + threatScore) * (1.0 - tankPenalty)

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

-- Triggered when a player dies, updates the player information accordingly
selector.onPlayerDeath = function(characterName)
    
    -- reset this life's damage and hit counts (direct assignment, not accumulation)
    local p = selector.players[characterName]
    p.life_damageTaken = 0
    p.life_blockedHits = 0
    p.life_shieldedHits = 0
    p.life_unblockedHits = 0
    p.life_minimumHealthObserved = -1
    p.isDead = true

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
        }
    end
    -- Trigger on death event and update minimum health observed
    local oldDeaths = selector.players[characterName].deaths

    for key, value in pairs(selector.players[characterName]) do
        if dict[key] ~= nil then
            selector.players[characterName][key] = dict[key]
        end
    end
    local died = oldDeaths ~= selector.players[characterName].deaths
    if died then
        selector.onPlayerDeath(characterName)
    end
    -- Only update minimum health if the player did not just die (currentHealth would be 0 and corrupt the new life's tracking)
    if not died then
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

        if isLocalPlayer then
            selector.currentTeam = battlegroundAlliance
        end

        if selector.currentTeam and battlegroundAlliance ~= selector.currentTeam then 
            selector.savePlayerInformation(characterName, {
                damageDone = damage,
                healingDone = healing,
                kills = kills,
                deaths = deaths,
                assists = assists
            })
        end

        uniqueTeamIds[battlegroundAlliance] = true
        activePlayers[characterName] = true

    end

    for name, playerInfo in pairs(selector.players) do
        if not activePlayers[name] then
            selector.players[name] = nil
        end
    end

    local totalTeams = 0
    for teamId, _ in pairs(uniqueTeamIds) do
        totalTeams = totalTeams + 1
    end

    -- Always keep maximum number of teams, in case a team leaves the battleground and the number of teams decreases, we don't want to reset the lives of players that are already dead
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
    end

end

selector.initialize = function()
    selector.setCurrentTeam()
    selector.gameType = GetCurrentBattlegroundGameType()
end