-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.Activities = EPC.Activities or {}
local A = EPC.Activities

A.PAGE_SIZE = 10
A.validGoals = { XP = true, GOLD = true, BALANCED = true }
A.goalLabels = { XP = "XP", GOLD = "GOLD", BALANCED = "BALANCED" }

local function nowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        return tonumber(GetFrameTimeMilliseconds()) or 0
    end
    return 0
end

local function persistentStamp()
    if type(GetTimeStamp) == "function" then
        local ok, stamp = pcall(GetTimeStamp)
        if ok and tonumber(stamp) then return tonumber(stamp) end
    end
    return math.floor(nowMs() / 1000)
end

local function clean(value, fallback)
    if value == nil then return fallback or "" end
    local text = tostring(value)
    if text == "" then return fallback or "" end
    return text
end

local function safeNumber(value, fallback)
    value = tonumber(value)
    if value == nil then return fallback or 0 end
    return value
end

local function formatNumber(value)
    local number = math.floor(safeNumber(value, 0) + 0.5)
    local sign = number < 0 and "-" or ""
    local digits = tostring(math.abs(number))
    local parts = {}
    while #digits > 3 do
        table.insert(parts, 1, string.sub(digits, -3))
        digits = string.sub(digits, 1, -4)
    end
    table.insert(parts, 1, digits)
    return sign .. table.concat(parts, ",")
end

local function formatRate(value)
    value = safeNumber(value, 0)
    if value >= 1000000 then return string.format("%.1fm", value / 1000000) end
    if value >= 1000 then return string.format("%.1fk", value / 1000) end
    return formatNumber(value)
end

local function average(oldAverage, oldSamples, newValue)
    oldAverage = safeNumber(oldAverage, 0)
    oldSamples = safeNumber(oldSamples, 0)
    newValue = safeNumber(newValue, 0)
    if newValue <= 0 then return oldAverage, oldSamples end
    local nextSamples = math.min(25, oldSamples + 1)
    if oldSamples <= 0 then return newValue, 1 end
    local weight = math.min(oldSamples, 24)
    return ((oldAverage * weight) + newValue) / (weight + 1), nextSamples
end


local SPEND_LABELS = {
    blacksmith = "Blacksmith",
    clothier = "Clothier",
    woodworker = "Woodworker",
    jeweler = "Jeweler / Mystic",
    alchemist = "Alchemist",
    enchanter = "Enchanter",
    grocer = "Grocer",
    brewer = "Brewer",
    chef = "Chef",
    armsman = "Armsman",
    armorer = "Armorer",
    merchant = "General Merchant",
    stable = "Stable / Riding Training",
    guildStore = "Guild Store Purchases",
    guildStoreFees = "Guild Store Fees",
    repairs = "Repairs",
    laundering = "Fence / Laundering",
    respec = "Respecs",
    travel = "Fast Travel",
    bagSpace = "Backpack Upgrades",
    bankSpace = "Bank Upgrades",
    bankFees = "Bank Fees",
    bounty = "Bounties / Justice Fines",
    buyback = "Buyback",
    cashOnDelivery = "Cash on Delivery",
    crafting = "Crafting / Reconstruction",
    guildCosts = "Guild Costs",
    pvpCosts = "PvP / Keep Costs",
    mail = "Mail Gold Outflow",
    playerTrade = "Player Trades",
    tribute = "Tales of Tribute",
    other = "Other Purchases / Fees",
    unclassified = "Unclassified Gold Outflow",
}

local SPEND_ORDER = {
    "blacksmith", "clothier", "woodworker", "jeweler", "alchemist", "enchanter",
    "grocer", "brewer", "chef", "armsman", "armorer", "merchant", "stable",
    "repairs", "respec", "travel", "laundering", "bagSpace", "bankSpace", "bankFees", "bounty", "buyback",
    "guildStore", "guildStoreFees", "cashOnDelivery", "playerTrade", "mail", "crafting",
    "guildCosts", "pvpCosts", "tribute", "other", "unclassified",
}

local function currentCharacterKey()
    if type(GetCurrentCharacterId) == "function" then
        local ok, value = pcall(GetCurrentCharacterId)
        if ok and value ~= nil and tostring(value) ~= "" then return tostring(value) end
    end
    local name = type(GetUnitName) == "function" and GetUnitName("player") or "Player"
    return tostring(name or "Player")
end

local function currencyReasonMatches(reason, constantName)
    local value = rawget(_G, constantName)
    return value ~= nil and reason == value
end

local function isRepeatable(repeatType)
    local candidates = {
        QUEST_REPEAT_DAILY,
        QUEST_REPEAT_EVENT_RESET,
        QUEST_REPEAT_MONTHLY,
        QUEST_REPEAT_REPEATABLE,
        QUEST_REPEAT_REPEATABLE_PER_DURATION,
        QUEST_REPEAT_WEEKLY,
    }
    for _, value in pairs(candidates) do
        if value ~= nil and repeatType == value then return true end
    end
    return false
end

