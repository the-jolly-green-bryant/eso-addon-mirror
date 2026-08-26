TetsuDailyWritPrecrafter = TetsuDailyWritPrecrafter or {}
local UI = {}
TetsuDailyWritPrecrafter.UI = UI

local queueHUD = nil

ESO_Dialogs["TDWP_CONFIRM"] = {
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
    queueHUD = wm:CreateTopLevelWindow("TetsuDailyWritPrecrafter_QueueHUD")
    queueHUD:SetDimensions(400, 90)
    queueHUD:SetAnchor(CENTER, GuiRoot, CENTER, 0, 180)
    queueHUD:SetHidden(true)
    queueHUD:SetDrawTier(DT_HIGH)
    queueHUD:SetDrawLayer(DL_OVERLAY)

    local bg = wm:CreateControl("$(parent)_BG", queueHUD, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.85)
    bg:SetEdgeColor(0.2, 0.8, 0.2, 0.9)
    bg:SetEdgeTexture("", 8, 1, 1)

    local title = wm:CreateControl("$(parent)_Title", queueHUD, CT_LABEL)
    title:SetAnchor(TOPLEFT, queueHUD, TOPLEFT, 15, 10)
    title:SetFont("ZoFontWinH4")
    title:SetColor(0.85, 1, 0.85, 1)
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
    counter:SetColor(0.8, 0.8, 0.8, 1)
    queueHUD.counter = counter
end

function UI.ShowProgress(total)
    if not queueHUD then UI.CreateProgressBarHUD() end
    local L = TetsuDailyWritPrecrafter.L
    queueHUD:SetHidden(false)
    queueHUD.title:SetText(L.PROGRESS_CRAFTING or "Crafting...")
    queueHUD.bar:SetValue(0)
    queueHUD.counter:SetText(zo_strformat(L.PROGRESS_STATUS or "0 / <<1>>", 0, total or 0))
end

function UI.UpdateProgress(current, total)
    if not queueHUD then UI.CreateProgressBarHUD() end
    queueHUD:SetHidden(false)
    local pct = 0
    if total and total > 0 then
        pct = math.floor((current / total) * 100)
    end
    queueHUD.bar:SetValue(pct)
    local L = TetsuDailyWritPrecrafter.L
    queueHUD.counter:SetText(zo_strformat(L.PROGRESS_STATUS or "<<1>> / <<2>>", current, total))
end

function UI.HideProgress()
    if queueHUD then queueHUD:SetHidden(true) end
end

-- isPrecraft = true → use pre-craft title/prompt
function UI.ShowConfirmationDialog(itemCount, onConfirmCallback, isPrecraft)
    local L = TetsuDailyWritPrecrafter.L
    local title, mainText
    if isPrecraft then
        local cs = TetsuDailyWritPrecrafter.GetCharSettings and TetsuDailyWritPrecrafter.GetCharSettings()
        local days = (cs and cs.preCraftDays) or 3
        title = L.CONFIRM_TITLE_PRECRAFT or "Pre-craft"
        mainText = zo_strformat(L.CONFIRM_PROMPT_PRECRAFT or "Craft for <<1>> days (<<2>> items)?", days, itemCount)
    else
        title = L.CONFIRM_TITLE_QUEST or "Craft Active Writ"
        mainText = zo_strformat(L.CONFIRM_PROMPT_QUEST or "Craft <<1>> items for active writ?", itemCount)
    end
    ZO_Dialogs_ShowPlatformDialog("TDWP_CONFIRM", {
        title = title,
        mainText = mainText,
        confirmCallback = onConfirmCallback,
    })
end

function UI.AlertError(message)
    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, message)
end

function UI.Chat(message)
    d("|cFFD700[Tetsu's Daily Writ Precrafter]|r " .. tostring(message))
end
