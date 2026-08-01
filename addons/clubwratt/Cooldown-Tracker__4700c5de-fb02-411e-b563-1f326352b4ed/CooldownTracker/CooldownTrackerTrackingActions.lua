-- CooldownTrackerTrackingActions.lua
-- Tracking engine: tracker CRUD, event subscriptions, active entries, discovery/recents.

---@type CooldownTracker
local CooldownTracker = assert(_G["CooldownTracker"], "CooldownTracker global missing")
local TrackingUtils = assert(CooldownTracker.TrackingUtils, "CooldownTracker.TrackingUtils missing (load order issue)")

local TrackingActions = {}
CooldownTracker.TrackingActions = TrackingActions

TrackingActions.ICON_MODE = TrackingUtils.ICON_MODE
TrackingActions.CALLBACK_RECENTS_UPDATED = "CooldownTracker_RecentsUpdated"

local function FireRecentsUpdated()
    if CALLBACK_MANAGER and CALLBACK_MANAGER.FireCallbacks then
        CALLBACK_MANAGER:FireCallbacks(TrackingActions.CALLBACK_RECENTS_UPDATED)
    end
end

-- Valid combat results for proc detection
local VALID_COMBAT_RESULTS = {
    [ACTION_RESULT_EFFECT_GAINED] = true,
    [ACTION_RESULT_EFFECT_GAINED_DURATION] = true,
    [ACTION_RESULT_POWER_ENERGIZE] = true,
    [ACTION_RESULT_HEAL] = true,
    [ACTION_RESULT_CRITICAL_HEAL] = true,
    [ACTION_RESULT_DAMAGE] = true,
    [ACTION_RESULT_CRITICAL_DAMAGE] = true,
}

local FALLBACK_ICON = TrackingUtils.FALLBACK_ICON
local EFFECT_UPDATE_TOLERANCE = TrackingUtils.EFFECT_UPDATE_TOLERANCE
local PERMANENT_DURATION_SECONDS = TrackingUtils.PERMANENT_DURATION_SECONDS

local GetNow = TrackingUtils.GetNow
local IsPlayerCombatSource = TrackingUtils.IsPlayerCombatSource
local IsMissingIcon = TrackingUtils.IsMissingIcon
local IsGenericAbilityIcon = TrackingUtils.IsGenericAbilityIcon
local NormalizeEventIcon = TrackingUtils.NormalizeEventIcon
local GetAbilityIconSafe = TrackingUtils.GetAbilityIconSafe
local NormalizeSetName = TrackingUtils.NormalizeSetName
local GetSetPieceIconPriority = TrackingUtils.GetSetPieceIconPriority
local GetSetCollectionIdByName = TrackingUtils.GetSetCollectionIdByName
local GetCollectionSetIdForSetId = TrackingUtils.GetCollectionSetIdForSetId

-- State (canonical tables live under CooldownTracker.State)
local trackingState = CooldownTracker.State and CooldownTracker.State.tracking
local trackerDefinitions = trackingState.trackerDefinitions
local activeCooldowns = trackingState.activeCooldowns
local recentProcs = trackingState.recentProcs
local equippedSets = trackingState.equippedSets
local equippedSetIconPriority = trackingState.equippedSetIconPriority
local registeredEvents = trackingState.registeredEvents

-- Scratch arrays to avoid per-tick allocations in the update loop.
local activeEntriesScratch = trackingState.activeEntriesScratch or {}
trackingState.activeEntriesScratch = activeEntriesScratch

---@param tracker TrackerDefinition|nil
---@param stackCount number|nil
local function MaybeMarkTrackerStackable(tracker, stackCount)
    if not tracker then
        return
    end
    if type(stackCount) == "number" and stackCount > 1 then
        tracker.isStackable = true
        if tracker.minStacksToShow == nil then
            tracker.minStacksToShow = 0
        end
    end
end

---@param tracker TrackerDefinition
---@param eventAbilityId number
---@return boolean
local function TrackerMatchesEventAbilityId(tracker, eventAbilityId)
    if not tracker or not tracker.abilityId then
        return false
    end
    return tracker.abilityId == eventAbilityId
end

---@param abilityName string|nil
---@return string|nil
local function GetEquippedSetIconByName(abilityName)
    local normalized = NormalizeSetName(abilityName)
    if not normalized then
        return nil
    end
    for _, setData in pairs(equippedSets) do
        local setName = setData.name and NormalizeSetName(setData.name)
        if setName and setName == normalized then
            if setData.icon and setData.icon ~= "" then
                return setData.icon
            end
            return nil
        end
    end
    return nil
end

---@param setId number|nil
---@return string|nil
local function GetSetCollectionIconBySetId(setId)
    local collectionSetId = GetCollectionSetIdForSetId(setId)
    if not collectionSetId then
        return nil
    end
    if not GetNumItemSetCollectionPieces or not GetItemSetCollectionPieceInfo or not GetItemSetCollectionPieceItemLink then
        return nil
    end

    local pieceCount = GetNumItemSetCollectionPieces(collectionSetId)
    if not pieceCount or pieceCount <= 0 then
        return nil
    end

    local fallbackIcon = nil
    for index = 1, pieceCount do
        local pieceId = select(1, GetItemSetCollectionPieceInfo(collectionSetId, index))
        if pieceId and pieceId > 0 then
            local itemLink = GetItemSetCollectionPieceItemLink(pieceId, LINK_STYLE_DEFAULT, ITEM_TRAIT_TYPE_NONE, nil)
            if itemLink and itemLink ~= "" then
                local icon = GetItemLinkIcon(itemLink)
                if not IsMissingIcon(icon) then
                    fallbackIcon = fallbackIcon or icon
                end
                if GetItemLinkEquipType and icon then
                    local equipType = GetItemLinkEquipType(itemLink)
                    if equipType == EQUIP_TYPE_HEAD then
                        return icon
                    end
                end
            end
        end
    end

    return fallbackIcon
end

---@param setId number|nil
---@return string|nil
local function GetSetIconBySetId(setId)
    if not setId or setId <= 0 then
        return nil
    end
    local setData = equippedSets[setId]
    if setData and not IsMissingIcon(setData.icon) then
        return setData.icon
    end
    local collectionIcon = GetSetCollectionIconBySetId(setId)
    if not IsMissingIcon(collectionIcon) then
        return collectionIcon
    end
    return nil
