-- Shortcuts
local CE = CustomEmotes
local LAM = LibAddonMenu2
local internal = CE.internal
local actions = CE.actions
local CONS = internal.constants

-- Initializes the editor
local editor = internal.editor or {}
internal.editor = editor

-- Initializes the types of actions
local actionsUI = {
    [actions.PLAY] = {
        id = CE.actions.PLAY,
        caption = CONS.ACTION_PLAY_CAPTION,
        defaultValue = "greet",
        componentBuilder = nil
    },
    [actions.WAIT] = {
        id = CE.actions.WAIT,
        caption = CONS.ACTION_WAIT_CAPTION,
        defaultValue = 1000,
        componentBuilder = nil
    },
    [actions.JUMP] = {
        id = CE.actions.JUMP,
        caption = CONS.ACTION_JUMP_CAPTION,
        defaultValue = 1,
        componentBuilder = nil
    },
    [actions.JUMP_FIRST] = {
        id = CE.actions.JUMP_FIRST,
        caption = CONS.ACTION_JUMP_FIRST_CAPTION,
        defaultValue = nil,
        componentBuilder = nil
    },
    [actions.REPEAT_FROM] = {
        id = CE.actions.REPEAT_FROM,
        caption = CONS.ACTION_REPEAT_FROM_CAPTION,
        defaultValue = {
            action = 1,
            times = 1
        },
        componentBuilder = nil
    },
    [actions.INTERRUPT] = {
        id = CE.actions.INTERRUPT,
        caption = CONS.ACTION_INTERRUPT_CAPTION,
        defaultValue = 0,
        componentBuilder = nil
    },
    [actions.PERSONALITY] = {
        id = CE.actions.PERSONALITY,
        caption = CONS.ACTION_PERSONALITY_CAPTION,
        defaultValue = 0,
        componentBuilder = nil
    },
    [actions.EMPTY_LINE] = {
        id = CE.actions.EMPTY_LINE,
        caption = CONS.ACTION_EMPTY_LINE_CAPTION,
        defaultValue = nil,
        componentBuilder = nil
    },
    [actions.MOVE_UP] = {
        id = CE.actions.MOVE_UP,
        caption = CONS.ACTION_MOVE_UP_CAPTION,
        defaultValue = nil,
        componentBuilder = nil
    },
    [actions.MOVE_DOWN] = {
        id = CE.actions.MOVE_DOWN,
        caption = CONS.ACTION_MOVE_DOWN_CAPTION,
        defaultValue = nil,
        componentBuilder = nil
    },
    [actions.DUPLICATE] = {
        id = CE.actions.DUPLICATE,
        caption = CONS.ACTION_DUPLICATE_CAPTION,
        defaultValue = nil,
        componentBuilder = nil
    },
    [actions.DELETE] = {
        id = CE.actions.DELETE,
        caption = CONS.ACTION_DELETE_CAPTION,
        defaultValue = nil,
        componentBuilder = nil
    }
}

editor.editorContainerReference = "CustomEmotesCreateEmoteSubMenuContainer"
editor.componentReference = "CustomEmotesCreateEmoteSubMenu"
editor.savedControls = {}
editor.isDirty = true
editor.currentEmote = {
    name = "",
    description = "",
    actions = {}
}

local COMPONENT_OFFSET_LEFT = 270
local COMPONENT_OFFSET_RIGHT = 10


-- Util function to display a list of errors
function editor.showErrorDialog(errors)
    local firstErrors = {}
    for i = 1, 5 do
        if errors[i] == nil then
            break
        end
        table.insert(firstErrors, errors[i])
    end
    local numberOfErrors = #errors
    if numberOfErrors > 5 then
        table.insert(firstErrors, zo_strformat(CONS.EDITOR_ERROR_DIALOG_MORE_ERRORS, numberOfErrors - 5))
    end
    local errorText = table.concat(firstErrors, "\n")

    ESO_Dialogs["CustomEmotesErrorDialogEditor"] = {
        title = { text = CONS.EDITOR_ERROR_DIALOG_TITLE },
        mainText = { text = CONS.EDITOR_ERROR_DIALOG_MAIN_TEXT .. errorText },
        buttons = {
            [1] = {
                text = SI_OK,
                callback = function(dialog) end,
            },
        },
    }
    ZO_Dialogs_ShowDialog("CustomEmotesErrorDialogEditor") 
end

-- Util function to reset the whole editor
function editor.refreshEditorInputs()
    LAM.util.RequestRefreshIfNeeded(_G[editor.editorContainerReference])
end

