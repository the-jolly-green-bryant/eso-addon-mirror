BGMeter = BGMeter or {}
local BGMeter = BGMeter

local U = BGMeter.UI._win
local W = U.W
local SEC = U.SEC
local set_text, set_bar, make_clickable = U.set_text, U.set_bar, U.make_clickable
local ICON_STAR, ICON_SORTUP, ICON_SORTDN = U.ICON_STAR, U.ICON_SORTUP, U.ICON_SORTDN

local C = BGMeter.zenimax.constants
local K = BGMeter.Constants
local L = BGMeter.Constants.LAYOUT
local F = BGMeter.Format
local P = BGMeter.Plot.primitives
local S = BGMeter.Plot.style
local Bar = BGMeter.Plot.bar
local Icons = BGMeter.Icons
local Awards = BGMeter.Awards
local Prefs = BGMeter.Prefs

local COLS = {
    { key = "damage",  right = 230, w = 56, label = "DMG", shift = true },
    { key = "healing", right = 170, w = 50, label = "HEAL", shift = true },
    { key = "kills",   right = 122, w = 22, label = "K", shift = true },
    { key = "deaths",  right = 94,  w = 22, label = "D", shift = true },
    { key = "assists", right = 66,  w = 22, label = "A", shift = true },
    { key = "caps",    right = 66,  w = 34, label = "CAP", flag = true },
    { key = "score",   right = 10,  w = 50, label = "PTS"  },
}
local CAPS_SHIFT = 40
local caps_shown = false

local function col_right(col)
    if not col.flag and caps_shown and col.shift then return col.right + CAPS_SHIFT end
    return col.right
end

local function col_hidden(col)
    return (col.flag and not caps_shown) and true or false
end
local INDEX_X, ICON_X, NAME_X = 6, 24, 50
local NAME_RIGHT = 296
local BAR_X, BAR_RIGHT = 50, 6

local function one_line(lbl)
    lbl:SetHeight(14)
    if TEXT_WRAP_MODE_ELLIPSIS and lbl.SetWrapMode then lbl:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
end

local function list_width() return W.cur_w - 2 * L.margin - L.haul_w - L.gap end

