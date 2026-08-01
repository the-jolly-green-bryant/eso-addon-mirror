-- ============================================
-- RAFFLE DATA / CALC HELPERS
-- ============================================

local DEMO_MEMBERS = NWT.RaffleConstants_DEMO_MEMBERS or {}

local function IsGuildEnabled(guildId)
    local sv = NWT.savedVars
    if type(sv.bookkeeper) ~= "table" then sv.bookkeeper = {} end
    if type(sv.bookkeeper.enabledGuilds) ~= "table" then sv.bookkeeper.enabledGuilds = {} end
    if sv.bookkeeper.enabledGuilds[guildId] == nil then
        sv.bookkeeper.enabledGuilds[guildId] = true
    end
    return sv.bookkeeper.enabledGuilds[guildId]
end

local function GetDefaultRaffleSettings()
    return {
        duesAmount = 5000,
        raffleSuffixes = {1},
        rafflePeriodId = "all",
        lastScanTime = 0,
        memberPayments = {},
        ticketPacks = {
            { price = 1001, tickets = 1, suffix = 1 },
        },
        useTicketPacks = false,
        simpleTicketPrice = 1000,
        rankBonuses = {
            enabled = false,
            ranks = {},
        },
        activityBonuses = {
            enabled = false,
            recruitmentBonus = 0,
            newMemberBonus = 0,
            traderSalesBonus = false,
            traderSalesPer = 0,
            eventParticipation = 0,
            longevityBonus = 0,
        },
        prizeConfig = {
            poolPercentage = 100,
            numWinners = 1,
            distribution = "equal",
            tieredSplit = {50, 30, 20},
            progressiveJackpot = false,
            jackpotAmount = 0,
            epicPrizeThresholds = {},
        },
        entryRules = {
            maxTickets = 0,
            minTickets = 0,
            winnerCooldown = 0,
            mustBeOnline = false,
            onlineThresholdDays = 7,
            excludedRanks = {},
        },
        raffleType = "gold",
        itemPrizes = {},
    }
end

local function DeepCopyTable(value)
    if type(value) ~= "table" then
        return value
    end
    local out = {}
    for k, v in pairs(value) do
        out[k] = DeepCopyTable(v)
    end
    return out
end

local function MergeDefaults(target, defaults)
    for k, v in pairs(defaults) do
        local targetValue = target[k]
        if targetValue == nil then
            target[k] = DeepCopyTable(v)
        elseif type(v) == "table" then
            if type(targetValue) ~= "table" then
                target[k] = DeepCopyTable(v)
            else
                MergeDefaults(targetValue, v)
            end
        end
    end
end

