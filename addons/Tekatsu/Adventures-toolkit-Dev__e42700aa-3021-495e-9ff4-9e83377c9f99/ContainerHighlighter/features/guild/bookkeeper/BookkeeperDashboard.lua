-- ============================================
-- GUILD BOOKKEEPER MODULE
-- ============================================

NWT.Bookkeeper = {
    isOpen = false,
    sceneInitialized = false,
    selectedGuildIndex = 1,   -- Cursor position in Guilds panel
    viewingGuildIndex = 1,    -- Guild currently shown in Dues panels
    selectedMemberIndex = 1,
    memberScrollOffset = 0,
    maxVisibleMembers = 13,
    sortedMembers = {},
    isScanning = false,
    isHistoryScanning = false,
    historyScanGuildId = nil,
    historyScanQueue = {},
    filterMode = 1,  -- 1=All, 2=Unpaid, 3=Paid, 4=A-Z, 5=Z-A, 6=Last Paid
    filterModes = {"All Members", "Unpaid Only", "Paid Only", "Name A-Z", "Name Z-A", "Last Paid"},
    searchText = "",  -- Current search filter
    focusPanel = "dues",  -- "guilds", "dues", "actions"
    selectedActionIndex = 1,  -- Quick actions selection
    salesScrollOffset = 0,
    maxVisibleSales = 12,
    activeGuilds = {}, -- [guildId] = bool
    demoMode = false,  -- Set to true for testing with fake data
}

-- Quick actions definition
local QUICK_ACTIONS = {
    { id = "settings", label = "Dues Settings", callback = function() NWT.BookkeeperShowDuesSettings() end },
    { id = "details", label = "View Details", callback = function() NWT.ShowMemberDetails() end },
    { id = "updateNote", label = "Update Note", callback = function() NWT.BookkeeperUpdateMemberNote() end },
    { id = "setRank", label = "Set Rank", callback = function() NWT.BookkeeperShowRankMenu() end },
    { id = "kick", label = "|cFF4444Kick Member|r", callback = function() NWT.BookkeeperKickMember() end },
}

-- Demo data for testing the UI
local DEMO_MEMBERS = {
    { name = "@GuildMaster_Alex", rankIndex = 1, duesMonths = 12, thisWeekDues = 1, totalDeposited = 125000, raffleTotal = 15000, otherTotal = 5000, lastPayment = GetTimeStamp() - 86400, isLifetime = false },
    { name = "@OfficerBeth", rankIndex = 2, duesMonths = 8, thisWeekDues = 1, totalDeposited = 85000, raffleTotal = 25000, otherTotal = 0, lastPayment = GetTimeStamp() - 172800, isLifetime = false },
    { name = "@TreasurerCarl", rankIndex = 2, duesMonths = 6, thisWeekDues = 0, totalDeposited = 65000, raffleTotal = 5000, otherTotal = 10000, lastPayment = GetTimeStamp() - 432000, isLifetime = true },
    { name = "@VeteranDiana", rankIndex = 3, duesMonths = 4, thisWeekDues = 1, totalDeposited = 45000, raffleTotal = 10000, otherTotal = 0, lastPayment = GetTimeStamp() - 86400, isLifetime = false },
    { name = "@MemberEric", rankIndex = 4, duesMonths = 3, thisWeekDues = 0, totalDeposited = 25000, raffleTotal = 5000, otherTotal = 0, lastPayment = GetTimeStamp() - 604800, isLifetime = false },
    { name = "@MemberFiona", rankIndex = 4, duesMonths = 2, thisWeekDues = 1, totalDeposited = 20000, raffleTotal = 8000, otherTotal = 2000, lastPayment = GetTimeStamp() - 259200, isLifetime = false },
    { name = "@NewbieGary", rankIndex = 5, duesMonths = 1, thisWeekDues = 1, totalDeposited = 10000, raffleTotal = 3000, otherTotal = 0, lastPayment = GetTimeStamp() - 86400, isLifetime = false },
    { name = "@NewbieHannah", rankIndex = 5, duesMonths = 0, thisWeekDues = 0, totalDeposited = 5000, raffleTotal = 5000, otherTotal = 0, lastPayment = GetTimeStamp() - 1209600, isLifetime = false },
    { name = "@SlackerIvan", rankIndex = 4, duesMonths = 0, thisWeekDues = 0, totalDeposited = 0, raffleTotal = 0, otherTotal = 0, lastPayment = 0, isLifetime = false },
    { name = "@InactiveJane", rankIndex = 5, duesMonths = 0, thisWeekDues = 0, totalDeposited = 2500, raffleTotal = 0, otherTotal = 2500, lastPayment = GetTimeStamp() - 2592000, isLifetime = false },
    { name = "@RichKyle", rankIndex = 3, duesMonths = 24, thisWeekDues = 1, totalDeposited = 500000, raffleTotal = 100000, otherTotal = 50000, lastPayment = GetTimeStamp() - 43200, isLifetime = false },
    { name = "@LifetimeLisa", rankIndex = 2, duesMonths = 0, thisWeekDues = 0, totalDeposited = 1000000, raffleTotal = 50000, otherTotal = 0, lastPayment = GetTimeStamp() - 7776000, isLifetime = true },
    { name = "@ExemptMike", rankIndex = 1, duesMonths = 0, thisWeekDues = 0, totalDeposited = 0, raffleTotal = 0, otherTotal = 0, lastPayment = 0, isExemptRank = true },
    { name = "@PrepaidNancy", rankIndex = 4, duesMonths = 6, thisWeekDues = 0, totalDeposited = 35000, raffleTotal = 0, otherTotal = 5000, lastPayment = GetTimeStamp() - 1814400, isLifetime = false },
    { name = "@LateOliver", rankIndex = 5, duesMonths = 0, thisWeekDues = 0, totalDeposited = 7500, raffleTotal = 2500, otherTotal = 0, lastPayment = GetTimeStamp() - 3024000, isLifetime = false },
    { name = "@RegularPaula", rankIndex = 4, duesMonths = 5, thisWeekDues = 1, totalDeposited = 32000, raffleTotal = 7000, otherTotal = 0, lastPayment = GetTimeStamp() - 172800, isLifetime = false },
    { name = "@QuietQuinn", rankIndex = 5, duesMonths = 1, thisWeekDues = 0, totalDeposited = 6000, raffleTotal = 1000, otherTotal = 0, lastPayment = GetTimeStamp() - 950400, isLifetime = false },
    { name = "@ActiveRachel", rankIndex = 3, duesMonths = 7, thisWeekDues = 1, totalDeposited = 75000, raffleTotal = 20000, otherTotal = 5000, lastPayment = GetTimeStamp() - 14400, isLifetime = false },
    { name = "@SilentSam", rankIndex = 5, duesMonths = 0, thisWeekDues = 0, totalDeposited = 0, raffleTotal = 0, otherTotal = 0, lastPayment = 0, isLifetime = false },
    { name = "@TradingTom", rankIndex = 4, duesMonths = 3, thisWeekDues = 1, totalDeposited = 28000, raffleTotal = 13000, otherTotal = 0, lastPayment = GetTimeStamp() - 86400, isLifetime = false },
}

local DEMO_RANKS = {
    { name = "Guild Master", index = 1 },
    { name = "Officer", index = 2 },
    { name = "Veteran", index = 3 },
    { name = "Member", index = 4 },
    { name = "Recruit", index = 5 },
}

local DEMO_GUILDS = {
    { id = 0, name = "Demo Trading Guild", memberCount = 500, isFavorite = true },
    { id = -1, name = "Demo Social Guild", memberCount = 150, isFavorite = false },
    { id = -2, name = "Demo PvP Guild", memberCount = 75, isFavorite = false },
}

-- Demo settings storage
NWT.Bookkeeper.demoSettings = nil
local FREE_TRADER_DEFAULT_TARGET = 30

local function GetDemoSettings()
    if not NWT.Bookkeeper.demoSettings then
        NWT.Bookkeeper.demoSettings = {
            duesAmount = 5000,
            duesPeriod = "weekly",
            customDaysPeriod = 7,
            duesSuffix = 0,
            raffleSuffixes = {1, 5},
            ticketPrice = 1000,
            gracePeriodDays = 3,
            lateFeeEnabled = false,
            lateFeeAmount = 0,
            exemptRanks = { [1] = true },  -- Guild Master exempt
            rankDuesOverride = {},
            autoUpdateNotes = false,
            noteFormat = "range",
            includeUpdateTimestamp = true,
            alertUnpaidCount = 0,
            alertOnLogin = false,
            highlightOverdue = true,
            lifetimeMembers = { ["@TreasurerCarl"] = true, ["@LifetimeLisa"] = true },
            specialSuffixes = {},
            memberPayments = {},
            lastScanTime = GetTimeStamp() - 3600,
            traderFlipDay = 3,
            sortBy = "status",
            showOfflineStatus = false,
            freeTraderMode = false,
            listingTarget = FREE_TRADER_DEFAULT_TARGET,
            memberListingCounts = {},
            listingsLastScanTime = 0,
            listingsScanInProgress = false,
            listingsLastFailureTime = 0,
        }
        -- Build demo member payments
        for _, m in ipairs(DEMO_MEMBERS) do
            local demoListings = math.max(0, math.min(FREE_TRADER_DEFAULT_TARGET, ((m.duesMonths or 0) * 3) + ((m.thisWeekDues or 0) * 2)))
            NWT.Bookkeeper.demoSettings.memberListingCounts[m.name] = demoListings
            NWT.Bookkeeper.demoSettings.memberPayments[m.name] = {
                name = m.name,
                totalDeposited = m.totalDeposited,
                duesMonths = m.duesMonths,
                raffleTotal = m.raffleTotal,
                otherTotal = m.otherTotal,
                lastPayment = m.lastPayment,
                thisWeekDues = m.thisWeekDues,
                thisWeekRaffle = m.raffleTotal > 0 and math.floor(m.raffleTotal / 4) or 0,
                deposits = {},
                rankIndex = m.rankIndex,
                isCurrentMember = true,
                isExemptRank = m.isExemptRank or false,
                listingsCount = demoListings,
            }
        end
    end
    if type(NWT.Bookkeeper.demoSettings.memberListingCounts) ~= "table" then
        NWT.Bookkeeper.demoSettings.memberListingCounts = {}
    end
    if type(NWT.Bookkeeper.demoSettings.listingTarget) ~= "number" or NWT.Bookkeeper.demoSettings.listingTarget < 1 then
        NWT.Bookkeeper.demoSettings.listingTarget = FREE_TRADER_DEFAULT_TARGET
    end
    if NWT.Bookkeeper.demoSettings.freeTraderMode ~= true then
        NWT.Bookkeeper.demoSettings.freeTraderMode = false
    end
    if type(NWT.Bookkeeper.demoSettings.listingsLastScanTime) ~= "number" then
        NWT.Bookkeeper.demoSettings.listingsLastScanTime = 0
    end
    if NWT.Bookkeeper.demoSettings.listingsScanInProgress ~= true then
        NWT.Bookkeeper.demoSettings.listingsScanInProgress = false
    end
    if type(NWT.Bookkeeper.demoSettings.listingsLastFailureTime) ~= "number" then
        NWT.Bookkeeper.demoSettings.listingsLastFailureTime = 0
    end
    return NWT.Bookkeeper.demoSettings
end

local function IsGuildEnabled(guildId)
    local sv = NWT.savedVars
    if not sv.bookkeeper then sv.bookkeeper = {} end
    if not sv.bookkeeper.enabledGuilds then sv.bookkeeper.enabledGuilds = {} end
    if sv.bookkeeper.enabledGuilds[guildId] == nil then
        sv.bookkeeper.enabledGuilds[guildId] = true -- Default to enabled
    end
    return sv.bookkeeper.enabledGuilds[guildId]
end

local function ToggleGuildEnabled(guildId)
    local sv = NWT.savedVars
    if not sv.bookkeeper then sv.bookkeeper = {} end
    if not sv.bookkeeper.enabledGuilds then sv.bookkeeper.enabledGuilds = {} end
    sv.bookkeeper.enabledGuilds[guildId] = not sv.bookkeeper.enabledGuilds[guildId]
    return sv.bookkeeper.enabledGuilds[guildId]
end

local function IsGuildFavorite(guildId)
    local sv = NWT.savedVars
    if not sv.bookkeeper then sv.bookkeeper = {} end
    if not sv.bookkeeper.favoriteGuilds then sv.bookkeeper.favoriteGuilds = {} end
    return sv.bookkeeper.favoriteGuilds[guildId] == true
end

local function ToggleGuildFavorite(guildId)
    local sv = NWT.savedVars
    if not sv.bookkeeper then sv.bookkeeper = {} end
    if not sv.bookkeeper.favoriteGuilds then sv.bookkeeper.favoriteGuilds = {} end
    sv.bookkeeper.favoriteGuilds[guildId] = not sv.bookkeeper.favoriteGuilds[guildId]
    return sv.bookkeeper.favoriteGuilds[guildId]
end

-- Default bookkeeper settings per guild (comprehensive)
local function GetDefaultBookkeeperSettings()
    return {
        -- Basic Dues Settings
        duesAmount = 5000,
        duesPeriod = "weekly",          -- "weekly", "biweekly", "monthly", "custom"
        customDaysPeriod = 7,           -- days for custom period
        duesSuffix = 0,                 -- deposit ending digit for dues (0 = any ending)
        
        -- Raffle Settings (legacy, most moved to Raffle.lua)
        raffleSuffixes = {1, 5},
        ticketPrice = 1000,
        rafflePeriodId = "all",
        
        -- Grace Period & Late Fees
        gracePeriodDays = 3,            -- days after due before marked late
        lateFeeEnabled = false,
        lateFeeAmount = 0,              -- additional gold if late
        
        -- Rank Configuration
        exemptRanks = {},               -- [rankIndex] = true for exempt
        rankDuesOverride = {},          -- [rankIndex] = {amount, period}
        
        -- Auto-Demotion System
        autoDemoteEnabled = false,      -- full auto mode - demotes without confirmation
        demotionRank = nil,             -- rank index to demote unpaid members to
        daysBeforeDemotion = 7,         -- days overdue before demotion triggers
        originalRanks = {},             -- [memberName] = originalRankIndex (for restoration)
        demotedMembers = {},            -- [memberName] = {originalRank, amountOwed, demotedAt}
        
        -- Note Management
        autoUpdateNotes = false,        -- automatically update member notes
        noteFormat = "range",           -- "range" (1/1-2/1), "due" (Due: 2/1), "paid" (Paid thru 2/1)
        includeUpdateTimestamp = true,  -- add "Upd: X/X" to notes
        
        -- Alerts & Notifications
        alertUnpaidCount = 0,           -- alert if unpaid > X (0 = disabled)
        alertOnLogin = false,           -- show unpaid summary on login
        highlightOverdue = true,        -- highlight overdue members in red
        
        -- Lifetime & Special Members
        lifetimeMembers = {},           -- [memberName] = true
        specialSuffixes = {},           -- special deposit suffixes
        
        -- Tracking Data
        memberPayments = {},
        paymentHistory = {},
        pastWinners = {},
        salesData = {},
        lastScanTime = 0,
        lastNotesScan = 0,
        traderFlipDay = 3,              -- 1=Sun, 2=Mon, 3=Tue, etc.
        
        -- Display Preferences
        sortBy = "status",              -- "status", "name", "rank", "lastPaid", "amount"
        showOfflineStatus = false,      -- show last online time

        -- Free Trader mode (listings-first)
        freeTraderMode = false,
        listingTarget = FREE_TRADER_DEFAULT_TARGET,
        memberListingCounts = {},       -- [memberName] = listingCount
        listingsLastScanTime = 0,
        listingsScanInProgress = false,
        listingsLastFailureTime = 0,
    }
end

-- Note format templates using placeholders: {START}, {END}, {UPD}
local NOTE_FORMAT_TEMPLATES = {
    range = "{START}-{END} Upd:{UPD}",
    due = "Due: {END} Upd:{UPD}",
    paid = "Paid thru {END} Upd:{UPD}",
}

-- Clean up corrupted payment history data (invalid dates like year=-1874, month=0)
local function CleanupPaymentHistory(gs)
    if not gs.paymentHistory then return end
    for memberName, ph in pairs(gs.paymentHistory) do
        if ph.payments then
            local validPayments = {}
            for _, payment in ipairs(ph.payments) do
                local dueMonth = tonumber(payment.dueMonth) or 0
                local dueDay = tonumber(payment.dueDay) or 0
                local dueYear = tonumber(payment.dueYear) or 0
                -- Only keep payments with valid dates
                if dueMonth >= 1 and dueMonth <= 12 and dueDay >= 1 and dueDay <= 31 and dueYear > 2000 then
                    table.insert(validPayments, payment)
                end
            end
            ph.payments = validPayments
        end
    end
end

local function GetBookkeeperGuildSettings(guildId)
    local sv = NWT.savedVars
    if not sv.bookkeeper then sv.bookkeeper = {} end
    if not sv.bookkeeper.guilds then sv.bookkeeper.guilds = {} end
    if not sv.bookkeeper.guilds[guildId] then
        sv.bookkeeper.guilds[guildId] = GetDefaultBookkeeperSettings()
    end
    -- Migrate old settings to new structure
    local gs = sv.bookkeeper.guilds[guildId]
    local defaults = GetDefaultBookkeeperSettings()
    for k, v in pairs(defaults) do
        if gs[k] == nil then gs[k] = v end
    end
    if not gs.lifetimeMembers then gs.lifetimeMembers = {} end
    if not gs.exemptRanks then gs.exemptRanks = {} end
    if type(gs.memberListingCounts) ~= "table" then gs.memberListingCounts = {} end
    if type(gs.listingsLastScanTime) ~= "number" then gs.listingsLastScanTime = 0 end
    if type(gs.listingsLastFailureTime) ~= "number" then gs.listingsLastFailureTime = 0 end
    if gs.freeTraderMode ~= true then gs.freeTraderMode = false end
    if type(gs.listingTarget) ~= "number" or gs.listingTarget < 1 then
        gs.listingTarget = FREE_TRADER_DEFAULT_TARGET
    end
    -- Clean up any corrupted payment history data
    CleanupPaymentHistory(gs)
    return gs
end

local function NormalizeDisplayName(displayName)
    if not displayName or displayName == "" then return nil end
    if not displayName:find("^@") then
        return "@" .. displayName
    end
    return displayName
end

local function IsFreeTraderMode(guildSettings)
    return guildSettings and guildSettings.freeTraderMode == true
end

local function GetListingTarget(guildSettings)
    return FREE_TRADER_DEFAULT_TARGET
end

local function IsRankExempt(guildSettings, rankIndex, guildId)
    -- GM auto-exempt disabled for testing (can be re-enabled later)
    -- if guildId and IsGuildRankGuildMaster(guildId, rankIndex) then return true end
    local exemptType = guildSettings.exemptRanks and guildSettings.exemptRanks[rankIndex]
    -- Any truthy value means exempt (true, "gm", "officer", "lifetime")
    return exemptType ~= nil and exemptType ~= false
end

-- Parse a deposit amount to determine if it's dues, raffle, or other
local function ParseDepositType(amount, guildSettings)
    local duesAmount = guildSettings.duesAmount or 5000
    local lastDigit = amount % 10
    
    -- Check raffle FIRST - if last digit matches raffle suffix
    for _, suffix in ipairs(guildSettings.raffleSuffixes or {}) do
        local suffixNum = tonumber(suffix) or suffix
        if lastDigit == suffixNum then return "raffle", amount end
    end
    
    -- Everything else is dues - calculate how many periods it covers
    if duesAmount > 0 and amount >= duesAmount then
        local periods = math.floor(amount / duesAmount)
        return "dues", periods
    end
    
    -- Small deposits that don't reach dues amount are donations
    return "other", amount
end

-- Get trader flip timestamp for current period (Tuesday)
local function GetCurrentTraderFlipStart()
    local now = GetTimeStamp()
    local flipDay = 3
    local daysSinceEpoch = math.floor(now / 86400)
    local dayOfWeek = ((daysSinceEpoch + 4) % 7) + 1
    local daysSinceFlip = (dayOfWeek - flipDay) % 7
    local flipTimestamp = now - (daysSinceFlip * 86400)
    return flipTimestamp - (flipTimestamp % 86400)
end

-- Raffle period presets
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

-- ============================================
-- NOTE PARSING AND DUE DATE MANAGEMENT
-- ============================================

-- Parse date string in various formats (1/1/25, 01/01/2025, 1-1-25, etc.)
local function ParseDateString(dateStr)
    if not dateStr then return nil end
    -- Try different patterns: M/D/YY, M/D/YYYY, M-D-YY, M-D-YYYY
    local m, d, y = dateStr:match("(%d+)[/%-%.]+(%d+)[/%-%.]+(%d+)")
    if not m then return nil end
    m, d, y = tonumber(m), tonumber(d), tonumber(y)
    if not m or not d or not y then return nil end
    -- Convert 2-digit year to 4-digit
    if y < 100 then y = y + 2000 end
    -- Validate ranges
    if m < 1 or m > 12 or d < 1 or d > 31 or y < 2020 or y > 2100 then return nil end
    -- Return as timestamp (midnight on that date)
    return os.time({year = y, month = m, day = d, hour = 0, min = 0, sec = 0})
end

-- Format timestamp to short date string (M/D/YY)
local function FormatShortDate(timestamp)
    if not timestamp or timestamp == 0 then return "" end
    return os.date("%m/%d/%y", timestamp):gsub("^0", ""):gsub("/0", "/")
end

-- Build a Lua pattern from a note format template to extract dates
-- Template placeholders: {START}, {END}, {UPD}
-- Returns a pattern and capture order table
local function BuildPatternFromTemplate(template)
    if not template or template == "" then return nil, nil end
    
    -- Date pattern that captures M/D/YY or M/D/YYYY
    local datePattern = "(%d+[/%-%.]+%d+[/%-%.]*%d*)"
    
    -- Escape special pattern characters in template
    local pattern = template:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    
    -- Track which placeholders we find and their order
    local captureOrder = {}
    
    -- Replace placeholders with date capture pattern
    -- We need to track the order they appear
    local placeholders = { "{START}", "{END}", "{UPD}" }
    local placeholderNames = { ["{START}"] = "start", ["{END}"] = "end", ["{UPD}"] = "upd" }
    
    -- Find positions of each placeholder
    local positions = {}
    for _, ph in ipairs(placeholders) do
        local pos = template:find(ph, 1, true)
        if pos then
            table.insert(positions, { pos = pos, ph = ph, name = placeholderNames[ph] })
        end
    end
    
    -- Sort by position
    table.sort(positions, function(a, b) return a.pos < b.pos end)
    
    -- Build capture order and replace in pattern
    for _, p in ipairs(positions) do
        table.insert(captureOrder, p.name)
        -- Escape the placeholder for pattern replacement
        local escapedPh = p.ph:gsub("([{}])", "%%%1")
        pattern = pattern:gsub(escapedPh, datePattern, 1)
    end
    
    return pattern, captureOrder
end

-- Parse due date from guild member note using custom template if available
-- Supports: "due 1/1/25", "Due: 1/5/26", "1/1/26-2/1/26", "paid thru 2/1/26", "Upd:1/6/26"
-- Also tries to match against guild's custom note format template
local function ParseDueDateFromNote(note, guildSettings)
    if not note or note == "" then return nil end
    
    -- Early exit: if no digits, no date to parse (saves CPU on empty/text-only notes)
    if not note:find("%d") then return nil end
    
    local result = { startDate = nil, endDate = nil, lastUpdate = nil }
    
    -- Try custom template first if available (skip if noteFormat is not "custom")
    local gs = guildSettings
    if gs and gs.noteFormat == "custom" and gs.customNoteFormat and gs.customNoteFormat ~= "" then
        local pattern, captureOrder = BuildPatternFromTemplate(gs.customNoteFormat)
        if pattern and #captureOrder > 0 then
            local captures = { note:match(pattern) }
            if #captures > 0 then
                for i, name in ipairs(captureOrder) do
                    if captures[i] then
                        if name == "start" then
                            result.startDate = ParseDateString(captures[i])
                        elseif name == "end" then
                            result.endDate = ParseDateString(captures[i])
                        elseif name == "upd" then
                            result.lastUpdate = ParseDateString(captures[i])
                        end
                    end
                end
                -- If we found dates via custom template, return early
                if result.startDate or result.endDate then
                    return result
                end
            end
        end
    end
    
    -- Fall back to standard patterns (simpler, faster regex)
    
    -- Look for date range format: "1/1/26-2/1/26"
    local d1, d2 = note:match("(%d+/%d+/%d+)%-(%d+/%d+/%d+)")
    if d1 and d2 then
        result.startDate = ParseDateString(d1)
        result.endDate = ParseDateString(d2)
        return result
    end
    
    -- Look for "due X" or "Due: X" format
    local dueDate = note:match("[Dd]ue:?%s*(%d+/%d+/%d+)")
    if dueDate then
        result.endDate = ParseDateString(dueDate)
        return result
    end
    
    -- Look for "thru X" format
    local thruDate = note:match("[Tt]hru%s*(%d+/%d+/%d+)")
    if thruDate then
        result.endDate = ParseDateString(thruDate)
        return result
    end
    
    -- Look for "Upd:" timestamp
    local updDate = note:match("[Uu]pd:?%s*(%d+/%d+/%d+)")
    if updDate then
        result.lastUpdate = ParseDateString(updDate)
    end
    
    return result
end

-- Get last note update timestamp for a member
local function GetLastNoteUpdate(guildId, memberName)
    local sv = NWT.savedVars
    if not sv.bookkeeper then return nil end
    if not sv.bookkeeper.noteUpdates then return nil end
    if not sv.bookkeeper.noteUpdates[guildId] then return nil end
    local ts = sv.bookkeeper.noteUpdates[guildId][memberName]
    -- Validate timestamp (must be positive and not in the future)
    if ts and type(ts) == "number" and ts > 0 and ts <= GetTimeStamp() + 86400 then
        return ts
    end
    -- Corrupted timestamp - clear it
    if ts then
        sv.bookkeeper.noteUpdates[guildId][memberName] = nil
    end
    return nil
end

-- Set last note update timestamp for a member
local function SetLastNoteUpdate(guildId, memberName, timestamp)
    local sv = NWT.savedVars
    if not sv.bookkeeper then sv.bookkeeper = {} end
    if not sv.bookkeeper.noteUpdates then sv.bookkeeper.noteUpdates = {} end
    if not sv.bookkeeper.noteUpdates[guildId] then sv.bookkeeper.noteUpdates[guildId] = {} end
    sv.bookkeeper.noteUpdates[guildId][memberName] = timestamp
end

-- Get saved due date for a member (backup in case note gets deleted)
local function GetSavedDueDate(guildId, memberName)
    local sv = NWT.savedVars
    if not sv.bookkeeper then return nil end
    if not sv.bookkeeper.dueDates then return nil end
    if not sv.bookkeeper.dueDates[guildId] then return nil end
    local dueDate = sv.bookkeeper.dueDates[guildId][memberName]
    -- Validate timestamp (must be positive)
    if dueDate and type(dueDate) == "number" and dueDate > 0 then
        return dueDate
    end
    return nil
end

-- Save due date for a member (backup in case note gets deleted)
local function SetSavedDueDate(guildId, memberName, dueDate)
    local sv = NWT.savedVars
    if not sv.bookkeeper then sv.bookkeeper = {} end
    if not sv.bookkeeper.dueDates then sv.bookkeeper.dueDates = {} end
    if not sv.bookkeeper.dueDates[guildId] then sv.bookkeeper.dueDates[guildId] = {} end
    sv.bookkeeper.dueDates[guildId][memberName] = dueDate
end

-- Parse payment date from note - handles various formats
-- "due 1/15", "paid 12/1", "1/15 due", "12/1-1/15", "Due: 1/15/26", "due 01/15/2026", "lifetime", "life", etc.
local function ParsePaymentDateFromNote(note)
    if not note or note == "" then return nil end
    
    local result = { paidDate = nil, dueDate = nil, isLifetime = false, rawNote = note }
    local noteLower = note:lower()
    
    -- Check for lifetime membership
    if noteLower:find("lifetime") or noteLower:match("%f[%a]life%f[%A]") then
        result.isLifetime = true
        return result
    end
    
    -- Look for "due" followed by date (with optional colon/space)
    -- Patterns: "due 1/15", "due: 1/15", "due 01/15/2026", "due:01/15/26"
    local m, d, y = noteLower:match("due[:%s]*(%d+)[/%-]+(%d+)[/%-]*(%d*)")
    if m and d then
        result.dueDate = { month = tonumber(m), day = tonumber(d), year = y ~= "" and tonumber(y) or nil }
    end
    
    -- Look for date followed by "due"
    if not result.dueDate then
        m, d, y = noteLower:match("(%d+)[/%-%.]+(%d+)[/%-%.]*(%d*)%s*due")
        if m and d then
            result.dueDate = { month = tonumber(m), day = tonumber(d), year = y ~= "" and tonumber(y) or nil }
        end
    end
    
    -- Look for "paid" followed by date
    m, d, y = noteLower:match("paid[:%s]*(%d+)[/%-]+(%d+)[/%-]*(%d*)")
    if m and d then
        result.paidDate = { month = tonumber(m), day = tonumber(d), year = y ~= "" and tonumber(y) or nil }
    end
    
    -- Look for date followed by "paid"
    if not result.paidDate then
        m, d, y = noteLower:match("(%d+)[/%-%.]+(%d+)[/%-%.]*(%d*)%s*paid")
        if m and d then
            result.paidDate = { month = tonumber(m), day = tonumber(d), year = y ~= "" and tonumber(y) or nil }
        end
    end
    
    -- Look for "thru" or "through" date
    if not result.dueDate then
        m, d, y = noteLower:match("thru[gh]*[:%s]*(%d+)[/%-%.]+(%d+)[/%-%.]*(%d*)")
        if m and d then
            result.dueDate = { month = tonumber(m), day = tonumber(d), year = y ~= "" and tonumber(y) or nil }
        end
    end
    
    -- Look for date range format: "1/1-2/1" or "1/1/26-2/1/26"
    local m1, d1, y1, m2, d2, y2 = note:match("(%d+)[/%-%.]+(%d+)[/%-%.]*(%d*)%s*[%-–]+%s*(%d+)[/%-%.]+(%d+)[/%-%.]*(%d*)")
    if m1 and d1 and m2 and d2 then
        result.paidDate = { month = tonumber(m1), day = tonumber(d1), year = y1 ~= "" and tonumber(y1) or nil }
        result.dueDate = { month = tonumber(m2), day = tonumber(d2), year = y2 ~= "" and tonumber(y2) or nil }
    end
    
    -- If we found any dates, return the result
    if result.paidDate or result.dueDate then
        return result
    end
    
    return nil
end

