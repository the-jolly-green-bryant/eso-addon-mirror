local PvPerformance = PvPerformance
local Analytics = PvPerformance.Modules.Analytics
local Utilities = PvPerformance.Utilities

local ANALYTICS_UPDATE_NAME = "PvPerformanceAnalyticsBuildStats"
local ANALYTICS_SAMPLE_INTERVAL_MS = 500
local ANALYTICS_MAX_LOG_EVENTS = 6000
local ANALYTICS_MAX_EFFECT_EVENTS = 3000
local ANALYTICS_MAX_SYSTEM_EVENTS = 3000
local MITIGATION_DEDUP_WINDOW_MS = 100
local EFFECT_SOURCE_HINT_WINDOW_MS = 750

local EFFECT_APPLICATION_RESULTS = {}
local function AddEffectApplicationResult(result)
    if result ~= nil then
        EFFECT_APPLICATION_RESULTS[result] = true
    end
end
AddEffectApplicationResult(EFFECT_RESULT_GAINED)
AddEffectApplicationResult(EFFECT_RESULT_UPDATED)
AddEffectApplicationResult(EFFECT_RESULT_FULL_REFRESH)

local EFFECT_TRACKED_RESULTS = {}
for result in pairs(EFFECT_APPLICATION_RESULTS) do
    EFFECT_TRACKED_RESULTS[result] = true
end
if EFFECT_RESULT_FADED ~= nil then
    EFFECT_TRACKED_RESULTS[EFFECT_RESULT_FADED] = true
end

local EFFECT_SOURCE_COMBAT_RESULTS = {}
local function AddEffectSourceCombatResult(result)
    if result ~= nil then
        table.insert(EFFECT_SOURCE_COMBAT_RESULTS, result)
    end
end
AddEffectSourceCombatResult(ACTION_RESULT_EFFECT_GAINED)
AddEffectSourceCombatResult(ACTION_RESULT_EFFECT_GAINED_DURATION)

local ANALYTICS_MITIGATION_RESULTS = {}
local function AddMitigationResult(result, kind)
    if result ~= nil then
        ANALYTICS_MITIGATION_RESULTS[result] = kind
    end
end
AddMitigationResult(ACTION_RESULT_BLOCKED, "blocked")
AddMitigationResult(ACTION_RESULT_DAMAGE_SHIELDED, "shielded")
AddMitigationResult(ACTION_RESULT_CRITICAL_DAMAGE_SHIELDED, "shielded")

local function ActorKey(name)
    return Utilities.NormalizeUnitName(name or "")
end

local function AbilityIdentity(abilityId, abilityName)
    abilityId = tonumber(abilityId) or 0
    local name = abilityName and abilityName ~= "" and abilityName or nil
    if not name and abilityId > 0 and type(GetAbilityName) == "function" then
        name = GetAbilityName(abilityId)
    end
    name = name and name ~= "" and name or "Unknown effect"
    return abilityId > 0 and ("id:" .. abilityId) or ("name:" .. zo_strlower(name)), name, abilityId
end

local function IsCriticalDamage(result)
    return result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_DOT_TICK_CRITICAL
end

local function IsCriticalHealing(result)
    return result == ACTION_RESULT_CRITICAL_HEAL or result == ACTION_RESULT_HOT_TICK_CRITICAL
end

local function NewCategory()
    return {
        byActor = {},
        activityByActor = {},
        unattributedAbsorbedByActor = {},
        total = 0,
    }
end

local function TouchCategoryActivity(category, actorKey, now)
    if not category or actorKey == "" then
        return
    end
    now = tonumber(now) or GetGameTimeMilliseconds()
    local activity = category.activityByActor[actorKey]
    if not activity then
        activity = { firstMS = now, lastMS = now }
        category.activityByActor[actorKey] = activity
        return
    end
    activity.firstMS = math.min(activity.firstMS or now, now)
    activity.lastMS = math.max(activity.lastMS or now, now)
end

local function AddUnattributedAbsorption(category, actorName, amount)
    amount = math.max(0, tonumber(amount) or 0)
    local actorKey = ActorKey(actorName)
    if not category or amount <= 0 or actorKey == "" then
        return
    end
    category.unattributedAbsorbedByActor[actorKey] =
        (category.unattributedAbsorbedByActor[actorKey] or 0) + amount
    category.byActor[actorKey] = category.byActor[actorKey] or {}
    TouchCategoryActivity(category, actorKey)
end

local function AddSource(category, actorName, abilityId, abilityName, amount, critical, allowZero, blocked, absorbed)
    amount = math.max(0, tonumber(amount) or 0)
    absorbed = math.max(0, tonumber(absorbed) or 0)
    local actorKey = ActorKey(actorName)
    if (amount <= 0 and not allowZero) or actorKey == "" then
        return
    end
    TouchCategoryActivity(category, actorKey)
    local sources = category.byActor[actorKey]
    if not sources then
        sources = {}
        category.byActor[actorKey] = sources
    end
    local identity, name, resolvedId = AbilityIdentity(abilityId, abilityName)
    local source = sources[identity]
    if not source then
        source = {
            name = name,
            abilityId = resolvedId > 0 and resolvedId or nil,
            total = 0,
            hitCount = 0,
            critCount = 0,
            minHit = nil,
            maxHit = 0,
            blockedCount = 0,
            absorbed = 0,
        }
        sources[identity] = source
    end
    source.total = source.total + amount
    source.hitCount = source.hitCount + 1
    source.critCount = source.critCount + (critical and 1 or 0)
    source.blockedCount = (source.blockedCount or 0) + (blocked and 1 or 0)
    source.absorbed = (source.absorbed or 0) + absorbed
    source.minHit = source.minHit and math.min(source.minHit, amount) or amount
    source.maxHit = math.max(source.maxHit, amount)
    category.total = category.total + amount