local function NormalizeRaffleGuildSettings(gs)
    if type(gs) ~= "table" then
        gs = {}
    end

    MergeDefaults(gs, GetDefaultRaffleSettings())
    if gs.ticketPrice and (not gs.simpleTicketPrice or gs.simpleTicketPrice <= 0) then
        gs.simpleTicketPrice = gs.ticketPrice
    end

    if type(gs.memberPayments) ~= "table" then gs.memberPayments = {} end
    if type(gs.pastWinners) ~= "table" then gs.pastWinners = {} end
    if type(gs.linkedGuilds) ~= "table" then gs.linkedGuilds = {} end
    if type(gs.raffleExemptRanks) ~= "table" then gs.raffleExemptRanks = {} end
    if type(gs.itemPrizes) ~= "table" then gs.itemPrizes = {} end

    if type(gs.raffleSuffixes) ~= "table" then gs.raffleSuffixes = {1} end
    for i = #gs.raffleSuffixes, 1, -1 do
        local suffix = tonumber(gs.raffleSuffixes[i])
        if not suffix then
            table.remove(gs.raffleSuffixes, i)
        else
            gs.raffleSuffixes[i] = math.max(0, math.min(9, math.floor(suffix)))
        end
    end
    if #gs.raffleSuffixes == 0 then gs.raffleSuffixes = {1} end

    if type(gs.ticketPacks) ~= "table" then gs.ticketPacks = {} end
    for i = #gs.ticketPacks, 1, -1 do
        local pack = gs.ticketPacks[i]
        if type(pack) ~= "table" then
            table.remove(gs.ticketPacks, i)
        else
            local price = tonumber(pack.price)
            local tickets = tonumber(pack.tickets)
            local suffix = tonumber(pack.suffix)
            if not price or price <= 0 or not tickets or tickets <= 0 or suffix == nil then
                table.remove(gs.ticketPacks, i)
            else
                pack.price = math.max(1, math.floor(price))
                pack.tickets = math.max(1, math.floor(tickets))
                pack.suffix = math.max(0, math.min(9, math.floor(suffix)))
            end
        end
    end
    if #gs.ticketPacks == 0 then
        gs.ticketPacks = { { price = 1001, tickets = 1, suffix = 1 } }
    end

    if type(gs.rankBonuses) ~= "table" then gs.rankBonuses = {} end
    if type(gs.rankBonuses.ranks) ~= "table" then gs.rankBonuses.ranks = {} end
    gs.rankBonuses.enabled = (gs.rankBonuses.enabled == true)

    if type(gs.activityBonuses) ~= "table" then gs.activityBonuses = {} end
    gs.activityBonuses.enabled = (gs.activityBonuses.enabled == true)
    gs.activityBonuses.recruitmentBonus = tonumber(gs.activityBonuses.recruitmentBonus) or 0
    gs.activityBonuses.newMemberBonus = tonumber(gs.activityBonuses.newMemberBonus) or 0
    gs.activityBonuses.traderSalesBonus = (gs.activityBonuses.traderSalesBonus == true)
    gs.activityBonuses.traderSalesPer = tonumber(gs.activityBonuses.traderSalesPer) or 0
    gs.activityBonuses.eventParticipation = tonumber(gs.activityBonuses.eventParticipation) or 0
    gs.activityBonuses.longevityBonus = tonumber(gs.activityBonuses.longevityBonus) or 0

    if type(gs.prizeConfig) ~= "table" then gs.prizeConfig = {} end
    gs.prizeConfig.poolPercentage = tonumber(gs.prizeConfig.poolPercentage) or 100
    gs.prizeConfig.numWinners = tonumber(gs.prizeConfig.numWinners) or 1
    gs.prizeConfig.distribution = type(gs.prizeConfig.distribution) == "string" and gs.prizeConfig.distribution or "equal"
    gs.prizeConfig.progressiveJackpot = (gs.prizeConfig.progressiveJackpot == true)
    gs.prizeConfig.jackpotAmount = math.max(0, tonumber(gs.prizeConfig.jackpotAmount) or 0)
    if type(gs.prizeConfig.tieredSplit) ~= "table" then gs.prizeConfig.tieredSplit = {50, 30, 20} end
    if type(gs.prizeConfig.epicPrizeThresholds) ~= "table" then gs.prizeConfig.epicPrizeThresholds = {} end

    if type(gs.entryRules) ~= "table" then gs.entryRules = {} end
    gs.entryRules.maxTickets = math.max(0, tonumber(gs.entryRules.maxTickets) or 0)
    gs.entryRules.minTickets = math.max(0, tonumber(gs.entryRules.minTickets) or 0)
    gs.entryRules.winnerCooldown = math.max(0, tonumber(gs.entryRules.winnerCooldown) or 0)
    gs.entryRules.mustBeOnline = (gs.entryRules.mustBeOnline == true)
    gs.entryRules.onlineThresholdDays = math.max(1, tonumber(gs.entryRules.onlineThresholdDays) or 7)
    if type(gs.entryRules.excludedRanks) ~= "table" then gs.entryRules.excludedRanks = {} end

    gs.rafflePeriodId = type(gs.rafflePeriodId) == "string" and gs.rafflePeriodId or "all"
    gs.raffleType = (gs.raffleType == "5050") and "5050" or "gold"
    gs.useTicketPacks = (gs.useTicketPacks == true)
    gs.simpleTicketPrice = math.max(1, tonumber(gs.simpleTicketPrice) or 1000)
    gs.duesAmount = math.max(0, tonumber(gs.duesAmount) or 5000)
    gs.lastScanTime = tonumber(gs.lastScanTime) or 0

    return gs