-- Scan all guild member notes for payment dates
function NWT.BookkeeperScanPaymentNotes(guildId)
    local gs = GetBookkeeperGuildSettings(guildId)
    local guildName = GetGuildName(guildId) or ("Guild " .. guildId)
    local numMembers = GetNumGuildMembers(guildId)
    
    local paymentHistory = {}
    local foundCount = 0
    local currentTime = GetTimeStamp()
    local currentDate = GetDate()
    local currentYear = tonumber(tostring(currentDate):sub(1, 4)) or 2026

    local batchSize = 10  -- smaller batch to avoid CPU timeout
    local timeBudgetMs = 12
    local index = 1

    local function processBatch()
        local startTime = GetFrameTimeMilliseconds()
        for _ = 1, batchSize do
            if index > numMembers then break end
            local name, note, rankIndex = GetGuildMemberInfo(guildId, index)
            index = index + 1
            if name and note and note ~= "" then
                local parsed = ParsePaymentDateFromNote(note)
                if parsed then
                    foundCount = foundCount + 1
                    if not paymentHistory[name] then
                        paymentHistory[name] = { payments = {}, rankIndex = rankIndex, isLifetime = false }
                    end
                    if parsed.isLifetime then
                        paymentHistory[name].isLifetime = true
                        if not gs.lifetimeMembers then gs.lifetimeMembers = {} end
                        gs.lifetimeMembers[name] = true
                    end
                    local record = { scanTime = currentTime, rawNote = note }
                    if parsed.paidDate then
                        record.paidMonth = parsed.paidDate.month
                        record.paidDay = parsed.paidDate.day
                        record.paidYear = parsed.paidDate.year or currentYear
                    end
                    if parsed.dueDate then
                        record.dueMonth = parsed.dueDate.month
                        record.dueDay = parsed.dueDate.day
                        record.dueYear = parsed.dueDate.year or currentYear
                    end
                    local isDuplicate = false
                    for _, existing in ipairs(paymentHistory[name].payments) do
                        if existing.paidMonth == record.paidMonth and existing.paidDay == record.paidDay and existing.dueMonth == record.dueMonth and existing.dueDay == record.dueDay then
                            isDuplicate = true
                            break
                        end
                    end
                    if not isDuplicate and (record.paidMonth or record.dueMonth) then
                        table.insert(paymentHistory[name].payments, record)
                    end
                end
            end
            if (GetFrameTimeMilliseconds() - startTime) >= timeBudgetMs then
                break
            end
        end
        if index <= numMembers then
            -- Defer next batch to avoid CPU timeout
            zo_callLater(processBatch, 10)
        else
            -- Merge with existing payment history
            if gs.paymentHistory then
                for name, data in pairs(gs.paymentHistory) do
                    if not paymentHistory[name] then
                        paymentHistory[name] = data
                    else
                        for _, oldRecord in ipairs(data.payments or {}) do
                            local isDuplicate = false
                            for _, newRecord in ipairs(paymentHistory[name].payments) do
                                if oldRecord.paidMonth == newRecord.paidMonth and oldRecord.paidDay == newRecord.paidDay and oldRecord.dueMonth == newRecord.dueMonth and oldRecord.dueDay == newRecord.dueDay then
                                    isDuplicate = true
                                    break
                                end
                            end
                            if not isDuplicate then
                                table.insert(paymentHistory[name].payments, oldRecord)
                            end
                        end
                    end
                end
            end
            gs.paymentHistory = paymentHistory
            gs.lastNotesScan = currentTime
            PlaySound(SOUNDS.POSITIVE_CLICK)

            -- Update UI once at completion
            if NWT.Bookkeeper.duesSettingsOpen then
                NWT.UpdateDuesSettingsDialog()
            elseif NWT.Bookkeeper.settingsMenuOpen then
                NWT.UpdateSettingsDialog()
            end
            NWT.BuildBookkeeperMemberList(guildId)
            NWT.UpdateBookkeeperUI()
            NWT.SyncHiddenBookkeeperList()
        end
    end

    processBatch()
end

-- Repair corrupted note date ranges by recalculating start dates from deposit history
function NWT.BookkeeperRepairNotes(guildId)
    local gs = GetBookkeeperGuildSettings(guildId)
    local guildName = GetGuildName(guildId) or ("Guild " .. guildId)
    NWT.Debug("|cFFD700[Bookkeeper]|r BookkeeperRepairNotes called for " .. guildName)
    if not gs or not gs.memberPayments then return end

    -- Check permission
    if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_NOTE_EDIT) then return end
    
    local numMembers = GetNumGuildMembers(guildId)
    local now = GetTimeStamp()
    local thirtyDaysAgo = now - (30 * 24 * 60 * 60)
    local repairedCount = 0
    
    for i = 1, numMembers do
        local displayName, currentNote, rankIndex = GetGuildMemberInfo(guildId, i)
        if displayName and currentNote and currentNote ~= "" then
            if not displayName:find("^@") then displayName = "@" .. displayName end
            
            local parsedNote = ParseDueDateFromNote(currentNote, gs)
            if parsedNote and parsedNote.startDate then
                -- Check if start date is older than our deposit history (30 days)
                if parsedNote.startDate < thirtyDaysAgo then
                    -- This note has a corrupted/old start date - repair it
                    local memberData = gs.memberPayments[displayName]
                    if memberData and memberData.deposits and #memberData.deposits > 0 then
                        -- Find the earliest deposit timestamp
                        local earliestDeposit = now
                        for _, dep in ipairs(memberData.deposits) do
                            if dep.timestamp and dep.timestamp > 0 and dep.timestamp < earliestDeposit then
                                earliestDeposit = dep.timestamp
                            end
                        end
                        
                        -- Only repair if we found a valid deposit and it's different from current
                        if earliestDeposit < now and earliestDeposit > thirtyDaysAgo then
                            -- Recalculate the note with corrected start date
                            local newNote = FormatDuesNote(earliestDeposit, parsedNote.endDate, currentNote, gs)
                            if newNote ~= currentNote then
                                SetGuildMemberNote(guildId, i, newNote)
                                SetSavedDueDate(guildId, displayName, parsedNote.endDate)
                                repairedCount = repairedCount + 1
                            end
                        end
                    end
                end
            end
        end
    end
    
    if repairedCount > 0 then
        NWT.Debug("|c00FF00[Bookkeeper]|r Repaired " .. repairedCount .. " corrupted note date ranges")
    end
end

-- Show text input dialog for custom note format (Xbox virtual keyboard)
function NWT.BookkeeperShowNoteFormatInput(guildId)
    local gs = GetBookkeeperGuildSettings(guildId)
    if not gs then return end
    
    -- Store guildId for callback
    NWT.Bookkeeper.noteFormatGuildId = guildId
    
    -- Create the input control if it doesn't exist
    if not NWT.Bookkeeper.noteFormatInputControl then
        local control = WINDOW_MANAGER:CreateTopLevelWindow("ATK_NoteFormatInput")
        control:SetDimensions(600, 300)
        control:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        control:SetHidden(true)
        control:SetMouseEnabled(true)
        control:SetMovable(false)
        
        -- Background
        local bg = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
        bg:SetAnchorFill()
        bg:SetCenterColor(0, 0, 0, 0.9)
        bg:SetEdgeColor(0.6, 0.6, 0.4, 1)
        bg:SetEdgeTexture("", 2, 2, 2, 0)
        
        -- Title
        local title = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        title:SetFont("ZoFontGamepadBold27")
        title:SetColor(1, 0.84, 0, 1)
        title:SetAnchor(TOP, control, TOP, 0, 20)
        title:SetText("CUSTOM NOTE FORMAT")
        
        -- Help text
        local help = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        help:SetFont("ZoFontGamepad22")
        help:SetColor(0.8, 0.8, 0.8, 1)
        help:SetAnchor(TOP, title, BOTTOM, 0, 10)
        help:SetText("Use placeholders: {START} {END} {UPD}")
        control.helpLabel = help
        
        -- Edit box backdrop
        local editBg = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_EditBackdrop")
        editBg:SetDimensions(500, 40)
        editBg:SetAnchor(TOP, help, BOTTOM, 0, 20)
        
        -- Edit box
        local editbox = WINDOW_MANAGER:CreateControlFromVirtual(nil, editBg, "ZO_DefaultEditForBackdrop")
        editbox:SetAnchor(TOPLEFT, editBg, TOPLEFT, 4, 4)
        editbox:SetAnchor(BOTTOMRIGHT, editBg, BOTTOMRIGHT, -4, -4)
        editbox:SetFont("ZoFontGamepad27")
        editbox:SetMaxInputChars(100)
        editbox:SetVirtualKeyboardType(VIRTUAL_KEYBOARD_TYPE_DEFAULT)
        control.editbox = editbox
        
        -- Confirm handler
        editbox:SetHandler("OnEnter", function(self)
            local text = self:GetText()
            local gid = NWT.Bookkeeper.noteFormatGuildId
            local settings = GetBookkeeperGuildSettings(gid)
            if settings and text and text ~= "" then
                settings.customNoteFormat = text
                settings.noteFormat = "custom"
            end
            control:SetHidden(true)
            NWT.UpdateDuesSettingsDialog()
            PlaySound(SOUNDS.POSITIVE_CLICK)
        end)
        
        -- Button hints
        local hints = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        hints:SetFont("ZoFontGamepad18")
        hints:SetColor(0.5, 0.5, 0.5, 1)
        hints:SetAnchor(BOTTOM, control, BOTTOM, 0, -50)
        hints:SetText("[Enter] Save  |  [Esc] Cancel")
        
        -- Close on escape
        control:SetHandler("OnKeyDown", function(self, key)
            if key == KEY_ESCAPE then
                self:SetHidden(true)
                PlaySound(SOUNDS.NEGATIVE_CLICK)
            end
        end)
        
        NWT.Bookkeeper.noteFormatInputControl = control
    end
    
    -- Set current value and show
    local control = NWT.Bookkeeper.noteFormatInputControl
    control.editbox:SetText(gs.customNoteFormat or "{START}-{END} Upd:{UPD}")
    control:SetHidden(false)
    control.editbox:TakeFocus()
end

-- Calculate deposits since a given timestamp
local function GetDepositsSince(memberData, sinceTimestamp, guildSettings)
    if not memberData or not memberData.deposits then return 0, 0 end
    local duesTotal, count = 0, 0
    local now = GetTimeStamp()
    for _, dep in ipairs(memberData.deposits) do
        -- Validate deposit has valid timestamp and amount
        local ts = dep.timestamp
        local amt = dep.amount
        if ts and type(ts) == "number" and ts > 0 and ts <= now + 86400 and
           amt and type(amt) == "number" and amt > 0 then
            if ts > sinceTimestamp and dep.type == "dues" then
                duesTotal = duesTotal + amt
                count = count + 1
            end
        end
    end
    return duesTotal, count
end

-- Calculate new due date based on deposits
local function CalculateNewDueDate(currentEndDate, duesDeposited, guildSettings)
    local duesAmount = guildSettings.duesAmount or 5000
    if duesAmount <= 0 then return currentEndDate end
    
    -- How many periods (weeks/months) does the deposit cover?
    local periodsCovered = math.floor(duesDeposited / duesAmount)
    if periodsCovered <= 0 then return currentEndDate end
    
    -- Start from current end date or today if none
    local startDate = currentEndDate or GetTimeStamp()
    if startDate < GetTimeStamp() then
        startDate = GetTimeStamp() -- Don't go backwards
    end
    
    -- Calculate days per period based on duesPeriod setting
    local daysPerPeriod = 7  -- Default: weekly
    if guildSettings.duesPeriod == "biweekly" then
        daysPerPeriod = 14
    elseif guildSettings.duesPeriod == "monthly" then
        daysPerPeriod = 30
    elseif guildSettings.duesPeriod == "custom" then
        daysPerPeriod = guildSettings.customDaysPeriod or 7
    end
    local newEndDate = startDate + (periodsCovered * daysPerPeriod * 86400)
    
    return newEndDate
end

-- Extract non-dues portion from existing note (preserve user's custom text)
local function ExtractCustomNotePortion(note)
    if not note or note == "" then return nil end
    -- Remove common dues patterns: "M/D-M/D", "M/D/YY-M/D/YY", "Upd:M/D/YY", "due M/D", "paid thru M/D"
    local cleaned = note
    -- Remove date ranges like "1/1-2/1" or "1/1/26-2/1/26"
    cleaned = cleaned:gsub("%d+[/%-%.]+%d+[/%-%.]*%d*%s*[%-–]+%s*%d+[/%-%.]+%d+[/%-%.]*%d*", "")
    -- Remove "Upd:X/X/XX" or "Updated:X/X"
    cleaned = cleaned:gsub("[Uu]pd[ate]*[ed]*[:%s]*%d+[/%-%.]+%d+[/%-%.]*%d*", "")
    -- Remove "due X/X" or "Due: X/X"
    cleaned = cleaned:gsub("[Dd]ue[:%s]*%d+[/%-%.]+%d+[/%-%.]*%d*", "")
    -- Remove "paid thru X/X" 
    cleaned = cleaned:gsub("[Pp]aid%s*[Tt]hru[gh]*[:%s]*%d+[/%-%.]+%d+[/%-%.]*%d*", "")
    -- Trim whitespace and extra spaces
    cleaned = cleaned:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
    if cleaned == "" then return nil end
    return cleaned
end

-- Format note with due date range and update timestamp, preserving custom content
-- Uses template from guild settings with placeholders: {START}, {END}, {UPD}
local function FormatDuesNote(startDate, endDate, existingNote, guildSettings)
    local startStr = FormatShortDate(startDate or GetTimeStamp())
    local endStr = FormatShortDate(endDate)
    local updStr = FormatShortDate(GetTimeStamp())
    
    -- Get template from guild settings or use default
    local template
    local gs = guildSettings or {}
    local format = gs.noteFormat or "range"
    
    if format == "custom" and gs.customNoteFormat and gs.customNoteFormat ~= "" then
        template = gs.customNoteFormat
    else
        template = NOTE_FORMAT_TEMPLATES[format] or NOTE_FORMAT_TEMPLATES.range
    end
    
    -- Replace placeholders
    local duesPortion = template
    duesPortion = duesPortion:gsub("{START}", startStr)
    duesPortion = duesPortion:gsub("{END}", endStr)
    duesPortion = duesPortion:gsub("{UPD}", updStr)
    
    -- Preserve any custom note content
    local customPortion = ExtractCustomNotePortion(existingNote)
    if customPortion then
        return duesPortion .. " " .. customPortion
    end
    return duesPortion
end

-- Reformat all notes to match the current note format template
function NWT.BookkeeperReformatAllNotes(guildId)
    local gs = GetBookkeeperGuildSettings(guildId)
    local guildName = GetGuildName(guildId) or ("Guild " .. guildId)
    NWT.Debug("|cFFD700[Bookkeeper]|r BookkeeperReformatAllNotes called for " .. guildName)
    if not gs then return end

    -- Check permission
    if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_NOTE_EDIT) then
        NWT.Debug("|cFF0000[Bookkeeper]|r No permission to edit member notes")
        return
    end
    
    local numMembers = GetNumGuildMembers(guildId)
    local reformattedCount = 0
    
    -- Calculate days per period based on duesPeriod setting
    local daysPerPeriod = 7  -- Default: weekly
    if gs.duesPeriod == "biweekly" then
        daysPerPeriod = 14
    elseif gs.duesPeriod == "monthly" then
        daysPerPeriod = 30
    elseif gs.duesPeriod == "custom" then
        daysPerPeriod = gs.customDaysPeriod or 7
    end
    
    for i = 1, numMembers do
        local displayName, currentNote, rankIndex = GetGuildMemberInfo(guildId, i)
        if displayName then
            if not displayName:find("^@") then displayName = "@" .. displayName end
            
            -- Look up member's tracked payment data
            local member = gs.memberPayments and gs.memberPayments[displayName]
            local parsedNote = ParseDueDateFromNote(currentNote or "", gs)
            
            -- Determine start and end dates
            local startDate, endDate
            
            if member and (member.duesMonths or 0) > 0 then
                -- Use tracked payment data to calculate dates
                -- Start = parsed start date or today
                startDate = (parsedNote and parsedNote.startDate) or GetTimeStamp()
                -- End = start + (paid periods * days per period)
                local paidPeriods = member.duesMonths or 0
                endDate = startDate + (paidPeriods * daysPerPeriod * 86400)
            elseif parsedNote and parsedNote.startDate and parsedNote.endDate then
                -- Fall back to parsed dates from existing note
                startDate = parsedNote.startDate
                endDate = parsedNote.endDate
            end
            
            -- Only update if we have valid dates
            if startDate and endDate then
                local newNote = FormatDuesNote(startDate, endDate, currentNote or "", gs)
                if newNote ~= currentNote then
                    SetGuildMemberNote(guildId, i, newNote)
                    SetSavedDueDate(guildId, displayName, endDate)
                    reformattedCount = reformattedCount + 1
                end
            end
        end
    end
    
    if reformattedCount > 0 then
        NWT.Debug("|c00FF00[Bookkeeper]|r Reformatted " .. reformattedCount .. " notes to new format")
    else
        NWT.Debug("|cFFFF00[Bookkeeper]|r No notes needed reformatting")
    end
    PlaySound(SOUNDS.POSITIVE_CLICK)
end

-- Initialize the native ESO dialog for note confirmation
local function InitNoteConfirmDialog()
    if ESO_Dialogs["ATK_NOTE_CONFIRM_DIALOG"] then return end
    
    ESO_Dialogs["ATK_NOTE_CONFIRM_DIALOG"] = {
        gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
        canQueue = true,
        title = { text = "Update Member Note?" },
        mainText = { text = "<<1>>\n\nCurrent: <<2>>\nNew: <<3>>\n\n<<4>>" },
        buttons = {
            { 
                text = "Confirm", 
                keybind = "DIALOG_PRIMARY", 
                callback = function() 
                    NWT.BookkeeperConfirmNoteUpdate() 
                end 
            },
            { 
                text = "Cancel", 
                keybind = "DIALOG_NEGATIVE",
                callback = function()
                    NWT.BookkeeperCancelNoteUpdate()
                end
            },
        },
    }
end

-- Show confirmation info inline (no popup - keybind strip handles A/B)
local function ShowConfirmDialog(pending)
    -- Just update keybind strip - info shown via CENTER_SCREEN_ANNOUNCE
    if not NWT.Bookkeeper.confirmShown then
        NWT.Bookkeeper.confirmShown = true
        -- Show confirmation message via center screen announce
        local CSA = CENTER_SCREEN_ANNOUNCE
        if CSA and CSA.CreateMessageParams then
            local params = CSA:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.DIALOG_SHOW)
            params:SetText(string.format("|cFFD700UPDATE NOTE?|r\n%s\n|c888888%s|r → |c00FF00%s|r\n|cFFFF00%sg = %d week(s)|r\n|c00FF00[A] Confirm|r  |cFF0000[B] Cancel|r",
                pending.memberName,
                pending.currentNote or "(empty)",
                pending.newNote,
                NWT.FormatGold(pending.duesDeposited),
                pending.periodsCovered))
            params:SetLifespanMS(10000)  -- Show for 10 seconds
            CSA:DisplayMessage(params)
        end
    end
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then 
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) 
    end
end

-- Hide confirmation (just reset flag - CSA auto-hides)
local function HideConfirmDialog()
    NWT.Bookkeeper.confirmShown = false
end

-- Confirm and execute the pending note update
function NWT.BookkeeperConfirmNoteUpdate()
    local pending = NWT.Bookkeeper.pendingNoteUpdate
    if not pending then return end
    
    -- Update the note
    SetGuildMemberNote(pending.guildId, pending.memberIndex, pending.newNote)
    SetLastNoteUpdate(pending.guildId, pending.memberName, GetTimeStamp())
    
    -- Provide feedback
NWT.Debug("|c00FF00[Bookkeeper]|r Updated " .. pending.memberName .. " - " .. NWT.FormatGold(pending.duesDeposited) .. "g = " .. pending.periodsCovered .. " week(s)")
NWT.Debug("|c00FF00[Bookkeeper]|r New due date: " .. pending.newEndDateStr)
    
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.Bookkeeper.pendingNoteUpdate = nil
    NWT.Bookkeeper.confirmDialogOpen = false
    HideConfirmDialog()
    
    -- Refresh the UI
    NWT.UpdateBookkeeperUI()
end

-- Cancel the pending note update
function NWT.BookkeeperCancelNoteUpdate()
    NWT.Bookkeeper.pendingNoteUpdate = nil
    NWT.Bookkeeper.confirmDialogOpen = false
    HideConfirmDialog()
NWT.Debug("|cFFFF00[Bookkeeper]|r Note update cancelled")
    PlaySound(SOUNDS.NEGATIVE_CLICK)
    NWT.UpdateBookkeeperUI()
end

-- Auto-update notes for all members who have new deposits (called after scan if enabled)
function NWT.BookkeeperAutoUpdateNotes(guildId)
    local guildSettings = GetBookkeeperGuildSettings(guildId)
    local guildName = GetGuildName(guildId) or ("Guild " .. guildId)
    NWT.Debug("|cFFD700[Bookkeeper]|r BookkeeperAutoUpdateNotes called for " .. guildName .. " - autoUpdateNotes = " .. tostring(guildSettings.autoUpdateNotes))
    if not guildSettings.autoUpdateNotes then
        NWT.Debug("|cFFFF00[Bookkeeper]|r BookkeeperAutoUpdateNotes exiting - setting is OFF")
        return
    end
    
    -- Check permission
    if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_NOTE_EDIT) then
        NWT.Debug("|cFFFF00[Bookkeeper]|r Auto-update skipped: no note edit permission")
        return
    end
    
    local numMembers = GetNumGuildMembers(guildId)
    local updatedCount = 0
    local duesAmount = guildSettings.duesAmount or 5000
    
    for i = 1, numMembers do
        local displayName, currentNote, rankIndex = GetGuildMemberInfo(guildId, i)
        if displayName then
            if not displayName:find("^@") then displayName = "@" .. displayName end
            local member = guildSettings.memberPayments and guildSettings.memberPayments[displayName]
            
            if member and (member.duesTotal or 0) > 0 then
                -- Parse current note to get existing end date
                local parsedNote = ParseDueDateFromNote(currentNote, guildSettings)

                -- Only auto-update if member already has a parseable date (incremental only)
                -- This prevents backfilling all historical deposits for members without notes
                local savedUpdate = GetLastNoteUpdate(guildId, displayName)
                local savedDueDate = GetSavedDueDate(guildId, displayName)
                local hasExistingDate = (parsedNote and (parsedNote.endDate or parsedNote.lastUpdate)) or savedUpdate or savedDueDate

                if hasExistingDate then
                    -- Check if note is missing but we have a saved due date (restoration needed)
                    local noteIsMissing = not parsedNote or not parsedNote.endDate
                    local needsRestoration = noteIsMissing and savedDueDate

                    if needsRestoration then
                        -- Restore the saved due date without any extensions
                        local newStartDate = GetTimeStamp()
                        local newNote = FormatDuesNote(newStartDate, savedDueDate, currentNote, guildSettings)
                        SetGuildMemberNote(guildId, i, newNote)
                        SetLastNoteUpdate(guildId, displayName, GetTimeStamp())
                        updatedCount = updatedCount + 1
                    else
                        -- Normal update: add new deposits to existing due date
                        -- Determine what timestamp to count deposits from
                        local noteLastUpdate = parsedNote and parsedNote.lastUpdate or 0
                        local savedTs = savedUpdate or 0
                        local countFromTimestamp = math.max(noteLastUpdate, savedTs)

                        -- Get deposits since that timestamp
                        local duesDeposited, depositCount = GetDepositsSince(member, countFromTimestamp, guildSettings)

                        if duesDeposited >= duesAmount then
                            -- Calculate new due date by extending current date
                            local currentEndDate = parsedNote and parsedNote.endDate
                            local newEndDate = CalculateNewDueDate(currentEndDate, duesDeposited, guildSettings)
                            local newStartDate = (parsedNote and parsedNote.startDate) or GetTimeStamp()

                            -- Format new note (preserve any custom text in existing note)
                            local newNote = FormatDuesNote(newStartDate, newEndDate, currentNote, guildSettings)

                            -- Update the note and save the due date as backup
                            SetGuildMemberNote(guildId, i, newNote)
                            SetLastNoteUpdate(guildId, displayName, GetTimeStamp())
                            SetSavedDueDate(guildId, displayName, newEndDate)
                            updatedCount = updatedCount + 1
                        end
                    end
                end
            end
        end
    end
    
    if updatedCount > 0 then
        NWT.Debug("|c00FF00[Bookkeeper]|r Auto-updated " .. updatedCount .. " member notes")
    end
end

-- Update a member's guild note with new due date (shows confirmation first)
function NWT.BookkeeperUpdateMemberNote()
    local bk = NWT.Bookkeeper
    if bk.rankMenuOpen or bk.settingsMenuOpen or bk.confirmDialogOpen then return end
    if bk.focusPanel ~= "dues" then return end
    
    local member = bk.sortedMembers[bk.selectedMemberIndex]
    if not member then 
NWT.Debug("|cFF0000[Bookkeeper]|r No member selected")
        return 
    end
    
    local guildId = GetGuildId(bk.viewingGuildIndex)
    local guildSettings = GetBookkeeperGuildSettings(guildId)
    
    -- Check permission
    if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_NOTE_EDIT) then
NWT.Debug("|cFF0000[Bookkeeper]|r No permission to edit member notes")
        return
    end
    
    -- Get member index for API call
    local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, member.name)
    if not memberIndex then
NWT.Debug("|cFF0000[Bookkeeper]|r Could not find member: " .. member.name)
        return
    end
    
    -- Get current note and parse it
    local _, currentNote = GetGuildMemberInfo(guildId, memberIndex)
    local parsedNote = ParseDueDateFromNote(currentNote, guildSettings)
    local savedDueDate = GetSavedDueDate(guildId, member.name)

    -- Check if note is missing but we have a saved due date (restoration needed)
    local noteIsMissing = not parsedNote or not parsedNote.endDate
    local needsRestoration = noteIsMissing and savedDueDate

    if needsRestoration then
        -- Restore the saved due date without any extensions
        local newStartDate = GetTimeStamp()
        local newNote = FormatDuesNote(newStartDate, savedDueDate, currentNote, guildSettings)
        SetGuildMemberNote(guildId, memberIndex, newNote)
        SetLastNoteUpdate(guildId, member.name, GetTimeStamp())
        NWT.Debug("|c00FF00[Bookkeeper]|r Restored note for " .. member.name .. ": " .. newNote)
    else
        -- Normal update: add new deposits to existing due date
        local noteLastUpdate = parsedNote and parsedNote.lastUpdate or 0
        local savedUpdate = GetLastNoteUpdate(guildId, member.name) or 0
        local countFromTimestamp = math.max(noteLastUpdate, savedUpdate)

        -- Get deposits since that timestamp
        local duesDeposited, depositCount = GetDepositsSince(member, countFromTimestamp, guildSettings)

        if duesDeposited <= 0 then
NWT.Debug("|cFFFF00[Bookkeeper]|r No new dues deposits found for " .. member.name)
            return
        end

        -- Calculate new due date by extending current date
        local currentEndDate = parsedNote and parsedNote.endDate
        local newEndDate = CalculateNewDueDate(currentEndDate, duesDeposited, guildSettings)
        local newStartDate = (parsedNote and parsedNote.startDate) or GetTimeStamp()

        -- Format new note (preserve any custom text in existing note)
        local newNote = FormatDuesNote(newStartDate, newEndDate, currentNote, guildSettings)
        local duesAmount = guildSettings.duesAmount or 5000
        local periodsCovered = math.floor(duesDeposited / duesAmount)

        -- Update note and save the due date as backup
        SetGuildMemberNote(guildId, memberIndex, newNote)
        SetLastNoteUpdate(guildId, member.name, GetTimeStamp())
        SetSavedDueDate(guildId, member.name, newEndDate)

        NWT.Debug("|c00FF00[Bookkeeper]|r Updated note for " .. member.name .. ": " .. newNote)
    end
    
    NWT.Debug("|c00FF00[Bookkeeper]|r Updated note for " .. member.name .. ": " .. newNote)
    PlaySound(SOUNDS.POSITIVE_CLICK)
    
    -- Rebuild member list to show updated status
    NWT.BuildBookkeeperMemberList(guildId)
    NWT.UpdateBookkeeperUI()
end

-- Scan all enabled guilds for trader history
function NWT.ScanAllGuildTraderHistory()
    if NWT.Bookkeeper.isHistoryScanning then
NWT.Debug("|cFFFF00[Bookkeeper]|r History scan already in progress.")
        return
    end

    local enabledGuilds = {}
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        if guildId and IsGuildEnabled(guildId) then
            table.insert(enabledGuilds, guildId)
        end
    end

    if #enabledGuilds == 0 then
NWT.Debug("|cFFFF00[Bookkeeper]|r No guilds enabled for scanning.")
        return
    end

    NWT.Bookkeeper.isHistoryScanning = true
    NWT.Bookkeeper.historyScanQueue = enabledGuilds
    NWT.ProcessNextHistoryScan()
end

function NWT.ProcessNextHistoryScan()
    if #NWT.Bookkeeper.historyScanQueue == 0 then
        NWT.Bookkeeper.isHistoryScanning = false
NWT.Debug("|c00FF00[Bookkeeper]|r Trader history scan complete for all guilds.")
        return
    end

    local guildId = table.remove(NWT.Bookkeeper.historyScanQueue, 1)
    NWT.Bookkeeper.historyScanGuildId = guildId
    
    local guildName = GetGuildName(guildId)
NWT.Debug("|cFFD700[Bookkeeper]|r Requesting trader history for " .. guildName .. "...")

    -- Request history for TRADER category (8)
    local now = GetTimeStamp()
    local sevenDaysAgo = now - (7 * 24 * 60 * 60)
    local requestId = CreateGuildHistoryRequest(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER, now, sevenDaysAgo)
    
    if requestId then
        RequestMoreGuildHistoryEvents(requestId)
        -- The results will come via EVENT_GUILD_HISTORY_CATEGORY_UPDATED
    else
        -- If request failed, move to next
        NWT.ProcessNextHistoryScan()
    end
end

local function OnGuildHistoryUpdated(eventCode, guildId, category, flags)
    if not NWT.Bookkeeper.isHistoryScanning then return end
    if guildId ~= NWT.Bookkeeper.historyScanGuildId then return end
    if category ~= GUILD_HISTORY_EVENT_CATEGORY_TRADER then return end

    -- Check if we have new info or if the request is complete
    if BitAnd(flags, GUILD_HISTORY_CATEGORY_UPDATE_FLAG_COMPLETE) ~= 0 then
        local numEvents = GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER)
        local salesFound = 0
        local guildSettings = GetBookkeeperGuildSettings(guildId)
        if not guildSettings.salesData then guildSettings.salesData = {} end

        for i = 1, numEvents do
            local eventId, ts, redacted, type, seller, buyer, itemLink, qty, price, tax = GetGuildHistoryTraderEventInfo(guildId, i)
            if eventId and not redacted and type == GUILD_HISTORY_TRADER_EVENT_ITEM_SOLD then
                local saleKey = tostring(eventId)
                if not guildSettings.salesData[saleKey] then
                    guildSettings.salesData[saleKey] = {
                        timestamp = ts,
                        seller = seller,
                        buyer = buyer,
                        itemLink = itemLink,
                        quantity = qty,
                        price = price,
                        tax = tax
                    }
                    salesFound = salesFound + 1
                end
            end
        end

NWT.Debug("|c00FF00[Bookkeeper]|r " .. GetGuildName(guildId) .. ": Processed " .. salesFound .. " new sales.")
        
        -- Process next guild in queue
        NWT.ProcessNextHistoryScan()
    end
end

-- Register the history update event
EVENT_MANAGER:RegisterForEvent("ATK_Bookkeeper_HistoryUpdate", EVENT_GUILD_HISTORY_CATEGORY_UPDATED, OnGuildHistoryUpdated)