end

-- ESO can report the same absorbed amount once on the attack event and again
-- as a nearby DAMAGE_SHIELDED event. Keep a tiny, duel-local correlation
-- buffer so Analytics counts the observed pressure once without persisting or
-- guessing a raw event relationship.
local function ClaimAbsorption(runtime, categoryName, actorName, amount, origin)
    amount = math.max(0, tonumber(amount) or 0)
    if not runtime or amount <= 0 then
        return false
    end
    local now = GetGameTimeMilliseconds()
    runtime.absorptionClaims = runtime.absorptionClaims or {}
    local key = table.concat({ categoryName or "", ActorKey(actorName) }, "|")
    local claims = runtime.absorptionClaims[key] or {}
    runtime.absorptionClaims[key] = claims
    for index = #claims, 1, -1 do
        local claim = claims[index]
        if now - (claim.timeMS or 0) > MITIGATION_DEDUP_WINDOW_MS then
            table.remove(claims, index)
        elseif not claim.matched
            and claim.origin ~= origin
            and math.abs((claim.amount or 0) - amount) <= 1 then
            claim.matched = true
            return false
        end
    end
    table.insert(claims, { timeMS = now, amount = amount, origin = origin })
    return true
end

local function AddLogEvent(runtime, category, abilityId, abilityName, amount, critical, sourceName, targetName, blocked, shielded, absorbed)
    runtime.logEventCount = runtime.logEventCount + 1
    if #runtime.events >= ANALYTICS_MAX_LOG_EVENTS then
        runtime.droppedLogEvents = runtime.droppedLogEvents + 1
        return
    end
    local _, name, resolvedId = AbilityIdentity(abilityId, abilityName)
    local now = GetGameTimeMilliseconds()
    table.insert(runtime.events, {
        sequence = runtime.logEventCount,
        offsetMS = math.max(0, now - (runtime.startTimeMS or now)),
        category = category,
        abilityId = resolvedId > 0 and resolvedId or nil,
        name = name,
        amount = math.max(0, math.floor((tonumber(amount) or 0) + 0.5)),
        critical = critical == true,
        blocked = blocked == true,
        shielded = shielded == true,
        absorbed = math.max(0, math.floor((tonumber(absorbed) or 0) + 0.5)),
        sourceKey = ActorKey(sourceName),
        targetKey = ActorKey(targetName),
        sourceName = Utilities.CleanCharacterName(sourceName or ""),
        targetName = Utilities.CleanCharacterName(targetName or ""),
    })
end

local function EffectHintKey(abilityId, targetName)
    return table.concat({ tostring(tonumber(abilityId) or 0), ActorKey(targetName) }, "|")
end

local function RememberEffectSource(runtime, abilityId, sourceName, targetName)
    if not runtime or not sourceName or sourceName == "" then
        return
    end
    runtime.effectSourceHints = runtime.effectSourceHints or {}
    runtime.effectSourceHints[EffectHintKey(abilityId, targetName)] = {
        sourceName = Utilities.CleanCharacterName(sourceName),
        timeMS = GetGameTimeMilliseconds(),
    }
end

local function ResolveEffectSource(runtime, abilityId, targetName, sourceType, targetIsSelf, effectKind)
    local hint = runtime and runtime.effectSourceHints
        and runtime.effectSourceHints[EffectHintKey(abilityId, targetName)]
    local now = GetGameTimeMilliseconds()
    if hint and now - (hint.timeMS or 0) <= EFFECT_SOURCE_HINT_WINDOW_MS then
        return hint.sourceName
    end
    if sourceType == COMBAT_UNIT_TYPE_PLAYER then
        return runtime.playerDisplayName or runtime.playerCharacterName or "You"
    end
    -- EVENT_EFFECT_CHANGED does not always expose a caster name. During a
    -- duel, a harmful effect received by the player is normally opponent
    -- sourced, but report that as an explicit API limitation rather than
    -- inventing an account name.
    if targetIsSelf and effectKind == "debuff" then
        return "Opponent / unknown"
    end
    return "Source unavailable"
end

local function AddEffectEvent(runtime, effect)
    runtime.effectEventCount = (runtime.effectEventCount or 0) + 1
    if #runtime.effects >= ANALYTICS_MAX_EFFECT_EVENTS then
        runtime.droppedEffectEvents = (runtime.droppedEffectEvents or 0) + 1
        return
    end
    effect.sequence = runtime.effectEventCount
    table.insert(runtime.effects, effect)
end

local function AddSystemEvent(runtime, category, message, abilityId)
    if not runtime or not category or not message then
        return
    end
    runtime.systemEventCount = (runtime.systemEventCount or 0) + 1
    if #runtime.systemEvents >= ANALYTICS_MAX_SYSTEM_EVENTS then
        runtime.droppedSystemEvents = (runtime.droppedSystemEvents or 0) + 1
        return
    end
    local now = GetGameTimeMilliseconds()
    table.insert(runtime.systemEvents, {
        sequence = runtime.systemEventCount,
        offsetMS = math.max(0, now - (runtime.startTimeMS or now)),
        category = category,
        message = tostring(message),
        abilityId = tonumber(abilityId) or nil,
    })
end

