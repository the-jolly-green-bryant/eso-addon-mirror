-- ESO Adventurer Suite
-- v0.29.574 - global player-death HUD suppression.
-- Suite gameplay overlays disappear while the local player is dead and restore
-- through their normal visibility logic after resurrection.

local EPC = ESOProgressionCoach
if not EPC or not EVENT_MANAGER then return end

local EM = EVENT_MANAGER
local PREFIX = (EPC.name or "ESOAdventurerSuite") .. "_DeathHUD029574"
local STATE = { dead = false, hidden = {} }

local function isDead()
    if type(IsUnitDead) ~= "function" then return false end
    local ok, value = pcall(IsUnitDead, "player")
    return ok and value == true
end

local baseSuppressed = EPC.IsGameplayHudSuppressed
if not EPC._easDeathSuppressionWrapped029574 then
    EPC._easDeathSuppressionWrapped029574 = true
    function EPC:IsGameplayHudSuppressed(...)
        if STATE.dead or isDead() then return true end
        if type(baseSuppressed) == "function" then
            return baseSuppressed(self, ...)
        end
        return false
    end
end

local moduleNames = {
    "UnitFrames", "DualActionBar", "RotationAssistant", "AbilityOverlays",
    "TickTracker", "QuickslotOverlay", "InfiniteArchiveOverlay", "SynergyOverlay",
    "Reticle", "RepairCostOverlay", "PerformanceOverlay", "EncounterReminders",
    "ChallengeDifficultyOverlay", "StableTimer", "Clock", "ActiveQuest",
    "GoldenPursuits", "AllianceRank", "ChampionOverlay", "MiniMap",
    "BossMechanicsAssistant", "CombatPresentation", "OverlandDifficulty",
}

local function addControl(out, seen, control)
    if not control or seen[control] or type(control.SetHidden) ~= "function" then return end
    -- Limit this rule to Suite top-level HUD roots; child controls follow parent.
    local parent = nil
    if type(control.GetParent) == "function" then
        local ok, value = pcall(control.GetParent, control)
        if ok then parent = value end
    end
    if parent ~= nil and parent ~= GuiRoot then return end
    seen[control] = true
    out[#out + 1] = control
end

local function collectControls()
    local out, seen = {}, {}
    local preferredKeys = {
        "frame", "window", "root", "panel", "container", "groupFrame", "raidFrame",
        "playerFrame", "targetFrame", "companionFrame", "combatHud", "swapCue",
    }
    for _, moduleName in ipairs(moduleNames) do
        local module = EPC[moduleName]
        if type(module) == "table" then
            for _, key in ipairs(preferredKeys) do addControl(out, seen, module[key]) end
            -- Ability overlays and similar modules can own a small array of roots.
            for _, value in ipairs(module.widgets or {}) do
                if type(value) == "table" then
                    addControl(out, seen, value.frame)
                    addControl(out, seen, value.window)
                    addControl(out, seen, value.root)
                else
                    addControl(out, seen, value)
                end
            end
        end
    end
    return out
end

local function hideAll()
    for _, control in ipairs(collectControls()) do
        if STATE.hidden[control] == nil and type(control.IsHidden) == "function" then
            local ok, hidden = pcall(control.IsHidden, control)
            STATE.hidden[control] = ok and hidden == true or false
        end
        pcall(control.SetHidden, control, true)
    end
end

local function refreshNormalVisibility()
    if type(EPC.RefreshResponsiveOverlays029343) == "function" then
        pcall(EPC.RefreshResponsiveOverlays029343, EPC)
    end
    for _, moduleName in ipairs(moduleNames) do
        local module = EPC[moduleName]
        if type(module) == "table" and type(module.Refresh) == "function" then
            pcall(module.Refresh, module)
        end
    end
    if EPC.UnitFrames and type(EPC.UnitFrames.RefreshGroupFrames) == "function" then
        pcall(EPC.UnitFrames.RefreshGroupFrames, EPC.UnitFrames)
    end
end

local function setDead(dead)
    dead = dead == true
    if STATE.dead == dead then
        if dead then hideAll() end
        return
    end
    STATE.dead = dead

    if dead then
        hideAll()
        EM:UnregisterForUpdate(PREFIX .. "_Enforce")
        EM:RegisterForUpdate(PREFIX .. "_Enforce", 250, hideAll)
    else
        EM:UnregisterForUpdate(PREFIX .. "_Enforce")
        -- Restore only controls that were visible before death; normal module
        -- refreshes below remain authoritative for scene/setting visibility.
        for control, wasHidden in pairs(STATE.hidden) do
            if control and type(control.SetHidden) == "function" and wasHidden == false then
                pcall(control.SetHidden, control, false)
            end
        end
        STATE.hidden = {}
        if type(zo_callLater) == "function" then
            zo_callLater(refreshNormalVisibility, 80)
        else
            refreshNormalVisibility()
        end
    end
end

local function syncDeathState()
    setDead(isDead())
end

if rawget(_G, "EVENT_PLAYER_DEAD") then
    EM:RegisterForEvent(PREFIX .. "_Dead", EVENT_PLAYER_DEAD, function() setDead(true) end)
end
if rawget(_G, "EVENT_PLAYER_ALIVE") then
    EM:RegisterForEvent(PREFIX .. "_Alive", EVENT_PLAYER_ALIVE, function() setDead(false) end)
end
if rawget(_G, "EVENT_PLAYER_ACTIVATED") then
    EM:RegisterForEvent(PREFIX .. "_Activated", EVENT_PLAYER_ACTIVATED, syncDeathState)
end
if rawget(_G, "EVENT_PLAYER_COMBAT_STATE") then
    EM:RegisterForEvent(PREFIX .. "_Combat", EVENT_PLAYER_COMBAT_STATE, syncDeathState)
end

syncDeathState()
