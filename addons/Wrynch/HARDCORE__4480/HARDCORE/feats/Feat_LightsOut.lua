local HARDCORE = HARDCORE

local ID = "LightsOut"
local NS = "HARDCORE_LightsOut"

local MIN_INTERVAL_MS = 7 * 60 * 1000
local MAX_INTERVAL_MS = 11 * 60 * 1000
local BLACKOUT_DURATION_MS = 3000
local TICK_MS = 5000

local Rule = {
    id = ID,
    title = "Lights Out: darkness takes the wheel",
    icon = "/esoui/art/stealth/stealth_64.dds",
    defaultEnabled = false
}

Rule.active = false
Rule._nextBlackoutMs = 0
Rule._blackoutToken = 0

local overlayTLW
local blackMask

local function IsHardcoreActive()
    return HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive
end

local function GetRandomIntervalMs()
    return MIN_INTERVAL_MS + math.random(0, MAX_INTERVAL_MS - MIN_INTERVAL_MS)
end

local function ScheduleNextBlackout(nowMs)
    Rule._nextBlackoutMs = (nowMs or GetFrameTimeMilliseconds()) + GetRandomIntervalMs()
end

local function EnsureOverlay()
    if overlayTLW then
        return
    end

    local wm = WINDOW_MANAGER
    overlayTLW = wm:CreateTopLevelWindow("HARDCORE_LightsOutOverlay")
    overlayTLW:SetAnchorFill(GuiRoot)
    overlayTLW:SetDrawTier(DT_HIGH)
    overlayTLW:SetDrawLayer(DL_OVERLAY)
    overlayTLW:SetDrawLevel(10000)
    overlayTLW:SetClampedToScreen(true)
    overlayTLW:SetMouseEnabled(false)
    overlayTLW:SetHidden(true)

    blackMask = wm:CreateControl(nil, overlayTLW, CT_BACKDROP)
    blackMask:SetAnchorFill()
    blackMask:SetCenterColor(0, 0, 0, 1)
    blackMask:SetEdgeColor(0, 0, 0, 1)
    blackMask:SetAlpha(1)
end

local function HideBlackout()
    if overlayTLW then
        overlayTLW:SetHidden(true)
    end
end

local function ShowBlackout()
    EnsureOverlay()
    Rule._blackoutToken = Rule._blackoutToken + 1
    local token = Rule._blackoutToken

    overlayTLW:SetHidden(false)
    zo_callLater(function()
        if token == Rule._blackoutToken then
            HideBlackout()
        end
    end, BLACKOUT_DURATION_MS)
end

local function UpdateBlackout()
    if not (Rule.active and IsHardcoreActive()) then
        return
    end

    local nowMs = GetFrameTimeMilliseconds()
    if Rule._nextBlackoutMs <= 0 then
        ScheduleNextBlackout(nowMs)
        return
    end

    if nowMs >= Rule._nextBlackoutMs then
        ShowBlackout()
        ScheduleNextBlackout(nowMs)
    end
end

local function RegisterUpdate()
    EVENT_MANAGER:UnregisterForUpdate(NS .. "_TICK")
    if Rule.active then
        EVENT_MANAGER:RegisterForUpdate(NS .. "_TICK", TICK_MS, UpdateBlackout)
    end
end

local function UnregisterUpdate()
    EVENT_MANAGER:UnregisterForUpdate(NS .. "_TICK")
end

function Rule:OnEnable()
    self.active = true
    ScheduleNextBlackout(GetFrameTimeMilliseconds())
    RegisterUpdate()
end

function Rule:OnDisable()
    self.active = false
    self._nextBlackoutMs = 0
    self._blackoutToken = self._blackoutToken + 1
    HideBlackout()
    UnregisterUpdate()
end

function HARDCORE.DebugLightsOutStatus()
    local nowMs = GetFrameTimeMilliseconds()
    local remainingMs = math.max(0, (Rule._nextBlackoutMs or 0) - nowMs)
    d("Lights Out: active=" .. tostring(Rule.active) ..
        " nextBlackoutIn=" .. tostring(math.floor(remainingMs / 1000)) .. "s")
end

function HARDCORE.DebugLightsOutCommand(action)
    action = string.lower(action or "help")
    if action == "help" then
        d("Lights Out debug:")
        d("/hc debug lightsout status")
        d("/hc debug lightsout blackout")
        return
    end

    if action == "status" then
        HARDCORE.DebugLightsOutStatus()
        return
    end

    if action == "blackout" or action == "test" then
        ShowBlackout()
        HARDCORE.DebugLightsOutStatus()
        return
    end

    d("Unknown Lights Out debug action: " .. tostring(action))
end

HARDCORE.RuleManager:RegisterRule(Rule)