-- Util function to validate if the action type and index is correct
function editor.invalidActionType(index, type)
    if index < 1 or index > #editor.currentEmote.actions then
        return true
    end
    local currentAction = editor.currentEmote.actions[index]
    if currentAction.type ~= type then
        return true
    end
    return false
end

-- Util function to refresh the editor
function editor.refreshActionEditor()
    editor.isDirty = true
    editor.refreshEmoteEditorInterface(_G[editor.componentReference])
end

-- Util function to check if the emote can be saved
function editor.checkCanSaveEmote()
   if editor.currentEmote.name == "" then
       return true
   end
    if editor.currentEmote.description == "" then
         return true
    end
    if #editor.currentEmote.actions == 0 then
        return true
    end
   return false
end

-- Util function to check if the emote can be previewed
function editor.checkCanPreviewEmote()
     if #editor.currentEmote.actions == 0 then
         return true
     end
    return false
 end

 -- Util function to check if the emote can be reset
function editor.checkCanResetEmote()
    if editor.currentEmote.name == "" and editor.currentEmote.description == "" and #editor.currentEmote.actions == 0 then
        return true
    end
    return false
end

function editor.editEmoteByName(name)

    -- Get emote by name from saved vars
    local emote = CE.savedVars.emotes[name]
    if emote == nil then
        return
    end

    emote = internal.deepCopy(emote)
    editor.currentEmote.name = emote.name
    editor.currentEmote.description = emote.description
    editor.currentEmote.actions = emote.actions
    editor.refreshEditorInputs()
    editor.refreshActionEditor()

end

function editor.checkForDuplicatesOnSave(name, callbackAccept)

    -- Check if the emote is duplicated
    for emoteName, _ in pairs(CE.savedVars.emotes) do
        if string.lower(emoteName) == string.lower(name) then

            -- If the emote is duplicated, show a dialog to confirm the action
            ESO_Dialogs["CustomEmotesErrorDialogDuplicated"] = {
                title = { text = CONS.EDITOR_DUPLICATE_DIALOG_TITLE },
                mainText = { text = zo_strformat(CONS.EDITOR_DUPLICATE_DIALOG_MAIN_TEXT, name) },
                buttons = {
                    [1] = {
                        text = SI_DIALOG_ACCEPT,
                        callback = callbackAccept,
                    },
                    [2] = {
                        text = SI_DIALOG_CANCEL,
                        callback = function(dialog) PlaySound(SOUNDS.GENERAL_ALERT_ERROR) end,
                    },
                },
            }
            ZO_Dialogs_ShowDialog("CustomEmotesErrorDialogDuplicated")
            return
        end
    end

    callbackAccept()

end

-- Event when the save button is clicked
function editor.saveEmoteClickedEvent()

    local errorList = internal.interpreter.getErrorsFromEmote(editor.currentEmote)
    if #errorList > 0 then
        editor.showErrorDialog(errorList)
        return
    end

    editor.checkForDuplicatesOnSave(editor.currentEmote.name, function(dialog)
        CustomEmotes.internal.editor.saveEmoteEditorAction()
        CustomEmotes.internal.editor.refreshEditorInputs() 
    end)
end

-- Event when the preview button is clicked
function editor.previewEmoteClickedEvent()

    local errorList = internal.interpreter.getErrorsFromActions(editor.currentEmote.actions)
    if #editor.currentEmote.actions == 0 then
        table.insert(errorList, CONS.INTERPRETER_EMOTE_NO_ACTIONS_ERROR)
    end

    -- If there are not errors
    if #errorList == 0 then
        if CE.savedVars.validatesLogic then
            local logicErrors = internal.interpreter.checkActionsLogic(editor.currentEmote.actions)
            for _, error in ipairs(logicErrors) do
                table.insert(errorList, error)
            end
        end
    end

    if #errorList > 0 then
        editor.showErrorDialog(errorList)
        return
    end

    -- Close the menu
    SCENE_MANAGER:HideCurrentScene()
    
    -- Tell the interpreter to open the menu when it finishes
    internal.interpreter.shouldOpenEditorOnExit = true

    -- Send message of emote playing to the player
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.QUEST_ACCEPTED, zo_strformat(CONS.EDITOR_PREVIEW_EMOTE_MESSAGE, editor.currentEmote.name))

    -- Play the emote after a short delay
    zo_callLater(function() internal.interpreter.playEmote(editor.currentEmote) end, 100)
end

-- Event: save the emote
function editor.saveEmoteEditorAction()

    local emote = internal.deepCopy(editor.currentEmote)
    emote.name = string.lower(emote.name)
    internal.saveEmote(emote)
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.ITEM_MONEY_CHANGED, CONS.EDITOR_SAVE_EMOTE_SUCCESS_MESSAGE)
    editor.resetEditor()

