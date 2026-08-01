-- ============================================
-- GUILD RAFFLE MODULE (Standalone)
-- ============================================

NWT.Raffle = {
    isOpen = false,
    sceneInitialized = false,
    selectedGuildIndex = 1,
    viewingGuildIndex = 1,
    raffleScrollOffset = 0,
    maxVisibleRaffle = 15,
    focusPanel = "guilds",  -- "guilds" or "entries"
    raffleEntriesCount = 0,
    sortedEntries = {},
    demoSettings = nil,  -- Persistent demo settings
}

-- Demo mode fake member data with varied characteristics
local DEMO_MEMBERS = {
    { name = "@LuckyDragon42", baseDeposit = 47000, rankIndex = 1, monthsInGuild = 24, isNew = false, recruits = 3, traderSales = 500000 },
    { name = "@GoldHoarder", baseDeposit = 35000, rankIndex = 2, monthsInGuild = 18, isNew = false, recruits = 2, traderSales = 350000 },
    { name = "@RaffleKing", baseDeposit = 28000, rankIndex = 3, monthsInGuild = 12, isNew = false, recruits = 1, traderSales = 200000 },
    { name = "@TamrielTrader", baseDeposit = 22000, rankIndex = 2, monthsInGuild = 6, isNew = false, recruits = 0, traderSales = 800000 },
    { name = "@CrownCollector", baseDeposit = 18000, rankIndex = 4, monthsInGuild = 3, isNew = false, recruits = 1, traderSales = 150000 },
    { name = "@DwemerDelver", baseDeposit = 15000, rankIndex = 5, monthsInGuild = 2, isNew = false, recruits = 0, traderSales = 50000 },
    { name = "@NightbladeNinja", baseDeposit = 12000, rankIndex = 3, monthsInGuild = 8, isNew = false, recruits = 0, traderSales = 100000 },
    { name = "@SorcSupreme", baseDeposit = 10000, rankIndex = 4, monthsInGuild = 1, isNew = true, recruits = 0, traderSales = 25000 },
    { name = "@TemplarTitan", baseDeposit = 8000, rankIndex = 5, monthsInGuild = 10, isNew = false, recruits = 2, traderSales = 75000 },
    { name = "@DragonKnight99", baseDeposit = 7000, rankIndex = 5, monthsInGuild = 4, isNew = false, recruits = 0, traderSales = 60000 },
    { name = "@NecroNomad", baseDeposit = 6000, rankIndex = 5, monthsInGuild = 0, isNew = true, recruits = 0, traderSales = 10000 },
    { name = "@WardenWolf", baseDeposit = 5000, rankIndex = 4, monthsInGuild = 14, isNew = false, recruits = 1, traderSales = 120000 },
    { name = "@FishingFanatic", baseDeposit = 4000, rankIndex = 5, monthsInGuild = 5, isNew = false, recruits = 0, traderSales = 30000 },
    { name = "@CraftMaster", baseDeposit = 3000, rankIndex = 5, monthsInGuild = 7, isNew = false, recruits = 0, traderSales = 200000 },
    { name = "@PvPChampion", baseDeposit = 3000, rankIndex = 3, monthsInGuild = 9, isNew = false, recruits = 0, traderSales = 40000 },
    { name = "@TrialRunner", baseDeposit = 2000, rankIndex = 5, monthsInGuild = 11, isNew = false, recruits = 0, traderSales = 80000 },
    { name = "@HousingStar", baseDeposit = 2000, rankIndex = 5, monthsInGuild = 2, isNew = false, recruits = 0, traderSales = 15000 },
    { name = "@MotifHunter", baseDeposit = 1000, rankIndex = 5, monthsInGuild = 1, isNew = true, recruits = 0, traderSales = 5000 },
    { name = "@SetCollector", baseDeposit = 1000, rankIndex = 5, monthsInGuild = 3, isNew = false, recruits = 0, traderSales = 20000 },
    { name = "@GuildLeader", baseDeposit = 1000, rankIndex = 1, monthsInGuild = 36, isNew = false, recruits = 5, traderSales = 100000 },
}

-- Demo rank names
local DEMO_RANKS = {
    [1] = "Guild Master",
    [2] = "Officer",
    [3] = "Veteran",
    [4] = "Member",
    [5] = "Initiate",
}

-- ============================================
-- SHARED UTILITY FUNCTIONS
-- ============================================

local function IsGuildEnabled(guildId)
    local sv = NWT.savedVars
    if not sv.bookkeeper then sv.bookkeeper = {} end
    if not sv.bookkeeper.enabledGuilds then sv.bookkeeper.enabledGuilds = {} end
    if sv.bookkeeper.enabledGuilds[guildId] == nil then
        sv.bookkeeper.enabledGuilds[guildId] = true
    end
    return sv.bookkeeper.enabledGuilds[guildId]
end

local function GetDefaultRaffleSettings()
    return {
        -- Basic Settings
        duesAmount = 5000,
        raffleSuffixes = {1},
        rafflePeriodId = "all",
        lastScanTime = 0,
        memberPayments = {},
        
        -- Ticket Packs (price -> tickets mapping)
        ticketPacks = {
            { price = 1001, tickets = 1, suffix = 1 },  -- 1001g = 1 ticket
        },
        useTicketPacks = false,  -- false = simple price mode, true = pack mode
        simpleTicketPrice = 1000,  -- used when useTicketPacks = false
        
        -- Rank Bonuses
        rankBonuses = {
            enabled = false,
            -- Format: [rankIndex] = { freeTickets = X, multiplier = Y }
            -- Ranks: 1=Guild Master, 2=usually Officer, etc.
            ranks = {},
        },
        
        -- Activity Bonuses
        activityBonuses = {
            enabled = false,
            recruitmentBonus = 0,       -- tickets for recruiting
            newMemberBonus = 0,         -- tickets for new members
            traderSalesBonus = false,   -- bonus based on trader sales
            traderSalesPer = 0,         -- tickets per X gold in sales
            eventParticipation = 0,     -- tickets for event attendance
            longevityBonus = 0,         -- tickets per month of membership
        },
        
        -- Prize Configuration
        prizeConfig = {
            poolPercentage = 100,       -- % of pot for prizes
            numWinners = 1,             -- number of winners
            distribution = "equal",     -- "equal", "tiered", "custom"
            tieredSplit = {50, 30, 20}, -- for tiered distribution
            progressiveJackpot = false, -- rollover pot
            jackpotAmount = 0,          -- current jackpot
            epicPrizeThresholds = {},   -- {amount = X, prize = "description"}
        },
        
        -- Entry Limits & Rules
        entryRules = {
            maxTickets = 0,             -- 0 = unlimited
            minTickets = 0,             -- 0 = no minimum
            winnerCooldown = 0,         -- weeks winner must wait
            mustBeOnline = false,       -- require recent activity
            onlineThresholdDays = 7,    -- days since last online
            excludedRanks = {},         -- rank indices excluded
        },
        
        -- Special Raffle Types
        raffleType = "gold",            -- "gold", "items", "mixed", "5050"
        itemPrizes = {},                -- list of item prizes
    }
end

local function GetRaffleGuildSettings(guildId)
    -- Demo mode: use persistent demo settings
    if guildId == 0 then
        if not NWT.Raffle.demoSettings then
            NWT.Raffle.demoSettings = GetDefaultRaffleSettings()
            -- Pre-configure some demo rank bonuses
            NWT.Raffle.demoSettings.rankBonuses.ranks = {
                [1] = { freeTickets = 10, multiplier = 2.0, weeklyAllowance = 250 },  -- Guild Master
                [2] = { freeTickets = 5, multiplier = 1.5, weeklyAllowance = 100 },   -- Officer
                [3] = { freeTickets = 2, multiplier = 1.25, weeklyAllowance = 50 },   -- Veteran
                [4] = { freeTickets = 0, multiplier = 1.0, weeklyAllowance = 0 },     -- Member
                [5] = { freeTickets = 0, multiplier = 1.0, weeklyAllowance = 0 },     -- Initiate
            }
        end
        return NWT.Raffle.demoSettings
    end
    
    local sv = NWT.savedVars
    if not sv.bookkeeper then sv.bookkeeper = {} end
    if not sv.bookkeeper.guilds then sv.bookkeeper.guilds = {} end
    if not sv.bookkeeper.guilds[guildId] then
        sv.bookkeeper.guilds[guildId] = GetDefaultRaffleSettings()
    end
    -- Migrate old settings to new structure
    local gs = sv.bookkeeper.guilds[guildId]
    if not gs.ticketPacks then
        local defaults = GetDefaultRaffleSettings()
        for k, v in pairs(defaults) do
            if gs[k] == nil then gs[k] = v end
        end
        -- Migrate old ticketPrice to simpleTicketPrice
        if gs.ticketPrice then
            gs.simpleTicketPrice = gs.ticketPrice
        end
    end
    return gs
end

local function IsRaffleGuildFavorite(guildId)
    local sv = NWT.savedVars
    if not sv.bookkeeper then sv.bookkeeper = {} end
    if not sv.bookkeeper.raffleFavoriteGuilds then sv.bookkeeper.raffleFavoriteGuilds = {} end
    return sv.bookkeeper.raffleFavoriteGuilds[guildId] == true
end

local function ToggleRaffleGuildFavorite(guildId)
    local sv = NWT.savedVars
    if not sv.bookkeeper then sv.bookkeeper = {} end
    if not sv.bookkeeper.raffleFavoriteGuilds then sv.bookkeeper.raffleFavoriteGuilds = {} end
    sv.bookkeeper.raffleFavoriteGuilds[guildId] = not sv.bookkeeper.raffleFavoriteGuilds[guildId]
    return sv.bookkeeper.raffleFavoriteGuilds[guildId]
end

-- Get demo rank bonus (uses DEMO_MEMBERS data)
-- Returns: freeTickets, multiplier, weeklyAllowance
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

-- Get demo activity bonuses
local function GetDemoActivityBonuses(memberData, gs)
    if not gs.activityBonuses or not gs.activityBonuses.enabled then
        return 0
    end
    
    local bonusTickets = 0
    local ab = gs.activityBonuses
    
    -- Longevity bonus
    if ab.longevityBonus and ab.longevityBonus > 0 then
        bonusTickets = bonusTickets + (memberData.monthsInGuild * ab.longevityBonus)
    end
    
    -- New member bonus
    if ab.newMemberBonus and ab.newMemberBonus > 0 and memberData.isNew then
        bonusTickets = bonusTickets + ab.newMemberBonus
    end
    
    -- Recruitment bonus
    if ab.recruitmentBonus and ab.recruitmentBonus > 0 then
        bonusTickets = bonusTickets + (memberData.recruits * ab.recruitmentBonus)
    end
    
    -- Trader sales bonus
    if ab.traderSalesBonus and ab.traderSalesPer and ab.traderSalesPer > 0 then
        local salesTickets = math.floor(memberData.traderSales / ab.traderSalesPer)
        bonusTickets = bonusTickets + salesTickets
    end
    
    return bonusTickets
end

-- Check if a deposit timestamp falls within a double ticket session
local function IsDoubleTicketDeposit(timestamp, gs)
    if not gs.doubleTicketStartTime or not gs.doubleTicketEndTime then return false end
    return timestamp >= gs.doubleTicketStartTime and timestamp <= gs.doubleTicketEndTime
end

-- Calculate tickets from a deposit amount using ticket packs or simple pricing
local function CalculateTicketsFromDeposit(amount, gs, depositTimestamp)
    local baseTickets = 0
    
    if not gs.useTicketPacks then
        -- Simple mode: tickets = floor(amount / price)
        local price = gs.simpleTicketPrice or 1000
        baseTickets = math.floor(amount / price)
    else
        -- Ticket pack mode: find matching pack by suffix
        -- Pack price includes suffix (e.g., 10,001 = 10,000 base + suffix 1)
        local lastDigit = amount % 10
        for _, pack in ipairs(gs.ticketPacks or {}) do
            if pack.suffix == lastDigit then
                -- Suffix matches - remove suffix and check if base amount is exact multiple of base price
                local baseAmount = amount - pack.suffix
                local basePrice = pack.price - pack.suffix
                if basePrice > 0 and baseAmount > 0 and (baseAmount % basePrice) == 0 then
                    local packCount = baseAmount / basePrice
                    baseTickets = packCount * pack.tickets
                    break
                end
            end
        end
    end
    
    -- Apply double ticket multiplier if deposit was during active session
    if depositTimestamp and IsDoubleTicketDeposit(depositTimestamp, gs) then
        baseTickets = baseTickets * 2
    end
    
    return baseTickets
end

-- Get rank bonus for a member
-- Returns: freeTickets, multiplier, weeklyAllowance
local function GetRankBonus(guildId, memberName, gs)
    if not gs.rankBonuses then
        return 0, 1.0, 0
    end
    if not gs.rankBonuses.enabled then
        return 0, 1.0, 0  -- no free tickets, 1x multiplier, no weekly allowance
    end
    if not gs.rankBonuses.ranks then
        return 0, 1.0, 0
    end
    
    -- Normalize member name for comparison
    local searchName = memberName
    if not searchName:find("^@") then searchName = "@" .. searchName end
    
    local numMembers = GetNumGuildMembers(guildId)
    for i = 1, numMembers do
        local name, _, rankIndex = GetGuildMemberInfo(guildId, i)
        -- Normalize guild member name
        if name and not name:find("^@") then name = "@" .. name end
        if name == searchName then
            local rankBonus = gs.rankBonuses.ranks[rankIndex]
            if rankBonus then
                local ft = rankBonus.freeTickets or 0
                local mult = rankBonus.multiplier or 1.0
                local wa = rankBonus.weeklyAllowance or 0
                return ft, mult, wa
            end
            break
        end
    end
    return 0, 1.0, 0
