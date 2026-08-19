TeamShadowsBuffs = TeamShadowsBuffs or {}

local TSB = TeamShadowsBuffs
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER

local Tracker = {
    name = "CombatStats",
    updateName = "TSB_CombatStats_Paint",
    eventName = "TSB_CombatStats_Events",
    targetArmor = 18200,
    criticalCeiling = 125,
}

-- Valeurs de jeu, exprimées indépendamment de toute autre extension.
-- Chaque entrée indique la réduction de résistance et/ou le bonus de dégâts
-- critiques qu'un effet actif applique à la cible.
local TARGET_MODIFIERS = {
    [61743]  = { pen = 5948 }, -- Brèche majeure
    [61742]  = { pen = 2974 }, -- Brèche mineure
    [120007] = { pen = 2108 }, -- Écrasement (mannequin)
    [17906]  = { pen = 2108 }, -- Écrasement
    [143808] = { pen = 1000 }, -- Arme de cristal
    [120018] = { pen = 6000 }, -- Alkosh (mannequin)
    [76667]  = { pen = 6000 }, -- Alkosh
    [159288] = { pen = 3541 }, -- Serment écarlate
    [187742] = { pen = 2200 }, -- Entaille runique
    [80866]  = { pen = 2640 }, -- Écaille de tremblement
    [79087]  = { spellPen = 1320 },
    [79090]  = { physicalPen = 1320 },

    [178118] = { pen = 660 },
    [18084]  = { pen = 660 },
    [95136]  = { pen = 660 },
    [95134]  = { pen = 660 },
    [178123] = { pen = 660 },
    [21929]  = { pen = 660 },
    [178127] = { pen = 660 },
    [148801] = { pen = 660 },

    [142610] = { crit = 5 },
    [142653] = { crit = 5 },
    [142652] = { crit = 5 },
    [181606] = { crit = 15 },
    [145975] = { crit = 10 }, -- Fragilité mineure
    [145977] = { crit = 20 }, -- Fragilité majeure
}

local MAGIC_DAMAGE = {
    [DAMAGE_TYPE_MAGIC] = true,
    [DAMAGE_TYPE_FIRE] = true,
    [DAMAGE_TYPE_COLD] = true,
    [DAMAGE_TYPE_SHOCK] = true,
}

local function ReadStat(statId)
    if not statId or not GetPlayerStat then return 0 end
    local ok, value
    if STAT_BONUS_OPTION_APPLY_BONUS then
        ok, value = pcall(GetPlayerStat, statId, STAT_BONUS_OPTION_APPLY_BONUS)
    else
        ok, value = pcall(GetPlayerStat, statId)
    end
    return ok and (tonumber(value) or 0) or 0
end

local function PlayerCriticalDamage()
    local stats = LibCombat and LibCombat.data and LibCombat.data.stats
    local spellCritBonusId = rawget(_G, "LIBCOMBAT_STAT_SPELLCRITBONUS")
    local weaponCritBonusId = rawget(_G, "LIBCOMBAT_STAT_WEAPONCRITBONUS")
    local spellCritBonus = stats and spellCritBonusId and tonumber(stats[spellCritBonusId]) or 0
    local weaponCritBonus = stats and weaponCritBonusId and tonumber(stats[weaponCritBonusId]) or 0
    local libCritBonus = zo_max(spellCritBonus or 0, weaponCritBonus or 0)

    if libCritBonus > 0 then
        return libCritBonus
    end

    if GetAdvancedStatValue and ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_DAMAGE then
        local ok, _, _, valueFromZos = pcall(GetAdvancedStatValue, ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_DAMAGE)
        if ok then
            local data = LibCombat and LibCombat.data or {}
            return 50
                + (tonumber(valueFromZos) or 0)
                + (tonumber(data.backstabber) or 0)
                + (tonumber(data.critBonusMundus) or 0)
        end
    end
    return 50
end

local function PlayerPenetration(isMagical)
    local stats = LibCombat and LibCombat.data and LibCombat.data.stats
    local libStatId = isMagical and rawget(_G, "LIBCOMBAT_STAT_SPELLPENETRATION") or rawget(_G, "LIBCOMBAT_STAT_WEAPONPENETRATION")
    local libValue = stats and libStatId and tonumber(stats[libStatId]) or 0
    if libValue > 0 then return zo_round(libValue) end

    local statId = isMagical and STAT_SPELL_PENETRATION or STAT_PHYSICAL_PENETRATION
    return zo_round(ReadStat(statId))
end

local function IsCriticalResult(result)
    return result == ACTION_RESULT_CRITICAL_DAMAGE
        or result == ACTION_RESULT_DOT_TICK_CRITICAL
        or result == rawget(_G, "ACTION_RESULT_BLOCKED_CRITICAL_VALUE")
end

