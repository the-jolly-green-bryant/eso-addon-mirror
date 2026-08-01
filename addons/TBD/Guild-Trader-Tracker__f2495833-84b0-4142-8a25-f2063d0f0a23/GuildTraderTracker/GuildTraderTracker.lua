GuildTraderTracker = GuildTraderTracker or {}
local GTT = GuildTraderTracker

GTT.name = "GuildTraderTracker"
GTT.savedVarName = "GuildTraderTrackerSavedVariables"
GTT.savedVarVersion = 1
GTT.maxLogEntries = 250

GTT.defaults = {
    settings = {
        probeEnabled = true,
        echoToChat = true,
    },
    probeLog = {},
}

GTT.probeEvents = {
    { name = "EVENT_OPEN_TRADING_HOUSE", constant = "EVENT_OPEN_TRADING_HOUSE" },
    { name = "EVENT_CLOSE_TRADING_HOUSE", constant = "EVENT_CLOSE_TRADING_HOUSE" },
    { name = "EVENT_TRADING_HOUSE_STATUS_RECEIVED", constant = "EVENT_TRADING_HOUSE_STATUS_RECEIVED" },
    { name = "EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE", constant = "EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE" },
    { name = "EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE", constant = "EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE" },
    { name = "EVENT_TRADING_HOUSE_AWAITING_RESPONSE", constant = "EVENT_TRADING_HOUSE_AWAITING_RESPONSE" },
    { name = "EVENT_TRADING_HOUSE_RESPONSE_TIMEOUT", constant = "EVENT_TRADING_HOUSE_RESPONSE_TIMEOUT" },
    { name = "EVENT_TRADING_HOUSE_RESPONSE_RECEIVED", constant = "EVENT_TRADING_HOUSE_RESPONSE_RECEIVED" },
    { name = "EVENT_TRADING_HOUSE_SELECTED_GUILD_CHANGED", constant = "EVENT_TRADING_HOUSE_SELECTED_GUILD_CHANGED" },
    { name = "EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED", constant = "EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED" },
    { name = "EVENT_TRADING_HOUSE_SEARCH_COOLDOWN_UPDATE", constant = "EVENT_TRADING_HOUSE_SEARCH_COOLDOWN_UPDATE" },
    { name = "EVENT_TRADING_HOUSE_ERROR", constant = "EVENT_TRADING_HOUSE_ERROR" },
    { name = "EVENT_TRADING_HOUSE_OPERATION_TIME_OUT", constant = "EVENT_TRADING_HOUSE_OPERATION_TIME_OUT" },
}

local function Print(message)
    d(string.format("[%s] %s", GTT.name, message))
end

local function SafeTrim(text)
    local value = tostring(text or "")
    value = value:gsub("^%s+", "")
    value = value:gsub("%s+$", "")
    return value
end

local function NormalizeText(text)
    local value = SafeTrim(text)
    if value == "" then
        return nil
    end

    if type(zo_strformat) == "function" then
        return zo_strformat("<<t:1>>", value)
    end

    return value
end

local function NormalizeItemText(text)
    local value = SafeTrim(text)
    if value == "" then
        return nil
    end

    if type(zo_strformat) == "function" then
        return zo_strformat("<<1>>", value)
    end

    return value
end

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end

    local ok, first, second, third, fourth, fifth, sixth, seventh, eighth = pcall(fn, ...)
    if not ok then
        return nil
    end

    return first, second, third, fourth, fifth, sixth, seventh, eighth
end

local function GetCurrentTimestamp()
    if type(GetTimeStamp) == "function" then
        local timestamp = tonumber(GetTimeStamp())
        if timestamp ~= nil and timestamp > 0 then
            return timestamp
        end
    end

    if type(os) == "table" and type(os.time) == "function" then
        return os.time()
    end

    return 0
end

local function FormatTimestamp(timestamp)
    local numericTimestamp = tonumber(timestamp)
    if numericTimestamp == nil or numericTimestamp <= 0 then
        return "n/a"
    end

    if type(GetDateStringFromTimestamp) == "function"
        and type(GetTimeStringFromTimestamp) == "function" then
        return string.format(
            "%s %s",
            GetDateStringFromTimestamp(numericTimestamp),
            GetTimeStringFromTimestamp(numericTimestamp)
        )
    end

    if type(os) == "table" and type(os.date) == "function" then
        return os.date("%Y-%m-%d %H:%M:%S", numericTimestamp)
    end

    return tostring(numericTimestamp)
