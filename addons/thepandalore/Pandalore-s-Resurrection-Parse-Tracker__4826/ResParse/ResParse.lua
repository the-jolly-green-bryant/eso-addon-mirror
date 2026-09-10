ResParse = ResParse or {}
local RP = ResParse

RP.name = "ResParse"
RP.version = "0.3.0"
RP.savedVariableName = "ResParseSavedVariables"
RP.schemaVersion = 1
RP.scoreModelVersion = 5
RP.debugEnabled = false
RP.debugLog = RP.debugLog or {}
RP.maxDebugLines = 100
RP.rows = RP.rows or {}
RP.windowWidth = 290
RP.rowHeight = 23
RP.baseWindowHeight = 48
RP.mainFileLoaded = true
RP.initError = nil
RP.wasGrouped = nil
RP.settingsPanel = nil
RP.hudFragment = nil

-- LibGroupBroadcast registration. These IDs must match the values reserved on
-- https://wiki.esoui.com/LibGroupBroadcast_IDs before public release.
RP.lgbCustomEventId = 4
RP.lgbProtocolId = 340
RP.lgbCustomEventName = "ResParseCompletedResurrection"
RP.lgbProtocolName = "ResParseScoresheet"
RP.lgbHandler = nil
RP.lgbProtocol = nil
RP.fireCompletedResurrectionEvent = nil
RP.lgbReady = false
RP.syncRequestPending = false
RP.ownStateBroadcastPending = false
RP.groupUpdatePending = false
RP.groupUpdateDelayMs = 250

local defaults = {
    tally = {},
    scoreModelVersion = 0,
    window = {
        hidden = false,
        point = CENTER,
        relativePoint = CENTER,
        x = 0,
        y = 0,
    },
    debugEnabled = false,
    backgroundOpacity = 86,
    windowWidth = 290,
}

local function IsNonEmptyString(value)
    return type(value) == "string" and value ~= ""
end

local function SafeLower(value)
    if not IsNonEmptyString(value) then
        return ""
    end
    return string.lower(value)
end

local function NormalizeDisplayName(value)
    if not IsNonEmptyString(value) then
        return ""
    end
    -- Display names are normally decorated with '@'. Compare the stable
    -- account portion so either decorated or undecorated event data matches.
    return SafeLower((string.gsub(value, "^@", "")))
end

local function NormalizeCharacterName(value)
    if not IsNonEmptyString(value) then
        return ""
    end

    -- ESO event character names can include grammar suffixes such as ^Mx/^Fx.
    -- zo_strformat resolves those suffixes to the same visible name returned by
    -- GetUnitName("player"), which makes self-target comparisons reliable.
    if zo_strformat then
        local ok, formatted = pcall(zo_strformat, "<<1>>", value)
        if ok and IsNonEmptyString(formatted) then
            value = formatted
        end
    end

    return SafeLower(value)
end

local function PrintChat(message)
    local text = "|c7FD7FFResParse|r: " .. tostring(message)
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        CHAT_SYSTEM:AddMessage(text)
    elseif d then
        d(text)
    end
end


function RP:SafeCall(label, callback)
    local ok, result = pcall(callback)
    if not ok then
        self:RecordDebug("ERROR " .. tostring(label) .. ": " .. tostring(result), true)
        return false, result
    end
    return true, result
end

function RP:SafeEventCall(label, handler, ...)
    local ok, err = pcall(handler, ...)
    if not ok then
        self:RecordDebug("ERROR " .. tostring(label) .. ": " .. tostring(err), true)
        return false
    end
    return true
end

