JacobsChannelCastBar = JacobsChannelCastBar or {}
local JCCB = JacobsChannelCastBar

JCCB.name = "JacobsChannelCastBar"
JCCB.version = "1.0.1"

JCCB.defaults = {
    enabled = true,
    unlocked = false,

    x = 0,
    y = 200,

    width = 280,
    height = 20,
    scale = 1.0,
    alpha = 1.0,

    reverseFill = true,
    showName = false,
    showTimer = false,
    showBackground = true,
    fontSize = 18,

    showIcon = true,
    colorBrightness = 1.0,

    debug = false,
    scanMode = false,

    bgR = 0.05,
    bgG = 0.05,
    bgB = 0.05,
    bgA = 0.75,
}

JCCB.MIN_CHANNEL_MS = 2000

JCCB.sv = nil

JCCB.control = nil
JCCB.iconBG = nil
JCCB.icon = nil
JCCB.barBG = nil
JCCB.fill = nil
JCCB.label = nil
JCCB.timerLabel = nil

JCCB.isCasting = false
JCCB.castAbilityId = nil
JCCB.castAbilityName = ""
JCCB.castStartMs = 0
JCCB.castEndMs = 0
JCCB.castDurationMs = 0
JCCB.lastStartStamp = 0

local STOP_RESULTS = {
    [ACTION_RESULT_INTERRUPT] = true,
    [ACTION_RESULT_FAILED] = true,
    [ACTION_RESULT_EFFECT_FADED] = true,
    [ACTION_RESULT_DIED] = true,
    [ACTION_RESULT_STUNNED] = true,
    [ACTION_RESULT_DISORIENTED] = true,
    [ACTION_RESULT_FEARED] = true,
    [ACTION_RESULT_KNOCKBACK] = true,
    [ACTION_RESULT_PACIFIED] = true,
    [ACTION_RESULT_SILENCED] = true,
}

local function dmsg(msg)
    d(string.format("|cD9A441[%s]|r %s", JCCB.name, tostring(msg)))
end

local function Clamp(v, minV, maxV)
    if v < minV then return minV end
    if v > maxV then return maxV end
    return v
end

function JCCB:ResolveSlotAbilityId(slotNum, hotbarCategory)
    local rawId = GetSlotBoundId(slotNum, hotbarCategory)
    local slotType = GetSlotType(slotNum, hotbarCategory)
    local resolvedId = rawId

    if slotType == ACTION_TYPE_CRAFTED_ABILITY and rawId and rawId > 0 then
        resolvedId = GetAbilityIdForCraftedAbilityId(rawId)
    end

    return resolvedId, rawId, slotType
end

function JCCB:GetAbilityCastData(abilityId)
    if not abilityId or abilityId <= 0 then
        return false, 0
    end

    local isChanneled, durationMs = GetAbilityCastInfo(abilityId)
    isChanneled = isChanneled == true
    durationMs = tonumber(durationMs) or 0

    return isChanneled, durationMs
end

function JCCB:IsTrackableAbility(abilityId)
    local isChanneled, durationMs = self:GetAbilityCastData(abilityId)

    if not isChanneled then
        return false, isChanneled, durationMs
    end

    if durationMs < self.MIN_CHANNEL_MS then
        return false, isChanneled, durationMs
    end

    return true, isChanneled, durationMs
end

function JCCB:GetCurrentClassColor()
    local classId = select(1, GetUnitClassId("player"))

    local map = {
        [1]   = {0.92, 0.43, 0.10}, -- Dragonknight
        [2]   = {0.47, 0.39, 0.92}, -- Sorcerer
        [3]   = {0.76, 0.18, 0.22}, -- Nightblade
        [6]   = {0.96, 0.79, 0.26}, -- Templar
        [4]   = {0.24, 0.64, 0.27}, -- Warden
        [5]   = {0.24, 0.66, 0.68}, -- Necromancer
        [117] = {0.31, 0.83, 0.47}, -- Arcanist
    }

    local base = map[classId] or {0.85, 0.65, 0.10}
    local m = Clamp(self.sv.colorBrightness or 1.0, 0.0, 1.0)

    return
        Clamp(base[1] * m, 0, 1),
        Clamp(base[2] * m, 0, 1),
        Clamp(base[3] * m, 0, 1)
end

