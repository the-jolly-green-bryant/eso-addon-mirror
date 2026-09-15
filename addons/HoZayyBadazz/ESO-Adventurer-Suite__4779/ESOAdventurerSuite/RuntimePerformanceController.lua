-- ESO Adventurer Suite
-- v0.29.630 - unified runtime performance controller.
-- Consolidates the old HUD/trial runtime guards into one ownership layer.
-- Dense 8+ player combat removes nonessential event traffic and world/UI work
-- before it reaches expensive Suite paths. Normal gameplay keeps full features.
-- No permanent frame OnUpdate loop is introduced.

local EPC = ESOProgressionCoach
if not EPC or not EVENT_MANAGER then return end

EPC.RuntimePerformanceController = EPC.RuntimePerformanceController or {}
local P = EPC.RuntimePerformanceController
local EM = EVENT_MANAGER
local PREFIX = (EPC.name or "ESOAdventurerSuite") .. "_RuntimePerf029630"
local TEAM_PREFIX = (EPC.name or "EAS") .. "_TeamVisibility"
local RESOURCE_PREFIX = (EPC.name or "ESOAdventurerSuite") .. "_ResourcePins"
local TICK_DRAW_NAME = PREFIX .. "_TickTrackerDraw"

local STATE = {
    groupSize = 0,
    inCombat = false,
    hard = false,
    teamWasHidden = nil,
    resourceWasHidden = nil,
}

local function nowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        local ok, value = pcall(GetFrameTimeMilliseconds)
        if ok then return tonumber(value) or 0 end
    end
    if type(GetGameTimeMilliseconds) == "function" then
        local ok, value = pcall(GetGameTimeMilliseconds)
        if ok then return tonumber(value) or 0 end
    end
    return 0
end

local function readGroupSize()
    if type(GetGroupSize) == "function" then
        local ok, value = pcall(GetGroupSize)
        STATE.groupSize = ok and math.max(0, tonumber(value) or 0) or 0
    else
        STATE.groupSize = 0
    end
end

local function readCombatState()
    if type(IsUnitInCombat) == "function" then
        local ok, value = pcall(IsUnitInCombat, "player")
        STATE.inCombat = ok and value == true
    else
        STATE.inCombat = false
    end
end

local function hardMode()
    return STATE.hard == true
end

function P:IsHardTrialMode()
    return hardMode()
end

function EPC:IsHardTrialPerformanceMode029630()
    return hardMode()
end

local function compactResults(...)
    local out = {}
    for i = 1, select("#", ...) do
        local value = select(i, ...)
        if value ~= nil then out[#out + 1] = value end
    end
    return out
end

local DAMAGE_RESULTS = compactResults(
    rawget(_G, "ACTION_RESULT_DAMAGE"),
    rawget(_G, "ACTION_RESULT_CRITICAL_DAMAGE"),
    rawget(_G, "ACTION_RESULT_DOT_TICK"),
    rawget(_G, "ACTION_RESULT_DOT_TICK_CRITICAL"),
    rawget(_G, "ACTION_RESULT_DAMAGE_SHIELDED")
)

local HEAL_RESULTS = compactResults(
    rawget(_G, "ACTION_RESULT_HEAL"),
    rawget(_G, "ACTION_RESULT_CRITICAL_HEAL"),
    rawget(_G, "ACTION_RESULT_HOT_TICK"),
    rawget(_G, "ACTION_RESULT_HOT_TICK_CRITICAL")
)

local function coreGroupRegistration(kind, result)
    return string.format("%s_Combat_%s_Group_%s",
        EPC.name or "ESOAdventurerSuite", kind, tostring(result))
end

local function groupCombatCallback(kind)
    return function(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
        sourceName, sourceType, targetName, targetType, hitValue, powerType,
        damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
        local combat = EPC.Combat
        if combat and type(combat.OnCombatEvent) == "function" then
            combat:OnCombatEvent(kind, result, abilityName, sourceName, sourceType,
                targetName, targetType, hitValue, abilityId, sourceUnitId)
        end
    end
end

local GROUP_DAMAGE_CALLBACK = groupCombatCallback("DAMAGE")
local GROUP_HEAL_CALLBACK = groupCombatCallback("HEAL")

local function unregisterGroupCombatStreams()
    if EVENT_COMBAT_EVENT == nil then return end
    for _, result in ipairs(DAMAGE_RESULTS) do
        EM:UnregisterForEvent(coreGroupRegistration("DAMAGE", result), EVENT_COMBAT_EVENT)
    end
    for _, result in ipairs(HEAL_RESULTS) do
        EM:UnregisterForEvent(coreGroupRegistration("HEAL", result), EVENT_COMBAT_EVENT)
    end
end

local function restoreOneGroupStream(kind, result, callback)
    if EVENT_COMBAT_EVENT == nil or result == nil then return end
    if REGISTER_FILTER_COMBAT_RESULT == nil
        or REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE == nil
        or COMBAT_UNIT_TYPE_GROUP == nil then
        return
    end

    local name = coreGroupRegistration(kind, result)
    EM:UnregisterForEvent(name, EVENT_COMBAT_EVENT)
    EM:RegisterForEvent(name, EVENT_COMBAT_EVENT, callback)
    EM:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, result)
    if REGISTER_FILTER_IS_ERROR ~= nil then
        EM:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)
    end
    EM:AddFilterForEvent(name, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_GROUP)