end

---@param setName string|nil
---@return string|nil
local function GetSetIconByName(setName)
    local setIcon = GetEquippedSetIconByName(setName)
    if not IsMissingIcon(setIcon) then
        return setIcon
    end
    local collectionSetId = GetSetCollectionIdByName(setName)
    if collectionSetId then
        local collectionIcon = GetSetCollectionIconBySetId(collectionSetId)
        if not IsMissingIcon(collectionIcon) then
            return collectionIcon
        end
    end
    return nil
end

---@param abilityId number
---@param abilityName string|nil
---@param eventIcon string|nil
---@return string|nil
local function ResolveCombatIcon(abilityId, abilityName, eventIcon)
    local abilityIcon = GetAbilityIconSafe(abilityId)
    if abilityIcon and not IsGenericAbilityIcon(abilityIcon) then
        return abilityIcon
    end
    local setIcon = GetSetIconByName(abilityName)
    if not IsMissingIcon(setIcon) then
        return setIcon
    end
    if abilityIcon then
        return abilityIcon
    end
    return FALLBACK_ICON
end

--- Get icon for a tracker with fallback chain.
-- Icon pipeline: custom override → ability icon → set icon → fallback.
---@param tracker TrackerDefinition
---@param eventIcon string|nil Icon from the triggering event
---@return string
function TrackingActions.GetIcon(tracker, eventIcon)
    -- 1. Custom icon override
    if tracker.iconMode == TrackingActions.ICON_MODE.CUSTOM and tracker.customIcon then
        return tracker.customIcon
    end

    local abilityIcon = GetAbilityIconSafe(tracker.abilityId)

    -- 2. Force set icon mode
    if tracker.iconMode == TrackingActions.ICON_MODE.SET_PIECE then
        local setIcon = tracker.setId and GetSetIconBySetId(tracker.setId) or GetSetIconByName(tracker.name)
        if not IsMissingIcon(setIcon) then
            ---@cast setIcon string
            return setIcon
        end
        if abilityIcon then
            return abilityIcon
        end
        return FALLBACK_ICON
    end

    -- 3. Ability-first modes (ABILITY/AUTO/default)
    if abilityIcon and not IsGenericAbilityIcon(abilityIcon) then
        return abilityIcon
    end
    local setIcon = tracker.setId and GetSetIconBySetId(tracker.setId) or GetSetIconByName(tracker.name)
    if not IsMissingIcon(setIcon) then
        ---@cast setIcon string
        return setIcon
    end
    if abilityIcon then
        return abilityIcon
    end
    return FALLBACK_ICON
end

