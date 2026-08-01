local CE = CustomEmotes
local internal = CE.internal
local LAM = LibAddonMenu2
local interpreter = internal.interpreter
local CONS = internal.constants

local import = {}
internal.import = import

import.importContainerReference = "CustomEmotesImportSubMenuContainer"

import.importName = ""
import.importDescription = ""
import.importText = ""

-- Util function to check if the import can be reset
function import.checkCanResetImport()
    if import.importText ~= nil and import.importText ~= "" then
        return false
    end
    if import.importName ~= nil and import.importName ~= "" then
        return false
    end
    if import.importDescription ~= nil and import.importDescription ~= "" then
        return false
    end
    return true
end

-- Util function to check if the import can be done
function import.checkIfCanImport()
    if import.importText == nil or import.importText == "" then
        return true
    end
    if import.importName == nil or import.importName == "" then
        return true
    end
    if import.importDescription == nil or import.importDescription == "" then
        return true
    end
    return false
end

-- Util function to show import
function import.showImport(name, description, text)
    import.importName = name
    import.importDescription = description
    import.importText = text
    LAM.util.RequestRefreshIfNeeded(_G[import.importContainerReference])
end

-- Util function to reset the import window
function import.resetImport()
    import.importName = ""
    import.importDescription = ""
    import.importText = ""
    LAM.util.RequestRefreshIfNeeded(_G[import.importContainerReference])
end

-- Util function to import an emote
function import.importEmote()

    local lowerName = string.lower(import.importName)

    -- Parse the emote
    local emote = {
        name = lowerName,
        description = import.importDescription,
        actions = {}
    }

   emote.actions = interpreter.deserialize(import.importText);

   if emote.actions == nil then
        internal.editor.showErrorDialog({CONS.IMPORT_FAILURE_MESSAGE})
        return
    end

    -- Validate the emote
    local errors = interpreter.getErrorsFromEmote(emote)
    if #errors > 0 then
        internal.editor.showErrorDialog(errors)
        return
    end

    internal.editor.checkForDuplicatesOnSave(emote.name, function(dialog)
        CustomEmotes.internal.saveEmote(emote)
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.ITEM_MONEY_CHANGED, CONS.IMPORT_SUCCESS_MESSAGE)
        CustomEmotes.internal.import.resetImport()
    end)

end

-- Import initialization
function import.initializeUI()
    local controls = {}

    -- Reset button
    table.insert(controls, {
        type = "button",
        name = CONS.IMPORT_RESET_BUTTON_NAME,
        tooltip = CONS.IMPORT_RESET_BUTTON_TOOLTIP,
        isDangerous = true,
        warning = CONS.IMPORT_RESET_BUTTON_WARNING,
        func = import.resetImport,
        disabled = import.checkCanResetImport,
        width = "full"
    })

    table.insert(controls, {
        type = "description",
        text = CONS.IMPORT_DESCRIPTION_TEXT
    })

    -- Emote name control
    table.insert(controls, {
        type = "editbox",
        name = CONS.IMPORT_EMOTE_NAME,
        tooltip = string.format(CONS.IMPORT_EMOTE_NAME_TOOLTIP, CE.savedVars.command),
        getFunc = function() return import.importName end,
        setFunc = function(value) import.importName = value end,
        width = "full",
    })

    -- Actions description
    table.insert(controls, {
        type = "editbox",
        title = nil,
        width = "full",
        name = CONS.IMPORT_DESCRIPTION_NAME,
        tooltip = CONS.IMPORT_DESCRIPTION_TOOLTIP,
        getFunc = function() return import.importDescription end,
        setFunc = function(value) import.importDescription = value end,
        isMultiline = true
    })

    table.insert(controls, {
        type = "editbox",
        name = CONS.IMPORT_EMOTE_CODE_NAME,
        getFunc = function() return import.importText end,
        setFunc = function(value) import.importText = value end,
        isMultiline = true,
        isExtraWide = true,
        width = "full",
    })

    table.insert(controls, {
        type = "button",
        name = CONS.IMPORT_BUTTON_NAME,
        func = import.importEmote,
        disabled = import.checkIfCanImport,
        width = "full",
    })

    return controls
end