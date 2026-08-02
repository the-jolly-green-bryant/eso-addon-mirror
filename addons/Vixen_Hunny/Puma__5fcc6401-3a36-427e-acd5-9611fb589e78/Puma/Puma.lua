Puma = {}
Puma.name = "Puma"
Puma.version = "1.0.0"
Puma.author = "Pixelles"
Puma.isLoaded = true
local em = EVENT_MANAGER
local am = ANIMATION_MANAGER
local wm = WINDOW_MANAGER

Puma.UI = {}

Puma.defaults_db = {
    resolveAlert = true,
    mendingAlert = true,
    courageAlert = true,
    minorResolveAlert = true,
    minorMendingAlert = true,
    minorCourageAlert = true,
    brutalityAlert = true,
    enableUptime = true,
    data = {
        "Major Resolve",
        "Major Mending",
        "Major Courage",
        "Minor Resolve",
        "Minor Courage",
        "Major Brutality",
    },
    selection = "Major Resolve",
    x = 500,
    y = 500,
    notifx = 0,
    notify = 0,
    barWidth = 340,
    barHeight = 24,
    scale = 1.0,
    fontSize = 24,
    hexcolor = "FF00CC",
    uptimeColor = "FF6A00",
}
-- Rolling uptime window (EWPFinder-style)
Puma.ROLL_SECONDS = 60          -- last 60 samples (60 seconds if sampled once per sec)
Puma.ROLL_UPDATE_MS = 1000      -- sample once per second

Puma.roll = {
    idx = 0,
    filled = 0,
    sums = {},      -- sums[buffName] = count of 1s in window
    samples = {},   -- samples[buffName][1..ROLL_SECONDS] = 0/1
}

-- Uptime settings
Puma.UPTIME_WINDOW_MS = 60000     -- 120s windowStart
Puma.UPTIME_UPDATE_MS = 100        -- UI refresh rate

Puma.uptime = {
    -- [effectName] = { intervals = { {sMs=..., eMs=...}, ... }, activeStartMs = nil }
}
local function IsPlayerBuffActive(buffName)
    for i = 1, GetNumBuffs("player") do
        local name = GetUnitBuffInfo("player", i)
        if name == buffName then
            return true
        end
    end
    return false
end

local function HexToRgb(hex)
    if type(hex) ~= "string" then
        return 1, 1, 1
    end

    local clean = hex:gsub("#", "")
    if #clean == 8 then
        clean = clean:sub(3, 8)
    end

    if #clean ~= 6 then
        return 1, 1, 1
    end

    local r = tonumber(clean:sub(1, 2), 16) or 255
    local g = tonumber(clean:sub(3, 4), 16) or 255
    local b = tonumber(clean:sub(5, 6), 16) or 255
    return r / 255, g / 255, b / 255
end

function Puma:SampleRollingAtIndex(buffName, isActive, idx)
    local r = self.roll
    r.samples[buffName] = r.samples[buffName] or {}
    r.sums[buffName] = r.sums[buffName] or 0

    local buf = r.samples[buffName]
    local old = buf[idx] or 0
    local new = isActive and 1 or 0

    r.sums[buffName] = r.sums[buffName] - old + new
    buf[idx] = new
end

function Puma:GetRollingPct(buffName)
    local r = self.roll
    local filled = math.max(1, r.filled or 1)
    local sum = r.sums[buffName] or 0
    return (sum / filled) * 100
end