local function IsDamageResult(result)
    return result == ACTION_RESULT_DAMAGE
        or result == ACTION_RESULT_CRITICAL_DAMAGE
        or result == ACTION_RESULT_DOT_TICK
        or result == ACTION_RESULT_DOT_TICK_CRITICAL
        or result == ACTION_RESULT_BLOCKED_DAMAGE
        or result == rawget(_G, "ACTION_RESULT_BLOCKED_CRITICAL_VALUE")
end

local function IsEffectGainedResult(result)
    return result == ACTION_RESULT_EFFECT_GAINED
        or result == ACTION_RESULT_EFFECT_GAINED_DURATION
end

local function IsEffectFadedResult(result)
    return result == ACTION_RESULT_EFFECT_FADED
end

local function GetColor(vars, key, fallback)
    local c = vars[key] or fallback
    return tonumber(c.r) or fallback.r, tonumber(c.g) or fallback.g, tonumber(c.b) or fallback.b
end

local function ApplyBackdropEdge(backdrop, r, g, b, alpha, thickness)
    thickness = zo_round(tonumber(thickness) or 0)
    alpha = tonumber(alpha) or 0
    if thickness > 0 and alpha > 0 then
        backdrop:SetEdgeColor(r, g, b, alpha)
        backdrop:SetEdgeTexture(nil, 1, 1, thickness, 0)
    else
        backdrop:SetEdgeColor(r, g, b, 0)
        backdrop:SetEdgeTexture(nil, 1, 1, 1, 0)
    end
end

local function MakeCell(parent)
    local cell = WM:CreateControl(nil, parent, CT_CONTROL)
    cell.bg = WM:CreateControl(nil, cell, CT_BACKDROP)
    cell.bg:SetAnchorFill(cell)

    cell.title = WM:CreateControl(nil, cell, CT_LABEL)
    cell.title:SetAnchor(TOPLEFT, cell, TOPLEFT, 4, 4)
    cell.title:SetAnchor(TOPRIGHT, cell, TOPRIGHT, -4, 4)
    cell.title:SetHeight(18)
    cell.title:SetFont("ZoFontGameSmall")
    cell.title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    cell.value = WM:CreateControl(nil, cell, CT_LABEL)
    cell.value:SetAnchor(TOPLEFT, cell.title, BOTTOMLEFT, 0, 2)
    cell.value:SetAnchor(BOTTOMRIGHT, cell, BOTTOMRIGHT, -4, -4)
    cell.value:SetFont("ZoFontGameBold")
    cell.value:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    cell.value:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return cell
end

local function MakeBar(parent)
    local bar = WM:CreateControl(nil, parent, CT_CONTROL)
    bar.bg = WM:CreateControl(nil, bar, CT_BACKDROP)
    bar.bg:SetAnchorFill(bar)
    bar.bg:SetCenterColor(0, 0, 0, 1)
    bar.bg:SetEdgeTexture(nil, 1, 1, 1, 0)

    bar.fill = WM:CreateControl(nil, bar, CT_BACKDROP)
    bar.fill:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, 0)
    bar.fill:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 0, 0)
    bar.fill:SetCenterColor(0.00, 1.00, 0.18, 1)
    bar.fill:SetEdgeTexture(nil, 1, 1, 1, 0)

    bar.border = {}
    for i = 1, 4 do
        bar.border[i] = WM:CreateControl(nil, bar, CT_TEXTURE)
        bar.border[i]:SetColor(0, 0, 0, 1)
    end

    bar.label = WM:CreateControl(nil, bar, CT_LABEL)
    bar.label:SetAnchor(TOPLEFT, bar, TOPLEFT, 14, 0)
    bar.label:SetAnchor(BOTTOMRIGHT, bar, BOTTOMRIGHT, -10, 0)
    bar.label:SetFont("ZoFontGameLarge")
    bar.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    bar.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    bar.label:SetColor(0, 0, 0, 1)
    return bar
end

local function ApplyBarBorder(bar, r, g, b, alpha, thickness)
    thickness = zo_max(zo_round(tonumber(thickness) or 0), 0)
    alpha = tonumber(alpha) or 0
    local top, right, bottom, left = bar.border[1], bar.border[2], bar.border[3], bar.border[4]
    local hidden = thickness <= 0 or alpha <= 0
    for _, line in ipairs(bar.border) do
        line:SetHidden(hidden)
        line:SetColor(r, g, b, alpha)
    end
    if hidden then return end

    top:ClearAnchors()
    top:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, 0)
    top:SetAnchor(TOPRIGHT, bar, TOPRIGHT, 0, 0)
    top:SetHeight(thickness)

    bottom:ClearAnchors()
    bottom:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 0, 0)
    bottom:SetAnchor(BOTTOMRIGHT, bar, BOTTOMRIGHT, 0, 0)
    bottom:SetHeight(thickness)

    left:ClearAnchors()
    left:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, 0)
    left:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 0, 0)
    left:SetWidth(thickness)

    right:ClearAnchors()
    right:SetAnchor(TOPRIGHT, bar, TOPRIGHT, 0, 0)
    right:SetAnchor(BOTTOMRIGHT, bar, BOTTOMRIGHT, 0, 0)
    right:SetWidth(thickness)
