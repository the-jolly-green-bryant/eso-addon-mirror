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
local GROUP_ROLE_COLORS = {
    [LFG_ROLE_TANK] = { 1.00, 0.20, 0.16 },
    [LFG_ROLE_HEAL] = { 1.00, 0.82, 0.18 },
    [LFG_ROLE_DPS] = { 0.22, 0.62, 1.00 },
}

local barSerial = 0 -- noms uniques pour les ZO_DefaultStatusBar (sinon collision $(parent))

local function Saved()
    return TSB.savedVars or {}
end

local function PanelStyle(item)
    local destination = item and item.destination
    if not destination or not destination:match("^panel[1-4]$") then return nil end
    return Saved().panelSettings and Saved().panelSettings[destination] or nil
end

local function StyleValue(item, key)
    local style = PanelStyle(item)
    if style and style[key] ~= nil then return style[key] end
    if item and item.destination == "group" and item.key then
        local settings = (Saved().effectSettings or {})[item.key] or {}
        if settings[key] ~= nil then return settings[key] end
    end
    return Saved()[key]
end

local function CellSize(item)
    local size = tonumber(StyleValue(item, "circleSize")) or 40
    if size < 20 then return 20 end
    return size
end

local function CellScale(item)
    return CellSize(item) / 40
end

local function RowHeight(item)
    return CellSize(item) + zo_round(8 * CellScale(item))
end

local function TimerTextScale(item)
    local scale = tonumber(StyleValue(item, "timerTextScale")) or 1
    if scale < 0.5 then return 0.5 end
    if scale > 3 then return 3 end
    return scale
end

local function WindowWidth(item)
    if StyleValue(item, "showNames") == false and StyleValue(item, "showBar") == false then
        -- mode icone seule : la fenetre suit la taille reelle du timer (echelle comprise)
        -- pour que le texte reste colle a l'icone au lieu de flotter dans un cadre trop large
        local base = zo_round(48 * CellScale(item))
        if StyleValue(item, "showTimers") == false then
            return base + zo_round(8 * CellScale(item))
        end
        return base + zo_round(48 * CellScale(item) * TimerTextScale(item))
    end
    return zo_round(180 * CellScale(item))
end

local function ItemWindowWidth(item)
    if item and item.compact == true then
        return zo_round(116 * CellScale(item))
    end
    return WindowWidth(item)
end

local function BarWidth(item)
    return zo_round(104 * CellScale(item))
end

local function GetFrameColor(item)
    local color = StyleValue(item, "frameColor") or {}
    return color.r or 0, color.g or 0, color.b or 0, StyleValue(item, "frameAlpha") or 0.78
end

local function GetBorderColor(item)
    local color = StyleValue(item, "borderColor") or GOLD
    return color.r or GOLD.r, color.g or GOLD.g, color.b or GOLD.b, StyleValue(item, "borderAlpha") or 0.95
end

local function GetSavedColor(key, item)
    local color = StyleValue(item, key) or {}
    return color.r or 1, color.g or 1, color.b or 1, color.a or 1
end

local function SavedAlpha(key, defaultValue, item)
    local alpha = tonumber(StyleValue(item, key))
    if alpha == nil then return defaultValue end
    if alpha < 0 then return 0 end
    if alpha > 1 then return 1 end
    return alpha
end

local function ApplySavedTextColor(label, key, alpha, item)
    local r, g, b, a = GetSavedColor(key, item)
    label:SetColor(r, g, b, (a or 1) * alpha)
end

local function EffectSettings(key)
    local settings = Saved().effectSettings or {}
    return settings[key] or {}
end

local function ShowStacksFor(item)
    if not item or not item.maxStacks then return false end
    local panelStyle = PanelStyle(item)
    if panelStyle and panelStyle.showStacks ~= nil then return panelStyle.showStacks == true end
    local settings = EffectSettings(item.key)
    if settings.showStacks ~= nil then return settings.showStacks == true end
    return StyleValue(item, "showStacks") ~= false
end

local function GetStackColor(item)
    local settings = EffectSettings(item and item.key)
    local panelStyle = PanelStyle(item)
    local color = (panelStyle and panelStyle.stackTextColor) or settings.stackTextColor or Saved().stackTextColor or {}
    return color.r or 1, color.g or 0.95, color.b or 0.55, color.a or 1
end

local function BorderThickness(item)
    local thickness = tonumber(StyleValue(item, "borderThickness")) or 3
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

local function ApplyFrameStyle(parent, item)
    if not parent then return end

    if parent.bg then
        local fr, fg, fb, fa = GetFrameColor(item)
        parent.bg:SetCenterColor(fr, fg, fb, fa)
        parent.bg:SetEdgeColor(0, 0, 0, 0)
    end

    local br, bg, bb, ba = GetBorderColor(item)
    local hidden = StyleValue(item, "borderEnabled") == false
    -- [LOOK] corner = 0 : les bords se rejoignent aux angles (plus de cadre "cassé")
    local corner = 0
    local thickness = BorderThickness(item)

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

