BGMeter = BGMeter or {}
local BGMeter = BGMeter

local U = BGMeter.UI._win
local W = U.W
local set_text, mk_button = U.set_text, U.mk_button
local TX = U.TX

local K = BGMeter.Constants
local L = BGMeter.Constants.LAYOUT
local F = BGMeter.Format
local P = BGMeter.Plot.primitives
local S = BGMeter.Plot.style
local Prefs = BGMeter.Prefs
local Sound = BGMeter.Sound

local M = {}

local LAUNCHER_ICON = "bgmeter/assets/launcher.dds"
local LAUNCHER_IDLE = 0.90

local MENU_ART = "esoui/art/loadingscreens/loadscreen_battleground_ularra_01.dds"
local MENU_ART_ALPHA = 0.30

local MODE_SHORT = {
    deathmatch = "DM", domination = "DOM", crazy_king = "CK",
    king_of_the_hill = "KOTH", capture_the_flag = "CTF", murderball = "BALL",
}

local MENU_W = 388
local MENU_H = 530
local ROW_H = 28
local HEAD_H = 46
local PANEL_H = 128
local QUEUE_H = 36
local FOOT_H = 34
local INSET_PAD = 20
local MIN_H, MAX_AUTO_H = 390, 764

local TELVAR = CURT_TELVAR_STONES

local built = false
local launcher = nil
local panel = nil
local rows = {}
local offset = 0
local on_hud = true
local reopen_after_report = false

