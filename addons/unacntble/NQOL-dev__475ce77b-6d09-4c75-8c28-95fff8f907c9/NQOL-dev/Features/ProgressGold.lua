NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local ProgressGold = {}

local EVENT_NAMESPACE = "NQOL_ProgressGold"
local UPDATE_INTERVAL_MS = 1000
local CURRENCY_REFRESH_DELAY_MS = 50
local TEXTURE_GOLD = "EsoUI/Art/currency/gamepad/gp_gold.dds"
local DRAW_LEVEL = 215
local DEFAULT_FONT_SIZE = 18
local FONT_SIZE_MIN = 12
local FONT_SIZE_MAX = 30
local DEFAULT_BACKGROUND_OPACITY = 0
local BACKGROUND_OPACITY_MIN = 0
local BACKGROUND_OPACITY_MAX = 100
local HUD_WIDTH_MAX = 500
local HUD_PADDING = 14
local TIMER_GAP = 8
local CARD_GAP = 8
local CARD_COLUMNS = 3
local CARD_ACCENT_WIDTH = 4
local GOLD_ICON_SIZE = 20
local CHART_BAR_COUNT = 60
local CHART_HEIGHT = 44
local CHART_GAP = 12
local CHART_MIN_BAR_HEIGHT = 1
local DEFAULT_GOLD_SOURCE = "carried"
local MAX_WINDOW_SECONDS = 60 * 60

local GAMEPLAY_SCENES = { hud = true, hudui = true, siegeBar = true }

local WINDOWS = {
    { key = "1m", label = NQOL.L("features.progress_gold.1m_dc4ea83"), hudLabel = "[1m]", seconds = 60 },
    { key = "5m", label = NQOL.L("features.progress_gold.5m_def1139"), hudLabel = "[5m]", seconds = 5 * 60 },
    { key = "15m", label = NQOL.L("features.progress_gold.15m_edbb97d"), hudLabel = "[15m]", seconds = 15 * 60 },
    { key = "30m", label = NQOL.L("features.progress_gold.30m_c5dca4f"), hudLabel = "[30m]", seconds = 30 * 60 },
    { key = "45m", label = NQOL.L("features.progress_gold.45m_cdefcc5"), hudLabel = "[45m]", seconds = 45 * 60 },
    { key = "60m", label = NQOL.L("features.progress_gold.60m_ccd4d27"), hudLabel = "[60m]", seconds = 60 * 60 },
}
NQOL.Lexicon.RegisterTableField(WINDOWS, "label", {
    "features.progress_gold.1m_dc4ea83", "features.progress_gold.5m_def1139", "features.progress_gold.15m_edbb97d",
    "features.progress_gold.30m_c5dca4f", "features.progress_gold.45m_cdefcc5", "features.progress_gold.60m_ccd4d27",
})

local GOLD_SOURCES = {
    { key = "carried", label = NQOL.L("features.progress_gold.carried_906a94b") },
    { key = "bank", label = NQOL.L("features.progress_gold.bank_9e89988") },
    { key = "combined", label = NQOL.L("features.progress_gold.carried_bank_181014b") },
}
NQOL.Lexicon.RegisterTableField(GOLD_SOURCES, "label", {
    "features.progress_gold.carried_906a94b", "features.progress_gold.bank_9e89988",
    "features.progress_gold.carried_bank_181014b",
})

local defaults = {
    progress = {
        gold = {
            enabled = false,
            showInSettings = true,
            horizontalPosition = 78,
            verticalPosition = 48,
            font = NQOL.Util.GetDefaultFont(),
            fontSize = 24,
            backgroundOpacity = 90,
            goldSource = DEFAULT_GOLD_SOURCE,
            showGoldAmount = true,
            showTrackers = true,
            showChart = true,
            timers = {},
        },
    },
}
for _, window in ipairs(WINDOWS) do defaults.progress.gold.timers[window.key] = true end

local savedVariables
local initialized = false
local settingsPanelVisible = false
local sceneCallbackInstalled = false
local eventsRegistered = false
local updateLoopRunning = false
local currencyRefreshQueued = false
local control
local headerLabel
local amountLabel
local emptyMessageLabel
local chartArea
local chartBaseline
local chartBars = {}
local cards = {}
local sampleQueue = { values = {}, head = 1, tail = 0 }
local rateScratch = { requests = {}, results = {} }
local chartBuckets = {}
local chartCurrentMinute
local lastBalance
local fontStringCache = {}
local InstallSceneCallback
local UninstallSceneCallback

local Clamp = NQOL.Util.Clamp
local Round = NQOL.Util.Round
local FormatNumber = NQOL.Util.FormatNumber