-- Request a full scan with reload UI (for fresh guild history)
function NWT.BookkeeperRequestScanWithReload(guildId)
    local sv = NWT.savedVars
    if not sv.bookkeeper then sv.bookkeeper = {} end
    sv.bookkeeper.pendingScanGuildId = guildId
    sv.bookkeeper.pendingScanTime = GetTimeStamp()
NWT.Debug("|cFFD700[Bookkeeper]|r Scan requested. Reloading UI to fetch fresh guild history...")
    zo_callLater(function() ReloadUI("ingame") end, 500)
end

-- Check for pending scan on addon load
function NWT.CheckPendingBookkeeperScan()
    local sv = NWT.savedVars
    if sv.bookkeeper and sv.bookkeeper.pendingScanGuildId then
        local guildId = sv.bookkeeper.pendingScanGuildId
        local scanTime = sv.bookkeeper.pendingScanTime or 0
        -- Clear the pending scan flag
        sv.bookkeeper.pendingScanGuildId = nil
        sv.bookkeeper.pendingScanTime = nil
        -- Only process if scan was requested recently (within 60 seconds)
        if (GetTimeStamp() - scanTime) < 60 then
NWT.Debug("|cFFD700[Bookkeeper]|r Resuming scan after reload...")
            zo_callLater(function()
                NWT.ScanGuildForBookkeeper(guildId)
            end, 2000) -- Wait 2 seconds for history to be available
        end
    end
end

-- Scan guild bank deposits for bookkeeper
function NWT.ScanGuildForBookkeeper(guildId)
    if NWT.Bookkeeper.isScanning then
NWT.Debug("|cFFFF00[Bookkeeper]|r Already scanning. Please wait.")
        return
    end
    
    local guildName = GetGuildName(guildId) or ("Guild " .. guildId)
    local guildSettings = GetBookkeeperGuildSettings(guildId)
    local numMembers = GetNumGuildMembers(guildId)
    
NWT.Debug("|cFFD700[Bookkeeper]|r Scanning " .. guildName .. " (" .. numMembers .. " members)...")
    NWT.Bookkeeper.isScanning = true

    -- Load existing memberPayments to preserve cumulative deposit tracking
    -- This prevents losing prepayments when they age out of the 30-day history window
    local memberPayments = guildSettings.memberPayments or {}
    local lastScanTime = guildSettings.lastScanTime or 0

    -- Update current member info (rank, note, online status)
    for i = 1, numMembers do
        local displayName, note, rankIndex, status, secsSinceLogoff = GetGuildMemberInfo(guildId, i)
        if displayName then
            if not displayName:find("^@") then displayName = "@" .. displayName end
            -- Calculate last online timestamp
            local lastOnline = 0
            if status == PLAYER_STATUS_ONLINE or status == PLAYER_STATUS_AWAY or status == PLAYER_STATUS_DO_NOT_DISTURB then
                lastOnline = GetTimeStamp()  -- Currently online
            elseif secsSinceLogoff and secsSinceLogoff > 0 then
                lastOnline = GetTimeStamp() - secsSinceLogoff
            end

            -- Preserve existing payment data if member already tracked, otherwise create new entry
            if not memberPayments[displayName] then
                memberPayments[displayName] = {
                    name = displayName, totalDeposited = 0, duesTotal = 0, duesMonths = 0, raffleTotal = 0, otherTotal = 0,
                    lastPayment = 0, thisWeekDuesTotal = 0, thisWeekDues = 0, thisWeekRaffle = 0,
                    rankIndex = rankIndex, note = note, isCurrentMember = true, lastOnline = lastOnline,
                }
            else
                -- Update current member info but preserve payment data
                memberPayments[displayName].rankIndex = rankIndex
                memberPayments[displayName].note = note
                memberPayments[displayName].isCurrentMember = true
                memberPayments[displayName].lastOnline = lastOnline
            end
        end
    end

    local now = GetTimeStamp()
    local thirtyDaysAgo = now - (30 * 24 * 60 * 60)
    local bankRequestId = CreateGuildHistoryRequest(guildId, GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY, now, thirtyDaysAgo)
    if bankRequestId then RequestMoreGuildHistoryEvents(bankRequestId, true, nil, nil) end
    
    local waitCount = 0
    EVENT_MANAGER:RegisterForUpdate("ATK_BookkeeperWait_" .. guildId, 1000, function()
        waitCount = waitCount + 1
        local numBankEvents = GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY)
        if waitCount >= 10 or numBankEvents > 0 then
            EVENT_MANAGER:UnregisterForUpdate("ATK_BookkeeperWait_" .. guildId)
            if bankRequestId then pcall(function() DestroyGuildHistoryRequest(bankRequestId) end) end
            
            local flipTimestamp = GetCurrentTraderFlipStart()
            local newDepositsCount = 0

            -- Reset weekly totals and deposits array for all members (will rebuild from current scan)
            for _, m in pairs(memberPayments) do
                m.thisWeekDuesTotal = 0
                m.thisWeekRaffle = 0
                m.deposits = {}  -- Only keep deposits from current scan (last 30 days)
            end

            -- Process deposits: add only NEW deposits (timestamp > lastScanTime) to cumulative totals
            -- Store ALL deposits from current scan in deposits array, calculate weekly totals
            for i = 1, numBankEvents do
                local eventId, ts, redacted, type, disp, _, amt = GetGuildHistoryBankedCurrencyEventInfo(guildId, i)
                if eventId and not redacted and type == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED and amt and amt > 0 and disp then
                    if not disp:find("^@") then disp = "@" .. disp end

                    -- Create member entry if they don't exist (ex-members who deposited but left)
                    if not memberPayments[disp] then
                        memberPayments[disp] = {
                            name = disp, totalDeposited = 0, duesTotal = 0, duesMonths = 0, raffleTotal = 0, otherTotal = 0,
                            lastPayment = 0, thisWeekDuesTotal = 0, thisWeekDues = 0, thisWeekRaffle = 0, deposits = {},
                            isCurrentMember = false  -- Not in current roster
                        }
                    end

                    local m = memberPayments[disp]
                    local dType, _ = ParseDepositType(amt, guildSettings)

                    -- Add to deposits array (for functions that need deposit details from recent history)
                    table.insert(m.deposits, { amount = amt, timestamp = ts, type = dType })

                    -- Add to cumulative totals ONLY if this deposit is newer than our last scan
                    if ts > lastScanTime then
                        m.totalDeposited = m.totalDeposited + amt
                        if ts > m.lastPayment then m.lastPayment = ts end
                        if dType == "dues" then
                            m.duesTotal = (m.duesTotal or 0) + amt
                        elseif dType == "raffle" then
                            m.raffleTotal = m.raffleTotal + amt
                        else
                            m.otherTotal = m.otherTotal + amt
                        end
                        newDepositsCount = newDepositsCount + 1
                    end

                    -- Calculate weekly totals from ALL deposits in current week
                    if ts >= flipTimestamp then
                        if dType == "dues" then
                            m.thisWeekDuesTotal = m.thisWeekDuesTotal + amt
                        elseif dType == "raffle" then
                            m.thisWeekRaffle = m.thisWeekRaffle + amt
                        end
                    end
                end
            end

            NWT.Debug("|cFFD700[Bookkeeper]|r Processed " .. newDepositsCount .. " new deposits since last scan")

            -- Calculate duesMonths from cumulative totals (using per-rank dues if configured)
            for _, m in pairs(memberPayments) do
                local rankDuesAmount, rankPeriod = NWT.GetEffectiveDuesForRank(guildSettings, m.rankIndex)
                m.effectiveDuesAmount = rankDuesAmount
                m.effectivePeriod = rankPeriod
                if rankDuesAmount > 0 then
                    m.duesMonths = math.floor((m.duesTotal or 0) / rankDuesAmount)
                    m.thisWeekDues = math.floor((m.thisWeekDuesTotal or 0) / rankDuesAmount)
                else
                    -- Exempt rank
                    m.duesMonths = 0
                    m.thisWeekDues = 0
                end
            end
            guildSettings.memberPayments = memberPayments
            -- Use 'now' timestamp from when we requested history, not current time
            -- This prevents missing deposits that came in during processing
            guildSettings.lastScanTime = now
            
            -- Now scan trader history for sales data
NWT.Debug("|cFFD700[Bookkeeper]|r Scanning trader history...")
            local traderRequestId = CreateGuildHistoryRequest(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER, now, thirtyDaysAgo)
            if traderRequestId then RequestMoreGuildHistoryEvents(traderRequestId, true, nil, nil) end
            
            local traderWaitCount = 0
            EVENT_MANAGER:RegisterForUpdate("ATK_BookkeeperTraderWait_" .. guildId, 1000, function()
                traderWaitCount = traderWaitCount + 1
                local numTraderEvents = GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER)
                if traderWaitCount >= 10 or numTraderEvents > 0 then
                    EVENT_MANAGER:UnregisterForUpdate("ATK_BookkeeperTraderWait_" .. guildId)
                    if traderRequestId then pcall(function() DestroyGuildHistoryRequest(traderRequestId) end) end
                    
                    -- Process trader sales and aggregate per-member tax totals (guild income)
                    local memberTaxes = {}
                    
                    local memberSalesData = {}
                    for i = 1, numTraderEvents do
                        local eventId, ts, redacted, evType, seller, buyer, itemLink, qty, price, tax = GetGuildHistoryTraderEventInfo(guildId, i)
                        if eventId and not redacted and evType == GUILD_HISTORY_TRADER_EVENT_ITEM_SOLD and seller then
                            if not seller:find("^@") then seller = "@" .. seller end
                            if not memberSalesData[seller] then
                                memberSalesData[seller] = { totalSales = 0, saleCount = 0, totalTax = 0, lastSale = 0 }
                            end
                            local sd = memberSalesData[seller]
                            sd.totalSales = sd.totalSales + (price or 0)
                            sd.saleCount = sd.saleCount + 1
                            sd.totalTax = sd.totalTax + (tax or 0)
                            if ts > sd.lastSale then sd.lastSale = ts end
                            memberTaxes[seller] = (memberTaxes[seller] or 0) + (tax or 0)
                        end
                    end
                    
                    -- Store aggregated sales data per member
                    guildSettings.memberSalesData = memberSalesData
                    guildSettings.memberTaxTotals = memberTaxes
                    
                    local sellerCount = 0
                    for _ in pairs(memberTaxes) do sellerCount = sellerCount + 1 end
                    
                    NWT.Bookkeeper.isScanning = false
                    
                    -- Scan member notes to get payment dates before any updates
                    NWT.BookkeeperScanPaymentNotes(guildId)

                    -- Debug: Show which guild was scanned and auto-update setting
                    local guildName = GetGuildName(guildId) or ("Guild " .. guildId)
                    NWT.Debug("|cFFD700[Bookkeeper]|r " .. guildName .. " - autoUpdateNotes = " .. tostring(guildSettings.autoUpdateNotes))

                    -- Note-writing actions only when auto-update is enabled for this guild
                    if guildSettings.autoUpdateNotes then
                        NWT.Debug("|cFFD700[Bookkeeper]|r Auto-update is ON - updating notes")
                        -- Repair corrupted note date ranges
                        NWT.BookkeeperRepairNotes(guildId)
                        -- Reformat all notes to match the current format template
                        NWT.BookkeeperReformatAllNotes(guildId)
                        -- Auto-update notes
                        NWT.BookkeeperAutoUpdateNotes(guildId)
                    else
                        NWT.Debug("|cFFD700[Bookkeeper]|r Auto-update is OFF - skipping note updates")
                    end
                    
                    NWT.UpdateBookkeeperUI()
                    
                    -- Show reload dialog like GST does
                    NWT.ShowBookkeeperReloadDialog(numBankEvents, numTraderEvents, sellerCount)
                end
            end)
        end
    end)
end

-- Show reload dialog after Bookkeeper scan (same pattern as GST)
function NWT.ShowBookkeeperReloadDialog(depositCount, saleCount, sellerCount)
    if not ESO_Dialogs["ATK_BOOKKEEPER_RELOAD_DIALOG"] then
        ESO_Dialogs["ATK_BOOKKEEPER_RELOAD_DIALOG"] = {
            gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
            canQueue = true,
            title = { text = "BOOKKEEPER SCAN COMPLETE" },
            mainText = { text = "Scan complete!\n\nDeposits: <<1>>\nSales: <<2>> from <<3>> sellers\n\nReload UI now to scan other guilds with fresh history data?" },
            buttons = {
                { text = "Reload UI", keybind = "DIALOG_PRIMARY", callback = function() ReloadUI("ingame") end },
                { text = "Later", keybind = "DIALOG_NEGATIVE" },
            },
        }
    end
    
NWT.Debug("|c00FF00[Bookkeeper]|r Scan complete! " .. (depositCount or 0) .. " deposits, " .. (saleCount or 0) .. " sales from " .. (sellerCount or 0) .. " sellers.")
    
    if IsInGamepadPreferredMode() then 
        ZO_Dialogs_ShowGamepadDialog("ATK_BOOKKEEPER_RELOAD_DIALOG", nil, { mainTextParams = { depositCount or 0, saleCount or 0, sellerCount or 0 } })
    else 
        ZO_Dialogs_ShowDialog("ATK_BOOKKEEPER_RELOAD_DIALOG", nil, { mainTextParams = { depositCount or 0, saleCount or 0, sellerCount or 0 } })
    end
end

local BOOKKEEPER_LISTINGS_SCAN_EVENT = "ATK_BOOKKEEPER_LISTINGS_SCAN_EVENT"
local BOOKKEEPER_TRADER_OPEN_EVENT = "ATK_BOOKKEEPER_TRADER_OPEN_EVENT"
local BOOKKEEPER_TRADER_CLOSE_EVENT = "ATK_BOOKKEEPER_TRADER_CLOSE_EVENT"
local BOOKKEEPER_TRADER_GUILD_CHANGE_EVENT = "ATK_BOOKKEEPER_TRADER_GUILD_CHANGE_EVENT"
local LISTINGS_PAGE_DELAY_MS = 300
local LISTINGS_SCAN_COOLDOWN_SEC = 60
local LISTINGS_FAILURE_BACKOFF_SEC = 30

function NWT.BookkeeperIsFreeTraderGuild(guildId)
    if not guildId or guildId <= 0 then return false end
    return IsFreeTraderMode(GetBookkeeperGuildSettings(guildId))
end

local function UpdateBookkeeperTradingHouseKeybind()
    if not KEYBIND_STRIP or not NWT.BookkeeperTradingHouseKeybindGroup then return end
    KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.BookkeeperTradingHouseKeybindGroup)
end

local function RemoveBookkeeperTradingHouseKeybinds()
    if NWT.bookkeeperTradingHouseKeybindsAdded and KEYBIND_STRIP and NWT.BookkeeperTradingHouseKeybindGroup then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(NWT.BookkeeperTradingHouseKeybindGroup)
    end
    NWT.bookkeeperTradingHouseKeybindsAdded = false
end

local function AddBookkeeperTradingHouseKeybinds()
    if not KEYBIND_STRIP then return end
    if NWT.bookkeeperTradingHouseKeybindsAdded then
        UpdateBookkeeperTradingHouseKeybind()
        return
    end

    if not NWT.BookkeeperTradingHouseKeybindGroup then
        NWT.BookkeeperTradingHouseKeybindGroup = {
            {
                alignment = KEYBIND_STRIP_ALIGN_LEFT,
                name = function()
                    local guildId = GetSelectedTradingHouseGuildId and GetSelectedTradingHouseGuildId() or 0
                    if guildId <= 0 then return "Scan Listings" end
                    local gs = GetBookkeeperGuildSettings(guildId)
                    if gs.listingsScanInProgress then return "Scanning..." end
                    if gs.freeTraderMode then return "Scan Listings" end
                    return "Free Trader Off"
                end,
                keybind = "UI_SHORTCUT_LEFT_STICK",
                callback = function()
                    local guildId = GetSelectedTradingHouseGuildId and GetSelectedTradingHouseGuildId() or 0
                    if guildId <= 0 then
                        PlaySound(SOUNDS.NEGATIVE_CLICK)
                        return
                    end

                    local gs = GetBookkeeperGuildSettings(guildId)
                    if not gs.freeTraderMode then
                        NWT.Debug("|cFFFF00[Bookkeeper]|r Free Trader mode is off for " .. (GetGuildName(guildId) or ("Guild " .. tostring(guildId))) .. ".")
                        PlaySound(SOUNDS.NEGATIVE_CLICK)
                        UpdateBookkeeperTradingHouseKeybind()
                        return
                    end

                    NWT.BookkeeperScanGuildListings(guildId)
                    UpdateBookkeeperTradingHouseKeybind()
                end,
                enabled = function()
                    if not GetInteractionType or not INTERACTION_TRADINGHOUSE then return false end
                    return GetInteractionType() == INTERACTION_TRADINGHOUSE
                end,
            },
        }
    end

    KEYBIND_STRIP:AddKeybindButtonGroup(NWT.BookkeeperTradingHouseKeybindGroup)
    NWT.bookkeeperTradingHouseKeybindsAdded = true
    UpdateBookkeeperTradingHouseKeybind()
end

local FinalizeBookkeeperListingsScan

function NWT.SetupBookkeeperTradingHouseKeybinds()
    if NWT.bookkeeperTradingHouseKeybindsInitialized then return end
    NWT.bookkeeperTradingHouseKeybindsInitialized = true

    EVENT_MANAGER:RegisterForEvent(BOOKKEEPER_TRADER_OPEN_EVENT, EVENT_OPEN_TRADING_HOUSE, function()
        zo_callLater(AddBookkeeperTradingHouseKeybinds, 100)
    end)

    EVENT_MANAGER:RegisterForEvent(BOOKKEEPER_TRADER_CLOSE_EVENT, EVENT_CLOSE_TRADING_HOUSE, function()
        RemoveBookkeeperTradingHouseKeybinds()
        local bk = NWT.Bookkeeper
        if bk and bk.listingsScanState and bk.listingsScanState.guildId then
            FinalizeBookkeeperListingsScan(
                bk.listingsScanState.guildId,
                bk.listingsScanState.sellerCounts or {},
                false,
                "trader_closed"
            )
        end
    end)

    EVENT_MANAGER:RegisterForEvent(BOOKKEEPER_TRADER_GUILD_CHANGE_EVENT, EVENT_TRADING_HOUSE_SELECTED_GUILD_CHANGED, function()
        UpdateBookkeeperTradingHouseKeybind()
    end)

    if GetInteractionType and INTERACTION_TRADINGHOUSE and GetInteractionType() == INTERACTION_TRADINGHOUSE then
        zo_callLater(AddBookkeeperTradingHouseKeybinds, 100)
    end
end

FinalizeBookkeeperListingsScan = function(guildId, sellerCounts, wasSuccessful, errorReason)
    local gs = GetBookkeeperGuildSettings(guildId)
    local bk = NWT.Bookkeeper

    EVENT_MANAGER:UnregisterForEvent(BOOKKEEPER_LISTINGS_SCAN_EVENT, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED)
    gs.listingsScanInProgress = false

    if bk then
        bk.listingsScanActiveGuildId = nil
        bk.listingsScanState = nil
    end

    if not wasSuccessful then
        gs.listingsLastFailureTime = GetTimeStamp()
        local reasonText = errorReason and (" (" .. tostring(errorReason) .. ")") or ""
        NWT.Debug("|cFF4444[Bookkeeper]|r Listings scan failed" .. reasonText)
        if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then
            KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor)
        end
        return
    end

    gs.listingsLastFailureTime = 0
    if not gs.memberPayments then gs.memberPayments = {} end
    if not gs.memberListingCounts then gs.memberListingCounts = {} end

    for _, memberData in pairs(gs.memberPayments) do
        memberData.isCurrentMember = false
    end

    local totalListings = 0
    local listedMembers = 0
    local memberListingCounts = {}
    local numMembers = GetNumGuildMembers(guildId)

    for i = 1, numMembers do
        local memberName, note, rankIndex, memberStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, i)
        memberName = NormalizeDisplayName(memberName)
        if memberName then
            local listingCount = sellerCounts[memberName] or 0
            memberListingCounts[memberName] = listingCount
            totalListings = totalListings + listingCount
            if listingCount > 0 then listedMembers = listedMembers + 1 end

            local data = gs.memberPayments[memberName]
            if not data then
                data = {
                    name = memberName,
                    totalDeposited = 0,
                    duesTotal = 0,
                    duesMonths = 0,
                    raffleTotal = 0,
                    otherTotal = 0,
                    lastPayment = 0,
                    deposits = {},
                    thisWeekDues = 0,
                    thisWeekDuesTotal = 0,
                    thisWeekRaffle = 0,
                    thisWeekDuesPeriods = 0,
                    noteDetected = false,
                }
                gs.memberPayments[memberName] = data
            end

            local lastOnline = 0
            if memberStatus ~= PLAYER_STATUS_ONLINE then
                lastOnline = GetTimeStamp() - (secsSinceLogoff or 0)
            end

            data.name = memberName
            data.note = note or ""
            data.rankIndex = rankIndex
            data.isCurrentMember = true
            data.lastOnline = lastOnline
            data.listingsCount = listingCount
        end
    end

    gs.memberListingCounts = memberListingCounts
    gs.listingsLastScanTime = GetTimeStamp()

    NWT.Debug(string.format(
        "|c00FF00[Bookkeeper]|r Listings scan complete for %s (%d members listed, %d total listings).",
        GetGuildName(guildId) or ("Guild " .. tostring(guildId)),
        listedMembers,
        totalListings
    ))

    if NWT.Bookkeeper and NWT.Bookkeeper.viewingGuildIndex and GetGuildId(NWT.Bookkeeper.viewingGuildIndex) == guildId then
        NWT.BuildBookkeeperMemberList(guildId)
        NWT.UpdateBookkeeperUI()
        NWT.SyncHiddenBookkeeperList()
    end

    UpdateBookkeeperTradingHouseKeybind()

    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor)
    end
end

function NWT.BookkeeperScanGuildListings(guildId)
    local bk = NWT.Bookkeeper
    if not bk or bk.demoMode then return end

    guildId = tonumber(guildId) or 0
    if guildId <= 0 then
        NWT.Debug("|cFF4444[Bookkeeper]|r Select a guild first to scan listings.")
        return
    end

    local gs = GetBookkeeperGuildSettings(guildId)
    if gs.listingsScanInProgress then
        NWT.Debug("|cFFFF00[Bookkeeper]|r Listings scan already in progress.")
        return
    end

    if bk.listingsScanActiveGuildId and bk.listingsScanActiveGuildId ~= guildId then
        NWT.Debug("|cFFFF00[Bookkeeper]|r Another listings scan is already in progress.")
        PlaySound(SOUNDS.NEGATIVE_CLICK)
        return
    end

    local now = GetTimeStamp()
    local lastScan = tonumber(gs.listingsLastScanTime) or 0
    local elapsedSinceScan = now - lastScan
    if lastScan > 0 and elapsedSinceScan < LISTINGS_SCAN_COOLDOWN_SEC then
        local waitSec = math.max(1, LISTINGS_SCAN_COOLDOWN_SEC - elapsedSinceScan)
        NWT.Debug("|cFFFF00[Bookkeeper]|r Please wait " .. tostring(waitSec) .. "s before scanning again.")
        PlaySound(SOUNDS.NEGATIVE_CLICK)
        return
    end

    local lastFailure = tonumber(gs.listingsLastFailureTime) or 0
    local elapsedSinceFailure = now - lastFailure
    if lastFailure > 0 and elapsedSinceFailure < LISTINGS_FAILURE_BACKOFF_SEC then
        local waitSec = math.max(1, LISTINGS_FAILURE_BACKOFF_SEC - elapsedSinceFailure)
        NWT.Debug("|cFFFF00[Bookkeeper]|r Previous scan failed. Wait " .. tostring(waitSec) .. "s before retrying.")
        PlaySound(SOUNDS.NEGATIVE_CLICK)
        return
    end

    if GetInteractionType and INTERACTION_TRADINGHOUSE and GetInteractionType() ~= INTERACTION_TRADINGHOUSE then
        NWT.Debug("|cFF4444[Bookkeeper]|r Open the guild trader window first.")
        PlaySound(SOUNDS.NEGATIVE_CLICK)
        return
    end

    local selectedGuildId = GetSelectedTradingHouseGuildId and GetSelectedTradingHouseGuildId() or 0
    local switchedGuild = false
    if selectedGuildId ~= guildId then
        if not SelectTradingHouseGuildId or not SelectTradingHouseGuildId(guildId) then
            NWT.Debug("|cFF4444[Bookkeeper]|r Unable to select target guild at trader.")
            PlaySound(SOUNDS.NEGATIVE_CLICK)
            return
        end
        switchedGuild = true
    end

    gs.listingsScanInProgress = true
    bk.listingsScanActiveGuildId = guildId

    -- Single unfiltered pass to scan all listings for the selected guild.
    local scanPasses = { { filterType = nil, filterValues = nil } }

    bk.listingsScanState = {
        guildId = guildId,
        sellerCounts = {},
        pagesScanned = 0,
        totalRowsRead = 0,
        processedPages = {},
        searchRequestPending = false,
        pendingPage = nil,
        queuedPage = nil,
        queuedUseLastExecutedSearchFilters = false,
        nextRequestEarliestAtMs = 0,
        queueDrainScheduled = false,
        pageMismatchCount = 0,
        requestedPageRetries = {},
        scanPasses = scanPasses,
        scanPassIndex = 1,
        segmentedMode = false,
    }

    local function ResetPassPagingState(state)
        state.processedPages = {}
        state.searchRequestPending = false
        state.pendingPage = nil
        state.queuedPage = nil
        state.queuedUseLastExecutedSearchFilters = false
        state.nextRequestEarliestAtMs = 0
        state.queueDrainScheduled = false
        state.pageMismatchCount = 0
    end

    local function RequestListingsPage(page, useLastExecutedSearchFilters)
        local state = bk.listingsScanState
        if not state or state.guildId ~= guildId then return false end
        if state.searchRequestPending then return false end
        state.searchRequestPending = true
        state.pendingPage = page
        ExecuteTradingHouseSearch(page, TRADING_HOUSE_SORT_EXPIRY_TIME, true, useLastExecutedSearchFilters)
        return true
    end

    local function DrainQueuedListingsSearch()
        local state = bk.listingsScanState
        if not state or state.guildId ~= guildId then return end
        if state.queuedPage == nil then return end

        if state.searchRequestPending then
            return
        end

        local nowMs = GetFrameTimeMilliseconds()
        local earliestMs = tonumber(state.nextRequestEarliestAtMs) or 0
        if nowMs < earliestMs then
            return
        end

        local cooldownRemaining = 0
        if GetTradingHouseCooldownRemaining then
            cooldownRemaining = tonumber(GetTradingHouseCooldownRemaining()) or 0
        end
        if cooldownRemaining > 0 then
            return
        end

        local page = state.queuedPage
        local useLast = state.queuedUseLastExecutedSearchFilters
        if RequestListingsPage(page, useLast) then
            state.queuedPage = nil
            state.queuedUseLastExecutedSearchFilters = false
            state.nextRequestEarliestAtMs = 0
        end
    end

    local function ScheduleQueuedListingsSearchDrain(delayMs)
        local state = bk.listingsScanState
        if not state or state.guildId ~= guildId then return end
        if state.queueDrainScheduled then return end
        state.queueDrainScheduled = true
        zo_callLater(function()
            local currentState = bk.listingsScanState
            if not currentState or currentState.guildId ~= guildId then return end
            currentState.queueDrainScheduled = false
            DrainQueuedListingsSearch()
            if currentState.queuedPage ~= nil then
                ScheduleQueuedListingsSearchDrain(50)
            end
        end, delayMs or 0)
    end

    local function QueueListingsPage(page, useLastExecutedSearchFilters, minDelayMs)
        local state = bk.listingsScanState
        if not state or state.guildId ~= guildId then return end
        state.queuedPage = page
        state.queuedUseLastExecutedSearchFilters = useLastExecutedSearchFilters and true or false
        local nowMs = GetFrameTimeMilliseconds()
        local delay = tonumber(minDelayMs) or 0
        local targetMs = nowMs + math.max(0, delay)
        if targetMs > (state.nextRequestEarliestAtMs or 0) then
            state.nextRequestEarliestAtMs = targetMs
        end
        ScheduleQueuedListingsSearchDrain(delay > 0 and delay or 0)
    end

    local function StartCurrentScanPass()
        local state = bk.listingsScanState
        if not state or state.guildId ~= guildId then return end
        local pass = state.scanPasses[state.scanPassIndex]
        if not pass then
            FinalizeBookkeeperListingsScan(guildId, state.sellerCounts, true)
            return
        end

        ResetPassPagingState(state)
        ClearAllTradingHouseSearchTerms()
        if pass.filterType and pass.filterValues then
            SetTradingHouseFilter(pass.filterType, pass.filterValues)
        end
        QueueListingsPage(0, false, 0)
    end

    EVENT_MANAGER:UnregisterForEvent(BOOKKEEPER_LISTINGS_SCAN_EVENT, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED)
    EVENT_MANAGER:RegisterForEvent(BOOKKEEPER_LISTINGS_SCAN_EVENT, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, function(_, responseType, result)
        local state = bk.listingsScanState
        if not state or state.guildId ~= guildId then return end
        if responseType ~= TRADING_HOUSE_RESULT_SEARCH_PENDING then return end

        local requestedPage = state.pendingPage

        if result ~= TRADING_HOUSE_RESULT_SUCCESS then
            state.searchRequestPending = false
            state.pendingPage = nil
            FinalizeBookkeeperListingsScan(guildId, state.sellerCounts, false, result)
            return
        end

        local numItemsOnPage, currentPage, hasMorePages = GetTradingHouseSearchResultsInfo()
        currentPage = currentPage or 0
        state.searchRequestPending = false
        state.pendingPage = nil

        -- Keep requests strictly sequential. If the response does not match the page we asked for,
        -- retry that requested page with pacing instead of dispatching new pages.
        if requestedPage ~= nil and currentPage ~= requestedPage then
            state.pageMismatchCount = (state.pageMismatchCount or 0) + 1
            state.requestedPageRetries[requestedPage] = (state.requestedPageRetries[requestedPage] or 0) + 1

            -- Never finalize success on a mismatch. Retry the page we requested.
            if state.pageMismatchCount >= 20 or state.requestedPageRetries[requestedPage] >= 12 then
                FinalizeBookkeeperListingsScan(
                    guildId,
                    state.sellerCounts,
                    false,
                    "page_mismatch_stall_" .. tostring(requestedPage)
                )
                return
            end
            QueueListingsPage(requestedPage, true, LISTINGS_PAGE_DELAY_MS + 500)
            return
        end
        state.pageMismatchCount = 0
        if requestedPage ~= nil then
            state.requestedPageRetries[requestedPage] = nil
        end

        local isDuplicatePage = state.processedPages[currentPage] == true
        if not isDuplicatePage then
            state.processedPages[currentPage] = true
            state.pagesScanned = (state.pagesScanned or 0) + 1
            state.totalRowsRead = (state.totalRowsRead or 0) + (numItemsOnPage or 0)

            for i = 1, (numItemsOnPage or 0) do
                local _, _, _, _, sellerName = GetTradingHouseSearchResultItemInfo(i)
                sellerName = NormalizeDisplayName(sellerName)
                if sellerName then
                    state.sellerCounts[sellerName] = (state.sellerCounts[sellerName] or 0) + 1
                end
            end
        end

        if hasMorePages then
            local nextPage = currentPage + 1
            QueueListingsPage(nextPage, true, LISTINGS_PAGE_DELAY_MS)
        else
            if state.scanPassIndex < #state.scanPasses then
                state.scanPassIndex = state.scanPassIndex + 1
                zo_callLater(StartCurrentScanPass, LISTINGS_PAGE_DELAY_MS)
            else
                FinalizeBookkeeperListingsScan(guildId, state.sellerCounts, true)
            end
        end
    end)

    local function StartListingsSearch()
        if not bk.listingsScanState or bk.listingsScanState.guildId ~= guildId then return end
        StartCurrentScanPass()
    end

    local kickoffDelay = switchedGuild and 250 or 50
    zo_callLater(StartListingsSearch, kickoffDelay)

    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.Debug("|c00FFFF[Bookkeeper]|r Scanning guild trader listings for " .. (GetGuildName(guildId) or ("Guild " .. tostring(guildId))) .. "...")
    NWT.UpdateBookkeeperUI()
    UpdateBookkeeperTradingHouseKeybind()
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor)
    end