--- Get a list of icon candidates for debugging/inspection.
---@param abilityId number|nil
---@param abilityName string|nil
---@param eventIcon string|nil
---@param tracker TrackerDefinition|nil
---@return { label: string, icon: string|nil }[]
function TrackingActions.GetIconSourceList(abilityId, abilityName, eventIcon, tracker)
    local sources = {}
    local customIcon = nil
    local trackerIconMode = tracker and tracker.iconMode
    if trackerIconMode == TrackingActions.ICON_MODE.CUSTOM then
        customIcon = tracker and tracker.customIcon or nil
    end

    sources[#sources + 1] = { label = "Custom override", icon = customIcon }
    sources[#sources + 1] = { label = "Event icon", icon = NormalizeEventIcon(eventIcon) }

    local abilityIcon = GetAbilityIconSafe(abilityId)
    local abilityLabel = IsGenericAbilityIcon(abilityIcon) and "Ability icon (generic fallback)" or "Ability icon"
    sources[#sources + 1] = { label = abilityLabel, icon = abilityIcon }

    local setIconById = tracker and tracker.setId and GetSetIconBySetId(tracker.setId) or nil
    local setIconByName = GetSetIconByName(abilityName)
    sources[#sources + 1] = { label = "Set icon (equipped)", icon = setIconById or setIconByName }
    sources[#sources + 1] = { label = "Set icon (equipped by name)", icon = setIconByName }

    return sources
end

--- Refresh equipped sets from inventory.
function TrackingActions.RefreshEquippedSets()
    ZO_ClearTable(equippedSets)
    ZO_ClearTable(equippedSetIconPriority)

    for slot = EQUIP_SLOT_HEAD, EQUIP_SLOT_ITERATION_END do
        local itemLink = GetItemLink(BAG_WORN, slot, LINK_STYLE_DEFAULT)
        if itemLink and itemLink ~= "" then
            local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, true)
            if hasSet and setId and setId > 0 then
                local icon = GetItemLinkIcon(itemLink)
                local priority = GetSetPieceIconPriority(itemLink)
                if IsMissingIcon(icon) then
                    icon = FALLBACK_ICON
                    priority = 0
                end

                local setEntry = equippedSets[setId]
                if not setEntry then
                    equippedSets[setId] = {
                        name = zo_strformat("<<t:1>>", setName),
                        icon = icon,
                    }
                    equippedSetIconPriority[setId] = priority
                else
                    local currentPriority = equippedSetIconPriority[setId] or 0
                    if priority > currentPriority then
                        setEntry.icon = icon
                        equippedSetIconPriority[setId] = priority
                    end
                end
            end
        end
    end
end

--- Get count of equipped sets.
---@return number
function TrackingActions.GetEquippedSetCount()
    local count = 0
    for _ in pairs(equippedSets) do
        count = count + 1
    end
    return count
end

--- Get equipped set info.
---@param setId number
---@return { name: string, icon: string }|nil
function TrackingActions.GetEquippedSet(setId)
    return equippedSets[setId]
end

--- Get all equipped sets.
---@return table<number, { name: string, icon: string }>
function TrackingActions.GetAllEquippedSets()
    return equippedSets
end

--- Check if a set is equipped.
---@param setId number
---@return boolean
function TrackingActions.IsSetEquipped(setId)
    return equippedSets[setId] ~= nil
end

--- Add or update a tracker definition.
---@param tracker TrackerDefinition
function TrackingActions.SetTracker(tracker)
    if not tracker or not tracker.id then
        return
    end
    local cooldownSeconds = tonumber(tracker.cooldownSeconds) or 0
    if cooldownSeconds < 0 then
        -- Negative cooldown modes require effect change events.
        tracker.useCombatEvent = false
        if cooldownSeconds < -1 then
            tracker.cooldownSeconds = -2
            cooldownSeconds = -2
        end
    end
    trackerDefinitions[tracker.id] = tracker
    TrackingActions.RefreshEventRegistrations()
    if TrackingActions.SyncMissingBuffTrackers then
        TrackingActions.SyncMissingBuffTrackers()
    end
end

--- Remove a tracker definition.
---@param trackerId string
function TrackingActions.RemoveTracker(trackerId)
    trackerDefinitions[trackerId] = nil
    activeCooldowns[trackerId] = nil
    TrackingActions.RefreshEventRegistrations()
end

--- Get a tracker definition.
---@param trackerId string
---@return TrackerDefinition|nil
function TrackingActions.GetTracker(trackerId)
    return trackerDefinitions[trackerId]
end

--- Get all tracker definitions.
---@return table<string, TrackerDefinition>
function TrackingActions.GetAllTrackers()
    return trackerDefinitions
end

--- Clear all trackers.
function TrackingActions.ClearTrackers()
    ZO_ClearTable(trackerDefinitions)
    ZO_ClearTable(activeCooldowns)
    TrackingActions.UnregisterAllEvents()
end

--- Load trackers from savedvars.
---@param savedTrackers table<string, TrackerDefinition>|nil
function TrackingActions.LoadTrackers(savedTrackers)
    if not savedTrackers then
        return
    end
    for id, tracker in pairs(savedTrackers) do
        tracker.id = id -- Ensure ID is set
        local cooldownSeconds = tonumber(tracker.cooldownSeconds) or 0
        if cooldownSeconds < 0 then
            -- Negative cooldown modes require effect change events.
            tracker.useCombatEvent = false
            if cooldownSeconds < -1 then
                tracker.cooldownSeconds = -2
                cooldownSeconds = -2
            end
        end
        trackerDefinitions[id] = tracker
    end
    TrackingActions.RefreshEventRegistrations()
    if TrackingActions.SyncMissingBuffTrackers then
        TrackingActions.SyncMissingBuffTrackers()
    end
end

--- Start a cooldown for a tracker.
---@param trackerId string
---@param eventIcon string|nil Icon from the triggering event
function TrackingActions.StartCooldown(trackerId, eventIcon)
    local tracker = trackerDefinitions[trackerId]
    if not tracker or not tracker.enabled then
        return
    end

    -- Check if set is still equipped (for set trackers)
    if tracker.setId and not TrackingActions.IsSetEquipped(tracker.setId) then
        return
    end

    local now = GetNow()
    local rawSeconds = tonumber(tracker.cooldownSeconds) or 0
    local isPermanent = rawSeconds == 0
    local cdSeconds = rawSeconds
    if isPermanent then
        cdSeconds = PERMANENT_DURATION_SECONDS
    elseif cdSeconds < 0 then
        cdSeconds = 0
    end
    local isCooldown = rawSeconds > 0

    -- Check if cooldown already active; on re-proc, refresh/extend the timer
    local existing = activeCooldowns[trackerId]
    if existing and existing.endTime > now then
        existing.endTime = now + cdSeconds
        existing.remaining = cdSeconds
        existing.maxDuration = cdSeconds
        existing.name = tracker.name
        existing.icon = TrackingActions.GetIcon(tracker, eventIcon)
        existing.isCooldown = isCooldown
        existing.isPermanent = isPermanent
        -- Reset effect snapshot so we don't carry extension deltas across separate procs.
        existing.effectEndSnapshot = nil
        return
    end

    -- Create active entry
    local icon = TrackingActions.GetIcon(tracker, eventIcon)

    activeCooldowns[trackerId] = {
        id = trackerId,
        name = tracker.name,
        icon = icon,
        remaining = cdSeconds,
        maxDuration = cdSeconds,
        endTime = now + cdSeconds,
        effectEndSnapshot = nil,
        effectStackCount = nil,
        isCooldown = isCooldown,
        isPermanent = isPermanent,
    }
end

--- Start or update an effect-style tracker entry using the game's effect endTime.
--- This is used when cooldownSeconds == 0 (permanent after trigger) or -2 (follow effect timer).
---@param trackerId string
---@param eventIcon string|nil
---@param effectBeginTime number
---@param effectEndTime number
---@param stackCount number|nil
function TrackingActions.StartOrUpdateEffect(trackerId, eventIcon, effectBeginTime, effectEndTime, stackCount)
    local tracker = trackerDefinitions[trackerId]
    if not tracker or not tracker.enabled then
        return
    end

    -- Check if set is still equipped (for set trackers)
    if tracker.setId and not TrackingActions.IsSetEquipped(tracker.setId) then
        return
    end

    MaybeMarkTrackerStackable(tracker, stackCount)

    local now = GetNow()
    local rawSeconds = tonumber(tracker.cooldownSeconds) or 0
    local isPermanent = rawSeconds == 0

    local endAt = effectEndTime
    if isPermanent then
        endAt = now + PERMANENT_DURATION_SECONDS
    elseif type(endAt) ~= "number" or endAt <= 0 then
        -- Treat missing/0 end times as "very long" so the tracker stays visible.
        endAt = now + PERMANENT_DURATION_SECONDS
    end

    local duration = 0
    if isPermanent then
        duration = PERMANENT_DURATION_SECONDS
    elseif type(effectBeginTime) == "number" and effectBeginTime > 0 and endAt > effectBeginTime then
        duration = endAt - effectBeginTime
    elseif endAt > now then
        duration = endAt - now
    end
    if duration <= 0 then
        duration = 0.1
    end

    local remaining = endAt - now
    if remaining <= 0 then
        if not isPermanent then
            activeCooldowns[trackerId] = nil
            return
        end
        endAt = now + PERMANENT_DURATION_SECONDS
        remaining = PERMANENT_DURATION_SECONDS
    end

    local icon = TrackingActions.GetIcon(tracker, eventIcon)
    local entry = activeCooldowns[trackerId]
    if entry then
        entry.name = tracker.name
        entry.icon = icon
        entry.endTime = endAt
        entry.remaining = remaining
        entry.maxDuration = duration
        entry.isCooldown = false
        entry.isPermanent = isPermanent
        entry.effectEndSnapshot = endAt
        if type(stackCount) == "number" then
            entry.effectStackCount = stackCount
        end
    else
        activeCooldowns[trackerId] = {
            id = trackerId,
            name = tracker.name,
            icon = icon,
            remaining = remaining,
            maxDuration = duration,
            endTime = endAt,
            effectEndSnapshot = endAt,
            effectStackCount = type(stackCount) == "number" and stackCount or nil,
            isCooldown = false,
            isPermanent = isPermanent,
        }
    end
end

--- Stop tracking an active entry immediately.
---@param trackerId string
function TrackingActions.StopActiveEntry(trackerId)
    activeCooldowns[trackerId] = nil
end

--- Get all active cooldowns as entries for rendering.
---@return ActiveEntry[]
function TrackingActions.GetActiveEntries()
    local now = GetNow()
    local entries = activeEntriesScratch
    local write = 0

    for trackerId, entry in pairs(activeCooldowns) do
        local isPermanent = entry.isPermanent == true
        local remaining = (entry.endTime or 0) - now
        if isPermanent then
            entry.endTime = now + PERMANENT_DURATION_SECONDS
            remaining = PERMANENT_DURATION_SECONDS
        end
        if remaining > 0 then
            entry.remaining = remaining
            entry.isPermanent = isPermanent
            entry.isCooldown = entry.isCooldown ~= false
            entry.stackCount = entry.effectStackCount

            write = write + 1
            entries[write] = entry
        else
            activeCooldowns[trackerId] = nil
        end
    end

    for i = write + 1, #entries do
        entries[i] = nil
    end

    return entries
end

--- Record a recent proc for the "recents" list.
---@param abilityId number
---@param name string
---@param icon string
---@param source string|nil "effect" or "combat" - how the proc was observed
---@param lastResult number|nil Combat result, when observed via EVENT_COMBAT_EVENT
---@param eventIcon string|nil Raw event icon (when available)
function TrackingActions.RecordRecentProc(abilityId, name, icon, source, lastResult, eventIcon)
    if trackingState.discoveryActive ~= true then
        return
    end
    local now = GetNow()
    local existing = recentProcs[abilityId]
    if existing then
        existing.lastSeen = now
        existing.count = existing.count + 1
        if icon and icon ~= "" then
            existing.icon = icon
        end
        if source then
            existing.lastSource = source
        end
        if type(lastResult) == "number" then
            existing.lastResult = lastResult
        end
        if type(eventIcon) == "string" and eventIcon ~= "" then
            existing.eventIcon = eventIcon
        end
    else
        recentProcs[abilityId] = {
            abilityId = abilityId,
            name = name,
            icon = icon,
            eventIcon = type(eventIcon) == "string" and eventIcon ~= "" and eventIcon or nil,
            firstSeen = now,
            lastSeen = now,
            count = 1,
            lastSource = source or "effect",
            lastResult = type(lastResult) == "number" and lastResult or nil,
        }
    end

    FireRecentsUpdated()
end

--- Get a specific recent proc by ability ID.
---@param abilityId number
---@return CooldownTrackerRecentProc|nil
function TrackingActions.GetRecentProc(abilityId)
    return recentProcs[abilityId]
end

--- Get recent procs (for settings UI).
---@return CooldownTrackerRecentProc[]
function TrackingActions.GetRecentProcs()
    local result = {}
    for _, proc in pairs(recentProcs) do
        table.insert(result, proc)
    end
    -- Sort by most recent so new procs surface in settings.
    table.sort(result, function(a, b)
        local aTime = a.lastSeen or a.firstSeen or 0
        local bTime = b.lastSeen or b.firstSeen or 0
        if aTime == bTime then
            return (a.abilityId or 0) < (b.abilityId or 0)
        end
        return aTime > bTime
    end)
    return result
end

--- Clear recent procs.
function TrackingActions.ClearRecentProcs()
    ZO_ClearTable(recentProcs)
    FireRecentsUpdated()
end

--- Remove one recent proc by ability ID.
---@param abilityId number|nil
---@return boolean
function TrackingActions.RemoveRecentProc(abilityId)
    if type(abilityId) ~= "number" then
        return false
    end
    if not recentProcs[abilityId] then
        return false
    end
    recentProcs[abilityId] = nil
    FireRecentsUpdated()
    return true
end

-- Temporary combat-event discovery for finding hidden proc IDs
local COMBAT_DISCOVERY_EVENT_NAME = "CooldownTracker_CombatDiscovery"
local COMBAT_DISCOVERY_AUTO_STOP_MS = 30000

local DISCOVERY_COMBAT_RESULTS = {
    [ACTION_RESULT_EFFECT_GAINED] = true,
    [ACTION_RESULT_EFFECT_GAINED_DURATION] = true,
    [ACTION_RESULT_POWER_ENERGIZE] = true,
    [ACTION_RESULT_DOT_TICK] = true,
    [ACTION_RESULT_DOT_TICK_CRITICAL] = true,
    -- Include common results so hidden procs (including scribing scripts) that only
    -- appear as damage/heal still show up in recents discovery.
    [ACTION_RESULT_HEAL] = true,
    [ACTION_RESULT_CRITICAL_HEAL] = true,
    [ACTION_RESULT_DAMAGE] = true,
    [ACTION_RESULT_CRITICAL_DAMAGE] = true,
}

local function OnCombatDiscoveryEvent(eventId, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
                                      sourceName, sourceType, targetName, targetType, hitValue, powerType,
                                      damageType, log, sourceUnitId, targetUnitId, abilityId)
    if trackingState.combatDiscoveryActive ~= true then
        return
    end
    if isError == true then
        return
    end
    if not abilityId or abilityId <= 0 then
        return
    end
    if not DISCOVERY_COMBAT_RESULTS[result] then
        return
    end
    if not IsPlayerCombatSource(sourceName, sourceType) then
        return
    end

    local formattedName = zo_strformat("<<t:1>>", abilityName)
    local eventIcon = NormalizeEventIcon(abilityGraphic)
    local icon = ResolveCombatIcon(abilityId, formattedName, eventIcon)
    TrackingActions.RecordRecentProc(abilityId, formattedName, icon, "combat", result, eventIcon)
end

--- Start watching combat events to populate recents.
function TrackingActions.StartCombatDiscovery()
    TrackingActions.StopCombatDiscovery()
    trackingState.combatDiscoveryActive = true
    trackingState.discoveryActive = true
    TrackingActions.RefreshEventRegistrations()

    trackingState.combatDiscoveryAutoStopCallLaterId = zo_callLater(function()
        if trackingState.combatDiscoveryActive == true then
            TrackingActions.StopCombatDiscovery()
            if CooldownTracker and CooldownTracker.Log then
                CooldownTracker:Log("Watch combat auto-disabled (performance safety).")
            end
        end
    end, COMBAT_DISCOVERY_AUTO_STOP_MS)

    EVENT_MANAGER:RegisterForEvent(COMBAT_DISCOVERY_EVENT_NAME, EVENT_COMBAT_EVENT, OnCombatDiscoveryEvent)
    EVENT_MANAGER:AddFilterForEvent(COMBAT_DISCOVERY_EVENT_NAME, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)

    -- Keep this as filtered as we reasonably can to avoid spam/perf issues.
    -- Avoid source-type filtering here; some set procs report non-player source types.
    for resultCode in pairs(DISCOVERY_COMBAT_RESULTS) do
        EVENT_MANAGER:AddFilterForEvent(COMBAT_DISCOVERY_EVENT_NAME, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT,
            resultCode)
    end

    FireRecentsUpdated()
end

--- Check if combat discovery is currently active.
---@return boolean
function TrackingActions.IsCombatDiscoveryActive()
    return trackingState.combatDiscoveryActive == true
end

--- Toggle combat discovery on/off.
---@return boolean isActive
function TrackingActions.ToggleCombatDiscovery()
    if TrackingActions.IsCombatDiscoveryActive() then
        TrackingActions.StopCombatDiscovery()
        return false
    end
    TrackingActions.StartCombatDiscovery()
    return true
end

--- Stop combat discovery mode (if active).
function TrackingActions.StopCombatDiscovery()
    local autoStopId = trackingState.combatDiscoveryAutoStopCallLaterId
    if type(autoStopId) == "number" then
        zo_removeCallLater(autoStopId)
    end
    trackingState.combatDiscoveryAutoStopCallLaterId = nil

    local changed = trackingState.combatDiscoveryActive == true or trackingState.discoveryActive == true
    if trackingState.combatDiscoveryActive == true then
        trackingState.combatDiscoveryActive = false
        EVENT_MANAGER:UnregisterForEvent(COMBAT_DISCOVERY_EVENT_NAME, EVENT_COMBAT_EVENT)
    end
    if trackingState.discoveryActive == true then
        trackingState.discoveryActive = false
        TrackingActions.RefreshEventRegistrations()
    end
    if changed then
        FireRecentsUpdated()
    end
end

---@param tracker TrackerDefinition
---@param result number
---@return boolean
local function MatchesCombatResult(tracker, result)
    if tracker and tracker.initialHitResult then
        if tracker.initialHitResult == ACTION_RESULT_DOT_TICK
            or tracker.initialHitResult == ACTION_RESULT_DOT_TICK_CRITICAL
        then
            return result == ACTION_RESULT_DOT_TICK or result == ACTION_RESULT_DOT_TICK_CRITICAL
        end
        return result == tracker.initialHitResult
    end
    return VALID_COMBAT_RESULTS[result] == true
end

---@param abilityId number|nil
---@return number|nil
local function FindPlayerBuffStack(abilityId)
    if type(abilityId) ~= "number" then
        return nil
    end

    local numBuffs = GetNumBuffs("player")
    if not numBuffs or numBuffs <= 0 then
        return nil
    end

    for i = 1, numBuffs do
        local _, _, _, _, stackCount, _, _, _, _, _, buffAbilityId = GetUnitBuffInfo("player", i)
        if buffAbilityId == abilityId then
            return stackCount
        end
    end

    return nil
end

local function GetMissingBuffRequiredStacks(tracker)
    local requiredStacks = tonumber(tracker and tracker.minStacksToShow) or 1
    if requiredStacks < 1 then
        requiredStacks = 1
    end
    return requiredStacks
end

local function GetMissingBuffEffectiveStacks(stackCount)
    if type(stackCount) ~= "number" then
        return 0
    end
    if stackCount <= 0 then
        return 1
    end
    return stackCount
end

local function IsMissingBuffSatisfied(tracker, stackCount)
    return GetMissingBuffEffectiveStacks(stackCount) >= GetMissingBuffRequiredStacks(tracker)
end

local function ClearActiveEntry(trackerId)
    activeCooldowns[trackerId] = nil
end

local function EnsureMissingEntry(trackerId, tracker, stackCount)
    if not tracker or tracker.enabled ~= true then
        return
    end

    local icon = TrackingActions.GetIcon(tracker, nil)
    local entry = activeCooldowns[trackerId]
    local now = GetNow()
    if entry then
        entry.name = tracker.name
        entry.icon = icon
        entry.isCooldown = false
        entry.isPermanent = true
        entry.effectEndSnapshot = nil
        entry.effectStackCount = type(stackCount) == "number" and stackCount or nil
        entry.endTime = now + PERMANENT_DURATION_SECONDS
        entry.remaining = PERMANENT_DURATION_SECONDS
        entry.maxDuration = PERMANENT_DURATION_SECONDS
        return
    end

    activeCooldowns[trackerId] = {
        id = trackerId,
        name = tracker.name,
        icon = icon,
        remaining = PERMANENT_DURATION_SECONDS,
        maxDuration = PERMANENT_DURATION_SECONDS,
        endTime = now + PERMANENT_DURATION_SECONDS,
        effectEndSnapshot = nil,
        effectStackCount = type(stackCount) == "number" and stackCount or nil,
        isCooldown = false,
        isPermanent = true,
    }
end

local function BuildPlayerBuffStackMap()
    local stacksByAbilityId = {}
    if not GetNumBuffs or not GetUnitBuffInfo then
        return stacksByAbilityId
    end

    local numBuffs = GetNumBuffs("player")
    if not numBuffs or numBuffs <= 0 then
        return stacksByAbilityId
    end

    for i = 1, numBuffs do
        local _, _, _, _, stackCount, _, _, _, _, _, buffAbilityId = GetUnitBuffInfo("player", i)
        if type(buffAbilityId) == "number" and buffAbilityId > 0 then
            local prev = stacksByAbilityId[buffAbilityId]
            local nextStacks = type(stackCount) == "number" and stackCount or 0
            if prev == nil or nextStacks > prev then
                stacksByAbilityId[buffAbilityId] = nextStacks
            end
        end
    end

    return stacksByAbilityId
end

--- Ensure entries exist for all enabled missing-buff trackers.
--- Missing-buff mode: cooldownSeconds == -1 → show icon while buff is missing (or below required stacks).
function TrackingActions.SyncMissingBuffTrackers()
    local stacksByAbilityId = BuildPlayerBuffStackMap()
    for trackerId, tracker in pairs(trackerDefinitions) do
        local cooldownSeconds = tonumber(tracker and tracker.cooldownSeconds) or 0
        if cooldownSeconds == -1 then
            if not tracker or tracker.enabled ~= true then
                ClearActiveEntry(trackerId)
            else
                local abilityId = tracker.abilityId
                local stacks = type(abilityId) == "number" and stacksByAbilityId[abilityId] or nil
                if IsMissingBuffSatisfied(tracker, stacks) then
                    ClearActiveEntry(trackerId)
                else
                    EnsureMissingEntry(trackerId, tracker, stacks)
                end
            end
        end
    end
end

--- Handle combat event.
local function OnCombatEvent(eventId, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
                             sourceName, sourceType, targetName, targetType, hitValue, powerType,
                             damageType, log, sourceUnitId, targetUnitId, abilityId)
    if isError == true then
        return
    end
    -- Only track player-sourced events
    if not IsPlayerCombatSource(sourceName, sourceType) then
        return
    end

    if type(abilityId) ~= "number" or abilityId <= 0 then
        return
    end

    local trackerId = tostring(abilityId)
    local tracker = trackerDefinitions[trackerId]
    if not tracker and trackingState.hasNonStandardTrackerIds == true then
        for id, t in pairs(trackerDefinitions) do
            if t and t.enabled and t.useCombatEvent and t.abilityId == abilityId then
                trackerId = id
                tracker = t
                break
            end
        end
    end
    if not tracker or tracker.enabled ~= true or tracker.useCombatEvent ~= true or tracker.abilityId ~= abilityId then
        return
    end

    local discoveryActive = trackingState.discoveryActive == true
    local formattedName = nil
    local eventIcon = nil
    local procIcon = nil
    if discoveryActive then
        formattedName = zo_strformat("<<t:1>>", abilityName)
        eventIcon = NormalizeEventIcon(abilityGraphic)
        procIcon = ResolveCombatIcon(abilityId, formattedName, eventIcon)
    end

    local stackChecked = false
    local stackCount = nil

    if MatchesCombatResult(tracker, result) then
        if not stackChecked then
            stackChecked = true
            stackCount = FindPlayerBuffStack(abilityId)
        end
        MaybeMarkTrackerStackable(tracker, stackCount)
        TrackingActions.StartCooldown(trackerId, nil)
        local entry = activeCooldowns[trackerId]
        if entry then
            entry.effectStackCount = type(stackCount) == "number" and stackCount or nil
        end
        if discoveryActive then
            ---@cast formattedName string
            ---@cast procIcon string
            TrackingActions.RecordRecentProc(abilityId, formattedName, procIcon, "combat", result, eventIcon)
        end
    end
end

--- Extend an active cooldown entry based on an effect update's reported endTime.
--- This is used for stacking/refreshing effects where EVENT_EFFECT_CHANGED reports a later endTime
--- via EFFECT_RESULT_UPDATED, and we want our timer to follow the game's timer extension.
---@param trackerId string
---@param tracker TrackerDefinition
---@param effectEndTime number
---@param stackCount number|nil
---@param eventIcon string|nil
local function ExtendActiveCooldownFromEffectEndTime(trackerId, tracker, effectEndTime, stackCount, eventIcon)
    local entry = activeCooldowns[trackerId]
    if not entry then
        return
    end

    MaybeMarkTrackerStackable(tracker, stackCount)

    if type(effectEndTime) ~= "number" or effectEndTime <= 0 then
        return
    end

    -- Tiny tolerance to avoid flapping on float precision/latency jitter.
    local TOLERANCE_SECONDS = EFFECT_UPDATE_TOLERANCE

    -- Only treat a cooldown as "effect-aligned" when the ends are extremely close.
    -- This avoids effect durations overriding user-configured cooldownSeconds.
    local rawCooldownSeconds = tonumber(tracker.cooldownSeconds) or 0
    local ALIGNMENT_SECONDS = 1.0
    if rawCooldownSeconds > 0 then
        ALIGNMENT_SECONDS = math.min(0.35, math.max(0.05, rawCooldownSeconds * 0.15))
    end

    local prevEffectEnd = entry.effectEndSnapshot
    local prevStacks = entry.effectStackCount

    -- Always store the latest effect snapshot for future delta calculations.
    entry.effectEndSnapshot = effectEndTime
    if type(stackCount) == "number" then
        entry.effectStackCount = stackCount
    end

    -- First snapshot: if this timer is meant to track the effect itself, snap up to the effect end time.
    if type(prevEffectEnd) ~= "number" or prevEffectEnd <= 0 then
        local currentTimerEnd = entry.endTime or 0
        local isEffectAligned = math.abs(currentTimerEnd - effectEndTime) <= ALIGNMENT_SECONDS
        if isEffectAligned and effectEndTime > currentTimerEnd + TOLERANCE_SECONDS then
            entry.endTime = effectEndTime
        end
    else
        local delta = effectEndTime - prevEffectEnd
        if delta <= TOLERANCE_SECONDS then
            return
        end

        local currentTimerEnd = entry.endTime or 0
        local isEffectAligned = math.abs(currentTimerEnd - prevEffectEnd) <= ALIGNMENT_SECONDS

        if isEffectAligned then
            -- Timer is tracking the effect: follow effect end directly.
            if effectEndTime > currentTimerEnd + TOLERANCE_SECONDS then
                entry.endTime = effectEndTime
            end
        else
            -- Timer is tracking a longer cooldown; only shift it when the effect is clearly refreshing/extending.
            -- For Mechanical Acuity-style stacks, stack count changes while endTime moves later.
            local stacksChanged = type(stackCount) == "number"
                and (type(prevStacks) ~= "number" or stackCount ~= prevStacks)
            if not stacksChanged then
                return
            end
            entry.endTime = currentTimerEnd + delta
        end
    end

    entry.name = tracker.name
    entry.icon = TrackingActions.GetIcon(tracker, eventIcon)

    -- Keep fields internally consistent (even though remaining is recomputed at render time).
    local now = GetNow()
    local remaining = (entry.endTime or 0) - now
    if remaining > 0 then
        entry.remaining = remaining
        if not entry.maxDuration or remaining > entry.maxDuration then
            entry.maxDuration = remaining
        end
    end
end

--- Handle effect changed event.
local function OnEffectChanged(eventId, changeType, effectSlot, effectName, unitTag,
                               beginTime, endTime, stackCount, iconName, deprecatedBuffType,
                               effectType, abilityType, statusEffectType, unitName, unitId,
                               abilityId, sourceType)
    -- For discovery, include UPDATED as well (some effects only surface that way).
    -- For effect-style trackers (cooldownSeconds == 0 or -2), also handle FADED.
    -- For missing-buff trackers (cooldownSeconds == -1), invert: show while missing.
    local isTriggerChange = changeType == EFFECT_RESULT_GAINED
        or changeType == EFFECT_RESULT_FULL_REFRESH
        or changeType == EFFECT_RESULT_TRANSFER
    local isFadeChange = changeType == EFFECT_RESULT_FADED
    local isDiscoveryChange = isTriggerChange or changeType == EFFECT_RESULT_UPDATED or isFadeChange

    if not isDiscoveryChange then
        return
    end

    -- Missing-buff mode: update even when the effect source isn't the player.
    if unitTag == "player" and type(abilityId) == "number" and abilityId > 0 then
        local trackerId = tostring(abilityId)
        local tracker = trackerDefinitions[trackerId]
        if (not tracker or tracker.enabled ~= true or tracker.abilityId ~= abilityId) and trackingState.hasNonStandardTrackerIds == true then
            for id, t in pairs(trackerDefinitions) do
                if t and t.enabled and t.abilityId == abilityId then
                    trackerId = id
                    tracker = t
                    break
                end
            end
        end

        if tracker and tracker.enabled == true and TrackerMatchesEventAbilityId(tracker, abilityId) then
            local cooldownSeconds = tonumber(tracker.cooldownSeconds) or 0
            if cooldownSeconds == -1 then
                ---@cast trackerId string
                if isFadeChange then
                    EnsureMissingEntry(trackerId, tracker, nil)
                else
                    if IsMissingBuffSatisfied(tracker, stackCount) then
                        ClearActiveEntry(trackerId)
                    else
                        EnsureMissingEntry(trackerId, tracker, stackCount)
                    end
                end
                return
            end
        end
    end

    local isPlayerSource = sourceType == COMBAT_UNIT_TYPE_PLAYER
        or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET
        or sourceType == COMBAT_UNIT_TYPE_PLAYER_COMPANION

    -- Only track player-sourced effects to avoid other players' procs.
    if not isPlayerSource then
        return
    end

    local discoveryActive = trackingState.discoveryActive == true

    local trackerId = type(abilityId) == "number" and tostring(abilityId) or nil
    local tracker = trackerId and trackerDefinitions[trackerId] or nil
    if (not tracker or tracker.enabled ~= true or tracker.abilityId ~= abilityId) and trackingState.hasNonStandardTrackerIds == true then
        for id, t in pairs(trackerDefinitions) do
            if t and t.enabled and t.abilityId == abilityId then
                trackerId = id
                tracker = t
                break
            end
        end
    end

    -- If discovery is off and we have no tracker for this ability, bail out early.
    if not discoveryActive and not tracker then
        return
    end

    local formattedEffectName = nil
    local eventIcon = nil
    local effectIcon = nil
    local function EnsureDiscoveryFields()
        if formattedEffectName then
            return
        end
        formattedEffectName = zo_strformat("<<t:1>>", effectName)
        eventIcon = NormalizeEventIcon(iconName)
        effectIcon = ResolveCombatIcon(abilityId, formattedEffectName, eventIcon)
    end

    -- Find matching tracker (tracked timers and/or extensions)
    if tracker and tracker.enabled and TrackerMatchesEventAbilityId(tracker, abilityId) then
        ---@cast trackerId string
        local cooldownSeconds = tonumber(tracker.cooldownSeconds) or 0
        if isFadeChange and cooldownSeconds > 0 then
            local entry = activeCooldowns[trackerId]
            if entry then
                entry.effectStackCount = nil
                entry.effectEndSnapshot = nil
            end
        else
            -- For combat-event cooldown trackers, don't start timers from EFFECT_CHANGED to avoid double-procs,
            -- but do allow EFFECT_RESULT_UPDATED to extend/shift the active timer when the effect extends.
            if tracker.useCombatEvent and cooldownSeconds > 0 then
                if changeType == EFFECT_RESULT_UPDATED then
                    ExtendActiveCooldownFromEffectEndTime(trackerId, tracker, endTime, stackCount, iconName)
                end
            elseif cooldownSeconds == 0 or cooldownSeconds == -2 then
                -- Effect-style tracker: 0 means permanent after trigger; -2 follows effect timing.
                if isFadeChange then
                    if cooldownSeconds < 0 then
                        TrackingActions.StopActiveEntry(trackerId)
                    else
                        local entry = activeCooldowns[trackerId]
                        if entry then
                            entry.effectStackCount = nil
                        end
                    end
                    return
                end

                TrackingActions.StartOrUpdateEffect(trackerId, nil, beginTime, endTime, stackCount)
                if discoveryActive then
                    EnsureDiscoveryFields()
                    ---@cast formattedEffectName string
                    ---@cast effectIcon string
                    TrackingActions.RecordRecentProc(abilityId, formattedEffectName, effectIcon, "effect", nil, eventIcon)
                end
                return
            elseif changeType == EFFECT_RESULT_UPDATED then
                local entry = activeCooldowns[trackerId]
                local prevEffectEnd = entry and entry.effectEndSnapshot or 0
                local prevStacks = entry and entry.effectStackCount
                local endExtended = type(endTime) == "number"
                    and endTime > (prevEffectEnd or 0) + EFFECT_UPDATE_TOLERANCE
                local stacksChanged = type(stackCount) == "number"
                    and (type(prevStacks) ~= "number" or stackCount ~= prevStacks)

                if not entry or endExtended or stacksChanged then
                    TrackingActions.StartCooldown(trackerId, nil)
                    ExtendActiveCooldownFromEffectEndTime(trackerId, tracker, endTime, stackCount, nil)
                    if discoveryActive then
                        EnsureDiscoveryFields()
                        ---@cast formattedEffectName string
                        ---@cast effectIcon string
                        TrackingActions.RecordRecentProc(abilityId, formattedEffectName, effectIcon, "effect", nil,
                            eventIcon)
                    end
                    return
                end

                -- If nothing material changed, just keep the timer aligned.
                ExtendActiveCooldownFromEffectEndTime(trackerId, tracker, endTime, stackCount, nil)
            elseif isTriggerChange then
                -- iconName comes directly from the event - this is the most accurate icon.
                TrackingActions.StartCooldown(trackerId, nil)
                -- Record the effect timing snapshot (and optionally snap/shift) immediately after starting.
                ExtendActiveCooldownFromEffectEndTime(trackerId, tracker, endTime, stackCount, nil)

                -- Record as recent proc (from effect changed)
                if discoveryActive then
                    EnsureDiscoveryFields()
                    ---@cast formattedEffectName string
                    ---@cast effectIcon string
                    TrackingActions.RecordRecentProc(abilityId, formattedEffectName, effectIcon, "effect", nil, eventIcon)
                end
                return
            end
        end
    end

    -- Also record any player effect as a recent proc (for discovery)
    if discoveryActive and not isFadeChange then
        EnsureDiscoveryFields()
        ---@cast formattedEffectName string
        ---@cast effectIcon string
        TrackingActions.RecordRecentProc(abilityId, formattedEffectName, effectIcon, "effect", nil, eventIcon)
    end
end

--- Unregister all events.
function TrackingActions.UnregisterAllEvents()
    for eventName, _ in pairs(registeredEvents) do
        EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_EFFECT_CHANGED)
    end
    ZO_ClearTable(registeredEvents)
end

--- Refresh event registrations based on current trackers.
function TrackingActions.RefreshEventRegistrations()
    TrackingActions.UnregisterAllEvents()

    local needsCombatEvent = false
    local needsEffectChanged = trackingState.discoveryActive == true
    local combatAbilityIds = {}
    local combatResultFiltersByAbilityId = {}
    local hasNonStandardTrackerIds = false

    for trackerId, tracker in pairs(trackerDefinitions) do
        if tracker.enabled and tracker.abilityId then
            if trackerId ~= tostring(tracker.abilityId) then
                hasNonStandardTrackerIds = true
            end
            if tracker.useCombatEvent then
                needsCombatEvent = true
                combatAbilityIds[tracker.abilityId] = true

                local results = combatResultFiltersByAbilityId[tracker.abilityId]
                if not results then
                    results = {}
                    combatResultFiltersByAbilityId[tracker.abilityId] = results
                end

                if type(tracker.initialHitResult) == "number" then
                    if tracker.initialHitResult == ACTION_RESULT_DOT_TICK
                        or tracker.initialHitResult == ACTION_RESULT_DOT_TICK_CRITICAL
                    then
                        results[ACTION_RESULT_DOT_TICK] = true
                        results[ACTION_RESULT_DOT_TICK_CRITICAL] = true
                    else
                        results[tracker.initialHitResult] = true
                    end
                else
                    for resultCode in pairs(VALID_COMBAT_RESULTS) do
                        results[resultCode] = true
                    end
                end
            else
                needsEffectChanged = true
            end
        end
    end

    trackingState.hasNonStandardTrackerIds = hasNonStandardTrackerIds

    -- Register combat events with ability ID filters
    if needsCombatEvent then
        for abilityId, _ in pairs(combatAbilityIds) do
            local eventName = string.format("CooldownTracker_CE_%d", abilityId)
            EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, OnCombatEvent)
            EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
            EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)

            local results = combatResultFiltersByAbilityId[abilityId]
            if results then
                for resultCode in pairs(results) do
                    EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT,
                        resultCode)
                end
            end
            registeredEvents[eventName] = true
        end
    end

    -- Register effect changed (single global handler)
    if needsEffectChanged then
        local eventName = "CooldownTracker_EffectChanged"
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, OnEffectChanged)
        registeredEvents[eventName] = true
    end
