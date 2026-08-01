local Runner = {
    started = false,
    timeout = 900,
    activeBuff = 0,
    data = {
        direction = 1,
        startedTime = 0,
        dolmensClosed = 0,
        xpPerMinute = 0,
        minutesToLevel = 0,
        hoursToLevel = 0,
        currentDolmen = 0,
        lastDomen = 0,
        beforeLastDolmen = 0,
        events = {}
    },
    defaultData = {
        direction = 1,
        startedTime = 0,
        dolmensClosed = 0,
        xpPerMinute = 0,
        minutesToLevel = 0,
        hoursToLevel = 0,
        currentDolmen = 0,
        lastDolmen = 0,
        beforeLastDolmen = 0,
        events = {}
    },
    directions = {
        cw = 1,
        ccw = -1
    },
    wayshrines = {
        -- summerset 353 358 349 357 365
        [59] = { region="Alik'r Desert", cw = 60, ccw = 155},
        [60] = { region="Alik'r Desert", cw = 155, ccw = 59},
        [155] = { region="Alik'r Desert", cw = 59, ccw = 60},
        [127] = { region="Auridon", cw = 175, ccw = 176},
        [175] = { region="Auridon", cw = 176, ccw = 127},
        [176] = { region="Auridon", cw = 127, ccw = 175},
        [39] = { region="Bangkorai", cw = 206, ccw = 35},
        [206] = { region="Bangkorai", cw = 35, ccw = 39},
        [35] = { region="Bangkorai", cw = 39, ccw = 206},
        [30] = { region="Deshaan", cw = 27, ccw = 80},
        [27] = { region="Deshaan", cw = 80, ccw = 30},
        [80] = { region="Deshaan", cw = 30, ccw = 27},
        [95] = { region="Eastmarch", cw = 92, ccw = 90},
        [92] = { region="Eastmarch", cw = 90, ccw = 95},
        [90] = { region="Eastmarch", cw = 95, ccw = 92},
        [20] = { region="Glenumbra", cw = 6, ccw = 2},
        [6] = { region="Glenumbra", cw = 2, ccw = 20},
        [2] = { region="Glenumbra", cw = 20, ccw = 6},
        [207] = { region="Grahtwood", cw = 164, ccw = 21},
        [164] = { region="Grahtwood", cw = 21, ccw = 207},
        [21] = { region="Grahtwood", cw = 207, ccw = 164},
        [148] = { region="Greenshade", cw = 152, ccw = 149},
        [152] = { region="Greenshade", cw = 149, ccw = 148},
        [149] = { region="Greenshade", cw = 148, ccw = 152},
        [103] = { region="Malabal Tor", cw = 100, ccw = 105},
        [100] = { region="Malabal Tor", cw = 105, ccw = 103},
        [105] = { region="Malabal Tor", cw = 103, ccw = 100},
        [162] = { region="Reaper's March", cw = 158, ccw = 157},
        [158] = { region="Reaper's March", cw = 157, ccw = 162},
        [157] = { region="Reaper's March", cw = 162, ccw = 158},
        [10] = { region="Ravenspire", cw = 13, ccw = 86},
        [13] = { region="Ravenspire", cw = 86, ccw = 10},
        [86] = { region="Ravenspire", cw = 10, ccw = 13},
        [51] = { region="Shadowfen", cw = 53, ccw = 47},
        [53] = { region="Shadowfen", cw = 47, ccw = 51},
        [47] = { region="Shadowfen", cw = 51, ccw = 53},
        [73] = { region="Stonefalls", cw = 67, ccw = 71},
        [67] = { region="Stonefalls", cw = 71, ccw = 73},
        [71] = { region="Stonefalls", cw = 73, ccw = 67},
        [17] = { region="Stormhaven", cw = 19, ccw = 31},
        [19] = { region="Stormhaven", cw = 31, ccw = 17},
        [31] = { region="Stormhaven", cw = 17, ccw = 19},
        [110] = { region="The Rift", cw = 116, ccw = 114},
        [116] = { region="The Rift", cw = 114, ccw = 110},
        [114] = { region="The Rift", cw = 110, ccw = 116}
    }
}

