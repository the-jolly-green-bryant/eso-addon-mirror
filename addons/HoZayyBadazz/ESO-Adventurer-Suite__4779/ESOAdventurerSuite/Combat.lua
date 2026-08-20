-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.Combat = EPC.Combat or {}
local C = EPC.Combat

local function nowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        local ok, value = pcall(GetFrameTimeMilliseconds)
        if ok then return tonumber(value) or 0 end
    end
    return 0
end

local function safeNumber(value, fallback)
    value = tonumber(value)
    if value == nil then return fallback or 0 end
    return value
end

local function isDamageResult(result)
    return (ACTION_RESULT_DAMAGE ~= nil and result == ACTION_RESULT_DAMAGE)
        or (ACTION_RESULT_CRITICAL_DAMAGE ~= nil and result == ACTION_RESULT_CRITICAL_DAMAGE)
        or (ACTION_RESULT_DOT_TICK ~= nil and result == ACTION_RESULT_DOT_TICK)
        or (ACTION_RESULT_DOT_TICK_CRITICAL ~= nil and result == ACTION_RESULT_DOT_TICK_CRITICAL)
        or (ACTION_RESULT_DAMAGE_SHIELDED ~= nil and result == ACTION_RESULT_DAMAGE_SHIELDED)
end

local function isCriticalDamageResult(result)
    return (ACTION_RESULT_CRITICAL_DAMAGE ~= nil and result == ACTION_RESULT_CRITICAL_DAMAGE)
        or (ACTION_RESULT_DOT_TICK_CRITICAL ~= nil and result == ACTION_RESULT_DOT_TICK_CRITICAL)
end

local function isBlockedDamageResult(result)
    return (ACTION_RESULT_BLOCKED_DAMAGE ~= nil and result == ACTION_RESULT_BLOCKED_DAMAGE)
        or (ACTION_RESULT_BLOCKED ~= nil and result == ACTION_RESULT_BLOCKED)
end

local function isIncomingDamageResult(result)
    return isDamageResult(result) or isBlockedDamageResult(result)
end

local function isDotResult(result)
    return (ACTION_RESULT_DOT_TICK ~= nil and result == ACTION_RESULT_DOT_TICK)
        or (ACTION_RESULT_DOT_TICK_CRITICAL ~= nil and result == ACTION_RESULT_DOT_TICK_CRITICAL)
end

local function isHealResult(result)
    return (ACTION_RESULT_HEAL ~= nil and result == ACTION_RESULT_HEAL)
        or (ACTION_RESULT_CRITICAL_HEAL ~= nil and result == ACTION_RESULT_CRITICAL_HEAL)
        or (ACTION_RESULT_HOT_TICK ~= nil and result == ACTION_RESULT_HOT_TICK)
        or (ACTION_RESULT_HOT_TICK_CRITICAL ~= nil and result == ACTION_RESULT_HOT_TICK_CRITICAL)
end

local function isCriticalHealResult(result)
    return (ACTION_RESULT_CRITICAL_HEAL ~= nil and result == ACTION_RESULT_CRITICAL_HEAL)
        or (ACTION_RESULT_HOT_TICK_CRITICAL ~= nil and result == ACTION_RESULT_HOT_TICK_CRITICAL)
end

local function playerName()
    if type(GetUnitName) == "function" then
        local ok, value = pcall(GetUnitName, "player")
        if ok and value and value ~= "" then
            if type(zo_strformat) == "function" then return zo_strformat("<<1>>", value) end
            return value
        end
    end
    return "You"
end

local function normalizedName(name)
    name = tostring(name or "")
    if name == "" then return nil end
    if type(zo_strformat) == "function" then
        local ok, value = pcall(zo_strformat, "<<1>>", name)
        if ok and value and value ~= "" then name = value end
    end
    return name
end

function C:Initialize()
    self.inCombat = false
    self.current = nil
    self.lastFight = nil
    if EPC.saved then EPC.saved.combatPersonalBests = EPC.saved.combatPersonalBests or {} end
end

