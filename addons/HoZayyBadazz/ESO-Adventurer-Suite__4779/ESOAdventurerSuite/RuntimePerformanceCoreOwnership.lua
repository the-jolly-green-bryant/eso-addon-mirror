-- ESO Adventurer Suite
-- v0.29.639 - final runtime + weapon-swap hot-path ownership.
-- The final swap gate is installed after every Dual Action Bar compatibility,
-- proc, availability, cast and live-state wrapper. This makes it the outermost
-- gate: normal Primary/Backup swaps cannot enter any deep dynamic/static chain.

local EPC = ESOProgressionCoach
if not EPC or not EVENT_MANAGER then return end

local EM = EVENT_MANAGER
local NAME = (EPC.name or "ESOAdventurerSuite") .. "_RuntimeCorePerf029639"
local CORE_HUD_TIMER = (EPC.name or "ESOAdventurerSuite") .. "_CombatHUDPulse"
local MINI_TIMER = (EPC.name or "ESOAdventurerSuite") .. "_MiniMap_PlayerMarker"
local ABILITY_TIMER = (EPC.name or "ESOAdventurerSuite") .. "_AbilityOverlays_Tick"
local DUAL_TIMER = (EPC.name or "ESOAdventurerSuite") .. "_DualActionBar029189_Tick"
local ROTATION_TIMER = (EPC.name or "ESOAdventurerSuite") .. "_RotationAssistant_Tick"
local PERFORMANCE_TIMER = (EPC.name or "ESOAdventurerSuite") .. "_PerformanceOverlay_Pulse"
local TEAM_PREFIX = (EPC.name or "EAS") .. "_TeamVisibility"
local TEAM_FOLLOW_TIMER = TEAM_PREFIX .. "_Follow"
local TEAM_PARTICLE_TIMER = TEAM_PREFIX .. "_Particles"

local function nowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        return tonumber(GetFrameTimeMilliseconds()) or 0
    end
    if type(GetGameTimeMilliseconds) == "function" then
        return tonumber(GetGameTimeMilliseconds()) or 0
    end
    return 0
end

local function inCombat()
    if type(IsUnitInCombat) == "function" then
        local ok, value = pcall(IsUnitInCombat, "player")
        if ok then return value == true end
    end
    return EPC.Combat and EPC.Combat.inCombat == true or false
end

local function hardMode()
    if type(EPC.IsHardTrialPerformanceMode029630) == "function" then
        local ok, value = pcall(EPC.IsHardTrialPerformanceMode029630, EPC)
        if ok then return value == true end
    end
    return EPC.trialHardPerformanceMode029630 == true
end

local function weaponSwapHeavyBlocked()
    local stamp = nowMs()
    local untilMs = tonumber(EPC.weaponSwapBroadRefreshUntil029636)
        or tonumber(EPC.weaponSwapSettlingUntil029636)
        or tonumber(EPC.weaponSwapSettlingUntil029635)
        or 0
    return stamp > 0 and stamp < untilMs
end

local function activeHotbarCategory()
    if type(GetActiveHotbarCategory) ~= "function" then return nil end
    local ok, value = pcall(GetActiveHotbarCategory)
    return ok and value or nil
end

local function ordinaryWeaponSwapBlocked()
    if not weaponSwapHeavyBlocked() then return false end

    -- Special/transformed bars genuinely change their slot set and are allowed
    -- through the structural path. The hard gate is only for ordinary front/back.
    local D = EPC.DualActionBar
    local category = activeHotbarCategory()
    if D and type(D.IsSingleTransformedHotbar029554) == "function" then
        local ok, transformed = pcall(D.IsSingleTransformedHotbar029554, D, category)
        if ok and transformed == true then return false end
    end

    local primary = rawget(_G, "HOTBAR_CATEGORY_PRIMARY")
    local backup = rawget(_G, "HOTBAR_CATEGORY_BACKUP")
    if primary == nil then primary = 0 end
    if backup == nil then backup = 1 end
    return category == nil or category == primary or category == backup
end

local function due(owner, key, gapMs)
    if type(owner) ~= "table" then return true end
    local stamp = nowMs()
    local last = tonumber(owner[key]) or -100000
    if stamp > 0 and (stamp - last) < (tonumber(gapMs) or 0) then return false end
    owner[key] = stamp
    return true
