TeamShadowsBuffs = TeamShadowsBuffs or {}

local TSB = TeamShadowsBuffs
local UI = {}
TSB.UI = UI

local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER
local UPDATE_NAME = "TeamShadowsBuffsUIUpdate"
local UPDATE_INTERVAL_MS = 100
local MAX_ROWS = 24
local GOLD = { r = 0.86, g = 0.72, b = 0.32, a = 0.9 }

-- [LOOK] cadre d'icone natif ESO (remplace le liseré blanc franc)
local ICON_FRAME = "/esoui/art/actionbar/abilityframe64_up.dds"
-- [LOOK] constantes du balayage radial, avec repli si l'API change de valeurs
local CD_RADIAL = (CD_TYPE_RADIAL ~= nil) and CD_TYPE_RADIAL or 1
local CD_UNTIL = (CD_TIME_TYPE_TIME_UNTIL ~= nil) and CD_TIME_TYPE_TIME_UNTIL or 0
-- seuil "buff bientot fini" (secondes) pour le feedback couleur
local LOW_TIME = 3

local barSerial = 0 -- noms uniques pour les ZO_DefaultStatusBar (sinon collision $(parent))

local function Saved()
    return TSB.savedVars or {}
end

local function CellSize()
    local size = tonumber(Saved().circleSize) or 40
    if size < 20 then return 20 end
    return size
end

local function CellScale()
    return CellSize() / 40
end

local function RowHeight()
    return CellSize() + zo_round(8 * CellScale())
end

local function WindowWidth()
    if Saved().showNames == false and Saved().showBar == false then
        return zo_round(96 * CellScale())
    end
    return zo_round(200 * CellScale())
end

local function BarWidth()
    return zo_round(124 * CellScale())
end

local function TimerTextScale()
    local scale = tonumber(Saved().timerTextScale) or 1
    if scale < 0.5 then return 0.5 end
    if scale > 3 then return 3 end
    return scale
end

local function GetFrameColor()
    local color = Saved().frameColor or {}
    return color.r or 0, color.g or 0, color.b or 0, Saved().frameAlpha or 0.78
end

local function GetBorderColor()
    local color = Saved().borderColor or GOLD
    return color.r or GOLD.r, color.g or GOLD.g, color.b or GOLD.b, Saved().borderAlpha or 0.95
end

local function GetSavedColor(key)
    local color = Saved()[key] or {}
    return color.r or 1, color.g or 1, color.b or 1, color.a or 1
end

local function SavedAlpha(key, defaultValue)
    local alpha = tonumber(Saved()[key])
    if alpha == nil then return defaultValue end
    if alpha < 0 then return 0 end
    if alpha > 1 then return 1 end
    return alpha
end

local function ApplySavedTextColor(label, key, alpha)
    local r, g, b, a = GetSavedColor(key)
    label:SetColor(r, g, b, (a or 1) * alpha)
end

local function BorderThickness()
    local thickness = tonumber(Saved().borderThickness) or 3
    if thickness < 2 then return 2 end
    return zo_round(thickness)
end

local function CreateBackdrop(parent)
    local bg = WM:CreateControl(nil, parent, CT_BACKDROP)
    bg:SetAnchorFill(parent)
    local r, g, b, a = GetFrameColor()
    bg:SetCenterColor(r, g, b, a)
    bg:SetEdgeColor(0, 0, 0, 0)
    bg:SetEdgeTexture("", 1, 1, 2)
    return bg
end

