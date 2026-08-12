NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local TrialTimer = {}

local EVENT_NAMESPACE = "NQOL_TrialTimer"
local UPDATE_INTERVAL_MS = 250
local SYNC_DELAY_MS = 500
local RESULT_HOLD_MS = 10000
local DRAW_LEVEL = 220
local FONT_SIZE_MIN = 16
local FONT_SIZE_MAX = 72
local BACKGROUND_OPACITY_MIN = 0
local BACKGROUND_OPACITY_MAX = 100
local TIMER_TEXTURE = "EsoUI/Art/Miscellaneous/Gamepad/gp_icon_timer32.dds"
local VITALITY_TEXTURE = "EsoUI/Art/Trials/VitalityDepletion.dds"
local SCORE_TEXTURE = "EsoUI/Art/Trials/trialPoints_normal.dds"
local GAMEPLAY_SCENES = {
    hud = true,
    hudui = true,
    siegeBar = true,
}

local defaults = {
    trialTimer = {
        enabled = false,
        showInSettings = true,
        showElapsedTime = true,
        showVitality = true,
        showLiveScore = true,
        showBestScore = true,
        horizontalPosition = 50,
        verticalPosition = 12,
        font = NQOL.Util.GetDefaultFont(),
        fontSize = 34,
        color = { r = 1, g = 1, b = 1, a = 1 },
        backgroundColor = { r = 0, g = 0, b = 0, a = 1 },
        backgroundOpacity = 60,
    },
}

local savedVariables
local initialized = false
local settingsPanelVisible = false
local eventsRegistered = false
local sceneCallbackInstalled = false
local updateRegistered = false
local stoppedForGroupLeave = false
local fontStringCache = {}
local control
local lastDisplayText
local run = {
    running = false,
    finished = false,
    durationMs = 0,
    score = 0,
    bestScore = nil,
    remainingRevives = nil,
    startingRevives = nil,
    raidId = nil,
    leaderboardRequested = false,
    hideAtMs = 0,
}

local Clamp = NQOL.Util.Clamp
local Round = NQOL.Util.Round

local function CopyColor(color, fallback)
    fallback = fallback or { r = 1, g = 1, b = 1, a = 1 }
    return {
        r = Clamp(tonumber(color and color.r) or fallback.r, 0, 1),
        g = Clamp(tonumber(color and color.g) or fallback.g, 0, 1),
        b = Clamp(tonumber(color and color.b) or fallback.b, 0, 1),
        a = Clamp(tonumber(color and color.a) or fallback.a, 0, 1),
    }
end

local function GetNowMs()
    if GetFrameTimeMilliseconds then
        return GetFrameTimeMilliseconds()
    end
    if GetGameTimeMilliseconds then
        return GetGameTimeMilliseconds()
    end
    return os and os.time and (os.time() * 1000) or 0
