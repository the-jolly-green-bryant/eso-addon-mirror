local SRC = SupportRotationCallouts
SRC.Diagnostics = SRC.Diagnostics or {}
local Diagnostics = SRC.Diagnostics
local WM = WINDOW_MANAGER

Diagnostics.MAX_STORED_LINES = 60
Diagnostics.MAX_OVERLAY_LINES = 16
Diagnostics.MAX_SESSIONS = 8
Diagnostics.MAX_SESSION_ENTRIES = 500
Diagnostics.VIEWER_PAGE_SIZE = 18
local DEVELOPER_CATEGORIES = {
    RAW_CAST = true,
    RAW_EFFECT = true,
    RAW_DEATH = true,
    DEDUPE = true,
    ULT = true,
    ULT_SPEND = true,
    CORRELATION = true,
}

local function Sanitize(value)
    local text = tostring(value)
    text = string.gsub(text, "\n", " ")
    return text
end

local function EnsureSessionStorage()
    SRC.saved.diagnosticSessions = SRC.saved.diagnosticSessions or {}
    SRC.saved.diagnosticSessionName = SRC.saved.diagnosticSessionName or "Trial Test"
    SRC.saved.selectedDiagnosticSession = SRC.saved.selectedDiagnosticSession or ""
end

function Diagnostics:Initialize()
    -- Preserve any diagnostics recorded by startup publishers before the UI is built.
    self.lines = self.lines or {}
    self.sequence = tonumber(self.sequence) or 0
    self.viewerPage = tonumber(self.viewerPage) or 1
    EnsureSessionStorage()

    local control = WM:CreateTopLevelWindow("SupportRotationCalloutsDiagnostics")
    control:SetDimensions(1040, 390)
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 20, 120)
    control:SetHidden(not SRC.saved.diagnosticOverlay)

    local bg = WM:CreateControl(nil, control, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.78)
    bg:SetEdgeColor(1, 1, 1, 0.25)
    bg:SetEdgeTexture(nil, 2, 2, 2)

    local label = WM:CreateControl(nil, control, CT_LABEL)
    label:SetAnchor(TOPLEFT, control, TOPLEFT, 10, 8)
    label:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -10, -8)
    label:SetFont("$(CHAT_FONT)|17|outline")
    label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetText("Conductor diagnostics")

    self.control = control
    self.label = label
    self:InitializeViewer()
end

function Diagnostics:InitializeViewer()
    local viewer = WM:CreateTopLevelWindow("SupportRotationCalloutsDiagnosticViewer")
    viewer:SetDimensions(1180, 650)
    viewer:SetAnchor(CENTER, GuiRoot, CENTER, 160, 0)
    viewer:SetClampedToScreen(true)
    viewer:SetHidden(true)

    local bg = WM:CreateControl(nil, viewer, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.92)
    bg:SetEdgeColor(1, 1, 1, 0.35)
    bg:SetEdgeTexture(nil, 2, 2, 2)

    local title = WM:CreateControl(nil, viewer, CT_LABEL)
    title:SetAnchor(TOPLEFT, viewer, TOPLEFT, 18, 14)
    title:SetAnchor(TOPRIGHT, viewer, TOPRIGHT, -18, 14)
    title:SetFont("$(BOLD_FONT)|24|outline")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local body = WM:CreateControl(nil, viewer, CT_LABEL)
    body:SetAnchor(TOPLEFT, viewer, TOPLEFT, 20, 58)
    body:SetAnchor(BOTTOMRIGHT, viewer, BOTTOMRIGHT, -20, -46)
    body:SetFont("$(CHAT_FONT)|18|outline")
    body:SetVerticalAlignment(TEXT_ALIGN_TOP)
    body:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    local footer = WM:CreateControl(nil, viewer, CT_LABEL)
    footer:SetAnchor(BOTTOMLEFT, viewer, BOTTOMLEFT, 18, -14)
    footer:SetAnchor(BOTTOMRIGHT, viewer, BOTTOMRIGHT, -18, -14)
    footer:SetFont("$(CHAT_FONT)|18|outline")
    footer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    self.viewer = viewer
    self.viewerTitle = title
    self.viewerBody = body
    self.viewerFooter = footer

    if SCENE_MANAGER and SCENE_MANAGER.RegisterCallback and not self.viewerSceneSafetyRegistered then
        self.viewerSceneSafetyRegistered = true
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
            if newState == SCENE_HIDING and Diagnostics:IsViewerOpen() then
                Diagnostics:CloseActiveViewer()
            end
        end)
    end