local function ApplyFrameStyle(parent)
    if not parent then return end

    if parent.bg then
        local fr, fg, fb, fa = GetFrameColor()
        parent.bg:SetCenterColor(fr, fg, fb, fa)
        parent.bg:SetEdgeColor(0, 0, 0, 0)
    end

    local br, bg, bb, ba = GetBorderColor()
    local hidden = Saved().borderEnabled == false
    -- [LOOK] corner = 0 : les bords se rejoignent aux angles (plus de cadre "cassé")
    local corner = 0
    local thickness = BorderThickness()

    if parent.borderLeft then
        parent.borderLeft:ClearAnchors()
        parent.borderLeft:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, corner)
        parent.borderLeft:SetAnchor(BOTTOMLEFT, parent, BOTTOMLEFT, 0, -corner)
        parent.borderLeft:SetWidth(thickness)
        parent.borderLeft:SetCenterColor(br, bg, bb, ba)
        parent.borderLeft:SetHidden(hidden)
    end
    if parent.borderRight then
        parent.borderRight:ClearAnchors()
        parent.borderRight:SetAnchor(TOPRIGHT, parent, TOPRIGHT, 0, corner)
        parent.borderRight:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, -corner)
        parent.borderRight:SetWidth(thickness)
        parent.borderRight:SetCenterColor(br, bg, bb, ba)
        parent.borderRight:SetHidden(hidden)
    end
    if parent.borderTop then
        parent.borderTop:ClearAnchors()
        parent.borderTop:SetAnchor(TOPLEFT, parent, TOPLEFT, corner, 0)
        parent.borderTop:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -corner, 0)
        parent.borderTop:SetHeight(thickness)
        parent.borderTop:SetCenterColor(br, bg, bb, ba)
        parent.borderTop:SetHidden(hidden)
    end
    if parent.borderBottom then
        parent.borderBottom:ClearAnchors()
        parent.borderBottom:SetAnchor(BOTTOMLEFT, parent, BOTTOMLEFT, corner, 0)
        parent.borderBottom:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, -corner, 0)
        parent.borderBottom:SetHeight(thickness)
        parent.borderBottom:SetCenterColor(br, bg, bb, ba)
        parent.borderBottom:SetHidden(hidden)
    end
end

local function CreateGoldBorders(parent)
    local function MakeLine()
        local line = WM:CreateControl(nil, parent, CT_BACKDROP)
        local r, g, b, a = GetBorderColor()
        line:SetCenterColor(r, g, b, a)
        line:SetEdgeColor(0, 0, 0, 0)
        line:SetEdgeTexture("", 1, 1, 1)
        return line
    end

    parent.borderLeft = MakeLine()
    parent.borderLeft:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
    parent.borderLeft:SetAnchor(BOTTOMLEFT, parent, BOTTOMLEFT, 0, 0)
    parent.borderLeft:SetWidth(BorderThickness())

    parent.borderRight = MakeLine()
    parent.borderRight:SetAnchor(TOPRIGHT, parent, TOPRIGHT, 0, 0)
    parent.borderRight:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, 0)
    parent.borderRight:SetWidth(BorderThickness())

    parent.borderTop = MakeLine()
    parent.borderTop:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
    parent.borderTop:SetAnchor(TOPRIGHT, parent, TOPRIGHT, 0, 0)
    parent.borderTop:SetHeight(BorderThickness())

    parent.borderBottom = MakeLine()
    parent.borderBottom:SetAnchor(BOTTOMLEFT, parent, BOTTOMLEFT, 0, 0)
    parent.borderBottom:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, 0)
    parent.borderBottom:SetHeight(BorderThickness())

    ApplyFrameStyle(parent)
end

local function CreateLabel(parent, font, r, g, b, a)
    local label = WM:CreateControl(nil, parent, CT_LABEL)
    label:SetFont(font or "ZoFontGame")
    label:SetColor(r or 1, g or 1, b or 1, a or 1)
    return label
end

local function AnchorWindow(control, x, y)
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x or 0, y or 0)
end

local function SaveWindowPosition(control, xKey, yKey)
    if not TSB.savedVars then return end
    TSB.savedVars[xKey] = control:GetLeft()
    TSB.savedVars[yKey] = control:GetTop()
end

local function SaveTrackerPosition(control, key)
    if not TSB.savedVars or not key then return end
    TSB.savedVars.trackerPositions = TSB.savedVars.trackerPositions or {}
    TSB.savedVars.trackerPositions[key] = {
        x = control:GetLeft(),
        y = control:GetTop(),
    }
end

local function MakeWindow(name, title, xKey, yKey)
    local win = WM:CreateTopLevelWindow(name)
    win:SetMouseEnabled(true)
    win:SetMovable(true)
    win:SetClampedToScreen(true)
    win:SetHidden(true)
    win.xKey = xKey
    win.yKey = yKey
    win.bg = CreateBackdrop(win)
    CreateGoldBorders(win)

    win.title = CreateLabel(win, "ZoFontGameBold", 0.25, 0.8, 1, 1)
    win.title:SetText(title)

    win.divider = WM:CreateControl(nil, win, CT_BACKDROP)
    win.divider:SetCenterColor(GOLD.r, GOLD.g, GOLD.b, 0.65)
    win.divider:SetEdgeColor(0, 0, 0, 0)
    win.divider:SetEdgeTexture("", 1, 1, 1)

    win:SetHandler("OnMoveStop", function(control)
        SaveWindowPosition(control, xKey, yKey)
    end)

    return win