end

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "trialTimer")
    local trialDefaults = defaults.trialTimer

    NQOL.Settings.Boolean(settings, trialDefaults, "enabled")
    NQOL.Settings.Boolean(settings, trialDefaults, "showInSettings")
    NQOL.Settings.Boolean(settings, trialDefaults, "showElapsedTime")
    NQOL.Settings.Boolean(settings, trialDefaults, "showVitality")
    NQOL.Settings.Boolean(settings, trialDefaults, "showLiveScore")
    NQOL.Settings.Boolean(settings, trialDefaults, "showBestScore")
    NQOL.Settings.ClampedNumber(settings, trialDefaults, "horizontalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, trialDefaults, "verticalPosition", 0, 100)
    if not NQOL.Util.IsFontChoice(settings.font) then
        settings.font = trialDefaults.font
    end
    NQOL.Settings.ClampedNumber(settings, trialDefaults, "fontSize", FONT_SIZE_MIN, FONT_SIZE_MAX, true)
    settings.color = CopyColor(settings.color, trialDefaults.color)
    settings.backgroundColor = CopyColor(settings.backgroundColor, trialDefaults.backgroundColor)
    NQOL.Settings.ClampedNumber(settings, trialDefaults, "backgroundOpacity", BACKGROUND_OPACITY_MIN, BACKGROUND_OPACITY_MAX, true)

    return settings
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
    return not SCENE_MANAGER or GAMEPLAY_SCENES[GetCurrentSceneName()] == true
end

local function GetPlayerZoneId()
    if not GetUnitZoneIndex or not GetZoneId then
        return 0
    end
    local zoneIndex = GetUnitZoneIndex("player")
    return tonumber(zoneIndex and GetZoneId(zoneIndex)) or 0
end

local function IsTrialZone()
    local data = NQOL.Data and NQOL.Data.DungeonAchievements
    local trials = data and data.trials
    return type(trials) == "table" and trials[GetPlayerZoneId()] ~= nil
end

local function IsActiveTrial()
    return IsTrialZone()
        and IsRaidInProgress
        and IsRaidInProgress() == true
end

local function ResolveFont()
    local settings = GetSettings()
    local cacheKey = settings.font .. "|" .. tostring(settings.fontSize)
    if not fontStringCache[cacheKey] then
        fontStringCache[cacheKey] = NQOL.Util.CreateFontString(settings.font, settings.fontSize, "ZoFontGamepad34")
    end
    return fontStringCache[cacheKey]
end

local function MoveControlAbove(target)
    if not target then
        return
    end
    if target.SetDrawLayer and DL_OVERLAY then
        target:SetDrawLayer(DL_OVERLAY)
    end
    if target.SetDrawTier and DT_HIGH then
        target:SetDrawTier(DT_HIGH)
    end
    if target.SetDrawLevel then
        target:SetDrawLevel(DRAW_LEVEL)
    end
end

local function EnsureControl()
    if control or not WINDOW_MANAGER or not GuiRoot then
        return control
    end

    local root = WINDOW_MANAGER:CreateTopLevelWindow("NQOLTrialTimer")
    root:SetHidden(true)
    root:SetClampedToScreen(true)
    root:SetMouseEnabled(false)
    root:SetDimensions(560, 54)
    MoveControlAbove(root)

    local background = WINDOW_MANAGER:CreateControl(nil, root, CT_BACKDROP)
    background:SetAnchorFill(root)
    background:SetCenterColor(0, 0, 0, 0)
    background:SetEdgeColor(0, 0, 0, 0)

    local label = WINDOW_MANAGER:CreateControl(nil, root, CT_LABEL)
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(1, 1, 1, 1)

    control = {
        root = root,
        background = background,
        label = label,
    }
    return control
end

local function ApplyPosition()
    local current = EnsureControl()
    if not current or not GuiRoot then
        return
    end

    local settings = GetSettings()
    local screenWidth = (GetScreenWidth and GetScreenWidth()) or (GuiRoot.GetWidth and GuiRoot:GetWidth()) or 1920
    local screenHeight = (GetScreenHeight and GetScreenHeight()) or (GuiRoot.GetHeight and GuiRoot:GetHeight()) or 1080
    local x = (screenWidth - current.root:GetWidth()) * (settings.horizontalPosition / 100)
    local y = (screenHeight - current.root:GetHeight()) * (settings.verticalPosition / 100)

    current.root:ClearAnchors()
    current.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

local function FormatTime(durationMs)
    durationMs = math.max(0, tonumber(durationMs) or 0)
    local totalSeconds = math.floor(durationMs / 1000)
    local hours = math.floor(totalSeconds / 3600)
    local minutes = math.floor((totalSeconds % 3600) / 60)
    local seconds = totalSeconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local function FormatRevives(remaining, starting)
    if remaining == nil or starting == nil then
        return NQOL.L("common.not_available")
    end
    if zo_strformat and SI_REVIVE_COUNTER_REVIVES_USED then
        return zo_strformat(SI_REVIVE_COUNTER_REVIVES_USED, remaining, starting)
    end
    return string.format("%d/%d", remaining, starting)
end

local function FormatIcon(texture, size)
    if zo_iconFormat then
        return zo_iconFormat(texture, size, size)
    end
    return ""
end

local function FormatComponent(icon, value)
    return NQOL.L("features.trial_timer.component_format", icon, value)
end

local function FormatScore(score, bestScore, showLiveScore, showBestScore)
    local currentText = NQOL.Util.FormatNumber(math.max(0, tonumber(score) or 0))
    bestScore = tonumber(bestScore)

    if showLiveScore and showBestScore and bestScore and bestScore > 0 then
        return NQOL.L(
            "features.trial_timer.score_with_best_format",
            currentText,
            NQOL.Util.FormatNumber(bestScore)
        )
    elseif showLiveScore then
        return currentText
    elseif showBestScore and bestScore and bestScore > 0 then
        return NQOL.Util.FormatNumber(bestScore)
    end

    return nil
end

local function BuildDisplayText(durationMs, remaining, starting, score, bestScore)
    local settings = GetSettings()
    local fontSize = settings.fontSize
    local iconSize = math.max(16, Round(fontSize * 0.85))
    local parts = {}

    if settings.showElapsedTime then
        parts[#parts + 1] = FormatComponent(FormatIcon(TIMER_TEXTURE, iconSize), FormatTime(durationMs))
    end
    if settings.showVitality then
        parts[#parts + 1] = FormatComponent(FormatIcon(VITALITY_TEXTURE, iconSize), FormatRevives(remaining, starting))
    end

    local scoreText = FormatScore(score, bestScore, settings.showLiveScore, settings.showBestScore)
    if scoreText then
        parts[#parts + 1] = FormatComponent(FormatIcon(SCORE_TEXTURE, iconSize), scoreText)
    end

    local text = parts[1] or ""
    for index = 2, #parts do
        text = NQOL.L("features.trial_timer.display_format", text, parts[index])
    end
    return text
end

local function GetPreviewText()
    return BuildDisplayText(754000, 32, 36, 87420, 105630)
end

local function ApplyAppearance(text)
    local current = EnsureControl()
    if not current then
        return
    end

    local settings = GetSettings()
    local color = settings.color
    local backgroundColor = settings.backgroundColor
    local fontSize = settings.fontSize

    current.label:SetFont(ResolveFont())
    current.label:SetColor(color.r, color.g, color.b, color.a)
    current.label:SetDimensions(4096, math.max(128, fontSize * 2))
    current.label:SetText(text)

    local measuredWidth = current.label.GetTextDimensions and current.label:GetTextDimensions() or 0
    if measuredWidth <= 0 and current.label.GetTextWidth then
        measuredWidth = current.label:GetTextWidth()
    end
    local measuredHeight = current.label.GetTextHeight and current.label:GetTextHeight() or 0
    local paddingX = math.ceil(fontSize * 0.55)
    local paddingY = math.ceil(fontSize * 0.25)
    local contentWidth = math.ceil(measuredWidth) + math.max(4, math.ceil(fontSize * 0.15))
    local width = math.max(contentWidth + paddingX * 2, fontSize + paddingX * 2)
    local height = math.max(measuredHeight + paddingY * 2, fontSize * 1.5)

    current.root:SetDimensions(width, height)
    current.label:ClearAnchors()
    current.label:SetAnchor(TOPLEFT, current.root, TOPLEFT, paddingX, paddingY)
    current.label:SetDimensions(contentWidth, height - paddingY * 2)
    current.background:SetCenterColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, settings.backgroundOpacity / 100)
    current.background:SetEdgeColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, 0)
    ApplyPosition()
end

local function Hide()
    if control and control.root then
        control.root:SetHidden(true)
    end
end

local function ShouldShowPreview()
    local settings = GetSettings()
    return settingsPanelVisible and settings.showInSettings == true
end

local function ShouldShowRun()
    return GetSettings().enabled == true
        and (run.running or run.finished)
        and IsGameplaySceneShowing()
end

local function Refresh()
    local text
    if ShouldShowPreview() then
        text = GetPreviewText()
    elseif ShouldShowRun() then
        text = BuildDisplayText(run.durationMs, run.remainingRevives, run.startingRevives, run.score, run.bestScore)
    else
        lastDisplayText = nil
        Hide()
        return
    end

    if text == "" then
        lastDisplayText = nil
        Hide()
        return
    end

    if text ~= lastDisplayText then
        ApplyAppearance(text)
        lastDisplayText = text
    else
        ApplyPosition()
    end
    EnsureControl().root:SetHidden(false)
end

local function ReadRaidMetrics()
    if run.running and GetRaidDuration then
        run.durationMs = math.max(0, tonumber(GetRaidDuration()) or run.durationMs or 0)
    end
    if GetCurrentRaidScore then
        run.score = math.max(0, tonumber(GetCurrentRaidScore()) or run.score or 0)
    end
    if GetRaidReviveCountersRemaining then
        local remaining = GetRaidReviveCountersRemaining()
        if remaining ~= nil then
            run.remainingRevives = tonumber(remaining)
        end
    end
    if GetCurrentRaidStartingReviveCounters then
        local starting = GetCurrentRaidStartingReviveCounters()
        if starting ~= nil then
            run.startingRevives = tonumber(starting)
        end
    end
end

local function ReadBestScore(raidId)
    raidId = tonumber(raidId)
    if not raidId or raidId <= 0 or run.raidId ~= raidId or not GetRaidLeaderboardLocalPlayerInfo then
        return
    end

    local _, bestScore = GetRaidLeaderboardLocalPlayerInfo(raidId)
    bestScore = tonumber(bestScore)
    if bestScore and bestScore > 0 then
        run.bestScore = math.max(run.bestScore or 0, bestScore)
    end
    lastDisplayText = nil
end

local function RequestBestScore()
    if not GetSettings().showBestScore or not GetCurrentParticipatingRaidId or not GetRaidLeaderboardLocalPlayerInfo then
        return
    end

    local raidId = tonumber(GetCurrentParticipatingRaidId())
    if not raidId or raidId <= 0 then
        return
    end

    if run.raidId ~= raidId then
        run.raidId = raidId
        run.bestScore = nil
        run.leaderboardRequested = false
    end
    if run.leaderboardRequested then
        return
    end

    run.leaderboardRequested = true
    if QueryRaidLeaderboardData and RAID_CATEGORY_TRIAL then
        QueryRaidLeaderboardData(RAID_CATEGORY_TRIAL, raidId)
    end
    ReadBestScore(raidId)
end

local function ClearRun()
    run.running = false
    run.finished = false
    run.durationMs = 0
    run.score = 0
    run.bestScore = nil
    run.remainingRevives = nil
    run.startingRevives = nil
    run.raidId = nil
    run.leaderboardRequested = false
    run.hideAtMs = 0
    lastDisplayText = nil
end

local function StartOrResumeRun()
    run.running = true
    run.finished = false
    run.hideAtMs = 0
    ReadRaidMetrics()
    RequestBestScore()
end

local function FinishRun(durationMs, score, completed)
    if stoppedForGroupLeave or (not run.running and not IsTrialZone()) then
        return
    end

    ReadRaidMetrics()
    run.durationMs = math.max(0, tonumber(durationMs) or run.durationMs or 0)
    run.score = math.max(0, tonumber(score) or run.score or 0)
    if completed and run.score > (run.bestScore or 0) then
        run.bestScore = run.score
    end
    run.running = false
    run.finished = true
    run.hideAtMs = GetNowMs() + RESULT_HOLD_MS
    lastDisplayText = nil
end

local function UpdateLoop()
    if run.running then
        ReadRaidMetrics()
    elseif run.finished and GetNowMs() >= run.hideAtMs then
        ClearRun()
    end

    Refresh()
    if not run.running and not run.finished and updateRegistered and EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForUpdate(EVENT_NAMESPACE)
        updateRegistered = false
    end
end

local function UpdateUpdateLoop()
    local shouldUpdate = run.running or run.finished
    if shouldUpdate and not updateRegistered and EVENT_MANAGER then
        EVENT_MANAGER:RegisterForUpdate(EVENT_NAMESPACE, UPDATE_INTERVAL_MS, UpdateLoop)
        updateRegistered = true
    elseif not shouldUpdate and updateRegistered and EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForUpdate(EVENT_NAMESPACE)
        updateRegistered = false
    end
end

local function SynchronizeRun()
    if GetSettings().enabled ~= true then
        stoppedForGroupLeave = false
        ClearRun()
    elseif stoppedForGroupLeave then
        if not IsTrialZone() then
            stoppedForGroupLeave = false
        end
        ClearRun()
    elseif IsActiveTrial() then
        StartOrResumeRun()
    elseif run.running then
        ClearRun()
    end
    UpdateUpdateLoop()
    Refresh()
end

local function QueueSynchronizeRun()
    if zo_callLater then
        zo_callLater(SynchronizeRun, SYNC_DELAY_MS)
    else
        SynchronizeRun()
    end
end

local function OnTrialStarted()
    if GetSettings().enabled ~= true or not IsTrialZone() then
        return
    end
    stoppedForGroupLeave = false
    ClearRun()
    StartOrResumeRun()
    UpdateUpdateLoop()
    Refresh()
end

local function OnTrialComplete(_, _, score, totalTime)
    FinishRun(totalTime, score, true)
    UpdateUpdateLoop()
    Refresh()
end

local function OnTrialFailed(_, _, score)
    local durationMs = GetRaidDuration and GetRaidDuration() or run.durationMs
    FinishRun(durationMs, score, false)
    UpdateUpdateLoop()
    Refresh()
end

local function OnReviveCounterUpdate(_, currentCounter)
    if not run.running then
        return
    end
    if currentCounter ~= nil then
        run.remainingRevives = tonumber(currentCounter)
    end
    ReadRaidMetrics()
    lastDisplayText = nil
    Refresh()
end

local function OnScoreUpdate(_, _, _, totalScore)
    if not run.running then
        return
    end
    run.score = math.max(0, tonumber(totalScore) or run.score or 0)
    lastDisplayText = nil
    Refresh()
end

local function OnLeaderboardDataReceived(_, raidCategory, raidId)
    if raidCategory == RAID_CATEGORY_TRIAL and tonumber(raidId) == run.raidId then
        ReadBestScore(run.raidId)
        Refresh()
    end
end

local function OnLeaderboardPlayerDataChanged()
    if run.raidId then
        ReadBestScore(run.raidId)
        Refresh()
    end
end

local function OnGroupMemberLeft(_, _, _, isLocalPlayer)
    if isLocalPlayer ~= true then
        return
    end
    stoppedForGroupLeave = true
    ClearRun()
    UpdateUpdateLoop()
    Refresh()
end

local function RegisterEvents()
    if eventsRegistered or not EVENT_MANAGER then
        return
    end

    eventsRegistered = true
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_RAID_TRIAL_STARTED, OnTrialStarted)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_RAID_TRIAL_COMPLETE, OnTrialComplete)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_RAID_TRIAL_FAILED, OnTrialFailed)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_RAID_REVIVE_COUNTER_UPDATE, OnReviveCounterUpdate)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_RAID_TRIAL_SCORE_UPDATE, OnScoreUpdate)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_RAID_LEADERBOARD_DATA_RECEIVED, OnLeaderboardDataReceived)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_RAID_LEADERBOARD_PLAYER_DATA_CHANGED, OnLeaderboardPlayerDataChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_RAID_TIMER_STATE_UPDATE, QueueSynchronizeRun)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, QueueSynchronizeRun)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ZONE_CHANGED, QueueSynchronizeRun)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_GROUP_UPDATE, QueueSynchronizeRun)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_GROUP_MEMBER_LEFT, OnGroupMemberLeft)
end

