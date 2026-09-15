-- ESO Adventurer Suite
-- v0.29.550 - account-wide settings load-order / HUD layout persistence fix.
-- The account-wide SavedVariables profile must become EPC.saved before any
-- EVENT_ADD_ON_LOADED initializer creates HUD controls. Otherwise a /reloadui
-- can build overlays from the old character/default profile and visually reset
-- their positions before this module swaps the saved-table pointer.

local EPC = ESOProgressionCoach
if not EPC then return end

local EVENT_NAME = (EPC.name or "ESOAdventurerSuite") .. "_AccountWideSettings029514"
local SAVED_NAME = "ESOProgressionCoachSavedVars"
local MIGRATION_KEY = "accountWideMigration029514"

local function deepCopyInto(source, destination, seen)
    if type(source) ~= "table" or type(destination) ~= "table" then return end
    seen = seen or {}
    if seen[source] then return end
    seen[source] = true

    for key, value in pairs(source) do
        if key ~= MIGRATION_KEY then
            if type(value) == "table" then
                if type(destination[key]) ~= "table" then destination[key] = {} end
                deepCopyInto(value, destination[key], seen)
            else
                destination[key] = value
            end
        end
    end
end

local function migrateToAccountWide()
    if type(ZO_SavedVars) ~= "table" or type(ZO_SavedVars.NewAccountWide) ~= "function" then return false end

    local characterSettings = EPC.saved
    local version = tonumber(EPC.savedVersion) or 1
    local defaults = type(EPC.defaults) == "table" and EPC.defaults or {}

    local ok, accountSettings = pcall(ZO_SavedVars.NewAccountWide, ZO_SavedVars, SAVED_NAME, version, nil, defaults)
    if not ok or type(accountSettings) ~= "table" then return false end

    -- First login after the original migration update: seed the shared profile
    -- from the currently loaded character exactly once. Never copy defaults back
    -- over an already-migrated account-wide profile on later reloads.
    if accountSettings[MIGRATION_KEY] ~= true then
        if type(characterSettings) == "table" and characterSettings ~= accountSettings then
            deepCopyInto(characterSettings, accountSettings)
        end
        accountSettings[MIGRATION_KEY] = true
    end

    -- This assignment is the important v0.29.550 change: it happens while addon
    -- files are still loading, before Core's EVENT_ADD_ON_LOADED callback can
    -- create any HUD controls. Every module therefore reads the same persisted
    -- account-wide coordinates from its very first SetAnchor call.
    EPC.saved = accountSettings
    EPC.accountWideSettings029514 = true
    return true
end

-- v0.29.550: perform the handoff immediately. Waiting for EVENT_ADD_ON_LOADED
-- allowed earlier-registered Core initialization to create HUD elements from the
-- obsolete character/default table, which made /reloadui look like Reset Layout.
local migratedEarly = migrateToAccountWide()

-- Keep one addon-loaded retry only for unusual clients where ZO_SavedVars was not
-- available during file execution. The normal path above is already complete.
local function onAddonLoaded(_, addonName)
    if addonName ~= (EPC.name or "ESOAdventurerSuite") then return end
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAME, EVENT_ADD_ON_LOADED)
    if not migratedEarly then migrateToAccountWide() end
end

if not migratedEarly and EVENT_ADD_ON_LOADED and EVENT_MANAGER then
    EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_ADD_ON_LOADED, onAddonLoaded)
end