local function applyQuestTypeSignals(questType, xpScore, goldScore, rewardScore)
    -- These are relative coaching signals, not claims about exact XP/hour or gold/hour.
    if QUEST_TYPE_CRAFTING ~= nil and questType == QUEST_TYPE_CRAFTING then
        return math.max(xpScore, 38), math.max(goldScore, 88), math.max(rewardScore, 78)
    elseif QUEST_TYPE_UNDAUNTED_PLEDGE ~= nil and questType == QUEST_TYPE_UNDAUNTED_PLEDGE then
        return math.max(xpScore, 58), math.max(goldScore, 48), math.max(rewardScore, 92)
    elseif QUEST_TYPE_MAIN_STORY ~= nil and questType == QUEST_TYPE_MAIN_STORY then
        return math.max(xpScore, 82), math.max(goldScore, 38), math.max(rewardScore, 82)
    elseif QUEST_TYPE_DUNGEON ~= nil and questType == QUEST_TYPE_DUNGEON then
        return math.max(xpScore, 68), math.max(goldScore, 44), math.max(rewardScore, 76)
    elseif QUEST_TYPE_RAID ~= nil and questType == QUEST_TYPE_RAID then
        return math.max(xpScore, 65), math.max(goldScore, 58), math.max(rewardScore, 94)
    elseif QUEST_TYPE_BATTLEGROUND ~= nil and questType == QUEST_TYPE_BATTLEGROUND then
        return math.max(xpScore, 76), math.max(goldScore, 42), math.max(rewardScore, 72)
    elseif QUEST_TYPE_GUILD ~= nil and questType == QUEST_TYPE_GUILD then
        return math.max(xpScore, 62), math.max(goldScore, 44), math.max(rewardScore, 72)
    end
    return xpScore, goldScore, rewardScore
end

function A:Initialize()
    EPC.saved.activityGoal = self.validGoals[EPC.saved.activityGoal] and EPC.saved.activityGoal or "BALANCED"
    EPC.saved.activityHistory = EPC.saved.activityHistory or {}
    EPC.saved.goldSpendingByCharacter = EPC.saved.goldSpendingByCharacter or {}
    self.selectedKey = nil
    self.lastView = nil
    self.pendingQuestCompletion = nil
    self.recentQuestGold = nil
    self.questStartTimes = {}
end

function A:GetGoal()
    local goal = EPC.saved and EPC.saved.activityGoal or "BALANCED"
    if not self.validGoals[goal] then goal = "BALANCED" end
    return goal
end

function A:SetGoal(goal)
    goal = string.upper(tostring(goal or "BALANCED"))
    if not self.validGoals[goal] then return end
    EPC.saved.activityGoal = goal
    self.selectedKey = nil
    -- Goal switching is a presentation/ranking change. Reuse the cached source
    -- entries so XP/GOLD/BALANCED tabs do not rebuild the whole character engine.
    if self.lastBaseEntries and EPC.lastSnapshot and EPC.UI and EPC.saved.activeTab == "ACTIVITY" then
        local view = self:BuildView(EPC.lastSnapshot, true)
        if EPC.lastModel then
            EPC.lastModel.activity = view
            EPC.UI:Render(EPC.lastModel)
        else
            EPC.UI:RenderActivity(view)
        end
        return
    end
    EPC:RequestRefresh("activity-goal")
end

function A:IsEndgame(snapshot)
    return safeNumber(snapshot and snapshot.level, 1) >= 50
end

function A:RecordQuestSample(questName, xpGain, goldGain, durationSeconds)
    questName = clean(questName, "")
    if questName == "" or not EPC.saved then return end

    EPC.saved.activityHistory = EPC.saved.activityHistory or {}
    local history = EPC.saved.activityHistory[questName] or {
        xpAverage = 0,
        xpSamples = 0,
        goldAverage = 0,
        goldSamples = 0,
        durationAverage = 0,
        durationSamples = 0,
        lastSeen = 0,
    }

    if safeNumber(xpGain, 0) > 0 then
        history.xpAverage, history.xpSamples = average(history.xpAverage, history.xpSamples, xpGain)
    end
    if safeNumber(goldGain, 0) > 0 then
        history.goldAverage, history.goldSamples = average(history.goldAverage, history.goldSamples, goldGain)
    end
    if safeNumber(durationSeconds, 0) >= 5 and safeNumber(durationSeconds, 0) <= 21600 then
        history.durationAverage, history.durationSamples = average(history.durationAverage, history.durationSamples, durationSeconds)
    end

    history.lastSeen = persistentStamp()
    EPC.saved.activityHistory[questName] = history
    self:PruneHistory(300)
end

