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
    if type(GetRaidDuration) ~= "function" then
        return 0
    end

    local ok, duration = pcall(GetRaidDuration)
    if not ok then
        return 0
    end

    return tonumber(duration) or 0
end

function Timer:CreateControl()
    if self.control then return end

    local control = WINDOW_MANAGER:CreateTopLevelWindow("TrialRecorderActiveTimer")
    control:SetClampedToScreen(true)
    control:SetMouseEnabled(false)
    control:SetMovable(false)
    control:SetDrawTier(DT_HIGH)
    control:SetDrawLayer(DL_OVERLAY)
    control:SetDimensions(260, 64)
    control:SetHidden(true)

    local label = WINDOW_MANAGER:CreateControl("TrialRecorderActiveTimerLabel", control, CT_LABEL)
    label:SetAnchor(CENTER, control, CENTER, 0, 0)
    label:SetFont("ZoFontGamepadBold34")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(1, 1, 1, 1)
    label:SetText("00:00:00")

    self.control = control
    self.label = label
end

function Timer:UpdateAnchor()
    if not self.control then return end

    local settings = TR.sv and TR.sv.settings or {}
    local xPercent = Clamp(settings.activeTimerX, 5, 95) / 100
    local yPercent = Clamp(settings.activeTimerY, 5, 95) / 100
    local width = GuiRoot:GetWidth()
    local height = GuiRoot:GetHeight()

    self.control:ClearAnchors()
    self.control:SetAnchor(CENTER, GuiRoot, TOPLEFT, width * xPercent, height * yPercent)
end

function Timer:UpdateScale()
    if not self.control then return end
    local settings = TR.sv and TR.sv.settings or {}
    self.control:SetScale(Clamp(settings.activeTimerScale, 0.75, 1.50))
end

function Timer:UpdateText()
    if not self.label then return end
    self.label:SetText(FormatRaidTime(self:GetRaidDuration()))
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
    self.label:SetText("00:12:34")
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
    self:UpdateAnchor()
    self:UpdateScale()

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
