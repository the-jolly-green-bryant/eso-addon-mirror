NWT = {}
NWT.name = "ContainerHighlighter"
NWT.ui = {}
NWT.initialized = false
NWT.uiVisible = false

-- ============================================
-- DEBUG TOGGLE - Set to false to disable chat messages
-- ============================================
NWT.DEBUG_ENABLED = false

-- Debug print function (silenced to prevent chat spam / Error 318)
function NWT.Debug(msg)
    return
end

-- ============================================
-- AUTHORIZATION TOGGLE
-- ============================================
NWT.REQUIRE_AUTHORIZATION = false

-- Authorization whitelist
NWT.AUTHORIZED_USERS = {
    ["@Tekatsu23"] = true,
    ["@Mithril0704"] = true,
    ["@TheDirtNap18"] = true,
    ["@Arcane Deez"] = true,
    ["@Arcane Deez^Fx"] = true,
    ["@ArcaneDeez"] = true,
    ["Arcane Deez"] = true,
    ["Arcane Deez^Fx"] = true,
    ["@ifiwasurmotha"] = true,
    ["ifiwasurmotha"] = true,
    ["@IfIWasUrMotha"] = true,
    ["IfIWasUrMotha"] = true,
    ["@IFIWASURMOTHA"] = true,
    ["IFIWASURMOTHA"] = true,
}
NWT.isAuthorized = false

NWT.netWorth = {
    inventory = 0,
    bank = 0,
    craftBag = 0,
    furnitureVault = 0,
    myHousing = 0,
    visitingHouse = 0,
    guildBanks = 0,
    gold = 0,
    crowns = 0,
    crownsAsGold = 0,
    crownGems = 0,
    crownStoreItems = 0,
    crownCrateItems = 0,
    total = 0,
}

NWT.topItems = {}

function NWT.CheckAuthorization()
    if not NWT.REQUIRE_AUTHORIZATION then
        NWT.isAuthorized = true
        return true
    end
    
    local displayName = GetDisplayName()
    NWT.isAuthorized = NWT.AUTHORIZED_USERS[displayName] == true
    if not NWT.isAuthorized then
NWT.Debug("|cFFFF00[Adventurer's Toolkit]|r This addon is currently under development.")
NWT.Debug("|cFFFF00[Adventurer's Toolkit]|r Display Name: |cFFFFFF" .. tostring(displayName) .. "|r")
NWT.Debug("|cFFFF00[Adventurer's Toolkit]|r Only Net Worth (/nw) is available. Other features are disabled.")
    end
    return NWT.isAuthorized
end

NWT.defaults = {
    features = {
        netWorth = true,
        guildSalesTracker = true,
        planBrowser = true,
        housingDashboard = true,
        lootLog = true,
        goldLedger = true,
        fishingTracker = true,
        lootRadar = true,
        bookkeeper = true,
        raffle = true,
        pvpDashboard = true,
    },
    includeBank = true,
    includeCraftBag = true,
    includeFurnitureVault = true,
    includeMyHousing = true,
    includeCrownsAsGold = true,
    crownToGoldRate = 100,
    lastFurnitureVaultValue = 0,
    myHousingValues = {},
    guildBankValues = {},
    enabledGuildBanks = {},
    savedTopItems = {},
    gstGuildNames = {},
    gstGuildEnabled = {},
    gstGuildSnapshots = {},
    gstCurrentGuild = nil,
    furnitureCache = {},
    fishingEnabled = false,
    fishingSessionFish = 0,
    fishingSessionStart = 0,
    fishingTotalFish = 0,
    fishingSessionRare = 0,
    fishingSessionPerfect = 0,
    housingHudEnabled = true,
    housingStats = {},
    wishlist = {
        projects = {
            ["Default"] = {},
        },
        activeProject = "Default",
    },
    knownPlans = {},
    planBrowser = {
        colorblindMode = "normal",
    },
    planIconCache = {},
    bookkeeper = {
        enabledGuilds = {},
        favoriteGuilds = {},
        guilds = {},
        noteUpdates = {},
    },
    goldLedger = {
        today = {
            income = { guildSales = 0, vendorSales = 0, loot = 0, mail = 0, quests = 0, other = 0 },
            expenses = { guildPurchases = 0, guildListingFee = 0, vendorPurchases = 0, repairs = 0, travel = 0, mail = 0, bagBank = 0, respec = 0, other = 0 },
        },
        allTime = { income = 0, expenses = 0 },
        lastResetTimestamp = 0,
    },
    lootLog = {
        today = {
            items = {},
            goldLooted = 0,
            totalValue = 0,
            itemCount = 0,
        },
        lastResetTimestamp = 0,
        history = {},
    },
    lootRadar = {
        containers = {},
        discoveryCount = 0,
    },
    debugMode = false,
}