function A:PruneHistory(maxEntries)
    maxEntries = safeNumber(maxEntries, 300)
    local history = EPC.saved and EPC.saved.activityHistory
    if type(history) ~= "table" then return end
    local rows = {}
    for name, data in pairs(history) do
        rows[#rows + 1] = { name = name, lastSeen = safeNumber(data and data.lastSeen, 0) }
    end
    if #rows <= maxEntries + 25 then return end
    table.sort(rows, function(a, b) return a.lastSeen > b.lastSeen end)
    for i = maxEntries + 1, #rows do history[rows[i].name] = nil end
end

function A:OnQuestAdded(journalIndex, questName)
    questName = clean(questName, "")
    if questName == "" then return end
    self.questStartTimes = self.questStartTimes or {}
    self.questStartTimes[questName] = nowMs()
end

function A:OnQuestComplete(questName, level, previousExperience, currentExperience, championPoints, questType, zoneDisplayType)
    local xpGain = 0
    previousExperience = safeNumber(previousExperience, 0)
    currentExperience = safeNumber(currentExperience, 0)
    if currentExperience >= previousExperience then
        xpGain = currentExperience - previousExperience
    end

    local stamp = nowMs()
    local goldGain = nil
    if self.recentQuestGold and stamp - self.recentQuestGold.time <= 3000 then
        goldGain = self.recentQuestGold.amount
        self.recentQuestGold = nil
    end

    local durationSeconds = nil
    self.questStartTimes = self.questStartTimes or {}
    local startedAt = self.questStartTimes[questName]
    if startedAt and stamp >= startedAt then
        durationSeconds = (stamp - startedAt) / 1000
        self.questStartTimes[questName] = nil
    end

    self:RecordQuestSample(questName, xpGain, goldGain, durationSeconds)
    self.pendingQuestCompletion = { name = questName, time = stamp }

    if EPC.saved and EPC.saved.activeTab == "ACTIVITY" then
        EPC:RequestRefresh("quest-complete")
    end
end

function A:GetGoldSpendingLedger()
    if not EPC.saved then return { total = 0, categories = {} } end
    EPC.saved.goldSpendingByCharacter = EPC.saved.goldSpendingByCharacter or {}
    local key = currentCharacterKey()
    local ledger = EPC.saved.goldSpendingByCharacter[key]
    if type(ledger) ~= "table" then
        ledger = { total = 0, categories = {} }
        EPC.saved.goldSpendingByCharacter[key] = ledger
    end
    ledger.total = safeNumber(ledger.total, 0)
    ledger.categories = type(ledger.categories) == "table" and ledger.categories or {}
    return ledger
end

function A:GetGoldSpendingView()
    local ledger = self:GetGoldSpendingLedger()
    local rows = {}
    for _, key in ipairs(SPEND_ORDER) do
        rows[#rows + 1] = { key = key, label = SPEND_LABELS[key] or key, amount = safeNumber(ledger.categories[key], 0) }
    end
    return { total = safeNumber(ledger.total, 0), rows = rows }
end

function A:IsIgnoredGoldOutflow(reason)
    -- Internal storage moves are not purchases. They can reduce character gold,
    -- but the same gold still belongs to the player/account, so do not count them
    -- as spending. Refund reasons are also excluded if ESO ever reports them with
    -- an unusual negative delta.
    local ignored = {
        "CURRENCY_CHANGE_REASON_BANK_DEPOSIT",
        "CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL",
        "CURRENCY_CHANGE_REASON_GUILD_BANK_DEPOSIT",
        "CURRENCY_CHANGE_REASON_GUILD_BANK_WITHDRAWAL",
        "CURRENCY_CHANGE_REASON_TRADINGHOUSE_REFUND",
        "CURRENCY_CHANGE_REASON_JUMP_FAILURE_REFUND",
        "CURRENCY_CHANGE_REASON_PLAYER_INIT",
    }
    for _, constantName in ipairs(ignored) do
        if currencyReasonMatches(reason, constantName) then return true end
    end
    return false
end

function A:ClassifyGoldSpend(reason)
    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_TRADINGHOUSE_PURCHASE") then return "guildStore" end
    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_TRADINGHOUSE_LISTING") then return "guildStoreFees" end
    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_VENDOR_REPAIR") then return "repairs" end
    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_VENDOR_LAUNDER") then return "laundering" end
    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_TRAVEL_GRAVEYARD") then return "travel" end
    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_STABLESPACE")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_FEED_MOUNT") then return "stable" end
    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_RESPEC_ATTRIBUTES")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_RESPEC_CHAMPION")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_RESPEC_MORPHS")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_RESPEC_SKILLS") then
        return "respec"
    end

    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_BAGSPACE") then return "bagSpace" end
    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_BANKSPACE") then return "bankSpace" end
    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_BANK_FEE") then return "bankFees" end
    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_BOUNTY_CONFISCATED")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_BOUNTY_PAID_FENCE")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_BOUNTY_PAID_GUARD") then return "bounty" end
    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_BUYBACK") then return "buyback" end
    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_CASH_ON_DELIVERY") then return "cashOnDelivery" end
    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_TRADE") then return "playerTrade" end
    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_MAIL") then return "mail" end
    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_TRIBUTE") then return "tribute" end

    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_REFORGE")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_RECONSTRUCTION")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_RESEARCH_TRAIT")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_TRAIT_REVEAL")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_CRAFT")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_RECIPE") then
        return "crafting"
    end

    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_EDIT_GUILD_HERALDRY")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_GUILD_FORWARD_CAMP")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_GUILD_TABARD")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_GUILD_STANDARD") then
        return "guildCosts"
    end

    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_KEEP_REPAIR")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_KEEP_UPGRADE")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_PVP_RESURRECT") then
        return "pvpCosts"
    end

    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_VENDOR") then
        local storeType = nil
        if EPC.MiniMap and type(EPC.MiniMap.GetCurrentStoreIdentity) == "function" then
            local ok, _, detectedType = pcall(EPC.MiniMap.GetCurrentStoreIdentity, EPC.MiniMap)
            if ok then storeType = tostring(detectedType or "") end
        end
        local map = {
            blacksmith = "blacksmith", clothier = "clothier", woodworker = "woodworker",
            alchemist = "alchemist", enchanter = "enchanter", grocer = "grocer",
            brewer = "brewer", chef = "chef", mystic = "jeweler", jeweler = "jeweler", stable = "stable",
            armsman = "armsman", armorer = "armorer", merchant = "merchant",
        }
        return map[storeType] or "merchant"
    end

    -- Known gold costs that do not have a more useful UI category yet.
    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_ABILITY_UPGRADE_PURCHASE")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_SOUL_HEAL")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_STUCK")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_CHARACTER_UPGRADE")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_ACTION")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_CONVERSATION")
        or currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_DEATH") then
        return "other"
    end

    if currencyReasonMatches(reason, "CURRENCY_CHANGE_REASON_UNKNOWN") then return "unclassified" end
    return nil
