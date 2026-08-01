-- global namspacing
PITHKA = PITHKA or {} 
PITHKA.data = PITHKA.data or {}
PITHKA.data.scores = {}

-- convenient namespace
local scores = PITHKA.data.scores
local utils = PITHKA.common.utils
local api = PITHKA.common.api

-- debug printing
local debugEnabled = false  -- Temporarily enable to show scoring is working
local function debug(msg)
    if debugEnabled then
        d('|cFFA500[data.scores]|r ' .. msg )
    end
end

--------------------------------
-- Scores callback system
--------------------------------

scores.callbacks = {}

-- register a callback function
function scores.registerCallback(fn)
    table.insert(scores.callbacks, fn)
end

-- call all registered callbacks
function scores.notifyCallbacks()
    for _, callback in ipairs(scores.callbacks) do
        callback()
    end
end



--------------------------------
-- Read and Write from SavedVars
--------------------------------

-- get highest score from savedVars
function scores.getHighestScore(abbv)
    local savedVars = PITHKA.data.savedVars.db
    -- check if we have any scores for this achievement
    if savedVars and savedVars.scores and savedVars.scores[abbv] then
        scoresArray = savedVars.scores[abbv]
        for key, value in pairs(scoresArray) do
            debug('scores.getHighestScore> ' .. tostring(key) .. ' ' .. tostring(value))
        end
        return utils.maxValue(scoresArray)
    else 
        return 0
    end
end

-- get sorted scores from savedVars
function scores.getSortedScores(abbv)
    local savedVars = PITHKA.data.savedVars.db
    if savedVars and savedVars.scores and savedVars.scores[abbv] then
        return utils.sortedByValues(savedVars.scores[abbv])
    end
end

-- saves score if higher
function scores.save(scoreType, lbIndex, newScore, abbv)
    local savedVars = PITHKA.data.savedVars.db
    if not savedVars then
        debug('ERROR: savedVars not initialized!')
        return
    end

    -- don't save 0 scores
    if newScore==nil or newScore==0 then
        return
    end

    -- get abbv from lbIndex if not provided (for trials)
    if not abbv then
        abbv = PITHKA.data.filterAchievements({LBINDEX=lbIndex}, {'ABBV'}) -- for trials
    end
    
    local name = GetUnitName("player")
    debug('scores.save> ' .. tostring(scoreType) .. ' ' .. tostring(lbIndex) .. ' ' .. tostring(newScore) .. ' ' .. tostring(abbv))
    
    -- create achievement entry if it doesn't exist
    if not savedVars.scores[abbv] then
        savedVars.scores[abbv] = {}
    end

    -- Only save if no score exists or new score is higher
    if not savedVars.scores[abbv][name] or newScore > savedVars.scores[abbv][name] then
        savedVars.scores[abbv][name] = newScore
        scores.notifyCallbacks()
    end
end



-------------------------------------------------
-- Fetch Score from Server, rescursive and async
-------------------------------------------------

function scores.fetchTrials(nextFetch)
    -- nextFetch is the lbIndex that we're incrementing through
    local nextFetch = nextFetch or 1
    debug('fetchTrials> nextFetch:' .. tostring(nextFetch))
    
    -- get all leaderboard indexes
    local lbArray = PITHKA.data.filterAchievements({TYPE='trial'}, {'LBINDEX'})
    local lbMax  = utils.maxValue(lbArray)

    -- stop loop if nextFetch is greater than maxFetch
    if nextFetch > lbMax then
        return
    end

    -- intiate query
    api.scores.requestTrial(nextFetch)
    
end

function scores.fetchEndless()
    debug('fetchEndless> Starting endless archive score fetch')
    
    -- Query endless dungeon leaderboard for solo and duo
    -- Using endlessDungeonId = 0 for Endless Archive
    api.scores.requestEndless(ENDLESS_DUNGEON_GROUP_TYPE_SOLO, 0)
    -- Note: Duo query will be triggered from the solo callback to avoid race conditions
end

-- callback for when a trial score is received
function scores.fetchTrialsCallback(event, raidCategory, lbIndex, classId)
    local score = api.scores.resultTrial(lbIndex)
    scores.save('trial',lbIndex, score) 
    debug('fetchTrialsCallback: ' .. tostring(lbIndex) .. ' score: ' .. tostring(score))

    -- fetch next trial
    scores.fetchTrials(lbIndex + 1)
end

