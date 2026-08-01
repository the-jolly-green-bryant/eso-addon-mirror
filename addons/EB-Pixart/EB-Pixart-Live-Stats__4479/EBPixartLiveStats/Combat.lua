local Addon = EBPixartLiveStats

Addon.Combat = Addon.Combat or {}

local Combat = Addon.Combat
local DEBUG_COMBAT = false
local DEBUG_HEALS = false
local INCLUDE_PLAYER_PET = true
local ALLOW_PLAYER_PET_HEALS = true
local HEAL_FILTER_MODE = "broad_player"
local HEAL_DENYLIST_ABILITY_IDS = {}
local HEAL_DENYLIST_NAMES = {}

local trackedCombat = {
    sessionHealingTotal = 0,
    totalDamage = 0,
    inCombat = false,
}

local sessionHealDebug = {}
local healBreakdownByAbilityId = {}
local healBreakdownTotal = 0
local DEFAULT_HEAL_ICON = "/esoui/art/icons/icon_missing.dds"
local healAnalysisArmed = false
local sessionHealTrackingReady = false

local DAMAGE_RESULTS = {
    [ACTION_RESULT_DAMAGE] = true,
    [ACTION_RESULT_CRITICAL_DAMAGE] = true,
    [ACTION_RESULT_DOT_TICK] = true,
    [ACTION_RESULT_DOT_TICK_CRITICAL] = true,
}

local HEAL_RESULTS = {
    [ACTION_RESULT_HEAL] = true,
    [ACTION_RESULT_CRITICAL_HEAL] = true,
    [ACTION_RESULT_HOT_TICK] = true,
    [ACTION_RESULT_HOT_TICK_CRITICAL] = true,
}

local function IsTrackedDamageSourceType(sourceType)
    if sourceType == COMBAT_UNIT_TYPE_PLAYER then
        return true
    end

    return INCLUDE_PLAYER_PET and sourceType == COMBAT_UNIT_TYPE_PLAYER_PET
end

local function IsTrackedHealingSourceType(sourceType)
    if sourceType == COMBAT_UNIT_TYPE_PLAYER then
        return true
    end

    return ALLOW_PLAYER_PET_HEALS and sourceType == COMBAT_UNIT_TYPE_PLAYER_PET
end

local function DebugCombatEvent(result, sourceType, targetType, abilityName, hitValue)
    if not DEBUG_COMBAT then
        return
    end

    Addon:Print(string.format(
        "Combat retenu result=%s sourceType=%s targetType=%s ability=%s hitValue=%s",
        tostring(result),
        tostring(sourceType),
        tostring(targetType),
        tostring(abilityName),
        tostring(hitValue)
    ))
end

local function DebugHealAccepted(abilityName, abilityId, skillType, hitValue, overflow, absoluteHeal)
    if not DEBUG_HEALS then
        return
    end

    Addon:Print(string.format(
        "Heal retenu ability=%s abilityId=%s skillType=%s hitValue=%s overflow=%s absoluteHeal=%s",
        tostring(abilityName),
        tostring(abilityId),
        tostring(skillType),
        tostring(hitValue),
        tostring(overflow),
        tostring(absoluteHeal)
    ))
end

local function DebugHealRejected(abilityName, abilityId, reason)
    if not DEBUG_HEALS then
        return
    end

    Addon:Print(string.format(
        "Heal rejete ability=%s abilityId=%s reason=%s",
        tostring(abilityName),
        tostring(abilityId),
        tostring(reason)
    ))
end

local function ResolveHealingSkillMapping(abilityId)
    if not abilityId or abilityId <= 0 then
        return false, nil, nil, nil
    end

    local skillType, skillLineIndex, skillIndex, abilityIndex = GetSpecificSkillAbilityKeysByAbilityId(abilityId)
    if not skillType then
        return false, nil, nil, nil
    end

    return true, skillType, skillIndex, abilityIndex
end

local function IsDeniedHealAbility(abilityId, abilityName)
    if abilityId and HEAL_DENYLIST_ABILITY_IDS[abilityId] then
        return true, "denylist abilityId"
    end

    if abilityName and abilityName ~= "" and HEAL_DENYLIST_NAMES[abilityName] then
        return true, "denylist abilityName"
    end

    return false, nil
end

local function IsQuickslotLikeAction(abilityActionSlotType)
    if not abilityActionSlotType then
        return false
    end

    if ACTION_SLOT_TYPE_QUICKSLOT and abilityActionSlotType == ACTION_SLOT_TYPE_QUICKSLOT then
        return true
    end

    if ACTION_SLOT_TYPE_ITEM and abilityActionSlotType == ACTION_SLOT_TYPE_ITEM then
        return true
    end

    return false
