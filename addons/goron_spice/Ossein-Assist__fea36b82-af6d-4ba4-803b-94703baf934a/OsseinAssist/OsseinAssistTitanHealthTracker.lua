function OsseinAssist.IsTrackedTitanHealthAbility(abilityName)
    for _, trackedAbilityName in ipairs(OsseinAssist.titanHealthTrackedAbilityNames) do
        if abilityName == trackedAbilityName then
            return true
        end
    end
    return false
end

function OsseinAssist.GetEmptyTitanHealthStats()
    return {}
end

function OsseinAssist.GetTitanHealthLogTimestampString(unixTimestamp)
    local stamp = tonumber(unixTimestamp) or 0
    if stamp <= 0 then
        return "Unknown Time"
    end
    if type(os) == "table" and type(os.date) == "function" then
        return os.date("%m/%d/%Y, %H:%M", stamp)
    end
    if type(GetDateStringFromTimestamp) == "function" then
        return GetDateStringFromTimestamp(stamp)
    end
    return tostring(stamp)
end

function OsseinAssist.GetTitanNames()
    return {
        OsseinAssist.blazeforgedValneerName,
        OsseinAssist.sparkstormMyrinaxName,
    }
end

function OsseinAssist.GetTitanLogColorHex(titanName)
    if titanName == OsseinAssist.blazeforgedValneerName then
        return OsseinAssist.redColorHex
    end
    if titanName == OsseinAssist.sparkstormMyrinaxName then
        return OsseinAssist.blueColorHex
    end
    return "FFFFFF"
end

function OsseinAssist.FormatTitanNameForLog(titanName)
    local colorHex = OsseinAssist.GetTitanLogColorHex(titanName)
    return string.format("|c%s<<%s>>|r", colorHex, tostring(titanName))
end

function OsseinAssist.FormatElapsedMsToMinuteSecond(elapsedMs)
    local totalSeconds = math.floor((tonumber(elapsedMs) or 0) / 1000)
    if totalSeconds < 0 then
        totalSeconds = 0
    end
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60
    return string.format("%02d:%02d", minutes, seconds)
end

function OsseinAssist.CaptureTitanStartingHealth(fightLog)
    if fightLog == nil then
        return
    end
    local titanUnitIds = {
        [OsseinAssist.blazeforgedValneerName] = OsseinAssist.blazeforgedValneerUnitId,
        [OsseinAssist.sparkstormMyrinaxName]  = OsseinAssist.sparkstormMyrinaxUnitId,
    }
    for _, titanName in ipairs(OsseinAssist.GetTitanNames()) do
        if fightLog.startingHealthByTitan[titanName] == nil then
            fightLog.startingHealthByTitan[titanName] = OsseinAssist.GetTitanHealthPercentByUnitId(titanUnitIds[titanName])
        end
    end
end

function OsseinAssist.CloneTitanHealthStats(stats)
    local clone = {}
    for titanName, titanStats in pairs(stats or {}) do
        clone[titanName] = {}
        for abilityName, abilityStats in pairs(titanStats) do
            clone[titanName][abilityName] = {
                hits = abilityStats.hits or 0,
                totalDamage = abilityStats.totalDamage or 0,
                firstHitMs = abilityStats.firstHitMs,
                lastHitMs = abilityStats.lastHitMs,
                sourceName = abilityStats.sourceName,
                abilityId = abilityStats.abilityId,
            }
        end
    end
    return clone
end

function OsseinAssist.TitanHealthStatsHasData(stats)
    for _, titanStats in pairs(stats or {}) do
        for _, abilityStats in pairs(titanStats) do
            if (abilityStats.hits or 0) > 0 then
                return true
            end
        end
    end
    return false
end

function OsseinAssist.StartTitanFightLog()
    if OsseinAssist.currentTitanFightLog ~= nil then
        return
    end

    local startedAtMs = GetFrameTimeMilliseconds()
    OsseinAssist.currentTitanFightLog = {
        startedAtMs = startedAtMs,
        startedAtUnix = type(GetTimeStamp) == "function" and GetTimeStamp() or 0,
        startingHealthByTitan = {},
        entries = {},
    }
    OsseinAssist.titanHealthStats = OsseinAssist.GetEmptyTitanHealthStats()
    OsseinAssist.CaptureTitanStartingHealth(OsseinAssist.currentTitanFightLog)
