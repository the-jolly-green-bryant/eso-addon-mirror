HealingBuffUptime = {}
local HBU = HealingBuffUptime

HBU.name = "HealingBuffUptime"
HBU.version = "0.4.0"
HBU.inCombat = false
HBU.combatStartMs = 0
HBU.combatEndMs = 0
HBU.effectiveHealing = 0
HBU.overhealing = 0
HBU.buffs = {}
HBU.miniRows = {}
HBU.detailRows = {}
HBU.uiSuspended = false
HBU.detailWantedVisible = false
HBU.moveMode = false
HBU.textControls = {}

HBU.defaults = {
    showOtherBuffs = true,
    miniWidth = 500,
    miniHeight = 320,
    fontSize = 18,
    textAlpha = 100,
    miniX = 10,
    miniY = 70,
    detailPositionSaved = false,
    detailX = 0,
    detailY = 0,
    controllerMoveStep = 10,
}

ZO_CreateStringId("SI_BINDING_NAME_HBU_TOGGLE_MOVE_MODE", "Verschiebemodus an/aus")
ZO_CreateStringId("SI_BINDING_NAME_HBU_MOVE_UP", "Buff-Fenster nach oben")
ZO_CreateStringId("SI_BINDING_NAME_HBU_MOVE_DOWN", "Buff-Fenster nach unten")
ZO_CreateStringId("SI_BINDING_NAME_HBU_MOVE_LEFT", "Buff-Fenster nach links")
ZO_CreateStringId("SI_BINDING_NAME_HBU_MOVE_RIGHT", "Buff-Fenster nach rechts")

local HEAL_RESULTS = {
    [ACTION_RESULT_HEAL] = true,
    [ACTION_RESULT_CRITICAL_HEAL] = true,
    [ACTION_RESULT_HOT_TICK] = true,
    [ACTION_RESULT_HOT_TICK_CRITICAL] = true,
}

local ALLOWED_EXACT_BUFFS = {
    ["Berserk"] = true,
    ["Brutality"] = true,
    ["Courage"] = true,
    ["Endurance"] = true,
    ["Evasion"] = true,
    ["Expedition"] = true,
    ["Force"] = true,
    ["Fortitude"] = true,
    ["Heroism"] = true,
    ["Intellect"] = true,
    ["Lifesteal"] = true,
    ["Maim"] = true,
    ["Mending"] = true,
    ["Protection"] = true,
    ["Prophecy"] = true,
    ["Resolve"] = true,
    ["Savagery"] = true,
    ["Slayer"] = true,
    ["Sorcery"] = true,
    ["Toughness"] = true,
    ["Vitality"] = true,
    ["Vulnerability"] = true,
}

local function NowMs()
    return GetGameTimeMilliseconds()
end

local function Clamp(value, minimum, maximum)
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

local function Round(value)
    return math.floor((value or 0) + 0.5)
end

local function SafeText(text)
    return zo_strformat("<<C:1>>", text or "")
end

