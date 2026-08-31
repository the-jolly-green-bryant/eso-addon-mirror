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
    return GetGameTimeMilliseconds()
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
    if not bag or not bag[key] then return false end
    local t = bag[key]
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
        local endMs = 0
        if endTime and endTime > 0 then endMs = math.floor(endTime * 1000) end
        bossFx[unitTag][key] = endMs
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
    title:SetDimensions(170, 18)
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
    local rows = {}
    for i = 1, #T.BossDebuffPairs do
        local row = wm:CreateControl(block:GetName() .. "R" .. i, block, CT_CONTROL)
        row:SetDimensions(176, ROW)
        local name = wm:CreateControl(row:GetName() .. "N", row, CT_LABEL)
        ApplyFont(name)
        name:SetDimensions(NAME_W, ROW)
        name:SetAnchor(LEFT, row, LEFT, 6, 0)
        name:SetColor(0.9, 0.93, 0.88, 1)
        local d1 = MakeDot(row, "A")
        d1.wrap:SetAnchor(LEFT, row, LEFT, NAME_W + 10, 0)
        local d2 = MakeDot(row, "B")
        d2.wrap:SetAnchor(LEFT, row, LEFT, NAME_W + 10 + COL, 0)
        rows[i] = { row = row, name = name, d1 = d1, d2 = d2 }
    end
    debuffBlocks[idx] = { block = block, title = title, h1 = h1, h2 = h2, rows = rows }
    return debuffBlocks[idx]
end

