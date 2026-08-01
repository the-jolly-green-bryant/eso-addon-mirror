LootLog = LootLog or {}
local LL = LootLog
local SUMMARY_TOP_ENTRY_LIMIT = 10

local SCOPE_DISPLAY_NAMES = {
    session = "Session",
    manual = "Last reset",
    lifetime = "All time",
}

local function GetScopeDisplayName(scopeName)
    return SCOPE_DISPLAY_NAMES[scopeName] or scopeName
end

local function GetIndexedString(stringId, index)
    local numericIndex = tonumber(index)
    if type(GetString) ~= "function" or numericIndex == nil then
        return nil
    end

    local ok, value = pcall(GetString, stringId, numericIndex)
    if not ok or type(value) ~= "string" or value == "" then
        return nil
    end

    return value
end

local function GetInteractionTotal(bucket)
    if not bucket or type(bucket.instances) ~= "table" then
        return 0
    end

    local total = tonumber(bucket.instances.Total)
    if total then
        return total
    end

    total = 0
    for _, value in pairs(bucket.instances) do
        total = total + (tonumber(value) or 0)
    end
    return total
end

local function GetCurrencyStartedAt(bucket)
    if not bucket then
        return 0
    end
    return tonumber(bucket.currencyStartedAt) or 0
end

local function PrintGeneralSummary()
    LL.EnsureSession()
    LL.EnsureSaved()

    LL.Print("Loot Log summary")

    local totalAddOnMemoryPoolUsageMB = LL.GetTotalAddOnMemoryPoolUsageMB()
    if totalAddOnMemoryPoolUsageMB ~= nil then
        LL.Print(string.format("Total addon memory pool: %.1f MB", totalAddOnMemoryPoolUsageMB))
    end

    local luaMemoryUsageMB = LL.GetLuaMemoryUsageMB()
    if luaMemoryUsageMB ~= nil then
        LL.Print(string.format("Lua memory: %.1f MB", luaMemoryUsageMB))
    end

    local addOnSavedVariablesDiskUsageMB = LL.GetAddOnSavedVariablesDiskUsageMB()
    if addOnSavedVariablesDiskUsageMB ~= nil then
        LL.Print(string.format("Addon saved vars on disk: %.1f MB", addOnSavedVariablesDiskUsageMB))
    end

    local unusedAddOnSavedVariablesDiskUsageMB = LL.GetUnusedAddOnSavedVariablesDiskUsageMB()
    if unusedAddOnSavedVariablesDiskUsageMB ~= nil then
        LL.Print(string.format("Unused addon saved vars on disk: %.1f MB", unusedAddOnSavedVariablesDiskUsageMB))
    end

    local scopes = {
        { name = GetScopeDisplayName("session"), bucket = LL.session },
        { name = GetScopeDisplayName("manual"), bucket = LL.saved.manual },
        { name = GetScopeDisplayName("lifetime"), bucket = LL.saved.lifetime },
    }

    for _, scope in ipairs(scopes) do
        local footprint = LL.GetBucketFootprintSummary(scope.bucket)
        LL.Print(string.format(
            "%s: started %s | currencies since %s | %d item keys | %d currencies | %d interactions | approx. %s",
            scope.name,
            LL.FormatTimestamp(scope.bucket.startedAt),
            LL.FormatTimestamp(GetCurrencyStartedAt(scope.bucket)),
            footprint.itemCount,
            footprint.currencyCount,
            GetInteractionTotal(scope.bucket),
            LL.FormatApproximateBytes(footprint.totalBytes)
        ))
    end

    LL.Print("Use /lootlog session, /lootlog manual, or /lootlog lifetime for detailed listings.")
end

local function PrintScope(scopeName, bucket)
    bucket = bucket or { items = {}, currencyByReason = {}, instances = {}, startedAt = 0 }
    local currencyTotals = LL.GetBucketCurrencyTotals(bucket)
    local footprint = LL.GetBucketFootprintSummary(bucket)
    LL.Print(string.format("%s loot summary", scopeName))
    LL.Print(string.format("Started: %s", LL.FormatTimestamp(bucket.startedAt)))
    LL.Print(string.format("Currencies started: %s", LL.FormatTimestamp(GetCurrencyStartedAt(bucket))))
    LL.Print(string.format(
        "Approx. data footprint: %s (%d item keys, %d currencies, %d interaction counters)",
        LL.FormatApproximateBytes(footprint.totalBytes),
        footprint.itemCount,
        footprint.currencyCount,
        footprint.interactionCount
    ))
    LL.PrintCounts("Items", bucket.items, "x", SUMMARY_TOP_ENTRY_LIMIT)
    LL.PrintCurrencyCounts("Currencies", currencyTotals, SUMMARY_TOP_ENTRY_LIMIT)
    LL.PrintCurrencyCountsByReason("Currencies By Reason", bucket.currencyByReason, SUMMARY_TOP_ENTRY_LIMIT, SUMMARY_TOP_ENTRY_LIMIT)
    LL.PrintCounts("Loot Interactions", bucket.instances, "x")
