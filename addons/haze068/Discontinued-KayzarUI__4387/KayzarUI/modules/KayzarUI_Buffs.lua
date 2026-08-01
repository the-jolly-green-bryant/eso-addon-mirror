KayzarUI = KayzarUI or {}
local KayzarUI = KayzarUI

KayzarUI.Buffs = {}
local BF = KayzarUI.Buffs
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER

local TEX_BUFF_BORDER   = "KayzarUI/textures/buff_border.dds"
local TEX_DEBUFF_BORDER = "KayzarUI/textures/debuff_border.dds"

------------------------------------------------------------------------
-- SAFE CONTROL CREATION
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
local function SavePos(key, c)
    if not KayzarUI.sv.buffTracker then return end
    KayzarUI.sv.buffTracker[key .. "X"] = c:GetLeft()
    KayzarUI.sv.buffTracker[key .. "Y"] = c:GetTop()
end

local function ApplyPos(key, c)
    if not KayzarUI.sv.buffTracker then return end
    local x = KayzarUI.sv.buffTracker[key .. "X"]
    local y = KayzarUI.sv.buffTracker[key .. "Y"]
    if x ~= nil and y ~= nil then
        c:ClearAnchors()
        c:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    end
end

------------------------------------------------------------------------
-- INITIALIZE
------------------------------------------------------------------------
function BF:Initialize()
    self.buffIcons = {}
    self.debuffIcons = {}
    self.debuffContainer = nil

    local sv = KayzarUI.sv
    if sv.buffTracker and sv.buffTracker.enabled then
        self:BuildBuffTracker()
    end
    if sv.targetDebuffs and sv.targetDebuffs.enabled then
        self:BuildDebuffContainer()
    end
    self:RegisterEvents()
end

function BF:Rebuild()
    if self.buffContainer then self.buffContainer:SetHidden(true) end
    for _, icon in pairs(self.buffIcons) do
        if icon.frame then icon.frame:SetHidden(true) end
    end
    self.buffIcons = {}
    if self.debuffContainer then self.debuffContainer:SetHidden(true) end
    self.debuffIcons = {}
    self:Initialize()
end

------------------------------------------------------------------------
-- PLAYER BUFF TRACKER
------------------------------------------------------------------------
function BF:BuildBuffTracker()
    local sv = KayzarUI.sv.buffTracker
    local iconSize = sv.iconSize or 36

    local container = GOTLW("KayzarUI_BuffTracker")
    container:SetDimensions(iconSize * 6 + 30, iconSize + 20)
    container:SetAnchor(CENTER, GuiRoot, CENTER, 0, -250)
    ApplyPos("container", container)
    container:SetMovable(not KayzarUI.sv.lockFrames)
    container:SetMouseEnabled(true)
    container:SetClampedToScreen(true)
    container:SetAlpha(0)
    container:SetHidden(false)
    container:SetHandler("OnMoveStop", function(c) SavePos("container", c) end)
    self.buffContainer = container
end