local function StartsWith(text, prefix)
    return text and prefix and text:sub(1, #prefix) == prefix
end

local function FormatNumber(value)
    value = math.floor(value or 0)
    local formatted = tostring(value)
    while true do
        local replaced, count = formatted:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
        formatted = replaced
        if count == 0 then break end
    end
    return formatted
end

local function FormatDuration(seconds)
    seconds = math.max(0, math.floor(seconds or 0))
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", minutes, secs)
end

function HBU:RegisterTextControl(control, sizeOffset, fontName)
    control.hbuFontSizeOffset = sizeOffset or 0
    control.hbuFontName = fontName or "$(MEDIUM_FONT)"
    table.insert(self.textControls, control)
    self:ApplyTextControlAppearance(control)
end

function HBU:ApplyTextControlAppearance(control)
    if not control then return end
    local baseSize = self.sv and self.sv.fontSize or self.defaults.fontSize
    local alpha = (self.sv and self.sv.textAlpha or self.defaults.textAlpha) / 100
    local size = Clamp(baseSize + (control.hbuFontSizeOffset or 0), 10, 42)
    control:SetFont(string.format("%s|%d|soft-shadow-thick", control.hbuFontName or "$(MEDIUM_FONT)", size))
    control:SetAlpha(alpha)
end

function HBU:ApplyTextAppearance()
    for _, control in ipairs(self.textControls) do
        self:ApplyTextControlAppearance(control)
    end
end

function HBU:GetDefaultIcon()
    return "/esoui/art/icons/ability_warrior_001.dds"
end

function HBU:NormalizeTrackedBuffName(effectName)
    local name = SafeText(effectName)
    if name == "" then return nil end
    if StartsWith(name, "Major ") or StartsWith(name, "Minor ") then
        return name
    end
    if ALLOWED_EXACT_BUFFS[name] then
        return name
    end
    return nil
end

function HBU:ShouldTrackBuff(effectName, beginTime, endTime, effectType)
    if not self.inCombat then return false end
    if effectType ~= BUFF_EFFECT_TYPE_BUFF then return false end
    if not self:NormalizeTrackedBuffName(effectName) then return false end
    local duration = (endTime or 0) - (beginTime or 0)
    if duration <= 0 or duration > 3600 or duration < 0.4 then return false end
    return true
end

function HBU:CreateBuff(displayName, iconName)
    return {
        name = displayName,
        icon = iconName and iconName ~= "" and iconName or self:GetDefaultIcon(),
        instances = {},
        selfActiveMs = 0,
        otherActiveMs = 0,
        totalActiveMs = 0,
        selfRunning = false,
        otherRunning = false,
        totalRunning = false,
        lastUpdateMs = NowMs(),
    }
end

function HBU:AccumulateBuff(buff, nowMs)
    local last = buff.lastUpdateMs or nowMs
    local delta = math.max(0, nowMs - last)
    if delta > 0 then
        if buff.selfRunning then buff.selfActiveMs = buff.selfActiveMs + delta end
        if buff.otherRunning then buff.otherActiveMs = buff.otherActiveMs + delta end
        if buff.totalRunning then buff.totalActiveMs = buff.totalActiveMs + delta end
        buff.lastUpdateMs = nowMs
    end
end

function HBU:RefreshBuffStates(buff)
    local selfActive = false
    local otherActive = false
    for _, instance in pairs(buff.instances) do
        if instance.active then
            if instance.fromSelf then
                selfActive = true
            else
                otherActive = true
            end
        end
    end
    buff.selfRunning = selfActive
    buff.otherRunning = otherActive
    buff.totalRunning = selfActive or otherActive
end

function HBU:GetBuffSnapshot(buff, nowMs, fightMs)
    local last = buff.lastUpdateMs or nowMs
    local delta = math.max(0, nowMs - last)
    local selfMs = buff.selfActiveMs + (buff.selfRunning and delta or 0)
    local otherMs = buff.otherActiveMs + (buff.otherRunning and delta or 0)
    local totalMs = buff.totalActiveMs + (buff.totalRunning and delta or 0)

    local showOtherBuffs = not self.sv or self.sv.showOtherBuffs
    local maxEndTime = 0
    for _, instance in pairs(buff.instances) do
        local sourceIsVisible = instance.fromSelf or showOtherBuffs
        if instance.active and sourceIsVisible and instance.endTime and instance.endTime > maxEndTime then
            maxEndTime = instance.endTime
        end
    end

    local remaining = maxEndTime > 0 and math.max(0, maxEndTime - GetFrameTimeSeconds()) or 0
    local denom = fightMs > 0 and fightMs or 1
    local visibleOtherMs = showOtherBuffs and otherMs or 0
    local visibleTotalMs = showOtherBuffs and totalMs or selfMs
    local visibleActive = showOtherBuffs and buff.totalRunning or buff.selfRunning
    return {
        name = buff.name,
        icon = buff.icon or self:GetDefaultIcon(),
        selfUptime = Clamp(selfMs / denom * 100, 0, 100),
        otherUptime = Clamp(visibleOtherMs / denom * 100, 0, 100),
        totalUptime = Clamp(visibleTotalMs / denom * 100, 0, 100),
        active = visibleActive,
        remaining = remaining,
        visible = showOtherBuffs or selfMs > 0 or buff.selfRunning,
    }
end

function HBU:GetRowColors(isActive)
    if isActive then
        return 0.10, 0.60, 0.18, 0.22, 0.18, 0.90, 0.28, 0.45
    end
    return 0.70, 0.10, 0.10, 0.18, 0.95, 0.20, 0.20, 0.40
end

function HBU:ApplyRowState(backdrop, isActive)
    if not backdrop then return end
    local cr, cg, cb, ca, er, eg, eb, ea = self:GetRowColors(isActive)
    backdrop:SetCenterColor(cr, cg, cb, ca)
    backdrop:SetEdgeColor(er, eg, eb, ea)
end

function HBU:RefreshWindowVisibility()
    if self.miniWindow then
        self.miniWindow:SetHidden(self.uiSuspended)
    end
    if self.detailWindow then
        local shouldShowDetail = self.detailWantedVisible and not self.uiSuspended
        self.detailWindow:SetHidden(not shouldShowDetail)
    end
end

function HBU:OnSceneStateChanged(scene, oldState, newState)
    if newState ~= SCENE_SHOWING and newState ~= SCENE_SHOWN then return end
    local sceneName = nil
    if scene then
        if scene.GetName then
            sceneName = scene:GetName()
        elseif scene.name then
            sceneName = scene.name
        end
    end
    local isHudScene = sceneName == "hud" or sceneName == "hudui"
    self.uiSuspended = not isHudScene
    self:RefreshWindowVisibility()
end

function HBU:GetMiniLayout()
    local width = self.sv and self.sv.miniWidth or self.defaults.miniWidth
    local rowWidth = math.max(350, width - 30)
    return {
        width = width,
        rowLeft = 22,
        rowWidth = rowWidth,
        nameX = 26,
        selfX = Round(rowWidth * 0.479),
        otherX = Round(rowWidth * 0.649),
        totalX = Round(rowWidth * 0.830),
        valueWidth = math.max(48, Round(rowWidth * 0.117)),
        rowHeight = math.max(22, (self.sv and self.sv.fontSize or self.defaults.fontSize) + 4),
    }
end

function HBU:LayoutMiniRow(row)
    if not row then return end
    local layout = self:GetMiniLayout()
    local nameWidth = math.max(90, layout.selfX - layout.nameX - 10)

    row.backdrop:SetDimensions(layout.rowWidth, layout.rowHeight)
    row.icon:SetDimensions(math.min(22, layout.rowHeight - 4), math.min(22, layout.rowHeight - 4))
    row.name:ClearAnchors()
    row.name:SetAnchor(LEFT, row.backdrop, LEFT, layout.nameX, 0)
    row.name:SetDimensions(nameWidth, layout.rowHeight)
    row.self:ClearAnchors()
    row.self:SetAnchor(LEFT, row.backdrop, LEFT, layout.selfX, 0)
    row.self:SetDimensions(layout.valueWidth, layout.rowHeight)
    row.other:ClearAnchors()
    row.other:SetAnchor(LEFT, row.backdrop, LEFT, layout.otherX, 0)
    row.other:SetDimensions(layout.valueWidth, layout.rowHeight)
    row.total:ClearAnchors()
    row.total:SetAnchor(LEFT, row.backdrop, LEFT, layout.totalX, 0)
    row.total:SetDimensions(layout.valueWidth, layout.rowHeight)
end

function HBU:ApplyMiniLayout()
    if not self.miniWindow then return end
    local layout = self:GetMiniLayout()
    self.miniWindow:SetWidth(layout.width)

    local nameWidth = math.max(90, layout.selfX - layout.nameX - 10)
    local headerYTarget = self.miniHps
    local headers = {
        { control = self.miniHeaderName, x = layout.rowLeft + layout.nameX, width = nameWidth, align = TEXT_ALIGN_LEFT },
        { control = self.miniHeaderSelf, x = layout.rowLeft + layout.selfX, width = layout.valueWidth, align = TEXT_ALIGN_RIGHT },
        { control = self.miniHeaderOther, x = layout.rowLeft + layout.otherX, width = layout.valueWidth, align = TEXT_ALIGN_RIGHT },
        { control = self.miniHeaderTotal, x = layout.rowLeft + layout.totalX, width = layout.valueWidth, align = TEXT_ALIGN_RIGHT },
    }
    for _, header in ipairs(headers) do
        header.control:ClearAnchors()
        header.control:SetAnchor(TOPLEFT, headerYTarget, BOTTOMLEFT, header.x, 6)
        header.control:SetDimensions(header.width, 20)
        header.control:SetHorizontalAlignment(header.align)
    end

    for index, row in ipairs(self.miniRows) do
        row.backdrop:ClearAnchors()
        if index == 1 then
            row.backdrop:SetAnchor(TOPLEFT, self.miniHeaderName, BOTTOMLEFT, -layout.nameX, 5)
        else
            row.backdrop:SetAnchor(TOPLEFT, self.miniRows[index - 1].backdrop, BOTTOMLEFT, 0, 3)
        end
        self:LayoutMiniRow(row)
    end

    self:UpdateMiniWindowHeight(self.lastVisibleBuffCount or 0)
end

function HBU:ApplyOtherBuffVisibility()
    if not self.miniHeaderOther then return end
    local hidden = self.sv and not self.sv.showOtherBuffs
    self.miniHeaderOther:SetHidden(hidden)
    self.detailHeaderOther:SetHidden(hidden)
    for _, row in ipairs(self.miniRows) do row.other:SetHidden(hidden) end
    for _, row in ipairs(self.detailRows) do row.other:SetHidden(hidden) end
end

function HBU:EnsureMiniRow(index)
    if self.miniRows[index] then return end
    local wm = WINDOW_MANAGER
    local layout = self:GetMiniLayout()
    local row = {}
    row.backdrop = wm:CreateControl("HealingBuffUptimeMiniRowBackdrop" .. index, self.miniWindow, CT_BACKDROP)
    if index == 1 then
        row.backdrop:SetAnchor(TOPLEFT, self.miniHeaderName, BOTTOMLEFT, -layout.nameX, 5)
    else
        row.backdrop:SetAnchor(TOPLEFT, self.miniRows[index - 1].backdrop, BOTTOMLEFT, 0, 3)
    end
    row.backdrop:SetDimensions(layout.rowWidth, layout.rowHeight)
    row.backdrop:SetCenterColor(0.70, 0.10, 0.10, 0.18)
    row.backdrop:SetEdgeColor(0.95, 0.20, 0.20, 0.40)
    row.backdrop:SetEdgeTexture("", 2, 2, 1)

    row.icon = wm:CreateControl("HealingBuffUptimeMiniIcon" .. index, self.miniWindow, CT_TEXTURE)
    row.icon:SetAnchor(LEFT, row.backdrop, LEFT, 3, 0)
    row.icon:SetDimensions(18, 18)
    row.icon:SetTexture(self:GetDefaultIcon())

    row.name = wm:CreateControl("HealingBuffUptimeMiniName" .. index, self.miniWindow, CT_LABEL)
    row.name:SetAnchor(LEFT, row.backdrop, LEFT, 26, 0)
    row.name:SetDimensions(185, 20)
    row.name:SetFont("$(MEDIUM_FONT)|18|soft-shadow-thick")
    row.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row.name:SetText(string.format("%d. -", index))

    row.self = wm:CreateControl("HealingBuffUptimeMiniSelf" .. index, self.miniWindow, CT_LABEL)
    row.self:SetAnchor(LEFT, row.backdrop, LEFT, 225, 0)
    row.self:SetDimensions(55, 20)
    row.self:SetFont("$(MEDIUM_FONT)|18|soft-shadow-thick")
    row.self:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.self:SetText("0.0%")

    row.other = wm:CreateControl("HealingBuffUptimeMiniOther" .. index, self.miniWindow, CT_LABEL)
    row.other:SetAnchor(LEFT, row.backdrop, LEFT, 305, 0)
    row.other:SetDimensions(55, 20)
    row.other:SetFont("$(MEDIUM_FONT)|18|soft-shadow-thick")
    row.other:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.other:SetText("0.0%")

    row.total = wm:CreateControl("HealingBuffUptimeMiniTotal" .. index, self.miniWindow, CT_LABEL)
    row.total:SetAnchor(LEFT, row.backdrop, LEFT, 390, 0)
    row.total:SetDimensions(60, 20)
    row.total:SetFont("$(MEDIUM_FONT)|18|soft-shadow-thick")
    row.total:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.total:SetText("0.0%")

    self.miniRows[index] = row
    self:RegisterTextControl(row.name, 0, "$(MEDIUM_FONT)")
    self:RegisterTextControl(row.self, 0, "$(MEDIUM_FONT)")
    self:RegisterTextControl(row.other, 0, "$(MEDIUM_FONT)")
    self:RegisterTextControl(row.total, 0, "$(MEDIUM_FONT)")
    self:LayoutMiniRow(row)
end

function HBU:EnsureDetailRow(index)
    if self.detailRows[index] then return end
    local wm = WINDOW_MANAGER
    local row = {}
    row.backdrop = wm:CreateControl("HealingBuffUptimeDetailRowBackdrop" .. index, self.detailWindow, CT_BACKDROP)
    if index == 1 then
        row.backdrop:SetAnchor(TOPLEFT, self.detailHeaderName, BOTTOMLEFT, -4, 6)
    else
        row.backdrop:SetAnchor(TOPLEFT, self.detailRows[index - 1].backdrop, BOTTOMLEFT, 0, 4)
    end
    row.backdrop:SetDimensions(800, 26)
    row.backdrop:SetCenterColor(0.70, 0.10, 0.10, 0.18)
    row.backdrop:SetEdgeColor(0.95, 0.20, 0.20, 0.40)
    row.backdrop:SetEdgeTexture("", 2, 2, 1)

    row.icon = wm:CreateControl("HealingBuffUptimeDetailIcon" .. index, self.detailWindow, CT_TEXTURE)
    row.icon:SetAnchor(LEFT, row.backdrop, LEFT, 4, 0)
    row.icon:SetDimensions(22, 22)
    row.icon:SetTexture(self:GetDefaultIcon())

    row.name = wm:CreateControl("HealingBuffUptimeDetailName" .. index, self.detailWindow, CT_LABEL)
    row.name:SetAnchor(LEFT, row.backdrop, LEFT, 30, 0)
    row.name:SetDimensions(260, 24)
    row.name:SetFont("$(MEDIUM_FONT)|19|soft-shadow-thick")
    row.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row.name:SetText(string.format("%d. -", index))

    row.self = wm:CreateControl("HealingBuffUptimeDetailSelf" .. index, self.detailWindow, CT_LABEL)
    row.self:SetAnchor(LEFT, row.backdrop, LEFT, 330, 0)
    row.self:SetDimensions(60, 24)
    row.self:SetFont("$(MEDIUM_FONT)|19|soft-shadow-thick")
    row.self:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.self:SetText("0.0%")

    row.other = wm:CreateControl("HealingBuffUptimeDetailOther" .. index, self.detailWindow, CT_LABEL)
    row.other:SetAnchor(LEFT, row.backdrop, LEFT, 430, 0)
    row.other:SetDimensions(60, 24)
    row.other:SetFont("$(MEDIUM_FONT)|19|soft-shadow-thick")
    row.other:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.other:SetText("0.0%")

    row.total = wm:CreateControl("HealingBuffUptimeDetailTotal" .. index, self.detailWindow, CT_LABEL)
    row.total:SetAnchor(LEFT, row.backdrop, LEFT, 530, 0)
    row.total:SetDimensions(60, 24)
    row.total:SetFont("$(MEDIUM_FONT)|19|soft-shadow-thick")
    row.total:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.total:SetText("0.0%")

    row.state = wm:CreateControl("HealingBuffUptimeDetailState" .. index, self.detailWindow, CT_LABEL)
    row.state:SetAnchor(LEFT, row.backdrop, LEFT, 650, 0)
    row.state:SetDimensions(120, 24)
    row.state:SetFont("$(MEDIUM_FONT)|18|soft-shadow-thick")
    row.state:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row.state:SetText("fehlt")

    self.detailRows[index] = row
    self:RegisterTextControl(row.name, 1, "$(MEDIUM_FONT)")
    self:RegisterTextControl(row.self, 1, "$(MEDIUM_FONT)")
    self:RegisterTextControl(row.other, 1, "$(MEDIUM_FONT)")
    self:RegisterTextControl(row.total, 1, "$(MEDIUM_FONT)")
    self:RegisterTextControl(row.state, 0, "$(MEDIUM_FONT)")
end

function HBU:UpdateMiniWindowHeight(visibleCount)
    local count = math.max(visibleCount, 1)
    local layout = self:GetMiniLayout()
    local contentHeight = 110 + count * (layout.rowHeight + 3)
    local minimumHeight = self.sv and self.sv.miniHeight or self.defaults.miniHeight
    self.miniWindow:SetDimensions(layout.width, math.max(minimumHeight, contentHeight))
end

function HBU:UpdateDetailWindowHeight(visibleCount)
    local count = math.max(visibleCount, 10)
    local height = 210 + count * 30
    self.detailWindow:SetDimensions(860, height)
    self.detailBackdrop:SetDimensions(860, height)
    self.detailHeaderBar:SetDimensions(860, 52)
    self.detailHint:ClearAnchors()
    self.detailHint:SetAnchor(BOTTOMLEFT, self.detailWindow, BOTTOMLEFT, 20, -14)
end

function HBU:CreateMiniUI()
    local wm = WINDOW_MANAGER
    self.miniWindow = wm:CreateTopLevelWindow("HealingBuffUptimeMiniWindow")
    self.miniWindow:SetDimensions(self.sv.miniWidth, self.sv.miniHeight)
    self.miniWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.sv.miniX, self.sv.miniY)
    self.miniWindow:SetMouseEnabled(false)
    self.miniWindow:SetMovable(false)
    self.miniWindow:SetClampedToScreen(true)
    self.miniWindow:SetHidden(false)
    self.miniWindow:SetHandler("OnMoveStop", function() self:SaveWindowPosition(self.miniWindow, "mini") end)

    self.miniBackdrop = wm:CreateControl("HealingBuffUptimeMiniBackdrop", self.miniWindow, CT_BACKDROP)
    self.miniBackdrop:SetAnchorFill()
    self.miniBackdrop:SetCenterColor(0, 0, 0, 0)
    self.miniBackdrop:SetEdgeColor(0, 0, 0, 0)
    self.miniBackdrop:SetEdgeTexture("", 2, 2, 0)

    self.miniTitle = wm:CreateControl("HealingBuffUptimeMiniTitle", self.miniWindow, CT_LABEL)
    self.miniTitle:SetAnchor(TOPLEFT, self.miniWindow, TOPLEFT, 0, 0)
    self.miniTitle:SetFont("$(BOLD_FONT)|22|soft-shadow-thick")
    self.miniTitle:SetText("HEALING UPTIME")

    self.miniDuration = wm:CreateControl("HealingBuffUptimeMiniDuration", self.miniWindow, CT_LABEL)
    self.miniDuration:SetAnchor(TOPLEFT, self.miniTitle, BOTTOMLEFT, 0, 6)
    self.miniDuration:SetFont("$(MEDIUM_FONT)|20|soft-shadow-thick")
    self.miniDuration:SetText("Kampfdauer: 00:00")

    self.miniHps = wm:CreateControl("HealingBuffUptimeMiniHps", self.miniWindow, CT_LABEL)
    self.miniHps:SetAnchor(TOPLEFT, self.miniDuration, BOTTOMLEFT, 0, 4)
    self.miniHps:SetFont("$(BOLD_FONT)|20|soft-shadow-thick")
    self.miniHps:SetText("HPS inkl. Overheal: 0")

    self.miniHeaderName = wm:CreateControl("HealingBuffUptimeMiniHeaderName", self.miniWindow, CT_LABEL)
    self.miniHeaderName:SetAnchor(TOPLEFT, self.miniHps, BOTTOMLEFT, 26, 6)
    self.miniHeaderName:SetFont("$(MEDIUM_FONT)|16|soft-shadow-thick")
    self.miniHeaderName:SetText("Buff")

    self.miniHeaderSelf = wm:CreateControl("HealingBuffUptimeMiniHeaderSelf", self.miniWindow, CT_LABEL)
    self.miniHeaderSelf:SetAnchor(TOPLEFT, self.miniHps, BOTTOMLEFT, 226, 6)
    self.miniHeaderSelf:SetFont("$(MEDIUM_FONT)|16|soft-shadow-thick")
    self.miniHeaderSelf:SetText("Eigen")

    self.miniHeaderOther = wm:CreateControl("HealingBuffUptimeMiniHeaderOther", self.miniWindow, CT_LABEL)
    self.miniHeaderOther:SetAnchor(TOPLEFT, self.miniHps, BOTTOMLEFT, 300, 6)
    self.miniHeaderOther:SetFont("$(MEDIUM_FONT)|16|soft-shadow-thick")
    self.miniHeaderOther:SetText("Andere")

    self.miniHeaderTotal = wm:CreateControl("HealingBuffUptimeMiniHeaderTotal", self.miniWindow, CT_LABEL)
    self.miniHeaderTotal:SetAnchor(TOPLEFT, self.miniHps, BOTTOMLEFT, 386, 6)
    self.miniHeaderTotal:SetFont("$(MEDIUM_FONT)|16|soft-shadow-thick")
    self.miniHeaderTotal:SetText("Gesamt")

    self.miniMoveHint = wm:CreateControl("HealingBuffUptimeMiniMoveHint", self.miniWindow, CT_LABEL)
    self.miniMoveHint:SetAnchor(TOPRIGHT, self.miniWindow, TOPRIGHT, -6, 3)
    self.miniMoveHint:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    self.miniMoveHint:SetText("VERSCHIEBEMODUS")
    self.miniMoveHint:SetColor(1, 0.82, 0.25, 1)
    self.miniMoveHint:SetHidden(true)

    self:RegisterTextControl(self.miniTitle, 4, "$(BOLD_FONT)")
    self:RegisterTextControl(self.miniDuration, 2, "$(MEDIUM_FONT)")
    self:RegisterTextControl(self.miniHps, 2, "$(BOLD_FONT)")
    self:RegisterTextControl(self.miniHeaderName, -2, "$(MEDIUM_FONT)")
    self:RegisterTextControl(self.miniHeaderSelf, -2, "$(MEDIUM_FONT)")
    self:RegisterTextControl(self.miniHeaderOther, -2, "$(MEDIUM_FONT)")
    self:RegisterTextControl(self.miniHeaderTotal, -2, "$(MEDIUM_FONT)")
    self:RegisterTextControl(self.miniMoveHint, -3, "$(BOLD_FONT)")
    self:ApplyMiniLayout()