end

function NWT.BuildBookkeeperMemberList(guildId)
    local bk = NWT.Bookkeeper
    local guildSettings = GetBookkeeperGuildSettings(guildId)
    local freeTraderMode = IsFreeTraderMode(guildSettings)
    local listingTarget = GetListingTarget(guildSettings)
    bk.sortedMembers = {}
    local searchLower = bk.searchText and bk.searchText:lower() or ""
    
    local now = GetTimeStamp()
    local currentDate = GetDate()
    local currentYear = tonumber(tostring(currentDate):sub(1, 4)) or 2026
    local currentMonth = tonumber(tostring(currentDate):sub(5, 6)) or 1
    local currentDay = tonumber(tostring(currentDate):sub(7, 8)) or 1
    
    if guildSettings.memberPayments then
        for name, data in pairs(guildSettings.memberPayments) do
            if data.isCurrentMember then
                local isLifetime = guildSettings.lifetimeMembers and guildSettings.lifetimeMembers[name]
                local isExemptRank = IsRankExempt(guildSettings, data.rankIndex, guildId)
                
                -- Bank deposits are primary source of truth
                local hasBankPaid = ((data.thisWeekDues or 0) > 0) or ((data.duesMonths or 0) > 0)
                
                -- Notes are fallback when bank doesn't show them as paid
                local isPaidViaNote = false
                local daysOverdue = 0
                local daysUntilDue = 0
                if not hasBankPaid and guildSettings.paymentHistory and guildSettings.paymentHistory[name] then
                    local ph = guildSettings.paymentHistory[name]
                    if ph.payments and #ph.payments > 0 then
                        local latest = ph.payments[#ph.payments]
                        -- Validate date values before using os.time (must be valid month 1-12, day 1-31, year > 2000)
                        local dueMonth = tonumber(latest.dueMonth) or 0
                        local dueDay = tonumber(latest.dueDay) or 0
                        local dueYear = tonumber(latest.dueYear) or currentYear
                        if dueMonth >= 1 and dueMonth <= 12 and dueDay >= 1 and dueDay <= 31 and dueYear > 2000 then
                            -- Calculate due date timestamp for comparison
                            local success, dueTimestamp = pcall(os.time, {year = dueYear, month = dueMonth, day = dueDay, hour = 0, min = 0, sec = 0})
                            if success and dueTimestamp then
                                local nowTimestamp = os.time({year = currentYear, month = currentMonth, day = currentDay, hour = 0, min = 0, sec = 0})
                                
                                if dueTimestamp >= nowTimestamp then
                                    -- Due date is today or in the future = paid
                                    isPaidViaNote = true
                                    daysUntilDue = math.floor((dueTimestamp - nowTimestamp) / 86400)
                                else
                                    -- Due date is in the past = overdue
                                    daysOverdue = math.floor((nowTimestamp - dueTimestamp) / 86400)
                                end
                            end
                        end
                    end
                end
                data.isPaidViaNote = isPaidViaNote
                data.daysOverdue = daysOverdue
                data.daysUntilDue = daysUntilDue

                local listingCount = 0
                if guildSettings.memberListingCounts then
                    listingCount = tonumber(guildSettings.memberListingCounts[name]) or 0
                end
                data.listingsCount = listingCount
                data.listingTarget = listingTarget

                local isPaidUp
                if freeTraderMode then
                    isPaidUp = listingCount >= listingTarget
                else
                    isPaidUp = ((data.thisWeekDues or 0) > 0) or ((data.duesMonths or 0) > 0) or isLifetime or isExemptRank or isPaidViaNote
                end
                data.isExemptRank = isExemptRank
                local include = true

                -- Filter by status (modes 2 and 3).
                -- In free trader mode these become "no listings" and "has listings".
                if bk.filterMode == 2 then
                    if freeTraderMode then
                        include = listingCount == 0
                    else
                        include = not isPaidUp
                    end
                elseif bk.filterMode == 3 then
                    if freeTraderMode then
                        include = listingCount > 0
                    else
                        include = isPaidUp
                    end
                end
                
                -- Apply search filter
                if include and searchLower ~= "" then
                    include = name:lower():find(searchLower, 1, true) ~= nil
                end
                
                if include then table.insert(bk.sortedMembers, data) end
            end
        end
    end
    
    -- Sort based on filter mode
    if bk.filterMode == 4 then
        -- Name A-Z
        table.sort(bk.sortedMembers, function(a, b) return a.name:lower() < b.name:lower() end)
    elseif bk.filterMode == 5 then
        -- Name Z-A
        table.sort(bk.sortedMembers, function(a, b) return a.name:lower() > b.name:lower() end)
    elseif bk.filterMode == 6 then
        -- Last Paid (most recent first)
        table.sort(bk.sortedMembers, function(a, b) return (a.lastPayment or 0) > (b.lastPayment or 0) end)
    else
        if freeTraderMode then
            -- Default in free trader mode: sort by listing count then name.
            table.sort(bk.sortedMembers, function(a, b)
                if (a.listingsCount or 0) ~= (b.listingsCount or 0) then return (a.listingsCount or 0) > (b.listingsCount or 0) end
                return a.name < b.name
            end)
        else
            -- Default: sort by dues months then name
            table.sort(bk.sortedMembers, function(a, b)
                if (a.duesMonths or 0) ~= (b.duesMonths or 0) then return (a.duesMonths or 0) > (b.duesMonths or 0) end
                return a.name < b.name
            end)
        end
    end
    
    if bk.selectedMemberIndex > #bk.sortedMembers then bk.selectedMemberIndex = math.max(1, #bk.sortedMembers) end
end

function NWT.BookkeeperCycleFilter()
    local bk = NWT.Bookkeeper
    if bk.rankMenuOpen then return end
    bk.filterMode = (bk.filterMode % 6) + 1
    bk.selectedMemberIndex, bk.memberScrollOffset = 1, 0
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateBookkeeperUI()
    NWT.SyncHiddenBookkeeperList()
end

function NWT.BookkeeperPromptSearch()
    local bk = NWT.Bookkeeper
    if bk.rankMenuOpen or bk.settingsMenuOpen or bk.duesSettingsOpen then return end
    
    -- Create edit box if needed (uses console virtual keyboard)
    if not bk.searchEditBox then
        local eb = WINDOW_MANAGER:CreateControl("BookkeeperSearchEditBox", ATK_Bookkeeper_UI, CT_EDITBOX)
        eb:SetDimensions(400, 50)
        eb:SetAnchor(CENTER, ATK_Bookkeeper_UI, CENTER, 0, 0)
        eb:SetFont("ZoFontGamepad34")
        eb:SetMaxInputChars(30)
        eb:SetVirtualKeyboardType(VIRTUAL_KEYBOARD_TYPE_DEFAULT)
        eb:SetHandler("OnEnter", function(self)
            local txt = self:GetText()
            bk.searchText = txt or ""
            bk.selectedMemberIndex, bk.memberScrollOffset = 1, 0
            NWT.UpdateBookkeeperUI()
            NWT.SyncHiddenBookkeeperList()
            if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then 
                KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) 
            end
            self:SetHidden(true)
            self:LoseFocus()
            PlaySound(SOUNDS.POSITIVE_CLICK)
        end)
        eb:SetHandler("OnEscape", function(self)
            self:SetHidden(true)
            self:LoseFocus()
        end)
        bk.searchEditBox = eb
    end
    
    bk.searchEditBox:SetText(bk.searchText or "")
    bk.searchEditBox:SetHidden(false)
    bk.searchEditBox:TakeFocus()
end

function NWT.BookkeeperClearSearch()
    local bk = NWT.Bookkeeper
    bk.searchText = ""
    bk.selectedMemberIndex, bk.memberScrollOffset = 1, 0
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateBookkeeperUI()
    NWT.SyncHiddenBookkeeperList()
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then 
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) 
    end
end

function NWT.UpdateBookkeeperUI()
    local ui = ATK_Bookkeeper_UI
    if not ui then 
NWT.Debug("|cFF0000[Bookkeeper]|r ATK_Bookkeeper_UI not found!")
        return 
    end
    
    local bk = NWT.Bookkeeper
    local guildId, guildName, guildSettings, numGuilds
    
    -- Demo mode uses fake data
    if bk.demoMode then
        numGuilds = #DEMO_GUILDS
        local demoGuild = DEMO_GUILDS[bk.viewingGuildIndex] or DEMO_GUILDS[1]
        guildId = demoGuild.id
        guildName = demoGuild.name
        guildSettings = GetDemoSettings()
        NWT.BuildBookkeeperMemberList_Demo()
    else
        numGuilds = GetNumGuilds()
        if numGuilds == 0 then return end
        guildId = GetGuildId(bk.viewingGuildIndex)
        guildName = GetGuildName(guildId)
        guildSettings = GetBookkeeperGuildSettings(guildId)
        NWT.BuildBookkeeperMemberList(guildId)
    end
    
    local isGuildsFocus = (bk.focusPanel == "guilds")
    local isDuesFocus = (bk.focusPanel == "dues")
    
    -- Use the new UI update function
    NWT.UpdateBookkeeperUI_New(ui, bk, guildId, guildName, guildSettings, isGuildsFocus, isDuesFocus, numGuilds)
end