function C:GetPersonalBest(role)
    role = role or (EPC.Role and EPC.Role:GetRole()) or "DAMAGE"
    local b = EPC.saved and EPC.saved.combatPersonalBests or {}
    local row = b[role] or {}
    if role == "HEALER" then return safeNumber(row.hps, 0) end
    if role == "TANK" then return safeNumber(row.blockPercent, 0) end
    return safeNumber(row.dps, 0)
end

function C:UpdatePersonalBest(fight)
    if not EPC.saved or not fight then return end
    EPC.saved.combatPersonalBests = EPC.saved.combatPersonalBests or {}
    local role = EPC.Role and EPC.Role:GetRole() or "DAMAGE"
    local row = EPC.saved.combatPersonalBests[role] or {}
    row.dps = math.max(safeNumber(row.dps, 0), safeNumber(fight.dps, 0))
    row.hps = math.max(safeNumber(row.hps, 0), safeNumber(fight.hps, 0))
    row.blockPercent = math.max(safeNumber(row.blockPercent, 0), safeNumber(fight.blockPercent, 0))
    row.bestDuration = math.max(safeNumber(row.bestDuration, 0), safeNumber(fight.duration, 0))
    EPC.saved.combatPersonalBests[role] = row
end

function C:BeginFight()
    self.inCombat = true
    self.current = {
        startedAt = nowMs(), totalDamage = 0, directDamage = 0, dotDamage = 0, petDamage = 0,
        hits = 0, criticalHits = 0, totalHealing = 0, healEvents = 0, criticalHeals = 0,
        incomingDamage = 0, incomingHits = 0, blockedHits = 0,
        abilities = {}, targets = {}, group = {},
    }
end

function C:GetOrCreateContributor(name, isSelf)
    if not self.current then return nil end
    name = isSelf and playerName() or normalizedName(name)
    if not name then return nil end
    local key = string.lower(name)
    local contributor = self.current.group[key]
    if not contributor then
        contributor = { name = name, damage = 0, healing = 0, hits = 0, criticalHits = 0, healEvents = 0, criticalHeals = 0, isSelf = isSelf == true }
        self.current.group[key] = contributor
    elseif isSelf then
        contributor.isSelf = true
        contributor.name = playerName()
    end
    return contributor
end

function C:OnCombatEvent(result, abilityName, sourceName, sourceType, targetName, targetType, hitValue, abilityId)
    if not self.inCombat or not self.current then return end
    local damageEvent = isDamageResult(result)
    local healEvent = isHealResult(result)
    local incomingDamageEvent = targetType == COMBAT_UNIT_TYPE_PLAYER and isIncomingDamageResult(result)
    if not damageEvent and not healEvent and not incomingDamageEvent then return end
    local value = math.max(0, safeNumber(hitValue, 0))
    if value <= 0 then return end

    if incomingDamageEvent then
        self.current.incomingDamage = self.current.incomingDamage + value
        self.current.incomingHits = self.current.incomingHits + 1
        if isBlockedDamageResult(result) then self.current.blockedHits = self.current.blockedHits + 1 end
    end

    local isPlayer = sourceType == COMBAT_UNIT_TYPE_PLAYER
    local isPet = COMBAT_UNIT_TYPE_PLAYER_PET ~= nil and sourceType == COMBAT_UNIT_TYPE_PLAYER_PET
    local isSelf = isPlayer or isPet
    local contributor = self:GetOrCreateContributor(sourceName, isSelf)
    if contributor then
        if damageEvent then
            contributor.damage = contributor.damage + value
            contributor.hits = contributor.hits + 1
            if isCriticalDamageResult(result) then contributor.criticalHits = contributor.criticalHits + 1 end
        else
            contributor.healing = contributor.healing + value
            contributor.healEvents = contributor.healEvents + 1
            if isCriticalHealResult(result) then contributor.criticalHeals = contributor.criticalHeals + 1 end
        end
    end

    if not isSelf then return end
    local fight = self.current
    if damageEvent then
        fight.totalDamage = fight.totalDamage + value
        fight.hits = fight.hits + 1
        if isCriticalDamageResult(result) then fight.criticalHits = fight.criticalHits + 1 end
        if isDotResult(result) then fight.dotDamage = fight.dotDamage + value else fight.directDamage = fight.directDamage + value end
        if isPet then fight.petDamage = fight.petDamage + value end
        local key = safeNumber(abilityId, 0) > 0 and tostring(abilityId) or tostring(abilityName or "Unknown")
        local ability = fight.abilities[key] or { name = abilityName and abilityName ~= "" and abilityName or "Unknown", damage = 0, hits = 0 }
        ability.damage = ability.damage + value
        ability.hits = ability.hits + 1
        fight.abilities[key] = ability
        if targetName and targetName ~= "" then fight.targets[targetName] = true end
    else
        fight.totalHealing = fight.totalHealing + value
        fight.healEvents = fight.healEvents + 1
        if isCriticalHealResult(result) then fight.criticalHeals = fight.criticalHeals + 1 end
    end
