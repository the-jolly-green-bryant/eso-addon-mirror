local KD = KyzderpsDerps
local Spud = KD.AntiSpud

Spud.PVE = "PVE"
Spud.PVP = "PVP"
Spud.HOUSING_PVE = "Housing dummy"
Spud.HOUSING_PVP = "Housing duel"
Spud.VENGEANCE = "Vengeance"
Spud.NONE = "Overland / elsewhere"

local currentState = Spud.NONE

function Spud.GetCurrentState()
    return currentState
end

function Spud.IsCurrentStateContentPVE()
    return currentState == Spud.PVE
end

function Spud.IsCurrentStateAnyPVE()
    return currentState == Spud.PVE or (KD.savedOptions.antispud.state.includeHouseCombatPVE and currentState == Spud.HOUSING_PVE)
end

function Spud.IsCurrentStateContentPVP()
    return currentState == Spud.PVP
end

function Spud.IsCurrentStateAnyPVP()
    return currentState == Spud.PVP or (KD.savedOptions.antispud.state.includeHouseCombatPVP and currentState == Spud.HOUSING_PVP)
end


---------------------------------------------------------------------
local BITMASKS = {
    [Spud.PVE] = 1,
    [Spud.PVP] = 2,
    [Spud.HOUSING_PVE] = 4,
    [Spud.HOUSING_PVP] = 8,
    [Spud.NONE] = 16,
    [Spud.VENGEANCE] = 32,
}

local function BuildSettings()
    local choices = {}
    local choicesValues = {}
    local order = {Spud.PVE, Spud.PVP, Spud.HOUSING_PVE, Spud.HOUSING_PVP, Spud.VENGEANCE, Spud.NONE}
    for _, state in ipairs(order) do
        table.insert(choices, state)
        table.insert(choicesValues, state)
    end

    return choices, choicesValues
end
Spud.BuildSettings = BuildSettings

-- Whether the specified state's bit is set in the setting
-- Returns true or false, or nil if the role is not valid
local function IsStateSet(setting, state)
    return BitAnd(setting, BITMASKS[state]) ~= 0
end

-- Converts a value like 6 to {Spud.PVP, Spud.HOUSING_PVE}
local function StateValueToTable(setting)
    local tab = {}
    for state, _ in pairs(BITMASKS) do
        if (IsStateSet(setting, state)) then
            table.insert(tab, state)
        end
    end
    return tab
end
Spud.StateValueToTable = StateValueToTable

-- Converts a table like {Spud.PVP, Spud.HOUSING_PVE} to 6
local function StateTableToValue(tab)
    local val = 0
    for _, state in ipairs(tab) do
        val = val + BITMASKS[state]
    end
    return val
end
Spud.StateTableToValue = StateTableToValue

local function IsCurrentStateEnabledInSetting(setting)
    return IsStateSet(setting, Spud.GetCurrentState())
end
Spud.IsCurrentStateEnabledInSetting = IsCurrentStateEnabledInSetting


---------------------------------------------------------------------
-- State Listeners
-- Other modules should register a listener for state changes
---------------------------------------------------------------------
local listeners = {}

-- Callback with params:
-- string oldState
-- string newState
function Spud.RegisterStateListener(name, callback)
    if (listeners[name]) then
        KD:dbg("|cFF0000Spud state listener " .. name .. " already exists|r")
        return
    end

    listeners[name] = callback
end

local function FireStateListeners(newState, reason)
    if (newState == currentState) then
        KD:dbg("|cFF0000Spud state is already " .. newState .. "|r")
        return
    end
    KD:dbg(string.format("State: %s → %s Reason: %s", currentState, newState, tostring(reason)))

    local prevState = currentState
    currentState = newState
    for _, callback in pairs(listeners) do
        callback(prevState, newState)
    end
end

---------------------------------------------------------------------
-- Cyrodiil or Imperial City Queue Check
---------------------------------------------------------------------
local function GetCyroType()
    if (GetNumCampaignQueueEntries() > 0) then
        return Spud.PVP
    end
    return Spud.NONE
end

---------------------------------------------------------------------
-- Zone Check
---------------------------------------------------------------------
local function IsDoingGroupPVE(zoneId)
    if (IsUnitInDungeon("player")) then
        return KD.IsInstanceId(tostring(zoneId))
    end
end
Spud.IsDoingGroupPVE = IsDoingGroupPVE

local function IsDoingPVP()
    if (IsActiveWorldBattleground()) then
        return true
    end

    if (IsInAvAZone()) then
        return true
    end

    if (IsInImperialCity()) then
        return true
    end

    if (GetUnitBattlegroundTeam("player") ~= nil and GetUnitBattlegroundTeam("player") ~= 0) then
        return true
    end
