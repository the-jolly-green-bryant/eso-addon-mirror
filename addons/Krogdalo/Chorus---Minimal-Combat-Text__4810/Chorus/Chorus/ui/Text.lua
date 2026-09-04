local T = Chorus.Text
local W = Chorus.Widgets
local S = Chorus.Strings
local F = Chorus.Format

T.DEFAULT_X = 140
T.DEFAULT_Y = -20
T.COLUMN_W = 260
T.DRIFT = 8
T.SUMMARY_GAP = 30

local function makeLine(parent, align)
    local line = {}
    line.number = W.Label(parent, W.Font(20), { 1, 1, 1 }, align)
    line.number:SetHeight(40)
    line.mark = W.Rect(parent, { 1, 1, 1 }, 1)
    line.mark:SetDimensions(3, 3)
    line.mark:SetHidden(true)
    line.name = W.Label(parent, W.SMALL_FONT, { 1, 1, 1 }, align)
    line.name:SetHeight(16)
    line.name:SetWidth(T.COLUMN_W)
    line.name:SetHidden(true)
    line.count = W.Label(parent, W.SMALL_FONT, { 1, 1, 1 }, align)
    line.count:SetHeight(16)
    line.count:SetWidth(32)
    line.count:SetHidden(true)
    line.number:SetHidden(true)
    return line
end

local function makeColumn(parent, side, lines)
    local col = { side = side, lines = {} }
    col.root = WINDOW_MANAGER:CreateControl(W.NextName("Col"), parent, CT_CONTROL)
    col.root:SetDimensions(T.COLUMN_W, 400)
    for i = 1, lines do col.lines[i] = makeLine(col.root, side == "right" and TEXT_ALIGN_LEFT or TEXT_ALIGN_RIGHT) end
    return col
end

function T.Init(sv)
    T.sv = sv
    T.unlocked = false
    local win = WINDOW_MANAGER:CreateTopLevelWindow("ChorusText")
    T.window = win
    win:SetDimensions(2 * (T.DEFAULT_X + T.COLUMN_W), 400)
    win:SetMouseEnabled(false)
    win:SetMovable(false)
    win:SetClampedToScreen(true)
    win:SetDrawLayer(DL_CONTROLS)
    win:SetDrawTier(DT_HIGH)
    win:SetHidden(true)

    T.grab = W.Rect(win, { 1, 1, 1 }, 0.06)
    T.grab:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)
    T.grab:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, 0, 0)
    T.grab:SetHidden(true)

    T.damage = makeColumn(win, "right", 12)
    T.damage.root:SetAnchor(BOTTOMLEFT, win, BOTTOM, T.DEFAULT_X, 0)
    T.heal = makeColumn(win, "left", 12)
    T.heal.root:SetAnchor(BOTTOMRIGHT, win, BOTTOM, -T.DEFAULT_X, 0)

    T.summary = W.Label(win, W.SUMMARY_FONT, sv.colors.dim, TEXT_ALIGN_LEFT)
    T.summary:SetHeight(18)
    T.summary:SetWidth(T.COLUMN_W + 80)
    T.summary:SetAnchor(TOPLEFT, T.damage.root, BOTTOMLEFT, 0, T.SUMMARY_GAP)
    T.summary:SetHidden(true)

    win:SetHandler("OnMoveStop", function() sv.position.x, sv.position.y = win:GetLeft(), win:GetTop() end)
    T.ApplyFont()
    T.ApplyPosition()
    return win
end

function T.ApplyFont()
    W.SetFace(T.sv.font)
    for _, col in ipairs({ T.damage, T.heal }) do
        for _, line in ipairs(col.lines) do line.name:SetFont(W.SMALL_FONT); line.count:SetFont(W.SMALL_FONT) end
    end
    T.summary:SetFont(W.SUMMARY_FONT)
end

function T.ApplyPosition()
    local win, sv = T.window, T.sv
    win:ClearAnchors()
    if sv.position.x then win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.position.x, sv.position.y)
    else win:SetAnchor(BOTTOM, GuiRoot, CENTER, 0, T.DEFAULT_Y) end
end

function T.ResetPosition() T.sv.position.x, T.sv.position.y = nil, nil; T.ApplyPosition() end

local function sizeFor(sv, weight) return sv.sizeMin + (sv.sizeMax - sv.sizeMin) * weight end

