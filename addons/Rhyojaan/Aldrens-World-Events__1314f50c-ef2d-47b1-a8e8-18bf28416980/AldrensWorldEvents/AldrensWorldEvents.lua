local ADDON_NAME = "AldrensWorldEvents"
local DISPLAY_NAME = "Aldren's World Events"
local VERSION = "0.4.4"
local SAVED_VARIABLES_NAME = "AldrensWorldEventsSavedVariables"
local SAVED_VARIABLES_VERSION = 1
local EVENT_DATABASE_VERSION = 1
local EVENT_HISTORY_VERSION = 1
local ZONE_DATABASE_VERSION = 1
local PREDICTION_ENGINE_VERSION = 4
local TRACKING_FILTER_VERSION = 2
local MAX_HISTORY_ENTRIES = 50
local MAX_ZONE_RECENT_COMPLETIONS = 20
local MIN_PREDICTION_INTERVAL_SAMPLES = 2
local MIN_PREDICTION_COMPLETIONS = 3
local MAX_PREDICTION_INTERVAL_SAMPLES = 10
local MAX_DISPLAYED_PREDICTIONS = 3
local DEFAULT_RECOMMENDATION_CHOICES = 3
local MIN_PREDICTION_FRESHNESS_WINDOW_S = 2 * 60 * 60
local MAX_PREDICTION_FRESHNESS_WINDOW_S = 7 * 24 * 60 * 60
local PREDICTION_FRESHNESS_INTERVAL_MULTIPLIER = 4
local PREDICTION_REFRESH_INTERVAL_S = 30

local UI = {
    defaultWidth = 700,
    defaultHeight = 110,
    titleTop = 12,
    rowTop = 46,
    rowSpacing = 6,
    rowHeight = 64,
    contentPadding = 72,
    maxRows = 8,
}

AldrensWorldEvents = AldrensWorldEvents or {}
local ADT = AldrensWorldEvents

ADT.version = VERSION
ADT.activeEvents = {}
ADT.rows = {}
ADT.maxRows = UI.maxRows
ADT.loadedMessageUntilS = 0
ADT.previewUntilS = 0
ADT.predictionCandidates = {}
ADT.lastPredictionRefreshS = 0
ADT.defaults = {
    panelX = 0,
    panelY = 190,
    panelWidth = UI.defaultWidth,
    panelHeight = UI.defaultHeight,
    showPreview = false,
    showRecentCompletions = true,
    recentCompletionMinutes = 10,
    showNextEventSuggestion = true,
    predictionMinConfidence = 40,
    maxPredictionSuggestions = DEFAULT_RECOMMENDATION_CHOICES,
    useTrackedEventSelection = true,
    trackedEvents = {},
    eventDatabaseVersion = EVENT_DATABASE_VERSION,
    eventHistoryVersion = EVENT_HISTORY_VERSION,
    zoneDatabaseVersion = ZONE_DATABASE_VERSION,
    predictionEngineVersion = PREDICTION_ENGINE_VERSION,
    trackingFilterVersion = TRACKING_FILTER_VERSION,
    zoneDatabaseInitialized = false,
    worldEvents = {},
    eventHistory = {},
    zones = {},
    movingRoutes = {},
}

local function CleanName(value, fallback)
    if value == nil or value == "" then
        return fallback
    end

    return zo_strformat("<<C:1>>", value)
end

local function IsGenericEventName(value)
    if value == nil or value == "" then
        return true
    end

    local normalizedName = string.lower(value)
    return normalizedName == "unknown event"
        or normalizedName == "clean event"
        or normalizedName == "world event"
end

local function FormatRemaining(totalSeconds)
    totalSeconds = math.max(0, math.floor(totalSeconds))

    local hours = math.floor(totalSeconds / 3600)
    local minutes = math.floor((totalSeconds % 3600) / 60)
    local seconds = totalSeconds % 60

    if hours > 0 then
        return string.format("%d:%02d:%02d", hours, minutes, seconds)
    end

    return string.format("%d:%02d", minutes, seconds)
end

local function FormatCompletedAge(totalSeconds)
    totalSeconds = math.max(0, math.floor(totalSeconds))

    if totalSeconds < 60 then
        return "just now"
    end

    local minutes = math.floor(totalSeconds / 60)
    if minutes == 1 then
        return "1m ago"
    end

    return string.format("%dm ago", minutes)
end

local function FormatPredictionTime(totalSeconds)
    totalSeconds = math.floor(totalSeconds)

    if totalSeconds <= 0 then
        return "likely now"
    end

    if totalSeconds < 60 then
        return "in under 1m"
    end

    local minutes = math.floor(totalSeconds / 60)

    if minutes < 60 then
        return string.format("in %dm", minutes)
    end

    local hours = math.floor(minutes / 60)
    local remainingMinutes = minutes % 60

    if hours < 24 then
        if remainingMinutes > 0 then
            return string.format("in %dh %dm", hours, remainingMinutes)
        end

        return string.format("in %dh", hours)
    end

    local days = math.floor(hours / 24)
    local remainingHours = hours % 24

    if remainingHours > 0 then
        return string.format("in %dd %dh", days, remainingHours)
    end

    return string.format("in %dd", days)
end

local function FormatCompactDuration(totalSeconds)
    totalSeconds = math.max(0, math.floor(totalSeconds))

    if totalSeconds < 60 then
        return "under 1m"
    end

    local minutes = math.floor(totalSeconds / 60)

    if minutes < 60 then
        return string.format("%dm", minutes)
    end

    local hours = math.floor(minutes / 60)
    local remainingMinutes = minutes % 60

    if hours < 24 then
        if remainingMinutes > 0 then
            return string.format("%dh %dm", hours, remainingMinutes)
        end

        return string.format("%dh", hours)
    end

    local days = math.floor(hours / 24)
    local remainingHours = hours % 24

    if remainingHours > 0 then
        return string.format("%dd %dh", days, remainingHours)
    end

    return string.format("%dd", days)
end

local function FormatPredictionEstimate(totalSeconds, uncertaintyS)
    totalSeconds = math.floor(totalSeconds or 0)
    uncertaintyS = math.max(0, math.floor(uncertaintyS or 0))

    local estimateText

    if totalSeconds < -uncertaintyS then
        estimateText = string.format("overdue %s", FormatCompactDuration(math.abs(totalSeconds)))
    elseif totalSeconds <= uncertaintyS then
        estimateText = "likely now"
    else
        estimateText = FormatPredictionTime(totalSeconds)
    end

    if uncertaintyS >= 60 then
        return string.format("%s ±%s", estimateText, FormatCompactDuration(uncertaintyS))
    end

    return estimateText
end

function ADT:EnsureSavedVariableStructure()
    local previousPredictionEngineVersion = self.savedVars.predictionEngineVersion or 0
    local previousTrackingFilterVersion = self.savedVars.trackingFilterVersion or 0

    self.savedVars.worldEvents = self.savedVars.worldEvents or {}
    self.savedVars.eventHistory = self.savedVars.eventHistory or {}
    self.savedVars.zones = self.savedVars.zones or {}
    self.savedVars.movingRoutes = self.savedVars.movingRoutes or {}
    self.savedVars.trackedEvents = self.savedVars.trackedEvents or {}
    self.savedVars.eventDatabaseVersion = self.savedVars.eventDatabaseVersion or EVENT_DATABASE_VERSION
    self.savedVars.eventHistoryVersion = self.savedVars.eventHistoryVersion or EVENT_HISTORY_VERSION
    self.savedVars.zoneDatabaseVersion = self.savedVars.zoneDatabaseVersion or ZONE_DATABASE_VERSION

    if self.savedVars.showNextEventSuggestion == nil then
        self.savedVars.showNextEventSuggestion = self.defaults.showNextEventSuggestion
    end

    if self.savedVars.predictionMinConfidence == nil then
        self.savedVars.predictionMinConfidence = self.defaults.predictionMinConfidence
    end

    if self.savedVars.maxPredictionSuggestions == nil then
        self.savedVars.maxPredictionSuggestions = self.defaults.maxPredictionSuggestions
    end

    -- v0.3.4 makes the per-event checkboxes the permanent display filter.
    -- Missing event keys remain selected by default, preserving learned events.
    if previousTrackingFilterVersion < TRACKING_FILTER_VERSION then
        self.savedVars.useTrackedEventSelection = true
    elseif self.savedVars.useTrackedEventSelection == nil then
        self.savedVars.useTrackedEventSelection = true
    end

    self.savedVars.trackingFilterVersion = TRACKING_FILTER_VERSION

    while #self.savedVars.eventHistory > MAX_HISTORY_ENTRIES do
        table.remove(self.savedVars.eventHistory)
    end

    if not self.savedVars.zoneDatabaseInitialized then
        self:RebuildZoneDatabaseFromExistingData()
        self.savedVars.zoneDatabaseInitialized = true
    elseif previousPredictionEngineVersion < PREDICTION_ENGINE_VERSION then
        self:RebuildPredictionStatisticsFromHistory()
    end

    self.savedVars.predictionEngineVersion = PREDICTION_ENGINE_VERSION
end

function ADT:ApplyPanelPosition()
    if not self.panel or not self.savedVars then
        return
    end

    self.panel:ClearAnchors()
    self.panel:SetAnchor(TOP, GuiRoot, TOP, self.savedVars.panelX, self.savedVars.panelY)
end

function ADT:ApplyPanelSize()
    if not self.panel or not self.savedVars then
        return
    end

    self.panel:SetWidth(self.savedVars.panelWidth)
end

function ADT:IsUIMenuOpen()
    return SCENE_MANAGER
        and SCENE_MANAGER.IsInUIMode
        and SCENE_MANAGER:IsInUIMode()
end

function ADT:HideTrackerForMenu()
    if not self.panel then
        return
    end

    self:HideRows(1)
    self.panel:SetHidden(true)
end

function ADT:ShouldHideForMenu(now)
    now = now or GetTimeStamp()

    -- Layout controls may request a short preview while the player is
    -- actively adjusting the popup. Otherwise, all ESO UI menus hide it.
    if now < (self.previewUntilS or 0) then
        return false
    end

    return self:IsUIMenuOpen()
end

function ADT:RegisterMenuVisibility()
    if not EVENT_GAME_CAMERA_UI_MODE_CHANGED then
        return
    end

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "MenuVisibility",
        EVENT_GAME_CAMERA_UI_MODE_CHANGED,
        function()
            self:RefreshDisplay()
        end
    )
end

function ADT:RequestSavedVariablesSave()
    if RequestAddOnSavedVariablesPrioritySave then
        RequestAddOnSavedVariablesPrioritySave(ADDON_NAME)
    end
end

function ADT:SavePopupLayout()
    if not self.savedVars then
        return
    end

    self.savedVars.panelX = self.savedVars.panelX or self.defaults.panelX
    self.savedVars.panelY = self.savedVars.panelY or self.defaults.panelY
    self.savedVars.panelWidth = self.savedVars.panelWidth or self.defaults.panelWidth
    self.savedVars.panelHeight = self.savedVars.panelHeight or self.defaults.panelHeight
    self:RequestSavedVariablesSave()
end

function ADT:CreateUI()
    local wm = WINDOW_MANAGER

    self.panel = wm:CreateTopLevelWindow("AldrensWorldEventsPanel")
    self.panel:SetDimensions(UI.defaultWidth, UI.defaultHeight)
    self.panel:SetClampedToScreen(true)
    self.panel:SetDrawLayer(DL_OVERLAY)
    self.panel:SetDrawTier(DT_HIGH)
    self.panel:SetHidden(true)

    local background = wm:CreateControl("AldrensWorldEventsBackground", self.panel, CT_BACKDROP)
    background:SetAnchorFill(self.panel)
    background:SetCenterColor(0, 0, 0, 0.82)
    background:SetEdgeColor(0.75, 0.65, 0.35, 1)
    background:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16)

    self.title = wm:CreateControl("AldrensWorldEventsTitle", self.panel, CT_LABEL)
    self.title:SetAnchor(TOPLEFT, self.panel, TOPLEFT, 18, UI.titleTop)
    self.title:SetAnchor(TOPRIGHT, self.panel, TOPRIGHT, -18, UI.titleTop)
    self.title:SetFont("ZoFontGamepadBold27")
    self.title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.title:SetText("ALDREN'S WORLD EVENTS")

    for index = 1, self.maxRows do
        local row = wm:CreateControl("AldrensWorldEventsRow" .. index, self.panel, CT_LABEL)

        if index == 1 then
            row:SetAnchor(TOPLEFT, self.panel, TOPLEFT, 18, UI.rowTop)
            row:SetAnchor(TOPRIGHT, self.panel, TOPRIGHT, -18, UI.rowTop)
        else
            local previousRow = self.rows[index - 1]
            row:SetAnchor(TOPLEFT, previousRow, BOTTOMLEFT, 0, UI.rowSpacing)
            row:SetAnchor(TOPRIGHT, previousRow, BOTTOMRIGHT, 0, UI.rowSpacing)
        end

        row:SetFont("ZoFontGamepad27")
        row:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        row:SetHidden(true)
        self.rows[index] = row
    end

    self:ApplyPanelPosition()
    self:ApplyPanelSize()