end

local function bump(key)
    EPC.swapPerfCounters029639 = EPC.swapPerfCounters029639 or {}
    EPC.swapPerfCounters029639[key] = (tonumber(EPC.swapPerfCounters029639[key]) or 0) + 1
end

-- FINAL/OUTERMOST WEAPON-SWAP GATES -----------------------------------------
-- These wrappers are intentionally installed from this late-loaded file, after
-- AbilityAvailabilityFix, AbilityCastPerformanceFix and LiveAbilityStateFix.
-- The old guard in GlobalWeaponSwapPerformanceFix was buried inside later
-- wrappers, so those outer layers could still scan slots/effects before it ran.
local function installFinalSwapGates()
    local D = EPC.DualActionBar
    if D and type(D.RefreshDynamic029311) == "function" and not D._easFinalSwapDynamicGate029639 then
        D._easFinalSwapDynamicGate029639 = true
        local base = D.RefreshDynamic029311
        D.RefreshDynamic029311 = function(self, force, ...)
            if self.layoutMode ~= true and ordinaryWeaponSwapBlocked() then
                bump("dynamic")
                return nil
            end
            return base(self, force, ...)
        end
    end

    if D and type(D.RefreshStatic029311) == "function" and not D._easFinalSwapStaticGate029639 then
        D._easFinalSwapStaticGate029639 = true
        local base = D.RefreshStatic029311
        D.RefreshStatic029311 = function(self, ...)
            if self.layoutMode ~= true and ordinaryWeaponSwapBlocked() then
                bump("static")
                return nil
            end
            return base(self, ...)
        end
    end

    -- EVENT_EFFECT_CHANGED and stack/proc paths can call this with force=true.
    -- Previously force=true bypassed the swap guard and caused the full dynamic
    -- chain ~50 ms after every weapon swap. Drop the request entirely; the normal
    -- controlled timer reconciles the rendered state once ESO settles.
    if D and type(D.QueueDynamicRefresh029386) == "function" and not D._easFinalSwapQueueGate029639 then
        D._easFinalSwapQueueGate029639 = true
        local base = D.QueueDynamicRefresh029386
        D.QueueDynamicRefresh029386 = function(self, force, ...)
            if self.layoutMode ~= true and ordinaryWeaponSwapBlocked() then
                self.pendingDynamicRefreshForce029386 = false
                bump("queue")
                return nil
            end
            return base(self, force, ...)
        end
    end

    local A = EPC.AbilityOverlays
    if A and type(A.Refresh) == "function" and not A._easFinalSwapGate029639 then
        A._easFinalSwapGate029639 = true
        local base = A.Refresh
        A.Refresh = function(self, ...)
            if self.layoutMode ~= true and ordinaryWeaponSwapBlocked() then
                bump("ability")
                return nil
            end
            return base(self, ...)
        end
    end

    local R = EPC.RotationAssistant
    if R and type(R.Refresh) == "function" and not R._easFinalSwapGate029639 then
        R._easFinalSwapGate029639 = true
        local base = R.Refresh
        R.Refresh = function(self, ...)
            if self.layoutMode ~= true and ordinaryWeaponSwapBlocked() then
                bump("rotation")
                return nil
            end
            return base(self, ...)
        end
    end
end

-- RefreshNow builds a broad Engine snapshot that includes gear/set inspection.
-- That is useful for menus, not for a trial gameplay frame. Event requests stay
-- pending and are reconciled after hard mode ends.
if type(EPC.RefreshNow) == "function" and not EPC._easCoreRefreshPerf029634 then
    EPC._easCoreRefreshPerf029634 = true
    local baseRefreshNow = EPC.RefreshNow
    EPC.RefreshNow = function(self, reason, ...)
        if hardMode() and not self.unitFramesMoveMode and not self.combatHudMoveMode then
            self.refreshPending = true
            self.refreshReason = reason or self.refreshReason or "trial-deferred"
            return
        end
        return baseRefreshNow(self, reason, ...)
    end
end