function RP:RecordDebug(message, force)
    -- Internal diagnostics are never exposed through the release slash-command
    -- surface. Forced entries are retained only as bounded internal state.
    if not self.debugEnabled and force ~= true then
        return
    end

    local text = tostring(message)
    self.debugLog[#self.debugLog + 1] = text
    while #self.debugLog > self.maxDebugLines do
        table.remove(self.debugLog, 1)
    end
end

function RP:CreateUI()
    if self.window then
        return
    end

    local wm = WINDOW_MANAGER
    local window = wm:CreateTopLevelWindow("ResParseWindow")
    window:SetDimensions(self.windowWidth, self.baseWindowHeight)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)

    local bg = wm:CreateControl("ResParseWindowBG", window, CT_BACKDROP)
    bg:SetAnchorFill(window)
    bg:SetCenterColor(0.03, 0.03, 0.03, self:GetBackgroundAlpha())
    bg:SetEdgeColor(0, 0, 0, 0)
    bg:SetMouseEnabled(false)

    -- Dedicated drag surface. Dynamic child controls can consume hit testing on a
    -- movable TopLevelControl, so do not rely on dragging the window body itself.
    local dragSurface = wm:CreateControl("ResParseWindowDragSurface", window, CT_CONTROL)
    dragSurface:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    dragSurface:SetDimensions(self.windowWidth, 32)
    dragSurface:SetMouseEnabled(true)

    local title = wm:CreateControl("ResParseWindowTitle", dragSurface, CT_LABEL)
    title:SetFont("ZoFontGameBold")
    title:SetText("ResParse")
    title:SetAnchor(LEFT, dragSurface, LEFT, 10, 0)
    title:SetMouseEnabled(false)

    dragSurface:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self.dragging = true
            window:StartMoving()
            if self.debugEnabled then
                self:RecordDebug("DRAG START")
            end
        end
    end)

    local function StopDragging()
        if not self.dragging then
            return
        end
        self.dragging = false
        window:StopMovingOrResizing()
        self:SaveWindowPosition()
        if self.debugEnabled then
            self:RecordDebug(string.format("DRAG STOP x=%.0f y=%.0f", window:GetLeft() or 0, window:GetTop() or 0))
        end
    end

    dragSurface:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            StopDragging()
        end
    end)
    window:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            StopDragging()
        end
    end)


    local rows = wm:CreateControl("ResParseWindowRows", window, CT_CONTROL)
    rows:SetAnchor(TOPLEFT, window, TOPLEFT, 10, 33)
    rows:SetAnchor(TOPRIGHT, window, TOPRIGHT, -10, 33)
    rows:SetMouseEnabled(false)

    window:SetHandler("OnMoveStop", function()
        self.dragging = false
        self:SaveWindowPosition()
    end)

    -- Scope the scoreboard to ESO's HUD scenes.  Native menus replace these
    -- scenes, so the fragment automatically hides ResParse while inventory,
    -- map, settings, crafting, dialogs, etc. are on screen.
    if ZO_HUDFadeSceneFragment and HUD_SCENE and HUD_UI_SCENE then
        self.hudFragment = ZO_HUDFadeSceneFragment:New(window, nil, 0)
        HUD_SCENE:AddFragment(self.hudFragment)
        HUD_UI_SCENE:AddFragment(self.hudFragment)
        self.hudFragment:RegisterCallback("StateChange", function()
            if zo_callLater then
                zo_callLater(function() self:RefreshWindowVisibility() end, 0)
            else
                self:RefreshWindowVisibility()
            end
        end)
    end

    self.window = window
    self.bg = bg
    self.dragSurface = dragSurface
    self.title = title
    self.rowsControl = rows
end

function RP:NormalizeSavedVariables()
    self.saved = ZO_SavedVars:NewAccountWide(self.savedVariableName, self.schemaVersion, nil, defaults)

    if type(self.saved.tally) ~= "table" then
        self.saved.tally = {}
    end

    -- 0.3.0 scores successful resurrection results directly, with one point per
    -- successfully resurrected target. Duration/channel timing is not part of
    -- the score model. Never carry scores from an older score-model revision;
    -- retain all unrelated UI/settings state.
    if tonumber(self.saved.scoreModelVersion) ~= self.scoreModelVersion then
        self.saved.tally = {}
        self.saved.scoreModelVersion = self.scoreModelVersion
    end
    if type(self.saved.window) ~= "table" then
        self.saved.window = {}
    end

    local window = self.saved.window

    -- Older 0.1.5 development builds saved the first return value from
    -- GetAnchor() (isValidAnchor) as window.point.  A boolean here will make
    -- SetAnchor() throw and abort all subsequent initialization.  Treat any
    -- malformed anchor tuple as disposable UI state and reset it safely.
    local malformedAnchor =
        type(window.point) ~= "number" or
        type(window.relativePoint) ~= "number" or
        type(window.x) ~= "number" or
        type(window.y) ~= "number"

    if malformedAnchor then
        window.point = CENTER
        window.relativePoint = CENTER
        window.x = 0
        window.y = 0
    end

    if type(window.hidden) ~= "boolean" then window.hidden = false end
    if type(self.saved.debugEnabled) ~= "boolean" then self.saved.debugEnabled = false end
    if type(self.saved.backgroundOpacity) ~= "number" then self.saved.backgroundOpacity = defaults.backgroundOpacity end
    self.saved.backgroundOpacity = math.max(0, math.min(100, self.saved.backgroundOpacity))

    if type(self.saved.windowWidth) ~= "number" then self.saved.windowWidth = defaults.windowWidth end
    self.saved.windowWidth = math.max(200, math.min(600, self.saved.windowWidth))
    self.windowWidth = self.saved.windowWidth

    self.debugEnabled = self.saved.debugEnabled == true