end

function ADT:CreateSettings()
    if not LibHarvensAddonSettings then
        return
    end

    local settings = LibHarvensAddonSettings:AddAddon(DISPLAY_NAME, {
        allowDefaults = true,
        allowRefresh = true,
    })

    self.settings = settings
    self.trackingSettingKeys = {}
    self.trackingResetSettingKeys = {}

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Popup Position",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Layout Preview While Adjusting",
        tooltip = "Shows the popup briefly when you change its position or size. The popup still hides when ESO menus open.",
        getFunction = function()
            return self.savedVars.showPreview
        end,
        setFunction = function(value)
            self.savedVars.showPreview = value
            if not value then
                self.previewUntilS = 0
                self:RefreshDisplay()
            end
        end,
        default = self.defaults.showPreview,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Horizontal Position",
        min = -900,
        max = 900,
        step = 10,
        format = "%.0f",
        getFunction = function()
            return self.savedVars.panelX
        end,
        setFunction = function(value)
            self.savedVars.panelX = value
            if self.savedVars.showPreview then
                self.previewUntilS = GetTimeStamp() + 5
            end
            self:ApplyPanelPosition()
            self:RefreshDisplay()
        end,
        default = self.defaults.panelX,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Vertical Position",
        min = 40,
        max = 950,
        step = 10,
        format = "%.0f",
        getFunction = function()
            return self.savedVars.panelY
        end,
        setFunction = function(value)
            self.savedVars.panelY = value
            if self.savedVars.showPreview then
                self.previewUntilS = GetTimeStamp() + 5
            end
            self:ApplyPanelPosition()
            self:RefreshDisplay()
        end,
        default = self.defaults.panelY,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Reset Popup Position",
        buttonText = "Reset Position",
        clickHandler = function()
            self.savedVars.panelX = self.defaults.panelX
            self.savedVars.panelY = self.defaults.panelY
            if self.savedVars.showPreview then
                self.previewUntilS = GetTimeStamp() + 5
            end
            self:ApplyPanelPosition()
            self:RefreshDisplay()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Popup Size",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Popup Width",
        tooltip = "Changes the width of the event box.",
        min = 450,
        max = 1000,
        step = 25,
        format = "%.0f",
        getFunction = function()
            return self.savedVars.panelWidth
        end,
        setFunction = function(value)
            self.savedVars.panelWidth = value
            if self.savedVars.showPreview then
                self.previewUntilS = GetTimeStamp() + 5
            end
            self:ApplyPanelSize()
            self:RefreshDisplay()
        end,
        default = self.defaults.panelWidth,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Popup Height",
        tooltip = "Changes the vertical height of the event box. The box still grows when extra event lines need more room.",
        min = 110,
        max = 450,
        step = 10,
        format = "%.0f",
        getFunction = function()
            return self.savedVars.panelHeight
        end,
        setFunction = function(value)
            self.savedVars.panelHeight = value
            if self.savedVars.showPreview then
                self.previewUntilS = GetTimeStamp() + 5
            end
            self:RefreshDisplay()
        end,
        default = self.defaults.panelHeight,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Reset Popup Size",
        buttonText = "Reset Size",
        clickHandler = function()
            self.savedVars.panelWidth = self.defaults.panelWidth
            self.savedVars.panelHeight = self.defaults.panelHeight
            if self.savedVars.showPreview then
                self.previewUntilS = GetTimeStamp() + 5
            end
            self:ApplyPanelSize()
            self:RefreshDisplay()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Save Popup Layout",
        tooltip = "Immediately saves the current popup position and size so they remain after UI reloads and add-on updates.",
        buttonText = "Save Layout",
        clickHandler = function()
            self:SavePopupLayout()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Event History",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Recently Completed Events",
        tooltip = "Shows recently completed World Events beneath active events.",
        getFunction = function()
            return self.savedVars.showRecentCompletions
        end,
        setFunction = function(value)
            self.savedVars.showRecentCompletions = value
            self:RefreshDisplay()
        end,
        default = self.defaults.showRecentCompletions,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Recent Event Display Time",
        tooltip = "Controls how many minutes completed events remain visible.",
        min = 1,
        max = 30,
        step = 1,
        format = "%.0f",
        getFunction = function()
            return self.savedVars.recentCompletionMinutes
        end,
        setFunction = function(value)
            self.savedVars.recentCompletionMinutes = value
            self:RefreshDisplay()
        end,
        default = self.defaults.recentCompletionMinutes,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Clear Event History",
        buttonText = "Clear History",
        clickHandler = function()
            self:ClearEventHistory()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Predictions",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Predictions & Recommendations",
        tooltip = "Shows history-based timing estimates and Where To Go Next recommendations for selected events. This is not live cross-zone status.",
        getFunction = function()
            return self.savedVars.showNextEventSuggestion
        end,
        setFunction = function(value)
            self.savedVars.showNextEventSuggestion = value
            self:RefreshDisplay()
        end,
        default = self.defaults.showNextEventSuggestion,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Minimum Estimate Confidence",
        tooltip = "Only shows estimates that meet this confidence level. More observations improve confidence over time.",
        min = 20,
        max = 90,
        step = 5,
        format = "%.0f%%",
        getFunction = function()
            return self.savedVars.predictionMinConfidence
        end,
        setFunction = function(value)
            self.savedVars.predictionMinConfidence = value
            self:RefreshDisplay()
        end,
        default = self.defaults.predictionMinConfidence,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Recommendation Choices",
        tooltip = "Controls how many ranked choices appear in Where To Go Next, including the primary recommendation.",
        min = 1,
        max = MAX_DISPLAYED_PREDICTIONS,
        step = 1,
        format = "%.0f",
        getFunction = function()
            return self.savedVars.maxPredictionSuggestions
        end,
        setFunction = function(value)
            self.savedVars.maxPredictionSuggestions = value
            self:RefreshDisplay()
        end,
        default = self.defaults.maxPredictionSuggestions,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Event Tracking",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Select All Learned Events",
        buttonText = "Select All",
        clickHandler = function()
            self:SetAllLearnedEventsTracked(true)
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Clear Event Selection",
        buttonText = "Clear Selection",
        clickHandler = function()
            self:SetAllLearnedEventsTracked(false)
        end,
    })

    self:RefreshTrackingSettings()
end

function ADT:GetLearnedEventEntryByKey(eventKey)
    for _, learnedEvent in ipairs(self:GetLearnedEventEntries()) do
        if learnedEvent.eventKey == eventKey then
            return learnedEvent
        end
    end

    return nil
end

function ADT:GetTrackingSettingLabel(eventKey)
    local learnedEvent = self:GetLearnedEventEntryByKey(eventKey)

    if not learnedEvent then
        return "Learned World Event"
    end

    return string.format("%s — %s", learnedEvent.zoneName or "Unknown Zone", self:GetEventDisplayName(learnedEvent))
end

function ADT:AddLearnedEventTrackingSetting(learnedEvent)
    if not self.settings or not learnedEvent or not learnedEvent.eventKey then
        return false
    end

    self.trackingSettingKeys = self.trackingSettingKeys or {}
    self.trackingResetSettingKeys = self.trackingResetSettingKeys or {}

    local settingEventKey = learnedEvent.eventKey
    local addedSetting = false

    if not self.trackingSettingKeys[settingEventKey] then
        self.trackingSettingKeys[settingEventKey] = true
        self.settings:AddSetting({
            type = LibHarvensAddonSettings.ST_CHECKBOX,
            label = function()
                return self:GetTrackingSettingLabel(settingEventKey)
            end,
            tooltip = "Controls whether this event location appears in the popup. Hidden events are still recorded and continue improving predictions.",
            getFunction = function()
                return self.savedVars.trackedEvents[settingEventKey] ~= false
            end,
            setFunction = function(value)
                self.savedVars.trackedEvents[settingEventKey] = value and true or false
                self:RefreshDisplay()
            end,
            default = true,
        })
        addedSetting = true
    end

    if not self.trackingResetSettingKeys[settingEventKey] then
        self.trackingResetSettingKeys[settingEventKey] = true
        self.settings:AddSetting({
            type = LibHarvensAddonSettings.ST_BUTTON,
            label = function()
                return string.format("Reset Timing — %s", self:GetTrackingSettingLabel(settingEventKey))
            end,
            tooltip = "Clears completion and interval data for this event only. The event remains learned and selected, and future observations start rebuilding its estimate.",
            buttonText = "Reset Timing",
            clickHandler = function()
                self:ResetLearnedEventTiming(settingEventKey)
            end,
        })
        addedSetting = true
    end

    return addedSetting
end

function ADT:RefreshTrackingSettings()
    if not self.settings or self.refreshingTrackingSettings then
        return
    end

    self.refreshingTrackingSettings = true
    local addedSetting = false

    for _, learnedEvent in ipairs(self:GetLearnedEventEntries()) do
        if self:AddLearnedEventTrackingSetting(learnedEvent) then
            addedSetting = true
        end
    end

    self.refreshingTrackingSettings = false

    -- LibHarvensAddonSettings needs its selected page rebuilt after a dynamic
    -- setting is appended while the player is viewing that page.
    if addedSetting and self.settings.selected and self.settings.Select then
        self.settings.selected = false
        self.settings:Select()
    end
end

function ADT:GetEventDetails(worldEventInstanceId)
    local zoneName = CleanName(GetUnitZone("player"), "Unknown Zone")
    local poiName = "Unknown Event"
    local zoneIndex = 0
    local poiIndex = 0

    if GetWorldEventLocationContext and GetWorldEventPOIInfo then
        local context = GetWorldEventLocationContext(worldEventInstanceId)

        if context == WORLD_EVENT_LOCATION_CONTEXT_POINT_OF_INTEREST then
            zoneIndex, poiIndex = GetWorldEventPOIInfo(worldEventInstanceId)
            zoneIndex = zoneIndex or 0
            poiIndex = poiIndex or 0

            if zoneIndex > 0 then
                local foundZoneName = GetZoneNameByIndex(zoneIndex)
                zoneName = CleanName(foundZoneName, zoneName)
            end

            if zoneIndex > 0 and poiIndex > 0 and GetPOIInfo then
                local foundPoiName = GetPOIInfo(zoneIndex, poiIndex)
                poiName = CleanName(foundPoiName, poiName)
            end
        end
    end

    local worldEventId = 0
    local worldEventType = 0

    if GetWorldEventId then
        worldEventId = GetWorldEventId(worldEventInstanceId) or 0
    end

    if worldEventId ~= 0 and GetWorldEventType then
        worldEventType = GetWorldEventType(worldEventId) or 0
    end

    return {
        instanceId = worldEventInstanceId,
        zoneName = zoneName,
        poiName = poiName,
        zoneIndex = zoneIndex,
        poiIndex = poiIndex,
        worldEventId = worldEventId,
        worldEventType = worldEventType,
    }
end

function ADT:UpdateEventStep(eventData, stepDefId)
    if not eventData or not stepDefId or stepDefId == 0 then
        return false
    end

    eventData.stepDefId = stepDefId

    if not GetWorldEventStepName then
        return false
    end

    local stepName = CleanName(GetWorldEventStepName(eventData.instanceId, stepDefId), nil)
    if IsGenericEventName(stepName) then
        return false
    end

    local nameChanged = eventData.eventName ~= stepName
    eventData.stepName = stepName
    eventData.eventName = stepName
    return nameChanged
