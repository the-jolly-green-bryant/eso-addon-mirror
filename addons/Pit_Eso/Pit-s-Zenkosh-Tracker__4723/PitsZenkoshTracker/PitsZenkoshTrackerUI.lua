-------------------------------------------------------------------------------
-- Pit's Zenkosh Tracker - Timer-Fenster
--
-- Je Gegner eine Gruppe: Name, darunter eine Alkosh-Leiste und (optional) eine
-- Touch-of-Z'en-Leiste mit Stack-Zahl. Beide Leisten eines Gegners bleiben
-- zusammen und die Zeilen springen innerhalb eines Kampfes nicht (stabile
-- Reihenfolge nach Erst-Sichtung, Bosse zuerst).
--
-- Das Symbol sitzt LINKS neben der Leiste, nicht dahinter - so verschwindet
-- der Alkosh-Kopf nicht mehr hinter der Farbe.
--
-- Laeuft der Alkosh eines wichtigen Ziels (Boss oder toedliche Schwierigkeit,
-- z.B. Trainingspuppe/Weltboss) ab, erscheint fuer 5 Sekunden eine rote Warnung
-- an der Stelle der Alkosh-Leiste, damit man sofort nachlegen kann. Danach (oder
-- wenn nichts laeuft) blendet sich das Fenster aus wie andere Timer auch.
--
-- Verschieben: entsperren, ziehen. Groesse: Ecke ziehen (natives Resize-Handle).
-------------------------------------------------------------------------------

local A  = PitsZenkoshTracker
local wm = WINDOW_MANAGER
local em = EVENT_MANAGER

A.UI = A.UI or {}
local UI = A.UI

-- Grundmasse bei Skalierung 1.0
local BASE_WIDTH  = 240
local BASE_HEADER = 22
local NAME_H      = 15
local BAR_H       = 20
local BASE_FONT   = 15

local MIN_SCALE, MAX_SCALE = 0.5, 3.0
local REFRESH_INTERVAL = 100

local window, backdrop, title, grip
local rows = {}

local PREVIEW = {
    { name = "Beispielboss", isBoss = true,
      alkosh = { remaining = 4.8, fraction = 0.80 },
      zen    = { remaining = 14.0, fraction = 0.70, stacks = 5 } },
    { name = "Beispiel-Add", isBoss = false,
      alkosh = { remaining = 2.3, fraction = 0.38 },
      zen    = { remaining = 9.0, fraction = 0.45, stacks = 3 } },
}

local function Scale()
    return math.min(MAX_SCALE, math.max(MIN_SCALE, A.sv.ui.scale or 1))
end

local function Font(size)
    return string.format("$(BOLD_FONT)|%d|soft-shadow-thick", math.max(8, math.floor(size)))
end

local function LineCount()
    return A.sv.ui.showZen and 2 or 1
end

local function RowHeight(s)
    return (NAME_H + LineCount() * BAR_H) * s
end

-------------------------------------------------------------------------------
-- Aufbau
-------------------------------------------------------------------------------

local function CreateBarLine(parent, id, gradient)
    local line = {}

    line.icon = wm:CreateControl(id .. "Icon", parent, CT_TEXTURE)

    line.bar = wm:CreateControl(id .. "Bar", parent, CT_STATUSBAR)
    line.bar:SetMinMax(0, 1)
    line.bar:SetGradientColors(unpack(gradient))

    line.stacks = wm:CreateControl(id .. "Stacks", parent, CT_LABEL)
    line.stacks:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    line.stacks:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    line.stacks:SetColor(1, 1, 1, 1)

    line.time = wm:CreateControl(id .. "Time", parent, CT_LABEL)
    line.time:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    line.time:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    line.time:SetColor(1, 1, 1, 1)

    return line
end

local ALKOSH_GRADIENT = { 0.55, 0.20, 0.10, 0.80, 0.90, 0.45, 0.15, 0.80 }
local ZEN_GRADIENT    = { 0.20, 0.15, 0.45, 0.80, 0.45, 0.30, 0.80, 0.80 }

