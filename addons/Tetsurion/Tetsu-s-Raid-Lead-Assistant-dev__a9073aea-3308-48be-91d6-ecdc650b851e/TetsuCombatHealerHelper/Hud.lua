-- Group buff HUD + effect tracker. No world / head icons.
TetsuCombatHealerHelper = TetsuCombatHealerHelper or {}
local T = TetsuCombatHealerHelper

T.Hud = T.Hud or T.Heads or {}
T.Heads = T.Hud
local H = T.Hud

local UPDATE_NAME = "TetsuCHH_HudUpdate"
local SCAN_NAME = "TetsuCHH_BuffScan"
local PANEL_NAME = "TetsuCHH_PanelUpdate"

local coverage = {}
local liveUnits = {}
local hudRoot, hudTitle, hudBg, hudCover, hudAlert, hudBarBg, hudBarFill
local hudHeader = {}
local hudCount = {}
local hudRows = {}
local hudAttached = false
local lastAlertMs = 0

local COL_W = 64
local NAME_W = 168
local ROW_H = 28
local TEX_DISC = "EsoUI/Art/ActionBar/abilityHighlight_mage_med.dds"
local TEX_SQUARE = "TetsuCombatHealerHelper/textures/square.dds"
local COL_HEAL = { 0.12, 1.00, 0.32 }

local function Now()
    if GetGameTimeMilliseconds then
        return GetGameTimeMilliseconds()
    end
    return 0
end

local function Vars()
    return T.savedVars
end

local function DotStyle()
    local vars = Vars()
    local s = vars and vars.hudDotStyle
    if s == "glow" then return "glow" end
    return "solid"
end

local function InCombat()
    if not IsUnitInCombat then return false end
    local ok, v = pcall(IsUnitInCombat, "player")
    return ok and v and true or false
end

local function CovKey(unitTag)
    if T.StableUnitKey then
        return T.StableUnitKey(unitTag)
    end
    return unitTag
end

local function HasEffect(unitTag, key)
    local bag = coverage[CovKey(unitTag)]
    if not bag then return false end
    local t = bag[key]
    if not t then return false end
    if t == 0 then return true end
    return t > Now()
end

local function SetEffect(unitTag, key, active, endTime)
    local ck = CovKey(unitTag)
    if not ck or not key then return end
    coverage[ck] = coverage[ck] or {}
    if active then
        coverage[ck][key] = endTime or 0
    else
        coverage[ck][key] = nil
    end
end

local function HasPrayer(unitTag)
    if HasEffect(unitTag, "prayer") then return true end
    local ber = HasEffect(unitTag, "minorBerserk") or HasEffect(unitTag, "berserk")
    local res = HasEffect(unitTag, "minorResolve") or HasEffect(unitTag, "resolve")
    return ber and res
end

local function EffectEnd(unitTag, key)
    local bag = coverage[CovKey(unitTag)]
    if not bag then return nil end
    return bag[key]
end