end

function HBU:CreateDetailUI()
    local wm = WINDOW_MANAGER
    self.detailWindow = wm:CreateTopLevelWindow("HealingBuffUptimeDetailWindow")
    self.detailWindow:SetDimensions(860, 520)
    if self.sv.detailPositionSaved then
        self.detailWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.sv.detailX, self.sv.detailY)
    else
        self.detailWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
    self.detailWindow:SetMovable(true)
    self.detailWindow:SetMouseEnabled(true)
    self.detailWindow:SetClampedToScreen(true)
    self.detailWindow:SetHidden(true)
    self.detailWindow:SetHandler("OnMoveStop", function() self:SaveWindowPosition(self.detailWindow, "detail") end)

    self.detailBackdrop = wm:CreateControl("HealingBuffUptimeDetailBackdrop", self.detailWindow, CT_BACKDROP)
    self.detailBackdrop:SetAnchorFill()
    self.detailBackdrop:SetCenterColor(0.05, 0.04, 0.03, 0.95)
    self.detailBackdrop:SetEdgeColor(0.76, 0.64, 0.34, 0.95)
    self.detailBackdrop:SetEdgeTexture("", 2, 2, 2)

    self.detailHeaderBar = wm:CreateControl("HealingBuffUptimeDetailHeaderBar", self.detailWindow, CT_BACKDROP)
    self.detailHeaderBar:SetAnchor(TOPLEFT, self.detailWindow, TOPLEFT, 0, 0)
    self.detailHeaderBar:SetDimensions(860, 52)
    self.detailHeaderBar:SetCenterColor(0.16, 0.12, 0.08, 0.98)
    self.detailHeaderBar:SetEdgeColor(0, 0, 0, 0)

    self.detailTitle = wm:CreateControl("HealingBuffUptimeDetailTitle", self.detailWindow, CT_LABEL)
    self.detailTitle:SetAnchor(LEFT, self.detailHeaderBar, LEFT, 18, 0)
    self.detailTitle:SetFont("$(BOLD_FONT)|28|soft-shadow-thick")
    self.detailTitle:SetText("Healing Buff Uptime")

    self.detailClose = wm:CreateControl("HealingBuffUptimeDetailClose", self.detailHeaderBar, CT_BUTTON)
    self.detailClose:SetDimensions(36, 36)
    self.detailClose:SetAnchor(RIGHT, self.detailHeaderBar, RIGHT, -10, 0)
    self.detailClose:SetNormalFontColor(1, 1, 1, 1)
    self.detailClose:SetMouseOverFontColor(1, 0.85, 0.4, 1)
    self.detailClose:SetPressedFontColor(1, 0.75, 0.2, 1)
    self.detailClose:SetFont("$(BOLD_FONT)|26|soft-shadow-thick")
    self.detailClose:SetText("×")
    self.detailClose:SetHandler("OnClicked", function() self:ToggleDetailWindow(false) end)

    self.detailStatus = wm:CreateControl("HealingBuffUptimeDetailStatus", self.detailWindow, CT_LABEL)
    self.detailStatus:SetAnchor(TOPLEFT, self.detailWindow, TOPLEFT, 20, 66)
    self.detailStatus:SetFont("$(BOLD_FONT)|20|soft-shadow-thick")
    self.detailStatus:SetText("Außerhalb des Kampfes")

    self.detailStats = wm:CreateControl("HealingBuffUptimeDetailStats", self.detailWindow, CT_LABEL)
    self.detailStats:SetAnchor(TOPLEFT, self.detailStatus, BOTTOMLEFT, 0, 12)
    self.detailStats:SetDimensions(820, 66)
    self.detailStats:SetFont("$(MEDIUM_FONT)|19|soft-shadow-thick")
    self.detailStats:SetText("Kampfdauer: 00:00 | HPS inkl. Overheal: 0\nEffektive HPS: 0 | Overheal: 0.0 % (0) | Effektive Heilung: 0")

    self.detailHeaderName = wm:CreateControl("HealingBuffUptimeDetailHeaderName", self.detailWindow, CT_LABEL)
    self.detailHeaderName:SetAnchor(TOPLEFT, self.detailStats, BOTTOMLEFT, 30, 12)
    self.detailHeaderName:SetFont("$(BOLD_FONT)|18|soft-shadow-thick")
    self.detailHeaderName:SetText("Buff")

    self.detailHeaderSelf = wm:CreateControl("HealingBuffUptimeDetailHeaderSelf", self.detailWindow, CT_LABEL)
    self.detailHeaderSelf:SetAnchor(TOPLEFT, self.detailStats, BOTTOMLEFT, 335, 12)
    self.detailHeaderSelf:SetFont("$(BOLD_FONT)|18|soft-shadow-thick")
    self.detailHeaderSelf:SetText("Eigen")

    self.detailHeaderOther = wm:CreateControl("HealingBuffUptimeDetailHeaderOther", self.detailWindow, CT_LABEL)
    self.detailHeaderOther:SetAnchor(TOPLEFT, self.detailStats, BOTTOMLEFT, 430, 12)
    self.detailHeaderOther:SetFont("$(BOLD_FONT)|18|soft-shadow-thick")
    self.detailHeaderOther:SetText("Andere")

    self.detailHeaderTotal = wm:CreateControl("HealingBuffUptimeDetailHeaderTotal", self.detailWindow, CT_LABEL)
    self.detailHeaderTotal:SetAnchor(TOPLEFT, self.detailStats, BOTTOMLEFT, 531, 12)
    self.detailHeaderTotal:SetFont("$(BOLD_FONT)|18|soft-shadow-thick")
    self.detailHeaderTotal:SetText("Gesamt")

    self.detailHeaderState = wm:CreateControl("HealingBuffUptimeDetailHeaderState", self.detailWindow, CT_LABEL)
    self.detailHeaderState:SetAnchor(TOPLEFT, self.detailStats, BOTTOMLEFT, 650, 12)
    self.detailHeaderState:SetFont("$(BOLD_FONT)|18|soft-shadow-thick")
    self.detailHeaderState:SetText("Status")

    self.detailHint = wm:CreateControl("HealingBuffUptimeDetailHint", self.detailWindow, CT_LABEL)
    self.detailHint:SetAnchor(BOTTOMLEFT, self.detailWindow, BOTTOMLEFT, 20, -14)
    self.detailHint:SetFont("$(MEDIUM_FONT)|17|soft-shadow-thick")
    self.detailHint:SetText("/hbu schließt dieses Fenster wieder.")

    self:RegisterTextControl(self.detailTitle, 10, "$(BOLD_FONT)")
    self:RegisterTextControl(self.detailClose, 8, "$(BOLD_FONT)")
    self:RegisterTextControl(self.detailStatus, 2, "$(BOLD_FONT)")
    self:RegisterTextControl(self.detailStats, 1, "$(MEDIUM_FONT)")
    self:RegisterTextControl(self.detailHeaderName, 0, "$(BOLD_FONT)")
    self:RegisterTextControl(self.detailHeaderSelf, 0, "$(BOLD_FONT)")
    self:RegisterTextControl(self.detailHeaderOther, 0, "$(BOLD_FONT)")
    self:RegisterTextControl(self.detailHeaderTotal, 0, "$(BOLD_FONT)")
    self:RegisterTextControl(self.detailHeaderState, 0, "$(BOLD_FONT)")
    self:RegisterTextControl(self.detailHint, -1, "$(MEDIUM_FONT)")
