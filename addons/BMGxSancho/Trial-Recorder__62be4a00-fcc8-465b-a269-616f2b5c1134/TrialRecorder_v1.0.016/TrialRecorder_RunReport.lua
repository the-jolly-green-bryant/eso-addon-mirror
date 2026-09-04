TrialRecorder = TrialRecorder or {}
local TR = TrialRecorder

TR.RunReport = TR.RunReport or {}
local RunReport = TR.RunReport

RunReport.SCHEMA_NAME = "BMG_TRIAL_RUN_REPORT"
RunReport.SCHEMA_VERSION = 1
RunReport.MAX_SAVED_REPORTS = 50
RunReport.providers = RunReport.providers or {}

local function CopyValue(value, seen)
    if type(value) ~= "table" then
        return value
    end

    seen = seen or {}
    if seen[value] then
        return nil
    end

    local copy = {}
    seen[value] = copy
    for key, child in pairs(value) do
        local keyType = type(key)
        local childType = type(child)
        if (keyType == "string" or keyType == "number")
            and childType ~= "function"
            and childType ~= "userdata"
            and childType ~= "thread" then
            copy[key] = CopyValue(child, seen)
        end
    end
    return copy
end

local function NormalizeCharacterName(value)
    if not value or value == "" then
        return nil
    end
    if ZO_CachedStrFormat then
        return ZO_CachedStrFormat(SI_UNIT_NAME, value)
    end
    if zo_strformat then
        return zo_strformat(SI_UNIT_NAME, value)
    end
    return value
end

local function GetUnitAccountName(unitTag)
    if type(GetUnitDisplayName) == "function" then
        local displayName = GetUnitDisplayName(unitTag)
        if displayName and displayName ~= "" then
            return displayName
        end
    end
    return nil
end

local function GetUnitCharacterName(unitTag)
    if type(GetUnitName) ~= "function" then
        return nil
    end
    return NormalizeCharacterName(GetUnitName(unitTag))
end

function RunReport:Initialize()
    TR.sv.runReports = TR.sv.runReports or { order = {}, byId = {} }
    TR.sv.runReports.order = TR.sv.runReports.order or {}
    TR.sv.runReports.byId = TR.sv.runReports.byId or {}
end

function RunReport:RegisterProvider(providerId, provider)
    if type(providerId) ~= "string" or providerId == "" or type(provider) ~= "table" then
        return false
    end
    if type(provider.GetSummary) ~= "function" then
        return false
    end

    self.providers[providerId] = provider
    return true
end

function RunReport:UnregisterProvider(providerId)
    if not providerId then
        return false
    end
    self.providers[providerId] = nil
    return true
end

function RunReport:GetSchemaVersion()
    return self.SCHEMA_VERSION
end

function RunReport:GetLatest()
    local reports = TR.sv and TR.sv.runReports
    local reportId = reports and reports.order and reports.order[1]
    if not reportId then
        return nil
    end
    return CopyValue(reports.byId[reportId])
end

function RunReport:Get(reportId)
    if not reportId or not TR.sv or not TR.sv.runReports then
        return nil
    end
    return CopyValue(TR.sv.runReports.byId[reportId])
end

function RunReport:CaptureRoster()
    local snapshot = {
        capturedAt = GetTimeStamp and GetTimeStamp() or 0,
        members = {},
    }

    local groupSize = type(GetGroupSize) == "function" and tonumber(GetGroupSize()) or 0
    groupSize = groupSize or 0

    if groupSize > 0 then
        for index = 1, groupSize do
            local unitTag = type(GetGroupUnitTagByIndex) == "function" and GetGroupUnitTagByIndex(index) or ("group" .. tostring(index))
            local exists = type(DoesUnitExist) ~= "function" or DoesUnitExist(unitTag)
            if unitTag and unitTag ~= "" and exists then
                table.insert(snapshot.members, {
                    accountName = GetUnitAccountName(unitTag),
                    characterName = GetUnitCharacterName(unitTag),
                    classId = type(GetUnitClassId) == "function" and GetUnitClassId(unitTag) or nil,
                    isGroupLeader = type(IsUnitGroupLeader) == "function" and IsUnitGroupLeader(unitTag) == true or nil,
                })
            end
        end
    end

    if #snapshot.members == 0 then
        table.insert(snapshot.members, {
            accountName = type(GetDisplayName) == "function" and GetDisplayName() or nil,
            characterName = GetUnitCharacterName("player"),
            classId = type(GetUnitClassId) == "function" and GetUnitClassId("player") or nil,
            isGroupLeader = nil,
        })
    end

    snapshot.size = #snapshot.members
    return snapshot
end

function RunReport:GetCurrentWeeklyTrial()
    if type(GetRaidOfTheWeekLeaderboardInfo) ~= "function" then
        return nil
    end

    local ok, weeklyName, weeklyRaidId = pcall(GetRaidOfTheWeekLeaderboardInfo, RAID_CATEGORY_TRIAL)
    if not ok then
        return nil
    end

    weeklyRaidId = tonumber(weeklyRaidId)
    if not weeklyRaidId or weeklyRaidId <= 0 then
        return nil
    end

    TR:RefreshRaidLeaderboardIds()
    local trialKey = nil
    for key, raidId in pairs(TR.RaidIdByTrialKey or {}) do
        if tonumber(raidId) == weeklyRaidId then
            trialKey = key
            break
        end
    end

    local trial = trialKey and TR.TrialByKey[trialKey] or nil
    return {
        raidId = weeklyRaidId,
        trialKey = trialKey,
        trialName = trial and trial.name or weeklyName,
    }