end

local function ResetScope(scopeName)
    if scopeName == "session" then
        LL.EnsureSession()
        LL.ResetBucket(LL.session)
        LL.RefreshUI()
        LL.Print("Session counters reset.")
        return
    end
    if scopeName == "manual" then
        LL.EnsureSaved()
        LL.ResetBucket(LL.saved.manual)
        LL.RefreshUI()
        LL.Print("Manual counters reset.")
        return
    end
    if scopeName == "lifetime" then
        LL.EnsureSaved()
        LL.ResetBucket(LL.saved.lifetime)
        LL.RefreshUI()
        LL.Print("Lifetime counters reset.")
        return
    end
    LL.Print("Usage: /lootlog reset session|manual|lifetime")
end

local function GetScopeBucket(scopeName)
    if scopeName == "session" then
        LL.EnsureSession()
        return LL.session, GetScopeDisplayName("session")
    end
    if scopeName == "manual" then
        LL.EnsureSaved()
        return LL.saved.manual, GetScopeDisplayName("manual")
    end
    if scopeName == "lifetime" then
        LL.EnsureSaved()
        return LL.saved.lifetime, GetScopeDisplayName("lifetime")
    end
    return nil, nil
end

local function CollectSampleKeys(bucket)
    local keys = {}
    if not bucket or type(bucket.items) ~= "table" then
        return keys
    end

    for itemKey in pairs(bucket.items) do
        keys[#keys + 1] = itemKey
    end

    return keys
end

local function SelectRandomSample(keys, limit)
    local count = #keys
    if count <= 1 or limit >= count then
        return keys
    end

    for index = 1, limit do
        local swapIndex = math.random(index, count)
        keys[index], keys[swapIndex] = keys[swapIndex], keys[index]
    end

    local sample = {}
    for index = 1, limit do
        sample[index] = keys[index]
    end
    return sample
end

local function FormatItemType(value)
    local numeric = tonumber(value)
    if numeric == nil then
        return tostring(value)
    end

    local displayName = GetIndexedString("SI_ITEMTYPE", numeric)
    if displayName then
        return string.format("%d (%s)", numeric, displayName)
    end

    return tostring(numeric)
end

local function FormatSpecializedItemType(value)
    local numeric = tonumber(value)
    if numeric == nil then
        return tostring(value)
    end

    local displayName = GetIndexedString("SI_SPECIALIZEDITEMTYPE", numeric)
    if displayName then
        return string.format("%d (%s)", numeric, displayName)
    end

    return tostring(numeric)
end

local function FormatFilterType(value)
    local numeric = tonumber(value)
    if numeric == nil then
        return tostring(value)
    end

    local displayName = GetIndexedString("SI_ITEMFILTERTYPE", numeric)
    if displayName then
        return string.format("%d (%s)", numeric, displayName)
    end

    return tostring(numeric)
end

local function FormatFilterTypeInfo(values)
    if not values or #values == 0 then
        return "n/a"
    end

    local parts = {}
    for index = 1, #values do
        parts[#parts + 1] = string.format("%d=%s", index, FormatFilterType(values[index]))
    end
    return table.concat(parts, ", ")
end

local function DebugCategorySample(scopeName, sampleCount)
    local bucket, label = GetScopeBucket(scopeName)
    if not bucket then
        LL.Print("Usage: /lootlog debug categories [session|manual|lifetime] [count]")
        return
    end

    local keys = CollectSampleKeys(bucket)
    if #keys == 0 then
        LL.Print(string.format("%s has no tracked items to sample.", label))
        return
    end

    local totalCount = #keys
    local limit = math.min(math.max(tonumber(sampleCount) or 5, 1), totalCount)
    keys = SelectRandomSample(keys, limit)
    LL.Print(string.format("Category sample from %s (%d of %d items)", label, limit, totalCount))

    for index = 1, limit do
        local itemLink = keys[index]
        local displayName = itemLink
        if type(GetItemLinkName) == "function" then
            local resolvedName = GetItemLinkName(itemLink)
            if resolvedName and resolvedName ~= "" then
                displayName = resolvedName
            end
        end

        local itemId = type(GetItemLinkItemId) == "function" and GetItemLinkItemId(itemLink) or "n/a"
        local quality = type(GetItemLinkDisplayQuality) == "function" and GetItemLinkDisplayQuality(itemLink)
            or (type(GetItemLinkQuality) == "function" and GetItemLinkQuality(itemLink) or "n/a")
        local itemType = "n/a"
        local specializedItemType = "n/a"
        if type(GetItemLinkItemType) == "function" then
            itemType, specializedItemType = GetItemLinkItemType(itemLink)
            itemType = itemType or "n/a"
            specializedItemType = specializedItemType or "n/a"
        end
        local filterTypeInfo = type(GetItemLinkFilterTypeInfo) == "function" and { GetItemLinkFilterTypeInfo(itemLink) } or nil

        LL.Print(string.format(
            "  [%d] %s | itemId=%s quality=%s itemType=%s specializedType=%s filterTypeInfo={%s}",
            index,
            tostring(displayName),
            tostring(itemId),
            tostring(quality),
            FormatItemType(itemType),
            FormatSpecializedItemType(specializedItemType),
            FormatFilterTypeInfo(filterTypeInfo)
        ))
    end
end

function LL.HandleSlashCommand(rawText)
    local text = (rawText or ""):lower()
    if text == "" then
        PrintGeneralSummary()
        return
    end
    if text == "session" then
        PrintScope(GetScopeDisplayName("session"), LL.session)
        return
    end
    if text == "manual" then
        PrintScope(GetScopeDisplayName("manual"), LL.saved.manual)
        return
    end
    if text == "lifetime" then
        PrintScope(GetScopeDisplayName("lifetime"), LL.saved.lifetime)
        return
    end
    if text == "ui" then
        LL.ToggleUI()
        return
    end
    if text == "ui show" or text == "show" then
        LL.ShowUI()
        return
    end
    if text == "ui hide" or text == "hide" then
        LL.HideUI()
        return
    end
    local _, _, uiScaleText = string.find(text, "^ui%s+scale%s+([0-9%.]+)$")
    if uiScaleText then
        local uiScale = tonumber(uiScaleText)
        if not uiScale then
            LL.Print("Usage: /lootlog ui scale <0.8 - 2.0>")
            return
        end
        LL.SetUIScale(uiScale)
        LL.Print(string.format("UI scale set to %.2f", LL.saved.settings.uiScale))
        LL.ShowUI()
        return
    end
    if text == "reset session" or text == "reset manual" or text == "reset lifetime" then
        local _, _, scopeName = string.find(text, "^reset%s+(%S+)$")
        ResetScope(scopeName)
        return
    end
    if text == "debug on" then
        LL.saved.settings.debug = true
        LL.Print("Debug logging enabled.")
        return
    end
    if text == "debug off" then
        LL.saved.settings.debug = false
        LL.Print("Debug logging disabled.")
        return
    end
    if text == "debug" then
        local state = LL.saved.settings.debug and "on" or "off"
        LL.Print(string.format("Debug is %s. Use /lootlog debug on|off", state))
        return
    end
    local _, _, categoryScope, categoryCount = string.find(text, "^debug%s+categories%s*(%S*)%s*(%S*)$")
    if categoryScope ~= nil then
        if categoryScope == "" then
            categoryScope = "lifetime"
        end
        DebugCategorySample(categoryScope, categoryCount)
        return
    end
    if text == "probe on" then
        LL.saved.settings.eventProbe = true
        LL.Print("Event probe enabled.")
        return
    end
    if text == "probe off" then
        LL.saved.settings.eventProbe = false
        LL.Print("Event probe disabled.")
        return
    end
    if text == "probe" then
        local state = LL.saved.settings.eventProbe and "on" or "off"
        LL.Print(string.format("Event probe is %s. Use /lootlog probe on|off", state))
        return
    end

    LL.Print("Commands:")
    LL.Print("  /lootlog")
    LL.Print("  /lootlog session")
    LL.Print("  /lootlog manual")
    LL.Print("  /lootlog lifetime")
    LL.Print("  /lootlog ui")
    LL.Print("  /lootlog ui show|hide")
    LL.Print("  /lootlog ui scale <0.8 - 2.0>")
    LL.Print("  /lootlog reset session")
    LL.Print("  /lootlog reset manual")
    LL.Print("  /lootlog reset lifetime")
    LL.Print("  /lootlog debug on|off")
    LL.Print("  /lootlog debug categories [session|manual|lifetime] [count]")
    LL.Print("  /lootlog probe on|off")
end