end

function HBU:ResetFight()
    self.combatStartMs = NowMs()
    self.combatEndMs = 0
    self.effectiveHealing = 0
    self.overhealing = 0
    self.buffs = {}
end

function HBU:StartCombat()
    self.inCombat = true
    self:ResetFight()
    self.detailStatus:SetText("Im Kampf")
end

function HBU:StopCombat()
    if not self.inCombat then return end
    local nowMs = NowMs()
    for _, buff in pairs(self.buffs) do
        self:AccumulateBuff(buff, nowMs)
    end
    self.inCombat = false
    self.combatEndMs = nowMs
    self.detailStatus:SetText("Kampf beendet")
    self:UpdateDisplay()
end

function HBU:OnCombatStateChanged(_, inCombat)
    if inCombat then
        self:StartCombat()
    else
        self:StopCombat()
    end
end

function HBU:OnCombatEvent(_, result, isError, abilityName, abilityGraphic,
                           abilityActionSlotType, sourceName, sourceType,
                           targetName, targetType, hitValue, powerType,
                           damageType, log, sourceUnitId, targetUnitId,
                           abilityId, overflow)
    if not self.inCombat or isError or not HEAL_RESULTS[result] then return end
    local effective = math.max(0, tonumber(hitValue) or 0)
    local overheal = math.max(0, tonumber(overflow) or 0)
    self.effectiveHealing = self.effectiveHealing + effective
    self.overhealing = self.overhealing + overheal