end

-- Event: reset editor
function editor.resetEditor()
    editor.currentEmote.name = ""
    editor.currentEmote.description = ""
    editor.currentEmote.actions = {}
    editor.refreshActionEditor()
end

-- Event: button to add a new action pressed
function editor.addNewActionEvent()
    local newAction = {
        type = actions.PLAY,
        value = actionsUI[actions.PLAY].defaultValue
    }
    table.insert(editor.currentEmote.actions, newAction)
    editor.refreshActionEditor()
end

-- Event: emote to play typed
function editor.actionPlayEmoteTyped(index, value)
    if editor.invalidActionType(index, actions.PLAY) then
        return
    end
    editor.currentEmote.actions[index].value = value
end

-- Event: wait time typed
function editor.actionWaitTyped(index, value)
    if editor.invalidActionType(index, actions.WAIT) then
        return
    end
    local numberValue = tonumber(value)
    if numberValue == nil then
        return
    end
    editor.currentEmote.actions[index].value = numberValue
end

-- Event: jump index typed
function editor.actionJumpTyped(index, value)
    if editor.invalidActionType(index, actions.JUMP) then
        return
    end
    local numberValue = tonumber(value)
    if numberValue == nil then
        return
    end
    editor.currentEmote.actions[index].value = numberValue
end

-- Util function to get the reference of the index of the action
function editor.getActionIndexReference(actionReferencing)
    
    if actionReferencing.type == actions.JUMP then
        return actionReferencing.value
    end

    if actionReferencing.type == actions.REPEAT_FROM then
        return actionReferencing.value.action
    end
    
    return nil

end

-- Util function to update the reference of the index of the action
function editor.updateActionIndexReference(actionReferencing, newIndex)

    if actionReferencing.type == actions.JUMP then
        actionReferencing.value = newIndex
    end

    if actionReferencing.type == actions.REPEAT_FROM then
        actionReferencing.value.action = newIndex
    end

end

-- Event: element in the combo box of the actions clicked
function editor.actionOptionSelected(index, value)

    -- If clicked on an empty just refresh action editor
    if value == actions.EMPTY_LINE then
        editor.refreshActionEditor()
        return
    end

    -- If the value is delete, remove the action and refresh the menu
    if value == actions.DELETE then
        table.remove(editor.currentEmote.actions, index)
        -- Any reference from JUMP or REPEAT_FROM actions should be updated
        for i, action in ipairs(editor.currentEmote.actions) do
            local referencedAction = editor.getActionIndexReference(action)
            if referencedAction ~= nil and referencedAction >= index then
                editor.updateActionIndexReference(action, referencedAction - 1)
            end
        end
        editor.refreshActionEditor()
        return
    end

    -- If the value is duplicate, duplicate the action and refresh the menu
    if value == actions.DUPLICATE then
        local newAction = internal.deepCopy(editor.currentEmote.actions[index])
        table.insert(editor.currentEmote.actions, index + 1, newAction)

        -- Any reference from JUMP or REPEAT_FROM actions should be updated
        for i, action in ipairs(editor.currentEmote.actions) do
            local referencedAction = editor.getActionIndexReference(action)
            if referencedAction ~= nil and referencedAction > index then
                editor.updateActionIndexReference(action, referencedAction + 1)
            end
        end

        editor.refreshActionEditor()
        return
    end

    -- If the value is move up, move the action up and refresh the menu
    if value == actions.MOVE_UP then
        if index > 1 then
            local temp = editor.currentEmote.actions[index]
            editor.currentEmote.actions[index] = editor.currentEmote.actions[index - 1]
            editor.currentEmote.actions[index - 1] = temp

            -- Any reference from JUMP or REPEAT_FROM actions should be updated
            for i, action in ipairs(editor.currentEmote.actions) do
                local referencedAction = editor.getActionIndexReference(action)
                if referencedAction ~= nil then
                    if referencedAction == index then
                        editor.updateActionIndexReference(action, index - 1)
                    elseif referencedAction == index - 1 then
                        editor.updateActionIndexReference(action, index)
                    end
                end
            end


            editor.refreshActionEditor()
        end
        return
    end

    -- If the value is move down, move the action down and refresh the menu
    if value == actions.MOVE_DOWN then
        if index < #editor.currentEmote.actions then
            local temp = editor.currentEmote.actions[index]
            editor.currentEmote.actions[index] = editor.currentEmote.actions[index + 1]
            editor.currentEmote.actions[index + 1] = temp


            -- Any reference from JUMP or REPEAT_FROM actions should be updated
            for i, action in ipairs(editor.currentEmote.actions) do
                local referencedAction = editor.getActionIndexReference(action)
                if referencedAction ~= nil then
                    if referencedAction == index then
                        editor.updateActionIndexReference(action, index + 1)
                    elseif referencedAction == index + 1 then
                        editor.updateActionIndexReference(action, index)
                    end
                end
            end

            editor.refreshActionEditor()
        end
        return
    end

    -- Get the action reference being edited
    local currentAction = editor.currentEmote.actions[index]

    -- If current action was not changed do nothing
    if currentAction.type == value then
        return
    end

    -- If the action was changed, set the default value and refresh the menu
    currentAction.type = value
    currentAction.value = actionsUI[value].defaultValue
    editor.refreshActionEditor()

