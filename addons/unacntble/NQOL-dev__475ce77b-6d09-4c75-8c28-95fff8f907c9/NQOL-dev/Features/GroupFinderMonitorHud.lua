NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local Hud = {}
local Monitor = NQOL.Features.GroupFinderMonitor

local C = {
    CONTROL_NAME = "NQOLGroupFinderMonitor",
    STATUS_UPDATE_NAMESPACE = "NQOL_GroupFinderMonitorHud_Status",
    STATUS_UPDATE_INTERVAL_MS = 1000,
    DRAW_LEVEL = 70,
    PADDING = 14,
    HEADER_HEIGHT = 70,
    ROW_GAP = 6,
    ROW_HEIGHT = 78,
    BASE_FONT_SIZE = 24,
    ROLE_COUNTS_WIDTH = 124,
    BORDER_TEXTURE_SIZE = 8,
    WHITE_TEXTURE = "EsoUI/Art/Miscellaneous/white.dds",
    GAMEPLAY_SCENES = { hud = true, hudui = true, siegeBar = true },
    NORMAL_COLOR = { 0.24, 0.76, 1, 1 },
    VETERAN_COLOR = { 1, 0.65, 0.19, 1 },
    OTHER_COLOR = { 0.70, 0.49, 1, 1 },
    NEW_COLOR = { 0.49, 0.95, 0.56, 1 },
    ALARM_COLOR = { 1, 0.20, 0.17, 1 },
    HEADER_COLOR = { 0.35, 0.84, 1, 1 },
    TEXT_COLOR = { 0.96, 0.98, 1, 1 },
}

local initialized = false
local sceneCallbackInstalled = false
local statusUpdateInstalled = false
local refreshQueued = false
local statusRefreshQueued = false
local control
local background
local topAccent
local title
local count
local status
local headerDivider
local empty
local rows = {}
local fontCache = {}
local renderTextColor = { 1, 1, 1, 1 }

local Upper = NQOL.Util.Upper

local function MoveAbove(target, level)
    if target.SetDrawLayer and DL_OVERLAY then target:SetDrawLayer(DL_OVERLAY) end
    if target.SetDrawTier and DT_HIGH then target:SetDrawTier(DT_HIGH) end
    if target.SetDrawLevel then target:SetDrawLevel(level or C.DRAW_LEVEL) end
end