local function ownCombatHudTimer()
    if not EPC.Combat or not EPC.UI or type(EPC.UI.UpdateCombatHUD) ~= "function" then return end

    EM:UnregisterForUpdate(CORE_HUD_TIMER)
    EM:RegisterForUpdate(CORE_HUD_TIMER, 250, function()
        if not EPC.Combat or not EPC.UI or not EPC.saved then return end
        local preview = EPC.combatHudMoveMode == true or EPC.unitFramesMoveMode == true
        if EPC.saved.showCombatHud == false and not preview then return end

        local gap
        if preview then gap = 100
        elseif hardMode() then gap = 750
        elseif EPC.Combat.inCombat then gap = 250
        else gap = 1000 end
        if not due(EPC, "_easCoreHudAt029634", gap) then return end

        local summary = nil
        if type(EPC.Combat.GetHUDSummary) == "function" then
            summary = EPC.Combat:GetHUDSummary()
        end
        EPC.UI:UpdateCombatHUD(summary)
    end)
end

local function ownMiniMapMarkerTimer()
    local M = EPC.MiniMap
    if not M or type(M.UpdatePlayerMarkerFast) ~= "function" then return end

    EM:UnregisterForUpdate(MINI_TIMER)
    EM:RegisterForUpdate(MINI_TIMER, 33, function()
        local mm = EPC.MiniMap
        if not mm or not mm.frame or not EPC.saved then return end
        if type(mm.frame.IsHidden) == "function" and mm.frame:IsHidden() then return end

        local gap = hardMode() and 66 or 33
        if not due(mm, "_easMarkerTimerAt029634", gap) then return end
        mm:UpdatePlayerMarkerFast(false, false)
    end)
end

local function ownAbilityOverlayTimer()
    local A = EPC.AbilityOverlays
    if not A or type(A.Refresh) ~= "function" then return end

    EM:UnregisterForUpdate(ABILITY_TIMER)
    EM:RegisterForUpdate(ABILITY_TIMER, 250, function()
        local current = EPC.AbilityOverlays
        if not current or not EPC.saved or EPC.saved.showAbilityOverlays == false then return end
        if current.layoutMode ~= true and ordinaryWeaponSwapBlocked() then return end
        local combat = inCombat()
        if current.layoutMode ~= true and not combat and not due(current, "_easTimerIdle029634", 1000) then return end
        if hardMode() and current.layoutMode ~= true and not due(current, "_easTimerHard029634", 750) then return end
        current:Refresh()
    end)
end

local function ownDualActionBarTimer()
    local D = EPC.DualActionBar
    if not D or type(D.RefreshDynamic029311) ~= "function" then return end

    EM:UnregisterForUpdate(DUAL_TIMER)
    EM:RegisterForUpdate(DUAL_TIMER, 250, function()
        local current = EPC.DualActionBar
        if not current or not EPC.saved or EPC.saved.showDualActionBar029189 ~= true then return end
        if current.layoutMode ~= true and ordinaryWeaponSwapBlocked() then return end

        local combat = inCombat()
        local gap = current.layoutMode == true and 250 or (hardMode() and 900 or (combat and 300 or 1000))
        if not due(current, "_easDynamicTimerAt029639", gap) then return end
        current:RefreshDynamic029311(false)
    end)
end

local function ownRotationTimer()
    local R = EPC.RotationAssistant
    if not R or type(R.Refresh) ~= "function" then return end

    EM:UnregisterForUpdate(ROTATION_TIMER)
    EM:RegisterForUpdate(ROTATION_TIMER, 350, function()
        local current = EPC.RotationAssistant
        if not current or not EPC.saved or EPC.saved.rotationAssistantEnabled == false then return end
        if current.layoutMode ~= true and ordinaryWeaponSwapBlocked() then return end
        if current.layoutMode ~= true and not inCombat() then return end
        local gap = hardMode() and 900 or 350
        if not due(current, "_easRotationTimerAt029634", gap) then return end
        current:Refresh()
    end)
end

