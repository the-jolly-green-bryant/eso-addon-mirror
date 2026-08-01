NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local Progress = {}

local EVENT_NAMESPACE = "NQOL_Progress"
local UPDATE_INTERVAL_MS = 1000
local TEXTURE_CHAMPION = "EsoUI/Art/Champion/champion_icon_32.dds"
local DRAW_LEVEL = 215
local DEFAULT_FONT_SIZE = 18
local FONT_SIZE_MIN = 12
local FONT_SIZE_MAX = 30
local DEFAULT_BACKGROUND_OPACITY = 0
local BACKGROUND_OPACITY_MIN = 0
local BACKGROUND_OPACITY_MAX = 100
local HUD_WIDTH_MAX = 500
local HUD_PADDING = 14
local HEADER_PROGRESS_GAP = 10
local HEADER_MIN_WIDTH = 1
local UNDERLINE_HEIGHT = 3
local UNDERLINE_GAP = 2
local ENLIGHTENMENT_GAP = 8
-- ESO caps accumulated Enlightenment at twelve daily 400,000-XP allotments.
local ENLIGHTENMENT_MAX_XP = 4800000
local GOAL_GAP = 8
local TIMER_GAP = 14
local CARD_GAP = 8
local CARD_COLUMNS = 3
local CARD_ACCENT_WIDTH = 4
local CP_ICON_SIZE = 20
local CHART_BAR_COUNT = 60
local CHART_HEIGHT = 44
local CHART_GAP = 12
local CHART_MIN_BAR_HEIGHT = 1
local DEFAULT_PROGRESS_ESTIMATOR = "15m"
local MAX_WINDOW_SECONDS = 60 * 60
local GAMEPLAY_SCENES = {
    hud = true,
    hudui = true,
    siegeBar = true,
}

local WINDOWS = {
    { key = "1m", label = NQOL.L("features.progress.1m_dc4ea83"), hudLabel = "[1m]", seconds = 60 },
    { key = "5m", label = NQOL.L("features.progress.5m_def1139"), hudLabel = "[5m]", seconds = 5 * 60 },
    { key = "15m", label = NQOL.L("features.progress.15m_edbb97d"), hudLabel = "[15m]", seconds = 15 * 60 },
    { key = "30m", label = NQOL.L("features.progress.30m_c5dca4f"), hudLabel = "[30m]", seconds = 30 * 60 },
    { key = "45m", label = NQOL.L("features.progress.45m_cdefcc5"), hudLabel = "[45m]", seconds = 45 * 60 },
    { key = "60m", label = NQOL.L("features.progress.60m_ccd4d27"), hudLabel = "[60m]", seconds = 60 * 60 },
}
NQOL.Lexicon.RegisterTableField(WINDOWS, "label", {
    "features.progress.1m_dc4ea83", "features.progress.5m_def1139", "features.progress.15m_edbb97d",
    "features.progress.30m_c5dca4f", "features.progress.45m_cdefcc5", "features.progress.60m_ccd4d27",
})

local defaults = {
    progress = {
        xp = {
            enabled = false,
            showInSettings = true,
            horizontalPosition = 78,
            verticalPosition = 35,
            font = NQOL.Util.GetDefaultFont(),
            fontSize = 24,
            backgroundOpacity = 90,
            progressEstimator = DEFAULT_PROGRESS_ESTIMATOR,
            showXpBar = true,
            showEnlightenment = false,
            showGoal = true,
            showTrackers = true,
            showChart = true,
            timers = {},
        },
    },
}

for _, window in ipairs(WINDOWS) do
    defaults.progress.xp.timers[window.key] = true
end

local savedVariables
local initialized = false
local settingsPanelVisible = false
local sceneCallbackInstalled = false
local eventsRegistered = false
local control
local headerLabel
local progressLabel
local progressTrack
local progressFill
local enlightenmentValueLabel
local enlightenmentTrack
local enlightenmentFill
local goalNameLabel
local goalEstimateLabel
local emptyMessageLabel
local chartArea
local chartBaseline
local chartBars = {}
local cards = {}
local samples = {}
local timerStartedAt = {}
local goalStartedAt
local chartBuckets = {}
local chartCurrentMinute
local lastProgress
local lastSampledProgress = {}
local fontStringCache = {}

local Clamp = NQOL.Util.Clamp
local Round = NQOL.Util.Round
local FormatNumber = NQOL.Util.FormatNumber

local VALID_WINDOW_KEYS = {}
for _, window in ipairs(WINDOWS) do
    VALID_WINDOW_KEYS[window.key] = true
end

