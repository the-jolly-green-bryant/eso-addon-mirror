local ADK = AntiDK2
local M   = {}
ADK.UI.Popups = M

-- Font helper: CrutchAlerts-style bold with thick shadow
function ADK.UI.BoldFont(size)
    return string.format("$(BOLD_FONT)|%d|soft-shadow-thick", math.floor(size))
end

-- Label helper
function ADK.UI.MakeLabel(name, parent, font, r, g, b)
    local lbl = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    lbl:SetFont(font or ADK.UI.BoldFont(16))
    lbl:SetColor(r or 1, g or 1, b or 1, 1)
    return lbl
end
function ADK.UI.MakeStatusBar(name, parent, width, height, r, g, b)
    local bar = WINDOW_MANAGER:CreateControl(name, parent, CT_STATUSBAR)
    bar:SetDimensions(width or 200, height or 20)
    bar:SetColor(r or 1, g or 1, b or 1, 1)
    bar:SetMinMax(0, 100)
    bar:SetValue(0)
    bar:SetTexture("/esoui/art/miscellaneous/progressbar_genericfill.dds")
    return bar
end
-- Keep for backwards compat but no longer used
function ADK.UI.MakeBackdrop(name, parent, eR, eG, eB)
    local bg = WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP)
    bg:SetAnchorFill(parent)
    bg:SetCenterColor(0, 0, 0, 0)
    bg:SetEdgeTexture("", 1, 1, 0)
    return bg
end

-- ── Panel visibility: show main panel only when a DK enemy is active ─────────
ADK.UI.panelFlags = { wings = false, molten = false, powerLash = false }

function ADK.UI.SetPanelFlag(key, hasData)
    ADK.UI.panelFlags[key] = hasData
    if not ADK.UI.MainPanel then return end
    local any = false
    for _, v in pairs(ADK.UI.panelFlags) do
        if v then any = true; break end
    end
    ADK.UI.MainPanel:SetHidden(not any)
end

-- ── Main panel: transparent container, GCD-Tracker style ─────────────────────
local PANEL_W = 280
local PANEL_H = 230

local function SaveMainPos(win)
    ADK.savedVars.mainPanelX = win:GetLeft()
    ADK.savedVars.mainPanelY = win:GetTop()
end

function M.Init()
    local sv = ADK.savedVars
    local c  = ADK.COLORS

    local win = WINDOW_MANAGER:CreateTopLevelWindow("AntiDK2MainPanel")
    win:SetDimensions(PANEL_W, PANEL_H)
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.mainPanelX, sv.mainPanelY)
    win:SetMovable(true)
    win:SetMouseEnabled(true)
    win:SetClampedToScreen(true)
    win:SetHandler("OnMoveStop", function(w) SaveMainPos(w) end)
    win:SetScale(sv.mainPanelScale or 1.0)
    win:SetHidden(false)  -- hidden until a tracked DK enemy is detected

    -- Header label only, no background
    local hdr = ADK.UI.MakeLabel("AntiDK2MainHdr", win, ADK.UI.BoldFont(14),
        c.LIGHT_BLUE[1], c.LIGHT_BLUE[2], c.LIGHT_BLUE[3])
    hdr:SetText("|c5BCEFAAnti DK|r |cF5A9B82.0|r")
    hdr:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    hdr:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 2)

    ADK.UI.MainPanel = win
end
