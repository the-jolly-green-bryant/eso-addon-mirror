-- ============================================
-- BOOKKEEPER DATA OPERATIONS
-- ============================================
-- Shared helpers: GetGuildSettings, guild toggle/favorite, rank exemption, raffle period formatting.
-- Exposed as NWT.BookkeeperData_* for use by Commands and Dashboard.

local BC = NWT.BookkeeperConstants
local FREE_TRADER_DEFAULT_TARGET = BC and BC.FREE_TRADER_DEFAULT_TARGET or 30
local NOTE_FORMAT_TEMPLATES = BC and BC.NOTE_FORMAT_TEMPLATES or { range = "{START}-{END} Upd:{UPD}", due = "Due: {END} Upd:{UPD}", paid = "Paid thru {END} Upd:{UPD}" }
local DEMO_MEMBERS = BC and BC.DEMO_MEMBERS or {}

local function GetDefaultBookkeeperSettings()
    return {
        duesAmount = 5000,
        duesPeriod = "weekly",
        customDaysPeriod = 7,
        duesSuffix = 0,
        raffleSuffixes = {1, 5},
        ticketPrice = 1000,
        rafflePeriodId = "all",
        gracePeriodDays = 3,
        lateFeeEnabled = false,
        lateFeeAmount = 0,
        exemptRanks = {},
        rankDuesOverride = {},
        autoDemoteEnabled = false,
        demotionRank = nil,
        daysBeforeDemotion = 7,
        originalRanks = {},
        demotedMembers = {},
        autoUpdateNotes = false,
        noteFormat = "range",
        includeUpdateTimestamp = true,
        alertUnpaidCount = 0,
        alertOnLogin = false,
        highlightOverdue = true,
        lifetimeMembers = {},
        specialSuffixes = {},
        memberPayments = {},
        paymentHistory = {},
        pastWinners = {},
        salesData = {},
        lastScanTime = 0,
        lastNotesScan = 0,
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
end

local function CleanupPaymentHistory(gs)
    if not gs.paymentHistory then return end
    for memberName, ph in pairs(gs.paymentHistory) do
        if ph.payments then
            local validPayments = {}
            for _, payment in ipairs(ph.payments) do
                local dueMonth = tonumber(payment.dueMonth) or 0
                local dueDay = tonumber(payment.dueDay) or 0
                local dueYear = tonumber(payment.dueYear) or 0
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
    if type(sv.bookkeeper) ~= "table" then sv.bookkeeper = {} end
    if type(sv.bookkeeper.guilds) ~= "table" then sv.bookkeeper.guilds = {} end
    if type(sv.bookkeeper.guilds[guildId]) ~= "table" then
        sv.bookkeeper.guilds[guildId] = GetDefaultBookkeeperSettings()
    end
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
    CleanupPaymentHistory(gs)
    return gs
end

local function IsGuildEnabled(guildId)
    local sv = NWT.savedVars
    if type(sv.bookkeeper) ~= "table" then sv.bookkeeper = {} end
    if type(sv.bookkeeper.enabledGuilds) ~= "table" then sv.bookkeeper.enabledGuilds = {} end
    if sv.bookkeeper.enabledGuilds[guildId] == nil then
        sv.bookkeeper.enabledGuilds[guildId] = true
    end
    return sv.bookkeeper.enabledGuilds[guildId]
end

local function ToggleGuildEnabled(guildId)
    local sv = NWT.savedVars
    if type(sv.bookkeeper) ~= "table" then sv.bookkeeper = {} end
    if type(sv.bookkeeper.enabledGuilds) ~= "table" then sv.bookkeeper.enabledGuilds = {} end
    sv.bookkeeper.enabledGuilds[guildId] = not sv.bookkeeper.enabledGuilds[guildId]
    return sv.bookkeeper.enabledGuilds[guildId]
end

local function IsGuildFavorite(guildId)
    local sv = NWT.savedVars
    if type(sv.bookkeeper) ~= "table" then sv.bookkeeper = {} end
    if type(sv.bookkeeper.favoriteGuilds) ~= "table" then sv.bookkeeper.favoriteGuilds = {} end
    return sv.bookkeeper.favoriteGuilds[guildId] == true
end

local function ToggleGuildFavorite(guildId)
    local sv = NWT.savedVars
    if type(sv.bookkeeper) ~= "table" then sv.bookkeeper = {} end
    if type(sv.bookkeeper.favoriteGuilds) ~= "table" then sv.bookkeeper.favoriteGuilds = {} end
    sv.bookkeeper.favoriteGuilds[guildId] = not sv.bookkeeper.favoriteGuilds[guildId]
    return sv.bookkeeper.favoriteGuilds[guildId]
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
    local exemptType = guildSettings.exemptRanks and guildSettings.exemptRanks[rankIndex]
    return exemptType ~= nil and exemptType ~= false
end

local function ParseDepositType(amount, guildSettings)
    local duesAmount = guildSettings.duesAmount or 5000
    local lastDigit = amount % 10
    for _, suffix in ipairs(guildSettings.raffleSuffixes or {}) do
        local suffixNum = tonumber(suffix) or suffix
        if lastDigit == suffixNum then return "raffle", amount end
    end
    if duesAmount > 0 and amount >= duesAmount then
        local periods = math.floor(amount / duesAmount)
        return "dues", periods
    end
    return "other", amount
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

local function ParseDateString(dateStr)
    if not dateStr then return nil end
    local m, d, y = dateStr:match("(%d+)[/%-%.]+(%d+)[/%-%.]+(%d+)")
    if not m then return nil end
    m, d, y = tonumber(m), tonumber(d), tonumber(y)
    if not m or not d or not y then return nil end
    if y < 100 then y = y + 2000 end
    if m < 1 or m > 12 or d < 1 or d > 31 or y < 2020 or y > 2100 then return nil end
    return os.time({year = y, month = m, day = d, hour = 0, min = 0, sec = 0})
end

local function FormatShortDate(timestamp)
    if not timestamp or timestamp == 0 then return "" end
    return os.date("%m/%d/%y", timestamp):gsub("^0", ""):gsub("/0", "/")
end

local function BuildPatternFromTemplate(template)
    if not template or template == "" then return nil, nil end
    local datePattern = "(%d+[/%-%.]+%d+[/%-%.]*%d*)"
    local pattern = template:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    local captureOrder = {}
    local placeholders = { "{START}", "{END}", "{UPD}" }
    local placeholderNames = { ["{START}"] = "start", ["{END}"] = "end", ["{UPD}"] = "upd" }
    local positions = {}
    for _, ph in ipairs(placeholders) do
        local pos = template:find(ph, 1, true)
        if pos then
            table.insert(positions, { pos = pos, ph = ph, name = placeholderNames[ph] })
        end
    end
    table.sort(positions, function(a, b) return a.pos < b.pos end)
    for _, p in ipairs(positions) do
        table.insert(captureOrder, p.name)
        local escapedPh = p.ph:gsub("([{}])", "%%%1")
        pattern = pattern:gsub(escapedPh, datePattern, 1)
    end
    return pattern, captureOrder
end

local function ParseDueDateFromNote(note, guildSettings)
    if not note or note == "" then return nil end
    if not note:find("%d") then return nil end
    local result = { startDate = nil, endDate = nil, lastUpdate = nil }
    local gs = guildSettings
    if gs and gs.noteFormat == "custom" and gs.customNoteFormat and gs.customNoteFormat ~= "" then
        local pattern, captureOrder = BuildPatternFromTemplate(gs.customNoteFormat)
        if pattern and #captureOrder > 0 then
            local captures = { note:match(pattern) }
            if #captures > 0 then
                for i, name in ipairs(captureOrder) do
                    if captures[i] then
                        if name == "start" then result.startDate = ParseDateString(captures[i])
                        elseif name == "end" then result.endDate = ParseDateString(captures[i])
                        elseif name == "upd" then result.lastUpdate = ParseDateString(captures[i]) end
                    end
                end
                if result.startDate or result.endDate then return result end
            end
        end
    end
    local d1, d2 = note:match("(%d+/%d+/%d+)%-(%d+/%d+/%d+)")
    if d1 and d2 then
        result.startDate = ParseDateString(d1)
        result.endDate = ParseDateString(d2)
        return result
    end
    local dueDate = note:match("[Dd]ue:?%s*(%d+/%d+/%d+)")
    if dueDate then
        result.endDate = ParseDateString(dueDate)
        return result
    end
    local thruDate = note:match("[Tt]hru%s*(%d+/%d+/%d+)")
    if thruDate then
        result.endDate = ParseDateString(thruDate)
        return result
    end
    local updDate = note:match("[Uu]pd:?%s*(%d+/%d+/%d+)")
    if updDate then result.lastUpdate = ParseDateString(updDate) end
    return result
end

local function GetLastNoteUpdate(guildId, memberName)
    local sv = NWT.savedVars
    if type(sv.bookkeeper) ~= "table" then return nil end
    if type(sv.bookkeeper.noteUpdates) ~= "table" then return nil end
    if type(sv.bookkeeper.noteUpdates[guildId]) ~= "table" then return nil end
    local ts = sv.bookkeeper.noteUpdates[guildId][memberName]
    if ts and type(ts) == "number" and ts > 0 and ts <= GetTimeStamp() + 86400 then return ts end
    if ts then sv.bookkeeper.noteUpdates[guildId][memberName] = nil end
    return nil
end

local function SetLastNoteUpdate(guildId, memberName, timestamp)
    local sv = NWT.savedVars
    if type(sv.bookkeeper) ~= "table" then sv.bookkeeper = {} end
    if type(sv.bookkeeper.noteUpdates) ~= "table" then sv.bookkeeper.noteUpdates = {} end
    if type(sv.bookkeeper.noteUpdates[guildId]) ~= "table" then sv.bookkeeper.noteUpdates[guildId] = {} end
    sv.bookkeeper.noteUpdates[guildId][memberName] = timestamp
end

local function GetSavedDueDate(guildId, memberName)
    local sv = NWT.savedVars
    if type(sv.bookkeeper) ~= "table" then return nil end
    if type(sv.bookkeeper.dueDates) ~= "table" then return nil end
    if type(sv.bookkeeper.dueDates[guildId]) ~= "table" then return nil end
    local dueDate = sv.bookkeeper.dueDates[guildId][memberName]
    if dueDate and type(dueDate) == "number" and dueDate > 0 then return dueDate end
    return nil
end

local function SetSavedDueDate(guildId, memberName, dueDate)
    local sv = NWT.savedVars
    if type(sv.bookkeeper) ~= "table" then sv.bookkeeper = {} end
    if type(sv.bookkeeper.dueDates) ~= "table" then sv.bookkeeper.dueDates = {} end
    if type(sv.bookkeeper.dueDates[guildId]) ~= "table" then sv.bookkeeper.dueDates[guildId] = {} end
    sv.bookkeeper.dueDates[guildId][memberName] = dueDate
end

local function ParsePaymentDateFromNote(note)
    if not note or note == "" then return nil end
    local result = { paidDate = nil, dueDate = nil, isLifetime = false, rawNote = note }
    local noteLower = note:lower()
    if noteLower:find("lifetime") or noteLower:match("%f[%a]life%f[%A]") then
        result.isLifetime = true
        return result
    end
    local m, d, y = noteLower:match("due[:%s]*(%d+)[/%-]+(%d+)[/%-]*(%d*)")
    if m and d then result.dueDate = { month = tonumber(m), day = tonumber(d), year = y ~= "" and tonumber(y) or nil } end
    if not result.dueDate then
        m, d, y = noteLower:match("(%d+)[/%-%.]+(%d+)[/%-%.]*(%d*)%s*due")
        if m and d then result.dueDate = { month = tonumber(m), day = tonumber(d), year = y ~= "" and tonumber(y) or nil } end
    end
    m, d, y = noteLower:match("paid[:%s]*(%d+)[/%-]+(%d+)[/%-]*(%d*)")
    if m and d then result.paidDate = { month = tonumber(m), day = tonumber(d), year = y ~= "" and tonumber(y) or nil } end
    if not result.paidDate then
        m, d, y = noteLower:match("(%d+)[/%-%.]+(%d+)[/%-%.]*(%d*)%s*paid")
        if m and d then result.paidDate = { month = tonumber(m), day = tonumber(d), year = y ~= "" and tonumber(y) or nil } end
    end
    if not result.dueDate then
        m, d, y = noteLower:match("thru[gh]*[:%s]*(%d+)[/%-%.]+(%d+)[/%-%.]*(%d*)")
        if m and d then result.dueDate = { month = tonumber(m), day = tonumber(d), year = y ~= "" and tonumber(y) or nil } end
    end
    local m1, d1, y1, m2, d2, y2 = note:match("(%d+)[/%-%.]+(%d+)[/%-%.]*(%d*)%s*[%-–]+%s*(%d+)[/%-%.]+(%d+)[/%-%.]*(%d*)")
    if m1 and d1 and m2 and d2 then
        result.paidDate = { month = tonumber(m1), day = tonumber(d1), year = y1 ~= "" and tonumber(y1) or nil }
        result.dueDate = { month = tonumber(m2), day = tonumber(d2), year = y2 ~= "" and tonumber(y2) or nil }
    end
    if result.paidDate or result.dueDate then return result end
    return nil
end

local function GetDemoSettings()
    if not NWT.Bookkeeper.demoSettings then
        NWT.Bookkeeper.demoSettings = {
            duesAmount = 5000, duesPeriod = "weekly", customDaysPeriod = 7, duesSuffix = 0,
            raffleSuffixes = {1, 5}, ticketPrice = 1000, gracePeriodDays = 3, lateFeeEnabled = false, lateFeeAmount = 0,
            exemptRanks = { [1] = true }, rankDuesOverride = {}, autoUpdateNotes = false, noteFormat = "range",
            includeUpdateTimestamp = true, alertUnpaidCount = 0, alertOnLogin = false, highlightOverdue = true,
            lifetimeMembers = { ["@TreasurerCarl"] = true, ["@LifetimeLisa"] = true }, specialSuffixes = {},
            memberPayments = {}, lastScanTime = GetTimeStamp() - 3600, traderFlipDay = 3, sortBy = "status",
            showOfflineStatus = false, freeTraderMode = false, listingTarget = FREE_TRADER_DEFAULT_TARGET,
            memberListingCounts = {}, listingsLastScanTime = 0, listingsScanInProgress = false, listingsLastFailureTime = 0,
        }
        for _, m in ipairs(DEMO_MEMBERS) do
            local demoListings = math.max(0, math.min(FREE_TRADER_DEFAULT_TARGET, ((m.duesMonths or 0) * 3) + ((m.thisWeekDues or 0) * 2)))
            NWT.Bookkeeper.demoSettings.memberListingCounts[m.name] = demoListings
            NWT.Bookkeeper.demoSettings.memberPayments[m.name] = {
                name = m.name, totalDeposited = m.totalDeposited, duesMonths = m.duesMonths, raffleTotal = m.raffleTotal,
                otherTotal = m.otherTotal, lastPayment = m.lastPayment, thisWeekDues = m.thisWeekDues,
                thisWeekRaffle = m.raffleTotal > 0 and math.floor(m.raffleTotal / 4) or 0, deposits = {},
                rankIndex = m.rankIndex, isCurrentMember = true, isExemptRank = m.isExemptRank or false, listingsCount = demoListings,
            }
        end
    end
    if type(NWT.Bookkeeper.demoSettings.memberListingCounts) ~= "table" then NWT.Bookkeeper.demoSettings.memberListingCounts = {} end
    if type(NWT.Bookkeeper.demoSettings.listingTarget) ~= "number" or NWT.Bookkeeper.demoSettings.listingTarget < 1 then
        NWT.Bookkeeper.demoSettings.listingTarget = FREE_TRADER_DEFAULT_TARGET
    end
    if NWT.Bookkeeper.demoSettings.freeTraderMode ~= true then NWT.Bookkeeper.demoSettings.freeTraderMode = false end
    if type(NWT.Bookkeeper.demoSettings.listingsLastScanTime) ~= "number" then NWT.Bookkeeper.demoSettings.listingsLastScanTime = 0 end
    if NWT.Bookkeeper.demoSettings.listingsScanInProgress ~= true then NWT.Bookkeeper.demoSettings.listingsScanInProgress = false end
    if type(NWT.Bookkeeper.demoSettings.listingsLastFailureTime) ~= "number" then NWT.Bookkeeper.demoSettings.listingsLastFailureTime = 0 end
    return NWT.Bookkeeper.demoSettings
end

local function GetDepositsSince(memberData, sinceTimestamp, guildSettings)
    if not memberData or not memberData.deposits then return 0, 0 end
    local duesTotal, count = 0, 0
    local now = GetTimeStamp()
    for _, dep in ipairs(memberData.deposits) do
        local ts, amt = dep.timestamp, dep.amount
        if ts and type(ts) == "number" and ts > 0 and ts <= now + 86400 and amt and type(amt) == "number" and amt > 0 then
            if ts > sinceTimestamp and dep.type == "dues" then duesTotal = duesTotal + amt; count = count + 1 end
        end
    end
    return duesTotal, count
end

local function CalculateNewDueDate(currentEndDate, duesDeposited, guildSettings)
    local duesAmount = guildSettings.duesAmount or 5000
    if duesAmount <= 0 then return currentEndDate end
    local periodsCovered = math.floor(duesDeposited / duesAmount)
    if periodsCovered <= 0 then return currentEndDate end
    local startDate = currentEndDate or GetTimeStamp()
    if startDate < GetTimeStamp() then startDate = GetTimeStamp() end
    local daysPerPeriod = 7
    if guildSettings.duesPeriod == "biweekly" then daysPerPeriod = 14
    elseif guildSettings.duesPeriod == "monthly" then daysPerPeriod = 30
    elseif guildSettings.duesPeriod == "custom" then daysPerPeriod = guildSettings.customDaysPeriod or 7 end
    return startDate + (periodsCovered * daysPerPeriod * 86400)
end

local function ExtractCustomNotePortion(note)
    if not note or note == "" then return nil end
    local cleaned = note
    cleaned = cleaned:gsub("%d+[/%-%.]+%d+[/%-%.]*%d*%s*[%-–]+%s*%d+[/%-%.]+%d+[/%-%.]*%d*", "")
    cleaned = cleaned:gsub("[Uu]pd[ate]*[ed]*[:%s]*%d+[/%-%.]+%d+[/%-%.]*%d*", "")
    cleaned = cleaned:gsub("[Dd]ue[:%s]*%d+[/%-%.]+%d+[/%-%.]*%d*", "")
    cleaned = cleaned:gsub("[Pp]aid%s*[Tt]hru[gh]*[:%s]*%d+[/%-%.]+%d+[/%-%.]*%d*", "")
    cleaned = cleaned:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
    if cleaned == "" then return nil end
    return cleaned
end

local function FormatDuesNote(startDate, endDate, existingNote, guildSettings)
    local startStr = FormatShortDate(startDate or GetTimeStamp())
    local endStr = FormatShortDate(endDate)
    local updStr = FormatShortDate(GetTimeStamp())
    local template
    local gs = guildSettings or {}
    local format = gs.noteFormat or "range"
    if format == "custom" and gs.customNoteFormat and gs.customNoteFormat ~= "" then
        template = gs.customNoteFormat
    else
        template = NOTE_FORMAT_TEMPLATES[format] or NOTE_FORMAT_TEMPLATES.range
    end
    local duesPortion = template:gsub("{START}", startStr):gsub("{END}", endStr):gsub("{UPD}", updStr)
    local customPortion = ExtractCustomNotePortion(existingNote)
    if customPortion then return duesPortion .. " " .. customPortion end
    return duesPortion
end

-- Public accessors for Commands and Dashboard
NWT.BookkeeperData_GetGuildSettings = GetBookkeeperGuildSettings
NWT.BookkeeperData_IsGuildEnabled = IsGuildEnabled
NWT.BookkeeperData_ToggleGuildEnabled = ToggleGuildEnabled
NWT.BookkeeperData_IsGuildFavorite = IsGuildFavorite
NWT.BookkeeperData_ToggleGuildFavorite = ToggleGuildFavorite
NWT.BookkeeperData_IsRankExempt = IsRankExempt
NWT.BookkeeperData_FormatRafflePeriod = FormatRafflePeriod
NWT.BookkeeperData_GetRafflePeriodPresets = GetRafflePeriodPresets
NWT.BookkeeperData_GetRafflePeriodTimes = GetRafflePeriodTimes
NWT.BookkeeperData_GetDemoSettings = GetDemoSettings
NWT.BookkeeperData_IsFreeTraderMode = IsFreeTraderMode
NWT.BookkeeperData_GetListingTarget = GetListingTarget
NWT.BookkeeperData_GetCurrentTraderFlipStart = GetCurrentTraderFlipStart
NWT.BookkeeperData_NormalizeDisplayName = NormalizeDisplayName
NWT.BookkeeperData_ParseDepositType = ParseDepositType
NWT.BookkeeperData_ParseDateString = ParseDateString
NWT.BookkeeperData_FormatShortDate = FormatShortDate
NWT.BookkeeperData_BuildPatternFromTemplate = BuildPatternFromTemplate
NWT.BookkeeperData_ParseDueDateFromNote = ParseDueDateFromNote
NWT.BookkeeperData_GetLastNoteUpdate = GetLastNoteUpdate
NWT.BookkeeperData_SetLastNoteUpdate = SetLastNoteUpdate
NWT.BookkeeperData_GetSavedDueDate = GetSavedDueDate
NWT.BookkeeperData_SetSavedDueDate = SetSavedDueDate
NWT.BookkeeperData_ParsePaymentDateFromNote = ParsePaymentDateFromNote
NWT.BookkeeperData_GetDepositsSince = GetDepositsSince
NWT.BookkeeperData_CalculateNewDueDate = CalculateNewDueDate
NWT.BookkeeperData_ExtractCustomNotePortion = ExtractCustomNotePortion
NWT.BookkeeperData_FormatDuesNote = FormatDuesNote

function NWT.GetEffectiveDuesForRank(guildSettings, rankIndex)
    if not guildSettings then return 5000, "weekly" end
    if guildSettings.exemptRanks and guildSettings.exemptRanks[rankIndex] then return 0, nil end
    local override = guildSettings.rankDuesOverride and guildSettings.rankDuesOverride[rankIndex]
    if override and type(override) == "table" then
        local amount = override.amount or guildSettings.duesAmount or 5000
        local period = override.period or guildSettings.duesPeriod or "weekly"
        return amount, period
    elseif override and type(override) == "number" then
        return override, guildSettings.duesPeriod or "weekly"
    end
    return guildSettings.duesAmount or 5000, guildSettings.duesPeriod or "weekly"
end
