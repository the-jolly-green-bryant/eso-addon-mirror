local SRC = SupportRotationCallouts
SRC.TeamCoverageDashboard = SRC.TeamCoverageDashboard or {}
local Dashboard = SRC.TeamCoverageDashboard
local WM = WINDOW_MANAGER

local CATEGORY_CONFIG = {
    BUFF = { title = "BUFFS", effectType = "BUFF" },
    DEBUFF = { title = "DEBUFFS", effectType = "DEBUFF" },
    OTHER = { title = "OTHER EFFECTS", effectType = "OTHER" },
}

local MAX_COLUMNS = 7
local PANEL_WIDTH = 1040
local PANEL_HEIGHT = 570
local LEFT = 122
local TOP = 94
local COLUMN_WIDTH = 128
local COLUMN_GAP = 2
local HEADER_WIDTH = 104

local ROWS = {
    { key="name", label="EFFECT", height=52 },
    { key="status", label="STATUS", height=42 },
    { key="provider", label="PROVIDER", height=72 },
    { key="source", label="PROVIDED VIA", height=82 },
    { key="recommendation", label="BEST TEAM OPTION", height=112 },
    { key="confidence", label="CONFIDENCE", height=42 },
}

local function Safe(value, limit)
    local text = tostring(value or "")
    limit = limit or 36
    if #text > limit then return string.sub(text, 1, limit - 3) .. "..." end
    return text
end

local function PlayerName(provider)
    if not provider then return "None" end
    if provider.accountName and provider.accountName ~= "" then return provider.accountName end
    return "Unknown"
end

local function StatusDot(status)
    if status == "PRESENT" then return "|c55FF55●|r" end
    return "|cFF5555●|r"
end

local function ConfidenceColor(confidence)
    if confidence == "CONFIRMED" then return "|c55FF55" end
    if confidence == "LIKELY" then return "|cFFFF66" end
    if confidence == "POSSIBLE" then return "|cFFAA44" end
    if confidence == "GENERAL" then return "|cBBBBBB" end
    return "|cFF6666"
end

local function SetBackdrop(control, alpha)
    control:SetCenterColor(0, 0, 0, alpha or 0.24)
    control:SetEdgeColor(0.82, 0.70, 0.34, 0.45)
    control:SetEdgeTexture(nil, 1, 1, 1)
end

function Dashboard:GetCategory()
    local category = tostring((SRC.saved and SRC.saved.teamCoverageCategory) or "BUFF")
    if not CATEGORY_CONFIG[category] then category = "BUFF" end
    return category
end

function Dashboard:GetPage(category)
    SRC.saved.teamCoveragePages = SRC.saved.teamCoveragePages or {}
    return math.max(1, tonumber(SRC.saved.teamCoveragePages[category]) or 1)
end

function Dashboard:SetPage(page)
    local category = self:GetCategory()
    local total = self:GetPageCount(category)
    SRC.saved.teamCoveragePages = SRC.saved.teamCoveragePages or {}
    SRC.saved.teamCoveragePages[category] = zo_clamp(tonumber(page) or 1, 1, total)
    self:Refresh()
end

function Dashboard:ChangePage(delta)
    self:SetPage(self:GetPage(self:GetCategory()) + (tonumber(delta) or 0))
end