end

function A:RecordGoldSpend(amount, category)
    amount = math.floor(safeNumber(amount, 0) + 0.5)
    if amount <= 0 or not category then return end
    local ledger = self:GetGoldSpendingLedger()
    ledger.total = safeNumber(ledger.total, 0) + amount
    ledger.categories[category] = safeNumber(ledger.categories[category], 0) + amount
end

-- Some ESO builds do not expose a distinct currency-change reason for Champion
-- redistribution.  Keep the confirmed live cost briefly so EVENT_MONEY_UPDATE can
-- still classify the matching decrease as a respec without counting unrelated gold.
function A:SetPendingGoldSpend(category, amount)
    amount = math.floor(safeNumber(amount, 0) + 0.5)
    if amount <= 0 or not category then
        self.pendingGoldSpend = nil
        return
    end
    self.pendingGoldSpend = {
        category = tostring(category),
        amount = amount,
        time = nowMs(),
    }
end

function A:ClearPendingGoldSpend(category)
    if not self.pendingGoldSpend then return end
    if category == nil or tostring(self.pendingGoldSpend.category) == tostring(category) then
        self.pendingGoldSpend = nil
    end
end

function A:CommitPendingGoldSpend(category)
    local pending = self.pendingGoldSpend
    if not pending then return false end
    if category ~= nil and tostring(pending.category) ~= tostring(category) then return false end
    self:RecordGoldSpend(pending.amount, pending.category)
    self.pendingGoldSpend = nil
    if EPC.saved and EPC.saved.activeTab == "JOURNAL" and EPC.Journal and EPC.Journal.Refresh then
        EPC.Journal:Refresh()
    end
    return true
end

function A:OnMoneyUpdate(newMoney, oldMoney, reason)
    local delta = safeNumber(newMoney, 0) - safeNumber(oldMoney, 0)

    if delta < 0 then
        local spent = math.floor((-delta) + 0.5)
        local category = self:ClassifyGoldSpend(reason)
        local pending = self.pendingGoldSpend
        local pendingMatches = pending
            and (nowMs() - safeNumber(pending.time, 0) <= 10000)
            and spent == safeNumber(pending.amount, 0)

        if pendingMatches and (category == nil or category == pending.category) then
            category = pending.category
            self.pendingGoldSpend = nil
        elseif pending and nowMs() - safeNumber(pending.time, 0) > 10000 then
            self.pendingGoldSpend = nil
        end

        -- Track every real negative character-gold outflow. Known categories
        -- get a descriptive bucket; future/new ESO reasons fall back to
        -- Unclassified instead of silently disappearing. Internal bank and guild-
        -- bank moves are the only intentional exclusions because they are storage
        -- transfers, not spending.
        if not category and not self:IsIgnoredGoldOutflow(reason) then
            category = "unclassified"
        end

        if category then
            self:RecordGoldSpend(spent, category)
            if EPC.saved and EPC.saved.activeTab == "JOURNAL" and EPC.Journal and EPC.Journal.Refresh then
                EPC.Journal:Refresh()
            end
        end
    end

    if CURRENCY_CHANGE_REASON_QUESTREWARD == nil or reason ~= CURRENCY_CHANGE_REASON_QUESTREWARD then return end
    local gain = delta
    if gain <= 0 then return end

    local stamp = nowMs()
    if self.pendingQuestCompletion and stamp - self.pendingQuestCompletion.time <= 3000 then
        self:RecordQuestSample(self.pendingQuestCompletion.name, nil, gain)
        self.pendingQuestCompletion = nil
    else
        self.recentQuestGold = { amount = gain, time = stamp }
    end

    if EPC.saved and EPC.saved.activeTab == "ACTIVITY" then
        EPC:RequestRefresh("quest-gold")
    end
end

function A:GetJournalGold(questIndex)
    if type(GetJournalQuestNumRewards) ~= "function" or type(GetJournalQuestRewardInfo) ~= "function" then
        return 0
    end

    local ok, count = pcall(GetJournalQuestNumRewards, questIndex)
    if not ok then return 0 end
    count = safeNumber(count, 0)
    local gold = 0

    for rewardIndex = 1, count do
        local rewardOk, rewardType, _, amount = pcall(GetJournalQuestRewardInfo, questIndex, rewardIndex)
        if rewardOk and REWARD_TYPE_MONEY ~= nil and rewardType == REWARD_TYPE_MONEY then
            gold = gold + safeNumber(amount, 0)
        end
    end
    return gold
end