end

function HBU:OnEffectChanged(_, changeType, effectSlot, effectName, unitTag,
                             beginTime, endTime, stackCount, iconName,
                             buffType, effectType, abilityType, statusEffectType,
                             unitName, unitId, abilityId, sourceType)
    if unitTag ~= "player" then return end
    local displayName = self:NormalizeTrackedBuffName(effectName)
    if not displayName then return end

    local key = string.lower(displayName)
    local buff = self.buffs[key]
    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        if not self:ShouldTrackBuff(effectName, beginTime, endTime, effectType) then return end
    elseif changeType == EFFECT_RESULT_FADED then
        if not buff then return end
    else
        return
    end

    if not buff then
        buff = self:CreateBuff(displayName, iconName)
        self.buffs[key] = buff
    end

    local nowMs = NowMs()
    self:AccumulateBuff(buff, nowMs)

    local slotKey = tostring(effectSlot)

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        buff.name = displayName
        if iconName and iconName ~= "" then buff.icon = iconName end
        buff.instances[slotKey] = {
            active = true,
            fromSelf = sourceType == COMBAT_UNIT_TYPE_PLAYER,
            endTime = endTime or 0,
        }
    elseif changeType == EFFECT_RESULT_FADED then
        buff.instances[slotKey] = nil
    end

    self:RefreshBuffStates(buff)