function Dashboard:GetStatuses(category)
    local config = CATEGORY_CONFIG[category or self:GetCategory()]
    local team = SRC.TeamIntelligenceEngine and SRC.TeamIntelligenceEngine:GetCurrentTeam() or { effectStatus = {} }
    local output = {}
    for _, status in ipairs(team.effectStatus or {}) do
        if status.effectType == config.effectType then output[#output + 1] = status end
    end
    return output, team
end

function Dashboard:GetPageCount(category)
    local statuses = self:GetStatuses(category)
    return math.max(1, math.ceil(#statuses / MAX_COLUMNS))
end

local function NormalizeSceneName(scene)
    if not scene or not scene.GetName then return "" end
    return string.lower(tostring(scene:GetName() or ""))
end

function Dashboard:IsProtectedScene(scene)
    local name = NormalizeSceneName(scene)
    if name == "" then return false end

    -- ESO's console Mod Browser calls private UI functions. Any addon-driven
    -- KEYBIND_STRIP mutation while that scene is active makes its call stack
    -- insecure and causes a protected-function error.
    if string.find(name, "modbrowser", 1, true) then return true end
    if string.find(name, "mod_browser", 1, true) then return true end
    if string.find(name, "mod browser", 1, true) then return true end
    if string.find(name, "addonsmanaged", 1, true) then return true end
    if string.find(name, "addon_manager", 1, true) then return true end

    return false
end

function Dashboard:IsProtectedSceneActive()
    if not SCENE_MANAGER or not SCENE_MANAGER.GetCurrentScene then return false end
    return self:IsProtectedScene(SCENE_MANAGER:GetCurrentScene())
end

function Dashboard:ShouldShow()
    if self.sceneSuspended == true or self:IsProtectedSceneActive() then return false end
    if self.preview == true then return true end
    if not SRC.saved or SRC.saved.teamCoverageDashboardEnabled ~= true then return false end
    -- This is an on-demand reference panel and intentionally ignores the
    -- persistent dashboard visibility preference.
    return true
end

function Dashboard:BuildKeybinds()
    if self.keybinds then return end
    self.keybinds = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        {
            name = "Previous Page",
            keybind = "UI_SHORTCUT_LEFT_TRIGGER",
            callback = function() Dashboard:ChangePage(-1) end,
            ethereal = true,
            order = 1,
            visible = function() return Dashboard.control and not Dashboard.control:IsHidden() end,
        },
        {
            name = "Next Page",
            keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
            callback = function() Dashboard:ChangePage(1) end,
            ethereal = true,
            order = 1,
            visible = function() return Dashboard.control and not Dashboard.control:IsHidden() end,
        },
        {
            name = "Back",
            keybind = "UI_SHORTCUT_NEGATIVE",
            callback = function() Dashboard:Hide() end,
            order = 2,
            visible = function() return Dashboard.control and not Dashboard.control:IsHidden() end,
        },
    }
end

function Dashboard:UpdateKeybinds(visible)
    if not KEYBIND_STRIP then return end
    self:BuildKeybinds()

    -- Never touch the global keybind strip after a protected system scene
    -- has become active. SceneStateChanged removes our group while the prior
    -- scene is still hiding.
    if self:IsProtectedSceneActive() then return end
    if self.sceneSuspended == true then visible = false end

    if visible and not self.keybindsAdded then
        KEYBIND_STRIP:AddKeybindButtonGroup(self.keybinds)
        self.keybindsAdded = true
    elseif not visible and self.keybindsAdded then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybinds)
        self.keybindsAdded = false
    end

    -- Do not call UpdateKeybindButtonGroup from the one-second dashboard
    -- refresh. That call was the source of the Mod Browser private-function
    -- error. Page changes do not require a keybind-strip rebuild.
end

function Dashboard:SuspendForProtectedScene()
    self.sceneSuspended = true
    if not self:IsProtectedSceneActive() then
        self:UpdateKeybinds(false)
    end
    if self.control then self.control:SetHidden(true) end
end

function Dashboard:ResumeAfterProtectedScene()
    if not self.sceneSuspended then return end
    self.sceneSuspended = false
    self:Refresh()
end

function Dashboard:RegisterSceneSafety()
    if self.sceneSafetyRegistered or not SCENE_MANAGER or not SCENE_MANAGER.RegisterCallback then return end
    self.sceneSafetyRegistered = true

    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
        local protected = Dashboard:IsProtectedScene(scene)

        -- Remove Conductor's keybind group while the current scene is still
        -- transitioning out. This ensures no addon keybind mutation occurs
        -- after a protected Mod Browser scene becomes current.
        if newState == SCENE_HIDING and Dashboard.keybindsAdded then
            Dashboard:UpdateKeybinds(false)
        end

        if protected and (newState == SCENE_SHOWING or newState == SCENE_SHOWN) then
            Dashboard.sceneSuspended = true
            if Dashboard.control then Dashboard.control:SetHidden(true) end
            return
        end

        if protected and (newState == SCENE_HIDING or newState == SCENE_HIDDEN) then
            zo_callLater(function()
                if not Dashboard:IsProtectedSceneActive() then
                    Dashboard:ResumeAfterProtectedScene()
                end
            end, 50)
            return
        end

        if newState == SCENE_SHOWN and not Dashboard:IsProtectedSceneActive() then
            Dashboard:ResumeAfterProtectedScene()
        end
    end)
end

local function PlayStationCircleGlyph(size)
    size = tonumber(size) or 26
    return string.format("|t%d:%d:EsoUI/Art/Buttons/Gamepad/gp_circle.dds|t", size, size)
end

