TetsuCombatHealerHelper = TetsuCombatHealerHelper or {}
local T = TetsuCombatHealerHelper
T.Panels = T.Panels or {}
local P = T.Panels

local COL_BUFF = { 0.25, 0.55, 1.00 }
local COL_DEBUFF = { 1.00, 0.22, 0.18 }
local COL_IMM = { 1.00, 0.82, 0.18 }

local buffRoot, debuffRoot
local buffRows, debuffBlocks = {}, {}
local bossFx = {}
local attached = false

local COL = 40
local ROW = 24
local NAME_W = 84

local function Now()
    if GetGameTimeMilliseconds then
        return GetGameTimeMilliseconds()
    end
    return 0
end

local function EndMs(timeStarted, timeEnding)
    local start = tonumber(timeStarted) or 0
    local stop = tonumber(timeEnding) or 0
    if stop <= 0 or (stop - start) <= 0.05 then
        return 0
    end
    local nowS = GetFrameTimeSeconds and GetFrameTimeSeconds() or (Now() / 1000)
    local remain = stop - nowS
    if remain <= 0.25 then
        return 0
    end
    return Now() + math.floor(remain * 1000)
end

local function Vars()
    return T.savedVars
end

local function ApplyFont(label)
    if not label or not label.SetFont then return end
    local fonts = { "ZoFontGamepadBold22", "ZoFontGamepad22", "ZoFontGameBold", "ZoFontGame" }
    for i = 1, #fonts do
        if pcall(function() label:SetFont(fonts[i]) end) then return end
    end
end

local function Attach(control)
    if not control or not SCENE_MANAGER then return end
    local frag
    if ZO_HUDFadeSceneFragment then
        frag = ZO_HUDFadeSceneFragment:New(control)
    elseif ZO_SimpleSceneFragment then
        frag = ZO_SimpleSceneFragment:New(control)
    end
    if not frag then return end
    for _, name in ipairs({ "hud", "hudui" }) do
        local sc = SCENE_MANAGER:GetScene(name)
        if sc and sc.AddFragment then
            pcall(function() sc:AddFragment(frag) end)
        end
    end
end

local function MakeTop(name, w, h)
    local wm = WINDOW_MANAGER
    if not wm then return nil end
    local root = wm:CreateTopLevelWindow(name)
    if not root then
        root = wm:CreateControl(name, GuiRoot, CT_TOPLEVELCONTROL)
    end
    if not root then return nil end
    root:SetHidden(true)
    root:SetMouseEnabled(false)
    root:SetDimensions(w, h)
    if DT_LOW then root:SetDrawTier(DT_LOW) else root:SetDrawTier(DT_MEDIUM) end
    if DL_CONTROLS then root:SetDrawLayer(DL_CONTROLS) end
    root:SetDrawLevel(0)
    if root.SetClampedToScreen then root:SetClampedToScreen(true) end
    local bg = wm:CreateControl(name .. "Bg", root, CT_BACKDROP)
    if bg then
        bg:SetAnchorFill(root)
        if bg.SetCenterColor then bg:SetCenterColor(0.04, 0.06, 0.08, 0.72) end
        if bg.SetEdgeColor then bg:SetEdgeColor(0.22, 0.72, 0.48, 0.7) end
    end
    Attach(root)
    return root
end

local function PaintDot(ring, fill, glow, mode, rgb)
    if glow then glow:SetHidden(true) end
    if ring then ring:SetHidden(true) end
    if not fill then return end
    fill:SetHidden(false)
    rgb = rgb or COL_BUFF
    local a = (mode == 0 and 0.45) or (mode == 1 and 0.70) or 1
    local size = (mode == 1 and 9) or 16
    fill:SetDimensions(size, size)
    local r, g, b = 0, 0, 0
    if mode ~= 0 then
        r, g, b = rgb[1], rgb[2], rgb[3]
    end
    if fill.SetCenterColor then
        fill:SetCenterColor(r, g, b, a)
        if fill.SetEdgeColor then fill:SetEdgeColor(0, 0, 0, 0) end
    else
        fill:SetColor(r, g, b, a)
    end