local function safe(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b = pcall(fn, ...)
    if not ok then return nil end
    return a, b
end

local function clean(s)
    if not s or s == "" then return nil end
    return (tostring(s):gsub("%^.*$", ""))
end

local function sv_launcher()
    local sv = BGMeter.zenimax.savedvars.get()
    if not sv then return { x = 0, y = 0 } end
    sv.launcher = sv.launcher or { x = 0, y = 0 }
    return sv.launcher
end

local function sv_menu()
    local sv = BGMeter.zenimax.savedvars.get()
    if not sv then return { x = 0, y = 0, w = 0, h = 0 } end
    sv.menu = sv.menu or { x = 0, y = 0, w = 0, h = 0 }
    return sv.menu
end

local function ago_label(capturedAt)
    local A = BGMeter.zenimax.api
    local now = (type(A.get_timestamp) == "function") and A.get_timestamp() or nil
    if not capturedAt or not now or now <= capturedAt then return "" end
    local s = now - capturedAt
    if s < 3600 then return math.floor(s / 60) .. "m ago" end
    if s < 86400 then return math.floor(s / 3600) .. "h ago" end
    return math.floor(s / 86400) .. "d ago"
end

local function result_color(res)
    if res == "WIN" then return K.COLOR.heal end
    if res == "LOSS" then return K.COLOR.accent end
    if res == "TIE" then return K.COLOR.gold end
    return K.COLOR.text_dim
end

local function mode_tag(m)
    local C = BGMeter.zenimax.constants
    local gt = C.GAME_TYPE_LABEL[m.gameType]
    local tag = MODE_SHORT[gt] or "?"
    if m.teamSize then tag = tag .. "  " .. m.teamSize .. "v" .. m.teamSize end
    return tag
end

local art_tries = 0

local function apply_art_cover()
    if not built then return end
    local art = panel.art
    local w = panel.win:GetWidth() - 4
    local h = panel.win:GetHeight() - 4
    if w <= 0 or h <= 0 then return end
    local tw, th
    pcall(function() tw, th = art:GetTextureFileDimensions() end)
    if not tw or tw <= 0 or not th or th <= 0 then
        art:SetTextureCoords(0, 1, 0, 1)
        if art_tries < 3 and type(zo_callLater) == "function" then
            art_tries = art_tries + 1
            zo_callLater(apply_art_cover, 350)
        end
        return
    end
    art_tries = 0
    local ca = w / h
    local ta = tw / th
    if ta > ca then
        local uw = ca / ta
        local u0 = (1 - uw) / 2
        art:SetTextureCoords(u0, u0 + uw, 0, 1)
    else
        local vh = ta / ca
        local v0 = (1 - vh) / 2
        art:SetTextureCoords(0, 1, v0, v0 + vh)
    end
end

local function auto_height()
    local mg = sv_menu()
    if (mg.h or 0) > 0 then return end
    local count = BGMeter.History.count()
    local want = HEAD_H + PANEL_H + QUEUE_H + FOOT_H + 18 + math.max(count, 1) * (ROW_H + 2)
    panel.win:SetHeight(math.max(MIN_H, math.min(want, MAX_AUTO_H)))
end

local function refresh_panel()
    local A = BGMeter.zenimax.api
    local C = BGMeter.zenimax.constants

    local st = panel.stats.ava
    local rank = safe(A.get_ava_rank)
    if rank and rank > 0 then
        st.c:SetHidden(false)
        local gender = safe(A.get_gender) or 1
        local rname = clean(safe(A.get_ava_rank_name, gender, rank)) or "?"
        if st.icon then st.icon:SetTexture(safe(A.get_ava_rank_icon, rank) or "") end
        set_text(st.label, string.format("%s  %d", rname, rank))
        local pts = safe(A.get_ava_rank_points) or 0
        local base = safe(A.get_ava_points_needed, rank) or 0
        local nextNeed = safe(A.get_ava_points_needed, rank + 1)
        if nextNeed and nextNeed > pts then
            st.tip = string.format("Alliance War rank %d\n%s AP to the next rank", rank, F.commas(nextNeed - pts))
        else
            st.tip = string.format("Alliance War rank %d", rank)
        end
        if st.bar then
            if nextNeed and nextNeed > base then
                local pct = math.max(0, math.min(1, (pts - base) / (nextNeed - base)))
                U.inset_bar_set(st.bar, pct, K.COLOR.gold, st.barW)
                st.bar.container:SetHidden(false)
            else
                st.bar.container:SetHidden(true)
            end
        end
    else
        st.c:SetHidden(true)
    end

    st = panel.stats.vet
    local snap = BGMeter.Veterancy and BGMeter.Veterancy.snapshot()
    if snap and snap.rank then
        st.c:SetHidden(false)
        if st.icon then
            st.icon:SetTexture(safe(A.get_veterancy_rank_icon, snap.rank, snap.seasonId)
                or snap.rankIcon or "")
        end
        set_text(st.label, string.format("%s  %d", clean(snap.rankTitle) or "Veterancy", snap.rank))
        local season = clean(snap.seasonName)
        local seasonLine = season and ("\n" .. season) or ""
        if snap.tierTotal and snap.tierTotal > 0 then
            st.tip = string.format("Veterancy rank %d\n%s / %s to the next rank%s",
                snap.rank, F.commas(snap.progressToNext or 0), F.commas(snap.tierTotal), seasonLine)
        else
            st.tip = string.format("Veterancy rank %d%s", snap.rank, seasonLine)
        end
        if st.bar then
            if snap.percent then
                local pct = math.max(0, math.min(1, snap.percent))
                U.inset_bar_set(st.bar, pct, K.COLOR.veterancy, st.barW)
                st.bar.container:SetHidden(false)
            else
                st.bar.container:SetHidden(true)
            end
        end
    else
        st.c:SetHidden(true)
    end

    st = panel.stats.stand
    local function trophy_tier(rank)
        if rank == 1 then return { 1.00, 0.97, 0.82 }, 0.75, "Champion!" end
        if rank <= 10 then return { 1.00, 0.55, 0.15 }, 0.60, "Mythic!" end
        if rank <= 50 then return { 1.00, 0.84, 0.30 }, 0.50, "Legendary" end
        return { 0.72, 0.53, 0.98 }, 0.42, "Epic"
    end
    local sv = BGMeter.zenimax.savedvars.get()
    local standing = sv and sv.standing
    if M._demo_rank then standing = { rank = M._demo_rank, score = 123456 } end
    st.c:SetHidden(false)
    if standing and (standing.rank or 0) > 0 then
        local top = standing.rank <= 100
        if st.icon then
            st.icon:SetTexture(top and "EsoUI/Art/Inventory/inventory_tabIcon_trophy_up.dds"
                or "EsoUI/Art/Journal/journal_tabIcon_leaderboard_up.dds")
            local tierTag = ""
            if top then
                local col, glowA, word = trophy_tier(standing.rank)
                st.icon:SetColor(col[1], col[2], col[3], 1)
                if not st.glow then
                    st.glow = P.icon(st.c, "bgmeter/assets/glow.dds")
                    st.glow:SetAnchor(CENTER, st.icon, CENTER, 0, 0)
                    st.glow:SetDimensions(64, 64)
                    if st.glow.SetBlendMode then st.glow:SetBlendMode(TEX_BLEND_MODE_ADD) end
                    if st.glow.SetDrawLevel then st.glow:SetDrawLevel(1) end
                    if st.icon.SetDrawLevel then st.icon:SetDrawLevel(2) end
                end
                st.glow:SetColor(col[1], col[2], col[3], glowA)
                st.glow:SetHidden(false)
                tierTag = string.format("  ·  |c%02X%02X%02X%s|r",
                    math.floor(col[1] * 255 + 0.5), math.floor(col[2] * 255 + 0.5),
                    math.floor(col[3] * 255 + 0.5), word)
            else
                st.icon:SetColor(1, 1, 1, 1)
                if st.glow then st.glow:SetHidden(true) end
            end
            st.tierTag = tierTag
        end
        set_text(st.label, "#" .. F.commas(standing.rank) .. (st.tierTag or ""))
        S.color(st.label, K.COLOR.gold)
        st.tip = string.format("Competitive standing\nrating %s", F.commas(standing.score or 0))
    else
        if st.icon then
            st.icon:SetTexture("EsoUI/Art/Journal/journal_tabIcon_leaderboard_up.dds")
            st.icon:SetColor(1, 1, 1, 1)
            if st.glow then st.glow:SetHidden(true) end
        end
        set_text(st.label, "unranked")
        S.color(st.label, K.COLOR.text_dim)
        if standing and (standing.score or 0) > 0 then
            st.tip = string.format("Competitive standing\nrating %s", F.commas(standing.score))
        else
            st.tip = "Competitive standing\nplay a ranked battleground to appear"
        end
    end

    st = panel.stats.ap
    st.c:SetHidden(false)
    if st.icon then st.icon:SetTexture(safe(A.get_currency_icon, C.CURT_ALLIANCE_POINTS) or "") end
    set_text(st.label, F.commas(safe(A.get_alliance_points) or 0))
    st.tip = "Alliance Points"

    st = panel.stats.telvar
    if TELVAR then
        st.c:SetHidden(false)
        if st.icon then st.icon:SetTexture(safe(A.get_currency_icon, TELVAR) or "") end
        set_text(st.label, F.commas(safe(A.get_currency, TELVAR, C.CURRENCY_LOCATION_CHARACTER) or 0))
        st.tip = "Tel Var Stones"
    else
        st.c:SetHidden(true)
    end

    st = panel.stats.session
    local sess = BGMeter.Session
    if sess and sess.matches > 0 then
        if (sess.streak or 0) >= 2 then
            set_text(st.label, string.format("%dW-%dL  ·  %dx streak", sess.wins, sess.losses, sess.streak))
        else
            set_text(st.label, string.format("%dW-%dL tonight", sess.wins, sess.losses))
        end
        local col = K.COLOR.text_dim
        if sess.wins > sess.losses then col = K.COLOR.heal
        elseif sess.losses > sess.wins then col = K.COLOR.accent end
        S.color(st.label, col)
        st.tip = string.format("This play session\n%d battlegrounds%s\n%s AP  ·  %s XP earned",
            sess.matches,
            (sess.streak or 0) >= 2 and string.format("\n%d wins in a row", sess.streak) or "",
            F.commas(sess.ap), F.commas(sess.xp))
    else
        set_text(st.label, "no battles yet")
        S.color(st.label, K.COLOR.text_dim)
        st.tip = "This play session (since login)"
    end
    st.c:SetHidden(false)
end

local function make_row(i)
    local r = {}
    r.container = BGMeter.zenimax.ui.create_control(nil, panel.inset, CT_CONTROL)
    r.container:SetMouseEnabled(true)

    r.base, r.highlight = U.row_chrome(r.container)

    r.pip = P.rect(r.container, K.COLOR.text_dim)
    r.pip:SetDimensions(3, ROW_H - 12)
    r.pip:SetAnchor(LEFT, r.container, LEFT, 4, 0)

    r.name = P.label(r.container, S.FONT.row, K.COLOR.text)
    r.name:SetAnchor(LEFT, r.container, LEFT, 14, 0)
    r.name:SetHeight(ROW_H)

    if r.name.SetMaxLineCount then r.name:SetMaxLineCount(1) end
    if TEXT_WRAP_MODE_ELLIPSIS and r.name.SetWrapMode then
        r.name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end

    r.kda = P.label(r.container, S.FONT.small, K.COLOR.text_dim)
    r.kda:SetAnchor(RIGHT, r.container, RIGHT, -154, 0)
    r.kda:SetDimensions(60, ROW_H)
    r.kda:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    U.clamp_line(r.kda)

    r.mode = P.label(r.container, S.FONT.small, K.COLOR.text_dim)
    r.mode:SetAnchor(RIGHT, r.container, RIGHT, -88, 0)
    r.mode:SetDimensions(62, ROW_H)
    r.mode:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    U.clamp_line(r.mode)

    r.ago = P.label(r.container, S.FONT.small, K.COLOR.text_dim)
    r.ago:SetAnchor(RIGHT, r.container, RIGHT, -26, 0)
    r.ago:SetDimensions(56, ROW_H)
    r.ago:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    U.clamp_line(r.ago)

    r.del = mk_button(r.container, TX.close, 14, function()
        M.delete(r.index)
    end, "Delete this match")
    r.del:SetAnchor(RIGHT, r.container, RIGHT, -6, 0)

    r.container:SetHandler("OnMouseEnter", function()
        r.highlight:SetHidden(false)
        if r.tip and ZO_Tooltips_ShowTextTooltip then
            ZO_Tooltips_ShowTextTooltip(r.container, BOTTOM, r.tip)
        end
    end)
    r.container:SetHandler("OnMouseExit", function()
        r.highlight:SetHidden(true)
        if ZO_Tooltips_HideTextTooltip then ZO_Tooltips_HideTextTooltip() end
    end)
    r.container:SetHandler("OnMouseUp", function(_, _, upInside)
        if upInside and r.index then
            Sound.play("match")
            reopen_after_report = true
            M.hide_menu(true)
            BGMeter.UI.window.show_match(r.index)
        end
    end)
    return r
end

local function build()
    if built then return end

    local g = sv_launcher()
    local LSZ = 56
    local win = BGMeter.zenimax.ui.wm:CreateTopLevelWindow("BGMeterLauncher")
    win:SetDimensions(LSZ, LSZ)
    win:SetMouseEnabled(true)
    win:SetMovable(true)
    win:SetClampedToScreen(true)
    win:SetHidden(true)
    if g.x == 0 and g.y == 0 then
        win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 24, 240)
    else
        win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, g.x, g.y)
    end
    win:SetHandler("OnMoveStop", function()
        g = sv_launcher()
        g.x, g.y = win:GetLeft(), win:GetTop()
    end)
    win:SetHandler("OnMouseUp", function(_, _, upInside)
        if upInside then M.toggle() end
    end)
    launcher = { win = win }

    launcher.pip = P.icon(win, "EsoUI/Art/Inventory/newItem_icon.dds")
    launcher.pip:SetDimensions(18, 18)
    launcher.pip:SetAnchor(TOPRIGHT, win, TOPRIGHT, 5, -5)
    launcher.pip:SetHidden(true)

    launcher.glowFx = P.icon(win, "bgmeter/assets/glow.dds")
    launcher.glowFx:SetAnchor(CENTER, win, CENTER, 0, 0)
    launcher.glowFx:SetDimensions(LSZ * 2.2, LSZ * 2.2)
    if launcher.glowFx.SetBlendMode then launcher.glowFx:SetBlendMode(TEX_BLEND_MODE_ADD) end
    launcher.glowFx:SetHidden(true)

    launcher.glow = P.icon(win, LAUNCHER_ICON)
    launcher.glow:SetAnchor(CENTER, win, CENTER, 0, 0)
    launcher.glow:SetDimensions(LSZ + 12, LSZ + 12)
    launcher.glow:SetHidden(true)

    launcher.icon = P.icon(win, LAUNCHER_ICON)
    launcher.icon:SetAnchorFill(win)
    launcher.icon:SetColor(1, 1, 1, LAUNCHER_IDLE)

    local GLOW_COLORS = { K.COLOR.team.fire, K.COLOR.team.storm, K.COLOR.team.pit }
    local GLOW_CYCLE_MS = 2100
    local Anim = BGMeter.Anim

    local function glow_tick(t)
        if not launcher.hovered then return end
        local phase = t * #GLOW_COLORS
        local i = math.min(math.floor(phase) + 1, #GLOW_COLORS)
        local j = (i % #GLOW_COLORS) + 1
        local f = phase - (i - 1)
        local a, b2 = GLOW_COLORS[i], GLOW_COLORS[j]
        local r = a[1] + (b2[1] - a[1]) * f
        local g = a[2] + (b2[2] - a[2]) * f
        local bch = a[3] + (b2[3] - a[3]) * f
        launcher.glow:SetColor(r, g, bch, 0.65)
        local pulse = 0.55 + 0.35 * (0.5 + 0.5 * math.sin(t * math.pi * 4))
        launcher.glowFx:SetColor(r, g, bch, pulse)
    end

    local function glow_loop()
        if not launcher.hovered then return end
        Anim.start(GLOW_CYCLE_MS, glow_tick, glow_loop, function(t) return t end)
    end

    win:SetHandler("OnMouseEnter", function()
        launcher.hovered = true
        launcher.icon:SetColor(1, 1, 1, 1)
        launcher.glow:SetHidden(false)
        launcher.glowFx:SetHidden(false)
        glow_loop()
    end)
    win:SetHandler("OnMouseExit", function()
        launcher.hovered = false
        launcher.glow:SetHidden(true)
        launcher.glowFx:SetHidden(true)
        launcher.icon:SetColor(1, 1, 1, LAUNCHER_IDLE)
    end)

    local mg = sv_menu()
    local pw = BGMeter.zenimax.ui.wm:CreateTopLevelWindow("BGMeterMenu")
    pw:SetDimensions((mg.w and mg.w > 0) and mg.w or MENU_W, (mg.h and mg.h > 0) and mg.h or MENU_H)
    pw:SetMouseEnabled(true)
    pw:SetMovable(true)
    pw:SetClampedToScreen(true)
    pw:SetHidden(true)
    pw:SetDrawTier(DT_HIGH)
    pw:SetResizeHandleSize(L.resize_h)
    pw:SetDimensionConstraints(384, 280, 560, 780)
    pw:SetHandler("OnMoveStop", function()
        mg = sv_menu()
        mg.x, mg.y = pw:GetLeft(), pw:GetTop()
    end)
    pw:SetHandler("OnResizeStop", function()
        mg = sv_menu()
        mg.w, mg.h = pw:GetWidth(), pw:GetHeight()
        apply_art_cover()
        M.refresh()
    end)
    pw:SetHandler("OnMouseWheel", function(_, delta)
        local count = BGMeter.History.count()
        local maxOff = math.max(0, count - (panel.vis or 1))
        local want = math.max(0, math.min(offset - delta, maxOff))
        if want ~= offset then
            offset = want
            M.refresh()
        end
    end)
    panel = { win = pw }

    local bg = P.rect(pw, { K.COLOR.bg[1], K.COLOR.bg[2], K.COLOR.bg[3], 0.97 })
    bg:SetAnchorFill(pw)

    panel.art = P.icon(pw, MENU_ART)
    panel.art:SetAnchor(TOPLEFT, pw, TOPLEFT, 2, 2)
    panel.art:SetAnchor(BOTTOMRIGHT, pw, BOTTOMRIGHT, -2, -2)
    panel.art:SetColor(1, 1, 1, MENU_ART_ALPHA)

    P.frame(pw):SetAnchorFill(pw)

    local strip = P.rect(pw, K.COLOR.accent)
    strip:SetAnchor(TOPLEFT, pw, TOPLEFT, 6, 6)
    strip:SetAnchor(TOPRIGHT, pw, TOPRIGHT, -6, 6)
    strip:SetHeight(3)

    panel.logo = P.icon(pw, K.LOGO)
    panel.logo:SetDimensions(20, 20)
    panel.logo:SetAnchor(TOPLEFT, pw, TOPLEFT, 16, 13)

    panel.title = P.label(pw, S.FONT.title, K.COLOR.text)
    panel.title:SetText(K.TITLE .. "  ·  Registry")
    panel.title:SetAnchor(LEFT, panel.logo, RIGHT, 8, 0)

    panel.close = mk_button(pw, TX.close, 20, function() M.hide_menu() end, "Close")
    panel.close:SetAnchor(TOPRIGHT, pw, TOPRIGHT, -14, 15)

    panel.gear = mk_button(pw, TX.gear, 22, function() W.toggle_settings() end, "Settings")
    panel.gear:SetAnchor(RIGHT, panel.close, LEFT, -8, 0)

    local function make_stat(rowi, right, withIcon, withBar)
        local c = BGMeter.zenimax.ui.create_control(nil, pw, CT_CONTROL)
        local rowH = right and 28 or 38
        local iconS = right and 26 or 38
        local pad = right and 6 or 9
        c:SetHeight(rowH)
        c:SetMouseEnabled(true)
        local y = HEAD_H + (rowi - 1) * (right and 30 or 40)
        if right then
            c:SetAnchor(TOPRIGHT, pw, TOPRIGHT, -(INSET_PAD + 2), y)
            c:SetWidth(126)
        else
            c:SetAnchor(TOPLEFT, pw, TOPLEFT, INSET_PAD + 2, y)
            c:SetWidth(200)
        end
        local st = { c = c }
        if withIcon then
            st.icon = P.icon(c)
            st.icon:SetDimensions(iconS, iconS)
            st.icon:SetAnchor(LEFT, c, LEFT, 0, 0)
        end
        local textX = withIcon and (iconS + pad) or 2
        st.label = P.label(c, right and S.FONT.small or S.FONT.row, K.COLOR.text)
        U.clamp_line(st.label)
        if withBar then
            st.label:SetAnchor(TOPLEFT, c, TOPLEFT, textX, 3)
            st.label:SetAnchor(TOPRIGHT, c, TOPRIGHT, 0, 3)
            st.label:SetHeight(20)
            st.bar = U.inset_bar(c)
            st.bar.container:SetAnchor(BOTTOMLEFT, c, BOTTOMLEFT, textX, -3)
            st.bar.container:SetAnchor(BOTTOMRIGHT, c, BOTTOMRIGHT, 0, -3)
            st.bar.container:SetHeight(9)
            st.barW = 200 - textX
        else
            st.label:SetAnchor(LEFT, c, LEFT, textX, 0)
            st.label:SetAnchor(RIGHT, c, RIGHT, 0, 0)
            st.label:SetHeight(rowH)
        end
        c:SetHandler("OnMouseEnter", function()
            if st.tip and ZO_Tooltips_ShowTextTooltip then ZO_Tooltips_ShowTextTooltip(c, BOTTOM, st.tip) end
        end)
        c:SetHandler("OnMouseExit", function()
            if ZO_Tooltips_HideTextTooltip then ZO_Tooltips_HideTextTooltip() end
        end)
        return st
    end

    panel.stats = {
        ava     = make_stat(1, false, true, true),
        vet     = make_stat(2, false, true, true),
        stand   = make_stat(3, false, true),
        ap      = make_stat(1, true, true),
        telvar  = make_stat(2, true, true),
        session = make_stat(3, true, false),
    }
    for _, key in ipairs({ "ap", "telvar" }) do
        local lbl = panel.stats[key].label
        if lbl.SetFont then lbl:SetFont(S.FONT.row) end
    end

    panel.inset = BGMeter.zenimax.ui.create_control(nil, pw, CT_CONTROL)
    panel.inset:SetAnchor(TOPLEFT, pw, TOPLEFT, INSET_PAD, HEAD_H + PANEL_H)
    panel.inset:SetAnchor(BOTTOMRIGHT, pw, BOTTOMRIGHT, -INSET_PAD, -(FOOT_H + QUEUE_H))
    panel.inset:SetMouseEnabled(false)

    local qc = BGMeter.zenimax.ui.create_from_virtual(nil, pw, "ZO_ComboBox")
    qc:SetDimensions(168, 30)
    qc:SetAnchor(BOTTOMLEFT, pw, BOTTOMLEFT, INSET_PAD, -(FOOT_H + 3))
    panel.queue = { combo_c = qc, sel = 1 }
    if type(ZO_ComboBox_ObjectFromContainer) == "function" then
        local ok, obj = pcall(ZO_ComboBox_ObjectFromContainer, qc)
        if ok then panel.queue.combo = obj end
    end
    if panel.queue.combo and panel.queue.combo.SetSortsItems then
        panel.queue.combo:SetSortsItems(false)
    end

    panel.queue.btn = BGMeter.zenimax.ui.create_from_virtual(nil, pw, "ZO_DefaultButton")
    panel.queue.btn:SetDimensions(92, 28)
    panel.queue.btn:SetAnchor(LEFT, qc, RIGHT, 4, 0)
    panel.queue.btn:SetText("Queue")
    panel.queue.btn:SetHandler("OnClicked", function() M.queue_click() end)

    panel.queue.status = P.label(pw, S.FONT.small, K.COLOR.text_dim)
    panel.queue.status:SetAnchor(LEFT, panel.queue.btn, RIGHT, 8, 0)
    panel.queue.status:SetHeight(28)
    panel.queue.statusW = 90
    if panel.queue.status.SetMaxLineCount then panel.queue.status:SetMaxLineCount(1) end
    if TEXT_WRAP_MODE_ELLIPSIS and panel.queue.status.SetWrapMode then
        panel.queue.status:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end

    panel.insetBg = P.rect(panel.inset, { 0, 0, 0, 0.45 })
    panel.insetBg:SetAnchorFill(panel.inset)
    P.frame(panel.inset):SetAnchorFill(panel.inset)

    panel.empty = P.label(panel.inset, S.FONT.small, K.COLOR.text_dim)
    panel.empty:SetText("no battlegrounds recorded yet\nqueue up below to record your first battle")
    panel.empty:SetAnchor(CENTER, panel.inset, CENTER, 0, 0)
    panel.empty:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    panel.empty:SetHidden(true)

    panel.footer = P.label(pw, S.FONT.small, K.COLOR.text_dim)
    panel.footer:SetAnchor(BOTTOMLEFT, pw, BOTTOMLEFT, 12, -9)
    panel.footer:SetAnchor(BOTTOMRIGHT, pw, BOTTOMRIGHT, -12, -9)
    panel.footer:SetHeight(14)
    panel.footer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    U.clamp_line(panel.footer)

    built = true
end

local QUEUE_TICKER = "BGMeterQueueTick"

local function update_footer(count, vis)
    local Cap = BGMeter.Capture
    if Cap and Cap.is_active and Cap.is_active() then
        local nm, el = Cap.live()
        set_text(panel.footer, string.format("|cf2cc55recording %s  ·  %s|r",
            clean(nm) or "battleground", F.duration(el or 0)))
        return
    end
    count = count or BGMeter.History.count()
    vis = vis or math.min(count, panel.vis or count)
    if panel.vis and count > panel.vis then
        set_text(panel.footer, string.format("%d-%d of %d  ·  scroll for more", offset + 1, offset + vis, count))
    else
        set_text(panel.footer, count > 0 and (count .. (count == 1 and " battleground" or " battlegrounds")) or "")
    end
end

local function safe_m(obj, method, ...)
    if not obj or type(obj[method]) ~= "function" then return nil end
    local ok, a = pcall(obj[method], obj, ...)
    if not ok then return nil end
    return a
end

local function push_set(q, id, name)
    local A = BGMeter.zenimax.api
    if not id then return end
    name = clean(name) or clean(safe(A.lfg_set_info, id)) or ("Set " .. id)
    q.sets[#q.sets + 1] = { id = id, name = name }
end

local function collect_from_manager(q, types)
    local mgr = ZO_ACTIVITY_FINDER_ROOT_MANAGER
    if not mgr or type(mgr.GetLocationsData) ~= "function" then return false end
    for _, act in ipairs(types) do
        local ok, locations = pcall(mgr.GetLocationsData, mgr, act)
        if ok and type(locations) == "table" and #locations > 0 then
            for _, loc in ipairs(locations) do
                if safe_m(loc, "IsSetEntryType")
                    and not safe_m(loc, "IsLocked")
                    and not safe_m(loc, "IsDisabled") then
                    push_set(q, safe_m(loc, "GetId"), safe_m(loc, "GetRawName"))
                end
            end
            if #q.sets > 0 then
                q.act = act
                BGMeter.Log.debug("queue sets via manager: %d playable of %d (activity %s)",
                    #q.sets, #locations, tostring(act))
                return true
            end
        end
    end
    return false
end

local function populate_queue_sets()
    local A = BGMeter.zenimax.api
    local C = BGMeter.zenimax.constants
    local q = panel.queue
    q.sets = {}
    q.act = nil
    local types = { C.LFG_ACTIVITY_BG_CHAMPION, C.LFG_ACTIVITY_BG_NON_CHAMPION, C.LFG_ACTIVITY_BG_LOW_LEVEL }
    if not collect_from_manager(q, types) then
        for _, act in ipairs(types) do
            local n = safe(A.lfg_num_sets, act) or 0
            BGMeter.Log.debug("queue sets: activity=%s count=%s", tostring(act), tostring(n))
            if n > 0 then
                q.act = act
                for i = 1, n do
                    local id = safe(A.lfg_set_id, act, i)
                    if id and not safe(A.lfg_set_disabled, id) then
                        push_set(q, id, nil)
                    end
                end
                BGMeter.Log.debug("queue sets: %d enabled of %d", #q.sets, n)
                break
            end
        end
    end
    if not q.sets[q.sel] then q.sel = 1 end
    if q.combo and q.combo.ClearItems then
        q.combo:ClearItems()
        for i, s in ipairs(q.sets) do
            q.combo:AddItem(q.combo:CreateItemEntry(s.name, function() q.sel = i end))
        end
        if q.sets[q.sel] and q.combo.SetSelectedItemText then
            q.combo:SetSelectedItemText(q.sets[q.sel].name)
        end
    end
end

local bg_types
local function is_bg_activity(activityId)
    local A = BGMeter.zenimax.api
    local C = BGMeter.zenimax.constants
    if not bg_types then
        bg_types = {}
        for _, t in ipairs({ C.LFG_ACTIVITY_BG_CHAMPION, C.LFG_ACTIVITY_BG_NON_CHAMPION, C.LFG_ACTIVITY_BG_LOW_LEVEL }) do
            if t ~= nil then bg_types[t] = true end
        end
    end
    if not activityId or activityId <= 0 then return false end
    return bg_types[safe(A.lfg_activity_type, activityId)] == true
end

local function bg_searching()
    local A = BGMeter.zenimax.api
    if not safe(A.lfg_searching) then return false end
    local n = safe(A.lfg_num_requests)
    if not n or type(A.lfg_request_ids) ~= "function" then return true end
    for i = 1, n do
        local ok, aid, sid = pcall(A.lfg_request_ids, i)
        if ok then
            if sid and sid ~= 0 and (safe(A.lfg_set_activity_count, sid) or 0) > 0 then
                aid = safe(A.lfg_set_activity_id, sid, 1)
            end
            if is_bg_activity(aid) then return true end
        end
    end
    return false
end

local function in_lfg_dungeon()
    local A = BGMeter.zenimax.api
    local curId = safe(A.lfg_current_activity) or 0
    return curId > 0 and not is_bg_activity(curId)
end

local function queue_ticker_sync(searching)
    local E = BGMeter.zenimax.events
    local want = searching and built and not panel.win:IsHidden()
    if want and not panel.queue.ticking then
        E.register_update(QUEUE_TICKER, 1000, function() M.update_queue() end)
        panel.queue.ticking = true
    elseif not want and panel.queue.ticking then
        E.unregister_update(QUEUE_TICKER)
        panel.queue.ticking = false
    end
end

function M.update_queue()
    if not built then return end
    local A = BGMeter.zenimax.api
    local C = BGMeter.zenimax.constants
    local q = panel.queue
    local anySearch = safe(A.lfg_searching) and true or false
    local searching = anySearch and bg_searching()
    local capturing = BGMeter.Capture and BGMeter.Capture.is_active and BGMeter.Capture.is_active() or false
    local inDungeon = in_lfg_dungeon()
    update_footer()
    local compact = (q.statusW or 200) < 110
    if q.btn.SetEnabled then
        q.btn:SetEnabled(searching or not (capturing or anySearch or inDungeon))
    end
    if capturing and not searching then
        q.btn:SetText("Queue")
        set_text(q.status, compact and "" or "in a battleground")
        S.color(q.status, K.COLOR.text_dim)
    elseif anySearch and not searching then
        q.btn:SetText("Queue")
        set_text(q.status, compact and "" or "in another queue")
        S.color(q.status, K.COLOR.text_dim)
    elseif inDungeon and not searching then
        q.btn:SetText("Queue")
        set_text(q.status, compact and "" or "in a dungeon")
        S.color(q.status, K.COLOR.text_dim)
    elseif searching then
        q.btn:SetText("Cancel")
        local startMs, etaMs = safe(A.lfg_times)
        local now = safe(A.now_ms) or 0
        local txt = compact and "..." or "in queue"
        if startMs and startMs > 0 and now > startMs then
            if compact then
                txt = F.duration(now - startMs)
            else
                txt = "in queue  " .. F.duration(now - startMs)
                if etaMs and etaMs > startMs then
                    txt = txt .. "  ·  eta ~" .. F.duration(etaMs - startMs)
                end
            end
        end
        set_text(q.status, txt)
        S.color(q.status, K.COLOR.gold)
    else
        q.btn:SetText("Queue")
        local cd = C.LFG_COOLDOWN_BATTLEGROUND_DESERTED_QUEUE
            and safe(A.lfg_cooldown, C.LFG_COOLDOWN_BATTLEGROUND_DESERTED_QUEUE) or 0
        if cd and cd > 0 then
            set_text(q.status, (compact and "" or "deserter  ") .. F.duration(cd * 1000))
            S.color(q.status, K.COLOR.accent)
        else
            set_text(q.status, "")
        end
    end
    queue_ticker_sync(searching or capturing)
end

function M.queue_click()
    if not built then return end
    local A = BGMeter.zenimax.api
    local C = BGMeter.zenimax.constants
    local q = panel.queue
    if safe(A.lfg_searching) then
        if bg_searching() then
            safe(A.lfg_cancel)
            Sound.play("nav")
            BGMeter.Log.debug("battleground queue cancelled")
            M.update_queue()
        end
        return
    end
    if (BGMeter.Capture and BGMeter.Capture.is_active()) or in_lfg_dungeon() then
        return
    end
    local flash
    do
        local s = q.sets and q.sets[q.sel]
        if not s then
            flash = "no queue entries available"
        else
            safe(A.lfg_clear_search)
            safe(A.lfg_add_set, s.id)
            local res = safe(A.lfg_start)
            Sound.play("nav")
            if C.ACTIVITY_QUEUE_RESULT_SUCCESS and res and res ~= C.ACTIVITY_QUEUE_RESULT_SUCCESS then
                flash = "queue rejected (" .. tostring(res) .. ")"
            else
                BGMeter.Log.debug("queued: %s", s.name)
            end
        end
    end
    M.update_queue()
    if flash then
        set_text(q.status, flash)
        S.color(q.status, K.COLOR.accent)
    end
end

function M.refresh()
    if not built or panel.win:IsHidden() then return end
    local H = BGMeter.History
    local count = H.count()

    refresh_panel()

    local w = panel.win:GetWidth()
    local h = panel.win:GetHeight()

    panel.queue.statusW = math.max(36, w - 2 * INSET_PAD - 168 - 4 - 92 - 8)
    panel.queue.status:SetWidth(panel.queue.statusW)
    local insetH = h - HEAD_H - PANEL_H - QUEUE_H - FOOT_H - 10
    panel.vis = math.max(1, math.floor(insetH / (ROW_H + 2)))

    local maxOff = math.max(0, count - panel.vis)
    if offset > maxOff then offset = maxOff end
    local vis = math.min(count - offset, panel.vis)

    local roww = w - 2 * INSET_PAD - 10
    panel.empty:SetHidden(count > 0)

    for i = 1, vis do
        local r = rows[i]
        if not r then
            r = make_row(i)
            rows[i] = r
        end
        local idx = offset + i
        local m = H.get(idx)
        r.index = idx
        r.container:ClearAnchors()
        r.container:SetAnchor(TOPLEFT, panel.inset, TOPLEFT, 5, 4 + (i - 1) * (ROW_H + 2))
        r.container:SetDimensions(roww, ROW_H)
        r.container:SetHidden(false)
        r.highlight:SetHidden(true)
        r.name:SetWidth(math.max(72, roww - 232))
        P.set_rect_color(r.pip, result_color(m.result))
        set_text(r.name, m.name or "Battleground")
        S.color(r.name, (BGMeter.UI.window.current() == idx and not BGMeter.UI.window.is_hidden()) and K.COLOR.you or K.COLOR.text)
        set_text(r.mode, mode_tag(m))
        set_text(r.ago, ago_label(m.capturedAt))
        local lr = BGMeter.Match.local_row(m)
        set_text(r.kda, lr and string.format("%d/%d/%d", lr.kills or 0, lr.deaths or 0, lr.assists or 0) or "")
        local score = m.result or ""
        if m.teams and #m.teams >= 2 then
            score = string.format("%s  %d - %d", m.result or "", m.teams[1].score or 0, m.teams[2].score or 0)
        end
        r.tip = string.format("%s\n%s%s", clean(m.name) or "Battleground", score,
            lr and string.format("\nyou  %d/%d/%d  ·  %s dmg  ·  %s heal",
                lr.kills or 0, lr.deaths or 0, lr.assists or 0,
                F.abbrev(lr.damage or 0), F.abbrev(lr.healing or 0)) or "")
    end
    for i = vis + 1, #rows do
        rows[i].container:SetHidden(true)
        rows[i].index = nil
    end

    update_footer(count, vis)
end

function M.delete(index)
    if not BGMeter.History.delete(index) then return end
    Sound.play("nav")
    W.on_history_changed(index)
    auto_height()
    apply_art_cover()
    M.refresh()
end

local DEMO_RANKS = { 96, 42, 7, 1 }
function M.demo_trophy()
    if not built then build() end
    local idx = M._demo_idx or 0
    idx = idx + 1
    if idx > #DEMO_RANKS then
        M._demo_idx, M._demo_rank = nil, nil
        BGMeter.Log.say("trophy demo OFF (real standing restored)")
    else
        M._demo_idx, M._demo_rank = idx, DEMO_RANKS[idx]
        BGMeter.Log.say("trophy demo: rank #%d", M._demo_rank)
    end
    if panel.win:IsHidden() then M.show_menu() else M.refresh() end
end

function M.show_menu()
    if not built then return end
    M.clear_unread()
    local mg = sv_menu()
    panel.win:ClearAnchors()
    if (mg.x or 0) ~= 0 or (mg.y or 0) ~= 0 then
        panel.win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mg.x, mg.y)
    else
        panel.win:SetAnchor(TOPLEFT, launcher.win, BOTTOMRIGHT, 2, 2)
    end
    panel.win:SetHidden(false)
    offset = 0
    auto_height()
    apply_art_cover()
    populate_queue_sets()
    M.update_queue()
    M.refresh()
    local A = BGMeter.zenimax.api
    local C = BGMeter.zenimax.constants
    safe(A.query_bg_leaderboard, C.BATTLEGROUND_LEADERBOARD_TYPE_COMPETITIVE)
    Sound.play("menu")
end

function M.hide_menu(silent)
    if not built then return end
    if not silent and not panel.win:IsHidden() then Sound.play("close") end
    panel.win:SetHidden(true)
    queue_ticker_sync(false)
end

function M.toggle()
    if not built then return end
    if panel.win:IsHidden() then M.show_menu() else M.hide_menu() end
end

function M.on_report_closed()
    if not reopen_after_report then return end
    reopen_after_report = false
    if built and Prefs.get("show_launcher") and on_hud then
        M.show_menu()
    end
end

function M.mark_unread()
    if built then launcher.pip:SetHidden(false) end
end

function M.clear_unread()
    if built then launcher.pip:SetHidden(true) end
end

function M.on_game_menu()
    reopen_after_report = false
    M.hide_menu(true)
end

function M.refresh_if_visible()
    if built and not panel.win:IsHidden() then
        auto_height()
        M.refresh()
    end
end

function M.sync()
    if not built then return end
    local vis = Prefs.get("show_launcher") and on_hud
    launcher.win:SetHidden(not vis)
    if not vis then M.hide_menu(true) end
end

function M.on_scene(hud)
    on_hud = hud
    M.sync()
end

function M.init()
    build()
    local C = BGMeter.zenimax.constants
    if C.EVENT_ACTIVITY_FINDER_STATUS_UPDATE then
        BGMeter.zenimax.events.register("BGMeterQueue", C.EVENT_ACTIVITY_FINDER_STATUS_UPDATE,
            function() M.update_queue() end)
    end
    if SCENE_MANAGER then
        local function handler(_, newState)
            if newState == SCENE_SHOWN then M.on_scene(true)
            elseif newState == SCENE_HIDDEN then M.on_scene(false) end
        end
        for _, name in ipairs({ "hud", "hudui" }) do
            local ok, sc = pcall(function() return SCENE_MANAGER:GetScene(name) end)
            if ok and sc and type(sc.RegisterCallback) == "function" then
                pcall(function() sc:RegisterCallback("StateChange", handler) end)
            end
        end
    end
    on_hud = (BGMeter.zenimax.scene and BGMeter.zenimax.scene.is_hud_scene()) and true or false
    M.sync()
    BGMeter.Log.debug("menu ready (launcher %s)", Prefs.get("show_launcher") and "shown" or "hidden")
end

BGMeter.UI.menu = M