local function UnregisterEvents()
    if not eventsRegistered or not EVENT_MANAGER then
        return
    end

    eventsRegistered = false
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_RAID_TRIAL_STARTED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_RAID_TRIAL_COMPLETE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_RAID_TRIAL_FAILED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_RAID_REVIVE_COUNTER_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_RAID_TRIAL_SCORE_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_RAID_LEADERBOARD_DATA_RECEIVED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_RAID_LEADERBOARD_PLAYER_DATA_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_RAID_TIMER_STATE_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_ZONE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_GROUP_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_GROUP_MEMBER_LEFT)
end

local function InstallSceneCallback()
    if sceneCallbackInstalled or not SCENE_MANAGER or not SCENE_MANAGER.RegisterCallback then
        return
    end

    sceneCallbackInstalled = true
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", Refresh)
    if EVENT_MANAGER and EVENT_SCREEN_RESIZED then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_ScreenResized", EVENT_SCREEN_RESIZED, Refresh)
    end
end

local function UninstallSceneCallback()
    if sceneCallbackInstalled and SCENE_MANAGER and SCENE_MANAGER.UnregisterCallback then
        SCENE_MANAGER:UnregisterCallback("SceneStateChanged", Refresh)
    end
    sceneCallbackInstalled = false
    if EVENT_MANAGER and EVENT_SCREEN_RESIZED then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_ScreenResized", EVENT_SCREEN_RESIZED)
    end