end

local function GetRaffleGuildSettings(guildId)
    if guildId == 0 then
        if not NWT.Raffle.demoSettings then
            NWT.Raffle.demoSettings = GetDefaultRaffleSettings()
            NWT.Raffle.demoSettings.rankBonuses.ranks = {
                [1] = { freeTickets = 10, multiplier = 2.0, weeklyAllowance = 250 },
                [2] = { freeTickets = 5, multiplier = 1.5, weeklyAllowance = 100 },
                [3] = { freeTickets = 2, multiplier = 1.25, weeklyAllowance = 50 },
                [4] = { freeTickets = 0, multiplier = 1.0, weeklyAllowance = 0 },
                [5] = { freeTickets = 0, multiplier = 1.0, weeklyAllowance = 0 },
            }
        end
        NWT.Raffle.demoSettings = NormalizeRaffleGuildSettings(NWT.Raffle.demoSettings)
        return NWT.Raffle.demoSettings
    end
    local sv = NWT.savedVars
    if type(sv.bookkeeper) ~= "table" then sv.bookkeeper = {} end
    if type(sv.bookkeeper.guilds) ~= "table" then sv.bookkeeper.guilds = {} end
    if type(sv.bookkeeper.guilds[guildId]) ~= "table" then
        sv.bookkeeper.guilds[guildId] = GetDefaultRaffleSettings()
    end
    local gs = NormalizeRaffleGuildSettings(sv.bookkeeper.guilds[guildId])
    sv.bookkeeper.guilds[guildId] = gs
    return gs
end

local function IsRaffleGuildFavorite(guildId)
    local sv = NWT.savedVars
    if type(sv.bookkeeper) ~= "table" then sv.bookkeeper = {} end
    if type(sv.bookkeeper.raffleFavoriteGuilds) ~= "table" then sv.bookkeeper.raffleFavoriteGuilds = {} end
    return sv.bookkeeper.raffleFavoriteGuilds[guildId] == true
end

local function ToggleRaffleGuildFavorite(guildId)
    local sv = NWT.savedVars
    if type(sv.bookkeeper) ~= "table" then sv.bookkeeper = {} end
    if type(sv.bookkeeper.raffleFavoriteGuilds) ~= "table" then sv.bookkeeper.raffleFavoriteGuilds = {} end
    sv.bookkeeper.raffleFavoriteGuilds[guildId] = not sv.bookkeeper.raffleFavoriteGuilds[guildId]
    return sv.bookkeeper.raffleFavoriteGuilds[guildId]
end

local function GetDemoRankBonus(memberData, gs)
    if not gs.rankBonuses or not gs.rankBonuses.enabled then
        return 0, 1.0, 0
    end
    local rankBonus = gs.rankBonuses.ranks[memberData.rankIndex]
    if rankBonus then
        return rankBonus.freeTickets or 0, rankBonus.multiplier or 1.0, rankBonus.weeklyAllowance or 0
    end
    return 0, 1.0, 0
end

local function GetDemoActivityBonuses(memberData, gs)
    if not gs.activityBonuses or not gs.activityBonuses.enabled then
        return 0
    end
    local bonusTickets = 0
    local ab = gs.activityBonuses
    if ab.longevityBonus and ab.longevityBonus > 0 then bonusTickets = bonusTickets + (memberData.monthsInGuild * ab.longevityBonus) end
    if ab.newMemberBonus and ab.newMemberBonus > 0 and memberData.isNew then bonusTickets = bonusTickets + ab.newMemberBonus end
    if ab.recruitmentBonus and ab.recruitmentBonus > 0 then bonusTickets = bonusTickets + (memberData.recruits * ab.recruitmentBonus) end
    if ab.traderSalesBonus and ab.traderSalesPer and ab.traderSalesPer > 0 then bonusTickets = bonusTickets + math.floor(memberData.traderSales / ab.traderSalesPer) end
    return bonusTickets
