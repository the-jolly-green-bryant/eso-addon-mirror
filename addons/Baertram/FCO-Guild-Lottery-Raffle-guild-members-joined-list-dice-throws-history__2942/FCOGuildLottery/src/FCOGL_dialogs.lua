if FCOGL == nil then FCOGL = {} end
local FCOGuildLottery = FCOGL

local addonVars = FCOGuildLottery.addonVars
local addonName = addonVars.addonName
local addonNamePre = FCOGuildLottery.addonNamePre

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--DIALOG FUNCTIONS


local function getDialogName(dialogId)
    local dialogNames = FCOGuildLottery.dialogs.names
    if dialogNames[dialogId] ~= nil then
        return addonName .. "_" .. dialogNames[dialogId]
    end
    return nil
end
FCOGuildLottery.getDialogName = getDialogName

--function to initialize the ask protection question dialog
function FCOGuildLottery.AskBeforeResetDialogInitialize(control, dialogName)
    if control == nil or dialogName == nil or dialogName == "" then return end
    local content   = GetControl(control, "Content")
    local acceptBtn = GetControl(control, "Accept")
    local cancelBtn = GetControl(control, "Cancel")
    local titleLabel = GetControl(control, "Title")
    local descLabel = GetControl(content, "Text")
    local okFunc
    local abortFunc

    ZO_Dialogs_RegisterCustomDialog(dialogName, {
        customControl = control,
        title = { text = "Title" },
        mainText = { text = "Question" },
        setup = function(_, data)
            titleLabel:SetText(data.title)
            descLabel:SetText(data.question)
            local callbackData = data.callbackData
            if callbackData.yes then
                okFunc = callbackData.yes
            end
            if okFunc == nil or type(okFunc) ~= "function" then
                okFunc = function() end
            end
            if callbackData.no then
                abortFunc = callbackData.no
            end
            if abortFunc == nil or type(abortFunc) ~= "function" then
                abortFunc = function() end
            end
        end,
        noChoiceCallback = function()
            abortFunc()
        end,
        buttons =
        {
            {
                control = acceptBtn,
                text = SI_DIALOG_ACCEPT,
                keybind = "DIALOG_PRIMARY",
                callback = function(dialog)
                    okFunc()
                end,
            },
            {
                control = cancelBtn,
                text = SI_DIALOG_CANCEL,
                keybind = "DIALOG_NEGATIVE",
                callback = function(dialog)
                    abortFunc()
                end,
            },
        },
    })
end
