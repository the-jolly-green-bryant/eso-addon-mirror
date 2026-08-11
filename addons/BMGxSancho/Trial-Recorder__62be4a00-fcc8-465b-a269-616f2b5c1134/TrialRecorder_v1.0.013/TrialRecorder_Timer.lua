TrialRecorder = TrialRecorder or {}
local TR = TrialRecorder

TR.Timer = TR.Timer or {}
local Timer = TR.Timer

local UPDATE_NAME = "TrialRecorder_ActiveTimerUpdate"
local PREVIEW_HIDE_NAME = "TrialRecorder_ActiveTimerPreviewHide"
local UPDATE_INTERVAL_MS = 1000
local PREVIEW_DURATION_MS = 3500

local function Clamp(value, minimum, maximum)
    value = tonumber(value) or minimum
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

local function FormatRaidTime(milliseconds)
    local totalSeconds = math.max(0, math.floor((tonumber(milliseconds) or 0) / 1000))
    local hours = math.floor(totalSeconds / 3600)
    local minutes = math.floor((totalSeconds % 3600) / 60)
    local seconds = totalSeconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local function SafeNumberCall(fn)
    if type(fn) ~= "function" then
        return nil
    end

    local ok, value = pcall(fn)
    if not ok then
        return nil
    end

    return tonumber(value)
end

local function FormatVitality(remaining, starting)
    if remaining == nil or starting == nil then
        return "--/--"
    end
    return string.format("%d/%d", math.max(0, remaining), math.max(0, starting))
end

function Timer:IsRaidTimerActive()
    if type(IsRaidInProgress) ~= "function" or not IsRaidInProgress() then
        return false
    end

    if type(HasRaidEnded) == "function" and HasRaidEnded() then
        return false
    end

    return true
end

function Timer:GetRaidDuration()
    return SafeNumberCall(GetRaidDuration) or 0
end

function Timer:GetVitality()
    local remaining = SafeNumberCall(GetRaidReviveCountersRemaining)
    local starting = SafeNumberCall(GetCurrentRaidStartingReviveCounters)
    return remaining, starting
end

function Timer:GetCurrentScore()
    -- Reuse the score stream already owned by Trial Recorder when available.
    -- Fall back to ESO's current raid score without creating another score tracker.
    local session = TR.activeSession
    if session and tonumber(session.lastScore) then
        return tonumber(session.lastScore) or 0
    end

    return SafeNumberCall(GetCurrentRaidScore) or 0
end

function Timer:CreateControl()
    if self.control then return end

    local control = WINDOW_MANAGER:CreateTopLevelWindow("TrialRecorderActiveTimer")
    control:SetClampedToScreen(true)
    control:SetMouseEnabled(false)
    control:SetMovable(false)
    control:SetDrawTier(DT_HIGH)
    control:SetDrawLayer(DL_OVERLAY)
    control:SetDimensions(820, 64)
    control:SetHidden(true)

    local label = WINDOW_MANAGER:CreateControl("TrialRecorderActiveTimerLabel", control, CT_LABEL)
    label:SetAnchor(CENTER, control, CENTER, 0, 0)
    label:SetFont("ZoFontGamepadBold27")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(1, 1, 1, 1)
    label:SetText("TIME 00:00:00  |  VITALITY --/--  |  SCORE 0")

    self.control = control
    self.label = label
end

function Timer:UpdateAnchor()
    if not self.control then return end

    local settings = TR.sv and TR.sv.settings or {}
    local xPercent = Clamp(settings.activeTimerX, 0, 100) / 100
    local yPercent = Clamp(settings.activeTimerY, 0, 100) / 100

    local screenWidth = GuiRoot:GetWidth()
    local screenHeight = GuiRoot:GetHeight()
    local scale = Clamp(settings.activeTimerScale, 0.75, 1.50)
    local controlWidth = self.control:GetWidth() * scale
    local controlHeight = self.control:GetHeight() * scale

    local usableWidth = math.max(0, screenWidth - controlWidth)
    local usableHeight = math.max(0, screenHeight - controlHeight)
    local centerX = (controlWidth * 0.5) + (usableWidth * xPercent)
    local centerY = (controlHeight * 0.5) + (usableHeight * yPercent)

    self.control:ClearAnchors()
    self.control:SetAnchor(CENTER, GuiRoot, TOPLEFT, centerX, centerY)