--------------------------------------------------
-- UI
--------------------------------------------------
function Puma:SetAppearance()
    local container = wm:GetControlByName("PumaContainer") or wm:CreateTopLevelWindow("PumaContainer")
    container:SetDimensions(800, 50)
    container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, Puma.db.x, Puma.db.y)
    container:SetScale(Puma.db.scale)
    container:SetClampedToScreen(true)

    local label = wm:GetControlByName("PumaLabel") or wm:CreateControl("PumaLabel", container, CT_LABEL)
    label:SetAnchor(CENTER, container, CENTER, 0, 0)
    label:SetDimensions(800, 50)
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetFont(string.format("/esoui/common/fonts/univers67.otf|%d|soft-shadow-thick", Puma.db.fontSize))
    label:SetHidden(true)
    local uptimeRoot = wm:GetControlByName("PumaUptimeRoot") or wm:CreateControl("PumaUptimeRoot", container, CT_CONTROL)
    uptimeRoot:ClearAnchors()
    uptimeRoot:SetAnchor(CENTER, container, CENTER, Puma.db.notifx, Puma.db.notify)
    uptimeRoot:SetDimensions(Puma.db.barWidth, Puma.db.barHeight)
    uptimeRoot:SetHidden(true)

    local uptimeFrame = wm:GetControlByName("PumaUptimeFrame") or wm:CreateControlFromVirtual("PumaUptimeFrame", uptimeRoot, "ZO_DefaultBackdrop")
    uptimeFrame:ClearAnchors()
    uptimeFrame:SetAnchorFill(uptimeRoot)

    local uptimeBarBg = wm:GetControlByName("PumaUptimeBarBg") or wm:CreateControl("PumaUptimeBarBg", uptimeRoot, CT_STATUSBAR)
    uptimeBarBg:ClearAnchors()
    uptimeBarBg:SetAnchor(TOPLEFT, uptimeRoot, TOPLEFT, 2, 2)
    uptimeBarBg:SetAnchor(BOTTOMRIGHT, uptimeRoot, BOTTOMRIGHT, -2, -2)
    uptimeBarBg:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill.dds")
    uptimeBarBg:SetMinMax(0, 100)
    uptimeBarBg:SetValue(100)

    local uptimeBar = wm:GetControlByName("PumaUptimeBar") or wm:CreateControl("PumaUptimeBar", uptimeRoot, CT_STATUSBAR)
    uptimeBar:ClearAnchors()
    uptimeBar:SetAnchor(TOPLEFT, uptimeRoot, TOPLEFT, 2, 2)
    uptimeBar:SetAnchor(BOTTOMRIGHT, uptimeRoot, BOTTOMRIGHT, -2, -2)
    uptimeBar:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill.dds")
    uptimeBar:SetMinMax(0, 100)
    uptimeBar:SetValue(0)

    local uptimeSheen = wm:GetControlByName("PumaUptimeSheen") or wm:CreateControl("PumaUptimeSheen", uptimeRoot, CT_STATUSBAR)
    uptimeSheen:ClearAnchors()
    uptimeSheen:SetAnchor(TOPLEFT, uptimeRoot, TOPLEFT, 2, 2)
    uptimeSheen:SetAnchor(BOTTOMRIGHT, uptimeRoot, CENTER, -2, -1)
    uptimeSheen:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill.dds")
    uptimeSheen:SetMinMax(0, 100)
    uptimeSheen:SetValue(0)

    local uptimeGlow = wm:GetControlByName("PumaUptimeGlow") or wm:CreateControlFromVirtual("PumaUptimeGlow", uptimeRoot, "ZO_DefaultBackdrop")
    uptimeGlow:ClearAnchors()
    uptimeGlow:SetAnchor(TOPLEFT, uptimeRoot, TOPLEFT, -2, -2)
    uptimeGlow:SetAnchor(BOTTOMRIGHT, uptimeRoot, BOTTOMRIGHT, 2, 2)

    local uptimeName = wm:GetControlByName("PumaUptimeName") or wm:CreateControl("PumaUptimeName", uptimeRoot, CT_LABEL)
    uptimeName:ClearAnchors()
    uptimeName:SetAnchor(BOTTOMLEFT, uptimeRoot, TOPLEFT, 2, -2)
    uptimeName:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    uptimeName:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    uptimeName:SetFont(string.format("/esoui/common/fonts/univers67.otf|%d|soft-shadow-thick", math.max(14, Puma.db.fontSize - 8)))

    local uptimeStats = wm:GetControlByName("PumaUptimeStats") or wm:CreateControl("PumaUptimeStats", uptimeRoot, CT_LABEL)
    uptimeStats:ClearAnchors()
    uptimeStats:SetAnchor(BOTTOMRIGHT, uptimeRoot, TOPRIGHT, -2, -2)
    uptimeStats:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    uptimeStats:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    uptimeStats:SetFont(string.format("/esoui/common/fonts/univers57.otf|%d|soft-shadow-thin", math.max(12, Puma.db.fontSize - 10)))

    local uptimeCenter = wm:GetControlByName("PumaUptimeCenter") or wm:CreateControl("PumaUptimeCenter", uptimeRoot, CT_LABEL)
    uptimeCenter:ClearAnchors()
    uptimeCenter:SetAnchor(CENTER, uptimeRoot, CENTER, 0, 0)
    uptimeCenter:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    uptimeCenter:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    uptimeCenter:SetFont(string.format("/esoui/common/fonts/univers67.otf|%d|soft-shadow-thick", math.max(12, Puma.db.fontSize - 8)))

    local r, g, b = HexToRgb(Puma.db.uptimeColor or Puma.db.hexcolor)
    uptimeBarBg:SetColor(0.13, 0.07, 0.03, 0.85)
    uptimeBar:SetColor(r, g, b, 0.95)
    uptimeSheen:SetColor(math.min(1, r + 0.25), math.min(1, g + 0.2), math.min(1, b + 0.2), 0.28)
    uptimeFrame:SetCenterColor(0.07, 0.04, 0.02, 0.92)
    uptimeFrame:SetEdgeColor(math.min(1, r + 0.2), math.min(1, g + 0.18), math.min(1, b + 0.16), 1)
    uptimeGlow:SetCenterColor(0, 0, 0, 0)
    uptimeGlow:SetEdgeColor(math.min(1, r + 0.25), math.min(1, g + 0.22), math.min(1, b + 0.2), 0.55)
    uptimeName:SetColor(1, 0.88, 0.65, 1)
    uptimeStats:SetColor(1, 0.88, 0.65, 1)
    uptimeCenter:SetColor(1, 0.96, 0.82, 1)

    Puma.UI.container = container
    Puma.UI.label = label
    Puma.UI.uptimeRoot = uptimeRoot
    Puma.UI.uptimeBarBg = uptimeBarBg
    Puma.UI.uptimeBar = uptimeBar
    Puma.UI.uptimeSheen = uptimeSheen
    Puma.UI.uptimeGlow = uptimeGlow
    Puma.UI.uptimeName = uptimeName
    Puma.UI.uptimeStats = uptimeStats
    Puma.UI.uptimeCenter = uptimeCenter