local function EffectMode(unitTag, key)
    if key == "prayer" then
        if not HasPrayer(unitTag) then return 0 end
        local ends = {}
        local ep = EffectEnd(unitTag, "prayer")
        if ep and ep > 0 then ends[#ends + 1] = ep end
        local eb = EffectEnd(unitTag, "minorBerserk") or EffectEnd(unitTag, "berserk")
        local er = EffectEnd(unitTag, "minorResolve") or EffectEnd(unitTag, "resolve")
        if eb and eb > 0 and er and er > 0 then
            ends[#ends + 1] = math.min(eb, er)
        end
        if #ends == 0 then return 2 end
        local left = math.min(unpack and unpack(ends) or ends[1]) - Now()
        -- math.min on list
        local m = ends[1]
        for i = 2, #ends do
            if ends[i] < m then m = ends[i] end
        end
        left = m - Now()
        if left > 0 and left <= 2000 then return 1 end
        return 2
    end
    local t = EffectEnd(unitTag, key)
    if not t then return 0 end
    if t == 0 then return 2 end
    local left = t - Now()
    if left <= 0 then return 0 end
    if left <= 2000 then return 1 end
    return 2
end

local function UnitDead(unitTag)
    if type(IsUnitDead) ~= "function" then return false end
    local ok, dead = pcall(IsUnitDead, unitTag)
    return ok and dead and true or false
end

local function UnitPresent(unitTag)
    if not unitTag then return false end
    if DoesUnitExist and not DoesUnitExist(unitTag) then return false end
    if IsUnitOnline and unitTag ~= "player" and not IsUnitOnline(unitTag) then
        return false
    end
    return true
end

local function ClipNick(raw, maxLen)
    if not raw or raw == "" then return "" end
    raw = tostring(raw)
    if raw:sub(1, 1) == "@" then
        raw = raw:sub(2)
    end
    raw = raw:gsub("%^.*", "")
    maxLen = maxLen or 14
    local len = T.Utf8Len and T.Utf8Len(raw) or #raw
    if len <= maxLen then return raw end
    local from = len - maxLen + 1
    if T.Utf8Sub then
        return T.Utf8Sub(raw, from, len)
    end
    return raw
end


local function ApplyFontTiny(label)
    if not label or not label.SetFont then return end
    local fonts = {
        "ZoFontGamepad20",
        "ZoFontGamepad18",
        "ZoFontWinH5",
        "ZoFontGameSmall",
        "ZoFontGameBold",
        "ZoFontGame",
        "ZoFontGamepad22",
    }
    for i = 1, #fonts do
        if pcall(function() label:SetFont(fonts[i]) end) then
            return
        end
    end
end

local function ApplyFont(label, small)
    if not label or not label.SetFont then return end
    local fonts = small and {
        "ZoFontGamepadBold22",
        "ZoFontGamepad22",
        "ZoFontAnnounceMedium",
        "ZoFontWinH4",
        "ZoFontGameBold",
        "ZoFontGame",
    } or {
        "ZoFontGamepadBold34",
        "ZoFontGamepad34",
        "ZoFontGamepadBold27",
        "ZoFontAnnounceLarge",
        "ZoFontWinH2",
        "ZoFontGameBold",
        "ZoFontGame",
    }
    for i = 1, #fonts do
        if pcall(function() label:SetFont(fonts[i]) end) then
            return
        end
    end
end

local function UnitUsable(unitTag)
    if not unitTag then return false end
    if DoesUnitExist and not DoesUnitExist(unitTag) then return false end
    if type(IsUnitDead) == "function" then
        local okDead, dead = pcall(IsUnitDead, unitTag)
        if okDead and dead then return false end
    end
    return true
end

local function UnitLabel(unitTag)
    if GetUnitDisplayName then
        local n = GetUnitDisplayName(unitTag)
        if n and n ~= "" then return n end
    end
    if GetUnitName then
        local n = GetUnitName(unitTag)
        if n and n ~= "" then return n end
    end
    return unitTag
end

local function HudKeys()
    local vars = Vars() or {}
    local keys = {}
    for i = 1, 5 do
        local key = vars["hudBuff" .. i] or "off"
        if type(key) ~= "string" then key = "off" end
        if T.ResolveSlotKey then
            key = T.ResolveSlotKey(key)
        end
        if key == "illustrious" or key == "vigor" or key == "echoingVigor" or key == "resolvingVigor"
            or key == "energyOrb" or key == "orbLockout" then
            key = "off"
        end
        keys[i] = key
    end
    return keys
end

local function IsSelf(unitTag)
    if T.IsSelf then return T.IsSelf(unitTag) end
    return unitTag == "player"
end

local function UnitRoleRank(unitTag)
    local role
    if unitTag == "player" and GetSelectedLFGRole then
        local ok, r = pcall(GetSelectedLFGRole)
        if ok then role = r end
    end
    if (not role or role == 0) and GetGroupMemberSelectedRole then
        local ok, r = pcall(GetGroupMemberSelectedRole, unitTag)
        if ok then role = r end
    end
    if (not role or role == 0) and GetUnitRole then
        local ok, r = pcall(GetUnitRole, unitTag)
        if ok then role = r end
    end
    if LFG_ROLE_TANK and role == LFG_ROLE_TANK then return 1, "T" end
    if LFG_ROLE_HEAL and role == LFG_ROLE_HEAL then return 2, "H" end
    if role == 2 then return 1, "T" end
    if role == 4 then return 2, "H" end
    return 3, "D"
end

local function UnitHealthPct(unitTag)
    local powerType = POWERTYPE_HEALTH or 1
    if COMBAT_MECHANIC_FLAGS_HEALTH then
        powerType = COMBAT_MECHANIC_FLAGS_HEALTH
    end
    if not GetUnitPower then return 1 end
    local ok, current, maxv, effective = pcall(GetUnitPower, unitTag, powerType)
    if not ok then return 1 end
    local cap = effective or maxv
    if not current or not cap or cap <= 0 then return 1 end
    return current / cap
end

local function IsTank(unitTag)
    local rank = UnitRoleRank(unitTag)
    return rank == 1
end

local function AttachHud(control)
    if not control or not SCENE_MANAGER then return false end
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
            pcall(function()
                sc:AddFragment(frag)
            end)
        end
    end
    return true
end

local function EnsureHud()
    if hudRoot then return hudRoot end
    local wm = WINDOW_MANAGER
    if not wm then return nil end
    local root = wm:CreateTopLevelWindow("TetsuCHH_GapHUD")
    if not root then
        root = wm:CreateControl("TetsuCHH_GapHUD", GuiRoot, CT_TOPLEVELCONTROL)
    end
    if not root then return nil end
    root:SetHidden(false)
    root:SetMouseEnabled(false)
    root:SetDimensions(380, 280)
    root:ClearAnchors()
    root:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -24, 132)
    if DT_LOW then root:SetDrawTier(DT_LOW) else root:SetDrawTier(DT_MEDIUM) end
    if DL_CONTROLS then root:SetDrawLayer(DL_CONTROLS) end
    root:SetDrawLevel(0)
    if root.SetClampedToScreen then root:SetClampedToScreen(true) end

    hudBg = wm:CreateControl("TetsuCHH_GapHUDBg", root, CT_BACKDROP)
    if hudBg then
        hudBg:SetAnchorFill(root)
        if hudBg.SetCenterColor then hudBg:SetCenterColor(0.04, 0.06, 0.08, 0.78) end
        if hudBg.SetEdgeColor then hudBg:SetEdgeColor(0.22, 0.72, 0.48, 0.85) end
    end

    local accent = wm:CreateControl("TetsuCHH_GapHUDAccent", root, CT_TEXTURE)
    if accent then
        accent:SetAnchor(TOPLEFT, root, TOPLEFT, 1, 1)
        accent:SetAnchor(TOPRIGHT, root, TOPRIGHT, -1, 1)
        accent:SetHeight(3)
        accent:SetColor(0.25, 0.85, 0.52, 0.95)
        accent:SetTexture(TEX_SQUARE)
    end

    hudTitle = wm:CreateControl("TetsuCHH_GapHUDTitle", root, CT_LABEL)
    hudTitle:SetAnchor(TOPLEFT, root, TOPLEFT, 8, 4)
    hudTitle:SetDimensions(400, 20)
    hudTitle:SetColor(0.45, 0.95, 0.68, 1)
    ApplyFont(hudTitle, true)
    hudTitle:SetText("Heal")

    hudCover = wm:CreateControl("TetsuCHH_GapHUDCover", root, CT_LABEL)
    hudCover:SetAnchor(TOPLEFT, root, TOPLEFT, 10, 32)
    hudCover:SetDimensions(460, 22)
    hudCover:SetColor(0.78, 0.92, 0.82, 1)
    ApplyFont(hudCover, true)
    hudCover:SetText("")

    hudBarBg = wm:CreateControl("TetsuCHH_GapHUDBarBg", root, CT_BACKDROP)
    if hudBarBg then
        hudBarBg:SetAnchor(TOPLEFT, root, TOPLEFT, 10, 54)
        hudBarBg:SetDimensions(280, 10)
        if hudBarBg.SetCenterColor then hudBarBg:SetCenterColor(0.12, 0.16, 0.14, 0.9) end
        if hudBarBg.SetEdgeColor then hudBarBg:SetEdgeColor(0.20, 0.45, 0.30, 0.8) end
    end
    hudBarFill = wm:CreateControl("TetsuCHH_GapHUDBarFill", root, CT_TEXTURE)
    if hudBarFill then
        hudBarFill:SetAnchor(TOPLEFT, root, TOPLEFT, 10, 54)
        hudBarFill:SetDimensions(1, 10)
        hudBarFill:SetColor(0.20, 0.95, 0.45, 0.95)
        hudBarFill:SetTexture(TEX_SQUARE)
    end

    hudAlert = wm:CreateControl("TetsuCHH_GapHUDAlert", root, CT_LABEL)
    hudAlert:SetDimensions(460, 22)
    hudAlert:SetColor(1, 0.35, 0.28, 1)
    ApplyFont(hudAlert, true)
    hudAlert:SetText("")

    for i = 1, 5 do
        local lab = wm:CreateControl("TetsuCHH_HudH" .. i, root, CT_LABEL)
        lab:SetDimensions(COL_W, 18)
        lab:SetColor(0.70, 0.86, 0.74, 1)
        ApplyFontTiny(lab)
        if lab.SetHorizontalAlignment and TEXT_ALIGN_CENTER then
            lab:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        end
        hudHeader[i] = lab
        local cnt = wm:CreateControl("TetsuCHH_HudC" .. i, root, CT_LABEL)
        cnt:SetDimensions(COL_W, 16)
        cnt:SetColor(0.55, 0.78, 0.62, 1)
        ApplyFontTiny(cnt)
        if cnt.SetHorizontalAlignment and TEXT_ALIGN_CENTER then
            cnt:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        end
        hudCount[i] = cnt
    end

    hudRoot = root
    if not hudAttached then
        hudAttached = AttachHud(root) and true or false
    end
    return root
end

local function EnsureRow(i)
    if hudRows[i] then return hudRows[i] end
    local root = EnsureHud()
    if not root then return nil end
    local wm = WINDOW_MANAGER
    local row = wm:CreateControl("TetsuCHH_GapRow" .. i, root, CT_CONTROL)
    row:SetDimensions(340, ROW_H)
    local cut = wm:CreateControl(row:GetName() .. "C", row, CT_LABEL)
    ApplyFont(cut, true)
    cut:SetDimensions(18, ROW_H)
    cut:SetAnchor(LEFT, row, LEFT, 2, 0)
    cut:SetColor(0.95, 0.42, 1.0, 1)
    cut:SetText("")
    cut:SetHidden(true)
    local ih = wm:CreateControl(row:GetName() .. "IH", row, CT_BACKDROP)
    ih:SetDimensions(8, 8)
    ih:SetAnchor(LEFT, row, LEFT, 20, 0)
    if ih.SetCenterColor then ih:SetCenterColor(1.0, 0.82, 0.18, 1) end
    if ih.SetEdgeColor then ih:SetEdgeColor(0, 0, 0, 0) end
    ih:SetHidden(true)
    local name = wm:CreateControl(row:GetName() .. "N", row, CT_LABEL)
    ApplyFont(name, true)
    name:SetDimensions(NAME_W - 8, ROW_H)
    name:SetAnchor(LEFT, row, LEFT, 8, 0)
    name:SetColor(0.93, 0.95, 0.90, 1)
    local dots = {}
    for c = 1, 5 do
        local wrap = wm:CreateControl(row:GetName() .. "W" .. c, row, CT_CONTROL)
        wrap:SetHidden(false)
        wrap:SetDimensions(26, 26)
        local glow = wm:CreateControl(wrap:GetName() .. "G", wrap, CT_TEXTURE)
        glow:SetAnchor(CENTER, wrap, CENTER, 0, 0)
        glow:SetDimensions(32, 32)
        glow:SetHidden(true)
        local ring = wm:CreateControl(wrap:GetName() .. "R", wrap, CT_TEXTURE)
        ring:SetHidden(true)
        ring:SetAnchor(CENTER, wrap, CENTER, 0, 0)
        ring:SetDimensions(20, 20)
        local fill = wm:CreateControl(wrap:GetName() .. "F", wrap, CT_BACKDROP)
        fill:SetAnchor(CENTER, wrap, CENTER, 0, 0)
        fill:SetDimensions(16, 16)
        if fill.SetCenterColor then fill:SetCenterColor(0, 0, 0, 0.45) end
        if fill.SetEdgeColor then fill:SetEdgeColor(0, 0, 0, 0) end
        if fill.SetInsets then fill:SetInsets(0, 0, 0, 0) end
        fill:SetHidden(false)
        dots[c] = { wrap = wrap, ring = ring, fill = fill, glow = glow }
    end
    hudRows[i] = { row = row, name = name, dots = dots, cut = cut, ih = ih }
    return hudRows[i]
end

function H.OnEffectChanged(_, changeType, _slot, effectName, unitTag, beginTime, endTime, _stacks, _icon, _buffType, _effectType, _abilityType, _status, _unitName, _unitId, abilityId, _sourceType)
    if not unitTag or unitTag == "" then return end
    local key = T.LookupKeyForAbilityId(abilityId, effectName)
    if not key then return end
    local gained = (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED)
    if EFFECT_RESULT_FULL_REFRESH and changeType == EFFECT_RESULT_FULL_REFRESH then
        gained = true
    end
    if gained then
        local endMs = 0
        if endTime and endTime > 0 then
            endMs = math.floor(endTime * 1000)
        end
        -- Ground HoT ticks last ~1s. Keep the HUD lit between ticks.
        if key == "illustrious" then
            local sticky = Now() + 2500
            if endMs < sticky then endMs = sticky end
        end
        SetEffect(unitTag, key, true, endMs)
    elseif changeType == EFFECT_RESULT_FADED then
        if key == "illustrious" then
            local ck = CovKey(unitTag)
            local cur = ck and coverage[ck] and coverage[ck][key]
            if cur and cur > Now() then
                return
            end
        end
        if key == "orbLockout" then
            local ck = CovKey(unitTag)
            local cur = ck and coverage[ck] and coverage[ck][key]
            if cur and cur > Now() then
                return
            end
        end
        SetEffect(unitTag, key, false)
    end
end

local function StripGender(name)
    if not name or name == "" then return "" end
    return zo_strlower((tostring(name):gsub("%^.*", "")))
end

local function TagForCombatName(targetName)
    local want = StripGender(targetName)
    if want == "" then return nil end
    local found
    local function consider(tag)
        if not tag then return end
        if StripGender(GetUnitName and GetUnitName(tag) or "") == want then
            found = tag
        elseif StripGender(GetUnitDisplayName and GetUnitDisplayName(tag) or "") == want then
            found = tag
        end
    end
    consider("player")
    if T.EachGroupTag then
        T.EachGroupTag(consider)
    end
    return found
end

local HEAL_RESULTS = {}
local function HealResult(v)
    if v then HEAL_RESULTS[v] = true end
end
HealResult(ACTION_RESULT_HEAL)
HealResult(ACTION_RESULT_HEAL_CRIT)
HealResult(ACTION_RESULT_HOT_TICK)
HealResult(ACTION_RESULT_HOT_TICK_CRITICAL)
HealResult(ACTION_RESULT_EFFECT_GAINED)
HealResult(ACTION_RESULT_EFFECT_GAINED_DURATION)

function H.OnCombatEvent(_, result, isError, abilityName, _g, _slot, _srcName, _srcType, targetName, _tgtType, _hit, _pwr, _dmg, _log, _sid, _tid, abilityId)
    if isError then return end
    -- Never call LookupKeyForAbilityId(id, nil): empty name used to poison the cache.
    local hit = abilityId and T.IsIllustrious and T.IsIllustrious[abilityId]
    if not hit then
        if result and next(HEAL_RESULTS) and not HEAL_RESULTS[result] then
            return
        end
        hit = abilityName and T.TextMatchesNeedles and T.TextMatchesNeedles(abilityName, "illustrious")
    end
    if not hit then return end
    local tag = TagForCombatName(targetName)
    if not tag then
        local me = StripGender(GetUnitName and GetUnitName("player") or "")
        if me ~= "" and StripGender(targetName) == me then
            tag = "player"
        end
    end
    if tag then
        SetEffect(tag, "illustrious", true, Now() + 2500)
    end
end

function H.OnCombatState(_, inCombat)
    -- Keep tracked effects out of combat so HUD dots stay testable.
    if inCombat == false and H.ScanGroupBuffs then
        H.ScanGroupBuffs()
    end
end

local function UnitHasKey(tag, key)
    if key == "prayer" then return HasPrayer(tag) end
    if key == "vigor" or key == "echoingVigor" or key == "resolvingVigor" then
        return HasEffect(tag, "vigor") or HasEffect(tag, "echoingVigor") or HasEffect(tag, "resolvingVigor")
    end
    return HasEffect(tag, key)
end

function H.RefreshAll()
    local vars = Vars()
    local root = EnsureHud()
    if root and not hudAttached then
        hudAttached = AttachHud(root) and true or false
    end
    local menu = T.WorldHudVisible and not T.WorldHudVisible()
    if menu or not vars or vars.enabled == false or vars.hudList == false then
        if root and not root:IsHidden() then
            root:SetHidden(true)
        end
        return
    end
    if root then
        root:SetHidden(false)
    end
    if hudCover then hudCover:SetHidden(true) end
    if hudBarBg then hudBarBg:SetHidden(true) end
    if hudBarFill then hudBarFill:SetHidden(true) end
    if hudAlert then hudAlert:SetHidden(true) end

    local keys = HudKeys()
    local liveCols = {}
    for c = 1, 5 do
        if keys[c] and keys[c] ~= "off" then
            liveCols[#liveCols + 1] = c
        end
    end

    local tags = {}
    if T.EachGroupTag then
        T.EachGroupTag(function(tag)
            if UnitPresent(tag) then
                tags[#tags + 1] = tag
            end
        end)
    else
        tags[1] = "player"
    end
    if vars.sortByRole ~= false then
        table.sort(tags, function(a, b)
            local ra = UnitRoleRank(a)
            local rb = UnitRoleRank(b)
            if ra ~= rb then return ra < rb end
            return (UnitLabel(a) or "") < (UnitLabel(b) or "")
        end)
    end

    local n = #tags
    if hudTitle then
        local title = (T.L and T.L.HEAL_SHORT) or "Heal"
        hudTitle:SetText(string.format("%s  %d", title, n > 0 and n or 1))
    end

    local ox = vars.hudOffsetX or 0
    local oy = vars.hudOffsetY or 0
    local scale = vars.hudScale or 1
    if scale < 0.7 then scale = 0.7 end
    if scale > 1.4 then scale = 1.4 end
    if root then
        root:ClearAnchors()
        root:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -24 + ox, 132 + oy)
        if root.SetScale then
            root:SetScale(scale)
        end
        local a = 1
        if not InCombat() then
            a = (vars.oocAlpha or 70) / 100
            if a < 0.2 then a = 0.2 end
            if a > 1 then a = 1 end
        end
        if root.SetAlpha then root:SetAlpha(a) end
    end

    local colCount = #liveCols
    if colCount < 1 then colCount = 1 end
    local x0 = NAME_W + 10
    local useGlow = DotStyle() == "glow"

    local covers = {}
    for i = 1, #liveCols do
        local c = liveCols[i]
        local key = keys[c]
        local have, tot = 0, 0
        for u = 1, #tags do
            if not UnitDead(tags[u]) then
                tot = tot + 1
                local on = HasEffect(tags[u], key)
                if key == "prayer" then on = HasPrayer(tags[u]) end
                if on then have = have + 1 end
            end
        end
        covers[c] = { have = have, tot = tot }
        local lab = hudHeader[c]
        if lab then
            lab:ClearAnchors()
            local short = T.SlotShort and T.SlotShort(key) or key
            local x = x0 + (i - 1) * COL_W
            lab:ClearAnchors()
            lab:SetAnchor(TOPLEFT, root, TOPLEFT, x, 18)
            lab:SetText(short)
            lab:SetHidden(false)
            local cnt = hudCount[c]
            if cnt then
                cnt:ClearAnchors()
                cnt:SetAnchor(TOPLEFT, root, TOPLEFT, x, 34)
                cnt:SetText(string.format("%d/%d", have, tot > 0 and tot or 0))
                if tot > 0 and have < tot then
                    cnt:SetColor(1.0, 0.62, 0.28, 1)
                else
                    cnt:SetColor(0.55, 0.78, 0.62, 1)
                end
                cnt:SetHidden(false)
            end
        end
    end
    for c = 1, 5 do
        local used = false
        for i = 1, #liveCols do
            if liveCols[i] == c then used = true end
        end
        if not used then
            if hudHeader[c] then
                hudHeader[c]:SetText("")
                hudHeader[c]:SetHidden(true)
            end
            if hudCount[c] then
                hudCount[c]:SetText("")
                hudCount[c]:SetHidden(true)
            end
        end
    end

    local rowI = 0
    for i = 1, #tags do
        rowI = rowI + 1
        local r = EnsureRow(rowI)
        if r then
            r.row:ClearAnchors()
            r.row:SetAnchor(TOPLEFT, root, TOPLEFT, 2, 54 + (rowI - 1) * ROW_H)
            local dead = UnitDead(tags[i])
            local _, roleLetter = UnitRoleRank(tags[i])
            local nick = ClipNick(UnitLabel(tags[i]) or "", 13)
            local label = (roleLetter or "D") .. " " .. nick
            local hp = UnitHealthPct(tags[i])
            local hpLimit = (vars.lowHpPercent or 35) / 100
            local watchHp = vars.lowHpTanksOnly == false or IsTank(tags[i])
            local lowHp = (not dead) and watchHp and hp <= hpLimit
            local cutOn = vars.showHealCut ~= false and (
                HasEffect(tags[i], "healCut")
                or HasEffect(tags[i], "majorDefile")
                or HasEffect(tags[i], "minorDefile")
            )
            local inPuddle = (not dead) and UnitHasKey(tags[i], "illustrious")
            if r.cut then
                r.cut:SetHidden(not cutOn)
                r.cut:SetText(cutOn and "✖" or "")
            end
            if r.ih then
                r.ih:SetHidden(not inPuddle)
            end
            local nameX = 8
            if cutOn then nameX = 18 end
            if inPuddle then nameX = nameX + 10 end
            r.name:SetAnchor(LEFT, r.row, LEFT, nameX, 0)
            r.name:SetText(label)
            if dead then
                r.name:SetColor(0.50, 0.52, 0.50, 0.85)
            elseif lowHp then
                r.name:SetColor(1.0, 0.28, 0.24, 1)
            elseif inPuddle then
                r.name:SetColor(1.0, 0.86, 0.20, 1)
            elseif IsSelf(tags[i]) then
                r.name:SetColor(0.55, 0.95, 0.75, 1)
            else
                r.name:SetColor(0.93, 0.95, 0.90, 1)
            end
            for c = 1, 5 do
                local d = r.dots[c]
                local liveIndex
                for li = 1, #liveCols do
                    if liveCols[li] == c then liveIndex = li end
                end
                if not liveIndex then
                    d.wrap:SetHidden(true)
                else
                    d.wrap:SetHidden(false)
                    d.wrap:ClearAnchors()
                    d.wrap:SetAnchor(LEFT, r.row, LEFT, x0 + (liveIndex - 1) * COL_W + math.floor((COL_W - 16) / 2) - 2, 0)
                    local key = keys[c]
                    local mode = dead and 0 or EffectMode(tags[i], key)
                    if key == "vigor" or key == "echoingVigor" or key == "resolvingVigor" then
                        if HasEffect(tags[i], "vigor") or HasEffect(tags[i], "echoingVigor") or HasEffect(tags[i], "resolvingVigor") then
                            mode = math.max(mode, 2)
                        end
                    end
                    if d.ring then d.ring:SetHidden(true) end
                    d.fill:SetHidden(false)
                    local rgb = T.ColumnColor and T.ColumnColor(c) or COL_HEAL
                    if mode == 0 then
                        if d.glow then d.glow:SetHidden(true) end
                        if d.fill.SetCenterColor then
                            d.fill:SetCenterColor(0, 0, 0, 0.45)
                        else
                            d.fill:SetColor(0, 0, 0, 0.45)
                        end
                        d.fill:SetDimensions(16, 16)
                    else
                        local a = (mode == 1) and 0.55 or 1
                        if d.fill.SetCenterColor then
                            d.fill:SetCenterColor(rgb[1], rgb[2], rgb[3], a)
                        else
                            d.fill:SetColor(rgb[1], rgb[2], rgb[3], a)
                        end
                        d.fill:SetDimensions(mode == 1 and 12 or 16, mode == 1 and 12 or 16)
                        if d.glow then
                            -- Never use the circular ability highlight. It reads as a
                            -- colored aura around a sharp square on console.
                            d.glow:SetHidden(true)
                        end
                    end
                end
            end
            r.row:SetHidden(false)
        end
    end
    for i = rowI + 1, #hudRows do
        hudRows[i].row:SetHidden(true)
    end
    if root then
        local w = NAME_W + 16 + math.max(1, #liveCols) * COL_W
        root:SetDimensions(w, math.max(78, 60 + rowI * ROW_H + 6))
    end
end


local function ScanUnitBuffs(unitTag)
    if type(GetNumBuffs) ~= "function" or type(GetUnitBuffInfo) ~= "function" then
        return
    end
    local fresh = {}
    local okN, n = pcall(GetNumBuffs, unitTag)
    if okN and n and n > 0 then
        for i = 1, n do
            local ok, buffName, _s, timeEnding, _slot, _stacks, _icon, _bt, _et, _at, _st, abilityId =
                pcall(GetUnitBuffInfo, unitTag, i)
            if ok then
                local mapped = T.LookupKeyForAbilityId(abilityId, buffName)
                if mapped then
                    local endMs = 0
                    if timeEnding and timeEnding > 0 then
                        endMs = math.floor(timeEnding * 1000)
                    end
                    fresh[mapped] = endMs
                end
            end
        end
    end
    local ck = CovKey(unitTag)
    if not ck then return end
    local old = coverage[ck]
    if old and old.illustrious then
        local sticky = old.illustrious
        if sticky ~= 0 and sticky > Now() and not fresh.illustrious then
            fresh.illustrious = sticky
        end
    end
    coverage[ck] = fresh
end

function H.ScanGroupBuffs()
    for k in pairs(liveUnits) do
        liveUnits[k] = nil
    end
    liveUnits.player = true
    if T.EachGroupTag then
        T.EachGroupTag(function(tag)
            liveUnits[CovKey(tag)] = true
            pcall(ScanUnitBuffs, tag)
        end)
    else
        pcall(ScanUnitBuffs, "player")
    end
    for ck, _ in pairs(coverage) do
        if not liveUnits[ck] then
            coverage[ck] = nil
        end
    end
    if T.Panels and T.Panels.ScanBoss then
        for i = 1, 8 do
            pcall(T.Panels.ScanBoss, "boss" .. i)
        end
        local allowTarget = not Vars() or Vars().debuffOnTarget ~= false
        if allowTarget and DoesUnitExist and DoesUnitExist("reticleover") then
            local monster = true
            if IsUnitMonster then
                local okM, m = pcall(IsUnitMonster, "reticleover")
                monster = okM and m
            end
            if monster then
                pcall(T.Panels.ScanBoss, "reticleover")
            end
        end
    end
end

function H.Start()
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    EVENT_MANAGER:UnregisterForUpdate(SCAN_NAME)
    EVENT_MANAGER:UnregisterForUpdate(PANEL_NAME)
    EnsureHud()
    H.ScanGroupBuffs()
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 300, function()
        pcall(H.RefreshAll)
    end)
    EVENT_MANAGER:RegisterForUpdate(SCAN_NAME, 1000, function()
        pcall(H.ScanGroupBuffs)
    end)
    EVENT_MANAGER:RegisterForUpdate(PANEL_NAME, 300, function()
        if T.Panels and T.Panels.Refresh then
            pcall(T.Panels.Refresh)
        end
    end)
    H.RefreshAll()
    if T.Panels and T.Panels.Refresh then
        pcall(T.Panels.Refresh)
    end
end

function H.HasTracked(unitTag, key)
    return UnitHasKey(unitTag, key)
end

function H.UnitOk(unitTag)
    return UnitUsable(unitTag)
end

function H.GetRoot()
    return hudRoot
end

function H.Stop()
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    EVENT_MANAGER:UnregisterForUpdate(SCAN_NAME)
    EVENT_MANAGER:UnregisterForUpdate(PANEL_NAME)
    if hudRoot then hudRoot:SetHidden(true) end
end
