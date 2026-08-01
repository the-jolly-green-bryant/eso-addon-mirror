BGMeter = BGMeter or {}
local BGMeter = BGMeter

local U = BGMeter.UI._win
local W = U.W
local SEC = U.SEC
local hexc, team_name, neutral_color, flag_pin, hit_proxy = U.hexc, U.team_name, U.neutral_color, U.flag_pin, U.hit_proxy

local C = BGMeter.zenimax.constants
local K = BGMeter.Constants
local L = BGMeter.Constants.LAYOUT
local F = BGMeter.Format
local P = BGMeter.Plot.primitives
local S = BGMeter.Plot.style
local Prefs = BGMeter.Prefs

local function timeline_ok(m)
    local tl = m.timeline
    return Prefs.get("show_timeline") and tl and tl.t and #tl.t >= 3
end

local function series_max(arr, n)
    local mx = 0
    for i = 1, n do
        local v = arr and arr[i] or 0
        if v > mx then mx = v end
    end
    return mx
end

local function ribbon_letter(b, i)
    local lbl = b.ribbon_letters[i]
    if not lbl then
        lbl = P.label(b.ribbon, S.FONT.small, K.COLOR.text)
        b.ribbon_letters[i] = lbl
    end
    return lbl
end

local function lane_pin(b, i)
    local ic = b.lane_pins[i]
    if not ic then
        ic = P.icon(b.ribbon, "")
        ic:SetDimensions(28, 28)
        b.lane_pins[i] = ic
    end
    return ic
end

function SEC.occupation(b, occ, neutralPct, stats, w)
    b.occ:SetHeight(L.occ_h)
    b.occ:SetHidden(false)
    local bw = w - 6
    local x = 0
    local parts = {}
    for _, e in ipairs(occ) do
        local tc = S.team_color(e.team)
        local seg_w = math.floor(e.pct * bw + 0.5)
        if seg_w > 1 then
            local r = b.occ_pool:acquire()
            r:SetAnchor(TOPLEFT, b.occ, TOPLEFT, x, 18)
            r:SetDimensions(seg_w, 10)
            P.set_rect_color(r, { tc[1], tc[2], tc[3], 0.80 })
            r:SetHidden(false)
            x = x + seg_w
        end
        parts[#parts + 1] = string.format("|c%s%s %d%%|r",
            hexc(tc), team_name(e.team), math.floor(e.pct * 100 + 0.5))
    end
    if x < bw then
        local r = b.occ_pool:acquire()
        r:SetAnchor(TOPLEFT, b.occ, TOPLEFT, x, 18)
        r:SetDimensions(bw - x, 10)
        local nc = neutral_color()
        P.set_rect_color(r, { nc[1], nc[2], nc[3], K.ALPHA.ribbon_neutral })
        r:SetHidden(false)
        if neutralPct and neutralPct >= 0.005 then
            local nl = "neutral"
            if stats and stats.mode == "relic" then nl = "at base"
            elseif stats and stats.mode == "ball" then nl = "loose" end
            parts[#parts + 1] = string.format("|c8c8c95%s %d%%|r",
                nl, math.floor(neutralPct * 100 + 0.5))
        end
    end
    b.occLegend:SetText(table.concat(parts, "  ·  "))

    local sp = {}
    if stats then
        for _, e in ipairs(stats.per) do
            local tc = S.team_color(e.team)
            if stats.mode == "relic" then
                sp[#sp + 1] = string.format("|c%s%s  %d/%d runs scored · avg run %s|r",
                    hexc(tc), team_name(e.team), e.caps, e.holds or 0, F.duration(e.avgHoldMs))
            elseif stats.mode == "ball" then
                sp[#sp + 1] = string.format("|c%s%s  held %s · avg %s|r",
                    hexc(tc), team_name(e.team), F.duration(e.holdMs), F.duration(e.avgHoldMs))
            else
                sp[#sp + 1] = string.format("|c%s%s  %d caps · %d defs · avg hold %s|r",
                    hexc(tc), team_name(e.team), e.caps, e.defs, F.duration(e.avgHoldMs))
            end
        end
        if stats.first then
            local tc = S.team_color(stats.first.team)
            sp[#sp + 1] = string.format("|c%s%s %s @ %s|r",
                hexc(tc), (stats.mode == "relic") and "first goal" or "first",
                tostring(stats.first.name or stats.first.letter), F.duration(stats.first.t))
        end
    end
    b.occStats:SetText(table.concat(sp, "    "))