-- Build member list from demo data
function NWT.BuildBookkeeperMemberList_Demo()
    local bk = NWT.Bookkeeper
    local gs = GetDemoSettings()
    local freeTraderMode = IsFreeTraderMode(gs)
    local listingTarget = GetListingTarget(gs)
    bk.sortedMembers = {}
    local searchLower = bk.searchText and bk.searchText:lower() or ""
    
    for name, data in pairs(gs.memberPayments) do
        local isLifetime = gs.lifetimeMembers and gs.lifetimeMembers[name]
        local isExemptRank = IsRankExempt(gs, data.rankIndex, 0)
        local listingCount = gs.memberListingCounts and (tonumber(gs.memberListingCounts[name]) or 0) or 0
        data.listingsCount = listingCount
        data.listingTarget = listingTarget
        local isPaidUp
        if freeTraderMode then
            isPaidUp = listingCount >= listingTarget
        else
            isPaidUp = ((data.thisWeekDues or 0) > 0) or ((data.duesMonths or 0) > 0) or isLifetime or isExemptRank
        end
        data.isExemptRank = isExemptRank
        
        local include = true
        if bk.filterMode == 2 then
            if freeTraderMode then
                include = listingCount == 0
            else
                include = not isPaidUp
            end
        elseif bk.filterMode == 3 then
            if freeTraderMode then
                include = listingCount > 0
            else
                include = isPaidUp
            end
        end
        
        -- Apply search filter
        if include and searchLower ~= "" then
            include = name:lower():find(searchLower, 1, true) ~= nil
        end
        
        if include then
            table.insert(bk.sortedMembers, data)
        end
    end
    
    -- Sort based on filter mode
    if bk.filterMode == 4 then
        table.sort(bk.sortedMembers, function(a, b) return a.name:lower() < b.name:lower() end)
    elseif bk.filterMode == 5 then
        table.sort(bk.sortedMembers, function(a, b) return a.name:lower() > b.name:lower() end)
    elseif bk.filterMode == 6 then
        table.sort(bk.sortedMembers, function(a, b) return (a.lastPayment or 0) > (b.lastPayment or 0) end)
    else
        if freeTraderMode then
            table.sort(bk.sortedMembers, function(a, b)
                if (a.listingsCount or 0) ~= (b.listingsCount or 0) then return (a.listingsCount or 0) > (b.listingsCount or 0) end
                return a.name < b.name
            end)
        else
            table.sort(bk.sortedMembers, function(a, b)
                local aLife = gs.lifetimeMembers and gs.lifetimeMembers[a.name]
                local bLife = gs.lifetimeMembers and gs.lifetimeMembers[b.name]
                local aExempt = a.isExemptRank
                local bExempt = b.isExemptRank
                local aPaid = (a.thisWeekDues or 0) > 0
                local bPaid = (b.thisWeekDues or 0) > 0
                local aPre = (a.duesMonths or 0) > 0
                local bPre = (b.duesMonths or 0) > 0
                
                if aLife ~= bLife then return aLife end
                if aExempt ~= bExempt then return aExempt end
                if aPaid ~= bPaid then return aPaid end
                if aPre ~= bPre then return aPre end
                if (a.duesMonths or 0) ~= (b.duesMonths or 0) then return (a.duesMonths or 0) > (b.duesMonths or 0) end
                return a.name < b.name
            end)
        end
    end
    
    if bk.selectedMemberIndex > #bk.sortedMembers then 
        bk.selectedMemberIndex = math.max(1, #bk.sortedMembers) 
    end
end

-- OLD UI CODE REMOVED - keeping for reference if needed
function NWT.UpdateBookkeeperUI_OLD_UNUSED()
    local ui = nil
    if not ui then return end
    local bk = NWT.Bookkeeper
    local numGuilds = GetNumGuilds()
    local guildId = GetGuildId(bk.viewingGuildIndex)
    local guildName = GetGuildName(guildId)
    local guildSettings = GetBookkeeperGuildSettings(guildId)
    local isSalesFocus = (bk.focusPanel == "sales")
    ui:GetNamedChild("Title"):SetText("|cFFFFFF" .. guildName .. "|r" .. (guildSettings.lastScanTime > 0 and " |c888888(Scanned " .. NWT.FormatTimeAgo(guildSettings.lastScanTime) .. ")|r" or ""))

    -- Build sorted guild list (favorites first)
    local sortedGuilds = {}
    for i = 1, numGuilds do
        local gId = GetGuildId(i)
        if gId and gId > 0 then
            table.insert(sortedGuilds, { index = i, guildId = gId, isFavorite = IsGuildFavorite(gId) })
        end
    end
    table.sort(sortedGuilds, function(a, b)
        if a.isFavorite ~= b.isFavorite then return a.isFavorite end
        return a.index < b.index
    end)
    bk.sortedGuildList = sortedGuilds  -- Store for navigation
    
    -- Update Guild Selection Panel
    local gp = ui:GetNamedChild("StatsPanel")
    if gp then
        gp:GetNamedChild("BG"):SetEdgeColor(isGuildsFocus and 1 or 0.3, isGuildsFocus and 0.8 or 0.3, isGuildsFocus and 0 or 0.3, 1)
        
        -- Position guild selection indicator
        local guildSel = gp:GetNamedChild("Selection")
        if guildSel then
            if isGuildsFocus and #sortedGuilds > 0 then
                local yOffsets = { 53, 88, 123, 158, 193 }
                local yPos = yOffsets[bk.selectedGuildIndex] or 53
                guildSel:ClearAnchors()
                guildSel:SetAnchor(TOPLEFT, gp, TOPLEFT, 15, yPos)
                guildSel:SetEdgeColor(1, 1, 1, 1)
                guildSel:SetHidden(false)
            else
                guildSel:SetHidden(true)
            end
        end
        
        for i = 1, 5 do
            local gLabel = gp:GetNamedChild("Guild" .. i)
            if gLabel then
                local guildData = sortedGuilds[i]
                if guildData then
                    local gId = guildData.guildId
                    local gName = GetGuildName(gId)
                    local isEnabled = IsGuildEnabled(gId)
                    local isFav = guildData.isFavorite
                    local isSelected = (bk.selectedGuildIndex == i)
                    local color = isEnabled and (isSelected and "|cFFD700" or "|cFFFFFF") or "|c888888"
                    local prefix = "  "
                    local starPrefix = isFav and "|cFFD700★|r " or ""
                    local suffix = isEnabled and "" or " |c888888(off)|r"
                    gLabel:SetText(color .. prefix .. starPrefix .. gName .. suffix)
                    gLabel:SetHidden(false)
                else
                    gLabel:SetHidden(true)
                end
            end
        end
    end

    local dp = ui:GetNamedChild("DuesList")
    if dp then
        dp:GetNamedChild("BG"):SetEdgeColor(isDuesFocus and 1 or 0.3, isDuesFocus and 0.8 or 0.3, isDuesFocus and 0 or 0.3, 1)
        for i = 1, bk.maxVisibleMembers do
            local nameLabel = dp:GetNamedChild("Row" .. i .. "Name")
            local monthsLabel = dp:GetNamedChild("Row" .. i .. "Months")
            local lastLabel = dp:GetNamedChild("Row" .. i .. "Last")
            local rankLabel = dp:GetNamedChild("Row" .. i .. "Rank")
            local mIdx = i + bk.memberScrollOffset
            local member = bk.sortedMembers[mIdx]
            
            if member then
                local isSel = (mIdx == bk.selectedMemberIndex)
                local isLife = guildSettings.lifetimeMembers and guildSettings.lifetimeMembers[member.name]
                local isExempt = member.isExemptRank
                local rank = member.rankIndex and GetGuildRankCustomName(guildId, member.rankIndex) or "Unknown"
                if not rank or rank == "" then rank = "R" .. (member.rankIndex or "?") end
                if #rank > 12 then rank = rank:sub(1,10) .. ".." end
                local displayName = member.name:gsub("^@", "")
                if #displayName > 14 then displayName = displayName:sub(1,12) .. ".." end
                local timeAgo = (member.lastPayment or 0) > 0 and NWT.FormatTimeAgo(member.lastPayment) or "Never"
                
                -- Color name based on status
                local nameColor = "|cFFFFFF"
                if isSel then nameColor = "|cFFD700"
                elseif isLife then nameColor = "|c00FFFF"
                elseif isExempt then nameColor = "|cFF00FF"
                elseif (member.thisWeekDues or 0) > 0 then nameColor = "|c00FF00"
                elseif (member.duesMonths or 0) > 0 then nameColor = "|cFFFF00"
                else nameColor = "|cFF4444" end
                
                local selMark = isSel and "►" or ""
                if nameLabel then nameLabel:SetText(nameColor .. selMark .. displayName .. "|r") nameLabel:SetHidden(false) end
                if monthsLabel then 
                    if isLife then monthsLabel:SetText("|c00FFFFLIFE|r")
                    elseif isExempt then monthsLabel:SetText("|cFF00FFEXMT|r")
                    else 
                        local periodSuffix = "w"
                        if guildSettings.duesPeriod == "monthly" then periodSuffix = "m"
                        elseif guildSettings.duesPeriod == "biweekly" then periodSuffix = "bw" end
                        monthsLabel:SetText(tostring(member.duesMonths) .. periodSuffix) 
                    end
                    monthsLabel:SetHidden(false) 
                end
                if lastLabel then 
                    if isLife or isExempt then lastLabel:SetText("|c888888---|r")
                    else lastLabel:SetText("|c888888" .. timeAgo .. "|r") end
                    lastLabel:SetHidden(false) 
                end
                if rankLabel then rankLabel:SetText("|c888888" .. rank .. "|r") rankLabel:SetHidden(false) end
                
                -- Position selection indicator on selected row
                if isSel then
                    local selection = dp:GetNamedChild("Selection")
                    if selection then
                        local rowY = 62 + (i - 1) * 34
                        selection:ClearAnchors()
                        selection:SetAnchor(TOPLEFT, dp, TOPLEFT, 10, rowY)
                        selection:SetHidden(not isDuesFocus or #bk.sortedMembers == 0)
                    end
                end
            else
                if nameLabel then nameLabel:SetText("") nameLabel:SetHidden(true) end
                if monthsLabel then monthsLabel:SetText("") monthsLabel:SetHidden(true) end
                if lastLabel then lastLabel:SetText("") lastLabel:SetHidden(true) end
                if rankLabel then rankLabel:SetText("") rankLabel:SetHidden(true) end
            end
        end
        -- Hide selection if list is empty
        if #bk.sortedMembers == 0 then
            local selection = dp:GetNamedChild("Selection")
            if selection then selection:SetHidden(true) end
        end
    end
    -- Calculate and display summary stats
    local paidCount, unpaidCount, prepaidCount, lifetimeCount, exemptCount = 0, 0, 0, 0, 0
    local totalDuesCollected, totalRaffleCollected = 0, 0
    local paidLastWeekCount = 0
    
    -- Calculate last week's Tuesday to this Tuesday (flip day)
    local now = GetTimeStamp()
    local currentTime = os.date("*t", now)
    local dayOfWeek = currentTime.wday  -- 1=Sunday, 3=Tuesday
    local daysSinceTuesday = (dayOfWeek - 3) % 7
    local thisTuesdayMidnight = now - (daysSinceTuesday * 86400) - (currentTime.hour * 3600) - (currentTime.min * 60) - currentTime.sec
    local lastTuesdayMidnight = thisTuesdayMidnight - (7 * 86400)
    
    for name, m in pairs(guildSettings.memberPayments or {}) do
        if m.isCurrentMember then
            local isLife = guildSettings.lifetimeMembers and guildSettings.lifetimeMembers[name]
            local isExempt = IsRankExempt(guildSettings, m.rankIndex, guildId)
            if isLife then lifetimeCount = lifetimeCount + 1
            elseif isExempt then exemptCount = exemptCount + 1
            elseif m.thisWeekDues > 0 then paidCount = paidCount + 1
            elseif m.duesMonths > 0 then prepaidCount = prepaidCount + 1
            elseif m.isPaidViaNote then paidCount = paidCount + 1  -- Note-based paid
            else unpaidCount = unpaidCount + 1 end
            totalDuesCollected = totalDuesCollected + (m.totalDeposited or 0) - (m.raffleTotal or 0) - (m.otherTotal or 0)
            totalRaffleCollected = totalRaffleCollected + (m.raffleTotal or 0)
            
            -- Count paid last week (excluding exempt/lifetime)
            if not isLife and not isExempt and m.deposits then
                for _, dep in ipairs(m.deposits) do
                    if dep.type == "dues" and dep.timestamp >= lastTuesdayMidnight and dep.timestamp < thisTuesdayMidnight then
                        paidLastWeekCount = paidLastWeekCount + 1
                        break  -- Only count each member once
                    end
                end
            end
        end
    end
    
    local summary = dp and dp:GetNamedChild("Summary")
    if summary then
        summary:SetText(string.format("|c00FF00%d|r Paid   |cFFFF00%d|r Pre   |cFF6666%d|r Owe", paidCount, prepaidCount, unpaidCount))
    end
    
    -- Stats panel (left side)
    local statPanel = ui:GetNamedChild("ExtraStatsPanel")
    if statPanel then
        local s1 = statPanel:GetNamedChild("Members")
        local s2 = statPanel:GetNamedChild("Collected")
        local s3 = statPanel:GetNamedChild("Raffle")
        local s4 = statPanel:GetNamedChild("LastWeek")
        if s1 then s1:SetText(string.format("|cFFFFAAMembers:|r %d", GetNumGuildMembers(guildId))) end
        if s2 then s2:SetText(string.format("|cFFFFAADues:|r |c00FF00%sg|r", NWT.FormatGold(totalDuesCollected))) end
        if s3 then s3:SetText(string.format("|cFFFFAARaffle:|r |c00FF00%sg|r", NWT.FormatGold(totalRaffleCollected))) end
        if s4 then s4:SetText(string.format("|cFFFFAAPaid Last Wk:|r |cAAFFAA%d|r", paidLastWeekCount)) end
    end
    
    -- Raffle panel removed - now a separate feature
    local rafflePanel = ui:GetNamedChild("RaffleList")
    if rafflePanel then
        rafflePanel:SetHidden(true) -- Raffle is now separate
    end

    -- Sales Panel
    local salesPanel = ui:GetNamedChild("SalesList")
    if salesPanel then
        salesPanel:GetNamedChild("BG"):SetEdgeColor(isSalesFocus and 1 or 0.3, isSalesFocus and 0.8 or 0.3, isSalesFocus and 0 or 0.3, 1)
        salesPanel:SetHidden(not isSalesFocus)
        
        local salesEntries = {}
        local totalSalesGold = 0
        if guildSettings.salesData then
            for eventId, sale in pairs(guildSettings.salesData) do
                table.insert(salesEntries, sale)
                totalSalesGold = totalSalesGold + (sale.price or 0)
            end
        end
        table.sort(salesEntries, function(a, b) return (a.timestamp or 0) > (b.timestamp or 0) end)
        bk.salesEntriesCount = #salesEntries

        local header = salesPanel:GetNamedChild("Header")
        if header then header:SetText("|c00FFFFRecent Sales|r") end

        for i = 1, bk.maxVisibleSales do
            local nameLabel = salesPanel:GetNamedChild("Row" .. i .. "Name")
            local itemLabel = salesPanel:GetNamedChild("Row" .. i .. "Item")
            local goldLabel = salesPanel:GetNamedChild("Row" .. i .. "Gold")
            
            local entryIdx = i + bk.salesScrollOffset
            local entry = salesEntries[entryIdx]
            if entry then
                local sellerShort = entry.seller:gsub("^@", "")
                if #sellerShort > 10 then sellerShort = sellerShort:sub(1,8) .. ".." end
                
                if nameLabel then nameLabel:SetText("|cFFFFFF" .. sellerShort .. "|r") nameLabel:SetHidden(false) end
                if itemLabel then 
                    local itemLink = entry.itemLink or "Item"
                    itemLabel:SetText(itemLink) 
                    itemLabel:SetHidden(false) 
                end
                if goldLabel then goldLabel:SetText("|c00FF00" .. NWT.FormatGold(entry.price) .. "|r") goldLabel:SetHidden(false) end
            else
                if nameLabel then nameLabel:SetText("") nameLabel:SetHidden(true) end
                if itemLabel then itemLabel:SetText("") itemLabel:SetHidden(true) end
                if goldLabel then goldLabel:SetText("") goldLabel:SetHidden(true) end
            end
        end

        local totalLabel = salesPanel:GetNamedChild("Total")
        if totalLabel then
            totalLabel:SetText(string.format("|cFFFF00%d sales|r |c00FF00%sg|r", #salesEntries, NWT.FormatGold(totalSalesGold)))
        end
    end

    local ctrl = ui:GetNamedChild("Controls")
    if ctrl then 
        local focusHint = ""
        if isGuildsFocus then focusHint = "|cFFFFFFGuilds|r |c888888→ Dues → Sales|r"
        elseif isDuesFocus then focusHint = "|c888888Guilds ←|r |cFFFFFFDues|r |c888888→ Sales|r"
        else focusHint = "|c888888Guilds ← Dues ←|r |cFFFFFFSales|r" end
        ctrl:SetText(string.format("|c888888[LB/RB] Navigate  [A] Select  [RS] Scan|r  %s", focusHint))
    end
    
    -- Show/hide confirmation dialog (dynamically created)
    if bk.confirmDialogOpen and bk.pendingNoteUpdate then
        ShowConfirmDialog(bk.pendingNoteUpdate)
    else
        HideConfirmDialog()
    end
end

-- ============================================
-- NEW UI UPDATE FUNCTION
-- ============================================

function NWT.UpdateBookkeeperUI_New(ui, bk, guildId, guildName, guildSettings, isGuildsFocus, isDuesFocus, numGuilds)
    local freeTraderMode = IsFreeTraderMode(guildSettings)
    local listingTarget = GetListingTarget(guildSettings)
    local function GetCurrentFilterLabel()
        if freeTraderMode then
            if bk.filterMode == 2 then return "No Listings" end
            if bk.filterMode == 3 then return "Has Listings" end
        end
        return bk.filterModes[bk.filterMode] or "All Members"
    end

    -- Header
    local header = ui:GetNamedChild("Header")
    if header then
        local title = header:GetNamedChild("Title")
        local subtitle = header:GetNamedChild("Subtitle")
        if title then title:SetText("|c00FFFFGUILD BOOKKEEPER|r") end
        if subtitle then 
            local scanTime = freeTraderMode and (guildSettings.listingsLastScanTime or 0) or (guildSettings.lastScanTime or 0)
            local scanText = scanTime > 0 and " • Scanned " .. NWT.FormatTimeAgo(scanTime) or ""
            if freeTraderMode and guildSettings.listingsScanInProgress then
                scanText = " • Scanning listings..."
            end
            subtitle:SetText("|cFFFFFF" .. guildName .. "|r" .. scanText)
        end
    end
    
    -- Build sorted guild list (favorites first) - use demo data if in demo mode
    local sortedGuilds = {}
    if bk.demoMode then
        for i, dg in ipairs(DEMO_GUILDS) do
            table.insert(sortedGuilds, { index = i, guildId = dg.id, name = dg.name, isFavorite = dg.isFavorite, memberCount = dg.memberCount })
        end
    else
        for i = 1, numGuilds do
            local gId = GetGuildId(i)
            if gId and gId > 0 then
                table.insert(sortedGuilds, { index = i, guildId = gId, isFavorite = IsGuildFavorite(gId) })
            end
        end
        table.sort(sortedGuilds, function(a, b)
            if a.isFavorite ~= b.isFavorite then return a.isFavorite end
            return a.index < b.index
        end)
    end
    bk.sortedGuildList = sortedGuilds
    
    -- Left Column: Guilds Card
    local leftCol = ui:GetNamedChild("LeftCol")
    if leftCol then
        local gCard = leftCol:GetNamedChild("GuildsCard")
        if gCard then
            local gBG = gCard:GetNamedChild("BG")
            local gFocus = gCard:GetNamedChild("FocusGlow")
            local gPlate = gCard:GetNamedChild("HeaderPlate")
            if isGuildsFocus then
                if gBG then gBG:SetEdgeColor(0, 0.8, 0.8, 1) end
                if gFocus then gFocus:SetHidden(false) end
                if gPlate then gPlate:SetEdgeColor(0, 0.8, 0.8, 1) end
            else
                if gBG then gBG:SetEdgeColor(0.3, 0.3, 0.3, 1) end
                if gFocus then gFocus:SetHidden(true) end
                if gPlate then gPlate:SetEdgeColor(0.3, 0.3, 0.3, 1) end
            end
            
            local gList = gCard:GetNamedChild("List")
            if gList then
                for i = 1, 5 do
                    local gLabel = gList:GetNamedChild("Guild" .. i)
                    if not gLabel then
                        gLabel = WINDOW_MANAGER:CreateControl("$(parent)Guild" .. i, gList, CT_LABEL)
                        gLabel:SetFont("ZoFontGamepad34")
                        gLabel:SetDimensions(320, 45)
                        gLabel:SetAnchor(TOPLEFT, gList, TOPLEFT, 20, (i-1) * 45)
                    end
                    
                    local guildData = sortedGuilds[i]
                    if guildData then
                        local gName = bk.demoMode and guildData.name or GetGuildName(guildData.guildId)
                        local isEnabled = true
                        local isFav = guildData.isFavorite
                        local isSelected = (bk.selectedGuildIndex == i)
                        
                        local color = isEnabled and (isSelected and "|c00FFFF" or "|cFFFFFF") or "|c888888"
                        local starPrefix = isFav and "|cFFD700★|r " or ""
                        local prefix = isSelected and "► " or "  "
                        local suffix = isEnabled and "" or " (off)"
                        gLabel:SetText(color .. prefix .. starPrefix .. gName .. suffix .. "|r")
                        gLabel:SetHidden(false)
                    else
                        gLabel:SetHidden(true)
                    end
                end
                
                -- Guild selection frame
                local gSelFrame = gList:GetNamedChild("SelectionFrame")
                if gSelFrame then
                    if isGuildsFocus and #sortedGuilds > 0 then
                        gSelFrame:ClearAnchors()
                        gSelFrame:SetAnchor(TOPLEFT, gList, TOPLEFT, 5, (bk.selectedGuildIndex - 1) * 45)
                        gSelFrame:SetHidden(false)
                    else
                        gSelFrame:SetHidden(true)
                    end
                end
            end
        end
        
        -- Stats Card
        local sCard = leftCol:GetNamedChild("StatsCard")
        if sCard then
            local paidCount, unpaidCount, prepaidCount, lifetimeCount, exemptCount = 0, 0, 0, 0, 0
            local totalDuesCollected, totalRaffleCollected = 0, 0
            local listedCount, targetMetCount, totalListings = 0, 0, 0

            for name, m in pairs(guildSettings.memberPayments or {}) do
                if m.isCurrentMember then
                    local listingCount = guildSettings.memberListingCounts and (tonumber(guildSettings.memberListingCounts[name]) or 0) or 0
                    if listingCount > 0 then listedCount = listedCount + 1 end
                    if listingCount >= listingTarget then targetMetCount = targetMetCount + 1 end
                    totalListings = totalListings + listingCount

                    local isLife = guildSettings.lifetimeMembers and guildSettings.lifetimeMembers[name]
                    local isExempt = IsRankExempt(guildSettings, m.rankIndex, guildId)
                    if isLife then lifetimeCount = lifetimeCount + 1
                    elseif isExempt then exemptCount = exemptCount + 1
                    elseif m.thisWeekDues > 0 then paidCount = paidCount + 1
                    elseif m.duesMonths > 0 then prepaidCount = prepaidCount + 1
                    elseif m.isPaidViaNote then paidCount = paidCount + 1
                    else unpaidCount = unpaidCount + 1 end
                    totalDuesCollected = totalDuesCollected + (m.totalDeposited or 0) - (m.raffleTotal or 0) - (m.otherTotal or 0)
                    totalRaffleCollected = totalRaffleCollected + (m.raffleTotal or 0)
                end
            end

            local members = sCard:GetNamedChild("Members")
            local paidLabel = sCard:GetNamedChild("PaidCount")
            local unpaidLabel = sCard:GetNamedChild("UnpaidCount")
            local lifeLabel = sCard:GetNamedChild("LifetimeCount")
            local duesLabel = sCard:GetNamedChild("DuesCollected")
            local raffleLabel = sCard:GetNamedChild("RaffleCollected")
            local duesAmtLabel = sCard:GetNamedChild("DuesAmount")
            local scanLabel = sCard:GetNamedChild("LastScan")
            
            local memberCount = bk.demoMode and (DEMO_GUILDS[bk.viewingGuildIndex] and DEMO_GUILDS[bk.viewingGuildIndex].memberCount or 500) or GetNumGuildMembers(guildId)
            if members then members:SetText(string.format("|c00FFFFMembers:|r  |cFFFFFF%d|r", memberCount)) end
            if freeTraderMode then
                if paidLabel then paidLabel:SetText(string.format("|c00FF00Listed:|r  |cFFFFFF%d|r  |cFFFF00Target:|r  |cFFFFFF%d|r", listedCount, targetMetCount)) end
                if unpaidLabel then unpaidLabel:SetText(string.format("|cFF4444Not Listed:|r  |cFFFFFF%d|r", math.max(0, memberCount - listedCount))) end
                if lifeLabel then lifeLabel:SetText(string.format("|c00FFFFTarget Per Member:|r  |cFFFFFF%d|r", listingTarget)) end
                if duesLabel then duesLabel:SetText(string.format("|c00FFFFTotal Listings:|r  |cFFFFFF%d|r", totalListings)) end
                if raffleLabel then raffleLabel:SetText("|c888888Dues status disabled in Free Trader mode|r") end
                if duesAmtLabel then duesAmtLabel:SetText(string.format("|c00FFFFListings Goal:|r  |cFFFFFF%d|r", listingTarget)) end
            else
                if paidLabel then paidLabel:SetText(string.format("|c00FF00Paid:|r  |cFFFFFF%d|r  |cFFFF00Pre:|r  |cFFFFFF%d|r", paidCount, prepaidCount)) end
                if unpaidLabel then unpaidLabel:SetText(string.format("|cFF4444Unpaid:|r  |cFFFFFF%d|r", unpaidCount)) end
                if lifeLabel then lifeLabel:SetText(string.format("|c00FFFFLifetime:|r  |cFFFFFF%d|r  |c888888Exempt:|r  |cFFFFFF%d|r", lifetimeCount, exemptCount)) end
                if duesLabel then duesLabel:SetText(string.format("|c00FFFFDues Total:|r  |c00FF00%sg|r", NWT.FormatGold(totalDuesCollected))) end
                if raffleLabel then raffleLabel:SetText(string.format("|c00FFFFRaffle Total:|r  |c00FF00%sg|r", NWT.FormatGold(totalRaffleCollected))) end
                if duesAmtLabel then duesAmtLabel:SetText(string.format("|c00FFFFDues Amount:|r  |cFFFFFF%sg|r", NWT.FormatGold(guildSettings.duesAmount or 5000))) end
            end
            if scanLabel then
                local lastScan = freeTraderMode and (guildSettings.listingsLastScanTime or 0) or (guildSettings.lastScanTime or 0)
                local scanText = lastScan > 0 and NWT.FormatTimeAgo(lastScan) or "Not scanned"
                if freeTraderMode and guildSettings.listingsScanInProgress then
                    scanText = "Scanning..."
                end
                local scanPrefix = freeTraderMode and "Listings scan: " or "Last scan: "
                scanLabel:SetText("|c888888" .. scanPrefix .. scanText .. "|r")
            end
        end
    end
    
    -- Members Column
    local membersCol = ui:GetNamedChild("MembersCol")
    if membersCol then
        local mBG = membersCol:GetNamedChild("BG")
        local mFocus = membersCol:GetNamedChild("FocusGlow")
        local mPlate = membersCol:GetNamedChild("HeaderPlate")
        if isDuesFocus then
            if mBG then mBG:SetEdgeColor(0, 0.8, 0.8, 1) end
            if mFocus then mFocus:SetHidden(false) end
            if mPlate then mPlate:SetEdgeColor(0, 0.8, 0.8, 1) end
        else
            if mBG then mBG:SetEdgeColor(0.3, 0.3, 0.3, 1) end
            if mFocus then mFocus:SetHidden(true) end
            if mPlate then mPlate:SetEdgeColor(0.3, 0.3, 0.3, 1) end
        end
        
        local mHeader = membersCol:GetNamedChild("Header")
        if mHeader then
            local searchInfo = ""
            if bk.searchText and bk.searchText ~= "" then
                searchInfo = "  •  Search: |cFFD700" .. bk.searchText .. "|r"
            end
            mHeader:SetText(string.format("|c00FFFF%d MEMBERS|r  •  |cFFFFFF%s|r%s", #bk.sortedMembers, GetCurrentFilterLabel(), searchInfo))
        end

        local colStatus = membersCol:GetNamedChild("ColStatus")
        if colStatus then
            if freeTraderMode then
                colStatus:SetText("|c888888Listings|r")
            else
                colStatus:SetText("|c888888Due In|r")
            end
        end
        
        local list = membersCol:GetNamedChild("List")
        local selectionFrame = list and list:GetNamedChild("SelectionFrame")
        
        for i = 1, 13 do
            local row = list and list:GetNamedChild("Row" .. i)
            if row then
                local mIdx = i + bk.memberScrollOffset
                local member = bk.sortedMembers[mIdx]
                
                if member then
                    local displayName = member.name:gsub("^@", "")
                    if #displayName > 18 then displayName = displayName:sub(1,16) .. ".." end
                    
                    local isLife = guildSettings.lifetimeMembers and guildSettings.lifetimeMembers[member.name]
                    local isExempt = member.isExemptRank
                    local rank
                    if bk.demoMode then
                        rank = (member.rankIndex and DEMO_RANKS[member.rankIndex] and DEMO_RANKS[member.rankIndex].name) or ("R" .. (member.rankIndex or "?"))
                    else
                        rank = (member.rankIndex and GetGuildRankCustomName(guildId, member.rankIndex)) or ("R" .. (member.rankIndex or "?"))
                    end
                    if #rank > 12 then rank = rank:sub(1,10) .. ".." end
                    
                    -- Status color and text
                    local statusText, statusColor
                    if freeTraderMode then
                        local listingsCount = tonumber(member.listingsCount) or 0
                        statusText = string.format("%d/%d", listingsCount, listingTarget)
                        if listingsCount >= listingTarget then
                            statusColor = "|c00FF00"
                        elseif listingsCount > 0 then
                            statusColor = "|cFFFF00"
                        else
                            statusColor = "|cFF4444"
                        end
                    else
                        if isLife then statusText, statusColor = "LIFE", "|c00FFFF"
                        elseif isExempt then statusText, statusColor = "EXMT", "|cFF00FF"
                        elseif (member.thisWeekDues or 0) > 0 then statusText, statusColor = "PAID", "|c00FF00"
                        elseif (member.duesMonths or 0) > 0 then 
                            local periodSuffix = "w"  -- Default to weeks
                            if guildSettings.duesPeriod == "monthly" then periodSuffix = "m"
                            elseif guildSettings.duesPeriod == "biweekly" then periodSuffix = "bw" end
                            statusText, statusColor = (member.duesMonths or 0) .. periodSuffix, "|cFFFF00"
                        elseif member.isPaidViaNote then 
                            -- Show days until due instead of just "NOTE"
                            local days = member.daysUntilDue or 0
                            if days == 0 then
                                statusText = "DUE"
                            elseif days >= 7 then
                                statusText = math.floor(days / 7) .. "w"
                            else
                                statusText = days .. "d"
                            end
                            statusColor = "|c00FF00"
                        elseif member.daysOverdue and member.daysOverdue > 0 then
                            -- Show how long overdue based on note (add "ago" for clarity)
                            if member.daysOverdue >= 7 then
                                statusText = math.floor(member.daysOverdue / 7) .. "w ago"
                            else
                                statusText = member.daysOverdue .. "d ago"
                            end
                            statusColor = "|cFF6600"  -- Orange for overdue
                        else statusText, statusColor = "OWED", "|cFF4444"
                        end
                    end
                    
                    local isSel = (mIdx == bk.selectedMemberIndex)
                    local nameColor = isSel and "|c00FFFF" or "|cFFFFFF"
                    local timeAgo = (member.lastPayment or 0) > 0 and NWT.FormatTimeAgo(member.lastPayment) or "Never"
                    
                    row:GetNamedChild("Num"):SetText("|c888888" .. mIdx .. "|r")
                    row:GetNamedChild("Name"):SetText(nameColor .. displayName .. "|r")
                    row:GetNamedChild("Status"):SetText(statusColor .. statusText .. "|r")
                    row:GetNamedChild("Rank"):SetText("|c888888" .. rank .. "|r")
                    row:GetNamedChild("LastPay"):SetText("|c888888" .. timeAgo .. "|r")
                    
                    -- Calculate total guild income contribution (deposits + taxes from sales)
                    local deposits = member.totalDeposited or 0
                    local taxes = guildSettings.memberTaxTotals and guildSettings.memberTaxTotals[member.name] or 0
                    local totalIncome = deposits + taxes
                    local incomeLabel = row:GetNamedChild("Income")
                    if incomeLabel then
                        if totalIncome > 0 then
                            incomeLabel:SetText("|c00FF00" .. NWT.FormatGold(totalIncome) .. "|r")
                        else
                            incomeLabel:SetText("|c555555-|r")
                        end
                    end
                    
                    -- Last Online column
                    local lastOnlineLabel = row:GetNamedChild("LastOnline")
                    if lastOnlineLabel then
                        local lastOnline = member.lastOnline or 0
                        if lastOnline > 0 then
                            local onlineAgo = NWT.FormatTimeAgo(lastOnline)
                            -- Color based on how long ago
                            local daysSinceOnline = (GetTimeStamp() - lastOnline) / 86400
                            local onlineColor = "|c00FF00"  -- Green for recent
                            if daysSinceOnline > 30 then onlineColor = "|cFF4444"  -- Red for 30+ days
                            elseif daysSinceOnline > 14 then onlineColor = "|cFF6600"  -- Orange for 14+ days
                            elseif daysSinceOnline > 7 then onlineColor = "|cFFFF00"  -- Yellow for 7+ days
                            end
                            lastOnlineLabel:SetText(onlineColor .. onlineAgo .. "|r")
                        else
                            lastOnlineLabel:SetText("|c555555-|r")
                        end
                    end
                    
                    if isSel and selectionFrame then
                        selectionFrame:ClearAnchors()
                        selectionFrame:SetAnchor(TOPLEFT, row, TOPLEFT, -5, -2)
                        selectionFrame:SetHidden(not isDuesFocus)
                    end
                    
                    row:SetHidden(false)
                else
                    row:SetHidden(true)
                end
            end
        end
        
        if not isDuesFocus and selectionFrame then
            selectionFrame:SetHidden(true)
        end
        
        -- Summary
        local summary = membersCol:GetNamedChild("Summary")
        if summary then
            if freeTraderMode then
                local noListings, listedCount, metTarget = 0, 0, 0
                for _, m in ipairs(bk.sortedMembers) do
                    local listingsCount = tonumber(m.listingsCount) or 0
                    if listingsCount <= 0 then
                        noListings = noListings + 1
                    else
                        listedCount = listedCount + 1
                        if listingsCount >= listingTarget then
                            metTarget = metTarget + 1
                        end
                    end
                end
                summary:SetText(string.format("|c00FF00%d Target|r   |cFFFF00%d Listed|r   |cFF4444%d None|r", metTarget, listedCount, noListings))
            else
                local paidCount, unpaidCount, prepaidCount = 0, 0, 0
                for _, m in ipairs(bk.sortedMembers) do
                    local isLife = guildSettings.lifetimeMembers and guildSettings.lifetimeMembers[m.name]
                    local isExempt = m.isExemptRank
                    if not isLife and not isExempt then
                        if m.thisWeekDues > 0 then paidCount = paidCount + 1
                        elseif m.duesMonths > 0 then prepaidCount = prepaidCount + 1
                        elseif m.isPaidViaNote then paidCount = paidCount + 1  -- Note-based paid
                        else unpaidCount = unpaidCount + 1 end
                    end
                end
                summary:SetText(string.format("|c00FF00%d Paid|r   |cFFFF00%d Pre|r   |cFF4444%d Owe|r", paidCount, prepaidCount, unpaidCount))
            end
        end
    end
    
    -- Right Column: Filter and Selected Member
    local rightCol = ui:GetNamedChild("RightCol")
    if rightCol then
        -- Filter Card
        local filterCard = rightCol:GetNamedChild("FilterCard")
        if filterCard then
            local currentFilter = filterCard:GetNamedChild("CurrentFilter")
            if currentFilter then
                local filterText = GetCurrentFilterLabel()
                local filterColor = bk.filterMode == 1 and "|cFFFFFF" or (bk.filterMode == 2 and "|cFF6666" or "|c00FF00")
                currentFilter:SetText(filterColor .. filterText .. "|r")
            end
        end
        
        -- Selected Member Card (expanded - no more Actions Card)
        local selCard = rightCol:GetNamedChild("SelectedCard")
        if selCard then
            local member = bk.sortedMembers[bk.selectedMemberIndex]
            if member then
                local displayName = member.name:gsub("^@", "")
                if #displayName > 18 then displayName = displayName:sub(1,16) .. ".." end
                
                -- Get sales data for this member
                local salesData = guildSettings.memberSalesData and guildSettings.memberSalesData[member.name]
                local totalSales = salesData and salesData.totalSales or 0
                local saleCount = salesData and salesData.saleCount or 0
                local taxes = guildSettings.memberTaxTotals and guildSettings.memberTaxTotals[member.name] or 0
                local avgSale = saleCount > 0 and math.floor(totalSales / saleCount) or 0
                
                -- Status calculation
                local isLife = guildSettings.lifetimeMembers and guildSettings.lifetimeMembers[member.name]
                local isExempt = member.isExemptRank
                local statusText
                if freeTraderMode then
                    local listingsCount = tonumber(member.listingsCount) or 0
                    if listingsCount >= listingTarget then
                        statusText = string.format("|c00FF00LISTINGS: %d/%d|r", listingsCount, listingTarget)
                    elseif listingsCount > 0 then
                        statusText = string.format("|cFFFF00LISTINGS: %d/%d|r", listingsCount, listingTarget)
                    else
                        statusText = string.format("|cFF4444LISTINGS: %d/%d|r", listingsCount, listingTarget)
                    end
                else
                    if isLife then statusText = "|c00FFFFLIFETIME|r"
                    elseif isExempt then statusText = "|cFF00FFEXEMPT|r"
                    elseif (member.thisWeekDues or 0) > 0 then statusText = "|c00FF00PAID|r"
                    elseif (member.duesMonths or 0) > 0 then statusText = "|cFFFF00PRE-PAID|r"
                    elseif member.isPaidViaNote then
                        local days = member.daysUntilDue or 0
                        if days == 0 then statusText = "|c00FF00DUE TODAY|r"
                        elseif days >= 7 then statusText = "|c00FF00" .. math.floor(days / 7) .. "w until due|r"
                        else statusText = "|c00FF00" .. days .. "d until due|r" end
                    else statusText = "|cFF4444UNPAID|r" end
                end
                
                -- Header section
                local nameLabel = selCard:GetNamedChild("Name")
                local statusLabel = selCard:GetNamedChild("Status")
                if nameLabel then nameLabel:SetText("|c00FFFF" .. displayName .. "|r") end
                if statusLabel then statusLabel:SetText(statusText) end
                
                -- Deposits section
                local totalDepLabel = selCard:GetNamedChild("TotalDeposited")
                local duesLabel = selCard:GetNamedChild("DuesPaid")
                local raffleLabel = selCard:GetNamedChild("RafflePaid")
                local otherLabel = selCard:GetNamedChild("OtherDeposits")
                
                local duesTotal = (member.duesTotal or 0)
                if totalDepLabel then totalDepLabel:SetText(string.format("|c888888Total:|r |c00FF00%s|r", NWT.FormatGold(member.totalDeposited or 0))) end
                if duesLabel then
                    if freeTraderMode then
                        duesLabel:SetText(string.format("|c888888Listings:|r |cFFFFFF%d/%d|r", tonumber(member.listingsCount) or 0, listingTarget))
                    else
                        duesLabel:SetText(string.format("|c888888Dues:|r |c00FF00%s|r (%dm)", NWT.FormatGold(duesTotal), member.duesMonths or 0))
                    end
                end
                if raffleLabel then raffleLabel:SetText(string.format("|c888888Raffle:|r |cFFFF00%s|r", NWT.FormatGold(member.raffleTotal or 0))) end
                if otherLabel then otherLabel:SetText(string.format("|c888888Other:|r |c888888%s|r", NWT.FormatGold(member.otherTotal or 0))) end
                
                -- Trading section
                local totalSalesLabel = selCard:GetNamedChild("TotalSales")
                local saleCountLabel = selCard:GetNamedChild("SaleCount")
                local taxesLabel = selCard:GetNamedChild("TaxesPaid")
                local avgSaleLabel = selCard:GetNamedChild("AvgSale")
                
                if totalSalesLabel then totalSalesLabel:SetText(string.format("|c888888Sales:|r |c00FF00%s|r", NWT.FormatGold(totalSales))) end
                if saleCountLabel then saleCountLabel:SetText(string.format("|c888888# Sales:|r |cFFFFFF%d|r", saleCount)) end
                if taxesLabel then taxesLabel:SetText(string.format("|c888888Taxes:|r |cFF6600%s|r", NWT.FormatGold(taxes))) end
                if avgSaleLabel then avgSaleLabel:SetText(string.format("|c888888Avg Sale:|r |cFFFFFF%s|r", NWT.FormatGold(avgSale))) end
                
                -- Activity section
                local totalIncomeLabel = selCard:GetNamedChild("TotalIncome")
                local lastPayLabel = selCard:GetNamedChild("LastPayment")
                local lastOnlineLabel = selCard:GetNamedChild("LastOnline")
                local depositCountLabel = selCard:GetNamedChild("DepositCount")
                
                local totalIncome = (member.totalDeposited or 0) + taxes
                local lastPayStr = (member.lastPayment or 0) > 0 and NWT.FormatTimeAgo(member.lastPayment) or "Never"
                local lastOnlineStr = member.lastOnline and member.lastOnline > 0 and NWT.FormatTimeAgo(member.lastOnline) or "Unknown"
                local depositCount = member.deposits and #member.deposits or 0
                
                if totalIncomeLabel then totalIncomeLabel:SetText(string.format("|c888888Income:|r |c00FF00%s|r", NWT.FormatGold(totalIncome))) end
                if lastPayLabel then lastPayLabel:SetText(string.format("|c888888Last Pay:|r |c888888%s|r", lastPayStr)) end
                if lastOnlineLabel then lastOnlineLabel:SetText(string.format("|c888888Online:|r |c888888%s|r", lastOnlineStr)) end
                if depositCountLabel then depositCountLabel:SetText(string.format("|c888888Deposits:|r |cFFFFFF%d|r", depositCount)) end
            else
                local nameLabel = selCard:GetNamedChild("Name")
                local statusLabel = selCard:GetNamedChild("Status")
                if nameLabel then nameLabel:SetText("|c888888No member selected|r") end
                if statusLabel then statusLabel:SetText("") end
            end
        end
    end
end

function NWT.BookkeeperSwitchPanel(dir)
    local bk = NWT.Bookkeeper
    if bk.rankMenuOpen or bk.settingsMenuOpen then return end
    
    -- Only two panels now: guilds and dues (actions panel removed)
    if dir == "right" then
        if bk.focusPanel == "guilds" then bk.focusPanel = "dues" end
    else
        if bk.focusPanel == "dues" then bk.focusPanel = "guilds" end
    end
    
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    NWT.UpdateBookkeeperUI()
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then 
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) 
    end
end

function NWT.BookkeeperScrollAction(dir)
    local bk = NWT.Bookkeeper
    local count = #QUICK_ACTIONS
    if count == 0 then return end
    
    if dir == "up" then
        bk.selectedActionIndex = math.max(1, bk.selectedActionIndex - 1)
    else
        bk.selectedActionIndex = math.min(count, bk.selectedActionIndex + 1)
    end
    
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    NWT.UpdateBookkeeperUI()
end

function NWT.BookkeeperExecuteAction()
    local bk = NWT.Bookkeeper
    local action = QUICK_ACTIONS[bk.selectedActionIndex]
    if action and action.callback then
        PlaySound(SOUNDS.POSITIVE_CLICK)
        action.callback()
    end
end

function NWT.BookkeeperScrollGuild(dir)
    local bk = NWT.Bookkeeper
    local nG = bk.demoMode and #DEMO_GUILDS or GetNumGuilds()
    if nG == 0 then return end
    
    if dir == "up" then
        bk.selectedGuildIndex = math.max(1, bk.selectedGuildIndex - 1)
    else
        bk.selectedGuildIndex = math.min(nG, bk.selectedGuildIndex + 1)
    end
    
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    NWT.UpdateBookkeeperUI()
end

function NWT.BookkeeperScrollMember(dir)
    local bk = NWT.Bookkeeper
    local count = #bk.sortedMembers or 0
    if count == 0 then return end
    
    if dir == "up" then
        bk.selectedMemberIndex = math.max(1, bk.selectedMemberIndex - 1)
    else
        bk.selectedMemberIndex = math.min(count, bk.selectedMemberIndex + 1)
    end
    
    -- Adjust scroll offset to keep selection visible
    if bk.selectedMemberIndex <= bk.memberScrollOffset then
        bk.memberScrollOffset = bk.selectedMemberIndex - 1
    elseif bk.selectedMemberIndex > bk.memberScrollOffset + 12 then
        bk.memberScrollOffset = bk.selectedMemberIndex - 12
    end
    bk.memberScrollOffset = math.max(0, bk.memberScrollOffset)
    
    NWT.UpdateBookkeeperUI()
end

function NWT.BookkeeperPageMember(dir)
    local bk = NWT.Bookkeeper
    local count = #bk.sortedMembers or 0
    if count == 0 then return end
    
    local pageSize = 10  -- Jump by 10 members
    if dir == "up" then
        bk.selectedMemberIndex = math.max(1, bk.selectedMemberIndex - pageSize)
    else
        bk.selectedMemberIndex = math.min(count, bk.selectedMemberIndex + pageSize)
    end
    
    -- Adjust scroll offset to keep selection visible
    if bk.selectedMemberIndex <= bk.memberScrollOffset then
        bk.memberScrollOffset = bk.selectedMemberIndex - 1
    elseif bk.selectedMemberIndex > bk.memberScrollOffset + 12 then
        bk.memberScrollOffset = bk.selectedMemberIndex - 12
    end
    bk.memberScrollOffset = math.max(0, bk.memberScrollOffset)
    
    NWT.UpdateBookkeeperUI()
end

function NWT.BookkeeperScrollSales(dir)
    local bk = NWT.Bookkeeper
    local count = bk.salesEntriesCount or 0
    
    if dir == "up" and bk.salesScrollOffset > 0 then
        bk.salesScrollOffset = bk.salesScrollOffset - 1
        PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    elseif dir == "down" and bk.salesScrollOffset < math.max(0, count - bk.maxVisibleSales) then
        bk.salesScrollOffset = bk.salesScrollOffset + 1
        PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    end
    NWT.UpdateBookkeeperUI()
end

function NWT.BookkeeperScrollRaffle(dir)
    local bk = NWT.Bookkeeper
    local count = bk.raffleEntriesCount or 0
    
    if dir == "up" and bk.raffleScrollOffset > 0 then
        bk.raffleScrollOffset = bk.raffleScrollOffset - 1
        PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    elseif dir == "down" and bk.raffleScrollOffset < math.max(0, count - bk.maxVisibleRaffle) then
        bk.raffleScrollOffset = bk.raffleScrollOffset + 1
        PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    end
    NWT.UpdateBookkeeperUI()
end

local ATK_HiddenBookkeeperListScreen = ZO_Gamepad_ParametricList_Screen:Subclass()
function ATK_HiddenBookkeeperListScreen:New(control) return ZO_Gamepad_ParametricList_Screen.New(self, control) end
function ATK_HiddenBookkeeperListScreen:Initialize(control) ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, NWT.BookkeeperScene) end
function ATK_HiddenBookkeeperListScreen:PerformUpdate() end
local function GetSelectedGuildId()
    local bk = NWT.Bookkeeper
    if bk.sortedGuildList and bk.sortedGuildList[bk.selectedGuildIndex] then
        return bk.sortedGuildList[bk.selectedGuildIndex].guildId
    end
    return GetGuildId(bk.selectedGuildIndex)
end

function NWT.BookkeeperToggleSelectedGuild()
    local guildId = GetSelectedGuildId()
    if not guildId or guildId == 0 then return end
    ToggleGuildEnabled(guildId)
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateBookkeeperUI()
end

function NWT.BookkeeperFavoriteSelectedGuild()
    local guildId = GetSelectedGuildId()
    if not guildId or guildId == 0 then return end
    ToggleGuildFavorite(guildId)
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateBookkeeperUI()
end

function NWT.BookkeeperSelectGuild()
    local bk = NWT.Bookkeeper
    
    -- In demo mode, just use the selected index directly
    if bk.demoMode then
        bk.viewingGuildIndex = bk.selectedGuildIndex
    else
        local guildId = GetSelectedGuildId()
        if not guildId or guildId == 0 then return end
        -- Find the actual guild index for viewingGuildIndex
        local actualIndex = bk.selectedGuildIndex
        if bk.sortedGuildList and bk.sortedGuildList[bk.selectedGuildIndex] then
            actualIndex = bk.sortedGuildList[bk.selectedGuildIndex].index
        end
        bk.viewingGuildIndex = actualIndex
    end
    
    -- Save the last selected guild
    if NWT.savedVars and NWT.savedVars.bookkeeper then
        NWT.savedVars.bookkeeper.lastGuildIndex = bk.selectedGuildIndex
    end
    -- Switch to Dues panel to view the selected guild
    bk.focusPanel = "dues"
    bk.selectedMemberIndex = 1
    bk.memberScrollOffset = 0
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    NWT.UpdateBookkeeperUI()
    NWT.SyncHiddenBookkeeperList()
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then 
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) 
    end
end

function ATK_HiddenBookkeeperListScreen:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = function() 
              if NWT.Bookkeeper.raffleWinner then return "Reroll" end 
              if NWT.Bookkeeper.memberDetailsOpen then return "Close" end
              if NWT.Bookkeeper.duesSettingsOpen then return "Change Value" end
              if NWT.Bookkeeper.settingsMenuOpen then return "Change Value" end
              if NWT.Bookkeeper.rankMenuOpen then return "Confirm Rank" end
              if NWT.Bookkeeper.focusPanel == "guilds" then return "Select Guild" end
              if NWT.Bookkeeper.focusPanel == "actions" then return "Execute" end
              return "View Details"
          end, 
          keybind = "UI_SHORTCUT_PRIMARY", 
          callback = function() 
              if NWT.Bookkeeper.raffleWinner then NWT.BookkeeperRerollRaffle() return end
              if NWT.Bookkeeper.memberDetailsOpen then NWT.CloseMemberDetails() return end
              if NWT.Bookkeeper.duesSettingsOpen then NWT.DuesSettingsChangeValue() return end
              if NWT.Bookkeeper.settingsMenuOpen then NWT.BookkeeperChangeSettingValue() return end
              if NWT.Bookkeeper.rankMenuOpen then NWT.BookkeeperConfirmRank() return end
              if NWT.Bookkeeper.focusPanel == "guilds" then NWT.BookkeeperSelectGuild() return end
              if NWT.Bookkeeper.focusPanel == "actions" then NWT.BookkeeperExecuteAction() return end
              if NWT.Bookkeeper.focusPanel == "dues" then NWT.ShowMemberDetails() return end
          end 
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = function() 
              if NWT.Bookkeeper.duesSettingsOpen and NWT.DUES_SETTINGS_TABS and NWT.Bookkeeper.duesSettingsTabIndex then 
                  local currentTab = NWT.DUES_SETTINGS_TABS[NWT.Bookkeeper.duesSettingsTabIndex]
                  if currentTab and currentTab.id == "ranks" then
                      return "Period"
                  end
              end
              if NWT.Bookkeeper.focusPanel == "guilds" then return "Favorite" 
              elseif NWT.Bookkeeper.datePickerOpen then return "Switch Field" 
              else return "Filter: " .. (NWT.Bookkeeper.filterModes[NWT.Bookkeeper.filterMode] or "All") end 
          end, 
          keybind = "UI_SHORTCUT_SECONDARY", 
          callback = function() 
              if NWT.Bookkeeper.duesSettingsOpen then 
                  -- X button in dues settings - cycle period on RANKS tab
                  NWT.DuesSettingsCyclePeriod()
                  return 
              end
              if NWT.Bookkeeper.focusPanel == "guilds" then NWT.BookkeeperFavoriteSelectedGuild() 
              elseif NWT.Bookkeeper.datePickerOpen then NWT.BookkeeperCycleDatePickerField() 
              else NWT.BookkeeperCycleFilter() end 
              NWT.UpdateBookkeeperUI() 
              if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) end 
          end, 
          enabled = function() return not NWT.Bookkeeper.rankMenuOpen and not NWT.Bookkeeper.settingsMenuOpen end 
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = function() 
              if NWT.Bookkeeper.duesSettingsOpen and NWT.DUES_SETTINGS_TABS and NWT.Bookkeeper.duesSettingsTabIndex then 
                  local currentTab = NWT.DUES_SETTINGS_TABS[NWT.Bookkeeper.duesSettingsTabIndex]
                  if currentTab and currentTab.id == "ranks" then
                      return "Amount"
                  end
              end
              if NWT.Bookkeeper.focusPanel == "guilds" then return "Settings" 
              elseif NWT.Bookkeeper.searchText and NWT.Bookkeeper.searchText ~= "" then return "Clear: " .. NWT.Bookkeeper.searchText
              else return "Search" end 
          end, 
          keybind = "UI_SHORTCUT_TERTIARY", 
          callback = function() 
              if NWT.Bookkeeper.duesSettingsOpen then 
                  -- Y button in dues settings - decrease amount on right column
                  NWT.DuesSettingsDecreaseAmount()
                  return 
              end
              if NWT.Bookkeeper.focusPanel == "guilds" then NWT.BookkeeperShowDuesSettings()
              elseif NWT.Bookkeeper.searchText and NWT.Bookkeeper.searchText ~= "" then NWT.BookkeeperClearSearch()
              else NWT.BookkeeperPromptSearch() end 
          end, 
          enabled = function() return not NWT.Bookkeeper.rankMenuOpen and not NWT.Bookkeeper.settingsMenuOpen end 
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = function()
              if NWT.Bookkeeper.duesSettingsOpen then return "◄ Tab" end
              return "Navigate Left"
          end, 
          keybind = "UI_SHORTCUT_LEFT_SHOULDER", 
          callback = function() 
              if NWT.Bookkeeper.duesSettingsOpen then 
                  -- On RANKS tab: left column -> prev tab, right column -> left column
                  local currentTab = NWT.DUES_SETTINGS_TABS and NWT.DUES_SETTINGS_TABS[NWT.Bookkeeper.duesSettingsTabIndex]
                  if currentTab and currentTab.id == "ranks" then
                      local col = NWT.Bookkeeper.ranksColumn or "left"
                      if col == "right" then
                          NWT.Bookkeeper.ranksColumn = "left"
                          NWT.UpdateDuesSettingsDialog()
                          PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
                      else
                          NWT.DuesSettingsChangeTab("left")
                      end
                  else
                      NWT.DuesSettingsChangeTab("left")
                  end
                  return 
              end
              NWT.BookkeeperSwitchPanel("left") 
          end, 
          enabled = function() return not NWT.Bookkeeper.rankMenuOpen and not NWT.Bookkeeper.settingsMenuOpen end 
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = function()
              if NWT.Bookkeeper.duesSettingsOpen then return "Tab ►" end
              return "Navigate Right"
          end, 
          keybind = "UI_SHORTCUT_RIGHT_SHOULDER", 
          callback = function() 
              if NWT.Bookkeeper.duesSettingsOpen then 
                  -- On RANKS tab: left column -> right column, right column -> next tab
                  local currentTab = NWT.DUES_SETTINGS_TABS and NWT.DUES_SETTINGS_TABS[NWT.Bookkeeper.duesSettingsTabIndex]
                  if currentTab and currentTab.id == "ranks" then
                      local col = NWT.Bookkeeper.ranksColumn or "left"
                      if col == "left" then
                          NWT.Bookkeeper.ranksColumn = "right"
                          NWT.UpdateDuesSettingsDialog()
                          PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
                      else
                          NWT.DuesSettingsChangeTab("right")
                      end
                  else
                      NWT.DuesSettingsChangeTab("right")
                  end
                  return 
              end
              NWT.BookkeeperSwitchPanel("right") 
          end, 
          enabled = function() return not NWT.Bookkeeper.rankMenuOpen and not NWT.Bookkeeper.settingsMenuOpen end 
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = "Page Up", 
          keybind = "UI_SHORTCUT_LEFT_TRIGGER", 
          ethereal = true,  -- Hide from keybind strip but keep functionality
          callback = function() 
              if NWT.Bookkeeper.focusPanel == "dues" then NWT.BookkeeperPageMember("up") end 
          end, 
          enabled = function() return NWT.Bookkeeper.focusPanel == "dues" and not NWT.Bookkeeper.rankMenuOpen and not NWT.Bookkeeper.settingsMenuOpen and not NWT.Bookkeeper.duesSettingsOpen end 
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = "Page Down", 
          keybind = "UI_SHORTCUT_RIGHT_TRIGGER", 
          ethereal = true,  -- Hide from keybind strip but keep functionality
          callback = function() 
              if NWT.Bookkeeper.focusPanel == "dues" then NWT.BookkeeperPageMember("down") end 
          end, 
          enabled = function() return NWT.Bookkeeper.focusPanel == "dues" and not NWT.Bookkeeper.rankMenuOpen and not NWT.Bookkeeper.settingsMenuOpen and not NWT.Bookkeeper.duesSettingsOpen end 
        },
        { alignment = KEYBIND_STRIP_ALIGN_RIGHT, 
          name = function() if NWT.Bookkeeper.focusPanel == "dues" then return "Update Note" else return "Scan: " .. GetGuildName(GetGuildId(NWT.Bookkeeper.viewingGuildIndex)) end end, 
          keybind = "UI_SHORTCUT_RIGHT_STICK", 
          callback = function() if NWT.Bookkeeper.focusPanel == "dues" then NWT.BookkeeperUpdateMemberNote() else NWT.ScanGuildForBookkeeper(GetGuildId(NWT.Bookkeeper.viewingGuildIndex)) end end, 
          enabled = function() return not NWT.Bookkeeper.rankMenuOpen and not NWT.Bookkeeper.settingsMenuOpen and not NWT.Bookkeeper.duesSettingsOpen end 
        },
        { alignment = KEYBIND_STRIP_ALIGN_RIGHT, 
          name = function()
              if NWT.Bookkeeper.duesSettingsOpen then return "Close Settings" end
              return "Set Rank"
          end, 
          keybind = "UI_SHORTCUT_QUATERNARY", 
          callback = function() 
              if NWT.Bookkeeper.duesSettingsOpen then 
                  NWT.CloseDuesSettingsDialog()
                  return
              end
              NWT.BookkeeperShowRankMenu() 
          end, 
          enabled = function() return not NWT.Bookkeeper.rankMenuOpen and not NWT.Bookkeeper.settingsMenuOpen end 
        },
        { alignment = KEYBIND_STRIP_ALIGN_RIGHT, 
          name = function() return "|cFF4444Kick|r" end,
          keybind = "UI_SHORTCUT_LEFT_STICK", 
          callback = function()
              if NWT.Bookkeeper.focusPanel == "dues" then
                  NWT.BookkeeperKickMember()
              end
          end, 
          enabled = function()
              return NWT.Bookkeeper.focusPanel == "dues"
                 and not NWT.Bookkeeper.rankMenuOpen
                 and not NWT.Bookkeeper.settingsMenuOpen
                 and not NWT.Bookkeeper.duesSettingsOpen
          end 
        },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, function() 
        if NWT.Bookkeeper.memberDetailsOpen then NWT.CloseMemberDetails() return end
        if NWT.Bookkeeper.duesSettingsOpen then NWT.CloseDuesSettingsDialog() return end
        if NWT.Bookkeeper.raffleWinner then NWT.CloseRaffleWinnerDialog() KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor) return end
        if NWT.Bookkeeper.settingsMenuOpen then NWT.CloseSettingsDialog() return end
        if NWT.Bookkeeper.rankMenuOpen then NWT.CloseRankDialog() KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor) return end
        NWT.CloseBookkeeper() 
    end)
