STARS = {}
STARS.name = "STARS"
STARS.version = "0.5.38-test16"
STARS.sv = nil

STARS.CP_MILESTONES = {160,300,600,900,1200,1500,1800,2100,2400,2700,3000,3300,3600}

-- STARS progression is deliberately split into two phases.
-- 0 -> Champion cap: a deterministic 300-CP Legacy ladder.
-- Champion cap onward: unlimited Prestige ranks, each costing the same XP as
-- ESO's final Champion Point. Presentation/coat-of-arms code consumes this
-- model but does not own the maths.
STARS.LEGACY_RANK_SIZE = 300
STARS.LEGACY_RANKS = {
    { name = "Wayfarer",        key = "wayfarer" },
    { name = "Pathfinder",      key = "pathfinder" },
    { name = "Standard Bearer", key = "standard_bearer" },
    { name = "Vanguard",        key = "vanguard" },
    { name = "Guardian",        key = "guardian" },
    { name = "Sentinel",        key = "sentinel" },
    { name = "Champion",        key = "champion" },
    { name = "Paragon",         key = "paragon" },
    { name = "Exemplar",        key = "exemplar" },
    { name = "Luminary",        key = "luminary" },
    { name = "Ascendant",       key = "ascendant" },
    { name = "Venerated",       key = "venerated" },
}

STARS.LEGACY_EMBLEM_STEP = 50
STARS.LEGACY_MAX_EMBLEMS = 5
STARS.PRESTIGE_BADGE_STEP = 10
STARS.PRESTIGE_BADGES_PER_TIER = 11
STARS.PRESTIGE_TIER_SIZE = STARS.PRESTIGE_BADGE_STEP * STARS.PRESTIGE_BADGES_PER_TIER
STARS.PRESTIGE_TIER_NAMES = { "Bronze", "Silver", "Gold" }

local DEFAULTS = {
    options = {
        enabled = true,
        debug = false,
        heraldryEnabled = true,
        sound = true,
        csa = false,
        startCP = 160,
        campaignRetention = 3, -- legacy Cyrodiil history retention
        veterancyRetention = 4, -- current season + previous 3 archived seasons
    },
    prestige = { baselineCP = 0, level = 0, session = 0, lastCP = 0, postCapRanks = nil, postCapXP = nil, xpPerRank = nil },
    stats = {
        pvp = {
            kills = 0, deaths = 0, revives = 0,
            keepsTaken = 0, keepsDefended = 0, apEarned = 0,
            battlegrounds = { kills = 0, deaths = 0, assists = 0, matches = 0 },
        },
        underworld = {
            pickpockets = 0,
            bladeOfWoeKills = 0,
            trackingStarted = 0,
            bladeOfWoeAbilityIds = {},
        },
        campaigns = { current = nil, history = {} }, -- retained for backwards compatibility
        veterancy = { current = nil, history = {} },
    },
    _dirtyTick = 0,
    _dirtyTime = 0,
}

local function Debug(msg)
    if STARS.sv and STARS.sv.options and STARS.sv.options.debug then
        if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
            CHAT_ROUTER:AddSystemMessage("[STARS] " .. tostring(msg))
        else
            d("[STARS] " .. tostring(msg))
        end
    end
end

local function Now()
    return GetTimeStamp and GetTimeStamp() or 0
end

local function FrameMs()
    if GetFrameTimeMilliseconds then
        return GetFrameTimeMilliseconds()
    end
    return Now() * 1000
end

local function IsPlayerSource(unitType)
    return unitType == COMBAT_UNIT_TYPE_PLAYER or unitType == COMBAT_UNIT_TYPE_PLAYER_PET
end

local function IsPlayerTarget(unitType)
    return unitType == COMBAT_UNIT_TYPE_PLAYER
end

function STARS:TouchSV()
    if not self.sv then return end
    self.sv._dirtyTick = (tonumber(self.sv._dirtyTick) or 0) + 1
    self.sv._dirtyTime = Now()
end

function STARS:IsEnabled()
    return self.sv and self.sv.options and self.sv.options.enabled == true
end

function STARS:GetPlayerCP()
    if GetUnitChampionPoints then
        local cp = GetUnitChampionPoints("player")
        if type(cp) == "number" then return cp end
    end
    return 0
end

function STARS:GetHighestBracketLE(cp)
    local best = 160
    for _, m in ipairs(self.CP_MILESTONES) do
        if m <= (tonumber(cp) or 0) then best = m end
    end
    return best
end

function STARS:NormalizeStartBracket()
    local cp = self:GetPlayerCP()
    if cp < 160 then return 160 end
    return self:GetHighestBracketLE(cp)
end

function STARS:GetChampionProgressionCap()
    -- STARS needs the absolute Champion Point ceiling, not the player's
    -- current progression-cap value. On console GetChampionPointsPlayerProgressionCap()
    -- can resolve to the player's current CP (for example 2375), which would
    -- incorrectly switch Legacy progression into permanent Prestige early.
    return 3600
end

function STARS:GetFinalChampionPointXP()
    local cap = self:GetChampionProgressionCap()
    if type(GetNumChampionXPInChampionPoint) == "function" then
        local ok, xp = pcall(GetNumChampionXPInChampionPoint, math.max(0, cap - 1))
        if ok and type(xp) == "number" and xp > 0 then return xp end
    end
    return nil
end

function STARS:GetPrestigeTierName(tierNumber)
    tierNumber = math.max(1, math.floor(tonumber(tierNumber) or 1))
    local known = self.PRESTIGE_TIER_NAMES[tierNumber]
    if known then return known end
    -- We only name the first three tiers until the visual language beyond Gold
    -- is designed. The numeric fallback keeps the progression engine unlimited.
    return "Prestige Tier " .. tostring(tierNumber)
end

