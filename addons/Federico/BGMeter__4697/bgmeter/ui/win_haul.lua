BGMeter = BGMeter or {}
local BGMeter = BGMeter

local U = BGMeter.UI._win
local W = U.W
local SEC = U.SEC
local set_text, set_count, set_bar, pop, hide_all, hit_proxy = U.set_text, U.set_count, U.set_bar, U.pop, U.hide_all, U.hit_proxy
local ICON_STAR, ICON_SORTUP, ICON_SORTDN = U.ICON_STAR, U.ICON_SORTUP, U.ICON_SORTDN

local K = BGMeter.Constants
local L = BGMeter.Constants.LAYOUT
local F = BGMeter.Format
local P = BGMeter.Plot.primitives
local S = BGMeter.Plot.style
local Bar = BGMeter.Plot.bar
local Icons = BGMeter.Icons
local Prefs = BGMeter.Prefs

local MEDAL_PERROW, MEDAL_STEP, MEDAL_CAP = 7, 24, 14

local medal_card = nil

local function build_medal_card()
    if medal_card then return medal_card end
    local root = BGMeter.zenimax.ui.create_control(nil, W.win, CT_CONTROL)
    root:SetDimensions(280, 96)
    root:SetDrawLevel(30)
    root:SetDrawTier(DT_HIGH)
    root:SetHidden(true)

    local bg = P.rect(root, { K.COLOR.bg[1], K.COLOR.bg[2], K.COLOR.bg[3], 0.98 })
    bg:SetAnchorFill(root)
    P.frame(root):SetAnchorFill(root)

    local strip = P.rect(root, K.COLOR.gold)
    strip:SetAnchor(TOPLEFT, root, TOPLEFT, 4, 4)
    strip:SetAnchor(BOTTOMLEFT, root, BOTTOMLEFT, 4, -4)
    strip:SetWidth(2)

    local icon = P.icon(root)
    icon:SetDimensions(40, 40)
    icon:SetAnchor(TOPLEFT, root, TOPLEFT, 14, 12)

    local name = P.label(root, S.FONT.header, K.COLOR.text)
    U.clamp_line(name)
    name:SetAnchor(TOPLEFT, root, TOPLEFT, 64, 12)
    name:SetDimensions(202, 20)

    local count = P.label(root, S.FONT.small, K.COLOR.gold)
    count:SetAnchor(TOPLEFT, root, TOPLEFT, 64, 34)
    count:SetDimensions(202, 14)

    local cond = P.label(root, S.FONT.small, K.COLOR.text_dim)
    cond:SetAnchor(TOPLEFT, root, TOPLEFT, 14, 60)
    cond:SetWidth(252)

    local reward = P.label(root, S.FONT.small, K.COLOR.gold)
    reward:SetDimensions(252, 14)

    medal_card = { root = root, icon = icon, name = name, count = count, cond = cond, reward = reward }
    return medal_card
end

local function hide_medal_card()
    if medal_card then medal_card.root:SetHidden(true) end
end

local function show_medal_card(mi)
    local id = mi.bgmMedalId
    local n = mi.bgmMedalCount or 1
    BGMeter.Log.debug("medal hover: id=%s x%d", tostring(id), n)
    local info = id and Icons.medal_info(id) or nil
    if not info then return end
    local c = build_medal_card()

    c.icon:SetTexture(info.icon)
    set_text(c.name, info.name)
    set_text(c.count, (n > 1) and ("earned x" .. n) or "earned this match")

    local ch = 0
    if info.condition and info.condition ~= "" then
        set_text(c.cond, info.condition)
        ch = math.max(14, c.cond:GetTextHeight() or 14)
    else
        set_text(c.cond, "")
    end
    c.cond:SetHeight(ch)

    local rtext = (info.reward and info.reward > 0)
        and string.format("+%s score%s", F.commas(info.reward), n > 1 and " each" or "") or ""
    set_text(c.reward, rtext)
    c.reward:ClearAnchors()
    c.reward:SetAnchor(TOPLEFT, c.cond, BOTTOMLEFT, 0, 4)

    c.root:SetHeight(math.max(60 + ch + ((rtext ~= "") and 22 or 6), 64))
    c.root:ClearAnchors()
    c.root:SetAnchor(TOPRIGHT, mi, TOPLEFT, -10, -6)
    c.root:SetHidden(false)
