LootLog = LootLog or {}
local LL = LootLog

local DATA_MODEL_VERSION = 6

function LL.GetDataModelVersion()
    return DATA_MODEL_VERSION
end

function LL.InferStoredDataModelVersion(saved)
    local explicitVersion = tonumber(saved and saved.dataModelVersion)
    if explicitVersion and explicitVersion > 0 then
        return explicitVersion, true
    end

    -- No explicit marker means pre-versioned data model; always migrate from v1.
    return 1, false
end

function LL.ApplyDataModelMigration(saved, fromVersion)
    local result = {
        didMigrate = false,
        didReset = false,
        didSimplifyInteractionTotals = false,
        didResetCurrencyTotals = false,
        fromVersion = fromVersion,
        toVersion = fromVersion,
    }

    local workingVersion = tonumber(fromVersion) or 0
    while workingVersion < DATA_MODEL_VERSION do
        if workingVersion == 1 then
            local hadPersistentData = LL.HasBucketData(saved.lifetime) or LL.HasBucketData(saved.manual)
            saved.lifetime = saved.lifetime or {}
            saved.manual = saved.manual or {}
            LL.ResetBucket(saved.lifetime)
            LL.ResetBucket(saved.manual)
            result.didReset = result.didReset or hadPersistentData
            workingVersion = 2
            result.didMigrate = true
        elseif workingVersion == 2 then
            -- v2 -> v3: force clean reset due earlier v2 rollout bug where data was not reset.
            local hadPersistentData = LL.HasBucketData(saved.lifetime) or LL.HasBucketData(saved.manual)
            saved.lifetime = saved.lifetime or {}
            saved.manual = saved.manual or {}
            LL.ResetBucket(saved.lifetime)
            LL.ResetBucket(saved.manual)
            result.didReset = result.didReset or hadPersistentData
            workingVersion = 3
            result.didMigrate = true
        elseif workingVersion == 3 then
            -- v3 -> v4: collapse legacy interaction subtype counts into Total only.
            saved.lifetime = saved.lifetime or {}
            saved.manual = saved.manual or {}
            LL.KeepOnlyTotalInteractions(saved.lifetime)
            LL.KeepOnlyTotalInteractions(saved.manual)
            workingVersion = 4
            result.didMigrate = true
            result.didSimplifyInteractionTotals = true
        elseif workingVersion == 4 then
            -- v4 -> v5: add explicit currency buckets to persisted scopes.
            saved.lifetime = saved.lifetime or {}
            saved.manual = saved.manual or {}
            saved.lifetime.currencies = saved.lifetime.currencies or {}
            saved.manual.currencies = saved.manual.currencies or {}
            workingVersion = 5
            result.didMigrate = true
        elseif workingVersion == 5 then
            -- v5 -> v6: reset old aggregate currency totals because historical
            -- entries cannot be attributed to reasons retroactively.
            saved.lifetime = saved.lifetime or {}
            saved.manual = saved.manual or {}
            local migrationTimestamp = LL.GetCurrentTimestamp()
            local hadCurrencyData = (type(saved.lifetime.currencies) == "table" and next(saved.lifetime.currencies) ~= nil)
                or (type(saved.manual.currencies) == "table" and next(saved.manual.currencies) ~= nil)
            saved.lifetime.currencies = {}
            saved.manual.currencies = {}
            saved.lifetime.currencyByReason = {}
            saved.manual.currencyByReason = {}
            saved.lifetime.currencyStartedAt = migrationTimestamp
            saved.manual.currencyStartedAt = migrationTimestamp
            workingVersion = 6
            result.didMigrate = true
            result.didResetCurrencyTotals = result.didResetCurrencyTotals or hadCurrencyData
        else
            -- Unknown historical version: advance to current without destructive reset.
            workingVersion = DATA_MODEL_VERSION
            result.didMigrate = true
        end
    end

    result.toVersion = workingVersion
    saved.dataModelVersion = workingVersion
    return result
end