end

function OsseinAssist.PersistTitanFightLogs()
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.titanFightLogs = OsseinAssist.titanFightLogs
    end
end

function OsseinAssist.FinalizeTitanFightLog(reason)
    local activeLog = OsseinAssist.currentTitanFightLog
    if activeLog == nil then
        return
    end

    local finishedAtMs = GetFrameTimeMilliseconds()
    local snapshot = OsseinAssist.CloneTitanHealthStats(OsseinAssist.titanHealthStats)
    local fightLog = {
        startedAtMs = activeLog.startedAtMs,
        startedAtUnix = activeLog.startedAtUnix,
        endedAtMs = finishedAtMs,
        durationMs = math.max(finishedAtMs - activeLog.startedAtMs, 0),
        reason = reason or "unknown",
        stats = snapshot,
        startingHealthByTitan = activeLog.startingHealthByTitan or {},
        entries = activeLog.entries or {},
    }

    OsseinAssist.currentTitanFightLog = nil
    if OsseinAssist.TitanHealthStatsHasData(snapshot) then
        table.insert(OsseinAssist.titanFightLogs, 1, fightLog)
        while #OsseinAssist.titanFightLogs > OsseinAssist.maxTitanFightLogs do
            table.remove(OsseinAssist.titanFightLogs)
        end
        OsseinAssist.PersistTitanFightLogs()
        d(string.format("Ossein Assist: saved titan health fight log (%dms, reason=%s).", fightLog.durationMs, fightLog.reason))
    end
    OsseinAssist.titanHealthStats = OsseinAssist.GetEmptyTitanHealthStats()
end

function OsseinAssist.GetFakeTitanHealthSnapshot(seed)
    local scale = 1 + ((seed or 0) * 0.08)
    local vBlazing = math.floor(185000 * scale + 0.5)
    local vSparking = math.floor(92000 * scale + 0.5)
    local vClash = math.floor(240000 * scale + 0.5)
    local vSeekSpark = math.floor(66000 * scale + 0.5)
    local vSparkInferno = math.floor(81000 * scale + 0.5)
    local vSeekForge = math.floor(71000 * scale + 0.5)
    local vForgeInferno = math.floor(98000 * scale + 0.5)
    local mBlazing = math.floor(69000 * scale + 0.5)
    local mSparking = math.floor(211000 * scale + 0.5)
    local mClash = math.floor(226000 * scale + 0.5)
    local mSeekSpark = math.floor(73000 * scale + 0.5)
    local mSparkInferno = math.floor(86000 * scale + 0.5)
    local mSeekForge = math.floor(64000 * scale + 0.5)
    local mForgeInferno = math.floor(102000 * scale + 0.5)
    local now = GetFrameTimeMilliseconds()
    return {
        [OsseinAssist.blazeforgedValneerName] = {
            [OsseinAssist.blazingHeatRayName] = { hits = 5 + (seed or 0), totalDamage = vBlazing, firstHitMs = now - 14000, lastHitMs = now - 2000, abilityId = 0 },
            [OsseinAssist.sparkingHeatRayName] = { hits = 3 + (seed or 0), totalDamage = vSparking, firstHitMs = now - 13000, lastHitMs = now - 3000, abilityId = 0 },
            [OsseinAssist.titanicClashName] = { hits = 2 + (seed or 0), totalDamage = vClash, firstHitMs = now - 18000, lastHitMs = now - 4000, abilityId = 0 },
            [OsseinAssist.seekingSparkSurgeName] = { hits = 4 + (seed or 0), totalDamage = vSeekSpark, firstHitMs = now - 12000, lastHitMs = now - 4500, abilityId = 0 },
            [OsseinAssist.sparkSurgeInfernoName] = { hits = 4 + (seed or 0), totalDamage = vSparkInferno, firstHitMs = now - 11000, lastHitMs = now - 3500, abilityId = 0 },
            [OsseinAssist.seekingForgeFireName] = { hits = 3 + (seed or 0), totalDamage = vSeekForge, firstHitMs = now - 10000, lastHitMs = now - 3000, abilityId = 0 },
            [OsseinAssist.forgeFireInfernoName] = { hits = 3 + (seed or 0), totalDamage = vForgeInferno, firstHitMs = now - 9000, lastHitMs = now - 2500, abilityId = 0 },
        },
        [OsseinAssist.sparkstormMyrinaxName] = {
            [OsseinAssist.blazingHeatRayName] = { hits = 2 + (seed or 0), totalDamage = mBlazing, firstHitMs = now - 11000, lastHitMs = now - 3500, abilityId = 0 },
            [OsseinAssist.sparkingHeatRayName] = { hits = 6 + (seed or 0), totalDamage = mSparking, firstHitMs = now - 12000, lastHitMs = now - 1500, abilityId = 0 },
            [OsseinAssist.titanicClashName] = { hits = 2 + (seed or 0), totalDamage = mClash, firstHitMs = now - 18000, lastHitMs = now - 5000, abilityId = 0 },
            [OsseinAssist.seekingSparkSurgeName] = { hits = 3 + (seed or 0), totalDamage = mSeekSpark, firstHitMs = now - 12000, lastHitMs = now - 4000, abilityId = 0 },
            [OsseinAssist.sparkSurgeInfernoName] = { hits = 5 + (seed or 0), totalDamage = mSparkInferno, firstHitMs = now - 11000, lastHitMs = now - 3200, abilityId = 0 },
            [OsseinAssist.seekingForgeFireName] = { hits = 2 + (seed or 0), totalDamage = mSeekForge, firstHitMs = now - 10000, lastHitMs = now - 2600, abilityId = 0 },
            [OsseinAssist.forgeFireInfernoName] = { hits = 4 + (seed or 0), totalDamage = mForgeInferno, firstHitMs = now - 9000, lastHitMs = now - 2100, abilityId = 0 },
        },
    }