end

function Tracker:CreateWindow()
    if self.window then return end
    local win = WM:CreateTopLevelWindow("TeamShadowsBuffsCombatStats")
    win:SetMouseEnabled(true)
    win:SetMovable(true)
    win:SetClampedToScreen(true)
    win:SetHidden(true)
    win.bg = WM:CreateControl(nil, win, CT_BACKDROP)
    win.bg:SetAnchorFill(win)
    win.cells = {}
    for i = 1, 6 do win.cells[i] = MakeCell(win) end
    win.penBar = MakeBar(win)
    win.critBar = MakeBar(win)
    win:SetHandler("OnMoveStop", function(control)
        if not TSB.savedVars then return end
        TSB.savedVars.statsTrackerX = zo_round(control:GetLeft())
        TSB.savedVars.statsTrackerY = zo_round(control:GetTop())
    end)
    self.window = win

    local target = WM:CreateTopLevelWindow("TeamShadowsBuffsTargetCombatStats")
    target:SetMouseEnabled(true)
    target:SetMovable(true)
    target:SetClampedToScreen(true)
    target:SetHidden(true)
    target.bg = WM:CreateControl(nil, target, CT_BACKDROP)
    target.bg:SetAnchorFill(target)
    target.title = WM:CreateControl(nil, target, CT_LABEL)
    target.title:SetFont("ZoFontGameBold")
    target.title:SetText("TAB TARGET")
    target.title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    target.title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    target.cells = {}
    for i = 1, 6 do target.cells[i] = MakeCell(target) end
    target.penBar = MakeBar(target)
    target.critBar = MakeBar(target)
    target:SetHandler("OnMoveStop", function(control)
        if not TSB.savedVars then return end
        TSB.savedVars.targetStatsTrackerX = zo_round(control:GetLeft())
        TSB.savedVars.targetStatsTrackerY = zo_round(control:GetTop())
    end)
    self.targetWindow = target
end

function Tracker:ApplyPosition()
    if not self.window or not TSB.savedVars then return end
    self.window:ClearAnchors()
    self.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        tonumber(TSB.savedVars.statsTrackerX) or 900,
        tonumber(TSB.savedVars.statsTrackerY) or 420)
    if self.targetWindow then
        self.targetWindow:ClearAnchors()
        self.targetWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
            tonumber(TSB.savedVars.targetStatsTrackerX) or 900,
            tonumber(TSB.savedVars.targetStatsTrackerY) or 530)
    end
end