function Dashboard:Initialize()
    local c = WM:CreateTopLevelWindow("ConductorTeamCoverageDashboard")
    c:SetDimensions(PANEL_WIDTH, PANEL_HEIGHT)
    c:SetAnchor(CENTER, GuiRoot, CENTER, SRC.saved.teamCoverageOffsetX or 0, SRC.saved.teamCoverageOffsetY or 0)
    c:SetScale(SRC.saved.teamCoverageScale or 0.85)
    c:SetClampedToScreen(true)
    c:SetHidden(true)

    local bg = WM:CreateControl(nil, c, CT_BACKDROP)
    bg:SetAnchorFill()
    SetBackdrop(bg, math.max(tonumber(SRC.saved.dashboardBackgroundOpacity) or 0.38, 0.66))
    bg:SetEdgeColor(1, 0.83, 0.28, 0.75)
    bg:SetEdgeTexture(nil, 2, 2, 2)

    local title = WM:CreateControl(nil, c, CT_LABEL)
    title:SetAnchor(TOPLEFT, c, TOPLEFT, 18, 10)
    title:SetAnchor(TOPRIGHT, c, TOPRIGHT, -18, 10)
    title:SetFont("$(BOLD_FONT)|24|outline")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetText("GROUP COVERAGE DASHBOARD")

    local subtitle = WM:CreateControl(nil, c, CT_LABEL)
    subtitle:SetAnchor(TOPLEFT, c, TOPLEFT, 18, 40)
    subtitle:SetAnchor(TOPRIGHT, c, TOPRIGHT, -18, 40)
    subtitle:SetFont("$(BOLD_FONT)|20|outline")
    subtitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local summary = WM:CreateControl(nil, c, CT_LABEL)
    summary:SetAnchor(TOPLEFT, c, TOPLEFT, 18, 65)
    summary:SetAnchor(TOPRIGHT, c, TOPRIGHT, -18, 65)
    summary:SetFont("$(CHAT_FONT)|15|outline")
    summary:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local recommendationText = WM:CreateControl(nil, c, CT_LABEL)
    recommendationText:SetAnchor(TOPLEFT, c, TOPLEFT, 42, 105)
    recommendationText:SetAnchor(BOTTOMRIGHT, c, BOTTOMRIGHT, -42, -58)
    recommendationText:SetFont("$(CHAT_FONT)|19|soft-shadow-thick")
    recommendationText:SetColor(0.95, 0.95, 0.95, 1)
    recommendationText:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    recommendationText:SetHidden(true)

    self.rowHeaders = {}
    local headerY = TOP
    for _, rowConfig in ipairs(ROWS) do
        local headerCell = WM:CreateControl(nil, c, CT_BACKDROP)
        headerCell:SetAnchor(TOPLEFT, c, TOPLEFT, 18, headerY)
        headerCell:SetDimensions(HEADER_WIDTH, rowConfig.height)
        SetBackdrop(headerCell, 0.48)
        local headerLabel = WM:CreateControl(nil, headerCell, CT_LABEL)
        headerLabel:SetAnchor(TOPLEFT, headerCell, TOPLEFT, 4, 3)
        headerLabel:SetAnchor(BOTTOMRIGHT, headerCell, BOTTOMRIGHT, -4, -3)
        headerLabel:SetFont("$(BOLD_FONT)|13|outline")
        headerLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        headerLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        headerLabel:SetText(rowConfig.label)
        self.rowHeaders[rowConfig.key] = headerLabel
        headerY = headerY + rowConfig.height
    end

    self.cells = {}
    local x = LEFT
    for col = 1, MAX_COLUMNS do
        self.cells[col] = {}
        local y = TOP
        for _, rowConfig in ipairs(ROWS) do
            local cell = WM:CreateControl(nil, c, CT_BACKDROP)
            cell:SetAnchor(TOPLEFT, c, TOPLEFT, x, y)
            cell:SetDimensions(COLUMN_WIDTH, rowConfig.height)
            SetBackdrop(cell, rowConfig.key == "name" and 0.50 or 0.34)

            local label = WM:CreateControl(nil, cell, CT_LABEL)
            label:SetAnchor(TOPLEFT, cell, TOPLEFT, 4, 3)
            label:SetAnchor(BOTTOMRIGHT, cell, BOTTOMRIGHT, -4, -3)
            label:SetFont(rowConfig.key == "name" and "$(BOLD_FONT)|14|outline" or "$(CHAT_FONT)|13|outline")
            label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
            self.cells[col][rowConfig.key] = label
            y = y + rowConfig.height
        end
        x = x + COLUMN_WIDTH + COLUMN_GAP
    end

    local footer = WM:CreateControl(nil, c, CT_LABEL)
    footer:SetHidden(true)

    self.control = c
    self.subtitle = subtitle
    self.summary = summary
    self.recommendationText = recommendationText
    self.footer = footer
    self:RegisterSceneSafety()
    self:Refresh()
    if EVENT_MANAGER then
        EVENT_MANAGER:RegisterForUpdate("ConductorTeamCoverageRefresh", 1000, function() Dashboard:Refresh() end)
    end
