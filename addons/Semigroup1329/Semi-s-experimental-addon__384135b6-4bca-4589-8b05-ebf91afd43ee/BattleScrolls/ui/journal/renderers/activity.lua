-----------------------------------------------------------
-- Activity Renderer
-- Renders the Activity tab: proc tracking and weaving stats
--
-- Receives a JournalRenderContext and populates the list.
-- All functions are stateless - filters come from context.
-----------------------------------------------------------

if not SemisPlaygroundCheckAccess() then
    return
end

local journal = BattleScrolls.journal
local utils = journal.utils
local StatIcons = journal.StatIcons
local EntryBuilder = journal.EntryBuilder
local ROW_CONTENT = journal.ROW_CONTENT

local SECTION_GAP = journal.SECTION_GAP
local Q3_INSET = journal.Q3_INSET

local ActivityRenderer = {}

-------------------------
-- Weaving Helpers
-------------------------

---Formats weaving time in ms for display
---@param ms number Weaving time in milliseconds
---@return string
local function formatWeaveTime(ms)
    return zo_strformat(GetString(BATTLESCROLLS_FORMAT_MILLISECONDS), ms)
end

---Formats a duration in seconds with localized unit suffix
---@param sec number
---@return string
local function formatSeconds(sec)
    return zo_strformat(GetString(BATTLESCROLLS_FORMAT_SECONDS), string.format("%.1f", sec))
end

---Formats a rate value with localized "/s" suffix
---@param rate number
---@return string
local function formatRate(rate)
    return zo_strformat(GetString(BATTLESCROLLS_STAT_PER_SECOND), string.format("%.2f", rate))
end

---Computes encounter-level weaving totals from per-ability "after" data
---@param weaving WeavingData
---@return number totalAfterSum
---@return number totalAfterCount
local function computeWeavingTotals(weaving)
    local totalSum, totalCount = 0, 0
    for _, entry in ipairs(weaving.byAbility) do
        totalSum = totalSum + entry.afterSum
        totalCount = totalCount + entry.afterCount
    end
    return totalSum, totalCount
end

-------------------------
-- Summary Tooltip Builders
-------------------------