end

function OsseinAssist.GetFakeTitanHealthEntries(seed)
    local now = GetFrameTimeMilliseconds()
    local offset = (seed or 0) * 250
    return {
        {
            elapsedMs = 1800 + offset,
            titanName = OsseinAssist.blazeforgedValneerName,
            abilityName = OsseinAssist.blazingHeatRayName,
            damage = 42500 + (seed or 0) * 800,
            newHealthPercent = 96.7,
        },
        {
            elapsedMs = 4200 + offset,
            titanName = OsseinAssist.sparkstormMyrinaxName,
            abilityName = OsseinAssist.sparkingHeatRayName,
            damage = 50300 + (seed or 0) * 1000,
            newHealthPercent = 95.9,
        },
        {
            elapsedMs = 8300 + offset,
            titanName = OsseinAssist.blazeforgedValneerName,
            abilityName = OsseinAssist.titanicClashName,
            damage = 120800 + (seed or 0) * 2200,
            newHealthPercent = 91.2,
        },
        {
            elapsedMs = 12100 + offset,
            titanName = OsseinAssist.sparkstormMyrinaxName,
            abilityName = OsseinAssist.sparkSurgeInfernoName,
            damage = 32800 + (seed or 0) * 700,
            newHealthPercent = 89.4,
        },
    }
end

function OsseinAssist.GetTitanHealthStatsForReporting()
    if OsseinAssist.titanHealthFakeDataEnabled then
        return OsseinAssist.GetFakeTitanHealthSnapshot(0)
    end
    return OsseinAssist.titanHealthStats
end

function OsseinAssist.GetTitanFightLogsForReporting()
    if OsseinAssist.titanHealthFakeDataEnabled then
        local logs = {}
        local now = GetFrameTimeMilliseconds()
        local count = math.min(5, OsseinAssist.maxTitanFightLogs)
        for index = 1, count do
            local durationMs = 90000 + (index * 7000)
            table.insert(logs, {
                startedAtMs = now - (index * 180000),
                startedAtUnix = (type(GetTimeStamp) == "function" and GetTimeStamp() or 0) - (index * 180),
                endedAtMs = now - (index * 180000) + durationMs,
                durationMs = durationMs,
                reason = "fake",
                stats = OsseinAssist.GetFakeTitanHealthSnapshot(index),
                startingHealthByTitan = {
                    [OsseinAssist.blazeforgedValneerName] = 100,
                    [OsseinAssist.sparkstormMyrinaxName] = 100,
                },
                entries = OsseinAssist.GetFakeTitanHealthEntries(index),
            })
        end
        return logs
    end
    return OsseinAssist.titanFightLogs