end

function NWT.SyncHiddenBookkeeperList()
    if not NWT.HiddenBookkeeperList then return end
    NWT.HiddenBookkeeperList:Clear()
    for i, m in ipairs(NWT.Bookkeeper.sortedMembers) do
        local ed = ZO_GamepadEntryData:New(m.name)
        ed.index, ed.member = i, m
        NWT.HiddenBookkeeperList:AddEntry("ZO_GamepadItemEntryTemplate", ed)
    end
    NWT.HiddenBookkeeperList:Commit()
    if #NWT.Bookkeeper.sortedMembers > 0 then NWT.HiddenBookkeeperList:SetSelectedIndexWithoutAnimation(NWT.Bookkeeper.selectedMemberIndex) end
end

function NWT.InitBookkeeperScene()
    if NWT.Bookkeeper.sceneInitialized then return end
    local ui = ATK_Bookkeeper_UI
    if not ui then 
NWT.Debug("|cFF0000[Bookkeeper]|r ATK_Bookkeeper_UI not found for scene init!")
        return 
    end
    local hc = WINDOW_MANAGER:CreateControlFromVirtual("ATK_HiddenBookkeeperList", GuiRoot, "ATK_HouseList_Screen")
    hc:SetHidden(true) hc:SetAlpha(0)
    NWT.BookkeeperScene = ZO_Scene:New("bookkeeperScene", SCENE_MANAGER)
    NWT.BookkeeperScene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    NWT.BookkeeperScene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    NWT.BookkeeperScene:AddFragment(ZO_SimpleSceneFragment:New(ui))
    NWT.BookkeeperScene:AddFragment(ZO_SimpleSceneFragment:New(hc))
    NWT.HiddenBookkeeperListScreen = ATK_HiddenBookkeeperListScreen:New(hc)
    NWT.HiddenBookkeeperList = NWT.HiddenBookkeeperListScreen:GetMainList()
    NWT.HiddenBookkeeperList:AddDataTemplate("ZO_GamepadItemEntryTemplate", function(c, d) local l = c:GetNamedChild("Label") if l then l:SetText(d.name or "") end end, ZO_GamepadMenuEntryTemplateParametricListFunction)
    
    -- Override list movement to use direct scroll functions (like raffle does)
    NWT.HiddenBookkeeperList.MovePrevious = function(self, ...)
        if NWT.Bookkeeper.duesSettingsOpen then NWT.DuesSettingsCycleRow("up") return end
        if NWT.Bookkeeper.settingsMenuOpen then NWT.BookkeeperCycleSettingsOption("up") return end
        if NWT.Bookkeeper.rankMenuOpen then NWT.BookkeeperCycleRank("up") return end
        if NWT.Bookkeeper.focusPanel == "guilds" then NWT.BookkeeperScrollGuild("up")
        elseif NWT.Bookkeeper.focusPanel == "actions" then NWT.BookkeeperScrollAction("up")
        else NWT.BookkeeperScrollMember("up") end
    end
    NWT.HiddenBookkeeperList.MoveNext = function(self, ...)
        if NWT.Bookkeeper.duesSettingsOpen then NWT.DuesSettingsCycleRow("down") return end
        if NWT.Bookkeeper.settingsMenuOpen then NWT.BookkeeperCycleSettingsOption("down") return end
        if NWT.Bookkeeper.rankMenuOpen then NWT.BookkeeperCycleRank("down") return end
        if NWT.Bookkeeper.focusPanel == "guilds" then NWT.BookkeeperScrollGuild("down")
        elseif NWT.Bookkeeper.focusPanel == "actions" then NWT.BookkeeperScrollAction("down")
        else NWT.BookkeeperScrollMember("down") end
    end
    
    
    NWT.HiddenBookkeeperList:SetOnSelectedDataChangedCallback(function(list, sd)
        if NWT.Bookkeeper.settingsMenuOpen or NWT.Bookkeeper.rankMenuOpen then return end
        if sd and sd.index then
            NWT.Bookkeeper.selectedMemberIndex = sd.index
            if NWT.Bookkeeper.selectedMemberIndex <= NWT.Bookkeeper.memberScrollOffset then NWT.Bookkeeper.memberScrollOffset = NWT.Bookkeeper.selectedMemberIndex - 1
            elseif NWT.Bookkeeper.selectedMemberIndex > NWT.Bookkeeper.memberScrollOffset + 12 then NWT.Bookkeeper.memberScrollOffset = NWT.Bookkeeper.selectedMemberIndex - 12 end
            NWT.UpdateBookkeeperUI()
        end
    end)
    NWT.BookkeeperScene:RegisterCallback("StateChange", function(os, ns)
        if ns == SCENE_SHOWING then 
            NWT.Bookkeeper.isOpen = true 
            -- Reset to first position (favorites sort to top, so position 1 = first favorite or first guild)
            NWT.Bookkeeper.selectedGuildIndex = 1
            -- Build sorted list first to get actual viewing guild
            NWT.UpdateBookkeeperUI()
            -- Set viewing guild to the first sorted guild (which is the first favorite if any)
            local bk = NWT.Bookkeeper
            if bk.sortedGuildList and bk.sortedGuildList[1] then
                bk.viewingGuildIndex = bk.sortedGuildList[1].index
            else
                bk.viewingGuildIndex = 1
            end
            NWT.Bookkeeper.focusPanel = "dues"
            NWT.UpdateBookkeeperUI() 
            NWT.SyncHiddenBookkeeperList()
        elseif ns == SCENE_SHOWN then
            -- Re-sync and commit the list to ensure it can receive input
            NWT.SyncHiddenBookkeeperList()
            if NWT.HiddenBookkeeperList then
                NWT.HiddenBookkeeperList:Activate()
            end
            if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then 
                KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) 
            end
        elseif ns == SCENE_HIDING then
            -- Close all dialogs when scene is hiding (e.g., Start button pressed)
            if NWT.Bookkeeper.duesSettingsOpen then NWT.CloseDuesSettingsDialog() end
            if NWT.Bookkeeper.memberDetailsOpen then NWT.CloseMemberDetails() end
            if NWT.Bookkeeper.rankMenuOpen then NWT.CloseRankDialog() end
            if NWT.Bookkeeper.settingsMenuOpen then NWT.CloseSettingsDialog() end
        elseif ns == SCENE_HIDDEN then 
            NWT.Bookkeeper.isOpen = false 
            if NWT.HiddenBookkeeperList then NWT.HiddenBookkeeperList:Deactivate() end
        end
    end)
    NWT.Bookkeeper.sceneInitialized = true
end

function NWT.OpenBookkeeper()
    if NWT.Bookkeeper.isOpen then return end
    if not NWT.BookkeeperScene then NWT.InitBookkeeperScene() end
    SCENE_MANAGER:Push("bookkeeperScene")
end

function NWT.CloseBookkeeper() if NWT.BookkeeperScene then SCENE_MANAGER:Hide("bookkeeperScene") end end

-- ============================================
-- BOOKKEEPER DIALOGS & SETTINGS
-- ============================================

function NWT.BookkeeperShowRankMenu()
    local bk = NWT.Bookkeeper
    if bk.rankMenuOpen then return end
    local member = bk.sortedMembers[bk.selectedMemberIndex]
    if not member then return end
    local guildId = GetGuildId(bk.selectedGuildIndex)
    if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_PROMOTE) and not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_DEMOTE) then NWT.Debug("|cFF0000[Bookkeeper]|r No permission to change ranks") return end
    
    local numRanks = GetNumGuildRanks(guildId)
    local rankNames = {}
    for i = 1, numRanks do
        if not IsGuildRankGuildMaster(guildId, i) then table.insert(rankNames, {index = i, name = GetGuildRankCustomName(guildId, i) or ("Rank " .. i)}) end
    end
    bk.rankMenuOpen, bk.rankMenuMember, bk.rankOptions, bk.rankSelectedIndex = true, member.name, rankNames, 1
    if member.rankIndex then for i, r in ipairs(rankNames) do if r.index == member.rankIndex then bk.rankSelectedIndex = i break end end end
    NWT.UpdateRankDialog() ATK_RankDialog:SetHidden(false) PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.UpdateRankDialog()
    local bk = NWT.Bookkeeper
    local dialog = ATK_RankDialog
    if not dialog then return end
    local ml = dialog:GetNamedChild("MemberName") if ml then ml:SetText("|cFFFFFF" .. (bk.rankMenuMember or "") .. "|r") end
    for i = 1, 8 do
        local row = dialog:GetNamedChild("Rank" .. i)
        if row then
            local rank = bk.rankOptions and bk.rankOptions[i]
            if rank then row:SetText(i == bk.rankSelectedIndex and "|cFFFF00► " .. rank.name .. "|r" or "|cFFFFFF  " .. rank.name .. "|r") row:SetHidden(false)
            else row:SetText("") row:SetHidden(true) end
        end
    end
end

function NWT.BookkeeperConfirmRank()
    local bk = NWT.Bookkeeper
    if not bk.rankMenuOpen then return end
    local gId = GetGuildId(bk.selectedGuildIndex)
    local disp = bk.rankMenuMember
    if not disp:find("^@") then disp = "@" .. disp end
    local selRank = bk.rankOptions[bk.rankSelectedIndex]
    local member = bk.sortedMembers[bk.selectedMemberIndex]
    if selRank and member then
        local mIdx = GetGuildMemberIndexFromDisplayName(gId, disp)
        if not mIdx then NWT.CloseRankDialog() return end
        local _, _, curRank = GetGuildMemberInfo(gId, mIdx)
        local target = selRank.index
        if curRank == target then NWT.Debug("|cFFFF00[Bookkeeper]|r Already at that rank")
        elseif target > curRank then
            local steps = target - curRank
            for i = 1, steps do zo_callLater(function() GuildDemote(gId, disp) end, (i-1)*500) end
        else
            local steps = curRank - target
            for i = 1, steps do zo_callLater(function() GuildPromote(gId, disp) end, (i-1)*500) end
        end
        member.rankIndex = target PlaySound(SOUNDS.GUILD_ROSTER_DEMOTE)
    end
    NWT.CloseRankDialog() KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor)
end

function NWT.CloseRankDialog()
    local bk = NWT.Bookkeeper
    bk.rankMenuOpen, bk.rankMenuMember, bk.rankOptions = false, nil, nil
    if ATK_RankDialog then ATK_RankDialog:SetHidden(true) end
end

function NWT.BookkeeperCycleRank(dir)
    local bk = NWT.Bookkeeper
    if not bk.rankMenuOpen or not bk.rankOptions then return end
    local nO = #bk.rankOptions
    if nO == 0 then return end
    bk.rankSelectedIndex = (dir == "up") and (bk.rankSelectedIndex == 1 and nO or bk.rankSelectedIndex - 1) or (bk.rankSelectedIndex == nO and 1 or bk.rankSelectedIndex + 1)
    NWT.UpdateRankDialog() PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

local SETTINGS_OPTIONS = { {id = "trackGuild", label = "Track This Guild"}, {id = "dues", label = "Weekly Dues"}, {id = "raffle", label = "Raffle Ends In"}, {id = "ticketPrice", label = "Ticket Price"}, {id = "rafflePeriod", label = "Raffle Period"}, {id = "rafflePicker", label = "Pick Winners"}, {id = "exempt", label = "Exempt Ranks"}, {id = "scanNotes", label = "Scan Payment Notes"}, }
local DUES_OPTIONS = {5000, 10000, 15000, 20000, 25000, 30000, 35000, 40000}
local TICKET_OPTIONS = {500, 1000, 2000, 2500, 5000, 10000, 25000, 50000}
local RAFFLE_PRESETS = { {suffixes = {1}, label = "01"}, {suffixes = {2}, label = "02"}, {suffixes = {3}, label = "03"}, {suffixes = {4}, label = "04"}, {suffixes = {5}, label = "05"}, {suffixes = {6}, label = "06"}, {suffixes = {7}, label = "07"}, {suffixes = {8}, label = "08"}, {suffixes = {9}, label = "09"}, }

function NWT.BookkeeperShowSettings()
    local bk = NWT.Bookkeeper
    if bk.rankMenuOpen or bk.settingsMenuOpen then return end
    -- Use viewing guild (the one shown in Dues panel) for settings
    bk.settingsMenuOpen, bk.settingsSelectedIndex, bk.settingsGuildId = true, 1, GetGuildId(bk.viewingGuildIndex)
    NWT.UpdateSettingsDialog() ATK_BookkeeperSettingsDialog:SetHidden(false) PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) end
end

function NWT.UpdateSettingsDialog()
    local bk = NWT.Bookkeeper
    local dialog = ATK_BookkeeperSettingsDialog
    if not dialog then return end
    local gs = GetBookkeeperGuildSettings(bk.settingsGuildId)
    local gn = GetGuildName(bk.settingsGuildId)
    dialog:GetNamedChild("GuildName"):SetText("|cFFFFFF" .. gn .. "|r")
    
    -- Build exempt ranks display string
    local exemptNames = {}
    local numRanks = GetNumGuildRanks(bk.settingsGuildId)
    for i = 1, numRanks do
        if gs.exemptRanks and gs.exemptRanks[i] then
            local rankName = GetGuildRankCustomName(bk.settingsGuildId, i) or ("Rank " .. i)
            table.insert(exemptNames, rankName)
        end
    end
    local exemptStr = #exemptNames > 0 and table.concat(exemptNames, ", ") or "None"
    if #exemptStr > 25 then exemptStr = #exemptNames .. " ranks" end
    
    local isTracked = IsGuildEnabled(bk.settingsGuildId)
    local notesScanCount = gs.paymentHistory and gs.lastNotesScan and #(gs.paymentHistory or {}) or 0
    local notesScanStatus = gs.lastNotesScan and (notesScanCount .. " found") or "Not scanned"
    local vals = { 
        {id = "trackGuild", value = isTracked and "|c00FF00ON|r" or "|cFF4444OFF|r"},
        {id = "dues", value = NWT.FormatGold(gs.duesAmount or 5000) .. "g"}, 
        {id = "raffle", value = table.concat(gs.raffleSuffixes or {1, 5}, ", ")}, 
        {id = "ticketPrice", value = NWT.FormatGold(gs.ticketPrice or 1000) .. "g"},
        {id = "rafflePeriod", value = FormatRafflePeriod(gs)},
        {id = "rafflePicker", value = "→"},
        {id = "exempt", value = exemptStr},
        {id = "scanNotes", value = notesScanStatus},
    }
    if vals[3].value == "" then vals[3].value = "None" end
    for i = 1, 8 do
        local row = dialog:GetNamedChild("Option" .. i)
        if row then
            local opt, val = SETTINGS_OPTIONS[i], vals[i]
            if opt and val then row:SetText(i == bk.settingsSelectedIndex and "|cFFFF00► " .. opt.label .. ": |cFFD700" .. val.value .. "|r" or "|cFFFFFF  " .. opt.label .. ": |c888888" .. val.value .. "|r") row:SetHidden(false)
            else row:SetText("") row:SetHidden(true) end
        end
    end
end

function NWT.BookkeeperCycleSettingsOption(dir)
    local bk = NWT.Bookkeeper
    if bk.rafflePickerOpen then
        NWT.BookkeeperAdjustWinnerCount(dir)
        return
    end
    if bk.datePickerOpen then
        NWT.BookkeeperAdjustDatePickerValue(dir)
        return
    end
    if bk.exemptMenuOpen then
        NWT.BookkeeperCycleExemptRank(dir)
        return
    end
    if not bk.settingsMenuOpen then return end
    local nO = #SETTINGS_OPTIONS
    bk.settingsSelectedIndex = (dir == "up") and (bk.settingsSelectedIndex == 1 and nO or bk.settingsSelectedIndex - 1) or (bk.settingsSelectedIndex == nO and 1 or bk.settingsSelectedIndex + 1)
    NWT.UpdateSettingsDialog() PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.BookkeeperChangeSettingValue()
    local bk = NWT.Bookkeeper
    if bk.rafflePickerOpen then
        NWT.BookkeeperRunRafflePicker()
        return
    end
    if bk.datePickerOpen then
        NWT.BookkeeperConfirmDatePicker()
        return
    end
    if bk.exemptMenuOpen then
        NWT.BookkeeperToggleExemptRank()
        return
    end
    if not bk.settingsMenuOpen then return end
    local gs = GetBookkeeperGuildSettings(bk.settingsGuildId)
    local opt = SETTINGS_OPTIONS[bk.settingsSelectedIndex]
    if not opt then return end
    if opt.id == "trackGuild" then
        ToggleGuildEnabled(bk.settingsGuildId)
    elseif opt.id == "dues" then
        local cur, nextIdx = gs.duesAmount or 5000, 1
        for i, amt in ipairs(DUES_OPTIONS) do if cur == amt then nextIdx = (i % #DUES_OPTIONS) + 1 break elseif cur < amt then nextIdx = i break end end
        gs.duesAmount = DUES_OPTIONS[nextIdx]
    elseif opt.id == "raffle" then
        local cur, nextIdx = table.concat(gs.raffleSuffixes or {1, 5}, ", "), 1
        for i, p in ipairs(RAFFLE_PRESETS) do if table.concat(p.suffixes, ", ") == cur then nextIdx = (i % #RAFFLE_PRESETS) + 1 break end end
        gs.raffleSuffixes = RAFFLE_PRESETS[nextIdx].suffixes
    elseif opt.id == "ticketPrice" then
        local cur, nextIdx = gs.ticketPrice or 1000, 1
        for i, amt in ipairs(TICKET_OPTIONS) do if cur == amt then nextIdx = (i % #TICKET_OPTIONS) + 1 break elseif cur < amt then nextIdx = i break end end
        gs.ticketPrice = TICKET_OPTIONS[nextIdx]
    elseif opt.id == "rafflePeriod" then
        local presets = GetRafflePeriodPresets()
        local curIdx = 1
        local curId = gs.rafflePeriodId or "all"
        for i, p in ipairs(presets) do
            if p.id == curId then curIdx = i break end
        end
        local nextIdx = (curIdx % #presets) + 1
        gs.rafflePeriodId = presets[nextIdx].id
        -- If custom selected, open date picker
        if gs.rafflePeriodId == "custom" then
            NWT.BookkeeperShowDatePicker()
            return
        end
    elseif opt.id == "rafflePicker" then
        -- Open raffle picker UI
        NWT.BookkeeperShowRafflePicker()
        return
    elseif opt.id == "exempt" then
        -- Open exempt ranks sub-menu
        NWT.BookkeeperShowExemptRanksMenu()
        return
    elseif opt.id == "scanNotes" then
        -- Scan all member notes for payment dates
        NWT.BookkeeperScanPaymentNotes(bk.settingsGuildId)
        return
    end
    PlaySound(SOUNDS.POSITIVE_CLICK) NWT.UpdateSettingsDialog() NWT.UpdateBookkeeperUI()
end

-- Random Raffle Picker
function NWT.BookkeeperShowRafflePicker()
    local bk = NWT.Bookkeeper
    bk.rafflePickerOpen = true
    bk.raffleWinnerCount = 1
    -- Hide settings dialog
    if ATK_BookkeeperSettingsDialog then ATK_BookkeeperSettingsDialog:SetHidden(true) end
    NWT.UpdateRafflePickerDialog()
    if ATK_RafflePickerDialog then ATK_RafflePickerDialog:SetHidden(false) end
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) end
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.UpdateRafflePickerDialog()
    local bk = NWT.Bookkeeper
    local dialog = ATK_RafflePickerDialog
    if not dialog then return end
    
    local guildId = GetGuildId(bk.selectedGuildIndex)
    local gs = GetBookkeeperGuildSettings(guildId)
    local startTime, endTime = GetRafflePeriodTimes(gs)
    local ticketPrice = gs.ticketPrice or 1000
    
    -- Count entries and tickets
    local entryCount, totalTickets = 0, 0
    for _, m in pairs(gs.memberPayments or {}) do
        if m.isCurrentMember and m.deposits then
            local memberRaffle = 0
            for _, dep in ipairs(m.deposits) do
                if dep.type == "raffle" and dep.timestamp >= startTime and dep.timestamp <= endTime then
                    memberRaffle = memberRaffle + dep.amount
                end
            end
            if memberRaffle > 0 then
                local tickets = math.floor(memberRaffle / ticketPrice)
                if tickets > 0 then entryCount = entryCount + 1 totalTickets = totalTickets + tickets end
            end
        end
    end
    
    local periodLabel = dialog:GetNamedChild("Period")
    local statsLabel = dialog:GetNamedChild("Stats")
    local countLabel = dialog:GetNamedChild("WinnerCount")
    
    if periodLabel then periodLabel:SetText(string.format("|cFFFFAAPeriod:|r %s", FormatRafflePeriod(gs))) end
    if statsLabel then statsLabel:SetText(string.format("|c00FFFF%d participants|r  |cFFFF00%d tickets|r", entryCount, totalTickets)) end
    if countLabel then countLabel:SetText(string.format("|cFFFFFF# Winners:|r |cFFD700◄ %d ►|r", bk.raffleWinnerCount)) end
end

function NWT.BookkeeperAdjustWinnerCount(dir)
    local bk = NWT.Bookkeeper
    if not bk.rafflePickerOpen then return end
    if dir == "up" or dir == "right" then
        bk.raffleWinnerCount = math.min(10, bk.raffleWinnerCount + 1)
    else
        bk.raffleWinnerCount = math.max(1, bk.raffleWinnerCount - 1)
    end
    NWT.UpdateRafflePickerDialog()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.BookkeeperRunRafflePicker()
    local bk = NWT.Bookkeeper
    local guildId = GetGuildId(bk.selectedGuildIndex)
    local gs = GetBookkeeperGuildSettings(guildId)
    local startTime, endTime = GetRafflePeriodTimes(gs)
    local ticketPrice = gs.ticketPrice or 1000
    
    -- Build weighted pool
    local pool = {}
    local totalTickets = 0
    for _, m in pairs(gs.memberPayments or {}) do
        if m.isCurrentMember and m.deposits then
            local memberRaffle = 0
            for _, dep in ipairs(m.deposits) do
                if dep.type == "raffle" and dep.timestamp >= startTime and dep.timestamp <= endTime then
                    memberRaffle = memberRaffle + dep.amount
                end
            end
            if memberRaffle > 0 then
                local tickets = math.floor(memberRaffle / ticketPrice)
                if tickets > 0 then
                    table.insert(pool, { name = m.name, tickets = tickets })
                    totalTickets = totalTickets + tickets
                end
            end
        end
    end
    
    if #pool == 0 then
NWT.Debug("|cFFFF00[Bookkeeper]|r No raffle entries for this period!")
        return
    end
    
    -- Pick winners
    local winners = {}
    local winnerCount = math.min(bk.raffleWinnerCount, #pool)
    
    for w = 1, winnerCount do
        local winningTicket = math.random(1, totalTickets)
        local runningTotal = 0
        for i, entry in ipairs(pool) do
            runningTotal = runningTotal + entry.tickets
            if winningTicket <= runningTotal then
                table.insert(winners, { name = entry.name, tickets = entry.tickets, place = w })
                -- Remove winner from pool for next draw
                totalTickets = totalTickets - entry.tickets
                table.remove(pool, i)
                break
            end
        end
    end
    
    bk.raffleWinners = winners
    bk.raffleTotalTickets = totalTickets
    bk.raffleEntryCount = #pool + #winners
    
    -- Close picker, show results
    if ATK_RafflePickerDialog then ATK_RafflePickerDialog:SetHidden(true) end
    NWT.ShowRaffleWinnerDialog()
end

function NWT.CloseRafflePickerDialog()
    local bk = NWT.Bookkeeper
    bk.rafflePickerOpen = false
    if ATK_RafflePickerDialog then ATK_RafflePickerDialog:SetHidden(true) end
    if ATK_BookkeeperSettingsDialog then ATK_BookkeeperSettingsDialog:SetHidden(false) end
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) end
    NWT.UpdateSettingsDialog()
end

function NWT.ShowRaffleWinnerDialog()
    local bk = NWT.Bookkeeper
    local dialog = ATK_RaffleWinnerDialog
    if not dialog then return end
    
    local winners = bk.raffleWinners
    if not winners or #winners == 0 then return end
    
    -- Build winner display
    local winnerText = ""
    for i, w in ipairs(winners) do
        local displayName = w.name:gsub("^@", "")
        if i == 1 then
            winnerText = string.format("|cFFD700#%d: %s|r (%d tickets)", i, displayName, w.tickets)
        else
            winnerText = winnerText .. string.format("\n|cFFFFAA#%d: %s|r (%d)", i, displayName, w.tickets)
        end
    end
    
    local nameLabel = dialog:GetNamedChild("WinnerName")
    local statsLabel = dialog:GetNamedChild("Stats")
    
    if nameLabel then nameLabel:SetText(winnerText) end
    if statsLabel then statsLabel:SetText(string.format("|c888888%d participants in draw|r", bk.raffleEntryCount)) end
    
    bk.raffleWinner = true -- Flag that dialog is open
    dialog:SetHidden(false)
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) end
    PlaySound(SOUNDS.TELVAR_GAINED)
end

function NWT.CloseRaffleWinnerDialog()
    if ATK_RaffleWinnerDialog then ATK_RaffleWinnerDialog:SetHidden(true) end
    NWT.Bookkeeper.raffleWinner = nil
    NWT.Bookkeeper.raffleWinners = nil
    -- Show settings again
    if ATK_BookkeeperSettingsDialog then ATK_BookkeeperSettingsDialog:SetHidden(false) end
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) end
    NWT.UpdateSettingsDialog()
end

function NWT.BookkeeperRerollRaffle()
    NWT.CloseRaffleWinnerDialog()
    -- Go back to picker
    NWT.BookkeeperShowRafflePicker()
end

-- Date Picker for Custom Raffle Period
function NWT.BookkeeperShowDatePicker()
    local bk = NWT.Bookkeeper
    bk.datePickerOpen = true
    bk.datePickerField = "start" -- "start" or "end"
    bk.datePickerDaysAgo = {start = 7, ["end"] = 0} -- Default: last 7 days
    -- Hide settings dialog while date picker is open
    if ATK_BookkeeperSettingsDialog then ATK_BookkeeperSettingsDialog:SetHidden(true) end
    NWT.UpdateDatePickerDialog()
    if ATK_DatePickerDialog then ATK_DatePickerDialog:SetHidden(false) end
    -- Update keybind strip to show "Switch Field" for Y button
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) end
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.UpdateDatePickerDialog()
    local bk = NWT.Bookkeeper
    local dialog = ATK_DatePickerDialog
    if not dialog then return end
    
    local now = GetTimeStamp()
    local startDays = bk.datePickerDaysAgo.start
    local endDays = bk.datePickerDaysAgo["end"]
    local startDate = os.date("%m/%d/%Y", now - (startDays * 86400))
    local endDate = os.date("%m/%d/%Y", now - (endDays * 86400))
    
    local startLabel = dialog:GetNamedChild("StartValue")
    local endLabel = dialog:GetNamedChild("EndValue")
    local startSel = bk.datePickerField == "start"
    
    if startLabel then
        startLabel:SetText(startSel and string.format("|cFFD700► %s ◄|r (%d days ago)", startDate, startDays) or string.format("|c888888  %s|r (%d days ago)", startDate, startDays))
    end
    if endLabel then
        endLabel:SetText(not startSel and string.format("|cFFD700► %s ◄|r (%d days ago)", endDate, endDays) or string.format("|c888888  %s|r (%d days ago)", endDate, endDays))
    end
    
    local hint = dialog:GetNamedChild("Hint")
    if hint then hint:SetText("|c888888[A] Confirm  [B] Cancel  [X] Switch Field  [D-pad] Adjust Days|r") end