local function CreateLabel(parent, alignment)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    label:SetHorizontalAlignment(alignment or TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    if label.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
    MoveAbove(label, C.DRAW_LEVEL + 3)
    return label
end

local function GetFont(offset, fontChoice)
    local size = C.BASE_FONT_SIZE + (offset or 0)
    fontChoice = fontChoice or Monitor.GetFont()
    local key = tostring(fontChoice) .. ":" .. tostring(size)
    if not fontCache[key] then fontCache[key] = NQOL.Util.CreateFontString(fontChoice, size, "ZoFontGamepad22") end
    return fontCache[key]
end

local function IsGameplaySceneShowing()
    local scene = SCENE_MANAGER and SCENE_MANAGER.GetCurrentScene and SCENE_MANAGER:GetCurrentScene()
    local name = scene and scene.GetName and scene:GetName()
    return name == nil or C.GAMEPLAY_SCENES[name] == true
end

local function ShouldShow()
    if Monitor.IsSettingsPanelVisible() and Monitor.GetShowInSettings() then return true end
    return Monitor.GetEnabled() and IsGameplaySceneShowing()
end

local function EnsureControls()
    if control or not WINDOW_MANAGER or not GuiRoot then return end
    control = WINDOW_MANAGER:CreateTopLevelWindow(C.CONTROL_NAME)
    control:SetHidden(true)
    MoveAbove(control, C.DRAW_LEVEL)

    background = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
    background:SetAnchorFill(control)
    MoveAbove(background, C.DRAW_LEVEL + 1)

    topAccent = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
    topAccent:SetTexture(C.WHITE_TEXTURE)
    MoveAbove(topAccent, C.DRAW_LEVEL + 2)

    title = CreateLabel(control)
    count = CreateLabel(control, TEXT_ALIGN_RIGHT)
    status = CreateLabel(control)
    headerDivider = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
    headerDivider:SetTexture(C.WHITE_TEXTURE)
    MoveAbove(headerDivider, C.DRAW_LEVEL + 2)
    empty = CreateLabel(control, TEXT_ALIGN_CENTER)
    empty:SetVerticalAlignment(TEXT_ALIGN_CENTER)
end

local function GetRow(index)
    if rows[index] then return rows[index] end
    local row = {}
    row.control = WINDOW_MANAGER:CreateControl(nil, control, CT_CONTROL)
    row.background = WINDOW_MANAGER:CreateControl(nil, row.control, CT_BACKDROP)
    row.background:SetAnchorFill(row.control)
    row.background:SetEdgeTexture("", 1, 1, 1)
    MoveAbove(row.background, C.DRAW_LEVEL + 2)
    row.accent = WINDOW_MANAGER:CreateControl(nil, row.control, CT_TEXTURE)
    row.accent:SetTexture(C.WHITE_TEXTURE)
    MoveAbove(row.accent, C.DRAW_LEVEL + 3)
    row.eyebrow = CreateLabel(row.control)
    row.activity = CreateLabel(row.control)
    row.details = CreateLabel(row.control)
    row.population = CreateLabel(row.control, TEXT_ALIGN_RIGHT)
    row.newBadge = CreateLabel(row.control, TEXT_ALIGN_RIGHT)
    rows[index] = row
    return row
end

local function HideRows(first)
    for index = first, #rows do rows[index].control:SetHidden(true) end
end

local function GetScreenSize()
    return GuiRoot:GetWidth(), GuiRoot:GetHeight()
end

local function ApplyPosition(width, height, scale)
    local screenWidth, screenHeight = GetScreenSize()
    local x = math.max(screenWidth - (width * scale), 0) * (Monitor.GetHorizontalPosition() / 100)
    local y = math.max(screenHeight - (height * scale), 0) * (Monitor.GetVerticalPosition() / 100)
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

local function GetStatusValues()
    if Monitor.IsSettingsPanelVisible() and not Monitor.GetEnabled() then
        return NQOL.L("features.group_finder_monitor.status_preview"), 0.55, 0.72, 0.88
    elseif not Monitor.HasSelectedCategories() then
        return NQOL.L("features.group_finder_monitor.status_paused"), 0.82, 0.57, 0.24
    elseif Monitor.IsScanning() then
        if Monitor.IsRestoringFilter() then
            return NQOL.L("features.group_finder_monitor.status_restoring_filter"), 1, 0.67, 0.22
        end
        local categoryLabel = Monitor.GetCurrentScanCategoryLabel()
        if categoryLabel then
            return NQOL.L("features.group_finder_monitor.status_checking_category", categoryLabel), 1, 0.67, 0.22
        end
        return NQOL.L("features.group_finder_monitor.status_restoring_filter"), 1, 0.67, 0.22
    elseif not Monitor.HasCompletedScan() then
        return NQOL.L("features.group_finder_monitor.status_paused"), 0.82, 0.57, 0.24
    end
    local remainingSeconds = Monitor.GetSecondsUntilNextRefresh()
    if remainingSeconds ~= nil then
        local minutes = math.floor(remainingSeconds / 60)
        local countdown = string.format("%d:%02d", minutes, remainingSeconds - (minutes * 60))
        return NQOL.L("features.group_finder_monitor.status_live_countdown", countdown), 0.39, 0.92, 0.55
    end
    return NQOL.L("features.group_finder_monitor.status_live"), 0.39, 0.92, 0.55
end

local function RefreshStatus()
    if not control or control:IsHidden() then return end
    local statusText, red, green, blue = GetStatusValues()
    status:SetText(Upper(statusText))
    status:SetColor(red, green, blue, 0.92)
    if empty and not empty:IsHidden() then
        if not Monitor.HasSelectedCategories() then
            empty:SetText(NQOL.L("features.group_finder_monitor.no_categories"))
        elseif Monitor.IsRestoringFilter() then
            empty:SetText(NQOL.L("features.group_finder_monitor.status_restoring_filter"))
        elseif Monitor.IsScanning() then
            empty:SetText(NQOL.L("features.group_finder_monitor.checking"))
        else
            empty:SetText(NQOL.L("features.group_finder_monitor.no_listings"))
        end
    end
end

local function GetRowAccent(data)
    if data.isAlarm then return C.ALARM_COLOR end
    if data.isVeteran then return C.VETERAN_COLOR end
    if data.primary ~= "" then return C.NORMAL_COLOR end
    return C.OTHER_COLOR
end

local function RowNeedsRender(row, data, width, y, rowHeight, fontChoice, textColor)
    return row.renderedKey ~= data.key
        or row.renderedRoleCountsText ~= data.roleCountsText
        or row.renderedSupportsRoles ~= data.supportsRoles
        or row.renderedIsAlarm ~= data.isAlarm
        or row.renderedIsNew ~= data.isNew
        or row.renderedIsVeteran ~= data.isVeteran
        or row.renderedWidth ~= width
        or row.renderedY ~= y
        or row.renderedRowHeight ~= rowHeight
        or row.renderedFont ~= fontChoice
        or row.renderedTextRed ~= textColor[1]
        or row.renderedTextGreen ~= textColor[2]
        or row.renderedTextBlue ~= textColor[3]
        or row.renderedTextAlpha ~= textColor[4]
end

local function RenderRow(row, data, width, y, rowHeight, fontChoice, textColor)
    local accent = GetRowAccent(data)
    row.control:ClearAnchors()
    row.control:SetAnchor(TOPLEFT, control, TOPLEFT, C.PADDING, y)
    row.control:SetDimensions(width - (C.PADDING * 2), rowHeight)
    if data.isAlarm then
        row.background:SetCenterColor(0.46, 0.025, 0.025, 0.92)
        row.background:SetEdgeColor(C.ALARM_COLOR[1], C.ALARM_COLOR[2], C.ALARM_COLOR[3], 0.72)
    else
        row.background:SetCenterColor(0.035, 0.075, 0.11, 0.78)
        row.background:SetEdgeColor(accent[1], accent[2], accent[3], 0.16)
    end
    row.accent:SetColor(accent[1], accent[2], accent[3], accent[4])
    row.accent:ClearAnchors()
    row.accent:SetAnchor(TOPLEFT, row.control, TOPLEFT, 0, 0)
    row.accent:SetDimensions(4, rowHeight)

    local innerWidth = width - (C.PADDING * 2) - 24
    row.eyebrow:SetFont(GetFont(-9, fontChoice))
    local eyebrow = data.primary ~= "" and data.primary ~= data.categoryText
        and NQOL.L("features.group_finder_monitor.row_eyebrow", data.categoryText, data.primary)
        or data.categoryText
    row.eyebrow:SetText(Upper(eyebrow))
    row.eyebrow:SetColor(accent[1], accent[2], accent[3], 0.92)
    row.eyebrow:ClearAnchors()
    row.eyebrow:SetAnchor(TOPLEFT, row.control, TOPLEFT, 14, 4)
    row.eyebrow:SetDimensions(innerWidth - 76, 18)

    local displayTitle = data.preferActivityTitle and data.activity or (data.title ~= "" and data.title or data.activity)
    row.activity:SetFont(GetFont(0, fontChoice))
    row.activity:SetText(displayTitle)
    row.activity:SetColor(textColor[1], textColor[2], textColor[3], textColor[4])
    row.activity:ClearAnchors()
    row.activity:SetAnchor(TOPLEFT, row.control, TOPLEFT, 14, 20)
    local roleColumnSpacing = data.supportsRoles and (C.ROLE_COUNTS_WIDTH + 8) or 0
    local listingTextWidth = innerWidth - roleColumnSpacing
    row.activity:SetDimensions(listingTextWidth, 28)

    local details = ""
    if data.description ~= "" then
        details = data.description
    elseif data.preferActivityTitle and data.title ~= "" and data.title ~= displayTitle then
        details = data.title
    elseif data.title ~= "" and data.activity ~= data.title then
        details = data.activity
    end
    if data.leader and data.leader ~= "" then
        details = details ~= "" and string.format("%s · %s", data.leader, details) or data.leader
    end
    row.details:SetFont(GetFont(-8, fontChoice))
    row.details:SetText(details)
    row.details:SetColor(textColor[1], textColor[2], textColor[3], textColor[4] * 0.66)
    row.details:ClearAnchors()
    row.details:SetAnchor(BOTTOMLEFT, row.control, BOTTOMLEFT, 14, -5)
    row.details:SetDimensions(listingTextWidth, 20)

    row.population:SetFont(GetFont(-7, fontChoice))
    row.population:SetText(data.roleCountsText or "")
    row.population:SetColor(textColor[1], textColor[2], textColor[3], textColor[4] * 0.88)
    row.population:ClearAnchors()
    row.population:SetAnchor(RIGHT, row.control, RIGHT, -10, 1)
    row.population:SetDimensions(C.ROLE_COUNTS_WIDTH, 26)
    row.population:SetHidden(not data.supportsRoles)

    row.newBadge:SetFont(GetFont(-10, fontChoice))
    row.newBadge:SetText(data.isNew and Upper(NQOL.L("features.group_finder_monitor.new_badge")) or "")
    row.newBadge:SetColor(C.NEW_COLOR[1], C.NEW_COLOR[2], C.NEW_COLOR[3], 1)
    row.newBadge:ClearAnchors()
    row.newBadge:SetAnchor(TOPRIGHT, row.control, TOPRIGHT, -10, 4)
    row.newBadge:SetDimensions(58, 18)
    row.renderedKey = data.key
    row.renderedRoleCountsText = data.roleCountsText
    row.renderedSupportsRoles = data.supportsRoles
    row.renderedIsAlarm = data.isAlarm
    row.renderedIsNew = data.isNew
    row.renderedIsVeteran = data.isVeteran
    row.renderedWidth = width
    row.renderedY = y
    row.renderedRowHeight = rowHeight
    row.renderedFont = fontChoice
    row.renderedTextRed = textColor[1]
    row.renderedTextGreen = textColor[2]
    row.renderedTextBlue = textColor[3]
    row.renderedTextAlpha = textColor[4]
    row.control:SetHidden(false)
end

local function Render()
    EnsureControls()
    if not control then return end
    if not ShouldShow() then control:SetHidden(true) return end

    local screenWidth, screenHeight = GetScreenSize()
    local scale = Monitor.GetScale() / 100
    local width = math.min(Monitor.GetWidth(), math.floor((screenWidth * 0.88) / scale))
    local rowHeight = C.ROW_HEIGHT
    local availableHeight = math.floor((screenHeight * 0.86) / scale) - C.HEADER_HEIGHT - (C.PADDING * 2)
    local screenRowLimit = math.max(math.floor((availableHeight + C.ROW_GAP) / (rowHeight + C.ROW_GAP)), 2)
    local dataRows = Monitor.GetRows()
    local visibleRows = math.min(#dataRows, Monitor.GetMaxRows(), screenRowLimit)
    local contentRows = math.max(visibleRows, 1)
    local contentHeight = (contentRows * rowHeight) + ((contentRows - 1) * C.ROW_GAP)
    local height = C.PADDING + C.HEADER_HEIGHT + contentHeight + C.PADDING
    local headerRed, headerGreen, headerBlue, headerAlpha = C.HEADER_COLOR[1], C.HEADER_COLOR[2], C.HEADER_COLOR[3], C.HEADER_COLOR[4]
    local textRed, textGreen, textBlue, textAlpha = C.TEXT_COLOR[1], C.TEXT_COLOR[2], C.TEXT_COLOR[3], C.TEXT_COLOR[4]
    local fontChoice = Monitor.GetFont()
    renderTextColor[1] = textRed
    renderTextColor[2] = textGreen
    renderTextColor[3] = textBlue
    renderTextColor[4] = textAlpha

    control:SetScale(scale)
    control:SetDimensions(width, height)
    background:SetCenterColor(0.018, 0.035, 0.052, Monitor.GetBackgroundOpacity() / 100)
    local borderSize = Monitor.GetBorderSize()
    background:SetEdgeTexture("", C.BORDER_TEXTURE_SIZE, C.BORDER_TEXTURE_SIZE, math.max(borderSize, 1))
    background:SetEdgeColor(headerRed, headerGreen, headerBlue, borderSize > 0 and 0.34 or 0)
    topAccent:SetColor(headerRed, headerGreen, headerBlue, headerAlpha)
    topAccent:ClearAnchors()
    topAccent:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    topAccent:SetDimensions(width, 3)

    title:SetFont(GetFont(3, fontChoice))
    title:SetText(Upper(NQOL.L("features.group_finder_monitor.hud_title")))
    title:SetColor(headerRed, headerGreen, headerBlue, headerAlpha)
    title:ClearAnchors()
    title:SetAnchor(TOPLEFT, control, TOPLEFT, C.PADDING, C.PADDING + 2)
    title:SetDimensions(width * 0.58, 30)
    count:SetFont(GetFont(-8, fontChoice))
    count:SetText(NQOL.L("features.group_finder_monitor.listings_count", #dataRows))
    count:SetColor(textRed, textGreen, textBlue, textAlpha * 0.62)
    count:ClearAnchors()
    count:SetAnchor(TOPRIGHT, control, TOPRIGHT, -C.PADDING, C.PADDING + 5)
    count:SetDimensions(width * 0.46, 22)

    status:SetFont(GetFont(-10, fontChoice))
    status:ClearAnchors()
    status:SetAnchor(TOPLEFT, control, TOPLEFT, C.PADDING, C.PADDING + 33)
    status:SetDimensions(width - (C.PADDING * 2), 20)
    headerDivider:SetColor(headerRed, headerGreen, headerBlue, 0.24)
    headerDivider:ClearAnchors()
    headerDivider:SetAnchor(TOPLEFT, control, TOPLEFT, C.PADDING, C.PADDING + C.HEADER_HEIGHT - 7)
    headerDivider:SetDimensions(width - (C.PADDING * 2), 1)

    local contentTop = C.PADDING + C.HEADER_HEIGHT
    if visibleRows == 0 then
        empty:SetFont(GetFont(-3, fontChoice))
        if not Monitor.HasSelectedCategories() then
            empty:SetText(NQOL.L("features.group_finder_monitor.no_categories"))
        elseif Monitor.IsRestoringFilter() then
            empty:SetText(NQOL.L("features.group_finder_monitor.status_restoring_filter"))
        elseif Monitor.IsScanning() then
            empty:SetText(NQOL.L("features.group_finder_monitor.checking"))
        else
            empty:SetText(NQOL.L("features.group_finder_monitor.no_listings"))
        end
        empty:SetColor(textRed, textGreen, textBlue, textAlpha * 0.68)
        empty:ClearAnchors()
        empty:SetAnchor(CENTER, control, CENTER, 0, 0)
        empty:SetDimensions(width - (C.PADDING * 2) - 24, rowHeight)
        empty:SetHidden(false)
        HideRows(1)
    else
        empty:SetHidden(true)
        for index = 1, visibleRows do
            local row = GetRow(index)
            local data = dataRows[index]
            local y = contentTop + ((index - 1) * (rowHeight + C.ROW_GAP))
            if RowNeedsRender(row, data, width, y, rowHeight, fontChoice, renderTextColor) then
                RenderRow(row, data, width, y, rowHeight, fontChoice, renderTextColor)
            else
                row.control:SetHidden(false)
            end
        end
        HideRows(visibleRows + 1)
    end

    ApplyPosition(width, height, scale)
    control:SetHidden(false)
    RefreshStatus()
end

local function QueueRender()
    if refreshQueued then return end
    refreshQueued = true
    if zo_callLater then
        zo_callLater(function() refreshQueued = false; Render() end, 0)
    else
        refreshQueued = false
        Render()
    end
end

local function QueueStatusRefresh()
    if refreshQueued or statusRefreshQueued then return end
    statusRefreshQueued = true
    if zo_callLater then
        zo_callLater(function()
            statusRefreshQueued = false
            if not refreshQueued then RefreshStatus() end
        end, 0)
    else
        statusRefreshQueued = false
        RefreshStatus()
    end
end

local function InstallSceneCallback()
    if sceneCallbackInstalled or not SCENE_MANAGER or not SCENE_MANAGER.RegisterCallback then return end
    sceneCallbackInstalled = true
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", QueueRender)
end

local function UninstallSceneCallback()
    if not sceneCallbackInstalled or not SCENE_MANAGER or not SCENE_MANAGER.UnregisterCallback then return end
    sceneCallbackInstalled = false
    SCENE_MANAGER:UnregisterCallback("SceneStateChanged", QueueRender)
end

local function InstallStatusUpdate()
    if statusUpdateInstalled or not EVENT_MANAGER then return end
    statusUpdateInstalled = true
    EVENT_MANAGER:RegisterForUpdate(C.STATUS_UPDATE_NAMESPACE, C.STATUS_UPDATE_INTERVAL_MS, RefreshStatus)
end

local function UninstallStatusUpdate()
    if not statusUpdateInstalled or not EVENT_MANAGER then return end
    statusUpdateInstalled = false
    EVENT_MANAGER:UnregisterForUpdate(C.STATUS_UPDATE_NAMESPACE)
end

function Hud.Initialize()
    if initialized then QueueRender() return end
    initialized = true
    EnsureControls()
    QueueRender()
end

function Hud.SetActive(value)
    if value == true then
        if not initialized then Hud.Initialize() end
        InstallSceneCallback()
        InstallStatusUpdate()
        QueueRender()
    else
        UninstallSceneCallback()
        UninstallStatusUpdate()
        if control then control:SetHidden(true) end
    end
end

function Hud.RefreshResults()
    if initialized then QueueRender() end
end

function Hud.RefreshStatus()
    if initialized then QueueStatusRefresh() end
end

function Hud.Refresh()
    Hud.RefreshResults()
end

NQOL.Features.GroupFinderMonitorHud = Hud