local function build_battle(win)
    local b = {}
    b.container = BGMeter.zenimax.ui.create_control(nil, win, CT_CONTROL)
    b.container:SetAnchor(TOPLEFT, win, TOPLEFT, L.margin, L.header_h)
    b.container:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -(L.haul_w + L.gap + L.margin), -L.footer_h)

    b.headers = {}
    local nameH = P.label(b.container, S.FONT.small, K.COLOR.text_dim)
    nameH:SetText("PLAYER")
    nameH:SetAnchor(TOPLEFT, b.container, TOPLEFT, NAME_X, 0)
    make_clickable(nameH, function() W.sort_by("name") end)
    b.headers.name = nameH

    for _, col in ipairs(COLS) do
        local lbl = P.label(b.container, S.FONT.small, K.COLOR.text_dim)
        lbl:SetText(col.label)
        lbl:SetAnchor(TOPRIGHT, b.container, TOPRIGHT, -col_right(col), 0)
        lbl:SetDimensions(col.w, 16)
        lbl:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        lbl:SetHidden(col_hidden(col))
        if col.key == "caps" then
            make_clickable(lbl, function() W.sort_by(W.flagcol_key or "caps") end)
            W.tip_dynamic(lbl)
        else
            make_clickable(lbl, function() W.sort_by(col.key) end)
        end
        b.headers[col.key] = lbl
    end

    b.rule = P.rect(b.container, { 1, 1, 1, 0.10 })
    b.rule:SetAnchor(TOPLEFT, b.container, TOPLEFT, 0, 18)
    b.rule:SetAnchor(TOPRIGHT, b.container, TOPRIGHT, 0, 18)
    b.rule:SetHeight(1)

    b.row_pool = BGMeter.Plot.pool.new(function() return W._make_row(b.container) end,
        function(row) row.container:SetHidden(true) end)

    b.chart = BGMeter.zenimax.ui.create_control(nil, b.container, CT_CONTROL)
    b.chart:SetAnchor(BOTTOMLEFT, b.container, BOTTOMLEFT, 0, 0)
    b.chart:SetAnchor(BOTTOMRIGHT, b.container, BOTTOMRIGHT, 0, 0)
    b.chart:SetHeight(L.chart_h)
    b.chart:SetHidden(true)

    b.chartBg = P.rect(b.chart, { 1, 1, 1, K.ALPHA.chart_bg })
    b.chartBg:SetAnchorFill(b.chart)

    b.chartTitle = P.label(b.chart, S.FONT.small, K.COLOR.text_dim)
    b.chartTitle:SetText("MATCH TIMELINE")
    b.chartTitle:SetAnchor(TOPLEFT, b.chart, TOPLEFT, 4, 2)
    W.tip_static(b.chartTitle,
        "Team score over time.\nGold skull = your kill  ·  red skull = your death  ·  team-color ticks = other kills\nGold band = bloodiest minute of the match")

    b.dot_pool = BGMeter.Plot.pool.new(
        function()
            local d = P.rect(b.chart, { 1, 1, 1, 1 })
            d:SetDimensions(3, 3)
            return d
        end,
        function(d) d:SetHidden(true) end)

    local probe = P.line(b.chart, { 1, 1, 1, 1 }, 2)
    if probe then
        probe:SetHidden(true)
        b.lines_ok = true
        b.line_pool = BGMeter.Plot.pool.new(
            function() return P.line(b.chart, { 1, 1, 1, 1 }, 2) end,
            function(ln) ln:SetHidden(true); ln:ClearAnchors() end)
    else
        b.lines_ok = false
    end

    b.bloodiest = P.rect(b.chart, { 0.95, 0.80, 0.35, 0.07 })
    b.bloodiest:SetHidden(true)

    b.skull_pool = BGMeter.Plot.pool.new(
        function()
            local ic = P.icon(b.chart, "EsoUI/Art/TargetMarkers/Target_White_Skull_64.dds")
            ic:SetDimensions(14, 14)
            return ic
        end,
        function(ic) ic:SetHidden(true); ic:ClearAnchors() end)

    b.cursor = P.rect(b.chart, { 1, 1, 1, 0.30 })
    b.cursor:SetDimensions(1, L.chart_h - 4)
    b.cursor:SetHidden(true)

    b.chart:SetMouseEnabled(true)
    b.chart:SetHandler("OnMouseEnter", function() W._chart_hover_start() end)
    b.chart:SetHandler("OnMouseExit", function() W._chart_hover_stop() end)

    b.ribbon = BGMeter.zenimax.ui.create_control(nil, b.container, CT_CONTROL)
    b.ribbon:SetAnchor(BOTTOMLEFT, b.container, BOTTOMLEFT, 0, 0)
    b.ribbon:SetAnchor(BOTTOMRIGHT, b.container, BOTTOMRIGHT, 0, 0)
    b.ribbon:SetHeight(0)
    b.ribbon:SetHidden(true)

    b.ribbonBg = P.rect(b.ribbon, { 1, 1, 1, K.ALPHA.chart_bg })
    b.ribbonBg:SetAnchorFill(b.ribbon)

    b.ribbonTitle = P.label(b.ribbon, S.FONT.small, K.COLOR.text_dim)
    b.ribbonTitle:SetText("FLAG CONTROL")
    b.ribbonTitle:SetAnchor(TOPLEFT, b.ribbon, TOPLEFT, 4, 2)
    W.tip_static(b.ribbonTitle,
        "Who held each flag over time (lane color = owning team).\nFlag pin = captured  ·  shield = attack defended\nHover any pin for the details")

    b.ribbon_pool = BGMeter.Plot.pool.new(
        function() return P.rect(b.ribbon, { 1, 1, 1, 1 }) end,
        function(r) r:SetHidden(true); r:ClearAnchors() end)

    b.ribbon_letters = {}
    b.lane_pins = {}

    b.pin_pool = BGMeter.Plot.pool.new(
        function() return P.icon(b.ribbon, "") end,
        function(ic) ic:SetHidden(true); ic:ClearAnchors() end)

    b.tick_hit_pool = BGMeter.Plot.pool.new(
        function()
            local h = BGMeter.zenimax.ui.create_control(nil, b.ribbon, CT_CONTROL)
            W.tip_dynamic(h)
            return h
        end,
        function(h) h:SetHidden(true); h:ClearAnchors(); W.tips[h] = nil end)

    b.ribbon:SetMouseEnabled(true)
    b.ribbon:SetHandler("OnMouseEnter", function() W._chart_hover_start() end)
    b.ribbon:SetHandler("OnMouseExit", function() W._chart_hover_stop() end)

    b.occ = BGMeter.zenimax.ui.create_control(nil, b.container, CT_CONTROL)
    b.occ:SetAnchor(BOTTOMLEFT, b.container, BOTTOMLEFT, 0, 0)
    b.occ:SetAnchor(BOTTOMRIGHT, b.container, BOTTOMRIGHT, 0, 0)
    b.occ:SetHeight(0)
    b.occ:SetHidden(true)

    b.occBg = P.rect(b.occ, { 1, 1, 1, K.ALPHA.chart_bg })
    b.occBg:SetAnchorFill(b.occ)

    b.occTitle = P.label(b.occ, S.FONT.small, K.COLOR.text_dim)
    b.occTitle:SetText("FLAG OCCUPATION")
    b.occTitle:SetAnchor(TOPLEFT, b.occ, TOPLEFT, 4, 2)
    W.tip_static(b.occTitle,
        "Share of total flag-hold time per team.\nBelow: captures, successful defenses, average hold per team, first capture")

    b.occLegend = P.label(b.occ, S.FONT.small, K.COLOR.text)
    U.clamp_line(b.occLegend)
    b.occLegend:SetAnchor(TOPLEFT, b.occTitle, TOPRIGHT, 10, 0)
    b.occLegend:SetAnchor(TOPRIGHT, b.occ, TOPRIGHT, -4, 2)
    b.occLegend:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    one_line(b.occLegend)

    b.occStats = P.label(b.occ, S.FONT.small, K.COLOR.text_dim)
    U.clamp_line(b.occStats)
    b.occStats:SetAnchor(TOPLEFT, b.occ, TOPLEFT, 4, 32)
    b.occStats:SetAnchor(TOPRIGHT, b.occ, TOPRIGHT, -4, 32)
    one_line(b.occStats)

    b.occ_pool = BGMeter.Plot.pool.new(
        function() return P.rect(b.occ, { 1, 1, 1, 1 }) end,
        function(r) r:SetHidden(true); r:ClearAnchors() end)

    b.mom = BGMeter.zenimax.ui.create_control(nil, b.container, CT_CONTROL)
    b.mom:SetAnchor(BOTTOMLEFT, b.container, BOTTOMLEFT, 0, 0)
    b.mom:SetAnchor(BOTTOMRIGHT, b.container, BOTTOMRIGHT, 0, 0)
    b.mom:SetHeight(0)
    b.mom:SetHidden(true)

    b.momBg = P.rect(b.mom, { 1, 1, 1, K.ALPHA.chart_bg })
    b.momBg:SetAnchorFill(b.mom)

    b.momTitle = P.label(b.mom, S.FONT.small, K.COLOR.text_dim)
    b.momTitle:SetText("MOMENTUM")
    b.momTitle:SetAnchor(TOPLEFT, b.mom, TOPLEFT, 4, 0)
    W.tip_static(b.momTitle,
        "Who was leading, and by how much.\nColor = leading team  ·  brighter = bigger lead")

    b.momStats = P.label(b.mom, S.FONT.small, K.COLOR.text_dim)
    b.momStats:SetAnchor(TOPLEFT, b.mom, TOPLEFT, 4, 30)
    b.momStats:SetAnchor(TOPRIGHT, b.mom, TOPRIGHT, -4, 30)
    one_line(b.momStats)

    b.mom_pool = BGMeter.Plot.pool.new(
        function() return P.rect(b.mom, { 1, 1, 1, 1 }) end,
        function(r) r:SetHidden(true); r:ClearAnchors() end)

    b.mom:SetMouseEnabled(true)
    b.mom:SetHandler("OnMouseEnter", function() W._chart_hover_start() end)
    b.mom:SetHandler("OnMouseExit", function() W._chart_hover_stop() end)

    return b