end

-- Check if member is excluded from raffle
local function IsMemberExcluded(guildId, memberName, gs)
    -- Normalize member name for comparison
    local searchName = memberName
    if not searchName:find("^@") then searchName = "@" .. searchName end
    
    local numMembers = GetNumGuildMembers(guildId)
    for i = 1, numMembers do
        local name, _, rankIndex, _, lastOnline = GetGuildMemberInfo(guildId, i)
        -- Normalize guild member name
        if name and not name:find("^@") then name = "@" .. name end
        if name == searchName then
            -- Check raffle-specific rank exemption
            if gs.raffleExemptRanks and gs.raffleExemptRanks[rankIndex] then
                return true
            end
            
            -- Check rank exclusion from entry rules
            if gs.entryRules then
                for _, excludedRank in ipairs(gs.entryRules.excludedRanks or {}) do
                    if rankIndex == excludedRank then return true end
                end
                
                -- Check online requirement
                if gs.entryRules.mustBeOnline then
                    local daysSinceOnline = (GetTimeStamp() - lastOnline) / 86400
                    if daysSinceOnline > (gs.entryRules.onlineThresholdDays or 7) then
                        return true
                    end
                end
            end
            break
        end
    end
    
    -- Check winner cooldown
    if gs.entryRules and gs.entryRules.winnerCooldown and gs.entryRules.winnerCooldown > 0 then
        local cooldownSeconds = gs.entryRules.winnerCooldown * 7 * 86400  -- weeks to seconds
        local pastWinners = gs.pastWinners or {}
        for _, winner in ipairs(pastWinners) do
            if winner.name == memberName then
                if (GetTimeStamp() - winner.timestamp) < cooldownSeconds then
                    return true  -- Still in cooldown
                end
            end
        end
    end
    
    return false
end

-- Calculate activity bonuses for a member
local function GetActivityBonusTickets(guildId, memberName, gs)
    if not gs.activityBonuses or not gs.activityBonuses.enabled then
        return 0
    end
    
    local bonusTickets = 0
    local ab = gs.activityBonuses
    local memberData = gs.memberPayments and gs.memberPayments[memberName]
    
    -- Longevity bonus: tickets per month of membership
    if ab.longevityBonus and ab.longevityBonus > 0 and memberData then
        local joinTime = memberData.firstSeen or GetTimeStamp()
        local monthsInGuild = math.floor((GetTimeStamp() - joinTime) / (30 * 86400))
        bonusTickets = bonusTickets + (monthsInGuild * ab.longevityBonus)
    end
    
    -- New member bonus
    if ab.newMemberBonus and ab.newMemberBonus > 0 and memberData then
        local joinTime = memberData.firstSeen or 0
        local daysInGuild = (GetTimeStamp() - joinTime) / 86400
        if daysInGuild <= 30 then  -- New within 30 days
            bonusTickets = bonusTickets + ab.newMemberBonus
        end
    end
    
    -- Recruitment bonus (tracked separately in memberData.recruits)
    if ab.recruitmentBonus and ab.recruitmentBonus > 0 and memberData then
        local recruits = memberData.recruitsThisPeriod or 0
        bonusTickets = bonusTickets + (recruits * ab.recruitmentBonus)
    end
    
    -- Trader sales bonus
    if ab.traderSalesBonus and ab.traderSalesPer and ab.traderSalesPer > 0 and memberData then
        local salesThisPeriod = memberData.traderSalesThisPeriod or 0
        local salesTickets = math.floor(salesThisPeriod / ab.traderSalesPer)
        bonusTickets = bonusTickets + salesTickets
    end
    
    return bonusTickets
end

-- Record a winner for cooldown tracking
local function RecordWinner(gs, winnerName)
    if not gs.pastWinners then gs.pastWinners = {} end
    
    -- Remove old entries (older than max cooldown)
    local maxCooldown = 4 * 7 * 86400  -- 4 weeks max
    local now = GetTimeStamp()
    local newList = {}
    for _, w in ipairs(gs.pastWinners) do
        if (now - w.timestamp) < maxCooldown then
            table.insert(newList, w)
        end
    end
    
    -- Add new winner
    table.insert(newList, { name = winnerName, timestamp = now })
    gs.pastWinners = newList
end