end

function HBU:GetSortedBuffs(nowMs, fightMs)
    local list = {}
    for _, buff in pairs(self.buffs) do
        local snapshot = self:GetBuffSnapshot(buff, nowMs, fightMs)
        if snapshot.visible then
            table.insert(list, snapshot)
        end
    end
    table.sort(list, function(a, b)
        if a.totalUptime == b.totalUptime then return a.name < b.name end
        return a.totalUptime > b.totalUptime
    end)
    return list
end

function HBU:UpdateDisplay()
    if not self.miniWindow or not self.detailWindow then return end
    local nowMs = NowMs()
    local endMs = self.inCombat and nowMs or (self.combatEndMs > 0 and self.combatEndMs or nowMs)
    local fightMs = self.combatStartMs > 0 and math.max(1, endMs - self.combatStartMs) or 1
    local fightSeconds = fightMs / 1000
    local totalHealing = self.effectiveHealing + self.overhealing
    local totalHps = totalHealing / fightSeconds
    local effectiveHps = self.effectiveHealing / fightSeconds
    local overhealPct = totalHealing > 0 and (self.overhealing / totalHealing * 100) or 0
    local durationText = FormatDuration(fightSeconds)
    local buffs = self:GetSortedBuffs(nowMs, fightMs)
    local showOtherBuffs = self.sv.showOtherBuffs

    self.miniDuration:SetText("Kampfdauer: " .. durationText)
    self.miniHps:SetText("HPS inkl. Overheal: " .. FormatNumber(totalHps))

    local buffCount = #buffs
    self.lastVisibleBuffCount = buffCount
    self:UpdateMiniWindowHeight(buffCount)
    self:UpdateDetailWindowHeight(buffCount)

    for i = 1, buffCount do
        self:EnsureMiniRow(i)
        self:EnsureDetailRow(i)
    end

    for i = 1, buffCount do
        local buff = buffs[i]
        local mini = self.miniRows[i]
        self:ApplyRowState(mini.backdrop, buff.active)
        mini.backdrop:SetHidden(false)
        mini.icon:SetHidden(false)
        mini.name:SetHidden(false)
        mini.self:SetHidden(false)
        mini.other:SetHidden(not showOtherBuffs)
        mini.total:SetHidden(false)
        mini.icon:SetTexture(buff.icon or self:GetDefaultIcon())
        mini.name:SetText(string.format("%d. %s", i, buff.name))
        mini.self:SetText(string.format("%.1f%%", buff.selfUptime))
        mini.other:SetText(string.format("%.1f%%", buff.otherUptime))
        mini.total:SetText(string.format("%.1f%%", buff.totalUptime))

        local detail = self.detailRows[i]
        self:ApplyRowState(detail.backdrop, buff.active)
        detail.backdrop:SetHidden(false)
        detail.icon:SetHidden(false)
        detail.name:SetHidden(false)
        detail.self:SetHidden(false)
        detail.other:SetHidden(not showOtherBuffs)
        detail.total:SetHidden(false)
        detail.state:SetHidden(false)
        detail.icon:SetTexture(buff.icon or self:GetDefaultIcon())
        detail.name:SetText(string.format("%d. %s", i, buff.name))
        detail.self:SetText(string.format("%.1f%%", buff.selfUptime))
        detail.other:SetText(string.format("%.1f%%", buff.otherUptime))
        detail.total:SetText(string.format("%.1f%%", buff.totalUptime))
        detail.state:SetText(buff.active and string.format("%.1f s", buff.remaining) or "fehlt")
    end

    for i = buffCount + 1, #self.miniRows do
        local mini = self.miniRows[i]
        mini.backdrop:SetHidden(true)
        mini.icon:SetHidden(true)
        mini.name:SetHidden(true)
        mini.self:SetHidden(true)
        mini.other:SetHidden(true)
        mini.total:SetHidden(true)
    end

    for i = buffCount + 1, #self.detailRows do
        local detail = self.detailRows[i]
        detail.backdrop:SetHidden(true)
        detail.icon:SetHidden(true)
        detail.name:SetHidden(true)
        detail.self:SetHidden(true)
        detail.other:SetHidden(true)
        detail.total:SetHidden(true)
        detail.state:SetHidden(true)
    end

    self.detailStats:SetText(string.format(
        "Kampfdauer: %s | HPS inkl. Overheal: %s\nEffektive HPS: %s | Overheal: %.1f %% (%s) | Effektive Heilung: %s",
        durationText,
        FormatNumber(totalHps),
        FormatNumber(effectiveHps),
        overhealPct,
        FormatNumber(self.overhealing),
        FormatNumber(self.effectiveHealing)
    ))