end

function W._make_row(parent)
    local row = { cells = {} }
    row.container = BGMeter.zenimax.ui.create_control(nil, parent, CT_CONTROL)
    row.container:SetHeight(L.row_h)
    row.container:SetMouseEnabled(true)

    row.highlight = P.rect(row.container, { 1, 1, 1, 0 })
    row.highlight:SetAnchorFill(row.container)

    row.teamStrip = P.rect(row.container, { 0, 0, 0, 0 })
    row.teamStrip:SetDimensions(3, L.row_h - 8)
    row.teamStrip:SetAnchor(LEFT, row.container, LEFT, 1, 0)

    row.bar = Bar.create(row.container)
    row.bar.container:SetAnchor(TOPLEFT, row.container, TOPLEFT, BAR_X, 3)
    row.bar.container:SetAnchor(BOTTOMRIGHT, row.container, BOTTOMRIGHT, -BAR_RIGHT, -3)

    row.index = P.label(row.container, S.FONT.small, K.COLOR.text_dim)
    row.index:SetAnchor(LEFT, row.container, LEFT, INDEX_X, 0)
    row.index:SetDimensions(16, L.row_h)

    row.classIcon = P.icon(row.container)
    row.classIcon:SetDimensions(20, 20)
    row.classIcon:SetAnchor(LEFT, row.container, LEFT, ICON_X, 0)

    row.name = P.label(row.container, S.FONT.row, K.COLOR.text)
    row.name:SetAnchor(LEFT, row.container, LEFT, NAME_X, 0)
    row.name:SetAnchor(RIGHT, row.container, RIGHT, -NAME_RIGHT, 0)
    row.name:SetHeight(L.row_h)
    row.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    if row.name.SetMaxLineCount then row.name:SetMaxLineCount(1) end
    if TEXT_WRAP_MODE_ELLIPSIS and row.name.SetWrapMode then
        row.name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end

    for _, col in ipairs(COLS) do
        local lbl = P.label(row.container, S.FONT.row, K.COLOR.text)
        lbl:SetAnchor(RIGHT, row.container, RIGHT, -col_right(col), 0)
        lbl:SetDimensions(col.w, L.row_h)
        lbl:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        lbl:SetHidden(col_hidden(col))
        row.cells[col.key] = lbl
    end
    row.capsLayout = false

    row.container:SetHandler("OnMouseEnter", function()
        if W._last_row_log ~= row then
            W._last_row_log = row
            BGMeter.Log.debug("row enter: %s", tostring(row.prow and (row.prow.displayName or row.prow.charName) or "?"))
        end
        P.set_rect_color(row.highlight, { 1, 1, 1, K.ALPHA.row_hover })
    end)
    row.container:SetHandler("OnMouseExit", function() P.set_rect_color(row.highlight, row.baseHL or { 0, 0, 0, 0 }) end)
    return row