end

function NWT.BookkeeperCycleDatePickerField()
    local bk = NWT.Bookkeeper
    if not bk.datePickerOpen then return end
    bk.datePickerField = (bk.datePickerField == "start") and "end" or "start"
    NWT.UpdateDatePickerDialog()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.BookkeeperAdjustDatePickerValue(dir)
    local bk = NWT.Bookkeeper
    if not bk.datePickerOpen then return end
    local field = bk.datePickerField
    local current = bk.datePickerDaysAgo[field]
    if dir == "up" then
        bk.datePickerDaysAgo[field] = math.max(0, current - 1)
    else
        bk.datePickerDaysAgo[field] = math.min(90, current + 1)
    end
    NWT.UpdateDatePickerDialog()
end

function NWT.BookkeeperConfirmDatePicker()
    local bk = NWT.Bookkeeper
    if not bk.datePickerOpen then return end
    local gs = GetBookkeeperGuildSettings(bk.settingsGuildId)
    local now = GetTimeStamp()
    gs.customRaffleStart = now - (bk.datePickerDaysAgo.start * 86400)
    gs.customRaffleEnd = now - (bk.datePickerDaysAgo["end"] * 86400)
    gs.rafflePeriodId = "custom"
    NWT.CloseDatePickerDialog()
    PlaySound(SOUNDS.POSITIVE_CLICK)
end

function NWT.CloseDatePickerDialog()
    local bk = NWT.Bookkeeper
    bk.datePickerOpen = false
    if ATK_DatePickerDialog then ATK_DatePickerDialog:SetHidden(true) end
    if ATK_BookkeeperSettingsDialog then ATK_BookkeeperSettingsDialog:SetHidden(false) end
    -- Update keybind strip to restore normal keybinds
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) end
    NWT.UpdateSettingsDialog()
    NWT.UpdateBookkeeperUI()
end

-- Exempt Ranks Sub-Menu
function NWT.BookkeeperShowExemptRanksMenu()
    local bk = NWT.Bookkeeper
    bk.exemptMenuOpen = true
    bk.exemptRankIndex = 2 -- Start at 2 since 1 is usually Guild Master
    -- Hide settings dialog while exempt dialog is open
    if ATK_BookkeeperSettingsDialog then ATK_BookkeeperSettingsDialog:SetHidden(true) end
    NWT.UpdateExemptRanksDialog()
    if ATK_ExemptRanksDialog then ATK_ExemptRanksDialog:SetHidden(false) end
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.UpdateExemptRanksDialog()
    local bk = NWT.Bookkeeper
    local dialog = ATK_ExemptRanksDialog
    if not dialog then return end
    local gs = GetBookkeeperGuildSettings(bk.settingsGuildId)
    local gn = GetGuildName(bk.settingsGuildId)
    local header = dialog:GetNamedChild("Header")
    if header then header:SetText("|cFFD700Exempt Ranks - " .. gn .. "|r") end
    
    local numRanks = GetNumGuildRanks(bk.settingsGuildId)
    for i = 1, 10 do
        local row = dialog:GetNamedChild("Rank" .. i)
        if row then
            if i <= numRanks and not IsGuildRankGuildMaster(bk.settingsGuildId, i) then
                local rankName = GetGuildRankCustomName(bk.settingsGuildId, i) or ("Rank " .. i)
                local isExempt = gs.exemptRanks and gs.exemptRanks[i]
                local checkbox = isExempt and "|c00FF00[✓]|r" or "|cFF6666[ ]|r"
                local isSel = (i == bk.exemptRankIndex)
                if isSel then
                    row:SetText(string.format("|cFFD700►►|r %s |cFFFFFF%s|r |cFFD700◄◄|r", checkbox, rankName))
                else
                    row:SetText(string.format("   %s |c888888%s|r", checkbox, rankName))
                end
                row:SetHidden(false)
            else
                row:SetText("")
                row:SetHidden(true)
            end
        end
    end
    local hint = dialog:GetNamedChild("Hint")
    if hint then hint:SetText("|c888888[A] Toggle  [B] Done|r") end
end

function NWT.BookkeeperCycleExemptRank(dir)
    local bk = NWT.Bookkeeper
    if not bk.exemptMenuOpen then return end
    local numRanks = GetNumGuildRanks(bk.settingsGuildId)
    local validRanks = {}
    for i = 1, numRanks do
        if not IsGuildRankGuildMaster(bk.settingsGuildId, i) then table.insert(validRanks, i) end
    end
    if #validRanks == 0 then return end
    local curPos = 1
    for i, r in ipairs(validRanks) do if r == bk.exemptRankIndex then curPos = i break end end
    if dir == "up" then curPos = curPos == 1 and #validRanks or curPos - 1
    else curPos = curPos == #validRanks and 1 or curPos + 1 end
    bk.exemptRankIndex = validRanks[curPos]
    NWT.UpdateExemptRanksDialog()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.BookkeeperToggleExemptRank()
    local bk = NWT.Bookkeeper
    if not bk.exemptMenuOpen then return end
    local gs = GetBookkeeperGuildSettings(bk.settingsGuildId)
    local idx = bk.exemptRankIndex
    if gs.exemptRanks[idx] then gs.exemptRanks[idx] = nil
    else gs.exemptRanks[idx] = true end
    NWT.UpdateExemptRanksDialog()
    PlaySound(SOUNDS.POSITIVE_CLICK)
end

function NWT.CloseExemptRanksDialog()
    local bk = NWT.Bookkeeper
    bk.exemptMenuOpen = false
    if ATK_ExemptRanksDialog then ATK_ExemptRanksDialog:SetHidden(true) end
    -- Show settings dialog again
    if ATK_BookkeeperSettingsDialog then ATK_BookkeeperSettingsDialog:SetHidden(false) end
    NWT.UpdateSettingsDialog()
    NWT.BuildBookkeeperMemberList(bk.settingsGuildId)
    NWT.UpdateBookkeeperUI()
end

function NWT.CloseSettingsDialog()
    local bk = NWT.Bookkeeper
    if bk.rafflePickerOpen then
        NWT.CloseRafflePickerDialog()
        return
    end
    if bk.datePickerOpen then
        NWT.CloseDatePickerDialog()
        return
    end
    if bk.exemptMenuOpen then
        NWT.CloseExemptRanksDialog()
        return
    end
    bk.settingsMenuOpen, bk.settingsGuildId = false, nil
    if ATK_BookkeeperSettingsDialog then ATK_BookkeeperSettingsDialog:SetHidden(true) end
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) end
end

function NWT.BookkeeperToggleLifetime()
    local bk = NWT.Bookkeeper
    if bk.rankMenuOpen then return end
    local m = bk.sortedMembers[bk.selectedMemberIndex]
    if not m then return end
    local gs = GetBookkeeperGuildSettings(GetGuildId(bk.selectedGuildIndex))
    if gs.lifetimeMembers[m.name] then gs.lifetimeMembers[m.name] = nil
    else gs.lifetimeMembers[m.name] = true end
    PlaySound(SOUNDS.POSITIVE_CLICK) NWT.UpdateBookkeeperUI()
    KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor)
end

function NWT.BookkeeperKickMember()
    local bk = NWT.Bookkeeper
    if bk.rankMenuOpen then return end
    local m = bk.sortedMembers[bk.selectedMemberIndex]
    if not m then return end
    local gId = GetGuildId(bk.selectedGuildIndex)
    if not DoesPlayerHaveGuildPermission(gId, GUILD_PERMISSION_REMOVE) then NWT.Debug("|cFF0000[Bookkeeper]|r No permission to remove members") return end
    bk.pendingKickMember, bk.pendingKickGuildId, bk.pendingKickMemberData = m.name:find("^@") and m.name or "@" .. m.name, gId, m
    if not ESO_Dialogs["ATK_KICK_MEMBER_DIALOG"] then
        ESO_Dialogs["ATK_KICK_MEMBER_DIALOG"] = {
            gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC }, canQueue = true,
            title = { text = "KICK MEMBER?" }, mainText = { text = "Are you sure you want to kick <<1>> from the guild?" },
            buttons = {
                { text = "Kick", keybind = "DIALOG_PRIMARY", callback = function() local b = NWT.Bookkeeper if b.pendingKickMember and b.pendingKickGuildId then GuildRemove(b.pendingKickGuildId, b.pendingKickMember) b.pendingKickMemberData.isCurrentMember = false NWT.BuildBookkeeperMemberList(b.pendingKickGuildId) NWT.UpdateBookkeeperUI() NWT.SyncHiddenBookkeeperList() end b.pendingKickMember, b.pendingKickGuildId, b.pendingKickMemberData = nil, nil, nil end },
                { text = "Cancel", keybind = "DIALOG_NEGATIVE", callback = function() local b = NWT.Bookkeeper b.pendingKickMember, b.pendingKickGuildId, b.pendingKickMemberData = nil, nil, nil end },
            },
        }
    end
    if IsInGamepadPreferredMode() then ZO_Dialogs_ShowGamepadDialog("ATK_KICK_MEMBER_DIALOG", nil, {mainTextParams = {m.name}})
    else ZO_Dialogs_ShowDialog("ATK_KICK_MEMBER_DIALOG", nil, {mainTextParams = {m.name}}) end
end

-- ============================================
-- COMPREHENSIVE DUES SETTINGS SYSTEM
-- ============================================

NWT.DUES_SETTINGS_TABS = {
    { id = "dues", label = "DUES" },
    { id = "periods", label = "PERIODS" },
    { id = "ranks", label = "RANKS" },
    { id = "enforce", label = "ENFORCE" },
    { id = "notes", label = "NOTES" },
    { id = "actions", label = "ACTIONS" },
}
local DUES_SETTINGS_TABS = NWT.DUES_SETTINGS_TABS

local DUES_AMOUNT_OPTIONS = {1000, 2000, 2500, 5000, 7500, 10000, 15000, 20000, 25000, 30000, 50000, 100000}
local PERIOD_OPTIONS = {"weekly", "biweekly", "monthly", "custom"}
local GRACE_PERIOD_OPTIONS = {0, 1, 2, 3, 5, 7, 14}
local NOTE_FORMAT_OPTIONS = {"range", "due", "paid", "custom"}
local SORT_OPTIONS = {"status", "name", "rank", "lastPaid", "amount"}

-- Smart amount increments based on current value (for up to 20m)
local function GetAmountIncrement(currentAmount, direction)
    local amount = currentAmount or 0
    if amount < 50000 then return 1000 * direction
    elseif amount < 100000 then return 5000 * direction
    elseif amount < 500000 then return 10000 * direction
    elseif amount < 1000000 then return 50000 * direction
    elseif amount < 5000000 then return 100000 * direction
    elseif amount < 10000000 then return 500000 * direction
    else return 1000000 * direction end
end

-- Period options for per-rank dues
local RANK_PERIOD_OPTIONS = {"weekly", "biweekly", "monthly", "yearly"}
local RANK_PERIOD_LABELS = {weekly = "Weekly", biweekly = "Bi-Weekly", monthly = "Monthly", yearly = "Yearly"}
local RANK_PERIOD_SHORT = {weekly = "wk", biweekly = "bw", monthly = "mo", yearly = "yr"}

-- Get effective dues amount and period for a member based on their rank
function NWT.GetEffectiveDuesForRank(guildSettings, rankIndex)
    if not guildSettings then return guildSettings.duesAmount or 5000, guildSettings.duesPeriod or "weekly" end
    
    -- Check if rank is exempt
    if guildSettings.exemptRanks and guildSettings.exemptRanks[rankIndex] then
        return 0, nil  -- Exempt
    end
    
    -- Check for per-rank override
    local override = guildSettings.rankDuesOverride and guildSettings.rankDuesOverride[rankIndex]
    if override and type(override) == "table" then
        local amount = override.amount or guildSettings.duesAmount or 5000
        local period = override.period or guildSettings.duesPeriod or "weekly"
        return amount, period
    elseif override and type(override) == "number" then
        -- Legacy support: just an amount, use guild period
        return override, guildSettings.duesPeriod or "weekly"
    end
    
    -- Use guild defaults
    return guildSettings.duesAmount or 5000, guildSettings.duesPeriod or "weekly"
end

-- Format rank dues for display
local function FormatRankDues(guildSettings, rankIndex)
    local exemptType = guildSettings.exemptRanks and guildSettings.exemptRanks[rankIndex]
    if exemptType then
        if exemptType == "gm" then return "|cFFD700GM|r"
        elseif exemptType == "officer" then return "|c00FFFFOFFICE|r"
        elseif exemptType == "lifetime" then return "|c00FF00LIFE|r"
        else return "|c00FFFFEXEMPT|r" end
    end
    
    local override = guildSettings.rankDuesOverride and guildSettings.rankDuesOverride[rankIndex]
    if override and type(override) == "table" then
        local amt = override.amount or 0
        local per = override.period or "weekly"
        local perShort = per == "weekly" and "wk" or (per == "monthly" and "mo" or (per == "yearly" and "yr" or "bw"))
        return "|c00FF00" .. NWT.FormatGold(amt) .. "/" .. perShort .. "|r"
    elseif override and type(override) == "number" then
        return NWT.FormatGold(override) .. "g"
    end
    
    return "Default"
end

local function FormatDuesPeriod(gs)
    local period = gs.duesPeriod or "weekly"
    if period == "weekly" then return "Weekly (7 days)"
    elseif period == "biweekly" then return "Bi-Weekly (14 days)"
    elseif period == "monthly" then return "Monthly (30 days)"
    elseif period == "custom" then return "Custom (" .. (gs.customDaysPeriod or 7) .. " days)"
    end
    return period
end