end

local function build_haul(win)
    local p = {}
    local PAD = 16
    local INNER = L.haul_w - 2 * PAD

    p.container = BGMeter.zenimax.ui.create_control(nil, win, CT_CONTROL)
    p.container:SetAnchor(TOPRIGHT, win, TOPRIGHT, -L.margin, L.header_h)
    p.container:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -L.margin, -L.footer_h)
    p.container:SetWidth(L.haul_w)

    p.bd = P.backdrop(p.container)
    p.bd:SetAnchorFill(p.container)
    P.frame(p.container):SetAnchorFill(p.container)

    p.heading = P.label(p.container, S.FONT.header, K.COLOR.gold)
    p.heading:SetText("YOUR HAUL")
    p.heading:SetAnchor(TOP, p.container, TOP, 0, 14)

    p.vetIcon = P.icon(p.container)
    p.vetIcon:SetDimensions(52, 52)
    p.vetIcon:SetAnchor(TOPLEFT, p.container, TOPLEFT, PAD, 44)

    p.vetTitle = P.label(p.container, S.FONT.row, K.COLOR.veterancy)
    U.clamp_line(p.vetTitle)
    p.vetTitle:SetAnchor(TOPLEFT, p.vetIcon, TOPRIGHT, 12, 6)
    p.vetTitle:SetDimensions(INNER - 64, 22)
    p.vetTitle:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    p.vetTier = P.label(p.container, S.FONT.small, K.COLOR.text_dim)
    U.clamp_line(p.vetTier)
    p.vetTier:SetAnchor(TOPLEFT, p.vetTitle, BOTTOMLEFT, 0, 8)
    p.vetTier:SetDimensions(INNER - 64, 18)

    p.track = Bar.create(p.container)
    p.track.container:SetAnchor(TOPLEFT, p.vetIcon, BOTTOMLEFT, 0, 14)
    p.track.container:SetDimensions(INNER, 12)

    p.vetDelta = P.label(p.container, S.FONT.small, K.COLOR.veterancy)
    U.clamp_line(p.vetDelta)
    p.vetDelta:SetAnchor(TOPLEFT, p.track.container, BOTTOMLEFT, 0, 8)
    p.vetDelta:SetDimensions(INNER, 16)

    p.season = P.label(p.container, S.FONT.small, K.COLOR.text_dim)
    U.clamp_line(p.season)
    p.season:SetAnchor(TOPLEFT, p.vetDelta, BOTTOMLEFT, 0, 4)
    p.season:SetDimensions(INNER, 16)

    p.div1 = P.rect(p.container, { 1, 1, 1, 0.10 })
    p.div1:SetAnchor(TOPLEFT, p.season, BOTTOMLEFT, 0, 12)
    p.div1:SetDimensions(INNER, 1)

    local VAL_W = 74
    local NAME_W = INNER - 22 - 8 - VAL_W - 4
    local function receipt_line(anchorTo, dy, iconTex)
        local icon = P.icon(p.container, iconTex)
        icon:SetDimensions(22, 22)
        icon:SetAnchor(TOPLEFT, anchorTo, BOTTOMLEFT, 0, dy)
        local name = P.label(p.container, S.FONT.row, K.COLOR.text_dim)
        name:SetAnchor(LEFT, icon, RIGHT, 8, 0)
        name:SetDimensions(NAME_W, 22)
        name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        local val = P.label(p.container, S.FONT.row, K.COLOR.gold)
        val:SetAnchor(LEFT, name, RIGHT, 4, 0)
        val:SetDimensions(VAL_W, 22)
        val:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        val:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        return { icon = icon, name = name, val = val }
    end
    p.ap = receipt_line(p.div1, 12, Icons.ap()); p.ap.name:SetText("Alliance Pts")
    p.xp = receipt_line(p.ap.icon, 10, Icons.XP); p.xp.name:SetText("Experience")
    p.cp = receipt_line(p.xp.icon, 10, Icons.CP); p.cp.name:SetText("Champion Pts")

    p.medalLabel = P.label(p.container, S.FONT.row, K.COLOR.text_dim)
    U.clamp_line(p.medalLabel)
    p.medalLabel:SetText("Medals")
    p.medalLabel:SetAnchor(TOPLEFT, p.cp.icon, BOTTOMLEFT, 0, 12)
    p.medalLabel:SetDimensions(INNER, 18)
    p.medalIcons = {}
    p.medalBadges = {}
    for i = 1, MEDAL_CAP do
        local col = (i - 1) % MEDAL_PERROW
        local rowN = math.floor((i - 1) / MEDAL_PERROW)
        local mi = P.icon(p.container)
        mi:SetDimensions(22, 22)
        mi:SetAnchor(TOPLEFT, p.medalLabel, BOTTOMLEFT, col * MEDAL_STEP, 6 + rowN * MEDAL_STEP)
        mi:SetHidden(true)
        p.medalIcons[i] = mi

        local badge = P.label(p.container, S.FONT.small, K.COLOR.gold)
        badge:SetAnchor(BOTTOMRIGHT, mi, BOTTOMRIGHT, 3, 3)
        badge:SetDimensions(20, 12)
        badge:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        badge:SetDrawLevel(5)
        badge:SetHidden(true)
        p.medalBadges[i] = badge
    end
    p.medalMore = P.label(p.container, S.FONT.small, K.COLOR.medal)
    p.medalMore:SetAnchor(TOPLEFT, p.medalLabel, BOTTOMLEFT, 0, 6 + 2 * MEDAL_STEP)

    p.eff = P.label(p.container, S.FONT.small, K.COLOR.accent)
    U.clamp_line(p.eff)
    p.eff:SetAnchor(TOPLEFT, p.medalLabel, BOTTOMLEFT, 0, 30 + 2 * MEDAL_STEP)
    p.eff:SetDimensions(INNER, 16)
    p.eff:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    p.sep = P.rect(p.container, { 1, 1, 1, 0.10 })
    p.sep:SetAnchor(BOTTOMLEFT, p.container, BOTTOMLEFT, PAD, -96)
    p.sep:SetDimensions(INNER, 1)

    p.standHeading = P.label(p.container, S.FONT.small, K.COLOR.text_dim)
    p.standHeading:SetText("COMPETITIVE STANDING")
    p.standHeading:SetAnchor(TOPLEFT, p.sep, BOTTOMLEFT, 0, 10)
    p.standHeading:SetDimensions(INNER, 16)
    p.standHeading:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    p.standRank = P.label(p.container, S.FONT.big, K.COLOR.text)
    p.standRank:SetAnchor(TOP, p.standHeading, BOTTOM, 0, 4)
    p.standRank:SetDimensions(INNER, 30)
    p.standRank:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    p.standSub = P.label(p.container, S.FONT.small, K.COLOR.text_dim)
    U.clamp_line(p.standSub)
    p.standSub:SetAnchor(TOP, p.standRank, BOTTOM, 0, 2)
    p.standSub:SetDimensions(INNER, 18)
    p.standSub:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    W.tip_static(hit_proxy(p.ap.icon), "Alliance Points earned this match")
    W.tip_static(hit_proxy(p.xp.icon), "Experience earned this match")
    W.tip_static(hit_proxy(p.cp.icon), "Champion Points earned this match")
    p.vetIconHit = hit_proxy(p.vetIcon)
    W.tip_dynamic(p.vetIconHit)
    W.tip_dynamic(p.standRank)
    p.medalHits = {}
    for i = 1, #p.medalIcons do
        local mi = p.medalIcons[i]
        local hit = hit_proxy(mi)
        hit:SetMouseEnabled(true)
        hit:SetHidden(true)
        hit:SetHandler("OnMouseEnter", function() show_medal_card(mi) end)
        hit:SetHandler("OnMouseExit", hide_medal_card)
        p.medalHits[i] = hit
    end
    return p