local function SaveGroupTrackerPosition(control, key)
    if not TSB.savedVars or not key then return end
    TSB.savedVars.groupTrackerPositions = TSB.savedVars.groupTrackerPositions or {}
    TSB.savedVars.groupTrackerPositions[key] = {
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

local function MakeGroupTrackerWindow(key)
    local safeKey = tostring(key or "group"):gsub("[^%w_]", "_")
    local win = WM:CreateTopLevelWindow("TeamShadowsBuffsGroup" .. safeKey)
    win:SetMouseEnabled(true)
    win:SetMovable(true)
    win:SetClampedToScreen(true)
    win:SetHidden(true)
    win.trackerKey = key
    win.bg = CreateBackdrop(win)
    CreateGoldBorders(win)

    win.icon = WM:CreateControl(nil, win, CT_TEXTURE)
    win.icon:SetTextureCoords(0.06, 0.94, 0.06, 0.94)
    win.icon:SetDrawLayer(DL_CONTROLS)
    win.iconFrame = WM:CreateControl(nil, win, CT_TEXTURE)
    win.iconFrame:SetTexture(ICON_FRAME)
    win.iconFrame:SetDrawLayer(DL_OVERLAY)
    win.status = CreateLabel(win, "ZoFontWinH4", 1, 1, 1, 1)
    win.status:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    win.status:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    win.status:SetDrawLayer(DL_OVERLAY)
    win.status:SetHidden(true)

    win.members = {}
    for i = 1, 12 do
        local cell = WM:CreateControl(nil, win, CT_CONTROL)
        cell.name = CreateLabel(cell, "ZoFontGameBold", 0.55, 0.55, 0.55, 1)
        cell.name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        cell.timer = CreateLabel(cell, "ZoFontGameOutline", 0.55, 0.55, 0.55, 1)
        cell.timer:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        cell.timer:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        cell:SetHidden(true)
        win.members[i] = cell
    end

    win:SetHandler("OnMoveStart", function(control)
        control.isDragging = true
    end)
    win:SetHandler("OnMoveStop", function(control)
        SaveGroupTrackerPosition(control, control.trackerKey)
        control.isDragging = false
    end)
    return win
end

local function ApplyWindowChrome(window, item)
    if not window or not window.title then return end

    ApplyFrameStyle(window, item)
    window.title:SetHidden(true)

    if window.divider then
        window.divider:SetHidden(true)
    end
end

local function Remaining(item)
    if not item then return nil end
    if item.permanent then return math.huge end
    if item.endTime and GetGameTimeSeconds then
        return item.endTime - GetGameTimeSeconds()
    end
    return tonumber(item.remaining)
end

local function RemainingText(item)
    if item and item.permanent then return "" end
    local remaining = Remaining(item)
    if not remaining or remaining <= 0 then return "0.0" end
    return string.format("%.1f", remaining)
end

local function CompactTimerAbove(item)
    return item and item.compact == true and item.compactTimerPosition ~= "inside"
end

local function CompactOverlayAbove(item)
    if CompactTimerAbove(item) then return true end
    return item and item.compact == true and item.compactTimerPosition == "inside"
        and item.maxStacks and ShowStacksFor(item)
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
    row.stacks:SetDrawLevel(5)
    row.stacks:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    row.stacks:SetVerticalAlignment(TEXT_ALIGN_CENTER)
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
    local item = row.item
    local cell = CellSize(item)
    local scale = CellScale(item)
    local rowHeight = RowHeight(item)
    local width = ItemWindowWidth(row.item) - zo_round(20 * scale)
    local badgeSize = zo_round(cell * 0.78)
    local barHeight = zo_max(6, zo_round(8 * scale))
    local compact = row.item and row.item.compact == true
    local showNames = (not compact) and StyleValue(item, "showNames") ~= false
    local showTimers = StyleValue(item, "showTimers") ~= false
    local showBar = (not compact) and StyleValue(item, "showBar") ~= false
    local timerWidth = showTimers and (compact and badgeSize or zo_round(42 * scale)) or 0
    local textX = badgeSize + zo_round(10 * scale)
    local barWidth = BarWidth(item)

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
    if compact and item.compactTimerPosition == "inside" then
        row.stacks:SetAnchor(BOTTOM, row.badge, TOP, 0, 0)
        row.stacks:SetDimensions(badgeSize, zo_round(18 * scale))
    else
        row.stacks:SetAnchorFill(row.badge)
    end
    row.stacks:SetScale(scale * 1.18)

    -- place reelle occupee par le timer une fois l'echelle appliquee (evite que le
    -- texte agrandi chevauche le nom ou deborde de la fenetre)
    local timerReserve = showTimers and zo_round(timerWidth * TimerTextScale(item)) or 0

    row.name:ClearAnchors()
    row.name:SetAnchor(TOPLEFT, row, TOPLEFT, textX, 0)
    row.name:SetDimensions(zo_max(10, width - textX - (compact and 0 or timerReserve)), zo_round(18 * scale))
    row.name:SetScale(scale)
    row.name:SetHidden(not showNames)

    -- [FIX] alignement du timer selon le mode : sans nom ni jauge le texte se colle
    -- a l'icone (alignement gauche), au lieu de rester aligne a droite de son cadre
    -- invisible et de flotter loin de l'icone.
    row.timer:ClearAnchors()
    if compact then
        if item.compactTimerPosition == "inside" then
            row.timer:SetAnchor(TOP, row.badge, TOP, 0, zo_round(1 * scale))
        else
            row.timer:SetAnchor(BOTTOM, row.badge, TOP, 0, 0)
        end
        row.timer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    elseif showNames or showBar then
        row.timer:SetAnchor(TOPRIGHT, row, TOPRIGHT, 0, 0)
        row.timer:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    else
        row.timer:SetAnchor(LEFT, row.badge, RIGHT, zo_round(6 * scale), 0)
        row.timer:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    end
    row.timer:SetDimensions(timerWidth, zo_round(18 * scale))
    row.timer:SetScale(scale * TimerTextScale(item))
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
    local isLow = (not item.isCooldown) and (not isExpired) and remaining <= LOW_TIME

    -- [LOOK] couleur d'état : rouge à l'expiration, ambre quand ça va tomber, sinon couleur de l'effet
    local cr, cg, cb = r, g, b
    if isExpired then
        cr, cg, cb = 0.9, 0.05, 0.05
    elseif isLow then
        cr, cg, cb = 0.95, 0.42, 0.18
    end

    local badgeAlpha = SavedAlpha("badgeAlpha", 0.95, item)
    local barAlpha = SavedAlpha("barAlpha", 0.95, item)
    local textAlpha = SavedAlpha("textAlpha", 1, item)
    local icon = item.icon

    if icon and icon ~= "" then
        row.icon:SetTexture(icon)
        row.icon:SetColor(1, 1, 1, badgeAlpha)
        row.icon:SetHidden(false)
        row.badge:SetCenterColor(0, 0, 0, 0.5 * badgeAlpha)
        row.frame:SetHidden(false)
        row.frame:SetColor(cr, cg, cb, badgeAlpha)

        -- balayage radial : on (re)lance seulement quand l'application change (endTime),
        -- le contrôle s'anime tout seul entre deux applications.
        if item.permanent then
            row.cd:SetHidden(true)
            row.cdEnd = nil
        elseif row.cd and row.cd.StartCooldown then
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
    row.badge:SetEdgeColor(cr, cg, cb, 0.9 * badgeAlpha)

    -- barre : valeur + dégradé (clair en haut, sombre en bas)
    row.barBg:SetCenterColor(0.02, 0.02, 0.02, 0.85 * barAlpha)
    row.barBg:SetEdgeColor(0, 0, 0, 0.9 * barAlpha)
    row.bar:SetValue(ratio)
    if row.bar.SetGradientColors then
        local ba = (a or 0.95) * barAlpha
        row.bar:SetGradientColors(cr, cg, cb, ba, cr * 0.45, cg * 0.45, cb * 0.45, ba)
    end

    ApplySavedTextColor(row.acronym, "acronymTextColor", badgeAlpha, item)
    ApplySavedTextColor(row.name, "nameTextColor", textAlpha, item)
    -- timer : couleur réglable, mais on prend la main pour le feedback bas-timer
    if item.isCooldown then
        row.timer:SetColor(cr, cg, cb, textAlpha)
    elseif isExpired then
        row.timer:SetColor(0.95, 0.2, 0.2, textAlpha)
    elseif isLow then
        row.timer:SetColor(0.98, 0.58, 0.22, textAlpha)
    else
        ApplySavedTextColor(row.timer, "timerTextColor", textAlpha, item)
    end

    row.acronym:SetText(item.shortName or "?")
    row.acronym:SetHidden((item.compact == true) or StyleValue(item, "showAcronyms") == false)
    row.timer:SetText(RemainingText(item))
    row.name:SetText(item.name or "")

    -- compteur de stacks (coin bas-droit de l'icone) pour les sets/compétences à stacks
    local stacks = tonumber(item.stacks) or 0
    if ShowStacksFor(item) and stacks > 0 then
        local sr, sg, sb, sa = GetStackColor(item)
        row.stacks:SetText(tostring(stacks))
        row.stacks:SetColor(sr, sg, sb, (sa or 1) * badgeAlpha)
        row.stacks:SetHidden(false)
        row.acronym:SetHidden(true)
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

local function CreateHeadMarker(ui, key)
    local marker = WM:CreateControl(nil, ui.headMarkerRoot, CT_CONTROL)
    marker:SetDimensions(30, 30)
    marker:SetMouseEnabled(false)
    marker.bg = WM:CreateControl(nil, marker, CT_BACKDROP)
    marker.bg:SetAnchorFill(marker)
    marker.bg:SetCenterColor(0, 0, 0, 0.72)
    marker.bg:SetEdgeColor(GOLD.r, GOLD.g, GOLD.b, 0.95)
    marker.bg:SetEdgeTexture("", 1, 1, 1)
    marker.icon = WM:CreateControl(nil, marker, CT_TEXTURE)
    marker.icon:SetAnchor(TOPLEFT, marker, TOPLEFT, 2, 2)
    marker.icon:SetAnchor(BOTTOMRIGHT, marker, BOTTOMRIGHT, -2, -2)
    marker.icon:SetTextureCoords(0.06, 0.94, 0.06, 0.94)
    marker.center = CreateLabel(marker, "ZoFontGameOutline", 1, 1, 1, 1)
    marker.center:SetAnchorFill(marker)
    marker.center:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    marker.center:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    marker.timer = CreateLabel(marker, "ZoFontGameOutline", 1, 1, 1, 1)
    marker.timer:SetAnchor(BOTTOM, marker, TOP, 0, -1)
    marker.timer:SetDimensions(46, 18)
    marker.timer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    marker.timer:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    marker.key = key
    marker:SetHidden(true)
    return marker
end

local function UpdateHeadMarkerVisual(marker, item)
    local r, g, b = GetColor(item)
    if item.icon and item.icon ~= "" then
        marker.icon:SetTexture(item.icon)
        marker.icon:SetColor(1, 1, 1, SavedAlpha("badgeAlpha", 0.95))
        marker.icon:SetHidden(false)
        marker.bg:SetCenterColor(0, 0, 0, 0.72)
    else
        marker.icon:SetHidden(true)
        marker.bg:SetCenterColor(r, g, b, SavedAlpha("badgeAlpha", 0.95))
    end
    local stacks = tonumber(item.stacks) or 0
    if ShowStacksFor(item) and stacks > 0 then
        local sr, sg, sb, sa = GetStackColor(item)
        marker.center:SetText(tostring(stacks))
        marker.center:SetColor(sr, sg, sb, sa or 1)
    else
        marker.center:SetText("")
    end
    local remaining = zo_max(Remaining(item) or 0, 0)
    marker.timer:SetText(tostring(zo_round(remaining)))
    ApplySavedTextColor(marker.timer, "timerTextColor", SavedAlpha("textAlpha", 1))
end

local function DrawHeadMarkers(ui, items)
    ui.headMarkers = ui.headMarkers or {}
    local seen, slots = {}, {}
    for _, item in ipairs(items or {}) do
        local key = item.renderKey or item.key
        if key then
            local marker = ui.headMarkers[key]
            if not marker then
                marker = CreateHeadMarker(ui, key)
                ui.headMarkers[key] = marker
            end
            local unitTag = item.unitTag
            if not unitTag or unitTag == "" then unitTag = item.targetType == "player" and "player" or "reticleover" end
            slots[unitTag] = (slots[unitTag] or 0) + 1
            marker.item = item
            marker.unitTag = unitTag
            marker.unitSlot = slots[unitTag]
            UpdateHeadMarkerVisual(marker, item)
            seen[key] = true
        end
    end
    for key, marker in pairs(ui.headMarkers) do
        if not seen[key] then
            marker.item = nil
            marker:SetHidden(true)
        end
    end
end

local function UpdateHeadMarkerPositions(ui)
    local root, camera = ui.headMarkerRoot, ui.headMarkerCamera
    if not ui.headMarkerAvailable or not root or not camera or not Set3DRenderSpaceToCurrentCamera or not GuiRender3DPositionToWorldPosition then return end
    Set3DRenderSpaceToCurrentCamera(camera:GetName())
    local originX, originY, originZ = GuiRender3DPositionToWorldPosition(camera:Get3DRenderSpaceOrigin())
    local forwardX, forwardY, forwardZ = camera:Get3DRenderSpaceForward()
    local rightX, rightY, rightZ = camera:Get3DRenderSpaceRight()
    local upX, upY, upZ = camera:Get3DRenderSpaceUp()
    local uiWidth, uiHeight = GuiRoot:GetDimensions()
    if not originX or not forwardX or not rightX or not upX or not GetWorldDimensionsOfViewFrustumAtDepth then return end
    local playerZone = GetUnitRawWorldPosition and GetUnitRawWorldPosition("player") or nil

    for _, marker in pairs(ui.headMarkers or {}) do
        local unitTag = marker.unitTag
        local visible = marker.item and unitTag and DoesUnitExist and DoesUnitExist(unitTag) and GetUnitRawWorldPosition
        if visible then
            local zone, x, y, z = GetUnitRawWorldPosition(unitTag)
            visible = zone and zone ~= 0 and (not playerZone or zone == playerZone)
            if visible then
                local headOffset = (IsUnitPlayer and IsUnitPlayer(unitTag)) and 220 or 300
                y = y + headOffset
                local dx, dy, dz = x - originX, y - originY, z - originZ
                local depth = dx * forwardX + dy * forwardY + dz * forwardZ
                visible = depth > 50
                if visible then
                    local worldWidth, worldHeight = GetWorldDimensionsOfViewFrustumAtDepth(depth)
                    visible = worldWidth and worldHeight and worldWidth > 0 and worldHeight > 0
                    if visible then
                        local screenX = (dx * rightX + dy * rightY + dz * rightZ) * uiWidth / worldWidth
                        local screenY = (dx * upX + dy * upY + dz * upZ) * uiHeight / worldHeight
                        local slotOffset = ((marker.unitSlot or 1) - 1) * 34
                        marker:ClearAnchors()
                        marker:SetAnchor(CENTER, root, CENTER, screenX + slotOffset, -screenY)
                    end
                end
            end
        end
        marker:SetHidden(not visible)
    end
end

local function SafeUpdateHeadMarkerPositions(ui)
    if not ui or not ui.headMarkerAvailable then return end
    local ok = pcall(UpdateHeadMarkerPositions, ui)
    if ok then return end
    ui.headMarkerAvailable = false
    for _, marker in pairs(ui.headMarkers or {}) do marker:SetHidden(true) end
    if TSB.savedVars and TSB.savedVars.debug and TSB.Chat then
        TSB.Chat("projection des trackers tête indisponible; les autres trackers restent actifs.")
    end
end

local function DrawListWindow(ui, key, window, items)
    items = items or {}
    local rows = ui.rows[key] or {}
    local count = #items
    if count > MAX_ROWS then count = MAX_ROWS end

    local styleItem = items[1]
    local scale = CellScale(styleItem)
    ApplyWindowChrome(window, styleItem)
    window:SetScale(tonumber(StyleValue(styleItem, "scale")) or 1)

    local contentHeight = 0
    for i = 1, MAX_ROWS do
        local row = rows[i]
        if i <= count then
            row.item = items[i]
            local itemScale = CellScale(row.item)
            local itemTop = CompactOverlayAbove(row.item) and zo_round(24 * itemScale) or zo_round(6 * itemScale)
            LayoutRow(row, window, 1, contentHeight + itemTop)
            contentHeight = contentHeight + itemTop + RowHeight(row.item)
            UpdateRow(row)
            row:SetHidden(false)
        else
            row.item = nil
            row:SetHidden(true)
        end
    end

    local width = count > 0 and ItemWindowWidth(items[1]) or WindowWidth(styleItem)
    for i = 2, count do
        width = zo_max(width, ItemWindowWidth(items[i]))
    end
    local height = count > 0 and (contentHeight + zo_round(6 * scale)) or zo_round(46 * scale)
    if window.lastWidth ~= width or window.lastHeight ~= height then
        window:SetDimensions(width, height)
        window.lastWidth = width
        window.lastHeight = height
    end
    window:SetHidden(count == 0)
end

local function DestinationGroups(items)
    local groups = {
        panel1 = {}, panel2 = {}, panel3 = {}, panel4 = {},
        free1 = {}, free2 = {}, free3 = {}, free4 = {}, free5 = {},
        free6 = {}, free7 = {}, free8 = {}, free9 = {}, free10 = {},
        head = {}, group = {},
        remaining = {},
    }
    local supported = {
        panel1 = true, panel2 = true, panel3 = true, panel4 = true,
        free1 = true, free2 = true, free3 = true, free4 = true, free5 = true,
        free6 = true, free7 = true, free8 = true, free9 = true, free10 = true,
        head = true, group = true,
    }
    local hasDestination = false
    for _, item in ipairs(items or {}) do
        local dest = item.destination
        if dest and supported[dest] and groups[dest] then
            groups[dest][#groups[dest] + 1] = item
            hasDestination = true
        else
            groups.remaining[#groups.remaining + 1] = item
        end
    end
    for _, panelKey in ipairs({ "panel1", "panel2", "panel3", "panel4" }) do
        local style = Saved().panelSettings and Saved().panelSettings[panelKey]
        if style and type(style.order) == "string" and style.order ~= "" then
            local rank, rankIndex = {}, 0
            for key in style.order:gmatch("[^,%s]+") do
                if not rank[key] then
                    rankIndex = rankIndex + 1
                    rank[key] = rankIndex
                end
            end
            local original = {}
            for index, item in ipairs(groups[panelKey]) do original[item] = index end
            table.sort(groups[panelKey], function(a, b)
                local ar = rank[a.key]
                local br = rank[b.key]
                if ar and br then return ar < br end
                if ar then return true end
                if br then return false end
                return original[a] < original[b]
            end)
        end
    end
    groups.hasDestination = hasDestination
    return groups
end

local function WithoutDestinations(items)
    local supported = {
        panel1 = true, panel2 = true, panel3 = true, panel4 = true,
        free1 = true, free2 = true, free3 = true, free4 = true, free5 = true,
        free6 = true, free7 = true, free8 = true, free9 = true, free10 = true,
        head = true, group = true,
    }
    local result = {}
    for _, item in ipairs(items or {}) do
        if not item.destination or not supported[item.destination] then
            result[#result + 1] = item
        end
    end
    return result
end

local function HideDestinationWindows(ui)
    for key, win in pairs(ui.destinationWindows or {}) do
        win:SetHidden(true)
        HideRows(ui.rows[key])
    end
end

local function DrawDestinationWindows(ui, groups)
    for _, key in ipairs({ "panel1", "panel2", "panel3", "panel4", "free1", "free2", "free3", "free4", "free5", "free6", "free7", "free8", "free9", "free10" }) do
        local win = ui.destinationWindows and ui.destinationWindows[key]
        if win then
            DrawListWindow(ui, key, win, groups[key])
        end
    end
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
        ApplyFrameStyle(win, item)
        win:SetScale(tonumber(StyleValue(item, "scale")) or 1)
        win:SetMovable(Saved().unlocked == true)

        local scale = CellScale(item)
        -- [FIX] largeur reelle de la ligne (compact compris) : plus de fenetre trop
        -- large avec le timer perdu a droite du cadre
        local width = ItemWindowWidth(item)
        local topOffset = CompactOverlayAbove(item) and zo_round(24 * scale) or zo_round(8 * scale)
        local height = RowHeight(item) + topOffset + zo_round(8 * scale)
        if win.lastWidth ~= width or win.lastHeight ~= height then
            win:SetDimensions(width, height)
            win.lastWidth = width
            win.lastHeight = height
        end

        win.row.item = item
        LayoutRow(win.row, win, 1, topOffset)
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

local function PositionGroupTrackerWindow(win, item, index)
    local previewMode = TSB.previewDisplayActive and StyleValue(item, "unlocked") ~= true
    local positionMode = previewMode and "preview" or "saved"
    if win.isDragging or win.positionMode == positionMode then return end
    if previewMode then
        local x, y = PreviewPosition(0)
        AnchorWindow(win, x + 240, y + ((index - 1) * 190))
        win.positionMode = positionMode
        return
    end
    local positions = Saved().groupTrackerPositions or {}
    local saved = positions[item.key]
    if saved then
        AnchorWindow(win, saved.x, saved.y)
        win.positionMode = positionMode
        return
    end
    AnchorWindow(win, (tonumber(Saved().combinedX) or 920) + 240,
        (tonumber(Saved().combinedY) or 480) + ((index - 1) * 190))
    win.positionMode = positionMode
end

local function UpdateGroupTrackerWindow(win)
    local item = win.item
    if not item then return end
    local blockScale = CellScale(item)
    local iconSize = 42
    local columnWidth = 136
    local memberHeight = 20
    local inset = 8
    local specialLayout = item.specialGroupLayout == true
    local width = (columnWidth * 2) + (inset * 3)
    local memberRows = specialLayout and 3 or 6
    local height = inset + iconSize + 8 + (memberHeight * memberRows) + inset
    win:SetDimensions(width, height)
    win:SetScale((tonumber(StyleValue(item, "scale")) or 1) * blockScale)
    win:SetMovable(StyleValue(item, "unlocked") == true)
    ApplyFrameStyle(win, item)

    win.icon:ClearAnchors()
    win.icon:SetAnchor(TOP, win, TOP, 0, inset)
    win.icon:SetDimensions(iconSize, iconSize)
    win.icon:SetTexture(item.icon or "")
    win.icon:SetColor(1, 1, 1, SavedAlpha("badgeAlpha", 0.95, item))
    win.iconFrame:ClearAnchors()
    local framePad = zo_round(iconSize * 0.14)
    win.iconFrame:SetAnchor(TOPLEFT, win.icon, TOPLEFT, -framePad, -framePad)
    win.iconFrame:SetAnchor(BOTTOMRIGHT, win.icon, BOTTOMRIGHT, framePad, framePad)
    win.status:ClearAnchors()
    win.status:SetAnchorFill(win.icon)
    if specialLayout then
        local active = item.spaulderActive == true
        win.status:SetText(active and "ON" or "OFF")
        if active then
            win.status:SetColor(0.25, 1, 0.35, 1)
        else
            win.status:SetColor(1, 0.18, 0.12, 1)
        end
        win.status:SetHidden(false)
    else
        win.status:SetHidden(true)
    end

    local now = GetGameTimeSeconds and GetGameTimeSeconds() or 0
    local showNames = StyleValue(item, "showNames") ~= false
    local showTimers = StyleValue(item, "showTimers") ~= false
    for i = 1, 12 do
        local cell = win.members[i]
        local member = item.groupMembers and item.groupMembers[i]
        if member then
            local column, line, x
            if specialLayout then
                if i == 1 then
                    column, line = 0, 0
                    x = zo_round((width - columnWidth) / 2)
                else
                    local gridIndex = i - 2
                    column = gridIndex % 2
                    line = 1 + math.floor(gridIndex / 2)
                    x = inset + (column * (columnWidth + inset))
                end
            else
                column = math.floor((i - 1) / 6)
                line = (i - 1) % 6
                x = inset + (column * (columnWidth + inset))
            end
            local y = inset + iconSize + 8 + (line * memberHeight)
            cell:ClearAnchors()
            cell:SetAnchor(TOPLEFT, win, TOPLEFT, x, y)
            cell:SetDimensions(columnWidth, memberHeight)
            cell.name:ClearAnchors()
            cell.name:SetAnchor(LEFT, cell, LEFT, 0, 0)
            cell.name:SetDimensions(96, memberHeight)
            cell.name:SetScale(1)
            cell.timer:ClearAnchors()
            cell.timer:SetAnchor(RIGHT, cell, RIGHT, 0, 0)
            cell.timer:SetDimensions(36, memberHeight)
            cell.timer:SetScale(TimerTextScale(item))

            local remaining = member.endTime and (member.endTime - now) or tonumber(member.remaining) or 0
            local active = member.active == true and remaining > 0
            if item.preview then active = member.active == true end
            local roleColor = GROUP_ROLE_COLORS[member.role]
            if active then
                if roleColor then
                    cell.name:SetColor(roleColor[1], roleColor[2], roleColor[3], SavedAlpha("textAlpha", 1, item))
                else
                    ApplySavedTextColor(cell.name, "nameTextColor", SavedAlpha("textAlpha", 1, item), item)
                end
                ApplySavedTextColor(cell.timer, "timerTextColor", SavedAlpha("textAlpha", 1, item), item)
            else
                if roleColor then
                    cell.name:SetColor(roleColor[1] * 0.38, roleColor[2] * 0.38, roleColor[3] * 0.38, 0.9)
                else
                    cell.name:SetColor(0.38, 0.38, 0.38, 0.9)
                end
                cell.timer:SetColor(0.38, 0.38, 0.38, 0.9)
            end
            cell.name:SetText(member.name or member.unitTag or "-")
            cell.name:SetHidden(not showNames)
            cell.timer:SetText(active and string.format("%.1f", zo_max(remaining, 0)) or "-")
            cell.timer:SetHidden(not showTimers)
            cell:SetHidden(false)
        else
            cell:SetHidden(true)
        end
    end
end

local function DrawGroupTrackerWindows(ui, items)
    ui.groupTrackerWindows = ui.groupTrackerWindows or {}
    local seen = {}
    for index, item in ipairs(items or {}) do
        local key = item.key or ("group" .. tostring(index))
        local win = ui.groupTrackerWindows[key]
        if not win then
            win = MakeGroupTrackerWindow(key)
            ui.groupTrackerWindows[key] = win
        end
        seen[key] = true
        win.trackerKey = key
        win.item = item
        PositionGroupTrackerWindow(win, item, index)
        UpdateGroupTrackerWindow(win)
        win:SetHidden(false)
    end
    for key, win in pairs(ui.groupTrackerWindows) do
        if not seen[key] then
            win.item = nil
            win:SetHidden(true)
        end
    end
end

local function HideGroupTrackerWindows(ui)
    for _, win in pairs(ui.groupTrackerWindows or {}) do
        win.item = nil
        win:SetHidden(true)
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
    self.destinationWindows = {
        panel1 = MakeWindow("TeamShadowsBuffsPanel1", "PANEL 1", "panel1X", "panel1Y"),
        panel2 = MakeWindow("TeamShadowsBuffsPanel2", "PANEL 2", "panel2X", "panel2Y"),
        panel3 = MakeWindow("TeamShadowsBuffsPanel3", "PANEL 3", "panel3X", "panel3Y"),
        panel4 = MakeWindow("TeamShadowsBuffsPanel4", "PANEL 4", "panel4X", "panel4Y"),
        free1 = MakeWindow("TeamShadowsBuffsFree1", "LIBRE 1", "free1X", "free1Y"),
        free2 = MakeWindow("TeamShadowsBuffsFree2", "LIBRE 2", "free2X", "free2Y"),
        free3 = MakeWindow("TeamShadowsBuffsFree3", "LIBRE 3", "free3X", "free3Y"),
        free4 = MakeWindow("TeamShadowsBuffsFree4", "LIBRE 4", "free4X", "free4Y"),
        free5 = MakeWindow("TeamShadowsBuffsFree5", "LIBRE 5", "free5X", "free5Y"),
        free6 = MakeWindow("TeamShadowsBuffsFree6", "LIBRE 6", "free6X", "free6Y"),
        free7 = MakeWindow("TeamShadowsBuffsFree7", "LIBRE 7", "free7X", "free7Y"),
        free8 = MakeWindow("TeamShadowsBuffsFree8", "LIBRE 8", "free8X", "free8Y"),
        free9 = MakeWindow("TeamShadowsBuffsFree9", "LIBRE 9", "free9X", "free9Y"),
        free10 = MakeWindow("TeamShadowsBuffsFree10", "LIBRE 10", "free10X", "free10Y"),
    }
    self.headMarkerRoot = WM:CreateTopLevelWindow("TeamShadowsBuffsHeadMarkerRoot")
    self.headMarkerRoot:SetAnchorFill(GuiRoot)
    self.headMarkerRoot:SetMouseEnabled(false)
    self.headMarkerRoot:SetHidden(false)
    self.headMarkerCamera = WM:CreateControl("TeamShadowsBuffsHeadMarkerCamera", self.headMarkerRoot, CT_CONTROL)
    self.headMarkerAvailable = false
    if self.headMarkerCamera.Create3DRenderSpace then
        self.headMarkerAvailable = pcall(function() self.headMarkerCamera:Create3DRenderSpace() end)
    end
    self.headMarkerCamera:SetHidden(false)
    self.headMarkers = {}
    self.rows = {}
    self.trackerWindows = {}
    self.groupTrackerWindows = {}

    EnsureRows(self, "combined", self.combined)
    EnsureRows(self, "buffs", self.buffs)
    EnsureRows(self, "debuffs", self.debuffs)
    for key, win in pairs(self.destinationWindows) do
        EnsureRows(self, key, win)
    end

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
    for key, win in pairs(self.destinationWindows or {}) do
        AnchorWindow(win, TSB.savedVars[key .. "X"], TSB.savedVars[key .. "Y"])
    end

    local scale = tonumber(TSB.savedVars.scale) or 1
    self.combined:SetScale(scale)
    self.buffs:SetScale(scale)
    self.debuffs:SetScale(scale)
    for _, win in pairs(self.destinationWindows or {}) do
        win:SetScale(scale)
    end

    local unlocked = TSB.savedVars.unlocked == true
    self.combined:SetMovable(unlocked)
    self.buffs:SetMovable(unlocked)
    self.debuffs:SetMovable(unlocked)
    for _, win in pairs(self.destinationWindows or {}) do
        win:SetMovable(unlocked)
    end
    for key, win in pairs(self.destinationWindows or {}) do
        local item = { destination = key }
        win:SetMovable(StyleValue(item, "unlocked") == true)
    end

    self:Refresh()
end

function UI:Refresh()
    if not self.initialized or not TSB.savedVars then return end
    if TSB.savedVars.enabled ~= true then
        self:Shutdown()
        return
    end

    local data = GetDisplayData()
    local groups = DestinationGroups(data.combined)
    DrawHeadMarkers(self, groups.head)
    DrawGroupTrackerWindows(self, groups.group)
    SafeUpdateHeadMarkerPositions(self)
    if groups.hasDestination then
        DrawDestinationWindows(self, groups)
    else
        HideDestinationWindows(self)
    end

    data = {
        player = WithoutDestinations(data.player),
        boss = WithoutDestinations(data.boss),
        combined = groups.remaining,
    }
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
    SafeUpdateHeadMarkerPositions(self)
    for _, marker in pairs(self.headMarkers or {}) do
        if marker.item then
            if (Remaining(marker.item) or 0) <= 0 then
                expired = true
            else
                UpdateHeadMarkerVisual(marker, marker.item)
            end
        end
    end
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
    for _, win in pairs(self.groupTrackerWindows or {}) do
        if win.item and not win:IsHidden() then UpdateGroupTrackerWindow(win) end
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
    HideDestinationWindows(self)
    HideIndividualWindows(self)
    HideGroupTrackerWindows(self)
    for _, marker in pairs(self.headMarkers or {}) do
        marker.item = nil
        marker:SetHidden(true)
    end
end
