local gpDialogTitle = ""
local gpDialogBody = ""

local function InitConsole()
    ESO_Dialogs["DYNAMICCP_CONFIRMATION_DIALOG"] =
    {
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title =
        {
            text = function() return gpDialogTitle end,
        },
        mainText =
        {
            text = function() return gpDialogBody end,
        },
        buttons =
        {
            [1] =
            {
                text = SI_DIALOG_ACCEPT,
                callback = function(dialog)
                    dialog.data.callback()
                end,
            },
            [2] =
            {
                text = SI_DIALOG_CANCEL,
            },
        },
    }
end


local consoleDialogInitialized = false
local function ShowConfirmationDialog(dialogName, dialogTitle, bodyText, callbackYes)
    if (LibDialog) then
        LibDialog:RegisterDialog(
                DynamicCP.name,
                dialogName,
                dialogTitle,
                bodyText,
                callbackYes,
                nil,
                nil,
                true)
        LibDialog:ShowDialog(DynamicCP.name, dialogName)
    else
        if (not consoleDialogInitialized) then
            InitConsole()
            consoleDialogInitialized = true
        end
        gpDialogTitle = dialogTitle
        gpDialogBody = bodyText
        ZO_Dialogs_ShowGamepadDialog("DYNAMICCP_CONFIRMATION_DIALOG", {callback = callbackYes})
    end
end
DynamicCP.ShowConfirmationDialog = ShowConfirmationDialog
-- /script DynamicCP.ShowConfirmationDialog(nil, "bbbbbb", "body asdf", function() d("callbackYes") end)