end

local function MakeTrackerWindow(key)
    local safeKey = tostring(key or "tracker"):gsub("[^%w_]", "_")
    local win = WM:CreateTopLevelWindow("TeamShadowsBuffsTracker" .. safeKey)
    win:SetMouseEnabled(true)
    win:SetMovable(true)
    win:SetClampedToScreen(true)
    win:SetHidden(true)
    win.trackerKey = key
    win.bg = CreateBackdrop(win)
    CreateGoldBorders(win)
    win:SetHandler("OnMoveStop", function(control)
        SaveTrackerPosition(control, control.trackerKey)
    end)
    return win
end

local function ApplyWindowChrome(window)
    if not window or not window.title then return end

    ApplyFrameStyle(window)
    window.title:SetHidden(true)

    if window.divider then
        window.divider:SetHidden(true)
    end
end

local function Remaining(item)
    if not item then return nil end
    if item.endTime and GetGameTimeSeconds then
        return item.endTime - GetGameTimeSeconds()
    end
    return tonumber(item.remaining)
end

local function RemainingText(item)
    local remaining = Remaining(item)
    if not remaining or remaining <= 0 then return "0" end
    if remaining < 20 then return string.format("%.1f", remaining) end
    return tostring(zo_round(remaining))
end

local function RemainingRatio(item)
    if not item then return 0 end
    local duration = tonumber(item.duration) or 0
    if duration <= 0 then return 1 end
    local remaining = Remaining(item) or 0
    local ratio = remaining / duration
    if ratio < 0 then return 0 end
    if ratio > 1 then return 1 end
    return ratio
end

local function GetColor(item)
    local color = item and item.color or {}
    return color.r or 0.25, color.g or 0.7, color.b or 1, color.a or 1
end

