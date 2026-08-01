-- =================================
-- Bard Class – Combat Stance
-- =================================

local BCS = {
    name = "BardCombatStance",
    version = "1.2.1",

    instruments = {
        { name = "Lute",  slash = "/lute"  },
        { name = "Flute", slash = "/flute" },
        { name = "Drum",  slash = "/drum"  },
    },

    defaults = {
        enabled = true,
        instrument = "/lute",
        minTime = 5000, -- ms
    },
}

local LAM = LibAddonMenu2

-- runtime state
local emoteIndex
local lastPlayTime = 0
local lastFailTime = 0
local lastActionTime = 0
local active = false

-- tuning
local UPDATE_RATE = 300
local FAIL_COOLDOWN = 2000
local ACTION_COOLDOWN = 700

-- =================================
-- UTIL
-- =================================
local function IsBusyBard()
    return IsPlayerMoving()
        or IsPlayerTryingToMove()
        or IsBlockActive()
        or IsMounted()
        or IsUnitDeadOrReincarnating("player")
        or IsUnitSwimming("player")
        or IsInteracting()
        or IsPlayerInteractingWithObject()
end

local function UpdateEmoteIndex()
    emoteIndex = nil
    for i = 1, GetNumEmotes() do
        local slashName = GetEmoteInfo(i)
        if slashName == BCS.vars.instrument then
            emoteIndex = i
            return
        end
    end
end

local function CanPlay()
    if not BCS.vars.enabled then return false end
    if not IsUnitInCombat("player") then return false end
    if IsBusyBard() then return false end

    local now = GetFrameTimeMilliseconds()

    if now - lastActionTime < ACTION_COOLDOWN then return false end
    if now - lastPlayTime < BCS.vars.minTime then return false end
    if now - lastFailTime < FAIL_COOLDOWN then return false end

    return true
end

-- =================================
-- CORE
-- =================================
local function TryPlay()
    if not active or not emoteIndex then return end
    if not CanPlay() then return end

    lastPlayTime = GetFrameTimeMilliseconds()
    local success = PlayEmoteByIndex(emoteIndex)

    if not success then
        lastFailTime = GetFrameTimeMilliseconds()
    end
end

local function Update()
    TryPlay()
end

local function Start()
    if active then return end
    active = true
    EVENT_MANAGER:RegisterForUpdate(BCS.name .. "_Update", UPDATE_RATE, Update)
end

local function Stop()
    active = false
    EVENT_MANAGER:UnregisterForUpdate(BCS.name .. "_Update")
end

-- =================================
-- EVENTS
-- =================================
local function OnCombatState(_, inCombat)
    if inCombat then
        Start()
    else
        Stop()
    end
end

local function OnAbilityUsed()
    lastActionTime = GetFrameTimeMilliseconds()
end

-- =================================
-- MENU (LibAddonMenu)
-- =================================
local function InitializeLAM()
    local panelData = {
        type = "panel",
        name = "Bard Class – Combat Stance",
        displayName = "Bard Class – Combat Stance",
        author = "Frooke",
        version = BCS.version,
        slashCommand = "/bcs",
        registerForRefresh = true,
    }

    LAM:RegisterAddonPanel("BCS_Settings", panelData)

    local instrumentNames = {}
    for _, inst in ipairs(BCS.instruments) do
        instrumentNames[#instrumentNames + 1] = inst.name
    end

    local optionsData = {
        {
            type = "checkbox",
            name = "Enable",
            getFunc = function() return BCS.vars.enabled end,
            setFunc = function(value)
                BCS.vars.enabled = value
                if not value then Stop() end
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Instrument",
            choices = instrumentNames,
            getFunc = function()
                for _, inst in ipairs(BCS.instruments) do
                    if inst.slash == BCS.vars.instrument then
                        return inst.name
                    end
                end
            end,
            setFunc = function(value)
                for _, inst in ipairs(BCS.instruments) do
                    if inst.name == value then
                        BCS.vars.instrument = inst.slash
                        UpdateEmoteIndex()
                        break
                    end
                end
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "Minimum play time (seconds)",
            min = 2,
            max = 30,
            step = 1,
            getFunc = function() return BCS.vars.minTime / 1000 end,
            setFunc = function(value)
                BCS.vars.minTime = value * 1000
            end,
            width = "full",
        },
    }

    LAM:RegisterOptionControls("BCS_Settings", optionsData)
end

-- =================================
-- INIT
-- =================================
local function OnAddOnLoaded(event, addonName)
    if addonName ~= BCS.name then return end

    EVENT_MANAGER:UnregisterForEvent(BCS.name, EVENT_ADD_ON_LOADED)

    BCS.vars = ZO_SavedVars:NewCharacterNameSettings(
    "BardCombatStanceVars",
    1,
    nil,
    BCS.defaults
    )


    UpdateEmoteIndex()
    InitializeLAM()

    EVENT_MANAGER:RegisterForEvent(
        BCS.name,
        EVENT_PLAYER_COMBAT_STATE,
        OnCombatState
    )

    EVENT_MANAGER:RegisterForEvent(
        BCS.name,
        EVENT_ACTION_SLOT_ABILITY_USED,
        OnAbilityUsed
    )
end

EVENT_MANAGER:RegisterForEvent(
    BCS.name,
    EVENT_ADD_ON_LOADED,
    OnAddOnLoaded
)
