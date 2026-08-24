-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.Endgame = EPC.Endgame or {}
local E = EPC.Endgame

E.validFocus = {
    AUTO = true,
    DPS = true,
    GOLD = true,
    XP_CP = true,
    GEAR = true,
    DUNGEONS = true,
    TRIALS = true,
    SOLO = true,
    QUESTING = true,
}

E.focusOrder = {"AUTO", "DPS", "GOLD", "XP_CP", "GEAR", "DUNGEONS", "TRIALS", "SOLO", "QUESTING"}
E.focusLabels = {
    AUTO = "AUTO",
    DPS = "DPS",
    GOLD = "GOLD",
    XP_CP = "XP / CP",
    GEAR = "GEAR",
    DUNGEONS = "DUNGEONS",
    TRIALS = "TRIALS",
    SOLO = "SOLO",
    QUESTING = "QUESTING",
}

local function safeNumber(value, fallback)
    value = tonumber(value)
    if value == nil then return fallback or 0 end
    return value
end

local function formatNumber(value)
    local number = math.floor(safeNumber(value, 0) + 0.5)
    local sign = number < 0 and "-" or ""
    local digits = tostring(math.abs(number))
    local parts = {}
    while #digits > 3 do
        table.insert(parts, 1, string.sub(digits, -3))
        digits = string.sub(digits, 1, -4)
    end
    table.insert(parts, 1, digits)
    return sign .. table.concat(parts, ",")
end

function E:Initialize()
    if not EPC.saved then return end
    local focus = tostring(EPC.saved.coachFocus or "AUTO")
    EPC.saved.coachFocus = self.validFocus[focus] and focus or "AUTO"
end

function E:GetFocus()
    local focus = EPC.saved and EPC.saved.coachFocus or "DPS"
    if not self.validFocus[focus] then focus = "DPS" end
    return focus
end

function E:GetFocusLabel(focus)
    focus = focus or self:GetFocus()
    return self.focusLabels[focus] or focus
end

function E:SetFocus(focus)
    focus = string.upper(tostring(focus or "DPS"))
    focus = string.gsub(focus, "[%s/]+", "_")
    if focus == "XP" or focus == "CP" or focus == "XP_CP_" then focus = "XP_CP" end
    if focus == "SMART" then focus = "AUTO" end
    if not self.validFocus[focus] or not EPC.saved then return end

    EPC.saved.coachFocus = focus
    if focus == "GOLD" then
        EPC.saved.activityGoal = "GOLD"
    elseif focus == "XP_CP" then
        EPC.saved.activityGoal = "XP"
    end

    if EPC.Activities then EPC.Activities.selectedKey = nil end
    EPC:RequestRefresh("coach-focus")
end

function E:GetChampionSummary(snapshot)
    local summary = {
        available = false,
        startSlot = 0,
        endSlot = 0,
        totalSlots = 0,
        slottedCount = 0,
        emptySlots = 0,
        slotted = {},
        disciplines = {},
    }

    if safeNumber(snapshot and snapshot.level, 1) < 50 then return summary end
    if type(GetAssignableChampionBarStartAndEndSlots) ~= "function" or type(GetSlotBoundId) ~= "function" then
        return summary
    end

    local ok, startSlot, endSlot = pcall(GetAssignableChampionBarStartAndEndSlots)
    if not ok or not startSlot or not endSlot then return summary end

    summary.available = true
    summary.startSlot = startSlot
    summary.endSlot = endSlot
    summary.totalSlots = math.max(0, endSlot - startSlot + 1)

    for slotIndex = startSlot, endSlot do
        local skillId = 0
        local boundOk, boundId = pcall(GetSlotBoundId, slotIndex, HOTBAR_CATEGORY_CHAMPION)
        if boundOk then skillId = safeNumber(boundId, 0) end

        if skillId > 0 then
            local name = "Champion Skill"
            if type(GetChampionSkillName) == "function" then
                local nameOk, returnedName = pcall(GetChampionSkillName, skillId)
                if nameOk and returnedName and returnedName ~= "" then name = returnedName end
            end

            local points = 0
            if type(GetNumPointsSpentOnChampionSkill) == "function" then
                local pointOk, returnedPoints = pcall(GetNumPointsSpentOnChampionSkill, skillId)
                if pointOk then points = safeNumber(returnedPoints, 0) end
            end

            local disciplineId = 0
            if type(GetRequiredChampionDisciplineIdForSlot) == "function" then
                local discOk, returnedDisciplineId = pcall(GetRequiredChampionDisciplineIdForSlot, slotIndex, HOTBAR_CATEGORY_CHAMPION)
                if discOk then disciplineId = safeNumber(returnedDisciplineId, 0) end
            end

            local disciplineName = "Champion"
            if disciplineId > 0 and type(GetChampionDisciplineName) == "function" then
                local discNameOk, returnedName = pcall(GetChampionDisciplineName, disciplineId)
                if discNameOk and returnedName and returnedName ~= "" then disciplineName = returnedName end
            end

            summary.slottedCount = summary.slottedCount + 1
            summary.disciplines[disciplineName] = (summary.disciplines[disciplineName] or 0) + 1
            summary.slotted[#summary.slotted + 1] = {
                slotIndex = slotIndex,
                skillId = skillId,
                name = name,
                points = points,
                disciplineId = disciplineId,
                disciplineName = disciplineName,
            }
        end
    end

    summary.emptySlots = math.max(0, summary.totalSlots - summary.slottedCount)
    return summary