function Tracker:ApplyTargetAppearance()
    local win = self.targetWindow
    if not win then return end
    local v = self.savedVars or {}
    local mode = v.displayMode == "cells" and "cells" or "bars"
    win:SetScale(tonumber(v.scale) or 1)

    if mode == "cells" then
        local cellWidth, cellHeight, gap, padding = 116, 50, 2, 4
        local width = padding * 2 + cellWidth * 3 + gap * 2
        win:SetDimensions(width, padding * 2 + cellHeight * 2 + gap)
        local fr, fg, fb = GetColor(v, "frameColor", {r=0,g=0,b=0})
        local br, bg, bb = GetColor(v, "borderColor", {r=0.86,g=0.72,b=0.32})
        local borderAlpha = tonumber(v.borderAlpha) or 0.95
        local thickness = v.borderEnabled == false and 0 or zo_round(tonumber(v.borderThickness) or 2)
        win.bg:SetCenterColor(fr, fg, fb, tonumber(v.frameAlpha) or 0.82)
        ApplyBackdropEdge(win.bg, br, bg, bb, borderAlpha, thickness)
        local cr, cg, cb = GetColor(v, "cellColor", {r=0.04,g=0.04,b=0.04})
        local lr, lg, lb = GetColor(v, "labelColor", {r=0.75,g=0.75,b=0.75})
        for i, cell in ipairs(win.cells) do
            local column = (i - 1) % 3
            local row = math.floor((i - 1) / 3)
            cell:ClearAnchors()
            cell:SetDimensions(cellWidth, cellHeight)
            cell:SetAnchor(TOPLEFT, win, TOPLEFT, padding + column * (cellWidth + gap), padding + row * (cellHeight + gap))
            cell.bg:SetCenterColor(cr, cg, cb, tonumber(v.cellAlpha) or 0.92)
            ApplyBackdropEdge(cell.bg, br, bg, bb, borderAlpha, thickness > 0 and 1 or 0)
            cell.title:SetColor(lr, lg, lb, tonumber(v.textAlpha) or 1)
            cell.title:SetHidden(v.showLabels == false)
            cell:SetHidden(false)
        end
        win.penBar:SetHidden(true)
        win.critBar:SetHidden(true)
    else
        local width, barHeight = 238, 44
        win:SetDimensions(width, barHeight * 2)
        win.bg:SetCenterColor(0, 0, 0, tonumber(v.frameAlpha) or 0)
        ApplyBackdropEdge(win.bg, 0, 0, 0, 0, 0)
        for _, cell in ipairs(win.cells) do cell:SetHidden(true) end
        local pr, pg, pb = GetColor(v, "penBarColor", {r=0.00,g=1.00,b=0.18})
        local br, bg, bb = GetColor(v, "borderColor", {r=0,g=0,b=0})
        local borderAlpha = tonumber(v.borderAlpha) or 1
        local thickness = v.borderEnabled == false and 0 or zo_round(tonumber(v.borderThickness) or 2)
        local barAlpha = tonumber(v.cellAlpha) or 1
        for index, bar in ipairs({ win.penBar, win.critBar }) do
            bar:ClearAnchors()
            bar:SetDimensions(width, barHeight)
            bar:SetAnchor(TOPLEFT, win, TOPLEFT, 0, (index - 1) * barHeight)
            bar.color = { pr, pg, pb, barAlpha }
            bar.bg:SetCenterColor(0, 0, 0, barAlpha)
            ApplyBarBorder(bar, br, bg, bb, borderAlpha, thickness)
            bar.label:SetColor(0, 0, 0, tonumber(v.textAlpha) or 1)
            bar.label:SetHidden(false)
            bar:SetHidden(false)
        end
    end

    win.title:ClearAnchors()
    win.title:SetAnchorFill(win)
    win.title:SetFont("ZoFontWinH2")
    win.title:SetDrawLayer(DL_OVERLAY)
    win.title:SetDrawLevel(20)
    win.title:SetColor(0.85, 0.90, 0.95, 0.16 * (tonumber(v.textAlpha) or 1))
end

function Tracker:ApplyAppearance()
    if not self.window then return end
    local v = self.savedVars or {}
    local mode = v.displayMode or "bars"
    if mode ~= "cells" then mode = "bars" end

    if mode == "cells" then
        local cellWidth, cellHeight, gap, padding = 116, 50, 2, 4
        self.window:SetDimensions(padding * 2 + cellWidth * 3 + gap * 2, padding * 2 + cellHeight * 2 + gap)
        self.window:SetScale(tonumber(v.scale) or 1)

        local fr, fg, fb = GetColor(v, "frameColor", {r=0,g=0,b=0})
        local br, bg, bb = GetColor(v, "borderColor", {r=0.86,g=0.72,b=0.32})
        local borderAlpha = tonumber(v.borderAlpha) or 0.95
        local thickness = v.borderEnabled == false and 0 or zo_round(tonumber(v.borderThickness) or 2)
        self.window.bg:SetCenterColor(fr, fg, fb, tonumber(v.frameAlpha) or 0.82)
        ApplyBackdropEdge(self.window.bg, br, bg, bb, borderAlpha, thickness)

        local cr, cg, cb = GetColor(v, "cellColor", {r=0.04,g=0.04,b=0.04})
        local lr, lg, lb = GetColor(v, "labelColor", {r=0.75,g=0.75,b=0.75})
        for i, cell in ipairs(self.window.cells) do
            local column = (i - 1) % 3
            local row = math.floor((i - 1) / 3)
            cell:ClearAnchors()
            cell:SetDimensions(cellWidth, cellHeight)
            cell:SetAnchor(TOPLEFT, self.window, TOPLEFT, padding + column * (cellWidth + gap), padding + row * (cellHeight + gap))
            cell.bg:SetCenterColor(cr, cg, cb, tonumber(v.cellAlpha) or 0.92)
            local inner = thickness > 0 and 1 or 0
            ApplyBackdropEdge(cell.bg, br, bg, bb, borderAlpha, inner)
            cell.title:SetColor(lr, lg, lb, tonumber(v.textAlpha) or 1)
            cell.title:SetHidden(v.showLabels == false)
            cell:SetHidden(false)
        end
        self.window.penBar:SetHidden(true)
        self.window.critBar:SetHidden(true)
        return
    end

    local barWidth, barHeight, gap = 238, 44, 0
    self.window:SetDimensions(barWidth, barHeight * 2 + gap)
    self.window:SetScale(tonumber(v.scale) or 1)

    self.window.bg:SetCenterColor(0, 0, 0, tonumber(v.frameAlpha) or 0)
    ApplyBackdropEdge(self.window.bg, 0, 0, 0, 0, 0)

    for _, cell in ipairs(self.window.cells) do
        cell:SetHidden(true)
    end

    local pr, pg, pb = GetColor(v, "penBarColor", {r=0.00,g=1.00,b=0.18})
    local br, bg, bb = GetColor(v, "borderColor", {r=0,g=0,b=0})
    local borderAlpha = tonumber(v.borderAlpha) or 1
    local borderThickness = v.borderEnabled == false and 0 or zo_round(tonumber(v.borderThickness) or 2)
    local barAlpha = tonumber(v.cellAlpha) or 1

    local pen = self.window.penBar
    pen:SetHidden(false)
    pen:ClearAnchors()
    pen:SetDimensions(barWidth, barHeight)
    pen:SetAnchor(TOPLEFT, self.window, TOPLEFT, 0, 0)
    pen.color = { pr, pg, pb, barAlpha }
    pen.bg:SetCenterColor(0, 0, 0, barAlpha)
    ApplyBarBorder(pen, br, bg, bb, borderAlpha, borderThickness)

    local crit = self.window.critBar
    crit:SetHidden(false)
    crit:ClearAnchors()
    crit:SetDimensions(barWidth, barHeight)
    crit:SetAnchor(TOPLEFT, self.window, TOPLEFT, 0, barHeight + gap)
    crit.color = { pr, pg, pb, barAlpha }
    crit.bg:SetCenterColor(0, 0, 0, barAlpha)
    ApplyBarBorder(crit, br, bg, bb, borderAlpha, borderThickness)

    for _, bar in ipairs({ pen, crit }) do
        bar.label:SetColor(0, 0, 0, tonumber(v.textAlpha) or 1)
        bar.label:SetHidden(false)
    end
