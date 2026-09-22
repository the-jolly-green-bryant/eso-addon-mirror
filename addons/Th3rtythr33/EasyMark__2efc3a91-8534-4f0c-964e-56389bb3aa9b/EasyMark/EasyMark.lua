-- EasyMark
-- Places a group target marker on the unit under your reticle when a trigger fires.
-- A trigger is only watched while it has a marker assigned in the settings menu.

EasyMark = EasyMark or {}
local EM = EasyMark

EM.name = "EasyMark"
EM.version = "1.0.0"
EM.savedVarsName = "EasyMarkSavedVars"
EM.savedVarsVersion = 1

-------------------------------------------------------------------------------
-- Tunables
-------------------------------------------------------------------------------

-- Two weapon swaps within this many milliseconds count as "Swap Weapons Twice".
local DOUBLE_SWAP_WINDOW_MS = 2000

-- How long after a heavy attack begins we treat hit events as part of that
-- same attack. Covers the longest charge plus channeled staff ticks.
local HEAVY_ATTACK_LIFETIME_MS = 3500

-- Hotbar slot that always holds the heavy attack ability.
local HEAVY_ATTACK_SLOT_INDEX = 2

-------------------------------------------------------------------------------
-- Marker choices
-------------------------------------------------------------------------------

-- Names follow the in-game icon art (EsoUI/Art/TargetMarkers).
local MARK_ITEMS =
{
    { name = "None",                data = TARGET_MARKER_TYPE_NONE },
    { name = "1 - Blue Square",     data = TARGET_MARKER_TYPE_ONE },
    { name = "2 - Gold Star",       data = TARGET_MARKER_TYPE_TWO },
    { name = "3 - Green Circle",    data = TARGET_MARKER_TYPE_THREE },
    { name = "4 - Orange Triangle", data = TARGET_MARKER_TYPE_FOUR },
    { name = "5 - Pink Moons",      data = TARGET_MARKER_TYPE_FIVE },
    { name = "6 - Purple Oblivion", data = TARGET_MARKER_TYPE_SIX },
    { name = "7 - Red Weapons",     data = TARGET_MARKER_TYPE_SEVEN },
    { name = "8 - White Skull",     data = TARGET_MARKER_TYPE_EIGHT },
}

local MARK_NAME_BY_TYPE = {}
local MARK_TYPE_BY_NAME = {}
for _, item in ipairs(MARK_ITEMS) do
    MARK_NAME_BY_TYPE[item.data] = item.name
    MARK_TYPE_BY_NAME[item.name] = item.data
end

-------------------------------------------------------------------------------
-- Marking
-------------------------------------------------------------------------------

-- Marks the reticle target. Returns true when the target now carries the
-- marker (either newly assigned or already present), false when there was
-- nothing under the reticle to mark.
local function ApplyMark(markType)
    if markType == nil or markType == TARGET_MARKER_TYPE_NONE then
        return false
    end
    -- The API can only mark whatever is under the reticle right now.
    if not DoesUnitExist("reticleover") then
        return false
    end
    -- Assigning the marker a unit already has removes it, so never toggle it off here.
    if GetUnitTargetMarkerType("reticleover") == markType then
        return true
    end
    AssignTargetMarkerToReticleTarget(markType)
    return true
end

local function FormatUnitName(name)
    if name == nil or name == "" then
        return ""
    end
    return zo_strformat(SI_UNIT_NAME, name)
end

-------------------------------------------------------------------------------
-- Trigger: Heavy Attack
-------------------------------------------------------------------------------
--
-- The marker API only ever targets what is under the reticle at call time, and
-- a heavy attack can finish after the target has drifted out of the reticle.
-- So the marker is placed the moment the heavy attack BEGINS, while the target
-- is still in the reticle. The hit events that arrive later are only used as a
-- fallback for the case where nothing was under the reticle at the start.

-- Fallback list of direct heavy-attack ability IDs, used when the combat event
-- does not carry ACTION_SLOT_TYPE_HEAVY_ATTACK in abilityActionSlotType.
local HEAVY_ATTACK_ABILITY_IDS =
{
    [16041] = true, -- Two Handed
    [15279] = true, -- One Hand and Shield
    [16420] = true, -- Dual Wield
    [16691] = true, -- Bow
    [15383] = true, -- Inferno Staff
    [16261] = true, -- Frost Staff
    [32477] = true, -- Werewolf
}

-- Combat results that mean the heavy attack has started charging or channeling.
local HEAVY_ATTACK_BEGIN_RESULTS =
{
    [ACTION_RESULT_BEGIN] = true,
    [ACTION_RESULT_BEGIN_CHANNEL] = true,
}

