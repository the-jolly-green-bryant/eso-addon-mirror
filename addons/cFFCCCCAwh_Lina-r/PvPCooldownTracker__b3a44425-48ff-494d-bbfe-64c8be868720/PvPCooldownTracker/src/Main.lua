-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Track cooldowns for various sets
--
-- Main.lua
-- -----------------------------------------------------------------------------
PvPCooldownTracker            = PvPCooldownTracker or {}
PvPCooldownTracker.name       = "PvPCooldownTracker"
PvPCooldownTracker.version    = "1.1.1"
PvPCooldownTracker.dbVersion  = 1
PvPCooldownTracker.slash      = "/pvpcooldowntracker"
PvPCooldownTracker.prefix     = "[PvPCooldownTracker] "
PvPCooldownTracker.HUDHidden  = false
PvPCooldownTracker.ForceShow  = false
PvPCooldownTracker.isInCombat = false
PvPCooldownTracker.isDead     = false

local EM = EVENT_MANAGER
local STARTUP_RETRY_INTERVAL_MS = 50
local STARTUP_RETRY_MAX_ATTEMPTS = 40

-- -----------------------------------------------------------------------------
-- Level of debug output
-- 1: Low    - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High   - Everything
PvPCooldownTracker.debugMode = 0
-- -----------------------------------------------------------------------------

function PvPCooldownTracker:Trace(debugLevel, ...)
    local level = tonumber(debugLevel) or 0
    local mode = tonumber(PvPCooldownTracker.debugMode) or 0

    if level <= mode then
        local message = zo_strformat(...)
        d((PvPCooldownTracker.prefix or "[PvPCooldownTracker] ") .. message)
    end
end

local function FallbackSetCombatStateDisplay()
    if PvPCooldownTracker.UI and type(PvPCooldownTracker.UI.SetCombatStateDisplay) == "function" then
        PvPCooldownTracker.UI:SetCombatStateDisplay()
    end
end

local function FallbackRegisterTrackingEvents()
    local eventNamespace = tostring(PvPCooldownTracker.name or "PvPCooldownTracker")

    EM:RegisterForEvent(eventNamespace, EVENT_PLAYER_ALIVE, function()
        PvPCooldownTracker.isDead = false
        FallbackSetCombatStateDisplay()
    end)
    EM:RegisterForEvent(eventNamespace, EVENT_PLAYER_DEAD, function()
        PvPCooldownTracker.isDead = true
        FallbackSetCombatStateDisplay()
    end)

    local preferences = PvPCooldownTracker.preferences or {}
    if not preferences.showOutsideCombat then
        EM:RegisterForEvent(eventNamespace .. "COMBAT", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
            PvPCooldownTracker.isInCombat = inCombat
            FallbackSetCombatStateDisplay()
        end)
    end

    d((PvPCooldownTracker.prefix or "[PvPCooldownTracker] ") .. "Fallback tracking event registration active.")
end

local function EnsureTrackingFallback()
    PvPCooldownTracker.Tracking = PvPCooldownTracker.Tracking or {}

    if type(PvPCooldownTracker.Tracking.RegisterCombatEvent) ~= "function" then
        PvPCooldownTracker.Tracking.RegisterCombatEvent = function()
            local eventNamespace = tostring(PvPCooldownTracker.name or "PvPCooldownTracker")
            EM:RegisterForEvent(eventNamespace .. "COMBAT", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
                PvPCooldownTracker.isInCombat = inCombat
                FallbackSetCombatStateDisplay()
            end)
        end
    end

    if type(PvPCooldownTracker.Tracking.UnregisterCombatEvent) ~= "function" then
        PvPCooldownTracker.Tracking.UnregisterCombatEvent = function()
            local eventNamespace = tostring(PvPCooldownTracker.name or "PvPCooldownTracker")
            EM:UnregisterForEvent(eventNamespace .. "COMBAT", EVENT_PLAYER_COMBAT_STATE)
        end
    end

    if type(PvPCooldownTracker.Tracking.RegisterEvents) ~= "function" then
        PvPCooldownTracker.Tracking.RegisterEvents = FallbackRegisterTrackingEvents
    end

    if type(PvPCooldownTracker.Tracking.EnableTrackingForSet) ~= "function" then
        PvPCooldownTracker.Tracking.EnableTrackingForSet = function(setKey, enabled)
            local setData = PvPCooldownTracker.Data and PvPCooldownTracker.Data.Sets and PvPCooldownTracker.Data.Sets[setKey]
            if not setData then
                return
            end

            setData.enabled = enabled == true
            if not enabled then
                setData.onCooldown = false
                setData.timeOfProc = 0
            end

            if PvPCooldownTracker.UI and type(PvPCooldownTracker.UI.Draw) == "function" then
                PvPCooldownTracker.UI.Draw(setKey)
            end

            FallbackSetCombatStateDisplay()
        end
    end