end
Spud.IsDoingPVP = IsDoingPVP

---------------------------------------------------------------------
-- Dungeon / Battlegrounds Finder
---------------------------------------------------------------------
-- Code from esoui/ingame/lfg/activitytracker.lua
local function GetCurrentFinderType()
    local activityId = 0

    if (IsCurrentlySearchingForGroup()) then
        activityId = GetActivityRequestIds(1)
    elseif (IsInLFGGroup()) then
        activityId = GetCurrentLFGActivityId()
    end

    if (activityId <= 0) then
        return Spud.NONE
    end

    local activityType = GetActivityType(activityId)

    if (activityType == LFG_ACTIVITY_DUNGEON or activityType == LFG_ACTIVITY_MASTER_DUNGEON) then
        return Spud.PVE
    elseif (activityType == LFG_ACTIVITY_BATTLE_GROUND_CHAMPION or activityType == LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION or activityType == LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL) then
        return Spud.PVP
    elseif (activityType == LFG_ACTIVITY_TRIBUTE_CASUAL or activityType == LFG_ACTIVITY_TRIBUTE_COMPETITIVE) then
        return Spud.NONE
    else
        KD:dbg(string.format("|cFF0000THIS SHOULDN'T BE POSSIBLE? %d", activityType))
        return Spud.NONE
    end
end

---------------------------------------------------------------------
-- Check current state and fire listeners if applicable
---------------------------------------------------------------------
local function CheckState(reason)
    local finderType = Spud.NONE
    if (KD.savedOptions.antispud.state.includeActivityFinder) then
        finderType = GetCurrentFinderType()
        if (finderType == Spud.NONE) then
            -- Also check Cyro / IC queue
            finderType = GetCyroType()
        end
    end

    local checkedState = Spud.NONE
    if (finderType == Spud.PVE or finderType == Spud.PVP) then
        -- Activity finder should take priority
        checkedState = finderType
    else
        -- If we're not queued, just use the zone as the check
        local zoneId = GetZoneId(GetUnitZoneIndex("player"))
        if (IsCurrentCampaignVengeanceRuleset()) then
            checkedState = Spud.VENGEANCE
        elseif (IsDoingGroupPVE(zoneId)) then
            checkedState = Spud.PVE
        elseif (IsDoingPVP()) then
            checkedState = Spud.PVP
        elseif (GetCurrentZoneHouseId() ~= 0) then
            if (IsUnitPvPFlagged("player")) then
                checkedState = Spud.HOUSING_PVP -- Dueling
            elseif (IsUnitInCombat("player")) then
                checkedState = Spud.HOUSING_PVE -- Otherwise dummy
            end
        else
            checkedState = Spud.NONE
        end
    end

    if (checkedState ~= currentState) then
        FireStateListeners(checkedState, reason)
    end
end
Spud.CheckState = CheckState

---------------------------------------------------------------------
-- Events to trigger state check
---------------------------------------------------------------------
local function OnFinderStatusUpdate()
    CheckState("finder")
end

local function OnCampaignQueueChanged()
    CheckState("campaign")
end

local function OnCombatStateChanged()
    CheckState("combat")
end

local prevZoneId
local function OnPlayerActivated()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if (prevZoneId) then
        KD:dbg(string.format("|c00FF00Left zone %s (%d)|r", GetZoneNameById(prevZoneId), prevZoneId))
    end
    KD:dbg(string.format("|c00FF00Entered zone %s (%d)|r", GetPlayerActiveZoneName(), zoneId))
    prevZoneId = zoneId

    CheckState("activation")
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Spud.InitializeState()
    EVENT_MANAGER:RegisterForEvent(KD.name .. "SpudActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    OnPlayerActivated()

    EVENT_MANAGER:RegisterForEvent(KD.name .. "SpudActivityFinder", EVENT_ACTIVITY_FINDER_STATUS_UPDATE, OnFinderStatusUpdate)

    EVENT_MANAGER:RegisterForEvent(KD.name .. "SpudCampaignJoined", EVENT_CAMPAIGN_QUEUE_JOINED, OnCampaignQueueChanged)
    EVENT_MANAGER:RegisterForEvent(KD.name .. "SpudCampaignLeft", EVENT_CAMPAIGN_QUEUE_LEFT, OnCampaignQueueChanged)

    EVENT_MANAGER:RegisterForEvent(KD.name .. "SpudCombat", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
end