local function CreateRow(index)
    local row = wm:CreateControl("PitsZenkoshTrackerRow" .. index, window, CT_CONTROL)

    row.name = wm:CreateControl("PitsZenkoshTrackerRow" .. index .. "Name", row, CT_LABEL)
    row.name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    row.alkosh = CreateBarLine(row, "PitsZenkoshTrackerRow" .. index .. "A", ALKOSH_GRADIENT)
    row.alkosh.icon:SetTexture(GetAbilityIcon(A.ALKOSH_LINEBREAKER))

    row.zen = CreateBarLine(row, "PitsZenkoshTrackerRow" .. index .. "Z", ZEN_GRADIENT)
    row.zen.icon:SetTexture(GetAbilityIcon(A.ZEN_TOUCH))

    -- Rote Ablauf-Warnung, liegt ueber der Alkosh-Leiste
    row.warn = wm:CreateControl("PitsZenkoshTrackerRow" .. index .. "Warn", row, CT_LABEL)
    row.warn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.warn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    row.warn:SetText("ALKOSH AUS - NACHLEGEN!")
    row.warn:SetHidden(true)

    row:SetHidden(true)
    return row
end

local function LayoutBarLine(line, row, s, topY, width)
    local pad  = 3 * s
    local iconSz = BAR_H * s - 2 * s
    local barH = BAR_H * s - 2 * s

    line.icon:ClearAnchors()
    line.icon:SetAnchor(TOPLEFT, row, TOPLEFT, pad, topY + s)
    line.icon:SetDimensions(iconSz, iconSz)

    local barX = pad + iconSz + pad
    line.bar:ClearAnchors()
    line.bar:SetAnchor(TOPLEFT, row, TOPLEFT, barX, topY + s)
    line.bar:SetDimensions(width - barX - pad, barH)

    line.stacks:ClearAnchors()
    line.stacks:SetAnchor(LEFT, line.bar, LEFT, 4 * s, 0)
    line.stacks:SetDimensions(40 * s, barH)
    line.stacks:SetFont(Font(BASE_FONT * s))

    line.time:ClearAnchors()
    line.time:SetAnchor(RIGHT, line.bar, RIGHT, -4 * s, 0)
    line.time:SetDimensions(60 * s, barH)
    line.time:SetFont(Font(BASE_FONT * s))
end

function UI.ApplyLayout()
    if not window then return end

    local s       = Scale()
    local width   = BASE_WIDTH * s
    local rowH    = RowHeight(s)
    local headerH = A.sv.ui.locked and 0 or BASE_HEADER * s
    local count   = A.sv.ui.maxRows

    window:SetDimensions(width, headerH + rowH * count)

    title:SetHidden(A.sv.ui.locked)
    title:SetFont(Font(BASE_FONT * s * 0.8))
    title:SetDimensions(width, headerH)

    for i = 1, count do
        rows[i] = rows[i] or CreateRow(i)
        local row = rows[i]

        row:ClearAnchors()
        row:SetAnchor(TOPLEFT, window, TOPLEFT, 0, headerH + (i - 1) * rowH)
        row:SetDimensions(width, rowH)

        row.name:ClearAnchors()
        row.name:SetAnchor(TOPLEFT, row, TOPLEFT, 4 * s, 0)
        row.name:SetDimensions(width - 8 * s, NAME_H * s)
        row.name:SetFont(Font(BASE_FONT * s * 0.9))

        LayoutBarLine(row.alkosh, row, s, NAME_H * s, width)
        LayoutBarLine(row.zen,    row, s, (NAME_H + BAR_H) * s, width)
        row.zen.icon:SetHidden(not A.sv.ui.showZen)

        row.warn:ClearAnchors()
        row.warn:SetAnchor(TOPLEFT, row, TOPLEFT, 0, NAME_H * s)
        row.warn:SetDimensions(width, BAR_H * s)
        row.warn:SetFont(Font(BASE_FONT * s * 0.95))
    end

    for i = count + 1, #rows do
        rows[i]:SetHidden(true)
    end

    grip:SetDimensions(14 * s, 14 * s)
    grip:SetHidden(A.sv.ui.locked)
end