end

function E:GetDerivedStats()
    local stats = {
        damage = 0,
        crit = 0,
        penetration = 0,
        physicalResistance = 0,
        spellResistance = 0,
    }
    if type(GetPlayerStat) ~= "function" then return stats end

    local bonusOption = STAT_BONUS_OPTION_APPLY_BONUS or STAT_BONUS_OPTION_DONT_APPLY_BONUS or 0
    local function read(constant)
        if constant == nil then return 0 end
        local ok, value = pcall(GetPlayerStat, constant, bonusOption)
        if ok then return safeNumber(value, 0) end
        return 0
    end

    stats.damage = read(STAT_WEAPON_AND_SPELL_DAMAGE)
    stats.crit = read(STAT_CRITICAL_CHANCE or STAT_CRITICAL_STRIKE)
    stats.penetration = math.max(read(STAT_SPELL_PENETRATION), read(STAT_PHYSICAL_PENETRATION))
    stats.physicalResistance = read(STAT_PHYSICAL_RESIST)
    stats.spellResistance = read(STAT_SPELL_RESIST)
    return stats
end

function E:ComputePreparationScores(snapshot, gearScore, buildScore, championSummary)
    local cp = championSummary or self:GetChampionSummary(snapshot)
    local cpCoverage = cp.totalSlots > 0 and (cp.slottedCount / cp.totalSlots) or 0
    local completeSets = safeNumber(snapshot.gear and snapshot.gear.completeSetCount, 0)
    local base = (safeNumber(gearScore, 0) * 0.48) + (safeNumber(buildScore, 0) * 0.42) + (cpCoverage * 10)

    local scores = {}
    local function clamp(v) return EPC:Clamp(math.floor(v + 0.5), 0, 100) end
    scores.SOLO = clamp(base + (snapshot.healthMax >= 20000 and 6 or 0) + 4)
    scores.DUNGEONS = clamp(base + math.min(8, completeSets * 4))
    scores.TRIALS = clamp(base - 6 + math.min(12, completeSets * 5))
    scores.DPS = clamp(base + math.min(8, completeSets * 3))
    scores.GEAR = clamp((gearScore * 0.75) + math.min(25, completeSets * 10))
    scores.XP_CP = clamp((buildScore * 0.55) + (cpCoverage * 25) + 20)
    scores.GOLD = 75
    scores.QUESTING = clamp((buildScore * 0.65) + 30)
    return scores
end