end

function HBU:ToggleDetailWindow(forceState)
    if forceState == nil then
        self.detailWantedVisible = not self.detailWantedVisible
    else
        self.detailWantedVisible = forceState
    end
    self:RefreshWindowVisibility()
end

function HBU:SaveWindowPosition(control, windowName)
    if not control or not self.sv then return end
    local left = control:GetLeft()
    local top = control:GetTop()
    if not left or not top then return end

    if windowName == "mini" then
        self.sv.miniX = Round(left)
        self.sv.miniY = Round(top)
    elseif windowName == "detail" then
        self.sv.detailX = Round(left)
        self.sv.detailY = Round(top)
        self.sv.detailPositionSaved = true
    end
end

function HBU:SetMoveMode(enabled)
    self.moveMode = enabled == true
    if not self.miniWindow then return end

    self.miniWindow:SetMouseEnabled(self.moveMode)
    self.miniWindow:SetMovable(self.moveMode)
    self.miniMoveHint:SetHidden(not self.moveMode)
    if self.moveMode then
        self.miniBackdrop:SetCenterColor(0.08, 0.08, 0.08, 0.55)
        self.miniBackdrop:SetEdgeColor(1, 0.82, 0.25, 0.9)
    else
        self.miniBackdrop:SetCenterColor(0, 0, 0, 0)
        self.miniBackdrop:SetEdgeColor(0, 0, 0, 0)
    end
end

function HBU:ToggleMoveMode()
    self:SetMoveMode(not self.moveMode)
    d(self.moveMode and "Healing Buff Uptime: Verschiebemodus aktiv." or "Healing Buff Uptime: Position gespeichert.")
    return true
end

function HBU:MoveMiniWindowBy(xDirection, yDirection)
    if not self.moveMode or not self.miniWindow then return false end
    local step = self.sv.controllerMoveStep or self.defaults.controllerMoveStep
    local left = self.miniWindow:GetLeft() or self.sv.miniX
    local top = self.miniWindow:GetTop() or self.sv.miniY
    local maxX = math.max(0, GuiRoot:GetWidth() - self.miniWindow:GetWidth())
    local maxY = math.max(0, GuiRoot:GetHeight() - self.miniWindow:GetHeight())
    local x = Clamp(left + (xDirection or 0) * step, 0, maxX)
    local y = Clamp(top + (yDirection or 0) * step, 0, maxY)

    self.miniWindow:ClearAnchors()
    self.miniWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    self:SaveWindowPosition(self.miniWindow, "mini")
    return true
end