local function LiveBosses()
    local list = {}
    for i = 1, 8 do
        local tag = "boss" .. i
        if DoesUnitExist and DoesUnitExist(tag) then
            local name = GetUnitName and GetUnitName(tag) or tag
            if name and name ~= "" then
                list[#list + 1] = { tag = tag, name = name }
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
            list[1] = { tag = "reticleover", name = name, target = true }
        end
    end
    return list
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
            if healerOn and parent and not parent:IsHidden() then
                root:SetAnchor(TOPLEFT, parent, BOTTOMLEFT, 0, 8)
            else
                root:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -24 + pairOx, 132 + pairOy)
            end
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
    local compactBoss = false
    if showDeb then
        if #bosses < 1 then
            compactBoss = true
            bosses = { { tag = "boss1", name = (T.L and T.L.NO_BOSS) or "Out", empty = true } }
        end
        local root = EnsureDebuffHud()
        if root then
            root:SetHidden(false)
            local y = 0
            for b = 1, #bosses do
                local blk = EnsureBossBlock(b)
                if blk then
                    blk.block:ClearAnchors()
                    blk.block:SetAnchor(TOPLEFT, root, TOPLEFT, 0, y)
                    blk.block:SetHidden(false)
                    local panelWord = (T.L and T.L.DEBUFFS_SHORT) or "Debuffs"
                    local nm
                    if compactBoss or bosses[b].empty then
                        nm = panelWord
                    elseif bosses[b].name and bosses[b].name ~= "" then
                        nm = bosses[b].name
                        if (T.Utf8Len and T.Utf8Len(nm) or #nm) > 14 then nm = (T.Utf8Sub and T.Utf8Sub(nm, 1, 13) or nm) .. "…" end
                    else
                        nm = panelWord
                    end
                    blk.title:SetText(nm)
                    blk.h1:SetText("Mj")
                    blk.h2:SetText("Mn")
                    local ry = 22
                    if compactBoss or bosses[b].empty then
                        blk.h1:SetHidden(true)
                        blk.h2:SetHidden(true)
                        blk.title:SetText(panelWord .. "  " .. ((T.L and T.L.NO_BOSS) or "Out"))
                        for i = 1, #blk.rows do
                            blk.rows[i].row:SetHidden(true)
                        end
                        if blk.obH then blk.obH:SetHidden(true) end
                        if blk.obH2 then blk.obH2:SetHidden(true) end
                        blk.block:SetDimensions(176, 26)
                        y = y + 28
                    else
                    blk.h1:SetHidden(false)
                    blk.h2:SetHidden(false)
                    ry = 42
                    local obPair, obRow
                    for i = 1, #T.BossDebuffPairs do
                        local pair = T.BossDebuffPairs[i]
                        local r = blk.rows[i]
                        if pair.ob then
                            obPair = pair
                            obRow = r
                            r.row:SetHidden(true)
                        elseif T.PairEnabled("debuff", pair.id) then
                            r.row:ClearAnchors()
                            r.row:SetAnchor(TOPLEFT, blk.block, TOPLEFT, 0, ry)
                            r.name:SetText(PairLabel(pair.id))
                            local onMaj, onMin = false, false
                            for k = 1, #pair.keysMaj do
                                if BossHas(bosses[b].tag, pair.keysMaj[k]) then onMaj = true end
                            end
                            for k = 1, #pair.keysMin do
                                if BossHas(bosses[b].tag, pair.keysMin[k]) then onMin = true end
                            end
                            PaintDot(r.d1.ring, r.d1.fill, r.d1.glow, onMaj and 2 or 0, COL_DEBUFF)
                            PaintDot(r.d2.ring, r.d2.fill, r.d2.glow, onMin and 2 or 0, COL_DEBUFF)
                            r.row:SetHidden(false)
                            ry = ry + ROW
                        else
                            r.row:SetHidden(true)
                        end
                    end
                    if obPair and obRow and T.PairEnabled("debuff", "offbalance") then
                        if not blk.obH then
                            local wm = WINDOW_MANAGER
                            local lab = wm:CreateControl(blk.block:GetName() .. "OBH", blk.block, CT_LABEL)
                            ApplyFont(lab)
                            lab:SetDimensions(COL, 18)
                            lab:SetColor(0.75, 0.88, 0.78, 1)
                            blk.obH = lab
                        end
                        blk.obH:ClearAnchors()
                        blk.obH:SetAnchor(TOPLEFT, blk.block, TOPLEFT, NAME_W + 6, ry + 2)
                        blk.obH:SetDimensions(COL, 18)
                        ApplyFont(blk.obH, true)
                        blk.obH:SetText("On")
                        blk.obH:SetHidden(false)
                        if not blk.obH2 then
                            local lab2 = WINDOW_MANAGER:CreateControl(blk.block:GetName() .. "OBH2", blk.block, CT_LABEL)
                            lab2:SetColor(0.75, 0.88, 0.78, 1)
                            blk.obH2 = lab2
                        end
                        blk.obH2:ClearAnchors()
                        blk.obH2:SetAnchor(TOPLEFT, blk.block, TOPLEFT, NAME_W + 6 + COL, ry + 2)
                        blk.obH2:SetDimensions(COL, 18)
                        ApplyFont(blk.obH2)
                        blk.obH2:SetText("Imm")
                        blk.obH2:SetHidden(false)
                        ry = ry + 18
                        obRow.row:ClearAnchors()
                        obRow.row:SetAnchor(TOPLEFT, blk.block, TOPLEFT, 0, ry)
                        obRow.name:SetText(PairLabel("offbalance"))
                        local on = BossHas(bosses[b].tag, "offBalance")
                        local imm = BossHas(bosses[b].tag, "offBalanceImm")
                        PaintDot(obRow.d1.ring, obRow.d1.fill, obRow.d1.glow, on and 2 or 0, COL_DEBUFF)
                        PaintDot(obRow.d2.ring, obRow.d2.fill, obRow.d2.glow, imm and 2 or 0, COL_IMM)
                        obRow.row:SetHidden(false)
                        ry = ry + ROW
                    else
                        if blk.obH then blk.obH:SetHidden(true) end
                        if blk.obH2 then blk.obH2:SetHidden(true) end
                        if obRow then obRow.row:SetHidden(true) end
                    end
                    blk.block:SetDimensions(176, ry + 4)
                    y = y + ry + 8
                    end
                end
            end
            for b = #bosses + 1, #debuffBlocks do
                debuffBlocks[b].block:SetHidden(true)
            end
            root:SetDimensions(176, math.max(40, y))
        end
    elseif debuffRoot then
        debuffRoot:SetHidden(true)
    end

    local buffShown = buffRoot and not buffRoot:IsHidden()
    local debShown = debuffRoot and not debuffRoot:IsHidden()
    -- Pack from the healer's RIGHT edge. Pair widths are fixed (~170+176);
    -- if we hang them off the healer's LEFT, a short healer grid pushes the
    -- boss window off-screen and SetClampedToScreen slides it back over buffs.
    if healerOn and parent and not parent:IsHidden() then
        if debShown then
            debuffRoot:ClearAnchors()
            debuffRoot:SetAnchor(TOPRIGHT, parent, BOTTOMRIGHT, 0, 8)
        end
        if buffShown then
            buffRoot:ClearAnchors()
            if debShown then
                buffRoot:SetAnchor(TOPRIGHT, debuffRoot, TOPLEFT, -8, 0)
            else
                buffRoot:SetAnchor(TOPRIGHT, parent, BOTTOMRIGHT, 0, 8)
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
                buffRoot:SetAnchor(TOPRIGHT, debuffRoot, TOPLEFT, -8, 0)
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