end

local function UpdateRuntime()
    if GetSettings().enabled == true then
        RegisterEvents()
        InstallSceneCallback()
        SynchronizeRun()
    else
        UnregisterEvents()
        stoppedForGroupLeave = false
        ClearRun()
        UpdateUpdateLoop()
        if ShouldShowPreview() then
            InstallSceneCallback()
        else
            UninstallSceneCallback()
        end
        Refresh()
    end
end

local function RefreshAfterSetting()
    lastDisplayText = nil
    Refresh()
end

function TrialTimer.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function TrialTimer.Initialize()
    if initialized then
        UpdateRuntime()
        return
    end
    initialized = true
    UpdateRuntime()
end

function TrialTimer.SetSettingsPanelVisible(value)
    settingsPanelVisible = value == true
    UpdateRuntime()
end

function TrialTimer.GetEnabled() return GetSettings().enabled end
function TrialTimer.GetEnabledDefault() return defaults.trialTimer.enabled end
function TrialTimer.SetEnabled(value)
    GetSettings().enabled = value == true
    UpdateRuntime()
end

function TrialTimer.GetShowInSettings() return GetSettings().showInSettings end
function TrialTimer.SetShowInSettings(value)
    GetSettings().showInSettings = value == true
    UpdateRuntime()
end