function STARS:GetPrestigeProgression()
    local cp = self:GetPlayerCP()
    local cap = self:GetChampionProgressionCap()
    local p = self.sv and self.sv.prestige or {}

    if cp < cap then
        local rankIndex = math.floor(math.max(0, cp) / self.LEGACY_RANK_SIZE) + 1
        rankIndex = math.max(1, math.min(#self.LEGACY_RANKS, rankIndex))
        local rank = self.LEGACY_RANKS[rankIndex]
        local baseline = (rankIndex - 1) * self.LEGACY_RANK_SIZE
        local level = math.max(0, cp - baseline)
        local emblemCount = math.min(self.LEGACY_MAX_EMBLEMS, math.floor(level / self.LEGACY_EMBLEM_STEP))
        local nextEmblemAt = emblemCount < self.LEGACY_MAX_EMBLEMS
            and ((emblemCount + 1) * self.LEGACY_EMBLEM_STEP) or nil
        local xpInPoint = type(GetPlayerChampionXP) == "function" and GetPlayerChampionXP() or 0
        local xpForPoint = type(GetNumChampionXPInChampionPoint) == "function"
            and GetNumChampionXPInChampionPoint(cp) or nil

        return {
            phase = "legacy",
            championPoints = cp,
            cap = cap,
            baselineCP = baseline,
            rankIndex = rankIndex,
            rankName = rank.name,
            rankKey = rank.key,
            level = level,
            emblemCount = emblemCount,
            nextEmblemAt = nextEmblemAt,
            xp = tonumber(xpInPoint) or 0,
            xpRequired = tonumber(xpForPoint) or 0,
        }
    end

    local totalRanks = math.max(0, math.floor(tonumber(p.postCapRanks) or tonumber(p.level) or 0))
    -- Permanent Prestige mirrors the zero-based Legacy bands: Bronze 0-109,
    -- Silver 0-109, Gold 0-109, etc. Each ten ranks selects the next of the
    -- eleven badge states, so rank 110 cleanly becomes Silver 0.
    local tierNumber = math.floor(totalRanks / self.PRESTIGE_TIER_SIZE) + 1
    local tierLevel = totalRanks % self.PRESTIGE_TIER_SIZE
    local badgeStage = math.floor(tierLevel / self.PRESTIGE_BADGE_STEP) + 1

    return {
        phase = "prestige",
        championPoints = cp,
        cap = cap,
        baselineCP = cap,
        rankName = self:GetPrestigeTierName(tierNumber),
        tierName = self:GetPrestigeTierName(tierNumber),
        tierNumber = tierNumber,
        level = tierLevel,
        totalPrestigeRanks = totalRanks,
        badgeStage = badgeStage,
        xp = math.max(0, tonumber(p.postCapXP) or 0),
        xpRequired = math.max(0, tonumber(p.xpPerRank) or tonumber(self:GetFinalChampionPointXP()) or 0),
    }
end

function STARS:ResetPrestigeBaseline()
    if not self.sv then return end
    local current = self:GetPlayerCP()
    local cap = self:GetChampionProgressionCap()
    local p = self.sv.prestige

    if current < cap then
        local progression = self:GetPrestigeProgression()
        self.sv.options.startCP = progression.baselineCP
        p.baselineCP = progression.baselineCP
        p.lastCP = current
        p.level = progression.level
        p.session = 0
    else
        -- Explicit user reset at cap starts permanent Prestige again from zero.
        self.sv.options.startCP = cap
        p.baselineCP = cap
        p.lastCP = current
        p.level = 0
        p.session = 0
        p.postCapRanks = 0
        p.postCapXP = 0
        p.xpPerRank = self:GetFinalChampionPointXP()
    end
    self:TouchSV()
end

function STARS:EnsurePrestigeState()
    if not self.sv then return end
    self.sv.options = self.sv.options or {}
    self.sv.prestige = self.sv.prestige or ZO_ShallowTableCopy(DEFAULTS.prestige)

    local p = self.sv.prestige
    local current = self:GetPlayerCP()
    local cap = self:GetChampionProgressionCap()
    local changed = false

    if current < cap then
        -- Before cap the ranking is a pure function of current CP. This fixes
        -- stale baselines from old versions without touching any other stats.
        local progression = self:GetPrestigeProgression()
        if p.baselineCP ~= progression.baselineCP then p.baselineCP = progression.baselineCP; changed = true end
        if p.level ~= progression.level then p.level = progression.level; changed = true end
        if p.lastCP ~= current then p.lastCP = current; changed = true end
        if self.sv.options.startCP ~= progression.baselineCP then self.sv.options.startCP = progression.baselineCP; changed = true end
        p.session = 0
    else
        -- First cap-aware build: preserve any existing accumulated Prestige as
        -- the starting permanent rank. Afterwards postCapRanks is authoritative.
        if p.postCapRanks == nil then
            p.postCapRanks = math.max(0, math.floor(tonumber(p.level) or 0))
            changed = true
        end
        if p.postCapXP == nil then p.postCapXP = 0; changed = true end
        local finalXP = self:GetFinalChampionPointXP()
        if (tonumber(p.xpPerRank) or 0) <= 0 and finalXP then p.xpPerRank = finalXP; changed = true end
        if p.baselineCP ~= cap then p.baselineCP = cap; changed = true end
        if self.sv.options.startCP ~= cap then self.sv.options.startCP = cap; changed = true end
        if p.lastCP ~= current then p.lastCP = current; changed = true end
        p.level = p.postCapRanks
        p.session = 0
    end

    if changed then self:TouchSV() end
end

function STARS:AnnouncePrestigeGain(delta)
    delta = math.floor(tonumber(delta) or 0)
    if delta <= 0 then return end
    if self.sv.options.sound and PlaySound and SOUNDS and SOUNDS.LEVEL_UP then PlaySound(SOUNDS.LEVEL_UP) end
    if self.sv.options.csa and CENTER_SCREEN_ANNOUNCE and CENTER_SCREEN_ANNOUNCE.CreateMessageParams then
        local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
        if params then
            params:SetText("[STARS] Prestige +" .. tostring(delta))
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
        end
    end
end

function STARS:AccumulatePostCapXP(amount)
    if not self:IsEnabled() or not self.sv then return end
    local cap = self:GetChampionProgressionCap()
    if self:GetPlayerCP() < cap then return end

    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return end

    local p = self.sv.prestige
    local xpPerRank = tonumber(p.xpPerRank) or tonumber(self:GetFinalChampionPointXP()) or 0
    if xpPerRank <= 0 then return end
    p.xpPerRank = xpPerRank

    local pool = math.max(0, tonumber(p.postCapXP) or 0) + amount
    local ranks = math.floor(pool / xpPerRank)
    p.postCapXP = pool % xpPerRank

    if ranks > 0 then
        p.postCapRanks = math.max(0, math.floor(tonumber(p.postCapRanks) or tonumber(p.level) or 0)) + ranks
        p.level = p.postCapRanks
        p.session = math.max(0, tonumber(p.session) or 0) + ranks
        self:AnnouncePrestigeGain(ranks)
    end
    self:TouchSV()
end

function STARS:UpdatePrestige()
    if not self:IsEnabled() or not self.sv then return end
    local current = self:GetPlayerCP()
    local cap = self:GetChampionProgressionCap()
    local p = self.sv.prestige

    if current < cap then
        -- Legacy rank/level is derived directly from CP; no additive state can
        -- drift or reset incorrectly during an addon update.
        local oldLevel = tonumber(p.level) or 0
        local progression = self:GetPrestigeProgression()
        p.baselineCP = progression.baselineCP
        p.level = progression.level
        p.lastCP = current
        self.sv.options.startCP = progression.baselineCP
        if progression.level > oldLevel then
            p.session = math.max(0, tonumber(p.session) or 0) + (progression.level - oldLevel)
        elseif progression.level < oldLevel then
            -- A 300-CP boundary deliberately begins a new named Legacy rank.
            p.session = 0
        end
        self:TouchSV()
        return
    end

    -- At cap actual CP no longer moves. Permanent progression is handled by
    -- AccumulatePostCapXP from the XP events.
    p.lastCP = current
end

function STARS:OnPendingExperienceReward(reason, amount)
    if self:GetPlayerCP() < self:GetChampionProgressionCap() then return end
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return end

    local nowMs = FrameMs()
    local recent = self.lastPrestigeExperienceAward
    if recent and recent.reason == reason and recent.amount == amount and (nowMs - recent.timeMs) <= 1000 then
        return
    end

    self.pendingPrestigeXPToken = (tonumber(self.pendingPrestigeXPToken) or 0) + 1
    local token = self.pendingPrestigeXPToken
    self.pendingPrestigeXP = { token = token, reason = reason, amount = amount, timeMs = nowMs }

    if type(zo_callLater) == "function" then
        zo_callLater(function()
            local pending = STARS.pendingPrestigeXP
            if pending and pending.token == token then
                STARS.pendingPrestigeXP = nil
                STARS.lastPrestigeExperienceAward = { reason = reason, amount = amount, timeMs = FrameMs() }
                STARS:AccumulatePostCapXP(amount)
            end
        end, 500)
    else
        self.pendingPrestigeXP = nil
        self.lastPrestigeExperienceAward = { reason = reason, amount = amount, timeMs = nowMs }
        self:AccumulatePostCapXP(amount)
    end
end

local function SafeApiCall(func, ...)
    if type(func) ~= "function" then return nil end
    local ok, a, b, c, d, e, f, g, h, i, j = pcall(func, ...)
    if not ok then return nil end
    return a, b, c, d, e, f, g, h, i, j
end


local CHRONICLE_MONTHS = {
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
}

local CHRONICLE_KEYWORDS = {
    { text = "emperor", score = 700 },
    { text = "empress", score = 700 },
    { text = "godslayer", score = 600 },
    { text = "planesbreaker", score = 600 },
    { text = "swashbuckler supreme", score = 600 },
    { text = "immortal redeemer", score = 550 },
    { text = "gryphon heart", score = 550 },
    { text = "tick-tock tormentor", score = 550 },
    { text = "unchained", score = 500 },
    { text = "flawless conqueror", score = 500 },
    { text = "master angler", score = 450 },
    { text = "grand overlord", score = 450 },
    { text = "conqueror", score = 160 },
    { text = "trifecta", score = 180 },
}

local function ChronicleDateParts(timestamp)
    timestamp = tonumber(timestamp) or 0
    if timestamp <= 0 or type(GetDateElementsFromTimestamp) ~= "function" then
        return 0, 0, 0
    end
    local year, month, day = SafeApiCall(GetDateElementsFromTimestamp, timestamp)
    return tonumber(year) or 0, tonumber(month) or 0, tonumber(day) or 0
end

local function ChronicleDateKey(year, month, day)
    return ((tonumber(year) or 0) * 10000) + ((tonumber(month) or 0) * 100) + (tonumber(day) or 0)
end

local function ChronicleHighlightScore(name, description, points, categoryName, subCategoryName)
    local score = (tonumber(points) or 0) * 10
    local text = string.lower(table.concat({
        tostring(name or ""), tostring(description or ""),
        tostring(categoryName or ""), tostring(subCategoryName or ""),
    }, " "))

    for _, rule in ipairs(CHRONICLE_KEYWORDS) do
        if string.find(text, rule.text, 1, true) then
            score = score + rule.score
        end
    end

    if string.find(text, "trial", 1, true) then score = score + 90 end
    if string.find(text, "arena", 1, true) then score = score + 70 end
    if string.find(text, "alliance war", 1, true) then score = score + 60 end
    if string.find(text, "dungeon", 1, true) then score = score + 35 end
    if (tonumber(points) or 0) >= 50 then score = score + 100 end

    return score
end

local function CopyChronicleMemory(memory, source)
    if not memory then return nil end
    local copy = {}
    for key, value in pairs(memory) do copy[key] = value end
    copy.source = source or memory.source
    return copy
end

function STARS:InvalidateChronicleCache()
    self._chronicleCache = nil
end

function STARS:GetAchievementRewardSummary(achievementId)
    achievementId = tonumber(achievementId) or 0
    if achievementId <= 0 then return "" end

    local rewards = {}

    local hasTitle, titleName = SafeApiCall(GetAchievementRewardTitle, achievementId)
    if hasTitle == true and titleName and titleName ~= "" then
        rewards[#rewards + 1] = "Title: " .. tostring(titleName)
    end

    local hasDye, dyeId = SafeApiCall(GetAchievementRewardDye, achievementId)
    if hasDye == true and tonumber(dyeId) and tonumber(dyeId) > 0 then
        local dyeName = SafeApiCall(GetDyeInfoById, dyeId)
        rewards[#rewards + 1] = "Dye: " .. tostring((dyeName and dyeName ~= "") and dyeName or "Unlocked")
    end

    local hasCollectible, collectibleId = SafeApiCall(GetAchievementRewardCollectible, achievementId)
    if hasCollectible == true and tonumber(collectibleId) and tonumber(collectibleId) > 0 then
        local collectibleName = SafeApiCall(GetCollectibleInfo, collectibleId)
        rewards[#rewards + 1] = "Collectible: " .. tostring((collectibleName and collectibleName ~= "") and collectibleName or "Unlocked")
    end

    local hasItem, itemName = SafeApiCall(GetAchievementRewardItem, achievementId)
    if hasItem == true and itemName and itemName ~= "" then
        rewards[#rewards + 1] = "Item: " .. tostring(itemName)
    end

    if #rewards == 0 then return "" end
    if #rewards <= 2 then return table.concat(rewards, "\n") end
    return rewards[1] .. "\n" .. rewards[2] .. "\n+" .. tostring(#rewards - 2) .. " more reward"
        .. ((#rewards - 2) == 1 and "" or "s")
end

function STARS:BuildChronicleData()
    local nowTimestamp = Now()
    local currentYear, currentMonth, currentDay = ChronicleDateParts(nowTimestamp)
    local dayKey = ChronicleDateKey(currentYear, currentMonth, currentDay)

    local chronicle = {
        dayKey = dayKey,
        currentYear = currentYear,
        currentMonth = currentMonth,
        currentDay = currentDay,
        monthName = CHRONICLE_MONTHS[currentMonth] or tostring(currentMonth),
        todayCount = 0,
        moreToday = 0,
        memories = {},
        displayMemories = {},
        completed = 0,
        earnedPoints = tonumber(SafeApiCall(GetEarnedAchievementPoints)) or 0,
        earliest = nil,
        busiest = nil,
        firstYear = 0,
        lastYear = 0,
    }

    if type(GetNumAchievementCategories) ~= "function"
        or type(GetAchievementCategoryInfo) ~= "function"
        or type(GetAchievementId) ~= "function"
        or type(GetAchievementInfo) ~= "function" then
        return chronicle
    end

    local todayMatches = {}
    local highlights = {}
    local seen = {}
    local dayStats = {}

    local function rememberAchievement(topLevelIndex, subCategoryIndex, achievementIndex, categoryName, subCategoryName)
        local achievementId = tonumber(SafeApiCall(GetAchievementId, topLevelIndex, subCategoryIndex, achievementIndex)) or 0
        if achievementId <= 0 or seen[achievementId] then return end
        seen[achievementId] = true

        local name, description, points, icon, completed = SafeApiCall(GetAchievementInfo, achievementId)
        if completed ~= true then return end

        chronicle.completed = chronicle.completed + 1
        local timestamp = tonumber(SafeApiCall(GetAchievementTimestamp, achievementId)) or 0
        if timestamp <= 0 then return end

        local year, month, day = ChronicleDateParts(timestamp)
        if year <= 0 or month <= 0 or day <= 0 then return end

        local memory = {
            id = achievementId,
            name = name or ("Achievement " .. tostring(achievementId)),
            description = description or "",
            points = tonumber(points) or 0,
            icon = icon or "",
            timestamp = timestamp,
            year = year,
            month = month,
            day = day,
            category = categoryName or "Achievements",
            subcategory = subCategoryName or "",
        }
        memory.score = ChronicleHighlightScore(memory.name, memory.description, memory.points, memory.category, memory.subcategory)

        if chronicle.firstYear == 0 or year < chronicle.firstYear then chronicle.firstYear = year end
        if chronicle.lastYear == 0 or year > chronicle.lastYear then chronicle.lastYear = year end
        if not chronicle.earliest or timestamp < chronicle.earliest.timestamp then chronicle.earliest = memory end

        local achievementDayKey = ChronicleDateKey(year, month, day)
        local dayRecord = dayStats[achievementDayKey]
        if not dayRecord then
            dayRecord = { year = year, month = month, day = day, count = 0, points = 0 }
            dayStats[achievementDayKey] = dayRecord
        end
        dayRecord.count = dayRecord.count + 1
        dayRecord.points = dayRecord.points + memory.points

        if month == currentMonth and day == currentDay then
            todayMatches[#todayMatches + 1] = memory
        end
        highlights[#highlights + 1] = memory
    end

    local numCategories = tonumber(SafeApiCall(GetNumAchievementCategories)) or 0
    for topLevelIndex = 1, numCategories do
        local categoryName, numSubCategories, numAchievements = SafeApiCall(GetAchievementCategoryInfo, topLevelIndex)
        categoryName = categoryName or "Achievements"
        numSubCategories = tonumber(numSubCategories) or 0
        numAchievements = tonumber(numAchievements) or 0

        for achievementIndex = 1, numAchievements do
            rememberAchievement(topLevelIndex, nil, achievementIndex, categoryName, "")
        end

        for subCategoryIndex = 1, numSubCategories do
            local subCategoryName, subNumAchievements = SafeApiCall(GetAchievementSubCategoryInfo, topLevelIndex, subCategoryIndex)
            subNumAchievements = tonumber(subNumAchievements) or 0
            for achievementIndex = 1, subNumAchievements do
                rememberAchievement(topLevelIndex, subCategoryIndex, achievementIndex, categoryName, subCategoryName or "")
            end
        end
    end

    for _, dayRecord in pairs(dayStats) do
        if not chronicle.busiest
            or dayRecord.count > chronicle.busiest.count
            or (dayRecord.count == chronicle.busiest.count and dayRecord.points > chronicle.busiest.points) then
            chronicle.busiest = dayRecord
        end
    end

    table.sort(todayMatches, function(a, b)
        if a.year ~= b.year then return a.year > b.year end
        if a.score ~= b.score then return a.score > b.score end
        return a.timestamp > b.timestamp
    end)
    table.sort(highlights, function(a, b)
        if a.score ~= b.score then return a.score > b.score end
        if a.points ~= b.points then return a.points > b.points end
        return a.timestamp > b.timestamp
    end)

    chronicle.todayCount = #todayMatches
    chronicle.moreToday = math.max(0, #todayMatches - 1)

    -- Chronicle test2 presents one large album memory at a time. Keep the
    -- complete list for today's date so L1/R1 can turn through every memory.
    -- On quiet dates, build a deterministic rotating archive reel instead.
    if #todayMatches > 0 then
        for index = 1, #todayMatches do
            local memory = CopyChronicleMemory(todayMatches[index], "today")
            memory.rewardSummary = self:GetAchievementRewardSummary(memory.id)
            chronicle.memories[#chronicle.memories + 1] = memory
        end
    elseif #highlights > 0 then
        local poolSize = math.min(#highlights, 16)
        local reelSize = math.min(poolSize, 8)
        local seed = dayKey > 0 and dayKey or 1
        local startIndex = ((seed * 17 + 11) % poolSize) + 1
        local selectedIds = {}
        for offset = 0, poolSize - 1 do
            local index = ((startIndex - 1 + offset) % poolSize) + 1
            local candidate = highlights[index]
            if candidate and not selectedIds[candidate.id] then
                local memory = CopyChronicleMemory(candidate, "archive")
                memory.rewardSummary = self:GetAchievementRewardSummary(memory.id)
                chronicle.memories[#chronicle.memories + 1] = memory
                selectedIds[memory.id] = true
                if #chronicle.memories >= reelSize then break end
            end
        end
    end

    -- Retain the original two-entry field for backwards compatibility with
    -- any code that still reads displayMemories during this test branch.
    for index = 1, math.min(2, #chronicle.memories) do
        chronicle.displayMemories[#chronicle.displayMemories + 1] = chronicle.memories[index]
    end

    Debug(string.format("Chronicle indexed %s completed achievements; %s memories match today",
        tostring(chronicle.completed), tostring(chronicle.todayCount)))
    return chronicle
end

function STARS:GetChronicleData(forceRefresh)
    local currentYear, currentMonth, currentDay = ChronicleDateParts(Now())
    local dayKey = ChronicleDateKey(currentYear, currentMonth, currentDay)
    if forceRefresh ~= true and self._chronicleCache and self._chronicleCache.dayKey == dayKey then
        return self._chronicleCache
    end
    self._chronicleCache = self:BuildChronicleData()
    return self._chronicleCache
end

function STARS:GetVeterancySnapshot()
    local snapshot = {
        active = false,
        seasonId = 0,
        seasonName = "No Active Veterancy Season",
        timeRemainingS = 0,
        rank = 0,
        rankTitle = "Unranked",
        rankIcon = "",
        largeRankIcon = "",
        progress = 0,
        progressTotal = 0,
        progressPercent = 0,
        numRanks = 0,
        numClaimableRewards = 0,
        hasUnclaimedRewards = false,
    }

    local isActive = SafeApiCall(IsVeterancySeasonActive)
    snapshot.active = isActive == true
    if not snapshot.active then
        return snapshot
    end

    snapshot.seasonId = tonumber(SafeApiCall(GetCurrentVeterancySeasonId)) or 0
    snapshot.seasonName = SafeApiCall(GetCurrentVeterancySeasonName) or "Veterancy"
    snapshot.timeRemainingS = tonumber(SafeApiCall(GetCurrentVeterancySeasonTimeRemainingS)) or 0

    local manager = ZO_VETERANCY_MANAGER
    if manager then
        if manager.RefreshRankData then
            pcall(manager.RefreshRankData, manager)
        end

        if manager.GetCurrentRank then
            snapshot.rank = tonumber(SafeApiCall(manager.GetCurrentRank, manager)) or 0
        end
        if manager.GetCurrentTierProgress then
            snapshot.progress = tonumber(SafeApiCall(manager.GetCurrentTierProgress, manager)) or 0
        end
        if manager.GetCurrentTierTotal then
            snapshot.progressTotal = tonumber(SafeApiCall(manager.GetCurrentTierTotal, manager)) or 0
        end
        if manager.GetNumRanks then
            snapshot.numRanks = tonumber(SafeApiCall(manager.GetNumRanks, manager)) or 0
        end
        if manager.HasUnclaimedRankRewards then
            snapshot.hasUnclaimedRewards = SafeApiCall(manager.HasUnclaimedRankRewards, manager) == true
        end
        if manager.GetCurrentRankData then
            local rankData = SafeApiCall(manager.GetCurrentRankData, manager)
            if rankData and rankData.GetNumClaimableRewards then
                snapshot.numClaimableRewards = tonumber(SafeApiCall(rankData.GetNumClaimableRewards, rankData)) or 0
            end
        end
    end

    if snapshot.rank <= 0 and GetUnitVeterancyRank then
        snapshot.rank = tonumber(SafeApiCall(GetUnitVeterancyRank, "player")) or 0
    end

    if snapshot.rank > 0 then
        snapshot.rankTitle = SafeApiCall(GetVeterancyRankTitle, snapshot.rank, snapshot.seasonId)
            or SafeApiCall(GetVeterancyRankTitle, snapshot.rank)
            or ("Rank " .. tostring(snapshot.rank))
        snapshot.rankIcon = SafeApiCall(GetVeterancyRankIcon, snapshot.rank, snapshot.seasonId)
            or SafeApiCall(GetVeterancyRankIcon, snapshot.rank)
            or ""
        snapshot.largeRankIcon = SafeApiCall(GetVeterancyLargeRankIcon, snapshot.rank, snapshot.seasonId)
            or SafeApiCall(GetVeterancyLargeRankIcon, snapshot.rank)
            or snapshot.rankIcon
    end

    if snapshot.progressTotal > 0 then
        snapshot.progressPercent = math.max(0, math.min(100, (snapshot.progress / snapshot.progressTotal) * 100))
    end

    return snapshot
end

function STARS:NewVeterancySeasonRecord(snapshot)
    return {
        seasonId = tonumber(snapshot.seasonId) or 0,
        name = snapshot.seasonName or "Veterancy",
        started = Now(),
        ended = 0,
        highestRank = tonumber(snapshot.rank) or 0,
        rankTitle = snapshot.rankTitle or "Unranked",
        rankIcon = snapshot.rankIcon or "",
        largeRankIcon = snapshot.largeRankIcon or "",
    }
end

function STARS:PruneVeterancyHistory()
    if not self.sv or not self.sv.stats or not self.sv.stats.veterancy then return end
    local history = self.sv.stats.veterancy.history
    local keepHistory = math.max(0, (tonumber(self.sv.options.veterancyRetention) or 4) - 1)
    while #history > keepHistory do
        table.remove(history)
    end
end

function STARS:EnsureVeterancySeason()
    if not self.sv or not self.sv.stats or not self.sv.stats.veterancy then
        return nil, self:GetVeterancySnapshot()
    end

    local snapshot = self:GetVeterancySnapshot()
    local veterancy = self.sv.stats.veterancy

    if not snapshot.active or snapshot.seasonId == 0 then
        return veterancy.current, snapshot
    end

    if not veterancy.current then
        veterancy.current = self:NewVeterancySeasonRecord(snapshot)
        self:TouchSV()
    elseif tonumber(veterancy.current.seasonId) ~= tonumber(snapshot.seasonId) then
        veterancy.current.ended = Now()
        table.insert(veterancy.history, 1, veterancy.current)
        veterancy.current = self:NewVeterancySeasonRecord(snapshot)
        self:PruneVeterancyHistory()
        self:TouchSV()
        Debug("Veterancy season rollover -> " .. tostring(veterancy.current.name))
    end

    local current = veterancy.current
    local rank = tonumber(snapshot.rank) or 0
    if rank >= (tonumber(current.highestRank) or 0) then
        local changed = rank > (tonumber(current.highestRank) or 0)
            or current.rankTitle ~= snapshot.rankTitle
            or current.rankIcon ~= snapshot.rankIcon
        current.highestRank = rank
        current.rankTitle = snapshot.rankTitle or current.rankTitle
        current.rankIcon = snapshot.rankIcon or current.rankIcon
        current.largeRankIcon = snapshot.largeRankIcon or current.largeRankIcon
        if changed then self:TouchSV() end
    end

    return current, snapshot
end

function STARS:OnVeterancyUpdated()
    if not self:IsEnabled() then return end
    self:EnsureVeterancySeason()
    if STARS_JOURNAL_GAMEPAD and STARS_JOURNAL_GAMEPAD.ShowPage and STARS_JOURNAL_GAMEPAD.currentPage then
        STARS_JOURNAL_GAMEPAD:ShowPage(STARS_JOURNAL_GAMEPAD.currentPage)
    end
end

function STARS:OnRewardTrackProgressGained(_, trackType)
    if trackType == REWARD_TRACK_TYPE_AVA_VETERANCY then
        self:OnVeterancyUpdated()
    end
end

function STARS:IsInCyrodiil()
    return IsInCyrodiil and IsInCyrodiil() == true
end

function STARS:GetHomeCampaignId()
    if not GetAssignedCampaignId then return 0 end
    local id = GetAssignedCampaignId()
    return tonumber(id) or 0
end

function STARS:GetCampaignNameSafe(campaignId)
    if campaignId == 0 then return "No Home Campaign" end
    if GetCampaignName then
        local ok, name = pcall(GetCampaignName, campaignId)
        if ok and type(name) == "string" and name ~= "" then return name end
    end
    return "Campaign " .. tostring(campaignId)
end

function STARS:NewCampaignRecord(campaignId)
    return {
        campaignId = campaignId,
        name = self:GetCampaignNameSafe(campaignId),
        started = Now(),
        ended = 0,
        alliance = GetUnitAlliance and GetUnitAlliance("player") or 0,
        kills = 0,
        assists = 0,
        deaths = 0,
        revives = 0,
        keepsTaken = 0,
        keepsDefended = 0,
        apEarned = 0,
    }
end

function STARS:PruneCampaignHistory()
    local c = self.sv.stats.campaigns
    local keepHistory = math.max(0, (tonumber(self.sv.options.campaignRetention) or 3) - 1)
    while #c.history > keepHistory do table.remove(c.history) end
end

function STARS:EnsureCampaign()
    if not self.sv or not self.sv.stats or not self.sv.stats.campaigns then return nil end
    local id = self:GetHomeCampaignId()
    if id == 0 then return self.sv.stats.campaigns.current end
    local c = self.sv.stats.campaigns
    if not c.current then
        c.current = self:NewCampaignRecord(id)
        self:TouchSV()
    elseif c.current.campaignId ~= id then
        c.current.ended = Now()
        table.insert(c.history, 1, c.current)
        c.current = self:NewCampaignRecord(id)
        self:PruneCampaignHistory()
        self:TouchSV()
        Debug("Campaign rollover -> " .. c.current.name)
    end
    return c.current
end

function STARS:IncrementCampaign(key, amount)
    local c = self:EnsureCampaign()
    if not c then return end
    c[key] = (tonumber(c[key]) or 0) + (tonumber(amount) or 1)
    self:TouchSV()
end

function STARS:IncrementPvp(key, amount)
    local pvp = self.sv.stats.pvp
    pvp[key] = (tonumber(pvp[key]) or 0) + (tonumber(amount) or 1)
    if self:IsInCyrodiil() then self:IncrementCampaign(key, amount) else self:TouchSV() end
end

function STARS:IncrementPvpLifetime(key, amount)
    local pvp = self.sv and self.sv.stats and self.sv.stats.pvp
    if not pvp then return end
    pvp[key] = (tonumber(pvp[key]) or 0) + (tonumber(amount) or 1)
    self:TouchSV()
end

function STARS:GetUnderworldStats()
    return self.sv and self.sv.stats and self.sv.stats.underworld or nil
end

function STARS:RecordPickpocketSuccess(source)
    if not self:IsEnabled() then return end
    local underworld = self:GetUnderworldStats()
    if not underworld then return end

    -- A successful gold pickpocket can produce a justice event while item loot
    -- produces EVENT_LOOT_RECEIVED. Treat events inside the same half-second as
    -- one pickpocket action so a single theft cannot be counted twice.
    local nowMs = FrameMs()
    if self.lastPickpocketSuccessMs and (nowMs - self.lastPickpocketSuccessMs) < 500 then
        Debug("Duplicate pickpocket event ignored: " .. tostring(source or "unknown"))
        return
    end

    self.lastPickpocketSuccessMs = nowMs
    underworld.pickpockets = (tonumber(underworld.pickpockets) or 0) + 1
    self:TouchSV()
    Debug("Pickpocket recorded (" .. tostring(source or "loot") .. "): " .. tostring(underworld.pickpockets))
end

function STARS:OnLootReceived(_, _, _, _, _, _, isSelf, isPickpocketLoot)
    if isSelf and isPickpocketLoot then
        self:RecordPickpocketSuccess("loot")
    end
end

function STARS:OnJusticeGoldPickpocketed()
    self:RecordPickpocketSuccess("gold")
end

function STARS:IsBladeOfWoeAbility(abilityId, abilityName)
    local underworld = self:GetUnderworldStats()
    local numericId = tonumber(abilityId) or 0
    if underworld and numericId > 0 and underworld.bladeOfWoeAbilityIds
        and underworld.bladeOfWoeAbilityIds[numericId] == true then
        return true
    end

    -- First-run discovery for English clients. Once seen, persist the numeric
    -- ability ID so future detections do not depend on the localized name.
    local name = tostring(abilityName or "")
    local lowerName = string.lower(name)
    if string.find(lowerName, "blade of woe", 1, true) then
        if underworld and numericId > 0 then
            underworld.bladeOfWoeAbilityIds = underworld.bladeOfWoeAbilityIds or {}
            underworld.bladeOfWoeAbilityIds[numericId] = true
            self:TouchSV()
            Debug("Learned Blade of Woe ability ID: " .. tostring(numericId))
        end
        return true
    end
    return false
end

function STARS:RecordBladeOfWoeKill(abilityId, abilityName)
    if not self:IsEnabled() then return end
    local underworld = self:GetUnderworldStats()
    if not underworld then return end

    -- Combat events may report more than one terminal result for the same kill.
    local nowMs = FrameMs()
    if self.lastBladeOfWoeKillMs and (nowMs - self.lastBladeOfWoeKillMs) < 1500 then
        return
    end
    self.lastBladeOfWoeKillMs = nowMs

    underworld.bladeOfWoeKills = (tonumber(underworld.bladeOfWoeKills) or 0) + 1
    self:TouchSV()
    Debug(string.format("Blade of Woe kill recorded: %s (ability=%s, id=%s)",
        tostring(underworld.bladeOfWoeKills), tostring(abilityName or ""), tostring(abilityId or 0)))
end

function STARS:OnGameCameraEvent(kind)
    local nowMs = FrameMs()
    self.lastGameCameraEventMs = nowMs
    self.lastGameCameraEventKind = kind
    Debug("Game camera " .. tostring(kind))

    -- If the assassination camera transition happens after the killing-blow
    -- event, associate it with the pending candidate as well. This is debug
    -- instrumentation only; it never increments the counter by itself.
    local candidate = self.pendingAssassinationCandidate
    if candidate and (nowMs - (candidate.timeMs or 0)) <= 3000 then
        local xpDelta = self.lastExperienceGainMs and (nowMs - self.lastExperienceGainMs) or -1
        Debug(string.format(
            "Assassination camera candidate: ability=%s id=%s target=%s camera=%s after=%sms xp=%sms ago",
            tostring(candidate.abilityName or ""), tostring(candidate.abilityId or 0),
            tostring(candidate.targetName or ""), tostring(kind),
            tostring(nowMs - (candidate.timeMs or nowMs)), tostring(xpDelta)))
    end
end

function STARS:OnExperienceGain(reason, level, previousExperience, currentExperience, championPoints)
    self.lastExperienceGainMs = FrameMs()

    local cap = self:GetChampionProgressionCap()
    if self:GetPlayerCP() < cap then
        self:UpdatePrestige()
        return
    end

    local previousXP = tonumber(previousExperience) or 0
    local currentXP = tonumber(currentExperience) or 0
    local delta = math.max(0, currentXP - previousXP)
    local nowMs = FrameMs()
    local pending = self.pendingPrestigeXP

    if pending and pending.reason == reason and (nowMs - pending.timeMs) <= 1000 then
        self.pendingPrestigeXP = nil
        self.lastPrestigeExperienceAward = { reason = reason, amount = pending.amount, timeMs = nowMs }
        self:AccumulatePostCapXP(pending.amount)
    elseif delta > 0 then
        self.lastPrestigeExperienceAward = { reason = reason, amount = delta, timeMs = nowMs }
        self:AccumulatePostCapXP(delta)
    end
end

function STARS:DebugAssassinationCandidate(abilityId, abilityName, targetName)
    if not (self.sv and self.sv.options and self.sv.options.debug) then return end
    local nowMs = FrameMs()
    self.pendingAssassinationCandidate = {
        timeMs = nowMs,
        abilityId = tonumber(abilityId) or 0,
        abilityName = abilityName or "",
        targetName = targetName or "",
    }

    local cameraDelta = self.lastGameCameraEventMs and (nowMs - self.lastGameCameraEventMs) or -1
    local xpDelta = self.lastExperienceGainMs and (nowMs - self.lastExperienceGainMs) or -1

    -- The camera transition can occur before or after the combat event. A
    -- recent prior transition is logged here; a later transition is picked up
    -- by OnGameCameraEvent above. The no-XP timing helps verify the console
    -- fingerprint without turning the heuristic into a potentially false count.
    if cameraDelta >= 0 and cameraDelta <= 3000 then
        Debug(string.format(
            "Assassination candidate: ability=%s id=%s target=%s camera=%s %sms ago xp=%sms ago",
            tostring(abilityName or ""), tostring(abilityId or 0), tostring(targetName or ""),
            tostring(self.lastGameCameraEventKind or "unknown"), tostring(cameraDelta), tostring(xpDelta)))
    end
end

function STARS:CaptureBattlegroundMatchStats()
    if self.bgMatchRecorded or not self:IsEnabled() then return end
    if not GetNumScoreboardEntries or not GetScoreboardEntryInfo then return end

    local numEntries = tonumber(GetNumScoreboardEntries()) or 0
    if numEntries <= 0 then return end

    local scoreGetter = GetBattlegroundCumulativeScoreForScoreboardEntryByType or GetScoreboardEntryScoreByType
    if not scoreGetter then return end

    for entryIndex = 1, numEntries do
        local _, _, _, isLocalPlayer = GetScoreboardEntryInfo(entryIndex)
        if isLocalPlayer then
            local function score(scoreType)
                local ok, value = pcall(scoreGetter, entryIndex, scoreType)
                if ok and type(value) == "number" then return value end
                return 0
            end

            local bg = self.sv.stats.pvp.battlegrounds
            bg.kills = (tonumber(bg.kills) or 0) + score(SCORE_TRACKER_TYPE_KILL)
            bg.deaths = (tonumber(bg.deaths) or 0) + score(SCORE_TRACKER_TYPE_DEATH)
            bg.assists = (tonumber(bg.assists) or 0) + score(SCORE_TRACKER_TYPE_ASSISTS)
            bg.matches = (tonumber(bg.matches) or 0) + 1
            self.bgMatchRecorded = true
            self:TouchSV()
            Debug(string.format("Battleground recorded: K=%s D=%s A=%s", tostring(bg.kills), tostring(bg.deaths), tostring(bg.assists)))
            return
        end
    end
end

function STARS:OnBattlegroundStateChanged(_, previousState, currentState)
    if currentState == BATTLEGROUND_STATE_STARTING or currentState == BATTLEGROUND_STATE_RUNNING then
        self.bgMatchRecorded = false
    elseif currentState == BATTLEGROUND_STATE_FINISHED then
        if zo_callLater then
            zo_callLater(function() self:CaptureBattlegroundMatchStats() end, 500)
        else
            self:CaptureBattlegroundMatchStats()
        end
    end
end

function STARS:OnCombatEvent(_, result, _, abilityName, _, _, sourceName, sourceType, targetName, targetType, _, _, _, _, _, _, abilityId)
    if not self:IsEnabled() then return end

    local playerSource = IsPlayerSource(sourceType)
    local playerTarget = IsPlayerTarget(targetType)
    local sourceIsLocalPlayer = playerSource
    if not sourceIsLocalPlayer and GetUnitName then
        sourceIsLocalPlayer = sourceName == GetUnitName("player")
    end
    local terminalKill = result == ACTION_RESULT_KILLING_BLOW
        or result == ACTION_RESULT_DIED
        or result == ACTION_RESULT_DIED_XP

    -- Underworld tracking is zone-independent. Blade of Woe is detected first
    -- by its exposed ability name/learned ID; Debug Mode also records the
    -- camera/XP fingerprint of other player killing blows for console testing.
    if sourceIsLocalPlayer and not playerTarget and terminalKill then
        if self:IsBladeOfWoeAbility(abilityId, abilityName) then
            self:RecordBladeOfWoeKill(abilityId, abilityName)
        elseif result == ACTION_RESULT_KILLING_BLOW then
            self:DebugAssassinationCandidate(abilityId, abilityName, targetName)
        end
    end

    if not self:IsInCyrodiil() then return end
    if result == ACTION_RESULT_KILLING_BLOW and playerSource and playerTarget then
        self:IncrementPvp("kills", 1)
    elseif (result == ACTION_RESULT_DIED or result == ACTION_RESULT_DIED_XP) and playerTarget and not playerSource then
        self:IncrementPvp("deaths", 1)
    end
end

function STARS:OnResurrectResult(_, _, reason)
    if not self:IsEnabled() or not self:IsInCyrodiil() then return end
    if reason == RESURRECT_RESULT_SUCCESS then self:IncrementPvp("revives", 1) end
end

function STARS:OnCurrencyUpdate(_, currencyType, currencyLocation, newAmount, oldAmount, reason)
    if not self:IsEnabled() or currencyType ~= CURT_ALLIANCE_POINTS then return end
    if not self:IsInCyrodiil() then return end
    if reason == CURRENCY_CHANGE_REASON_PLAYER_INIT then return end
    if type(newAmount) ~= "number" or type(oldAmount) ~= "number" then return end
    local delta = newAmount - oldAmount
    if delta <= 0 then return end
    self:IncrementPvpLifetime("apEarned", delta)
    self:IncrementCampaign("apEarned", delta)
    self.lastApGainTime = Now()
    self:ConfirmPendingKeepContribution()
end

function STARS:QueueKeepContribution(kind, keepId)
    if not self:IsInCyrodiil() then return end
    self.pendingKeepContribution = { kind = kind, keepId = keepId, time = Now() }
    -- AP can sometimes arrive just before the keep state event.
    if self.lastApGainTime and (Now() - self.lastApGainTime) <= 20 then
        self:ConfirmPendingKeepContribution()
    end
end

function STARS:ConfirmPendingKeepContribution()
    local p = self.pendingKeepContribution
    if not p then return end
    if (Now() - (p.time or 0)) > 30 then self.pendingKeepContribution = nil return end
    if p.kind == "capture" then
        self:IncrementPvpLifetime("keepsTaken", 1)
        self:IncrementCampaign("keepsTaken", 1)
        Debug("Keep capture credited: " .. tostring(p.keepId))
    elseif p.kind == "defence" then
        self:IncrementPvpLifetime("keepsDefended", 1)
        self:IncrementCampaign("keepsDefended", 1)
        Debug("Keep defence credited: " .. tostring(p.keepId))
    end
    self.pendingKeepContribution = nil
end

function STARS:OnKeepAllianceOwnerChanged(_, keepId, battlegroundContext, owningAlliance, oldOwningAlliance)
    if not self:IsEnabled() or not self:IsInCyrodiil() then return end
    local myAlliance = GetUnitAlliance and GetUnitAlliance("player") or 0
    if owningAlliance == myAlliance and oldOwningAlliance ~= myAlliance then
        self:QueueKeepContribution("capture", keepId)
    end
    self.keepUnderAttack = self.keepUnderAttack or {}
    self.keepUnderAttack[keepId] = nil
end

function STARS:OnKeepUnderAttackChanged(_, keepId, battlegroundContext, underAttack)
    if not self:IsEnabled() or not self:IsInCyrodiil() then return end
    self.keepUnderAttack = self.keepUnderAttack or {}
    if underAttack then
        self.keepUnderAttack[keepId] = { started = Now() }
        return
    end
    local tracked = self.keepUnderAttack[keepId]
    self.keepUnderAttack[keepId] = nil
    if not tracked then return end
    if GetKeepAlliance then
        local ok, owner = pcall(GetKeepAlliance, keepId, battlegroundContext)
        local myAlliance = GetUnitAlliance and GetUnitAlliance("player") or 0
        if ok and owner == myAlliance then self:QueueKeepContribution("defence", keepId) end
    end
end

function STARS:GetPrestigeTier()
    local progression = self:GetPrestigeProgression()
    if progression.phase == "legacy" then
        return progression.rankName, "EsoUI/Art/Progression/Gamepad/gp_levelup_icon.dds"
    end

    local tier = progression.tierName or "Bronze"
    if tier == "Gold" then
        return tier, "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_currency_gold.dds"
    elseif tier == "Silver" then
        return tier, "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_currency_gold.dds"
    end
    return tier, "EsoUI/Art/TreeIcons/Gamepad/gp_tutorial_idexIcon_combat.dds"
end

function STARS:GetCharacterProfile()
    local name = GetUnitName and GetUnitName("player") or "Character"
    local race = GetUnitRace and GetUnitRace("player") or ""
    local className = ""
    if GetUnitClass then className = GetUnitClass("player") or "" end
    local alliance = GetUnitAlliance and GetUnitAlliance("player") or 0
    local allianceName = GetAllianceName and GetAllianceName(alliance) or tostring(alliance)
    local health, magicka, stamina = 0,0,0
    if GetUnitPower then
        local _, mh = GetUnitPower("player", POWERTYPE_HEALTH); health = mh or 0
        local _, mm = GetUnitPower("player", POWERTYPE_MAGICKA); magicka = mm or 0
        local _, ms = GetUnitPower("player", POWERTYPE_STAMINA); stamina = ms or 0
    end
    local function stat(statType)
        if GetPlayerStat then
            local ok, v = pcall(GetPlayerStat, statType)
            if ok and type(v) == "number" then return v end
        end
        return 0
    end
    return {
        name = name, race = race, className = className, allianceName = allianceName,
        cp = self:GetPlayerCP(), prestige = tonumber(self.sv.prestige.level) or 0,
        health = health, magicka = magicka, stamina = stamina,
        weaponDamage = stat(STAT_WEAPON_AND_SPELL_DAMAGE), spellDamage = stat(STAT_WEAPON_AND_SPELL_DAMAGE),
        physicalResist = stat(STAT_PHYSICAL_RESIST), spellResist = stat(STAT_SPELL_RESIST),
        critResist = stat(STAT_CRITICAL_RESISTANCE),
    }
end

function STARS:ResetAllStats()
    self.sv.stats = {
        pvp = {
            kills=0,deaths=0,revives=0,keepsTaken=0,keepsDefended=0,apEarned=0,
            battlegrounds={kills=0,deaths=0,assists=0,matches=0},
        },
        underworld = {pickpockets=0,bladeOfWoeKills=0,trackingStarted=Now(),bladeOfWoeAbilityIds={}},
        campaigns = {current=nil,history={}},
        veterancy = {current=nil,history={}},
    }
    self.sv.prestige.level = 0
    self.sv.prestige.session = 0
    self:EnsureCampaign()
    self:EnsureVeterancySeason()
    self:TouchSV()
    if STARS_JOURNAL_GAMEPAD and STARS_JOURNAL_GAMEPAD.ShowPage then STARS_JOURNAL_GAMEPAD:ShowPage(STARS_JOURNAL_GAMEPAD.currentPage or 1) end
end

function STARS:UpgradeSavedVars()
    self.sv.options = self.sv.options or {}
    for k,v in pairs(DEFAULTS.options) do
        if self.sv.options[k] == nil then self.sv.options[k] = v end
    end

    self.sv.prestige = self.sv.prestige or ZO_ShallowTableCopy(DEFAULTS.prestige)
    local prestige = self.sv.prestige
    if prestige.baselineCP == nil then prestige.baselineCP = DEFAULTS.prestige.baselineCP end
    if prestige.level == nil then prestige.level = DEFAULTS.prestige.level end
    if prestige.session == nil then prestige.session = DEFAULTS.prestige.session end
    if prestige.lastCP == nil then prestige.lastCP = DEFAULTS.prestige.lastCP end
    -- New cap-era fields are intentionally additive. Existing STARS data is not
    -- renamed or rebuilt; these are only used by the new unlimited progression.
    if prestige.postCapRanks == nil and self:GetPlayerCP() >= self:GetChampionProgressionCap() then
        prestige.postCapRanks = math.max(0, math.floor(tonumber(prestige.level) or 0))
    end
    if prestige.postCapXP == nil and self:GetPlayerCP() >= self:GetChampionProgressionCap() then prestige.postCapXP = 0 end
    if prestige.xpPerRank == nil and self:GetPlayerCP() >= self:GetChampionProgressionCap() then
        prestige.xpPerRank = self:GetFinalChampionPointXP()
    end

    self.sv.stats = self.sv.stats or {}

    -- Saved statistics are historical data. During normal addon upgrades,
    -- never coerce an existing value to zero. Only supply fields that are
    -- genuinely absent. Runtime readers already use tonumber(...) or 0, so
    -- preserving an older representation is safer than destructive cleanup.
    self.sv.stats.pvp = self.sv.stats.pvp or {}
    local pvp = self.sv.stats.pvp
    if pvp.kills == nil then pvp.kills = 0 end
    if pvp.deaths == nil then pvp.deaths = 0 end
    if pvp.revives == nil then pvp.revives = 0 end
    if pvp.keepsTaken == nil then pvp.keepsTaken = 0 end
    if pvp.keepsDefended == nil then pvp.keepsDefended = 0 end
    if pvp.apEarned == nil then pvp.apEarned = 0 end

    pvp.battlegrounds = pvp.battlegrounds or {}
    local bg = pvp.battlegrounds
    if bg.kills == nil then bg.kills = 0 end
    if bg.deaths == nil then bg.deaths = 0 end
    if bg.assists == nil then bg.assists = 0 end
    if bg.matches == nil then bg.matches = 0 end

    self.sv.stats.underworld = self.sv.stats.underworld or {}
    local underworld = self.sv.stats.underworld
    if underworld.pickpockets == nil then underworld.pickpockets = 0 end
    if underworld.bladeOfWoeKills == nil then underworld.bladeOfWoeKills = 0 end
    if underworld.trackingStarted == nil or underworld.trackingStarted == 0 then
        underworld.trackingStarted = Now()
    end
    if underworld.bladeOfWoeAbilityIds == nil then underworld.bladeOfWoeAbilityIds = {} end

    self.sv.stats.campaigns = self.sv.stats.campaigns or {current=nil,history={}}
    if self.sv.stats.campaigns.history == nil then self.sv.stats.campaigns.history = {} end

    self.sv.stats.veterancy = self.sv.stats.veterancy or {current=nil,history={}}
    if self.sv.stats.veterancy.history == nil then self.sv.stats.veterancy.history = {} end

    -- These fields were already retired before this separation and the
    -- known-good STARS build intentionally removes them.
    self.sv.stats.economy = nil
    pvp.healing = nil
    pvp.weekly = nil
    pvp.weeklyReset = nil

    self:PruneCampaignHistory()
    self:PruneVeterancyHistory()
end

function STARS:RegisterResetDialogs()
    if not ZO_Dialogs_RegisterCustomDialog then return end

    ZO_Dialogs_RegisterCustomDialog("STARS_RESET_DATA", {
        gamepadInfo = { dialogType = GAMEPAD_DIALOGS and GAMEPAD_DIALOGS.BASIC },
        title = { text = "Reset STARS Data" },
        mainText = { text = "Choose what STARS should reset.\n\nX - Prestige Only\nSquare - Clear All Data\nO - Back" },
        buttons = {
            {
                text = "Prestige Only",
                keybind = "DIALOG_PRIMARY",
                callback = function() STARS:ResetPrestigeBaseline() end,
            },
            {
                text = "Clear All Data",
                keybind = "DIALOG_SECONDARY",
                callback = function()
                    if ZO_Dialogs_ShowGamepadDialog then
                        ZO_Dialogs_ShowGamepadDialog("STARS_RESET_ALL_CONFIRM")
                    elseif ZO_Dialogs_ShowDialog then
                        ZO_Dialogs_ShowDialog("STARS_RESET_ALL_CONFIRM")
                    end
                end,
            },
            { text = "Back", keybind = "DIALOG_NEGATIVE" },
        },
    })

    ZO_Dialogs_RegisterCustomDialog("STARS_RESET_ALL_CONFIRM", {
        gamepadInfo = { dialogType = GAMEPAD_DIALOGS and GAMEPAD_DIALOGS.BASIC },
        title = { text = "Clear All STARS Data?" },
        mainText = { text = "This permanently clears tracked STARS statistics and history.\n\nX - Clear Everything\nO - Back" },
        buttons = {
            {
                text = "Clear Everything",
                keybind = "DIALOG_PRIMARY",
                callback = function() STARS:ResetAllStats() end,
            },
            { text = "Back", keybind = "DIALOG_NEGATIVE" },
        },
    })
end

function STARS:ShowResetDialog()
    if ZO_Dialogs_ShowGamepadDialog then
        ZO_Dialogs_ShowGamepadDialog("STARS_RESET_DATA")
    elseif ZO_Dialogs_ShowDialog then
        ZO_Dialogs_ShowDialog("STARS_RESET_DATA")
    end
end



function STARS:InitSettingsMenu()
    if not LibHarvensAddonSettings then return end
    local HAS = LibHarvensAddonSettings
    local settings = HAS:AddAddon("STARS", {allowDefaults=true, allowRefresh=true})
    if not settings then return end
    self.settingsPanel = settings

    -- Match the shared Tea & Toast LHAS layout used by Rags To Riches:
    -- coloured top-level category dividers, followed by normal option groups.
    local function AddCategoryHeader(label)
        settings:AddSetting({
            type = HAS.ST_SECTION,
            subMenu = false,
            label = "|cFFD700-- " .. label .. " --|r",
        })
    end

    AddCategoryHeader("GENERAL")
    settings:AddSetting({type=HAS.ST_SECTION,label="STARS"})
    settings:AddSetting({type=HAS.ST_CHECKBOX,label="Enable STARS",getFunction=function() return self.sv.options.enabled end,setFunction=function(v) self.sv.options.enabled=v; self:TouchSV() end})
    settings:AddSetting({type=HAS.ST_CHECKBOX,label="Debug Mode",getFunction=function() return self.sv.options.debug end,setFunction=function(v) self.sv.options.debug=v; self:TouchSV() end})

    AddCategoryHeader("PRESTIGE")
    settings:AddSetting({type=HAS.ST_SECTION,label="Display"})
    settings:AddSetting({
        type=HAS.ST_CHECKBOX,
        label="Show Heraldry Badges",
        tooltip="Shows the new heraldry artwork on the Prestige page. If a badge is unfinished or cannot be rendered, STARS automatically keeps the existing icon and text view.",
        getFunction=function() return self.sv.options.heraldryEnabled == true end,
        setFunction=function(v)
            self.sv.options.heraldryEnabled = v == true
            self:TouchSV()
            if STARS_JOURNAL_GAMEPAD and STARS_JOURNAL_GAMEPAD.ShowPage and STARS_JOURNAL_GAMEPAD.currentPage then
                STARS_JOURNAL_GAMEPAD:ShowPage(STARS_JOURNAL_GAMEPAD.currentPage)
            end
        end,
    })
    settings:AddSetting({type=HAS.ST_SECTION,label="Notifications"})
    settings:AddSetting({type=HAS.ST_CHECKBOX,label="Prestige Sound",getFunction=function() return self.sv.options.sound end,setFunction=function(v) self.sv.options.sound=v; self:TouchSV() end})
    settings:AddSetting({type=HAS.ST_CHECKBOX,label="Prestige Center Screen Announce",getFunction=function() return self.sv.options.csa end,setFunction=function(v) self.sv.options.csa=v; self:TouchSV() end})

    AddCategoryHeader("HISTORY")
    settings:AddSetting({type=HAS.ST_SECTION,label="Veterancy"})
    local retentionItems={
        {name="Current season only",data=1},
        {name="Current + previous",data=2},
        {name="Current + previous 2",data=3},
        {name="Current + previous 3",data=4},
    }
    settings:AddSetting({type=HAS.ST_DROPDOWN,label="Veterancy History Retention",items=retentionItems,getFunction=function()
        local r=self.sv.options.veterancyRetention or 4
        return retentionItems[r] and retentionItems[r].name or retentionItems[4].name
    end,setFunction=function(_,_,item) if item and item.data then self.sv.options.veterancyRetention=item.data; self:PruneVeterancyHistory(); self:TouchSV() end end})


    AddCategoryHeader("DATA MANAGEMENT")
    settings:AddSetting({type=HAS.ST_SECTION,label="Reset STARS"})
    settings:AddSetting({
        type=HAS.ST_LABEL,
        label="Reset controls",
        tooltip="X resets Prestige only. Square selects Clear All Data and requires a second confirmation. O always goes Back without resetting anything.",
    })
    settings:AddSetting({
        type=HAS.ST_BUTTON,
        label="Reset STARS Data",
        buttonText="Choose Reset",
        clickHandler=function() self:ShowResetDialog() end,
    })

    settings:AddSetting({
        type = HAS.ST_SECTION,
        subMenu = false,
        label = "|cFFD700Built on tea, toast and ADHD – tested live on PS5.|r\n" ..
                "|cB427D3Su|c546D6Aga|c889764Co|cDA34CDma|r",
    })
    settings:AddSetting({
        type = HAS.ST_LABEL,
        label = "Contact",
        tooltip = "Found an error or need to contact me about STARS?\n\nPlayStation User / PSN: SugaComa\nEmail: eso.addons@rik-sprint.co.uk",
    })
end

function STARS:RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_EXPERIENCE_GAIN, function(_, reason, level, previousExperience, currentExperience, championPoints) self:OnExperienceGain(reason, level, previousExperience, currentExperience, championPoints) end)
    if EVENT_PENDING_EXPERIENCE_REWARD_CACHED then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PENDING_EXPERIENCE_REWARD_CACHED, function(_, reason, amount) self:OnPendingExperienceReward(reason, amount) end)
    end
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, function(...) self:OnCombatEvent(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_LOOT_RECEIVED, function(...) self:OnLootReceived(...) end)
    if EVENT_ACHIEVEMENT_AWARDED then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACHIEVEMENT_AWARDED, function()
            self:InvalidateChronicleCache()
        end)
    end
    if EVENT_JUSTICE_GOLD_PICKPOCKETED then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_JUSTICE_GOLD_PICKPOCKETED, function(...) self:OnJusticeGoldPickpocketed(...) end)
    end
    if EVENT_GAME_CAMERA_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GAME_CAMERA_ACTIVATED, function() self:OnGameCameraEvent("activated") end)
    end
    if EVENT_GAME_CAMERA_DEACTIVATED then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GAME_CAMERA_DEACTIVATED, function() self:OnGameCameraEvent("deactivated") end)
    end
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RESURRECT_RESULT, function(...) self:OnResurrectResult(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CURRENCY_UPDATE, function(...) self:OnCurrencyUpdate(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_KEEP_ALLIANCE_OWNER_CHANGED, function(...) self:OnKeepAllianceOwnerChanged(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_KEEP_UNDER_ATTACK_CHANGED, function(...) self:OnKeepUnderAttackChanged(...) end)
    if EVENT_REWARD_TRACK_PROGRESS_GAINED then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_REWARD_TRACK_PROGRESS_GAINED, function(...) self:OnRewardTrackProgressGained(...) end)
    end
    if EVENT_REWARD_TRACK_UPDATE_RECEIVED then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_REWARD_TRACK_UPDATE_RECEIVED, function() self:OnVeterancyUpdated() end)
    end
    if EVENT_REWARD_TRACK_SETTINGS_UPDATE_RECEIVED then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_REWARD_TRACK_SETTINGS_UPDATE_RECEIVED, function() self:OnVeterancyUpdated() end)
    end
    if EVENT_HOLIDAYS_CHANGED then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_HOLIDAYS_CHANGED, function() self:OnVeterancyUpdated() end)
    end
    if EVENT_BATTLEGROUND_STATE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_BATTLEGROUND_STATE_CHANGED, function(...) self:OnBattlegroundStateChanged(...) end)
    end
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function()
        self:EnsureCampaign()
        self:EnsureVeterancySeason()
    end)
end

function STARS:Initialize()
    self.sv = ZO_SavedVars:NewAccountWide("STARS_SV", 1, GetWorldName(), DEFAULTS)
    self:UpgradeSavedVars()
    self:EnsurePrestigeState()
    self:EnsureCampaign()
    self:EnsureVeterancySeason()
    if STARS_JOURNAL and STARS_JOURNAL.Initialize then STARS_JOURNAL:Initialize() end
    self:RegisterResetDialogs()
    self:InitSettingsMenu()
    self:RegisterEvents()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= STARS.name then return end
    STARS:Initialize()
    EVENT_MANAGER:UnregisterForEvent(STARS.name, EVENT_ADD_ON_LOADED)
end
EVENT_MANAGER:RegisterForEvent(STARS.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
