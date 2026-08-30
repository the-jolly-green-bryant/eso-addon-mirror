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
local hudRows = {}
local hudAttached = false
local lastAlertMs = 0

local COL_W = 56
local NAME_W = 170
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
    return HasEffect(unitTag, "minorBerserk") and HasEffect(unitTag, "minorResolve")
end

local function ApplyFont(label, small)
    if not label or not label.SetFont then return end
    local fonts = small and {
        "ZoFontGamepadBold27",
        "ZoFontGamepad27",
        "ZoFontGamepadBold22",
        "ZoFontGamepad22",
        "ZoFontAnnounceMedium",
        "ZoFontWinH3",
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
        if key == "illustrious" or key == "vigor" or key == "echoingVigor" or key == "resolvingVigor" then
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
    hudTitle:SetAnchor(TOPLEFT, root, TOPLEFT, 10, 8)
    hudTitle:SetDimensions(400, 28)
    hudTitle:SetColor(0.45, 0.95, 0.68, 1)
    ApplyFont(hudTitle, false)
    hudTitle:SetText("Healer Tracker")

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
        lab:SetDimensions(COL_W, 24)
        lab:SetColor(0.70, 0.86, 0.74, 1)
        ApplyFont(lab, true)
        if lab.SetHorizontalAlignment and TEXT_ALIGN_CENTER then
            lab:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        end
        hudHeader[i] = lab
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
    cut:SetDimensions(28, ROW_H)
    cut:SetAnchor(LEFT, row, LEFT, 4, 0)
    cut:SetColor(1, 0.25, 0.22, 1)
    cut:SetText("")
    cut:SetHidden(true)
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
    hudRows[i] = { row = row, name = name, dots = dots, cut = cut }
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
    local tag = TagForCombatName(targetName)
    if not tag then
        local me = StripGender(GetUnitName and GetUnitName("player") or "")
        if me ~= "" and StripGender(targetName) == me then
            tag = "player"
        end
    end
    if abilityId and T.LookupKeyForAbilityId and T.LookupKeyForAbilityId(abilityId, nil) == "orbLockout" then
        if tag then
            SetEffect(tag, "orbLockout", true, Now() + 20000)
        end
        return
    end
    local isIH = T.IsIllustriousAbility and T.IsIllustriousAbility(abilityId)
    if not isIH then
        if result and next(HEAL_RESULTS) and not HEAL_RESULTS[result] then
            return
        end
        isIH = T.TextMatchesNeedles and T.TextMatchesNeedles(abilityName, "illustrious")
    end
    if not isIH then return end
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

    local keys = HudKeys()
    local n = GetGroupSize and GetGroupSize() or 0
    if hudTitle then
        hudTitle:SetText(string.format("Healer Tracker   %d  ·  %s", n > 0 and n or 1, InCombat() and "IN COMBAT" or "out of combat"))
    end

    local tags = {}
    if T.EachGroupTag then
        T.EachGroupTag(function(tag)
            tags[#tags + 1] = tag
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
        root:SetHidden(false)
    end

    local x0 = NAME_W + 14
    for c = 1, 5 do
        local lab = hudHeader[c]
        if lab then
            local key = keys[c]
            lab:ClearAnchors()
            lab:SetAnchor(TOPLEFT, root, TOPLEFT, x0 + (c - 1) * COL_W, 38)
            if key == "off" then
                lab:SetText("")
            else
                lab:SetText(T.SlotShort and T.SlotShort(key) or zo_strsub(T.SlotLabel(key) or key, 1, 4))
            end
        end
    end

    local rowI = 0
    for i = 1, #tags do
        if UnitUsable(tags[i]) then
            rowI = rowI + 1
            
            local r = EnsureRow(rowI)
            if r then
                r.row:ClearAnchors()
                r.row:SetAnchor(TOPLEFT, root, TOPLEFT, 4, 64 + (rowI - 1) * ROW_H)
                local label = UnitLabel(tags[i]) or ""
                if zo_strlen(label) > 18 then
                    label = zo_strsub(label, 1, 17) .. "…"
                end
                local hp = UnitHealthPct(tags[i])
                local hpLimit = (vars.lowHpPercent or 35) / 100
                local watchHp = vars.lowHpTanksOnly == false or IsTank(tags[i])
                local lowHp = watchHp and hp <= hpLimit
                local cutOn = vars.showHealCut ~= false and HasEffect(tags[i], "healCut")
                if r.cut then
                    r.cut:SetHidden(not cutOn)
                    r.cut:SetText(cutOn and "✖" or "")
                end
                if cutOn then
                    r.name:SetAnchor(LEFT, r.row, LEFT, 30, 0)
                else
                    r.name:SetAnchor(LEFT, r.row, LEFT, 8, 0)
                end
                r.name:SetText(label)
                local inPuddle = UnitHasKey(tags[i], "illustrious")
                if lowHp then
                    r.name:SetColor(1.0, 0.28, 0.24, 1)
                elseif cutOn then
                    r.name:SetColor(0.95, 0.42, 1.0, 1)
                elseif inPuddle then
                    r.name:SetColor(1.0, 0.82, 0.18, 1)
                elseif IsSelf(tags[i]) then
                    r.name:SetColor(0.55, 0.95, 0.75, 1)
                else
                    r.name:SetColor(0.93, 0.95, 0.90, 1)
                end
                for c = 1, 5 do
                    local key = keys[c]
                    local d = r.dots[c]
                    d.wrap:ClearAnchors()
                    d.wrap:SetAnchor(LEFT, r.row, LEFT, x0 + (c - 1) * COL_W + 10, 0)
                    d.wrap:SetHidden(false)
                    if d.glow then d.glow:SetHidden(true) end
                    if d.ring then d.ring:SetHidden(true) end
                    if key == "off" then
                        d.fill:SetHidden(true)
                    else
                        local has = HasEffect(tags[i], key)
                        if key == "prayer" then
                            has = HasPrayer(tags[i])
                        elseif key == "vigor" or key == "echoingVigor" or key == "resolvingVigor" then
                            has = HasEffect(tags[i], "vigor")
                                or HasEffect(tags[i], "echoingVigor")
                                or HasEffect(tags[i], "resolvingVigor")
                        end
                        d.fill:SetHidden(false)
                        if has then
                            local rgb = T.ColumnColor and T.ColumnColor(c) or COL_HEAL
                            if d.fill.SetCenterColor then
                                d.fill:SetCenterColor(rgb[1], rgb[2], rgb[3], 1)
                            else
                                d.fill:SetColor(rgb[1], rgb[2], rgb[3], 1)
                            end
                        else
                            if d.fill.SetCenterColor then
                                d.fill:SetCenterColor(0, 0, 0, 0.45)
                            else
                                d.fill:SetColor(0, 0, 0, 0.45)
                            end
                        end
                    end
                end
                r.row:SetHidden(false)
            end
        end
    end
    for i = rowI + 1, #hudRows do
        hudRows[i].row:SetHidden(true)
    end
    if root then
        if hudCover then hudCover:SetHidden(true) end
        if hudBarBg then hudBarBg:SetHidden(true) end
        if hudBarFill then hudBarFill:SetHidden(true) end
        if hudAlert then hudAlert:SetHidden(true) end
        root:SetDimensions(NAME_W + 24 + 5 * COL_W, math.max(90, 70 + rowI * ROW_H + 8))
    end
end

local function ScanUnitBuffs(unitTag)
    if type(GetNumBuffs) ~= "function" or type(GetUnitBuffInfo) ~= "function" then
        return
    end
    local okN, n = pcall(GetNumBuffs, unitTag)
    if not okN or not n or n < 1 then return end
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
                SetEffect(unitTag, mapped, true, endMs)
            end
        end
    end
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
        for i = 1, 6 do
            pcall(T.Panels.ScanBoss, "boss" .. i)
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