end

local function CurrentSceneName()
    if not SCENE_MANAGER or not SCENE_MANAGER.GetCurrentScene then return "" end
    local scene = SCENE_MANAGER:GetCurrentScene()
    if not scene then return "" end
    if scene.GetName then return string.lower(tostring(scene:GetName() or "")) end
    return string.lower(tostring(scene.name or ""))
end

function Diagnostics:IsProtectedViewerSceneActive()
    local name = CurrentSceneName()
    return string.find(name, "mod_browser", 1, true) ~= nil
        or string.find(name, "modbrowser", 1, true) ~= nil
        or string.find(name, "market", 1, true) ~= nil
end

function Diagnostics:GetSettingsPanelIntegration()
    local settings = LibHarvensAddonSettings
    if not settings or not settings.list or not settings.scrollList then return nil end
    if not settings.scrollList.keybindStripDescriptor then return nil end
    return settings
end

function Diagnostics:RefreshSettingsPanelKeybinds(rebuild)
    if not KEYBIND_STRIP or self:IsProtectedViewerSceneActive() then return end
    local settings = self:GetSettingsPanelIntegration()
    if not settings then return end
    local descriptor = settings.scrollList.keybindStripDescriptor

    if rebuild then
        -- The viewer temporarily owns UI_SHORTCUT_NEGATIVE. Rebuild the native
        -- LibHarvens group after removing the viewer group so Circle/Back is
        -- registered again by the settings panel rather than the overlay.
        KEYBIND_STRIP:RemoveKeybindButtonGroup(descriptor)
        KEYBIND_STRIP:AddKeybindButtonGroup(descriptor)
    elseif KEYBIND_STRIP.UpdateKeybindButtonGroup then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(descriptor)
    end
end

function Diagnostics:AcquireSettingsPanel(owner)
    owner = tostring(owner or "viewer")
    self.settingsPanelOwners = self.settingsPanelOwners or {}
    if self.settingsPanelOwners[owner] then return end
    self.settingsPanelOwners[owner] = true

    if self.settingsPanelOwnerCount then
        self.settingsPanelOwnerCount = self.settingsPanelOwnerCount + 1
        return
    end

    local settings = self:GetSettingsPanelIntegration()
    if not settings then return end

    local selectedData = settings.list:GetSelectedData()
    self.settingsPanelOwnerCount = 1
    self.settingsPanelSelectedData = selectedData
    self.settingsPanelTooltipText = selectedData and selectedData.tooltipText or nil
    if selectedData then selectedData.tooltipText = nil end

    -- Modal Conductor windows should look and behave like normal console
    -- addon scenes, not float over the Harvens menu. Temporarily hide the
    -- underlying lists and release Harvens' Circle binding while the modal
    -- owns X/Circle/L2/R2 through the standard keybind strip.
    self.settingsPanelListWasHidden = settings.list.IsHidden and settings.list:IsHidden() or false
    self.settingsPanelScrollWasHidden = settings.scrollList.IsHidden and settings.scrollList:IsHidden() or false
    if settings.list.SetHidden then settings.list:SetHidden(true) end
    if settings.scrollList.SetHidden then settings.scrollList:SetHidden(true) end
    if KEYBIND_STRIP and settings.scrollList.keybindStripDescriptor then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(settings.scrollList.keybindStripDescriptor)
        self.settingsPanelNativeKeybindRemoved = true
    end

    if GAMEPAD_TOOLTIPS and GAMEPAD_LEFT_TOOLTIP then
        GAMEPAD_TOOLTIPS:Reset(GAMEPAD_LEFT_TOOLTIP)
    end
end

