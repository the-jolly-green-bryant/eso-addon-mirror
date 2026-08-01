local Log = IMP_PVP_UI_Logger('IMP_PVP_UI_BG_LABELS')

local PI = math.pi
local EVENT_NAMESPACE = 'IMP_BGL_EVENT_NAMESPACE'

local ZONES = {
    [520] = {   -- Reman's Folly (8)
        [1] = {{48400, 12000, 34600}, {0,  0.5*PI, 0, true}},  -- VV
        [2] = {{42400, 12000, 25000}, {0, -0.5*PI, 0, true}},  -- VV
    },
    [1481] = {  -- Mota Ka (4/8)
        [1] = {{54955-800, 13590, 15760}, {0, 0, 0, true}},
        [2] = {{54955+800, 13590, 15760}, {0, 1*PI, 0, true}},
    },
    [1482] = {  -- Strid River Valley (8)
        [1] = {{57000, 12060, 20829}, {0,  0.45*PI, 0, true}},  -- VVV
        [2] = {{53000, 12060, 19000}, {0, -0.53*PI, 0, true}},  -- VVV
    },
    [1483] = {  -- Huntsman's Fortress (4/8)
        [1] = {{58100, 11800, 41500}, {0,  0.73*PI, 0, true}}, -- VVV
        [2] = {{57300, 11800, 40700}, {0, -0.27*PI, 0, true}}, -- VVV
    },
    [1484] = {  -- Shehai Waystation (8)
        [1] = {{33590, 12800, 61500}, {0, -0.5*PI, 0, true}},  -- VVV
        [2] = {{42650, 12800, 55800}, {0, 0.73*PI, 0, true}},  -- VVV
    },
    [1485] = {  -- Port Dufort (8)
        [1] = {{45750, 53500, 53350}, {0, -0.29*PI, 0, true}},  -- VVV
        [2] = {{54500, 52000, 46900}, {0,  0.72*PI, 0, true}},  -- VV
    },
    [1504] = {  -- Coldharbour Colosseum (4)
        [1] = {{49200, 5800, 49200}, {0,  0.77*PI, 0, true}},  -- ~
        [2] = {{49200, 5800, 49200}, {0, -0.23*PI, 0, true}},  -- VVV
    },
    -- [1011] = {  -- Alinor, Summerset - for testing
    --     {161300-500, 18350+1500, 331660+1000},
    --     {0, 0.30*PI, 0.05*PI, true},
    -- }
}

local OUTLINE = false
local MAX_WIDTH = nil
local TIMER_SIZE = 5
local VS_SIZE = 3
local PLAYER_COUNTER_SIZE = 4.5
local SCORE_SIZE = 4.5

-- local BUFF_ID = 52291
local BUFF_ID = 97414

-- local battlegroundLabels = LibImplex.Marker('imp-bg-labels')

local defaultColor = {GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HIGHLIGHT)}
local teamColors = {}
do
    for i = 1, 3 do  -- possible problem  if number of teams will be different
        -- local r, g, b, a = GetInterfaceColor(INTERFACE_COLOR_TYPE_BATTLEGROUND_TEAM, i)
        teamColors[i] = {GetInterfaceColor(INTERFACE_COLOR_TYPE_BATTLEGROUND_TEAM, i)}
    end
end

local countdownLabel
local vsLabel
local teamLabels = {}
local typeLabel
local scoreLabels = {}

local teamLabelPositions = {
    {
        anchorPoint = RIGHT,
        -- relativeTo = vsLabel,
        relativePoint = {LEFT, -50, -95, 5},
    },
    {
        anchorPoint = LEFT,
        -- relativeTo = vsLabel,
        relativePoint = {RIGHT, 50, -95, 5},
    },
}

local scoreLabelPositions = {
    {
        anchorPoint = RIGHT,
        -- relativeTo = countdownLabel,
        relativePoint = {CENTER, -90, 300, 5},
    },
    {
        anchorPoint = LEFT,
        -- relativeTo = countdownLabel,
        relativePoint = {CENTER, 90, 300, 5},
    },
}

local position = nil
local orientation = nil

local function UpdatePlayers()
    local numPlayers = {0, 0}

    local roundIndex = GetCurrentBattlegroundRoundIndex()
    local numScoreboardEntries = GetNumScoreboardEntries(roundIndex)
    for entryIndex = 1, numScoreboardEntries do
        local characterName, displayName, battlegroundTeam, isLocalPlayer = GetScoreboardEntryInfo(entryIndex, roundIndex)
        numPlayers[battlegroundTeam] = numPlayers[battlegroundTeam] + 1
    end

    for i = 1, 2 do
        local teamLabel = teamLabels[i]
        teamLabel.text = tostring(numPlayers[i])
        teamLabel:Render()
    end
end

local function UpdateScore()
    local currentRound = GetCurrentBattlegroundRoundIndex()

    for i = 1, 2 do
        scoreLabels[i].text = tostring(GetCurrentBattlegroundScore(currentRound, i))
        scoreLabels[i]:Render()
    end
end