end

function ADT:UpdateParticipatingEventStep(eventData)
    if not eventData or not GetParticipatingWorldEventStep then
        return false
    end

    local participatingInstanceId, stepDefId = GetParticipatingWorldEventStep()
    if participatingInstanceId ~= eventData.instanceId then
        return false
    end

    return self:UpdateEventStep(eventData, stepDefId)
end

function ADT:ReadExpireTime(worldEventInstanceId)
    if not GetWorldEventCurrentStepExpireTimeS then
        return 0
    end

    return GetWorldEventCurrentStepExpireTimeS(worldEventInstanceId) or 0
end

function ADT:UpdateEventExpiration(eventData)
    local expireTimeS = self:ReadExpireTime(eventData.instanceId)

    if expireTimeS > GetTimeStamp() then
        eventData.expireTimeS = expireTimeS
    else
        eventData.expireTimeS = 0
    end
end

function ADT:GetEventDatabaseKey(eventData)
    if eventData and eventData.databaseKey and eventData.databaseKey ~= "" then
        return eventData.databaseKey
    end

    return string.format("%d:%d:%d", eventData.worldEventId or 0, eventData.zoneIndex or 0, eventData.poiIndex or 0)
end

function ADT:GetMovingRouteFamilyKey(eventData)
    if not eventData or not eventData.worldEventId or eventData.worldEventId == 0 then
        return nil
    end

    return string.format("%d:%d", eventData.worldEventId, eventData.zoneIndex or 0)
end

function ADT:GetMovingRouteDatabaseKey(eventData)
    local familyKey = self:GetMovingRouteFamilyKey(eventData)
    if not familyKey then
        return nil
    end

    return "route:" .. familyKey
end

function ADT:GetMovingRouteInfo(eventData)
    if not self.savedVars or not self.savedVars.movingRoutes then
        return nil
    end

    local familyKey = self:GetMovingRouteFamilyKey(eventData)
    if not familyKey then
        return nil
    end

    return self.savedVars.movingRoutes[familyKey]
end

function ADT:FormatMovingRouteName(routeInfo)
    if not routeInfo then
        return "Moving World Event"
    end

    local startName = routeInfo.startEventName or routeInfo.startPoiName
    local finalName = routeInfo.finalEventName or routeInfo.finalPoiName

    if startName and finalName and startName ~= finalName then
        return string.format("%s → %s", startName, finalName)
    end

    if startName then
        return string.format("%s route", startName)
    end

    return "Moving World Event"
end

function ADT:BuildMovingRouteEventData(eventData, routeInfo)
    if not eventData or not routeInfo then
        return eventData
    end

    return {
        databaseKey = routeInfo.databaseKey,
        isMovingRoute = true,
        routeFamilyKey = routeInfo.familyKey,
        instanceId = eventData.instanceId,
        worldEventId = routeInfo.worldEventId or eventData.worldEventId or 0,
        worldEventType = routeInfo.worldEventType or eventData.worldEventType or 0,
        zoneIndex = routeInfo.zoneIndex or eventData.zoneIndex or 0,
        zoneName = routeInfo.zoneName or eventData.zoneName or "Unknown Zone",
        poiIndex = 0,
        poiName = self:FormatMovingRouteName(routeInfo),
        eventName = self:FormatMovingRouteName(routeInfo),
        stepName = eventData.stepName,
        stepDefId = eventData.stepDefId or 0,
        startPoiIndex = routeInfo.startPoiIndex or 0,
        startPoiName = routeInfo.startPoiName,
        startEventName = routeInfo.startEventName,
        finalPoiIndex = routeInfo.finalPoiIndex or 0,
        finalPoiName = routeInfo.finalPoiName,
        finalEventName = routeInfo.finalEventName,
        activatedAtS = eventData.activatedAtS,
        expireTimeS = eventData.expireTimeS or 0,
    }
end

function ADT:GetStorageEventData(eventData)
    local routeInfo = self:GetMovingRouteInfo(eventData)
    if routeInfo then
        return self:BuildMovingRouteEventData(eventData, routeInfo)
    end

    return eventData
end

function ADT:GetTrackedSelectionKey(eventData)
    local routeInfo = self:GetMovingRouteInfo(eventData)
    if routeInfo and routeInfo.databaseKey then
        return routeInfo.databaseKey
    end

    return eventData.eventKey or eventData.databaseKey or self:GetEventDatabaseKey(eventData)
end

function ADT:IsRawEventHiddenByMovingRoute(zoneRecord, eventKey, eventRecord)
    if not zoneRecord or not eventRecord or eventRecord.isMovingRoute then
        return false
    end

    local familyKey = self:GetMovingRouteFamilyKey({
        worldEventId = eventRecord.worldEventId or 0,
        zoneIndex = zoneRecord.zoneIndex or 0,
    })
    local routeInfo = familyKey and self.savedVars.movingRoutes[familyKey] or nil

    return routeInfo ~= nil and eventKey ~= routeInfo.databaseKey
end

function ADT:MarkEventAsMoving(eventData)
    if not eventData or not self.savedVars then
        return nil
    end

    local familyKey = self:GetMovingRouteFamilyKey(eventData)
    local databaseKey = self:GetMovingRouteDatabaseKey(eventData)
    if not familyKey or not databaseKey then
        return nil
    end

    local routeInfo = self.savedVars.movingRoutes[familyKey]
    local routeWasKnown = routeInfo ~= nil
    if not routeInfo then
        routeInfo = {
            familyKey = familyKey,
            databaseKey = databaseKey,
            worldEventId = eventData.worldEventId or 0,
            worldEventType = eventData.worldEventType or 0,
            zoneIndex = eventData.zoneIndex or 0,
            zoneName = eventData.zoneName or "Unknown Zone",
            startPoiIndex = eventData.poiIndex or 0,
            startPoiName = eventData.poiName,
            startEventName = self:GetEventDisplayName(eventData),
        }
        self.savedVars.movingRoutes[familyKey] = routeInfo

        local anyKnownSelection = false
        local anySelected = false
        local zoneKey = self:GetZoneDatabaseKey(eventData.zoneIndex, eventData.zoneName)
        local zoneRecord = zoneKey and self.savedVars.zones[zoneKey] or nil

        for eventKey, eventRecord in pairs(zoneRecord and zoneRecord.events or {}) do
            if (eventRecord.worldEventId or 0) == (eventData.worldEventId or 0) then
                local selection = self.savedVars.trackedEvents[eventKey]
                if selection ~= nil then
                    anyKnownSelection = true
                    anySelected = anySelected or selection ~= false
                end
            end
        end

        if anyKnownSelection then
            self.savedVars.trackedEvents[databaseKey] = anySelected
        end
    end

    eventData.movingRouteFamilyKey = familyKey
    local routeEventData = self:BuildMovingRouteEventData(eventData, routeInfo)
    self:RecordWorldEvent(routeEventData, not routeWasKnown)
    return routeInfo
end

function ADT:FinalizeMovingRoute(eventData)
    local routeInfo = self:GetMovingRouteInfo(eventData)
    if not routeInfo then
        return eventData
    end

    routeInfo.finalPoiIndex = eventData.poiIndex or 0
    routeInfo.finalPoiName = eventData.poiName
    routeInfo.finalEventName = self:GetEventDisplayName(eventData)
    routeInfo.worldEventType = eventData.worldEventType or routeInfo.worldEventType or 0
    routeInfo.zoneName = eventData.zoneName or routeInfo.zoneName

    local routeEventData = self:BuildMovingRouteEventData(eventData, routeInfo)
    self:RecordWorldEvent(routeEventData, false)
    return routeEventData
end

function ADT:GetZoneDatabaseKey(zoneIndex, zoneName)
    if zoneIndex and zoneIndex > 0 then
        return string.format("zone:%d", zoneIndex)
    end

    if zoneName and zoneName ~= "" and zoneName ~= "Unknown Zone" then
        return string.format("name:%s", zoneName)
    end

    return nil
end

function ADT:GetOrCreateZoneRecord(eventData, observedAtS)
    if not self.savedVars or not self.savedVars.zones then
        return nil, nil
    end

    local zoneKey = self:GetZoneDatabaseKey(eventData.zoneIndex, eventData.zoneName)
    if not zoneKey then
        return nil, nil
    end

    observedAtS = observedAtS or GetTimeStamp()

    local zoneRecord = self.savedVars.zones[zoneKey]
    if not zoneRecord then
        zoneRecord = {
            zoneIndex = eventData.zoneIndex or 0,
            zoneName = eventData.zoneName or "Unknown Zone",
            firstObservedS = observedAtS,
            lastObservedS = observedAtS,
            observationCount = 0,
            completionCount = 0,
            totalActiveDurationS = 0,
            events = {},
            recentCompletions = {},
        }
        self.savedVars.zones[zoneKey] = zoneRecord
    end

    zoneRecord.events = zoneRecord.events or {}
    zoneRecord.recentCompletions = zoneRecord.recentCompletions or {}

    if eventData.zoneIndex and eventData.zoneIndex > 0 then
        zoneRecord.zoneIndex = eventData.zoneIndex
    end

    if eventData.zoneName and eventData.zoneName ~= "Unknown Zone" then
        zoneRecord.zoneName = eventData.zoneName
    end

    if not zoneRecord.firstObservedS or zoneRecord.firstObservedS == 0 or observedAtS < zoneRecord.firstObservedS then
        zoneRecord.firstObservedS = observedAtS
    end

    if not zoneRecord.lastObservedS or observedAtS > zoneRecord.lastObservedS then
        zoneRecord.lastObservedS = observedAtS
    end

    return zoneRecord, zoneKey
end

function ADT:GetOrCreateZoneEventRecord(zoneRecord, eventData, observedAtS)
    if not zoneRecord then
        return nil, nil, false
    end

    observedAtS = observedAtS or GetTimeStamp()

    local eventKey = self:GetEventDatabaseKey(eventData)
    local eventRecord = zoneRecord.events[eventKey]
    local recordIsNew = eventRecord == nil

    if recordIsNew then
        eventRecord = {
            databaseKey = eventKey,
            isMovingRoute = eventData.isMovingRoute == true,
            routeFamilyKey = eventData.routeFamilyKey,
            worldEventId = eventData.worldEventId or 0,
            worldEventType = eventData.worldEventType or 0,
            poiIndex = eventData.poiIndex or 0,
            poiName = eventData.poiName or "Unknown Event",
            eventName = eventData.eventName,
            stepName = eventData.stepName,
            stepDefId = eventData.stepDefId or 0,
            startPoiIndex = eventData.startPoiIndex or 0,
            startPoiName = eventData.startPoiName,
            startEventName = eventData.startEventName,
            finalPoiIndex = eventData.finalPoiIndex or 0,
            finalPoiName = eventData.finalPoiName,
            finalEventName = eventData.finalEventName,
            firstObservedS = observedAtS,
            lastObservedS = observedAtS,
            observationCount = 0,
            completionCount = 0,
            totalActiveDurationS = 0,
            lastCompletedS = 0,
            previousCompletedS = 0,
            averageCompletionIntervalS = 0,
            averageIntervalDeviationS = 0,
            intervalSampleCount = 0,
            intervalSamplesS = {},
        }
        zoneRecord.events[eventKey] = eventRecord
    end

    eventRecord.intervalSamplesS = eventRecord.intervalSamplesS or {}
    eventRecord.averageIntervalDeviationS = eventRecord.averageIntervalDeviationS or 0

    if eventData.worldEventId and eventData.worldEventId ~= 0 then
        eventRecord.worldEventId = eventData.worldEventId
    end

    if eventData.worldEventType and eventData.worldEventType ~= 0 then
        eventRecord.worldEventType = eventData.worldEventType
    end

    if eventData.poiIndex and eventData.poiIndex > 0 then
        eventRecord.poiIndex = eventData.poiIndex
    end

    if eventData.poiName and eventData.poiName ~= "Unknown Event" then
        eventRecord.poiName = eventData.poiName
    end

    if eventData.eventName and not IsGenericEventName(eventData.eventName) then
        eventRecord.eventName = eventData.eventName
    end

    if eventData.stepName and not IsGenericEventName(eventData.stepName) then
        eventRecord.stepName = eventData.stepName
    end

    if eventData.stepDefId and eventData.stepDefId ~= 0 then
        eventRecord.stepDefId = eventData.stepDefId
    end

    if eventData.isMovingRoute then
        eventRecord.isMovingRoute = true
        eventRecord.routeFamilyKey = eventData.routeFamilyKey or eventRecord.routeFamilyKey
        eventRecord.startPoiIndex = eventData.startPoiIndex or eventRecord.startPoiIndex or 0
        eventRecord.startPoiName = eventData.startPoiName or eventRecord.startPoiName
        eventRecord.startEventName = eventData.startEventName or eventRecord.startEventName
        eventRecord.finalPoiIndex = eventData.finalPoiIndex or eventRecord.finalPoiIndex or 0
        eventRecord.finalPoiName = eventData.finalPoiName or eventRecord.finalPoiName
        eventRecord.finalEventName = eventData.finalEventName or eventRecord.finalEventName
    end

    if not eventRecord.firstObservedS or eventRecord.firstObservedS == 0 or observedAtS < eventRecord.firstObservedS then
        eventRecord.firstObservedS = observedAtS
    end

    if not eventRecord.lastObservedS or observedAtS > eventRecord.lastObservedS then
        eventRecord.lastObservedS = observedAtS
    end

    return eventRecord, eventKey, recordIsNew