end

-- Event: repeat from action typed
function editor.actionRepeatFromTyped(index, value)
    if editor.invalidActionType(index, actions.REPEAT_FROM) then
        return
    end
    local numberValue = tonumber(value)
    if numberValue == nil then
        return
    end
    local savedValue = editor.currentEmote.actions[index].value
    if type(savedValue) ~= "table" then
        return
    end
    savedValue.action = numberValue
end

-- Event: repeat times typed
function editor.actionRepeatTimesTyped(index, value)
    if editor.invalidActionType(index, actions.REPEAT_FROM) then
        return
    end
    local numberValue = tonumber(value)
    if numberValue == nil then
        return
    end
    local savedValue = editor.currentEmote.actions[index].value
    if type(savedValue) ~= "table" then
        return
    end
    savedValue.times = numberValue
end

-- Builder for the play action control
actionsUI[actions.PLAY].componentBuilder = function(index, parent)
    if editor.invalidActionType(index, actions.PLAY) then
        return
    end

    local editBoxName = "$(parent)actionValuePlayEmote" .. index
    local control = editor.savedControls[editBoxName]
    if control == nil then
        control = WINDOW_MANAGER:CreateControlFromVirtual(editBoxName, parent, "ZO_EditBackdrop")
        editor.savedControls[editBoxName] = control

        -- Create the edit box inside the backdrop
        control.editbox = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_DefaultEditForBackdrop")
        control.editbox:SetHandler("OnTextChanged", function(self) editor.actionPlayEmoteTyped(index, self:GetText()) end)
    end

    control:SetHeight(30)
    control:SetHidden(false)
    control:SetWidth(200)
    control.editbox:SetMaxInputChars(100)
    local yOffset = (index - 1) * 30
    control:SetAnchor(TOPLEFT, parent, TOPLEFT, COMPONENT_OFFSET_LEFT, yOffset)
    control:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -COMPONENT_OFFSET_RIGHT, yOffset)
    control.editbox:SetText(editor.currentEmote.actions[index].value)

    return {control}
end

-- Builder for the wait action control
actionsUI[actions.WAIT].componentBuilder = function(index, parent)
    if editor.invalidActionType(index, actions.WAIT) then
        return
    end

    local editBoxName = "$(parent)actionValueWait" .. index
    local control = editor.savedControls[editBoxName]
    if control == nil then
        control = WINDOW_MANAGER:CreateControlFromVirtual(editBoxName, parent, "ZO_EditBackdrop")
        editor.savedControls[editBoxName] = control

        -- Create the edit box inside the backdrop
        control.editbox = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_DefaultEditForBackdrop")
        control.editbox:SetHandler("OnTextChanged", function(self) editor.actionWaitTyped(index, self:GetText()) end)
        control.editbox:SetTextType(TEXT_TYPE_NUMERIC)
    end

    local editBoxWidth = 80

    control:SetHeight(30)
    control:SetHidden(false)
    control:SetWidth(editBoxWidth)
    control.editbox:SetMaxInputChars(100)
    local yOffset = (index - 1) * 30
    control:SetAnchor(TOPLEFT, parent, TOPLEFT, COMPONENT_OFFSET_LEFT, yOffset)
    control.editbox:SetText(editor.currentEmote.actions[index].value)

    local editBoxNameLabel = "$(parent)actionValueWaitLabel" .. index
    local labelControl = editor.savedControls[editBoxNameLabel]
    if labelControl == nil then
        labelControl = WINDOW_MANAGER:CreateControl(editBoxNameLabel, parent, CT_LABEL)
        editor.savedControls[editBoxNameLabel] = labelControl
        labelControl:SetFont("ZoFontGame")
        labelControl:SetText(CONS.EDITOR_WAIT_LABEL_TEXT)
    end
    labelControl:SetHidden(false)
    labelControl:SetAnchor(TOPLEFT, parent, TOPLEFT, COMPONENT_OFFSET_LEFT + editBoxWidth + 10, yOffset)
    labelControl:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -COMPONENT_OFFSET_RIGHT, yOffset)

    return {control}
