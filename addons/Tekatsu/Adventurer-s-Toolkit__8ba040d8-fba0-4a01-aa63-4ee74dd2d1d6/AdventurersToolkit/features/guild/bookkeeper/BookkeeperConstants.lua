-- ============================================
-- BOOKKEEPER CONSTANTS AND STATE
-- ============================================
-- Extracted from BookkeeperDashboard for modular split.

NWT.Bookkeeper = NWT.Bookkeeper or {
    isOpen = false,
    sceneInitialized = false,
    selectedGuildIndex = 1,
    viewingGuildIndex = 1,
    selectedMemberIndex = 1,
    memberScrollOffset = 0,
    maxVisibleMembers = 13,
    sortedMembers = {},
    isScanning = false,
    isHistoryScanning = false,
    historyScanGuildId = nil,
    historyScanQueue = {},
    filterMode = 1,
    filterModes = {"All Members", "Unpaid Only", "Paid Only", "Name A-Z", "Name Z-A", "Last Paid"},
    searchText = "",
    focusPanel = "dues",
    selectedActionIndex = 1,
    salesScrollOffset = 0,
    maxVisibleSales = 12,
    activeGuilds = {},
    demoMode = false,
}
NWT.Bookkeeper.demoSettings = nil

NWT.BookkeeperConstants = NWT.BookkeeperConstants or {}
local BC = NWT.BookkeeperConstants

BC.FREE_TRADER_DEFAULT_TARGET = 30

BC.NOTE_FORMAT_TEMPLATES = {
    range = "{START}-{END} Upd:{UPD}",
    due = "Due: {END} Upd:{UPD}",
    paid = "Paid thru {END} Upd:{UPD}",
}

BC.QUICK_ACTIONS = {
    { id = "settings", label = "Dues Settings", callback = function() NWT.BookkeeperShowDuesSettings() end },
    { id = "details", label = "View Details", callback = function() NWT.ShowMemberDetails() end },
    { id = "updateNote", label = "Update Note", callback = function() NWT.BookkeeperUpdateMemberNote() end },
    { id = "setRank", label = "Set Rank", callback = function() NWT.BookkeeperShowRankMenu() end },
    { id = "kick", label = "|cFF4444Kick Member|r", callback = function() NWT.BookkeeperKickMember() end },
}

BC.DEMO_MEMBERS = {
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

BC.DEMO_RANKS = {
    { name = "Guild Master", index = 1 },
    { name = "Officer", index = 2 },
    { name = "Veteran", index = 3 },
    { name = "Member", index = 4 },
    { name = "Recruit", index = 5 },
}

BC.DEMO_GUILDS = {
    { id = 0, name = "Demo Trading Guild", memberCount = 500, isFavorite = true },
    { id = -1, name = "Demo Social Guild", memberCount = 150, isFavorite = false },
    { id = -2, name = "Demo PvP Guild", memberCount = 75, isFavorite = false },
}

NWT.DUES_SETTINGS_TABS = NWT.DUES_SETTINGS_TABS or {
    { id = "dues", label = "DUES" },
    { id = "periods", label = "PERIODS" },
    { id = "ranks", label = "RANKS" },
    { id = "enforce", label = "ENFORCE" },
    { id = "notes", label = "NOTES" },
    { id = "actions", label = "ACTIONS" },
}

BC.DUES_AMOUNT_OPTIONS = {1000, 2000, 2500, 5000, 7500, 10000, 15000, 20000, 25000, 30000, 50000, 100000}
BC.PERIOD_OPTIONS = {"weekly", "biweekly", "monthly", "custom"}
BC.GRACE_PERIOD_OPTIONS = {0, 1, 2, 3, 5, 7, 14}
BC.NOTE_FORMAT_OPTIONS = {"range", "due", "paid", "custom"}
BC.SORT_OPTIONS = {"status", "name", "rank", "lastPaid", "amount"}
BC.RANK_PERIOD_OPTIONS = {"weekly", "biweekly", "monthly", "yearly"}
BC.RANK_PERIOD_LABELS = {weekly = "Weekly", biweekly = "Bi-Weekly", monthly = "Monthly", yearly = "Yearly"}
BC.RANK_PERIOD_SHORT = {weekly = "wk", biweekly = "bw", monthly = "mo", yearly = "yr"}