end

function ADT:RecalculateIntervalStatistics(eventRecord)
    if not eventRecord then
        return
    end

    local samples = eventRecord.intervalSamplesS or {}
    eventRecord.intervalSamplesS = samples
    eventRecord.intervalSampleCount = #samples

    if #samples == 0 then
        eventRecord.averageCompletionIntervalS = 0
        eventRecord.averageIntervalDeviationS = 0
        return
    end

    local totalIntervalS = 0

    for _, intervalS in ipairs(samples) do
        totalIntervalS = totalIntervalS + intervalS
    end

    local averageIntervalS = totalIntervalS / #samples
    local totalDeviationS = 0

    for _, intervalS in ipairs(samples) do
        totalDeviationS = totalDeviationS + math.abs(intervalS - averageIntervalS)
    end

    eventRecord.averageCompletionIntervalS = averageIntervalS
    eventRecord.averageIntervalDeviationS = totalDeviationS / #samples
end

function ADT:AddIntervalSample(eventRecord, intervalS)
    if not eventRecord or not intervalS or intervalS <= 0 then
        return
    end

    eventRecord.intervalSamplesS = eventRecord.intervalSamplesS or {}
    table.insert(eventRecord.intervalSamplesS, intervalS)

    while #eventRecord.intervalSamplesS > MAX_PREDICTION_INTERVAL_SAMPLES do
        table.remove(eventRecord.intervalSamplesS, 1)
    end

    self:RecalculateIntervalStatistics(eventRecord)
end

function ADT:UpdateCompletionInterval(eventRecord, completedAtS)
    if not eventRecord or not completedAtS or completedAtS <= 0 then
        return
    end

    local previousCompletedS = eventRecord.lastCompletedS or 0

    if previousCompletedS > 0 and completedAtS > previousCompletedS then
        eventRecord.previousCompletedS = previousCompletedS
        self:AddIntervalSample(eventRecord, completedAtS - previousCompletedS)
    end

    if completedAtS >= previousCompletedS then
        eventRecord.lastCompletedS = completedAtS
    end
end

function ADT:RecordZoneObservation(eventData, isNewObservation)
    if eventData.worldEventId == 0 and eventData.zoneIndex == 0 and eventData.poiIndex == 0 then
        return
    end

    local observedAtS = GetTimeStamp()
    local zoneRecord = self:GetOrCreateZoneRecord(eventData, observedAtS)
    local eventRecord = self:GetOrCreateZoneEventRecord(zoneRecord, eventData, observedAtS)

    if not zoneRecord or not eventRecord then
        return
    end

    if isNewObservation then
        zoneRecord.observationCount = (zoneRecord.observationCount or 0) + 1
        eventRecord.observationCount = (eventRecord.observationCount or 0) + 1
    end
end

function ADT:RecordZoneCompletion(eventData, completedAtS, activeDurationS)
    local zoneRecord = self:GetOrCreateZoneRecord(eventData, completedAtS)
    local eventRecord, eventKey = self:GetOrCreateZoneEventRecord(zoneRecord, eventData, completedAtS)

    if not zoneRecord or not eventRecord then
        return
    end

    zoneRecord.completionCount = (zoneRecord.completionCount or 0) + 1
    zoneRecord.totalActiveDurationS = (zoneRecord.totalActiveDurationS or 0) + activeDurationS
    zoneRecord.lastCompletedS = completedAtS
    zoneRecord.lastCompletedEventKey = eventKey

    eventRecord.completionCount = (eventRecord.completionCount or 0) + 1
    eventRecord.totalActiveDurationS = (eventRecord.totalActiveDurationS or 0) + activeDurationS
    self:UpdateCompletionInterval(eventRecord, completedAtS)

    table.insert(zoneRecord.recentCompletions, 1, {
        databaseKey = eventKey,
        isMovingRoute = eventData.isMovingRoute == true,
        routeFamilyKey = eventData.routeFamilyKey,
        poiName = eventData.poiName,
        eventName = eventData.eventName,
        stepName = eventData.stepName,
        stepDefId = eventData.stepDefId or 0,
        startPoiIndex = eventData.startPoiIndex or 0,
        startPoiName = eventData.startPoiName,
        startEventName = eventData.startEventName,
        finalPoiIndex = eventData.finalPoiIndex or 0,
        finalPoiName = eventData.finalPoiName,
        finalEventName = eventData.finalEventName,
        completedAtS = completedAtS,
        activeDurationS = activeDurationS,
    })

    while #zoneRecord.recentCompletions > MAX_ZONE_RECENT_COMPLETIONS do
        table.remove(zoneRecord.recentCompletions)
    end
end

function ADT:GetLearnedEventEntries()
    local learnedEvents = {}

    if not self.savedVars or not self.savedVars.zones then
        return learnedEvents
    end

    for zoneKey, zoneRecord in pairs(self.savedVars.zones) do
        for eventKey, eventRecord in pairs(zoneRecord.events or {}) do
            if not self:IsRawEventHiddenByMovingRoute(zoneRecord, eventKey, eventRecord) then
                table.insert(learnedEvents, {
                    zoneKey = zoneKey,
                    eventKey = eventKey,
                    databaseKey = eventKey,
                    isMovingRoute = eventRecord.isMovingRoute == true,
                    routeFamilyKey = eventRecord.routeFamilyKey,
                    zoneIndex = zoneRecord.zoneIndex or 0,
                    zoneName = zoneRecord.zoneName or "Unknown Zone",
                    worldEventId = eventRecord.worldEventId or 0,
                    worldEventType = eventRecord.worldEventType or 0,
                    poiIndex = eventRecord.poiIndex or 0,
                    poiName = eventRecord.poiName or "Unknown Event",
                    eventName = eventRecord.eventName,
                    stepName = eventRecord.stepName,
                    stepDefId = eventRecord.stepDefId or 0,
                    startPoiIndex = eventRecord.startPoiIndex or 0,
                    startPoiName = eventRecord.startPoiName,
                    startEventName = eventRecord.startEventName,
                    finalPoiIndex = eventRecord.finalPoiIndex or 0,
                    finalPoiName = eventRecord.finalPoiName,
                    finalEventName = eventRecord.finalEventName,
                    observationCount = eventRecord.observationCount or 0,
                    completionCount = eventRecord.completionCount or 0,
                    lastObservedS = eventRecord.lastObservedS or 0,
                    lastCompletedS = eventRecord.lastCompletedS or 0,
                    averageCompletionIntervalS = eventRecord.averageCompletionIntervalS or 0,
                    averageIntervalDeviationS = eventRecord.averageIntervalDeviationS or 0,
                    intervalSampleCount = eventRecord.intervalSampleCount or 0,
                })
            end
        end
    end

    table.sort(learnedEvents, function(left, right)
        if left.zoneName ~= right.zoneName then
            return left.zoneName < right.zoneName
        end

        local leftName = self:GetEventDisplayName(left)
        local rightName = self:GetEventDisplayName(right)

        if leftName ~= rightName then
            return leftName < rightName
        end

        return left.eventKey < right.eventKey
    end)

    return learnedEvents
end

function ADT:IsEventTracked(eventData)
    if not self.savedVars then
        return true
    end

    local eventKey = self:GetTrackedSelectionKey(eventData)
    return self.savedVars.trackedEvents[eventKey] ~= false
end

function ADT:SetAllLearnedEventsTracked(isTracked)
    if not self.savedVars then
        return
    end

    self.savedVars.trackedEvents = self.savedVars.trackedEvents or {}

    for _, learnedEvent in ipairs(self:GetLearnedEventEntries()) do
        self.savedVars.trackedEvents[learnedEvent.eventKey] = isTracked and true or false
    end

    self.savedVars.useTrackedEventSelection = true
    self:RefreshDisplay()
end

function ADT:GetTrackedEventCount()
    local trackedCount = 0

    for _, learnedEvent in ipairs(self:GetLearnedEventEntries()) do
        if self:IsEventTracked(learnedEvent) then
            trackedCount = trackedCount + 1
        end
    end

    return trackedCount
end

function ADT:GetPredictionCandidateForEvent(zoneKey, eventKey)
    for _, candidate in ipairs(self.predictionCandidates) do
        if candidate.zoneKey == zoneKey and candidate.eventKey == eventKey then
            return candidate
        end
    end

    return nil
end

function ADT:BuildTrackedEventOverview(now, excludedEventKeys)
    local overviewEntries = {}

    if not self.savedVars then
        return overviewEntries
    end

    now = now or GetTimeStamp()
    excludedEventKeys = excludedEventKeys or {}

    for _, learnedEvent in ipairs(self:GetLearnedEventEntries()) do
        if self:IsEventTracked(learnedEvent) and not excludedEventKeys[learnedEvent.eventKey] then
            local candidate = self:GetPredictionCandidateForEvent(learnedEvent.zoneKey, learnedEvent.eventKey)
            local timeUntilPredictedS = nil
            local predictionStatus = "Not Enough Data"

            if candidate then
                timeUntilPredictedS = (candidate.predictedAtS or 0) - now
                predictionStatus = self:GetPredictionStatus(candidate, now)
            end

            table.insert(overviewEntries, {
                event = learnedEvent,
                candidate = candidate,
                predictionStatus = predictionStatus,
                timeUntilPredictedS = timeUntilPredictedS,
            })
        end
    end

    table.sort(overviewEntries, function(left, right)
        local leftReliable = left.predictionStatus == "Estimated"
            or left.predictionStatus == "Expected Soon"
            or left.predictionStatus == "Overdue"
        local rightReliable = right.predictionStatus == "Estimated"
            or right.predictionStatus == "Expected Soon"
            or right.predictionStatus == "Overdue"

        if leftReliable ~= rightReliable then
            return leftReliable
        end

        if leftReliable and left.timeUntilPredictedS ~= right.timeUntilPredictedS then
            return left.timeUntilPredictedS < right.timeUntilPredictedS
        end

        if (left.event.lastObservedS or 0) ~= (right.event.lastObservedS or 0) then
            return (left.event.lastObservedS or 0) > (right.event.lastObservedS or 0)
        end

        if left.event.zoneName ~= right.event.zoneName then
            return left.event.zoneName < right.event.zoneName
        end

        return self:GetEventDisplayName(left.event) < self:GetEventDisplayName(right.event)
    end)

    return overviewEntries
end