local function DrawLabel()
    if not (position and orientation) then return end

    countdownLabel = LibImplex.Text('00:00', nil, position, orientation, TIMER_SIZE, defaultColor, MAX_WIDTH, OUTLINE, nil, LibImplex.Fonts._Monospace)
    countdownLabel:Render()

    local countdownLabelBottom = {countdownLabel:GetRelativePointCoordinates(BOTTOM, 0, 100, 5)}
    vsLabel = LibImplex.Text('vs', TOP, countdownLabelBottom, orientation, VS_SIZE, defaultColor, MAX_WIDTH, OUTLINE)
    vsLabel:Render()

    for i = 1, 2 do  -- possible problem  if number of teams will be different
        local anchorPoint = teamLabelPositions[i].anchorPoint
        local relativeTo = vsLabel
        local relativePoint = teamLabelPositions[i].relativePoint

        local labelPosition = {relativeTo:GetRelativePointCoordinates(unpack(relativePoint))}

        teamLabels[i] = LibImplex.Text('9', anchorPoint, labelPosition, orientation, PLAYER_COUNTER_SIZE, teamColors[i], MAX_WIDTH, OUTLINE)
        -- teamLabels[i]:Render()
    end

    local battlegroundType = GetCurrentBattlegroundGameType()
    local gameTypeString = GetString('SI_BATTLEGROUNDGAMETYPE', battlegroundType)

    local countdownLabelTop = {countdownLabel:GetRelativePointCoordinates(TOP, 0, -80, 5)}
    typeLabel = LibImplex.Text(gameTypeString, BOTTOM, countdownLabelTop, orientation, VS_SIZE, defaultColor, MAX_WIDTH, OUTLINE)
    typeLabel:Render()

    for i = 1, 2 do  -- possible problem  if number of teams will be different
        local anchorPoint = scoreLabelPositions[i].anchorPoint
        local relativeTo = typeLabel
        local relativePoint = scoreLabelPositions[i].relativePoint

        local labelPosition = {relativeTo:GetRelativePointCoordinates(unpack(relativePoint))}

        scoreLabels[i] = LibImplex.Text('999', anchorPoint, labelPosition, orientation, SCORE_SIZE, teamColors[i], MAX_WIDTH, OUTLINE)
        -- scoreLabels[i]:Render()
    end

    UpdatePlayers()
    UpdateScore()
end

local function Countdown()
    if not countdownLabel then return end

    local timer = math.floor(BATTLEGROUND_HUD_FRAGMENT.currentBattlegroundTimeMS / 1000)

    local minutes = math.floor(timer / 60)
    local seconds = timer % 60

    countdownLabel.text = ('%02d:%02d'):format(minutes, seconds)
    countdownLabel:Render()
end

local function EnableLabels()
    if not countdownLabel then
        DrawLabel()
    end

    EVENT_MANAGER:RegisterForUpdate(EVENT_NAMESPACE, 100, Countdown)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_BATTLEGROUND_SCOREBOARD_UPDATED, UpdatePlayers)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ZONE_SCORING_CHANGED, UpdateScore)
end

local function DisableLabels()
    EVENT_MANAGER:UnregisterForUpdate(EVENT_NAMESPACE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_BATTLEGROUND_SCOREBOARD_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_ZONE_SCORING_CHANGED)

    if countdownLabel then countdownLabel:Wipe() end
    if countdownLabel then vsLabel:Wipe() end
    if countdownLabel then typeLabel:Wipe() end

    countdownLabel = nil
    vsLabel = nil
    typeLabel = nil

    for i, teamLabel in ipairs(teamLabels) do
        teamLabel:Wipe()
        teamLabels[i] = nil
    end

    for i, scoreLabel in ipairs(scoreLabels) do
        scoreLabel:Wipe()
        scoreLabels[i] = nil
    end
end

local function SpecificBuffChanged(_, changeType)
    if changeType ~= EFFECT_RESULT_FADED then return end

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_EFFECT_CHANGED)
    Log('Jumped from respawn, labels are turned off')
    DisableLabels()
end

local function OnPlayerAlive()
    local numBuffs = GetNumBuffs('player')
    for i = 1, numBuffs do
        local buffName, _, _, buffSlot, _, _, _, _, _, _, abilityId = GetUnitBuffInfo('player', i)
        Log('%d: %s', abilityId, buffName)

        if abilityId == BUFF_ID then  -- 232335 232356 why these are different??
            Log('Found Specific buff, turning labels on')
            EnableLabels()
            EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_EFFECT_CHANGED, SpecificBuffChanged)
            EVENT_MANAGER:AddFilterForEvent(EVENT_NAMESPACE, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, BUFF_ID, REGISTER_FILTER_UNIT_TAG, 'player')
            return
        end

        -- EnableLabels()  -- for testing
    end

    Log('Specific buff not found')
end

local function UnregisterEvents()
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ALIVE)
end

local function OnPlayerActivated()
    local zoneId = GetZoneId(GetUnitZoneIndex('player'))

    local team = GetUnitBattlegroundTeam('player')
    if team == 0 then
        Log('Team is 0 -> not a battleground zone for sure, turning labels off')
        UnregisterEvents()
        DisableLabels()
        return
    end

    Log('Team: %d', team)

    if not ZONES[zoneId] or ZONES[zoneId][team] then
        Log('No data for zoneId %d team %d', zoneId, team)
        return
    end
    position, orientation = unpack(ZONES[zoneId][team])

    local balltegroundZone = position ~= nil

    if not balltegroundZone then
        Log('Not a battleground zone, turning labels off')
        UnregisterEvents()
        DisableLabels()
        return
    end

    OnPlayerAlive()

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ALIVE, OnPlayerAlive)
end

function IMP_BL_Initialize()
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end