function Diagnostics:ReleaseSettingsPanel(owner)
    owner = tostring(owner or "viewer")
    if not self.settingsPanelOwners or not self.settingsPanelOwners[owner] then return end
    self.settingsPanelOwners[owner] = nil

    local count = 0
    for _ in pairs(self.settingsPanelOwners) do count = count + 1 end
    self.settingsPanelOwnerCount = count > 0 and count or nil
    if count > 0 then return end

    if self.settingsPanelSelectedData then
        self.settingsPanelSelectedData.tooltipText = self.settingsPanelTooltipText
    end
    self.settingsPanelSelectedData = nil
    self.settingsPanelTooltipText = nil

    local settings = self:GetSettingsPanelIntegration()
    if settings then
        if settings.list.SetHidden then settings.list:SetHidden(self.settingsPanelListWasHidden == true) end
        if settings.scrollList.SetHidden then settings.scrollList:SetHidden(self.settingsPanelScrollWasHidden == true) end
    end
    self.settingsPanelListWasHidden = nil
    self.settingsPanelScrollWasHidden = nil
    self.settingsPanelNativeKeybindRemoved = nil
    self:RefreshSettingsPanelKeybinds(true)
end

function Diagnostics:IsViewerOpen()
    return self.viewer and not self.viewer:IsHidden()
end