end

function OsseinAssist.GetTitanNameFromAbilityId(abilityId)
    local numericId = tonumber(abilityId)
    if numericId == nil then
        return nil
    end
    -- Heat ray IDs uniquely identify which titan is casting
    if OsseinAssist.blazingHeatRayAbilityIdDurations and OsseinAssist.blazingHeatRayAbilityIdDurations[numericId] then
        return OsseinAssist.blazeforgedValneerName
    end
    if OsseinAssist.sparkingHeatRayAbilityIdDurations and OsseinAssist.sparkingHeatRayAbilityIdDurations[numericId] then
        return OsseinAssist.sparkstormMyrinaxName
    end
    -- Titanic Clash: blue-side IDs = Myrinax, orange-side IDs = Valneer
    if numericId == 232375 or numericId == 232460 or numericId == 232473 then
        return OsseinAssist.sparkstormMyrinaxName
    end
    if numericId == 232376 or numericId == 232465 or numericId == 232477 then
        return OsseinAssist.blazeforgedValneerName
    end
    return nil
end

function OsseinAssist.GetTitanNameFromCombatEvent(targetName, targetUnitId, abilityId)
    -- Heat ray and clash IDs uniquely identify the titan via ability ID.
    local fromId = OsseinAssist.GetTitanNameFromAbilityId(abilityId)
    if fromId ~= nil then
        return fromId
    end
    -- For RAD TITAN / Fx TITAN variants the titan is the target: use unit ID first, name as fallback.
    local numericTargetUnitId = tonumber(targetUnitId)
    if numericTargetUnitId == OsseinAssist.blazeforgedValneerUnitId then
        return OsseinAssist.blazeforgedValneerName
    end
    if numericTargetUnitId == OsseinAssist.sparkstormMyrinaxUnitId then
        return OsseinAssist.sparkstormMyrinaxName
    end
    return OsseinAssist.ResolveTitanEncounterName(targetName)
end

function OsseinAssist.IsDamageResult(result)
    return result == ACTION_RESULT_DAMAGE
        or result == ACTION_RESULT_CRITICAL_DAMAGE
        or result == ACTION_RESULT_DOT_TICK
        or result == ACTION_RESULT_DOT_TICK_CRITICAL
end

function OsseinAssist.TrackTitanHealth(result, abilityName, targetName, targetUnitId, hitValue, abilityId)
    if not OsseinAssist.titanHealthLoggingEnabled then
        return
    end
    if OsseinAssist.titanHealthFakeDataEnabled then
        return
    end
    if not OsseinAssist.IsInOsseinCage() then
        return
    end
    if not OsseinAssist.IsTrackedTitanHealthAbility(abilityName) then
        return
    end

    -- Diagnostic: log all matching ability events before damage filter
    OsseinAssist.LogTitanHealthMessage(string.format(
        "[TitanDiag] ability=%s id=%s result=%s target=%s",
        tostring(abilityName), tostring(abilityId), tostring(result),
        tostring(targetName)
    ))

    if not OsseinAssist.IsDamageResult(result) then
        return
    end

    local titanName = OsseinAssist.GetTitanNameFromCombatEvent(targetName, targetUnitId, abilityId)
    if titanName == nil then
        return
    end
    if OsseinAssist.currentTitanFightLog == nil then
        OsseinAssist.StartTitanFightLog()
    end
    local activeLog = OsseinAssist.currentTitanFightLog
    OsseinAssist.CaptureTitanStartingHealth(activeLog)

    local nowMs = GetFrameTimeMilliseconds()
    local damage = tonumber(hitValue) or 0
    local titanUnitId = titanName == OsseinAssist.blazeforgedValneerName
        and OsseinAssist.blazeforgedValneerUnitId
        or OsseinAssist.sparkstormMyrinaxUnitId
    local newHealthPercent = OsseinAssist.GetTitanHealthPercentByUnitId(titanUnitId)
    local titanStats = OsseinAssist.titanHealthStats[titanName]
    if titanStats == nil then
        titanStats = {}
        OsseinAssist.titanHealthStats[titanName] = titanStats
    end
    local abilityStats = titanStats[abilityName]
    if abilityStats == nil then
        abilityStats = {
            hits = 0,
            totalDamage = 0,
            firstHitMs = nowMs,
            lastHitMs = nowMs,
            abilityId = abilityId,
        }
        titanStats[abilityName] = abilityStats
    end

    abilityStats.hits = abilityStats.hits + 1
    abilityStats.totalDamage = abilityStats.totalDamage + damage
    abilityStats.lastHitMs = nowMs
    abilityStats.abilityId = abilityId

    table.insert(activeLog.entries, {
        elapsedMs = math.max(nowMs - activeLog.startedAtMs, 0),
        titanName = titanName,
        abilityName = abilityName,
        damage = damage,
        newHealthPercent = newHealthPercent,
        abilityId = abilityId,
    })