end

-- Builder for the jump action control
actionsUI[actions.JUMP].componentBuilder = function(index, parent)
    if editor.invalidActionType(index, actions.JUMP) then
        return
    end

    local editBoxName = "$(parent)actionValueJump" .. index
    local control = editor.savedControls[editBoxName]
    if control == nil then
        control = WINDOW_MANAGER:CreateControlFromVirtual(editBoxName, parent, "ZO_EditBackdrop")
        editor.savedControls[editBoxName] = control

        -- Create the edit box inside the backdrop
        control.editbox = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_DefaultEditForBackdrop")
        control.editbox:SetHandler("OnTextChanged", function(self) editor.actionJumpTyped(index, self:GetText()) end)
        control.editbox:SetTextType(TEXT_TYPE_NUMERIC)
    end

    local editBoxWidth = 40

    control:SetHeight(30)
    control:SetHidden(false)
    control:SetWidth(editBoxWidth)
    control.editbox:SetMaxInputChars(100)
    local yOffset = (index - 1) * 30
    control:SetAnchor(TOPLEFT, parent, TOPLEFT, COMPONENT_OFFSET_LEFT, yOffset)
    control.editbox:SetText(editor.currentEmote.actions[index].value)

    local editBoxNameLabel = "$(parent)actionValueJumpLabel" .. index
    local labelControl = editor.savedControls[editBoxNameLabel]
    if labelControl == nil then
        labelControl = WINDOW_MANAGER:CreateControl(editBoxNameLabel, parent, CT_LABEL)
        editor.savedControls[editBoxNameLabel] = labelControl
        labelControl:SetFont("ZoFontGame")
        labelControl:SetText(CONS.EDITOR_JUMP_LABEL_TEXT)
    end
    labelControl:SetHidden(false)
    labelControl:SetAnchor(TOPLEFT, parent, TOPLEFT, COMPONENT_OFFSET_LEFT + editBoxWidth + 10, yOffset)
    labelControl:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -COMPONENT_OFFSET_RIGHT, yOffset)

    return {control}
end

-- Builder for the jump first action control
actionsUI[actions.JUMP_FIRST].componentBuilder = function(index, parent)
    if editor.invalidActionType(index, actions.JUMP_FIRST) then
        return
    end

    local labelName = "$(parent)actionValueJumpFirstLabel" .. index
    local label = editor.savedControls[labelName]
    if label == nil then
        label = WINDOW_MANAGER:CreateControl(labelName, parent, CT_LABEL)
        editor.savedControls[labelName] = label
    end
    label:SetHeight(14)
    label:SetHidden(false)
    label:SetFont("ZoFontGame")
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetText(CONS.EDITOR_JUMP_FIRST_LABEL_TEXT)
    local yOffset = (index - 1) * 30
    label:SetAnchor(TOPLEFT, parent, TOPLEFT, COMPONENT_OFFSET_LEFT, yOffset)
    label:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -COMPONENT_OFFSET_RIGHT, yOffset)

    return {label}
end