------------------------------------------------------------------------
-- CREATE/UPDATE BUFF ICON
------------------------------------------------------------------------
function BF:GetOrCreateBuffIcon(index)
    if self.buffIcons[index] then return self.buffIcons[index] end

    local sv = KayzarUI.sv.buffTracker
    local iconSize = sv.iconSize or 36
    local frameName = "KayzarUI_Buff" .. index

    local frame = GOTLW(frameName)
    frame:SetDimensions(iconSize, iconSize + (sv.showTimer and 14 or 0))

    local col = (index - 1) % 6
    local row = zo_floor((index - 1) / 6)
    local containerX = KayzarUI.sv.buffTracker.containerX or (GuiRoot:GetWidth() / 2 - iconSize * 3)
    local containerY = KayzarUI.sv.buffTracker.containerY or (GuiRoot:GetHeight() / 2 - 250)
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        containerX + col * (iconSize + 4),
        containerY + row * (iconSize + 18))

    ApplyPos("buff" .. index, frame)
    frame:SetMovable(not KayzarUI.sv.lockFrames)
    frame:SetMouseEnabled(true)
    frame:SetClampedToScreen(true)
    frame:SetHidden(true)
    frame:SetHandler("OnMoveStop", function(c) SavePos("buff" .. index, c) end)

    local icon = GOC(frameName .. "_Icon", frame, CT_TEXTURE)
    icon:SetDimensions(iconSize, iconSize)
    icon:SetAnchor(TOPLEFT, frame, TOPLEFT, 0, 0)
    icon:SetDrawLayer(DL_CONTROLS)

    local border = GOC(frameName .. "_Border", frame, CT_TEXTURE)
    border:SetDimensions(iconSize, iconSize)
    border:SetAnchor(TOPLEFT, frame, TOPLEFT, 0, 0)
    border:SetTexture(TEX_BUFF_BORDER)
    local ac = KayzarUI.sv.accentColor or {r = 0.95, g = 0.3, b = 0.55}
    border:SetColor(ac.r, ac.g, ac.b, 0.8)
    border:SetDrawLayer(DL_OVERLAY)

    local timer = GOC(frameName .. "_Timer", frame, CT_LABEL)
    timer:SetDimensions(iconSize, 14)
    timer:SetAnchor(TOP, icon, BOTTOM, 0, 1)
    timer:SetFont("ZoFontGameSmall")
    timer:SetColor(1, 1, 1, 1)
    timer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    timer:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    timer:SetHidden(not sv.showTimer)

    local stacks = GOC(frameName .. "_Stacks", frame, CT_LABEL)
    stacks:SetDimensions(iconSize * 0.4, iconSize * 0.4)
    stacks:SetAnchor(TOPRIGHT, icon, TOPRIGHT, -1, 1)
    stacks:SetFont("ZoFontGameSmall")
    stacks:SetColor(1, 0.9, 0.3, 1)
    stacks:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    stacks:SetHidden(true)

    local entry = {
        frame     = frame,
        icon      = icon,
        border    = border,
        timer     = timer,
        stacks    = stacks,
        abilityId = nil,
    }
    self.buffIcons[index] = entry
    return entry
end

------------------------------------------------------------------------
-- DEBUFF CONTAINER
------------------------------------------------------------------------
function BF:BuildDebuffContainer()
    local sv = KayzarUI.sv.targetDebuffs
    local iconSize = sv.iconSize or 30

    local container = GOTLW("KayzarUI_DebuffContainer")
    container:SetDimensions(iconSize * 8 + 28, iconSize + 16)

    local tf = _G["KayzarUI_TargetFrame"]
    if tf then
        container:SetAnchor(TOP, tf, BOTTOM, 0, 4)
    else
        container:SetAnchor(CENTER, GuiRoot, CENTER, 340, -100)
    end

    local ufSv = KayzarUI.sv.unitFrames
    if ufSv.debuffContPosX ~= nil and ufSv.debuffContPosY ~= nil then
        container:ClearAnchors()
        container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ufSv.debuffContPosX, ufSv.debuffContPosY)
    end

    container:SetMovable(not KayzarUI.sv.lockFrames)
    container:SetMouseEnabled(true)
    container:SetClampedToScreen(true)
    container:SetHidden(true)
    container:SetHandler("OnMoveStop", function(c)
        KayzarUI.sv.unitFrames.debuffContPosX = c:GetLeft()
        KayzarUI.sv.unitFrames.debuffContPosY = c:GetTop()
    end)

    self.debuffContainer = container

    for i = 1, (sv.maxDebuffs or 8) do
        local dn = "KayzarUI_Debuff" .. i
        local df = GOC(dn, container, CT_CONTROL)
        df:SetDimensions(iconSize, iconSize + 14)
        df:SetAnchor(TOPLEFT, container, TOPLEFT, (i - 1) * (iconSize + 4), 0)
        df:SetHidden(true)

        local dIcon = GOC(dn .. "_Icon", df, CT_TEXTURE)
        dIcon:SetDimensions(iconSize, iconSize)
        dIcon:SetAnchor(TOPLEFT, df, TOPLEFT, 0, 0)

        local dBorder = GOC(dn .. "_Border", df, CT_TEXTURE)
        dBorder:SetDimensions(iconSize, iconSize)
        dBorder:SetAnchor(TOPLEFT, df, TOPLEFT, 0, 0)
        dBorder:SetTexture(TEX_DEBUFF_BORDER)
        dBorder:SetColor(1, 0.3, 0.3, 0.9)
        dBorder:SetDrawLayer(DL_OVERLAY)

        local dTimer = GOC(dn .. "_Timer", df, CT_LABEL)
        dTimer:SetDimensions(iconSize, 14)
        dTimer:SetAnchor(TOP, dIcon, BOTTOM, 0, 0)
        dTimer:SetFont("ZoFontGameSmall")
        dTimer:SetColor(1, 0.5, 0.5, 1)
        dTimer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

        self.debuffIcons[i] = {
            frame  = df,
            icon   = dIcon,
            border = dBorder,
            timer  = dTimer,
        }
    end
