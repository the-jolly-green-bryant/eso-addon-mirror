LootLog = LootLog or {}
local LL = LootLog

function LL.Print(message)
    d(string.format("[%s] %s", LL.name, message))
end

local APPROX_TABLE_BASE_BYTES = 40
local APPROX_ENTRY_OVERHEAD_BYTES = 24
local APPROX_NUMBER_BYTES = 8
local APPROX_BOOLEAN_BYTES = 4

function LL.DebugPrint(message)
    if LL.saved and LL.saved.settings and LL.saved.settings.debug then
        LL.Print(string.format("[debug] %s", message))
    end
end

function LL.Increment(t, key, amount)
    if not key or key == "" then
        return
    end

    local nextValue = (t[key] or 0) + (amount or 0)
    if nextValue > 0 then
        t[key] = nextValue
    end
end

local function ApproximateStringBytes(value)
    if value == nil then
        return 0
    end
    return #tostring(value)
end

local function ApproximateScalarBytes(value)
    local valueType = type(value)
    if valueType == "number" then
        return APPROX_NUMBER_BYTES
    end
    if valueType == "boolean" then
        return APPROX_BOOLEAN_BYTES
    end
    if valueType == "string" then
        return ApproximateStringBytes(value)
    end
    return ApproximateStringBytes(value)
end

local function CountMapEntries(map)
    if type(map) ~= "table" then
        return 0
    end

    local entries = 0
    for _ in pairs(map) do
        entries = entries + 1
    end

    return entries
end

local function ApproximateMapBytes(map)
    if type(map) ~= "table" then
        return 0
    end

    local bytes = APPROX_TABLE_BASE_BYTES
    for key, value in pairs(map) do
        bytes = bytes
            + APPROX_ENTRY_OVERHEAD_BYTES
            + ApproximateScalarBytes(key)
            + ApproximateScalarBytes(value)
    end

    return bytes
end

local function CountNestedMapEntries(map)
    if type(map) ~= "table" then
        return 0
    end

    local entries = 0
    for key, nestedMap in pairs(map) do
        entries = entries + 1
        entries = entries + CountMapEntries(nestedMap)
    end

    return entries
end

local function ApproximateNestedMapBytes(map)
    if type(map) ~= "table" then
        return 0
    end

    local bytes = APPROX_TABLE_BASE_BYTES
    for key, nestedMap in pairs(map) do
        bytes = bytes + APPROX_ENTRY_OVERHEAD_BYTES + ApproximateScalarBytes(key)

        local nestedBytes = ApproximateMapBytes(nestedMap)
        bytes = bytes + nestedBytes
    end

    return bytes
end

local function SortedEntries(countTable)
    local entries = {}
    for name, count in pairs(countTable) do
        entries[#entries + 1] = {
            name = name,
            count = count,
        }
    end

    table.sort(entries, function(a, b)
        if a.count == b.count then
            return a.name < b.name
        end
        return a.count > b.count
    end)

    return entries
end