end

local function IsPlayerDrivenHealAction(sourceType, abilityActionSlotType, inCombat)
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then
        return false
    end

    if inCombat then
        return true
    end

    if abilityActionSlotType and not IsQuickslotLikeAction(abilityActionSlotType) then
        return true
    end

    return false
end

local function UpdateSessionHealDebug(abilityId, abilityName, absoluteHeal, mappingSucceeded, skillType, skillIndex, abilityIndex)
    local key = tonumber(abilityId) or 0
    local entry = sessionHealDebug[key]
    if not entry then
        entry = {
            abilityName = abilityName ~= "" and abilityName or "Unknown",
            count = 0,
            totalAbsoluteHeal = 0,
            resolvedSkillType = nil,
            resolvedSkillIndex = nil,
            resolvedAbilityIndex = nil,
            mappingSucceeded = false,
        }
        sessionHealDebug[key] = entry
    end

    entry.abilityName = abilityName ~= "" and abilityName or entry.abilityName
    entry.count = entry.count + 1
    entry.totalAbsoluteHeal = entry.totalAbsoluteHeal + absoluteHeal
    entry.mappingSucceeded = entry.mappingSucceeded or mappingSucceeded

    if mappingSucceeded then
        entry.resolvedSkillType = skillType
        entry.resolvedSkillIndex = skillIndex
        entry.resolvedAbilityIndex = abilityIndex
    end
end

local function ResolveHealIcon(abilityId, abilityGraphic)
    if type(GetAbilityIcon) == "function" and abilityId and abilityId > 0 then
        local icon = GetAbilityIcon(abilityId)
        if icon and icon ~= "" then
            return icon
        end
    end

    if abilityGraphic and abilityGraphic ~= "" then
        return abilityGraphic
    end

    return DEFAULT_HEAL_ICON
end

local function NormalizeAbilityName(name)
    if not name or name == "" then
        return nil
    end

    local resolvedName = name

    if type(ZO_CachedStrFormat) == "function" and SI_ABILITY_NAME then
        resolvedName = ZO_CachedStrFormat(SI_ABILITY_NAME, resolvedName)
    end

    resolvedName = tostring(resolvedName)
    resolvedName = resolvedName:gsub("%^[%a%d]+", "")
    resolvedName = resolvedName:gsub("%s+", " ")
    resolvedName = resolvedName:match("^%s*(.-)%s*$")

    if not resolvedName or resolvedName == "" then
        return nil
    end

    return resolvedName
end

local function ResolveAbilityDisplayInfo(abilityId, rawName, rawIcon)
    local resolvedName = nil

    if type(GetAbilityName) == "function" and abilityId and abilityId > 0 then
        resolvedName = NormalizeAbilityName(GetAbilityName(abilityId))
    end

    if not resolvedName then
        resolvedName = NormalizeAbilityName(rawName)
    end

    if not resolvedName then
        if abilityId and abilityId > 0 then
            resolvedName = string.format("Ability #%s", tostring(abilityId))
        else
            resolvedName = "Ability inconnue"
        end
    end

    return resolvedName, ResolveHealIcon(abilityId, rawIcon)
end

local function UpdateHealingBreakdown(abilityId, abilityName, abilityGraphic, absoluteHeal)
    local key = tonumber(abilityId) or 0
    local entry = healBreakdownByAbilityId[key]
    local displayName, resolvedIcon = ResolveAbilityDisplayInfo(key, abilityName, abilityGraphic)
    local rawName = (abilityName and abilityName ~= "") and tostring(abilityName) or nil

    if not entry then
        entry = {
            abilityId = key,
            rawName = rawName,
            displayName = displayName,
            icon = resolvedIcon,
            totalHeal = 0,
            eventCount = 0,
        }
        healBreakdownByAbilityId[key] = entry
    end

    entry.rawName = rawName or entry.rawName
    entry.displayName = displayName or entry.displayName
    entry.icon = resolvedIcon or entry.icon
    entry.totalHeal = entry.totalHeal + absoluteHeal
    entry.eventCount = entry.eventCount + 1
    healBreakdownTotal = healBreakdownTotal + absoluteHeal
end

