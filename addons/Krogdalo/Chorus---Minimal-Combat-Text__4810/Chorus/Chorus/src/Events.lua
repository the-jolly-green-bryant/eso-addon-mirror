local Ev = Chorus.Events
local API = Chorus.API
local S = Chorus.Strings

Ev.TICK_MS = 16

local function set(names) local t = {} for _, n in ipairs(names) do if _G[n] then t[_G[n]] = true end end return t end
local DAMAGE = set({ "ACTION_RESULT_DAMAGE", "ACTION_RESULT_CRITICAL_DAMAGE", "ACTION_RESULT_BLOCKED_DAMAGE", "ACTION_RESULT_DAMAGE_SHIELDED", "ACTION_RESULT_KILLING_BLOW" })
local DAMAGE_TICK = set({ "ACTION_RESULT_DOT_TICK", "ACTION_RESULT_DOT_TICK_CRITICAL" })
local HEAL = set({ "ACTION_RESULT_HEAL", "ACTION_RESULT_CRITICAL_HEAL" })
local HEAL_TICK = set({ "ACTION_RESULT_HOT_TICK", "ACTION_RESULT_HOT_TICK_CRITICAL" })
local CRIT = set({ "ACTION_RESULT_CRITICAL_DAMAGE", "ACTION_RESULT_DOT_TICK_CRITICAL", "ACTION_RESULT_CRITICAL_HEAL", "ACTION_RESULT_HOT_TICK_CRITICAL" })

function Ev.Init(engine, sv, callbacks)
    Ev.engine, Ev.sv = engine, sv
    Ev.onShow = callbacks and callbacks.onShow or function() end
    Ev.onHide = callbacks and callbacks.onHide or function() end
    Ev.onTick = callbacks and callbacks.onTick or function() end
    Ev.ticking = false
    Ev.warned = false
    local name = Chorus.name

    local function onCombat(_, result, _, _, _, _, _, sourceType, _, targetType, hitValue, _, _, _, _, _, abilityId, overflow)
        if sourceType == COMBAT_UNIT_TYPE_PLAYER_PET and not sv.includePets then return end
        local amount = (hitValue or 0) + (overflow or 0)
        if amount <= 0 then return end
        local kind, tick
        if DAMAGE[result] then kind, tick = "damage", false
        elseif DAMAGE_TICK[result] then kind, tick = "damage", true
        elseif HEAL[result] then kind, tick = "heal", false
        elseif HEAL_TICK[result] then kind, tick = "heal", true
        else return end
        if kind == "damage" and targetType == COMBAT_UNIT_TYPE_PLAYER then return end
        if kind == "heal" and not sv.showHealing then return end
        engine:Hit(API.Now(), { id = abilityId, name = API.AbilityName(abilityId), amount = amount, crit = CRIT[result] == true, tick = tick, kind = kind })
        Ev.StartTicking()
    end

    EVENT_MANAGER:RegisterForEvent(name .. "Player", EVENT_COMBAT_EVENT, onCombat)
    EVENT_MANAGER:AddFilterForEvent(name .. "Player", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    if COMBAT_UNIT_TYPE_PLAYER_PET then
        EVENT_MANAGER:RegisterForEvent(name .. "Pet", EVENT_COMBAT_EVENT, onCombat)
        EVENT_MANAGER:AddFilterForEvent(name .. "Pet", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_PET)
    end
    if REGISTER_FILTER_IS_ERROR then
        EVENT_MANAGER:AddFilterForEvent(name .. "Player", EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)
        if COMBAT_UNIT_TYPE_PLAYER_PET then EVENT_MANAGER:AddFilterForEvent(name .. "Pet", EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false) end
    end

    EVENT_MANAGER:RegisterForEvent(name .. "Combat", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        engine:CombatState(API.Now(), inCombat == true)
        if sv.summary then Ev.StartTicking() end
    end)

    EVENT_MANAGER:RegisterForEvent(name .. "Activated", EVENT_PLAYER_ACTIVATED, function()
        if not Ev.warned and API.LuiCombatTextEnabled() then
            Ev.warned = true
            API.Print(S.Get("LUI_HINT"))
        end
    end)
end

local function tick()
    local view = Ev.engine:Tick(API.Now())
    if #view.entries == 0 and (not view.summary or not Ev.sv.summary) then Ev.StopTicking(); return end
    Ev.onTick(view)
end

function Ev.StartTicking()
    if Ev.ticking then return end
    Ev.ticking = true
    EVENT_MANAGER:RegisterForUpdate(Chorus.name .. "Tick", Ev.TICK_MS, tick)
    Ev.onShow()
    tick()
end

function Ev.StopTicking()
    if not Ev.ticking then return end
    Ev.ticking = false
    EVENT_MANAGER:UnregisterForUpdate(Chorus.name .. "Tick")
    Ev.onHide()
end