end

function OsseinAssist.ResetTitanHealthStats()
    OsseinAssist.titanHealthStats = OsseinAssist.GetEmptyTitanHealthStats()
    OsseinAssist.titanFightLogs = {}
    OsseinAssist.currentTitanFightLog = nil
    OsseinAssist.PersistTitanFightLogs()
    d("Ossein Assist: titan health stats reset.")
end

function OsseinAssist.PrintTitanHealthStats()
    local titanNames = {
        OsseinAssist.blazeforgedValneerName,
        OsseinAssist.sparkstormMyrinaxName,
    }

    local statsByTitan = OsseinAssist.GetTitanHealthStatsForReporting()
    d("Ossein Assist: titan health report")
    for _, titanName in ipairs(titanNames) do
        local titanStats = statsByTitan[titanName] or {}
        local hasAny = next(titanStats) ~= nil
        if not hasAny then
            d(string.format(" - %s: no hits recorded", titanName))
        else
            for abilityName, stats in pairs(titanStats) do
                local durationMs = math.max((stats.lastHitMs or 0) - (stats.firstHitMs or 0), 0)
                d(string.format(
                    " - %s <- %s: hits=%d total=%d window=%dms id=%s",
                    titanName,
                    abilityName,
                    stats.hits or 0,
                    stats.totalDamage or 0,
                    durationMs,
                    tostring(stats.abilityId)
                ))
            end
        end
    end
end