function Runner:Start()
    LeoDolmenRunner.log("Starting runner")
    local direction = Runner.data.direction
    local lastDolmen = Runner.data.lastDolmen or 0
    local beforeLastDolmen = Runner.data.beforeLastDolmen or 0
    ZO_ShallowTableCopy(Runner.defaultData, Runner.data)
    Runner.data.startedTime = GetTimeStamp()
    Runner.data.direction = direction
    Runner.data.lastDolmen = lastDolmen
    Runner.data.beforeLastDolmen = beforeLastDolmen
    Runner.started = true
    LeoDolmenRunnerWindowPanelStartStopLabel:SetText("Stop")
    LeoDolmenRunner.ui:CreateUI()
    self:GetActiveBuff()
end

function Runner:Stop()
    LeoDolmenRunner.log("Stopping runner")
    Runner.started = false
    LeoDolmenRunnerWindowPanelStartStopLabel:SetText("Start")
end

function Runner:StartStop()
    if Runner.started then
        Runner:Stop()
    else
        Runner:Start()
    end
end

function Runner:CW()
    LeoDolmenRunner.log("Changing direction to clock wise")
    Runner.data.direction = Runner.directions.cw
    LeoDolmenRunnerWindowPanelOrientationLabel:SetText("CW")
end

function Runner:CCW()
    LeoDolmenRunner.log("Changing direction to counter clock wise")
    Runner.data.direction = Runner.directions.ccw
    LeoDolmenRunnerWindowPanelOrientationLabel:SetText("CCW")
end

function Runner:CWCCW()
    if Runner.data.direction == Runner.directions.cw then
        Runner:CCW()
    else
        Runner:CW()
    end
end

function Runner:OnFastTravelInteraction(currentWayshrine)
    if not Runner.started or Runner.wayshrines[currentWayshrine] == nil then return end

    local nextWayshrine = nil
    if Runner.data.direction == Runner.directions.cw then
        nextWayshrine = Runner.wayshrines[currentWayshrine].cw
    else
        nextWayshrine = Runner.wayshrines[currentWayshrine].ccw
    end

    local discovered, name = GetFastTravelNodeInfo(nextWayshrine)
    if not discovered then
        LeoDolmenRunner.log("Can't fast travel: " .. name .. " not discovered yet.")
        return
    end

    FastTravelToNode(nextWayshrine)
end

local function calculateXpPerMinute(xp, timestamp)
    local diff = GetDiffBetweenTimeStamps(GetTimeStamp(), timestamp)
    diff = (diff == 0) and 1 or diff

    return xp / (diff / 60)
end

local function TimeToLevel()
    local xpToLevel = 0
    if (CanUnitGainChampionPoints("player")) then
        xpToLevel = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned("player")) - GetPlayerChampionXP()
    else
        xpToLevel = GetNumExperiencePointsInLevel(GetUnitLevel("player")) - GetUnitXP("player")
    end

    local minutesToLevel = math.ceil(xpToLevel / Runner.data.xpPerMinute)

    if minutesToLevel < 60 then return 0, minutesToLevel end

    local hoursToLevel = math.floor(minutesToLevel / 60)
    minutesToLevel = minutesToLevel - (hoursToLevel * 60)

    return hoursToLevel, minutesToLevel
end