end

function RunReport:CollectExtensions(run, report)
    local extensions = {}
    local providerVersions = {}

    for providerId, provider in pairs(self.providers) do
        local isAvailable = true
        if type(provider.IsAvailable) == "function" then
            local ok, available = pcall(provider.IsAvailable, provider)
            isAvailable = ok and available == true
        end

        if isAvailable then
            local context = {
                reportId = report.reportId,
                runId = report.runId,
                trialKey = run.trialKey,
                trialName = run.trialName,
                completionType = run.completionType,
                configuration = run.configuration,
                completedAt = run.completedAt,
                durationMs = run.durationMs,
            }

            local ok, summary = pcall(provider.GetSummary, provider, context)
            if ok and type(summary) == "table" then
                extensions[providerId] = CopyValue(summary)

                local version = provider.version
                if type(provider.GetVersion) == "function" then
                    local versionOk, returnedVersion = pcall(provider.GetVersion, provider)
                    if versionOk and returnedVersion then
                        version = returnedVersion
                    end
                end
                providerVersions[providerId] = version or "unknown"
            elseif not ok then
                TR:AddDiagnostic({
                    event = "RUN_REPORT_PROVIDER_ERROR",
                    providerId = providerId,
                    error = tostring(summary),
                })
            end
        end
    end

    return extensions, providerVersions
end

function RunReport:Build(run)
    if type(run) ~= "table" or not run.id then
        return nil
    end

    local trial = TR.TrialByKey[run.trialKey]
    local raidId = TR:GetRaidIdForTrial(run.trialKey)
    local weekly = self:GetCurrentWeeklyTrial()

    local report = {
        schema = self.SCHEMA_NAME,
        schemaVersion = self.SCHEMA_VERSION,
        reportId = run.id,
        runId = run.id,
        createdAt = GetTimeStamp and GetTimeStamp() or run.completedAt,

        identity = {
            accountName = type(GetDisplayName) == "function" and GetDisplayName() or nil,
            characterId = run.characterId,
            characterName = run.characterName,
            worldName = type(GetWorldName) == "function" and GetWorldName() or nil,
        },

        trial = {
            key = run.trialKey,
            name = run.trialName,
            short = trial and trial.short or nil,
            raidId = raidId,
            currentWeekly = weekly,
        },

        result = {
            veteran = true,
            hardMode = run.completionType == "HARD_MODE",
            completionType = run.completionType,
            configuration = run.configuration,
            classificationSource = run.classificationSource,
            score = run.score,
            durationMs = run.durationMs,
            completedAt = run.completedAt,
            vitality = {
                remaining = run.vitalityRemaining,
                starting = run.vitalityStarting,
            },
            deaths = run.deaths,
            newFastest = run.newFastest == true,
            newHighest = run.newHighest == true,
        },

        roster = self:CaptureRoster(),

        provenance = {
            producer = "TrialRecorder",
            producerVersion = TR.VERSION,
            schemaVersion = self.SCHEMA_VERSION,
            fields = {
                ["result.score"] = "ESO_EVENT_RAID_TRIAL_COMPLETE",
                ["result.durationMs"] = "ESO_EVENT_RAID_TRIAL_COMPLETE",
                ["result.completedAt"] = "TRIAL_RECORDER_TIMESTAMP",
                ["result.completionType"] = "TRIAL_RECORDER_CLASSIFICATION",
                ["result.configuration"] = "TRIAL_RECORDER_CLASSIFICATION",
                ["result.vitality.remaining"] = "ESO_GET_RAID_REVIVE_COUNTERS_REMAINING",
                ["result.vitality.starting"] = "ESO_GET_CURRENT_RAID_STARTING_REVIVE_COUNTERS",
                ["result.deaths"] = "ESO_GET_CURRENT_RAID_DEATHS",
                ["roster"] = "ESO_GROUP_UNIT_SNAPSHOT_AT_CLEAR",
            },
            extensions = {},
        },

        extensions = {},
    }

    local extensions, providerVersions = self:CollectExtensions(run, report)
    report.extensions = extensions
    report.provenance.extensions = providerVersions

    return report
end

function RunReport:Store(report)
    if type(report) ~= "table" or not report.reportId then
        return false
    end

    self:Initialize()
    local reports = TR.sv.runReports
    local reportId = report.reportId

    if reports.byId[reportId] then
        reports.byId[reportId] = CopyValue(report)
        return true
    end

    reports.byId[reportId] = CopyValue(report)
    table.insert(reports.order, 1, reportId)

    while #reports.order > self.MAX_SAVED_REPORTS do
        local oldId = table.remove(reports.order)
        reports.byId[oldId] = nil
    end

    return true
end

function RunReport:OnRunSaved(run)
    local report = self:Build(run)
    if not report then
        return nil
    end

    if not self:Store(report) then
        return nil
    end

    run.reportId = report.reportId
    return report
end

TR.RunReportAPI = TR.RunReportAPI or {}
local API = TR.RunReportAPI

function API:GetSchemaVersion()
    return RunReport:GetSchemaVersion()
end

function API:GetLatestReport()
    return RunReport:GetLatest()
end

function API:GetReport(reportId)
    return RunReport:Get(reportId)
end

function API:RegisterProvider(providerId, provider)
    return RunReport:RegisterProvider(providerId, provider)
end

function API:UnregisterProvider(providerId)
    return RunReport:UnregisterProvider(providerId)
end