-- Builder for the repeat from action control
actionsUI[actions.REPEAT_FROM].componentBuilder = function(index, parent)
    if editor.invalidActionType(index, actions.REPEAT_FROM) then
        return
    end

    local editBoxName = "$(parent)actionValueRepeatFrom" .. index
    local control = editor.savedControls[editBoxName]
    if control == nil then
        control = WINDOW_MANAGER:CreateControlFromVirtual(editBoxName, parent, "ZO_EditBackdrop")
        editor.savedControls[editBoxName] = control

        -- Create the edit box inside the backdrop
        control.editbox = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_DefaultEditForBackdrop")
        control.editbox:SetHandler("OnTextChanged", function(self) editor.actionRepeatFromTyped(index, self:GetText()) end)
        control.editbox:SetTextType(TEXT_TYPE_NUMERIC)
    end

    local editBoxWidth = 40

    control:SetHeight(30)
    control:SetHidden(false)
    control:SetWidth(editBoxWidth)
    control.editbox:SetMaxInputChars(100)
    local yOffset = (index - 1) * 30
    control:SetAnchor(TOPLEFT, parent, TOPLEFT, COMPONENT_OFFSET_LEFT, yOffset)
    control.editbox:SetText(editor.currentEmote.actions[index].value.action)

    local editBoxNameLabel = "$(parent)actionValueRepeatFromLabel" .. index
    local labelControl = editor.savedControls[editBoxNameLabel]
    if labelControl == nil then
        labelControl = WINDOW_MANAGER:CreateControl(editBoxNameLabel, parent, CT_LABEL)
        editor.savedControls[editBoxNameLabel] = labelControl
        labelControl:SetFont("ZoFontGame")
        labelControl:SetText(CONS.EDITOR_REPEAT_FROM_LABEL_TEXT)
    end
    labelControl:SetHidden(false)
    labelControl:SetAnchor(TOPLEFT, parent, TOPLEFT, COMPONENT_OFFSET_LEFT + editBoxWidth + 10, yOffset)
    labelControl:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -COMPONENT_OFFSET_RIGHT, yOffset)

    local editBoxNameTimes = "$(parent)actionValueRepeatFromTimes" .. index
    local controlTimes = editor.savedControls[editBoxNameTimes]
    if controlTimes == nil then
        controlTimes = WINDOW_MANAGER:CreateControlFromVirtual(editBoxNameTimes, parent, "ZO_EditBackdrop")
        editor.savedControls[editBoxNameTimes] = controlTimes

        -- Create the edit box inside the backdrop
        controlTimes.editbox = WINDOW_MANAGER:CreateControlFromVirtual(nil, controlTimes, "ZO_DefaultEditForBackdrop")
        controlTimes.editbox:SetHandler("OnTextChanged", function(self) editor.actionRepeatTimesTyped(index, self:GetText()) end)
        controlTimes.editbox:SetTextType(TEXT_TYPE_NUMERIC)
    end

    controlTimes:SetHeight(30)
    controlTimes:SetHidden(false)
    controlTimes:SetWidth(editBoxWidth)
    controlTimes.editbox:SetMaxInputChars(100)
    controlTimes.editbox:SetText(editor.currentEmote.actions[index].value.times)
    controlTimes:SetAnchor(TOPLEFT, parent, TOPLEFT, COMPONENT_OFFSET_LEFT + editBoxWidth + 10 + 100, yOffset)

    local editBoxNameLabelTimes = "$(parent)actionValueRepeatFromLabelTimes" .. index
    local labelControlTimes = editor.savedControls[editBoxNameLabelTimes]
    if labelControlTimes == nil then
        labelControlTimes = WINDOW_MANAGER:CreateControl(editBoxNameLabelTimes, parent, CT_LABEL)
        editor.savedControls[editBoxNameLabelTimes] = labelControlTimes
        labelControlTimes:SetFont("ZoFontGame")
        labelControlTimes:SetText(CONS.EDITOR_REPEAT_FROM_TIMES_LABEL_TEXT)
    end

    labelControlTimes:SetHidden(false)
    labelControlTimes:SetAnchor(TOPLEFT, parent, TOPLEFT, COMPONENT_OFFSET_LEFT + editBoxWidth + 10 + 100 + editBoxWidth + 10, yOffset)
    labelControlTimes:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -COMPONENT_OFFSET_RIGHT, yOffset)

    return {control, controlTimes}

end

-- Builder for the interrupt first action control
actionsUI[actions.INTERRUPT].componentBuilder = function(index, parent)
    if editor.invalidActionType(index, actions.INTERRUPT) then
        return
    end

    local labelName = "$(parent)actionValueInterruptLabel" .. index
    local label = editor.savedControls[labelName]
    if label == nil then
        label = WINDOW_MANAGER:CreateControl(labelName, parent, CT_LABEL)
        editor.savedControls[labelName] = label
    end
    label:SetHeight(14)
    label:SetHidden(false)
    label:SetFont("ZoFontGame")
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetText(CONS.EDITOR_INTERRUPT_LABEL_TEXT)
    local yOffset = (index - 1) * 30
    label:SetAnchor(TOPLEFT, parent, TOPLEFT, COMPONENT_OFFSET_LEFT, yOffset)
    local sliderName = "$(parent)actionValueInterruptSlider" .. index
    local slider = editor.savedControls[sliderName]
    if slider == nil then
        slider = WINDOW_MANAGER:CreateControl(sliderName, parent, CT_SLIDER)
        editor.savedControls[sliderName] = slider
        slider:SetDimensions(200, 14)
        slider:SetMinMax(0, 500)
        slider:SetValueStep(1)
        slider:SetOrientation(ORIENTATION_HORIZONTAL)
        slider:SetThumbTexture("EsoUI/Art/Miscellaneous/scrollbox_elevator.dds", "EsoUI/Art/Miscellaneous/scrollbox_elevator_disabled.dds", nil, 8, 16)
        slider:SetMouseEnabled(true)
        slider:SetHandler("OnValueChanged", function(self, value)
            editor.currentEmote.actions[index].value = value
        end)
        local bg = WINDOW_MANAGER:CreateControl(nil, slider, CT_BACKDROP)
        bg:SetCenterColor(0, 0, 0)
        bg:SetAnchor(TOPLEFT, slider, TOPLEFT, 0, 4)
        bg:SetAnchor(BOTTOMRIGHT, slider, BOTTOMRIGHT, 0, -4)
        bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-SliderBackdrop.dds", 32, 4)
    end
    slider:SetHidden(false)
    slider:SetValue(editor.currentEmote.actions[index].value or 0)
    slider:ClearAnchors()
    slider:SetAnchor(TOPLEFT, parent, TOPLEFT, COMPONENT_OFFSET_LEFT + 60, yOffset + 6)
    return {label, slider}
