KayzarUI = KayzarUI or {}
local KayzarUI = KayzarUI

KayzarUI.UnitFrames = {}
local UF = KayzarUI.UnitFrames
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local sv

local TEX_BG   = "KayzarUI/textures/bg_dark.dds"
local TEX_EDGE = "KayzarUI/textures/border_thin.dds"

------------------------------------------------------------------------
-- SAFE CONTROL
------------------------------------------------------------------------
local function GOC(name, parent, ct)
    local c = _G[name]
    if c then
        c:SetHidden(false)
        c:ClearAnchors()
        if parent then c:SetParent(parent) end
        return c
    end
    return WM:CreateControl(name, parent, ct)
end

local function GOTLW(name)
    local c = _G[name]
    if c then
        c:SetHidden(false)
        c:ClearAnchors()
        return c
    end
    return WM:CreateTopLevelWindow(name)
end

------------------------------------------------------------------------
-- POSITION HELPERS
------------------------------------------------------------------------
local function SavePos(c, prefix)
    sv[prefix .. "X"] = c:GetLeft()
    sv[prefix .. "Y"] = c:GetTop()
end

local function ApplyPos(c, prefix)
    local x = sv[prefix .. "X"]
    local y = sv[prefix .. "Y"]
    if x ~= nil and y ~= nil then
        c:ClearAnchors()
        c:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    end
end

local function GetBarTex()
    return KayzarUI.GetBarTexture()
end

local function AdjustedHeight(base)
    local shape = sv.barShape or "Rectangle"
    if shape == "Thin" then       return math.max(6, zo_floor(base * 0.5))
    elseif shape == "Thick" then  return zo_floor(base * 1.6)
    elseif shape == "Slim" then   return math.max(4, zo_floor(base * 0.35))
    elseif shape == "Extra Thick" then return zo_floor(base * 2.0)
    elseif shape == "Flat Line" then   return math.max(3, zo_floor(base * 0.2))
    elseif shape == "Chunky" then      return zo_floor(base * 1.3)
    end
    return base
end

local function MakeBar(n, p, w, h, a, rT, rP, ox, oy, c)
    local tex = GetBarTex()
    local ah  = AdjustedHeight(h)
    local b   = GOC(n, p, CT_STATUSBAR)
    b:SetDimensions(w, ah)
    b:SetAnchor(a, rT or p, rP or a, ox or 0, oy or 0)
    b:SetMinMax(0, 1)
    b:SetValue(1)
    b:SetTexture(tex)
    b:SetColor(c.r, c.g, c.b, 1)

    local bg = GOC(n .. "B", b, CT_TEXTURE)
    bg:SetAnchorFill()
    bg:SetTexture(tex)
    bg:SetColor(c.r * 0.15, c.g * 0.15, c.b * 0.15, 0.8)
    bg:SetDrawLayer(DL_BACKGROUND)

    local s = KayzarUI.sv
    local t = GOC(n .. "T", b, CT_LABEL)
    t:SetAnchorFill()
    t:SetFont("ZoFontGameSmall")
    t:SetColor(s.textColor.r, s.textColor.g, s.textColor.b, s.textColor.a)
    t:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    t:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    -- Shield overlay for health bars only
    if n == "KP_H" or n == "KT_H" then
        local shieldBar = GOC(n .. "_SHIELD", b, CT_STATUSBAR)
        shieldBar:SetDimensions(w, ah)
        shieldBar:SetAnchor(TOPLEFT, b, TOPLEFT, 0, 0)
        shieldBar:SetMinMax(0, 1)
        shieldBar:SetValue(0)
        shieldBar:SetTexture("KayzarUI/textures/shield_overlay.dds")
        local sc = s.shield or {}
        local shieldCol = sc.color or {r = 0.3, g = 0.7, b = 1, a = 0.55}
        shieldBar:SetColor(shieldCol.r, shieldCol.g, shieldCol.b, shieldCol.a or 0.55)
        shieldBar:SetDrawLayer(DL_OVERLAY)
        shieldBar:SetHidden(true)
        b._shield = shieldBar
    end

    b._bg  = bg
    b._txt = t
    return b
end