function JCCB:CreateUI()
    local wm = WINDOW_MANAGER

    local ctl = wm:CreateTopLevelWindow("JacobsChannelCastBar_Control")
    ctl:SetMouseEnabled(true)
    ctl:SetMovable(true)
    ctl:SetClampedToScreen(true)
    ctl:SetScale(self.sv.scale)
    ctl:SetAlpha(self.sv.alpha)
    ctl:SetHidden(false)
    ctl:SetDrawLayer(DL_OVERLAY)
    ctl:SetDrawTier(DT_HIGH)

    ctl:SetHandler("OnMoveStop", function(control)
        self.sv.x = control:GetLeft()
        self.sv.y = control:GetTop()
    end)

    self.control = ctl

    local iconBG = wm:CreateControl("$(parent)_IconBG", ctl, CT_BACKDROP)
    iconBG:SetCenterColor(0, 0, 0, 1)
    iconBG:SetEdgeColor(0, 0, 0, 1)
    iconBG:SetEdgeTexture(nil, 1, 1, 1)
    self.iconBG = iconBG

    local icon = wm:CreateControl("$(parent)_Icon", iconBG, CT_TEXTURE)
    icon:SetTexture("/esoui/art/icons/ability_warrior_001.dds")
    self.icon = icon

    local barBG = wm:CreateControl("$(parent)_BarBG", ctl, CT_BACKDROP)
    barBG:SetCenterColor(self.sv.bgR, self.sv.bgG, self.sv.bgB, self.sv.bgA)
    barBG:SetEdgeColor(0, 0, 0, 1)
    barBG:SetEdgeTexture(nil, 1, 1, 1)
    self.barBG = barBG

    local fill = wm:CreateControl("$(parent)_Fill", barBG, CT_BACKDROP)
    fill:SetCenterColor(1, 1, 1, 1)
    fill:SetEdgeColor(0, 0, 0, 0)
    fill:SetEdgeTexture(nil, 1, 1, 1)
    self.fill = fill

    local label = wm:CreateControl("$(parent)_Label", ctl, CT_LABEL)
    label:SetColor(1, 1, 1, 1)
    label:SetText("")
    self.label = label

    local timerLabel = wm:CreateControl("$(parent)_Timer", ctl, CT_LABEL)
    timerLabel:SetColor(1, 1, 1, 1)
    timerLabel:SetText("")
    self.timerLabel = timerLabel

    self:ApplySettings()
    self:RestorePosition()
    self:RefreshVisibility()
end

function JCCB:RestorePosition()
    self.control:ClearAnchors()

    local x = self.sv.x
    local y = self.sv.y

    if x == 0 and y == 200 then
        self.control:SetAnchor(CENTER, GuiRoot, CENTER, 0, 200)
    else
        self.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    end
end

function JCCB:LayoutControls()
    if not self.control then return end

    local h = self.sv.height
    local barWidth = self.sv.width
    local iconSize = self.sv.showIcon and h or 0
    local gap = self.sv.showIcon and 1 or 0
    local totalWidth = iconSize + gap + barWidth

    self.control:SetDimensions(totalWidth, h)

    self.iconBG:ClearAnchors()
    self.icon:ClearAnchors()
    self.barBG:ClearAnchors()
    self.fill:ClearAnchors()
    self.label:ClearAnchors()
    self.timerLabel:ClearAnchors()

    if self.sv.showIcon then
        self.iconBG:SetHidden(false)
        self.iconBG:SetDimensions(iconSize, iconSize)
        self.iconBG:SetAnchor(LEFT, self.control, LEFT, 0, 0)

        self.icon:SetDimensions(math.max(iconSize - 2, 1), math.max(iconSize - 2, 1))
        self.icon:SetAnchor(CENTER, self.iconBG, CENTER, 0, 0)
    else
        self.iconBG:SetHidden(true)
    end

    local barLeft = iconSize + gap
    self.barBG:SetAnchor(LEFT, self.control, LEFT, barLeft, 0)
    self.barBG:SetDimensions(barWidth, h)

    self.label:SetAnchor(CENTER, self.barBG, CENTER, 0, 0)
    self.timerLabel:SetAnchor(RIGHT, self.barBG, RIGHT, -6, 0)

    self:SetProgress(0)
end

function JCCB:SetProgress(progress)
    if not self.fill or not self.barBG then return end

    progress = Clamp(progress or 0, 0, 1)

    local innerHeight = math.max(self.sv.height - 2, 1)
    local innerWidth = math.max(self.sv.width - 2, 0)
    local fillWidth = math.floor(innerWidth * progress + 0.5)

    self.fill:ClearAnchors()

    if fillWidth <= 0 then
        self.fill:SetHidden(true)
        self.fill:SetDimensions(0, innerHeight)
        return
    end

    self.fill:SetHidden(false)

    if self.sv.reverseFill then
        self.fill:SetAnchor(TOPRIGHT, self.barBG, TOPRIGHT, -1, 1)
    else
        self.fill:SetAnchor(TOPLEFT, self.barBG, TOPLEFT, 1, 1)
    end

    self.fill:SetDimensions(fillWidth, innerHeight)
end

