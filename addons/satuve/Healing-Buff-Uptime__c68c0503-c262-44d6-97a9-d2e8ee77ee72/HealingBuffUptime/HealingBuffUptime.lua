HealingBuffUptime = {}
local HBU = HealingBuffUptime

HBU.name = "HealingBuffUptime"
HBU.version = "0.3.5"
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

    local maxEndTime = 0
    for _, instance in pairs(buff.instances) do
        if instance.active and instance.endTime and instance.endTime > maxEndTime then
            maxEndTime = instance.endTime
        end
    end

    local remaining = maxEndTime > 0 and math.max(0, maxEndTime - GetFrameTimeSeconds()) or 0
    local denom = fightMs > 0 and fightMs or 1
    return {
        name = buff.name,
        icon = buff.icon or self:GetDefaultIcon(),
        selfUptime = Clamp(selfMs / denom * 100, 0, 100),
        otherUptime = Clamp(otherMs / denom * 100, 0, 100),
        totalUptime = Clamp(totalMs / denom * 100, 0, 100),
        active = buff.totalRunning,
        remaining = remaining,
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

function HBU:EnsureMiniRow(index)
    if self.miniRows[index] then return end
    local wm = WINDOW_MANAGER
    local row = {}
    row.backdrop = wm:CreateControl("HealingBuffUptimeMiniRowBackdrop" .. index, self.miniWindow, CT_BACKDROP)
    if index == 1 then
        row.backdrop:SetAnchor(TOPLEFT, self.miniHeaderName, BOTTOMLEFT, -4, 5)
    else
        row.backdrop:SetAnchor(TOPLEFT, self.miniRows[index - 1].backdrop, BOTTOMLEFT, 0, 3)
    end
    row.backdrop:SetDimensions(470, 22)
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
end

function HBU:UpdateMiniWindowHeight(visibleCount)
    local count = math.max(visibleCount, 1)
    self.miniWindow:SetDimensions(500, 110 + count * 25)
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
    self.miniWindow:SetDimensions(500, 320)
    self.miniWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 10, 70)
    self.miniWindow:SetMouseEnabled(true)
    self.miniWindow:SetMovable(true)
    self.miniWindow:SetClampedToScreen(true)
    self.miniWindow:SetHidden(false)

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
end

function HBU:CreateDetailUI()
    local wm = WINDOW_MANAGER
    self.detailWindow = wm:CreateTopLevelWindow("HealingBuffUptimeDetailWindow")
    self.detailWindow:SetDimensions(860, 520)
    self.detailWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    self.detailWindow:SetMovable(true)
    self.detailWindow:SetMouseEnabled(true)
    self.detailWindow:SetClampedToScreen(true)
    self.detailWindow:SetHidden(true)

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
    if not buff then
        buff = self:CreateBuff(displayName, iconName)
        self.buffs[key] = buff
    end

    local nowMs = NowMs()
    self:AccumulateBuff(buff, nowMs)

    local slotKey = tostring(effectSlot)

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        if not self:ShouldTrackBuff(effectName, beginTime, endTime, effectType) then return end
        buff.name = displayName
        if iconName and iconName ~= "" then buff.icon = iconName end
        buff.instances[slotKey] = {
            active = true,
            fromSelf = sourceType == COMBAT_UNIT_TYPE_PLAYER,
            endTime = endTime or 0,
        }
    elseif changeType == EFFECT_RESULT_FADED then
        buff.instances[slotKey] = nil
    else
        return
    end

    self:RefreshBuffStates(buff)
end

function HBU:GetSortedBuffs(nowMs, fightMs)
    local list = {}
    for _, buff in pairs(self.buffs) do
        table.insert(list, self:GetBuffSnapshot(buff, nowMs, fightMs))
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

    self.miniDuration:SetText("Kampfdauer: " .. durationText)
    self.miniHps:SetText("HPS inkl. Overheal: " .. FormatNumber(totalHps))

    local buffCount = #buffs
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
        mini.other:SetHidden(false)
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
        detail.other:SetHidden(false)
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

function HBU:ResetWindowPositions()
    self.miniWindow:ClearAnchors()
    self.miniWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 10, 70)
    self.detailWindow:ClearAnchors()
    self.detailWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
end

function HBU:Initialize()
    self:CreateMiniUI()
    self:CreateDetailUI()

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

    self.detailWantedVisible = false
    self.uiSuspended = false
    self:RefreshWindowVisibility()

    d(string.format("%s %s geladen. /hbu öffnet die Detailansicht.", self.name, self.version))
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= HBU.name then return end
    EVENT_MANAGER:UnregisterForEvent(HBU.name, EVENT_ADD_ON_LOADED)
    HBU:Initialize()
end

EVENT_MANAGER:RegisterForEvent(HBU.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