-- callback for when endless dungeon scores are received
function scores.fetchEndlessCallback(event, endlessDungeonGroupType, endlessDungeonId, classId)
    debug('fetchEndlessCallback: groupType=' .. tostring(endlessDungeonGroupType) .. ' dungeonId=' .. tostring(endlessDungeonId))
    
    local _, bestScoreSolo = GetEndlessDungeonLeaderboardLocalPlayerInfo(ENDLESS_DUNGEON_GROUP_TYPE_SOLO, endlessDungeonId)
    local _, bestScoreDuo = GetEndlessDungeonLeaderboardLocalPlayerInfo(ENDLESS_DUNGEON_GROUP_TYPE_DUO, endlessDungeonId)

    debug('fetchEndlessCallback: bestScoreSolo=' .. tostring(bestScoreSolo) .. ' bestScoreDuo=' .. tostring(bestScoreDuo))

    -- Get abbreviations for solo and duo endless archive scores
    local abbvSolo = PITHKA.data.filterAchievements({IAINDEX=0}, {'ABBV'})  -- Solo endless archive
    local abbvDuo = PITHKA.data.filterAchievements({IAINDEX=1}, {'ABBV'})   -- Duo endless archive

    debug('fetchEndlessCallback: abbvSolo=' .. tostring(abbvSolo) .. ' abbvDuo=' .. tostring(abbvDuo))
    debug('fetchEndlessCallback: ENDLESS_DUNGEON_GROUP_TYPE_SOLO=' .. tostring(ENDLESS_DUNGEON_GROUP_TYPE_SOLO))
    debug('fetchEndlessCallback: ENDLESS_DUNGEON_GROUP_TYPE_DUO=' .. tostring(ENDLESS_DUNGEON_GROUP_TYPE_DUO))

    if bestScoreSolo and bestScoreSolo > 0 and abbvSolo then
        scores.save('endless', endlessDungeonId, bestScoreSolo, abbvSolo)
        debug('fetchEndlessCallback: saved solo score ' .. tostring(bestScoreSolo) .. ' for ' .. tostring(abbvSolo))
    else
        debug('fetchEndlessCallback: solo score NOT saved - bestScoreSolo=' .. tostring(bestScoreSolo) .. ' abbvSolo=' .. tostring(abbvSolo))
    end

    if bestScoreDuo and bestScoreDuo > 0 and abbvDuo then
        scores.save('endless', endlessDungeonId, bestScoreDuo, abbvDuo)
        debug('fetchEndlessCallback: saved duo score ' .. tostring(bestScoreDuo) .. ' for ' .. tostring(abbvDuo))
    else
        debug('fetchEndlessCallback: duo score NOT saved - bestScoreDuo=' .. tostring(bestScoreDuo) .. ' abbvDuo=' .. tostring(abbvDuo))
    end

    -- If this was the solo callback, also query duo scores
    if endlessDungeonGroupType == ENDLESS_DUNGEON_GROUP_TYPE_SOLO then
        debug('fetchEndlessCallback: querying duo scores after solo')
        api.scores.requestEndless(ENDLESS_DUNGEON_GROUP_TYPE_DUO, endlessDungeonId)
    end
end

-- callback for when a new endless archive best score is achieved
function scores.onEndlessNewBestScore(event, endlessDungeonName, score)
    debug('onEndlessNewBestScore: dungeonName=' .. tostring(endlessDungeonName) .. ' score=' .. tostring(score))
    
    if endlessDungeonName == 131824 then -- 131824 is the ID for Endless Archive
        local _, bestScoreSolo = GetEndlessDungeonLeaderboardLocalPlayerInfo(ENDLESS_DUNGEON_GROUP_TYPE_SOLO, nil)
        local _, bestScoreDuo = GetEndlessDungeonLeaderboardLocalPlayerInfo(ENDLESS_DUNGEON_GROUP_TYPE_DUO, nil)

        debug('onEndlessNewBestScore: bestScoreSolo=' .. tostring(bestScoreSolo) .. ' bestScoreDuo=' .. tostring(bestScoreDuo))

        local abbvSolo = PITHKA.data.filterAchievements({IAINDEX=0}, {'ABBV'})  -- Solo endless archive
        local abbvDuo = PITHKA.data.filterAchievements({IAINDEX=1}, {'ABBV'})   -- Duo endless archive

        if bestScoreSolo and bestScoreSolo > 0 and abbvSolo then
            scores.save('endless', 0, bestScoreSolo, abbvSolo)
            debug('onEndlessNewBestScore: saved new solo score ' .. tostring(bestScoreSolo))
        end

        if bestScoreDuo and bestScoreDuo > 0 and abbvDuo then
            scores.save('endless', 0, bestScoreDuo, abbvDuo)
            debug('onEndlessNewBestScore: saved new duo score ' .. tostring(bestScoreDuo))
        end
    else
        debug("PAT: New Endless Dungeon ID found " .. tostring(endlessDungeonName))
    end
end

EVENT_MANAGER:RegisterForEvent(PITHKA.name, EVENT_RAID_LEADERBOARD_DATA_RECEIVED, scores.fetchTrialsCallback)
EVENT_MANAGER:RegisterForEvent(PITHKA.name, EVENT_ENDLESS_DUNGEON_LEADERBOARD_DATA_RECEIVED, scores.fetchEndlessCallback)
EVENT_MANAGER:RegisterForEvent(PITHKA.name, EVENT_ENDLESS_DUNGEON_NEW_BEST_SCORE, scores.onEndlessNewBestScore)


--------------------------------
-- ESOUI API callback handling
--------------------------------


-- function scores.callback.endless(endlessDungeonGroupType, endlessDungeonId, classId)
--     -- to do, do both become available after a single callback?  I would suspect they're per group type
--     local _, bestScoreSolo = GetEndlessDungeonLeaderboardLocalPlayerInfo(ENDLESS_DUNGEON_GROUP_TYPE_SOLO, endlessDungeonId)
--     local _, bestScoreDuo = GetEndlessDungeonLeaderboardLocalPlayerInfo(ENDLESS_DUNGEON_GROUP_TYPE_DUO, endlessDungeonId)
-- end

-- EVENT_MANAGER:RegisterForEvent(PITHKA.name, EVENT_RAID_LEADERBOARD_DATA_RECEIVED, scores.callback.trial)
-- EVENT_MANAGER:RegisterForEvent(PITHKA.name, EVENT_ENDLESS_DUNGEON_LEADERBOARD_DATA_RECEIVED, scores.callback.endless)

-- function scores.callback.trial(event, raidCategory, raidId, classId)
--     -- print arguement in single line
--     d('|cFFA500DEBUG - raidCategory' .. tostring(raidCategory) .. ' raidId' .. tostring(raidId) .. ' classId' .. tostring(classId) .. '|r')
--     -- data is now available
--     local _, bestScore = GetRaidLeaderboardLocalPlayerInfo(raidId)
--     scores.save('trial',raidId, bestScore)
-- end