------------------------------------------------------------------------
-- DESTROY ALL
------------------------------------------------------------------------
function UF:DestroyAll()
    local frameNames = {
        "KayzarUI_PlayerFrame", "KayzarUI_TargetFrame",
        "KayzarUI_HealthBarFrame", "KayzarUI_MagickaBarFrame",
        "KayzarUI_StaminaBarFrame",
    }
    for _, n in ipairs(frameNames) do
        local f = _G[n]
        if f then f:SetHidden(true) end
    end
    self.pf = nil
    self.tf = nil
    self.pH = nil
    self.pM = nil
    self.pS = nil
    self.tH = nil
    self._pN = nil
    self._pL = nil
    self._pU = nil
    self._tN = nil
    self._tL = nil
    self._tTitle = nil
end

------------------------------------------------------------------------
-- INITIALIZE / BUILD
------------------------------------------------------------------------
function UF:Initialize()
    sv = KayzarUI.sv.unitFrames
    self:HideDefault()
    self:Build()
    self:Reg()
end

function UF:Build()
    sv = KayzarUI.sv.unitFrames
    local s = KayzarUI.sv
    if sv.playerEnabled then self:BP(s) end
    if sv.targetEnabled then self:BT(s) end
end

------------------------------------------------------------------------
-- HIDE DEFAULT FRAMES
------------------------------------------------------------------------
function UF:HideDefault()
    local function kill(c)
        if not c then return end
        c:SetHidden(true)
        c:SetAlpha(0)
        local orig = c.SetHidden
        c.SetHidden = function(self, h)
            if not h then return end
            orig(self, true)
        end
    end
    kill(ZO_PlayerAttribute)
    kill(ZO_PlayerAttributeHealth)
    kill(ZO_PlayerAttributeMagicka)
    kill(ZO_PlayerAttributeStamina)
    kill(ZO_PlayerAttributeSiegeHealth)
    kill(ZO_PlayerAttributeWerewolf)
    kill(ZO_PlayerAttributeMountStamina)

    local function hide(c)
        if c then c:SetHidden(true); c:SetAlpha(0) end
    end
    hide(ZO_TargetUnitFramereticle)
    hide(ZO_BossBar)
end

------------------------------------------------------------------------
-- REBUILD (recolor only, no full recreate)
------------------------------------------------------------------------
function UF:Rebuild()
    local s = KayzarUI.sv
    if self.pf then
        local bg = _G["KP_BG"]
        if bg then
            if sv.showBackground then
                bg:SetHidden(false)
                bg:SetColor(s.frameBgColor.r, s.frameBgColor.g, s.frameBgColor.b, sv.bgOpacity / 100)
            else
                bg:SetHidden(true)
            end
        end
        local e = _G["KP_E"]
        if e then
            if sv.showBorder then
                e:SetHidden(false)
                e:SetColor(s.frameBorderColor.r, s.frameBorderColor.g, s.frameBorderColor.b, s.frameBorderColor.a)
            else
                e:SetHidden(true)
            end
        end
        if self._pN then self._pN:SetColor(s.nameColor.r, s.nameColor.g, s.nameColor.b, 1) end
        if self._pL then self._pL:SetColor(s.levelColor.r, s.levelColor.g, s.levelColor.b, 1) end
        if self._pU then self._pU:SetColor(s.ultimateColor.r, s.ultimateColor.g, s.ultimateColor.b, 1) end
        if self.pH then
            self.pH:SetColor(s.healthColor.r, s.healthColor.g, s.healthColor.b, 1)
            self.pH._bg:SetColor(s.healthColor.r * 0.15, s.healthColor.g * 0.15, s.healthColor.b * 0.15, 0.8)
        end
        if self.pM then
            self.pM:SetColor(s.magickaColor.r, s.magickaColor.g, s.magickaColor.b, 1)
            self.pM._bg:SetColor(s.magickaColor.r * 0.15, s.magickaColor.g * 0.15, s.magickaColor.b * 0.15, 0.8)
        end
        if self.pS then
            self.pS:SetColor(s.staminaColor.r, s.staminaColor.g, s.staminaColor.b, 1)
            self.pS._bg:SetColor(s.staminaColor.r * 0.15, s.staminaColor.g * 0.15, s.staminaColor.b * 0.15, 0.8)
        end
    end
    if self.tf then
        local bg = _G["KT_BG"]
        if bg then
            if sv.showBackground then
                bg:SetHidden(false)
                bg:SetColor(s.frameBgColor.r, s.frameBgColor.g, s.frameBgColor.b, sv.bgOpacity / 100)
            else
                bg:SetHidden(true)
            end
        end
        if self.tH then
            self.tH:SetColor(s.healthColor.r, s.healthColor.g, s.healthColor.b, 1)
            self.tH._bg:SetColor(s.healthColor.r * 0.15, s.healthColor.g * 0.15, s.healthColor.b * 0.15, 0.8)
        end
    end