function TrialTimer.GetShowElapsedTime() return GetSettings().showElapsedTime end
function TrialTimer.SetShowElapsedTime(value)
    GetSettings().showElapsedTime = value == true
    RefreshAfterSetting()
end

function TrialTimer.GetShowVitality() return GetSettings().showVitality end
function TrialTimer.SetShowVitality(value)
    GetSettings().showVitality = value == true
    RefreshAfterSetting()
end

function TrialTimer.GetShowLiveScore() return GetSettings().showLiveScore end
function TrialTimer.SetShowLiveScore(value)
    GetSettings().showLiveScore = value == true
    RefreshAfterSetting()
end

function TrialTimer.GetShowBestScore() return GetSettings().showBestScore end
function TrialTimer.SetShowBestScore(value)
    GetSettings().showBestScore = value == true
    RequestBestScore()
    RefreshAfterSetting()
end

function TrialTimer.GetHorizontalPosition() return GetSettings().horizontalPosition end
function TrialTimer.SetHorizontalPosition(value)
    GetSettings().horizontalPosition = Clamp(value, 0, 100)
    RefreshAfterSetting()
end

function TrialTimer.GetVerticalPosition() return GetSettings().verticalPosition end
function TrialTimer.SetVerticalPosition(value)
    GetSettings().verticalPosition = Clamp(value, 0, 100)
    RefreshAfterSetting()