-- Combat results that mean the heavy attack actually connected with a target.
local HEAVY_ATTACK_HIT_RESULTS =
{
    [ACTION_RESULT_DAMAGE] = true,
    [ACTION_RESULT_CRITICAL_DAMAGE] = true,
    [ACTION_RESULT_BLOCKED_DAMAGE] = true,
    [ACTION_RESULT_DAMAGE_SHIELDED] = true,
    [ACTION_RESULT_DOT_TICK] = true,
    [ACTION_RESULT_DOT_TICK_CRITICAL] = true,
    [ACTION_RESULT_KILLING_BLOW] = true,
    [ACTION_RESULT_DODGED] = true,
    [ACTION_RESULT_IMMUNE] = true,
    [ACTION_RESULT_MISS] = true,
    [ACTION_RESULT_PARRIED] = true,
    [ACTION_RESULT_REFLECTED] = true,
    [ACTION_RESULT_RESIST] = true,
    [ACTION_RESULT_PARTIAL_RESIST] = true,
    [ACTION_RESULT_ABSORBED] = true,
}

-- State of the heavy attack currently in progress, if any.
local heavyAttack =
{
    startedMs = 0,      -- when the begin event arrived (0 = none in progress)
    marked = false,     -- whether this attack has already placed its marker
}

local function IsHeavyAttackAbility(abilityActionSlotType, abilityId)
    if abilityActionSlotType == ACTION_SLOT_TYPE_HEAVY_ATTACK then
        return true
    end
    if HEAVY_ATTACK_ABILITY_IDS[abilityId] then
        return true
    end
    return abilityId ~= 0 and abilityId == GetSlotBoundId(HEAVY_ATTACK_SLOT_INDEX)
end

local function OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
                             sourceName, sourceType, targetName, targetType, hitValue, powerType,
                             damageType, log, sourceUnitId, targetUnitId, abilityId)
    if isError then
        return
    end
    if not IsHeavyAttackAbility(abilityActionSlotType, abilityId) then
        return
    end

    local now = GetGameTimeMilliseconds()
    local markType = EM.sv.marks.heavyAttack

    if HEAVY_ATTACK_BEGIN_RESULTS[result] then
        -- Heavy attack just started: mark whatever is in the reticle right now,
        -- before the player has a chance to turn away.
        heavyAttack.startedMs = now
        heavyAttack.marked = ApplyMark(markType)
        return
    end

    if not HEAVY_ATTACK_HIT_RESULTS[result] then
        return
    end

    -- Hit events for an attack that already marked its target are ignored.
    local inProgress = heavyAttack.startedMs > 0 and (now - heavyAttack.startedMs) <= HEAVY_ATTACK_LIFETIME_MS
    if inProgress and heavyAttack.marked then
        return
    end

    -- Fallback: no begin event was seen, or nothing was in the reticle when the
    -- attack started. Mark on hit if the thing we hit is what we are looking at.
    local hitName = FormatUnitName(targetName)
    if hitName ~= "" and hitName ~= FormatUnitName(GetUnitName("reticleover")) then
        return
    end

    if ApplyMark(markType) then
        heavyAttack.startedMs = now
        heavyAttack.marked = true
    end
end

local HEAVY_ATTACK_EVENT_NAME = EM.name .. "_HeavyAttack"