end

local function SummarizeValue(value)
    local valueType = type(value)
    if value == nil then
        return "nil"
    end
    if valueType == "string" then
        local trimmed = SafeTrim(value)
        if trimmed == "" then
            return "\"\""
        end
        return string.format("%q", trimmed)
    end
    if valueType == "number" or valueType == "boolean" then
        return tostring(value)
    end
    if valueType == "table" then
        local count = 0
        for _ in pairs(value) do
            count = count + 1
        end
        return string.format("<table:%d>", count)
    end
    return string.format("<%s:%s>", valueType, tostring(value))
end

function GTT:EnsureSavedVariables()
    if type(self.sv.settings) ~= "table" then
        self.sv.settings = {}
    end
    if self.sv.settings.probeEnabled == nil then
        self.sv.settings.probeEnabled = true
    end
    if self.sv.settings.echoToChat == nil then
        self.sv.settings.echoToChat = true
    end
    if type(self.sv.probeLog) ~= "table" then
        self.sv.probeLog = {}
    end
end

function GTT:GetCurrentZoneSnapshot()
    local zoneId = nil
    local zoneName = nil

    if type(GetUnitZoneIndex) == "function" and type(GetZoneId) == "function" then
        local zoneIndex = GetUnitZoneIndex("player")
        if type(zoneIndex) == "number" and zoneIndex > 0 then
            local derivedZoneId = GetZoneId(zoneIndex)
            if type(derivedZoneId) == "number" and derivedZoneId > 0 then
                zoneId = derivedZoneId
            end
        end
    end

    if zoneId ~= nil and type(GetZoneNameById) == "function" then
        zoneName = NormalizeText(GetZoneNameById(zoneId))
    end

    local subzoneName = nil
    if type(GetPlayerActiveSubzoneName) == "function" then
        subzoneName = NormalizeText(GetPlayerActiveSubzoneName())
    end

    return {
        zoneId = zoneId,
        zoneName = zoneName,
        subzoneName = subzoneName,
    }
end

function GTT:GetCurrentGuildSnapshot()
    local guildId, guildName = SafeCall(GetCurrentTradingHouseGuildDetails)
    return {
        guildId = guildId,
        guildName = NormalizeText(guildName),
    }
end

function GTT:GetCurrentTraderSnapshot()
    local traderName = nil

    if type(GetRawUnitName) == "function" then
        traderName = NormalizeText(SafeCall(GetRawUnitName, "reticleover"))
        if traderName == nil then
            traderName = NormalizeText(SafeCall(GetRawUnitName, "interact"))
        end
    end

    if traderName == nil and type(GetUnitName) == "function" then
        traderName = NormalizeText(SafeCall(GetUnitName, "reticleover"))
        if traderName == nil then
            traderName = NormalizeText(SafeCall(GetUnitName, "interact"))
        end
    end

    return {
        traderName = traderName,
    }
end

function GTT:GetTradingHouseStateSnapshot()
    local snapshot = {}

    if type(IsTradingHouseOpen) == "function" then
        snapshot.isOpen = SafeCall(IsTradingHouseOpen)
    end

    if type(GetNumTradingHouseSearchResults) == "function" then
        snapshot.searchResultCount = SafeCall(GetNumTradingHouseSearchResults)
    end

    return snapshot
end

function GTT:GetSearchResultSnapshot(resultIndex)
    local numericIndex = tonumber(resultIndex)
    if numericIndex == nil or numericIndex <= 0 then
        return nil
    end

    if type(GetTradingHouseSearchResultItemInfo) ~= "function" then
        return nil
    end

    local _, itemName, _, stackCount, sellerName, timeRemaining, purchasePrice, currencyType =
        SafeCall(GetTradingHouseSearchResultItemInfo, numericIndex)
    local itemLink = nil
    if type(GetTradingHouseSearchResultItemLink) == "function" then
        itemLink = SafeCall(GetTradingHouseSearchResultItemLink, numericIndex)
    end

    return {
        resultIndex = numericIndex,
        itemName = NormalizeItemText(itemName),
        itemLink = itemLink,
        stackCount = tonumber(stackCount),
        sellerName = NormalizeText(sellerName),
        timeRemaining = timeRemaining,
        purchasePrice = tonumber(purchasePrice),
        currencyType = currencyType,
    }