end

-- Builder for personality change, it only has a dropbox with the personality options from internal.personalityList and as value it uses collectibleId
actionsUI[actions.PERSONALITY].componentBuilder = function(index, parent)
    if editor.invalidActionType(index, actions.PERSONALITY) then
        return
    end

    local dropBoxName = "$(parent)actionValuePersonality" .. index
    local dropBox = editor.savedControls[dropBoxName]
    if dropBox == nil then
        dropBox = WINDOW_MANAGER:CreateControlFromVirtual(dropBoxName, parent, "ZO_ComboBox")
        local comboBox = ZO_ComboBox_ObjectFromContainer(dropBox)
        comboBox:SetSortsItems(false)
        for _, personality in pairs(internal.personalityList) do
            comboBox:AddItem(comboBox:CreateItemEntry(personality.name, function() editor.currentEmote.actions[index].value = personality.collectibleId end))
        end
        editor.savedControls[dropBoxName] = dropBox
        dropBox.dropdown = comboBox
    end
    dropBox:SetHeight(30)
    dropBox:SetHidden(false)
    dropBox:SetWidth(200)
    dropBox:SetAnchor(TOPLEFT, parent, TOPLEFT, COMPONENT_OFFSET_LEFT, (index - 1) * 30)
    dropBox.dropdown:SetSelectedItem(internal.personalityList[editor.currentEmote.actions[index].value].name)
    return {dropBox}
end

-- Creates label saying No actions
function editor.createPlaceholderActionLabel(parent)
    local labelName = "$(parent)actionLabelPlaceholder"
    local label = editor.savedControls[labelName]
    if label == nil then
        label = WINDOW_MANAGER:CreateControl(labelName, parent, CT_LABEL)
        editor.savedControls[labelName] = label
    end
    label:SetHeight(14)
    label:SetHidden(false)
    label:SetFont("ZoFontGame")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetText(CONS.EDITOR_NO_ACTIONS_LABEL_TEXT)
    label:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
    label:SetAnchor(TOPRIGHT, parent, TOPRIGHT, 0, 0)
    return {label}
end

-- Creates the dropdown to select the action type
function editor.createDropBoxControl(index, parent)
    
    local dropBoxName = "$(parent)actionType" .. index
    local dropBox = editor.savedControls[dropBoxName]
    if dropBox == nil then
        dropBox = WINDOW_MANAGER:CreateControlFromVirtual(dropBoxName, parent, "ZO_ComboBox")
        local comboBox = ZO_ComboBox_ObjectFromContainer(dropBox)
        comboBox:SetSortsItems(false)

        local sortedActions = {}
        for _, action in pairs(actions) do
            table.insert(sortedActions, action)
        end

        table.sort(sortedActions)

        for _, action in ipairs(sortedActions) do
            local actionUI = actionsUI[action]
            comboBox:AddItem(comboBox:CreateItemEntry(actionUI.caption, function() editor.actionOptionSelected(index, action) end))
        end

        editor.savedControls[dropBoxName] = dropBox
        dropBox.dropdown = comboBox
    end
    dropBox:SetHeight(30)
    dropBox:SetHidden(false)
    dropBox:SetWidth(200)
    
    local offsetX = 60
    local offsetY = (index - 1) * 30
    dropBox:SetAnchor(TOPLEFT, parent, TOPLEFT, offsetX, offsetY)
    
    return {dropBox}
    
end