function Combat:Initialize()
    -- Re-enregistrement defensif pour eviter les doublons apres rechargement.
    EVENT_MANAGER:UnregisterForEvent(Addon.eventNamespace, EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(Addon.eventNamespace, EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(Addon.eventNamespace, EVENT_PLAYER_ACTIVATED)

    trackedCombat.inCombat = false
    self:ResetCurrentCombatDamageOnly()
    self:ResetHealingSessionTotal()
    self:ResetHealAnalysis(false)

    if Addon.sv and Addon.sv.stats then
        Addon.sv.stats.totalDamage = 0
    end

    EVENT_MANAGER:RegisterForEvent(Addon.eventNamespace, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        self:OnPlayerCombatState(inCombat)
    end)

    EVENT_MANAGER:RegisterForEvent(Addon.eventNamespace, EVENT_PLAYER_ACTIVATED, function()
        self:OnPlayerActivated()
    end)

    EVENT_MANAGER:RegisterForEvent(Addon.eventNamespace, EVENT_COMBAT_EVENT, function(
        _,
        result,
        isError,
        abilityName,
        abilityGraphic,
        abilityActionSlotType,
        sourceName,
        sourceType,
        targetName,
        targetType,
        hitValue,
        powerType,
        damageType,
        log,
        sourceUnitId,
        targetUnitId,
        abilityId,
        overflow
    )
        self:OnCombatEvent(
            result,
            isError,
            abilityName,
            abilityGraphic,
            abilityActionSlotType,
            sourceName,
            sourceType,
            targetName,
            targetType,
            hitValue,
            powerType,
            damageType,
            log,
            sourceUnitId,
            targetUnitId,
            abilityId,
            overflow
        )
    end)
end

function Combat:OnPlayerActivated()
    self:ResetHealAnalysis(false)
    sessionHealTrackingReady = false

    if Addon.Session and Addon.Session.HandlePlayerActivated then
        Addon.Session:HandlePlayerActivated()
    end

    if Addon.HealUI and Addon.HealUI.RefreshAll then
        Addon.HealUI:RefreshAll()
    end

    if Addon.UI and Addon.UI.RefreshAll then
        Addon.UI:RefreshAll()
    end
end

function Combat:ResetCurrentCombatDamageOnly()
    trackedCombat.totalDamage = 0
end

function Combat:ResetHealingSessionTotal()
    trackedCombat.sessionHealingTotal = 0
    sessionHealTrackingReady = false

    if Addon.sv and Addon.sv.stats then
        Addon.sv.stats.totalHealing = 0
    end
end

function Combat:ResetHealingSessionDebug()
    sessionHealDebug = {}
end

function Combat:ResetHealingBreakdown()
    healBreakdownByAbilityId = {}
    healBreakdownTotal = 0
end

function Combat:StartHealAnalysisTracking()
    healAnalysisArmed = true
end

function Combat:StopHealAnalysisTracking()
    healAnalysisArmed = false
end

function Combat:IsHealAnalysisTracking()
    return healAnalysisArmed == true
end

function Combat:ResetHealAnalysis(startTracking)
    self:ResetHealingBreakdown()
    healAnalysisArmed = (startTracking == true)
end

function Combat:ShouldIgnoreInitialPassiveHeal(sourceType, abilityActionSlotType)
    if sessionHealTrackingReady then
        return false
    end

    if IsPlayerDrivenHealAction(sourceType, abilityActionSlotType, trackedCombat.inCombat) then
        sessionHealTrackingReady = true
        return false
    end

    return true
end

function Combat:GetCurrentTotals()
    return {
        sessionHealingTotal = trackedCombat.sessionHealingTotal,
        totalDamage = trackedCombat.totalDamage,
        totalHealing = trackedCombat.sessionHealingTotal,
        inCombat = trackedCombat.inCombat,
    }
end

function Combat:GetHealingBreakdown()
    local entries = {}

    for _, entry in pairs(healBreakdownByAbilityId) do
        if (tonumber(entry.totalHeal) or 0) > 0 then
            entries[#entries + 1] = {
                abilityId = entry.abilityId,
                rawName = entry.rawName,
                displayName = entry.displayName,
                icon = entry.icon,
                totalHeal = entry.totalHeal,
                eventCount = entry.eventCount,
            }
        end
    end

    table.sort(entries, function(left, right)
        if left.totalHeal == right.totalHeal then
            if left.displayName == right.displayName then
                return (left.abilityId or 0) < (right.abilityId or 0)
            end

            return tostring(left.displayName) < tostring(right.displayName)
        end

        return left.totalHeal > right.totalHeal
    end)

    return {
        totalHeal = healBreakdownTotal,
        entries = entries,
    }
end

function Combat:GetGroupedHealingBreakdown()
    local rawBreakdown = self:GetHealingBreakdown()
    local groupedEntriesByName = {}
    local groupedEntries = {}

    for _, entry in ipairs(rawBreakdown.entries or {}) do
        local groupKey = tostring(entry.displayName or string.format("Ability #%s", tostring(entry.abilityId or 0)))
        local groupedEntry = groupedEntriesByName[groupKey]

        if not groupedEntry then
            groupedEntry = {
                displayName = groupKey,
                icon = entry.icon,
                totalHeal = 0,
                eventCount = 0,
            }
            groupedEntriesByName[groupKey] = groupedEntry
            groupedEntries[#groupedEntries + 1] = groupedEntry
        end

        if (not groupedEntry.icon or groupedEntry.icon == "") and entry.icon and entry.icon ~= "" then
            groupedEntry.icon = entry.icon
        end

        groupedEntry.totalHeal = groupedEntry.totalHeal + (tonumber(entry.totalHeal) or 0)
        groupedEntry.eventCount = groupedEntry.eventCount + (tonumber(entry.eventCount) or 0)
    end

    table.sort(groupedEntries, function(left, right)
        if left.totalHeal == right.totalHeal then
            return tostring(left.displayName) < tostring(right.displayName)
        end

        return left.totalHeal > right.totalHeal
    end)

    return {
        totalHeal = rawBreakdown.totalHeal or 0,
        entries = groupedEntries,
    }
end

function Combat:IsTrackedHealingAbility(abilityId)
    local mappingSucceeded, skillType, skillIndex, abilityIndex = ResolveHealingSkillMapping(abilityId)
    if not mappingSucceeded then
        return false, nil, "no skill mapping"
    end

    if skillType == SKILL_TYPE_CLASS or skillType == SKILL_TYPE_WEAPON then
        return true, skillType, nil, skillIndex, abilityIndex, true
    end

    return false, skillType, "skillType not allowed", skillIndex, abilityIndex, true
end

function Combat:ResetHealingTracking()
    self:ResetHealAnalysis(false)

    if Addon.HealUI and Addon.HealUI.RefreshAll then
        Addon.HealUI:RefreshAll()
    end
end

function Combat:ResetTrackedSessionData()
    local shouldTrackHealAnalysis = self:IsHealAnalysisTracking()

    trackedCombat.inCombat = false
    self:ResetCurrentCombatDamageOnly()
    self:ResetHealingSessionTotal()
    self:ResetHealingSessionDebug()
    self:ResetHealAnalysis(shouldTrackHealAnalysis)

    if Addon.sv and Addon.sv.stats then
        Addon.sv.stats.totalDamage = 0
        Addon.sv.stats.totalHealing = 0
        Addon.sv.stats.combatStartAt = 0
        Addon.sv.stats.lastCombatEndAt = 0
    end
end

function Combat:DumpHealingDebug()
    local entries = {}
    for abilityId, entry in pairs(sessionHealDebug) do
        entries[#entries + 1] = {
            abilityId = abilityId,
            abilityName = entry.abilityName,
            totalAbsoluteHeal = entry.totalAbsoluteHeal,
            count = entry.count,
            mappingSucceeded = entry.mappingSucceeded,
            resolvedSkillType = entry.resolvedSkillType,
        }
    end

    table.sort(entries, function(left, right)
        if left.totalAbsoluteHeal == right.totalAbsoluteHeal then
            return left.abilityId < right.abilityId
        end

        return left.totalAbsoluteHeal > right.totalAbsoluteHeal
    end)

    if #entries == 0 then
        Addon:Print("Aucun heal de session retenu pour le moment.")
        return
    end

    local maxLines = zo_min(20, #entries)
    Addon:Print(string.format("Top %d heals de session :", maxLines))

    for index = 1, maxLines do
        local entry = entries[index]
        Addon:Print(string.format(
            "%s | %s | %s | %s | %s | %s",
            tostring(entry.abilityId),
            tostring(entry.abilityName),
            tostring(entry.totalAbsoluteHeal),
            tostring(entry.count),
            entry.mappingSucceeded and "mapped" or "unmapped",
            tostring(entry.resolvedSkillType)
        ))
    end
end

function Combat:OnPlayerCombatState(inCombat)
    trackedCombat.inCombat = inCombat

    if inCombat then
        self:ResetCurrentCombatDamageOnly()
    end

    if Addon.sv and Addon.sv.stats then
        if inCombat then
            Addon.sv.stats.totalDamage = 0
        end

        Addon.sv.stats.combatStartAt = inCombat and GetFrameTimeMilliseconds() or Addon.sv.stats.combatStartAt
        Addon.sv.stats.lastCombatEndAt = (not inCombat) and GetFrameTimeMilliseconds() or Addon.sv.stats.lastCombatEndAt
    end

    if Addon.UI and Addon.UI.RefreshAll then
        Addon.UI:RefreshAll()
    end
end

function Combat:OnCombatEvent(
    result,
    isError,
    abilityName,
    abilityGraphic,
    abilityActionSlotType,
    sourceName,
    sourceType,
    targetName,
    targetType,
    hitValue,
    powerType,
    damageType,
    log,
    sourceUnitId,
    targetUnitId,
    abilityId,
    overflow
)
    if isError then
        return
    end

    if DAMAGE_RESULTS[result] then
        if sourceType == COMBAT_UNIT_TYPE_PLAYER then
            sessionHealTrackingReady = true
        end

        if Addon.sv and Addon.sv.healAnalysisAutoTracking and sourceType == COMBAT_UNIT_TYPE_PLAYER and not self:IsHealAnalysisTracking() then
            self:StartHealAnalysisTracking()
        end

        if not trackedCombat.inCombat or not IsTrackedDamageSourceType(sourceType) then
            return
        end

        local value = tonumber(hitValue)
        if not value or value <= 0 then
            return
        end

        trackedCombat.totalDamage = trackedCombat.totalDamage + value
        if Addon.sv and Addon.sv.stats then
            Addon.sv.stats.totalDamage = trackedCombat.totalDamage
        end

        if Addon.Session and Addon.Session.NotifyDamageActivity then
            Addon.Session:NotifyDamageActivity()
        end

        DebugCombatEvent(result, sourceType, targetType, abilityName, value)

        if Addon.UI and Addon.UI.RefreshAll then
            Addon.UI:RefreshAll()
        end

        return
    end

    if not HEAL_RESULTS[result] then
        DebugHealRejected(abilityName, abilityId, "invalid result")
        return
    end

    if not IsTrackedHealingSourceType(sourceType) then
        DebugHealRejected(abilityName, abilityId, "bad sourceType")
        return
    end

    local isDenied, denyReason = IsDeniedHealAbility(abilityId, abilityName)
    if isDenied then
        DebugHealRejected(abilityName, abilityId, denyReason)
        return
    end

    if IsQuickslotLikeAction(abilityActionSlotType) then
        DebugHealRejected(abilityName, abilityId, "quickslot/item")
        return
    end

    local isTrackedAbility, skillType, rejectionReason, skillIndex, abilityIndex, mappingSucceeded = self:IsTrackedHealingAbility(abilityId)

    if HEAL_FILTER_MODE == "strict_skill_only" and not isTrackedAbility then
        DebugHealRejected(abilityName, abilityId, rejectionReason)
        return
    end

    local effectiveHeal = zo_max(0, tonumber(hitValue) or 0)
    local overheal = zo_max(0, tonumber(overflow) or 0)
    local absoluteHeal = effectiveHeal + overheal
    if absoluteHeal <= 0 then
        return
    end

    if self:ShouldIgnoreInitialPassiveHeal(sourceType, abilityActionSlotType) then
        DebugHealRejected(abilityName, abilityId, "initial passive heal")
        return
    end

    if Addon.sv and Addon.sv.healAnalysisAutoTracking and sourceType == COMBAT_UNIT_TYPE_PLAYER and not self:IsHealAnalysisTracking() then
        self:StartHealAnalysisTracking()
    end

    trackedCombat.sessionHealingTotal = trackedCombat.sessionHealingTotal + absoluteHeal

    if Addon.sv and Addon.sv.stats then
        Addon.sv.stats.totalHealing = trackedCombat.sessionHealingTotal
    end

    if self:IsHealAnalysisTracking() then
        UpdateHealingBreakdown(abilityId, abilityName, abilityGraphic, absoluteHeal)

        if Addon.Session and Addon.Session.NotifyHealingActivity then
            Addon.Session:NotifyHealingActivity()
        end
    end
    UpdateSessionHealDebug(abilityId, abilityName, absoluteHeal, mappingSucceeded, skillType, skillIndex, abilityIndex)
    DebugHealAccepted(abilityName, abilityId, skillType, effectiveHeal, overheal, absoluteHeal)

    if Addon.UI and Addon.UI.RefreshAll then
        Addon.UI:RefreshAll()
    end

    if Addon.HealUI and Addon.HealUI.RefreshAll then
        Addon.HealUI:RefreshAll()
    end
end