end

function GTT:BuildContextSnapshot(eventName, argList)
    local snapshot = {
        eventName = eventName,
        zone = self:GetCurrentZoneSnapshot(),
        guild = self:GetCurrentGuildSnapshot(),
        trader = self:GetCurrentTraderSnapshot(),
        tradingHouse = self:GetTradingHouseStateSnapshot(),
    }

    local firstArg = argList[1]
    if eventName == "EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE"
        or eventName == "EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE" then
        snapshot.searchResult = self:GetSearchResultSnapshot(firstArg)
    end

    return snapshot
end

function GTT:TrimLog()
    while #self.sv.probeLog > self.maxLogEntries do
        table.remove(self.sv.probeLog, 1)
    end
end

function GTT:FormatContextLine(entry)
    local guildName = nil
    local traderName = nil
    local zoneName = nil

    if type(entry.snapshot) == "table" then
        if type(entry.snapshot.guild) == "table" then
            guildName = entry.snapshot.guild.guildName
        end
        if type(entry.snapshot.trader) == "table" then
            traderName = entry.snapshot.trader.traderName
        end
        if type(entry.snapshot.zone) == "table" then
            zoneName = entry.snapshot.zone.subzoneName or entry.snapshot.zone.zoneName
        end
    end

    local parts = {}
    if guildName ~= nil then
        table.insert(parts, "guild=" .. guildName)
    end
    if traderName ~= nil then
        table.insert(parts, "trader=" .. traderName)
    end
    if zoneName ~= nil then
        table.insert(parts, "zone=" .. zoneName)
    end

    if type(entry.snapshot) == "table" and type(entry.snapshot.searchResult) == "table" then
        local searchResult = entry.snapshot.searchResult
        if searchResult.itemName ~= nil then
            table.insert(parts, "item=" .. searchResult.itemName)
        end
        if searchResult.purchasePrice ~= nil then
            table.insert(parts, "price=" .. tostring(searchResult.purchasePrice))
        end
    end

    if #parts == 0 then
        return "no context"
    end

    return table.concat(parts, " | ")
end

function GTT:StoreProbeEvent(eventName, ...)
    if not self.sv.settings.probeEnabled then
        return
    end

    local argList = { ... }
    local argSummary = {}
    for index = 1, #argList do
        argSummary[index] = SummarizeValue(argList[index])
    end

    local entry = {
        timestamp = GetCurrentTimestamp(),
        eventName = eventName,
        args = argSummary,
        snapshot = self:BuildContextSnapshot(eventName, argList),
    }

    table.insert(self.sv.probeLog, entry)
    self:TrimLog()

    if self.sv.settings.echoToChat then
        Print(string.format(
            "probe %s | args: %s | %s",
            entry.eventName,
            #entry.args > 0 and table.concat(entry.args, ", ") or "none",
            self:FormatContextLine(entry)
        ))
    end
end

function GTT:RegisterProbeEvents()
    for _, eventInfo in ipairs(self.probeEvents) do
        local eventCode = _G[eventInfo.constant]
        if type(eventCode) == "number" then
            EVENT_MANAGER:RegisterForEvent(self.name .. eventInfo.name, eventCode, function(_, ...)
                self:StoreProbeEvent(eventInfo.name, ...)
            end)
        end
    end
end

function GTT:PrintSnapshot()
    local snapshot = {
        timestamp = GetCurrentTimestamp(),
        eventName = "MANUAL_SNAPSHOT",
        args = {},
        snapshot = self:BuildContextSnapshot("MANUAL_SNAPSHOT", {}),
    }

    Print(string.format(
        "snapshot | %s | %s",
        FormatTimestamp(snapshot.timestamp),
        self:FormatContextLine(snapshot)
    ))