local STAT_DEFINITIONS = {
    offensive = {
        { key = "weaponDamage", label = "Weapon Damage", constant = "STAT_WEAPON_POWER" },
        { key = "spellDamage", label = "Spell Damage", constant = "STAT_SPELL_POWER" },
        { key = "weaponCritical", label = "Weapon Critical", constant = "STAT_CRITICAL_STRIKE" },
        { key = "spellCritical", label = "Spell Critical", constant = "STAT_SPELL_CRITICAL" },
        { key = "physicalPenetration", label = "Physical Penetration", constant = "STAT_PHYSICAL_PENETRATION" },
        { key = "spellPenetration", label = "Spell Penetration", constant = "STAT_SPELL_PENETRATION" },
        { key = "maximumMagicka", label = "Maximum Magicka", constant = "STAT_MAX_MAGICKA" },
        { key = "maximumStamina", label = "Maximum Stamina", constant = "STAT_MAX_STAMINA" },
    },
    defensive = {
        { key = "maximumHealth", label = "Maximum Health", constant = "STAT_MAX_HEALTH" },
        { key = "physicalResistance", label = "Physical Resistance", constant = "STAT_PHYSICAL_RESIST" },
        { key = "spellResistance", label = "Spell Resistance", constant = "STAT_SPELL_RESIST" },
        { key = "criticalResistance", label = "Critical Resistance", constant = "STAT_CRITICAL_RESISTANCE" },
        { key = "healthRecovery", label = "Health Recovery", constant = "STAT_HEALTH_REGEN_COMBAT" },
        { key = "magickaRecovery", label = "Magicka Recovery", constant = "STAT_MAGICKA_REGEN_COMBAT" },
        { key = "staminaRecovery", label = "Stamina Recovery", constant = "STAT_STAMINA_REGEN_COMBAT" },
    },
}

local function SampleStatGroup(runtime, groupName, definitions, recordChanges)
    local group = runtime.buildStats[groupName]
    runtime.lastStatValues = runtime.lastStatValues or {}
    for _, definition in ipairs(definitions) do
        local statId = _G[definition.constant]
        if statId ~= nil and type(GetPlayerStat) == "function" then
            local value = tonumber(GetPlayerStat(statId))
            if value then
                local previous = runtime.lastStatValues[definition.key]
                local entry = group[definition.key]
                if not entry then
                    entry = { label = definition.label, low = value, high = value, sum = 0, count = 0 }
                    group[definition.key] = entry
                end
                entry.low = math.min(entry.low, value)
                entry.high = math.max(entry.high, value)
                entry.sum = entry.sum + value
                entry.count = entry.count + 1
                runtime.lastStatValues[definition.key] = value
                if recordChanges and previous ~= value then
                    local message
                    if previous == nil then
                        message = string.format(
                            "%s is at %s.",
                            definition.label,
                            Utilities.FormatCombatNumber(value)
                        )
                    else
                        local delta = value - previous
                        message = string.format(
                            "%s %s to %s (%s%s).",
                            definition.label,
                            delta > 0 and "increased" or "decreased",
                            Utilities.FormatCombatNumber(value),
                            delta > 0 and "+" or "-",
                            Utilities.FormatCombatNumber(math.abs(delta))
                        )
                    end
                    AddSystemEvent(runtime, "statsChange", message)
                end
            end
        end
    end
end

local function SampleAllStats(runtime, recordChanges)
    SampleStatGroup(runtime, "offensive", STAT_DEFINITIONS.offensive, recordChanges)
    SampleStatGroup(runtime, "defensive", STAT_DEFINITIONS.defensive, recordChanges)
end

local POWER_LABELS = {}
local function AddPowerLabel(powerType, label)
    if powerType ~= nil then
        POWER_LABELS[powerType] = label
    end
end
AddPowerLabel(POWERTYPE_HEALTH, "Health")
AddPowerLabel(POWERTYPE_MAGICKA, "Magicka")
AddPowerLabel(POWERTYPE_STAMINA, "Stamina")
AddPowerLabel(POWERTYPE_ULTIMATE, "Ultimate")

local function InitializePowerValues(runtime)
    runtime.powerValues = {}
    if type(GetUnitPower) ~= "function" then
        return
    end
    for powerType in pairs(POWER_LABELS) do
        local value = GetUnitPower("player", powerType)
        runtime.powerValues[powerType] = tonumber(value) or 0
    end
end

function Analytics:BeginDuel(tracking, startTimeMS)
    if not tracking then
        return
    end
    tracking.analytics = {
        startTimeMS = tonumber(startTimeMS) or GetGameTimeMilliseconds(),
        damageDone = NewCategory(),
        damageTaken = NewCategory(),
        healingDone = NewCategory(),
        healingReceived = NewCategory(),
        events = {},
        logEventCount = 0,
        droppedLogEvents = 0,
        effects = {},
        effectEventCount = 0,
        droppedEffectEvents = 0,
        effectSourceHints = {},
        effectStates = {},
        systemEvents = {},
        systemEventCount = 0,
        droppedSystemEvents = 0,
        playerCharacterName = tracking.playerCharacterName,
        playerDisplayName = tracking.playerDisplayName,
        buildStats = { offensive = {}, defensive = {} },
        mitigationSeen = {},
        absorptionClaims = {},
    }
    local runtime = tracking.analytics
    InitializePowerValues(runtime)
    if type(GetActiveWeaponPairInfo) == "function" then
        runtime.activeWeaponPair = GetActiveWeaponPairInfo()
    end
    SampleAllStats(runtime, true)
    AddSystemEvent(runtime, "infoEvent", "Duel analytics tracking started.")
    EVENT_MANAGER:UnregisterForUpdate(ANALYTICS_UPDATE_NAME)
    EVENT_MANAGER:RegisterForUpdate(ANALYTICS_UPDATE_NAME, ANALYTICS_SAMPLE_INTERVAL_MS, function()
        local current = PvPerformance.Modules.Dueling.currentDuelTracking
        local runtime = current and current.analytics
        if not runtime then
            EVENT_MANAGER:UnregisterForUpdate(ANALYTICS_UPDATE_NAME)
            return
        end
        local now = GetGameTimeMilliseconds()
        if now >= runtime.startTimeMS then
            SampleAllStats(runtime, true)
            if now - (runtime.lastPerformanceSampleMS or 0) >= 1000 then
                runtime.lastPerformanceSampleMS = now
                local fps = type(GetFramerate) == "function" and tonumber(GetFramerate()) or nil
                local latency = type(GetLatency) == "function" and tonumber(GetLatency()) or nil
                if fps or latency then
                    AddSystemEvent(runtime, "performanceInfo", string.format(
                        "FPS: %s, Ping: %s ms.",
                        fps and string.format("%.1f", fps) or "N/A",
                        latency and tostring(math.floor(latency + 0.5)) or "N/A"
                    ))
                end
            end
        end
    end)