end

function RP:GetBackgroundAlpha()
    local value = self.saved and tonumber(self.saved.backgroundOpacity) or defaults.backgroundOpacity
    value = math.max(0, math.min(100, value or defaults.backgroundOpacity))
    return value / 100
end

function RP:ApplyBackgroundOpacity()
    if self.bg then
        self.bg:SetCenterColor(0.03, 0.03, 0.03, self:GetBackgroundAlpha())
    end
end

function RP:ApplyWindowWidth()
    local width = self.saved and tonumber(self.saved.windowWidth) or defaults.windowWidth
    width = math.max(200, math.min(600, width or defaults.windowWidth))
    self.windowWidth = width

    if self.dragSurface then
        self.dragSurface:SetDimensions(width, 32)
    end

    for _, row in ipairs(self.rows or {}) do
        row:SetWidth(width - 20)
    end

    self:UpdateUI()
end

function RP:RegisterSettings()
    local LAM = LibAddonMenu2
    if not LAM then
        self:RecordDebug("LibAddonMenu-2.0 unavailable", true)
        return
    end

    local panelName = "ResParseSettingsPanel"
    self.settingsPanel = LAM:RegisterAddonPanel(panelName, {
        type = "panel",
        name = "ResParse",
        displayName = "ResParse",
        author = "thepandalore",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    })

    LAM:RegisterOptionControls(panelName, {
        {
            type = "checkbox",
            name = "Show ResParse",
            tooltip = "Show or hide the ResParse window while grouped. ResParse remains hidden while ungrouped.",
            getFunc = function()
                return not (self.saved.window.hidden == true)
            end,
            setFunc = function(value)
                self.saved.window.hidden = value ~= true
                self:RefreshWindowVisibility()
            end,
            default = true,
            width = "full",
        },
        {
            type = "slider",
            name = "Background Opacity",
            tooltip = "Adjust the opacity of the ResParse background.",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function()
                return self.saved.backgroundOpacity
            end,
            setFunc = function(value)
                self.saved.backgroundOpacity = math.max(0, math.min(100, tonumber(value) or defaults.backgroundOpacity))
                self:ApplyBackgroundOpacity()
            end,
            default = defaults.backgroundOpacity,
            width = "full",
        },
        {
            type = "slider",
            name = "Window Width",
            tooltip = "Adjust the width of the ResParse scoreboard.",
            min = 200,
            max = 600,
            step = 10,
            getFunc = function()
                return self.saved.windowWidth
            end,
            setFunc = function(value)
                self.saved.windowWidth = math.max(200, math.min(600, tonumber(value) or defaults.windowWidth))
                self:ApplyWindowWidth()
            end,
            default = defaults.windowWidth,
            width = "full",
        },
    })
end

function RP:SaveWindowPosition()
    if not self.saved or not self.window then
        return
    end

    -- Persist absolute screen coordinates instead of the GetAnchor() tuple.
    -- This avoids stale/invalid relative anchor data and is the standard
    -- pattern for movable ESO top-level controls.
    local x = self.window:GetLeft()
    local y = self.window:GetTop()
    if type(x) ~= "number" or type(y) ~= "number" then
        self:RecordDebug("WINDOW POSITION not saved: invalid coordinates", true)
        return
    end

    self.saved.window.point = TOPLEFT
    self.saved.window.relativePoint = TOPLEFT
    self.saved.window.x = x
    self.saved.window.y = y
end

function RP:RestoreWindowPosition()
    if not self.saved or not self.window then
        return
    end

    local settings = self.saved.window
    local point = settings.point
    local relativePoint = settings.relativePoint
    local x = settings.x
    local y = settings.y

    if type(point) ~= "number" or type(relativePoint) ~= "number" or
       type(x) ~= "number" or type(y) ~= "number" then
        point = CENTER
        relativePoint = CENTER
        x = 0
        y = 0
    end

    self.window:ClearAnchors()
    local ok, err = pcall(function()
        self.window:SetAnchor(point, GuiRoot, relativePoint, x, y)
    end)

    if not ok then
        -- Saved UI position must never prevent the scorekeeper from loading.
        self.window:ClearAnchors()
        self.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        settings.point = CENTER
        settings.relativePoint = CENTER
        settings.x = 0
        settings.y = 0
        self:RecordDebug("WINDOW POSITION reset after SetAnchor error: " .. tostring(err), true)
    end

    self:RefreshWindowVisibility()