end

local function GetModuleStatus()
    return {
        data = type(PvPCooldownTracker.Data),
        sets = type(PvPCooldownTracker.Data and PvPCooldownTracker.Data.Sets),
        defaults = type(PvPCooldownTracker.Defaults),
        settings = type(PvPCooldownTracker.Settings),
        settingsInit = type(PvPCooldownTracker.Settings and PvPCooldownTracker.Settings.Init),
        ui = type(PvPCooldownTracker.UI),
        tracking = type(PvPCooldownTracker.Tracking),
        registerEvents = type(PvPCooldownTracker.Tracking and PvPCooldownTracker.Tracking.RegisterEvents),
        enableTrackingForSet = type(PvPCooldownTracker.Tracking and PvPCooldownTracker.Tracking.EnableTrackingForSet),
    }
end

local function HasRequiredModules()
    local status = GetModuleStatus()
    return status.sets == "table"
        and status.defaults == "table"
        and status.settingsInit == "function"
    and status.ui == "table"
end

local function LogModuleStatus(prefix)
    local status = GetModuleStatus()
    d(string.format(
        "%sModule status: Data=%s Sets=%s Defaults=%s Settings=%s Settings.Init=%s UI=%s Tracking=%s RegisterEvents=%s EnableTrackingForSet=%s",
        prefix or "[PvPCooldownTracker] ",
        status.data,
        status.sets,
        status.defaults,
        status.settings,
        status.settingsInit,
        status.ui,
        status.tracking,
        status.registerEvents,
        status.enableTrackingForSet
    ))
end