function LL.PrintCounts(title, countTable, valueLabel, maxEntries)
    local entries = SortedEntries(countTable)
    local limit = tonumber(maxEntries)
    if limit then
        limit = math.max(0, math.floor(limit))
    end

    if limit and #entries > limit then
        LL.Print(string.format("%s: %d (showing top %d)", title, #entries, limit))
    else
        LL.Print(string.format("%s: %d", title, #entries))
    end

    if #entries == 0 then
        LL.Print("  (none)")
        return
    end

    local lastIndex = limit and math.min(#entries, limit) or #entries
    for index = 1, lastIndex do
        local entry = entries[index]
        LL.Print(string.format("  %d %s - %s", entry.count, valueLabel, entry.name))
    end
end

function LL.GetCurrencyDisplayName(currencyType)
    local numeric = tonumber(currencyType)
    if numeric == nil then
        return tostring(currencyType)
    end

    if type(GetCurrencyName) == "function" then
        local ok, displayName = pcall(GetCurrencyName, numeric, false, false)
        if ok and type(displayName) == "string" and displayName ~= "" then
            return displayName
        end
    end

    if type(GetString) == "function" then
        local ok, displayName = pcall(GetString, "SI_CURRENCYTYPE", numeric)
        if ok and type(displayName) == "string" and displayName ~= "" then
            return displayName
        end
    end

    return tostring(numeric)
end

function LL.GetCurrencyChangeReasonDisplayName(reason)
    local numeric = tonumber(reason)
    if numeric == nil then
        return tostring(reason)
    end

    local constantName = LL.CurrencyChangeReasonNames and LL.CurrencyChangeReasonNames[numeric]
    if type(constantName) == "string" and constantName ~= "" then
        return constantName
    end

    return tostring(numeric)
end

function LL.GetBucketCurrencyTotals(bucket)
    local totals = {}
    if type(bucket) ~= "table" then
        return totals
    end

    if type(bucket.currencyByReason) == "table" then
        for _, currencyMap in pairs(bucket.currencyByReason) do
            if type(currencyMap) == "table" then
                for currencyType, amount in pairs(currencyMap) do
                    LL.Increment(totals, currencyType, tonumber(amount) or 0)
                end
            end
        end
    end

    return totals
end

function LL.PrintCurrencyCountsByReason(title, currencyByReason, maxReasons, maxCurrenciesPerReason)
    local reasonEntries = {}
    if type(currencyByReason) == "table" then
        for reason, currencyMap in pairs(currencyByReason) do
            if type(currencyMap) == "table" then
                local currencies = {}
                local totalAmount = 0
                for currencyType, amount in pairs(currencyMap) do
                    local numericAmount = tonumber(amount)
                    if numericAmount and numericAmount > 0 then
                        totalAmount = totalAmount + numericAmount
                        currencies[#currencies + 1] = {
                            amount = numericAmount,
                            name = LL.GetCurrencyDisplayName(currencyType),
                        }
                    end
                end

                if #currencies > 0 then
                    table.sort(currencies, function(a, b)
                        if a.amount == b.amount then
                            return a.name < b.name
                        end
                        return a.amount > b.amount
                    end)

                    reasonEntries[#reasonEntries + 1] = {
                        reason = tonumber(reason) or reason,
                        reasonName = LL.GetCurrencyChangeReasonDisplayName(reason),
                        totalAmount = totalAmount,
                        currencies = currencies,
                    }
                end
            end
        end
    end

    table.sort(reasonEntries, function(a, b)
        if a.totalAmount == b.totalAmount then
            return tostring(a.reasonName) < tostring(b.reasonName)
        end
        return a.totalAmount > b.totalAmount
    end)

    local reasonLimit = tonumber(maxReasons)
    if reasonLimit then
        reasonLimit = math.max(0, math.floor(reasonLimit))
    end

    if reasonLimit and #reasonEntries > reasonLimit then
        LL.Print(string.format("%s: %d (showing top %d reasons)", title, #reasonEntries, reasonLimit))
    else
        LL.Print(string.format("%s: %d", title, #reasonEntries))
    end

    if #reasonEntries == 0 then
        LL.Print("  (none)")
        return
    end

    local currencyLimit = tonumber(maxCurrenciesPerReason)
    if currencyLimit then
        currencyLimit = math.max(0, math.floor(currencyLimit))
    end

    local lastReasonIndex = reasonLimit and math.min(#reasonEntries, reasonLimit) or #reasonEntries
    for reasonIndex = 1, lastReasonIndex do
        local reasonEntry = reasonEntries[reasonIndex]
        if currencyLimit and #reasonEntry.currencies > currencyLimit then
            LL.Print(string.format(
                "  %s - %d (showing top %d currencies)",
                reasonEntry.reasonName,
                reasonEntry.totalAmount,
                currencyLimit
            ))
        else
            LL.Print(string.format("  %s - %d", reasonEntry.reasonName, reasonEntry.totalAmount))
        end

        local lastCurrencyIndex = currencyLimit and math.min(#reasonEntry.currencies, currencyLimit) or #reasonEntry.currencies
        for currencyIndex = 1, lastCurrencyIndex do
            local currencyEntry = reasonEntry.currencies[currencyIndex]
            LL.Print(string.format("    %d - %s", currencyEntry.amount, currencyEntry.name))
        end
    end
end

function LL.PrintCurrencyCounts(title, currencyTable, maxEntries)
    local entries = {}
    if type(currencyTable) == "table" then
        for currencyType, amount in pairs(currencyTable) do
            local numericAmount = tonumber(amount)
            if numericAmount and numericAmount > 0 then
                entries[#entries + 1] = {
                    amount = numericAmount,
                    name = LL.GetCurrencyDisplayName(currencyType),
                }
            end
        end
    end

    table.sort(entries, function(a, b)
        if a.amount == b.amount then
            return a.name < b.name
        end
        return a.amount > b.amount
    end)

    local limit = tonumber(maxEntries)
    if limit then
        limit = math.max(0, math.floor(limit))
    end

    if limit and #entries > limit then
        LL.Print(string.format("%s: %d (showing top %d)", title, #entries, limit))
    else
        LL.Print(string.format("%s: %d", title, #entries))
    end

    if #entries == 0 then
        LL.Print("  (none)")
        return
    end

    local lastIndex = limit and math.min(#entries, limit) or #entries
    for index = 1, lastIndex do
        local entry = entries[index]
        LL.Print(string.format("  %d - %s", entry.amount, entry.name))
    end
end

function LL.FormatApproximateBytes(bytes)
    local numeric = tonumber(bytes) or 0
    if numeric < 1024 then
        return string.format("~%d B", math.floor(numeric + 0.5))
    end
    if numeric < (1024 * 1024) then
        return string.format("~%.1f KB", numeric / 1024)
    end
    return string.format("~%.2f MB", numeric / (1024 * 1024))
end

function LL.GetBucketFootprintSummary(bucket)
    bucket = bucket or {}
    local currencyTotals = LL.GetBucketCurrencyTotals(bucket)

    local itemBytes = ApproximateMapBytes(bucket.items)
    local itemCount = CountMapEntries(bucket.items)
    local currencyCount = CountMapEntries(currencyTotals)
    local currencyByReasonBytes = ApproximateNestedMapBytes(bucket.currencyByReason)
    local currencyByReasonCount = CountNestedMapEntries(bucket.currencyByReason)
    local interactionBytes = ApproximateMapBytes(bucket.instances)
    local interactionCount = CountMapEntries(bucket.instances)
    local startedAtBytes = ApproximateScalarBytes(bucket.startedAt)
    local totalBytes = itemBytes + currencyByReasonBytes + interactionBytes + startedAtBytes

    return {
        itemCount = itemCount,
        currencyCount = currencyCount,
        currencyByReasonCount = currencyByReasonCount,
        interactionCount = interactionCount,
        totalBytes = totalBytes,
    }
end

function LL.GetTotalAddOnMemoryPoolUsageMB()
    if type(GetTotalUserAddOnMemoryPoolUsageMB) ~= "function" then
        return nil
    end

    local ok, value = pcall(GetTotalUserAddOnMemoryPoolUsageMB)
    if not ok then
        return nil
    end

    local numeric = tonumber(value)
    if numeric == nil or numeric < 0 then
        return nil
    end

    return numeric
end

function LL.GetLuaMemoryUsageMB()
    if type(collectgarbage) ~= "function" then
        return nil
    end

    local ok, value = pcall(collectgarbage, "count")
    if not ok then
        return nil
    end

    local numeric = tonumber(value)
    if numeric == nil or numeric < 0 then
        return nil
    end

    return numeric / 1024
end

local function GetAddOnManager()
    if type(AddOnManager) == "table" then
        return AddOnManager
    end
    if type(ADD_ON_MANAGER) == "table" then
        return ADD_ON_MANAGER
    end
    return nil
end

local function CallAddOnManagerNumeric(methodName)
    local addOnManager = GetAddOnManager()
    local method = addOnManager and addOnManager[methodName]
    if type(method) ~= "function" then
        return nil
    end

    local ok, value = pcall(method, addOnManager)
    if not ok then
        ok, value = pcall(method)
        if not ok then
            return nil
        end
    end

    local numeric = tonumber(value)
    if numeric == nil or numeric < 0 then
        return nil
    end

    return numeric
end

function LL.GetAddOnSavedVariablesDiskUsageMB()
    return CallAddOnManagerNumeric("GetUserAddOnSavedVariablesDiskUsageMB")
end

function LL.GetUnusedAddOnSavedVariablesDiskUsageMB()
    return CallAddOnManagerNumeric("GetTotalUnusedAddOnSavedVariablesDiskUsageMB")
end

function LL.GetCurrentTimestamp()
    if type(GetTimeStamp) == "function" then
        return GetTimeStamp()
    end
    if type(os) == "table" and type(os.time) == "function" then
        return os.time()
    end
    return 0
end

function LL.FormatTimestamp(timestamp)
    local numericTimestamp = tonumber(timestamp)
    if not numericTimestamp or numericTimestamp <= 0 then
        return "n/a"
    end

    if type(GetDateStringFromTimestamp) == "function" and type(GetTimeStringFromTimestamp) == "function" then
        return string.format("%s %s", GetDateStringFromTimestamp(numericTimestamp), GetTimeStringFromTimestamp(numericTimestamp))
    end

    if type(os) == "table" and type(os.date) == "function" then
        return os.date("%Y-%m-%d %H:%M:%S", numericTimestamp)
    end

    return tostring(numericTimestamp)
end

function LL.NormalizeDisplayName(rawName)
    if not rawName or rawName == "" then
        return nil
    end

    if type(zo_strformat) == "function" then
        return zo_strformat("<<t:1>>", rawName)
    end

    return rawName
end