function HBU:ResetWindowPositions()
    self.miniWindow:ClearAnchors()
    self.miniWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 10, 70)
    self.sv.miniX = 10
    self.sv.miniY = 70
    self.detailWindow:ClearAnchors()
    self.detailWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    self.sv.detailPositionSaved = false
    self.sv.detailX = 0
    self.sv.detailY = 0
end


function HBU:SetupSettings()
    local LAM = LibAddonMenu2
    if not LAM then
        d("Healing Buff Uptime: LibAddonMenu-2.0 wurde nicht gefunden.")
        return
    end

    local panelName = "HealingBuffUptimeOptions"
    local panelData = {
        type = "panel",
        name = "Healing Buff Uptime",
        displayName = "Healing Buff Uptime",
        author = "satuve",
        version = self.version,
        slashCommand = "/hbusettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    self.settingsPanel = LAM:RegisterAddonPanel(panelName, panelData)

    local options = {
        {
            type = "description",
            text = "Passe das Buff-Fenster an. Für den Controller kannst du unter Steuerung > Tastenbelegung > Add-ons die fünf Aktionen von Healing Buff Uptime belegen.",
            width = "full",
        },
        {
            type = "header",
            name = "Buff-Anzeige",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Fremde Buffs anzeigen",
            tooltip = "Zeigt Buffs und Anteile an, die von anderen Spielern stammen.",
            getFunc = function() return self.sv.showOtherBuffs end,
            setFunc = function(value)
                self.sv.showOtherBuffs = value
                self:ApplyOtherBuffVisibility()
                self:UpdateDisplay()
            end,
            default = self.defaults.showOtherBuffs,
            width = "full",
        },
        {
            type = "slider",
            name = "Breite",
            tooltip = "Breite des kleinen Buff-Fensters.",
            min = 400,
            max = 900,
            step = 10,
            getFunc = function() return self.sv.miniWidth end,
            setFunc = function(value)
                self.sv.miniWidth = value
                self:ApplyMiniLayout()
            end,
            default = self.defaults.miniWidth,
            width = "full",
        },
        {
            type = "slider",
            name = "Höhe",
            tooltip = "Mindesthöhe des kleinen Buff-Fensters. Bei vielen Buffs wächst es automatisch weiter.",
            min = 140,
            max = 800,
            step = 10,
            getFunc = function() return self.sv.miniHeight end,
            setFunc = function(value)
                self.sv.miniHeight = value
                self:UpdateMiniWindowHeight(self.lastVisibleBuffCount or 0)
            end,
            default = self.defaults.miniHeight,
            width = "full",
        },
        {
            type = "slider",
            name = "Schriftgröße",
            tooltip = "Ändert die Schriftgröße in beiden Ansichten.",
            min = 12,
            max = 30,
            step = 1,
            getFunc = function() return self.sv.fontSize end,
            setFunc = function(value)
                self.sv.fontSize = value
                self:ApplyTextAppearance()
                self:ApplyMiniLayout()
            end,
            default = self.defaults.fontSize,
            width = "full",
        },
        {
            type = "slider",
            name = "Texttransparenz",
            tooltip = "100 % ist vollständig sichtbar, 10 % ist fast durchsichtig.",
            min = 10,
            max = 100,
            step = 5,
            getFunc = function() return self.sv.textAlpha end,
            setFunc = function(value)
                self.sv.textAlpha = value
                self:ApplyTextAppearance()
            end,
            default = self.defaults.textAlpha,
            width = "full",
        },
        {
            type = "header",
            name = "Position",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Buff-Fenster verschieben",
            tooltip = "Entsperrt das Fenster für die Maus und für die belegten Controller-Aktionen.",
            getFunc = function() return self.moveMode end,
            setFunc = function(value) self:SetMoveMode(value) end,
            default = false,
            width = "full",
        },
        {
            type = "button",
            name = "Positionen zurücksetzen",
            tooltip = "Setzt das kleine Buff-Fenster und die Detailansicht auf ihre Standardpositionen zurück.",
            func = function()
                self:ResetWindowPositions()
                d("Healing Buff Uptime: Fensterpositionen zurückgesetzt.")
            end,
            width = "full",
        },
    }

    LAM:RegisterOptionControls(panelName, options)
end

function HBU:Initialize()
    self.sv = ZO_SavedVars:NewAccountWide("HealingBuffUptimeSavedVariables", 1, nil, self.defaults)
    self.sv.miniWidth = Clamp(tonumber(self.sv.miniWidth) or self.defaults.miniWidth, 400, 900)
    self.sv.miniHeight = Clamp(tonumber(self.sv.miniHeight) or self.defaults.miniHeight, 140, 800)
    self.sv.fontSize = Clamp(tonumber(self.sv.fontSize) or self.defaults.fontSize, 12, 30)
    self.sv.textAlpha = Clamp(tonumber(self.sv.textAlpha) or self.defaults.textAlpha, 10, 100)
    self.sv.controllerMoveStep = Clamp(tonumber(self.sv.controllerMoveStep) or self.defaults.controllerMoveStep, 1, 100)

    self:CreateMiniUI()
    self:CreateDetailUI()
    self:ApplyTextAppearance()
    self:ApplyOtherBuffVisibility()
    self:SetupSettings()

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE,
        function(...) self:OnCombatStateChanged(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT,
        function(...) self:OnCombatEvent(...) end)
    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_EFFECT_CHANGED,
        function(...) self:OnEffectChanged(...) end)
    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:RegisterForUpdate(self.name .. "Update", 250,
        function() self:UpdateDisplay() end)

    if SCENE_MANAGER and SCENE_MANAGER.RegisterCallback then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
            self:OnSceneStateChanged(scene, oldState, newState)
        end)
    end

    SLASH_COMMANDS["/hbu"] = function() self:ToggleDetailWindow() end
    SLASH_COMMANDS["/hbureset"] = function() self:ResetWindowPositions() end
    SLASH_COMMANDS["/hbumove"] = function() self:ToggleMoveMode() end

    self.detailWantedVisible = false
    self.uiSuspended = false
    self:RefreshWindowVisibility()

    d(string.format("%s %s geladen. /hbu: Details, /hbumove: Fenster verschieben.", self.name, self.version))
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= HBU.name then return end
    EVENT_MANAGER:UnregisterForEvent(HBU.name, EVENT_ADD_ON_LOADED)
    HBU:Initialize()
end

EVENT_MANAGER:RegisterForEvent(HBU.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
