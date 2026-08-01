-- NORMetronome.lua
local Addon = NORGuildTools
Addon.Metronome = Addon.Metronome or {}
local M = Addon.Metronome

M.enabled = false
M.inCombat = false
M.timerActive = false
M.interval = 1000

local METRO_SOUND = SOUNDS.ABILITY_SYNERGY_READY

function M:Tick()
    if not self.enabled or not self.inCombat then
        self.timerActive = false
        return
    end

    PlaySound(METRO_SOUND)

    zo_callLater(function() M:Tick() end, self.interval)
end

function M:Start()
    if self.timerActive then return end
    self.timerActive = true
    self:Tick()
end

function M:Stop()
    self.timerActive = false
end

local function OnCombatState(event, inCombat)
    M.inCombat = inCombat
    if M.enabled and inCombat then
        M:Start()
    else
        M:Stop()
    end
end

local function ToggleMetronome()
    M.enabled = not M.enabled

    if M.enabled then
        d("|c00FF00NOR Metronome enabled.|r")
        if M.inCombat then M:Start() end
    else
        d("|cFF0000NOR Metronome disabled.|r")
        M:Stop()
    end
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= Addon.name then return end

    SLASH_COMMANDS["/normetro"] = ToggleMetronome

    EVENT_MANAGER:RegisterForEvent(
        "NOR_MetronomeCombat",
        EVENT_PLAYER_COMBAT_STATE,
        OnCombatState
    )

    EVENT_MANAGER:UnregisterForEvent("NOR_MetronomeInit", EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent("NOR_MetronomeInit", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