end

function RP:IsHUDSceneVisible()
    if not SCENE_MANAGER or type(SCENE_MANAGER.IsShowing) ~= "function" then
        -- Fail open if scene state is unavailable; the HUD fragment still
        -- provides a second layer of native-menu visibility control.
        return true
    end

    return SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui")
end

function RP:RefreshWindowVisibility()
    if not self.window then
        return
    end

    local manuallyHidden = self.saved and self.saved.window and self.saved.window.hidden == true
    local grouped = IsUnitGrouped("player") == true
    local hudVisible = self:IsHUDSceneVisible()
    local shouldHide = (not grouped) or manuallyHidden or (not hudVisible)
    self.window:SetHidden(shouldHide)
end

function RP:SetWindowHidden(hidden)
    if self.saved then
        self.saved.window.hidden = hidden == true
    end
    self:RefreshWindowVisibility()
end

function RP:AcquireRow(index)
    if self.rows[index] then
        return self.rows[index]
    end

    local row = WINDOW_MANAGER:CreateControl("ResParseRow" .. tostring(index), self.rowsControl, CT_CONTROL)
    row:SetDimensions(self.windowWidth - 20, self.rowHeight)
    row:SetMouseEnabled(false)

    local nameLabel = WINDOW_MANAGER:CreateControl(row:GetName() .. "Name", row, CT_LABEL)
    nameLabel:SetFont("ZoFontGame")
    nameLabel:SetAnchor(LEFT, row, LEFT, 0, 0)
    nameLabel:SetMouseEnabled(false)

    local scoreLabel = WINDOW_MANAGER:CreateControl(row:GetName() .. "Score", row, CT_LABEL)
    scoreLabel:SetFont("ZoFontGameBold")
    scoreLabel:SetAnchor(RIGHT, row, RIGHT, 0, 0)
    scoreLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    scoreLabel:SetMouseEnabled(false)

    row.nameLabel = nameLabel
    row.scoreLabel = scoreLabel
    self.rows[index] = row
    return row
end

function RP:UpdateTitle()
    if self.title then
        self.title:SetText("ResParse")
    end
end