function ADT:RefreshPredictionCandidates()
    ZO_ClearTable(self.predictionCandidates)

    if not self.savedVars or not self.savedVars.zones then
        return
    end

    local now = GetTimeStamp()
    self.lastPredictionRefreshS = now

    for zoneKey, zoneRecord in pairs(self.savedVars.zones) do
        for eventKey, eventRecord in pairs(zoneRecord.events or {}) do
            if not self:IsRawEventHiddenByMovingRoute(zoneRecord, eventKey, eventRecord) then
            local averageIntervalS = eventRecord.averageCompletionIntervalS or 0
            local averageDeviationS = eventRecord.averageIntervalDeviationS or 0
            local intervalSampleCount = eventRecord.intervalSampleCount or 0
            local completionCount = eventRecord.completionCount or 0
            local lastCompletedS = eventRecord.lastCompletedS or 0
            local lastObservedS = eventRecord.lastObservedS or 0

            if averageIntervalS > 0 and intervalSampleCount > 0 and lastCompletedS > 0 then
                local sampleEvidence = math.min(1, intervalSampleCount / 6)
                local completionEvidence = math.min(1, completionCount / 10)
                local deviationRatio = math.min(1, averageDeviationS / averageIntervalS)
                local consistencyEvidence = math.max(0, 1 - (deviationRatio * 2.5))
                local freshnessWindowS = math.min(
                    MAX_PREDICTION_FRESHNESS_WINDOW_S,
                    math.max(MIN_PREDICTION_FRESHNESS_WINDOW_S, averageIntervalS * PREDICTION_FRESHNESS_INTERVAL_MULTIPLIER)
                )
                local dataAgeS = math.max(0, now - lastCompletedS)
                local freshnessEvidence = math.max(0, 1 - (dataAgeS / freshnessWindowS))
                local isStale = dataAgeS > freshnessWindowS
                local confidence = math.floor((
                    (sampleEvidence * 0.4)
                    + (completionEvidence * 0.1)
                    + (consistencyEvidence * 0.3)
                    + (freshnessEvidence * 0.2)
                ) * 100 + 0.5)
                local uncertaintyS = math.max(60, averageIntervalS * 0.1, averageDeviationS * 1.5)

                table.insert(self.predictionCandidates, {
                    zoneKey = zoneKey,
                    zoneIndex = zoneRecord.zoneIndex or 0,
                    zoneName = zoneRecord.zoneName or "Unknown Zone",
                    eventKey = eventKey,
                    databaseKey = eventKey,
                    isMovingRoute = eventRecord.isMovingRoute == true,
                    routeFamilyKey = eventRecord.routeFamilyKey,
                    worldEventId = eventRecord.worldEventId or 0,
                    poiIndex = eventRecord.poiIndex or 0,
                    poiName = eventRecord.poiName or "Unknown Event",
                    eventName = eventRecord.eventName,
                    stepName = eventRecord.stepName,
                    stepDefId = eventRecord.stepDefId or 0,
                    startPoiIndex = eventRecord.startPoiIndex or 0,
                    startPoiName = eventRecord.startPoiName,
                    startEventName = eventRecord.startEventName,
                    finalPoiIndex = eventRecord.finalPoiIndex or 0,
                    finalPoiName = eventRecord.finalPoiName,
                    finalEventName = eventRecord.finalEventName,
                    lastObservedS = lastObservedS,
                    lastCompletedS = lastCompletedS,
                    predictedAtS = lastCompletedS + averageIntervalS,
                    averageIntervalS = averageIntervalS,
                    averageDeviationS = averageDeviationS,
                    uncertaintyS = uncertaintyS,
                    intervalSampleCount = intervalSampleCount,
                    completionCount = completionCount,
                    dataAgeS = dataAgeS,
                    freshnessWindowS = freshnessWindowS,
                    freshnessEvidence = freshnessEvidence,
                    isStale = isStale,
                    confidence = confidence,
                })
            end
            end
        end
    end
end

function ADT:GetPredictionScore(candidate, now)
    local averageIntervalS = candidate.averageIntervalS or 0

    if averageIntervalS <= 0 or candidate.isStale then
        return 0, 0, "Needs Fresh Data"
    end

    local status = self:GetPredictionStatus(candidate, now)

    if status ~= "Estimated" and status ~= "Expected Soon" and status ~= "Overdue" then
        return 0, (candidate.predictedAtS or 0) - now, status
    end

    local timeUntilPredictedS = (candidate.predictedAtS or 0) - now
    local uncertaintyS = math.max(60, candidate.uncertaintyS or 0)
    local confidenceEvidence = math.max(0, math.min(1, (candidate.confidence or 0) / 100))
    local freshnessEvidence = math.max(0, math.min(1, candidate.freshnessEvidence or 0))
    local sampleEvidence = math.max(0, math.min(1, (candidate.intervalSampleCount or 0) / 6))
    local timingEvidence = 0
    local overdueBonus = 0

    if status == "Expected Soon" then
        timingEvidence = 1
    elseif status == "Overdue" then
        local overdueS = math.abs(timeUntilPredictedS)
        local overdueScaleS = math.max(uncertaintyS, averageIntervalS * 0.5)
        local overdueRatio = math.min(1, overdueS / overdueScaleS)

        -- A recently overdue event is useful, but very old overdue estimates
        -- should gradually lose priority instead of staying first forever.
        timingEvidence = 0.95 - (overdueRatio * 0.15)
        overdueBonus = 0.05
    else
        local recommendationHorizonS = math.max(uncertaintyS * 2, averageIntervalS)
        timingEvidence = math.max(0, 1 - (timeUntilPredictedS / recommendationHorizonS))
    end

    local score = (timingEvidence * 0.45)
        + (confidenceEvidence * 0.30)
        + (freshnessEvidence * 0.15)
        + (sampleEvidence * 0.10)
        + overdueBonus

    return math.min(1, score), timeUntilPredictedS, status
end

function ADT:GetPredictionStatus(candidate, now)
    if not candidate then
        return "Not Enough Data", nil
    end

    if (candidate.intervalSampleCount or 0) < MIN_PREDICTION_INTERVAL_SAMPLES
        or (candidate.completionCount or 0) < MIN_PREDICTION_COMPLETIONS then
        return "Not Enough Data", nil
    end

    if candidate.isStale then
        return "Needs Fresh Data", nil
    end

    local minimumConfidence = self.savedVars.predictionMinConfidence or self.defaults.predictionMinConfidence
    if (candidate.confidence or 0) < minimumConfidence then
        return "Low Confidence", nil
    end

    local timeUntilPredictedS = (candidate.predictedAtS or 0) - now
    local uncertaintyS = candidate.uncertaintyS or 0

    if timeUntilPredictedS < -uncertaintyS then
        return "Overdue", FormatCompactDuration(math.abs(timeUntilPredictedS))
    end

    if timeUntilPredictedS <= uncertaintyS then
        if uncertaintyS >= 60 then
            return "Expected Soon", string.format("±%s", FormatCompactDuration(uncertaintyS))
        end

        return "Expected Soon", nil
    end

    return "Estimated", FormatPredictionEstimate(timeUntilPredictedS, uncertaintyS)
end

function ADT:GetRankedPredictionCandidates(now, limit)
    local rankedCandidates = {}

    if not self.savedVars or not self.savedVars.showNextEventSuggestion then
        return rankedCandidates
    end

    now = now or GetTimeStamp()
    limit = math.max(1, math.min(MAX_DISPLAYED_PREDICTIONS, limit or MAX_DISPLAYED_PREDICTIONS))

    local minimumConfidence = self.savedVars.predictionMinConfidence or self.defaults.predictionMinConfidence

    for _, candidate in ipairs(self.predictionCandidates) do
        if self:IsEventTracked(candidate)
            and (candidate.intervalSampleCount or 0) >= MIN_PREDICTION_INTERVAL_SAMPLES
            and (candidate.completionCount or 0) >= MIN_PREDICTION_COMPLETIONS
            and (candidate.confidence or 0) >= minimumConfidence then
            local score, timeUntilPredictedS, status = self:GetPredictionScore(candidate, now)

            if score > 0 then
                table.insert(rankedCandidates, {
                    candidate = candidate,
                    score = score,
                    timeUntilPredictedS = timeUntilPredictedS,
                    status = status,
                })
            end
        end
    end

    table.sort(rankedCandidates, function(left, right)
        if left.score ~= right.score then
            return left.score > right.score
        end

        if left.timeUntilPredictedS ~= right.timeUntilPredictedS then
            return left.timeUntilPredictedS < right.timeUntilPredictedS
        end

        if left.candidate.confidence ~= right.candidate.confidence then
            return left.candidate.confidence > right.candidate.confidence
        end

        if left.candidate.zoneName ~= right.candidate.zoneName then
            return left.candidate.zoneName < right.candidate.zoneName
        end

        return left.candidate.poiName < right.candidate.poiName
    end)

    while #rankedCandidates > limit do
        table.remove(rankedCandidates)
    end

    return rankedCandidates
end

function ADT:GetBestPredictionCandidate(now)
    local rankedCandidates = self:GetRankedPredictionCandidates(now, 1)
    local rankedCandidate = rankedCandidates[1]

    if not rankedCandidate then
        return nil
    end

    local candidate = rankedCandidate.candidate
    candidate.currentTimeUntilPredictedS = rankedCandidate.timeUntilPredictedS
    candidate.currentScore = rankedCandidate.score
    return candidate
end

function ADT:GetLearnedZoneCount()
    local zoneCount = 0

    if not self.savedVars or not self.savedVars.zones then
        return zoneCount
    end

    for _ in pairs(self.savedVars.zones) do
        zoneCount = zoneCount + 1
    end

    return zoneCount
end

function ADT:RecalculateZoneSummary(zoneRecord)
    if not zoneRecord then
        return
    end

    local completionCount = 0
    local totalActiveDurationS = 0
    local lastCompletedS = 0
    local lastCompletedEventKey = nil

    for eventKey, eventRecord in pairs(zoneRecord.events or {}) do
        completionCount = completionCount + (eventRecord.completionCount or 0)
        totalActiveDurationS = totalActiveDurationS + (eventRecord.totalActiveDurationS or 0)

        if (eventRecord.lastCompletedS or 0) > lastCompletedS then
            lastCompletedS = eventRecord.lastCompletedS or 0
            lastCompletedEventKey = eventKey
        end
    end

    zoneRecord.completionCount = completionCount
    zoneRecord.totalActiveDurationS = totalActiveDurationS
    zoneRecord.lastCompletedS = lastCompletedS
    zoneRecord.lastCompletedEventKey = lastCompletedEventKey
end

function ADT:ResetLearnedEventTiming(eventKey)
    if not self.savedVars or not eventKey then
        return
    end

    for _, zoneRecord in pairs(self.savedVars.zones or {}) do
        local eventRecord = zoneRecord.events and zoneRecord.events[eventKey]

        if eventRecord then
            eventRecord.completionCount = 0
            eventRecord.totalActiveDurationS = 0
            eventRecord.lastCompletedS = 0
            eventRecord.previousCompletedS = 0
            eventRecord.averageCompletionIntervalS = 0
            eventRecord.averageIntervalDeviationS = 0
            eventRecord.intervalSampleCount = 0
            eventRecord.intervalSamplesS = {}

            local recentCompletions = zoneRecord.recentCompletions or {}
            for index = #recentCompletions, 1, -1 do
                if recentCompletions[index].databaseKey == eventKey then
                    table.remove(recentCompletions, index)
                end
            end

            self:RecalculateZoneSummary(zoneRecord)
        end
    end

    local worldEventRecord = self.savedVars.worldEvents and self.savedVars.worldEvents[eventKey]
    if worldEventRecord then
        worldEventRecord.completionCount = 0
        worldEventRecord.totalActiveDurationS = 0
        worldEventRecord.lastCompletedS = 0
    end

    for index = #self.savedVars.eventHistory, 1, -1 do
        if self:GetEventDatabaseKey(self.savedVars.eventHistory[index]) == eventKey then
            table.remove(self.savedVars.eventHistory, index)
        end
    end

    self:RefreshPredictionCandidates()
    self:RequestSavedVariablesSave()
    self:RefreshDisplay()
end

function ADT:ClearEventHistory()
    ZO_ClearTable(self.savedVars.eventHistory)

    for _, zoneRecord in pairs(self.savedVars.zones or {}) do
        zoneRecord.recentCompletions = zoneRecord.recentCompletions or {}
        ZO_ClearTable(zoneRecord.recentCompletions)
    end

    self:RefreshDisplay()
end