end

local function ValueState(value, cap)
    return value >= cap and "normal" or "low"
end

local function PaintCell(module, cell, title, text, state)
    local v = module.savedVars or {}
    cell.title:SetText(title)
    cell.value:SetText(text)
    local key = state == "low" and "lowColor" or "normalColor"
    local fallback = state == "low" and {r=0.95,g=0.30,b=0.20} or {r=0.35,g=0.90,b=0.45}
    local r, g, b = GetColor(v, key, fallback)
    cell.value:SetColor(r, g, b, tonumber(v.textAlpha) or 1)
end

local function BlendColor(ar, ag, ab, br, bg, bb, ratio)
    ratio = zo_min(zo_max(ratio or 0, 0), 1)
    return ar + (br - ar) * ratio, ag + (bg - ag) * ratio, ab + (bb - ab) * ratio
end

local function PaintBar(bar, text, value, cap)
    bar.label:SetText(text)
    local greenR, greenG, greenB, alpha = unpack(bar.color or { 0.00, 1.00, 0.18, 1 })
    local darkRedR, darkRedG, darkRedB = 0.04, 0.00, 0.00
    local lightRedR, lightRedG, lightRedB = 1.00, 0.38, 0.32
    local ratio = (cap > 0) and zo_min(zo_max((tonumber(value) or 0) / cap, 0), 1) or 0
    local r, g, b

    if ratio >= 1 then
        r, g, b = greenR, greenG, greenB
    else
        r, g, b = BlendColor(darkRedR, darkRedG, darkRedB, lightRedR, lightRedG, lightRedB, math.sqrt(ratio))
    end

    bar.fill:SetHidden(false)
    bar.fill:ClearAnchors()
    bar.fill:SetAnchorFill(bar)
    bar.fill:SetCenterColor(r, g, b, alpha)
end

function Tracker:ResetFightSamples()
    self.penMin, self.penCurrent, self.penMax = nil, nil, nil
    self.critMin, self.critCurrent, self.critMax = nil, nil, nil
end

function Tracker:RecordPenetration(value)
    value = zo_min(zo_max(zo_round(value or 0), 0), self.targetArmor)
    self.penCurrent = value
    self.penMin = self.penMin and zo_min(self.penMin, value) or value
    self.penMax = self.penMax and zo_max(self.penMax, value) or value
end

function Tracker:RecordCritical(value)
    value = zo_max(tonumber(value) or 0, 0)
    self.critCurrent = value
    self.critMin = self.critMin and zo_min(self.critMin, value) or value
    self.critMax = self.critMax and zo_max(self.critMax, value) or value
end

function Tracker:RecordPlayerBaseline()
    self:RecordPenetration(zo_max(PlayerPenetration(true), PlayerPenetration(false)))
    self:RecordCritical(PlayerCriticalDamage())
end

function Tracker:AddModifiersFromEffects(effects, isMagical, counted)
    if not effects then return 0, 0 end
    local pen, crit = 0, 0
    for abilityId in pairs(effects) do
        -- Le meme debuff peut etre vu via reticleover puis via l'id numerique.
        if not counted[abilityId] then
            counted[abilityId] = true
            local modifier = TARGET_MODIFIERS[abilityId]
            if modifier then
                pen = pen + (modifier.pen or 0)
                pen = pen + (isMagical and (modifier.spellPen or 0) or (modifier.physicalPen or 0))
                crit = crit + (modifier.crit or 0)
            end
        end
    end
    return pen, crit