-- Calculate prize distribution for multiple winners
local function CalculatePrizeDistribution(totalPot, gs)
    local pc = gs.prizeConfig or {}
    local numWinners = pc.numWinners or 1
    local poolPct = (pc.poolPercentage or 100) / 100
    local distribution = pc.distribution or "equal"
    
    -- Handle 50/50 raffle type - winner gets 50% of pot + starting jackpot
    if gs.raffleType == "5050" then
        local startingJackpot = (pc.jackpotAmount or 0)
        local prizePool = math.floor(totalPot * 0.5) + startingJackpot
        return {prizePool}, prizePool  -- Single winner gets 50% + starting amount
    end
    
    local prizePool = math.floor(totalPot * poolPct)
    local prizes = {}
    
    if distribution == "equal" then
        local perWinner = math.floor(prizePool / numWinners)
        for i = 1, numWinners do
            prizes[i] = perWinner
        end
    elseif distribution == "tiered" then
        local splits = pc.tieredSplit or {50, 30, 20}
        for i = 1, numWinners do
            local pct = splits[i] or splits[#splits] or (100 / numWinners)
            prizes[i] = math.floor(prizePool * (pct / 100))
        end
    else  -- custom or fallback
        local perWinner = math.floor(prizePool / numWinners)
        for i = 1, numWinners do
            prizes[i] = perWinner
        end
    end
    
    return prizes, prizePool
end

-- Handle progressive jackpot
local function UpdateJackpot(gs, wasWon, potAmount)
    if not gs.prizeConfig then gs.prizeConfig = {} end
    
    if gs.prizeConfig.progressiveJackpot then
        if wasWon then
            -- Reset jackpot after win
            local jackpotWon = gs.prizeConfig.jackpotAmount or 0
            gs.prizeConfig.jackpotAmount = 0
            return jackpotWon
        else
            -- Add percentage to jackpot (3% of pot)
            local addition = math.floor(potAmount * 0.03)
            gs.prizeConfig.jackpotAmount = (gs.prizeConfig.jackpotAmount or 0) + addition
            return 0
        end
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
        local startStr = os.date("%m/%d", gs.customRaffleStart)
        local endStr = os.date("%m/%d", gs.customRaffleEnd)
        return startStr .. " - " .. endStr
    end
    local presets = GetRafflePeriodPresets()
    for _, p in ipairs(presets) do
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
    local presets = GetRafflePeriodPresets()
    for _, p in ipairs(presets) do
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
        local remainder = amount % duesAmount
        if remainder == 0 then return "dues", months end
    end
    if duesAmount > 0 and math.abs(amount - duesAmount) <= 500 then return "dues", 1 end
    return "other", amount
end

-- ============================================
-- RAFFLE ENTRIES BUILDING
-- ============================================

function NWT.BuildRaffleEntries(guildId)
    local rf = NWT.Raffle
    local gs
    if guildId == 0 then
        gs = GetRaffleGuildSettings(0)  -- Use demo settings, not fresh defaults
    else
        gs = GetRaffleGuildSettings(guildId)
    end
    local startTime, endTime = GetRafflePeriodTimes(gs)
    
    rf.sortedEntries = {}
    local totalTickets = 0
    local totalGold = 0
    
    -- Build list of guilds to process (primary + linked)
    local guildsToProcess = { { guildId = guildId, gs = gs } }
    if gs.linkedGuilds then
        for linkedGuildId, isLinked in pairs(gs.linkedGuilds) do
            if isLinked and linkedGuildId ~= guildId then
                local linkedGs = GetRaffleGuildSettings(linkedGuildId)
                table.insert(guildsToProcess, { guildId = linkedGuildId, gs = linkedGs })
            end
        end
    end
    
    -- Combined entries by player name
    local combinedEntries = {}
    
    -- Process each guild
    for _, guildData in ipairs(guildsToProcess) do
        local processGuildId = guildData.guildId
        local processGs = guildData.gs
        
        local guildName = processGuildId > 0 and GetGuildName(processGuildId) or "Test Guild"
        
        for name, m in pairs(processGs.memberPayments or {}) do
            if m.isCurrentMember and m.deposits then
                -- Check if member is excluded (use primary guild settings for exclusions)
                if not IsMemberExcluded(processGuildId, name, processGs) then
                    local memberRaffle = 0
                    local depositCount = 0
                    local lastDeposit = 0
                    local ticketsFromDeposits = 0
                    
                    -- Track double ticket vs normal deposits separately
                    local normalGold = 0
                    local doubleGold = 0
                    local normalTickets = 0
                    local doubleTickets = 0
                    local depositHistory = {}
                    
                    for _, dep in ipairs(m.deposits) do
                        if dep.type == "raffle" and dep.timestamp >= startTime and dep.timestamp <= endTime then
                            memberRaffle = memberRaffle + dep.amount
                            depositCount = depositCount + 1
                            if dep.timestamp > lastDeposit then lastDeposit = dep.timestamp end
                            
                            -- Calculate tickets and track if double ticket period
                            local depTickets = CalculateTicketsFromDeposit(dep.amount, processGs, dep.timestamp)
                            ticketsFromDeposits = ticketsFromDeposits + depTickets
                            
                            -- Check if this was a double ticket deposit
                            local isDouble = IsDoubleTicketDeposit(dep.timestamp, processGs)
                            if isDouble then
                                doubleGold = doubleGold + dep.amount
                                doubleTickets = doubleTickets + depTickets
                            else
                                normalGold = normalGold + dep.amount
                                normalTickets = normalTickets + depTickets
                            end
                            
                            -- Store deposit history for participant details
                            table.insert(depositHistory, {
                                amount = dep.amount,
                                tickets = depTickets,
                                timestamp = dep.timestamp,
                                isDouble = isDouble,
                                guildName = guildName,
                            })
                        end
                    end
                    
                    -- Apply rank bonuses from that guild
                    local freeTickets, multiplier, weeklyAllowance = GetRankBonus(processGuildId, name, processGs)
                    local weeksInPeriod = math.max(1, math.floor((endTime - startTime) / (7 * 86400)))
                    local weeklyAllowanceTickets = weeklyAllowance * weeksInPeriod
                    local rankBonusTickets = math.floor(ticketsFromDeposits * (multiplier - 1)) + freeTickets + weeklyAllowanceTickets
                    
                    -- Apply activity bonuses from that guild
                    local activityBonusTickets = GetActivityBonusTickets(processGuildId, name, processGs)
                    
                    -- Calculate final tickets for this guild
                    local finalTickets = math.floor(ticketsFromDeposits * multiplier) + freeTickets + weeklyAllowanceTickets + activityBonusTickets
                    
                    if finalTickets > 0 or memberRaffle > 0 then
                        -- Combine with existing entry for this player
                        if combinedEntries[name] then
                            local e = combinedEntries[name]
                            e.amount = e.amount + memberRaffle
                            e.tickets = e.tickets + finalTickets
                            e.baseTickets = e.baseTickets + ticketsFromDeposits
                            e.rankBonusTickets = e.rankBonusTickets + rankBonusTickets
                            e.activityBonusTickets = e.activityBonusTickets + activityBonusTickets
                            e.depositCount = e.depositCount + depositCount
                            e.normalGold = (e.normalGold or 0) + normalGold
                            e.doubleGold = (e.doubleGold or 0) + doubleGold
                            e.normalTickets = (e.normalTickets or 0) + normalTickets
                            e.doubleTickets = (e.doubleTickets or 0) + doubleTickets
                            e.freeTickets = (e.freeTickets or 0) + freeTickets
                            e.weeklyAllowanceTickets = (e.weeklyAllowanceTickets or 0) + weeklyAllowanceTickets
                            if lastDeposit > e.lastDeposit then e.lastDeposit = lastDeposit end
                            -- Merge deposit history
                            for _, dh in ipairs(depositHistory) do
                                table.insert(e.depositHistory, dh)
                            end
                            -- Track per-guild breakdown
                            e.guildBreakdown[guildName] = {
                                gold = memberRaffle,
                                tickets = finalTickets,
                                baseTickets = ticketsFromDeposits,
                                rankBonus = rankBonusTickets,
                                activityBonus = activityBonusTickets,
                            }
                        else
                            combinedEntries[name] = {
                                name = name,
                                amount = memberRaffle,
                                tickets = finalTickets,
                                baseTickets = ticketsFromDeposits,
                                rankBonusTickets = rankBonusTickets,
                                activityBonusTickets = activityBonusTickets,
                                multiplier = multiplier,
                                depositCount = depositCount,
                                lastDeposit = lastDeposit,
                                normalGold = normalGold,
                                doubleGold = doubleGold,
                                normalTickets = normalTickets,
                                doubleTickets = doubleTickets,
                                freeTickets = freeTickets,
                                weeklyAllowanceTickets = weeklyAllowanceTickets,
                                depositHistory = depositHistory,
                                guildBreakdown = {
                                    [guildName] = {
                                        gold = memberRaffle,
                                        tickets = finalTickets,
                                        baseTickets = ticketsFromDeposits,
                                        rankBonus = rankBonusTickets,
                                        activityBonus = activityBonusTickets,
                                    }
                                },
                            }
                        end
                    end
                end
            end
        end
    end  -- End guild loop
    
    -- Apply entry limits and minimums using primary guild settings, then add to sorted entries
    for name, entry in pairs(combinedEntries) do
        local finalTickets = entry.tickets
        
        -- Apply entry limits from primary guild
        if gs.entryRules and gs.entryRules.maxTickets > 0 then
            finalTickets = math.min(finalTickets, gs.entryRules.maxTickets)
        end
        
        -- Check minimum tickets requirement from primary guild
        local minTickets = (gs.entryRules and gs.entryRules.minTickets) or 0
        
        if finalTickets >= minTickets and finalTickets > 0 then
            entry.tickets = finalTickets
            table.insert(rf.sortedEntries, entry)
            totalTickets = totalTickets + finalTickets
            totalGold = totalGold + entry.amount
        end
    end
    
    -- DEMO MODE: Use DEMO_MEMBERS data with full settings application
    if #rf.sortedEntries == 0 and guildId == 0 then
        local ticketPrice = gs.simpleTicketPrice or 1000
        
        for _, member in ipairs(DEMO_MEMBERS) do
            -- Calculate base tickets from deposit
            local baseTickets = math.floor(member.baseDeposit / ticketPrice)
            
            -- Apply rank bonuses (includes weekly allowance)
            local freeTickets, multiplier, weeklyAllowance = GetDemoRankBonus(member, gs)
            local weeksInPeriod = math.max(1, math.floor((endTime - startTime) / (7 * 86400)))
            local weeklyAllowanceTickets = weeklyAllowance * weeksInPeriod
            local rankBonusTickets = math.floor(baseTickets * (multiplier - 1)) + freeTickets + weeklyAllowanceTickets
            
            -- Apply activity bonuses
            local activityBonusTickets = GetDemoActivityBonuses(member, gs)
            
            -- Calculate final tickets
            local finalTickets = math.floor(baseTickets * multiplier) + freeTickets + weeklyAllowanceTickets + activityBonusTickets
            
            -- Apply entry limits
            if gs.entryRules and gs.entryRules.maxTickets > 0 then
                finalTickets = math.min(finalTickets, gs.entryRules.maxTickets)
            end
            
            -- Check minimum tickets requirement
            local minTickets = (gs.entryRules and gs.entryRules.minTickets) or 0
            
            -- Check winner cooldown (demo mode)
            local isOnCooldown = false
            if gs.entryRules and gs.entryRules.winnerCooldown > 0 and gs.pastWinners then
                local cooldownSeconds = gs.entryRules.winnerCooldown * 7 * 86400
                for _, w in ipairs(gs.pastWinners) do
                    if w.name == member.name and (GetTimeStamp() - w.timestamp) < cooldownSeconds then
                        isOnCooldown = true
                        break
                    end
                end
            end
            
            if finalTickets >= minTickets and finalTickets > 0 and not isOnCooldown then
                table.insert(rf.sortedEntries, {
                    name = member.name,
                    amount = member.baseDeposit,
                    tickets = finalTickets,
                    baseTickets = baseTickets,
                    rankBonusTickets = rankBonusTickets,
                    activityBonusTickets = activityBonusTickets,
                    multiplier = multiplier,
                    rankIndex = member.rankIndex,
                    rankName = DEMO_RANKS[member.rankIndex] or "Member",
                    depositCount = math.random(1, math.max(1, baseTickets)),
                    lastDeposit = GetTimeStamp() - math.random(0, 604800),
                })
                totalTickets = totalTickets + finalTickets
                totalGold = totalGold + member.baseDeposit
            end
        end
    end
    -- END DEMO MODE
    
    -- Sort by tickets (descending)
    table.sort(rf.sortedEntries, function(a, b)
        if a.tickets ~= b.tickets then return a.tickets > b.tickets end
        return a.name < b.name
    end)
    
    rf.raffleEntriesCount = #rf.sortedEntries
    rf.totalTickets = totalTickets
    rf.totalGold = totalGold
    
    -- Calculate per-guild stats for spreadsheet view
    rf.guildStats = {}
    for _, entry in ipairs(rf.sortedEntries) do
        if entry.guildBreakdown then
            for guildName, data in pairs(entry.guildBreakdown) do
                if not rf.guildStats[guildName] then
                    rf.guildStats[guildName] = {
                        name = guildName,
                        participants = 0,
                        gold = 0,
                        tickets = 0,
                        baseTickets = 0,
                        rankBonus = 0,
                        activityBonus = 0,
                        doubleGold = 0,
                        doubleTickets = 0,
                    }
                end
                local gs = rf.guildStats[guildName]
                gs.participants = gs.participants + 1
                gs.gold = gs.gold + (data.gold or 0)
                gs.tickets = gs.tickets + (data.tickets or 0)
                gs.baseTickets = gs.baseTickets + (data.baseTickets or 0)
                gs.rankBonus = gs.rankBonus + (data.rankBonus or 0)
                gs.activityBonus = gs.activityBonus + (data.activityBonus or 0)
            end
        end
        -- Track double ticket stats
        if entry.doubleGold and entry.doubleGold > 0 then
            -- Get first guild from breakdown for double stats
            if entry.guildBreakdown then
                for guildName, _ in pairs(entry.guildBreakdown) do
                    if rf.guildStats[guildName] then
                        rf.guildStats[guildName].doubleGold = rf.guildStats[guildName].doubleGold + (entry.doubleGold or 0)
                        rf.guildStats[guildName].doubleTickets = rf.guildStats[guildName].doubleTickets + (entry.doubleTickets or 0)
                    end
                    break
                end
            end
        end
    end
end

-- ============================================
-- UI UPDATE
-- ============================================

function NWT.UpdateRaffleUI()
    local ui = ATK_Raffle_UI
    if not ui then return end
    
    local rf = NWT.Raffle
    local numGuilds = GetNumGuilds()
    
    -- TEST MODE: Use fake data when no guilds
    local guildId, guildName, gs
    if numGuilds == 0 then
        guildId = 0
        guildName = "Test Guild (No Guilds)"
        gs = { ticketPrice = 1000, raffleSuffixes = {1}, rafflePeriodId = "all", lastScanTime = 0 }
    else
        guildId = GetGuildId(rf.viewingGuildIndex)
        guildName = GetGuildName(guildId)
        gs = GetRaffleGuildSettings(guildId)
    end
    
    NWT.BuildRaffleEntries(guildId)
    
    -- Main Window Gilded Frame
    local bg = ui:GetNamedChild("BG")
    if bg then
        bg:SetEdgeColor(1, 0.84, 0, 1) -- Golden
        bg:SetCenterColor(0, 0, 0, 0.98)
    end

    -- Header Section
    local header = ui:GetNamedChild("Header")
    local plate = header:GetNamedChild("Plate")
    plate:SetEdgeColor(1, 0.84, 0, 1)
    
    local title = header:GetNamedChild("Title")
    title:SetColor(1, 0.84, 0, 1)
    
    local subtitle = header:GetNamedChild("Subtitle")
    subtitle:SetText("|cFFFFFF" .. guildName:upper() .. "|r")
    
    local isGuildsFocus = (rf.focusPanel == "guilds")
    local isEntriesFocus = (rf.focusPanel == "entries")
    
    -- Guild selection card focus effects
    local leftCol = ui:GetNamedChild("LeftCol")
    local gCard = leftCol:GetNamedChild("GuildsCard")
    if gCard then
        local gBG = gCard:GetNamedChild("BG")
        local gFocus = gCard:GetNamedChild("FocusGlow")
        local gPlate = gCard:GetNamedChild("HeaderPlate")
        if isGuildsFocus then
            gBG:SetEdgeColor(1, 0.84, 0, 1)
            gFocus:SetHidden(false)
            if not gCard.glowTimeline:IsPlaying() then gCard.glowTimeline:PlayForward() end
            gPlate:SetEdgeColor(1, 0.84, 0, 1)
            PlaySound(SOUNDS.GAMEPAD_MENU_UP)
        else
            gBG:SetEdgeColor(0.3, 0.3, 0.3, 1)
            gFocus:SetHidden(true)
            gCard.glowTimeline:Stop()
            gPlate:SetEdgeColor(0.3, 0.3, 0.3, 1)
        end
        
        local gList = gCard:GetNamedChild("List")
        for i = 1, 5 do
            local gLabel = gList:GetNamedChild("Guild" .. i)
            if not gLabel then
                gLabel = WINDOW_MANAGER:CreateControl("$(parent)Guild" .. i, gList, CT_LABEL)
                gLabel:SetFont("ZoFontGamepad34")
                gLabel:SetDimensions(340, 45)
                gLabel:SetAnchor(TOPLEFT, gList, TOPLEFT, 20, (i-1) * 50)
            end
            
            -- TEST MODE: Show fake guild when no real guilds
            if numGuilds == 0 then
                if i == 1 then
                    local isSelected = (rf.selectedGuildIndex == 1)
                    if isSelected then
                        gLabel:SetScale(1.1)
                        gLabel:SetColor(1, 0.84, 0, 1)
                    else
                        gLabel:SetScale(1.0)
                        gLabel:SetColor(1, 1, 1, 1)
                    end
                    gLabel:SetText("► Test Guild (Demo)")
                    gLabel:SetHidden(false)
                else
                    gLabel:SetHidden(true)
                end
            else
                -- Build sorted guild list (favorites first)
                if not rf.sortedGuildList then
                    rf.sortedGuildList = {}
                    for gi = 1, numGuilds do
                        local gId = GetGuildId(gi)
                        if gId and gId > 0 then
                            table.insert(rf.sortedGuildList, { index = gi, guildId = gId, isFavorite = IsRaffleGuildFavorite(gId) })
                        end
                    end
                    table.sort(rf.sortedGuildList, function(a, b)
                        if a.isFavorite ~= b.isFavorite then return a.isFavorite end
                        return a.index < b.index
                    end)
                end
                
                local guildData = rf.sortedGuildList[i]
                if guildData then
                    local gId = guildData.guildId
                    local name = GetGuildName(gId)
                    local isEnabled = IsGuildEnabled(gId)
                    local isFav = guildData.isFavorite
                    local isSelected = (rf.selectedGuildIndex == i)
                    
                    -- High-Contrast Selection Highlight
                    if isSelected then
                        gLabel:SetScale(1.1)
                        gLabel:SetColor(1, 0.84, 0, 1) -- Golden
                    else
                        gLabel:SetScale(1.0)
                        gLabel:SetColor(1, 1, 1, isEnabled and 1 or 0.5)
                    end

                    local prefix = isSelected and "► " or "  "
                    local favIcon = isFav and "|cFFD700★|r " or ""
                    gLabel:SetText(prefix .. favIcon .. name)
                    gLabel:SetHidden(false)
                else
                    gLabel:SetHidden(true)
                end
            end
        end
    end
    
    -- Entries panel focus effects
    local ep = ui:GetNamedChild("EntriesCol")
    if ep then
        local eBG = ep:GetNamedChild("BG")
        local eFocus = ep:GetNamedChild("FocusGlow")
        local ePlate = ep:GetNamedChild("HeaderPlate")
        if isEntriesFocus then
            eBG:SetEdgeColor(1, 0.84, 0, 1)
            eFocus:SetHidden(false)
            if not ep.glowTimeline:IsPlaying() then ep.glowTimeline:PlayForward() end
            ePlate:SetEdgeColor(1, 0.84, 0, 1)
        else
            eBG:SetEdgeColor(0.3, 0.3, 0.3, 1)
            eFocus:SetHidden(true)
            ep.glowTimeline:Stop()
            ePlate:SetEdgeColor(0.3, 0.3, 0.3, 1)
        end
        
        local epHeader = ep:GetNamedChild("Header")
        if epHeader then
            epHeader:SetText(string.format("|c00FFFF%d PARTICIPANTS|r  |cFFD700●|r  |cFFFF00%d TICKETS|r", 
                rf.raffleEntriesCount, rf.totalTickets or 0))
        end
        
        local list = ep:GetNamedChild("List")
        local selectionFrame = list:GetNamedChild("SelectionFrame")
        
        for i = 1, 12 do
            local row = list:GetNamedChild("Row" .. i)
            
            local entryIdx = i + rf.raffleScrollOffset
            local entry = rf.sortedEntries[entryIdx]
            
            if entry then
                local displayName = entry.name:gsub("^@", "")
                if #displayName > 24 then displayName = displayName:sub(1,22) .. ".." end
                
                row:GetNamedChild("Num"):SetText("|c888888" .. entryIdx .. "|r")
                row:GetNamedChild("Name"):SetText("|cFFFFFF" .. displayName .. "|r")
                row:GetNamedChild("Tickets"):SetText("|cFFFF00" .. entry.tickets .. "|r")
                row:GetNamedChild("Gold"):SetText("|c00FF00" .. NWT.FormatGold(entry.amount) .. "g|r")
                
                -- Selection feedback
                local isRowFocused = isEntriesFocus and (entryIdx == rf.selectedEntryIndex)
                
                if isRowFocused then
                    selectionFrame:ClearAnchors()
                    selectionFrame:SetAnchor(TOPLEFT, row, TOPLEFT, -5, -2)
                    selectionFrame:SetAlpha(1)
                    row:GetNamedChild("BG"):SetEdgeColor(1, 0.84, 0, 1)
                    row:GetNamedChild("BG"):SetAlpha(0.8)
                else
                    row:GetNamedChild("BG"):SetEdgeColor(0.3, 0.3, 0.3, 0.5)
                    row:GetNamedChild("BG"):SetAlpha(0.2)
                end

                if row:IsHidden() then
                    row:SetHidden(false)
                    if row.timeline then row.timeline:PlayForward() end
                end
            else
                row:SetHidden(true)
            end
        end
        
        if not isEntriesFocus then
            selectionFrame:SetAlpha(0)
        end
    end
    
    -- Stats Card - Show raffle statistics with per-guild breakdown
    local sCard = leftCol:GetNamedChild("StatsCard")
    if sCard then
        sCard:GetNamedChild("BG"):SetEdgeColor(0.3, 0.3, 0.3, 1)
        sCard:GetNamedChild("HeaderPlate"):SetEdgeColor(0.3, 0.3, 0.3, 1)
        
        -- Calculate stats
        local totalParticipants = rf.raffleEntriesCount or 0
        local totalTickets = rf.totalTickets or 0
        local totalGold = rf.totalGold or 0
        local periodStr = FormatRafflePeriod(gs)
        
        -- Check if we have linked guilds for spreadsheet view
        -- Show breakdown if there are linked guilds configured
        local allGuildStats = rf.guildStats or {}
        local guildStats = {}
        local guildOrder = {}
        local hasLinkedGuilds = false
        
        -- Get the current guild name
        local currentGuildName = guildId > 0 and GetGuildName(guildId) or "Test Guild"
        
        -- Always include current guild first
        table.insert(guildOrder, currentGuildName)
        guildStats[currentGuildName] = allGuildStats[currentGuildName] or {
            name = currentGuildName,
            participants = 0,
            gold = 0,
            tickets = 0,
        }
        
        -- Add linked guilds (even if they have no data)
        if gs.linkedGuilds then
            for linkedGuildId, isLinked in pairs(gs.linkedGuilds) do
                if isLinked then
                    hasLinkedGuilds = true
                    local linkedName = GetGuildName(linkedGuildId)
                    table.insert(guildOrder, linkedName)
                    guildStats[linkedName] = allGuildStats[linkedName] or {
                        name = linkedName,
                        participants = 0,
                        gold = 0,
                        tickets = 0,
                    }
                end
            end
        end
        
        local guildCount = #guildOrder
        
        -- Calculate additional stats from entries
        local totalDoubleGold = 0
        local totalDoubleTickets = 0
        local totalRankBonus = 0
        for _, entry in ipairs(rf.sortedEntries) do
            totalDoubleGold = totalDoubleGold + (entry.doubleGold or 0)
            totalDoubleTickets = totalDoubleTickets + (entry.doubleTickets or 0)
            totalRankBonus = totalRankBonus + (entry.rankBonusTickets or 0)
        end
        
        if hasLinkedGuilds then
            -- Fixed column width for alignment (12 chars per guild column)
            local colWidth = 12
            local labelWidth = 10
            
            -- Helper to pad string to fixed width
            local function pad(str, width)
                str = tostring(str)
                if #str >= width then return str:sub(1, width) end
                return str .. string.rep(" ", width - #str)
            end
            
            -- Spreadsheet-style header with guild names
            local header = string.format("|cFFD700%-" .. labelWidth .. "s|r", "STAT")
            for _, guildName in ipairs(guildOrder) do
                header = header .. string.format("  |c00FFFF%-" .. colWidth .. "s|r", guildName:sub(1, colWidth))
            end
            header = header .. string.format("  |cFFFF00%-" .. colWidth .. "s|r", "TOTAL")
            sCard:GetNamedChild("TicketPrice"):SetText(header)
            
            -- Gold row
            local goldRow = string.format("|cFFFFAA%-" .. labelWidth .. "s|r", "Gold")
            for _, gn in ipairs(guildOrder) do
                goldRow = goldRow .. string.format("  |cFFFFFF%-" .. colWidth .. "s|r", NWT.FormatGold(guildStats[gn].gold or 0))
            end
            goldRow = goldRow .. string.format("  |c00FF00%-" .. colWidth .. "s|r", NWT.FormatGold(totalGold))
            sCard:GetNamedChild("Suffix"):SetText(goldRow)
            
            -- Tickets row
            local ticketRow = string.format("|cFFFFAA%-" .. labelWidth .. "s|r", "Tickets")
            for _, gn in ipairs(guildOrder) do
                ticketRow = ticketRow .. string.format("  |cFFFFFF%-" .. colWidth .. "s|r", tostring(guildStats[gn].tickets or 0))
            end
            ticketRow = ticketRow .. string.format("  |cFFFF00%-" .. colWidth .. "s|r", tostring(totalTickets))
            sCard:GetNamedChild("Period"):SetText(ticketRow)
            
            -- Participants row
            local partRow = string.format("|cFFFFAA%-" .. labelWidth .. "s|r", "Members")
            for _, gn in ipairs(guildOrder) do
                partRow = partRow .. string.format("  |cFFFFFF%-" .. colWidth .. "s|r", tostring(guildStats[gn].participants or 0))
            end
            partRow = partRow .. string.format("  |c00FFFF%-" .. colWidth .. "s|r", tostring(totalParticipants))
            sCard:GetNamedChild("LastScan"):SetText(partRow .. "  |c888888(" .. periodStr .. ")|r")
        else
            -- Single guild - enhanced display with more stats
            sCard:GetNamedChild("TicketPrice"):SetText(string.format("|c00FFFFPARTICIPANTS:|r |cFFFFFF%d|r   |cFFD700TICKETS:|r |cFFFFFF%d|r   |c00FF00GOLD:|r |cFFFFFF%sg|r", totalParticipants, totalTickets, NWT.FormatGold(totalGold)))
            
            -- Show double ticket stats if any
            local doubleInfo = ""
            if totalDoubleTickets > 0 then
                doubleInfo = string.format("   |cFF00FFDouble:|r %d tix (%sg)", totalDoubleTickets, NWT.FormatGold(totalDoubleGold))
            end
            sCard:GetNamedChild("Suffix"):SetText(string.format("|cFFFFAANormal Tickets:|r |cFFFFFF%d|r%s", totalTickets - totalDoubleTickets, doubleInfo))
            
            -- Show rank bonus stats if any
            local rankInfo = ""
            if totalRankBonus > 0 then
                rankInfo = string.format("   |c00FF00Rank Bonus:|r +%d tix", totalRankBonus)
            end
            sCard:GetNamedChild("Period"):SetText(string.format("|cFFFFAABase Tickets:|r |cFFFFFF%d|r%s", totalTickets - totalRankBonus, rankInfo))
            
            sCard:GetNamedChild("LastScan"):SetText(string.format("|c888888Period: %s|r", periodStr))
        end
    end
    
    local footer = ui:GetNamedChild("Footer")
    if footer then
        local xAction = rf.focusPanel == "guilds" and "Favorite" or "Pick Winner"
        footer:SetText("|c888888[LB/RB] Switch Panel  [D-Pad] Navigate  [A] Select  [X] " .. xAction .. "  [Y] Settings  [RS] Rescan|r")
    end
end

-- ============================================
-- NAVIGATION
-- ============================================

function NWT.RaffleSwitchPanel(dir)
    local rf = NWT.Raffle
    if rf.settingsMenuOpen or rf.rafflePickerOpen then return end
    
    if dir == "right" then
        if rf.focusPanel == "guilds" then rf.focusPanel = "entries" end
    else
        if rf.focusPanel == "entries" then rf.focusPanel = "guilds" end
    end
    
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    NWT.UpdateRaffleUI()
end

function NWT.RaffleScrollGuild(dir)
    local rf = NWT.Raffle
    local nG = GetNumGuilds()
    if nG == 0 then return end
    
    if dir == "up" then
        rf.selectedGuildIndex = math.max(1, rf.selectedGuildIndex - 1)
    else
        rf.selectedGuildIndex = math.min(nG, rf.selectedGuildIndex + 1)
    end
    
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    NWT.UpdateRaffleUI()
end

function NWT.RaffleScrollEntries(dir)
    local rf = NWT.Raffle
    local count = rf.raffleEntriesCount or 0
    
    if dir == "up" then
        if rf.selectedEntryIndex and rf.selectedEntryIndex > 1 then
            rf.selectedEntryIndex = rf.selectedEntryIndex - 1
            if rf.selectedEntryIndex <= rf.raffleScrollOffset then
                rf.raffleScrollOffset = math.max(0, rf.raffleScrollOffset - 1)
            end
            PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
        end
    elseif dir == "down" then
        if rf.selectedEntryIndex and rf.selectedEntryIndex < count then
            rf.selectedEntryIndex = rf.selectedEntryIndex + 1
            if rf.selectedEntryIndex > rf.raffleScrollOffset + 12 then
                rf.raffleScrollOffset = math.min(math.max(0, count - 12), rf.raffleScrollOffset + 1)
            end
            PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
        elseif not rf.selectedEntryIndex and count > 0 then
            rf.selectedEntryIndex = 1
            PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
        end
    end
    NWT.UpdateRaffleUI()
end

function NWT.RaffleSelectGuild()
    local rf = NWT.Raffle
    -- Get actual guild from sorted list
    if rf.sortedGuildList and rf.sortedGuildList[rf.selectedGuildIndex] then
        rf.viewingGuildIndex = rf.sortedGuildList[rf.selectedGuildIndex].index
    else
        rf.viewingGuildIndex = rf.selectedGuildIndex
    end
    rf.focusPanel = "entries"
    rf.raffleScrollOffset = 0
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    NWT.UpdateRaffleUI()
end

function NWT.RaffleFavoriteSelectedGuild()
    local rf = NWT.Raffle
    if not rf.sortedGuildList or not rf.sortedGuildList[rf.selectedGuildIndex] then return end
    local guildId = rf.sortedGuildList[rf.selectedGuildIndex].guildId
    if not guildId or guildId <= 0 then return end
    ToggleRaffleGuildFavorite(guildId)
    rf.sortedGuildList = nil  -- Force rebuild of sorted list
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateRaffleUI()
end

-- ============================================
-- RAFFLE PICKER (Random Winner Selection)
-- ============================================

function NWT.RaffleShowPicker()
    local rf = NWT.Raffle
    rf.rafflePickerOpen = true
    rf.raffleWinnerCount = 1
    NWT.UpdateRafflePickerDialog()
    if ATK_RafflePickerDialog then ATK_RafflePickerDialog:SetHidden(false) end
    if KEYBIND_STRIP and NWT.HiddenRaffleListScreen then 
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenRaffleListScreen.keybindStripDescriptor) 
    end
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.UpdateRafflePickerDialog()
    local rf = NWT.Raffle
    local dialog = ATK_RafflePickerDialog
    if not dialog then return end
    
    local guildId = GetGuildId(rf.viewingGuildIndex)
    local gs = GetRaffleGuildSettings(guildId)
    
    local periodLabel = dialog:GetNamedChild("Period")
    local statsLabel = dialog:GetNamedChild("Stats")
    local countLabel = dialog:GetNamedChild("WinnerCount")
    
    if periodLabel then periodLabel:SetText(string.format("|cFFFFAAPeriod:|r %s", FormatRafflePeriod(gs))) end
    if statsLabel then statsLabel:SetText(string.format("|c00FFFF%d participants|r  |cFFFF00%d tickets|r", rf.raffleEntriesCount or 0, rf.totalTickets or 0)) end
    if countLabel then countLabel:SetText(string.format("|cFFFFFF# Winners:|r |cFFD700◄ %d ►|r", rf.raffleWinnerCount or 1)) end
end

function NWT.RaffleAdjustWinnerCount(dir)
    local rf = NWT.Raffle
    if not rf.rafflePickerOpen then return end
    if dir == "up" or dir == "right" then
        rf.raffleWinnerCount = math.min(10, (rf.raffleWinnerCount or 1) + 1)
    else
        rf.raffleWinnerCount = math.max(1, (rf.raffleWinnerCount or 1) - 1)
    end
    NWT.UpdateRafflePickerDialog()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.RaffleRunPicker()
    local rf = NWT.Raffle
    local guildId = GetGuildId(rf.viewingGuildIndex)
    local gs
    if guildId == 0 then
        gs = GetDefaultRaffleSettings()
    else
        gs = GetRaffleGuildSettings(guildId)
    end
    
    -- Use pre-built entries from BuildRaffleEntries (already has all bonuses applied)
    NWT.BuildRaffleEntries(guildId)
    
    -- Build weighted pool from sorted entries
    local pool = {}
    local totalTickets = 0
    for _, entry in ipairs(rf.sortedEntries) do
        -- Entries already have exclusions applied and tickets calculated
        table.insert(pool, { name = entry.name, tickets = entry.tickets, amount = entry.amount })
        totalTickets = totalTickets + entry.tickets
    end
    
    if #pool == 0 then
NWT.Debug("|cFFFF00[Raffle]|r No entries for this period!")
        return
    end
    
    -- Get prize distribution settings
    local pc = gs.prizeConfig or {}
    local configuredWinners = pc.numWinners or 1
    local winnerCount = math.min(rf.raffleWinnerCount or configuredWinners, #pool)
    
    -- Calculate prize distribution
    local prizes, prizePool = CalculatePrizeDistribution(rf.totalGold, gs)
    
    -- Pick winners
    local winners = {}
    local poolCopy = {}
    for i, v in ipairs(pool) do poolCopy[i] = {name = v.name, tickets = v.tickets, amount = v.amount} end
    local tempTotalTickets = totalTickets

    for w = 1, winnerCount do
        if tempTotalTickets <= 0 or #poolCopy == 0 then break end
        local winningTicket = math.random(1, tempTotalTickets)
        local runningTotal = 0
        for i, entry in ipairs(poolCopy) do
            runningTotal = runningTotal + entry.tickets
            if winningTicket <= runningTotal then
                local prize = prizes[w] or 0
                table.insert(winners, { 
                    name = entry.name, 
                    tickets = entry.tickets, 
                    place = w,
                    prize = prize,
                })
                -- Record winner for cooldown tracking
                if guildId > 0 then
                    RecordWinner(gs, entry.name)
                end
                tempTotalTickets = tempTotalTickets - entry.tickets
                table.remove(poolCopy, i)
                break
            end
        end
    end
    
    -- Handle progressive jackpot
    local jackpotWon = 0
    if #winners > 0 and guildId > 0 then
        jackpotWon = UpdateJackpot(gs, true, rf.totalGold)
        if jackpotWon > 0 then
            winners[1].prize = (winners[1].prize or 0) + jackpotWon
            winners[1].jackpotWon = jackpotWon
        end
    end
    
    rf.raffleWinners = winners
    rf.raffleEntryCount = #pool
    rf.rafflePrizePool = prizePool
    
    -- High-fidelity rolling animation
    if ATK_RafflePickerDialog then ATK_RafflePickerDialog:SetHidden(true) end
    if ATK_RaffleWinnerDialog then
        ATK_RaffleWinnerDialog:SetHidden(false)
        local winnerLabel = ATK_RaffleWinnerDialog:GetNamedChild("WinnerName")
        local statsLabel = ATK_RaffleWinnerDialog:GetNamedChild("Stats")
        statsLabel:SetText("|c888888Drawing winners...|r")
        
        local rollCount = 0
        local maxRolls = 20
        EVENT_MANAGER:RegisterForUpdate("ATK_Raffle_Rolling", 100, function()
            rollCount = rollCount + 1
            if rollCount < maxRolls then
                local randomIdx = math.random(1, #pool)
                winnerLabel:SetText("|c888888" .. pool[randomIdx].name:gsub("^@", "") .. "|r")
                PlaySound(SOUNDS.ROLL_DICE)
            else
                EVENT_MANAGER:UnregisterForUpdate("ATK_Raffle_Rolling")
                NWT.ShowRaffleWinnerDialog()
            end
        end)
    end
end

function NWT.ShowRaffleWinnerDialog()
    local rf = NWT.Raffle
    local dialog = ATK_RaffleWinnerDialog
    if not dialog then return end
    
    local winners = rf.raffleWinners
    if not winners or #winners == 0 then return end
    
    local winnerText = ""
    for i, w in ipairs(winners) do
        local displayName = w.name:gsub("^@", "")
        local prizeText = ""
        if w.prize and w.prize > 0 then
            prizeText = " - |c00FF00" .. NWT.FormatGold(w.prize) .. "g|r"
            if w.jackpotWon and w.jackpotWon > 0 then
                prizeText = prizeText .. " |cFF00FF(+JACKPOT!)|r"
            end
        end
        if i == 1 then
            winnerText = string.format("|cFFD700#%d: %s|r (%d tickets)%s", i, displayName, w.tickets, prizeText)
        else
            winnerText = winnerText .. string.format("\n|cFFFFAA#%d: %s|r (%d tickets)%s", i, displayName, w.tickets, prizeText)
        end
    end
    
    local nameLabel = dialog:GetNamedChild("WinnerName")
    local statsLabel = dialog:GetNamedChild("Stats")
    
    if nameLabel then nameLabel:SetText(winnerText) end
    
    local statsText = string.format("|c888888%d participants  •  Prize Pool: %sg|r", 
        rf.raffleEntryCount or 0, NWT.FormatGold(rf.rafflePrizePool or 0))
    if statsLabel then statsLabel:SetText(statsText) end
    
    rf.raffleWinnerDialogOpen = true
    dialog:SetHidden(false)
    if KEYBIND_STRIP and NWT.HiddenRaffleListScreen then 
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenRaffleListScreen.keybindStripDescriptor) 
    end
    PlaySound(SOUNDS.TELVAR_GAINED)
end

function NWT.CloseRaffleWinnerDialog()
    if ATK_RaffleWinnerDialog then ATK_RaffleWinnerDialog:SetHidden(true) end
    NWT.Raffle.raffleWinnerDialogOpen = nil
    NWT.Raffle.raffleWinners = nil
    NWT.Raffle.rafflePickerOpen = false
    if KEYBIND_STRIP and NWT.HiddenRaffleListScreen then 
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenRaffleListScreen.keybindStripDescriptor) 
    end
end

function NWT.RaffleReroll()
    NWT.CloseRaffleWinnerDialog()
    NWT.RaffleShowPicker()
end

-- ============================================
-- PARTICIPANT DETAILS
-- ============================================

function NWT.ShowParticipantDetails()
    local rf = NWT.Raffle
    if rf.focusPanel ~= "entries" then return end
    
    local entryIdx = rf.selectedEntryIndex or 1
    local entry = rf.sortedEntries[entryIdx]
    if not entry then return end
    
    local dialog = ATK_ParticipantDetailsDialog
    if not dialog then return end
    
    -- Title
    local displayName = entry.name:gsub("^@", "")
    local title = dialog:GetNamedChild("Title")
    if title then title:SetText("|cFFD700" .. displayName .. "|r") end
    
    -- Helper to safely set row text
    local function SetRow(num, text)
        local row = dialog:GetNamedChild("Row" .. num)
        if row then row:SetText(text) end
    end
    
    local rowNum = 1
    
    -- Row 1: Total Tickets
    SetRow(rowNum, string.format("|cFFFFAAFinal Tickets:|r  |cFFFF00%d|r", entry.tickets))
    rowNum = rowNum + 1
    
    -- Row 2: Total Deposited
    SetRow(rowNum, string.format("|cFFFFAATotal Deposited:|r  |c00FF00%sg|r", NWT.FormatGold(entry.amount or 0)))
    rowNum = rowNum + 1
    
    -- Row 3: Normal Deposits
    local normalGold = entry.normalGold or entry.amount or 0
    local normalTickets = entry.normalTickets or entry.baseTickets or 0
    SetRow(rowNum, string.format("|cFFFFAANormal:|r  %sg → |cFFFFFF%d tickets|r", NWT.FormatGold(normalGold), normalTickets))
    rowNum = rowNum + 1
    
    -- Row 4: Double Ticket Deposits
    local doubleGold = entry.doubleGold or 0
    local doubleTickets = entry.doubleTickets or 0
    if doubleGold > 0 or doubleTickets > 0 then
        SetRow(rowNum, string.format("|cFFFFAADouble Tickets:|r  %sg → |c00FF00%d tickets|r", NWT.FormatGold(doubleGold), doubleTickets))
    else
        SetRow(rowNum, "|cFFFFAADouble Tickets:|r  |c888888None|r")
    end
    rowNum = rowNum + 1
    
    -- Row 5: Free Tickets (from rank)
    local freeTickets = entry.freeTickets or 0
    local weeklyTickets = entry.weeklyAllowanceTickets or 0
    local totalFree = freeTickets + weeklyTickets
    if totalFree > 0 then
        SetRow(rowNum, string.format("|cFFFFAAFree Tickets:|r  |c00FF00+%d|r  (rank bonus)", totalFree))
    else
        SetRow(rowNum, "|cFFFFAAFree Tickets:|r  |c888888None|r")
    end
    rowNum = rowNum + 1
    
    -- Row 6: Rank Multiplier
    local multiplier = entry.multiplier or 1.0
    if multiplier > 1.0 then
        SetRow(rowNum, string.format("|cFFFFAARank Multiplier:|r  |c00FF00%.2fx|r", multiplier))
    else
        SetRow(rowNum, "|cFFFFAARank Multiplier:|r  |c888888None|r")
    end
    rowNum = rowNum + 1
    
    -- Row 7: Activity Bonus
    local activityBonus = entry.activityBonusTickets or 0
    if activityBonus > 0 then
        SetRow(rowNum, string.format("|cFFFFAAActivity Bonus:|r  |c00FF00+%d|r", activityBonus))
    else
        SetRow(rowNum, "|cFFFFAAActivity Bonus:|r  |c888888None|r")
    end
    rowNum = rowNum + 1
    
    -- Row: Deposit History header (only if we have room)
    local row8 = dialog:GetNamedChild("Row" .. rowNum)
    if row8 then
        row8:SetText("|cFFD700--- Deposit History ---|r")
        rowNum = rowNum + 1
    end
    
    -- Show recent deposits (up to available rows)
    local depositHistory = entry.depositHistory or {}
    if #depositHistory > 0 then
        -- Sort by timestamp descending
        table.sort(depositHistory, function(a, b) return a.timestamp > b.timestamp end)
        
        local maxDeposits = math.min(4, #depositHistory)
        for i = 1, maxDeposits do
            local dep = depositHistory[i]
            local row = dialog:GetNamedChild("Row" .. rowNum)
            if dep and row then
                local dateStr = os.date("%m/%d %H:%M", dep.timestamp)
                local doubleTag = dep.isDouble and " |cFF00FF(2x)|r" or ""
                local guildTag = dep.guildName and (" |c888888[" .. dep.guildName:sub(1,8) .. "]|r") or ""
                row:SetText(string.format("  |c888888%s|r  %sg → %d tix%s%s", dateStr, NWT.FormatGold(dep.amount), dep.tickets, doubleTag, guildTag))
                rowNum = rowNum + 1
            end
        end
    end
    
    -- Clear remaining rows (up to 12 max)
    for i = rowNum, 12 do
        local row = dialog:GetNamedChild("Row" .. i)
        if row then row:SetText("") end
    end
    
    rf.participantDetailsOpen = true
    dialog:SetHidden(false)
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    if KEYBIND_STRIP and NWT.HiddenRaffleListScreen then 
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenRaffleListScreen.keybindStripDescriptor) 
    end
end

function NWT.CloseParticipantDetails()
    if ATK_ParticipantDetailsDialog then ATK_ParticipantDetailsDialog:SetHidden(true) end
    NWT.Raffle.participantDetailsOpen = nil
    if KEYBIND_STRIP and NWT.HiddenRaffleListScreen then 
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenRaffleListScreen.keybindStripDescriptor) 
    end