local function GetDuesSettingsForTab(tabId, gs, guildId)
    if tabId == "dues" then
        return {
            { id = "duesAmount", label = "Dues Amount", value = NWT.FormatGold(gs.duesAmount or 5000) .. "g", type = "cycle", options = DUES_AMOUNT_OPTIONS },
            { id = "duesSuffix", label = "Dues Deposit Suffix", value = tostring(gs.duesSuffix), type = "number" },
            { id = "freeTraderMode", label = "Free Trader Mode", value = gs.freeTraderMode and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" },
            { id = "freeTraderHelp", label = "How To Scan", value = "At banker: open Guild Trader, select this guild, then press L3.", type = "info" },
        }
    elseif tabId == "periods" then
        return {
            { id = "duesPeriod", label = "Dues Period", value = FormatDuesPeriod(gs), type = "cycle", options = PERIOD_OPTIONS },
            { id = "customDaysPeriod", label = "Custom Period Days", value = tostring(gs.customDaysPeriod or 7) .. " days", type = "number" },
            { id = "traderFlipDay", label = "Trader Flip Day", value = ({"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"})[gs.traderFlipDay or 3], type = "cycle" },
            { id = "gracePeriodDays", label = "Grace Period", value = (gs.gracePeriodDays or 3) .. " days", type = "cycle", options = GRACE_PERIOD_OPTIONS },
            { id = "lateFeeEnabled", label = "Late Fee", value = gs.lateFeeEnabled and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" },
            { id = "lateFeeAmount", label = "Late Fee Amount", value = NWT.FormatGold(gs.lateFeeAmount or 0) .. "g", type = "number" },
        }
    elseif tabId == "ranks" then
        local rankSettings = {}
        if guildId > 0 then
            -- Add instructions header
            table.insert(rankSettings, { id = "rankHelp", label = "|c888888A=Amount  X=Period  Y=Exempt|r", value = "", type = "info" })
            
            for i = 1, GetNumGuildRanks(guildId) do
                if not IsGuildRankGuildMaster(guildId, i) then
                    local rankName = GetGuildRankCustomName(guildId, i) or ("Rank " .. i)
                    local exemptType = gs.exemptRanks and gs.exemptRanks[i]
                    local override = gs.rankDuesOverride and gs.rankDuesOverride[i]
                    
                    local amountText, periodText
                    if exemptType then
                        amountText = "|c00FFFFEXEMPT|r"
                        periodText = ""
                    elseif override and type(override) == "table" then
                        local amt = override.amount or 0
                        local per = override.period or "weekly"
                        amountText = "|c00FF00" .. NWT.FormatGold(amt) .. "g|r"
                        periodText = "|cFFFF00" .. (RANK_PERIOD_SHORT[per] or per) .. "|r"
                    else
                        amountText = "Default"
                        periodText = ""
                    end
                    
                    local displayValue = amountText
                    if periodText ~= "" then displayValue = amountText .. "/" .. periodText end
                    
                    table.insert(rankSettings, { 
                        id = "rank_" .. i, 
                        label = rankName, 
                        value = displayValue, 
                        type = "rank_config", 
                        rankIndex = i 
                    })
                end
            end
        else
            table.insert(rankSettings, { id = "noGuild", label = "|c888888(Select a guild to configure ranks)|r", value = "", type = "info" })
        end
        return rankSettings
    elseif tabId == "enforce" then
        -- Build rank list for demotion rank selection
        local demotionRankName = "Not Set"
        if gs.demotionRank and guildId > 0 then
            demotionRankName = GetGuildRankCustomName(guildId, gs.demotionRank) or ("Rank " .. gs.demotionRank)
        end
        local demotedCount = 0
        for _ in pairs(gs.demotedMembers or {}) do demotedCount = demotedCount + 1 end
        
        return {
            { id = "autoDemoteEnabled", label = "Full Auto Mode", value = gs.autoDemoteEnabled and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" },
            { id = "demotionRank", label = "Demotion Rank", value = demotionRankName, type = "rank_select" },
            { id = "daysBeforeDemotion", label = "Days Before Demote", value = (gs.daysBeforeDemotion or 7) .. " days", type = "cycle", options = {3, 5, 7, 10, 14, 21, 30} },
            { id = "demotedCount", label = "|cFFAAAACurrently Demoted|r", value = "|cFFFF00" .. demotedCount .. " members|r", type = "info" },
            { id = "previewDemotions", label = "|c00FFFF► Preview Demotions|r", value = "", type = "action" },
            { id = "runDemotions", label = "|cFF6600► Run Demotions Now|r", value = "", type = "action" },
            { id = "restoreAll", label = "|c00FF00► Restore All Demoted|r", value = "", type = "action" },
        }
    elseif tabId == "notes" then
        -- Format display names
        local formatDisplayNames = {
            range = "Range (1/1-2/1)",
            due = "Due: 2/1",
            paid = "Paid thru 2/1",
            custom = "Custom Template",
        }
        local currentFormat = gs.noteFormat or "range"
        local formatDisplay = formatDisplayNames[currentFormat] or "Range (1/1-2/1)"
        
        -- Get template preview
        local templatePreview = ""
        if currentFormat == "custom" then
            templatePreview = gs.customNoteFormat or "{START}-{END} Upd:{UPD}"
        else
            templatePreview = NOTE_FORMAT_TEMPLATES[currentFormat] or NOTE_FORMAT_TEMPLATES.range
        end
        
        return {
            { id = "autoUpdateNotes", label = "Auto-Update Notes", value = gs.autoUpdateNotes and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" },
            { id = "noteFormat", label = "Note Format", value = formatDisplay, type = "cycle", options = {"range", "due", "paid", "custom"} },
            { id = "customNoteFormat", label = "Custom Template", value = gs.customNoteFormat or "{START}-{END} Upd:{UPD}", type = "text_input" },
            { id = "templateHelp", label = "|c888888Placeholders: {START} {END} {UPD}|r", value = "", type = "info" },
            { id = "reformatNotes", label = "|c00FFFF► Reformat All Notes|r", value = "", type = "action" },
            { id = "scanNotes", label = "|c00FFFF► Scan All Member Notes|r", value = "", type = "action" },
        }
    elseif tabId == "alerts" then
        return {
            { id = "alertOnLogin", label = "Show Unpaid on Login", value = gs.alertOnLogin and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" },
            { id = "alertUnpaidCount", label = "Alert if Unpaid >", value = gs.alertUnpaidCount == 0 and "Disabled" or tostring(gs.alertUnpaidCount), type = "number" },
            { id = "highlightOverdue", label = "Highlight Overdue Members", value = gs.highlightOverdue and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" },
            { id = "showOfflineStatus", label = "Show Last Online", value = gs.showOfflineStatus and "|c00FF00ON|r" or "|cFF0000OFF|r", type = "toggle" },
        }
    elseif tabId == "actions" then
        return {
            { id = "scanGuild", label = "|c00FFFF► Scan Guild (Deposits + Sales)|r", value = "", type = "action" },
            { id = "exportUnpaid", label = "|cFFFFAA► Export Unpaid List|r", value = "", type = "action" },
            { id = "clearData", label = "|cFF6666► Clear All Data|r", value = "", type = "action" },
            { id = "sortBy", label = "Sort Members By", value = gs.sortBy or "status", type = "cycle", options = SORT_OPTIONS },
        }
    end
    return {}
end

function NWT.BookkeeperShowDuesSettings()
    local bk = NWT.Bookkeeper
    local guildId = GetGuildId(bk.viewingGuildIndex)
    
    bk.duesSettingsOpen = true
    bk.duesSettingsGuildId = guildId
    bk.duesSettingsTabIndex = 1
    bk.duesSettingsRowIndex = 1
    
    NWT.UpdateDuesSettingsDialog()
    if ATK_DuesSettingsDialog then ATK_DuesSettingsDialog:SetHidden(false) end
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then 
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) 
    end
end

function NWT.UpdateDuesSettingsDialog()
    local bk = NWT.Bookkeeper
    local dialog = ATK_DuesSettingsDialog
    if not dialog then return end
    
    local gs = GetBookkeeperGuildSettings(bk.duesSettingsGuildId or 0)
    local gn = bk.duesSettingsGuildId and bk.duesSettingsGuildId > 0 and GetGuildName(bk.duesSettingsGuildId) or "No Guild"
    dialog:GetNamedChild("GuildName"):SetText("|cFFFFFF" .. gn .. "|r")
    
    -- Update tab highlights
    local tabBar = dialog:GetNamedChild("TabBar")
    for i = 1, 6 do
        local tab = tabBar:GetNamedChild("Tab" .. i)
        if tab then
            if i == bk.duesSettingsTabIndex then
                tab:SetColor(1, 0.84, 0, 1)
            else
                tab:SetColor(0.6, 0.6, 0.6, 1)
            end
        end
    end
    
    -- Get settings for current tab
    local currentTab = DUES_SETTINGS_TABS[bk.duesSettingsTabIndex]
    local content = dialog:GetNamedChild("Content")
    local selectionBG = content:GetNamedChild("SelectionBG")
    local ranksLayout = content:GetNamedChild("RanksLayout")
    
    -- Check if this is the RANKS tab (uses two-column layout)
    local isRanksTab = (currentTab.id == "ranks")
    
    -- Hide standard rows for RANKS tab, show for others
    for i = 1, 10 do
        local row = content:GetNamedChild("Row" .. i)
        if row then row:SetHidden(isRanksTab) end
    end
    
    if isRanksTab then
        -- === TWO-COLUMN RANKS LAYOUT ===
        if ranksLayout then ranksLayout:SetHidden(false) end
        if selectionBG then selectionBG:SetHidden(true) end
        
        -- Initialize column tracking
        if not bk.ranksColumn then bk.ranksColumn = "left" end
        
        -- Get guild ranks data
        local guildId = bk.duesSettingsGuildId or 0
        local rankRows = {}
        if guildId > 0 then
            for i = 1, GetNumGuildRanks(guildId) do
                if not IsGuildRankGuildMaster(guildId, i) then
                    local rankName = GetGuildRankCustomName(guildId, i) or ("Rank " .. i)
                    if #rankName > 16 then rankName = rankName:sub(1,14) .. ".." end
                    
                    -- Exempt status
                    local exemptType = gs.exemptRanks and gs.exemptRanks[i]
                    local exemptText
                    if exemptType == "gm" then exemptText = "|cFFD700GM|r"
                    elseif exemptType == "officer" then exemptText = "|c00FFFFOFFICER|r"
                    elseif exemptType == "lifetime" then exemptText = "|c00FF00LIFETIME|r"
                    elseif exemptType then exemptText = "|c00FFFFEXEMPT|r"
                    else exemptText = "|c888888None|r" end
                    
                    -- Dues override
                    local override = gs.rankDuesOverride and gs.rankDuesOverride[i]
                    local duesText
                    if exemptType then
                        duesText = "|c888888--|r"
                    elseif override and type(override) == "table" then
                        local amt = override.amount or 0
                        local per = override.period or "weekly"
                        local perShort = RANK_PERIOD_SHORT[per] or per
                        duesText = "|c00FF00" .. NWT.FormatGold(amt) .. "|r |cFFFF00/" .. perShort .. "|r"
                    else
                        duesText = "|c888888Default|r"
                    end
                    
                    table.insert(rankRows, { rankIndex = i, name = rankName, exempt = exemptText, dues = duesText })
                end
            end
        end
        bk.ranksData = rankRows
        
        -- Populate left and right columns
        local leftSelBG = ranksLayout:GetNamedChild("LeftSelBG")
        local rightSelBG = ranksLayout:GetNamedChild("RightSelBG")
        
        for i = 1, 10 do
            local leftRow = ranksLayout:GetNamedChild("LeftRow" .. i)
            local rightRow = ranksLayout:GetNamedChild("RightRow" .. i)
            local rData = rankRows[i]
            
            if leftRow then
                if rData then
                    local isLeftSel = (i == bk.duesSettingsRowIndex and bk.ranksColumn == "left")
                    local prefix = isLeftSel and "|cFFFF00► " or "|cFFFFFF  "
                    leftRow:SetText(prefix .. rData.name .. "|r  " .. rData.exempt)
                    leftRow:SetHidden(false)
                else
                    leftRow:SetHidden(true)
                end
            end
            if rightRow then
                if rData then
                    local isRightSel = (i == bk.duesSettingsRowIndex and bk.ranksColumn == "right")
                    local prefix = isRightSel and "|cFFD700► " or ""
                    rightRow:SetText(prefix .. rData.dues)
                    rightRow:SetHidden(false)
                else
                    rightRow:SetHidden(true)
                end
            end
        end
        
        -- Update selection backgrounds
        local rowY = 35 + (bk.duesSettingsRowIndex - 1) * 36
        if leftSelBG then
            leftSelBG:ClearAnchors()
            leftSelBG:SetAnchor(TOPLEFT, ranksLayout, TOPLEFT, 20, rowY - 2)
            leftSelBG:SetHidden(bk.ranksColumn ~= "left")
        end
        if rightSelBG then
            rightSelBG:ClearAnchors()
            rightSelBG:SetAnchor(TOPRIGHT, ranksLayout, TOPRIGHT, -20, rowY - 2)
            rightSelBG:SetHidden(bk.ranksColumn ~= "right")
        end
        
        -- Store for handlers
        bk.currentDuesTabSettings = rankRows
        
        -- Update page info
        local pageInfo = dialog:GetNamedChild("PageInfo")
        if pageInfo then
            local colName = bk.ranksColumn == "left" and "Exempt" or "Dues"
            pageInfo:SetText(string.format("|c888888Column: %s  •  Rank %d of %d|r", colName, bk.duesSettingsRowIndex, #rankRows))
        end
    else
        -- === STANDARD SINGLE-COLUMN LAYOUT ===
        if ranksLayout then ranksLayout:SetHidden(true) end
        
        local settings = GetDuesSettingsForTab(currentTab.id, gs, bk.duesSettingsGuildId or 0)
        bk.currentDuesTabSettings = settings
        
        for i = 1, 10 do
            local row = content:GetNamedChild("Row" .. i)
            if row then
                local setting = settings[i]
                if setting then
                    local isSelected = (i == bk.duesSettingsRowIndex)
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
        
        -- Update selection highlight
        if selectionBG and bk.duesSettingsRowIndex <= #settings then
            selectionBG:ClearAnchors()
            selectionBG:SetAnchor(TOPLEFT, content, TOPLEFT, 15, 10 + (bk.duesSettingsRowIndex - 1) * 45)
            selectionBG:SetHidden(false)
        else
            selectionBG:SetHidden(true)
        end
        
        -- Update page info
        local pageInfo = dialog:GetNamedChild("PageInfo")
        if pageInfo then
            pageInfo:SetText(string.format("|c888888Tab %d of %d  •  Item %d of %d|r", bk.duesSettingsTabIndex, #DUES_SETTINGS_TABS, bk.duesSettingsRowIndex, #settings))
        end
    end
end

function NWT.DuesSettingsChangeTab(direction)
    local bk = NWT.Bookkeeper
    if not bk.duesSettingsOpen then return end
    
    if direction == "left" then
        bk.duesSettingsTabIndex = bk.duesSettingsTabIndex > 1 and bk.duesSettingsTabIndex - 1 or #DUES_SETTINGS_TABS
    else
        bk.duesSettingsTabIndex = bk.duesSettingsTabIndex < #DUES_SETTINGS_TABS and bk.duesSettingsTabIndex + 1 or 1
    end
    bk.duesSettingsRowIndex = 1
    bk.ranksColumn = "left"  -- Reset to left column on tab change
    NWT.UpdateDuesSettingsDialog()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

-- Switch between left/right columns on RANKS tab
function NWT.DuesSettingsSwitchColumn()
    local bk = NWT.Bookkeeper
    if not bk.duesSettingsOpen then return end
    
    local currentTab = DUES_SETTINGS_TABS[bk.duesSettingsTabIndex]
    if currentTab.id ~= "ranks" then return end
    
    bk.ranksColumn = bk.ranksColumn == "left" and "right" or "left"
    NWT.UpdateDuesSettingsDialog()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.DuesSettingsCycleRow(direction)
    local bk = NWT.Bookkeeper
    if not bk.duesSettingsOpen then return end
    
    local settings = bk.currentDuesTabSettings or {}
    local numSettings = #settings
    if numSettings == 0 then return end
    
    if direction == "up" then
        bk.duesSettingsRowIndex = bk.duesSettingsRowIndex > 1 and bk.duesSettingsRowIndex - 1 or numSettings
    else
        bk.duesSettingsRowIndex = bk.duesSettingsRowIndex < numSettings and bk.duesSettingsRowIndex + 1 or 1
    end
    NWT.UpdateDuesSettingsDialog()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.DuesSettingsChangeValue()
    local bk = NWT.Bookkeeper
    if not bk.duesSettingsOpen then return end
    
    local gs = GetBookkeeperGuildSettings(bk.duesSettingsGuildId or 0)
    local settings = bk.currentDuesTabSettings or {}
    local setting = settings[bk.duesSettingsRowIndex]
    if not setting then return end
    
    if setting.type == "toggle" then
        if setting.id == "lateFeeEnabled" then gs.lateFeeEnabled = not gs.lateFeeEnabled
        elseif setting.id == "autoUpdateNotes" then
            gs.autoUpdateNotes = not gs.autoUpdateNotes
            local guildName = GetGuildName(bk.duesSettingsGuildId) or ("Guild " .. (bk.duesSettingsGuildId or 0))
            NWT.Debug("|cFFD700[Bookkeeper]|r " .. guildName .. " - autoUpdateNotes toggled to: " .. tostring(gs.autoUpdateNotes))
        elseif setting.id == "includeUpdateTimestamp" then gs.includeUpdateTimestamp = not gs.includeUpdateTimestamp
        elseif setting.id == "alertOnLogin" then gs.alertOnLogin = not gs.alertOnLogin
        elseif setting.id == "highlightOverdue" then gs.highlightOverdue = not gs.highlightOverdue
        elseif setting.id == "showOfflineStatus" then gs.showOfflineStatus = not gs.showOfflineStatus
        elseif setting.id == "autoDemoteEnabled" then gs.autoDemoteEnabled = not gs.autoDemoteEnabled
        elseif setting.id == "freeTraderMode" then gs.freeTraderMode = not gs.freeTraderMode
        end
    elseif setting.type == "cycle" then
        if setting.id == "duesAmount" then
            local curIdx = 1
            for i, v in ipairs(DUES_AMOUNT_OPTIONS) do if gs.duesAmount == v then curIdx = i break end end
            gs.duesAmount = DUES_AMOUNT_OPTIONS[(curIdx % #DUES_AMOUNT_OPTIONS) + 1]
        elseif setting.id == "ticketPrice" then
            local curIdx = 1
            for i, v in ipairs(DUES_AMOUNT_OPTIONS) do if gs.ticketPrice == v then curIdx = i break end end
            gs.ticketPrice = DUES_AMOUNT_OPTIONS[(curIdx % #DUES_AMOUNT_OPTIONS) + 1]
        elseif setting.id == "duesPeriod" then
            local curIdx = 1
            for i, v in ipairs(PERIOD_OPTIONS) do if gs.duesPeriod == v then curIdx = i break end end
            gs.duesPeriod = PERIOD_OPTIONS[(curIdx % #PERIOD_OPTIONS) + 1]
        elseif setting.id == "gracePeriodDays" then
            local opts = setting.options or GRACE_PERIOD_OPTIONS
            local curIdx = 1
            for i, v in ipairs(opts) do if gs.gracePeriodDays == v then curIdx = i break end end
            gs.gracePeriodDays = opts[(curIdx % #opts) + 1]
        elseif setting.id == "daysBeforeDemotion" then
            local opts = {3, 5, 7, 10, 14, 21, 30}
            local curIdx = 1
            for i, v in ipairs(opts) do if gs.daysBeforeDemotion == v then curIdx = i break end end
            gs.daysBeforeDemotion = opts[(curIdx % #opts) + 1]
        elseif setting.id == "traderFlipDay" then
            gs.traderFlipDay = (gs.traderFlipDay % 7) + 1
        elseif setting.id == "sortBy" then
            local curIdx = 1
            for i, v in ipairs(SORT_OPTIONS) do if gs.sortBy == v then curIdx = i break end end
            gs.sortBy = SORT_OPTIONS[(curIdx % #SORT_OPTIONS) + 1]
        elseif setting.id == "noteFormat" then
            local opts = {"range", "due", "paid", "custom"}
            local curIdx = 1
            for i, v in ipairs(opts) do if gs.noteFormat == v then curIdx = i break end end
            gs.noteFormat = opts[(curIdx % #opts) + 1]
        end
    elseif setting.type == "number" then
        if setting.id == "duesSuffix" then gs.duesSuffix = (gs.duesSuffix + 1) % 11
        elseif setting.id == "customDaysPeriod" then gs.customDaysPeriod = ((gs.customDaysPeriod or 7) % 60) + 1
        elseif setting.id == "lateFeeAmount" then gs.lateFeeAmount = ((gs.lateFeeAmount or 0) + 1000) % 51000
        elseif setting.id == "alertUnpaidCount" then gs.alertUnpaidCount = ((gs.alertUnpaidCount or 0) + 5) % 105
        end
    elseif setting.type == "rank_select" then
        -- Cycle through available ranks for demotion rank
        local guildId = bk.duesSettingsGuildId
        if guildId and guildId > 0 then
            local numRanks = GetNumGuildRanks(guildId)
            local current = gs.demotionRank or 0
            current = current + 1
            if current > numRanks then current = 0 end  -- 0 = not set
            gs.demotionRank = current > 0 and current or nil
        end
    elseif setting.type == "text_input" then
        -- Open text input dialog
        if setting.id == "customNoteFormat" then
            NWT.BookkeeperShowNoteFormatInput(bk.duesSettingsGuildId)
        end
        return  -- Don't play sound or update yet
    elseif setting.type == "action" then
        if setting.id == "scanGuild" then NWT.ScanGuildForBookkeeper(bk.duesSettingsGuildId)
        elseif setting.id == "scanNotes" then NWT.BookkeeperScanPaymentNotes(bk.duesSettingsGuildId)
        elseif setting.id == "reformatNotes" then NWT.BookkeeperReformatAllNotes(bk.duesSettingsGuildId)
        elseif setting.id == "exportUnpaid" then NWT.BookkeeperExportUnpaid(bk.duesSettingsGuildId)
        elseif setting.id == "previewDemotions" then NWT.PreviewDemotions(bk.duesSettingsGuildId)
        elseif setting.id == "runDemotions" then NWT.RunDemotions(bk.duesSettingsGuildId)
        elseif setting.id == "restoreAll" then NWT.RestoreAllDemoted(bk.duesSettingsGuildId)
        elseif setting.id == "clearData" then
            gs.memberPayments = {}
            gs.salesData = {}
            gs.demotedMembers = {}
            gs.paymentHistory = {}
            gs.lastScanTime = 0
            -- Also clear noteUpdates for this guild (stored separately)
            local sv = NWT.savedVars
            if sv.bookkeeper and sv.bookkeeper.noteUpdates then
                sv.bookkeeper.noteUpdates[bk.duesSettingsGuildId] = nil
            end
NWT.Debug("|cFFFF00[Bookkeeper]|r Data cleared for " .. GetGuildName(bk.duesSettingsGuildId))
        end
    elseif setting.rankIndex then
        -- Two-column RANKS tab handling
        local rankIdx = setting.rankIndex
        
        if bk.ranksColumn == "left" then
            -- LEFT COLUMN: Cycle exempt status (None -> GM -> Officer -> Lifetime -> None)
            if not gs.exemptRanks then gs.exemptRanks = {} end
            local current = gs.exemptRanks[rankIdx]
            
            if not current then
                gs.exemptRanks[rankIdx] = "gm"
            elseif current == "gm" then
                gs.exemptRanks[rankIdx] = "officer"
            elseif current == "officer" then
                gs.exemptRanks[rankIdx] = "lifetime"
            else
                gs.exemptRanks[rankIdx] = nil
                -- Also clear dues override when removing exempt
            end
        else
            -- RIGHT COLUMN: Increase dues amount with smart increments
            local isExempt = gs.exemptRanks and gs.exemptRanks[rankIdx]
            if isExempt then return end  -- Can't edit dues for exempt ranks
            
            if not gs.rankDuesOverride then gs.rankDuesOverride = {} end
            local override = gs.rankDuesOverride[rankIdx]
            
            if not override or type(override) ~= "table" then
                -- Initialize with guild defaults
                gs.rankDuesOverride[rankIdx] = { amount = gs.duesAmount or 5000, period = gs.duesPeriod or "weekly" }
            else
                -- Increase amount with smart increment
                local currentAmount = override.amount or 0
                local increment = GetAmountIncrement(currentAmount, 1)
                local newAmount = currentAmount + increment
                if newAmount > 20000000 then newAmount = 0 end  -- Wrap to 0 (back to default)
                if newAmount == 0 then
                    gs.rankDuesOverride[rankIdx] = nil
                else
                    override.amount = newAmount
                end
            end
        end
    end
    
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateDuesSettingsDialog()
    NWT.UpdateBookkeeperUI()
end

-- X button: Cycle period for selected rank (only works on right column)
function NWT.DuesSettingsCyclePeriod()
    local bk = NWT.Bookkeeper
    if not bk.duesSettingsOpen then return end
    
    local currentTab = DUES_SETTINGS_TABS[bk.duesSettingsTabIndex]
    if currentTab.id ~= "ranks" then return end
    if bk.ranksColumn ~= "right" then return end  -- Only on right column
    
    local gs = GetBookkeeperGuildSettings(bk.duesSettingsGuildId or 0)
    local rankData = bk.ranksData and bk.ranksData[bk.duesSettingsRowIndex]
    if not rankData then return end
    
    local rankIdx = rankData.rankIndex
    local isExempt = gs.exemptRanks and gs.exemptRanks[rankIdx]
    if isExempt then return end  -- Can't change period on exempt rank
    
    if not gs.rankDuesOverride then gs.rankDuesOverride = {} end
    local override = gs.rankDuesOverride[rankIdx]
    
    if not override or type(override) ~= "table" then
        -- Initialize with guild defaults, then cycle period
        gs.rankDuesOverride[rankIdx] = { amount = gs.duesAmount or 5000, period = "biweekly" }
    else
        -- Cycle to next period
        local currentPeriod = override.period or "weekly"
        local currentIdx = 1
        for i, p in ipairs(RANK_PERIOD_OPTIONS) do
            if p == currentPeriod then currentIdx = i break end
        end
        override.period = RANK_PERIOD_OPTIONS[(currentIdx % #RANK_PERIOD_OPTIONS) + 1]
    end
    
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateDuesSettingsDialog()
end

-- Y button: Toggle exempt for selected rank
function NWT.DuesSettingsToggleExempt()
    local bk = NWT.Bookkeeper
    if not bk.duesSettingsOpen then return end
    
    local gs = GetBookkeeperGuildSettings(bk.duesSettingsGuildId or 0)
    local settings = bk.currentDuesTabSettings or {}
    local setting = settings[bk.duesSettingsRowIndex]
    if not setting or setting.type ~= "rank_config" then return end
    
    if not gs.exemptRanks then gs.exemptRanks = {} end
    
    local isExempt = gs.exemptRanks[setting.rankIndex]
    if isExempt then
        -- Clear exempt
        gs.exemptRanks[setting.rankIndex] = nil
    else
        -- Set exempt and clear any dues override
        gs.exemptRanks[setting.rankIndex] = true
        if gs.rankDuesOverride then gs.rankDuesOverride[setting.rankIndex] = nil end
    end
    
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateDuesSettingsDialog()
end

-- Increase amount (for X button on RANKS tab)
function NWT.DuesSettingsIncreaseAmount()
    local bk = NWT.Bookkeeper
    if not bk.duesSettingsOpen then return end
    
    local currentTab = DUES_SETTINGS_TABS and DUES_SETTINGS_TABS[bk.duesSettingsTabIndex]
    if not currentTab or currentTab.id ~= "ranks" then return end
    if bk.ranksColumn ~= "right" then return end  -- Only on right column
    
    local gs = GetBookkeeperGuildSettings(bk.duesSettingsGuildId or 0)
    local rankData = bk.ranksData and bk.ranksData[bk.duesSettingsRowIndex]
    if not rankData then return end
    
    local rankIdx = rankData.rankIndex
    local isExempt = gs.exemptRanks and gs.exemptRanks[rankIdx]
    if isExempt then return end
    
    if not gs.rankDuesOverride then gs.rankDuesOverride = {} end
    local override = gs.rankDuesOverride[rankIdx]
    
    if not override or type(override) ~= "table" then
        -- Initialize with guild default + first increment
        local baseAmount = gs.duesAmount or 5000
        gs.rankDuesOverride[rankIdx] = { amount = baseAmount + GetAmountIncrement(baseAmount, 1), period = gs.duesPeriod or "weekly" }
    else
        local currentAmount = override.amount or 0
        local increment = GetAmountIncrement(currentAmount, 1)
        local newAmount = currentAmount + increment
        if newAmount > 20000000 then newAmount = 20000000 end
        override.amount = newAmount
    end
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateDuesSettingsDialog()
end

-- Decrease amount (for Y button on RANKS tab)
function NWT.DuesSettingsDecreaseAmount()
    local bk = NWT.Bookkeeper
    if not bk.duesSettingsOpen then return end
    
    local currentTab = DUES_SETTINGS_TABS and DUES_SETTINGS_TABS[bk.duesSettingsTabIndex]
    if not currentTab or currentTab.id ~= "ranks" then return end
    if bk.ranksColumn ~= "right" then return end  -- Only on right column
    
    local gs = GetBookkeeperGuildSettings(bk.duesSettingsGuildId or 0)
    local rankData = bk.ranksData and bk.ranksData[bk.duesSettingsRowIndex]
    if not rankData then return end
    
    local rankIdx = rankData.rankIndex
    local isExempt = gs.exemptRanks and gs.exemptRanks[rankIdx]
    if isExempt then return end
    
    if not gs.rankDuesOverride then gs.rankDuesOverride = {} end
    local override = gs.rankDuesOverride[rankIdx]
    
    if not override or type(override) ~= "table" then
        -- No override (default) - wrap to 20m
        gs.rankDuesOverride[rankIdx] = { amount = 20000000, period = gs.duesPeriod or "weekly" }
    else
        local currentAmount = override.amount or 0
        local decrement = GetAmountIncrement(currentAmount, -1)
        local newAmount = currentAmount + decrement  -- decrement is negative
        if newAmount < 1000 then
            gs.rankDuesOverride[rankIdx] = nil  -- Back to default
        else
            override.amount = newAmount
        end
    end
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateDuesSettingsDialog()
end

function NWT.CloseDuesSettingsDialog()
    local bk = NWT.Bookkeeper
    bk.duesSettingsOpen = false
    bk.duesSettingsGuildId = nil
    bk.duesSettingsTabIndex = 1
    bk.duesSettingsRowIndex = 1
    bk.currentDuesTabSettings = nil
    if ATK_DuesSettingsDialog then ATK_DuesSettingsDialog:SetHidden(true) end
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then 
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) 
    end
end

function NWT.BookkeeperExportUnpaid(guildId)
    local gs = GetBookkeeperGuildSettings(guildId)
    local unpaidList = {}
    for name, m in pairs(gs.memberPayments or {}) do
        if m.isCurrentMember then
            local isLife = gs.lifetimeMembers and gs.lifetimeMembers[name]
            local isExempt = IsRankExempt(gs, m.rankIndex, guildId)
            if not isLife and not isExempt and m.thisWeekDues == 0 and m.duesMonths == 0 then
                table.insert(unpaidList, name)
            end
        end
    end
    table.sort(unpaidList)
NWT.Debug("|cFFD700[Bookkeeper]|r Unpaid members in " .. GetGuildName(guildId) .. ":")
    for _, name in ipairs(unpaidList) do
NWT.Debug("  • " .. name)
    end
NWT.Debug("|c888888Total: " .. #unpaidList .. " unpaid|r")
end

-- ============================================
-- MEMBER DETAILS VIEW
-- ============================================

function NWT.ShowMemberDetails()
    local bk = NWT.Bookkeeper
    if bk.focusPanel ~= "dues" then return end
    
    local member = bk.sortedMembers[bk.selectedMemberIndex]
    if not member then return end
    
    local dialog = ATK_MemberDetailsDialog
    if not dialog then return end
    
    local guildId = GetGuildId(bk.viewingGuildIndex)
    local gs = GetBookkeeperGuildSettings(guildId)
    
    -- Title
    local displayName = member.name:gsub("^@", "")
    dialog:GetNamedChild("Title"):SetText("|cFFD700" .. displayName .. "|r")
    
    -- Row 1: Rank
    local rank = (member.rankIndex and GetGuildRankCustomName(guildId, member.rankIndex)) or ("Rank " .. (member.rankIndex or "?"))
    dialog:GetNamedChild("Row1"):SetText(string.format("|cFFFFAARank:|r  |cFFFFFF%s|r", rank))
    
    -- Row 2: Status - show cycles remaining
    local isLife = gs.lifetimeMembers and gs.lifetimeMembers[member.name]
    local isExempt = member.isExemptRank
    local totalCycles = (member.thisWeekDues or 0) + (member.duesMonths or 0)
    local statusText
    if isLife then statusText = "|c00FFFFLIFETIME|r"
    elseif isExempt then statusText = "|cFF00FFEXEMPT|r"
    elseif totalCycles > 1 then statusText = "|c00FF00+" .. totalCycles .. " cycles prepaid|r"
    elseif totalCycles == 1 then statusText = "|c00FF00PAID (current cycle)|r"
    elseif member.isPaidViaNote then statusText = "|c00FF00PAID (via note)|r"
    else statusText = "|cFF4444UNPAID|r" end
    dialog:GetNamedChild("Row2"):SetText(string.format("|cFFFFAAStatus:|r  %s", statusText))
    
    -- Row 3: Total Deposited
    dialog:GetNamedChild("Row3"):SetText(string.format("|cFFFFAATotal Deposited:|r  |c00FF00%sg|r", NWT.FormatGold(member.totalDeposited or 0)))
    
    -- Row 4: Dues Paid
    local duesTotal = (member.totalDeposited or 0) - (member.raffleTotal or 0) - (member.otherTotal or 0)
    dialog:GetNamedChild("Row4"):SetText(string.format("|cFFFFAADues Paid:|r  |c00FF00%sg|r  (%d periods)", NWT.FormatGold(duesTotal), member.duesMonths or 0))
    
    -- Row 5: Raffle Entries
    dialog:GetNamedChild("Row5"):SetText(string.format("|cFFFFAARaffle Entries:|r  |cFFFF00%sg|r", NWT.FormatGold(member.raffleTotal or 0)))
    
    -- Row 6: Taxes (from sales)
    local taxes = gs.memberTaxTotals and gs.memberTaxTotals[member.name] or 0
    dialog:GetNamedChild("Row6"):SetText(string.format("|cFFFFAASales Taxes:|r  |cFF6600%sg|r", NWT.FormatGold(taxes)))
    
    -- Row 7: Total Income (deposits + taxes)
    local totalIncome = (member.totalDeposited or 0) + taxes
    dialog:GetNamedChild("Row7"):SetText(string.format("|cFFFFAATotal Income:|r  |c00FF00%sg|r", NWT.FormatGold(totalIncome)))
    
    -- Row 8: Last Payment
    local lastPayStr = (member.lastPayment or 0) > 0 and NWT.FormatTimeAgo(member.lastPayment) or "Never"
    dialog:GetNamedChild("Row8"):SetText(string.format("|cFFFFAALast Payment:|r  |c888888%s|r", lastPayStr))
    
    -- Row 9: Last Online
    local lastOnlineStr = member.lastOnline and member.lastOnline > 0 and NWT.FormatTimeAgo(member.lastOnline) or "Unknown"
    dialog:GetNamedChild("Row9"):SetText(string.format("|cFFFFAALast Online:|r  |c888888%s|r", lastOnlineStr))
    
    bk.memberDetailsOpen = true
    dialog:SetHidden(false)
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then 
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) 
    end
end

function NWT.CloseMemberDetails()
    if ATK_MemberDetailsDialog then ATK_MemberDetailsDialog:SetHidden(true) end
    NWT.Bookkeeper.memberDetailsOpen = nil
    if KEYBIND_STRIP and NWT.HiddenBookkeeperListScreen then 
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenBookkeeperListScreen.keybindStripDescriptor) 
    end
end

-- ============================================
-- AUTO-DEMOTION SYSTEM
-- ============================================

-- Calculate how much a member owes based on their effective dues
local function CalculateAmountOwed(memberData, guildSettings)
    local rankDuesAmount, rankPeriod = NWT.GetEffectiveDuesForRank(guildSettings, memberData.rankIndex)
    if rankDuesAmount <= 0 then return 0 end  -- Exempt
    
    -- Calculate periods owed based on their deposits vs expected
    local duesDeposited = memberData.duesTotal or 0
    local periodsPaid = math.floor(duesDeposited / rankDuesAmount)
    
    -- If they haven't paid this period, calculate what's owed
    if (memberData.thisWeekDues or 0) <= 0 and periodsPaid <= 0 then
        -- They owe at least one period + late fee if applicable
        local owed = rankDuesAmount
        if guildSettings.lateFeeEnabled and (guildSettings.lateFeeAmount or 0) > 0 then
            owed = owed + guildSettings.lateFeeAmount
        end
        return owed
    end
    return 0
end

-- Get list of members eligible for demotion
function NWT.GetDemotionCandidates(guildId)
    local gs = GetBookkeeperGuildSettings(guildId)
    if not gs.demotionRank then return {} end
    
    local candidates = {}
    local now = GetTimeStamp()
    local daysThreshold = gs.daysBeforeDemotion or 7
    local secondsThreshold = daysThreshold * 86400
    
    for name, m in pairs(gs.memberPayments or {}) do
        if m.isCurrentMember then
            local isLifetime = gs.lifetimeMembers and gs.lifetimeMembers[name]
            local isExempt = gs.exemptRanks and gs.exemptRanks[m.rankIndex]
            local alreadyDemoted = gs.demotedMembers and gs.demotedMembers[name]
            
            -- Skip if exempt, lifetime, or already demoted
            if not isLifetime and not isExempt and not alreadyDemoted then
                -- Check if overdue beyond threshold
                local isPaid = (m.thisWeekDues or 0) > 0 or (m.duesMonths or 0) > 0 or m.isPaidViaNote
                if not isPaid then
                    local lastPayment = m.lastPayment or 0
                    local daysSincePayment = lastPayment > 0 and math.floor((now - lastPayment) / 86400) or 999
                    
                    if daysSincePayment >= daysThreshold then
                        local amountOwed = CalculateAmountOwed(m, gs)
                        if amountOwed > 0 then
                            table.insert(candidates, {
                                name = name,
                                rankIndex = m.rankIndex,
                                rankName = GetGuildRankCustomName(guildId, m.rankIndex) or ("Rank " .. m.rankIndex),
                                amountOwed = amountOwed,
                                daysSincePayment = daysSincePayment,
                                memberIndex = m.memberIndex,
                            })
                        end
                    end
                end
            end
        end
    end
    
    -- Sort by days overdue (most overdue first)
    table.sort(candidates, function(a, b) return a.daysSincePayment > b.daysSincePayment end)
    return candidates
end

-- Preview demotions without executing
function NWT.PreviewDemotions(guildId)
    local candidates = NWT.GetDemotionCandidates(guildId)
    local gs = GetBookkeeperGuildSettings(guildId)
    
    if #candidates == 0 then
        NWT.Debug("|c00FF00[Bookkeeper]|r No members eligible for demotion")
        return
    end
    
    local demotionRankName = GetGuildRankCustomName(guildId, gs.demotionRank) or ("Rank " .. gs.demotionRank)
    NWT.Debug("|cFFFF00[Bookkeeper]|r " .. #candidates .. " member(s) eligible for demotion to " .. demotionRankName .. ":")
    
    -- Store for cycling through
    NWT.Bookkeeper.demotionPreview = candidates
    NWT.Bookkeeper.demotionPreviewIndex = 1
    NWT.Bookkeeper.demotionPreviewGuildId = guildId
    
    -- Show first candidate
    NWT.ShowDemotionPreview()
end

-- Show current demotion preview candidate
function NWT.ShowDemotionPreview()
    local bk = NWT.Bookkeeper
    local candidates = bk.demotionPreview
    if not candidates or #candidates == 0 then return end
    
    local idx = bk.demotionPreviewIndex or 1
    local c = candidates[idx]
    if not c then return end
    
    NWT.Debug(string.format("|cFFFF00[%d/%d]|r %s - |cFF6600%s|r overdue, owes |cFF0000%sg|r (was %s)",
        idx, #candidates, c.name, c.daysSincePayment .. "d", NWT.FormatGold(c.amountOwed), c.rankName))
end

-- Execute demotion for a single member
function NWT.DemoteMember(guildId, memberName, memberData)
    local gs = GetBookkeeperGuildSettings(guildId)
    if not gs.demotionRank then return false end
    
    -- Find member index in guild
    local memberIndex = nil
    local currentRank = nil
    for i = 1, GetNumGuildMembers(guildId) do
        local displayName = GetGuildMemberInfo(guildId, i)
        if displayName then
            if not displayName:find("^@") then displayName = "@" .. displayName end
            if displayName == memberName then
                memberIndex = i
                local _, _, rankIndex = GetGuildMemberInfo(guildId, i)
                currentRank = rankIndex
                break
            end
        end
    end
    
    if not memberIndex or not currentRank then return false end
    if currentRank == gs.demotionRank then return false end  -- Already at demotion rank
    
    -- Store original rank and demote
    if not gs.demotedMembers then gs.demotedMembers = {} end
    gs.demotedMembers[memberName] = {
        originalRank = currentRank,
        amountOwed = memberData.amountOwed or 0,
        demotedAt = GetTimeStamp(),
    }
    
    -- Set rank (requires permission)
    local success = pcall(function()
        SetGuildMemberRank(guildId, memberIndex, gs.demotionRank)
    end)
    
    if success then
        -- Update note to show amount owed
        local currentNote = select(2, GetGuildMemberInfo(guildId, memberIndex)) or ""
        local originalRankName = GetGuildRankCustomName(guildId, currentRank) or ("R" .. currentRank)
        local newNote = "Owe: " .. NWT.FormatGold(memberData.amountOwed) .. "g (was " .. originalRankName .. ")"
        pcall(function() SetGuildMemberNote(guildId, memberIndex, newNote) end)
        
        NWT.Debug("|cFF6600[Bookkeeper]|r Demoted " .. memberName .. " - owes " .. NWT.FormatGold(memberData.amountOwed) .. "g")
        return true
    end
    
    return false
end

-- Run all demotions
function NWT.RunDemotions(guildId)
    local candidates = NWT.GetDemotionCandidates(guildId)
    local gs = GetBookkeeperGuildSettings(guildId)
    
    if #candidates == 0 then
        NWT.Debug("|c00FF00[Bookkeeper]|r No members to demote")
        return
    end
    
    if not gs.demotionRank then
        NWT.Debug("|cFF0000[Bookkeeper]|r No demotion rank configured")
        return
    end
    
    local demoted = 0
    for _, c in ipairs(candidates) do
        if NWT.DemoteMember(guildId, c.name, c) then
            demoted = demoted + 1
        end
    end
    
    NWT.Debug("|cFF6600[Bookkeeper]|r Demoted " .. demoted .. " of " .. #candidates .. " members")
    NWT.UpdateDuesSettingsDialog()
    NWT.UpdateBookkeeperUI()
end

-- Restore a single demoted member
function NWT.RestoreMember(guildId, memberName)
    local gs = GetBookkeeperGuildSettings(guildId)
    local demotedInfo = gs.demotedMembers and gs.demotedMembers[memberName]
    if not demotedInfo then return false end
    
    -- Find member index
    local memberIndex = nil
    for i = 1, GetNumGuildMembers(guildId) do
        local displayName = GetGuildMemberInfo(guildId, i)
        if displayName then
            if not displayName:find("^@") then displayName = "@" .. displayName end
            if displayName == memberName then
                memberIndex = i
                break
            end
        end
    end
    
    if not memberIndex then return false end
    
    -- Restore original rank
    local success = pcall(function()
        SetGuildMemberRank(guildId, memberIndex, demotedInfo.originalRank)
    end)
    
    if success then
        gs.demotedMembers[memberName] = nil
        NWT.Debug("|c00FF00[Bookkeeper]|r Restored " .. memberName .. " to original rank")
        return true
    end
    
    return false
end

-- Restore all demoted members
function NWT.RestoreAllDemoted(guildId)
    local gs = GetBookkeeperGuildSettings(guildId)
    if not gs.demotedMembers then
        NWT.Debug("|c888888[Bookkeeper]|r No demoted members to restore")
        return
    end
    
    local restored = 0
    local total = 0
    for name, _ in pairs(gs.demotedMembers) do
        total = total + 1
        if NWT.RestoreMember(guildId, name) then
            restored = restored + 1
        end
    end
    
    NWT.Debug("|c00FF00[Bookkeeper]|r Restored " .. restored .. " of " .. total .. " demoted members")
    NWT.UpdateDuesSettingsDialog()
    NWT.UpdateBookkeeperUI()
end