end

function Timer:UpdateScale()
    if not self.control then return end
    local settings = TR.sv and TR.sv.settings or {}
    self.control:SetScale(Clamp(settings.activeTimerScale, 0.75, 1.50))
end

function Timer:UpdateText()
    if not self.label then return end

    local remaining, starting = self:GetVitality()
    local score = self:GetCurrentScore()
    local formattedScore = TR.FormatScore and TR:FormatScore(score) or tostring(score)

    self.label:SetText(string.format(
        "TIME %s  |  VITALITY %s  |  SCORE %s",
        FormatRaidTime(self:GetRaidDuration()),
        FormatVitality(remaining, starting),
        formattedScore
    ))
end

function Timer:StopUpdate()
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    self.updating = false
end

function Timer:StartUpdate()
    if self.updating then return end

    self.updating = true
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, UPDATE_INTERVAL_MS, function()
        if not TR.sv.settings.activeTimerEnabled or not Timer:IsRaidTimerActive() then
            Timer:RefreshVisibility()
            return
        end
        Timer:UpdateText()
    end)
end

function Timer:HidePreview()
    EVENT_MANAGER:UnregisterForUpdate(PREVIEW_HIDE_NAME)
    self.previewing = false
    self:RefreshVisibility()
end

function Timer:ShowPreview()
    if not self.control or not TR.sv.settings.activeTimerEnabled then return end

    EVENT_MANAGER:UnregisterForUpdate(PREVIEW_HIDE_NAME)
    self.previewing = true
    self.label:SetText("TIME 00:12:34  |  VITALITY 31/36  |  SCORE 248,760")
    self.control:SetHidden(false)

    EVENT_MANAGER:RegisterForUpdate(PREVIEW_HIDE_NAME, PREVIEW_DURATION_MS, function()
        EVENT_MANAGER:UnregisterForUpdate(PREVIEW_HIDE_NAME)
        Timer:HidePreview()
    end)
end

function Timer:RefreshVisibility()
    if not self.control then return end

    if not TR.sv.settings.activeTimerEnabled then
        self:StopUpdate()
        self.control:SetHidden(true)
        return
    end

    if self.previewing then
        self.control:SetHidden(false)
        return
    end

    if self:IsRaidTimerActive() then
        self:UpdateText()
        self.control:SetHidden(false)
        self:StartUpdate()
    else
        self:StopUpdate()
        self.control:SetHidden(true)
    end
end

function Timer:ApplySettings(showPreview)
    self:CreateControl()
    self:UpdateScale()
    self:UpdateAnchor()

    if showPreview and TR.sv.settings.activeTimerEnabled then
        self:ShowPreview()
    else
        self:RefreshVisibility()
    end
end

function Timer:Initialize()
    if self.initialized then return end

    self:CreateControl()
    self:ApplySettings(false)

    EVENT_MANAGER:RegisterForEvent("TrialRecorder_ActiveTimerState", EVENT_RAID_TIMER_STATE_UPDATE, function()
        Timer:RefreshVisibility()
    end)

    EVENT_MANAGER:RegisterForEvent("TrialRecorder_ActiveTimerStarted", EVENT_RAID_TRIAL_STARTED, function()
        Timer:RefreshVisibility()
    end)

    EVENT_MANAGER:RegisterForEvent("TrialRecorder_ActiveTimerComplete", EVENT_RAID_TRIAL_COMPLETE, function()
        Timer:RefreshVisibility()
    end)

    EVENT_MANAGER:RegisterForEvent("TrialRecorder_ActiveTimerFailed", EVENT_RAID_TRIAL_FAILED, function()
        Timer:RefreshVisibility()
    end)

    EVENT_MANAGER:RegisterForEvent("TrialRecorder_ActiveTimerPlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        Timer:RefreshVisibility()
    end)

    self.initialized = true
end