end

--- Create trackers from equipped sets that have known cooldowns.
---@param cooldownData table<number, { s1: number, s2: number, CD: number, cdE: number, iH: number|nil, altName: string|nil, altIcon: string|nil }>|nil
function TrackingActions.CreateTrackersFromEquippedSets(cooldownData)
    if not cooldownData then
        return
    end

    for abilityId, cdData in pairs(cooldownData) do
        local s1, s2 = cdData.s1, cdData.s2
        local setId = nil

        if s1 and s1 > 0 and TrackingActions.IsSetEquipped(s1) then
            setId = s1
        elseif s2 and s2 > 0 and TrackingActions.IsSetEquipped(s2) then
            setId = s2
        end

        if setId then
            local setData = equippedSets[setId]
            local trackerId = tostring(abilityId)

            -- Don't overwrite user-configured trackers
            if not trackerDefinitions[trackerId] then
                local name = cdData.altName
                if not name or name == "" then
                    name = setData and setData.name or zo_strformat("<<t:1>>", GetItemSetName(setId))
                end

                TrackingActions.SetTracker({
                    id = trackerId,
                    abilityId = abilityId,
                    setId = setId,
                    name = name,
                    cooldownSeconds = cdData.CD or 0,
                    enabled = true,
                    iconMode = TrackingActions.ICON_MODE.AUTO,
                    customIcon = nil,
                    useCombatEvent = cdData.cdE == 1,
                    initialHitResult = cdData.iH,
                })
            end
        end
    end
end

return TrackingActions