end

function Tracker:ModifiersForTarget(unitId, isMagical)
    local pen, crit = 0, 0
    local counted = {}
    local addPen, addCrit = self:AddModifiersFromEffects(self.targetEffects[unitId], isMagical, counted)
    pen, crit = pen + addPen, crit + addCrit

    addPen, addCrit = self:AddModifiersFromEffects(self.targetEffects.reticleover, isMagical, counted)
    pen, crit = pen + addPen, crit + addCrit

    addPen, addCrit = self:AddModifiersFromEffects(self.targetEffects.currentTarget, isMagical, counted)
    pen, crit = pen + addPen, crit + addCrit

    return pen, crit
end

function Tracker:RebuildCurrentTargetEffects()
    local effects = self.targetEffects.currentTarget
    if not effects then
        effects = {}
        self.targetEffects.currentTarget = effects
    end
    for abilityId in pairs(TARGET_MODIFIERS) do
        local active = false
        if GetUnitBuffInfo then
            active = active or self:UnitHasAbility("reticleover", abilityId)
        end
        if GetUnitDebuffInfo then
            active = active or self:UnitHasAbility("reticleover", abilityId, true)
        end
        effects[abilityId] = active or nil
    end
end

function Tracker:UnitHasAbility(unitTag, abilityId, debuff)
    local getter = debuff and GetUnitDebuffInfo or GetUnitBuffInfo
    if not getter or not DoesUnitExist or not DoesUnitExist(unitTag) then return false end

    local index = 1
    while true do
        local name, _, _, _, _, _, _, _, _, _, buffAbilityId = getter(unitTag, index)
        if not name or name == "" then return false end
        if buffAbilityId == abilityId then return true end
        index = index + 1
    end
end

function Tracker:EffectsForUnit(unitId)
    if not unitId or unitId == 0 then
        return self.targetEffects.currentTarget
    end
    if unitId == "reticleover" then
        return self.targetEffects.reticleover
    end
    local effects = self.targetEffects[unitId]
    if not effects then
        effects = {}
        self.targetEffects[unitId] = effects
    end
    return effects
end

function Tracker:HandleEffect(changeType, unitId, abilityId)
    if not unitId or unitId == 0 or not TARGET_MODIFIERS[abilityId] then return end
    local effects = self:EffectsForUnit(unitId)
    if changeType == EFFECT_RESULT_FADED then
        if effects then
            effects[abilityId] = nil
            if unitId ~= "reticleover" and unitId ~= "currentTarget" and next(effects) == nil then self.targetEffects[unitId] = nil end
        end
        return
    end
    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        if not effects then
            effects = {}
            self.targetEffects[unitId] = effects
        end
        effects[abilityId] = true
    end
end

function Tracker:HandleCombatEffect(result, targetUnitId, abilityId)
    if not targetUnitId or targetUnitId == 0 or not TARGET_MODIFIERS[abilityId] then return end
    if IsEffectFadedResult(result) then
        self:HandleEffect(EFFECT_RESULT_FADED, targetUnitId, abilityId)
    elseif IsEffectGainedResult(result) then
        self:HandleEffect(EFFECT_RESULT_GAINED, targetUnitId, abilityId)
    end
end

function Tracker:HandleDamage(result, sourceType, hitValue, damageType, targetUnitId)
    if not self.inCombat or not IsDamageResult(result) then return end
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER and sourceType ~= COMBAT_UNIT_TYPE_PLAYER_PET then return end
    if (tonumber(hitValue) or 0) <= 0 or not targetUnitId or targetUnitId == 0 then return end

    local magical = MAGIC_DAMAGE[damageType] == true
    self:RebuildCurrentTargetEffects()
    local targetPen, targetCrit = self:ModifiersForTarget(targetUnitId, magical)
    self:RecordPenetration(PlayerPenetration(magical) + targetPen)
    if IsCriticalResult(result) then
        self:RecordCritical(PlayerCriticalDamage() + targetCrit)
    end
    self:Refresh()
end

function Tracker:HandleCombatEvent(result, sourceType, hitValue, damageType, targetUnitId, abilityId)
    self:HandleCombatEffect(result, targetUnitId, abilityId)
    self:HandleDamage(result, sourceType, hitValue, damageType, targetUnitId)
end

function Tracker:BeginCombat()
    self.inCombat = true
    self:ResetFightSamples()
    self:RecordPlayerBaseline()
    self:Refresh()
end