function RP:GetSortedScoresheetEntries()
    local entries = {}
    if self.saved and type(self.saved.tally) == "table" then
        for displayName, count in pairs(self.saved.tally) do
            if type(count) == "number" and count > 0 then
                entries[#entries + 1] = { displayName = displayName, count = count }
            end
        end
    end

    table.sort(entries, function(a, b)
        if a.count ~= b.count then
            return a.count > b.count
        end
        return SafeLower(a.displayName) < SafeLower(b.displayName)
    end)

    return entries
end

function RP:UpdateUI()
    if not self.window then
        return
    end

    local entries = self:GetSortedScoresheetEntries()

    for index, entry in ipairs(entries) do
        local row = self:AcquireRow(index)
        row:ClearAnchors()
        row:SetAnchor(TOPLEFT, self.rowsControl, TOPLEFT, 0, (index - 1) * self.rowHeight)
        row:SetAnchor(TOPRIGHT, self.rowsControl, TOPRIGHT, 0, (index - 1) * self.rowHeight)
        row.nameLabel:SetText(entry.displayName)
        row.scoreLabel:SetText(tostring(entry.count))
        row:SetHidden(false)
    end

    for index = #entries + 1, #self.rows do
        self.rows[index]:SetHidden(true)
    end

    local height = self.baseWindowHeight + (#entries * self.rowHeight)
    self.window:SetDimensions(self.windowWidth, height)
    self:UpdateTitle()
end

function RP:AddResurrection(displayName, source)
    if not self.saved or type(self.saved.tally) ~= "table" then
        self:RecordDebug("score rejected: saved tally unavailable", true)
        return false
    end
    if not IsNonEmptyString(displayName) then
        self:RecordDebug("score rejected: empty account name via " .. tostring(source), true)
        return false
    end

    self.saved.tally[displayName] = (tonumber(self.saved.tally[displayName]) or 0) + 1
    self:RecordDebug(string.format("SCORE %s = %d via %s", displayName, self.saved.tally[displayName], tostring(source)))
    self:UpdateUI()
    return true
end

function RP:GetLocalResurrectionCount()
    if not self.saved or type(self.saved.tally) ~= "table" then
        return 0
    end
    return math.max(0, math.min(65535, tonumber(self.saved.tally[GetDisplayName()]) or 0))
end

function RP:SendOwnScoresheetState(reason)
    if not self.lgbReady or not self.lgbProtocol or not IsUnitGrouped("player") then
        return false
    end
    if type(self.lgbProtocol.IsEnabled) == "function" and not self.lgbProtocol:IsEnabled() then
        self:RecordDebug("LGB state not sent: ResParseScoresheet disabled")
        return false
    end

    local count = self:GetLocalResurrectionCount()
    local success = self.lgbProtocol:Send({
        requestSync = false,
        resurrectionCount = count,
    })
    self:RecordDebug(string.format("LGB STATE SEND count=%d reason=%s success=%s", count, tostring(reason), tostring(success)))
    return success == true
end

function RP:RequestScoresheetSync(reason)
    if not self.lgbReady or not self.lgbProtocol or not IsUnitGrouped("player") then
        return false
    end
    if type(self.lgbProtocol.IsEnabled) == "function" and not self.lgbProtocol:IsEnabled() then
        self:RecordDebug("LGB sync request not sent: ResParseScoresheet disabled")
        return false
    end

    local success = self.lgbProtocol:Send({
        requestSync = true,
        resurrectionCount = self:GetLocalResurrectionCount(),
    })
    self:RecordDebug(string.format("LGB SYNC REQUEST reason=%s success=%s", tostring(reason), tostring(success)))
    return success == true
end

function RP:ScheduleScoresheetSync(reason, delayMs)
    if not IsUnitGrouped("player") then
        return
    end
    if self.syncRequestPending then
        return
    end
    self.syncRequestPending = true
    local delay = tonumber(delayMs) or 750
    local callback = function()
        self.syncRequestPending = false
        if IsUnitGrouped("player") then
            -- A sync request already carries our current resurrectionCount, so
            -- do not immediately queue a second state message for the same data.
            self:RequestScoresheetSync(reason)
        end
    end
    if zo_callLater then
        zo_callLater(callback, delay)
    else
        callback()
    end
end

function RP:ScheduleOwnStateBroadcast(reason, delayMs)
    if not IsUnitGrouped("player") then
        return
    end
    -- Group events and simultaneous sync requests can arrive in bursts. Collapse
    -- them into one pending state publication instead of queueing one per event.
    if self.ownStateBroadcastPending then
        return
    end
    self.ownStateBroadcastPending = true
    local callback = function()
        self.ownStateBroadcastPending = false
        if IsUnitGrouped("player") then
            self:SendOwnScoresheetState(reason)
        end
    end
    if zo_callLater then
        zo_callLater(callback, tonumber(delayMs) or 250)
    else
        callback()
    end
end

function RP:OnScoresheetData(unitTag, data)
    if not IsUnitGrouped("player") or type(data) ~= "table" then
        return
    end

    local senderDisplayName = IsNonEmptyString(unitTag) and GetUnitDisplayName(unitTag) or nil
    if not IsNonEmptyString(senderDisplayName) then
        self:RecordDebug("LGB RECEIVE rejected: sender account unavailable", true)
        return
    end

    local count = tonumber(data.resurrectionCount)
    if count == nil then
        self:RecordDebug("LGB RECEIVE rejected: missing resurrectionCount", true)
        return
    end
    count = math.max(0, math.min(65535, math.floor(count)))

    if not self.saved or type(self.saved.tally) ~= "table" then
        self:RecordDebug("LGB RECEIVE rejected: saved tally unavailable", true)
        return
    end

    -- Every protocol message, including a sync request, carries the sender's
    -- current authoritative total. Apply it once and rebuild the UI only when
    -- the visible score actually changed.
    local previousCount = tonumber(self.saved.tally[senderDisplayName]) or 0
    if count ~= previousCount then
        if count > 0 then
            self.saved.tally[senderDisplayName] = count
        else
            self.saved.tally[senderDisplayName] = nil
        end
        self:RecordDebug(string.format("LGB STATE RECEIVE %s = %d", senderDisplayName, count))
        self:UpdateUI()
    end

    if data.requestSync == true then
        self:RecordDebug("LGB SYNC REQUEST received from " .. senderDisplayName)
        -- Do not answer every request immediately. Several clients can reload or
        -- join together; coalesce the burst into one state response per client.
        self:ScheduleOwnStateBroadcast("sync-response", 250)
    end
end

function RP:BroadcastCompletedResurrection()
    if not IsUnitGrouped("player") then
        return
    end

    if self.fireCompletedResurrectionEvent and self.lgbHandler then
        local enabled = true
        if type(self.lgbHandler.IsCustomEventEnabled) == "function" then
            enabled = self.lgbHandler:IsCustomEventEnabled(self.lgbCustomEventName)
        end
        if enabled then
            local ok, err = pcall(self.fireCompletedResurrectionEvent)
            if not ok then
                self:RecordDebug("LGB completed-resurrection event failed: " .. tostring(err), true)
            end
        end
    end

    -- The protocol message is authoritative. Receivers set the sender's total
    -- rather than incrementing it, so duplicate/reordered messages cannot
    -- inflate the shared scoresheet.
    self:SendOwnScoresheetState("completed-resurrection")
end

function RP:InitializeGroupBroadcast()
    local LGB = LibGroupBroadcast
    if not LGB then
        self:RecordDebug("LibGroupBroadcast unavailable; synchronized scoring disabled", true)
        return false
    end

    local ok, err = pcall(function()
        self.lgbHandler = LGB:RegisterHandler(self.name)
        self.lgbHandler:SetDisplayName("ResParse")
        self.lgbHandler:SetDescription("Broadcasts confirmed successful player resurrections for distributed resurrection scoring and tracking.")

        self.lgbProtocol = self.lgbHandler:DeclareProtocol(self.lgbProtocolId, self.lgbProtocolName)
        self.lgbProtocol:SetDisplayName("ResParse Scoresheet")
        self.lgbProtocol:SetDescription("Synchronizes each participating player's authoritative successful-resurrection total.")
        self.lgbProtocol:AddField(LGB.CreateFlagField("requestSync", { defaultValue = false }))
        self.lgbProtocol:AddField(LGB.CreateNumericField("resurrectionCount", {
            minValue = 0,
            maxValue = 65535,
            defaultValue = 0,
            trimValues = true,
        }))
        self.lgbProtocol:OnData(function(unitTag, data)
            self:SafeEventCall("LGB Scoresheet", function() self:OnScoresheetData(unitTag, data) end)
        end)

        local finalized = self.lgbProtocol:Finalize({
            isRelevantInCombat = true,
            replaceQueuedMessages = false,
        })
        if finalized ~= true then
            error("ResParseScoresheet protocol failed to finalize")
        end
    end)

    if not ok then
        self.lgbHandler = nil
        self.lgbProtocol = nil
        self.fireCompletedResurrectionEvent = nil
        self.lgbReady = false
        self:RecordDebug("LibGroupBroadcast initialization failed: " .. tostring(err), true)
        return false
    end

    self.lgbReady = true

    -- ResParseScoresheet is the authoritative synchronization path. Keep the
    -- completed-resurrection custom event best-effort so an event-ID problem
    -- cannot take down the scoresheet protocol.
    local eventOk, eventResult = pcall(function()
        return self.lgbHandler:DeclareCustomEvent(
            self.lgbCustomEventId,
            self.lgbCustomEventName,
            { isRelevantInCombat = true }
        )
    end)
    if eventOk then
        self.fireCompletedResurrectionEvent = eventResult
    else
        self.fireCompletedResurrectionEvent = nil
        self:RecordDebug("LGB custom event unavailable: " .. tostring(eventResult), true)
    end

    self:RecordDebug(string.format(
        "LGB READY event=%s[%d] protocol=%s[%d]",
        self.lgbCustomEventName, self.lgbCustomEventId,
        self.lgbProtocolName, self.lgbProtocolId
    ))
    return true
end

function RP:GetGroupMembers()
    local members = {}
    if not IsUnitGrouped("player") then
        return members
    end

    local groupSize = GetGroupSize()
    for index = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(index)
        if unitTag and DoesUnitExist(unitTag) then
            local displayName = GetUnitDisplayName(unitTag)
            if IsNonEmptyString(displayName) then
                members[#members + 1] = {
                    unitTag = unitTag,
                    displayName = displayName,
                }
            end
        end
    end
    return members
end

function RP:ClearSessionState(reason)
    if self.saved then
        self.saved.tally = {}
    end
    self:RecordDebug(tostring(reason or "SESSION RESET"))
    self:UpdateUI()
end

function RP:PruneScoresheetToCurrentGroup()
    if not self.saved or type(self.saved.tally) ~= "table" or not IsUnitGrouped("player") then
        return
    end

    local present = { [GetDisplayName()] = true }
    for _, member in ipairs(self:GetGroupMembers()) do
        present[member.displayName] = true
    end

    local changed = false
    for displayName in pairs(self.saved.tally) do
        if not present[displayName] then
            self.saved.tally[displayName] = nil
            changed = true
        end
    end
    if changed then
        self:RecordDebug("SCORESHEET pruned departed group members")
        self:UpdateUI()
    end
end

function RP:HandleGroupLifecycle()
    local grouped = IsUnitGrouped("player") == true

    if self.wasGrouped == nil then
        self.wasGrouped = grouped
        if not grouped and self.saved and next(self.saved.tally or {}) ~= nil then
            self:ClearSessionState("UNGROUPED AT LOAD: stale resurrection scores cleared")
        elseif grouped then
            -- A grouped reload may retain scores from members who have already
            -- departed. Prune first, then request authoritative current totals.
            self:PruneScoresheetToCurrentGroup()
            self:ScheduleScoresheetSync("grouped-load", 1000)
        end
        self:RefreshWindowVisibility()
        return grouped
    end

    if self.wasGrouped and not grouped then
        self:ClearSessionState("LEFT GROUP: resurrection scores reset")
    elseif (not self.wasGrouped) and grouped then
        self:ClearSessionState("JOINED GROUP: new resurrection session")
        self:PruneScoresheetToCurrentGroup()
        self:ScheduleScoresheetSync("joined-group", 1000)
    elseif grouped then
        -- EVENT_GROUP_UPDATE can be the first reliable indication that a unit
        -- disappeared. Keep the local sheet scoped to the current roster.
        self:PruneScoresheetToCurrentGroup()
    end

    self.wasGrouped = grouped
    self:RefreshWindowVisibility()
    return grouped
end

function RP:IsLocalPlayerResurrectionTarget(targetCharacterName, targetDisplayName)
    local localDisplayName = GetDisplayName and GetDisplayName() or ""
    if NormalizeDisplayName(targetDisplayName) ~= "" and
       NormalizeDisplayName(targetDisplayName) == NormalizeDisplayName(localDisplayName) then
        return true
    end

    local targetCharacter = NormalizeCharacterName(targetCharacterName)
    if targetCharacter == "" then
        return false
    end

    local localCharacter = GetUnitName and NormalizeCharacterName(GetUnitName("player")) or ""
    if localCharacter ~= "" and targetCharacter == localCharacter then
        return true
    end

    -- GetRawUnitName is useful on clients/events that expose the grammar-tagged
    -- character name instead of the formatted character name.
    if GetRawUnitName then
        local rawLocalCharacter = NormalizeCharacterName(GetRawUnitName("player"))
        if rawLocalCharacter ~= "" and targetCharacter == rawLocalCharacter then
            return true
        end
    end

    return false
end

function RP:OnLocalResurrectionResult(targetCharacterName, result, targetDisplayName)
    if not IsUnitGrouped("player") then
        return
    end

    local target = IsNonEmptyString(targetDisplayName) and targetDisplayName or targetCharacterName

    if result ~= RESURRECT_RESULT_SUCCESS then
        self:RecordDebug(string.format(
            "LOCAL REZ RESULT rejected result=%s target=%s",
            tostring(result), tostring(target or "?")
        ))
        return
    end

    -- EVENT_RESURRECT_RESULT is the authoritative success signal. Do not gate
    -- scoring on soul-gem channel duration: resurrection speed is variable and
    -- abilities such as Necromancer Reanimate can successfully resurrect more
    -- than one target from a single activation. Each SUCCESS result is one point.
    local localAccount = GetDisplayName()
    if self:IsLocalPlayerResurrectionTarget(targetCharacterName, targetDisplayName) then
        self:RecordDebug(string.format(
            "LOCAL SELF-RESURRECTION RESULT ignored character=%s display=%s",
            tostring(targetCharacterName or "?"), tostring(targetDisplayName or "?")
        ))
        return
    end

    self:RecordDebug("LOCAL REZ SUCCESS target=" .. tostring(target or "?"))
    if self:AddResurrection(localAccount, "EVENT_RESURRECT_RESULT:SUCCESS") then
        self:BroadcastCompletedResurrection()
    end
end

function RP:ScheduleGroupUpdateProcessing()
    -- EVENT_GROUP_UPDATE can arrive in bursts while ESO is rebuilding group
    -- state. A full roster scan and scoreboard layout on every raw event can
    -- produce severe hitching, especially in trials. Process at most one update
    -- per debounce window instead.
    if self.groupUpdatePending then
        return
    end
    self.groupUpdatePending = true

    local callback = function()
        self.groupUpdatePending = false
        self:HandleGroupLifecycle()
    end

    if zo_callLater then
        zo_callLater(callback, self.groupUpdateDelayMs or 250)
    else
        callback()
    end
end

function RP:RegisterEvents()
    local function Register(label, eventId, handler)
        if eventId == nil then
            self:RecordDebug("event unavailable: " .. tostring(label), true)
            return
        end
        self:SafeCall("register " .. label, function()
            EVENT_MANAGER:RegisterForEvent(self.name .. "_" .. label, eventId, function(...)
                self:SafeEventCall(label, handler, ...)
            end)
        end)
    end

    Register("LocalRezResult", EVENT_RESURRECT_RESULT, function(_, targetCharacterName, result, targetDisplayName)
        self:OnLocalResurrectionResult(targetCharacterName, result, targetDisplayName)
    end)

    Register("GroupJoined", EVENT_GROUP_MEMBER_JOINED, function()
        local wasGrouped = self.wasGrouped
        self:HandleGroupLifecycle()
        if wasGrouped == true and IsUnitGrouped("player") then
            -- Existing members advertise only their own authoritative total.
            -- The joining client issues the sync request, avoiding an N^2
            -- request storm when a member enters a populated group.
            self:ScheduleOwnStateBroadcast("member-joined", 750)
        end
    end)

    Register("GroupLeft", EVENT_GROUP_MEMBER_LEFT, function()
        self:HandleGroupLifecycle()
        if IsUnitGrouped("player") then
            if zo_callLater then
                zo_callLater(function() self:PruneScoresheetToCurrentGroup() end, 250)
            else
                self:PruneScoresheetToCurrentGroup()
            end
        end
    end)

    if EVENT_GROUP_UPDATE ~= nil then
        Register("GroupUpdate", EVENT_GROUP_UPDATE, function()
            self:ScheduleGroupUpdateProcessing()
        end)
    end
end

function RP:PrintScoresheet()
    local entries = self:GetSortedScoresheetEntries()

    if #entries == 0 then
        PrintChat("scoresheet: no successful resurrections")
        return
    end

    PrintChat("scoresheet")
    for _, entry in ipairs(entries) do
        PrintChat(string.format("%s: %d", entry.displayName, entry.count))
    end
end

function RP:SlashCommand(text)
    local command = type(text) == "string" and text or ""
    command = string.lower(command)
    if zo_strtrim then
        command = zo_strtrim(command)
    else
        command = string.match(command, "^%s*(.-)%s*$") or ""
    end

    -- Release command surface: /resparse sync is the only /resparse option.
    -- Scoresheet chat output is provided separately by /resparsers.
    if command == "sync" then
        self:RequestScoresheetSync("manual")
    end
end

function RP:Initialize()
    -- Tracking must not depend on the UI. Normalize persistent state, initialize
    -- synchronization, and register the local successful-resurrection result
    -- listener before best-effort UI creation/restoration.
    self:NormalizeSavedVariables()
    self:SafeCall("RegisterSettings", function() self:RegisterSettings() end)
    self:SafeCall("InitializeGroupBroadcast", function() self:InitializeGroupBroadcast() end)
    self:RegisterEvents()
    self:SafeCall("InitialGroupLifecycle", function() self:HandleGroupLifecycle() end)
    self.initialized = true
    self.initError = nil

    local uiOk = self:SafeCall("CreateUI", function()
        self:CreateUI()
    end)

    if uiOk and self.window then
        self:SafeCall("RestoreWindowPosition", function()
            self:RestoreWindowPosition()
        end)
        self:SafeCall("InitialUpdateUI", function()
            self:ApplyWindowWidth()
            self:ApplyBackgroundOpacity()
            self:UpdateUI()
            self:RefreshWindowVisibility()
        end)
    end

    self:RecordDebug("INITIALIZED ResParse v" .. self.version .. " API=" .. tostring(GetAPIVersion()), true)
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= RP.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(RP.name .. "_MainLoad", EVENT_ADD_ON_LOADED)

    local ok, err = pcall(function()
        RP:Initialize()
    end)
    if not ok then
        RP.initialized = false
        RP.initError = tostring(err)
        if RP.BootPrint then
            RP.BootPrint("MAIN INITIALIZATION FAILED: " .. tostring(err))
        else
            RP.debugLog[#RP.debugLog + 1] = "MAIN INITIALIZATION FAILED: " .. tostring(err)
        end
    end
end

EVENT_MANAGER:RegisterForEvent(RP.name .. "_MainLoad", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