end

------------------------------------------------------------------------
-- PLAYER FRAME
------------------------------------------------------------------------
function UF:BP(s)
    local el = s.elements or {}
    local W       = sv.barWidth
    local layout  = sv.layoutMode or "Stacked"
    local spacing = sv.barSpacing or 4
    local hH      = AdjustedHeight(sv.healthBarHeight or 22)
    local mH      = AdjustedHeight(sv.magickaBarHeight or 14)
    local sH      = AdjustedHeight(sv.staminaBarHeight or 14)
    local rH      = math.max(mH, sH)
    local hW      = (sv.healthBarWidth or 0) > 0 and sv.healthBarWidth or W
    local mW      = (sv.magickaBarWidth or 0) > 0 and sv.magickaBarWidth or nil
    local sW      = (sv.staminaBarWidth or 0) > 0 and sv.staminaBarWidth or nil
    local nameH   = 18
    local ultH    = 16
    local topPad  = 3
    local sidePad = 10

    local frameW, frameH
    if layout == "Stacked" then
        frameW = W + sidePad * 2; frameH = topPad + nameH + hH + spacing + rH + spacing + ultH
    elseif layout == "Horizontal" then
        frameW = W + sidePad * 2; frameH = topPad + nameH + hH + spacing + ultH
    elseif layout == "Vertical" then
        frameW = W + sidePad * 2; frameH = topPad + nameH + hH + spacing + mH + spacing + sH + spacing + ultH
    elseif layout == "Minimal" then
        frameW = W + sidePad * 2; frameH = topPad + nameH + hH + spacing + 6 + spacing + ultH
    elseif layout == "Pyramid" then
        frameW = W + sidePad * 2; frameH = topPad + nameH + hH + spacing + rH + spacing + ultH
    elseif layout == "Center Stack" then
        frameW = W + sidePad * 2; frameH = topPad + nameH + hH + spacing + mH + spacing + sH + spacing + ultH
    elseif layout == "Wide" then
        frameW = W + sidePad * 2; frameH = topPad + nameH + hH + spacing + rH + spacing + ultH
    elseif layout == "Compact" then
        frameW = W + sidePad * 2; frameH = topPad + nameH + hH + spacing + ultH
    elseif layout == "Diamond" then
        frameW = W + sidePad * 2; frameH = topPad + nameH + hH + spacing + rH + spacing + rH + spacing + ultH
    end

    local f = GOTLW("KayzarUI_PlayerFrame")
    f:SetDimensions(frameW, frameH)
    f:SetAnchor(CENTER, GuiRoot, CENTER, sv.playerOffsetX or 0, sv.playerOffsetY or 200)
    ApplyPos(f, "playerPos")
    f:SetMovable(not s.lockFrames)
    f:SetMouseEnabled(true)
    f:SetClampedToScreen(true)
    f:SetHidden(false)

    local bg = GOC("KP_BG", f, CT_TEXTURE)
    bg:SetAnchorFill()
    bg:SetTexture(TEX_BG)
    if sv.showBackground then
        bg:SetColor(s.frameBgColor.r, s.frameBgColor.g, s.frameBgColor.b, sv.bgOpacity / 100)
        bg:SetHidden(false)
    else
        bg:SetHidden(true)
    end

    local e = GOC("KP_E", f, CT_TEXTURE)
    e:SetAnchorFill()
    e:SetTexture(TEX_EDGE)
    if sv.showBorder then
        e:SetColor(s.frameBorderColor.r, s.frameBorderColor.g, s.frameBorderColor.b, s.frameBorderColor.a)
        e:SetHidden(false)
    else
        e:SetHidden(true)
    end

    self._pN = GOC("KP_N", f, CT_LABEL)
    self._pN:SetDimensions(W * 0.65, nameH)
    self._pN:SetAnchor(TOPLEFT, f, TOPLEFT, sidePad, topPad)
    self._pN:SetFont("ZoFontGameBold")
    self._pN:SetColor(s.nameColor.r, s.nameColor.g, s.nameColor.b, 1)
    self._pN:SetHidden(el.playerName == false)

    self._pL = GOC("KP_L", f, CT_LABEL)
    self._pL:SetDimensions(W * 0.35, nameH)
    self._pL:SetAnchor(TOPRIGHT, f, TOPRIGHT, -sidePad, topPad)
    self._pL:SetFont("ZoFontGameSmall")
    self._pL:SetColor(s.levelColor.r, s.levelColor.g, s.levelColor.b, 1)
    self._pL:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    self._pL:SetHidden(el.playerLevel == false)

    local barTop = topPad + nameH

    if sv.independentBars then
        self:BuildIndependentBars(s, hW, mW, sW, hH, mH, sH)
    else
        for _, n in ipairs({"KayzarUI_HealthBarFrame", "KayzarUI_MagickaBarFrame", "KayzarUI_StaminaBarFrame"}) do
            local bf = _G[n]
            if bf then bf:SetHidden(true) end
        end
        if layout == "Stacked" then
            self.pH = MakeBar("KP_H", f, hW, sv.healthBarHeight, TOPLEFT, f, TOPLEFT, sidePad, barTop, s.healthColor)
            local hw = zo_floor((W - spacing) / 2)
            self.pM = MakeBar("KP_M", f, mW or hw, sv.magickaBarHeight, TOPLEFT, f, TOPLEFT, sidePad, barTop + hH + spacing, s.magickaColor)
            self.pS = MakeBar("KP_S", f, sW or hw, sv.staminaBarHeight, TOPRIGHT, f, TOPRIGHT, -sidePad, barTop + hH + spacing, s.staminaColor)
        elseif layout == "Horizontal" then
            local bw = zo_floor((W - spacing * 2) / 3)
            self.pH = MakeBar("KP_H", f, bw, sv.healthBarHeight, TOPLEFT, f, TOPLEFT, sidePad, barTop, s.healthColor)
            self.pM = MakeBar("KP_M", f, mW or bw, sv.magickaBarHeight, TOPLEFT, f, TOPLEFT, sidePad + bw + spacing, barTop, s.magickaColor)
            self.pS = MakeBar("KP_S", f, sW or bw, sv.staminaBarHeight, TOPLEFT, f, TOPLEFT, sidePad + (bw + spacing) * 2, barTop, s.staminaColor)
        elseif layout == "Vertical" then
            self.pH = MakeBar("KP_H", f, hW, sv.healthBarHeight, TOPLEFT, f, TOPLEFT, sidePad, barTop, s.healthColor)
            self.pM = MakeBar("KP_M", f, mW or W, sv.magickaBarHeight, TOPLEFT, f, TOPLEFT, sidePad, barTop + hH + spacing, s.magickaColor)
            self.pS = MakeBar("KP_S", f, sW or W, sv.staminaBarHeight, TOPLEFT, f, TOPLEFT, sidePad, barTop + hH + spacing + mH + spacing, s.staminaColor)
        elseif layout == "Minimal" then
            self.pH = MakeBar("KP_H", f, hW, sv.healthBarHeight, TOPLEFT, f, TOPLEFT, sidePad, barTop, s.healthColor)
            local hw = zo_floor((W - spacing) / 2)
            self.pM = MakeBar("KP_M", f, mW or hw, 6, TOPLEFT, f, TOPLEFT, sidePad, barTop + hH + spacing, s.magickaColor)
            self.pS = MakeBar("KP_S", f, sW or hw, 6, TOPRIGHT, f, TOPRIGHT, -sidePad, barTop + hH + spacing, s.staminaColor)
            if self.pM._txt then self.pM._txt:SetHidden(true) end
            if self.pS._txt then self.pS._txt:SetHidden(true) end
        elseif layout == "Pyramid" then
            self.pH = MakeBar("KP_H", f, hW, sv.healthBarHeight, TOPLEFT, f, TOPLEFT, sidePad, barTop, s.healthColor)
            local rW2 = zo_floor(W * 0.7)
            local ro  = zo_floor((W - rW2) / 2)
            local hw  = zo_floor((rW2 - spacing) / 2)
            self.pM = MakeBar("KP_M", f, mW or hw, sv.magickaBarHeight, TOPLEFT, f, TOPLEFT, sidePad + ro, barTop + hH + spacing, s.magickaColor)
            self.pS = MakeBar("KP_S", f, sW or hw, sv.staminaBarHeight, TOPLEFT, f, TOPLEFT, sidePad + ro + hw + spacing, barTop + hH + spacing, s.staminaColor)
        elseif layout == "Center Stack" then
            self.pH = MakeBar("KP_H", f, hW, sv.healthBarHeight, TOPLEFT, f, TOPLEFT, sidePad, barTop, s.healthColor)
            self.pM = MakeBar("KP_M", f, mW or W, sv.magickaBarHeight, TOPLEFT, f, TOPLEFT, sidePad, barTop + hH + spacing, s.magickaColor)
            self.pS = MakeBar("KP_S", f, sW or W, sv.staminaBarHeight, TOPLEFT, f, TOPLEFT, sidePad, barTop + hH + spacing + mH + spacing, s.staminaColor)
        elseif layout == "Wide" then
            self.pH = MakeBar("KP_H", f, hW, sv.healthBarHeight, TOPLEFT, f, TOPLEFT, sidePad, barTop, s.healthColor)
            local mw2 = mW or zo_floor(W * 0.6 - spacing / 2)
            local sw2 = sW or zo_floor(W * 0.4 - spacing / 2)
            self.pM = MakeBar("KP_M", f, mw2, sv.magickaBarHeight, TOPLEFT, f, TOPLEFT, sidePad, barTop + hH + spacing, s.magickaColor)
            self.pS = MakeBar("KP_S", f, sw2, sv.staminaBarHeight, TOPRIGHT, f, TOPRIGHT, -sidePad, barTop + hH + spacing, s.staminaColor)
        elseif layout == "Compact" then
            self.pH = MakeBar("KP_H", f, hW, sv.healthBarHeight, TOPLEFT, f, TOPLEFT, sidePad, barTop, s.healthColor)
            local hw3 = zo_floor((W - spacing) / 2)
            self.pM = MakeBar("KP_M", f, mW or hw3, 4, BOTTOMLEFT, self.pH, BOTTOMLEFT, 0, 0, s.magickaColor)
            self.pS = MakeBar("KP_S", f, sW or hw3, 4, BOTTOMRIGHT, self.pH, BOTTOMRIGHT, 0, 0, s.staminaColor)
            if self.pM._txt then self.pM._txt:SetHidden(true) end
            if self.pS._txt then self.pS._txt:SetHidden(true) end
        elseif layout == "Diamond" then
            self.pH = MakeBar("KP_H", f, hW, sv.healthBarHeight, TOPLEFT, f, TOPLEFT, sidePad, barTop, s.healthColor)
            local mw3 = mW or zo_floor(W * 0.75)
            local sw3 = sW or zo_floor(W * 0.5)
            local mOff = zo_floor((W - mw3) / 2)
            local sOff = zo_floor((W - sw3) / 2)
            self.pM = MakeBar("KP_M", f, mw3, sv.magickaBarHeight, TOPLEFT, f, TOPLEFT, sidePad + mOff, barTop + hH + spacing, s.magickaColor)
            self.pS = MakeBar("KP_S", f, sw3, sv.staminaBarHeight, TOPLEFT, f, TOPLEFT, sidePad + sOff, barTop + hH + spacing + rH + spacing, s.staminaColor)
        end
    end

    -- Toggle bar visibility
    if self.pH then self.pH:SetHidden(el.healthBar == false); if self.pH._bg then self.pH._bg:SetHidden(el.healthBar == false) end end
    if self.pM then self.pM:SetHidden(el.magickaBar == false); if self.pM._bg then self.pM._bg:SetHidden(el.magickaBar == false) end end
    if self.pS then self.pS:SetHidden(el.staminaBar == false); if self.pS._bg then self.pS._bg:SetHidden(el.staminaBar == false) end end

    -- Ultimate
    self._pU = GOC("KP_U", f, CT_LABEL)
    self._pU:SetDimensions(50, ultH)
    self._pU:SetAnchor(BOTTOMLEFT, f, BOTTOMLEFT, sidePad, -2)
    self._pU:SetFont("ZoFontGameSmall")
    self._pU:SetColor(s.ultimateColor.r, s.ultimateColor.g, s.ultimateColor.b, 1)
    self._pU:SetHidden(el.playerUlt == false)

    f:SetHandler("OnMoveStop", function(c) SavePos(c, "playerPos") end)
    self.pf = f
    self:UP()
