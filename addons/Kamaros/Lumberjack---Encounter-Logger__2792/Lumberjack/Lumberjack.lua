Lumberjack = Lumberjack or {}
Lumberjack.name = "Lumberjack"
Lumberjack.version = "1.0.7"
Lumberjack.variableVersion = 1
Lumberjack.defaultSavedVariables = {
    veteranOnly = true,
    promptInTrials = true,
    promptInArenas = true,
    promptInDungeons = false
}

---------------------------------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------------------------------

local TRIAL_ZONE_IDS = {
    [636] = true, -- Hel Ra Citadel
    [638] = true, -- Aetherian Archive
    [639] = true, -- Sanctum Ophidia
    [725] = true, -- Maw of Lorkhaj
    [975] = true, -- Halls of Fabrication
    [1000] = true, -- Asylum Sanctorium
    [1051] = true, -- Cloudrest
    [1121] = true, -- Sunspire
    [1196] = true, -- Kyne's Aegis
    [1263] = true, -- Rockgrove
	[1344] = true, -- DSR
	[1427] = true, -- SE
    [1548] = true, -- OC
    [1478] = true -- LC
}

local ARENA_ZONE_IDS = {
    [635] = true, -- Dragonstar Arena
    [677] = true, -- Maelstrom Arena
    [1082] = true, -- Blackrose Prison
    [1227] = true -- Vateshran Hollows
}

local ENABLE_ENCOUNTER_LOG_DIALOG_NAME = Lumberjack.name .. "EnableEncounterLogDialog"
local DISABLE_ENCOUNTER_LOG_DIALOG_NAME = Lumberjack.name .. "DisableEncounterLogDialog"

---------------------------------------------------------------------------------------------------
-- Utilities
---------------------------------------------------------------------------------------------------

local function isVeteranDifficulty()
    return GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN
end

local function isTrial(zoneId)
    return TRIAL_ZONE_IDS[zoneId] or false
end

local function isArena(zoneId)
    return ARENA_ZONE_IDS[zoneId] or false
end

local function getCurrentZoneId()
    return GetZoneId(GetUnitZoneIndex("player"))
end

local function isPlayerInSupportedZone()
    local zoneId = getCurrentZoneId()
    return (Lumberjack.savedVariables.promptInTrials and isTrial(zoneId)) or
        (Lumberjack.savedVariables.promptInArenas and isArena(zoneId)) or
        -- Unintuitively, IsUnitInDungeon("player") returns true not only inside of dungeons, but also in trials and arenas
        -- As such, we need to explicitly exclude trials and arenas to evaluate if the player is within a dungeon or not
        (Lumberjack.savedVariables.promptInDungeons and IsUnitInDungeon("player") and not isTrial(zoneId) and not isArena(zoneId))
end

local function isPlayerInSupportedInstance()
    return isPlayerInSupportedZone() and (isVeteranDifficulty() or not Lumberjack.savedVariables.veteranOnly)
end

---------------------------------------------------------------------------------------------------
-- Event handlers
---------------------------------------------------------------------------------------------------

function Lumberjack.onEnableEncounterLog(dialog)
    SetEncounterLogEnabled(true)
    d("[Lumberjack] Encounter logging enabled")
end

function Lumberjack.onDisableEncounterLog(dialog)
    SetEncounterLogEnabled(false)
    d("[Lumberjack] Encounter logging disabled")
end

local currentZoneId = nil
local disableEncounterLogDialogShown = false

function Lumberjack.onPlayerActivated()
    local inSupportedInstance = isPlayerInSupportedInstance()
    local encounterLogEnabled = IsEncounterLogEnabled()
    local zoneId = getCurrentZoneId()

    if inSupportedInstance then
        if zoneId ~= currentZoneId then
            if encounterLogEnabled then
                d("[Lumberjack] Encounter logging is currently enabled")
            else
                ZO_Dialogs_ShowDialog(ENABLE_ENCOUNTER_LOG_DIALOG_NAME)
            end
        end
        disableEncounterLogDialogShown = false
    elseif encounterLogEnabled and not disableEncounterLogDialogShown then
        ZO_Dialogs_ShowDialog(DISABLE_ENCOUNTER_LOG_DIALOG_NAME)
        disableEncounterLogDialogShown = true
    end

    currentZoneId = zoneId