end

function TrialTimer.GetFontChoices() return NQOL.Util.GetFontChoices() end
function TrialTimer.GetFontChoiceNames() return NQOL.Util.GetFontChoiceNames() end
function TrialTimer.GetFont() return GetSettings().font end
function TrialTimer.SetFont(value)
    GetSettings().font = NQOL.Util.IsFontChoice(value) and value or NQOL.Util.GetDefaultFont()
    fontStringCache = {}
    RefreshAfterSetting()
end

function TrialTimer.GetFontSize() return GetSettings().fontSize end
function TrialTimer.SetFontSize(value)
    GetSettings().fontSize = Clamp(Round(value), FONT_SIZE_MIN, FONT_SIZE_MAX)
    fontStringCache = {}
    RefreshAfterSetting()
end

function TrialTimer.GetColor()
    local color = GetSettings().color
    return color.r, color.g, color.b, color.a
end
function TrialTimer.SetColor(red, green, blue, alpha)
    GetSettings().color = CopyColor({ r = red, g = green, b = blue, a = alpha or 1 }, defaults.trialTimer.color)
    RefreshAfterSetting()
end

function TrialTimer.GetBackgroundColor()
    local color = GetSettings().backgroundColor
    return color.r, color.g, color.b, color.a
end
function TrialTimer.SetBackgroundColor(red, green, blue, alpha)
    GetSettings().backgroundColor = CopyColor({ r = red, g = green, b = blue, a = alpha or 1 }, defaults.trialTimer.backgroundColor)
    RefreshAfterSetting()