function JCCB:ApplySettings()
    if not self.control then return end

    self.control:SetScale(self.sv.scale)
    self.control:SetAlpha(self.sv.alpha)

    self:LayoutControls()

    self.barBG:SetHidden(not self.sv.showBackground)
    self.barBG:SetCenterColor(self.sv.bgR, self.sv.bgG, self.sv.bgB, self.sv.bgA)

    local r, g, b = self:GetCurrentClassColor()
    self.fill:SetCenterColor(r, g, b, 1)

    self.label:SetHidden(not self.sv.showName)
    self.timerLabel:SetHidden(not self.sv.showTimer)

    self.label:SetFont(string.format("ZoFontGameBold|%d|soft-shadow-thick", self.sv.fontSize))
    self.timerLabel:SetFont(string.format("ZoFontGameBold|%d|soft-shadow-thick", math.max(14, self.sv.fontSize - 2)))

    self:RefreshVisibility()
end

function JCCB:RefreshVisibility()
    if not self.control then return end

    if self.sv.unlocked then
        self.control:SetHidden(false)
        self:SetProgress(1.0)

        if self.sv.showName then
            self.label:SetText("Jacobs Channel Cast Bar")
        end
        if self.sv.showTimer then
            self.timerLabel:SetText("1.2")
        end
        return
    end

    self.control:SetHidden(not self.isCasting)
end

function JCCB:SetCurrentIcon(abilityId)
    if not self.icon or not self.iconBG then return end

    if not self.sv.showIcon then
        self.iconBG:SetHidden(true)
        return
    end

    local texture = GetAbilityIcon(abilityId)
    if texture and texture ~= "" then
        self.icon:SetTexture(texture)
    else
        self.icon:SetTexture("/esoui/art/icons/ability_warrior_001.dds")
    end

    self.iconBG:SetHidden(false)
end

function JCCB:StartCast(abilityId, abilityName, durationMs)
    durationMs = tonumber(durationMs) or 0
    if durationMs <= 0 then return end

    local now = GetGameTimeMilliseconds()

    -- анти-спам: если тот же channel уже идёт, не рестартуем
    if self.isCasting and self.castAbilityId == abilityId and now < self.castEndMs then
        if self.sv.debug then
            dmsg(string.format("IGNORE restart spam for %s [%d]", tostring(abilityName), abilityId))
        end
        return
    end

    if self.castAbilityId == abilityId and (now - self.lastStartStamp) < 100 then
        return
    end

    self.lastStartStamp = now
    self.isCasting = true
    self.castAbilityId = abilityId
    self.castAbilityName = abilityName or GetAbilityName(abilityId) or tostring(abilityId)
    self.castStartMs = now
    self.castDurationMs = durationMs
    self.castEndMs = now + durationMs

    self:SetCurrentIcon(abilityId)

    local r, g, b = self:GetCurrentClassColor()
    self.fill:SetCenterColor(r, g, b, 1)

    if self.sv.showName then
        self.label:SetText(zo_strformat("<<C:1>>", self.castAbilityName))
    end

    self:SetProgress(1.0)
    self.control:SetHidden(false)

    EVENT_MANAGER:RegisterForUpdate(self.name .. "_Update", 16, function()
        self:OnUpdate()
    end)

    if self.sv.debug then
        dmsg(string.format("START %s [%d] %.0fms", tostring(self.castAbilityName), abilityId, durationMs))
    end
end

function JCCB:StopCast(reason)
    if self.sv.debug and self.isCasting then
        dmsg("STOP " .. tostring(reason or ""))
    end

    self.isCasting = false
    self.castAbilityId = nil
    self.castAbilityName = ""
    self.castStartMs = 0
    self.castEndMs = 0
    self.castDurationMs = 0

    EVENT_MANAGER:UnregisterForUpdate(self.name .. "_Update")

    self:SetProgress(0)
    self.label:SetText("")
    self.timerLabel:SetText("")

    self:RefreshVisibility()
end

function JCCB:OnUpdate()
    if not self.isCasting then
        self:StopCast("not casting")
        return
    end

    if IsBlockActive and IsBlockActive() then
        self:StopCast("block")
        return
    end

    if IsUnitDead("player") then
        self:StopCast("dead")
        return
    end

    local now = GetGameTimeMilliseconds()
    local remaining = self.castEndMs - now

    if remaining <= 0 then
        self:StopCast("timer ended")
        return
    end

    local progress = Clamp(remaining / self.castDurationMs, 0, 1)
    self:SetProgress(progress)

    if self.sv.showTimer then
        self.timerLabel:SetText(string.format("%.1f", remaining / 1000))
    end
end

