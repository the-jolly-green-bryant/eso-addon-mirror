MCAT_Tracker = {}

--#region[purple] Modules and locals
local Utils = MCAT_Utils
local EM = EVENT_MANAGER

-- buffId -> mechanicKey, built in Initialize() once MCAT_Definitions is available
local BuffIdToMechanic = {}
--#endregion

--#region[teal] Effect tracking
local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime,
        stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId,
        sourceType)
    local mechanicKey = BuffIdToMechanic[abilityId]
    if not mechanicKey then return end

    local stacks = (changeType == EFFECT_RESULT_FADED) and 0 or stackCount
    if MCAT.State[mechanicKey].stacks == stacks then return end
    MCAT.State[mechanicKey].stacks = stacks
    Utils.LogDebug(mechanicKey .. " stacks: " .. tostring(stacks))
    MCAT_Interface.Update()
end

local function Resync()
    for i = 1, GetNumBuffs("player") do
        local _, _, _, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        local mechanicKey = BuffIdToMechanic[abilityId]
        if mechanicKey then
            MCAT.State[mechanicKey].stacks = stackCount
            Utils.LogDebug(mechanicKey .. " resynced: " .. tostring(stackCount))
        end
    end
    MCAT_Interface.Update()
end

-- namespace must be unique per buffId: EVENT_MANAGER keys registrations/filters by (namespace, eventCode),
-- so sharing one namespace across buff ids would overwrite all but the last filter.
local function RegisterEffectTracking()
    for buffId in pairs(BuffIdToMechanic) do
        local namespace = MCAT.name .. "_Effect_" .. buffId
        EM:RegisterForEvent(namespace, EVENT_EFFECT_CHANGED, OnEffectChanged)
        EM:AddFilterForEvent(namespace, EVENT_EFFECT_CHANGED,
            REGISTER_FILTER_ABILITY_ID, buffId,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    end
end

local function UnregisterEffectTracking()
    for buffId in pairs(BuffIdToMechanic) do
        EM:UnregisterForEvent(MCAT.name .. "_Effect_" .. buffId, EVENT_EFFECT_CHANGED)
    end
end
--#endregion

--#region[orange] Combat gating
-- Tracking and display are both combat-only to avoid running buff-change tracking
-- (and the resulting UI updates) during normal open-world play. MCAT.InCombat is the
-- single source of truth Init.lua's ActionBarUpdated reads to fold into visibility.
local function OnCombatStateChanged(eventCode, inCombat)
    MCAT.InCombat = inCombat
    if inCombat then
        RegisterEffectTracking()
        Resync()
    else
        UnregisterEffectTracking()
    end
    MCAT.ActionBarUpdated()
end
--#endregion

--#region[pink] Debug
function MCAT_Tracker.ScanBuffs()
    Utils.Log(string.format("Buff scan: %d active", GetNumBuffs("player")))
    for i = 1, GetNumBuffs("player") do
        local name, _, _, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        Utils.Log(string.format("[%d] %s (id=%d, stacks=%d)", i, name, abilityId, stackCount))
    end
end

SLASH_COMMANDS["/mcat"] = function(extra)
    if extra == "scan" then
        MCAT_Tracker.ScanBuffs()
    else
        Utils.Log("Usage: /mcat scan")
    end
end
--#endregion

--#region[yellow] Init
function MCAT_Tracker.Initialize()
    MCAT.State = {}
    MCAT.InCombat = false
    for mechanicKey, def in pairs(MCAT_Definitions) do
        MCAT.State[mechanicKey] = { stacks = 0, visible = false }
        if def.buffId then
            BuffIdToMechanic[def.buffId] = mechanicKey
        end
        if def.skillMap then
            for _, buffId in pairs(def.skillMap) do
                BuffIdToMechanic[buffId] = mechanicKey
            end
        end
    end

    local combatNamespace = MCAT.name .. "_Combat"
    EM:RegisterForEvent(combatNamespace, EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)

    local resyncNamespace = MCAT.name .. "_Resync"
    EM:RegisterForEvent(resyncNamespace, EVENT_PLAYER_ACTIVATED, Resync)
    EM:RegisterForEvent(resyncNamespace, EVENT_PLAYER_ALIVE, Resync)
    EM:RegisterForEvent(resyncNamespace, EVENT_ZONE_CHANGED, Resync)

    -- addon can load mid-fight (e.g. /reloadui), so seed state instead of waiting for the next transition
    OnCombatStateChanged(nil, IsUnitInCombat("player"))
end
--#endregion