end

local function apply_dynamic_min_width(m)
    if not W.measure then return end
    local maxw = 0
    for _, prow in ipairs(m.battle) do
        W.measure:SetText(U.player_ident(prow))
        local tw = W.measure:GetTextWidth() or 0
        if tw > maxw then maxw = tw end
    end
    if maxw <= 0 then return end
    local needed = math.ceil(maxw) + 26 + NAME_X + NAME_RIGHT + (caps_shown and CAPS_SHIFT or 0) + 2 * L.margin + L.haul_w + L.gap
    local dyn = math.max(L.min_w, math.min(needed, L.dyn_min_cap))

    local extra
    local nflags = m.objectives and m.objectives.list and #m.objectives.list or 0
    if nflags == 0 and m.relics and m.relics.list then nflags = #m.relics.list end
    if nflags > 0 then
        local lh, lg = U.lane_metrics(nflags)
        extra = (L.occ_h + 2) + (L.ribbon_top + nflags * (lh + lg) + 3 + 2) + (28 + 2)
    else
        extra = 46 + 2
    end
    local needed_h = L.header_h + 24 + #m.battle * L.row_h + L.chart_h + extra + 8 + L.footer_h + 12
    local dyn_h = math.max(L.min_h, math.min(needed_h, L.max_h))

    if dyn ~= W.dyn_min or dyn_h ~= W.dyn_min_h then
        W.dyn_min = dyn
        W.dyn_min_h = dyn_h
        W.win:SetDimensionConstraints(dyn, dyn_h, L.max_w, L.max_h)
    end
    local sv = BGMeter.zenimax.savedvars.get()
    if W.cur_w < dyn then
        W.cur_w = dyn
        W.win:SetWidth(dyn)
        if sv then sv.window = sv.window or {}; sv.window.w = dyn end
    end
    if W.cur_h < dyn_h then
        W.cur_h = dyn_h
        W.win:SetHeight(dyn_h)
        if sv then sv.window = sv.window or {}; sv.window.h = dyn_h end
    end
