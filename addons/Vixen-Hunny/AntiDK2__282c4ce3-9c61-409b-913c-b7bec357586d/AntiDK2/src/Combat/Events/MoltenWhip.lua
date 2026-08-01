local ADK = AntiDK2
local M   = {}
ADK.Combat.Events.MoltenWhip = M

local ID         = ADK.IDS.MOLTEN_WHIP
local MAX_STACKS = 3
local DECAY_MS   = 12000

local stacks = {}

local function Decay(name)
    if stacks[name] then
        stacks[name] = nil
        ADK.UI.MoltenStacks.Refresh(stacks)
    end
end

local function OnHit(sourceName, result)
    if result == ACTION_RESULT_EFFECT_FADED then
        -- Stacks faded (expired naturally or consumed by empowered whip)
        Decay(sourceName)
        return
    end

    if not stacks[sourceName] then
        stacks[sourceName] = { count = 0, decayHandle = nil }
    end
    local e = stacks[sourceName]

    if result == ACTION_RESULT_EFFECT_GAINED then
        -- Each EFFECT_GAINED = +1 stack (do not use hitValue, it is not the stack count)
        e.count = math.min(e.count + 1, MAX_STACKS)
    else
        -- Damage result: if stacks are at max, the empowered whip was used - consume
        if e.count >= MAX_STACKS then
            Decay(sourceName)
            return
        end
        -- Sub-max damage: just refresh (stacks unchanged until EFFECT_GAINED fires)
    end

    if e.decayHandle then zo_removeCallLater(e.decayHandle) end
    if e.count > 0 then
        e.decayHandle = zo_callLater(function() Decay(sourceName) end, DECAY_MS)
    else
        stacks[sourceName] = nil
    end
    ADK.UI.MoltenStacks.Refresh(stacks)
end

function M.Register()
    EVENT_MANAGER:RegisterForEvent(
        ADK.name .. "_MoltenWhip", EVENT_COMBAT_EVENT,
        function(_, result, _, _, _, _, sourceName, sourceType, targetName, _, _, _, _, _, _, targetUnitId, abilityId)
            if not ADK.savedVars.trackMoltenWhip then return end
            if abilityId ~= ID and abilityId ~= ADK.IDS.MOLTEN_ATTACK then return end
            local name = zo_strformat("<<1>>", sourceName)
            if name == GetUnitName("player") then return end
            local tName = zo_strformat("<<1>>", targetName)
            if tName ~= GetUnitName("player") then return end
            if result ~= ACTION_RESULT_EFFECT_FADED
            and result ~= ACTION_RESULT_EFFECT_GAINED
            and result ~= ACTION_RESULT_DAMAGE
            and result ~= ACTION_RESULT_CRITICAL_DAMAGE
            and result ~= ACTION_RESULT_BLOCKED
            and result ~= ACTION_RESULT_BLOCKED_DAMAGE
            and result ~= ACTION_RESULT_DODGED then return end
            OnHit(sourceName, result)
            --ADK.Combat.Events.Wings.TrackEnemy(sourceName, sourceType)
        end
    )
    EVENT_MANAGER:RegisterForEvent(
        ADK.name .. "_MoltenDeath", EVENT_COMBAT_EVENT,
        function(_, result, _, _, _, _, _, _, targetName, _, _, _, _, _, _, _, _)
            if result ~= ACTION_RESULT_KILLED then return end
            if stacks[targetName] then Decay(targetName) end
        end
    )
end

function M.Unregister()
    EVENT_MANAGER:UnregisterForEvent(ADK.name .. "_MoltenWhip",  EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(ADK.name .. "_MoltenDeath", EVENT_COMBAT_EVENT)
end

function M.Reset()
    for _, e in pairs(stacks) do
        if e.decayHandle then zo_removeCallLater(e.decayHandle) end
    end
    stacks = {}
    ADK.UI.MoltenStacks.Refresh(stacks)
end