end

function GTT:ShowRecentEvents(limit)
    local entries = self.sv.probeLog
    if #entries == 0 then
        Print("Probe log is empty.")
        return
    end

    local numericLimit = math.max(1, math.floor(tonumber(limit) or 10))
    local shown = 0
    for index = #entries, 1, -1 do
        local entry = entries[index]
        shown = shown + 1
        Print(string.format(
            "%d. %s | %s | args: %s | %s",
            shown,
            FormatTimestamp(entry.timestamp),
            entry.eventName,
            #entry.args > 0 and table.concat(entry.args, ", ") or "none",
            self:FormatContextLine(entry)
        ))
        if shown >= numericLimit then
            break
        end
    end
end

function GTT:ClearProbeLog()
    self.sv.probeLog = {}
    Print("Probe log cleared.")
end

function GTT:ShowHelp()
    Print("Guild Trader Tracker commands:")
    Print("/gtt - show current status")
    Print("/gtt help - show this help")
    Print("/gtt probe on - enable probe logging")
    Print("/gtt probe off - disable probe logging")
    Print("/gtt probe echo on|off - toggle chat echo")
    Print("/gtt probe show [count] - print recent probe events")
    Print("/gtt probe clear - clear saved probe log")
    Print("/gtt probe snapshot - print current trading house context")
end

function GTT:HandleProbeCommand(words, startIndex)
    local command = string.lower(words[startIndex] or "")

    if command == "" then
        Print(string.format(
            "Probe is %s, chat echo is %s, saved events: %d. Use /gtt help.",
            self.sv.settings.probeEnabled and "on" or "off",
            self.sv.settings.echoToChat and "on" or "off",
            #self.sv.probeLog
        ))
        return
    end

    if command == "help" then
        self:ShowHelp()
        return
    end

    if command == "on" then
        self.sv.settings.probeEnabled = true
        Print("Probe logging enabled.")
        return
    end

    if command == "off" then
        self.sv.settings.probeEnabled = false
        Print("Probe logging disabled.")
        return
    end

    if command == "echo" then
        local value = string.lower(words[startIndex + 1] or "")
        if value == "on" then
            self.sv.settings.echoToChat = true
            Print("Probe chat echo enabled.")
        elseif value == "off" then
            self.sv.settings.echoToChat = false
            Print("Probe chat echo disabled.")
        else
            Print("Usage: /gtt probe echo on|off")
        end
        return
    end

    if command == "show" then
        self:ShowRecentEvents(words[startIndex + 1] or 10)
        return
    end

    if command == "clear" then
        self:ClearProbeLog()
        return
    end

    if command == "snapshot" then
        self:PrintSnapshot()
        return
    end

    Print(string.format("Unknown probe command '%s'. Use /gtt help.", command))
end

function GTT:HandleSlashCommand(argumentText)
    local text = SafeTrim(argumentText)
    if text == "" then
        Print(string.format(
            "Probe is %s, chat echo is %s, saved events: %d. Use /gtt help.",
            self.sv.settings.probeEnabled and "on" or "off",
            self.sv.settings.echoToChat and "on" or "off",
            #self.sv.probeLog
        ))
        return
    end

    local words = {}
    for token in text:gmatch("%S+") do
        table.insert(words, token)
    end

    local command = string.lower(words[1] or "")
    if command == "help" then
        self:ShowHelp()
        return
    end

    if command == "probe" then
        self:HandleProbeCommand(words, 2)
        return
    end

    Print(string.format("Unknown command '%s'. Use /gtt help.", command))
end

function GTT:Initialize()
    self.sv = ZO_SavedVars:NewAccountWide(
        self.savedVarName,
        self.savedVarVersion,
        nil,
        self.defaults
    )
    self:EnsureSavedVariables()
    self:RegisterProbeEvents()

    SLASH_COMMANDS["/gtt"] = function(text)
        self:HandleSlashCommand(text)
    end

    Print("Loaded in probe mode. Use /gtt help.")
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= GTT.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(GTT.name, EVENT_ADD_ON_LOADED)
    GTT:Initialize()
end

EVENT_MANAGER:RegisterForEvent(GTT.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