local function FinishInitialize(addonId)
    if PvPCooldownTracker.initialized then
        return
    end

    PvPCooldownTracker.initialized = true
    PvPCooldownTracker.name = addonId
    PvPCooldownTracker.prefix = PvPCooldownTracker.prefix or "[PvPCooldownTracker] "
    local prefix = PvPCooldownTracker.prefix
    local trace = PvPCooldownTracker.Trace

    if type(trace) == "function" then
        trace(PvPCooldownTracker, 1, "PvPCooldownTracker Loaded")
    end

    for _, set in pairs(PvPCooldownTracker.Data.Sets) do
        set.enabled = false
        set.onCooldown = false
        set.timeOfProc = 0
        set.justProcced = false
    end

    PvPCooldownTracker.Defaults:Generate()
    PvPCooldownTracker.preferences = ZO_SavedVars:NewAccountWide("CooldownsVariables1", PvPCooldownTracker.dbVersion, nil, PvPCooldownTracker.Defaults.Get())

    local legacyCharacter = ZO_SavedVars:New("CooldownsVariables2", PvPCooldownTracker.dbVersion, nil, PvPCooldownTracker.Defaults.GetCharacter())
    PvPCooldownTracker.character = ZO_SavedVars:NewAccountWide("CooldownsVariables2AccountWide", PvPCooldownTracker.dbVersion, nil, PvPCooldownTracker.Defaults.GetCharacter())

    if not PvPCooldownTracker.character.migratedFromCharacterWide then
        if type(PvPCooldownTracker.character.set) ~= "table" then
            PvPCooldownTracker.character.set = {}
        end

        if type(legacyCharacter) == "table" and type(legacyCharacter.set) == "table" then
            for setKey, setEnabled in pairs(legacyCharacter.set) do
                if PvPCooldownTracker.character.set[setKey] == nil then
                    PvPCooldownTracker.character.set[setKey] = setEnabled
                end
            end
        end

        PvPCooldownTracker.character.upgradedv154 = PvPCooldownTracker.character.upgradedv154
            or (type(legacyCharacter) == "table" and legacyCharacter.upgradedv154)
            or false
        PvPCooldownTracker.character.migratedFromCharacterWide = true
    end

    PvPCooldownTracker:UpgradeSavedVars()

    if PvPCooldownTracker.Settings and type(PvPCooldownTracker.Settings.Upgrade) == "function" then
        PvPCooldownTracker.Settings.Upgrade()
    end

    if PvPCooldownTracker.EquippedSets and type(PvPCooldownTracker.EquippedSets.RestoreCustomSets) == "function" then
        local restoredCount = PvPCooldownTracker.EquippedSets.RestoreCustomSets()
        if restoredCount > 0 then
            d(prefix .. string.format("Restored %d custom set entries from SavedVariables.", restoredCount))
        end
    end

    PvPCooldownTracker:SanitizeSavedVars()
    PvPCooldownTracker.debugMode = PvPCooldownTracker.preferences.debugMode
    SLASH_COMMANDS[PvPCooldownTracker.slash or "/pvpcooldowntracker"] = PvPCooldownTracker.UI.SlashCommand

    PvPCooldownTracker.isInCombat = IsUnitInCombat("player")
    PvPCooldownTracker.isDead = IsUnitDead("player")

    if PvPCooldownTracker.Settings and type(PvPCooldownTracker.Settings.Init) == "function" then
        PvPCooldownTracker.Settings.Init()
    else
        d(prefix .. "Settings module is unavailable; skipping settings initialization.")
    end

    EnsureTrackingFallback()

    local trackingType = type(PvPCooldownTracker.Tracking)
    local registerEventsType = type(PvPCooldownTracker.Tracking and PvPCooldownTracker.Tracking.RegisterEvents)
    if type(trace) == "function" then
        trace(PvPCooldownTracker, 0, "Tracking table type=<<1>>, RegisterEvents type=<<2>>", trackingType, registerEventsType)
    else
        d(prefix .. "Tracking table type=" .. trackingType .. ", RegisterEvents type=" .. registerEventsType)
    end

    if PvPCooldownTracker.Tracking and type(PvPCooldownTracker.Tracking.RegisterEvents) == "function" then
        PvPCooldownTracker.Tracking.RegisterEvents()
    else
        d(prefix .. "Tracking RegisterEvents unavailable; using fallback event registration.")
        FallbackRegisterTrackingEvents()
    end

    EM:AddFilterForEvent(addonId .. "_1234", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    local LEB = LibEquipmentBonus
    if LEB and type(LEB.Init) == "function" and PvPCooldownTracker.Tracking and type(PvPCooldownTracker.Tracking.EnableTrackingForSet) == "function" then
        local Equip = LEB:Init(addonId)
        if Equip and type(Equip.Register) == "function" then
            Equip:Register(PvPCooldownTracker.Tracking.EnableTrackingForSet)
        end
    else
        d(prefix .. "LibEquipmentBonus or tracking callback unavailable; equipment registration skipped.")
    end

    if type(trace) == "function" then
        trace(PvPCooldownTracker, 2, "Finished Initialize()")
    else
        d(prefix .. "Finished Initialize()")
    end
end

-- -----------------------------------------------------------------------------
-- Startup
-- -----------------------------------------------------------------------------
function PvPCooldownTracker.Initialize(event, addonName)
    local addonId = PvPCooldownTracker.name or "PvPCooldownTracker"
    if addonName ~= addonId then return end

    EM:UnregisterForEvent(addonId, EVENT_ADD_ON_LOADED)
    PvPCooldownTracker.name = addonId
    PvPCooldownTracker.prefix = PvPCooldownTracker.prefix or "[PvPCooldownTracker] "

    if HasRequiredModules() then
        FinishInitialize(addonId)
        return
    end

    LogModuleStatus(PvPCooldownTracker.prefix)
    d(PvPCooldownTracker.prefix .. "Deferring startup until required modules are ready.")

    local attempts = 0
    EM:RegisterForUpdate(addonId .. "_StartupRetry", STARTUP_RETRY_INTERVAL_MS, function()
        attempts = attempts + 1

        if HasRequiredModules() then
            EM:UnregisterForUpdate(addonId .. "_StartupRetry")
            d(PvPCooldownTracker.prefix .. "Deferred startup resolved after " .. tostring(attempts) .. " retries.")
            FinishInitialize(addonId)
            return
        end

        if attempts >= STARTUP_RETRY_MAX_ATTEMPTS then
            EM:UnregisterForUpdate(addonId .. "_StartupRetry")
            LogModuleStatus(PvPCooldownTracker.prefix)
            d(PvPCooldownTracker.prefix .. "Startup failed: required modules never became available.")
        end
    end)
end
function PvPCooldownTracker:UpgradeSavedVars()
    local sv = PvPCooldownTracker.preferences
    local currentVersion = 2
    local baseDefaults = PvPCooldownTracker.Defaults.Get()

    if not sv.version then
        sv.version = 1
    end

    -- Upgrade path from v1 → v2
    if sv.version == 1 then
        d("[PvPCooldownTracker] Upgrading SavedVariables from v1 to v2...")

        for setKey, saved in pairs(sv.sets or {}) do
            local defaults = baseDefaults.sets[setKey] or {}

            -- Add new fields if missing
            if saved.texture == nil then
                saved.texture = defaults.texture or "EsoUI/Art/Icons/icon_missing.dds"
            end
            if saved.label == nil then
                saved.label = defaults.label or setKey
            end
            if saved.cooldown == nil then
                saved.cooldown = defaults.cooldown or true
            end
        end

        sv.version = 2
    end

    if sv.version < currentVersion then
        sv.version = currentVersion
    end
end
function PvPCooldownTracker:SanitizeSavedVars()
    local defaults = PvPCooldownTracker.Defaults.Get()

    -- Loop through each tracked set
    for key, defaultSet in pairs(defaults.sets) do
        local saved = PvPCooldownTracker.preferences.sets[key]

        -- If missing, create it fresh from defaults
        if type(saved) ~= "table" then
            PvPCooldownTracker.preferences.sets[key] = ZO_ShallowTableCopy(defaultSet)
            saved = PvPCooldownTracker.preferences.sets[key]
        end

        -- Validate position
        local screenW, screenH = GuiRoot:GetWidth(), GuiRoot:GetHeight()
        if not saved.x or saved.x < 0 or saved.x > screenW then
            saved.x = defaultSet.x
        end
        if not saved.y or saved.y < 0 or saved.y > screenH then
            saved.y = defaultSet.y
        end

        -- Validate size
        if not saved.size or saved.size < 16 then
            saved.size = defaultSet.size
        end

        if type(saved.sounds) ~= "table" then
            saved.sounds = ZO_DeepTableCopy(defaultSet.sounds)
        else
            if type(saved.sounds.onProc) ~= "table" then
                saved.sounds.onProc = ZO_ShallowTableCopy(defaultSet.sounds.onProc)
            end
            if type(saved.sounds.onReady) ~= "table" then
                saved.sounds.onReady = ZO_ShallowTableCopy(defaultSet.sounds.onReady)
            end
        end
    end

    if not PvPCooldownTracker.preferences.labelFont then
        PvPCooldownTracker.preferences.labelFont = defaults.labelFont
    end
    if not PvPCooldownTracker.preferences.timerFont then
        PvPCooldownTracker.preferences.timerFont = defaults.timerFont
    end
    if type(PvPCooldownTracker.preferences.style) ~= "table" then
        PvPCooldownTracker.preferences.style = ZO_DeepTableCopy(defaults.style)
    else
        for styleKey, styleValue in pairs(defaults.style) do
            if PvPCooldownTracker.preferences.style[styleKey] == nil then
                if type(styleValue) == "table" then
                    PvPCooldownTracker.preferences.style[styleKey] = ZO_DeepTableCopy(styleValue)
                else
                    PvPCooldownTracker.preferences.style[styleKey] = styleValue
                end
            end
        end
    end
end
-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EM:RegisterForEvent(PvPCooldownTracker.name, EVENT_ADD_ON_LOADED, PvPCooldownTracker.Initialize)