end

------------------------------------------------------------------------
-- INDEPENDENT BARS
------------------------------------------------------------------------
function UF:BuildIndependentBars(s, hW, mW, sW, hH, mH, sH)
    local W = sv.barWidth

    local hf = GOTLW("KayzarUI_HealthBarFrame")
    hf:SetDimensions(hW + 4, hH + 4)
    hf:SetAnchor(CENTER, GuiRoot, CENTER, sv.healthOffsetX or 0, sv.healthOffsetY or 180)
    ApplyPos(hf, "healthPos")
    hf:SetMovable(not KayzarUI.sv.lockFrames)
    hf:SetMouseEnabled(true)
    hf:SetClampedToScreen(true)
    self.pH = MakeBar("KP_H", hf, hW, sv.healthBarHeight, CENTER, hf, CENTER, 0, 0, s.healthColor)
    hf:SetHandler("OnMoveStop", function(c) SavePos(c, "healthPos") end)

    local mf = GOTLW("KayzarUI_MagickaBarFrame")
    mf:SetDimensions((mW or zo_floor(W / 2)) + 4, mH + 4)
    mf:SetAnchor(CENTER, GuiRoot, CENTER, sv.magickaOffsetX or -80, sv.magickaOffsetY or 210)
    ApplyPos(mf, "magickaPos")
    mf:SetMovable(not KayzarUI.sv.lockFrames)
    mf:SetMouseEnabled(true)
    mf:SetClampedToScreen(true)
    self.pM = MakeBar("KP_M", mf, mW or zo_floor(W / 2), sv.magickaBarHeight, CENTER, mf, CENTER, 0, 0, s.magickaColor)
    mf:SetHandler("OnMoveStop", function(c) SavePos(c, "magickaPos") end)

    local sf = GOTLW("KayzarUI_StaminaBarFrame")
    sf:SetDimensions((sW or zo_floor(W / 2)) + 4, sH + 4)
    sf:SetAnchor(CENTER, GuiRoot, CENTER, sv.staminaOffsetX or 80, sv.staminaOffsetY or 210)
    ApplyPos(sf, "staminaPos")
    sf:SetMovable(not KayzarUI.sv.lockFrames)
    sf:SetMouseEnabled(true)
    sf:SetClampedToScreen(true)
    self.pS = MakeBar("KP_S", sf, sW or zo_floor(W / 2), sv.staminaBarHeight, CENTER, sf, CENTER, 0, 0, s.staminaColor)
    sf:SetHandler("OnMoveStop", function(c) SavePos(c, "staminaPos") end)