function Tracker:EndCombat()
    self.inCombat = false
    local v = self.savedVars or {}
    if self.penMin then
        v.lastPenMin, v.lastPenCurrent, v.lastPenMax = self.penMin, self.penCurrent, self.penMax
    end
    if self.critMin then
        v.lastCritMin, v.lastCritCurrent, v.lastCritMax = self.critMin, self.critCurrent, self.critMax
    end
    self.targetEffects = {}
    self:Refresh()
end

function Tracker:RefreshTargetPanel()
    local win = self.targetWindow
    if not win or not TSB.savedVars then return end
    local v = self.savedVars or {}
    local preview = TSB.managerTestMode == true
    local hasTarget = DoesUnitExist and DoesUnitExist("reticleover")
    local hostile = hasTarget and (not IsUnitAttackable or IsUnitAttackable("reticleover"))
    if TSB.savedVars.enabled ~= true or v.enabled == false or v.targetEnabled == false or (not preview and not hostile) then
        win:SetHidden(true)
        self.targetSampleKey = nil
        return
    end

    local penCap = tonumber(v.penetrationMax) or self.targetArmor
    local critCap = tonumber(v.criticalMax) or self.criticalCeiling
    if preview then
        self.targetSampleKey = "__preview"
        self.targetPenMin, self.targetPenNow, self.targetPenMax = penCap * 0.65, penCap * 0.85, penCap
        self.targetCritMin, self.targetCritNow, self.targetCritMax = critCap * 0.80, critCap * 0.92, critCap
    else
        local unitId = GetUnitId and GetUnitId("reticleover") or 0
        local unitName = GetUnitName and zo_strformat("<<1>>", GetUnitName("reticleover")) or ""
        local sampleKey = tostring(unitId or 0) .. ":" .. unitName
        if sampleKey ~= self.targetSampleKey then
            self.targetSampleKey = sampleKey
            self.targetPenMin, self.targetPenNow, self.targetPenMax = nil, nil, nil
            self.targetCritMin, self.targetCritNow, self.targetCritMax = nil, nil, nil
        end

        self:RebuildCurrentTargetEffects()
        local magicPen, magicCrit = self:ModifiersForTarget("reticleover", true)
        local physicalPen, physicalCrit = self:ModifiersForTarget("reticleover", false)
        local pen = zo_max(PlayerPenetration(true) + magicPen, PlayerPenetration(false) + physicalPen)
        local crit = PlayerCriticalDamage() + zo_max(magicCrit, physicalCrit)
        pen = zo_min(zo_max(zo_round(pen), 0), penCap)
        crit = zo_max(tonumber(crit) or 0, 0)
        self.targetPenNow = pen
        self.targetPenMin = self.targetPenMin and zo_min(self.targetPenMin, pen) or pen
        self.targetPenMax = self.targetPenMax and zo_max(self.targetPenMax, pen) or pen
        self.targetCritNow = crit
        self.targetCritMin = self.targetCritMin and zo_min(self.targetCritMin, crit) or crit
        self.targetCritMax = self.targetCritMax and zo_max(self.targetCritMax, crit) or crit
    end

    self:ApplyTargetAppearance()
    if v.displayMode == "cells" then
        PaintCell(self, win.cells[1], "PÉNÉ MINI", ZO_CommaDelimitNumber(zo_round(self.targetPenMin)), ValueState(self.targetPenMin, penCap))
        PaintCell(self, win.cells[2], "PÉNÉ ACTUELLE", ZO_CommaDelimitNumber(zo_round(self.targetPenNow)), ValueState(self.targetPenNow, penCap))
        PaintCell(self, win.cells[3], "PÉNÉ MAX", ZO_CommaDelimitNumber(zo_round(self.targetPenMax)), ValueState(self.targetPenMax, penCap))
        PaintCell(self, win.cells[4], "CRIT MINI", string.format("%.1f%%", self.targetCritMin), ValueState(self.targetCritMin, critCap))
        PaintCell(self, win.cells[5], "CRIT ACTUEL", string.format("%.1f%%", self.targetCritNow), ValueState(self.targetCritNow, critCap))
        PaintCell(self, win.cells[6], "CRIT MAX", string.format("%.1f%%", self.targetCritMax), ValueState(self.targetCritMax, critCap))
    else
        PaintBar(win.penBar, string.format("PEN %d", zo_round(self.targetPenNow)), self.targetPenNow, penCap)
        PaintBar(win.critBar, string.format("CRIT %d%%", zo_round(self.targetCritNow)), self.targetCritNow, critCap)
    end
    local unlocked = preview or v.unlocked == true
    win:SetMovable(unlocked)
    win:SetMouseEnabled(unlocked)
    win:SetHidden(false)
end

