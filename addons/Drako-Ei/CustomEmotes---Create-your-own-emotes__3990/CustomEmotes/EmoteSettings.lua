local CE = CustomEmotes
local internal = CE.internal
local LAM = LibAddonMenu2
local CONS = internal.constants

local settings = {}
internal.settings = settings

settings.settingsContainerReference = "CustomEmotesSettingsSubMenuContainer"
settings.dangerZone = false

function settings.isDangerZoneDeactivated()
    return not settings.dangerZone
end


-- Settings menu
function settings.initializeUI()

    local settingsMenu = {}

    -- Command name, requires a reloadui
    table.insert(settingsMenu, {
        type = "editbox",
        name = CONS.COMMAND_NAME,
        tooltip = CONS.COMMAND_TOOLTIP,
        getFunc = function() return CE.savedVars.command end,
        setFunc = function(value) CE.savedVars.command = value end,
        width = "full",
        warning = CONS.COMMAND_WARNING
    })

    table.insert(settingsMenu, {
        type = "checkbox",
        name = CONS.PREVENT_SERVER_KICK_NAME,
        tooltip = CONS.PREVENT_SERVER_KICK_TOOLTIP,
        warning = CONS.PREVENT_SERVER_KICK_WARNING,
        getFunc = function() return CE.savedVars.preventServerKick end,
        setFunc = function(value) CE.savedVars.preventServerKick = value end,
        width = "full"
    })

    table.insert(settingsMenu, {
        type = "checkbox",
        name = CONS.CREATE_COMMANDS_NAME,
        tooltip = CONS.CREATE_COMMANDS_TOOLTIP,
        getFunc = function() return CE.savedVars.overrideCommands end,
        setFunc = function(value)
            CE.savedVars.overrideCommands = value
            zo_callLater(function() DoCommand("/reloadui") end, 100)
        end,
        width = "full",
        warning = CONS.CREATE_COMMANDS_WARNING,
    })

    table.insert(settingsMenu, {
        type = "checkbox",
        name = CONS.VALIDATE_LOGIC_NAME,
        tooltip = CONS.VALIDATE_LOGIC_TOOLTIP,
        getFunc = function() return CE.savedVars.validatesLogic end,
        setFunc = function(value) CE.savedVars.validatesLogic = value end,
        width = "full",
        warning = CONS.VALIDATE_LOGIC_WARNING,
    })

    -- Add divider
    table.insert(settingsMenu, {
        type = "divider",
        width = "full"
    })

    -- Add caption danger zone
    table.insert(settingsMenu, {
        type = "description",
        text = CONS.DANGER_ZONE_TEXT,
        width = "full"
    })

    -- Add checkbox to activate danger zone
    table.insert(settingsMenu, {
        type = "checkbox",
        name = CONS.DANGER_ZONE_CHECKBOX_NAME,
        getFunc = function() return settings.dangerZone end,
        setFunc = function(value) settings.dangerZone = value end,
        warning = CONS.DANGER_ZONE_WARNING_CHECKBOX,
        width = "full",
    })

    -- Reset addon button
    table.insert(settingsMenu, {
        type = "button",
        name = CONS.RESET_SAVED_VARS_NAME,
        isDangerous = true,
        warning = CONS.RESET_SAVED_VARS_WARNING,
        func = function()
            internal.restoreDefaultVars()
            PlaySound(SOUNDS.DUEL_START)
            SCENE_MANAGER:HideCurrentScene()
            zo_callLater(function() DoCommand("/headache") end, 100)
            zo_callLater(function() DoCommand("/reloadui") end, 1500)
        end,
        width = "half",
        disabled = settings.isDangerZoneDeactivated
    })

    -- Delete all emotes button
    table.insert(settingsMenu, {
        type = "button",
        name = CONS.DELETE_ALL_EMOTES_NAME,
        isDangerous = true,
        warning = CONS.DELETE_ALL_EMOTES_WARNING,
        func = function()
            for emoteName, _ in pairs(CE.savedVars.emotes) do
                internal.unregisterEmoteCommand(emoteName)
            end
            CE.savedVars.emotes = {}
            PlaySound(SOUNDS.DUEL_START)
            settings.dangerZone = false
            SCENE_MANAGER:HideCurrentScene()
            zo_callLater(function() DoCommand("/crying") end, 100)
            zo_callLater(function() DoCommand(CE.savedVars.command) end, 2000)
        end,
        width = "half",
        disabled = settings.isDangerZoneDeactivated
    })

    return settingsMenu

end