end

function SEC.haul(m, animate)
    local p, h = W.haul, m.haul
    local rec = m.records or {}
    local vet = h.vetEnd or h.vetStart
    local vetControls = { p.vetIcon, p.vetIconHit, p.vetTitle, p.vetTier, p.track.container, p.vetDelta, p.season }

    if not Prefs.get("show_veterancy") then
        hide_all(vetControls, true)
    elseif vet and vet.rank then
        hide_all(vetControls, false)
        if vet.rankIcon then p.vetIcon:SetTexture(vet.rankIcon); p.vetIcon:SetHidden(false) else p.vetIcon:SetHidden(true) end
        set_text(p.vetTitle, vet.rankTitle or ("Veteran Rank " .. tostring(vet.rank)))
        set_text(p.vetTier, vet.tier and string.format("Tier %d", vet.tier) or "")
        local hasPct = vet.percent ~= nil
        Bar.set_hidden(p.track, not hasPct)
        if hasPct then set_bar(p.track, vet.percent, K.COLOR.veterancy, L.haul_w - 32, animate) end
        if h.vetRankUp then
            set_text(p.vetDelta, "RANK UP this match!"); S.color(p.vetDelta, K.COLOR.gold)
        elseif hasPct then
            local txt
            if vet.tierTotal and vet.tierTotal > 0 then
                txt = string.format("%s / %s to next rank", F.commas(vet.progressToNext or 0), F.commas(vet.tierTotal))
            else
                txt = "max rank reached"
            end
            set_text(p.vetDelta, txt); S.color(p.vetDelta, K.COLOR.veterancy)
        else
            set_text(p.vetDelta, "")
        end
        set_text(p.season, vet.seasonName or "")
        local endsTxt = (vet.secondsLeft and vet.secondsLeft > 0)
            and ("\nseason ends in " .. F.countdown(vet.secondsLeft)) or ""
        W.tips[p.vetIconHit] = string.format("%s%s\n%s%s",
            vet.rankTitle or ("Veteran Rank " .. tostring(vet.rank)),
            vet.tier and ("  ·  Tier " .. vet.tier) or "",
            vet.seasonName or "Veterancy season", endsTxt)
    else
        hide_all(vetControls, false)
        p.vetIcon:SetHidden(true)
        set_text(p.vetTitle, "Veterancy"); set_text(p.vetTier, "(no season data)")
        Bar.set_hidden(p.track, true); set_text(p.vetDelta, ""); set_text(p.season, "")
        W.tips[p.vetIconHit] = nil
    end

    set_count(p.ap.val, h.apGained, "+", animate)
    set_count(p.xp.val, h.xpGained, "+", animate)
    set_text(p.cp.val, h.cpGained > 0 and F.signed(h.cpGained) or "+0")
    S.color(p.ap.val, rec.ap and K.COLOR.you or K.COLOR.gold)
    if rec.ap and animate then pop(p.ap.val) end

    local lr = BGMeter.Match.local_row(m)
    local ids = lr and lr.medalIds or {}
    local counts = lr and lr.medalCounts or {}
    hide_medal_card()
    for i = 1, #p.medalIcons do
        local mi, badge, id = p.medalIcons[i], p.medalBadges[i], ids[i]
        local hit = p.medalHits[i]
        local info = id and Icons.medal_info(id) or nil
        if info and info.icon then
            mi:SetTexture(info.icon); mi:SetHidden(false)
            if hit then hit:SetHidden(false) end
            local n = counts[id] or 1
            mi.bgmMedalId = id
            mi.bgmMedalCount = n
            if n > 1 then
                set_text(badge, "x" .. n)
                badge:SetHidden(false)
            else
                badge:SetHidden(true)
            end
        else
            mi:SetHidden(true); badge:SetHidden(true)
            if hit then hit:SetHidden(true) end
            mi.bgmMedalId = nil
            mi.bgmMedalCount = nil
        end
    end
    set_text(p.medalMore, (#ids > #p.medalIcons) and ("+" .. (#ids - #p.medalIcons)) or "")

    set_text(p.eff, string.format("%s AP/min  ·  %s AP/kill", F.commas(h.apPerMin), F.commas(h.apPerKill)))

    local standControls = { p.sep, p.standHeading, p.standRank, p.standSub }
    local casual = (m.competitive == false)
        or (m.competitive == nil and m.teamSize == nil and #m.battle > 10)
    if not Prefs.get("show_standing") then hide_all(standControls, true); return end
    local effBottom = p.eff:GetBottom() or 0
    local sepTop = p.sep:GetTop() or 0
    if effBottom > 0 and sepTop > 0 and effBottom + 6 > sepTop then
        hide_all(standControls, true)
        return
    end

    if casual then
        local sess = BGMeter.Session
        if not sess or sess.matches == 0 then hide_all(standControls, true); return end
        hide_all(standControls, false)
        p.standHeading:SetText("SESSION")
        set_text(p.standRank, string.format("%dW - %dL", sess.wins, sess.losses))
        local col = K.COLOR.text
        if sess.wins > sess.losses then col = K.COLOR.heal
        elseif sess.losses > sess.wins then col = K.COLOR.accent end
        S.color(p.standRank, col)
        set_text(p.standSub, string.format("%s AP  ·  %d %s tonight",
            F.commas(sess.ap), sess.matches, sess.matches == 1 and "match" or "matches"))
        W.tips[p.standRank] = string.format(
            "This play session (since login)\n%d wins, %d losses\n%s AP  ·  %s XP earned",
            sess.wins, sess.losses, F.commas(sess.ap), F.commas(sess.xp))
        return
    end
    hide_all(standControls, false)
    p.standHeading:SetText("COMPETITIVE STANDING")

    local st = m.standing
    if not st then
        set_text(p.standRank, "..."); S.color(p.standRank, K.COLOR.text_dim)
        set_text(p.standSub, "loading leaderboard...")
        W.tips[p.standRank] = "Competitive leaderboard standing"
    elseif st.rank and st.rank > 0 then
        set_text(p.standRank, "#" .. F.commas(st.rank))
        local rankCol, move = K.COLOR.text, ""
        if st.rankDelta > 0 then rankCol = K.COLOR.heal; move = F.icon(ICON_SORTUP, 16) .. string.format(" |c5cc85f%d up|r   ", st.rankDelta)
        elseif st.rankDelta < 0 then rankCol = K.COLOR.accent; move = F.icon(ICON_SORTDN, 16) .. string.format(" |ce34234%d down|r   ", -st.rankDelta)
        elseif st.prevRank == 0 then rankCol = K.COLOR.gold; move = "|cf2cc55NEW|r   "
        else move = "|c8a8a8ano change|r   " end
        if rec.rank then move = F.icon(ICON_STAR, 16) .. " |cf2cc55best!|r   " .. move end
        S.color(p.standRank, rec.rank and K.COLOR.gold or rankCol)
        if rec.rank and animate then pop(p.standRank) end
        local sub = move .. "rating " .. F.commas(st.score)
        if st.scoreDelta and st.scoreDelta ~= 0 then
            sub = sub .. string.format(" (%s%s)", st.scoreDelta > 0 and "+" or "", F.commas(st.scoreDelta))
        end
        set_text(p.standSub, sub)
        local tip = "Competitive leaderboard standing\n"
        if st.rankDelta > 0 then tip = tip .. string.format("up %d since your last match", st.rankDelta)
        elseif st.rankDelta < 0 then tip = tip .. string.format("down %d since your last match", -st.rankDelta)
        elseif st.prevRank == 0 then tip = tip .. "your first ranked match"
        else tip = tip .. "no change since your last match" end
        if st.mmr then tip = tip .. "\nhidden MMR: " .. F.commas(st.mmr) end
        if not st.impacts then tip = tip .. "\n(this match did not affect rank)" end
        W.tips[p.standRank] = tip
    else
        set_text(p.standRank, "unranked"); S.color(p.standRank, K.COLOR.text_dim)
        set_text(p.standSub, st.impacts and "no leaderboard entry yet" or "this match did not affect rank")
        W.tips[p.standRank] = "Competitive leaderboard standing\nplay a ranked battleground to appear"
    end
end

U.build_haul = build_haul
U.hide_medal_card = hide_medal_card