end

local function MakeDot(parent, suffix)
    local wm = WINDOW_MANAGER
    local wrap = wm:CreateControl(parent:GetName() .. suffix, parent, CT_CONTROL)
    wrap:SetDimensions(18, 18)
    local glow = wm:CreateControl(wrap:GetName() .. "G", wrap, CT_TEXTURE)
    glow:SetAnchor(CENTER, wrap, CENTER, 0, 0)
    glow:SetDimensions(22, 22)
    glow:SetHidden(true)
    local ring = wm:CreateControl(wrap:GetName() .. "R", wrap, CT_TEXTURE)
    ring:SetAnchor(CENTER, wrap, CENTER, 0, 0)
    ring:SetDimensions(16, 16)
    ring:SetHidden(true)
    local fill = wm:CreateControl(wrap:GetName() .. "F", wrap, CT_BACKDROP)
    fill:SetAnchor(CENTER, wrap, CENTER, 0, 0)
    fill:SetDimensions(14, 14)
    if fill.SetCenterColor then fill:SetCenterColor(0, 0, 0, 0.45) end
    if fill.SetEdgeColor then fill:SetEdgeColor(0, 0, 0, 0) end
    if fill.SetInsets then fill:SetInsets(0, 0, 0, 0) end
    fill:SetHidden(false)
    return { wrap = wrap, ring = ring, fill = fill, glow = glow }
end

local function PairLabel(id)
    if T.PairPanelLabel then
        return T.PairPanelLabel(id)
    end
    if T.HudLabel then
        return T.HudLabel(id, 8)
    end
    return (T.EnglishName and T.EnglishName[id]) or id
end

local function HasKey(tag, key)
    if T.Hud and T.Hud.HasTracked then
        return T.Hud.HasTracked(tag, key)
    end
    return false
end

local function AnyKey(tag, keys)
    for i = 1, #keys do
        if HasKey(tag, keys[i]) then return true end
    end
    return false
end

local function CountPair(pair)
    local n, maj, mn = 0, 0, 0
    local function one(tag)
        n = n + 1
        if AnyKey(tag, pair.keysMaj) then maj = maj + 1 end
        if AnyKey(tag, pair.keysMin) then mn = mn + 1 end
    end
    if T.EachGroupTag then
        T.EachGroupTag(one)
    else
        one("player")
    end
    if n < 1 then n = 1 end
    local function mode(have)
        if have <= 0 then return 0 end
        if have >= n then return 2 end
        return 1
    end
    return mode(maj), mode(mn)
end

local function BossHas(tag, key)
    local bag = bossFx[tag]
    if not bag then return false end
    local t = bag[key]
    if t == nil then return false end
    if t == 0 then return true end
    return t > Now()
end

function P.OnBossEffect(_, changeType, _slot, effectName, unitTag, beginTime, endTime, _s, _i, _bt, _et, _at, _st, _un, _uid, abilityId)
    if not unitTag then return end
    if unitTag:find("^boss") then
        -- ok
    elseif unitTag == "reticleover" then
        local vars = Vars()
        if vars and vars.debuffOnTarget == false then return end
    else
        return
    end
    local key = T.MatchPairKey and T.MatchPairKey(abilityId, effectName)
    if not key then return end
    bossFx[unitTag] = bossFx[unitTag] or {}
    local gained = (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED)
    if EFFECT_RESULT_FULL_REFRESH and changeType == EFFECT_RESULT_FULL_REFRESH then gained = true end
    if gained then
        bossFx[unitTag][key] = EndMs(beginTime, endTime)
    elseif changeType == EFFECT_RESULT_FADED then
        bossFx[unitTag][key] = nil
    end
end