---Builds tooltip for the Avg Cast Delay summary stat
---@param avgMs number Average inter-cast delay
---@param totalSum number Total inter-cast time (ms)
---@param totalCount number Number of measurements
---@return string
local function buildCastDelayTooltip(avgMs, totalSum, totalCount)
    local lines = {}
    lines[#lines + 1] = GetString(BATTLESCROLLS_TOOLTIP_INTER_CAST_DESC)
    lines[#lines + 1] = ""
    lines[#lines + 1] = string.format("%s (%d×)", formatWeaveTime(avgMs), totalCount)
    lines[#lines + 1] = string.format("%s: %s", GetString(BATTLESCROLLS_TOOLTIP_TOTAL), formatSeconds(totalSum / 1000))
    return table.concat(lines, "\n")
end

---Builds tooltip for the Time Lost summary stat
---@param totalSum number Total inter-cast time (ms)
---@param durationSec number Fight duration in seconds
---@return string
local function buildTimeLostTooltip(totalSum, durationSec)
    local lines = {}
    lines[#lines + 1] = GetString(BATTLESCROLLS_TOOLTIP_TIME_LOST_DESC)
    lines[#lines + 1] = ""
    local timeLostSec = totalSum / 1000
    local pctOfFight = durationSec > 0 and (timeLostSec / durationSec * 100) or 0
    lines[#lines + 1] = string.format("%s / %s (%.1f%%)", formatSeconds(timeLostSec), formatSeconds(durationSec), pctOfFight)
    return table.concat(lines, "\n")
end

---Builds tooltip for the Missed LAs summary stat
---@param errors number Total missed LA count
---@param skillActivations number Total skill activations
---@return string
local function buildMissedLaTooltip(errors, skillActivations)
    local lines = {}
    lines[#lines + 1] = GetString(BATTLESCROLLS_TOOLTIP_MISSED_LA_DESC)
    if skillActivations > 0 then
        lines[#lines + 1] = ""
        local pct = errors / skillActivations * 100
        lines[#lines + 1] = string.format("%d / %d (%.1f%%)", errors, skillActivations, pct)
    end
    return table.concat(lines, "\n")
end

---Builds tooltip for the Double LAs summary stat
---@param errors number Double LA count
---@param lightAttacks number Total LA count
---@return string
local function buildDoubleLaTooltip(errors, lightAttacks)
    local lines = {}
    lines[#lines + 1] = GetString(BATTLESCROLLS_TOOLTIP_DOUBLE_LA_DESC)
    lines[#lines + 1] = ""
    local pct = errors / lightAttacks * 100
    lines[#lines + 1] = string.format("%d / %d (%.1f%%)", errors, lightAttacks, pct)
    return table.concat(lines, "\n")
end

-------------------------
-- Per-Ability Tooltip Builder
-------------------------

---Builds tooltip text for a weaving ability entry
---@param entry WeavingAbilityData
---@param totalActivations number Total skill activations in the encounter
---@return string
local function buildWeavingAbilityTooltipText(entry, totalActivations)
    local lines = {}

    -- Casts with share
    local castShare = totalActivations > 0 and (entry.activations / totalActivations * 100) or 0
    lines[#lines + 1] = string.format("%s: %d (%.1f%%)", GetString(BATTLESCROLLS_STAT_CASTS), entry.activations, castShare)

    -- Delay after cast
    if entry.afterCount > 0 then
        local afterAvg = entry.afterSum / entry.afterCount
        lines[#lines + 1] = string.format("%s: %s (%d×)",
            GetString(BATTLESCROLLS_TOOLTIP_DELAY_AFTER), formatWeaveTime(afterAvg), entry.afterCount)
    end

    -- Delay before cast
    if entry.beforeCount > 0 then
        local beforeAvg = entry.beforeSum / entry.beforeCount
        lines[#lines + 1] = string.format("%s: %s (%d×)",
            GetString(BATTLESCROLLS_TOOLTIP_DELAY_BEFORE), formatWeaveTime(beforeAvg), entry.beforeCount)
    end

    -- Missed LAs (skill→skill after this ability)
    if entry.weavingErrors > 0 then
        lines[#lines + 1] = string.format("%s: %d", GetString(BATTLESCROLLS_STAT_MISSED_LA), entry.weavingErrors)
    end

    table.insert(lines, "")

    utils.appendAbilityIdLine(lines, entry.abilityId)

    return table.concat(lines, "\n")
end

-------------------------
-- Proc Tooltip Builder
-------------------------

---Builds tooltip text for a proc entry, showing per-enemy breakdown
---@param procData ProcData
---@param unitNames table<number, string>
---@return string text Formatted tooltip text with per-enemy breakdown
local function buildProcTooltipText(procData, unitNames)
    local lines = {}

    lines[#lines + 1] = string.format("%s: %s", GetString(BATTLESCROLLS_TOOLTIP_TOTAL),
        zo_strformat(GetString(BATTLESCROLLS_STAT_TOTAL_PROCS), procData.totalProcs))

    if procData.meanIntervalMs > 0 then
        lines[#lines + 1] = string.format("%s: %s",
            GetString(BATTLESCROLLS_TOOLTIP_MEAN_INTERVAL), formatSeconds(procData.meanIntervalMs / 1000))
    end
    if procData.medianIntervalMs > 0 then
        lines[#lines + 1] = string.format("%s: %s",
            GetString(BATTLESCROLLS_TOOLTIP_MEDIAN_INTERVAL), formatSeconds(procData.medianIntervalMs / 1000))
    end

    if procData.procsByEnemy and #procData.procsByEnemy > 0 then
        lines[#lines + 1] = ""
        lines[#lines + 1] = GetString(BATTLESCROLLS_TOOLTIP_BY_TARGET) .. ":"

        local sortedByEnemy = {}
        for _, enemyData in ipairs(procData.procsByEnemy) do
            sortedByEnemy[#sortedByEnemy + 1] = enemyData
        end
        table.sort(sortedByEnemy, function(a, b)
            return a.procCount > b.procCount
        end)

        for _, enemyData in ipairs(sortedByEnemy) do
            local rawName = unitNames[enemyData.unitId] or GetString(BATTLESCROLLS_UNKNOWN)
            local enemyName = zo_strformat(SI_UNIT_NAME, rawName)
            local percent = procData.totalProcs > 0 and (enemyData.procCount / procData.totalProcs * 100) or 0
            lines[#lines + 1] = string.format("  %s: %d (%.1f%%)", enemyName, enemyData.procCount, percent)
        end
    end

    table.insert(lines, "")

    utils.appendAbilityIdLine(lines, procData.abilityId)

    return table.concat(lines, "\n")
end

-------------------------
-- Ultimate Section
-------------------------

---Renders the ultimate tracking section into the list
---Appends "Includes X: uptime%, ~N" lines for fixed-rate silent ultimate
---sources/drains (Heroism, Timidity) whose uptime lives in the encounter's
---player-effect stats
---@param lines string[]
---@param effectsOnPlayer table<number, EffectStats>|nil
---@param ratePerTick table<number, number> Buff/debuff ability id -> Ultimate per tick
---@param durationSec number
---@return boolean appended True when at least one line was added
local function appendSilentUltLines(lines, effectsOnPlayer, ratePerTick, durationSec)
    if not effectsOnPlayer then
        return false
    end
    local ids = {}
    for buffId in pairs(ratePerTick) do
        local stats = effectsOnPlayer[buffId]
        if stats and stats.totalActiveTimeMs > 0 then
            ids[#ids + 1] = buffId
        end
    end
    table.sort(ids)
    for _, buffId in ipairs(ids) do
        local activeMs = effectsOnPlayer[buffId].totalActiveTimeMs
        local approx = math.ceil(activeMs / BattleScrolls.ultimate.FIXED_RATE_TICK_MS) * ratePerTick[buffId]
        local uptimePct = durationSec > 0 and (activeMs / (durationSec * 1000) * 100) or 0
        table.insert(lines, zo_strformat(GetString(BATTLESCROLLS_ULT_HEROISM_LINE),
            utils.getAbilityDisplayName(buffId), string.format("%.1f", uptimePct), approx))
    end
    return #ids > 0
end

---@param list any
---@param ult UltimateData
---@param durationSec number
---@param effectsOnPlayer table<number, EffectStats>|nil Player-effect stats (source of Heroism/Timidity uptimes for tooltips)
local function renderUltimateSection(list, ult, durationSec, effectsOnPlayer)
    -- Ultimate at combat entry
    EntryBuilder.addEntry(list, {
        label = GetString(BATTLESCROLLS_STAT_ULT_AT_ENTRY),
        sublabel = string.format("%d / %d", ult.startUlt, ult.maxUlt),
        icon = StatIcons.SUMMARY,
        header = GetString(BATTLESCROLLS_HEADER_ULTIMATE),
    })

    -- Total generated (+rate) and drained
    if ult.totalGained > 0 then
        EntryBuilder.addEntry(list, {
            label = GetString(BATTLESCROLLS_STAT_ULT_GENERATED),
            sublabel = string.format("%d (%s)", ult.totalGained, formatRate(durationSec > 0 and ult.totalGained / durationSec or 0)),
            icon = StatIcons.DPS,
        })
    end
    if ult.totalDrained > 0 then
        -- Minor Timidity drains silently into totalDrained; surface its
        -- uptime and trait-less estimate here
        local drainLines = {}
        appendSilentUltLines(drainLines, effectsOnPlayer, BattleScrolls.ultimate.TIMIDITY_DEBUFFS, durationSec)
        EntryBuilder.addEntry(list, {
            label = GetString(BATTLESCROLLS_STAT_ULT_DRAINED),
            sublabel = tostring(ult.totalDrained),
            icon = StatIcons.DAMAGE_TAKEN,
            tooltip = #drainLines > 0 and {
                type = "text",
                title = GetString(BATTLESCROLLS_STAT_ULT_DRAINED),
                text = table.concat(drainLines, "\n"),
            } or nil,
        })
    end

    -- Gains by source (id 0 = base generation)
    local gainTotal = 0
    local sources = {}
    for abilityId, gain in pairs(ult.gainByAbilityId) do
        gainTotal = gainTotal + gain.total
        sources[#sources + 1] = { abilityId = abilityId, gain = gain }
    end
    table.sort(sources, function(a, b) return a.gain.total > b.gain.total end)

    local isFirst = true
    for _, source in ipairs(sources) do
        local gain = source.gain
        local name, icon
        if source.abilityId == 0 then
            name = GetString(BATTLESCROLLS_ULT_BASE_GENERATION)
            icon = StatIcons.DPS
        else
            name = zo_strformat("<<C:1>>", utils.getAbilityDisplayName(source.abilityId))
            icon = utils.getAbilityIcon(source.abilityId)
        end
        local pct = gainTotal > 0 and (gain.total / gainTotal * 100) or 0

        local tooltipLines = {
            string.format("%s: %d (%.1f%%)", GetString(BATTLESCROLLS_TOOLTIP_TOTAL), gain.total, pct),
            string.format("%s", formatRate(durationSec > 0 and gain.total / durationSec or 0)),
        }
        -- Gain amounts vary per source (e.g. scaling energizes) - show the
        -- usual tick spread; the base bucket has no discrete ticks
        if gain.ticks > 0 then
            table.insert(tooltipLines, "")
            table.insert(tooltipLines, string.format("%s: %d", GetString(BATTLESCROLLS_TOOLTIP_TICKS), gain.ticks))
            table.insert(tooltipLines, string.format("%s: %.1f", GetString(BATTLESCROLLS_TOOLTIP_AVG_TICK), gain.total / gain.ticks))
            table.insert(tooltipLines, string.format("%s: %d", GetString(BATTLESCROLLS_TOOLTIP_MIN_TICK), gain.minTick))
            table.insert(tooltipLines, string.format("%s: %d", GetString(BATTLESCROLLS_TOOLTIP_MAX_TICK), gain.maxTick))
        end
        -- Heroism generates silently and lands in the base bucket (the
        -- Decisive trait makes an exact split impossible); its uptime is
        -- already in the player-effect stats - list it here with the
        -- trait-less estimate
        if source.abilityId == 0 then
            local heroismLines = {}
            if appendSilentUltLines(heroismLines, effectsOnPlayer, BattleScrolls.ultimate.HEROISM_BUFFS, durationSec) then
                table.insert(tooltipLines, "")
                for _, line in ipairs(heroismLines) do
                    table.insert(tooltipLines, line)
                end
            end
        end
        if source.abilityId ~= 0 then
            table.insert(tooltipLines, "")
            utils.appendAbilityIdLine(tooltipLines, source.abilityId)
        end

        EntryBuilder.addEntry(list, {
            label = name,
            sublabel = string.format("%d (%.1f%%)", gain.total, pct),
            icon = icon,
            frame = source.abilityId ~= 0,
            header = isFirst and GetString(BATTLESCROLLS_HEADER_ULT_SOURCES) or nil,
            tooltip = { type = "text", title = name, text = table.concat(tooltipLines, "\n") },
        })
        isFirst = false
    end

    -- Casts, aggregated per ultimate with per-cast times in the tooltip
    if #ult.casts > 0 then
        local byUlt = {}
        local ultOrder = {}
        for _, cast in ipairs(ult.casts) do
            if not byUlt[cast.abilityId] then
                byUlt[cast.abilityId] = {}
                ultOrder[#ultOrder + 1] = cast.abilityId
            end
            table.insert(byUlt[cast.abilityId], cast.timeMs)
        end

        isFirst = true
        for _, abilityId in ipairs(ultOrder) do
            local times = byUlt[abilityId]
            local name = zo_strformat("<<C:1>>", utils.getAbilityDisplayName(abilityId))
            local timeStrings = {}
            for _, timeMs in ipairs(times) do
                timeStrings[#timeStrings + 1] = utils.formatDuration(timeMs)
            end
            local tooltipLines = {
                string.format("%s: %d", GetString(BATTLESCROLLS_STAT_CASTS), #times),
                "",
                table.concat(timeStrings, ", "),
                "",
            }
            utils.appendAbilityIdLine(tooltipLines, abilityId)

            EntryBuilder.addEntry(list, {
                label = name,
                sublabel = string.format("%d× (%s)", #times, timeStrings[1]),
                icon = utils.getAbilityIcon(abilityId),
                frame = true,
                header = isFirst and GetString(BATTLESCROLLS_HEADER_ULT_CASTS) or nil,
                tooltip = { type = "text", title = name, text = table.concat(tooltipLines, "\n") },
            })
            isFirst = false
        end
    end
end

-------------------------
-- Crux Section
-------------------------

---Renders the Arcanist Crux discipline section into the list
---@param list any
---@param crux CruxData
local function renderCruxSection(list, crux)
    local underTotal = (crux.spenderUnder[1] or 0) + (crux.spenderUnder[2] or 0) + (crux.spenderUnder[3] or 0)
    local needsHeader = true
    local function takeHeader()
        if needsHeader then
            needsHeader = false
            return GetString(BATTLESCROLLS_HEADER_CRUX)
        end
        return nil
    end

    -- Generators
    if crux.generatorCasts > 0 then
        local atFullPct = crux.generatorAtFull / crux.generatorCasts * 100
        EntryBuilder.addEntry(list, {
            label = GetString(BATTLESCROLLS_STAT_CRUX_GENERATORS),
            sublabel = tostring(crux.generatorCasts),
            icon = StatIcons.DPS,
            header = takeHeader(),
        })
        EntryBuilder.addEntry(list, {
            label = GetString(BATTLESCROLLS_STAT_CRUX_AT_FULL),
            sublabel = string.format("%d (%.1f%%)", crux.generatorAtFull, atFullPct),
            icon = StatIcons.DAMAGE_TAKEN,
        })
    end

    -- Spenders
    if crux.spenderCasts > 0 then
        EntryBuilder.addEntry(list, {
            label = GetString(BATTLESCROLLS_STAT_CRUX_SPENDERS),
            sublabel = tostring(crux.spenderCasts),
            icon = StatIcons.AOE,
            header = takeHeader(),
        })
        local underPct = underTotal / crux.spenderCasts * 100
        local tooltipLines = {}
        for cruxCount = 0, 2 do
            tooltipLines[#tooltipLines + 1] = zo_strformat(GetString(BATTLESCROLLS_CRUX_AT_N), cruxCount, crux.spenderUnder[cruxCount + 1] or 0)
        end
        EntryBuilder.addEntry(list, {
            label = GetString(BATTLESCROLLS_STAT_CRUX_UNDER),
            sublabel = string.format("%d (%.1f%%)", underTotal, underPct),
            icon = StatIcons.DAMAGE_TAKEN,
            tooltip = {
                type = "text",
                title = GetString(BATTLESCROLLS_STAT_CRUX_UNDER),
                text = table.concat(tooltipLines, "\n"),
            },
        })
    end

    -- Crux consumed outside tracked casts (natural expiry, death)
    if crux.passiveEvents and crux.passiveEvents > 0 then
        EntryBuilder.addEntry(list, {
            label = GetString(BATTLESCROLLS_STAT_CRUX_PASSIVE),
            sublabel = string.format("%d (%d×)", crux.passiveStacks, crux.passiveEvents),
            icon = StatIcons.DURATION,
            header = takeHeader(),
            tooltip = {
                type = "text",
                title = GetString(BATTLESCROLLS_STAT_CRUX_PASSIVE),
                text = GetString(BATTLESCROLLS_STAT_CRUX_PASSIVE_TT),
            },
        })
    end

    -- Crux gained per ability: cast generators contribute casts minus
    -- wasted (each non-full cast generates exactly one), proc-attributed
    -- conditional sources contribute their paired gains
    local gains = {}
    for abilityId, activity in pairs(crux.byAbility) do
        if not BattleScrolls.crux.CRUX_SPENDERS[abilityId] then
            local gained = (activity.casts or 0) - (activity.bad or 0)
            if gained > 0 then
                gains[#gains + 1] = { abilityId = abilityId, count = gained, casts = activity.casts }
            end
        end
    end
    if crux.conditionalGains then
        for abilityId, count in pairs(crux.conditionalGains) do
            if count > 0 then
                gains[#gains + 1] = { abilityId = abilityId, count = count, proc = true }
            end
        end
    end
    table.sort(gains, function(a, b) return a.count > b.count end)

    local isFirstGain = true
    for _, entry in ipairs(gains) do
        local name = zo_strformat("<<C:1>>", utils.getAbilityDisplayName(entry.abilityId))
        local tooltipLines = {}
        if entry.proc then
            tooltipLines[1] = GetString(BATTLESCROLLS_STAT_CRUX_CONDITIONAL_TT)
        else
            tooltipLines[1] = string.format("%s: %d", GetString(BATTLESCROLLS_STAT_CASTS), entry.casts)
        end
        tooltipLines[2] = ""
        utils.appendAbilityIdLine(tooltipLines, entry.abilityId)
        EntryBuilder.addEntry(list, {
            label = name,
            sublabel = string.format("+%d", entry.count),
            icon = utils.getAbilityIcon(entry.abilityId),
            frame = true,
            header = isFirstGain and GetString(BATTLESCROLLS_HEADER_CRUX_GAINED) or nil,
            tooltip = { type = "text", title = name, text = table.concat(tooltipLines, "\n") },
        })
        isFirstGain = false
    end
    if crux.unattributedGains and crux.unattributedGains > 0 then
        EntryBuilder.addEntry(list, {
            label = GetString(BATTLESCROLLS_STAT_CRUX_OTHER),
            sublabel = string.format("+%d", crux.unattributedGains),
            icon = StatIcons.DURATION,
            header = isFirstGain and GetString(BATTLESCROLLS_HEADER_CRUX_GAINED) or nil,
            tooltip = {
                type = "text",
                title = GetString(BATTLESCROLLS_STAT_CRUX_OTHER),
                -- 217699 = Banner Bearer, the known untracked source
                text = zo_strformat(GetString(BATTLESCROLLS_STAT_CRUX_OTHER_TT), utils.getAbilityDisplayName(217699)),
            },
        })
    end

    -- Per-ability discipline breakdown (only abilities with bad casts)
    local badAbilities = {}
    for abilityId, activity in pairs(crux.byAbility) do
        if activity.bad > 0 then
            badAbilities[#badAbilities + 1] = { abilityId = abilityId, casts = activity.casts, bad = activity.bad }
        end
    end
    table.sort(badAbilities, function(a, b) return a.bad > b.bad end)

    local isFirst = true
    for _, entry in ipairs(badAbilities) do
        local name = zo_strformat("<<C:1>>", utils.getAbilityDisplayName(entry.abilityId))
        local badPct = entry.casts > 0 and (entry.bad / entry.casts * 100) or 0
        local tooltipLines = {
            string.format("%s: %d", GetString(BATTLESCROLLS_STAT_CASTS), entry.casts),
            "",
        }
        utils.appendAbilityIdLine(tooltipLines, entry.abilityId)

        EntryBuilder.addEntry(list, {
            label = name,
            sublabel = string.format("%d / %d (%.1f%%)", entry.bad, entry.casts, badPct),
            icon = utils.getAbilityIcon(entry.abilityId),
            frame = true,
            header = isFirst and GetString(BATTLESCROLLS_HEADER_CRUX_BY_ABILITY) or nil,
            tooltip = { type = "text", title = name, text = table.concat(tooltipLines, "\n") },
        })
        isFirst = false
    end
end

-------------------------
-- Z'en / DoT Stacking Section
-------------------------

---Computes summary stats from a 12-slot zen bucket array
---@param buckets number[]
---@return number totalMs
---@return number avgDots
---@return number zenPct Z'en debuff uptime %
---@return number anyDotPct Time with >=1 DoT %
local function computeZenSummary(buckets)
    local totalMs = 0
    local dotWeightedMs = 0
    local zenMs = 0
    for dots = 0, 5 do
        local noZen = buckets[dots * 2 + 1] or 0
        local withZen = buckets[dots * 2 + 2] or 0
        totalMs = totalMs + noZen + withZen
        dotWeightedMs = dotWeightedMs + dots * (noZen + withZen)
        zenMs = zenMs + withZen
    end
    if totalMs == 0 then
        return 0, 0, 0, 0
    end
    local idleMs = (buckets[1] or 0) + (buckets[2] or 0)
    return totalMs,
        dotWeightedMs / totalMs,
        zenMs / totalMs * 100,
        (totalMs - idleMs) / totalMs * 100
end

---Renders the Z'en / DoT stacking section into the list
---@param list any
---@param zen ZenData
---@param encounter DecodedEncounter
local function renderZenSection(list, zen, encounter)
    -- Stable boss ordering by unitTag
    local tags = {}
    for unitTag in pairs(zen) do
        tags[#tags + 1] = unitTag
    end
    table.sort(tags)

    local isFirst = true
    for _, unitTag in ipairs(tags) do
        local buckets = zen[unitTag]
        local totalMs, avgDots, zenPct, anyDotPct = computeZenSummary(buckets)
        if totalMs > 0 then
            -- Keys are "bossTag:tagSeq" - the same shape bossSeqNames uses
            local rawBossName = (encounter.bossSeqNames and encounter.bossSeqNames[unitTag])
                or unitTag:match("^(.-):%d+$") or unitTag
            local bossName = zo_strformat(SI_UNIT_NAME, rawBossName)

            local tooltipLines = {
                string.format("%s: %.1f", GetString(BATTLESCROLLS_ZEN_AVG_DOTS), avgDots),
                string.format("%s: %.1f%%", GetString(BATTLESCROLLS_ZEN_UPTIME), zenPct),
                string.format("%s: %.1f%%", GetString(BATTLESCROLLS_ZEN_POTENTIAL), anyDotPct),
                "",
            }
            for dots = 0, 5 do
                local noZen = buckets[dots * 2 + 1] or 0
                local withZen = buckets[dots * 2 + 2] or 0
                local bucketMs = noZen + withZen
                if bucketMs > 0 then
                    local bucketPct = bucketMs / totalMs * 100
                    local zenShare = withZen / bucketMs * 100
                    local dotsLabel = zo_strformat(GetString(BATTLESCROLLS_ZEN_DOTS_LABEL), dots)
                    if withZen > 0 then
                        tooltipLines[#tooltipLines + 1] = string.format("%s: %.1f%% (%s %.0f%%)",
                            dotsLabel, bucketPct, GetString(BATTLESCROLLS_ZEN_SHORT), zenShare)
                    else
                        tooltipLines[#tooltipLines + 1] = string.format("%s: %.1f%%", dotsLabel, bucketPct)
                    end
                end
            end

            EntryBuilder.addEntry(list, {
                label = bossName,
                sublabel = zo_strformat(GetString(BATTLESCROLLS_ZEN_BOSS_SUMMARY),
                    string.format("%.1f", avgDots), string.format("%.0f", zenPct), string.format("%.0f", anyDotPct)),
                icon = StatIcons.DOT,
                header = isFirst and GetString(BATTLESCROLLS_HEADER_ZEN) or nil,
                tooltip = { type = "text", title = bossName, text = table.concat(tooltipLines, "\n") },
            })
            isFirst = false
        end
    end
end

-------------------------
-- Public Renderer API
-------------------------

---Renders the Activity stats tab
---@param ctx JournalRenderContext
---@return Effect
function ActivityRenderer.renderActivity(ctx)
    return LibEffect.Async(function()
        local list = ctx.list
        local encounter = ctx.encounter
        local unitNames = ctx.unitNames
        local durationSec = ctx.durationSec
        local weaving = encounter.weaving

        -------------------------
        -- Proc Tracking (top, right after Overview entry)
        -------------------------
        if encounter.procs and #encounter.procs > 0 then
            local isFirst = true
            for _, procData in ipairs(encounter.procs) do
                local abilityName = BattleScrolls.utils.GetScribeAwareAbilityDisplayName(procData.abilityId)
                if abilityName == "" then
                    abilityName = string.format("%s %d", GetString(BATTLESCROLLS_TOOLTIP_ABILITY), procData.abilityId)
                end

                local abilityIcon = utils.getAbilityIcon(procData.abilityId)
                local valueStr
                local totalProcsStr = zo_strformat(GetString(BATTLESCROLLS_STAT_TOTAL_PROCS), procData.totalProcs)
                if procData.medianIntervalMs > 0 then
                    valueStr = string.format("%s (%s %s)", totalProcsStr, GetString(BATTLESCROLLS_STAT_MEDIAN_INTERVAL), formatSeconds(procData.medianIntervalMs / 1000))
                else
                    valueStr = totalProcsStr
                end

                EntryBuilder.addEntry(list, {
                    label = abilityName,
                    sublabel = valueStr,
                    icon = abilityIcon,
                    frame = true,
                    header = isFirst and GetString(BATTLESCROLLS_HEADER_PROC_TRACKING) or nil,
                    tooltip = {
                        type = "text",
                        title = abilityName,
                        text = buildProcTooltipText(procData, unitNames),
                    },
                })
                isFirst = false
            end
        end
        LibEffect.Yield():Await()

        -------------------------
        -- Ultimate Section
        -------------------------
        if encounter.ultimate then
            renderUltimateSection(list, encounter.ultimate, durationSec, encounter.effectsOnPlayer)
            LibEffect.Yield():Await()
        end

        -------------------------
        -- Crux Section (Arcanist)
        -------------------------
        if encounter.crux then
            renderCruxSection(list, encounter.crux)
            LibEffect.Yield():Await()
        end

        -------------------------
        -- Resurrections
        -------------------------
        if encounter.resurrections and encounter.resurrections > 0 then
            EntryBuilder.addEntry(list, {
                label = GetString(BATTLESCROLLS_STAT_RESURRECTIONS),
                sublabel = tostring(encounter.resurrections),
                icon = StatIcons.GROUP,
                header = GetString(BATTLESCROLLS_HEADER_SUPPORT),
            })
        end

        -------------------------
        -- Z'en / DoT Stacking Section
        -------------------------
        if encounter.zen then
            renderZenSection(list, encounter.zen, encounter)
            LibEffect.Yield():Await()
        end

        -------------------------
        -- Weaving Section
        -------------------------
        if weaving then
            local totalSum, totalCount = computeWeavingTotals(weaving)

            -- Avg Cast Delay (with explanatory tooltip)
            if totalCount > 0 then
                local avgMs = totalSum / totalCount
                EntryBuilder.addEntry(list, {
                    label = GetString(BATTLESCROLLS_STAT_AVG_WEAVE_TIME),
                    sublabel = formatWeaveTime(avgMs),
                    icon = StatIcons.DURATION,
                    header = GetString(BATTLESCROLLS_HEADER_WEAVING),
                    tooltip = {
                        type = "text",
                        title = GetString(BATTLESCROLLS_STAT_AVG_WEAVE_TIME),
                        text = buildCastDelayTooltip(avgMs, totalSum, totalCount),
                    },
                })
            end

            -- Time Lost
            if totalSum > 0 then
                local timeLostSec = totalSum / 1000
                local pctOfFight = durationSec > 0 and (timeLostSec / durationSec * 100) or 0
                EntryBuilder.addEntry(list, {
                    label = GetString(BATTLESCROLLS_STAT_TIME_LOST),
                    sublabel = string.format("%s (%.1f%%)", formatSeconds(timeLostSec), pctOfFight),
                    icon = StatIcons.DURATION,
                    header = totalCount == 0 and GetString(BATTLESCROLLS_HEADER_WEAVING) or nil,
                    tooltip = {
                        type = "text",
                        title = GetString(BATTLESCROLLS_STAT_TIME_LOST),
                        text = buildTimeLostTooltip(totalSum, durationSec),
                    },
                })
            end

            -- Light attacks
            local lightAttacks = weaving.lightAttackHits
            if lightAttacks > 0 then
                local laPerSec = durationSec > 0 and (lightAttacks / durationSec) or 0
                EntryBuilder.addEntry(list, {
                    label = GetString(BATTLESCROLLS_STAT_LIGHT_ATTACKS),
                    sublabel = string.format("%d (%s)", lightAttacks, formatRate(laPerSec)),
                    icon = StatIcons.DPS,
                })
            end

            -- Heavy attacks
            local heavyAttacks = weaving.heavyAttackHits
            if heavyAttacks > 0 then
                local haPerSec = durationSec > 0 and (heavyAttacks / durationSec) or 0
                EntryBuilder.addEntry(list, {
                    label = GetString(BATTLESCROLLS_STAT_HEAVY_ATTACKS),
                    sublabel = string.format("%d (%s)", heavyAttacks, formatRate(haPerSec)),
                    icon = StatIcons.DPS,
                })
            end

            -- Skill activations
            if weaving.skillActivations > 0 then
                EntryBuilder.addEntry(list, {
                    label = GetString(BATTLESCROLLS_STAT_SKILL_ACTIVATIONS),
                    sublabel = tostring(weaving.skillActivations),
                    icon = StatIcons.SUMMARY,
                })
            end

            -- Missed light attacks (skill→skill) — with tooltip
            if weaving.totalWeavingErrors > 0 then
                EntryBuilder.addEntry(list, {
                    label = GetString(BATTLESCROLLS_STAT_MISSED_LA),
                    sublabel = tostring(weaving.totalWeavingErrors),
                    icon = StatIcons.DAMAGE_TAKEN,
                    tooltip = {
                        type = "text",
                        title = GetString(BATTLESCROLLS_STAT_MISSED_LA),
                        text = buildMissedLaTooltip(weaving.totalWeavingErrors, weaving.skillActivations),
                    },
                })
            end

            -- Double light attacks (la→la) — with tooltip
            if weaving.doubleLaErrors and weaving.doubleLaErrors > 0 then
                EntryBuilder.addEntry(list, {
                    label = GetString(BATTLESCROLLS_STAT_DOUBLE_LA),
                    sublabel = tostring(weaving.doubleLaErrors),
                    icon = StatIcons.DAMAGE_TAKEN,
                    tooltip = {
                        type = "text",
                        title = GetString(BATTLESCROLLS_STAT_DOUBLE_LA),
                        text = buildDoubleLaTooltip(weaving.doubleLaErrors, weaving.lightAttackHits),
                    },
                })
            end

            LibEffect.Yield():Await()

            -------------------------
            -- Per-Ability Weaving Breakdown
            -------------------------
            if #weaving.byAbility > 0 then
                -- Sort by activations descending (most-cast skills first)
                local sorted = {}
                for _, entry in ipairs(weaving.byAbility) do
                    sorted[#sorted + 1] = entry
                end
                table.sort(sorted, function(a, b)
                    return a.activations > b.activations
                end)

                local totalActivations = weaving.skillActivations
                local isFirst = true
                local maxAbilities = 25
                for i, entry in ipairs(sorted) do
                    if i > maxAbilities then break end

                    local abilityName = utils.getAbilityDisplayName(entry.abilityId)
                    local abilityIcon = utils.getAbilityIcon(entry.abilityId)

                    -- Sublabel: casts first (primary), then avg delay (secondary)
                    local sublabel
                    if entry.afterCount > 0 then
                        local avgMs = entry.afterSum / entry.afterCount
                        sublabel = string.format("%d× (%s)", entry.activations, formatWeaveTime(avgMs))
                    else
                        sublabel = string.format("%d×", entry.activations)
                    end

                    EntryBuilder.addEntry(list, {
                        label = zo_strformat("<<C:1>>", abilityName),
                        sublabel = sublabel,
                        icon = abilityIcon,
                        frame = true,
                        header = isFirst and GetString(BATTLESCROLLS_HEADER_WEAVING_BY_ABILITY) or nil,
                        tooltip = {
                            type = "text",
                            title = zo_strformat("<<C:1>>", abilityName),
                            text = buildWeavingAbilityTooltipText(entry, totalActivations),
                        },
                    })
                    isFirst = false

                    if i % 20 == 0 then
                        LibEffect.Yield():Await()
                    end
                end
            end

            LibEffect.Yield():Await()
        end
    end)
end

-------------------------
-- Overview Panel
-------------------------

---Builds a PanelSpec for the Activity tab overview panel
---Q2: Weaving summary stats
---Q3: Top abilities by cast count with icons
---Q4: Proc summary with icons (only when procs exist)
---@param ctx { arithmancer: table, encounter: table, durationS: number, unitNames: table, filters: table, abilityInfo: table }
---@return PanelSpec
function ActivityRenderer.buildActivityPanelSpec(ctx)
    return {
        layout = "wide-right",
        build = function(q2, q3)
            local encounter = ctx.encounter
            local durationS = ctx.durationS
            local weaving = encounter.weaving
            -- mount() anchors from the column top on every call, so both
            -- Q2 sections must go through ONE call or they overlap
            local q2Sections = {}

            -------------------------
            -- Q2: Weaving Summary
            -------------------------
            if weaving then
                local totalSum, totalCount = computeWeavingTotals(weaving)

                local avgWeaveRow
                if totalCount > 0 then
                    avgWeaveRow = q2:StatRow(GetString(BATTLESCROLLS_STAT_AVG_WEAVE_TIME), formatWeaveTime(totalSum / totalCount))
                end

                local timeLostRow
                if totalSum > 0 then
                    local timeLostSec = totalSum / 1000
                    local pctOfFight = durationS > 0 and (timeLostSec / durationS * 100) or 0
                    timeLostRow = q2:StatRow(GetString(BATTLESCROLLS_STAT_TIME_LOST), string.format("%s (%.1f%%)", formatSeconds(timeLostSec), pctOfFight))
                end

                local lightAttacks = weaving.lightAttackHits
                local laRow
                if lightAttacks > 0 then
                    local laPerSec = durationS > 0 and (lightAttacks / durationS) or 0
                    laRow = q2:StatRow(GetString(BATTLESCROLLS_STAT_LIGHT_ATTACKS), string.format("%d (%s)", lightAttacks, formatRate(laPerSec)))
                end

                local heavyAttacks = weaving.heavyAttackHits
                local haRow
                if heavyAttacks > 0 then
                    local haPerSec = durationS > 0 and (heavyAttacks / durationS) or 0
                    haRow = q2:StatRow(GetString(BATTLESCROLLS_STAT_HEAVY_ATTACKS), string.format("%d (%s)", heavyAttacks, formatRate(haPerSec)))
                end

                local skillRow = weaving.skillActivations > 0
                    and q2:StatRow(GetString(BATTLESCROLLS_STAT_SKILL_ACTIVATIONS), tostring(weaving.skillActivations))
                    or nil

                local missedLaRow = weaving.totalWeavingErrors > 0
                    and q2:StatRow(GetString(BATTLESCROLLS_STAT_MISSED_LA), tostring(weaving.totalWeavingErrors))
                    or nil

                local doubleLaRow = weaving.doubleLaErrors and weaving.doubleLaErrors > 0
                    and q2:StatRow(GetString(BATTLESCROLLS_STAT_DOUBLE_LA), tostring(weaving.doubleLaErrors))
                    or nil

                q2Sections[#q2Sections + 1] = q2:Section(GetString(BATTLESCROLLS_HEADER_WEAVING),
                    avgWeaveRow, timeLostRow, laRow, haRow, skillRow, missedLaRow, doubleLaRow)
            end

            -------------------------
            -- Q2: Ultimate Summary
            -------------------------
            local ult = encounter.ultimate
            if ult then
                local entryRow = q2:StatRow(GetString(BATTLESCROLLS_STAT_ULT_AT_ENTRY), string.format("%d / %d", ult.startUlt, ult.maxUlt))
                local generatedRow
                if ult.totalGained > 0 then
                    generatedRow = q2:StatRow(GetString(BATTLESCROLLS_STAT_ULT_GENERATED),
                        string.format("%d (%s)", ult.totalGained, formatRate(durationS > 0 and ult.totalGained / durationS or 0)))
                end
                local castsRow = #ult.casts > 0
                    and q2:StatRow(GetString(BATTLESCROLLS_HEADER_ULT_CASTS), tostring(#ult.casts))
                    or nil
                local resRow = encounter.resurrections and encounter.resurrections > 0
                    and q2:StatRow(GetString(BATTLESCROLLS_STAT_RESURRECTIONS), tostring(encounter.resurrections))
                    or nil
                q2Sections[#q2Sections + 1] = q2:Section(GetString(BATTLESCROLLS_HEADER_ULTIMATE),
                    entryRow, generatedRow, castsRow, resRow)
            end

            if #q2Sections > 0 then
                q2:mount(SECTION_GAP, 0, unpack(q2Sections))
            end

            LibEffect.Yield():Await()

            -------------------------
            -- Q3: Procs + Abilities (combined right column)
            -------------------------
            local sections = {}

            if encounter.procs and #encounter.procs > 0 then
                local maxProcs = q3:maxItems(ROW_CONTENT.STAT_ROW, 10)
                local rows = {}
                for i, procData in ipairs(encounter.procs) do
                    if i > maxProcs then break end
                    local name = BattleScrolls.utils.GetScribeAwareAbilityDisplayName(procData.abilityId)
                    if name == "" then
                        name = string.format("ID %d", procData.abilityId)
                    end
                    local icon = utils.getAbilityIcon(procData.abilityId)
                    local text
                    if procData.medianIntervalMs > 0 then
                        text = string.format("%s — %d (%s)", name, procData.totalProcs, formatSeconds(procData.medianIntervalMs / 1000))
                    else
                        text = string.format("%s — %d", name, procData.totalProcs)
                    end
                    rows[#rows + 1] = q3:IconTextRow(icon, text, nil, true)
                end

                if #rows > 0 then
                    sections[#sections + 1] = q3:Section(GetString(BATTLESCROLLS_HEADER_PROC_TRACKING), rows)
                end
            end

            if weaving and #weaving.byAbility > 0 then
                local sorted = {}
                for _, entry in ipairs(weaving.byAbility) do
                    sorted[#sorted + 1] = entry
                end
                table.sort(sorted, function(a, b)
                    return a.activations > b.activations
                end)

                local maxAbilities = q3:maxItems(ROW_CONTENT.STAT_ROW, 10)
                local rows = {}
                for i, entry in ipairs(sorted) do
                    if i > maxAbilities then break end
                    local name = zo_strformat("<<C:1>>", utils.getAbilityDisplayName(entry.abilityId))
                    local icon = utils.getAbilityIcon(entry.abilityId)
                    local text
                    if entry.afterCount > 0 then
                        local avgMs = entry.afterSum / entry.afterCount
                        text = string.format("%s — %d× (%s)", name, entry.activations, formatWeaveTime(avgMs))
                    else
                        text = string.format("%s — %d×", name, entry.activations)
                    end
                    rows[#rows + 1] = q3:IconTextRow(icon, text, nil, true)
                end

                if #rows > 0 then
                    sections[#sections + 1] = q3:Section(GetString(BATTLESCROLLS_HEADER_WEAVING_BY_ABILITY), rows)
                end
            end

            if #sections > 0 then
                q3:mount(SECTION_GAP, Q3_INSET, unpack(sections))
            end
        end,
    }
end

-- Export to namespace
journal.renderers.activity = ActivityRenderer
