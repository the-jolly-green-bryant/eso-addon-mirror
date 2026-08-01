LootLog = LootLog or {}
local LL = LootLog

function LL.KeepOnlyTotalInteractions(bucket)
    if not bucket then
        return
    end

    local totalInteractions = type(bucket.instances) == "table" and (tonumber(bucket.instances.Total) or 0) or 0
    bucket.instances = {}
    if totalInteractions > 0 then
        bucket.instances.Total = totalInteractions
    end
end

local function EnsureBucket(bucket)
    bucket.items = bucket.items or {}
    if type(bucket.currencyByReason) ~= "table" then
        bucket.currencyByReason = {}
    end
    if type(bucket.instances) ~= "table" then
        bucket.instances = {}
    end
    if not bucket.startedAt or tonumber(bucket.startedAt) == nil or tonumber(bucket.startedAt) <= 0 then
        bucket.startedAt = LL.GetCurrentTimestamp()
    end
    if not bucket.currencyStartedAt or tonumber(bucket.currencyStartedAt) == nil or tonumber(bucket.currencyStartedAt) <= 0 then
        bucket.currencyStartedAt = LL.GetCurrentTimestamp()
    end
    -- Legacy cleanup: retain only total interaction counts in saved buckets.
    bucket.sources = nil
    bucket.currencies = nil
end

function LL.HasBucketData(bucket)
    if not bucket then
        return false
    end
    local items = type(bucket.items) == "table" and bucket.items or nil
    local currencyByReason = type(bucket.currencyByReason) == "table" and bucket.currencyByReason or nil
    local instances = type(bucket.instances) == "table" and bucket.instances or nil
    return (items and next(items) ~= nil)
        or (currencyByReason and next(currencyByReason) ~= nil)
        or (instances and next(instances) ~= nil)
end

local function ResetBucket(bucket)
    bucket.items = {}
    bucket.currencyByReason = {}
    bucket.instances = {}
    bucket.startedAt = LL.GetCurrentTimestamp()
    bucket.currencyStartedAt = bucket.startedAt
    bucket.sources = nil
    bucket.currencies = nil
end

function LL.ResetBucket(bucket)
    if not bucket then
        return
    end
    ResetBucket(bucket)
end

function LL.EnsureSaved()
    LL.saved = LL.saved or {}
    LL.saved.lifetime = LL.saved.lifetime or {}
    LL.saved.manual = LL.saved.manual or {}
    LL.saved.settings = LL.saved.settings or {}
    if LL.saved.settings.debug == nil then
        LL.saved.settings.debug = false
    end
    if LL.saved.settings.eventProbe == nil then
        LL.saved.settings.eventProbe = false
    end
    if LL.saved.settings.uiScale == nil then
        if type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode() then
            LL.saved.settings.uiScale = 1.2
        else
            LL.saved.settings.uiScale = 1.0
        end
    end

    local fromVersion, hasExplicitVersion = LL.InferStoredDataModelVersion(LL.saved)
    local migrationResult = {
        didMigrate = false,
        didReset = false,
        fromVersion = fromVersion,
        toVersion = fromVersion,
        hadExplicitVersion = hasExplicitVersion,
    }
    if fromVersion < LL.GetDataModelVersion() then
        migrationResult = LL.ApplyDataModelMigration(LL.saved, fromVersion)
        migrationResult.hadExplicitVersion = hasExplicitVersion
    else
        LL.saved.dataModelVersion = fromVersion
    end

    EnsureBucket(LL.saved.manual)
    EnsureBucket(LL.saved.lifetime)

    migrationResult.toVersion = LL.saved.dataModelVersion
    return migrationResult
end

function LL.EnsureSession()
    LL.session = LL.session or {}
    EnsureBucket(LL.session)
end