function ADT:RebuildPredictionStatisticsFromHistory()
    if not self.savedVars or not self.savedVars.zones then
        return
    end

    local chronologicalHistory = {}

    for _, historyEntry in ipairs(self.savedVars.eventHistory or {}) do
        table.insert(chronologicalHistory, historyEntry)
    end

    table.sort(chronologicalHistory, function(left, right)
        return (left.completedAtS or 0) < (right.completedAtS or 0)
    end)

    local intervalStates = {}

    for _, historyEntry in ipairs(chronologicalHistory) do
        local completedAtS = historyEntry.completedAtS or 0

        if completedAtS > 0 then
            local eventData = {
                databaseKey = historyEntry.databaseKey,
                isMovingRoute = historyEntry.isMovingRoute == true,
                routeFamilyKey = historyEntry.routeFamilyKey,
                worldEventId = historyEntry.worldEventId or 0,
                worldEventType = historyEntry.worldEventType or 0,
                zoneIndex = historyEntry.zoneIndex or 0,
                poiIndex = historyEntry.poiIndex or 0,
                zoneName = historyEntry.zoneName or "Unknown Zone",
                poiName = historyEntry.poiName or "Unknown Event",
                eventName = historyEntry.eventName,
                stepName = historyEntry.stepName,
                stepDefId = historyEntry.stepDefId or 0,
                startPoiIndex = historyEntry.startPoiIndex or 0,
                startPoiName = historyEntry.startPoiName,
                startEventName = historyEntry.startEventName,
                finalPoiIndex = historyEntry.finalPoiIndex or 0,
                finalPoiName = historyEntry.finalPoiName,
                finalEventName = historyEntry.finalEventName,
            }
            local zoneRecord, zoneKey = self:GetOrCreateZoneRecord(eventData, completedAtS)
            local eventRecord, eventKey = self:GetOrCreateZoneEventRecord(zoneRecord, eventData, completedAtS)

            if zoneRecord and eventRecord then
                local compositeKey = string.format("%s|%s", zoneKey, eventKey)
                local state = intervalStates[compositeKey]

                if not state then
                    state = {
                        eventRecord = eventRecord,
                        lastCompletedS = 0,
                        previousCompletedS = 0,
                        samples = {},
                    }
                    intervalStates[compositeKey] = state
                end

                if state.lastCompletedS > 0 and completedAtS > state.lastCompletedS then
                    state.previousCompletedS = state.lastCompletedS
                    table.insert(state.samples, completedAtS - state.lastCompletedS)

                    while #state.samples > MAX_PREDICTION_INTERVAL_SAMPLES do
                        table.remove(state.samples, 1)
                    end
                end

                if completedAtS >= state.lastCompletedS then
                    state.lastCompletedS = completedAtS
                end
            end
        end
    end

    for _, state in pairs(intervalStates) do
        local eventRecord = state.eventRecord

        if eventRecord and #state.samples > 0 then
            eventRecord.intervalSamplesS = state.samples
            eventRecord.previousCompletedS = state.previousCompletedS
            eventRecord.lastCompletedS = math.max(eventRecord.lastCompletedS or 0, state.lastCompletedS)
            self:RecalculateIntervalStatistics(eventRecord)
        end
    end
end

function ADT:RebuildZoneDatabaseFromExistingData()
    ZO_ClearTable(self.savedVars.zones)

    local aggregatedEvents = {}
    local eventRecords = {}

    for databaseKey, sourceRecord in pairs(self.savedVars.worldEvents or {}) do
        local eventData = {
            databaseKey = sourceRecord.databaseKey or databaseKey,
            isMovingRoute = sourceRecord.isMovingRoute == true,
            routeFamilyKey = sourceRecord.routeFamilyKey,
            worldEventId = sourceRecord.worldEventId or 0,
            worldEventType = sourceRecord.worldEventType or 0,
            zoneIndex = sourceRecord.zoneIndex or 0,
            poiIndex = sourceRecord.poiIndex or 0,
            zoneName = sourceRecord.zoneName or "Unknown Zone",
            poiName = sourceRecord.poiName or "Unknown Event",
            eventName = sourceRecord.eventName,
            stepName = sourceRecord.stepName,
            stepDefId = sourceRecord.stepDefId or 0,
            startPoiIndex = sourceRecord.startPoiIndex or 0,
            startPoiName = sourceRecord.startPoiName,
            startEventName = sourceRecord.startEventName,
            finalPoiIndex = sourceRecord.finalPoiIndex or 0,
            finalPoiName = sourceRecord.finalPoiName,
            finalEventName = sourceRecord.finalEventName,
        }
        local observedAtS = sourceRecord.lastObservedS or sourceRecord.firstObservedS or GetTimeStamp()
        local zoneRecord, zoneKey = self:GetOrCreateZoneRecord(eventData, observedAtS)
        local eventRecord, eventKey = self:GetOrCreateZoneEventRecord(zoneRecord, eventData, observedAtS)

        if zoneRecord and eventRecord then
            local compositeKey = string.format("%s|%s", zoneKey, eventKey)
            aggregatedEvents[compositeKey] = true
            eventRecords[compositeKey] = eventRecord

            eventRecord.firstObservedS = sourceRecord.firstObservedS or eventRecord.firstObservedS
            eventRecord.lastObservedS = sourceRecord.lastObservedS or eventRecord.lastObservedS
            eventRecord.observationCount = sourceRecord.observationCount or 0
            eventRecord.completionCount = sourceRecord.completionCount or 0
            eventRecord.totalActiveDurationS = sourceRecord.totalActiveDurationS or 0
            eventRecord.lastCompletedS = sourceRecord.lastCompletedS or 0

            zoneRecord.observationCount = (zoneRecord.observationCount or 0) + eventRecord.observationCount
            zoneRecord.completionCount = (zoneRecord.completionCount or 0) + eventRecord.completionCount
            zoneRecord.totalActiveDurationS = (zoneRecord.totalActiveDurationS or 0) + eventRecord.totalActiveDurationS

            if eventRecord.lastCompletedS > (zoneRecord.lastCompletedS or 0) then
                zoneRecord.lastCompletedS = eventRecord.lastCompletedS
                zoneRecord.lastCompletedEventKey = databaseKey
            end
        end
    end

    local chronologicalHistory = {}
    for _, historyEntry in ipairs(self.savedVars.eventHistory or {}) do
        table.insert(chronologicalHistory, historyEntry)
    end

    table.sort(chronologicalHistory, function(left, right)
        return (left.completedAtS or 0) < (right.completedAtS or 0)
    end)

    local intervalStates = {}

    for _, historyEntry in ipairs(chronologicalHistory) do
        local completedAtS = historyEntry.completedAtS or 0

        if completedAtS > 0 then
            local eventData = {
                databaseKey = historyEntry.databaseKey,
                isMovingRoute = historyEntry.isMovingRoute == true,
                routeFamilyKey = historyEntry.routeFamilyKey,
                worldEventId = historyEntry.worldEventId or 0,
                worldEventType = historyEntry.worldEventType or 0,
                zoneIndex = historyEntry.zoneIndex or 0,
                poiIndex = historyEntry.poiIndex or 0,
                zoneName = historyEntry.zoneName or "Unknown Zone",
                poiName = historyEntry.poiName or "Unknown Event",
                eventName = historyEntry.eventName,
                stepName = historyEntry.stepName,
                stepDefId = historyEntry.stepDefId or 0,
                startPoiIndex = historyEntry.startPoiIndex or 0,
                startPoiName = historyEntry.startPoiName,
                startEventName = historyEntry.startEventName,
                finalPoiIndex = historyEntry.finalPoiIndex or 0,
                finalPoiName = historyEntry.finalPoiName,
                finalEventName = historyEntry.finalEventName,
            }
            local zoneRecord, zoneKey = self:GetOrCreateZoneRecord(eventData, completedAtS)
            local eventRecord, eventKey = self:GetOrCreateZoneEventRecord(zoneRecord, eventData, completedAtS)

            if zoneRecord and eventRecord then
                local compositeKey = string.format("%s|%s", zoneKey, eventKey)
                eventRecords[compositeKey] = eventRecord

                if not aggregatedEvents[compositeKey] then
                    local activeDurationS = historyEntry.activeDurationS or 0
                    eventRecord.completionCount = (eventRecord.completionCount or 0) + 1
                    eventRecord.totalActiveDurationS = (eventRecord.totalActiveDurationS or 0) + activeDurationS
                    zoneRecord.completionCount = (zoneRecord.completionCount or 0) + 1
                    zoneRecord.totalActiveDurationS = (zoneRecord.totalActiveDurationS or 0) + activeDurationS
                end

                local state = intervalStates[compositeKey]
                if not state then
                    state = {
                        lastCompletedS = 0,
                        previousCompletedS = 0,
                        totalIntervalS = 0,
                        intervalSampleCount = 0,
                    }
                    intervalStates[compositeKey] = state
                end

                if state.lastCompletedS > 0 and completedAtS > state.lastCompletedS then
                    state.previousCompletedS = state.lastCompletedS
                    state.totalIntervalS = state.totalIntervalS + (completedAtS - state.lastCompletedS)
                    state.intervalSampleCount = state.intervalSampleCount + 1
                end

                if completedAtS >= state.lastCompletedS then
                    state.lastCompletedS = completedAtS
                end
            end
        end
    end

    for compositeKey, state in pairs(intervalStates) do
        local eventRecord = eventRecords[compositeKey]

        if eventRecord then
            eventRecord.previousCompletedS = state.previousCompletedS
            eventRecord.intervalSampleCount = state.intervalSampleCount

            if state.intervalSampleCount > 0 then
                eventRecord.averageCompletionIntervalS = state.totalIntervalS / state.intervalSampleCount
            end

            if state.lastCompletedS > (eventRecord.lastCompletedS or 0) then
                eventRecord.lastCompletedS = state.lastCompletedS
            end
        end
    end

    for _, historyEntry in ipairs(self.savedVars.eventHistory or {}) do
        local completedAtS = historyEntry.completedAtS or 0

        if completedAtS > 0 then
            local eventData = {
                databaseKey = historyEntry.databaseKey,
                isMovingRoute = historyEntry.isMovingRoute == true,
                routeFamilyKey = historyEntry.routeFamilyKey,
                worldEventId = historyEntry.worldEventId or 0,
                worldEventType = historyEntry.worldEventType or 0,
                zoneIndex = historyEntry.zoneIndex or 0,
                poiIndex = historyEntry.poiIndex or 0,
                zoneName = historyEntry.zoneName or "Unknown Zone",
                poiName = historyEntry.poiName or "Unknown Event",
                eventName = historyEntry.eventName,
                stepName = historyEntry.stepName,
                stepDefId = historyEntry.stepDefId or 0,
                startPoiIndex = historyEntry.startPoiIndex or 0,
                startPoiName = historyEntry.startPoiName,
                startEventName = historyEntry.startEventName,
                finalPoiIndex = historyEntry.finalPoiIndex or 0,
                finalPoiName = historyEntry.finalPoiName,
                finalEventName = historyEntry.finalEventName,
            }
            local zoneRecord = self:GetOrCreateZoneRecord(eventData, completedAtS)

            if zoneRecord and #zoneRecord.recentCompletions < MAX_ZONE_RECENT_COMPLETIONS then
                table.insert(zoneRecord.recentCompletions, {
                    databaseKey = self:GetEventDatabaseKey(eventData),
                    poiName = eventData.poiName,
                    eventName = eventData.eventName,
                    stepName = eventData.stepName,
                    stepDefId = eventData.stepDefId or 0,
                    completedAtS = completedAtS,
                    activeDurationS = historyEntry.activeDurationS or 0,
                })
            end
        end
    end

    self:RebuildPredictionStatisticsFromHistory()
end

