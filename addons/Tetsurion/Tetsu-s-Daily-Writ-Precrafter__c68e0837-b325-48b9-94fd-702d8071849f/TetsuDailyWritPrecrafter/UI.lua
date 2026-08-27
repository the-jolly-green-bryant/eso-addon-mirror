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

local function LargeFont(kind)
    -- Console ignores ZoFontWinH*; gamepad faces are the ones that actually scale
    if IsInGamepadPreferredMode and IsInGamepadPreferredMode() or (IsConsoleUI and IsConsoleUI()) then
        if kind == "title" then
            return "ZoFontGamepad34"
        end
        return "ZoFontGamepad27"
    end
    if kind == "title" then
        return "ZoFontWinH2"
    end
    return "ZoFontWinH3"
end

function UI.CreateProgressBarHUD()
    if queueHUD then return end
    local wm = WINDOW_MANAGER
    queueHUD = wm:CreateTopLevelWindow("TetsuDailyWritPrecrafter_QueueHUD")
    queueHUD:SetDimensions(420, 78)
    queueHUD:SetAnchor(CENTER, GuiRoot, CENTER, 0, 180)
    queueHUD:SetHidden(true)
    queueHUD:SetDrawTier(DT_HIGH)
    queueHUD:SetDrawLayer(DL_OVERLAY)
    queueHUD:SetClampedToScreen(true)

    local bg = wm:CreateControl("$(parent)_BG", queueHUD, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.82)
    bg:SetEdgeColor(0.90, 0.75, 0.20, 0.95)
    bg:SetEdgeTexture("", 8, 1, 1)

    local title = wm:CreateControl("$(parent)_Title", queueHUD, CT_LABEL)
    title:SetAnchor(TOPLEFT, queueHUD, TOPLEFT, 14, 6)
    title:SetAnchor(TOPRIGHT, queueHUD, TOPRIGHT, -14, 6)
    title:SetFont(LargeFont("title"))
    title:SetColor(0.98, 0.86, 0.35, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetMaxLineCount(1)
    queueHUD.title = title

    local bar = wm:CreateControl("$(parent)_Bar", queueHUD, CT_STATUSBAR)
    bar:SetAnchor(BOTTOMLEFT, queueHUD, BOTTOMLEFT, 14, -10)
    bar:SetDimensions(392, 20)
    bar:SetMinMax(0, 100)
    bar:SetColor(0.90, 0.75, 0.18, 1)
    queueHUD.bar = bar

    -- Text sits on the bar so the box stays short and the numbers stay readable
    local counter = wm:CreateControl("$(parent)_Counter", queueHUD, CT_LABEL)
    counter:SetAnchor(CENTER, bar, CENTER, 0, 0)
    counter:SetFont(LargeFont("counter"))
    counter:SetColor(0.12, 0.10, 0.05, 1)
    counter:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    counter:SetDrawLayer(DL_OVERLAY)
    counter:SetDrawLevel(2)
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