function A:GetAcceptedQuests(snapshot)
    local entries = {}
    if type(GetNumJournalQuests) ~= "function" or type(GetJournalQuestInfo) ~= "function" then
        return entries
    end

    local count = safeNumber(EPC:Safe(GetNumJournalQuests, 0), 0)
    local historyTable = EPC.saved and EPC.saved.activityHistory or {}

    for questIndex = 1, count do
        local ok, questName, _, _, _, _, completed, tracked, questLevel, _, questType = pcall(GetJournalQuestInfo, questIndex)
        local isPledge = ok and QUEST_TYPE_UNDAUNTED_PLEDGE ~= nil and questType == QUEST_TYPE_UNDAUNTED_PLEDGE
        if ok and questName and questName ~= "" and (not completed or isPledge) then
            local zoneName = "Unknown zone"
            if type(GetJournalQuestLocationInfo) == "function" then
                local locOk, returnedZone = pcall(GetJournalQuestLocationInfo, questIndex)
                if locOk then zoneName = clean(returnedZone, zoneName) end
            end

            if isPledge and completed == true and EPC.Travel and type(EPC.Travel.GetUndauntedEnclaveForPlayer) == "function" then
                local enclave = EPC.Travel:GetUndauntedEnclaveForPlayer()
                if enclave then zoneName = enclave.city .. ", " .. enclave.zone end
            end

            local repeatType = EPC:Safe(GetJournalQuestRepeatType, 0, questIndex)
            local directGold = self:GetJournalGold(questIndex)
            local history = historyTable and historyTable[questName] or nil
            local learnedXP = history and safeNumber(history.xpAverage, 0) or 0
            local learnedGold = history and safeNumber(history.goldAverage, 0) or 0
            local learnedDuration = history and safeNumber(history.durationAverage, 0) or 0
            local learnedXPRate = (learnedXP > 0 and learnedDuration > 0) and ((learnedXP / learnedDuration) * 3600) or 0
            local learnedGoldRate = (learnedGold > 0 and learnedDuration > 0) and ((learnedGold / learnedDuration) * 3600) or 0
            local displayGold = math.max(directGold, learnedGold)

            local xpScore
            if learnedXPRate > 0 then
                xpScore = math.min(100, 45 + (learnedXPRate / 10000))
            elseif learnedXP > 0 then
                xpScore = math.min(100, 45 + (learnedXP / 1200))
            else
                xpScore = 42 + math.min(25, safeNumber(questLevel, snapshot.level) * 0.5)
                if tracked then xpScore = xpScore + 5 end
                if isRepeatable(repeatType) then xpScore = xpScore + 5 end
            end

            local goldScore
            if learnedGoldRate > 0 then
                goldScore = math.min(100, 35 + (learnedGoldRate / 1000))
            else
                goldScore = displayGold > 0 and math.min(100, 35 + (displayGold / 80)) or 30
            end
            if isRepeatable(repeatType) then goldScore = goldScore + 6 end
            local rewardScore = isRepeatable(repeatType) and 65 or 52
            xpScore, goldScore, rewardScore = applyQuestTypeSignals(questType, xpScore, goldScore, rewardScore)

            entries[#entries + 1] = {
                key = "QUEST:" .. tostring(questIndex) .. ":" .. questName,
                kind = "QUEST",
                questIndex = questIndex,
                name = questName,
                location = zoneName,
                xpScore = math.min(100, xpScore),
                goldScore = math.min(100, goldScore),
                rewardScore = math.min(100, rewardScore),
                directGold = directGold,
                learnedXP = learnedXP,
                learnedGold = learnedGold,
                learnedDuration = learnedDuration,
                learnedXPRate = learnedXPRate,
                learnedGoldRate = learnedGoldRate,
                repeatable = isRepeatable(repeatType),
                tracked = tracked == true,
                questType = questType,
                actionText = "ROUTE QUEST",
                canActivate = true,
            }
        end
    end

    return entries
end

function A:GetDailyRewardEligibility(activityType)
    if type(IsActivityEligibleForDailyReward) ~= "function" or activityType == nil then return nil end
    local ok, eligible = pcall(IsActivityEligibleForDailyReward, activityType)
    if not ok then return nil end
    return eligible == true
end