end

function Dashboard:FormatRecommendation(status)
    if status.status == "PRESENT" then
        local count = tonumber(status.providerCount) or 0
        if count > 1 then return tostring(count) .. " providers detected" end
        return "Covered"
    end
    if status.teamRecommendation then
        local r = status.teamRecommendation
        local who = r.playerName and (r.playerName .. "\n") or ""
        return who .. Safe(r.providerName or r.name or "Custom / Other", 30)
    end
    local options = status.providers or {}
    if #options == 1 then return Safe(options[1].name or "Custom / Other", 32) end
    if #options > 1 then return "Review valid providers" end
    return "Custom / Other"
end

function Dashboard:FillColumn(column, status)
    local cells = self.cells[column]
    if not status then
        for _, rowConfig in ipairs(ROWS) do cells[rowConfig.key]:SetText("") end
        return
    end
    local provider = status.teamProviders and status.teamProviders[1]
    local confidence = status.status == "PRESENT" and (provider and provider.confidence or "CONFIRMED") or (status.teamRecommendation and status.teamRecommendation.confidence or "GENERAL")
    cells.name:SetText(Safe(status.name, 28))
    cells.status:SetText(StatusDot(status.status) .. "\n" .. (status.status == "PRESENT" and "COVERED" or "MISSING"))
    cells.provider:SetText(status.status == "PRESENT" and Safe(PlayerName(provider), 28) or "No provider")
    cells.source:SetText(status.status == "PRESENT" and Safe(provider and provider.sourceSummary or "Detected", 36) or "Not covered")
    cells.recommendation:SetText(self:FormatRecommendation(status))
    cells.confidence:SetText(ConfidenceColor(confidence) .. tostring(confidence) .. "|r")
end


function Dashboard:SetGridHidden(hidden)
    for _, label in pairs(self.rowHeaders or {}) do label:SetHidden(hidden) end
    for _, column in pairs(self.cells or {}) do
        for _, label in pairs(column) do
            label:SetHidden(hidden)
            local parent = label:GetParent()
            if parent then parent:SetHidden(hidden) end
        end
    end
end