end

------------------------------------------------------------------------
-- UPDATE LOCK STATE
------------------------------------------------------------------------
function BF:UpdateLock()
    local movable = not KayzarUI.sv.lockFrames
    for _, icon in pairs(self.buffIcons) do
        if icon.frame then
            icon.frame:SetMovable(movable)
            icon.frame:SetMouseEnabled(true)
        end
    end
    if self.buffContainer then
        self.buffContainer:SetMovable(movable)
        self.buffContainer:SetMouseEnabled(true)
    end
    if self.debuffContainer then
        self.debuffContainer:SetMovable(movable)
        self.debuffContainer:SetMouseEnabled(true)
    end
end

------------------------------------------------------------------------
-- FORMAT TIME
------------------------------------------------------------------------
local function FormatTime(ms)
    if not ms or ms <= 0 then return "" end
    local sec = ms / 1000
    if sec >= 3600 then
        return string.format("%dh", zo_floor(sec / 3600))
    elseif sec >= 60 then
        return string.format("%dm", zo_floor(sec / 60))
    elseif sec >= 10 then
        return string.format("%ds", zo_floor(sec))
    end
    return string.format("%.1f", sec)
end

------------------------------------------------------------------------
-- REFRESH PLAYER BUFFS
------------------------------------------------------------------------
function BF:RefreshBuffs()
    local sv = KayzarUI.sv.buffTracker
    if not sv or not sv.enabled then
        for _, icon in pairs(self.buffIcons) do
            if icon.frame then icon.frame:SetHidden(true) end
        end
        return
    end

    local maxBuffs = sv.maxBuffs or 12
    local now = GetGameTimeMilliseconds()
    local buffs = {}

    local numBuffs = GetNumBuffs("player")
    for i = 1, numBuffs do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename,
              buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff =
              GetUnitBuffInfo("player", i)
        if buffName and buffName ~= "" and iconFilename and iconFilename ~= "" then
            local timeRemaining = 0
            if timeEnding and timeEnding > 0 then
                timeRemaining = (timeEnding - now / 1000) * 1000
            end
            local isPermanent = (timeEnding == 0 or timeEnding == nil)
            if effectType == 1 and not isPermanent then
                buffs[#buffs + 1] = {
                    name          = buffName,
                    icon          = iconFilename,
                    timeRemaining = timeRemaining,
                    stackCount    = stackCount or 0,
                    abilityId     = abilityId,
                    timeEnding    = timeEnding,
                }
            end
        end
    end

    table.sort(buffs, function(a, b) return a.timeRemaining < b.timeRemaining end)

    local count = math.min(#buffs, maxBuffs)
    for i = 1, count do
        local entry = self:GetOrCreateBuffIcon(i)
        local buff = buffs[i]
        entry.icon:SetTexture(buff.icon)
        entry.abilityId = buff.abilityId

        if sv.showTimer and entry.timer then
            local timeText = FormatTime(buff.timeRemaining)
            entry.timer:SetText(timeText)
            entry.timer:SetHidden(timeText == "")
        end

        if buff.stackCount > 1 and entry.stacks then
            entry.stacks:SetText(tostring(buff.stackCount))
            entry.stacks:SetHidden(false)
        elseif entry.stacks then
            entry.stacks:SetHidden(true)
        end

        entry.frame:SetHidden(false)
    end

    for i = count + 1, #self.buffIcons do
        if self.buffIcons[i] and self.buffIcons[i].frame then
            self.buffIcons[i].frame:SetHidden(true)
        end
    end
end

------------------------------------------------------------------------
-- REFRESH TARGET DEBUFFS
------------------------------------------------------------------------
function BF:RefreshDebuffs()
    local sv = KayzarUI.sv.targetDebuffs
    if not sv or not sv.enabled then
        if self.debuffContainer then self.debuffContainer:SetHidden(true) end
        return
    end

    local ex = DoesUnitExist("reticleover")
    if not ex then
        if self.debuffContainer then self.debuffContainer:SetHidden(true) end
        for _, d in pairs(self.debuffIcons) do
            if d.frame then d.frame:SetHidden(true) end
        end
        return
    end

    local maxDebuffs = sv.maxDebuffs or 8
    local now = GetGameTimeMilliseconds()
    local debuffs = {}

    local numBuffs = GetNumBuffs("reticleover")
    for i = 1, numBuffs do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename,
              buffType, effectType, abilityType, statusEffectType, abilityId =
              GetUnitBuffInfo("reticleover", i)
        if buffName and buffName ~= "" and iconFilename and iconFilename ~= "" then
            local timeRemaining = 0
            if timeEnding and timeEnding > 0 then
                timeRemaining = (timeEnding - now / 1000) * 1000
            end
            if effectType == 2 then
                debuffs[#debuffs + 1] = {
                    name          = buffName,
                    icon          = iconFilename,
                    timeRemaining = timeRemaining,
                    stackCount    = stackCount or 0,
                }
            end
        end
    end

    table.sort(debuffs, function(a, b) return a.timeRemaining < b.timeRemaining end)

    local count = math.min(#debuffs, maxDebuffs)
    if count > 0 and self.debuffContainer then
        self.debuffContainer:SetHidden(false)
    elseif self.debuffContainer then
        self.debuffContainer:SetHidden(true)
    end

    for i = 1, count do
        local entry = self.debuffIcons[i]
        if entry then
            local debuff = debuffs[i]
            entry.icon:SetTexture(debuff.icon)
            if entry.timer then
                local timeText = FormatTime(debuff.timeRemaining)
                entry.timer:SetText(timeText)
                entry.timer:SetHidden(timeText == "")
            end
            entry.frame:SetHidden(false)
        end
    end

    for i = count + 1, maxDebuffs do
        if self.debuffIcons[i] and self.debuffIcons[i].frame then
            self.debuffIcons[i].frame:SetHidden(true)
        end
    end
end

------------------------------------------------------------------------
-- EVENTS
------------------------------------------------------------------------
function BF:RegisterEvents()
    local ns = "KUI_Buffs"

    EM:UnregisterForUpdate(ns .. "_Tick")
    EM:UnregisterForEvent(ns .. "_EC", EVENT_EFFECT_CHANGED)
    EM:UnregisterForEvent(ns .. "_RT", EVENT_RETICLE_TARGET_CHANGED)

    EM:RegisterForUpdate(ns .. "_Tick", 500, function()
        self:RefreshBuffs()
        self:RefreshDebuffs()
    end)

    EM:RegisterForEvent(ns .. "_EC", EVENT_EFFECT_CHANGED, function(_, changeType, _, _, unitTag)
        if unitTag == "player" then
            self:RefreshBuffs()
        elseif unitTag == "reticleover" then
            self:RefreshDebuffs()
        end
    end)

    EM:RegisterForEvent(ns .. "_RT", EVENT_RETICLE_TARGET_CHANGED, function()
        self:RefreshDebuffs()
    end)
end
