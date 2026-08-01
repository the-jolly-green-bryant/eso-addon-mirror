BGMeter = BGMeter or {}
local BGMeter = BGMeter
BGMeter.UI = BGMeter.UI or {}

local E = {}
local controls = nil
local MAX_CHARS = 200000


local function build()
    if controls then return end
    local ui = BGMeter.zenimax.ui
    local K = BGMeter.Constants
    local P = BGMeter.Plot.primitives
    local S = BGMeter.Plot.style

    local win = ui.wm:CreateTopLevelWindow("BGMeterExportWindow")
    win:SetDimensions(640, 480)
    win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    win:SetMouseEnabled(true)
    win:SetMovable(true)
    win:SetClampedToScreen(true)
    win:SetHidden(true)
    win:SetDrawTier(DT_HIGH)

    local bg = P.rect(win, { K.COLOR.bg[1], K.COLOR.bg[2], K.COLOR.bg[3], 0.98 })
    bg:SetAnchorFill(win)
    P.frame(win):SetAnchorFill(win)

    local strip = P.rect(win, K.COLOR.accent)
    strip:SetAnchor(TOPLEFT, win, TOPLEFT, 6, 6)
    strip:SetAnchor(TOPRIGHT, win, TOPRIGHT, -6, 6)
    strip:SetHeight(3)

    local logo = P.icon(win, K.LOGO)
    logo:SetDimensions(20, 20)
    logo:SetAnchor(TOPLEFT, win, TOPLEFT, 16, 13)

    local title = P.label(win, S.FONT.title, K.COLOR.text)
    title:SetText(K.TITLE .. "  ·  Report")
    title:SetAnchor(LEFT, logo, RIGHT, 8, 0)

    local hint = P.label(win, S.FONT.small, K.COLOR.text_dim)
    hint:SetText("Select All, then Ctrl+C to copy")
    hint:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 4)

    local closeX = P.button(win, "EsoUI/Art/Buttons/decline_up.dds",
        "EsoUI/Art/Buttons/decline_down.dds", "EsoUI/Art/Buttons/decline_over.dds")
    closeX:SetDimensions(20, 20)
    closeX:SetAnchor(TOPRIGHT, win, TOPRIGHT, -14, 14)
    closeX:SetHandler("OnClicked", function() E.hide() end)

    local ebbg = ui.create_from_virtual(nil, win, "ZO_MultiLineEditBackdrop_Keyboard")
    ebbg:SetAnchor(TOPLEFT, win, TOPLEFT, 16, 62)
    ebbg:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -16, -52)

    local edit = ui.create_from_virtual("BGMeterExportEdit", ebbg, "ZO_DefaultEditMultiLineForBackdrop")
    edit:SetMaxInputChars(MAX_CHARS)
    edit:SetFont("ZoFontChat")

    local selall = ui.create_from_virtual(nil, win, "ZO_DefaultButton")
    selall:SetDimensions(150, 28)
    selall:SetAnchor(BOTTOMLEFT, win, BOTTOMLEFT, 16, -14)
    selall:SetText("Select All")
    selall:SetHandler("OnClicked", function() edit:TakeFocus(); edit:SelectAll() end)

    local closebtn = ui.create_from_virtual(nil, win, "ZO_DefaultButton")
    closebtn:SetDimensions(120, 28)
    closebtn:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -16, -14)
    closebtn:SetText("Close")
    closebtn:SetHandler("OnClicked", function() E.hide() end)

    controls = { window = win, edit = edit }
end

function E.show_text(text)
    build()
    controls.edit:SetText(text or "")
    controls.window:SetHidden(false)
    controls.edit:TakeFocus()
    controls.edit:SelectAll()
end

function E.hide()
    if not controls or controls.window:IsHidden() then return end
    controls.window:SetHidden(true)
    if BGMeter.Sound then BGMeter.Sound.play("close") end
end

BGMeter.UI.export = E