end

function TrialTimer.GetBackgroundOpacity() return GetSettings().backgroundOpacity end
function TrialTimer.SetBackgroundOpacity(value)
    GetSettings().backgroundOpacity = Clamp(Round(value), BACKGROUND_OPACITY_MIN, BACKGROUND_OPACITY_MAX)
    RefreshAfterSetting()
end

function TrialTimer.GetFontSizeMin() return FONT_SIZE_MIN end
function TrialTimer.GetFontSizeMax() return FONT_SIZE_MAX end
function TrialTimer.GetBackgroundOpacityMin() return BACKGROUND_OPACITY_MIN end
function TrialTimer.GetBackgroundOpacityMax() return BACKGROUND_OPACITY_MAX end

function TrialTimer.GetEnabledLabel() return NQOL.L("features.trial_timer.enabled_label") end
function TrialTimer.GetEnabledTooltip() return NQOL.L("features.trial_timer.enabled_tooltip") end
function TrialTimer.GetShowInSettingsLabel() return NQOL.L("features.trial_timer.show_in_settings_label") end
function TrialTimer.GetShowInSettingsTooltip() return NQOL.L("features.trial_timer.show_in_settings_tooltip") end
function TrialTimer.GetShowElapsedTimeLabel() return NQOL.L("features.trial_timer.show_elapsed_time_label") end
function TrialTimer.GetShowElapsedTimeTooltip() return NQOL.L("features.trial_timer.show_elapsed_time_tooltip") end
function TrialTimer.GetShowVitalityLabel() return NQOL.L("features.trial_timer.show_vitality_label") end
function TrialTimer.GetShowVitalityTooltip() return NQOL.L("features.trial_timer.show_vitality_tooltip") end
function TrialTimer.GetShowLiveScoreLabel() return NQOL.L("features.trial_timer.show_live_score_label") end
function TrialTimer.GetShowLiveScoreTooltip() return NQOL.L("features.trial_timer.show_live_score_tooltip") end
function TrialTimer.GetShowBestScoreLabel() return NQOL.L("features.trial_timer.show_best_score_label") end
function TrialTimer.GetShowBestScoreTooltip() return NQOL.L("features.trial_timer.show_best_score_tooltip") end
function TrialTimer.GetHorizontalPositionLabel() return NQOL.L("features.trial_timer.horizontal_position_label") end
function TrialTimer.GetHorizontalPositionTooltip() return NQOL.L("features.trial_timer.horizontal_position_tooltip") end
function TrialTimer.GetVerticalPositionLabel() return NQOL.L("features.trial_timer.vertical_position_label") end
function TrialTimer.GetVerticalPositionTooltip() return NQOL.L("features.trial_timer.vertical_position_tooltip") end
function TrialTimer.GetFontLabel() return NQOL.L("features.trial_timer.font_label") end
function TrialTimer.GetFontTooltip() return NQOL.L("features.trial_timer.font_tooltip") end
function TrialTimer.GetFontSizeLabel() return NQOL.L("features.trial_timer.font_size_label") end
function TrialTimer.GetFontSizeTooltip() return NQOL.L("features.trial_timer.font_size_tooltip") end
function TrialTimer.GetColorLabel() return NQOL.L("features.trial_timer.color_label") end
function TrialTimer.GetColorTooltip() return NQOL.L("features.trial_timer.color_tooltip") end
function TrialTimer.GetBackgroundColorLabel() return NQOL.L("features.trial_timer.background_color_label") end
function TrialTimer.GetBackgroundColorTooltip() return NQOL.L("features.trial_timer.background_color_tooltip") end
function TrialTimer.GetBackgroundOpacityLabel() return NQOL.L("features.trial_timer.background_opacity_label") end
function TrialTimer.GetBackgroundOpacityTooltip() return NQOL.L("features.trial_timer.background_opacity_tooltip") end

NQOL.Features.TrialTimer = TrialTimer