local function StartHeavyAttackWatcher()
    heavyAttack.startedMs = 0
    heavyAttack.marked = false
    EVENT_MANAGER:RegisterForEvent(HEAVY_ATTACK_EVENT_NAME, EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(HEAVY_ATTACK_EVENT_NAME, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EVENT_MANAGER:AddFilterForEvent(HEAVY_ATTACK_EVENT_NAME, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_IS_ERROR, false)
end

local function StopHeavyAttackWatcher()
    EVENT_MANAGER:UnregisterForEvent(HEAVY_ATTACK_EVENT_NAME, EVENT_COMBAT_EVENT)
    heavyAttack.startedMs = 0
    heavyAttack.marked = false
end

-------------------------------------------------------------------------------
-- Trigger: Swap Weapons Twice
-------------------------------------------------------------------------------

local lastSwapMs = nil
local lastSwapPair = nil

local function OnWeaponPairChanged(_, activeWeaponPair, locked)
    local now = GetGameTimeMilliseconds()

    if lastSwapMs ~= nil
        and activeWeaponPair ~= lastSwapPair
        and (now - lastSwapMs) <= DOUBLE_SWAP_WINDOW_MS then
        -- Second swap inside the window: fire and reset so a third swap starts fresh.
        lastSwapMs = nil
        lastSwapPair = nil
        ApplyMark(EM.sv.marks.doubleSwap)
        return
    end

    lastSwapMs = now
    lastSwapPair = activeWeaponPair
end

local DOUBLE_SWAP_EVENT_NAME = EM.name .. "_DoubleSwap"

local function StartDoubleSwapWatcher()
    lastSwapMs = nil
    lastSwapPair = nil
    EVENT_MANAGER:RegisterForEvent(DOUBLE_SWAP_EVENT_NAME, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, OnWeaponPairChanged)
end

local function StopDoubleSwapWatcher()
    EVENT_MANAGER:UnregisterForEvent(DOUBLE_SWAP_EVENT_NAME, EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    lastSwapMs = nil
    lastSwapPair = nil
end

-------------------------------------------------------------------------------
-- Trigger registry
-------------------------------------------------------------------------------

EM.triggers =
{
    {
        key = "heavyAttack",
        label = "Heavy Attack",
        tooltip = "Marks the target you are looking at the moment you begin a heavy attack.",
        start = StartHeavyAttackWatcher,
        stop = StopHeavyAttackWatcher,
        active = false,
    },
    {
        key = "doubleSwap",
        label = "Swap Weapons Twice",
        tooltip = "Marks the target you are looking at when you swap weapon bars twice within two seconds.",
        start = StartDoubleSwapWatcher,
        stop = StopDoubleSwapWatcher,
        active = false,
    },
}

-- Start watchers for triggers that have a marker assigned and stop the rest.
function EM.RefreshWatchers()
    for _, trigger in ipairs(EM.triggers) do
        local markType = EM.sv.marks[trigger.key]
        local wanted = markType ~= nil and markType ~= TARGET_MARKER_TYPE_NONE
        if wanted and not trigger.active then
            trigger.start()
            trigger.active = true
        elseif not wanted and trigger.active then
            trigger.stop()
            trigger.active = false
        end
    end
end

-------------------------------------------------------------------------------
-- Saved variables
-------------------------------------------------------------------------------

local function BuildDefaults()
    local defaults = { marks = {} }
    for _, trigger in ipairs(EM.triggers) do
        defaults.marks[trigger.key] = TARGET_MARKER_TYPE_NONE
    end
    return defaults
end

local function ResetToDefaults()
    for _, trigger in ipairs(EM.triggers) do
        EM.sv.marks[trigger.key] = TARGET_MARKER_TYPE_NONE
    end
    EM.RefreshWatchers()
end

-------------------------------------------------------------------------------
-- Settings menu (LibHarvensAddonSettings)
-------------------------------------------------------------------------------

local function ResolveMarkType(itemName, itemData)
    -- Newer library versions pass the item's data; older ones pass the item table.
    if type(itemData) == "table" then
        itemData = itemData.data
    end
    if itemData ~= nil and MARK_NAME_BY_TYPE[itemData] then
        return itemData
    end
    return MARK_TYPE_BY_NAME[itemName] or TARGET_MARKER_TYPE_NONE
end

local function CreateSettingsMenu()
    if not LibHarvensAddonSettings then
        d("[EasyMark] LibHarvensAddonSettings is missing; the settings menu is unavailable.")
        return
    end

    local options =
    {
        allowDefaults = true,
        allowRefresh = true,
        defaultsFunction = ResetToDefaults,
    }
    local panel = LibHarvensAddonSettings:AddAddon("EasyMark", options)
    if not panel then
        return
    end

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Triggers",
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_LABEL,
        label = "Pick a marker for each trigger. A trigger set to None is not watched at all.",
    })

    for _, trigger in ipairs(EM.triggers) do
        local key = trigger.key
        panel:AddSetting({
            type = LibHarvensAddonSettings.ST_DROPDOWN,
            label = trigger.label,
            tooltip = trigger.tooltip,
            items = MARK_ITEMS,
            default = MARK_NAME_BY_TYPE[TARGET_MARKER_TYPE_NONE],
            getFunction = function()
                return MARK_NAME_BY_TYPE[EM.sv.marks[key]] or MARK_NAME_BY_TYPE[TARGET_MARKER_TYPE_NONE]
            end,
            setFunction = function(control, itemName, itemData)
                EM.sv.marks[key] = ResolveMarkType(itemName, itemData)
                EM.RefreshWatchers()
            end,
        })
    end
end

-------------------------------------------------------------------------------
-- Startup
-------------------------------------------------------------------------------

local function OnAddOnLoaded(_, addonName)
    if addonName ~= EM.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(EM.name, EVENT_ADD_ON_LOADED)

    EM.sv = ZO_SavedVars:NewAccountWide(EM.savedVarsName, EM.savedVarsVersion, nil, BuildDefaults())

    -- Guard against saved data from a build with a different trigger list.
    for _, trigger in ipairs(EM.triggers) do
        if MARK_NAME_BY_TYPE[EM.sv.marks[trigger.key]] == nil then
            EM.sv.marks[trigger.key] = TARGET_MARKER_TYPE_NONE
        end
    end

    CreateSettingsMenu()
    EM.RefreshWatchers()
end

EVENT_MANAGER:RegisterForEvent(EM.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