end

function Analytics:CancelDuel()
    EVENT_MANAGER:UnregisterForUpdate(ANALYTICS_UPDATE_NAME)
end

local function IsBlockedDamage(result)
    return result == ACTION_RESULT_BLOCKED or result == ACTION_RESULT_BLOCKED_DAMAGE
end

local function IsDuplicateMitigation(runtime, categoryName, abilityId, sourceName, targetName, kind)
    if not runtime or not kind then
        return false
    end
    runtime.mitigationSeen = runtime.mitigationSeen or {}
    local now = GetGameTimeMilliseconds()
    local key = table.concat({
        categoryName or "",
        tostring(tonumber(abilityId) or 0),
        ActorKey(sourceName),
        ActorKey(targetName),
        kind,
    }, "|")
    local previous = runtime.mitigationSeen[key]
    runtime.mitigationSeen[key] = now
    return previous ~= nil and (now - previous) >= 0 and (now - previous) <= MITIGATION_DEDUP_WINDOW_MS
end

function Analytics:RecordDamage(tracking, categoryName, result, abilityName, sourceName, targetName, hitValue, abilityId, overflow)
    local runtime = tracking and tracking.analytics
    local category = runtime and runtime[categoryName]
    local amount = math.max(0, tonumber(hitValue) or 0)
    local absorbed = math.max(0, tonumber(overflow) or 0)
    local blocked = IsBlockedDamage(result)
    if not category or (amount <= 0 and not blocked and absorbed <= 0) then
        return
    end
    if blocked and IsDuplicateMitigation(runtime, categoryName, abilityId, sourceName, targetName, "blocked") then
        return
    end
    local actorName = categoryName == "damageDone" and targetName or sourceName
    local critical = IsCriticalDamage(result)
    local attributedAbsorbed = ClaimAbsorption(
        runtime,
        categoryName,
        actorName,
        absorbed,
        "attack"
    ) and absorbed or 0
    AddSource(category, actorName, abilityId, abilityName, amount, critical, blocked or absorbed > 0, blocked, attributedAbsorbed)
    AddLogEvent(runtime, categoryName, abilityId, abilityName, amount, critical, sourceName, targetName, blocked, false, absorbed)
end

function Analytics:OnMitigatedDamageCombatEvent(_, result, _, abilityName, _, _, sourceName, sourceUnitType, targetName, targetUnitType, hitValue, _, _, _, _, _, abilityId, overflow)
    local Dueling = PvPerformance.Modules.Dueling
    local tracking = Dueling.currentDuelTracking
    local kind = ANALYTICS_MITIGATION_RESULTS[result]
    if not tracking or not kind then
        return
    end
    local now = GetGameTimeMilliseconds()
    if Dueling.currentDuelStartMS and now < Dueling.currentDuelStartMS then
        return
    end
    local isFromPlayer = sourceUnitType == COMBAT_UNIT_TYPE_PLAYER
    local isToPlayer = targetUnitType == COMBAT_UNIT_TYPE_PLAYER
    local categoryName = isFromPlayer and not isToPlayer and "damageDone"
        or (isToPlayer and not isFromPlayer and "damageTaken") or nil
    if not categoryName then
        return
    end

    if kind == "blocked" then
        -- ACTION_RESULT_BLOCKED names the attack and can safely contribute a
        -- zero-damage hit occurrence. It remains separate from health damage.
        self:RecordDamage(tracking, categoryName, result, abilityName, sourceName, targetName, 0, abilityId, overflow)
        return
    end

    -- DAMAGE_SHIELDED names the ward/passive, not the attack that produced
    -- it. Preserve the timestamp and API-reported absorbed value in the log,
    -- but do not misattribute the ward as an outgoing damage ability.
    local runtime = tracking.analytics
    if not runtime or IsDuplicateMitigation(runtime, categoryName, abilityId, sourceName, targetName, kind) then
        return
    end
    local absorbed = math.max(0, tonumber(hitValue) or 0, tonumber(overflow) or 0)
    local actorName = categoryName == "damageDone" and targetName or sourceName
    if ClaimAbsorption(runtime, categoryName, actorName, absorbed, "shield") then
        AddUnattributedAbsorption(runtime[categoryName], actorName, absorbed)
    end
    AddLogEvent(runtime, categoryName, abilityId, abilityName, 0, false, sourceName, targetName, false, true, absorbed)
end

function Analytics:RecordHealing(tracking, categoryName, result, abilityName, sourceName, targetName, hitValue, abilityId)
    local runtime = tracking and tracking.analytics
    local category = runtime and runtime[categoryName]
    local amount = math.max(0, tonumber(hitValue) or 0)
    if not category or amount <= 0 then
        return
    end
    local actorName = categoryName == "healingDone" and targetName or sourceName
    local critical = IsCriticalHealing(result)
    AddSource(category, actorName, abilityId, abilityName, amount, critical)
    AddLogEvent(runtime, categoryName, abilityId, abilityName, amount, critical, sourceName, targetName)