function ADT:RecordWorldEvent(eventData, isNewObservation)
    eventData = self:GetStorageEventData(eventData)

    if not self.savedVars or not self.savedVars.worldEvents then
        return
    end

    if eventData.worldEventId == 0 and eventData.zoneIndex == 0 and eventData.poiIndex == 0 then
        return
    end

    local databaseKey = self:GetEventDatabaseKey(eventData)
    local now = GetTimeStamp()
    local record = self.savedVars.worldEvents[databaseKey]
    local recordIsNew = record == nil
    local previousEventName = record and record.eventName or nil

    if recordIsNew then
        record = {
            databaseKey = databaseKey,
            isMovingRoute = eventData.isMovingRoute == true,
            routeFamilyKey = eventData.routeFamilyKey,
            worldEventId = eventData.worldEventId,
            worldEventType = eventData.worldEventType,
            zoneIndex = eventData.zoneIndex,
            poiIndex = eventData.poiIndex,
            zoneName = eventData.zoneName,
            poiName = eventData.poiName,
            eventName = eventData.eventName,
            stepName = eventData.stepName,
            stepDefId = eventData.stepDefId or 0,
            startPoiIndex = eventData.startPoiIndex or 0,
            startPoiName = eventData.startPoiName,
            startEventName = eventData.startEventName,
            finalPoiIndex = eventData.finalPoiIndex or 0,
            finalPoiName = eventData.finalPoiName,
            finalEventName = eventData.finalEventName,
            firstObservedS = now,
            lastObservedS = now,
            observationCount = 0,
            completionCount = 0,
            totalActiveDurationS = 0,
        }
        self.savedVars.worldEvents[databaseKey] = record
    end

    if eventData.worldEventType ~= 0 then
        record.worldEventType = eventData.worldEventType
    end

    if eventData.zoneName ~= "Unknown Zone" then
        record.zoneName = eventData.zoneName
    end

    if eventData.poiName ~= "Unknown Event" then
        record.poiName = eventData.poiName
    end

    if eventData.eventName and not IsGenericEventName(eventData.eventName) then
        record.eventName = eventData.eventName
    end

    if eventData.stepName and not IsGenericEventName(eventData.stepName) then
        record.stepName = eventData.stepName
    end

    if eventData.stepDefId and eventData.stepDefId ~= 0 then
        record.stepDefId = eventData.stepDefId
    end

    if eventData.isMovingRoute then
        record.isMovingRoute = true
        record.routeFamilyKey = eventData.routeFamilyKey or record.routeFamilyKey
        record.startPoiIndex = eventData.startPoiIndex or record.startPoiIndex or 0
        record.startPoiName = eventData.startPoiName or record.startPoiName
        record.startEventName = eventData.startEventName or record.startEventName
        record.finalPoiIndex = eventData.finalPoiIndex or record.finalPoiIndex or 0
        record.finalPoiName = eventData.finalPoiName or record.finalPoiName
        record.finalEventName = eventData.finalEventName or record.finalEventName
    end

    record.lastObservedS = now

    local shouldCountObservation = recordIsNew or isNewObservation

    if shouldCountObservation then
        record.observationCount = (record.observationCount or 0) + 1
    end

    self:RecordZoneObservation(eventData, shouldCountObservation)
    self:RefreshPredictionCandidates()

    if recordIsNew or record.eventName ~= previousEventName then
        self:RefreshTrackingSettings()
    end
end

function ADT:RecordCompletedEvent(eventData)
    if not self.savedVars or not self.savedVars.eventHistory then
        return
    end

    local completedAtS = GetTimeStamp()
    local activatedAtS = eventData.activatedAtS or completedAtS
    local activeDurationS = math.max(0, completedAtS - activatedAtS)

    table.insert(self.savedVars.eventHistory, 1, {
        databaseKey = self:GetEventDatabaseKey(eventData),
        isMovingRoute = eventData.isMovingRoute == true,
        routeFamilyKey = eventData.routeFamilyKey,
        worldEventId = eventData.worldEventId,
        worldEventType = eventData.worldEventType,
        zoneIndex = eventData.zoneIndex,
        poiIndex = eventData.poiIndex,
        zoneName = eventData.zoneName,
        poiName = eventData.poiName,
        eventName = eventData.eventName,
        stepName = eventData.stepName,
        stepDefId = eventData.stepDefId or 0,
        startPoiIndex = eventData.startPoiIndex or 0,
        startPoiName = eventData.startPoiName,
        startEventName = eventData.startEventName,
        finalPoiIndex = eventData.finalPoiIndex or 0,
        finalPoiName = eventData.finalPoiName,
        finalEventName = eventData.finalEventName,
        activatedAtS = activatedAtS,
        completedAtS = completedAtS,
        activeDurationS = activeDurationS,
    })

    while #self.savedVars.eventHistory > MAX_HISTORY_ENTRIES do
        table.remove(self.savedVars.eventHistory)
    end

    local databaseKey = self:GetEventDatabaseKey(eventData)
    local databaseRecord = self.savedVars.worldEvents[databaseKey]

    if databaseRecord then
        databaseRecord.lastCompletedS = completedAtS
        databaseRecord.completionCount = (databaseRecord.completionCount or 0) + 1
        databaseRecord.totalActiveDurationS = (databaseRecord.totalActiveDurationS or 0) + activeDurationS
        if eventData.eventName and not IsGenericEventName(eventData.eventName) then
            databaseRecord.eventName = eventData.eventName
        end
    end

    self:RecordZoneCompletion(eventData, completedAtS, activeDurationS)
    self:RefreshPredictionCandidates()
    self:RefreshTrackingSettings()
end

function ADT:TrackActivatedEvent(worldEventInstanceId, stepDefId)
    if not worldEventInstanceId or worldEventInstanceId == 0 then
        return
    end

    if self.activeEvents[worldEventInstanceId] then
        self:RefreshTrackedEvent(worldEventInstanceId, true, stepDefId)
        return
    end

    local eventData = self:GetEventDetails(worldEventInstanceId)
    eventData.expireTimeS = 0
    eventData.activatedAtS = GetTimeStamp()

    if not self:UpdateEventStep(eventData, stepDefId) then
        self:UpdateParticipatingEventStep(eventData)
    end

    self:UpdateEventExpiration(eventData)

    local routeInfo = self:GetMovingRouteInfo(eventData)
    if routeInfo then
        routeInfo.startPoiIndex = eventData.poiIndex or routeInfo.startPoiIndex or 0
        routeInfo.startPoiName = eventData.poiName or routeInfo.startPoiName
        routeInfo.startEventName = self:GetEventDisplayName(eventData)
        routeInfo.zoneName = eventData.zoneName or routeInfo.zoneName
        eventData.movingRouteFamilyKey = routeInfo.familyKey
    end

    self.activeEvents[worldEventInstanceId] = eventData
    self:RecordWorldEvent(eventData, true)
    self:RefreshDisplay()
end

function ADT:RefreshTrackedEvent(worldEventInstanceId, refreshDetails, stepDefId)
    local eventData = self.activeEvents[worldEventInstanceId]
    if not eventData then
        self:TrackActivatedEvent(worldEventInstanceId, stepDefId)
        return
    end

    if refreshDetails then
        local refreshedData = self:GetEventDetails(worldEventInstanceId)
        eventData.zoneName = refreshedData.zoneName
        eventData.poiName = refreshedData.poiName
        eventData.zoneIndex = refreshedData.zoneIndex
        eventData.poiIndex = refreshedData.poiIndex
        eventData.worldEventId = refreshedData.worldEventId
        eventData.worldEventType = refreshedData.worldEventType
    end

    local nameChanged = self:UpdateEventStep(eventData, stepDefId)

    if not stepDefId then
        nameChanged = self:UpdateParticipatingEventStep(eventData) or nameChanged
    end

    self:UpdateEventExpiration(eventData)
    self:RecordWorldEvent(eventData, false)

    if nameChanged then
        self:RefreshTrackingSettings()
    end

    self:RefreshDisplay()
end

function ADT:CompleteEvent(worldEventInstanceId)
    local eventData = self.activeEvents[worldEventInstanceId]
    if not eventData then
        return
    end

    eventData = self:FinalizeMovingRoute(eventData)
    self:RecordCompletedEvent(eventData)
    self.activeEvents[worldEventInstanceId] = nil
    self:RefreshDisplay()
end

function ADT:ClearEvents()
    ZO_ClearTable(self.activeEvents)
    self:RefreshDisplay()
end

function ADT:BuildVisibleEvents()
    local visibleEvents = {}
    local now = GetTimeStamp()

    for _, eventData in pairs(self.activeEvents) do
        if self:IsEventTracked(eventData) then
            table.insert(visibleEvents, eventData)
        end
    end

    table.sort(visibleEvents, function(left, right)
        local leftHasTimer = left.expireTimeS and left.expireTimeS > now
        local rightHasTimer = right.expireTimeS and right.expireTimeS > now

        if leftHasTimer ~= rightHasTimer then
            return leftHasTimer
        end

        if leftHasTimer and left.expireTimeS ~= right.expireTimeS then
            return left.expireTimeS < right.expireTimeS
        end

        if left.zoneName ~= right.zoneName then
            return left.zoneName < right.zoneName
        end

        if left.poiName ~= right.poiName then
            return left.poiName < right.poiName
        end

        return left.instanceId < right.instanceId
    end)

    return visibleEvents
end

function ADT:BuildRecentCompletions(now)
    local recentCompletions = {}

    if not self.savedVars.showRecentCompletions then
        return recentCompletions
    end

    local recentWindowS = math.max(1, self.savedVars.recentCompletionMinutes or 10) * 60

    for _, historyEntry in ipairs(self.savedVars.eventHistory) do
        local completedAtS = historyEntry.completedAtS or 0

        if completedAtS > 0 and now - completedAtS <= recentWindowS and self:IsEventTracked(historyEntry) then
            table.insert(recentCompletions, historyEntry)
        end
    end

    table.sort(recentCompletions, function(left, right)
        return (left.completedAtS or 0) > (right.completedAtS or 0)
    end)

    return recentCompletions
end

function ADT:GetEventDisplayName(eventData)
    if eventData.isMovingRoute then
        local routeName = self:FormatMovingRouteName(eventData)
        if routeName and routeName ~= "Moving World Event" then
            return routeName
        end
    end

    if eventData.eventName and not IsGenericEventName(eventData.eventName) then
        return eventData.eventName
    end

    if eventData.stepName and not IsGenericEventName(eventData.stepName) then
        return eventData.stepName
    end

    if eventData.poiName and not IsGenericEventName(eventData.poiName) then
        return eventData.poiName
    end

    return "World Event"
end

function ADT:FormatTrackedEventAge(totalSeconds)
    totalSeconds = math.max(0, math.floor(totalSeconds or 0))

    if totalSeconds < 60 then
        return "just now"
    end

    local minutes = math.floor(totalSeconds / 60)

    if minutes < 60 then
        return string.format("%dm ago", minutes)
    end

    local hours = math.floor(minutes / 60)
    local remainingMinutes = minutes % 60

    if hours < 24 then
        if remainingMinutes > 0 then
            return string.format("%dh %dm ago", hours, remainingMinutes)
        end

        return string.format("%dh ago", hours)
    end

    local days = math.floor(hours / 24)
    local remainingHours = hours % 24

    if remainingHours > 0 then
        return string.format("%dd %dh ago", days, remainingHours)
    end

    return string.format("%dd ago", days)
end

function ADT:FormatTrackedEventOverview(overviewEntry, now)
    local eventData = overviewEntry.event
    local candidate = overviewEntry.candidate
    local zoneName = eventData.zoneName or "Unknown Zone"
    local eventName = self:GetEventDisplayName(eventData)
    local completionCount = eventData.completionCount or 0
    local observationCount = eventData.observationCount or 0
    local lastObservedS = eventData.lastObservedS or 0
    local lastSeenText

    if lastObservedS > 0 then
        lastSeenText = string.format("Seen %s", self:FormatTrackedEventAge(now - lastObservedS))
    else
        lastSeenText = "Not observed yet"
    end

    if not self.savedVars.showNextEventSuggestion then
        return string.format("%s — %s — %s (%d obs)", zoneName, eventName, lastSeenText, observationCount)
    end

    local status, detail = self:GetPredictionStatus(candidate, now)

    if status == "Not Enough Data" then
        return string.format(
            "%s — %s — %s — Not Enough Data %d/%d (%d obs)",
            zoneName,
            eventName,
            lastSeenText,
            math.min(completionCount, MIN_PREDICTION_COMPLETIONS),
            MIN_PREDICTION_COMPLETIONS,
            observationCount
        )
    end

    if status == "Needs Fresh Data" then
        return string.format("%s — %s — %s — Needs Fresh Data (%d obs)", zoneName, eventName, lastSeenText, observationCount)
    end

    local confidence = candidate and candidate.confidence or 0

    if detail then
        return string.format("%s — %s — %s — %s %s (%d%%, %d obs)", zoneName, eventName, lastSeenText, status, detail, confidence, observationCount)
    end

    return string.format("%s — %s — %s — %s (%d%%, %d obs)", zoneName, eventName, lastSeenText, status, confidence, observationCount)