end

function C:BuildContributorList(fight, duration)
    local contributors = {}
    for _, data in pairs(fight.group or {}) do
        if (data.damage or 0) > 0 or (data.healing or 0) > 0 then
            contributors[#contributors + 1] = {
                name = data.name or "Unknown", damage = data.damage or 0, healing = data.healing or 0,
                dps = (data.damage or 0) / duration, hps = (data.healing or 0) / duration,
                critPercent = (data.hits or 0) > 0 and ((data.criticalHits or 0) / data.hits * 100) or 0,
                isSelf = data.isSelf == true,
            }
        end
    end
    table.sort(contributors, function(a, b)
        if a.damage == b.damage then return a.healing > b.healing end
        return a.damage > b.damage
    end)
    return contributors
end

function C:GetLiveSummary()
    local fight = self.current
    if not fight then return nil end
    local duration = math.max(0.1, (nowMs() - safeNumber(fight.startedAt, nowMs())) / 1000)
    return {
        active = true, duration = duration, dps = fight.totalDamage / duration, totalDamage = fight.totalDamage,
        hits = fight.hits or 0, criticalHits = fight.criticalHits or 0,
        hps = fight.totalHealing / duration, totalHealing = fight.totalHealing,
        healEvents = fight.healEvents or 0, criticalHeals = fight.criticalHeals or 0,
        criticalEventPercent = fight.hits > 0 and (fight.criticalHits / fight.hits * 100) or 0,
        criticalHealPercent = fight.healEvents > 0 and (fight.criticalHeals / fight.healEvents * 100) or 0,
        incomingDamage = fight.incomingDamage or 0, dtps = (fight.incomingDamage or 0) / duration,
        incomingHits = fight.incomingHits or 0, blockedHits = fight.blockedHits or 0,
        blockPercent = (fight.incomingHits or 0) > 0 and ((fight.blockedHits or 0) / fight.incomingHits * 100) or 0,
        role = EPC.Role and EPC.Role:GetRole() or "DAMAGE",
    }
end

function C:GetHUDSummary()
    local live = self:GetLiveSummary()
    if live then return live end
    local last = self.lastFight
    if not last then return nil end
    if nowMs() - safeNumber(last.finishedAt, 0) > 10000 then return nil end
    return {
        active = false, duration = last.duration or 0, dps = last.dps or 0, totalDamage = last.totalDamage or 0,
        hits = last.hits or 0, criticalHits = last.criticalHits or 0,
        hps = last.hps or 0, totalHealing = last.totalHealing or 0, healEvents = last.healEvents or 0, criticalHeals = last.criticalHeals or 0,
        criticalEventPercent = last.criticalEventPercent or 0, criticalHealPercent = last.criticalHealPercent or 0,
        incomingDamage = last.incomingDamage or 0, dtps = last.dtps or 0, incomingHits = last.incomingHits or 0, blockedHits = last.blockedHits or 0,
        blockPercent = last.blockPercent or 0, role = EPC.Role and EPC.Role:GetRole() or "DAMAGE"
    }
end