end

function Analytics:OnHealingReceivedCombatEvent(_, result, _, abilityName, _, _, sourceName, sourceUnitType, targetName, targetUnitType, hitValue, _, _, _, _, _, abilityId)
    local Dueling = PvPerformance.Modules.Dueling
    local tracking = Dueling.currentDuelTracking
    if not tracking or targetUnitType ~= COMBAT_UNIT_TYPE_PLAYER or sourceUnitType == COMBAT_UNIT_TYPE_PLAYER then
        return
    end
    local now = GetGameTimeMilliseconds()
    if Dueling.currentDuelStartMS and now < Dueling.currentDuelStartMS then
        return
    end
    self:RecordHealing(tracking, "healingReceived", result, abilityName, sourceName, targetName, hitValue, abilityId)
end

function Analytics:OnEffectSourceCombatEvent(_, _, _, _, _, _, sourceName, sourceUnitType, targetName, targetUnitType, _, _, _, _, _, _, abilityId)
    local Dueling = PvPerformance.Modules.Dueling
    local tracking = Dueling.currentDuelTracking
    local runtime = tracking and tracking.analytics
    if not runtime then
        return
    end
    local now = GetGameTimeMilliseconds()
    if Dueling.currentDuelStartMS and now < Dueling.currentDuelStartMS then
        return
    end
    if sourceUnitType ~= COMBAT_UNIT_TYPE_PLAYER and targetUnitType ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end
    RememberEffectSource(runtime, abilityId, sourceName, targetName)
end

function Analytics:OnEffectChanged(_, changeType, _, effectName, unitTag, _, _, stackCount, iconName, _, effectType, _, _, unitName, _, abilityId, sourceType)
    local Dueling = PvPerformance.Modules.Dueling
    local tracking = Dueling.currentDuelTracking
    local runtime = tracking and tracking.analytics
    if not runtime or not EFFECT_TRACKED_RESULTS[changeType] then
        return
    end
    local now = GetGameTimeMilliseconds()
    if Dueling.currentDuelStartMS and now < Dueling.currentDuelStartMS then
        return
    end

    local effectKind
    if BUFF_EFFECT_TYPE_BUFF ~= nil and effectType == BUFF_EFFECT_TYPE_BUFF then
        effectKind = "buff"
    elseif BUFF_EFFECT_TYPE_DEBUFF ~= nil and effectType == BUFF_EFFECT_TYPE_DEBUFF then
        effectKind = "debuff"
    else
        return
    end

    local targetKey = ActorKey(unitName)
    local playerCharacterKey = ActorKey(runtime.playerCharacterName)
    local playerDisplayKey = ActorKey(runtime.playerDisplayName)
    local targetIsSelf = unitTag == "player"
        or (targetKey ~= "" and (targetKey == playerCharacterKey or targetKey == playerDisplayKey))
    local sourceIsSelf = sourceType == COMBAT_UNIT_TYPE_PLAYER
    if not targetIsSelf and not sourceIsSelf then
        return
    end

    local _, resolvedName, resolvedAbilityId = AbilityIdentity(abilityId, effectName)
    local targetLabel = targetIsSelf and "Self" or nil
    if not targetLabel and unitTag and unitTag ~= ""
        and type(GetUnitDisplayName) == "function" then
        local displayName = GetUnitDisplayName(unitTag)
        if displayName and displayName ~= "" then
            targetLabel = displayName
        end
    end
    targetLabel = targetLabel or Utilities.CleanCharacterName(unitName or "")
    if targetLabel == "" then
        targetLabel = "Target unavailable"
    end
    local sourceLabel = ResolveEffectSource(runtime, abilityId, unitName, sourceType, targetIsSelf, effectKind)
    local effect = {
        offsetMS = math.max(0, now - (runtime.startTimeMS or now)),
        abilityId = resolvedAbilityId > 0 and resolvedAbilityId or nil,
        name = resolvedName,
        icon = iconName and iconName ~= "" and iconName or nil,
        effectKind = effectKind,
        incoming = targetIsSelf,
        outgoing = sourceIsSelf,
        sourceName = sourceLabel,
        targetName = targetLabel,
        stacks = math.max(0, math.floor((tonumber(stackCount) or 0) + 0.5)),
    }

    local stateKey = table.concat({
        tostring(resolvedAbilityId),
        effectKind,
        targetIsSelf and "in" or "",
        sourceIsSelf and "out" or "",
        ActorKey(sourceLabel),
        ActorKey(targetLabel),
    }, "|")
    local state = runtime.effectStates[stateKey]
    if not state then
        state = {
            abilityId = effect.abilityId,
            name = effect.name,
            icon = effect.icon,
            effectKind = effectKind,
            incoming = targetIsSelf,
            outgoing = sourceIsSelf,
            sourceName = sourceLabel,
            targetName = targetLabel,
            applications = 0,
            maxStacks = 0,
            uptimeMS = 0,
        }
        runtime.effectStates[stateKey] = state
    end
    state.icon = state.icon or effect.icon
    state.maxStacks = math.max(state.maxStacks or 0, effect.stacks or 0)
    if EFFECT_APPLICATION_RESULTS[changeType] then
        if not state.openMS then
            state.openMS = now
            state.applications = (state.applications or 0) + 1
        end
        AddEffectEvent(runtime, effect)
    elseif changeType == EFFECT_RESULT_FADED and state.openMS then
        state.uptimeMS = (state.uptimeMS or 0) + math.max(0, now - state.openMS)
        state.openMS = nil
    end