end

------------------------------------------------------------------------
-- PLAYER UPDATE
------------------------------------------------------------------------
function UF:UP()
    if not self.pf then return end
    local s = KayzarUI.sv
    local el = s.elements or {}

    if self._pN and el.playerName ~= false then
        self._pN:SetText(zo_strformat("<<1>>", GetUnitName("player")))
        self._pN:SetHidden(false)
    elseif self._pN then
        self._pN:SetHidden(true)
    end

    if self._pL and el.playerLevel ~= false then
        local cp = GetUnitChampionPoints("player")
        if cp and cp > 0 then
            self._pL:SetText("CP " .. cp)
        else
            self._pL:SetText("Lv " .. GetUnitLevel("player"))
        end
        self._pL:SetHidden(false)
    elseif self._pL then
        self._pL:SetHidden(true)
    end

    if el.healthBar ~= false then  self:UB("player", COMBAT_MECHANIC_FLAGS_HEALTH,  self.pH, s.healthColor) end
    if el.magickaBar ~= false then self:UB("player", COMBAT_MECHANIC_FLAGS_MAGICKA, self.pM, s.magickaColor) end
    if el.staminaBar ~= false then self:UB("player", COMBAT_MECHANIC_FLAGS_STAMINA, self.pS, s.staminaColor) end

    local c, _, m = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_ULTIMATE)
    if self._pU and el.playerUlt ~= false then
        if m and m > 0 then
            self._pU:SetText(zo_floor(c / m * 100) .. "%")
        else
            self._pU:SetText("")
        end
    end