end

local function IsDoubleTicketDeposit(timestamp, gs)
    if not gs.doubleTicketStartTime or not gs.doubleTicketEndTime then return false end
    return timestamp >= gs.doubleTicketStartTime and timestamp <= gs.doubleTicketEndTime
end

local function CalculateTicketsFromDeposit(amount, gs, depositTimestamp)
    local baseTickets = 0
    if not gs.useTicketPacks then
        local price = gs.simpleTicketPrice or 1000
        baseTickets = math.floor(amount / price)
    else
        local lastDigit = amount % 10
        for _, pack in ipairs(gs.ticketPacks or {}) do
            if pack.suffix == lastDigit then
                local baseAmount = amount - pack.suffix
                local basePrice = pack.price - pack.suffix
                if basePrice > 0 and baseAmount > 0 and (baseAmount % basePrice) == 0 then
                    baseTickets = (baseAmount / basePrice) * pack.tickets
                    break
                end
            end
        end
    end
    if depositTimestamp and IsDoubleTicketDeposit(depositTimestamp, gs) then
        baseTickets = baseTickets * 2
    end
    return baseTickets
end

local function GetRankBonus(guildId, memberName, gs)
    if not gs.rankBonuses or not gs.rankBonuses.enabled or not gs.rankBonuses.ranks then
        return 0, 1.0, 0
    end
    local searchName = memberName
    if not searchName:find("^@") then searchName = "@" .. searchName end
    local numMembers = GetNumGuildMembers(guildId)
    for i = 1, numMembers do
        local name, _, rankIndex = GetGuildMemberInfo(guildId, i)
        if name and not name:find("^@") then name = "@" .. name end
        if name == searchName then
            local rankBonus = gs.rankBonuses.ranks[rankIndex]
            if rankBonus then
                return rankBonus.freeTickets or 0, rankBonus.multiplier or 1.0, rankBonus.weeklyAllowance or 0
            end
            break
        end
    end
    return 0, 1.0, 0
end

local function IsMemberExcluded(guildId, memberName, gs)
    local searchName = memberName
    if not searchName:find("^@") then searchName = "@" .. searchName end
    local numMembers = GetNumGuildMembers(guildId)
    for i = 1, numMembers do
        local name, _, rankIndex, _, lastOnline = GetGuildMemberInfo(guildId, i)
        if name and not name:find("^@") then name = "@" .. name end
        if name == searchName then
            if gs.raffleExemptRanks and gs.raffleExemptRanks[rankIndex] then return true end
            if gs.entryRules then
                for _, excludedRank in ipairs(gs.entryRules.excludedRanks or {}) do
                    if rankIndex == excludedRank then return true end
                end
                if gs.entryRules.mustBeOnline then
                    local daysSinceOnline = (GetTimeStamp() - lastOnline) / 86400
                    if daysSinceOnline > (gs.entryRules.onlineThresholdDays or 7) then return true end
                end
            end
            break
        end
    end
    if gs.entryRules and gs.entryRules.winnerCooldown and gs.entryRules.winnerCooldown > 0 then
        local cooldownSeconds = gs.entryRules.winnerCooldown * 7 * 86400
        for _, winner in ipairs(gs.pastWinners or {}) do
            if winner.name == memberName and (GetTimeStamp() - winner.timestamp) < cooldownSeconds then
                return true
            end
        end
    end
    return false
end