end

local function caps_relevant(m)
    if m.objectives and m.objectives.list and #m.objectives.list > 0 then return true end
    for _, r in ipairs(m.battle) do
        if (r.caps or 0) > 0 or (r.carried or 0) > 0 then return true end
    end
    return false
end

local function flag_col_spec(m)
    local gt = C.GAME_TYPE_LABEL and C.GAME_TYPE_LABEL[m.gameType] or nil
    if gt == "murderball" then
        return "carried", "HOLD",
            "BALL POSSESSION\nTime this player spent holding a chaosball\n(the ball scores for their team while held). Click to sort."
    end
    return "caps", "CAP",
        "CAPTURES\nObjectives this player captured for their team\n(flags, capture points, relics). Click to sort."
end

local function caps_count(m, v)
    local gt = C.GAME_TYPE_LABEL and C.GAME_TYPE_LABEL[m.gameType] or nil
    if gt == "capture_the_flag" then return math.floor(v / 100 + 0.5) end
    return v
end

local function name_right()
    return NAME_RIGHT + (caps_shown and CAPS_SHIFT or 0)
end

local function layout_headers(b)
    for _, col in ipairs(COLS) do
        local lbl = b.headers[col.key]
        if lbl then
            lbl:ClearAnchors()
            lbl:SetAnchor(TOPRIGHT, b.container, TOPRIGHT, -col_right(col), 0)
            lbl:SetHidden(col_hidden(col))
        end
    end
end

local function layout_row_cells(row)
    for _, col in ipairs(COLS) do
        local cell = row.cells[col.key]
        cell:ClearAnchors()
        cell:SetAnchor(RIGHT, row.container, RIGHT, -col_right(col), 0)
        cell:SetHidden(col_hidden(col))
    end
    row.name:ClearAnchors()
    row.name:SetAnchor(LEFT, row.container, LEFT, NAME_X, 0)
    row.name:SetAnchor(RIGHT, row.container, RIGHT, -name_right(), 0)
    row.capsLayout = caps_shown
end