end

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function Lumberjack.loadSavedVariables()
    Lumberjack.savedVariables = ZO_SavedVars:NewAccountWide("LumberjackSavedVariables", Lumberjack.variableVersion, nil, Lumberjack.defaultSavedVariables)
end

function Lumberjack.initializeMenu()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "Lumberjack",
        displayName = "Lumberjack - Encounter Logger",
        author = "Kamaros",
        version = Lumberjack.version
    }
    LAM:RegisterAddonPanel(Lumberjack.name .. "Menu", panelData)

    local optionsData = {
        {
            type = "checkbox",
            name = "Show Prompt On Veteran Only",
            getFunc = function() return Lumberjack.savedVariables.veteranOnly end,
            setFunc = function(value) Lumberjack.savedVariables.veteranOnly = value end
        },
        {
            type = "header",
            name = "Locations"
        },
        {
            type = "checkbox",
            name = "Trials",
            tooltip = "Prompt will be shown when entering a trial",
            getFunc = function() return Lumberjack.savedVariables.promptInTrials end,
            setFunc = function(value) Lumberjack.savedVariables.promptInTrials = value end
        },
        {
            type = "checkbox",
            name = "Arenas",
            tooltip = "Prompt will be shown when entering an arena",
            getFunc = function() return Lumberjack.savedVariables.promptInArenas end,
            setFunc = function(value) Lumberjack.savedVariables.promptInArenas = value end
        },
        {
            type = "checkbox",
            name = "Dungeons",
            tooltip = "Prompt will be shown when entering a dungeon",
            getFunc = function() return Lumberjack.savedVariables.promptInDungeons end,
            setFunc = function(value) Lumberjack.savedVariables.promptInDungeons = value end
        }
    }
    LAM:RegisterOptionControls(Lumberjack.name .. "Menu", optionsData)
end

function Lumberjack.initializeDialogs()
    ESO_Dialogs[ENABLE_ENCOUNTER_LOG_DIALOG_NAME] = {
        canQueue = true,
        uniqueIdentifier = ENABLE_ENCOUNTER_LOG_DIALOG_NAME,
        title = {
            text = Lumberjack.name
        },
        mainText = {
            text = "Enable encounter logging?"
        },
        buttons = {
            [1] = {
                text = SI_DIALOG_YES,
                callback = Lumberjack.onEnableEncounterLog
            },
            [2] = {
                text = SI_DIALOG_NO,
                callback = function(dialog) end
            }
        },
        setup = function(dialog, data) end
    }

    ESO_Dialogs[DISABLE_ENCOUNTER_LOG_DIALOG_NAME] = {
        canQueue = true,
        uniqueIdentifier = DISABLE_ENCOUNTER_LOG_DIALOG_NAME,
        title = {
            text = Lumberjack.name
        },
        mainText = {
            text = "Disable encounter logging?"
        },
        buttons = {
            [1] = {
                text = SI_DIALOG_YES,
                callback = Lumberjack.onDisableEncounterLog
            },
            [2] = {
                text = SI_DIALOG_NO,
                callback = function(dialog) end
            }
        },
        setup = function(dialog, data) end
    }
end

function Lumberjack.registerForEvents()
    EVENT_MANAGER:RegisterForEvent(Lumberjack.name .. "PlayerActivated", EVENT_PLAYER_ACTIVATED, Lumberjack.onPlayerActivated)
end

function Lumberjack.onAddOnLoaded(eventCode, addonName)
    if addonName ~= Lumberjack.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(Lumberjack.name, eventCode)

    Lumberjack.loadSavedVariables()
    Lumberjack.initializeMenu()
    Lumberjack.initializeDialogs()
    Lumberjack.registerForEvents()
end

EVENT_MANAGER:RegisterForEvent(Lumberjack.name, EVENT_ADD_ON_LOADED, Lumberjack.onAddOnLoaded)