local function ownTeamVisibilityTimers()
    EM:UnregisterForUpdate(TEAM_FOLLOW_TIMER)
    EM:UnregisterForUpdate(TEAM_PARTICLE_TIMER)
    if hardMode() then return end

    local T = EPC.TeamVisibility
    if not T then return end

    if type(T.FollowVisibleParticles) == "function" then
        EM:RegisterForUpdate(TEAM_FOLLOW_TIMER, 66, function()
            local current = EPC.TeamVisibility
            if not current or hardMode() or type(current.FollowVisibleParticles) ~= "function" then return end
            if type(current.IsEnabled) == "function" then
                local ok, enabled = pcall(current.IsEnabled, current)
                if ok and enabled == false then return end
            end
            current:FollowVisibleParticles()
        end)
    end

    if type(T.RefreshParticles) == "function" then
        EM:RegisterForUpdate(TEAM_PARTICLE_TIMER, 1200, function()
            local current = EPC.TeamVisibility
            if not current or hardMode() or type(current.RefreshParticles) ~= "function" then return end
            current:RefreshParticles()
        end)
    end
end

local function ownPerformanceOverlayTimer()
    local P = EPC.PerformanceOverlay
    if not P or type(P.UpdateValues) ~= "function" then return end

    EM:UnregisterForUpdate(PERFORMANCE_TIMER)
    EM:RegisterForUpdate(PERFORMANCE_TIMER, 1000, function()
        local current = EPC.PerformanceOverlay
        if not current or not current.frame or not EPC.saved then return end
        local enabled = EPC.saved.showPerformanceOverlay ~= false
        if type(current.SuppressNative) == "function" then
            current:SuppressNative(enabled and EPC.saved.suppressNativePerformanceMeters ~= false)
        end
        local show = type(current.ShouldShow) == "function" and current:ShouldShow() or enabled
        if type(current.ApplyHudReason) == "function" then current:ApplyHudReason(show) end
        if enabled then current:UpdateValues() end
    end)
end

local function takeOwnership()
    installFinalSwapGates()
    ownCombatHudTimer()
    ownMiniMapMarkerTimer()
    ownAbilityOverlayTimer()
    ownDualActionBarTimer()
    ownRotationTimer()
    ownTeamVisibilityTimers()
    ownPerformanceOverlayTimer()
end

-- All action-bar wrapper files have already loaded before this file, so install
-- the outermost guards immediately. Reinstalling ownership after activation is
-- still useful because module Initialize methods may replace timer registrations.
installFinalSwapGates()

if EVENT_PLAYER_ACTIVATED then
    EM:RegisterForEvent(NAME .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
        if type(zo_callLater) == "function" then
            zo_callLater(takeOwnership, 50)
            zo_callLater(takeOwnership, 500)
        else
            takeOwnership()
        end
    end)
end

if EVENT_PLAYER_COMBAT_STATE then
    EM:RegisterForEvent(NAME .. "_Combat", EVENT_PLAYER_COMBAT_STATE, function(_, active)
        if active == true then return end
        if type(zo_callLater) == "function" then
            zo_callLater(takeOwnership, 80)
        else
            takeOwnership()
        end
    end)
end

SLASH_COMMANDS = SLASH_COMMANDS or {}
SLASH_COMMANDS["/easperfmem"] = function()
    local luaKb = nil
    if type(collectgarbage) == "function" then
        local ok, value = pcall(collectgarbage, "count")
        if ok then luaKb = tonumber(value) end
    end

    local poolMb = nil
    if type(GetTotalUserAddOnMemoryPoolUsageMB) == "function" then
        local ok, value = pcall(GetTotalUserAddOnMemoryPoolUsageMB)
        if ok then poolMb = tonumber(value) end
    end

    local parts = {
        "ESO Adventurer Suite runtime",
        hardMode() and "HARD TRIAL" or "NORMAL",
    }
    if luaKb then parts[#parts + 1] = string.format("Lua %.1f MB", luaKb / 1024) end
    if poolMb and poolMb > 0 then parts[#parts + 1] = string.format("addon pool %.1f MB", poolMb) end
    if type(d) == "function" then d(table.concat(parts, " | ")) end
end

SLASH_COMMANDS["/easswapstats"] = function()
    local c = EPC.swapPerfCounters029639 or {}
    local text = string.format(
        "EAS swap blocks | dynamic=%d static=%d queue=%d ability=%d rotation=%d",
        tonumber(c.dynamic) or 0,
        tonumber(c.static) or 0,
        tonumber(c.queue) or 0,
        tonumber(c.ability) or 0,
        tonumber(c.rotation) or 0)
    if type(d) == "function" then d(text) end
end