function P.ScanBoss(tag)
    if not GetNumBuffs or not GetUnitBuffInfo then return end
    if not DoesUnitExist or not DoesUnitExist(tag) then
        return
    end
    local fresh = {}
    local okN, n = pcall(GetNumBuffs, tag)
    if not okN or not n then return end
    for i = 1, n do
        local ok, name, _s, ending, _sl, _st, _ic, _bt, _et, _at, _se, id = pcall(GetUnitBuffInfo, tag, i)
        if ok then
            local key = T.MatchPairKey and T.MatchPairKey(id, name)
            if key then
                local endMs = 0
                if ending and ending > 0 then endMs = math.floor(ending * 1000) end
                fresh[key] = endMs
            end
        end
    end
    if fresh.offBalanceImm or fresh.offBalance then
        bossFx[tag] = fresh
    else
        local old = bossFx[tag] or {}
        if old.offBalanceImm and old.offBalanceImm > Now() and not fresh.offBalance then
            fresh.offBalanceImm = old.offBalanceImm
        end
        bossFx[tag] = fresh
    end
end

local function EnsureBuffHud()
    if buffRoot then return buffRoot end
    buffRoot = MakeTop("TetsuCHH_RaidBuffs", 170, 80)
    if not buffRoot then return nil end
    local title = WINDOW_MANAGER:CreateControl("TetsuCHH_RaidBuffsT", buffRoot, CT_LABEL)
    title:SetAnchor(TOPLEFT, buffRoot, TOPLEFT, 8, 2)
    title:SetDimensions(NAME_W - 2, 18)
    title:SetColor(0.45, 0.95, 0.68, 1)
    ApplyFont(title)
    title:SetText((T.L and (T.L.BUFFS_SHORT or T.L.RAID_BUFFS)) or "Buffs")
    local mj = WINDOW_MANAGER:CreateControl("TetsuCHH_RaidBuffsMj", buffRoot, CT_LABEL)
    mj:SetAnchor(TOPLEFT, buffRoot, TOPLEFT, NAME_W + 8, 22)
    mj:SetDimensions(COL, 18)
    mj:SetColor(0.75, 0.88, 0.78, 1)
    ApplyFont(mj)
    mj:SetText("Mj")
    local mn = WINDOW_MANAGER:CreateControl("TetsuCHH_RaidBuffsMn", buffRoot, CT_LABEL)
    mn:SetAnchor(TOPLEFT, buffRoot, TOPLEFT, NAME_W + 8 + COL, 22)
    mn:SetDimensions(COL, 18)
    mn:SetColor(0.75, 0.88, 0.78, 1)
    ApplyFont(mn)
    mn:SetText("Mn")
    return buffRoot
end

local function EnsureBuffRow(i)
    if buffRows[i] then return buffRows[i] end
    local root = EnsureBuffHud()
    if not root then return nil end
    local wm = WINDOW_MANAGER
    local row = wm:CreateControl("TetsuCHH_RB" .. i, root, CT_CONTROL)
    row:SetDimensions(170, ROW)
    local name = wm:CreateControl(row:GetName() .. "N", row, CT_LABEL)
    ApplyFont(name)
    name:SetDimensions(NAME_W, ROW)
    name:SetAnchor(LEFT, row, LEFT, 6, 0)
    name:SetColor(0.9, 0.93, 0.88, 1)
    local d1 = MakeDot(row, "A")
    d1.wrap:SetAnchor(LEFT, row, LEFT, NAME_W + 10, 0)
    local d2 = MakeDot(row, "B")
    d2.wrap:SetAnchor(LEFT, row, LEFT, NAME_W + 10 + COL, 0)
    buffRows[i] = { row = row, name = name, d1 = d1, d2 = d2 }
    return buffRows[i]
end

local MAX_BOSS = 4
local PAIR_W = 100

local function EnsureDebuffHud()
    if debuffRoot then return debuffRoot end
    debuffRoot = MakeTop("TetsuCHH_BossDebuffs", 176, 80)
    return debuffRoot
end