-- Creates the labels of the actions in the editor
function editor.createLabelControl(index, parent)

    local labelName = "$(parent)actionLabel" .. index
    local label = editor.savedControls[labelName]
    if label == nil then
        label = WINDOW_MANAGER:CreateControl(labelName, parent, CT_LABEL)
        editor.savedControls[labelName] = label
    end
    label:SetHeight(14)
    label:SetHidden(false)
    label:SetFont("ZoFontGame")
    label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    label:SetText(index .. ")")

    local offsetX = 50
    local offsetY = (index - 1) * 30
    label:SetAnchor(TOPRIGHT, parent, TOPLEFT, offsetX, offsetY)
    label:SetWidth(50)
    return {label}

end

-- Refreshes the editor interface
function editor.refreshEmoteEditorInterface(control)

    -- Avoids refreshing the menu if it is not dirty
    if not editor.isDirty then
        return
    end
    editor.isDirty = false

    -- Deletes all the savedControls controls
    for key, value in pairs(editor.savedControls) do
        value:SetHidden(true)
    end

    -- If there are no actions, insert a default one
    if #editor.currentEmote.actions == 0 then
        editor.createPlaceholderActionLabel(control)
    end

    -- Create a label for each action
    for i, action in ipairs(editor.currentEmote.actions) do

        -- Create a label for the action
        editor.createLabelControl(i, control)

        -- Get the UI for the action
        local actionUI = actionsUI[action.type]

        -- Create a dropbox for the action type
        local dropBox = editor.createDropBoxControl(i, control)[1]
        dropBox.dropdown:SetSelectedItem(actionUI.caption)

        -- Create the control for the action value
        actionUI.componentBuilder(i, control)

    end

    -- Sets the height of the control
    control:SetHeight(30 + 30 * #editor.currentEmote.actions)

end
-- Initializes the editor interface
function editor.initializeUI()

    local editorUI = {}

    -- Reset button
    table.insert(editorUI, {
        type = "button",
        name = CONS.EDITOR_RESET_BUTTON_NAME,
        tooltip = CONS.EDITOR_RESET_BUTTON_TOOLTIP,
        isDangerous = true,
        warning = CONS.EDITOR_RESET_BUTTON_WARNING,
        func = editor.resetEditor,
        disabled = editor.checkCanResetEmote,
        width = "full",
        isExtraWide = true
    })

    -- Emote name control
    table.insert(editorUI, {
        type = "editbox",
        name = CONS.EDITOR_EMOTE_NAME,
        tooltip = string.format(CONS.EDITOR_EMOTE_NAME_TOOLTIP, CE.savedVars.command),
        getFunc = function() return editor.currentEmote.name end,
        setFunc = function(value) editor.currentEmote.name = value end,
        width = "full",
    })

    -- Actions description
    table.insert(editorUI, {
        type = "editbox",
        title = nil,
        width = "full",
        name = CONS.EDITOR_DESCRIPTION_NAME,
        tooltip = CONS.EDITOR_DESCRIPTION_TOOLTIP,
        getFunc = function() return editor.currentEmote.description end,
        setFunc = function(value) editor.currentEmote.description = value end,
        isMultiline = true
    })

    -- Add action button
    table.insert(editorUI, {
        type = "button",
        name = CONS.EDITOR_ADD_ACTION_BUTTON_NAME,
        tooltip = CONS.EDITOR_ADD_ACTION_BUTTON_TOOLTIP,
        func = editor.addNewActionEvent,
        width = "full"
    })

    -- Division
    table.insert(editorUI, {
        type = "divider",
        width = "full",
    })

    -- Preview button
    table.insert(editorUI, {
        type = "button",
        name = CONS.EDITOR_PREVIEW_BUTTON_NAME,
        tooltip = CONS.EDITOR_PREVIEW_BUTTON_TOOLTIP,
        func = editor.previewEmoteClickedEvent,
        disabled = editor.checkCanPreviewEmote,
        width = "half"
    })

    -- Save button
    table.insert(editorUI, {
        type = "button",
        name = CONS.EDITOR_SAVE_BUTTON_NAME,
        tooltip = CONS.EDITOR_SAVE_BUTTON_TOOLTIP,
        func = editor.saveEmoteClickedEvent,
        disabled = editor.checkCanSaveEmote,
        width = "half"
    })
    
    -- Division
    table.insert(editorUI, {
        type = "divider",
        width = "full",
    })

    -- Dynamic action list
    table.insert(editorUI, {
        type = "custom",
        reference = editor.componentReference,
        createFunc = editor.refreshActionEditor,
        refreshFunc = editor.refreshEmoteEditorInterface,
        width = "full",
    })

    return editorUI

end