function JCCB:DebugScan(slotNum, slotType, rawId, abilityId, abilityName, isChanneled, durationMs, trackable)
    if not self.sv.scanMode then return end

    dmsg(string.format(
        "SCAN slot=%s slotType=%s rawId=%s resolvedId=%s name=%s chan=%s dur=%s trackable=%s",
        tostring(slotNum),
        tostring(slotType),
        tostring(rawId),
        tostring(abilityId),
        tostring(abilityName),
        tostring(isChanneled),
        tostring(durationMs),
        tostring(trackable)
    ))
end

function JCCB:OnActionSlotAbilityUsed(eventCode, slotNum)
    local hotbarCategory = GetActiveHotbarCategory()
    local abilityId, rawId, slotType = self:ResolveSlotAbilityId(slotNum, hotbarCategory)
    local abilityName = abilityId and GetAbilityName(abilityId) or "nil"
    local isChanneled, durationMs = self:GetAbilityCastData(abilityId)
    local trackable = self:IsTrackableAbility(abilityId)

    if self.sv.debug then
        dmsg(string.format(
            "RAW SLOT event=%s slot=%s rawId=%s abilityId=%s name=%s",
            tostring(eventCode), tostring(slotNum), tostring(rawId), tostring(abilityId), tostring(abilityName)
        ))
    end

    self:DebugScan(slotNum, slotType, rawId, abilityId, abilityName, isChanneled, durationMs, trackable)

    if not self.sv.enabled then return end
    if self.sv.unlocked then return end
    if not abilityId or abilityId == 0 then return end

    local ok
    ok, isChanneled, durationMs = self:IsTrackableAbility(abilityId)
    if not ok then
        return
    end

    self:StartCast(abilityId, abilityName, durationMs)
end

function JCCB:OnActiveWeaponPairChanged()
    if self.isCasting then
        self:StopCast("bar swap")
    end
end

function JCCB:OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
                             sourceName, sourceType, targetName, targetType, hitValue, powerType,
                             damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if not self.sv.enabled then return end
    if not self.isCasting then return end
    if not abilityId or abilityId == 0 then return end
    if self.castAbilityId ~= abilityId then return end

    if self.sv.debug then
        dmsg(string.format("COMBAT result=%s ability=%s [%d]", tostring(result), tostring(abilityName), abilityId))
    end

    if STOP_RESULTS[result] then
        self:StopCast("combat stop")
        return
    end
end

function JCCB:InitializeSavedVars()
    local worldName = GetWorldName()
    self.sv = ZO_SavedVars:NewAccountWide("JacobsChannelCastBar_SavedVars", 1, worldName, self.defaults)
end

function JCCB:RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTION_SLOT_ABILITY_USED, function(...)
        self:OnActionSlotAbilityUsed(...)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name .. "_WeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function(...)
        self:OnActiveWeaponPairChanged(...)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name .. "_Combat", EVENT_COMBAT_EVENT, function(...)
        self:OnCombatEvent(...)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
        self:RefreshVisibility()
        self:ApplySettings()
        if self.sv.debug then
            dmsg("PLAYER ACTIVATED")
        end
    end)
end

function JCCB:RegisterSlashCommands()
    SLASH_COMMANDS["/jccbunlock"] = function()
        self.sv.unlocked = true
        self:RefreshVisibility()
        dmsg("Unlocked")
    end

    SLASH_COMMANDS["/jccblock"] = function()
        self.sv.unlocked = false
        self:RefreshVisibility()
        dmsg("Locked")
    end

    SLASH_COMMANDS["/jccbreset"] = function()
        self.sv.x = 0
        self.sv.y = 200
        self:RestorePosition()
        dmsg("Position reset")
    end

    SLASH_COMMANDS["/jccbdebug"] = function()
        self.sv.debug = not self.sv.debug
        dmsg("Debug = " .. tostring(self.sv.debug))
    end

    SLASH_COMMANDS["/jccbscan"] = function()
        self.sv.scanMode = not self.sv.scanMode
        dmsg("ScanMode = " .. tostring(self.sv.scanMode))
    end

    SLASH_COMMANDS["/jccbtest"] = function()
        self:StartCast(1, "Test Channel", 4500)
    end
end

function JCCB:Initialize()
    self:InitializeSavedVars()
    self:CreateUI()
    self:RegisterEvents()
    self:RegisterSlashCommands()

    if self.RegisterSettings then
        self:RegisterSettings()
    end
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= JCCB.name then return end
    EVENT_MANAGER:UnregisterForEvent(JCCB.name .. "_Loaded", EVENT_ADD_ON_LOADED)
    JCCB:Initialize()
end

EVENT_MANAGER:RegisterForEvent(JCCB.name .. "_Loaded", EVENT_ADD_ON_LOADED, OnAddonLoaded)