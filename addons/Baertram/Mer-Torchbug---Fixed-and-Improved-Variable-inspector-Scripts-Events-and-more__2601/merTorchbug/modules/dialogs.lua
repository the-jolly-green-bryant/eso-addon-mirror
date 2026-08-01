local tbug = TBUG or SYSTEMS:GetSystem("merTorchbug")

local SM = SCENE_MANAGER

local dialog_ConfirmBeforeName = "TBUG_CONFIRM_BEFORE_DIALOG"

--Enable the mouse cursor again as the dialog layer disables it and we manually have to press the keybind to get into UI mouse cursor mode again
local function changeBackToMouseCursorMode()
    if SM:IsInUIMode() then return end
    ZO_SceneManager_ToggleUIModeBinding()
end

function tbug.RegisterCustomDialogs()
    ZO_Dialogs_RegisterCustomDialog(dialog_ConfirmBeforeName,
    {
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title =
        {
            text = "Do you really want to:",
        },
        mainText =
        {
            text = "",
        },
        buttons =
        {
            [1] = {
                text = SI_DIALOG_CONFIRM,
                callback = function(dialog) changeBackToMouseCursorMode() end
            },
            [2] = {
                text = SI_DIALOG_CANCEL,
                callback = function(dialog) changeBackToMouseCursorMode() end
            },
        },
        noChoiceCallback = function() changeBackToMouseCursorMode()  end,
    })
end

function tbug.ShowConfirmBeforeDialog(title, mainText, callbackYes)
    if not ZO_Dialogs_IsDialogRegistered(dialog_ConfirmBeforeName) then return end
    local dialogData = ESO_Dialogs[dialog_ConfirmBeforeName]
    if dialogData == nil then return end
    if title ~= nil and title ~= "" then
        dialogData.title = { text = title }
    end
    dialogData.mainText = { text = mainText }
    dialogData.buttons[1].callback = function(dialog)
        callbackYes(dialog)
        changeBackToMouseCursorMode()
    end
    ZO_Dialogs_ShowPlatformDialog(dialog_ConfirmBeforeName, nil, dialogData)
end