end
local function nowMs()
    return GetGameTimeMilliseconds()
end

function Puma:GetUptimeState(effectName)
    Puma.uptime[effectName] = Puma.uptime[effectName] or { intervals = {}, activeStartMs = nil }
    return Puma.uptime[effectName]
end

function Puma:TrimIntervals(effectName, now)
    local st = Puma:GetUptimeState(effectName)
    local cutoff = now - Puma.UPTIME_WINDOW_MS

    -- If currently active, we keep activeStartMs as-is (but clamp later when calculating)
    -- Trim/adjust stored intervals
    local out = {}
    for i = 1, #st.intervals do
        local seg = st.intervals[i]
        local s = seg.sMs
        local e = seg.eMs

        -- Skip segments entirely before cutoff
        if e > cutoff then
            -- Clamp start to cutoff
            s = math.max(s, cutoff)
            -- Ensure sane ordering
            if e > s then
                out[#out + 1] = { sMs = s, eMs = e }
            end
        end
    end
    st.intervals = out
end

function Puma:PushClosedInterval(effectName, sMs, eMs)
    if not sMs or not eMs then return end
    if eMs <= sMs then return end

    local st = Puma:GetUptimeState(effectName)
    st.intervals[#st.intervals + 1] = { sMs = sMs, eMs = eMs }
end

function Puma:GetUptimeDowntime(effectName, now)
    local st = Puma:GetUptimeState(effectName)
    local windowStart = now - Puma.UPTIME_WINDOW_MS
    local windowLen = Puma.UPTIME_WINDOW_MS

    self:TrimIntervals(effectName, now)

    local uptimeMs = 0

    -- closed intervals
    for i = 1, #st.intervals do
        local seg = st.intervals[i]
        local s = math.max(seg.sMs, windowStart)
        local e = math.min(seg.eMs, now)
        if e > s then
            uptimeMs = uptimeMs + (e - s)
        end
    end

    -- currently-active interval
    if st.activeStartMs then
        local s = math.max(st.activeStartMs, windowStart)
        local e = now
        if e > s then
            uptimeMs = uptimeMs + (e - s)
        end
    end

    -- clamp uptime into [0, windowLen]
    uptimeMs = math.max(0, math.min(uptimeMs, windowLen))

    local downtimeMs = windowLen - uptimeMs
    downtimeMs = math.max(0, math.min(downtimeMs, windowLen))

    local uptimePct = (uptimeMs / windowLen) * 100.0
    local downtimePct = (downtimeMs / windowLen) * 100.0

    return uptimeMs, downtimeMs, uptimePct, downtimePct
end


--------------------------------------------------
-- Animation
--------------------------------------------------
function Puma:PlayAlert(text)
    local label = Puma.UI.label
    local container = Puma.UI.container

    label:SetText(text)
    label:SetAlpha(1.0)
    label:SetHidden(false)
    container:SetHidden(false)

    local anim = am:CreateTimeline()
    anim:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)

    local move = anim:InsertAnimation(ANIMATION_TRANSLATE, label, 0)
    move:SetTranslateOffsets(Puma.db.x, Puma.db.y, Puma.db.x - zo_random(50, 150), Puma.db.y - zo_random(50, 150))
    move:SetDuration(1500)
    move:SetEasingFunction(EASING_FUNCTION_QUADRATIC_IN_OUT)

    local fade = anim:InsertAnimation(ANIMATION_ALPHA, label, 1500)
    fade:SetAlphaValues(label:GetAlpha(), 0)
    fade:SetDuration(500)

    anim:SetHandler("OnStop", function()
        label:SetHidden(true)
    end)

    anim:PlayFromStart()
end
function Puma:UpdateUI()
    local uptimeRoot = self.UI.uptimeRoot

    if not Puma.db or not Puma.db.enableUptime then
        if uptimeRoot then uptimeRoot:SetHidden(true) end
        return
    end

    local buffName = Puma.db.selection
    if not buffName or buffName == "" then
        if uptimeRoot then uptimeRoot:SetHidden(true) end
        return
    end

    if not self.UI.uptimeBar then
        return
    end

    -- Ensure roll table exists
    self.ROLL_SECONDS = self.ROLL_SECONDS or 60
    self.roll = self.roll or { idx = 0, filled = 0, sums = {}, samples = {} }

    local r = self.roll
    local win = self.ROLL_SECONDS

    -- Advance index ONCE per tick
    r.idx = (r.idx % win) + 1
    r.filled = math.min(win, (r.filled or 0) + 1)

    -- Sample selected buff into the SAME idx
    local active = IsPlayerBuffActive(buffName)
    self:SampleRollingAtIndex(buffName, active, r.idx)

    local upPct = self:GetRollingPct(buffName)
    local downPct = 100 - upPct

    local rr, gg, bb = HexToRgb(self.db.uptimeColor or self.db.hexcolor)
    local upNorm = zo_clamp(upPct / 100, 0, 1)
    local heat = 1 - upNorm
    local mainR = zo_clamp(rr + (0.30 * heat), 0, 1)
    local mainG = zo_clamp((gg * (0.75 + (0.25 * upNorm))) + (0.10 * heat), 0, 1)
    local mainB = zo_clamp(bb * (0.65 + (0.35 * upNorm)), 0, 1)
    local blink = (r.idx % 2 == 0) and 1 or 0.7

    self.UI.uptimeBarBg:SetValue(100)
    self.UI.uptimeBarBg:SetColor(0.13, 0.07, 0.03, 0.85)
    self.UI.uptimeBar:SetColor(mainR, mainG, mainB, 0.96)
    self.UI.uptimeBar:SetValue(upPct)
    self.UI.uptimeSheen:SetColor(math.min(1, mainR + 0.2), math.min(1, mainG + 0.2), math.min(1, mainB + 0.2), 0.30)
    self.UI.uptimeSheen:SetValue(upPct)
    self.UI.uptimeGlow:SetEdgeColor(
        math.min(1, mainR + 0.22),
        math.min(1, mainG + 0.15),
        math.min(1, mainB + 0.12),
        (0.35 + (0.5 * heat)) * blink
    )
    self.UI.uptimeName:SetText(buffName)
    self.UI.uptimeCenter:SetText(string.format("%.1f%%", upPct))
    self.UI.uptimeStats:SetText(string.format("DOWN %.1f%%", downPct))
    uptimeRoot:SetHidden(false)
end


--------------------------------------------------
-- Effect Logic
--------------------------------------------------
function Puma:EffectExpired(effectName)
    local c = Puma.db.hexcolor

    local messages = {
        ["Major Resolve"]   = Puma.db.resolveAlert       and "Major Resolve requires rebuff!!",
        ["Major Mending"]   = Puma.db.mendingAlert       and "Major Mending requires rebuff!!",
        ["Major Courage"]   = Puma.db.courageAlert       and "Major Courage requires rebuff!!",
        ["Minor Resolve"]   = Puma.db.minorResolveAlert  and "Minor Resolve requires rebuff!!",
        ["Minor Mending"]   = Puma.db.minorMendingAlert  and "Minor Mending requires rebuff!!",
        ["Minor Courage"]   = Puma.db.minorCourageAlert  and "Minor Courage requires rebuff!!",
        ["Major Brutality"] = Puma.db.brutalityAlert     and "Major Brutality/Sorcery requires rebuff!!",
    }

    if messages[effectName] then
        Puma:PlayAlert(string.format("|c%s%s|r", c, messages[effectName]))
    end
end
--------------------------------------------------
-- EVENT_EFFECT_CHANGED
--------------------------------------------------
function Puma:OnEffectChanged(_, changeType, _, effectName, unitTag, beginTime, endTime)
    if unitTag ~= "player" then return end

    local st = Puma:GetUptimeState(effectName)
    local t = nowMs()

    -- Track active window intervals
    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        -- Start tracking if not already active
        if not st.activeStartMs then
            st.activeStartMs = t
        end

    elseif changeType == EFFECT_RESULT_FADED then
        -- Close interval if it was active
        if st.activeStartMs then
            self:PushClosedInterval(effectName, st.activeStartMs, t)
            st.activeStartMs = nil
        end

        -- Your existing rebuff alert
        Puma:EffectExpired(effectName)
    end
end


--------------------------------------------------
-- Init
--------------------------------------------------
function Puma:Initialize()
    Puma.db = ZO_SavedVars:New("PumaSettings", 2, nil, Puma.defaults_db)

    Puma:SetAppearance()

    em:RegisterForEvent(
    "Puma_EffectChanged",
    EVENT_EFFECT_CHANGED,
    function(...) Puma:OnEffectChanged(...) end
    )

    -- Update loop for uptime UI
    -- Rolling uptime update (EWPFinder-like)
    em:RegisterForUpdate("Puma_Rolling_Uptime", Puma.ROLL_UPDATE_MS, function()
        Puma:UpdateUI()
    end)


end

em:RegisterForEvent("Puma_Load", EVENT_ADD_ON_LOADED, function(_, name)
    if name == "Puma" and Puma.isLoaded == true then
        Puma:Initialize()
    end
end)