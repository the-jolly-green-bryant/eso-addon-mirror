-- EsoCombatLock - initialization

local ECL = EsoCombatLock

local ADDON_NAME = ECL.NAME
local loaded = false

--- Detect legacy account-wide layout (top-level @DisplayName keys) and return
--- a detached copy of settings for the current account to seed server-scoped SVs.
--- Returns nil when already migrated or no legacy data exists.
local function migrateLegacyAccountWideDefaults()
    local sv = _G[ECL.SV_NAME]
    if type(sv) ~= "table" then
        return nil
    end

    local worldName = GetWorldName()
    if type(sv[worldName]) == "table" then
        return nil
    end

    local displayName = GetDisplayName()
    local accountTable = sv[displayName]
    if type(accountTable) ~= "table" then
        return nil
    end
    if accountTable.svMigrated then
        return nil
    end

    local legacy = accountTable["$AccountWide"]
    if type(legacy) ~= "table" then
        return nil
    end

    local copy
    if ZO_DeepTableCopy then
        copy = ZO_DeepTableCopy(legacy)
    else
        copy = ZO_ShallowTableCopy(legacy)
    end

    rawset(accountTable, "svMigrated", true)
    ECL.Chat(string.format("Migrated settings to server-scoped SavedVariables (%s)", worldName))
    return copy
end

local function onAddOnLoaded(_, name)
    if name ~= ADDON_NAME then
        return
    end
    if loaded then
        return
    end
    loaded = true
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    local defaults = ECL.defaults
    local migrated = migrateLegacyAccountWideDefaults()
    if migrated then
        defaults = ZO_ShallowTableCopy(ECL.defaults)
        for key, value in pairs(migrated) do
            defaults[key] = value
        end
    end

    -- Namespace by server so NA / EU / PTS account settings do not overwrite each other.
    ECL.db = ZO_SavedVars:NewAccountWide(ECL.SV_NAME, ECL.SV_VERSION, GetWorldName(), defaults)

    -- Default substitute is none (nil). Drop partial/corrupt saved values.
    local sub = ECL.db.substitute
    if sub ~= nil and (not sub.actionType or not sub.actionId) then
        ECL.db.substitute = nil
    end

    -- One-time: build parkPriority from legacy preferDetectableNoOp / substitute.
    -- (ZO_SavedVars may already have filled parkPriority from defaults.)
    if ECL.MigrateParkPriorityFromLegacy and ECL.MigrateParkPriorityFromLegacy(ECL.db) then
        ECL.Chat("Migrated park priority from legacy settings")
    end
    if ECL.ValidateAndRepairParkPriority and ECL.ValidateAndRepairParkPriority(ECL.db) then
        -- Only notify when the list was actually corrupt (not a quiet deep-copy).
        local list = ECL.db.parkPriority
        if type(list) ~= "table" or #list ~= #ECL.DEFAULT_PARK_PRIORITY then
            ECL.Chat("Repaired park priority list")
        end
    end

    -- indicatorEnabled (legacy) was on/off; indicatorAlwaysVisible is combat-only vs always.
    if ECL.db.indicatorAlwaysVisible == nil and ECL.db.indicatorEnabled ~= nil then
        ECL.db.indicatorAlwaysVisible = false
    end

    ECL.RegisterCommands()
    ECL.RegisterQuickslotKeyListeners()
    ECL.RegisterSettingsPanel()
    ECL.Indicator.Initialize()
    ECL.Indicator.Register()
    ECL.Guard.Register()

    ECL.Chat(string.format("%s v%s loaded — /ecl help", ECL.DISPLAY_NAME, ECL.VERSION))
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, onAddOnLoaded)