end

local function lane_label(lane)
    return lane.name or ("flag " .. tostring(lane.letter))
end

function SEC.ribbon(b, lanes, ribbon_h, tspan, w, y_off, gt)
    b.ribbon:ClearAnchors()
    b.ribbon:SetAnchor(BOTTOMLEFT, b.container, BOTTOMLEFT, 0, -y_off)
    b.ribbon:SetAnchor(BOTTOMRIGHT, b.container, BOTTOMRIGHT, 0, -y_off)
    b.ribbon:SetHeight(ribbon_h)
    b.ribbon:SetHidden(false)
    local lh, lg = U.lane_metrics(#lanes)
    local pinS = math.max(16, math.floor(L.pin_size * lh / L.lane_h))
    local function rx(t) return math.floor((t / tspan) * (w - 6) + 0.5) end
    for li, lane in ipairs(lanes) do
        local y = L.ribbon_top + (li - 1) * (lh + lg)
        for _, seg in ipairs(lane.segs) do
            local x0, x1 = rx(seg.t0), rx(seg.t1)
            if x1 > x0 then
                local r = b.ribbon_pool:acquire()
                r:SetAnchor(TOPLEFT, b.ribbon, TOPLEFT, x0, y)
                r:SetDimensions(x1 - x0, lh)
                if seg.own and seg.own ~= 0 then
                    local tc = S.team_color(seg.own)
                    P.set_rect_color(r, { tc[1], tc[2], tc[3], K.ALPHA.ribbon_fill })
                else
                    local nc = neutral_color()
                    P.set_rect_color(r, { nc[1], nc[2], nc[3], K.ALPHA.ribbon_neutral })
                end
                r:SetHidden(false)
            end
        end
        for _, tick in ipairs(lane.ticks) do
            local ic = b.pin_pool:acquire()
            local tip
            local ctf = (gt == "capture_the_flag")
            local tlabel = tick.name or lane_label(lane)
            if tick.kind == "take" then
                ic:SetTexture(string.format("EsoUI/Art/MapPins/battlegrounds_murderball_%s.dds",
                    S.team_art_key(tick.own)))
                ic:SetDimensions(pinS - 12, pinS - 12)
                ic:SetColor(1, 1, 1, 1)
                tip = string.format("%s took %s @ %s",
                    tick.who or team_name(tick.own), tlabel, F.duration(tick.t))
            elseif tick.kind == "def" then
                local tc = S.team_color(tick.own)
                if ctf then
                    ic:SetTexture("EsoUI/Art/Buttons/closeButton_up.dds")
                    ic:SetDimensions(pinS - 10, pinS - 10)
                else
                    ic:SetTexture("EsoUI/Art/WorldMap/map_AVA_tabIcon_resourceDefense_up.dds")
                    ic:SetDimensions(pinS - 6, pinS - 6)
                end
                ic:SetColor(tc[1], tc[2], tc[3], 1)
                tip = string.format("%s %s %s @ %s",
                    team_name(tick.own), ctf and "returned" or "defended",
                    tlabel, F.duration(tick.t))
            elseif ctf then
                ic:SetTexture("EsoUI/Art/Collections/Favorite_StarOnly.dds")
                ic:SetDimensions(pinS, pinS)
                local tc = S.team_color(tick.own)
                ic:SetColor(tc[1], tc[2], tc[3], 1)
                tip = string.format("%s scored %s @ %s",
                    tick.who or team_name(tick.own), tlabel, F.duration(tick.t))
            else
                ic:SetTexture(flag_pin(gt, tick.letter or lane.letter, tick.own))
                ic:SetDimensions(pinS, pinS)
                ic:SetColor(1, 1, 1, 1)
                tip = string.format("%s captured %s @ %s",
                    team_name(tick.own), tlabel, F.duration(tick.t))
            end
            local half = math.floor(pinS / 2)
            local tx = math.max(half, math.min(rx(tick.t), w - 6 - half))
            ic:SetAnchor(CENTER, b.ribbon, TOPLEFT, tx, y + math.floor(lh / 2))
            ic:SetHidden(false)
            local hit = b.tick_hit_pool:acquire()
            hit:SetAnchorFill(ic)
            hit:SetHidden(false)
            W.tips[hit] = tip
        end
        local is_letter = lane.letter and lane.letter:match("^[ABCD]$") ~= nil
        local river = lane.letter == "~"
        local lbl = ribbon_letter(b, li)
        local pin = lane_pin(b, li)
        if is_letter or river then
            pin:SetTexture(flag_pin(gt, river and nil or lane.letter, 0))
            pin:ClearAnchors()
            pin:SetAnchor(LEFT, b.ribbon, TOPLEFT, 2, y + math.floor(lh / 2))
            pin:SetHidden(false)
            lbl:SetHidden(true)
        else
            lbl:SetText(lane.letter)
            lbl:ClearAnchors()
            lbl:SetAnchor(TOPRIGHT, b.ribbon, TOPLEFT, -4, y - 2)
            lbl:SetHidden(false)
            pin:SetHidden(true)
        end
    end
    for i = #lanes + 1, #b.ribbon_letters do
        b.ribbon_letters[i]:SetHidden(true)
    end
    for i = #lanes + 1, #b.lane_pins do
        b.lane_pins[i]:SetHidden(true)
    end
end

function SEC.momentum(b, m, tl, n, tspan, w, mom_h, mom_off, lead, tdm_line, cmom, cmomMax)
    b.mom:ClearAnchors()
    b.mom:SetAnchor(BOTTOMLEFT, b.container, BOTTOMLEFT, 0, -mom_off)
    b.mom:SetAnchor(BOTTOMRIGHT, b.container, BOTTOMRIGHT, 0, -mom_off)
    b.mom:SetHeight(mom_h)
    b.mom:SetHidden(false)

    local function mx(t) return math.floor((t / tspan) * (w - 6) + 0.5) end
    if cmom then
        b.momTitle:SetText("COMBAT MOMENTUM")
        W.tips[b.momTitle] = "Who was winning the FIGHT, minute by minute.\nColor = team ahead on kills in the last 60s  ·  brighter = more dominant\nWhen this disagrees with the score chart above, kills were not buying points."
        local peak = math.max(3, math.ceil(math.max(cmomMax or 1, 1) * 0.75))
        for _, sg in ipairs(cmom) do
            local x0, x1 = mx(sg.t0), mx(sg.t1)
            if x1 > x0 then
                local r = b.mom_pool:acquire()
                r:SetAnchor(TOPLEFT, b.mom, TOPLEFT, x0, 18)
                r:SetDimensions(x1 - x0, 10)
                if sg.team then
                    local tc = S.team_color(sg.team)
                    local a = 0.18 + 0.62 * math.min(1, sg.mag / math.max(cmomMax or 1, 1))
                    P.set_rect_color(r, { tc[1], tc[2], tc[3], a })
                    local hit = b.tick_hit_pool:acquire()
                    hit:SetAnchorFill(r)
                    hit:SetHidden(false)
                    W.tips[hit] = string.format("%s +%d kills", team_name(sg.team), sg.mag)
                    if sg.mag >= peak and (x1 - x0) >= 26 then
                        local ic = b.pin_pool:acquire()
                        ic:SetTexture("EsoUI/Art/DeathRecap/deathRecap_killingBlow_icon.dds")
                        ic:SetDimensions(18, 18)
                        ic:SetColor(tc[1], tc[2], tc[3], 1)
                        ic:SetAnchor(CENTER, b.mom, TOPLEFT, math.floor((x0 + x1) / 2), 23)
                        ic:SetHidden(false)
                    end
                else
                    local nc = neutral_color()
                    P.set_rect_color(r, { nc[1], nc[2], nc[3], 0.10 })
                end
                r:SetHidden(false)
            end
        end
    elseif lead then
        b.momTitle:SetText("MOMENTUM")
        W.tips[b.momTitle] = "Who was leading, and by how much.\nColor = leading team  ·  brighter = bigger lead"
        local series = { tl.s1, tl.s2, tl.s3 }
        local teams = tl.teams or {}
        local maxLead = math.max(1, (lead and lead.maxLead) or 1)
        for i = 2, n do
            local best, second, bestTeam = 0, 0, nil
            for s = 1, 3 do
                local team = teams[s]
                local v = (series[s] and series[s][i]) or 0
                if team and v > best then
                    second = best
                    best, bestTeam = v, team
                elseif team and v > second then
                    second = v
                end
            end
            local margin = best - second
            local x0, x1 = mx(tl.t[i - 1] or 0), mx(tl.t[i] or 0)
            if x1 > x0 then
                local r = b.mom_pool:acquire()
                r:SetAnchor(TOPLEFT, b.mom, TOPLEFT, x0, 18)
                r:SetDimensions(x1 - x0, 10)
                if bestTeam and margin > 0 then
                    local tc = S.team_color(bestTeam)
                    local a = 0.15 + 0.60 * math.min(1, margin / maxLead)
                    P.set_rect_color(r, { tc[1], tc[2], tc[3], a })
                else
                    local nc = neutral_color()
                    P.set_rect_color(r, { nc[1], nc[2], nc[3], 0.10 })
                end
                r:SetHidden(false)
            end
        end
    end

    if not tdm_line then
        b.momStats:SetText("")
        return
    end
    local Match = BGMeter.Match
    local sp = {}
    if lead then
        local tc = S.team_color(lead.maxTeam)
        sp[#sp + 1] = string.format("|c%smax lead %s +%d|r", hexc(tc), team_name(lead.maxTeam), lead.maxLead)
        sp[#sp + 1] = string.format("lead changes %d", lead.changes)
    end
    local bm = Match.bloodiest_minute(m.killfeed)
    if bm then
        sp[#sp + 1] = string.format("|c%sbloodiest %s-%s (%d kills)|r",
            hexc(K.COLOR.gold), F.duration(bm.t0), F.duration(bm.t1), bm.count)
    end
    local fb = Match.first_blood(m.killfeed)
    if fb then
        local tc = S.team_color(fb.kt)
        sp[#sp + 1] = string.format("|c%sfirst blood %s|r @ %s", hexc(tc), tostring(fb.kn), F.duration(fb.t))
    end
    local runs = Match.kill_streaks(m.killfeed)
    if runs then
        local best = runs[1]
        for _, r in ipairs(runs) do
            if r.n > best.n then best = r end
        end
        local tc = S.team_color(best.team)
        sp[#sp + 1] = string.format("best streak |c%s%s x%d|r", hexc(tc), tostring(best.name), best.n)
    end
    b.momStats:SetText(table.concat(sp, "    "))
end

function SEC.timeline(m)
    local b = W.battle
    b.dot_pool:release_all()
    if b.line_pool then b.line_pool:release_all() end
    b.skull_pool:release_all()
    b.ribbon_pool:release_all()
    b.pin_pool:release_all()
    b.tick_hit_pool:release_all()
    for _, lbl in ipairs(b.ribbon_letters) do lbl:SetHidden(true) end
    for _, ic in ipairs(b.lane_pins) do ic:SetHidden(true) end
    b.ribbon:SetHidden(true)
    b.occ_pool:release_all()
    b.occ:SetHidden(true)
    b.mom_pool:release_all()
    b.mom:SetHidden(true)
    b.bloodiest:SetHidden(true)
    W.chart_state = nil
    if not timeline_ok(m) then
        b.chart:SetHidden(true)
        return
    end

    local tl = m.timeline
    local n = #tl.t
    local tspan = math.max(1, tl.t[n] or 1)
    local gt = C.GAME_TYPE_LABEL and C.GAME_TYPE_LABEL[m.gameType] or nil

    local dc = W._derived
    if not dc or dc.m ~= m or dc.tspan ~= tspan then
        dc = { m = m, tspan = tspan }
        dc.lanes = BGMeter.Match.flag_lanes(m, tspan)
        dc.relicMode = false
        if not dc.lanes and BGMeter.Match.relic_lanes then
            dc.lanes = BGMeter.Match.relic_lanes(m, tspan)
            dc.relicMode = dc.lanes ~= nil
        end
        if dc.lanes then
            dc.occ, dc.neutralPct = BGMeter.Match.flag_occupation(dc.lanes, tspan)
            dc.fstats = BGMeter.Match.flag_stats(dc.lanes)
            if dc.fstats then dc.fstats.mode = dc.relicMode and (gt == "murderball" and "ball" or "relic") or nil end
            if dc.relicMode and dc.occ then
                local held = 0
                for _, e in ipairs(dc.occ) do held = held + e.pct end
                dc.neutralPct = math.max(0, 1 - held)
            end
            if dc.occ and #dc.occ == 0 then dc.occ = nil end
        end
        dc.lead = BGMeter.Match.lead_stats(tl)
        dc.bm = BGMeter.Match.bloodiest_minute(m.killfeed)
        dc.cmom, dc.cmomMax = BGMeter.Match.combat_momentum(m.killfeed, tspan)
        W._derived = dc
    end
    local lanes, relicMode = dc.lanes, dc.relicMode
    local occ, neutralPct, fstats = dc.occ, dc.neutralPct, dc.fstats
    local lead = dc.lead
    if lanes then
        b.ribbonTitle:SetText(relicMode and (gt == "murderball" and "BALL POSSESSION" or "RELIC RUNS") or "FLAG CONTROL")
        b.occTitle:SetText(relicMode and "POSSESSION" or "FLAG OCCUPATION")
    end
    local ribbon_h = 0
    if lanes then
        local lh, lg = U.lane_metrics(#lanes)
        ribbon_h = L.ribbon_top + #lanes * (lh + lg) + 3
    end
    local occ_h = occ and L.occ_h or 0
    local tdm_line = (not lanes) and lead ~= nil
    local mom_h = (dc.cmom or lead) and (tdm_line and 46 or 28) or 0

    local rows_h = 24 + #m.battle * L.row_h
    local cont_h = b.container:GetHeight()
    local function fits(extra) return cont_h - rows_h >= L.chart_h + extra + 8 end
    if lanes and mom_h > 0 and not fits(mom_h + ribbon_h + occ_h) then
        mom_h, tdm_line = 0, false
    end
    if occ_h > 0 and not fits(mom_h + ribbon_h + occ_h) then
        occ, occ_h = nil, 0
    end
    if ribbon_h > 0 and not fits(mom_h + ribbon_h + occ_h) then
        lanes, ribbon_h = nil, 0
    end
    if mom_h > 0 and tdm_line and not fits(mom_h + ribbon_h + occ_h) then
        mom_h, tdm_line = 28, false
    end
    if mom_h > 0 and not fits(mom_h + ribbon_h + occ_h) then
        mom_h, tdm_line = 0, false
    end
    if not fits(0) then
        b.chart:SetHidden(true)
        return
    end
    local rib_off = (occ_h > 0) and (occ_h + 2) or 0
    local mom_off = rib_off + ((ribbon_h > 0) and (ribbon_h + 2) or 0)
    local chart_off = mom_off + ((mom_h > 0) and (mom_h + 2) or 0)
    b.chart:SetHidden(false)
    b.chart:ClearAnchors()
    b.chart:SetAnchor(BOTTOMLEFT, b.container, BOTTOMLEFT, 0, -chart_off)
    b.chart:SetAnchor(BOTTOMRIGHT, b.container, BOTTOMRIGHT, 0, -chart_off)
    b.chart:SetHeight(L.chart_h)

    local w = b.chart:GetWidth()
    local h = L.chart_h
    if w <= 8 then return end

    local series = { tl.s1, tl.s2, tl.s3 }
    local smax = {}
    local maxScore = 1
    for s = 1, 3 do
        smax[s] = series_max(series[s], n)
        if smax[s] > maxScore then maxScore = smax[s] end
    end

    local plot_h = h - 18
    local function px(i) return math.floor((tl.t[i] / tspan) * (w - 6) + 0.5) end
    local function py(arr, i) return 14 + math.floor((1 - (arr[i] or 0) / maxScore) * plot_h + 0.5) end

    for s = 1, 3 do
        local arr = series[s]
        local team = tl.teams and tl.teams[s]
        if arr and smax[s] > 0 and team then
            local tc = S.team_color(team)
            if b.lines_ok then
                for i = 2, n do
                    local ln = b.line_pool:acquire()
                    ln:ClearAnchors()
                    ln:SetAnchor(TOPLEFT, b.chart, TOPLEFT, px(i - 1), py(arr, i - 1))
                    ln:SetAnchor(TOPRIGHT, b.chart, TOPLEFT, px(i), py(arr, i))
                    ln:SetColor(tc[1], tc[2], tc[3], 0.95)
                    if ln.SetThickness then ln:SetThickness(2) end
                    ln:SetHidden(false)
                end
            else
                for i = 1, n do
                    local dot = b.dot_pool:acquire()
                    dot:ClearAnchors()
                    dot:SetAnchor(TOPLEFT, b.chart, TOPLEFT, px(i), py(arr, i))
                    dot:SetDimensions(3, 3)
                    P.set_rect_color(dot, { tc[1], tc[2], tc[3], 0.95 })
                    dot:SetHidden(false)
                end
            end
        end
    end

    local bm = dc.bm
    if bm then
        local x0 = math.floor((math.min(bm.t0, tspan) / tspan) * (w - 6) + 0.5)
        local x1 = math.floor((math.min(bm.t1, tspan) / tspan) * (w - 6) + 0.5)
        b.bloodiest:ClearAnchors()
        b.bloodiest:SetAnchor(TOPLEFT, b.chart, TOPLEFT, x0, 2)
        b.bloodiest:SetDimensions(math.max(2, x1 - x0), h - 4)
        b.bloodiest:SetHidden(false)
    end

    if m.killfeed then
        for _, k in ipairs(m.killfeed) do
            local x = math.floor((math.min(k.t or 0, tspan) / tspan) * (w - 6) + 0.5)
            if k.kind == "kill" or k.kind == "death" then
                local ic = b.skull_pool:acquire()
                local c = (k.kind == "kill") and K.COLOR.gold or K.COLOR.accent
                ic:SetColor(c[1], c[2], c[3], 1)
                ic:SetAnchor(BOTTOM, b.chart, BOTTOMLEFT, x, 5)
                ic:SetHidden(false)
            elseif k.kt then
                local tc = S.team_color(k.kt)
                local mark = b.dot_pool:acquire()
                mark:ClearAnchors()
                mark:SetAnchor(BOTTOMLEFT, b.chart, BOTTOMLEFT, x, -2)
                mark:SetDimensions(2, 5)
                P.set_rect_color(mark, { tc[1], tc[2], tc[3], 0.65 })
                mark:SetHidden(false)
            end
        end
    end

    if lanes then
        SEC.ribbon(b, lanes, ribbon_h, tspan, w, rib_off, gt)
    end
    if occ then
        SEC.occupation(b, occ, neutralPct, fstats, w)
    end
    if mom_h > 0 then
        SEC.momentum(b, m, tl, n, tspan, w, mom_h, mom_off, lead, tdm_line, dc.cmom, dc.cmomMax)
    end

    W.chart_state = { tl = tl, n = n, w = w, smax = smax, lanes = lanes, kf = m.killfeed }
end

local function chart_hover_poll()
    local b = W.battle
    local st = W.chart_state
    if not st or b.chart:IsHidden() then W._chart_hover_stop(); return end
    local A = BGMeter.zenimax.api
    if type(A.get_ui_mouse) ~= "function" then return end
    local mx = A.get_ui_mouse()
    local rel = mx - b.chart:GetLeft()
    local w = b.chart:GetWidth()
    if rel < 0 then rel = 0 elseif rel > w then rel = w end

    local tl, n = st.tl, st.n
    local tspan = math.max(1, tl.t[n] or 1)
    local want_t = (rel / math.max(1, w - 6)) * tspan
    local idx = 1
    for i = 1, n do
        if tl.t[i] <= want_t then idx = i else break end
    end

    local x = math.floor((tl.t[idx] / tspan) * (w - 6) + 0.5)
    b.cursor:ClearAnchors()
    b.cursor:SetAnchor(TOPLEFT, b.chart, TOPLEFT, x, 2)
    b.cursor:SetHidden(false)

    local parts = { "team score  ·  t " .. F.duration(tl.t[idx]) }
    local series = { tl.s1, tl.s2, tl.s3 }
    for s = 1, 3 do
        local team = tl.teams and tl.teams[s]
        if team and st.smax[s] > 0 then
            local tc = S.team_color(team)
            parts[#parts + 1] = string.format("|c%s%s  %s|r",
                hexc(tc), team_name(team), F.commas((series[s] and series[s][idx]) or 0))
        end
    end
    if st.lanes then
        for _, lane in ipairs(st.lanes) do
            local own, hit = 0, nil
            for _, seg in ipairs(lane.segs) do
                if want_t >= seg.t0 and want_t < seg.t1 then
                    own, hit = seg.own, seg
                    break
                end
            end
            local label = (hit and hit.name) or lane_label(lane)
            if own ~= 0 then
                local tc = S.team_color(own)
                parts[#parts + 1] = string.format("|c%s%s  %s|r",
                    hexc(tc), label, team_name(own))
            elseif hit or not lane.covered then
                parts[#parts + 1] = string.format("|c8c8c95%s  neutral|r", label)
            end
        end
    end

    if st.kf then
        local shown, extra = 0, 0
        for _, k in ipairs(st.kf) do
            if k.t and math.abs(k.t - want_t) <= 8000 then
                if shown >= 4 then
                    extra = extra + 1
                elseif k.kn and k.dn then
                    local tc = S.team_color(k.kt)
                    parts[#parts + 1] = string.format("|c%s%s|r killed %s  @ %s",
                        hexc(tc), k.kn, k.dn, F.duration(k.t))
                    shown = shown + 1
                elseif k.kind then
                    parts[#parts + 1] = string.format("%s @ %s",
                        k.kind == "kill" and "your kill" or "your death", F.duration(k.t))
                    shown = shown + 1
                end
            end
        end
        if extra > 0 then
            parts[#parts + 1] = string.format("+%d more kills here", extra)
        end
    end

    if ZO_Tooltips_ShowTextTooltip then
        ZO_Tooltips_ShowTextTooltip(b.chart, TOP, table.concat(parts, "\n"))
    end
end

function W._chart_hover_start()
    if not W.chart_state then return end
    BGMeter.zenimax.events.register_update("BGMeterChartHover", 100, chart_hover_poll)
end

function W._chart_hover_stop()
    BGMeter.zenimax.events.unregister_update("BGMeterChartHover")
    if W.battle and W.battle.cursor then W.battle.cursor:SetHidden(true) end
    if ZO_Tooltips_HideTextTooltip then ZO_Tooltips_HideTextTooltip() end
end

local function ensure_duel_icons(b)
    if b.nemesisIcon then return end
    b.nemesisIcon = P.icon(b.container, "EsoUI/Art/DeathRecap/deathRecap_killingBlow_icon.dds")
    b.nemesisIcon:SetDimensions(18, 18)
    b.nemesisIcon:SetAnchor(LEFT, b.headers.name, RIGHT, 12, -1)
    S.color(b.nemesisIcon, K.COLOR.accent)
    b.nemesisIcon:SetHidden(true)
    b.nemesisHit = hit_proxy(b.nemesisIcon)
    W.tip_static(b.nemesisHit, "")

    b.preyIcon = P.icon(b.container, "EsoUI/Art/HUD/HUD_Countdown_Badge_Dueling.dds")
    b.preyIcon:SetDimensions(18, 18)
    b.preyIcon:SetAnchor(LEFT, b.nemesisIcon, RIGHT, 8, 0)
    S.color(b.preyIcon, K.COLOR.gold)
    b.preyIcon:SetHidden(true)
    b.preyHit = hit_proxy(b.preyIcon)
    W.tip_static(b.preyHit, "")
end

function SEC.duels(m)
    local b = W.battle
    ensure_duel_icons(b)
    local d = m and BGMeter.Match.duels(m)
    if d and d.nemesis then
        b.nemesisIcon:SetHidden(false)
        b.nemesisHit:SetHidden(false)
        W.tips[b.nemesisHit] = string.format("Nemesis: %s\nKilled you %d time%s this match",
            d.nemesis.name, d.nemesis.count, d.nemesis.count == 1 and "" or "s")
    else
        b.nemesisIcon:SetHidden(true)
        b.nemesisHit:SetHidden(true)
        W.tips[b.nemesisHit] = nil
    end
    if d and d.prey then
        b.preyIcon:SetHidden(false)
        b.preyHit:SetHidden(false)
        W.tips[b.preyHit] = string.format("Prey: %s\nYou killed them %d time%s this match",
            d.prey.name, d.prey.count, d.prey.count == 1 and "" or "s")
    else
        b.preyIcon:SetHidden(true)
        b.preyHit:SetHidden(true)
        W.tips[b.preyHit] = nil
    end
end