end

function Analytics:OnPowerUpdate(_, unitTag, _, powerType, powerValue)
    local tracking = PvPerformance.Modules.Dueling.currentDuelTracking
    local runtime = tracking and tracking.analytics
    local label = POWER_LABELS[powerType]
    if not runtime or unitTag ~= "player" or not label then
        return
    end
    local now = GetGameTimeMilliseconds()
    if PvPerformance.Modules.Dueling.currentDuelStartMS
        and now < PvPerformance.Modules.Dueling.currentDuelStartMS then
        runtime.powerValues[powerType] = tonumber(powerValue) or 0
        return
    end
    local value = tonumber(powerValue) or 0
    local previous = runtime.powerValues[powerType]
    runtime.powerValues[powerType] = value
    if previous == nil or previous == value then
        return
    end
    local delta = value - previous
    AddSystemEvent(runtime, "resourceEvent", string.format(
        "You %s %s %s.",
        delta > 0 and "gained" or "lost",
        Utilities.FormatCombatNumber(math.abs(delta)),
        label
    ))
end

function Analytics:OnActionSlotAbilityUsed(_, slotNum)
    local tracking = PvPerformance.Modules.Dueling.currentDuelTracking
    local runtime = tracking and tracking.analytics
    if not runtime then
        return
    end
    local abilityId
    if type(GetSlotBoundId) == "function" then
        local ok, value = pcall(GetSlotBoundId, slotNum)
        abilityId = ok and tonumber(value) or nil
    end
    local abilityName = abilityId and abilityId > 0 and type(GetAbilityName) == "function"
        and GetAbilityName(abilityId) or nil
    abilityName = abilityName and abilityName ~= "" and abilityName or ("Action slot " .. tostring(slotNum or "?"))
    AddSystemEvent(runtime, "usedSkill", "You used " .. abilityName .. ".", abilityId)
end

function Analytics:OnActiveWeaponPairChanged(_, activeWeaponPair, locked)
    local tracking = PvPerformance.Modules.Dueling.currentDuelTracking
    local runtime = tracking and tracking.analytics
    if not runtime or locked then
        return
    end
    activeWeaponPair = tonumber(activeWeaponPair)
    if not activeWeaponPair or activeWeaponPair == runtime.activeWeaponPair then
        return
    end
    runtime.activeWeaponPair = activeWeaponPair
    AddSystemEvent(runtime, "infoEvent", "Weapon swapped to bar " .. tostring(activeWeaponPair) .. ".")
end

function Analytics:RegisterDuelEvents()
    if self.eventsRegistered then
        return
    end
    local healResults = PvPerformance.Private.HEAL_COMBAT_RESULTS or {}
    for _, result in ipairs(healResults) do
        local eventName = string.format("PvPerformanceAnalyticsHealingReceived%d", result)
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function(...)
            Analytics:OnHealingReceivedCombatEvent(...)
        end)
        EVENT_MANAGER:AddFilterForEvent(
            eventName,
            EVENT_COMBAT_EVENT,
            REGISTER_FILTER_COMBAT_RESULT,
            result,
            REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE,
            COMBAT_UNIT_TYPE_PLAYER
        )
    end
    for result in pairs(ANALYTICS_MITIGATION_RESULTS) do
        local outgoingEventName = string.format("PvPerformanceAnalyticsMitigationOutgoing%d", result)
        EVENT_MANAGER:RegisterForEvent(outgoingEventName, EVENT_COMBAT_EVENT, function(...)
            Analytics:OnMitigatedDamageCombatEvent(...)
        end)
        EVENT_MANAGER:AddFilterForEvent(
            outgoingEventName,
            EVENT_COMBAT_EVENT,
            REGISTER_FILTER_COMBAT_RESULT,
            result,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
            COMBAT_UNIT_TYPE_PLAYER
        )

        local incomingEventName = string.format("PvPerformanceAnalyticsMitigationIncoming%d", result)
        EVENT_MANAGER:RegisterForEvent(incomingEventName, EVENT_COMBAT_EVENT, function(...)
            Analytics:OnMitigatedDamageCombatEvent(...)
        end)
        EVENT_MANAGER:AddFilterForEvent(
            incomingEventName,
            EVENT_COMBAT_EVENT,
            REGISTER_FILTER_COMBAT_RESULT,
            result,
            REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE,
            COMBAT_UNIT_TYPE_PLAYER
        )
    end
    for _, result in ipairs(EFFECT_SOURCE_COMBAT_RESULTS) do
        local outgoingEventName = string.format("PvPerformanceAnalyticsEffectSourceOutgoing%d", result)
        EVENT_MANAGER:RegisterForEvent(outgoingEventName, EVENT_COMBAT_EVENT, function(...)
            Analytics:OnEffectSourceCombatEvent(...)
        end)
        EVENT_MANAGER:AddFilterForEvent(
            outgoingEventName,
            EVENT_COMBAT_EVENT,
            REGISTER_FILTER_COMBAT_RESULT,
            result,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
            COMBAT_UNIT_TYPE_PLAYER
        )

        local incomingEventName = string.format("PvPerformanceAnalyticsEffectSourceIncoming%d", result)
        EVENT_MANAGER:RegisterForEvent(incomingEventName, EVENT_COMBAT_EVENT, function(...)
            Analytics:OnEffectSourceCombatEvent(...)
        end)
        EVENT_MANAGER:AddFilterForEvent(
            incomingEventName,
            EVENT_COMBAT_EVENT,
            REGISTER_FILTER_COMBAT_RESULT,
            result,
            REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE,
            COMBAT_UNIT_TYPE_PLAYER
        )
    end
    if EVENT_EFFECT_CHANGED then
        EVENT_MANAGER:RegisterForEvent("PvPerformanceAnalyticsEffects", EVENT_EFFECT_CHANGED, function(...)
            Analytics:OnEffectChanged(...)
        end)
    end
    if EVENT_POWER_UPDATE then
        EVENT_MANAGER:RegisterForEvent("PvPerformanceAnalyticsResources", EVENT_POWER_UPDATE, function(...)
            Analytics:OnPowerUpdate(...)
        end)
        if REGISTER_FILTER_UNIT_TAG then
            EVENT_MANAGER:AddFilterForEvent(
                "PvPerformanceAnalyticsResources",
                EVENT_POWER_UPDATE,
                REGISTER_FILTER_UNIT_TAG,
                "player"
            )
        end
    end
    if EVENT_ACTION_SLOT_ABILITY_USED then
        EVENT_MANAGER:RegisterForEvent("PvPerformanceAnalyticsUsedSkills", EVENT_ACTION_SLOT_ABILITY_USED, function(...)
            Analytics:OnActionSlotAbilityUsed(...)
        end)
    end
    if EVENT_ACTIVE_WEAPON_PAIR_CHANGED then
        EVENT_MANAGER:RegisterForEvent("PvPerformanceAnalyticsWeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function(...)
            Analytics:OnActiveWeaponPairChanged(...)
        end)
    end
    self.eventsRegistered = true