function NWT.GetColors()
    local mode = NWT.savedVars and NWT.savedVars.planBrowser and NWT.savedVars.planBrowser.colorblindMode or "normal"
    
    if mode == "protanopia" then
        return { positive = "0096FF", negative = "FFD700", warning = "FF9900", success = "0096FF", error = "FFD700" }
    elseif mode == "deuteranopia" then
        return { positive = "0096FF", negative = "FF6600", warning = "FFCC00", success = "0096FF", error = "FF6600" }
    elseif mode == "tritanopia" then
        return { positive = "00CC00", negative = "FF0066", warning = "FFFF00", success = "00CC00", error = "FF0066" }
    else
        return { positive = "00FF00", negative = "FF0000", warning = "FFFF00", success = "00FF00", error = "FF0000" }
    end
end

function NWT.GetFont(size)
    if IsInGamepadPreferredMode() then
        return size == "large" and "ZoFontGamepadBold27" or "ZoFontGamepad22"
    else
        return size == "large" and "ZoFontWinH1" or "ZoFontWinH3"
    end
end

function NWT.FormatGold(amount)
    return ZO_CommaDelimitNumber(math.floor(amount or 0))
end

function NWT.FormatGoldLedger(amount)
    if amount >= 1000000 then
        return string.format("%.1fm", amount / 1000000)
    elseif amount >= 1000 then
        return string.format("%.1fk", amount / 1000)
    else
        return tostring(amount)
    end
end

function NWT.FormatTimestamp(timestamp)
    if not timestamp or timestamp == 0 then return "N/A" end
    local dateTable = os.date("*t", timestamp)
    return string.format("%d/%d/%d", dateTable.month, dateTable.day, dateTable.year % 100)
end

function NWT.FormatTimeAgo(ts)
    if not ts or ts == 0 then return "Never" end
    local age = GetTimeStamp() - ts
    if age < 3600 then return math.floor(age / 60) .. "m ago"
    elseif age < 86400 then return math.floor(age / 3600) .. "h ago"
    else return math.floor(age / 86400) .. "d ago" end
end

function NWT.NonContiguousCount(t)
    local count = 0
    if not t then return 0 end
    for _ in pairs(t) do count = count + 1 end
    return count
end

function NWT.GetPrice(itemLink)
    if not itemLink then return nil end
    if not ATPriceDataXBNA or not ATPriceDataXBNA.priceData then return nil end
    local itemId = GetItemLinkItemId(itemLink)
    local data = nil
    if itemId then
        data = ATPriceDataXBNA.priceData[itemId]
    end
    if not data then
        local itemName = GetItemLinkName(itemLink)
        if itemName then
            itemName = string.gsub(itemName, "%%^.*$", "")
            data = ATPriceDataXBNA.priceData[itemName]
        end
    end
    if not data then return nil end
    if type(data) == "string" then
        local avg = tonumber(string.match(data, "^([^,]+)"))
        if avg then return math.floor(avg * 1.2) end
    end
    return nil
end