function UI.ApplyLock()
    if not window then return end
    local locked = A.sv.ui.locked

    window:SetMovable(not locked)
    window:SetMouseEnabled(not locked)
    window:SetResizeHandleSize(locked and 0 or 8)

    -- Gesperrt (Normalfall im Kampf): voellig transparent, damit der leere Teil
    -- des Fensters nichts abdunkelt. Entsperrt: Rahmen sichtbar zum Verschieben.
    backdrop:SetCenterColor(0, 0, 0, locked and 0 or 0.55)
    backdrop:SetEdgeColor(1, 0.75, 0.3, locked and 0 or 0.8)

    UI.ApplyLayout()
end

function UI.SetScale(newScale)
    A.sv.ui.scale = math.min(MAX_SCALE, math.max(MIN_SCALE, newScale))
    UI.ApplyLayout()
end

function UI.Diagnose()
    if not window then
        return "Fenster wurde nie erzeugt (PitsZenkoshTrackerUI.lua nicht geladen?)"
    end
    return string.format("sichtbar: %s | %dx%d Pixel | Position %d,%d | Zeilen: %d",
        window:IsHidden() and "NEIN" or "ja",
        window:GetWidth(), window:GetHeight(),
        window:GetLeft(), window:GetTop(), #rows)
end

function UI.ResetPosition()
    A.sv.ui.x, A.sv.ui.y = nil, nil
    window:ClearAnchors()
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
end

-------------------------------------------------------------------------------
-- Anzeige-Daten: aktive Ziele plus kuerzlich abgelaufene Boss-Alkosh (Warnung)
-------------------------------------------------------------------------------

function UI.BuildDisplay(nowMs)
    nowMs = nowMs or GetGameTimeMilliseconds()
    local list = A.GetTimerTargets(nowMs, A.sv.ui.bossOnly, A.sv.ui.maxRows)

    if not A.sv.ui.expiryWarning then return list end

    local byKey = {}
    for _, e in ipairs(list) do byKey[e.key] = e end

    -- Frisch abgelaufene wichtige Ziele: dringliche, pulsende Warnung (5s).
    for _, x in ipairs(A.GetRecentExpiries(nowMs)) do
        local e = byKey[x.key]
        if e then
            if not e.alkosh then e.warnSince = x.sinceMs end   -- Ziel noch da (z.B. Z'en laeuft)
        elseif #list < A.sv.ui.maxRows then
            e = { key = x.key, name = x.name, isBoss = true, warnSince = x.sinceMs }
            byKey[x.key] = e
            table.insert(list, e)
        end
    end

    -- Boss ohne aktives Alkosh: leere Leiste bleibt sichtbar (ruhig), auch nach
    -- Ablauf der 5s-Warnung - der Boss haelt seine Zeile bis Kampfende.
    for _, e in ipairs(list) do
        if e.isBoss and not e.alkosh and not e.warnSince then
            e.warnEmpty = true
        end
    end

    return list
end

-------------------------------------------------------------------------------
-- Zeichnen
-------------------------------------------------------------------------------

local function ShowBarLine(line, data, maxSeconds)
    if data then
        line.bar:SetHidden(false)
        line.bar:SetValue(data.fraction or 0)
        line.time:SetHidden(false)
        line.time:SetText(string.format("%.1f", data.remaining or 0))
        line.icon:SetAlpha(1)
        if data.stacks ~= nil then
            line.stacks:SetHidden(false)
            line.stacks:SetText("x" .. data.stacks)
        else
            line.stacks:SetHidden(true)
        end
    else
        line.bar:SetHidden(true)
        line.time:SetHidden(true)
        line.stacks:SetHidden(true)
        line.icon:SetAlpha(0.25)   -- Symbol bleibt als Platzhalter schwach sichtbar
    end
end

local function Refresh()
    if not window then return end

    local nowMs   = GetGameTimeMilliseconds()
    local display = UI.BuildDisplay(nowMs)

    if #display == 0 and not A.sv.ui.locked then
        display = PREVIEW
    end

    -- Ausblenden wie andere Timer: gesperrt und nichts anzuzeigen -> weg.
    local visible = A.sv.ui.show and (#display > 0 or not A.sv.ui.locked)
    window:SetHidden(not visible)
    if not visible then return end

    -- rotes Pulsieren fuer die Warnung
    local pulse = 0.55 + 0.45 * math.abs(math.sin(nowMs / 200))

    for i = 1, A.sv.ui.maxRows do
        local row   = rows[i]
        local entry = display[i]
        if not row then break end

        if entry then
            row.name:SetText(entry.name or "")
            if entry.isBoss then
                row.name:SetColor(1, 0.85, 0.45, 1)
            else
                row.name:SetColor(0.85, 0.85, 0.85, 1)
            end

            -- Alkosh-Zeile, dringliche Warnung, oder ruhige leere Boss-Leiste
            if not entry.alkosh and (entry.warnSince or entry.warnEmpty) then
                row.alkosh.bar:SetHidden(true)
                row.alkosh.time:SetHidden(true)
                row.alkosh.stacks:SetHidden(true)
                row.warn:SetHidden(false)
                if entry.warnSince then
                    row.alkosh.icon:SetAlpha(pulse)             -- dringlich: pulsend
                    row.warn:SetColor(1, 0.15, 0.15, pulse)
                else
                    row.alkosh.icon:SetAlpha(0.6)               -- ruhig: Boss haelt die Zeile
                    row.warn:SetColor(1, 0.35, 0.35, 0.6)
                end
            else
                row.warn:SetHidden(true)
                ShowBarLine(row.alkosh, entry.alkosh)
            end

            -- Z'en-Zeile
            if A.sv.ui.showZen then
                ShowBarLine(row.zen, entry.zen)
            else
                row.zen.bar:SetHidden(true)
                row.zen.time:SetHidden(true)
                row.zen.stacks:SetHidden(true)
                row.zen.icon:SetHidden(true)
            end

            row:SetHidden(false)
        else
            row:SetHidden(true)
        end
    end
end
UI.Refresh = Refresh

-- Sichtbarkeit wird komplett in Refresh() entschieden (show + ob etwas laeuft).
-- Diese Funktion stoesst das nach einer Options-Aenderung sofort an.
function UI.ApplyVisibility()
    Refresh()
end

-------------------------------------------------------------------------------
-- Initialisierung
-------------------------------------------------------------------------------

function A.InitUI()
    window = wm:CreateTopLevelWindow("PitsZenkoshTrackerWindow")
    window:SetClampedToScreen(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_MEDIUM)
    window:SetDimensionConstraints(BASE_WIDTH * MIN_SCALE, BAR_H,
                                   BASE_WIDTH * MAX_SCALE, RowHeight(MAX_SCALE) * 12)

    if A.sv.ui.x and A.sv.ui.y then
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, A.sv.ui.x, A.sv.ui.y)
    else
        window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end

    backdrop = wm:CreateControl("PitsZenkoshTrackerBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    backdrop:SetEdgeTexture("", 1, 1, 1)

    title = wm:CreateControl("PitsZenkoshTrackerTitle", window, CT_LABEL)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    title:SetColor(1, 0.8, 0.4, 1)
    title:SetText("Pit's Zenkosh Tracker  -  ziehen, Ecke = Groesse")

    grip = wm:CreateControl("PitsZenkoshTrackerGrip", window, CT_BACKDROP)
    grip:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -1, -1)
    grip:SetEdgeTexture("", 1, 1, 1)
    grip:SetCenterColor(1, 0.8, 0.4, 0.55)
    grip:SetEdgeColor(1, 0.8, 0.4, 0.9)

    window:SetHandler("OnMoveStop", function()
        A.sv.ui.x, A.sv.ui.y = window:GetLeft(), window:GetTop()
    end)
    window:SetHandler("OnResizeStop", function()
        UI.SetScale(window:GetWidth() / BASE_WIDTH)
        A.sv.ui.x, A.sv.ui.y = window:GetLeft(), window:GetTop()
    end)

    UI.ApplyLock()

    em:RegisterForUpdate(A.name .. "_ui", REFRESH_INTERVAL, Refresh)
end
