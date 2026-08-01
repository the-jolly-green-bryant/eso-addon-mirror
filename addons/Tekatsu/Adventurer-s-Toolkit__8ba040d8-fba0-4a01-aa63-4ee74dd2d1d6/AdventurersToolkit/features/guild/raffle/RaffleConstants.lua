-- ============================================
-- RAFFLE CONSTANTS / SHARED STATE
-- ============================================

NWT.Raffle = NWT.Raffle or {
    isOpen = false,
    sceneInitialized = false,
    selectedGuildIndex = 1,
    viewingGuildIndex = 1,
    raffleScrollOffset = 0,
    maxVisibleRaffle = 15,
    focusPanel = "guilds",
    raffleEntriesCount = 0,
    sortedEntries = {},
    demoSettings = nil,
}

NWT.RaffleConstants_DEMO_MEMBERS = {
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

NWT.RaffleConstants_DEMO_RANKS = {
    [1] = "Guild Master",
    [2] = "Officer",
    [3] = "Veteran",
    [4] = "Member",
    [5] = "Initiate",
}