end

local function restoreGroupCombatStreams()
    for _, result in ipairs(DAMAGE_RESULTS) do
        restoreOneGroupStream("DAMAGE", result, GROUP_DAMAGE_CALLBACK)
    end
    for _, result in ipairs(HEAL_RESULTS) do
        restoreOneGroupStream("HEAL", result, GROUP_HEAL_CALLBACK)
    end
end

local BOSS_BEGIN_NAME = (EPC.name or "ESOAdventurerSuite") .. "_BossMechanics029198_Begin"

local function bossBeginCallback(_, result, isError, abilityName, abilityGraphic,
    abilityActionSlotType, sourceName, sourceType, targetName, targetType,
    hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    local mechanics = EPC.BossMechanicsAssistant
    if mechanics and type(mechanics.OnBeginEvent) == "function" then
        mechanics:OnBeginEvent(abilityName, abilityActionSlotType, sourceName, targetName, abilityId)
    end
end

local function configureBossBegin(targetPlayerOnly)
    local M = EPC.BossMechanicsAssistant
    if EVENT_COMBAT_EVENT == nil
        or ACTION_RESULT_BEGIN == nil
        or REGISTER_FILTER_COMBAT_RESULT == nil
        or not M
        or type(M.OnBeginEvent) ~= "function" then
        return
    end

    EM:UnregisterForEvent(BOSS_BEGIN_NAME, EVENT_COMBAT_EVENT)
    EM:RegisterForEvent(BOSS_BEGIN_NAME, EVENT_COMBAT_EVENT, bossBeginCallback)
    EM:AddFilterForEvent(BOSS_BEGIN_NAME, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    if REGISTER_FILTER_IS_ERROR ~= nil then
        EM:AddFilterForEvent(BOSS_BEGIN_NAME, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)
    end
    if targetPlayerOnly
        and REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE ~= nil
        and COMBAT_UNIT_TYPE_PLAYER ~= nil then
        EM:AddFilterForEvent(BOSS_BEGIN_NAME, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    end
end

local function isHidden(control)
    if not control or type(control.IsHidden) ~= "function" then return nil end
    local ok, value = pcall(control.IsHidden, control)
    if not ok then return nil end
    return value == true
end

local function delayed(callback, delay)
    if type(callback) ~= "function" then return end
    if type(zo_callLater) == "function" then
        zo_callLater(callback, tonumber(delay) or 0)
    else
        callback()
    end
end

local function pauseTeamVisibility()
    local T = EPC.TeamVisibility
    EM:UnregisterForUpdate(TEAM_PREFIX .. "_Follow")
    EM:UnregisterForUpdate(TEAM_PREFIX .. "_Particles")
    if not T then return end

    if T.particleWindow then
        if STATE.teamWasHidden == nil then STATE.teamWasHidden = isHidden(T.particleWindow) end
        if type(T.particleWindow.SetHidden) == "function" then
            pcall(T.particleWindow.SetHidden, T.particleWindow, true)
        end
    end
    if type(T.HideAllParticles) == "function" then pcall(T.HideAllParticles, T) end
end

local function resumeTeamVisibility()
    local T = EPC.TeamVisibility
    if not T then return end

    EM:UnregisterForUpdate(TEAM_PREFIX .. "_Follow")
    EM:UnregisterForUpdate(TEAM_PREFIX .. "_Particles")

    EM:RegisterForUpdate(TEAM_PREFIX .. "_Follow", 33, function()
        local current = EPC.TeamVisibility
        if not current or hardMode() or type(current.FollowVisibleParticles) ~= "function" then return end
        current:FollowVisibleParticles()
    end)

    EM:RegisterForUpdate(TEAM_PREFIX .. "_Particles", 500, function()
        local current = EPC.TeamVisibility
        if not current or hardMode() or type(current.RefreshParticles) ~= "function" then return end
        current:RefreshParticles()
    end)

    delayed(function()
        if hardMode() then return end
        local current = EPC.TeamVisibility
        if not current then return end
        if current.particleWindow and type(current.particleWindow.SetHidden) == "function" then
            local shouldHide = STATE.teamWasHidden == true
                or (EPC.saved and EPC.saved.teamVisibilityEnabled == false)
            pcall(current.particleWindow.SetHidden, current.particleWindow, shouldHide)
        end
        STATE.teamWasHidden = nil
        if not (EPC.saved and EPC.saved.teamVisibilityEnabled == false)
            and type(current.RefreshParticles) == "function" then
            pcall(current.RefreshParticles, current)
        end
    end, 250)
end

local function pauseResourcePins()
    local R = EPC.ResourcePins
    EM:UnregisterForUpdate(RESOURCE_PREFIX .. "_Interact")
    EM:UnregisterForUpdate(RESOURCE_PREFIX .. "_Render")
    if not R or not R.window then return end
    if STATE.resourceWasHidden == nil then STATE.resourceWasHidden = isHidden(R.window) end
    if type(R.window.SetHidden) == "function" then pcall(R.window.SetHidden, R.window, true) end
end

local function resumeResourcePins()
    local R = EPC.ResourcePins
    if not R then return end

    EM:UnregisterForUpdate(RESOURCE_PREFIX .. "_Interact")
    EM:UnregisterForUpdate(RESOURCE_PREFIX .. "_Render")

    if type(R.CaptureResourceInteraction) == "function" then
        EM:RegisterForUpdate(RESOURCE_PREFIX .. "_Interact", 900, function()
            local current = EPC.ResourcePins
            if current and not hardMode() and type(current.CaptureResourceInteraction) == "function" then
                current:CaptureResourceInteraction()
            end
        end)
    end

    if type(R.MovementAwareRefreshMarkers029312) == "function" then
        EM:RegisterForUpdate(RESOURCE_PREFIX .. "_Render", 900, function()
            local current = EPC.ResourcePins
            if current and not hardMode()
                and type(current.MovementAwareRefreshMarkers029312) == "function" then
                current:MovementAwareRefreshMarkers029312()
            end
        end)
    end

    delayed(function()
        if hardMode() then return end
        local current = EPC.ResourcePins
        if not current then return end
        if current.window and type(current.window.SetHidden) == "function" then
            local shouldHide = STATE.resourceWasHidden == true
                or not EPC.saved
                or EPC.saved.resourcePinsEnabled == false
                or EPC.saved.resourcePinsShow3D == false
            pcall(current.window.SetHidden, current.window, shouldHide)
        end
        STATE.resourceWasHidden = nil
        if EPC.saved and EPC.saved.resourcePinsEnabled ~= false
            and type(current.RefreshMarkers) == "function" then
            pcall(current.RefreshMarkers, current)
        end
    end, 300)
end

local function enterHardMode()
    if STATE.hard then return end
    STATE.hard = true
    EPC.trialHardPerformanceMode029630 = true
    EPC.trialHardPerformanceMode029625 = true

    unregisterGroupCombatStreams()
    configureBossBegin(true)
    pauseTeamVisibility()
    pauseResourcePins()
end

local function exitHardMode()
    if not STATE.hard then return end
    STATE.hard = false
    EPC.trialHardPerformanceMode029630 = false
    EPC.trialHardPerformanceMode029625 = false

    restoreGroupCombatStreams()
    configureBossBegin(false)
    resumeTeamVisibility()
    resumeResourcePins()

    delayed(function()
        if hardMode() then return end
        local F = EPC.UnitFrames
        if F and type(F.RefreshGroupFrames) == "function" then pcall(F.RefreshGroupFrames, F) end
        local M = EPC.MiniMap
        if M then
            if type(M.SyncToPlayerMap) == "function" then pcall(M.SyncToPlayerMap, M, true) end
            if type(M.RefreshStaticPins) == "function" then pcall(M.RefreshStaticPins, M) end
        end
    end, 350)
end

local function applyState()
    local shouldHard = STATE.inCombat == true and STATE.groupSize >= 8
    if shouldHard then enterHardMode() else exitHardMode() end
end

local function refreshState()
    readGroupSize()
    readCombatState()
    applyState()
end

local function wrapThrottle(object, methodName, key, hardGap, normalGapResolver)
    if type(object) ~= "table" or type(object[methodName]) ~= "function" then return end
    local marker = "_easUnifiedPerf_" .. key
    if object[marker] then return end
    object[marker] = true

    local base = object[methodName]
    local lastKey = marker .. "_last"
    object[methodName] = function(self, ...)
        local stamp = nowMs()
        local gap = 0
        if hardMode() then
            gap = tonumber(hardGap) or 0
        elseif type(normalGapResolver) == "function" then
            gap = tonumber(normalGapResolver()) or 0
        end

        if gap > 0 and stamp > 0 then
            local last = tonumber(self and self[lastKey]) or -100000
            if (stamp - last) < gap then return end
            if self then self[lastKey] = stamp end
        end
        return base(self, ...)
    end
end

local function wrapHardNoOp(object, methodName, key)
    if type(object) ~= "table" or type(object[methodName]) ~= "function" then return end
    local marker = "_easUnifiedPerf_" .. key
    if object[marker] then return end
    object[marker] = true
    local base = object[methodName]
    object[methodName] = function(self, ...)
        if hardMode() then return end
        return base(self, ...)
    end
end

local function wrapHardSuccess(object, methodName, key)
    if type(object) ~= "table" or type(object[methodName]) ~= "function" then return end
    local marker = "_easUnifiedPerf_" .. key
    if object[marker] then return end
    object[marker] = true
    local base = object[methodName]
    object[methodName] = function(self, ...)
        if hardMode() then return true end
        return base(self, ...)
    end
end

local F = EPC.UnitFrames
wrapThrottle(F, "RefreshGroupFrames", "GroupFrames", 100000, function()
    if STATE.groupSize >= 8 then return STATE.inCombat and 300 or 220 end
    if STATE.inCombat then return 180 end
    if STATE.groupSize >= 4 then return 130 end
    return 90
end)
wrapThrottle(F, "RefreshPlayerAuras", "PlayerAuras", 250)
wrapThrottle(F, "RefreshTargetAuras", "TargetAuras", 300)

if type(EPC.RefreshResponsiveOverlays029343) == "function"
    and not EPC._easUnifiedResponsive029630 then
    EPC._easUnifiedResponsive029630 = true
    local baseResponsive = EPC.RefreshResponsiveOverlays029343
    EPC.RefreshResponsiveOverlays029343 = function(self, ...)
        if hardMode() then return end
        local stamp = nowMs()
        local gap = STATE.inCombat and 120 or 75
        local last = tonumber(self._easUnifiedResponsiveAt029630) or -100000
        if stamp > 0 and (stamp - last) < gap then return end
        self._easUnifiedResponsiveAt029630 = stamp
        return baseResponsive(self, ...)
    end
end

local A = EPC.AbilityOverlays
wrapThrottle(A, "Refresh", "AbilityOverlays", 750)

local RA = EPC.RotationAssistant
wrapThrottle(RA, "Refresh", "RotationAssistant", 850)

local D = EPC.DualActionBar
wrapThrottle(D, "RefreshDynamic029311", "DualDynamic", 650)

local T = EPC.TeamVisibility
wrapThrottle(T, "RefreshParticles", "TeamRefresh", 100000, function()
    return STATE.groupSize >= 8 and 350 or 220
end)
wrapHardNoOp(T, "FollowVisibleParticles", "TeamFollow")
wrapHardNoOp(T, "ResetRenderSpaces", "TeamReset")

local RP = EPC.ResourcePins
wrapHardNoOp(RP, "CaptureResourceInteraction", "ResourceInteract")
wrapHardNoOp(RP, "MovementAwareRefreshMarkers029312", "ResourceRender")
wrapHardNoOp(RP, "RefreshMarkers", "ResourceRefresh")
wrapHardNoOp(RP, "RecoverWorldRenderer", "ResourceRecover")

local MM = EPC.MiniMap
wrapThrottle(MM, "UpdatePlayerMarkerFast", "MiniPlayer", 66)
wrapThrottle(MM, "UpdatePanAndPins", "MiniPanPins", 500)
wrapHardNoOp(MM, "RefreshStaticPins", "MiniStaticPins")
wrapHardNoOp(MM, "RebuildMap", "MiniRebuild")
wrapHardSuccess(MM, "TrySyncHiddenPlayerMap", "MiniHiddenSync")

local PERF = EPC.PerformanceOverlay
wrapThrottle(PERF, "UpdateValues", "PerformanceOverlay", 1000)

local TT = EPC.TickTracker
local function takeTickTrackerOwnership()
    local tracker = EPC.TickTracker
    if not tracker then return end
    if tracker.frame and type(tracker.frame.SetHandler) == "function" then
        pcall(tracker.frame.SetHandler, tracker.frame, "OnUpdate", nil)
    end
end

if type(TT) == "table" and type(TT.Create) == "function" and not TT._easUnifiedCreate029630 then
    TT._easUnifiedCreate029630 = true
    local baseCreate = TT.Create
    TT.Create = function(self, ...)
        local result = baseCreate(self, ...)
        takeTickTrackerOwnership()
        return result
    end
end

EM:UnregisterForUpdate(TICK_DRAW_NAME)
EM:RegisterForUpdate(TICK_DRAW_NAME, 50, function()
    local tracker = EPC.TickTracker
    if not tracker or not tracker.frame or type(tracker.RefreshText) ~= "function" then return end
    if type(tracker.frame.IsHidden) == "function" and tracker.frame:IsHidden() then return end

    local stamp = nowMs()
    local gap = hardMode() and 125 or 50
    local last = tonumber(tracker._easUnifiedDrawAt029630) or -100000
    if stamp > 0 and (stamp - last) < gap then return end
    tracker._easUnifiedDrawAt029630 = stamp
    tracker.lastDrawAt = stamp
    tracker:RefreshText()
end)

takeTickTrackerOwnership()
delayed(takeTickTrackerOwnership, 0)
delayed(takeTickTrackerOwnership, 500)

if EVENT_GROUP_UPDATE then
    EM:RegisterForEvent(PREFIX .. "_Group", EVENT_GROUP_UPDATE, function()
        readGroupSize()
        applyState()
    end)
end
if EVENT_GROUP_MEMBER_JOINED then
    EM:RegisterForEvent(PREFIX .. "_Join", EVENT_GROUP_MEMBER_JOINED, function()
        readGroupSize()
        applyState()
    end)
end
if EVENT_GROUP_MEMBER_LEFT then
    EM:RegisterForEvent(PREFIX .. "_Left", EVENT_GROUP_MEMBER_LEFT, function()
        readGroupSize()
        applyState()
    end)
end
if EVENT_PLAYER_ACTIVATED then
    EM:RegisterForEvent(PREFIX .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
        refreshState()
        delayed(takeTickTrackerOwnership, 50)
    end)
end
if EVENT_PLAYER_COMBAT_STATE then
    EM:RegisterForEvent(PREFIX .. "_Combat", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        STATE.inCombat = inCombat == true
        readGroupSize()
        applyState()
    end)
end

SLASH_COMMANDS = SLASH_COMMANDS or {}
SLASH_COMMANDS["/easperf"] = function()
    local mode = hardMode() and "HARD TRIAL" or "NORMAL"
    local text = string.format(
        "ESO Adventurer Suite Performance: %s | group=%d | combat=%s | Tick Tracker=%s",
        mode,
        tonumber(STATE.groupSize) or 0,
        STATE.inCombat and "yes" or "no",
        (EPC.TickTracker and EPC.TickTracker.frame) and "timer-owned" or "not-created")
    if type(d) == "function" then d(text) end
end

refreshState()