function Runner:UpdateData()
    local xpGained = 0
    local firstEventTimestamp = 0
    if (#Runner.data.events > 0) then
        for i, event in pairs(Runner.data.events) do
            if GetDiffBetweenTimeStamps(GetTimeStamp(), event.timestamp) > Runner.timeout then
                Runner.data.events[i] = nil
            else
                xpGained = xpGained + event.xp

                if firstEventTimestamp == 0 or event.timestamp < firstEventTimestamp then
                    firstEventTimestamp = event.timestamp
                end

            end
        end
    end

    Runner.data.xpPerMinute = calculateXpPerMinute(xpGained, firstEventTimestamp)

    if xpGained > 0 then
        Runner.data.hoursToLevel, Runner.data.minutesToLevel = TimeToLevel()
    end
end

function Runner:Update(tick)
    if not Runner.started or tick ~= 5 then return end

    self:UpdateData()
end


local assistants = {
    267, -- Nuzhimeh
    300, -- Fence
    301, -- Tythis
    6376, -- Ezabi
    6378 -- Fezez
}

local buffs = {
    { id =  479, from = 1022, to = 1103 }, -- Witchmother's Whistle
    { id = 1167, from =  326, to =  403 }, -- The Pie of Misrule
    { id = 1168, from = 1217, to = 1231 }, -- Breda's Bottomless Mead Mug
    { id = 1168, from =  101, to =  105 }, -- Breda's Bottomless Mead Mug
    { id = 7619, abilityId = 136348 }, -- Jubilee Cake 2020
    { id = 5886 }, -- Jubilee Cake 2019
    { id = 4786 }, -- Jubilee Cake 2018
    { id = 1109 }, -- Jubilee Cake 2017
    { id =  356 }, -- Jubilee Cake 2016
}

function Runner:IsBuffActive(collectible)
    if type(collectible) ~= "table" then
        for _, buff in ipairs(buffs) do
            if buff.id == collectible then
                collectible = buff
                break
            end
        end
    end
    for i = 1, GetNumBuffs("player") do
        local buffName, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if collectible.abilityId and abilityId == collectible.abilityId then return true end
    end
    return false
end

function Runner:OnCombatState(inCombat)
    if not Runner.started then return end

    if IsUnitDead("player") then
        zo_callLater(function() Runner:OnCombatState(inCombat) end, 500)
        return
    end

    if not inCombat and LeoDolmenRunner.settings.runner.reapplyBuff then
        if Runner.activeBuff == 0 then
            local date = tonumber(os.date("%m%d", GetTimeStamp()))
            for _, collectible in ipairs(buffs) do
                local _, _, _, _, unlocked = GetCollectibleInfo(collectible.id)
                if unlocked and collectible.from and collectible.from <= date and collectible.to > date then
                    Runner.activeBuff = collectible.id
                    break
                end
            end
        end

        if Runner.activeBuff > 0 and not self:IsBuffActive(Runner.activeBuff) then
            LeoDolmenRunner.log("Reapplying " .. GetCollectibleInfo(Runner.activeBuff))
            UseCollectible(Runner.activeBuff)
        end
    end

    if inCombat and LeoDolmenRunner.settings.runner.autoDismiss then
        for _, id in pairs(assistants) do
            if IsCollectibleActive(id) then
                LeoDolmenRunner.log("Dismissing " .. GetCollectibleInfo(id))
                UseCollectible(id)
            end
        end
    end
end

function Runner:OnExperienceGain(reason, level, previousExperience, currentExperience, championPoints)
    if not Runner.started then return end

    local event = {
        timestamp = GetTimeStamp(),
        xp = currentExperience - previousExperience
    }
    table.insert(Runner.data.events, event)

    Runner.data.currentDolmen = Runner.data.currentDolmen + event.xp

    if reason == 7 then
        Runner.data.dolmensClosed = Runner.data.dolmensClosed + 1
        Runner.data.beforeLastDolmen = Runner.data.lastDolmen
        Runner.data.lastDolmen = Runner.data.currentDolmen
        Runner.data.currentDolmen = 0
    end

    self:UpdateData()
end

function Runner:GetActiveBuff()
    for _, collectible in pairs(buffs) do
        if self:IsBuffActive(collectible) then
            Runner.activeBuff = collectible.id
            -- LeoDolmenRunner.debug("Found buff " .. Runner.activeBuff)
            return
        end
    end
end

function Runner:Initialize()
    Runner.activeBuff = 0
    self:GetActiveBuff()
end

LeoDolmenRunner.runner = Runner