local function GetSettings()
    local progress = NQOL.Settings.GetSection(savedVariables, defaults, "progress")
    local xpDefaults = defaults.progress.xp

    if type(progress.xp) ~= "table" then
        progress.xp = {}
    end

    local settings = progress.xp
    NQOL.Settings.Boolean(settings, xpDefaults, "enabled")
    NQOL.Settings.Boolean(settings, xpDefaults, "showInSettings")
    NQOL.Settings.ClampedNumber(settings, xpDefaults, "horizontalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, xpDefaults, "verticalPosition", 0, 100)
    if not NQOL.Util.IsFontChoice(settings.font) then
        settings.font = xpDefaults.font
    end
    NQOL.Settings.ClampedNumber(settings, xpDefaults, "fontSize", FONT_SIZE_MIN, FONT_SIZE_MAX, true)
    NQOL.Settings.ClampedNumber(settings, xpDefaults, "backgroundOpacity", BACKGROUND_OPACITY_MIN, BACKGROUND_OPACITY_MAX, true)
    NQOL.Settings.Boolean(settings, xpDefaults, "showXpBar")
    NQOL.Settings.Boolean(settings, xpDefaults, "showEnlightenment")
    NQOL.Settings.Boolean(settings, xpDefaults, "showGoal")
    NQOL.Settings.Boolean(settings, xpDefaults, "showTrackers")
    NQOL.Settings.Boolean(settings, xpDefaults, "showChart")
    if VALID_WINDOW_KEYS[settings.progressEstimator] ~= true then
        settings.progressEstimator = xpDefaults.progressEstimator
    end
    NQOL.Settings.EnsureTable(settings, "timers")

    for _, window in ipairs(WINDOWS) do
        NQOL.Settings.DefaultFrom(settings.timers, window.key, xpDefaults.timers[window.key])
        settings.timers[window.key] = settings.timers[window.key] == true
    end

    return settings
end

local function GetNow()
    if GetFrameTimeSeconds then
        return GetFrameTimeSeconds()
    end

    if GetFrameTimeMilliseconds then
        return GetFrameTimeMilliseconds() / 1000
    end

    return os and os.time and os.time() or 0
end

local function GetEnlightenmentAmount()
    if not IsEnlightenedAvailableForCharacter
        or IsEnlightenedAvailableForCharacter() ~= true
        or not GetEnlightenedPool
        or not GetEnlightenedMultiplier
    then
        return 0
    end

    local pool = math.max(tonumber(GetEnlightenedPool()) or 0, 0)
    local multiplier = math.max(tonumber(GetEnlightenedMultiplier()) or 0, 0)
    return Round(pool * (multiplier + 1))
end

local function ShouldRenderEnlightenment()
    return GetSettings().showEnlightenment == true and GetEnlightenmentAmount() > 0
end

local function MoveControlAbove(targetControl, drawLevel)
    if not targetControl then
        return
    end

    if targetControl.SetDrawLayer and DL_OVERLAY then
        targetControl:SetDrawLayer(DL_OVERLAY)
    end

    if targetControl.SetDrawTier and DT_HIGH then
        targetControl:SetDrawTier(DT_HIGH)
    end

    if targetControl.SetDrawLevel then
        targetControl:SetDrawLevel(drawLevel or DRAW_LEVEL)
    end
end

local function ResolveFont(sizeOffset)
    local settings = GetSettings()
    local size = Clamp((tonumber(settings.fontSize) or DEFAULT_FONT_SIZE) + (sizeOffset or 0), FONT_SIZE_MIN, FONT_SIZE_MAX + 8)
    local key = tostring(settings.font) .. ":" .. tostring(size)
    if not fontStringCache[key] then
        fontStringCache[key] = NQOL.Util.CreateFontString(settings.font, size, "ZoFontGamepad18")
    end

    return fontStringCache[key]
end

local function GetFontSize(sizeOffset)
    return Clamp((tonumber(GetSettings().fontSize) or DEFAULT_FONT_SIZE) + (sizeOffset or 0), FONT_SIZE_MIN, FONT_SIZE_MAX + 8)
end

local function GetLineHeight(sizeOffset)
    return GetFontSize(sizeOffset) + 6
end

local function GetHeaderHeight()
    return math.max(GetLineHeight(4), GetLineHeight(0))
end

local function GetGoalHeight()
    return math.max(GetLineHeight(-4), GetLineHeight(-5))
end

local function GetProgressBarHeight()
    return GetHeaderHeight() + UNDERLINE_GAP + UNDERLINE_HEIGHT
end

local function GetHudWidth()
    return HUD_WIDTH_MAX
end

local function GetCardHeight()
    return 8 + GetLineHeight(-4) + GetLineHeight(2) + GetLineHeight(-5) + 6
end

local function GetTimersHeight(timerRows)
    timerRows = tonumber(timerRows) or 0
    if timerRows <= 0 then
        return 0
    end

    return (GetCardHeight() * timerRows) + (CARD_GAP * math.max(timerRows - 1, 0))
end

local function GetProgressBarsBottom()
    local settings = GetSettings()
    local top = HUD_PADDING
    if settings.showXpBar == true then
        top = top + GetProgressBarHeight()
    end

    if ShouldRenderEnlightenment() then
        if top > HUD_PADDING then
            top = top + ENLIGHTENMENT_GAP
        end
        top = top + GetProgressBarHeight()
    end

    return top
end

local function GetEnlightenmentTop()
    local top = HUD_PADDING
    if GetSettings().showXpBar == true then
        top = top + GetProgressBarHeight() + ENLIGHTENMENT_GAP
    end

    return top
end

local function GetGoalTop()
    local top = GetProgressBarsBottom()
    if top > HUD_PADDING then
        top = top + GOAL_GAP
    end

    return top
end

local function GetTimersTop()
    local top = GetProgressBarsBottom()

    if GetSettings().showGoal == true then
        if top > HUD_PADDING then
            top = top + GOAL_GAP
        end
        top = top + GetGoalHeight()
    end

    if top > HUD_PADDING then
        top = top + TIMER_GAP
    end

    return top
end

local function GetChartTop(timerRows)
    local top = GetProgressBarsBottom()

    if GetSettings().showGoal == true then
        if top > HUD_PADDING then
            top = top + GOAL_GAP
        end
        top = top + GetGoalHeight()
    end

    if GetSettings().showTrackers == true and timerRows > 0 then
        if top > HUD_PADDING then
            top = top + TIMER_GAP
        end
        top = top + GetTimersHeight(timerRows)
    end

    if top > HUD_PADDING then
        top = top + CHART_GAP
    end

    return top
end

local function AreAnyHudSectionsEnabled()
    local settings = GetSettings()
    return settings.showXpBar == true
        or ShouldRenderEnlightenment()
        or settings.showGoal == true
        or settings.showTrackers == true
        or settings.showChart == true
end

local function GetEmptyMessageHeight()
    return GetLineHeight(-3)
end

local function GetEnabledWindows()
    local timers = GetSettings().timers
    local enabledWindows = {}

    for _, window in ipairs(WINDOWS) do
        if timers[window.key] == true then
            enabledWindows[#enabledWindows + 1] = window
        end
    end

    return enabledWindows
end

local function HasEnabledTimers()
    local timers = GetSettings().timers
    for _, window in ipairs(WINDOWS) do
        if timers[window.key] == true then
            return true
        end
    end

    return false
end

local function ShouldCollectXpHistory()
    local settings = GetSettings()
    return HasEnabledTimers() or settings.showGoal == true or settings.showChart == true
end

local function ShouldCollectWindowHistory()
    return HasEnabledTimers() or GetSettings().showGoal == true
end

local function GetLongestWindowHistorySeconds()
    local settings = GetSettings()
    local timers = settings.timers
    local longest = 0
    for _, window in ipairs(WINDOWS) do
        if timers[window.key] == true
            or (settings.showGoal == true and settings.progressEstimator == window.key)
        then
            longest = math.max(longest, window.seconds)
        end
    end

    return longest
end

local function EnsureEnabledTimerStartTimes()
    local now = GetNow()
    local timers = GetSettings().timers
    for _, window in ipairs(WINDOWS) do
        if timers[window.key] == true then
            timerStartedAt[window.key] = timerStartedAt[window.key] or now
        else
            timerStartedAt[window.key] = nil
        end
    end
end

local function EnsureGoalStartTime()
    if GetSettings().showGoal == true then
        goalStartedAt = goalStartedAt or GetNow()
    else
        goalStartedAt = nil
    end
end

local function GetHudHeight()
    local settings = GetSettings()
    if not AreAnyHudSectionsEnabled() then
        return HUD_PADDING + GetEmptyMessageHeight() + HUD_PADDING
    end

    local height = GetProgressBarsBottom()

    if settings.showGoal == true then
        if height > HUD_PADDING then
            height = height + GOAL_GAP
        end
        height = height + GetGoalHeight()
    end

    if settings.showTrackers == true then
        local timerRows = math.ceil(#GetEnabledWindows() / CARD_COLUMNS)
        if timerRows > 0 then
            if height > HUD_PADDING then
                height = height + TIMER_GAP
            end
            height = height + GetTimersHeight(timerRows)
        end
    end

    if settings.showChart == true then
        if height > HUD_PADDING then
            height = height + CHART_GAP
        end
        height = height + CHART_HEIGHT
    end

    return height + HUD_PADDING
end

local function GetCurrentChampionPoints()
    if GetPlayerChampionPointsEarned then
        return GetPlayerChampionPointsEarned()
    end

    if GetUnitChampionPoints then
        return GetUnitChampionPoints("player")
    end

    return 0
end

local function IsChampionProgression()
    return CanUnitGainChampionPoints and CanUnitGainChampionPoints("player") == true
end

local function GetProgress()
    local current = 0
    local maximum = 0
    local label = NQOL.L("features.progress.xp_53af638")

    if IsChampionProgression() and GetPlayerChampionXP and GetNumChampionXPInChampionPoint then
        local championPoints = tonumber(GetCurrentChampionPoints()) or 0
        current = tonumber(GetPlayerChampionXP()) or 0
        maximum = tonumber(GetNumChampionXPInChampionPoint(championPoints)) or 0
        label = NQOL.L("features.progress.cp_xp_85779db")
    elseif GetUnitXP and GetUnitXPMax then
        current = tonumber(GetUnitXP("player")) or 0
        maximum = tonumber(GetUnitXPMax("player")) or 0
    end

    return {
        current = current,
        maximum = maximum,
        label = label,
    }
end

local function GetEnlightenmentProgress()
    return {
        current = GetEnlightenmentAmount(),
        maximum = ENLIGHTENMENT_MAX_XP,
    }
end

local function PruneSamples(now)
    now = now or GetNow()
    local longestWindowSeconds = GetLongestWindowHistorySeconds()
    if longestWindowSeconds <= 0 then
        for index = #samples, 1, -1 do
            samples[index] = nil
        end
        return
    end

    local cutoff = now - math.min(longestWindowSeconds, MAX_WINDOW_SECONDS)
    local firstKept = 1

    while samples[firstKept] and samples[firstKept].time < cutoff do
        firstKept = firstKept + 1
    end

    if firstKept > 1 then
        for index = firstKept, #samples do
            samples[index - firstKept + 1] = samples[index]
        end
        for index = #samples, #samples - firstKept + 2, -1 do
            samples[index] = nil
        end
    end
end

local function EnsureChartBuckets()
    for index = 1, CHART_BAR_COUNT do
        if type(chartBuckets[index]) ~= "number" then
            chartBuckets[index] = 0
        end
    end

    for index = #chartBuckets, CHART_BAR_COUNT + 1, -1 do
        chartBuckets[index] = nil
    end
end

local function ShiftChartBuckets(count)
    count = math.min(math.max(tonumber(count) or 0, 0), CHART_BAR_COUNT)
    if count <= 0 then
        return
    end

    EnsureChartBuckets()

    for _ = 1, count do
        for index = 1, CHART_BAR_COUNT - 1 do
            chartBuckets[index] = chartBuckets[index + 1] or 0
        end
        chartBuckets[CHART_BAR_COUNT] = 0
    end
end

local function AdvanceChartToMinute(minute)
    minute = tonumber(minute)
    if not minute then
        return
    end

    EnsureChartBuckets()

    if not chartCurrentMinute then
        chartCurrentMinute = minute
        return
    end

    if minute > chartCurrentMinute then
        ShiftChartBuckets(minute - chartCurrentMinute)
        chartCurrentMinute = minute
    elseif minute < chartCurrentMinute then
        chartCurrentMinute = minute
    end
end

local function AdvanceChartToNow()
    AdvanceChartToMinute(math.floor(GetNow() / 60))
end

local function AddChartGain(amount, now)
    amount = tonumber(amount) or 0
    if amount <= 0 then
        return
    end

    AdvanceChartToMinute(math.floor((now or GetNow()) / 60))
    chartBuckets[CHART_BAR_COUNT] = (chartBuckets[CHART_BAR_COUNT] or 0) + amount
end

local function GetWindowByKey(windowKey)
    for _, window in ipairs(WINDOWS) do
        if window.key == windowKey then
            return window
        end
    end

    return WINDOWS[3]
end

local function AddSample(amount, progress)
    amount = tonumber(amount) or 0
    local collectWindowHistory = ShouldCollectWindowHistory()
    local collectChartHistory = GetSettings().showChart == true
    if amount <= 0 or (not collectWindowHistory and not collectChartHistory) then
        return
    end

    if progress and progress.label then
        if lastSampledProgress[progress.label] == progress.current then
            return
        end

        lastSampledProgress[progress.label] = progress.current
    end

    local now = GetNow()
    if collectWindowHistory then
        samples[#samples + 1] = {
            time = now,
            amount = amount,
        }
        PruneSamples(now)
    end
    if collectChartHistory then
        AddChartGain(amount, now)
    end
end

local function ClearWindowSamples()
    for index = #samples, 1, -1 do
        samples[index] = nil
    end
end

local function ClearWindowHistory()
    ClearWindowSamples()
    for timerKey in pairs(timerStartedAt) do
        timerStartedAt[timerKey] = nil
    end
    goalStartedAt = nil
end

local function ClearChartHistory()
    for index = #chartBuckets, 1, -1 do
        chartBuckets[index] = nil
    end

    chartCurrentMinute = nil
end

local function ResetRuntimeTimers()
    ClearWindowHistory()
    ClearChartHistory()
    lastSampledProgress = {}
    lastProgress = GetProgress()
    EnsureEnabledTimerStartTimes()
    EnsureGoalStartTime()

    if GetSettings().showChart == true then
        EnsureChartBuckets()
        AdvanceChartToNow()
    end
end

local function ResetRuntimeState()
    ClearWindowHistory()
    ClearChartHistory()
    lastProgress = nil
    for key in pairs(lastSampledProgress) do
        lastSampledProgress[key] = nil
    end
end

local function ComputeWindow(window, startedAt)
    if not window or not startedAt then
        return 0, 0
    end

    local now = GetNow()
    local windowSeconds = window.seconds
    local cutoff = math.max(now - windowSeconds, startedAt)
    local gain = 0
    local oldest

    PruneSamples(now)

    for _, sample in ipairs(samples) do
        if sample.time >= cutoff then
            gain = gain + sample.amount
            if not oldest or sample.time < oldest then
                oldest = sample.time
            end
        end
    end

    local elapsedSeconds = windowSeconds
    if oldest then
        elapsedSeconds = math.min(windowSeconds, math.max(now - oldest, 1))
    end

    local rate = 0
    if gain > 0 then
        rate = gain / (elapsedSeconds / 60)
    end

    return gain, rate
end

local function GetNormalXpRemainingToLevel50(progress)
    if not GetUnitLevel or not GetNumExperiencePointsInLevel then
        return nil
    end

    local level = tonumber(GetUnitLevel("player")) or 0
    if level >= 50 then
        return 0
    end

    local remaining = 0
    local current = progress and tonumber(progress.current) or (GetUnitXP and tonumber(GetUnitXP("player")) or 0)
    local maximum = progress and tonumber(progress.maximum) or (GetUnitXPMax and tonumber(GetUnitXPMax("player")) or 0)
    if maximum and maximum > 0 then
        remaining = remaining + math.max(maximum - (current or 0), 0)
    end

    for futureLevel = level + 1, 49 do
        remaining = remaining + (tonumber(GetNumExperiencePointsInLevel(futureLevel)) or 0)
    end

    return remaining
end

local function GetChampionXpRemainingToTarget(targetChampionPoints, progress)
    targetChampionPoints = tonumber(targetChampionPoints) or 0
    local currentChampionPoints = tonumber(GetCurrentChampionPoints()) or 0
    if currentChampionPoints >= targetChampionPoints then
        return 0
    end

    local remaining = 0
    local current = progress and tonumber(progress.current) or (GetPlayerChampionXP and tonumber(GetPlayerChampionXP()) or 0)
    local maximum = progress and tonumber(progress.maximum) or (GetNumChampionXPInChampionPoint and tonumber(GetNumChampionXPInChampionPoint(currentChampionPoints)) or 0)
    if maximum and maximum > 0 then
        remaining = remaining + math.max(maximum - (current or 0), 0)
    end

    if NQOL.Util.GetChampionXpRequirementSum then
        remaining = remaining + NQOL.Util.GetChampionXpRequirementSum(currentChampionPoints + 2, targetChampionPoints)
    end

    return remaining
end

local function GetActiveGoal(progress)
    local currentChampionPoints = tonumber(GetCurrentChampionPoints()) or 0

    if not IsChampionProgression() then
        return {
            name = NQOL.L("features.progress.goal_cp"),
            target = NQOL.L("features.progress.level_target", 50),
            remainingXp = GetNormalXpRemainingToLevel50(progress),
        }
    end

    if currentChampionPoints < 160 then
        return {
            name = NQOL.L("features.progress.goal_gearing"),
            target = NQOL.L("features.progress.cp_target", 160),
            remainingXp = GetChampionXpRemainingToTarget(160, progress),
        }
    end

    if currentChampionPoints < 3600 then
        return {
            name = NQOL.L("features.progress.goal_max"),
            target = NQOL.L("features.progress.cp_target", 3600),
            remainingXp = GetChampionXpRemainingToTarget(3600, progress),
        }
    end

    return nil
end

local function GetCurrentSceneName()
    if not SCENE_MANAGER then
        return nil
    end

    if SCENE_MANAGER.GetCurrentSceneName then
        return SCENE_MANAGER:GetCurrentSceneName()
    end

    if SCENE_MANAGER.GetCurrentScene then
        local scene = SCENE_MANAGER:GetCurrentScene()
        if scene and scene.GetName then
            return scene:GetName()
        end
    end

    return nil
end

local function IsGameplaySceneShowing()
    if not SCENE_MANAGER then
        return true
    end

    return GAMEPLAY_SCENES[GetCurrentSceneName()] == true
end

local function ShouldShow()
    local settings = GetSettings()
    if settingsPanelVisible and settings.showInSettings == true then
        return true
    end

    return settings.enabled == true and IsGameplaySceneShowing()
end

local function GetScreenDimensions()
    local width = GetScreenWidth and GetScreenWidth() or nil
    local height = GetScreenHeight and GetScreenHeight() or nil

    if (not width or width <= 0) and GuiRoot and GuiRoot.GetWidth then
        width = GuiRoot:GetWidth()
    end
    if (not height or height <= 0) and GuiRoot and GuiRoot.GetHeight then
        height = GuiRoot:GetHeight()
    end

    return width or 1920, height or 1080
end

local function ApplyPosition()
    if not control or not GuiRoot then
        return
    end

    local settings = GetSettings()
    local screenWidth, screenHeight = GetScreenDimensions()
    local x = (screenWidth - control:GetWidth()) * (settings.horizontalPosition / 100)
    local y = (screenHeight - control:GetHeight()) * (settings.verticalPosition / 100)

    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

local function CreateLabel(parent, fontOffset, color)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    label:SetFont(ResolveFont(fontOffset))
    label:SetColor(color[1], color[2], color[3], color[4])
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    if label.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end
    MoveControlAbove(label, DRAW_LEVEL + 3)
    return label
end

local function CreateSolidControl(parent, color, drawLevel)
    local solid = WINDOW_MANAGER:CreateControl(nil, parent, CT_BACKDROP)
    solid:SetCenterColor(color[1], color[2], color[3], color[4])
    solid:SetEdgeColor(0, 0, 0, 0)
    MoveControlAbove(solid, drawLevel or DRAW_LEVEL + 2)
    return solid
end

local function GetIconMarkup(texturePath, size)
    size = tonumber(size) or CP_ICON_SIZE
    if zo_iconFormat then
        return zo_iconFormat(texturePath, size, size)
    end

    return string.format("|t%d:%d:%s|t", size, size, texturePath)
end

local function ApplyBackgroundOpacity()
    if not control then
        return
    end

    local opacity = GetSettings().backgroundOpacity / 100
    if control.background then
        control.background:SetCenterColor(0, 0, 0, opacity)
        control.background:SetEdgeColor(0, 0, 0, 0)
    end
end

local function EnsureControls()
    if control or not WINDOW_MANAGER or not GuiRoot then
        return
    end

    local hudWidth = GetHudWidth()
    local cardWidth = math.floor((hudWidth - (HUD_PADDING * 2) - (CARD_GAP * (CARD_COLUMNS - 1))) / CARD_COLUMNS)

    control = WINDOW_MANAGER:CreateTopLevelWindow("NQOLProgressXP")
    control:SetDimensions(hudWidth, GetHudHeight())
    control:SetHidden(true)
    MoveControlAbove(control, DRAW_LEVEL)

    control.background = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
    control.background:SetCenterColor(0, 0, 0, GetSettings().backgroundOpacity / 100)
    control.background:SetEdgeColor(0, 0, 0, 0)
    control.background:SetAnchorFill(control)
    MoveControlAbove(control.background, DRAW_LEVEL)

    headerLabel = CreateLabel(control, 4, { 1, 0.86, 0.42, 1 })
    headerLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    headerLabel:SetDimensions(96, GetHeaderHeight())
    headerLabel:SetAnchor(TOPLEFT, control, TOPLEFT, HUD_PADDING, HUD_PADDING)

    progressLabel = CreateLabel(control, -4, { 1, 1, 1, 0.95 })
    progressLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    progressLabel:SetDimensions(hudWidth - (HUD_PADDING * 2) - 104, GetHeaderHeight())
    progressLabel:SetAnchor(TOPRIGHT, control, TOPRIGHT, -HUD_PADDING, HUD_PADDING)

    progressTrack = CreateSolidControl(control, { 1, 1, 1, 0.42 }, DRAW_LEVEL + 4)
    progressTrack:SetHeight(UNDERLINE_HEIGHT)
    progressTrack:SetAnchor(TOPLEFT, headerLabel, BOTTOMLEFT, 0, UNDERLINE_GAP)
    progressTrack:SetAnchor(TOPRIGHT, control, TOPRIGHT, -HUD_PADDING, HUD_PADDING + GetHeaderHeight() + UNDERLINE_GAP)

    progressFill = CreateSolidControl(control, { 1, 0.78, 0.22, 1 }, DRAW_LEVEL + 5)
    progressFill:SetDimensions(1, UNDERLINE_HEIGHT)
    progressFill:SetAnchor(TOPLEFT, progressTrack, TOPLEFT, 0, 0)

    local enlightenmentTop = GetEnlightenmentTop()
    enlightenmentValueLabel = CreateLabel(control, -4, { 1, 1, 1, 0.95 })
    enlightenmentValueLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    enlightenmentValueLabel:SetDimensions(hudWidth - (HUD_PADDING * 2), GetHeaderHeight())
    enlightenmentValueLabel:SetAnchor(TOPRIGHT, control, TOPRIGHT, -HUD_PADDING, enlightenmentTop)

    enlightenmentTrack = CreateSolidControl(control, { 1, 1, 1, 0.42 }, DRAW_LEVEL + 4)
    enlightenmentTrack:SetHeight(UNDERLINE_HEIGHT)
    enlightenmentTrack:SetAnchor(TOPLEFT, control, TOPLEFT, HUD_PADDING, enlightenmentTop + GetHeaderHeight() + UNDERLINE_GAP)
    enlightenmentTrack:SetAnchor(TOPRIGHT, control, TOPRIGHT, -HUD_PADDING, enlightenmentTop + GetHeaderHeight() + UNDERLINE_GAP)

    enlightenmentFill = CreateSolidControl(control, { 0.32, 0.85, 0.38, 1 }, DRAW_LEVEL + 5)
    enlightenmentFill:SetDimensions(1, UNDERLINE_HEIGHT)
    enlightenmentFill:SetAnchor(TOPLEFT, enlightenmentTrack, TOPLEFT, 0, 0)

    emptyMessageLabel = CreateLabel(control, -3, { 1, 1, 1, 0.85 })
    emptyMessageLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    emptyMessageLabel:SetDimensions(hudWidth - (HUD_PADDING * 2), GetEmptyMessageHeight())
    emptyMessageLabel:SetAnchor(TOPLEFT, control, TOPLEFT, HUD_PADDING, HUD_PADDING)
    emptyMessageLabel:SetText(NQOL.L("features.progress.enable_at_least_one_xp_tracker_section_5cbdfbd"))
    emptyMessageLabel:SetHidden(true)

    goalNameLabel = CreateLabel(control, -4, { 1, 0.86, 0.42, 0.96 })
    goalNameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    goalNameLabel:SetDimensions(math.floor((hudWidth - (HUD_PADDING * 2)) * 0.48), GetGoalHeight())
    goalNameLabel:SetAnchor(TOPLEFT, control, TOPLEFT, HUD_PADDING, GetGoalTop())

    goalEstimateLabel = CreateLabel(control, -5, { 1, 1, 1, 0.9 })
    goalEstimateLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    goalEstimateLabel:SetDimensions(math.floor((hudWidth - (HUD_PADDING * 2)) * 0.52), GetGoalHeight())
    goalEstimateLabel:SetAnchor(TOPRIGHT, control, TOPRIGHT, -HUD_PADDING, GetGoalTop())

    for index, window in ipairs(WINDOWS) do
        local card = WINDOW_MANAGER:CreateControl(nil, control, CT_CONTROL)
        local column = (index - 1) % CARD_COLUMNS
        local row = math.floor((index - 1) / CARD_COLUMNS)
        local x = HUD_PADDING + (column * (cardWidth + CARD_GAP))
        local y = GetTimersTop() + (row * (GetCardHeight() + CARD_GAP))

        card:SetDimensions(cardWidth, GetCardHeight())
        card:SetAnchor(TOPLEFT, control, TOPLEFT, x, y)
        MoveControlAbove(card, DRAW_LEVEL + 1)

        card.accent = CreateSolidControl(card, { 0.48, 0.82, 1, 1 }, DRAW_LEVEL + 4)
        card.accent:SetWidth(CARD_ACCENT_WIDTH)
        card.accent:SetAnchor(TOPLEFT, card, TOPLEFT, 0, 4)
        card.accent:SetAnchor(BOTTOMLEFT, card, BOTTOMLEFT, 0, -4)

        card.timeLabel = CreateLabel(card, -4, { 0.72, 0.86, 1, 0.95 })
        card.timeLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        card.timeLabel:SetDimensions(cardWidth - 12, GetLineHeight(-4))
        card.timeLabel:SetAnchor(TOPLEFT, card, TOPLEFT, 10, 4)

        card.gainLabel = CreateLabel(card, 2, { 1, 1, 1, 0.98 })
        card.gainLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        card.gainLabel:SetDimensions(cardWidth - 16, GetLineHeight(2))
        card.gainLabel:SetAnchor(TOPLEFT, card.timeLabel, BOTTOMLEFT, 0, 0)

        card.rateLabel = CreateLabel(card, -5, { 1, 1, 1, 0.66 })
        card.rateLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        card.rateLabel:SetDimensions(cardWidth - 16, GetLineHeight(-5))
        card.rateLabel:SetAnchor(TOPLEFT, card.gainLabel, BOTTOMLEFT, 0, 0)

        cards[index] = card
    end

    chartArea = WINDOW_MANAGER:CreateControl(nil, control, CT_CONTROL)
    chartArea:SetDimensions(hudWidth - (HUD_PADDING * 2), CHART_HEIGHT)
    chartArea:SetAnchor(TOPLEFT, control, TOPLEFT, HUD_PADDING, GetChartTop(math.ceil(#GetEnabledWindows() / CARD_COLUMNS)))
    MoveControlAbove(chartArea, DRAW_LEVEL + 1)

    chartBaseline = CreateSolidControl(chartArea, { 1, 1, 1, 0.22 }, DRAW_LEVEL + 4)
    chartBaseline:SetHeight(1)
    chartBaseline:SetAnchor(BOTTOMLEFT, chartArea, BOTTOMLEFT, 0, 0)
    chartBaseline:SetAnchor(BOTTOMRIGHT, chartArea, BOTTOMRIGHT, 0, 0)

    for index = 1, CHART_BAR_COUNT do
        local bar = CreateSolidControl(chartArea, { 1, 0.78, 0.22, 0.82 }, DRAW_LEVEL + 5)
        bar:SetHidden(true)
        chartBars[index] = bar
    end

    ApplyBackgroundOpacity()
end

local function ApplyChartLayout()
    if not chartArea then
        return
    end

    if GetSettings().showChart ~= true then
        chartArea:SetHidden(true)
        return
    end

    chartArea:SetHidden(false)

    local hudWidth = GetHudWidth()
    local chartWidth = hudWidth - (HUD_PADDING * 2)
    local enabledWindowCount = #GetEnabledWindows()
    local timerRows = math.ceil(enabledWindowCount / CARD_COLUMNS)
    local barWidth = chartWidth / CHART_BAR_COUNT

    chartArea:ClearAnchors()
    chartArea:SetDimensions(chartWidth, CHART_HEIGHT)
    chartArea:SetAnchor(TOPLEFT, control, TOPLEFT, HUD_PADDING, GetChartTop(timerRows))

    if chartBaseline then
        chartBaseline:ClearAnchors()
        chartBaseline:SetHeight(1)
        chartBaseline:SetAnchor(BOTTOMLEFT, chartArea, BOTTOMLEFT, 0, 0)
        chartBaseline:SetAnchor(BOTTOMRIGHT, chartArea, BOTTOMRIGHT, 0, 0)
    end

    for index, bar in ipairs(chartBars) do
        local x = (index - 1) * barWidth
        local nextX = index * barWidth
        local width = math.max(1, Round(nextX) - Round(x))
        bar:ClearAnchors()
        bar.nqolWidth = width
        bar:SetDimensions(width, CHART_MIN_BAR_HEIGHT)
        bar:SetAnchor(BOTTOMLEFT, chartArea, BOTTOMLEFT, Round(x), 1)
    end
end

local function ApplyLayout()
    if not control then
        return
    end

    local headerHeight = GetHeaderHeight()
    local cardHeight = GetCardHeight()
    local hudWidth = GetHudWidth()
    local cardWidth = math.floor((hudWidth - (HUD_PADDING * 2) - (CARD_GAP * (CARD_COLUMNS - 1))) / CARD_COLUMNS)
    local settings = GetSettings()

    control:SetDimensions(hudWidth, GetHudHeight())

    emptyMessageLabel:ClearAnchors()
    emptyMessageLabel:SetDimensions(hudWidth - (HUD_PADDING * 2), GetEmptyMessageHeight())
    emptyMessageLabel:SetAnchor(TOPLEFT, control, TOPLEFT, HUD_PADDING, HUD_PADDING)

    headerLabel:ClearAnchors()
    headerLabel:SetDimensions(96, headerHeight)
    headerLabel:SetAnchor(TOPLEFT, control, TOPLEFT, HUD_PADDING, HUD_PADDING)

    progressLabel:ClearAnchors()
    progressLabel:SetDimensions(hudWidth - (HUD_PADDING * 2) - 104, headerHeight)
    progressLabel:SetAnchor(TOPRIGHT, control, TOPRIGHT, -HUD_PADDING, HUD_PADDING)

    progressTrack:ClearAnchors()
    progressTrack:SetHeight(UNDERLINE_HEIGHT)
    progressTrack:SetAnchor(TOPLEFT, headerLabel, BOTTOMLEFT, 0, UNDERLINE_GAP)
    progressTrack:SetAnchor(TOPRIGHT, control, TOPRIGHT, -HUD_PADDING, HUD_PADDING + headerHeight + UNDERLINE_GAP)

    progressFill:ClearAnchors()
    progressFill:SetDimensions(1, UNDERLINE_HEIGHT)
    progressFill:SetAnchor(TOPLEFT, progressTrack, TOPLEFT, 0, 0)
    headerLabel:SetHidden(settings.showXpBar ~= true)
    progressLabel:SetHidden(settings.showXpBar ~= true)
    progressTrack:SetHidden(settings.showXpBar ~= true)
    progressFill:SetHidden(settings.showXpBar ~= true)

    local enlightenmentTop = GetEnlightenmentTop()
    enlightenmentValueLabel:ClearAnchors()
    enlightenmentValueLabel:SetDimensions(hudWidth - (HUD_PADDING * 2), headerHeight)
    enlightenmentValueLabel:SetAnchor(TOPRIGHT, control, TOPRIGHT, -HUD_PADDING, enlightenmentTop)

    enlightenmentTrack:ClearAnchors()
    enlightenmentTrack:SetHeight(UNDERLINE_HEIGHT)
    enlightenmentTrack:SetAnchor(TOPLEFT, control, TOPLEFT, HUD_PADDING, enlightenmentTop + headerHeight + UNDERLINE_GAP)
    enlightenmentTrack:SetAnchor(TOPRIGHT, control, TOPRIGHT, -HUD_PADDING, enlightenmentTop + headerHeight + UNDERLINE_GAP)

    enlightenmentFill:ClearAnchors()
    enlightenmentFill:SetDimensions(1, UNDERLINE_HEIGHT)
    enlightenmentFill:SetAnchor(TOPLEFT, enlightenmentTrack, TOPLEFT, 0, 0)

    local showEnlightenment = ShouldRenderEnlightenment()
    enlightenmentValueLabel:SetHidden(not showEnlightenment)
    enlightenmentTrack:SetHidden(not showEnlightenment)
    enlightenmentFill:SetHidden(not showEnlightenment)

    local contentWidth = hudWidth - (HUD_PADDING * 2)
    local goalTop = GetGoalTop()

    goalNameLabel:ClearAnchors()
    goalNameLabel:SetDimensions(math.floor(contentWidth * 0.48), GetGoalHeight())
    goalNameLabel:SetAnchor(TOPLEFT, control, TOPLEFT, HUD_PADDING, goalTop)

    goalEstimateLabel:ClearAnchors()
    goalEstimateLabel:SetDimensions(math.floor(contentWidth * 0.52), GetGoalHeight())
    goalEstimateLabel:SetAnchor(TOPRIGHT, control, TOPRIGHT, -HUD_PADDING, goalTop)

    goalNameLabel:SetHidden(settings.showGoal ~= true)
    goalEstimateLabel:SetHidden(settings.showGoal ~= true)

    local enabledWindows = GetEnabledWindows()
    local visibleIndexByWindowIndex = {}
    for visibleIndex, window in ipairs(enabledWindows) do
        for windowIndex, candidate in ipairs(WINDOWS) do
            if candidate.key == window.key then
                visibleIndexByWindowIndex[windowIndex] = visibleIndex
                break
            end
        end
    end

    for index, card in ipairs(cards) do
        local visibleIndex = visibleIndexByWindowIndex[index]
        if settings.showTrackers ~= true or not visibleIndex then
            card:SetHidden(true)
        else
            local column = (visibleIndex - 1) % CARD_COLUMNS
            local row = math.floor((visibleIndex - 1) / CARD_COLUMNS)
            local x = HUD_PADDING + (column * (cardWidth + CARD_GAP))
            local y = GetTimersTop() + (row * (cardHeight + CARD_GAP))

            card:SetHidden(false)
            card:ClearAnchors()
            card:SetDimensions(cardWidth, cardHeight)
            card:SetAnchor(TOPLEFT, control, TOPLEFT, x, y)

            card.accent:ClearAnchors()
            card.accent:SetWidth(CARD_ACCENT_WIDTH)
            card.accent:SetAnchor(TOPLEFT, card, TOPLEFT, 0, 4)
            card.accent:SetAnchor(BOTTOMLEFT, card, BOTTOMLEFT, 0, -4)

            card.timeLabel:ClearAnchors()
            card.timeLabel:SetDimensions(cardWidth - 12, GetLineHeight(-4))
            card.timeLabel:SetAnchor(TOPLEFT, card, TOPLEFT, 10, 4)

            card.gainLabel:ClearAnchors()
            card.gainLabel:SetDimensions(cardWidth - 16, GetLineHeight(2))
            card.gainLabel:SetAnchor(TOPLEFT, card.timeLabel, BOTTOMLEFT, 0, 0)

            card.rateLabel:ClearAnchors()
            card.rateLabel:SetDimensions(cardWidth - 16, GetLineHeight(-5))
            card.rateLabel:SetAnchor(TOPLEFT, card.gainLabel, BOTTOMLEFT, 0, 0)
        end
    end

    ApplyChartLayout()
end

local function ApplyHeaderTextLayout()
    if not headerLabel or not progressLabel then
        return
    end

    local hudWidth = GetHudWidth()
    local headerHeight = GetHeaderHeight()
    local headerWidth = math.max(HEADER_MIN_WIDTH, Round((hudWidth - (HUD_PADDING * 2)) * 0.42))
    local progressWidth = math.max(hudWidth - (HUD_PADDING * 2) - headerWidth - HEADER_PROGRESS_GAP, 48)

    headerLabel:ClearAnchors()
    headerLabel:SetDimensions(headerWidth, headerHeight)
    headerLabel:SetAnchor(TOPLEFT, control, TOPLEFT, HUD_PADDING, HUD_PADDING)

    progressLabel:ClearAnchors()
    progressLabel:SetDimensions(progressWidth, headerHeight)
    progressLabel:SetAnchor(TOPRIGHT, control, TOPRIGHT, -HUD_PADDING, HUD_PADDING)
end

local function HideControl()
    if control then
        control:SetHidden(true)
    end
end

local function FormatProgressText(progress)
    local percent = 0
    if progress.maximum > 0 then
        percent = Clamp((progress.current / progress.maximum) * 100, 0, 100)
    end

    return string.format(
        "%s / %s  %.1f%%",
        FormatNumber(progress.current),
        FormatNumber(progress.maximum),
        percent
    )
end

local function FormatGainText(value)
    value = Round(value or 0)
    if value <= 0 then
        return "+0"
    end

    return "+" .. FormatNumber(value)
end

local function FormatRateText(value)
    return NQOL.L("features.progress.xp_rate", FormatNumber(Round(value or 0)))
end

local function FormatGoalTime(minutes)
    minutes = tonumber(minutes) or 0
    if minutes <= 0 then
        return "0:00"
    end

    if minutes < 1 then
        return "<1:00"
    end

    local wholeMinutes = math.ceil(minutes)
    local hours = math.floor(wholeMinutes / 60)
    local remainderMinutes = wholeMinutes % 60

    if hours > 0 then
        return string.format("%d:%02d", hours, remainderMinutes)
    end

    return string.format("0:%02d", remainderMinutes)
end

local function FormatHeaderText(progress)
    if progress and progress.label == "CP XP" then
        return GetIconMarkup(TEXTURE_CHAMPION, CP_ICON_SIZE) .. " " .. progress.label
    end

    return progress and progress.label or NQOL.L("features.progress.xp_53af638")
end

local function GetProgressPercent(progress)
    if not progress or not progress.maximum or progress.maximum <= 0 then
        return 0
    end

    return Clamp((progress.current / progress.maximum) * 100, 0, 100)
end

local function RenderChart()
    if not chartArea then
        return
    end

    if GetSettings().showChart ~= true then
        chartArea:SetHidden(true)
        return
    end

    AdvanceChartToNow()
    EnsureChartBuckets()

    local maxGain = 0
    for index = 1, CHART_BAR_COUNT do
        maxGain = math.max(maxGain, chartBuckets[index] or 0)
    end

    for index, bar in ipairs(chartBars) do
        local gain = chartBuckets[index] or 0
        if gain <= 0 or maxGain <= 0 then
            bar:SetHidden(true)
        else
            local height = math.max(CHART_MIN_BAR_HEIGHT, Round((gain / maxGain) * (CHART_HEIGHT - 3)))
            bar:SetHidden(false)
            bar:SetDimensions(bar.nqolWidth or 1, height)
        end
    end
end

local function RenderGoal(progress)
    if not goalNameLabel or not goalEstimateLabel then
        return
    end

    if GetSettings().showGoal ~= true then
        goalNameLabel:SetHidden(true)
        goalEstimateLabel:SetHidden(true)
        return
    end

    local goal = GetActiveGoal(progress)
    if not goal then
        goalNameLabel:SetHidden(true)
        goalEstimateLabel:SetHidden(true)
        return
    end

    local estimatorWindow = GetWindowByKey(GetSettings().progressEstimator)
    local _, rate = ComputeWindow(estimatorWindow, goalStartedAt)
    local estimateText = "Estimating..."
    if rate and rate > 0 and goal.remainingXp and goal.remainingXp > 0 then
        estimateText = FormatGoalTime(goal.remainingXp / rate)
    elseif goal.remainingXp == 0 then
        estimateText = "0m"
    end

    goalNameLabel:SetHidden(false)
    goalEstimateLabel:SetHidden(false)
    goalNameLabel:SetFont(ResolveFont(-4))
    goalEstimateLabel:SetFont(ResolveFont(-5))
    goalNameLabel:SetText(goal.name)
    goalEstimateLabel:SetText(goal.target .. "  " .. estimateText)
end

local function Render()
    EnsureControls()
    if not control then
        return
    end

    if not ShouldShow() then
        HideControl()
        return
    end

    ApplyLayout()
    ApplyBackgroundOpacity()

    local sectionsEnabled = AreAnyHudSectionsEnabled()
    emptyMessageLabel:SetHidden(sectionsEnabled)
    if not sectionsEnabled then
        emptyMessageLabel:SetFont(ResolveFont(-3))
        control:SetHidden(false)
        ApplyPosition()
        return
    end

    local progress = GetProgress()
    local progressText = FormatProgressText(progress)

    if GetSettings().showXpBar == true then
        headerLabel:SetFont(ResolveFont(4))
        headerLabel:SetText(FormatHeaderText(progress))
        progressLabel:SetFont(ResolveFont(-4))
        progressLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        progressLabel:SetText(progressText)
        ApplyHeaderTextLayout()
    end

    if progressFill and GetSettings().showXpBar == true then
        local trackWidth = GetHudWidth() - (HUD_PADDING * 2)
        local progressPercent = GetProgressPercent(progress)
        local fillWidth = Round(trackWidth * (progressPercent / 100))
        progressFill:SetHidden(fillWidth <= 0)
        progressFill:SetDimensions(math.max(fillWidth, 1), UNDERLINE_HEIGHT)
    end

    if ShouldRenderEnlightenment() then
        local enlightenment = GetEnlightenmentProgress()
        local enlightenmentPercent = GetProgressPercent(enlightenment)
        local trackWidth = GetHudWidth() - (HUD_PADDING * 2)
        local fillWidth = Round(trackWidth * (enlightenmentPercent / 100))

        enlightenmentValueLabel:SetFont(ResolveFont(-4))
        enlightenmentValueLabel:SetText(FormatProgressText(enlightenment))
        enlightenmentFill:SetHidden(fillWidth <= 0)
        enlightenmentFill:SetDimensions(math.max(fillWidth, 1), UNDERLINE_HEIGHT)
    end

    RenderGoal(progress)

    if GetSettings().showTrackers == true then
        local timers = GetSettings().timers
        for index, window in ipairs(WINDOWS) do
            if timers[window.key] == true then
                local gain, rate = ComputeWindow(window, timerStartedAt[window.key])
                local card = cards[index]
                card.timeLabel:SetFont(ResolveFont(-4))
                card.gainLabel:SetFont(ResolveFont(2))
                card.rateLabel:SetFont(ResolveFont(-5))
                card.timeLabel:SetText(window.hudLabel)
                card.gainLabel:SetText(FormatGainText(gain))
                card.rateLabel:SetText(FormatRateText(rate))
            end
        end
    end

    RenderChart()

    control:SetHidden(false)
    ApplyPosition()
end

local function Refresh()
    Render()
end

local function UnregisterEvents()
    if not EVENT_MANAGER then
        return
    end

    if EVENT_EXPERIENCE_GAIN then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_ExperienceGain", EVENT_EXPERIENCE_GAIN)
    end
    if EVENT_EXPERIENCE_UPDATE then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_ExperienceUpdate", EVENT_EXPERIENCE_UPDATE)
    end
    if EVENT_CHAMPION_XP_UPDATE then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_ChampionXpUpdate", EVENT_CHAMPION_XP_UPDATE)
    end
    if EVENT_CHAMPION_POINT_GAINED then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_ChampionPointGained", EVENT_CHAMPION_POINT_GAINED)
    end
    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_Activated", EVENT_PLAYER_ACTIVATED)
    end
    if EVENT_SCREEN_RESIZED then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_ScreenResized", EVENT_SCREEN_RESIZED)
    end
    eventsRegistered = false
end

local function UpdateLoop()
    if not EVENT_MANAGER then
        return
    end

    EVENT_MANAGER:UnregisterForUpdate(EVENT_NAMESPACE)

    if GetSettings().enabled == true then
        EVENT_MANAGER:RegisterForUpdate(EVENT_NAMESPACE, UPDATE_INTERVAL_MS, Refresh)
    end
end

local function OnExperienceGain(_, _, _, previousExperience, currentExperience)
    local previousValue = tonumber(previousExperience)
    local currentValue = tonumber(currentExperience)
    local progress = GetProgress()
    if previousValue and currentValue and currentValue > previousValue then
        progress.current = currentValue
        AddSample(currentValue - previousValue, progress)
    end

    lastProgress = progress
    Refresh()
end

local function UpdateExperienceGainListener()
    if not EVENT_MANAGER or not EVENT_EXPERIENCE_GAIN then
        return
    end

    local namespace = EVENT_NAMESPACE .. "_ExperienceGain"
    EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_EXPERIENCE_GAIN)
    if eventsRegistered and ShouldCollectXpHistory() then
        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_EXPERIENCE_GAIN, OnExperienceGain)
    end
end

local function OnProgressUpdated()
    local progress = GetProgress()

    if lastProgress
        and lastProgress.label == progress.label
        and progress.current > lastProgress.current
    then
        AddSample(progress.current - lastProgress.current, progress)
    end

    lastProgress = progress
    Refresh()
end

local function RegisterEvents()
    if not EVENT_MANAGER or eventsRegistered then
        return
    end

    eventsRegistered = true
    UpdateExperienceGainListener()

    if EVENT_EXPERIENCE_UPDATE then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_ExperienceUpdate", EVENT_EXPERIENCE_UPDATE, function(_, unitTag)
            if unitTag == nil or unitTag == "player" then
                OnProgressUpdated()
            end
        end)
        if EVENT_MANAGER.AddFilterForEvent and REGISTER_FILTER_UNIT_TAG then
            EVENT_MANAGER:AddFilterForEvent(EVENT_NAMESPACE .. "_ExperienceUpdate", EVENT_EXPERIENCE_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
        end
    end

    if EVENT_CHAMPION_XP_UPDATE then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_ChampionXpUpdate", EVENT_CHAMPION_XP_UPDATE, OnProgressUpdated)
    end

    if EVENT_CHAMPION_POINT_GAINED then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_ChampionPointGained", EVENT_CHAMPION_POINT_GAINED, OnProgressUpdated)
    end

    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
            lastProgress = GetProgress()
            Refresh()
        end)
    end

    if EVENT_SCREEN_RESIZED then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_ScreenResized", EVENT_SCREEN_RESIZED, ApplyPosition)
    end
end

local function UpdateRuntimeState()
    if GetSettings().enabled == true then
        lastProgress = GetProgress()
        EnsureEnabledTimerStartTimes()
        EnsureGoalStartTime()
        RegisterEvents()
        UpdateLoop()
        Refresh()
        return
    end

    if EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForUpdate(EVENT_NAMESPACE)
    end
    UnregisterEvents()
    ResetRuntimeState()
    HideControl()
    if settingsPanelVisible and GetSettings().showInSettings == true then
        Refresh()
    end
end

local function InstallSceneCallback()
    if sceneCallbackInstalled or not SCENE_MANAGER or not SCENE_MANAGER.RegisterCallback then
        return
    end

    sceneCallbackInstalled = true
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function()
        if ShouldShow() then
            Refresh()
        else
            HideControl()
        end
    end)
end

function Progress.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function Progress.Initialize()
    if initialized then
        return
    end

    initialized = true
    InstallSceneCallback()
    UpdateRuntimeState()
end

function Progress.SetSettingsPanelVisible(value)
    settingsPanelVisible = value == true
    if GetSettings().enabled == true or (settingsPanelVisible and GetSettings().showInSettings == true) then
        Refresh()
    else
        HideControl()
    end
end

function Progress.GetXpEnabled()
    return GetSettings().enabled
end

function Progress.SetXpEnabled(value)
    GetSettings().enabled = value == true
    UpdateRuntimeState()
end

function Progress.GetXpShowInSettings()
    return GetSettings().showInSettings
end

function Progress.SetXpShowInSettings(value)
    GetSettings().showInSettings = value == true
    if GetSettings().enabled == true or (settingsPanelVisible and GetSettings().showInSettings == true) then
        Refresh()
    else
        HideControl()
    end
end

function Progress.GetXpHorizontalPosition()
    return GetSettings().horizontalPosition
end

function Progress.SetXpHorizontalPosition(value)
    GetSettings().horizontalPosition = Clamp(value, 0, 100)
    ApplyPosition()
end

function Progress.GetXpVerticalPosition()
    return GetSettings().verticalPosition
end

function Progress.SetXpVerticalPosition(value)
    GetSettings().verticalPosition = Clamp(value, 0, 100)
    ApplyPosition()
end

function Progress.GetXpFontChoices()
    return NQOL.Util.GetFontChoices()
end

function Progress.GetXpFontChoiceNames()
    return NQOL.Util.GetFontChoiceNames()
end

function Progress.GetXpFont()
    return GetSettings().font
end

function Progress.SetXpFont(value)
    if not NQOL.Util.IsFontChoice(value) then
        value = NQOL.Util.GetDefaultFont()
    end

    GetSettings().font = value
    Refresh()
end

function Progress.GetXpFontSize()
    return GetSettings().fontSize
end

function Progress.SetXpFontSize(value)
    GetSettings().fontSize = Clamp(Round(value), FONT_SIZE_MIN, FONT_SIZE_MAX)
    Refresh()
end

function Progress.GetXpFontSizeMin()
    return FONT_SIZE_MIN
end

function Progress.GetXpFontSizeMax()
    return FONT_SIZE_MAX
end

function Progress.GetXpBackgroundOpacity()
    return GetSettings().backgroundOpacity
end

function Progress.SetXpBackgroundOpacity(value)
    GetSettings().backgroundOpacity = Clamp(Round(value), BACKGROUND_OPACITY_MIN, BACKGROUND_OPACITY_MAX)
    Refresh()
end

function Progress.GetXpBackgroundOpacityMin()
    return BACKGROUND_OPACITY_MIN
end

function Progress.GetXpBackgroundOpacityMax()
    return BACKGROUND_OPACITY_MAX
end

function Progress.GetXpProgressEstimatorChoices()
    local choices = {}
    for index, window in ipairs(WINDOWS) do
        choices[index] = window.key
    end

    return choices
end

function Progress.GetXpProgressEstimatorChoiceNames()
    local choiceNames = {}
    for index, window in ipairs(WINDOWS) do
        choiceNames[index] = window.label
    end

    return choiceNames
end

function Progress.GetXpProgressEstimator()
    return GetSettings().progressEstimator
end

function Progress.SetXpProgressEstimator(value)
    if VALID_WINDOW_KEYS[value] ~= true then
        value = DEFAULT_PROGRESS_ESTIMATOR
    end

    local settings = GetSettings()
    if settings.progressEstimator == value then
        return
    end

    settings.progressEstimator = value
    if settings.showGoal == true then
        goalStartedAt = GetNow()
        PruneSamples(goalStartedAt)
    end
    Refresh()
end

function Progress.GetXpBarVisible()
    return GetSettings().showXpBar
end

function Progress.SetXpBarVisible(value)
    GetSettings().showXpBar = value == true
    Refresh()
end

function Progress.GetXpEnlightenmentVisible()
    return GetSettings().showEnlightenment
end

function Progress.SetXpEnlightenmentVisible(value)
    GetSettings().showEnlightenment = value == true
    Refresh()
end

function Progress.GetXpGoalVisible()
    return GetSettings().showGoal
end

function Progress.SetXpGoalVisible(value)
    local settings = GetSettings()
    local enabled = value == true
    if settings.showGoal == enabled then
        return
    end

    settings.showGoal = enabled
    goalStartedAt = enabled and GetNow() or nil
    if ShouldCollectWindowHistory() then
        PruneSamples(GetNow())
    else
        ClearWindowSamples()
    end

    if not ShouldCollectXpHistory() then
        lastSampledProgress = {}
        lastProgress = GetProgress()
    end

    UpdateExperienceGainListener()
    Refresh()
end

function Progress.GetXpTrackersVisible()
    return GetSettings().showTrackers
end

function Progress.SetXpTrackersVisible(value)
    GetSettings().showTrackers = value == true
    Refresh()
end

function Progress.GetXpChartVisible()
    return GetSettings().showChart
end

function Progress.SetXpChartVisible(value)
    local settings = GetSettings()
    local enabled = value == true
    if settings.showChart == enabled then
        return
    end

    settings.showChart = enabled
    ClearChartHistory()
    if enabled then
        EnsureChartBuckets()
        AdvanceChartToNow()
    elseif not ShouldCollectWindowHistory() then
        lastSampledProgress = {}
        lastProgress = GetProgress()
    end

    UpdateExperienceGainListener()
    Refresh()
end

function Progress.GetXpTimers()
    return WINDOWS
end

function Progress.GetXpTimerEnabled(timerKey)
    return GetSettings().timers[timerKey] == true
end

function Progress.SetXpTimerEnabled(timerKey, value)
    if VALID_WINDOW_KEYS[timerKey] ~= true then
        return
    end

    local timers = GetSettings().timers
    local enabled = value == true
    local wasEnabled = timers[timerKey] == true
    timers[timerKey] = enabled

    if enabled and not wasEnabled then
        timerStartedAt[timerKey] = GetNow()
    elseif not enabled then
        timerStartedAt[timerKey] = nil
    end

    if ShouldCollectWindowHistory() then
        PruneSamples(GetNow())
    else
        ClearWindowSamples()
    end

    if not ShouldCollectXpHistory() then
        lastSampledProgress = {}
        lastProgress = GetProgress()
    end

    UpdateExperienceGainListener()
    Refresh()
end

function Progress.ResetXpTimers()
    ResetRuntimeTimers()
    Refresh()
end

function Progress.GetXpResetTimersLabel()
    return NQOL.L("features.progress.xp_reset_timers_label")
end

function Progress.GetXpResetTimersTooltip()
    return NQOL.L("features.progress.xp_reset_timers_tooltip")
end

function Progress.GetXpTimersLabel()
    return NQOL.L("features.progress.xp_timers_label")
end

function Progress.GetXpTimersTooltip()
    return NQOL.L("features.progress.xp_timers_tooltip")
end

function Progress.GetXpTimerTooltip(timerLabel)
    return NQOL.L("features.progress.xp_timer_tooltip", tostring(timerLabel))
end

function Progress.GetXpEnabledLabel()
    return NQOL.L("features.progress.xp_enabled_label")
end

function Progress.GetXpEnabledTooltip()
    return NQOL.L("features.progress.xp_enabled_tooltip")
end

function Progress.GetXpShowInSettingsLabel()
    return NQOL.L("features.progress.xp_show_in_settings_label")
end

function Progress.GetXpShowInSettingsTooltip()
    return NQOL.L("features.progress.xp_show_in_settings_tooltip")
end

function Progress.GetXpHorizontalPositionLabel()
    return NQOL.L("features.progress.xp_horizontal_position_label")
end

function Progress.GetXpHorizontalPositionTooltip()
    return NQOL.L("features.progress.xp_horizontal_position_tooltip")
end

function Progress.GetXpVerticalPositionLabel()
    return NQOL.L("features.progress.xp_vertical_position_label")
end

function Progress.GetXpVerticalPositionTooltip()
    return NQOL.L("features.progress.xp_vertical_position_tooltip")
end

function Progress.GetXpFontLabel()
    return NQOL.L("features.progress.xp_font_label")
end

function Progress.GetXpFontTooltip()
    return NQOL.L("features.progress.xp_font_tooltip")
end

function Progress.GetXpFontSizeLabel()
    return NQOL.L("features.progress.xp_font_size_label")
end

function Progress.GetXpFontSizeTooltip()
    return NQOL.L("features.progress.xp_font_size_tooltip")
end

function Progress.GetXpBackgroundOpacityLabel()
    return NQOL.L("features.progress.xp_background_opacity_label")
end

function Progress.GetXpBackgroundOpacityTooltip()
    return NQOL.L("features.progress.xp_background_opacity_tooltip")
end

function Progress.GetXpProgressEstimatorLabel()
    return NQOL.L("features.progress.xp_progress_estimator_label")
end

function Progress.GetXpProgressEstimatorTooltip()
    return NQOL.L("features.progress.xp_progress_estimator_tooltip")
end

function Progress.GetXpBarVisibleLabel()
    return NQOL.L("features.progress.xp_bar_visible_label")
end

function Progress.GetXpBarVisibleTooltip()
    return NQOL.L("features.progress.xp_bar_visible_tooltip")
end

function Progress.GetXpEnlightenmentVisibleLabel()
    return NQOL.L("features.progress.xp_enlightenment_visible_label")
end

function Progress.GetXpEnlightenmentVisibleTooltip()
    return NQOL.L("features.progress.xp_enlightenment_visible_tooltip")
end

function Progress.GetXpGoalVisibleLabel()
    return NQOL.L("features.progress.xp_goal_visible_label")
end

function Progress.GetXpGoalVisibleTooltip()
    return NQOL.L("features.progress.xp_goal_visible_tooltip")
end

function Progress.GetXpTrackersVisibleLabel()
    return NQOL.L("features.progress.xp_trackers_visible_label")
end

function Progress.GetXpTrackersVisibleTooltip()
    return NQOL.L("features.progress.xp_trackers_visible_tooltip")
end

function Progress.GetXpChartVisibleLabel()
    return NQOL.L("features.progress.xp_chart_visible_label")
end

function Progress.GetXpChartVisibleTooltip()
    return NQOL.L("features.progress.xp_chart_visible_tooltip")
end

NQOL.Features.Progress = Progress