function SEC.battle(m, animate)
    local b = W.battle
    b.row_pool:release_all()
    local want_caps = caps_relevant(m)
    if want_caps ~= caps_shown then
        caps_shown = want_caps
        layout_headers(b)
    end
    local fkey, flabel, ftip = flag_col_spec(m)
    W.flagcol_key = fkey
    if b.headers.caps then W.tips[b.headers.caps] = ftip end
    apply_dynamic_min_width(m)

    local key = Prefs.get("sort_key") or "damage"
    if (key == "caps" or key == "carried") and not caps_shown then key = "damage" end
    if key == "caps" or key == "carried" then key = fkey end
    if key == "name" then
        local desc = Prefs.get("sort_desc")
        table.sort(m.battle, function(a, z)
            local an = (a.displayName or a.charName or ""):lower()
            local zn = (z.displayName or z.charName or ""):lower()
            if desc then return an > zn end
            return an < zn
        end)
    else
        BGMeter.Match.sort(m, key, Prefs.get("sort_desc"))
    end

    for ckey, lbl in pairs(b.headers) do
        local base = (ckey == "name") and "PLAYER" or ckey
        for _, col in ipairs(COLS) do if col.key == ckey then base = col.label end end
        if ckey == "caps" then base = flabel end
        if (ckey == "caps" and key == fkey) or ckey == key then
            S.color(lbl, K.COLOR.text)
            set_text(lbl, base .. " " .. F.icon(Prefs.get("sort_desc") and ICON_SORTDN or ICON_SORTUP, 16))
        else
            S.color(lbl, K.COLOR.text_dim); set_text(lbl, base)
        end
    end

    local awards = Prefs.get("show_awards") and Awards.compute(m) or { leaders = {}, mvp = nil }
    local barKey = (key == "name" or key == "deaths") and "damage" or key
    local maxVal = BGMeter.Match.column_max(m, barKey)
    local barBase = (barKey == "healing") and K.COLOR.heal or K.COLOR.accent
    local listW = list_width()
    local y = 24

    for i, prow in ipairs(m.battle) do
        local row = b.row_pool:acquire()
        row.prow = prow
        if row.capsLayout ~= caps_shown then layout_row_cells(row) end
        row.container:SetHidden(false)
        row.container:ClearAnchors()
        row.container:SetAnchor(TOPLEFT, b.container, TOPLEFT, 0, y)
        row.container:SetAnchor(TOPRIGHT, b.container, TOPRIGHT, 0, y)

        set_text(row.index, tostring(i))
        local cicon = Icons.class(prow.classId)
        if cicon then row.classIcon:SetTexture(cicon); row.classIcon:SetHidden(false) else row.classIcon:SetHidden(true) end

        local nm = U.player_ident(prow)
        if awards.mvp == prow then nm = F.icon(ICON_STAR, 20) .. " " .. nm end
        set_text(row.name, nm)
        S.color(row.name, prow.isLocal and K.COLOR.you or S.team_color(prow.team))

        if prow.team then
            local tc = S.team_color(prow.team)
            P.set_rect_color(row.teamStrip, { tc[1], tc[2], tc[3], K.ALPHA.team_strip })
        else
            P.set_rect_color(row.teamStrip, { 0, 0, 0, 0 })
        end

        for _, col in ipairs(COLS) do
            local ck = (col.key == "caps") and fkey or col.key
            local cell, v = row.cells[col.key], (prow[ck] or 0) + 0
            local txt
            if col.key == "damage" or col.key == "healing" or col.key == "score" then
                txt = F.abbrev(v)
            elseif ck == "carried" then
                txt = (v > 0) and F.duration(v * 1000) or "0"
            elseif ck == "caps" then
                txt = tostring(caps_count(m, v))
            else
                txt = tostring(v)
            end
            set_text(cell, txt)
            if awards.leaders[ck] == prow and v > 0 then S.color(cell, K.COLOR.gold)
            elseif v == 0 then S.color(cell, K.COLOR.text_dim)
            else S.color(cell, K.COLOR.text) end
        end

        local pct = (maxVal > 0) and ((prow[barKey] or 0) / maxVal) or 0
        local bc = prow.isLocal and K.COLOR.you or barBase
        set_bar(row.bar, pct, { bc[1], bc[2], bc[3], K.ALPHA.bar_fill }, listW - BAR_X - BAR_RIGHT, animate)

        local hl = { 0, 0, 0, 0 }
        if awards.mvp == prow then hl = { K.COLOR.gold[1], K.COLOR.gold[2], K.COLOR.gold[3], K.ALPHA.row_mvp } end
        if prow.isLocal then hl = { K.COLOR.you[1], K.COLOR.you[2], K.COLOR.you[3], K.ALPHA.row_you } end
        if W.selected_row == prow then hl = { 1, 1, 1, K.ALPHA.row_selected } end
        row.baseHL = hl
        P.set_rect_color(row.highlight, hl)
        row.container:SetHandler("OnMouseUp", function(_, button, upInside)
            if not upInside then return end
            if MOUSE_BUTTON_INDEX_RIGHT and button == MOUSE_BUTTON_INDEX_RIGHT then
                local name = prow.displayName or prow.charName
                if name and not prow.isLocal
                    and type(ClearMenu) == "function" and type(AddMenuItem) == "function"
                    and type(ShowMenu) == "function" then
                    name = (name:gsub("%^.*$", ""))
                    ClearMenu()
                    if CHAT_SYSTEM and CHAT_SYSTEM.StartTextEntry and CHAT_CHANNEL_WHISPER then
                        AddMenuItem("Whisper " .. name, function()
                            CHAT_SYSTEM:StartTextEntry("", CHAT_CHANNEL_WHISPER, name)
                        end)
                    end
                    if type(GroupInviteByName) == "function" then
                        AddMenuItem("Invite to Group", function() GroupInviteByName(name) end)
                    end
                    ShowMenu(row.container)
                end
                return
            end
            W.select(prow)
        end)

        y = y + L.row_h
    end
end

U.build_battle = build_battle
U.flag_col_spec = flag_col_spec
U.caps_count = caps_count
