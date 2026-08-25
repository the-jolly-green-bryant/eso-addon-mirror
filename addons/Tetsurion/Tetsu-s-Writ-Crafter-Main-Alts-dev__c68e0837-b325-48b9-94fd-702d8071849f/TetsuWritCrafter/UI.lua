TetsuWritCrafter = TetsuWritCrafter or {}
local UI = {}
TetsuWritCrafter.UI = UI

local queueHUD = nil

ESO_Dialogs["TETSU_WRIT_CONFIRM"] = {
    gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
    title = { text = function(dialog) return dialog.data.title end },
    mainText = { text = function(dialog) return dialog.data.mainText end },
    buttons = {
        {
            text = SI_DIALOG_CONFIRM,
            callback = function(dialog)
                if dialog.data and dialog.data.confirmCallback then
                    dialog.data.confirmCallback()
                end
            end,
        },
        { text = SI_DIALOG_CANCEL },
    },
}

function UI.CreateProgressBarHUD()
    if queueHUD then return end
    local wm = WINDOW_MANAGER
    queueHUD = wm:CreateTopLevelWindow("TetsuWritCrafter_QueueHUD")
    queueHUD:SetDimensions(400, 90)
    queueHUD:SetAnchor(CENTER, GuiRoot, CENTER, 0, 180)
    queueHUD:SetHidden(true)

    local bg = wm:CreateControl("$(parent)_BG", queueHUD, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.85)
    bg:SetEdgeColor(0.2, 0.8, 0.2, 0.9)
    bg:SetEdgeTexture("", 8, 1, 1)

    local title = wm:CreateControl("$(parent)_Title", queueHUD, CT_LABEL)
    title:SetAnchor(TOPLEFT, queueHUD, TOPLEFT, 15, 10)
    title:SetFont("ZoFontWinH4")
    queueHUD.title = title

    local bar = wm:CreateControl("$(parent)_Bar", queueHUD, CT_STATUSBAR)
    bar:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 6)
    bar:SetDimensions(370, 16)
    bar:SetMinMax(0, 100)
    bar:SetColor(0.2, 0.8, 0.2, 1)
    queueHUD.bar = bar

    local counter = wm:CreateControl("$(parent)_Counter", queueHUD, CT_LABEL)
    counter:SetAnchor(TOPLEFT, bar, BOTTOMLEFT, 0, 4)
    counter:SetFont("ZoFontGameSmall")
    queueHUD.counter = counter
end

function UI.UpdateProgress(titleText, current, total)
    if not queueHUD then UI.CreateProgressBarHUD() end
    queueHUD:SetHidden(false)
    queueHUD.title:SetText(titleText)
    queueHUD.bar:SetValue(math.floor((current / total) * 100))
    queueHUD.counter:SetText(zo_strformat(TetsuWritCrafter.L.PROGRESS_STATUS, current, total))
end

function UI.HideProgress()
    if queueHUD then queueHUD:SetHidden(true) end
end

function UI.ShowConfirmationDialog(itemCount, onConfirmCallback)
    local L = TetsuWritCrafter.L
    ZO_Dialogs_ShowPlatformDialog("TETSU_WRIT_CONFIRM", {
        title = L.CONFIRM_TITLE,
        mainText = zo_strformat(L.CONFIRM_PROMPT, itemCount),
        confirmCallback = onConfirmCallback,
    })
end