local function EnsureBossBlock(idx)
    if debuffBlocks[idx] then return debuffBlocks[idx] end
    local root = EnsureDebuffHud()
    if not root then return nil end
    local wm = WINDOW_MANAGER
    local block = wm:CreateControl("TetsuCHH_BD" .. idx, root, CT_CONTROL)
    block:SetDimensions(176, 200)
    local title = wm:CreateControl(block:GetName() .. "T", block, CT_LABEL)
    ApplyFont(title)
    title:SetAnchor(TOPLEFT, block, TOPLEFT, 6, 2)
    title:SetDimensions(300, 18)
    title:SetColor(0.45, 0.95, 0.68, 1)
    local h1 = wm:CreateControl(block:GetName() .. "H1", block, CT_LABEL)
    ApplyFont(h1)
    h1:SetAnchor(TOPLEFT, block, TOPLEFT, NAME_W + 8, 22)
    h1:SetDimensions(COL, 18)
    h1:SetColor(0.75, 0.88, 0.78, 1)
    h1:SetText("Mj")
    local h2 = wm:CreateControl(block:GetName() .. "H2", block, CT_LABEL)
    ApplyFont(h2)
    h2:SetAnchor(TOPLEFT, block, TOPLEFT, NAME_W + 8 + COL, 22)
    h2:SetDimensions(COL, 18)
    h2:SetColor(0.75, 0.88, 0.78, 1)
    h2:SetText("Mn")
    local heads, mjh, mnh = {}, {}, {}
    for b = 1, MAX_BOSS do
        local h = wm:CreateControl(block:GetName() .. "HN" .. b, block, CT_LABEL)
        ApplyFont(h)
        h:SetDimensions(PAIR_W, 16)
        h:SetColor(0.75, 0.88, 0.78, 1)
        h:SetHidden(true)
        heads[b] = h
        local mj = wm:CreateControl(block:GetName() .. "HMJ" .. b, block, CT_LABEL)
        ApplyFont(mj)
        mj:SetDimensions(COL, 14)
        mj:SetColor(0.70, 0.84, 0.74, 1)
        mj:SetHidden(true)
        mjh[b] = mj
        local mn = wm:CreateControl(block:GetName() .. "HMN" .. b, block, CT_LABEL)
        ApplyFont(mn)
        mn:SetDimensions(COL, 14)
        mn:SetColor(0.70, 0.84, 0.74, 1)
        mn:SetHidden(true)
        mnh[b] = mn
        local onl = wm:CreateControl(block:GetName() .. "HON" .. b, block, CT_LABEL)
        ApplyFont(onl)
        onl:SetDimensions(COL, 14)
        onl:SetColor(0.70, 0.84, 0.74, 1)
        onl:SetHidden(true)
        local iml = wm:CreateControl(block:GetName() .. "HIM" .. b, block, CT_LABEL)
        ApplyFont(iml)
        iml:SetDimensions(COL, 14)
        iml:SetColor(0.70, 0.84, 0.74, 1)
        iml:SetHidden(true)
        mjh[b]._on = onl
        mjh[b]._imm = iml
    end
    local nPairs = (T.BossDebuffPairs and #T.BossDebuffPairs) or 10
    local rows = {}
    for i = 1, nPairs do
        local row = wm:CreateControl(block:GetName() .. "R" .. i, block, CT_CONTROL)
        row:SetDimensions(400, ROW)
        local name = wm:CreateControl(row:GetName() .. "N", row, CT_LABEL)
        ApplyFont(name)
        name:SetDimensions(NAME_W, ROW)
        name:SetAnchor(LEFT, row, LEFT, 6, 0)
        name:SetColor(0.9, 0.93, 0.88, 1)
        local cols = {}
        for b = 1, MAX_BOSS do
            local d1 = MakeDot(row, "A" .. b)
            local d2 = MakeDot(row, "B" .. b)
            cols[b] = { d1 = d1, d2 = d2 }
        end
        rows[i] = { row = row, name = name, cols = cols }
    end
    local onh, imh = {}, {}
    for b = 1, MAX_BOSS do
        onh[b] = mjh[b]._on
        imh[b] = mjh[b]._imm
        mjh[b]._on = nil
        mjh[b]._imm = nil
    end
    debuffBlocks[idx] = { block = block, title = title, h1 = h1, h2 = h2, heads = heads, mjh = mjh, mnh = mnh, onh = onh, imh = imh, rows = rows }
    return debuffBlocks[idx]
end

local function LiveBosses()
    local list = {}
    for i = 1, 8 do
        local tag = "boss" .. i
        if DoesUnitExist and DoesUnitExist(tag) then
            local name = GetUnitName and GetUnitName(tag) or tag
            if name and name ~= "" then
                list[#list + 1] = { tag = tag, name = name, idx = i }
            end
        end
    end
    local allowTarget = not Vars() or Vars().debuffOnTarget ~= false
    if allowTarget and #list == 0 and DoesUnitExist and DoesUnitExist("reticleover") then
        local monster = false
        if IsUnitMonster then
            local okM, m = pcall(IsUnitMonster, "reticleover")
            monster = okM and m
        elseif GetUnitType then
            local okT, typ = pcall(GetUnitType, "reticleover")
            monster = okT and typ and typ ~= 0
        end
        if monster then
            local name = GetUnitName and GetUnitName("reticleover") or "Target"
            list[1] = { tag = "reticleover", name = name, target = true, idx = 0 }
        end
    end
    if #list > MAX_BOSS then
        local cut = {}
        for i = 1, MAX_BOSS do
            cut[i] = list[i]
        end
        return cut
    end
    return list
end

local function BossColTitle(boss)
    if boss and boss.empty then
        return (T.L and T.L.NO_BOSS) or "Out"
    end
    local idx = boss and boss.idx
    local prefix = (idx and idx > 0) and tostring(idx) or "•"
    local raw = (boss and boss.name) or ""
    raw = raw:gsub("%^.*", "")
    local name = T.ClipLabel and T.ClipLabel(raw, 8) or raw
    if name == "" then name = "Boss" end
    return prefix .. " " .. name
end

local function PairOn(tag, pair)
    local onMaj, onMin = false, false
    if pair.keysMaj then
        for k = 1, #pair.keysMaj do
            if BossHas(tag, pair.keysMaj[k]) then onMaj = true end
        end
    end
    if pair.keysMin then
        for k = 1, #pair.keysMin do
            if BossHas(tag, pair.keysMin[k]) then onMin = true end
        end
    end
    return onMaj, onMin
end

local function LayoutBossDots(row, nBoss, single)
    for b = 1, MAX_BOSS do
        local col = row.cols[b]
        if not col then
        elseif b > nBoss then
            col.d1.wrap:SetHidden(true)
            col.d2.wrap:SetHidden(true)
        else
            local x = NAME_W + 10 + (b - 1) * PAIR_W
            col.d1.wrap:ClearAnchors()
            col.d1.wrap:SetAnchor(LEFT, row.row, LEFT, x, 0)
            col.d1.wrap:SetHidden(false)
            col.d2.wrap:ClearAnchors()
            col.d2.wrap:SetAnchor(LEFT, row.row, LEFT, x + COL, 0)
            col.d2.wrap:SetHidden(single and true or false)
        end
    end
end

function P.Refresh()
    local vars = Vars()
    if T.WorldHudVisible and not T.WorldHudVisible() then
        if buffRoot then buffRoot:SetHidden(true) end
        if debuffRoot then debuffRoot:SetHidden(true) end
        return
    end
    local parent = T.Hud and T.Hud.GetRoot and T.Hud.GetRoot()
    local showPairs = vars and vars.enabled ~= false and vars.showPairPanels ~= false
    local healerOn = vars and vars.enabled ~= false and vars.hudList ~= false
    local showBuffs = showPairs and vars.showRaidPanel ~= false
    local showDeb = showPairs and vars.showBossPanel ~= false
    local pairOx = (vars and vars.pairOffsetX) or 0
    local pairOy = (vars and vars.pairOffsetY) or 0

    if showBuffs then
        local root = EnsureBuffHud()
        if root then
            root:SetHidden(false)
            root:ClearAnchors()
            -- Final anchors are applied after both windows exist.
            root:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -24 + pairOx, 132 + pairOy)
            local y = 42
            local used = 0
            for i = 1, #T.RaidBuffPairs do
                local pair = T.RaidBuffPairs[i]
                if T.PairEnabled("buff", pair.id) then
                    used = used + 1
                    local r = EnsureBuffRow(used)
                    if r then
                        r.row:ClearAnchors()
                        r.row:SetAnchor(TOPLEFT, root, TOPLEFT, 0, y)
                        r.name:SetText(PairLabel(pair.id))
                        local m1, m2 = CountPair(pair)
                        PaintDot(r.d1.ring, r.d1.fill, r.d1.glow, m1, COL_BUFF)
                        PaintDot(r.d2.ring, r.d2.fill, r.d2.glow, m2, COL_BUFF)
                        r.row:SetHidden(false)
                        y = y + ROW
                    end
                end
            end
            for i = used + 1, #buffRows do
                buffRows[i].row:SetHidden(true)
            end
            root:SetDimensions(170, math.max(40, y + 6))
        end
    elseif buffRoot then
        buffRoot:SetHidden(true)
    end

    local bosses = showDeb and LiveBosses() or {}
    if showDeb then
        if #bosses < 1 then
            bosses = { { tag = "_empty", name = (T.L and T.L.NO_BOSS) or "Out", idx = 0, empty = true } }
        end
        local root = EnsureDebuffHud()
        if root then
            root:SetHidden(false)
            local nBoss = #bosses
            local blk = EnsureBossBlock(1)
            for b = 2, #debuffBlocks do
                debuffBlocks[b].block:SetHidden(true)
            end
            if blk then
                blk.block:ClearAnchors()
                blk.block:SetAnchor(TOPLEFT, root, TOPLEFT, 0, 0)
                blk.block:SetHidden(false)
                local panelWord = (T.L and T.L.DEBUFFS_SHORT) or "Debuffs"
                blk.title:SetText(panelWord)
                blk.h1:SetHidden(true)
                blk.h2:SetHidden(true)
                if blk.obH then blk.obH:SetHidden(true) end
                if blk.obH2 then blk.obH2:SetHidden(true) end
                for b = 1, MAX_BOSS do
                    local x = NAME_W + 8 + (b - 1) * PAIR_W
                    local h = blk.heads and blk.heads[b]
                    local mj = blk.mjh and blk.mjh[b]
                    local mn = blk.mnh and blk.mnh[b]
                    if b <= nBoss then
                        if h then
                            h:ClearAnchors()
                            h:SetAnchor(TOPLEFT, blk.block, TOPLEFT, x, 20)
                            h:SetText(BossColTitle(bosses[b]))
                            h:SetHidden(false)
                        end
                        if mj then
                            mj:ClearAnchors()
                            mj:SetAnchor(TOPLEFT, blk.block, TOPLEFT, x, 36)
                            mj:SetText("Mj")
                            mj:SetHidden(false)
                        end
                        if mn then
                            mn:ClearAnchors()
                            mn:SetAnchor(TOPLEFT, blk.block, TOPLEFT, x + COL, 36)
                            mn:SetText("Mn")
                            mn:SetHidden(false)
                        end
                    else
                        if h then h:SetHidden(true) end
                        if mj then mj:SetHidden(true) end
                        if mn then mn:SetHidden(true) end
                    end
                    if blk.onh and blk.onh[b] then blk.onh[b]:SetHidden(true) end
                    if blk.imh and blk.imh[b] then blk.imh[b]:SetHidden(true) end
                end
                local ry = 54
                for i = 1, #T.BossDebuffPairs do
                    local pair = T.BossDebuffPairs[i]
                    local r = blk.rows[i]
                    if not r then
                    elseif not T.PairEnabled("debuff", pair.id) then
                        r.row:SetHidden(true)
                    else
                        if pair.ob then
                            for b = 1, nBoss do
                                local x = NAME_W + 8 + (b - 1) * PAIR_W
                                local onl = blk.onh and blk.onh[b]
                                local iml = blk.imh and blk.imh[b]
                                if onl then
                                    onl:ClearAnchors()
                                    onl:SetAnchor(TOPLEFT, blk.block, TOPLEFT, x, ry)
                                    onl:SetText("On")
                                    onl:SetHidden(false)
                                end
                                if iml then
                                    iml:ClearAnchors()
                                    iml:SetAnchor(TOPLEFT, blk.block, TOPLEFT, x + COL, ry)
                                    iml:SetText("Imm")
                                    iml:SetHidden(false)
                                end
                            end
                            ry = ry + 16
                        end
                        r.row:ClearAnchors()
                        r.row:SetAnchor(TOPLEFT, blk.block, TOPLEFT, 0, ry)
                        r.name:SetText(PairLabel(pair.id))
                        LayoutBossDots(r, nBoss, pair.single or pair.onOnly)
                        for b = 1, nBoss do
                            local col = r.cols[b]
                            if pair.ob then
                                local on = BossHas(bosses[b].tag, "offBalance")
                                local imm = BossHas(bosses[b].tag, "offBalanceImm")
                                PaintDot(col.d1.ring, col.d1.fill, col.d1.glow, on and 2 or 0, COL_DEBUFF)
                                PaintDot(col.d2.ring, col.d2.fill, col.d2.glow, imm and 2 or 0, COL_IMM)
                            else
                                local onMaj, onMin = PairOn(bosses[b].tag, pair)
                                PaintDot(col.d1.ring, col.d1.fill, col.d1.glow, onMaj and 2 or 0, COL_DEBUFF)
                                if not (pair.single or pair.onOnly) then
                                    PaintDot(col.d2.ring, col.d2.fill, col.d2.glow, onMin and 2 or 0, COL_DEBUFF)
                                end
                            end
                        end
                        r.row:SetHidden(false)
                        ry = ry + ROW
                    end
                end
                local w = NAME_W + 16 + nBoss * PAIR_W
                if w < 176 then w = 176 end
                blk.block:SetDimensions(w, ry + 4)
                root:SetDimensions(w, ry + 4)
            end
        end
    elseif debuffRoot then
        debuffRoot:SetHidden(true)
    end

    local buffShown = buffRoot and not buffRoot:IsHidden()
    local debShown = debuffRoot and not debuffRoot:IsHidden()
    -- Pack from the healer's RIGHT edge. Pair widths are fixed (~170+176);
    -- if we hang them off the healer's LEFT, a short healer grid pushes the
    -- boss window off-screen and SetClampedToScreen slides it back over buffs.
    -- Stack under the healer, right edges aligned:
    -- healer HUD
    -- debuffs (grows left when 3–4 bosses)
    -- raid buffs
    -- pairOffset nudges the whole stack in both modes.
    if healerOn and parent and not parent:IsHidden() then
        if debShown then
            debuffRoot:ClearAnchors()
            -- Y follows the healer HUD. Stack X can still nudge left/right.
            debuffRoot:SetAnchor(TOPRIGHT, parent, BOTTOMRIGHT, pairOx, 8)
        end
        if buffShown then
            buffRoot:ClearAnchors()
            if debShown then
                buffRoot:SetAnchor(TOPRIGHT, debuffRoot, BOTTOMRIGHT, 0, 8)
            else
                buffRoot:SetAnchor(TOPRIGHT, parent, BOTTOMRIGHT, pairOx, 8)
            end
        end
    else
        if debShown then
            debuffRoot:ClearAnchors()
            debuffRoot:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -24 + pairOx, 132 + pairOy)
        end
        if buffShown then
            buffRoot:ClearAnchors()
            if debShown then
                buffRoot:SetAnchor(TOPRIGHT, debuffRoot, BOTTOMRIGHT, 0, 8)
            else
                buffRoot:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -24 + pairOx, 132 + pairOy)
            end
        end
    end

    local a = 1
    if not (IsUnitInCombat and IsUnitInCombat("player")) then
        a = ((vars and vars.oocAlpha) or 70) / 100
        if a < 0.2 then a = 0.2 end
        if a > 1 then a = 1 end
    end
    if buffShown and buffRoot.SetAlpha then buffRoot:SetAlpha(a) end
    if debShown and debuffRoot.SetAlpha then debuffRoot:SetAlpha(a) end
end