function A:GetBattlegroundEligibility()
    -- Build the list explicitly so a nil constant cannot create a sparse-array # bug.
    local candidates = {}
    local function add(value) if value ~= nil then candidates[#candidates + 1] = value end end
    add(LFG_ACTIVITY_BATTLE_GROUND_CHAMPION)
    add(LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION)
    add(LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL)

    local known = false
    for i = 1, #candidates do
        local result = self:GetDailyRewardEligibility(candidates[i])
        if result ~= nil then
            known = true
            if result then return true end
        end
    end
    if known then return false end
    return nil
end

function A:GetCuratedActivities(snapshot)
    local endgame = self:IsEndgame(snapshot)
    local level = safeNumber(snapshot.level, 1)
    local activities = {}

    local function add(item)
        item.key = item.key or ("ACTIVITY:" .. string.upper(string.gsub(item.name, "%s+", "_")))
        item.kind = "ACTIVITY"
        item.canActivate = false
        activities[#activities + 1] = item
    end

    local dungeonReady = self:GetDailyRewardEligibility(LFG_ACTIVITY_DUNGEON)
    local dungeonStatus = dungeonReady == true and "Daily bonus ready"
        or (dungeonReady == false and "Daily bonus already used or unavailable" or "Check Activity Finder")

    add({
        name = "Random Dungeon daily bonus",
        location = "Activity Finder",
        xpScore = 96,
        goldScore = 52,
        rewardScore = 88,
        status = dungeonStatus,
        note = "Queue as a random dungeon to receive the daily bonus when eligible.",
    })

    local bgReady = self:GetBattlegroundEligibility()
    add({
        name = "Battleground daily reward",
        location = "Activity Finder",
        xpScore = 86,
        goldScore = 42,
        rewardScore = 66,
        status = bgReady == true and "Daily reward ready" or (bgReady == false and "Daily reward used or unavailable" or "Check Activity Finder"),
        note = "Useful when you want XP plus PvP rewards; queue time and match result affect efficiency.",
    })

    add({
        name = "Daily crafting writs",
        location = "Writ boards in major cities",
        xpScore = 38,
        goldScore = 94,
        rewardScore = 82,
        status = "Reliable repeatable income",
        note = "Strong direct-gold routine with crafting materials and other rewards; value rises with multiple characters.",
    })

    if level >= 45 then
        local pledgeLocation = "Undaunted Enclave"
        if EPC.Travel and type(EPC.Travel.GetUndauntedEnclaveForPlayer) == "function" then
            local enclave = EPC.Travel:GetUndauntedEnclaveForPlayer()
            if enclave then pledgeLocation = enclave.city .. ", " .. enclave.zone end
        end
        add({
            name = "Undaunted Pledges",
            location = pledgeLocation,
            xpScore = 58,
            goldScore = 48,
            rewardScore = 92,
            status = "Repeatable dungeon objectives",
            note = "Good endgame progression value from dungeon rewards, keys, gear, and transmute-related progression.",
        })
    end

    if endgame then
        add({
            name = "Trial weekly quest",
            location = "Trial entrance / weekly quest giver",
            xpScore = 62,
            goldScore = 66,
            rewardScore = 97,
            status = "High-value weekly endgame objective",
            note = "Prioritize when your group can complete it efficiently; loot value depends on the trial and your goals.",
        })
        add({
            name = "Infinite Archive run",
            location = "Infinite Archive",
            xpScore = 68,
            goldScore = 54,
            rewardScore = 90,
            status = "Repeatable solo/duo progression",
            note = "Useful for repeatable rewards and account progression when you want a non-queue activity.",
        })
        add({
            name = "Tamriel Tome challenges",
            location = "Tamriel Tome menu",
            xpScore = 48,
            goldScore = 38,
            rewardScore = 96,
            status = "Seasonal progression",
            note = "Current seasonal objectives can overlap with your normal farming route, improving overall reward efficiency.",
        })
    else
        add({
            name = "Zone story and main quests",
            location = "Current / nearby quest zones",
            xpScore = 82,
            goldScore = 40,
            rewardScore = 74,
            status = "Strong leveling route",
            note = "Good for steady character XP while also unlocking zones, skill points, and progression systems.",
        })
    end

    return activities
end

function A:GetFocusBias(entry, endgame)
    if endgame ~= true then return 0 end
    if not EPC.Endgame or not EPC.Endgame.GetFocus then return 0 end
    local focus = EPC.Endgame:GetFocus()
    if focus == "AUTO" and EPC.Advisor then focus = EPC.Advisor:GetEffectiveFocus(EPC.lastSnapshot) end
    local name = string.lower(tostring(entry and entry.name or ""))
    local questType = entry and entry.questType or nil
    local kind = entry and entry.kind or nil

    local isDungeon = (QUEST_TYPE_DUNGEON ~= nil and questType == QUEST_TYPE_DUNGEON)
        or (QUEST_TYPE_UNDAUNTED_PLEDGE ~= nil and questType == QUEST_TYPE_UNDAUNTED_PLEDGE)
        or string.find(name, "dungeon", 1, true) ~= nil
        or string.find(name, "undaunted", 1, true) ~= nil
    local isTrial = (QUEST_TYPE_RAID ~= nil and questType == QUEST_TYPE_RAID)
        or string.find(name, "trial", 1, true) ~= nil
    local isSolo = string.find(name, "infinite archive", 1, true) ~= nil
        or string.find(name, "zone story", 1, true) ~= nil

    if focus == "DUNGEONS" then
        return isDungeon and 26 or (isTrial and -8 or 0)
    elseif focus == "TRIALS" then
        return isTrial and 30 or (isDungeon and 4 or 0)
    elseif focus == "QUESTING" then
        return kind == "QUEST" and 24 or (isSolo and 8 or -2)
    elseif focus == "SOLO" then
        if isSolo or kind == "QUEST" then return 14 end
        if isTrial then return -12 end
        return 0
    elseif focus == "GEAR" then
        if isTrial then return 20 end
        if isDungeon then return 16 end
        if string.find(name, "archive", 1, true) then return 12 end
        return 0
    elseif focus == "DPS" then
        if isTrial then return 12 end
        if isDungeon then return 10 end
        return 0
    elseif focus == "GOLD" then
        return safeNumber(entry and entry.goldScore, 0) * 0.08
    elseif focus == "XP_CP" then
        return safeNumber(entry and entry.xpScore, 0) * 0.08
    end
    return 0
end

function A:GetRoleBias(entry, endgame)
    if endgame ~= true or not EPC.Role then return 0 end
    local role = EPC.Role:GetRole()
    local name = string.lower(tostring(entry and entry.name or ""))
    local questType = entry and entry.questType or nil
    local isDungeon = (QUEST_TYPE_DUNGEON ~= nil and questType == QUEST_TYPE_DUNGEON)
        or (QUEST_TYPE_UNDAUNTED_PLEDGE ~= nil and questType == QUEST_TYPE_UNDAUNTED_PLEDGE)
        or string.find(name, "dungeon", 1, true) ~= nil
        or string.find(name, "undaunted", 1, true) ~= nil
    local isTrial = (QUEST_TYPE_RAID ~= nil and questType == QUEST_TYPE_RAID) or string.find(name, "trial", 1, true) ~= nil
    if role == "HEALER" then
        if isTrial then return 9 end
        if isDungeon then return 8 end
    elseif role == "TANK" then
        if isDungeon then return 10 end
        if isTrial then return 8 end
    end
    return 0
end

function A:ScoreEntry(entry, goal, endgame)
    local xp = safeNumber(entry.xpScore, 0)
    local gold = safeNumber(entry.goldScore, 0)
    local rewards = safeNumber(entry.rewardScore, 0)
    local score
    if goal == "XP" then
        score = (xp * 0.72) + (rewards * 0.18) + (gold * 0.10)
    elseif goal == "GOLD" then
        score = (gold * 0.72) + (rewards * 0.18) + (xp * 0.10)
    else
        score = (xp * 0.38) + (gold * 0.34) + (rewards * 0.28)
    end
    return score + self:GetFocusBias(entry, endgame) + self:GetRoleBias(entry, endgame)
end

function A:DescribeEntry(entry)
    if entry.kind == "QUEST" then
        local details = {}
        details[#details + 1] = entry.location
        if safeNumber(entry.learnedXPRate, 0) > 0 then
            details[#details + 1] = "local ~" .. formatRate(entry.learnedXPRate) .. " XP/hr"
        elseif safeNumber(entry.learnedXP, 0) > 0 then
            details[#details + 1] = "learned XP ~" .. formatNumber(entry.learnedXP)
        else
            details[#details + 1] = "XP estimate"
        end
        local gold = math.max(safeNumber(entry.directGold, 0), safeNumber(entry.learnedGold, 0))
        if safeNumber(entry.learnedGoldRate, 0) > 0 then
            details[#details + 1] = "local ~" .. formatRate(entry.learnedGoldRate) .. "g/hr"
        elseif gold > 0 then
            details[#details + 1] = formatNumber(gold) .. "g"
        end
        if entry.repeatable then details[#details + 1] = "repeatable" end
        return table.concat(details, "  |  ")
    end
    return string.format("%s  |  %s", clean(entry.location, "Location varies"), clean(entry.status, "Available"))
end

function A:BuildView(snapshot, reuseBase)
    local goal = self:GetGoal()
    local endgame = self:IsEndgame(snapshot)
    local entries = {}
    local curatedCount = 0
    if reuseBase == true and self.lastBaseEntries then
        for i=1,#self.lastBaseEntries do
            local copy = {}
            for k,v in pairs(self.lastBaseEntries[i]) do copy[k]=v end
            entries[#entries+1]=copy
        end
        curatedCount = self.lastCuratedCount or 0
    else
        entries = self:GetAcceptedQuests(snapshot)
        local curated = self:GetCuratedActivities(snapshot)
        curatedCount = #curated
        for i = 1, #curated do entries[#entries + 1] = curated[i] end
        self.lastBaseEntries = {}
        for i=1,#entries do
            local copy={}
            for k,v in pairs(entries[i]) do if k ~= "score" and k ~= "displayText" and k ~= "detailText" then copy[k]=v end end
            self.lastBaseEntries[i]=copy
        end
        self.lastCuratedCount = curatedCount
    end

    for i = 1, #entries do
        entries[i].score = self:ScoreEntry(entries[i], goal, endgame)
        entries[i].displayText = entries[i].name
        entries[i].detailText = self:DescribeEntry(entries[i])
    end

    table.sort(entries, function(a, b)
        if math.abs((a.score or 0) - (b.score or 0)) > 0.001 then
            return (a.score or 0) > (b.score or 0)
        end
        return tostring(a.name) < tostring(b.name)
    end)

    local selected = nil
    if self.selectedKey then
        for i = 1, #entries do
            if entries[i].key == self.selectedKey then selected = entries[i] break end
        end
    end
    if self.selectedKey and not selected then self.selectedKey = nil end

    local rows = {}
    for i = 1, math.min(self.PAGE_SIZE, #entries) do rows[#rows + 1] = entries[i] end

    local acceptedCount = math.max(0, #entries - curatedCount)
    local top = rows[1]
    local phaseLabel = endgame and "ENDGAME" or "LEVELING"
    local goalLabel = self.goalLabels[goal] or goal
    local rawFocus = EPC.Endgame and EPC.Endgame:GetFocus() or "DPS"
    local effectiveFocus = rawFocus
    if rawFocus == "AUTO" and EPC.Advisor then effectiveFocus = EPC.Advisor:GetEffectiveFocus(snapshot) end
    local focusLabel = EPC.Endgame and EPC.Endgame:GetFocusLabel(effectiveFocus) or "GENERAL"
    local title = top and top.name or "No activities available"
    local description
    if top then
        description = string.format(
            "%s is currently the best %s match from the data the coach can see for your %s profile. Rankings combine direct rewards, measured quest history, repeatability, activity value, and a small role-practice bias for group content.",
            top.name,
            string.lower(goalLabel),
            snapshot.roleLabel or "current role"
        )
    else
        description = "The activity planner could not read any current quest or activity data."
    end

    local characterGold = 0
    if type(GetCurrencyAmount) == "function" and CURT_MONEY ~= nil and CURRENCY_LOCATION_CHARACTER ~= nil then
        characterGold = safeNumber(EPC:Safe(GetCurrencyAmount, 0, CURT_MONEY, CURRENCY_LOCATION_CHARACTER), 0)
    end

    local view = {
        header = (endgame and "ENDGAME PROFIT & XP" or "LEVELING PROFIT & XP") .. "  /  " .. focusLabel,
        title = title,
        description = description,
        goal = goal,
        goalLabel = goalLabel,
        entries = entries,
        rows = rows,
        selected = selected,
        actionEnabled = false,
        actionText = "",
        stats = {
            { label = "MODE", value = phaseLabel },
            { label = "GOAL", value = goalLabel },
            { label = "ROLE", value = snapshot.roleLabel or "Damage" },
            { label = "FOCUS", value = rawFocus == "AUTO" and ("AUTO > " .. focusLabel) or focusLabel },
        },
        hint = selected and (selected.note or selected.detailText) or ("Ranking is biased toward your " .. string.lower(focusLabel) .. " focus and " .. string.lower(snapshot.roleLabel or "damage") .. " role. Select an activity to view details, or change the planner goal above."),
        sessionMinutes = EPC.Advisor and EPC.Advisor:GetSessionMinutes() or 60,
    }

    self.lastView = view
    return view
end

function A:SelectVisibleRow(rowIndex)
    local view = self.lastView or self:BuildView(EPC.lastSnapshot or (EPC.Engine and EPC.Engine:BuildSnapshot()))
    local entry = view and view.rows and view.rows[rowIndex] or nil
    if not entry then return end
    self.selectedKey = entry.key
    EPC:RefreshNow("activity-select")
end

function A:TravelSelectedNearestWayshrine()
    -- Activities contains both journal quests and non-quest recommendations.
    -- Only accepted journal quests can be routed to a quest/objective wayshrine.
    local view = self:BuildView(EPC.lastSnapshot or (EPC.Engine and EPC.Engine:BuildSnapshot()))
    local entry = view and view.selected or nil
    if not entry then
        EPC:Print("Select a quest activity first.")
        return false
    end
    if entry.kind ~= "QUEST" or not entry.questIndex then
        EPC:Print((entry.name or "That activity") .. " is not a journal quest, so quest wayshrine travel is unavailable.")
        return false
    end
    if not EPC.Travel or type(EPC.Travel.TravelToNearestQuestStarterWayshrine) ~= "function" then
        EPC:Print("Quest wayshrine travel is unavailable.")
        return false
    end

    -- Make the selected activity quest the assisted quest first. This lets the
    -- Travel module use the live objective-distance ranking when ESO exposes it.
    if TRACK_TYPE_QUEST ~= nil and type(SetTracked) == "function" then
        pcall(SetTracked, TRACK_TYPE_QUEST, true, entry.questIndex, 0)
    end
    if TRACK_TYPE_QUEST ~= nil and type(SetTrackedIsAssisted) == "function" then
        pcall(SetTrackedIsAssisted, TRACK_TYPE_QUEST, true, entry.questIndex, 0)
    end

    local quest = {
        questIndex = entry.questIndex,
        name = entry.name,
        zone = entry.location,
        zoneName = entry.location,
    }
    return EPC.Travel:TravelToNearestQuestStarterWayshrine(quest)
end

function A:ActivateSelected()
    -- Rebuild from selectedKey so the action never relies on a stale pre-click view.
    local view = self:BuildView(EPC.lastSnapshot or (EPC.Engine and EPC.Engine:BuildSnapshot()))
    local entry = view and view.selected or nil
    if not entry then
        EPC:Print("Select a quest first.")
        return
    end

    if entry.kind ~= "QUEST" or not entry.questIndex then
        EPC:Print((entry.name or "Activity") .. ": " .. clean(entry.location, "location varies") .. ".")
        return
    end

    if TRACK_TYPE_QUEST == nil or type(SetTrackedIsAssisted) ~= "function" then
        EPC:Print("Quest routing API is unavailable on this client.")
        return
    end

    if type(SetTracked) == "function" then
        pcall(SetTracked, TRACK_TYPE_QUEST, true, entry.questIndex, 0)
    end
    pcall(SetTrackedIsAssisted, TRACK_TYPE_QUEST, true, entry.questIndex, 0)

    EPC.saved.activeTab = "MAP"
    EPC.saved.travelMode = "SHRINES"
    EPC.saved.travelPage = 1
    EPC.saved.travelBookPage = 1
    if EPC.Travel then
        EPC.Travel.selectedKey = nil
        if EPC.Travel.InvalidateQuestPositionCache then EPC.Travel:InvalidateQuestPositionCache() end
    end
    EPC:RefreshNow("activity-route")
end