function E:GetFocusAdvice(snapshot, gearScore, buildScore, championSummary, preparationScores)
    local focus = self:GetFocus()
    local cp = championSummary or self:GetChampionSummary(snapshot)
    local scores = preparationScores or self:ComputePreparationScores(snapshot, gearScore, buildScore, cp)
    local completeSets = safeNumber(snapshot.gear and snapshot.gear.completeSetCount, 0)
    local lastFight = EPC.Combat and EPC.Combat:GetLastFight() or nil
    local advice = { items = {} }

    if focus == "DPS" then
        advice.title = "DPS optimization focus"
        advice.description = "Use this mode to line up gear, Champion slottables, combat results, and your current damage profile. The coach never casts skills or changes your build automatically."
        advice.items[#advice.items + 1] = completeSets >= 2 and "Two or more complete equipped set bonuses detected" or "Finish the set bonuses your DPS setup is built around"
        advice.items[#advice.items + 1] = cp.emptySlots > 0 and string.format("Fill %d empty Champion slottable slot%s", cp.emptySlots, cp.emptySlots == 1 and "" or "s") or "Review Champion slottables against your current damage style"
        advice.items[#advice.items + 1] = lastFight and string.format("Last fight: %s DPS over %.1fs; use COMBAT for the breakdown", formatNumber(lastFight.dps), lastFight.duration or 0) or "Complete a combat encounter, then open COMBAT for a measured DPS sample"
    elseif focus == "GOLD" then
        advice.title = "Gold-making focus"
        advice.description = "The Activity planner weights direct gold, repeatability, measured local gold/hour, and reward value. Market resale value is not guessed unless a market-data integration is added later."
        advice.items = {"Open ACTIVITY and use GOLD ranking", "Favor repeatable routines with reliable direct rewards", "Route accepted gold-value quests through MAP to reduce travel time"}
    elseif focus == "XP_CP" then
        advice.title = "XP / Champion Point focus"
        advice.description = "The coach prioritizes repeatable XP, daily bonuses, and your own measured quest XP/hour. Champion Point slot coverage is also checked at level 50+."
        advice.items[#advice.items + 1] = "Open ACTIVITY and use XP ranking"
        advice.items[#advice.items + 1] = cp.emptySlots > 0 and string.format("You have %d empty Champion slottable slot%s", cp.emptySlots, cp.emptySlots == 1 and "" or "s") or "Champion slottable bar is filled"
        advice.items[#advice.items + 1] = "Use your local quest history to compare XP/hour instead of relying only on static estimates"
    elseif focus == "GEAR" then
        advice.title = "Gear optimization focus"
        advice.description = "This mode emphasizes complete set bonuses, quality, traits, enchants, and weapon pairing. It reports what is equipped without pretending one trait is universally best for every build."
        advice.items[#advice.items + 1] = string.format("Complete equipped sets detected: %d", completeSets)
        advice.items[#advice.items + 1] = string.format("Average equipped quality: %.1f", safeNumber(snapshot.gear and snapshot.gear.averageQuality, 0))
        advice.items[#advice.items + 1] = "Use the GEAR tab to inspect set, trait, enchant, and weapon signals"
    elseif focus == "DUNGEONS" then
        advice.title = string.format("Dungeon preparation score: %d / 100", scores.DUNGEONS or 0)
        advice.description = "A preparation score is a checklist signal, not a guarantee that a veteran dungeon will be easy. Mechanics, group composition, and player execution still matter."
        advice.items = {"Match Champion slottables and bars to your dungeon role", "Bring a coherent set setup before expensive upgrades", "Use COMBAT after boss fights to identify measurable damage gaps"}
    elseif focus == "TRIALS" then
        advice.title = string.format("Trial preparation score: %d / 100", scores.TRIALS or 0)
        advice.description = "Trial preparation weighs build, gear, set completion, and Champion slot coverage. It does not certify clear readiness because mechanics and group requirements vary by trial."
        advice.items = {"Finish coherent set bonuses and weapon-bar synergy", "Fill and review Champion slottables for your assigned role", "Measure real boss performance in COMBAT before judging readiness"}
    elseif focus == "SOLO" then
        advice.title = string.format("Solo preparation score: %d / 100", scores.SOLO or 0)
        advice.description = "Solo mode favors self-sufficiency, usable health, a complete build, and repeatable performance rather than pure dummy DPS."
        advice.items = {"Keep a reliable heal or defensive tool available", "Balance damage with sustain and survivability", "Use COMBAT to compare encounters after build changes"}
    else
        advice.title = "Questing and exploration focus"
        advice.description = "Questing mode connects ACTIVITY ranking with assisted-quest routing and the nearest usable wayshrine calculation."
        advice.items = {"Select a journal quest in ACTIVITY", "Use ROUTE QUEST to make it the assisted objective", "Open MAP and select QUEST BEST before traveling"}
    end

    advice.focus = focus
    advice.focusLabel = self:GetFocusLabel(focus)
    advice.score = scores[focus] or buildScore
    return advice
end