function Tracker:Refresh()
    if not self.window or not TSB.savedVars then return end
    self:ApplyAppearance()
    local v = self.savedVars or {}
    if not self.penMin then
        self:RecordPlayerBaseline()
    end

    local penMin = self.penMin or tonumber(v.lastPenMin) or 0
    local penNow = self.penCurrent or tonumber(v.lastPenCurrent) or 0
    local penMax = self.penMax or tonumber(v.lastPenMax) or 0
    local critMin = self.critMin or tonumber(v.lastCritMin) or 0
    local critNow = self.critCurrent or tonumber(v.lastCritCurrent) or 0
    local critMax = self.critMax or tonumber(v.lastCritMax) or 0

    local penCap = tonumber(v.penetrationMax) or self.targetArmor
    local critCap = tonumber(v.criticalMax) or self.criticalCeiling

    if (v.displayMode or "bars") ~= "cells" then
        PaintBar(self.window.penBar, string.format("PEN %d", zo_round(penNow)), penNow, penCap)
        PaintBar(self.window.critBar, string.format("CRIT %d%%", zo_round(critNow)), critNow, critCap)
        local unlocked = v.unlocked == true
        self.window:SetMovable(unlocked)
        self.window:SetMouseEnabled(unlocked)
        self.window:SetHidden(TSB.savedVars.enabled ~= true or v.enabled == false)
        self:RefreshTargetPanel()
        return
    end

    PaintCell(self, self.window.cells[1], "PÉNÉ MINI", ZO_CommaDelimitNumber(zo_round(penMin)), ValueState(penMin, penCap))
    PaintCell(self, self.window.cells[2], "PÉNÉ ACTUELLE", ZO_CommaDelimitNumber(zo_round(penNow)), ValueState(penNow, penCap))
    PaintCell(self, self.window.cells[3], "PÉNÉ MAX", ZO_CommaDelimitNumber(zo_round(penMax)), ValueState(penMax, penCap))
    PaintCell(self, self.window.cells[4], "DÉG CRIT MINI", string.format("%.1f%%", critMin), ValueState(critMin, critCap))
    PaintCell(self, self.window.cells[5], "DÉG CRIT ACTUEL", string.format("%.1f%%", critNow), ValueState(critNow, critCap))
    PaintCell(self, self.window.cells[6], "DÉG CRIT MAX", string.format("%.1f%%", critMax), ValueState(critMax, critCap))

    local unlocked = v.unlocked == true
    self.window:SetMovable(unlocked)
    self.window:SetMouseEnabled(unlocked)
    self.window:SetHidden(TSB.savedVars.enabled ~= true or v.enabled == false)
    self:RefreshTargetPanel()
end

function Tracker:Load(savedVars)
    self.savedVars = savedVars or {}
    self.targetEffects = {}
    self:CreateWindow()
    self:ApplyPosition()
    self.inCombat = IsUnitInCombat and IsUnitInCombat("player") or false
    self:ResetFightSamples()
    self:Refresh()

    EM:RegisterForUpdate(self.updateName, 500, function() self:Refresh() end)

    if EVENT_PLAYER_COMBAT_STATE then
        EM:RegisterForEvent(self.eventName, EVENT_PLAYER_COMBAT_STATE, function(_, active)
            if active then self:BeginCombat() else self:EndCombat() end
        end)
    end

    if EVENT_EFFECT_CHANGED then
        EM:RegisterForEvent(self.eventName, EVENT_EFFECT_CHANGED,
            function(_, changeType, _, _, unitTag, _, _, _, _, _, _, _, _, _, unitId, abilityId)
                self:HandleEffect(changeType, unitId or unitTag, abilityId)
            end)
    end

    if EVENT_COMBAT_EVENT then
        EM:RegisterForEvent(self.eventName, EVENT_COMBAT_EVENT,
            function(_, result, _, _, _, _, _, sourceType, _, _, hitValue, _, damageType, _, _, targetUnitId, abilityId)
                self:HandleCombatEvent(result, sourceType, hitValue, damageType, targetUnitId, abilityId)
            end)
    end


    if EVENT_RETICLE_TARGET_CHANGED then
        EM:RegisterForEvent(self.eventName, EVENT_RETICLE_TARGET_CHANGED, function()
            self:RefreshTargetPanel()
        end)
    end
end

function Tracker:Unload()
    EM:UnregisterForUpdate(self.updateName)
    if EVENT_PLAYER_COMBAT_STATE then EM:UnregisterForEvent(self.eventName, EVENT_PLAYER_COMBAT_STATE) end
    if EVENT_EFFECT_CHANGED then EM:UnregisterForEvent(self.eventName, EVENT_EFFECT_CHANGED) end
    if EVENT_COMBAT_EVENT then EM:UnregisterForEvent(self.eventName, EVENT_COMBAT_EVENT) end
    if EVENT_RETICLE_TARGET_CHANGED then EM:UnregisterForEvent(self.eventName, EVENT_RETICLE_TARGET_CHANGED) end
    if self.window then self.window:SetHidden(true) end
    if self.targetWindow then self.targetWindow:SetHidden(true) end
end

TSB.RegisterModule(Tracker)