local function GetActivityBonusTickets(guildId, memberName, gs)
    if not gs.activityBonuses or not gs.activityBonuses.enabled then return 0 end
    local bonusTickets = 0
    local ab = gs.activityBonuses
    local memberData = gs.memberPayments and gs.memberPayments[memberName]
    if ab.longevityBonus and ab.longevityBonus > 0 and memberData then
        local joinTime = memberData.firstSeen or GetTimeStamp()
        local monthsInGuild = math.floor((GetTimeStamp() - joinTime) / (30 * 86400))
        bonusTickets = bonusTickets + (monthsInGuild * ab.longevityBonus)
    end
    if ab.newMemberBonus and ab.newMemberBonus > 0 and memberData then
        local joinTime = memberData.firstSeen or 0
        if ((GetTimeStamp() - joinTime) / 86400) <= 30 then bonusTickets = bonusTickets + ab.newMemberBonus end
    end
    if ab.recruitmentBonus and ab.recruitmentBonus > 0 and memberData then
        bonusTickets = bonusTickets + ((memberData.recruitsThisPeriod or 0) * ab.recruitmentBonus)
    end
    if ab.traderSalesBonus and ab.traderSalesPer and ab.traderSalesPer > 0 and memberData then
        bonusTickets = bonusTickets + math.floor((memberData.traderSalesThisPeriod or 0) / ab.traderSalesPer)
    end
    return bonusTickets
end

local function RecordWinner(gs, winnerName)
    if not gs.pastWinners then gs.pastWinners = {} end
    local maxCooldown = 4 * 7 * 86400
    local now = GetTimeStamp()
    local newList = {}
    for _, w in ipairs(gs.pastWinners) do
        if (now - w.timestamp) < maxCooldown then table.insert(newList, w) end
    end
    table.insert(newList, { name = winnerName, timestamp = now })
    gs.pastWinners = newList
end