end

function ADT:HideRows(startIndex)
    for index = startIndex or 1, self.maxRows do
        self.rows[index]:SetHidden(true)
        self.rows[index]:SetText("")
    end
end

function ADT:ShowStatusRow(text)
    self.rows[1]:SetText(text)
    self.rows[1]:SetHidden(false)
    self:HideRows(2)
    self.panel:SetHeight(math.max(self.savedVars.panelHeight, UI.defaultHeight))
    self.panel:SetHidden(false)
end

function ADT:ShowPredictionCandidates(rankedCandidates)
    local candidateCount = math.min(#rankedCandidates, self.maxRows - 1)

    if candidateCount <= 0 then
        return
    end

    self.rows[1]:SetText("NEXT EVENT ESTIMATES")
    self.rows[1]:SetHidden(false)

    for index = 1, candidateCount do
        local rankedCandidate = rankedCandidates[index]
        local candidate = rankedCandidate.candidate
        local zoneName = candidate.zoneName or "Unknown Zone"
        local eventName = self:GetEventDisplayName(candidate)
        local status, detail = self:GetPredictionStatus(candidate, GetTimeStamp())
        local statusText = detail and string.format("%s %s", status, detail) or status
        local confidence = candidate.confidence or 0
        local rowIndex = index + 1

        self.rows[rowIndex]:SetText(string.format("%d. %s — %s — %s (%d%%)", index, zoneName, eventName, statusText, confidence))
        self.rows[rowIndex]:SetHidden(false)
    end

    self:HideRows(candidateCount + 2)
    self.panel:SetHeight(math.max(self.savedVars.panelHeight, UI.contentPadding + ((candidateCount + 1) * UI.rowHeight)))
    self.panel:SetHidden(false)
end

function ADT:FormatRecommendationRow(rankedCandidate, rank, now)
    local candidate = rankedCandidate.candidate
    local zoneName = candidate.zoneName or "Unknown Zone"
    local eventName = self:GetEventDisplayName(candidate)
    local status, detail = self:GetPredictionStatus(candidate, now)
    local timingText = status
    local confidence = candidate.confidence or 0
    local prefix

    if detail then
        if status == "Overdue" then
            timingText = string.format("Overdue by %s", detail)
        else
            timingText = string.format("%s %s", status, detail)
        end
    end

    if rank == 1 then
        prefix = "GO"
    else
        prefix = string.format("ALT %d", rank - 1)
    end

    return string.format("%s: %s — %s — %s (%d%%)", prefix, zoneName, eventName, timingText, confidence)
end

function ADT:AddRecommendationSection(now, rowIndex, displayedEventKeys)
    if not self.savedVars.showNextEventSuggestion or rowIndex > self.maxRows then
        return rowIndex, false
    end

    local recommendationLimit = math.max(
        1,
        math.min(MAX_DISPLAYED_PREDICTIONS, self.savedVars.maxPredictionSuggestions or DEFAULT_RECOMMENDATION_CHOICES)
    )
    local rankedCandidates = self:GetRankedPredictionCandidates(now, recommendationLimit)

    self.rows[rowIndex]:SetText("WHERE TO GO NEXT (ESTIMATE)")
    self.rows[rowIndex]:SetHidden(false)
    rowIndex = rowIndex + 1

    if #rankedCandidates == 0 then
        if rowIndex <= self.maxRows then
            self.rows[rowIndex]:SetText("No reliable recommendation yet — keep observing")
            self.rows[rowIndex]:SetHidden(false)
            rowIndex = rowIndex + 1
        end

        return rowIndex, false
    end

    for rank, rankedCandidate in ipairs(rankedCandidates) do
        if rowIndex > self.maxRows then
            break
        end

        self.rows[rowIndex]:SetText(self:FormatRecommendationRow(rankedCandidate, rank, now))
        self.rows[rowIndex]:SetHidden(false)
        displayedEventKeys[rankedCandidate.candidate.eventKey] = true
        rowIndex = rowIndex + 1
    end

    return rowIndex, true
end

function ADT:RefreshDisplay()
    local now = GetTimeStamp()

    if self:ShouldHideForMenu(now) then
        self:HideTrackerForMenu()
        return
    end

    if now - (self.lastPredictionRefreshS or 0) >= PREDICTION_REFRESH_INTERVAL_S then
        self:RefreshPredictionCandidates()
    end

    local visibleEvents = self:BuildVisibleEvents()
    local recentCompletions = self:BuildRecentCompletions(now)
    local displayedEventKeys = {}
    local rowIndex = 1

    local function AddHeader(headerText, itemCount)
        if itemCount <= 0 or rowIndex >= self.maxRows then
            return false
        end

        self.rows[rowIndex]:SetText(headerText)
        self.rows[rowIndex]:SetHidden(false)
        rowIndex = rowIndex + 1
        return true
    end

    if self:GetTrackedEventCount() > 0 then
        rowIndex = self:AddRecommendationSection(now, rowIndex, displayedEventKeys)
    end

    if #visibleEvents > 0 then
        AddHeader("ACTIVE", #visibleEvents)

        for _, eventData in ipairs(visibleEvents) do
            if rowIndex > self.maxRows then
                break
            end

            local eventName = self:GetEventDisplayName(eventData)
            local statusText = "Active"
            local eventKey = self:GetTrackedSelectionKey(eventData)

            if eventData.expireTimeS and eventData.expireTimeS > now then
                statusText = string.format("%s remaining", FormatRemaining(eventData.expireTimeS - now))
            end

            self.rows[rowIndex]:SetText(string.format("%s — %s — %s", eventData.zoneName, eventName, statusText))
            self.rows[rowIndex]:SetHidden(false)
            displayedEventKeys[eventKey] = true
            rowIndex = rowIndex + 1
        end
    end

    local undisplayedCompletions = {}
    for _, historyEntry in ipairs(recentCompletions) do
        local eventKey = self:GetEventDatabaseKey(historyEntry)
        if not displayedEventKeys[eventKey] then
            table.insert(undisplayedCompletions, historyEntry)
        end
    end

    if #undisplayedCompletions > 0 and rowIndex <= self.maxRows then
        AddHeader("RECENTLY COMPLETED", #undisplayedCompletions)

        for _, historyEntry in ipairs(undisplayedCompletions) do
            if rowIndex > self.maxRows then
                break
            end

            local eventName = self:GetEventDisplayName(historyEntry)
            local ageText = FormatCompletedAge(now - (historyEntry.completedAtS or now))
            local eventKey = self:GetEventDatabaseKey(historyEntry)

            self.rows[rowIndex]:SetText(string.format("%s — %s — Completed %s", historyEntry.zoneName or "Unknown Zone", eventName, ageText))
            self.rows[rowIndex]:SetHidden(false)
            displayedEventKeys[eventKey] = true
            rowIndex = rowIndex + 1
        end
    end

    local trackedOverview = self:BuildTrackedEventOverview(now, displayedEventKeys)

    if #trackedOverview > 0 and rowIndex <= self.maxRows then
        AddHeader("TRACKED EVENTS", #trackedOverview)

        for _, overviewEntry in ipairs(trackedOverview) do
            if rowIndex > self.maxRows then
                break
            end

            self.rows[rowIndex]:SetText(self:FormatTrackedEventOverview(overviewEntry, now))
            self.rows[rowIndex]:SetHidden(false)
            displayedEventKeys[overviewEntry.event.eventKey] = true
            rowIndex = rowIndex + 1
        end
    end

    local visibleCount = rowIndex - 1

    if visibleCount > 0 then
        self:HideRows(rowIndex)
        self.panel:SetHeight(math.max(self.savedVars.panelHeight, UI.contentPadding + (visibleCount * UI.rowHeight)))
        self.panel:SetHidden(false)
        return
    end

    if now < (self.previewUntilS or 0) then
        self:ShowStatusRow("GO: Auridon — Sample Event — Estimated in 18m ±4m (65%)")
        return
    end

    local learnedEvents = self:GetLearnedEventEntries()
    local trackedEventCount = self:GetTrackedEventCount()

    if #learnedEvents > 0 and trackedEventCount == 0 then
        self:ShowStatusRow("No events selected — choose learned events in Add-On Settings")
        return
    end

    if now < self.loadedMessageUntilS then
        local currentZone = CleanName(GetUnitZone("player"), "current zone")
        local learnedZoneCount = self:GetLearnedZoneCount()

        if learnedZoneCount == 1 then
            self:ShowStatusRow(string.format("Loaded — 1 zone learned; watching %s", currentZone))
        elseif learnedZoneCount > 1 then
            self:ShowStatusRow(string.format("Loaded — %d zones learned; watching %s", learnedZoneCount, currentZone))
        else
            self:ShowStatusRow(string.format("Loaded — watching %s for new event signals", currentZone))
        end
    else
        self:HideRows(1)
        self.panel:SetHidden(true)
    end
end

function ADT:RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_WORLD_EVENTS_INITIALIZED, function()
        -- Do not enumerate the world-event list here. It can contain unrelated
        -- world-event systems and was the source of the stale 0.0.3 popup.
        self:ClearEvents()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_WORLD_EVENT_ACTIVATED, function(_, worldEventInstanceId)
        self:TrackActivatedEvent(worldEventInstanceId)
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_WORLD_EVENT_DEACTIVATED, function(_, worldEventInstanceId)
        self:CompleteEvent(worldEventInstanceId)
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_WORLD_EVENT_ACTIVE_LOCATION_CHANGED, function(_, worldEventInstanceId, oldWorldEventLocationId, newWorldEventLocationId)
        if newWorldEventLocationId == 0 then
            self:CompleteEvent(worldEventInstanceId)
        else
            local eventData = self.activeEvents[worldEventInstanceId]
            if eventData and oldWorldEventLocationId and oldWorldEventLocationId ~= 0 then
                self:MarkEventAsMoving(eventData)
            end
            self:RefreshTrackedEvent(worldEventInstanceId, true)
        end
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_WORLD_EVENT_STEP_CHANGED, function(_, worldEventInstanceId, newStepDefId)
        if newStepDefId == 0 then
            self:CompleteEvent(worldEventInstanceId)
        else
            self:RefreshTrackedEvent(worldEventInstanceId, false, newStepDefId)
        end
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_WORLD_EVENT_STEP_PROGRESS_CHANGED, function(_, worldEventInstanceId, stepDefId)
        self:RefreshTrackedEvent(worldEventInstanceId, false, stepDefId)
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_WORLD_EVENT_PARTICIPATION_BEGIN, function(_, worldEventInstanceId, stepDefId)
        self:RefreshTrackedEvent(worldEventInstanceId, true, stepDefId)
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_WORLD_EVENT_PARTICIPATION_END, function(_, worldEventInstanceId)
        self:RefreshTrackedEvent(worldEventInstanceId, false)
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
        self:ClearEvents()
        self.loadedMessageUntilS = GetTimeStamp() + 8
        self:RefreshTrackingSettings()
        self:RefreshDisplay()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_DEACTIVATED, function()
        self:RequestSavedVariablesSave()
    end)

    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "Update", 500, function()
        self:RefreshDisplay()
    end)
end

function ADT:Initialize()
    self.savedVars = ZO_SavedVars:NewAccountWide(SAVED_VARIABLES_NAME, SAVED_VARIABLES_VERSION, nil, self.defaults)
    self:EnsureSavedVariableStructure()
    self:RefreshPredictionCandidates()
    self.previewUntilS = 0
    self.settings = nil
    self.trackingSettingKeys = {}
    self.trackingResetSettingKeys = {}
    self.refreshingTrackingSettings = false
    self:CreateUI()
    self:CreateSettings()
    self:RegisterMenuVisibility()
    self:RegisterEvents()
    self.loadedMessageUntilS = GetTimeStamp() + 8
    self:RefreshDisplay()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    ADT:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