local function paintLine(col, line, e, y)
    local sv = T.sv
    local size = sizeFor(sv, e.weight)
    local alpha = e.alpha * (0.6 + 0.4 * e.weight)
    local rgb = e.kind == "heal" and sv.colors.heal or (e.crit and sv.colors.crit or sv.colors.text)
    local right = col.side == "right"
    local anchor, rel = right and BOTTOMLEFT or BOTTOMRIGHT, right and BOTTOMLEFT or BOTTOMRIGHT

    line.number:SetFont(W.Font(size))
    line.number:SetText(e.text)
    W.SetLabelColor(line.number, rgb, alpha)
    line.number:SetHeight(size + 6)
    line.number:SetWidth(T.COLUMN_W - 60)
    line.number:ClearAnchors()
    line.number:SetAnchor(anchor, col.root, rel, 0, -y)
    line.number:SetHidden(false)

    local showMark = sv.critMark and e.crit and e.kind ~= "heal"
    line.mark:SetHidden(not showMark)
    if showMark then
        line.mark:SetCenterColor(rgb[1], rgb[2], rgb[3], alpha)
        line.mark:ClearAnchors()
        if right then line.mark:SetAnchor(RIGHT, line.number, LEFT, -6, 0) else line.mark:SetAnchor(LEFT, line.number, RIGHT, 6, 0) end
    end

    local textW = line.number.GetTextWidth and line.number:GetTextWidth() or 0
    local extra = {}
    if e.count and e.count >= 2 then extra[#extra + 1] = "×" .. e.count end
    if e.showName and e.name then extra[#extra + 1] = e.name end
    if #extra > 0 then
        line.name:SetText(table.concat(extra, "  "))
        W.SetLabelColor(line.name, sv.colors.dim, alpha)
        line.name:ClearAnchors()
        if right then line.name:SetAnchor(BOTTOMLEFT, line.number, BOTTOMLEFT, textW + 8, -3)
        else line.name:SetAnchor(BOTTOMRIGHT, line.number, BOTTOMRIGHT, -(textW + 8), -3) end
        line.name:SetHidden(false)
    else
        line.name:SetHidden(true)
    end
    line.count:SetHidden(true)
    return size + 6
end

local function hideLine(line)
    line.number:SetHidden(true); line.mark:SetHidden(true); line.name:SetHidden(true); line.count:SetHidden(true)
end

local function renderColumn(col, entries)
    local y = 0
    local used = 0
    for _, e in ipairs(entries) do
        used = used + 1
        local line = col.lines[used]
        if not line then break end
        local drift = math.min(1, e.age / math.max(1, e.dwell)) * T.DRIFT
        local h = paintLine(col, line, e, y + drift)
        y = y + h + 2
    end
    for i = used + 1, #col.lines do hideLine(col.lines[i]) end
end

function T.Render(view)
    local damage, heal = {}, {}
    for _, e in ipairs(view.entries) do
        if e.kind == "heal" then heal[#heal + 1] = e else damage[#damage + 1] = e end
    end
    renderColumn(T.damage, damage)
    renderColumn(T.heal, heal)

    local s = view.summary
    if s and T.sv.summary then
        local fadeStart = 3200
        local alpha = s.age > fadeStart and math.max(0, 1 - (s.age - fadeStart) / 800) or 1
        T.summary:SetText(S.Get("SUMMARY", F.Seconds(s.duration), F.Amount(s.dps), s.top.name or "", math.floor(s.top.share * 100 + 0.5)))
        W.SetLabelColor(T.summary, T.sv.colors.dim, alpha)
        T.summary:SetHidden(false)
    else
        T.summary:SetHidden(true)
    end
end

function T.Show() T.window:SetHidden(false) end
function T.Hide() if not T.unlocked then T.window:SetHidden(true) end end

function T.PreviewView()
    return {
        entries = {
            { text = "31.2k", name = "Crystal Fragments", kind = "damage", weight = 1.0, crit = true, count = 1, alpha = 1, age = 0, dwell = 1500, showName = true, index = 1 },
            { text = "4120", name = "Fiery Grip", kind = "damage", weight = 0.55, crit = false, count = 1, alpha = 1, age = 300, dwell = 1200, showName = false, index = 2 },
            { text = "9600", name = "Whirling Blades", kind = "damage", weight = 0.7, crit = false, count = 3, alpha = 1, age = 500, dwell = 1300, showName = false, index = 3 },
            { text = "412", name = "Burning Embers", kind = "damage", weight = 0.1, crit = false, count = 1, alpha = 1, age = 700, dwell = 950, showName = false, index = 4 },
        },
        summary = { duration = 42300, dps = 18340, total = 776000, top = { name = "Rapid Strikes", share = 0.31 }, age = 0 },
    }
end

function T.SetUnlocked(unlocked)
    T.unlocked = unlocked
    T.window:SetMovable(unlocked)
    T.window:SetMouseEnabled(unlocked)
    T.grab:SetHidden(not unlocked)
    if unlocked then T.Render(T.PreviewView()); T.window:SetHidden(false)
    elseif not Chorus.Events.ticking then T.window:SetHidden(true) end
end