local function CreateRow(parent)
    local row = WM:CreateControl(nil, parent, CT_CONTROL)

    -- [LOOK] socle sombre sous l'icone (remplace le liseré blanc franc)
    row.badge = WM:CreateControl(nil, row, CT_BACKDROP)
    row.badge:SetCenterColor(0, 0, 0, 0.5)
    row.badge:SetEdgeColor(0, 0, 0, 0.85)
    row.badge:SetEdgeTexture("", 1, 1, 1)

    row.icon = WM:CreateControl(nil, row.badge, CT_TEXTURE)
    row.icon:SetDrawLayer(DL_CONTROLS)
    -- [LOOK] rogne le bord sombre intégré aux icones ESO pour un carré net
    row.icon:SetTextureCoords(0.06, 0.94, 0.06, 0.94)

    -- [LOOK] balayage radial type "cooldown" : la part de camembert qui s'assombrit.
    -- Si jamais ça pose souci en jeu, commente ce bloc et les refs à row.cd plus bas.
    row.cd = WM:CreateControl(nil, row.badge, CT_COOLDOWN)
    row.cd:SetDrawLayer(DL_CONTROLS)
    row.cd:SetDrawLevel(2)
    if row.cd.SetFillColor then row.cd:SetFillColor(0, 0, 0, 0.55) end

    -- [LOOK] cadre d'icone natif ESO par-dessus le socle
    row.frame = WM:CreateControl(nil, row.badge, CT_TEXTURE)
    row.frame:SetTexture(ICON_FRAME)
    row.frame:SetDrawLayer(DL_OVERLAY)
    row.frame:SetDrawLevel(1)

    -- [LOOK] acronyme en police à contour -> lisible sur n'importe quelle icone
    row.acronym = CreateLabel(row.badge, "ZoFontGameOutline", 1, 1, 1, 1)
    row.acronym:SetDrawLayer(DL_OVERLAY)
    row.acronym:SetDrawLevel(3)
    row.acronym:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    row.acronym:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    -- compteur de stacks (coin bas-droit de l'icone), masqué par défaut
    row.stacks = CreateLabel(row.badge, "ZoFontGameOutline", 1, 1, 1, 1)
    row.stacks:SetDrawLayer(DL_OVERLAY)
    row.stacks:SetDrawLevel(4)
    row.stacks:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.stacks:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    row.stacks:SetHidden(true)

    row.name = CreateLabel(row, "ZoFontGameBold", 1, 1, 1, 1)
    row.name:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    -- [LOOK] timer à contour aussi (très lisible en combat)
    row.timer = CreateLabel(row, "ZoFontGameOutline", 1, 1, 1, 1)
    row.timer:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.timer:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    -- [LOOK] piste sombre derrière la barre
    row.barBg = WM:CreateControl(nil, row, CT_BACKDROP)
    row.barBg:SetCenterColor(0.02, 0.02, 0.02, 0.85)
    row.barBg:SetEdgeColor(0, 0, 0, 0.9)
    row.barBg:SetEdgeTexture("", 1, 1, 1)

    -- [LOOK] barre native ESO avec dégradé + gloss (au lieu d'un rectangle plat)
    barSerial = barSerial + 1
    row.bar = WM:CreateControlFromVirtual("TeamShadowsBuffsBar" .. barSerial, row.barBg, "ZO_DefaultStatusBar")
    row.bar:SetMinMax(0, 1)
    row.bar:SetValue(1)

    row:SetHidden(true)
    return row
end

local function LayoutRow(row, parent, index, topOffset)
    local cell = CellSize()
    local scale = CellScale()
    local rowHeight = RowHeight()
    local width = WindowWidth() - zo_round(20 * scale)
    local badgeSize = zo_round(cell * 0.78)
    local barHeight = zo_max(6, zo_round(8 * scale))
    local showNames = Saved().showNames ~= false
    local showTimers = Saved().showTimers ~= false
    local showBar = Saved().showBar ~= false
    local timerWidth = showTimers and zo_round(48 * scale) or 0
    local textX = badgeSize + zo_round(10 * scale)
    local barWidth = BarWidth()

    row:ClearAnchors()
    topOffset = topOffset or zo_round(32 * scale)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, zo_round(10 * scale), topOffset + ((index - 1) * rowHeight))
    row:SetDimensions(width, rowHeight)

    row.badge:ClearAnchors()
    row.badge:SetAnchor(LEFT, row, LEFT, 0, 0)
    row.badge:SetDimensions(badgeSize, badgeSize)

    row.icon:ClearAnchors()
    row.icon:SetAnchorFill(row.badge)

    row.cd:ClearAnchors()
    row.cd:SetAnchorFill(row.badge)

    -- cadre légèrement plus grand que le socle (le frame ESO a du vide sur les bords)
    local fpad = zo_round(badgeSize * 0.14)
    row.frame:ClearAnchors()
    row.frame:SetAnchor(TOPLEFT, row.badge, TOPLEFT, -fpad, -fpad)
    row.frame:SetAnchor(BOTTOMRIGHT, row.badge, BOTTOMRIGHT, fpad, fpad)

    row.acronym:ClearAnchors()
    row.acronym:SetAnchorFill(row.badge)
    row.acronym:SetScale(scale)

    row.stacks:ClearAnchors()
    row.stacks:SetAnchor(BOTTOMRIGHT, row.badge, BOTTOMRIGHT, -zo_round(1 * scale), -zo_round(1 * scale))
    row.stacks:SetScale(scale)

    row.name:ClearAnchors()
    row.name:SetAnchor(TOPLEFT, row, TOPLEFT, textX, 0)
    row.name:SetDimensions(width - textX - timerWidth, zo_round(18 * scale))
    row.name:SetScale(scale)
    row.name:SetHidden(not showNames)

    row.timer:ClearAnchors()
    if showNames or showBar then
        row.timer:SetAnchor(TOPRIGHT, row, TOPRIGHT, 0, 0)
    else
        row.timer:SetAnchor(LEFT, row.badge, RIGHT, zo_round(6 * scale), 0)
    end
    row.timer:SetDimensions(timerWidth, zo_round(18 * scale))
    row.timer:SetScale(scale * TimerTextScale())
    row.timer:SetHidden(not showTimers)

    row.barBg:ClearAnchors()
    row.barBg:SetAnchor(TOPLEFT, row, TOPLEFT, textX, showNames and zo_round(24 * scale) or zo_round(4 * scale))
    row.barBg:SetDimensions(barWidth, barHeight)
    row.barBg:SetHidden(not showBar)

    -- la barre native remplit la piste (1px d'inset -> la piste fait office de liseré)
    row.bar:ClearAnchors()
    row.bar:SetAnchor(TOPLEFT, row.barBg, TOPLEFT, 1, 1)
    row.bar:SetAnchor(BOTTOMRIGHT, row.barBg, BOTTOMRIGHT, -1, -1)
    row.bar:SetHidden(not showBar)
end

local function UpdateRow(row)
    local item = row.item
    if not item then return end

    local r, g, b, a = GetColor(item)
    local ratio = RemainingRatio(item)
    local remaining = Remaining(item) or 0
    local isExpired = ratio <= 0
    local isLow = (not isExpired) and remaining <= LOW_TIME

    -- [LOOK] couleur d'état : rouge à l'expiration, ambre quand ça va tomber, sinon couleur de l'effet
    local cr, cg, cb = r, g, b
    if isExpired then
        cr, cg, cb = 0.9, 0.05, 0.05
    elseif isLow then
        cr, cg, cb = 0.95, 0.42, 0.18
    end

    local badgeAlpha = SavedAlpha("badgeAlpha", 0.95)
    local barAlpha = SavedAlpha("barAlpha", 0.95)
    local textAlpha = SavedAlpha("textAlpha", 1)
    local icon = item.icon

    if icon and icon ~= "" then
        row.icon:SetTexture(icon)
        row.icon:SetColor(1, 1, 1, badgeAlpha)
        row.icon:SetHidden(false)
        row.badge:SetCenterColor(0, 0, 0, 0.5 * badgeAlpha)
        row.frame:SetHidden(false)
        row.frame:SetColor(1, 1, 1, badgeAlpha)

        -- balayage radial : on (re)lance seulement quand l'application change (endTime),
        -- le contrôle s'anime tout seul entre deux applications.
        if row.cd and row.cd.StartCooldown then
            row.cd:SetHidden(false)
            local total = tonumber(item.duration) or remaining
            if row.cdEnd ~= item.endTime then
                row.cdEnd = item.endTime
                row.cd:StartCooldown(zo_max(remaining, 0) * 1000, zo_max(total, 0.001) * 1000, CD_RADIAL, CD_UNTIL, false)
            end
        end
    else
        -- pas d'icone : tuile colorée, on masque cadre + balayage
        row.icon:SetHidden(true)
        row.badge:SetCenterColor(cr, cg, cb, badgeAlpha)
        row.frame:SetHidden(true)
        if row.cd then
            row.cd:SetHidden(true)
            row.cdEnd = nil
        end
    end
    row.badge:SetEdgeColor(0, 0, 0, 0.85 * badgeAlpha)

    -- barre : valeur + dégradé (clair en haut, sombre en bas)
    row.barBg:SetCenterColor(0.02, 0.02, 0.02, 0.85 * barAlpha)
    row.barBg:SetEdgeColor(0, 0, 0, 0.9 * barAlpha)
    row.bar:SetValue(ratio)
    if row.bar.SetGradientColors then
        local ba = (a or 0.95) * barAlpha
        row.bar:SetGradientColors(cr, cg, cb, ba, cr * 0.45, cg * 0.45, cb * 0.45, ba)
    end

    ApplySavedTextColor(row.acronym, "acronymTextColor", badgeAlpha)
    ApplySavedTextColor(row.name, "nameTextColor", textAlpha)
    -- timer : couleur réglable, mais on prend la main pour le feedback bas-timer
    if isExpired then
        row.timer:SetColor(0.95, 0.2, 0.2, textAlpha)
    elseif isLow then
        row.timer:SetColor(0.98, 0.58, 0.22, textAlpha)
    else
        ApplySavedTextColor(row.timer, "timerTextColor", textAlpha)
    end

    row.acronym:SetText(item.shortName or "?")
    row.acronym:SetHidden(Saved().showAcronyms == false)
    row.timer:SetText(RemainingText(item))
    row.name:SetText(item.name or "")

    -- compteur de stacks (coin bas-droit de l'icone) pour les sets/compétences à stacks
    local stacks = tonumber(item.stacks) or 0
    if item.maxStacks and stacks > 1 then
        row.stacks:SetText(tostring(stacks))
        row.stacks:SetColor(1, 0.95, 0.55, badgeAlpha)
        row.stacks:SetHidden(false)
    else
        row.stacks:SetHidden(true)
    end
end

local function EnsureRows(ui, key, parent)
    ui.rows[key] = ui.rows[key] or {}
    for i = #ui.rows[key] + 1, MAX_ROWS do
        ui.rows[key][i] = CreateRow(parent)
    end
end

local function HasItems(data)
    return data and data.combined and #data.combined > 0
end

local function GetDisplayData()
    local data = TSB.GetDisplayItems and TSB.GetDisplayItems() or { player = {}, boss = {}, combined = {} }
    if Saved().previewEnabled ~= false and TSB.settingsPanelOpen == true and TSB.GetPreviewDisplayItems then
        TSB.previewDisplayActive = true
        return TSB.GetPreviewDisplayItems()
    end
    TSB.previewDisplayActive = false
    return data
end

local function HideRows(rows)
    for _, row in ipairs(rows or {}) do
        row.item = nil
        row:SetHidden(true)
    end
end

local function DrawListWindow(ui, key, window, items)
    items = items or {}
    local rows = ui.rows[key] or {}
    local count = #items
    if count > MAX_ROWS then count = MAX_ROWS end

    local scale = CellScale()
    local topOffset = zo_round(8 * scale)
    ApplyWindowChrome(window)

    for i = 1, MAX_ROWS do
        local row = rows[i]
        if i <= count then
            row.item = items[i]
            LayoutRow(row, window, i, topOffset)
            UpdateRow(row)
            row:SetHidden(false)
        else
            row.item = nil
            row:SetHidden(true)
        end
    end

    local width = WindowWidth()
    local height = count > 0 and (topOffset + zo_round(8 * scale) + (count * RowHeight())) or zo_round(46 * scale)
    if window.lastWidth ~= width or window.lastHeight ~= height then
        window:SetDimensions(width, height)
        window.lastWidth = width
        window.lastHeight = height
    end
    window:SetHidden(count == 0)
end

local function HideListWindows(ui)
    ui.combined:SetHidden(true)
    ui.buffs:SetHidden(true)
    ui.debuffs:SetHidden(true)
    HideRows(ui.rows.combined)
    HideRows(ui.rows.buffs)
    HideRows(ui.rows.debuffs)
end

local function PreviewPosition(index)
    local rootWidth = GuiRoot and GuiRoot.GetWidth and GuiRoot:GetWidth() or 1920
    local x = zo_round(rootWidth * 0.66)
    local y = 180 + ((index or 0) * zo_round(180 * CellScale()))
    return x, y
end

local function AnchorPreviewListWindows(ui, layout)
    if not TSB.previewDisplayActive then return end
    -- [FIX] déverrouillé = tu places les fenêtres -> l'aperçu ne force plus la position
    if Saved().unlocked == true then return end

    if layout == "separate" then
        local x, y = PreviewPosition(0)
        AnchorWindow(ui.buffs, x, y)
        AnchorWindow(ui.debuffs, x, y + zo_round(190 * CellScale()))
    else
        local x, y = PreviewPosition(0)
        AnchorWindow(ui.combined, x, y)
    end
end

local function PositionTrackerWindow(win, item, index)
    -- [FIX] aperçu ignoré quand déverrouillé : on respecte la position sauvegardée / le drag
    if TSB.previewDisplayActive and Saved().unlocked ~= true then
        local x, y = PreviewPosition(0)
        AnchorWindow(win, x, y + ((index - 1) * RowHeight()))
        return
    end

    local positions = Saved().trackerPositions or {}
    local saved = positions[item.key]
    if saved then
        AnchorWindow(win, saved.x, saved.y)
        return
    end

    local startX = tonumber(Saved().combinedX) or 920
    local startY = tonumber(Saved().combinedY) or 480
    AnchorWindow(win, startX, startY + ((index - 1) * RowHeight()))
end

local function DrawIndividualWindows(ui, items)
    items = items or {}
    ui.trackerWindows = ui.trackerWindows or {}

    local seen = {}
    for i, item in ipairs(items) do
        local key = item.key or ("tracker" .. tostring(i))
        local win = ui.trackerWindows[key]
        if not win then
            win = MakeTrackerWindow(key)
            win.row = CreateRow(win)
            ui.trackerWindows[key] = win
        end

        seen[key] = true
        win.trackerKey = key
        PositionTrackerWindow(win, item, i)
        ApplyFrameStyle(win)
        win:SetScale(tonumber(Saved().scale) or 1)
        win:SetMovable(Saved().unlocked == true)

        local scale = CellScale()
        local width = WindowWidth()
        local height = RowHeight() + zo_round(16 * scale)
        if win.lastWidth ~= width or win.lastHeight ~= height then
            win:SetDimensions(width, height)
            win.lastWidth = width
            win.lastHeight = height
        end

        win.row.item = item
        LayoutRow(win.row, win, 1, zo_round(8 * scale))
        UpdateRow(win.row)
        win.row:SetHidden(false)
        win:SetHidden(false)
    end

    for key, win in pairs(ui.trackerWindows or {}) do
        if not seen[key] then
            win:SetHidden(true)
            if win.row then
                win.row.item = nil
                win.row:SetHidden(true)
            end
        end
    end
end

local function HideIndividualWindows(ui)
    for _, win in pairs(ui.trackerWindows or {}) do
        win:SetHidden(true)
        if win.row then
            win.row.item = nil
            win.row:SetHidden(true)
        end
    end
end

function UI:Initialize()
    if self.initialized then return end

    self.combined = MakeWindow("TeamShadowsBuffsCombined", "BUFFS / DEBUFFS", "combinedX", "combinedY")
    self.buffs = MakeWindow("TeamShadowsBuffsPlayerBuffs", "BUFFS", "buffsX", "buffsY")
    self.debuffs = MakeWindow("TeamShadowsBuffsBossDebuffs", "DEBUFFS", "debuffsX", "debuffsY")
    self.rows = {}
    self.trackerWindows = {}

    EnsureRows(self, "combined", self.combined)
    EnsureRows(self, "buffs", self.buffs)
    EnsureRows(self, "debuffs", self.debuffs)

    EM:RegisterForUpdate(UPDATE_NAME, UPDATE_INTERVAL_MS, function()
        self:UpdateVisibleRows()
    end)

    self.initialized = true
end

function UI:ApplySettings()
    if not self.initialized or not TSB.savedVars then return end

    AnchorWindow(self.combined, TSB.savedVars.combinedX, TSB.savedVars.combinedY)
    AnchorWindow(self.buffs, TSB.savedVars.buffsX, TSB.savedVars.buffsY)
    AnchorWindow(self.debuffs, TSB.savedVars.debuffsX, TSB.savedVars.debuffsY)

    local scale = tonumber(TSB.savedVars.scale) or 1
    self.combined:SetScale(scale)
    self.buffs:SetScale(scale)
    self.debuffs:SetScale(scale)

    local unlocked = TSB.savedVars.unlocked == true
    self.combined:SetMovable(unlocked)
    self.buffs:SetMovable(unlocked)
    self.debuffs:SetMovable(unlocked)

    self:Refresh()
end

function UI:Refresh()
    if not self.initialized or not TSB.savedVars then return end
    if TSB.savedVars.enabled ~= true then
        self:Shutdown()
        return
    end

    local data = GetDisplayData()
    local layout = TSB.NormalizeLayout and TSB.NormalizeLayout(TSB.savedVars.layout) or (TSB.savedVars.layout or "combined")
    AnchorPreviewListWindows(self, layout)

    if layout == "separate" then
        self.combined:SetHidden(true)
        HideIndividualWindows(self)
        DrawListWindow(self, "buffs", self.buffs, data.player)
        DrawListWindow(self, "debuffs", self.debuffs, data.boss)
    elseif layout == "individual" then
        HideListWindows(self)
        DrawIndividualWindows(self, data.combined)
    else
        self.buffs:SetHidden(true)
        self.debuffs:SetHidden(true)
        HideIndividualWindows(self)
        DrawListWindow(self, "combined", self.combined, data.combined)
    end
end

function UI:UpdateVisibleRows()
    if not self.initialized or not TSB.savedVars or TSB.savedVars.enabled ~= true then return end

    local expired = false
    for _, rows in pairs(self.rows or {}) do
        for _, row in ipairs(rows or {}) do
            if not row:IsHidden() and row.item then
                if (Remaining(row.item) or 0) <= 0 then
                    expired = true
                else
                    UpdateRow(row)
                end
            end
        end
    end

    for _, win in pairs(self.trackerWindows or {}) do
        local row = win.row
        if row and not row:IsHidden() and row.item then
            if (Remaining(row.item) or 0) <= 0 then
                expired = true
            else
                UpdateRow(row)
            end
        end
    end

    if expired and TSB.NotifyDisplayChanged then
        TSB.NotifyDisplayChanged()
    end
end

function UI:Shutdown()
    if not self.initialized then return end
    self.combined:SetHidden(true)
    self.buffs:SetHidden(true)
    self.debuffs:SetHidden(true)
    HideIndividualWindows(self)
end