local VALID_GOLD_SOURCES = {}
for _, source in ipairs(GOLD_SOURCES) do VALID_GOLD_SOURCES[source.key] = true end

local function GetSettings()
    local progress = NQOL.Settings.GetSection(savedVariables, defaults, "progress")
    local goldDefaults = defaults.progress.gold
    if type(progress.gold) ~= "table" then progress.gold = {} end

    local settings = progress.gold
    NQOL.Settings.Boolean(settings, goldDefaults, "enabled")
    NQOL.Settings.Boolean(settings, goldDefaults, "showInSettings")
    NQOL.Settings.ClampedNumber(settings, goldDefaults, "horizontalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, goldDefaults, "verticalPosition", 0, 100)
    if not NQOL.Util.IsFontChoice(settings.font) then settings.font = goldDefaults.font end
    NQOL.Settings.ClampedNumber(settings, goldDefaults, "fontSize", FONT_SIZE_MIN, FONT_SIZE_MAX, true)
    NQOL.Settings.ClampedNumber(settings, goldDefaults, "backgroundOpacity", BACKGROUND_OPACITY_MIN, BACKGROUND_OPACITY_MAX, true)
    if VALID_GOLD_SOURCES[settings.goldSource] ~= true then settings.goldSource = goldDefaults.goldSource end
    NQOL.Settings.Boolean(settings, goldDefaults, "showGoldAmount")
    NQOL.Settings.Boolean(settings, goldDefaults, "showTrackers")
    NQOL.Settings.Boolean(settings, goldDefaults, "showChart")
    NQOL.Settings.EnsureTable(settings, "timers")
    for _, window in ipairs(WINDOWS) do
        NQOL.Settings.DefaultFrom(settings.timers, window.key, goldDefaults.timers[window.key])
        settings.timers[window.key] = settings.timers[window.key] == true
    end
    return settings
end

local function GetNow()
    if GetFrameTimeSeconds then return GetFrameTimeSeconds() end
    if GetFrameTimeMilliseconds then return GetFrameTimeMilliseconds() / 1000 end
    return os and os.time and os.time() or 0
end

local function MoveControlAbove(targetControl, drawLevel)
    if not targetControl then return end
    if targetControl.SetDrawLayer and DL_OVERLAY then targetControl:SetDrawLayer(DL_OVERLAY) end
    if targetControl.SetDrawTier and DT_HIGH then targetControl:SetDrawTier(DT_HIGH) end
    if targetControl.SetDrawLevel then targetControl:SetDrawLevel(drawLevel or DRAW_LEVEL) end
end

local function ResolveFont(sizeOffset)
    local settings = GetSettings()
    local size = Clamp((tonumber(settings.fontSize) or DEFAULT_FONT_SIZE) + (sizeOffset or 0), FONT_SIZE_MIN, FONT_SIZE_MAX + 8)
    local key = tostring(settings.font) .. ":" .. tostring(size)
    if not fontStringCache[key] then fontStringCache[key] = NQOL.Util.CreateFontString(settings.font, size, "ZoFontGamepad18") end
    return fontStringCache[key]
end

local function GetFontSize(sizeOffset)
    return Clamp((tonumber(GetSettings().fontSize) or DEFAULT_FONT_SIZE) + (sizeOffset or 0), FONT_SIZE_MIN, FONT_SIZE_MAX + 8)
end
local function GetLineHeight(sizeOffset) return GetFontSize(sizeOffset) + 6 end
local function GetHeaderHeight() return math.max(GetLineHeight(4), GetLineHeight(-4)) end
local function GetHudWidth()
    return HUD_WIDTH_MAX
end
local function GetCardHeight() return 8 + GetLineHeight(-4) + GetLineHeight(2) + GetLineHeight(-5) + 6 end
local function GetTimersHeight(timerRows)
    if timerRows <= 0 then return 0 end
    return (GetCardHeight() * timerRows) + (CARD_GAP * math.max(timerRows - 1, 0))
end

local function GetEnabledWindows()
    local timers = GetSettings().timers
    local enabledWindows = {}
    for _, window in ipairs(WINDOWS) do
        if timers[window.key] == true then enabledWindows[#enabledWindows + 1] = window end
    end
    return enabledWindows
end

local function AreAnyHudSectionsEnabled()
    local settings = GetSettings()
    return settings.showGoldAmount == true or settings.showTrackers == true or settings.showChart == true
end
local function GetEmptyMessageHeight() return GetLineHeight(-3) end

local function GetTimersTop()
    local top = HUD_PADDING
    if GetSettings().showGoldAmount == true then top = top + GetHeaderHeight() end
    if top > HUD_PADDING then top = top + TIMER_GAP end
    return top
end

local function GetChartTop(timerRows)
    local top = HUD_PADDING
    if GetSettings().showGoldAmount == true then top = top + GetHeaderHeight() end
    if GetSettings().showTrackers == true and timerRows > 0 then
        if top > HUD_PADDING then top = top + TIMER_GAP end
        top = top + GetTimersHeight(timerRows)
    end
    if top > HUD_PADDING then top = top + CHART_GAP end
    return top
end

local function GetHudHeight()
    local settings = GetSettings()
    if not AreAnyHudSectionsEnabled() then return HUD_PADDING + GetEmptyMessageHeight() + HUD_PADDING end
    local height = HUD_PADDING
    if settings.showGoldAmount == true then height = height + GetHeaderHeight() end
    if settings.showTrackers == true then
        local timerRows = math.ceil(#GetEnabledWindows() / CARD_COLUMNS)
        if timerRows > 0 then
            if height > HUD_PADDING then height = height + TIMER_GAP end
            height = height + GetTimersHeight(timerRows)
        end
    end
    if settings.showChart == true then
        if height > HUD_PADDING then height = height + CHART_GAP end
        height = height + CHART_HEIGHT
    end
    return height + HUD_PADDING
end

local function GetCurrencyLocationAmount(location)
    if not GetCurrencyAmount or not CURT_MONEY or not location then return 0 end
    return tonumber(GetCurrencyAmount(CURT_MONEY, location)) or 0
end

local function GetCurrentGoldAmount()
    local source = GetSettings().goldSource
    if source == "bank" then return GetCurrencyLocationAmount(CURRENCY_LOCATION_BANK) end
    if source == "combined" then return GetCurrencyLocationAmount(CURRENCY_LOCATION_CHARACTER) + GetCurrencyLocationAmount(CURRENCY_LOCATION_BANK) end
    return GetCurrencyLocationAmount(CURRENCY_LOCATION_CHARACTER)
end

local function PruneSamples(now)
    now = now or GetNow()
    local cutoff = now - MAX_WINDOW_SECONDS
    local values = sampleQueue.values
    while sampleQueue.head <= sampleQueue.tail do
        local sample = values[sampleQueue.head]
        if sample and sample.time >= cutoff then break end
        values[sampleQueue.head] = nil
        sampleQueue.head = sampleQueue.head + 1
    end
    if sampleQueue.head > sampleQueue.tail then
        sampleQueue.head = 1
        sampleQueue.tail = 0
        return
    end

    local discardedCount = sampleQueue.head - 1
    local retainedCount = sampleQueue.tail - sampleQueue.head + 1
    if discardedCount >= 256 and discardedCount >= retainedCount then
        local oldHead = sampleQueue.head
        local oldTail = sampleQueue.tail
        for index = 1, retainedCount do values[index] = values[oldHead + index - 1] end
        for index = retainedCount + 1, oldTail do values[index] = nil end
        sampleQueue.head = 1
        sampleQueue.tail = retainedCount
    end
end

local function EnsureChartBuckets()
    for index = 1, CHART_BAR_COUNT do if type(chartBuckets[index]) ~= "number" then chartBuckets[index] = 0 end end
    for index = #chartBuckets, CHART_BAR_COUNT + 1, -1 do chartBuckets[index] = nil end
end

local function ShiftChartBuckets(count)
    count = math.min(math.max(tonumber(count) or 0, 0), CHART_BAR_COUNT)
    if count <= 0 then return end
    EnsureChartBuckets()
    for _ = 1, count do
        for index = 1, CHART_BAR_COUNT - 1 do chartBuckets[index] = chartBuckets[index + 1] or 0 end
        chartBuckets[CHART_BAR_COUNT] = 0
    end
end

local function AdvanceChartToMinute(minute)
    minute = tonumber(minute)
    if not minute then return end
    EnsureChartBuckets()
    if not chartCurrentMinute then chartCurrentMinute = minute return end
    if minute > chartCurrentMinute then ShiftChartBuckets(minute - chartCurrentMinute) chartCurrentMinute = minute elseif minute < chartCurrentMinute then chartCurrentMinute = minute end
end
local function AdvanceChartToNow() AdvanceChartToMinute(math.floor(GetNow() / 60)) end

local function AddSample(amount)
    amount = tonumber(amount) or 0
    if amount <= 0 then return end
    local now = GetNow()
    sampleQueue.tail = sampleQueue.tail + 1
    sampleQueue.values[sampleQueue.tail] = { time = now, amount = amount }
    PruneSamples(now)
    AdvanceChartToMinute(math.floor(now / 60))
    chartBuckets[CHART_BAR_COUNT] = (chartBuckets[CHART_BAR_COUNT] or 0) + amount
end

local function ResetRuntimeTimers(resetBalance)
    for index = sampleQueue.head, sampleQueue.tail do sampleQueue.values[index] = nil end
    sampleQueue.head = 1
    sampleQueue.tail = 0
    for index = #chartBuckets, 1, -1 do chartBuckets[index] = nil end
    chartCurrentMinute = nil
    if resetBalance ~= false then lastBalance = GetCurrentGoldAmount() end
    EnsureChartBuckets()
    AdvanceChartToNow()
end

local function ResetRuntimeState()
    ResetRuntimeTimers(false)
    lastBalance = nil
end

local function DetectGoldGain()
    local currentBalance = GetCurrentGoldAmount()
    if lastBalance and currentBalance > lastBalance then AddSample(currentBalance - lastBalance) end
    lastBalance = currentBalance
    return currentBalance
end

local function ComputeRateWindows(settings)
    local now = GetNow()
    PruneSamples(now)

    local requests = rateScratch.requests
    local results = rateScratch.results
    local requestCount = 0
    for _, window in ipairs(WINDOWS) do
        local result = results[window.key]
        if not result then
            result = {}
            results[window.key] = result
        end
        result.gain = 0
        result.rate = 0

        if settings.showTrackers == true and settings.timers[window.key] == true then
            requestCount = requestCount + 1
            local request = requests[requestCount] or {}
            request.id = window.key
            request.windowSeconds = window.seconds
            request.cutoff = now - window.seconds
            requests[requestCount] = request
        end
    end

    for index = 2, requestCount do
        local request = requests[index]
        local insertionIndex = index - 1
        while insertionIndex >= 1 and requests[insertionIndex].cutoff < request.cutoff do
            requests[insertionIndex + 1] = requests[insertionIndex]
            insertionIndex = insertionIndex - 1
        end
        requests[insertionIndex + 1] = request
    end

    local values = sampleQueue.values
    local sampleIndex = sampleQueue.tail
    local gain = 0
    local oldest
    for requestIndex = 1, requestCount do
        local request = requests[requestIndex]
        while sampleIndex >= sampleQueue.head do
            local sample = values[sampleIndex]
            if not sample or sample.time < request.cutoff then break end
            gain = gain + sample.amount
            oldest = sample.time
            sampleIndex = sampleIndex - 1
        end

        local elapsedSeconds = request.windowSeconds
        if oldest then elapsedSeconds = math.min(request.windowSeconds, math.max(now - oldest, 1)) end
        local result = results[request.id]
        result.gain = gain
        result.rate = gain > 0 and gain / (elapsedSeconds / 60) or 0
    end

    return results
end

local function GetCurrentSceneName()
    if not SCENE_MANAGER then return nil end
    if SCENE_MANAGER.GetCurrentSceneName then return SCENE_MANAGER:GetCurrentSceneName() end
    if SCENE_MANAGER.GetCurrentScene then
        local scene = SCENE_MANAGER:GetCurrentScene()
        if scene and scene.GetName then return scene:GetName() end
    end
    return nil
end
local function IsGameplaySceneShowing() if not SCENE_MANAGER then return true end return GAMEPLAY_SCENES[GetCurrentSceneName()] == true end
local function ShouldShow()
    local settings = GetSettings()
    if settingsPanelVisible and settings.showInSettings == true then return true end
    return settings.enabled == true and IsGameplaySceneShowing()
end

local function GetScreenDimensions()
    local width = GetScreenWidth and GetScreenWidth() or nil
    local height = GetScreenHeight and GetScreenHeight() or nil
    if (not width or width <= 0) and GuiRoot and GuiRoot.GetWidth then width = GuiRoot:GetWidth() end
    if (not height or height <= 0) and GuiRoot and GuiRoot.GetHeight then height = GuiRoot:GetHeight() end
    return width or 1920, height or 1080
end

local function ApplyPosition()
    if not control or not GuiRoot then return end
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
    if label.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
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
    size = tonumber(size) or GOLD_ICON_SIZE
    if zo_iconFormat then return zo_iconFormat(texturePath, size, size) end
    return string.format("|t%d:%d:%s|t", size, size, texturePath)
end
local function ApplyBackgroundOpacity()
    if control and control.background then
        control.background:SetCenterColor(0, 0, 0, GetSettings().backgroundOpacity / 100)
        control.background:SetEdgeColor(0, 0, 0, 0)
    end
end

local function EnsureControls()
    if control or not WINDOW_MANAGER or not GuiRoot then return end
    local hudWidth = GetHudWidth()
    local cardWidth = math.floor((hudWidth - (HUD_PADDING * 2) - (CARD_GAP * (CARD_COLUMNS - 1))) / CARD_COLUMNS)
    control = WINDOW_MANAGER:CreateTopLevelWindow("NQOLProgressGold")
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
    amountLabel = CreateLabel(control, -4, { 1, 1, 1, 0.95 })
    amountLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    emptyMessageLabel = CreateLabel(control, -3, { 1, 1, 1, 0.85 })
    emptyMessageLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    emptyMessageLabel:SetText(NQOL.L("features.progress_gold.enable_at_least_one_gold_tracker_section_8a5c9dc"))
    emptyMessageLabel:SetHidden(true)

    for index, window in ipairs(WINDOWS) do
        local card = WINDOW_MANAGER:CreateControl(nil, control, CT_CONTROL)
        card.accent = CreateSolidControl(card, { 1, 0.78, 0.22, 1 }, DRAW_LEVEL + 4)
        card.timeLabel = CreateLabel(card, -4, { 0.72, 0.86, 1, 0.95 })
        card.timeLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        card.gainLabel = CreateLabel(card, 2, { 1, 1, 1, 0.98 })
        card.gainLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        card.rateLabel = CreateLabel(card, -5, { 1, 1, 1, 0.66 })
        card.rateLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        cards[index] = card
    end

    chartArea = WINDOW_MANAGER:CreateControl(nil, control, CT_CONTROL)
    MoveControlAbove(chartArea, DRAW_LEVEL + 1)
    chartBaseline = CreateSolidControl(chartArea, { 1, 1, 1, 0.22 }, DRAW_LEVEL + 4)
    for index = 1, CHART_BAR_COUNT do
        local bar = CreateSolidControl(chartArea, { 1, 0.78, 0.22, 0.82 }, DRAW_LEVEL + 5)
        bar:SetHidden(true)
        chartBars[index] = bar
    end
end

local function ApplyChartLayout()
    if not chartArea then return end
    if GetSettings().showChart ~= true then chartArea:SetHidden(true) return end
    chartArea:SetHidden(false)
    local hudWidth = GetHudWidth()
    local chartWidth = hudWidth - (HUD_PADDING * 2)
    local timerRows = math.ceil(#GetEnabledWindows() / CARD_COLUMNS)
    local barWidth = chartWidth / CHART_BAR_COUNT
    chartArea:ClearAnchors()
    chartArea:SetDimensions(chartWidth, CHART_HEIGHT)
    chartArea:SetAnchor(TOPLEFT, control, TOPLEFT, HUD_PADDING, GetChartTop(timerRows))
    chartBaseline:ClearAnchors()
    chartBaseline:SetHeight(1)
    chartBaseline:SetAnchor(BOTTOMLEFT, chartArea, BOTTOMLEFT, 0, 0)
    chartBaseline:SetAnchor(BOTTOMRIGHT, chartArea, BOTTOMRIGHT, 0, 0)
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
    if not control then return end
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
    headerLabel:SetDimensions(math.floor((hudWidth - (HUD_PADDING * 2)) * 0.45), headerHeight)
    headerLabel:SetAnchor(TOPLEFT, control, TOPLEFT, HUD_PADDING, HUD_PADDING)
    amountLabel:ClearAnchors()
    amountLabel:SetDimensions(math.floor((hudWidth - (HUD_PADDING * 2)) * 0.55), headerHeight)
    amountLabel:SetAnchor(TOPRIGHT, control, TOPRIGHT, -HUD_PADDING, HUD_PADDING)
    headerLabel:SetHidden(settings.showGoldAmount ~= true)
    amountLabel:SetHidden(settings.showGoldAmount ~= true)

    local enabledWindows = GetEnabledWindows()
    local visibleIndexByWindowIndex = {}
    for visibleIndex, window in ipairs(enabledWindows) do
        for windowIndex, candidate in ipairs(WINDOWS) do
            if candidate.key == window.key then visibleIndexByWindowIndex[windowIndex] = visibleIndex break end
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

local function HideControl() if control then control:SetHidden(true) end end
local function FormatGainText(value) value = Round(value or 0) return value <= 0 and "+0" or "+" .. FormatNumber(value) end
local function FormatRateText(value) return NQOL.L("features.progress_gold.gold_rate", FormatNumber(Round(value or 0))) end
local function FormatHeaderText()
    local currencyName = GetCurrencyName and GetCurrencyName(CURT_MONEY, false, false) or NQOL.L("common.gold")
    return GetIconMarkup(TEXTURE_GOLD, GOLD_ICON_SIZE) .. " " .. currencyName
end

local function RenderChart()
    if not chartArea then return end
    if GetSettings().showChart ~= true then chartArea:SetHidden(true) return end
    AdvanceChartToNow()
    EnsureChartBuckets()
    local maxGain = 0
    for index = 1, CHART_BAR_COUNT do maxGain = math.max(maxGain, chartBuckets[index] or 0) end
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

local function Render()
    if not ShouldShow() then HideControl() return end
    EnsureControls()
    if not control then return end
    local currentGold = GetSettings().enabled == true and DetectGoldGain() or GetCurrentGoldAmount()
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
    if GetSettings().showGoldAmount == true then
        headerLabel:SetFont(ResolveFont(4))
        headerLabel:SetText(FormatHeaderText())
        amountLabel:SetFont(ResolveFont(-4))
        amountLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        amountLabel:SetText(FormatNumber(currentGold))
    end
    if GetSettings().showTrackers == true then
        local settings = GetSettings()
        local rateResults = ComputeRateWindows(settings)
        for index, window in ipairs(WINDOWS) do
            if settings.timers[window.key] == true then
                local result = rateResults[window.key]
                local card = cards[index]
                card.timeLabel:SetFont(ResolveFont(-4))
                card.gainLabel:SetFont(ResolveFont(2))
                card.rateLabel:SetFont(ResolveFont(-5))
                card.timeLabel:SetText(window.hudLabel)
                card.gainLabel:SetText(FormatGainText(result and result.gain or 0))
                card.rateLabel:SetText(FormatRateText(result and result.rate or 0))
            end
        end
    end
    RenderChart()
    control:SetHidden(false)
    ApplyPosition()
end

local function Refresh() Render() end
local function UpdateLoop()
    if not EVENT_MANAGER then return end
    local settings = GetSettings()
    local shouldRun = (settings.enabled == true and IsGameplaySceneShowing())
        or (settingsPanelVisible and settings.showInSettings == true)
    if shouldRun == updateLoopRunning then return shouldRun end

    EVENT_MANAGER:UnregisterForUpdate(EVENT_NAMESPACE)
    updateLoopRunning = false
    if shouldRun then
        EVENT_MANAGER:RegisterForUpdate(EVENT_NAMESPACE, UPDATE_INTERVAL_MS, Refresh)
        updateLoopRunning = true
    end
    return shouldRun
end

local function FlushCurrencyRefresh()
    currencyRefreshQueued = false
    if ShouldShow() then Refresh() end
end

local function OnCurrencyChanged()
    if currencyRefreshQueued or not ShouldShow() then return end
    currencyRefreshQueued = true
    if zo_callLater then
        zo_callLater(FlushCurrencyRefresh, CURRENCY_REFRESH_DELAY_MS)
    else
        FlushCurrencyRefresh()
    end
end

local function RegisterCurrencyEvent(eventName, suffix)
    if eventName then EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. suffix, eventName, OnCurrencyChanged) end
end

local function UnregisterCurrencyEvent(eventName, suffix)
    if eventName then EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. suffix, eventName) end
end

local function RegisterEvents()
    if not EVENT_MANAGER or eventsRegistered then return end
    eventsRegistered = true
    RegisterCurrencyEvent(EVENT_CURRENCY_UPDATE, "_Currency")
    RegisterCurrencyEvent(EVENT_MONEY_UPDATE, "_Money")
    RegisterCurrencyEvent(EVENT_CARRIED_CURRENCY_UPDATE, "_CarriedCurrency")
    RegisterCurrencyEvent(EVENT_BANKED_CURRENCY_UPDATE, "_BankedCurrency")
    if EVENT_PLAYER_ACTIVATED then EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Activated", EVENT_PLAYER_ACTIVATED, function() lastBalance = GetCurrentGoldAmount() if ShouldShow() then Refresh() end end) end
    if EVENT_SCREEN_RESIZED then EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_ScreenResized", EVENT_SCREEN_RESIZED, ApplyPosition) end
end

local function UnregisterEvents()
    if not EVENT_MANAGER then return end
    UnregisterCurrencyEvent(EVENT_CURRENCY_UPDATE, "_Currency")
    UnregisterCurrencyEvent(EVENT_MONEY_UPDATE, "_Money")
    UnregisterCurrencyEvent(EVENT_CARRIED_CURRENCY_UPDATE, "_CarriedCurrency")
    UnregisterCurrencyEvent(EVENT_BANKED_CURRENCY_UPDATE, "_BankedCurrency")
    if EVENT_PLAYER_ACTIVATED then EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_Activated", EVENT_PLAYER_ACTIVATED) end
    if EVENT_SCREEN_RESIZED then EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_ScreenResized", EVENT_SCREEN_RESIZED) end
    eventsRegistered = false
end

local function UpdateRuntimeState()
    if GetSettings().enabled == true then
        InstallSceneCallback()
        lastBalance = GetCurrentGoldAmount()
        RegisterEvents()
        UpdateLoop()
        Refresh()
        return
    end

    UnregisterEvents()
    ResetRuntimeState()
    UpdateLoop()
    if settingsPanelVisible and GetSettings().showInSettings == true then
        InstallSceneCallback()
        Refresh()
    else
        UninstallSceneCallback()
        HideControl()
    end
end

local function OnSceneStateChanged()
    UpdateLoop()
    if ShouldShow() then Refresh() else HideControl() end
end

InstallSceneCallback = function()
    if sceneCallbackInstalled or not SCENE_MANAGER or not SCENE_MANAGER.RegisterCallback then return end
    sceneCallbackInstalled = true
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", OnSceneStateChanged)
end

UninstallSceneCallback = function()
    if not sceneCallbackInstalled or not SCENE_MANAGER or not SCENE_MANAGER.UnregisterCallback then return end
    SCENE_MANAGER:UnregisterCallback("SceneStateChanged", OnSceneStateChanged)
    sceneCallbackInstalled = false
end

function ProgressGold.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end
function ProgressGold.Initialize()
    if initialized then return end
    initialized = true
    UpdateRuntimeState()
end
function ProgressGold.SetSettingsPanelVisible(value)
    local visible = value == true
    settingsPanelVisible = visible
    UpdateRuntimeState()
end

function ProgressGold.GetGoldEnabled() return GetSettings().enabled end
function ProgressGold.SetGoldEnabled(value)
    GetSettings().enabled = value == true
    UpdateRuntimeState()
end
function ProgressGold.GetGoldShowInSettings() return GetSettings().showInSettings end
function ProgressGold.SetGoldShowInSettings(value)
    GetSettings().showInSettings = value == true
    UpdateRuntimeState()
end
function ProgressGold.GetGoldHorizontalPosition() return GetSettings().horizontalPosition end
function ProgressGold.SetGoldHorizontalPosition(value) GetSettings().horizontalPosition = Clamp(value, 0, 100) ApplyPosition() end
function ProgressGold.GetGoldVerticalPosition() return GetSettings().verticalPosition end
function ProgressGold.SetGoldVerticalPosition(value) GetSettings().verticalPosition = Clamp(value, 0, 100) ApplyPosition() end
function ProgressGold.GetGoldFontChoices() return NQOL.Util.GetFontChoices() end
function ProgressGold.GetGoldFontChoiceNames() return NQOL.Util.GetFontChoiceNames() end
function ProgressGold.GetGoldFont() return GetSettings().font end
function ProgressGold.SetGoldFont(value) if not NQOL.Util.IsFontChoice(value) then value = NQOL.Util.GetDefaultFont() end GetSettings().font = value Refresh() end
function ProgressGold.GetGoldFontSize() return GetSettings().fontSize end
function ProgressGold.SetGoldFontSize(value) GetSettings().fontSize = Clamp(Round(value), FONT_SIZE_MIN, FONT_SIZE_MAX) Refresh() end
function ProgressGold.GetGoldFontSizeMin() return FONT_SIZE_MIN end
function ProgressGold.GetGoldFontSizeMax() return FONT_SIZE_MAX end
function ProgressGold.GetGoldBackgroundOpacity() return GetSettings().backgroundOpacity end
function ProgressGold.SetGoldBackgroundOpacity(value) GetSettings().backgroundOpacity = Clamp(Round(value), BACKGROUND_OPACITY_MIN, BACKGROUND_OPACITY_MAX) Refresh() end
function ProgressGold.GetGoldBackgroundOpacityMin() return BACKGROUND_OPACITY_MIN end
function ProgressGold.GetGoldBackgroundOpacityMax() return BACKGROUND_OPACITY_MAX end
function ProgressGold.GetGoldSourceChoices() local choices = {} for index, source in ipairs(GOLD_SOURCES) do choices[index] = source.key end return choices end
function ProgressGold.GetGoldSourceChoiceNames() local names = {} for index, source in ipairs(GOLD_SOURCES) do names[index] = source.label end return names end
function ProgressGold.GetGoldSource() return GetSettings().goldSource end
function ProgressGold.SetGoldSource(value) if VALID_GOLD_SOURCES[value] ~= true then value = DEFAULT_GOLD_SOURCE end GetSettings().goldSource = value lastBalance = GetCurrentGoldAmount() Refresh() end
function ProgressGold.GetGoldAmountVisible() return GetSettings().showGoldAmount end
function ProgressGold.SetGoldAmountVisible(value) GetSettings().showGoldAmount = value == true Refresh() end
function ProgressGold.GetGoldTrackersVisible() return GetSettings().showTrackers end
function ProgressGold.SetGoldTrackersVisible(value) GetSettings().showTrackers = value == true Refresh() end
function ProgressGold.GetGoldChartVisible() return GetSettings().showChart end
function ProgressGold.SetGoldChartVisible(value) GetSettings().showChart = value == true Refresh() end
function ProgressGold.GetGoldTimers() return WINDOWS end
function ProgressGold.GetGoldTimerEnabled(timerKey) return GetSettings().timers[timerKey] == true end
function ProgressGold.SetGoldTimerEnabled(timerKey, value) GetSettings().timers[timerKey] = value == true Refresh() end

function ProgressGold.ResetGoldTimers() ResetRuntimeTimers() Refresh() end
function ProgressGold.GetGoldResetTimersLabel() return NQOL.L("features.progress_gold.gold_reset_timers_label") end
function ProgressGold.GetGoldResetTimersTooltip() return NQOL.L("features.progress_gold.gold_reset_timers_tooltip") end

function ProgressGold.GetGoldTimersLabel() return NQOL.L("features.progress_gold.gold_timers_label") end
function ProgressGold.GetGoldTimersTooltip() return NQOL.L("features.progress_gold.gold_timers_tooltip") end
function ProgressGold.GetGoldTimerTooltip(timerLabel) return NQOL.L("features.progress_gold.timer_tooltip", tostring(timerLabel)) end
function ProgressGold.GetGoldEnabledLabel() return NQOL.L("features.progress_gold.gold_enabled_label") end
function ProgressGold.GetGoldEnabledTooltip() return NQOL.L("features.progress_gold.gold_enabled_tooltip") end
function ProgressGold.GetGoldShowInSettingsLabel() return NQOL.L("features.progress_gold.gold_show_in_settings_label") end
function ProgressGold.GetGoldShowInSettingsTooltip() return NQOL.L("features.progress_gold.gold_show_in_settings_tooltip") end
function ProgressGold.GetGoldHorizontalPositionLabel() return NQOL.L("features.progress_gold.gold_horizontal_position_label") end
function ProgressGold.GetGoldHorizontalPositionTooltip() return NQOL.L("features.progress_gold.gold_horizontal_position_tooltip") end
function ProgressGold.GetGoldVerticalPositionLabel() return NQOL.L("features.progress_gold.gold_vertical_position_label") end
function ProgressGold.GetGoldVerticalPositionTooltip() return NQOL.L("features.progress_gold.gold_vertical_position_tooltip") end
function ProgressGold.GetGoldFontLabel() return NQOL.L("features.progress_gold.gold_font_label") end
function ProgressGold.GetGoldFontTooltip() return NQOL.L("features.progress_gold.gold_font_tooltip") end
function ProgressGold.GetGoldFontSizeLabel() return NQOL.L("features.progress_gold.gold_font_size_label") end
function ProgressGold.GetGoldFontSizeTooltip() return NQOL.L("features.progress_gold.gold_font_size_tooltip") end
function ProgressGold.GetGoldBackgroundOpacityLabel() return NQOL.L("features.progress_gold.gold_background_opacity_label") end
function ProgressGold.GetGoldBackgroundOpacityTooltip() return NQOL.L("features.progress_gold.gold_background_opacity_tooltip") end
function ProgressGold.GetGoldSourceLabel() return NQOL.L("features.progress_gold.gold_source_label") end
function ProgressGold.GetGoldSourceTooltip() return NQOL.L("features.progress_gold.gold_source_tooltip") end
function ProgressGold.GetGoldAmountVisibleLabel() return NQOL.L("features.progress_gold.gold_amount_visible_label") end
function ProgressGold.GetGoldAmountVisibleTooltip() return NQOL.L("features.progress_gold.gold_amount_visible_tooltip") end
function ProgressGold.GetGoldTrackersVisibleLabel() return NQOL.L("features.progress_gold.gold_trackers_visible_label") end
function ProgressGold.GetGoldTrackersVisibleTooltip() return NQOL.L("features.progress_gold.gold_trackers_visible_tooltip") end
function ProgressGold.GetGoldChartVisibleLabel() return NQOL.L("features.progress_gold.gold_chart_visible_label") end
function ProgressGold.GetGoldChartVisibleTooltip() return NQOL.L("features.progress_gold.gold_chart_visible_tooltip") end

NQOL.Features.ProgressGold = ProgressGold