end

------------------------------------------------------------------------
-- BAR UPDATE (shared for player + target health)
------------------------------------------------------------------------
function UF:UB(tag, mech, bar, col)
    if not bar then return end
    local c, _, m = GetUnitPower(tag, mech)
    if not m or m == 0 then return end
    bar:SetColor(col.r, col.g, col.b, 1)
    local p = c / m
    if sv.animateBars then
        KayzarUI.Animation.SmoothBar(bar, c, m, 200)
    else
        bar:SetValue(p)
    end
    if bar._txt then
        local text = KayzarUI.FormatBarText(c, m, p)
        if text ~= "" then
            bar._txt:SetText(text)
            bar._txt:SetHidden(false)
        else
            bar._txt:SetHidden(true)
        end
    end

    -- Shield overlay for health bars
    if mech == COMBAT_MECHANIC_FLAGS_HEALTH and bar._shield then
        local shieldSv = KayzarUI.sv.shield or {}
        if shieldSv.enabled ~= false then
            local shield = 0
            if GetUnitAttributeVisualizerEffectInfo then
                shield = GetUnitAttributeVisualizerEffectInfo(tag, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH) or 0
            end
            if (not shield or shield == 0) and GetUnitShield then
                shield = GetUnitShield(tag) or 0
            end
            if shield and shield > 0 then
                local shieldPct = shield / m
                local isOvershield = (c + shield) > m
                local displayPct = math.min(shieldPct, 1.0)
                bar._shield:SetValue(displayPct)
                if isOvershield then
                    local oc = shieldSv.overshieldColor or {r = 0.9, g = 0.85, b = 0.2, a = 0.65}
                    bar._shield:SetColor(oc.r, oc.g, oc.b, oc.a or 0.65)
                else
                    local sc = shieldSv.color or {r = 0.3, g = 0.7, b = 1, a = 0.55}
                    bar._shield:SetColor(sc.r, sc.g, sc.b, sc.a or 0.55)
                end
                bar._shield:SetHidden(false)
            else
                bar._shield:SetHidden(true)
            end
        else
            bar._shield:SetHidden(true)
        end
    end