function C:GetDisplayFight()
    local fight = self.current
    if not fight then return self.lastFight end
    local duration = math.max(0.1, (nowMs() - safeNumber(fight.startedAt, nowMs())) / 1000)
    local abilities = {}
    for _, data in pairs(fight.abilities or {}) do
        abilities[#abilities + 1] = { name = data.name, damage = data.damage or 0, hits = data.hits or 0 }
    end
    table.sort(abilities, function(a, b) return (a.damage or 0) > (b.damage or 0) end)
    local targetCount = 0
    for _ in pairs(fight.targets or {}) do targetCount = targetCount + 1 end
    return {
        live = true, duration = duration, totalDamage = fight.totalDamage, dps = fight.totalDamage / duration,
        directDamage = fight.directDamage, dotDamage = fight.dotDamage, dotPercent = fight.totalDamage > 0 and (fight.dotDamage / fight.totalDamage * 100) or 0,
        petDamage = fight.petDamage, petPercent = fight.totalDamage > 0 and (fight.petDamage / fight.totalDamage * 100) or 0,
        hits = fight.hits, criticalHits = fight.criticalHits, criticalEventPercent = fight.hits > 0 and (fight.criticalHits / fight.hits * 100) or 0,
        totalHealing = fight.totalHealing, hps = fight.totalHealing / duration, healEvents = fight.healEvents, criticalHeals = fight.criticalHeals,
        criticalHealPercent = fight.healEvents > 0 and (fight.criticalHeals / fight.healEvents * 100) or 0,
        incomingDamage = fight.incomingDamage or 0, dtps = (fight.incomingDamage or 0) / duration,
        incomingHits = fight.incomingHits or 0, blockedHits = fight.blockedHits or 0, blockPercent = (fight.incomingHits or 0) > 0 and ((fight.blockedHits or 0) / fight.incomingHits * 100) or 0,
        targetCount = targetCount, abilities = abilities, contributors = self:BuildContributorList(fight, duration),
    }
end

function C:EndFight()
    if not self.current then self.inCombat = false return end
    local fight = self.current
    self.current = nil
    self.inCombat = false
    local finishedAt = nowMs()
    local duration = math.max(0.1, (finishedAt - safeNumber(fight.startedAt, finishedAt)) / 1000)
    if fight.totalDamage <= 0 and fight.totalHealing <= 0 and (fight.incomingDamage or 0) <= 0 then return end

    local abilities = {}
    for _, data in pairs(fight.abilities) do abilities[#abilities + 1] = data end
    table.sort(abilities, function(a, b) return (a.damage or 0) > (b.damage or 0) end)
    local targetCount = 0
    for _ in pairs(fight.targets) do targetCount = targetCount + 1 end

    self.lastFight = {
        finishedAt = finishedAt, duration = duration, totalDamage = fight.totalDamage, dps = fight.totalDamage / duration,
        directDamage = fight.directDamage, dotDamage = fight.dotDamage, dotPercent = fight.totalDamage > 0 and (fight.dotDamage / fight.totalDamage * 100) or 0,
        petDamage = fight.petDamage, petPercent = fight.totalDamage > 0 and (fight.petDamage / fight.totalDamage * 100) or 0,
        hits = fight.hits, criticalHits = fight.criticalHits, criticalEventPercent = fight.hits > 0 and (fight.criticalHits / fight.hits * 100) or 0,
        totalHealing = fight.totalHealing, hps = fight.totalHealing / duration, healEvents = fight.healEvents, criticalHeals = fight.criticalHeals,
        criticalHealPercent = fight.healEvents > 0 and (fight.criticalHeals / fight.healEvents * 100) or 0,
        incomingDamage = fight.incomingDamage or 0, dtps = (fight.incomingDamage or 0) / duration,
        incomingHits = fight.incomingHits or 0, blockedHits = fight.blockedHits or 0, blockPercent = (fight.incomingHits or 0) > 0 and ((fight.blockedHits or 0) / fight.incomingHits * 100) or 0,
        targetCount = targetCount, abilities = abilities, contributors = self:BuildContributorList(fight, duration),
    }
    self:UpdatePersonalBest(self.lastFight)
    EPC:RequestRefresh("combat-finished")
end

function C:OnCombatState(inCombat)
    if inCombat then
        if not self.inCombat then self:BeginFight() end
    elseif self.inCombat then
        self:EndFight()
    end
end

function C:GetLastFight() return self.lastFight end

function C:ResetLastFight()
    self.lastFight = nil
    EPC:RequestRefresh("combat-reset")
    if EPC.UI and EPC.UI.UpdateCombatHUD then EPC.UI:UpdateCombatHUD(nil) end
end