local function CalculatePrizeDistribution(totalPot, gs)
    local pc = gs.prizeConfig or {}
    local numWinners = pc.numWinners or 1
    local poolPct = (pc.poolPercentage or 100) / 100
    local distribution = pc.distribution or "equal"
    if gs.raffleType == "5050" then
        local prizePool5050 = math.floor(totalPot * 0.5) + (pc.jackpotAmount or 0)
        return { prizePool5050 }, prizePool5050
    end
    local prizePool = math.floor(totalPot * poolPct)
    local prizes = {}
    if distribution == "equal" then
        local perWinner = math.floor(prizePool / numWinners)
        for i = 1, numWinners do prizes[i] = perWinner end
    elseif distribution == "tiered" then
        local splits = pc.tieredSplit or {50, 30, 20}
        for i = 1, numWinners do
            local pct = splits[i] or splits[#splits] or (100 / numWinners)
            prizes[i] = math.floor(prizePool * (pct / 100))
        end
    else
        local perWinner = math.floor(prizePool / numWinners)
        for i = 1, numWinners do prizes[i] = perWinner end
    end
    return prizes, prizePool
end

local function UpdateJackpot(gs, wasWon, potAmount)
    if not gs.prizeConfig then gs.prizeConfig = {} end
    if gs.prizeConfig.progressiveJackpot then
        if wasWon then
            local jackpotWon = gs.prizeConfig.jackpotAmount or 0
            gs.prizeConfig.jackpotAmount = 0
            return jackpotWon
        end
        gs.prizeConfig.jackpotAmount = (gs.prizeConfig.jackpotAmount or 0) + math.floor(potAmount * 0.03)
    end
    return 0
end

local function GetCurrentTraderFlipStart()
    local now = GetTimeStamp()
    local flipDay = 3
    local daysSinceEpoch = math.floor(now / 86400)
    local dayOfWeek = ((daysSinceEpoch + 4) % 7) + 1
    local daysSinceFlip = (dayOfWeek - flipDay) % 7
    local flipTimestamp = now - (daysSinceFlip * 86400)
    return flipTimestamp - (flipTimestamp % 86400)
end

local function GetRafflePeriodPresets()
    local now = GetTimeStamp()
    local flipStart = GetCurrentTraderFlipStart()
    local lastFlipStart = flipStart - (7 * 86400)
    return {
        { id = "thisWeek", label = "This Week", startTime = flipStart, endTime = now },
        { id = "lastWeek", label = "Last Week", startTime = lastFlipStart, endTime = flipStart },
        { id = "twoWeeks", label = "2 Weeks", startTime = lastFlipStart, endTime = now },
        { id = "month", label = "30 Days", startTime = now - (30 * 86400), endTime = now },
        { id = "sixtyDays", label = "60 Days", startTime = now - (60 * 86400), endTime = now },
        { id = "ninety", label = "90 Days", startTime = now - (90 * 86400), endTime = now },
        { id = "all", label = "All Time", startTime = 0, endTime = now },
        { id = "custom", label = "Custom...", startTime = 0, endTime = now },
    }
end

local function FormatRafflePeriod(gs)
    if not gs then return "All Time" end
    local periodId = gs.rafflePeriodId or "all"
    if periodId == "custom" and gs.customRaffleStart and gs.customRaffleEnd then
        return os.date("%m/%d", gs.customRaffleStart) .. " - " .. os.date("%m/%d", gs.customRaffleEnd)
    end
    for _, p in ipairs(GetRafflePeriodPresets()) do
        if p.id == periodId then return p.label end
    end
    return "All Time"
end

local function GetRafflePeriodTimes(gs)
    if not gs then return 0, GetTimeStamp() end
    local periodId = gs.rafflePeriodId or "all"
    if periodId == "custom" and gs.customRaffleStart and gs.customRaffleEnd then
        return gs.customRaffleStart, gs.customRaffleEnd
    end
    for _, p in ipairs(GetRafflePeriodPresets()) do
        if p.id == periodId then return p.startTime, p.endTime end
    end
    return 0, GetTimeStamp()
end

local function ParseDepositType(amount, guildSettings)
    local duesAmount = guildSettings.duesAmount or 5000
    local lastDigit = amount % 10
    for _, suffix in ipairs(guildSettings.raffleSuffixes or {}) do
        local suffixNum = tonumber(suffix) or suffix
        if lastDigit == suffixNum then return "raffle", amount end
    end
    if duesAmount > 0 and amount >= duesAmount then
        local months = math.floor(amount / duesAmount)
        if (amount % duesAmount) == 0 then return "dues", months end
    end
    if duesAmount > 0 and math.abs(amount - duesAmount) <= 500 then return "dues", 1 end
    return "other", amount
end

NWT.RaffleData_IsGuildEnabled = IsGuildEnabled
NWT.RaffleData_GetDefaultSettings = GetDefaultRaffleSettings
NWT.RaffleData_GetGuildSettings = GetRaffleGuildSettings
NWT.RaffleData_IsGuildFavorite = IsRaffleGuildFavorite
NWT.RaffleData_ToggleGuildFavorite = ToggleRaffleGuildFavorite
NWT.RaffleData_GetDemoRankBonus = GetDemoRankBonus
NWT.RaffleData_GetDemoActivityBonuses = GetDemoActivityBonuses
NWT.RaffleData_IsDoubleTicketDeposit = IsDoubleTicketDeposit
NWT.RaffleData_CalculateTicketsFromDeposit = CalculateTicketsFromDeposit
NWT.RaffleData_GetRankBonus = GetRankBonus
NWT.RaffleData_IsMemberExcluded = IsMemberExcluded
NWT.RaffleData_GetActivityBonusTickets = GetActivityBonusTickets
NWT.RaffleData_RecordWinner = RecordWinner
NWT.RaffleData_CalculatePrizeDistribution = CalculatePrizeDistribution
NWT.RaffleData_UpdateJackpot = UpdateJackpot
NWT.RaffleData_GetCurrentTraderFlipStart = GetCurrentTraderFlipStart
NWT.RaffleData_GetPeriodPresets = GetRafflePeriodPresets
NWT.RaffleData_FormatPeriod = FormatRafflePeriod
NWT.RaffleData_GetPeriodTimes = GetRafflePeriodTimes
NWT.RaffleData_ParseDepositType = ParseDepositType