end

function Analytics:UnregisterDuelEvents()
    if not self.eventsRegistered then
        return
    end
    for _, result in ipairs(PvPerformance.Private.HEAL_COMBAT_RESULTS or {}) do
        EVENT_MANAGER:UnregisterForEvent(string.format("PvPerformanceAnalyticsHealingReceived%d", result), EVENT_COMBAT_EVENT)
    end
    for result in pairs(ANALYTICS_MITIGATION_RESULTS) do
        EVENT_MANAGER:UnregisterForEvent(string.format("PvPerformanceAnalyticsMitigationOutgoing%d", result), EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(string.format("PvPerformanceAnalyticsMitigationIncoming%d", result), EVENT_COMBAT_EVENT)
    end
    for _, result in ipairs(EFFECT_SOURCE_COMBAT_RESULTS) do
        EVENT_MANAGER:UnregisterForEvent(string.format("PvPerformanceAnalyticsEffectSourceOutgoing%d", result), EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(string.format("PvPerformanceAnalyticsEffectSourceIncoming%d", result), EVENT_COMBAT_EVENT)
    end
    if EVENT_EFFECT_CHANGED then
        EVENT_MANAGER:UnregisterForEvent("PvPerformanceAnalyticsEffects", EVENT_EFFECT_CHANGED)
    end
    if EVENT_POWER_UPDATE then
        EVENT_MANAGER:UnregisterForEvent("PvPerformanceAnalyticsResources", EVENT_POWER_UPDATE)
    end
    if EVENT_ACTION_SLOT_ABILITY_USED then
        EVENT_MANAGER:UnregisterForEvent("PvPerformanceAnalyticsUsedSkills", EVENT_ACTION_SLOT_ABILITY_USED)
    end
    if EVENT_ACTIVE_WEAPON_PAIR_CHANGED then
        EVENT_MANAGER:UnregisterForEvent("PvPerformanceAnalyticsWeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    end
    self.eventsRegistered = false
end

local function MatchesOpponent(actorKey, opponentKeys)
    return actorKey ~= "" and opponentKeys[actorKey] == true
end

local function BuildCategory(category, opponentKeys, filterOpponent)
    local combined = {}
    local total = 0
    local absorbedTotal = 0
    local firstActivityMS
    local lastActivityMS
    for actorKey, sources in pairs(category and category.byActor or {}) do
        if not filterOpponent or MatchesOpponent(actorKey, opponentKeys) then
            local activity = category.activityByActor and category.activityByActor[actorKey]
            if activity then
                firstActivityMS = firstActivityMS and math.min(firstActivityMS, activity.firstMS) or activity.firstMS
                lastActivityMS = lastActivityMS and math.max(lastActivityMS, activity.lastMS) or activity.lastMS
            end
            absorbedTotal = absorbedTotal
                + ((category.unattributedAbsorbedByActor and category.unattributedAbsorbedByActor[actorKey]) or 0)
            for identity, source in pairs(sources) do
                local entry = combined[identity]
                if not entry then
                    entry = {
                        name = source.name,
                        abilityId = source.abilityId,
                        total = 0,
                        hitCount = 0,
                        critCount = 0,
                        minHit = nil,
                        maxHit = 0,
                        blockedCount = 0,
                        absorbed = 0,
                    }
                    combined[identity] = entry
                end
                entry.total = entry.total + source.total
                entry.hitCount = entry.hitCount + source.hitCount
                entry.critCount = entry.critCount + source.critCount
                entry.blockedCount = entry.blockedCount + (source.blockedCount or 0)
                entry.absorbed = entry.absorbed + (source.absorbed or 0)
                entry.minHit = entry.minHit and math.min(entry.minHit, source.minHit) or source.minHit
                entry.maxHit = math.max(entry.maxHit, source.maxHit)
            end
        end
    end
    local entries = {}
    for _, entry in pairs(combined) do
        entry.total = math.floor(entry.total + 0.5)
        entry.absorbed = math.floor((entry.absorbed or 0) + 0.5)
        entry.pressureTotal = entry.total + entry.absorbed
        entry.minHit = entry.minHit and math.floor(entry.minHit + 0.5) or nil
        entry.maxHit = math.floor(entry.maxHit + 0.5)
        total = total + entry.total
        absorbedTotal = absorbedTotal + entry.absorbed
        table.insert(entries, entry)
    end
    table.sort(entries, function(left, right)
        if left.pressureTotal ~= right.pressureTotal then
            return left.pressureTotal > right.pressureTotal
        end
        return zo_strlower(left.name) < zo_strlower(right.name)
    end)
    absorbedTotal = math.floor(absorbedTotal + 0.5)
    local activeDurationSeconds
    if firstActivityMS and lastActivityMS then
        -- CMX-style DPS brackets activity from the first qualified event to
        -- the last. A one-second floor prevents a single opening hit from
        -- producing an infinite or meaningless rate.
        activeDurationSeconds = math.max(1, (lastActivityMS - firstActivityMS) / 1000)
    end
    return {
        total = total,
        absorbedTotal = absorbedTotal,
        pressureTotal = total + absorbedTotal,
        activeDurationSeconds = activeDurationSeconds,
        sources = entries,
    }
end

local function FinishBuildStats(runtime)
    local result = { offensive = {}, defensive = {} }
    for groupName, definitions in pairs(STAT_DEFINITIONS) do
        local runtimeGroup = runtime.buildStats[groupName]
        for _, definition in ipairs(definitions) do
            local entry = runtimeGroup[definition.key]
            if entry and entry.count > 0 then
                table.insert(result[groupName], {
                    key = definition.key,
                    label = definition.label,
                    low = math.floor(entry.low + 0.5),
                    average = math.floor(entry.sum / entry.count + 0.5),
                    high = math.floor(entry.high + 0.5),
                })
            end
        end
    end
    return result
end

local function FinishEffectUptimes(runtime, finishMS)
    local durationMS = math.max(1, finishMS - (runtime.startTimeMS or finishMS))
    local entries = {}
    for _, state in pairs(runtime.effectStates or {}) do
        local uptimeMS = tonumber(state.uptimeMS) or 0
        if state.openMS then
            uptimeMS = uptimeMS + math.max(0, finishMS - state.openMS)
        end
        uptimeMS = math.min(durationMS, uptimeMS)
        table.insert(entries, {
            abilityId = state.abilityId,
            name = state.name,
            icon = state.icon,
            effectKind = state.effectKind,
            incoming = state.incoming == true,
            outgoing = state.outgoing == true,
            sourceName = state.sourceName,
            targetName = state.targetName,
            applications = math.max(0, tonumber(state.applications) or 0),
            maxStacks = math.max(0, tonumber(state.maxStacks) or 0),
            uptimeMS = math.floor(uptimeMS + 0.5),
            uptimePercent = math.min(100, uptimeMS / durationMS * 100),
        })
    end
    table.sort(entries, function(left, right)
        if left.uptimeMS ~= right.uptimeMS then
            return left.uptimeMS > right.uptimeMS
        end
        return zo_strlower(left.name or "") < zo_strlower(right.name or "")
    end)
    return entries
end

function Analytics:FinishDuel(tracking, opponentCharacterName, opponentDisplayName)
    self:CancelDuel()
    local runtime = tracking and tracking.analytics
    if not runtime then
        return nil
    end
    SampleAllStats(runtime, true)
    AddSystemEvent(runtime, "infoEvent", "Duel analytics tracking finished.")
    local finishMS = GetGameTimeMilliseconds()
    local opponentKeys = {
        [ActorKey(opponentCharacterName)] = true,
        [ActorKey(opponentDisplayName)] = true,
    }
    opponentKeys[""] = nil
    local log = {}
    for _, event in ipairs(runtime.events) do
        -- Shield-result events identify the ward and may not retain the
        -- opponent's name in the same field as ordinary damage. Their native
        -- source/target player filters already established duel direction, so
        -- keep them without pretending the ward name is an attack source.
        local keep = event.shielded == true
            or event.category == "healingDone"
            or event.category == "healingReceived"
        if event.category == "damageDone" then
            keep = MatchesOpponent(event.targetKey, opponentKeys)
        elseif event.category == "damageTaken" then
            keep = MatchesOpponent(event.sourceKey, opponentKeys)
        end
        if keep then
            table.insert(log, {
                offsetMS = event.offsetMS,
                category = event.category,
                abilityId = event.abilityId,
                name = event.name,
                amount = event.amount,
                critical = event.critical,
                blocked = event.blocked,
                shielded = event.shielded,
                absorbed = event.absorbed,
                sourceName = event.sourceName,
                targetName = event.targetName,
            })
        end
    end
    local effects = {}
    for _, effect in ipairs(runtime.effects or {}) do
        table.insert(effects, {
            offsetMS = effect.offsetMS,
            abilityId = effect.abilityId,
            name = effect.name,
            icon = effect.icon,
            effectKind = effect.effectKind,
            incoming = effect.incoming == true,
            outgoing = effect.outgoing == true,
            sourceName = effect.sourceName,
            targetName = effect.targetName,
            stacks = effect.stacks,
        })
    end
    return {
        schemaVersion = 5,
        damageDone = BuildCategory(runtime.damageDone, opponentKeys, true),
        damageTaken = BuildCategory(runtime.damageTaken, opponentKeys, true),
        healingDone = BuildCategory(runtime.healingDone, opponentKeys, false),
        healingReceived = BuildCategory(runtime.healingReceived, opponentKeys, false),
        combatLog = log,
        droppedLogEvents = runtime.droppedLogEvents,
        effects = effects,
        droppedEffectEvents = runtime.droppedEffectEvents,
        effectUptimes = FinishEffectUptimes(runtime, finishMS),
        systemLog = runtime.systemEvents,
        droppedSystemEvents = runtime.droppedSystemEvents,
        buildStats = FinishBuildStats(runtime),
    }
end