function Diagnostics:GetActiveViewerPageCount()
    if self.developerLines then
        return zo_max(1, math.ceil(#self.developerLines / (self.DEVELOPER_PAGE_SIZE or 22)))
    end
    local session = self:GetSessionById(SRC.saved.selectedDiagnosticSession)
    if session then return zo_max(1, math.ceil(#(session.entries or {}) / self.VIEWER_PAGE_SIZE)) end
    return 1
end

function Diagnostics:GetActiveViewerPage()
    if self.developerLines then return self.developerPage or 1 end
    return self.viewerPage or 1
end

function Diagnostics:BuildViewerKeybinds()
    if self.viewerKeybinds then return end
    self.viewerKeybinds = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        {
            name = "Previous Page",
            keybind = "UI_SHORTCUT_LEFT_TRIGGER",
            callback = function() Diagnostics:ChangeActiveViewerPage(-1) end,
            visible = function() return Diagnostics:IsViewerOpen() and Diagnostics:GetActiveViewerPage() > 1 end,
        },
        {
            name = "Next Page",
            keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
            callback = function() Diagnostics:ChangeActiveViewerPage(1) end,
            visible = function() return Diagnostics:IsViewerOpen() and Diagnostics:GetActiveViewerPage() < Diagnostics:GetActiveViewerPageCount() end,
        },
        {
            name = "Close",
            keybind = "UI_SHORTCUT_NEGATIVE",
            callback = function() Diagnostics:CloseActiveViewer() end,
            visible = function() return Diagnostics:IsViewerOpen() end,
        },
    }
end

function Diagnostics:UpdateViewerKeybinds(show)
    if not KEYBIND_STRIP or self:IsProtectedViewerSceneActive() then return end
    self:BuildViewerKeybinds()
    if show and not self.viewerKeybindsAdded then
        KEYBIND_STRIP:AddKeybindButtonGroup(self.viewerKeybinds)
        self.viewerKeybindsAdded = true
    elseif not show and self.viewerKeybindsAdded then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(self.viewerKeybinds)
        self.viewerKeybindsAdded = false
    elseif show and self.viewerKeybindsAdded and KEYBIND_STRIP.UpdateKeybindButtonGroup then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.viewerKeybinds)
    end
end

function Diagnostics:ActivateViewer()
    if not self.viewer then return end
    self:AcquireSettingsPanel("diagnosticViewer")
    self.viewer:SetHidden(false)
    self:UpdateViewerKeybinds(true)
end

function Diagnostics:ChangeActiveViewerPage(delta)
    if self.developerLines then
        if self.ChangeDeveloperPage then self:ChangeDeveloperPage(delta) end
    else
        self:ChangeViewerPage(delta)
    end
end

function Diagnostics:CloseActiveViewer()
    self.developerLines = nil
    self.developerTitle = nil
    self.developerFooter = nil
    if self.viewer then self.viewer:SetHidden(true) end
    self:UpdateViewerKeybinds(false)
    self:ReleaseSettingsPanel("diagnosticViewer")
end

function Diagnostics:GetMode()
    if SRC.saved.diagnosticMode then return SRC.saved.diagnosticMode end
    if SRC.saved.developerDiagnostics then return "developer" end
    if SRC.saved.diagnostics then return "standard" end
    return "off"
end

function Diagnostics:SetMode(mode)
    mode = mode or "off"
    SRC.saved.diagnosticMode = mode
    SRC.saved.diagnostics = mode ~= "off"
    SRC.saved.developerDiagnostics = mode == "developer"
end

function Diagnostics:ShouldRecord(category)
    local mode = self:GetMode()
    if mode == "off" then return false end
    if DEVELOPER_CATEGORIES[tostring(category)] and mode ~= "developer" then return false end
    return true
end

function Diagnostics:GetActiveSession()
    EnsureSessionStorage()
    local id = SRC.saved.activeDiagnosticSessionId
    if not id or id == "" then return nil end
    for _, session in ipairs(SRC.saved.diagnosticSessions) do
        if session.id == id and not session.endedAt then return session end
    end
    return nil
end

function Diagnostics:StartSession(name)
    EnsureSessionStorage()
    if self:GetActiveSession() then self:EndSession() end

    local timestamp = GetTimeStamp and GetTimeStamp() or math.floor(GetGameTimeMilliseconds() / 1000)
    local session = {
        id = tostring(timestamp) .. "-" .. tostring(math.random(1000, 9999)),
        name = (name and zo_strtrim(name) ~= "") and zo_strtrim(name) or ("Session " .. tostring(timestamp)),
        startedAt = timestamp,
        endedAt = nil,
        entries = {},
    }
    table.insert(SRC.saved.diagnosticSessions, 1, session)
    while #SRC.saved.diagnosticSessions > self.MAX_SESSIONS do table.remove(SRC.saved.diagnosticSessions) end
    SRC.saved.activeDiagnosticSessionId = session.id
    SRC.saved.selectedDiagnosticSession = session.id
    self.sequence = 0
    self:Add("SESSION", "Diagnostic session started: " .. session.name)
    return session
end

function Diagnostics:EndSession()
    local session = self:GetActiveSession()
    if not session then return false end
    self:Add("SESSION", "Diagnostic session ended: " .. session.name)
    session.endedAt = GetTimeStamp and GetTimeStamp() or math.floor(GetGameTimeMilliseconds() / 1000)
    SRC.saved.activeDiagnosticSessionId = nil
    return true
end

function Diagnostics:Add(category, message)
    if message == nil then
        message = category
        category = "INFO"
    end
    if not self:ShouldRecord(category) then return end

    self.throttle = self.throttle or {}
    local throttleKey = tostring(category) .. "|" .. tostring(message)
    local nowMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    local previous = self.throttle[throttleKey]
    if previous and nowMs - previous < 3000 then return end
    self.throttle[throttleKey] = nowMs

    -- Diagnostics can receive EventBus publications during startup before the
    -- diagnostics UI has completed Initialize(). Keep recording independent
    -- from control creation so early player scans cannot fail initialization.
    self.lines = self.lines or {}
    self.sequence = (tonumber(self.sequence) or 0) + 1

    local stamp = string.format("%.3f", GetGameTimeMilliseconds() / 1000)
    local line = string.format("%04d %s [%s] %s", self.sequence, stamp, Sanitize(category), Sanitize(message))
    table.insert(self.lines, 1, line)
    while #self.lines > self.MAX_STORED_LINES do table.remove(self.lines) end

    local session = self:GetActiveSession()
    if session then
        session.entries = session.entries or {}
        table.insert(session.entries, line)
        while #session.entries > self.MAX_SESSION_ENTRIES do table.remove(session.entries, 1) end
    end
    self:RefreshOverlay()
end

function Diagnostics:AddFields(category, eventName, fields)
    if not self:ShouldRecord(category) then return end
    local fieldParts = {}
    for key, value in pairs(fields or {}) do
        table.insert(fieldParts, tostring(key) .. "=" .. Sanitize(value))
    end
    table.sort(fieldParts)
    local parts = { tostring(eventName) }
    for index = 1, #fieldParts do table.insert(parts, fieldParts[index]) end
    self:Add(category, table.concat(parts, " "))
end

function Diagnostics:RefreshOverlay()
    if not self.label or not self.control or self.control:IsHidden() then return end
    local visible = {}
    local count = zo_min(#self.lines, self.MAX_OVERLAY_LINES)
    for index = 1, count do visible[index] = self.lines[index] end
    self.label:SetText(count == 0 and "Conductor diagnostics\nNo events recorded yet" or table.concat(visible, "\n"))
end

function Diagnostics:Clear()
    self.lines = {}
    self.sequence = 0
    self:RefreshOverlay()
end

function Diagnostics:SetOverlay(enabled)
    if self.control then
        self.control:SetHidden(not enabled)
        if enabled then self:RefreshOverlay() end
    end
end

function Diagnostics:GetSessionById(id)
    EnsureSessionStorage()
    for _, session in ipairs(SRC.saved.diagnosticSessions) do
        if session.id == id then return session end
    end
    return nil
end

function Diagnostics:GetSessionItems()
    EnsureSessionStorage()
    local items = {}
    for _, session in ipairs(SRC.saved.diagnosticSessions) do
        local suffix = session.endedAt and "" or " (ACTIVE)"
        items[#items + 1] = { name = session.name .. suffix, data = session.id }
    end
    if #items == 0 then items[1] = { name = "No saved sessions", data = "" } end
    return items
end

function Diagnostics:SelectSession(id)
    SRC.saved.selectedDiagnosticSession = id or ""
    self.viewerPage = 1
    self:RefreshViewer()
end

function Diagnostics:ShowViewer(show)
    if not self.viewer then return end
    self.developerLines = nil
    self.developerTitle = nil
    self.developerFooter = nil
    if show then
        self:RefreshViewer()
        self:ActivateViewer()
    else
        self:CloseActiveViewer()
    end
end

function Diagnostics:ChangeViewerPage(delta)
    self.viewerPage = zo_max(1, (self.viewerPage or 1) + delta)
    self:RefreshViewer()
    self:UpdateViewerKeybinds(true)
end

function Diagnostics:RefreshViewer()
    if not self.viewerTitle then return end
    local session = self:GetSessionById(SRC.saved.selectedDiagnosticSession)
    if not session then
        self.viewerTitle:SetText("DIAGNOSTIC SESSIONS")
        self.viewerBody:SetText("No saved session selected.")
        self.viewerFooter:SetText("")
        return
    end

    local entries = session.entries or {}
    local pageCount = zo_max(1, math.ceil(#entries / self.VIEWER_PAGE_SIZE))
    self.viewerPage = zo_clamp(self.viewerPage or 1, 1, pageCount)
    local first = ((self.viewerPage - 1) * self.VIEWER_PAGE_SIZE) + 1
    local last = zo_min(#entries, first + self.VIEWER_PAGE_SIZE - 1)
    local pageLines = {}
    for index = first, last do pageLines[#pageLines + 1] = entries[index] end

    self.viewerTitle:SetText(session.name)
    self.viewerBody:SetText(#pageLines > 0 and table.concat(pageLines, "\n") or "No events recorded in this session.")
    self.viewerFooter:SetText(string.format("Page %d / %d    Entries %d-%d of %d", self.viewerPage, pageCount, #entries > 0 and first or 0, last, #entries))
end

function Diagnostics:DeleteSelectedSession()
    EnsureSessionStorage()
    local id = SRC.saved.selectedDiagnosticSession
    if not id or id == "" then return end
    for index, session in ipairs(SRC.saved.diagnosticSessions) do
        if session.id == id then
            table.remove(SRC.saved.diagnosticSessions, index)
            if SRC.saved.activeDiagnosticSessionId == id then SRC.saved.activeDiagnosticSessionId = nil end
            break
        end
    end
    SRC.saved.selectedDiagnosticSession = SRC.saved.diagnosticSessions[1] and SRC.saved.diagnosticSessions[1].id or ""
    self.viewerPage = 1
    self:RefreshViewer()
end

function Diagnostics:DeleteAllSessions()
    SRC.saved.diagnosticSessions = {}
    SRC.saved.activeDiagnosticSessionId = nil
    SRC.saved.selectedDiagnosticSession = ""
    self.viewerPage = 1
    self:RefreshViewer()
end

function Diagnostics:GetNetworkSummaryLines()
    local lines = { "Conductor Network" }
    if not SRC.Network or not SRC.Network.GetDiagnostics then
        lines[#lines + 1] = "Network unavailable"
        return lines
    end
    local info = SRC.Network:GetDiagnostics()
    lines[#lines + 1] = string.format("Version: %s", tostring(info.addonVersion))
    lines[#lines + 1] = string.format("Protocol: %s", tostring(info.protocolVersion))
    lines[#lines + 1] = string.format("Transport: %s (%s)", tostring(info.transport), info.transportAvailable and "available" or "unavailable")
    lines[#lines + 1] = string.format("Dedicated payloads: %s", info.dedicatedPayloadReady and "ready" or "unavailable")
    lines[#lines + 1] = string.format("Transport step: %s", tostring(info.transportLastStep or "unknown"))
    lines[#lines + 1] = string.format("Transport init attempts/recoveries: %d / %d", tonumber(info.transportInitAttempts) or 0, tonumber(info.transportRecoveries) or 0)
    lines[#lines + 1] = string.format("Registration/finalize/send: %s / %s / %s", tostring(info.registrationMode or "none"), tostring(info.finalizeMode or "none"), tostring(info.sendMode or "none"))
    if info.transportLastError and info.transportLastError ~= "" then lines[#lines + 1] = "Transport error: " .. tostring(info.transportLastError) end
    if info.lastSendError and info.lastSendError ~= "" then lines[#lines + 1] = "Last send error: " .. tostring(info.lastSendError) end
    lines[#lines + 1] = string.format("Roster members: %d", tonumber(info.rosterMembers) or 0)
    lines[#lines + 1] = string.format("Connected Conductor clients: %d", tonumber(info.connectedPlayers) or 0)
    lines[#lines + 1] = string.format("Messages sent/received/rejected: %d / %d / %d", tonumber(info.sent) or 0, tonumber(info.received) or 0, tonumber(info.rejected) or 0)
    lines[#lines + 1] = string.format("Profiles sent/completed/suppressed: %d / %d / %d", tonumber(info.profileChangesSent) or 0, tonumber(info.profilesCompleted) or 0, tonumber(info.profileSendsSuppressed) or 0)
    lines[#lines + 1] = string.format("Profile commits / partial commits: %d / %d", tonumber(info.profileCommits) or 0, tonumber(info.partialProfilesCommitted) or 0)
    lines[#lines + 1] = string.format("Queue / duplicates / stale / timeouts: %d / %d / %d / %d", tonumber(info.queuedChunks) or 0, tonumber(info.duplicatePackets) or 0, tonumber(info.stalePackets) or 0, tonumber(info.timedOutProfiles) or 0)
    lines[#lines + 1] = string.format("Retry packets sent: %d", tonumber(info.retryPacketsSent) or 0)
    lines[#lines + 1] = string.format("Capability schema: %s", tostring(info.capabilitySchemaVersion or 1))
    lines[#lines + 1] = string.format("Normalized profiles completed: %d", tonumber(info.normalizedProfilesCompleted) or 0)
    lines[#lines + 1] = string.format("Normalized entries sent/received: %d / %d", tonumber(info.normalizedEntriesSent) or 0, tonumber(info.normalizedEntriesReceived) or 0)
    if info.peerNames and #info.peerNames > 0 then
        lines[#lines + 1] = "Known Conductor clients:"
        for _, peerName in ipairs(info.peerNames) do lines[#lines + 1] = "  " .. tostring(peerName) end
    end
    if info.rejectReasons and #info.rejectReasons > 0 then
        lines[#lines + 1] = "Reject reasons:"
        for _, reason in ipairs(info.rejectReasons) do lines[#lines + 1] = "  " .. tostring(reason) end
    end
    local db = SRC.Database and SRC.Database:GetCapabilitySummary() or { players = 0, localPlayers = 0, networkPlayers = 0 }
    lines[#lines + 1] = string.format("Live player objects: %d", db.players or 0)
    return lines
end

function Diagnostics:GetLocalCapabilityLines()
    local lines = { "Raid Intelligence Profile" }
    if not SRC.PlayerScanner then
        lines[#lines + 1] = "Player scanner unavailable"
        return lines
    end

    local snapshot = SRC.PlayerScanner:GetLastLocalSnapshot() or {}
    local capabilities = snapshot.capabilities or {}
    local profile = SRC.RaidIntelligenceEngine and SRC.RaidIntelligenceEngine:GetProfile(snapshot) or nil

    lines[#lines + 1] = string.format("Character: %s", tostring(snapshot.characterName or "unknown"))
    lines[#lines + 1] = string.format("Account: %s", tostring(snapshot.accountName or "unknown"))
    lines[#lines + 1] = string.format("Class: %s", tostring(profile and profile.className or snapshot.classId or "Unknown"))
    lines[#lines + 1] = string.format("Conductor role: %s", tostring(snapshot.role or "UNKNOWN"))

    lines[#lines + 1] = ""
    lines[#lines + 1] = "THIS PLAYER PROVIDES"
    local provided = 0
    if profile then
        for _, status in ipairs(profile.effectStatus or {}) do
            if status.status == "PRESENT" then
                provided = provided + 1
                lines[#lines + 1] = string.format("  + %s", tostring(status.name or status.key))
                if status.sourceSummary and status.sourceSummary ~= "" then
                    lines[#lines + 1] = "      Provided by: " .. tostring(status.sourceSummary)
                end
            end
        end
    end
    if provided == 0 then lines[#lines + 1] = "  None detected" end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "OTHER COMMON TRIAL EFFECTS"
    local missing = 0
    if profile then
        for _, status in ipairs(profile.effectStatus or {}) do
            if status.status ~= "PRESENT" then
                missing = missing + 1
                lines[#lines + 1] = string.format("  - %s: not detected", tostring(status.name or status.key))
                local shown = 0
                for _, provider in ipairs(status.providers or {}) do
                    if shown >= 3 then break end
                    shown = shown + 1
                    lines[#lines + 1] = string.format("      %s: %s", tostring(provider.providerType or "Other"), tostring(provider.name or provider.key))
                    if provider.instructions and provider.instructions ~= "" then
                        lines[#lines + 1] = "        " .. tostring(provider.instructions)
                    end
                end
            end
        end
    end
    if missing == 0 then lines[#lines + 1] = "  All catalogued effects detected" end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "AVAILABLE ASSIGNMENTS"
    if profile and #(profile.responsibilities or {}) > 0 then
        for _, entry in ipairs(profile.responsibilities or {}) do
            lines[#lines + 1] = string.format("  + %s <- %s", tostring(entry.name or entry.key), tostring(entry.sourceSummary or "detected source"))
        end
    else
        lines[#lines + 1] = "  None detected"
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "ROLE FIT"
    if profile and profile.roleFit then
        lines[#lines + 1] = string.format("  %s (%s)", tostring(profile.roleFit.name or "Unclassified"), tostring(profile.roleFit.confidence or "REVIEW"))
        if profile.roleFit.reason then lines[#lines + 1] = "  " .. tostring(profile.roleFit.reason) end
    else
        lines[#lines + 1] = "  Unclassified"
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "DETECTED SOURCES"
    for _, setEntry in ipairs(capabilities.gearSets or {}) do
        lines[#lines + 1] = string.format("  Gear: %s (%d pieces)", tostring(setEntry.setName or "Unknown Set"), tonumber(setEntry.equippedPieces) or 0)
    end
    for _, ultimate in ipairs(capabilities.ultimates or {}) do
        lines[#lines + 1] = string.format("  Ultimate: %s - %s", tostring(ultimate.bar or "BAR"), tostring(ultimate.abilityName or "Unknown"))
    end
    for _, skill in ipairs(capabilities.scribedSkills or {}) do
        lines[#lines + 1] = string.format("  Scribed: %s", tostring(skill.abilityName or "Unknown"))
        if #(skill.scriptNames or {}) > 0 then lines[#lines + 1] = "    Scripts: " .. table.concat(skill.scriptNames, ", ") end
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "Champion Points and Class Masteries: detection pending"
    return lines
end

function Diagnostics:GetTeamIntelligenceLines()
    local lines = { "Current Team Intelligence" }
    if not SRC.TeamIntelligenceEngine then lines[#lines+1]="Team Intelligence Engine unavailable"; return lines end
    local team=SRC.TeamIntelligenceEngine:GetCurrentTeam()
    lines[#lines+1]=string.format("Players: %d  Conductor profiles: %d",#(team.players or {}),team.conductorProfiles or 0)
    lines[#lines+1]=string.format("Catalog coverage: %d/%d (%d%%)  Duplicate effects: %d",team.covered or 0,team.catalogued or 0,team.coveragePercent or 0,team.duplicates or 0)
    for _,effectType in ipairs({"BUFF","DEBUFF","ULTIMATE"}) do
        lines[#lines+1]=""; lines[#lines+1]=effectType.."S"
        for _,status in ipairs(team.effectStatus or {}) do
            if status.effectType==effectType then
                local marker=status.status=="PRESENT" and "+" or "-"
                lines[#lines+1]=string.format("  %s %s",marker,tostring(status.name or status.key))
                if status.status=="PRESENT" then
                    for _,provider in ipairs(status.teamProviders or {}) do
                        local who=(provider.characterName and provider.characterName~="") and provider.characterName or provider.accountName
                        lines[#lines+1]=string.format("      %s via %s",tostring(who or "Unknown"),tostring(provider.sourceSummary or "detected source"))
                    end
                else
                    local best=status.bestProvider
                    lines[#lines+1]="      Best option: "..tostring(best and best.name or "Custom / Other")
                    if best and best.instructions then lines[#lines+1]="      "..tostring(best.instructions) end
                end
            end
        end
    end
    lines[#lines+1]=""; lines[#lines+1]="Not detected does not mean required. Recommended and Custom Setups decide requirements."
    return lines
end

function Diagnostics:ShowNetworkSummary()
    self:SetDeveloperPage("CONDUCTOR NETWORK", self:GetNetworkSummaryLines(), "Network diagnostics")
end

function Diagnostics:ShowLocalCapabilitySummary()
    self:SetDeveloperPage("RAID INTELLIGENCE PROFILE", self:GetLocalCapabilityLines(), "Local capability scan")
end

function Diagnostics:ShowTeamIntelligenceSummary()
    self:SetDeveloperPage("CURRENT TEAM COVERAGE", self:GetTeamIntelligenceLines(), "Team coverage preview")
end

function Diagnostics:ToggleTeamIntelligenceSummary()
    if not self.viewer then return end
    if self.viewer:IsHidden() or (self.viewerTitle and self.viewerTitle:GetText() ~= "CURRENT TEAM COVERAGE") then
        self:ShowTeamIntelligenceSummary()
    else
        self:CloseActiveViewer()
    end
end

function Diagnostics:HideNetworkSummary()
    self:CloseActiveViewer()
end

function Diagnostics:ToggleNetworkSummary()
    if not self.viewer then return end
    if self.viewer:IsHidden() then
        self:ShowNetworkSummary()
    else
        self:HideNetworkSummary()
    end
end

function Diagnostics:ToggleLocalCapabilitySummary()
    if not self.viewer then return end
    if self.viewer:IsHidden() or (self.viewerTitle and self.viewerTitle:GetText() ~= "RAID INTELLIGENCE PROFILE") then
        self:ShowLocalCapabilitySummary()
    else
        self:HideNetworkSummary()
    end
end