function OsseinAssist.PrintTitanFightLogs()
    local logs = OsseinAssist.GetTitanFightLogsForReporting()
    d(string.format("Ossein Assist: titan health fight logs (%d/%d)", #logs, OsseinAssist.maxTitanFightLogs))
    if #logs == 0 then
        d(" - no fight logs yet.")
        return
    end

    for index, log in ipairs(logs) do
        d(string.format(" %d) duration=%dms reason=%s", index, log.durationMs or 0, tostring(log.reason)))
        local titanNames = { OsseinAssist.blazeforgedValneerName, OsseinAssist.sparkstormMyrinaxName }
        local abilityNames = OsseinAssist.titanHealthTrackedAbilityNames
        for _, titanName in ipairs(titanNames) do
            local titanStats = (log.stats and log.stats[titanName]) or {}
            for _, abilityName in ipairs(abilityNames) do
                local stats = titanStats[abilityName]
                local hits = stats and stats.hits or 0
                local totalDamage = stats and stats.totalDamage or 0
                d(string.format("    - %s <- %s: hits=%d total=%d", titanName, abilityName, hits, totalDamage))
            end
        end
    end
end

function OsseinAssist.GetTitanFightLogDamage(log, titanName, abilityName)
    local titanStats = (log.stats and log.stats[titanName]) or {}
    local abilityStats = titanStats[abilityName]
    if abilityStats == nil then
        return 0
    end
    return abilityStats.totalDamage or 0
end

function OsseinAssist.GetTitanFightLogSummaryLine(index)
    local logs = OsseinAssist.GetTitanFightLogsForReporting()
    local log = logs[index]
    if log == nil then
        return string.format("%02d) --", index)
    end

    local function getTitanTotals(titanName)
        local totalDamage = 0
        local totalHits = 0
        for _, abilityName in ipairs(OsseinAssist.titanHealthTrackedAbilityNames) do
            local titanStats = (log.stats and log.stats[titanName]) or {}
            local stats = titanStats[abilityName]
            if stats ~= nil then
                totalDamage = totalDamage + (stats.totalDamage or 0)
                totalHits = totalHits + (stats.hits or 0)
            end
        end
        return totalDamage, totalHits
    end

    local valneerDamage, valneerHits = getTitanTotals(OsseinAssist.blazeforgedValneerName)
    local myrinaxDamage, myrinaxHits = getTitanTotals(OsseinAssist.sparkstormMyrinaxName)
    local durationSeconds = (log.durationMs or 0) / 1000

    return string.format(
        "%02d) %.1fs | V:%dk/%dh M:%dk/%dh",
        index,
        durationSeconds,
        math.floor(valneerDamage / 1000 + 0.5),
        valneerHits,
        math.floor(myrinaxDamage / 1000 + 0.5),
        myrinaxHits
    )
end

function OsseinAssist.GetTitanFightLogTitle(index)
    local logs = OsseinAssist.GetTitanFightLogsForReporting()
    local log = logs[index]
    if log == nil then
        return string.format("%02d) --", index)
    end
    return OsseinAssist.GetTitanHealthLogTimestampString(log.startedAtUnix)
end

function OsseinAssist.GetTitanFightLogDescription(index)
    local logs = OsseinAssist.GetTitanFightLogsForReporting()
    local log = logs[index]
    if log == nil then
        return "No log"
    end

    local lines = {}
    local entries = log.entries or {}
    local byTitan = {
        [OsseinAssist.sparkstormMyrinaxName] = {},
        [OsseinAssist.blazeforgedValneerName] = {},
    }

    for _, entry in ipairs(entries) do
        local titanName = entry.titanName
        if byTitan[titanName] ~= nil then
            table.insert(byTitan[titanName], entry)
        end
    end

    local function appendTitanSection(titanName)
        local titanEntries = byTitan[titanName] or {}
        local startHp = (log.startingHealthByTitan and log.startingHealthByTitan[titanName]) or nil
        local totalDamage = 0
        local abilityHitCounts = {}
        for _, entry in ipairs(titanEntries) do
            totalDamage = totalDamage + (tonumber(entry.damage) or 0)
            local abilityName = tostring(entry.abilityName)
            abilityHitCounts[abilityName] = (abilityHitCounts[abilityName] or 0) + 1
        end

        table.insert(lines, OsseinAssist.FormatTitanNameForLog(titanName))
        table.insert(lines, string.format(
            "Start HP: %s | Hits: %d | Total Damage: %d",
            OsseinAssist.FormatHealthPercent(startHp),
            #titanEntries,
            totalDamage
        ))
        table.insert(lines, "Ability Hits:")
        for _, abilityName in ipairs(OsseinAssist.titanHealthTrackedAbilityNames) do
            local hitCount = abilityHitCounts[abilityName] or 0
            table.insert(lines, string.format(" - %s: %d", abilityName, hitCount))
        end
        table.insert(lines, "")
        table.insert(lines, "Damage Timeline:")

        local maxPerTitanLines = 12
        local rendered = math.min(#titanEntries, maxPerTitanLines)
        for i = 1, rendered do
            local entry = titanEntries[i]
            table.insert(lines, string.format(
                "%s %s dmg=%d newHP=%s",
                OsseinAssist.FormatElapsedMsToMinuteSecond(entry.elapsedMs),
                tostring(entry.abilityName),
                tonumber(entry.damage) or 0,
                OsseinAssist.FormatHealthPercent(entry.newHealthPercent)
            ))
        end
        if #titanEntries > maxPerTitanLines then
            table.insert(lines, string.format("... %d more entries", #titanEntries - maxPerTitanLines))
        end
    end

    appendTitanSection(OsseinAssist.sparkstormMyrinaxName)
    table.insert(lines, "")
    appendTitanSection(OsseinAssist.blazeforgedValneerName)

    return table.concat(lines, "\n")
end

function OsseinAssist.SetTitanHealthLoggingEnabled(enabled)
    OsseinAssist.titanHealthLoggingEnabled = enabled
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.titanHealthLoggingEnabled = enabled
    end
    if not enabled then
        OsseinAssist.FinalizeTitanFightLog("disabled")
    end
    OsseinAssist.RefreshTitanHealthTrackingRegistration()
    d(string.format("Ossein Assist: titan health logging %s.", enabled and "enabled" or "disabled"))
end

function OsseinAssist.SetTitanHealthFakeDataEnabled(enabled)
    if enabled and not OsseinAssist.IsDevUser() then
        OsseinAssist.titanHealthFakeDataEnabled = false
        if OsseinAssist.savedVariables ~= nil then
            OsseinAssist.savedVariables.titanHealthFakeDataEnabled = false
        end
        d("Ossein Assist: titan fake data is developer-only.")
        return
    end
    OsseinAssist.titanHealthFakeDataEnabled = enabled
    if OsseinAssist.savedVariables ~= nil then
        OsseinAssist.savedVariables.titanHealthFakeDataEnabled = enabled
    end
    d(string.format("Ossein Assist: titan health fake data %s.", enabled and "enabled" or "disabled"))
end

function OsseinAssist.OnTitanHealthCombatEvent(_, result, _, abilityName, _, _, _, _, targetName, _, hitValue, _, _, _, _, targetUnitId, abilityId)
    if not OsseinAssist.titanHealthLoggingEnabled then
        return
    end
    OsseinAssist.TrackTitanHealth(result, abilityName, targetName, targetUnitId, hitValue, abilityId)
end

function OsseinAssist.RefreshTitanHealthTrackingRegistration()
    local namespaceBase = OsseinAssist.name .. "TitanHealthTracking"
    -- Unregister legacy single-namespace registration in case it exists from an older version
    EVENT_MANAGER:UnregisterForEvent(namespaceBase, EVENT_COMBAT_EVENT)
    local allIds = OsseinAssist.titanHealthAbilityIds or {}
    for _, abilityId in ipairs(allIds) do
        local namespace = string.format("%s_%d", namespaceBase, abilityId)
        EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_COMBAT_EVENT)
        if OsseinAssist.titanHealthLoggingEnabled then
            EVENT_MANAGER:RegisterForEvent(namespace, EVENT_COMBAT_EVENT, OsseinAssist.OnTitanHealthCombatEvent)
            EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
        end
    end
end

function OsseinAssist.StartTitanHealthTracking()
    OsseinAssist.RefreshTitanHealthTrackingRegistration()
end

function OsseinAssist.OnHeatRaySignalCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if not OsseinAssist.IsInOsseinCage() then
        return
    end

    local numericId = tonumber(abilityId)
    local knownDurationMs = OsseinAssist.heatRayAbilityIdDurations and OsseinAssist.heatRayAbilityIdDurations[numericId]
    if knownDurationMs == nil then
        return
    end

    local titanName = "unknown"
    if OsseinAssist.blazingHeatRayAbilityIdDurations and OsseinAssist.blazingHeatRayAbilityIdDurations[numericId] then
        titanName = OsseinAssist.blazeforgedValneerName
    elseif OsseinAssist.sparkingHeatRayAbilityIdDurations and OsseinAssist.sparkingHeatRayAbilityIdDurations[numericId] then
        titanName = OsseinAssist.sparkstormMyrinaxName
    end

    local resultName = OsseinAssist.GetActionResultDebugName(result)
    OsseinAssist.LogAspectHeavyMessage(string.format(
        "Ossein Assist [HeatRay]: titan=%s id=%d name=%s result=%s source=%s target=%s knownDuration=%dms",
        titanName,
        numericId,
        tostring(abilityName),
        tostring(resultName),
        tostring(sourceName),
        tostring(targetName),
        knownDurationMs
    ))
end

function OsseinAssist.RefreshHeatRaySignalTrackingRegistration()
    local namespaceBase = OsseinAssist.name .. "HeatRaySignal"
    local allIds = OsseinAssist.heatRayAllAbilityIds or {}
    for _, abilityId in ipairs(allIds) do
        local namespace = string.format("%s_%d", namespaceBase, abilityId)
        EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_COMBAT_EVENT)
        if OsseinAssist.aspectHeavyChatLoggingEnabled then
            EVENT_MANAGER:RegisterForEvent(namespace, EVENT_COMBAT_EVENT, OsseinAssist.OnHeatRaySignalCombatEvent)
            EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
        end
    end
end

function OsseinAssist.StartHeatRaySignalTracking()
    OsseinAssist.RefreshHeatRaySignalTrackingRegistration()
end