function Dashboard:BuildRecommendationText()
    local team = SRC.TeamIntelligenceEngine and SRC.TeamIntelligenceEngine:GetCurrentTeam() or { players={}, effectStatus={} }
    local lines = { "|cFFD447CURRENT GROUP|r" }
    local players = team.players or {}
    if #players == 0 and SRC.Roster and SRC.Roster.accountToUnitTag then
        for account in pairs(SRC.Roster.accountToUnitTag) do players[#players+1] = { accountName=account } end
    end
    table.sort(players, function(a,b) return tostring(a.accountName or "") < tostring(b.accountName or "") end)
    if #players == 0 then lines[#lines+1] = "No grouped players were found." end
    for _, player in ipairs(players) do
        lines[#lines+1] = string.format("• %s  %s", tostring(player.accountName or "Unknown"), tostring(player.role or player.inferredRole or ""))
    end
    lines[#lines+1] = ""
    lines[#lines+1] = "|cFFD447MISSING BUFFS, DEBUFFS, AND EFFECTS|r"
    local missing = {}
    for _, status in ipairs(team.effectStatus or {}) do
        if status.status ~= "PRESENT" then missing[#missing+1] = status end
    end
    table.sort(missing, function(a,b) return tostring(a.name or "") < tostring(b.name or "") end)
    if #missing == 0 then
        lines[#lines+1] = "Conductor found coverage for every enabled effect."
    else
        for index, status in ipairs(missing) do
            if index > 16 then lines[#lines+1] = string.format("• %d more enabled effects are missing", #missing-16); break end
            lines[#lines+1] = string.format("• %s: %s", tostring(status.name or status.key or "Unknown"), self:FormatRecommendation(status))
        end
    end
    lines[#lines+1] = ""
    lines[#lines+1] = "This is a basic launch recommendation. It does not change the team automatically."
    return table.concat(lines, "\n")
end

function Dashboard:ShowRecommendations()
    SRC.saved.teamCoverageCategory = "RECOMMENDATION"
    SRC.saved.teamCoverageDashboardEnabled = true
    self.preview = true
    if SRC.TeamIntelligenceEngine and SRC.TeamIntelligenceEngine.BuildCurrentTeam then SRC.TeamIntelligenceEngine:BuildCurrentTeam() end
    self:Refresh()
end

function Dashboard:Refresh()
    if not self.control then return end

    -- Protected console system scenes must remain completely isolated from
    -- addon keybind-strip work, including periodic dashboard refreshes.
    if self:IsProtectedSceneActive() then
        self.sceneSuspended = true
        self.control:SetHidden(true)
        if self.settingsPanelAcquired and SRC.Diagnostics then
            SRC.Diagnostics:ReleaseSettingsPanel("teamCoverage")
            self.settingsPanelAcquired = false
        end
        return
    end

    -- Keep recommendations current while the reference panel is open. This
    -- catches gear, bar, skill, and enchant changes even when a platform event
    -- arrives late or is not emitted by a bulk loadout swap.
    local now = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    if self.control and not self.control:IsHidden() and SRC.PlayerScanner and (now - (self.lastLiveScanAt or 0)) >= 250 then
        self.lastLiveScanAt = now
        SRC.PlayerScanner:RefreshLocalCapabilities(false)
    end
    local visible = self:ShouldShow()
    self.control:SetHidden(not visible)
    self:UpdateKeybinds(visible)
    if visible and not self.settingsPanelAcquired and SRC.Diagnostics then
        SRC.Diagnostics:AcquireSettingsPanel("teamCoverage")
        self.settingsPanelAcquired = true
    elseif not visible and self.settingsPanelAcquired and SRC.Diagnostics then
        SRC.Diagnostics:ReleaseSettingsPanel("teamCoverage")
        self.settingsPanelAcquired = false
    end
    if not visible then return end

    local category = tostring(SRC.saved.teamCoverageCategory or "BUFF")
    if category == "RECOMMENDATION" then
        self.subtitle:SetText("RAID SETUP RECOMMENDATION")
        self.summary:SetText("Current group and missing enabled effects")
        self:SetGridHidden(true)
        self.recommendationText:SetHidden(false)
        self.recommendationText:SetText(self:BuildRecommendationText())
        self.footer:SetText("")
        return
    end
    if not CATEGORY_CONFIG[category] then category = "BUFF"; SRC.saved.teamCoverageCategory = category end
    self:SetGridHidden(false)
    self.recommendationText:SetHidden(true)
    local statuses, team = self:GetStatuses(category)
    local pageCount = math.max(1, math.ceil(#statuses / MAX_COLUMNS))
    local page = zo_clamp(self:GetPage(category), 1, pageCount)
    SRC.saved.teamCoveragePages[category] = page

    self.control:SetScale(SRC.saved.teamCoverageScale or 0.85)
    self.subtitle:SetText(CATEGORY_CONFIG[category].title)

    local covered, duplicates = 0, 0
    for _, status in ipairs(statuses) do
        if status.status == "PRESENT" then covered = covered + 1 end
        if (status.providerCount or 0) > 1 then duplicates = duplicates + 1 end
    end
    self.summary:SetText(string.format("Covered %d/%d  •  Missing %d  •  Duplicates %d  •  Profiles %d  •  Page %d/%d", covered, #statuses, #statuses-covered, duplicates, team.conductorProfiles or 0, page, pageCount))

    local first = ((page - 1) * MAX_COLUMNS) + 1
    for column = 1, MAX_COLUMNS do self:FillColumn(column, statuses[first + column - 1]) end
    self.footer:SetText("")
end

function Dashboard:ShowCategory(category)
    category = tostring(category or "BUFF")
    if not CATEGORY_CONFIG[category] then category = "BUFF" end
    SRC.saved.teamCoverageCategory = category
    SRC.saved.teamCoverageDashboardEnabled = true
    self.preview = true
    self:Refresh()
end

function Dashboard:Hide()
    self.preview = false
    SRC.saved.teamCoverageDashboardEnabled = false
    self:Refresh()
end

function Dashboard:SetEnabled(enabled)
    SRC.saved.teamCoverageDashboardEnabled = enabled == true
    if not enabled then self.preview = false end
    self:Refresh()
end

function Dashboard:ToggleCategory(category)
    if self:ShouldShow() and self:GetCategory() == category then self:Hide() else self:ShowCategory(category) end
end