end

------------------------------------------------------------------------
-- TARGET FRAME
------------------------------------------------------------------------
function UF:BT(s)
    local el = s.elements or {}
    local W = sv.barWidth
    local hH = AdjustedHeight(sv.healthBarHeight or 22)
    local nameH   = 18
    local titleH  = 18
    local topPad  = 3
    local sidePad = 10
    local totalH  = topPad + nameH + titleH + hH + 6

    local f = GOTLW("KayzarUI_TargetFrame")
    f:SetDimensions(W + sidePad * 2, totalH)
    f:SetAnchor(CENTER, GuiRoot, CENTER, sv.targetOffsetX or 0, sv.targetOffsetY or -150)
    ApplyPos(f, "targetPos")
    f:SetMovable(not s.lockFrames)
    f:SetMouseEnabled(true)
    f:SetClampedToScreen(true)
    f:SetHidden(true)

    local bg = GOC("KT_BG", f, CT_TEXTURE)
    bg:SetAnchorFill()
    bg:SetTexture(TEX_BG)
    if sv.showBackground then
        bg:SetColor(s.frameBgColor.r, s.frameBgColor.g, s.frameBgColor.b, sv.bgOpacity / 100)
        bg:SetHidden(false)
    else
        bg:SetHidden(true)
    end

    local edge = GOC("KT_E", f, CT_TEXTURE)
    edge:SetAnchorFill()
    edge:SetTexture(TEX_EDGE)
    if sv.showBorder then
        edge:SetColor(s.frameBorderColor.r, s.frameBorderColor.g, s.frameBorderColor.b, s.frameBorderColor.a)
        edge:SetHidden(false)
    else
        edge:SetHidden(true)
    end

    -- Line 1: Name
    self._tN = GOC("KT_N", f, CT_LABEL)
    self._tN:SetDimensions(W * 0.65, nameH)
    self._tN:SetAnchor(TOPLEFT, f, TOPLEFT, sidePad, topPad)
    self._tN:SetFont("ZoFontGameBold")
    self._tN:SetColor(s.nameColor.r, s.nameColor.g, s.nameColor.b, 1)
    self._tN:SetHidden(el.targetName == false)

    -- Level/CP
    self._tL = GOC("KT_L", f, CT_LABEL)
    self._tL:SetDimensions(W * 0.35, nameH)
    self._tL:SetAnchor(TOPRIGHT, f, TOPRIGHT, -sidePad, topPad)
    self._tL:SetFont("ZoFontGameSmall")
    self._tL:SetColor(0.7, 0.7, 0.7, 1)
    self._tL:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    self._tL:SetHidden(el.targetLevel == false)

    -- Line 2: Title
    self._tTitle = GOC("KT_TI", f, CT_LABEL)
    self._tTitle:SetDimensions(W, titleH)
    self._tTitle:SetAnchor(TOPLEFT, f, TOPLEFT, sidePad, topPad + nameH)
    self._tTitle:SetFont("ZoFontGameBold")
    self._tTitle:SetColor(s.accentColor.r, s.accentColor.g, s.accentColor.b, 0.85)
    self._tTitle:SetHidden(true)

    -- Health bar
    self.tH = MakeBar("KT_H", f, W, sv.healthBarHeight, TOPLEFT, f, TOPLEFT, sidePad, topPad + nameH + titleH, s.healthColor)
    if el.targetHealth == false then self.tH:SetHidden(true) end

    f:SetHandler("OnMoveStop", function(c) SavePos(c, "targetPos") end)
    self.tf = f