end

-- ============================================
-- COMPREHENSIVE SETTINGS SYSTEM
-- ============================================

local SETTINGS_TABS = {
    { id = "tickets", label = "TICKETS" },
    { id = "packs", label = "PACKS" },
    { id = "ranks", label = "RANKS" },
    { id = "bonuses", label = "BONUSES" },
    { id = "prizes", label = "PRIZES" },
    { id = "rules", label = "RULES" },
    { id = "linked", label = "LINKED" },
}

local TICKET_OPTIONS = {500, 1000, 2000, 2500, 5000, 10000, 25000, 50000}
local SUFFIX_OPTIONS = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}
local MULTIPLIER_OPTIONS = {1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 12.0, 15.0, 20.0}
local WINNER_OPTIONS = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
local PERCENTAGE_OPTIONS = {25, 50, 75, 100}

-- Settings definitions per tab
local function GetSettingsForTab(tabId, gs, guildId)
    if tabId == "tickets" then
        -- Check if double ticket session is active
        local doubleActive = gs.doubleTicketEndTime and gs.doubleTicketEndTime > GetTimeStamp()
        local doubleStatusText = ""
        if doubleActive then
            local remaining = gs.doubleTicketEndTime - GetTimeStamp()
            local mins = math.floor(remaining / 60)
            local secs = remaining % 60
            doubleStatusText = string.format("|c00FF00ACTIVE: %d:%02d|r", mins, secs)
        else
            doubleStatusText = "|c888888Inactive|r"
        end
        
        local settings = {
            { id = "simpleTicketPrice", label = "Ticket Price", value = NWT.FormatGold(gs.simpleTicketPrice or 1000) .. "g", type = "number", step = 500 },
            { id = "raffleSuffix", label = "Raffle Suffix (Deposit Ending)", value = table.concat(gs.raffleSuffixes or {1}, ", "), type = "cycle" },
            { id = "rafflePeriod", label = "Raffle Period", value = FormatRafflePeriod(gs), type = "cycle" },
        }
        
        -- Show custom date settings when custom period is selected
        if gs.rafflePeriodId == "custom" then
            local startDate = gs.customRaffleStart and os.date("%m/%d/%y", gs.customRaffleStart) or "Not Set"
            local endDate = gs.customRaffleEnd and os.date("%m/%d/%y", gs.customRaffleEnd) or "Not Set"
            table.insert(settings, { id = "customStartMonth", label = "  Start Month", value = gs.customStartMonth or 1, type = "number" })
            table.insert(settings, { id = "customStartDay", label = "  Start Day", value = gs.customStartDay or 1, type = "number" })
            table.insert(settings, { id = "customEndMonth", label = "  End Month", value = gs.customEndMonth or 12, type = "number" })
            table.insert(settings, { id = "customEndDay", label = "  End Day", value = gs.customEndDay or 31, type = "number" })
            table.insert(settings, { id = "applyCustomDates", label = "|c00FF00▶ Apply Custom Dates|r", value = startDate .. " - " .. endDate, type = "action" })
        end
        
        table.insert(settings, { id = "useTicketPacks", label = "Use Ticket Packs", value = gs.useTicketPacks and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" })
        table.insert(settings, { id = "doubleTicketDuration", label = "Double Ticket Duration", value = (gs.doubleTicketDuration or 30) .. " min", type = "number" })
        table.insert(settings, { id = "startDoubleTickets", label = doubleActive and "|cFF6600■ Stop Double Tickets|r" or "|c00FF00▶ Start Double Tickets|r", value = doubleStatusText, type = "action" })
        
        return settings
    elseif tabId == "packs" then
        local packList = {}
        for i, pack in ipairs(gs.ticketPacks or {}) do
            -- Each pack gets 3 editable rows
            table.insert(packList, { id = "pack_" .. i .. "_price", label = "  Pack " .. i .. " - Price", value = NWT.FormatGold(pack.price) .. "g", type = "pack_price", packIndex = i })
            table.insert(packList, { id = "pack_" .. i .. "_tickets", label = "  Pack " .. i .. " - Tickets", value = tostring(pack.tickets), type = "pack_tickets", packIndex = i })
            table.insert(packList, { id = "pack_" .. i .. "_suffix", label = "  Pack " .. i .. " - Suffix", value = tostring(pack.suffix), type = "pack_suffix", packIndex = i })
        end
        table.insert(packList, { id = "addPack", label = "|c00FF00+ Add New Pack|r", value = "", type = "action" })
        if #(gs.ticketPacks or {}) > 0 then
            table.insert(packList, { id = "removePack", label = "|cFF0000- Remove Last Pack|r", value = "", type = "action" })
        end
        return packList
    elseif tabId == "ranks" then
        local rankSettings = { 
            { id = "rankBonusEnabled", label = "Rank Bonuses Enabled", value = (gs.rankBonuses and gs.rankBonuses.enabled) and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" },
            { id = "header_exempt", label = "|cFFFF00── Exempt Ranks (No Raffle) ──|r", value = "", type = "info" },
        }
        
        -- Add exempt toggles for each rank
        if guildId > 0 then
            for i = 1, GetNumGuildRanks(guildId) do
                local rankName = GetGuildRankCustomName(guildId, i)
                local isExempt = gs.raffleExemptRanks and gs.raffleExemptRanks[i]
                table.insert(rankSettings, { id = "raffleExempt_" .. i, label = "  " .. rankName .. " Exempt", value = isExempt and "|cFF6600EXEMPT|r" or "|c888888No|r", type = "rank_exempt", rankIndex = i })
            end
        else
            for i = 1, 5 do
                local rankName = DEMO_RANKS[i] or ("Rank " .. i)
                local isExempt = gs.raffleExemptRanks and gs.raffleExemptRanks[i]
                table.insert(rankSettings, { id = "raffleExempt_" .. i, label = "  " .. rankName .. " Exempt", value = isExempt and "|cFF6600EXEMPT|r" or "|c888888No|r", type = "rank_exempt", rankIndex = i })
            end
        end
        
        table.insert(rankSettings, { id = "header_bonuses", label = "|cFFFF00── Rank Bonuses ──|r", value = "", type = "info" })
        
        if guildId > 0 then
            for i = 1, GetNumGuildRanks(guildId) do
                local rankName = GetGuildRankCustomName(guildId, i)
                local rb = (gs.rankBonuses and gs.rankBonuses.ranks and gs.rankBonuses.ranks[i]) or {}
                local freeTickets = rb.freeTickets or 0
                local multiplier = rb.multiplier or 1.0
                local weeklyAllowance = rb.weeklyAllowance or 0
                -- Each rank gets 3 editable rows
                table.insert(rankSettings, { id = "rank_" .. i .. "_free", label = "  " .. rankName .. " - Free Tickets", value = tostring(freeTickets), type = "rank_free", rankIndex = i })
                table.insert(rankSettings, { id = "rank_" .. i .. "_mult", label = "  " .. rankName .. " - Multiplier", value = string.format("%.2fx", multiplier), type = "rank_mult", rankIndex = i })
                table.insert(rankSettings, { id = "rank_" .. i .. "_weekly", label = "  " .. rankName .. " - Weekly Allowance", value = tostring(weeklyAllowance) .. "/wk", type = "rank_weekly", rankIndex = i })
            end
        else
            -- Demo mode: show demo ranks
            for i = 1, 5 do
                local rankName = DEMO_RANKS[i] or ("Rank " .. i)
                local rb = (gs.rankBonuses and gs.rankBonuses.ranks and gs.rankBonuses.ranks[i]) or {}
                local freeTickets = rb.freeTickets or 0
                local multiplier = rb.multiplier or 1.0
                local weeklyAllowance = rb.weeklyAllowance or 0
                -- Each rank gets 3 editable rows
                table.insert(rankSettings, { id = "rank_" .. i .. "_free", label = "  " .. rankName .. " - Free Tickets", value = tostring(freeTickets), type = "rank_free", rankIndex = i })
                table.insert(rankSettings, { id = "rank_" .. i .. "_mult", label = "  " .. rankName .. " - Multiplier", value = string.format("%.2fx", multiplier), type = "rank_mult", rankIndex = i })
                table.insert(rankSettings, { id = "rank_" .. i .. "_weekly", label = "  " .. rankName .. " - Weekly Allowance", value = tostring(weeklyAllowance) .. "/wk", type = "rank_weekly", rankIndex = i })
            end
        end
        return rankSettings
    elseif tabId == "bonuses" then
        local ab = gs.activityBonuses or {}
        return {
            { id = "activityEnabled", label = "Activity Bonuses Enabled", value = ab.enabled and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" },
            { id = "recruitmentBonus", label = "Recruitment Bonus", value = (ab.recruitmentBonus or 0) .. " tickets", type = "number" },
            { id = "newMemberBonus", label = "New Member Bonus", value = (ab.newMemberBonus or 0) .. " tickets", type = "number" },
            { id = "longevityBonus", label = "Longevity Bonus (per month)", value = (ab.longevityBonus or 0) .. " tickets", type = "number" },
            { id = "traderSalesBonus", label = "Trader Sales Bonus", value = ab.traderSalesBonus and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" },
            { id = "traderSalesPer", label = "Tickets per X Gold Sales", value = NWT.FormatGold(ab.traderSalesPer or 100000) .. "g", type = "cycle" },
        }
    elseif tabId == "prizes" then
        local pc = gs.prizeConfig or {}
        return {
            { id = "numWinners", label = "Number of Winners", value = tostring(pc.numWinners or 1), type = "cycle", options = WINNER_OPTIONS },
            { id = "poolPercentage", label = "Prize Pool %", value = (pc.poolPercentage or 100) .. "%", type = "cycle", options = PERCENTAGE_OPTIONS },
            { id = "distribution", label = "Distribution", value = pc.distribution or "equal", type = "cycle", options = {"equal", "tiered", "custom"} },
            { id = "progressiveJackpot", label = "Progressive Jackpot", value = pc.progressiveJackpot and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" },
            { id = "jackpotAmount", label = "Current Jackpot", value = NWT.FormatGold(pc.jackpotAmount or 0) .. "g", type = "number" },
            { id = "raffleType", label = "Raffle Type", value = gs.raffleType or "gold", type = "cycle", options = {"gold", "5050"} },
        }
    elseif tabId == "rules" then
        local er = gs.entryRules or {}
        return {
            { id = "maxTickets", label = "Max Tickets per Member", value = (er.maxTickets or 0) == 0 and "Unlimited" or tostring(er.maxTickets), type = "number" },
            { id = "minTickets", label = "Min Tickets to Enter", value = tostring(er.minTickets or 0), type = "number" },
            { id = "winnerCooldown", label = "Winner Cooldown (weeks)", value = tostring(er.winnerCooldown or 0), type = "number" },
            { id = "mustBeOnline", label = "Must Be Recently Online", value = er.mustBeOnline and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" },
            { id = "onlineThresholdDays", label = "Online Threshold (days)", value = tostring(er.onlineThresholdDays or 7), type = "number" },
        }
    elseif tabId == "linked" then
        -- Build list of all guilds that can be linked
        local settings = {}
        local linkedGuilds = gs.linkedGuilds or {}
        
        -- Show current guild as the "primary"
        local currentGuildName = guildId == 0 and "Test Guild" or GetGuildName(guildId)
        table.insert(settings, { id = "linkedInfo", label = "Primary Guild", value = "|cFFD700" .. currentGuildName .. "|r", type = "display" })
        table.insert(settings, { id = "linkedHelp", label = "Toggle guilds below", value = "to combine their data", type = "display" })
        
        -- List all player's guilds (except current) as toggleable options
        local numGuilds = GetNumGuilds()
        for i = 1, numGuilds do
            local otherGuildId = GetGuildId(i)
            if otherGuildId ~= guildId and otherGuildId > 0 then
                local otherName = GetGuildName(otherGuildId)
                local isLinked = linkedGuilds[otherGuildId] == true
                table.insert(settings, { 
                    id = "linkGuild_" .. otherGuildId, 
                    label = otherName, 
                    value = isLinked and "|c00FF00LINKED|r" or "|c888888-|r", 
                    type = "toggle",
                    guildIdToLink = otherGuildId
                })
            end
        end
        
        if #settings == 2 then
            table.insert(settings, { id = "noOtherGuilds", label = "No other guilds", value = "to link", type = "display" })
        end
        
        return settings
    end
    return {}
end

function NWT.RaffleShowSettings()
    local rf = NWT.Raffle
    if rf.settingsMenuOpen then return end
    rf.settingsMenuOpen = true
    rf.settingsTabIndex = 1
    rf.settingsRowIndex = 1
    rf.settingsScrollOffset = 0
    rf.settingsGuildId = GetGuildId(rf.viewingGuildIndex)
    if rf.settingsGuildId == 0 then rf.settingsGuildId = 0 end  -- Test mode
    NWT.UpdateRaffleSettingsDialog()
    if ATK_RaffleSettingsDialog then ATK_RaffleSettingsDialog:SetHidden(false) end
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    if KEYBIND_STRIP and NWT.HiddenRaffleListScreen then 
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenRaffleListScreen.keybindStripDescriptor) 
    end
end

function NWT.UpdateRaffleSettingsDialog()
    local rf = NWT.Raffle
    local dialog = ATK_RaffleSettingsDialog
    if not dialog then return end
    
    -- Always use GetRaffleGuildSettings - it handles demo mode (guildId=0) correctly
    local gs = GetRaffleGuildSettings(rf.settingsGuildId)
    local gn = rf.settingsGuildId == 0 and "Test Guild (Demo)" or GetGuildName(rf.settingsGuildId)
    dialog:GetNamedChild("GuildName"):SetText("|cFFFFFF" .. gn .. "|r")
    
    -- Update tab highlights
    local tabBar = dialog:GetNamedChild("TabBar")
    for i = 1, 6 do
        local tab = tabBar:GetNamedChild("Tab" .. i)
        if tab then
            if i == rf.settingsTabIndex then
                tab:SetColor(1, 0.84, 0, 1)  -- Gold for selected
            else
                tab:SetColor(0.6, 0.6, 0.6, 1)  -- Gray for unselected
            end
        end
    end
    
    -- Get settings for current tab
    local currentTab = SETTINGS_TABS[rf.settingsTabIndex]
    local settings = GetSettingsForTab(currentTab.id, gs, rf.settingsGuildId)
    rf.currentTabSettings = settings
    
    -- Update content rows with scroll support
    local content = dialog:GetNamedChild("Content")
    local selectionBG = content:GetNamedChild("SelectionBG")
    local scrollOffset = rf.settingsScrollOffset or 0
    
    for i = 1, 10 do
        local row = content:GetNamedChild("Row" .. i)
        if row then
            local settingIdx = i + scrollOffset
            local setting = settings[settingIdx]
            if setting then
                local isSelected = (settingIdx == rf.settingsRowIndex)
                local labelColor = isSelected and "|cFFFF00" or "|cFFFFFF"
                local valueColor = isSelected and "|cFFD700" or "|c888888"
                local prefix = isSelected and "► " or "  "
                row:SetText(string.format("%s%s%s:|r %s%s|r", labelColor, prefix, setting.label, valueColor, setting.value))
                row:SetHidden(false)
            else
                row:SetText("")
                row:SetHidden(true)
            end
        end
    end
    
    -- Update selection highlight position (relative to visible area)
    local visibleRowIndex = rf.settingsRowIndex - scrollOffset
    if selectionBG and visibleRowIndex >= 1 and visibleRowIndex <= 10 then
        selectionBG:ClearAnchors()
        selectionBG:SetAnchor(TOPLEFT, content, TOPLEFT, 15, 10 + (visibleRowIndex - 1) * 45)
        selectionBG:SetHidden(false)
    else
        selectionBG:SetHidden(true)
    end
    
    -- Update page info with scroll indicator
    local pageInfo = dialog:GetNamedChild("PageInfo")
    if pageInfo then
        local scrollInfo = ""
        if #settings > 10 then
            scrollInfo = string.format("  |cFFFF00(%d/%d)|r", rf.settingsRowIndex, #settings)
        end
        pageInfo:SetText(string.format("|c888888Tab %d of %d  •  %s%s|r", rf.settingsTabIndex, #SETTINGS_TABS, currentTab.label, scrollInfo))
    end
end

function NWT.RaffleSettingsChangeTab(dir)
    local rf = NWT.Raffle
    if not rf.settingsMenuOpen then return end
    
    if dir == "left" then
        rf.settingsTabIndex = rf.settingsTabIndex > 1 and rf.settingsTabIndex - 1 or #SETTINGS_TABS
    else
        rf.settingsTabIndex = rf.settingsTabIndex < #SETTINGS_TABS and rf.settingsTabIndex + 1 or 1
    end
    rf.settingsRowIndex = 1  -- Reset row selection when changing tabs
    rf.settingsScrollOffset = 0  -- Reset scroll when changing tabs
    NWT.UpdateRaffleSettingsDialog()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.RaffleCycleSettingsOption(dir)
    local rf = NWT.Raffle
    if not rf.settingsMenuOpen then return end
    
    local settings = rf.currentTabSettings or {}
    local numSettings = #settings
    if numSettings == 0 then return end
    
    local maxVisible = 10
    rf.settingsScrollOffset = rf.settingsScrollOffset or 0
    
    if dir == "up" then
        if rf.settingsRowIndex > 1 then
            rf.settingsRowIndex = rf.settingsRowIndex - 1
            -- Scroll up if selection goes above visible area
            if rf.settingsRowIndex <= rf.settingsScrollOffset then
                rf.settingsScrollOffset = rf.settingsRowIndex - 1
            end
        else
            -- Wrap to bottom
            rf.settingsRowIndex = numSettings
            rf.settingsScrollOffset = math.max(0, numSettings - maxVisible)
        end
    else
        if rf.settingsRowIndex < numSettings then
            rf.settingsRowIndex = rf.settingsRowIndex + 1
            -- Scroll down if selection goes below visible area
            if rf.settingsRowIndex > rf.settingsScrollOffset + maxVisible then
                rf.settingsScrollOffset = rf.settingsRowIndex - maxVisible
            end
        else
            -- Wrap to top
            rf.settingsRowIndex = 1
            rf.settingsScrollOffset = 0
        end
    end
    NWT.UpdateRaffleSettingsDialog()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.RaffleChangeSettingValue(direction)
    local rf = NWT.Raffle
    if not rf.settingsMenuOpen then return end
    direction = direction or 1  -- 1 = increment, -1 = decrement
    
    -- Always use GetRaffleGuildSettings - it handles demo mode (guildId=0) correctly
    local gs = GetRaffleGuildSettings(rf.settingsGuildId)
    
    local settings = rf.currentTabSettings or {}
    local setting = settings[rf.settingsRowIndex]
    if not setting then return end
    
    local currentTab = SETTINGS_TABS[rf.settingsTabIndex]
    
    -- Handle different setting types
    if setting.type == "toggle" then
        NWT.RaffleToggleSetting(gs, setting.id, currentTab.id)
    elseif setting.type == "cycle" then
        NWT.RaffleCycleSetting(gs, setting.id, currentTab.id, setting.options, direction)
    elseif setting.type == "number" then
        NWT.RaffleIncrementSetting(gs, setting.id, currentTab.id, direction)
    elseif setting.type == "action" then
        NWT.RaffleDoAction(gs, setting.id, currentTab.id)
    elseif setting.type == "pack_price" then
        NWT.RaffleEditPackPrice(gs, setting.packIndex, direction)
    elseif setting.type == "pack_tickets" then
        NWT.RaffleEditPackTickets(gs, setting.packIndex, direction)
    elseif setting.type == "pack_suffix" then
        NWT.RaffleEditPackSuffix(gs, setting.packIndex, direction)
    elseif setting.type == "rank_free" then
        NWT.RaffleEditRankFree(gs, setting.rankIndex, direction)
    elseif setting.type == "rank_mult" then
        NWT.RaffleEditRankMult(gs, setting.rankIndex, direction)
    elseif setting.type == "rank_weekly" then
        NWT.RaffleEditRankWeekly(gs, setting.rankIndex, direction)
    elseif setting.type == "rank_exempt" then
        NWT.RaffleToggleRankExempt(gs, setting.rankIndex)
    end
    
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateRaffleSettingsDialog()
    NWT.UpdateRaffleUI()
end

function NWT.RaffleToggleSetting(gs, settingId, tabId)
    if settingId == "useTicketPacks" then
        gs.useTicketPacks = not gs.useTicketPacks
    elseif settingId == "rankBonusEnabled" then
        if not gs.rankBonuses then gs.rankBonuses = { enabled = false, ranks = {} } end
        gs.rankBonuses.enabled = not gs.rankBonuses.enabled
    elseif settingId == "activityEnabled" then
        if not gs.activityBonuses then gs.activityBonuses = {} end
        gs.activityBonuses.enabled = not gs.activityBonuses.enabled
    elseif settingId == "progressiveJackpot" then
        if not gs.prizeConfig then gs.prizeConfig = {} end
        gs.prizeConfig.progressiveJackpot = not gs.prizeConfig.progressiveJackpot
    elseif settingId == "mustBeOnline" then
        if not gs.entryRules then gs.entryRules = {} end
        gs.entryRules.mustBeOnline = not gs.entryRules.mustBeOnline
    elseif settingId == "traderSalesBonus" then
        if not gs.activityBonuses then gs.activityBonuses = {} end
        gs.activityBonuses.traderSalesBonus = not gs.activityBonuses.traderSalesBonus
    elseif string.find(settingId, "^linkGuild_") then
        -- Toggle linked guild
        local linkedGuildId = tonumber(string.match(settingId, "linkGuild_(%d+)"))
        if linkedGuildId then
            if not gs.linkedGuilds then gs.linkedGuilds = {} end
            gs.linkedGuilds[linkedGuildId] = not gs.linkedGuilds[linkedGuildId]
        end
    end
end

function NWT.RaffleCycleSetting(gs, settingId, tabId, options)
    if settingId == "raffleSuffix" then
        local cur = (gs.raffleSuffixes and gs.raffleSuffixes[1]) or 1
        local nextIdx = ((cur) % 10)
        gs.raffleSuffixes = {nextIdx}
    elseif settingId == "rafflePeriod" then
        local presets = GetRafflePeriodPresets()
        local curId = gs.rafflePeriodId or "all"
        local curIdx = 1
        for i, p in ipairs(presets) do
            if p.id == curId then curIdx = i break end
        end
        gs.rafflePeriodId = presets[(curIdx % #presets) + 1].id
    elseif settingId == "numWinners" then
        if not gs.prizeConfig then gs.prizeConfig = {} end
        local cur = gs.prizeConfig.numWinners or 1
        local nextIdx = 1
        for i, v in ipairs(WINNER_OPTIONS) do
            if cur == v then nextIdx = (i % #WINNER_OPTIONS) + 1 break end
        end
        gs.prizeConfig.numWinners = WINNER_OPTIONS[nextIdx]
    elseif settingId == "poolPercentage" then
        if not gs.prizeConfig then gs.prizeConfig = {} end
        local cur = gs.prizeConfig.poolPercentage or 100
        local nextIdx = 1
        for i, v in ipairs(PERCENTAGE_OPTIONS) do
            if cur == v then nextIdx = (i % #PERCENTAGE_OPTIONS) + 1 break end
        end
        gs.prizeConfig.poolPercentage = PERCENTAGE_OPTIONS[nextIdx]
    elseif settingId == "distribution" then
        if not gs.prizeConfig then gs.prizeConfig = {} end
        local opts = {"equal", "tiered", "custom"}
        local cur = gs.prizeConfig.distribution or "equal"
        local curIdx = 1
        for i, v in ipairs(opts) do
            if cur == v then curIdx = i break end
        end
        gs.prizeConfig.distribution = opts[(curIdx % #opts) + 1]
    elseif settingId == "raffleType" then
        local opts = {"gold", "5050"}
        local cur = gs.raffleType or "gold"
        local curIdx = 1
        for i, v in ipairs(opts) do
            if cur == v then curIdx = i break end
        end
        gs.raffleType = opts[(curIdx % #opts) + 1]
    elseif settingId == "traderSalesPer" then
        if not gs.activityBonuses then gs.activityBonuses = {} end
        local opts = {10000, 25000, 50000, 100000, 250000, 500000}
        local cur = gs.activityBonuses.traderSalesPer or 100000
        local curIdx = 1
        for i, v in ipairs(opts) do
            if cur == v then curIdx = i break end
        end
        gs.activityBonuses.traderSalesPer = opts[(curIdx % #opts) + 1]
    end
end

function NWT.RaffleIncrementSetting(gs, settingId, tabId, direction)
    direction = direction or 1
    if settingId == "maxTickets" then
        if not gs.entryRules then gs.entryRules = {} end
        local cur = gs.entryRules.maxTickets or 0
        cur = cur + (10 * direction)
        if cur > 100 then cur = 0 elseif cur < 0 then cur = 100 end
        gs.entryRules.maxTickets = cur
    elseif settingId == "minTickets" then
        if not gs.entryRules then gs.entryRules = {} end
        local cur = gs.entryRules.minTickets or 0
        cur = cur + direction
        if cur > 10 then cur = 0 elseif cur < 0 then cur = 10 end
        gs.entryRules.minTickets = cur
    elseif settingId == "winnerCooldown" then
        if not gs.entryRules then gs.entryRules = {} end
        local cur = gs.entryRules.winnerCooldown or 0
        cur = cur + direction
        if cur > 4 then cur = 0 elseif cur < 0 then cur = 4 end
        gs.entryRules.winnerCooldown = cur
    elseif settingId == "onlineThresholdDays" then
        if not gs.entryRules then gs.entryRules = {} end
        local opts = {7, 14, 30, 60, 90}
        local cur = gs.entryRules.onlineThresholdDays or 7
        local curIdx = 1
        for i, v in ipairs(opts) do
            if cur == v then curIdx = i break end
        end
        curIdx = curIdx + direction
        if curIdx > #opts then curIdx = 1 elseif curIdx < 1 then curIdx = #opts end
        gs.entryRules.onlineThresholdDays = opts[curIdx]
    elseif settingId == "recruitmentBonus" then
        if not gs.activityBonuses then gs.activityBonuses = {} end
        local cur = gs.activityBonuses.recruitmentBonus or 0
        cur = cur + direction
        if cur > 20 then cur = 0 elseif cur < 0 then cur = 20 end
        gs.activityBonuses.recruitmentBonus = cur
    elseif settingId == "newMemberBonus" then
        if not gs.activityBonuses then gs.activityBonuses = {} end
        local cur = gs.activityBonuses.newMemberBonus or 0
        cur = cur + direction
        if cur > 20 then cur = 0 elseif cur < 0 then cur = 20 end
        gs.activityBonuses.newMemberBonus = cur
    elseif settingId == "longevityBonus" then
        if not gs.activityBonuses then gs.activityBonuses = {} end
        local cur = gs.activityBonuses.longevityBonus or 0
        cur = cur + direction
        if cur > 10 then cur = 0 elseif cur < 0 then cur = 10 end
        gs.activityBonuses.longevityBonus = cur
    elseif settingId == "simpleTicketPrice" then
        local cur = gs.simpleTicketPrice or 1000
        cur = cur + (500 * direction)
        if cur > 100000 then cur = 500 elseif cur < 500 then cur = 100000 end
        gs.simpleTicketPrice = cur
    elseif settingId == "doubleTicketDuration" then
        local cur = gs.doubleTicketDuration or 30
        cur = cur + (5 * direction)
        if cur > 120 then cur = 5 elseif cur < 5 then cur = 120 end
        gs.doubleTicketDuration = cur
    elseif settingId == "jackpotAmount" then
        if not gs.prizeConfig then gs.prizeConfig = {} end
        local cur = gs.prizeConfig.jackpotAmount or 0
        cur = cur + (50000 * direction)
        if cur < 0 then cur = 0 end
        if cur > 50000000 then cur = 50000000 end
        gs.prizeConfig.jackpotAmount = cur
    elseif settingId == "customStartMonth" then
        local cur = gs.customStartMonth or 1
        cur = cur + direction
        if cur > 12 then cur = 1 elseif cur < 1 then cur = 12 end
        gs.customStartMonth = cur
    elseif settingId == "customStartDay" then
        local cur = gs.customStartDay or 1
        cur = cur + direction
        if cur > 31 then cur = 1 elseif cur < 1 then cur = 31 end
        gs.customStartDay = cur
    elseif settingId == "customEndMonth" then
        local cur = gs.customEndMonth or 12
        cur = cur + direction
        if cur > 12 then cur = 1 elseif cur < 1 then cur = 12 end
        gs.customEndMonth = cur
    elseif settingId == "customEndDay" then
        local cur = gs.customEndDay or 31
        cur = cur + direction
        if cur > 31 then cur = 1 elseif cur < 1 then cur = 31 end
        gs.customEndDay = cur
    end
end

function NWT.RaffleDoAction(gs, actionId, tabId)
    if actionId == "addPack" then
        if not gs.ticketPacks then gs.ticketPacks = {} end
        local suffix = #gs.ticketPacks + 1
        if suffix > 9 then suffix = 1 end
        table.insert(gs.ticketPacks, { price = 1001, tickets = 1, suffix = suffix })
    elseif actionId == "removePack" then
        if gs.ticketPacks and #gs.ticketPacks > 0 then
            table.remove(gs.ticketPacks)
        end
    elseif actionId == "startDoubleTickets" then
        local isActive = gs.doubleTicketEndTime and gs.doubleTicketEndTime > GetTimeStamp()
        if isActive then
            -- Stop the session - set end time to now so past deposits still count
            gs.doubleTicketEndTime = GetTimeStamp()
            PlaySound(SOUNDS.NEGATIVE_CLICK)
        else
            -- Start the session
            local duration = (gs.doubleTicketDuration or 30) * 60  -- Convert minutes to seconds
            gs.doubleTicketStartTime = GetTimeStamp()
            gs.doubleTicketEndTime = GetTimeStamp() + duration
            PlaySound(SOUNDS.TELVAR_GAINED)
        end
    elseif actionId == "applyCustomDates" then
        -- Convert month/day to timestamps using current year
        local currentYear = tonumber(os.date("%Y"))
        local startMonth = gs.customStartMonth or 1
        local startDay = gs.customStartDay or 1
        local endMonth = gs.customEndMonth or 12
        local endDay = gs.customEndDay or 31
        
        -- Create timestamps (start at 00:00:00, end at 23:59:59)
        local success1, startTs = pcall(os.time, {year = currentYear, month = startMonth, day = startDay, hour = 0, min = 0, sec = 0})
        local success2, endTs = pcall(os.time, {year = currentYear, month = endMonth, day = endDay, hour = 23, min = 59, sec = 59})
        
        if success1 and success2 and startTs and endTs then
            gs.customRaffleStart = startTs
            gs.customRaffleEnd = endTs
            PlaySound(SOUNDS.POSITIVE_CLICK)
        else
            PlaySound(SOUNDS.NEGATIVE_CLICK)
        end
    end
end

-- Pack field editors
function NWT.RaffleEditPackPrice(gs, packIndex)
    local pack = gs.ticketPacks and gs.ticketPacks[packIndex]
    if not pack then return end
    local priceOpts = {500, 1000, 2000, 3000, 5000, 10000, 15000, 20000, 25000, 50000}
    local curIdx = 1
    for i, v in ipairs(priceOpts) do
        if pack.price >= v and pack.price < (priceOpts[i+1] or 999999) then curIdx = i break end
    end
    local basePrice = priceOpts[(curIdx % #priceOpts) + 1]
    pack.price = basePrice + pack.suffix
end

function NWT.RaffleEditPackTickets(gs, packIndex)
    local pack = gs.ticketPacks and gs.ticketPacks[packIndex]
    if not pack then return end
    local ticketOpts = {1, 2, 3, 5, 10, 15, 20, 25, 50}
    local curIdx = 1
    for i, v in ipairs(ticketOpts) do
        if pack.tickets == v then curIdx = i break end
    end
    pack.tickets = ticketOpts[(curIdx % #ticketOpts) + 1]
end

function NWT.RaffleEditPackSuffix(gs, packIndex)
    local pack = gs.ticketPacks and gs.ticketPacks[packIndex]
    if not pack then return end
    pack.suffix = (pack.suffix + 1) % 10
    -- Update price to match new suffix
    local basePrice = math.floor(pack.price / 10) * 10
    pack.price = basePrice + pack.suffix
end

-- Rank field editors
-- Helper to clean up rank bonus entry if all values are default
local function CleanupRankBonus(gs, rankIndex)
    if not gs.rankBonuses or not gs.rankBonuses.ranks then return end
    local rb = gs.rankBonuses.ranks[rankIndex]
    if rb and rb.freeTickets == 0 and rb.multiplier == 1.0 and (rb.weeklyAllowance or 0) == 0 then
        gs.rankBonuses.ranks[rankIndex] = nil
    end
end

function NWT.RaffleEditRankFree(gs, rankIndex)
    if not gs.rankBonuses then gs.rankBonuses = { enabled = false, ranks = {} } end
    if not gs.rankBonuses.ranks then gs.rankBonuses.ranks = {} end
    if not gs.rankBonuses.ranks[rankIndex] then
        gs.rankBonuses.ranks[rankIndex] = { freeTickets = 0, multiplier = 1.0, weeklyAllowance = 0 }
    end
    local rb = gs.rankBonuses.ranks[rankIndex]
    local freeOpts = {0, 1, 2, 3, 5, 10, 15, 20, 25, 50}
    local curIdx = 1
    for i, v in ipairs(freeOpts) do
        if rb.freeTickets == v then curIdx = i break end
    end
    rb.freeTickets = freeOpts[(curIdx % #freeOpts) + 1]
    CleanupRankBonus(gs, rankIndex)
end

function NWT.RaffleEditRankMult(gs, rankIndex, direction)
    if not gs.rankBonuses then gs.rankBonuses = { enabled = false, ranks = {} } end
    if not gs.rankBonuses.ranks then gs.rankBonuses.ranks = {} end
    if not gs.rankBonuses.ranks[rankIndex] then
        gs.rankBonuses.ranks[rankIndex] = { freeTickets = 0, multiplier = 1.0, weeklyAllowance = 0 }
    end
    local rb = gs.rankBonuses.ranks[rankIndex]
    local curIdx = 1
    for i, v in ipairs(MULTIPLIER_OPTIONS) do
        if rb.multiplier == v then curIdx = i break end
    end
    if direction == -1 then
        -- Y button - decrease
        curIdx = curIdx - 1
        if curIdx < 1 then curIdx = #MULTIPLIER_OPTIONS end
    else
        -- A button - increase
        curIdx = curIdx + 1
        if curIdx > #MULTIPLIER_OPTIONS then curIdx = 1 end
    end
    rb.multiplier = MULTIPLIER_OPTIONS[curIdx]
    CleanupRankBonus(gs, rankIndex)
end

function NWT.RaffleEditRankWeekly(gs, rankIndex)
    if not gs.rankBonuses then gs.rankBonuses = { enabled = false, ranks = {} } end
    if not gs.rankBonuses.ranks then gs.rankBonuses.ranks = {} end
    if not gs.rankBonuses.ranks[rankIndex] then
        gs.rankBonuses.ranks[rankIndex] = { freeTickets = 0, multiplier = 1.0, weeklyAllowance = 0 }
    end
    local rb = gs.rankBonuses.ranks[rankIndex]
    local weeklyOpts = {0, 10, 25, 50, 100, 150, 200, 250, 300, 500}
    local curIdx = 1
    for i, v in ipairs(weeklyOpts) do
        if rb.weeklyAllowance == v then curIdx = i break end
    end
    rb.weeklyAllowance = weeklyOpts[(curIdx % #weeklyOpts) + 1]
    CleanupRankBonus(gs, rankIndex)
end

function NWT.RaffleToggleRankExempt(gs, rankIndex)
    if not gs.raffleExemptRanks then gs.raffleExemptRanks = {} end
    gs.raffleExemptRanks[rankIndex] = not gs.raffleExemptRanks[rankIndex]
end

function NWT.CloseRaffleSettingsDialog()
    local rf = NWT.Raffle
    rf.settingsMenuOpen = false
    rf.settingsGuildId = nil
    rf.settingsTabIndex = 1
    rf.settingsRowIndex = 1
    rf.currentTabSettings = nil
    if ATK_RaffleSettingsDialog then ATK_RaffleSettingsDialog:SetHidden(true) end
    if KEYBIND_STRIP and NWT.HiddenRaffleListScreen then 
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenRaffleListScreen.keybindStripDescriptor) 
    end
end

-- ============================================
-- SCENE INITIALIZATION
-- ============================================

local ATK_HiddenRaffleListScreen = ZO_Gamepad_ParametricList_Screen:Subclass()
function ATK_HiddenRaffleListScreen:New(control) return ZO_Gamepad_ParametricList_Screen.New(self, control) end
function ATK_HiddenRaffleListScreen:Initialize(control) ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, NWT.RaffleScene) end
function ATK_HiddenRaffleListScreen:PerformUpdate() end

function ATK_HiddenRaffleListScreen:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = function() 
              if NWT.Raffle.raffleWinnerDialogOpen then return "Reroll" end
              if NWT.Raffle.rafflePickerOpen then return "Pick Winners" end
              if NWT.Raffle.participantDetailsOpen then return "Close" end
              return NWT.Raffle.focusPanel == "guilds" and "Select Guild" or "View Details"
          end, 
          keybind = "UI_SHORTCUT_PRIMARY", 
          callback = function() 
              if NWT.Raffle.raffleWinnerDialogOpen then NWT.RaffleReroll() return end
              if NWT.Raffle.rafflePickerOpen then NWT.RaffleRunPicker() return end
              if NWT.Raffle.participantDetailsOpen then NWT.CloseParticipantDetails() return end
              if NWT.Raffle.settingsMenuOpen then NWT.RaffleChangeSettingValue(1) return end
              if NWT.Raffle.focusPanel == "guilds" then NWT.RaffleSelectGuild() return end
              if NWT.Raffle.focusPanel == "entries" then NWT.ShowParticipantDetails() end
          end 
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = function() 
              if NWT.Raffle.settingsMenuOpen then return "Decrease" end
              if NWT.Raffle.focusPanel == "guilds" then return "Favorite" end
              return "Pick Winner"
          end, 
          keybind = "UI_SHORTCUT_TERTIARY", 
          callback = function() 
              if NWT.Raffle.settingsMenuOpen then NWT.RaffleChangeSettingValue(-1) return end
              if NWT.Raffle.focusPanel == "guilds" then NWT.RaffleFavoriteSelectedGuild() return end
              NWT.RaffleShowPicker() 
          end,
          enabled = function() return not NWT.Raffle.rafflePickerOpen end
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = "Settings", 
          keybind = "UI_SHORTCUT_SECONDARY", 
          callback = function() NWT.RaffleShowSettings() end,
          enabled = function() return not NWT.Raffle.settingsMenuOpen and not NWT.Raffle.rafflePickerOpen end
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = function() return NWT.Raffle.settingsMenuOpen and "Prev Tab" or "Navigate Left" end,
          keybind = "UI_SHORTCUT_LEFT_SHOULDER", 
          callback = function() 
              if NWT.Raffle.settingsMenuOpen then 
                  NWT.RaffleSettingsChangeTab("left") 
              else 
                  NWT.RaffleSwitchPanel("left") 
              end
          end,
          enabled = function() return not NWT.Raffle.rafflePickerOpen end
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = function() return NWT.Raffle.settingsMenuOpen and "Next Tab" or "Navigate Right" end,
          keybind = "UI_SHORTCUT_RIGHT_SHOULDER", 
          callback = function() 
              if NWT.Raffle.settingsMenuOpen then 
                  NWT.RaffleSettingsChangeTab("right") 
              else 
                  NWT.RaffleSwitchPanel("right") 
              end
          end,
          enabled = function() return not NWT.Raffle.rafflePickerOpen end
        },
        { alignment = KEYBIND_STRIP_ALIGN_RIGHT, 
          name = function() return "Scan: " .. GetGuildName(GetGuildId(NWT.Raffle.viewingGuildIndex)) end, 
          keybind = "UI_SHORTCUT_RIGHT_STICK", 
          callback = function() 
              if NWT.ScanGuildForBookkeeper then 
                  NWT.ScanGuildForBookkeeper(GetGuildId(NWT.Raffle.viewingGuildIndex)) 
              end
          end,
          enabled = function() return not NWT.Raffle.settingsMenuOpen and not NWT.Raffle.rafflePickerOpen end
        },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, function()
        if NWT.Raffle.raffleWinnerDialogOpen then NWT.CloseRaffleWinnerDialog() return end
        if NWT.Raffle.participantDetailsOpen then NWT.CloseParticipantDetails() return end
        if NWT.Raffle.rafflePickerOpen then 
            NWT.Raffle.rafflePickerOpen = false
            if ATK_RafflePickerDialog then ATK_RafflePickerDialog:SetHidden(true) end
            KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
            return 
        end
        if NWT.Raffle.settingsMenuOpen then NWT.CloseRaffleSettingsDialog() return end
        NWT.CloseRaffle()
    end)
end

function NWT.InitRaffleScene()
    if NWT.Raffle.sceneInitialized then return end
    local ui = ATK_Raffle_UI
    if not ui then return end
    
    local hc = WINDOW_MANAGER:CreateControlFromVirtual("ATK_HiddenRaffleList", GuiRoot, "ATK_HouseList_Screen")
    hc:SetHidden(true) hc:SetAlpha(0)
    
    NWT.RaffleScene = ZO_Scene:New("raffleScene", SCENE_MANAGER)
    NWT.RaffleScene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    NWT.RaffleScene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    NWT.RaffleScene:AddFragment(ZO_FadeSceneFragment:New(ui))
    NWT.RaffleScene:AddFragment(ZO_SimpleSceneFragment:New(hc))
    
    NWT.HiddenRaffleListScreen = ATK_HiddenRaffleListScreen:New(hc)
    NWT.HiddenRaffleList = NWT.HiddenRaffleListScreen:GetMainList()
    NWT.HiddenRaffleList:AddDataTemplate("ZO_GamepadItemEntryTemplate", function(c, d) end, ZO_GamepadMenuEntryTemplateParametricListFunction)
    
    NWT.HiddenRaffleList.MovePrevious = function(self, ...)
        if NWT.Raffle.settingsMenuOpen then NWT.RaffleCycleSettingsOption("up") return end
        if NWT.Raffle.rafflePickerOpen then NWT.RaffleAdjustWinnerCount("up") return end
        if NWT.Raffle.focusPanel == "guilds" then NWT.RaffleScrollGuild("up")
        else NWT.RaffleScrollEntries("up") end
    end
    NWT.HiddenRaffleList.MoveNext = function(self, ...)
        if NWT.Raffle.settingsMenuOpen then NWT.RaffleCycleSettingsOption("down") return end
        if NWT.Raffle.rafflePickerOpen then NWT.RaffleAdjustWinnerCount("down") return end
        if NWT.Raffle.focusPanel == "guilds" then NWT.RaffleScrollGuild("down")
        else NWT.RaffleScrollEntries("down") end
    end
    
    NWT.RaffleScene:RegisterCallback("StateChange", function(os, ns)
        if ns == SCENE_SHOWING then
            NWT.Raffle.isOpen = true
            NWT.Raffle.sortedGuildList = nil  -- Force rebuild to get current favorites
            NWT.Raffle.selectedGuildIndex = 1
            NWT.Raffle.focusPanel = "entries"
            NWT.Raffle.raffleScrollOffset = 0
            NWT.Raffle.selectedEntryIndex = 1
            NWT.UpdateRaffleUI()
            -- Set viewing guild to first sorted guild (favorites first)
            local rf = NWT.Raffle
            if rf.sortedGuildList and rf.sortedGuildList[1] then
                rf.viewingGuildIndex = rf.sortedGuildList[1].index
            else
                rf.viewingGuildIndex = 1
            end
            NWT.UpdateRaffleUI()
            if ui.timeline then ui.timeline:PlayForward() end
        elseif ns == SCENE_SHOWN then
            if NWT.HiddenRaffleList then NWT.HiddenRaffleList:Activate() end
        elseif ns == SCENE_HIDDEN then
            NWT.Raffle.isOpen = false
            if NWT.HiddenRaffleList then NWT.HiddenRaffleList:Deactivate() end
        end
    end)
    
    NWT.Raffle.sceneInitialized = true
end

function NWT.OpenRaffle()
    if NWT.Raffle.isOpen then return end
    if not NWT.RaffleScene then NWT.InitRaffleScene() end
    SCENE_MANAGER:Push("raffleScene")
end

function NWT.CloseRaffle()
    if NWT.RaffleScene then SCENE_MANAGER:Hide("raffleScene") end
end