end

function UF:UT()
    if not self.tf then return end
    local ex = DoesUnitExist("reticleover")
    local showAll = KayzarUI.sv.showAllElements

    if showAll then
        self.tf:SetHidden(false)
    else
        self.tf:SetHidden(not ex)
    end

    if not ex and not showAll then return end
    local s = KayzarUI.sv
    local el = s.elements or {}

    if self._tN and el.targetName ~= false then
        self._tN:SetText(KayzarUI.GetFormattedTargetName("reticleover"))
        local r = GetUnitReaction("reticleover")
        if r == UNIT_REACTION_HOSTILE then
            self._tN:SetColor(0.9, 0.2, 0.2, 1)
        elseif r == UNIT_REACTION_FRIENDLY then
            self._tN:SetColor(0.2, 0.8, 0.2, 1)
        else
            self._tN:SetColor(s.nameColor.r, s.nameColor.g, s.nameColor.b, 1)
        end
    end

    if self._tTitle then
        local title = KayzarUI.GetFormattedTargetTitle("reticleover")
        if title ~= "" then
            self._tTitle:SetText(title)
            self._tTitle:SetColor(s.accentColor.r, s.accentColor.g, s.accentColor.b, 0.85)
            self._tTitle:SetHidden(false)
        else
            self._tTitle:SetHidden(true)
        end
    end

    if self._tL and el.targetLevel ~= false then
        local cp = GetUnitChampionPoints("reticleover")
        if cp and cp > 0 then
            self._tL:SetText("CP " .. cp)
        else
            self._tL:SetText("Lv " .. GetUnitLevel("reticleover"))
        end
    end

    if el.targetHealth ~= false then
        self:UB("reticleover", COMBAT_MECHANIC_FLAGS_HEALTH, self.tH, s.healthColor)
    end
end

------------------------------------------------------------------------
-- EVENTS
------------------------------------------------------------------------
function UF:Reg()
    local ns = "KUI"

    -- Unregister old events
    for _, e in ipairs({"PP", "TP"}) do
        EM:UnregisterForEvent(ns .. e, EVENT_POWER_UPDATE)
    end
    EM:UnregisterForEvent(ns .. "RT", EVENT_RETICLE_TARGET_CHANGED)

    -- Player power updates
    EM:RegisterForEvent(ns .. "PP", EVENT_POWER_UPDATE, function() self:UP() end)
    EM:AddFilterForEvent(ns .. "PP", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")

    -- Target power updates
    EM:RegisterForEvent(ns .. "TP", EVENT_POWER_UPDATE, function() self:UT() end)
    EM:AddFilterForEvent(ns .. "TP", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "reticleover")

    -- Target changed
    EM:RegisterForEvent(ns .. "RT", EVENT_RETICLE_TARGET_CHANGED, function() self:UT() end)

    -- Shield update events
    if EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED then
        EM:RegisterForEvent(ns .. "SA", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, function(_, unitTag)
            if unitTag == "player" then self:UP()
            elseif unitTag == "reticleover" then self:UT() end
        end)
        EM:RegisterForEvent(ns .. "SR", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, function(_, unitTag)
            if unitTag == "player" then self:UP()
            elseif unitTag == "reticleover" then self:UT() end
        end)
        EM:RegisterForEvent(ns .. "SU", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, function(_, unitTag)
            if unitTag == "player" then self:UP()
            elseif unitTag == "reticleover" then self:UT() end
        end)
    end
end
